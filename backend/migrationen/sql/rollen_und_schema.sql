-- Grundeinrichtung (ADR 0007, Entscheid 7, Festlegung S1.1; R3-F-008). Keine Revision.
--
-- Läuft als Superuser der Instanz, einmal vor der ersten Revision: Alembic läuft als
-- r3cosint_eigentuemer, und diese Rolle kann sich nicht selbst anlegen; läge die
-- Versionstabelle unter dem Superuser, gehörte sie ihm. Rollen gelten für die ganze
-- Instanz, das Schema für die Datenbank, in der dieses Skript läuft.
--
-- Die Passwörter stehen nicht im Text: der Aufrufer setzt vorher je Rolle mit Bindeparameter
--   SELECT set_config('r3cosint.passwort_eigentuemer', :wert, false)
--   SELECT set_config('r3cosint.passwort_anwendung', :wert, false)
-- und das Skript leert beide Werte am Ende. format() mit %L setzt sie als Literal ein.

-- Schlägt CREATE ROLE fehl (zum Beispiel weil die Rolle besteht), enthielte der Fehlertext von
-- PostgreSQL den Anweisungstext samt Passwort. Deshalb fängt jeder Block den Fehler und löst
-- einen eigenen aus, der Rolle und SQLSTATE nennt, nie SQLERRM, Anweisungstext oder Passwort.
DO $grundeinrichtung$
BEGIN
    BEGIN
        EXECUTE format(
            'CREATE ROLE r3cosint_eigentuemer LOGIN NOSUPERUSER NOCREATEROLE NOCREATEDB '
            'NOBYPASSRLS NOREPLICATION PASSWORD %L',
            current_setting('r3cosint.passwort_eigentuemer'));
    EXCEPTION WHEN OTHERS THEN
        RAISE EXCEPTION 'Rolle r3cosint_eigentuemer nicht angelegt (SQLSTATE %)', SQLSTATE
            USING ERRCODE = SQLSTATE;
    END;
    BEGIN
        EXECUTE format(
            'CREATE ROLE r3cosint_anwendung LOGIN NOINHERIT NOSUPERUSER NOCREATEROLE NOCREATEDB '
            'NOBYPASSRLS NOREPLICATION PASSWORD %L',
            current_setting('r3cosint.passwort_anwendung'));
    EXCEPTION WHEN OTHERS THEN
        RAISE EXCEPTION 'Rolle r3cosint_anwendung nicht angelegt (SQLSTATE %)', SQLSTATE
            USING ERRCODE = SQLSTATE;
    END;
END
$grundeinrichtung$;

SELECT set_config('r3cosint.passwort_eigentuemer', '', false);
SELECT set_config('r3cosint.passwort_anwendung', '', false);

REVOKE CREATE ON SCHEMA public FROM PUBLIC;

CREATE SCHEMA r3cosint AUTHORIZATION r3cosint_eigentuemer;
GRANT USAGE ON SCHEMA r3cosint TO r3cosint_anwendung;

DO $verbinden$
BEGIN
    EXECUTE format('REVOKE ALL ON DATABASE %I FROM PUBLIC', current_database());
    EXECUTE format(
        'GRANT CONNECT ON DATABASE %I TO r3cosint_eigentuemer, r3cosint_anwendung',
        current_database());
END
$verbinden$;
