"""Einheitstest: core.konfiguration und core.datenbank (ADR 0007, Entscheid 8; Festlegung S1.1, R3-F-008).

Alle Werte sind erkennbar synthetisch. Geprüft wird auch, dass kein Passwort in einer
URL, einer Meldung oder einer Darstellung steht.
"""

from pathlib import Path
from typing import Any

import pytest
from pydantic import ValidationError

from r3cosint.core import datenbank
from r3cosint.core.fehler import KonfigurationsFehler
from r3cosint.core.konfiguration import (
    Datenbankverbindung,
    aus_umgebung,
    verbindungs_url,
)

PASSWORT = "synthetisches-passwort-nur-fuer-tests"


@pytest.fixture
def passwortdatei(tmp_path: Path) -> Path:
    datei = tmp_path / "passwort"
    datei.write_text(PASSWORT + "\n", encoding="utf-8")
    return datei


@pytest.fixture
def umgebung(passwortdatei: Path) -> dict[str, str]:
    return {
        "R3COSINT_DB_HOST": "datenbank.synthetisch.test",
        "R3COSINT_DB_PORT": "6543",
        "R3COSINT_DB_NAME": "r3cosint_synthetisch",
        "R3COSINT_DB_BENUTZER": "synthetische_rolle",
        "R3COSINT_DB_PASSWORT_DATEI": str(passwortdatei),
    }


def test_R3_F_008_aus_umgebung_liest_die_fuenf_variablen(
    umgebung: dict[str, str], passwortdatei: Path
) -> None:
    verbindung = aus_umgebung(umgebung)
    assert verbindung.host == "datenbank.synthetisch.test"
    assert verbindung.port == 6543
    assert verbindung.name == "r3cosint_synthetisch"
    assert verbindung.benutzer == "synthetische_rolle"
    assert verbindung.passwort_datei == passwortdatei


def test_R3_F_008_aus_umgebung_ohne_port_nimmt_5432(umgebung: dict[str, str]) -> None:
    del umgebung["R3COSINT_DB_PORT"]
    assert aus_umgebung(umgebung).port == 5432


def test_R3_F_008_aus_umgebung_liest_os_environ_ohne_abbildung(
    umgebung: dict[str, str], monkeypatch: pytest.MonkeyPatch
) -> None:
    for name, wert in umgebung.items():
        monkeypatch.setenv(name, wert)
    assert aus_umgebung().name == "r3cosint_synthetisch"


@pytest.mark.parametrize(
    "variable",
    [
        "R3COSINT_DB_HOST",
        "R3COSINT_DB_NAME",
        "R3COSINT_DB_BENUTZER",
        "R3COSINT_DB_PASSWORT_DATEI",
    ],
)
def test_R3_F_008_fehlende_variable_nennt_den_namen_nicht_die_werte(
    umgebung: dict[str, str], variable: str
) -> None:
    del umgebung[variable]
    with pytest.raises(KonfigurationsFehler) as ausnahme:
        aus_umgebung(umgebung)
    meldung = str(ausnahme.value)
    assert variable in meldung
    assert ausnahme.value.naechster_schritt
    for wert in umgebung.values():
        assert wert not in meldung


@pytest.mark.parametrize(
    ("variable", "wert"),
    [
        ("R3COSINT_DB_PORT", "datenbankport-synthetisch"),
        ("R3COSINT_DB_PORT", "0"),
        ("R3COSINT_DB_PORT", "65536"),
        ("R3COSINT_DB_HOST", ""),
        ("R3COSINT_DB_NAME", ""),
        ("R3COSINT_DB_BENUTZER", ""),
        ("R3COSINT_DB_PASSWORT_DATEI", "relativer/synthetischer/pfad"),
    ],
)
def test_R3_F_008_ungueltige_variable_nennt_den_namen_nie_den_wert(
    umgebung: dict[str, str], variable: str, wert: str
) -> None:
    umgebung[variable] = wert
    with pytest.raises(KonfigurationsFehler) as ausnahme:
        aus_umgebung(umgebung)
    meldung = str(ausnahme.value)
    assert variable in meldung
    assert wert == "" or wert not in meldung


def test_R3_F_008_verbindung_ist_unveraenderlich_und_weist_fremde_felder_ab(
    umgebung: dict[str, str],
) -> None:
    verbindung = aus_umgebung(umgebung)
    with pytest.raises(ValidationError):
        verbindung.host = "anderer.synthetisch.test"
    felder: dict[str, Any] = {"passwort": PASSWORT, **dict(verbindung)}
    with pytest.raises(ValidationError):
        Datenbankverbindung(**felder)


def test_R3_F_008_passwort_lesen_entfernt_einen_abschliessenden_zeilenumbruch(
    umgebung: dict[str, str],
) -> None:
    geheimnis = aus_umgebung(umgebung).passwort_lesen()
    assert geheimnis.get_secret_value() == PASSWORT
    assert PASSWORT not in repr(geheimnis)
    assert PASSWORT not in str(geheimnis)


def test_R3_F_008_passwort_lesen_entfernt_nur_einen_zeilenumbruch(
    umgebung: dict[str, str], passwortdatei: Path
) -> None:
    passwortdatei.write_text(PASSWORT + "\n\n", encoding="utf-8")
    assert aus_umgebung(umgebung).passwort_lesen().get_secret_value() == PASSWORT + "\n"


def test_R3_F_008_passwort_lesen_nimmt_ein_passwort_ohne_zeilenumbruch(
    umgebung: dict[str, str], passwortdatei: Path
) -> None:
    passwortdatei.write_text(PASSWORT, encoding="utf-8")
    assert aus_umgebung(umgebung).passwort_lesen().get_secret_value() == PASSWORT


@pytest.mark.parametrize("inhalt", ["", "\n"])
def test_R3_F_008_leere_passwortdatei_ist_ein_konfigurationsfehler(
    umgebung: dict[str, str], passwortdatei: Path, inhalt: str
) -> None:
    passwortdatei.write_text(inhalt, encoding="utf-8")
    with pytest.raises(KonfigurationsFehler, match="leer"):
        aus_umgebung(umgebung).passwort_lesen()


def test_R3_F_008_fehlende_passwortdatei_ist_ein_konfigurationsfehler(
    umgebung: dict[str, str], passwortdatei: Path
) -> None:
    passwortdatei.unlink()
    with pytest.raises(KonfigurationsFehler, match="nicht lesbar") as ausnahme:
        aus_umgebung(umgebung).passwort_lesen()
    assert ausnahme.value.naechster_schritt


def test_R3_F_008_unlesbare_passwortdatei_ist_ein_konfigurationsfehler(
    umgebung: dict[str, str], tmp_path: Path
) -> None:
    umgebung["R3COSINT_DB_PASSWORT_DATEI"] = str(tmp_path)  # ein Verzeichnis
    with pytest.raises(KonfigurationsFehler, match="nicht lesbar"):
        aus_umgebung(umgebung).passwort_lesen()


def test_R3_F_008_passwortdatei_mit_ungueltiger_kodierung_ist_ein_konfigurationsfehler(
    umgebung: dict[str, str], passwortdatei: Path
) -> None:
    passwortdatei.write_bytes(b"\xff\xfe\x00synthetisch\n")
    with pytest.raises(KonfigurationsFehler, match="nicht lesbar"):
        aus_umgebung(umgebung).passwort_lesen()


def test_R3_F_008_die_url_hat_den_treiber_und_kein_passwort(
    umgebung: dict[str, str],
) -> None:
    verbindung = aus_umgebung(umgebung)
    url = verbindungs_url(verbindung)
    assert url.drivername == "postgresql+asyncpg"
    assert (url.host, url.port, url.database, url.username) == (
        "datenbank.synthetisch.test",
        6543,
        "r3cosint_synthetisch",
        "synthetische_rolle",
    )
    assert url.password is None
    for darstellung in (
        str(url),
        repr(url),
        url.render_as_string(hide_password=False),
        repr(verbindung),
        str(verbindung),
        verbindung.model_dump_json(),
    ):
        assert PASSWORT not in darstellung


def test_R3_F_008_engine_fuehrt_das_passwort_allein_in_connect_args(
    umgebung: dict[str, str], monkeypatch: pytest.MonkeyPatch
) -> None:
    aufruf: dict[str, Any] = {}

    def ersatz(url: Any, **optionen: Any) -> str:
        aufruf["url"] = url
        aufruf["optionen"] = optionen
        return "engine"

    monkeypatch.setattr(datenbank, "create_async_engine", ersatz)
    assert datenbank.engine_erzeugen(aus_umgebung(umgebung)) == "engine"
    optionen = aufruf["optionen"]
    assert optionen["connect_args"]["password"] == PASSWORT
    assert PASSWORT not in aufruf["url"].render_as_string(hide_password=False)
    assert optionen["hide_parameters"] is True
    assert optionen["echo"] is False


@pytest.mark.parametrize(
    ("host", "ssl"),
    [("/var/run/synthetisch", False), ("datenbank.synthetisch.test", "require")],
)
def test_R3_F_008_engine_gibt_ssl_ausdruecklich_mit(
    umgebung: dict[str, str], monkeypatch: pytest.MonkeyPatch, host: str, ssl: object
) -> None:
    aufruf: dict[str, Any] = {}

    def ersatz(url: Any, **optionen: Any) -> str:
        aufruf.update(optionen)
        return "engine"

    monkeypatch.setattr(datenbank, "create_async_engine", ersatz)
    umgebung["R3COSINT_DB_HOST"] = host
    datenbank.engine_erzeugen(aus_umgebung(umgebung))
    assert aufruf["connect_args"]["ssl"] == ssl


def test_R3_F_008_engine_ohne_lesbares_passwort_endet_mit_konfigurationsfehler(
    umgebung: dict[str, str], passwortdatei: Path
) -> None:
    passwortdatei.unlink()
    with pytest.raises(KonfigurationsFehler):
        datenbank.engine_erzeugen(aus_umgebung(umgebung))
