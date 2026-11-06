-- Revision 0002, Startwerte (ADR 0007, Nr. 22; Projektauftrag 4.4): die sieben Fallkategorien.
-- Die Werte sind ein Vorschlag zur Bestätigung (Projektauftrag 4.4); kein Fristwert steht im Code.
INSERT INTO r3cosint.fallkategorie
    (kennung, bezeichnung, erste_pruefung_monate, folgepruefung_monate)
VALUES
    ('nichtanhandnahme_einstellung', 'Nichtanhandnahme oder Einstellung', 12, NULL),
    ('uebertretung', 'Übertretung', 36, NULL),
    ('vergehen', 'Vergehen', 84, NULL),
    ('freiheitsstrafe_bis_3_jahre', 'Freiheitsstrafe bis 3 Jahre', 120, NULL),
    ('verbrechen_ueber_3_jahre', 'Verbrechen über 3 Jahre', 180, NULL),
    ('lebenslaenglich', 'Lebenslänglich', 360, NULL),
    ('unverjaehrbar', 'Unverjährbar', 60, 60);
