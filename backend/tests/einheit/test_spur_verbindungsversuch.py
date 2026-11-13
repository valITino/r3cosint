"""Einheitstest: Eingabe Verbindungsversuch und Eintragstypen des Ausgangs (ADR 0008, Festlegung S2.1; R3-F-015, R3-F-028, R3-F-011).

Geprüft werden die Belegungstabelle (jede Zelle), die Vorräte, die Nutzlast mit nachgerechneten
Pseudonymen, die Darstellung ohne Klartext und die Zuordnung der Eintragstypen. Alle Werte sind
synthetisch (Endung .test, Testkonstante 2001:20::1, die nie kontaktiert wird).
"""

import hashlib
import hmac
import json
from typing import Any
from uuid import UUID

import pytest
from pydantic import ValidationError

from r3cosint.spur.kette import SPUR_JE_EINTRAGSTYP, Eintragstyp, Spur
from r3cosint.spur.payload import (
    Pseudonymisierer,
    Verbindungsversuch,
    normalisieren,
    nutzlast_bilden,
)

SCHLUESSEL = bytes(range(32))
FALL = UUID(int=1)
VERSUCH = UUID("5a5a5a5a-0000-4000-8000-00000000c0de")
STAND = "ab" * 32
ZIEL = "https://dienst.beispiel.test:443"
AUSGANG = "http://vorlauf.beispiel.test:8080"
ADRESSE = "2001:20::1"

FELDER = (
    "schema",
    "anschluss",
    "zielart",
    "ziel",
    "adresse",
    "adressbereich",
    "listeneintrag",
    "fehlerart",
    "status",
    "antwort_bytes",
)
# Belegungstabelle der Festlegung (Zeile Protokoll: spur.payload), unabhängig von der Umsetzung
# hier erneut ausgeschrieben: P = Pflicht, V = verboten, in der Reihenfolge von FELDER.
TABELLE = {
    "zugelassen": "PPPPPPPVVV",
    "beantwortet": "PPPPPPPVPP",
    "verbindung_fehlgeschlagen": "PPPPPPPPVV",
    "nicht_in_positivliste": "PPPPVVVVVV",
    "bereich_nicht_oeffentlich": "PPPPPPPVVV",
    "aufloesung_fehlgeschlagen": "PPPPVVPVVV",
    "kette_zu_lang": "PPPPVVVVVV",
    "url_nicht_auswertbar": "VVVVVVVVVV",
}
GUELTIG: dict[str, Any] = {
    "schema": "https",
    "anschluss": 443,
    "zielart": "name",
    "ziel": ZIEL,
    "adresse": ADRESSE,
    "adressbereich": "oeffentlich",
    "listeneintrag": "test.ziel-synth",
    "fehlerart": "verbindung",
    "status": 200,
    "antwort_bytes": 5,
}


def _felder(ergebnis: str, schritt: int = 0, /, **aenderung: Any) -> dict[str, Any]:
    """Gültige Felder je Ergebnis nach der Tabelle; None in aenderung entfernt ein Feld."""
    wert: dict[str, Any] = {
        "fall_kennung": FALL,
        "werkzeug": "test.werkzeug",
        "versuch_kennung": VERSUCH,
        "schritt": schritt,
        "methode": "GET",
        "ergebnis": ergebnis,
        "listenstand": STAND,
    }
    for name, kennzeichen in zip(FELDER, TABELLE[ergebnis], strict=True):
        if kennzeichen == "P":
            wert[name] = GUELTIG[name]
    if ergebnis == "bereich_nicht_oeffentlich":
        wert["adressbereich"] = "privat"
        wert["adresse"] = "10.0.0.1"
    if schritt > 0:
        wert["ausgangsziel"] = AUSGANG
    for name, neu in aenderung.items():
        if neu is None:
            wert.pop(name, None)
        else:
            wert[name] = neu
    return wert


def _eingabe(
    ergebnis: str, schritt: int = 0, /, **aenderung: Any
) -> Verbindungsversuch:
    return Verbindungsversuch(**_felder(ergebnis, schritt, **aenderung))


@pytest.mark.parametrize("ergebnis", sorted(TABELLE))
def test_R3_F_015_jedes_ergebnis_ist_mit_seiner_belegung_gueltig(
    ergebnis: str,
) -> None:
    assert _eingabe(ergebnis).ergebnis == ergebnis
    assert _eingabe(ergebnis, 2).ausgangsziel == AUSGANG


def _zellen() -> list[tuple[str, str, str]]:
    return [
        (ergebnis, name, kennzeichen)
        for ergebnis, zeile in TABELLE.items()
        for name, kennzeichen in zip(FELDER, zeile, strict=True)
    ]


@pytest.mark.parametrize(
    ("ergebnis", "name", "kennzeichen"),
    _zellen(),
    ids=lambda w: str(w),
)
def test_R3_F_015_jede_zelle_der_belegungstabelle_wird_durchgesetzt(
    ergebnis: str, name: str, kennzeichen: str
) -> None:
    if kennzeichen == "P":
        with pytest.raises(ValidationError, match=name):
            _eingabe(ergebnis, **{name: None})
    else:
        # Ein verbotenes Feld wird mit einem Wert der eigenen Form gesetzt.
        with pytest.raises(ValidationError, match=name):
            _eingabe(ergebnis, **{name: GUELTIG[name]})


def test_R3_F_015_ausgangsziel_genau_bei_schritt_ueber_null() -> None:
    with pytest.raises(ValidationError, match="ausgangsziel"):
        _eingabe("zugelassen", 1, ausgangsziel=None)
    with pytest.raises(ValidationError, match="ausgangsziel"):
        _eingabe("zugelassen", 0, ausgangsziel=AUSGANG)
    with pytest.raises(ValidationError, match="ausgangsziel"):
        _eingabe("url_nicht_auswertbar", 0, ausgangsziel=AUSGANG)
    assert _eingabe("url_nicht_auswertbar", 3).schritt == 3


def test_R3_F_015_stets_pflicht_sind_die_sieben_grundfelder() -> None:
    for name in (
        "fall_kennung",
        "werkzeug",
        "versuch_kennung",
        "schritt",
        "methode",
        "ergebnis",
        "listenstand",
    ):
        wert = _felder("url_nicht_auswertbar")
        del wert[name]
        with pytest.raises(ValidationError, match=name):
            Verbindungsversuch(**wert)


def test_R3_F_015_zielart_name_ist_bei_aufloesungsergebnissen_pflicht() -> None:
    for ergebnis in ("bereich_nicht_oeffentlich", "aufloesung_fehlgeschlagen"):
        with pytest.raises(ValidationError, match="zielart"):
            _eingabe(ergebnis, zielart="ipv4")


def test_R3_F_015_adressbereich_je_ergebnis() -> None:
    with pytest.raises(ValidationError, match="adressbereich"):
        _eingabe("bereich_nicht_oeffentlich", adressbereich="oeffentlich")
    for ergebnis in ("zugelassen", "beantwortet", "verbindung_fehlgeschlagen"):
        with pytest.raises(ValidationError, match="adressbereich"):
            _eingabe(ergebnis, adressbereich="privat")
    # Ein Literal trägt den Bereich des Literals (GK-6): die Rückschleife ist zulässig.
    literal = _eingabe(
        "zugelassen",
        zielart="ipv4",
        adresse="127.0.0.1",
        adressbereich="rueckschleife",
        ziel="https://127.0.0.1:443",
    )
    assert literal.adressbereich == "rueckschleife"


def test_R3_F_015_ziel_traegt_schema_und_anschluss_und_keinen_pfad() -> None:
    for ziel in (
        "http://dienst.beispiel.test:443",  # Schema weicht ab
        "https://dienst.beispiel.test:8443",  # Anschluss weicht ab
        "https://dienst.beispiel.test:443/pfad",
        "https://dienst.beispiel.test:443?abfrage=1",
        "https://benutzer@dienst.beispiel.test:443",
        "https://dienst.beispiel.test",
        "dienst.beispiel.test:443",
        "https://dienst.beispiel.test:443 ",
    ):
        with pytest.raises(ValidationError):
            _eingabe("zugelassen", ziel=ziel)
    with pytest.raises(ValidationError):
        _eingabe("zugelassen", 1, ausgangsziel="https://a.test/pfad:443")
    ipv6 = _eingabe(
        "zugelassen",
        schema="http",
        anschluss=8080,
        zielart="ipv6",
        ziel="http://[2001:20::1]:8080",
        adressbereich="oeffentlich",
    )
    assert ipv6.ziel == "http://[2001:20::1]:8080"


@pytest.mark.parametrize(
    ("feld", "wert"),
    [
        ("methode", "PUT"),
        ("methode", "get"),
        ("ergebnis", "unbekannt"),
        ("schema", "ftp"),
        ("anschluss", 0),
        ("anschluss", 65536),
        ("zielart", "url"),
        ("adressbereich", "loopback"),
        ("fehlerart", "sonstige"),
        ("status", 99),
        ("status", 600),
        ("antwort_bytes", -1),
        ("schritt", -1),
        ("listenstand", "AB" * 32),
        ("listenstand", "ab" * 31),
        ("listeneintrag", "Gross"),
        ("werkzeug", "Gross Werkzeug"),
        ("adresse", "Dienst.Test"),
    ],
)
def test_R3_F_015_vorraete_und_formen_werden_abgewiesen(feld: str, wert: Any) -> None:
    with pytest.raises(ValidationError):
        _eingabe("beantwortet", **{feld: wert})


def test_R3_F_015_der_vorrat_der_ergebnisse_hat_acht_werte() -> None:
    erlaubt = Verbindungsversuch.model_fields["ergebnis"].annotation
    assert erlaubt is not None
    assert set(erlaubt.__args__) == set(TABELLE)
    assert len(TABELLE) == 8
    bereiche = Verbindungsversuch.model_fields["adressbereich"].annotation
    assert bereiche is not None
    assert len(bereiche.__args__[0].__args__) == 11
    assert len(Verbindungsversuch.model_fields) == 18


def test_R3_F_015_die_eingabe_ist_unveraenderlich_und_nimmt_keine_weiteren_felder() -> (
    None
):
    eingabe = _eingabe("zugelassen")
    with pytest.raises(ValidationError):
        eingabe.schritt = 1
    with pytest.raises(ValidationError):
        Verbindungsversuch(**_felder("zugelassen"), pfad="/x")  # type: ignore[call-arg]
    with pytest.raises(ValidationError):
        _eingabe("zugelassen", schritt="1")  # strikt: kein Text für eine Zahl


def test_R3_F_011_repr_und_str_nennen_ziel_adresse_und_ausgangsziel_nicht() -> None:
    eingabe = _eingabe("zugelassen", 1)
    for darstellung in (repr(eingabe), str(eingabe)):
        for klartext in (ZIEL, AUSGANG, ADRESSE, "beispiel.test"):
            assert klartext not in darstellung
        assert str(VERSUCH) in darstellung
    for name in ("ziel", "adresse", "ausgangsziel"):
        assert Verbindungsversuch.model_fields[name].repr is False
    for name, feld in Verbindungsversuch.model_fields.items():
        if name not in ("ziel", "adresse", "ausgangsziel"):
            assert feld.repr is True


def test_R3_F_011_validierungsfehler_nennen_keinen_klartext() -> None:
    with pytest.raises(ValidationError) as fehler:
        _eingabe("zugelassen", ziel="https://geheim.beispiel.test:443/pfad")
    assert "geheim" not in str(fehler.value)
    with pytest.raises(ValidationError) as fehler2:
        _eingabe("nicht_in_positivliste", adresse=ADRESSE)
    assert ADRESSE not in str(fehler2.value)


def _hmac(wert: str) -> str:
    nachricht = b"r3cosint-pseudonym-1\n" + wert.encode("utf-8")
    return hmac.new(SCHLUESSEL, nachricht, hashlib.sha256).hexdigest()


def test_R3_F_015_nutzlast_ohne_klartext_und_mit_nachgerechneten_pseudonymen() -> None:
    eingabe = _eingabe("beantwortet", 1)
    text = nutzlast_bilden(eingabe, Pseudonymisierer(SCHLUESSEL))
    wert = json.loads(text)
    assert wert == {
        "fall_kennung": str(FALL),
        "werkzeug": "test.werkzeug",
        "versuch_kennung": str(VERSUCH),
        "schritt": 1,
        "methode": "GET",
        "ergebnis": "beantwortet",
        "listenstand": STAND,
        "schema": "https",
        "anschluss": 443,
        "zielart": "name",
        "adressbereich": "oeffentlich",
        "listeneintrag": "test.ziel-synth",
        "status": 200,
        "antwort_bytes": 5,
        "ziel_pseudonym": _hmac(ZIEL),
        "adresse_pseudonym": _hmac(ADRESSE),
        "ausgangsziel_pseudonym": _hmac(AUSGANG),
    }
    for klartext in (ZIEL, AUSGANG, ADRESSE, "beispiel.test", "vorlauf"):
        assert klartext not in text
    # Vorbedingung der Nachrechnung: die Zielform ist normalisiert.
    assert normalisieren(ZIEL) == ZIEL
    assert normalisieren(AUSGANG) == AUSGANG


def test_R3_F_015_felder_ohne_wert_fehlen_in_der_nutzlast() -> None:
    wert = json.loads(
        nutzlast_bilden(_eingabe("nicht_in_positivliste"), Pseudonymisierer(SCHLUESSEL))
    )
    assert set(wert) == {
        "fall_kennung",
        "werkzeug",
        "versuch_kennung",
        "schritt",
        "methode",
        "ergebnis",
        "listenstand",
        "schema",
        "anschluss",
        "zielart",
        "ziel_pseudonym",
    }
    leer = json.loads(
        nutzlast_bilden(_eingabe("url_nicht_auswertbar"), Pseudonymisierer(SCHLUESSEL))
    )
    assert set(leer) == {
        "fall_kennung",
        "werkzeug",
        "versuch_kennung",
        "schritt",
        "methode",
        "ergebnis",
        "listenstand",
    }
    assert "null" not in json.dumps(leer)


def test_R3_F_028_gleiche_zielform_ergibt_gleiches_pseudonym_je_fall_und_schluessel() -> (
    None
):
    p = Pseudonymisierer(SCHLUESSEL)
    a = json.loads(nutzlast_bilden(_eingabe("zugelassen"), p))
    b = json.loads(nutzlast_bilden(_eingabe("zugelassen", 2), p))
    assert a["ziel_pseudonym"] == b["ziel_pseudonym"]
    anderer = Pseudonymisierer(bytes(reversed(SCHLUESSEL)))
    c = json.loads(nutzlast_bilden(_eingabe("zugelassen"), anderer))
    assert c["ziel_pseudonym"] != a["ziel_pseudonym"]
    d = json.loads(
        nutzlast_bilden(
            _eingabe(
                "zugelassen", ziel="http://dienst.beispiel.test:443", schema="http"
            ),
            p,
        )
    )
    assert d["ziel_pseudonym"] != a["ziel_pseudonym"]


def test_R3_F_015_die_vier_neuen_eintragstypen_gehoeren_zur_arbeitsspur() -> None:
    neue = {"verbindungsversuch", "abweisung", "abfrage", "negativbefund"}
    assert {t.value for t in Eintragstyp} == {
        "fall_eroeffnet",
        "fall_geschlossen",
        "entitaet",
        "beziehung",
    } | neue
    for typ in Eintragstyp:
        if typ.value in neue:
            assert SPUR_JE_EINTRAGSTYP[typ] is Spur.ARBEITSSPUR
    assert set(SPUR_JE_EINTRAGSTYP) == set(Eintragstyp)


def test_R3_F_015_zeitpunkt_steht_nicht_in_der_eingabe() -> None:
    # Der Zeitpunkt kommt allein aus der Uhr über spur.service.anfuegen (DS-S21-07).
    assert not {"zeitpunkt", "person_kennung", "erhoben_am"} & set(
        Verbindungsversuch.model_fields
    )
