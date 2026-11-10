"""Namensauflösung und Bereichsregel (ADR 0008, Nr. 15 (3), Festlegung S2.1; R3-F-028).

Je Versuch gibt es genau eine Auflösung. Jede gelieferte Adresse wird geprüft; ist eine davon
nicht öffentlich, wird der ganze Versuch abgewiesen. Die Bereichsregel ist eine reine Funktion
mit geschlossenem Vorrat und fester Reihenfolge der Klassen.
"""

import asyncio
import ipaddress
import socket
from typing import Final, Protocol

from r3cosint.core.fehler import R3cosintFehler
from r3cosint.spur.payload import Adressbereich as Adressbereich

Adresse = ipaddress.IPv4Address | ipaddress.IPv6Address

ADRESSBEREICHE: Final[tuple[Adressbereich, ...]] = (
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
)
"""Geschlossener Vorrat und Reihenfolge der Klassen; zugleich der Vorrat des Felds adressbereich."""

_ABGEKUENDIGT: Final = (ipaddress.ip_network("192.88.99.0/24"),)
"""Relay-Anycast nach RFC 7526 (abgekündigt): eine Gegenstelle, die niemand bestimmt."""

_PROTOKOLLZUWEISUNG: Final = (
    ipaddress.ip_network("192.0.0.0/24"),
    ipaddress.ip_network("2001:1::1/128"),
    ipaddress.ip_network("2001:1::2/128"),
    ipaddress.ip_network("2001:1::3/128"),
)
"""Anycast-Dienstadressen der IETF-Protokollzuweisungen, die der nächste Knoten beantwortet.

Stand des Registers 2025-10-09; die Liste veraltet mit ihm (Grenze GK-23)."""

_TEXT = "Die Namensauflösung ist fehlgeschlagen."


class AufloesungsFehler(R3cosintFehler):
    """Die Namensauflösung ergab einen Fehler oder keine Adresse; der Text nennt keinen Namen."""

    def __init__(self) -> None:
        super().__init__(_TEXT)


class Aufloeser(Protocol):
    """Löst einen Namen in Normalform in seine Adressen auf."""

    async def aufloesen(self, name: str) -> tuple[Adresse, ...]:
        """Adressen in der Reihenfolge der Antwort. Fehlerfall: AufloesungsFehler."""
        ...


def _abbilden(adresse: Adresse) -> Adresse:
    """IPv4-in-IPv6 wird auf IPv4 abgebildet."""
    if isinstance(adresse, ipaddress.IPv6Address) and adresse.ipv4_mapped is not None:
        return adresse.ipv4_mapped
    return adresse


def _in_liste(
    adresse: Adresse, netze: tuple[ipaddress.IPv4Network | ipaddress.IPv6Network, ...]
) -> bool:
    """Ob die Adresse in einem der Netze liegt (Netze anderer Fassung zählen nicht)."""
    return any(netz.version == adresse.version and adresse in netz for netz in netze)


def adressbereich(adresse: Adresse) -> Adressbereich:
    """Klasse einer Adresse: die erste zutreffende in der Reihenfolge von ADRESSBEREICHE.

    Zulässig ist allein "oeffentlich". Trifft eine frühere Eigenschaft von ipaddress zu, ergibt
    sie den Klassennamen, auch wenn die Adresse in einer der festen Listen steht.
    """
    a = _abbilden(adresse)
    if a.is_unspecified:
        return "unspezifiziert"
    if a.is_loopback:
        return "rueckschleife"
    if a.is_link_local:
        return "verbindungslokal"
    if isinstance(a, ipaddress.IPv6Address) and a.is_site_local:
        return "standortlokal"
    if a.is_multicast:
        return "multicast"
    if a.is_private:
        return "privat"
    if a.is_reserved:
        return "reserviert"
    if _in_liste(a, _ABGEKUENDIGT):
        return "abgekuendigt"
    if _in_liste(a, _PROTOKOLLZUWEISUNG):
        return "protokollzuweisung"
    if not a.is_global:
        return "nicht_global"
    return "oeffentlich"


def _adresse_lesen(text: str) -> Adresse | None:
    """Adresse aus dem Text einer Antwort; eine Zonenangabe wird abgeschnitten."""
    try:
        adresse = ipaddress.ip_address(text.split("%", 1)[0])
    except ValueError:
        return None
    return _abbilden(adresse)


class StandardAufloeser:
    """Auflösung über loop.getaddrinfo der laufenden Ereignisschleife (Typ SOCK_STREAM).

    Adressen in der Reihenfolge der Antwort, Dubletten entfernt, eine Zonenangabe
    abgeschnitten (die Adresse ist dann verbindungslokal und wird abgewiesen), IPv4-in-IPv6
    auf IPv4 abgebildet. Jeder Fehler und eine leere Antwort ergeben AufloesungsFehler.
    """

    async def aufloesen(self, name: str) -> tuple[Adresse, ...]:
        """Löst den Namen auf. Fehlerfall: AufloesungsFehler mit festem Text."""
        schleife = asyncio.get_running_loop()
        try:
            antwort = await schleife.getaddrinfo(name, None, type=socket.SOCK_STREAM)
        except (OSError, ValueError):
            antwort = None
        adressen: list[Adresse] = []
        for eintrag in antwort or ():
            adresse = _adresse_lesen(str(eintrag[4][0]))
            if adresse is None:
                adressen = []
                break
            if adresse not in adressen:
                adressen.append(adresse)
        if not adressen:
            raise AufloesungsFehler
        return tuple(adressen)
