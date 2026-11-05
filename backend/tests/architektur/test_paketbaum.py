"""Architekturtest: der Paketbaum unter backend/src gegen ADR 0002, 4.1.

Geprüft wird der Baum, nicht das Verhalten: genau ein Wurzelpaket r3cosint, darin die
16 Pakete des Modulschnitts (freigabe als Elternpaket von vorschlag und ausfuehrung),
jedes allein mit seiner Modulbeschreibung als Docstring, am Syntaxbaum geprüft. Ausnahmen
sind api mit der ASGI-Anwendung ohne Route (Grundgerüst, Einheit G1) und core mit den fünf
Modulen von Sprint 1 (Einheit S1.1, ADR 0007, Festlegung S1.1); der __init__ von core bleibt
die Modulbeschreibung allein. Fachlogik in den übrigen Paketen entsteht erst mit ihrer Einheit.
"""

import ast
import importlib
from pathlib import Path

import pytest

QUELLE = Path(__file__).resolve().parents[2] / "src"
WURZEL = QUELLE / "r3cosint"

# Die 16 Pakete nach ADR 0002, 4.1, als Punktpfade unterhalb des Wurzelpakets.
PAKETE = (
    "core",
    "kanon",
    "spur",
    "fall",
    "zugriff",
    "freigabe",
    "freigabe.vorschlag",
    "freigabe.ausfuehrung",
    "beschaffung",
    "ausgang",
    "fremd",
    "llm",
    "graph",
    "export",
    "api",
    "mcpsrv",
)

# Die Module von core (ADR 0007, Entscheid 28, Festlegung S1.1, Nachführung zu Entscheid 28).
CORE_MODULE = ("konfiguration", "fehler", "zeit", "kennung", "datenbank")

# Inhalt von api/__init__.py hinter dem Docstring (Festlegung G1, Zeile Paketbaum).
API_NACH_DOCSTRING = """\
from fastapi import FastAPI

app = FastAPI(docs_url=None, redoc_url=None, openapi_url=None)
"""


def _init_datei(paket: str) -> Path:
    return WURZEL.joinpath(*paket.split("."), "__init__.py")


def _syntaxbaum(datei: Path) -> ast.Module:
    return ast.parse(datei.read_text(encoding="utf-8"), filename=str(datei))


def _ist_docstring(knoten: ast.stmt) -> bool:
    return (
        isinstance(knoten, ast.Expr)
        and isinstance(knoten.value, ast.Constant)
        and isinstance(knoten.value.value, str)
        and knoten.value.value.strip() != ""
    )


DATEIEN_OHNE_CODE = (
    WURZEL / "__init__.py",
    *(_init_datei(paket) for paket in PAKETE if paket != "api"),
)
MIT_CODE = ("api", "core")


def test_unter_src_steht_allein_das_wurzelpaket() -> None:
    namen = sorted(p.name for p in QUELLE.iterdir() if p.name != "__pycache__")
    assert namen == ["r3cosint"]


def test_wurzelpaket_enthaelt_genau_die_dateien_des_modulschnitts() -> None:
    gefunden = {
        pfad.relative_to(WURZEL).as_posix()
        for pfad in WURZEL.rglob("*")
        if pfad.is_file() and "__pycache__" not in pfad.relative_to(WURZEL).parts
    }
    erwartet = {"__init__.py", "py.typed"}
    erwartet |= {f"{paket.replace('.', '/')}/__init__.py" for paket in PAKETE}
    erwartet |= {f"core/{modul}.py" for modul in CORE_MODULE}
    assert gefunden == erwartet


def test_wurzelpaket_ist_importierbar() -> None:
    modul = importlib.import_module("r3cosint")
    assert modul.__file__ is not None
    assert Path(modul.__file__).resolve() == (WURZEL / "__init__.py").resolve()


@pytest.mark.parametrize("paket", PAKETE)
def test_paket_ist_aus_diesem_baum_importierbar(paket: str) -> None:
    modul = importlib.import_module(f"r3cosint.{paket}")
    assert modul.__file__ is not None
    assert Path(modul.__file__).resolve() == _init_datei(paket).resolve()


@pytest.mark.parametrize(
    "datei", DATEIEN_OHNE_CODE, ids=lambda d: d.relative_to(QUELLE).as_posix()
)
def test_init_besteht_allein_aus_einem_docstring(datei: Path) -> None:
    koerper = _syntaxbaum(datei).body
    assert len(koerper) == 1
    assert _ist_docstring(koerper[0])


def test_api_besteht_aus_docstring_und_der_anwendung_ohne_route() -> None:
    koerper = _syntaxbaum(_init_datei("api")).body
    assert koerper
    assert _ist_docstring(koerper[0])
    gefunden = [ast.dump(knoten) for knoten in koerper[1:]]
    erwartet = [ast.dump(knoten) for knoten in ast.parse(API_NACH_DOCSTRING).body]
    assert gefunden == erwartet


def test_R3_F_008_core_enthaelt_genau_die_fuenf_module_von_sprint_1() -> None:
    gefunden = sorted(
        p.name for p in (WURZEL / "core").glob("*.py") if p.name != "__init__.py"
    )
    assert gefunden == sorted(f"{modul}.py" for modul in CORE_MODULE)


@pytest.mark.parametrize("modul", CORE_MODULE)
def test_R3_F_008_jedes_core_modul_beginnt_mit_einer_modulbeschreibung(
    modul: str,
) -> None:
    koerper = _syntaxbaum(WURZEL / "core" / f"{modul}.py").body
    assert koerper
    assert _ist_docstring(koerper[0])


def test_R3_F_008_nur_api_und_core_tragen_code_ausser_der_modulbeschreibung() -> None:
    mit_code = sorted(
        paket
        for paket in PAKETE
        if len(_syntaxbaum(_init_datei(paket)).body) != 1
        or any(
            p.name != "__init__.py"
            for p in WURZEL.joinpath(*paket.split(".")).glob("*.py")
        )
    )
    assert mit_code == sorted(MIT_CODE)
