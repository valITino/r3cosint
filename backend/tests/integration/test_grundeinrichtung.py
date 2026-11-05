"""Integrationstest: die Grundeinrichtung rollen_und_schema.sql (ADR 0007, Entscheid 7; R3-F-008).

Geprüft wird, was unmittelbar nach dem Skript gilt (nicht, was die Fixture je Test neu setzt):
die Rechte der Datenbank, die geleerten Sitzungswerte der Passwörter und ein Fehler des
Skripts ohne Passwort in der Meldung.
"""

from collections.abc import Awaitable, Callable
from pathlib import Path
from typing import TYPE_CHECKING

import pytest
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncConnection

from r3cosint.core.datenbank import engine_erzeugen

if TYPE_CHECKING:
    from conftest import PostgresInstanz, Testdatenbank

SKRIPT = (
    Path(__file__).resolve().parents[2]
    / "migrationen"
    / "sql"
    / "rollen_und_schema.sql"
)


@pytest.mark.anyio
async def test_R3_F_008_die_vorlage_traegt_nach_der_grundeinrichtung_die_rechte_der_datenbank(
    postgres_instanz: "PostgresInstanz",
) -> None:
    engine = engine_erzeugen(
        postgres_instanz.verbindung("r3cosint_test", "r3cosint_test")
    )
    try:
        async with engine.connect() as verbindung:
            fuer_public = await verbindung.execute(
                text(
                    "SELECT count(*) FROM pg_database d, "
                    "aclexplode(coalesce(d.datacl, acldefault('d', d.datdba))) a "
                    "WHERE d.datname = 'vorlage' AND a.grantee = 0"
                )
            )
            assert fuer_public.scalar_one() == 0
            for rolle in ("r3cosint_eigentuemer", "r3cosint_anwendung"):
                recht = await verbindung.execute(
                    text("SELECT has_database_privilege(:rolle, 'vorlage', 'CONNECT')"),
                    {"rolle": rolle},
                )
                assert recht.scalar_one() is True, rolle
    finally:
        await engine.dispose()


def test_R3_F_008_die_sitzungswerte_der_passwoerter_sind_nach_der_grundeinrichtung_leer(
    postgres_instanz: "PostgresInstanz",
) -> None:
    assert postgres_instanz.sitzungswerte == {
        "passwort_eigentuemer": "",
        "passwort_anwendung": "",
    }


def _meldungen(fehler: BaseException) -> str:
    """Sammelt alles, was ein Fehler und seine Ursachen an Text tragen, auch den Kontext."""
    teile: list[str] = []
    aktuell: BaseException | None = fehler
    while aktuell is not None:
        teile += [str(aktuell), repr(aktuell)]
        urspruenglich = getattr(aktuell, "orig", None)
        if urspruenglich is not None:
            teile += [str(urspruenglich), repr(urspruenglich)]
            if hasattr(urspruenglich, "as_dict"):
                teile.append(str(urspruenglich.as_dict()))
        aktuell = aktuell.__cause__
    return "\n".join(teile)


@pytest.mark.anyio
async def test_R3_F_008_ein_zweiter_lauf_der_grundeinrichtung_scheitert_ohne_passwort_im_text(
    datenbank: "Testdatenbank",
    sql_als_ganzes: Callable[[AsyncConnection, str], Awaitable[None]],
) -> None:
    passwoerter = datenbank.instanz.passwoerter
    engine = engine_erzeugen(datenbank.verbindung("r3cosint_test"))
    try:
        async with engine.connect() as verbindung:
            verbindung = await verbindung.execution_options(
                isolation_level="AUTOCOMMIT"
            )
            for schluessel, rolle in (
                ("passwort_eigentuemer", "r3cosint_eigentuemer"),
                ("passwort_anwendung", "r3cosint_anwendung"),
            ):
                await verbindung.execute(
                    text("SELECT set_config(:name, :wert, false)"),
                    {"name": f"r3cosint.{schluessel}", "wert": passwoerter[rolle]},
                )
            # Der Text läuft am Treiber vorbei an SQLAlchemy: der Fehler ist der des Treibers.
            with pytest.raises(Exception, match="SQLSTATE") as ausnahme:
                await sql_als_ganzes(verbindung, SKRIPT.read_text(encoding="utf-8"))
    finally:
        await engine.dispose()
    meldung = _meldungen(ausnahme.value)
    assert "r3cosint_eigentuemer" in meldung
    assert "42710" in meldung  # SQLSTATE duplicate_object: die Rolle besteht schon
    for geheimnis in passwoerter.values():
        enthalten = geheimnis in meldung
        assert not enthalten, "ein Passwort steht im Fehlertext der Grundeinrichtung"
