"""Auslöser an fall: Zustandsübergänge (ADR 0007, Festlegung S1.3, E-S13-12 b; R3-F-001).

Revision 0004. Läuft als r3cosint_eigentuemer. Legt die Funktion fall_uebergang_pruefen und den
Auslöser fall_uebergang an; der Rückweg entfernt beide (E-S1-04 b; keine Spurtabelle ist
betroffen). Diese Datei importiert nichts aus r3cosint (Entscheid 4); sie liest ihr SQL aus
backend/migrationen/sql.
"""

from collections.abc import Sequence
from pathlib import Path

from alembic import op
from sqlalchemy.engine.interfaces import AdaptedConnection

revision: str = "0004"
down_revision: str | None = "0003"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None

SQL_VERZEICHNIS = Path(__file__).resolve().parents[1] / "sql"
SQL_DATEI = SQL_VERZEICHNIS / "0004_fall_uebergang.sql"
SQL_RUECKWEG = SQL_VERZEICHNIS / "0004_fall_uebergang_rueckweg.sql"


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
    """Legt die Auslöserfunktion und den Auslöser an fall an."""
    _sql_als_ganzes(SQL_DATEI.read_text(encoding="utf-8"))


def downgrade() -> None:
    """Entfernt Auslöser und Funktion."""
    _sql_als_ganzes(SQL_RUECKWEG.read_text(encoding="utf-8"))
