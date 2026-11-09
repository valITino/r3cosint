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
VERTRAG_10 = "Vertrag 10: Treiber nur hinter der Zugriffsschicht"
VERTRAG_4 = "Vertrag 4 (R3-F-008): ausser spur schreibt kein Modul in die Spurtabellen"
VERTRAG_8 = "Vertrag 8 (R3-F-001): ausser fall schreibt kein Modul in die Falltabellen"
VERTRAG_5 = "Vertrag 5 (R3-F-005): ausser kanon schreibt kein Modul in den Bestand"
VERTRAG_9 = "Vertrag 9 (R3-F-008): Schichtung"

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
        (VERTRAG_4, "r3cosint.spur"),
        (VERTRAG_8, "r3cosint.fall"),
        (VERTRAG_5, "r3cosint.kanon"),
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


def test_R3_F_008_vertrag_10_nennt_alle_14_obersten_pakete_als_quellen_ohne_ausnahme() -> (
    None
):
    vertrag = _vertrag(VERTRAG_10)
    quellen = vertrag["source_modules"]
    assert len(quellen) == len(set(quellen)), "ein Paket steht doppelt in den Quellen"
    assert set(quellen) == _oberste_pakete()
    assert len(quellen) == 14


def test_R3_F_008_vertrag_10_verbietet_asyncpg_und_alembic_und_laesst_mittelbare_importe_zu() -> (
    None
):
    vertrag = _vertrag(VERTRAG_10)
    assert vertrag["type"] == "forbidden"
    assert vertrag["forbidden_modules"] == ["asyncpg", "alembic"]
    # sqlalchemy lädt asyncpg über den Dialekt; ein mittelbarer Import ist gewollt.
    assert vertrag["allow_indirect_imports"] is True


def test_R3_F_008_vertrag_4_verbietet_tables_und_store_von_spur() -> None:
    vertrag = _vertrag(VERTRAG_4)
    assert vertrag["type"] == "forbidden"
    assert vertrag["forbidden_modules"] == [
        "r3cosint.spur.tables",
        "r3cosint.spur.store",
    ]
    assert vertrag["allow_indirect_imports"] is True


def test_R3_F_001_vertrag_8_verbietet_tables_und_store_von_fall() -> None:
    vertrag = _vertrag(VERTRAG_8)
    assert vertrag["type"] == "forbidden"
    assert vertrag["forbidden_modules"] == [
        "r3cosint.fall.tables",
        "r3cosint.fall.store",
    ]
    assert vertrag["allow_indirect_imports"] is True


def test_R3_F_005_vertrag_5_verbietet_tables_und_store_von_kanon() -> None:
    vertrag = _vertrag(VERTRAG_5)
    assert vertrag["type"] == "forbidden"
    assert vertrag["forbidden_modules"] == [
        "r3cosint.kanon.tables",
        "r3cosint.kanon.store",
    ]
    assert vertrag["allow_indirect_imports"] is True


def test_R3_F_008_vertrag_9_ordnet_die_schichten_kanon_fall_spur_core() -> None:
    vertrag = _vertrag(VERTRAG_9)
    assert vertrag["type"] == "layers"
    assert vertrag["layers"] == [
        "r3cosint.kanon",
        "r3cosint.fall",
        "r3cosint.spur",
        "r3cosint.core",
    ]
