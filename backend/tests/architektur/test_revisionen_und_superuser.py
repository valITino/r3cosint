"""Architekturtest: gemeinsamer Text der Revisionen und Superuser nur über manipulieren
(ADR 0007, Festlegung S1.2, Zeilen "Gemeinsamer Text der Revisionen" und "Fixture und Teststufe"; R3-F-008).
"""

import ast
from pathlib import Path

import pytest

TESTS = Path(__file__).resolve().parents[1]
REVISIONEN = sorted(
    p for p in (TESTS.parent / "migrationen" / "versionen").glob("[0-9]*.py")
)
# Ausnahmen aus S1.1, im Test benannt: die Prüfungen der Teststufe selbst.
AUSNAHMEN = {"test_grundeinrichtung.py", "test_teststufe.py"}
VERBOTENE_NAMEN = {
    "SUPERUSER",
    "passwort_dateien",
    "passwoerter",
    "verbindung_superuser",
}
VERBOTENE_ZEICHENKETTEN = ("r3cosint_test", "session_replication_role")


def _funktion(datei: Path, name: str) -> ast.AST:
    baum = ast.parse(datei.read_text(encoding="utf-8"))
    treffer = [
        k for k in baum.body if isinstance(k, ast.FunctionDef) and k.name == name
    ]
    assert len(treffer) == 1, datei.name
    return treffer[0]


def test_R3_F_008_es_gibt_mindestens_drei_revisionen() -> None:
    assert len(REVISIONEN) >= 3


@pytest.mark.parametrize("datei", REVISIONEN[1:], ids=lambda d: d.name)
def test_R3_F_008_sql_als_ganzes_ist_in_allen_revisionen_gleich(datei: Path) -> None:
    erste = ast.dump(_funktion(REVISIONEN[0], "_sql_als_ganzes"))
    assert ast.dump(_funktion(datei, "_sql_als_ganzes")) == erste


def _tests_unter_integration_und_abnahme() -> list[Path]:
    return sorted(
        p
        for ordner in ("integration", "abnahme")
        for p in (TESTS / ordner).glob("*.py")
        if p.name not in AUSNAHMEN
    )


def test_R3_F_008_der_gegenstand_ist_nicht_leer() -> None:
    assert len(_tests_unter_integration_und_abnahme()) >= 4


@pytest.mark.parametrize(
    "datei", _tests_unter_integration_und_abnahme(), ids=lambda d: d.name
)
def test_R3_F_008_kein_test_hat_einen_eigenen_zugang_des_superusers(
    datei: Path,
) -> None:
    baum = ast.parse(datei.read_text(encoding="utf-8"))
    namen = {k.id for k in ast.walk(baum) if isinstance(k, ast.Name)}
    namen |= {k.attr for k in ast.walk(baum) if isinstance(k, ast.Attribute)}
    namen |= {
        a.arg
        for k in ast.walk(baum)
        if isinstance(k, ast.arguments)
        for a in k.args + k.kwonlyargs
    }
    zeichenketten = [
        k.value
        for k in ast.walk(baum)
        if isinstance(k, ast.Constant) and isinstance(k.value, str)
    ]
    assert namen & VERBOTENE_NAMEN == set()
    for verboten in VERBOTENE_ZEICHENKETTEN:
        assert not any(verboten in z for z in zeichenketten), verboten
