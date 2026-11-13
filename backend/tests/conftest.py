"""Teststufe gegen PostgreSQL (ADR 0007, Abschnitt "Teststufen" und Festlegung S1.1; R3-F-008).

Die Sitzungsfixture postgres_instanz startet, sobald ein Test sie anfordert, einen
Wegwerf-Container aus genau dem Digest, den deploy/compose.test.yml für den Dienst
datenbank nennt (eine Quelle). Der Container hat kein Netz und keinen veröffentlichten
Port; die Verbindung läuft über einen Unix-Socket in einem Wegwerfverzeichnis unter TMPDIR
beziehungsweise /tmp, stets ausserhalb des Arbeitsbaums, mit scram-sha-256 auch dort. Die Passwörter aller drei Rollen sind je Lauf
zufällig und stehen nur im Speicher und im Wegwerfverzeichnis: die Verbindungspasswörter in
Dateien mit Modus 0600 in einem Verzeichnis 0700, das des Superusers in einer Datei 0644 in einem
Verzeichnis 0755 (nur lesbar in den Container eingehängt; das Wegwerfverzeichnis darüber ist 0700).

Fehlt docker, der Daemon oder das Image, endet die Fixture mit einer Meldung, die die fehlende
Sache und den nächsten Schritt nennt; übersprungen wird nie (ein übersprungener Test wäre
ein grünes Urteil ohne Prüfung). Das Image wird nie geladen (--pull=never).

Die Werkzeuge docker laufen mit einer Umgebung aus PATH und HOME allein: DOCKER_HOST,
DOCKER_CONTEXT und DOCKER_CONFIG des Aufrufers wirken nicht, wie bei der Wache im Makefile;
massgeblich ist der Standard-Socket, soweit HOME ihn nicht umlenkt: HOME wird durchgereicht, ein
currentContext in $HOME/.docker/config.json lenkt Fixture und Wache gleichermassen.
Ruff-Ausnahmen S603 und S607 gelten für diese Datei (benannt in pyproject.toml): der
Aufruf von docker erfolgt als Liste ohne Shell, mit einem Programmnamen aus dem PATH und
einem Digest, der gegen das Muster sha256 plus 64 Hexzeichen geprüft ist.
"""

import asyncio
import importlib.util
import ipaddress
import os
import re
import secrets
import shutil
import socket
import ssl
import subprocess
import sys
import tempfile
import time
from collections.abc import (
    AsyncIterator,
    Awaitable,
    Callable,
    Iterator,
    Mapping,
    Sequence,
)
from contextlib import asynccontextmanager
from dataclasses import dataclass, field
from datetime import UTC, datetime
from pathlib import Path
from types import ModuleType
from uuid import UUID

import pytest
from alembic import command
from alembic.config import Config
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncConnection, AsyncEngine

from r3cosint.ausgang.aufloesung import Adresse, AufloesungsFehler
from r3cosint.ausgang.client import GebundenerVerbindungsweg, SpurkontextDatenbank
from r3cosint.ausgang.positivliste import Positivliste, laden
from r3cosint.core.datenbank import engine_erzeugen
from r3cosint.core.fehler import KonfigurationsFehler
from r3cosint.core.kennung import neue_kennung
from r3cosint.core.konfiguration import Datenbankverbindung
from r3cosint.fall.service import (
    Eroeffnung,
    Fall,
    Rechtsregime,
    eroeffnen,
    pseudonymisierer_laden,
)
from r3cosint.spur.payload import Verbindungsversuch
from r3cosint.spur.service import (
    Eingabe,
    Eintrag,
    Entitaet,
    FallEroeffnet,
    Kennzeichnung,
    Pseudonymisierer,
    Spur,
    anfuegen,
    ketten_anlegen,
)

WURZEL = Path(__file__).resolve().parents[2]
COMPOSE_DATEI = WURZEL / "deploy" / "compose.test.yml"
MIGRATIONEN = WURZEL / "backend" / "migrationen"
LABEL = "r3cosint-test-wegwerf"
IMAGE_PRAEFIX = "docker.io/library/postgres@sha256:"
DIGEST_ZEILE = re.compile(
    r"^\s*image:\s*docker\.io/library/postgres@sha256:([0-9a-f]{64})\s*$",
    re.MULTILINE,
)
SUPERUSER = "r3cosint_test"
EIGENTUEMER = "r3cosint_eigentuemer"
ANWENDUNG = "r3cosint_anwendung"
HAUPTDATENBANK = "r3cosint_test"
VORLAGE = "vorlage"
VORLAGE_0002 = "vorlage_0002"
SOCKET_PORT = 5432
BEREITSCHAFT_FRIST_SEKUNDEN = 90


@pytest.fixture(scope="session")
def anyio_backend() -> str:
    """Die Datenbanktests laufen allein unter asyncio."""
    return "asyncio"


def docker_umgebung() -> dict[str, str]:
    """Umgebung für docker: PATH und HOME, nichts vom Aufrufer sonst."""
    return {
        "PATH": os.environ.get("PATH", "/usr/bin:/bin"),
        "HOME": os.environ.get("HOME", "/"),
    }


def _docker(
    docker: str, *argumente: str, zeitgrenze: float = 120
) -> subprocess.CompletedProcess[str]:
    return subprocess.run(  # Liste ohne Shell, siehe Kopf
        [docker, *argumente],
        env=docker_umgebung(),
        capture_output=True,
        text=True,
        timeout=zeitgrenze,
        check=False,
    )


def digest_lesen(compose_datei: Path = COMPOSE_DATEI) -> str:
    """Liest den Digest des Dienstes datenbank; genau eine Zeile mit 64 Hexzeichen."""
    try:
        inhalt = compose_datei.read_text(encoding="utf-8")
    except OSError as fehler:
        raise KonfigurationsFehler(
            f"Die Datei {compose_datei} ist nicht lesbar.",
            "Den Stand von deploy/compose.test.yml wiederherstellen.",
        ) from fehler
    gefunden = DIGEST_ZEILE.findall(inhalt)
    if len(gefunden) != 1:
        raise KonfigurationsFehler(
            f"{compose_datei} nennt den Digest des Dienstes datenbank nicht genau einmal.",
            "Die Zeile 'image: docker.io/library/postgres@sha256:<64 Hexzeichen>' wiederherstellen.",
        )
    return str(gefunden[0])


def voraussetzungen_pruefen(docker: str = "docker") -> str:
    """Prüft docker, Daemon und Image; liefert die Bezeichnung des Images über den Digest.

    Jede fehlende Sache endet mit KonfigurationsFehler, der sie und den nächsten Schritt nennt.
    """
    bild = IMAGE_PRAEFIX + digest_lesen()
    if (
        shutil.which(docker, path=docker_umgebung()["PATH"]) is None
        and not Path(docker).is_file()
    ):
        raise KonfigurationsFehler(
            "Das Programm docker fehlt.",
            "Docker Engine installieren (https://docs.docker.com/engine/install/).",
        )
    try:
        info = _docker(docker, "info", zeitgrenze=30)
    except (OSError, subprocess.TimeoutExpired) as fehler:
        raise KonfigurationsFehler(
            "Der Docker-Daemon ist nicht erreichbar.",
            "Den Docker-Dienst starten (zum Beispiel sudo systemctl start docker).",
        ) from fehler
    if info.returncode != 0:
        raise KonfigurationsFehler(
            "Der Docker-Daemon ist nicht erreichbar.",
            "Den Docker-Dienst starten (zum Beispiel sudo systemctl start docker).",
        )
    if _docker(docker, "image", "inspect", bild, zeitgrenze=30).returncode != 0:
        raise KonfigurationsFehler(
            f"Das Image {bild} liegt lokal nicht vor.",
            f"Mit 'docker pull {bild}' laden (nur über den Digest; die Teststufe lädt nie).",
        )
    return bild


@pytest.fixture
def voraussetzungen() -> Callable[[str], str]:
    """Die Prüfung der Voraussetzungen, damit Tests sie mit einem Ersatz für docker aufrufen."""
    return voraussetzungen_pruefen


@pytest.fixture
def sql_als_ganzes() -> Callable[[AsyncConnection, str], Awaitable[None]]:
    """Führt einen SQL-Text als Ganzes im einfachen Abfrageprotokoll aus."""
    return _sql_als_ganzes


@pytest.fixture
def aufraeumen_mit_ersatz(
    monkeypatch: pytest.MonkeyPatch,
) -> Callable[[Exception, Path], list[str]]:
    """_aufraeumen ohne Container: docker wirft den übergebenen Fehler, die Frist ist kurz.

    conftest ist unter --import-mode=importlib kein importierbares Modul; die Fixture reicht
    die Funktion samt Haken für den Ersatz an die Tests weiter.
    """

    def ausfuehren(fehler: Exception, wurzel: Path) -> list[str]:
        def ersatz(
            *_argumente: str, **_optionen: float
        ) -> subprocess.CompletedProcess[str]:
            raise fehler

        monkeypatch.setitem(globals(), "_docker", ersatz)
        monkeypatch.setitem(globals(), "ABRAEUMEN_FRIST_SEKUNDEN", 0.5)
        return _aufraeumen("r3cosint-test-ersatz", wurzel)

    return ausfuehren


@pytest.fixture
def docker_aufruf() -> Callable[..., subprocess.CompletedProcess[str]]:
    """Aufruf von docker mit der Umgebung der Fixture (für Tests, die den Container befragen)."""
    return lambda *argumente: _docker("docker", *argumente, zeitgrenze=60)


@dataclass(frozen=True)
class PostgresInstanz:
    """Der laufende Wegwerf-Container und die Orte seiner Anbindung."""

    docker: str
    container: str
    bild: str
    laufkennung: str
    wurzel: Path
    socket_verzeichnis: Path
    passwort_dateien: dict[str, Path]
    passwoerter: dict[str, str] = field(repr=False)
    # Sitzungswerte unmittelbar nach der Grundeinrichtung (Zusicherung: beide leer).
    sitzungswerte: dict[str, str] = field(default_factory=dict, repr=False)

    def verbindung(self, benutzer: str, datenbank: str) -> Datenbankverbindung:
        """Parameter der Verbindung über den Socket; das Passwort steht in seiner Datei."""
        return Datenbankverbindung(
            host=str(self.socket_verzeichnis),
            port=SOCKET_PORT,
            name=datenbank,
            benutzer=benutzer,
            passwort_datei=self.passwort_dateien[benutzer],
        )


def _datei_schreiben(pfad: Path, inhalt: str, modus: int) -> None:
    deskriptor = os.open(pfad, os.O_WRONLY | os.O_CREAT | os.O_EXCL, modus)
    with os.fdopen(deskriptor, "w", encoding="utf-8") as datei:
        datei.write(inhalt)
    # Der Modus der Anlage wird durch umask verengt; ein ausdrücklicher Aufruf stellt ihn her.
    pfad.chmod(modus)


def _wegwerfverzeichnis_anlegen() -> Path:
    """Legt das Wegwerfverzeichnis an, nie im Arbeitsbaum; Modus 0700 (mkdtemp)."""
    wurzel = Path(tempfile.mkdtemp(prefix="r3cosint-test-")).resolve()
    if wurzel.is_relative_to(WURZEL):
        shutil.rmtree(wurzel, ignore_errors=True)
        raise KonfigurationsFehler(
            "Das Wegwerfverzeichnis läge im Arbeitsbaum.",
            "TMPDIR auf einen Ort ausserhalb des Arbeitsbaums setzen oder entfernen.",
        )
    return wurzel


def _warten_bis_bereit(instanz: PostgresInstanz) -> None:
    """Wartet auf das Ende der Initialisierung und dann auf die erste Verbindung.

    Die Initialisierung des Images läuft mit einem vorläufigen Server im selben Socket-
    Verzeichnis; eine Verbindung vorher träfe ihn und bräche beim Neustart ab.
    """
    ende = time.monotonic() + BEREITSCHAFT_FRIST_SEKUNDEN
    while time.monotonic() < ende:
        protokoll = _docker(instanz.docker, "logs", instanz.container, zeitgrenze=30)
        if "PostgreSQL init process complete" in protokoll.stdout + protokoll.stderr:
            break
        time.sleep(0.5)
    else:
        raise KonfigurationsFehler(
            "Die Initialisierung der Datenbank endete nicht innerhalb von "
            f"{BEREITSCHAFT_FRIST_SEKUNDEN} Sekunden.",
            f"Das Protokoll mit 'docker logs {instanz.container}' lesen.",
        )

    async def verbinden() -> None:
        engine = engine_erzeugen(instanz.verbindung(SUPERUSER, HAUPTDATENBANK))
        try:
            async with engine.connect() as verbindung:
                await verbindung.execute(text("SELECT 1"))
        finally:
            await engine.dispose()

    while time.monotonic() < ende:
        try:
            asyncio.run(verbinden())
        except Exception:  # noqa: BLE001 - jede Verbindungsstörung heisst "noch nicht bereit"
            time.sleep(0.5)
        else:
            return
    raise KonfigurationsFehler(
        "Die Datenbank nahm keine Verbindung an.",
        f"Das Protokoll mit 'docker logs {instanz.container}' lesen.",
    )


async def _sql_als_ganzes(verbindung: AsyncConnection, sql: str) -> None:
    """Führt den Text als Ganzes im einfachen Abfrageprotokoll aus (mehrere Anweisungen)."""
    roh = await verbindung.get_raw_connection()
    await roh.driver_connection.execute(sql)  # type: ignore[union-attr]


async def _vorlage_aufbauen(instanz: PostgresInstanz) -> None:
    """Datenbank vorlage_0002 (Grundeinrichtung, Revisionen bis 0002), daraus vorlage bis Kopf."""
    super_engine = engine_erzeugen(instanz.verbindung(SUPERUSER, HAUPTDATENBANK))
    try:
        async with super_engine.connect() as verbindung:
            verbindung = await verbindung.execution_options(
                isolation_level="AUTOCOMMIT"
            )
            await verbindung.execute(text(f"CREATE DATABASE {VORLAGE_0002}"))
    finally:
        await super_engine.dispose()
    vorlage_engine = engine_erzeugen(instanz.verbindung(SUPERUSER, VORLAGE_0002))
    try:
        async with vorlage_engine.connect() as verbindung:
            verbindung = await verbindung.execution_options(
                isolation_level="AUTOCOMMIT"
            )
            for rolle, schluessel in (
                (EIGENTUEMER, "passwort_eigentuemer"),
                (ANWENDUNG, "passwort_anwendung"),
            ):
                await verbindung.execute(
                    text("SELECT set_config(:name, :wert, false)"),
                    {
                        "name": f"r3cosint.{schluessel}",
                        "wert": instanz.passwoerter[rolle],
                    },
                )
            sql = (MIGRATIONEN / "sql" / "rollen_und_schema.sql").read_text(
                encoding="utf-8"
            )
            await _sql_als_ganzes(verbindung, sql)
            for schluessel in ("passwort_eigentuemer", "passwort_anwendung"):
                wert = await verbindung.execute(
                    text("SELECT current_setting(:name, true)"),
                    {"name": f"r3cosint.{schluessel}"},
                )
                instanz.sitzungswerte[schluessel] = str(wert.scalar_one())
    finally:
        await vorlage_engine.dispose()
    await alembic_ausfuehren(
        instanz.verbindung(EIGENTUEMER, VORLAGE_0002), "upgrade", "0002"
    )
    super_engine = engine_erzeugen(instanz.verbindung(SUPERUSER, HAUPTDATENBANK))
    try:
        async with super_engine.connect() as verbindung:
            verbindung = await verbindung.execution_options(
                isolation_level="AUTOCOMMIT"
            )
            await verbindung.execute(
                text(f"CREATE DATABASE {VORLAGE} TEMPLATE {VORLAGE_0002}")
            )
            await _rechte_der_datenbank(verbindung, VORLAGE)
    finally:
        await super_engine.dispose()
    await alembic_ausfuehren(
        instanz.verbindung(EIGENTUEMER, VORLAGE), "upgrade", "head"
    )


async def _rechte_der_datenbank(verbindung: AsyncConnection, name: str) -> None:
    """Die Zugriffsrechte einer Datenbank gehen nicht mit der Vorlage über."""
    await verbindung.execute(text(f"REVOKE ALL ON DATABASE {name} FROM PUBLIC"))
    await verbindung.execute(
        text(f"GRANT CONNECT ON DATABASE {name} TO {EIGENTUEMER}, {ANWENDUNG}")
    )


def alembic_config() -> Config:
    """Konfiguration von Alembic im Code, ohne alembic.ini (Festlegung S1.1)."""
    konfiguration = Config()
    konfiguration.set_main_option("script_location", str(MIGRATIONEN))
    # Die Revisionen liegen unter versionen (ADR 0007, Entscheid 4), nicht unter dem Vorgabenamen.
    konfiguration.set_main_option("path_separator", "os")
    konfiguration.set_main_option("version_locations", str(MIGRATIONEN / "versionen"))
    return konfiguration


async def alembic_ausfuehren(
    verbindung: Datenbankverbindung, befehl: str, ziel: str | None = None
) -> None:
    """Führt einen Befehl von Alembic als die Rolle der Verbindung aus."""
    engine: AsyncEngine = engine_erzeugen(verbindung)
    try:
        async with engine.connect() as aktiv:
            await aktiv.run_sync(_alembic_synchron, befehl, ziel)
            await aktiv.commit()
    finally:
        await engine.dispose()


def _alembic_synchron(verbindung: object, befehl: str, ziel: str | None) -> None:
    konfiguration = alembic_config()
    konfiguration.attributes["verbindung"] = verbindung
    if befehl == "check":
        command.check(konfiguration)
    elif ziel is None:
        raise ValueError("ziel fehlt")
    elif befehl == "upgrade":
        command.upgrade(konfiguration, ziel)
    elif befehl == "downgrade":
        command.downgrade(konfiguration, ziel)
    else:
        raise ValueError(f"unbekannter Befehl {befehl}")


ABRAEUMEN_FRIST_SEKUNDEN = 120
ABRAEUMEN_AUFRUF_SEKUNDEN = 30


def _docker_tolerant(*argumente: str) -> subprocess.CompletedProcess[str] | None:
    """docker im Abräumen: ein Ausbleiben oder Fehlen des Programms hält das Abräumen nicht auf."""
    try:
        return _docker("docker", *argumente, zeitgrenze=ABRAEUMEN_AUFRUF_SEKUNDEN)
    except (subprocess.TimeoutExpired, OSError):
        return None


def _aufraeumen(container: str, wurzel: Path | None) -> list[str]:
    """Räumt allein den eigenen Container und das eigene Wegwerfverzeichnis ab (GS-8).

    Jeder Schritt läuft auch dann, wenn ein früherer scheitert; Fehler werden gesammelt. Das
    Abräumen des Containers ist auf ABRAEUMEN_FRIST_SEKUNDEN begrenzt (der Schritt der Kette auf
    der Gegenseite hat eine Zeitgrenze); danach wird das Wegwerfverzeichnis trotzdem entfernt und
    der Name des Containers gemeldet, damit er von Hand entfernt werden kann.
    """
    ende = time.monotonic() + ABRAEUMEN_FRIST_SEKUNDEN
    fehler: list[str] = []
    stopp = _docker_tolerant("stop", "--time", "10", container)
    if stopp is None:
        fehler.append("docker stop: ohne Antwort")
    elif stopp.returncode != 0 and "No such container" not in stopp.stderr:
        fehler.append(f"docker stop: {stopp.stderr.strip()}")
    # Mit --rm entfernt der Daemon den Container nach dem Stopp; ein Rest wird erzwungen entfernt.
    while True:
        rest = _docker_tolerant("ps", "-aq", "--filter", f"name=^{container}$")
        if rest is not None and rest.stdout.strip() == "":
            break
        if time.monotonic() >= ende:
            fehler.append(
                f"Der Container {container} besteht noch; von Hand entfernen mit "
                f"'docker rm -f {container}' (Kennzeichnung r3cosint-test-wegwerf, GS-8)."
            )
            break
        _docker_tolerant("rm", "-f", container)
        time.sleep(0.25)
    if wurzel is not None:
        # Erst nach dem Stopp: der Server entfernt Socket und Sperrdatei selbst (Sticky-Bit,
        # Eigentümer im Container); ein anderer Benutzer als dieser könnte sie nicht löschen.
        ausfaelle: list[str] = []
        shutil.rmtree(wurzel, onexc=lambda _f, pfad, _e: ausfaelle.append(str(pfad)))
        if ausfaelle:
            fehler.append(f"Nicht entfernt: {', '.join(ausfaelle)}")
    return fehler


@pytest.fixture(scope="session")
def postgres_instanz() -> Iterator[PostgresInstanz]:
    """Wegwerf-Container mit Vorlage-Datenbank, einmal je Sitzung."""
    try:
        bild = voraussetzungen_pruefen()
    except KonfigurationsFehler as fehler:
        pytest.fail(str(fehler), pytrace=False)
    laufkennung = secrets.token_hex(8)
    container = f"r3cosint-test-{secrets.token_hex(6)}"
    passwoerter = {
        name: secrets.token_urlsafe(32) for name in (SUPERUSER, EIGENTUEMER, ANWENDUNG)
    }
    wurzel: Path | None = None
    try:
        wurzel = _wegwerfverzeichnis_anlegen()
        socket_verzeichnis = wurzel / "socket"
        geheimnisse = (
            wurzel / "geheimnis"
        )  # gelesen vom Entrypoint des Containers als root
        passwort_verzeichnis = wurzel / "passwoerter"
        socket_verzeichnis.mkdir(mode=0o700)
        # Der Entrypoint des Images läuft als root ohne DAC_OVERRIDE und fände ein 0700-Verzeichnis
        # eines anderen Benutzers (Runner ohne root) nicht lesbar; das Elternverzeichnis
        # (0700) hält den Zugriff trotzdem beim Aufrufer. Der Entrypoint setzt den Modus danach selbst.
        socket_verzeichnis.chmod(0o777)
        geheimnisse.mkdir(mode=0o755)
        passwort_verzeichnis.mkdir(mode=0o700)
        geheimnisse.chmod(0o755)
        passwort_dateien = {}
        for name, passwort in passwoerter.items():
            passwort_dateien[name] = passwort_verzeichnis / name
            _datei_schreiben(passwort_dateien[name], passwort + "\n", 0o600)
        # Ohne DAC_OVERRIDE liest root im Container nur, was für alle lesbar ist.
        _datei_schreiben(
            geheimnisse / "superuser_passwort", passwoerter[SUPERUSER], 0o644
        )
        instanz = PostgresInstanz(
            docker="docker",
            container=container,
            bild=bild,
            laufkennung=laufkennung,
            wurzel=wurzel,
            socket_verzeichnis=socket_verzeichnis,
            passwort_dateien=passwort_dateien,
            passwoerter=passwoerter,
        )
        start = _docker(
            "docker",
            "run",
            "--detach",
            "--pull=never",
            "--network",
            "none",
            "--rm",
            "--name",
            container,
            "--label",
            f"{LABEL}={laufkennung}",
            "--cap-drop",
            "ALL",
            "--cap-add",
            "CHOWN",
            "--cap-add",
            "SETGID",
            "--cap-add",
            "SETUID",
            "--security-opt",
            "no-new-privileges",
            "--pids-limit",
            "256",
            "--memory",
            "1g",
            "--tmpfs",
            "/var/lib/postgresql:rw,mode=1777",
            "--volume",
            f"{socket_verzeichnis}:/var/run/postgresql",
            "--volume",
            f"{geheimnisse}:/run/geheimnisse:ro",
            "--env",
            f"POSTGRES_USER={SUPERUSER}",
            "--env",
            f"POSTGRES_DB={HAUPTDATENBANK}",
            "--env",
            "POSTGRES_PASSWORD_FILE=/run/geheimnisse/superuser_passwort",
            "--env",
            "POSTGRES_INITDB_ARGS=--auth-local=scram-sha-256 --auth-host=scram-sha-256",
            bild,
            "-c",
            "fsync=off",
        )
        if start.returncode != 0:
            pytest.fail(
                f"Der Container startete nicht: {start.stderr.strip()} "
                "Nächster Schritt: docker info und die Rechte des Aufrufers prüfen.",
                pytrace=False,
            )
        try:
            _warten_bis_bereit(instanz)
            asyncio.run(_vorlage_aufbauen(instanz))
        except KonfigurationsFehler as fehler:
            pytest.fail(str(fehler), pytrace=False)
        yield instanz
    finally:
        reste = _aufraeumen(container, wurzel)
        if reste:
            pytest.fail("Aufräumen unvollständig: " + "; ".join(reste), pytrace=False)


@pytest.fixture
def alembic_befehl() -> Callable[
    [Datenbankverbindung, str, str | None], Awaitable[None]
]:
    """Alembic als Rolle der übergebenen Verbindung (befehl: upgrade, downgrade oder check)."""
    return alembic_ausfuehren


@dataclass(frozen=True)
class Testdatenbank:
    """Eine Datenbank dieses Tests, aus der Vorlage erzeugt."""

    instanz: PostgresInstanz
    name: str

    def verbindung(self, benutzer: str) -> Datenbankverbindung:
        """Parameter der Verbindung eines Benutzers zu dieser Datenbank."""
        return self.instanz.verbindung(benutzer, self.name)


async def _datenbank_aus_vorlage(
    instanz: PostgresInstanz, vorlage: str
) -> AsyncIterator[Testdatenbank]:
    name = f"t_{secrets.token_hex(6)}"
    engine = engine_erzeugen(instanz.verbindung(SUPERUSER, HAUPTDATENBANK))
    try:
        async with engine.connect() as verbindung:
            verbindung = await verbindung.execution_options(
                isolation_level="AUTOCOMMIT"
            )
            await verbindung.execute(text(f"CREATE DATABASE {name} TEMPLATE {vorlage}"))
            await _rechte_der_datenbank(verbindung, name)
        try:
            yield Testdatenbank(instanz=instanz, name=name)
        finally:
            async with engine.connect() as verbindung:
                verbindung = await verbindung.execution_options(
                    isolation_level="AUTOCOMMIT"
                )
                await verbindung.execute(
                    text(f"DROP DATABASE IF EXISTS {name} WITH (FORCE)")
                )
    finally:
        await engine.dispose()


@pytest.fixture
async def datenbank(postgres_instanz: PostgresInstanz) -> AsyncIterator[Testdatenbank]:
    """Je Test eine Datenbank aus der Vorlage (CREATE DATABASE ... TEMPLATE), auf dem Kopf."""
    async for datenbank in _datenbank_aus_vorlage(postgres_instanz, VORLAGE):
        yield datenbank


@pytest.fixture
async def datenbank_bei_0002(
    postgres_instanz: PostgresInstanz,
) -> AsyncIterator[Testdatenbank]:
    """Je Test eine Datenbank im Stand der Revision 0002 (für Läufe zwischen leer und 0002)."""
    async for datenbank in _datenbank_aus_vorlage(postgres_instanz, VORLAGE_0002):
        yield datenbank


async def _verbindung(
    datenbank: Testdatenbank, benutzer: str
) -> AsyncIterator[AsyncConnection]:
    engine = engine_erzeugen(datenbank.verbindung(benutzer))
    try:
        async with engine.connect() as verbindung:
            yield verbindung
    finally:
        await engine.dispose()


@pytest.fixture
async def verbindung_eigentuemer(
    datenbank: Testdatenbank,
) -> AsyncIterator[AsyncConnection]:
    """Verbindung der Rolle r3cosint_eigentuemer zur Datenbank dieses Tests."""
    async for verbindung in _verbindung(datenbank, EIGENTUEMER):
        yield verbindung


@pytest.fixture
async def verbindung_anwendung(
    datenbank: Testdatenbank,
) -> AsyncIterator[AsyncConnection]:
    """Verbindung der Rolle r3cosint_anwendung zur Datenbank dieses Tests."""
    async for verbindung in _verbindung(datenbank, ANWENDUNG):
        yield verbindung


@dataclass(frozen=True)
class FesteUhr:
    """Uhr mit festem Zeitpunkt (R3-F-008); jetzt() liefert stets denselben Wert."""

    zeitpunkt: datetime = datetime(2026, 1, 15, 8, 30, 0, 123456, tzinfo=UTC)

    def jetzt(self) -> datetime:
        """Liefert den festen Zeitpunkt, zeitbewusst, in UTC."""
        return self.zeitpunkt


@dataclass
class VerstellbareUhr:
    """Uhr mit einstellbarem Zeitpunkt (R3-F-001): Eröffnen und Schliessen laufen zu zwei Zeiten.

    Im Unterschied zu FesteUhr ist das Feld veränderbar; jetzt() liefert den eingestellten Wert.
    """

    zeitpunkt: datetime = datetime(2026, 1, 15, 8, 30, 0, 123456, tzinfo=UTC)

    def jetzt(self) -> datetime:
        """Liefert den eingestellten Zeitpunkt, zeitbewusst, in UTC."""
        return self.zeitpunkt


@dataclass(frozen=True)
class SynthetischerFall:
    """Ein synthetischer Fall mit angelegten Ketten (S1.2; 5.15: alle Werte erfunden).

    kennung: Kennung des Falls in der Tabelle fall.
    schluessel: die 32 Zufallsbytes aus fall_schluessel.
    pseudonymisierer: aus dem Schlüssel gebaut.
    uhr: feste Uhr, mit der die Fixtures Einträge anfügen.
    """

    kennung: UUID
    schluessel: bytes = field(repr=False)
    pseudonymisierer: Pseudonymisierer
    uhr: FesteUhr


@asynccontextmanager
async def _superuser(datenbank: Testdatenbank) -> AsyncIterator[AsyncConnection]:
    """Verbindung des Superusers zur Datenbank des Tests; allein für manipulieren (SD-S12-07)."""
    engine = engine_erzeugen(datenbank.verbindung(SUPERUSER))
    try:
        async with engine.connect() as verbindung:
            yield verbindung
    finally:
        await engine.dispose()


@pytest.fixture
def fall_anlegen(
    datenbank: Testdatenbank,
) -> Callable[[], Awaitable[SynthetischerFall]]:
    """Hilfe: legt in der Datenbank dieses Tests einen weiteren synthetischen Fall samt Ketten an."""

    async def anlegen() -> SynthetischerFall:
        uhr = FesteUhr()
        kennung = neue_kennung()
        schluessel = secrets.token_bytes(32)
        async for eigentuemer in _verbindung(datenbank, EIGENTUEMER):
            await eigentuemer.execute(
                text(
                    "INSERT INTO r3cosint.fall (kennung, aktenzeichen, ermittelnde_person, "
                    "rechtsgrundlage, rechtsregime, fallkategorie, zustand, eroeffnet_am) "
                    "VALUES (:kennung, :aktenzeichen, 'test.ermittlung', "
                    "'synthetisch, ohne Rechtsgrundlage', 'R1', 'vergehen', 'aktiv', :eroeffnet)"
                ),
                {
                    "kennung": kennung,
                    "aktenzeichen": f"TEST-SYNTH-{secrets.token_hex(6)}",
                    "eroeffnet": uhr.zeitpunkt,
                },
            )
            await eigentuemer.execute(
                text(
                    "INSERT INTO r3cosint.fall_schluessel (fall_kennung, schluessel) "
                    "VALUES (:kennung, :schluessel)"
                ),
                {"kennung": kennung, "schluessel": schluessel},
            )
            await eigentuemer.commit()
        async for anwendung in _verbindung(datenbank, ANWENDUNG):
            async with anwendung.begin():
                await ketten_anlegen(anwendung, kennung)
        return SynthetischerFall(
            kennung=kennung,
            schluessel=schluessel,
            pseudonymisierer=Pseudonymisierer(schluessel),
            uhr=uhr,
        )

    return anlegen


@pytest.fixture
async def fall_mit_ketten(
    fall_anlegen: Callable[[], Awaitable[SynthetischerFall]],
) -> SynthetischerFall:
    """Legt einen synthetischen Fall samt beider Ketten in der Datenbank dieses Tests an.

    Schreibt als Eigentümer unmittelbar in fall (Kennung neu, aktenzeichen "TEST-SYNTH-" mit
    Zufallsteil, ermittelnde_person "test.ermittlung", rechtsgrundlage "synthetisch, ohne
    Rechtsgrundlage", rechtsregime R1, fallkategorie vergehen, zustand aktiv, eroeffnet_am aus der
    festen Uhr) und 32 Zufallsbytes (secrets.token_bytes) in fall_schluessel; committet; ruft dann
    als Anwendung spur.service.ketten_anlegen in einer Transaktion auf.
    """
    return await fall_anlegen()


@dataclass(frozen=True)
class EroeffneterFall:
    """Ein über fall.service eröffneter synthetischer Fall (S1.3; 5.15: alle Werte erfunden).

    fall: der Fall im Zustand aktiv, wie eroeffnen ihn lieferte.
    eroeffnung: die Eingabe, mit der er eröffnet wurde.
    pseudonymisierer: über pseudonymisierer_laden gebildet; es gibt kein Feld für den Schlüssel.
    uhr: verstellbare Uhr, auf den Zeitpunkt der Eröffnung gestellt.
    """

    fall: Fall
    eroeffnung: Eroeffnung
    pseudonymisierer: Pseudonymisierer
    uhr: VerstellbareUhr


@pytest.fixture
def faelle_eroeffnen(
    datenbank: Testdatenbank,
) -> Callable[[int], Awaitable[list[EroeffneterFall]]]:
    """Hilfe: eröffnet n synthetische Fälle als Anwendung über fall.service.eroeffnen.

    Aufruf: await faelle_eroeffnen(n). Je Fall eine Transaktion mit commit; Aktenzeichen
    "TEST-SYNTH-" mit Zufallsteil, Rechtsregime R1, Fallkategorie vergehen, person_kennung
    "test.ermittlung" (die handelnde Person), ermittelnde_person "test.fallfuehrung" (verschieden,
    damit eine Klartextsuche in den Spuren beide trennt). Das ist der Weg der Anwendung; fall_anlegen schreibt
    dagegen als Eigentümer unmittelbar und legt allein die Ketten an (Weg der Tests).
    """

    async def eroeffnen_n(anzahl: int) -> list[EroeffneterFall]:
        faelle: list[EroeffneterFall] = []
        async for anwendung in _verbindung(datenbank, ANWENDUNG):
            for _ in range(anzahl):
                uhr = VerstellbareUhr()
                eroeffnung = Eroeffnung(
                    aktenzeichen=f"TEST-SYNTH-{secrets.token_hex(6)}",
                    rechtsgrundlage="synthetisch, ohne Rechtsgrundlage",
                    rechtsregime=Rechtsregime.R1,
                    fallkategorie="vergehen",
                    ermittelnde_person="test.fallfuehrung",
                )
                async with anwendung.begin():
                    fall = await eroeffnen(
                        anwendung,
                        eroeffnung=eroeffnung,
                        person_kennung="test.ermittlung",
                        uhr=uhr,
                    )
                async with anwendung.begin():
                    pseudonymisierer = await pseudonymisierer_laden(
                        anwendung, fall.kennung
                    )
                faelle.append(
                    EroeffneterFall(
                        fall=fall,
                        eroeffnung=eroeffnung,
                        pseudonymisierer=pseudonymisierer,
                        uhr=uhr,
                    )
                )
        return faelle

    return eroeffnen_n


@pytest.fixture
async def eroeffneter_fall(
    faelle_eroeffnen: Callable[[int], Awaitable[list[EroeffneterFall]]],
) -> EroeffneterFall:
    """Eröffnet je Test einen synthetischen Fall über fall.service.eroeffnen (Weg der Anwendung)."""
    return (await faelle_eroeffnen(1))[0]


@pytest.fixture
def fallschluessel_lesen(
    datenbank: Testdatenbank,
) -> Callable[[UUID], Awaitable[bytes]]:
    """Hilfe: liest den Fallschlüssel als Eigentümer (Zugang der Tests, nicht öffentlich).

    Allein für Tests, die den Schlüssel selbst brauchen (zwei Fälle, zwei Schlüssel; Suche nach
    dem Hex des Schlüssels in Fehlertexten und Spuren). Er steht in keinem Feld eines Fixtures.
    """

    async def lesen(fall_kennung: UUID) -> bytes:
        schluessel: bytes | None = None
        async for eigentuemer in _verbindung(datenbank, EIGENTUEMER):
            ergebnis = await eigentuemer.execute(
                text(
                    "SELECT schluessel FROM r3cosint.fall_schluessel "
                    "WHERE fall_kennung = :kennung"
                ),
                {"kennung": fall_kennung},
            )
            schluessel = bytes(ergebnis.scalar_one())
        assert schluessel is not None
        return schluessel

    return lesen


@pytest.fixture
def eintraege_schreiben(
    datenbank: Testdatenbank,
) -> Callable[[SynthetischerFall, Spur, int], Awaitable[list[Eintrag]]]:
    """Hilfe: schreibt als Anwendung n Einträge einer Spur über spur.service.anfuegen.

    Aufruf: await eintraege_schreiben(fall, spur, n). Je Aufruf eine Transaktion mit commit.
    In der Arbeitsspur FallEroeffnet, in der Ermittlungsspur Entitaet mit erfundenen Werten
    (5.15); Kennzeichnung quellenaussage; Rückgabe die angefügten Einträge in Reihenfolge.
    """

    async def schreiben(
        fall: SynthetischerFall, spur: Spur, anzahl: int
    ) -> list[Eintrag]:
        eintraege: list[Eintrag] = []
        async for anwendung in _verbindung(datenbank, ANWENDUNG):
            async with anwendung.begin():
                for nr in range(anzahl):
                    eingabe: Eingabe
                    if spur is Spur.ARBEITSSPUR:
                        eingabe = FallEroeffnet(
                            fall_kennung=fall.kennung,
                            rechtsregime="R1",
                            fallkategorie="vergehen",
                            aktenzeichen=f"TEST-SYNTH-{nr}",
                            rechtsgrundlage="synthetisch, ohne Rechtsgrundlage",
                            ermittelnde_person="test.ermittlung",
                            eroeffnet_am=fall.uhr.zeitpunkt,
                        )
                    else:
                        eingabe = Entitaet(
                            fall_kennung=fall.kennung,
                            entitaet_kennung=neue_kennung(),
                            ftm_kennung=f"synth-{nr}",
                            ftm_schema="Person",
                            herkunft_kennung=neue_kennung(),
                            eigenschaften={"name": (f"Erfundene Person {nr}",)},
                            werkzeug="synth.werkzeug",
                            erhoben_am=fall.uhr.zeitpunkt,
                            erhebende_person="synth.erhebung",
                            abfrage="TEST-SYNTH Abfrage",
                        )
                    eintraege.append(
                        await anfuegen(
                            anwendung,
                            spur=spur,
                            fall_kennung=fall.kennung,
                            person_kennung="test.ermittlung",
                            kennzeichnung=Kennzeichnung.QUELLENAUSSAGE,
                            eingabe=eingabe,
                            pseudonymisierer=fall.pseudonymisierer,
                            uhr=fall.uhr,
                        )
                    )
        return eintraege

    return schreiben


_ANWEISUNG = re.compile(
    r"^\s*(insert\s+into|update|delete\s+from)\s+r3cosint\."
    r"(ermittlungsspur|arbeitsspur|kettenkopf|herkunft|entitaet|beziehung)\b",
    re.IGNORECASE,
)
_MANIPULIERTE_TABELLEN = (
    "ermittlungsspur",
    "arbeitsspur",
    "kettenkopf",
    "herkunft",
    "entitaet",
    "beziehung",
)


@pytest.fixture
def manipulieren(
    datenbank: Testdatenbank,
) -> Callable[..., Awaitable[str]]:
    """Hilfe: manipuliert den Bestand als Superuser, einziger Weg eines Tests dorthin (SD-S12-07).

    Aufruf: await manipulieren(sql, bedingungen_entfernen=("name", ...)). Öffnet eine Transaktion,
    setzt allein SET LOCAL session_replication_role = replica (wirkt in
    dieser Transaktion, danach origin; GS-2) und führt den Text aus. Angenommen werden allein
    INSERT, UPDATE und DELETE auf r3cosint.ermittlungsspur, r3cosint.arbeitsspur,
    r3cosint.kettenkopf, r3cosint.herkunft, r3cosint.entitaet und r3cosint.beziehung, geprüft am
    Anfang jeder Anweisung; anderes weist die Hilfe vor jeder
    Ausführung mit ValueError ab. Benannte Prüf- oder UNIQUE-Bedingungen dieser sechs Tabellen
    werden (nach Abgleich der Namen mit dem Katalog) in der Datenbank des Tests entfernt.
    Rückgabe: der Wert von SHOW session_replication_role, den dieselbe Verbindung nach dem
    Ende der Transaktion in einer neuen Transaktion liest (erwartet: origin).
    """

    async def ausfuehren(sql: str, *, bedingungen_entfernen: Sequence[str] = ()) -> str:
        anweisungen = [teil for teil in sql.split(";") if teil.strip()]
        for anweisung in anweisungen:
            if _ANWEISUNG.match(anweisung) is None:
                raise ValueError(
                    "manipulieren nimmt allein INSERT, UPDATE und DELETE auf die Spuren, "
                    "den Kettenkopf und den Bestand an"
                )
        async with _superuser(datenbank) as verbindung:
            async with verbindung.begin():
                await verbindung.execute(
                    text("SET LOCAL session_replication_role = replica")
                )
                if bedingungen_entfernen:
                    zeilen = await verbindung.execute(
                        text(
                            "SELECT c.conname, cl.relname FROM pg_constraint c "
                            "JOIN pg_class cl ON cl.oid = c.conrelid "
                            "JOIN pg_namespace n ON n.oid = cl.relnamespace "
                            "WHERE n.nspname = 'r3cosint' AND cl.relname = ANY(:tabellen) "
                            "AND c.contype IN ('c', 'u')"
                        ),
                        {"tabellen": list(_MANIPULIERTE_TABELLEN)},
                    )
                    vorhanden = {name: tabelle for name, tabelle in zeilen}
                    for name in bedingungen_entfernen:
                        if name not in vorhanden:
                            raise ValueError("Bedingung unbekannt")
                        await verbindung.execute(
                            text(
                                f'ALTER TABLE r3cosint."{vorhanden[name]}" '
                                f'DROP CONSTRAINT "{name}"'
                            )
                        )
                for anweisung in anweisungen:
                    await verbindung.execute(text(anweisung))
            async with verbindung.begin():
                danach = await verbindung.execute(text("SHOW session_replication_role"))
                return str(danach.scalar_one())

    return ausfuehren


@pytest.fixture
def replikationsparameter() -> str:
    """Name des Parameters, den allein manipulieren setzt; für die Tests, die seine Sperre prüfen."""
    return "session_replication_role"


# ---- Hilfen für ausgang (S2.1; Zeilen Testgegenstelle und Fixtures der Festlegung) ---------------

GEGENSTELLE_MODUL = "r3cosint_gegenstelle"
GEGENSTELLE_DATEI = Path(__file__).resolve().parent / "gegenstelle.py"


def gegenstelle_laden() -> ModuleType:
    """Lädt tests/gegenstelle.py über den Dateipfad unter dem festen Modulnamen.

    Eine schon geladene Instanz wird wiederverwendet, damit conftest und Tests ein Modul teilen.
    """
    vorhanden = sys.modules.get(GEGENSTELLE_MODUL)
    if vorhanden is not None:
        return vorhanden
    spec = importlib.util.spec_from_file_location(GEGENSTELLE_MODUL, GEGENSTELLE_DATEI)
    assert spec is not None and spec.loader is not None
    modul = importlib.util.module_from_spec(spec)
    sys.modules[GEGENSTELLE_MODUL] = modul
    spec.loader.exec_module(modul)
    return modul


@pytest.fixture
async def gegenstelle() -> AsyncIterator[object]:
    """Eine laufende Gegenstelle je Test (Antwort treffer(1)); nach dem Test beendet."""
    modul = gegenstelle_laden()
    instanz = await modul.Gegenstelle.starten(modul.Antwortskript.treffer(1))
    try:
        yield instanz
    finally:
        await instanz.beenden()


@pytest.fixture
async def gegenstelle_ausserhalb() -> AsyncIterator[object]:
    """Zweite Gegenstelle, deren Ziel in keiner Testliste steht (W2-37)."""
    modul = gegenstelle_laden()
    instanz = await modul.Gegenstelle.starten(modul.Antwortskript.treffer(1))
    try:
        yield instanz
    finally:
        await instanz.beenden()


@pytest.fixture
def testpositivliste(
    tmp_path: Path,
) -> Callable[..., Positivliste]:
    """Fabrik: schreibt positivliste.toml unter tmp_path und lädt sie über laden (Umgebung test)."""
    zaehler = [0]

    def bauen(
        eintraege: Sequence[Mapping[str, object]],
        *,
        hoechstzahl: int = 3,
        stillgelegt: Sequence[str] = (),
    ) -> Positivliste:
        zaehler[0] += 1
        stillgelegt_text = ", ".join(f'"{name}"' for name in stillgelegt)
        zeilen = [
            "format = 1",
            'umgebung = "test"',
            f"ausgang_weiterleitungen_hoechstzahl = {hoechstzahl}",
            f"stillgelegt = [{stillgelegt_text}]",
        ]
        for eintrag in eintraege:
            zeilen += ["", "[[eintrag]]"]
            for schluessel, wert in eintrag.items():
                text_wert = f'"{wert}"' if isinstance(wert, str) else str(wert)
                zeilen.append(f"{schluessel} = {text_wert}")
        pfad = tmp_path / f"positivliste-{zaehler[0]}.toml"
        pfad.write_bytes(("\n".join(zeilen) + "\n").encode("utf-8"))
        return laden(pfad, umgebung="test")

    return bauen


class SteuerbarerAufloeser:
    """Auflöser der Tests: Antwort je Name und Aufruf, Zähler je Name, wählbare Verzögerung."""

    def __init__(self) -> None:
        self.zaehler: dict[str, int] = {}
        self._antworten: dict[str, tuple[object, ...]] = {}
        self._position: dict[str, int] = {}
        self.verzoegerung: float = 0.0

    def setzen(self, name: str, *antworten: object) -> None:
        """Je Antwort ein Tupel von Adressen oder eine Ausnahmeklasse.

        Die n-te Antwort gilt für den n-ten Aufruf nach setzen, die letzte wiederholt sich; der
        Zähler je Name läuft über setzen hinweg weiter."""
        self._antworten[name] = antworten
        self._position[name] = 0

    async def aufloesen(self, name: str) -> tuple[Adresse, ...]:
        """Zählt den Aufruf und liefert die n-te Antwort des Namens."""
        aufrufe = self.zaehler.get(name, 0) + 1
        self.zaehler[name] = aufrufe
        if self.verzoegerung > 0:
            await asyncio.sleep(self.verzoegerung)
        antworten = self._antworten.get(name)
        if not antworten:
            raise AufloesungsFehler
        position = self._position[name] + 1
        self._position[name] = position
        antwort = antworten[min(position, len(antworten)) - 1]
        if isinstance(antwort, type) and issubclass(antwort, BaseException):
            raise antwort()
        assert isinstance(antwort, tuple)
        return antwort


@pytest.fixture
def aufloeser_steuerbar() -> SteuerbarerAufloeser:
    """Steuerbarer Auflöser (setzen, zaehler)."""
    return SteuerbarerAufloeser()


@dataclass(frozen=True)
class Aufruf:
    """Eine Aufzeichnung des Verbindungswegs-Ersatzes."""

    name_oder_adresse: str
    adresse: Adresse
    anschluss: int


class VerbindungswegErsatz:
    """Verbindungsweg der Tests: zeichnet auf und bildet jede Adresse auf 127.0.0.1 ab."""

    def __init__(self) -> None:
        self.aufrufe: list[Aufruf] = []

    def transport(
        self,
        *,
        name_oder_adresse: str,
        adresse: Adresse,
        anschluss: int,
        ssl_kontext: ssl.SSLContext,
    ) -> object:
        """Zeichnet auf; der Transport verbindet über den gebundenen Weg mit 127.0.0.1."""
        self.aufrufe.append(Aufruf(name_oder_adresse, adresse, anschluss))
        return GebundenerVerbindungsweg().transport(
            name_oder_adresse=name_oder_adresse,
            adresse=ipaddress.IPv4Address("127.0.0.1"),
            anschluss=anschluss,
            ssl_kontext=ssl_kontext,
        )


@pytest.fixture
def verbindungsweg_ersatz() -> VerbindungswegErsatz:
    """Verbindungsweg-Ersatz (aufrufe)."""
    return VerbindungswegErsatz()


@dataclass
class Netzwaechter:
    """Zähler der Netzzugriffe mit einem Namen oder einer anderen Adresse als 127.0.0.1."""

    zaehler: int = 0
    aufrufe: list[str] = field(default_factory=list)

    def beachten(self, ort: object) -> None:
        """Zählt den Zugriff und beendet ihn mit einer Ausnahme."""
        self.zaehler += 1
        self.aufrufe.append(type(ort).__name__)
        raise OSError("Der Netzwächter lässt nur 127.0.0.1 durch.")


def _ort_zulaessig(ort: object) -> bool:
    if ort is None:
        return True
    if isinstance(ort, bytes):
        ort = ort.decode("latin-1")
    return isinstance(ort, str) and ort == "127.0.0.1"


@pytest.fixture
async def netzwaechter(monkeypatch: pytest.MonkeyPatch) -> AsyncIterator[Netzwaechter]:
    """Ersetzt die Wege der Namensauflösung und des Verbindens durch zählende Hüllen.

    Durchgereicht werden allein die numerische Adresse 127.0.0.1 und Unix-Socket-Pfade; jeder andere
    Aufruf wird gezählt und scheitert. Am Testende ist der Zähler 0 (Zusicherung der Fixture).
    """
    wache = Netzwaechter()
    schleife = asyncio.get_running_loop()
    gai = socket.getaddrinfo
    ghbn = socket.gethostbyname
    cc = socket.create_connection
    verbinden = socket.socket.connect
    verbinden_ex = socket.socket.connect_ex
    lgai = schleife.getaddrinfo
    lcc = schleife.create_connection

    def huelle_gai(host: object, *args: object, **kwargs: object) -> object:
        if not _ort_zulaessig(host):
            wache.beachten(host)
        return gai(host, *args, **kwargs)  # type: ignore[arg-type]

    def huelle_ghbn(host: str) -> str:
        if not _ort_zulaessig(host):
            wache.beachten(host)
        return ghbn(host)

    def huelle_cc(adresse: tuple[str, int], *args: object, **kwargs: object) -> object:
        if not _ort_zulaessig(adresse[0]):
            wache.beachten(adresse[0])
        return cc(adresse, *args, **kwargs)  # type: ignore[arg-type]

    def huelle_verbinden(self: socket.socket, adresse: object) -> None:
        if isinstance(adresse, tuple) and not _ort_zulaessig(adresse[0]):
            wache.beachten(adresse[0])
        verbinden(self, adresse)  # type: ignore[arg-type]

    def huelle_verbinden_ex(self: socket.socket, adresse: object) -> int:
        if isinstance(adresse, tuple) and not _ort_zulaessig(adresse[0]):
            wache.beachten(adresse[0])
        return verbinden_ex(self, adresse)  # type: ignore[arg-type]

    async def huelle_lgai(host: object, *args: object, **kwargs: object) -> object:
        if not _ort_zulaessig(host):
            wache.beachten(host)
        return await lgai(host, *args, **kwargs)  # type: ignore[arg-type]

    async def huelle_lcc(*args: object, **kwargs: object) -> object:
        host = args[1] if len(args) > 1 else kwargs.get("host")
        if not _ort_zulaessig(host):
            wache.beachten(host)
        return await lcc(*args, **kwargs)  # type: ignore[call-overload]

    monkeypatch.setattr(socket, "getaddrinfo", huelle_gai)
    monkeypatch.setattr(socket, "gethostbyname", huelle_ghbn)
    monkeypatch.setattr(socket, "create_connection", huelle_cc)
    monkeypatch.setattr(socket.socket, "connect", huelle_verbinden)
    monkeypatch.setattr(socket.socket, "connect_ex", huelle_verbinden_ex)
    monkeypatch.setattr(schleife, "getaddrinfo", huelle_lgai)
    monkeypatch.setattr(schleife, "create_connection", huelle_lcc)
    yield wache
    monkeypatch.undo()
    assert wache.zaehler == 0, (
        f"Netzwächter: {wache.zaehler} Zugriffe ausserhalb 127.0.0.1"
    )


class SpurkontextAttrappe:
    """Spurkontext der Einheitsstufe: sammelt die Eingaben, kann beim n-ten Eintrag scheitern."""

    def __init__(self) -> None:
        self.fall_kennung: UUID = neue_kennung()
        self.werkzeug = "pruef.werkzeug"
        self.person_kennung = "test.ermittlung"
        self.uhr = FesteUhr()
        self.fall_besteht = True
        self.eingaben: list[Verbindungsversuch] = []
        self.fehler_bei: int | None = None
        self.fall_pruefungen = 0

    async def fall_pruefen(self) -> None:
        """Zählt die Prüfung; ohne Fall EingabeFehler."""
        self.fall_pruefungen += 1
        if not self.fall_besteht:
            from r3cosint.core.fehler import EingabeFehler

            raise EingabeFehler("Der Fall besteht nicht.")

    async def eintragen(self, eingabe: Verbindungsversuch) -> None:
        """Sammelt die Eingabe; beim n-ten Aufruf (fehler_bei, ab 1) eine Ausnahme."""
        if self.fehler_bei is not None and len(self.eingaben) + 1 == self.fehler_bei:
            raise RuntimeError("Eintrag nicht geschrieben (Attrappe)")
        self.eingaben.append(eingabe)


@pytest.fixture
def spurkontext_attrappe() -> SpurkontextAttrappe:
    """Spurkontext ohne Datenbank (Einheitsstufe)."""
    return SpurkontextAttrappe()


@pytest.fixture
async def spurkontext(
    eroeffneter_fall: EroeffneterFall, verbindung_anwendung: AsyncConnection
) -> AsyncIterator[SpurkontextDatenbank]:
    """SpurkontextDatenbank aus dem eröffneten Fall, mit einer Verbindung in offener Transaktion."""
    await verbindung_anwendung.begin()
    yield SpurkontextDatenbank(
        verbindung=verbindung_anwendung,
        fall_kennung=eroeffneter_fall.fall.kennung,
        werkzeug="pruef.werkzeug",
        person_kennung="test.ermittlung",
        pseudonymisierer=eroeffneter_fall.pseudonymisierer,
        uhr=FesteUhr(),
    )
    if verbindung_anwendung.in_transaction():
        await verbindung_anwendung.rollback()


@pytest.fixture
async def schein_proxy(monkeypatch: pytest.MonkeyPatch) -> AsyncIterator[object]:
    """Gegenstelle als Proxy: setzt HTTP_PROXY, HTTPS_PROXY und ALL_PROXY; null Verbindungen."""
    modul = gegenstelle_laden()
    instanz = await modul.Gegenstelle.starten(modul.Antwortskript.treffer(1))
    adresse = f"http://127.0.0.1:{instanz.anschluss}"
    for name in ("HTTP_PROXY", "HTTPS_PROXY", "ALL_PROXY"):
        monkeypatch.setenv(name, adresse)
        monkeypatch.setenv(name.lower(), adresse)
    try:
        yield instanz
        assert instanz.verbindungen == 0, "der Schein-Proxy sah eine Verbindung"
    finally:
        await instanz.beenden()


@dataclass(frozen=True)
class TlsZertifikat:
    """Zur Laufzeit erzeugte Zertifikate für zwei Testnamen (nie versioniert).

    name, anderer_name: die Testnamen unter .test.
    server_kontext, server_kontext_anderer: Serverkontexte mit je einem Zertifikat.
    client_kontext: einziger Anker ist das erste Zertifikat.
    client_kontext_beide: beide Zertifikate als Anker (trennt allein die Namensprüfung).
    """

    name: str
    anderer_name: str
    server_kontext: ssl.SSLContext
    server_kontext_anderer: ssl.SSLContext
    client_kontext: ssl.SSLContext
    client_kontext_beide: ssl.SSLContext


def _zertifikat_erzeugen(verzeichnis: Path, name: str) -> tuple[Path, Path]:
    """Selbst signiertes EC-Zertifikat P-256 für name (CN und subjectAltName), Rechte 0600."""
    schluessel = verzeichnis / f"{name}.key"
    zertifikat = verzeichnis / f"{name}.pem"
    subprocess.run(
        [
            "openssl",
            "req",
            "-x509",
            "-newkey",
            "ec",
            "-pkeyopt",
            "ec_paramgen_curve:prime256v1",
            "-nodes",
            "-days",
            "1",
            "-subj",
            f"/CN={name}",
            "-addext",
            f"subjectAltName=DNS:{name}",
            "-keyout",
            str(schluessel),
            "-out",
            str(zertifikat),
        ],
        check=True,
        capture_output=True,
        timeout=60,
    )
    schluessel.chmod(0o600)
    zertifikat.chmod(0o600)
    return zertifikat, schluessel


def _client_kontext(*anker: Path) -> ssl.SSLContext:
    kontext = ssl.SSLContext(ssl.PROTOCOL_TLS_CLIENT)
    kontext.minimum_version = ssl.TLSVersion.TLSv1_2
    kontext.verify_mode = ssl.CERT_REQUIRED
    kontext.check_hostname = True
    for pfad in anker:
        kontext.load_verify_locations(cafile=str(pfad))
    return kontext


def _server_kontext(zertifikat: Path, schluessel: Path) -> ssl.SSLContext:
    kontext = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
    kontext.load_cert_chain(str(zertifikat), str(schluessel))
    return kontext


@pytest.fixture
def tls_zertifikat(tmp_path: Path) -> TlsZertifikat:
    """Zwei Zertifikate zur Laufzeit mit openssl (fehlt openssl, scheitert der Test)."""
    name = "tls-eins.beispiel.test"
    anderer = "tls-zwei.beispiel.test"
    z1, k1 = _zertifikat_erzeugen(tmp_path, name)
    z2, k2 = _zertifikat_erzeugen(tmp_path, anderer)
    return TlsZertifikat(
        name=name,
        anderer_name=anderer,
        server_kontext=_server_kontext(z1, k1),
        server_kontext_anderer=_server_kontext(z2, k2),
        client_kontext=_client_kontext(z1),
        client_kontext_beide=_client_kontext(z1, z2),
    )
