"""Integrationstest: Bestand und Herkunft gegen PostgreSQL (ADR 0007, Festlegung S1.4; R3-F-003, R3-F-005).

Geprüft werden fall_teilen (geteilte Sperre), der Schreibweg kanon.service.schreiben mit Spur,
Zeitinvariante und SAVEPOINT, der Nachweis je Datenbankweg unmittelbar an kanon.store (Tests
dürfen store importieren; Vertrag 5 gilt für backend/src), die Rechte der Anwendungsrolle,
herkunft_pruefen je Form und die Isolationsstufe im Befund. Alle Werte sind erfunden (5.15,
DS-S14-05): Text- und Kennungswerte tragen die Marke "synth".
"""

import asyncio
import traceback
from collections.abc import AsyncIterator, Awaitable, Callable
from contextlib import asynccontextmanager
from datetime import UTC, datetime, timedelta, timezone
from typing import TYPE_CHECKING, Any
from uuid import UUID, uuid4

import pytest
from pydantic import ValidationError
from sqlalchemy import text
from sqlalchemy.exc import DBAPIError
from sqlalchemy.ext.asyncio import AsyncConnection

from r3cosint.core.datenbank import engine_erzeugen
from r3cosint.core.fehler import (
    EindeutigkeitsFehler,
    EingabeFehler,
    HerkunftFehler,
    SchemaFehler,
    ZustandsFehler,
)
from r3cosint.fall.service import fall_teilen, schliessen
from r3cosint.kanon import store
from r3cosint.kanon.eingabe import Datenpunkt, Datensatz, Herkunft, Herkunftsluecke
from r3cosint.kanon.service import (
    VORRAT_KANTEN,
    VORRAT_KNOTEN,
    datenpunkte_lesen,
    herkunft_lesen,
    herkunft_pruefen,
    schreiben,
)
from r3cosint.spur.service import Kennzeichnung

if TYPE_CHECKING:
    from conftest import EroeffneterFall, Testdatenbank

pytestmark = pytest.mark.anyio

PERSON = "test.ermittlung"
ERHOBEN = datetime(2026, 2, 1, 9, 15, 0, 250000, tzinfo=UTC)
JETZT = datetime(2026, 2, 2, 10, 0, 0, 500000, tzinfo=UTC)
SENTINEL = "SYNTH-SENTINEL-ABFRAGE-4711"
SENTINEL_WERT = "TEST-SYNTH-SENTINEL-WERT-4711"
Manipulieren = Callable[..., Awaitable[str]]
FaelleEroeffnen = Callable[[int], Awaitable[list["EroeffneterFall"]]]


class _Uhr:
    """Uhr, die je Aufruf um eine Millisekunde fortschreitet."""

    def __init__(self, start: datetime = JETZT) -> None:
        self._start = start
        self._aufrufe = 0

    def jetzt(self) -> datetime:
        wert = self._start + timedelta(milliseconds=self._aufrufe)
        self._aufrufe += 1
        return wert


def _herkunft(
    kennzeichnung: Kennzeichnung = Kennzeichnung.QUELLENAUSSAGE, abfrage: str = SENTINEL
) -> dict[str, object]:
    return {
        "werkzeug": "synth.werkzeug",
        "abfrage": abfrage,
        "zeitpunkt": ERHOBEN,
        "erhebende_person": "synth.erhebung",
        "kennzeichnung": kennzeichnung,
    }


def _knoten(ftm: str, schema: str = "Person") -> dict[str, object]:
    return {
        "id": ftm,
        "schema": schema,
        "properties": {"name": [f"{SENTINEL_WERT} {ftm}"]},
    }


def _kante(ftm: str, quelle: str, ziel: str) -> dict[str, object]:
    return {
        "id": ftm,
        "schema": "Ownership",
        "properties": {"owner": [quelle], "asset": [ziel]},
    }


async def _schreiben(
    verbindung: AsyncConnection,
    fall: UUID,
    datensatz: dict[str, object],
    herkunft: dict[str, object] | None = None,
    uhr: Any = None,
) -> Datenpunkt:
    async with verbindung.begin():
        return await schreiben(
            verbindung,
            fall_kennung=fall,
            datensatz=datensatz,
            herkunft=herkunft if herkunft is not None else _herkunft(),
            person_kennung=PERSON,
            uhr=uhr if uhr is not None else _Uhr(),
        )


@asynccontextmanager
async def _weitere_verbindung(
    datenbank: "Testdatenbank", benutzer: str = "r3cosint_anwendung"
) -> AsyncIterator[AsyncConnection]:
    engine = engine_erzeugen(datenbank.verbindung(benutzer))
    try:
        async with engine.connect() as verbindung:
            yield verbindung
    finally:
        await engine.dispose()


def _sqlstate(fehler: BaseException) -> str | None:
    zustand = getattr(getattr(fehler, "orig", None), "sqlstate", None)
    return zustand if isinstance(zustand, str) else None


def _ohne_sentinel(fehler: BaseException, *sentinels: str) -> None:
    """str, repr, traceback.format_exception, __cause__ und __context__ nennen keinen Wert (DS-S14-01)."""
    kette: list[BaseException] = []
    aktuell: BaseException | None = fehler
    while aktuell is not None and aktuell not in kette:
        kette.append(aktuell)
        aktuell = aktuell.__cause__ or aktuell.__context__
    assert fehler.__cause__ is None
    assert fehler.__context__ is None
    for glied in kette:
        gesamt = str(glied) + repr(glied) + "".join(traceback.format_exception(glied))
        for sentinel in sentinels:
            assert sentinel not in gesamt


async def _befund(verbindung: AsyncConnection, stufe: str = "REPEATABLE READ") -> Any:
    async with verbindung.begin():
        await verbindung.execute(text(f"SET TRANSACTION ISOLATION LEVEL {stufe}"))
        return await herkunft_pruefen(verbindung)


# ---------------------------------------------------------------------------------------------
# fall_teilen (Messung: FOR SHARE OF fall als Anwendungsrolle mit dem Spaltenrecht UPDATE)
# ---------------------------------------------------------------------------------------------


async def test_R3_F_003_fall_teilen_gelingt_als_anwendung_und_schliesst_das_schliessen_aus(
    datenbank: "Testdatenbank", faelle_eroeffnen: FaelleEroeffnen
) -> None:
    (e,) = await faelle_eroeffnen(1)
    fall = e.fall.kennung
    async with _weitere_verbindung(datenbank) as a, _weitere_verbindung(datenbank) as b:
        transaktion = await a.begin()
        gelesen = await fall_teilen(a, fall)
        assert gelesen.kennung == fall
        # Zweiter geteilter Zugriff blockiert nicht.
        async with _weitere_verbindung(datenbank) as c:
            async with c.begin():
                await c.execute(text("SET LOCAL lock_timeout = '2s'"))
                assert (await fall_teilen(c, fall)).kennung == fall
        # Das Schliessen (FOR NO KEY UPDATE) wartet auf die geteilte Sperre.
        e.uhr.zeitpunkt = e.uhr.zeitpunkt + timedelta(days=1)
        with pytest.raises(DBAPIError) as info:
            async with b.begin():
                await b.execute(text("SET LOCAL lock_timeout = '300ms'"))
                await schliessen(b, fall_kennung=fall, person_kennung=PERSON, uhr=e.uhr)
        assert _sqlstate(info.value) == "55P03"
        await transaktion.rollback()
        # Gegenprobe: ohne die geteilte Sperre gelingt das Schliessen.
        async with b.begin():
            geschlossen = await schliessen(
                b, fall_kennung=fall, person_kennung=PERSON, uhr=e.uhr
            )
        assert geschlossen.zustand.value == "abgeschlossen"


async def test_R3_F_003_fall_teilen_fehlender_fall_und_ohne_transaktion(
    verbindung_anwendung: AsyncConnection,
) -> None:
    with pytest.raises(EingabeFehler):
        await fall_teilen(verbindung_anwendung, uuid4())
    async with verbindung_anwendung.begin():
        with pytest.raises(EingabeFehler):
            await fall_teilen(verbindung_anwendung, uuid4())


async def test_R3_F_003_schreiben_wartet_auf_ein_gleichzeitiges_schliessen_und_endet_danach_im_zustandsfehler(
    datenbank: "Testdatenbank",
    faelle_eroeffnen: FaelleEroeffnen,
) -> None:
    (e,) = await faelle_eroeffnen(1)
    fall = e.fall.kennung
    e.uhr.zeitpunkt = e.uhr.zeitpunkt + timedelta(days=1)
    async with (
        _weitere_verbindung(datenbank) as schliesser,
        _weitere_verbindung(datenbank) as schreiber,
    ):
        transaktion = await schliesser.begin()
        await schliessen(
            schliesser, fall_kennung=fall, person_kennung=PERSON, uhr=e.uhr
        )
        with pytest.raises(DBAPIError) as info:
            async with schreiber.begin():
                await schreiber.execute(text("SET LOCAL lock_timeout = '300ms'"))
                await schreiben(
                    schreiber,
                    fall_kennung=fall,
                    datensatz=_knoten("synth-p-1"),
                    herkunft=_herkunft(),
                    person_kennung=PERSON,
                    uhr=_Uhr(),
                )
        assert _sqlstate(info.value) == "55P03"
        await transaktion.commit()
        with pytest.raises(ZustandsFehler):
            async with schreiber.begin():
                await schreiben(
                    schreiber,
                    fall_kennung=fall,
                    datensatz=_knoten("synth-p-1"),
                    herkunft=_herkunft(),
                    person_kennung=PERSON,
                    uhr=_Uhr(),
                )


# ---------------------------------------------------------------------------------------------
# schreiben: Spur, Zeitinvariante, SAVEPOINT
# ---------------------------------------------------------------------------------------------


async def test_R3_F_005_schreiben_je_schema_des_vorrats_mit_spureintrag_und_beiden_kennzeichnungen(
    verbindung_anwendung: AsyncConnection, faelle_eroeffnen: FaelleEroeffnen
) -> None:
    (e,) = await faelle_eroeffnen(1)
    fall = e.fall.kennung
    anzahl = 0
    knoten_ids: dict[str, str] = {}
    for nr, schema in enumerate(sorted(VORRAT_KNOTEN)):
        ftm = f"synth-n-{nr}"
        kennzeichnung = (
            Kennzeichnung.SCHLUSSFOLGERUNG if nr % 2 else Kennzeichnung.QUELLENAUSSAGE
        )
        punkt = await _schreiben(
            verbindung_anwendung,
            fall,
            _knoten(ftm, schema),
            _herkunft(kennzeichnung),
        )
        assert punkt.ftm_schema == schema
        knoten_ids[schema] = ftm
        anzahl += 1
        satz = await herkunft_lesen(verbindung_anwendung, fall, punkt.herkunft_kennung)
        assert satz.kennzeichnung is kennzeichnung
        assert satz.abfrage == SENTINEL
    assert len(VORRAT_KANTEN) == 6
    async with verbindung_anwendung.begin():
        zeilen = (
            await verbindung_anwendung.execute(
                text(
                    "SELECT eintragstyp, kennzeichnung FROM r3cosint.ermittlungsspur "
                    "WHERE fall_kennung = :f ORDER BY position"
                ),
                {"f": fall},
            )
        ).all()
    assert [z[0] for z in zeilen] == ["entitaet"] * anzahl
    assert {z[1] for z in zeilen} == {"quellenaussage", "schlussfolgerung"}
    gelesen = await datenpunkte_lesen(verbindung_anwendung, fall)
    assert len(gelesen) == anzahl
    assert gelesen == sorted(gelesen, key=lambda p: (p.erstellt_am, p.kennung))


async def test_R3_F_005_zeitinvariante_spur_herkunft_und_datenpunkt_tragen_denselben_zeitpunkt_als_text(
    verbindung_anwendung: AsyncConnection, faelle_eroeffnen: FaelleEroeffnen
) -> None:
    (e,) = await faelle_eroeffnen(1)
    fall = e.fall.kennung
    uhr = _Uhr()
    for nr in range(3):
        await _schreiben(verbindung_anwendung, fall, _knoten(f"synth-z-{nr}"), uhr=uhr)
    async with verbindung_anwendung.begin():
        zeilen = (
            await verbindung_anwendung.execute(
                text(
                    "SELECT to_char(s.zeitpunkt AT TIME ZONE 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SS.US'), "
                    "to_char(h.erstellt_am AT TIME ZONE 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SS.US'), "
                    "to_char(e.erstellt_am AT TIME ZONE 'UTC', 'YYYY-MM-DD\"T\"HH24:MI:SS.US'), "
                    "s.payload::jsonb ->> 'erhoben_am' "
                    "FROM r3cosint.ermittlungsspur s "
                    "JOIN r3cosint.entitaet e ON e.kennung = (s.payload::jsonb ->> 'entitaet_kennung')::uuid "
                    "JOIN r3cosint.herkunft h ON h.kennung = e.herkunft_kennung "
                    "WHERE s.fall_kennung = :f ORDER BY s.position"
                ),
                {"f": fall},
            )
        ).all()
    assert len(zeilen) == 3
    assert (
        len({z[0] for z in zeilen}) == 3
    )  # die Uhr schritt fort: drei verschiedene Zeitpunkte
    for spur, herkunft, datenpunkt, erhoben in zeilen:
        assert spur == herkunft == datenpunkt
        assert erhoben == "2026-02-01T09:15:00.250000Z"
        assert erhoben.rstrip("Z") <= spur


async def test_R3_F_005_klartext_steht_in_keiner_spalte_der_spuren_und_des_kettenkopfs(
    verbindung_anwendung: AsyncConnection, faelle_eroeffnen: FaelleEroeffnen
) -> None:
    (e,) = await faelle_eroeffnen(1)
    fall = e.fall.kennung
    await _schreiben(verbindung_anwendung, fall, _knoten("synth-klar-1"))
    await _schreiben(verbindung_anwendung, fall, _knoten("synth-klar-2", "Company"))
    await _schreiben(
        verbindung_anwendung,
        fall,
        _kante("synth-klar-k", "synth-klar-1", "synth-klar-2"),
    )
    async with verbindung_anwendung.begin():
        for tabelle in ("ermittlungsspur", "arbeitsspur", "kettenkopf"):
            zeilen = (
                await verbindung_anwendung.execute(
                    text(f"SELECT t::text FROM r3cosint.{tabelle} t")  # noqa: S608 - feste Namen
                )
            ).scalars()
            gesamt = "\n".join(zeilen)
            for klartext in (SENTINEL, SENTINEL_WERT, "synth-klar", "synth.erhebung"):
                if klartext == "synth.erhebung" and tabelle == "ermittlungsspur":
                    continue  # die erhebende Person steht als Kennung im Klartext (E-S1-07)
                assert klartext not in gesamt, (tabelle, klartext)


async def test_R3_F_005_abgewiesener_zweiter_versuch_in_einer_transaktion_der_erste_besteht(
    verbindung_anwendung: AsyncConnection, faelle_eroeffnen: FaelleEroeffnen
) -> None:
    (e,) = await faelle_eroeffnen(1)
    fall = e.fall.kennung
    async with verbindung_anwendung.begin():
        erster = await schreiben(
            verbindung_anwendung,
            fall_kennung=fall,
            datensatz=_knoten("synth-sp-1"),
            herkunft=_herkunft(),
            person_kennung=PERSON,
            uhr=_Uhr(),
        )
        with pytest.raises(EindeutigkeitsFehler):
            await schreiben(
                verbindung_anwendung,
                fall_kennung=fall,
                datensatz=_knoten("synth-sp-1"),
                herkunft=_herkunft(),
                person_kennung=PERSON,
                uhr=_Uhr(),
            )
        # Abweisung in Schritt (10): Herkunft ungültig am Store vorbei ist nicht möglich; Schema
        # fehlerhaft wird vor dem Schreiben abgewiesen. Beides lässt die Transaktion benutzbar.
        with pytest.raises(SchemaFehler):
            await schreiben(
                verbindung_anwendung,
                fall_kennung=fall,
                datensatz={"id": "synth-sp-2", "schema": "Vehicle", "properties": {}},
                herkunft=_herkunft(),
                person_kennung=PERSON,
                uhr=_Uhr(),
            )
        zweiter = await schreiben(
            verbindung_anwendung,
            fall_kennung=fall,
            datensatz=_knoten("synth-sp-3"),
            herkunft=_herkunft(),
            person_kennung=PERSON,
            uhr=_Uhr(),
        )
    vorhanden = {p.kennung for p in await datenpunkte_lesen(verbindung_anwendung, fall)}
    assert vorhanden == {erster.kennung, zweiter.kennung}


# ---------------------------------------------------------------------------------------------
# Nachweis je Datenbankweg unmittelbar an kanon.store (SD-S14-05)
# ---------------------------------------------------------------------------------------------


async def _grundbestand(
    verbindung: AsyncConnection, fall: UUID
) -> tuple[Datenpunkt, Datenpunkt, Datenpunkt]:
    """Zwei Knoten und eine Kante über schreiben."""
    p = await _schreiben(verbindung, fall, _knoten("synth-g-1"))
    c = await _schreiben(verbindung, fall, _knoten("synth-g-2", "Company"))
    k = await _schreiben(
        verbindung, fall, _kante("synth-g-k", "synth-g-1", "synth-g-2")
    )
    return p, c, k


def _herkunft_modell(**aenderung: object) -> Herkunft:
    werte: dict[str, object] = {
        "werkzeug": "synth.werkzeug",
        "abfrage": SENTINEL,
        "zeitpunkt": ERHOBEN,
        "erhebende_person": "synth.erhebung",
        "kennzeichnung": Kennzeichnung.QUELLENAUSSAGE,
    }
    werte.update(aenderung)
    return Herkunft.model_construct(**werte)  # type: ignore[arg-type]


def _datensatz_modell(ftm: str, **eigenschaften: Any) -> Datensatz:
    return Datensatz.model_construct(
        ftm_kennung=ftm,
        ftm_schema="Person",
        eigenschaften=eigenschaften or {"name": (f"{SENTINEL_WERT} {ftm}",)},
    )


async def _versuch(
    verbindung: AsyncConnection, aufruf: Callable[[], Awaitable[None]]
) -> BaseException:
    """Führt den Aufruf in einem SAVEPOINT aus und gibt die Ausnahme zurück."""
    async with verbindung.begin():
        try:
            async with verbindung.begin_nested():
                await aufruf()
        except BaseException as fehler:  # noqa: BLE001 - Test sammelt die Ausnahme
            return fehler
    raise AssertionError("keine Abweisung")


async def test_R3_F_005_store_23505_an_der_ftm_kennung_ergibt_eindeutigkeitsfehler_je_tabelle(
    verbindung_anwendung: AsyncConnection, faelle_eroeffnen: FaelleEroeffnen
) -> None:
    (e,) = await faelle_eroeffnen(1)
    fall = e.fall.kennung
    p, c, k = await _grundbestand(verbindung_anwendung, fall)

    async def knoten_doppelt() -> None:
        h = uuid4()
        await store.herkunft_einfuegen(
            verbindung_anwendung,
            kennung=h,
            fall_kennung=fall,
            herkunft=_herkunft_modell(),
            erstellt_am=JETZT,
        )
        await store.entitaet_einfuegen(
            verbindung_anwendung,
            kennung=uuid4(),
            fall_kennung=fall,
            datensatz=_datensatz_modell(p.ftm_kennung),
            herkunft_kennung=h,
            erstellt_am=JETZT,
        )

    async def kante_doppelt() -> None:
        h = uuid4()
        await store.herkunft_einfuegen(
            verbindung_anwendung,
            kennung=h,
            fall_kennung=fall,
            herkunft=_herkunft_modell(),
            erstellt_am=JETZT,
        )
        await store.beziehung_einfuegen(
            verbindung_anwendung,
            kennung=uuid4(),
            fall_kennung=fall,
            datensatz=_datensatz_modell(k.ftm_kennung),
            herkunft_kennung=h,
            quelle_kennung=p.kennung,
            ziel_kennung=c.kennung,
            erstellt_am=JETZT,
        )

    for aufruf in (knoten_doppelt, kante_doppelt):
        fehler = await _versuch(verbindung_anwendung, aufruf)
        assert type(fehler) is EindeutigkeitsFehler
        _ohne_sentinel(fehler, SENTINEL, SENTINEL_WERT, "synth-g-")


async def test_R3_F_005_store_23505_am_primaerschluessel_ergibt_eingabefehler_nicht_eindeutigkeitsfehler(
    verbindung_anwendung: AsyncConnection, faelle_eroeffnen: FaelleEroeffnen
) -> None:
    (e,) = await faelle_eroeffnen(1)
    fall = e.fall.kennung
    p, _, _ = await _grundbestand(verbindung_anwendung, fall)

    async def aufruf() -> None:
        h = uuid4()
        await store.herkunft_einfuegen(
            verbindung_anwendung,
            kennung=h,
            fall_kennung=fall,
            herkunft=_herkunft_modell(),
            erstellt_am=JETZT,
        )
        await store.entitaet_einfuegen(
            verbindung_anwendung,
            kennung=p.kennung,  # Primärschlüssel doppelt, FollowTheMoney-Kennung neu
            fall_kennung=fall,
            datensatz=_datensatz_modell("synth-pk-neu"),
            herkunft_kennung=h,
            erstellt_am=JETZT,
        )

    fehler = await _versuch(verbindung_anwendung, aufruf)
    assert type(fehler) is EingabeFehler
    _ohne_sentinel(fehler, SENTINEL, SENTINEL_WERT)


async def test_R3_F_005_store_23505_an_der_herkunft_kennung_je_tabelle_ergibt_eingabefehler(
    verbindung_anwendung: AsyncConnection, faelle_eroeffnen: FaelleEroeffnen
) -> None:
    (e,) = await faelle_eroeffnen(1)
    fall = e.fall.kennung
    p, c, k = await _grundbestand(verbindung_anwendung, fall)

    async def knoten() -> None:
        await store.entitaet_einfuegen(
            verbindung_anwendung,
            kennung=uuid4(),
            fall_kennung=fall,
            datensatz=_datensatz_modell("synth-h-neu-1"),
            herkunft_kennung=p.herkunft_kennung,
            erstellt_am=JETZT,
        )

    async def kante() -> None:
        await store.beziehung_einfuegen(
            verbindung_anwendung,
            kennung=uuid4(),
            fall_kennung=fall,
            datensatz=_datensatz_modell("synth-h-neu-2"),
            herkunft_kennung=k.herkunft_kennung,
            quelle_kennung=p.kennung,
            ziel_kennung=c.kennung,
            erstellt_am=JETZT,
        )

    for aufruf in (knoten, kante):
        fehler = await _versuch(verbindung_anwendung, aufruf)
        assert type(fehler) is EingabeFehler
        _ohne_sentinel(fehler, SENTINEL, SENTINEL_WERT)


FORMREGELN: dict[str, dict[str, object]] = {
    "werkzeug": {"werkzeug": "Synth Ungueltig"},
    "abfrage_leer": {"abfrage": "   "},
    "abfrage_zu_lang": {"abfrage": SENTINEL + "a" * 4096},
    "erhebende_person": {"erhebende_person": "Synth Person"},
    "kennzeichnung": {"kennzeichnung": "vermutung"},
    "zeitbereich_zeitpunkt": {"zeitpunkt": datetime(1999, 1, 1, tzinfo=UTC)},
    "zeitpunkt_nach_erstellt_am": {"zeitpunkt": JETZT + timedelta(days=1)},
}


@pytest.mark.parametrize("regel", list(FORMREGELN))
async def test_R3_F_005_store_23514_je_formregel_ergibt_eingabefehler_ohne_klartext(
    verbindung_anwendung: AsyncConnection, faelle_eroeffnen: FaelleEroeffnen, regel: str
) -> None:
    (e,) = await faelle_eroeffnen(1)
    fall = e.fall.kennung
    kennzeichnung = FORMREGELN[regel].get("kennzeichnung")
    aenderung = dict(FORMREGELN[regel])
    if kennzeichnung is not None:
        aenderung["kennzeichnung"] = (
            kennzeichnung  # Zeichenkette ausserhalb des Vorrats
        )

    async def aufruf() -> None:
        await store.herkunft_einfuegen(
            verbindung_anwendung,
            kennung=uuid4(),
            fall_kennung=fall,
            herkunft=_herkunft_modell(**aenderung),
            erstellt_am=JETZT,
        )

    # Die Zeichenkette für kennzeichnung hat kein .value: ein Hilfsobjekt liefert es.
    if kennzeichnung is not None:

        class _Roh:
            value = "vermutung"

        aenderung["kennzeichnung"] = _Roh()
    fehler = await _versuch(verbindung_anwendung, aufruf)
    assert type(fehler) is EingabeFehler
    _ohne_sentinel(fehler, SENTINEL)


async def test_R3_F_005_store_23514_am_gesamtgroesse_und_form_der_ftm_kennung_je_tabelle(
    verbindung_anwendung: AsyncConnection, faelle_eroeffnen: FaelleEroeffnen
) -> None:
    (e,) = await faelle_eroeffnen(1)
    fall = e.fall.kennung
    p, c, _ = await _grundbestand(verbindung_anwendung, fall)
    faelle = [
        _datensatz_modell(
            "synth-gross", name=("x" * 4000,) * 300
        ),  # über 1 MiB als Text
        _datensatz_modell("ungültig mit Leerzeichen"),
    ]
    for datensatz in faelle:

        async def knoten(d: Datensatz = datensatz) -> None:
            h = uuid4()
            await store.herkunft_einfuegen(
                verbindung_anwendung,
                kennung=h,
                fall_kennung=fall,
                herkunft=_herkunft_modell(),
                erstellt_am=JETZT,
            )
            await store.entitaet_einfuegen(
                verbindung_anwendung,
                kennung=uuid4(),
                fall_kennung=fall,
                datensatz=d,
                herkunft_kennung=h,
                erstellt_am=JETZT,
            )

        async def kante(d: Datensatz = datensatz) -> None:
            h = uuid4()
            await store.herkunft_einfuegen(
                verbindung_anwendung,
                kennung=h,
                fall_kennung=fall,
                herkunft=_herkunft_modell(),
                erstellt_am=JETZT,
            )
            await store.beziehung_einfuegen(
                verbindung_anwendung,
                kennung=uuid4(),
                fall_kennung=fall,
                datensatz=d,
                herkunft_kennung=h,
                quelle_kennung=p.kennung,
                ziel_kennung=c.kennung,
                erstellt_am=JETZT,
            )

        for aufruf in (knoten, kante):
            fehler = await _versuch(verbindung_anwendung, aufruf)
            assert type(fehler) is EingabeFehler
            _ohne_sentinel(fehler, SENTINEL, SENTINEL_WERT, "ungültig")


async def test_R3_F_005_store_23502_und_23503_je_fall_ergeben_eingabefehler(
    verbindung_anwendung: AsyncConnection, faelle_eroeffnen: FaelleEroeffnen
) -> None:
    a, b = await faelle_eroeffnen(2)
    fall, fremd = a.fall.kennung, b.fall.kennung
    p, c, _ = await _grundbestand(verbindung_anwendung, fall)
    fremd_knoten = await _schreiben(
        verbindung_anwendung, fremd, _knoten("synth-fremd-1")
    )
    fremd_herkunft = fremd_knoten.herkunft_kennung

    async def knoten(herkunft: UUID | None, nr: str) -> None:
        await store.entitaet_einfuegen(
            verbindung_anwendung,
            kennung=uuid4(),
            fall_kennung=fall,
            datensatz=_datensatz_modell(f"synth-v-{nr}"),
            herkunft_kennung=herkunft,  # type: ignore[arg-type]
            erstellt_am=JETZT,
        )

    async def kante(quelle: UUID, ziel: UUID, nr: str) -> None:
        h = uuid4()
        await store.herkunft_einfuegen(
            verbindung_anwendung,
            kennung=h,
            fall_kennung=fall,
            herkunft=_herkunft_modell(),
            erstellt_am=JETZT,
        )
        await store.beziehung_einfuegen(
            verbindung_anwendung,
            kennung=uuid4(),
            fall_kennung=fall,
            datensatz=_datensatz_modell(f"synth-v-{nr}"),
            herkunft_kennung=h,
            quelle_kennung=quelle,
            ziel_kennung=ziel,
            erstellt_am=JETZT,
        )

    versuche: list[Callable[[], Awaitable[None]]] = [
        lambda: knoten(None, "null"),  # 23502
        lambda: knoten(uuid4(), "leer"),  # 23503 Herkunft ins Leere
        lambda: knoten(fremd_herkunft, "fremd"),  # 23503 Herkunft eines anderen Falls
        lambda: kante(uuid4(), c.kennung, "ende-leer"),  # 23503 Ende ins Leere
        lambda: kante(
            p.kennung, fremd_knoten.kennung, "ende-fremd"
        ),  # 23503 Ende anderer Fall
    ]
    for aufruf in versuche:
        fehler = await _versuch(verbindung_anwendung, aufruf)
        assert type(fehler) is EingabeFehler
        _ohne_sentinel(fehler, SENTINEL, SENTINEL_WERT, "synth-v-")


async def test_R3_F_005_store_datenfehler_mit_ersatzzeichen_in_wert_und_abfrage_ergibt_eingabefehler(
    verbindung_anwendung: AsyncConnection, faelle_eroeffnen: FaelleEroeffnen
) -> None:
    """Messung SD-S14-03 b: Verhalten des Treibers bei U+D800, am Store vorbei an der Eingabeklasse."""
    (e,) = await faelle_eroeffnen(1)
    fall = e.fall.kennung
    ersatz = "\ud800"

    async def abfrage() -> None:
        await store.herkunft_einfuegen(
            verbindung_anwendung,
            kennung=uuid4(),
            fall_kennung=fall,
            herkunft=_herkunft_modell(abfrage=f"{SENTINEL} {ersatz}"),
            erstellt_am=JETZT,
        )

    async def wert() -> None:
        h = uuid4()
        await store.herkunft_einfuegen(
            verbindung_anwendung,
            kennung=h,
            fall_kennung=fall,
            herkunft=_herkunft_modell(),
            erstellt_am=JETZT,
        )
        await store.entitaet_einfuegen(
            verbindung_anwendung,
            kennung=uuid4(),
            fall_kennung=fall,
            datensatz=_datensatz_modell(
                "synth-ers", name=(f"{SENTINEL_WERT} {ersatz}",)
            ),
            herkunft_kennung=h,
            erstellt_am=JETZT,
        )

    for aufruf in (abfrage, wert):
        fehler = await _versuch(verbindung_anwendung, aufruf)
        assert type(fehler) is EingabeFehler, type(fehler).__name__
        _ohne_sentinel(fehler, SENTINEL, SENTINEL_WERT)


async def test_R3_F_005_wettlauf_um_dieselbe_ftm_kennung_endet_im_eindeutigkeitsfehler(
    datenbank: "Testdatenbank", faelle_eroeffnen: FaelleEroeffnen
) -> None:
    (e,) = await faelle_eroeffnen(1)
    fall = e.fall.kennung
    async with _weitere_verbindung(datenbank) as a, _weitere_verbindung(datenbank) as b:
        ta = await a.begin()
        tb = await b.begin()
        # Beide Prüfungen (Schritt 8) sehen die Kennung noch nicht.
        assert not await store.ftm_kennung_vergeben(a, fall, "synth-wettlauf")
        assert not await store.ftm_kennung_vergeben(b, fall, "synth-wettlauf")

        async def einfuegen(verbindung: AsyncConnection) -> None:
            h = uuid4()
            await store.herkunft_einfuegen(
                verbindung,
                kennung=h,
                fall_kennung=fall,
                herkunft=_herkunft_modell(),
                erstellt_am=JETZT,
            )
            await store.entitaet_einfuegen(
                verbindung,
                kennung=uuid4(),
                fall_kennung=fall,
                datensatz=_datensatz_modell("synth-wettlauf"),
                herkunft_kennung=h,
                erstellt_am=JETZT,
            )

        await einfuegen(a)
        zweiter = asyncio.ensure_future(einfuegen(b))
        await asyncio.sleep(0.3)
        assert not zweiter.done()  # wartet auf die Sperre des Index
        await ta.commit()
        with pytest.raises(EindeutigkeitsFehler) as info:
            await zweiter
        _ohne_sentinel(info.value, SENTINEL, SENTINEL_WERT, "synth-wettlauf")
        await tb.rollback()


# ---------------------------------------------------------------------------------------------
# Rechte der Anwendungsrolle (SD-S14-06) und unmittelbarer Weg
# ---------------------------------------------------------------------------------------------

TABELLEN = ("herkunft", "entitaet", "beziehung")


async def test_R3_F_005_rechtekatalog_je_tabelle_und_rolle(
    verbindung_eigentuemer: AsyncConnection,
) -> None:
    async with verbindung_eigentuemer.begin():
        for tabelle in TABELLEN:
            name = f"r3cosint.{tabelle}"
            for recht in ("INSERT", "SELECT"):
                assert (
                    await verbindung_eigentuemer.execute(
                        text(
                            "SELECT has_table_privilege('r3cosint_anwendung', :t, :r)"
                        ),
                        {"t": name, "r": recht},
                    )
                ).scalar_one() is True
            for recht in ("UPDATE", "DELETE", "TRUNCATE", "TRIGGER", "REFERENCES"):
                assert (
                    await verbindung_eigentuemer.execute(
                        text(
                            "SELECT has_table_privilege('r3cosint_anwendung', :t, :r)"
                        ),
                        {"t": name, "r": recht},
                    )
                ).scalar_one() is False, (tabelle, recht)
            for recht in ("UPDATE", "REFERENCES"):
                assert (
                    await verbindung_eigentuemer.execute(
                        text(
                            "SELECT has_any_column_privilege('r3cosint_anwendung', :t, :r)"
                        ),
                        {"t": name, "r": recht},
                    )
                ).scalar_one() is False, (tabelle, recht)
            spalten = (
                await verbindung_eigentuemer.execute(
                    text(
                        "SELECT count(*) FROM information_schema.column_privileges "
                        "WHERE table_schema = 'r3cosint' AND table_name = :t "
                        "AND grantee = 'r3cosint_anwendung' AND privilege_type = 'UPDATE'"
                    ),
                    {"t": tabelle},
                )
            ).scalar_one()
            assert spalten == 0
            public = (
                await verbindung_eigentuemer.execute(
                    text(
                        "SELECT count(*) FROM information_schema.table_privileges "
                        "WHERE table_schema = 'r3cosint' AND table_name = :t AND grantee = 'PUBLIC'"
                    ),
                    {"t": tabelle},
                )
            ).scalar_one()
            assert public == 0


@pytest.mark.parametrize("tabelle", TABELLEN)
@pytest.mark.parametrize(
    "anweisung",
    [
        "UPDATE r3cosint.{t} SET erstellt_am = erstellt_am",
        "DELETE FROM r3cosint.{t}",
        "TRUNCATE r3cosint.{t}",
    ],
)
async def test_R3_F_005_update_delete_und_truncate_sind_der_anwendung_verwehrt(
    verbindung_anwendung: AsyncConnection, tabelle: str, anweisung: str
) -> None:
    with pytest.raises(DBAPIError) as info:
        async with verbindung_anwendung.begin():
            await verbindung_anwendung.execute(text(anweisung.format(t=tabelle)))
    assert _sqlstate(info.value) == "42501"


async def test_R3_F_005_alle_fremdschluessel_ohne_on_delete_und_on_update(
    verbindung_eigentuemer: AsyncConnection,
) -> None:
    async with verbindung_eigentuemer.begin():
        zeilen = (
            await verbindung_eigentuemer.execute(
                text(
                    "SELECT conrelid::regclass::text, confdeltype::text, confupdtype::text "
                    "FROM pg_constraint WHERE contype = 'f' AND connamespace = 'r3cosint'::regnamespace "
                    "AND conrelid::regclass::text IN ('r3cosint.herkunft', 'r3cosint.entitaet', 'r3cosint.beziehung')"
                )
            )
        ).all()
    assert len(zeilen) == 7
    assert all(z[1] == "a" and z[2] == "a" for z in zeilen)


# ---------------------------------------------------------------------------------------------
# herkunft_pruefen: Formen, Isolationsstufe, Beleg der Grenze
# ---------------------------------------------------------------------------------------------

_M_HERKUNFT = (
    "INSERT INTO r3cosint.herkunft (kennung, fall_kennung, werkzeug, abfrage, zeitpunkt, "
    "erhebende_person, kennzeichnung, erstellt_am) VALUES ('{h}', '{f}', '{werkzeug}', "
    "'{abfrage}', '{zeitpunkt}', '{person}', '{kennzeichnung}', '{erstellt}')"
)
_M_ENTITAET = (
    "INSERT INTO r3cosint.entitaet (kennung, fall_kennung, ftm_kennung, schema, eigenschaften, "
    "herkunft_kennung, erstellt_am) VALUES ('{k}', '{f}', '{ftm}', 'Person', "
    "CAST('{{\"name\": [\"TEST-SYNTH eingebracht\"]}}' AS jsonb), '{h}', '2026-02-02 10:00:00+00')"
)
_FORMEN_UNVOLLSTAENDIG: dict[str, tuple[dict[str, str], tuple[str, ...]]] = {
    "werkzeug": ({"werkzeug": "Synth Ungueltig"}, ("herkunft_werkzeug_form",)),
    "abfrage_leer": ({"abfrage": "   "}, ("herkunft_abfrage_form",)),
    "abfrage_zu_lang": ({"abfrage": "SYNTH" + "a" * 4100}, ("herkunft_abfrage_form",)),
    "erhebende_person": (
        {"person": "Synth Person"},
        ("herkunft_erhebende_person_form",),
    ),
    "kennzeichnung": (
        {"kennzeichnung": "vermutung"},
        ("herkunft_kennzeichnung_vorrat",),
    ),
    "zeitbereich_zeitpunkt": (
        {"zeitpunkt": "-infinity"},
        ("herkunft_zeitpunkt_zeitbereich",),
    ),
    "zeitbereich_erstellt_am": (
        {"erstellt": "infinity"},
        ("herkunft_erstellt_am_zeitbereich",),
    ),
    "zeitpunkt_nach_erstellt_am": (
        {"zeitpunkt": "2026-03-01 00:00:00+00"},
        ("herkunft_zeitpunkt_vor_erstellt_am",),
    ),
}


@pytest.mark.parametrize("regel", list(_FORMEN_UNVOLLSTAENDIG))
async def test_R3_F_005_herkunft_pruefen_zaehlt_jede_formregel_einzeln_als_unvollstaendig(
    verbindung_anwendung: AsyncConnection,
    faelle_eroeffnen: FaelleEroeffnen,
    manipulieren: Manipulieren,
    regel: str,
) -> None:
    (e,) = await faelle_eroeffnen(1)
    fall = e.fall.kennung
    await _grundbestand(verbindung_anwendung, fall)
    vorher = await _befund(verbindung_anwendung)
    assert vorher.anzahl == 0
    werte = {
        "werkzeug": "synth.werkzeug",
        "abfrage": "SYNTH-Abfrage eingebracht",
        "zeitpunkt": "2026-02-01 09:15:00+00",
        "person": "synth.erhebung",
        "kennzeichnung": "quellenaussage",
        "erstellt": "2026-02-02 10:00:00+00",
    }
    aenderung, bedingungen = _FORMEN_UNVOLLSTAENDIG[regel]
    werte.update(aenderung)
    herkunft = uuid4()
    await manipulieren(
        _M_HERKUNFT.format(h=herkunft, f=fall, **werte)
        + ";"
        + _M_ENTITAET.format(k=uuid4(), f=fall, ftm="synth-unvoll-1", h=herkunft),
        bedingungen_entfernen=bedingungen,
    )
    nachher = await _befund(verbindung_anwendung)
    assert nachher.anzahl == 1
    assert nachher.knoten == vorher.knoten + 1
    for form in Herkunftsluecke:
        erwartet = 1 if form is Herkunftsluecke.UNVOLLSTAENDIG else 0
        assert nachher.je_form[form] == erwartet, (regel, form)


async def test_R3_F_005_herkunft_pruefen_zeigt_die_isolationsstufe_ohne_abweisung(
    verbindung_anwendung: AsyncConnection,
) -> None:
    assert (
        await _befund(verbindung_anwendung, "REPEATABLE READ")
    ).isolationsstufe == "repeatable read"
    assert (
        await _befund(verbindung_anwendung, "READ COMMITTED")
    ).isolationsstufe == "read committed"


async def test_R3_F_005_herkunft_pruefen_verlangt_eine_transaktion(
    verbindung_anwendung: AsyncConnection,
) -> None:
    with pytest.raises(EingabeFehler):
        await herkunft_pruefen(verbindung_anwendung)


async def test_R3_F_005_grenze_datenpunkt_ohne_spureintrag_bleibt_fuer_herkunft_pruefen_unsichtbar(
    verbindung_anwendung: AsyncConnection, faelle_eroeffnen: FaelleEroeffnen
) -> None:
    """Beleg der Grenze GS-38 (DF-S14-03), keine Anforderung: ein Datenpunkt ohne Eintrag der Spur."""
    (e,) = await faelle_eroeffnen(1)
    fall = e.fall.kennung
    async with verbindung_anwendung.begin():
        h = uuid4()
        await store.herkunft_einfuegen(
            verbindung_anwendung,
            kennung=h,
            fall_kennung=fall,
            herkunft=_herkunft_modell(),
            erstellt_am=JETZT,
        )
        await store.entitaet_einfuegen(
            verbindung_anwendung,
            kennung=uuid4(),
            fall_kennung=fall,
            datensatz=_datensatz_modell("synth-ohne-spur"),
            herkunft_kennung=h,
            erstellt_am=JETZT,
        )
    befund = await _befund(verbindung_anwendung)
    assert befund.anzahl == 0
    async with verbindung_anwendung.begin():
        spur = (
            await verbindung_anwendung.execute(
                text(
                    "SELECT count(*) FROM r3cosint.ermittlungsspur WHERE fall_kennung = :f"
                ),
                {"f": fall},
            )
        ).scalar_one()
    assert spur == 0


async def test_R3_F_005_herkunft_lesen_fehlender_satz_und_fremder_fall(
    verbindung_anwendung: AsyncConnection, faelle_eroeffnen: FaelleEroeffnen
) -> None:
    a, b = await faelle_eroeffnen(2)
    p = await _schreiben(verbindung_anwendung, a.fall.kennung, _knoten("synth-hl-1"))
    with pytest.raises(EingabeFehler):
        await herkunft_lesen(verbindung_anwendung, a.fall.kennung, uuid4())
    with pytest.raises(EingabeFehler):
        await herkunft_lesen(verbindung_anwendung, b.fall.kennung, p.herkunft_kennung)
    assert await datenpunkte_lesen(verbindung_anwendung, b.fall.kennung) == []


async def test_R3_F_005_herkunft_nach_dem_schreiben_wird_abgewiesen_ohne_spur_und_bestand(
    verbindung_anwendung: AsyncConnection, faelle_eroeffnen: FaelleEroeffnen
) -> None:
    (e,) = await faelle_eroeffnen(1)
    fall = e.fall.kennung
    spaet = _herkunft()
    spaet["zeitpunkt"] = JETZT + timedelta(days=1)
    with pytest.raises(HerkunftFehler):
        await _schreiben(verbindung_anwendung, fall, _knoten("synth-spaet"), spaet)
    assert await datenpunkte_lesen(verbindung_anwendung, fall) == []


# ---------------------------------------------------------------------------------------------
# Fehlertexte von schreiben (DS-S14-01, SD-S14-03 a)
# ---------------------------------------------------------------------------------------------


async def test_R3_F_003_sache_nennt_nur_aliasse_nie_schluessel_oder_eigenschaftsnamen_des_aufrufers(
    verbindung_anwendung: AsyncConnection, faelle_eroeffnen: FaelleEroeffnen
) -> None:
    (e,) = await faelle_eroeffnen(1)
    fall = e.fall.kennung
    fremder_schluessel = "SYNTH-SENTINEL-SCHLUESSEL"
    faelle: list[tuple[dict[str, object], dict[str, object], type[Exception], str]] = [
        (
            {**_knoten("synth-f-1"), fremder_schluessel: 1},
            _herkunft(),
            SchemaFehler,
            "unbekanntes Feld",
        ),
        (
            {
                "id": "synth-f-2",
                "schema": "Person",
                "properties": {"SynthSentinelName": ["a"]},
            },
            _herkunft(),
            SchemaFehler,
            "properties",
        ),
        (
            _knoten("synth-f-3"),
            {**_herkunft(), fremder_schluessel: 1},
            HerkunftFehler,
            "unbekanntes Feld",
        ),
        (
            _knoten("synth-f-4"),
            {**_herkunft(), "zeitpunkt": "kein Zeitpunkt"},
            HerkunftFehler,
            "zeitpunkt",
        ),
    ]
    for datensatz, herkunft, klasse, feld in faelle:
        with pytest.raises(klasse) as info:
            async with verbindung_anwendung.begin():
                await schreiben(
                    verbindung_anwendung,
                    fall_kennung=fall,
                    datensatz=datensatz,
                    herkunft=herkunft,
                    person_kennung=PERSON,
                    uhr=_Uhr(),
                )
        assert feld in info.value.sache  # type: ignore[attr-defined]
        _ohne_sentinel(
            info.value, fremder_schluessel, "SynthSentinelName", SENTINEL, SENTINEL_WERT
        )
    assert await datenpunkte_lesen(verbindung_anwendung, fall) == []


async def test_R3_F_003_schreiben_ohne_transaktion_und_mit_ungueltiger_person_wird_abgewiesen(
    verbindung_anwendung: AsyncConnection, faelle_eroeffnen: FaelleEroeffnen
) -> None:
    (e,) = await faelle_eroeffnen(1)
    with pytest.raises(EingabeFehler):
        await schreiben(
            verbindung_anwendung,
            fall_kennung=e.fall.kennung,
            datensatz=_knoten("synth-t-1"),
            herkunft=_herkunft(),
            person_kennung=PERSON,
            uhr=_Uhr(),
        )
    with pytest.raises(EingabeFehler):
        async with verbindung_anwendung.begin():
            await schreiben(
                verbindung_anwendung,
                fall_kennung=e.fall.kennung,
                datensatz=_knoten("synth-t-1"),
                herkunft=_herkunft(),
                person_kennung="Ungueltig Person",
                uhr=_Uhr(),
            )
    with pytest.raises(EingabeFehler):
        async with verbindung_anwendung.begin():
            await schreiben(
                verbindung_anwendung,
                fall_kennung=uuid4(),
                datensatz=_knoten("synth-t-2"),
                herkunft=_herkunft(),
                person_kennung=PERSON,
                uhr=_Uhr(),
            )


async def test_R3_F_003_uhr_ohne_zeitzone_oder_ausserhalb_des_bereichs_und_herkunft_ohne_abbildung(
    verbindung_anwendung: AsyncConnection, faelle_eroeffnen: FaelleEroeffnen
) -> None:
    (e,) = await faelle_eroeffnen(1)
    fall = e.fall.kennung

    class _Naiv:
        def jetzt(self) -> datetime:
            return datetime(2026, 2, 2)  # noqa: DTZ001 - naive Zeit ist der Prüfgegenstand

    class _Ueberlauf:
        def jetzt(self) -> datetime:
            return datetime(9999, 12, 31, 23, 0, tzinfo=timezone(timedelta(hours=-5)))

    for uhr in (_Naiv(), _Ueberlauf()):
        with pytest.raises(EingabeFehler):
            await _schreiben(verbindung_anwendung, fall, _knoten("synth-u-1"), uhr=uhr)
    with pytest.raises(HerkunftFehler) as info:
        async with verbindung_anwendung.begin():
            await schreiben(
                verbindung_anwendung,
                fall_kennung=fall,
                datensatz=_knoten("synth-u-2"),
                herkunft=None,  # type: ignore[arg-type]
                person_kennung=PERSON,
                uhr=_Uhr(),
            )
    assert "unbekanntes Feld" in info.value.sache


async def test_R3_F_003_kante_ohne_ende_im_datensatz_wird_vom_dienst_selbst_abgewiesen(
    verbindung_anwendung: AsyncConnection,
    faelle_eroeffnen: FaelleEroeffnen,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    from r3cosint.kanon import service
    from r3cosint.kanon.ftm import schemata

    (e,) = await faelle_eroeffnen(1)
    # Die Prüfung der Pflichteigenschaften des Schemas wird ausgesetzt: der Dienst sichert die Enden selbst.
    monkeypatch.setattr(service, "pruefen", lambda satz: schemata()["Ownership"])
    with pytest.raises(SchemaFehler):
        await _schreiben(
            verbindung_anwendung,
            e.fall.kennung,
            {
                "id": "synth-o-1",
                "schema": "Ownership",
                "properties": {"asset": ["synth-x"]},
            },
        )


# ---------------------------------------------------------------------------------------------
# Nachbesserungsrunde nach der Codeprüfung (ST-S14-02, -05, -13)
# ---------------------------------------------------------------------------------------------


async def _zaehlen(verbindung: AsyncConnection, fall: UUID) -> dict[str, Any]:
    """Zahl der Zeilen des Falls in den drei Tabellen und der Ermittlungsspur, dazu der Kettenkopf."""
    async with verbindung.begin():
        return await _zaehlen_in(verbindung, fall)


async def test_R3_F_005_abweisung_der_datenbank_in_schritt_10_ueber_schreiben_rollt_den_savepoint_zurueck(
    verbindung_anwendung: AsyncConnection,
    faelle_eroeffnen: FaelleEroeffnen,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    (e,) = await faelle_eroeffnen(1)
    fall = e.fall.kennung
    erster = await _schreiben(verbindung_anwendung, fall, _knoten("synth-s10-1"))

    async def nie_vergeben(*_: object, **__: object) -> bool:
        return False  # die Prüfung (8) sieht die Kennung nicht: der Wettlauf wird nachgestellt

    monkeypatch.setattr(store, "ftm_kennung_vergeben", nie_vergeben)
    vorher = await _zaehlen(verbindung_anwendung, fall)
    async with verbindung_anwendung.begin():
        zweiter = await schreiben(
            verbindung_anwendung,
            fall_kennung=fall,
            datensatz=_knoten("synth-s10-2"),
            herkunft=_herkunft(),
            person_kennung=PERSON,
            uhr=_Uhr(),
        )
        zwischen = await _zaehlen_in(verbindung_anwendung, fall)
        with pytest.raises(EindeutigkeitsFehler) as info:
            await schreiben(
                verbindung_anwendung,
                fall_kennung=fall,
                datensatz=_knoten("synth-s10-1"),  # dieselbe Kennung wie der erste
                herkunft=_herkunft(),
                person_kennung=PERSON,
                uhr=_Uhr(),
            )
        _ohne_sentinel(info.value, SENTINEL, SENTINEL_WERT, "synth-s10")
        # Die Transaktion des Aufrufers bleibt benutzbar (ohne SAVEPOINT: abgebrochen).
        assert (await verbindung_anwendung.execute(text("SELECT 1"))).scalar_one() == 1
        # Kein Rest des abgewiesenen Versuchs in den drei Tabellen und in der Spur.
        assert await _zaehlen_in(verbindung_anwendung, fall) == zwischen
    nachher = await _zaehlen(verbindung_anwendung, fall)
    assert nachher["herkunft"] == vorher["herkunft"] + 1
    assert nachher["entitaet"] == vorher["entitaet"] + 1
    assert nachher["ermittlungsspur"] == vorher["ermittlungsspur"] + 1
    punkte = {p.kennung for p in await datenpunkte_lesen(verbindung_anwendung, fall)}
    assert punkte == {
        erster.kennung,
        zweiter.kennung,
    }  # nach COMMIT besteht der zweite, der erste bleibt


_ZAEHLEN = "SELECT count(*) FROM r3cosint.{tabelle} WHERE fall_kennung = :f"


async def _zaehlen_in(verbindung: AsyncConnection, fall: UUID) -> dict[str, Any]:
    stand: dict[str, Any] = {}
    for tabelle in ("herkunft", "entitaet", "beziehung", "ermittlungsspur"):
        stand[tabelle] = (
            await verbindung.execute(
                text(_ZAEHLEN.format(tabelle=tabelle)),
                {"f": fall},
            )
        ).scalar_one()
    stand["kettenkopf"] = [
        tuple(z)
        for z in await verbindung.execute(
            text(
                "SELECT spur, position, pruefsumme FROM r3cosint.kettenkopf "
                "WHERE fall_kennung = :f ORDER BY spur"
            ),
            {"f": fall},
        )
    ]
    return stand


async def test_R3_F_005_store_23514_an_erstellt_am_ausserhalb_des_bereichs_ergibt_eingabefehler(
    verbindung_anwendung: AsyncConnection, faelle_eroeffnen: FaelleEroeffnen
) -> None:
    (e,) = await faelle_eroeffnen(1)

    async def aufruf() -> None:
        await store.herkunft_einfuegen(
            verbindung_anwendung,
            kennung=uuid4(),
            fall_kennung=e.fall.kennung,
            herkunft=_herkunft_modell(),
            erstellt_am=datetime(
                9999, 12, 31, tzinfo=UTC
            ),  # nach dem Bereich, zeitpunkt <= erstellt_am erfüllt
        )

    fehler = await _versuch(verbindung_anwendung, aufruf)
    assert type(fehler) is EingabeFehler
    _ohne_sentinel(fehler, SENTINEL)


async def test_R3_F_005_wettlauf_um_dieselbe_ftm_kennung_an_der_kante_endet_im_eindeutigkeitsfehler(
    datenbank: "Testdatenbank",
    verbindung_anwendung: AsyncConnection,
    faelle_eroeffnen: FaelleEroeffnen,
) -> None:
    (e,) = await faelle_eroeffnen(1)
    fall = e.fall.kennung
    p, c, _ = await _grundbestand(verbindung_anwendung, fall)
    async with _weitere_verbindung(datenbank) as a, _weitere_verbindung(datenbank) as b:
        ta = await a.begin()
        tb = await b.begin()
        assert not await store.ftm_kennung_vergeben(a, fall, "synth-wettlauf-k")
        assert not await store.ftm_kennung_vergeben(b, fall, "synth-wettlauf-k")

        async def einfuegen(verbindung: AsyncConnection) -> None:
            h = uuid4()
            await store.herkunft_einfuegen(
                verbindung,
                kennung=h,
                fall_kennung=fall,
                herkunft=_herkunft_modell(),
                erstellt_am=JETZT,
            )
            await store.beziehung_einfuegen(
                verbindung,
                kennung=uuid4(),
                fall_kennung=fall,
                datensatz=_datensatz_modell("synth-wettlauf-k"),
                herkunft_kennung=h,
                quelle_kennung=p.kennung,
                ziel_kennung=c.kennung,
                erstellt_am=JETZT,
            )

        await einfuegen(a)
        zweiter = asyncio.ensure_future(einfuegen(b))
        await asyncio.sleep(0.3)
        assert not zweiter.done()
        await ta.commit()
        with pytest.raises(EindeutigkeitsFehler) as info:
            await zweiter
        _ohne_sentinel(info.value, SENTINEL, SENTINEL_WERT, "synth-wettlauf")
        await tb.rollback()


async def test_R3_F_003_gesamtgroesse_in_bytes_endet_im_schemafehler_statt_in_der_datenbank(
    verbindung_anwendung: AsyncConnection, faelle_eroeffnen: FaelleEroeffnen
) -> None:
    (e,) = await faelle_eroeffnen(1)
    fall = e.fall.kennung
    werte = [chr(0x1F600 + n) + "\U0001f600" * 4095 for n in range(64)]
    datensatz: dict[str, object] = {
        "id": "synth-gross",
        "schema": "Person",
        "properties": {"name": werte[:50], "alias": werte[50:]},
    }
    with pytest.raises(SchemaFehler) as info:
        await _schreiben(verbindung_anwendung, fall, datensatz)
    _ohne_sentinel(info.value, SENTINEL, "synth-gross")
    assert await datenpunkte_lesen(verbindung_anwendung, fall) == []


async def test_R3_F_003_validator_und_datenbank_ziehen_die_bytegrenze_an_derselben_stelle(
    verbindung_anwendung: AsyncConnection, faelle_eroeffnen: FaelleEroeffnen
) -> None:
    """Der Validator wird selbst aufgerufen; die Datenbank (octet_length) bestimmt die Grösse.

    Kalibriert wird an der Datenbank: ein Datensatz aus 63 Werten zu 4096 Vier-Byte-Zeichen und
    einem letzten Wert, dessen Länge die Grösse des JSON-Texts auf genau 1 048 576 Bytes stellt.
    Wenige Bytes darunter und darüber muss der Validator wie die Prüfbedingung entscheiden; die
    Mutation "Summand Zahl der Werte plus Zahl der Namen minus 1 entfernt" (rund 66 Bytes)
    liesse die Fälle darüber durch.
    """
    import json

    (e,) = await faelle_eroeffnen(1)
    fall = e.fall.kennung
    vier = "\U0001f600"
    volle = [chr(0x1F600 + n) + vier * 4095 for n in range(63)]

    def eigenschaften(m: int, t: int) -> dict[str, list[str]]:
        # m Vier-Byte-Zeichen (verschieden von den vollen Werten) und t ASCII-Zeichen im letzten Wert.
        return {"name": [*volle, chr(0x1F700) + vier * (m - 1) + "a" * t]}

    async def groesse(eig: dict[str, list[str]]) -> int:
        async with verbindung_anwendung.begin():
            return int(
                (
                    await verbindung_anwendung.execute(
                        text(
                            "SELECT octet_length(CAST(CAST(:j AS text) AS jsonb)::text)"
                        ),
                        {"j": json.dumps(eig, ensure_ascii=False)},
                    )
                ).scalar_one()
            )

    grenze = 1_048_576
    start = await groesse(eigenschaften(4000, 0))
    fehlend = grenze - start
    assert 0 < fehlend < 4 * 96  # innerhalb der Zeichengrenze von 262 144 erreichbar

    def fall_mit(abstand: int) -> dict[str, list[str]]:
        # abstand Bytes über der Grenze: Vier-Byte-Zeichen und höchstens drei ASCII-Zeichen.
        gesamt = fehlend + abstand
        return eigenschaften(4000 + gesamt // 4, gesamt % 4)

    assert await groesse(fall_mit(0)) == grenze
    for abstand, angenommen in (
        (-3, True),
        (0, True),
        (1, False),
        (3, False),
        (60, False),
    ):
        eig = fall_mit(abstand)
        assert await groesse(eig) == grenze + abstand
        daten = {"id": "synth-grenze", "schema": "Person", "properties": eig}
        if angenommen:
            Datensatz.model_validate(daten)
        else:
            with pytest.raises(ValidationError):
                Datensatz.model_validate(daten)
    # An der Grenze nimmt auch die Datenbank den Datensatz an (kein EingabeFehler aus Schritt 10).
    punkt = await _schreiben(
        verbindung_anwendung,
        fall,
        {"id": "synth-grenze", "schema": "Person", "properties": fall_mit(0)},
    )
    assert punkt.fall_kennung == fall
