"""Einheitstest: spur.payload (ADR 0007, Nr. 17 und 26, Festlegung S1.2; R3-F-011, R3-F-008)."""

import json
import pickle
import unicodedata
from datetime import UTC, datetime
from typing import Any
from uuid import UUID

import pytest
from pydantic import ValidationError

from r3cosint.spur.payload import (
    Beziehung,
    Eingabe,
    Entitaet,
    FallEroeffnet,
    FallGeschlossen,
    Pseudonymisierer,
    kanonisch_serialisieren,
    normalisieren,
    nutzlast_bilden,
)

SCHLUESSEL = bytes(range(32))
ZEIT = datetime(2026, 1, 15, 8, 30, 0, 123456, tzinfo=UTC)
ZEIT_ERHOBEN = datetime(2026, 1, 15, 8, 0, 0, tzinfo=UTC)
K1, K2, K3, K4 = (UUID(int=n) for n in (1, 2, 3, 4))


def test_R3_F_011_unicode_stand_ist_festgeschrieben() -> None:
    # Ein Wechsel der Unicode-Datenbank kann Pseudonyme ändern (DF-S12-16): bewusster Entscheid
    # mit neuem Etikett, nicht still.
    assert unicodedata.unidata_version == "15.1.0"


def test_R3_F_011_pseudonym_vektor_mit_festem_schluessel() -> None:
    # Erwartungswerte: openssl dgst -sha256 -mac HMAC mit dem Schlüssel 00 01 ... 1f über
    # "r3cosint-pseudonym-1\n" + normalisierter Wert, unabhängig von dieser Implementierung.
    pseudonymisierer = Pseudonymisierer(SCHLUESSEL)
    assert pseudonymisierer.pseudonym("Erika  Muster") == (
        "67580ef4c74dbeebaa8b5036be66909311b17760822ce7e849c2955c04d733d7"
    )
    assert pseudonymisierer.pseudonym("STRASSE 1") == (
        "06ee5f910c288d5db0803d8b407b7fe64af482e8e08bd0235badd6846fa40ecd"
    )


def test_R3_F_011_gleiche_pseudonyme_fuer_gleiche_werte_in_verschiedener_schreibweise() -> (
    None
):
    p = Pseudonymisierer(SCHLUESSEL)
    assert p.pseudonym("Erika  Muster") == p.pseudonym("ERIKA MUSTER")
    assert p.pseudonym("Erika Muster") != p.pseudonym("Erika Mustern")


def test_R3_F_011_zwei_schluessel_geben_verschiedene_pseudonyme() -> None:
    a = Pseudonymisierer(SCHLUESSEL)
    b = Pseudonymisierer(bytes(reversed(SCHLUESSEL)))
    assert a.pseudonym("Erika Muster") != b.pseudonym("Erika Muster")


def test_R3_F_011_normalisierung_nfc_casefold_und_leerraum() -> None:
    assert normalisieren("  Straße \t 1\n") == "strasse 1"
    assert normalisieren("Ä") == "ä"  # zerlegt wird zusammengesetzt
    assert normalisieren("Ä") == normalisieren("ä")
    # Leerraum ist die Menge von str.split: U+001C, U+0085 und U+2028 trennen, U+200B nicht.
    assert normalisieren("a\u001cb\u0085c\u2028d") == "a b c d"
    assert normalisieren("a\u200bb") == "a\u200bb"


@pytest.mark.parametrize("wert", ["", "   ", "\t\n\u2028"])
def test_R3_F_011_leerer_wert_wird_abgewiesen_ohne_den_wert_zu_nennen(
    wert: str,
) -> None:
    with pytest.raises(ValueError, match="leer") as fehler:
        Pseudonymisierer(SCHLUESSEL).pseudonym(wert)
    assert repr(wert) not in str(fehler.value)


@pytest.mark.parametrize("laenge", [0, 31, 33, 64])
def test_R3_F_011_schluessel_ungleich_32_bytes_wird_abgewiesen(laenge: int) -> None:
    with pytest.raises(ValueError, match="32 Bytes"):
        Pseudonymisierer(b"x" * laenge)


def test_R3_F_011_pseudonymisierer_verraet_den_schluessel_nicht() -> None:
    p = Pseudonymisierer(SCHLUESSEL)
    assert repr(p) == "Pseudonymisierer()"
    assert str(p) == "Pseudonymisierer()"
    assert not hasattr(p, "__dict__")
    with pytest.raises(TypeError):
        pickle.dumps(p)
    with pytest.raises(TypeError):
        p.__reduce__()


def _alle_eingaben() -> list[Eingabe]:
    eigenschaften = {
        "name": ("Erfundene Person", "Erfundene Person"),
        "ort": ("Nirgendwo",),
    }
    return [
        FallEroeffnet(
            fall_kennung=K1,
            rechtsregime="R1",
            fallkategorie="vergehen",
            aktenzeichen="TEST-SYNTH-GEHEIM-1",
            rechtsgrundlage="synthetische Rechtsgrundlage",
            ermittelnde_person="test.ermittlung",
            eroeffnet_am=ZEIT,
        ),
        FallGeschlossen(
            fall_kennung=K1,
            geschlossen_am=ZEIT,
            prueffrist_bis=ZEIT,
            erste_pruefung_monate=84,
        ),
        Entitaet(
            fall_kennung=K1,
            entitaet_kennung=K2,
            ftm_kennung="erfundene-kennung-geheim",
            ftm_schema="Person",
            herkunft_kennung=K3,
            eigenschaften=eigenschaften,
            werkzeug="synth.werkzeug",
            erhoben_am=ZEIT_ERHOBEN,
            erhebende_person="synth.erhebung",
            abfrage="TEST-SYNTH Abfrage",
        ),
        Beziehung(
            fall_kennung=K1,
            beziehung_kennung=K2,
            ftm_kennung="erfundene-beziehung-geheim",
            ftm_schema="Family",
            herkunft_kennung=K3,
            quelle_kennung=K3,
            ziel_kennung=K4,
            eigenschaften=eigenschaften,
            werkzeug="synth.werkzeug",
            erhoben_am=ZEIT_ERHOBEN,
            erhebende_person="synth.erhebung",
            abfrage="TEST-SYNTH Abfrage",
        ),
    ]


@pytest.mark.parametrize("eingabe", _alle_eingaben(), ids=lambda e: type(e).__name__)
def test_R3_F_011_kein_klartextwert_im_text_der_nutzlast(eingabe: Eingabe) -> None:
    text = nutzlast_bilden(eingabe, Pseudonymisierer(SCHLUESSEL))
    for geheim in (
        "TEST-SYNTH-GEHEIM-1",
        "synthetische Rechtsgrundlage",
        "test.ermittlung",
        "erfundene-kennung-geheim",
        "erfundene-beziehung-geheim",
        "Erfundene Person",
        "Nirgendwo",
    ):
        assert geheim not in text
        assert geheim.lower() not in text.lower()
    daten = json.loads(text)
    assert daten["fall_kennung"] == str(K1)


def test_R3_F_011_nutzlast_fall_eroeffnet_traegt_pseudonyme_und_klartext_der_vorraete() -> (
    None
):
    p = Pseudonymisierer(SCHLUESSEL)
    text = nutzlast_bilden(_alle_eingaben()[0], p)
    assert text == (
        '{"aktenzeichen_pseudonym":"' + p.pseudonym("TEST-SYNTH-GEHEIM-1") + '",'
        '"ermittelnde_person_pseudonym":"' + p.pseudonym("test.ermittlung") + '",'
        '"eroeffnet_am":"2026-01-15T08:30:00.123456Z",'
        '"fall_kennung":"00000000-0000-0000-0000-000000000001",'
        '"fallkategorie":"vergehen",'
        '"rechtsgrundlage_pseudonym":"'
        + p.pseudonym("synthetische Rechtsgrundlage")
        + '",'
        '"rechtsregime":"R1"}'
    )


def test_R3_F_011_nutzlast_fall_geschlossen_traegt_allein_kennung_zeiten_und_monate() -> (
    None
):
    text = nutzlast_bilden(_alle_eingaben()[1], Pseudonymisierer(SCHLUESSEL))
    assert json.loads(text) == {
        "fall_kennung": str(K1),
        "geschlossen_am": "2026-01-15T08:30:00.123456Z",
        "prueffrist_bis": "2026-01-15T08:30:00.123456Z",
        "erste_pruefung_monate": 84,
    }


@pytest.mark.parametrize("index", [2, 3], ids=["Entitaet", "Beziehung"])
def test_R3_F_011_eigenschaftswerte_sind_sortierte_pseudonyme_mit_doppeln(
    index: int,
) -> None:
    p = Pseudonymisierer(SCHLUESSEL)
    daten = json.loads(nutzlast_bilden(_alle_eingaben()[index], p))
    assert daten["eigenschaften"]["name"] == [p.pseudonym("Erfundene Person")] * 2
    assert daten["eigenschaften"]["ort"] == [p.pseudonym("Nirgendwo")]
    assert daten["ftm_kennung_pseudonym"] == p.pseudonym(
        "erfundene-kennung-geheim" if index == 2 else "erfundene-beziehung-geheim"
    )
    assert "ftm_kennung" not in daten
    assert daten["ftm_schema"] in ("Person", "Family")
    if index == 3:
        assert (daten["quelle_kennung"], daten["ziel_kennung"]) == (str(K3), str(K4))


def test_R3_F_011_werte_werden_sortiert() -> None:
    p = Pseudonymisierer(SCHLUESSEL)
    eingabe = Entitaet(
        fall_kennung=K1,
        entitaet_kennung=K2,
        ftm_kennung="x",
        ftm_schema="Person",
        herkunft_kennung=K3,
        eigenschaften={"name": ("b", "a", "c")},
        werkzeug="synth.werkzeug",
        erhoben_am=ZEIT_ERHOBEN,
        erhebende_person="synth.erhebung",
        abfrage="TEST-SYNTH Abfrage",
    )
    liste = json.loads(nutzlast_bilden(eingabe, p))["eigenschaften"]["name"]
    assert liste == sorted(liste)
    assert len(liste) == 3


def test_R3_F_011_leerer_eigenschaftswert_wird_abgewiesen() -> None:
    eingabe = Entitaet(
        fall_kennung=K1,
        entitaet_kennung=K2,
        ftm_kennung="x",
        ftm_schema="Person",
        herkunft_kennung=K3,
        eigenschaften={"name": ("  ",)},
        werkzeug="synth.werkzeug",
        erhoben_am=ZEIT_ERHOBEN,
        erhebende_person="synth.erhebung",
        abfrage="TEST-SYNTH Abfrage",
    )
    with pytest.raises(ValueError, match="leer"):
        nutzlast_bilden(eingabe, Pseudonymisierer(SCHLUESSEL))


def test_R3_F_008_kanonische_serialisierung_ist_sortiert_ohne_leerraum_und_nicht_ascii_unmaskiert() -> (
    None
):
    text = kanonisch_serialisieren({"b": [1, "ä", "😀"], "a": {"z": 0, "y": "x"}})
    assert text == '{"a":{"y":"x","z":0},"b":[1,"ä","😀"]}'


@pytest.mark.parametrize(
    "wert",
    [
        {"a": True},
        {"a": 1.5},
        {"a": float("nan")},
        {"a": 2**53},
        {"a": -(2**53)},
        {"a": None},
        {"a": (1, 2)},
        {"ä": 1},
        {"a": [{"ä": 1}]},
    ],
    ids=[
        "bool",
        "float",
        "nan",
        "gross",
        "klein",
        "none",
        "tupel",
        "nicht_ascii_schluessel",
        "tief",
    ],
)
def test_R3_F_008_unzulaessige_werte_und_schluessel_werden_abgewiesen(
    wert: dict[str, Any],
) -> None:
    with pytest.raises(ValueError, match=r"unzul|Schlüssel|ausserhalb"):
        kanonisch_serialisieren(wert)


def test_R3_F_008_ganze_zahlen_bis_zur_grenze_sind_zulaessig() -> None:
    assert kanonisch_serialisieren({"a": 2**53 - 1, "b": -(2**53 - 1)}) == (
        '{"a":9007199254740991,"b":-9007199254740991}'
    )


def test_R3_F_008_nicht_zeichenketten_schluessel_werden_abgewiesen() -> None:
    with pytest.raises(ValueError, match="Schlüssel"):
        kanonisch_serialisieren({1: "x"})  # type: ignore[dict-item]  # Schlüssel absichtlich int: der Fall selbst


@pytest.mark.parametrize("monate", [0, -1, 2**53, "84", 84.0, True, None])
def test_R3_F_001_fall_geschlossen_weist_ungueltige_erste_pruefung_monate_ab(
    monate: object,
) -> None:
    with pytest.raises(ValidationError):
        FallGeschlossen(
            fall_kennung=K1,
            geschlossen_am=ZEIT,
            prueffrist_bis=ZEIT,
            erste_pruefung_monate=monate,  # type: ignore[arg-type]  # ungültig: der Fall selbst
        )


@pytest.mark.parametrize("monate", [1, 84, 2**53 - 1])
def test_R3_F_001_fall_geschlossen_nimmt_erste_pruefung_monate_in_den_grenzen_an(
    monate: int,
) -> None:
    eingabe = FallGeschlossen(
        fall_kennung=K1,
        geschlossen_am=ZEIT,
        prueffrist_bis=ZEIT,
        erste_pruefung_monate=monate,
    )
    text = nutzlast_bilden(eingabe, Pseudonymisierer(SCHLUESSEL))
    assert json.loads(text)["erste_pruefung_monate"] == monate


def test_R3_F_008_unbekannte_felder_und_falsche_typen_werden_abgewiesen() -> None:
    gueltig: dict[str, Any] = {
        "fall_kennung": K1,
        "geschlossen_am": ZEIT,
        "prueffrist_bis": ZEIT,
        "erste_pruefung_monate": 84,
    }
    FallGeschlossen(**gueltig)
    with pytest.raises(ValidationError):
        FallGeschlossen(**gueltig, extra="x")  # type: ignore[call-arg]  # unbekanntes Feld: der Fall selbst
    with pytest.raises(ValidationError):
        FallGeschlossen(**{**gueltig, "fall_kennung": str(K1)})
    with pytest.raises(ValidationError):
        FallGeschlossen(**{**gueltig, "geschlossen_am": datetime(2026, 1, 1)})  # noqa: DTZ001
    with pytest.raises(ValidationError):
        FallEroeffnet(
            fall_kennung=K1,
            rechtsregime="R3",  # type: ignore[arg-type]  # ausserhalb des Vorrats: der Fall selbst
            fallkategorie="vergehen",
            aktenzeichen="a",
            rechtsgrundlage="b",
            ermittelnde_person="c",
            eroeffnet_am=ZEIT,
        )
    with pytest.raises(ValidationError):
        Entitaet(
            fall_kennung=K1,
            entitaet_kennung=K2,
            ftm_kennung="x",
            ftm_schema="person",
            herkunft_kennung=K3,
            eigenschaften={},
            werkzeug="synth.werkzeug",
            erhoben_am=ZEIT_ERHOBEN,
            erhebende_person="synth.erhebung",
            abfrage="TEST-SYNTH Abfrage",
        )
    with pytest.raises(ValidationError):
        Entitaet(
            fall_kennung=K1,
            entitaet_kennung=K2,
            ftm_kennung="x",
            ftm_schema="Person",
            herkunft_kennung=K3,
            eigenschaften={"Name": ("a",)},
            werkzeug="synth.werkzeug",
            erhoben_am=ZEIT_ERHOBEN,
            erhebende_person="synth.erhebung",
            abfrage="TEST-SYNTH Abfrage",
        )
    with pytest.raises(ValidationError):
        Entitaet(
            fall_kennung=K1,
            entitaet_kennung=K2,
            ftm_kennung="x",
            ftm_schema="Person",
            herkunft_kennung=K3,
            eigenschaften={"name": ()},
            werkzeug="synth.werkzeug",
            erhoben_am=ZEIT_ERHOBEN,
            erhebende_person="synth.erhebung",
            abfrage="TEST-SYNTH Abfrage",
        )


def test_R3_F_011_eingaben_sind_unveraenderlich() -> None:
    eingabe = _alle_eingaben()[1]
    with pytest.raises(ValidationError):
        eingabe.fall_kennung = K2


def test_R3_F_008_zeit_ausserhalb_des_bereichs_in_der_nutzlast_wird_abgewiesen() -> (
    None
):
    eingabe = FallGeschlossen(
        fall_kennung=K1,
        geschlossen_am=datetime(1999, 12, 31, 23, 59, 59, 999999, tzinfo=UTC),
        prueffrist_bis=ZEIT,
        erste_pruefung_monate=84,
    )
    with pytest.raises(ValueError, match="ausserhalb"):
        nutzlast_bilden(eingabe, Pseudonymisierer(SCHLUESSEL))


@pytest.mark.parametrize("eingabe", _alle_eingaben(), ids=lambda e: type(e).__name__)
def test_R3_F_011_repr_und_str_der_eingaben_nennen_keinen_klartext(
    eingabe: Eingabe,
) -> None:
    # DS-S15-08: Aktenzeichen, Rechtsgrundlage, ermittelnde Person, ftm_kennung, Eigenschaftswerte
    # und Abfrage stehen weder in repr noch in str (nur synthetische Werte).
    klartext = (
        "TEST-SYNTH-GEHEIM-1",
        "synthetische Rechtsgrundlage",
        "test.ermittlung",
        "erfundene-kennung-geheim",
        "erfundene-beziehung-geheim",
        "Erfundene Person",
        "Nirgendwo",
        "TEST-SYNTH Abfrage",
    )
    for darstellung in (repr(eingabe), str(eingabe)):
        for wert in klartext:
            assert wert not in darstellung
    # Die Darstellung nennt weiter die Kennungen und Vorräte.
    assert str(K1) in repr(eingabe)


@pytest.mark.parametrize(
    ("klasse", "felder"),
    [
        (FallEroeffnet, {"aktenzeichen", "rechtsgrundlage", "ermittelnde_person"}),
        (Entitaet, {"ftm_kennung", "eigenschaften", "abfrage"}),
        (Beziehung, {"ftm_kennung", "eigenschaften", "abfrage"}),
    ],
)
def test_R3_F_011_klartextfelder_der_nutzlastklassen_tragen_repr_false(
    klasse: Any, felder: set[str]
) -> None:
    for name in felder:
        assert klasse.model_fields[name].repr is False
    for name, feld in klasse.model_fields.items():
        if name not in felder:
            assert feld.repr is True
