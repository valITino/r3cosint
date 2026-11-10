"""Vorrat der Eintragstypen der Arbeitsspur um die Typen des Ausgangs (ADR 0008, Nr. 20, Festlegung S2.1; R3-F-015, R3-F-028).

Revision 0006. Läuft als r3cosint_eigentuemer. Ersetzt die Bedingung arbeitsspur_eintragstyp_vorrat
(gleicher Name) durch eine mit sechs Werten. Der Rückweg bricht mit Fehler ab, wenn eine Zeile der
Arbeitsspur einen der vier neuen Typen trägt (kein DELETE, ausschliesslich anfügbar), und stellt sonst
den Stand von 0003 her. Diese Datei importiert nichts aus r3cosint (Entscheid 4); sie liest ihr SQL aus
backend/migrationen/sql.
"""

from collections.abc import Sequence
from pathlib import Path

from alembic import op
from sqlalchemy.engine.interfaces import AdaptedConnection

revision: str = "0006"
down_revision: str | None = "0005"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None

SQL_VERZEICHNIS = Path(__file__).resolve().parents[1] / "sql"
SQL_DATEI = SQL_VERZEICHNIS / "0006_ausgang.sql"
SQL_RUECKWEG = SQL_VERZEICHNIS / "0006_ausgang_rueckweg.sql"


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
    """Erweitert den Vorrat der Eintragstypen der Arbeitsspur."""
    _sql_als_ganzes(SQL_DATEI.read_text(encoding="utf-8"))


def downgrade() -> None:
    """Stellt den Vorrat von Revision 0003 her, sofern keine Zeile der neuen Typen besteht."""
    _sql_als_ganzes(SQL_RUECKWEG.read_text(encoding="utf-8"))
