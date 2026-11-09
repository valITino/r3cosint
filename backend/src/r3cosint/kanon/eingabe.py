"""Eingabe und Ausgabe des Bestands: Datensatz, Herkunft, Angleichung (ADR 0007, Festlegung S1.4; R3-F-003, R3-F-005).

Rein, ohne Datenbank. Die Eingaben sind unveränderlich, lassen keine fremden Felder zu und
nennen in Validierungsfehlern nie den Wert (hide_input_in_errors). Eigenschaftswerte und die
Abfrage der Herkunft stehen nie in repr oder str (DS-S14-01). Eine Abbildung in der Form von
FollowTheMoney (id, schema, properties) bildet den Datensatz (E-S14-03).
"""

import re
import unicodedata
from collections.abc import Mapping
from dataclasses import dataclass, field
from datetime import datetime
from enum import StrEnum
from typing import Annotated, Any
from uuid import UUID

from pydantic import (
    AwareDatetime,
    BaseModel,
    ConfigDict,
    Field,
    StringConstraints,
    TypeAdapter,
    field_validator,
    model_validator,
)

from r3cosint.core.fehler import EingabeFehler
from r3cosint.core.kennung import benutzerkennung_pruefen
from r3cosint.spur.kette import zeitpunkt_text
from r3cosint.spur.service import Kennzeichnung

_KONFIGURATION = ConfigDict(
    frozen=True, extra="forbid", strict=True, hide_input_in_errors=True
)
FTM_KENNUNG_MUSTER = r"^[A-Za-z0-9][A-Za-z0-9._:-]{0,127}$"
"""Form der FollowTheMoney-Kennung (id) einer Entität oder Kante; auch Prüfbedingung der Revision 0005."""
WERT_HOECHSTLAENGE = 4096
WERTE_HOECHSTZAHL = 100
ABFRAGE_HOECHSTLAENGE = 4096
EIGENSCHAFTEN_HOECHSTZAHL = 128
WERTE_GESAMT_HOECHSTZAHL = 1000
WERTE_GESAMT_HOECHSTLAENGE = 262_144
EIGENSCHAFTEN_HOECHSTBYTES = 1_048_576
"""Obergrenze der kanonischen JSON-Form der Eigenschaften in Bytes (wie die Prüfbedingung der Revision 0005)."""

_FtmKennung = Annotated[str, StringConstraints(pattern=FTM_KENNUNG_MUSTER)]
_Schemaname = Annotated[str, StringConstraints(pattern=r"^[A-Z][A-Za-z]{0,63}$")]
_Eigenschaftsname = Annotated[str, StringConstraints(pattern=r"^[a-z][A-Za-z]{0,63}$")]
_Werkzeug = Annotated[str, StringConstraints(pattern=r"^[a-z0-9._-]{1,64}$")]
_ERLAUBTE_STEUERZEICHEN = frozenset("\t\n\r")
_EIGENSCHAFTEN_ADAPTER: TypeAdapter[dict[str, list[str]]] = TypeAdapter(
    dict[str, list[str]]
)


def wert_angleichen(wert: str) -> str:
    """Gleicht einen Eigenschaftswert an (E-S14-07, GS-33): Unicode NFC, an den Enden getrimmt.

    Gross- und Kleinschreibung und innerer Leerraum bleiben. Parameter: wert. Rückgabe: die
    angeglichene Form. Fehlerklasse: ValueError ohne den Wert, wenn das Ergebnis leer ist, ein
    Zeichen der Kategorie Cc ausser U+0009, U+000A und U+000D oder der Kategorie Cs (Ersatzzeichen)
    enthält oder länger als 4096 Zeichen ist; Cf bleibt zulässig (GS-48). Transaktionspflicht:
    keine (rein).
    """
    ergebnis = unicodedata.normalize("NFC", wert).strip()
    if not ergebnis:
        raise ValueError("Der Wert ist leer.")
    if any(
        unicodedata.category(zeichen) == "Cs"
        or (
            unicodedata.category(zeichen) == "Cc"
            and zeichen not in _ERLAUBTE_STEUERZEICHEN
        )
        for zeichen in ergebnis
    ):
        raise ValueError("Der Wert enthält ein Steuer- oder Ersatzzeichen.")
    if len(ergebnis) > WERT_HOECHSTLAENGE:
        raise ValueError(f"Der Wert ist länger als {WERT_HOECHSTLAENGE} Zeichen.")
    return ergebnis


def werte_angleichen(werte: tuple[str, ...]) -> tuple[str, ...]:
    """Gleicht die Werte einer Eigenschaft an, entfernt Doppel, behält die Reihenfolge der ersten Nennung.

    Parameter: werte (mindestens einer, höchstens 100 vor der Angleichung). Rückgabe: Tupel
    der angeglichenen, verschiedenen Werte. Fehlerklasse: ValueError ohne Werte (leer, zu
    viele Werte oder ein Wert nach wert_angleichen abgewiesen). Transaktionspflicht: keine.
    """
    if not werte or len(werte) > WERTE_HOECHSTZAHL:
        raise ValueError(
            f"Eine Eigenschaft trägt mindestens einen und höchstens {WERTE_HOECHSTZAHL} Werte."
        )
    return tuple(dict.fromkeys(wert_angleichen(wert) for wert in werte))


class Datensatz(BaseModel):
    """Ein Datenpunkt in der Form von FollowTheMoney (E-S14-03): id, schema, properties.

    Das Modell trägt die angeglichene Form. repr und str nennen weder Kennung noch Werte.
    Der Aufrufer bildet den Datensatz mit model_validate aus der Abbildung; ein Fehler von
    Pydantic entsteht dort und wird in kanon.service zu SchemaFehler (nie mit input).
    """

    model_config = _KONFIGURATION | ConfigDict(populate_by_name=False)

    ftm_kennung: _FtmKennung = Field(alias="id", repr=False)
    ftm_schema: _Schemaname = Field(alias="schema")
    eigenschaften: Annotated[
        dict[
            _Eigenschaftsname,
            Annotated[
                tuple[str, ...], Field(min_length=1, max_length=WERTE_HOECHSTZAHL)
            ],
        ],
        Field(max_length=EIGENSCHAFTEN_HOECHSTZAHL),
    ] = Field(alias="properties", repr=False)

    @field_validator("eigenschaften", mode="before")
    @classmethod
    def _listen_zulassen(cls, wert: Any) -> Any:
        """Nimmt Listen als Werte einer Eigenschaft an (Form von FollowTheMoney), intern Tupel."""
        if isinstance(wert, Mapping):
            # Die Zahlen werden vor jeder Prüfung der einzelnen Elemente begrenzt (SD-S14-04).
            if len(wert) > EIGENSCHAFTEN_HOECHSTZAHL:
                raise ValueError("Zu viele Eigenschaften.")
            if any(
                isinstance(werte, list | tuple) and len(werte) > WERTE_HOECHSTZAHL
                for werte in wert.values()
            ):
                raise ValueError("Zu viele Werte je Eigenschaft.")
            return {
                name: tuple(werte) if isinstance(werte, list) else werte
                for name, werte in wert.items()
            }
        return wert

    @field_validator("eigenschaften")
    @classmethod
    def _angleichen(
        cls, wert: dict[str, tuple[str, ...]]
    ) -> dict[str, tuple[str, ...]]:
        """Gleicht jeden Wert an und entfernt Doppel (werte_angleichen)."""
        return {name: werte_angleichen(werte) for name, werte in wert.items()}

    @model_validator(mode="after")
    def _gesamtgroesse(self) -> "Datensatz":
        """Begrenzt Gesamtzahl (1000), Gesamtlänge (262 144 Zeichen) und Grösse der JSON-Form (1 MiB) (SD-S14-04)."""
        werte = [wert for liste in self.eigenschaften.values() for wert in liste]
        if len(werte) > WERTE_GESAMT_HOECHSTZAHL:
            raise ValueError("Zu viele Werte im Datensatz.")
        if sum(len(wert) for wert in werte) > WERTE_GESAMT_HOECHSTLAENGE:
            raise ValueError("Die Werte des Datensatzes sind insgesamt zu lang.")
        # Grösse der JSON-Form in Bytes wie PostgreSQL sie als Text ausgibt (", " und ": " mit
        # Leerzeichen): kompakte Form plus je ein Byte für Komma und Doppelpunkt nach dem Leerzeichen.
        kompakt = _EIGENSCHAFTEN_ADAPTER.dump_json(
            {name: list(liste) for name, liste in self.eigenschaften.items()}
        )
        zahl_werte = sum(len(liste) for liste in self.eigenschaften.values())
        zahl_namen = len(self.eigenschaften)
        if len(kompakt) + zahl_werte + zahl_namen - 1 > EIGENSCHAFTEN_HOECHSTBYTES:
            raise ValueError(
                "Die Eigenschaften des Datensatzes sind in Bytes zu gross."
            )
        return self


class Herkunft(BaseModel):
    """Herkunftsangabe eines Datenpunkts (Nr. 25, R3-F-005); alle fünf Angaben sind Pflicht.

    zeitpunkt ist der Zeitpunkt der Erhebung (E-S14-06), erhebende_person die Person, die
    erhoben hat (getrennt von der handelnden Person, E-S14-13); kennzeichnung hat keinen
    Vorgabewert. repr und str nennen die Abfrage nie.
    """

    model_config = _KONFIGURATION

    werkzeug: _Werkzeug
    abfrage: str = Field(repr=False)
    zeitpunkt: AwareDatetime
    erhebende_person: str
    kennzeichnung: Kennzeichnung

    @field_validator("abfrage")
    @classmethod
    def _abfrage(cls, wert: str) -> str:
        """Lässt die Abfrage unverändert, weist leer, nur Leerraum, NUL, Ersatzzeichen und über 4096 Zeichen ab."""
        if (
            not wert.strip()
            or "\x00" in wert
            or len(wert) > ABFRAGE_HOECHSTLAENGE
            or re.search(r"\S", wert) is None
            or any(unicodedata.category(zeichen) == "Cs" for zeichen in wert)
        ):
            raise ValueError(
                "Die Abfrage ist leer, enthält NUL oder ein Ersatzzeichen oder ist zu lang."
            )
        return wert

    @field_validator("zeitpunkt")
    @classmethod
    def _zeitpunkt(cls, wert: datetime) -> datetime:
        """Weist einen Zeitpunkt ausserhalb des Bereichs der Spuren ab (zeitpunkt_text)."""
        zeitpunkt_text(wert)
        return wert

    @field_validator("erhebende_person")
    @classmethod
    def _erhebende_person(cls, wert: str) -> str:
        try:
            return benutzerkennung_pruefen(wert)
        except EingabeFehler:
            raise ValueError(
                "Die erhebende Person hat nicht die Form der Benutzerkennung."
            ) from None


class Datenpunktart(StrEnum):
    """Art eines Datenpunkts: Knoten (Tabelle entitaet) oder Kante (Tabelle beziehung)."""

    KNOTEN = "knoten"
    KANTE = "kante"


class Herkunftsluecke(StrEnum):
    """Die vier Formen eines unvollständigen Herkunftsnachweises (FA-S14-07)."""

    VERWEIS_INS_LEERE = "verweis_ins_leere"
    ANDERER_FALL = "anderer_fall"
    UNVOLLSTAENDIG = "unvollstaendig"
    MEHRFACH_VERWENDET = "mehrfach_verwendet"


@dataclass(frozen=True, slots=True)
class Datenpunkt:
    """Ein gespeicherter Knoten oder eine gespeicherte Kante.

    quelle_kennung und ziel_kennung sind bei Knoten None. ftm_kennung und eigenschaften
    stehen nie in repr (Falldaten, DS-S14-01).
    """

    kennung: UUID
    art: Datenpunktart
    fall_kennung: UUID
    ftm_schema: str
    herkunft_kennung: UUID
    erstellt_am: datetime
    quelle_kennung: UUID | None
    ziel_kennung: UUID | None
    ftm_kennung: str = field(repr=False)
    eigenschaften: Mapping[str, tuple[str, ...]] = field(repr=False)


@dataclass(frozen=True, slots=True)
class Herkunftssatz:
    """Ein gespeicherter Herkunftssatz; die Abfrage steht nie in repr."""

    kennung: UUID
    fall_kennung: UUID
    werkzeug: str
    zeitpunkt: datetime
    erhebende_person: str
    kennzeichnung: Kennzeichnung
    erstellt_am: datetime
    abfrage: str = field(repr=False)


@dataclass(frozen=True, slots=True)
class Herkunftsbefund:
    """Ergebnis von herkunft_pruefen: allein Zählwerte, keine Kennungen (E-S14-10).

    anzahl: Datenpunkte mit mindestens einer Lücke (Soll 0); je_form: Zahl je Form;
    knoten und kanten: Zahl aller Datenpunkte je Art im geprüften Bestand; isolationsstufe:
    Wert von current_setting('transaction_isolation') der prüfenden Transaktion (etwa
    "read committed" oder "repeatable read"), damit der Leser sieht, ob der Befund einen einzigen
    Stand wiedergibt (DF-S14-07, Hinweis 2).
    """

    anzahl: int
    je_form: Mapping[Herkunftsluecke, int]
    knoten: int
    kanten: int
    isolationsstufe: str
