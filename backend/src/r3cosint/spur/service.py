"""Öffentliche Schnittstelle von spur (ADR 0007, Nr. 19, 21 und 27; Festlegung S1.2).

Alle Funktionen laufen in der Transaktion des Aufrufers (async with verbindung.begin()); keine
macht commit. Ohne laufende Transaktion endet Anfügen und Prüfen mit EingabeFehler.
Öffentlich sind ausserdem Spur, Eintragstyp, Kennzeichnung, Bruchgrund, Eintrag, Kettenkopf,
Befund, Pseudonymisierer und die vier Eingaben.
"""

from dataclasses import replace
from uuid import UUID

from sqlalchemy.ext.asyncio import AsyncConnection

from r3cosint.core.fehler import EingabeFehler
from r3cosint.core.kennung import benutzerkennung_pruefen, neue_kennung
from r3cosint.core.zeit import Uhr
from r3cosint.spur import kette, store
from r3cosint.spur.kette import (
    SPUR_JE_EINTRAGSTYP,
    Befund,
    Bruchgrund,
    Eintrag,
    Eintragstyp,
    Kennzeichnung,
    Kettenkopf,
    Spur,
    zeitpunkt_text,
)
from r3cosint.spur.payload import (
    Beziehung,
    Eingabe,
    Entitaet,
    FallEroeffnet,
    FallGeschlossen,
    Pseudonymisierer,
    nutzlast_bilden,
)

_EINTRAGSTYP_JE_EINGABE: dict[type, Eintragstyp] = {
    FallEroeffnet: Eintragstyp.FALL_EROEFFNET,
    FallGeschlossen: Eintragstyp.FALL_GESCHLOSSEN,
    Entitaet: Eintragstyp.ENTITAET,
    Beziehung: Eintragstyp.BEZIEHUNG,
}

__all__ = [
    "Befund",
    "Beziehung",
    "Bruchgrund",
    "Eingabe",
    "Eintrag",
    "Eintragstyp",
    "Entitaet",
    "FallEroeffnet",
    "FallGeschlossen",
    "Kennzeichnung",
    "Kettenkopf",
    "Pseudonymisierer",
    "Spur",
    "alle_ketten_pruefen",
    "anfuegen",
    "kette_pruefen",
    "kette_pruefen_datenbank",
    "ketten_anlegen",
]


def _transaktion_verlangen(verbindung: AsyncConnection) -> None:
    """Die Klammer der Transaktion setzt der Aufrufer (Nr. 1); ohne sie EingabeFehler."""
    if not verbindung.in_transaction():
        raise EingabeFehler(
            "Der Aufruf verlangt eine offene Transaktion des Aufrufers."
        )


async def ketten_anlegen(verbindung: AsyncConnection, fall_kennung: UUID) -> None:
    """Legt je Spur einen Kettenkopf in Position 0 mit dem Anfangswert an (Nr. 13).

    Aufgerufen ab S1.3 von fall.service.eroeffnen, in S1.2 von der Testfixture.
    """
    for spur in sorted(Spur):
        await store.kopf_anlegen(
            verbindung,
            Kettenkopf(
                spur=spur,
                fall_kennung=fall_kennung,
                position=0,
                pruefsumme=kette.anfangswert(spur, fall_kennung),
            ),
        )


async def anfuegen(
    verbindung: AsyncConnection,
    *,
    spur: Spur,
    fall_kennung: UUID,
    person_kennung: str,
    kennzeichnung: Kennzeichnung,
    eingabe: Eingabe,
    pseudonymisierer: Pseudonymisierer,
    uhr: Uhr,
) -> Eintrag:
    """Fügt einen Eintrag an die Kette von spur und fall_kennung an und liefert ihn zurück.

    kennzeichnung hat keinen Vorgabewert (E-S1-08); alle Parameter nach verbindung sind nur
    Schlüsselwörter. Ablauf: Transaktion vorhanden, person_kennung geprüft, Eintragstyp aus der
    Klasse der Eingabe gehört zur Spur, fall_kennung der Eingabe gleich dem Parameter, Kopf mit
    FOR UPDATE gesperrt, Eintrag gebildet (Position, Zeit aus der Uhr, Nutzlast, Vorgänger,
    Prüfsumme), eingefügt, Kopf fortgeschrieben. Kein commit.
    Fehlerfälle: EingabeFehler (keine Transaktion; Form der person_kennung; Eintragstyp passt
    nicht zur Spur; Eingabe ohne Eintragstyp in der Zuordnung; fall_kennung der Eingabe weicht
    ab; Kettenkopf fehlt; Zeitpunkt der Uhr nicht zeitbewusst oder ausserhalb von 2000-01-01
    bis vor 9999-01-01 UTC; Nutzlast nicht bildbar).
    """
    _transaktion_verlangen(verbindung)
    benutzerkennung_pruefen(person_kennung)
    eintragstyp = _EINTRAGSTYP_JE_EINGABE.get(type(eingabe))
    if eintragstyp is None:
        raise EingabeFehler("Die Eingabe hat keinen Eintragstyp.")
    if SPUR_JE_EINTRAGSTYP[eintragstyp] is not spur:
        raise EingabeFehler("Der Eintragstyp der Eingabe gehört nicht zu dieser Spur.")
    if eingabe.fall_kennung != fall_kennung:
        raise EingabeFehler(
            "Die Fallkennung der Eingabe weicht vom Fall des Eintrags ab."
        )
    kopf = await store.kopf_sperren(verbindung, spur, fall_kennung)
    if kopf is None:
        raise EingabeFehler("Für diesen Fall besteht keine Kette dieser Spur.")
    zeitpunkt = uhr.jetzt()
    try:
        zeitpunkt_text(zeitpunkt)
    except ValueError as fehler:
        raise EingabeFehler(
            "Der Zeitpunkt der Uhr ist nicht zeitbewusst oder liegt ausserhalb von "
            "2000-01-01 bis vor 9999-01-01 (UTC)."
        ) from fehler
    try:
        offen = Eintrag(
            spur=spur,
            kennung=neue_kennung(),
            fall_kennung=fall_kennung,
            position=kopf.position + 1,
            zeitpunkt=zeitpunkt,
            person_kennung=person_kennung,
            eintragstyp=eintragstyp,
            kennzeichnung=kennzeichnung,
            payload=nutzlast_bilden(eingabe, pseudonymisierer),
            vorgaenger_pruefsumme=kopf.pruefsumme,
            pruefsumme="",
        )
        eintrag = replace(offen, pruefsumme=kette.pruefsumme(offen))
    except ValueError as fehler:
        raise EingabeFehler(
            "Die Eingabe lässt sich nicht als Nutzlast bilden "
            "(leerer Wert oder Zeitpunkt ausser Bereich)."
        ) from fehler
    await store.eintrag_einfuegen(verbindung, eintrag)
    await store.kopf_fortschreiben(
        verbindung,
        Kettenkopf(
            spur=spur,
            fall_kennung=fall_kennung,
            position=eintrag.position,
            pruefsumme=eintrag.pruefsumme,
        ),
    )
    return eintrag


async def kette_pruefen(
    verbindung: AsyncConnection, fall_kennung: UUID
) -> dict[Spur, Befund]:
    """Prüft beide Ketten eines Falls in der Anwendung (spur.kette.pruefen).

    Je Spur Kopf mit FOR SHARE, dann Einträge lesen; beide Lesungen sehen denselben Stand.
    Verlangt eine Transaktion (sonst EingabeFehler). Ändert nichts und schreibt keinen Eintrag.
    """
    _transaktion_verlangen(verbindung)
    befunde: dict[Spur, Befund] = {}
    for spur in sorted(Spur):
        kopf = await store.kopf_teilen(verbindung, spur, fall_kennung)
        eintraege = await store.eintraege_lesen(verbindung, spur, fall_kennung)
        befunde[spur] = kette.pruefen(spur, fall_kennung, eintraege, kopf)
    return befunde


async def kette_pruefen_datenbank(
    verbindung: AsyncConnection, fall_kennung: UUID
) -> dict[Spur, Befund]:
    """Derselbe Befund über die SQL-Funktion r3cosint.spur_kette_pruefen (zweiter Rechenweg)."""
    _transaktion_verlangen(verbindung)
    for spur in sorted(Spur):
        await store.kopf_teilen(verbindung, spur, fall_kennung)
    return {
        spur: await store.kette_in_datenbank_pruefen(verbindung, spur, fall_kennung)
        for spur in sorted(Spur)
    }


async def alle_ketten_pruefen(verbindung: AsyncConnection) -> list[Befund]:
    """Prüft alle Fälle (faelle_lesen); Befunde sortiert nach fall_kennung und Spur."""
    _transaktion_verlangen(verbindung)
    befunde: list[Befund] = []
    for fall_kennung in await store.faelle_lesen(verbindung):
        befunde.extend((await kette_pruefen(verbindung, fall_kennung)).values())
    return befunde
