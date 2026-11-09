"""Schemata von FollowTheMoney aus den versionierten Dateien (ADR 0007, Festlegung S1.4; R3-F-003).

Rein, ohne Datenbank, kein Netz. Die 71 Schemadateien der Fassung 4.11.2 liegen byte-gleich
unter ftm_schema/ (Quelle und Summen in quellen.toml). Sie sind fremde Daten: sie werden mit
yaml.safe_load gelesen, nie ausgeführt; gelesen werden allein die Schlüssel extends, abstract,
required, edge (source, target) und properties (type, range). Das Laden geschieht beim ersten
Zugriff (nie beim Import) und prüft jede Datei gegen ihre Summe; jede Abweichung sperrt mit
KonfigurationsFehler (fail-closed, E-S14-12). Danach sind die Strukturen im Prozess
unveränderlich.
"""

import functools
import hashlib
import tomllib
from collections.abc import Mapping
from dataclasses import dataclass
from importlib import resources
from types import MappingProxyType
from typing import Any

import yaml

from r3cosint.core.fehler import KonfigurationsFehler, SchemaFehler
from r3cosint.kanon.eingabe import Datensatz

VORRAT_KNOTEN: frozenset[str] = frozenset(
    {"Person", "LegalEntity", "Organization", "Company", "Asset"}
)
"""Schemata für Knoten, die der Bestand annimmt (E-S14-01, Empfehlung b; Fortschreibung als Folgeeinheit)."""
VORRAT_KANTEN: frozenset[str] = frozenset(
    {"Ownership", "Directorship", "Control", "Employment", "Associate", "Family"}
)
"""Schemata für Kanten, die der Bestand annimmt (E-S14-01, Empfehlung b)."""

_PAKET = "r3cosint.kanon"
_VERZEICHNIS = "ftm_schema"
_QUELLEN = "quellen.toml"
_NAECHSTER_SCHRITT = (
    "Die Schemadateien nach dem Pflegeweg in quellen.toml wiederherstellen "
    "(Fassung 4.11.2 byte-gleich) oder die Einheit der Fassung wechseln."
)


@dataclass(frozen=True, slots=True)
class Eigenschaft:
    """Eine Eigenschaft eines Schemas: Name, Typ (Vorgabe "string") und Bereich (range, sonst None)."""

    name: str
    typ: str
    bereich: str | None


@dataclass(frozen=True, slots=True)
class Schema:
    """Ein Schema mit vererbten Eigenschaften.

    vorfahren: transitiv, einschliesslich des eigenen Namens. eigenschaften und pflicht sind
    vererbt. kante: Namen der Quell- und der Zieleigenschaft bei einem Kantenschema, sonst None.
    """

    name: str
    abstrakt: bool
    vorfahren: frozenset[str]
    eigenschaften: Mapping[str, Eigenschaft]
    pflicht: frozenset[str]
    kante: tuple[str, str] | None


def _fehler(sache: str) -> KonfigurationsFehler:
    return KonfigurationsFehler(sache, _NAECHSTER_SCHRITT)


def _summe(daten: bytes) -> str:
    return hashlib.sha256(daten).hexdigest()


def _rohdaten() -> dict[str, dict[str, Any]]:
    """Liest und prüft alle Dateien; Rückgabe: Schemaname nach Rohabbildung.

    Fehlerklasse: KonfigurationsFehler bei fehlender, zusätzlicher oder abweichender Datei
    (die Meldung nennt den Dateinamen), bei ungültigem YAML, TOML oder UTF-8, bei einer Datei ohne
    genau ein Schema und bei Schlüsseln oder Namen falschen Typs.
    """
    wurzel = resources.files(_PAKET).joinpath(_VERZEICHNIS)
    try:
        quellen = tomllib.loads(wurzel.joinpath(_QUELLEN).read_bytes().decode("utf-8"))
        erwartet: dict[str, str] = dict(quellen["dateien"])
        lizenz_summe = quellen["quelle"]["lizenz_sha256"]
        lizenzdatei = quellen["quelle"]["lizenzdatei"]
    except (
        OSError,
        KeyError,
        TypeError,
        ValueError,
        UnicodeDecodeError,
        tomllib.TOMLDecodeError,
    ):
        raise _fehler(
            f"Die Herkunftsdatei {_QUELLEN} der Schemadateien fehlt oder ist ungültig."
        ) from None
    if (
        not isinstance(lizenz_summe, str)
        or not isinstance(lizenzdatei, str)
        or not all(
            isinstance(name, str) and isinstance(summe, str)
            for name, summe in erwartet.items()
        )
    ):
        raise _fehler(f"Die Herkunftsdatei {_QUELLEN} hat Angaben falschen Typs.")
    # Namen aus quellen.toml bleiben im Verzeichnis: kein Pfadtrenner, kein "..", nicht absolut.
    for name in (lizenzdatei, *erwartet):
        if not _einfacher_dateiname(name):
            raise _fehler(
                f"Die Herkunftsdatei {_QUELLEN} nennt einen Dateinamen ausserhalb des Verzeichnisses."
            )
    try:
        vorhanden = {
            eintrag.name
            for eintrag in wurzel.iterdir()
            if eintrag.name.endswith(".yaml")
        }
    except OSError:
        raise _fehler("Das Verzeichnis der Schemadateien ist nicht lesbar.") from None
    for name in sorted(vorhanden - erwartet.keys()):
        raise _fehler(f"Die Schemadatei {name} steht nicht in {_QUELLEN}.")
    for name in sorted(erwartet.keys() - vorhanden):
        raise _fehler(f"Die Schemadatei {name} fehlt.")
    try:
        lizenz = wurzel.joinpath(lizenzdatei).read_bytes()
    except OSError:
        raise _fehler(f"Die Lizenzdatei {lizenzdatei} fehlt.") from None
    if _summe(lizenz) != lizenz_summe:
        raise _fehler(f"Die Lizenzdatei {lizenzdatei} weicht von ihrer Summe ab.")
    roh: dict[str, dict[str, Any]] = {}
    for name in sorted(erwartet):
        # Einmal gelesen: dieselben Bytes für die Summe und für safe_load (SD-S14-01).
        try:
            daten = wurzel.joinpath(name).read_bytes()
        except OSError:
            raise _fehler(f"Die Schemadatei {name} ist nicht lesbar.") from None
        if _summe(daten) != erwartet[name]:
            raise _fehler(f"Die Schemadatei {name} weicht von ihrer Summe ab.")
        try:
            inhalt = yaml.safe_load(daten.decode("utf-8"))
        except (yaml.YAMLError, UnicodeDecodeError):
            raise _fehler(f"Die Schemadatei {name} ist kein gültiges YAML.") from None
        if (
            not isinstance(inhalt, dict)
            or len(inhalt) != 1
            or not all(isinstance(wert, dict) for wert in inhalt.values())
        ):
            raise _fehler(f"Die Schemadatei {name} enthält nicht genau ein Schema.")
        ((schemaname, definition),) = inhalt.items()
        _typen_pruefen(name, schemaname, definition)
        if schemaname in roh:
            raise _fehler(f"Die Schemadatei {name} wiederholt einen Schemanamen.")
        roh[schemaname] = definition
    return roh


def _einfacher_dateiname(name: str) -> bool:
    """Ein Name ohne Pfadtrenner, ohne "..", ohne Laufwerk, nicht leer und nicht absolut (kein Zugriff ausserhalb)."""
    return (
        bool(name)
        and name not in {".", ".."}
        and not any(zeichen in name for zeichen in ("/", "\\", ":", "\x00"))
    )


def _namen(name: str, wert: object) -> None:
    """Jeder Name einer Liste ist str (YAML 1.1 liest etwa no als False)."""
    if wert is None:
        return
    if not isinstance(wert, list) or not all(
        isinstance(eintrag, str) for eintrag in wert
    ):
        raise _fehler(f"Die Schemadatei {name} nennt Namen falschen Typs.")


def _typen_pruefen(name: str, schemaname: object, definition: dict[Any, Any]) -> None:
    """Typprüfung nach dem Laden: Schlüssel und Namen str, abstract bool (fail-closed)."""
    if not isinstance(schemaname, str) or not all(
        isinstance(schluessel, str) for schluessel in definition
    ):
        raise _fehler(f"Die Schemadatei {name} nennt Schlüssel falschen Typs.")
    abstrakt = definition.get("abstract")
    if abstrakt is not None and not isinstance(abstrakt, bool):
        raise _fehler(f"Die Schemadatei {name} nennt abstract falschen Typs.")
    _namen(name, definition.get("extends"))
    _namen(name, definition.get("required"))
    kante = definition.get("edge")
    if kante is not None:
        if (
            not isinstance(kante, dict)
            or not isinstance(kante.get("source"), str)
            or not isinstance(kante.get("target"), str)
        ):
            raise _fehler(f"Die Schemadatei {name} nennt edge falschen Typs.")
    eigenschaften = definition.get("properties")
    if eigenschaften is None:
        return
    if not isinstance(eigenschaften, dict):
        raise _fehler(f"Die Schemadatei {name} nennt properties falschen Typs.")
    for eigenschaftsname, angaben in eigenschaften.items():
        if not isinstance(eigenschaftsname, str) or not (
            angaben is None or isinstance(angaben, dict)
        ):
            raise _fehler(
                f"Die Schemadatei {name} nennt eine Eigenschaft falschen Typs."
            )
        for schluessel in ("type", "range"):
            if (
                angaben is not None
                and schluessel in angaben
                and not isinstance(angaben[schluessel], str)
            ):
                raise _fehler(
                    f"Die Schemadatei {name} nennt {schluessel} falschen Typs."
                )


def _aufloesen(
    name: str,
    roh: Mapping[str, Mapping[str, Any]],
    fertig: dict[str, Schema],
    pfad: tuple[str, ...],
) -> Schema:
    """Bildet ein Schema samt Vorfahren (Reihenfolge der Elternliste, spätere überschreiben nicht)."""
    if name in fertig:
        return fertig[name]
    if name in pfad:
        raise _fehler(f"Die Vererbung von {name} ist zyklisch.")
    definition = roh[name]
    vorfahren = {name}
    eigenschaften: dict[str, Eigenschaft] = {}
    pflicht: set[str] = set()
    for eltern in definition.get("extends") or []:
        if eltern not in roh:
            raise _fehler(f"Das Schema {name} erweitert ein unbekanntes Schema.")
        vater = _aufloesen(eltern, roh, fertig, (*pfad, name))
        vorfahren |= vater.vorfahren
        for eigenschaftsname, eigenschaft in vater.eigenschaften.items():
            eigenschaften.setdefault(eigenschaftsname, eigenschaft)
        pflicht |= vater.pflicht
    for eigenschaftsname, angaben in (definition.get("properties") or {}).items():
        angaben = angaben or {}
        eigenschaften[str(eigenschaftsname)] = Eigenschaft(
            name=str(eigenschaftsname),
            typ=str(angaben.get("type", "string")),
            bereich=(str(angaben["range"]) if "range" in angaben else None),
        )
    pflicht |= {str(eintrag) for eintrag in (definition.get("required") or [])}
    kante_roh = definition.get("edge")
    kante: tuple[str, str] | None = None
    if kante_roh is not None:
        kante = (str(kante_roh["source"]), str(kante_roh["target"]))
    schema = Schema(
        name=name,
        abstrakt=definition.get("abstract") is True,
        vorfahren=frozenset(vorfahren),
        eigenschaften=MappingProxyType(eigenschaften),
        pflicht=frozenset(pflicht),
        kante=kante,
    )
    fertig[name] = schema
    return schema


@functools.cache
def schemata() -> Mapping[str, Schema]:
    """Lädt und prüft die Schemadateien beim ersten Zugriff; danach unveränderlich im Prozess.

    Rückgabe: unveränderliche Abbildung Schemaname nach Schema (71 Einträge in Fassung 4.11.2).
    Fehlerklasse: KonfigurationsFehler (fail-closed; ein Fehlschlag wird nicht gemerkt, der
    nächste Zugriff prüft erneut). Transaktionspflicht: keine.
    """
    roh = _rohdaten()
    fertig: dict[str, Schema] = {}
    for name in roh:
        _aufloesen(name, roh, fertig, ())
    return MappingProxyType(fertig)


def vorrat() -> frozenset[str]:
    """Liefert die Schemata, die der Bestand annimmt (Vereinigung von VORRAT_KNOTEN und VORRAT_KANTEN).

    Bei Option (a) von E-S14-01 liefert diese Funktion alle nicht abstrakten Schemata; nichts
    sonst ändert sich. Parameter: keine. Rückgabe: unveränderliche Menge von Schemanamen.
    Fehlerklasse: keine (reine Konstanten, die Schemadateien werden nicht geladen).
    Transaktionspflicht: keine.
    """
    return VORRAT_KNOTEN | VORRAT_KANTEN


def pruefen(datensatz: Datensatz) -> Schema:
    """Prüft einen Datensatz gegen die Schemata nach der Zeile Umfang (E-S14-07), ohne Datenbank.

    Geprüft: Schema bekannt, nicht abstrakt, im Vorrat; jede Eigenschaft dem Schema bekannt
    (eigene oder vererbte); Eigenschaften vom Typ entity nur als source oder target eines
    Kantenschemas, mit genau einem Wert; jede Pflichteigenschaft vorhanden. Nicht geprüft
    werden die übrigen Werttypen (GS-33).
    Parameter: datensatz. Rückgabe: das Schema. Fehlerklasse: SchemaFehler, deren sache allein
    Namen aus den Schemadateien nennt, nie Werte oder vom Aufrufer gelieferte Namen (DS-S14-01);
    KonfigurationsFehler, wenn die Schemadateien nicht geladen werden können.
    Transaktionspflicht: keine.
    """
    bekannt = schemata()
    schema = bekannt.get(datensatz.ftm_schema)
    if schema is None:
        raise SchemaFehler("Das Schema ist unbekannt.")
    if schema.abstrakt:
        raise SchemaFehler(f"Das Schema {schema.name} ist abstrakt.")
    if schema.name not in vorrat():
        raise SchemaFehler(f"Das Schema {schema.name} gehört nicht zum Vorrat.")
    enden = frozenset(schema.kante) if schema.kante is not None else frozenset()
    for name, werte in datensatz.eigenschaften.items():
        eigenschaft = schema.eigenschaften.get(name)
        if eigenschaft is None:
            raise SchemaFehler(
                f"Eine Eigenschaft ist dem Schema {schema.name} unbekannt."
            )
        if eigenschaft.typ == "entity":
            if name not in enden:
                raise SchemaFehler(
                    f"Eine Eigenschaft vom Typ entity ist im Schema {schema.name} nur als Ende einer Kante zulässig."
                )
            if len(werte) != 1:
                raise SchemaFehler(f"Das Ende {name} der Kante trägt genau einen Wert.")
    for name in sorted(schema.pflicht):
        if name not in datensatz.eigenschaften:
            raise SchemaFehler(
                f"Die Pflichteigenschaft {name} fehlt im Schema {schema.name}."
            )
    return schema


def ende_pruefen(schema: Schema, rolle: str, ende_schema: str) -> None:
    """Prüft, dass das Schema eines Kantenendes dem range der Eigenschaft entspricht.

    Parameter: schema (Kantenschema), rolle (Name der Quell- oder Zieleigenschaft der Kante,
    zum Beispiel owner), ende_schema (Schemaname des gefundenen Knotens). Zulässig ist range
    selbst oder ein Unterschema davon. Fehlerklasse: SchemaFehler, wenn rolle kein Ende des
    Schemas ist oder ende_schema weder range noch ein Unterschema davon ist (die sache nennt
    allein Namen aus den Schemadateien). Transaktionspflicht: keine.
    """
    if schema.kante is None or rolle not in schema.kante:
        raise SchemaFehler(f"{rolle} ist kein Ende des Schemas {schema.name}.")
    eigenschaft = schema.eigenschaften[rolle]
    unterschema = schemata().get(ende_schema)
    if (
        eigenschaft.bereich is None
        or unterschema is None
        or eigenschaft.bereich not in unterschema.vorfahren
    ):
        raise SchemaFehler(
            f"Das Ende {rolle} der Kante {schema.name} verlangt ein anderes Schema."
        )
