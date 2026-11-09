"""Table-Objekte von Herkunft, Knoten und Kanten des Bestands (ADR 0007, Nr. 24 und 25, Festlegung S1.4; R3-F-003, R3-F-005).

Nur Table-Objekte. Prüfbedingungen und Rechte stehen im SQL der Revision 0005
(backend/migrationen/sql/0005_bestand.sql); Fremdschlüssel innerhalb dieser MetaData sind
erklärt, die auf fall nicht (GS-17). target_metadata in backend/migrationen/env.py führt
diese MetaData.
"""

from sqlalchemy import (
    Column,
    DateTime,
    ForeignKeyConstraint,
    MetaData,
    Table,
    Text,
    UniqueConstraint,
    Uuid,
)
from sqlalchemy.dialects.postgresql import JSONB

metadata = MetaData(schema="r3cosint")

herkunft = Table(
    "herkunft",
    metadata,
    Column("kennung", Uuid, primary_key=True),
    Column("fall_kennung", Uuid, nullable=False),
    Column("werkzeug", Text, nullable=False),
    Column("abfrage", Text, nullable=False),
    Column("zeitpunkt", DateTime(timezone=True), nullable=False),
    Column("erhebende_person", Text, nullable=False),
    Column("kennzeichnung", Text, nullable=False),
    Column("erstellt_am", DateTime(timezone=True), nullable=False),
    UniqueConstraint("fall_kennung", "kennung", name="herkunft_fall_kennung_eindeutig"),
)

entitaet = Table(
    "entitaet",
    metadata,
    Column("kennung", Uuid, primary_key=True),
    Column("fall_kennung", Uuid, nullable=False),
    Column("ftm_kennung", Text, nullable=False),
    Column("schema", Text, nullable=False),
    Column("eigenschaften", JSONB, nullable=False),
    Column("herkunft_kennung", Uuid, nullable=False),
    Column("erstellt_am", DateTime(timezone=True), nullable=False),
    UniqueConstraint(
        "fall_kennung", "ftm_kennung", name="entitaet_ftm_kennung_eindeutig"
    ),
    UniqueConstraint("herkunft_kennung", name="entitaet_herkunft_kennung_eindeutig"),
    UniqueConstraint("fall_kennung", "kennung", name="entitaet_fall_kennung_eindeutig"),
    ForeignKeyConstraint(
        ["fall_kennung", "herkunft_kennung"],
        ["r3cosint.herkunft.fall_kennung", "r3cosint.herkunft.kennung"],
        name="entitaet_herkunft_fk",
    ),
)

beziehung = Table(
    "beziehung",
    metadata,
    Column("kennung", Uuid, primary_key=True),
    Column("fall_kennung", Uuid, nullable=False),
    Column("ftm_kennung", Text, nullable=False),
    Column("schema", Text, nullable=False),
    Column("eigenschaften", JSONB, nullable=False),
    Column("herkunft_kennung", Uuid, nullable=False),
    Column("quelle_kennung", Uuid, nullable=False),
    Column("ziel_kennung", Uuid, nullable=False),
    Column("erstellt_am", DateTime(timezone=True), nullable=False),
    UniqueConstraint(
        "fall_kennung", "ftm_kennung", name="beziehung_ftm_kennung_eindeutig"
    ),
    UniqueConstraint("herkunft_kennung", name="beziehung_herkunft_kennung_eindeutig"),
    UniqueConstraint(
        "fall_kennung", "kennung", name="beziehung_fall_kennung_eindeutig"
    ),
    ForeignKeyConstraint(
        ["fall_kennung", "herkunft_kennung"],
        ["r3cosint.herkunft.fall_kennung", "r3cosint.herkunft.kennung"],
        name="beziehung_herkunft_fk",
    ),
    ForeignKeyConstraint(
        ["fall_kennung", "quelle_kennung"],
        ["r3cosint.entitaet.fall_kennung", "r3cosint.entitaet.kennung"],
        name="beziehung_quelle_fk",
    ),
    ForeignKeyConstraint(
        ["fall_kennung", "ziel_kennung"],
        ["r3cosint.entitaet.fall_kennung", "r3cosint.entitaet.kennung"],
        name="beziehung_ziel_fk",
    ),
)
