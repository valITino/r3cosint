-- Revision 0004 (ADR 0007, Festlegung S1.3, E-S13-12 b; R3-F-001): bindet den Zustand von fall.
-- Die Rechte der Anwendungsrolle allein verhindern nicht, dass sie einen Fall im Zustand
-- abgeschlossen anlegt, einen abgeschlossenen Fall wieder aktiv setzt, die Frist verschiebt oder
-- zustand auf geloescht setzt (der Teilindex nimmt den Fall dann aus, das Aktenzeichen wird frei).
-- Der Auslöser lässt in Sprint 1 allein zu: INSERT im Zustand aktiv ohne Zeiten und UPDATE von
-- aktiv nach abgeschlossen mit gesetzten Zeiten und sonst unveränderten Spalten. Die Meldung
-- nennt keinen Wert der Zeile. Der Eigentümer (Migrationen, Grundeinrichtung, Direktweg der
-- Tests) ist ausgenommen; gegen ihn hält ein Auslöser ohnehin nicht (GS-15). Die übrigen
-- Zustände kommen mit R3-F-020 als neue Fassung der Funktion.

CREATE FUNCTION r3cosint.fall_uebergang_pruefen()
RETURNS trigger LANGUAGE plpgsql SECURITY INVOKER
SET search_path = pg_catalog, pg_temp
AS $fall_uebergang_pruefen$
BEGIN
    IF current_user = 'r3cosint_eigentuemer' THEN
        RETURN NEW;
    END IF;
    IF TG_OP = 'INSERT' THEN
        IF NEW.zustand IS NOT DISTINCT FROM 'aktiv'
           AND NEW.geschlossen_am IS NULL AND NEW.prueffrist_bis IS NULL THEN
            RETURN NEW;
        END IF;
    ELSIF TG_OP = 'UPDATE' THEN
        IF OLD.zustand IS NOT DISTINCT FROM 'aktiv'
           AND NEW.zustand IS NOT DISTINCT FROM 'abgeschlossen'
           AND NEW.geschlossen_am IS NOT NULL AND NEW.prueffrist_bis IS NOT NULL
           AND NEW.kennung IS NOT DISTINCT FROM OLD.kennung
           AND NEW.aktenzeichen IS NOT DISTINCT FROM OLD.aktenzeichen
           AND NEW.ermittelnde_person IS NOT DISTINCT FROM OLD.ermittelnde_person
           AND NEW.rechtsgrundlage IS NOT DISTINCT FROM OLD.rechtsgrundlage
           AND NEW.rechtsregime IS NOT DISTINCT FROM OLD.rechtsregime
           AND NEW.fallkategorie IS NOT DISTINCT FROM OLD.fallkategorie
           AND NEW.eroeffnet_am IS NOT DISTINCT FROM OLD.eroeffnet_am THEN
            RETURN NEW;
        END IF;
    END IF;
    RAISE EXCEPTION 'r3cosint: unzulässiger Zustandsübergang an fall' USING ERRCODE = 'P0001';
END
$fall_uebergang_pruefen$;

CREATE TRIGGER fall_uebergang BEFORE INSERT OR UPDATE ON r3cosint.fall
    FOR EACH ROW EXECUTE FUNCTION r3cosint.fall_uebergang_pruefen();
