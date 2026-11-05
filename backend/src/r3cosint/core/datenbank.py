"""Asynchrone Datenbankverbindung (ADR 0007, Entscheid 1, 2 und 8; Festlegung S1.1, R3-F-008).

Die Engine entsteht allein aus der Konfiguration. Es gibt hier keine Tabellen, kein
MetaData und keine Schemaerzeugung aus Modellen (Entscheid 1: das Schema entsteht durch Revisionen). asyncpg
wird nicht importiert; SQLAlchemy lädt den Treiber über den Dialekt (Vertrag 10).
"""

from sqlalchemy.ext.asyncio import AsyncEngine, create_async_engine

from r3cosint.core.konfiguration import Datenbankverbindung, verbindungs_url


def engine_erzeugen(verbindung: Datenbankverbindung) -> AsyncEngine:
    """Erzeugt die Engine zur Datenbank aus der Konfiguration.

    Das Passwort gelangt allein über connect_args zum Treiber, nie in die URL. asyncpg
    fällt bei fehlenden Angaben auf PG*-Variablen und ~/.pgpass zurück; deshalb gehen
    Host, Port, Benutzer, Datenbank, Passwort und ssl immer ausdrücklich mit (Befund B-1
    der Lieferkettenprüfung S1.1). Parameter von Anweisungen bleiben aus Fehlertexten
    (hide_parameters), die Ausgabe von Anweisungen ist aus.
    """
    ueber_socket = verbindung.host.startswith("/")
    return create_async_engine(
        verbindungs_url(verbindung),
        connect_args={
            "password": verbindung.passwort_lesen().get_secret_value(),
            # Am Socket kein TLS; bei einem Rechnernamen "require" (kein Rückfall auf Klartext).
            # Ausdrücklich gesetzt, damit PGSSLMODE nicht wirkt; asyncpg verlangt von sich aus nichts.
            "ssl": False if ueber_socket else "require",
        },
        hide_parameters=True,
        echo=False,
    )
