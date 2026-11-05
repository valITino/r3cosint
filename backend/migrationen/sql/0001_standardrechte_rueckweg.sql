-- Rückweg von Revision 0001 (ADR 0007, Entscheid 4 und 11; R3-F-008): gibt PUBLIC das
-- Standardrecht EXECUTE auf Funktionen zurück. Läuft als r3cosint_eigentuemer.
ALTER DEFAULT PRIVILEGES GRANT EXECUTE ON FUNCTIONS TO PUBLIC;
