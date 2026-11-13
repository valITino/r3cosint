"""Einheitstest: ausgang.positivliste (ADR 0008, Festlegung S2.1; R3-F-015, R3-F-028)."""

import hashlib
from pathlib import Path

import pytest
from pydantic import ValidationError

from r3cosint.ausgang.positivliste import Listeneintrag, Positivliste, laden
from r3cosint.ausgang.ziel import aus_url
from r3cosint.core.fehler import KonfigurationsFehler

WURZEL = Path(__file__).resolve().parents[3]
KOPF = (
    'format = 1\numgebung = "test"\n'
    "ausgang_weiterleitungen_hoechstzahl = 3\nstillgelegt = []\n"
)
NAME = '\n[[eintrag]]\nkennung = "test.name"\nschema = "https"\nrechnername = "gut.test"\nanschluss = 443\n'
LITERAL = '\n[[eintrag]]\nkennung = "test.literal"\nschema = "http"\nadresse = "127.0.0.1"\nanschluss = 8080\n'


def _datei(verzeichnis: Path, inhalt: str) -> Path:
    pfad = verzeichnis / "positivliste.toml"
    pfad.write_text(inhalt, encoding="utf-8")
    return pfad


def _laden(verzeichnis: Path, inhalt: str, umgebung: str = "test") -> Positivliste:
    return laden(_datei(verzeichnis, inhalt), umgebung=umgebung)  # type: ignore[arg-type]


def _eintrag(zeilen: str) -> str:
    return KOPF + "\n[[eintrag]]\n" + zeilen


def test_R3_F_015_gueltige_datei_und_listenstand_ist_sha256_der_bytes(
    tmp_path: Path,
) -> None:
    inhalt = "# Kommentar\n" + KOPF + NAME + LITERAL
    liste = _laden(tmp_path, inhalt)
    assert liste.listenstand == hashlib.sha256(inhalt.encode()).hexdigest()
    assert liste.umgebung == "test"
    assert liste.ausgang_weiterleitungen_hoechstzahl == 3
    assert [e.kennung for e in liste.eintraege] == ["test.name", "test.literal"]
    assert liste.eintraege[0].rechnername == "gut.test"
    assert liste.eintraege[1].adresse == "127.0.0.1"
    assert liste.eintraege[1].schema == "http"
    assert liste.eintraege[1].anschluss == 8080


def test_R3_F_015_kommentar_aendert_den_listenstand_nicht_aber_die_bytes_doch(
    tmp_path: Path,
) -> None:
    """M44: der Stand beschreibt die Bytes der Datei, nicht die normalisierten Werte."""
    a = _laden(tmp_path, KOPF + NAME)
    b = _laden(tmp_path, "# Kommentar\n" + KOPF + NAME)
    assert a.listenstand != b.listenstand
    assert a.eintraege == b.eintraege


def test_R3_F_015_leere_liste_ohne_eintrag_ist_gueltig(tmp_path: Path) -> None:
    liste = _laden(tmp_path, KOPF)
    assert liste.eintraege == ()
    assert liste.eintrag_fuer(aus_url("http://gut.test")) is None


@pytest.mark.parametrize("hoechstzahl", [0, 1, 10])
def test_R3_F_028_hoechstzahl_innerhalb_0_bis_10(
    tmp_path: Path, hoechstzahl: int
) -> None:
    inhalt = KOPF.replace("= 3", f"= {hoechstzahl}")
    assert _laden(tmp_path, inhalt).ausgang_weiterleitungen_hoechstzahl == hoechstzahl


FEHLER: list[tuple[str, str, str]] = [
    # (Name des Falls, Inhalt, erwartete Fehlerart im Text)
    ("unbekannter_schluessel", KOPF + "weiteres = 1\n", "Fehlerart unbekannt"),
    ("format_2", KOPF.replace("format = 1", "format = 2"), "Schlüssel format"),
    ("format_text", KOPF.replace("format = 1", 'format = "1"'), "Schlüssel format"),
    (
        "format_wahrheitswert",
        KOPF.replace("format = 1", "format = true"),
        "Schlüssel format",
    ),
    ("format_fehlt", KOPF.replace("format = 1\n", ""), "Fehlerart fehlt"),
    (
        "umgebung_produktion",
        KOPF.replace('"test"', '"produktion"'),
        "Schlüssel umgebung",
    ),
    ("hoechstzahl_minus_1", KOPF.replace("= 3", "= -1"), "Fehlerart bereich"),
    ("hoechstzahl_11", KOPF.replace("= 3", "= 11"), "Fehlerart bereich"),
    ("hoechstzahl_text", KOPF.replace("= 3", '= "3"'), "Fehlerart bereich"),
    ("hoechstzahl_wahrheitswert", KOPF.replace("= 3", "= true"), "Fehlerart bereich"),
    ("stillgelegt_kein_array", KOPF.replace("[]", '"x"'), "Schlüssel stillgelegt"),
    ("stillgelegt_zahl", KOPF.replace("[]", "[1]"), "Schlüssel stillgelegt"),
    ("stillgelegt_form", KOPF.replace("[]", '["GROSS"]'), "Schlüssel stillgelegt"),
    ("eintrag_kein_array", KOPF + 'eintrag = "x"\n', "Schlüssel eintrag"),
    ("eintrag_kein_tisch", KOPF + "eintrag = [1]\n", "Schlüssel eintrag"),
    (
        "eintrag_unbekannter_schluessel",
        _eintrag(
            'kennung = "a"\nschema = "http"\nadresse = "127.0.0.1"\nanschluss = 80\nx = 1\n'
        ),
        "Eintrag Nr. 1",
    ),
    (
        "kennung_fehlt",
        _eintrag('schema = "http"\nadresse = "127.0.0.1"\nanschluss = 80\n'),
        "Schlüssel kennung",
    ),
    (
        "kennung_form",
        _eintrag(
            'kennung = "Gross"\nschema = "http"\nadresse = "127.0.0.1"\nanschluss = 80\n'
        ),
        "Schlüssel kennung",
    ),
    (
        "kennung_zahl",
        _eintrag(
            'kennung = 1\nschema = "http"\nadresse = "127.0.0.1"\nanschluss = 80\n'
        ),
        "Schlüssel kennung",
    ),
    (
        "schema_ftp",
        _eintrag(
            'kennung = "a"\nschema = "ftp"\nadresse = "127.0.0.1"\nanschluss = 80\n'
        ),
        "Schlüssel schema",
    ),
    (
        "schema_fehlt",
        _eintrag('kennung = "a"\nadresse = "127.0.0.1"\nanschluss = 80\n'),
        "Schlüssel schema",
    ),
    (
        "anschluss_fehlt",
        _eintrag('kennung = "a"\nschema = "http"\nadresse = "127.0.0.1"\n'),
        "Schlüssel anschluss",
    ),
    (
        "anschluss_0",
        _eintrag(
            'kennung = "a"\nschema = "http"\nadresse = "127.0.0.1"\nanschluss = 0\n'
        ),
        "Schlüssel anschluss",
    ),
    (
        "anschluss_65536",
        _eintrag(
            'kennung = "a"\nschema = "http"\nadresse = "127.0.0.1"\nanschluss = 65536\n'
        ),
        "Schlüssel anschluss",
    ),
    (
        "anschluss_text",
        _eintrag(
            'kennung = "a"\nschema = "http"\nadresse = "127.0.0.1"\nanschluss = "80"\n'
        ),
        "Schlüssel anschluss",
    ),
    (
        "beides",
        _eintrag(
            'kennung = "a"\nschema = "http"\nrechnername = "gut.test"\nadresse = "127.0.0.1"\nanschluss = 80\n'
        ),
        "beides_oder_keines",
    ),
    (
        "keines",
        _eintrag('kennung = "a"\nschema = "http"\nanschluss = 80\n'),
        "beides_oder_keines",
    ),
    (
        "rechnername_gross",
        _eintrag(
            'kennung = "a"\nschema = "http"\nrechnername = "Gut.test"\nanschluss = 80\n'
        ),
        "Schlüssel rechnername, Eintrag Nr. 1 (Kennung a), Fehlerart form",
    ),
    (
        "rechnername_zahl",
        _eintrag('kennung = "a"\nschema = "http"\nrechnername = 5\nanschluss = 80\n'),
        "Fehlerart form",
    ),
    (
        "rechnername_nicht_normal_unicode",
        _eintrag(
            'kennung = "a"\nschema = "http"\nrechnername = "bücher.example"\nanschluss = 80\n'
        ),
        "Fehlerart form",
    ),
    (
        "rechnername_abschliessender_punkt",
        _eintrag(
            'kennung = "a"\nschema = "http"\nrechnername = "gut.test."\nanschluss = 80\n'
        ),
        "nicht_normalisiert",
    ),
    (
        "rechnername_ist_literal",
        _eintrag(
            'kennung = "a"\nschema = "http"\nrechnername = "127.0.0.1"\nanschluss = 80\n'
        ),
        "nicht_normalisiert",
    ),
    (
        "rechnername_mit_fragment",
        _eintrag(
            'kennung = "a"\nschema = "http"\nrechnername = "gut.test#"\nanschluss = 80\n'
        ),
        "Fehlerart form",
    ),
    (
        "rechnername_ungueltiges_etikett",
        _eintrag(
            'kennung = "a"\nschema = "http"\nrechnername = "-gut.test"\nanschluss = 80\n'
        ),
        "nicht_normalisiert",
    ),
    (
        "adresse_oktal",
        _eintrag(
            'kennung = "a"\nschema = "http"\nadresse = "0177.0.0.1"\nanschluss = 80\n'
        ),
        "nicht_normalisiert",
    ),
    (
        "adresse_kurz",
        _eintrag('kennung = "a"\nschema = "http"\nadresse = "127.1"\nanschluss = 80\n'),
        "nicht_normalisiert",
    ),
    (
        "adresse_ipv6_lang",
        _eintrag(
            'kennung = "a"\nschema = "http"\nadresse = "0:0:0:0:0:0:0:1"\nanschluss = 80\n'
        ),
        "nicht_normalisiert",
    ),
    (
        "adresse_ipv6_gross",
        _eintrag(
            'kennung = "a"\nschema = "http"\nadresse = "2001:DB8::1"\nanschluss = 80\n'
        ),
        "Fehlerart form",
    ),
    (
        "adresse_ipv6_abgebildet",
        _eintrag(
            'kennung = "a"\nschema = "http"\nadresse = "::ffff:7f00:1"\nanschluss = 80\n'
        ),
        "nicht_normalisiert",
    ),
    (
        "adresse_zone",
        _eintrag(
            'kennung = "a"\nschema = "http"\nadresse = "fe80::1%eth0"\nanschluss = 80\n'
        ),
        "Fehlerart form",
    ),
    (
        "adresse_zahl",
        _eintrag('kennung = "a"\nschema = "http"\nadresse = 5\nanschluss = 80\n'),
        "Fehlerart form",
    ),
    (
        "adresse_ist_name",
        _eintrag('kennung = "a"\nschema = "http"\nadresse = "a.b"\nanschluss = 80\n'),
        "nicht_normalisiert",
    ),
    (
        "kennung_stillgelegt",
        KOPF.replace("[]", '["a"]')
        + "\n[[eintrag]]\n"
        + 'kennung = "a"\nschema = "http"\nadresse = "127.0.0.1"\nanschluss = 80\n',
        "Fehlerart stillgelegt",
    ),
    (
        "kennung_doppelt",
        KOPF + LITERAL + LITERAL.replace("127.0.0.1", "127.0.0.2"),
        "Fehlerart doppelt",
    ),
    (
        "ziel_doppelt",
        KOPF + LITERAL + LITERAL.replace("test.literal", "test.anders"),
        "Fehlerart ziel_doppelt",
    ),
    ("kein_toml", "format = = 1\n", "Schlüssel datei, Fehlerart unlesbar"),
    ("kein_utf8", "￾", "Schlüssel datei, Fehlerart unlesbar"),
]


@pytest.mark.parametrize(
    ("inhalt", "erwartet"), [(f[1], f[2]) for f in FEHLER], ids=[f[0] for f in FEHLER]
)
def test_R3_F_015_jede_fehlerart_ergibt_einen_konfigurationsfehler(
    tmp_path: Path, inhalt: str, erwartet: str
) -> None:
    with pytest.raises(KonfigurationsFehler) as info:
        _laden(tmp_path, inhalt)
    text = str(info.value)
    assert erwartet in text
    assert info.value.__cause__ is None
    assert info.value.__context__ is None
    assert str(tmp_path) not in text + repr(info.value.args)


def test_R3_F_015_fehlertext_traegt_weder_wert_noch_pfad(tmp_path: Path) -> None:
    inhalt = _eintrag(
        'kennung = "a"\nschema = "http"\nrechnername = "GEHEIMER-Wert.test"\nanschluss = 80\n'
    )
    with pytest.raises(KonfigurationsFehler) as info:
        _laden(tmp_path, inhalt)
    text = str(info.value) + repr(info.value.args)
    assert "GEHEIM" not in text.upper()
    assert str(tmp_path) not in text


def test_R3_F_015_fehlende_datei_ergibt_fehler_ohne_pfad(tmp_path: Path) -> None:
    pfad = tmp_path / "gibt-es-nicht.toml"
    with pytest.raises(KonfigurationsFehler) as info:
        laden(pfad, umgebung="test")
    assert "gibt-es-nicht" not in str(info.value)
    assert info.value.__context__ is None


@pytest.mark.parametrize(
    ("datei", "umgebung", "andere"),
    [("test", "test", "produktion"), ("produktion", "produktion", "test")],
)
def test_R3_F_015_dateien_unter_deploy_laden_nur_mit_ihrer_umgebung(
    datei: str, umgebung: str, andere: str
) -> None:
    pfad = WURZEL / "deploy" / "konfiguration" / datei / "positivliste.toml"
    liste = laden(pfad, umgebung=umgebung)  # type: ignore[arg-type]
    assert liste.umgebung == umgebung
    assert liste.eintraege == ()
    assert liste.ausgang_weiterleitungen_hoechstzahl == 3
    assert liste.listenstand == hashlib.sha256(pfad.read_bytes()).hexdigest()
    with pytest.raises(KonfigurationsFehler, match="Schlüssel umgebung"):
        laden(pfad, umgebung=andere)  # type: ignore[arg-type]


def test_R3_F_015_die_beiden_dateien_haben_verschiedene_staende() -> None:
    test = laden(
        WURZEL / "deploy/konfiguration/test/positivliste.toml", umgebung="test"
    )
    produktion = laden(
        WURZEL / "deploy/konfiguration/produktion/positivliste.toml",
        umgebung="produktion",
    )
    assert test.listenstand != produktion.listenstand


def test_R3_F_028_eintrag_fuer_vergleicht_schema_art_wert_und_anschluss(
    tmp_path: Path,
) -> None:
    liste = _laden(tmp_path, KOPF + NAME + LITERAL)
    assert liste.eintrag_fuer(aus_url("https://gut.test")) is liste.eintraege[0]
    assert (
        liste.eintrag_fuer(aus_url("HTTPS://Gut.TEST.:443/pfad?x=1"))
        is liste.eintraege[0]
    )
    assert liste.eintrag_fuer(aus_url("http://0177.0.0.1:8080")) is liste.eintraege[1]
    assert (
        liste.eintrag_fuer(aus_url("http://[::ffff:7f00:1]:8080")) is liste.eintraege[1]
    )
    # anderer Anschluss, anderes Schema, anderer Rechner
    assert liste.eintrag_fuer(aus_url("https://gut.test:444")) is None
    assert liste.eintrag_fuer(aus_url("http://gut.test:443")) is None
    assert liste.eintrag_fuer(aus_url("https://andere.test")) is None
    assert liste.eintrag_fuer(aus_url("https://127.0.0.1:8080")) is None
    assert liste.eintrag_fuer(aus_url("http://127.0.0.1:8081")) is None


def test_R3_F_028_ein_name_deckt_keine_adresse_und_umgekehrt(tmp_path: Path) -> None:
    inhalt = KOPF + (
        '\n[[eintrag]]\nkennung = "a"\nschema = "http"\nrechnername = "127.0.0.1.test"\nanschluss = 80\n'
        '\n[[eintrag]]\nkennung = "b"\nschema = "http"\nadresse = "2001:db8::1"\nanschluss = 80\n'
    )
    liste = _laden(tmp_path, inhalt)
    assert liste.eintrag_fuer(aus_url("http://127.0.0.1")) is None
    assert liste.eintrag_fuer(aus_url("http://127.0.0.1.test")) is liste.eintraege[0]
    assert liste.eintrag_fuer(aus_url("http://[2001:db8::1]")) is liste.eintraege[1]
    assert liste.eintrag_fuer(aus_url("http://gut.test")) is None


def test_R3_F_015_listeneintrag_verlangt_genau_eines_von_rechnername_und_adresse() -> (
    None
):
    with pytest.raises(ValidationError):
        Listeneintrag(kennung="a", schema="http", anschluss=80)
    with pytest.raises(ValidationError):
        Listeneintrag(
            kennung="a",
            schema="http",
            anschluss=80,
            rechnername="a.test",
            adresse="127.0.0.1",
        )
    with pytest.raises(ValidationError):
        Listeneintrag(kennung="A", schema="http", anschluss=80, adresse="127.0.0.1")
    eintrag = Listeneintrag(
        kennung="a", schema="http", anschluss=80, adresse="127.0.0.1"
    )
    assert eintrag.schluessel() == ("http", "ipv4", "127.0.0.1", 80)
    assert Listeneintrag(
        kennung="a", schema="https", anschluss=1, adresse="::1"
    ).schluessel() == (
        "https",
        "ipv6",
        "::1",
        1,
    )


def test_R3_F_015_positivliste_ist_unveraenderlich_und_streng() -> None:
    liste = Positivliste(
        eintraege=(),
        ausgang_weiterleitungen_hoechstzahl=3,
        umgebung="test",
        listenstand="0" * 64,
    )
    with pytest.raises(ValidationError):
        liste.umgebung = "produktion"
    with pytest.raises(ValidationError):
        Positivliste(
            eintraege=(),
            ausgang_weiterleitungen_hoechstzahl=11,
            umgebung="test",
            listenstand="0" * 64,
        )
    with pytest.raises(ValidationError):
        Positivliste(
            eintraege=(),
            ausgang_weiterleitungen_hoechstzahl=3,
            umgebung="test",
            listenstand="zz",
        )
