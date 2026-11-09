"""Architekturtest: Zeit, Fristwerte und Zufall im Paket fall (ADR 0007, S1.3; R3-F-001).

Die Zeit kommt allein aus der übergebenen Uhr (Nr. 23), die Frist allein aus der Tabelle
fallkategorie, der Fallschlüssel allein aus secrets.token_bytes in fall.service.
"""

import ast
from pathlib import Path

import pytest

WURZEL = Path(__file__).resolve().parents[2] / "src" / "r3cosint"
FALL = sorted((WURZEL / "fall").glob("*.py"))
STARTWERTE = {12, 36, 60, 84, 120, 180, 360}
ZEITAUFRUFE = {"now", "utcnow", "today", "time", "monotonic", "time_ns"}


def _baum(pfad: Path) -> ast.AST:
    return ast.parse(pfad.read_text(encoding="utf-8"))


@pytest.mark.parametrize("pfad", FALL, ids=lambda p: p.name)
def test_R3_F_001_fall_liest_die_systemzeit_nicht(pfad: Path) -> None:
    for knoten in ast.walk(_baum(pfad)):
        if isinstance(knoten, ast.Call) and isinstance(knoten.func, ast.Attribute):
            ziel = knoten.func.value
            name = ziel.id if isinstance(ziel, ast.Name) else ""
            assert not (
                knoten.func.attr in ZEITAUFRUFE and name in {"datetime", "date", "time"}
            ), f"{pfad.name}:{knoten.lineno} liest die Systemzeit"


@pytest.mark.parametrize("pfad", FALL, ids=lambda p: p.name)
def test_R3_F_001_fall_traegt_keinen_fristwert_der_startwerte_im_code(
    pfad: Path,
) -> None:
    for knoten in ast.walk(_baum(pfad)):
        if isinstance(knoten, ast.Constant) and isinstance(knoten.value, int):
            assert knoten.value not in STARTWERTE, (
                f"{pfad.name}:{knoten.lineno}: ganze Zahl {knoten.value} wie ein Startwert"
            )


def test_R3_F_001_token_bytes_steht_allein_in_fall_service() -> None:
    treffer = sorted(
        str(p.relative_to(WURZEL))
        for p in WURZEL.rglob("*.py")
        if "token_bytes" in p.read_text(encoding="utf-8")
    )
    assert treffer == ["fall/service.py"]
