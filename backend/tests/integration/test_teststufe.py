"""Integrationstest: die Teststufe selbst (ADR 0007, Abschnitt "Teststufen"; R3-F-008).

Geprüft werden der Container (Netz, Port, Fähigkeiten, Kennzeichnung), die Anmeldung auf dem
Socket, die Wirkungslosigkeit der PG*-Umgebung (Befund B-1), kein Passwort in einer Meldung
und die Meldungen bei fehlendem docker, Daemon oder Image. Ein fehlender Daemon wird durch
ein Ersatzprogramm für docker nachgestellt, nicht durch Anhalten des Daemons.
"""

import json
import stat
import subprocess
from collections.abc import Callable
from pathlib import Path
from typing import TYPE_CHECKING, Any

import pytest
from sqlalchemy import text
from sqlalchemy.exc import DBAPIError
from sqlalchemy.ext.asyncio import AsyncConnection

from r3cosint.core.datenbank import engine_erzeugen
from r3cosint.core.fehler import KonfigurationsFehler

if TYPE_CHECKING:
    from conftest import PostgresInstanz, Testdatenbank

LABEL = "r3cosint-test-wegwerf"


DockerAufruf = Callable[..., subprocess.CompletedProcess[str]]


def _inspect(docker_aufruf: DockerAufruf, instanz: "PostgresInstanz") -> dict[str, Any]:
    ergebnis = docker_aufruf("inspect", instanz.container)
    assert ergebnis.returncode == 0, ergebnis.stderr
    inhalt = json.loads(ergebnis.stdout)
    assert len(inhalt) == 1
    assert isinstance(inhalt[0], dict)
    return inhalt[0]


def test_R3_F_008_der_container_hat_kein_netz_keinen_port_und_nur_drei_faehigkeiten(
    postgres_instanz: "PostgresInstanz", docker_aufruf: DockerAufruf
) -> None:
    daten = _inspect(docker_aufruf, postgres_instanz)
    host = daten["HostConfig"]
    assert host["NetworkMode"] == "none"
    assert not host["PortBindings"]
    assert [f.removeprefix("CAP_") for f in host["CapDrop"]] == ["ALL"]
    # Der Daemon gibt die Namen je nach Fassung mit oder ohne das Präfix CAP_ aus.
    assert sorted(f.removeprefix("CAP_") for f in host["CapAdd"]) == [
        "CHOWN",
        "SETGID",
        "SETUID",
    ]
    assert host["Privileged"] is False
    assert host["AutoRemove"] is True
    assert "no-new-privileges" in " ".join(host["SecurityOpt"])
    assert host["PidsLimit"] > 0
    assert host["Memory"] > 0


def test_R3_F_008_der_container_traegt_die_kennzeichnung_und_das_image_ueber_den_digest(
    postgres_instanz: "PostgresInstanz", docker_aufruf: DockerAufruf
) -> None:
    daten = _inspect(docker_aufruf, postgres_instanz)
    assert daten["Config"]["Labels"][LABEL] == postgres_instanz.laufkennung
    assert daten["Config"]["Image"] == postgres_instanz.bild
    assert "@sha256:" in postgres_instanz.bild


def test_R3_F_008_der_container_bindet_allein_socket_und_geheimnisverzeichnis(
    postgres_instanz: "PostgresInstanz", docker_aufruf: DockerAufruf
) -> None:
    daten = _inspect(docker_aufruf, postgres_instanz)
    ziele = sorted(m["Destination"] for m in daten["Mounts"] if m["Type"] == "bind")
    assert ziele == ["/run/geheimnisse", "/var/run/postgresql"]
    geheimnis = next(
        m for m in daten["Mounts"] if m["Destination"] == "/run/geheimnisse"
    )
    assert geheimnis["RW"] is False
    tmpfs = daten["HostConfig"]["Tmpfs"]
    assert "/var/lib/postgresql" in tmpfs


def test_R3_F_008_keine_darstellung_der_instanz_zeigt_ein_passwort_oder_einen_sitzungswert(
    postgres_instanz: "PostgresInstanz",
) -> None:
    darstellungen = [repr(postgres_instanz), str(postgres_instanz)]
    geheimnisse = [
        *postgres_instanz.passwoerter.values(),
        *postgres_instanz.sitzungswerte.values(),
    ]
    for geheimnis in geheimnisse:
        if geheimnis == "":
            continue  # ein leerer Sitzungswert steckt in jedem Text
        # Der Wahrheitswert entsteht vorab: pytest gibt bei einem Fehlschlag den Wert nie aus.
        enthalten = any(geheimnis in darstellung for darstellung in darstellungen)
        assert not enthalten, "ein Passwort steht in der Darstellung der Instanz"


@pytest.mark.parametrize(
    "fehler", [subprocess.TimeoutExpired("docker", 30), FileNotFoundError("docker")]
)
def test_R3_F_008_aufraeumen_entfernt_das_verzeichnis_auch_wenn_docker_ausfaellt(
    aufraeumen_mit_ersatz: Callable[[Exception, Path], list[str]],
    tmp_path: Path,
    fehler: Exception,
) -> None:
    wurzel = tmp_path / "r3cosint-test-ersatz"
    (wurzel / "passwoerter").mkdir(parents=True, mode=0o700)
    passwortdatei = wurzel / "passwoerter" / "r3cosint_anwendung"
    passwortdatei.write_text("synthetisch\n", encoding="utf-8")
    meldungen = aufraeumen_mit_ersatz(fehler, wurzel)  # keine Ausnahme nach aussen
    assert not wurzel.exists()
    assert not passwortdatei.exists()
    assert any("r3cosint-test-ersatz" in m and "docker rm -f" in m for m in meldungen)


def test_R3_F_008_das_socket_verzeichnis_ist_fuer_den_entrypoint_des_images_betretbar(
    postgres_instanz: "PostgresInstanz",
) -> None:
    # Angelegt wird das Verzeichnis mit 0777; der Entrypoint ändert den Modus beim Start (gemessen:
    # 1775). Nach dem Start ist zu belegen, dass andere Benutzer es lesen und betreten dürfen; der
    # Zugang bleibt durch das 0700-Elternverzeichnis beim Aufrufer.
    modus = stat.S_IMODE(postgres_instanz.socket_verzeichnis.stat().st_mode)
    assert (modus & 0o005) == 0o005
    assert (
        stat.S_IMODE(postgres_instanz.socket_verzeichnis.parent.stat().st_mode) == 0o700
    )


def test_R3_F_008_das_wegwerfverzeichnis_liegt_ausserhalb_des_arbeitsbaums_mit_engen_rechten(
    postgres_instanz: "PostgresInstanz",
) -> None:
    arbeitsbaum = Path(__file__).resolve().parents[3]
    assert not postgres_instanz.wurzel.is_relative_to(arbeitsbaum)
    assert stat.S_IMODE(postgres_instanz.wurzel.stat().st_mode) == 0o700
    for datei in postgres_instanz.passwort_dateien.values():
        assert stat.S_IMODE(datei.stat().st_mode) == 0o600
        assert stat.S_IMODE(datei.parent.stat().st_mode) == 0o700


@pytest.mark.anyio
async def test_R3_F_008_alle_lokalen_anmeldungen_verlangen_scram_sha_256(
    datenbank: "Testdatenbank",
) -> None:
    engine = engine_erzeugen(
        datenbank.instanz.verbindung("r3cosint_test", "r3cosint_test")
    )
    try:
        async with engine.connect() as verbindung:
            methoden = await verbindung.execute(
                text(
                    "SELECT DISTINCT auth_method FROM pg_hba_file_rules "
                    "WHERE type IN ('local', 'host') AND auth_method IS NOT NULL"
                )
            )
            assert [zeile[0] for zeile in methoden] == ["scram-sha-256"]
    finally:
        await engine.dispose()


@pytest.mark.anyio
async def test_R3_F_008_pg_umgebung_bleibt_ohne_wirkung_auf_die_verbindung(
    datenbank: "Testdatenbank",
    verbindung_anwendung: AsyncConnection,
    tmp_path: Path,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    richtig = datenbank.instanz.passwoerter["r3cosint_anwendung"]
    falsch = "synthetisch-falsches-passwort-nur-fuer-tests"
    falsche_datei = tmp_path / "falsch"
    falsche_datei.write_text(falsch + "\n", encoding="utf-8")
    verbindung = datenbank.verbindung("r3cosint_anwendung").model_copy(
        update={"passwort_datei": falsche_datei}
    )
    # Die Umgebung bietet das richtige Passwort an; die Verbindung nimmt allein die Datei.
    monkeypatch.setenv("PGPASSWORD", richtig)
    monkeypatch.setenv("PGUSER", "r3cosint_eigentuemer")
    monkeypatch.setenv("PGHOST", "/nicht/vorhanden")
    monkeypatch.setenv("PGDATABASE", "nicht_vorhanden")
    monkeypatch.setenv("PGPASSFILE", str(tmp_path / "pgpass"))
    engine = engine_erzeugen(verbindung)
    try:
        with pytest.raises(DBAPIError) as ausnahme:
            async with engine.connect() as aktiv:
                await aktiv.execute(text("SELECT 1"))
    finally:
        await engine.dispose()
    meldung = str(ausnahme.value)
    assert "password authentication failed" in meldung
    assert (
        "r3cosint_anwendung" in meldung
    )  # der Benutzer der Verbindung, nicht der der Umgebung
    for geheimnis in (richtig, falsch, *datenbank.instanz.passwoerter.values()):
        # Das Ergebnis wird vorab zu einem Wahrheitswert: bei einem Fehlschlag gibt pytest so
        # nie den Wert des Passworts aus.
        enthalten = geheimnis in meldung or geheimnis in repr(ausnahme.value)
        assert not enthalten, "ein Passwort steht in der Fehlermeldung"
    # Gegenprobe: dieselbe Umgebung mit der richtigen Datei verbindet.
    ergebnis = await verbindung_anwendung.execute(text("SELECT current_user"))
    assert ergebnis.scalar_one() == "r3cosint_anwendung"


def test_R3_F_008_keine_passwoerter_in_der_ausgabe_des_containers(
    postgres_instanz: "PostgresInstanz", docker_aufruf: DockerAufruf
) -> None:
    protokoll = docker_aufruf("logs", postgres_instanz.container)
    assert protokoll.returncode == 0
    ausgabe = protokoll.stdout + protokoll.stderr
    for passwort in postgres_instanz.passwoerter.values():
        enthalten = passwort in ausgabe
        assert not enthalten, "ein Passwort steht im Protokoll des Containers"


# --- Meldungen bei fehlender Voraussetzung (ohne Daemon gemessen durch ein Ersatzprogramm) ---


def _ersatz(tmp_path: Path, info: int, image: int) -> Path:
    programm = tmp_path / "docker"
    programm.write_text(
        "#!/bin/sh\n"
        'case "$1" in\n'
        f"  info) exit {info} ;;\n"
        f"  image) exit {image} ;;\n"
        "esac\n"
        "exit 0\n",
        encoding="utf-8",
    )
    programm.chmod(0o755)
    return programm


def test_R3_F_008_ohne_docker_nennt_die_meldung_die_sache_und_den_schritt(
    voraussetzungen: Callable[[str], str], tmp_path: Path
) -> None:
    with pytest.raises(KonfigurationsFehler) as ausnahme:
        voraussetzungen(str(tmp_path / "gibt-es-nicht"))
    assert "docker fehlt" in ausnahme.value.sache
    assert "installieren" in ausnahme.value.naechster_schritt


def test_R3_F_008_ohne_daemon_nennt_die_meldung_die_sache_und_den_schritt(
    voraussetzungen: Callable[[str], str], tmp_path: Path
) -> None:
    with pytest.raises(KonfigurationsFehler) as ausnahme:
        voraussetzungen(str(_ersatz(tmp_path, info=1, image=0)))
    assert "Daemon" in ausnahme.value.sache
    assert "starten" in ausnahme.value.naechster_schritt


def test_R3_F_008_ohne_image_nennt_die_meldung_die_sache_und_den_schritt(
    voraussetzungen: Callable[[str], str], tmp_path: Path
) -> None:
    with pytest.raises(KonfigurationsFehler) as ausnahme:
        voraussetzungen(str(_ersatz(tmp_path, info=0, image=1)))
    assert "Image" in ausnahme.value.sache
    assert "docker pull" in ausnahme.value.naechster_schritt
    assert "@sha256:" in ausnahme.value.naechster_schritt


def test_R3_F_008_mit_allen_voraussetzungen_liefert_die_pruefung_das_image_ueber_den_digest(
    voraussetzungen: Callable[[str], str], tmp_path: Path
) -> None:
    bild = voraussetzungen(str(_ersatz(tmp_path, info=0, image=0)))
    assert bild.startswith("docker.io/library/postgres@sha256:")
    assert len(bild.removeprefix("docker.io/library/postgres@sha256:")) == 64
