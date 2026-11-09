-- Revision 0005 (ADR 0007, Nr. 24 und 25 und Festlegung S1.4; R3-F-003, R3-F-005): Herkunft,
-- Knoten und Kanten des kanonischen Bestands. Läuft als r3cosint_eigentuemer im Schema r3cosint.
-- Zusammengesetzte Fremdschlüssel binden Herkunft, Kante und Enden an denselben Fall (ohne
-- Auslöser). Alle Bedingungen sind ausdrücklich benannt. Fremdschlüssel ohne ON DELETE und
-- ON UPDATE (NO ACTION). Die Anwendungsrolle erhält allein INSERT und SELECT; keine Funktion,
-- kein Auslöser. Die Formen entsprechen kanon.eingabe (Muster, Längen) und spur.kette.zeitpunkt_text.

CREATE TABLE r3cosint.herkunft (
    kennung uuid PRIMARY KEY,
    fall_kennung uuid NOT NULL,
    werkzeug text NOT NULL,
    abfrage text NOT NULL,
    zeitpunkt timestamptz NOT NULL,
    erhebende_person text NOT NULL,
    kennzeichnung text NOT NULL,
    erstellt_am timestamptz NOT NULL,
    CONSTRAINT herkunft_fall_fk FOREIGN KEY (fall_kennung) REFERENCES r3cosint.fall (kennung),
    CONSTRAINT herkunft_fall_kennung_eindeutig UNIQUE (fall_kennung, kennung),
    CONSTRAINT herkunft_werkzeug_form CHECK (werkzeug ~ '^[a-z0-9._-]{1,64}$'),
    CONSTRAINT herkunft_abfrage_form CHECK (abfrage ~ '\S' AND char_length(abfrage) <= 4096),
    CONSTRAINT herkunft_erhebende_person_form CHECK (erhebende_person ~ '^[a-z0-9._-]{1,64}$'),
    CONSTRAINT herkunft_kennzeichnung_vorrat CHECK (kennzeichnung IN ('quellenaussage', 'schlussfolgerung')),
    CONSTRAINT herkunft_zeitpunkt_zeitbereich CHECK (
        isfinite(zeitpunkt)
        AND zeitpunkt >= '2000-01-01 00:00:00+00'
        AND zeitpunkt < '9999-01-01 00:00:00+00'),
    CONSTRAINT herkunft_erstellt_am_zeitbereich CHECK (
        isfinite(erstellt_am)
        AND erstellt_am >= '2000-01-01 00:00:00+00'
        AND erstellt_am < '9999-01-01 00:00:00+00'),
    CONSTRAINT herkunft_zeitpunkt_vor_erstellt_am CHECK (zeitpunkt <= erstellt_am)
);

CREATE TABLE r3cosint.entitaet (
    kennung uuid PRIMARY KEY,
    fall_kennung uuid NOT NULL,
    ftm_kennung text NOT NULL,
    schema text NOT NULL,
    eigenschaften jsonb NOT NULL,
    herkunft_kennung uuid NOT NULL,
    erstellt_am timestamptz NOT NULL,
    CONSTRAINT entitaet_fall_fk FOREIGN KEY (fall_kennung) REFERENCES r3cosint.fall (kennung),
    CONSTRAINT entitaet_ftm_kennung_eindeutig UNIQUE (fall_kennung, ftm_kennung),
    CONSTRAINT entitaet_herkunft_kennung_eindeutig UNIQUE (herkunft_kennung),
    CONSTRAINT entitaet_fall_kennung_eindeutig UNIQUE (fall_kennung, kennung),
    CONSTRAINT entitaet_herkunft_fk FOREIGN KEY (fall_kennung, herkunft_kennung)
        REFERENCES r3cosint.herkunft (fall_kennung, kennung),
    CONSTRAINT entitaet_ftm_kennung_form CHECK (ftm_kennung ~ '^[A-Za-z0-9][A-Za-z0-9._:-]{0,127}$'),
    CONSTRAINT entitaet_schema_form CHECK (schema ~ '^[A-Z][A-Za-z]{0,63}$'),
    CONSTRAINT entitaet_eigenschaften_objekt CHECK (jsonb_typeof(eigenschaften) = 'object'),
    CONSTRAINT entitaet_eigenschaften_groesse CHECK (octet_length(eigenschaften::text) <= 1048576),
    CONSTRAINT entitaet_erstellt_am_zeitbereich CHECK (
        isfinite(erstellt_am)
        AND erstellt_am >= '2000-01-01 00:00:00+00'
        AND erstellt_am < '9999-01-01 00:00:00+00')
);

CREATE TABLE r3cosint.beziehung (
    kennung uuid PRIMARY KEY,
    fall_kennung uuid NOT NULL,
    ftm_kennung text NOT NULL,
    schema text NOT NULL,
    eigenschaften jsonb NOT NULL,
    herkunft_kennung uuid NOT NULL,
    quelle_kennung uuid NOT NULL,
    ziel_kennung uuid NOT NULL,
    erstellt_am timestamptz NOT NULL,
    CONSTRAINT beziehung_fall_fk FOREIGN KEY (fall_kennung) REFERENCES r3cosint.fall (kennung),
    CONSTRAINT beziehung_ftm_kennung_eindeutig UNIQUE (fall_kennung, ftm_kennung),
    CONSTRAINT beziehung_herkunft_kennung_eindeutig UNIQUE (herkunft_kennung),
    CONSTRAINT beziehung_fall_kennung_eindeutig UNIQUE (fall_kennung, kennung),
    CONSTRAINT beziehung_herkunft_fk FOREIGN KEY (fall_kennung, herkunft_kennung)
        REFERENCES r3cosint.herkunft (fall_kennung, kennung),
    CONSTRAINT beziehung_quelle_fk FOREIGN KEY (fall_kennung, quelle_kennung)
        REFERENCES r3cosint.entitaet (fall_kennung, kennung),
    CONSTRAINT beziehung_ziel_fk FOREIGN KEY (fall_kennung, ziel_kennung)
        REFERENCES r3cosint.entitaet (fall_kennung, kennung),
    CONSTRAINT beziehung_ftm_kennung_form CHECK (ftm_kennung ~ '^[A-Za-z0-9][A-Za-z0-9._:-]{0,127}$'),
    CONSTRAINT beziehung_schema_form CHECK (schema ~ '^[A-Z][A-Za-z]{0,63}$'),
    CONSTRAINT beziehung_eigenschaften_objekt CHECK (jsonb_typeof(eigenschaften) = 'object'),
    CONSTRAINT beziehung_eigenschaften_groesse CHECK (octet_length(eigenschaften::text) <= 1048576),
    CONSTRAINT beziehung_erstellt_am_zeitbereich CHECK (
        isfinite(erstellt_am)
        AND erstellt_am >= '2000-01-01 00:00:00+00'
        AND erstellt_am < '9999-01-01 00:00:00+00')
);

GRANT SELECT, INSERT ON r3cosint.herkunft TO r3cosint_anwendung;
GRANT SELECT, INSERT ON r3cosint.entitaet TO r3cosint_anwendung;
GRANT SELECT, INSERT ON r3cosint.beziehung TO r3cosint_anwendung;
