-- Rückweg von Revision 0004 (ADR 0007, E-S1-04 b): entfernt Auslöser und Funktion.
-- Keine Spurtabelle ist betroffen.
DROP TRIGGER fall_uebergang ON r3cosint.fall;
DROP FUNCTION r3cosint.fall_uebergang_pruefen();
