-- Revision 0001 (ADR 0007, Entscheid 7 und 9; R3-F-008): Standardrecht EXECUTE entziehen.
-- Läuft als r3cosint_eigentuemer; gilt für Funktionen, die diese Rolle künftig anlegt.
ALTER DEFAULT PRIVILEGES REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC;
