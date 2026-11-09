"""Eingabe der Eröffnung eines Falls, Vorräte und Angleichung (ADR 0007, Festlegung S1.3; R3-F-001).

Rein, ohne Datenbank. Die Klartextfelder der Eröffnung stehen nie in repr oder str.
Der Ausgabetyp Fall steht hier (und wird über fall.service öffentlich gemacht), damit
fall.store ihn zurückgeben kann, ohne fall.service zu importieren (kein Zirkelbezug).
"""

import unicodedata
from dataclasses import dataclass
from datetime import datetime
from enum import StrEnum
from typing import Annotated
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field, StringConstraints, field_validator

from r3cosint.core.fehler import EingabeFehler
from r3cosint.core.kennung import benutzerkennung_pruefen

_KONFIGURATION = ConfigDict(
    frozen=True, extra="forbid", strict=True, hide_input_in_errors=True
)
_AKTENZEICHEN_HOECHSTLAENGE = 100
_RECHTSGRUNDLAGE_HOECHSTLAENGE = 2000


class Rechtsregime(StrEnum):
    """Rechtsregime eines Falls; R3 bis R5 sind kein Regime eines Falls (W1-02, E-S1-09 a)."""

    R1 = "R1"
    R2 = "R2"


class Fallzustand(StrEnum):
    """Zustand der Aufbewahrung; spiegelt die Prüfbedingung fall_zustand_vorrat in ihrer Reihenfolge.

    Erreichbar sind in Sprint 1 allein AKTIV und ABGESCHLOSSEN (GS-21).
    """

    AKTIV = "aktiv"
    ABGESCHLOSSEN = "abgeschlossen"
    PRUEFUNG_FAELLIG = "pruefung_faellig"
    VERLAENGERT = "verlaengert"
    ZUR_LOESCHUNG_FREIGEGEBEN = "zur_loeschung_freigegeben"
    GELOESCHT = "geloescht"
    ARCHIVIERT = "archiviert"


@dataclass(frozen=True, slots=True)
class Fall:
    """Ein Fall ohne Schlüssel und ohne Klartext (ADR 0007, Nr. 26).

    Aktenzeichen, Rechtsgrundlage und ermittelnde Person bleiben in der Tabelle. Zeitpunkte
    sind zeitbewusst, in UTC.
    """

    kennung: UUID
    rechtsregime: Rechtsregime
    fallkategorie: str
    zustand: Fallzustand
    eroeffnet_am: datetime
    geschlossen_am: datetime | None
    prueffrist_bis: datetime | None


def _angleichen(wert: str, hoechstlaenge: int) -> str:
    """Gemeinsame Angleichung: NFC, Leerraum zusammengefasst, getrimmt; Cc, Cf und Cs abgewiesen.

    Fehlerfall: ValueError ohne den Wert, wenn das Ergebnis leer ist, ein Zeichen der
    Kategorien Cc, Cf oder Cs (Ersatzzeichen, E-S15-06) enthält oder länger als hoechstlaenge ist.
    """
    normal = unicodedata.normalize("NFC", wert)
    ergebnis = " ".join(normal.split())
    if not ergebnis:
        raise ValueError("Der Wert ist leer.")
    if any(unicodedata.category(zeichen) in ("Cc", "Cf", "Cs") for zeichen in ergebnis):
        raise ValueError("Der Wert enthält ein Steuer-, Format- oder Ersatzzeichen.")
    if len(ergebnis) > hoechstlaenge:
        raise ValueError(f"Der Wert ist länger als {hoechstlaenge} Zeichen.")
    return ergebnis


def aktenzeichen_angleichen(wert: str) -> str:
    """Gleicht ein Aktenzeichen an (E-S13-05 b): NFC, Leerraum zu einem Leerzeichen, getrimmt.

    Gross- und Kleinschreibung bleiben erhalten (GS-24). Höchstens 100 Zeichen nach der
    Angleichung. Fehlerfall: ValueError, dessen Text den Wert nicht nennt (leer, Zeichen der
    Kategorien Cc, Cf oder Cs, zu lang). Gespeichert und verglichen wird allein diese Form.
    """
    return _angleichen(wert, _AKTENZEICHEN_HOECHSTLAENGE)


def rechtsgrundlage_angleichen(wert: str) -> str:
    """Gleicht eine Rechtsgrundlage wie das Aktenzeichen an, Höchstlänge 2000 Zeichen (GS-27).

    Fehlerfall: ValueError, dessen Text den Wert nicht nennt.
    """
    return _angleichen(wert, _RECHTSGRUNDLAGE_HOECHSTLAENGE)


class Eroeffnung(BaseModel):
    """Eingabe der Eröffnung eines Falls; alle fünf Angaben sind Pflicht (W1-01).

    Das Modell trägt die angeglichene Form. repr und str nennen allein rechtsregime und
    fallkategorie. Der Aufrufer bildet die Eroeffnung; ein Validierungsfehler von Pydantic
    entsteht dort, nie in fall.service (GS-28).
    """

    model_config = _KONFIGURATION

    aktenzeichen: str = Field(repr=False)
    rechtsgrundlage: str = Field(repr=False)
    rechtsregime: Rechtsregime
    fallkategorie: Annotated[str, StringConstraints(pattern=r"^[a-z0-9_]{1,64}$")]
    ermittelnde_person: str = Field(repr=False)

    @field_validator("aktenzeichen")
    @classmethod
    def _aktenzeichen(cls, wert: str) -> str:
        return aktenzeichen_angleichen(wert)

    @field_validator("rechtsgrundlage")
    @classmethod
    def _rechtsgrundlage(cls, wert: str) -> str:
        return rechtsgrundlage_angleichen(wert)

    @field_validator("ermittelnde_person")
    @classmethod
    def _ermittelnde_person(cls, wert: str) -> str:
        try:
            return benutzerkennung_pruefen(wert)
        except EingabeFehler:
            raise ValueError(
                "Die ermittelnde Person hat nicht die Form der Benutzerkennung."
            ) from None
