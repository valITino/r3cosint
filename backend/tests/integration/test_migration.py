"""Integrationstest: Migrationen gegen PostgreSQL (ADR 0007, Entscheid 4, 7 und 11; R3-F-008).

Geprüft werden das Namensschema und die Linearität der Revisionen (ohne Datenbank), der
Lauf von leer bis Kopf, zurück und wieder vor, der Vergleich des Schemas mit den
Table-Objekten über Alembic und das Standardrecht aus Revision 0001.
"""

import re
from collections.abc import Awaitable, Callable
from pathlib import Path
from typing import TYPE_CHECKING

import pytest
from alembic.script import ScriptDirectory
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncConnection

from r3cosint.core.datenbank import engine_erzeugen
from r3cosint.core.konfiguration import Datenbankverbindung

if TYPE_CHECKING:
    from conftest import Testdatenbank

pytestmark = pytest.mark.anyio

MIGRATIONEN = Path(__file__).resolve().parents[2] / "migrationen"
KOPF = "0003"
AlembicBefehl = Callable[[Datenbankverbindung, str, str | None], Awaitable[None]]


def _skripte() -> ScriptDirectory:
    from alembic.config import Config

    konfiguration = Config()
    konfiguration.set_main_option("script_location", str(MIGRATIONEN))
    konfiguration.set_main_option("path_separator", "os")
    konfiguration.set_main_option("version_locations", str(MIGRATIONEN / "versionen"))
    return ScriptDirectory.from_config(konfiguration)


def test_R3_F_008_revisionen_haben_ein_vierstelliges_fortlaufendes_namensschema() -> (
    None
):
    revisionen = list(_skripte().walk_revisions())
    nummern = sorted(revision.revision for revision in revisionen)
    assert nummern == [f"{n:04d}" for n in range(1, len(revisionen) + 1)]
    dateien = sorted(
        p.name
        for p in (MIGRATIONEN / "versionen").glob("*.py")
        if p.name != "__init__.py"
    )
    assert len(dateien) == len(revisionen)
    for datei in dateien:
        assert re.fullmatch(r"\d{4}_[a-z0-9_]+\.py", datei), datei


def test_R3_F_008_revisionen_sind_linear_mit_einem_kopf() -> None:
    skripte = _skripte()
    assert len(skripte.get_heads()) == 1
    revisionen = list(skripte.walk_revisions())
    wurzeln = [r for r in revisionen if r.down_revision is None]
    assert len(wurzeln) == 1
    assert wurzeln[0].revision == "0001"
    for revision in revisionen:
        assert revision.down_revision is None or isinstance(revision.down_revision, str)
        assert revision.branch_labels == set()
        assert revision.dependencies is None
    nummer = {r.revision: int(r.revision) for r in revisionen}
    for revision in revisionen:
        if isinstance(revision.down_revision, str):
            assert nummer[revision.down_revision] == nummer[revision.revision] - 1


def test_R3_F_008_sql_dateien_folgen_dem_namensschema() -> None:
    namen = sorted(p.name for p in (MIGRATIONEN / "sql").iterdir())
    for name in namen:
        assert re.fullmatch(r"(\d{4}_[a-z0-9_]+|rollen_und_schema)\.sql", name), name
    revisionsnamen = {
        p.stem
        for p in (MIGRATIONEN / "versionen").glob("*.py")
        if p.name != "__init__.py"
    }
    for revisionsname in revisionsnamen:
        assert f"{revisionsname}.sql" in namen, revisionsname


async def _version(verbindung: AsyncConnection) -> list[str]:
    zeilen = await verbindung.execute(
        text("SELECT version_num FROM r3cosint.alembic_version")
    )
    return [zeile[0] for zeile in zeilen]


async def _ausfuehrbar(verbindung: AsyncConnection, funktion: str) -> bool:
    ergebnis = await verbindung.execute(
        text(
            "SELECT has_function_privilege('r3cosint_anwendung', "
            f"'r3cosint.{funktion}()'::regprocedure, 'EXECUTE')"
        )
    )
    return bool(ergebnis.scalar_one())


async def _funktion_anlegen(verbindung: AsyncConnection, name: str) -> None:
    await verbindung.execute(
        text(
            f"CREATE FUNCTION r3cosint.{name}() RETURNS integer LANGUAGE sql AS 'SELECT 1'"
        )
    )
    await verbindung.commit()


async def test_R3_F_008_die_vorlage_steht_auf_dem_kopf(
    verbindung_eigentuemer: AsyncConnection,
) -> None:
    assert await _version(verbindung_eigentuemer) == [_skripte().get_current_head()]


async def test_R3_F_008_migration_von_leer_bis_0002_zurueck_und_wieder_vor_bis_kopf(
    datenbank_bei_0002: "Testdatenbank", alembic_befehl: AlembicBefehl
) -> None:
    eigentuemer = datenbank_bei_0002.verbindung("r3cosint_eigentuemer")
    engine = engine_erzeugen(eigentuemer)
    try:
        async with engine.connect() as verbindung:
            assert await _version(verbindung) == ["0002"]
            await verbindung.rollback()

            await alembic_befehl(eigentuemer, "downgrade", "base")
            assert await _version(verbindung) == []
            assert await _tabellen(verbindung) == ["alembic_version"]
            await verbindung.rollback()
            await _funktion_anlegen(verbindung, "zurueck")
            assert await _ausfuehrbar(verbindung, "zurueck")
            await verbindung.rollback()

            await alembic_befehl(eigentuemer, "upgrade", "0002")
            assert await _version(verbindung) == ["0002"]
            assert await _tabellen(verbindung) == [
                "alembic_version",
                "fall",
                "fall_schluessel",
                "fallkategorie",
            ]
            await verbindung.rollback()

            await alembic_befehl(eigentuemer, "upgrade", "head")
            assert await _version(verbindung) == ["0003"]
            await verbindung.rollback()
            await _funktion_anlegen(verbindung, "wieder_vor")
            assert not await _ausfuehrbar(verbindung, "wieder_vor")
    finally:
        await engine.dispose()


async def _tabellen(verbindung: AsyncConnection) -> list[str]:
    zeilen = await verbindung.execute(
        text(
            "SELECT tablename FROM pg_tables WHERE schemaname = 'r3cosint' "
            "ORDER BY tablename"
        )
    )
    return [zeile[0] for zeile in zeilen]


async def test_R3_F_008_downgrade_von_0003_endet_mit_der_meldung_version_und_tabellen_bleiben(
    datenbank: "Testdatenbank",
    verbindung_eigentuemer: AsyncConnection,
    alembic_befehl: AlembicBefehl,
) -> None:
    vorher = await _tabellen(verbindung_eigentuemer)
    await verbindung_eigentuemer.rollback()
    with pytest.raises(
        RuntimeError, match=r"Revision 0003 hat keinen R.ckweg"
    ) as fehler:
        await alembic_befehl(
            datenbank.verbindung("r3cosint_eigentuemer"), "downgrade", "0002"
        )
    assert "E-S1-04 b" in str(fehler.value)
    assert "ausschliesslich anfügbar" in str(fehler.value)
    assert await _version(verbindung_eigentuemer) == ["0003"]
    assert await _tabellen(verbindung_eigentuemer) == vorher
    assert {"arbeitsspur", "ermittlungsspur", "kettenkopf"} <= set(vorher)


async def test_R3_F_008_ein_zweiter_lauf_bis_kopf_aendert_nichts(
    datenbank: "Testdatenbank",
    verbindung_eigentuemer: AsyncConnection,
    alembic_befehl: AlembicBefehl,
) -> None:
    assert await _version(verbindung_eigentuemer) == [KOPF]
    await verbindung_eigentuemer.rollback()
    eigentuemer = datenbank.verbindung("r3cosint_eigentuemer")
    await alembic_befehl(eigentuemer, "upgrade", "head")
    assert await _version(verbindung_eigentuemer) == [KOPF]
    await alembic_befehl(eigentuemer, "check", None)


async def test_R3_F_008_das_schema_entspricht_den_table_objekten(
    datenbank: "Testdatenbank", alembic_befehl: AlembicBefehl
) -> None:
    # command.check wirft CommandError, sobald der Vergleich einen Unterschied findet.
    await alembic_befehl(datenbank.verbindung("r3cosint_eigentuemer"), "check", None)


async def test_R3_F_008_der_vergleich_findet_eine_fremde_tabelle_im_schema_nicht_im_bestand(
    datenbank: "Testdatenbank",
    verbindung_eigentuemer: AsyncConnection,
    alembic_befehl: AlembicBefehl,
) -> None:
    # Gegenprobe: ohne Table-Objekt ist eine Tabelle im Schema r3cosint ein Unterschied.
    from alembic.util.exc import CommandError

    await verbindung_eigentuemer.execute(
        text("CREATE TABLE r3cosint.fremd (x integer)")
    )
    await verbindung_eigentuemer.commit()
    with pytest.raises(CommandError):
        await alembic_befehl(
            datenbank.verbindung("r3cosint_eigentuemer"), "check", None
        )


async def test_R3_F_008_das_standardrecht_execute_ist_fuer_public_entzogen(
    verbindung_eigentuemer: AsyncConnection,
) -> None:
    await _funktion_anlegen(verbindung_eigentuemer, "ohne_grant")
    assert not await _ausfuehrbar(verbindung_eigentuemer, "ohne_grant")


async def test_R3_F_008_ohne_grant_ist_die_funktion_fuer_anwendung_nicht_aufrufbar(
    verbindung_eigentuemer: AsyncConnection, verbindung_anwendung: AsyncConnection
) -> None:
    from sqlalchemy.exc import ProgrammingError

    await _funktion_anlegen(verbindung_eigentuemer, "nicht_aufrufbar")
    with pytest.raises(ProgrammingError, match="permission denied"):
        await verbindung_anwendung.execute(text("SELECT r3cosint.nicht_aufrufbar()"))
    await verbindung_anwendung.rollback()
    await verbindung_eigentuemer.execute(
        text(
            "GRANT EXECUTE ON FUNCTION r3cosint.nicht_aufrufbar() TO r3cosint_anwendung"
        )
    )
    await verbindung_eigentuemer.commit()
    ergebnis = await verbindung_anwendung.execute(
        text("SELECT r3cosint.nicht_aufrufbar()")
    )
    assert ergebnis.scalar_one() == 1
