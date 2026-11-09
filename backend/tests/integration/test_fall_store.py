"""Integrationstest: fall.store und der Auslöser fall_uebergang (ADR 0007, S1.3; R3-F-001).

Abweisungswege ohne Klartext in Ursache, Kontext und Fehlertext; der Auslöser bindet den
Zustand für die Anwendungsrolle. Alle Werte sind erfunden (5.15).
"""

import re
import traceback
from typing import TYPE_CHECKING, Any
from uuid import UUID

import pytest
from sqlalchemy import text
from sqlalchemy.exc import DBAPIError
from sqlalchemy.ext.asyncio import AsyncConnection

from r3cosint.core.fehler import EindeutigkeitsFehler, EingabeFehler
from r3cosint.core.zeit import Systemuhr
from r3cosint.fall import store
from r3cosint.fall.service import Eroeffnung, Fallzustand, Rechtsregime

if TYPE_CHECKING:
    from conftest import EroeffneterFall

pytestmark = pytest.mark.anyio

GEHEIM_AZ = "TEST-SYNTH-GEHEIM-0042"
GEHEIM_RG = "synthetische GEHEIME Rechtsgrundlage"


def _eroeffnung(az: str = GEHEIM_AZ, kategorie: str = "vergehen") -> Eroeffnung:
    return Eroeffnung(
        aktenzeichen=az,
        rechtsgrundlage=GEHEIM_RG,
        rechtsregime=Rechtsregime.R1,
        fallkategorie=kategorie,
        ermittelnde_person="test.fallfuehrung",
    )


def _ohne_klartext(fehler: BaseException, *werte: str) -> None:
    assert fehler.__cause__ is None
    assert fehler.__context__ is None
    for t in (str(fehler), repr(fehler), "".join(traceback.format_exception(fehler))):
        for wert in werte:
            assert wert not in t


async def test_R3_F_001_23505_am_teilindex_ist_ein_eindeutigkeitsfehler_ohne_klartext(
    eroeffneter_fall: "EroeffneterFall", verbindung_anwendung: AsyncConnection
) -> None:
    zeit = Systemuhr().jetzt()
    az = eroeffneter_fall.eroeffnung.aktenzeichen
    with pytest.raises(EindeutigkeitsFehler) as info:
        async with verbindung_anwendung.begin():
            await store.fall_einfuegen(
                verbindung_anwendung,
                kennung=UUID(int=11),
                eroeffnung=_eroeffnung(az),
                eroeffnet_am=zeit,
            )
    _ohne_klartext(info.value, az, GEHEIM_RG, "test.fallfuehrung")


async def test_R3_F_001_23505_am_primaerschluessel_ist_ein_eingabefehler_und_kein_eindeutigkeitsfehler(
    eroeffneter_fall: "EroeffneterFall", verbindung_anwendung: AsyncConnection
) -> None:
    with pytest.raises(EingabeFehler) as info:
        async with verbindung_anwendung.begin():
            await store.fall_einfuegen(
                verbindung_anwendung,
                kennung=eroeffneter_fall.fall.kennung,
                eroeffnung=_eroeffnung("TEST-SYNTH-ANDERS"),
                eroeffnet_am=Systemuhr().jetzt(),
            )
    assert not isinstance(info.value, EindeutigkeitsFehler)
    _ohne_klartext(info.value, "ANDERS", GEHEIM_RG, str(eroeffneter_fall.fall.kennung))


async def test_R3_F_001_andere_verletzung_von_fall_einfuegen_ist_ein_eingabefehler(
    verbindung_anwendung: AsyncConnection,
) -> None:
    with pytest.raises(EingabeFehler, match="Prüfbedingung") as info:
        async with verbindung_anwendung.begin():
            await store.fall_einfuegen(
                verbindung_anwendung,
                kennung=UUID(int=12),
                eroeffnung=_eroeffnung(kategorie="gibt_es_nicht"),
                eroeffnet_am=Systemuhr().jetzt(),
            )
    assert not isinstance(info.value, EindeutigkeitsFehler)
    _ohne_klartext(info.value, GEHEIM_AZ, GEHEIM_RG, "gibt_es_nicht")


async def test_R3_F_001_schluessel_einfuegen_weist_ab_ohne_schluesselbytes(
    eroeffneter_fall: "EroeffneterFall", verbindung_anwendung: AsyncConnection
) -> None:
    kurz = bytes(range(1, 32))
    with pytest.raises(EingabeFehler) as info:
        async with verbindung_anwendung.begin():
            await store.schluessel_einfuegen(
                verbindung_anwendung, eroeffneter_fall.fall.kennung, kurz
            )
    _ohne_klartext(info.value, kurz.hex(), "\\x" + kurz.hex())
    # Primärschlüssel: der Fall hat schon einen Schlüssel.
    voll = bytes(range(32))
    with pytest.raises(EingabeFehler) as info2:
        async with verbindung_anwendung.begin():
            await store.schluessel_einfuegen(
                verbindung_anwendung, eroeffneter_fall.fall.kennung, voll
            )
    _ohne_klartext(info2.value, voll.hex())


async def test_R3_F_001_store_liest_ohne_treffer_none_und_sortiert_die_kennungen(
    faelle_eroeffnen: Any, verbindung_anwendung: AsyncConnection
) -> None:
    v = verbindung_anwendung
    async with v.begin():
        assert await store.fallkategorie_lesen(v, "vergehen") == 84
        assert await store.fallkategorie_lesen(v, "gibt_es_nicht") is None
        assert await store.schluessel_lesen(v, UUID(int=1)) is None
        assert await store.fall_lesen(v, UUID(int=1)) is None
        assert await store.fall_sperren(v, UUID(int=1)) is None
        assert await store.fall_kennungen_lesen(v) == []
    faelle = await faelle_eroeffnen(3)
    async with v.begin():
        kennungen = await store.fall_kennungen_lesen(v)
        gesperrt = await store.fall_sperren(v, faelle[0].fall.kennung)
    assert kennungen == sorted(f.fall.kennung for f in faelle)
    assert gesperrt == (faelle[0].fall, 84)


async def _sqlstate_und_text(
    v: AsyncConnection, sql: str, **parameter: Any
) -> tuple[str, str]:
    try:
        async with v.begin():
            await v.execute(text(sql), parameter)
    except DBAPIError as fehler:
        orig = fehler.orig
        return str(getattr(orig, "sqlstate", "")), str(orig)
    return "", ""


_FALL_INSERT = (
    "INSERT INTO r3cosint.fall (kennung, aktenzeichen, ermittelnde_person, rechtsgrundlage, "
    "rechtsregime, fallkategorie, zustand, eroeffnet_am, geschlossen_am, prueffrist_bis) "
    "VALUES (CAST(:k AS uuid), 'TEST-SYNTH-TRIGGER', 'test.fallfuehrung', 'synthetisch', 'R1', "
    "'vergehen', :zustand, now(), CAST(CAST(:zu AS text) AS timestamptz), "
    "CAST(CAST(:pf AS text) AS timestamptz))"
)


@pytest.mark.parametrize(
    ("zustand", "zu", "pf"),
    [
        ("abgeschlossen", None, None),
        ("abgeschlossen", "2026-01-02T00:00:00+00", "2030-01-02T00:00:00+00"),
        ("aktiv", "2026-01-02T00:00:00+00", None),
        ("aktiv", None, "2030-01-02T00:00:00+00"),
        ("geloescht", None, None),
    ],
)
async def test_R3_F_001_ausloeser_weist_inserts_ausserhalb_von_aktiv_ohne_zeiten_ab(
    zustand: str, zu: str | None, pf: str | None, verbindung_anwendung: AsyncConnection
) -> None:
    sqlstate, meldung = await _sqlstate_und_text(
        verbindung_anwendung,
        _FALL_INSERT,
        k=str(UUID(int=21)),
        zustand=zustand,
        zu=zu,
        pf=pf,
    )
    assert sqlstate == "P0001"
    assert "TRIGGER" not in meldung
    async with verbindung_anwendung.begin():
        assert await store.fall_lesen(verbindung_anwendung, UUID(int=21)) is None


@pytest.mark.parametrize(
    "aenderung",
    [
        "zustand = 'geloescht'",
        "zustand = 'geloescht', geschlossen_am = now(), prueffrist_bis = now()",
        "zustand = 'pruefung_faellig', geschlossen_am = now(), prueffrist_bis = now()",
        "zustand = 'abgeschlossen'",
        "zustand = 'abgeschlossen', geschlossen_am = now()",
        "zustand = 'abgeschlossen', prueffrist_bis = now()",
    ],
)
async def test_R3_F_001_ausloeser_weist_uebergaenge_eines_aktiven_falls_ausserhalb_der_regel_ab(
    aenderung: str,
    eroeffneter_fall: "EroeffneterFall",
    verbindung_anwendung: AsyncConnection,
) -> None:
    sqlstate, meldung = await _sqlstate_und_text(
        verbindung_anwendung,
        f"UPDATE r3cosint.fall SET {aenderung} WHERE kennung = CAST(:k AS uuid)",  # noqa: S608
        k=str(eroeffneter_fall.fall.kennung),
    )
    assert sqlstate == "P0001"
    assert eroeffneter_fall.eroeffnung.aktenzeichen not in meldung
    await _aktenzeichen_bleibt_belegt(eroeffneter_fall, verbindung_anwendung)


async def _aktenzeichen_bleibt_belegt(
    fall: "EroeffneterFall", v: AsyncConnection
) -> None:
    with pytest.raises(EindeutigkeitsFehler):
        async with v.begin():
            await store.fall_einfuegen(
                v,
                kennung=UUID(int=99),
                eroeffnung=fall.eroeffnung,
                eroeffnet_am=Systemuhr().jetzt(),
            )


@pytest.mark.parametrize(
    "aenderung",
    [
        "zustand = 'aktiv'",
        "zustand = 'geloescht'",
        "geschlossen_am = now()",
        "prueffrist_bis = now()",
    ],
)
async def test_R3_F_001_ausloeser_haelt_einen_abgeschlossenen_fall_unveraenderlich(
    aenderung: str,
    eroeffneter_fall: "EroeffneterFall",
    verbindung_anwendung: AsyncConnection,
) -> None:
    from r3cosint.fall.service import schliessen

    async with verbindung_anwendung.begin():
        await schliessen(
            verbindung_anwendung,
            fall_kennung=eroeffneter_fall.fall.kennung,
            person_kennung="test.ermittlung",
            uhr=eroeffneter_fall.uhr,
        )
    sqlstate, _ = await _sqlstate_und_text(
        verbindung_anwendung,
        f"UPDATE r3cosint.fall SET {aenderung} WHERE kennung = CAST(:k AS uuid)",  # noqa: S608
        k=str(eroeffneter_fall.fall.kennung),
    )
    assert sqlstate == "P0001"
    await _aktenzeichen_bleibt_belegt(eroeffneter_fall, verbindung_anwendung)


async def test_R3_F_001_der_eigentuemer_bleibt_vom_ausloeser_ausgenommen_und_der_ausloeser_ist_aktiv(
    verbindung_eigentuemer: AsyncConnection,
) -> None:
    v = verbindung_eigentuemer
    await v.execute(
        text(_FALL_INSERT),
        {
            "k": str(UUID(int=22)),
            "zustand": "abgeschlossen",
            "zu": "2099-01-02T00:00:00+00",
            "pf": "2100-01-02T00:00:00+00",
        },
    )
    await v.commit()
    zeile = (
        await v.execute(
            text(
                "SELECT t.tgenabled::text, p.prosecdef, "
                "has_function_privilege('r3cosint_anwendung', p.oid, 'EXECUTE'), "
                "has_function_privilege('public', p.oid, 'EXECUTE') "
                "FROM pg_trigger t JOIN pg_proc p ON p.oid = t.tgfoid "
                "WHERE t.tgname = 'fall_uebergang'"
            )
        )
    ).one()
    assert tuple(zeile) == ("O", False, False, False)


async def _vorrat(v: AsyncConnection, name: str) -> set[str]:
    definition = (
        await v.execute(
            text(
                "SELECT pg_get_constraintdef(c.oid) FROM pg_constraint c "
                "JOIN pg_namespace n ON n.oid = c.connamespace "
                "WHERE n.nspname = 'r3cosint' AND c.conname = :name"
            ),
            {"name": name},
        )
    ).scalar_one()
    return set(re.findall(r"'([a-z0-9_A-Z]+)'", definition))


async def test_R3_F_001_die_strenum_vorraete_gleichen_den_pruefbedingungen_im_katalog(
    verbindung_eigentuemer: AsyncConnection,
) -> None:
    assert await _vorrat(verbindung_eigentuemer, "fall_rechtsregime_vorrat") == {
        r.value for r in Rechtsregime
    }
    assert await _vorrat(verbindung_eigentuemer, "fall_zustand_vorrat") == {
        z.value for z in Fallzustand
    }
