"""Architekturtest: Datenzugriff und Migrationen (ADR 0007, Entscheid 1, 4, 8 und Vertrag 10; R3-F-008).

Ergänzt Vertrag 10 (D18) um das, was ein Importvertrag nicht sieht: Revisionen liegen
ausserhalb des Pakets r3cosint und importieren dennoch nichts daraus; unter backend/src gibt
es keinen Aufruf von create_all (das Schema entsteht allein durch Revisionen); es gibt keine
alembic.ini; das Passwort der Datenbank kommt nie aus einer Variablen.
"""

import ast
import re
from pathlib import Path

import pytest

BACKEND = Path(__file__).resolve().parents[2]
QUELLE = BACKEND / "src" / "r3cosint"
MIGRATIONEN = BACKEND / "migrationen"
REVISIONEN = sorted(
    p for p in (MIGRATIONEN / "versionen").glob("*.py") if p.name != "__init__.py"
)


def _importierte_module(datei: Path) -> list[str]:
    baum = ast.parse(datei.read_text(encoding="utf-8"), filename=str(datei))
    module: list[str] = []
    for knoten in ast.walk(baum):
        if isinstance(knoten, ast.Import):
            module += [alias.name for alias in knoten.names]
        elif isinstance(knoten, ast.ImportFrom):
            module.append(("." * knoten.level) + (knoten.module or ""))
    return module


def _ist_aus_r3cosint(modul: str) -> bool:
    return modul == "r3cosint" or modul.startswith("r3cosint.") or modul.startswith(".")


def test_R3_F_008_es_gibt_mindestens_eine_revision() -> None:
    assert REVISIONEN


@pytest.mark.parametrize("datei", REVISIONEN, ids=lambda d: d.name)
def test_R3_F_008_revisionen_importieren_nichts_aus_r3cosint(datei: Path) -> None:
    fremd = [m for m in _importierte_module(datei) if _ist_aus_r3cosint(m)]
    assert fremd == []


def test_R3_F_008_env_py_importiert_aus_r3cosint_allein_core_und_die_tables_von_fall_spur_und_kanon() -> (
    None
):
    aus_r3cosint = [
        m for m in _importierte_module(MIGRATIONEN / "env.py") if _ist_aus_r3cosint(m)
    ]
    assert aus_r3cosint  # env.py baut die Engine aus der Konfiguration von core
    # Ab S1.2 auch die MetaData von fall und spur, ab S1.4 die von kanon für den Vergleich
    # (target_metadata).
    erlaubt = (
        "r3cosint.core.",
        "r3cosint.fall.tables",
        "r3cosint.spur.tables",
        "r3cosint.kanon.tables",
    )
    assert all(m.startswith(erlaubt) for m in aus_r3cosint), aus_r3cosint


def test_R3_F_008_unter_backend_src_gibt_es_keinen_aufruf_von_create_all() -> None:
    treffer = [
        p.relative_to(BACKEND).as_posix()
        for p in QUELLE.rglob("*.py")
        if "create_all" in p.read_text(encoding="utf-8")
    ]
    assert treffer == []


def test_R3_F_008_es_gibt_keine_alembic_ini() -> None:
    assert (
        sorted(
            p.relative_to(BACKEND).as_posix()
            for p in BACKEND.rglob("alembic.ini")
            if ".venv" not in p.parts
        )
        == []
    )


def test_R3_F_008_das_passwort_der_datenbank_kommt_nie_aus_einer_variablen() -> None:
    muster = re.compile(r"R3COSINT_DB_PASSWORT(?!_DATEI)")
    treffer = [
        p.relative_to(BACKEND).as_posix()
        for p in QUELLE.rglob("*.py")
        if muster.search(p.read_text(encoding="utf-8"))
    ]
    assert treffer == []


def test_R3_F_008_unter_backend_src_steht_kein_unmittelbarer_import_von_asyncpg_oder_alembic() -> (
    None
):
    # Vertrag 10 prüft das in D18; hier der Text als zweite, vom Werkzeug unabhängige Probe.
    treffer = [
        (p.relative_to(BACKEND).as_posix(), m)
        for p in QUELLE.rglob("*.py")
        for m in _importierte_module(p)
        if m.split(".")[0] in {"asyncpg", "alembic"}
    ]
    assert treffer == []
