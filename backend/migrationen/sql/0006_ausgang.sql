-- Revision 0006 (ADR 0008, Nr. 20 und Festlegung S2.1; R3-F-015, R3-F-028): Vorrat der Eintragstypen
-- der Arbeitsspur um verbindungsversuch, abweisung, abfrage und negativbefund. Läuft als
-- r3cosint_eigentuemer im Schema r3cosint. Name der Bedingung unverändert; die Ermittlungsspur und
-- die Rechte bleiben unverändert.
ALTER TABLE r3cosint.arbeitsspur
    DROP CONSTRAINT arbeitsspur_eintragstyp_vorrat,
    ADD CONSTRAINT arbeitsspur_eintragstyp_vorrat CHECK (eintragstyp IN (
        'fall_eroeffnet', 'fall_geschlossen', 'verbindungsversuch', 'abweisung', 'abfrage',
        'negativbefund'));
