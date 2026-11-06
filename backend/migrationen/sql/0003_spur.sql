-- Revision 0003 (ADR 0007, Nr. 10 bis 21 und Festlegung S1.2; R3-F-008, R3-F-012): beide Spuren,
-- Kettenkopf, Funktionen, Auslöser, Einfügeprüfung und Rechte. Läuft als r3cosint_eigentuemer
-- im Schema r3cosint. Die Revision hat keinen Rückweg (E-S1-04 b).

CREATE TABLE r3cosint.ermittlungsspur (
    kennung uuid PRIMARY KEY,
    fall_kennung uuid NOT NULL REFERENCES r3cosint.fall (kennung),
    position integer NOT NULL,
    zeitpunkt timestamptz NOT NULL,
    person_kennung text NOT NULL,
    eintragstyp text NOT NULL,
    kennzeichnung text NOT NULL,
    payload text NOT NULL,
    vorgaenger_pruefsumme char(64) NOT NULL,
    pruefsumme char(64) NOT NULL UNIQUE,
    UNIQUE (fall_kennung, position),
    CONSTRAINT ermittlungsspur_position_ab_eins CHECK (position >= 1),
    CONSTRAINT ermittlungsspur_zeitbereich CHECK (
        isfinite(zeitpunkt)
        AND zeitpunkt >= '2000-01-01 00:00:00+00'
        AND zeitpunkt < '9999-01-01 00:00:00+00'),
    CONSTRAINT ermittlungsspur_person_kennung_form CHECK (person_kennung ~ '^[a-z0-9._-]{1,64}$'),
    CONSTRAINT ermittlungsspur_eintragstyp_vorrat CHECK (eintragstyp IN ('entitaet', 'beziehung')),
    CONSTRAINT ermittlungsspur_kennzeichnung_vorrat CHECK (kennzeichnung IN ('quellenaussage', 'schlussfolgerung')),
    CONSTRAINT ermittlungsspur_payload_objekt CHECK (jsonb_typeof(payload::jsonb) = 'object'),
    CONSTRAINT ermittlungsspur_vorgaenger_form CHECK (vorgaenger_pruefsumme ~ '^[0-9a-f]{64}$'),
    CONSTRAINT ermittlungsspur_pruefsumme_form CHECK (pruefsumme ~ '^[0-9a-f]{64}$')
);

CREATE TABLE r3cosint.arbeitsspur (
    kennung uuid PRIMARY KEY,
    fall_kennung uuid NOT NULL REFERENCES r3cosint.fall (kennung),
    position integer NOT NULL,
    zeitpunkt timestamptz NOT NULL,
    person_kennung text NOT NULL,
    eintragstyp text NOT NULL,
    kennzeichnung text NOT NULL,
    payload text NOT NULL,
    vorgaenger_pruefsumme char(64) NOT NULL,
    pruefsumme char(64) NOT NULL UNIQUE,
    UNIQUE (fall_kennung, position),
    CONSTRAINT arbeitsspur_position_ab_eins CHECK (position >= 1),
    CONSTRAINT arbeitsspur_zeitbereich CHECK (
        isfinite(zeitpunkt)
        AND zeitpunkt >= '2000-01-01 00:00:00+00'
        AND zeitpunkt < '9999-01-01 00:00:00+00'),
    CONSTRAINT arbeitsspur_person_kennung_form CHECK (person_kennung ~ '^[a-z0-9._-]{1,64}$'),
    CONSTRAINT arbeitsspur_eintragstyp_vorrat CHECK (eintragstyp IN ('fall_eroeffnet', 'fall_geschlossen')),
    CONSTRAINT arbeitsspur_kennzeichnung_vorrat CHECK (kennzeichnung IN ('quellenaussage', 'schlussfolgerung')),
    CONSTRAINT arbeitsspur_payload_objekt CHECK (jsonb_typeof(payload::jsonb) = 'object'),
    CONSTRAINT arbeitsspur_vorgaenger_form CHECK (vorgaenger_pruefsumme ~ '^[0-9a-f]{64}$'),
    CONSTRAINT arbeitsspur_pruefsumme_form CHECK (pruefsumme ~ '^[0-9a-f]{64}$')
);

CREATE TABLE r3cosint.kettenkopf (
    fall_kennung uuid NOT NULL REFERENCES r3cosint.fall (kennung),
    spur text NOT NULL,
    position integer NOT NULL,
    pruefsumme char(64) NOT NULL,
    PRIMARY KEY (fall_kennung, spur),
    CONSTRAINT kettenkopf_spur_vorrat CHECK (spur IN ('ermittlungsspur', 'arbeitsspur')),
    CONSTRAINT kettenkopf_position_ab_null CHECK (position >= 0),
    CONSTRAINT kettenkopf_pruefsumme_form CHECK (pruefsumme ~ '^[0-9a-f]{64}$')
);

-- Funktionen: SECURITY INVOKER (Vorgabe), search_path fest, Objekte mit r3cosint qualifiziert,
-- Eingabeparameter mit Präfix p_, Ausgabespalten mit Präfix o_, kein dynamisches SQL (SD-S12-01,
-- SD-S12-06). Der Rumpf steht in Dollar-Quotes mit dem Funktionsnamen als Marke.

CREATE FUNCTION r3cosint.spur_anfangswert(p_spur text, p_fall uuid)
RETURNS text LANGUAGE sql STABLE STRICT SECURITY INVOKER
SET search_path = pg_catalog, pg_temp
AS $spur_anfangswert$
    SELECT encode(sha256(convert_to('r3cosint-spur-1|' || p_spur || '|' || p_fall::text, 'UTF8')), 'hex')
$spur_anfangswert$;

CREATE FUNCTION r3cosint.spur_pruefsumme(
    p_spur text, p_kennung uuid, p_fall_kennung uuid, p_position integer,
    p_zeitpunkt timestamptz, p_person_kennung text, p_eintragstyp text,
    p_kennzeichnung text, p_payload text, p_vorgaenger_pruefsumme text)
RETURNS text LANGUAGE plpgsql STABLE STRICT SECURITY INVOKER
SET search_path = pg_catalog, pg_temp
AS $spur_pruefsumme$
BEGIN
    -- Zeitbereich wie spur.kette.zeitpunkt_text: 2000-01-01 bis vor 9999-01-01 UTC, endlich.
    IF NOT (isfinite(p_zeitpunkt)
            AND p_zeitpunkt >= '2000-01-01 00:00:00+00'
            AND p_zeitpunkt < '9999-01-01 00:00:00+00') THEN
        RAISE EXCEPTION 'r3cosint: Zeitpunkt ausserhalb des Bereichs' USING ERRCODE = '22008';
    END IF;
    RETURN encode(sha256(convert_to(
        'r3cosint-spur-1' || E'\n'
        || octet_length(convert_to(p_spur, 'UTF8'))::text || ':' || p_spur || E'\n'
        || octet_length(convert_to(p_kennung::text, 'UTF8'))::text || ':' || p_kennung::text || E'\n'
        || octet_length(convert_to(p_fall_kennung::text, 'UTF8'))::text || ':' || p_fall_kennung::text || E'\n'
        || octet_length(convert_to(p_position::text, 'UTF8'))::text || ':' || p_position::text || E'\n'
        || octet_length(convert_to(to_char(p_zeitpunkt AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS.US"Z"'), 'UTF8'))::text
           || ':' || to_char(p_zeitpunkt AT TIME ZONE 'UTC', 'YYYY-MM-DD"T"HH24:MI:SS.US"Z"') || E'\n'
        || octet_length(convert_to(p_person_kennung, 'UTF8'))::text || ':' || p_person_kennung || E'\n'
        || octet_length(convert_to(p_eintragstyp, 'UTF8'))::text || ':' || p_eintragstyp || E'\n'
        || octet_length(convert_to(p_kennzeichnung, 'UTF8'))::text || ':' || p_kennzeichnung || E'\n'
        || octet_length(convert_to(p_payload, 'UTF8'))::text || ':' || p_payload || E'\n'
        || octet_length(convert_to(p_vorgaenger_pruefsumme, 'UTF8'))::text || ':' || p_vorgaenger_pruefsumme || E'\n',
        'UTF8')), 'hex');
END
$spur_pruefsumme$;

CREATE FUNCTION r3cosint.spur_kette_pruefen(p_spur text, p_fall uuid)
RETURNS TABLE (
    o_unversehrt boolean, o_anzahl integer, o_position integer, o_grund text,
    o_letzte_pruefsumme text, o_kopf_position integer)
LANGUAGE plpgsql STABLE SECURITY INVOKER
SET search_path = pg_catalog, pg_temp
AS $spur_kette_pruefen$
DECLARE
    v_zeile record;
    v_summen text[];
    v_erwartet integer := 1;
    v_gezaehlt integer := 0;
    v_errechnet text;
    v_kopf_gefunden boolean;
    v_kp integer;
    v_kpr text;
    v_grund text;
    v_position integer;
BEGIN
    IF p_spur IS DISTINCT FROM 'ermittlungsspur' AND p_spur IS DISTINCT FROM 'arbeitsspur' THEN
        RAISE EXCEPTION 'r3cosint: unbekannte Spur';
    END IF;
    IF p_fall IS NULL THEN
        RAISE EXCEPTION 'r3cosint: Fall fehlt';
    END IF;
    v_summen := ARRAY[r3cosint.spur_anfangswert(p_spur, p_fall)];
    SELECT k.position, k.pruefsumme INTO v_kp, v_kpr
      FROM r3cosint.kettenkopf AS k WHERE k.fall_kennung = p_fall AND k.spur = p_spur;
    v_kopf_gefunden := FOUND;
    FOR v_zeile IN
        SELECT s.kennung, s.fall_kennung, s.position, s.zeitpunkt, s.person_kennung,
               s.eintragstyp, s.kennzeichnung, s.payload, s.vorgaenger_pruefsumme, s.pruefsumme
          FROM (
            SELECT e.* FROM r3cosint.ermittlungsspur AS e WHERE p_spur = 'ermittlungsspur'
            UNION ALL
            SELECT a.* FROM r3cosint.arbeitsspur AS a WHERE p_spur = 'arbeitsspur'
          ) AS s
         WHERE s.fall_kennung = p_fall
         ORDER BY s.position, s.kennung
    LOOP
        IF v_zeile.position IS DISTINCT FROM v_erwartet THEN
            v_grund := 'luecke'; v_position := v_erwartet; EXIT;
        END IF;
        BEGIN
            v_errechnet := r3cosint.spur_pruefsumme(
                p_spur, v_zeile.kennung, v_zeile.fall_kennung, v_zeile.position,
                v_zeile.zeitpunkt, v_zeile.person_kennung, v_zeile.eintragstyp,
                v_zeile.kennzeichnung, v_zeile.payload, v_zeile.vorgaenger_pruefsumme);
        EXCEPTION WHEN SQLSTATE '22008' THEN
            -- Zeitpunkt ausserhalb des Bereichs: der Eintrag gilt als geändert, wie im Python-Weg.
            v_errechnet := NULL;
        END;
        IF v_errechnet IS DISTINCT FROM v_zeile.pruefsumme THEN
            v_grund := 'inhalt_geaendert'; v_position := v_zeile.position; EXIT;
        END IF;
        IF v_zeile.vorgaenger_pruefsumme IS DISTINCT FROM v_summen[v_gezaehlt + 1] THEN
            v_grund := 'vorgaenger_falsch'; v_position := v_zeile.position; EXIT;
        END IF;
        v_summen := v_summen || v_zeile.pruefsumme::text;
        v_erwartet := v_erwartet + 1;
        v_gezaehlt := v_gezaehlt + 1;
    END LOOP;
    IF v_grund IS NULL THEN
        IF NOT v_kopf_gefunden THEN
            v_grund := 'kopf_abweichend'; v_position := 0;
        ELSIF v_kp > v_gezaehlt THEN
            v_grund := 'kopf_abweichend'; v_position := v_gezaehlt + 1;
        ELSIF v_kp < v_gezaehlt THEN
            v_grund := 'kopf_abweichend'; v_position := v_kp + 1;
            v_gezaehlt := greatest(v_kp, 0);
        ELSIF v_kpr IS DISTINCT FROM v_summen[v_gezaehlt + 1] THEN
            v_grund := 'kopf_abweichend'; v_position := v_gezaehlt;
            v_gezaehlt := greatest(v_gezaehlt - 1, 0);
        END IF;
    END IF;
    RETURN QUERY SELECT
        v_grund IS NULL, v_gezaehlt, v_position, v_grund,
        v_summen[v_gezaehlt + 1], CASE WHEN v_kopf_gefunden THEN v_kp END;
END
$spur_kette_pruefen$;

CREATE FUNCTION r3cosint.spur_unveraenderlich()
RETURNS trigger LANGUAGE plpgsql SECURITY INVOKER
SET search_path = pg_catalog, pg_temp
AS $spur_unveraenderlich$
BEGIN
    RAISE EXCEPTION 'r3cosint: % ist ausschliesslich anfügbar', TG_TABLE_NAME;
END
$spur_unveraenderlich$;

CREATE FUNCTION r3cosint.spur_einfuegen_pruefen()
RETURNS trigger LANGUAGE plpgsql SECURITY INVOKER
SET search_path = pg_catalog, pg_temp
AS $spur_einfuegen_pruefen$
DECLARE
    v_kp integer;
    v_kpr text;
BEGIN
    IF TG_TABLE_SCHEMA IS DISTINCT FROM 'r3cosint' THEN
        RAISE EXCEPTION 'r3cosint: Spur ausserhalb des Schemas r3cosint';
    END IF;
    -- Fehlt ein Pflichtfeld, weist die Tabelle selbst mit 23502 ab.
    IF NEW.kennung IS NULL OR NEW.fall_kennung IS NULL OR NEW.position IS NULL
       OR NEW.zeitpunkt IS NULL OR NEW.person_kennung IS NULL OR NEW.eintragstyp IS NULL
       OR NEW.kennzeichnung IS NULL OR NEW.payload IS NULL
       OR NEW.vorgaenger_pruefsumme IS NULL OR NEW.pruefsumme IS NULL THEN
        RETURN NEW;
    END IF;
    SELECT k.position, k.pruefsumme INTO v_kp, v_kpr
      FROM r3cosint.kettenkopf AS k
     WHERE k.fall_kennung = NEW.fall_kennung AND k.spur = TG_TABLE_NAME;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'r3cosint: Kette des Falls besteht nicht' USING ERRCODE = '23503';
    END IF;
    IF NEW.position IS DISTINCT FROM v_kp + 1 THEN
        RAISE EXCEPTION 'r3cosint: Position folgt nicht auf den Kettenkopf';
    END IF;
    IF NEW.vorgaenger_pruefsumme IS DISTINCT FROM v_kpr THEN
        RAISE EXCEPTION 'r3cosint: Vorgänger ist nicht der Kettenkopf';
    END IF;
    IF NEW.pruefsumme IS DISTINCT FROM r3cosint.spur_pruefsumme(
        TG_TABLE_NAME, NEW.kennung, NEW.fall_kennung, NEW.position, NEW.zeitpunkt,
        NEW.person_kennung, NEW.eintragstyp, NEW.kennzeichnung, NEW.payload,
        NEW.vorgaenger_pruefsumme) THEN
        RAISE EXCEPTION 'r3cosint: Prüfsumme stimmt nicht';
    END IF;
    RETURN NEW;
END
$spur_einfuegen_pruefen$;

CREATE FUNCTION r3cosint.kettenkopf_pruefen()
RETURNS trigger LANGUAGE plpgsql SECURITY INVOKER
SET search_path = pg_catalog, pg_temp
AS $kettenkopf_pruefen$
DECLARE
    v_erwartet text;
BEGIN
    IF TG_OP = 'INSERT' THEN
        IF NEW.position IS DISTINCT FROM 0
           OR NEW.pruefsumme IS DISTINCT FROM r3cosint.spur_anfangswert(NEW.spur, NEW.fall_kennung) THEN
            RAISE EXCEPTION 'r3cosint: Kettenkopf beginnt nicht mit Position 0 und Anfangswert';
        END IF;
        RETURN NEW;
    END IF;
    IF NEW.fall_kennung IS DISTINCT FROM OLD.fall_kennung OR NEW.spur IS DISTINCT FROM OLD.spur THEN
        RAISE EXCEPTION 'r3cosint: Fall und Spur des Kettenkopfs sind unveränderlich';
    END IF;
    IF NEW.position IS DISTINCT FROM OLD.position + 1 THEN
        RAISE EXCEPTION 'r3cosint: Kettenkopf rückt um genau eine Position vor';
    END IF;
    SELECT s.pruefsumme::text INTO v_erwartet
      FROM (
        SELECT e.fall_kennung, e.position, e.pruefsumme
          FROM r3cosint.ermittlungsspur AS e WHERE OLD.spur = 'ermittlungsspur'
        UNION ALL
        SELECT a.fall_kennung, a.position, a.pruefsumme
          FROM r3cosint.arbeitsspur AS a WHERE OLD.spur = 'arbeitsspur'
      ) AS s
     WHERE s.fall_kennung = NEW.fall_kennung AND s.position = NEW.position;
    IF NEW.pruefsumme IS DISTINCT FROM v_erwartet THEN
        RAISE EXCEPTION 'r3cosint: Kettenkopf trägt nicht die Prüfsumme der Zeile';
    END IF;
    RETURN NEW;
END
$kettenkopf_pruefen$;

-- Auslöser (ADR 0007, Nr. 10 und 13): gelten für jede Rolle.
CREATE TRIGGER ermittlungsspur_unveraenderlich BEFORE UPDATE OR DELETE ON r3cosint.ermittlungsspur
    FOR EACH ROW EXECUTE FUNCTION r3cosint.spur_unveraenderlich();
CREATE TRIGGER ermittlungsspur_unveraenderlich_leeren BEFORE TRUNCATE ON r3cosint.ermittlungsspur
    FOR EACH STATEMENT EXECUTE FUNCTION r3cosint.spur_unveraenderlich();
CREATE TRIGGER arbeitsspur_unveraenderlich BEFORE UPDATE OR DELETE ON r3cosint.arbeitsspur
    FOR EACH ROW EXECUTE FUNCTION r3cosint.spur_unveraenderlich();
CREATE TRIGGER arbeitsspur_unveraenderlich_leeren BEFORE TRUNCATE ON r3cosint.arbeitsspur
    FOR EACH STATEMENT EXECUTE FUNCTION r3cosint.spur_unveraenderlich();
CREATE TRIGGER kettenkopf_nicht_loeschen BEFORE DELETE ON r3cosint.kettenkopf
    FOR EACH ROW EXECUTE FUNCTION r3cosint.spur_unveraenderlich();
CREATE TRIGGER kettenkopf_nicht_leeren BEFORE TRUNCATE ON r3cosint.kettenkopf
    FOR EACH STATEMENT EXECUTE FUNCTION r3cosint.spur_unveraenderlich();

CREATE TRIGGER ermittlungsspur_einfuegen_pruefen BEFORE INSERT ON r3cosint.ermittlungsspur
    FOR EACH ROW EXECUTE FUNCTION r3cosint.spur_einfuegen_pruefen();
CREATE TRIGGER arbeitsspur_einfuegen_pruefen BEFORE INSERT ON r3cosint.arbeitsspur
    FOR EACH ROW EXECUTE FUNCTION r3cosint.spur_einfuegen_pruefen();
CREATE TRIGGER kettenkopf_einfuegen_aendern_pruefen BEFORE INSERT OR UPDATE ON r3cosint.kettenkopf
    FOR EACH ROW EXECUTE FUNCTION r3cosint.kettenkopf_pruefen();

-- Rechte der Rolle r3cosint_anwendung (ADR 0007, Nr. 9; SD-S12-02: UPDATE am Kettenkopf allein auf
-- position und pruefsumme, sonst wäre LOCK TABLE möglich): nie DELETE oder TRUNCATE, kein UPDATE
-- auf den Spuren; kein EXECUTE auf die Auslöserfunktionen (ein Auslöser greift auch ohne).
GRANT SELECT, INSERT ON r3cosint.ermittlungsspur TO r3cosint_anwendung;
GRANT SELECT, INSERT ON r3cosint.arbeitsspur TO r3cosint_anwendung;
GRANT SELECT, INSERT ON r3cosint.kettenkopf TO r3cosint_anwendung;
GRANT UPDATE (position, pruefsumme) ON r3cosint.kettenkopf TO r3cosint_anwendung;
GRANT EXECUTE ON FUNCTION r3cosint.spur_anfangswert(text, uuid) TO r3cosint_anwendung;
GRANT EXECUTE ON FUNCTION r3cosint.spur_pruefsumme(
    text, uuid, uuid, integer, timestamptz, text, text, text, text, text) TO r3cosint_anwendung;
GRANT EXECUTE ON FUNCTION r3cosint.spur_kette_pruefen(text, uuid) TO r3cosint_anwendung;
