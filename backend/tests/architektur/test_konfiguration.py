"""Konfigurationstest: die Werkzeugkonfiguration von backend/ gilt und ist eindeutig.

ruff sucht seine Konfiguration je Datei hierarchisch; eine näher liegende Datei änderte
D2 und D3 still, während mypy, pytest, coverage und lint-imports ihre Konfiguration
ausdrücklich erhalten (ADR 0002, Abschnitt 5, Nachtrag G1, Zeile "Tests").
"""

import os
from pathlib import Path

import pytest

BACKEND = Path(__file__).resolve().parents[2]
KONFIGURATIONSNAMEN = frozenset({"ruff.toml", ".ruff.toml", "pyproject.toml"})


def test_unter_backend_gibt_es_keine_zweite_konfiguration_von_ruff() -> None:
    gefunden: list[str] = []
    for ordner, unterordner, dateien in os.walk(BACKEND):
        unterordner[:] = [name for name in unterordner if name != ".venv"]
        gefunden += [
            (Path(ordner) / name).relative_to(BACKEND).as_posix()
            for name in dateien
            if name in KONFIGURATIONSNAMEN
        ]
    assert gefunden == ["pyproject.toml"]


def test_pytest_liest_die_konfiguration_aus_backend(
    pytestconfig: pytest.Config,
) -> None:
    assert pytestconfig.inipath is not None
    assert pytestconfig.inipath.resolve() == (BACKEND / "pyproject.toml").resolve()


def test_marker_abnahme_ist_registriert(pytestconfig: pytest.Config) -> None:
    registriert = [
        zeile.split(":", 1)[0].strip() for zeile in pytestconfig.getini("markers")
    ]
    assert "abnahme" in registriert
