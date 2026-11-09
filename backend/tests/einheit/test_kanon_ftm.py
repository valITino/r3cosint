"""Einheitstest: kanon.ftm (ADR 0007, Festlegung S1.4; R3-F-003): Laden, Vererbung, Prüfung. Werte erfunden (5.15)."""

import hashlib
import importlib.resources
import re
import shutil
import tomllib
from collections.abc import Iterator
from importlib import resources
from pathlib import Path
from typing import Any

import pytest

from r3cosint.core.fehler import KonfigurationsFehler, SchemaFehler
from r3cosint.kanon.eingabe import Datensatz
from r3cosint.kanon.ftm import (
    VORRAT_KANTEN,
    VORRAT_KNOTEN,
    ende_pruefen,
    pruefen,
    schemata,
    vorrat,
)

QUELLE = Path(str(resources.files("r3cosint.kanon").joinpath("ftm_schema")))


@pytest.fixture
def kopie(tmp_path: Path, monkeypatch: pytest.MonkeyPatch) -> Iterator[Path]:
    """Eine Kopie des Verzeichnisses der Schemadateien, auf die kanon.ftm zeigt; Zwischenspeicher leer."""
    ziel = tmp_path / "ftm_schema"
    shutil.copytree(QUELLE, ziel)
    monkeypatch.setattr(importlib.resources, "files", lambda paket: tmp_path)
    schemata.cache_clear()
    yield ziel
    schemata.cache_clear()


def _summe_nachtragen(ordner: Path, name: str) -> None:
    summe = hashlib.sha256((ordner / name).read_bytes()).hexdigest()
    quellen = (ordner / "quellen.toml").read_text(encoding="utf-8")
    quellen = re.sub(
        rf'("{re.escape(name)}" = ")[0-9a-f]{{64}}(")', rf"\g<1>{summe}\g<2>", quellen
    )
    (ordner / "quellen.toml").write_text(quellen, encoding="utf-8")


def _satz(
    schema: str, eigenschaften: dict[str, Any], ftm_kennung: str = "synth-1"
) -> Datensatz:
    return Datensatz.model_validate(
        {"id": ftm_kennung, "schema": schema, "properties": eigenschaften}
    )


def test_R3_F_003_laden_aller_71_dateien_mit_gleichen_summen() -> None:
    schemata.cache_clear()
    bekannt = schemata()
    quellen = tomllib.loads((QUELLE / "quellen.toml").read_text(encoding="utf-8"))
    assert len(bekannt) == 71 == quellen["quelle"]["anzahl_dateien"]
    assert set(bekannt) == {name.removesuffix(".yaml") for name in quellen["dateien"]}
    for name, summe in quellen["dateien"].items():
        assert hashlib.sha256((QUELLE / name).read_bytes()).hexdigest() == summe
    assert schemata() is bekannt  # einmal geladen


def test_R3_F_003_vererbung_company_erbt_von_organization_und_asset() -> None:
    company = schemata()["Company"]
    assert {
        "Company",
        "Organization",
        "LegalEntity",
        "Thing",
        "Asset",
    } <= company.vorfahren
    assert "name" in company.pflicht  # Pflichteigenschaft über Thing
    assert "name" in company.eigenschaften
    assert set(schemata()["Organization"].eigenschaften) <= set(company.eigenschaften)
    assert set(schemata()["Asset"].eigenschaften) <= set(company.eigenschaften)


def test_R3_F_003_abstrakte_schemata_und_kanten() -> None:
    bekannt = schemata()
    assert {n for n, s in bekannt.items() if s.abstrakt} == {
        "Analyzable",
        "Interest",
        "Interval",
        "Thing",
        "Value",
    }
    assert bekannt["Asset"].abstrakt is False
    assert bekannt["Ownership"].kante == ("owner", "asset")
    assert bekannt["Person"].kante is None
    for name in VORRAT_KANTEN:
        assert bekannt[name].kante is not None and not bekannt[name].abstrakt
    for name in VORRAT_KNOTEN:
        assert bekannt[name].kante is None and not bekannt[name].abstrakt
    assert vorrat() == VORRAT_KNOTEN | VORRAT_KANTEN


def test_R3_F_003_schemata_sind_unveraenderlich() -> None:
    with pytest.raises(TypeError):
        schemata()["Person"].eigenschaften["neu"] = None  # type: ignore[index]
    with pytest.raises(TypeError):
        schemata()["neu"] = None  # type: ignore[index]


@pytest.mark.parametrize(
    "datensatz",
    [
        ("Vehicle", {"name": ["a"]}),  # ausserhalb des Vorrats
        ("Membership", {"organization": ["a"], "member": ["b"]}),
        ("Thing", {"name": ["a"]}),  # abstrakt
        ("Interest", {}),
        ("SynthSchema", {"name": ["a"]}),
        ("Person", {"synthFremd": ["a"]}),
        ("Person", {"ownershipOwner": ["a"]}),  # Stub von reverse, nicht modelliert
        ("Person", {"notes": ["a"]}),  # Pflichteigenschaft name fehlt
        ("Person", {"name": ["a"], "weakAlias": ["b"], "synthFremdZwei": ["c"]}),
        ("Ownership", {"owner": ["a"]}),  # asset fehlt
        ("Ownership", {"owner": ["a", "b"], "asset": ["c"]}),  # Ende mit zwei Werten
        ("Ownership", {"owner": ["a"], "asset": ["b"], "synthFremd": ["c"]}),
    ],
)
def test_R3_F_003_abweisungsfaelle_ohne_datenbank(
    datensatz: tuple[str, dict[str, Any]],
) -> None:
    schema, eigenschaften = datensatz
    with pytest.raises(SchemaFehler) as fehler:
        pruefen(_satz(schema, eigenschaften))
    # Die Meldung nennt weder Werte noch vom Aufrufer gelieferte unbekannte Namen.
    for geheim in ("synthFremd", "synthFremdZwei", "SynthSchema", "synth-1"):
        assert geheim not in fehler.value.sache


def test_R3_F_003_knoten_als_kante_und_kante_als_knoten() -> None:
    with pytest.raises(SchemaFehler):
        pruefen(_satz("Person", {"name": ["a"], "owner": ["b"]}))
    with pytest.raises(SchemaFehler):
        pruefen(_satz("Ownership", {"name": ["a"]}))


def test_R3_F_003_entity_ausserhalb_der_enden_wird_abgewiesen() -> None:
    schema = schemata()["Ownership"]
    ausserhalb = [
        n
        for n, e in schema.eigenschaften.items()
        if e.typ == "entity" and n not in ("owner", "asset")
    ]
    assert ausserhalb, (
        "Ownership trägt keine weitere entity-Eigenschaft: Fall nicht herstellbar"
    )
    with pytest.raises(SchemaFehler):
        pruefen(
            _satz("Ownership", {"owner": ["a"], "asset": ["b"], ausserhalb[0]: ["c"]})
        )


def test_R3_F_003_gueltige_datensaetze_je_schema_des_vorrats() -> None:
    assert pruefen(_satz("Person", {"name": ["a"]})).name == "Person"
    assert pruefen(_satz("Company", {"name": ["a"]})).name == "Company"
    assert pruefen(_satz("Ownership", {"owner": ["a"], "asset": ["b"]})).kante == (
        "owner",
        "asset",
    )


def test_R3_F_003_range_mit_unterschema_angenommen_und_fremdes_schema_abgewiesen() -> (
    None
):
    ownership = schemata()["Ownership"]
    ende_pruefen(
        ownership, "owner", "Person"
    )  # range LegalEntity, Person ist Unterschema
    ende_pruefen(ownership, "asset", "Company")  # range Asset, Company erbt von Asset
    ende_pruefen(ownership, "asset", "Asset")
    with pytest.raises(SchemaFehler):
        ende_pruefen(ownership, "asset", "Person")
    with pytest.raises(SchemaFehler):
        ende_pruefen(ownership, "owner", "Vehicle")
    with pytest.raises(SchemaFehler):
        ende_pruefen(ownership, "name", "Person")  # keine Rolle der Kante
    with pytest.raises(SchemaFehler):
        ende_pruefen(ownership, "owner", "SynthSchema")


def test_R3_F_003_veraenderte_datei_ergibt_konfigurationsfehler_mit_dateiname(
    kopie: Path,
) -> None:
    (kopie / "Person.yaml").write_bytes(
        (kopie / "Person.yaml").read_bytes() + b"\n# x\n"
    )
    with pytest.raises(KonfigurationsFehler) as fehler:
        schemata()
    assert "Person.yaml" in str(fehler.value)


def test_R3_F_003_fehlende_und_zusaetzliche_datei_ergeben_konfigurationsfehler(
    kopie: Path,
) -> None:
    (kopie / "Person.yaml").unlink()
    with pytest.raises(KonfigurationsFehler) as fehler:
        schemata()
    assert "Person.yaml" in str(fehler.value)
    shutil.copy(QUELLE / "Person.yaml", kopie / "Person.yaml")
    (kopie / "Zusatz.yaml").write_text("Zusatz: {}\n", encoding="utf-8")
    with pytest.raises(KonfigurationsFehler) as fehler:
        schemata()
    assert "Zusatz.yaml" in str(fehler.value)


def test_R3_F_003_veraenderte_lizenzdatei_und_fehlende_quellenangabe_ergeben_konfigurationsfehler(
    kopie: Path,
) -> None:
    (kopie / "LIZENZ.txt").write_bytes(b"geaendert")
    with pytest.raises(KonfigurationsFehler):
        schemata()
    shutil.copy(QUELLE / "LIZENZ.txt", kopie / "LIZENZ.txt")
    (kopie / "quellen.toml").unlink()
    with pytest.raises(KonfigurationsFehler):
        schemata()


def test_R3_F_003_ein_fehlschlag_wird_nicht_gemerkt(kopie: Path) -> None:
    original = (kopie / "Person.yaml").read_bytes()
    (kopie / "Person.yaml").write_bytes(original + b"#\n")
    with pytest.raises(KonfigurationsFehler):
        schemata()
    (kopie / "Person.yaml").write_bytes(original)
    assert "Person" in schemata()  # der nächste Zugriff prüft erneut


@pytest.mark.parametrize(
    "inhalt",
    [
        b"Person: [unclosed\n",  # YAMLError
        b"Person:\n  \xff\xfe: x\n",  # UnicodeDecodeError
        b"Person:\n  extends:\n    - no\n    - 1\n",  # Namen nicht str
        b"Person:\n  properties:\n    no:\n      type: string\n",  # Schlüssel no wird False
        b"Person:\n  abstract: ja\n",  # abstract nicht bool
        b"Person:\n  edge:\n    source: 1\n    target: b\n",
        b"Person:\n  properties:\n    name:\n      range: 5\n",
        b"- Person\n",  # kein Abbild
        b"Person: {}\nZweite: {}\n",  # zwei Schemata
        b"Person: {}\n---\nZweite: {}\n",  # zwei Dokumente
        b"Person: !!python/object/apply:collections.OrderedDict []\n",  # safe_load weist ab
    ],
)
def test_R3_F_003_fehlerhafter_inhalt_mit_nachgetragener_summe_ergibt_konfigurationsfehler(
    kopie: Path, inhalt: bytes
) -> None:
    (kopie / "Person.yaml").write_bytes(inhalt)
    _summe_nachtragen(kopie, "Person.yaml")
    with pytest.raises(KonfigurationsFehler):
        schemata()


def test_R3_F_003_fehlerhaftes_toml_und_nicht_utf8_ergeben_konfigurationsfehler(
    kopie: Path,
) -> None:
    (kopie / "quellen.toml").write_text("[quelle\nkaputt", encoding="utf-8")
    with pytest.raises(KonfigurationsFehler):
        schemata()
    (kopie / "quellen.toml").write_bytes(b"\xff\xfe\x00")
    with pytest.raises(KonfigurationsFehler):
        schemata()
    shutil.copy(QUELLE / "quellen.toml", kopie / "quellen.toml")
    text = (kopie / "quellen.toml").read_text(encoding="utf-8")
    (kopie / "quellen.toml").write_text(
        text.replace('lizenzdatei = "LIZENZ.txt"', "lizenzdatei = 5"), encoding="utf-8"
    )
    with pytest.raises(KonfigurationsFehler):
        schemata()


def test_R3_F_003_fehlende_lizenzdatei_ergibt_konfigurationsfehler(kopie: Path) -> None:
    (kopie / "LIZENZ.txt").unlink()
    with pytest.raises(KonfigurationsFehler) as fehler:
        schemata()
    assert "LIZENZ.txt" in str(fehler.value)


@pytest.mark.parametrize(
    "inhalt",
    [
        b"1: {}\n",  # Schemaname kein str
        b"Person:\n  properties: [a]\n",
        b"Person:\n  extends: [Person]\n",  # zyklisch
        b"Person:\n  extends: [SynthSchema]\n",  # unbekanntes Schema
    ],
)
def test_R3_F_003_weitere_fehlerinhalte_ergeben_konfigurationsfehler(
    kopie: Path, inhalt: bytes
) -> None:
    (kopie / "Person.yaml").write_bytes(inhalt)
    _summe_nachtragen(kopie, "Person.yaml")
    with pytest.raises(KonfigurationsFehler):
        schemata()


def test_R3_F_003_abstraktes_schema_wird_vom_nicht_vorratsschema_unterschieden() -> (
    None
):
    with pytest.raises(SchemaFehler) as abstrakt:
        pruefen(_satz("Thing", {"name": ["a"]}))
    with pytest.raises(SchemaFehler) as ausserhalb:
        pruefen(_satz("Vehicle", {"name": ["a"]}))
    assert "abstrakt" in abstrakt.value.sache
    assert "Vorrat" not in abstrakt.value.sache
    assert "Vorrat" in ausserhalb.value.sache
    assert "abstrakt" not in ausserhalb.value.sache


def _quellen_aendern(ordner: Path, alt: str, neu: str) -> None:
    text = (ordner / "quellen.toml").read_text(encoding="utf-8")
    assert alt in text
    (ordner / "quellen.toml").write_text(text.replace(alt, neu, 1), encoding="utf-8")


def test_R3_F_003_dateien_in_quellen_toml_ohne_paare_ergibt_konfigurationsfehler(
    kopie: Path,
) -> None:
    text = (kopie / "quellen.toml").read_text(encoding="utf-8")
    (kopie / "quellen.toml").write_text(
        re.sub(r"\[dateien\].*", '[dateien]\nx = "y"\n', text, flags=re.S).replace(
            "[quelle]", "[quelle]\n", 1
        ),
        encoding="utf-8",
    )
    with pytest.raises(KonfigurationsFehler):
        schemata()
    # ValueError beim Aufbau der Liste: "dateien" als Zeichenkette statt als Tabelle.
    (kopie / "quellen.toml").write_text(
        text.replace("[dateien]", "dateien_alt = 1\n[unbenutzt]").replace(
            "[quelle]", 'dateien = "text"\n[quelle]', 1
        ),
        encoding="utf-8",
    )
    with pytest.raises(KonfigurationsFehler):
        schemata()


def test_R3_F_003_verzeichnis_nicht_lesbar_ergibt_konfigurationsfehler(
    kopie: Path, monkeypatch: pytest.MonkeyPatch
) -> None:
    def verweigert(self: Path) -> Iterator[Path]:
        raise PermissionError("synth")

    monkeypatch.setattr(Path, "iterdir", verweigert)
    with pytest.raises(KonfigurationsFehler):
        schemata()


def test_R3_F_003_schemadatei_nicht_lesbar_ergibt_konfigurationsfehler(
    kopie: Path,
) -> None:
    (kopie / "Person.yaml").unlink()
    (kopie / "Person.yaml").mkdir()  # vorhanden, aber nicht als Datei lesbar
    with pytest.raises(KonfigurationsFehler) as fehler:
        schemata()
    assert "Person.yaml" in str(fehler.value)


@pytest.mark.parametrize(
    "lizenzdatei", ["../LIZENZ.txt", "/etc/hostname", "unter/LIZENZ.txt", "..", "a\\b"]
)
def test_R3_F_003_lizenzdatei_ausserhalb_des_verzeichnisses_ergibt_konfigurationsfehler(
    kopie: Path, lizenzdatei: str
) -> None:
    _quellen_aendern(
        kopie, 'lizenzdatei = "LIZENZ.txt"', f"lizenzdatei = '{lizenzdatei}'"
    )
    with pytest.raises(KonfigurationsFehler) as fehler:
        schemata()
    assert "ausserhalb" in str(fehler.value)


@pytest.mark.parametrize(
    "name", ["../Person.yaml", "/etc/Person.yaml", "x/Person.yaml"]
)
def test_R3_F_003_dateiname_in_quellen_toml_ausserhalb_des_verzeichnisses_ergibt_konfigurationsfehler(
    kopie: Path, name: str
) -> None:
    _quellen_aendern(kopie, '"Person.yaml" =', f'"{name}" =')
    with pytest.raises(KonfigurationsFehler) as fehler:
        schemata()
    assert "ausserhalb" in str(fehler.value)


def test_R3_F_003_doppelter_schemaname_in_zwei_dateien_ergibt_konfigurationsfehler(
    kopie: Path,
) -> None:
    (kopie / "Person.yaml").write_bytes((kopie / "Address.yaml").read_bytes())
    _summe_nachtragen(kopie, "Person.yaml")
    with pytest.raises(KonfigurationsFehler) as fehler:
        schemata()
    assert "Person.yaml" in str(fehler.value)


@pytest.mark.parametrize(
    "inhalt",
    [
        b"Person:\n  no: x\n",  # Schlüssel der Definition kein str (YAML 1.1: False)
        b"Person:\n  properties:\n    name:\n      type: 5\n",  # type kein str
        b"Person:\n  required: [no]\n",  # required mit Namen, die kein str sind
    ],
)
def test_R3_F_003_typpruefung_auf_definitionsebene_ergibt_konfigurationsfehler(
    kopie: Path, inhalt: bytes
) -> None:
    (kopie / "Person.yaml").write_bytes(inhalt)
    _summe_nachtragen(kopie, "Person.yaml")
    with pytest.raises(KonfigurationsFehler):
        schemata()
