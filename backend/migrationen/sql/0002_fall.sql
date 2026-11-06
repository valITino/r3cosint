-- Revision 0002 (ADR 0007, Nr. 9, 22 und Festlegung S1.2; R3-F-001, R3-F-008): Fall, Fallkategorie
-- und Fallschlüssel. Läuft als r3cosint_eigentuemer im Schema r3cosint.

CREATE TABLE r3cosint.fallkategorie (
    kennung text PRIMARY KEY,
    bezeichnung text NOT NULL,
    erste_pruefung_monate integer NOT NULL,
    folgepruefung_monate integer,
    CONSTRAINT fallkategorie_kennung_form CHECK (kennung ~ '^[a-z0-9_]{1,64}$'),
    CONSTRAINT fallkategorie_bezeichnung_nicht_leer CHECK (btrim(bezeichnung) <> ''),
    CONSTRAINT fallkategorie_erste_pruefung_positiv CHECK (erste_pruefung_monate > 0),
    CONSTRAINT fallkategorie_folgepruefung_positiv
        CHECK (folgepruefung_monate IS NULL OR folgepruefung_monate > 0)
);
COMMENT ON TABLE r3cosint.fallkategorie IS
    'Aufbewahrungsklasse (Synonym Fallkategorie). Die Startwerte nach Projektauftrag 4.4 sind ein Vorschlag zur Bestätigung (Projektauftrag 4.4).';

CREATE TABLE r3cosint.fall (
    kennung uuid PRIMARY KEY,
    aktenzeichen text,
    ermittelnde_person text,
    rechtsgrundlage text,
    rechtsregime text NOT NULL,
    fallkategorie text NOT NULL REFERENCES r3cosint.fallkategorie (kennung),
    zustand text NOT NULL,
    eroeffnet_am timestamptz NOT NULL,
    geschlossen_am timestamptz,
    prueffrist_bis timestamptz,
    CONSTRAINT fall_rechtsregime_vorrat CHECK (rechtsregime IN ('R1', 'R2')),
    CONSTRAINT fall_zustand_vorrat CHECK (zustand IN (
        'aktiv', 'abgeschlossen', 'pruefung_faellig', 'verlaengert',
        'zur_loeschung_freigegeben', 'geloescht', 'archiviert')),
    CONSTRAINT fall_falldaten_gesetzt CHECK (
        zustand = 'geloescht'
        OR (coalesce(btrim(aktenzeichen) <> '', false)
            AND coalesce(btrim(ermittelnde_person) <> '', false)
            AND coalesce(btrim(rechtsgrundlage) <> '', false))),
    CONSTRAINT fall_geschlossen_am_genau_wenn_nicht_aktiv
        CHECK ((zustand <> 'aktiv') = (geschlossen_am IS NOT NULL)),
    CONSTRAINT fall_prueffrist_bis_genau_wenn_nicht_aktiv
        CHECK ((zustand <> 'aktiv') = (prueffrist_bis IS NOT NULL)),
    CONSTRAINT fall_geschlossen_nach_eroeffnung CHECK (geschlossen_am >= eroeffnet_am),
    CONSTRAINT fall_prueffrist_nach_schliessung CHECK (prueffrist_bis >= geschlossen_am)
);
CREATE UNIQUE INDEX fall_aktenzeichen_eindeutig
    ON r3cosint.fall (aktenzeichen) WHERE zustand <> 'geloescht';

CREATE TABLE r3cosint.fall_schluessel (
    fall_kennung uuid PRIMARY KEY REFERENCES r3cosint.fall (kennung),
    schluessel bytea NOT NULL,
    CONSTRAINT fall_schluessel_laenge CHECK (octet_length(schluessel) = 32)
);

-- Rechte der Rolle r3cosint_anwendung (ADR 0007, Nr. 9; E-S12-07): kleinstes Recht, nie DELETE.
GRANT SELECT ON r3cosint.fallkategorie TO r3cosint_anwendung;
GRANT SELECT, INSERT ON r3cosint.fall TO r3cosint_anwendung;
GRANT UPDATE (zustand, geschlossen_am, prueffrist_bis) ON r3cosint.fall TO r3cosint_anwendung;
GRANT SELECT, INSERT ON r3cosint.fall_schluessel TO r3cosint_anwendung;
