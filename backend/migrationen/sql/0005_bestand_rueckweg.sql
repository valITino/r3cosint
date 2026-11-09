-- Rückweg von Revision 0005 (ADR 0007, E-S1-04 b): entfernt die drei Tabellen des Bestands in der
-- Reihenfolge der Fremdschlüssel. Keine Spurtabelle ist betroffen.
DROP TABLE r3cosint.beziehung;
DROP TABLE r3cosint.entitaet;
DROP TABLE r3cosint.herkunft;
