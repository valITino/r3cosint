"""Beide Spuren, Kettenkopf, Funktionen, Auslöser und Rechte (ADR 0007, Nr. 10 bis 21, Festlegung S1.2; R3-F-008, R3-F-012).

Revision 0003. Läuft als r3cosint_eigentuemer. Die Spuren sind ausschliesslich anfügbar: diese
Revision hat keinen Rückweg (E-S1-04 b). Diese Datei importiert nichts aus r3cosint (Entscheid 4);
sie liest ihr SQL aus backend/migrationen/sql.
"""

from collections.abc import Sequence
from pathlib import Path

from alembic import op
from sqlalchemy.engine.interfaces import AdaptedConnection

revision: str = "0003"
down_revision: str | None = "0002"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None

SQL_VERZEICHNIS = Path(__file__).resolve().parents[1] / "sql"
SQL_DATEI = SQL_VERZEICHNIS / "0003_spur.sql"


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
    """Legt Spuren, Kettenkopf, Funktionen, Auslöser und Rechte an."""
    _sql_als_ganzes(SQL_DATEI.read_text(encoding="utf-8"))


def downgrade() -> None:
    """Es gibt keinen Rückweg: die Spuren sind ausschliesslich anfügbar."""
    raise RuntimeError(
        "Revision 0003 hat keinen Rückweg (ADR 0007, E-S1-04 b): die Spuren sind "
        "ausschliesslich anfügbar; in Test/Schulung eine neue Instanz aufsetzen"
    )
