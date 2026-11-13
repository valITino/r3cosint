"""Handschlag auf der Rückschleife (ADR 0008, Festlegung S2.1, Zeile Tests Einheit; E-S21-11, GK-20).

Das Zertifikat entsteht zur Laufzeit (Fixture tls_zertifikat); nichts davon ist versioniert. Die
Gegenstelle spricht TLS auf 127.0.0.1, die Adresse des Namens ist die Testkonstante und wird über
den Verbindungsweg-Ersatz auf die Gegenstelle abgebildet. Kein IPv6-Socket, keine Verbindung nach aussen.
"""

import importlib.util
import ipaddress
import sys
from collections.abc import Callable
from pathlib import Path
from types import ModuleType
from typing import Any

import pytest

from r3cosint.ausgang.client import Antwort, Antwortgrenzen, Client, Fehlschlag
from r3cosint.ausgang.positivliste import Positivliste


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


async def _versuch(
    zertifikat: Any,
    server_kontext: Any,
    vertrauensanker: Any,
    testpositivliste: Callable[..., Positivliste],
    aufloeser: Any,
    ersatz: Any,
    kontext: Any,
) -> tuple[Any, Any]:
    gegenstelle = await GS.Gegenstelle.starten(
        GS.Antwortskript.treffer(1), tls=server_kontext
    )
    try:
        aufloeser.setzen(
            zertifikat.name, (ipaddress.ip_address(str(GS.TESTKONSTANTE)),)
        )
        liste = testpositivliste(
            [
                {
                    "kennung": "test.tls",
                    "schema": "https",
                    "rechnername": zertifikat.name,
                    "anschluss": gegenstelle.anschluss,
                }
            ]
        )
        client = Client(
            positivliste=liste,
            aufloeser=aufloeser,
            vertrauensanker=vertrauensanker,
            verbindungsweg=ersatz,
        )
        rueckgabe = await client.anfragen(
            kontext,
            methode="GET",
            url=f"https://{zertifikat.name}:{gegenstelle.anschluss}/p",
            grenzen=GRENZEN,
        )
        return rueckgabe, gegenstelle
    finally:
        await gegenstelle.beenden()


async def test_R3_F_028_handschlag_mit_dem_laufzeit_zertifikat(
    tls_zertifikat: Any,
    testpositivliste: Callable[..., Positivliste],
    aufloeser_steuerbar: Any,
    verbindungsweg_ersatz: Any,
    spurkontext_attrappe: Any,
    netzwaechter: Any,
) -> None:
    """(i) Anker mit dem Zertifikat: Antwort 200, SNI und Host gleich dem Namen."""
    rueckgabe, g = await _versuch(
        tls_zertifikat,
        tls_zertifikat.server_kontext,
        tls_zertifikat.client_kontext,
        testpositivliste,
        aufloeser_steuerbar,
        verbindungsweg_ersatz,
        spurkontext_attrappe,
    )
    assert isinstance(rueckgabe, Antwort) and rueckgabe.status == 200
    assert [e.ergebnis for e in spurkontext_attrappe.eingaben] == [
        "zugelassen",
        "beantwortet",
    ]
    assert g.sni_namen == [tls_zertifikat.name]
    assert g.anfragen[0].host.rsplit(":", 1)[0] == tls_zertifikat.name
    assert verbindungsweg_ersatz.aufrufe[0].name_oder_adresse == tls_zertifikat.name


async def test_R3_F_028_falscher_name_im_zertifikat_scheitert_mit_tls(
    tls_zertifikat: Any,
    testpositivliste: Callable[..., Positivliste],
    aufloeser_steuerbar: Any,
    verbindungsweg_ersatz: Any,
    spurkontext_attrappe: Any,
    netzwaechter: Any,
) -> None:
    """(ii) Das Zertifikat gilt für einen anderen Namen (beide sind Anker): nur der Name trennt (M47)."""
    rueckgabe, g = await _versuch(
        tls_zertifikat,
        tls_zertifikat.server_kontext_anderer,
        tls_zertifikat.client_kontext_beide,
        testpositivliste,
        aufloeser_steuerbar,
        verbindungsweg_ersatz,
        spurkontext_attrappe,
    )
    assert isinstance(rueckgabe, Fehlschlag) and rueckgabe.fehlerart == "tls"
    assert [e.ergebnis for e in spurkontext_attrappe.eingaben] == [
        "zugelassen",
        "verbindung_fehlgeschlagen",
    ]
    assert g.anfragen == []


async def test_R3_F_028_ohne_vertrauensanker_gilt_certifi_und_scheitert_mit_tls(
    tls_zertifikat: Any,
    testpositivliste: Callable[..., Positivliste],
    aufloeser_steuerbar: Any,
    verbindungsweg_ersatz: Any,
    spurkontext_attrappe: Any,
    netzwaechter: Any,
) -> None:
    """(iii) Das selbst signierte Zertifikat steht nicht in den Wurzeln aus certifi."""
    rueckgabe, g = await _versuch(
        tls_zertifikat,
        tls_zertifikat.server_kontext,
        None,
        testpositivliste,
        aufloeser_steuerbar,
        verbindungsweg_ersatz,
        spurkontext_attrappe,
    )
    assert isinstance(rueckgabe, Fehlschlag) and rueckgabe.fehlerart == "tls"
    assert g.anfragen == []
