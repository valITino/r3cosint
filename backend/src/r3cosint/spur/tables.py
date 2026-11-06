"""Table-Objekte der Spuren (ADR 0007, Nr. 13, 21 und Festlegung S1.2; R3-F-008).

Nur Spalten, Typen, Nullbarkeit, Primärschlüssel und UNIQUE. Prüfbedingungen, Auslöser und
Funktionen stehen allein im SQL der Revision 0003; Fremdschlüssel auf fall stehen über die
Paketgrenze ebenfalls allein im SQL (GS-17). Keine Schemaerzeugung aus den Modellen (Nr. 1).
"""

from sqlalchemy import (
    CHAR,
    Column,
    DateTime,
    Integer,
    MetaData,
    PrimaryKeyConstraint,
    Table,
    Text,
    UniqueConstraint,
    Uuid,
)

metadata = MetaData(schema="r3cosint")


def _spurtabelle(name: str) -> Table:
    """Erzeugt eine Spurtabelle; beide Spuren haben dieselbe Form (Nr. 12)."""
    return Table(
        name,
        metadata,
        Column("kennung", Uuid, primary_key=True),
        Column("fall_kennung", Uuid, nullable=False),
        Column("position", Integer, nullable=False),
        Column("zeitpunkt", DateTime(timezone=True), nullable=False),
        Column("person_kennung", Text, nullable=False),
        Column("eintragstyp", Text, nullable=False),
        Column("kennzeichnung", Text, nullable=False),
        Column("payload", Text, nullable=False),
        Column("vorgaenger_pruefsumme", CHAR(64), nullable=False),
        Column("pruefsumme", CHAR(64), nullable=False, unique=True),
        UniqueConstraint("fall_kennung", "position"),
    )


ermittlungsspur = _spurtabelle("ermittlungsspur")
arbeitsspur = _spurtabelle("arbeitsspur")

kettenkopf = Table(
    "kettenkopf",
    metadata,
    Column("fall_kennung", Uuid, nullable=False),
    Column("spur", Text, nullable=False),
    Column("position", Integer, nullable=False),
    Column("pruefsumme", CHAR(64), nullable=False),
    PrimaryKeyConstraint("fall_kennung", "spur"),
)
