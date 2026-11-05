"""Einheitstest: spur.kette ohne Datenbank (ADR 0007, Nr. 16 bis 19, Festlegung S1.2; R3-F-008, R3-F-012).

Die Prüfvektoren stehen mit ausgeschriebenen Bytes und dem Erwartungswert in
tests/vektoren/pruefvektoren.json; die Erwartungswerte sind mit sha256sum über genau diese
Bytes ermittelt, nicht mit serialisieren. Dieselbe Datei prüft die Integrationsstufe gegen die
SQL-Funktionen (zweiter Rechenweg).
"""

import hashlib
import json
from dataclasses import replace
from datetime import UTC, datetime, timedelta, timezone
from pathlib import Path
from typing import Any
from uuid import UUID
from zoneinfo import ZoneInfo

import pytest

from r3cosint.spur.kette import (
    Befund,
    Bruchgrund,
    Eintrag,
    Eintragstyp,
    Kennzeichnung,
    Kettenkopf,
    Spur,
    anfangswert,
    pruefen,
    pruefsumme,
    serialisieren,
    zeitpunkt_text,
)

VEKTOREN: dict[str, Any] = json.loads(
    (Path(__file__).resolve().parents[1] / "vektoren" / "pruefvektoren.json").read_text(
        encoding="utf-8"
    )
)
FALL = UUID(VEKTOREN["fall_kennung"])
NULL_SUMME = "0" * 64


def _aus_vektor(v: dict[str, Any]) -> Eintrag:
    return Eintrag(
        spur=Spur(v["spur"]),
        kennung=UUID(v["kennung"]),
        fall_kennung=UUID(v["fall_kennung"]),
        position=v["position"],
        zeitpunkt=datetime.fromisoformat(v["zeitpunkt"]),
        person_kennung=v["person_kennung"],
        eintragstyp=Eintragstyp(v["eintragstyp"]),
        kennzeichnung=Kennzeichnung(v["kennzeichnung"]),
        payload=v["payload"],
        vorgaenger_pruefsumme=v["vorgaenger_pruefsumme"],
        pruefsumme="",
    )


@pytest.mark.parametrize("spur", list(Spur))
def test_R3_F_008_anfangswert_ist_der_ausgeschriebene_vektor_je_spur(
    spur: Spur,
) -> None:
    # Die Fallkennung wird in Grossbuchstaben übergeben und klein serialisiert.
    grossgeschrieben = UUID(VEKTOREN["fall_kennung"].upper())
    assert anfangswert(spur, grossgeschrieben) == VEKTOREN["anfangswerte"][spur.value]


def test_R3_F_008_die_anfangswerte_der_beiden_spuren_eines_falls_sind_verschieden() -> (
    None
):
    assert anfangswert(Spur.ARBEITSSPUR, FALL) != anfangswert(
        Spur.ERMITTLUNGSSPUR, FALL
    )
    assert anfangswert(Spur.ARBEITSSPUR, FALL) != anfangswert(
        Spur.ARBEITSSPUR, UUID(int=1)
    )


@pytest.mark.parametrize("vektor", VEKTOREN["eintraege"], ids=lambda v: v["name"])
def test_R3_F_008_pruefsumme_und_bytes_gleichen_dem_ausgeschriebenen_vektor(
    vektor: dict[str, Any],
) -> None:
    eintrag = _aus_vektor(vektor)
    assert serialisieren(eintrag).hex() == vektor["roh_hex"]
    assert pruefsumme(eintrag) == vektor["erwartet"]
    assert (
        pruefsumme(eintrag)
        == hashlib.sha256(bytes.fromhex(vektor["roh_hex"])).hexdigest()
    )


def test_R3_F_008_vorkomponiertes_und_zerlegtes_zeichen_geben_verschiedene_pruefsummen() -> (
    None
):
    namen = {v["name"]: v["erwartet"] for v in VEKTOREN["eintraege"]}
    assert namen["nicht_ascii_vorkomponiert"] != namen["nicht_ascii_zerlegt"]


def test_R3_F_008_die_laenge_zaehlt_bytes_nicht_zeichen() -> None:
    vektor = next(v for v in VEKTOREN["eintraege"] if v["name"] == "vier_byte_zeichen")
    roh = bytes.fromhex(vektor["roh_hex"])
    # '{"a":"' + 4 Bytes + '"}' sind 12 Bytes bei 9 Zeichen.
    assert b"\n12:" + vektor["payload"].encode("utf-8") + b"\n" in roh


def test_R3_F_008_verschiebung_zwischen_feldern_aendert_die_pruefsumme() -> None:
    basis = _aus_vektor(VEKTOREN["eintraege"][0])
    a = replace(basis, person_kennung="ab", payload="c")
    b = replace(basis, person_kennung="a", payload="bc")
    assert pruefsumme(a) != pruefsumme(b)


def test_R3_F_008_naive_zeit_wird_abgewiesen() -> None:
    ohne_zone = datetime(2026, 1, 1)  # noqa: DTZ001
    naiv = replace(_aus_vektor(VEKTOREN["eintraege"][0]), zeitpunkt=ohne_zone)
    with pytest.raises(ValueError, match="zeitbewusst"):
        serialisieren(naiv)
    with pytest.raises(ValueError, match="zeitbewusst"):
        zeitpunkt_text(datetime(2026, 1, 1))  # noqa: DTZ001


@pytest.mark.parametrize(
    "zeit",
    [
        datetime(1999, 12, 31, 23, 59, 59, 999999, tzinfo=UTC),
        datetime(1, 1, 1, tzinfo=UTC),
        datetime(9999, 1, 1, tzinfo=UTC),
        datetime.max.replace(tzinfo=UTC),
        datetime(9999, 12, 31, 23, tzinfo=timezone(timedelta(hours=-12))),
    ],
    ids=["vor_2000", "jahr_1", "9999_01_01", "datetime_max", "ueberlauf_nach_utc"],
)
def test_R3_F_008_zeit_ausserhalb_des_bereichs_wird_abgewiesen(zeit: datetime) -> None:
    with pytest.raises(ValueError, match="ausserhalb"):
        zeitpunkt_text(zeit)


def test_R3_F_008_zeit_text_unterscheidet_die_beiden_stunden_der_umstellung() -> None:
    zuerich = ZoneInfo("Europe/Zurich")
    erste = datetime(2026, 10, 25, 2, 30, tzinfo=zuerich, fold=0)
    zweite = datetime(2026, 10, 25, 2, 30, tzinfo=zuerich, fold=1)
    assert zeitpunkt_text(erste) == "2026-10-25T00:30:00.000000Z"
    assert zeitpunkt_text(zweite) == "2026-10-25T01:30:00.000000Z"


def test_R3_F_008_zeit_text_hat_ein_vierstelliges_jahr_und_sechs_stellen() -> None:
    assert (
        zeitpunkt_text(datetime(2000, 1, 1, tzinfo=UTC))
        == "2000-01-01T00:00:00.000000Z"
    )
    assert (
        zeitpunkt_text(datetime(9998, 12, 31, 23, 59, 59, 999999, tzinfo=UTC))
        == "9998-12-31T23:59:59.999999Z"
    )


# --- Prüfung (R3-F-012) ---------------------------------------------------------------------


def _kette(
    anzahl: int, spur: Spur = Spur.ARBEITSSPUR, fall: UUID = FALL
) -> tuple[list[Eintrag], Kettenkopf]:
    eintraege: list[Eintrag] = []
    vorgaenger = anfangswert(spur, fall)
    for nr in range(1, anzahl + 1):
        offen = Eintrag(
            spur=spur,
            kennung=UUID(int=nr),
            fall_kennung=fall,
            position=nr,
            zeitpunkt=datetime(2026, 1, 15, 8, 30, nr, tzinfo=UTC),
            person_kennung="test.ermittlung",
            eintragstyp=Eintragstyp.FALL_EROEFFNET
            if spur is Spur.ARBEITSSPUR
            else Eintragstyp.ENTITAET,
            kennzeichnung=Kennzeichnung.QUELLENAUSSAGE,
            payload=f'{{"nr":"{nr}"}}',
            vorgaenger_pruefsumme=vorgaenger,
            pruefsumme="",
        )
        eintrag = replace(offen, pruefsumme=pruefsumme(offen))
        eintraege.append(eintrag)
        vorgaenger = eintrag.pruefsumme
    kopf = Kettenkopf(
        spur=spur, fall_kennung=fall, position=anzahl, pruefsumme=vorgaenger
    )
    return eintraege, kopf


def _nachgerechnet(eintrag: Eintrag, **aenderung: Any) -> Eintrag:
    neu = replace(eintrag, **aenderung)
    return replace(neu, pruefsumme=pruefsumme(neu))


def _pruefen(eintraege: list[Eintrag], kopf: Kettenkopf | None) -> Befund:
    return pruefen(Spur.ARBEITSSPUR, FALL, eintraege, kopf)


def _bruch(befund: Befund, grund: Bruchgrund, position: int, anzahl: int) -> None:
    assert befund.unversehrt is False
    assert befund.grund is grund
    assert befund.position == position
    assert befund.anzahl == anzahl


@pytest.mark.parametrize("spur", list(Spur))
def test_R3_F_012_unversehrte_folge_meldet_anzahl_und_letzte_pruefsumme(
    spur: Spur,
) -> None:
    eintraege, kopf = _kette(3, spur)
    befund = pruefen(spur, FALL, eintraege, kopf)
    assert befund.unversehrt is True
    assert (befund.anzahl, befund.position, befund.grund) == (3, None, None)
    assert befund.letzte_pruefsumme == eintraege[-1].pruefsumme
    assert befund.kopf_position == 3
    assert (befund.spur, befund.fall_kennung) == (spur, FALL)


def test_R3_F_012_leerer_bestand_mit_kopf_in_position_0_ist_unversehrt() -> None:
    kopf = Kettenkopf(Spur.ARBEITSSPUR, FALL, 0, anfangswert(Spur.ARBEITSSPUR, FALL))
    befund = _pruefen([], kopf)
    assert befund.unversehrt is True
    assert befund.anzahl == 0
    assert befund.letzte_pruefsumme == kopf.pruefsumme


def test_R3_F_012_aenderung_ohne_nachrechnen_ergibt_inhalt_geaendert_an_dieser_position() -> (
    None
):
    eintraege, kopf = _kette(4)
    eintraege[1] = replace(eintraege[1], payload='{"nr":"x"}')
    befund = _pruefen(eintraege, kopf)
    _bruch(befund, Bruchgrund.INHALT_GEAENDERT, 2, 1)
    assert befund.letzte_pruefsumme == eintraege[0].pruefsumme


def test_R3_F_012_entfernen_in_der_mitte_ergibt_luecke_an_der_entfernten_position() -> (
    None
):
    eintraege, kopf = _kette(4)
    del eintraege[1]
    _bruch(_pruefen(eintraege, kopf), Bruchgrund.LUECKE, 2, 1)


def test_R3_F_012_doppelte_position_ergibt_luecke() -> None:
    eintraege, kopf = _kette(3)
    eintraege.insert(1, eintraege[0])
    _bruch(_pruefen(eintraege, kopf), Bruchgrund.LUECKE, 2, 1)


def test_R3_F_012_entfernen_des_letzten_eintrags_ergibt_kopf_abweichend_an_seiner_position() -> (
    None
):
    eintraege, kopf = _kette(4)
    del eintraege[-1]
    befund = _pruefen(eintraege, kopf)
    _bruch(befund, Bruchgrund.KOPF_ABWEICHEND, 4, 3)
    assert befund.kopf_position == 4


def test_R3_F_012_abschneiden_von_zwei_eintraegen_nennt_die_erste_fehlende_position() -> (
    None
):
    eintraege, kopf = _kette(5)
    del eintraege[-2:]
    befund = _pruefen(eintraege, kopf)
    _bruch(befund, Bruchgrund.KOPF_ABWEICHEND, 4, 3)
    assert befund.kopf_position == 5


def test_R3_F_012_ein_eintrag_hinter_dem_kopf_ergibt_kopf_abweichend_an_dessen_position() -> (
    None
):
    eintraege, kopf = _kette(4)
    kopf_vorher = Kettenkopf(kopf.spur, kopf.fall_kennung, 3, eintraege[2].pruefsumme)
    befund = _pruefen(eintraege, kopf_vorher)
    _bruch(befund, Bruchgrund.KOPF_ABWEICHEND, 4, 3)
    assert befund.letzte_pruefsumme == eintraege[2].pruefsumme


def test_R3_F_012_fehlt_der_kopf_ist_der_bruch_an_position_0() -> None:
    eintraege, _ = _kette(2)
    befund = _pruefen(eintraege, None)
    _bruch(befund, Bruchgrund.KOPF_ABWEICHEND, 0, 2)
    assert befund.kopf_position is None


def test_R3_F_012_falsche_pruefsumme_im_kopf_ergibt_kopf_abweichend_am_letzten_eintrag() -> (
    None
):
    eintraege, kopf = _kette(3)
    falsch = replace(kopf, pruefsumme=NULL_SUMME)
    befund = _pruefen(eintraege, falsch)
    _bruch(befund, Bruchgrund.KOPF_ABWEICHEND, 3, 2)
    assert befund.letzte_pruefsumme == eintraege[1].pruefsumme


def test_R3_F_012_kopf_mit_falscher_pruefsumme_bei_leerem_bestand_liegt_an_position_0() -> (
    None
):
    kopf = Kettenkopf(Spur.ARBEITSSPUR, FALL, 0, NULL_SUMME)
    befund = _pruefen([], kopf)
    _bruch(befund, Bruchgrund.KOPF_ABWEICHEND, 0, 0)
    assert befund.letzte_pruefsumme == anfangswert(Spur.ARBEITSSPUR, FALL)


def test_R3_F_012_nachgerechnete_aenderung_in_der_mitte_bricht_am_folgeglied() -> None:
    eintraege, kopf = _kette(4)
    eintraege[1] = _nachgerechnet(eintraege[1], payload='{"nr":"x"}')
    _bruch(_pruefen(eintraege, kopf), Bruchgrund.VORGAENGER_FALSCH, 3, 2)


def test_R3_F_012_nachgerechnete_aenderung_am_ende_bricht_am_kopf() -> None:
    eintraege, kopf = _kette(3)
    eintraege[2] = _nachgerechnet(eintraege[2], payload='{"nr":"x"}')
    _bruch(_pruefen(eintraege, kopf), Bruchgrund.KOPF_ABWEICHEND, 3, 2)


def test_R3_F_008_nachrechnen_bis_zum_ende_samt_kopf_ist_nicht_erkennbar() -> None:
    # Grenze GS-2: wer alle Prüfsummen und den Kopf neu rechnet, bleibt unentdeckt.
    eintraege, _ = _kette(3)
    vorgaenger = anfangswert(Spur.ARBEITSSPUR, FALL)
    neu: list[Eintrag] = []
    for eintrag in eintraege:
        geaendert = _nachgerechnet(
            eintrag, payload='{"nr":"x"}', vorgaenger_pruefsumme=vorgaenger
        )
        neu.append(geaendert)
        vorgaenger = geaendert.pruefsumme
    kopf = Kettenkopf(Spur.ARBEITSSPUR, FALL, 3, vorgaenger)
    assert _pruefen(neu, kopf).unversehrt is True


def test_R3_F_012_vorrang_luecke_vor_inhalt_und_inhalt_vor_vorgaenger() -> None:
    eintraege, kopf = _kette(2)
    beides = replace(eintraege[0], position=2, payload='{"nr":"x"}')
    _bruch(_pruefen([beides], kopf), Bruchgrund.LUECKE, 1, 0)
    inhalt_und_vorgaenger = replace(
        eintraege[0], payload='{"nr":"x"}', vorgaenger_pruefsumme=NULL_SUMME
    )
    _bruch(_pruefen([inhalt_und_vorgaenger], kopf), Bruchgrund.INHALT_GEAENDERT, 1, 0)
    nur_vorgaenger = _nachgerechnet(eintraege[0], vorgaenger_pruefsumme=NULL_SUMME)
    _bruch(_pruefen([nur_vorgaenger], kopf), Bruchgrund.VORGAENGER_FALSCH, 1, 0)


def test_R3_F_012_eine_fremde_kette_bricht_an_position_1() -> None:
    fremd, _ = _kette(2, fall=UUID(int=99))
    kopf = Kettenkopf(Spur.ARBEITSSPUR, FALL, 2, fremd[-1].pruefsumme)
    _bruch(_pruefen(fremd, kopf), Bruchgrund.VORGAENGER_FALSCH, 1, 0)


def test_R3_F_012_ein_nicht_serialisierbarer_eintrag_gilt_als_geaendert() -> None:
    eintraege, kopf = _kette(2)
    eintraege[0] = replace(eintraege[0], zeitpunkt=datetime(1999, 1, 1, tzinfo=UTC))
    _bruch(_pruefen(eintraege, kopf), Bruchgrund.INHALT_GEAENDERT, 1, 0)


def test_R3_F_012_pruefen_sortiert_nicht() -> None:
    eintraege, kopf = _kette(3)
    eintraege.reverse()
    _bruch(_pruefen(eintraege, kopf), Bruchgrund.LUECKE, 1, 0)


def test_R3_F_008_befund_und_eintrag_sind_unveraenderlich() -> None:
    eintraege, kopf = _kette(1)
    befund = _pruefen(eintraege, kopf)
    with pytest.raises(AttributeError):
        befund.anzahl = 5  # type: ignore[misc]  # frozen: der Fall selbst


def test_R3_F_012_negative_kopfposition_gibt_anzahl_0_und_keinen_negativen_index() -> (
    None
):
    eintraege, kopf = _kette(3)
    negativ = replace(kopf, position=-3)
    befund = _pruefen(eintraege, negativ)
    _bruch(befund, Bruchgrund.KOPF_ABWEICHEND, -2, 0)
    assert befund.letzte_pruefsumme == anfangswert(Spur.ARBEITSSPUR, FALL)
    assert befund.kopf_position == -3
