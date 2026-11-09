"""Integrationstest: Eröffnen und Schliessen eines Falls gegen PostgreSQL (ADR 0007, S1.3; R3-F-001).

Geschrieben wird als Anwendungsrolle über fall.service; der Eigentümer stellt Sonderfälle
her (Kategorie, fehlender Schlüssel). Alle Werte sind erfunden (5.15).
"""

import asyncio
import json
import traceback
from collections.abc import Awaitable, Callable
from datetime import UTC, datetime, timedelta, timezone
from typing import TYPE_CHECKING, Any
from uuid import UUID

import pytest
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncConnection

from r3cosint.core.datenbank import engine_erzeugen
from r3cosint.core.fehler import (
    EindeutigkeitsFehler,
    EingabeFehler,
    ZustandsFehler,
)
from r3cosint.fall import store
from r3cosint.fall.service import (
    Eroeffnung,
    Fall,
    Fallzustand,
    Rechtsregime,
    eroeffnen,
    fall_lesen,
    ketten_aller_faelle_pruefen,
    pseudonymisierer_laden,
    schliessen,
)
from r3cosint.spur.kette import zeitpunkt_text
from r3cosint.spur.service import (
    Spur,
    alle_ketten_pruefen,
    kette_pruefen,
    kette_pruefen_datenbank,
)

if TYPE_CHECKING:
    from conftest import EroeffneterFall, Testdatenbank

pytestmark = pytest.mark.anyio
# Feste Tabellennamen aus dem Test selbst, keine Eingabe: S608 trifft hier nicht zu.
# ruff: noqa: S608

PERSON = "test.ermittlung"
AKTENZEICHEN = "TEST-SYNTH-BE 2026/0001"
GEHEIM = ("TEST-SYNTH-BE", "synthetisch, ohne Rechtsgrundlage")
TABELLEN_BESTAND = (
    "fall",
    "fall_schluessel",
    "kettenkopf",
    "arbeitsspur",
    "ermittlungsspur",
)


def _utc(j: int, m: int, t: int, h: int = 0) -> datetime:
    return datetime(j, m, t, h, tzinfo=UTC)


def _eroeffnung(az: str = AKTENZEICHEN, kategorie: str = "vergehen") -> Eroeffnung:
    return Eroeffnung(
        aktenzeichen=az,
        rechtsgrundlage="synthetisch, ohne Rechtsgrundlage",
        rechtsregime=Rechtsregime.R1,
        fallkategorie=kategorie,
        ermittelnde_person="test.fallfuehrung",
    )


class _Uhr:
    def __init__(self, zeitpunkt: datetime) -> None:
        self.zeitpunkt = zeitpunkt

    def jetzt(self) -> datetime:
        return self.zeitpunkt


async def _eroeffnen(v: AsyncConnection, e: Eroeffnung, uhr: Any) -> Fall:
    async with v.begin():
        return await eroeffnen(v, eroeffnung=e, person_kennung=PERSON, uhr=uhr)


async def _schliessen(v: AsyncConnection, kennung: UUID, uhr: Any) -> Fall:
    async with v.begin():
        return await schliessen(v, fall_kennung=kennung, person_kennung=PERSON, uhr=uhr)


async def _zahlen(v: AsyncConnection) -> dict[str, int]:
    async with v.begin():
        return {
            t: int(
                (
                    await v.execute(text(f"SELECT count(*) FROM r3cosint.{t}"))
                ).scalar_one()
            )
            for t in TABELLEN_BESTAND
        }


async def _eintraege(
    v: AsyncConnection, fall: UUID, spur: Spur = Spur.ARBEITSSPUR
) -> list[Any]:
    async with v.begin():
        zeilen = await v.execute(
            text(
                f"SELECT position, zeitpunkt, person_kennung, eintragstyp, kennzeichnung, payload "
                f"FROM r3cosint.{spur.value} WHERE fall_kennung = :f ORDER BY position"
            ),
            {"f": fall},
        )
        return list(zeilen)


async def _beide_wege(v: AsyncConnection, fall: UUID, anzahl: int) -> None:
    async with v.begin():
        a = await kette_pruefen(v, fall)
    async with v.begin():
        d = await kette_pruefen_datenbank(v, fall)
    assert a == d
    assert a[Spur.ARBEITSSPUR].unversehrt
    assert a[Spur.ARBEITSSPUR].anzahl == anzahl
    assert a[Spur.ERMITTLUNGSSPUR].unversehrt
    assert a[Spur.ERMITTLUNGSSPUR].anzahl == 0


def _texte(fehler: BaseException) -> list[str]:
    return [
        str(fehler),
        repr(fehler),
        "".join(traceback.format_exception(fehler)),
    ]


async def test_R3_F_001_eroeffnen_schreibt_fall_schluessel_koepfe_und_genau_einen_eintrag(
    eroeffneter_fall: "EroeffneterFall",
    verbindung_anwendung: AsyncConnection,
    fallschluessel_lesen: Callable[[UUID], Awaitable[bytes]],
) -> None:
    fall = eroeffneter_fall.fall
    assert fall.zustand is Fallzustand.AKTIV
    zahlen = await _zahlen(verbindung_anwendung)
    assert zahlen == {
        "fall": 1,
        "fall_schluessel": 1,
        "kettenkopf": 2,
        "arbeitsspur": 1,
        "ermittlungsspur": 0,
    }
    assert len(await fallschluessel_lesen(fall.kennung)) == 32
    (eintrag,) = await _eintraege(verbindung_anwendung, fall.kennung)
    assert (eintrag.position, eintrag.eintragstyp, eintrag.kennzeichnung) == (
        1,
        "fall_eroeffnet",
        "quellenaussage",
    )
    assert eintrag.person_kennung == PERSON
    nutzlast = json.loads(eintrag.payload)
    assert eintrag.zeitpunkt == fall.eroeffnet_am
    assert zeitpunkt_text(eintrag.zeitpunkt) == nutzlast["eroeffnet_am"]
    assert zeitpunkt_text(fall.eroeffnet_am) == nutzlast["eroeffnet_am"]
    await _beide_wege(verbindung_anwendung, fall.kennung, 1)
    assert await fall_lesen(verbindung_anwendung, fall.kennung) == fall


async def test_R3_F_001_kein_klartext_in_den_spuren_und_pseudonym_nachgerechnet(
    eroeffneter_fall: "EroeffneterFall", verbindung_anwendung: AsyncConnection
) -> None:
    fall = eroeffneter_fall.fall
    await _schliessen(verbindung_anwendung, fall.kennung, eroeffneter_fall.uhr)
    async with verbindung_anwendung.begin():
        tabellen = [
            z[0]
            for z in await verbindung_anwendung.execute(
                text(
                    "SELECT tablename FROM pg_tables WHERE schemaname = 'r3cosint' AND "
                    "tablename NOT IN ('fall','fallkategorie','fall_schluessel','alembic_version')"
                )
            )
        ]
        assert set(tabellen) == {"arbeitsspur", "ermittlungsspur", "kettenkopf"}
        alles = ""
        for t in tabellen:
            alles += "".join(
                z[0]
                for z in await verbindung_anwendung.execute(
                    text(f"SELECT t::text FROM r3cosint.{t} t")
                )
            )
    e = eroeffneter_fall.eroeffnung
    for klartext in (e.aktenzeichen, e.rechtsgrundlage, e.ermittelnde_person):
        assert klartext not in alles
        assert klartext.casefold() not in alles.casefold()
    (eintrag, _) = await _eintraege(verbindung_anwendung, fall.kennung)
    nutzlast = json.loads(eintrag.payload)
    assert nutzlast[
        "aktenzeichen_pseudonym"
    ] == eroeffneter_fall.pseudonymisierer.pseudonym(e.aktenzeichen)


async def test_R3_F_001_schliessen_setzt_zeiten_frist_und_eintrag_mit_gleichen_zeitwerten(
    eroeffneter_fall: "EroeffneterFall", verbindung_anwendung: AsyncConnection
) -> None:
    fall = eroeffneter_fall.fall
    uhr = eroeffneter_fall.uhr
    uhr.zeitpunkt = datetime(2026, 8, 31, 10, 0, 0, 5, tzinfo=UTC)
    zu = await _schliessen(verbindung_anwendung, fall.kennung, uhr)
    assert zu.zustand is Fallzustand.ABGESCHLOSSEN
    assert zu.geschlossen_am == uhr.zeitpunkt
    assert zu.prueffrist_bis == datetime(2033, 8, 31, 10, 0, 0, 5, tzinfo=UTC)
    assert await fall_lesen(verbindung_anwendung, fall.kennung) == zu
    zeilen = await _eintraege(verbindung_anwendung, fall.kennung)
    assert [(z.position, z.eintragstyp) for z in zeilen] == [
        (1, "fall_eroeffnet"),
        (2, "fall_geschlossen"),
    ]
    nutzlast = json.loads(zeilen[1].payload)
    assert zeitpunkt_text(zeilen[1].zeitpunkt) == nutzlast["geschlossen_am"]
    assert zeitpunkt_text(zu.geschlossen_am) == nutzlast["geschlossen_am"]
    assert zeitpunkt_text(zu.prueffrist_bis) == nutzlast["prueffrist_bis"]
    assert nutzlast["erste_pruefung_monate"] == 84
    await _beide_wege(verbindung_anwendung, fall.kennung, 2)


async def test_R3_F_001_die_frist_kommt_aus_der_kategorie_und_nicht_aus_dem_code(
    verbindung_anwendung: AsyncConnection, verbindung_eigentuemer: AsyncConnection
) -> None:
    await verbindung_eigentuemer.execute(
        text(
            "INSERT INTO r3cosint.fallkategorie (kennung, bezeichnung, erste_pruefung_monate) "
            "VALUES ('test_sieben', 'synthetisch', 7)"
        )
    )
    await verbindung_eigentuemer.commit()
    uhr = _Uhr(_utc(2026, 1, 31, 12))
    fall = await _eroeffnen(
        verbindung_anwendung, _eroeffnung(kategorie="test_sieben"), uhr
    )
    uhr.zeitpunkt = _utc(2026, 7, 31, 12)
    zu = await _schliessen(verbindung_anwendung, fall.kennung, uhr)
    assert zu.prueffrist_bis == _utc(2027, 2, 28, 12)
    nutzlast = json.loads(
        (await _eintraege(verbindung_anwendung, fall.kennung))[1].payload
    )
    assert nutzlast["erste_pruefung_monate"] == 7


async def _ohne_spuren(v: AsyncConnection, vorher: dict[str, int]) -> None:
    assert await _zahlen(v) == vorher


@pytest.mark.parametrize("zustand", ["aktiv", "abgeschlossen"])
@pytest.mark.parametrize(
    ("zweites", "abgewiesen"),
    [
        (AKTENZEICHEN, True),
        ("TEST-SYNTH-BE   2026/0001 ", True),
        ("test-synth-be 2026/0001", False),
    ],
)
async def test_R3_F_001_doppeltes_aktenzeichen_wird_ohne_rueckstand_abgewiesen(
    zustand: str, zweites: str, abgewiesen: bool, verbindung_anwendung: AsyncConnection
) -> None:
    v = verbindung_anwendung
    uhr = _Uhr(_utc(2026, 2, 2, 9))
    erster = await _eroeffnen(v, _eroeffnung(), uhr)
    if zustand == "abgeschlossen":
        uhr.zeitpunkt = _utc(2026, 3, 2, 9)
        await _schliessen(v, erster.kennung, uhr)
    vorher = await _zahlen(v)
    if abgewiesen:
        with pytest.raises(EindeutigkeitsFehler) as info:
            await _eroeffnen(v, _eroeffnung(zweites), uhr)
        assert info.value.__cause__ is None
        assert info.value.__context__ is None
        for t in _texte(info.value):
            assert "0001" not in t
            assert "BE" not in t
        await _ohne_spuren(v, vorher)
        await _beide_wege(v, erster.kennung, 2 if zustand == "abgeschlossen" else 1)
    else:
        await _eroeffnen(v, _eroeffnung(zweites), uhr)
        assert (await _zahlen(v))["fall"] == 2


async def test_R3_F_001_abweisungen_vor_dem_schreiben_hinterlassen_nichts(
    verbindung_anwendung: AsyncConnection, eroeffneter_fall: "EroeffneterFall"
) -> None:
    v = verbindung_anwendung
    vorher = await _zahlen(v)
    uhr = _Uhr(_utc(2026, 2, 2, 9))
    fall = eroeffneter_fall.fall

    with pytest.raises(EingabeFehler, match="Fallkategorie"):
        await _eroeffnen(v, _eroeffnung("X-1", "gibt_es_nicht"), uhr)
    with pytest.raises(EingabeFehler, match="zeitbewusst"):
        await _eroeffnen(v, _eroeffnung("X-2"), _Uhr(datetime(2026, 1, 1)))  # noqa: DTZ001
    with pytest.raises(EingabeFehler, match="Bereich"):
        # +05:00 am letzten Tag: die Umrechnung nach UTC läuft über.
        spaet = datetime(9999, 12, 31, 23, 0, tzinfo=timezone(-timedelta(hours=5)))
        await _eroeffnen(v, _eroeffnung("X-3"), _Uhr(spaet))
    with pytest.raises(EingabeFehler):
        await _eroeffnen(v, _eroeffnung("X-4"), _Uhr(datetime(1999, 1, 1, tzinfo=UTC)))
    with pytest.raises(EingabeFehler, match="Benutzerkennung"):
        async with v.begin():
            await eroeffnen(
                v,
                eroeffnung=_eroeffnung("X-5"),
                person_kennung="Falsch Person",
                uhr=uhr,
            )
    with pytest.raises(EingabeFehler, match="Transaktion"):
        await eroeffnen(
            v, eroeffnung=_eroeffnung("X-6"), person_kennung=PERSON, uhr=uhr
        )
    with pytest.raises(EingabeFehler, match="Fall besteht nicht"):
        await _schliessen(v, UUID(int=7), uhr)
    with pytest.raises(EingabeFehler, match="zeitbewusst"):
        await _schliessen(v, fall.kennung, _Uhr(datetime(2026, 1, 1)))  # noqa: DTZ001
    with pytest.raises(EingabeFehler, match="vor der Eröffnung"):
        await _schliessen(
            v, fall.kennung, _Uhr(fall.eroeffnet_am - timedelta(seconds=1))
        )
    with pytest.raises(EingabeFehler, match="Benutzerkennung"):
        async with v.begin():
            await schliessen(
                v, fall_kennung=fall.kennung, person_kennung="X Y", uhr=uhr
            )
    with pytest.raises(EingabeFehler, match="Transaktion"):
        await schliessen(v, fall_kennung=fall.kennung, person_kennung=PERSON, uhr=uhr)
    with pytest.raises(EingabeFehler, match="Transaktion"):
        await ketten_aller_faelle_pruefen(v)
    await _ohne_spuren(v, vorher)
    assert (await fall_lesen(v, fall.kennung)).zustand is Fallzustand.AKTIV


async def test_R3_F_001_zweites_schliessen_und_fall_schliessen_am_store_weisen_ab(
    eroeffneter_fall: "EroeffneterFall", verbindung_anwendung: AsyncConnection
) -> None:
    v = verbindung_anwendung
    fall = eroeffneter_fall.fall
    zu = await _schliessen(v, fall.kennung, eroeffneter_fall.uhr)
    assert zu.geschlossen_am is not None
    vorher = await _zahlen(v)
    with pytest.raises(ZustandsFehler):
        await _schliessen(v, fall.kennung, _Uhr(zu.geschlossen_am + timedelta(days=9)))
    await _ohne_spuren(v, vorher)
    assert await fall_lesen(v, fall.kennung) == zu
    async with v.begin():
        zeilen = await store.fall_schliessen(
            v,
            fall_kennung=fall.kennung,
            geschlossen_am=_utc(2027, 1, 1),
            prueffrist_bis=_utc(2030, 1, 1),
        )
    assert zeilen == 0
    assert await fall_lesen(v, fall.kennung) == zu


async def test_R3_F_001_die_zweite_linie_beim_schliessen_weist_ab(
    eroeffneter_fall: "EroeffneterFall",
    verbindung_anwendung: AsyncConnection,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    async def keine_zeile(*_a: object, **_k: object) -> int:
        return 0

    monkeypatch.setattr(store, "fall_schliessen", keine_zeile)
    vorher = await _zahlen(verbindung_anwendung)
    with pytest.raises(ZustandsFehler):
        await _schliessen(
            verbindung_anwendung, eroeffneter_fall.fall.kennung, eroeffneter_fall.uhr
        )
    await _ohne_spuren(verbindung_anwendung, vorher)


async def test_R3_F_001_ueberlauf_der_pruefrist_ist_ein_eingabefehler_ohne_schreiben(
    verbindung_anwendung: AsyncConnection, verbindung_eigentuemer: AsyncConnection
) -> None:
    await verbindung_eigentuemer.execute(
        text(
            "INSERT INTO r3cosint.fallkategorie (kennung, bezeichnung, erste_pruefung_monate) "
            "VALUES ('test_riesig', 'synthetisch', 96000)"
        )
    )
    await verbindung_eigentuemer.commit()
    uhr = _Uhr(_utc(2026, 1, 31, 12))
    fall = await _eroeffnen(
        verbindung_anwendung, _eroeffnung(kategorie="test_riesig"), uhr
    )
    vorher = await _zahlen(verbindung_anwendung)
    with pytest.raises(EingabeFehler, match="darstellbaren Bereich"):
        await _schliessen(verbindung_anwendung, fall.kennung, uhr)
    await _ohne_spuren(verbindung_anwendung, vorher)
    assert (
        await fall_lesen(verbindung_anwendung, fall.kennung)
    ).zustand is Fallzustand.AKTIV


async def test_R3_F_001_eine_gefangene_abweisung_laesst_fruehere_vorgaenge_der_transaktion_bestehen(
    verbindung_anwendung: AsyncConnection,
) -> None:
    v = verbindung_anwendung
    uhr = _Uhr(_utc(2026, 2, 2, 9))
    async with v.begin():
        erster = await eroeffnen(
            v, eroeffnung=_eroeffnung(), person_kennung=PERSON, uhr=uhr
        )
        with pytest.raises(EindeutigkeitsFehler):
            await eroeffnen(v, eroeffnung=_eroeffnung(), person_kennung=PERSON, uhr=uhr)
    assert await _zahlen(v) == {
        "fall": 1,
        "fall_schluessel": 1,
        "kettenkopf": 2,
        "arbeitsspur": 1,
        "ermittlungsspur": 0,
    }
    assert (await fall_lesen(v, erster.kennung)).zustand is Fallzustand.AKTIV
    await _beide_wege(v, erster.kennung, 1)


async def test_R3_F_001_gefangenes_schliessen_ohne_schluessel_rollt_den_vorgang_zurueck(
    eroeffneter_fall: "EroeffneterFall",
    verbindung_anwendung: AsyncConnection,
    verbindung_eigentuemer: AsyncConnection,
) -> None:
    v = verbindung_anwendung
    fall = eroeffneter_fall.fall
    await verbindung_eigentuemer.execute(
        text("DELETE FROM r3cosint.fall_schluessel WHERE fall_kennung = :k"),
        {"k": fall.kennung},
    )
    await verbindung_eigentuemer.commit()
    async with v.begin():
        with pytest.raises(EingabeFehler, match="Fallschlüssel"):
            await schliessen(
                v,
                fall_kennung=fall.kennung,
                person_kennung=PERSON,
                uhr=eroeffneter_fall.uhr,
            )
    assert (await fall_lesen(v, fall.kennung)).zustand is Fallzustand.AKTIV
    assert len(await _eintraege(v, fall.kennung)) == 1
    with pytest.raises(EingabeFehler, match="Fallschlüssel"):
        await pseudonymisierer_laden(v, fall.kennung)


async def test_R3_F_001_gefangenes_zweites_schliessen_laesst_das_erste_bestehen(
    eroeffneter_fall: "EroeffneterFall", verbindung_anwendung: AsyncConnection
) -> None:
    v = verbindung_anwendung
    fall = eroeffneter_fall.fall
    async with v.begin():
        await schliessen(
            v,
            fall_kennung=fall.kennung,
            person_kennung=PERSON,
            uhr=eroeffneter_fall.uhr,
        )
        with pytest.raises(ZustandsFehler):
            await schliessen(
                v,
                fall_kennung=fall.kennung,
                person_kennung=PERSON,
                uhr=eroeffneter_fall.uhr,
            )
    assert (await fall_lesen(v, fall.kennung)).zustand is Fallzustand.ABGESCHLOSSEN
    assert len(await _eintraege(v, fall.kennung)) == 2


async def test_R3_F_001_pseudonymisierer_laden_und_fall_lesen_mit_und_ohne_transaktion(
    eroeffneter_fall: "EroeffneterFall", verbindung_anwendung: AsyncConnection
) -> None:
    v = verbindung_anwendung
    fall = eroeffneter_fall.fall
    ohne = await pseudonymisierer_laden(v, fall.kennung)
    assert not v.in_transaction()
    async with v.begin():
        mit = await pseudonymisierer_laden(v, fall.kennung)
        assert await fall_lesen(v, fall.kennung) == fall
    assert (
        ohne.pseudonym("x")
        == mit.pseudonym("x")
        == eroeffneter_fall.pseudonymisierer.pseudonym("x")
    )
    with pytest.raises(EingabeFehler, match="Fall besteht nicht"):
        await fall_lesen(v, UUID(int=9))
    assert not v.in_transaction()


async def test_R3_F_001_zwei_faelle_tragen_verschiedene_schluessel(
    faelle_eroeffnen: Callable[[int], Awaitable[list["EroeffneterFall"]]],
    fallschluessel_lesen: Callable[[UUID], Awaitable[bytes]],
) -> None:
    a, b = await faelle_eroeffnen(2)
    assert await fallschluessel_lesen(a.fall.kennung) != await fallschluessel_lesen(
        b.fall.kennung
    )
    assert a.pseudonymisierer.pseudonym("x") != b.pseudonymisierer.pseudonym("x")


async def test_R3_F_001_ketten_aller_faelle_pruefen_deckt_einen_fall_ohne_koepfe_und_eintraege_auf(
    faelle_eroeffnen: Callable[[int], Awaitable[list["EroeffneterFall"]]],
    verbindung_anwendung: AsyncConnection,
    manipulieren: Callable[..., Awaitable[str]],
) -> None:
    a, b = await faelle_eroeffnen(2)
    async with verbindung_anwendung.begin():
        befunde = await ketten_aller_faelle_pruefen(verbindung_anwendung)
    assert len(befunde) == 4
    assert all(x.unversehrt for x in befunde)
    assert [(x.fall_kennung, x.spur) for x in befunde] == sorted(
        (x.fall_kennung, x.spur) for x in befunde
    )
    assert (
        await manipulieren(
            "; ".join(
                f"DELETE FROM r3cosint.{t} WHERE fall_kennung = '{b.fall.kennung}'"
                for t in ("arbeitsspur", "ermittlungsspur", "kettenkopf")
            )
        )
        == "origin"
    )
    async with verbindung_anwendung.begin():
        befunde = await ketten_aller_faelle_pruefen(verbindung_anwendung)
    gebrochen = [x for x in befunde if x.fall_kennung == b.fall.kennung]
    assert len(gebrochen) == 2
    assert all(not x.unversehrt and x.position == 0 for x in gebrochen)
    assert all(
        x.grund is not None and x.grund.value == "kopf_abweichend" for x in gebrochen
    )
    assert all(x.unversehrt for x in befunde if x.fall_kennung == a.fall.kennung)
    # GS-19: alle_ketten_pruefen geht von den Kettenköpfen aus und meldet den Fall nicht.
    async with verbindung_anwendung.begin():
        nur_koepfe = await alle_ketten_pruefen(verbindung_anwendung)
    assert b.fall.kennung not in {x.fall_kennung for x in nur_koepfe}
    assert a.fall.kennung in {x.fall_kennung for x in nur_koepfe}


async def test_R3_F_001_gleichzeitiges_schliessen_gelingt_genau_einmal(
    eroeffneter_fall: "EroeffneterFall",
    datenbank: "Testdatenbank",
    verbindung_anwendung: AsyncConnection,
) -> None:
    fall = eroeffneter_fall.fall

    async def versuch() -> str:
        engine = engine_erzeugen(datenbank.verbindung("r3cosint_anwendung"))
        try:
            async with engine.connect() as v:
                try:
                    async with v.begin():
                        await schliessen(
                            v,
                            fall_kennung=fall.kennung,
                            person_kennung=PERSON,
                            uhr=_Uhr(_utc(2026, 5, 5, 9)),
                        )
                except ZustandsFehler:
                    return "abgewiesen"
                return "gelungen"
        finally:
            await engine.dispose()

    ergebnisse = await asyncio.gather(versuch(), versuch())
    assert sorted(ergebnisse) == ["abgewiesen", "gelungen"]
    zeilen = await _eintraege(verbindung_anwendung, fall.kennung)
    assert [(z.position, z.eintragstyp) for z in zeilen] == [
        (1, "fall_eroeffnet"),
        (2, "fall_geschlossen"),
    ]


async def test_R3_F_001_gleichzeitiges_eroeffnen_mit_demselben_aktenzeichen_gelingt_genau_einmal(
    datenbank: "Testdatenbank", verbindung_anwendung: AsyncConnection
) -> None:
    async def versuch() -> str:
        engine = engine_erzeugen(datenbank.verbindung("r3cosint_anwendung"))
        try:
            async with engine.connect() as v:
                try:
                    async with v.begin():
                        await eroeffnen(
                            v,
                            eroeffnung=_eroeffnung(),
                            person_kennung=PERSON,
                            uhr=_Uhr(_utc(2026, 5, 5, 9)),
                        )
                except EindeutigkeitsFehler:
                    return "abgewiesen"
                return "gelungen"
        finally:
            await engine.dispose()

    assert sorted(await asyncio.gather(versuch(), versuch())) == [
        "abgewiesen",
        "gelungen",
    ]
    assert (await _zahlen(verbindung_anwendung))["fall"] == 1
    assert (await _zahlen(verbindung_anwendung))["arbeitsspur"] == 1


class _FortschreitendeUhr:
    """Uhr, die bei jedem Aufruf um eine Sekunde weiterläuft (eine Systemuhr täte es auch)."""

    def __init__(self, start: datetime) -> None:
        self._zeit = start

    def jetzt(self) -> datetime:
        self._zeit += timedelta(seconds=1)
        return self._zeit


async def test_R3_F_001_die_uhr_wird_einmal_gelesen_und_alle_zeitwerte_sind_gleich(
    verbindung_anwendung: AsyncConnection,
) -> None:
    v = verbindung_anwendung
    uhr = _FortschreitendeUhr(_utc(2026, 2, 2, 9))
    fall = await _eroeffnen(v, _eroeffnung(), uhr)
    (eintrag,) = await _eintraege(v, fall.kennung)
    assert eintrag.zeitpunkt == fall.eroeffnet_am
    assert json.loads(eintrag.payload)["eroeffnet_am"] == zeitpunkt_text(
        fall.eroeffnet_am
    )
    zu = await _schliessen(v, fall.kennung, uhr)
    zeilen = await _eintraege(v, fall.kennung)
    assert zeilen[1].zeitpunkt == zu.geschlossen_am
    assert json.loads(zeilen[1].payload)["geschlossen_am"] == zeitpunkt_text(
        zu.geschlossen_am
    )
