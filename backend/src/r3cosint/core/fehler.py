"""Fehlerklassen des Projekts (ADR 0007, Entscheid 6 und 28; Festlegung S1.1, R3-F-008).

Jede Meldung an die Bedienung nennt die fehlende Sache und den nächsten Schritt; ein
Stacktrace ersetzt das nicht. Werte von Geheimnissen stehen nie in einer Meldung.
"""


class R3cosintFehler(Exception):
    """Basisklasse aller Fehler, die das Projekt selbst auslöst."""


class KonfigurationsFehler(R3cosintFehler):
    """Eine Einstellung fehlt oder ist ungültig.

    sache: was fehlt oder ungültig ist (Name der Einstellung, nie ihr Wert).
    naechster_schritt: was die Bedienung als Nächstes tut.
    """

    def __init__(self, sache: str, naechster_schritt: str) -> None:
        super().__init__(sache, naechster_schritt)
        self.sache = sache
        self.naechster_schritt = naechster_schritt

    def __str__(self) -> str:
        return f"{self.sache} Nächster Schritt: {self.naechster_schritt}"


class EingabeFehler(R3cosintFehler):
    """Eine Eingabe ist ungültig und wird vor jedem Schreiben abgewiesen (ADR 0007, Nr. 24 und 27).

    sache: was ungültig ist, ohne den Wert der Eingabe (Werte können Personendaten tragen).
    """

    def __init__(self, sache: str) -> None:
        super().__init__(sache)
        self.sache = sache

    def __str__(self) -> str:
        return self.sache
