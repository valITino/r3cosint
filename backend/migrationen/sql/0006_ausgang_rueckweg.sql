-- Rückweg von Revision 0006 (ADR 0008, Nr. 20): stellt den Vorrat von Revision 0003 her. Trägt eine
-- Zeile der Arbeitsspur einen der vier neuen Typen, bricht er ab (kein DELETE: die Spur ist
-- ausschliesslich anfügbar); der Fehlertext nennt keinen Wert einer Zeile. Die Bedingung entsteht
-- ohne NOT VALID und prüft damit den Bestand selbst.
DO $rueckweg$
BEGIN
    IF EXISTS (
        SELECT 1 FROM r3cosint.arbeitsspur
        WHERE eintragstyp IN ('verbindungsversuch', 'abweisung', 'abfrage', 'negativbefund')
    ) THEN
        RAISE EXCEPTION 'Rueckweg von Revision 0006 abgebrochen: Zeilen der Arbeitsspur tragen Typen dieser Revision'
            USING ERRCODE = 'check_violation';
    END IF;
END
$rueckweg$;
ALTER TABLE r3cosint.arbeitsspur
    DROP CONSTRAINT arbeitsspur_eintragstyp_vorrat,
    ADD CONSTRAINT arbeitsspur_eintragstyp_vorrat CHECK (eintragstyp IN ('fall_eroeffnet', 'fall_geschlossen'));
