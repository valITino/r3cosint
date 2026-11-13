"""ausgang mit Datenbank (ADR 0008, Festlegung S2.1, Zeile Tests Integration; R3-F-015, R3-F-028).

SpurkontextDatenbank aus der Fixture spurkontext (Fall über fall.service eröffnet), Client gegen die
Testgegenstelle mit Literal-Eintrag der Rückschleife. Alle Werte sind erfunden (5.15).
"""

import dataclasses
import importlib.util
import json
import sys
from collections.abc import Callable
from pathlib import Path
from types import ModuleType
from typing import Any

import pytest
from sqlalchemy import text

from r3cosint.ausgang.client import (
    Abweisung,
    Antwort,
    Antwortgrenzen,
    Client,
    SpurkontextDatenbank,
)
from r3cosint.ausgang.positivliste import Positivliste
from r3cosint.core.fehler import EingabeFehler
from r3cosint.core.kennung import neue_kennung
from r3cosint.spur.service import Spur, kette_pruefen, kette_pruefen_datenbank


def _gegenstelle_laden() -> ModuleType:
    """Lädt tests/gegenstelle.py über den Dateipfad; eine geladene Instanz wird geteilt."""
    name = "r3cosint_gegenstelle"
    vorhanden = sys.modules.get(name)
    if vorhanden is not None:
        return vorhanden
    pfad = Path(__file__).resolve().parents[1] / "gegenstelle.py"
    spec = importlib.util.spec_from_file_location(name, pfad)
    assert spec is not None and spec.loader is not None
    modul = importlib.util.module_from_spec(spec)
    sys.modules[name] = modul
    spec.loader.exec_module(modul)
    return modul


pytestmark = pytest.mark.anyio

GS: Any = _gegenstelle_laden()
GRENZEN = Antwortgrenzen(antwortgroesse_bytes=65536, frist_sekunden=10)


def _eintrag(g: Any, kennung: str) -> dict[str, object]:
    return {
        "kennung": kennung,
        "schema": "http",
        "adresse": "127.0.0.1",
        "anschluss": g.anschluss,
    }


def nutzlast(zeile: Any) -> dict[str, Any]:
    roh = zeile.payload
    wert = json.loads(roh) if isinstance(roh, (str, bytes)) else roh
    assert isinstance(wert, dict)
    return wert


async def _eintraege(kontext: SpurkontextDatenbank) -> list[Any]:
    zeilen = await kontext.verbindung.execute(
        text(
            "SELECT eintragstyp, kennzeichnung, person_kennung, payload "
            "FROM r3cosint.arbeitsspur WHERE fall_kennung = :f "
            "AND eintragstyp = 'verbindungsversuch' ORDER BY position"
        ),
        {"f": kontext.fall_kennung},
    )
    return list(zeilen)


async def test_R3_F_015_eintraege_in_der_arbeitsspur_und_ketten_unversehrt(
    spurkontext: SpurkontextDatenbank,
    testpositivliste: Callable[..., Positivliste],
    aufloeser_steuerbar: Any,
) -> None:
    folge = [
        GS.Antwortskript.weiterleitung(302, "/weiter/"),
        GS.Antwortskript.treffer(1),
    ]
    gegenstelle = await GS.Gegenstelle.starten(folge)
    try:
        client = Client(
            positivliste=testpositivliste([_eintrag(gegenstelle, "test.ziel")]),
            aufloeser=aufloeser_steuerbar,
        )
        rueckgabe = await client.anfragen(
            spurkontext,
            methode="GET",
            url=f"http://127.0.0.1:{gegenstelle.anschluss}/p?q=1",
            grenzen=GRENZEN,
        )
        assert isinstance(rueckgabe, Antwort) and rueckgabe.schritt == 1
        # mehrere Einträge eines Weiterleitungslaufs in derselben Transaktion
        assert spurkontext.verbindung.in_transaction()
        zeilen = await _eintraege(spurkontext)
        assert [z.kennzeichnung for z in zeilen] == ["quellenaussage"] * 4
        assert {z.person_kennung for z in zeilen} == {spurkontext.person_kennung}
        assert [nutzlast(z)["ergebnis"] for z in zeilen] == [
            "zugelassen",
            "beantwortet",
            "zugelassen",
            "beantwortet",
        ]
        assert [nutzlast(z)["schritt"] for z in zeilen] == [0, 0, 1, 1]
        assert "127.0.0.1" not in str([nutzlast(z) for z in zeilen])
        anwendungsweg = await kette_pruefen(
            spurkontext.verbindung, spurkontext.fall_kennung
        )
        datenbankweg = await kette_pruefen_datenbank(
            spurkontext.verbindung, spurkontext.fall_kennung
        )
        for weg in (anwendungsweg, datenbankweg):
            assert all(weg[spur].unversehrt for spur in Spur)
        assert anwendungsweg == datenbankweg
    finally:
        await gegenstelle.beenden()


async def test_R3_F_015_abweisung_wird_in_der_transaktion_protokolliert(
    spurkontext: SpurkontextDatenbank,
    testpositivliste: Callable[..., Positivliste],
    aufloeser_steuerbar: Any,
) -> None:
    client = Client(positivliste=testpositivliste([]), aufloeser=aufloeser_steuerbar)
    rueckgabe = await client.anfragen(
        spurkontext, methode="GET", url="http://127.0.0.1:9/", grenzen=GRENZEN
    )
    assert isinstance(rueckgabe, Abweisung)
    zeilen = await _eintraege(spurkontext)
    assert [nutzlast(z)["ergebnis"] for z in zeilen] == ["nicht_in_positivliste"]


async def test_R3_F_015_unbekannter_fall_ohne_eintrag_aufloesung_und_verbindung(
    spurkontext: SpurkontextDatenbank,
    testpositivliste: Callable[..., Positivliste],
    aufloeser_steuerbar: Any,
) -> None:
    unbekannt = dataclasses.replace(spurkontext, fall_kennung=neue_kennung())
    gegenstelle = await GS.Gegenstelle.starten(GS.Antwortskript.treffer(1))
    try:
        client = Client(
            positivliste=testpositivliste([_eintrag(gegenstelle, "test.ziel")]),
            aufloeser=aufloeser_steuerbar,
        )
        with pytest.raises(EingabeFehler) as fehler:
            await client.anfragen(
                unbekannt,
                methode="GET",
                url=f"http://127.0.0.1:{gegenstelle.anschluss}/",
                grenzen=GRENZEN,
            )
        assert fehler.value.__cause__ is None and fehler.value.__context__ is None
        assert gegenstelle.verbindungen == 0 and not aufloeser_steuerbar.zaehler
        assert await _eintraege(spurkontext) == []
    finally:
        await gegenstelle.beenden()


@pytest.mark.anyio
async def test_R3_F_015_spurkontext_repr_ohne_verbindung_und_pseudonymisierer(
    spurkontext: SpurkontextDatenbank,
) -> None:
    darstellung = repr(spurkontext)
    assert "verbindung=" not in darstellung and "pseudonymisierer=" not in darstellung
