"""Standardrechte: Funktionen sind für PUBLIC nicht ausführbar (ADR 0007, Entscheid 7 und 9).

Revision 0001, R3-F-008. Läuft als r3cosint_eigentuemer. Ohne diese Revision dürfte jede
Rolle jede später angelegte Funktion ausführen; Entscheid 9 gewährt das Ausführen der
Prüffunktion der Kette der Rolle r3cosint_anwendung ausdrücklich. Der Rückweg gewährt das
Standardrecht zurück (Entscheid 11, E-S1-04 b). Diese Datei importiert nichts aus
r3cosint (Entscheid 4); sie liest ihr SQL aus backend/migrationen/sql.
"""

from collections.abc import Sequence
from pathlib import Path

from alembic import op
from sqlalchemy.engine.interfaces import AdaptedConnection

revision: str = "0001"
down_revision: str | None = None
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None

SQL_VERZEICHNIS = Path(__file__).resolve().parents[1] / "sql"
SQL_DATEI = SQL_VERZEICHNIS / "0001_standardrechte.sql"
SQL_RUECKWEG = SQL_VERZEICHNIS / "0001_standardrechte_rueckweg.sql"


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
    """Entzieht PUBLIC das Standardrecht EXECUTE auf später angelegte Funktionen."""
    _sql_als_ganzes(SQL_DATEI.read_text(encoding="utf-8"))


def downgrade() -> None:
    """Gewährt PUBLIC das Standardrecht EXECUTE auf Funktionen zurück."""
    _sql_als_ganzes(SQL_RUECKWEG.read_text(encoding="utf-8"))
