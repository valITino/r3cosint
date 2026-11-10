"""Positivliste der Verbindungen nach aussen (ADR 0008, Nr. 14, Festlegung S2.1; R3-F-015).

Nur freigegebene Gegenstellen sind erreichbar (5.4). Die Datei positivliste.toml je Umgebung
wird einmal als Bytes gelesen; listenstand ist der SHA-256 dieser Bytes. Werte in der Datei
müssen schon in Normalform nach ausgang.ziel stehen: ein Wert, dessen Normalform abweicht,
wird abgewiesen, nicht normalisiert (FA-S21-08). Fehlertexte nennen Schlüssel, Eintrag und Art
des Fehlers, nie einen Wert und nie den Pfad; sie entstehen ausserhalb jedes except-Blocks.
"""

import hashlib
import re
import tomllib
from pathlib import Path
from typing import Annotated, Any, Literal

from pydantic import BaseModel, ConfigDict, Field
from pydantic.dataclasses import dataclass

from r3cosint.ausgang.ziel import Schema, Ziel, Zielart, ZielFehler, aus_url
from r3cosint.core.fehler import KonfigurationsFehler

_KONFIGURATION = ConfigDict(
    frozen=True, extra="forbid", strict=True, hide_input_in_errors=True
)
_KENNUNG = re.compile(r"^[a-z0-9._-]{1,64}$")
_NAME_ZEICHEN = re.compile(r"^[a-z0-9.-]+$")
_ADRESS_ZEICHEN = re.compile(r"^[0-9a-f.:]+$")
_STAND = re.compile(r"^[0-9a-f]{64}$")
_KOPF_SCHLUESSEL = frozenset(
    {
        "format",
        "umgebung",
        "ausgang_weiterleitungen_hoechstzahl",
        "stillgelegt",
        "eintrag",
    }
)
_EINTRAG_SCHLUESSEL = frozenset(
    {"kennung", "schema", "rechnername", "adresse", "anschluss"}
)
HOECHSTZAHL_GRENZE = 10
_NAECHSTER_SCHRITT = "Die Datei positivliste.toml der Umgebung prüfen und nach Nr. 14 der Festlegung berichtigen."

Umgebung = Literal["test", "produktion"]


@dataclass(
    frozen=True,
    config=ConfigDict(extra="forbid", strict=True, hide_input_in_errors=True),
)
class Listeneintrag:
    """Ein freigegebenes Ziel: rechnername oder adresse (genau eines), Schema und Anschluss.

    Als Pydantic-Datenklasse, damit das Feld schema heissen darf (ein Modell trüge die
    Methode schema der Basisklasse).
    """

    kennung: Annotated[str, Field(pattern=_KENNUNG.pattern)]
    schema: Schema
    anschluss: Annotated[int, Field(ge=1, le=65535)]
    rechnername: str | None = None
    adresse: str | None = None

    def __post_init__(self) -> None:
        if (self.rechnername is None) == (self.adresse is None):
            raise ValueError("rechnername oder adresse, genau eines von beiden")

    def schluessel(self) -> tuple[str, Zielart, str, int]:
        """Gleichheitsschlüssel (schema, Art, Wert in Normalform, anschluss)."""
        if self.rechnername is not None:
            return (self.schema, "name", self.rechnername, self.anschluss)
        wert = self.adresse or ""
        return (self.schema, "ipv6" if ":" in wert else "ipv4", wert, self.anschluss)


class Positivliste(BaseModel):
    """Die geladene Liste einer Umgebung mit dem Stand der Datei."""

    model_config = _KONFIGURATION

    eintraege: tuple[Listeneintrag, ...]
    ausgang_weiterleitungen_hoechstzahl: Annotated[
        int, Field(ge=0, le=HOECHSTZAHL_GRENZE)
    ]
    umgebung: Umgebung
    listenstand: Annotated[str, Field(pattern=_STAND.pattern)]

    def eintrag_fuer(self, ziel: Ziel) -> Listeneintrag | None:
        """Der Eintrag, der das Ziel deckt (Gleichheit über schema, Art, Wert, anschluss).

        Ein Name in der Liste deckt keine Adresse und umgekehrt.
        """
        gesucht = (ziel.schema, ziel.art, ziel.wert, ziel.anschluss)
        for eintrag in self.eintraege:
            if eintrag.schluessel() == gesucht:
                return eintrag
        return None


def _fehler(
    schluessel: str, art: str, nummer: int | None = None, kennung: str | None = None
) -> KonfigurationsFehler:
    """Fester Text: Schlüssel, Eintrag und Art des Fehlers, nie ein Wert und nie der Pfad."""
    ort = "" if nummer is None else f", Eintrag Nr. {nummer}"
    ort += "" if kennung is None else f" (Kennung {kennung})"
    return KonfigurationsFehler(
        f"Die Positivliste ist ungültig: Schlüssel {schluessel}{ort}, Fehlerart {art}.",
        _NAECHSTER_SCHRITT,
    )


def _ist_ganzzahl(wert: object) -> bool:
    return type(wert) is int


def _text_gleich(
    ziel_url: str, schema: str, art: Zielart, wert: str, anschluss: int
) -> bool:
    """Ob die URL ein Ziel genau dieser Form ergibt (Normalform gleich dem Wert der Datei)."""
    try:
        ziel = aus_url(ziel_url)
    except ZielFehler:
        return False
    return (ziel.schema, ziel.art, ziel.wert, ziel.anschluss) == (
        schema,
        art,
        wert,
        anschluss,
    )


def _eintrag_pruefen(
    roh: object, stillgelegt: frozenset[str]
) -> tuple[Listeneintrag | None, str, str, str | None]:
    """Prüft einen Eintrag. Rückgabe: Eintrag oder None, Schlüssel, Fehlerart, Kennung."""
    if not isinstance(roh, dict) or not set(roh) <= _EINTRAG_SCHLUESSEL:
        return None, "eintrag", "unbekannt", None
    kennung = roh.get("kennung")
    if not isinstance(kennung, str) or not _KENNUNG.fullmatch(kennung):
        return None, "kennung", "form", None
    schema = roh.get("schema")
    if schema not in ("http", "https"):
        return None, "schema", "form", kennung
    anschluss = roh.get("anschluss")
    if type(anschluss) is not int or not 1 <= anschluss <= 65535:
        return None, "anschluss", "form", kennung
    name, adresse = roh.get("rechnername"), roh.get("adresse")
    if (name is None) == (adresse is None):
        return None, "rechnername", "beides_oder_keines", kennung
    if kennung in stillgelegt:
        return None, "kennung", "stillgelegt", kennung
    if name is not None:
        if not isinstance(name, str) or not _NAME_ZEICHEN.fullmatch(name):
            return None, "rechnername", "form", kennung
        if not _text_gleich(
            f"{schema}://{name}:{anschluss}", schema, "name", name, anschluss
        ):
            return None, "rechnername", "nicht_normalisiert", kennung
    else:
        if not isinstance(adresse, str) or not _ADRESS_ZEICHEN.fullmatch(adresse):
            return None, "adresse", "form", kennung
        art: Zielart = "ipv6" if ":" in adresse else "ipv4"
        host = f"[{adresse}]" if art == "ipv6" else adresse
        if not _text_gleich(
            f"{schema}://{host}:{anschluss}", schema, art, adresse, anschluss
        ):
            return None, "adresse", "nicht_normalisiert", kennung
    eintrag = Listeneintrag(
        kennung=kennung,
        schema=schema,
        anschluss=anschluss,
        rechnername=name,
        adresse=adresse,
    )
    return eintrag, "", "", kennung


def _kopf_pruefen(roh: dict[str, Any], umgebung: Umgebung) -> tuple[str, str] | None:
    """Prüft die Schlüssel auf Kopfebene. Rückgabe: (Schlüssel, Fehlerart) oder None."""
    if not set(roh) <= _KOPF_SCHLUESSEL:
        return "datei", "unbekannt"
    for schluessel in (
        "format",
        "umgebung",
        "ausgang_weiterleitungen_hoechstzahl",
        "stillgelegt",
    ):
        if schluessel not in roh:
            return schluessel, "fehlt"
    if not _ist_ganzzahl(roh["format"]) or roh["format"] != 1:
        return "format", "form"
    if roh["umgebung"] != umgebung:
        return "umgebung", "abweichend"
    hoechstzahl = roh["ausgang_weiterleitungen_hoechstzahl"]
    if not _ist_ganzzahl(hoechstzahl) or not 0 <= hoechstzahl <= HOECHSTZAHL_GRENZE:
        return "ausgang_weiterleitungen_hoechstzahl", "bereich"
    stillgelegt = roh["stillgelegt"]
    if not isinstance(stillgelegt, list) or not all(
        isinstance(k, str) and _KENNUNG.fullmatch(k) for k in stillgelegt
    ):
        return "stillgelegt", "form"
    if not isinstance(roh.get("eintrag", []), list):
        return "eintrag", "form"
    return None


def laden(pfad: Path, *, umgebung: Umgebung) -> Positivliste:
    """Lädt die Positivliste einer Umgebung.

    Liest die Datei einmal als Bytes; listenstand ist der SHA-256 dieser Bytes (hexadezimal,
    klein). Fehlerfall: KonfigurationsFehler mit festem Text ohne Wert und ohne Pfad, bei
    unlesbarer Datei, jeder Formverletzung, abweichender umgebung (die Liste von Test/Schulung
    lässt sich in Produktion nicht laden, 5.16), doppelter Kennung, stillgelegter Kennung,
    doppeltem Ziel und nicht normalisiertem Wert.
    """
    roh: dict[str, Any] | None
    try:
        daten = pfad.read_bytes()
        roh = tomllib.loads(daten.decode("utf-8"))
    except (OSError, ValueError):
        daten, roh = b"", None
    if roh is None:
        raise _fehler("datei", "unlesbar")
    verstoss = _kopf_pruefen(roh, umgebung)
    if verstoss is not None:
        raise _fehler(*verstoss)
    stillgelegt = frozenset(roh["stillgelegt"])
    eintraege: list[Listeneintrag] = []
    for nummer, eintrag_roh in enumerate(roh.get("eintrag", []), start=1):
        eintrag, schluessel, art, kennung = _eintrag_pruefen(eintrag_roh, stillgelegt)
        if eintrag is None:
            raise _fehler(schluessel, art, nummer, kennung)
        eintraege.append(eintrag)
    if len({e.kennung for e in eintraege}) != len(eintraege):
        raise _fehler("kennung", "doppelt")
    if len({e.schluessel() for e in eintraege}) != len(eintraege):
        raise _fehler("eintrag", "ziel_doppelt")
    return Positivliste(
        eintraege=tuple(eintraege),
        ausgang_weiterleitungen_hoechstzahl=roh["ausgang_weiterleitungen_hoechstzahl"],
        umgebung=umgebung,
        listenstand=hashlib.sha256(daten).hexdigest(),
    )
