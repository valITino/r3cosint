"""Fall, Fallkategorie und Fallschlüssel (ADR 0007, Nr. 9 und 22, Festlegung S1.2; R3-F-001, R3-F-008).

Revision 0002. Läuft als r3cosint_eigentuemer. Legt die drei Tabellen mit Prüfbedingungen und
Rechten an und trägt danach die Startwerte der Fallkategorien ein (eigene SQL-Datei, Vorschlag
zur Bestätigung nach Projektauftrag 4.4). Der Rückweg entfernt die drei Tabellen (E-S1-04 b).
Diese Datei importiert nichts aus r3cosint (Entscheid 4); sie liest ihr SQL aus backend/migrationen/sql.
"""

from collections.abc import Sequence
from pathlib import Path

from alembic import op
from sqlalchemy.engine.interfaces import AdaptedConnection

revision: str = "0002"
down_revision: str | None = "0001"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None

SQL_VERZEICHNIS = Path(__file__).resolve().parents[1] / "sql"
SQL_DATEI = SQL_VERZEICHNIS / "0002_fall.sql"
SQL_STARTWERTE = SQL_VERZEICHNIS / "0002_fall_startwerte.sql"
SQL_RUECKWEG = SQL_VERZEICHNIS / "0002_fall_rueckweg.sql"


def _sql_als_ganzes(text: str) -> None:
    """Führt den Text als Ganzes im einfachen Abfrageprotokoll aus, in der Transaktion der Revision.

    Mehrere Anweisungen und Funktionsrümpfe sind so ohne Zerlegung möglich. Der Aufruf von
    SELECT 1 beginnt die Transaktion des Adapters (SQLAlchemy beginnt sie erst mit der ersten
    Anweisung über den Cursor, nicht mit einem Aufruf am Treiber); so läuft der Text innerhalb
    der Transaktion der Revision (Entscheid 1 und 4).
    """
    verbindung = op.get_bind()
    verbindung.exec_driver_sql("SELECT 1")
    adaptiert = verbindung.connection.dbapi_connection
    if not isinstance(adaptiert, AdaptedConnection):
        raise TypeError("Die Verbindung ist keine angepasste Verbindung von SQLAlchemy")
    adaptiert.run_async(lambda treiber: treiber.execute(text))


def upgrade() -> None:
    """Legt Fall, Fallkategorie und Fallschlüssel an und trägt die Startwerte ein."""
    _sql_als_ganzes(SQL_DATEI.read_text(encoding="utf-8"))
    _sql_als_ganzes(SQL_STARTWERTE.read_text(encoding="utf-8"))


def downgrade() -> None:
    """Entfernt die drei Tabellen."""
    _sql_als_ganzes(SQL_RUECKWEG.read_text(encoding="utf-8"))
