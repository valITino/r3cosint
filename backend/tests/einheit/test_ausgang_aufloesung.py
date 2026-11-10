"""Einheitstest: ausgang.aufloesung (ADR 0008, Festlegung S2.1; R3-F-028).

Keine echte Namensauflösung: der StandardAufloeser läuft über ein ersetztes loop.getaddrinfo.
"""

import asyncio
import ipaddress
import socket
from typing import Any

import pytest

from r3cosint.ausgang.aufloesung import (
    ADRESSBEREICHE,
    Adresse,
    Aufloeser,
    AufloesungsFehler,
    StandardAufloeser,
    adressbereich,
)
from r3cosint.core.fehler import R3cosintFehler

# Testkonstante des zulässigen Namenspfads (ORCHIDv2, E-S2-03 a); zu ihr entsteht nie eine
# Verbindung. Sie steht allein im Testbaum.
_TESTKONSTANTE = "2001:20::1"

KLASSEN: list[tuple[str, str]] = [
    ("0.0.0.0", "unspezifiziert"),  # noqa: S104
    ("::", "unspezifiziert"),
    ("127.0.0.1", "rueckschleife"),
    ("::1", "rueckschleife"),
    ("169.254.1.1", "verbindungslokal"),
    ("fe80::1", "verbindungslokal"),
    ("fec0::1", "standortlokal"),
    ("224.0.0.1", "multicast"),
    ("ff02::1", "multicast"),
    ("10.0.0.1", "privat"),
    ("192.0.2.1", "privat"),
    ("198.51.100.1", "privat"),
    ("203.0.113.1", "privat"),
    ("240.0.0.1", "privat"),
    ("192.88.99.1", "abgekuendigt"),
    ("192.0.0.9", "protokollzuweisung"),
    ("192.0.0.10", "protokollzuweisung"),
    ("2001:1::1", "protokollzuweisung"),
    ("2001:1::2", "protokollzuweisung"),
    ("2001:1::3", "privat"),
    ("2001:3::1", "oeffentlich"),
    ("2001:4:112::1", "oeffentlich"),
    ("2001:30::1", "oeffentlich"),
    ("100.64.0.1", "nicht_global"),
    ("64:ff9b::1", "reserviert"),
    ("64:ff9b::a00:1", "reserviert"),
    ("::10.0.0.1", "reserviert"),
    ("::127.0.0.1", "reserviert"),
    ("5f00::1", "reserviert"),
    ("2002:a00:1::", "privat"),
    ("2001::1", "privat"),
    ("64:ff9b:1::a00:1", "privat"),
    ("::ffff:10.0.0.1", "privat"),
    ("::ffff:127.0.0.1", "rueckschleife"),
    ("::ffff:8.8.8.8", "oeffentlich"),
    ("8.8.8.8", "oeffentlich"),
    ("2606:4700::1111", "oeffentlich"),
    (_TESTKONSTANTE, "oeffentlich"),
]


@pytest.mark.parametrize(("adresse", "klasse"), KLASSEN)
def test_R3_F_028_klassentabelle(adresse: str, klasse: str) -> None:
    assert adressbereich(ipaddress.ip_address(adresse)) == klasse


def test_R3_F_028_vorbedingung_testkonstante_ist_oeffentlich_und_global() -> None:
    adresse = ipaddress.ip_address(_TESTKONSTANTE)
    assert adresse.is_global
    assert adressbereich(adresse) == "oeffentlich"


def test_R3_F_028_nur_oeffentlich_ist_zulaessig_und_der_vorrat_ist_geschlossen() -> (
    None
):
    gesehen = {klasse for _, klasse in KLASSEN}
    assert gesehen <= set(ADRESSBEREICHE)
    assert len(ADRESSBEREICHE) == len(set(ADRESSBEREICHE)) == 11
    assert ADRESSBEREICHE[-1] == "oeffentlich"
    assert ADRESSBEREICHE.index("privat") < ADRESSBEREICHE.index("reserviert")
    assert ADRESSBEREICHE.index("reserviert") < ADRESSBEREICHE.index("abgekuendigt")
    assert ADRESSBEREICHE.index("abgekuendigt") < ADRESSBEREICHE.index(
        "protokollzuweisung"
    )
    assert ADRESSBEREICHE.index("standortlokal") < ADRESSBEREICHE.index("multicast")


def test_R3_F_028_frueheres_merkmal_gewinnt_auch_in_der_festen_liste() -> None:
    """DT-S21-A-01: 2001:1::3 und 240.0.0.1 sind für ipaddress privat und bleiben es."""
    assert adressbereich(ipaddress.ip_address("2001:1::3")) == "privat"
    assert adressbereich(ipaddress.ip_address("240.0.0.1")) == "privat"


def test_R3_F_028_netze_der_listen_gelten_nur_fuer_die_eigene_fassung() -> None:
    assert adressbereich(ipaddress.ip_address("192.0.0.200")) in {
        "protokollzuweisung",
        "privat",
    }
    assert adressbereich(ipaddress.ip_address("2001:1::4")) == "privat"


class _Steuerbar:
    """Testhilfe: Antwort je Name, Zähler je Name (kein Netz)."""

    def __init__(self, antworten: dict[str, tuple[Adresse, ...]]) -> None:
        self.antworten = antworten
        self.zaehler: dict[str, int] = {}

    async def aufloesen(self, name: str) -> tuple[Adresse, ...]:
        self.zaehler[name] = self.zaehler.get(name, 0) + 1
        return self.antworten[name]


def test_R3_F_028_steuerbarer_aufloeser_erfuellt_das_protokoll() -> None:
    aufloeser: Aufloeser = _Steuerbar({"gut.test": (ipaddress.ip_address("8.8.8.8"),)})
    ergebnis = asyncio.run(aufloeser.aufloesen("gut.test"))
    assert ergebnis == (ipaddress.ip_address("8.8.8.8"),)


def _info(adresse: str, familie: int = socket.AF_INET) -> tuple[Any, ...]:
    return (familie, socket.SOCK_STREAM, 6, "", (adresse, 0))


class _Schleifenersatz:
    """Ersetzt loop.getaddrinfo; zeichnet die Aufrufe auf, ruft nie die Auflösung des Systems."""

    def __init__(
        self, antwort: Any = None, fehler: BaseException | None = None
    ) -> None:
        self.antwort = antwort
        self.fehler = fehler
        self.aufrufe: list[tuple[str, Any, int]] = []

    async def __call__(self, host: str, port: Any, *, type: int) -> Any:
        self.aufrufe.append((host, port, type))
        if self.fehler is not None:
            raise self.fehler
        return self.antwort


def _aufloesen(
    monkeypatch: pytest.MonkeyPatch, ersatz: _Schleifenersatz
) -> tuple[Adresse, ...]:
    async def lauf() -> tuple[Adresse, ...]:
        schleife = asyncio.get_running_loop()
        monkeypatch.setattr(schleife, "getaddrinfo", ersatz)
        return await StandardAufloeser().aufloesen("gut.test")

    return asyncio.run(lauf())


def test_R3_F_028_standardaufloeser_reihenfolge_dubletten_und_aufruf(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    ersatz = _Schleifenersatz(
        [
            _info("8.8.8.8"),
            _info("2606:4700::1111", socket.AF_INET6),
            _info("8.8.8.8"),
            _info("1.1.1.1"),
        ]
    )
    ergebnis = _aufloesen(monkeypatch, ersatz)
    assert ergebnis == tuple(
        ipaddress.ip_address(a) for a in ("8.8.8.8", "2606:4700::1111", "1.1.1.1")
    )
    assert ersatz.aufrufe == [("gut.test", None, socket.SOCK_STREAM)]


def test_R3_F_028_standardaufloeser_schneidet_die_zonenangabe_ab(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    ergebnis = _aufloesen(
        monkeypatch, _Schleifenersatz([_info("fe80::1%eth0", socket.AF_INET6)])
    )
    assert ergebnis == (ipaddress.ip_address("fe80::1"),)
    assert adressbereich(ergebnis[0]) == "verbindungslokal"


def test_R3_F_028_standardaufloeser_bildet_ipv4_in_ipv6_auf_ipv4_ab(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    ergebnis = _aufloesen(
        monkeypatch,
        _Schleifenersatz(
            [_info("::ffff:10.0.0.1", socket.AF_INET6), _info("10.0.0.1")]
        ),
    )
    assert ergebnis == (ipaddress.ip_address("10.0.0.1"),)


@pytest.mark.parametrize(
    "ersatz",
    [
        _Schleifenersatz([]),
        _Schleifenersatz(None),
        _Schleifenersatz(fehler=socket.gaierror(-2, "GEHEIM.test unbekannt")),
        _Schleifenersatz(fehler=OSError("GEHEIM.test")),
        _Schleifenersatz(fehler=UnicodeError("GEHEIM.test")),
        _Schleifenersatz([_info("8.8.8.8"), _info("kein-literal")]),
    ],
)
def test_R3_F_028_standardaufloeser_fehler_und_leere_antwort(
    monkeypatch: pytest.MonkeyPatch, ersatz: _Schleifenersatz
) -> None:
    with pytest.raises(AufloesungsFehler) as info:
        _aufloesen(monkeypatch, ersatz)
    fehler = info.value
    assert isinstance(fehler, R3cosintFehler)
    assert str(fehler) == "Die Namensauflösung ist fehlgeschlagen."
    assert "GEHEIM" not in repr(fehler) + str(fehler.args)
    assert fehler.__cause__ is None
    assert fehler.__context__ is None


def test_R3_F_028_standardaufloeser_laesst_abbruch_der_aufgabe_durch(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    with pytest.raises(asyncio.CancelledError):
        _aufloesen(monkeypatch, _Schleifenersatz(fehler=asyncio.CancelledError()))
