"""Nutzlast der Einträge: Eingaben im Klartext, Pseudonymisierung, kanonische Serialisierung.

ADR 0007, Nr. 17, 21 und 26 und Festlegung S1.2 (R3-F-011, R3-F-008). Die Nutzlast trägt
Klartext allein für Kennungen, geschlossene Vorräte, Zeitpunkte und ganze Zahlen; jede
andere Angabe steht als Pseudonym (HMAC-SHA-256 mit dem Schlüssel des Falls).
"""

import hashlib
import hmac
import json
import unicodedata
import warnings
from typing import Annotated, Literal
from uuid import UUID

from pydantic import (
    AwareDatetime,
    BaseModel,
    ConfigDict,
    Field,
    StringConstraints,
    model_validator,
)

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
Ergebnis = Literal[
    "zugelassen",
    "beantwortet",
    "nicht_in_positivliste",
    "bereich_nicht_oeffentlich",
    "aufloesung_fehlgeschlagen",
    "kette_zu_lang",
    "verbindung_fehlgeschlagen",
    "url_nicht_auswertbar",
]
"""Vorrat des Ergebnisses eines Verbindungsversuchs (Festlegung S2.1, E-S21-10)."""
Adressbereich = Literal[
    "unspezifiziert",
    "rueckschleife",
    "verbindungslokal",
    "standortlokal",
    "multicast",
    "privat",
    "reserviert",
    "abgekuendigt",
    "protokollzuweisung",
    "nicht_global",
    "oeffentlich",
]
"""Klassen der Adresse in der Reihenfolge der Bereichsregel (ausgang.aufloesung)."""
Zielart = Literal["name", "ipv4", "ipv6"]
Fehlerart = Literal[
    "verbindung", "tls", "zeitueberschreitung", "antwort_zu_gross", "antwort_ungueltig"
]
Methode = Literal["GET", "POST"]
Anschlussschema = Literal["http", "https"]
_Kennung = Annotated[str, StringConstraints(pattern=r"^[a-z0-9._-]{1,64}$")]
_Pruefsumme = Annotated[str, StringConstraints(pattern=r"^[0-9a-f]{64}$")]
_Zielform = Annotated[
    str,
    StringConstraints(pattern=r"^https?://[^\s/?#@]{1,253}:[0-9]{1,5}$"),
]
_Adresse = Annotated[str, StringConstraints(pattern=r"^[0-9a-f.:]{2,45}$")]
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
    aktenzeichen: str = Field(repr=False)
    rechtsgrundlage: str = Field(repr=False)
    ermittelnde_person: str = Field(repr=False)
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
    ftm_kennung: str = Field(repr=False)
    ftm_schema: _Schema
    herkunft_kennung: UUID
    eigenschaften: _Eigenschaften = Field(repr=False)
    werkzeug: _Werkzeug
    erhoben_am: AwareDatetime
    erhebende_person: _Person
    abfrage: str = Field(min_length=1, repr=False)


class Beziehung(BaseModel):
    """Eingabe des Eintragstyps beziehung (Spur ermittlungsspur)."""

    model_config = _KONFIGURATION

    fall_kennung: UUID
    beziehung_kennung: UUID
    ftm_kennung: str = Field(repr=False)
    ftm_schema: _Schema
    herkunft_kennung: UUID
    quelle_kennung: UUID
    ziel_kennung: UUID
    eigenschaften: _Eigenschaften = Field(repr=False)
    werkzeug: _Werkzeug
    erhoben_am: AwareDatetime
    erhebende_person: _Person
    abfrage: str = Field(min_length=1, repr=False)


_PFLICHT_JE_ERGEBNIS: dict[str, frozenset[str]] = {
    "zugelassen": frozenset(
        {
            "schema",
            "anschluss",
            "zielart",
            "ziel",
            "adresse",
            "adressbereich",
            "listeneintrag",
        }
    ),
    "beantwortet": frozenset(
        {
            "schema",
            "anschluss",
            "zielart",
            "ziel",
            "adresse",
            "adressbereich",
            "listeneintrag",
            "status",
            "antwort_bytes",
        }
    ),
    "verbindung_fehlgeschlagen": frozenset(
        {
            "schema",
            "anschluss",
            "zielart",
            "ziel",
            "adresse",
            "adressbereich",
            "listeneintrag",
            "fehlerart",
        }
    ),
    "nicht_in_positivliste": frozenset({"schema", "anschluss", "zielart", "ziel"}),
    "bereich_nicht_oeffentlich": frozenset(
        {
            "schema",
            "anschluss",
            "zielart",
            "ziel",
            "adresse",
            "adressbereich",
            "listeneintrag",
        }
    ),
    "aufloesung_fehlgeschlagen": frozenset(
        {"schema", "anschluss", "zielart", "ziel", "listeneintrag"}
    ),
    "kette_zu_lang": frozenset({"schema", "anschluss", "zielart", "ziel"}),
    "url_nicht_auswertbar": frozenset(),
}
_BELEGTE_FELDER = (
    "schema",
    "anschluss",
    "zielart",
    "ziel",
    "adresse",
    "adressbereich",
    "listeneintrag",
    "fehlerart",
    "status",
    "antwort_bytes",
)


# Das Feld heisst schema, wie in der Festlegung; es verdeckt die veraltete Klassenmethode
# BaseModel.schema, die niemand aufruft. Pydantic warnt davor bei der Klassenbildung; die
# Meldung wird nur hier und nur für diesen Feldnamen unterdrückt.
with warnings.catch_warnings():
    warnings.filterwarnings("ignore", message='Field name "schema"')

    class Verbindungsversuch(BaseModel):
        """Eingabe des Eintragstyps verbindungsversuch (Spur arbeitsspur; Festlegung S2.1, Nr. 16).

        Je Ergebnis ist jedes der zehn bedingten Felder Pflicht oder verboten (Belegungstabelle);
        ausgangsziel ist Pflicht genau dann, wenn schritt grösser 0 ist. ziel und ausgangsziel tragen
        die Zielform (schema://wert:anschluss, IPv6 in eckigen Klammern), adresse die Adresse in
        Normalform; alle drei sind Klartext der Eingabe und erscheinen nur als Pseudonym in der
        Nutzlast. Nie Teil der Eingabe: Pfad, Abfrageteil, Fragment, Benutzerangaben, Kopfzeilen,
        Körper, Rohform der URL.
        """

        model_config = _KONFIGURATION

        fall_kennung: UUID
        werkzeug: _Werkzeug
        versuch_kennung: UUID
        schritt: Annotated[int, Field(ge=0, le=_GANZZAHL_GRENZE)]
        methode: Methode
        ergebnis: Ergebnis
        listenstand: _Pruefsumme
        schema: Anschlussschema | None = None  # type: ignore[assignment]
        anschluss: Annotated[int, Field(ge=1, le=65535)] | None = None
        zielart: Zielart | None = None
        ziel: _Zielform | None = Field(default=None, repr=False)
        adresse: _Adresse | None = Field(default=None, repr=False)
        ausgangsziel: _Zielform | None = Field(default=None, repr=False)
        adressbereich: Adressbereich | None = None
        listeneintrag: _Kennung | None = None
        fehlerart: Fehlerart | None = None
        status: Annotated[int, Field(ge=100, le=599)] | None = None
        antwort_bytes: Annotated[int, Field(ge=0, le=_GANZZAHL_GRENZE)] | None = None

        @model_validator(mode="after")
        def _belegung_pruefen(self) -> "Verbindungsversuch":
            """Pflicht und Verbot je Ergebnis; die Meldungen nennen nur Feldnamen."""
            pflicht = _PFLICHT_JE_ERGEBNIS[self.ergebnis]
            for name in _BELEGTE_FELDER:
                gesetzt = getattr(self, name) is not None
                if name in pflicht and not gesetzt:
                    raise ValueError(f"Pflichtfeld fehlt: {name}")
                if name not in pflicht and gesetzt:
                    raise ValueError(f"Feld nicht zulässig bei diesem Ergebnis: {name}")
            if (self.ausgangsziel is not None) != (self.schritt > 0):
                raise ValueError("ausgangsziel genau dann, wenn schritt grösser 0 ist")
            if (
                self.ergebnis
                in ("bereich_nicht_oeffentlich", "aufloesung_fehlgeschlagen")
                and self.zielart != "name"
            ):
                raise ValueError("zielart muss name sein")
            if self.ergebnis == "bereich_nicht_oeffentlich":
                if self.adressbereich == "oeffentlich":
                    raise ValueError("adressbereich darf nicht oeffentlich sein")
            elif (
                self.ergebnis
                in ("zugelassen", "beantwortet", "verbindung_fehlgeschlagen")
                and self.zielart == "name"
                and self.adressbereich != "oeffentlich"
            ):
                raise ValueError("adressbereich muss oeffentlich sein")
            if (
                self.ziel is not None
                and self.schema is not None
                and self.anschluss is not None
                and (
                    not self.ziel.startswith(f"{self.schema}://")
                    or not self.ziel.endswith(f":{self.anschluss}")
                )
            ):
                raise ValueError("ziel trägt nicht schema und anschluss")
            return self


Eingabe = FallEroeffnet | FallGeschlossen | Entitaet | Beziehung | Verbindungsversuch
"""Die fünf Eingaben; die Zuordnung zum Eintragstyp ist fest (Festlegung S1.2, S2.1)."""


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


def _verbindungsversuch_felder(
    eingabe: "Verbindungsversuch", pseudonymisierer: Pseudonymisierer
) -> dict[str, object]:
    """Nutzlast des Verbindungsversuchs: Klartext allein aus Vorräten, Kennungen und Zahlen.

    ziel, adresse und ausgangsziel erscheinen nur als Pseudonym; ein Feld ohne Wert fehlt.
    """
    wert: dict[str, object] = {
        "fall_kennung": str(eingabe.fall_kennung),
        "werkzeug": eingabe.werkzeug,
        "versuch_kennung": str(eingabe.versuch_kennung),
        "schritt": eingabe.schritt,
        "methode": eingabe.methode,
        "ergebnis": eingabe.ergebnis,
        "listenstand": eingabe.listenstand,
    }
    klartext: dict[str, object] = {
        "schema": eingabe.schema,
        "anschluss": eingabe.anschluss,
        "zielart": eingabe.zielart,
        "adressbereich": eingabe.adressbereich,
        "listeneintrag": eingabe.listeneintrag,
        "fehlerart": eingabe.fehlerart,
        "status": eingabe.status,
        "antwort_bytes": eingabe.antwort_bytes,
    }
    pseudonyme = {
        "ziel_pseudonym": eingabe.ziel,
        "adresse_pseudonym": eingabe.adresse,
        "ausgangsziel_pseudonym": eingabe.ausgangsziel,
    }
    wert.update({name: v for name, v in klartext.items() if v is not None})
    wert.update(
        {
            name: pseudonymisierer.pseudonym(v)
            for name, v in pseudonyme.items()
            if v is not None
        }
    )
    return wert


def nutzlast_bilden(eingabe: Eingabe, pseudonymisierer: Pseudonymisierer) -> str:
    """Bildet den gespeicherten Text der Nutzlast (Nr. 17).

    Klartext bleibt für Kennungen, rechtsregime, fallkategorie, ftm_schema, Eigenschaftsnamen
    und Zeitpunkte; aktenzeichen, rechtsgrundlage, ermittelnde_person, ftm_kennung und jeder
    Eigenschaftswert werden zu Feldern mit der Endung _pseudonym (Eigenschaftswerte als
    aufsteigend sortierte Liste, Doppel bleiben). Entitaet und Beziehung tragen zusätzlich werkzeug,
    erhoben_am und erhebende_person im Klartext (Kennung, Zeitpunkt, Benutzerkennung) sowie
    abfrage_pseudonym und abfrage_bindung (Festlegung S1.4, DF-S14-01). Verbindungsversuch trägt
    ziel, adresse und ausgangsziel allein als Pseudonym der Zielform beziehungsweise der Adresse
    (Festlegung S2.1). Kein Wert des Klartexts gelangt in den
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
        case Verbindungsversuch():
            wert = _verbindungsversuch_felder(eingabe, pseudonymisierer)
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
