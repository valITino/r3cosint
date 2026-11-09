"""Lesen und Schreiben der drei Tabellen des Bestands (ADR 0007, Festlegung S1.4; R3-F-003, R3-F-005).

Alle Funktionen laufen mit der AsyncConnection des Aufrufers, ohne eigene Transaktion und
ohne commit; allein insert und select von SQLAlchemy Core mit Bindeparametern über
kanon.tables. Das Modul ist nur über kanon.service öffentlich (Vertrag 5).

Abweisungswege (wie fall.store): IntegrityError und DataError gefangen, SQLSTATE an
fehler.orig, Name der Bedingung an fehler.orig.__cause__ (constraint_name); im except-Block
bleibt allein die Fehlerart, die Ausnahme wird danach ausgelöst (__cause__ und __context__
None), weil das DETAIL von PostgreSQL die Werte der Zeile trägt (DS-S14-01). 23505 an
entitaet_ftm_kennung_eindeutig oder beziehung_ftm_kennung_eindeutig ergibt
EindeutigkeitsFehler; jeder andere IntegrityError und jeder DataError (SQLSTATE-Klasse 22)
ergibt EingabeFehler mit fester sache ohne Wert. OperationalError und InterfaceError bleiben
unübersetzt (Verbindungsfehler tragen keine Zeile).
"""

from collections.abc import Mapping
from datetime import UTC, datetime
from typing import Any
from uuid import UUID

from sqlalchemy import (
    ColumnElement,
    Select,
    and_,
    exists,
    func,
    insert,
    literal_column,
    or_,
    select,
)
from sqlalchemy.exc import DataError, DBAPIError, IntegrityError
from sqlalchemy.ext.asyncio import AsyncConnection
from sqlalchemy.sql import Insert

from r3cosint.core.fehler import EindeutigkeitsFehler, EingabeFehler, R3cosintFehler
from r3cosint.kanon.eingabe import (
    Datenpunkt,
    Datenpunktart,
    Datensatz,
    Herkunft,
    Herkunftsbefund,
    Herkunftsluecke,
    Herkunftssatz,
)
from r3cosint.kanon.tables import beziehung, entitaet
from r3cosint.kanon.tables import herkunft as herkunft_tabelle
from r3cosint.spur.service import Kennzeichnung

_EINDEUTIGKEIT_SQLSTATE = "23505"
_EINDEUTIGKEIT_BEDINGUNGEN = frozenset(
    {"entitaet_ftm_kennung_eindeutig", "beziehung_ftm_kennung_eindeutig"}
)
_ZEIT_VON = datetime(2000, 1, 1, tzinfo=UTC)
_ZEIT_BIS = datetime(9999, 1, 1, tzinfo=UTC)
_FORM_KENNUNG = r"^[a-z0-9._-]{1,64}$"
_URSACHEN_TIEFE = 8


def _bedingung_nennen(fehler: IntegrityError) -> tuple[str | None, str | None]:
    """SQLSTATE am DBAPI-Fehler und Name der Bedingung an dessen Ursache (getattr, Vertrag 10)."""
    orig = fehler.orig
    sqlstate = getattr(orig, "sqlstate", None)
    ursache = getattr(orig, "__cause__", None)
    name = getattr(ursache, "constraint_name", None)
    return (
        sqlstate if isinstance(sqlstate, str) else None,
        name if isinstance(name, str) else None,
    )


def _ist_datenfehler(fehler: DBAPIError) -> bool:
    """Gilt ein Fehler des Treibers als nicht darstellbarer Wert (SQLSTATE-Klasse 22 oder Kodierung)?

    PostgreSQL meldet Klasse 22 teils als DataError, teils (etwa 22P02 beim Lesen von JSON mit
    Ersatzzeichen) als allgemeinen DBAPIError mit SQLSTATE an orig. Ein Ersatzzeichen (U+D800) in
    einem Textwert scheitert schon im
    Treiber beim Kodieren; SQLAlchemy reicht das als allgemeinen DBAPIError mit dem DataError des
    Treibers als Ursache weiter (gemessen am gesperrten asyncpg-Stand, SD-S14-03 b). Der Name
    einer Ursache der Kette wird gelesen (höchstens acht Stufen), ohne asyncpg zu importieren (Vertrag 10).
    """
    if isinstance(fehler, DataError):
        return True
    sqlstate = getattr(fehler.orig, "sqlstate", None)
    if isinstance(sqlstate, str) and sqlstate.startswith("22"):
        return True
    if type(fehler) is not DBAPIError:
        return False
    # Die Ursachenkette wird bis zu einer festen Tiefe gelesen (__cause__, sonst __context__).
    glied: BaseException | None = fehler.orig
    for _ in range(_URSACHEN_TIEFE):
        if glied is None:
            return False
        glied = glied.__cause__ or glied.__context__
        if glied is not None and type(glied).__name__ == "DataError":
            return True
    return False


async def _einfuegen(
    verbindung: AsyncConnection, anweisung: Insert, tabelle: str
) -> None:
    """Führt ein INSERT aus und übersetzt Verletzungen; die Ausnahme entsteht nach dem except-Block."""
    abweisung: R3cosintFehler | None = None
    try:
        await verbindung.execute(anweisung)
    except IntegrityError as fehler:
        sqlstate, bedingung = _bedingung_nennen(fehler)
        if (
            sqlstate == _EINDEUTIGKEIT_SQLSTATE
            and bedingung in _EINDEUTIGKEIT_BEDINGUNGEN
        ):
            abweisung = EindeutigkeitsFehler(
                "Die FollowTheMoney-Kennung ist im Fall schon vergeben."
            )
        else:
            abweisung = EingabeFehler(
                f"Der Datenpunkt verletzt eine Bedingung der Tabelle {tabelle}."
            )
    except DBAPIError as fehler:
        if not _ist_datenfehler(fehler):
            raise  # Verbindungsfehler tragen keine Zeile und bleiben unübersetzt
        abweisung = EingabeFehler(
            f"Ein Wert ist für die Tabelle {tabelle} nicht darstellbar."
        )
    if abweisung is not None:
        raise abweisung from None


def _eigenschaften(datensatz: Datensatz) -> dict[str, list[str]]:
    return {name: list(werte) for name, werte in datensatz.eigenschaften.items()}


async def herkunft_einfuegen(
    verbindung: AsyncConnection,
    *,
    kennung: UUID,
    fall_kennung: UUID,
    herkunft: Herkunft,
    erstellt_am: datetime,
) -> None:
    """Fügt einen Herkunftssatz ein.

    Parameter: neue kennung, fall_kennung, herkunft (angeglichen), erstellt_am (Uhr).
    Fehlerklassen: EingabeFehler bei jeder verletzten Bedingung (feste sache ohne Wert).
    Transaktionspflicht: die Transaktion des Aufrufers, im SAVEPOINT von kanon.service.
    """
    await _einfuegen(
        verbindung,
        insert(herkunft_tabelle).values(
            kennung=kennung,
            fall_kennung=fall_kennung,
            werkzeug=herkunft.werkzeug,
            abfrage=herkunft.abfrage,
            zeitpunkt=herkunft.zeitpunkt,
            erhebende_person=herkunft.erhebende_person,
            kennzeichnung=herkunft.kennzeichnung.value,
            erstellt_am=erstellt_am,
        ),
        "herkunft",
    )


async def entitaet_einfuegen(
    verbindung: AsyncConnection,
    *,
    kennung: UUID,
    fall_kennung: UUID,
    datensatz: Datensatz,
    herkunft_kennung: UUID,
    erstellt_am: datetime,
) -> None:
    """Fügt einen Knoten ein.

    Parameter: neue kennung, fall_kennung, datensatz (Schema und Eigenschaften), Kennung des
    Herkunftssatzes, erstellt_am. Fehlerklassen: EindeutigkeitsFehler (23505 an
    entitaet_ftm_kennung_eindeutig), EingabeFehler (jede andere Verletzung). Transaktionspflicht
    wie herkunft_einfuegen.
    """
    await _einfuegen(
        verbindung,
        insert(entitaet).values(
            kennung=kennung,
            fall_kennung=fall_kennung,
            ftm_kennung=datensatz.ftm_kennung,
            schema=datensatz.ftm_schema,
            eigenschaften=_eigenschaften(datensatz),
            herkunft_kennung=herkunft_kennung,
            erstellt_am=erstellt_am,
        ),
        "entitaet",
    )


async def beziehung_einfuegen(
    verbindung: AsyncConnection,
    *,
    kennung: UUID,
    fall_kennung: UUID,
    datensatz: Datensatz,
    herkunft_kennung: UUID,
    quelle_kennung: UUID,
    ziel_kennung: UUID,
    erstellt_am: datetime,
) -> None:
    """Fügt eine Kante ein.

    Parameter wie entitaet_einfuegen, dazu die Kennungen der Enden (Zeilen in entitaet desselben
    Falls). Fehlerklassen: EindeutigkeitsFehler (23505 an beziehung_ftm_kennung_eindeutig),
    EingabeFehler (jede andere Verletzung, auch ein Ende eines anderen Falls). Transaktionspflicht
    wie herkunft_einfuegen.
    """
    await _einfuegen(
        verbindung,
        insert(beziehung).values(
            kennung=kennung,
            fall_kennung=fall_kennung,
            ftm_kennung=datensatz.ftm_kennung,
            schema=datensatz.ftm_schema,
            eigenschaften=_eigenschaften(datensatz),
            herkunft_kennung=herkunft_kennung,
            quelle_kennung=quelle_kennung,
            ziel_kennung=ziel_kennung,
            erstellt_am=erstellt_am,
        ),
        "beziehung",
    )


async def knoten_suchen(
    verbindung: AsyncConnection, fall_kennung: UUID, ftm_kennung: str
) -> tuple[UUID, str] | None:
    """Sucht einen Knoten des Falls über seine FollowTheMoney-Kennung, allein in entitaet.

    Rückgabe: (Kennung, Schemaname) oder None. Fehlerklassen: keine eigenen. Transaktionspflicht:
    keine (nur lesend).
    """
    zeile = (
        await verbindung.execute(
            select(entitaet.c.kennung, entitaet.c.schema).where(
                entitaet.c.fall_kennung == fall_kennung,
                entitaet.c.ftm_kennung == ftm_kennung,
            )
        )
    ).one_or_none()
    return None if zeile is None else (zeile.kennung, zeile.schema)


async def ftm_kennung_vergeben(
    verbindung: AsyncConnection, fall_kennung: UUID, ftm_kennung: str
) -> bool:
    """Prüft, ob die FollowTheMoney-Kennung im Fall schon vergeben ist (entitaet und beziehung).

    Rückgabe: True, wenn vergeben. Fehlerklassen: keine eigenen. Transaktionspflicht: keine.
    """
    for tabelle in (entitaet, beziehung):
        gefunden = await verbindung.execute(
            select(
                exists().where(
                    tabelle.c.fall_kennung == fall_kennung,
                    tabelle.c.ftm_kennung == ftm_kennung,
                )
            )
        )
        if gefunden.scalar_one():
            return True
    return False


def _eigenschaften_lesen(roh: Any) -> Mapping[str, tuple[str, ...]]:
    return {str(name): tuple(werte) for name, werte in dict(roh).items()}


async def datenpunkte_lesen(
    verbindung: AsyncConnection, fall_kennung: UUID
) -> list[Datenpunkt]:
    """Liest alle Knoten und Kanten eines Falls, sortiert nach erstellt_am, kennung.

    Fehlerklassen: keine eigenen. Transaktionspflicht: keine (nur lesend).
    """
    punkte: list[Datenpunkt] = []
    for zeile in await verbindung.execute(
        select(entitaet).where(entitaet.c.fall_kennung == fall_kennung)
    ):
        punkte.append(
            Datenpunkt(
                kennung=zeile.kennung,
                art=Datenpunktart.KNOTEN,
                fall_kennung=zeile.fall_kennung,
                ftm_schema=zeile.schema,
                herkunft_kennung=zeile.herkunft_kennung,
                erstellt_am=zeile.erstellt_am,
                quelle_kennung=None,
                ziel_kennung=None,
                ftm_kennung=zeile.ftm_kennung,
                eigenschaften=_eigenschaften_lesen(zeile.eigenschaften),
            )
        )
    for zeile in await verbindung.execute(
        select(beziehung).where(beziehung.c.fall_kennung == fall_kennung)
    ):
        punkte.append(
            Datenpunkt(
                kennung=zeile.kennung,
                art=Datenpunktart.KANTE,
                fall_kennung=zeile.fall_kennung,
                ftm_schema=zeile.schema,
                herkunft_kennung=zeile.herkunft_kennung,
                erstellt_am=zeile.erstellt_am,
                quelle_kennung=zeile.quelle_kennung,
                ziel_kennung=zeile.ziel_kennung,
                ftm_kennung=zeile.ftm_kennung,
                eigenschaften=_eigenschaften_lesen(zeile.eigenschaften),
            )
        )
    punkte.sort(key=lambda punkt: (punkt.erstellt_am, punkt.kennung))
    return punkte


async def herkunft_lesen(
    verbindung: AsyncConnection, fall_kennung: UUID, herkunft_kennung: UUID
) -> Herkunftssatz | None:
    """Liest einen Herkunftssatz des Falls; None, wenn er im Fall nicht besteht.

    Fehlerklassen: keine eigenen. Transaktionspflicht: keine (nur lesend).
    """
    zeile = (
        await verbindung.execute(
            select(herkunft_tabelle).where(
                herkunft_tabelle.c.fall_kennung == fall_kennung,
                herkunft_tabelle.c.kennung == herkunft_kennung,
            )
        )
    ).one_or_none()
    if zeile is None:
        return None
    return Herkunftssatz(
        kennung=zeile.kennung,
        fall_kennung=zeile.fall_kennung,
        werkzeug=zeile.werkzeug,
        zeitpunkt=zeile.zeitpunkt,
        erhebende_person=zeile.erhebende_person,
        kennzeichnung=Kennzeichnung(zeile.kennzeichnung),
        erstellt_am=zeile.erstellt_am,
        abfrage=zeile.abfrage,
    )


def _zeitbereich(spalte: ColumnElement[datetime]) -> ColumnElement[bool]:
    return and_(func.isfinite(spalte), spalte >= _ZEIT_VON, spalte < _ZEIT_BIS)


def _formregeln_erfuellt() -> ColumnElement[bool]:
    """Die Formregeln der Revision 0005 an einem Herkunftssatz (Spiegel der Prüfbedingungen)."""
    h = herkunft_tabelle.c
    return and_(
        h.werkzeug.op("~")(_FORM_KENNUNG),
        h.abfrage.op("~")(r"\S"),
        func.char_length(h.abfrage) <= 4096,
        h.erhebende_person.op("~")(_FORM_KENNUNG),
        h.kennzeichnung.in_([art.value for art in Kennzeichnung]),
        _zeitbereich(h.zeitpunkt),
        _zeitbereich(h.erstellt_am),
        h.zeitpunkt <= h.erstellt_am,
    )


def _punkte() -> Select[Any]:
    """Alle Datenpunkte mit Rang je Herkunftskennung (entitaet vor beziehung, erstellt_am, kennung)."""
    knoten = select(
        entitaet.c.kennung,
        entitaet.c.fall_kennung,
        entitaet.c.herkunft_kennung,
        entitaet.c.erstellt_am,
        literal_column("0").label("rang"),
    )
    kanten = select(
        beziehung.c.kennung,
        beziehung.c.fall_kennung,
        beziehung.c.herkunft_kennung,
        beziehung.c.erstellt_am,
        literal_column("1").label("rang"),
    )
    alle = knoten.union_all(kanten).subquery("alle")
    return select(
        alle.c.kennung,
        alle.c.fall_kennung,
        alle.c.herkunft_kennung,
        func.row_number()
        .over(
            partition_by=alle.c.herkunft_kennung,
            order_by=(alle.c.rang, alle.c.erstellt_am, alle.c.kennung),
        )
        .label("lauf"),
    )


async def luecken_zaehlen(verbindung: AsyncConnection) -> Herkunftsbefund:
    """Zählt über alle Fälle Datenpunkte ohne vollständigen Herkunftsnachweis je Form.

    Eine Abfrage je Form (FA-S14-07) und eine für die Datenpunkte mit mindestens einer Lücke;
    allein Zählwerte, keine Kennungen (E-S14-10). Fehlerklassen: keine eigenen.
    Transaktionspflicht: keine; für einen Nachweis verlangt kanon.service eine Transaktion mit
    REPEATABLE READ. Der Befund trägt die Isolationsstufe der Transaktion.
    """
    p = _punkte().subquery("p")
    h = herkunft_tabelle.c

    def ohne_satz() -> ColumnElement[bool]:
        return or_(
            p.c.herkunft_kennung.is_(None),
            ~exists().where(h.kennung == p.c.herkunft_kennung),
        )

    def anderer_fall() -> ColumnElement[bool]:
        return exists().where(
            h.kennung == p.c.herkunft_kennung, h.fall_kennung != p.c.fall_kennung
        )

    def unvollstaendig() -> ColumnElement[bool]:
        return exists().where(
            h.kennung == p.c.herkunft_kennung,
            func.coalesce(_formregeln_erfuellt(), False).is_(False),
        )

    def mehrfach() -> ColumnElement[bool]:
        return and_(p.c.herkunft_kennung.is_not(None), p.c.lauf > 1)

    formen: dict[Herkunftsluecke, ColumnElement[bool]] = {
        Herkunftsluecke.VERWEIS_INS_LEERE: ohne_satz(),
        Herkunftsluecke.ANDERER_FALL: anderer_fall(),
        Herkunftsluecke.UNVOLLSTAENDIG: unvollstaendig(),
        Herkunftsluecke.MEHRFACH_VERWENDET: mehrfach(),
    }
    je_form: dict[Herkunftsluecke, int] = {}
    for form, bedingung in formen.items():
        je_form[form] = int(
            (
                await verbindung.execute(
                    select(func.count()).select_from(p).where(bedingung)
                )
            ).scalar_one()
        )
    anzahl = int(
        (
            await verbindung.execute(
                select(func.count()).select_from(p).where(or_(*formen.values()))
            )
        ).scalar_one()
    )
    knoten = int(
        (
            await verbindung.execute(select(func.count()).select_from(entitaet))
        ).scalar_one()
    )
    kanten = int(
        (
            await verbindung.execute(select(func.count()).select_from(beziehung))
        ).scalar_one()
    )
    stufe = (
        await verbindung.execute(select(func.current_setting("transaction_isolation")))
    ).scalar_one()
    return Herkunftsbefund(
        anzahl=anzahl,
        je_form=je_form,
        knoten=knoten,
        kanten=kanten,
        isolationsstufe=str(stufe),
    )
