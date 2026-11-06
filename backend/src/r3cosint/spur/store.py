"""Lesen und Anfügen der Spuren (ADR 0007, Nr. 1, 13 und 21; Festlegung S1.2; R3-F-008).

Allein insert, select und update von SQLAlchemy Core mit Bindeparametern über spur.tables,
je mit der AsyncConnection des Aufrufers; die Transaktionsklammer setzt der Aufrufer, hier
gibt es kein commit. Kein delete, kein truncate. Das Modul ist nur über spur.service öffentlich.
"""

from typing import Any
from uuid import UUID

from sqlalchemy import (
    Boolean,
    Integer,
    Row,
    Table,
    Text,
    column,
    func,
    insert,
    select,
    union,
    update,
)
from sqlalchemy.ext.asyncio import AsyncConnection

from r3cosint.spur.kette import (
    Befund,
    Bruchgrund,
    Eintrag,
    Eintragstyp,
    Kennzeichnung,
    Kettenkopf,
    Spur,
)
from r3cosint.spur.tables import arbeitsspur, ermittlungsspur, kettenkopf

_TABELLE: dict[Spur, Table] = {
    Spur.ERMITTLUNGSSPUR: ermittlungsspur,
    Spur.ARBEITSSPUR: arbeitsspur,
}


def _kopf(zeile: Row[Any, Any, Any, Any]) -> Kettenkopf:
    return Kettenkopf(
        spur=Spur(zeile.spur),
        fall_kennung=zeile.fall_kennung,
        position=zeile.position,
        pruefsumme=zeile.pruefsumme,
    )


async def kopf_anlegen(verbindung: AsyncConnection, kopf: Kettenkopf) -> None:
    """Fügt einen Kettenkopf ein (INSERT); Position 0 und Anfangswert prüft die Datenbank."""
    await verbindung.execute(
        insert(kettenkopf).values(
            fall_kennung=kopf.fall_kennung,
            spur=kopf.spur.value,
            position=kopf.position,
            pruefsumme=kopf.pruefsumme,
        )
    )


async def _kopf_lesen(
    verbindung: AsyncConnection, spur: Spur, fall_kennung: UUID, *, sperre: str
) -> Kettenkopf | None:
    anweisung = select(
        kettenkopf.c.spur,
        kettenkopf.c.fall_kennung,
        kettenkopf.c.position,
        kettenkopf.c.pruefsumme,
    ).where(kettenkopf.c.fall_kennung == fall_kennung, kettenkopf.c.spur == spur.value)
    anweisung = (
        anweisung.with_for_update()
        if sperre == "update"
        else anweisung.with_for_update(read=True)
    )
    zeile = (await verbindung.execute(anweisung)).one_or_none()
    return None if zeile is None else _kopf(zeile)


async def kopf_sperren(
    verbindung: AsyncConnection, spur: Spur, fall_kennung: UUID
) -> Kettenkopf | None:
    """Liest den Kettenkopf mit SELECT ... FOR UPDATE; None, wenn er fehlt."""
    return await _kopf_lesen(verbindung, spur, fall_kennung, sperre="update")


async def kopf_teilen(
    verbindung: AsyncConnection, spur: Spur, fall_kennung: UUID
) -> Kettenkopf | None:
    """Liest den Kettenkopf mit SELECT ... FOR SHARE; None, wenn er fehlt."""
    return await _kopf_lesen(verbindung, spur, fall_kennung, sperre="share")


async def eintrag_einfuegen(verbindung: AsyncConnection, eintrag: Eintrag) -> None:
    """Fügt einen Eintrag in die Tabelle seiner Spur ein (INSERT)."""
    await verbindung.execute(
        insert(_TABELLE[eintrag.spur]).values(
            kennung=eintrag.kennung,
            fall_kennung=eintrag.fall_kennung,
            position=eintrag.position,
            zeitpunkt=eintrag.zeitpunkt,
            person_kennung=eintrag.person_kennung,
            eintragstyp=eintrag.eintragstyp.value,
            kennzeichnung=eintrag.kennzeichnung.value,
            payload=eintrag.payload,
            vorgaenger_pruefsumme=eintrag.vorgaenger_pruefsumme,
            pruefsumme=eintrag.pruefsumme,
        )
    )


async def kopf_fortschreiben(verbindung: AsyncConnection, kopf: Kettenkopf) -> None:
    """Schreibt Position und Prüfsumme des Kettenkopfs fort (UPDATE)."""
    await verbindung.execute(
        update(kettenkopf)
        .where(
            kettenkopf.c.fall_kennung == kopf.fall_kennung,
            kettenkopf.c.spur == kopf.spur.value,
        )
        .values(position=kopf.position, pruefsumme=kopf.pruefsumme)
    )


async def eintraege_lesen(
    verbindung: AsyncConnection, spur: Spur, fall_kennung: UUID
) -> list[Eintrag]:
    """Liest alle Einträge einer Kette, nach position und kennung aufsteigend."""
    tabelle = _TABELLE[spur]
    ergebnis = await verbindung.execute(
        select(
            tabelle.c.kennung,
            tabelle.c.fall_kennung,
            tabelle.c.position,
            tabelle.c.zeitpunkt,
            tabelle.c.person_kennung,
            tabelle.c.eintragstyp,
            tabelle.c.kennzeichnung,
            tabelle.c.payload,
            tabelle.c.vorgaenger_pruefsumme,
            tabelle.c.pruefsumme,
        )
        .where(tabelle.c.fall_kennung == fall_kennung)
        .order_by(tabelle.c.position, tabelle.c.kennung)
    )
    return [
        Eintrag(
            spur=spur,
            kennung=zeile.kennung,
            fall_kennung=zeile.fall_kennung,
            position=zeile.position,
            zeitpunkt=zeile.zeitpunkt,
            person_kennung=zeile.person_kennung,
            eintragstyp=Eintragstyp(zeile.eintragstyp),
            kennzeichnung=Kennzeichnung(zeile.kennzeichnung),
            payload=zeile.payload,
            vorgaenger_pruefsumme=zeile.vorgaenger_pruefsumme,
            pruefsumme=zeile.pruefsumme,
        )
        for zeile in ergebnis
    ]


async def faelle_lesen(verbindung: AsyncConnection) -> list[UUID]:
    """Fallkennungen aus Kettenkopf und beiden Spuren (Vereinigung), sortiert.

    spur liest die Tabelle fall nicht.
    """
    vereinigung = union(
        select(kettenkopf.c.fall_kennung),
        select(ermittlungsspur.c.fall_kennung),
        select(arbeitsspur.c.fall_kennung),
    ).subquery()
    ergebnis = await verbindung.execute(
        select(vereinigung.c.fall_kennung).order_by(vereinigung.c.fall_kennung)
    )
    return [zeile.fall_kennung for zeile in ergebnis]


async def kette_in_datenbank_pruefen(
    verbindung: AsyncConnection, spur: Spur, fall_kennung: UUID
) -> Befund:
    """Ruft r3cosint.spur_kette_pruefen auf (zweiter Rechenweg, Nr. 20) und bildet den Befund."""
    funktion = func.r3cosint.spur_kette_pruefen(spur.value, fall_kennung).table_valued(
        column("o_unversehrt", Boolean),
        column("o_anzahl", Integer),
        column("o_position", Integer),
        column("o_grund", Text),
        column("o_letzte_pruefsumme", Text),
        column("o_kopf_position", Integer),
    )
    zeile = (await verbindung.execute(select(funktion))).one()
    return Befund(
        spur=spur,
        fall_kennung=fall_kennung,
        unversehrt=zeile.o_unversehrt,
        anzahl=zeile.o_anzahl,
        position=zeile.o_position,
        grund=None if zeile.o_grund is None else Bruchgrund(zeile.o_grund),
        letzte_pruefsumme=zeile.o_letzte_pruefsumme,
        kopf_position=zeile.o_kopf_position,
    )
