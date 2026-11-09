"""Öffentliche Schnittstelle von kanon: der einzige Schreibweg in den Bestand (ADR 0007, Festlegung S1.4; R3-F-003, R3-F-005).

Schreiben läuft in der Transaktion des Aufrufers (async with verbindung.begin()); keine
Funktion macht commit. Ohne laufende Transaktion endet jede Funktion mit EingabeFehler.
Alle Prüfungen laufen vor dem ersten Schreiben; geschrieben wird in einem SAVEPOINT, eine
Abweisung nimmt allein den Versuch zurück.
"""

from collections.abc import Mapping
from datetime import UTC, datetime
from uuid import UUID

from pydantic import ValidationError
from sqlalchemy.ext.asyncio import AsyncConnection

from r3cosint.core.fehler import (
    EindeutigkeitsFehler,
    EingabeFehler,
    HerkunftFehler,
    SchemaFehler,
    ZustandsFehler,
)
from r3cosint.core.kennung import benutzerkennung_pruefen, neue_kennung
from r3cosint.core.zeit import Uhr
from r3cosint.fall.eingabe import Fallzustand
from r3cosint.fall.service import fall_teilen, pseudonymisierer_laden
from r3cosint.kanon import store
from r3cosint.kanon.eingabe import (
    Datenpunkt,
    Datenpunktart,
    Datensatz,
    Herkunft,
    Herkunftsbefund,
    Herkunftsluecke,
    Herkunftssatz,
)
from r3cosint.kanon.ftm import VORRAT_KANTEN, VORRAT_KNOTEN, ende_pruefen, pruefen
from r3cosint.spur.payload import Beziehung, Entitaet
from r3cosint.spur.service import Spur, anfuegen

__all__ = [
    "VORRAT_KANTEN",
    "VORRAT_KNOTEN",
    "Datenpunkt",
    "Datenpunktart",
    "Herkunftsbefund",
    "Herkunftsluecke",
    "Herkunftssatz",
    "datenpunkte_lesen",
    "herkunft_lesen",
    "herkunft_pruefen",
    "schreiben",
]


_ALIASSE = frozenset(
    {
        "id",
        "schema",
        "properties",
        "werkzeug",
        "abfrage",
        "zeitpunkt",
        "erhebende_person",
        "kennzeichnung",
    }
)
_UNBEKANNTES_FELD = "unbekanntes Feld"


def _transaktion_verlangen(verbindung: AsyncConnection) -> None:
    """Die Klammer der Transaktion setzt der Aufrufer; ohne sie EingabeFehler."""
    if not verbindung.in_transaction():
        raise EingabeFehler(
            "Der Aufruf verlangt eine offene Transaktion des Aufrufers."
        )


class _FesteZeit:
    """Uhr, die stets denselben Zeitpunkt liefert (DF-S14-05, eine Zeit je Schreibvorgang)."""

    def __init__(self, zeitpunkt: datetime) -> None:
        self._zeitpunkt = zeitpunkt

    def jetzt(self) -> datetime:
        """Liefert den festgehaltenen Zeitpunkt."""
        return self._zeitpunkt


def _jetzt_lesen(uhr: Uhr) -> datetime:
    """Liest die Uhr einmal; zeitbewusst verlangt, nach UTC umgerechnet (sonst EingabeFehler)."""
    zeitpunkt = uhr.jetzt()
    if zeitpunkt.tzinfo is None or zeitpunkt.utcoffset() is None:
        raise EingabeFehler("Der Zeitpunkt der Uhr ist nicht zeitbewusst.")
    try:
        return zeitpunkt.astimezone(UTC)
    except (OverflowError, ValueError):
        raise EingabeFehler(
            "Der Zeitpunkt der Uhr liegt ausserhalb des darstellbaren Bereichs."
        ) from None


def _feld_nennen(fehler: ValidationError) -> str:
    """Nennt das Feld des ersten Fehlers, allein aus der festen Menge der Aliasse (SD-S14-03 a).

    Gelesen wird allein loc[0] ohne input; tiefere Elemente von loc tragen Eigenschaftsnamen
    und Schlüssel des Aufrufers und gelangen nie in einen Text. Die Liste der Fehler wird nicht
    weitergegeben.
    """
    einzelne = fehler.errors(
        include_input=False, include_context=False, include_url=False
    )
    if not einzelne or not einzelne[0]["loc"]:
        return _UNBEKANNTES_FELD
    erstes = einzelne[0]["loc"][0]
    if isinstance(erstes, str) and erstes in _ALIASSE:
        return erstes
    return _UNBEKANNTES_FELD


async def schreiben(
    verbindung: AsyncConnection,
    *,
    fall_kennung: UUID,
    datensatz: Mapping[str, object],
    herkunft: Mapping[str, object],
    person_kennung: str,
    uhr: Uhr,
) -> Datenpunkt:
    """Schreibt einen Knoten oder eine Kante mit Herkunftsnachweis und Eintrag der Ermittlungsspur.

    Ablauf (Festlegung S1.4, Zeile kanon.service): Transaktion verlangen; person_kennung prüfen
    (handelnde Person, getrennt von erhebende_person); Uhr einmal lesen; Datensatz und Herkunft
    aus den Abbildungen bilden; kanon.ftm.pruefen; fall_teilen (geteilte Sperre, nur aktive
    Fälle); bei einer Kante beide Enden im selben Fall suchen und gegen range prüfen; Kennung
    nicht vergeben; Pseudonymisierer laden; im SAVEPOINT Herkunft, Knoten oder Kante und Eintrag
    der Spur ermittlungsspur mit Kennzeichnung der Herkunft anfügen. Alle Prüfungen laufen vor
    dem ersten Schreiben; ein abgewiesener Versuch hinterlässt nichts, die Transaktion des
    Aufrufers bleibt benutzbar. Die Uhr wird einmal gelesen: Zeitpunkt des Eintrags,
    erstellt_am des Herkunftssatzes und erstellt_am des Datenpunkts sind gleich.
    Parameter: fall_kennung; datensatz (Abbildung id, schema, properties); herkunft
    (Abbildung der fünf Angaben); person_kennung (handelnde Person); uhr.
    Rückgabe: der gespeicherte Datenpunkt.
    Fehlerklassen: EingabeFehler (keine Transaktion, Person, Fall oder Ende fehlt),
    SchemaFehler (Datensatz verletzt das Schema), HerkunftFehler (Herkunft fehlt, ist ausser
    Form oder liegt nach dem Schreiben), ZustandsFehler (Fall nicht aktiv),
    EindeutigkeitsFehler (FollowTheMoney-Kennung im Fall vergeben); KonfigurationsFehler aus
    kanon.ftm.pruefen, wenn die Schemadateien nicht geladen werden können; Verbindungs- und
    Sperrfehler der Datenbank bleiben unübersetzt und werden als DBAPIError durchgereicht
    (SQLSTATE 55P03 bei Sperrzeitüberschreitung, 40001 unter REPEATABLE READ).
    Transaktionspflicht: eine offene Transaktion des Aufrufers unter READ COMMITTED (Pflicht des
    Aufrufers): unter REPEATABLE READ endet ein Schreiben nach gleichzeitigem Schliessen des
    Falls mit SQLSTATE 40001, nicht mit ZustandsFehler.
    """
    _transaktion_verlangen(verbindung)
    benutzerkennung_pruefen(person_kennung)
    jetzt = _jetzt_lesen(uhr)
    abweisung: SchemaFehler | HerkunftFehler | None = None
    try:
        satz = Datensatz.model_validate(datensatz)
    except ValidationError as fehler:
        abweisung = SchemaFehler(
            f"Der Datensatz verletzt die Form am Feld {_feld_nennen(fehler)}."
        )
    if abweisung is not None:
        raise abweisung from None
    try:
        angabe = Herkunft.model_validate(herkunft)
    except ValidationError as fehler:
        abweisung = HerkunftFehler(
            f"Die Herkunft verletzt die Form am Feld {_feld_nennen(fehler)}."
        )
    if abweisung is not None:
        raise abweisung from None
    if angabe.zeitpunkt > jetzt:
        raise HerkunftFehler("Der Zeitpunkt der Erhebung liegt nach dem Schreiben.")
    schema = pruefen(satz)
    fall = await fall_teilen(verbindung, fall_kennung)
    if fall.zustand is not Fallzustand.AKTIV:
        raise ZustandsFehler("Der Fall ist nicht aktiv, in ihn wird nicht geschrieben.")
    quelle: UUID | None = None
    ziel: UUID | None = None
    if schema.kante is not None:
        quelle_name, ziel_name = schema.kante
        enden: list[UUID] = []
        for rolle in (quelle_name, ziel_name):
            if rolle not in satz.eigenschaften:
                raise SchemaFehler("Ein Ende der Kante fehlt im Datensatz.")
            gefunden = await store.knoten_suchen(
                verbindung, fall_kennung, satz.eigenschaften[rolle][0]
            )
            if gefunden is None:
                raise EingabeFehler("Ein Ende der Kante besteht im Fall nicht.")
            ende_pruefen(schema, rolle, gefunden[1])
            enden.append(gefunden[0])
        quelle, ziel = enden
    if await store.ftm_kennung_vergeben(verbindung, fall_kennung, satz.ftm_kennung):
        raise EindeutigkeitsFehler(
            "Die FollowTheMoney-Kennung ist im Fall schon vergeben."
        )
    pseudonymisierer = await pseudonymisierer_laden(verbindung, fall_kennung)
    herkunft_kennung = neue_kennung()
    kennung = neue_kennung()
    async with verbindung.begin_nested():
        await store.herkunft_einfuegen(
            verbindung,
            kennung=herkunft_kennung,
            fall_kennung=fall_kennung,
            herkunft=angabe,
            erstellt_am=jetzt,
        )
        eingabe: Entitaet | Beziehung
        if quelle is not None and ziel is not None:
            await store.beziehung_einfuegen(
                verbindung,
                kennung=kennung,
                fall_kennung=fall_kennung,
                datensatz=satz,
                herkunft_kennung=herkunft_kennung,
                quelle_kennung=quelle,
                ziel_kennung=ziel,
                erstellt_am=jetzt,
            )
            eingabe = Beziehung(
                fall_kennung=fall_kennung,
                beziehung_kennung=kennung,
                ftm_kennung=satz.ftm_kennung,
                ftm_schema=satz.ftm_schema,
                herkunft_kennung=herkunft_kennung,
                quelle_kennung=quelle,
                ziel_kennung=ziel,
                eigenschaften=dict(satz.eigenschaften),
                werkzeug=angabe.werkzeug,
                erhoben_am=angabe.zeitpunkt,
                erhebende_person=angabe.erhebende_person,
                abfrage=angabe.abfrage,
            )
        else:
            await store.entitaet_einfuegen(
                verbindung,
                kennung=kennung,
                fall_kennung=fall_kennung,
                datensatz=satz,
                herkunft_kennung=herkunft_kennung,
                erstellt_am=jetzt,
            )
            eingabe = Entitaet(
                fall_kennung=fall_kennung,
                entitaet_kennung=kennung,
                ftm_kennung=satz.ftm_kennung,
                ftm_schema=satz.ftm_schema,
                herkunft_kennung=herkunft_kennung,
                eigenschaften=dict(satz.eigenschaften),
                werkzeug=angabe.werkzeug,
                erhoben_am=angabe.zeitpunkt,
                erhebende_person=angabe.erhebende_person,
                abfrage=angabe.abfrage,
            )
        await anfuegen(
            verbindung,
            spur=Spur.ERMITTLUNGSSPUR,
            fall_kennung=fall_kennung,
            person_kennung=person_kennung,
            kennzeichnung=angabe.kennzeichnung,
            eingabe=eingabe,
            pseudonymisierer=pseudonymisierer,
            uhr=_FesteZeit(jetzt),
        )
    return Datenpunkt(
        kennung=kennung,
        art=Datenpunktart.KANTE if quelle is not None else Datenpunktart.KNOTEN,
        fall_kennung=fall_kennung,
        ftm_schema=satz.ftm_schema,
        herkunft_kennung=herkunft_kennung,
        erstellt_am=jetzt,
        quelle_kennung=quelle,
        ziel_kennung=ziel,
        ftm_kennung=satz.ftm_kennung,
        eigenschaften=dict(satz.eigenschaften),
    )


async def datenpunkte_lesen(
    verbindung: AsyncConnection, fall_kennung: UUID
) -> list[Datenpunkt]:
    """Liest alle Datenpunkte eines Falls, sortiert nach erstellt_am und kennung.

    Parameter: verbindung; fall_kennung. Rückgabe: Liste der Knoten und Kanten des Falls (leer,
    wenn der Fall keine hat oder nicht besteht). Fehlerklassen: keine eigenen. Transaktionspflicht: keine (nur lesend): ohne offene
    Transaktion liest die Funktion in einer eigenen, die sie beendet. Fallgebunden: keine
    fallübergreifende Suche.
    """
    if verbindung.in_transaction():
        return await store.datenpunkte_lesen(verbindung, fall_kennung)
    async with verbindung.begin():
        return await store.datenpunkte_lesen(verbindung, fall_kennung)


async def herkunft_lesen(
    verbindung: AsyncConnection, fall_kennung: UUID, herkunft_kennung: UUID
) -> Herkunftssatz:
    """Liest einen Herkunftssatz des Falls.

    Parameter: verbindung; fall_kennung; herkunft_kennung. Rückgabe: der Herkunftssatz mit allen
    fünf Angaben. Fehlerklassen: EingabeFehler, wenn der Satz im Fall nicht besteht. Transaktionspflicht:
    wie datenpunkte_lesen.
    """
    if verbindung.in_transaction():
        satz = await store.herkunft_lesen(verbindung, fall_kennung, herkunft_kennung)
    else:
        async with verbindung.begin():
            satz = await store.herkunft_lesen(
                verbindung, fall_kennung, herkunft_kennung
            )
    if satz is None:
        raise EingabeFehler("Der Herkunftssatz besteht im Fall nicht.")
    return satz


async def herkunft_pruefen(verbindung: AsyncConnection) -> Herkunftsbefund:
    """Zählt über den ganzen Bestand Knoten und Kanten ohne vollständigen Herkunftsnachweis (Soll 0).

    Vier Formen (verweis_ins_leere, anderer_fall, unvollstaendig, mehrfach_verwendet); je
    Datenpunkt höchstens einmal in anzahl. Schreibt nichts, liefert allein Zählwerte über alle
    Fälle, keine Kennungen (E-S14-10). Der Befund trägt die Isolationsstufe der Transaktion;
    eine Stufe wird nicht abgewiesen. Ein Jahr später belegt die Spur allein Herkunftskennung,
    Werkzeug, Zeitpunkt der Erhebung und erhebende Person, die Tabelle herkunft nicht.
    Fehlerklassen: EingabeFehler ohne Transaktion. Transaktionspflicht: eine Transaktion; für
    einen Nachweis REPEATABLE READ als Pflicht des Aufrufers (ein einziger Stand).
    """
    _transaktion_verlangen(verbindung)
    return await store.luecken_zaehlen(verbindung)
