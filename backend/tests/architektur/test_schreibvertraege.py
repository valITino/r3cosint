"""Architekturtest: Texttest zu den Schreibverträgen 4 und 8 (ADR 0007, Verträge; R3-F-008, R3-F-001).

import-linter prüft Importe, keine SQL-Ziele. Dieser Test ergänzt Vertrag 4 und 8 um die
Zeichenkettenkonstanten: ausserhalb von spur (beziehungsweise fall) steht kein Tabellenname dieses
Pakets als ganzes Wort in einer Zeichenkette (Docstrings ausgenommen). Bezeichner wie
Spur.ARBEITSSPUR sind keine Zeichenketten und bleiben frei. backend/migrationen und
backend/tests sind nicht Gegenstand.
"""

import ast
import re
from pathlib import Path

import pytest

WURZEL = Path(__file__).resolve().parents[2] / "src" / "r3cosint"

VERTRAEGE = {
    "spur": ("ermittlungsspur", "arbeitsspur", "kettenkopf"),
    "fall": ("fall_schluessel", "fallkategorie"),
}


def zeichenketten(quelle: str) -> list[str]:
    """Alle Zeichenkettenkonstanten (auch Teile von f-Strings und Bytes) ohne Docstrings."""
    baum = ast.parse(quelle)
    docstrings: set[int] = set()
    for knoten in ast.walk(baum):
        if isinstance(
            knoten, ast.Module | ast.ClassDef | ast.FunctionDef | ast.AsyncFunctionDef
        ):
            if (
                knoten.body
                and isinstance(knoten.body[0], ast.Expr)
                and isinstance(knoten.body[0].value, ast.Constant)
            ):
                docstrings.add(id(knoten.body[0].value))
    texte: list[str] = []
    for knoten in ast.walk(baum):
        if isinstance(knoten, ast.Constant) and id(knoten) not in docstrings:
            if isinstance(knoten.value, str):
                texte.append(knoten.value)
            elif isinstance(knoten.value, bytes):
                texte.append(knoten.value.decode("utf-8", errors="replace"))
    return texte


def treffer(quelle: str, namen: tuple[str, ...]) -> list[str]:
    muster = re.compile(
        r"(?<![A-Za-z0-9_])(" + "|".join(namen) + r")(?![A-Za-z0-9_])", re.IGNORECASE
    )
    return [t for t in zeichenketten(quelle) if muster.search(t)]


def _dateien_ausserhalb(paket: str) -> list[Path]:
    return sorted(
        p for p in WURZEL.rglob("*.py") if p.relative_to(WURZEL).parts[0] != paket
    )


@pytest.mark.parametrize(("paket", "namen"), list(VERTRAEGE.items()))
def test_R3_F_008_ausserhalb_des_pakets_steht_kein_tabellenname_in_einer_zeichenkette(
    paket: str, namen: tuple[str, ...]
) -> None:
    gefunden = {
        p.relative_to(WURZEL).as_posix(): treffer(p.read_text(encoding="utf-8"), namen)
        for p in _dateien_ausserhalb(paket)
    }
    assert {k: v for k, v in gefunden.items() if v} == {}


def test_R3_F_008_der_gegenstand_ist_nicht_leer() -> None:
    assert _dateien_ausserhalb("spur")
    assert _dateien_ausserhalb("fall")
    assert all(
        "spur" not in p.relative_to(WURZEL).parts[:1]
        for p in _dateien_ausserhalb("spur")
    )


@pytest.mark.parametrize(
    "quelle",
    [
        'x = "insert into arbeitsspur (a) values (1)"',
        "x = f'select * from {t} join Kettenkopf on 1'",
        'x = b"DELETE FROM ermittlungsspur"',
        'x = ("a", "kettenkopf")',
    ],
)
def test_R3_F_008_der_texttest_findet_tabellennamen_in_allen_formen(
    quelle: str,
) -> None:
    assert treffer(quelle, VERTRAEGE["spur"])


@pytest.mark.parametrize(
    "quelle",
    [
        '"""Docstring mit arbeitsspur."""\nx = 1',
        "def f():\n    '''kettenkopf im Docstring'''\n    return 1",
        "x = Spur.ARBEITSSPUR",
        'x = "arbeitsspur_neu"',
        'x = "meinkettenkopf"',
    ],
)
def test_R3_F_008_der_texttest_ignoriert_docstrings_bezeichner_und_wortteile(
    quelle: str,
) -> None:
    assert treffer(quelle, VERTRAEGE["spur"]) == []
