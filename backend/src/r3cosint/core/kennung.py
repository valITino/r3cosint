"""Kennungen (ADR 0007, Entscheid 28; Festlegung S1.1 und S1.2, R3-F-008).

Eine Kennung ist eine UUID der Fassung 4: zufällig, ohne Bezug zu Zeit oder Rechner.
Die Benutzerkennung ist die Zurechnung einer Handlung an eine Person (E-S1-07).
"""

import re
from uuid import UUID, uuid4

from r3cosint.core.fehler import EingabeFehler

BENUTZERKENNUNG = re.compile(r"^[a-z0-9._-]{1,64}$")
"""Form der Benutzerkennung (ADR 0007, Nr. 25): Kleinbuchstaben, Ziffern, Punkt, Unterstrich, Bindestrich."""


def neue_kennung() -> UUID:
    """Erzeugt eine neue Kennung (UUID, Fassung 4)."""
    return uuid4()


def benutzerkennung_pruefen(wert: str) -> str:
    """Prüft die Form der Benutzerkennung und liefert sie unverändert zurück.

    Fehlerfall: EingabeFehler, wenn der Wert nicht auf BENUTZERKENNUNG passt; die Meldung
    nennt den Wert nicht.
    """
    if not BENUTZERKENNUNG.fullmatch(wert):
        raise EingabeFehler("Die Benutzerkennung hat nicht die vorgeschriebene Form.")
    return wert
