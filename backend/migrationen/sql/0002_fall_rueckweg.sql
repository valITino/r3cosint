-- Rückweg von Revision 0002 (ADR 0007, Nr. 11 und E-S1-04 b): entfernt die drei Tabellen.
-- Keine Spurtabelle verweist in diesem Stand darauf (Revision 0003 hat keinen Rückweg).
DROP TABLE r3cosint.fall_schluessel;
DROP TABLE r3cosint.fall;
DROP TABLE r3cosint.fallkategorie;
