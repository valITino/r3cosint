"""Nutzlast der Einträge: Eingaben im Klartext, Pseudonymisierung, kanonische Serialisierung.

ADR 0007, Nr. 17, 21 und 26 und Festlegung S1.2 (R3-F-011, R3-F-008). Die Nutzlast trägt
Klartext allein für Kennungen, geschlossene Vorräte, Zeitpunkte und ganze Zahlen; jede
andere Angabe steht als Pseudonym (HMAC-SHA-256 mit dem Schlüssel des Falls).
"""

import hashlib
import hmac
import json
import unicodedata
from typing import Annotated, Literal
from uuid import UUID

from pydantic import AwareDatetime, BaseModel, ConfigDict, Field, StringConstraints

from r3cosint.spur.kette import zeitpunkt_text

_KONFIGURATION = ConfigDict(
    frozen=True, extra="forbid", strict=True, hide_input_in_errors=True
)
_PSEUDONYM_ETIKETT = b"r3cosint-pseudonym-1\n"
_BINDUNG_ETIKETT = b"r3cosint-bindung-1\n"
_SCHLUESSEL_LAENGE = 32
_GANZZAHL_GRENZE = 2**53 - 1

_Fallkategorie = Annotated[str, StringConstraints(pattern=r"^[a-z0-9_]{1,64}$")]
_Schema = Annotated[str, StringConstraints(pattern=r"^[A-Z][A-Za-z]{0,63}$")]
EIGENSCHAFTSNAME_MUSTER = r"^[a-z][A-Za-z]{0,63}$"
"""Form eines Eigenschaftsnamens in der Nutzlast (der Architekturtest zu kanon liest sie hier)."""
_Eigenschaftsname = Annotated[str, StringConstraints(pattern=EIGENSCHAFTSNAME_MUSTER)]
_Werkzeug = Annotated[str, StringConstraints(pattern=r"^[a-z0-9._-]{1,64}$")]
_Person = Annotated[str, StringConstraints(pattern=r"^[a-z0-9._-]{1,64}$")]
_Eigenschaften = dict[
    _Eigenschaftsname, Annotated[tuple[str, ...], Field(min_length=1)]
]


def normalisieren(wert: str) -> str:
    """Normalform eines Werts für das Pseudonym (E-S1-06).

    Unicode NFC, casefold, erneut NFC, jede Folge von Leerraum (Menge von str.split) zu einem
    Leerzeichen, an den Enden getrimmt. Fehlerfall: ValueError, wenn das Ergebnis leer ist.
    """
    normal = unicodedata.normalize("NFC", unicodedata.normalize("NFC", wert).casefold())
    ergebnis = " ".join(normal.split())
    if not ergebnis:
        raise ValueError("Der Wert ist nach der Normalisierung leer")
    return ergebnis


class Pseudonymisierer:
    """Bildet Pseudonyme eines Falls; der Schlüssel (32 Bytes) bleibt im Objekt."""

    __slots__ = ("_schluessel",)

    def __init__(self, schluessel: bytes) -> None:
        """Fehlerfall: ValueError, wenn der Schlüssel nicht genau 32 Bytes lang ist."""
        if len(schluessel) != _SCHLUESSEL_LAENGE:
            raise ValueError("Der Schlüssel muss genau 32 Bytes lang sein")
        self._schluessel = bytes(schluessel)

    def __repr__(self) -> str:
        """Darstellung ohne den Schlüssel."""
        return "Pseudonymisierer()"

    def __reduce__(self) -> str | tuple[object, ...]:
        """Das Objekt lässt sich nicht serialisieren: der Schlüssel verlässt den Speicher nicht."""
        raise TypeError("Pseudonymisierer lässt sich nicht serialisieren")

    def pseudonym(self, wert: str) -> str:
        """HMAC-SHA-256 über b"r3cosint-pseudonym-1\\n" + UTF-8 von normalisieren(wert).

        Hexadezimal klein, 64 Zeichen. Fehlerfall: ValueError bei leerem normalisiertem Wert.
        """
        nachricht = _PSEUDONYM_ETIKETT + normalisieren(wert).encode("utf-8")
        return hmac.new(self._schluessel, nachricht, hashlib.sha256).hexdigest()

    def bindung(self, wert: str) -> str:
        """HMAC-SHA-256 über b"r3cosint-bindung-1\\n" + die exakten UTF-8-Bytes des Werts (DF-S14-01).

        Ohne Normalisierung: eine Änderung allein der Schreibweise oder des Leerraums ergibt eine
        andere Bindung, aber dasselbe Pseudonym. Hexadezimal klein, 64 Zeichen. Fehlerfall:
        ValueError ohne den Wert im Text, wenn der Wert leer ist.
        """
        if not wert:
            raise ValueError("Der Wert ist leer")
        nachricht = _BINDUNG_ETIKETT + wert.encode("utf-8")
        return hmac.new(self._schluessel, nachricht, hashlib.sha256).hexdigest()


class FallEroeffnet(BaseModel):
    """Eingabe des Eintragstyps fall_eroeffnet (Spur arbeitsspur)."""

    model_config = _KONFIGURATION

    fall_kennung: UUID
    rechtsregime: Literal["R1", "R2"]
    fallkategorie: _Fallkategorie
    aktenzeichen: str
    rechtsgrundlage: str
    ermittelnde_person: str
    eroeffnet_am: AwareDatetime


class FallGeschlossen(BaseModel):
    """Eingabe des Eintragstyps fall_geschlossen (Spur arbeitsspur)."""

    model_config = _KONFIGURATION

    fall_kennung: UUID
    geschlossen_am: AwareDatetime
    prueffrist_bis: AwareDatetime
    erste_pruefung_monate: Annotated[int, Field(gt=0, le=_GANZZAHL_GRENZE)]


class Entitaet(BaseModel):
    """Eingabe des Eintragstyps entitaet (Spur ermittlungsspur)."""

    model_config = _KONFIGURATION

    fall_kennung: UUID
    entitaet_kennung: UUID
    ftm_kennung: str
    ftm_schema: _Schema
    herkunft_kennung: UUID
    eigenschaften: _Eigenschaften
    werkzeug: _Werkzeug
    erhoben_am: AwareDatetime
    erhebende_person: _Person
    abfrage: str = Field(min_length=1, repr=False)


class Beziehung(BaseModel):
    """Eingabe des Eintragstyps beziehung (Spur ermittlungsspur)."""

    model_config = _KONFIGURATION

    fall_kennung: UUID
    beziehung_kennung: UUID
    ftm_kennung: str
    ftm_schema: _Schema
    herkunft_kennung: UUID
    quelle_kennung: UUID
    ziel_kennung: UUID
    eigenschaften: _Eigenschaften
    werkzeug: _Werkzeug
    erhoben_am: AwareDatetime
    erhebende_person: _Person
    abfrage: str = Field(min_length=1, repr=False)


Eingabe = FallEroeffnet | FallGeschlossen | Entitaet | Beziehung
"""Die vier Eingaben; die Zuordnung zum Eintragstyp ist fest (Festlegung S1.2)."""


def _pruefen(wert: object) -> None:
    """Weist ab, was die kanonische Form nach RFC 8785 für diese Wertarten nicht trägt."""
    if isinstance(wert, bool) or isinstance(wert, float):
        raise ValueError(
            "Wahrheitswerte und Gleitkommazahlen sind in der Nutzlast unzulässig"
        )
    if isinstance(wert, int):
        if abs(wert) > _GANZZAHL_GRENZE:
            raise ValueError("Ganze Zahl ausserhalb von ±(2^53 - 1)")
    elif isinstance(wert, str):
        return
    elif isinstance(wert, list):
        for element in wert:
            _pruefen(element)
    elif isinstance(wert, dict):
        for schluessel, element in wert.items():
            if not isinstance(schluessel, str) or not schluessel.isascii():
                raise ValueError("Schlüssel der Nutzlast sind ASCII-Zeichenketten")
            _pruefen(element)
    else:
        raise ValueError("Werttyp in der Nutzlast unzulässig")


def kanonisch_serialisieren(wert: dict[str, object]) -> str:
    """JSON mit sortierten Schlüsseln, Trennern "," und ":", ohne Maskierung von Nicht-ASCII.

    Werte allein str, int, list, dict; bool und Gleitkommazahlen und int ausserhalb von
    ±(2^53 - 1) werden mit ValueError abgewiesen, Schlüssel allein ASCII (DF-S12-04).
    """
    _pruefen(wert)
    return json.dumps(
        wert,
        sort_keys=True,
        separators=(",", ":"),
        ensure_ascii=False,
        allow_nan=False,
    )


def _eigenschaften(
    eigenschaften: dict[str, tuple[str, ...]], pseudonymisierer: Pseudonymisierer
) -> dict[str, object]:
    return {
        name: sorted(pseudonymisierer.pseudonym(wert) for wert in werte)
        for name, werte in eigenschaften.items()
    }


def _herkunft_felder(
    eingabe: "Entitaet | Beziehung", pseudonymisierer: Pseudonymisierer
) -> dict[str, object]:
    """Die Herkunftsfelder der Nutzlast: Klartext für Werkzeug, Zeit und Person, Abfrage gebunden."""
    return {
        "werkzeug": eingabe.werkzeug,
        "erhoben_am": zeitpunkt_text(eingabe.erhoben_am),
        "erhebende_person": eingabe.erhebende_person,
        "abfrage_pseudonym": pseudonymisierer.pseudonym(eingabe.abfrage),
        "abfrage_bindung": pseudonymisierer.bindung(eingabe.abfrage),
    }


def nutzlast_bilden(eingabe: Eingabe, pseudonymisierer: Pseudonymisierer) -> str:
    """Bildet den gespeicherten Text der Nutzlast (Nr. 17).

    Klartext bleibt für Kennungen, rechtsregime, fallkategorie, ftm_schema, Eigenschaftsnamen
    und Zeitpunkte; aktenzeichen, rechtsgrundlage, ermittelnde_person, ftm_kennung und jeder
    Eigenschaftswert werden zu Feldern mit der Endung _pseudonym (Eigenschaftswerte als
    aufsteigend sortierte Liste, Doppel bleiben). Entitaet und Beziehung tragen zusätzlich werkzeug,
    erhoben_am und erhebende_person im Klartext (Kennung, Zeitpunkt, Benutzerkennung) sowie
    abfrage_pseudonym und abfrage_bindung (Festlegung S1.4, DF-S14-01). Kein Wert des Klartexts gelangt in den
    Rückgabetext. Fehlerfall: ValueError bei leerem Wert oder Zeit ausserhalb des Bereichs.
    """
    wert: dict[str, object]
    match eingabe:
        case FallEroeffnet():
            # Als Schlüsselwörter, nicht als Zeichenketten: der Texttest zu Vertrag 8 duldet den
            # Namen fallkategorie ausserhalb von fall nur als Bezeichner.
            wert = dict(
                fall_kennung=str(eingabe.fall_kennung),
                rechtsregime=eingabe.rechtsregime,
                fallkategorie=eingabe.fallkategorie,
                aktenzeichen_pseudonym=pseudonymisierer.pseudonym(eingabe.aktenzeichen),
                rechtsgrundlage_pseudonym=pseudonymisierer.pseudonym(
                    eingabe.rechtsgrundlage
                ),
                ermittelnde_person_pseudonym=pseudonymisierer.pseudonym(
                    eingabe.ermittelnde_person
                ),
                eroeffnet_am=zeitpunkt_text(eingabe.eroeffnet_am),
            )
        case FallGeschlossen():
            wert = {
                "fall_kennung": str(eingabe.fall_kennung),
                "geschlossen_am": zeitpunkt_text(eingabe.geschlossen_am),
                "prueffrist_bis": zeitpunkt_text(eingabe.prueffrist_bis),
                "erste_pruefung_monate": eingabe.erste_pruefung_monate,
            }
        case Entitaet():
            wert = {
                "fall_kennung": str(eingabe.fall_kennung),
                "entitaet_kennung": str(eingabe.entitaet_kennung),
                "ftm_kennung_pseudonym": pseudonymisierer.pseudonym(
                    eingabe.ftm_kennung
                ),
                "ftm_schema": eingabe.ftm_schema,
                "herkunft_kennung": str(eingabe.herkunft_kennung),
                "eigenschaften": _eigenschaften(
                    eingabe.eigenschaften, pseudonymisierer
                ),
                **_herkunft_felder(eingabe, pseudonymisierer),
            }
        case Beziehung():
            wert = {
                "fall_kennung": str(eingabe.fall_kennung),
                "beziehung_kennung": str(eingabe.beziehung_kennung),
                "ftm_kennung_pseudonym": pseudonymisierer.pseudonym(
                    eingabe.ftm_kennung
                ),
                "ftm_schema": eingabe.ftm_schema,
                "herkunft_kennung": str(eingabe.herkunft_kennung),
                "quelle_kennung": str(eingabe.quelle_kennung),
                "ziel_kennung": str(eingabe.ziel_kennung),
                "eigenschaften": _eigenschaften(
                    eingabe.eigenschaften, pseudonymisierer
                ),
                **_herkunft_felder(eingabe, pseudonymisierer),
            }
    return kanonisch_serialisieren(wert)
