"""Architekturtest: Vorrat der Eintragstypen, Eingaben und Klartextfelder von spur (ADR 0008, Festlegung S2.1; R3-F-015, R3-F-011).

Der Vorrat der Revisionen gleicht spur.kette.Eintragstyp; jede Eingabe gehört zu genau einem
Eintragstyp, und die Typen einer Folgeeinheit haben noch keine Eingabe (jede Folgeeinheit streicht
ihren Typ aus der Liste); die Klartextfelder des Verbindungsversuchs tragen repr=False.
"""

import re
import typing
from pathlib import Path

from r3cosint.spur import payload
from r3cosint.spur.kette import SPUR_JE_EINTRAGSTYP, Eintragstyp, Spur
from r3cosint.spur.service import _EINTRAGSTYP_JE_EINGABE

SQL = Path(__file__).resolve().parents[2] / "migrationen" / "sql"
# Typen ohne Eingabeklasse in S2.1 mit der Einheit, die sie liefert (Festlegung S2.1, Zeile Protokoll).
FOLGEEINHEIT = {
    Eintragstyp.ABWEISUNG: "S2.2",
    Eintragstyp.ABFRAGE: "S2.2",
    Eintragstyp.NEGATIVBEFUND: "S2.4",
}


def _vorrat(datei: str, bedingung: str) -> set[str]:
    sql = (SQL / datei).read_text(encoding="utf-8")
    treffer = re.search(
        rf"{bedingung}\s+CHECK\s*\(eintragstyp\s+IN\s*\(([^)]*)\)", sql, re.DOTALL
    )
    assert treffer is not None, (datei, bedingung)
    return set(re.findall(r"'([a-z_]+)'", treffer.group(1)))


def test_R3_F_015_vorrat_der_revisionen_gleich_dem_vorrat_in_spur_kette() -> None:
    arbeit = _vorrat("0006_ausgang.sql", "arbeitsspur_eintragstyp_vorrat")
    ermittlung = _vorrat("0003_spur.sql", "ermittlungsspur_eintragstyp_vorrat")
    assert arbeit | ermittlung == {typ.value for typ in Eintragstyp}
    assert not arbeit & ermittlung
    for typ in Eintragstyp:
        spur = Spur.ARBEITSSPUR if typ.value in arbeit else Spur.ERMITTLUNGSSPUR
        assert SPUR_JE_EINTRAGSTYP[typ] is spur


def test_R3_F_015_eingaben_gleich_eintragstyp_ohne_die_typen_der_folgeeinheiten() -> (
    None
):
    eingaben = set(typing.get_args(payload.Eingabe))
    assert set(_EINTRAGSTYP_JE_EINGABE) == eingaben
    zugeordnet = set(_EINTRAGSTYP_JE_EINGABE.values())
    assert len(zugeordnet) == len(eingaben), "ein Eintragstyp je Eingabe"
    assert zugeordnet == set(Eintragstyp) - set(FOLGEEINHEIT)
    assert Eintragstyp.VERBINDUNGSVERSUCH in zugeordnet


def test_R3_F_015_rueckweg_von_0006_nennt_dieselben_vier_typen() -> None:
    rueckweg = (SQL / "0006_ausgang_rueckweg.sql").read_text(encoding="utf-8")
    liste = re.search(r"eintragstyp IN \(([^)]*)\)", rueckweg)
    assert liste is not None
    nennt = set(re.findall(r"'([a-z_]+)'", liste.group(1)))
    assert nennt == {t.value for t in FOLGEEINHEIT} | {"verbindungsversuch"}


def test_R3_F_011_klartextfelder_des_verbindungsversuchs_tragen_repr_false() -> None:
    felder = payload.Verbindungsversuch.model_fields
    klartext = {"ziel", "adresse", "ausgangsziel"}
    assert len(felder) == 18
    for name, feld in felder.items():
        assert feld.repr is (name not in klartext), name
