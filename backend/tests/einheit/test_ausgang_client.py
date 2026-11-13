"""Einheitstests von ausgang.client (ADR 0008, Festlegung S2.1, Zeile Tests Einheit; R3-F-015, R3-F-028).

Mit spurkontext_attrappe und der Testgegenstelle, ohne Datenbank. Alle Werte sind erfunden (5.15);
Ziele sind die Rückschleife, Namen unter .test und die Testkonstante, die nie kontaktiert wird.
"""

import importlib.util
import inspect
import ipaddress
import logging
import ssl
import sys
import time
from collections.abc import AsyncIterator, Callable
from contextlib import asynccontextmanager
from pathlib import Path
from types import ModuleType
from typing import Any, Literal, get_args, get_type_hints

import httpcore
import httpx
import pytest

from r3cosint.ausgang import client as modul
from r3cosint.ausgang.aufloesung import AufloesungsFehler
from r3cosint.ausgang.client import (
    Abweisung,
    Antwort,
    Antwortgrenzen,
    Client,
    Fehlschlag,
    GebundenerNetzanschluss,
    GebundenerVerbindungsweg,
    bibliotheksclient_bauen,
)
from r3cosint.ausgang.positivliste import Positivliste
from r3cosint.ausgang.ziel import ZielFehler
from r3cosint.core.fehler import EingabeFehler, KonfigurationsFehler


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
SKRIPT: Any = GS.Antwortskript
GRENZEN = Antwortgrenzen(antwortgroesse_bytes=65536, frist_sekunden=10)
TESTKONSTANTE = ipaddress.ip_address(str(GS.TESTKONSTANTE))
ListeBauen = Callable[..., Positivliste]


@asynccontextmanager
async def gegenstellen(*skripte: Any) -> AsyncIterator[list[Any]]:
    """Startet je Skript (oder je Folge von Skripten) eine Gegenstelle und beendet sie."""
    laufende: list[Any] = []
    try:
        for skript in skripte:
            laufende.append(await GS.Gegenstelle.starten(skript))
        yield laufende
    finally:
        for g in laufende:
            await g.beenden()


def literal(g: Any, kennung: str = "test.ziel") -> dict[str, object]:
    return {
        "kennung": kennung,
        "schema": "http",
        "adresse": "127.0.0.1",
        "anschluss": g.anschluss,
    }


def url(g: Any, pfad: str = "/p") -> str:
    return f"http://127.0.0.1:{g.anschluss}{pfad}?q={GS.MERKMAL}#f"


def ergebnisse(k: Any) -> list[tuple[int, str]]:
    return [(e.schritt, e.ergebnis) for e in k.eingaben]


async def aufruf(
    c: Client, k: Any, ziel_url: str, **kw: Any
) -> Antwort | Abweisung | Fehlschlag:
    kw.setdefault("methode", "GET")
    kw.setdefault("grenzen", GRENZEN)
    return await c.anfragen(k, url=ziel_url, **kw)


# ---- Grenzen, Eingabefehler, Signatur ---------------------------------------------------------


@pytest.mark.parametrize(
    ("groesse", "frist"),
    [
        (0, 1),
        (-1, 1),
        (True, 1),
        (1.5, 1),
        (10, 0),
        (10, -1),
        (10, 301),
        (10, True),
        (10, "1"),
    ],
)
def test_R3_F_015_antwortgrenzen_ungueltig(groesse: Any, frist: Any) -> None:
    with pytest.raises(EingabeFehler):
        Antwortgrenzen(antwortgroesse_bytes=groesse, frist_sekunden=frist)


def test_R3_F_015_antwortgrenzen_gueltig() -> None:
    assert Antwortgrenzen(1, 300).frist_sekunden == 300


def test_R3_F_028_signatur_ohne_follow_redirects_und_kwargs() -> None:
    parameter = inspect.signature(Client.anfragen).parameters
    assert "follow_redirects" not in parameter
    assert all(p.kind is not inspect.Parameter.VAR_KEYWORD for p in parameter.values())


@pytest.mark.parametrize(
    "kopf",
    [
        {"Host": "x"},
        {"cookie": "a=b"},
        {"Accept-Encoding": "gzip"},
        {"Proxy-Authorization": "x"},
        {"transfer-encoding": "chunked"},
        {"": "x"},
        {"x y": "z"},
        {"x:y": "z"},
        {"x-ok": "a\x01b"},
        {"x-ok": "ä"},
    ],
)
async def test_R3_F_015_gesperrte_kopfzeile_ohne_eintrag_und_netzakt(
    kopf: dict[str, str],
    testpositivliste: ListeBauen,
    aufloeser_steuerbar: Any,
    spurkontext_attrappe: Any,
) -> None:
    async with gegenstellen(SKRIPT.treffer(1)) as (g,):
        c = Client(
            positivliste=testpositivliste([literal(g)]), aufloeser=aufloeser_steuerbar
        )
        with pytest.raises(EingabeFehler):
            await aufruf(c, spurkontext_attrappe, url(g), kopfzeilen=kopf)
        assert spurkontext_attrappe.eingaben == [] and g.verbindungen == 0
        assert spurkontext_attrappe.fall_pruefungen == 0


async def test_R3_F_015_koerper_bei_get_und_unbekannte_methode(
    testpositivliste: ListeBauen,
    aufloeser_steuerbar: Any,
    spurkontext_attrappe: Any,
) -> None:
    async with gegenstellen(SKRIPT.treffer(1)) as (g,):
        c = Client(
            positivliste=testpositivliste([literal(g)]), aufloeser=aufloeser_steuerbar
        )
        for methode, koerper in (("GET", b"x"), ("PUT", None)):
            with pytest.raises(EingabeFehler):
                await aufruf(
                    c, spurkontext_attrappe, url(g), methode=methode, koerper=koerper
                )
        assert spurkontext_attrappe.eingaben == [] and g.verbindungen == 0


async def test_R3_F_015_fall_fehlt_ohne_eintrag_aufloesung_und_verbindung(
    testpositivliste: ListeBauen,
    aufloeser_steuerbar: Any,
    spurkontext_attrappe: Any,
) -> None:
    spurkontext_attrappe.fall_besteht = False
    async with gegenstellen(SKRIPT.treffer(1)) as (g,):
        c = Client(
            positivliste=testpositivliste([literal(g)]), aufloeser=aufloeser_steuerbar
        )
        with pytest.raises(EingabeFehler):
            await aufruf(c, spurkontext_attrappe, url(g))
        assert spurkontext_attrappe.eingaben == []
        assert g.verbindungen == 0 and not aufloeser_steuerbar.zaehler


# ---- Ablauf eines Schritts ---------------------------------------------------------------------


async def test_R3_F_015_erfolg_antwort_eintraege_und_kopfzeilen(
    testpositivliste: ListeBauen,
    aufloeser_steuerbar: Any,
    spurkontext_attrappe: Any,
    netzwaechter: Any,
) -> None:
    async with gegenstellen(SKRIPT.treffer(3)) as (g,):
        liste = testpositivliste([literal(g)])
        c = Client(positivliste=liste, aufloeser=aufloeser_steuerbar)
        r = await aufruf(
            c, spurkontext_attrappe, url(g), kopfzeilen={"x-api-key": "synthetisch"}
        )
        assert isinstance(r, Antwort) and r.status == 200 and b"3" in r.koerper
        assert r.schritt == 0 and r.listeneintrag == "test.ziel"
        assert ("content-length", str(len(r.koerper))) in r.kopfzeilen
        assert GS.MERKMAL not in repr(r) and r.koerper.decode() not in repr(r)
        assert ergebnisse(spurkontext_attrappe) == [
            (0, "zugelassen"),
            (0, "beantwortet"),
        ]
        zugelassen, beantwortet = spurkontext_attrappe.eingaben
        assert beantwortet.status == 200 and beantwortet.antwort_bytes == len(r.koerper)
        assert zugelassen.listenstand == liste.listenstand
        assert {e.versuch_kennung for e in spurkontext_attrappe.eingaben} == {
            r.versuch_kennung
        }
        anfrage = g.anfragen[0]
        assert anfrage.pfad == f"/p?q={GS.MERKMAL}", "kein Fragment gesendet"
        assert anfrage.accept_encoding == "identity"
        namen = {n.lower() for n, _ in anfrage.kopfzeilen}
        assert namen == {"host", "accept-encoding", "x-api-key"}, "Abweichung 2"
        assert anfrage.host == f"127.0.0.1:{g.anschluss}"
        # zweiter Aufruf: neue versuch_kennung
        r2 = await aufruf(c, spurkontext_attrappe, url(g))
        assert isinstance(r2, Antwort) and r2.versuch_kennung != r.versuch_kennung


async def test_R3_F_015_post_mit_koerper(
    testpositivliste: ListeBauen,
    aufloeser_steuerbar: Any,
    spurkontext_attrappe: Any,
) -> None:
    async with gegenstellen(SKRIPT.treffer(1)) as (g,):
        c = Client(
            positivliste=testpositivliste([literal(g)]), aufloeser=aufloeser_steuerbar
        )
        r = await aufruf(
            c, spurkontext_attrappe, url(g), methode="POST", koerper=b"abc"
        )
        assert isinstance(r, Antwort)
        assert g.anfragen[0].methode == "POST" and g.anfragen[0].koerper == b"abc"
        assert spurkontext_attrappe.eingaben[0].methode == "POST"


async def test_R3_F_015_eintrag_vor_dem_netzakt(
    testpositivliste: ListeBauen,
    aufloeser_steuerbar: Any,
    spurkontext_attrappe: Any,
) -> None:
    """M16: scheitert das Schreiben des Eintrags zugelassen, entsteht keine Verbindung."""
    spurkontext_attrappe.fehler_bei = 1
    async with gegenstellen(SKRIPT.treffer(1)) as (g,):
        c = Client(
            positivliste=testpositivliste([literal(g)]), aufloeser=aufloeser_steuerbar
        )
        with pytest.raises(RuntimeError):
            await aufruf(c, spurkontext_attrappe, url(g))
        assert g.verbindungen == 0


async def test_R3_F_015_abweisungen_ohne_netzakt(
    testpositivliste: ListeBauen,
    aufloeser_steuerbar: Any,
    spurkontext_attrappe: Any,
    netzwaechter: Any,
) -> None:
    async with gegenstellen(SKRIPT.treffer(1)) as (g,):
        c = Client(
            positivliste=testpositivliste([literal(g)]), aufloeser=aufloeser_steuerbar
        )
        for ziel, erwartet in (
            (f"http://127.0.0.1:{g.anschluss + 1}/", "nicht_in_positivliste"),
            (f"http://127.0.0.2:{g.anschluss}/", "nicht_in_positivliste"),
            (f"https://127.0.0.1:{g.anschluss}/", "nicht_in_positivliste"),
            (f"http://{GS.MERKMAL}:x@127.0.0.1:{g.anschluss}/", "url_nicht_auswertbar"),
            ("ftp://127.0.0.1/", "url_nicht_auswertbar"),
        ):
            r = await aufruf(c, spurkontext_attrappe, ziel)
            assert isinstance(r, Abweisung) and r.ergebnis == erwartet, ziel
            assert r.schritt == 0
        assert g.verbindungen == 0 and not aufloeser_steuerbar.zaehler
        assert [e.ergebnis for e in spurkontext_attrappe.eingaben] == [
            "nicht_in_positivliste"
        ] * 3 + ["url_nicht_auswertbar"] * 2


@pytest.mark.parametrize(
    ("skript", "fehlerart", "grenze"),
    [
        (SKRIPT.komprimiert(), "antwort_ungueltig", 65536),
        (SKRIPT.gross(1000), "antwort_zu_gross", 100),
        (SKRIPT.status(600), "antwort_ungueltig", 65536),
        (SKRIPT.weiterleitung(302, "/x", komprimiert=True), "antwort_ungueltig", 65536),
    ],
)
async def test_R3_F_015_fehlschlag_je_fehlerart(
    skript: Any,
    fehlerart: str,
    grenze: int,
    testpositivliste: ListeBauen,
    aufloeser_steuerbar: Any,
    spurkontext_attrappe: Any,
) -> None:
    async with gegenstellen(skript) as (g,):
        c = Client(
            positivliste=testpositivliste([literal(g)]), aufloeser=aufloeser_steuerbar
        )
        r = await aufruf(
            c,
            spurkontext_attrappe,
            url(g),
            grenzen=Antwortgrenzen(grenze, 10),
        )
        assert isinstance(r, Fehlschlag) and r.fehlerart == fehlerart
        assert ergebnisse(spurkontext_attrappe) == [
            (0, "zugelassen"),
            (0, "verbindung_fehlgeschlagen"),
        ]
        assert spurkontext_attrappe.eingaben[1].fehlerart == fehlerart
        assert spurkontext_attrappe.eingaben[1].status is None


@pytest.mark.parametrize("inhalt", ["GZip", "x-gzip", "identity, gzip", "br"], ids=str)
async def test_R3_F_015_content_encoding_formen(
    inhalt: str,
    testpositivliste: ListeBauen,
    aufloeser_steuerbar: Any,
    spurkontext_attrappe: Any,
) -> None:
    """M33: jede Form ausser leer und identity ist antwort_ungueltig (ohne Lesen des Körpers)."""
    paare = (("content-encoding", inhalt),)
    assert modul._kodierung_ungueltig(paare) is True
    assert modul._kodierung_ungueltig((("Content-Encoding", " identity "),)) is False
    assert modul._kodierung_ungueltig((("x", "gzip"),)) is False
    assert (
        modul._kodierung_ungueltig(
            (("content-encoding", "identity"), ("Content-Encoding", inhalt))
        )
        is True
    )


async def test_R3_F_015_fehlschlag_verbindung_und_zeitueberschreitung(
    testpositivliste: ListeBauen,
    aufloeser_steuerbar: Any,
    spurkontext_attrappe: Any,
) -> None:
    async with gegenstellen(SKRIPT.treffer(1)) as (zu,):
        zu_liste = testpositivliste([literal(zu)])
        zu_url = url(zu)
    # die Gegenstelle ist beendet: der Anschluss ist geschlossen
    c = Client(positivliste=zu_liste, aufloeser=aufloeser_steuerbar)
    r = await aufruf(c, spurkontext_attrappe, zu_url)
    assert isinstance(r, Fehlschlag) and r.fehlerart == "verbindung"
    assert spurkontext_attrappe.eingaben[-1].fehlerart == "verbindung"
    async with gegenstellen(SKRIPT.zeitueberschreitung()) as (g,):
        c = Client(
            positivliste=testpositivliste([literal(g)]), aufloeser=aufloeser_steuerbar
        )
        r = await aufruf(
            c, spurkontext_attrappe, url(g), grenzen=Antwortgrenzen(1000, 0.5)
        )
        assert isinstance(r, Fehlschlag) and r.fehlerart == "zeitueberschreitung"


async def test_R3_F_015_verbindungsweg_wirft(
    testpositivliste: ListeBauen,
    aufloeser_steuerbar: Any,
    spurkontext_attrappe: Any,
) -> None:
    class Kaputt:
        def transport(self, **_: Any) -> httpx.AsyncBaseTransport:
            raise RuntimeError(GS.MERKMAL)

    async with gegenstellen(SKRIPT.treffer(1)) as (g,):
        c = Client(
            positivliste=testpositivliste([literal(g)]),
            aufloeser=aufloeser_steuerbar,
            verbindungsweg=Kaputt(),
        )
        r = await aufruf(c, spurkontext_attrappe, url(g))
        assert isinstance(r, Fehlschlag) and r.fehlerart == "verbindung"
        assert g.verbindungen == 0


# ---- Weiterleitungen ---------------------------------------------------------------------------


async def test_R3_F_028_relative_location_und_kette_zu_lang(
    testpositivliste: ListeBauen,
    aufloeser_steuerbar: Any,
    spurkontext_attrappe: Any,
) -> None:
    folge = [SKRIPT.weiterleitung(302, f"/w{i}/") for i in range(3)]
    folge.append(SKRIPT.weiterleitung(302, "/zuviel/"))
    async with gegenstellen(folge) as (g,):
        c = Client(
            positivliste=testpositivliste([literal(g)], hoechstzahl=3),
            aufloeser=aufloeser_steuerbar,
        )
        r = await aufruf(c, spurkontext_attrappe, url(g))
        assert isinstance(r, Abweisung) and r.ergebnis == "kette_zu_lang"
        assert r.schritt == 4
        assert g.verbindungen == 4 and not aufloeser_steuerbar.zaehler
        assert [a.pfad for a in g.anfragen] == [
            f"/p?q={GS.MERKMAL}",
            "/w0/",
            "/w1/",
            "/w2/",
        ]
        letzter = spurkontext_attrappe.eingaben[-1]
        assert letzter.ergebnis == "kette_zu_lang" and letzter.ausgangsziel is not None
        assert letzter.ziel == letzter.ausgangsziel


@pytest.mark.parametrize(
    "unauswertbar", [("/eins/", "/zwei/"), "http://[::1", "ftp://127.0.0.1/"]
)
async def test_R3_F_028_location_nicht_auswertbar_ist_schritt_n_plus_1(
    unauswertbar: Any,
    testpositivliste: ListeBauen,
    aufloeser_steuerbar: Any,
    spurkontext_attrappe: Any,
) -> None:
    """Abweichung 1: auch ein unlesbarer Wert endet als url_nicht_auswertbar, nicht als Fehlschlag."""
    folge = [SKRIPT.weiterleitung(302, f"/w{i}/") for i in range(3)]
    folge.append(SKRIPT.weiterleitung(302, unauswertbar))
    async with gegenstellen(folge) as (g,):
        c = Client(
            positivliste=testpositivliste([literal(g)], hoechstzahl=3),
            aufloeser=aufloeser_steuerbar,
        )
        r = await aufruf(c, spurkontext_attrappe, url(g))
        assert isinstance(r, Abweisung) and r.ergebnis == "url_nicht_auswertbar"
        assert r.schritt == 4 and g.verbindungen == 4
        letzter = spurkontext_attrappe.eingaben[-1]
        assert letzter.ausgangsziel is not None and letzter.ziel is None


@pytest.mark.parametrize("location", [None, "", "   "])
async def test_R3_F_028_3xx_ohne_location_ist_die_antwort(
    location: Any,
    testpositivliste: ListeBauen,
    aufloeser_steuerbar: Any,
    spurkontext_attrappe: Any,
) -> None:
    async with gegenstellen(SKRIPT.weiterleitung(302, location)) as (g,):
        c = Client(
            positivliste=testpositivliste([literal(g)]), aufloeser=aufloeser_steuerbar
        )
        r = await aufruf(c, spurkontext_attrappe, url(g))
        assert isinstance(r, Antwort) and r.status == 302 and r.schritt == 0


@pytest.mark.parametrize(
    ("status", "methode", "erwartet"),
    [
        (303, "POST", "GET"),
        (301, "POST", "GET"),
        (302, "POST", "GET"),
        (302, "GET", "GET"),
        (307, "POST", "POST"),
        (308, "POST", "POST"),
    ],
)
async def test_R3_F_028_methode_und_koerper_bei_weiterleitung_auf_dasselbe_ziel(
    status: int,
    methode: Literal["GET", "POST"],
    erwartet: str,
    testpositivliste: ListeBauen,
    aufloeser_steuerbar: Any,
    spurkontext_attrappe: Any,
) -> None:
    async with gegenstellen(
        [SKRIPT.weiterleitung(status, "/weiter/"), SKRIPT.treffer(1)]
    ) as (g,):
        c = Client(
            positivliste=testpositivliste([literal(g)]), aufloeser=aufloeser_steuerbar
        )
        r = await aufruf(
            c,
            spurkontext_attrappe,
            url(g),
            methode=methode,
            kopfzeilen={"x-api-key": "k"},
            koerper=b"abc" if methode == "POST" else None,
        )
        assert isinstance(r, Antwort) and r.schritt == 1
        zweite = g.anfragen[1]
        assert zweite.methode == erwartet
        assert zweite.koerper == (b"abc" if erwartet == "POST" else b"")
        assert [v for n, v in zweite.kopfzeilen if n.lower() == "x-api-key"] == ["k"]
        assert [e.methode for e in spurkontext_attrappe.eingaben][-1] == erwartet
        assert spurkontext_attrappe.eingaben[1].antwort_bytes == 0


@pytest.mark.parametrize(
    ("status", "folgt"), [(302, True), (307, False), (308, False), (303, True)]
)
async def test_R3_F_028_zielwechsel_verwirft_kopfzeilen_und_koerper(
    status: int,
    folgt: bool,
    testpositivliste: ListeBauen,
    aufloeser_steuerbar: Any,
    spurkontext_attrappe: Any,
) -> None:
    """M35, M49: x-api-key fällt beim Zielwechsel; 307 und 308 mit Körper werden nicht verfolgt."""
    async with gegenstellen(SKRIPT.treffer(1)) as (b,):
        async with gegenstellen(SKRIPT.weiterleitung(status, url(b, "/b"))) as (a,):
            c = Client(
                positivliste=testpositivliste([literal(a, "a"), literal(b, "b")]),
                aufloeser=aufloeser_steuerbar,
            )
            r = await aufruf(
                c,
                spurkontext_attrappe,
                url(a),
                methode="POST",
                kopfzeilen={"x-api-key": "k"},
                koerper=b"abc",
            )
            assert [v for n, v in a.anfragen[0].kopfzeilen if n == "x-api-key"] == ["k"]
            if folgt:
                assert isinstance(r, Antwort) and r.schritt == 1 and b.verbindungen == 1
                assert b.anfragen[0].koerper == b"" and b.anfragen[0].methode == "GET"
                assert not [1 for n, _ in b.anfragen[0].kopfzeilen if n == "x-api-key"]
            else:
                assert isinstance(r, Antwort) and r.status == status and r.schritt == 0
                assert b.verbindungen == 0
                assert ergebnisse(spurkontext_attrappe) == [
                    (0, "zugelassen"),
                    (0, "beantwortet"),
                ]


async def test_R3_F_028_rueckkehr_zum_ersten_ziel_bleibt_verworfen(
    testpositivliste: ListeBauen,
    aufloeser_steuerbar: Any,
    spurkontext_attrappe: Any,
) -> None:
    platz: dict[str, int] = {}

    class Verweis:
        def __str__(self) -> str:
            return f"http://127.0.0.1:{platz['a']}/zurueck"

    async with gegenstellen(SKRIPT.weiterleitung(302, Verweis())) as (b,):
        async with gegenstellen(
            [SKRIPT.weiterleitung(302, url(b, "/b")), SKRIPT.treffer(1)]
        ) as (a,):
            platz["a"] = a.anschluss
            c = Client(
                positivliste=testpositivliste([literal(a, "a"), literal(b, "b")]),
                aufloeser=aufloeser_steuerbar,
            )
            r = await aufruf(
                c, spurkontext_attrappe, url(a), kopfzeilen={"x-api-key": "k"}
            )
            assert isinstance(r, Antwort) and r.schritt == 2
            assert [n for n, _ in a.anfragen[1].kopfzeilen if n == "x-api-key"] == []


async def test_R3_F_028_307_mit_koerper_unauswertbar_wird_verfolgt_bis_zur_abweisung(
    testpositivliste: ListeBauen,
    aufloeser_steuerbar: Any,
    spurkontext_attrappe: Any,
    netzwaechter: Any,
) -> None:
    async with gegenstellen(SKRIPT.weiterleitung(307, "http://[::1")) as (a,):
        c = Client(
            positivliste=testpositivliste([literal(a)]), aufloeser=aufloeser_steuerbar
        )
        r = await aufruf(c, spurkontext_attrappe, url(a), methode="POST", koerper=b"x")
        assert isinstance(r, Abweisung) and r.ergebnis == "url_nicht_auswertbar"
        assert r.schritt == 1


# ---- Namen, Auflösung, Bereichsregel --------------------------------------------------------------


async def test_R3_F_028_name_wird_einmal_aufgeloest_und_gegen_die_adresse_verbunden(
    testpositivliste: ListeBauen,
    aufloeser_steuerbar: Any,
    verbindungsweg_ersatz: Any,
    spurkontext_attrappe: Any,
    netzwaechter: Any,
) -> None:
    aufloeser_steuerbar.setzen("gut.test", (TESTKONSTANTE,))
    async with gegenstellen(SKRIPT.treffer(1)) as (g,):
        liste = testpositivliste(
            [
                {
                    "kennung": "test.name",
                    "schema": "http",
                    "rechnername": "gut.test",
                    "anschluss": g.anschluss,
                }
            ]
        )
        c = Client(
            positivliste=liste,
            aufloeser=aufloeser_steuerbar,
            verbindungsweg=verbindungsweg_ersatz,
        )
        r = await aufruf(c, spurkontext_attrappe, f"HTTP://Gut.TEST.:{g.anschluss}/a")
        assert isinstance(r, Antwort)
        assert aufloeser_steuerbar.zaehler == {"gut.test": 1}
        (aufzeichnung,) = verbindungsweg_ersatz.aufrufe
        assert aufzeichnung.adresse == TESTKONSTANTE
        assert aufzeichnung.name_oder_adresse == "gut.test"
        assert g.anfragen[0].host == f"gut.test:{g.anschluss}", "M38"
        zugelassen = spurkontext_attrappe.eingaben[0]
        assert (
            zugelassen.zielart == "name" and zugelassen.adressbereich == "oeffentlich"
        )
        assert zugelassen.adresse == str(TESTKONSTANTE)


@pytest.mark.parametrize(
    "antworten",
    [(TESTKONSTANTE, "10.0.0.1"), ("10.0.0.1", TESTKONSTANTE), ("127.0.0.1",)],
)
async def test_R3_F_028_mehrere_adressen_nach_e_s21_02(
    antworten: tuple[Any, ...],
    testpositivliste: ListeBauen,
    aufloeser_steuerbar: Any,
    verbindungsweg_ersatz: Any,
    spurkontext_attrappe: Any,
    netzwaechter: Any,
) -> None:
    """Eine nicht öffentliche Adresse unter mehreren weist den ganzen Versuch ab (M18)."""
    adressen = tuple(ipaddress.ip_address(str(a)) for a in antworten)
    aufloeser_steuerbar.setzen("gut.test", adressen)
    liste = testpositivliste(
        [{"kennung": "n", "schema": "http", "rechnername": "gut.test", "anschluss": 80}]
    )
    c = Client(
        positivliste=liste,
        aufloeser=aufloeser_steuerbar,
        verbindungsweg=verbindungsweg_ersatz,
    )
    r = await aufruf(c, spurkontext_attrappe, "http://gut.test/")
    assert isinstance(r, Abweisung) and r.ergebnis == "bereich_nicht_oeffentlich"
    assert verbindungsweg_ersatz.aufrufe == []
    (e,) = spurkontext_attrappe.eingaben
    assert e.adressbereich != "oeffentlich" and e.adresse is not None
    assert e.adresse != str(TESTKONSTANTE)


async def test_R3_F_028_alle_oeffentlich_erste_wird_verwendet(
    testpositivliste: ListeBauen,
    aufloeser_steuerbar: Any,
    verbindungsweg_ersatz: Any,
    spurkontext_attrappe: Any,
    netzwaechter: Any,
) -> None:
    zweite = ipaddress.ip_address("2001:30::1")
    aufloeser_steuerbar.setzen("gut.test", (TESTKONSTANTE, zweite))
    async with gegenstellen(SKRIPT.treffer(1)) as (g,):
        liste = testpositivliste(
            [
                {
                    "kennung": "n",
                    "schema": "http",
                    "rechnername": "gut.test",
                    "anschluss": g.anschluss,
                }
            ]
        )
        c = Client(
            positivliste=liste,
            aufloeser=aufloeser_steuerbar,
            verbindungsweg=verbindungsweg_ersatz,
        )
        r = await aufruf(c, spurkontext_attrappe, f"http://gut.test:{g.anschluss}/")
        assert isinstance(r, Antwort)
        assert verbindungsweg_ersatz.aufrufe[0].adresse == TESTKONSTANTE


@pytest.mark.parametrize("antwort", [AufloesungsFehler, OSError, ()])
async def test_R3_F_028_aufloesung_fehlgeschlagen(
    antwort: Any,
    testpositivliste: ListeBauen,
    aufloeser_steuerbar: Any,
    verbindungsweg_ersatz: Any,
    spurkontext_attrappe: Any,
    netzwaechter: Any,
) -> None:
    aufloeser_steuerbar.setzen("gut.test", antwort)
    liste = testpositivliste(
        [{"kennung": "n", "schema": "http", "rechnername": "gut.test", "anschluss": 80}]
    )
    c = Client(
        positivliste=liste,
        aufloeser=aufloeser_steuerbar,
        verbindungsweg=verbindungsweg_ersatz,
    )
    r = await aufruf(c, spurkontext_attrappe, "http://gut.test/")
    assert isinstance(r, Abweisung) and r.ergebnis == "aufloesung_fehlgeschlagen"
    assert verbindungsweg_ersatz.aufrufe == []
    assert spurkontext_attrappe.eingaben[0].listeneintrag == "n"


async def test_R3_F_028_aufloesung_unter_der_gesamtfrist(
    testpositivliste: ListeBauen,
    aufloeser_steuerbar: Any,
    spurkontext_attrappe: Any,
    netzwaechter: Any,
    verbindungsweg_ersatz: Any,
) -> None:
    """M50: ein verzögerter Auflöser über der Frist ergibt aufloesung_fehlgeschlagen."""
    aufloeser_steuerbar.setzen("gut.test", (TESTKONSTANTE,))
    aufloeser_steuerbar.verzoegerung = 4.0
    liste = testpositivliste(
        [{"kennung": "n", "schema": "http", "rechnername": "gut.test", "anschluss": 80}]
    )
    c = Client(
        positivliste=liste,
        aufloeser=aufloeser_steuerbar,
        verbindungsweg=verbindungsweg_ersatz,
    )
    beginn = time.monotonic()
    r = await aufruf(
        c, spurkontext_attrappe, "http://gut.test/", grenzen=Antwortgrenzen(1000, 1.0)
    )
    assert isinstance(r, Abweisung) and r.ergebnis == "aufloesung_fehlgeschlagen"
    assert time.monotonic() - beginn < 3.0


async def test_R3_F_028_ipv6_literal_ueber_den_ersatz(
    testpositivliste: ListeBauen,
    aufloeser_steuerbar: Any,
    verbindungsweg_ersatz: Any,
    spurkontext_attrappe: Any,
    netzwaechter: Any,
) -> None:
    async with gegenstellen(SKRIPT.treffer(1)) as (g,):
        liste = testpositivliste(
            [
                {
                    "kennung": "v6",
                    "schema": "http",
                    "adresse": "::1",
                    "anschluss": g.anschluss,
                }
            ]
        )
        c = Client(
            positivliste=liste,
            aufloeser=aufloeser_steuerbar,
            verbindungsweg=verbindungsweg_ersatz,
        )
        r = await aufruf(
            c, spurkontext_attrappe, f"http://[0:0:0:0:0:0:0:1]:{g.anschluss}/"
        )
        assert isinstance(r, Antwort)
        assert verbindungsweg_ersatz.aufrufe[0].name_oder_adresse == "::1"
        assert g.anfragen[0].host == f"[::1]:{g.anschluss}"
        assert spurkontext_attrappe.eingaben[0].zielart == "ipv6"
        assert not aufloeser_steuerbar.zaehler


# ---- Gesamtfrist (M37) ---------------------------------------------------------------------------


async def test_R3_F_028_gesamtfrist_je_aufruf_nicht_je_schritt(
    testpositivliste: ListeBauen,
    aufloeser_steuerbar: Any,
    spurkontext_attrappe: Any,
) -> None:
    """Schritt 0 braucht 0,6 mal die Frist, Schritt 1 hängt: Gesamtdauer unter 1,3 mal Frist (Spielraum 0,6 s; je Schritt läge sie bei etwa 1,6 mal)."""
    frist = 2.0
    async with gegenstellen(SKRIPT.zeitueberschreitung()) as (b,):
        async with gegenstellen(
            SKRIPT.verzoegert(0.6 * frist, SKRIPT.weiterleitung(302, url(b, "/b")))
        ) as (a,):
            c = Client(
                positivliste=testpositivliste([literal(a, "a"), literal(b, "b")]),
                aufloeser=aufloeser_steuerbar,
            )
            beginn = time.monotonic()
            r = await aufruf(
                c, spurkontext_attrappe, url(a), grenzen=Antwortgrenzen(1000, frist)
            )
            dauer = time.monotonic() - beginn
            assert isinstance(r, Fehlschlag) and r.fehlerart == "zeitueberschreitung"
            assert r.schritt == 1
            assert dauer < 1.3 * frist, f"{dauer:.2f} s"


# ---- Einstellungen der Bibliothek ----------------------------------------------------------------


async def test_R3_F_028_bibliotheksclient_einstellungen() -> None:
    client = bibliotheksclient_bauen(
        httpx.MockTransport(lambda r: httpx.Response(204)), 5.0
    )
    try:
        assert client.follow_redirects is False
        assert client.trust_env is False
        assert not client._mounts
        assert len(client.headers) == 0
        assert client.timeout == httpx.Timeout(5.0)
    finally:
        await client.aclose()


async def test_R3_F_028_umgebungs_proxy_wirkt_nicht(
    schein_proxy: Any,
    testpositivliste: ListeBauen,
    aufloeser_steuerbar: Any,
    spurkontext_attrappe: Any,
) -> None:
    async with gegenstellen(SKRIPT.treffer(1)) as (g,):
        c = Client(
            positivliste=testpositivliste([literal(g)]), aufloeser=aufloeser_steuerbar
        )
        r = await aufruf(c, spurkontext_attrappe, url(g))
        assert isinstance(r, Antwort) and g.verbindungen == 1
    assert schein_proxy.verbindungen == 0


async def test_R3_F_015_die_beiden_aufruf_formen_der_nutzlast_ohne_klartext(
    testpositivliste: ListeBauen,
    aufloeser_steuerbar: Any,
    spurkontext_attrappe: Any,
) -> None:
    async with gegenstellen(SKRIPT.treffer(1)) as (g,):
        c = Client(
            positivliste=testpositivliste([literal(g)]), aufloeser=aufloeser_steuerbar
        )
        r = await aufruf(c, spurkontext_attrappe, url(g))
        assert isinstance(r, Antwort)
        for e in spurkontext_attrappe.eingaben:
            assert GS.MERKMAL not in repr(e) and "127.0.0.1" not in repr(e)
        for wert in (r,):
            assert not any(
                isinstance(v, (httpx.Response, httpx.Request, BaseException))
                for v in vars_von(wert)
            )


def vars_von(wert: Any) -> list[Any]:
    return [getattr(wert, name) for name in wert.__slots__]


# ---- Vertrauensanker und Kontext -------------------------------------------------------------------


def _kontext(**einstellungen: Any) -> ssl.SSLContext:
    kontext = ssl.create_default_context()
    kontext.minimum_version = ssl.TLSVersion.TLSv1_2
    for name, wert in einstellungen.items():
        if name == "check_hostname":
            kontext.check_hostname = wert
        if name == "verify_mode":
            kontext.check_hostname = False
            kontext.verify_mode = wert
        if name == "minimum_version":
            kontext.minimum_version = wert
    return kontext


@pytest.mark.filterwarnings("ignore::DeprecationWarning")
@pytest.mark.parametrize(
    "einstellung",
    [
        {"verify_mode": ssl.CERT_NONE},
        {"check_hostname": False},
        {"minimum_version": ssl.TLSVersion.TLSv1_1},
    ],
)
def test_R3_F_015_vertrauensanker_ohne_pruefung_wird_abgewiesen(
    einstellung: dict[str, Any],
    testpositivliste: ListeBauen,
    aufloeser_steuerbar: Any,
) -> None:
    with pytest.raises(KonfigurationsFehler) as fehler:
        Client(
            positivliste=testpositivliste([]),
            aufloeser=aufloeser_steuerbar,
            vertrauensanker=_kontext(**einstellung),
        )
    assert fehler.value.__cause__ is None and fehler.value.__context__ is None


def test_R3_F_015_vertrauensanker_mit_pruefung_wird_angenommen(
    testpositivliste: ListeBauen, aufloeser_steuerbar: Any
) -> None:
    Client(
        positivliste=testpositivliste([]),
        aufloeser=aufloeser_steuerbar,
        vertrauensanker=_kontext(),
    )


def test_R3_F_015_standardkontext_ist_eigen_und_streng() -> None:
    kontext = modul._standardkontext()
    assert kontext.verify_mode == ssl.CERT_REQUIRED and kontext.check_hostname
    assert kontext.minimum_version == ssl.TLSVersion.TLSv1_2
    assert kontext.cert_store_stats()["x509_ca"] > 0, "Wurzeln aus certifi"


def test_R3_F_028_eigene_ausnahmen_ohne_ursache_und_kontext() -> None:
    for fehler in (ZielFehler(), AufloesungsFehler(), EingabeFehler("x")):
        assert fehler.__cause__ is None and fehler.__context__ is None


# ---- Netzanschluss (M14, M36) ------------------------------------------------------------------------


class _Innen(httpcore.AsyncNetworkBackend):
    def __init__(self) -> None:
        self.aufrufe: list[tuple[str, int]] = []
        self.geschlafen: list[float] = []

    async def connect_tcp(self, host: str, port: int, *a: Any, **k: Any) -> Any:
        self.aufrufe.append((host, port))
        return "strom"

    async def connect_unix_socket(self, path: str, *a: Any, **k: Any) -> Any:
        raise AssertionError("nicht erreichbar")

    async def sleep(self, seconds: float) -> None:
        self.geschlafen.append(seconds)


async def test_R3_F_028_netzanschluss_bindet_adresse_und_weist_ab() -> None:
    innen = _Innen()
    netz = GebundenerNetzanschluss(
        rechner="gut.test", anschluss=80, adresse=TESTKONSTANTE, innen=innen
    )
    assert str(await netz.connect_tcp("gut.test", 80)) == "strom"
    assert innen.aufrufe == [(str(TESTKONSTANTE), 80)], "Adresse statt Name"
    with pytest.raises(httpcore.ConnectError):  # M36: kein zweiter Aufbau
        await netz.connect_tcp("gut.test", 80)
    await netz.sleep(0.25)
    assert innen.geschlafen == [0.25]
    for host, port in (("anders.test", 80), ("gut.test", 81)):
        frisch = GebundenerNetzanschluss(
            rechner="gut.test", anschluss=80, adresse=TESTKONSTANTE, innen=innen
        )
        with pytest.raises(httpcore.ConnectError):
            await frisch.connect_tcp(host, port)
    with pytest.raises(httpcore.ConnectError):
        await netz.connect_unix_socket("/tmp/x")  # noqa: S108
    assert len(innen.aufrufe) == 1


def test_R3_F_028_standard_verbindungsweg_liefert_einen_transport() -> None:
    transport = GebundenerVerbindungsweg().transport(
        name_oder_adresse="gut.test",
        adresse=TESTKONSTANTE,
        anschluss=80,
        ssl_kontext=modul._standardkontext(),
    )
    assert isinstance(transport, httpx.AsyncBaseTransport)


async def test_R3_F_028_antwortstrom_schliesst_auch_ohne_coroutine() -> None:
    geschlossen: list[int] = []

    async def strom() -> AsyncIterator[bytes]:
        yield b"a"
        yield b"b"

    umhuelle = modul._Antwortstrom(strom(), lambda: geschlossen.append(1))
    assert [s async for s in umhuelle] == [b"a", b"b"]
    await umhuelle.aclose()
    assert geschlossen == [1]


# ---- Fehlerarten ---------------------------------------------------------------------------------------


def _mit_ursache(aussen: BaseException, ursache: BaseException) -> BaseException:
    aussen.__cause__ = ursache
    return aussen


@pytest.mark.parametrize(
    ("fehler", "erwartet"),
    [
        (TimeoutError(), "zeitueberschreitung"),
        (httpx.ReadTimeout("x"), "zeitueberschreitung"),
        (httpcore.ConnectTimeout("x"), "zeitueberschreitung"),
        (
            _mit_ursache(httpcore.ConnectError("x"), ssl.SSLCertVerificationError()),
            "tls",
        ),
        (httpcore.RemoteProtocolError("x"), "antwort_ungueltig"),
        (httpx.RemoteProtocolError("x"), "antwort_ungueltig"),
        (httpcore.ConnectError("x"), "verbindung"),
        (OSError(), "verbindung"),
    ],
)
def test_R3_F_015_fehlerart_aus_der_ausnahme(
    fehler: BaseException, erwartet: str
) -> None:
    assert modul._fehlerart_aus(fehler) == erwartet


# ---- Protokolle der Bibliothek (M11, M12, M40) ----------------------------------------------------------


async def test_R3_F_015_logger_der_bibliothek_stumm_auch_spaeter_angelegte_kinder(
    testpositivliste: ListeBauen,
    aufloeser_steuerbar: Any,
    spurkontext_attrappe: Any,
    caplog: pytest.LogCaptureFixture,
) -> None:
    kind = logging.getLogger("httpcore.connection")
    kind.setLevel(logging.DEBUG)
    logging.getLogger().setLevel(logging.DEBUG)
    caplog.set_level(1)
    async with gegenstellen(SKRIPT.treffer(1)) as (g,):
        c = Client(
            positivliste=testpositivliste([literal(g)]), aufloeser=aufloeser_steuerbar
        )
        await aufruf(c, spurkontext_attrappe, url(g))
        assert logging.getLogger("httpx").level == logging.CRITICAL + 1
        assert logging.getLogger("httpcore").level == logging.CRITICAL + 1
        assert kind.level == logging.NOTSET
        spaet = logging.getLogger("httpx.spaet_angelegt")
        spaet.setLevel(logging.DEBUG)
        caplog.clear()
        await aufruf(c, spurkontext_attrappe, url(g))
        assert spaet.level == logging.NOTSET
        assert not [
            r for r in caplog.records if r.name.startswith(("httpx", "httpcore"))
        ]


async def test_R3_F_028_koerper_allein_ueber_den_rohstrom_hilfsfall_zu_m34(
    monkeypatch: pytest.MonkeyPatch,
    testpositivliste: ListeBauen,
    aufloeser_steuerbar: Any,
    spurkontext_attrappe: Any,
) -> None:
    """M34: bei entfernter Kopfzeilenprüfung zählt der Client die Rohbytes, nie die dekodierten.

    Der gzip-Block ist klein, dekodiert aber über der Grenze. Der Strom wird nicht dekodiert: die
    Antwort trägt den gzip-Block selbst. Mit aiter_bytes wäre es antwort_zu_gross.
    """
    monkeypatch.setattr(modul, "_kodierung_ungueltig", lambda paare: False)
    async with gegenstellen(SKRIPT.komprimiert(100000)) as (g,):
        c = Client(
            positivliste=testpositivliste([literal(g)]), aufloeser=aufloeser_steuerbar
        )
        r = await aufruf(
            c, spurkontext_attrappe, url(g), grenzen=Antwortgrenzen(5000, 10)
        )
        assert isinstance(r, Antwort)
        assert r.koerper[:2] == b"\x1f\x8b" and len(r.koerper) < 5000
        assert spurkontext_attrappe.eingaben[1].antwort_bytes == len(r.koerper)
    # Gegenprobe: ist der Block selbst über der Grenze, zählen die Rohbytes
    async with gegenstellen(SKRIPT.komprimiert(100000)) as (g,):
        c = Client(
            positivliste=testpositivliste([literal(g)]), aufloeser=aufloeser_steuerbar
        )
        r = await aufruf(
            c, spurkontext_attrappe, url(g), grenzen=Antwortgrenzen(50, 10)
        )
        assert isinstance(r, Fehlschlag) and r.fehlerart == "antwort_zu_gross"


def test_R3_F_028_vorraete_gleich_denen_von_spur_payload() -> None:
    """ST-S21-03: die Vorräte von ausgang sind die Literal-Typen von spur.payload."""
    from r3cosint.ausgang import aufloesung, ziel
    from r3cosint.spur import payload

    assert aufloesung.Adressbereich is payload.Adressbereich
    assert ziel.Zielart is payload.Zielart
    assert ziel.Schema is payload.Anschlussschema
    assert get_type_hints(modul.Fehlschlag)["fehlerart"] == payload.Fehlerart
    assert aufloesung.ADRESSBEREICHE == get_args(payload.Adressbereich)


@pytest.mark.parametrize("wert", ["IDENTITY", "Identity", " identity "])
async def test_R3_F_028_content_encoding_identity_ohne_gross_und_kleinschreibung(
    wert: str,
    testpositivliste: ListeBauen,
    aufloeser_steuerbar: Any,
    spurkontext_attrappe: Any,
    netzwaechter: Any,
) -> None:
    """M33 (Grundform): identity gilt in jeder Schreibweise, die Antwort wird nicht abgewiesen."""
    async with gegenstellen(SKRIPT.kodierung(wert)) as (g,):
        c = Client(
            positivliste=testpositivliste([literal(g)]), aufloeser=aufloeser_steuerbar
        )
        r = await aufruf(c, spurkontext_attrappe, url(g))
        assert isinstance(r, Antwort) and r.koerper == b"synthetisch"
        assert ergebnisse(spurkontext_attrappe) == [
            (0, "zugelassen"),
            (0, "beantwortet"),
        ]
