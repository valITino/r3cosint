"""Ziel einer Verbindung nach aussen: Zerlegung und Normalform einer URL (ADR 0008, Nr. 15 (1)).

Reine Funktionen ohne Netz und ohne Namensauflösung (R3-F-015, R3-F-028). Eine URL wird nie
ausgewertet, bevor ihre Zeichen geprüft sind; der Rechnerteil wird nach UTS 46 abgebildet,
bevor erkannt wird, ob er ein Literal ist, und ein Literal wird mit einem eigenen Parser
gelesen. Pfad, Abfrageteil und Fragment gehen nie in ein Ziel ein.

Jede Ausnahme der Bausteine (urlsplit, ipaddress, idna) trägt den Wert im Text. Sie wird
deshalb im except-Block nur als Merker gesetzt; ZielFehler entsteht danach ausserhalb des
Blocks mit festem Text, sodass keine Ursache und kein Kontext einen Teil der URL trägt.
"""

import ipaddress
import unicodedata
from dataclasses import dataclass, field
from urllib.parse import urlsplit

import idna

from r3cosint.core.fehler import EingabeFehler
from r3cosint.spur.payload import Anschlussschema
from r3cosint.spur.payload import Zielart as Zielart

Schema = Anschlussschema
Adresse = ipaddress.IPv4Address | ipaddress.IPv6Address

URL_HOECHSTLAENGE = 2048
"""Höchstzahl der Zeichen einer URL (Festlegung S2.1, Zeile ausgang.ziel, Schritt 1)."""

_GESPERRTE_KATEGORIEN = frozenset({"Cc", "Cf", "Cs", "Zs", "Zl", "Zp"})
_DEZIMALZIFFERN = frozenset("0123456789")
_OKTALZIFFERN = frozenset("01234567")
_HEXZIFFERN = frozenset("0123456789abcdefABCDEF")
_STANDARDANSCHLUSS: dict[str, int] = {"http": 80, "https": 443}
_HOECHSTER_ANSCHLUSS = 65535
_TEXT = "Die URL ist nicht auswertbar."


class ZielFehler(EingabeFehler):
    """Die URL ist nicht auswertbar; der Text nennt weder die URL noch einen Teil von ihr."""

    def __init__(self) -> None:
        super().__init__(_TEXT)


@dataclass(frozen=True, slots=True)
class Ziel:
    """Ziel einer Verbindung in Normalform.

    schema: http oder https.
    art: name, ipv4 oder ipv6.
    wert: Rechnername (A-Label-Form in Kleinschreibung ohne abschliessenden Punkt) oder
        Adresse in Normalform (IPv4 dezimal mit Punkten, IPv6 verkürzt und klein, ohne
        Klammern). Der Wert steht nie in der Darstellung (repr), weil Ziele in Fehlern und
        Berichten nicht im Klartext erscheinen sollen.
    anschluss: ganze Zahl 1 bis 65535, bei fehlender Angabe 80 oder 443 nach dem Schema.
    """

    schema: Schema
    art: Zielart
    wert: str = field(repr=False)
    anschluss: int

    def zielform(self) -> str:
        """Zielform nach ADR 0008 (Zeile Protokoll): schema://wert:anschluss, IPv6 in Klammern."""
        rechner = f"[{self.wert}]" if self.art == "ipv6" else self.wert
        return f"{self.schema}://{rechner}:{self.anschluss}"

    def adresse(self) -> Adresse:
        """Die Adresse eines Literals. Fehlerfall: ValueError bei einem Namen."""
        if self.art == "ipv4":
            return ipaddress.IPv4Address(self.wert)
        if self.art == "ipv6":
            return ipaddress.IPv6Address(self.wert)
        raise ValueError("Ein Name ist kein Literal.")


def zeichen_pruefen(url: object) -> None:
    """Schritt 1: Zeichenprüfung der ganzen URL vor jeder Zerlegung.

    Zulässig ist ein str der Länge 1 bis 2048 ohne Zeichen der Unicode-Kategorien Cc, Cf, Cs,
    Zs, Zl und Zp und ohne Zeichen, für das str.isspace gilt. Fehlerfall: ZielFehler.
    """
    gueltig = (
        isinstance(url, str)
        and 1 <= len(url) <= URL_HOECHSTLAENGE
        and not any(
            unicodedata.category(zeichen) in _GESPERRTE_KATEGORIEN or zeichen.isspace()
            for zeichen in url
        )
    )
    if not gueltig:
        raise ZielFehler


def _anschluss_lesen(text: str) -> int | None:
    """Anschluss allein aus den Ziffern 0 bis 9; leer nach ":" ist ein Fehler (None)."""
    if text == "":
        return None
    if not all(zeichen in _DEZIMALZIFFERN for zeichen in text):
        return None
    zahl = int(text)
    return zahl if 1 <= zahl <= _HOECHSTER_ANSCHLUSS else None


def _ipv4_teil(teil: str) -> int | None:
    """Ein Teil eines IPv4-Literals: dezimal, oktal mit führender 0 oder hexadezimal mit 0x."""
    if teil[:2] in ("0x", "0X"):
        ziffern, basis, erlaubt = teil[2:], 16, _HEXZIFFERN
    elif len(teil) > 1 and teil[0] == "0":
        ziffern, basis, erlaubt = teil[1:], 8, _OKTALZIFFERN
    else:
        ziffern, basis, erlaubt = teil, 10, _DEZIMALZIFFERN
    if ziffern == "" or not all(zeichen in erlaubt for zeichen in ziffern):
        return None
    return int(ziffern, basis)


def ipv4_lesen(text: str) -> ipaddress.IPv4Address | None:
    """Liest ein IPv4-Literal nach der Grammatik der C-Bibliothek für IPv4-Literale (eigener, reiner Parser).

    Ein bis vier Teile durch "." getrennt, je Teil dezimal, oktal mit führender 0 oder
    hexadezimal mit 0x oder 0X; die Wertebereiche sind 32, 8.24, 8.8.16 und 8.8.8.8 Bit; kein
    leerer Teil, kein Rest. Rückgabe None bei jedem Verstoss.
    """
    teile = text.split(".")
    if not 1 <= len(teile) <= 4:
        return None
    werte = [_ipv4_teil(teil) for teil in teile]
    zahlen = [wert for wert in werte if wert is not None]
    if len(zahlen) != len(werte):
        return None
    *vorn, letzter = zahlen
    if any(zahl > 255 for zahl in vorn) or letzter >= 256 ** (5 - len(zahlen)):
        return None
    gesamt = letzter
    for stelle, zahl in enumerate(vorn):
        gesamt += zahl << (8 * (3 - stelle))
    return ipaddress.IPv4Address(gesamt)


def _ist_ipv4_literal(rechner: str) -> bool:
    """Das letzte Etikett besteht allein aus Ziffern oder hat die Form 0x mit Hexziffern."""
    letztes = rechner.rsplit(".", 1)[-1]
    if letztes[:2] in ("0x", "0X"):
        return all(zeichen in _HEXZIFFERN for zeichen in letztes[2:])
    return letztes != "" and all(zeichen in _DEZIMALZIFFERN for zeichen in letztes)


def _literal_ipv6(innen: str) -> Adresse | None:
    """IPv6-Weg: keine Zonenangabe, IPv4-in-IPv6 wird auf IPv4 abgebildet."""
    if "%" in innen:
        return None
    try:
        adresse = ipaddress.IPv6Address(innen)
    except ValueError:
        return None
    return adresse.ipv4_mapped or adresse


def _abbilden(rechner: str) -> str | None:
    """Namensabbildung nach UTS 46 mit idna, ein abschliessender Punkt entfällt.

    Rückgabe None bei jedem Verstoss, auch bei leerem Ergebnis oder einem ":" darin.
    """
    try:
        abgebildet = idna.uts46_remap(rechner, std3_rules=True, transitional=False)
    except ValueError:
        return None
    abgebildet = abgebildet.removesuffix(".")
    if abgebildet == "" or ":" in abgebildet:
        return None
    return abgebildet


def _rechner_bestimmen(rechner: str) -> tuple[Zielart, str] | None:
    """Rechner ohne Klammern: Abbildung, Literal-Erkennung, Name. None bei jedem Verstoss."""
    abgebildet = _abbilden(rechner)
    if abgebildet is None:
        return None
    if _ist_ipv4_literal(abgebildet):
        adresse = ipv4_lesen(abgebildet)
        return None if adresse is None else ("ipv4", str(adresse))
    try:
        kodiert = idna.encode(abgebildet)
    except ValueError:
        return None
    name = kodiert.decode("ascii").lower()
    return None if name.endswith(".") else ("name", name)


def _zerlegen(url: str) -> Ziel | None:
    """Schritt 2 bis 5: Zerlegung und Normalform; None bei jedem Verstoss."""
    try:
        teile = urlsplit(url)
    except ValueError:
        return None
    schema = teile.scheme.lower()
    netloc = teile.netloc
    if schema not in _STANDARDANSCHLUSS or netloc == "" or "@" in netloc:
        return None
    if netloc.startswith("["):
        rechner, _, rest = netloc[1:].partition("]")
        klammern = True
    else:
        rechner, trenner, rest = netloc.partition(":")
        rest = trenner + rest
        klammern = False
    if rest == "":
        anschluss: int | None = _STANDARDANSCHLUSS[schema]
    else:
        anschluss = _anschluss_lesen(rest[1:]) if rest[:1] == ":" else None
    if anschluss is None or rechner == "":
        return None
    if klammern:
        literal = _literal_ipv6(rechner)
        if literal is None:
            return None
        art: Zielart = "ipv4" if literal.version == 4 else "ipv6"
        return Ziel(
            schema=_schema(schema), art=art, wert=str(literal), anschluss=anschluss
        )
    bestimmt = _rechner_bestimmen(rechner)
    if bestimmt is None:
        return None
    return Ziel(
        schema=_schema(schema), art=bestimmt[0], wert=bestimmt[1], anschluss=anschluss
    )


def _schema(text: str) -> Schema:
    """Das Schema als Literal; der Aufrufer hat es schon gegen den Vorrat geprüft."""
    return "https" if text == "https" else "http"


def aus_url(url: str) -> Ziel:
    """Zerlegt eine URL in ein Ziel in Normalform.

    Fehlerfall: ZielFehler mit festem Text, ausserhalb jedes except-Blocks ausgelöst, ohne
    die URL und ohne einen Teil von ihr. Benutzerangaben ("@" im Rechnerteil), Zonenangaben
    ("%" in eckigen Klammern) und jeder nicht lesbare Anschluss sind Fehler.
    """
    zeichen_pruefen(url)
    ziel = _zerlegen(url)
    if ziel is None:
        raise ZielFehler
    return ziel


def pfad_und_abfrage(url: str) -> str:
    """Pfad und Abfrageteil einer schon mit aus_url geprüften URL; das Fragment entfällt.

    Der Pfad ist mindestens "/". Die Angaben gehen nie in ein Ziel, ein Pseudonym oder das
    Protokoll ein; sie dienen allein der Anfrage.
    """
    teile = urlsplit(url)
    abfrage = f"?{teile.query}" if teile.query else ""
    return (teile.path or "/") + abfrage
