"""Abnahmetests R3-F-015 und R3-F-028 (ADR 0008, Festlegung S2.1 mit Nachbesserung S2.1.1).

R3-F-015 (Backlog, Abnahme `R3-F-015_ziel_ausserhalb_abgewiesen`, präzisiert am 2026-11-10) und
R3-F-028 (Backlog, Abnahmen `R3-F-028_weiterleitung_wird_erneut_geprueft`,
`R3-F-028_namensaufloesung_einmal_und_geprueft`, `R3-F-028_ip_literal_wie_normalform_entschieden`,
präzisiert am 2026-11-10). Massgeblich für die Prüffälle ist die Zeile "Tests Abnahme" der
Festlegung S2.1; die Testhilfen (Gegenstelle, Fixtures) sind nach den Zeilen "Testgegenstelle"
und "Fixtures" benutzt, nicht hier gebaut.

Gemeinsam für alle vier Tests:

- Spurkontext aus eroeffneter_fall (Fixture spurkontext), Fixture netzwaechter aktiv (sie sichert
  am Testende selbst Zähler 0 zu), Prozessausgaben über caplog ab Stufe 1 mit der Wurzel auf
  NOTSET, capfd und warnings.catch_warnings.
- Jede URL trägt MERKMAL in Pfad, Abfrageteil und Fragment; R3-F-015 hat einen eigenen
  Abweisungsfall mit MERKMAL in den Benutzerangaben. MERKMAL, Zielform und Rohform der Rechner
  stehen in keiner Nutzlast und keiner Prozessausgabe (DS-S21-04, DS-S21-09). Trennschärfe: eine
  Gegenprobe ohne ausgang setzt den Logger httpx auf INFO und findet MERKMAL.
- Pseudonyme werden mit hmac und hashlib aus der Zielform und dem Fallschlüssel nachgerechnet
  (fallschluessel_lesen), mit der Vorbedingung normalisieren(Zielform) gleich Zielform.
- Alle Einträge eines Aufrufs von anfragen tragen dieselbe versuch_kennung wie die Rückgabe,
  zwei Aufrufe verschiedene; methode ist gesetzt und gleich der gesendeten Methode des Schritts;
  auf jedes zugelassen folgt mit gleichem Schritt genau ein beantwortet oder
  verbindung_fehlgeschlagen; jeder Eintrag erfüllt die Belegungstabelle der Zeile Protokoll.
- Beide Rechenwege der Kettenprüfung sind am Ende unversehrt.

Keine Verbindung nach aussen: Ziele sind Namen unter .test, die Rückschleife 127.0.0.1 und die
Testkonstante 2001:20::1, die nie kontaktiert wird (verbindungsweg_ersatz, netzwaechter). Kein
Test bindet oder verbindet einen IPv6-Socket; IPv6-Literale laufen allein über
verbindungsweg_ersatz (GK-21). Die TLS-Fälle stehen nach der Festlegung in test_ausgang_tls.py.

Annahmen an Schnittstellen, die die Festlegung nicht im Einzelnen nennt (Befunde DT-S21-A-02 bis
-08 im Bericht an den Koordinator): Laden der Testgegenstelle aus backend/tests/gegenstelle.py
über den Dateipfad; Formen des Antwortskripts als Funktionen des Moduls oder als Attribute von
Antwortskript; mehrere location-Kopfzeilen als Tupel; 3xx mit content-encoding über das
Schlüsselwort komprimiert; Aufzeichnung der Anfrage mit kopfzeilen und koerper; Schnittstelle von
aufloeser_steuerbar (setzen, zaehler) und verbindungsweg_ersatz (aufrufe).

Geschrieben vor dem Bau vom Dynamic Software Tester; der Test wird nicht an die Umsetzung
angepasst, Abweichungen gehen an den Koordinator. Alle Werte sind erfunden (5.15).
"""

import hashlib
import hmac
import importlib.util
import inspect
import ipaddress
import json
import logging
import sys
import time
import warnings
from collections.abc import AsyncIterator, Iterable, Mapping, Sequence
from contextlib import asynccontextmanager
from dataclasses import dataclass, field
from pathlib import Path
from types import ModuleType
from typing import Any, Literal
from uuid import UUID

import httpx
import pytest
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncConnection

from r3cosint.ausgang.aufloesung import adressbereich
from r3cosint.ausgang.client import (
    Abweisung,
    Antwort,
    Antwortgrenzen,
    Client,
    Fehlschlag,
    bibliotheksclient_bauen,
)
from r3cosint.ausgang.positivliste import Positivliste, laden
from r3cosint.spur.payload import normalisieren
from r3cosint.spur.service import Befund, Spur, kette_pruefen, kette_pruefen_datenbank

pytestmark = [pytest.mark.anyio, pytest.mark.abnahme]


# ---- Testgegenstelle (backend/tests/gegenstelle.py, Zeile Testgegenstelle) -------------------


def _gegenstellenmodul() -> ModuleType:
    """Das Modul backend/tests/gegenstelle.py; dieselbe Instanz, wenn conftest es schon geladen hat."""
    pfad = (Path(__file__).resolve().parents[1] / "gegenstelle.py").resolve()
    for modul in list(sys.modules.values()):
        datei = getattr(modul, "__file__", None)
        if datei is not None and Path(datei).resolve() == pfad:
            return modul
    spec = importlib.util.spec_from_file_location("r3cosint_gegenstelle", pfad)
    assert spec is not None and spec.loader is not None, (
        "backend/tests/gegenstelle.py fehlt"
    )
    modul = importlib.util.module_from_spec(spec)
    sys.modules[spec.name] = modul
    spec.loader.exec_module(modul)
    return modul


_GS = _gegenstellenmodul()
TESTKONSTANTE: str = str(_GS.TESTKONSTANTE)
MERKMAL: str = str(_GS.MERKMAL)


def _skript(form: str, *argumente: Any, **schluessel: Any) -> Any:
    """Antwortskript in einer der Formen der Zeile Testgegenstelle."""
    fabrik = getattr(_GS, form, None)
    if fabrik is None:
        fabrik = getattr(_GS.Antwortskript, form)
    return fabrik(*argumente, **schluessel)


@asynccontextmanager
async def _gegenstelle(skript: Any) -> AsyncIterator[Any]:
    """Startet eine Gegenstelle auf 127.0.0.1 (Anschluss 0) und beendet sie am Ende."""
    starten = inspect.getattr_static(_GS.Gegenstelle, "starten")
    if isinstance(starten, (classmethod, staticmethod)):
        instanz = await _GS.Gegenstelle.starten(skript)
    else:
        instanz = await _GS.Gegenstelle().starten(skript)
    try:
        yield instanz
    finally:
        await instanz.beenden()


def _kopfzeile(anfrage: Any, name: str) -> list[str]:
    """Werte einer Kopfzeile der aufgezeichneten Anfrage (Name ohne Gross- und Kleinschreibung)."""
    return [str(w) for n, w in anfrage.kopfzeilen if str(n).lower() == name]


def _koerper(anfrage: Any) -> bytes:
    return bytes(anfrage.koerper or b"")


@dataclass(frozen=True)
class _Verweis:
    """Location, deren Anschluss erst nach dem Start der Gegenstelle feststeht (Fall (f)).

    Die Gegenstelle bildet den Text der Location beim Antworten mit str(); Annahme DT-S21-A-06.
    """

    platz: Mapping[str, int]
    schluessel: str

    def __str__(self) -> str:
        return _url("http", "127.0.0.1", self.platz[self.schluessel])


# ---- Positivliste über den Weg des Betriebs (Datei unter tmp_path, laden) ----------------------


@dataclass(frozen=True)
class _E:
    """Listeneintrag für die Testdatei (rechnername oder adresse, genau eines)."""

    kennung: str
    schema: str
    anschluss: int
    rechnername: str | None = None
    adresse: str | None = None


def _liste(
    verzeichnis: Path,
    eintraege: Sequence[_E],
    *,
    hoechstzahl: int = 3,
    name: str = "liste",
) -> tuple[Positivliste, str]:
    """Schreibt positivliste.toml nach der Form der Zeile ausgang.positivliste, lädt sie.

    Rückgabe: Liste und SHA-256 der geschriebenen Bytes (Erwartung für listenstand).
    """
    zeilen = [
        "format = 1",
        'umgebung = "test"',
        f"ausgang_weiterleitungen_hoechstzahl = {hoechstzahl}",
        "stillgelegt = []",
    ]
    for e in eintraege:
        zeilen += [
            "",
            "[[eintrag]]",
            f'kennung = "{e.kennung}"',
            f'schema = "{e.schema}"',
        ]
        if e.rechnername is not None:
            zeilen.append(f'rechnername = "{e.rechnername}"')
        if e.adresse is not None:
            zeilen.append(f'adresse = "{e.adresse}"')
        zeilen.append(f"anschluss = {e.anschluss}")
    daten = ("\n".join(zeilen) + "\n").encode("utf-8")
    pfad = verzeichnis / f"{name}.toml"
    pfad.write_bytes(daten)
    liste = laden(pfad, umgebung="test")
    stand = hashlib.sha256(daten).hexdigest()
    assert liste.listenstand == stand
    return liste, stand


GRENZEN = Antwortgrenzen(antwortgroesse_bytes=65536, frist_sekunden=10)


def _url(schema: str, rechner: str, anschluss: int | None, pfad: str = "") -> str:
    """URL mit MERKMAL in Pfad, Abfrageteil und Fragment (DS-S21-04)."""
    teil = f":{anschluss}" if anschluss is not None else ""
    return f"{schema}://{rechner}{teil}/{pfad}p-{MERKMAL}?q={MERKMAL}#f-{MERKMAL}"


# ---- Pseudonyme, Zielform, Belegung -------------------------------------------------------------

_ETIKETT = b"r3cosint-pseudonym-1\n"


def _zielform(schema: str, wert: str, anschluss: int) -> str:
    """Zielform nach der Zeile Protokoll (DF-S21-05 a): IPv6 in eckigen Klammern, stets mit Anschluss."""
    rechner = f"[{wert}]" if ":" in wert else wert
    return f"{schema}://{rechner}:{anschluss}"


def _pseudonym(schluessel: bytes, wert: str) -> str:
    """Zweiter Rechenweg: HMAC-SHA-256 mit dem Fallschlüssel; Vorbedingung normalisieren(x) == x."""
    assert normalisieren(wert) == wert, (
        "Vorbedingung DF-S21-05 b: Wert bereits in Normalform"
    )
    return hmac.new(
        schluessel, _ETIKETT + wert.encode("utf-8"), hashlib.sha256
    ).hexdigest()


_IMMER = (
    "fall_kennung",
    "werkzeug",
    "versuch_kennung",
    "schritt",
    "methode",
    "ergebnis",
    "listenstand",
)
_FELDER = (
    "schema",
    "anschluss",
    "zielart",
    "ziel_pseudonym",
    "adresse_pseudonym",
    "adressbereich",
    "listeneintrag",
    "fehlerart",
    "status",
    "antwort_bytes",
)
_BELEGUNG = {
    "zugelassen": "PPPPPPPVVV",
    "beantwortet": "PPPPPPPVPP",
    "verbindung_fehlgeschlagen": "PPPPPPPPVV",
    "nicht_in_positivliste": "PPPPVVVVVV",
    "bereich_nicht_oeffentlich": "PPPPPPPVVV",
    "aufloesung_fehlgeschlagen": "PPPPVVPVVV",
    "kette_zu_lang": "PPPPVVVVVV",
    "url_nicht_auswertbar": "VVVVVVVVVV",
}
_ERLAUBT = set(_IMMER) | set(_FELDER) | {"ausgangsziel_pseudonym"}


def _belegung(p: Mapping[str, Any]) -> None:
    """Belegungstabelle der Zeile Protokoll (DF-S21-04): jedes Feld Pflicht oder verboten."""
    assert set(p) <= _ERLAUBT, (
        f"unbekannte Felder in der Nutzlast: {sorted(set(p) - _ERLAUBT)}"
    )
    for feld in _IMMER:
        assert feld in p, f"Pflichtfeld fehlt: {feld}"
    zeile = _BELEGUNG[p["ergebnis"]]
    for feld, zeichen in zip(_FELDER, zeile, strict=True):
        if zeichen == "P":
            assert feld in p, f"{p['ergebnis']}: Pflichtfeld {feld} fehlt"
        else:
            assert feld not in p, f"{p['ergebnis']}: verbotenes Feld {feld} gesetzt"
    if p["schritt"] > 0:
        assert "ausgangsziel_pseudonym" in p, "ausgangsziel Pflicht ab Schritt 1"
    else:
        assert "ausgangsziel_pseudonym" not in p, "ausgangsziel verboten in Schritt 0"
    if p["ergebnis"] in ("bereich_nicht_oeffentlich", "aufloesung_fehlgeschlagen"):
        assert p["zielart"] == "name"
    if p["ergebnis"] == "bereich_nicht_oeffentlich":
        assert p["adressbereich"] != "oeffentlich"
    if p["ergebnis"] in ("zugelassen", "beantwortet", "verbindung_fehlgeschlagen"):
        if p["zielart"] == "name":
            assert p["adressbereich"] == "oeffentlich"
    assert p["methode"] in ("GET", "POST")
    assert len(p["listenstand"]) == 64


# ---- Protokoll lesen, Ausgaben, Kette -----------------------------------------------------------


def _nutzlast(roh: Any) -> dict[str, Any]:
    wert = json.loads(roh) if isinstance(roh, (str, bytes)) else dict(roh)
    assert isinstance(wert, dict)
    return wert


@dataclass
class _Lauf:
    """Ruft anfragen in der Transaktion des Aufrufers und liest danach die neuen Einträge."""

    kontext: Any
    schluessel: bytes
    position: int = 0
    nutzlasten_roh: list[str] = field(default_factory=list)
    kennungen: list[str] = field(default_factory=list)

    @property
    def verbindung(self) -> AsyncConnection:
        verbindung: AsyncConnection = self.kontext.verbindung
        return verbindung

    async def anfragen(
        self,
        client: Client,
        url: str,
        *,
        methode: Literal["GET", "POST"] = "GET",
        grenzen: Antwortgrenzen = GRENZEN,
        kopfzeilen: Mapping[str, str] | None = None,
        koerper: bytes | None = None,
    ) -> Any:
        async def aufruf() -> Any:
            return await client.anfragen(
                self.kontext,
                methode=methode,
                url=url,
                grenzen=grenzen,
                kopfzeilen=kopfzeilen,
                koerper=koerper,
            )

        if self.verbindung.in_transaction():
            rueckgabe = await aufruf()
        else:
            async with self.verbindung.begin():
                rueckgabe = await aufruf()
        assert isinstance(rueckgabe, (Antwort, Abweisung, Fehlschlag)), type(rueckgabe)
        kennung = str(rueckgabe.versuch_kennung)
        assert kennung not in self.kennungen, "versuch_kennung je Aufruf verschieden"
        self.kennungen.append(kennung)
        return rueckgabe

    async def neu(self) -> list[dict[str, Any]]:
        """Neue Zeilen der Arbeitsspur seit dem letzten Lesen, mit gelesener Nutzlast."""
        sql = text(
            "SELECT position, eintragstyp, kennzeichnung, person_kennung, payload "
            "FROM r3cosint.arbeitsspur WHERE fall_kennung = :fall AND position > :ab "
            "ORDER BY position"
        )
        parameter = {"fall": self.kontext.fall_kennung, "ab": self.position}
        if self.verbindung.in_transaction():
            zeilen = [
                dict(z._mapping) for z in await self.verbindung.execute(sql, parameter)
            ]
        else:
            async with self.verbindung.begin():
                zeilen = [
                    dict(z._mapping)
                    for z in await self.verbindung.execute(sql, parameter)
                ]
        ergebnis: list[dict[str, Any]] = []
        for z in zeilen:
            self.position = int(z["position"])
            roh = z["payload"]
            self.nutzlasten_roh.append(roh if isinstance(roh, str) else json.dumps(roh))
            assert z["eintragstyp"] == "verbindungsversuch", z["eintragstyp"]
            assert z["kennzeichnung"] == "quellenaussage"
            assert z["person_kennung"] == self.kontext.person_kennung
            p = _nutzlast(roh)
            assert p["fall_kennung"] == str(self.kontext.fall_kennung)
            assert p["werkzeug"] == self.kontext.werkzeug
            assert self.kontext.person_kennung not in json.dumps(p), "DS-S21-08"
            _belegung(p)
            ergebnis.append(p)
        return ergebnis

    async def startposition(self) -> None:
        """Merkt die letzte Position vor dem ersten Aufruf (fall_eroeffnet und Ähnliches)."""
        sql = text(
            "SELECT coalesce(max(position), 0) FROM r3cosint.arbeitsspur WHERE fall_kennung = :f"
        )
        if self.verbindung.in_transaction():
            wert = (
                await self.verbindung.execute(sql, {"f": self.kontext.fall_kennung})
            ).scalar()
        else:
            async with self.verbindung.begin():
                wert = (
                    await self.verbindung.execute(sql, {"f": self.kontext.fall_kennung})
                ).scalar()
        self.position = int(wert or 0)

    def ps(self, wert: str) -> str:
        return _pseudonym(self.schluessel, wert)


def _aufruf_pruefen(
    eintraege: Sequence[Mapping[str, Any]],
    rueckgabe: Any,
    *,
    methoden: Mapping[int, str] | None = None,
    listenstand: str,
) -> None:
    """Gemeinsame Zusicherungen je Aufruf (Nachbesserung S2.1.1, gemeinsam für alle vier)."""
    assert eintraege, "jeder Aufruf erzeugt mindestens einen Eintrag"
    kennungen = {e["versuch_kennung"] for e in eintraege}
    assert kennungen == {str(rueckgabe.versuch_kennung)}, (
        "eine versuch_kennung je Aufruf"
    )
    UUID(str(rueckgabe.versuch_kennung))
    for e in eintraege:
        assert e["listenstand"] == listenstand
        if methoden is not None and e["schritt"] in methoden:
            assert e["methode"] == methoden[e["schritt"]], (e["schritt"], e["methode"])
    for i, e in enumerate(eintraege):
        if e["ergebnis"] == "zugelassen":
            folge = eintraege[i + 1] if i + 1 < len(eintraege) else None
            assert folge is not None, "auf zugelassen folgt ein Eintrag"
            assert folge["ergebnis"] in ("beantwortet", "verbindung_fehlgeschlagen")
            assert folge["schritt"] == e["schritt"]
        if e["ergebnis"] in ("beantwortet", "verbindung_fehlgeschlagen"):
            assert i > 0 and eintraege[i - 1]["ergebnis"] == "zugelassen"
            assert eintraege[i - 1]["schritt"] == e["schritt"]
    schritte = [e["schritt"] for e in eintraege]
    assert schritte == sorted(schritte)
    assert rueckgabe.schritt == schritte[-1]


def _ausgaben(
    caplog: pytest.LogCaptureFixture,
    capfd: pytest.CaptureFixture[str],
    gewarnt: Iterable[warnings.WarningMessage],
) -> list[str]:
    texte = [f"{r.name} {r.getMessage()}" for r in caplog.records]
    aus, fehler = capfd.readouterr()
    texte += [aus, fehler]
    texte += [str(w.message) for w in gewarnt]
    return texte


def _ohne(texte: Iterable[str], verboten: Iterable[str], ort: str) -> None:
    verboten = [v for v in verboten if v]
    for t in texte:
        for v in verboten:
            assert v.casefold() not in t.casefold(), f"{ort}: verbotener Wert gefunden"


async def _gegenprobe_trennschaerfe(caplog: pytest.LogCaptureFixture) -> None:
    """Hilfsfall ohne ausgang: httpx auf INFO protokolliert die URL samt MERKMAL (Trennschärfe)."""
    logger = logging.getLogger("httpx")
    vorher = logger.level
    logger.setLevel(logging.INFO)
    caplog.clear()
    try:
        async with httpx.AsyncClient(
            transport=httpx.MockTransport(lambda r: httpx.Response(204))
        ) as c:
            await c.get(f"http://gegenprobe.test/{MERKMAL}")
        assert any(MERKMAL in r.getMessage() for r in caplog.records), (
            "Gegenprobe: die Erfassung der Prozessausgaben findet MERKMAL nicht"
        )
    finally:
        logger.setLevel(vorher)
        caplog.clear()


async def _ketten_unversehrt(verbindung: AsyncConnection, fall: UUID) -> None:
    async def beide() -> tuple[dict[Spur, Befund], dict[Spur, Befund]]:
        if verbindung.in_transaction():
            return await kette_pruefen(verbindung, fall), await kette_pruefen_datenbank(
                verbindung, fall
            )
        async with verbindung.begin():
            a = await kette_pruefen(verbindung, fall)
        async with verbindung.begin():
            b = await kette_pruefen_datenbank(verbindung, fall)
        return a, b

    anwendungsweg, datenbankweg = await beide()
    for weg in (anwendungsweg, datenbankweg):
        for spur in Spur:
            assert weg[spur].unversehrt, (spur, weg[spur])
    assert anwendungsweg == datenbankweg


@asynccontextmanager
async def _beobachtet(
    caplog: pytest.LogCaptureFixture,
) -> AsyncIterator[list[warnings.WarningMessage]]:
    """Prozessausgaben ab DEBUG für alle Logger, Wurzel auf NOTSET, Warnungen erfasst."""
    await _gegenprobe_trennschaerfe(caplog)
    wurzel = logging.getLogger()
    vorher = wurzel.level
    caplog.set_level(1)
    wurzel.setLevel(logging.NOTSET)
    with warnings.catch_warnings(record=True) as gewarnt:
        warnings.simplefilter("always")
        try:
            yield gewarnt
        finally:
            wurzel.setLevel(vorher)


async def _lauf(spurkontext: Any, fallschluessel_lesen: Any) -> _Lauf:
    lauf = _Lauf(spurkontext, await fallschluessel_lesen(spurkontext.fall_kennung))
    await lauf.startposition()
    return lauf


def _verbindungen(g: Any) -> int:
    return int(g.verbindungen)


def _abschluss(lauf: _Lauf, texte: list[str], verboten: Iterable[str]) -> None:
    """MERKMAL, Zielformen und Rohformen weder in einer Nutzlast noch in einer Prozessausgabe."""
    verboten = [MERKMAL, *verboten]
    _ohne(lauf.nutzlasten_roh, verboten, "Nutzlast")
    _ohne(texte, verboten, "Prozessausgabe")


# =================================================================================================
# R3-F-015
# =================================================================================================


async def test_R3_F_015_ziel_ausserhalb_abgewiesen(
    spurkontext: Any,
    netzwaechter: Any,
    aufloeser_steuerbar: Any,
    gegenstelle_ausserhalb: Any,
    fallschluessel_lesen: Any,
    tmp_path: Path,
    caplog: pytest.LogCaptureFixture,
    capfd: pytest.CaptureFixture[str],
) -> None:
    """(a) Ziele ausserhalb der Liste, (b) Gegenprobe Literal-Eintrag, (c) content-encoding gzip."""
    lauf = await _lauf(spurkontext, fallschluessel_lesen)
    aussen = gegenstelle_ausserhalb.anschluss
    async with (
        _gegenstelle(_skript("treffer", 1)) as a,
        _gegenstelle(_skript("komprimiert")) as c,
        _beobachtet(caplog) as gewarnt,
    ):
        liste, stand = _liste(
            tmp_path,
            [
                _E("test.ziel-a", "http", a.anschluss, adresse="127.0.0.1"),
                _E("test.ziel-c", "http", c.anschluss, adresse="127.0.0.1"),
            ],
        )
        client = Client(positivliste=liste, aufloeser=aufloeser_steuerbar)
        verboten: list[str] = ["fremd.ausserhalb.test"]

        # (a) je Ziel ausserhalb: nicht_in_positivliste, ohne Auflösung und Verbindung
        faelle = [
            ("http", "fremd.ausserhalb.test", aussen, "http://fremd.ausserhalb.test"),
            ("http", "127.0.0.2", aussen, "http://127.0.0.2"),
            ("http", "127.0.0.1", aussen, "http://127.0.0.1"),
            ("https", "127.0.0.1", a.anschluss, "https://127.0.0.1"),
        ]
        for schema, rechner, anschluss, _ in faelle:
            rueckgabe = await lauf.anfragen(client, _url(schema, rechner, anschluss))
            assert isinstance(rueckgabe, Abweisung)
            assert rueckgabe.ergebnis == "nicht_in_positivliste"
            assert rueckgabe.schritt == 0
            eintraege = await lauf.neu()
            assert len(eintraege) == 1, "genau ein neuer Eintrag verbindungsversuch"
            e = eintraege[0]
            assert e["ergebnis"] == "nicht_in_positivliste" and e["schritt"] == 0
            assert "listeneintrag" not in e
            zielform = _zielform(schema, rechner, anschluss)
            assert e["ziel_pseudonym"] == lauf.ps(zielform), (
                "Pseudonym des versuchten Ziels"
            )
            assert e["schema"] == schema and e["anschluss"] == anschluss
            assert e["methode"] == "GET"
            _aufruf_pruefen(eintraege, rueckgabe, listenstand=stand)
            verboten.append(zielform)
        assert sum(aufloeser_steuerbar.zaehler.values()) == 0, "Auflöser ohne Aufruf"
        assert _verbindungen(gegenstelle_ausserhalb) == 0
        assert _verbindungen(a) == 0

        # Eigener Abweisungsfall: MERKMAL in den Benutzerangaben
        rueckgabe = await lauf.anfragen(
            client, f"http://{MERKMAL}:{MERKMAL}@127.0.0.1:{a.anschluss}/"
        )
        assert isinstance(rueckgabe, Abweisung)
        assert rueckgabe.ergebnis == "url_nicht_auswertbar"
        eintraege = await lauf.neu()
        assert [e["ergebnis"] for e in eintraege] == ["url_nicht_auswertbar"]
        _aufruf_pruefen(eintraege, rueckgabe, listenstand=stand)
        assert _verbindungen(a) == 0

        # (b) Gegenprobe: Literal-Eintrag 127.0.0.1 mit dem Anschluss der Gegenstelle
        rueckgabe = await lauf.anfragen(client, _url("http", "127.0.0.1", a.anschluss))
        assert isinstance(rueckgabe, Antwort), type(rueckgabe)
        assert _verbindungen(a) == 1, "genau eine Verbindung"
        eintraege = await lauf.neu()
        assert [e["ergebnis"] for e in eintraege] == ["zugelassen", "beantwortet"]
        zielform = _zielform("http", "127.0.0.1", a.anschluss)
        for e in eintraege:
            assert e["listeneintrag"] == "test.ziel-a"
            assert e["ziel_pseudonym"] == lauf.ps(zielform)
            assert e["adresse_pseudonym"] == lauf.ps("127.0.0.1")
            assert e["zielart"] == "ipv4" and e["adressbereich"] == "rueckschleife"
        assert eintraege[1]["status"] == rueckgabe.status
        assert eintraege[1]["antwort_bytes"] == len(rueckgabe.koerper)
        assert rueckgabe.listeneintrag == "test.ziel-a"
        anfrage = a.anfragen[0]
        assert anfrage.methode == "GET"
        assert eintraege[0]["methode"] == anfrage.methode
        assert str(anfrage.accept_encoding).strip().lower() == "identity"
        _aufruf_pruefen(eintraege, rueckgabe, listenstand=stand)
        verboten.append(zielform)

        # (c) content-encoding gzip trotz accept-encoding identity: Fehlschlag antwort_ungueltig
        rueckgabe = await lauf.anfragen(client, _url("http", "127.0.0.1", c.anschluss))
        assert isinstance(rueckgabe, Fehlschlag), type(rueckgabe)
        assert rueckgabe.fehlerart == "antwort_ungueltig"
        eintraege = await lauf.neu()
        assert [e["ergebnis"] for e in eintraege] == [
            "zugelassen",
            "verbindung_fehlgeschlagen",
        ]
        assert eintraege[1]["fehlerart"] == "antwort_ungueltig"
        assert _verbindungen(c) == 1
        _aufruf_pruefen(eintraege, rueckgabe, listenstand=stand)
        verboten.append(_zielform("http", "127.0.0.1", c.anschluss))

        texte = _ausgaben(caplog, capfd, gewarnt)
    _abschluss(lauf, texte, verboten)
    await _ketten_unversehrt(lauf.verbindung, spurkontext.fall_kennung)


# =================================================================================================
# R3-F-028: Weiterleitung
# =================================================================================================


async def test_R3_F_028_weiterleitung_wird_erneut_geprueft(
    spurkontext: Any,
    netzwaechter: Any,
    aufloeser_steuerbar: Any,
    gegenstelle_ausserhalb: Any,
    fallschluessel_lesen: Any,
    tmp_path: Path,
    caplog: pytest.LogCaptureFixture,
    capfd: pytest.CaptureFixture[str],
) -> None:
    """Jeder Weiterleitungsschritt ist ein eigener, erneut geprüfter Versuch (W2-50 bis W2-53)."""
    lauf = await _lauf(spurkontext, fallschluessel_lesen)
    verboten: list[str] = ["umweg.ausserhalb.test"]
    zaehler = 0

    def name() -> str:
        nonlocal zaehler
        zaehler += 1
        return f"l{zaehler}"

    # Wirksame Einstellung am Ergebnis von bibliotheksclient_bauen (M1, M7)
    bib = bibliotheksclient_bauen(
        httpx.MockTransport(lambda r: httpx.Response(204)), 5.0
    )
    try:
        assert bib.follow_redirects is False
        assert bib.trust_env is False
    finally:
        await bib.aclose()

    async def lese(
        rueckgabe: Any, *, methoden: Mapping[int, str] | None = None, stand: str
    ) -> list[dict[str, Any]]:
        eintraege = await lauf.neu()
        _aufruf_pruefen(eintraege, rueckgabe, methoden=methoden, listenstand=stand)
        return eintraege

    def kette(
        eintraege: Sequence[Mapping[str, Any]], zielformen: Mapping[int, str]
    ) -> None:
        """ziel_pseudonym je Schritt und ausgangsziel_pseudonym gleich dem Ziel des vorigen Schritts."""
        for e in eintraege:
            s = e["schritt"]
            if "ziel_pseudonym" in e:
                assert e["ziel_pseudonym"] == lauf.ps(zielformen[s]), s
            if s > 0:
                assert e["ausgangsziel_pseudonym"] == lauf.ps(zielformen[s - 1]), s

    aussen = gegenstelle_ausserhalb.anschluss
    async with _beobachtet(caplog) as gewarnt:
        # ---- Weiterleitung nach ausserhalb, anderer Anschluss, anderes Schema ------------------
        async with _gegenstelle(_skript("treffer", 1)) as b:
            for schema, rechner, ziel_anschluss in (
                ("http", "umweg.ausserhalb.test", aussen),
                ("http", "127.0.0.1", aussen),
                ("https", "127.0.0.1", b.anschluss),
            ):
                async with _gegenstelle(
                    _skript("weiterleitung", 302, _url(schema, rechner, ziel_anschluss))
                ) as a:
                    liste, stand = _liste(
                        tmp_path,
                        [
                            _E("test.ziel-a", "http", a.anschluss, adresse="127.0.0.1"),
                            _E("test.ziel-b", "http", b.anschluss, adresse="127.0.0.1"),
                        ],
                        name=name(),
                    )
                    client = Client(positivliste=liste, aufloeser=aufloeser_steuerbar)
                    rueckgabe = await lauf.anfragen(
                        client, _url("http", "127.0.0.1", a.anschluss)
                    )
                    assert isinstance(rueckgabe, Abweisung), (schema, rechner)
                    assert rueckgabe.ergebnis == "nicht_in_positivliste"
                    assert rueckgabe.schritt == 1
                    eintraege = await lese(
                        rueckgabe, methoden={0: "GET", 1: "GET"}, stand=stand
                    )
                    assert [(e["schritt"], e["ergebnis"]) for e in eintraege] == [
                        (0, "zugelassen"),
                        (0, "beantwortet"),
                        (1, "nicht_in_positivliste"),
                    ]
                    assert (
                        eintraege[1]["status"] == 302
                        and eintraege[1]["antwort_bytes"] == 0
                    )
                    z0 = _zielform("http", "127.0.0.1", a.anschluss)
                    z1 = _zielform(schema, rechner, ziel_anschluss)
                    kette(eintraege, {0: z0, 1: z1})
                    assert (
                        eintraege[2]["ausgangsziel_pseudonym"]
                        == eintraege[0]["ziel_pseudonym"]
                    )
                    assert _verbindungen(a) == 1
                    verboten += [z0, z1]
            assert _verbindungen(b) == 0, "keine Verbindung zum Weiterleitungsziel"
        assert _verbindungen(gegenstelle_ausserhalb) == 0
        assert sum(aufloeser_steuerbar.zaehler.values()) == 0

        # ---- Gegenprobe: Weiterleitung auf ein Listenziel wird geprüft und ausgeführt -----------
        async with _gegenstelle(_skript("treffer", 1)) as b:
            async with _gegenstelle(
                _skript("weiterleitung", 302, _url("http", "127.0.0.1", b.anschluss))
            ) as a:
                liste, stand = _liste(
                    tmp_path,
                    [
                        _E("test.ziel-a", "http", a.anschluss, adresse="127.0.0.1"),
                        _E("test.ziel-b", "http", b.anschluss, adresse="127.0.0.1"),
                    ],
                    name=name(),
                )
                client = Client(positivliste=liste, aufloeser=aufloeser_steuerbar)
                rueckgabe = await lauf.anfragen(
                    client, _url("http", "127.0.0.1", a.anschluss)
                )
                assert isinstance(rueckgabe, Antwort) and rueckgabe.schritt == 1
                eintraege = await lese(
                    rueckgabe, methoden={0: "GET", 1: "GET"}, stand=stand
                )
                assert [(e["schritt"], e["ergebnis"]) for e in eintraege] == [
                    (0, "zugelassen"),
                    (0, "beantwortet"),
                    (1, "zugelassen"),
                    (1, "beantwortet"),
                ]
                assert eintraege[2]["listeneintrag"] == "test.ziel-b"
                kette(
                    eintraege,
                    {
                        0: _zielform("http", "127.0.0.1", a.anschluss),
                        1: _zielform("http", "127.0.0.1", b.anschluss),
                    },
                )
                assert _verbindungen(a) == 1 and _verbindungen(b) == 1

        # ---- Kette von genau N Weiterleitungen; eine weitere: kette_zu_lang --------------------
        for hoechstzahl in (3, 1):
            for weitere in (False, True):
                folge = [
                    _skript("weiterleitung", 302, f"/w{i}/") for i in range(hoechstzahl)
                ]
                folge.append(
                    _skript("weiterleitung", 302, "/zuviel/")
                    if weitere
                    else _skript("treffer", 1)
                )
                async with _gegenstelle(folge) as a:
                    liste, stand = _liste(
                        tmp_path,
                        [_E("test.ziel-a", "http", a.anschluss, adresse="127.0.0.1")],
                        hoechstzahl=hoechstzahl,
                        name=name(),
                    )
                    client = Client(positivliste=liste, aufloeser=aufloeser_steuerbar)
                    rueckgabe = await lauf.anfragen(
                        client, _url("http", "127.0.0.1", a.anschluss)
                    )
                    eintraege = await lese(rueckgabe, stand=stand)
                    zugelassen = [e for e in eintraege if e["ergebnis"] == "zugelassen"]
                    assert len(zugelassen) == hoechstzahl + 1, "N+1 Einträge zugelassen"
                    assert _verbindungen(a) == hoechstzahl + 1
                    if weitere:
                        assert isinstance(rueckgabe, Abweisung)
                        assert rueckgabe.ergebnis == "kette_zu_lang"
                        assert rueckgabe.schritt == hoechstzahl + 1
                        letzter = eintraege[-1]
                        assert letzter["ergebnis"] == "kette_zu_lang"
                        assert letzter["schritt"] == hoechstzahl + 1
                    else:
                        assert isinstance(rueckgabe, Antwort)
                        assert rueckgabe.schritt == hoechstzahl
                    z = _zielform("http", "127.0.0.1", a.anschluss)
                    kette(eintraege, dict.fromkeys(range(hoechstzahl + 2), z))
        assert sum(aufloeser_steuerbar.zaehler.values()) == 0

        # ---- Randfall ST-S21-F-07: Schritt N nicht auswertbar ergibt url_nicht_auswertbar ------
        for unauswertbar in (
            _skript("weiterleitung", 302, ("/eins/", "/zwei/")),
            _skript("weiterleitung", 302, "http://[::1"),
        ):
            folge = [_skript("weiterleitung", 302, f"/w{i}/") for i in range(3)]
            folge.append(unauswertbar)
            async with _gegenstelle(folge) as a:
                liste, stand = _liste(
                    tmp_path,
                    [_E("test.ziel-a", "http", a.anschluss, adresse="127.0.0.1")],
                    name=name(),
                )
                client = Client(positivliste=liste, aufloeser=aufloeser_steuerbar)
                rueckgabe = await lauf.anfragen(
                    client, _url("http", "127.0.0.1", a.anschluss)
                )
                assert isinstance(rueckgabe, Abweisung)
                assert (
                    rueckgabe.ergebnis == "url_nicht_auswertbar"
                    and rueckgabe.schritt == 4
                )
                eintraege = await lese(rueckgabe, stand=stand)
                assert eintraege[-1]["ergebnis"] == "url_nicht_auswertbar"
                assert "kette_zu_lang" not in {e["ergebnis"] for e in eintraege}
                assert _verbindungen(a) == 4

        # ---- (d) Zielwechsel: keine Kopfzeilen und kein Körper des Aufrufers -------------------
        kopf = {"x-api-key": "synthetisch"}
        koerper = b"synthetischer-koerper-0001"
        faelle_d: tuple[tuple[int, Literal["GET", "POST"], bool, bool], ...] = (
            (302, "POST", True, True),
            (307, "POST", True, False),
            (308, "POST", True, False),
            (307, "GET", False, True),
            (308, "GET", False, True),
        )
        for status, methode, mit_koerper, verfolgt in faelle_d:
            async with _gegenstelle(_skript("treffer", 1)) as b:
                async with _gegenstelle(
                    _skript(
                        "weiterleitung", status, _url("http", "127.0.0.1", b.anschluss)
                    )
                ) as a:
                    liste, stand = _liste(
                        tmp_path,
                        [
                            _E("test.ziel-a", "http", a.anschluss, adresse="127.0.0.1"),
                            _E("test.ziel-b", "http", b.anschluss, adresse="127.0.0.1"),
                        ],
                        name=name(),
                    )
                    client = Client(positivliste=liste, aufloeser=aufloeser_steuerbar)
                    rueckgabe = await lauf.anfragen(
                        client,
                        _url("http", "127.0.0.1", a.anschluss),
                        methode=methode,
                        kopfzeilen=kopf,
                        koerper=koerper if mit_koerper else None,
                    )
                    erwartete_methode = "GET" if status == 302 else methode
                    eintraege = await lese(
                        rueckgabe,
                        methoden={0: methode, 1: erwartete_methode},
                        stand=stand,
                    )
                    assert _kopfzeile(a.anfragen[0], "x-api-key") == [kopf["x-api-key"]]
                    if verfolgt:
                        assert isinstance(rueckgabe, Antwort) and rueckgabe.schritt == 1
                        assert _verbindungen(b) == 1
                        assert b.anfragen[0].methode == erwartete_methode
                        assert _kopfzeile(b.anfragen[0], "x-api-key") == [], "M35"
                        assert _koerper(b.anfragen[0]) == b"", (
                            "kein Körper beim Zielwechsel"
                        )
                    else:
                        assert isinstance(rueckgabe, Antwort), (
                            "3xx ist die Antwort (M49)"
                        )
                        assert rueckgabe.status == status and rueckgabe.schritt == 0
                        assert [(e["schritt"], e["ergebnis"]) for e in eintraege] == [
                            (0, "zugelassen"),
                            (0, "beantwortet"),
                        ]
                        assert eintraege[1]["status"] == status
                        assert _verbindungen(b) == 0

        # ---- (e) Weiterleitung auf dasselbe Ziel: Kopfzeilen und Körper bleiben bei 307/308 ----
        for status in (307, 308):
            async with _gegenstelle(
                [_skript("weiterleitung", status, "/weiter/"), _skript("treffer", 1)]
            ) as a:
                liste, stand = _liste(
                    tmp_path,
                    [_E("test.ziel-a", "http", a.anschluss, adresse="127.0.0.1")],
                    name=name(),
                )
                client = Client(positivliste=liste, aufloeser=aufloeser_steuerbar)
                rueckgabe = await lauf.anfragen(
                    client,
                    _url("http", "127.0.0.1", a.anschluss),
                    methode="POST",
                    kopfzeilen=kopf,
                    koerper=koerper,
                )
                assert isinstance(rueckgabe, Antwort) and rueckgabe.schritt == 1
                await lese(rueckgabe, methoden={0: "POST", 1: "POST"}, stand=stand)
                zweite = a.anfragen[1]
                assert zweite.methode == "POST"
                assert _koerper(zweite) == koerper
                assert _kopfzeile(zweite, "x-api-key") == [kopf["x-api-key"]]

        # ---- (f) Rückkehr zum ersten Ziel: einmal verworfen, bleibt verworfen ------------------
        platz: dict[str, int] = {}
        async with (
            _gegenstelle(_skript("weiterleitung", 302, _Verweis(platz, "a"))) as b,
            _gegenstelle(
                [
                    _skript(
                        "weiterleitung", 302, _url("http", "127.0.0.1", b.anschluss)
                    ),
                    _skript("treffer", 1),
                ]
            ) as a,
        ):
            platz["a"] = a.anschluss
            liste, stand = _liste(
                tmp_path,
                [
                    _E("test.ziel-a", "http", a.anschluss, adresse="127.0.0.1"),
                    _E("test.ziel-b", "http", b.anschluss, adresse="127.0.0.1"),
                ],
                name=name(),
            )
            client = Client(positivliste=liste, aufloeser=aufloeser_steuerbar)
            rueckgabe = await lauf.anfragen(
                client, _url("http", "127.0.0.1", a.anschluss), kopfzeilen=kopf
            )
            assert isinstance(rueckgabe, Antwort) and rueckgabe.schritt == 2
            await lese(rueckgabe, methoden={0: "GET", 1: "GET", 2: "GET"}, stand=stand)
            assert _kopfzeile(a.anfragen[0], "x-api-key") == [kopf["x-api-key"]]
            assert _kopfzeile(b.anfragen[0], "x-api-key") == []
            assert _kopfzeile(a.anfragen[1], "x-api-key") == [], (
                "Rückkehr ohne x-api-key"
            )

        # ---- (g) 303 auf POST: methode GET in Schritt 1, ausgangsziel wie oben -----------------
        async with _gegenstelle(_skript("treffer", 1)) as b:
            async with _gegenstelle(
                _skript("weiterleitung", 303, _url("http", "127.0.0.1", b.anschluss))
            ) as a:
                liste, stand = _liste(
                    tmp_path,
                    [
                        _E("test.ziel-a", "http", a.anschluss, adresse="127.0.0.1"),
                        _E("test.ziel-b", "http", b.anschluss, adresse="127.0.0.1"),
                    ],
                    name=name(),
                )
                client = Client(positivliste=liste, aufloeser=aufloeser_steuerbar)
                rueckgabe = await lauf.anfragen(
                    client,
                    _url("http", "127.0.0.1", a.anschluss),
                    methode="POST",
                    koerper=koerper,
                )
                eintraege = await lese(
                    rueckgabe, methoden={0: "POST", 1: "GET"}, stand=stand
                )
                assert b.anfragen[0].methode == "GET"
                kette(
                    eintraege,
                    {
                        0: _zielform("http", "127.0.0.1", a.anschluss),
                        1: _zielform("http", "127.0.0.1", b.anschluss),
                    },
                )

        # ---- (h) Gesamtfrist je Aufruf über alle Schritte -------------------------------------
        frist = 1.0
        toleranz = 1.5
        async with _gegenstelle(_skript("zeitueberschreitung")) as b:
            async with _gegenstelle(
                _skript("weiterleitung", 302, _url("http", "127.0.0.1", b.anschluss))
            ) as a:
                liste, stand = _liste(
                    tmp_path,
                    [
                        _E("test.ziel-a", "http", a.anschluss, adresse="127.0.0.1"),
                        _E("test.ziel-b", "http", b.anschluss, adresse="127.0.0.1"),
                    ],
                    name=name(),
                )
                client = Client(positivliste=liste, aufloeser=aufloeser_steuerbar)
                beginn = time.monotonic()
                rueckgabe = await lauf.anfragen(
                    client,
                    _url("http", "127.0.0.1", a.anschluss),
                    grenzen=Antwortgrenzen(
                        antwortgroesse_bytes=65536, frist_sekunden=frist
                    ),
                )
                dauer = time.monotonic() - beginn
                assert isinstance(rueckgabe, Fehlschlag)
                assert (
                    rueckgabe.fehlerart == "zeitueberschreitung"
                    and rueckgabe.schritt == 1
                )
                assert dauer <= frist + toleranz, f"Gesamtdauer {dauer:.2f} s"
                eintraege = await lese(rueckgabe, stand=stand)
                assert [(e["schritt"], e["ergebnis"]) for e in eintraege][-2:] == [
                    (1, "zugelassen"),
                    (1, "verbindung_fehlgeschlagen"),
                ]
                assert eintraege[-1]["fehlerart"] == "zeitueberschreitung"

        # ---- 3xx mit content-encoding gzip: antwort_ungueltig, nicht verfolgt ------------------
        async with _gegenstelle(_skript("treffer", 1)) as b:
            async with _gegenstelle(
                _skript(
                    "weiterleitung",
                    302,
                    _url("http", "127.0.0.1", b.anschluss),
                    komprimiert=True,
                )
            ) as a:
                liste, stand = _liste(
                    tmp_path,
                    [
                        _E("test.ziel-a", "http", a.anschluss, adresse="127.0.0.1"),
                        _E("test.ziel-b", "http", b.anschluss, adresse="127.0.0.1"),
                    ],
                    name=name(),
                )
                client = Client(positivliste=liste, aufloeser=aufloeser_steuerbar)
                rueckgabe = await lauf.anfragen(
                    client, _url("http", "127.0.0.1", a.anschluss)
                )
                assert isinstance(rueckgabe, Fehlschlag)
                assert (
                    rueckgabe.fehlerart == "antwort_ungueltig"
                    and rueckgabe.schritt == 0
                )
                eintraege = await lese(rueckgabe, stand=stand)
                assert [e["ergebnis"] for e in eintraege] == [
                    "zugelassen",
                    "verbindung_fehlgeschlagen",
                ]
                assert _verbindungen(b) == 0

        texte = _ausgaben(caplog, capfd, gewarnt)
    _abschluss(lauf, texte, verboten)
    await _ketten_unversehrt(lauf.verbindung, spurkontext.fall_kennung)


# =================================================================================================
# R3-F-028: Namensauflösung
# =================================================================================================

NAME = "dienst.beispiel.test"
NAME_IDN_A = "xn--bcher-kva.beispiel.test"

# Je Klasse des Vorrats ein Abweisungsfall (Zeile ausgang.aufloesung; Reihenfolge der Klassen und
# Messung vom 2026-11-10 in 3.13.16 und 3.13.18, Fremdbeleg im Bericht): erwartetes adressbereich.
KLASSENFAELLE: tuple[tuple[str, str], ...] = (
    ("0.0.0.0", "unspezifiziert"),  # noqa: S104 (Adresswert, keine Bindung)
    ("::", "unspezifiziert"),
    ("127.0.0.1", "rueckschleife"),
    ("::1", "rueckschleife"),
    ("169.254.1.1", "verbindungslokal"),
    ("fe80::1", "verbindungslokal"),
    ("fec0::1", "standortlokal"),
    ("224.0.0.1", "multicast"),
    ("ff02::1", "multicast"),
    ("10.0.0.1", "privat"),
    ("192.0.2.1", "privat"),
    ("240.0.0.1", "privat"),
    ("2002:a00:1::", "privat"),
    ("64:ff9b::a00:1", "reserviert"),
    ("::10.0.0.1", "reserviert"),
    ("5f00::1", "reserviert"),
    ("192.88.99.1", "abgekuendigt"),
    ("192.0.0.9", "protokollzuweisung"),
    ("192.0.0.10", "protokollzuweisung"),
    ("2001:1::1", "protokollzuweisung"),
    ("2001:1::2", "protokollzuweisung"),
    # 2001:1::3: ipaddress liefert is_private wahr (gemessen), privat steht vor protokollzuweisung
    # in der festgelegten Reihenfolge; Widerspruch zur Zeile Tests Abnahme: DT-S21-A-01.
    ("2001:1::3", "privat"),
    ("100.64.0.1", "nicht_global"),
)


async def test_R3_F_028_namensaufloesung_einmal_und_geprueft(
    spurkontext: Any,
    netzwaechter: Any,
    aufloeser_steuerbar: Any,
    verbindungsweg_ersatz: Any,
    fallschluessel_lesen: Any,
    tmp_path: Path,
    caplog: pytest.LogCaptureFixture,
    capfd: pytest.CaptureFixture[str],
) -> None:
    """Einmal auflösen, jede Adresse prüfen, gegen genau diese Adresse verbinden (W2-54 bis W2-57)."""
    tk = ipaddress.ip_address(TESTKONSTANTE)
    # Vorbedingung (GK-5, DS-S21-12): die Testkonstante ist öffentlich und is_global wahr.
    assert tk.is_global, "Vorbedingung: is_global der Testkonstante"
    assert adressbereich(tk) == "oeffentlich", "Vorbedingung: Testkonstante oeffentlich"
    lauf = await _lauf(spurkontext, fallschluessel_lesen)
    verboten: list[str] = [
        NAME,
        NAME_IDN_A,
        "bücher.beispiel.test",
        "DIENST.Beispiel.TEST",
    ]

    def ersatzaufrufe() -> int:
        return len(verbindungsweg_ersatz.aufrufe)

    async with _gegenstelle(_skript("treffer", 1)) as g, _beobachtet(caplog) as gewarnt:
        liste, stand = _liste(
            tmp_path,
            [
                _E("test.dienst", "http", g.anschluss, rechnername=NAME),
                _E("test.dienst-idn", "http", g.anschluss, rechnername=NAME_IDN_A),
            ],
        )
        client = Client(
            positivliste=liste,
            aufloeser=aufloeser_steuerbar,
            verbindungsweg=verbindungsweg_ersatz,
        )
        zielform = _zielform("http", NAME, g.anschluss)
        verboten.append(zielform)

        # ---- zulässiger Fall: Name auf die Testkonstante ---------------------------------------
        aufloeser_steuerbar.setzen(NAME, (tk,))
        rueckgabe = await lauf.anfragen(client, _url("http", NAME, g.anschluss))
        assert isinstance(rueckgabe, Antwort), type(rueckgabe)
        assert aufloeser_steuerbar.zaehler[NAME] == 1, "genau eine Auflösung"
        assert ersatzaufrufe() == 1
        aufruf = verbindungsweg_ersatz.aufrufe[0]
        assert ipaddress.ip_address(str(aufruf.adresse)) == tk, (
            "Verbindung gegen genau diese Adresse"
        )
        assert aufruf.name_oder_adresse == NAME
        assert aufruf.anschluss == g.anschluss
        assert _verbindungen(g) == 1
        assert str(g.anfragen[0].host).rsplit(":", 1)[0] == NAME, (
            "Host-Kopfzeile des Namens"
        )
        eintraege = await lauf.neu()
        _aufruf_pruefen(eintraege, rueckgabe, methoden={0: "GET"}, listenstand=stand)
        assert [e["ergebnis"] for e in eintraege] == ["zugelassen", "beantwortet"]
        for e in eintraege:
            assert e["zielart"] == "name" and e["adressbereich"] == "oeffentlich"
            assert e["ziel_pseudonym"] == lauf.ps(zielform)
            assert e["adresse_pseudonym"] == lauf.ps(str(tk))
            assert e["listeneintrag"] == "test.dienst"

        # ---- FA-S21-04: zwei Versuche, der zweite erhält 127.0.0.1 -----------------------------
        aufloeser_steuerbar.setzen(NAME, (tk,), (ipaddress.ip_address("127.0.0.1"),))
        basis = aufloeser_steuerbar.zaehler[NAME]
        erster = await lauf.anfragen(client, _url("http", NAME, g.anschluss))
        assert isinstance(erster, Antwort)
        await lauf.neu()
        zweiter = await lauf.anfragen(client, _url("http", NAME, g.anschluss))
        assert (
            isinstance(zweiter, Abweisung)
            and zweiter.ergebnis == "bereich_nicht_oeffentlich"
        )
        eintraege = await lauf.neu()
        _aufruf_pruefen(eintraege, zweiter, listenstand=stand)
        assert [e["ergebnis"] for e in eintraege] == ["bereich_nicht_oeffentlich"]
        assert eintraege[0]["adressbereich"] == "rueckschleife"
        assert eintraege[0]["adresse_pseudonym"] == lauf.ps("127.0.0.1")
        assert aufloeser_steuerbar.zaehler[NAME] - basis == 2, "Zähler des Auflösers 2"
        assert ersatzaufrufe() == 2 and _verbindungen(g) == 2, (
            "keine Verbindung im zweiten"
        )

        # ---- je Klasse des Vorrats ein Abweisungsfall ohne Verbindung ---------------------------
        for wert, klasse in KLASSENFAELLE:
            adresse = ipaddress.ip_address(wert)
            aufloeser_steuerbar.setzen(NAME, (adresse,))
            vorher = (
                aufloeser_steuerbar.zaehler[NAME],
                ersatzaufrufe(),
                _verbindungen(g),
            )
            rueckgabe = await lauf.anfragen(client, _url("http", NAME, g.anschluss))
            assert isinstance(rueckgabe, Abweisung), wert
            assert rueckgabe.ergebnis == "bereich_nicht_oeffentlich", wert
            eintraege = await lauf.neu()
            _aufruf_pruefen(eintraege, rueckgabe, listenstand=stand)
            assert len(eintraege) == 1
            assert eintraege[0]["adressbereich"] == klasse, (
                wert,
                eintraege[0]["adressbereich"],
            )
            assert eintraege[0]["adresse_pseudonym"] == lauf.ps(str(adresse))
            assert eintraege[0]["listeneintrag"] == "test.dienst"
            nachher = (
                aufloeser_steuerbar.zaehler[NAME],
                ersatzaufrufe(),
                _verbindungen(g),
            )
            assert nachher == (vorher[0] + 1, vorher[1], vorher[2]), wert

        # ---- mehrere Adressen nach E-S21-02: eine nicht öffentliche weist den Versuch ab -------
        for antwort in (
            (tk, ipaddress.ip_address("10.0.0.1")),
            (ipaddress.ip_address("10.0.0.1"), tk),
        ):
            aufloeser_steuerbar.setzen(NAME, antwort)
            vorher_m = (ersatzaufrufe(), _verbindungen(g))
            rueckgabe = await lauf.anfragen(client, _url("http", NAME, g.anschluss))
            assert isinstance(rueckgabe, Abweisung)
            assert rueckgabe.ergebnis == "bereich_nicht_oeffentlich"
            eintraege = await lauf.neu()
            _aufruf_pruefen(eintraege, rueckgabe, listenstand=stand)
            assert eintraege[0]["adressbereich"] == "privat"
            assert eintraege[0]["adresse_pseudonym"] == lauf.ps("10.0.0.1")
            assert (ersatzaufrufe(), _verbindungen(g)) == vorher_m

        # ---- Schreibweisen des Namens entscheiden wie die Normalform ---------------------------
        aufloeser_steuerbar.setzen(NAME, (tk,))
        aufloeser_steuerbar.setzen(NAME_IDN_A, (tk,))
        for rechner, normal, kennung in (
            ("DIENST.Beispiel.TEST", NAME, "test.dienst"),
            ("dienst.beispiel.test.", NAME, "test.dienst"),
            ("bücher.beispiel.test", NAME_IDN_A, "test.dienst-idn"),
            ("BÜCHER.beispiel.test.", NAME_IDN_A, "test.dienst-idn"),
        ):
            vorher = aufloeser_steuerbar.zaehler.get(normal, 0)
            rueckgabe = await lauf.anfragen(client, _url("http", rechner, g.anschluss))
            assert isinstance(rueckgabe, Antwort), rechner
            assert aufloeser_steuerbar.zaehler[normal] == vorher + 1, (
                "Auflösung der Normalform"
            )
            eintraege = await lauf.neu()
            _aufruf_pruefen(eintraege, rueckgabe, listenstand=stand)
            assert [e["ergebnis"] for e in eintraege] == ["zugelassen", "beantwortet"]
            z = _zielform("http", normal, g.anschluss)
            assert eintraege[0]["ziel_pseudonym"] == lauf.ps(z), rechner
            assert eintraege[0]["listeneintrag"] == kennung
            assert verbindungsweg_ersatz.aufrufe[-1].name_oder_adresse == normal
            assert str(g.anfragen[-1].host).rsplit(":", 1)[0] == normal
            verboten.append(z)
        # Gegenprobe: ein anderer Name ist ausserhalb der Liste, ohne Auflösung
        gesamt = sum(aufloeser_steuerbar.zaehler.values())
        rueckgabe = await lauf.anfragen(
            client, _url("http", "dienst2.beispiel.test", g.anschluss)
        )
        assert (
            isinstance(rueckgabe, Abweisung)
            and rueckgabe.ergebnis == "nicht_in_positivliste"
        )
        await lauf.neu()
        assert sum(aufloeser_steuerbar.zaehler.values()) == gesamt

        texte = _ausgaben(caplog, capfd, gewarnt)
    _abschluss(lauf, texte, verboten)
    await _ketten_unversehrt(lauf.verbindung, spurkontext.fall_kennung)


# =================================================================================================
# R3-F-028: IP-Literale
# =================================================================================================

_VOLLBREITE = "".join(chr(0xFF10 + int(z)) if z.isdigit() else z for z in "127.0.0.1")

# Pflicht-Schreibweisen von 127.0.0.1 (Messung des Dynamic Software Testers, Zeile Tests Einheit;
# Normalform 127.0.0.1 nach DT-S21-M-05 auch für abschliessenden Punkt und Unicode).
SCHREIBWEISEN_V4: tuple[str, ...] = (
    "127.0.0.1",
    "0177.0.0.1",
    "0177.0000.0000.0001",
    "0x7f.0.0.1",
    "0x7F.0x0.0x0.0x1",
    "0x7f.0.0.01",
    "0177.0x0.0.1",
    "127.1",
    "127.0.1",
    "0x7f.1",
    "0177.1",
    "2130706433",
    "0x7f000001",
    "017700000001",
    "127.000.000.001",
    "[::ffff:127.0.0.1]",
    "[::ffff:7f00:1]",
    "[0:0:0:0:0:ffff:7f00:1]",
    "[::FFFF:7F00:1]",
    "127.0.0.1.",
    "127。0.0.1",
    _VOLLBREITE,
)
SCHREIBWEISEN_V6: tuple[str, ...] = (
    "[::1]",
    "[0:0:0:0:0:0:0:1]",
    "[0000:0000:0000:0000:0000:0000:0000:0001]",
)


async def test_R3_F_028_ip_literal_wie_normalform_entschieden(
    spurkontext: Any,
    netzwaechter: Any,
    aufloeser_steuerbar: Any,
    verbindungsweg_ersatz: Any,
    fallschluessel_lesen: Any,
    tmp_path: Path,
    caplog: pytest.LogCaptureFixture,
    capfd: pytest.CaptureFixture[str],
) -> None:
    """Jede Schreibweise erhält die Entscheidung ihrer Normalform (W2-58 bis W2-60)."""
    lauf = await _lauf(spurkontext, fallschluessel_lesen)
    verboten: list[str] = [w for w in SCHREIBWEISEN_V4 if w not in ("127.0.0.1",)]
    async with _gegenstelle(_skript("treffer", 1)) as g, _beobachtet(caplog) as gewarnt:
        zielform = _zielform("http", "127.0.0.1", g.anschluss)
        verboten.append(zielform)

        # ---- Gegenprobe: Liste mit Literal-Eintrag 127.0.0.1 ----------------------------------
        mit, stand_mit = _liste(
            tmp_path,
            [_E("test.literal", "http", g.anschluss, adresse="127.0.0.1")],
            name="mit",
        )
        client = Client(positivliste=mit, aufloeser=aufloeser_steuerbar)
        pseudonyme: set[str] = set()
        for schreibweise in SCHREIBWEISEN_V4:
            vorher = _verbindungen(g)
            rueckgabe = await lauf.anfragen(
                client, _url("http", schreibweise, g.anschluss)
            )
            assert isinstance(rueckgabe, Antwort), schreibweise
            assert _verbindungen(g) == vorher + 1, schreibweise
            eintraege = await lauf.neu()
            _aufruf_pruefen(
                eintraege, rueckgabe, methoden={0: "GET"}, listenstand=stand_mit
            )
            assert [e["ergebnis"] for e in eintraege] == ["zugelassen", "beantwortet"]
            assert eintraege[0]["zielart"] == "ipv4"
            assert eintraege[0]["listeneintrag"] == "test.literal"
            assert eintraege[0]["adressbereich"] == "rueckschleife", (
                "Literal ohne Bereichsregel"
            )
            assert eintraege[0]["adresse_pseudonym"] == lauf.ps("127.0.0.1")
            pseudonyme.add(eintraege[0]["ziel_pseudonym"])
        assert pseudonyme == {lauf.ps(zielform)}, (
            "ziel_pseudonym für alle Schreibweisen gleich"
        )
        assert sum(aufloeser_steuerbar.zaehler.values()) == 0

        # ---- Abweisung: Liste ohne den Literal-Eintrag, ein Listenname löst auf 127.0.0.1 -----
        ohne, stand_ohne = _liste(
            tmp_path,
            [_E("test.name", "http", g.anschluss, rechnername=NAME)],
            name="ohne",
        )
        aufloeser_steuerbar.setzen(NAME, (ipaddress.ip_address("127.0.0.1"),))
        client = Client(positivliste=ohne, aufloeser=aufloeser_steuerbar)
        vorher = _verbindungen(g)
        for schreibweise in SCHREIBWEISEN_V4:
            rueckgabe = await lauf.anfragen(
                client, _url("http", schreibweise, g.anschluss)
            )
            assert isinstance(rueckgabe, Abweisung), schreibweise
            assert rueckgabe.ergebnis == "nicht_in_positivliste", schreibweise
            eintraege = await lauf.neu()
            _aufruf_pruefen(eintraege, rueckgabe, listenstand=stand_ohne)
            assert len(eintraege) == 1
            assert eintraege[0]["ziel_pseudonym"] == lauf.ps(zielform), schreibweise
        assert _verbindungen(g) == vorher, "keine Verbindung ohne eigenen Eintrag"
        assert sum(aufloeser_steuerbar.zaehler.values()) == 0, (
            "kein Umweg über den Namen"
        )

        # ---- IPv6-Schreibweisen von ::1 über verbindungsweg_ersatz (ohne IPv6-Socket) ---------
        v6, stand_v6 = _liste(
            tmp_path,
            [_E("test.literal-v6", "http", g.anschluss, adresse="::1")],
            name="v6",
        )
        client = Client(
            positivliste=v6,
            aufloeser=aufloeser_steuerbar,
            verbindungsweg=verbindungsweg_ersatz,
        )
        z6 = _zielform("http", "::1", g.anschluss)
        verboten.append(z6)
        for schreibweise in SCHREIBWEISEN_V6:
            vorher_ersatz = len(verbindungsweg_ersatz.aufrufe)
            rueckgabe = await lauf.anfragen(
                client, _url("http", schreibweise, g.anschluss)
            )
            assert isinstance(rueckgabe, Antwort), schreibweise
            assert len(verbindungsweg_ersatz.aufrufe) == vorher_ersatz + 1
            assert ipaddress.ip_address(
                str(verbindungsweg_ersatz.aufrufe[-1].adresse)
            ) == (ipaddress.ip_address("::1"))
            eintraege = await lauf.neu()
            _aufruf_pruefen(eintraege, rueckgabe, listenstand=stand_v6)
            assert [e["ergebnis"] for e in eintraege] == ["zugelassen", "beantwortet"]
            assert eintraege[0]["zielart"] == "ipv6"
            assert eintraege[0]["ziel_pseudonym"] == lauf.ps(z6)
        client = Client(
            positivliste=mit,
            aufloeser=aufloeser_steuerbar,
            verbindungsweg=verbindungsweg_ersatz,
        )
        for schreibweise in SCHREIBWEISEN_V6:
            vorher_ersatz = len(verbindungsweg_ersatz.aufrufe)
            rueckgabe = await lauf.anfragen(
                client, _url("http", schreibweise, g.anschluss)
            )
            assert isinstance(rueckgabe, Abweisung)
            assert rueckgabe.ergebnis == "nicht_in_positivliste"
            await lauf.neu()
            assert len(verbindungsweg_ersatz.aufrufe) == vorher_ersatz

        # ---- Zonenangabe gegen einen Literal-Eintrag fe80::1: url_nicht_auswertbar ------------
        zone, stand_zone = _liste(
            tmp_path,
            [_E("test.zone", "http", g.anschluss, adresse="fe80::1")],
            name="zone",
        )
        client = Client(
            positivliste=zone,
            aufloeser=aufloeser_steuerbar,
            verbindungsweg=verbindungsweg_ersatz,
        )
        for rechner in ("[fe80::1%25eth0]", "[fe80::1%eth0]"):
            vorher_ersatz = len(verbindungsweg_ersatz.aufrufe)
            rueckgabe = await lauf.anfragen(client, _url("http", rechner, g.anschluss))
            assert isinstance(rueckgabe, Abweisung)
            assert rueckgabe.ergebnis == "url_nicht_auswertbar", rechner
            eintraege = await lauf.neu()
            assert [e["ergebnis"] for e in eintraege] == ["url_nicht_auswertbar"]
            _aufruf_pruefen(eintraege, rueckgabe, listenstand=stand_zone)
            assert len(verbindungsweg_ersatz.aufrufe) == vorher_ersatz
        verboten += ["fe80::1%25eth0", "fe80::1%eth0"]

        texte = _ausgaben(caplog, capfd, gewarnt)
    _abschluss(lauf, texte, verboten)
    await _ketten_unversehrt(lauf.verbindung, spurkontext.fall_kennung)
