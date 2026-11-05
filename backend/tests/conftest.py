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
import os
import re
import secrets
import shutil
import subprocess
import tempfile
import time
from collections.abc import AsyncIterator, Awaitable, Callable, Iterator
from dataclasses import dataclass, field
from pathlib import Path

import pytest
from alembic import command
from alembic.config import Config
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncConnection, AsyncEngine

from r3cosint.core.datenbank import engine_erzeugen
from r3cosint.core.fehler import KonfigurationsFehler
from r3cosint.core.konfiguration import Datenbankverbindung

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
    """Datenbank vorlage: Grundeinrichtung als Superuser, dann 0001 bis Kopf als Eigentümer."""
    super_engine = engine_erzeugen(instanz.verbindung(SUPERUSER, HAUPTDATENBANK))
    try:
        async with super_engine.connect() as verbindung:
            verbindung = await verbindung.execution_options(
                isolation_level="AUTOCOMMIT"
            )
            await verbindung.execute(text(f"CREATE DATABASE {VORLAGE}"))
    finally:
        await super_engine.dispose()
    vorlage_engine = engine_erzeugen(instanz.verbindung(SUPERUSER, VORLAGE))
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
        instanz.verbindung(EIGENTUEMER, VORLAGE), "upgrade", "head"
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


@pytest.fixture
async def datenbank(postgres_instanz: PostgresInstanz) -> AsyncIterator[Testdatenbank]:
    """Je Test eine Datenbank aus der Vorlage (CREATE DATABASE ... TEMPLATE)."""
    name = f"t_{secrets.token_hex(6)}"
    engine = engine_erzeugen(postgres_instanz.verbindung(SUPERUSER, HAUPTDATENBANK))
    try:
        async with engine.connect() as verbindung:
            verbindung = await verbindung.execution_options(
                isolation_level="AUTOCOMMIT"
            )
            await verbindung.execute(text(f"CREATE DATABASE {name} TEMPLATE {VORLAGE}"))
            # Die Zugriffsrechte der Datenbank gehen nicht mit der Vorlage über.
            await verbindung.execute(text(f"REVOKE ALL ON DATABASE {name} FROM PUBLIC"))
            await verbindung.execute(
                text(f"GRANT CONNECT ON DATABASE {name} TO {EIGENTUEMER}, {ANWENDUNG}")
            )
        try:
            yield Testdatenbank(instanz=postgres_instanz, name=name)
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
