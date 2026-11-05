"""Umgebung von Alembic (ADR 0007, Entscheid 4 und 7; Festlegung S1.1, R3-F-008).

Asynchron und ohne alembic.ini: die Konfiguration entsteht im Code des Aufrufers. Die
Verbindung kommt aus config.attributes["verbindung"] (eine synchrone Sicht auf eine
AsyncConnection, so wie die Teststufe sie übergibt); fehlt sie, entsteht eine Engine aus
den Variablen der Konfiguration, als r3cosint_eigentuemer. Die Versionstabelle liegt im
Schema r3cosint; andere Schemas sehen Vergleich und Erzeugung nicht. Eine Ausgabe als
SQL-Text (offline) gibt es nicht: Revisionen führen SQL-Dateien aus, die ein Text nicht
abbildet.
"""

import asyncio

from alembic import context
from sqlalchemy import MetaData
from sqlalchemy.engine import Connection

from r3cosint.core.datenbank import engine_erzeugen
from r3cosint.core.fehler import KonfigurationsFehler
from r3cosint.core.konfiguration import aus_umgebung

SCHEMA = "r3cosint"

# Die MetaData-Objekte aus spur.tables, fall.tables und kanon.tables kommen mit S1.2 bis
# S1.4; in S1.1 gibt es keine Tabelle.
target_metadata: list[MetaData] = []


def include_name(name: str | None, type_: str, parent_names: object) -> bool:
    """Lässt allein das Schema r3cosint in den Vergleich; Objekte darin gehören dazu."""
    if type_ == "schema":
        return name == SCHEMA
    return True


def _revisionen_ausfuehren(verbindung: Connection) -> None:
    context.configure(
        connection=verbindung,
        target_metadata=target_metadata,
        version_table_schema=SCHEMA,
        include_schemas=True,
        include_name=include_name,
        compare_type=True,
    )
    with context.begin_transaction():
        context.run_migrations()


async def _mit_eigener_engine() -> None:
    engine = engine_erzeugen(aus_umgebung())
    try:
        async with engine.connect() as verbindung:
            await verbindung.run_sync(_revisionen_ausfuehren)
            await verbindung.commit()
    finally:
        await engine.dispose()


def _online() -> None:
    uebergeben = context.config.attributes.get("verbindung")
    if uebergeben is not None:
        _revisionen_ausfuehren(uebergeben)
    else:
        asyncio.run(_mit_eigener_engine())


if context.is_offline_mode():
    raise KonfigurationsFehler(
        "Alembic läuft nicht im Offline-Modus (Ausgabe als SQL-Text).",
        "Die Revisionen gegen eine Datenbank ausführen, ohne die Option --sql.",
    )
_online()
