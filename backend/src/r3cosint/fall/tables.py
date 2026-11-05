"""Table-Objekte von Fall, Fallkategorie und Fallschlüssel (ADR 0007, Nr. 22 und Festlegung S1.2; R3-F-001).

Nur Table-Objekte, keine Dienstschicht (die kommt mit S1.3). Prüfbedingungen und Rechte
stehen im SQL der Revision 0002. Fremdschlüssel innerhalb dieser MetaData sind erklärt.
"""

from sqlalchemy import (
    Column,
    DateTime,
    ForeignKey,
    Index,
    Integer,
    LargeBinary,
    MetaData,
    Table,
    Text,
    Uuid,
    text,
)

metadata = MetaData(schema="r3cosint")

fallkategorie = Table(
    "fallkategorie",
    metadata,
    Column("kennung", Text, primary_key=True),
    Column("bezeichnung", Text, nullable=False),
    Column("erste_pruefung_monate", Integer, nullable=False),
    Column("folgepruefung_monate", Integer, nullable=True),
    comment=(
        "Aufbewahrungsklasse (Synonym Fallkategorie). Die Startwerte nach Projektauftrag 4.4 "
        "sind ein Vorschlag zur Bestätigung (Projektauftrag 4.4)."
    ),
)

fall = Table(
    "fall",
    metadata,
    Column("kennung", Uuid, primary_key=True),
    Column("aktenzeichen", Text, nullable=True),
    Column("ermittelnde_person", Text, nullable=True),
    Column("rechtsgrundlage", Text, nullable=True),
    Column("rechtsregime", Text, nullable=False),
    Column(
        "fallkategorie",
        Text,
        ForeignKey("r3cosint.fallkategorie.kennung"),
        nullable=False,
    ),
    Column("zustand", Text, nullable=False),
    Column("eroeffnet_am", DateTime(timezone=True), nullable=False),
    Column("geschlossen_am", DateTime(timezone=True), nullable=True),
    Column("prueffrist_bis", DateTime(timezone=True), nullable=True),
    Index(
        "fall_aktenzeichen_eindeutig",
        "aktenzeichen",
        unique=True,
        postgresql_where=text("zustand <> 'geloescht'"),
    ),
)

fall_schluessel = Table(
    "fall_schluessel",
    metadata,
    Column("fall_kennung", Uuid, ForeignKey("r3cosint.fall.kennung"), primary_key=True),
    Column("schluessel", LargeBinary, nullable=False),
)
