"""Integrationstest: Fall, Fallkategorie und Fallschlüssel (ADR 0007, Nr. 22, Festlegung S1.2; R3-F-001, R3-F-008)."""

from typing import Any
from uuid import UUID

import pytest
from sqlalchemy import text
from sqlalchemy.exc import DBAPIError
from sqlalchemy.ext.asyncio import AsyncConnection

pytestmark = pytest.mark.anyio

STARTWERTE = {
    "nichtanhandnahme_einstellung": (12, None),
    "uebertretung": (36, None),
    "vergehen": (84, None),
    "freiheitsstrafe_bis_3_jahre": (120, None),
    "verbrechen_ueber_3_jahre": (180, None),
    "lebenslaenglich": (360, None),
    "unverjaehrbar": (60, 60),
}
FALL = (
    "INSERT INTO r3cosint.fall (kennung, aktenzeichen, ermittelnde_person, rechtsgrundlage, "
    "rechtsregime, fallkategorie, zustand, eroeffnet_am, geschlossen_am, prueffrist_bis) VALUES "
    "(CAST(:k AS uuid), :az, :person, :rg, :regime, :kat, :zustand, "
    "CAST('2026-01-01T00:00:00+00' AS timestamptz), "
    "CAST(CAST(:zu AS text) AS timestamptz), CAST(CAST(:pf AS text) AS timestamptz))"
)
GUELTIG: dict[str, Any] = {
    "az": "TEST-SYNTH-A",
    "person": "test.ermittlung",
    "rg": "synthetisch",
    "regime": "R1",
    "kat": "vergehen",
    "zustand": "aktiv",
    "zu": None,
    "pf": None,
}


def _sqlstate(fehler: BaseException) -> str:
    orig = getattr(fehler, "orig", None)
    zustand = getattr(orig, "sqlstate", None) or getattr(orig, "pgcode", None)
    assert isinstance(zustand, str)
    return zustand


async def _fall(verbindung: AsyncConnection, nr: int, **aenderung: Any) -> str | None:
    """Fügt einen Fall ein; liefert None bei Erfolg, sonst den SQLSTATE."""
    parameter = {**GUELTIG, "k": str(UUID(int=nr)), **aenderung}
    try:
        await verbindung.execute(text(FALL), parameter)
    except DBAPIError as fehler:
        await verbindung.rollback()
        return _sqlstate(fehler)
    await verbindung.rollback()
    return None


async def test_R3_F_001_die_startwerte_der_sieben_fallkategorien_stehen_in_der_datenbank(
    verbindung_anwendung: AsyncConnection,
) -> None:
    zeilen = (
        await verbindung_anwendung.execute(
            text(
                "SELECT kennung, erste_pruefung_monate, folgepruefung_monate, bezeichnung "
                "FROM r3cosint.fallkategorie"
            )
        )
    ).all()
    assert {
        z.kennung: (z.erste_pruefung_monate, z.folgepruefung_monate) for z in zeilen
    } == STARTWERTE
    assert all(z.bezeichnung.strip() for z in zeilen)
    kommentar = (
        await verbindung_anwendung.execute(
            text("SELECT obj_description('r3cosint.fallkategorie'::regclass)")
        )
    ).scalar_one()
    assert "Vorschlag zur Bestätigung" in kommentar


@pytest.mark.parametrize(
    ("aenderung", "erwartet"),
    [
        ({}, None),
        ({"regime": "R3"}, "23514"),
        ({"zustand": "unbekannt"}, "23514"),
        ({"kat": "gibt_es_nicht"}, "23503"),
        ({"az": "  "}, "23514"),
        ({"az": None}, "23514"),
        ({"person": ""}, "23514"),
        ({"rg": None}, "23514"),
        (
            {
                "zustand": "geloescht",
                "az": None,
                "person": None,
                "rg": None,
                "zu": "2026-02-01T00:00:00+00",
                "pf": "2026-03-01T00:00:00+00",
            },
            None,
        ),
        ({"zu": "2026-02-01T00:00:00+00", "pf": "2026-03-01T00:00:00+00"}, "23514"),
        ({"zustand": "abgeschlossen"}, "23514"),
        ({"zustand": "abgeschlossen", "zu": "2026-02-01T00:00:00+00"}, "23514"),
        (
            {
                "zustand": "abgeschlossen",
                "zu": "2025-12-31T00:00:00+00",
                "pf": "2026-03-01T00:00:00+00",
            },
            "23514",
        ),
        (
            {
                "zustand": "abgeschlossen",
                "zu": "2026-02-01T00:00:00+00",
                "pf": "2026-01-31T00:00:00+00",
            },
            "23514",
        ),
        (
            {
                "zustand": "abgeschlossen",
                "zu": "2026-02-01T00:00:00+00",
                "pf": "2033-02-01T00:00:00+00",
            },
            None,
        ),
    ],
    ids=[
        "gueltig",
        "regime",
        "zustand",
        "kategorie",
        "aktenzeichen_leer",
        "aktenzeichen_null",
        "person_leer",
        "grundlage_null",
        "geloescht_ohne_falldaten",
        "aktiv_mit_schliessung",
        "abgeschlossen_ohne_zeiten",
        "abgeschlossen_ohne_frist",
        "schliessung_vor_eroeffnung",
        "frist_vor_schliessung",
        "abgeschlossen_gueltig",
    ],
)
async def test_R3_F_001_pruefbedingungen_von_fall(
    verbindung_eigentuemer: AsyncConnection,
    aenderung: dict[str, Any],
    erwartet: str | None,
) -> None:
    assert await _fall(verbindung_eigentuemer, 1, **aenderung) == erwartet


async def test_R3_F_001_das_aktenzeichen_ist_eindeutig_ausser_nach_dem_loeschen(
    verbindung_eigentuemer: AsyncConnection,
) -> None:
    await verbindung_eigentuemer.execute(text(FALL), {**GUELTIG, "k": str(UUID(int=1))})
    zweiter = {**GUELTIG, "k": str(UUID(int=2))}
    with pytest.raises(DBAPIError) as fehler:
        await verbindung_eigentuemer.execute(text(FALL), zweiter)
    assert _sqlstate(fehler.value) == "23505"
    await verbindung_eigentuemer.rollback()
    await verbindung_eigentuemer.execute(text(FALL), {**GUELTIG, "k": str(UUID(int=1))})
    geloescht = {
        **zweiter,
        "zustand": "geloescht",
        "zu": "2026-02-01T00:00:00+00",
        "pf": "2026-03-01T00:00:00+00",
    }
    await verbindung_eigentuemer.execute(text(FALL), geloescht)
    await verbindung_eigentuemer.rollback()
    indexdef = (
        await verbindung_eigentuemer.execute(
            text(
                "SELECT indexdef FROM pg_indexes WHERE indexname = 'fall_aktenzeichen_eindeutig'"
            )
        )
    ).scalar_one()
    assert "WHERE" in indexdef
    assert "geloescht" in indexdef


async def test_R3_F_001_fallschluessel_hat_genau_32_bytes_und_die_anwendung_darf_nichts_aendern(
    fall_mit_ketten: Any,
    verbindung_eigentuemer: AsyncConnection,
    verbindung_anwendung: AsyncConnection,
) -> None:
    kennung = str(fall_mit_ketten.kennung)
    laenge = (
        await verbindung_eigentuemer.execute(
            text(
                "SELECT octet_length(schluessel) FROM r3cosint.fall_schluessel "
                "WHERE fall_kennung = CAST(:k AS uuid)"
            ),
            {"k": kennung},
        )
    ).scalar_one()
    assert laenge == 32
    await verbindung_eigentuemer.rollback()
    with pytest.raises(DBAPIError) as fehler:
        await verbindung_eigentuemer.execute(
            text(
                "UPDATE r3cosint.fall_schluessel SET schluessel = CAST('\\x00' AS bytea) "
                "WHERE fall_kennung = CAST(:k AS uuid)"
            ),
            {"k": kennung},
        )
    assert _sqlstate(fehler.value) == "23514"
    await verbindung_eigentuemer.rollback()
    for sql in (
        "UPDATE r3cosint.fall_schluessel SET schluessel = schluessel",
        "DELETE FROM r3cosint.fall_schluessel",
        "UPDATE r3cosint.fall SET aktenzeichen = 'x'",
        "DELETE FROM r3cosint.fall",
        "UPDATE r3cosint.fallkategorie SET bezeichnung = 'x'",
    ):
        with pytest.raises(DBAPIError) as abgewiesen:
            await verbindung_anwendung.execute(text(sql))
        assert _sqlstate(abgewiesen.value) == "42501", sql
        await verbindung_anwendung.rollback()


async def test_R3_F_001_die_anwendung_darf_zustand_und_fristen_fortschreiben(
    fall_mit_ketten: Any, verbindung_anwendung: AsyncConnection
) -> None:
    ergebnis = await verbindung_anwendung.execute(
        text(
            "UPDATE r3cosint.fall SET zustand = 'abgeschlossen', "
            "geschlossen_am = CAST('2026-02-01T00:00:00+00' AS timestamptz), "
            "prueffrist_bis = CAST('2033-02-01T00:00:00+00' AS timestamptz) "
            "WHERE kennung = CAST(:k AS uuid)"
        ),
        {"k": str(fall_mit_ketten.kennung)},
    )
    assert ergebnis.rowcount == 1
    await verbindung_anwendung.rollback()
