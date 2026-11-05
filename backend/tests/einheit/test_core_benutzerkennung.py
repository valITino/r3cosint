"""Einheitstest: core.kennung.benutzerkennung_pruefen und core.fehler.EingabeFehler (ADR 0007, Nr. 25; R3-F-008)."""

import pytest

from r3cosint.core.fehler import EingabeFehler, R3cosintFehler
from r3cosint.core.kennung import BENUTZERKENNUNG, benutzerkennung_pruefen


@pytest.mark.parametrize("wert", ["a", "test.ermittlung", "a-b_c.9", "x" * 64])
def test_R3_F_008_gueltige_benutzerkennungen_gehen_unveraendert_durch(
    wert: str,
) -> None:
    assert benutzerkennung_pruefen(wert) == wert
    assert BENUTZERKENNUNG.fullmatch(wert)


@pytest.mark.parametrize(
    "wert", ["", "A", "x" * 65, "a b", "ä", "a\n", "a/b", "../x", "a;b"]
)
def test_R3_F_008_ungueltige_benutzerkennungen_werden_ohne_den_wert_abgewiesen(
    wert: str,
) -> None:
    with pytest.raises(EingabeFehler) as fehler:
        benutzerkennung_pruefen(wert)
    assert wert == "" or wert not in str(fehler.value)


def test_R3_F_008_eingabefehler_nennt_die_sache() -> None:
    fehler = EingabeFehler("Die Eingabe ist ungültig.")
    assert isinstance(fehler, R3cosintFehler)
    assert fehler.sache == "Die Eingabe ist ungültig."
    assert str(fehler) == "Die Eingabe ist ungültig."
