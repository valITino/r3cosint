"""Öffentliche Schnittstelle von fall (ADR 0007, Festlegung S1.3; R3-F-001).

Eröffnen und Schliessen laufen in der Transaktion des Aufrufers (async with verbindung.begin());
keine Funktion macht commit. Ohne laufende Transaktion endet jede schreibende und prüfende
Funktion mit EingabeFehler. Öffentlich sind ausserdem Eroeffnung, Rechtsregime, Fallzustand
und Fall.

Die Schritte, die schreiben, laufen in einem SAVEPOINT (begin_nested): eine Abweisung nimmt
nur diesen Vorgang zurück, die Transaktion des Aufrufers bleibt benutzbar. Aufrufer, die
ketten_aller_faelle_pruefen als Nachweis verwenden, setzen REPEATABLE READ (Pflicht des
Aufrufers; READ COMMITTED gibt nicht einen einzigen Stand wieder).
"""

import secrets
from dataclasses import replace
from datetime import UTC, datetime
from uuid import UUID

from sqlalchemy.ext.asyncio import AsyncConnection

from r3cosint.core.fehler import EingabeFehler, ZustandsFehler
from r3cosint.core.kennung import benutzerkennung_pruefen, neue_kennung
from r3cosint.core.zeit import Uhr, monate_addieren
from r3cosint.fall import store
from r3cosint.fall.eingabe import Eroeffnung, Fall, Fallzustand, Rechtsregime
from r3cosint.spur.service import (
    Befund,
    FallEroeffnet,
    FallGeschlossen,
    Kennzeichnung,
    Pseudonymisierer,
    Spur,
    anfuegen,
    kette_pruefen,
    ketten_anlegen,
)

__all__ = [
    "Eroeffnung",
    "Fall",
    "Fallzustand",
    "Rechtsregime",
    "eroeffnen",
    "fall_lesen",
    "ketten_aller_faelle_pruefen",
    "pseudonymisierer_laden",
    "schliessen",
]


def _transaktion_verlangen(verbindung: AsyncConnection) -> None:
    """Die Klammer der Transaktion setzt der Aufrufer; ohne sie EingabeFehler."""
    if not verbindung.in_transaction():
        raise EingabeFehler(
            "Der Aufruf verlangt eine offene Transaktion des Aufrufers."
        )


class _FesteZeit:
    """Uhr, die stets denselben Zeitpunkt liefert.

    Hält eroeffnet_am in fall, in der Nutzlast und zeitpunkt des Eintrags gleich.
    """

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


async def eroeffnen(
    verbindung: AsyncConnection,
    *,
    eroeffnung: Eroeffnung,
    person_kennung: str,
    uhr: Uhr,
) -> Fall:
    """Eröffnet einen Fall und schreibt fall_eroeffnet in die Arbeitsspur (Nr. 23, E-S13-11).

    Ablauf: Transaktion verlangen; person_kennung prüfen; uhr.jetzt() einmal (zeitbewusst,
    nach UTC); Fallkategorie prüfen; Fall einfügen; Fallschlüssel (secrets.token_bytes(32),
    nie zurückgegeben) einfügen; Ketten anlegen; Eintrag anfügen (Kennzeichnung
    QUELLENAUSSAGE, _FesteZeit).
    Parameter: eroeffnung (fertig gebildet), person_kennung (handelnde Person, nicht die
    ermittelnde), uhr. Rückgabe: Fall im Zustand aktiv. Fehlerklassen: EingabeFehler (keine
    Transaktion, Kennung, naive Zeit, unbekannte Fallkategorie, Zeit ausserhalb des
    Bereichs); EindeutigkeitsFehler (Aktenzeichen schon vergeben). Jede Abweisung rollt mit
    dem Ende der Klammer des Aufrufers alles zurück. Transaktionspflicht: ja.
    """
    _transaktion_verlangen(verbindung)
    benutzerkennung_pruefen(person_kennung)
    jetzt = _jetzt_lesen(uhr)
    if await store.fallkategorie_lesen(verbindung, eroeffnung.fallkategorie) is None:
        raise EingabeFehler("Die Fallkategorie besteht nicht.")
    kennung = neue_kennung()
    async with verbindung.begin_nested():
        await store.fall_einfuegen(
            verbindung, kennung=kennung, eroeffnung=eroeffnung, eroeffnet_am=jetzt
        )
        schluessel = secrets.token_bytes(32)
        await store.schluessel_einfuegen(verbindung, kennung, schluessel)
        pseudonymisierer = Pseudonymisierer(schluessel)
        del schluessel
        await ketten_anlegen(verbindung, kennung)
        await anfuegen(
            verbindung,
            spur=Spur.ARBEITSSPUR,
            fall_kennung=kennung,
            person_kennung=person_kennung,
            kennzeichnung=Kennzeichnung.QUELLENAUSSAGE,
            eingabe=FallEroeffnet(
                fall_kennung=kennung,
                rechtsregime=eroeffnung.rechtsregime.value,
                fallkategorie=eroeffnung.fallkategorie,
                aktenzeichen=eroeffnung.aktenzeichen,
                rechtsgrundlage=eroeffnung.rechtsgrundlage,
                ermittelnde_person=eroeffnung.ermittelnde_person,
                eroeffnet_am=jetzt,
            ),
            pseudonymisierer=pseudonymisierer,
            uhr=_FesteZeit(jetzt),
        )
    return Fall(
        kennung=kennung,
        rechtsregime=eroeffnung.rechtsregime,
        fallkategorie=eroeffnung.fallkategorie,
        zustand=Fallzustand.AKTIV,
        eroeffnet_am=jetzt,
        geschlossen_am=None,
        prueffrist_bis=None,
    )


async def schliessen(
    verbindung: AsyncConnection,
    *,
    fall_kennung: UUID,
    person_kennung: str,
    uhr: Uhr,
) -> Fall:
    """Schliesst einen aktiven Fall und schreibt fall_geschlossen in die Arbeitsspur (Nr. 23).

    prueffrist_bis ist geschlossen_am plus erste_pruefung_monate der Fallkategorie
    (Kalendermonate, UTC, E-S13-10). Vorgang und Eintrag liegen in derselben Transaktion.
    Parameter: fall_kennung, person_kennung, uhr. Rückgabe: Fall im Zustand abgeschlossen.
    Fehlerklassen: EingabeFehler (keine Transaktion, Kennung, naive Zeit, Fall fehlt, Zeit vor
    der Eröffnung, Fallschlüssel fehlt); ZustandsFehler (Fall nicht aktiv, zweites
    Schliessen). Transaktionspflicht: ja.
    """
    _transaktion_verlangen(verbindung)
    benutzerkennung_pruefen(person_kennung)
    jetzt = _jetzt_lesen(uhr)
    gesperrt = await store.fall_sperren(verbindung, fall_kennung)
    if gesperrt is None:
        raise EingabeFehler("Der Fall besteht nicht.")
    fall, monate = gesperrt
    if fall.zustand is not Fallzustand.AKTIV:
        raise ZustandsFehler(
            "Der Fall ist nicht aktiv und kann nicht geschlossen werden."
        )
    if jetzt < fall.eroeffnet_am:
        raise EingabeFehler(
            "Der Zeitpunkt des Schliessens liegt vor der Eröffnung des Falls."
        )
    frist: datetime | None = None
    try:
        frist = monate_addieren(jetzt, monate)
    except ValueError:
        frist = None
    if frist is None:
        raise EingabeFehler(
            "Die Prüffrist der Fallkategorie liegt ausserhalb des darstellbaren Bereichs."
        )
    async with verbindung.begin_nested():
        geschrieben = await store.fall_schliessen(
            verbindung,
            fall_kennung=fall_kennung,
            geschlossen_am=jetzt,
            prueffrist_bis=frist,
        )
        if geschrieben != 1:
            raise ZustandsFehler(
                "Der Fall ist nicht aktiv und kann nicht geschlossen werden."
            )
        pseudonymisierer = await pseudonymisierer_laden(verbindung, fall_kennung)
        await anfuegen(
            verbindung,
            spur=Spur.ARBEITSSPUR,
            fall_kennung=fall_kennung,
            person_kennung=person_kennung,
            kennzeichnung=Kennzeichnung.QUELLENAUSSAGE,
            eingabe=FallGeschlossen(
                fall_kennung=fall_kennung,
                geschlossen_am=jetzt,
                prueffrist_bis=frist,
                erste_pruefung_monate=monate,
            ),
            pseudonymisierer=pseudonymisierer,
            uhr=_FesteZeit(jetzt),
        )
    return replace(
        fall,
        zustand=Fallzustand.ABGESCHLOSSEN,
        geschlossen_am=jetzt,
        prueffrist_bis=frist,
    )


async def pseudonymisierer_laden(
    verbindung: AsyncConnection, fall_kennung: UUID
) -> Pseudonymisierer:
    """Liefert den Pseudonymisierer des Falls aus fall_schluessel (TA-S1-A-NP-02).

    Parameter: fall_kennung. Rückgabe: Pseudonymisierer (der Schlüssel bleibt im Objekt).
    Fehlerklassen: EingabeFehler, wenn kein Fallschlüssel besteht. Transaktionspflicht:
    keine (nur lesend): ohne offene Transaktion liest die Funktion in einer eigenen, die sie
    beendet, damit die Verbindung nicht in einer unbeabsichtigten Transaktion bleibt.
    """
    if verbindung.in_transaction():
        schluessel = await store.schluessel_lesen(verbindung, fall_kennung)
    else:
        async with verbindung.begin():
            schluessel = await store.schluessel_lesen(verbindung, fall_kennung)
    if schluessel is None:
        raise EingabeFehler("Für diesen Fall besteht kein Fallschlüssel.")
    return Pseudonymisierer(schluessel)


async def fall_lesen(verbindung: AsyncConnection, fall_kennung: UUID) -> Fall:
    """Liest einen Fall ohne Schlüssel und ohne Klartext.

    Parameter: fall_kennung. Rückgabe: Fall. Fehlerklassen: EingabeFehler, wenn der Fall
    fehlt. Transaktionspflicht: keine (nur lesend): ohne offene Transaktion liest die Funktion
    in einer eigenen, die sie beendet, damit die Verbindung nicht in einer unbeabsichtigten
    Transaktion bleibt.
    """
    if verbindung.in_transaction():
        fall = await store.fall_lesen(verbindung, fall_kennung)
    else:
        async with verbindung.begin():
            fall = await store.fall_lesen(verbindung, fall_kennung)
    if fall is None:
        raise EingabeFehler("Der Fall besteht nicht.")
    return fall


async def ketten_aller_faelle_pruefen(verbindung: AsyncConnection) -> list[Befund]:
    """Prüft die Ketten aller Fälle der Tabelle fall (GS-19).

    Ruft je Fall spur.service.kette_pruefen; ein Fall ohne Kettenkopf ergibt kopf_abweichend
    an Position 0. Parameter: keine. Rückgabe: Befunde, sortiert nach Fallkennung und Spur.
    Fehlerklassen: EingabeFehler ohne Transaktion. Transaktionspflicht: ja.
    """
    _transaktion_verlangen(verbindung)
    befunde: list[Befund] = []
    for fall_kennung in await store.fall_kennungen_lesen(verbindung):
        befunde.extend((await kette_pruefen(verbindung, fall_kennung)).values())
    return befunde
