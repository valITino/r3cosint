"""Einheitstest: core.kennung und core.fehler (ADR 0007, Entscheid 28; Festlegung S1.1, R3-F-008)."""

from uuid import UUID

from r3cosint.core.fehler import KonfigurationsFehler, R3cosintFehler
from r3cosint.core.kennung import neue_kennung


def test_R3_F_008_neue_kennung_ist_eine_uuid_der_fassung_4() -> None:
    kennung = neue_kennung()
    assert isinstance(kennung, UUID)
    assert kennung.version == 4


def test_R3_F_008_neue_kennungen_sind_verschieden() -> None:
    assert len({neue_kennung() for _ in range(1000)}) == 1000


def test_R3_F_008_konfigurationsfehler_ist_ein_fehler_des_projekts() -> None:
    assert issubclass(KonfigurationsFehler, R3cosintFehler)
    assert issubclass(R3cosintFehler, Exception)


def test_R3_F_008_konfigurationsfehler_nennt_sache_und_naechsten_schritt() -> None:
    fehler = KonfigurationsFehler("Die Variable X fehlt.", "X setzen.")
    assert fehler.sache == "Die Variable X fehlt."
    assert fehler.naechster_schritt == "X setzen."
    meldung = str(fehler)
    assert "Die Variable X fehlt." in meldung
    assert "X setzen." in meldung
