"""Lesen und Schreiben der drei Falltabellen (ADR 0007, Festlegung S1.3; R3-F-001).

Alle Funktionen laufen mit der AsyncConnection des Aufrufers, ohne eigene Transaktion und
ohne commit; allein insert, select und update von SQLAlchemy Core mit Bindeparametern über
fall.tables. Das Modul ist nur über fall.service öffentlich (Vertrag 8: kein Modul ausser fall
importiert es). Kein delete, kein truncate.

Die Abweisungswege der beiden Einfügungen lösen die Ausnahme nach dem except-Block aus: im
DETAIL-Text eines IntegrityError stehen die Werte der Zeile (Aktenzeichen, Rechtsgrundlage,
Schlüsselbytes); mit __cause__ und __context__ gleich None gelangt er in keinen Fehlertext.
"""

from datetime import datetime
from typing import Any
from uuid import UUID

from sqlalchemy import insert, select, update
from sqlalchemy.exc import IntegrityError
from sqlalchemy.ext.asyncio import AsyncConnection

from r3cosint.core.fehler import EindeutigkeitsFehler, EingabeFehler, R3cosintFehler
from r3cosint.fall.eingabe import Eroeffnung, Fall, Fallzustand, Rechtsregime
from r3cosint.fall.tables import fall, fall_schluessel, fallkategorie

_EINDEUTIGKEIT_SQLSTATE = "23505"
_EINDEUTIGKEIT_BEDINGUNG = "fall_aktenzeichen_eindeutig"

_FALL_SPALTEN = (
    fall.c.kennung,
    fall.c.rechtsregime,
    fall.c.fallkategorie,
    fall.c.zustand,
    fall.c.eroeffnet_am,
    fall.c.geschlossen_am,
    fall.c.prueffrist_bis,
)


def _fall(zeile: Any) -> Fall:
    return Fall(
        kennung=zeile.kennung,
        rechtsregime=Rechtsregime(zeile.rechtsregime),
        fallkategorie=zeile.fallkategorie,
        zustand=Fallzustand(zeile.zustand),
        eroeffnet_am=zeile.eroeffnet_am,
        geschlossen_am=zeile.geschlossen_am,
        prueffrist_bis=zeile.prueffrist_bis,
    )


async def fallkategorie_lesen(verbindung: AsyncConnection, kennung: str) -> int | None:
    """Liest erste_pruefung_monate der Fallkategorie.

    Parameter: kennung der Fallkategorie. Rückgabe: Monate, None wenn die Kategorie fehlt.
    Fehlerklassen: keine eigenen. Transaktionspflicht: keine (nur lesend).
    """
    ergebnis = await verbindung.execute(
        select(fallkategorie.c.erste_pruefung_monate).where(
            fallkategorie.c.kennung == kennung
        )
    )
    monate = ergebnis.scalar_one_or_none()
    return None if monate is None else int(monate)


def _bedingung_nennen(fehler: IntegrityError) -> tuple[str | None, str | None]:
    """SQLSTATE am DBAPI-Fehler und Name der Bedingung an dessen Ursache.

    Der Adapter von SQLAlchemy für asyncpg setzt an orig allein sqlstate und hängt den
    Fehler des Treibers als Ursache an; beide Attribute werden mit getattr gelesen, damit
    asyncpg nicht importiert wird (Vertrag 10).
    """
    orig = fehler.orig
    sqlstate = getattr(orig, "sqlstate", None)
    ursache = getattr(orig, "__cause__", None)
    name = getattr(ursache, "constraint_name", None)
    return (
        sqlstate if isinstance(sqlstate, str) else None,
        name if isinstance(name, str) else None,
    )


async def fall_einfuegen(
    verbindung: AsyncConnection,
    *,
    kennung: UUID,
    eroeffnung: Eroeffnung,
    eroeffnet_am: datetime,
) -> None:
    """Fügt die Fallzeile ein (zustand aktiv, geschlossen_am und prueffrist_bis NULL).

    Parameter: kennung des neuen Falls; die fertige Eroeffnung; eroeffnet_am in UTC.
    Rückgabe: keine. Fehlerklassen: EindeutigkeitsFehler bei SQLSTATE 23505 am Index
    fall_aktenzeichen_eindeutig; EingabeFehler bei jedem anderen IntegrityError. Beide werden
    nach dem except-Block ausgelöst, damit weder __cause__ noch __context__ den DETAIL-Text
    mit den Werten der Zeile trägt. Transaktionspflicht: läuft in der Transaktion des
    Aufrufers, ohne commit.
    """
    abweisung: R3cosintFehler | None = None
    try:
        await verbindung.execute(
            insert(fall).values(
                kennung=kennung,
                aktenzeichen=eroeffnung.aktenzeichen,
                ermittelnde_person=eroeffnung.ermittelnde_person,
                rechtsgrundlage=eroeffnung.rechtsgrundlage,
                rechtsregime=eroeffnung.rechtsregime.value,
                fallkategorie=eroeffnung.fallkategorie,
                zustand=Fallzustand.AKTIV.value,
                eroeffnet_am=eroeffnet_am,
            )
        )
    except IntegrityError as fehler:
        sqlstate, bedingung = _bedingung_nennen(fehler)
        if (
            sqlstate == _EINDEUTIGKEIT_SQLSTATE
            and bedingung == _EINDEUTIGKEIT_BEDINGUNG
        ):
            abweisung = EindeutigkeitsFehler(
                "Das Aktenzeichen ist bereits einem nicht gelöschten Fall zugeordnet."
            )
        else:
            abweisung = EingabeFehler(
                "Der Fall verletzt eine Prüfbedingung der Tabelle fall."
            )
    if abweisung is not None:
        raise abweisung from None


async def schluessel_einfuegen(
    verbindung: AsyncConnection, fall_kennung: UUID, schluessel: bytes
) -> None:
    """Fügt den Fallschlüssel (32 Bytes) ein.

    Parameter: fall_kennung, schluessel. Rückgabe: keine. Fehlerklassen: EingabeFehler bei
    IntegrityError, nach dem except-Block ausgelöst, ohne Werte (der DETAIL-Text einer
    Längenverletzung trüge die Schlüsselbytes). Transaktionspflicht: wie fall_einfuegen,
    ohne commit.
    """
    abweisung: R3cosintFehler | None = None
    try:
        await verbindung.execute(
            insert(fall_schluessel).values(
                fall_kennung=fall_kennung, schluessel=schluessel
            )
        )
    except IntegrityError:
        abweisung = EingabeFehler(
            "Der Fallschlüssel verletzt eine Prüfbedingung der Tabelle fall_schluessel."
        )
    if abweisung is not None:
        raise abweisung from None


async def schluessel_lesen(
    verbindung: AsyncConnection, fall_kennung: UUID
) -> bytes | None:
    """Liest den Fallschlüssel.

    Parameter: fall_kennung. Rückgabe: 32 Bytes, None wenn keine Zeile besteht.
    Fehlerklassen: keine eigenen. Transaktionspflicht: keine (nur lesend).
    """
    ergebnis = await verbindung.execute(
        select(fall_schluessel.c.schluessel).where(
            fall_schluessel.c.fall_kennung == fall_kennung
        )
    )
    wert = ergebnis.scalar_one_or_none()
    return None if wert is None else bytes(wert)


async def fall_lesen(verbindung: AsyncConnection, fall_kennung: UUID) -> Fall | None:
    """Liest einen Fall ohne Schlüssel und ohne Klartext.

    Parameter: fall_kennung. Rückgabe: Fall, None wenn er fehlt. Fehlerklassen: keine
    eigenen. Transaktionspflicht: keine (nur lesend).
    """
    zeile = (
        await verbindung.execute(
            select(*_FALL_SPALTEN).where(fall.c.kennung == fall_kennung)
        )
    ).one_or_none()
    return None if zeile is None else _fall(zeile)


async def fall_sperren(
    verbindung: AsyncConnection, fall_kennung: UUID
) -> tuple[Fall, int] | None:
    """Liest die Fallzeile mit erste_pruefung_monate der Fallkategorie und sperrt sie.

    SELECT mit Join auf fallkategorie, FOR NO KEY UPDATE OF fall (dasselbe Recht wie
    FOR UPDATE; blockiert aber nicht die Prüfung der Fremdschlüssel beim gleichzeitigen
    Anfügen an eine Spur desselben Falls).
    Parameter: fall_kennung. Rückgabe: (Fall, erste_pruefung_monate), None wenn er fehlt.
    Fehlerklassen: keine eigenen. Transaktionspflicht: läuft in der Transaktion des
    Aufrufers; die Sperre gilt bis zu deren Ende.
    """
    zeile = (
        await verbindung.execute(
            select(*_FALL_SPALTEN, fallkategorie.c.erste_pruefung_monate)
            .select_from(
                fall.join(
                    fallkategorie, fall.c.fallkategorie == fallkategorie.c.kennung
                )
            )
            .where(fall.c.kennung == fall_kennung)
            .with_for_update(key_share=True, of=fall)
        )
    ).one_or_none()
    if zeile is None:
        return None
    return _fall(zeile), int(zeile.erste_pruefung_monate)


async def fall_schliessen(
    verbindung: AsyncConnection,
    *,
    fall_kennung: UUID,
    geschlossen_am: datetime,
    prueffrist_bis: datetime,
) -> int:
    """Setzt zustand abgeschlossen, geschlossen_am und prueffrist_bis, nur wo zustand aktiv ist.

    UPDATE ... WHERE kennung = :k AND zustand = 'aktiv'.
    Parameter: fall_kennung, geschlossen_am und prueffrist_bis in UTC.
    Rückgabe: rowcount; 0 heisst abgewiesen. Fehlerklassen: keine eigenen (die Dienstschicht
    wandelt 0 in ZustandsFehler). Transaktionspflicht: in der Transaktion des Aufrufers.
    """
    ergebnis = await verbindung.execute(
        update(fall)
        .where(
            fall.c.kennung == fall_kennung,
            fall.c.zustand == Fallzustand.AKTIV.value,
        )
        .values(
            zustand=Fallzustand.ABGESCHLOSSEN.value,
            geschlossen_am=geschlossen_am,
            prueffrist_bis=prueffrist_bis,
        )
    )
    return int(ergebnis.rowcount)


async def fall_kennungen_lesen(verbindung: AsyncConnection) -> list[UUID]:
    """Liest die Kennungen aller Fälle, sortiert.

    Parameter: keine. Rückgabe: aufsteigend sortierte Liste. Fehlerklassen: keine eigenen.
    Transaktionspflicht: keine (nur lesend).
    """
    ergebnis = await verbindung.execute(select(fall.c.kennung).order_by(fall.c.kennung))
    return list(ergebnis.scalars())


async def fall_teilen(verbindung: AsyncConnection, fall_kennung: UUID) -> Fall | None:
    """Liest die Fallzeile mit geteilter Sperre (SELECT ... FOR SHARE OF fall; Festlegung S1.4, E-S14-05).

    Die geteilte Sperre hält ein gleichzeitiges Schliessen (FOR NO KEY UPDATE) bis zum Ende der
    Transaktion des Aufrufers an; das Spaltenrecht UPDATE der Anwendungsrolle genügt dafür
    (gemessen am 2026-11-09, Messung 1). Parameter: fall_kennung. Rückgabe: Fall oder None, wenn
    der Fall fehlt. Fehlerklassen: keine eigenen. Transaktionspflicht: die Transaktion des
    Aufrufers; die Sperre gilt bis zu ihrem Ende.
    """
    zeile = (
        await verbindung.execute(
            select(*_FALL_SPALTEN)
            .where(fall.c.kennung == fall_kennung)
            .with_for_update(read=True, of=fall)
        )
    ).one_or_none()
    return None if zeile is None else _fall(zeile)
