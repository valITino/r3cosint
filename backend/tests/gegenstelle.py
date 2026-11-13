"""Testgegenstelle (ADR 0008, Festlegung S2.1, Zeile Testgegenstelle; nur im Testbaum).

Ein minimaler HTTP/1.1-Server auf 127.0.0.1 ohne Bibliothek, der je Anfrage nach einem
Antwortskript antwortet und alles aufzeichnet, was ein Client sendet. Der Testbaum ist kein Paket:
das Modul wird über den Dateipfad unter dem Namen r3cosint_gegenstelle geladen
(conftest.gegenstelle_laden) und von allen Tests geteilt. Alle Werte sind erfunden (5.15); es gibt
keine IPv6-Bindung (GK-21) und keine Prozessausgabe.
"""

import asyncio
import gzip
import ipaddress
import ssl
from collections.abc import Sequence
from dataclasses import dataclass, field
from typing import Literal

TESTKONSTANTE = ipaddress.IPv6Address("2001:20::1")
"""Öffentliche Adresse aus dem Namenspfad der Tests; wird nie kontaktiert (GK-5)."""

MERKMAL = "mk-7f3a9c-synthetisch"
"""Synthetische Zeichenfolge für Pfad, Abfrageteil, Fragment und Benutzerangaben (DS-S21-04)."""

_KOPFENDE = b"\r\n\r\n"
_GRUND = {200: "OK", 204: "No Content"}


@dataclass(frozen=True)
class Antwortskript:
    """Eine Antwort der Gegenstelle; die Formen sind Klassenmethoden."""

    art: Literal[
        "treffer",
        "leer",
        "status",
        "zeitueberschreitung",
        "weiterleitung",
        "gross",
        "komprimiert",
        "verzoegert",
        "kodierung",
    ]
    status_code: int = 200
    anzahl: int = 0
    location: object | tuple[object, ...] | None = None
    komprimiert_flag: bool = False
    bytes_anzahl: int = 0
    sekunden: float = 0.0
    inneres: "Antwortskript | None" = None
    kodierung_wert: str = ""

    @classmethod
    def treffer(cls, anzahl: int) -> "Antwortskript":
        """200 mit einem kleinen Körper, der die Zahl der Treffer nennt."""
        return cls("treffer", anzahl=anzahl)

    @classmethod
    def leer(cls) -> "Antwortskript":
        """200 mit leerem Körper."""
        return cls("leer")

    @classmethod
    def status(cls, code: int) -> "Antwortskript":
        """Der Statuscode mit einem kleinen Körper."""
        return cls("status", status_code=code)

    @classmethod
    def zeitueberschreitung(cls) -> "Antwortskript":
        """Liest die Anfrage und antwortet nie, bis die Verbindung schliesst."""
        return cls("zeitueberschreitung")

    @classmethod
    def weiterleitung(
        cls,
        status: int,
        location: object | tuple[object, ...] | None,
        *,
        komprimiert: bool = False,
    ) -> "Antwortskript":
        """3xx; location als Objekt (str() beim Antworten), Tupel (je eine Kopfzeile) oder None."""
        return cls(
            "weiterleitung",
            status_code=status,
            location=location,
            komprimiert_flag=komprimiert,
        )

    @classmethod
    def gross(cls, bytes_anzahl: int) -> "Antwortskript":
        """200 mit einem Körper aus bytes_anzahl Bytes."""
        return cls("gross", bytes_anzahl=bytes_anzahl)

    @classmethod
    def komprimiert(cls, dekodiert_bytes: int = 0) -> "Antwortskript":
        """200 mit content-encoding gzip; dekodiert_bytes > 0: gzip-Block, der so gross dekodiert."""
        return cls("komprimiert", bytes_anzahl=dekodiert_bytes)

    @classmethod
    def kodierung(cls, wert: str) -> "Antwortskript":
        """200 mit unkomprimiertem Körper und der Kopfzeile content-encoding mit genau diesem Wert."""
        return cls("kodierung", kodierung_wert=wert)

    @classmethod
    def verzoegert(cls, sekunden: float, skript: "Antwortskript") -> "Antwortskript":
        """Wartet sekunden nach dem Lesen der Anfrage und antwortet dann nach skript."""
        return cls("verzoegert", sekunden=sekunden, inneres=skript)


@dataclass(frozen=True)
class Anfrage:
    """Eine gesehene Anfrage."""

    methode: str
    pfad: str
    host: str | None
    accept_encoding: str | None
    kopfzeilen: tuple[tuple[str, str], ...]
    koerper: bytes


@dataclass
class Gegenstelle:
    """Laufende Gegenstelle; Instanzen entstehen mit await Gegenstelle.starten(...)."""

    anschluss: int = 0
    verbindungen: int = 0
    anfragen: list[Anfrage] = field(default_factory=list)
    sni_namen: list[str | None] = field(default_factory=list)
    _skripte: list[Antwortskript] = field(default_factory=list)
    _server: asyncio.Server | None = None
    _schreiber: list[asyncio.StreamWriter] = field(default_factory=list)

    @classmethod
    async def starten(
        cls,
        skript: Antwortskript | Sequence[Antwortskript],
        *,
        tls: ssl.SSLContext | None = None,
    ) -> "Gegenstelle":
        """Startet auf 127.0.0.1, Anschluss 0; mit tls spricht sie TLS und zeichnet den SNI-Namen auf.

        Der n-te Aufruf antwortet nach dem n-ten Skript, das letzte gilt für alle weiteren.
        Der Kontext tls erhält den Rückruf für den SNI-Namen.
        """
        instanz = cls()
        instanz.setzen(skript)
        if tls is not None:

            def merken(
                _objekt: ssl.SSLObject | ssl.SSLSocket,
                name: str | None,
                _kontext: ssl.SSLContext,
            ) -> None:
                instanz.sni_namen.append(name)

            tls.sni_callback = merken
        server = await asyncio.start_server(instanz._bedienen, "127.0.0.1", 0, ssl=tls)
        instanz._server = server
        instanz.anschluss = int(server.sockets[0].getsockname()[1])
        return instanz

    def setzen(self, skript: Antwortskript | Sequence[Antwortskript]) -> None:
        """Ersetzt das Antwortskript."""
        self._skripte = [skript] if isinstance(skript, Antwortskript) else list(skript)

    async def beenden(self) -> None:
        """Beendet die Gegenstelle und schliesst offene Verbindungen."""
        server = self._server
        if server is None:
            return
        self._server = None
        server.close()
        for schreiber in list(self._schreiber):
            schreiber.close()
        await server.wait_closed()

    # ---- Bedienung ------------------------------------------------------------------------

    async def _bedienen(
        self, leser: asyncio.StreamReader, schreiber: asyncio.StreamWriter
    ) -> None:
        self.verbindungen += 1
        self._schreiber.append(schreiber)
        try:
            anfrage = await self._lesen(leser)
            if anfrage is None:
                return
            self.anfragen.append(anfrage)
            nummer = min(len(self.anfragen), len(self._skripte)) - 1
            await self._antworten(self._skripte[nummer], leser, schreiber)
        except (OSError, asyncio.IncompleteReadError, ssl.SSLError, ValueError):
            return
        finally:
            schreiber.close()
            if schreiber in self._schreiber:
                self._schreiber.remove(schreiber)

    async def _lesen(self, leser: asyncio.StreamReader) -> Anfrage | None:
        kopf = await leser.readuntil(_KOPFENDE)
        zeilen = kopf[: -len(_KOPFENDE)].decode("latin-1").split("\r\n")
        teile = zeilen[0].split(" ")
        if len(teile) < 2:
            return None
        kopfzeilen: list[tuple[str, str]] = []
        for zeile in zeilen[1:]:
            name, trenner, wert = zeile.partition(":")
            if trenner:
                kopfzeilen.append((name, wert.strip()))
        laenge = 0
        host: str | None = None
        accept: str | None = None
        for name, wert in kopfzeilen:
            kleinname = name.lower()
            if kleinname == "content-length":
                laenge = int(wert)
            elif kleinname == "host":
                host = wert
            elif kleinname == "accept-encoding":
                accept = wert
        koerper = await leser.readexactly(laenge) if laenge > 0 else b""
        return Anfrage(
            methode=teile[0],
            pfad=teile[1],
            host=host,
            accept_encoding=accept,
            kopfzeilen=tuple(kopfzeilen),
            koerper=koerper,
        )

    async def _antworten(
        self,
        skript: Antwortskript,
        leser: asyncio.StreamReader,
        schreiber: asyncio.StreamWriter,
    ) -> None:
        if skript.art == "verzoegert" and skript.inneres is not None:
            await asyncio.sleep(skript.sekunden)
            await self._antworten(skript.inneres, leser, schreiber)
            return
        if skript.art == "zeitueberschreitung":
            await leser.read()
            return
        kopfzeilen: list[tuple[str, str]] = []
        status = skript.status_code
        koerper = b""
        if skript.art == "treffer":
            koerper = f'{{"treffer": {skript.anzahl}}}'.encode("ascii")
        elif skript.art == "status":
            koerper = b"synthetisch"
        elif skript.art == "gross":
            koerper = b"x" * skript.bytes_anzahl
        elif skript.art == "kodierung":
            koerper = b"synthetisch"
            kopfzeilen.append(("content-encoding", skript.kodierung_wert))
        elif skript.art == "komprimiert":
            koerper = gzip.compress(
                b"x" * skript.bytes_anzahl
                if skript.bytes_anzahl
                else b"synthetisch" * 4
            )
            kopfzeilen.append(("content-encoding", "gzip"))
        elif skript.art == "weiterleitung":
            orte = (
                skript.location
                if isinstance(skript.location, tuple)
                else (() if skript.location is None else (skript.location,))
            )
            kopfzeilen.extend(("location", str(ort)) for ort in orte)
            if skript.komprimiert_flag:
                koerper = gzip.compress(b"synthetisch")
                kopfzeilen.append(("content-encoding", "gzip"))
        kopf = [f"HTTP/1.1 {status} {_GRUND.get(status, 'X')}"]
        kopf += [f"{n}: {w}" for n, w in kopfzeilen]
        kopf += [f"content-length: {len(koerper)}", "connection: close", "", ""]
        schreiber.write("\r\n".join(kopf).encode("latin-1", "replace") + koerper)
        await schreiber.drain()
