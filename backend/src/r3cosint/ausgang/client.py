"""Der einzige HTTP-Client nach aussen (ADR 0008, Festlegung S2.1, Zeilen ausgang.client; R3-F-015, R3-F-028).

Jeder Schritt eines Aufrufs durchläuft dieselbe Folge: Ziel bestimmen, Höchstzahl der Schritte,
Positivliste, genau eine Auflösung mit Bereichsregel, Eintrag zugelassen, erst dann der Netzakt.
Auf den Netzakt folgt je Antwort oder Fehlschlag ein zweiter Eintrag. Jede Abweisung und jeder
Fehlschlag ist Rückgabewert, keine Ausnahme; nach dem ersten Eintrag verlässt keine Ausnahme ausser
einem Fehler des Schreibens selbst den Aufruf.

Die Antwort einer Gegenstelle ist fremder Inhalt (5.4): ihr Körper wird weder ausgewertet noch
dekodiert, ihre Kopfzeilen lösen nichts aus ausser den Weiterleitungsregeln dieses Moduls.

Ausnahmen von httpx, httpcore, ssl und asyncio werden im except-Block nur als Vorratswert
(fehlerart) gemerkt; kein Rückgabewert und keine eigene Ausnahme trägt eine Ursache, einen Kontext,
eine Adresse, einen Rechnernamen oder ein Stück der Antwort.
"""

import asyncio
import functools
import logging
import ssl
from collections.abc import AsyncIterator, Callable, Iterable, Mapping
from dataclasses import dataclass, field
from typing import Any, Final, Literal, Protocol
from urllib.parse import urljoin
from uuid import UUID

import certifi
import httpcore
import httpx
from sqlalchemy.ext.asyncio import AsyncConnection

from r3cosint.ausgang.aufloesung import Adresse, Aufloeser, adressbereich
from r3cosint.ausgang.positivliste import Positivliste
from r3cosint.ausgang.ziel import Ziel, ZielFehler, aus_url, pfad_und_abfrage
from r3cosint.core.fehler import EingabeFehler, KonfigurationsFehler
from r3cosint.core.kennung import neue_kennung
from r3cosint.core.zeit import Uhr
from r3cosint.fall.service import fall_lesen
from r3cosint.spur.payload import (
    Adressbereich,
    Fehlerart,
    Methode,
    Pseudonymisierer,
    Verbindungsversuch,
)
from r3cosint.spur.service import Kennzeichnung, Spur, anfuegen

__all__ = [
    "Abweisung",
    "Antwort",
    "Antwortgrenzen",
    "Client",
    "Fehlschlag",
    "GebundenerNetzanschluss",
    "GebundenerVerbindungsweg",
    "Spurkontext",
    "SpurkontextDatenbank",
    "Verbindungsweg",
    "bibliotheksclient_bauen",
]

ROHKOPF: Final = "r3cosint_rohkopf"
_FRIST_HOECHSTENS = 300.0
_STATUS_WEITERLEITUNG: Final = frozenset({301, 302, 303, 307, 308})
_SPERRLISTE: Final = frozenset(
    {
        "host",
        "content-length",
        "transfer-encoding",
        "connection",
        "te",
        "upgrade",
        "cookie",
        "accept-encoding",
    }
)
_MINDESTFASSUNG: Final = ssl.TLSVersion.TLSv1_2
_LOGGER_STUFE: Final = logging.CRITICAL + 1
_PRAEFIXE_LOGGER: Final = ("httpx.", "httpcore.")

AbweisungsErgebnis = Literal[
    "nicht_in_positivliste",
    "bereich_nicht_oeffentlich",
    "aufloesung_fehlgeschlagen",
    "kette_zu_lang",
    "url_nicht_auswertbar",
]
Paare = tuple[tuple[str, str], ...]


# ---- Rückgabetypen ------------------------------------------------------------------------------


@dataclass(frozen=True, slots=True)
class Antwortgrenzen:
    """Grenzen eines Aufrufs von Client.anfragen.

    antwortgroesse_bytes: grösser 0; höchstens so viele Rohbytes des Körpers je Schritt.
    frist_sekunden: grösser 0 und höchstens 300; Gesamtfrist je Aufruf über alle Schritte
        einschliesslich der Auflösung.
    """

    antwortgroesse_bytes: int
    frist_sekunden: float

    def __post_init__(self) -> None:
        """Fehlerfall: EingabeFehler mit festem Text."""
        if (
            isinstance(self.antwortgroesse_bytes, bool)
            or not isinstance(self.antwortgroesse_bytes, int)
            or self.antwortgroesse_bytes <= 0
        ):
            raise EingabeFehler(
                "Die Grösse der Antwort muss eine ganze Zahl über 0 sein."
            )
        if (
            isinstance(self.frist_sekunden, bool)
            or not isinstance(self.frist_sekunden, (int, float))
            or not 0 < self.frist_sekunden <= _FRIST_HOECHSTENS
        ):
            raise EingabeFehler(
                "Die Frist muss über 0 und höchstens 300 Sekunden liegen."
            )


@dataclass(frozen=True, slots=True)
class Antwort:
    """Die Antwort eines Schritts; der Körper ist fremder Inhalt und wird nicht ausgewertet."""

    status: int
    kopfzeilen: Paare
    koerper: bytes = field(repr=False)
    schritt: int
    listeneintrag: str
    versuch_kennung: UUID


@dataclass(frozen=True, slots=True)
class Abweisung:
    """Der Aufruf wurde vor dem Netzakt abgewiesen."""

    ergebnis: AbweisungsErgebnis
    schritt: int
    versuch_kennung: UUID


@dataclass(frozen=True, slots=True)
class Fehlschlag:
    """Der Netzakt lieferte keine verwertbare Antwort."""

    fehlerart: Fehlerart
    schritt: int
    versuch_kennung: UUID


# ---- Kontext der Spur ---------------------------------------------------------------------------


class Spurkontext(Protocol):
    """Was der Client vom Aufrufer braucht, um jeden Versuch in die Arbeitsspur zu schreiben."""

    @property
    def fall_kennung(self) -> UUID:
        """Kennung des Falls, zu dem der Aufruf gehört."""
        ...

    @property
    def werkzeug(self) -> str:
        """Kennung des Werkzeugs (Form nach ADR 0007, Nr. 25)."""
        ...

    @property
    def person_kennung(self) -> str:
        """Benutzerkennung der handelnden Person; steht allein in der Spalte des Eintrags."""
        ...

    @property
    def uhr(self) -> Uhr:
        """Uhr des Eintrags (UTC)."""
        ...

    async def fall_pruefen(self) -> None:
        """Fehlerfall: EingabeFehler, wenn der Fall nicht besteht."""
        ...

    async def eintragen(self, eingabe: Verbindungsversuch) -> None:
        """Schreibt den Eintrag in die Transaktion des Aufrufers."""
        ...


@dataclass(frozen=True, slots=True)
class SpurkontextDatenbank:
    """Spurkontext über eine Verbindung mit offener Transaktion (ADR 0007, Nr. 1).

    ausgang öffnet, beendet und setzt keine Transaktion zurück; die offene Transaktion stellt der
    Aufrufer.
    """

    verbindung: AsyncConnection = field(repr=False)
    fall_kennung: UUID
    werkzeug: str
    person_kennung: str
    pseudonymisierer: Pseudonymisierer = field(repr=False)
    uhr: Uhr

    async def fall_pruefen(self) -> None:
        """Prüft, dass der Fall besteht; sonst EingabeFehler mit festem Text."""
        fehlt = False
        try:
            await fall_lesen(self.verbindung, self.fall_kennung)
        except EingabeFehler:
            fehlt = True
        if fehlt:
            raise EingabeFehler("Der Fall besteht nicht.")

    async def eintragen(self, eingabe: Verbindungsversuch) -> None:
        """Einzige Schreibstelle: spur.service.anfuegen in der Arbeitsspur als Quellenaussage."""
        await anfuegen(
            self.verbindung,
            spur=Spur.ARBEITSSPUR,
            fall_kennung=self.fall_kennung,
            person_kennung=self.person_kennung,
            kennzeichnung=Kennzeichnung.QUELLENAUSSAGE,
            eingabe=eingabe,
            pseudonymisierer=self.pseudonymisierer,
            uhr=self.uhr,
        )


# ---- Verbindungsweg (Weg a) ----------------------------------------------------------------------


class GebundenerNetzanschluss(httpcore.AsyncNetworkBackend):
    """Netzanschluss, der allein den erwarteten Rechner und Anschluss annimmt (Weg a).

    connect_tcp ersetzt den Rechner durch die geprüfte Adresse, weist jeden anderen Rechner
    oder Anschluss ab und nimmt höchstens einen Verbindungsaufbau an; connect_unix_socket wird
    abgewiesen. Die Auflösung eines Namens findet hier nie statt.
    """

    def __init__(
        self,
        *,
        rechner: str,
        anschluss: int,
        adresse: Adresse,
        innen: httpcore.AsyncNetworkBackend | None = None,
    ) -> None:
        self._rechner = rechner
        self._anschluss = anschluss
        self._adresse = adresse
        self._innen = innen if innen is not None else httpcore.AnyIOBackend()
        self._aufbauten = 0

    async def connect_tcp(
        self,
        host: str,
        port: int,
        timeout: float | None = None,  # noqa: ASYNC109 (Schnittstelle von httpcore)
        local_address: str | None = None,
        socket_options: Iterable[httpcore.SOCKET_OPTION] | None = None,
    ) -> httpcore.AsyncNetworkStream:
        """Verbindet mit der geprüften Adresse; jede Abweichung ist ein Fehler."""
        if host != self._rechner or port != self._anschluss or self._aufbauten >= 1:
            raise httpcore.ConnectError("Die Verbindung ist nicht vorgesehen.")
        self._aufbauten += 1
        return await self._innen.connect_tcp(
            str(self._adresse),
            port,
            timeout=timeout,
            local_address=local_address,
            socket_options=socket_options,
        )

    async def connect_unix_socket(
        self,
        path: str,
        timeout: float | None = None,  # noqa: ASYNC109 (Schnittstelle von httpcore)
        socket_options: Iterable[httpcore.SOCKET_OPTION] | None = None,
    ) -> httpcore.AsyncNetworkStream:
        """Abgewiesen: ausgang kennt keine Unix-Sockets."""
        raise httpcore.ConnectError("Die Verbindung ist nicht vorgesehen.")

    async def sleep(self, seconds: float) -> None:
        """Wartet über den inneren Netzanschluss."""
        await self._innen.sleep(seconds)


class _Antwortstrom(httpx.AsyncByteStream):
    """Wickelt den Strom von httpcore in einen Strom von httpx."""

    def __init__(
        self, strom: AsyncIterator[bytes], schliessen: Callable[[], object]
    ) -> None:
        self._strom = strom
        self._schliessen = schliessen

    async def __aiter__(self) -> AsyncIterator[bytes]:
        async for stueck in self._strom:
            yield stueck

    async def aclose(self) -> None:
        """Schliesst den Strom von httpcore."""
        ergebnis = self._schliessen()
        if asyncio.iscoroutine(ergebnis):
            await ergebnis


class _Transport(httpx.AsyncBaseTransport):
    """Transport von httpx über einen httpcore.AsyncConnectionPool mit gebundenem Netzanschluss."""

    def __init__(self, pool: httpcore.AsyncConnectionPool) -> None:
        self._pool = pool

    async def handle_async_request(self, request: httpx.Request) -> httpx.Response:
        """Sendet die Anfrage über den Pool und liefert die Antwort mit Rohstrom."""
        anfrage = httpcore.Request(
            method=request.method,
            url=httpcore.URL(
                scheme=request.url.raw_scheme,
                host=request.url.raw_host,
                port=request.url.port,
                target=request.url.raw_path,
            ),
            headers=request.headers.raw,
            content=request.stream,
            extensions=request.extensions,
        )
        antwort = await self._pool.handle_async_request(anfrage)
        strom = antwort.stream
        # httpx baut bei jeder Antwort mit location-Kopfzeile eine Folgeanfrage und scheitert an
        # einem nicht lesbaren Wert mit einem Text, der den Wert enthält. Die Kopfzeile bleibt
        # deshalb für httpx unsichtbar; die Rohform liegt in der Erweiterung ROHKOPF.
        sichtbar = [(n, w) for n, w in antwort.headers if n.lower() != b"location"]
        return httpx.Response(
            status_code=antwort.status,
            headers=sichtbar,
            stream=_Antwortstrom(
                strom.__aiter__(),  # type: ignore[union-attr]
                strom.aclose,  # type: ignore[union-attr]
            ),
            extensions={**antwort.extensions, ROHKOPF: tuple(antwort.headers)},
        )

    async def aclose(self) -> None:
        """Schliesst den Pool."""
        await self._pool.aclose()


class Verbindungsweg(Protocol):
    """Liefert den Transport für einen Schritt.

    Verbindungsziel ist allein die geprüfte Adresse; name_oder_adresse dient allein der
    Host-Kopfzeile, dem SNI und der Zertifikatsprüfung und wird nie aufgelöst.
    """

    def transport(
        self,
        *,
        name_oder_adresse: str,
        adresse: Adresse,
        anschluss: int,
        ssl_kontext: ssl.SSLContext,
    ) -> httpx.AsyncBaseTransport:
        """Baut den Transport eines Schritts."""
        ...


class GebundenerVerbindungsweg:
    """Standard-Verbindungsweg: ein Pool je Schritt mit gebundenem Netzanschluss (Weg a)."""

    def __init__(self, innen: httpcore.AsyncNetworkBackend | None = None) -> None:
        self._innen = innen

    def transport(
        self,
        *,
        name_oder_adresse: str,
        adresse: Adresse,
        anschluss: int,
        ssl_kontext: ssl.SSLContext,
    ) -> httpx.AsyncBaseTransport:
        """Ein httpcore.AsyncConnectionPool mit HTTP/1.1, ohne Wiederholungen."""
        netz = GebundenerNetzanschluss(
            rechner=name_oder_adresse,
            anschluss=anschluss,
            adresse=adresse,
            innen=self._innen,
        )
        pool = httpcore.AsyncConnectionPool(
            ssl_context=ssl_kontext,
            max_connections=1,
            max_keepalive_connections=0,
            http1=True,
            http2=False,
            retries=0,
            network_backend=netz,
        )
        return _Transport(pool)


def bibliotheksclient_bauen(
    transport: httpx.AsyncBaseTransport, frist: float
) -> httpx.AsyncClient:
    """Der Bibliotheksclient eines Schritts; die einzige Stelle mit diesen Einstellungen.

    follow_redirects und trust_env sind aus; kein Proxy, keine mounts, keine Kopfzeilen vorab.
    Der Aufrufer schliesst den Client am Ende des Schritts (async with oder aclose).
    """
    client = httpx.AsyncClient(
        transport=transport,
        trust_env=False,
        follow_redirects=False,
        timeout=httpx.Timeout(frist),
    )
    client.headers.clear()
    return client


# ---- Hilfen -------------------------------------------------------------------------------------


@functools.cache
def _standardkontext() -> ssl.SSLContext:
    """Eigener ssl-Kontext mit den Wurzeln aus certifi, nicht aus der Umgebung."""
    kontext = ssl.create_default_context(cafile=certifi.where())
    kontext.minimum_version = _MINDESTFASSUNG
    kontext.verify_mode = ssl.CERT_REQUIRED
    kontext.check_hostname = True
    return kontext


def _kontext_geprueft(kontext: ssl.SSLContext) -> bool:
    return (
        kontext.verify_mode == ssl.CERT_REQUIRED
        and kontext.check_hostname
        and kontext.minimum_version in (ssl.TLSVersion.TLSv1_2, ssl.TLSVersion.TLSv1_3)
    )


def _bibliothekslogger_abdichten() -> None:
    """Keine Meldung von httpx und httpcore auf irgendeiner Stufe (DS-S21-09, M11, M12, M40).

    Die Eltern stehen über CRITICAL, jedes bestehende Kind steht auf NOTSET und erbt; die Kinder
    werden bei jedem Aufruf neu erfasst. propagate bleibt unverändert.
    """
    logging.getLogger("httpx").setLevel(_LOGGER_STUFE)
    logging.getLogger("httpcore").setLevel(_LOGGER_STUFE)
    for name, logger in list(logging.root.manager.loggerDict.items()):
        if name.startswith(_PRAEFIXE_LOGGER) and isinstance(logger, logging.Logger):
            logger.setLevel(logging.NOTSET)


def _kopfzeilen_pruefen(kopfzeilen: Mapping[str, str]) -> None:
    """Fehlerfall: EingabeFehler mit festem Text; Sperrliste und Zeichenvorrat."""
    for name, wert in kopfzeilen.items():
        kleinname = name.lower()
        if (
            not name
            or kleinname in _SPERRLISTE
            or kleinname.startswith("proxy-")
            or any(not 0x21 <= ord(z) <= 0x7E or z == ":" for z in name)
            or any(not 0x20 <= ord(z) <= 0x7E for z in wert)
        ):
            raise EingabeFehler("Eine Kopfzeile ist nicht zulässig.")


def _rohkopfzeilen(antwort: httpx.Response) -> Paare:
    roh = antwort.extensions.get(ROHKOPF, antwort.headers.raw)
    return tuple((n.decode("latin-1"), w.decode("latin-1")) for n, w in roh)


def _kodierung_ungueltig(paare: Paare) -> bool:
    """Jede Kopfzeile content-encoding ausser leer und identity ist ungültig."""
    for name, wert in paare:
        if name.strip().lower() == "content-encoding" and wert.strip().lower() not in (
            "",
            "identity",
        ):
            return True
    return False


def _fehlerart_aus(fehler: BaseException) -> Fehlerart:
    """Ordnet eine Ausnahme dem Vorrat zu; liest allein Typen, gibt nur den Vorratswert zurück."""
    if isinstance(
        fehler, (TimeoutError, httpx.TimeoutException, httpcore.TimeoutException)
    ):
        return "zeitueberschreitung"
    kette: list[BaseException] = []
    aktuell: BaseException | None = fehler
    while aktuell is not None and len(kette) < 12:
        kette.append(aktuell)
        aktuell = aktuell.__cause__ or aktuell.__context__
    if any(isinstance(glied, ssl.SSLError) for glied in kette):
        return "tls"
    if any(
        isinstance(glied, (httpcore.ProtocolError, httpx.ProtocolError))
        for glied in kette
    ):
        return "antwort_ungueltig"
    return "verbindung"


class _Abbruch(Exception):
    """Interne Meldung eines Fehlschlags mit Vorratswert; nie Teil eines Rückgabewerts."""

    def __init__(self, art: Fehlerart) -> None:
        super().__init__()
        self.art: Fehlerart = art


@dataclass(frozen=True, slots=True)
class _Plan:
    """Entscheidung über die Folge einer Antwort."""

    art: Literal["keine", "weiter", "unauswertbar"]
    url: str | None = None
    ziel: Ziel | None = None
    methode: Methode = "GET"
    koerper: bytes | None = None
    verworfen: bool = False


@dataclass(frozen=True, slots=True)
class _Roh:
    status: int
    paare: Paare
    koerper: bytes
    plan: _Plan


def _rechner_text(ziel: Ziel) -> str:
    return f"[{ziel.wert}]" if ziel.art == "ipv6" else ziel.wert


# ---- Client -------------------------------------------------------------------------------------


class Client:
    """Der Client nach aussen.

    positivliste: die Positivliste der Umgebung; die Höchstzahl der Weiterleitungen steht in ihr.
    aufloeser: genau ein Aufruf je Schritt mit Name.
    vertrauensanker: ersetzt die Wurzeln aus certifi; abgewiesen (KonfigurationsFehler), wenn die
        Prüfung des Zertifikats oder des Namens abgeschaltet ist oder die Mindestfassung unter
        TLS 1.2 liegt. Von keiner Konfiguration und keinem Aufrufer unter backend/src erreichbar.
    verbindungsweg: Standard ist GebundenerVerbindungsweg.
    """

    def __init__(
        self,
        *,
        positivliste: Positivliste,
        aufloeser: Aufloeser,
        vertrauensanker: ssl.SSLContext | None = None,
        verbindungsweg: Verbindungsweg | None = None,
    ) -> None:
        if vertrauensanker is not None and not _kontext_geprueft(vertrauensanker):
            raise KonfigurationsFehler(
                "Der Vertrauensanker prüft Zertifikat, Namen oder Mindestfassung nicht.",
                "Einen Kontext mit CERT_REQUIRED, check_hostname und mindestens TLS 1.2 übergeben.",
            )
        self._positivliste = positivliste
        self._aufloeser = aufloeser
        self._ssl = (
            vertrauensanker if vertrauensanker is not None else _standardkontext()
        )
        self._weg: Verbindungsweg = (
            verbindungsweg if verbindungsweg is not None else GebundenerVerbindungsweg()
        )

    async def anfragen(
        self,
        kontext: Spurkontext,
        *,
        methode: Literal["GET", "POST"],
        url: str,
        grenzen: Antwortgrenzen,
        kopfzeilen: Mapping[str, str] | None = None,
        koerper: bytes | None = None,
    ) -> Antwort | Abweisung | Fehlschlag:
        """Ein Aufruf mit allen Schritten einer Weiterleitungskette.

        Eingabefehler (EingabeFehler) vor jedem Versuch, ohne Eintrag und ohne Netzakt: Körper bei
        GET, nicht zulässige Kopfzeile, Fall besteht nicht. Danach ist jede Abweisung und jeder
        Fehlschlag Rückgabewert.
        """
        if methode not in ("GET", "POST") or (methode == "GET" and koerper is not None):
            raise EingabeFehler("Methode und Körper passen nicht zusammen.")
        _kopfzeilen_pruefen(kopfzeilen or {})
        await kontext.fall_pruefen()
        versuch = neue_kennung()
        schleife = asyncio.get_running_loop()
        endzeit = schleife.time() + grenzen.frist_sekunden
        _bibliothekslogger_abdichten()
        stand = self._positivliste.listenstand
        hoechstzahl = self._positivliste.ausgang_weiterleitungen_hoechstzahl

        async def eintragen(**felder: Any) -> None:
            await kontext.eintragen(
                Verbindungsversuch(
                    fall_kennung=kontext.fall_kennung,
                    werkzeug=kontext.werkzeug,
                    versuch_kennung=versuch,
                    listenstand=stand,
                    **felder,
                )
            )

        schritt = 0
        aktuelle_url: str | None = url
        aktuelle_methode: Methode = methode
        aktueller_koerper = koerper
        aktuelle_kopfzeilen: dict[str, str] = dict(kopfzeilen or {})
        ziel0 = ""
        vorige: str | None = None
        verworfen = False

        while True:
            ausgangsziel = {"ausgangsziel": vorige} if schritt > 0 else {}
            kopf = {
                "schritt": schritt,
                "methode": aktuelle_methode,
                **ausgangsziel,
            }
            # (1) Ziel bestimmen
            ziel: Ziel | None = None
            if aktuelle_url is not None:
                try:
                    ziel = aus_url(aktuelle_url)
                except ZielFehler:
                    ziel = None
            if ziel is None or aktuelle_url is None:
                await eintragen(ergebnis="url_nicht_auswertbar", **kopf)
                return Abweisung("url_nicht_auswertbar", schritt, versuch)
            zielform = ziel.zielform()
            grund = {
                "schema": ziel.schema,
                "anschluss": ziel.anschluss,
                "zielart": ziel.art,
                "ziel": zielform,
            }
            if schritt == 0:
                ziel0 = zielform
            # (2) Höchstzahl
            if schritt > hoechstzahl:
                await eintragen(ergebnis="kette_zu_lang", **kopf, **grund)
                return Abweisung("kette_zu_lang", schritt, versuch)
            # (3) Positivliste
            eintrag = self._positivliste.eintrag_fuer(ziel)
            if eintrag is None:
                await eintragen(ergebnis="nicht_in_positivliste", **kopf, **grund)
                return Abweisung("nicht_in_positivliste", schritt, versuch)
            # (4) Adresse
            adresse: Adresse
            if ziel.art == "name":
                adressen: tuple[Adresse, ...] = ()
                aufloesung_fehlt = False
                try:
                    async with asyncio.timeout_at(endzeit):
                        adressen = tuple(await self._aufloeser.aufloesen(ziel.wert))
                except Exception:  # noqa: BLE001 (Merker; kein Wert verlässt den Block)
                    aufloesung_fehlt = True
                if aufloesung_fehlt or not adressen:
                    await eintragen(
                        ergebnis="aufloesung_fehlgeschlagen",
                        listeneintrag=eintrag.kennung,
                        **kopf,
                        **grund,
                    )
                    return Abweisung("aufloesung_fehlgeschlagen", schritt, versuch)
                adresse = adressen[0]
                abgewiesen: tuple[Adresse, Adressbereich] | None = None
                for kandidat in adressen:
                    bereich = adressbereich(kandidat)
                    if bereich != "oeffentlich":
                        abgewiesen = (kandidat, bereich)
                        break
                if abgewiesen is not None:
                    await eintragen(
                        ergebnis="bereich_nicht_oeffentlich",
                        adresse=str(abgewiesen[0]),
                        adressbereich=abgewiesen[1],
                        listeneintrag=eintrag.kennung,
                        **kopf,
                        **grund,
                    )
                    return Abweisung("bereich_nicht_oeffentlich", schritt, versuch)
            else:
                adresse = ziel.adresse()
            adressfelder = {
                "adresse": str(adresse),
                "adressbereich": adressbereich(adresse),
                "listeneintrag": eintrag.kennung,
            }
            # (5) Eintrag zugelassen vor dem Netzakt
            await eintragen(ergebnis="zugelassen", **kopf, **grund, **adressfelder)
            # (6) Netzakt
            zielform0 = ziel0

            def planen(
                status: int,
                paare: Paare,
                *,
                aktuelle_url: str = aktuelle_url,
                aktuelle_methode: Methode = aktuelle_methode,
                aktueller_koerper: bytes | None = aktueller_koerper,
                verworfen: bool = verworfen,
                zielform0: str = zielform0,
            ) -> _Plan:
                return _weiterleitung_planen(
                    status,
                    paare,
                    aktuelle_url=aktuelle_url,
                    methode=aktuelle_methode,
                    koerper=aktueller_koerper,
                    verworfen=verworfen,
                    zielform0=zielform0,
                )

            ergebnis = await self._netzakt(
                ziel=ziel,
                adresse=adresse,
                endzeit=endzeit,
                methode=aktuelle_methode,
                url=aktuelle_url,
                kopfzeilen=aktuelle_kopfzeilen,
                koerper=aktueller_koerper,
                frist=grenzen.frist_sekunden,
                grenze=grenzen.antwortgroesse_bytes,
                planen=planen,
            )
            if isinstance(ergebnis, str):
                await eintragen(
                    ergebnis="verbindung_fehlgeschlagen",
                    fehlerart=ergebnis,
                    **kopf,
                    **grund,
                    **adressfelder,
                )
                return Fehlschlag(ergebnis, schritt, versuch)
            await eintragen(
                ergebnis="beantwortet",
                status=ergebnis.status,
                antwort_bytes=len(ergebnis.koerper),
                **kopf,
                **grund,
                **adressfelder,
            )
            plan = ergebnis.plan
            if plan.art == "keine":
                return Antwort(
                    ergebnis.status,
                    ergebnis.paare,
                    ergebnis.koerper,
                    schritt,
                    eintrag.kennung,
                    versuch,
                )
            # (7) Weiterleitung
            vorige = zielform
            aktuelle_url = plan.url
            aktuelle_methode = plan.methode
            aktueller_koerper = plan.koerper
            if plan.verworfen and not verworfen:
                verworfen = True
                aktuelle_kopfzeilen = {}
            schritt += 1

    async def _netzakt(
        self,
        *,
        ziel: Ziel,
        adresse: Adresse,
        endzeit: float,
        methode: Methode,
        url: str,
        kopfzeilen: Mapping[str, str],
        koerper: bytes | None,
        frist: float,
        grenze: int,
        planen: Callable[[int, Paare], _Plan],
    ) -> _Roh | Fehlerart:
        """Verbindung, Anfrage und Lesen unter der Gesamtfrist; Rückgabe ein Ergebnis oder die Art."""
        fehler: Fehlerart | None = None
        roh: _Roh | None = None
        anfrage_url = f"{ziel.schema}://{_rechner_text(ziel)}:{ziel.anschluss}{pfad_und_abfrage(url)}"
        kopf = {**kopfzeilen, "accept-encoding": "identity"}
        try:
            transport = self._weg.transport(
                name_oder_adresse=ziel.wert,
                adresse=adresse,
                anschluss=ziel.anschluss,
                ssl_kontext=self._ssl,
            )
            async with (
                bibliotheksclient_bauen(transport, frist) as client,
                asyncio.timeout_at(endzeit),
                client.stream(
                    methode, anfrage_url, headers=kopf, content=koerper
                ) as antwort,
            ):
                paare = _rohkopfzeilen(antwort)
                if _kodierung_ungueltig(paare) or not 100 <= antwort.status_code <= 599:
                    raise _Abbruch("antwort_ungueltig")
                plan = planen(antwort.status_code, paare)
                if plan.art != "keine":
                    roh = _Roh(antwort.status_code, paare, b"", plan)
                else:
                    teile: list[bytes] = []
                    gelesen = 0
                    async for stueck in antwort.aiter_raw():
                        gelesen += len(stueck)
                        if gelesen > grenze:
                            raise _Abbruch("antwort_zu_gross")
                        teile.append(stueck)
                    roh = _Roh(antwort.status_code, paare, b"".join(teile), plan)
        except _Abbruch as abbruch:
            fehler = abbruch.art
        except Exception as ausnahme:  # noqa: BLE001 (nur der Vorratswert verlässt den Block)
            fehler = _fehlerart_aus(ausnahme)
        if fehler is not None:
            return fehler
        if (
            roh is None
        ):  # pragma: no cover (nicht erreichbar: ohne Fehler ist roh gesetzt)
            return "verbindung"
        return roh


def _weiterleitung_planen(
    status: int,
    paare: Paare,
    *,
    aktuelle_url: str,
    methode: Methode,
    koerper: bytes | None,
    verworfen: bool,
    zielform0: str,
) -> _Plan:
    """Entscheidet nach Schritt (7), ob und wohin die Antwort weiterleitet.

    Ein Zielwechsel ist eine Abweichung der Zielform von der von Schritt 0; ab dem ersten
    Zielwechsel bleiben Kopfzeilen des Aufrufers und Körper verworfen. 307 und 308 mit Körper und
    Zielwechsel werden nicht verfolgt.
    """
    if status not in _STATUS_WEITERLEITUNG:
        return _Plan("keine")
    orte = [wert for name, wert in paare if name.strip().lower() == "location"]
    if len(orte) == 0 or (len(orte) == 1 and orte[0].strip() == ""):
        return _Plan("keine")
    if status == 303 or (status in (301, 302) and methode == "POST"):
        naechste_methode: Methode = "GET"
        naechster_koerper: bytes | None = None
    else:
        naechste_methode = methode
        naechster_koerper = koerper
    if len(orte) > 1:
        return _Plan(
            "unauswertbar", None, None, naechste_methode, naechster_koerper, verworfen
        )
    absolut: str | None = None
    ziel: Ziel | None = None
    try:
        absolut = urljoin(aktuelle_url, orte[0].strip())
        ziel = aus_url(absolut)
    except (ValueError, ZielFehler):
        ziel = None
    if ziel is None or absolut is None:
        return _Plan(
            "unauswertbar", None, None, naechste_methode, naechster_koerper, verworfen
        )
    wechsel = verworfen or ziel.zielform() != zielform0
    if status in (307, 308) and koerper is not None and wechsel and not verworfen:
        return _Plan("keine")
    if wechsel:
        naechster_koerper = None
    return _Plan("weiter", absolut, ziel, naechste_methode, naechster_koerper, wechsel)
