"""Kennungen (ADR 0007, Entscheid 28; Festlegung S1.1, R3-F-008).

Eine Kennung ist eine UUID der Fassung 4: zufällig, ohne Bezug zu Zeit oder Rechner.
"""

from uuid import UUID, uuid4


def neue_kennung() -> UUID:
    """Erzeugt eine neue Kennung (UUID, Fassung 4)."""
    return uuid4()
