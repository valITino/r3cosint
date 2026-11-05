"""Zeit in UTC (ADR 0007, Entscheid 28; Festlegung S1.1, R3-F-008).

Zeitpunkte sind zeitbewusst und in UTC; eine naive Zeit ist ein Fehler des Aufrufers,
weil ihre Zone unbekannt wäre. Die Uhr ist ein Protocol, damit Tests eine feste Uhr
einsetzen können.
"""

import calendar
from datetime import UTC, datetime
from typing import Protocol


class Uhr(Protocol):
    """Quelle der aktuellen Zeit."""

    def jetzt(self) -> datetime:
        """Liefert den aktuellen Zeitpunkt, zeitbewusst, in UTC."""
        ...


class Systemuhr:
    """Uhr des Rechners."""

    def jetzt(self) -> datetime:
        """Liefert den aktuellen Zeitpunkt in UTC."""
        return datetime.now(UTC)


def monate_addieren(zeitpunkt: datetime, monate: int) -> datetime:
    """Addiert Kalendermonate; der Tag wird am Monatsende begrenzt.

    Der 31. Januar plus 1 Monat ist der 28. Februar, im Schaltjahr der 29. Februar.
    Naive Zeit oder negative Monate: ValueError.
    """
    if zeitpunkt.tzinfo is None or zeitpunkt.utcoffset() is None:
        raise ValueError("zeitpunkt muss zeitbewusst sein (naive Zeit)")
    if monate < 0:
        raise ValueError("monate darf nicht negativ sein")
    gezaehlt = zeitpunkt.year * 12 + (zeitpunkt.month - 1) + monate
    jahr, monat0 = divmod(gezaehlt, 12)
    monat = monat0 + 1
    letzter_tag = calendar.monthrange(jahr, monat)[1]
    return zeitpunkt.replace(
        year=jahr, month=monat, day=min(zeitpunkt.day, letzter_tag)
    )
