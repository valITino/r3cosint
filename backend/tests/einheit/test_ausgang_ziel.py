"""Einheitstest: ausgang.ziel (ADR 0008, Festlegung S2.1; R3-F-015, R3-F-028)."""

import ipaddress
import socket

import pytest

from r3cosint.ausgang.ziel import (
    URL_HOECHSTLAENGE,
    Ziel,
    ZielFehler,
    aus_url,
    ipv4_lesen,
    pfad_und_abfrage,
    zeichen_pruefen,
)
from r3cosint.core.fehler import EingabeFehler

PFLICHT_127 = [
    "127.0.0.1",
    "0177.0.0.1",
    "0177.0000.0000.0001",
    "0x7f.0.0.1",
    "0x7F.0x0.0x0.0x1",
    "0x7f.0.0.01",
    "0177.0x0.0.1",
    "127.1",
    "127.0.1",
    "0x7f.1",
    "0177.1",
    "2130706433",
    "0x7f000001",
    "017700000001",
    "127.000.000.001",
]


@pytest.mark.parametrize("schreibweise", PFLICHT_127)
def test_R3_F_028_pflicht_schreibweisen_ergeben_die_normalform(
    schreibweise: str,
) -> None:
    ziel = aus_url(f"http://{schreibweise}/pfad")
    assert (ziel.art, ziel.wert, ziel.anschluss) == ("ipv4", "127.0.0.1", 80)
    assert ziel.zielform() == "http://127.0.0.1:80"
    assert ziel.adresse() == ipaddress.IPv4Address("127.0.0.1")


@pytest.mark.parametrize("schreibweise", PFLICHT_127)
def test_R3_F_028_eigener_parser_stimmt_mit_inet_aton_ueberein(
    schreibweise: str,
) -> None:
    erwartet = ipaddress.IPv4Address(socket.inet_aton(schreibweise))
    assert ipv4_lesen(schreibweise) == erwartet


@pytest.mark.parametrize(
    "text",
    [
        "",
        "1.2.3.4.5",
        "127.0.0.256",
        "256.1",
        "1.256.1",
        "1.1.65536",
        "1.16777216",
        "4294967296",
        "08",
        "0x",
        "0xg",
        "1..2",
        "1.2.3.",
        "-1",
        "+1",
        "1 ",
    ],
)
def test_R3_F_028_eigener_parser_weist_ungueltige_literale_ab(text: str) -> None:
    assert ipv4_lesen(text) is None


@pytest.mark.parametrize(
    ("rechner", "erwartet"),
    [
        ("[::ffff:127.0.0.1]", "127.0.0.1"),
        ("[::ffff:7f00:1]", "127.0.0.1"),
        ("[0:0:0:0:0:ffff:7f00:1]", "127.0.0.1"),
        ("[::FFFF:7F00:1]", "127.0.0.1"),
        ("127。0。0。1", "127.0.0.1"),
        ("127.0.0.1.", "127.0.0.1"),
        ("\uff11\uff12\uff17.0.0.1", "127.0.0.1"),
        ("127。0.0.1", "127.0.0.1"),
    ],
)
def test_R3_F_028_ipv4_formen_ergeben_art_ipv4(rechner: str, erwartet: str) -> None:
    ziel = aus_url(f"http://{rechner}")
    assert (ziel.art, ziel.wert) == ("ipv4", erwartet)


@pytest.mark.parametrize(
    ("rechner", "erwartet"),
    [
        ("[::1]", "::1"),
        ("[0:0:0:0:0:0:0:1]", "::1"),
        ("[0000:0000:0000:0000:0000:0000:0000:0001]", "::1"),
        ("[2001:DB8::1]", "2001:db8::1"),
        ("[2001:0db8::0001]", "2001:db8::1"),
        ("[::127.0.0.1]", "::7f00:1"),
    ],
)
def test_R3_F_028_ipv6_formen_ergeben_verkuerzte_kleine_normalform(
    rechner: str, erwartet: str
) -> None:
    ziel = aus_url(f"https://{rechner}:8443/x")
    assert (ziel.art, ziel.wert, ziel.anschluss) == ("ipv6", erwartet, 8443)
    assert ziel.zielform() == f"https://[{erwartet}]:8443"
    assert ziel.adresse() == ipaddress.IPv6Address(erwartet)


@pytest.mark.parametrize(
    ("url", "erwartet"),
    [
        ("HTTP://Gut.TEST./a", "gut.test"),
        ("http://gut.test", "gut.test"),
        ("http://GUT.test", "gut.test"),
        ("http://bücher.example", "xn--bcher-kva.example"),
        ("http://xn--bcher-kva.example", "xn--bcher-kva.example"),
        ("http://BÜCHER.example.", "xn--bcher-kva.example"),
        ("http://gut。test", "gut.test"),
        ("http://\uff47\uff55\uff54.test", "gut.test"),
        ("http://a-b.test", "a-b.test"),
        ("http://localhost", "localhost"),
        ("http://127.0.0.1.test", "127.0.0.1.test"),
        ("http://0x.test", "0x.test"),
    ],
)
def test_R3_F_028_namen_ergeben_die_a_label_form(url: str, erwartet: str) -> None:
    ziel = aus_url(url)
    assert (ziel.art, ziel.wert) == ("name", erwartet)
    with pytest.raises(ValueError, match="Name"):
        ziel.adresse()


def test_R3_F_015_standardanschluss_und_anschlussangabe() -> None:
    assert aus_url("http://gut.test").anschluss == 80
    assert aus_url("https://gut.test").anschluss == 443
    assert aus_url("https://gut.test:8443").anschluss == 8443
    assert aus_url("http://gut.test:0080").anschluss == 80
    assert aus_url("http://gut.test:65535/").anschluss == 65535
    assert aus_url("HTTPS://gut.test").schema == "https"
    assert aus_url("https://gut.test:443").zielform() == "https://gut.test:443"


def test_R3_F_015_pfad_abfrage_und_fragment_gehen_nicht_in_das_ziel_ein() -> None:
    ziel = aus_url("http://gut.test/a/b?x=1#f")
    assert ziel == aus_url("http://gut.test")
    assert "/a/b" not in repr(ziel)
    assert "gut.test" not in repr(ziel)
    assert pfad_und_abfrage("http://gut.test/a/b?x=1#f") == "/a/b?x=1"
    assert pfad_und_abfrage("http://gut.test") == "/"
    assert pfad_und_abfrage("http://gut.test?q=2") == "/?q=2"
    assert pfad_und_abfrage("http://gut.test/p#f") == "/p"


ABGEWIESEN = [
    "http://[fe80::1%25eth0]/",
    "http://[::1%25lo]/",
    "http://[::1%lo]/",
    "http://[fe80::1%eth0]:80",
    "http://127.0.0.256",
    "http://1.2.3.4.5",
    "http://0x",
    "http://127.0.0.1\x00",
    "http://127.0.0.1\t",
    "http://127.0.0.1\n",
    "http://127.0.0.1 x.test",
    "http://8.8.8.8 127.0.0.1",
    "http://127.0.0.1\u00a0",
    "http://127.0.0.1\u200b",
    "http://127.0.0.1\u2028",
    "http://127.0.0.1\u2029",
    "http://127.0.0.1\ud800",
    "http://127.0.0.1\x1c",
    "http://user@gut.test",
    "http://user:pw@gut.test",
    "http://@gut.test",
    "http://gut.test\\@boes.test/",
    "http://gut.test\uff20boes.test",
    "http://gut.test:",
    "http://gut.test:0",
    "http://gut.test:65536",
    "http://gut.test:+80",
    "http://gut.test:\uff18\uff10",
    "http://gut.test:0x50",
    "http://gut.test:80:80",
    "http://[::1]x",
    "http://[::1]:",
    "http://[::1",
    "http://[v1.x]/",
    "http://[gut]/",
    "http://[]/",
    "ftp://gut.test",
    "gut.test",
    "http:gut.test",
    "http:///pfad",
    "http://",
    "http://:80",
    "file:///etc/passwd",
    "http://gut_test.test",
    "http://-gut.test",
    "http://gut-.test",
    "http://gut..test",
    "http://.test",
    "http://.",
    "http://gut.test..",
    "http://xn--zz.test",
    "http://gut.test:80/\x7f",
    "http://" + "a" * 64 + ".test",
    "http://" + ".".join(["a" * 60] * 5),
    "http://gut.test/" + "a" * URL_HOECHSTLAENGE,
    "",
    " ",
    "http://[2001:db8::1]%25x",
]


@pytest.mark.parametrize("url", ABGEWIESEN)
def test_R3_F_015_nicht_auswertbare_urls_ergeben_ziel_fehler(url: str) -> None:
    with pytest.raises(ZielFehler) as info:
        aus_url(url)
    fehler = info.value
    assert isinstance(fehler, EingabeFehler)
    assert str(fehler) == "Die URL ist nicht auswertbar."
    assert fehler.__cause__ is None
    assert fehler.__context__ is None
    assert fehler.args == ("Die URL ist nicht auswertbar.",)


ACHT_GEMESSENE = [
    "http://gut\uff20boes.test/",
    "http://gut.test%zz/",
    "http://127.0.0.256/",
    "http://xn--a.test/",
    "http://gut.test:\uff18\uff10/",
    "http://gut.test\\@boes.test/",
    "http://[GEHEIM%25x]/",
    "http://[::1%25GEHEIM]/",
]


@pytest.mark.parametrize("url", ACHT_GEMESSENE)
def test_R3_F_011_fehlertext_traegt_keinen_teil_der_eingabe(url: str) -> None:
    with pytest.raises(ZielFehler) as info:
        aus_url(url)
    text = str(info.value) + repr(info.value) + repr(info.value.args)
    for teil in ("gut", "boes", "127", "xn--", "GEHEIM", "8"):
        assert teil not in text
    assert info.value.__cause__ is None
    assert info.value.__context__ is None


@pytest.mark.parametrize("url", [None, 1, b"http://gut.test", ["http://gut.test"]])
def test_R3_F_015_kein_text_ist_ein_fehler(url: object) -> None:
    with pytest.raises(ZielFehler):
        zeichen_pruefen(url)


def test_R3_F_015_zeichen_pruefen_ist_eine_eigene_pruefung() -> None:
    """Fall zu M8: die Prüfung steht für sich und weist Leerraum und Steuerzeichen ab."""
    zeichen_pruefen("http://gut.test/")
    zeichen_pruefen("a" * URL_HOECHSTLAENGE)
    for schlecht in (
        "a b",
        "a\tb",
        "a\x00b",
        "a\u200bb",
        "a\u3000b",
        "",
        "a" * (URL_HOECHSTLAENGE + 1),
    ):
        with pytest.raises(ZielFehler):
            zeichen_pruefen(schlecht)


def test_R3_F_015_ziel_ist_ein_unveraenderliches_wertobjekt() -> None:
    ziel = aus_url("http://gut.test")
    assert isinstance(ziel, Ziel)
    assert ziel == Ziel(schema="http", art="name", wert="gut.test", anschluss=80)
    assert hash(ziel) == hash(
        Ziel(schema="http", art="name", wert="gut.test", anschluss=80)
    )
    with pytest.raises(AttributeError):
        ziel.anschluss = 81  # type: ignore[misc]
