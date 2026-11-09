"""Abnahmetest R3-F-011 (ADR 0007, Festlegung S1.5 nach Nachbesserung 2 (S1.5.2); E-S15-01 bis -10).

R3-F-011 (Backlog, Abnahme `R3-F-011_keine_klardaten_im_protokoll`, Präzisierung vom 2026-11-09):
ein Suchlauf über die Protokolltabellen nach den Klartextwerten eines Testfalls liefert null
Treffer; die zugehörigen Prüfsummen (Pseudonyme nach E-S1-06) sind vorhanden.

Aufbau (ein Testname; die Zusicherungen Z01 bis Z14 werden einzeln erhoben und am Ende gemeinsam
geprüft, damit ein Lauf vor dem Bau jede Zusicherung einzeln grün oder rot ausweist):

- Testfall (E-S15-01 a, DS-S15-02): zwei Fälle A und B über fall.service.eroeffnen mit denselben
  Klartextwerten ausser dem Aktenzeichen; je zwei Knoten Person (name, firstName, lastName,
  address, phone, email, notes), ein Knoten Company, eine Kante Family mit relationship, je mit
  eigenem Herkunftssatz und eigener Abfrage über kanon.service.schreiben; in A ein abgewiesener
  Schreibversuch mit eigenen Klartextwerten (E-S15-07); A danach geschlossen.
- Z01 Vorbedingung Trennschärfe (DS-S15-04): jeder Suchbegriff hat die Mindestform und kommt im
  zulässigen Klartext des Testfalls nicht vor.
- Z02 Suchfläche (DS-S15-01, E-S15-02): jede Tabelle des Schemas r3cosint aus dem Katalog ausser
  der Positivliste; geschlossene Typliste; ermittlungsspur, arbeitsspur und kettenkopf darunter,
  mit gesuchten Spalten und Zeilen beider Fälle.
- Z03 Suchlauf (E-S15-03, DS-S15-03): null Treffer in Spalten, ganzer Zeile und gelesenem JSON.
- Z04 positive Formprüfung je Eintragstyp und Spalte (DS-S15-05).
- Z05 Pseudonyme auf dem zweiten Rechenweg im richtigen Feld des richtigen Eintrags, Schreibvarianten
  gleich (E-S15-04 a, DS-S15-06).
- Z06 Schlüssel je Fall: A und B verschieden, kein Pseudonym des einen Falls beim anderen.
- Z07 SHA-256 ohne Schlüssel nirgends.
- Z08 abfrage_bindung gleich dem HMAC der exakten Bytes.
- Z09 beide Rechenwege der Kettenprüfung unversehrt, Anzahl wie geschrieben, kein Eintrag des
  abgewiesenen Versuchs.
- Z10 Abweisung mit ganzer Ursachenkette ohne Suchbegriff (DS-S15-07, Teil Abnahme).
- Z11 repr und str jeder Eingabe des Testfalls ohne Suchbegriff (DS-S15-08).
- Z12 Prozessausgaben (DS-S15-09): stdout, stderr und Protokollmeldungen ab DEBUG ohne Treffer;
  Gegenprobe: mindestens eine Meldung von sqlalchemy.engine.
- Z13 Gegenprobe (a): dieselbe Suche über den Bestand findet jeden Wert, den des abgewiesenen
  Versuchs nicht.
- Z14 Gegenprobe (b): über manipulieren eingebrachter Klartext wird in ermittlungsspur und in
  arbeitsspur je mit Tabelle und Spalte gefunden, nur dort.

Meldungen nennen Tabelle, Spalte, Bezeichnung und Form, nie den Wert (DT-S14-03), nie den
Schlüssel. Alle Werte sind erfunden (5.15, DS-S14-05). Nicht hier geprüft, weil die Festlegung es
den Einheits- und Integrationstests zuweist: SD-S14-B-02 am Weg an kanon vorbei (DS-S15-07),
Ersatzzeichen in fall.eingabe (E-S15-06). Geschrieben vor dem Bau vom Dynamic Software Tester;
der Test wird nicht an die Umsetzung angepasst, Abweichungen gehen an den Koordinator.
"""

import hashlib
import hmac
import json
import logging
import re
import sys
import traceback
import unicodedata
from collections.abc import AsyncIterator, Awaitable, Callable, Iterable, Mapping
from contextlib import asynccontextmanager
from dataclasses import dataclass, field
from datetime import UTC, datetime
from typing import TYPE_CHECKING, Any
from uuid import UUID

import pytest
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncConnection

from r3cosint.core.datenbank import engine_erzeugen
from r3cosint.core.fehler import EingabeFehler
from r3cosint.fall.service import (
    Eroeffnung,
    Rechtsregime,
    eroeffnen,
    ketten_aller_faelle_pruefen,
    schliessen,
)
from r3cosint.kanon.eingabe import Datenpunkt, Datensatz, Herkunft
from r3cosint.kanon.service import VORRAT_KANTEN, VORRAT_KNOTEN, schreiben
from r3cosint.spur.payload import EIGENSCHAFTSNAME_MUSTER
from r3cosint.spur.service import (
    Beziehung,
    Eintragstyp,
    Entitaet,
    FallEroeffnet,
    Kennzeichnung,
    Spur,
    kette_pruefen_datenbank,
)

if TYPE_CHECKING:
    from conftest import Testdatenbank

# Tabellen- und Spaltennamen stammen aus dem Katalog der Wegwerfinstanz und aus Konstanten dieses
# Tests, Werte aus dem synthetischen Testfall; kein Text kommt von aussen (S608).
# ruff: noqa: S608

pytestmark = [pytest.mark.anyio, pytest.mark.abnahme]

SchluesselLesen = Callable[[UUID], Awaitable[bytes]]
Manipulieren = Callable[..., Awaitable[str]]

# ---------------------------------------------------------------------------------------------
# Synthetische Ausgangslage (5.15, DS-S14-05, DS-S15-02); Sonderzeichen als Escape geschrieben
# ---------------------------------------------------------------------------------------------

ANWENDUNG = "r3cosint_anwendung"
EIGENTUEMER = "r3cosint_eigentuemer"
PERSON = "akteur.handlung"
"""Handelnde Person (person_kennung); zulässiger Klartext (E-S1-07)."""
ERHEBENDE_PERSON = "akteur.erhebung"
WERKZEUG = "werkzeug.lauf-1"
FALLKATEGORIE = "vergehen"
EROEFFNET = datetime(2026, 2, 1, 8, 0, 0, 125000, tzinfo=UTC)
ERHOBEN = datetime(2026, 2, 1, 9, 15, 0, 250000, tzinfo=UTC)
GESCHRIEBEN = datetime(2026, 2, 2, 10, 0, 0, 500000, tzinfo=UTC)
GESCHLOSSEN = datetime(2026, 2, 3, 12, 0, 0, 750000, tzinfo=UTC)

AKTENZEICHEN = {
    "A": "TEST-SYNTH  Wirbelstrom Alpha",
    "B": "TEST-SYNTH  Wirbelstrom Bravo",
}
RECHTSGRUNDLAGE = " Erfundene  Normquelle Paragraphus Synthetikus"
ERMITTELNDE_PERSON = "synthfigur.quarzbach"

P1_ID = "synthkennung-quarzlinde-p1"
P2_ID = "synthkennung-wolkenhain-p2"
FIRMA_ID = "synthkennung-glitzerwerk-c1"
KANTE_ID = "synthkennung-familienband-k1"

DATENSAETZE: dict[str, dict[str, Any]] = {
    "p1": {
        "id": P1_ID,
        "schema": "Person",
        "properties": {
            # Randständiger und doppelter innerer Leerraum, Grossschreibung.
            "name": ["  Quarzlinde   ZORBATINSKA "],
            "firstName": ["Quarzlinde"],
            "lastName": ["ZORBATINSKA"],
            # Eszett und Umlaut in NFC.
            "address": ["Fabelstra\u00dfe 17, 3999 Zwirbelbr\u00fcck"],
            "phone": ["+41 99 999 01 23"],
            "email": ["quarzlinde.zorbatinska@synthpost.invalid"],
            # Anführungszeichen, umgekehrter Schrägstrich, Zeilenumbruch.
            "notes": [
                'Erfundene Notiz mit "Zitatzeichen" und C:\\Synthordner\\Ablage\n'
                "zweite Zeile Gr\u00fcnspecht"
            ],
        },
    },
    "p2": {
        "id": P2_ID,
        "schema": "Person",
        "properties": {
            # Umlaut in NFD (u + U+0308).
            "name": ["Wolkenhain Ku\u0308mmerling"],
            "firstName": ["Wolkenhain"],
            "lastName": ["Ku\u0308mmerling"],
            "address": ["Nebelgasse 5, 3998 Quellmoos"],
            "phone": ["099 888 45 67"],
            "email": ["wolkenhain.kuemmerling@synthpost.invalid"],
            "notes": ["Zweite erfundene Notiz Schattenfink"],
        },
    },
    "firma": {
        "id": FIRMA_ID,
        "schema": "Company",
        "properties": {
            "name": ["Glitzerwerk Synthetik AG"],
            "address": ["Funkelstrasse 9, 3997 Flimmerdorf"],
        },
    },
    "kante": {
        "id": KANTE_ID,
        "schema": "Family",
        "properties": {
            "person": [P1_ID],
            "relative": [P2_ID],
            "relationship": ["Wahlverwandtschaft Gro\u00dftante"],
        },
    },
}
ABFRAGEN: dict[str, str] = {
    "p1": 'Melderegister Name:"Quarzlinde ZORBATINSKA" Rufnummer +41 99 999 01 23',
    "p2": 'Melderegister  NAME:"Wolkenhain Ku\u0308mmerling" Rufnummer 099 888 45 67 C:\\Melde',
    "firma": 'Handelsregister Firma "Glitzerwerk Synthetik AG"',
    "kante": "Zivilstandsregister Wolkenhain Quarzlinde",
}
REIHENFOLGE = ("p1", "p2", "firma", "kante")

# Abgewiesener Versuch (E-S15-07): Kante mit einem Ende, das im Fall nicht besteht; eigene Werte.
VERSUCH_DATENSATZ: dict[str, Any] = {
    "id": "zyprianwald-k5",
    "schema": "Family",
    "properties": {
        "person": [P1_ID],
        "relative": ["zyprianwald-niemand-k6"],
        "relationship": ["Mondsteinvetter"],
    },
}
VERSUCH_ABFRAGE = "Tiefseekabel Zyprianwald Mondsteinvetter"

POSITIVLISTE = frozenset(
    {
        "fall",
        "fall_schluessel",
        "fallkategorie",
        "herkunft",
        "entitaet",
        "beziehung",
        "alembic_version",
    }
)
"""Klartexttabellen, nicht durchsucht (DS-S15-01); jede Erweiterung ist eine Fortschreibung."""
TYPLISTE = frozenset(
    {
        "uuid",
        "int4",
        "int8",
        "timestamptz",
        "text",
        "bpchar",
        "varchar",
        "json",
        "jsonb",
    }
)
"""Geschlossene Typliste (E-S15-02 a): uuid, integer, bigint, timestamp with time zone, text,
character, character varying, json, jsonb; jeder andere Typ macht den Test rot."""
MINDESTTABELLEN = ("ermittlungsspur", "arbeitsspur", "kettenkopf")
BESTAND = ("fall", "entitaet", "beziehung", "herkunft")

_PSEUDONYM_ETIKETT = b"r3cosint-pseudonym-1\n"
_BINDUNG_ETIKETT = b"r3cosint-bindung-1\n"
_HEX64 = re.compile(r"^[0-9a-f]{64}$")
_UUID = re.compile(r"^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$")
_ZEIT = re.compile(
    r"^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}\.[0-9]{6}Z$"
)
_KENNUNGSFORM = re.compile(r"^[a-z0-9._-]{1,64}$")
_EIGENSCHAFTSNAME = re.compile(EIGENSCHAFTSNAME_MUSTER)
_TEIL = re.compile(r"[^\W_]+")
_ZIFFERN = re.compile(r"^[0-9]+$")

_SCHLUESSEL_JE_TYP: dict[str, frozenset[str]] = {
    "fall_eroeffnet": frozenset(
        {
            "fall_kennung",
            "rechtsregime",
            "fallkategorie",
            "aktenzeichen_pseudonym",
            "rechtsgrundlage_pseudonym",
            "ermittelnde_person_pseudonym",
            "eroeffnet_am",
        }
    ),
    "fall_geschlossen": frozenset(
        {"fall_kennung", "geschlossen_am", "prueffrist_bis", "erste_pruefung_monate"}
    ),
    "entitaet": frozenset(
        {
            "fall_kennung",
            "entitaet_kennung",
            "ftm_kennung_pseudonym",
            "ftm_schema",
            "herkunft_kennung",
            "eigenschaften",
            "werkzeug",
            "erhoben_am",
            "erhebende_person",
            "abfrage_pseudonym",
            "abfrage_bindung",
        }
    ),
    "beziehung": frozenset(
        {
            "fall_kennung",
            "beziehung_kennung",
            "quelle_kennung",
            "ziel_kennung",
            "ftm_kennung_pseudonym",
            "ftm_schema",
            "herkunft_kennung",
            "eigenschaften",
            "werkzeug",
            "erhoben_am",
            "erhebende_person",
            "abfrage_pseudonym",
            "abfrage_bindung",
        }
    ),
}
_SPALTEN_SPUR = frozenset(
    {
        "person_kennung",
        "eintragstyp",
        "kennzeichnung",
        "payload",
        "vorgaenger_pruefsumme",
        "pruefsumme",
    }
)
_SPALTEN_KOPF = frozenset({"spur", "pruefsumme"})


@dataclass
class _Uhr:
    """Uhr mit einstellbarem Zeitpunkt (wie VerstellbareUhr in conftest)."""

    zeitpunkt: datetime

    def jetzt(self) -> datetime:
        """Liefert den eingestellten Zeitpunkt."""
        return self.zeitpunkt


# ---------------------------------------------------------------------------------------------
# Zweiter Rechenweg (E-S15-04 a): Normalform nach E-S1-06 und HMAC, im Test ausgeschrieben
# ---------------------------------------------------------------------------------------------


def _normalform(wert: str) -> str:
    """NFC, casefold, NFC, Leerraum nach str.split zusammengefasst, getrimmt."""
    nfc = unicodedata.normalize("NFC", unicodedata.normalize("NFC", wert).casefold())
    return " ".join(nfc.split())


def _pseudonym(schluessel: bytes, wert: str) -> str:
    nachricht = _PSEUDONYM_ETIKETT + _normalform(wert).encode("utf-8")
    return hmac.new(schluessel, nachricht, hashlib.sha256).hexdigest()


def _bindung(schluessel: bytes, wert: str) -> str:
    nachricht = _BINDUNG_ETIKETT + wert.encode("utf-8")
    return hmac.new(schluessel, nachricht, hashlib.sha256).hexdigest()


def _kanon_angleichen(wert: str) -> str:
    """Angleichung des Bestands (kanon.eingabe): NFC, an den Enden getrimmt."""
    return unicodedata.normalize("NFC", wert).strip()


def _fall_angleichen(wert: str) -> str:
    """Angleichung des Falls (fall.eingabe): NFC, Leerraum zusammengefasst, getrimmt."""
    return " ".join(unicodedata.normalize("NFC", wert).split())


def _zeit_text(zeitpunkt: datetime) -> str:
    u = zeitpunkt.astimezone(UTC)
    return (
        f"{u.year:04d}-{u.month:02d}-{u.day:02d}T{u.hour:02d}:{u.minute:02d}:"
        f"{u.second:02d}.{u.microsecond:06d}Z"
    )


# ---------------------------------------------------------------------------------------------
# Klartextwerte und Suchbegriffe (Nr. 26 fortgeschrieben, E-S15-03, DS-S15-03, DS-S15-04)
# ---------------------------------------------------------------------------------------------


@dataclass(frozen=True)
class _Klartext:
    """Ein Klartextwert mit Bezeichnung; zusatz sind Teilwerte, die nicht aus Wortteilen folgen."""

    bezeichnung: str
    roh: str = field(repr=False)
    angeglichen: str = field(repr=False)
    zusatz: tuple[str, ...] = field(default=(), repr=False)


def _trennscharf(begriff: str) -> bool:
    """DS-S15-04: Ziffernfolge ab neun Ziffern, sonst ab fünf Zeichen mit einem Nicht-Hex-Zeichen."""
    b = begriff.casefold()
    if _ZIFFERN.match(b):
        return len(b) >= 9
    return len(b) >= 5 and any(z not in "0123456789abcdef-" for z in b)


def _rufnummer_formen(roh: str) -> tuple[str, ...]:
    """Rufnummer als ganze Ziffernfolge mit und ohne Landesvorwahl, mit und ohne führende Null."""
    ziffern = "".join(z for z in roh if z.isdigit())
    if roh.strip().startswith("+41"):
        national = ziffern[2:]
    elif ziffern.startswith("0041"):
        national = ziffern[4:]
    else:
        national = ziffern.removeprefix("0")
    return (national, "0" + national, "41" + national, "0041" + national, ziffern)


def _email_formen(roh: str) -> tuple[str, ...]:
    lokal, _, domaene = roh.partition("@")
    return (lokal, domaene)


def _suchbegriffe(wert: _Klartext) -> dict[str, str]:
    """Suchbegriff (casefold) nach Form; Formen nach DS-S15-03, Teilwerte nach DS-S15-04."""
    basis: dict[str, str] = {
        "roh": wert.roh,
        "angeglichen": wert.angeglichen,
        "normalisiert": _normalform(wert.roh),
    }
    teile = sorted(set(_TEIL.findall(unicodedata.normalize("NFC", wert.roh))))
    for nr, teil in enumerate(t for t in teile if _trennscharf(t)):
        basis[f"teilwert {nr}"] = teil
    for nr, zusatz in enumerate(wert.zusatz):
        if _trennscharf(zusatz):
            basis[f"zusatz {nr}"] = zusatz
    begriffe: dict[str, str] = {}
    for name, s in basis.items():
        for un, t in (
            ("", s),
            ("/nfc", unicodedata.normalize("NFC", s)),
            ("/nfd", unicodedata.normalize("NFD", s)),
        ):
            for js, u in (
                ("", t),
                ("/json", json.dumps(t, ensure_ascii=False)[1:-1]),
                ("/json-ascii", json.dumps(t, ensure_ascii=True)[1:-1]),
            ):
                begriffe.setdefault(u.casefold(), f"{name}{un}{js}")
    return begriffe


def _klartextwerte() -> tuple[list[_Klartext], list[_Klartext]]:
    """Klartextwerte des Testfalls und, getrennt, die des abgewiesenen Versuchs."""
    werte: list[_Klartext] = [
        _Klartext(f"aktenzeichen {f}", az, _fall_angleichen(az))
        for f, az in AKTENZEICHEN.items()
    ]
    werte.append(
        _Klartext("rechtsgrundlage", RECHTSGRUNDLAGE, _fall_angleichen(RECHTSGRUNDLAGE))
    )
    werte.append(
        _Klartext("ermittelnde_person", ERMITTELNDE_PERSON, ERMITTELNDE_PERSON)
    )
    for name in REIHENFOLGE:
        satz = DATENSAETZE[name]
        werte.append(_Klartext(f"{name} ftm_kennung", satz["id"], satz["id"]))
        for eigenschaft, liste in satz["properties"].items():
            if eigenschaft in ("person", "relative"):
                continue  # Enden: dieselben Werte wie die FollowTheMoney-Kennungen der Knoten
            for nr, roh in enumerate(liste):
                zusatz: tuple[str, ...] = ()
                if eigenschaft == "phone":
                    zusatz = _rufnummer_formen(roh)
                elif eigenschaft == "email":
                    zusatz = _email_formen(roh)
                werte.append(
                    _Klartext(
                        f"{name} {eigenschaft} {nr}",
                        roh,
                        _kanon_angleichen(roh),
                        zusatz,
                    )
                )
        werte.append(_Klartext(f"{name} abfrage", ABFRAGEN[name], ABFRAGEN[name]))
    versuch = [
        _Klartext(
            "versuch ftm_kennung", VERSUCH_DATENSATZ["id"], VERSUCH_DATENSATZ["id"]
        ),
        _Klartext(
            "versuch relative",
            VERSUCH_DATENSATZ["properties"]["relative"][0],
            VERSUCH_DATENSATZ["properties"]["relative"][0],
        ),
        _Klartext(
            "versuch relationship",
            VERSUCH_DATENSATZ["properties"]["relationship"][0],
            VERSUCH_DATENSATZ["properties"]["relationship"][0],
        ),
        _Klartext("versuch abfrage", VERSUCH_ABFRAGE, VERSUCH_ABFRAGE),
    ]
    return werte, versuch


# ---------------------------------------------------------------------------------------------
# Suchfläche und Suche
# ---------------------------------------------------------------------------------------------


@dataclass(frozen=True)
class _Text:
    """Ein durchsuchter Text: Tabelle, Spalte (oder Zeile), Fall der Zeile, Inhalt casefold."""

    tabelle: str
    spalte: str
    fall: str | None
    inhalt: str = field(repr=False)


@dataclass(frozen=True)
class _Spalte:
    tabelle: str
    name: str
    typ: str
    kategorie: str


_KATALOG_SQL = (
    "SELECT c.relname::text, a.attname::text, t.typname::text, t.typcategory::text "
    "FROM pg_catalog.pg_attribute a "
    "JOIN pg_catalog.pg_class c ON c.oid = a.attrelid "
    "JOIN pg_catalog.pg_namespace n ON n.oid = c.relnamespace "
    "JOIN pg_catalog.pg_type t ON t.oid = a.atttypid "
    "WHERE n.nspname = 'r3cosint' AND c.relkind IN ('r', 'p', 'm', 'f') "
    "AND a.attnum > 0 AND NOT a.attisdropped ORDER BY c.relname, a.attnum"
)


def _gesucht(spalte: _Spalte) -> bool:
    """Typkategorie S sowie json und jsonb (FA-S15-03)."""
    return spalte.kategorie == "S" or spalte.typ in ("json", "jsonb")


def _bezeichner(name: str) -> str:
    return '"' + name.replace('"', '""') + '"'


def _json_teile(wert: Any) -> Iterable[str]:
    """Alle Zeichenketten und Schlüssel eines gelesenen JSON-Werts."""
    if isinstance(wert, str):
        yield wert
    elif isinstance(wert, list):
        for element in wert:
            yield from _json_teile(element)
    elif isinstance(wert, dict):
        for schluessel, element in wert.items():
            yield str(schluessel)
            yield from _json_teile(element)


async def _katalog(verbindung: AsyncConnection) -> list[_Spalte]:
    async with verbindung.begin():
        zeilen = await verbindung.execute(text(_KATALOG_SQL))
        return [_Spalte(str(a), str(b), str(c), str(d)) for a, b, c, d in zeilen]


async def _texte_lesen(
    verbindung: AsyncConnection, spalten: list[_Spalte], tabellen: Iterable[str]
) -> tuple[list[_Text], str]:
    """Liest die Texte der Tabellen in einer Transaktion unter REPEATABLE READ.

    Je Zeile die ganze Zeile als Text (t::text), je gesuchte Spalte ihr Text und, falls er sich
    als JSON lesen lässt, jede Zeichenkette und jeder Schlüssel darin. Rückgabe auch die Stufe.
    """
    texte: list[_Text] = []
    verbindung = await verbindung.execution_options(isolation_level="REPEATABLE READ")
    async with verbindung.begin():
        stufe = str(
            (
                await verbindung.execute(
                    text("SELECT current_setting('transaction_isolation')")
                )
            ).scalar_one()
        )
        for tabelle in tabellen:
            gesucht = [s for s in spalten if s.tabelle == tabelle and _gesucht(s)]
            ausdruecke = ", ".join(f"t.{_bezeichner(s.name)}::text" for s in gesucht)
            sql = (
                f"SELECT t::text, to_jsonb(t)->>'fall_kennung'"
                f"{', ' + ausdruecke if ausdruecke else ''} "
                f"FROM r3cosint.{_bezeichner(tabelle)} t"
            )
            for zeile in await verbindung.execute(text(sql)):
                fall = None if zeile[1] is None else str(zeile[1])
                texte.append(_Text(tabelle, "<zeile>", fall, str(zeile[0]).casefold()))
                for spalte, wert in zip(gesucht, zeile[2:], strict=True):
                    if wert is None:
                        continue
                    texte.append(
                        _Text(tabelle, spalte.name, fall, str(wert).casefold())
                    )
                    try:
                        gelesen = json.loads(str(wert))
                    except ValueError:
                        if spalte.typ in ("json", "jsonb") or spalte.name == "payload":
                            raise AssertionError(
                                f"{tabelle}.{spalte.name} nicht als JSON lesbar"
                            ) from None
                        continue
                    for teil in _json_teile(gelesen):
                        texte.append(
                            _Text(
                                tabelle, f"{spalte.name}[json]", fall, teil.casefold()
                            )
                        )
    return texte, stufe


def _suchen(
    texte: Iterable[_Text], begriffe: Mapping[str, Mapping[str, str]]
) -> list[tuple[str, str, str, str]]:
    """Treffer als (Tabelle, Spalte, Bezeichnung, Form); nie der Wert."""
    treffer: list[tuple[str, str, str, str]] = []
    for t in texte:
        for bezeichnung, formen in begriffe.items():
            for begriff, form in formen.items():
                if begriff in t.inhalt:
                    treffer.append((t.tabelle, t.spalte, bezeichnung, form))
    return treffer


def _meldung_treffer(
    treffer: list[tuple[str, str, str, str]], hoechstens: int = 12
) -> str:
    teile = [f"{t}.{s}: {b} ({f})" for t, s, b, f in treffer[:hoechstens]]
    return f"{len(treffer)} Treffer: " + "; ".join(teile)


# ---------------------------------------------------------------------------------------------
# Protokoll der Zusicherungen
# ---------------------------------------------------------------------------------------------


@dataclass
class _Zusicherungen:
    """Erhebt jede Zusicherung einzeln; am Ende gilt: keine verletzt."""

    stand: dict[str, list[str]] = field(default_factory=dict)

    def pruefen(self, kennung: str, bedingung: bool, meldung: str) -> None:
        liste = self.stand.setdefault(kennung, [])
        if not bedingung:
            liste.append(meldung)

    def verletzt(self) -> list[str]:
        return [f"{k}: {m}" for k, liste in sorted(self.stand.items()) for m in liste]


def _fehlerkette_texte(fehler: BaseException) -> list[str]:
    """str, repr und args jedes Glieds der Ursachenkette und das ganze traceback."""
    texte = ["".join(traceback.format_exception(fehler))]
    offen: list[BaseException] = [fehler]
    gesehen: set[int] = set()
    while offen:
        glied = offen.pop()
        if id(glied) in gesehen:
            continue
        gesehen.add(id(glied))
        texte.extend((str(glied), repr(glied), repr(glied.args)))
        for naechstes in (glied.__cause__, glied.__context__):
            if naechstes is not None:
                offen.append(naechstes)
    return texte


def _in_texten(
    texte: Iterable[str], begriffe: Mapping[str, Mapping[str, str]]
) -> list[str]:
    """Bezeichnung und Form jedes Suchbegriffs, der in einem der Texte steht."""
    gefunden: list[str] = []
    gefaltet = [t.casefold() for t in texte]
    for bezeichnung, formen in begriffe.items():
        for begriff, form in formen.items():
            if any(begriff in t for t in gefaltet):
                gefunden.append(f"{bezeichnung} ({form})")
    return gefunden


def _blatt_form(
    schluessel: str, wert: Any, faelle: set[str], kategorien: set[str]
) -> bool:
    """Genau eine zulässige Form je Blatt der Nutzlast (DS-S15-05).

    faelle: Kennungen, die fall_kennung tragen darf (der Fall der Zeile).
    """
    if schluessel == "fall_kennung":
        return isinstance(wert, str) and wert in faelle
    if schluessel.endswith(("_pseudonym", "_bindung")):
        return isinstance(wert, str) and _HEX64.match(wert) is not None
    if schluessel in ("werkzeug", "erhebende_person"):
        return isinstance(wert, str) and _KENNUNGSFORM.match(wert) is not None
    if schluessel.endswith("_kennung"):
        return isinstance(wert, str) and _UUID.match(wert) is not None
    if schluessel.endswith("_am") or schluessel == "prueffrist_bis":
        return isinstance(wert, str) and _ZEIT.match(wert) is not None
    if schluessel == "rechtsregime":
        return wert in {r.value for r in Rechtsregime}
    if schluessel == "fallkategorie":
        return wert in kategorien
    if schluessel == "ftm_schema":
        return wert in VORRAT_KNOTEN | VORRAT_KANTEN
    if schluessel == "erste_pruefung_monate":
        return isinstance(wert, int) and not isinstance(wert, bool)
    if schluessel == "eigenschaften":
        return isinstance(wert, dict) and all(
            isinstance(n, str)
            and _EIGENSCHAFTSNAME.match(n) is not None
            and isinstance(liste, list)
            and len(liste) > 0
            and all(isinstance(p, str) and _HEX64.match(p) is not None for p in liste)
            for n, liste in wert.items()
        )
    return False


@asynccontextmanager
async def _verbindung(
    datenbank: "Testdatenbank", benutzer: str
) -> AsyncIterator[AsyncConnection]:
    """Eigene Verbindung, geöffnet erst nach dem Setzen der Protokollstufe (DS-S15-09)."""
    engine = engine_erzeugen(datenbank.verbindung(benutzer))
    try:
        async with engine.connect() as verbindung:
            yield verbindung
    finally:
        await engine.dispose()


def _soll_nutzlast(
    schluessel: bytes, fall: UUID, name: str, punkt: Datenpunkt
) -> dict[str, Any]:
    """Erwartete Nutzlast des Eintrags entitaet oder beziehung, auf dem zweiten Rechenweg."""
    satz = DATENSAETZE[name]
    eigenschaften = {
        e: sorted(
            _pseudonym(schluessel, w)
            for w in dict.fromkeys(_kanon_angleichen(v) for v in werte)
        )
        for e, werte in satz["properties"].items()
    }
    soll: dict[str, Any] = {
        "fall_kennung": str(fall),
        "ftm_kennung_pseudonym": _pseudonym(schluessel, satz["id"]),
        "ftm_schema": satz["schema"],
        "herkunft_kennung": str(punkt.herkunft_kennung),
        "eigenschaften": eigenschaften,
        "werkzeug": WERKZEUG,
        "erhoben_am": _zeit_text(ERHOBEN),
        "erhebende_person": ERHEBENDE_PERSON,
        "abfrage_pseudonym": _pseudonym(schluessel, ABFRAGEN[name]),
        "abfrage_bindung": _bindung(schluessel, ABFRAGEN[name]),
    }
    if punkt.quelle_kennung is None:
        soll["entitaet_kennung"] = str(punkt.kennung)
    else:
        soll["beziehung_kennung"] = str(punkt.kennung)
        soll["quelle_kennung"] = str(punkt.quelle_kennung)
        soll["ziel_kennung"] = str(punkt.ziel_kennung)
    return soll


def _herkunft(name: str) -> dict[str, object]:
    return {
        "werkzeug": WERKZEUG,
        "abfrage": ABFRAGEN[name],
        "zeitpunkt": ERHOBEN,
        "erhebende_person": ERHEBENDE_PERSON,
        "kennzeichnung": Kennzeichnung.QUELLENAUSSAGE,
    }


def _eroeffnung(fall: str) -> Eroeffnung:
    return Eroeffnung(
        aktenzeichen=AKTENZEICHEN[fall],
        rechtsgrundlage=RECHTSGRUNDLAGE,
        rechtsregime=Rechtsregime.R1,
        fallkategorie=FALLKATEGORIE,
        ermittelnde_person=ERMITTELNDE_PERSON,
    )


def _protokollstufe_debug(caplog: pytest.LogCaptureFixture) -> None:
    """DEBUG am Wurzel-Logger und an jedem Logger mit eigener höherer Stufe (etwa sqlalchemy)."""
    caplog.set_level(logging.DEBUG)
    for name, logger in list(logging.Logger.manager.loggerDict.items()):
        if isinstance(logger, logging.Logger) and logger.level > logging.DEBUG:
            caplog.set_level(logging.DEBUG, logger=name)
    caplog.set_level(logging.DEBUG, logger="sqlalchemy")


def _protokollstufe_warnung(caplog: pytest.LogCaptureFixture) -> None:
    caplog.set_level(logging.WARNING)
    caplog.set_level(logging.WARNING, logger="sqlalchemy")


# ---------------------------------------------------------------------------------------------
# R3-F-011_keine_klardaten_im_protokoll
# ---------------------------------------------------------------------------------------------


async def test_R3_F_011_keine_klardaten_im_protokoll(
    datenbank: "Testdatenbank",
    fallschluessel_lesen: SchluesselLesen,
    manipulieren: Manipulieren,
    capfd: pytest.CaptureFixture[str],
    caplog: pytest.LogCaptureFixture,
) -> None:
    """R3-F-011_keine_klardaten_im_protokoll: Suchlauf über die Protokolltabellen nach den
    Klartextwerten eines Testfalls liefert null Treffer; die zugehörigen Prüfsummen (Pseudonyme)
    sind vorhanden und auf einem zweiten Rechenweg nachgerechnet; Gegenproben (a) und (b).
    """
    z = _Zusicherungen()
    werte, versuch = _klartextwerte()
    begriffe = {w.bezeichnung: _suchbegriffe(w) for w in werte}
    begriffe_versuch = {w.bezeichnung: _suchbegriffe(w) for w in versuch}
    alle_begriffe = {**begriffe, **begriffe_versuch}

    # ---- Testfall (E-S15-01 a), Protokollstufe DEBUG vor dem Öffnen der Verbindungen ----------
    _protokollstufe_debug(caplog)
    uhr = _Uhr(EROEFFNET)
    faelle: dict[str, UUID] = {}
    punkte: dict[str, dict[str, Datenpunkt]] = {"A": {}, "B": {}}
    eingaben_repr: list[object] = []
    abweisung: BaseException | None = None
    async with _verbindung(datenbank, ANWENDUNG) as v:
        for f in ("A", "B"):
            eroeffnung = _eroeffnung(f)
            eingaben_repr.append(eroeffnung)
            uhr.zeitpunkt = EROEFFNET
            async with v.begin():
                fall = await eroeffnen(
                    v, eroeffnung=eroeffnung, person_kennung=PERSON, uhr=uhr
                )
            eingaben_repr.append(fall)
            faelle[f] = fall.kennung
            uhr.zeitpunkt = GESCHRIEBEN
            for name in REIHENFOLGE:
                async with v.begin():
                    punkt = await schreiben(
                        v,
                        fall_kennung=fall.kennung,
                        datensatz=DATENSAETZE[name],
                        herkunft=_herkunft(name),
                        person_kennung=PERSON,
                        uhr=uhr,
                    )
                punkte[f][name] = punkt
                eingaben_repr.append(punkt)
        # Abgewiesener Versuch in A (E-S15-07): ein Ende der Kante besteht im Fall nicht.
        anfrage_herkunft = {**_herkunft("kante"), "abfrage": VERSUCH_ABFRAGE}
        async with v.begin():
            try:
                await schreiben(
                    v,
                    fall_kennung=faelle["A"],
                    datensatz=VERSUCH_DATENSATZ,
                    herkunft=anfrage_herkunft,
                    person_kennung=PERSON,
                    uhr=uhr,
                )
            except EingabeFehler as fehler:
                abweisung = fehler
        uhr.zeitpunkt = GESCHLOSSEN
        async with v.begin():
            geschlossen = await schliessen(
                v, fall_kennung=faelle["A"], person_kennung=PERSON, uhr=uhr
            )
        eingaben_repr.append(geschlossen)
    ausgaben_testfall = capfd.readouterr()
    meldungen_testfall = list(caplog.records)
    text_testfall = caplog.text
    _protokollstufe_warnung(caplog)

    # ---- Z10 Abweisung mit Ursachenkette ohne Suchbegriff (DS-S15-07, E-S15-07) ---------------
    z.pruefen(
        "Z10",
        abweisung is not None,
        "der Versuch wurde nicht mit EingabeFehler abgewiesen",
    )
    if abweisung is not None:
        gefunden = _in_texten(_fehlerkette_texte(abweisung), alle_begriffe)
        z.pruefen(
            "Z10", not gefunden, f"Suchbegriff in der Ursachenkette: {gefunden[:8]}"
        )

    # ---- Z11 repr und str der Eingaben ohne Suchbegriff (DS-S15-08) ----------------------------
    # Eingaben des abgewiesenen Versuchs (ST-S15-06).
    eingaben_repr.extend(
        (
            Datensatz.model_validate(VERSUCH_DATENSATZ),
            Herkunft.model_validate(anfrage_herkunft),
        )
    )
    for name in (*REIHENFOLGE,):
        satz = Datensatz.model_validate(DATENSAETZE[name])
        eingaben_repr.extend((satz, Herkunft.model_validate(_herkunft(name))))
        punkt_a = punkte["A"][name]
        gemeinsam: dict[str, Any] = {
            "fall_kennung": faelle["A"],
            "ftm_kennung": satz.ftm_kennung,
            "ftm_schema": satz.ftm_schema,
            "herkunft_kennung": punkt_a.herkunft_kennung,
            "eigenschaften": dict(satz.eigenschaften),
            "werkzeug": WERKZEUG,
            "erhoben_am": ERHOBEN,
            "erhebende_person": ERHEBENDE_PERSON,
            "abfrage": ABFRAGEN[name],
        }
        if punkt_a.quelle_kennung is None or punkt_a.ziel_kennung is None:
            eingaben_repr.append(
                Entitaet(entitaet_kennung=punkt_a.kennung, **gemeinsam)
            )
        else:
            eingaben_repr.append(
                Beziehung(
                    beziehung_kennung=punkt_a.kennung,
                    quelle_kennung=punkt_a.quelle_kennung,
                    ziel_kennung=punkt_a.ziel_kennung,
                    **gemeinsam,
                )
            )
    for f in ("A", "B"):
        eroeffnung = _eroeffnung(f)
        eingaben_repr.append(
            FallEroeffnet(
                fall_kennung=faelle[f],
                rechtsregime="R1",
                fallkategorie=FALLKATEGORIE,
                aktenzeichen=eroeffnung.aktenzeichen,
                rechtsgrundlage=eroeffnung.rechtsgrundlage,
                ermittelnde_person=eroeffnung.ermittelnde_person,
                eroeffnet_am=EROEFFNET,
            )
        )
    for objekt in eingaben_repr:
        gefunden = _in_texten((repr(objekt), str(objekt)), alle_begriffe)
        z.pruefen(
            "Z11",
            not gefunden,
            f"repr oder str von {type(objekt).__name__} nennt {gefunden[:6]}",
        )

    # ---- Z12 Prozessausgaben (DS-S15-09) -------------------------------------------------------
    prozess = [
        ausgaben_testfall.out,
        ausgaben_testfall.err,
        text_testfall,
        *(m.getMessage() for m in meldungen_testfall),
    ]
    gefunden = _in_texten(prozess, alle_begriffe)
    z.pruefen(
        "Z12",
        not gefunden,
        f"Suchbegriff in stdout, stderr oder Protokoll: {gefunden[:8]}",
    )
    engine_meldungen = [
        m for m in meldungen_testfall if m.name.startswith("sqlalchemy.engine")
    ]
    z.pruefen(
        "Z12",
        len(engine_meldungen) > 0,
        "Gegenprobe: keine Meldung von sqlalchemy.engine aufgefangen",
    )

    # ---- Schlüssel und Vorräte (Zugang der Tests) ----------------------------------------------
    schluessel = {f: await fallschluessel_lesen(faelle[f]) for f in ("A", "B")}
    async with _verbindung(datenbank, ANWENDUNG) as v:
        async with v.begin():
            kategorien = {
                str(k)
                for k in (
                    await v.execute(text("SELECT kennung FROM r3cosint.fallkategorie"))
                ).scalars()
            }

    # ---- Z01 Vorbedingung Trennschärfe (DS-S15-04) ---------------------------------------------
    zulaessig: list[str] = [
        PERSON,
        ERHEBENDE_PERSON,
        WERKZEUG,
        *(r.value for r in Rechtsregime),
        *kategorien,
        *(s.value for s in Spur),
        *(e.value for e in Eintragstyp),
        *(k.value for k in Kennzeichnung),
        *VORRAT_KNOTEN,
        *VORRAT_KANTEN,
        *(n for satz in DATENSAETZE.values() for n in satz["properties"]),
        *(n for schl in _SCHLUESSEL_JE_TYP.values() for n in schl),
        *_SPALTEN_SPUR,
        *_SPALTEN_KOPF,
        *(_zeit_text(t) for t in (EROEFFNET, ERHOBEN, GESCHRIEBEN, GESCHLOSSEN)),
    ]
    if geschlossen.prueffrist_bis is not None:
        zulaessig.append(_zeit_text(geschlossen.prueffrist_bis))
    zulaessig_gefaltet = [t.casefold() for t in zulaessig]
    nicht_trennscharf = [
        f"{b} ({form})"
        for b, formen in alle_begriffe.items()
        for begriff, form in formen.items()
        if not _trennscharf(begriff) or any(begriff in t for t in zulaessig_gefaltet)
    ]
    assert not nicht_trennscharf, f"Z01 Trennschärfe verletzt: {nicht_trennscharf[:8]}"
    z.pruefen("Z01", True, "")

    # ---- Z02 Suchfläche (DS-S15-01, E-S15-02) --------------------------------------------------
    async with _verbindung(datenbank, ANWENDUNG) as v:
        katalog = await _katalog(v)
        tabellen = sorted({s.tabelle for s in katalog} - POSITIVLISTE)
        texte, stufe = await _texte_lesen(v, katalog, tabellen)
        anzahl_je_fall: dict[tuple[str, str], int] = {}
        async with v.begin():
            for tabelle in MINDESTTABELLEN:
                for f in ("A", "B"):
                    anzahl_je_fall[(tabelle, f)] = int(
                        (
                            await v.execute(
                                text(
                                    f"SELECT count(*) FROM r3cosint.{_bezeichner(tabelle)} "
                                    "WHERE fall_kennung = :f"
                                ),
                                {"f": faelle[f]},
                            )
                        ).scalar_one()
                    )
    z.pruefen("Z02", stufe == "repeatable read", "Suche nicht unter REPEATABLE READ")
    spalten_je_tabelle = {
        t: [s.name for s in katalog if s.tabelle == t and _gesucht(s)] for t in tabellen
    }
    for tabelle in MINDESTTABELLEN:
        z.pruefen(
            "Z02",
            tabelle in tabellen,
            f"{tabelle} nicht unter den durchsuchten Tabellen",
        )
        z.pruefen(
            "Z02",
            len(spalten_je_tabelle.get(tabelle, [])) > 0,
            f"{tabelle} ohne gesuchte Spalte",
        )
        for f in ("A", "B"):
            z.pruefen(
                "Z02",
                anzahl_je_fall[(tabelle, f)] > 0,
                f"{tabelle} trägt keine Zeile von Fall {f}",
            )
    for s in katalog:
        if s.tabelle in tabellen:
            z.pruefen(
                "Z02",
                s.typ in TYPLISTE,
                f"{s.tabelle}.{s.name}: Typ {s.typ} ausserhalb der geschlossenen Typliste",
            )

    # ---- Z03 Suchlauf über die Suchfläche: null Treffer ----------------------------------------
    treffer = _suchen(texte, alle_begriffe)
    z.pruefen("Z03", not treffer, _meldung_treffer(treffer))

    # ---- Einträge der Spuren lesen -------------------------------------------------------------
    eintraege: dict[str, list[dict[str, Any]]] = {"A": [], "B": []}
    koepfe: list[dict[str, Any]] = []
    async with _verbindung(datenbank, ANWENDUNG) as v:
        async with v.begin():
            for spur in Spur:
                for zeile in await v.execute(
                    text(
                        "SELECT fall_kennung::text AS fall, person_kennung, eintragstyp, "
                        "kennzeichnung, payload, vorgaenger_pruefsumme, pruefsumme "
                        f"FROM r3cosint.{_bezeichner(spur.value)} ORDER BY position"
                    )
                ):
                    eintrag = dict(zeile._mapping)
                    eintrag["spur"] = spur.value
                    f = "A" if eintrag["fall"] == str(faelle["A"]) else "B"
                    eintraege[f].append(eintrag)
            for zeile in await v.execute(
                text(
                    "SELECT fall_kennung::text AS fall, spur, pruefsumme FROM r3cosint.kettenkopf"
                )
            ):
                koepfe.append(dict(zeile._mapping))

    # ---- Z04 positive Formprüfung (DS-S15-05) --------------------------------------------------
    for spur_name in ("ermittlungsspur", "arbeitsspur"):
        ist = {s.name for s in katalog if s.tabelle == spur_name and _gesucht(s)}
        z.pruefen(
            "Z04", ist == _SPALTEN_SPUR, f"{spur_name}: Textspalten ohne Formregel"
        )
    ist_kopf = {s.name for s in katalog if s.tabelle == "kettenkopf" and _gesucht(s)}
    z.pruefen(
        "Z04", ist_kopf == _SPALTEN_KOPF, "kettenkopf: Textspalten ohne Formregel"
    )
    for f in ("A", "B"):
        for e in eintraege[f]:
            ort = f"{e['spur']} Fall {f} {e['eintragstyp']}"
            z.pruefen(
                "Z04",
                _KENNUNGSFORM.match(e["person_kennung"]) is not None,
                f"{ort}: person_kennung",
            )
            z.pruefen(
                "Z04", e["eintragstyp"] in _SCHLUESSEL_JE_TYP, f"{ort}: eintragstyp"
            )
            z.pruefen(
                "Z04",
                e["kennzeichnung"] in {k.value for k in Kennzeichnung},
                f"{ort}: kennzeichnung",
            )
            for spalte in ("pruefsumme", "vorgaenger_pruefsumme"):
                z.pruefen(
                    "Z04", _HEX64.match(str(e[spalte])) is not None, f"{ort}: {spalte}"
                )
            nutzlast = json.loads(e["payload"])
            z.pruefen(
                "Z04",
                isinstance(nutzlast, dict)
                and set(nutzlast)
                == _SCHLUESSEL_JE_TYP.get(e["eintragstyp"], frozenset()),
                f"{ort}: Schlüsselmenge der Nutzlast",
            )
            if isinstance(nutzlast, dict):
                for schl, wert in nutzlast.items():
                    z.pruefen(
                        "Z04",
                        _blatt_form(schl, wert, {e["fall"]}, kategorien),
                        f"{ort}: Feld {schl} ausser Form",
                    )
    for k in koepfe:
        z.pruefen("Z04", k["spur"] in {s.value for s in Spur}, "kettenkopf: spur")
        z.pruefen(
            "Z04",
            _HEX64.match(str(k["pruefsumme"])) is not None,
            "kettenkopf: pruefsumme",
        )

    # ---- Z05 bis Z08 Pseudonyme, Schlüssel je Fall, ohne Schlüssel, Bindung --------------------
    def nutzlasten(f: str, typ: str) -> list[dict[str, Any]]:
        return [
            json.loads(e["payload"]) for e in eintraege[f] if e["eintragstyp"] == typ
        ]

    for f in ("A", "B"):
        fallschl = schluessel[f]
        eroeffnet = nutzlasten(f, "fall_eroeffnet")
        z.pruefen(
            "Z05", len(eroeffnet) == 1, f"Fall {f}: nicht genau ein fall_eroeffnet"
        )
        if eroeffnet:
            n = eroeffnet[0]
            for feld, roh in (
                ("aktenzeichen_pseudonym", AKTENZEICHEN[f]),
                ("rechtsgrundlage_pseudonym", RECHTSGRUNDLAGE),
                ("ermittelnde_person_pseudonym", ERMITTELNDE_PERSON),
            ):
                z.pruefen(
                    "Z05",
                    n.get(feld) == _pseudonym(fallschl, roh),
                    f"Fall {f}: {feld} weicht ab",
                )
        datenpunkt_nutzlasten = {
            n.get("entitaet_kennung", n.get("beziehung_kennung")): n
            for typ in ("entitaet", "beziehung")
            for n in nutzlasten(f, typ)
        }
        for name in REIHENFOLGE:
            punkt = punkte[f][name]
            ist_n = datenpunkt_nutzlasten.get(str(punkt.kennung))
            soll = _soll_nutzlast(fallschl, faelle[f], name, punkt)
            z.pruefen(
                "Z05",
                ist_n is not None
                and {s: w for s, w in ist_n.items() if s != "abfrage_bindung"}
                == {s: w for s, w in soll.items() if s != "abfrage_bindung"},
                f"Fall {f} {name}: Nutzlast weicht vom zweiten Rechenweg ab",
            )
            z.pruefen(
                "Z08",
                ist_n is not None
                and ist_n.get("abfrage_bindung") == soll["abfrage_bindung"],
                f"Fall {f} {name}: abfrage_bindung nicht über die exakten Bytes",
            )
        # Schreibvarianten tragen dasselbe Pseudonym (DS-S15-06).
        name_p1 = DATENSAETZE["p1"]["properties"]["name"][0]
        name_p2 = DATENSAETZE["p2"]["properties"]["name"][0]
        p1 = datenpunkt_nutzlasten.get(str(punkte[f]["p1"].kennung), {})
        p2 = datenpunkt_nutzlasten.get(str(punkte[f]["p2"].kennung), {})
        for variante in (name_p1.upper(), name_p1.lower(), " ".join(name_p1.split())):
            z.pruefen(
                "Z05",
                p1.get("eigenschaften", {}).get("name")
                == [_pseudonym(fallschl, variante)],
                f"Fall {f}: Schreibvariante p1 name mit anderem Pseudonym",
            )
        for variante in (unicodedata.normalize("NFC", name_p2), name_p2.upper()):
            z.pruefen(
                "Z05",
                p2.get("eigenschaften", {}).get("name")
                == [_pseudonym(fallschl, variante)],
                f"Fall {f}: Schreibvariante p2 name mit anderem Pseudonym",
            )
    # Schlüssel je Fall (Z06).
    for w in werte:
        if w.bezeichnung.startswith("aktenzeichen"):
            continue
        z.pruefen(
            "Z06",
            _pseudonym(schluessel["A"], w.roh) != _pseudonym(schluessel["B"], w.roh),
            f"{w.bezeichnung}: gleiches Pseudonym in A und B",
        )

    def pseudonyme(f: str) -> set[str]:
        menge: set[str] = set()
        for e in eintraege[f]:
            n = json.loads(e["payload"])
            for schl, wert in n.items():
                if schl.endswith(("_pseudonym", "_bindung")) and isinstance(wert, str):
                    menge.add(wert)
                elif schl == "eigenschaften" and isinstance(wert, dict):
                    menge.update(p for liste in wert.values() for p in liste)
        return menge

    for von, nach in (("A", "B"), ("B", "A")):
        fremde = pseudonyme(von)
        texte_nach = [t for t in texte if t.fall == str(faelle[nach])]
        quer = sum(1 for p in fremde for t in texte_nach if p in t.inhalt)
        z.pruefen(
            "Z06",
            quer == 0 and len(fremde) > 0,
            f"{quer} Pseudonyme von Fall {von} in Zeilen von Fall {nach}",
        )
    # Ohne Schlüssel (Z07).
    ohne = {
        f"{w.bezeichnung} ({form})": hashlib.sha256(s.encode("utf-8")).hexdigest()
        for w in (*werte, *versuch)
        for form, s in (
            ("roh", w.roh),
            ("angeglichen", w.angeglichen),
            ("normal", _normalform(w.roh)),
        )
    }
    ohne_treffer = [b for b, h in ohne.items() if any(h in t.inhalt for t in texte)]
    z.pruefen(
        "Z07", not ohne_treffer, f"SHA-256 ohne Schlüssel gefunden: {ohne_treffer[:6]}"
    )

    # ---- Z09 Ketten unversehrt, Anzahl wie geschrieben -----------------------------------------
    erwartet = {
        ("A", Spur.ARBEITSSPUR): 2,
        ("A", Spur.ERMITTLUNGSSPUR): len(REIHENFOLGE),
        ("B", Spur.ARBEITSSPUR): 1,
        ("B", Spur.ERMITTLUNGSSPUR): len(REIHENFOLGE),
    }
    async with _verbindung(datenbank, ANWENDUNG) as v:
        async with v.begin():
            anwendungsweg = await ketten_aller_faelle_pruefen(v)
        datenbankweg = {}
        for f in ("A", "B"):
            async with v.begin():
                datenbankweg[f] = await kette_pruefen_datenbank(v, faelle[f])
    z.pruefen("Z09", len(anwendungsweg) == len(erwartet), "Zahl der Befunde weicht ab")
    for befund in anwendungsweg:
        f = "A" if befund.fall_kennung == faelle["A"] else "B"
        soll_anzahl = erwartet.get((f, befund.spur))
        z.pruefen(
            "Z09",
            befund.unversehrt and befund.anzahl == soll_anzahl,
            f"Anwendungsweg Fall {f} {befund.spur.value}: nicht unversehrt oder Anzahl abweichend",
        )
        z.pruefen(
            "Z09",
            datenbankweg[f].get(befund.spur) == befund,
            f"Datenbankweg Fall {f} {befund.spur.value}: weicht vom Anwendungsweg ab",
        )
    for (f, spur), anzahl in erwartet.items():
        geschrieben = sum(1 for e in eintraege[f] if e["spur"] == spur.value)
        z.pruefen(
            "Z09",
            geschrieben == anzahl,
            f"Fall {f} {spur.value}: {geschrieben} statt {anzahl}",
        )

    # ---- Z13 Gegenprobe (a) am Bestand ---------------------------------------------------------
    async with _verbindung(datenbank, EIGENTUEMER) as v:
        bestand_texte, _ = await _texte_lesen(v, katalog, BESTAND)
    # Je Wert ein Treffer in einer Spalte, nicht allein in der Zeilenform: sonst blieben
    # Katalogabfrage und Typfilter unbelegt (ST-S15-01, M13).
    for w in werte:
        in_spalten = [
            t
            for t in _suchen(bestand_texte, {w.bezeichnung: begriffe[w.bezeichnung]})
            if t[1] != "<zeile>"
        ]
        z.pruefen(
            "Z13",
            bool(in_spalten),
            f"{w.bezeichnung}: im Bestand in keiner Spalte gefunden",
        )
    versuch_im_bestand = _suchen(bestand_texte, begriffe_versuch)
    z.pruefen(
        "Z13",
        not versuch_im_bestand,
        "Wert des abgewiesenen Versuchs im Bestand: "
        + _meldung_treffer(versuch_im_bestand),
    )

    # ---- Z14 Gegenprobe (b): eingebrachter Klartext --------------------------------------------
    eingebracht = (
        (
            "ermittlungsspur",
            "p1 name 0",
            DATENSAETZE["p1"]["properties"]["name"][0],
            "entitaet",
        ),
        ("arbeitsspur", "aktenzeichen A", AKTENZEICHEN["A"], "fall_eroeffnet"),
    )
    for tabelle, bezeichnung, wert, typ in eingebracht:
        ziel = next(
            e
            for e in eintraege["B"]
            if e["spur"] == tabelle and e["eintragstyp"] == typ
        )
        neu = {**json.loads(ziel["payload"]), "eingebracht": wert}
        literal = json.dumps(neu, ensure_ascii=False).replace("'", "''")
        rolle = await manipulieren(
            f"UPDATE r3cosint.{tabelle} SET payload = '{literal}' "
            f"WHERE pruefsumme = '{ziel['pruefsumme']}'"
        )
        z.pruefen(
            "Z14",
            rolle == "origin",
            "Replikationsparameter nach der Gegenprobe nicht wieder origin",
        )
        async with _verbindung(datenbank, ANWENDUNG) as v:
            nach_texte, _ = await _texte_lesen(v, katalog, tabellen)
        orte = {
            (t, s)
            for t, s, _, _ in _suchen(nach_texte, {bezeichnung: begriffe[bezeichnung]})
        }
        z.pruefen(
            "Z14",
            (tabelle, "payload") in orte and {t for t, _ in orte} == {tabelle},
            f"eingebrachter Wert {bezeichnung}: Fundorte {sorted(orte)}",
        )

    # ---- Ausgabe und Urteil ---------------------------------------------------------------------
    ausgaben_rest = capfd.readouterr()
    gefunden = _in_texten((ausgaben_rest.out, ausgaben_rest.err), alle_begriffe)
    z.pruefen(
        "Z12",
        not gefunden,
        f"Suchbegriff in Ausgaben nach dem Testfall: {gefunden[:6]}",
    )
    anzahl_begriffe = sum(len(b) for b in alle_begriffe.values())
    zeilen = ["", "R3-F-011 Suchfläche (Tabelle: Zahl der durchsuchten Spalten):"]
    zeilen += [f"  {t}: {len(spalten_je_tabelle[t])}" for t in tabellen]
    zeilen.append(
        f"R3-F-011 Klartextwerte {len(werte)} plus {len(versuch)} des Versuchs, "
        f"Suchbegriffe {anzahl_begriffe}, durchsuchte Texte {len(texte)}, "
        f"Meldungen sqlalchemy.engine {len(engine_meldungen)}"
    )
    zeilen += [
        f"  {kennung}: " + ("gruen" if not liste else f"rot ({len(liste)})")
        for kennung, liste in sorted(z.stand.items())
    ]
    with capfd.disabled():
        sys.stdout.write("\n".join(zeilen) + "\n")
    verletzt = z.verletzt()
    assert not verletzt, "\n".join(verletzt[:40])
