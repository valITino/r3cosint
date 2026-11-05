"""Verkettung der Spuren: Vorräte, Serialisierung, Prüfsumme und Prüfung ohne Datenbank.

ADR 0007, Nr. 12 bis 21 und Festlegung S1.2 (R3-F-008, R3-F-012). Dieses Modul ist rein:
es berührt weder Datenbank noch Uhr noch Zufall. Die Prüfung liefert je Spur und Fall
einen Befund; die Datenbank rechnet über spur_kette_pruefen ein zweites Mal.
"""

import enum
import hashlib
from collections.abc import Sequence
from dataclasses import dataclass
from datetime import UTC, datetime
from uuid import UUID

_VERSIONSETIKETT = "r3cosint-spur-1"
_ZEIT_VON = datetime(2000, 1, 1, tzinfo=UTC)
_ZEIT_BIS = datetime(9999, 1, 1, tzinfo=UTC)


class Spur(enum.StrEnum):
    """Die beiden gleichwertigen Spuren; der Wert ist Tabellen- und Spurname (Nr. 16, 18)."""

    ERMITTLUNGSSPUR = "ermittlungsspur"
    ARBEITSSPUR = "arbeitsspur"


class Eintragstyp(enum.StrEnum):
    """Geschlossener Vorrat der Eintragstypen (Nr. 14)."""

    FALL_EROEFFNET = "fall_eroeffnet"
    FALL_GESCHLOSSEN = "fall_geschlossen"
    ENTITAET = "entitaet"
    BEZIEHUNG = "beziehung"


class Kennzeichnung(enum.StrEnum):
    """Quellenaussage und Schlussfolgerung sind getrennt gekennzeichnet (5.3, E-S1-08)."""

    QUELLENAUSSAGE = "quellenaussage"
    SCHLUSSFOLGERUNG = "schlussfolgerung"


class Bruchgrund(enum.StrEnum):
    """Grund des ersten Bruchs einer Kette (Nr. 19)."""

    LUECKE = "luecke"
    INHALT_GEAENDERT = "inhalt_geaendert"
    VORGAENGER_FALSCH = "vorgaenger_falsch"
    KOPF_ABWEICHEND = "kopf_abweichend"


SPUR_JE_EINTRAGSTYP: dict[Eintragstyp, Spur] = {
    Eintragstyp.FALL_EROEFFNET: Spur.ARBEITSSPUR,
    Eintragstyp.FALL_GESCHLOSSEN: Spur.ARBEITSSPUR,
    Eintragstyp.ENTITAET: Spur.ERMITTLUNGSSPUR,
    Eintragstyp.BEZIEHUNG: Spur.ERMITTLUNGSSPUR,
}
"""Zuordnung des Eintragstyps zur Spur (Nr. 14)."""


@dataclass(frozen=True, slots=True)
class Eintrag:
    """Ein Eintrag einer Spur; die zehn Felder von Nr. 18 und die Prüfsumme."""

    spur: Spur
    kennung: UUID
    fall_kennung: UUID
    position: int
    zeitpunkt: datetime
    person_kennung: str
    eintragstyp: Eintragstyp
    kennzeichnung: Kennzeichnung
    payload: str
    vorgaenger_pruefsumme: str
    pruefsumme: str


@dataclass(frozen=True, slots=True)
class Kettenkopf:
    """Stand einer Kette: Position und Prüfsumme des letzten Eintrags (Nr. 13).

    Position 0 ist der Anfang.
    """

    spur: Spur
    fall_kennung: UUID
    position: int
    pruefsumme: str


@dataclass(frozen=True, slots=True)
class Befund:
    """Ergebnis der Prüfung einer Kette (eine Spur in einem Fall, E-S1-05).

    anzahl: Zahl der Einträge, die mit dem Anfangswert stimmig verkettet sind (bei unversehrt
    alle); "verifiziert" heisst stimmig verkettet, nicht unverändert (DF-S12-08).
    position: erste Stelle, an der die Folge nicht stimmig ist; position und grund sind None
    genau dann, wenn unversehrt gilt.
    letzte_pruefsumme: Kettenwert nach den anzahl stimmig verketteten Einträgen (beim leeren
    Bestand der Anfangswert); macht den Befund an einen Anker ausserhalb anschlussfähig.
    kopf_position: Position des Kettenkopfs, None wenn er fehlt.
    """

    spur: Spur
    fall_kennung: UUID
    unversehrt: bool
    anzahl: int
    position: int | None
    grund: Bruchgrund | None
    letzte_pruefsumme: str
    kopf_position: int | None


def anfangswert(spur: Spur, fall_kennung: UUID) -> str:
    """Vorgängerwert des ersten Eintrags (Nr. 16).

    SHA-256 über "r3cosint-spur-1|" + Spurname + "|" + fall_kennung (klein, mit Bindestrichen),
    hexadezimal klein, 64 Zeichen.
    """
    text = f"{_VERSIONSETIKETT}|{spur.value}|{fall_kennung}"
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


def zeitpunkt_text(zeitpunkt: datetime) -> str:
    """Zeitpunkt als YYYY-MM-DDTHH:MM:SS.ffffffZ in UTC (Nr. 18, DF-S12-01).

    Fehlerfall: ValueError bei naiver Zeit und ausserhalb von 2000-01-01T00:00:00Z bis vor
    9999-01-01 (datetime.max ist für asyncpg 'infinity'). Das Jahr ist ausdrücklich vierstellig
    formatiert, nicht über strftime oder isoformat (beide lassen Stellen weg).
    """
    if zeitpunkt.tzinfo is None or zeitpunkt.utcoffset() is None:
        raise ValueError("zeitpunkt muss zeitbewusst sein")
    try:
        utc = zeitpunkt.astimezone(UTC)
    except OverflowError as fehler:
        raise ValueError("zeitpunkt liegt ausserhalb des Bereichs") from fehler
    if utc < _ZEIT_VON or utc >= _ZEIT_BIS:
        raise ValueError("zeitpunkt liegt ausserhalb des Bereichs")
    return (
        f"{utc.year:04d}-{utc.month:02d}-{utc.day:02d}"
        f"T{utc.hour:02d}:{utc.minute:02d}:{utc.second:02d}.{utc.microsecond:06d}Z"
    )


def serialisieren(eintrag: Eintrag) -> bytes:
    """Bytes, über die die Prüfsumme gebildet wird (Nr. 18), ohne das Feld pruefsumme.

    Das Versionsetikett und "\\n", danach je Feld in der Reihenfolge spur, kennung, fall_kennung,
    position, zeitpunkt, person_kennung, eintragstyp, kennzeichnung, payload,
    vorgaenger_pruefsumme die Länge der UTF-8-Bytes dezimal, ":", die Bytes, "\\n".
    Fehlerfall: ValueError, wenn zeitpunkt naiv oder ausserhalb des Bereichs ist.
    """
    felder = (
        eintrag.spur.value,
        str(eintrag.kennung),
        str(eintrag.fall_kennung),
        str(eintrag.position),
        zeitpunkt_text(eintrag.zeitpunkt),
        eintrag.person_kennung,
        eintrag.eintragstyp.value,
        eintrag.kennzeichnung.value,
        eintrag.payload,
        eintrag.vorgaenger_pruefsumme,
    )
    ausgabe = bytearray(f"{_VERSIONSETIKETT}\n".encode())
    for feld in felder:
        roh = feld.encode("utf-8")
        ausgabe += str(len(roh)).encode() + b":" + roh + b"\n"
    return bytes(ausgabe)


def pruefsumme(eintrag: Eintrag) -> str:
    """SHA-256 über serialisieren(eintrag), hexadezimal klein, 64 Zeichen (Nr. 18)."""
    return hashlib.sha256(serialisieren(eintrag)).hexdigest()


def _errechnet(eintrag: Eintrag) -> str | None:
    """Prüfsumme oder None, wenn der Eintrag sich nicht serialisieren lässt.

    Ein solcher Eintrag zählt als geändert.
    """
    try:
        return pruefsumme(eintrag)
    except ValueError:
        return None


def pruefen(
    spur: Spur,
    fall_kennung: UUID,
    eintraege: Sequence[Eintrag],
    kopf: Kettenkopf | None,
) -> Befund:
    """Prüft eine Folge von Einträgen einer Kette ohne Datenbank (Nr. 19, Festlegung S1.2).

    Die Einträge kommen nach Position und Kennung aufsteigend; die Funktion sortiert nicht. Je
    Eintrag gilt die Reihenfolge luecke, inhalt_geaendert, vorgaenger_falsch; danach der
    Abgleich mit dem Kopf (kopf_abweichend; fehlt der Kopf, an Position 0; Positionsregel nach
    DF-S12-09). Der erste Bruch beendet die Prüfung. Eine leere Folge mit Kopf in Position 0
    und Anfangswert ist unversehrt. Ein Eintrag, dessen Prüfsumme sich nicht bilden lässt,
    gilt als inhalt_geaendert.
    """
    summen = [anfangswert(spur, fall_kennung)]
    kopf_position = None if kopf is None else kopf.position

    def befund(grund: Bruchgrund | None, position: int | None, anzahl: int) -> Befund:
        return Befund(
            spur=spur,
            fall_kennung=fall_kennung,
            unversehrt=grund is None,
            anzahl=anzahl,
            position=position,
            grund=grund,
            letzte_pruefsumme=summen[anzahl],
            kopf_position=kopf_position,
        )

    for eintrag in eintraege:
        gezaehlt = len(summen) - 1
        if eintrag.position != gezaehlt + 1:
            return befund(Bruchgrund.LUECKE, gezaehlt + 1, gezaehlt)
        if _errechnet(eintrag) != eintrag.pruefsumme:
            return befund(Bruchgrund.INHALT_GEAENDERT, eintrag.position, gezaehlt)
        if eintrag.vorgaenger_pruefsumme != summen[gezaehlt]:
            return befund(Bruchgrund.VORGAENGER_FALSCH, eintrag.position, gezaehlt)
        summen.append(eintrag.pruefsumme)
    gezaehlt = len(summen) - 1
    if kopf is None:
        return befund(Bruchgrund.KOPF_ABWEICHEND, 0, gezaehlt)
    if kopf.position > gezaehlt:
        return befund(Bruchgrund.KOPF_ABWEICHEND, gezaehlt + 1, gezaehlt)
    if kopf.position < gezaehlt:
        # anzahl nie negativ: ein negativer Kopf (nur unter Umgehung der Prüfbedingung) wäre
        # sonst ein negativer Index in summen.
        return befund(
            Bruchgrund.KOPF_ABWEICHEND, kopf.position + 1, max(kopf.position, 0)
        )
    if kopf.pruefsumme != summen[gezaehlt]:
        return befund(Bruchgrund.KOPF_ABWEICHEND, gezaehlt, max(gezaehlt - 1, 0))
    return befund(None, None, gezaehlt)
