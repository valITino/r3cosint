"""Architekturtest: Bestand und Herkunft (ADR 0007, Festlegung S1.4, Zeile Tests Architektur; R3-F-003, R3-F-005).

Positivliste der Importe von kanon über den Syntaxbaum, Bildung der Eingaben Entitaet und
Beziehung allein in kanon und spur, nur yaml.safe_load, keine Bibliothek followthemoney, Abgleich
des Katalogs der Schemata, Summe von quellen.toml, Erreichbarkeit der Schemadateien über
importlib.resources, kanon ohne Systemzeit und Zufall.
"""

import ast
import hashlib
import re
import tomllib
from importlib import resources
from pathlib import Path

import pytest

from r3cosint.kanon.ftm import VORRAT_KANTEN, VORRAT_KNOTEN, schemata
from r3cosint.spur.payload import EIGENSCHAFTSNAME_MUSTER

BACKEND = Path(__file__).resolve().parents[2]
SRC = BACKEND / "src"
WURZEL = SRC / "r3cosint"
KANON = sorted((WURZEL / "kanon").glob("*.py"))
SCHEMADATEIEN = WURZEL / "kanon" / "ftm_schema"

QUELLEN_SHA256 = "5bc92e34892540fe37cee1a6c67ab0f9c8f25d4d060de008be2b4f32c112eb7f"
"""SHA-256 über die ganze Datei quellen.toml (SD-S14-01); ein Fassungswechsel ändert sie und diese Zeile."""

POSITIVLISTE = frozenset(
    {
        "__future__",
        "hashlib",
        "tomllib",
        "unicodedata",
        "importlib.resources",
        "functools",
        "types",
        "re",
        "dataclasses",
        "enum",
        "datetime",
        "collections.abc",
        "typing",
        "uuid",
        "pydantic",
        "sqlalchemy",
        "yaml",
        "r3cosint",
    }
)
ZEITAUFRUFE = {"now", "utcnow", "today", "time", "monotonic", "time_ns"}
UNSICHERE_YAML = {
    "load",
    "unsafe_load",
    "full_load",
    "load_all",
    "unsafe_load_all",
    "full_load_all",
}
LADER = {"Loader", "FullLoader", "UnsafeLoader", "BaseLoader"}


def _erlaubt(modul: str) -> bool:
    return any(modul == name or modul.startswith(name + ".") for name in POSITIVLISTE)


def importverstoesse(quelltext: str) -> list[str]:
    """Funde einer Quelle gegen die Positivliste (Import, ImportFrom, __import__, import_module)."""
    funde: list[str] = []
    for knoten in ast.walk(ast.parse(quelltext)):
        if isinstance(knoten, ast.Import):
            funde += [a.name for a in knoten.names if not _erlaubt(a.name)]
        elif isinstance(knoten, ast.ImportFrom):
            modul = knoten.module or ""
            if knoten.level:
                funde.append("relativer Import")
            elif modul == "importlib":
                funde += [
                    f"importlib.{a.name}" for a in knoten.names if a.name != "resources"
                ]
            elif not _erlaubt(modul):
                funde.append(modul)
        elif isinstance(knoten, ast.Call):
            ziel = knoten.func
            name = ziel.id if isinstance(ziel, ast.Name) else getattr(ziel, "attr", "")
            if name in {"__import__", "import_module"}:
                funde.append(name)
    return funde


@pytest.mark.parametrize("pfad", KANON, ids=lambda p: p.name)
def test_R3_F_003_kanon_importiert_allein_module_der_positivliste(pfad: Path) -> None:
    assert importverstoesse(pfad.read_text(encoding="utf-8")) == []


@pytest.mark.parametrize(
    "quelle",
    [
        "import socket",
        "import os.path",
        "from socket import socket",
        "from importlib import import_module",
        "from importlib import util",
        "import importlib.util",
        "import importlib\nimportlib.import_module('x')",
        "__import__('socket')",
        "from . import x",
        "from urllib import request",
    ],
)
def test_R3_F_003_die_positivliste_erkennt_verstoesse_gegenprobe(quelle: str) -> None:
    assert importverstoesse(quelle)


@pytest.mark.parametrize(
    "quelle",
    [
        "from importlib import resources",
        "import importlib.resources",
        "from importlib.resources import files",
        "from collections.abc import Mapping",
        "from r3cosint.core.fehler import EingabeFehler",
    ],
)
def test_R3_F_003_die_positivliste_laesst_erlaubtes_zu_gegenprobe(quelle: str) -> None:
    assert importverstoesse(quelle) == []


_EINGABEN = {"Entitaet", "Beziehung", "Eingabe"}
"""Die Namen der Eingaben in spur.payload und ihrer Vereinigung (Eingabe)."""


def _text(knoten: ast.AST) -> str | None:
    """Der Text eines Ausdrucks, soweit er aus Zeichenkettenkonstanten zusammengesetzt ist, sonst None."""
    if isinstance(knoten, ast.Constant) and isinstance(knoten.value, str):
        return knoten.value
    if isinstance(knoten, ast.BinOp) and isinstance(knoten.op, ast.Add):
        links, rechts = _text(knoten.left), _text(knoten.right)
        return None if links is None or rechts is None else links + rechts
    if isinstance(knoten, ast.JoinedStr):
        teile = [_text(t) for t in knoten.values]
        return None if any(t is None for t in teile) else "".join(t for t in teile if t)
    return None


def _bildung_von_eingaben(quelltext: str) -> list[str]:
    """Jede Nennung der Namen Entitaet, Beziehung und Eingabe: Name, Attribut, Import, Alias, Zeichenkette (auch zusammengesetzt)."""
    funde: list[str] = []
    for knoten in ast.walk(ast.parse(quelltext)):
        if isinstance(knoten, ast.Name) and knoten.id in _EINGABEN:
            funde.append(f"Name {knoten.id}")
        elif isinstance(knoten, ast.Attribute) and knoten.attr in _EINGABEN:
            funde.append(f"Attribut {knoten.attr}")
        elif isinstance(knoten, ast.alias) and (
            knoten.name.split(".")[-1] in _EINGABEN or knoten.asname in _EINGABEN
        ):
            funde.append(f"Import {knoten.name}")
        elif isinstance(knoten, ast.Constant | ast.BinOp | ast.JoinedStr):
            text = _text(knoten)
            if text in _EINGABEN:
                funde.append(f"Zeichenkette {text}")
    return funde


def test_R3_F_005_entitaet_beziehung_und_eingabe_werden_allein_in_kanon_und_spur_genannt() -> (
    None
):
    for pfad in sorted(WURZEL.rglob("*.py")):
        teil = pfad.relative_to(WURZEL).parts[0]
        if teil in {"kanon", "spur"}:
            continue
        assert _bildung_von_eingaben(pfad.read_text(encoding="utf-8")) == [], pfad
    # Gegenprobe: in kanon wird gebildet, die Suche findet es.
    assert _bildung_von_eingaben(
        (WURZEL / "kanon" / "service.py").read_text(encoding="utf-8")
    )


@pytest.mark.parametrize(
    "quelle",
    [
        "from r3cosint.spur.payload import Entitaet\nEntitaet(x=1)",
        "import r3cosint.spur.payload as payload\npayload.Entitaet.model_validate(x)",
        "s.Beziehung.model_construct(x)",
        "from r3cosint.spur.payload import Entitaet\nE = Entitaet\nE(x=1)",
        "from r3cosint.spur.payload import Beziehung as B\nB(x=1)",
        "from pydantic import TypeAdapter\nTypeAdapter(Entitaet)",
        "from pydantic import TypeAdapter\nTypeAdapter(payload.Eingabe).validate_python(x)",
        "getattr(payload, 'Ent' + 'itaet')",
        "getattr(payload, 'Beziehung' + '')",
        "getattr(payload, f'Ein' f'gabe')",
        "getattr(payload, 'Beziehung')",
        "from r3cosint.spur import payload as Entitaet",
    ],
)
def test_R3_F_005_gegenprobe_die_suche_findet_alle_statischen_formen(
    quelle: str,
) -> None:
    assert _bildung_von_eingaben(quelle)


def test_R3_F_005_gegenprobe_ohne_nennung_kein_fund() -> None:
    assert (
        _bildung_von_eingaben("x = 'entitaet'\nclass Eintragstyp: ENTITAET = 1") == []
    )


def _yaml_funde(quelltext: str) -> list[str]:
    funde: list[str] = []
    for knoten in ast.walk(ast.parse(quelltext)):
        if isinstance(knoten, ast.Attribute):
            wert = knoten.value
            if (
                isinstance(wert, ast.Name)
                and wert.id == "yaml"
                and (knoten.attr in UNSICHERE_YAML or knoten.attr in LADER)
            ):
                funde.append(f"yaml.{knoten.attr}")
        elif isinstance(knoten, ast.Name) and knoten.id in LADER:
            funde.append(knoten.id)
        elif (
            isinstance(knoten, ast.ImportFrom)
            and (knoten.module or "").split(".")[0] == "yaml"
        ):
            funde += [
                f"from yaml import {a.name}"
                for a in knoten.names
                if a.name not in {"safe_load", "YAMLError"}
            ]
    return funde


def test_R3_F_003_unter_backend_src_laedt_allein_yaml_safe_load() -> None:
    for pfad in sorted(SRC.rglob("*.py")):
        assert _yaml_funde(pfad.read_text(encoding="utf-8")) == [], pfad
    for schlecht in (
        "import yaml\nyaml.load(x)",
        "import yaml\nyaml.unsafe_load(x)",
        "import yaml\nyaml.full_load(x)",
        "import yaml\nyaml.safe_load(x, Loader=yaml.Loader)",
        "from yaml import load",
        "import yaml\nyaml.FullLoader",
    ):
        assert _yaml_funde(schlecht)


def test_R3_F_003_followthemoney_steht_weder_in_der_projektdatei_noch_in_der_sperrdatei() -> (
    None
):
    for name in ("pyproject.toml", "uv.lock"):
        assert (
            "followthemoney" not in (BACKEND / name).read_text(encoding="utf-8").lower()
        )


def test_R3_F_003_kanon_liest_keine_systemzeit_und_nutzt_kein_random_oder_secrets() -> (
    None
):
    for pfad in KANON:
        baum = ast.parse(pfad.read_text(encoding="utf-8"))
        for knoten in ast.walk(baum):
            if isinstance(knoten, ast.Call) and isinstance(knoten.func, ast.Attribute):
                ziel = knoten.func.value
                name = ziel.id if isinstance(ziel, ast.Name) else ""
                assert not (
                    knoten.func.attr in ZEITAUFRUFE
                    and name in {"datetime", "date", "time"}
                ), f"{pfad.name}:{knoten.lineno} liest die Systemzeit"
            if isinstance(knoten, ast.Import):
                assert not {a.name.split(".")[0] for a in knoten.names} & {
                    "random",
                    "secrets",
                    "time",
                }
            if isinstance(knoten, ast.ImportFrom):
                assert (knoten.module or "").split(".")[0] not in {
                    "random",
                    "secrets",
                    "time",
                }
        assert "uuid4" not in pfad.read_text(
            encoding="utf-8"
        )  # Kennungen allein über core.kennung


def test_R3_F_003_summe_von_quellen_toml_gleich_der_konstante() -> None:
    assert (
        hashlib.sha256((SCHEMADATEIEN / "quellen.toml").read_bytes()).hexdigest()
        == QUELLEN_SHA256
    )


def test_R3_F_003_schemadateien_lizenz_und_quellen_sind_ueber_importlib_resources_erreichbar() -> (
    None
):
    wurzel = resources.files("r3cosint.kanon").joinpath("ftm_schema")
    yaml_namen = sorted(e.name for e in wurzel.iterdir() if e.name.endswith(".yaml"))
    assert len(yaml_namen) == 71
    quellen = tomllib.loads(wurzel.joinpath("quellen.toml").read_text(encoding="utf-8"))
    assert sorted(quellen["dateien"]) == yaml_namen
    assert quellen["quelle"]["anzahl_dateien"] == 71
    assert (
        hashlib.sha256(wurzel.joinpath("LIZENZ.txt").read_bytes()).hexdigest()
        == quellen["quelle"]["lizenz_sha256"]
    )
    assert (
        quellen["quelle"]["projekt"]
        == "https://github.com/opensanctions/followthemoney"
    )
    assert quellen["quelle"]["fassung"] == "4.11.2"
    assert quellen["quelle"]["vermerk"] == "byte-gleich, unverändert"
    assert len(quellen["quelle"]["urhebervermerke"]) == 2
    lizenz = wurzel.joinpath("LIZENZ.txt").read_text(encoding="utf-8")
    assert all(v in lizenz for v in quellen["quelle"]["urhebervermerke"])


def test_R3_F_003_katalogabgleich_des_vorrats() -> None:
    bekannt = schemata()
    for name in VORRAT_KNOTEN | VORRAT_KANTEN:
        assert name in bekannt, name
        assert not bekannt[name].abstrakt, name
    for name in VORRAT_KNOTEN:
        assert bekannt[name].kante is None, name
    for name in VORRAT_KANTEN:
        assert bekannt[name].kante is not None, name
        quelle, ziel = bekannt[name].kante  # type: ignore[misc]
        assert bekannt[name].eigenschaften[quelle].typ == "entity"
        assert bekannt[name].eigenschaften[ziel].typ == "entity"


def test_R3_F_003_eigenschaftsnamen_der_vorratsschemata_passen_auf_das_muster_der_nutzlast() -> (
    None
):
    muster = re.compile(EIGENSCHAFTSNAME_MUSTER)
    bekannt = schemata()
    for name in sorted(VORRAT_KNOTEN | VORRAT_KANTEN):
        for eigenschaft in bekannt[name].eigenschaften:
            assert muster.fullmatch(eigenschaft), (name, eigenschaft)
