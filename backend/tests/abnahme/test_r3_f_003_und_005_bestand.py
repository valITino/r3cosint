"""Abnahmetests R3-F-003 und R3-F-005 (ADR 0007, Festlegung S1.4, Zeile "Tests Abnahme").

R3-F-003 (Backlog, Abnahme `R3-F-003_ftm_schemakonform`, Präzisierung vom 2026-11-09): erzeugte
Entitäten validieren gegen das FollowTheMoney-Schema der versionierten Schemadateien; erzeugt
heisst geschrieben über kanon.service.schreiben für einen eröffneten Fall mit vollständigem
Herkunftsnachweis. (a) Gegenprobe je Knoten- und Kantenschema des Vorrats (E-S14-01, Bau auf b):
lesbar mit Schema, FollowTheMoney-Kennung und Eigenschaften, dem Fall zugeordnet, das Gelesene
validiert gegen das Schema, die Ermittlungsspur trägt je Knoten einen Eintrag entitaet und je
Kante einen Eintrag beziehung, Kettenprüfung unversehrt (beide Rechenwege). (b) Abweisungen je in
einem eigenen Prüffall; danach kein Teil des Datensatzes in entitaet, beziehung oder herkunft,
Ermittlungsspur und Kettenkopf unverändert, kein Protokolleintrag der Abweisung.

R3-F-005 (Backlog, Abnahme `R3-F-005_kein_knoten_ohne_herkunft`): jede der fünf Angaben einzeln
fehlend, jede Textangabe leer, jede Angabe ausserhalb ihrer Form, Verweis ins Leere; je für Knoten
und Kante, auf beiden Schreibwegen (kanon.service.schreiben und unmittelbar als Anwendungsrolle);
danach nichts aus dem Versuch im Bestand, Spur und Kettenkopf unverändert, Enden einer Kante
unverändert; Gegenprobe mit vollständigem Herkunftsnachweis gelingt, Herkunftssatz mit allen fünf
Angaben lesbar.

R3-F-005 (Backlog, Abnahme `R3-F-005_bestand_ohne_herkunftsluecke`): kanon.service.herkunft_pruefen
zählt über den ganzen Bestand (alle Fälle) die Datenpunkte ohne vollständigen Herkunftsnachweis,
je Form (verweis_ins_leere, anderer_fall, unvollstaendig, mehrfach_verwendet); an zwei Fällen mit
Knoten und Kanten 0; jede eingebrachte Form erhöht Anzahl und Zählwert ihrer Form um genau 1;
geprüft unter REPEATABLE READ mit der Isolationsstufe im Befund (Nachbesserung S1.4.1).

Massstab der Erwartungswerte: die Einträge R3-F-003 und R3-F-005 in docs/05_Product_Backlog.md
(Wortlaut massgebend) und ADR 0007, Teil A, Festlegung S1.4 in der Fassung nach der Nachbesserung
(Zeilen Umfang der Validierung, kanon.eingabe, kanon.service, herkunft_pruefen, Revision 0005,
spur.payload, core, Tests Abnahme). Fehlerfälle prüfen die Fehlerklasse aus core, nicht den Text
der sache; dazu nach DS-S14-01, dass str und repr der Ausnahme und ihrer Ursachen keinen
synthetischen Wert des Versuchs nennen. Die Namen der Nutzlastfelder der Herkunft (werkzeug,
erhoben_am, erhebende_person, abfrage_pseudonym, abfrage_bindung) und die Bindung nach
Pseudonymisierer.bindung sind der Festlegung entnommen (Zeile spur.payload) und hier unabhängig
nachgerechnet (hmac, hashlib). Geschrieben vor dem Bau vom Dynamic Software Tester; die Tests werden
nicht an die Umsetzung angepasst, Abweichungen gehen an den Koordinator.

Bedarf an Phase 2 (nicht hier gebaut): manipulieren in backend/tests/conftest.py nimmt herkunft,
entitaet und beziehung an, auch für bedingungen_entfernen (Festlegung S1.4, Zeile Tests
Integration); Herkunftsbefund trägt isolationsstufe (Zeile kanon.eingabe). Bis dahin sind die Tests
rot.

Alle Werte sind erfunden (5.15, DS-S14-05): jeder Text- und Kennungswert der Datensätze und der
Herkunft trägt die Marke "synth" (TEST-SYNTH, synth-, synth.), keine Beispieldaten aus den
Schemadateien oder öffentlichen Quellen. Jeder Vorgang läuft in einer eigenen Klammer
verbindung.begin().
"""

import hashlib
import hmac
import json
import re
from collections.abc import Awaitable, Callable, Mapping, Sequence
from dataclasses import dataclass, field
from datetime import UTC, datetime, timedelta
from typing import Any, Protocol
from uuid import UUID, uuid4

import pytest
from sqlalchemy import text
from sqlalchemy.exc import DBAPIError
from sqlalchemy.ext.asyncio import AsyncConnection

from r3cosint.core.fehler import (
    EindeutigkeitsFehler,
    EingabeFehler,
    HerkunftFehler,
    R3cosintFehler,
    SchemaFehler,
    ZustandsFehler,
)
from r3cosint.fall.service import Fall, schliessen
from r3cosint.kanon.eingabe import Datensatz
from r3cosint.kanon.ftm import pruefen as ftm_pruefen
from r3cosint.kanon.ftm import schemata
from r3cosint.kanon.service import (
    VORRAT_KANTEN,
    VORRAT_KNOTEN,
    Datenpunkt,
    Datenpunktart,
    Herkunftsbefund,
    Herkunftsluecke,
    datenpunkte_lesen,
    herkunft_lesen,
    herkunft_pruefen,
    schreiben,
)
from r3cosint.spur.service import (
    Befund,
    Kennzeichnung,
    Pseudonymisierer,
    Spur,
    kette_pruefen,
    kette_pruefen_datenbank,
)
from r3cosint.spur.store import eintraege_lesen

pytestmark = [pytest.mark.anyio, pytest.mark.abnahme]

# ---------------------------------------------------------------------------------------------
# Synthetische Ausgangslage (5.15)
# ---------------------------------------------------------------------------------------------

PERSON = "test.ermittlung"
"""Handelnde Person (person_kennung), getrennt von der erhebenden Person (E-S14-13)."""
ERHEBENDE_PERSON = "synth.erhebung"
WERKZEUG = "synth.werkzeug-1"
# Doppelter Leerraum und Grossbuchstaben: abfrage wird unverändert gespeichert; die Bindung läuft
# über die exakten Bytes, das Pseudonym über die Normalform (Festlegung, Zeile spur.payload).
ABFRAGE = 'SYNTH-Abfrage  Name:"TEST-SYNTH Erfundene Person"'
ERHOBEN = datetime(2026, 2, 1, 9, 15, 0, 250000, tzinfo=UTC)
JETZT = datetime(2026, 2, 2, 10, 0, 0, 500000, tzinfo=UTC)
SCHLIESSEN = datetime(2026, 2, 1, 12, 0, 0, tzinfo=UTC)
MARKE = "synth"
"""Jeder synthetische Wert eines Versuchs trägt diese Marke (Gross- und Kleinschreibung egal)."""

_FELD_ISOLATIONSSTUFE = "isolationsstufe"
"""Feld des Herkunftsbefunds nach der Nachbesserung (DF-S14-07, Hinweis 2); gelesen über getattr,
weil Phase 1 das Feld noch nicht trägt."""


@dataclass(frozen=True)
class _FesteUhr:
    """Uhr mit festem Zeitpunkt."""

    zeitpunkt: datetime = JETZT

    def jetzt(self) -> datetime:
        """Liefert den festen Zeitpunkt."""
        return self.zeitpunkt


@dataclass
class _FortschreitendeUhr:
    """Uhr, die je Aufruf um eine Millisekunde fortschreitet (Invariante, DF-S14-05)."""

    zeitpunkt: datetime = JETZT
    aufrufe: int = field(default=0)

    def jetzt(self) -> datetime:
        """Liefert den nächsten Zeitpunkt."""
        wert = self.zeitpunkt + timedelta(milliseconds=self.aufrufe)
        self.aufrufe += 1
        return wert


class _Eroeffnet(Protocol):
    """Was diese Tests vom EroeffneterFall der Fixture faelle_eroeffnen brauchen."""

    @property
    def fall(self) -> Fall: ...

    @property
    def pseudonymisierer(self) -> Pseudonymisierer: ...


FaelleEroeffnen = Callable[[int], Awaitable[Sequence[_Eroeffnet]]]
SchluesselLesen = Callable[[UUID], Awaitable[bytes]]
Manipulieren = Callable[..., Awaitable[str]]


def _herkunft(
    kennzeichnung: Kennzeichnung = Kennzeichnung.QUELLENAUSSAGE,
) -> dict[str, object]:
    """Vollständiger Herkunftsnachweis mit allen fünf Angaben (R3-F-005)."""
    return {
        "werkzeug": WERKZEUG,
        "abfrage": ABFRAGE,
        "zeitpunkt": ERHOBEN,
        "erhebende_person": ERHEBENDE_PERSON,
        "kennzeichnung": kennzeichnung,
    }


def _knoten(schema: str, ftm: str, **weitere: list[str]) -> dict[str, object]:
    """Knoten in der Form von FollowTheMoney mit Pflichteigenschaft name (über Thing)."""
    return {
        "id": ftm,
        "schema": schema,
        "properties": {"name": [f"TEST-SYNTH {schema} {ftm}"], **weitere},
    }


def _kante(schema: str, ftm: str, **eigenschaften: list[str]) -> dict[str, object]:
    """Kante in der Form von FollowTheMoney; die Enden stehen als Eigenschaften (source, target)."""
    return {"id": ftm, "schema": schema, "properties": dict(eigenschaften)}


# Je Knotenschema des Vorrats: zusätzliche Eigenschaft (geerbt von Thing, Typ ungeprüft, GS-33).
KNOTEN: dict[str, dict[str, list[str]]] = {
    "Person": {"notes": ["TEST-SYNTH Notiz zur erfundenen Person"]},
    "LegalEntity": {"alias": ["TEST-SYNTH Rechtsträger-Alias"]},
    "Organization": {"summary": ["TEST-SYNTH erfundene Organisation"]},
    "Company": {"alias": ["TEST-SYNTH Firma AG", "TEST-SYNTH Firma Holding"]},
    "Asset": {"notes": ["TEST-SYNTH erfundener Vermögenswert"]},
}


@dataclass(frozen=True)
class KantenFall:
    """Kantenschema mit Quell- und Zieleigenschaft und dem Schema der Enden im Bestand.

    Die Enden sind teils Unterschemata des range (Company für Asset und Organization), damit die
    Vererbung beim Prüfen des range belegt ist.
    """

    quelle: str
    quelle_schema: str
    ziel: str
    ziel_schema: str


KANTEN: dict[str, KantenFall] = {
    "Ownership": KantenFall("owner", "Person", "asset", "Company"),
    "Directorship": KantenFall("director", "Person", "organization", "Company"),
    "Control": KantenFall("controller", "Organization", "controlled", "LegalEntity"),
    "Employment": KantenFall("employee", "Person", "employer", "Organization"),
    "Associate": KantenFall("person", "Person", "associate", "Person"),
    "Family": KantenFall("person", "Person", "relative", "Person"),
}

# ---------------------------------------------------------------------------------------------
# Lesen, Zustand, Ketten
# ---------------------------------------------------------------------------------------------

_STAND_SQL = {
    "fall": "SELECT kennung, zustand FROM r3cosint.fall ORDER BY kennung",
    "kettenkopf": "SELECT fall_kennung, spur, position, pruefsumme FROM r3cosint.kettenkopf "
    "ORDER BY fall_kennung, spur",
    "arbeitsspur": "SELECT kennung, fall_kennung, position, eintragstyp, payload, pruefsumme "
    "FROM r3cosint.arbeitsspur ORDER BY fall_kennung, position",
    "ermittlungsspur": "SELECT kennung, fall_kennung, position, eintragstyp, payload, pruefsumme "
    "FROM r3cosint.ermittlungsspur ORDER BY fall_kennung, position",
    "herkunft": "SELECT kennung, fall_kennung, werkzeug, abfrage, zeitpunkt, erhebende_person, "
    "kennzeichnung, erstellt_am FROM r3cosint.herkunft ORDER BY kennung",
    "entitaet": "SELECT kennung, fall_kennung, ftm_kennung, schema, eigenschaften, "
    "herkunft_kennung, erstellt_am FROM r3cosint.entitaet ORDER BY kennung",
    "beziehung": "SELECT kennung, fall_kennung, ftm_kennung, schema, eigenschaften, "
    "herkunft_kennung, quelle_kennung, ziel_kennung, erstellt_am FROM r3cosint.beziehung "
    "ORDER BY kennung",
}


async def _stand(verbindung: AsyncConnection) -> dict[str, list[tuple[Any, ...]]]:
    """Alle Zeilen von fall (Kennung, Zustand), Kettenkopf, beiden Spuren und dem Bestand."""
    stand: dict[str, list[tuple[Any, ...]]] = {}
    async with verbindung.begin():
        for name, sql in _STAND_SQL.items():
            stand[name] = [tuple(z) for z in await verbindung.execute(text(sql))]
    return stand


async def _ketten_unversehrt(
    verbindung: AsyncConnection, fall: UUID, *, ermittlungsspur: int, arbeitsspur: int
) -> None:
    """Beide Rechenwege, je in eigener Transaktion: unversehrt, Anzahl und Kopf wie erwartet."""
    async with verbindung.begin():
        anwendungsweg = await kette_pruefen(verbindung, fall)
    async with verbindung.begin():
        datenbankweg = await kette_pruefen_datenbank(verbindung, fall)
    erwartet = {Spur.ARBEITSSPUR: arbeitsspur, Spur.ERMITTLUNGSSPUR: ermittlungsspur}
    for weg in (anwendungsweg, datenbankweg):
        assert set(weg) == set(Spur)
        for spur, anzahl in erwartet.items():
            befund: Befund = weg[spur]
            assert befund.unversehrt, (spur, befund)
            assert befund.anzahl == anzahl, (spur, befund)
            assert befund.kopf_position == anzahl, (spur, befund)
    assert anwendungsweg == datenbankweg


async def _schreiben(
    verbindung: AsyncConnection,
    fall: UUID,
    datensatz: Mapping[str, object],
    *,
    herkunft: Mapping[str, object] | None = None,
    uhr: _FesteUhr | _FortschreitendeUhr | None = None,
) -> Datenpunkt:
    """Schreibt über kanon.service.schreiben in einer eigenen Transaktion mit commit."""
    async with verbindung.begin():
        return await schreiben(
            verbindung,
            fall_kennung=fall,
            datensatz=datensatz,
            herkunft=_herkunft() if herkunft is None else herkunft,
            person_kennung=PERSON,
            uhr=_FesteUhr() if uhr is None else uhr,
        )


async def _datenpunkte(verbindung: AsyncConnection, fall: UUID) -> list[Datenpunkt]:
    async with verbindung.begin():
        return await datenpunkte_lesen(verbindung, fall)


def _zeit_text(zeitpunkt: datetime) -> str:
    """Erwartete Zeitform der Nutzlast (Nr. 18), von Hand gebildet."""
    u = zeitpunkt.astimezone(UTC)
    return (
        f"{u.year:04d}-{u.month:02d}-{u.day:02d}T{u.hour:02d}:{u.minute:02d}:"
        f"{u.second:02d}.{u.microsecond:06d}Z"
    )


def _bindung(schluessel: bytes, wert: str) -> str:
    """Pseudonymisierer.bindung nach der Festlegung, unabhängig nachgerechnet (DF-S14-01)."""
    return hmac.new(
        schluessel, b"r3cosint-bindung-1\n" + wert.encode("utf-8"), hashlib.sha256
    ).hexdigest()


def _ohne_klartext_im_fehler(fehler: BaseException) -> None:
    """str und repr der Ausnahme und aller Ursachen nennen keinen synthetischen Wert (DS-S14-01)."""
    gesehen: set[int] = set()
    offen: list[BaseException] = [fehler]
    while offen:
        aktuell = offen.pop()
        if id(aktuell) in gesehen:
            continue
        gesehen.add(id(aktuell))
        for darstellung in (str(aktuell), repr(aktuell)):
            assert MARKE not in darstellung.casefold(), (
                "Fehlertext nennt einen Wert des Versuchs",
                type(aktuell).__name__,
            )
        for ursache in (aktuell.__cause__, aktuell.__context__):
            if ursache is not None:
                offen.append(ursache)


def _sqlstate(fehler: DBAPIError) -> str | None:
    zustand = getattr(fehler.orig, "sqlstate", None)
    return zustand if isinstance(zustand, str) else None


async def _befund_wiederholbar(verbindung: AsyncConnection) -> Herkunftsbefund:
    """herkunft_pruefen unter REPEATABLE READ (Nachweis eines einzigen Stands, Nachbesserung)."""
    async with verbindung.begin():
        await verbindung.execute(
            text("SET TRANSACTION ISOLATION LEVEL REPEATABLE READ")
        )
        stufe = (
            await verbindung.execute(
                text("SELECT current_setting('transaction_isolation')")
            )
        ).scalar_one()
        assert stufe == "repeatable read"
        befund = await herkunft_pruefen(verbindung)
    assert getattr(befund, _FELD_ISOLATIONSSTUFE) == "repeatable read"
    return befund


# ---------------------------------------------------------------------------------------------
# Unmittelbarer Weg der Anwendungsrolle (INSERT mit Bindeparametern)
# ---------------------------------------------------------------------------------------------

_SPALTEN: dict[str, tuple[str, ...]] = {
    "herkunft": (
        "kennung",
        "fall_kennung",
        "werkzeug",
        "abfrage",
        "zeitpunkt",
        "erhebende_person",
        "kennzeichnung",
        "erstellt_am",
    ),
    "entitaet": (
        "kennung",
        "fall_kennung",
        "ftm_kennung",
        "schema",
        "eigenschaften",
        "herkunft_kennung",
        "erstellt_am",
    ),
    "beziehung": (
        "kennung",
        "fall_kennung",
        "ftm_kennung",
        "schema",
        "eigenschaften",
        "herkunft_kennung",
        "quelle_kennung",
        "ziel_kennung",
        "erstellt_am",
    ),
}
_EINFUEGEN = "INSERT INTO r3cosint.{tabelle} ({spalten}) VALUES ({werte})"


def _einfuegen_sql(tabelle: str, werte: Mapping[str, object]) -> str:
    """INSERT mit festen Tabellen- und Spaltennamen; jeder Wert als Bindeparameter."""
    erlaubt = _SPALTEN[tabelle]
    if not set(werte) <= set(erlaubt):
        raise ValueError("Spalte ausserhalb der festen Liste")
    spalten = [s for s in erlaubt if s in werte]
    platzhalter = [
        "CAST(CAST(:eigenschaften AS text) AS jsonb)"
        if s == "eigenschaften"
        else ":" + s
        for s in spalten
    ]
    return (
        _EINFUEGEN.replace("{tabelle}", tabelle)
        .replace("{spalten}", ", ".join(spalten))
        .replace("{werte}", ", ".join(platzhalter))
    )


def _herkunft_zeile(fall: UUID, **aenderung: object) -> dict[str, object]:
    """Vollständige Zeile für herkunft; aenderung setzt oder entfernt (Wert _FEHLT) Spalten."""
    zeile: dict[str, object] = {
        "kennung": uuid4(),
        "fall_kennung": fall,
        "werkzeug": WERKZEUG,
        "abfrage": ABFRAGE,
        "zeitpunkt": ERHOBEN,
        "erhebende_person": ERHEBENDE_PERSON,
        "kennzeichnung": "quellenaussage",
        "erstellt_am": JETZT,
    }
    return _aendern(zeile, aenderung)


def _knoten_zeile(
    fall: UUID, herkunft: object, **aenderung: object
) -> dict[str, object]:
    zeile: dict[str, object] = {
        "kennung": uuid4(),
        "fall_kennung": fall,
        "ftm_kennung": f"synth-direkt-{uuid4().hex[:12]}",
        "schema": "Person",
        "eigenschaften": json.dumps({"name": ["TEST-SYNTH unmittelbar geschrieben"]}),
        "herkunft_kennung": herkunft,
        "erstellt_am": JETZT,
    }
    return _aendern(zeile, aenderung)


def _kanten_zeile(
    fall: UUID, herkunft: object, quelle: UUID, ziel: UUID, **aenderung: object
) -> dict[str, object]:
    zeile: dict[str, object] = {
        "kennung": uuid4(),
        "fall_kennung": fall,
        "ftm_kennung": f"synth-direkt-{uuid4().hex[:12]}",
        "schema": "Ownership",
        "eigenschaften": json.dumps(
            {"owner": ["synth-ende-q"], "asset": ["synth-ende-z"]}
        ),
        "herkunft_kennung": herkunft,
        "quelle_kennung": quelle,
        "ziel_kennung": ziel,
        "erstellt_am": JETZT,
    }
    return _aendern(zeile, aenderung)


_FEHLT = object()


def _aendern(
    zeile: dict[str, object], aenderung: Mapping[str, object]
) -> dict[str, object]:
    for name, wert in aenderung.items():
        if name not in zeile:
            raise ValueError("Spalte unbekannt")
        if wert is _FEHLT:
            del zeile[name]
        else:
            zeile[name] = wert
    return zeile


async def _einfuegen(
    verbindung: AsyncConnection, tabelle: str, zeile: Mapping[str, object]
) -> None:
    await verbindung.execute(text(_einfuegen_sql(tabelle, zeile)), dict(zeile))


# ---------------------------------------------------------------------------------------------
# Manipulation der Teststufe (Superuser über manipulieren; Werte als geprüfte Literale)
# ---------------------------------------------------------------------------------------------

_LITERAL = re.compile(r"^[A-Za-z0-9 .:+_-]{1,80}$")
_PLATZHALTER = re.compile(r"\{[a-z_]+\}")

_M_HERKUNFT = (
    "INSERT INTO r3cosint.herkunft (kennung, fall_kennung, werkzeug, abfrage, zeitpunkt, "
    "erhebende_person, kennzeichnung, erstellt_am) VALUES ('{kennung}', '{fall}', '{werkzeug}', "
    "'SYNTH-Abfrage eingebracht', '2026-02-01 09:15:00+00', 'synth.erhebung', 'quellenaussage', "
    "'2026-02-02 10:00:00+00')"
)
_M_ENTITAET = (
    "INSERT INTO r3cosint.entitaet (kennung, fall_kennung, ftm_kennung, schema, eigenschaften, "
    "herkunft_kennung, erstellt_am) VALUES ('{kennung}', '{fall}', '{ftm}', 'Person', "
    "CAST('{\"name\": [\"TEST-SYNTH eingebracht\"]}' AS jsonb), '{herkunft}', "
    "'2026-02-02 10:00:00+00')"
)
_M_BEZIEHUNG = (
    "INSERT INTO r3cosint.beziehung (kennung, fall_kennung, ftm_kennung, schema, eigenschaften, "
    "herkunft_kennung, quelle_kennung, ziel_kennung, erstellt_am) VALUES ('{kennung}', '{fall}', "
    "'{ftm}', 'Ownership', CAST('{\"summary\": [\"TEST-SYNTH eingebracht\"]}' AS jsonb), "
    "'{herkunft}', '{quelle}', '{ziel}', '2026-02-02 10:00:00+00')"
)


def _sql(vorlage: str, **werte: object) -> str:
    """Setzt geprüfte Werte in eine feste Vorlage ein (manipulieren nimmt keine Bindeparameter)."""
    ergebnis = vorlage
    for name, wert in werte.items():
        textwert = str(wert)
        if not _LITERAL.fullmatch(textwert):
            raise ValueError(f"Wert für {name} ausserhalb des Musters")
        ergebnis = ergebnis.replace("{" + name + "}", textwert)
    if _PLATZHALTER.search(ergebnis):
        raise ValueError("Vorlage mit nicht ersetztem Platzhalter")
    return ergebnis


# ---------------------------------------------------------------------------------------------
# R3-F-003_ftm_schemakonform
# ---------------------------------------------------------------------------------------------


@dataclass(frozen=True)
class Abweisung:
    """Ein Abweisungsfall: Datensatz, Fehlerklasse aus core oder SQLSTATE des unmittelbaren Wegs."""

    fehlerklasse: type[R3cosintFehler] | None
    sqlstate: str | None = None


# Bestand vor jedem Abweisungsfall (Fall A aktiv): Knoten synth-p-1 (Person), synth-p-2 (Person),
# synth-c-1 (Company), Kante synth-k-1 (Ownership synth-p-1 -> synth-c-1); in Fall B Knoten
# synth-p-b (Person).
ABWEISUNGEN: dict[str, Abweisung] = {
    # Wortlaut (b) des Kriteriums
    "unbekanntes_schema": Abweisung(SchemaFehler),
    "abstraktes_schema_thing": Abweisung(SchemaFehler),
    "abstraktes_schema_interest": Abweisung(SchemaFehler),
    "ausserhalb_vorrat_knoten_vehicle": Abweisung(SchemaFehler),
    "ausserhalb_vorrat_kante_membership": Abweisung(SchemaFehler),
    "unbekannte_eigenschaft": Abweisung(SchemaFehler),
    "kante_ein_ende_fehlt": Abweisung(EingabeFehler),
    "kante_beide_enden_fehlen": Abweisung(EingabeFehler),
    # Ergänzung vom 2026-11-09 (FA-S14-01, -02, -03, -09, -10)
    "fall_abgeschlossen": Abweisung(ZustandsFehler),
    "kante_ende_in_anderem_fall": Abweisung(EingabeFehler),
    "direkt_knoten_herkunft_anderer_fall": Abweisung(None, "23503"),
    "direkt_kante_herkunft_anderer_fall": Abweisung(None, "23503"),
    "direkt_kante_ende_anderer_fall": Abweisung(None, "23503"),
    "pflichteigenschaft_fehlt_knoten": Abweisung(SchemaFehler),
    "pflichteigenschaft_fehlt_kante": Abweisung(SchemaFehler),
    "doppelte_kennung_knoten": Abweisung(EindeutigkeitsFehler),
    "doppelte_kennung_kante": Abweisung(EindeutigkeitsFehler),
    "kennung_eines_knotens_als_kante": Abweisung(EindeutigkeitsFehler),
    "kennung_einer_kante_als_knoten": Abweisung(EindeutigkeitsFehler),
    "kante_mit_kante_als_ende": Abweisung(EingabeFehler),
    # Weitere Abweisungsfälle der Festlegung (Zeile Umfang der Validierung, kanon.service)
    "stub_eigenschaft_aus_reverse": Abweisung(SchemaFehler),
    "entity_ausserhalb_der_enden": Abweisung(SchemaFehler),
    "ende_mit_zwei_werten": Abweisung(SchemaFehler),
    "range_verletzt": Abweisung(SchemaFehler),
    "unbekannter_fall": Abweisung(EingabeFehler),
}


def _abweisender_datensatz(name: str) -> dict[str, object]:
    """Datensatz des Abweisungsfalls (allein der Weg über kanon)."""
    p1, c1 = ["synth-p-1"], ["synth-c-1"]
    neu = f"synth-neu-{name.replace('_', '-')}"
    match name:
        case "unbekanntes_schema":
            return _knoten("SynthErfundenesSchema", neu)
        case "abstraktes_schema_thing":
            return _knoten("Thing", neu)
        case "abstraktes_schema_interest":
            return _kante("Interest", neu, summary=["TEST-SYNTH abstrakt"])
        case "ausserhalb_vorrat_knoten_vehicle":
            return _knoten("Vehicle", neu)
        case "ausserhalb_vorrat_kante_membership":
            return _kante("Membership", neu, member=p1, organization=c1)
        case "unbekannte_eigenschaft":
            return _knoten("Person", neu, synthErfundeneEigenschaft=["TEST-SYNTH x"])
        case "kante_ein_ende_fehlt":
            return _kante("Ownership", neu, owner=p1, asset=["synth-fehlt-1"])
        case "kante_beide_enden_fehlen":
            return _kante(
                "Ownership", neu, owner=["synth-fehlt-1"], asset=["synth-fehlt-2"]
            )
        case "fall_abgeschlossen":
            return _knoten("Person", neu)
        case "kante_ende_in_anderem_fall":
            return _kante("Associate", neu, person=p1, associate=["synth-p-b"])
        case "pflichteigenschaft_fehlt_knoten":
            return {
                "id": neu,
                "schema": "Person",
                "properties": {"notes": ["TEST-SYNTH ohne Namen"]},
            }
        case "pflichteigenschaft_fehlt_kante":
            return _kante("Ownership", neu, owner=p1)
        case "doppelte_kennung_knoten":
            return _knoten("Person", "synth-p-1")
        case "doppelte_kennung_kante":
            return _kante("Ownership", "synth-k-1", owner=["synth-p-2"], asset=c1)
        case "kennung_eines_knotens_als_kante":
            return _kante("Ownership", "synth-p-2", owner=p1, asset=c1)
        case "kennung_einer_kante_als_knoten":
            return _knoten("Person", "synth-k-1")
        case "kante_mit_kante_als_ende":
            return _kante("Control", neu, controller=p1, controlled=["synth-k-1"])
        case "stub_eigenschaft_aus_reverse":
            return _knoten("Person", neu, ownershipOwner=["synth-k-1"])
        case "entity_ausserhalb_der_enden":
            return _knoten("Person", neu, parent=c1)
        case "ende_mit_zwei_werten":
            return _kante("Ownership", neu, owner=["synth-p-1", "synth-p-2"], asset=c1)
        case "range_verletzt":
            return _kante("Ownership", neu, owner=p1, asset=["synth-p-2"])
        case "unbekannter_fall":
            return _knoten("Person", neu)
    raise ValueError("Abweisungsfall unbekannt")


FAELLE_003 = [
    *(f"gegenprobe_knoten_{s}" for s in KNOTEN),
    *(f"gegenprobe_kante_{s}" for s in KANTEN),
    *(f"abgewiesen_{name}" for name in ABWEISUNGEN),
]


async def _gegenprobe_003(
    verbindung: AsyncConnection,
    fall_art: str,
    a: _Eroeffnet,
    b: _Eroeffnet,
    schluessel: bytes,
) -> None:
    """(a): je Schema des Vorrats ein schemakonformer Datensatz, gelesen, validiert, in der Spur."""
    fall = a.fall.kennung
    uhr = _FortschreitendeUhr()
    erwartet: dict[str, dict[str, object]] = {}
    pruefling: str
    if fall_art.startswith("gegenprobe_knoten_"):
        schema = fall_art.removeprefix("gegenprobe_knoten_")
        pruefling = f"synth-pruef-{schema.lower()}"
        erwartet[pruefling] = _knoten(schema, pruefling, **KNOTEN[schema])
    else:
        schema = fall_art.removeprefix("gegenprobe_kante_")
        kf = KANTEN[schema]
        quelle, ziel = f"synth-q-{schema.lower()}", f"synth-z-{schema.lower()}"
        erwartet[quelle] = _knoten(kf.quelle_schema, quelle)
        erwartet[ziel] = _knoten(kf.ziel_schema, ziel)
        pruefling = f"synth-pruef-{schema.lower()}"
        erwartet[pruefling] = _kante(
            schema,
            pruefling,
            **{kf.quelle: [quelle], kf.ziel: [ziel]},
            summary=["TEST-SYNTH erfundene Kante"],
        )
    # Die Enden mit quellenaussage, der Prüfling mit schlussfolgerung (FA-S14-08).
    geschrieben: dict[str, Datenpunkt] = {}
    for ftm, datensatz in erwartet.items():
        kennzeichnung = (
            Kennzeichnung.SCHLUSSFOLGERUNG
            if ftm == pruefling
            else Kennzeichnung.QUELLENAUSSAGE
        )
        geschrieben[ftm] = await _schreiben(
            verbindung, fall, datensatz, herkunft=_herkunft(kennzeichnung), uhr=uhr
        )

    # Lesbar, dem Fall zugeordnet, gegen das Schema validiert.
    gelesen = {d.ftm_kennung: d for d in await _datenpunkte(verbindung, fall)}
    assert set(gelesen) == set(erwartet)
    assert await _datenpunkte(verbindung, b.fall.kennung) == []
    alle_schemata = schemata()
    for ftm, datensatz in erwartet.items():
        punkt = gelesen[ftm]
        assert punkt == geschrieben[ftm]
        assert punkt.fall_kennung == fall
        assert punkt.ftm_schema == datensatz["schema"]
        eigenschaften = datensatz["properties"]
        assert isinstance(eigenschaften, dict)
        assert dict(punkt.eigenschaften) == {
            k: tuple(v) for k, v in eigenschaften.items()
        }
        ist_kante = punkt.ftm_schema in KANTEN
        assert punkt.art is (Datenpunktart.KANTE if ist_kante else Datenpunktart.KNOTEN)
        if ist_kante:
            kf = KANTEN[punkt.ftm_schema]
            assert punkt.quelle_kennung == gelesen[f"synth-q-{schema.lower()}"].kennung
            assert punkt.ziel_kennung == gelesen[f"synth-z-{schema.lower()}"].kennung
            assert punkt.eigenschaften[kf.quelle] == (f"synth-q-{schema.lower()}",)
        else:
            assert punkt.quelle_kennung is None
            assert punkt.ziel_kennung is None
        zurueck = Datensatz.model_validate(
            {
                "id": punkt.ftm_kennung,
                "schema": punkt.ftm_schema,
                "properties": {k: list(v) for k, v in punkt.eigenschaften.items()},
            }
        )
        assert ftm_pruefen(zurueck).name == punkt.ftm_schema
        assert not alle_schemata[punkt.ftm_schema].abstrakt
        assert (alle_schemata[punkt.ftm_schema].kante is not None) is ist_kante

    # Herkunft vollständig lesbar; Invariante der drei Zeitpunkte (DF-S14-05).
    async with verbindung.begin():
        saetze = {
            ftm: await herkunft_lesen(verbindung, fall, p.herkunft_kennung)
            for ftm, p in gelesen.items()
        }
    assert len({p.herkunft_kennung for p in gelesen.values()}) == len(gelesen)
    async with verbindung.begin():
        eintraege = await eintraege_lesen(verbindung, Spur.ERMITTLUNGSSPUR, fall)
    assert len(eintraege) == len(erwartet)
    je_kennung: dict[str, Any] = {}
    for eintrag in eintraege:
        nutzlast = json.loads(eintrag.payload)
        schluesselfeld = (
            "beziehung_kennung"
            if eintrag.eintragstyp.value == "beziehung"
            else "entitaet_kennung"
        )
        je_kennung[nutzlast[schluesselfeld]] = (eintrag, nutzlast)
    for ftm, punkt in gelesen.items():
        satz = saetze[ftm]
        assert satz.kennung == punkt.herkunft_kennung
        assert satz.fall_kennung == fall
        assert satz.werkzeug == WERKZEUG
        assert satz.abfrage == ABFRAGE
        assert satz.zeitpunkt == ERHOBEN
        assert satz.erhebende_person == ERHEBENDE_PERSON
        soll_kennzeichnung = (
            Kennzeichnung.SCHLUSSFOLGERUNG
            if ftm == pruefling
            else Kennzeichnung.QUELLENAUSSAGE
        )
        assert satz.kennzeichnung is soll_kennzeichnung
        eintrag, nutzlast = je_kennung[str(punkt.kennung)]
        assert eintrag.eintragstyp.value == (
            "beziehung" if punkt.art is Datenpunktart.KANTE else "entitaet"
        )
        assert eintrag.kennzeichnung is soll_kennzeichnung
        assert eintrag.person_kennung == PERSON
        assert eintrag.zeitpunkt == punkt.erstellt_am == satz.erstellt_am
        assert punkt.erstellt_am >= JETZT
        assert nutzlast["fall_kennung"] == str(fall)
        assert nutzlast["herkunft_kennung"] == str(punkt.herkunft_kennung)
        assert nutzlast["ftm_schema"] == punkt.ftm_schema
        assert nutzlast["ftm_kennung_pseudonym"] == a.pseudonymisierer.pseudonym(ftm)
        assert nutzlast["eigenschaften"] == {
            k: sorted(a.pseudonymisierer.pseudonym(w) for w in v)
            for k, v in punkt.eigenschaften.items()
        }
        if punkt.art is Datenpunktart.KANTE:
            assert nutzlast["quelle_kennung"] == str(punkt.quelle_kennung)
            assert nutzlast["ziel_kennung"] == str(punkt.ziel_kennung)
        # Herkunft in der Nutzlast (E-S14-02 a, Nachbesserung DF-S14-01).
        assert nutzlast["werkzeug"] == WERKZEUG
        assert nutzlast["erhoben_am"] == _zeit_text(ERHOBEN)
        assert nutzlast["erhebende_person"] == ERHEBENDE_PERSON
        assert nutzlast["abfrage_pseudonym"] == a.pseudonymisierer.pseudonym(ABFRAGE)
        assert nutzlast["abfrage_bindung"] == _bindung(schluessel, ABFRAGE)
        assert nutzlast["abfrage_bindung"] != _bindung(
            schluessel, " ".join(ABFRAGE.split())
        )
        # Kein Klartext des Datensatzes und der Abfrage in der Nutzlast.
        for klartext in (
            ftm,
            ABFRAGE,
            *(w for v in punkt.eigenschaften.values() for w in v),
        ):
            assert klartext.casefold() not in eintrag.payload.casefold()
    await _ketten_unversehrt(
        verbindung, fall, ermittlungsspur=len(erwartet), arbeitsspur=1
    )
    await _ketten_unversehrt(
        verbindung, b.fall.kennung, ermittlungsspur=0, arbeitsspur=1
    )


async def _abweisung_003(
    verbindung: AsyncConnection, name: str, a: _Eroeffnet, b: _Eroeffnet
) -> None:
    """(b): je Abweisungsfall Fehlerklasse oder Datenbankfehler, danach kein Rest, Spur unverändert."""
    fall_a, fall_b = a.fall.kennung, b.fall.kennung
    vorbestand = {
        "synth-p-1": _knoten("Person", "synth-p-1"),
        "synth-p-2": _knoten("Person", "synth-p-2"),
        "synth-c-1": _knoten("Company", "synth-c-1"),
        "synth-k-1": _kante(
            "Ownership", "synth-k-1", owner=["synth-p-1"], asset=["synth-c-1"]
        ),
    }
    for datensatz in vorbestand.values():
        await _schreiben(verbindung, fall_a, datensatz)
    await _schreiben(verbindung, fall_b, _knoten("Person", "synth-p-b"))
    arbeitsspur_a = 1
    if name == "fall_abgeschlossen":
        async with verbindung.begin():
            await schliessen(
                verbindung,
                fall_kennung=fall_a,
                person_kennung=PERSON,
                uhr=_FesteUhr(SCHLIESSEN),
            )
        arbeitsspur_a = 2
    punkte_a = {d.ftm_kennung: d for d in await _datenpunkte(verbindung, fall_a)}
    punkte_b = {d.ftm_kennung: d for d in await _datenpunkte(verbindung, fall_b)}
    vorher = await _stand(verbindung)

    abweisung = ABWEISUNGEN[name]
    if abweisung.fehlerklasse is None:
        # Unmittelbarer Weg der Anwendungsrolle: zusammengesetzter Fremdschlüssel (E-S14-04).
        herkunft_b = _herkunft_zeile(fall_b)
        herkunft_a = _herkunft_zeile(fall_a)
        with pytest.raises(DBAPIError) as info_db:
            async with verbindung.begin():
                if name == "direkt_knoten_herkunft_anderer_fall":
                    await _einfuegen(verbindung, "herkunft", herkunft_b)
                    await _einfuegen(
                        verbindung,
                        "entitaet",
                        _knoten_zeile(fall_a, herkunft_b["kennung"]),
                    )
                elif name == "direkt_kante_herkunft_anderer_fall":
                    await _einfuegen(verbindung, "herkunft", herkunft_b)
                    await _einfuegen(
                        verbindung,
                        "beziehung",
                        _kanten_zeile(
                            fall_a,
                            herkunft_b["kennung"],
                            punkte_a["synth-p-1"].kennung,
                            punkte_a["synth-c-1"].kennung,
                        ),
                    )
                else:
                    await _einfuegen(verbindung, "herkunft", herkunft_a)
                    await _einfuegen(
                        verbindung,
                        "beziehung",
                        _kanten_zeile(
                            fall_a,
                            herkunft_a["kennung"],
                            punkte_a["synth-p-1"].kennung,
                            punkte_b["synth-p-b"].kennung,
                        ),
                    )
        assert _sqlstate(info_db.value) == abweisung.sqlstate
    else:
        datensatz = _abweisender_datensatz(name)
        ziel_fall = uuid4() if name == "unbekannter_fall" else fall_a
        async with verbindung.begin():
            with pytest.raises(R3cosintFehler) as info:
                await schreiben(
                    verbindung,
                    fall_kennung=ziel_fall,
                    datensatz=datensatz,
                    herkunft=_herkunft(),
                    person_kennung=PERSON,
                    uhr=_FesteUhr(),
                )
            # Die Transaktion des Aufrufers bleibt nach der gefangenen Abweisung benutzbar.
            assert (await verbindung.execute(text("SELECT 1"))).scalar_one() == 1
            assert {
                d.ftm_kennung for d in await datenpunkte_lesen(verbindung, fall_a)
            } == set(punkte_a)
        assert type(info.value) is abweisung.fehlerklasse, type(info.value).__name__
        _ohne_klartext_im_fehler(info.value)

    # Kein Teil des Datensatzes im Bestand, Spuren und Kettenköpfe unverändert, kein Eintrag.
    assert await _stand(verbindung) == vorher
    await _ketten_unversehrt(
        verbindung, fall_a, ermittlungsspur=len(vorbestand), arbeitsspur=arbeitsspur_a
    )
    await _ketten_unversehrt(verbindung, fall_b, ermittlungsspur=1, arbeitsspur=1)


@pytest.mark.parametrize("fall_art", FAELLE_003)
async def test_R3_F_003_ftm_schemakonform(
    fall_art: str,
    verbindung_anwendung: AsyncConnection,
    faelle_eroeffnen: FaelleEroeffnen,
    fallschluessel_lesen: SchluesselLesen,
) -> None:
    """R3-F-003_ftm_schemakonform: (a) je Schema des Vorrats ein über kanon.service.schreiben
    geschriebener, schemakonformer Datensatz ist lesbar, dem Fall zugeordnet, validiert gegen die
    versionierten Schemadateien und trägt je Datenpunkt einen Eintrag der Ermittlungsspur bei
    unversehrter Kette; (b) jeder Abweisungsfall endet mit einer Fehlerklasse aus core (auf dem
    unmittelbaren Weg mit einem Fehler der Datenbank) und hinterlässt nichts.
    """
    # Der Vorrat nach E-S14-01 (Bau auf b) ist genau die Liste dieses Tests.
    assert frozenset(KNOTEN) == VORRAT_KNOTEN
    assert frozenset(KANTEN) == VORRAT_KANTEN
    verbindung = verbindung_anwendung
    a, b = await faelle_eroeffnen(2)
    if fall_art.startswith("gegenprobe_"):
        schluessel = await fallschluessel_lesen(a.fall.kennung)
        await _gegenprobe_003(verbindung, fall_art, a, b, schluessel)
    else:
        await _abweisung_003(verbindung, fall_art.removeprefix("abgewiesen_"), a, b)


# ---------------------------------------------------------------------------------------------
# R3-F-005_kein_knoten_ohne_herkunft
# ---------------------------------------------------------------------------------------------

# Weg über kanon: Abbildung der Herkunft mit einer Änderung (Wert _FEHLT entfernt die Angabe).
FORMEN_KANON: dict[str, dict[str, object]] = {
    "fehlt_werkzeug": {"werkzeug": _FEHLT},
    "fehlt_abfrage": {"abfrage": _FEHLT},
    "fehlt_zeitpunkt": {"zeitpunkt": _FEHLT},
    "fehlt_erhebende_person": {"erhebende_person": _FEHLT},
    "fehlt_kennzeichnung": {"kennzeichnung": _FEHLT},
    "fehlt_alles": {
        "werkzeug": _FEHLT,
        "abfrage": _FEHLT,
        "zeitpunkt": _FEHLT,
        "erhebende_person": _FEHLT,
        "kennzeichnung": _FEHLT,
    },
    "leer_werkzeug": {"werkzeug": ""},
    "leer_abfrage": {"abfrage": ""},
    "leer_erhebende_person": {"erhebende_person": ""},
    "leer_kennzeichnung": {"kennzeichnung": ""},
    "ungesetzt_werkzeug": {"werkzeug": None},
    "ungesetzt_zeitpunkt": {"zeitpunkt": None},
    "form_werkzeug": {"werkzeug": "Synth Werkzeug"},
    "form_werkzeug_zu_lang": {"werkzeug": "synth" + "w" * 60},
    "form_abfrage_nur_leerraum": {"abfrage": " \t\n "},
    "form_abfrage_zu_lang": {"abfrage": "SYNTH-" + "a" * 4091},
    "form_abfrage_nul": {"abfrage": "SYNTH-Abfrage\x00mit NUL"},
    "form_abfrage_ersatzzeichen": {"abfrage": "SYNTH-Abfrage \ud800"},
    "form_erhebende_person": {"erhebende_person": "Synth Erhebung"},
    "form_kennzeichnung_ausserhalb": {"kennzeichnung": "synth-vermutung"},
    "form_zeitpunkt_naiv": {"zeitpunkt": datetime(2026, 2, 1, 9, 15)},  # noqa: DTZ001
    "form_zeitpunkt_vor_2000": {"zeitpunkt": datetime(1999, 12, 31, 23, 0, tzinfo=UTC)},
    "form_zeitpunkt_nach_dem_schreiben": {"zeitpunkt": JETZT + timedelta(seconds=1)},
}

# Unmittelbarer Weg: Änderung der Zeile herkunft (Wert _FEHLT lässt die Spalte im INSERT weg).
FORMEN_DIREKT_HERKUNFT: dict[str, tuple[dict[str, object], str]] = {
    "fehlt_werkzeug": ({"werkzeug": _FEHLT}, "23502"),
    "fehlt_abfrage": ({"abfrage": _FEHLT}, "23502"),
    "fehlt_zeitpunkt": ({"zeitpunkt": _FEHLT}, "23502"),
    "fehlt_erhebende_person": ({"erhebende_person": _FEHLT}, "23502"),
    "fehlt_kennzeichnung": ({"kennzeichnung": _FEHLT}, "23502"),
    "leer_werkzeug": ({"werkzeug": ""}, "23514"),
    "leer_abfrage": ({"abfrage": ""}, "23514"),
    "leer_erhebende_person": ({"erhebende_person": ""}, "23514"),
    "leer_kennzeichnung": ({"kennzeichnung": ""}, "23514"),
    "form_werkzeug": ({"werkzeug": "Synth Werkzeug"}, "23514"),
    "form_werkzeug_zu_lang": ({"werkzeug": "synth" + "w" * 60}, "23514"),
    "form_abfrage_nur_leerraum": ({"abfrage": " \t\n "}, "23514"),
    "form_abfrage_zu_lang": ({"abfrage": "SYNTH-" + "a" * 4091}, "23514"),
    "form_erhebende_person": ({"erhebende_person": "Synth Erhebung"}, "23514"),
    "form_kennzeichnung_ausserhalb": ({"kennzeichnung": "synth-vermutung"}, "23514"),
    "form_zeitpunkt_vor_2000": (
        {"zeitpunkt": datetime(1999, 12, 31, 23, 0, tzinfo=UTC)},
        "23514",
    ),
    "form_zeitpunkt_nach_erstellt_am": (
        {"zeitpunkt": JETZT + timedelta(seconds=1)},
        "23514",
    ),
}

# Unmittelbarer Weg am Datenpunkt selbst: kein Verweis, Verweis ins Leere.
FORMEN_DIREKT_VERWEIS: dict[str, str] = {
    "ohne_herkunft_kennung": "23502",
    "verweis_ins_leere": "23503",
}

FAELLE_005 = [
    *(f"kanon_{art}_{form}" for art in ("knoten", "kante") for form in FORMEN_KANON),
    *(
        f"direkt_{art}_{form}"
        for art in ("knoten", "kante")
        for form in (*FORMEN_DIREKT_HERKUNFT, *FORMEN_DIREKT_VERWEIS)
    ),
    "gegenprobe_kanon_knoten",
    "gegenprobe_kanon_kante",
    "gegenprobe_direkt_knoten",
    "gegenprobe_direkt_kante",
]


async def _herkunft_lesbar(
    verbindung: AsyncConnection, fall: UUID, herkunft_kennung: UUID
) -> None:
    async with verbindung.begin():
        satz = await herkunft_lesen(verbindung, fall, herkunft_kennung)
    assert satz.kennung == herkunft_kennung
    assert satz.fall_kennung == fall
    assert satz.werkzeug == WERKZEUG
    assert satz.abfrage == ABFRAGE
    assert satz.zeitpunkt == ERHOBEN
    assert satz.erhebende_person == ERHEBENDE_PERSON
    assert satz.kennzeichnung is Kennzeichnung.QUELLENAUSSAGE


@pytest.mark.parametrize("fall_art", FAELLE_005)
async def test_R3_F_005_kein_knoten_ohne_herkunft(
    fall_art: str,
    verbindung_anwendung: AsyncConnection,
    faelle_eroeffnen: FaelleEroeffnen,
) -> None:
    """R3-F-005_kein_knoten_ohne_herkunft: ein Knoten oder eine Kante ohne vollständigen
    Herkunftsnachweis (Angabe fehlend, leer, ausser Form, Verweis ins Leere) wird über
    kanon.service.schreiben (Fehlerklasse aus core) und unmittelbar als Anwendungsrolle (Fehler
    der Datenbank) abgewiesen; danach nichts aus dem Versuch im Bestand, Spur, Kettenkopf und
    Enden unverändert; mit vollständigem Herkunftsnachweis gelingt das Schreiben.
    """
    verbindung = verbindung_anwendung
    (eroeffnet,) = await faelle_eroeffnen(1)
    fall = eroeffnet.fall.kennung
    # Enden für die Kanten, über den Schreibweg der Anwendung.
    quelle = await _schreiben(verbindung, fall, _knoten("Person", "synth-ende-q"))
    ziel = await _schreiben(verbindung, fall, _knoten("Company", "synth-ende-z"))
    ende_q, ende_z = ["synth-ende-q"], ["synth-ende-z"]
    vorher = await _stand(verbindung)

    weg, art, *rest = fall_art.split("_", 2)
    if weg == "gegenprobe":
        weg, art = art, rest[0]
        if weg == "kanon":
            datensatz = (
                _knoten("Person", "synth-gegenprobe")
                if art == "knoten"
                else _kante("Ownership", "synth-gegenprobe", owner=ende_q, asset=ende_z)
            )
            punkt = await _schreiben(verbindung, fall, datensatz)
            assert punkt.art is (
                Datenpunktart.KNOTEN if art == "knoten" else Datenpunktart.KANTE
            )
            await _herkunft_lesbar(verbindung, fall, punkt.herkunft_kennung)
            await _ketten_unversehrt(verbindung, fall, ermittlungsspur=3, arbeitsspur=1)
        else:
            herkunft = _herkunft_zeile(fall)
            zeile = (
                _knoten_zeile(fall, herkunft["kennung"])
                if art == "knoten"
                else _kanten_zeile(
                    fall, herkunft["kennung"], quelle.kennung, ziel.kennung
                )
            )
            async with verbindung.begin():
                await _einfuegen(verbindung, "herkunft", herkunft)
                await _einfuegen(
                    verbindung, "entitaet" if art == "knoten" else "beziehung", zeile
                )
            herkunft_kennung = herkunft["kennung"]
            assert isinstance(herkunft_kennung, UUID)
            await _herkunft_lesbar(verbindung, fall, herkunft_kennung)
        nachher = await _stand(verbindung)
        tabelle = "entitaet" if art == "knoten" else "beziehung"
        assert len(nachher[tabelle]) == len(vorher[tabelle]) + 1
        assert len(nachher["herkunft"]) == len(vorher["herkunft"]) + 1
        return

    form = rest[0]
    if weg == "kanon":
        herkunft_abbildung = _aendern(_herkunft(), FORMEN_KANON[form])
        datensatz = (
            _knoten("Person", "synth-versuch")
            if art == "knoten"
            else _kante("Ownership", "synth-versuch", owner=ende_q, asset=ende_z)
        )
        async with verbindung.begin():
            with pytest.raises(R3cosintFehler) as info:
                await schreiben(
                    verbindung,
                    fall_kennung=fall,
                    datensatz=datensatz,
                    herkunft=herkunft_abbildung,
                    person_kennung=PERSON,
                    uhr=_FesteUhr(),
                )
            assert (await verbindung.execute(text("SELECT 1"))).scalar_one() == 1
        assert type(info.value) is HerkunftFehler, type(info.value).__name__
        _ohne_klartext_im_fehler(info.value)
    else:
        versuch_herkunft: dict[str, object] | None
        if form in FORMEN_DIREKT_HERKUNFT:
            aenderung, sqlstate = FORMEN_DIREKT_HERKUNFT[form]
            versuch_herkunft = _herkunft_zeile(fall, **aenderung)
            verweis: object = versuch_herkunft["kennung"]
        else:
            sqlstate = FORMEN_DIREKT_VERWEIS[form]
            versuch_herkunft = None
            verweis = _FEHLT if form == "ohne_herkunft_kennung" else uuid4()
        zeile = (
            _knoten_zeile(fall, verweis)
            if art == "knoten"
            else _kanten_zeile(fall, verweis, quelle.kennung, ziel.kennung)
        )
        if verweis is _FEHLT:
            # Ohne Verweis: die Spalte herkunft_kennung fehlt im INSERT (NOT NULL, 23502).
            del zeile["herkunft_kennung"]
        with pytest.raises(DBAPIError) as info_db:
            async with verbindung.begin():
                if versuch_herkunft is not None:
                    await _einfuegen(verbindung, "herkunft", versuch_herkunft)
                await _einfuegen(
                    verbindung, "entitaet" if art == "knoten" else "beziehung", zeile
                )
        assert _sqlstate(info_db.value) == sqlstate

    # Nichts aus dem Versuch im Bestand; Spur, Kettenkopf und Enden unverändert.
    assert await _stand(verbindung) == vorher
    await _ketten_unversehrt(verbindung, fall, ermittlungsspur=2, arbeitsspur=1)


# ---------------------------------------------------------------------------------------------
# R3-F-005_bestand_ohne_herkunftsluecke
# ---------------------------------------------------------------------------------------------


def _null() -> dict[Herkunftsluecke, int]:
    return dict.fromkeys(Herkunftsluecke, 0)


def _befund_pruefen(
    befund: Herkunftsbefund,
    *,
    je_form: Mapping[Herkunftsluecke, int],
    knoten: int,
    kanten: int,
) -> None:
    assert dict(befund.je_form) == dict(je_form), befund
    assert befund.anzahl == sum(je_form.values()), befund
    assert befund.knoten == knoten, befund
    assert befund.kanten == kanten, befund


async def test_R3_F_005_bestand_ohne_herkunftsluecke(
    verbindung_anwendung: AsyncConnection,
    faelle_eroeffnen: FaelleEroeffnen,
    manipulieren: Manipulieren,
) -> None:
    """R3-F-005_bestand_ohne_herkunftsluecke: herkunft_pruefen zählt unter REPEATABLE READ über
    alle Fälle die Datenpunkte ohne vollständigen Herkunftsnachweis je Form; an zwei Fällen mit
    Knoten und Kanten 0; jede eingebrachte Form (verweis_ins_leere an Knoten und Kante,
    anderer_fall, unvollstaendig, mehrfach_verwendet) erhöht Anzahl und Zählwert ihrer Form um
    genau 1, die übrigen bleiben; der leere Bestand ergibt 0 und ist allein kein Nachweis.
    """
    verbindung = verbindung_anwendung

    # Leerer Bestand: überall 0 (allein kein Nachweis).
    _befund_pruefen(
        await _befund_wiederholbar(verbindung), je_form=_null(), knoten=0, kanten=0
    )

    # Zwei Fälle mit je zwei Knoten und einer Kante über kanon.service.schreiben.
    a, b = await faelle_eroeffnen(2)
    punkte: dict[tuple[UUID, str], Datenpunkt] = {}
    for eroeffnet in (a, b):
        fall = eroeffnet.fall.kennung
        for datensatz in (
            _knoten("Person", "synth-p-1"),
            _knoten("Company", "synth-c-1"),
            _kante("Ownership", "synth-k-1", owner=["synth-p-1"], asset=["synth-c-1"]),
        ):
            punkt = await _schreiben(verbindung, fall, datensatz)
            punkte[(fall, punkt.ftm_kennung)] = punkt
    zaehler = _null()
    knoten, kanten = 4, 2
    vorher = await _stand(verbindung)
    _befund_pruefen(
        await _befund_wiederholbar(verbindung),
        je_form=zaehler,
        knoten=knoten,
        kanten=kanten,
    )
    # herkunft_pruefen schreibt nichts.
    assert await _stand(verbindung) == vorher

    fall_a, fall_b = a.fall.kennung, b.fall.kennung
    p_a, c_a = punkte[(fall_a, "synth-p-1")], punkte[(fall_a, "synth-c-1")]
    p_b, c_b = punkte[(fall_b, "synth-p-1")], punkte[(fall_b, "synth-c-1")]

    # verweis_ins_leere am Knoten (Superuser; Fremdschlüssel wirkt unter replica nicht).
    await manipulieren(
        _sql(
            _M_ENTITAET,
            kennung=uuid4(),
            fall=fall_a,
            ftm="synth-leer-1",
            herkunft=uuid4(),
        )
    )
    zaehler[Herkunftsluecke.VERWEIS_INS_LEERE] += 1
    knoten += 1
    _befund_pruefen(
        await _befund_wiederholbar(verbindung),
        je_form=zaehler,
        knoten=knoten,
        kanten=kanten,
    )

    # verweis_ins_leere an der Kante.
    await manipulieren(
        _sql(
            _M_BEZIEHUNG,
            kennung=uuid4(),
            fall=fall_a,
            ftm="synth-leer-2",
            herkunft=uuid4(),
            quelle=p_a.kennung,
            ziel=c_a.kennung,
        )
    )
    zaehler[Herkunftsluecke.VERWEIS_INS_LEERE] += 1
    kanten += 1
    _befund_pruefen(
        await _befund_wiederholbar(verbindung),
        je_form=zaehler,
        knoten=knoten,
        kanten=kanten,
    )

    # anderer_fall: Knoten in Fall A mit einem (sonst unbenutzten) Herkunftssatz des Falls B.
    herkunft_b = uuid4()
    await manipulieren(
        _sql(_M_HERKUNFT, kennung=herkunft_b, fall=fall_b, werkzeug="synth.werkzeug-b")
        + ";"
        + _sql(
            _M_ENTITAET,
            kennung=uuid4(),
            fall=fall_a,
            ftm="synth-fremd-1",
            herkunft=herkunft_b,
        )
    )
    zaehler[Herkunftsluecke.ANDERER_FALL] += 1
    knoten += 1
    _befund_pruefen(
        await _befund_wiederholbar(verbindung),
        je_form=zaehler,
        knoten=knoten,
        kanten=kanten,
    )

    # unvollstaendig: Herkunftssatz mit werkzeug ausserhalb der Form (Prüfbedingung entfernt).
    async with verbindung.begin():
        namen = (
            (
                await verbindung.execute(
                    text(
                        "SELECT c.conname FROM pg_constraint c "
                        "JOIN pg_class cl ON cl.oid = c.conrelid "
                        "JOIN pg_namespace n ON n.oid = cl.relnamespace "
                        "WHERE n.nspname = 'r3cosint' AND cl.relname = 'herkunft' "
                        "AND c.contype = 'c' AND pg_get_constraintdef(c.oid) LIKE '%werkzeug%'"
                    )
                )
            )
            .scalars()
            .all()
        )
    assert len(namen) == 1, namen
    herkunft_u = uuid4()
    await manipulieren(
        _sql(_M_HERKUNFT, kennung=herkunft_u, fall=fall_a, werkzeug="Synth Ungueltig")
        + ";"
        + _sql(
            _M_ENTITAET,
            kennung=uuid4(),
            fall=fall_a,
            ftm="synth-unvoll-1",
            herkunft=herkunft_u,
        ),
        bedingungen_entfernen=(namen[0],),
    )
    zaehler[Herkunftsluecke.UNVOLLSTAENDIG] += 1
    knoten += 1
    _befund_pruefen(
        await _befund_wiederholbar(verbindung),
        je_form=zaehler,
        knoten=knoten,
        kanten=kanten,
    )

    # mehrfach_verwendet als Anwendungsrolle: eine Kante in Fall B verwendet den Herkunftssatz
    # eines Knotens desselben Falls (über die Tabellen hinweg, GS-38); gezählt wird die Kante.
    async with verbindung.begin():
        await _einfuegen(
            verbindung,
            "beziehung",
            _kanten_zeile(fall_b, p_b.herkunft_kennung, p_b.kennung, c_b.kennung),
        )
    zaehler[Herkunftsluecke.MEHRFACH_VERWENDET] += 1
    kanten += 1
    _befund_pruefen(
        await _befund_wiederholbar(verbindung),
        je_form=zaehler,
        knoten=knoten,
        kanten=kanten,
    )
    assert zaehler == {
        Herkunftsluecke.VERWEIS_INS_LEERE: 2,
        Herkunftsluecke.ANDERER_FALL: 1,
        Herkunftsluecke.UNVOLLSTAENDIG: 1,
        Herkunftsluecke.MEHRFACH_VERWENDET: 1,
    }
