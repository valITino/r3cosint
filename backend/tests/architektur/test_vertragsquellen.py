"""Architekturtest: die Quellenlisten der Verträge in importvertraege.toml.

Die Quellenlisten der Verträge 2, 3 und 6 zählen die obersten Pakete einzeln auf; ein
neues oberstes Paket fehlte sonst still in den Verträgen. Der Test gleicht je Vertrag mit
einem ausgenommenen Paket ab, dass Quellen und Ausnahme zusammen die obersten Pakete
unter backend/src/r3cosint ergeben (ADR 0002, Abschnitt 5, Nachtrag G1, Zeile
"Verträge, gemeinsam"). Die Verträge selbst prüft import-linter (D18).
"""

import tomllib
from pathlib import Path
from typing import Any

import pytest

BACKEND = Path(__file__).resolve().parents[2]
WURZEL = BACKEND / "src" / "r3cosint"
VERTRAGSDATEI = BACKEND / "importvertraege.toml"

VERTRAG_1 = (
    "Vertrag 1 (R3-F-014): vorschlag und ausfuehrung sind voneinander unabhaengig"
)
VERTRAG_2 = "Vertrag 2 (R3-F-015): ausgehende Verbindungen nur in ausgang"
VERTRAG_3 = "Vertrag 3 (R3-F-018), ausserhalb llm: kein Modellendpunkt"
VERTRAG_3_LLM = "Vertrag 3 (R3-F-018), in llm: keine Herstellerbibliothek"
VERTRAG_6 = "Vertrag 6: api wird von keinem anderen Modul importiert"
VERTRAG_7 = "Vertrag 7: Produktionscode importiert prototype nicht"

# Verbotsliste von Vertrag 2 (ADR 0002, Abschnitt 5, Nachtrag G1, Zeile "Vertrag 2"),
# einschliesslich httpx2 und httpcore2 (Vermerk "nach dem Bau").
VERBOTENE_BIBLIOTHEKEN_VERTRAG_2 = (
    "httpx",
    "httpx2",
    "httpcore",
    "httpcore2",
    "requests",
    "urllib3",
    "aiohttp",
    "httplib2",
    "pycurl",
    "websockets",
    "websocket",
    "grpc",
    "socket",
    "smtplib",
    "ftplib",
    "imaplib",
    "poplib",
    "xmlrpc",
)


def _einstellungen() -> dict[str, Any]:
    with VERTRAGSDATEI.open("rb") as datei:
        einstellungen = tomllib.load(datei)["tool"]["importlinter"]
    assert isinstance(einstellungen, dict)
    return einstellungen


def _vertrag(name: str) -> dict[str, Any]:
    treffer = [v for v in _einstellungen()["contracts"] if v["name"] == name]
    assert len(treffer) == 1, f"Vertrag {name!r} steht nicht genau einmal in der Datei"
    vertrag = treffer[0]
    assert isinstance(vertrag, dict)
    return vertrag


def _oberste_pakete() -> set[str]:
    return {
        f"r3cosint.{ordner.name}"
        for ordner in WURZEL.iterdir()
        if ordner.is_dir() and (ordner / "__init__.py").is_file()
    }


def test_gemeinsame_einstellungen() -> None:
    einstellungen = _einstellungen()
    assert einstellungen["root_packages"] == ["r3cosint"]
    assert einstellungen["include_external_packages"] is True
    assert all(
        "ignore_imports" not in vertrag for vertrag in einstellungen["contracts"]
    )


def test_die_obersten_pakete_sind_die_14_des_modulschnitts() -> None:
    assert len(_oberste_pakete()) == 14


@pytest.mark.parametrize(
    ("vertrag", "ausnahme"),
    [
        (VERTRAG_2, "r3cosint.ausgang"),
        (VERTRAG_3, "r3cosint.llm"),
        (VERTRAG_6, "r3cosint.api"),
    ],
)
def test_quellen_und_ausnahme_ergeben_die_obersten_pakete(
    vertrag: str, ausnahme: str
) -> None:
    quellen = _vertrag(vertrag)["source_modules"]
    assert len(quellen) == len(set(quellen)), "ein Paket steht doppelt in den Quellen"
    assert ausnahme not in quellen
    assert {*quellen, ausnahme} == _oberste_pakete()


def test_vertrag_2_verbietet_die_bibliotheken_fuer_ausgehende_verbindungen() -> None:
    verboten = _vertrag(VERTRAG_2)["forbidden_modules"]
    assert len(verboten) == len(set(verboten)), "ein Name steht doppelt in der Liste"
    assert set(verboten) == set(VERBOTENE_BIBLIOTHEKEN_VERTRAG_2)


def test_vertrag_1_nennt_vorschlag_und_ausfuehrung() -> None:
    vertrag = _vertrag(VERTRAG_1)
    assert vertrag["type"] == "independence"
    assert vertrag["modules"] == [
        "r3cosint.freigabe.vorschlag",
        "r3cosint.freigabe.ausfuehrung",
    ]


def test_vertrag_3_in_llm_nennt_llm_als_einzige_quelle() -> None:
    vertrag = _vertrag(VERTRAG_3_LLM)
    assert vertrag["source_modules"] == ["r3cosint.llm"]
    assert "openai" not in vertrag["forbidden_modules"]
    assert set(vertrag["forbidden_modules"]) == {
        "anthropic",
        "mistralai",
        "cohere",
        "ollama",
        "litellm",
    }


def test_vertrag_7_verbietet_prototype_dem_ganzen_produktionscode() -> None:
    vertrag = _vertrag(VERTRAG_7)
    assert vertrag["source_modules"] == ["r3cosint"]
    assert vertrag["forbidden_modules"] == ["prototype"]
