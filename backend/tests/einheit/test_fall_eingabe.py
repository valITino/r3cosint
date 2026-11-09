"""Einheitstest: Eingabe der Eröffnung, Vorräte, Angleichung, Fristrechnung (ADR 0007, S1.3; R3-F-001).

Alle Werte sind erfunden (5.15). Die Erwartungswerte der Prüffrist stehen als Zahlen im Test,
nicht aus dem Code.
"""

import inspect
import traceback
from collections.abc import Callable
from datetime import UTC, datetime
from typing import Any

import pytest
from pydantic import ValidationError

from r3cosint.core.fehler import (
    EindeutigkeitsFehler,
    R3cosintFehler,
    ZustandsFehler,
)
from r3cosint.core.zeit import monate_addieren
from r3cosint.fall import service
from r3cosint.fall.eingabe import (
    Eroeffnung,
    Fall,
    Fallzustand,
    Rechtsregime,
    aktenzeichen_angleichen,
    rechtsgrundlage_angleichen,
)

AKTENZEICHEN = "TEST-SYNTH-GEHEIM-AZ-0815"
RECHTSGRUNDLAGE = "synthetische Rechtsgrundlage GEHEIM-RG"
PERSON = "test.geheim"


def _daten(**aenderung: Any) -> dict[str, Any]:
    daten: dict[str, Any] = {
        "aktenzeichen": AKTENZEICHEN,
        "rechtsgrundlage": RECHTSGRUNDLAGE,
        "rechtsregime": Rechtsregime.R1,
        "fallkategorie": "vergehen",
        "ermittelnde_person": PERSON,
    }
    daten.update(aenderung)
    return daten


def _utc(
    j: int, m: int, t: int, h: int = 0, mi: int = 0, s: int = 0, us: int = 0
) -> datetime:
    return datetime(j, m, t, h, mi, s, us, tzinfo=UTC)


def test_R3_F_001_rechtsregime_kennt_allein_r1_und_r2() -> None:
    assert [r.value for r in Rechtsregime] == ["R1", "R2"]
    for wert in ("R3", "R4", "R5", "r1", ""):
        with pytest.raises(ValueError):
            Rechtsregime(wert)


def test_R3_F_001_fallzustand_spiegelt_die_sieben_werte_in_der_reihenfolge_der_pruefbedingung() -> (
    None
):
    assert [z.value for z in Fallzustand] == [
        "aktiv",
        "abgeschlossen",
        "pruefung_faellig",
        "verlaengert",
        "zur_loeschung_freigegeben",
        "geloescht",
        "archiviert",
    ]


@pytest.mark.parametrize(
    "regime", ["R3", "R4", "R5", "r1", "", None, "R1", "R2"], ids=str
)
def test_R3_F_001_eroeffnung_weist_ein_regime_ausserhalb_des_vorrats_und_text_statt_enum_ab(
    regime: object,
) -> None:
    with pytest.raises(ValidationError):
        Eroeffnung(**_daten(rechtsregime=regime))


@pytest.mark.parametrize("regime", [Rechtsregime.R1, Rechtsregime.R2])
def test_R3_F_001_eroeffnung_nimmt_r1_und_r2_an(regime: Rechtsregime) -> None:
    assert Eroeffnung(**_daten(rechtsregime=regime)).rechtsregime is regime


@pytest.mark.parametrize(
    "feld",
    [
        "aktenzeichen",
        "rechtsgrundlage",
        "rechtsregime",
        "fallkategorie",
        "ermittelnde_person",
    ],
)
def test_R3_F_001_jedes_fehlende_feld_der_eroeffnung_wird_abgewiesen(feld: str) -> None:
    daten = _daten()
    del daten[feld]
    with pytest.raises(ValidationError):
        Eroeffnung(**daten)


def test_R3_F_001_eroeffnung_weist_unbekannte_felder_ab() -> None:
    with pytest.raises(ValidationError):
        Eroeffnung(**_daten(zusatz="x"))


@pytest.mark.parametrize("feld", ["aktenzeichen", "rechtsgrundlage"])
@pytest.mark.parametrize("wert", ["", "   ", "\t\n "])
def test_R3_F_001_leere_und_leerraumwerte_werden_abgewiesen(
    feld: str, wert: str
) -> None:
    with pytest.raises(ValidationError):
        Eroeffnung(**_daten(**{feld: wert}))


@pytest.mark.parametrize(
    "kategorie", ["", "Vergehen", "mit leerraum", "x" * 65, "aeä", "a-b"]
)
def test_R3_F_001_fallkategorie_hat_die_form_klein_ziffern_unterstrich(
    kategorie: str,
) -> None:
    with pytest.raises(ValidationError):
        Eroeffnung(**_daten(fallkategorie=kategorie))


@pytest.mark.parametrize("person", ["", "Falsch Person", "GROSS", "a" * 200, "a;b"])
def test_R3_F_001_ermittelnde_person_ausserhalb_der_form_der_benutzerkennung_wird_abgewiesen(
    person: str,
) -> None:
    with pytest.raises(ValidationError) as fehler:
        Eroeffnung(**_daten(ermittelnde_person=person))
    assert person not in str(fehler.value) or person == ""


def test_R3_F_001_aktenzeichen_angleichen_fasst_leerraum_zusammen_und_trimmt() -> None:
    assert aktenzeichen_angleichen("BE  123 ") == "BE 123"
    assert aktenzeichen_angleichen("\t BE\n\x0c123" + chr(0xA0) + " ") == "BE 123"


def test_R3_F_001_aktenzeichen_angleichen_bringt_unicode_in_die_normalform_nfc() -> (
    None
):
    zerlegt = "A\u0308"
    assert aktenzeichen_angleichen(zerlegt) == "Ä"
    assert aktenzeichen_angleichen("BE 2026/A\u0308-1") == "BE 2026/Ä-1"


def test_R3_F_001_aktenzeichen_angleichen_behaelt_die_grossschreibung() -> None:
    assert aktenzeichen_angleichen("be 123") == "be 123"
    assert aktenzeichen_angleichen("BE 123") != aktenzeichen_angleichen("be 123")


@pytest.mark.parametrize("zeichen", ["\u200b", "\u0007", "\u2060", "\x00", "\u202e"])
def test_R3_F_001_aktenzeichen_angleichen_weist_steuer_und_formatzeichen_ab(
    zeichen: str,
) -> None:
    with pytest.raises(ValueError) as fehler:
        aktenzeichen_angleichen(f"BE{zeichen}123")
    assert "BE" not in str(fehler.value)


def test_R3_F_001_aktenzeichen_hat_hoechstens_100_zeichen_nach_der_angleichung() -> (
    None
):
    assert aktenzeichen_angleichen("a" * 100) == "a" * 100
    with pytest.raises(ValueError, match="100"):
        aktenzeichen_angleichen("a" * 101)
    # Die Länge wird nach der Angleichung gemessen: Leerraum am Rand zählt nicht.
    assert aktenzeichen_angleichen("  " + "a" * 100 + "  ") == "a" * 100


def test_R3_F_001_rechtsgrundlage_angleichen_hat_die_hoechstlaenge_2000() -> None:
    assert rechtsgrundlage_angleichen("a" * 2000) == "a" * 2000
    with pytest.raises(ValueError, match="2000"):
        rechtsgrundlage_angleichen("a" * 2001)
    assert rechtsgrundlage_angleichen(" Art.  1\tStPO ") == "Art. 1 StPO"
    with pytest.raises(ValueError):
        rechtsgrundlage_angleichen("   ")
    with pytest.raises(ValueError):
        rechtsgrundlage_angleichen("a\u200bb")


def test_R3_F_001_die_eroeffnung_traegt_die_angeglichene_form() -> None:
    eroeffnung = Eroeffnung(
        **_daten(aktenzeichen="  BE   7 ", rechtsgrundlage="Art.  1\tStPO")
    )
    assert eroeffnung.aktenzeichen == "BE 7"
    assert eroeffnung.rechtsgrundlage == "Art. 1 StPO"


def test_R3_F_001_repr_und_str_der_eroeffnung_nennen_keine_klartextfelder() -> None:
    eroeffnung = Eroeffnung(**_daten())
    for darstellung in (repr(eroeffnung), str(eroeffnung)):
        assert AKTENZEICHEN not in darstellung
        assert "GEHEIM-RG" not in darstellung
        assert PERSON not in darstellung
        assert "vergehen" in darstellung
        assert "R1" in darstellung


def test_R3_F_001_ein_validierungsfehler_der_eroeffnung_nennt_die_eingabe_nicht() -> (
    None
):
    geheim = "GEHEIM\u200bWERT"
    with pytest.raises(ValidationError) as fehler:
        Eroeffnung(**_daten(aktenzeichen=geheim))
    for text in (
        str(fehler.value),
        repr(fehler.value),
        "".join(traceback.format_exception(fehler.value)),
    ):
        assert "GEHEIM" not in text
    with pytest.raises(ValidationError) as fehler:
        Eroeffnung(**_daten(rechtsregime="R3"))
    assert "R3" not in str(fehler.value).replace("rechtsregime", "")  # kein Eingabewert


def test_R3_F_001_die_eroeffnung_ist_unveraenderlich() -> None:
    eroeffnung = Eroeffnung(**_daten())
    with pytest.raises(ValidationError):
        eroeffnung.aktenzeichen = "x"


def test_R3_F_001_fall_ist_unveraenderlich_und_hat_keine_klartextfelder() -> None:
    felder = {f for f in Fall.__dataclass_fields__}
    assert felder == {
        "kennung",
        "rechtsregime",
        "fallkategorie",
        "zustand",
        "eroeffnet_am",
        "geschlossen_am",
        "prueffrist_bis",
    }
    assert not {"aktenzeichen", "rechtsgrundlage", "ermittelnde_person"} & felder
    assert not any("schluessel" in f for f in felder)


def test_R3_F_001_zustandsfehler_und_eindeutigkeitsfehler_sind_projektfehler_und_nennen_die_sache() -> (
    None
):
    for klasse in (ZustandsFehler, EindeutigkeitsFehler):
        fehler = klasse("Die Sache.")
        assert isinstance(fehler, R3cosintFehler)
        assert fehler.sache == "Die Sache."
        assert str(fehler) == "Die Sache."


def test_R3_F_001_eroeffnen_und_schliessen_nehmen_alles_nach_der_verbindung_nur_als_schluesselwort() -> (
    None
):
    erwartet: dict[Callable[..., Any], list[str]] = {
        service.eroeffnen: ["eroeffnung", "person_kennung", "uhr"],
        service.schliessen: ["fall_kennung", "person_kennung", "uhr"],
    }
    for funktion, namen in erwartet.items():
        parameter = list(inspect.signature(funktion).parameters.values())
        assert parameter[0].name == "verbindung"
        assert all(p.kind is inspect.Parameter.KEYWORD_ONLY for p in parameter[1:])
        assert [p.name for p in parameter[1:]] == namen
        assert all(p.default is inspect.Parameter.empty for p in parameter)


def test_R3_F_001_die_oeffentliche_schnittstelle_von_fall_nennt_die_vorgesehenen_namen() -> (
    None
):
    assert set(service.__all__) == {
        "Eroeffnung",
        "Fall",
        "Fallzustand",
        "Rechtsregime",
        "eroeffnen",
        "fall_lesen",
        "fall_teilen",
        "ketten_aller_faelle_pruefen",
        "pseudonymisierer_laden",
        "schliessen",
    }


@pytest.mark.parametrize(
    ("start", "monate", "erwartet"),
    [
        (_utc(2026, 1, 31), 1, _utc(2026, 2, 28)),
        (_utc(2028, 1, 31), 1, _utc(2028, 2, 29)),
        (_utc(2026, 8, 31), 12, _utc(2027, 8, 31)),
        (_utc(2026, 2, 28), 12, _utc(2027, 2, 28)),
        (_utc(2028, 2, 29), 12, _utc(2029, 2, 28)),
        (_utc(2026, 3, 10, 14, 5, 6, 654321), 84, _utc(2033, 3, 10, 14, 5, 6, 654321)),
        (_utc(2026, 1, 31), 360, _utc(2056, 1, 31)),
    ],
)
def test_R3_F_001_pruefrist_nach_kalendermonaten_mit_den_startwerten_als_zahlen(
    start: datetime, monate: int, erwartet: datetime
) -> None:
    assert monate_addieren(start, monate) == erwartet


def test_R3_F_001_ein_kalendermonat_ist_nicht_30_tage() -> None:
    ergebnis = monate_addieren(_utc(2026, 1, 31), 1)
    assert ergebnis == _utc(2026, 2, 28)
    assert ergebnis != _utc(2026, 3, 2)


def test_R3_F_001_ein_ueberlauf_der_monate_ist_ein_valueerror_von_core_zeit() -> None:
    with pytest.raises(ValueError):
        monate_addieren(_utc(2026, 1, 31), 96000)
