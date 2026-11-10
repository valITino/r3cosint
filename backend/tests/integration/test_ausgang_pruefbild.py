"""Prüfbild der Arbeitsspur von ausgang (Bereitstellung für den Prüfbericht D16, Festlegung S2.1).

Der Test hinterlässt in der Arbeitsspur eines eröffneten Falls alle acht Ergebnisse, eine Kette mit
N Weiterleitungen (bis zur Antwort) und eine mit kette_zu_lang; er prüft die beiden Rechenwege der
Kettenprüfung und die Bytes der geladenen positivliste.toml gegen listenstand. Wer die Spur selbst
untersuchen will, ruft diesen Test mit einer Ergänzung am Ende auf (die Fixtures spurkontext,
fallschluessel_lesen und testpositivliste liefern Verbindung, synthetischen Fallschlüssel und die
Datei unter tmp_path). Alle Werte sind erfunden (5.15).
"""

import hashlib
import importlib.util
import ipaddress
import json
import sys
from collections.abc import Callable
from pathlib import Path
from types import ModuleType
from typing import Any

import pytest
from sqlalchemy import text

from r3cosint.ausgang.client import Antwortgrenzen, Client
from r3cosint.ausgang.positivliste import Positivliste
from r3cosint.spur.service import Spur, kette_pruefen, kette_pruefen_datenbank

pytestmark = pytest.mark.anyio


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


GS: Any = _gegenstelle_laden()
SKRIPT: Any = GS.Antwortskript
GRENZEN = Antwortgrenzen(antwortgroesse_bytes=65536, frist_sekunden=10)


async def test_R3_F_015_arbeitsspur_mit_allen_acht_ergebnissen_und_beiden_ketten(
    spurkontext: Any,
    aufloeser_steuerbar: Any,
    verbindungsweg_ersatz: Any,
    fallschluessel_lesen: Any,
    testpositivliste: Callable[..., Positivliste],
    tmp_path: Path,
    netzwaechter: Any,
) -> None:
    kette = [SKRIPT.weiterleitung(302, f"/w{i}/") for i in range(2)] + [
        SKRIPT.treffer(1)
    ]
    zu_lang = [SKRIPT.weiterleitung(302, f"/z{i}/") for i in range(3)]
    ungueltig = SKRIPT.status(600)
    gestartet = [await GS.Gegenstelle.starten(s) for s in (kette, zu_lang, ungueltig)]
    try:
        k, z, u = gestartet
        eintraege = [
            {
                "kennung": f"test.{n}",
                "schema": "http",
                "adresse": "127.0.0.1",
                "anschluss": g.anschluss,
            }
            for n, g in (("kette", k), ("lang", z), ("ungueltig", u))
        ]
        eintraege.append(
            {
                "kennung": "test.name",
                "schema": "http",
                "rechnername": "gut.test",
                "anschluss": 80,
            }
        )
        liste = testpositivliste(eintraege, hoechstzahl=2)
        client = Client(
            positivliste=liste,
            aufloeser=aufloeser_steuerbar,
            verbindungsweg=verbindungsweg_ersatz,
        )
        ziele = [
            f"http://127.0.0.1:{k.anschluss}/start",  # N = 2 Weiterleitungen, dann Antwort
            f"http://127.0.0.1:{z.anschluss}/start",  # kette_zu_lang
            f"http://127.0.0.1:{u.anschluss}/start",  # verbindung_fehlgeschlagen
            "http://127.0.0.2:81/",  # nicht_in_positivliste
            "ftp://127.0.0.1/",  # url_nicht_auswertbar
            "http://gut.test/",  # aufloesung_fehlgeschlagen (nichts gesetzt)
            "http://gut.test:80/zwei",  # bereich_nicht_oeffentlich (nach setzen)
        ]
        for nummer, ziel in enumerate(ziele):
            if nummer == 6:
                aufloeser_steuerbar.setzen(
                    "gut.test", (ipaddress.ip_address("10.0.0.1"),)
                )
            await client.anfragen(spurkontext, methode="GET", url=ziel, grenzen=GRENZEN)
        zeilen = await spurkontext.verbindung.execute(
            text(
                "SELECT payload FROM r3cosint.arbeitsspur WHERE fall_kennung = :f "
                "AND eintragstyp = 'verbindungsversuch' ORDER BY position"
            ),
            {"f": spurkontext.fall_kennung},
        )
        nutzlasten = [
            json.loads(r.payload) if isinstance(r.payload, (str, bytes)) else r.payload
            for r in zeilen
        ]
        assert {p["ergebnis"] for p in nutzlasten} == {
            "zugelassen",
            "beantwortet",
            "nicht_in_positivliste",
            "bereich_nicht_oeffentlich",
            "aufloesung_fehlgeschlagen",
            "kette_zu_lang",
            "verbindung_fehlgeschlagen",
            "url_nicht_auswertbar",
        }
        assert max(p["schritt"] for p in nutzlasten) == 3, "kette_zu_lang bei N + 1 = 3"
        assert len({p["versuch_kennung"] for p in nutzlasten}) == len(ziele)
        assert {p["listenstand"] for p in nutzlasten} == {liste.listenstand}
        # Bytes der geladenen Datei und synthetischer Fallschlüssel
        datei = tmp_path / "positivliste-1.toml"
        assert hashlib.sha256(datei.read_bytes()).hexdigest() == liste.listenstand
        assert len(await fallschluessel_lesen(spurkontext.fall_kennung)) == 32
        for weg in (
            await kette_pruefen(spurkontext.verbindung, spurkontext.fall_kennung),
            await kette_pruefen_datenbank(
                spurkontext.verbindung, spurkontext.fall_kennung
            ),
        ):
            assert all(weg[spur].unversehrt for spur in Spur)
    finally:
        for g in gestartet:
            await g.beenden()
