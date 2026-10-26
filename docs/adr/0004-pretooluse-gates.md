# ADR 0004 — PreToolUse-Gates und Prüfmittel (R3-Q-010)

| | |
|---|---|
| **Titel** | Die beiden PreToolUse-Gates `.claude/hooks/block-main-write.sh` und `.claude/hooks/block-prototype-import.sh`, ihre belegten Lücken und ihr Prüfmittel `scripts/pretooluse-gates-selbsttest.sh` |
| **Status** | **angenommen** — Umfang freigegeben am 2026-09-22 (Teil B, 6.13, Status-Block), R3-Q-010 abgenommen am 2026-09-23 (ADR 0002, Abschnitt 10); abgenommen sind Posten 1, 2, 4, 5, 6 und der Teil von Posten 7 am Prototyp-Gate, offen Posten 3, 8, 9, 10 und der Teil von Posten 7 am main-Gate (Teil A, Posten und belegte Lücken); als eigener ADR angelegt mit PS-2 am 2026-10-22; Aufteilung und Teil A angenommen am 2026-10-26 durch Merge des Pull Requests #30, Merge-Commit `80aee8dc978778b9184b9e9639328535f1708264` (ADR 0002, Abschnitt 10) |
| **Datum** | 2026-10-22 |
| **Kennung** | R3-Q-010 |
| **Grundlage** | Projektauftrag 3.2 c, 3.3, 3.4, 4.2, 5.6, 6.6; Eintrag R3-Q-010 mit Sammelposten in `docs/05_Product_Backlog.md`; `docs/10_Zustandsbericht_2026-09-02.md` (BER-05); `.claude/rules/claude-konfiguration.md` (Abschnitt "Hooks"); `.claude/rules/dokumentation.md`; `docs/adr/0001-rollenmodell.md`; ADR 0002 (6.1, Absatz "Anlass"; 6.12.12; O-8; O-28; Abschnitt 10); `docs/11_Schwachstellenregister.md` |
| **Herkunft** | verschoben aus ADR 0002, 6.13, mit PS-2 am 2026-10-22, unverändert als Teil B; Wortlaut bis zum Schnitt beim Commit `ac6e0c17672ad9f0d139a59dba8ca319f46056c4` |
| **Verfasst durch** | Software Architect (4.3) |

**Betroffene Dateien.** Dieser ADR legt an: `docs/adr/0004-pretooluse-gates.md` — sonst nichts. Er legt fest, was für `.claude/hooks/block-main-write.sh`, `.claude/hooks/block-prototype-import.sh` (Matcher in `.claude/settings.json`) und das Prüfmittel `scripts/pretooluse-gates-selbsttest.sh` gilt; geändert werden diese Dateien nur in Bau-Einheiten nach Teil B, 6.13 e und g. Bezug haben `docs/11_Schwachstellenregister.md` (SR-001 bis SR-006), die Sammelposten unter R3-Q-010 in `docs/05_Product_Backlog.md`, die Hook-Regel in `.claude/rules/claude-konfiguration.md` und die Gate-Zeilen in `CLAUDE.md`. Freigaben und Abnahmen stehen in ADR 0002, Abschnitt 10.

Teil A fasst zusammen; bei einem Widerspruch gelten Teil B und ADR 0002, Abschnitt 10, bis Teil A berichtigt ist. Jede Änderung an Teil A bekommt einen datierten Eintrag am Ende von Teil B in der Form "Vorher galt / Jetzt gilt / Weshalb" (ADR 0002, 6.1, Überschrift und Absatz "Anlass"); Teil B ist ausschliesslich anfügbar.

---

## Teil A — Stand

Stand vom 2026-10-22.

**Fundorte.** Teil B ist der unveränderte Text von ADR 0002, 6.13; Teil A verweist auf dessen Überschriften und Kennungen. "Status-Block" ist der Block am Anfang von 6.13. In 6.13 c stehen zwei Nachträge vom 2026-10-21: "zum Bau von Posten 4 und 5" meint den Nachtrag "Posten 4 und 5 gebaut; Einordnungen aus Bau und Verifikation; Posten 6 und 7 erfasst", "Festlegung für C3" den Nachtrag "zur Abnahme von Posten 4 und 5 — Festlegung für C3". Zahlen, Daten und Prüfsummen stammen aus Teil B, aus ADR 0002, Abschnitt 10, aus `docs/11_Schwachstellenregister.md` und aus den Übergaben vom 2026-10-21 (`docs/uebergaben/2026-10-21_abschnitt-c-posten-4-5.md`) und vom 2026-10-22 (`docs/uebergaben/2026-10-22_c3-prototyp-gate.md`); der Gegenstand der Fallklassen ist aus ihrer Liste im Prüfmittel gekürzt. Offene Fragen stehen mit Zuständigkeit in der Tabelle Restpunkte.

### Entscheid

1. Gegenstand sind die beiden bestehenden PreToolUse-Gates: `.claude/hooks/block-main-write.sh` schützt main (Projektauftrag 3.2 c), `.claude/hooks/block-prototype-import.sh` trennt Prototyp und Produktionscode bis zur Prototyp-Freigabe (5.6); massgeblich sind allein belegte Lücken, eine Härtung ohne ausgeführte Probe ist nicht Gegenstand (6.13 a und c).
2. E4 ist kein Kettenschritt der Definition of Done: D10 bleibt Lage C, eine D-Nummer wird nicht vergeben, und ob die Stapelprüfung für D10 als Betriebsart des Prototyp-Gates entsteht, bleibt als ADR 0002, O-8 offen und mit dem Grundgerüst terminiert (6.13 a).
3. Was ein Gate nicht prüfen kann, sperrt mit Rückgabewert 2 und Meldung — nicht auswertbare Eingabe (Entscheid zu ST-13, 6.13 b), ein fehlendes Werkzeug, eine Prüfstelle ohne gültigen Ausgang (Posten 4 bis 6) und am Prototyp-Gate die Überschreitung der eigenen Zeitgrenze (Posten 7); noch offen sind die jq-Schritte am Prototyp-Gate (Posten 8) und die eigene Zeitgrenze am main-Gate.
4. Eine Textprüfung ist nicht dicht: Was nur über die Auswertung durch die Shell, eine Zerlegung nach ihrer Syntax oder eine Angabe des Harness erkennbar wäre, wird nicht geschlossen, sondern als Grenze benannt und mit einem durchlaufenden Fall gemessen; die harte Zusicherung für main trägt das serverseitige Regelwerk, die Gates sind die zweite Verteidigungslinie (6.13 c).
5. Neue Befunde werden nach dem Massstab Erreichbarkeit, Vertrag, Mittel eingeordnet — als belegte Lücke, Grenze, gewolltes Verhalten oder Preis in sicherer Richtung (6.13 c, Nachträge ab 2026-09-23); belegte Lücken werden Posten unter R3-Q-010, terminiert mit der nächsten Änderung am jeweiligen Gate, spätestens vor der Freigabe des Grundgerüsts.
6. Prüfmittel ist ein einziges versioniertes Skript, `scripts/pretooluse-gates-selbsttest.sh`, mit Fallliste je Gate, Mutationsmodus `--mutationen` und einer einmal aus den Kopfkommentaren abgezählten Liste der Fallklassen: Jede als gedeckt behauptete Klasse braucht einen blockierenden, jede benannte Grenze einen durchlaufenden Fall (6.13 d).
7. Gebaut wird nach 6.13 g — zuerst das Soll auf 2, der Lauf fällt, dann das Gate, zuletzt der Vermerk —, mit einer Mutation je Behebung, einem blockierenden und einem durchzulassenden Gegenstand je Sachverhalt und grünem Regressionsschutz (6.13 d, Punkt 6; 6.13 f, Punkt 1 und 2).
8. Gate und Prüfmittel baut der SecDevOps Engineer; verifiziert wird durch Static und Dynamic Software Tester auf einem anderen Modell als die Umsetzung, abgenommen durch den Merge des Pull Requests (6.13 e; 6.13 f, Punkt 4; ADR 0002, Abschnitt 10).

### Festlegungen

| Kennung | Festlegung | seit | Fundort in Teil B |
|---|---|---|---|
| 6.13 a | Gegenstand sind beide PreToolUse-Gates; E4 ist kein Kettenschritt der Definition of Done (D10 bleibt Lage C, keine D-Nummer); abgegrenzt von R3-Q-005 und vom DoD-Gate (ADR 0002, 6.12); eine Berührung mit ADR 0002, O-8 legt eine Fortschreibung fest, nicht der Bau | 2026-09-21 | 6.13 a |
| 6.13 b | Belegte Lücken, Stand 2026-09-21 (ST-01 bis ST-05, ST-09, ST-13, P-01, P-10, kein Prüfmittel); Entscheid zu ST-13: nicht auswertbare Eingabe sperrt mit Rückgabewert 2, auch JSON mit `tool_input` als Zeichenkette; seither Bezug jedes Fehlerpfads ("blockiert, was das Gate nicht prüfen kann") | 2026-09-21; die Befunde der Tabelle bis 2026-09-23 mit E4.1 bis E4.3 behoben, fremdverifiziert oder als Grenze benannt | 6.13 b; 6.13, Status-Block, Nachträge vom 2026-09-23 zu E4.1, E4.2 und E4.3 |
| 6.13 c | Nicht Gegenstand: ST-06 bis ST-08, ST-10, ST-12, ST-14, ST-15, K-01, die Abhängigkeitsanalyse aus P-10 und jede Härtung ohne belegte Lücke; ST-11 als ADR 0002, O-28 geführt; benannte Grenzen werden festgeschrieben und als durchlaufende Fälle gemessen, nicht geschlossen; seit 2026-09-23 auch der Massstab für neue Befunde und die Posten unter R3-Q-010 | 2026-09-21; Nachträge vom 2026-09-23, 2026-10-14, 2026-10-21 (zwei) und 2026-10-22 | 6.13 c mit seinen Nachträgen |
| 6.13 d | Ein einziges Prüfmittel; Form 1 bis 6 (Angaben je Fall, Wegwerf-Klone für das main-Gate, keine Änderung an versionierten Dateien, Kopfzeile mit Commit und SHA-256-Präfix je Gate, Rückgabewert, Mutationsprobe im Skript); Mass ohne Zusicherungstabelle; Fallklassen einmal aus den Kopfkommentaren abgezählt; Ausgangsmenge: 37 Proben vom 2026-09-21, zehn Zusatzfälle, die rekonstruierbaren Proben vom 2026-08-25 | 2026-09-21; Punkt 2 präzisiert am 2026-09-23; die Annahme "einstellig" für die Mutationen ist seit E4.1 überschritten | 6.13 d; 6.13, Status-Block, Nachtrag vom 2026-09-23 — E4.1 gebaut |
| 6.13 e | Umsetzung von Gates und Prüfmittel: SecDevOps Engineer; Verifikation: Static und Dynamic Software Tester auf einem anderen Modell als die Umsetzung; Kopfkommentare und Hook-Regel führt die umsetzende Rolle nach, dieses ADR der Software Architect, den Backlog der Product Owner, die Gate-Tabelle in `CLAUDE.md` der Koordinator | 2026-09-21 | 6.13 e |
| 6.13 f | Massgeblich sind die sieben Tests von R3-Q-010; dazu (1) je Sachverhalt ein blockierender und ein durchzulassender Gegenstand, (2) Regressionsschutz: G01, G02, G03, G05, G06 und P01, P03, P04, P05 bleiben grün, (3) der Lauf ändert keine versionierte Datei, (4) Fremdverifikation auf einem anderen Modell vor jeder Fertigmeldung | 2026-09-21 | 6.13 f |
| 6.13 g | Schnitt E4.1 (Prüfmittel, keine Zeile an den Gates), E4.2 (Erkennungslücken am Prototyp-Gate), E4.3 (Ränder und Grenzen); Reihenfolge E4.1, E4.2, E4.3, E3, Grundgerüst; Bauvorschrift: Soll zuerst auf 2, dann Gate, zuletzt Vermerk; ein verbliebener Vermerk "belegte Lücke" ist ein offener Befund | 2026-09-21; freigegeben am 2026-09-22 | 6.13 g; 6.13, Status-Block, Nachtrag vom 2026-09-22 |

Teil B, 6.13 h ("Nachzuführen") ist eine Liste für ADR 0002, Abschnitt 9, keine Festlegung. Die sieben Abnahmekriterien nach 6.13 f — `R3-Q-010_prototyp_gate_pfadformen`, `R3-Q-010_prototyp_gate_richtungsgleichheit`, `R3-Q-010_prototyp_gate_schreibwirkung`, `R3-Q-010_gates_unlesbare_eingabe`, `R3-Q-010_pruefmittel_je_gate`, `R3-Q-010_main_gate_fremdbelegt`, `R3-Q-010_benannte_grenzen` — sind bis 2026-09-23 gebaut und verifiziert (6.13, Status-Block, Nachtrag vom 2026-09-23 — E4.3 gebaut, mit dem Nachtrag vom selben Tag).

### Fallklassen des Prüfmittels

Stand 2026-10-22: 479 Fälle, 66 Mutationen, 39 Fallklassen (main-Gate 27, Prototyp-Gate 12).

| Kürzel | Gate | Typ | Gegenstand | seit |
|---|---|---|---|---|
| KM-1 | main | gedeckt | Dateiänderung, während HEAD auf main oder master steht | 2026-09-23 (E4.1 bis E4.3) |
| KM-2 | main | gedeckt | Bash-Befehl, der auf main oder master committet | 2026-09-23 (E4.1 bis E4.3) |
| KM-3 | main | gedeckt | Bash-Befehl, der auf main oder master merged | 2026-09-23 (E4.1 bis E4.3) |
| KM-4 | main | gedeckt | Bash-Befehl, der nach main oder master pusht | 2026-09-23 (E4.1 bis E4.3) |
| KM-5 | main | gedeckt | gängige Interpreter mit Inline-Code | 2026-09-23 (E4.1 bis E4.3) |
| KM-6 | main | gedeckt | Anlegen eines Arbeitsbaums auf main | 2026-09-23 (E4.1 bis E4.3) |
| KM-7 | main | gedeckt | Mirror- und Wildcard-Pushes | 2026-09-23 (E4.1 bis E4.3) |
| KM-8 | main | gedeckt | fehlendes git sperrt | 2026-09-23 (E4.1 bis E4.3) |
| KM-9 | main | gedeckt | fehlendes jq sperrt (jq-Wache; Fall S06) | 2026-09-23 (E4.1 bis E4.3) |
| KM-10 | main | gedeckt | unlesbare Eingabe sperrt (ST-13) | 2026-09-23 (E4.1 bis E4.3) |
| KM-11 | main | gedeckt | Subshell in Klammern wird erkannt (N-9) | 2026-09-23 (E4.1 bis E4.3) |
| KM-12 | main | gedeckt | Schreibwirkung in einem geschützten Kontext, auch bei flüchtigen Zielen mit ".." oder "/dev/null" ohne Wortgrenze und mit Trenner dahinter (DT-E43-6, DT-E43-8) | 2026-09-23 (E4.3-Nachtrag) |
| KM-13 | main | gedeckt | Posten 1: Ziele bereinigt verglichen; Ausnahme für -b/-B nicht für main oder master, getrennt, angehängt oder gebündelt | 2026-10-14 (Posten 1) |
| KM-14 | main | gedeckt | Zielprüfung am Befehlstext, nicht am Abschnitt (Preis in sicherer Richtung) | 2026-10-21 (C2) |
| KM-15 | main | gedeckt | Posten 4 a: Ausnahme für -b/-B nur im eigenen worktree-add-Abschnitt | 2026-10-21 (C2) |
| KM-16 | main | gedeckt | Posten 4 b: Prüfungen am Befehlstext ohne Zeilenfortsetzungen; dazu POSIXLY_CORRECT (S17) | 2026-10-21 (C2) |
| KM-17 | main | gedeckt | Posten 4 c: Basename-Form, mit Preisen (Tabelle Preise) | 2026-10-21 (C2) |
| KM-18 | main | gedeckt | Posten 5: grosse Eingabe; kann eine Prüfung nicht laufen, sperrt das Gate | 2026-10-21 (C2) |
| GM-1 | main | grenze | Interpreter, der mit eigener Datei-API schreibt | 2026-09-23 (E4.1 bis E4.3) |
| GM-2 | main | grenze | zweiter Arbeitsbaum auf main, ausserhalb der Sitzung angelegt | 2026-09-23 (E4.1 bis E4.3) |
| GM-3 | main | grenze | Aufruf ausserhalb eines Repositories | 2026-09-23 (E4.1 bis E4.3) |
| GM-4 | main | grenze | Kontextwechsel in einem untergeordneten Shell-Aufruf | 2026-09-23 (E4.1 bis E4.3) |
| GM-5 | main | grenze | Auswertung durch die Shell | 2026-10-14 (Posten 1) |
| GM-6 | main | grenze | Schnittstelle: Werkzeugname ungleich Bash | 2026-10-14 (Posten 1) |
| GM-7 | main | grenze | Ausnahme für -b/-B am Text, nicht an der Syntax der Shell | 2026-10-14 (Posten 1) |
| GM-8 | main | grenze | Befehlstext: Verb und Sammel-Push-Optionen | 2026-10-14 (Posten 1) |
| GM-9 | main | grenze | Basename-Form: Zerlegung nur an Leerraum | 2026-10-21 (C2) |
| KP-1 | Prototyp | gedeckt | Richtung 1: Produktionscode importiert aus prototype/ | 2026-09-23 (E4.1 bis E4.3) |
| KP-2 | Prototyp | gedeckt | Richtung 2: Prototyp importiert aus dem Produktionscode | 2026-09-23 (E4.1 bis E4.3) |
| KP-3 | Prototyp | gedeckt | unlesbare Eingabe sperrt (ST-13) | 2026-09-23 (E4.1 bis E4.3) |
| KP-4 | Prototyp | gedeckt | Schreibwirkung derselben Befehlsklassen wie am main-Gate (ST-09) | 2026-09-23 (E4.1 bis E4.3) |
| KP-5 | Prototyp | gedeckt | Posten 5: grosse Eingabe bei Bash und am Dateiinhalt | 2026-10-21 (C2) |
| KP-6 | Prototyp | gedeckt | POSIXLY_CORRECT wird zu Beginn entfernt (ST-C2-D-01) | 2026-10-21 (C2) |
| KP-7 | Prototyp | gedeckt | Posten 2: vier Schreibweisen des Konstrukts in beiden Richtungen; vormals GP-3 (grenze) | 2026-10-22 (C3) |
| KP-8 | Prototyp | gedeckt | Posten 6: sed- und tr-Schritte prüfen ihren Rückgabewert | 2026-10-22 (C3) |
| KP-9 | Prototyp | gedeckt | Posten 7, Teil am Prototyp-Gate: eigene Zeitgrenze | 2026-10-22 (C3) |
| GP-1 | Prototyp | grenze | gemeinsame Abhängigkeiten und ihre Auflösung (P-10) | 2026-09-23 (E4.1 bis E4.3) |
| GP-2 | Prototyp | grenze | Pfadschreibweise der Richtung 2 (präfixgebunden) | 2026-09-23 (E4.1 bis E4.3) |
| GP-4 | Prototyp | grenze | Schnittstelle: Werkzeugname ungleich Bash | 2026-10-22 (C3) |

Zählung: 15 Klassen mit E4.1, 22 mit E4.3, 23 mit dem E4.3-Nachtrag, 28 mit Posten 1, 36 mit C2, 39 mit C3 (Fundorte: Tabelle Zahlen); welche der 22 Klassen bis E4.3 schon mit E4.1 bestanden, nennt Teil B nicht einzeln. GP-3 (symmetrische Lücken, Typ "grenze") ist seit 2026-10-22 als KP-7 gedeckt (6.13 c, Nachtrag vom 2026-10-22). Posten 8 bis 10 und die Grenze aus DT-C3-05 ändern die Zählung erst mit C4.

### Grenzen

| Kennung | Gate | Grenze | Fälle | Fundort in Teil B |
|---|---|---|---|---|
| GM-1 | main | Interpreter mit Skriptdatei oder eigener Datei-API, ohne Inline-Code im Text | in Teil B nicht einzeln genannt | 6.13, Status-Block, Nachtrag vom 2026-09-23 — E4.3 gebaut |
| GM-2 | main | zweiter Arbeitsbaum auf main, ausserhalb der Sitzung angelegt | in Teil B nicht einzeln genannt | 6.13 c (Absatz "Die im Kopfkommentar des main-Gates benannten Grenzen"); Status-Block wie GM-1 |
| GM-3 | main | Aufruf ausserhalb eines Repositories | ZF4a, ZF4b | wie GM-2; 6.13, Status-Block, Nachtrag vom 2026-09-23 — E4.1 gebaut |
| GM-4 | main | Kontextwechsel in einem untergeordneten Shell-Aufruf; eine Subshell in Klammern wird erkannt (ZF2a, KM-11) | ZF2b, ZF2c | wie GM-2; Status-Block wie GM-1 |
| GM-5 | main | Auswertung: Variable, Befehlssubstitution, eval, Brace-Expansion, Escape-Folgen in `$'...'`, Übersetzung von `$"..."` über einen Meldungskatalog; seit Posten 4 a auch ein worktree add in einer Befehlssubstitution innerhalb eines Ausnahme-Abschnitts, mit Posten 4 c eine Befehlssubstitution als Umleitungsoperand | u. a. G63, G64, G68, G71, G88, G89, G105 | 6.13, Status-Block, Nachtrag vom 2026-10-14; 6.13 c, Nachtrag vom 2026-10-14 (DT-B2-07); 6.13 c, Nachtrag vom 2026-10-21 zum Bau von Posten 4 und 5 (Absätze "Posten 4 a" und "Posten 4 c, Preise und Grenzen") |
| GM-6 | main | Schnittstelle: Werkzeugname ungleich Bash; den Namen setzt der Harness, nicht das Modell | ZF10a, ZF10b | 6.13 c, Nachträge vom 2026-09-23 und 2026-10-14 |
| GM-7 | main | Ausnahme für -b/-B am Text, nicht an der Syntax der Shell: -b/-B in Anführungszeichen oder im Kommentar, seit Posten 4 b auch über eine Zeilenfortsetzung neben worktree add; Preis in sperrender Richtung siehe Tabelle Preise | G59, G60, G80, G92, G93 | 6.13 c, Nachtrag vom 2026-10-14 (DT-B2-05 a und b); 6.13 c, Nachtrag vom 2026-10-21 zum Bau von Posten 4 und 5 (Absatz "Posten 4 b") |
| GM-8 | main | Befehlstext: Verb oder Sammel-Push-Option in Anführungszeichen oder hinter Rückstrich wird nicht erkannt | G69, G70 | 6.13 c, Nachtrag vom 2026-10-14 (DT-B2-08) |
| GM-9 | main | Basename-Form: Zerlegung nur an Leerraum (Option mit getrenntem Wert, auch in Anführungszeichen; Pfad in Anführungszeichen zerfällt in Wörter; `<` oder `>` am Wortende und Trenner in einem Wort in Anführungszeichen vor dem Pfad); Umleitungen nur über Einzelmuster erkannt, Operandenmuster seit Delta 4 nicht mehr erweitert | G90, G91, G97 bis G100, G106, G110 bis G112 | 6.13 c, Nachtrag vom 2026-10-21 zum Bau von Posten 4 und 5 (Absatz "Posten 4 c, Preise und Grenzen") |
| Zeitgrenze | main | keine eigene Zeitgrenze, es gilt die des Harness (15 s); bis zum Bau des Teils von Posten 7 am main-Gate von 6.13 d ausgenommen, ohne Fall und Fallklasse | — | 6.13 c, Nachtrag vom 2026-10-21 zum Bau von Posten 4 und 5 (Absatz "Zeitgrenze und 6.13 d"); 6.13 c, Nachtrag vom 2026-10-21 — Festlegung für C3 (Absatz "Posten 7, Teil am main-Gate") |
| GP-1 | Prototyp | gemeinsame Abhängigkeiten und ihre Auflösung (Alias, baseUrl, Workspace) werden nicht geprüft (P-10) | P35 | 6.13, Status-Block, Nachtrag vom 2026-09-23 — E4.3 gebaut; 6.13 c, Nachtrag vom 2026-10-22 (P52) |
| GP-2 | Prototyp | Pfadschreibweise der Richtung 2 präfixgebunden: Wurzelpfad, beliebiger Vorspann, `src=` ohne Schrägstrich hinter der Wurzel, `href=` mit Rückstrich, doppelter Rückstrich, mehrfaches "./", Alias "~/"; Lesart seit E4.2: Bezugsform ist das Konstrukt | L10 bis L16 | 6.13, Status-Block, Nachtrag vom 2026-09-23 — E4.2 gebaut (Lesart des Koordinators); 6.13 c, Nachtrag vom 2026-09-23 |
| Python-Formen | Prototyp | in Richtung 2 bewusst nur für die Bauwurzeln backend, frontend und deploy erkannt ("import app" wäre ein Fehlalarm); der Kopfkommentar nennt die Einschränkung ("bewusst nur die Bauwurzeln"), die Klassenliste führt keine Fallklasse dafür (siehe Restpunkte) | — | 6.13, Status-Block, Nachtrag vom 2026-09-23 — E4.2 gebaut |
| GP-4 | Prototyp | Schnittstelle: Werkzeugname ungleich Bash, Gegenstück zu GM-6; im Kopfkommentar seit 2026-10-22 | ZF10d | 6.13 c, Nachträge vom 2026-09-23 und 2026-10-22 |
| DT-C3-05 | Prototyp | Waisenprozess: ignoriert ein vom inneren Lauf aufgerufenes Werkzeug TERM, endet das Gate nach 12,011 s mit 2, das Werkzeug läuft etwa 11 s weiter; Grenze mit Fallklasse in C4, nur wenn die Ausgabekanäle des Gates nicht erst mit dem Waisenprozess schliessen, sonst Lücke | noch keiner (mit C4: Fall mit Soll 2) | 6.13 c, Nachtrag vom 2026-10-22 |
| ZF9 | Prototyp | gewolltes Verhalten: eine Datei unter .claude/ liegt ausserhalb dessen, was das Gate trennt, solange keine Bauwurzel unter die Ausnahmeliste fällt | ZF9 (durchlaufend) | 6.13 c, Nachtrag vom 2026-09-23 |
| ZF10c | Prototyp | gewolltes Verhalten, fail-closed: ein unbekannter Werkzeugname am Zweig der Dateiwerkzeuge sperrt | ZF10c (Soll 2) | 6.13 c, Nachtrag vom 2026-09-23 |
| P52 | Prototyp | gewollter Durchlass: blosser JS-Modulname `import("backend")`, ebenso die statische Form `import x from "backend"`; eine Auflösungskonfiguration fällt unter GP-1 | P52; Mutation MP32 | 6.13 c, Nachtrag vom 2026-10-22 |

### Preise in sicherer Richtung

| Kennung | Gate | Gegenstand | Ausweg | Fundort in Teil B |
|---|---|---|---|---|
| DT-B2-03 | main | -Bbmain wird mit der Prüfung des Namens hinter -b/-B mitgesperrt; die Ausnahme ist nicht verbreitert | — | 6.13, Status-Block, Nachtrag vom 2026-10-14; 6.13 c, Nachtrag vom 2026-10-14 |
| B2-PM-14, B2-GATE-D03 (GM-7, sperrende Richtung) | main | -b/-B main als Inhalt (Commit-Meldung, Suchmuster, Pfad in Anführungszeichen, Kommentar) sperrt; Fälle A78, A79 | Commit-Meldung mit dem Write-Werkzeug in eine Datei schreiben, dann `git commit -F <datei>` | 6.13 c, Nachtrag vom 2026-10-14 |
| B2-GATE-D04 (KM-13) | main | `git push origin \$'main'` (maskiertes Dollarzeichen) sperrt, vorbestehend; Fall A77 | — | 6.13 c, Nachtrag vom 2026-10-14 |
| KM-14 | main | Zielprüfung am Befehlstext, nicht am Abschnitt: bleibt nach dem Abziehen der Ausnahme-Abschnitte ein worktree add ohne Ausnahme, sperrt jedes main an anderer Stelle derselben Eingabe; Fälle A89, A90 | getrennte Bash-Aufrufe | 6.13 c, Nachtrag vom 2026-10-21 zum Bau von Posten 4 und 5 (Absatz "Posten 4 a") |
| KM-17 (A102) | main | `echo "git worktree add ../main" > /tmp/x.txt` sperrt, Klasse "Wörter nur als Inhalt"; derselbe Inhalt in der bisherigen Sperrform sperrte schon vorher (A103) | Write-Werkzeug oder `git commit -F` | 6.13 c, Nachtrag vom 2026-10-21 zum Bau von Posten 4 und 5 (Absatz "Posten 4 c, Preise und Grenzen") |
| KM-17 (A139 bis A142, A149) | main | ein Operand in Anführungszeichen schliesst erst hinter einer Abschnittsgrenze oder einem Zeilenumbruch (A139, A140); `<` oder `>` in Anführungszeichen hinter dem Pfad (A141, A142) oder am Wortende vor --detach (A149) verschluckt das commit-ish oder --detach | den Befehl aufteilen | wie A102 |
| Umleitungsoperanden | main | die erste Zielprüfung liest weiter die Operanden von Umleitungen, vorbestehend | — | 6.13 c, Nachtrag vom 2026-10-21 zum Bau von Posten 4 und 5 (Restpunkte) |
| -bfeature | main | `git worktree add -bfeature /tmp/wt main` gibt 2 wie vor Posten 1, weil die Ausnahme Leerraum oder "=" hinter -b/-B verlangt; Fehlalarm in sicherer Richtung, nicht Gegenstand | — | 6.13 c, Nachtrag vom 2026-10-14 (Restpunkte) |
| Zeitgrenze 12 s | Prototyp | eine Eingabe, deren Prüfung länger als 12 s braucht, sperrt (6.13 b) | — | 6.13 c, Nachtrag vom 2026-10-21 — Festlegung für C3 (Absatz "Posten 7, Teil am Prototyp-Gate") |
| P38 | Prototyp | `python3 -c` mit einem Importtext über die Trennung und Umleitung nach /dev/null sperrt (Soll 2, Klasse "pruefstand"), weil die Interpreterklasse auf dem bereinigten Text unabhängig von der Umleitung trifft (DT-E43-5); Restbefund der Abnahme von R3-Q-010, nicht entschieden | — | 6.13, Status-Block, Nachtrag vom 2026-09-23 — Abnahme erteilt; 6.13 c, Nachträge vom 2026-09-23 und 2026-10-14; Gegenstand nach dem Vermerk des Falls im Prüfmittel |

ST-C2-G-03 ist ein Fehlalarm in sicherer Richtung derselben Klasse wie A139 bis A142, aber noch nicht als Preis benannt (Tabelle Restpunkte).

### Posten und belegte Lücken

| Posten | Gate | Gegenstand, Fälle | Status | terminiert | Register |
|---|---|---|---|---|---|
| 1 | main | Ziele von push und `worktree add` nach dem Entfernen von Anführungszeichen, Rückstrichen, Zeilenfortsetzungen und dem Dollar vor Anführungszeichen verglichen; Ausnahme für -b/-B nicht für main oder master; L01 bis L04, L18 | abgenommen am 2026-10-16 (Merge #26) | — | kein Eintrag |
| 2 | Prototyp | vier Schreibweisen des Konstrukts in beiden Richtungen an den Dateiwerkzeugen (`require (`, `@import url(`, `src =` und `href =`, `__import__` ohne Punkt); L05 bis L08, B66 bis B73, Gegenproben P42 bis P54 (P52 gewollter Durchlass) | abgenommen am 2026-10-22 (Merge #28) | — | kein Eintrag |
| 3 | Prototyp | lexikalische Bereinigung des Dateipfads (Segmente "." und "..", doppelte Schrägstriche) vor jeder Zuordnung; L09 (Soll 0, BEFUND_VON) | offen, belegte Lücke | C4, spätestens vor der Freigabe des Grundgerüsts | kein Eintrag (siehe Restpunkte) |
| 4 | main | a) Ausnahme für -b/-B nur im eigenen worktree-add-Abschnitt (L17); b) Verb, Sammel-Push-Optionen, Ausnahme und Abschnitte ohne Zeilenfortsetzungen geprüft (L19); c) Basename-Form `git worktree add <pfad>/main` sperrt (L21) | abgenommen am 2026-10-21 (Merge #27) | — | SR-002 (DT-C2-01, mit 4 b behoben), behoben mit Nachweis; für L17, L19, L21 kein Eintrag |
| 5 | beide | grosse Eingabe: der Abbruch des Schreibers durch SIGPIPE gilt nie als kein Treffer (`trifft`, Status aus PIPESTATUS); L20, L22, B64, B65 | abgenommen am 2026-10-21 (Merge #27) | — | SR-001, behoben mit Nachweis |
| 6 | Prototyp | sed- und tr-Schritte prüfen ihren Rückgabewert (`schritt_geprueft` an sieben Stellen); L23, L24 | abgenommen am 2026-10-22 (Merge #28) | — | SR-004, behoben mit Nachweis (Register, Nachtrag 2026-10-22 nach dem Merge des Pull Requests #28) |
| 7, Teil am Prototyp-Gate | Prototyp | eigene Zeitgrenze: Selbstaufruf unter `timeout -k 1 12`; S25 bis S28 | abgenommen am 2026-10-22 (Merge #28) | — | SR-003, Prototyp-Teil behoben mit Nachweis; Eintrag offen (main-Gate-Teil) |
| 7, Teil am main-Gate | main | keine eigene Zeitgrenze; gemessen 8 MB 14,22 s, über 15 s zwischen 8 und 9 MB; ohne Fall | offen, belegte Lücke | eigene Einheit vor der Freigabe des Grundgerüsts, Einordnung ausstehend | SR-003, main-Gate-Teil offen; Eintrag offen |
| 8 | Prototyp | jq-Schritte (tool, cmd, fp, payload) prüfen ihren Rückgabewert nicht; DT-C3-02: MultiEdit mit einem Objekt in `edits[1].new_string` läuft durch | offen, belegte Lücke, noch ohne Fall | C4, spätestens vor der Freigabe des Grundgerüsts | SR-005, offen |
| 9 | Prototyp | a) an den Dateiwerkzeugen Formen ohne Anführungszeichen und in Grossschreibung (DT-C3-01); b) `src=` und `href=` am Bash-Weg | offen, belegte Lücke, noch ohne Fall | C4, spätestens vor der Freigabe des Grundgerüsts | SR-006, offen |
| 10 | Prüfmittel | Fall und Mutation für `-k 1` (DT-C3-03, ST-C3-04), `import_module` je Richtung (ST-C3-03), statische JS-Form als Gegenprobe zu P52 | offen | C4, spätestens vor der Freigabe des Grundgerüsts | kein Eintrag, weil das Gate selbst wirkt |

Fundorte in Teil B: Posten 1 bis 3 in 6.13 c, Nachtrag vom 2026-09-23 (Absatz "Die drei Posten unter R3-Q-010"); Posten 4 und 5 in 6.13 c, Nachtrag vom 2026-10-14; Posten 6 und 7 in 6.13 c, Nachtrag vom 2026-10-21 zum Bau von Posten 4 und 5; der Bau von C3 in 6.13 c, Nachtrag vom 2026-10-21 — Festlegung für C3; Posten 8 bis 10 in 6.13 c, Nachtrag vom 2026-10-22; Bau und Verifikation je Posten im Status-Block. Register nach `docs/11_Schwachstellenregister.md`; "kein Eintrag" bei Posten 1, 2 und 4 nach dem Entscheid des Koordinators vom 2026-10-22 gegen rückwirkende Einträge (Übergabe vom 2026-10-22, Entscheide). C4 umfasst Posten 3, 8, 9 und 10; sein Schnitt ist vor dem Bau festzulegen (Projektauftrag 3.3).

### Zahlen

| Datum | Stand | Fälle | Mutationen | Fallklassen | Fundort in Teil B |
|---|---|---|---|---|---|
| 2026-09-23 | E4.1 gebaut | 202 (main 112, Prototyp 90) | 10 | 15 | 6.13, Status-Block, Nachtrag vom 2026-09-23 — E4.1 gebaut |
| 2026-09-23 | E4.2 gebaut | 225 | 11 | in Teil B nicht genannt (siehe Restpunkte) | 6.13, Status-Block, Nachtrag vom 2026-09-23 — E4.2 gebaut |
| 2026-09-23 | E4.3 gebaut | 247 (main 114, Prototyp 133) | 15 | 22 | 6.13, Status-Block, Nachtrag vom 2026-09-23 — E4.3 gebaut |
| 2026-09-23 | E4.3-Nachtrag; Stand der Abnahme von R3-Q-010 | 258 | 19 | 23 | 6.13, Status-Block, Nachtrag vom selben Tag (E4.3-Nachtrag, Aufgabe #4); ADR 0002, Abschnitt 10 |
| 2026-10-14 | Posten 1, dritte Baurunde | 318 | 26 | 28 (main 21, Prototyp 7) | 6.13, Status-Block, Nachtrag vom 2026-10-14 (Absatz "Prüfmittel"); 6.13 c, Nachtrag vom 2026-10-14 (Zählung der Fallklassen) |
| 2026-10-21 | Posten 4 und 5 (C2) | 447 (main 298, Prototyp 149) | 49 | 36 (main 27, Prototyp 9) | 6.13, Status-Block, Nachtrag vom 2026-10-21 — Posten 4 und 5 gebaut; 6.13 c, Nachtrag vom 2026-10-21 zum Bau von Posten 4 und 5 (Zählung der Fallklassen) |
| 2026-10-22 | C3: Posten 2, 6 und Teil von Posten 7 am Prototyp-Gate | 479 (main 298, Prototyp 181) | 66 | 39 (main 27, Prototyp 12) | 6.13, Status-Block, Nachtrag vom 2026-10-22 — C3; 6.13 c, Nachtrag vom 2026-10-22 (Zählung der Fallklassen) |

Die Zahlen je Gate für E4.1 und E4.3 sind Summen der in Teil B genannten Fälle mit Soll 2 und Soll 0 (E4.1: main 62 und 50, Prototyp 39 und 51; E4.3: main 67 und 47, Prototyp 82 und 51). Am Stand vom 2026-10-22 enden beide Modi mit Rückgabewert 0: Lauf B 479 von 479, Mutationsmodus 66 von 66 erkannt (auf dem Endstand beim Dynamic Software Tester). Stand der Dateien am Ende von C3 (SHA-256): Prototyp-Gate `348ba80862f036adf874c0ead117dc2854e24f877137ac20357072be567d7389`, Prüfmittel `7ce0db32e576c8f79ae571c303543a0421df7bf9a38557768d1d6aa26af8cef0`, main-Gate unverändert `b2732614ce3c51a7233d41439a044fe2401920bcb5640b75c919b812a58586cb` (6.13, Status-Block, Nachtrag vom 2026-10-22 — C3).

### Restpunkte

| Kennung | Gate | Gegenstand | Stand, Termin | Fundort |
|---|---|---|---|---|
| DT-C2-G-01 | main | ein Umleitungsoperator mit "&" vor dem Pfad (`>&`, `&>`, `2>&1`, `2>&-`) trennt den Pfad vom worktree-add-Abschnitt; die Basename-Form greift nicht (Durchlass, Mechanismus wie G112) | offen; Fall mit Soll 0 unter GM-9 mit der nächsten Änderung am main-Gate (Einheit zum Teil von Posten 7) | 6.13 c, Nachtrag vom 2026-10-21 zum Bau von Posten 4 und 5 (Restpunkte); Übergaben vom 2026-10-21 und 2026-10-22; SR-002 (Restpunkt) |
| ST-C2-G-03 | main | ein leeres oder nur aus Leerraum bestehendes Umleitungsziel in Anführungszeichen lässt die zweite Fassung das folgende Wort als Operanden lesen; Fehlalarm in sicherer Richtung wie A139 bis A142 (KM-17), noch nicht als Preis benannt, ohne Fall | offen, mit der Einheit zum Teil von Posten 7 | wie DT-C2-G-01 |
| ST-C2-G-01, ST-C2-G-02 | main | zwei Ungenauigkeiten im Kopfkommentar: G109 verschluckte das commit-ish, nicht einen Pfad; der Rückstrich ist im Operanden auch als Paar zugelassen | offen, wie ST-C2-G-03 | wie DT-C2-G-01 |
| ohne Fall | main | `git worktree add ../main/` gibt 0 (git lehnt "main/" als Zweignamen ab), `git worktree add -- ../main` gibt 2 | offen, ohne Fall | 6.13 c, Nachtrag vom 2026-10-21 zum Bau von Posten 4 und 5 (Restpunkte) |
| Grenzen ohne Sperre | main | G105, G106, G110 bis G112 | als Grenze geführt (GM-5, GM-9; Tabelle Grenzen) | Übergabe vom 2026-10-21 |
| jq am main-Gate | main | ob das main-Gate die Bauform von Posten 8 trägt, ist nicht gemessen | misst der Dynamic Software Tester mit der nächsten Änderung am main-Gate | 6.13 c, Nachtrag vom 2026-10-22 (Posten 8) |
| B2-GATE-R3-01, B2-PM-19 | main | GM-8 ist nur mit G69 und G70 gemessen; die Formen hinter einem Rückstrich, `'*:*'` und `"--mirror"` in Anführungszeichen sowie `worktree "add"` haben keinen eigenen Fall; die Fallwahl trifft der Software Architect | offen: Die Fallwahl war mit der nächsten Änderung am Prüfmittel fällig; C2 und C3 haben das Prüfmittel geändert, seine Klassenliste führt für GM-8 weiter nur G69 und G70. Zuständig: Software Architect, mit C4 | 6.13 c, Nachtrag vom 2026-10-14 (Restpunkte) |
| B2-GATE-R3-02 | main | die Nachtragszeile im Kopfkommentar ordnet GM-5 auch Mirror- und Wildcard-Pushes zu; kein Fall misst eine Sammel-Push-Option, die erst durch die Auswertung entsteht | offen, ungemessen | 6.13 c, Nachtrag vom 2026-10-14 (Restpunkte) |
| DT-C3-04 | Prototyp | der Wortlaut "unter 40 %" im Kopfkommentar ist widerlegt; zu ersetzen durch das gemessene Maximum mit Datum (5,06 s am 2026-10-22) | offen, mit C4 | 6.13 c, Nachtrag vom 2026-10-22 (Berichtigung vom 2026-10-22) |
| DT-C3-05, Bedingung | Prototyp | Messung, wann die Ausgabekanäle des Gates beim Waisenprozess schliessen; sie entscheidet zwischen Grenze und Lücke (Tabelle Grenzen) | offen, mit C4, Dynamic Software Tester | 6.13 c, Nachtrag vom 2026-10-22 |
| "Killed" | Prototyp | bei Rückgabewert 137 schreibt die äussere bash zusätzlich "Killed" auf die Fehlerausgabe; das ist kein Text des Gates | Rauschen, kein Befund | 6.13 c, Nachtrag vom 2026-10-22 (Restpunkte); Übergabe vom 2026-10-22 |
| Lauf C | Prüfmittel | Lauf C des SecDevOps Engineers lief gegen den Stand vor den letzten Kommentaränderungen; auf dem Endstand belegt der Dynamic Software Tester 66 von 66 | Hinweis, kein Befund | 6.13, Status-Block, Nachtrag vom 2026-10-22 — C3; Übergabe vom 2026-10-22 |
| Harness | beide | die Wirkung der Gates im laufenden Harness ist nicht gemessen; die Hooks wirken in den Sitzungen nicht | offen; von der Abnahme von Posten 4 und 5 ausdrücklich nicht umfasst | 6.13 c, Nachträge vom 2026-10-14, 2026-10-21 und 2026-10-22; ADR 0002, Abschnitt 10 |
| dod-gate.sh | — | `.claude/hooks/dod-gate.sh` trägt die Bauform von vor Posten 5 an zwei Stellen; nach dem Lesebefund nicht betroffen, nicht gemessen, nicht geändert | Neubewertung nach SR-001 bei mehrzeiliger tools_zeile oder gemessenem Fehlerstatus | 6.13 c, Nachtrag vom 2026-10-21 zum Bau von Posten 4 und 5 (Absatz "Posten 5, Fehlerpfad und Fälle"); SR-001 (Bauteil); Übergabe vom 2026-10-21 |
| DT-C2-G-02 | — | betraf nur ein Skript des Dynamic Software Testers | kein Befund am Gate | Übergabe vom 2026-10-21 |
| Restbefunde der Abnahme von R3-Q-010, Gates | beide | nicht behoben: DT-E43-4 (`deno eval`, `node --eval` und `bun -e` an beiden Gates nicht erkannt, Parität besteht) und P38 (Tabelle Preise); R-1/E-1 und DST-E42-N1 sind seit 2026-09-23 als Grenze GP-2 entschieden | offen | 6.13, Status-Block, Nachtrag vom 2026-09-23 — Abnahme erteilt; 6.13 c, Nachtrag vom 2026-09-23 (L12 bis L16) |
| Restbefunde der Abnahme von R3-Q-010, Prüfmittel | Prüfmittel | NEU-1 (Überschreibung am Rückgabewert nicht erkennbar, vor einer Einbindung in die Kette zu neutralisieren), NEU-4 (ungestagte Löschung macht den Lauf rot, die Meldung nennt die Ursache nicht), N-DT-1 (relativer Überschreibungspfad) | offen: nach dem 2026-09-23 in keiner Übergabe mehr geführt, ihr Stand am Prüfmittel ist ungeklärt. Zuständig: Koordinator | 6.13, Status-Block, Nachtrag vom 2026-09-23 — Abnahme erteilt; `docs/uebergaben/2026-09-23_e4-1-pruefmittel-pretooluse-gates.md`; in den Übergaben zu E4.2 und E4.3 als unverändert geführt |
| Posten 3, Register | Prototyp | Posten 3 (L09) hat keinen Registereintrag; der Entscheid des Koordinators vom 2026-10-22 gegen rückwirkende Einträge nennt Posten 1, 2 und 4 | offen: ob L09 einen Eintrag braucht, entscheidet der Vulnerability Manager mit C4 | Übergabe vom 2026-10-22 (Entscheide); `docs/11_Schwachstellenregister.md` |
| Python-Formen, Fallklasse | Prototyp | der Kopfkommentar des Prototyp-Gates nennt die Einschränkung der Python-Formen in Richtung 2 auf die Bauwurzeln backend, frontend und deploy ("bewusst nur die Bauwurzeln"); die Klassenliste im Prüfmittel führt dafür keine eigene Fallklasse "grenze" | offen: Einordnung nach 6.13 d mit C4. Zuständig: Software Architect | 6.13, Status-Block, Nachtrag vom 2026-09-23 — E4.2 gebaut; `.claude/hooks/block-prototype-import.sh` (Kopfkommentar) |
| Fallklassen nach E4.2 | Prüfmittel | Teil B nennt für den Stand nach E4.2 (225 Fälle, 11 Mutationen) keine Zahl der Fallklassen | Tatsache, keine Prüfung offen | 6.13, Status-Block, Nachtrag vom 2026-09-23 — E4.2 gebaut |
| Textbefunde | — | nachrangige Befunde der Textprüfungen: B2-ADR-06 und B2-ADR-14 bis B2-ADR-16 (Übergabe der Einheit vom 2026-10-14); C2-TEXT-SA-01 bis -03 und -06 bis -08 (Werte ohne Fundort, Zuordnung der Preise A139 bis A142 und A149, Zitat der Zeitgrenze, zwei Restpunkte ohne Fundort, Form); am Register C2-TEXT-REG-PO-KOORD-04 bis -06, -08 und -09; C1-PM-PO-CLAUDE-03 und -04 | offen, nachrangig; Teil B bleibt unverändert, eine Berichtigung geht über Teil A oder einen Nachtrag | 6.13 c, Nachtrag vom 2026-10-14; Übergabe vom 2026-10-21 |

Nicht aufgeführt sind die Punkte der beiden Übergaben, die nicht R3-Q-010 betreffen (O-29, R3-Q-005, D20 mit ADR 0002, O-15, `R3-Q-011_regel_im_startkontext`, Terminierung von `Skill`, Berichtigung des Verweises auf den Grundsatz in ADR 0002, 6.1, Absatz "Anlass", Geltungsbereich des Registers, Restpunkte zu PS-1).

### Abnahmen

| Datum | Gegenstand | Merge-Commit | Eintrag in ADR 0002, Abschnitt 10 |
|---|---|---|---|
| 2026-09-22 | Freigabe, keine Abnahme: Umfang von R3-Q-010, Schnitt E4.1 bis E4.3 und Reihenfolge (zweiter Formweg, Weisung im Wortlaut) | — | kein eigener Unterabschnitt; Wortlaut in Teil B, 6.13, Status-Block, Nachtrag vom 2026-09-22 |
| 2026-09-23 | R3-Q-010 im Umfang der drei Übergaben vom 2026-09-23 einschliesslich der Restbefunde, ohne Auflagen (Merge #21); Prüfmittel mit 258 Fällen, 19 Mutationen und 23 Fallklassen | `9a84b9ccd1ecb81b19739f64defc5881e83e2db5` | "Abnahme von R3-Q-010 — E4, die beiden PreToolUse-Gates und ihr Prüfmittel — erteilt und eingetragen am 2026-09-23"; bestätigt durch Merge #23 am 2026-09-24 (`3e5caf71b2bca97b7f9764a19841025875974df7`) |
| 2026-10-16 | Posten 1 (main-Gate, L01 bis L04, Grenzen GM-5 bis GM-8) im Umfang der Übergabe vom 2026-10-14 einschliesslich der Restbefunde (Merge #26) | `5ada002023c0ff160c26c78659727c7e8623c6f5` | "Abnahme von Posten 1 unter R3-Q-010 — main-Gate, L01 bis L04, Grenzen GM-5 bis GM-8 — erteilt am 2026-10-16, eingetragen am 2026-10-21"; bestätigt durch Merge #27 |
| 2026-10-21 | Posten 4 (main-Gate: L17, L19, L21) und Posten 5 (beide Gates: L20, L22, B64, B65) im Umfang der Übergabe vom 2026-10-21 einschliesslich der Restbefunde, Preise und Grenzen (Merge #27) | `998f81d9fffe3970baf870d04e44576eda534fcc` | "Abnahme von Posten 4 und 5 unter R3-Q-010 — main-Gate L17, L19, L21; beide Gates L20, L22, B64, B65 — erteilt am 2026-10-21, eingetragen am 2026-10-21"; bestätigt durch Merge #28 am 2026-10-22 |
| 2026-10-22 | Posten 2, Posten 6 und Teil von Posten 7 am Prototyp-Gate (C3), ohne Kommentare und Reviews (Merge #28) | `95cafc9cc31773a6c29d977ec9c3b97af5a1f047` | "Abnahme von Posten 2, 6 und des Teils von Posten 7 am Prototyp-Gate unter R3-Q-010 — Prototyp-Gate L05 bis L08, L23, L24, eigene Zeitgrenze — erteilt am 2026-10-22, eingetragen am 2026-10-22" |
| 2026-10-26 | Annahme von PS-2 (dieser ADR als eigenes Dokument, Kopf und Teil A) durch Merge des Pull Requests #30, ohne Kommentare und Reviews; nach dem Text des Pull Requests nicht umfasst die Restpunkte in Teil A (Einordnung mit C4) | `80aee8dc978778b9184b9e9639328535f1708264` (Pull Request #30) | "Annahme des Prozess-Schnitts PS-2 (Aufteilung von ADR 0002 in ADR 0003 bis 0005) — Merge des Pull Requests #30 — erteilt am 2026-10-26, eingetragen am 2026-10-26" |

Alle Abnahmen sind über den ersten Formweg erteilt, den Merge des Pull Requests. Was jeweils nicht umfasst ist, nennt der Eintrag in ADR 0002, Abschnitt 10; offen ist, was die Tabelle Posten als offen führt.

---

## Teil B — Entscheidlog

### 6.13 Neunzehnte Fortschreibung vom 2026-09-21 — E4: die beiden PreToolUse-Gates, ihre belegten Lücken und ihr Prüfmittel (R3-Q-010), festgelegt und nicht gebaut

> **Status dieses Abschnitts: Festlegung ohne Bau.** Er ordnet den Backlog-Eintrag
> R3-Q-010 architektonisch ein, entscheidet die Fragen, die der Requirements
> Engineer ausdrücklich dem Software Architect vorgelegt hat, und legt Ort, Form
> und Mass des Prüfmittels fest. Er ist dem Auftraggeber mit der Übergabe vom
> 2026-09-21 vorgelegt; die Freigabe des Umfangs, der Entscheid über den Schnitt
> und der Start der Umsetzung stehen aus. An den beiden Gates, an
> `.claude/settings.json` und am `Makefile` ist in dieser Einheit keine Zeile
> geändert worden.
>
> **Nachtrag vom 2026-09-22 — Freigabe erteilt.** Der Auftraggeber hat den
> Umfang von R3-Q-010 freigegeben und den Schnitt E4.1 bis E4.3 bestätigt, über
> den zweiten Formweg (Weisung an die Sitzung im Wortlaut): "Umfang von
> R3-Q-010 freigegeben, Schnitt E4.1 bis E4.3 bestätigt. Zur Frage nach 3.4
> gilt die Lesart des Koordinators: kein Abbruch. Nächste Einheit: E4.1 bauen.
> Zu C: Das, was richtig ist und Sinn macht." Die Sätze "stehen aus" oben
> bleiben als Stand davor stehen (ADR 0002, 6.1.2). Freigegeben sind damit der
> Umfang nach den Buchstaben a bis f, der Schnitt und die Reihenfolge nach
> Buchstabe g; die nächste Einheit ist der Bau von E4.1. Nicht Gegenstand
> dieser Freigabe: O-28 (bleibt bedingt offen), O-25 (entschieden am 2026-09-03, Abschnitt 8), O-15 und die Freigabe
> des Grundgerüsts. Der Bau selbst hat in dieser Einheit nicht begonnen; an
> den beiden Gates und am `Makefile` ist für E4 weiterhin keine Zeile
> geändert. Die Änderung an `.claude/settings.json` vom 2026-09-22 betrifft
> allein den Starthook zu E-E (ADR 0002, Abschnitt 10, Nachtrag vom
> 2026-09-22), nicht die beiden `PreToolUse`-Gates. Der Satz "Zur Frage nach
> 3.4" bezieht sich auf die Zählfrage der Übergabe vom 2026-09-21 und ist dort
> beziehungsweise in der Übergabe vom 2026-09-22 festgehalten, nicht hier.
>
> **Nachtrag vom 2026-09-23 — E4.1 gebaut.** Das Prüfmittel
> `scripts/pretooluse-gates-selbsttest.sh` besteht jetzt; Form 1 bis 6 aus
> Buchstabe d sind umgesetzt. Es führt 202 Fälle mit Kennung, Gate, Werkzeug,
> Eingabe, Soll, Ist, Urteil, Klasse und Vermerk (main-Gate 62 mit Soll 2 und
> 50 mit Soll 0, Prototyp-Gate 39 und 51), darunter die 37 Proben vom 2026-09-21 unter
> ihren Kennungen (G04 mit Soll 2), die zehn Zusatzfälle als ZF1a bis ZF10d,
> die rekonstruierbaren Klassen vom 2026-08-25 (die einzelnen 29 und 18
> Proben sind nicht überliefert) und je Fallklasse der Kopfkommentare
> mindestens einen Fall (15 Klassen, einmal abgezählt und fest im Skript
> geführt, eine davon die im Rumpf des main-Gates benannte bewusste Grenze
> aus Buchstabe c). Die Kopfzeile nennt den Commit der Klone und je Gate den
> SHA-256-Präfix; die Unverändertheit des Arbeitsbaums wird im Lauf gemessen.
> Der Modus `--mutationen` prüft nach einer Grundlinie zehn Mutationen, fünf
> je Gate (MM1 bis MM5, MP1 bis MP5). Die Annahme "einstellig" aus
> Buchstabe d ist damit um eins überschritten; die Mutationen bleiben
> trotzdem im Skript, und eine eigene Datei entsteht weiterhin nicht: Zehn
> Zeilen im Datenteil sind lesbar, und MM5, nach Runde 1 als zehnte
> hinzugekommen, setzt die ST-01-Behebung zurück und ist die einzige
> Mutation, die den Fremdbeleg von ST-01 trägt. Die offenen Lücken ST-04,
> ST-05, ST-09, ST-13 und P-01 stehen nach Buchstabe g als Klasse "belegte
> Lücke" mit dem heute gemessenen Rückgabewert 0 als Soll (28 Fälle), nach
> dem Wortlaut der Abnahmekriterien auch die Python-Modul-, Funktions- und
> Punktform in Richtung 2 (B35, B41, B42, Klasse P-01) und der
> Rückstrich-Pfad (ZF5e, ST-04), die Buchstabe b nicht einzeln nennt; sie
> gehören zu E4.2. Als Prüfstand, mit dem heutigen Stand als Soll und ohne
> Befund, stehen ZF9 und ZF10a bis ZF10d (Nummer 9 und 10 aus Buchstabe d),
> ZF2a (die Subshell mit Klammer wird heute erkannt), ZF7b (`perl -e` wird
> nur wegen des Zeichens `>` erkannt) und L01 bis L04 (DT-E41-04), vier vom
> Dynamic Software Tester belegte neue Lücken am main-Gate ausserhalb der
> Befunde aus Buchstabe b. Was aus diesen Fällen folgt, ist hier **nicht**
> entschieden; eine Aufnahme von L01 bis L04 in R3-Q-010 geht nur als
> Fortschreibung dieses Abschnitts nach Buchstabe c.
> **Präzisierung zu Buchstabe d Punkt 2** (Befund N-11 der statischen
> Prüfung): Die Wendung "gegen einen Wegwerf-Klon auf main" heisst gegen
> Wegwerf-Klone: einer auf main, einer auf master, ein zweiter main-Klon als
> Ziel von Kontextwechseln und einer auf einem Arbeitszweig für Gegenproben
> und für Fälle, in denen die Sperre "Push bei HEAD auf main" die
> Zielprüfung überdecken würde; die benannte Grenze ausserhalb eines
> Repositories (ZF4a, ZF4b) läuft gegen ein Wegwerfverzeichnis ohne
> Repository. Kein main-Fall läuft gegen den echten Arbeitsbaum. Anlass ist
> Befund B-1/DT-E41-01: Die ST-01-Fälle waren im main-Klon nicht
> trennscharf. Dieselbe Schwäche trug die Belegspalte zu ST-01 in
> Buchstabe b ("Proben A01 bis A06 je Rückgabewert 2"); der Satz bleibt
> stehen, den Fremdbeleg tragen jetzt A38 bis A42 im Arbeitszweig-Kontext
> und die Mutation MM5, die A38 bis A41 fallen lässt. Das ist eine
> Präzisierung, keine Abweichung. Verifikation nach Buchstabe f Punkt 4:
> Static und Dynamic Software Tester auf einem anderen Modell als die
> Umsetzung, Runde 1 je mit demselben blockierenden Befund, Behebung,
> Nachprüfung bestanden (statisch und dynamisch, beide Kriterien, Stand
> c992f38b25e9019e; danach nur Textkorrekturen, Stand 7227f22986621f95);
> beide Stände sind SHA-256-Präfixe des Skripts, keine Commits, und am
> zweiten sind beide Modi erneut grün, gelaufen durch den Koordinator.
> Abgeschlossen sind `R3-Q-010_pruefmittel_je_gate` und
> `R3-Q-010_main_gate_fremdbelegt`. An den beiden Gates, am `Makefile` und
> an der Kette ist keine Zeile geändert; die beiden Ausnahmezeilen in
> `scripts/belege-ausnahmen.txt` sind entfernt, die Hook-Regel ist ergänzt
> (Buchstabe h). Beleg, Protokoll und nicht blockierende Restbefunde:
> `docs/uebergaben/2026-09-23_e4-1-pruefmittel-pretooluse-gates.md`.
> Nächste Einheit: E4.2.
>
> **Nachtrag vom 2026-09-23 — E4.2 gebaut.** Die belegten Lücken ST-04,
> ST-05 und P-01 am Prototyp-Gate `.claude/hooks/block-prototype-import.sh`
> sind geschlossen. Richtung 1 erkennt den Verzeichnisimport ohne
> Schrägstrich und den Rückstrich-Pfad: Das Muster lässt hinter "prototype"
> Schrägstrich, Rückstrich oder schliessendes Anführungszeichen zu;
> "prototypes", "prototyp" und "prototype_alt" treffen weiterhin nicht.
> Richtung 2 erkennt den Präfix `./` vor `../`, die HTML-Formen `src=` und
> `href=` und die Python-Formen (Modul-, Punkt- und Funktionsform), letztere
> bewusst nur für die Bauwurzeln `backend`, `frontend` und `deploy`, nicht
> für die generischen Verzeichnisnamen der Richtung 2, weil "import app" in
> einem Python-Prototyp ein Fehlalarm wäre (Begründung im Rumpfkommentar des
> Gates). Die Verzeichnisliste der Richtung 2 ist einmal als Variable
> `WURZELN` definiert, damit die Mutation MP3 eindeutig bleibt. Die Meldungen
> nennen jetzt die Richtung ("Richtung 1 (Produktionscode -> Prototyp)",
> "Richtung 2 (Prototyp -> Produktionscode)") und weiterhin 5.6.
> Vorgehen nach Buchstabe g belegt: Das Soll der 16 Fälle stand zuerst auf 2
> — der Lauf fiel mit genau diesen 16 Fällen —, dann folgte das Gate, dann
> die Entfernung der Befundkennung aus dem Vermerk. Dazu kommen 22 neue Fälle
> aus den Prüfrunden (B43 bis B51 und ZF6f blockierend, P27 bis P32 als
> Gegenproben gegen Fehlalarme, L05 bis L11 als Prüfstand). Das Prüfmittel
> führt jetzt 225 Fälle; die Zeile "belegte Lücken" nennt nur noch die zwölf
> Fälle von ST-09 und ST-13 (E4.3). Beide Modi enden mit Rückgabewert 0, elf
> Mutationen erkannt (MP1 und MP3 angepasst, MP6 neu an der Meldung). Bei
> Soll 2 prüft das Prüfmittel jetzt auch die Meldung (5.6 beziehungsweise
> 3.2 c, bei Dateiwerkzeugen des Prototyp-Gates die Richtung).
> **Lesart des Koordinators, hiermit festgehalten:** "Bezugsform" im
> Kriterium Richtungsgleichheit ist das Konstrukt (from/import, `require(`,
> `import(`, `@import`, `src=`, `href=`, Python-Formen). Die
> Pfadschreibweise ist in Richtung 1 bewusst weiter (prototype/ ist ein
> bestimmter Name) und in Richtung 2 präfixgebunden (die Produktionswurzeln
> sind generische Namen; ein Vorspann wie mock/backend/ im Prototyp wäre ein
> Fehlalarm). Wurzelpfade und beliebige Vorspanne in Richtung 2 (L10, L11),
> vier symmetrische Lücken beider Richtungen (Leerraum vor der Klammer,
> `@import url(`, Leerraum um das Gleichheitszeichen, `__import__` ohne
> Punkt; L05 bis L08) und ein nicht bereinigter Dateipfad (L09) stehen als
> Prüfstand; ihre Aufnahme ist nach Buchstabe c eine Fortschreibung dieses
> Abschnitts und hier **nicht** entschieden. Verifikation nach Buchstabe f
> Punkt 4: Static und Dynamic Software Tester auf einem anderen Modell als
> die Umsetzung, Runde 1 mit je einem blockierenden Befund, Behebung,
> Nachprüfung bestanden (statisch und dynamisch, beide Kriterien, Stand des
> Gates bf803ef96806c416, des Prüfmittels 01c01113e4f79150); danach nur Text,
> beide Modi erneut grün, Stand des Gates fb13fb2a3054dc7d, des Prüfmittels
> b8079eab3ceefa3f (SHA-256-Präfixe, keine Commits). Abgeschlossen sind
> `R3-Q-010_prototyp_gate_pfadformen` und
> `R3-Q-010_prototyp_gate_richtungsgleichheit`. Die Tabelle in Buchstabe b
> bleibt als Stand vom 2026-09-21 stehen; der Stand "offen" gilt für ST-04,
> ST-05 und P-01 seit diesem Nachtrag nicht mehr. Der Kopfkommentar des
> Gates ist nachgeführt (Buchstabe e). Am main-Gate, am `Makefile` und an
> der Kette ist keine Zeile geändert. Beleg, Protokoll und nicht
> blockierende Restbefunde:
> `docs/uebergaben/2026-09-23_e4-2-prototyp-gate-erkennungsluecken.md`.
> Nächste Einheit: E4.3 (ST-09, ST-13, benannte Grenzen, P-10).
>
> **Nachtrag vom 2026-09-23 — E4.3 gebaut.** ST-09 ist geschlossen: Das
> Prototyp-Gate führt bei Bash dieselbe Befehlsklassenliste als
> Schreibwirkung wie das main-Gate (Interpreter mit Inline-Code,
> Dateiwerkzeuge, ed/ex) und blockiert weiterhin nur zusammen mit einem
> Importmuster. ST-13 ist nach Buchstabe b geschlossen: Beide Gates
> blockieren eine Eingabe, die kein JSON-Objekt mit einem Objekt
> `tool_input` ist, mit Rückgabewert 2, leerer Standardausgabe und einer
> Meldung, die Anfang und Länge der Eingabe nennt. Benannte Grenzen: Die
> Nichtprüfung gemeinsamer Abhängigkeiten (P-10) steht als Grenze im
> Kopfkommentar des Prototyp-Gates (Fallklasse GP-1, durchlaufender Fall
> P35). Die Subshell-Grenze des main-Gates ist präzisiert: Eine Subshell in
> Klammern wird erkannt (ZF2a), Grenze ist der untergeordnete Shell-Aufruf
> (ZF2b, ZF2c). Die übrigen Grenzen (Interpreter mit Skriptdatei, zweiter
> Arbeitsbaum ausserhalb der Sitzung, ausserhalb eines Repositories) bleiben
> gemessen. Das Prüfmittel führt 247 Fälle (main-Gate 67 mit Soll 2 und 47
> mit Soll 0, Prototyp-Gate 82 und 51), 15 Mutationen und 22 Fallklassen;
> die Zeile "belegte Lücken" lautet "keine". Kein Vermerk "belegte Lücke"
> verbleibt; nach Buchstabe g wäre ein verbliebener Vermerk ein offener
> Befund, und es verbleibt keiner. Die Prüfstand-Fälle (ZF9, ZF10a bis
> ZF10d, L01 bis L11) stehen weiter mit dem heutigen Wert; ihre Aufnahme ist
> nach Buchstabe c **nicht** entschieden. Verifikation nach Buchstabe f
> Punkt 4: je eine statische und eine dynamische Runde mit vier
> beziehungsweise fünf Befunden (B-1 bis B-4, DT-E43-1 bis DT-E43-5), alle
> behoben und je einmal nachgeprüft, alle drei Kriterien bestanden.
> DT-E43-6/N-1 (die Ausnahme flüchtiger Ziele greift in beiden Gates auch
> bei "/tmp/..", "$TMPDIR/.." und "/dev/nullx") ist als offener Restbefund
> im Kopfkommentar und in der Übergabe geführt, nicht als benannte Grenze.
>
> **Nachtrag vom selben Tag (E4.3-Nachtrag, Aufgabe #4):** DT-E43-6/N-1 und
> N-3 sind behoben, dazu der bei der Prüfung der Behebung gefundene DT-E43-8
> (ein Trenner samt Schreibverb direkt hinter einem flüchtigen Ziel wurde
> mitverschluckt, vorbestehend in beiden Gates): ein Umleitungsziel mit ".."
> fällt in beiden Gates nicht mehr unter die Ausnahme flüchtiger Ziele,
> "/dev/null" nur mit Wortgrenze, Trenner beenden das Ziel; die Ausnahme ist
> in beiden Gates textgleich. Prüfmittel danach 258 Fälle, 19 Mutationen (neu
> MM7/MP10 für die Ausnahme, MM8/MP11 für "length == 1"), 23 Fallklassen (neu
> KM-12); Vorgehen nach Buchstabe g, eine dynamische Runde auf einem anderen
> Modell mit gezielter Nachmessung, bestanden (Übergabe E4.3, Abschnitt
> "Nachtrag").
>
> Abgeschlossen sind `R3-Q-010_prototyp_gate_schreibwirkung`,
> `R3-Q-010_gates_unlesbare_eingabe` und `R3-Q-010_benannte_grenzen`; damit
> sind alle sieben Abnahmekriterien von R3-Q-010 gebaut und verifiziert. Die
> Abnahme des Eintrags liegt beim Auftraggeber (Merge des Pull Requests,
> Formweg 1 nach Abschnitt 10). Die Tabelle in Buchstabe b bleibt als Stand
> vom 2026-09-21 stehen; der Stand "offen" gilt für ST-09 und ST-13 seit
> diesem Nachtrag nicht mehr. Am `Makefile`, an `.claude/settings.json` und
> an der Kette ist keine Zeile geändert. Beleg, Protokoll und nicht
> blockierende Restbefunde:
> `docs/uebergaben/2026-09-23_e4-3-raender-st-09-st-13-grenzen.md`.
> Nächste Einheit nach Buchstabe g: E3 (eigene Festlegungseinheit), dann
> Grundgerüst.
>
> **Nachtrag vom 2026-09-23 — Abnahme erteilt.** Der Auftraggeber hat
> R3-Q-010 über den ersten Formweg abgenommen: Merge des Pull Requests #21
> (Arbeitszweig claude/happy-johnson-t0yqlo) am 2026-09-23 um 12:47:58 UTC
> durch das Konto des Repository-Eigentümers, Merge-Commit
> `9a84b9ccd1ecb81b19739f64defc5881e83e2db5`, unverändert gemergt, ohne
> Kommentare, ohne Reviews und **ohne Auflagen**. Den Umfang bestimmt der Text
> des Pull Requests, im Wortlaut: "Abnahme von R3-Q-010 im Umfang der drei
> Übergaben vom 2026-09-23 einschliesslich der dort benannten Restbefunde
> (erster Formweg, ADR 0002, Abschnitt 10)." Die drei Übergaben sind
> `docs/uebergaben/2026-09-23_e4-1-pruefmittel-pretooluse-gates.md`,
> `docs/uebergaben/2026-09-23_e4-2-prototyp-gate-erkennungsluecken.md` und
> `docs/uebergaben/2026-09-23_e4-3-raender-st-09-st-13-grenzen.md`. Als
> Restbefunde, nicht behoben, nennt der Pull Request DT-E43-4 (`deno eval`,
> `node --eval` und `bun -e` an beiden Gates nicht erkannt, Parität besteht),
> den Preis P38 und aus E4.1 und E4.2 NEU-1, NEU-4, N-DT-1, R-1/E-1 und
> DST-E42-N1, dazu die Prüfstand-Fälle zur Entscheidung als Fortschreibung von
> ADR 0002, 6.13 c; nicht Gegenstand sind E3, das Grundgerüst, R3-Q-005 und
> D20 (ADR 0002, O-15). Zugehöriger Merge im Methodik-Repository: Pull Request
> #12, Merge-Commit `cb838ecd35baba30fb04ab64300e501ab55ed0b6`, 2026-09-23,
> 12:48:24 UTC. Eingetragen auf Weisung des Sitzungsauftrags vom 2026-09-23
> (zweiter Formweg); den Abnahmeeintrag in ADR 0002, Abschnitt 10 schreibt der
> Protocol Master. Die Aussage im Nachtrag zu E4.3 oben, die Abnahme des
> Eintrags liege beim Auftraggeber, bleibt als Stand davor stehen
> (ADR 0002, 6.1.2). Die Prüfstand-Fälle ZF9, ZF10a bis ZF10d und L01 bis L16
> sind auf Weisung vom 2026-09-23 (Entscheid 2 des Auftraggebers) in
> ADR 0002, 6.13 c fortgeschrieben (Nachtrag vom 2026-09-23, siehe dort):
> L01 bis L09 als belegte Lücken in drei Posten unter R3-Q-010, ZF10a, ZF10b,
> ZF10d und L10 bis L16 als Grenze, ZF9 und ZF10c als gewolltes Verhalten.
> Die Posten sind neue Arbeit an den Gates, keine Nacharbeit am abgenommenen
> Umfang. An den beiden Gates, am Prüfmittel, am `Makefile` und an
> `.claude/settings.json` ist in dieser Einheit keine Zeile geändert. Nächste
> Einheit: E3 als neuer Backlog-Eintrag auf die Definition of Ready (Kennung
> vergibt der Requirements Engineer in Schritt 2 dieser Sitzung; Einordnung
> als ADR 0002, 6.14), kein Bau; danach E3, dann Grundgerüst.
>
> **Nachtrag vom 2026-10-14 — Posten 1 gebaut.** Posten 1 unter R3-Q-010
> (main-Gate, L01 bis L04; Festlegung in ADR 0002, 6.13 c, Nachtrag vom
> 2026-09-23, Absatz "Die drei Posten unter R3-Q-010") ist gebaut, in drei
> Baurunden des SecDevOps Engineers: dem Bau und zwei Behebungen nach den
> ersten beiden Verifikationsrunden. Der Sitzungsauftrag des Auftraggebers vom
> 2026-10-14 (zweiter Formweg; eingetragen am 2026-10-14 in `CLAUDE.md`,
> Statuszeile, und in ADR 0002, 6.14, Status-Block, Nachtrag vom 2026-10-14)
> sieht die drei Posten je als eigene Einheit vor; gebaut ist in dieser
> Sitzung nur Posten 1 (siehe unten). Die Einordnungen der Befunde nach dem Massstab des Nachtrags vom
> 2026-09-23 stehen in ADR 0002, 6.13 c, Nachtrag vom 2026-10-14.
>
> **Gate** (`.claude/hooks/block-main-write.sh`). Neu ist cmd_ziel, der
> Befehlstext nach vier lexikalischen Schritten in dieser Reihenfolge:
> (1) die Zeilenfortsetzung entfernt — das Paar aus Rückstrich und
> Zeilenumbruch, wenn vor dem Zeilenumbruch eine ungerade Zahl von
> Rückstrichen steht; (2) Rückstriche entfernt, das Folgezeichen bleibt;
> (3) ein Dollarzeichen unmittelbar vor einem Anführungszeichen entfernt;
> (4) alle einfachen und doppelten Anführungszeichen entfernt. Die Funktion
> ziel_hat prüft ein Muster gegen den Befehlstext oder gegen cmd_ziel. Posten 1
> kann damit nur Sperren hinzufügen, keine lösen: Kein vor Posten 1
> blockierter Befehl wird frei; das ist die Gegenseite des Regressionsschutzes
> nach ADR 0002, 6.13 f, Punkt 2, der die heute grünen Gegenproben schützt,
> und im Prüfmittel mit A65, A66 und A74 bis A76 gemessen. Beides gilt nur für die Zielmuster von push
> und `worktree add` und für den Namen hinter -b/-B; das Verb (push,
> `worktree add`), die Sammel-Push-Optionen und die Ausnahme für -b/-B liest
> das Gate weiterhin am Befehlstext (DT-B2-01, DT-B2-02, siehe unten). Vor der
> worktree-Sperre steht eine neue Prüfung: Das Muster
> `-[a-zA-Z]*[bB][[:space:]]*(main|master)`, gefolgt von Leerraum, Zeilenende
> oder einem der Zeichen `;`, `&`, `|` und `)`, ergibt auf cmd_ziel
> Rückgabewert 2 mit der Meldung "BLOCKIERT (Projektauftrag 3.2 c): neuer Zweig
> main/master in einem zweiten Arbeitsbaum." Sie erfasst -B main, -Bmain,
> -bmain, -fBmain und -qbmaster; -Bbmain wird als Preis in sicherer Richtung
> mitgesperrt; die Ausnahme selbst (Muster `-[bB]([[:space:]]|=)`) ist nicht
> verbreitert. Der Rumpfkommentar zur Ausnahme ist nachgeführt.
>
> Der Kopfkommentar trägt einen Absatz "Seit Posten 1 (2026-10-14, ADR 0002,
> 6.13 c) gilt zusaetzlich: ..." (Ziele nach dem Entfernen von
> Anführungszeichen, Rückstrichen, Zeilenfortsetzungen und Dollarzeichen vor
> Anführungszeichen verglichen; die Ausnahme greift nicht für main oder
> master, getrennt oder angehängt; der Schritt ist rein lexikalisch; Verb,
> Sammel-Push-Optionen und Ausnahme am Befehlstext) und vier benannte
> Grenzen, je mit einer Fallklasse vom Typ "grenze": GM-5, die Grenze der
> Auswertung (Variable, Befehlssubstitution, eval, Brace-Expansion,
> Escape-Folgen in `$'...'`, die Übersetzung von `$"..."` über einen
> Meldungskatalog); GM-6, die Grenze an der Schnittstelle (Werkzeugname), wie
> im Nachtrag vom 2026-09-23 für ZF10a und ZF10b verlangt; GM-7, die Grenze
> der Ausnahme für -b/-B, mit dem Preis in sperrender Richtung; GM-8, die
> Grenze am Befehlstext (Verb und Sammel-Push-Optionen). Die Deckungsaussage
> aus dem Stand vor Posten 1 steht wortgleich; ihr folgt ein datierter
> Nachtrag, der für das Anlegen eines Arbeitsbaums auf main und für
> Mirror-/Wildcard-Pushes die Grenzen und die offenen Posten nennt.
>
> **Prüfmittel** (`scripts/pretooluse-gates-selbsttest.sh`). Vor Posten 1
> 258 Fälle, 19 Mutationen (MM1 bis MM8, MP1 bis MP11) und 23 Fallklassen;
> nach der ersten Baurunde 269, 22 und 26; nach der zweiten 309, 26 und 27;
> mit der dritten 318 Fälle, 26 Mutationen und 28 Fallklassen (neu KM-13,
> gedeckt, sowie GM-5, GM-6, GM-7 und GM-8 vom Typ "grenze"; 21 am main-Gate,
> 7 am Prototyp-Gate). L01 bis L04 laufen mit Soll 2 und der Klasse
> "blockierend"; ihr Vermerk nennt die Schliessung am 2026-10-14 und führt den
> früheren Wortlaut als Nachtrag hinter "vormals Pruefstand: ". Neu am
> main-Gate sind A54 bis A79 (Soll 2), G43 bis G71 (Soll 0, durchlaufend oder
> Grenze), L18 (`git worktree add -B $'main' /tmp/wt`, Soll 2, blockierend)
> sowie L17, L19, L20 und L21 (Soll 0, belegte Lücke; Posten 4 und Posten 5,
> siehe unten). ZF10a und ZF10b tragen die Klasse "grenze" (Soll 0); ihr
> früherer Vermerk ist wiederhergestellt, ein datierter Nachtrag "vormals
> Pruefstand" steht davor. Die 15 Prüfstand-Fälle am Prototyp-Gate tragen die
> Klasse aus der Spalte "Folge" des Nachtrags vom 2026-09-23 (Vollzug in
> ADR 0002, 6.13 c, Nachtrag vom 2026-10-14); P38 bleibt "pruefstand". Am
> Prototyp-Gate selbst ist keine Zeile geändert.
>
> Neu sind die Mutationen MM9 bis MM15, je mit ihrem Mindestsatz: MM9 setzt
> den Schritt für die Anführungszeichen ausser Kraft (L01, L03, A54, L04),
> MM10 den Schritt für die Rückstriche (L02, A55, A67), MM11 die Prüfung für
> -b/-B (L04, A56, A57); MM12 legt die Ausnahme wieder auf cmd_ziel (A58,
> A75); MM13 lässt den Namen hinter -b/-B nur getrennt und ohne Buchstaben
> davor zu (A59, A60, A61, A73); MM14 setzt den Schritt für die
> Zeilenfortsetzung ausser Kraft (A62, A63, A64), MM15 den Dollar-Schritt
> (L18, A69, A70, A71, A72). Der Mindestsatz von MM5 ist auf A40 und A41
> gekürzt; A38 und A39 fallen bei MM5 nicht mehr, weil cmd_ziel die
> Anführungszeichen deckt. Nach der zweiten Baurunde führen die Listen der
> Abnahmekriterien im Prüfmittel MM9 bis MM15
> (`R3-Q-010_pruefmittel_je_gate`) und KM-13, GM-5, GM-6 und GM-7
> (`R3-Q-010_benannte_grenzen`).
>
> **Läufe nach ADR 0002, 6.13 g** (Soll zuerst auf 2). Erste Baurunde: Lauf 1
> (05:31 UTC) gegen das Gate vor Posten 1, Rückgabewert 2, gefallen A54, A55,
> A56, A57, L01, L02, L03 und L04; nach der Änderung am Gate Lauf 2 im
> Normalmodus 269 von 269 und Lauf 3 im Mutationsmodus 22 von 22, je
> Rückgabewert 0. Zweite Baurunde: Lauf 4 (10:21 UTC) mit allen neuen Fällen
> gegen das Gate der ersten Baurunde, Rückgabewert 2, gefallen A58 bis A64 und
> G55 bis G58 (die Fehlalarme der ersten Fassung, Soll 0, gemessen 2);
> Lauf 4b (10:24 UTC, nach Aufnahme der Fälle zu DT-B2-07), Rückgabewert 2,
> zusätzlich gefallen A69 bis A73 und L18; nach der Änderung am Gate Lauf 5
> (10:35 UTC) im Normalmodus 309 von 309 und Lauf 6 (10:39 UTC) im
> Mutationsmodus 26 von 26, je Rückgabewert 0. Der Lauf ändert keine
> versionierte Datei. `make dod` nach dem Bau (10:39 UTC): D7, D10 und D12
> Lage C, terminiert; D20 und D11 `A_OK`; D19 `OHNE_BEFUND`; Rückgabewert 2,
> die erwartete Form. Dritte Baurunde, die am Gate nur Kommentare ändert:
> Lauf 7 (11:47 UTC, neues Prüfmittel gegen das Gate vor den
> Kommentaränderungen) 318 von 318, Rückgabewert 0, die neun neuen Fälle mit
> heutigem Wert; Lauf 8 (11:48 UTC) 318 von 318 und Lauf 9 (12:00:44 bis
> 12:05:05 UTC) im Mutationsmodus 26 von 26, Arbeitsbaum unverändert, je
> Rückgabewert 0; `make dod` (11:58 UTC) in der erwarteten Form. Zwei frühere
> Mutationsläufe (11:48 und 11:53 UTC) erkannten je 26 von 26 und endeten mit
> Rückgabewert 2 ("VERLETZT -- Arbeitsbaum hat sich waehrend des
> Mutationslaufs veraendert"), weil bis 11:55:01 UTC im selben Arbeitsbaum an
> diesem Nachtrag geschrieben wurde.
>
> **Verifikation** nach ADR 0002, 6.13 f, Punkt 4, durch Static und Dynamic
> Software Tester auf einem anderen Modell als die Umsetzung; der Dynamic
> Software Tester mit dem Prüfmittel in beiden Modi, einem eigenen Korpus von
> 47 Befehlen gegen altes und neues Gate, Proben mit echtem git in
> Wegwerf-Klonen und eigenen Mutationen. **Runde 1: nicht bestanden**, mit
> zwei blockierenden Befunden beider Prüfrollen (DT-B2-01, DT-B2-02) und vier
> weiteren blockierenden Befunden des Static Software Testers am Prüfmittel
> (B2-PM-03 bis B2-PM-06). DT-B2-01: In der ersten Fassung liefen das
> Verb (push, `worktree add`) und die Sammel-Push-Optionen über cmd_ziel;
> daraus entstand eine neue Klasse von Fehlalarmen — etwa
> `git log --all --grep "push"`, `git log -S "git push" --oneline main` und
> `git commit -m "push main"`, vor Posten 1 mit Rückgabewert 0, in der ersten
> Fassung mit 2 —, genau der Vorbehalt des Nachtrags vom 2026-09-23.
> DT-B2-02: Die Ausnahme für -b/-B lief in der ersten Fassung auf cmd_ziel,
> maskierte Leerzeichen im Pfad wurden zu " -b ";
> `git worktree add /tmp/a\ -b\ x main` gab vor Posten 1 Rückgabewert 2, in
> der ersten Fassung 0, und mit echtem git entsteht der Arbeitsbaum auf main —
> eine Regression. Der Static Software Tester hat dieselben zwei Befunde am
> Gate gefunden (B2-GATE-01, B2-GATE-02), dazu am Prüfmittel B2-PM-01 bis
> B2-PM-06 (B2-PM-01 und B2-PM-02 sind am Prüfmittel dieselben Sachverhalte
> wie DT-B2-02 und DT-B2-01). Behoben in der zweiten Baurunde: Verb,
> Sammel-Push-Optionen und
> Ausnahme zurück auf den Befehlstext, denn die Festlegung verlangt den
> bereinigten Vergleich nur für die Ziele; die nachrangigen Befunde beider
> Prüfrollen sind eingearbeitet, unter anderem DT-B2-06 (Gegenproben mit
> Rückstrich G52, G53, G54 und A67).
>
> **Runde 2: dynamisch bestanden, statisch nicht bestanden.** Der Dynamic
> Software Tester hat die drei Kriterien erfüllt gefunden: L01 bis L04
> blockieren; der Regressionsschutz ist grün (alle 72 Fälle des main-Gates
> mit Soll 0 grün, unter 134 geprobten Formen keine von alt 2 auf neu 0);
> keine neue Fehlalarmklasse (K31 bis K39 je 0, alle 43 Formen mit alt 0 und
> neu 2 gehören lexikalisch zu Posten 1); 309 von 309 Fällen und 26 von 26
> Mutationen. Seine eigene Mutation V4 (Dollar-Schritt entfernt) lässt genau
> A69, A70, A71, A72 und L18 fallen; `POSIXLY_CORRECT=1` ändert keinen
> Rückgabewert. Nicht geprüft hat er die Wirkung im laufenden Harness (die
> Hooks wirken in dieser Sitzung nicht) und echtes git für -qbmaster und für
> die Formen von DT-B2-09. Zwei nachrangige, vorbestehende Lücken ausserhalb
> von Posten 1 hat er zur Einordnung vorgelegt, DT-B2-08 und DT-B2-09. Der
> Static Software Tester hat am Prüfmittel B2-PM-13 (Vermerke L01 bis L04
> überschrieben statt als Nachtrag geführt), B2-PM-14 (Fehlalarm über
> cmd_ziel, eingeordnet als Preis in sperrender Richtung) und B2-PM-15 (der
> Text der Fallklasse GM-5 nannte die Übersetzung von `$"..."` über einen
> Meldungskatalog nicht, ohne Fall) gefunden, am Gate B2-GATE-D01
> (Deckungsaussage im Kopfkommentar umgeschrieben statt datiert nachgetragen;
> in der Gegenprüfung widerlegt, weil kein Wort verloren ging, vom
> Koordinator nach der Checkliste 5.3 des Sitzungsauftrags dennoch in die
> Nachtragsform gebracht) und B2-GATE-D02 (die Fundorte "ADR 0002, 6.13 c,
> Fortschreibung vom 2026-10-14" und "Posten 4 unter R3-Q-010" fehlten im
> Repository; Fundort ist ADR 0002, 6.13 c, Nachtrag vom 2026-10-14, die
> Aufnahme in den Backlog folgt durch den Product Owner), dazu nachrangig
> B2-GATE-D03 bis B2-GATE-D09. Nach seiner Zählung scheitern B2-PM-13,
> B2-PM-14 und B2-PM-15 zum zweiten Mal am jeweils gleichen Kriterium
> (Projektauftrag 3.4); die dritte Baurunde ist die letzte vor dem Abbruch.
>
> **Dritte Baurunde, Behebung.** Behoben sind B2-PM-13 (Vermerke L01 bis L04
> mit dem früheren Wortlaut hinter "vormals Pruefstand: "), B2-PM-15 (Text der
> Fallklasse GM-5 um den Meldungskatalog ergänzt, Fall G71
> `git push origin $"zweig"` mit Soll 0) und B2-GATE-D01 in der Nachtragsform;
> der Absatz zu GM-7 ist berichtigt (B2-GATE-D06: "benannt seit Posten 1",
> denn die Ausnahme las den Befehlstext schon vor Posten 1) und um den Preis
> in sperrender Richtung ergänzt (B2-PM-14), der Absatz zu GM-8 ist neu (G69,
> G70), dazu L19, L20, L21, A77, A78 und A79; nachrangig B2-PM-16 (A74 als
> Regressionsschutz im Kopfnachtrag) und B2-PM-17 (die Überschrift 11a nannte
> vorher zehn Mutationen); GM-8 steht seither auch in der Liste zu
> `R3-Q-010_benannte_grenzen`. Am Gate ändert diese Runde nur Kommentare,
> kein Verhalten. **Runde 3:** Bestanden haben der Dynamic Software Tester
> (318 von 318, 26 von 26; mit echtem git belegt die Basename-Form und A79;
> nachrangig DT-B2-10, siehe 6.13 c) und der Static Software Tester an Gate
> und Prüfmittel (B2-PM-13 bis B2-PM-15 erfüllt); damit ist Posten 1
> verifiziert. Die statische Prüfung dieses Nachtrags ergab drei blockierende
> Befunde an Zuordnung und Zahlen, in dieser Fassung behoben; die Zeile in
> `CLAUDE.md` hat der Koordinator berichtigt.
>
> **Einordnungen** nach dem Massstab des Nachtrags vom 2026-09-23
> (Erreichbarkeit, Vertrag, Mittel) durch den Software Architect am
> 2026-10-14, auf Vorlage des Koordinators; die Begründungen stehen in
> ADR 0002, 6.13 c, Nachtrag vom 2026-10-14. In Posten 1 geschlossen:
> DT-B2-03 (Wert hinter -b/-B angehängt oder gebündelt), DT-B2-04
> (Zeilenfortsetzung im Ziel) und DT-B2-07 (`-B $'main'`). Grenzen: DT-B2-05 a
> und b (GM-7) und DT-B2-08 (GM-8). Preise in sicherer Richtung: B2-PM-14 mit
> B2-GATE-D03 (GM-7, sperrende Richtung) und B2-GATE-D04. Belegte Lücken, neu
> als Posten: Posten 4 unter R3-Q-010 am main-Gate mit a) Befehlskette
> (DT-B2-05 c, L17), b) Zeilenfortsetzung in den Prüfungen am Befehlstext
> (DT-B2-09, L19) und c) Basename-Form (L21); Posten 5 unter R3-Q-010 an
> beiden Gates, grosse Eingabe (B2-GATE-D05, L20). Beide Posten sind
> vorbestehende Lücken, keine Folge von Posten 1.
>
> **Posten 4 und Posten 5.** Terminierung: mit der nächsten Änderung am
> jeweiligen Gate, spätestens vor der Freigabe des Grundgerüsts. Die
> Einordnung in die Reihenfolge legt der Auftraggeber fest; die Aufnahme in
> den Backlog macht der Product Owner in den Nachführungen dieser Sitzung
> (Backlog, `CLAUDE.md`, Nachweise; Schritt B5 des Sitzungsauftrags vom
> 2026-10-14, festgehalten in der Übergabe der Sitzung). Für Posten 5 empfiehlt der Software Architect dem
> Auftraggeber die Einordnung vor Posten 2 und 3, weil die Lücke jede Prüfung
> beider Gates unabhängig von der Form umgeht und Posten 2 und 3 Prüfstellen
> des Prototyp-Gates mit derselben Bauform ändern. Vor dem Entscheid über die
> Reihenfolge bewertet der Vulnerability Manager Posten 5 nach CVSS, als
> eigener Auftrag; ungeprüft ist, ob `.claude/hooks/dod-gate.sh` dieselbe
> Bauform trägt, das gehört in diese Bewertung. In dieser Einheit ist
> Posten 5 nur erfasst.
>
> Die zwei weiteren Formen aus DT-E41-04 liegen nicht im Fremdbeleg vor; es
> gab nichts zur Einordnung vorzulegen. Die Restpunkte, nicht geschlossen,
> stehen in ADR 0002, 6.13 c, Nachtrag vom 2026-10-14, Absatz "Restpunkte".
> Nicht geändert sind in dieser Einheit das Prototyp-Gate
> (`.claude/hooks/block-prototype-import.sh`), das `Makefile`,
> `.claude/settings.json`, ADR 0001 und der Backlog; den Backlog führt der
> Product Owner in den Nachführungen dieser Sitzung (Backlog, `CLAUDE.md`,
> Nachweise; Schritt B5 des Sitzungsauftrags vom 2026-10-14, festgehalten in
> der Übergabe der Sitzung) nach, die Zeile zu
> `.claude/hooks/block-main-write.sh` in "Aktive Gates" von `CLAUDE.md` der
> Koordinator in dieser Einheit. Abgenommen ist Posten 1 damit nicht: Die
> Abnahme von Posten 1 erteilt der Auftraggeber durch den Merge des Pull
> Requests dieser Sitzung (erster Formweg, ADR 0002, Abschnitt 10). Posten 2
> und 3 werden in dieser Sitzung nicht gebaut (Entscheid des Koordinators nach
> Projektauftrag 3.3: Posten 2 wäre die nächste Änderung am Prototyp-Gate und
> zöge den Teil von Posten 5 dort nach sich, dessen Einordnung der
> Auftraggeber festlegt; die Bewertung nach CVSS und das
> Schwachstellenregister stehen aus); Posten 4 und 5 sind erfasst, nicht
> gebaut; keiner der vier ist von der Abnahme umfasst. Nächste Einheit nach
> dem Entscheid des Auftraggebers über die Einordnung von Posten 4 und 5
> (Empfehlung: Posten 5, dann Posten 2, dann Posten 3), danach O-29, dann
> Grundgerüst. Die Angabe zur nächsten Einheit im Nachtrag vom 2026-09-23
> oben bleibt als Stand davor stehen (ADR 0002, 6.1, Absatz "Anlass").
>
> **Nachtrag vom 2026-10-21 — Abnahme von Posten 1, Weisung vom 2026-10-21, Einordnung von Posten 4 und 5.**
> Die Abnahme von Posten 1 ist am 2026-10-16 erteilt (erster Formweg): Merge des Pull Requests #26 um 05:54:49
> UTC, Merge-Commit `5ada002023c0ff160c26c78659727c7e8623c6f5`, ohne Kommentare und ohne Reviews; eingetragen am
> 2026-10-21 in Abschnitt 10 durch den Protocol Master; der Pull Request #16 des Methodik-Repositories ist am
> 2026-10-21 gemergt (Merge-Commit `44d6c5b5dbc4428d53708e8cfd20d7154e895e9d`).
> Weisung vom 2026-10-21 (zweiter Formweg), im Wortlaut: "Was jetzt? Weitermachen bzw. fortfahren mit dem nächsten? Alles so gemerged wie es soll und bereit für das nächste? Mach einfach das, was richtig ist und gemacht werden soll, ich erlaube es dir."
> Vorangegangen am 2026-10-15, im Wortlaut: "Ich möchte, dass das Ganze effizienter abläuft und nicht unnötig stundenlang irgendwelche Sachen macht, die insgesamt unnötig sind. Verstehst du? Trotzdem, mach keine Annahmen und keine Halluzinationen."
> und "Mach weiter wo du aufgehört hast und bitte nicht so ultra lange, also das muss auch angepasst werden".
> Darauf entscheidet der Koordinator (delegiert; Backlog, offener Punkt 24): (1) Reihenfolge: Posten 5 (beide Gates) vor Posten 2 und 3
> (Empfehlung in Buchstabe c, Nachtrag vom 2026-10-14); Posten 4 (main-Gate, a bis c) mit Posten 5 in einer Einheit (eigener
> Entscheid des Koordinators); dann Posten 2, dann Posten 3, dann O-29, dann die Freigabe des Grundgerüsts durch den Auftraggeber
> (Merge des Pull Requests, dessen Text das sagt), weil Posten 5 jede Prüfung beider Gates umgeht und Posten 4
> mit der nächsten Änderung am main-Gate terminiert ist; (2) CVSS-Bewertung von Posten 5 durch den Vulnerability
> Manager und Anlage des Schwachstellenregisters (Projektauftrag 4.2) in der Einheit, die Posten 5 baut, ohne
> eigenen Vorlauf (Grund: Effizienz, die Einordnung ist mit (1) entschieden); (3) Prüftiefe (fortgeschrieben aus Punkt 5 des Sitzungsauftrags vom
> 2026-10-14): Gates und Prüfmittel weiter durch Static und Dynamic Software Tester auf einem anderen Modell mit Delta-Runden
> bis ohne blockierenden Befund (Projektauftrag 3.4); Texte (ADR-Nachträge, Backlog, `CLAUDE.md`, Übergaben) einmal statisch auf dem anderen
> `model`-Feld, blockierende Befunde mit einer Delta-Runde, nachrangige als Restpunkte ohne weitere Runde;
> Nachträge kurz (ein Absatz je Einheit, keine Tabellen über 50 Zeilen); (4) bis nach der Freigabe des
> Grundgerüsts zurückgestellt (ohne Wirkung auf den Produktaufbau): Terminierung von `Skill` in dreizehn Werkzeuglisten (ADR 0002, 6.14 e)
> und Berichtigung des Verweises "(ADR 0002, 6.1.2)" an bestehenden Stellen; die Gegenprobe zu `R3-Q-011_regel_im_startkontext` bleibt
> beim Auftraggeber, das Kriterium offen; (5) Arbeitszweig ccr-0cbb4387-oe1i3c in beiden Repositories am
> 2026-10-21 nach den Merges neu von origin/main gesetzt (nur gemergte Historie). Empfehlung und CVSS-Bewertung
> vor dem Entscheid im Nachtrag vom 2026-10-14 bleiben als Stand davor stehen (ADR 0002, 6.1, Absatz "Anlass").
>
> **Nachtrag vom 2026-10-21 — Posten 4 und 5 gebaut, Posten 6 und 7 erfasst.**
> In der Einheit C2 der Sitzung vom 2026-10-21 (Entscheid 1 oben) hat der SecDevOps Engineer Posten 5 an beiden Gates und Posten 4 a bis c
> am main-Gate gebaut; geändert sind nur `.claude/hooks/block-main-write.sh`, `.claude/hooks/block-prototype-import.sh` und
> `scripts/pretooluse-gates-selbsttest.sh`. Posten 5: Jede Prüfung mit `grep -q` läuft je Gate über die Hilfsfunktion `trifft`, die den Status
> aus PIPESTATUS liest; ein Abbruch des Schreibers gilt nie als kein Treffer, und kann eine Prüfung nicht laufen, endet das Gate mit 2.
> Posten 4: Die Ausnahme für -b/-B gilt nur für ihren Abschnitt (a), Verb, Sammel-Push-Optionen, Ausnahme und Abschnitte werden ohne
> Zeilenfortsetzungen geprüft (b), und die Basename-Form `git worktree add <pfad>/main` sperrt, geprüft auf zwei Fassungen (c). Geschlossen
> sind L17, L19, L20, L21 und am Prototyp-Gate L22 (Soll 2; L20 und L22 in 30 von 30 Läufen). Mit dem Bau behoben sind die quadratische
> Laufzeit der Entfernung der Zeilenfortsetzungen (DT-C2-01, vorbestehend seit Posten 1, Durchlass ab etwa 150 KB), zwei neue
> Fehlalarmklassen der ersten Fassungen (ST-C2-02, ST-C2-D-07), zwei Lücken späterer Fassungen der Basename-Prüfung (DT-C2-E-01, ST-C2-F-01)
> und die Abhängigkeit beider Gates von der Umgebungsvariablen POSIXLY_CORRECT (ST-C2-D-01). Das Prüfmittel steht nach 318 Fällen,
> 26 Mutationen und 28 Fallklassen bei 447, 49 und 36 (main-Gate 298 Fälle, 182 mit Soll 2 und 116 mit Soll 0; Prototyp-Gate 149, 93 und
> 56); Lauf B und Lauf C (`--mutationen`, 49 von 49 erkannt) je Rückgabewert 0, Arbeitsbaum unverändert; `make dod` Rückgabewert 2 wie
> vorher (Lagen C bei D7, D10 und D12, terminiert; D19 ohne Befund). Verifikation nach ADR 0002, 6.13 f, Punkt 4, durch Static und Dynamic
> Software Tester auf dem anderen `model`-Feld, in der ersten Runde und in vier Delta-Runden: erste Runde dynamisch nicht bestanden
> (DT-C2-02, blockierend), statisch bestanden mit acht nachrangigen Befunden; erste Delta-Runde bestanden; zweite Delta-Runde dynamisch
> nicht bestanden (DT-C2-E-01, blockierend), statisch bestanden; dritte Delta-Runde statisch nicht bestanden (ST-C2-F-01, blockierend),
> dynamisch bestanden; vierte Delta-Runde statisch und dynamisch bestanden, die nachrangigen Restpunkte bleiben ohne weitere Änderung am Gate
> in dieser Einheit (Entscheid des Koordinators nach dem Muster aus 3.4; Buchstabe c, Nachtrag vom 2026-10-21, Restpunkte). Nach 3.4 war das
> Kriterium Posten 4 c zweimal gescheitert (DT-C2-E-01, ST-C2-F-01); die vierte Delta-Runde war der letzte Versuch und hat bestanden. Der
> Vulnerability Manager hat das Register `docs/11_Schwachstellenregister.md` mit SR-001 (Posten 5, CVSS 3.1 Basiswert 5.5) angelegt
> (Entscheid 2 oben), dazu SR-002 (DT-C2-01, 5.5), SR-003 (Posten 7, 4.7) und SR-004 (Posten 6, Bewertung mit dem Bau). Neu erfasst, nicht gebaut: Posten 6 (Prototyp-Gate, sed- und tr-Schritte ohne Prüfung des Rückgabewerts; L23, L24)
> und Posten 7 (beide Gates ohne eigene Zeitgrenze; am main-Gate über 14 s ab 8 MB), je terminiert mit der nächsten Änderung am jeweiligen
> Gate; Einordnungen, Grenzen und Preise in Buchstabe c, Nachtrag vom 2026-10-21. Vorbehalte: Die Hooks wirken in dieser Sitzung nicht
> (Probe mit Rückgabewert 0); gemessen ist über das Prüfmittel und Skripte, nicht im laufenden Harness. Nicht geändert sind
> `.claude/hooks/dod-gate.sh` (nach dem Register nicht betroffen, nicht gemessen), das `Makefile` und `.claude/settings.json`; `CLAUDE.md`,
> den Backlog und den Status von SR-001 führen Koordinator, Product Owner und Vulnerability Manager nach. Die Abnahme von Posten 4 und 5
> erteilt der Auftraggeber durch den Merge des Pull Requests dieser Sitzung (erster Formweg, Abschnitt 10); Posten 2, 3, 6 und 7 sind nicht
> umfasst. Die Sätze oben, die Posten 4 und 5 als erfasst und nicht gebaut führen, bleiben als Stand davor stehen (ADR 0002, 6.1, Absatz
> "Anlass").
>
> **Nachtrag vom 2026-10-21 zur Abnahme von Posten 4 und 5.**
> Die Abnahme von Posten 4 und 5 unter R3-Q-010 ist am 2026-10-21 erteilt (erster Formweg): Merge des Pull Requests #27 um 16:53:03 UTC
> durch den Auftraggeber, Merge-Commit `998f81d9fffe3970baf870d04e44576eda534fcc`, 0 Kommentare und 0 Reviews; eingetragen in Abschnitt 10
> durch den Protocol Master (Unterabschnitt "Abnahme von Posten 4 und 5 unter R3-Q-010 — main-Gate L17, L19, L21; beide Gates L20, L22, B64, B65 — erteilt am 2026-10-21, eingetragen am 2026-10-21", mit dem Wortlaut des Pull Requests, Umfang und
> Nicht-Umfasstem). Nach dem Wortlaut des Pull Requests ist der Merge zugleich die Bestätigung des Eintrags zur Abnahme von Posten 1 und der
> unter der Delegation getroffenen Einordnungen; nicht umfasst sind Posten 2, 3, 6 und 7 sowie die weiteren in diesem Unterabschnitt genannten Gegenstände (`R3-Q-011_regel_im_startkontext`, Terminierung von `Skill`, Berichtigung des Verweises "6.1.2", Wirkung der Gates im laufenden Harness). Der Pull Request #17 des Methodik-Repositories ist
> am 2026-10-21 um 16:53:23 UTC gemergt (Merge-Commit `f8cb47867fe09b80adb623a6c37fb6d800c49f1c`). Weisung vom 2026-10-21 (zweiter
> Formweg), im Wortlaut: "Weiter mit Abschnitt D, D1 und dann C3". Lesart des Koordinators: D1 ist der Eintrag der beiden Merges
> (Abschnitt 10, dieser Abschnitt, Backlog, Register, `CLAUDE.md`); C3 ist Posten 2 (L05 bis L08) zusammen mit Posten 6 (L23, L24) und dem
> Teil von Posten 7 am Prototyp-Gate, weil Posten 2 die nächste Änderung am Prototyp-Gate ist, mit der Posten 6 terminiert ist, und Posten 7
> mit der nächsten Änderung am jeweiligen Gate terminiert ist; der Teil von Posten 7 am main-Gate bleibt bis zur nächsten Änderung am
> main-Gate offen; danach C4 (Posten 3), O-29, Grundgerüst. Lesart des Koordinators zum Register (Entscheid unter der Delegation vom
> 2026-10-21, hiermit offengelegt): Das Schwachstellenregister stand im Titel des Pull Requests und war Inhalt des Diffs; der Wortlaut zur
> Bedeutung des Merges ordnet es weder dem Umfang noch dem Nicht-Umfassten zu. Der Merge nimmt die Datei `docs/11_Schwachstellenregister.md`
> im vorgelegten Stand an; eine Abnahme der CVSS-Bewertungen spricht er nicht aus, die Pflege bleibt beim Vulnerability Manager. Dessen
> Aufgabe in D1 ist, SR-001 und SR-002 mit dem Merge-Commit als Nachweis auf "behoben mit Nachweis" zu setzen; das steht in seinem Eintrag.
> Die Festlegung für C3 steht in Buchstabe c, Nachtrag vom 2026-10-21 zur Abnahme von Posten 4 und 5 — Festlegung für C3. Die Sätze oben,
> die die Abnahme von Posten 4 und 5 als künftig beschreiben, bleiben als Stand davor stehen (ADR 0002, 6.1, Absatz "Anlass").
>
> **Nachtrag vom 2026-10-22 — C3: Posten 2, Posten 6 und Teil von Posten 7 am Prototyp-Gate gebaut.**
> C3 ist am 2026-10-22 auf dem Arbeitszweig ccr-0cbb4387-oe1i3c gebaut, nach der Festlegung in Buchstabe c, Nachtrag vom 2026-10-21 zur
> Abnahme von Posten 4 und 5 — Festlegung für C3. Geändert sind das Prototyp-Gate (`.claude/hooks/block-prototype-import.sh`, Ausgang
> `c31e52c4fed1a5f8cb7821fe84d70779805e8698719ae655a46dd0348eb99adc`, Endstand `348ba80862f036adf874c0ead117dc2854e24f877137ac20357072be567d7389`)
> und das Prüfmittel (`scripts/pretooluse-gates-selbsttest.sh`, Ausgang `1bb858ff8bf4912659b8057d9a5115c2abbac028a6730d74c6fb0987a7bebaae`,
> Endstand `7ce0db32e576c8f79ae571c303543a0421df7bf9a38557768d1d6aa26af8cef0`); das main-Gate ist unverändert
> (`b2732614ce3c51a7233d41439a044fe2401920bcb5640b75c919b812a58586cb`). Gebaut hat der SecDevOps Engineer. Verifiziert haben der Static
> Software Tester (bestanden: Posten 2 und 6, Posten 7 nach Nennung der Laufzeit) und der Dynamic Software Tester (bestanden, alle
> Kriterien erfüllt), beide auf einem anderen Modell als die Umsetzung (6.13 f, Punkt 4).
> Posten 2: L05 bis L08 laufen mit Soll 2 und der Klasse "blockierend". Importwörter und Attribute stehen je einmal als Variable
> (IMPORTWORT, ATTR) und werden von beiden Richtungen gelesen: `require (`, `@import url(`, `src =` und `href =`, `__import__` und
> `import_module` mit einem Modulnamen ohne Punkt. Richtung 2 mit B66 bis B71, Gegenproben P42 bis P51; JS-Zuweisungen an src und href
> mit B72 und B73 (Soll 2) sowie P53 und P54 (Soll 0); `import("backend")` als gewollter Durchlass mit P52 (Soll 0). Der Kopfkommentar
> ersetzt den Absatz zu den symmetrischen Lücken (der frühere Wortlaut bleibt als "vormals" erhalten), benennt die Grenze an der
> Schnittstelle für ZF10d (GP-4) und verweist für L12 bis L16 auf den Nachtrag vom 2026-09-23.
> Posten 6: L23 und L24 laufen mit Soll 2 und der Klasse "blockierend". Die Hilfsfunktion `schritt_geprueft` prüft den Rückgabewert an
> sieben Stellen (cmd_flach: sed, sed der Schleife, tr; bereinigt: sed; payload_norm: sed, sed der Schleife, tr); jeder andere Ausgang als
> 0 endet über `pruefung_unmoeglich` mit Rückgabewert 2 und einer Meldung, die Werkzeug, Rückgabewert und Stelle nennt. Die jq-Schritte
> sind als Annahme der Bauform benannt (ST-13; widerlegt durch DT-C3-02, Posten 8). Je Stelle ein Fall und eine Mutation (S20, S21, S22,
> S24, S29, S30 und L24; MP21 bis MP27), dazu L23 und S23 für das ganz fehlende sed.
> Posten 7, Teil am Prototyp-Gate: Selbstaufruf unter `timeout -k 1 12` mit `$BASH` und `$0` nach der Festlegung; 0 nur bei innerem 0,
> eine 2 bleibt 2, jeder andere Ausgang und ein fehlendes `timeout` enden mit 2 und Meldung. Fälle S25 (cat um 20 s verzögert,
> Rückgabewert 2 nach 12,009 s), S26 (um 4 s verzögert, Soll 0), S27 (ohne `timeout`) und S28 (`timeout` endet mit 125); Mutationen MP28
> bis MP31; alle PATH-Varianten des Prüfmittels führen `timeout`, ausser der Variante ohne. Der Kopfkommentar nennt die Zeitgrenze als
> eigene Grenze des Gates; die Ausnahme von 6.13 d entfällt für dieses Gate.
> Zahlen: 479 Fälle (vorher 447; main-Gate 298, Prototyp-Gate 181), 66 Mutationen (vorher 49; neu MP16 bis MP32), 39 Fallklassen
> (vorher 36; KP-7 ersetzt GP-3, neu GP-4, KP-8 und KP-9), sieben Abnahmekriterien mit fortgeschriebenen Listen; BEFUND_VON trägt nur
> noch L09. Das Prüfmittel prüft bei Fällen des Prototyp-Gates mit Soll 2 zusätzlich, dass die Meldung vom Gate stammt und nicht allein
> von der Shell (Entscheid des Koordinators vom 2026-10-22, Begründung im Kopfkommentar des Prüfmittels).
> Läufe: Lauf A4 gegen das Gate im Ausgangsstand ergibt 455 von 479; die 24 gefallenen sind genau die erwartete Liste (Soll zuerst,
> 6.13 g). Lauf B gegen den Endstand ergibt 479 von 479, Rückgabewert 0 (54,7 s; beim Dynamic Software Tester 56,3 s). Lauf C im
> Mutationsmodus gegen den Stand vor den letzten Kommentaränderungen (Gate `b3bc6beb42c75cd0ac7ba3ce06a4e28fa3e029e370ade89f032574261c4106cc`)
> erkennt 66 von 66, 0 wirkungslos, Rückgabewert 0 (32 min 50 s); auf dem Endstand erkennt der Mutationsmodus beim Dynamic Software Tester
> 66 von 66 (2039,5 s). Dazu 120 direkte Gate-Aufrufe ohne Abweichung, die S25-Form mit Rückgabewert 2 nach 12,011 s und ein innerer
> Lauf, der TERM ignoriert, mit Rückgabewert 2 nach 13,010 s. `make dod` endet wie erwartet mit Rückgabewert 2: D7, D10 und D12 in
> Lage C, D11 und D20 A_OK, D19 OHNE_BEFUND. Aus der statischen Prüfung sind ST-C3-01 und ST-C3-02 behoben, ST-C3-03 und ST-C3-04
> eingeordnet.
> Neu erfasst aus der dynamischen Prüfung, nicht gebaut, terminiert mit der nächsten Änderung am Prototyp-Gate (C4), spätestens vor der
> Freigabe des Grundgerüsts: Posten 8 (die jq-Schritte prüfen ihren Rückgabewert nicht; DT-C3-02), Posten 9 (Bezugsformen, die das Gate
> nicht erkennt: ohne Anführungszeichen und in Grossschreibung an den Dateiwerkzeugen, DT-C3-01; `src=` und `href=` am Bash-Weg) und
> Posten 10 (Reste im Prüfmittel zu Posten 2 und 7: `-k 1`, `import_module`, statische JS-Form; DT-C3-03, ST-C3-03, ST-C3-04); dazu
> die Berichtigung der Laufzeit (DT-C3-04) und die Grenze des Waisenprozesses mit Messauftrag (DT-C3-05). C4 umfasst damit Posten 3, 8,
> 9 und 10; der Schnitt ist vor dem Bau festzulegen (3.3). Register: Den Status von SR-003 für den Teil am Prototyp-Gate setzt der
> Vulnerability Manager, der Teil am main-Gate bleibt offen; SR-004 bewertet er mit diesem Bau; Posten 8 und 9 trägt er als SR-005 und
> SR-006 ein.
> Weisung vom 2026-10-22 (zweiter Formweg, während des Baus von C3), im Wortlaut: "Ich vertraue dir und deinen super Fähigkeiten und
> gehen nach deiner Empfehlung". Vorangegangen waren eine Frage des Auftraggebers, ob ein fremdes Repository
> (https://github.com/affaan-m/ECC) das Vorgehen beschleunigen könne und ob das Methodik-Repository r3coscrum nötig sei, und die
> Einschätzung des Koordinators mit drei Optionen (1 Prozess verschlanken, 2 r3coscrum einfalten statt stampfen, 3 Muster aus dem
> fremden Repository selektiv mit dem Grundgerüst) und der Empfehlung, 1 und 2 jetzt, 3 mit dem Grundgerüst. Lesart des Koordinators:
> Die Optionen 1 und 2 sind dem Grundsatz nach entschieden, Option 3 ist auf das Grundgerüst terminiert. Die konkreten Änderungen
> (Projektauftrag 1.3, 3.3 und 6.6, `.claude/rules/dokumentation.md`, Form von Übergabe und Pull Request, Einfalten von r3coscrum) legt
> der Koordinator nach Abschluss von C3 als eigene Einheit "Prozess-Schnitt" in einem Pull Request vor, dessen Text sagt "Merge = Annahme
> der Regeländerungen"; der Merge ist der Entscheid (erster Formweg). C3 wird zuvor zu Ende geführt (3.1). Das fremde Repository bleibt
> fremder Inhalt; nichts daraus wird installiert.
> Weisung vom 2026-10-22 (zweiter Formweg), auf die Frage, ob die FFHS r3coscrum als eigenes Repository braucht, im Wortlaut: "Nein, FFHS
> braucht es nicht, nach Übergangsfrist weg". Lesart des Koordinators: r3coscrum wird im Prozess-Schnitt eingefaltet (Methodik-Texte und
> Nachweise mit Quell-Prüfsummen nach docs/methodik/ (künftiges Verzeichnis, entsteht mit dem Prozess-Schnitt) dieses Repositories), die Automatik abgeschaltet und das Repository nur lesbar
> archiviert; nach einer Übergangsfrist löscht der Auftraggeber es selbst. Vorschlag der Frist: bis zum Merge des Pull Requests, der die
> Freigabe des Grundgerüsts trägt; vorher liegen alle in Abschnitt 10 und in `CLAUDE.md` zitierten Merge-Commits des
> Methodik-Repositories als Kopien mit Quell-Prüfsumme unter docs/methodik/ (künftig), damit die Verweise auflösbar bleiben (6.6). Der
> Prozess-Schnitt berührt ADR 0002 an den Stellen, die das Methodik-Repository voraussetzen (der Starthook
> `.claude/hooks/session-start-eingang.sh` und `docs/EINGANG_METHODIK.md`, die Arbeitsabläufe unter `.github/workflows/`, die Nachweise
> übertragen, die Verweise auf Merge-Commits des Methodik-Repositories in Abschnitt 10); ihre Fortschreibung gehört in dessen Pull Request.
> Nächste Einheit: Prozess-Schnitt; danach C4 (Posten 3, 8, 9 und 10), O-29, die Einheit für den Teil von Posten 7 am main-Gate
> (Einordnung ausstehend), Grundgerüst. Die Abnahme von C3 erteilt der Auftraggeber durch den Merge des Pull Requests dieser Sitzung;
> nicht umfasst sind Posten 3, 8, 9 und 10, der Teil von Posten 7 am main-Gate, die Restpunkte am main-Gate und der Prozess-Schnitt.
> Die Einordnungen aus dem Bau und die Berichtigung stehen in Buchstabe c, Nachtrag vom 2026-10-22 zum Bau von C3 — Einordnungen und Berichtigung.
> Die Sätze oben, die C3 als künftig beschreiben, bleiben als Stand davor stehen (ADR 0002, 6.1, Absatz "Anlass").
>
> **Nachtrag vom 2026-10-22 zur Abnahme von Posten 2, 6 und des Teils von Posten 7 am Prototyp-Gate.**
> Die Abnahme von Posten 2, 6 und des Teils von Posten 7 am Prototyp-Gate unter R3-Q-010 ist am 2026-10-22 erteilt (erster Formweg): Merge des
> Pull Requests #28 um 14:59:00 UTC durch den Auftraggeber, Merge-Commit `95cafc9cc31773a6c29d977ec9c3b97af5a1f047`, 0 Kommentare und 0 Reviews;
> eingetragen in Abschnitt 10 durch den Protocol Master (Unterabschnitt "Abnahme von Posten 2, 6 und des Teils von Posten 7 am Prototyp-Gate unter R3-Q-010 — …").
> Umfasst ist C3 im Umfang der Übergabe `docs/uebergaben/2026-10-22_c3-prototyp-gate.md` einschliesslich der dort benannten Restpunkte, des gewollten
> Durchlasses für `import("backend")` und der Berichtigung zur Laufzeit; nach dem Wortlaut des Pull Requests bestätigt der Merge zugleich den Eintrag
> zur Abnahme von Posten 4 und 5 und die Lesart des Koordinators zum Register und nimmt die Register-Nachträge im vorgelegten Stand an. Nicht umfasst
> sind Posten 3, 8, 9 und 10 (C4), der Teil von Posten 7 am main-Gate samt den Restpunkten dort, der Prozess-Schnitt, `R3-Q-011_regel_im_startkontext`,
> die Terminierung von `Skill`, die Berichtigung "(ADR 0002, 6.1.2)" und die Wirkung der Gates im laufenden Harness. Der Pull Request #18 des
> Methodik-Repositories ist am 2026-10-22 um 14:59:51 UTC gemergt (Merge-Commit `b26f286ef9680a741c0de5294d80543bace44de8`) und spricht nach eigenem
> Text keine Abnahme aus. Mit dem Merge des Pull Requests #29 um 14:59:15 UTC (Merge-Commit `d7d539ebea07043201d58e36c8abafec54045848`) ist PS-1 des
> Prozess-Schnitts angenommen (Abschnitt 10, Unterabschnitt "Annahme des Prozess-Schnitts PS-1 (Regeln) — …"); PS-2 (die Verschiebung dieses Abschnitts
> 6.13 nach ADR 0004, Teil B, unverändert) beginnt am 2026-10-22. Die Sätze oben, die C3 als künftig beschreiben, bleiben als Stand davor stehen
> (ADR 0002, 6.1, Absatz "Anlass").

**Anlass.** Die Abnahme des Definition-of-Done-Gates aus R3-Q-001 ist am
2026-09-08 erteilt (Merge-Commit `9870b0d115b8ef330a7c19777af5741093e4f0e9`,
eingetragen in ADR 0002, Abschnitt 10). Nach der freigegebenen Reihenfolge folgt
E4. Der Umfang von E4 war in keinem Dokument des Repositories festgelegt; der
Zustandsbericht vom 2026-09-02 (`docs/10_Zustandsbericht_2026-09-02.md`) führt
das als Befund BER-05 und als Punkt 4 seiner Tabelle "Arbeitseinheiten in der
freigegebenen Reihenfolge". Derselbe Bericht hat in seiner Dimension Hooks und
Skripte belegte Lücken an beiden bestehenden PreToolUse-Gates gefunden. Am
2026-09-21 sind diese Lücken gegen einen Wegwerf-Klon auf `main`
(`c06ed44337b297a70fcf33ae2410b0fd69503445`) nachgemessen und von einer
Prüfrolle auf einem anderen Modell als die Erhebung zusätzlich am Quelltext
belegt worden. Der Requirements Engineer hat daraus R3-Q-010 formuliert; dieser
Abschnitt ordnet den Eintrag ein und entscheidet, was er offengelassen hat.

**Was vorher galt.** E4 hiess "main-Gate" und hatte als einzige Quelle einen Satz
der Übergabe vom 2026-08-25
(`docs/uebergaben/2026-08-25_eingangskanal-repariert.md`): E4 rücke nach hinten,
der Umfang bleibe, die Dringlichkeit falle weg, weil auf `main` zusätzlich ein
serverseitiges Regelwerk mit Blockade von Force-Pushes und Pull-Request-Pflicht
greife. Ein versioniertes Prüfmittel für die beiden PreToolUse-Gates bestand
nicht und besteht nicht; ihre Wirkung ist allein in Übergabetexten beschrieben.

**Was jetzt gilt.** E4 hat einen am Bestand gemessenen Inhalt, umfasst beide
PreToolUse-Gates und trägt die Kennung R3-Q-010. Massgeblich sind ausschliesslich
die belegten Lücken; was ein Gate sonst noch könnte, ist nicht Gegenstand. Die
Festlegung dieses Abschnitts bindet die Umsetzung, sobald der Auftraggeber den
Umfang freigibt; sie ist selbst keine Freigabe.

**a) Gegenstand und Abgrenzung.**

Gegenstand sind die beiden bestehenden PreToolUse-Gates:
`.claude/hooks/block-main-write.sh` (Schutz von `main` als Hook statt als Satz,
3.2 c) und `.claude/hooks/block-prototype-import.sh` (Trennung von Prototyp und
Produktionscode bis zur Prototyp-Freigabe, 5.6). Das Prototyp-Gate gehört zu E4,
obwohl E4 bisher "main-Gate" hiess: Der Zustandsbericht führt beide Gates in
derselben Dimension und hat an beiden belegte Lücken gefunden; seine Einordnung
der Arbeitseinheiten stützt Punkt 4 der Tabelle und den Befund BER-05 gerade
darauf ("E4 ist damit nicht mehr nur 'rückt nach hinten', sondern hat einen
messbaren Inhalt"). Ein Schnitt, der nur das main-Gate nähme, liesse die
erheblichen Befunde am Prototyp-Gate ohne Einheit, obwohl beide Gates dieselbe
Bauform, dieselbe Aufrufschnittstelle und dasselbe fehlende Prüfmittel teilen.

E4 ist **kein Kettenschritt der Definition of Done**. Der Kettenschritt D10
(Prototyp-Trennung) bleibt Lage C: Der bestehende PreToolUse-Hook leistet die für
D10 verlangte Stapelprüfung über den Bestand nicht, weil er ein Ereignis von der
Standardeingabe liest und je Werkzeugaufruf urteilt
(`docs/06_Definition_of_Ready_und_Done.md`, Zeile D10; ADR 0002, Abschnitt 6,
Zeile D10). Ob die Stapelprüfung als Betriebsart desselben Skripts entsteht, ist
als ADR 0002, O-8 offen und mit dem Grundgerüst terminiert. E4 ersetzt D10 nicht,
und dieser Abschnitt vergibt keine D-Nummer.

Abgrenzung nach drei Seiten: **R3-Q-005** betrifft ein noch nicht bestehendes
Gate für die harte Durchsetzung der Rollen-Schreibgrenzen — andere Frage, andere
Datei, keine gemeinsame Umsetzung. **ADR 0002, 6.12** betrifft das
Definition-of-Done-Gate, das am 2026-09-08 abgenommen worden ist; E4 rührt es
nicht an. Berührung besteht nur mittelbar: Weil die Kette abgenommen ist, greift
`make dod` über jede Änderung an den beiden Gates. **ADR 0002, O-8** wird
dagegen unmittelbar berührt: E4.2 und E4.3 ändern
`.claude/hooks/block-prototype-import.sh`, also das Skript, dessen zweite
Betriebsart nach ADR 0002, O-8 Prüfmittel für D10 werden könnte. Wer E4.2 oder
E4.3 umsetzt, hält O-8 offen und legt eine Berührung mit D10 als Fortschreibung
dieses ADR fest, nicht stillschweigend.

**b) Die belegten Lücken, Stand 2026-09-21.**

| Befund | Gate | heutiger Stand | Beleg |
|---|---|---|---|
| ST-01 (Zweigname in Anführungszeichen, in Befehlsketten, in Klammern) | main-Gate | behoben; Fremdverifikation der Behebung nicht belegt | Commit `0b3510a3fd8b219c82c093b34be3aff50c68f7e0` vom 2026-09-03; Proben A01 bis A06 je Rückgabewert 2 |
| ST-02 (Anlegen eines Arbeitsbaums auf `main` mit gequotetem Zweignamen) | main-Gate | behoben; Fremdverifikation nicht belegt | derselbe Commit; A07 bis A09 je Rückgabewert 2, Gegenprobe G03 Rückgabewert 0 |
| ST-03 (fehlendes `git` im Suchpfad) | main-Gate | behoben; Fremdverifikation nicht belegt | derselbe Commit; S03 Rückgabewert 2 mit Meldung auf der Standardfehlerausgabe |
| ST-04 (Verzeichnisimport ohne Schrägstrich) | Prototyp-Gate | offen | B02 und B03 je Rückgabewert 0 |
| ST-05 (gleichwertiger Pfad mit vorangestelltem Punkt-Schrägstrich) | Prototyp-Gate | offen | B06 Rückgabewert 0 |
| P-01 der Dimension Prototyp (5.6) (Richtung 2 kennt die HTML-Formen nicht, die Richtung 1 führt) | Prototyp-Gate | offen | B07 und B08 je Rückgabewert 0, Gegenprobe P02 Rückgabewert 2 |
| ST-09 (Schreibwirkung eines Interpreters mit Inline-Code nicht erkannt) | Prototyp-Gate | offen | B09 Rückgabewert 0; dieselbe Befehlsklasse führt das main-Gate ausdrücklich |
| P-10 der Dimension Prototyp (5.6) (Nichtprüfung gemeinsamer Abhängigkeiten nirgends als Grenze benannt) | Prototyp-Gate | offen | Kopfkommentar zitiert 5.6 einschliesslich "ohne gemeinsame Abhängigkeiten", benennt die Nichtprüfung an keiner Stelle |
| ST-13 (nicht auswertbare Eingabe läuft still durch) | beide Gates | offen | S01, S02, S04, S05 je Rückgabewert 0 |
| kein versioniertes Prüfmittel für die beiden Gates (Massstab: Hook-Regel in `.claude/rules/claude-konfiguration.md`, je Hook ein blockierender und ein durchzulassender Fall) | beide Gates | offen | Vergleich mit `scripts/dod-gate-selbsttest.sh`: für das DoD-Gate besteht ein Selbsttest, für die beiden `PreToolUse`-Gates besteht keiner; die Proben vom 2026-08-25 und die 16 Fälle vom 2026-09-03 sind nur in Übergaben beschrieben |

Zu ST-01 bis ST-03: Die Behebung ist im Bestand allein durch die umsetzende
Einheit selbst belegt. Der Fremdbeleg vom 2026-09-21 stellt ausdrücklich fest,
dass es dazu keinen Prüfbericht, keinen Prüffall und keine benannte prüfende
Rolle gibt; der Commit ändert genau eine Datei und rührt kein Prüfmittel an, und
die im Commit-Rumpf genannten "16 Fälle" sind nirgends überliefert. Der Lauf vom
2026-09-21 ist der erste Fremdbeleg dieser Behebung. Genau das ist der Grund,
weshalb R3-Q-010 die drei Befunde nicht erneut behebt, sondern die fehlende
Verifikation nachholt (3.4).

Zu ST-13: Der Zustandsbericht führt den Befund in seiner Tabelle der widerlegten
Befunde, bestätigt dort aber im lesbaren Teil den operativen Befund und bricht in
der Zelle "Grund der Widerlegung" mitten im Satz ab; der Widerlegungsgrund ist im
Dokument nicht überliefert und lässt sich nicht rekonstruieren. Der historische
Stand bleibt stehen (ADR 0002, 6.1.2); dieser Abschnitt benennt ihn, schreibt ihn
nicht um.

**Entscheid zu ST-13: die Nachbedingung Rückgabewert 2 wird bestätigt.** Was der
Requirements Engineer nach R4 als ausdrücklich benannte Annahme geführt hat, ist
mit diesem Abschnitt entschieden; das Abnahmekriterium
`R3-Q-010_gates_unlesbare_eingabe` gilt in der Fassung des Backlogs. Gründe:

1. Beide Gates behandeln ein fehlendes Prüfmittel bereits fail-closed: die
   jq-Wache in beiden Gates, seit dem 2026-09-03 zusätzlich die git-Wache des
   main-Gates — ST-03 ist mit genau dieser Begründung behoben worden. Eine
   Eingabe, die sich nicht auswerten lässt, ist derselbe Zustand: Das Gate kann
   nicht prüfen. Dass es in dem einen Fall blockiert und in dem anderen
   durchlässt, ist keine Entscheidung, sondern eine Auslassung — der
   Rückgabewert von jq wird schlicht nicht ausgewertet.
2. Das abgenommene Definition-of-Done-Gate führt für denselben Sachverhalt den
   Blockpfad "kein gültiges JSON" mit Rückgabewert 2 (ADR 0002, 6.12.28 e), und
   ADR 0002, 6.12.28 f verlangt, dass Deckungen fail-closed sind. Zwei Gates
   desselben Repositories dürfen denselben Fall nicht gegenläufig behandeln; wer
   den Bestand liest, muss aus einem Gate auf das andere schliessen können.
3. Das Gegenargument ist gewürdigt und trägt nicht: Der Harness sendet in der
   Regel gültiges JSON, der Fall tritt kaum auf. Gerade deshalb kostet ein Block
   praktisch nichts. Ein stilles Durchlassen dagegen ist eine Zusicherung ohne
   Deckung — die Gate-Tabelle in CLAUDE.md sagt, das Gate blockiere; bei
   unlesbarer Eingabe tut es das nicht, und niemand erfährt davon. Das ist
   dieselbe Fehlerklasse, gegen die dieser Eintrag insgesamt gerichtet ist.
4. Grenze des Entscheids, ausdrücklich: Er betrifft die Eingabe des Hooks, nicht
   das Verhalten des Harness. Ob und wie oft der Harness selbst unvollständige
   Eingabe erzeugt, ist nicht gemessen; träte das im Betrieb gehäuft auf, wäre
   das eine Beobachtung für eine Fortschreibung dieses Abschnitts, kein Grund,
   die Richtung jetzt offen zu lassen.

**Präzisierung, keine Abweichung:** Die schärfere dritte Form aus dem Fremdbeleg
— syntaktisch gültiges JSON, in dem `tool_input` eine Zeichenkette statt eines
Objekts trägt — trägt dasselbe Soll 2, weil auch dort die Auswertung scheitert.
Der Prüfsatz führt sie als Prüffall, nicht als Behauptung über den Bestand. Sie
ist kein fünfter Grund, sondern eine Präzisierung des Entscheids; die Gründe
sind die vier oben genannten.

**c) Was bewusst nicht Gegenstand ist.**

- **ST-10** (der `SessionStart`-Matcher führt den Auslöser fork nicht): Er
  betrifft den Eingangs-Hook `.claude/hooks/session-start-eingang.sh`, der nie
  blockiert und damit ein Kanal ist, kein Gate; Gegenstand war Einheit E2.
- **ST-11** (die beiden `PreToolUse`-Matcher führen PowerShell nicht): nicht
  aufgenommen, aber **als neuer offener Punkt O-28 geführt**, nicht abgelehnt.
  Die Konfigurationslücke ist statisch belegt; was nicht belegt ist, ist die
  Wirkung. In dieser Umgebung besteht das Werkzeug nicht, und ein Matcher-Eintrag
  allein liesse die auf Shell-Grammatik zugeschnittene Textprüfung beider Gates
  über fremde Grammatik laufen — ob sie dort trägt, ist mit statischen Mitteln
  nicht zu belegen, so auch der Fremdbeleg. Ein Eintrag ohne Messung wäre
  wiederum eine Zusicherung ohne Deckung. Bedingung, Entscheider und Frist stehen
  in O-28 (ADR 0002, Abschnitt 8).
- **ST-06, ST-12, ST-14** (Belegprüfer `scripts/belege-pruefen.sh`): kein Gate,
  sondern Prüfmittel eines Kettenschritts; seine Abnahme ist als ADR 0002, O-15
  offen und fällig vor der Freigabe des Grundgerüsts.
- **ST-07** (`scripts/nachweise-erzeugen.sh`): kein Gate, Nachweisfluss.
- **ST-08, ST-15** (Arbeitsabläufe des Nachweisflusses): kein Gate.
- **K-01** (der Belegprüfer liest nur versionierte Dateien): Kettenschritt D20,
  kein Gate. Die Klasse ist in dieser Einheit erneut wirksam geworden — `main`
  war seit dem Merge von `9870b0d115b8ef330a7c19777af5741093e4f0e9` an D20 rot,
  weil die damals neue Übergabedatei vor ihrer Versionierung geprüft worden war.
  Der Befund gehört zur Abnahme des Belegprüfers (ADR 0002, O-15), nicht zu E4.
- **Die Prüfung gemeinsamer Abhängigkeiten aus P-10**: Das wäre eine neue
  Fähigkeit (Abhängigkeitsanalyse über zwei Bäume), keine Lücke an einer
  bestehenden Prüfung. Belegt und billig ist allein das Benennen der Grenze;
  genau das ist aufgenommen.
- **Jede Härtung ohne belegte Lücke**: kein neuer Werkzeugname im Matcher, keine
  neue Befehlsklasse, kein weiteres Verzeichnis, solange keine ausgeführte Probe
  dafür eine Lücke zeigt.
- **Die im Kopfkommentar des main-Gates benannten Grenzen** (Kontextwechsel in
  einer Subshell oder in einem untergeordneten Shell-Aufruf, ein ausserhalb der
  Sitzung angelegter zweiter Arbeitsbaum, ein Aufruf ausserhalb eines
  Repositories): Sie werden **nicht geschlossen, sondern festgeschrieben und als
  durchlaufende Fälle gemessen**. Eine Textprüfung ist grundsätzlich nicht dicht;
  sie als dicht auszugeben, wäre schädlicher als die Grenze. Die harte Zusicherung
  für `main` trägt das serverseitige Regelwerk mit Blockade von Force-Pushes und
  Pull-Request-Pflicht; die Gates sind die zweite Verteidigungslinie.

**Nachtrag vom 2026-09-23 — die Prüfstand-Fälle, entschieden (Entscheid 2 des
Auftraggebers vom 2026-09-23, Wortlaut: "Prüfstand-Fälle des Prüfmittels (ZF9,
ZF10a bis ZF10d, L01 bis L16) als Fortschreibung von ADR 0002, 6.13 c durch den
Software Architect in dieser Session mit erledigen: ja/nein. ICH WÄHLE: ja").**

Gegenstand sind die 21 in Entscheid 2 genannten Fälle, die im Prüfmittel
`scripts/pretooluse-gates-selbsttest.sh` die Klasse "pruefstand" tragen und mit
dem heute gemessenen Rückgabewert als Soll laufen: ZF9 und ZF10a bis ZF10d
(Nummer 9 und 10 aus ADR 0002, 6.13 d) sowie L01 bis L16; P38 trägt dieselbe
Klasse, ist aber nicht Gegenstand von Entscheid 2 (siehe unten). ADR 0002, 6.13 d und
die Nachträge zu E4.1, E4.2 und E4.3 im Status-Block von ADR 0002, 6.13 haben
ihre Aufnahme offengelassen; dieser Nachtrag entscheidet sie. Der Wortlaut von
ADR 0002, 6.13 c oben bleibt unverändert (ADR 0002, 6.1.2). R3-Q-010 ist seit
dem 2026-09-23 abgenommen (Status-Block von ADR 0002, 6.13); was hier als Lücke
entschieden wird, ist neue Arbeit an den Gates, keine Nacharbeit am
abgenommenen Umfang.

**Massstab.** Drei Fragen, in dieser Reihenfolge:

1. **Erreichbarkeit.** Kommt die geprüfte Angabe vom Modell (`tool_input`) oder
   setzt sie der Harness (`tool_name`)? Eine Form, die nur über eine Angabe des
   Harness entsteht, ist keine Lücke der Textprüfung.
2. **Vertrag.** Liegt die Form in einer Klasse, die der Kopfkommentar des Gates
   als gedeckt behauptet, und ausserhalb der Lesart aus dem Nachtrag zu E4.2
   (Bezugsform ist das Konstrukt; die Pfadschreibweise ist in Richtung 1 weiter
   gefasst und in Richtung 2 präfixgebunden)?
3. **Mittel.** Lässt sich die Form mit einem begrenzten, rein lexikalischen
   Schritt erkennen — ohne Auswertung (Expansion durch die Shell, Auflösung von
   Modulen oder Pfaden über das Dateisystem) und ohne eine Klasse von
   Fehlalarmen, die das Gate bewusst meidet?

Daraus folgt der Entscheid je Fall. **Belegte Lücke (c)** ist nur, was alle
drei Fragen besteht. **Grenze (a)** ist, was an der Lesart oder am Mittel
scheitert: Es wird nicht geschlossen, sondern festgeschrieben und als
durchlaufender Fall gemessen, wie oben für die Grenzen des main-Gates
entschieden. Scheitert ein Fall an der Erreichbarkeit, entscheidet die Wirkung:
Lässt das Gate durch, wird die Stelle als **Grenze an der Schnittstelle (a)**
benannt, weil ein unbenannter Durchlass als Dichtheit gelesen würde; blockiert
es, ist das **gewolltes Verhalten (b)**. Gewollt ist auch, was ausserhalb des
Gegenstands eines Gates liegt (beim Prototyp-Gate: ausserhalb dessen, was nach
Projektauftrag 5.6 zu trennen ist).

| Fall | Gate | heutiger Wert | Entscheid | Begründung | Folge |
|---|---|---|---|---|---|
| ZF9 | Prototyp | 0 | (b) Verhalten gewollt, kein Befund | Frage 2: Eine Datei unter .claude/ ist nach ADR 0002 weder Bauwurzel noch Prototyp und liegt ausserhalb dessen, was das Gate trennt; die Ausnahmeliste nimmt .claude/ bewusst aus, und dort liegt das Gate selbst, dessen Kommentare Importmuster als Beispiele tragen. Der Entscheid gilt, solange keine Bauwurzel nach ADR 0002 unter die Ausnahmeliste fällt. | Soll bleibt 0; Klasse "durchlaufend", Vermerk auf diesen Nachtrag; Kopfkommentar unverändert |
| ZF10a, ZF10b, ZF10d | main (ZF10a, ZF10b), Prototyp (ZF10d) | 0 | (a) Grenze an der Schnittstelle, festgeschrieben | Frage 1: Den Werkzeugnamen setzt der Harness, nicht das Modell. Beide Gates führen ihren Bash-Zweig nur bei Gleichheit mit "Bash"; unter einem anderen Namen wird ein Befehlstext nicht als Befehl geprüft. Eine Erweiterung der Gleichheitsprüfung ohne belegte Lücke fiele unter die Härtungen oben (ADR 0002, 6.13 d, Nummer 10). Weil der Fall durchlässt, wird er benannt. Ein weiteres Befehlswerkzeug im Matcher ist Gegenstand von ADR 0002, O-28, nicht dieses Entscheids. | Die Kopfkommentare beider Gates nennen diese Grenze heute nicht; nachzutragen mit der nächsten Änderung am jeweiligen Gate, je mit einer Fallklasse vom Typ "grenze" (ADR 0002, 6.13 d); Soll bleibt 0, Klasse "grenze" |
| ZF10c | Prototyp | 2 | (b) Verhalten gewollt, fail-closed | Frage 1 wie oben, aber mit umgekehrter Wirkung: Der Zweig der Dateiwerkzeuge prüft den Werkzeugnamen nicht und entscheidet an Pfad und Inhalt; ein unbekannter Name blockiert deshalb, und das ist die sichere Richtung. | Soll bleibt 2; Klasse "blockierend", Vermerk auf diesen Nachtrag; Kopfkommentar unverändert |
| L01, L02, L03 | main | 0 | (c) belegte Lücke, Posten 1 unter R3-Q-010 | Belegt vom Dynamic Software Tester (DT-E41-04). Push nach main (L01, L02) und Arbeitsbaum auf main (L03) liegen in Klassen, die der Kopfkommentar als gedeckt behauptet (KM-4, KM-6). `ma"in"` und `\main` ergeben nach dem Entfernen der Quotierung durch die Shell das Wort main; den Befehl setzt das Modell. Erkennbar mit einem lexikalischen Schritt: Anführungszeichen und Rückstriche entfernen, bevor die Ziele von push und worktree verglichen werden. Eine neue Klasse von Fehlalarmen ist nicht zu erwarten, weil beide Muster ein Anführungszeichen vor main heute schon als Ziel werten; die Gegenproben des Postens belegen das. | Soll 2 nach ADR 0002, 6.13 g mit dem Bau von Posten 1; mit demselben Bau benennt der Kopfkommentar als Grenze, dass Ziele, die erst durch Auswertung entstehen (Variable, Befehlssubstitution, eval), nicht erkannt werden, mit einem durchlaufenden Fall (ADR 0002, 6.13 d) |
| L04 | main | 0 | (c) belegte Lücke, Posten 1 unter R3-Q-010 | Belegt wie L01 (DT-E41-04); Klasse KM-6 (gedeckt). Die Ausnahme für -b und -B ist für einen neuen Zweig gedacht, der von main abzweigt; sie greift aber auch, wenn der neue Zweig selbst main heisst. `-B` setzt einen bestehenden Zweig dabei auf den Ausgangspunkt zurück und checkt ihn im neuen Arbeitsbaum aus — genau die Wirkung, die die Sperre verhindern soll. Lexikalisch erkennbar: Die Ausnahme gilt nur, wenn der Name hinter -b oder -B weder main noch master ist. | Soll 2 nach ADR 0002, 6.13 g mit dem Bau von Posten 1; der Rumpfkommentar zur Ausnahme für -b und -B wird mit dem Bau nachgeführt |
| L05, L06, L07, L08 | Prototyp | 0 | (c) belegte Lücke, Posten 2 unter R3-Q-010 | Belegt in der dynamischen Runde zu E4.2 (DST-E42-04); Klassen KP-1 und KP-2 (gedeckt). Die Formen sind Schreibweisen des Konstrukts, nicht des Pfads: Leerraum vor der Klammer bei `require (`, die Form `@import url(`, Leerraum um das Gleichheitszeichen bei `src =`, `__import__` mit einem Modulnamen ohne Punkt. Nach der Lesart ist das Konstrukt die Bezugsform, die in beiden Richtungen gedeckt sein soll. Die Formen betreffen auch Richtung 1, also den Weg, auf dem nach dem Kopfkommentar des Gates Provisorien in die Produktion wandern; `@import url(` ist die gängige Form in CSS. Lexikalisch erkennbar: Leerraum zulassen, die url-Form als Variante von `@import`, den Modulnamen ohne Punkt. | Beide Richtungen in einem Bau (Kriterium `R3-Q-010_prototyp_gate_richtungsgleichheit`), Soll 2 nach ADR 0002, 6.13 g mit dem Bau von Posten 2; der Absatz des Kopfkommentars zu den symmetrischen Lücken wird mit dem Bau ersetzt, die Fallklasse GP-3 verliert den Typ "grenze" |
| L09 | Prototyp | 0 | (c) belegte Lücke, Posten 3 unter R3-Q-010 | Klasse KP-2 (gedeckt). Dieselbe Importzeile blockiert unter prototype/x.js (B06); der Unterschied liegt im Dateipfad mit dem Segment "." (Vermerk des Falls L09 im Prüfmittel: "B-1-dynamisch-unnormalisierter-Pfad", 2026-09-23; in der Übergabe zu E4.2 nicht einzeln geführt). Den Pfad setzt das Modell; die Lesart zu Richtung 2 betrifft die Importpfade, nicht den Ort der Datei. Lexikalisch erkennbar: die Segmente "." und ".." und doppelte Schrägstriche vor der Zuordnung bereinigen, ohne das Dateisystem zu befragen. | Bereinigung vor jeder Zuordnung (Richtung 1, Richtung 2, Ausnahmeliste), Soll 2 nach ADR 0002, 6.13 g mit dem Bau von Posten 3; die Auflösung symbolischer Verknüpfungen ist nicht Gegenstand (keine belegte Lücke) |
| L10, L11 | Prototyp | 0 | (a) Grenze GP-2, festgeschrieben | Frage 2: Pfadschreibweise der Richtung 2 (Wurzelpfad, beliebiger Vorspann), nach der Lesart präfixgebunden, weil die Produktionswurzeln generische Namen sind; ein weiter gefasstes Präfix hat in der dynamischen Runde zu E4.2 Fehlalarme gekostet (DST-E42-02). Ein Wurzelpfad in einer HTML-Datei zeigt zudem unter die Wurzel des ausliefernden Servers, nicht notwendig auf den Produktionscode. | Der Kopfkommentar benennt die Grenze bereits (Absatz zur Asymmetrie der Pfadschreibweise); Soll bleibt 0, Klasse "grenze" |
| L12, L13, L14, L15, L16 | Prototyp | 0 | (a) Grenze GP-2, festgeschrieben | Frage 2: Pfadschreibweisen der Richtung 2 — `src=` ohne Schrägstrich hinter der Wurzel (L12), `href=` mit Rückstrich (L13), doppelter Rückstrich im Import (L14), mehrfaches "./" (L15), Alias "~/" in `href=` (L16). Die Lesart nennt Wurzelpfade, beliebige Vorspanne, `src=`/`href=` ohne Schrägstrich, doppelten Rückstrich und mehrfaches "./" als präfixgebunden (Übergabe zu E4.2); der Kopfkommentar führt dazu den Rückstrich und den Alias "~/" in `src=`/`href=`. Das Kriterium `R3-Q-010_prototyp_gate_richtungsgleichheit` ist unter dieser Lesart bestanden und abgenommen; diese Formen zu schliessen hiesse, seine Lesart zu ändern. Die Restbefunde R-1/E-1 und DST-E42-N1 aus E4.2 betreffen dieselben Formen und sind damit als Grenze entschieden, nicht als offene Befunde. | Der Kopfkommentar benennt die Formen bereits; sein Halbsatz, der den Entscheid über eine Aufnahme dieser Fortschreibung zuweist, ist überholt und wird mit der nächsten Änderung am Gate durch den Verweis auf diesen Nachtrag ersetzt; Soll bleibt 0, Klasse "grenze" |

**Die drei Posten unter R3-Q-010.** Die Aufnahme in den Backlog macht der
Product Owner, nach der Präzedenz der drei Restlücken, die nach der Abnahme von
R3-Q-001 als Posten unter dem abgenommenen Eintrag geführt werden
(ADR 0002, 6.12.28 j, Punkt 5).

1. **Posten 1, main-Gate (L01 bis L04):** Die Ziele von push und worktree
   werden nach dem Entfernen von Anführungszeichen und Rückstrichen verglichen;
   die Ausnahme für -b und -B greift nicht, wenn der neue Zweig main oder master
   heisst. Mit derselben Änderung benennt der Kopfkommentar die Grenze der
   Auswertung. Die Übergabe zu E4.1 nennt zwei weitere Formen aus DT-E41-04,
   die das Prüfmittel nicht führt; sie sind nicht Gegenstand dieses Entscheids.
   Liegen sie im Fremdbeleg vor, legt der Bau sie dieser Rolle zur Einordnung
   nach demselben Massstab vor.
2. **Posten 2, Prototyp-Gate (L05 bis L08):** die vier Schreibweisen des
   Konstrukts, in beiden Richtungen in einem Bau.
3. **Posten 3, Prototyp-Gate (L09):** lexikalische Bereinigung des Dateipfads
   vor jeder Zuordnung.

Für alle drei Posten gilt:

- **Bauvorschrift** nach ADR 0002, 6.13 g: je Fall zuerst das Soll auf 2 — der
  Lauf fällt und belegt, dass der Fall wirksam ist —, dann das Gate, zuletzt
  der Vermerk. Je Behebung eine Mutation, die sie zurücksetzt und den
  betroffenen Fall nennt (ADR 0002, 6.13 d, Punkt 6); je Sachverhalt ein
  blockierender und ein durchzulassender Gegenstand, und die Gegenproben des
  Regressionsschutzes bleiben grün (ADR 0002, 6.13 f, Punkt 1 und 2).
- **Rollen** nach ADR 0002, 6.13 e: Umsetzung durch den SecDevOps Engineer,
  Verifikation durch Static und Dynamic Software Tester auf einem anderen
  Modell als die Umsetzung (ADR 0002, 6.13 f, Punkt 4; Projektauftrag 3.4).
- **Terminierung:** mit der nächsten Änderung an den Gates, spätestens vor der
  Freigabe des Grundgerüsts. Die Einordnung in die freigegebene Reihenfolge
  (E3, dann Grundgerüst) legt der Auftraggeber fest.
- **Vorbehalt:** Zeigt der Bau, dass eine Behebung eine neue Klasse von
  Fehlalarmen öffnet oder eine Auswertung verlangt, wird der Fall nicht
  geschlossen, sondern dieser Rolle als Grenze vorgelegt, als Fortschreibung
  dieses Nachtrags.

**Was daraus für das Prüfmittel folgt.** In dieser Sitzung ändert sich an
`scripts/pretooluse-gates-selbsttest.sh`, an den beiden Gates, am `Makefile`
und an `.claude/settings.json` keine Zeile. Die 21 Fälle behalten die Klasse
"pruefstand" und ihren heutigen Wert als Soll bis zur nächsten Änderung am
Prüfmittel; mit ihr erhalten sie die Klasse aus der Spalte "Folge": "grenze"
für ZF10a, ZF10b, ZF10d und L10 bis L16, "durchlaufend" für ZF9, "blockierend"
für ZF10c. L01 bis L09 führen bis zum Bau ihres Postens die Klasse "belegte
Lücke" mit der Postennummer im Vermerk — nach ADR 0002, 6.13 g ist ein solcher
Vermerk ein offener Befund, und offene Befunde sind sie —, danach Soll 2 und die
Klasse "blockierend". Die **Zählung der Fallklassen bleibt mit diesem Nachtrag
bei 23.** Sie ändert sich erst mit den Änderungen an den Kopfkommentaren, die
er auslöst (Grenze an der Schnittstelle in beiden Gates, Grenze der Auswertung
im main-Gate, GP-3 nach dem Bau von Posten 2), und wird dann nach
ADR 0002, 6.13 d einmal neu abgezählt und im Prüfmittel geführt. P38 trägt im
Prüfmittel ebenfalls die Klasse "pruefstand"; er ist nicht Gegenstand von
Entscheid 2, bleibt als Preis P38 Restbefund der Abnahme und wird hier nicht
entschieden.

**Nachtrag vom 2026-10-14 — Posten 1 gebaut; Einordnungen nach dem Massstab
des Nachtrags vom 2026-09-23 (Erreichbarkeit, Vertrag, Mittel).**

Dieser Nachtrag ist die Fortschreibung vom 2026-10-14, auf die der
Kopfkommentar von `.claude/hooks/block-main-write.sh` mit "ADR 0002, 6.13 c,
Fortschreibung vom 2026-10-14" verweist (B2-GATE-D02). Er ordnet die Befunde
aus dem Bau von Posten 1 und aus seiner Verifikation ein; Bau, Läufe und
Verifikation stehen im Status-Block von ADR 0002, 6.13, Nachtrag vom
2026-10-14. Eingeordnet hat der Software Architect am 2026-10-14 in vier
Schritten, auf Vorlage des Koordinators, mit Fremdbeleg des Dynamic Software
Testers und des Koordinators, dieser mit echtem git 2.43.0 in Wegwerf-Klonen.
Der Wortlaut des Nachtrags vom 2026-09-23 oben bleibt unverändert (ADR 0002,
6.1, Absatz "Anlass"). Posten 1 hat nach der Festlegung zwei Sachverhalte:
(i) Die Ziele von push und `worktree add` werden nach dem Entfernen von
Anführungszeichen und Rückstrichen verglichen; (ii) die Ausnahme für -b und
-B greift nicht, wenn der neue Zweig main oder master heisst.

**Der Vorbehalt in der ersten Baurunde.** Er griff bei DT-B2-01. Die neue
Klasse von Fehlalarmen entstand nicht aus der Festlegung, die den bereinigten
Vergleich nur für die Ziele verlangt, sondern aus ihrer Überdehnung auf das
Verb; mit der Rücknahme auf die Ziele ist sie geschlossen (Gegenproben G55
bis G58, Soll 0, gemessen 0). Die Festlegung selbst öffnete keine neue
Klasse, wie es der Nachtrag vom 2026-09-23 für L01 bis L03 erwartet hat
("Eine neue Klasse von Fehlalarmen ist nicht zu erwarten, weil beide Muster
ein Anführungszeichen vor main heute schon als Ziel werten").

| Fall oder Befund | Gate | heute gemessen | Einordnung | Begründung | Folge |
|---|---|---|---|---|---|
| L01, L02, L03, L04 | main | 2 | geschlossen in Posten 1 (L01 bis L03: Sachverhalt i; L04: Sachverhalt ii) | Wie im Nachtrag vom 2026-09-23 festgelegt. Lauf 1 der ersten Baurunde fiel an L01 bis L04 und an A54 bis A57; nach der Änderung am Gate bestanden alle Fälle. | Soll 2, Klasse "blockierend"; der Vermerk nennt die Schliessung am 2026-10-14 und führt den früheren Wortlaut hinter "vormals Pruefstand: " (B2-PM-13); Mutationen MM9, MM10, MM11 |
| ZF10a, ZF10b | main | 0 | (a) Grenze an der Schnittstelle, Fallklasse GM-6 | Entschieden im Nachtrag vom 2026-09-23; mit dieser ersten Änderung am main-Gate im Kopfkommentar benannt ("GRENZE AN DER SCHNITTSTELLE (Werkzeugname), ehrlich benannt"). | Klasse "grenze", Soll 0; der frühere Vermerk wiederhergestellt, ein datierter Nachtrag "vormals Pruefstand" davor; der Teil für ZF10d folgt mit Posten 2 (Absatz "Zählung der Fallklassen") |
| DT-B2-01 | main | 0 (erste Fassung 2) | Vorbehalt griff: neue Klasse von Fehlalarmen, geschlossen durch die Rücknahme auf die Ziele | In der ersten Fassung liefen das Verb (push, `worktree add`) und die Sammel-Push-Optionen über cmd_ziel; `git log --all --grep "push"`, `git log -S "git push" --oneline main` und `git commit -m "push main"` gingen von 0 auf 2. Die Klasse folgt aus der Überdehnung der Festlegung auf das Verb (Absatz oben). | Verb und Sammel-Push-Optionen wieder am Befehlstext; Gegenproben G55 bis G58 (Soll 0); Anführungszeichen am Verb siehe DT-B2-08 |
| DT-B2-02 | main | 2 (erste Fassung 0) | Regression, geschlossen | In der ersten Fassung lief die Ausnahme für -b/-B auf cmd_ziel; maskierte Leerzeichen im Pfad wurden zu " -b ". `git worktree add /tmp/a\ -b\ x main` gab vor Posten 1 2, in der ersten Fassung 0; mit echtem git entsteht der Arbeitsbaum auf main. Die Festlegung verlangt den bereinigten Vergleich nur für die Ziele. | Ausnahme wieder am Befehlstext; Mutation MM12 legt sie zurück auf cmd_ziel (A58, A75) |
| DT-B2-03 | main | 2 | (c) belegte Lücke, Sachverhalt ii von Posten 1, geschlossen | Wert hinter -b/-B angehängt oder gebündelt (`git worktree add -Bmain /tmp/wt`, `-bmain`, `-fBmain`): Mit echtem git entsteht der Arbeitsbaum auf main ("Preparing worktree (new branch 'main')"); vor Posten 1 und in der ersten Fassung 0. Erreichbarkeit und Vertrag (KM-6) ja; es ist derselbe Sachverhalt wie L04 in einer anderen Schreibweise der Optionen. Mittel ja: Buchstaben vor b oder B und null oder mehr Leerzeichen vor dem Namen zulassen. | Neue Prüfung vor der worktree-Sperre (Status-Block); Fälle A59, A60, A61, A73 (Soll 2), Regressionsschutz A74 (2 vorher wie nachher), Gegenproben G50 (-bmainline), G66 (-Bfmain), G67 (-fB feature); Mutation MM13; Preis in sicherer Richtung: -Bbmain wird mitgesperrt; die Ausnahme ist nicht verbreitert |
| DT-B2-04 | main | 2 | (c) belegte Lücke, Sachverhalt i von Posten 1, geschlossen | Zeilenfortsetzung im Ziel (`git push origin ma\<Zeilenumbruch>in`): Mit bash belegt fügt die Shell zu main zusammen, nach demselben Mechanismus wie bei DT-B2-09 (Rückstrich und Zeilenumbruch fallen vor der Wortzerlegung weg, POSIX Shell Command Language 2.2.1); der Rückstrich vor dem Zeilenumbruch ist ein Rückstrich im Sinne der Festlegung. Mittel ja: nur das Paar aus Rückstrich und Zeilenumbruch bei ungerader Zahl von Rückstrichen entfernen, keine anderen Zeilen zusammenziehen. | Erster Schritt von cmd_ziel; Fälle A62, A63, A64 (Soll 2), Regressionsschutz A65 (ein Zeilenumbruch ohne Rückstrich verbindet nicht) und A66 (zwei Rückstriche sind ein maskierter Rückstrich), Gegenprobe G51 (mainline); Mutation MM14 |
| DT-B2-05 a und b | main | 0 | (a) Grenze GM-7, festgeschrieben | -b/-B in Anführungszeichen (`git worktree add '/tmp/a -b x' main`) oder im Kommentar (`git worktree add /tmp/wt main # -b x`): mit echtem git je Arbeitsbaum auf main. Erreichbarkeit und Vertrag (KM-6) ja; Mittel nein: Quotierung und Kommentar zu unterscheiden hiesse, die Token-Erkennung der Shell nachzubilden; jede Näherung mit Mustern öffnete neue Fehlalarme (eine Option in Anführungszeichen, eine Raute in einem Argument vor -b, -b nach dem Pfad). | Absatz "GRENZE DER AUSNAHME FUER -b/-B, ehrlich benannt" im Kopfkommentar, beginnend mit "benannt seit Posten 1", weil die Ausnahme den Befehlstext schon vor Posten 1 las (B2-GATE-D06); Fälle G59, G60 (Soll 0, Klasse "grenze") |
| DT-B2-05 c | main | 0 | (c) belegte Lücke, Posten 4 a unter R3-Q-010 | Befehlskette `git worktree add -b x /tmp/w1 main; git worktree add /tmp/w2 main`: Mit echtem git steht w2 auf main; das Gate gibt 0, weil die Ausnahme auf die ganze Eingabe wirkt. Erreichbarkeit und Vertrag (KM-6) ja; Mittel ja: die Ausnahme an den worktree-add-Abschnitt binden, in dem sie steht. Das ändert den Aufbau der Sperre und gehört nicht zum Sachverhalt von Posten 1. | Fall L17 (Soll 0, Klasse "belegte Lücke", BEFUND_VON "DT-B2-05 (Posten 4 unter R3-Q-010)"); Posten 4 a unten |
| DT-B2-07 | main | 2 | (c) belegte Lücke, Posten 1, geschlossen | `git worktree add -B $'main' /tmp/wt`: mit echtem git Arbeitsbaum auf main, das Gate gab 0. Ohne Escape-Folge sind `$'...'` und `$"..."` lexikalisch; ein Dollarzeichen unmittelbar vor einem Anführungszeichen entfällt mit diesem. Mit bash geprüft: `ma$'in'`, `$'ma'in`, `$"main"` und `$'main'` ergeben je das Wort main. GM-5 bleibt auf Escape-Folgen in `$'...'` (hexadezimal, oktal) und die Übersetzung von `$"..."` über einen Meldungskatalog beschränkt. | Dritter Schritt von cmd_ziel; Fälle L18, A69, A70, A71, A72 (Soll 2), Gegenprobe G65 (-B mit `$'feature'`), Grenze G63, G64, G68 (Escape-Folgen, GM-5), Regressionsschutz A75 (-b in Dollar-Anführungszeichen im Pfad; die Ausnahme liest den Befehlstext); Mutation MM15. Ohne Katalog ergibt `$"main"` das Wort main und wird gesperrt (am Gegenstand 2); seit der dritten Baurunde führt GM-5 den Fall G71 (`git push origin $"zweig"`, Soll 0; B2-PM-15) |
| DT-B2-08 | main | 0 (vor Posten 1 0, erste Fassung 2) | (a) Grenze GM-8, festgeschrieben | Sammel-Push-Option oder Verb in Anführungszeichen (`git push origin "--all"`, `git push origin '*:*'`, `git push "--mirror" origin`, `git pu"sh" origin main`); vorbestehend, nicht Posten 1. Erreichbarkeit ja; Vertrag ja (der Kopfkommentar führt Mirror- und Wildcard-Pushes als gedeckt); Mittel nein: Das Sammel-Push-Muster wertet ein Anführungszeichen neben dem Wort nicht, anders als die Zielmuster neben main; das Entfernen verschöbe Wortgrenzen und öffnete eine neue Fehlalarmklasse (Messkopie V5 des Dynamic Software Testers: `git push origin feature -o "ci.variable=X --all"` von 0 auf 2). Auch das Lesen nur vollständig quotierter Wörter liesse `--"all"`, `\--all` und `git "push" --all origin` durch. Das Verb in Anführungszeichen, nach DT-B2-01 bewusst 0, gehört in dieselbe Grenze. | Absatz "GRENZE AM BEFEHLSTEXT (Verb und Sammel-Push-Optionen), ehrlich benannt" im Kopfkommentar; Fälle G69 (`git push origin "--all"`) und G70 (`git pu"sh" origin main`), Soll 0, Klasse "grenze" |
| DT-B2-09 | main | 0 (vor Posten 1 0) | (c) belegte Lücke, Posten 4 b unter R3-Q-010 | Verb durch Zeilenfortsetzung getrennt (`git \<Zeilenumbruch>push origin main`, `git worktree \<Zeilenumbruch>add /tmp/wt main`); vorbestehend; nicht Posten 1, denn die Festlegung nennt die Ziele und -b/-B, nicht das Verb. Erreichbarkeit ja; Vertrag ja: Die Shell entfernt Rückstrich und Zeilenumbruch vor der Wortzerlegung (POSIX Shell Command Language 2.2.1), git erhält dieselben Argumente wie bei `git push origin main`, der Beleg mit bash-Semantik genügt. Mittel ja: derselbe erste Schritt wie in cmd_ziel, nur die Zeilenfortsetzung; Anführungszeichen und übrige Rückstriche bleiben, keine Wortgrenze verschiebt sich. Posten 4 statt eines eigenen Postens: Der Schritt muss für Verb, Sammel-Push-Optionen und Ausnahme zugleich gelten — zöge nur das Verb nach, ginge der zulässige Befehl `git worktree \<Zeilenumbruch>add -b x /tmp/wt main` von 0 auf 2 —, und auf genau diesem Text bildet Posten 4 a seine Abschnitte. | Fall L19 (`git \<Zeilenumbruch>push origin main`, Soll 0, Klasse "belegte Lücke", BEFUND_VON "DT-B2-09 (Delta-Pruefung Posten 1, 2026-10-14): Verb durch Zeilenfortsetzung getrennt; Posten 4 unter R3-Q-010"); die worktree-Form kommt mit dem Bau von Posten 4; Posten 4 b unten |
| B2-PM-14, B2-GATE-D03 | main | 2 (vor Posten 1 0) | Preis in sicherer Richtung, Teil von GM-7 (sperrende Richtung) | -b/-B main als Inhalt in einer Eingabe, die das Gate seit jeher am Text als `worktree add` liest: Commit-Meldung (`git commit -m "Doku: worktree add -b main"`), Suchmuster (`git log --oneline --grep "Posten 1 worktree add -B main"`), Pfad in Anführungszeichen (`git worktree add -b feature "/tmp/a -B main"`), Kommentar (`git worktree add -b feature /tmp/wt main # -B main`). Der Vorbehalt greift nicht, weil keine neue Fehlalarmklasse entsteht: Weder die textbasierte Erkennung von `worktree add` noch die Wertung eines Anführungszeichens neben main ändert sich (die Zielmuster werten es schon, Nachtrag vom 2026-09-23 zu L01 bis L03). Die neu gesperrten Formen nennen die verbotene Handlung als Inhalt, die bestehende, gewollte Klasse "Wörter nur als Inhalt" (`.claude/rules/claude-konfiguration.md`, Abschnitt Hooks); derselbe Inhalt ohne -b/-B sperrte schon vor Posten 1 (`git commit -m "Doku: git worktree add /tmp/wt main"`, 2 vorher wie nachher). Vor Posten 1 rettete diese Formen nur die Ausnahme am Text, die L04 für den Namen main zurücknimmt; cmd_ziel ist nötig, weil L04 selbst `-B "main"` ist. Nicht gewählt: eine engere Fassung (die Bindung an den Abschnitt ändert an der Commit-Meldung nichts; nur einen git-Aufruf am Befehlsanfang zu zählen liesse L04 hinter `env git worktree add -B main /tmp/wt` offen) und der Rückbau (er öffnete L04 wieder; nach `.claude/rules/claude-konfiguration.md`, Abschnitt Hooks, kostet ein Fehlalarm einen Versuch, ein übersehener Push nach main mehr). | Fälle A78, A79 (Soll 2, Klasse "blockierend", Fallklasse GM-7, Vermerk "Preis GM-7, sperrende Richtung (B2-PM-14): Inhalt nennt -b/-B main"); Absatz zum Preis im Absatz zu GM-7 des Kopfkommentars, mit dem Ausweg, eine Commit-Meldung mit dem Write-Werkzeug in eine Datei zu schreiben und `git commit -F <datei>` zu verwenden |
| B2-GATE-D04 | main | 2 (vor Posten 1 2) | Preis in sicherer Richtung, vorbestehend | `git push origin \$'main'` (maskiertes Dollarzeichen): Die Shell ergibt ein Wort mit Dollarzeichen vor main; das Gate sperrt, weil das Zielmuster am Befehlstext das Anführungszeichen vor main wertet (Nachtrag vom 2026-09-23 zu L01 bis L03). Die Reihenfolge der Schritte in cmd_ziel bleibt: Eine andere Reihenfolge änderte den Rückgabewert nicht, bräuchte für den Dollar-Schritt die Regel der ungeraden Rückstriche, und die heutige weicht nur in sicherer Richtung ab. | Fall A77 (Soll 2, Fallklasse KM-13, Vermerk "Preis (B2-GATE-D04): die Shell ergibt ein Wort mit Dollarzeichen vor main; das Zielmuster am Befehlstext wertet das Anfuehrungszeichen vor main (6.13 c zu L01 bis L03)") |
| B2-GATE-D05 | main und Prototyp | 0 am main-Gate (vor Posten 1 0); am Prototyp-Gate dieselbe Bauform, nicht gemessen | (c) belegte Lücke, Posten 5 unter R3-Q-010, beide Gates | Unter `set -uo pipefail` liefert die Pipeline aus `printf` und `grep -Eq` den Wert 141 (SIGPIPE), wenn grep nach einem frühen Treffer endet, während printf noch schreibt; die Bedingung gilt dann als nicht erfüllt. `git push origin main` mit einer folgenden Kommentarzeile läuft durch, sobald die Zeile gross genug ist (gemessen 0 bei 150000 Zeichen und mehr). Die Grenze ist keine feste Zahl: Unter etwa 64 KiB sperrt das Gate, zwischen etwa 65000 und 120000 Zeichen entscheidet ein Wettlauf zwischen printf und grep, ab 131072 Zeichen lässt es in 30 von 30 Läufen durch (DT-B2-10, altes und neues Gate gleich betroffen). Das Prototyp-Gate hat dieselbe Bauform. Erreichbarkeit ja (die Länge setzt das Modell); Vertrag ja (jede als gedeckt geführte Klasse beider Gates; nach ADR 0002, 6.13 b blockiert, was das Gate nicht prüfen kann — hier lässt es durch, gerade bei einem frühen Treffer); Mittel ja: Es geht um die Ausführung der Prüfung, nicht um eine Erkennungsform — gleiche Muster ohne Abbruch des Schreibers, etwa über einen Here-String oder grep ohne -q, ohne Auswertung und ohne neue Fehlalarmklasse. Nicht Posten 1 und nicht Posten 4, weil jede Prüfstelle beider Gates betroffen ist. | Fall L20 am main-Gate (`git push origin main` mit einer Kommentarzeile aus 200000 Rauten, stabil 0 in 30 von 30 Läufen (DT-B2-10), gemessen 0 auch bei 150000, 300000 und 2000000; Soll 0, Klasse "belegte Lücke", BEFUND_VON "B2-GATE-D05 (2026-10-14): grosse Eingabe, SIGPIPE unter pipefail; Posten 5 unter R3-Q-010"); der Fall am Prototyp-Gate folgt erst mit Beleg beim Bau von Posten 5; Posten 5 unten |
| Basename-Form | main | 0 (vor Posten 1 0) | (c) belegte Lücke, Posten 4 c unter R3-Q-010 | `git worktree add <pfad>/main` ohne commit-ish checkt den bestehenden Zweig main im neuen Arbeitsbaum aus (echtes git 2.43.0, `git worktree list`: "[main]"), ebenso `git worktree add ../main`; KM-6 führt das Anlegen eines Arbeitsbaums auf main als gedeckt. Vorbestehend; offene Frage des Static Software Testers, vom Koordinator belegt. Mittel ja: lexikalisch am worktree-add-Abschnitt aus Posten 4 a, auf cmd_ziel — nach den Optionen genau ein Wort, das auf /main oder /master endet; kein --detach; die Ausnahme für -b/-B wie sonst; ein zweites Wort ist der commit-ish (`git worktree add /tmp/wt origin/main` zählt nicht); `git worktree add main` sperrt schon heute. Eine neue Fehlalarmklasse ist nicht zu erwarten; beim Bau gilt der Vorbehalt. | Fall L21 (`git worktree add ../main`, Soll 0, Klasse "belegte Lücke", BEFUND_VON "Basename-Form (2026-10-14, echtes git 2.43.0): worktree add ../main ohne commit-ish checkt main aus; Posten 4 unter R3-Q-010"); Posten 4 c unten |

**Posten 4 und Posten 5 unter R3-Q-010.** Beide sind vorbestehende Lücken,
keine Folge von Posten 1, und neue Arbeit an den Gates. Dieser Nachtrag ist
der Fundort für die Verweise "Posten 4 unter R3-Q-010" und "Posten 5 unter
R3-Q-010" in Gate und Prüfmittel; die Aufnahme in den Backlog macht der
Product Owner in den Nachführungen dieser Sitzung (Backlog, `CLAUDE.md`,
Nachweise; Schritt B5 des Sitzungsauftrags vom 2026-10-14, festgehalten in
der Übergabe der Sitzung), nach der Präzedenz der drei Posten oben
(B2-GATE-D02).

4. **Posten 4, main-Gate:** in einem Bau, zuerst b, dann a; c setzt auf dem
   Abschnitt aus a auf.
   - a) **Befehlskette (DT-B2-05 c, L17):** Die Ausnahme für -b und -B gilt
     nur für den worktree-add-Abschnitt, in dem sie steht, bis zum nächsten
     Trenner (|, ;, & oder Zeilenumbruch); das Ziel wird im Befehlstext ohne
     die Abschnitte mit gültiger Ausnahme geprüft, am Befehlstext wie an
     cmd_ziel.
   - b) **Zeilenfortsetzung in den Prüfungen am Befehlstext (DT-B2-09,
     L19):** Verb (push, worktree add), Sammel-Push-Optionen und Ausnahme für
     -b/-B werden auf dem Befehlstext geprüft, in dem nur die
     Zeilenfortsetzungen entfernt sind (wie im ersten Schritt von cmd_ziel);
     Anführungszeichen und übrige Rückstriche bleiben (Grenze GM-8).
   - c) **Basename-Form (L21):** Das Gate sperrt einen worktree-add-Abschnitt,
     der nach den Optionen genau ein Wort trägt, das auf /main oder /master
     endet, ohne --detach; die Ausnahme für -b/-B gilt wie sonst; geprüft auf
     cmd_ziel am Abschnitt aus a. Ein zweites Wort ist der commit-ish
     (`git worktree add /tmp/wt origin/main` zählt nicht).

   Mit dem Bau wechseln von 2 auf 0 nur Formen, die die Shell nicht als
   Sperrfall liest — `git worktree add \<Zeilenumbruch>  -b x /tmp/wt main`
   und `git push origin feature -o x\<Zeilenumbruch>--all`, deren heutige
   Fehlalarme in sicherer Richtung entfallen —, und -b in mehrzeiligem Text
   in einfachen Anführungszeichen (GM-7). Regressionsschutz: "Kein Fall, der
   in der Shell ein Sperrfall ist und heute blockiert, läuft danach durch,
   ausser innerhalb einer benannten Grenze (GM-7)."
5. **Posten 5, beide Gates (B2-GATE-D05, L20):** Jede Prüfstelle beider Gates
   prüft so, dass der Abbruch des Schreibers durch SIGPIPE (Rückgabewert 141
   unter `pipefail`) nicht als "kein Treffer" gilt, etwa über einen
   Here-String oder grep ohne -q; die Muster bleiben unverändert. Die Schwelle
   ist keine feste Zahl (DT-B2-10): Unter etwa 64 KiB sperrt das Gate, bis
   etwa 128 KiB entscheidet ein Wettlauf; ein Fall in diesem Bereich taugt
   nicht als fester Wert, L20 liegt mit 200000 Zeichen darüber. Mit dem Bau
   erhält L20 das Soll 2; der Fall am Prototyp-Gate folgt mit Beleg, der
   Verweis im Kopfkommentar des Prototyp-Gates mit der nächsten Änderung dort.
   Der Software Architect empfiehlt dem Auftraggeber, Posten 5 vor Posten 2
   und 3 einzuordnen, weil die Lücke jede Prüfung beider Gates unabhängig von
   der Form umgeht und Posten 2 und 3 Prüfstellen des Prototyp-Gates mit
   derselben Bauform ändern. Vor dem Entscheid über die Reihenfolge bewertet
   der Vulnerability Manager Posten 5 nach CVSS, als eigener Auftrag;
   ungeprüft ist, ob `.claude/hooks/dod-gate.sh` dieselbe Bauform trägt, das
   gehört in diese Bewertung. In dieser Einheit ist Posten 5 nur erfasst; am
   Verhalten der Gates ändert sie dazu nichts.

Für Posten 4 und Posten 5 gilt der Rahmen der drei Posten oben:

- **Bauvorschrift** nach ADR 0002, 6.13 g, mit einer Mutation je Behebung
  (ADR 0002, 6.13 d, Punkt 6) und je Sachverhalt einem blockierenden und
  einem durchzulassenden Gegenstand; die Gegenproben des Regressionsschutzes
  bleiben grün (ADR 0002, 6.13 f, Punkt 1 und 2).
- **Rollen** nach ADR 0002, 6.13 e: Umsetzung durch den SecDevOps Engineer,
  Verifikation durch Static und Dynamic Software Tester auf einem anderen
  Modell als die Umsetzung (ADR 0002, 6.13 f, Punkt 4; Projektauftrag 3.4).
- **Terminierung:** mit der nächsten Änderung am jeweiligen Gate — für
  Posten 4 am main-Gate, für Posten 5 an jedem der beiden —, spätestens vor
  der Freigabe des Grundgerüsts. Die Einordnung in die Reihenfolge legt der
  Auftraggeber fest.
- **Vorbehalt** wie für die drei Posten.

**Zählung der Fallklassen.** Der Nachtrag vom 2026-09-23 hat die Zählung bei
23 belassen; sie ändert sich mit den Änderungen an den Kopfkommentaren, die er
auslöst, und wird dann "einmal neu abgezählt". Mit Posten 1 steht sie bei 28
(am main-Gate neu KM-13, GM-5, GM-6, GM-7 und GM-8; 21 am main-Gate, 7 am
Prototyp-Gate). Der Teil für das Prototyp-Gate — die Grenze an der
Schnittstelle für ZF10d als Fallklasse und GP-3 ohne den Typ "grenze" — folgt
mit Posten 2. Die Zählung wird damit in zwei Schritten abgeschlossen, nicht in
einem; das weicht vom Wortlaut "einmal" ab. Grund: Die Klassen des
Prototyp-Gates werden nach ADR 0002, 6.13 d einmal aus dem Text seines
Kopfkommentars abgezählt, und dieser ändert sich erst mit Posten 2; der Lauf
prüft nur, dass jede definierte Fallklasse gedeckt ist.

**Klassenwechsel der Prüfstand-Fälle.** Der Nachtrag vom 2026-09-23 hat
festgelegt, dass die 21 Prüfstand-Fälle mit der nächsten Änderung am
Prüfmittel die Klasse aus der Spalte "Folge" erhalten. Das ist mit Posten 1
vollzogen. Am main-Gate tragen ZF10a und ZF10b die Klasse "grenze"; L01 bis
L04 laufen nach dem Bau mit Soll 2 und der Klasse "blockierend". Am
Prototyp-Gate tragen ZF9 die Klasse "durchlaufend", ZF10c "blockierend",
ZF10d und L10 bis L16 "grenze", L05 bis L08 die Klasse "belegte Lücke" mit
dem Vermerk "Posten 2 unter R3-Q-010 (ADR 0002, 6.13 c)" und L09 die Klasse
"belegte Lücke" mit dem Vermerk "Posten 3 unter R3-Q-010 (ADR 0002, 6.13 c)",
je mit dem heutigen Wert als Soll und dem Vermerk als datiertem Nachtrag vor
dem bisherigen Wortlaut. P38 bleibt "pruefstand"; er ist nicht Gegenstand von
Entscheid 2. Am Prototyp-Gate selbst ist keine Zeile geändert.

**Die zwei weiteren Formen aus DT-E41-04.** Die Übergabe zu E4.1
(`docs/uebergaben/2026-09-23_e4-1-pruefmittel-pretooluse-gates.md`) nennt sie
nur der Zahl nach, nicht dem Inhalt nach. Sie liegen damit nicht im
Fremdbeleg vor; es gab nichts zur Einordnung vorzulegen, und sie bleiben
nicht Gegenstand. Die Befunde, die dieser Nachtrag einordnet, stammen aus dem
Bau und der Verifikation von Posten 1.

**Restpunkte, nicht geschlossen.**

- `git worktree add -bfeature /tmp/wt main` gibt wie vor Posten 1
  Rückgabewert 2: ein Fehlalarm in sicherer Richtung, nicht Gegenstand; die
  Ausnahme verlangt Leerraum oder "=" hinter -b/-B.
- `git worktree add \<Zeilenumbruch>  -b x /tmp/wt main` gibt Rückgabewert 2:
  ein Fehlalarm in sicherer Richtung, weil das Gate zeilenweise prüft und die
  Ausnahme "-b" nicht auf der Zeile von `worktree add` findet; nicht als Fall
  aufgenommen, er entfällt mit Posten 4 b.
- GP-3 behält den Typ "grenze" bis Posten 2.
- P38 bleibt "pruefstand", Restbefund der Abnahme von R3-Q-010.
- In der zweiten Verifikationsrunde nicht geprüft: die Wirkung im laufenden
  Harness (die Hooks wirken in dieser Sitzung nicht) und echtes git für
  -qbmaster und für die Formen von DT-B2-09.
- In der dritten Verifikationsrunde nicht geprüft: die Wirkung im laufenden
  Harness, der Wettlauf aus DT-B2-10 unter paralleler Last und das
  Prototyp-Gate (Posten 5 ist nur am main-Gate gemessen).
- Ein Schwachstellenregister (Projektauftrag 4.2, Rolle Vulnerability
  Manager) besteht im Repository noch nicht. Seine Anlage legt die Übergabe
  der Einheit dem Auftraggeber zum Entscheid vor; dieser Nachtrag entscheidet
  sie nicht. *Überholt am 2026-10-21: Das Register besteht, siehe Nachtrag vom 2026-10-21 unten, Absatz "Register".*
- Die Befundkennungen dieses Nachtrags (DT-B2-…, B2-GATE-…, B2-PM-…) führt
  die Übergabe der Einheit mit Fundort (B2-GATE-D09).
- GM-8 ist nur mit G69 und G70 gemessen; die Formen hinter einem Rückstrich,
  `'*:*'` und `"--mirror"` in Anführungszeichen sowie `worktree "add"` haben
  keinen eigenen Fall. Die Fallwahl trifft der Software Architect mit der
  nächsten Änderung am Prüfmittel (B2-GATE-R3-01, B2-PM-19).
- Die Nachtragszeile im Kopfkommentar ordnet GM-5 auch den
  Mirror-/Wildcard-Pushes zu; kein Fall misst eine Sammel-Push-Option oder
  Wildcard-Refspec, die erst durch die Auswertung der Shell entsteht. Die
  Aussage trifft zu, ist aber ungemessen (B2-GATE-R3-02).

In der dritten Verifikationsrunde ist Posten 1 verifiziert (ADR 0002, 6.13,
Status-Block); mit echtem git belegt sind dabei die Basename-Form und A79, neu
ist der nachrangige Befund DT-B2-10 (Zeile zu B2-GATE-D05 und Posten 5). Die
statische Prüfung dieses Nachtrags ergab drei blockierende Befunde an
Zuordnung und Zahlen (B2-ADR-01 bis B2-ADR-03), in dieser Fassung behoben.
Zwei weitere Delta-Prüfungen ergaben einen weiteren blockierenden Befund
(B2-ADR-09, Begründung der Fallklassen-Zählung) und die nachrangigen
B2-ADR-10 bis B2-ADR-16; behoben sind in dieser Fassung auch die nachrangigen
B2-ADR-04, B2-ADR-05, B2-ADR-07 und B2-ADR-08 der ersten Prüfung sowie
B2-ADR-09 bis B2-ADR-13, als Restpunkte in der Übergabe geführt sind
B2-ADR-06 und B2-ADR-14 bis B2-ADR-16.

**Nachtrag vom 2026-10-21 — Posten 4 und 5 gebaut; Einordnungen aus Bau und
Verifikation; Posten 6 und 7 erfasst.**

Dieser Nachtrag ist der Fundort für die Verweise "ADR 0002, 6.13 c, Nachtrag
vom 2026-10-21", "Posten 6 unter R3-Q-010" und "Posten 7 unter R3-Q-010" in
Gates und Prüfmittel. Er ordnet die Befunde aus dem Bau von Posten 4 und 5 in
der Einheit C2 und aus dessen Verifikation ein; Bau, Läufe und Verifikation
stehen im Status-Block von ADR 0002, 6.13, Nachtrag vom 2026-10-21 zum Bau von Posten 4 und 5.
Eingeordnet hat der Software Architect am 2026-10-21 in fünf Schritten auf
Vorlage des Koordinators, mit Fremdbeleg des SecDevOps Engineers und der
beiden Prüfrollen; die Befunde der Delta-Runden (ST-C2-D-…, DT-C2-D-01,
ST-C2-E-…, DT-C2-E-…, ST-C2-F-…, DT-C2-F-…, DT-C2-G-01, ST-C2-G-…) hat der
Koordinator nach demselben Massstab eingeordnet, zu A139 bis A142 und A149
entscheidet dieser Nachtrag nach dem Vorbehalt (Posten 4 c). Der Wortlaut
des Nachtrags vom 2026-10-14 oben bleibt unverändert (ADR 0002, 6.1, Absatz
"Anlass").

**Posten 5, Form.** Posten 5 ist in beiden Gates als je eine Hilfsfunktion
`trifft` gebaut, über die jede Prüfung mit `grep -q` mit unverändertem Muster
läuft: Sie prüft über `printf '%s' "$text" | grep -Eq` und liest in der
ersten Anweisung danach PIPESTATUS aus — grep 0 ist ein Treffer, auch wenn
der Schreiber durch SIGPIPE abgebrochen wurde, grep 1 ist nur zusammen mit
Schreiber 0 kein Treffer, und jeder andere Ausgang beendet das Gate mit
Meldung und Rückgabewert 2 (6.13 b); die Funktion wird nie aus einer Subshell
aufgerufen. Die Form erfüllt den Hauptsatz von Punkt 5, ohne eines der beiden
dort mit "etwa" genannten Beispiele zu sein: grep behält -q, weil der Abbruch
des Schreibers nicht mehr über den Rückgabewert der Kette entscheidet, und das
Beispiel Here-String ist zurückgenommen, weil bash ihn ab Pipe-Grösse über
eine temporäre Datei führt und ein Fehler dort mit 1 endet, nicht
unterscheidbar von "kein Treffer" (gemessen bei vollem /tmp). Die Form
`grep -E >/dev/null` wirkte in der Messung nur wegen der Bauart von GNU grep
3.11 und ist nicht gewählt. Die übrigen Musterprüfungen (Zählung,
sed-Adressen, `grep -oE`, `jq`) brechen nicht mit -q ab und laufen nicht über
`trifft` (ST-C2-01, ST-C2-D-04).

**Posten 5, Fehlerpfad und Fälle.** Der Fehlerpfad gilt in beiden Richtungen
der Prüfung: `pruefung_unmoeglich` meldet 6.13 b und den nächsten Schritt und
endet mit 2; die Vergleiche lesen `${st[0]:-}` und `${st[1]:-}`, damit ein
unvollständiger PIPESTATUS unter `set -u` nicht mit 1 endet. Damit sperrt
auch ein fehlendes grep, das vorher mit 127 als kein Treffer galt: S10 und S11
(PATH ohne grep) sowie S13 und S14 (grep endet mit 1, ohne zu lesen) je
Soll 2, Mutationen MM20, MP13, MM24 und MP14. L20 (200000 Zeichen) und am
Prototyp-Gate L22 (Bash), B64 (Richtung 1 über Write) und B65 (Richtung 2)
geben in 30 von 30 Läufen gegen das neue Gate 2 und gegen das alte 0; das
ist der in Punkt 5 angekündigte Fall am Prototyp-Gate mit Beleg. Dazu A80 bis
A84 (grosse Eingabe an weiteren Prüfstellen des main-Gates), die Gegenproben
G72, G73, P40 und P41 und die Mutationen MM16 und MP12; Fallklassen KM-18 und
KP-5. Der Wettlauf zwischen printf und grep bleibt bestehen, entscheidet aber
nicht mehr; die Schwelle aus DT-B2-10 fällt aus der Entscheidung, und es
bleibt die Zeitgrenze des Hooks (Posten 7). Die offene Frage aus Punkt 5 zu
`.claude/hooks/dod-gate.sh` beantwortet das Register (SR-001, Bauteil):
dieselbe Bauform an zwei Stellen, nach dem Lesebefund nicht betroffen, nicht
gemessen; das DoD-Gate ist nicht geändert.

**Posten 4 a.** Der Rest ist cmd_verb, der Befehlstext ohne
Zeilenfortsetzungen, ohne die Abschnitte mit gültiger Ausnahme; die
Zielprüfung läuft über den Rest, am Text und nach `ziel_normalisieren`, die
Prüfung des Namens hinter -b/-B über die ganze Eingabe. Das ist der Wortlaut
der Festlegung; eine Prüfung je Abschnitt hätte an einem Zeilenumbruch in
Anführungszeichen Verb und Ziel getrennt. Jeder Schritt der
Abschnittsbildung prüft seinen Rückgabewert, und eine Zählprobe verlangt,
dass die nichtleeren Abschnitte gleich Rest plus Ausnahme-Abschnitte sind;
scheitert etwas, endet das Gate mit 2, nie mit einem verkleinerten Rest (S12,
MM21; mit intakten Werkzeugen ist die Zählprobe nicht auslösbar). L17, A85
bis A88, A101 und A106 bis A109 Soll 2, Gegenproben G74 bis G76, Fallklasse
KM-15, Mutation MM17. Bei A90 griff der Vorbehalt nicht (Massstab B2-PM-14:
der Rest von A90 ist wörtlich A89, das vorher wie nachher sperrt): A90 ist
benannter Preis in sicherer Richtung, Fallklasse KM-14 "Zielprüfung am
Befehlstext, nicht am Abschnitt" mit A89, Ausweg getrennte Bash-Aufrufe.
Bei ST-C2-02 griff er: Die erste Fassung der Abschnittsbildung ersetzte ";",
"&" und "|" durch Zeilenumbrüche und machte damit einen Trenner direkt vor
main zur Wortgrenze
(`git worktree add /tmp/w feature && git branch | grep -E "dev|main"` von 0
auf 2); die Klasse ist im selben Bau behoben, indem der Zeilenumbruch vor dem
Trenner eingefügt wird und der Trenner bleibt, sodass das Zielmuster vor main
dieselbe Grenze sieht wie vor Posten 4 (G95 Soll 0, MM23; A106 bis A109
belegen, dass die Basename-Prüfung einen führenden Trenner zulässt). GM-5
umfasst neu ein worktree add in einer Befehlssubstitution oder in
Rückwärtsakzenten innerhalb eines Ausnahme-Abschnitts (G88, G89, Soll 0).

**Posten 4 b.** Verb (push, worktree add), Sammel-Push-Optionen, Ausnahme
und Abschnitte lesen cmd_verb, den Befehlstext, in dem nur die
Zeilenfortsetzungen entfernt sind; Anführungszeichen und übrige Rückstriche
bleiben (GM-8). L19, A91 und A92 Soll 2, Gegenprobe G77, Fallklasse KM-16,
Mutationen MM14 und MM18. Mit 4 b liest die Ausnahme für -b/-B den Text ohne
Zeilenfortsetzungen; dadurch fallen neben G80 auch G92 (U-1,
`git worktree add "/tmp/a \<Zeilenumbruch>-b x" main`) und G93 (U-2,
`git worktree add /tmp/wt main # \<Zeilenumbruch> -b x`) von 2 auf 0, beide
Sperrfälle der Shell und beide in der Grenze GM-7, weil sie nach dem
Entfernen der Fortsetzung wie G59 und G60 dastehen, die schon vor Posten 4
durchliefen (DT-C2-02). Die Aufzählung im Regressionsschutz ist damit um
-b/-B in Anführungszeichen jeder Art und im Kommentar fortgeschrieben, sein
Kriterium nicht; GM-7 umfasst neu -b/-B, das erst über eine
Zeilenfortsetzung neben worktree add rückt (G80, G92, G93, Soll 0). Nicht
gewählt ist, die Ausnahme zusätzlich am Text mit Zeilenfortsetzungen zu
verlangen: Das brächte den zulässigen Befehl G77
(`git worktree \<Zeilenumbruch>add -b x /tmp/wt main`) von 0 auf 2, die neue
Fehlalarmklasse, vor der DT-B2-09 warnt, und G78 zurück auf 2. Zu den
Formen, die die Shell nicht als Sperrfall liest, gehört neben G78 und G79
auch G101 (`git worktree add /tmp/wt foo\<Zeilenumbruch>main`, vorher 2 über
den Rohtext, jetzt 0; ST-C2-03 iii): Die Shell liest foomain, der Rest aus
4 a entsteht aus cmd_verb, und kein Sperrfall ist nur am Rohtext erkennbar.

**DT-C2-01, behoben mit 4 b.** Die Entfernung der Zeilenfortsetzungen lief
seit Posten 1 als sed-Schleife mit N, deren Laufzeit quadratisch mit der Zahl
der Fortsetzungen wächst (sed allein: 20000 Fortsetzungen 9,2 s, 50000 62 s);
ab etwa 150 KB riss das main-Gate die Zeitgrenze des Hooks und liess durch,
auf main seit dem Merge von Posten 1. Behoben ist das in C2 als Teil von 4 b,
nicht als eigener Posten: Der Schritt ist der, den 4 b zu cmd_fort und
cmd_verb macht und der für jeden Bash-Befehl Verb, Sammel-Push, Ausnahme und
Abschnitte trägt; 4 b legt seine Bedeutung fest, nicht die Schleife, und die
Wirkung ist die von Posten 5 (B2-GATE-D05, Vertrag 6.13 b). Der Schritt ist
linear und mit gleicher Bedeutung gebaut, `sed -zE 's/\\\n|(\\[^\n])/\1/g'`:
Rückstriche werden von links paarweise gelesen, nur ein Paar aus Rückstrich
und Zeilenumbruch fällt weg. Belegt ist das mit einem Gleichheitsvergleich
gegen die Schleife an 88573 Zeichenfolgen aus a, Rückstrich und
Zeilenumbruch bis zur Länge 10 (keine Abweichung ausser bei Text, der auf
Rückstrich und Zeilenumbruch endet; im Gate kommt er nicht vor, weil die
Befehlssubstitution den letzten Zeilenumbruch abschneidet), mit der Laufzeit
(50000 Fortsetzungen 0,11 s für das ganze Gate, 400000 höchstens 0,62 s), mit
A104 (zwei Fortsetzungen hintereinander), A105 (50000 Zeilen, Soll 2), der
Gegenprobe G94, S15 und S16 (Mutation MM25) und mit der Mutation MM22 zurück
auf die Schleife. Nicht gewählt ist die Form
`s/(^|[^\\])((\\\\)*)\\\n/\1\2/g`: Sie verbraucht ihr Kontextzeichen und
lässt von zwei Fortsetzungen hintereinander die zweite stehen
(`git \<Zeilenumbruch>\<Zeilenumbruch>push origin main` liefe durch).

**Posten 4 c.** Gesperrt wird ein Abschnitt des Rests ohne Ausnahme, der nach
den Optionen genau ein Wort trägt, das auf /main oder /master endet, auch
ohne Präfix (`git worktree add /main`, DT-C2-03), ohne --detach und ohne -d,
auch gebündelt; ein zweites Wort ist der commit-ish. Vor der Wortzählung
entfallen ein Kommentar, eine schliessende Klammer und die Umleitungen samt
Operand, auch nach `<<<`, `<<`, `<<-` und `<>` (DT-C2-04); als Deskriptor
gilt eine Ziffernfolge nur nach Leerraum oder am Textanfang (ST-C2-D-07),
dazu `{name}` (DT-C2-E-02). Die Prüfung läuft auf zwei Fassungen und sperrt,
wenn eine trifft; die Vereinigung fügt nur Sperren hinzu. Die erste Fassung
liest den Rest ohne Normalisierung und nimmt Operanden in Anführungszeichen,
mit maskiertem Zeichen oder mit offener Anführung bis zum Zeilenende mit
(DT-C2-D-01), auch mit maskierter Anführung im Operanden
(`"([^"\\]|\\.)*("|\\?$)`, ST-C2-E-02; ein Rückstrich steht als Paar mit dem
folgenden Zeichen, allein nur unmittelbar vor dem Zeilenende, ST-C2-F-01);
die zweite ist die Fassung davor, auf dem normalisierten Rest mit
unquotiertem Operanden. Die Vereinigung schliesst DT-C2-E-01: Stand `<` oder
`>` in einem Wort in Anführungszeichen vor dem Pfad
(`git worktree add --lock --reason="a>b" ../main`,
`git -c "core.x=a>b" worktree add ../main`), las die erste Fassung die
schliessende Anführung als offene, und der Operand nahm den Pfad mit; vor
Delta 2 sperrte das Gate, danach nicht mehr. Zu ST-C2-F-01: Die Klasse aus
Delta 3 (`"([^"\\]|\\.)*\\?("|$)`) liess eine Mischlesung zu, ein maskiertes
`\"` als Rückstrich und schliessende Anführung, und verschluckte so einen
Pfad dahinter (`git worktree add > "a b\"c"d\" ../main`, in der Shell ein
Arbeitsbaum auf main, nach Delta 2 mit 2, nach Delta 3 mit 0). Behoben ist
das in Delta 4 mit der einzigen Musteränderung dieser Runde (A143 bis A146
Soll 2; G109 Soll 0, unter der Klasse aus Delta 3 ein neuer Fehlalarm;
Mutation MM34 mit der Klasse aus Delta 3). Ohne die Bedingung für den
Deskriptor wurde `git worktree add ../main1>x` als Basename-Form gelesen,
eine neue Fehlalarmklasse; der Vorbehalt griff, und die Klasse ist im Bau
behoben (G102, G103 Soll 0 unter beiden Fassungen, A118, A119 Soll 2, MM28).
L21, A93 bis A100, A110 bis A115, A120 bis A138 und A143 bis A148 Soll 2
(A147, A148: `{fd2}` und `{FD}`), Gegenproben G81 bis G87, G96, G104, G107
bis G109 und G113 (`-d` mit Umleitung), Fallklasse KM-17, Mutationen MM19
(beide Fassungen), MM26, MM27, MM29, MM31 (zweite Fassung entfernt), MM32,
MM33 und MM34; die Ausdrücke sind linear gemessen (H-1: 150000 Zeichen
höchstens 0,25 s, Wachfälle A116 und A117; maskierte Anführungen als
Operand, 150000 Zeichen, höchstens 0,37 s).

**Posten 4 c, Preise und Grenzen.** Der einzige Fall des ersten Baus, der
kein Sperrfall der Shell ist und von 0 auf 2 wechselt, ist A102
(`echo "git worktree add ../main" > /tmp/x.txt`): benannter Preis der
bestehenden Klasse "Wörter nur als Inhalt"
(`.claude/rules/claude-konfiguration.md`, Abschnitt Hooks), kein Fall des
Vorbehalts, nach dem Massstab von B2-PM-14 — die Erkennung von
`worktree add` am Text bleibt, das Zielwort wird an cmd_ziel gelesen wie die
Zielmuster seit Posten 1, und derselbe Inhalt in der bisherigen Sperrform
sperrte schon vorher (A103, 2 vorher wie nachher); Ausweg Write-Werkzeug
oder `git commit -F`. Dazu kommen A139 und A140 (ST-C2-E-01: ein Operand in
Anführungszeichen schliesst erst hinter einer Abschnittsgrenze oder einem
Zeilenumbruch, das commit-ish wird unsichtbar) und A141 und A142 (`<` oder
`>` in Anführungszeichen hinter dem Pfad verschluckt das commit-ish oder
--detach): Sie sperren, wo die Shell keinen Sperrfall liest, und gaben vor
Delta 2 0. Nach dem Massstab von B2-PM-14 ist das eine neue Fehlalarmklasse,
weil sich die Erkennung der Umleitungsoperanden geändert hat; der Vorbehalt
griff. Der Koordinator hat sie als benannten Preis in sicherer Richtung
eingeordnet (A139 und A140; A141 und A142 sind Funde des Engineers), statt
L21 offen zu lassen; A149 (ein Wort in Anführungszeichen endet auf `>`
direkt vor --detach, DT-C2-F-04) gehört in dieselbe Klasse wie A141 und
A142. Diese Einordnung schreibt den Vorbehalt für diesen Fall fort: Ihre
Behebung verlangte eine Zerlegung nach der Syntax der Shell, und L21 offen zu
lassen, öffnete wieder eine Lücke in unsicherer Richtung. Alle sechs Preise
führt KM-17; Ausweg: den Befehl aufteilen. Benannte Grenzen ohne Sperre, je
Soll 0: eine Befehlssubstitution als Operand (`<<< $(echo a b)`, G105,
GM-5); unter GM-9 eine Option mit getrenntem Wert, auch in Anführungszeichen
(`--reason="a b" ../main`, G106), die Verbindung beider Fehlformen
(`git worktree add --lock --reason="a>b" ../main > "x y"`: die erste Fassung
verschluckt den Pfad, die zweite zählt den Operanden als zwei Wörter; G110),
`<` oder `>` als letztes Zeichen eines Worts in Anführungszeichen vor dem
Pfad (`--reason="a>" ../main`, G111, DT-C2-F-01) und ";", "&", "|" oder ein
Zeilenumbruch in einem Wort in Anführungszeichen vor dem Pfad, die den Pfad
vom Abschnitt trennen (`--reason="a;b" ../main`, G112, DT-C2-F-02). GM-9
umfasst ausserdem: Das Gate zerlegt nur an Leerraum; eine Option mit
getrenntem Wert (`--lock --reason x ../main`, G90) zählt als zweites Wort,
und ein Pfad in Anführungszeichen zerfällt in mehrere Wörter, an Leerraum,
Trennern, Raute, Umleitungszeichen und Zeilenumbruch (G91, G97 bis G100).
Grenze der Umleitungs-Erkennung: Die Basename-Prüfung erkennt Umleitungen und
ihre Operanden mit Einzelmustern, nicht durch eine Zerlegung nach der Syntax
der Shell; jede Prüfrunde fand eine weitere Token-Form (DT-C2-D-01,
DT-C2-E-01, ST-C2-E-02, ST-C2-F-01, DT-C2-F-01, DT-C2-F-02), und seit Delta 4
wird das Operandenmuster nicht mehr erweitert. Was die Muster nicht
erfassen, bleibt Grenze (GM-5, GM-9) oder, in sicherer Richtung, Preis
(KM-17); die Klasse ist benannt, nicht geschlossen, und eine vollständige
Erkennung verlangte eine Tokenisierung, die nicht Gegenstand ist.

**Umgebung (ST-C2-D-01).** Unter der Umgebungsvariablen POSIXLY_CORRECT liest
GNU sed `[^\n]` und damit `s#//[^\n]*##` anders; betroffen waren die
Entfernung der Zeilenfortsetzungen am main-Gate und die Kommentarentfernung
am Prototyp-Gate, und vor dem `unset` liessen beide Gates unter der Variablen
einen sonst gesperrten Befehl durch. Beide Gates entfernen die Variable jetzt
zu Beginn (`unset POSIXLY_CORRECT`); S17 (main-Gate, KM-16), S18 und S19
(Prototyp-Gate, S19 am Bash-Weg; Fallklasse KP-6) je Soll 2, Mutationen MM30
und MP15.

**Regressionsschutz in beide Richtungen.** Von 2 auf 0 wechseln genau G78,
G79 und G101 (Formen, die die Shell nicht als Sperrfall liest) und, in der
Grenze GM-7, G80, G92 und G93; am Korpus des SecDevOps Engineers aus 80
Eingaben und am Prüfskript des Dynamic Software Testers ist kein weiterer
Wechsel von 2 auf 0 aufgetreten. Die Wechsel von 2 auf 0 zwischen den
Fassungen der Basename-Prüfung sind geschlossen, der aus DT-C2-E-01 mit A131
bis A136 und der aus ST-C2-F-01 mit A143 (je Soll 2). Von 0 auf 2 wechseln
nur Sperrfälle der Shell, die Preisformen A90 (KM-14), A102, A139 bis A142
und A149 (KM-17) und Läufe, in denen eine Prüfung nicht laufen kann
(S-Fälle, jetzt fail-closed). Die Fehlalarme der Zwischenfassungen (G95 aus
ST-C2-02, G102 und G103 aus ST-C2-D-07, G109 aus ST-C2-F-01) sind im Bau
behoben und laufen mit Soll 0.

**Posten 6 unter R3-Q-010 (neu), Prototyp-Gate.** Die sed- und tr-Schritte
des Prototyp-Gates (cmd_flach und bereinigt am Bash-Weg, payload_norm am Weg
der Dateiwerkzeuge) prüfen ihren Rückgabewert nicht; fehlt sed oder tr, läuft
ein sonst gesperrter Befehl durch (L23: Bash ohne sed, L24: Write ohne tr, je
gemessen 0, mit vollem PATH 2). Erreichbarkeit über die Umgebung, wie bei den
gemessenen Läufen ohne jq, git oder grep; Vertrag nach 6.13 b und `CLAUDE.md`
("Fehlt eines, blockieren sie mit einer Meldung, statt stillschweigend
durchzulassen"); Mittel ja, die Prüfung des Rückgabewerts je Schritt wie am
main-Gate seit Posten 4, ohne Erkennungsform und ohne neue Fehlalarmklasse.
Nicht Posten 2 (Umfang L05 bis L08) und nicht Posten 5 (SIGPIPE an den
Prüfstellen). L23 und L24 laufen mit Soll 0, Klasse "belegte Lücke" und
BEFUND_VON "Posten 6 unter R3-Q-010 (2026-10-21)"; terminiert mit der
nächsten Änderung am Prototyp-Gate, in C3 zusammen mit Posten 2, mit eigenem
Gegenstand je Weg und eigener Mutation.

**Posten 7 unter R3-Q-010 (neu), beide Gates.** Keines der beiden
PreToolUse-Gates zieht eine eigene Zeitgrenze, wie
`.claude/rules/claude-konfiguration.md` es für jedes Gate verlangt ("Ein Gate
zieht seine Zeitgrenze deshalb im Skript selbst, kürzer als in
settings.json", ADR 0002, 6.12.12); reisst ein Gate die Grenze des Harness
von 15 s, wird es abgebrochen und lässt durch. Gemessener Gegenstand am
main-Gate (CPU frei): Eine Zeile aus "&" hinter
`git worktree add /tmp/wt feature` braucht bei 5 MB 8,07 s, bei 8 MB
14,22 s, bei 9 MB 17,16 s und bei 10 MB 19,82 s, also über 14 s ab 8 MB und
über 15 s zwischen 8 und 9 MB; das Prototyp-Gate braucht bei 10 MB höchstens
3,7 s. Kein Fall im Prüfmittel; die Wirkung im laufenden Harness und die
Grösse, die der Harness als Befehl zulässt, sind nicht gemessen. Das
Prüfmittel fährt seit der Behebung von DT-C2-01 jeden Gate-Aufruf mit einer
Zeitgrenze von 14 s und wertet eine Überschreitung (Rückgabewert 124) als
Durchlass; das bildet die Grenze des Harness nach und macht MM22 erkennbar,
misst aber nicht die Grenze selbst. Terminiert mit der nächsten Änderung am
jeweiligen Gate, spätestens vor der Freigabe des Grundgerüsts; mit Posten 7
endet eine Überschreitung der eigenen Grenze mit 2 und wird als gedeckte
Fallklasse mit Soll 2 messbar, etwa über ein künstlich verlangsamtes
Werkzeug im PATH.

**Zeitgrenze und 6.13 d (ST-C2-05).** Die im Kopfkommentar benannte Grenze
"Zeitgrenze des Hooks (15 s)" ist bis zum Bau von Posten 7 ausdrücklich von
6.13 d ausgenommen, weil sie beim Harness liegt und im Prüfmittel nur als
nachgebaute Grenze messbar wäre; mit Posten 7 wird sie zur eigenen
Zeitgrenze des Gates mit Rückgabewert 2 und als Fallklasse mit Soll 2
gemessen.

**Rahmen für Posten 6 und 7.** Es gilt der Rahmen der Posten 4 und 5 aus dem
Nachtrag vom 2026-10-14: Bauvorschrift nach 6.13 g mit einer Mutation je
Behebung und je Sachverhalt einem blockierenden und einem durchzulassenden
Gegenstand, Rollen nach 6.13 e mit Verifikation auf einem anderen Modell als
die Umsetzung, Vorbehalt wie für die drei Posten. Eingeordnet hat der
Koordinator nach der Delegation vom 2026-10-21 (Status-Block): Posten 6 in
C3 mit Posten 2, Posten 7 mit der nächsten Änderung am jeweiligen Gate. Die
Bewertung nach CVSS und den Eintrag ins Register nimmt der Vulnerability
Manager vor.

**Belegte Lücken nach dem Bau.**

| Fall | Gate | vorher | Soll jetzt | Einordnung | Folge |
|---|---|---|---|---|---|
| L17 | main | 0 | 2 | geschlossen, Posten 4 a | Klasse "blockierend", KM-15; BEFUND_VON entfernt, Vermerk "geschlossen am 2026-10-21" mit dem früheren Wortlaut hinter "vormals belegte Luecke: "; MM17 |
| L19 | main | 0 | 2 | geschlossen, Posten 4 b | wie L17; KM-16; MM14, MM18 |
| L20 | main | 0 in 30 von 30 Läufen | 2 in 30 von 30 Läufen | geschlossen, Posten 5, SR-001 | wie L17, der Vermerk nennt SR-001; KM-18; MM16 |
| L21 | main | 0 | 2 | geschlossen, Posten 4 c | wie L17; KM-17; MM19, MM31 |
| L22 | Prototyp | 0 in 30 von 30 Läufen | 2 in 30 von 30 Läufen | geschlossen, Posten 5, SR-001; der Fall mit Beleg nach Punkt 5 | Klasse "blockierend", der Vermerk nennt SR-001; KP-5; MP12 |
| L23 | Prototyp | 0 | 0 | belegte Lücke, Posten 6 (Bash ohne sed) | Klasse "belegte Lücke", BEFUND_VON "Posten 6 unter R3-Q-010 (2026-10-21)"; mit vollem PATH 2 |
| L24 | Prototyp | 0 | 0 | belegte Lücke, Posten 6 (Write ohne tr) | wie L23 |

**Register.** Der Restpunkt "Ein Schwachstellenregister (Projektauftrag 4.2,
Rolle Vulnerability Manager) besteht im Repository noch nicht" im Nachtrag
vom 2026-10-14 ist überholt: Das Register `docs/11_Schwachstellenregister.md`
ist angelegt (Entscheid 2 des Koordinators vom 2026-10-21, Status-Block, Nachtrag zur Weisung vom 2026-10-21), mit
SR-001 für Posten 5 (CVSS 3.1 Basiswert 5.5, Mittel), dazu SR-002 (DT-C2-01, 5.5), SR-003 (Posten 7, 4.7) und SR-004 (Posten 6, Bewertung mit dem Bau). Die Belege zu seinem
Schliesskriterium liegen mit diesem Bau vor; den Status setzt der
Vulnerability Manager. DT-C2-01, Posten 7 und Posten 6 führt er als eigene Einträge; den Status setzt er.

**Zählung der Fallklassen.** Mit diesem Nachtrag stehen 36 Fallklassen: am
main-Gate neu KM-14 bis KM-18 und GM-9 (27), am Prototyp-Gate neu KP-5 und
KP-6 (9); GM-5 und GM-7 sind um Fälle erweitert. Der Teil für das
Prototyp-Gate aus dem Nachtrag vom 2026-10-14 (ZF10d, GP-3) folgt weiter mit
Posten 2.

**Restpunkte, nicht geschlossen.** Die vierte Delta-Runde ist statisch und
dynamisch bestanden; die folgenden nachrangigen Restpunkte bleiben ohne
weitere Änderung am Gate in dieser Einheit (Entscheid des Koordinators nach
dem Muster aus 3.4).

- DT-C2-G-01, vorbestehend seit dem ersten Bau von 4 c: Ein
  Umleitungsoperator mit "&" vor dem Pfad (`>&`, `&>`, `2>&1`, `2>&-`) trennt
  den Pfad vom worktree-add-Abschnitt, und die Basename-Form greift nicht
  (Durchlass, gleicher Mechanismus wie G112); ein Fall mit Soll 0 unter GM-9
  folgt mit der nächsten Änderung am main-Gate.
- ST-C2-G-03, seit Delta 3: Ist ein Umleitungsziel nach dem Entfernen der
  Anführungszeichen leer oder nur Leerraum (`> "\""`, `> " "`), liest die
  zweite Fassung das folgende Wort als Operanden; ein Fehlalarm in sicherer
  Richtung derselben Klasse wie A139 bis A142 (KM-17), im Kopfkommentar
  unter (i) noch nicht als Preis benannt, ohne Fall.
- ST-C2-G-01 und ST-C2-G-02: zwei Ungenauigkeiten im Kopfkommentar — G109
  verschluckte das commit-ish, nicht einen Pfad, und der Rückstrich ist im
  Operanden auch als Paar zugelassen.
- Die Wirkung im laufenden Harness ist nicht gemessen; die Hooks wirken in
  dieser Sitzung nicht.
- Die erste Zielprüfung liest weiter die Operanden von Umleitungen
  (vorbestehender Preis in sicherer Richtung).
- `git worktree add ../main/` gibt 0 (git lehnt "main/" als Zweignamen ab),
  `git worktree add -- ../main` gibt 2; beide ohne Fall.

Die Befundkennungen dieses Nachtrags (DT-C2-…, ST-C2-…, DT-C2-D-…,
ST-C2-D-…, DT-C2-E-…, ST-C2-E-…, DT-C2-F-…, ST-C2-F-…, DT-C2-G-01,
ST-C2-G-…, H-1, U-1, U-2, R1 bis R5) und die Messdateien führt die Übergabe
`docs/uebergaben/2026-10-21_abschnitt-c-posten-4-5.md` mit Fundort.

**Nachtrag vom 2026-10-21 zur Abnahme von Posten 4 und 5 — Festlegung für C3.**

Posten 4 und 5 sind abgenommen (Abschnitt 10; Status-Block, Nachtrag vom
2026-10-21 zur Abnahme von Posten 4 und 5). Auf die Weisung vom 2026-10-21
("Weiter mit Abschnitt D, D1 und dann C3") und die dort offengelegte Lesart
des Koordinators legt dieser Nachtrag den Bau in C3 fest: Posten 2, Posten 6
und den Teil von Posten 7 am Prototyp-Gate
(`.claude/hooks/block-prototype-import.sh`) in einem Bau, weil Posten 2 die
nächste Änderung an diesem Gate ist und Posten 6 und 7 mit ihr terminiert
sind. Posten 3 (L09) folgt in C4. Das main-Gate bleibt in C3 unverändert.
Die Nachträge oben bleiben im Wortlaut stehen (ADR 0002, 6.1, Absatz
"Anlass").

**Posten 2 (L05 bis L08).** Gegenstand nach der Zeile L05 bis L08 im
Nachtrag vom 2026-09-23: die vier Schreibweisen des Konstrukts — Leerraum
vor der Klammer bei `require (`, die Form `@import url(`, Leerraum um das
Gleichheitszeichen bei `src =` und `__import__` mit einem Modulnamen ohne
Punkt —, an den Dateiwerkzeugen in beiden Richtungen in einem Bau
(Kriterium `R3-Q-010_prototyp_gate_richtungsgleichheit`). Weil `src` und
`href` im selben Musterteil stehen und der Kopfkommentar die Lücke für
beide nennt, gilt die Form mit Leerraum um das Gleichheitszeichen auch für
`href =`. Die Fälle L05 bis L08 messen heute nur Richtung 1; für Richtung 2
kommt je Schreibweise ein Fall hinzu. Mit demselben Bau, nach den
Festlegungen vom 2026-09-23 und vom 2026-10-14: Der Absatz des
Kopfkommentars zu den symmetrischen Lücken wird ersetzt; GP-3 verliert den
Typ "grenze" und wird als gedeckte Klasse neu gefasst; die Grenze an der
Schnittstelle für ZF10d wird im Kopfkommentar benannt, mit einer
Fallklasse vom Typ "grenze"; der Halbsatz, der den Entscheid zu L12 bis L16
einer Fortschreibung zuweist, wird durch den Verweis auf den Nachtrag vom
2026-09-23 ersetzt. Damit ist die Zählung der Fallklassen für das
Prototyp-Gate abgeschlossen (Nachtrag vom 2026-10-14, Absatz "Zählung der
Fallklassen"). Nicht Gegenstand ist der Bash-Weg: Sein grobes Netz kennt
nach Lesung des Musters die Formen `src=` und `href=` in keiner Richtung;
ob daraus ein Durchlass folgt, misst der Dynamic Software Tester in C3, und
ein Befund wird dem Software Architect vorgelegt (Vorbehalt; Buchstabe c, "Jede
Härtung ohne belegte Lücke").

Abnahmekriterium für Posten 2: L05 bis L08 und die neuen Fälle der
Richtung 2 laufen mit Soll 2 und der Klasse "blockierend"; je Schreibweise
eine Gegenprobe mit Soll 0, dieselbe Schreibweise ohne Bezug über die
Trennung (etwa `require ("./util")` im Produktionscode); auch `href =`, je Richtung ein Fall mit Soll 2 und eine Gegenprobe mit Soll 0 (L07 misst heute nur `src =`); BEFUND_VON ist
entfernt, der Vermerk nennt die Schliessung und führt den früheren Wortlaut
hinter "vormals belegte Luecke: " (wie bei L17); je geänderter Stelle im
Gate eine Mutation (6.13 d, Punkt 6).

**Posten 6 (L23, L24).** Jeder sed- und tr-Schritt, dessen Ergebnis in die
Entscheidung eingeht — cmd_flach mit der Schleife über die Blockkommentare
und bereinigt am Bash-Weg, payload_norm mit seiner Schleife am Weg der
Dateiwerkzeuge —, prüft seinen Rückgabewert; jeder andere Ausgang als 0
endet über `pruefung_unmoeglich` mit Rückgabewert 2 und einer Meldung
(6.13 b), wie am main-Gate seit Posten 4. Fehlendes `sed` oder `tr` sperrt
damit. Die Meldung nennt das Werkzeug und seinen Rückgabewert; der nächste
Schritt in `pruefung_unmoeglich` nennt heute nur grep und wird allgemein
gefasst. Nicht Gegenstand sind die jq-Schritte (tool, cmd, fp, payload): jq
ist vorher auf Vorhandensein geprüft und die Eingabe als auswertbar
bestätigt (ST-13); ein Fehler danach ist durch keine ausgeführte Probe
belegt (Buchstabe c, "Jede Härtung ohne belegte Lücke"). Der Kopfkommentar,
der sie heute zusammen mit den sed- und tr-Schritten nennt, nennt sie
danach allein, mit diesem Grund, als Annahme der Bauform. Zeigt eine Probe
in C3 einen Durchlass über einen jq-Schritt, wird der Fall dem Software Architect
vorgelegt (Vorbehalt). Die Schritte der Meldung zu ST-13 (wc, tr, cut)
entscheiden nichts und bleiben unverändert.

Abnahmekriterium für Posten 6: L23 (Bash ohne sed) und L24 (Write ohne tr)
laufen mit Soll 2 und der Klasse "blockierend", BEFUND_VON entfernt,
Vermerk wie bei Posten 2. Je geprüfter Stelle ein Fall, an dem sie als
erste scheitert, und eine Mutation, die ihre Prüfung entfernt: Fehlendes
`tr` am Bash-Weg und fehlendes `sed` am Weg der Dateiwerkzeuge kommen als
Fälle zu L23 und L24 hinzu; für die Stellen, die ein fehlendes Werkzeug
nicht als erste erreicht (die beiden Schleifen, bereinigt), dient je eine
Attrappe nach dem Muster von `sed-ohne-z`. Das schärft die Vorgabe "mit
eigenem Gegenstand je Weg und eigener Mutation" (Nachtrag vom 2026-10-21
zum Bau von Posten 4 und 5 oben, Absatz zu Posten 6) auf je geprüfte
Stelle, weil 6.13 g je Behebung eine Mutation verlangt und eine Prüfung,
die kein Fall als erste erreicht, ungeprüft bliebe. Durchzulassender
Gegenstand sind die bestehenden Fälle mit Soll 0 bei vollem PATH. Die
Bewertung von SR-004 nimmt der Vulnerability Manager mit dem Bau vor.

**Posten 7, Teil am Prototyp-Gate.** Zahl: Das Gate zieht im Skript eine
eigene Zeitgrenze von 12 s mit einem Nachlauf von 1 s (`timeout -k 1 12`),
zusammen höchstens 13 s und damit unter der Grenze des Prüfmittels (14 s)
und der des Harness (15 s, `.claude/settings.json`), wie
`.claude/rules/claude-konfiguration.md` (Abschnitt "Hooks") und 6.12.12 es
verlangen. Die gemessene Laufzeit des Gates (10 MB höchstens 3,7 s) liegt
unter einem Drittel davon. Eine Eingabe, deren Prüfung länger als 12 s
braucht, sperrt; das ist ein Preis in sicherer Richtung (6.13 b).

Mechanik: Unmittelbar nach `unset POSIXLY_CORRECT` und `set -uo pipefail`
ruft das Skript sich selbst unter `timeout -k 1 12` auf, mit dem laufenden
bash (`$BASH`), über `$0` und mit einem festen Argument für den inneren
Lauf — `$BASH`, weil die PATH-Varianten des Prüfmittels kein bash führen,
`$0`, weil die Mutationsprobe eine Kopie des Gates fährt und der innere
Lauf dieselbe Kopie sein muss, nicht ein Pfad aus `CLAUDE_PROJECT_DIR`. Der
innere Lauf ist das heutige Gate und liest wie bisher die Standardeingabe;
der äussere Teil liest sie nicht und ruft ausser `timeout` kein Werkzeug
auf. Abbildung der Ausgänge: 0 nur, wenn der innere Lauf mit 0 endet; eine
2 bleibt 2; jeder andere Ausgang — Überschreitung (124), Abbruch nach dem
Nachlauf (137), Fehler von `timeout` (125 bis 127) und ein Rückgabewert 1
des inneren Laufs, etwa ein Abbruch unter `set -u` — endet mit 2 und einer
Meldung nach 6.13 b, die die Grenze und den nächsten Schritt nennt. Fehlt
`timeout`, sperrt das Gate mit einer Meldung, die `timeout` nennt, wie bei
jq. Das feste Argument öffnet keinen Weg an der Grenze vorbei: Den Aufruf
setzt `.claude/settings.json`, die Werkzeugeingabe kommt allein über die
Standardeingabe. Der Kopfkommentar nennt die Zeitgrenze als eigene Grenze
des Gates, nicht mehr als Grenze des Hooks, und den Abstand zur Grenze des
Harness als Annahme der Bauform; die Ausnahme von 6.13 d (Absatz
"Zeitgrenze und 6.13 d" im Nachtrag vom 2026-10-21 zum Bau von Posten 4
und 5 oben) entfällt für dieses Gate.

Abnahmekriterium für Posten 7 am Prototyp-Gate: eine gedeckte Fallklasse
mit einem Fall mit Soll 2 über ein künstlich verlangsamtes Werkzeug im
PATH — ein Werkzeug, das jeder innere Lauf aufruft (etwa `cat` beim Lesen
der Eingabe), verzögert um mehr als 14 s — und mit einer Eingabe, die ohne
Verzögerung mit 0 durchläuft; dazu eine Gegenprobe mit derselben Eingabe
und einer Verzögerung deutlich unter 12 s (Soll 0) und ein Fall ohne
`timeout` im PATH (Soll 2, die Meldung nennt `timeout`). Die Verzögerung
liegt über 14 s, damit eine Mutation, die die Grenze entfernt, den Fall bis
zur Grenze des Prüfmittels laufen lässt, wo er als Durchlass gewertet und
so erkannt wird. Zwei Mutationen: eine entfernt die Grenze, eine bildet die
Überschreitung als 0 ab. Die Laufzeit des Falls ist gemessen und genannt.
Alle PATH-Varianten des Prüfmittels führen `timeout`, ausser der Variante
ohne `timeout`; sonst sperrten L23, L24 und die Fälle der Wachen wegen des
fehlenden `timeout` und nicht aus ihrem eigenen Grund. Der Fall kostet je
Lauf etwa 12 s, im Mutationsmodus je Mutation am Prototyp-Gate; das wird
hingenommen. Den Status von SR-003 für diesen Teil setzt der
Vulnerability Manager.

**Posten 7, Teil am main-Gate.** Er bleibt offen (gemessen, ohne Fall) bis
zur nächsten Änderung am main-Gate, spätestens vor der Freigabe des
Grundgerüsts (Terminierung im Nachtrag vom 2026-10-21 zum Bau von Posten 4
und 5 oben); bis dahin gilt dort die Ausnahme von 6.13 d weiter. Für ihn
gilt dieselbe Festlegung mit Zahl, Mechanik und Abnahmekriterium; die dort
gemessene Eingabe über 14 s (8 MB, 14,22 s) sperrt danach mit 2. Die
Reihenfolge nach der Weisung vom 2026-10-21 ("Weiter mit Abschnitt D, D1 und dann C3") und der Lesart des Koordinators (C3, C4, O-29, Grundgerüst)
sieht keine Änderung am main-Gate vor; dieser Teil braucht deshalb eine
eigene Einheit vor der Freigabe des Grundgerüsts, deren Einordnung
aussteht. Mit ihr folgen die Restpunkte, die mit der nächsten Änderung am
main-Gate terminiert sind (Absatz "Restpunkte, nicht geschlossen" im Nachtrag vom 2026-10-21 — Posten 4 und 5 gebaut, oben).

**Rahmen für C3.** Bauvorschrift nach 6.13 g: zuerst das Soll, der Lauf
fällt, dann das Gate, zuletzt der Vermerk; je Behebung eine Mutation; je
Sachverhalt ein blockierender und ein durchzulassender Gegenstand (6.13 f,
Punkt 1); die Gegenproben des Regressionsschutzes (P01, P03, P04, P05)
bleiben grün (6.13 f, Punkt 2), und jeder bestehende Fall beider Gates behält sein Soll,
ausser den hier geschlossenen. Rollen nach 6.13 e: Gate
und Prüfmittel baut der SecDevOps Engineer; die Verifikation liegt beim
Static und beim Dynamic Software Tester auf einem anderen Modell als die
Umsetzung (6.13 f, Punkt 4). Vorbehalt wie für die drei Posten: Öffnet eine
Behebung eine neue Fehlalarmklasse, wird der Fall dem Software Architect vorgelegt.
Die Hooks wirken in der Sitzung nicht; gemessen wird über das Prüfmittel,
die Wirkung im laufenden Harness bleibt ungemessen. Die Zahlen nach dem Bau
nennt der Status-Block; die Fallklassen werden nach 6.13 d aus den
Kopfkommentaren abgezählt. Die Abnahme erteilt der Auftraggeber durch den
Merge des Pull Requests der Sitzung, in der C3 gebaut wird; nicht umfasst
sind Posten 3 (C4), der Teil von Posten 7 am main-Gate und die Restpunkte
am main-Gate.

**Nachtrag vom 2026-10-22 zum Bau von C3 — Einordnungen und Berichtigung.**

C3 ist nach dem Nachtrag oben gebaut und verifiziert (Status-Block,
Nachtrag vom 2026-10-22 — C3: Posten 2, Posten 6 und Teil von Posten 7 am
Prototyp-Gate gebaut). Dieser Nachtrag ordnet ein, was Bau, statische und
dynamische Prüfung ergeben haben, und berichtigt einen Satz der
Festlegung. Der Wortlaut oben bleibt stehen (ADR 0002, 6.1, Absatz
"Anlass").

**Gewollter Durchlass `import("backend")` (P52).** Entscheid des Software
Architects vom 2026-10-22, vorbereitet vom Koordinator. Die Endung für den
blossen Modulnamen ohne Punkt, bei der das Anführungszeichen unmittelbar auf
den Namen folgt, gilt nur für die Python-Formen `__import__` und
`import_module`, nicht für das dynamische `import(` der JS-Form. Ein blosser
JS-Modulname bezeichnet ein Paket, nicht das Verzeichnis. Die statische Form
`import x from "backend"` ist am Gate ebenso frei, weil Richtung 2 für den
Verzeichnisnamen ohne Schrägstrich ein "../" verlangt. Eine Sperre nur der
dynamischen Form behandelte die beiden Formen ungleich; eine Sperre beider
wäre eine neue Erkennungsform mit neuer Fehlalarmklasse ohne belegte Lücke
(Buchstabe c, "Jede Härtung ohne belegte Lücke"). Python ist anders: Die
Form `from backend import x` ist in Richtung 2 seit E4.2 gesperrt, weil
dort der Modulname der Verzeichnisname ist, und `__import__('backend')` ist
dasselbe Konstrukt (B71). Über die Trennung führt nur eine
Auflösungskonfiguration (Alias, baseUrl, Workspace); diesen Weg schlösse
auch eine Sperre nicht, weil die Konfiguration selbst kein Importmuster
trägt. Er fällt unter die Grenze GP-1 (P-10); der Kopfkommentar nennt Alias,
baseUrl und Workspace und hält fest: "Abhaengigkeiten und ihre Aufloesung sind GP-1 (P-10)."
P52 läuft als "durchlaufend" mit Soll 0; MP32 belegt, dass die Gegenprobe
unterscheidet. Die Überschrift im Kopfkommentar lautet "GEWOLLTER DURCHLASS"
statt vorher "PREIS in Richtung Durchlass".

**JS-Zuweisungen an src und href (B72, B73, P53, P54).** Seit Posten 2
sperren JS-Zuweisungen mit Leerraum (`x.src = "../backend/y"` in einer
Prototyp-Datei, `x.href = "../prototype/z"` im Produktionscode) wie die
Form ohne Leerraum schon vorher. Das Muster ATTR liest Text, nicht die
Syntax von HTML, und ob ein Formatierer Leerraum setzt, soll nicht
entscheiden; inhaltlich ist es ein Bezug über die Trennung und keine neue
Fehlalarmklasse. Geführt als eigener Sachverhalt nach 6.13 f, Punkt 1: B72
(Richtung 2) und B73 (Richtung 1) mit Soll 2, die Gegenproben P53 und P54
mit Soll 0. Die Fälle stehen in der Erwartungsliste von MP18, eine neue
Mutation braucht es nicht; der Kopfkommentar nennt den Sachverhalt in einem
Satz.

**Berichtigung vom 2026-10-22.** Der Satz "Die gemessene Laufzeit des Gates
(10 MB höchstens 3,7 s) liegt unter einem Drittel davon" im Absatz zu
Posten 7, Teil am Prototyp-Gate, der Festlegung oben trifft nach den
Messungen am gebauten Gate nicht zu. Eine Quote nennt dieser Nachtrag
nicht; massgeblich ist das gemessene Maximum mit Datum. Am 2026-10-22
brauchen acht Eingaben aus je 10 000 000 Zeichen (Bash: "&", Leerzeichen,
"#", "a"; Write: Kommentarzeile, "a", Leerzeichen im Prototyp, "&") nach
der Nachmessung des SecDevOps Engineers 2,5 s bis 4,5 s (Gate im
Ausgangsstand 2,3 s bis 4,4 s), nach der Messung des Dynamic Software
Testers 2,86 s bis 5,06 s. Das Maximum von 5,06 s (Write mit "a", 42 % der
Grenze von 12 s) trat einmal auf; drei Wiederholungen brauchten 4,16 s bis
4,79 s. Der Wortlaut "unter 40 %" im Kopfkommentar ist damit widerlegt
(DT-C3-04); er wird mit der nächsten Änderung am Gate (C4) durch das
gemessene Maximum mit Datum ersetzt. Der Abstand zur Grenze bleibt mehr als
das Doppelte. Die 3,7 s vom 2026-10-21 bleiben als Stand davor stehen. Der
Bau bringt keinen messbaren Mehraufwand; eine harmlose Eingabe braucht
51 ms. Die S25-Form endet nach 12,009 s bis 12,011 s mit Rückgabewert 2.
Ignoriert der innere Lauf selbst TERM, endet das Gate nach 13,0 s (beim
Dynamic Software Tester 13,010 s) mit Rückgabewert 2, ohne verwaiste
Prozesse; anders, wenn nur ein vom inneren Lauf aufgerufenes Werkzeug TERM
ignoriert (DT-C3-05, unten).

**Schärfung "je geprüfter Stelle": S29, S30 und die Attrappe
`sed-ohne-kommentar`.** Die Festlegung verlangt je geprüfter Stelle einen
Fall, an dem sie als erste scheitert. An der ersten sed-Stelle jedes Wegs
reicht das nicht: Fehlt sed ganz (L23, S23), fängt die Prüfung der nächsten
sed-Stelle den Ausfall auf, und eine Mutation, die nur die Prüfung der
ersten Stelle entfernt (MP21 am Bash-Weg, MP25 am Weg der Dateiwerkzeuge),
erkennt kein Fall mit fehlendem sed. Die Attrappe verweigert nur den Aufruf
für die Zeilenkommentare; S29 und S30 lassen damit genau die erste Stelle
scheitern. Massgeblich ist deshalb ein Fall, an dem die Stelle als einzige
scheitert. Das schärft die Festlegung oben, ohne ihren Wortlaut zu ändern.
L23 und S23 bleiben als Fälle des fehlenden Werkzeugs ohne Einzelmutation;
ihr Vermerk nennt die Einzelstellen.

**Mutationen über die Mindestzahl (MP30 bis MP32, S28).** MP30 (Prüfung, ob
`timeout` vorhanden ist; S27) und MP31 (Zweig "jeder andere Ausgang"; S28
mit einem `timeout`, das mit 125 endet) prüfen Stellen, die mit Posten 7
geändert wurden; das trägt die Vorgabe "je Behebung eine Mutation" aus dem Rahmen für C3 oben (6.13 g und 6.13 d, Punkt 6). MP32
entfernt keine Sperre, sondern erweitert ein Muster zu weit. Das verlangt
6.13 d, Punkt 6 nicht; es trägt 6.13 f, Punkt 1, weil die Mutation belegt,
dass die Gegenprobe P52 unterscheidet. Die Festlegung nennt, was mindestens
gemessen sein muss; 479 Fälle, 66 Mutationen und 39 Fallklassen weichen
nicht von ihr ab.

**Befunde der dynamischen Prüfung (DT-C3-01 bis DT-C3-05) und Beobachtung
am Bash-Weg.** Eingeordnet vom Software Architect am 2026-10-22. Alle sind
vorbestehend oder liegen ausserhalb der Festlegung; keiner hält die Abnahme
von C3 auf. Das Prüfmittel bleibt in C3 im verifizierten Endstand; die
Fälle der neuen Posten kommen mit dem ersten Schritt ihres Baus ins
Prüfmittel, mit Soll 2 zuerst (6.13 g). Die drei Posten sind terminiert
mit der nächsten Änderung am Prototyp-Gate (C4), spätestens vor der
Freigabe des Grundgerüsts; für sie gilt der Vorbehalt wie für die drei
Posten.

- **Posten 8 unter R3-Q-010 (neu), Prototyp-Gate: jq-Schritte ohne Prüfung
  des Rückgabewerts (DT-C3-02).** Eine Eingabe für MultiEdit mit einem
  Import über die Trennung in `edits[0].new_string` und einem Objekt in
  `edits[1].new_string` lässt den jq-Schritt für payload abbrechen; payload
  bleibt leer, und das Gate endet mit 0. Das ist die Probe, die die
  Festlegung oben (Absatz zu Posten 6) für die jq-Schritte vorbehalten hat;
  die dort genannte Annahme der Bauform ist damit widerlegt. Ob der Harness
  eine solche Eingabe weitergibt, ist offen; nach 6.13 b darf das Gate
  darauf nicht bauen. Mittel: Jeder jq-Schritt, dessen Ergebnis in die
  Entscheidung eingeht (tool, cmd, fp, payload), prüft seinen
  Rückgabewert; jeder andere Ausgang als 0 endet über `pruefung_unmoeglich`
  mit Rückgabewert 2. Abnahmekriterium wie bei Posten 6: je geprüfter
  Stelle ein Fall, an dem sie als einzige scheitert, und eine Mutation;
  dazu der Fall aus DT-C3-02 mit Soll 2 und eine Gegenprobe mit Soll 0. Ob
  das main-Gate dieselbe Bauform trägt, misst der Dynamic Software Tester
  mit der nächsten Änderung am main-Gate; bis dahin ist es nicht Gegenstand
  (Buchstabe c). Register SR-005.
- **Posten 9 unter R3-Q-010 (neu), Prototyp-Gate: Bezugsformen, die das
  Gate nicht erkennt.** (a) An den Dateiwerkzeugen laufen Formen ohne
  Anführungszeichen (`@import url(../prototype/x.css);`,
  `src=../prototype/x.js`) und in Grossschreibung (`SRC=`) durch, weil
  jedes Muster ein Anführungszeichen verlangt (DT-C3-01; vorbestehend, auch
  in der statischen Prüfung beobachtet). (b) Am Bash-Weg kennt das grobe
  Netz `src=` und `href=` nicht: `echo` mit `<script src="../prototype/x.js">`
  oder `<link href=...>` und Umleitung in den Produktionscode, `printf` mit
  `href = ...` und ein Heredoc mit `src=` laufen durch, ebenso
  `<img src="../backend/x.png">` mit Umleitung nach prototype/
  (Beobachtung des Dynamic Software Testers, HEAD unverändert); gesperrt
  sind am Bash-Weg `@import url(`, `require (` und `__import__`. Beides ist
  eine belegte Lücke, keine Grenze: Die Formen sind gültige Bezüge über die
  Trennung, und das Gate kann sie lexikalisch erkennen. Am Bash-Weg gelten
  nach dem Bau dieselben Formen wie an den Dateiwerkzeugen, gebunden an das
  Attribut mit Gleichheitszeichen (ATTR), nicht an das blosse Wort src, das
  mit einem Kopieren aus src/ eine neue Fehlalarmklasse öffnete.
  Abnahmekriterium: je Form und Richtung ein Fall mit Soll 2 und eine
  Gegenprobe mit Soll 0, je geänderter Stelle eine Mutation. Register
  SR-006 für beide Teile.
- **Posten 10 unter R3-Q-010 (neu), Prüfmittel: Reste zu Posten 2 und 7.**
  `-k 1` wirkt, hat aber weder Fall noch Mutation (DT-C3-03, ST-C3-04):
  Ohne `-k 1` endet ein innerer Lauf, der TERM ignoriert, erst nach 31 s,
  über der Grenze des Harness, und eine Mutation, die `-k 1` entfernt,
  erkennt heute kein Fall. Dazu kommen `import_module` ohne eigenen Fall
  (ST-C3-03) und die statische JS-Form `import x from "backend"` ohne
  eigenen Fall. Abnahmekriterium: ein Fall mit einem inneren Lauf, der TERM
  ignoriert (Soll 2), mit der Mutation "-k 1 entfernt"; je Richtung ein
  Fall mit Mutation für `import_module`; ein Fall mit Soll 0 für die
  statische Form als Gegenprobe zu P52. Die langsamen Fälle (S25, S26 und
  der neue) dürfen im Mutationsmodus auf die Mutationen der Zeitgrenze
  beschränkt werden, wenn der Normalmodus sie immer fährt; das entscheidet
  der Bau. Kein Registereintrag, weil das Gate selbst wirkt.
- **Laufzeit (DT-C3-04):** Berichtigung oben; der Wortlaut des
  Kopfkommentars folgt mit C4.
- **Grenze des Waisenprozesses (DT-C3-05).** Ignoriert ein vom inneren
  Lauf aufgerufenes Werkzeug TERM (Attrappe von cat mit `trap "" TERM` und
  `sleep 22`), endet das Gate nach 12,011 s mit Rückgabewert 2, und das
  Werkzeug läuft als Waisenprozess etwa 11 s weiter: `timeout` endet mit
  dem inneren bash und schickt kein KILL nach. Eingeordnet als Grenze, mit
  C4 im Kopfkommentar benannt, mit einer Fallklasse vom Typ "grenze" und
  dem Fall aus DT-C3-05 (Soll 2; der Vermerk nennt den Waisenprozess),
  unter einer Bedingung: Mit C4 misst der Dynamic Software Tester, wann die
  Ausgabekanäle des Gates in diesem Fall schliessen. Schliessen sie erst
  mit dem Waisenprozess, hielte ein Harness, der auf ihr Ende wartet, die
  Entscheidung über 15 s hinaus auf. Dann ist es keine Grenze, sondern eine
  Lücke, und das Gate räumt nach Ablauf die Prozessgruppe ab.

**Restpunkte, nicht geschlossen.**

- Die Wirkung im laufenden Harness ist nicht gemessen; die Hooks wirken in
  der Sitzung nicht.
- Bei 137 schreibt die äussere bash zusätzlich "Killed" auf die
  Fehlerausgabe; das ist kein Text des Gates.

**Belegte Lücken nach dem Bau.**

| Fall | Gate | vorher | Soll jetzt | Einordnung | Folge |
|---|---|---|---|---|---|
| L05 | Prototyp | 0 | 2 | geschlossen, Posten 2 (`require (`) | Klasse "blockierend", KP-7; BEFUND_VON entfernt, Vermerk "geschlossen am 2026-10-22" mit dem früheren Wortlaut hinter "vormals belegte Luecke: "; MP16; Richtung 2 B66, Gegenproben P42 und P43 |
| L06 | Prototyp | 0 | 2 | geschlossen, Posten 2 (`@import url(`) | wie L05; MP17; B67, P44 und P45 |
| L07 | Prototyp | 0 | 2 | geschlossen, Posten 2 (`src =`, dazu `href =` mit B69 und B70) | wie L05; MP18; B68, P46 bis P49; JS-Zuweisungen B72, B73, P53 und P54 |
| L08 | Prototyp | 0 | 2 | geschlossen, Posten 2 (`__import__` ohne Punkt) | wie L05; MP19; Richtung 2 B71 mit MP20, P50 und P51 |
| L23 | Prototyp | 0 | 2 | geschlossen, Posten 6 (Bash ohne sed) | Klasse "blockierend", KP-8; BEFUND_VON entfernt, Vermerk wie bei L05; keine Einzelmutation, der Vermerk nennt die Einzelstellen S29, S21 und S22 (MP21, MP22, MP24) |
| L24 | Prototyp | 0 | 2 | geschlossen, Posten 6 (Write ohne tr) | wie L23; MP27 |
| L09 | Prototyp | 0 | 0 | belegte Lücke, Posten 3 | unverändert; BEFUND_VON bleibt; mit C4 |
| DT-C3-02 | Prototyp | 0 | kein Fall | belegte Lücke, Posten 8 | Fall mit Soll 2 zuerst im Bau (6.13 g); SR-005 |
| DT-C3-01 | Prototyp | 0 | kein Fall | belegte Lücke, Posten 9 (a) | wie DT-C3-02; SR-006 |
| Bash-Weg mit `src=` und `href=` | Prototyp | 0 | kein Fall | belegte Lücke, Posten 9 (b) | wie DT-C3-02; SR-006 |

**Zählung der Fallklassen.** Mit diesem Bau stehen 39 Fallklassen, nach
6.13 d aus den Kopfkommentaren abgezählt: am main-Gate unverändert 27, am
Prototyp-Gate 12 (vorher 9). KP-7 ersetzt GP-3 ("vormals GP-3 (grenze),
seit 2026-10-22 gedeckt"); neu sind GP-4 (Grenze an der Schnittstelle,
ZF10d), KP-8 (Posten 6) und KP-9 (Posten 7). Damit ist die Zählung für das
Prototyp-Gate abgeschlossen, die der Nachtrag vom 2026-10-14 (Absatz
"Zählung der Fallklassen") mit Posten 2 angekündigt hat. Posten 8 bis 10
und die Grenze aus DT-C3-05 ändern die Zählung erst mit C4.

Die Befundkennungen dieses Nachtrags (ST-C3-01 bis ST-C3-04, DT-C3-01 bis
DT-C3-05) und die Messdateien führt die Übergabe dieser Sitzung unter
`docs/uebergaben/` mit Fundort.

**d) Das Prüfmittel: Ort, Name, Form und Mass.**

**Entscheid: ein einziges versioniertes Skript**
`scripts/pretooluse-gates-selbsttest.sh`, nicht zwei. Gründe: Beide Gates haben
dieselbe Aufrufschnittstelle (JSON auf der Standardeingabe, Rückgabewert 0 oder
2), ST-13 betrifft beide zugleich und liesse sich auf zwei Dateien nicht ohne
Doppelung führen, und die Fallliste ist der eigentliche Gegenstand — sie gehört
an eine Stelle. Die Forderung des Backlogs, für **jedes** der beiden Gates ein
Prüfmittel mit mindestens einem blockierenden und einem durchzulassenden Fall zu
haben, bleibt wörtlich erfüllt: Jeder Fall trägt sein Gate als Feld, und der Lauf
weist die Zahl der blockierenden und der durchlaufenden Fälle **je Gate**
gesondert aus; sind es für ein Gate null, fällt der Lauf.

Form, verbindlich:

1. Je Fall werden geführt und ausgegeben: Kennung, Gate, Werkzeug (`tool_name`),
   die Eingabe in der Form, in der sie dem Gate übergeben wird, der erwartete und
   der gemessene Rückgabewert, das Urteil. Für jeden gefallenen Fall wird genau
   eine Zeile ausgegeben, die diese Angaben trägt.
2. Die Fälle des main-Gates laufen gegen einen **Wegwerf-Klon auf `main`**, die
   Fälle des Prototyp-Gates gegen den **Arbeitsbaum**; die Prototyp-Fälle werden
   über die Gate-Eingabe gestellt, nicht über echte Schreibvorgänge.
3. Der Lauf **ändert keine versionierte Datei**: Wegwerfverzeichnisse werden
   angelegt und geräumt, die geprüften Gate-Dateien werden nur gelesen. Das ist
   der Kettengrundsatz aus ADR 0002, 6.1.3 und zugleich Voraussetzung dafür, dass
   der Lauf innerhalb der Definition-of-Done-Kette stattfinden kann, ohne D19
   auszulösen.
4. Die Kopfzeile des Laufs nennt den Commit des Wegwerf-Klons und je Gate die
   ersten sechzehn Stellen der SHA-256-Summe der geprüften Datei. Ohne diese
   Angaben ist eine Ausgabe kein Beleg, weil nicht feststeht, welcher Stand
   gemessen wurde.
5. Ein vollständig bestandener Lauf endet mit Rückgabewert 0, ein Lauf mit
   mindestens einem gefallenen Fall mit einem Rückgabewert ungleich 0.
6. **Mutationsprobe als Gegenprobe**, aufgerufen über einen eigenen Modus des
   Skripts: Je Gate wird mindestens eine im Quelltext benannte Sperre in einer
   **Kopie** des Gates entfernt oder geschwächt; der Lauf gegen diese Kopie muss
   fallen und den betroffenen Fall nennen. Erkennt eine Mutation kein Fall, ist
   das ein Befund am Prüfsatz, nicht an der Mutation. Die Mutationen stehen im
   Skript selbst; eine eigene Mutationsdatei nach dem Muster von
   `scripts/dod-gate-mutationen.txt` entsteht nicht, weil ihre Zahl einstellig
   bleibt.

**Mass: bewusst ohne Zusicherungstabelle, ohne mechanische Deckungen und ohne
vollständige Mutationsdatei** nach dem Muster von ADR 0002, 6.12.19 bis
ADR 0002, 6.12.28. Begründung, weshalb das hier trägt: Gegenstand sind zwei kurze
Textprüfungen mit abzählbaren Fällen. Sie führen keinen Zustandsautomaten, keinen
Zähler, keine Eskalationsstufen und keine Lagenlogik; sie lesen eine Eingabe,
vergleichen sie gegen eine Musterreihe und enden mit 0 oder 2. Die Apparatur aus
ADR 0002, 6.12 ist genau dafür gebaut worden, dass ein Gate mit Zuständen,
Zählern und Meldungsformen nicht an der Aufzählung seiner Ausgaben, sondern am
Gegenstand gedeckt wird. Hier fehlt der Gegenstand, den diese Apparatur decken
soll. Ein Prüfmittel, das aufwendiger ist als der geprüfte Gegenstand, bindet
Kontingent ohne Zuwachs an Sicherheit.

**Grenze dieses Masses, ausdrücklich:** Die Fallliste ist eine Aufzählung. Was
sie nicht führt, misst sie nicht — dieselbe Klasse wie ADR 0002, 6.12.27
("Deckung an der Aufzählung statt am Gegenstand"). Deshalb gilt als Ausgleich die
eine mechanische Bindung, die hier bezahlbar ist: **Jede Fallklasse, die der
Kopfkommentar eines Gates als gedeckt behauptet, braucht einen blockierenden
Fall, und jede Grenze, die er benennt, einen durchlaufenden** — das ist das
Abnahmekriterium `R3-Q-010_benannte_grenzen`. Die Liste dieser Klassen wird
**einmal** aus dem Text der beiden Kopfkommentare abgezählt, im Prüfmittel
geführt und in der Ausgabe genannt; sie darf nicht bei jedem Lauf neu entstehen,
sonst wandert die Deckung mit dem Text (offene Frage des Requirements Engineers,
hiermit entschieden).

**Ausgangsmenge der Fälle:**

- Die Proben des Laufs vom 2026-09-21, mit Kennung geführt: A01 bis A11, G01 bis
  G06, S01 bis S05, B01 bis B10, P01 bis P05 — 37 Fälle. **G04 trägt das Soll 2**
  (Push bei HEAD auf `main`, die im Kopfkommentar beschriebene gewollte Wirkung),
  nicht 0; das Probeskript des Koordinators führte hier versehentlich 0 und
  meldete deshalb eine Abweichung. Wer den Prüfsatz baut, setzt das Soll auf 2,
  sonst liest ein späterer Leser die Zeile als Fehlalarm.
- Der Fremdbeleg zählt für denselben Lauf 44 ausgegebene Zeilen. Die Differenz zu
  den 37 mit Kennung geführten Proben hat der Koordinator am Probeskript
  ausgezählt (Übergabe vom 2026-09-21): Die sieben weiteren Zeilen sind die
  Abweichungsmeldungen des Skripts zu G04, B02, B03, B06, B07, B08 und B09 —
  keine Proben. Ausgangsmenge sind die 37 Proben; wer E4.1 baut, zählt sie am
  Skript nach und gibt jeder Probe ihre Kennung.
- Die zehn Zusatzfälle des Static Software Testers (unten, wortgetreu).
- Die 29 und 18 Proben vom 2026-08-25
  (`docs/uebergaben/2026-08-25_full-review-konfiguration.md`), soweit dort
  nachvollziehbar. Ihr Inhalt ist in dieser Einheit nicht gelesen worden und wird
  hier nicht behauptet; wer E4.1 baut, gleicht sie ab und nennt in der Übergabe,
  welche davon nicht rekonstruierbar sind.

Die zehn gewünschten Zusatzfälle, wortgetreu aus dem Fremdbeleg des Static
Software Testers vom 2026-09-21, mit zwei offengelegten Abweichungen: Umlaute
sind gesetzt, und Literale mit Schrägstrich ohne Anführungszeichen sind in
gerade Anführungszeichen gefasst, weil ein Pfadliteral in Rückwärtsakzenten im
Belegprüfer eine bestehende Datei bezeichnen muss; und Zeilenangaben aus dem
Fremdbeleg sind in Nummer 10 verallgemeinert, weil ihre Aktualität in dieser
Einheit nicht nachgeprüft wurde:

1. main-Gate, Push in Ref-Form und mit Pluszeichen: "git push origin
   HEAD:refs/heads/main" und `git push origin +main` (Zeile 124/125 führt `:` und
   `+` in der vorderen Zeichenklasse; heute nur aus dem Quelltext gelesen, nicht
   ausgeführt).
2. main-Gate, benannte Grenze aus dem Kopfkommentar (Zeile 83-87) als Probe: ein
   Kontextwechsel in einer Subshell oder in `bash -c`, der in einem auf main
   stehenden zweiten Auscheckstand committet. Erwartung nach dem Kopfkommentar:
   geht durch. Wert der Probe: die Grenze wäre gemessen statt nur behauptet, und
   E4 kann sie bewusst als Grenze festschreiben.
3. main-Gate, Kontextauflösung nach Zeile 89-107: derselbe Schreibbefehl in einem
   auf main stehenden Auscheckstand einmal über einen absoluten und einmal über
   einen relativen Pfad (`cd`, `pushd`, `git -C`, `env -C`), dazu ein Lauf mit
   einem vom Projektbaum verschiedenen Arbeitsverzeichnis des Hook-Prozesses —
   der Kommentar sagt ausdrücklich, dass das Ergebnis davon abhing.
4. main-Gate ausserhalb eines Repositories: CLAUDE_PROJECT_DIR auf ein Verzeichnis
   ohne ".git". Erwartung nach Zeile 47 und dem Kopfkommentar Zeile 23-27:
   Rückgabewert 0 als bewusste Grenze. Belegt diese Grenze.
5. Prototyp-Gate Richtung 1, weitere Grammatiken desselben Lochs ST-04:
   `require("../prototype")`, `import("../prototype")`, `@import "../prototype"`,
   `from prototype.helper import x` und ein Pfad mit Rückstrich. Zeigt, ob ST-04
   ein Einzelmuster oder die ganze Musterreihe betrifft, und begrenzt den Umfang
   von E4 belegbar.
6. Prototyp-Gate Richtung 2, weitere Formen von ST-05 und P-01:
   `require("./../backend/api")`, `@import "./../frontend/style.css"`,
   `<img src="../backend/x.png">`, `<a href="../frontend/index.html">` sowie ein
   absoluter Alias "@/backend/..." als Gegenprobe zu Zeile 138.
7. Prototyp-Gate, ST-09 in der Breite: `node -e`, `perl -e`, `php -r`, `ruby -e`
   mit einem Prototyp-Import im geschriebenen Text — also genau die Klasse, die
   das main-Gate an Zeile 172 führt und das Prototyp-Gate an Zeile 46 nicht.
8. Beide Gates, ST-13 in der schärferen Form: syntaktisch gültiges JSON, in dem
   `tool_input` eine Zeichenkette statt eines Objekts ist (jq meldet "Cannot
   index string"). Zeigt, ob das stille Durchlassen nur unlesbare Eingabe
   betrifft oder jede Eingabe, an der jq scheitert.
9. Prototyp-Gate, Reichweite der Ausnahmeliste in Zeile 66-68: eine Datei unter
   ".claude/" mit einem verbotenen Import. Die Liste nimmt "docs/*", ".claude/*",
   "*.md", "*.txt", "*.adoc", "*.rst" aus; ".claude/*" umfasst auch Skript- und
   Konfigurationsdateien. Ich melde das als Prüffall, nicht als Befund:
   ".claude/" ist nach ADR 0002 keine Bauwurzel und damit kein Produktionscode,
   und der Zustandsbericht führt dazu nichts.
10. Beide Gates, Schreibweise des Werkzeugnamens: `tool_name` als `bash` statt
    `Bash`. Belegt, ob die Gleichheitsprüfung an der betreffenden Zeile beider
    Gates eine eigene Annahme trägt.

Zu Nummer 9 und 10 als Einordnung dieses Abschnitts, nicht als Erweiterung des
Umfangs: Beide sind **Prüffälle, keine Befunde**. Ihr gemessenes Ergebnis wird
als heutiger Stand geführt; ob daraus eine Änderung am Gate folgt, entscheidet
nicht der Prüfsatz, sondern eine Fortschreibung dieses Abschnitts. Für Nummer 10
gilt das besonders: Der Harness setzt den Werkzeugnamen, und eine Erweiterung der
Gleichheitsprüfung ohne belegte Lücke fiele unter die Härtungen aus Buchstabe c.

**e) Rollen.**

Die Quellenlage ist uneinheitlich und wird hiermit entschieden: ADR 0001,
Abschnitt 8 legt die Hook-Konfiguration beim SecDevOps Engineer; ADR 0001,
Abschnitt 4 weist `.claude/` keiner Rolle zu, weshalb die ersten Hooks der
Koordinator angelegt hat; der Zustandsbericht weist die Gate-Befunde dem DevOps
Engineer als Umsetzung und den beiden Testerrollen als Verifikation zu, P-01 dem
SecDevOps Engineer.

- **Umsetzung, beide Gates und das Prüfmittel: SecDevOps Engineer.** ADR 0001 ist
  die Rechtezuweisung, der Zustandsbericht ein Prüfbericht mit einem Vorschlag;
  bei Widerspruch trägt ADR 0001. Für die Zuweisung spricht zudem, dass das
  Prüfmittel nichts anderes prüft als die beiden Hooks, und dass P-01 dort schon
  liegt. Der DevOps Engineer wird zugezogen, wo das Prüfmittel die
  Definition-of-Done-Kette oder das `Makefile` berührt — in E4.1 ist eine solche
  Berührung nicht vorgesehen.
- **Verifikation: Static Software Tester** (statisch am Quelltext, Deckung der
  Fallliste gegen die beiden Kopfkommentare, Vollständigkeit der Ausgangsmenge)
  **und Dynamic Software Tester** (ausgeführter Lauf, Mutationsprobe, Verhalten
  im Harness), je **auf einem anderen Modell als die Umsetzung** (3.4). Die Rolle,
  die umsetzt, prüft ihre eigene Arbeit nicht; das gilt auch für den Prüfsatz
  selbst.
- **Nachführung:** Die Kopfkommentare der beiden Gates und die Hook-Regel in
  `.claude/rules/claude-konfiguration.md` führt die umsetzende Rolle mit derselben
  Einheit nach, in der sie das Gate ändert — ein Kopfkommentar, der dem Code
  hinterherhinkt, ist die Quelle von ST-02 und P-10 gewesen. Die Fortschreibung
  dieses ADR macht der Software Architect, den Backlog der Product Owner, die
  Gate-Tabelle in CLAUDE.md der Koordinator.

**f) Abnahmekriterium.**

Massgeblich sind die sieben Tests des Backlog-Eintrags R3-Q-010 in
`docs/05_Product_Backlog.md`: `R3-Q-010_prototyp_gate_pfadformen`,
`R3-Q-010_prototyp_gate_richtungsgleichheit`,
`R3-Q-010_prototyp_gate_schreibwirkung`, `R3-Q-010_gates_unlesbare_eingabe`,
`R3-Q-010_pruefmittel_je_gate`, `R3-Q-010_main_gate_fremdbelegt` und
`R3-Q-010_benannte_grenzen`. Dieser Abschnitt ändert keinen davon und verlangt
zusätzlich:

1. **Je Sachverhalt ein blockierender und ein durchzulassender Gegenstand.** Ein
   Fall, der nur blockiert, belegt nicht, dass das Gate unterscheidet; er belegt
   nur, dass es blockiert.
2. **Regressionsschutz:** Die heute grünen Gegenproben bleiben grün — G01, G02,
   G03, G05, G06 am main-Gate und P01, P03, P04, P05 am Prototyp-Gate. Eine
   Änderung, die eine dieser Proben auf 2 hebt, ist ein Fehlalarm und gilt als
   gefallener Fall, nicht als Härtung.
3. **Der Lauf ändert keine versionierte Datei** (Kettengrundsatz ADR 0002, 6.1.3);
   das wird im Lauf selbst geprüft und ausgewiesen, nicht nur behauptet.
4. **Fremdverifikation auf einem anderen Modell als die Umsetzung vor jeder
   Fertigmeldung** (3.4). Ohne sie gilt kein Sachverhalt des Eintrags als belegt —
   das ist genau die Lücke, die ST-01 bis ST-03 seit dem 2026-09-03 tragen.

**g) Schnitt und Reihenfolge.**

Die Einschätzung des Requirements Engineers wird bestätigt: R3-Q-010 **passt
erkennbar nicht in eine Session** (3.3). Tragend sind seine Gründe am Bestand —
sieben Sachverhalte an zwei Skripten, ein Prüfmittel, das es noch nicht gibt, drei
nötige Verifikationsschleifen auf einem anderen Modell, und die Erfahrung aus
R3-Q-001, wo der Selbsttest eines einzigen Gates zwölf Prüfrunden und mehrere
Arbeitseinheiten gebraucht hat. Der Schnitt wird **unverändert bestätigt**:

- **E4.1 — Prüfmittel am heutigen Stand.** Schliesst `R3-Q-010_pruefmittel_je_gate`
  und `R3-Q-010_main_gate_fremdbelegt` ab. **E4.1 ändert keine Zeile an den beiden
  Gates.** Das ist keine Empfehlung, sondern Bedingung: Der heutige Stand ist der
  einzige Bezugspunkt, gegen den ein späterer Rückschritt auffällt, und wer
  Gate-Änderung und Prüfmittel in derselben Einheit baut, prüft seine eigene
  Änderung mit einem Werkzeug, das er gerade erst geschrieben hat.
- **E4.2 — Prototyp-Gate, Erkennungslücken:** ST-04, ST-05, P-01. Schliesst
  `R3-Q-010_prototyp_gate_pfadformen` und
  `R3-Q-010_prototyp_gate_richtungsgleichheit` ab.
- **E4.3 — Verhalten an den Rändern:** ST-09, ST-13 und die benannten Grenzen
  samt der Nichtprüfung gemeinsamer Abhängigkeiten im Kopfkommentar. Schliesst
  `R3-Q-010_prototyp_gate_schreibwirkung`, `R3-Q-010_gates_unlesbare_eingabe` und
  `R3-Q-010_benannte_grenzen` ab. Die Richtung von ST-13 ist mit Buchstabe b
  entschieden und steht damit vor E4.3 fest.

**Eine Ergänzung zum Schnitt, damit er ausführbar ist** — sie folgt aus der
Forderung, dass E4.1 mit Rückgabewert 0 endet, und ist keine Abweichung vom
Backlog: In E4.1 werden die heute offenen Lücken als Fälle der Klasse "belegte
Lücke" mit dem **heute gemessenen** Rückgabewert als Soll und mit der
Befundkennung im Vermerk geführt. Dadurch endet der Lauf mit 0, und der Prüfsatz
belegt zugleich, dass die Lücke am heutigen Stand besteht. In E4.2 und E4.3 wird
je Befund zuerst das Soll auf 2 gesetzt — der Lauf fällt und belegt, dass der Fall
wirksam ist —, dann das Gate geändert, bis der Lauf wieder steigt, und zuletzt die
Befundkennung aus dem Vermerk entfernt. Ein Vermerk "belegte Lücke", der nach dem
Abschluss von E4.3 noch im Prüfsatz steht, ist ein offener Befund.

**Reihenfolge:** E4.1, E4.2, E4.3, dann **E3**, dann das **Grundgerüst**. E3 wird
nicht in diesem Zug festgelegt, sondern braucht eine eigene Festlegungseinheit:
Für E4 lag ein Befundbestand vor, für E3 liegt keiner vor — der Umfang wäre zu
erheben, nicht abzulesen; und E3 hängt an Entscheiden, die nicht beim
Requirements Engineer liegen (wer `.claude/skills/` beschreiben darf, fällig vor
der dritten Skill nach ADR 0001, Abschnitt 8, dazu der nicht als ausgeführt
belegte Kontrollversuch SK-02). Vor diesen Entscheiden wäre jedes
Abnahmekriterium zu E3 eine Vermutung und erfüllte R4 nicht.

**Prüfaufwand: 5 h**, geschätzt vom Requirements Engineer, bestätigt vom Product
Owner; das ist nach der Definition of Ready der Aufwand des Teams, das Inkrement
zu prüfen, nicht der Umsetzungsaufwand. Schnitt, Reihenfolge und Schätzung sind
**Vorlage an den Auftraggeber; entschieden ist davon nichts.** **Entschieden
am 2026-09-22:** Umfang freigegeben, Schnitt E4.1 bis E4.3 und Reihenfolge
bestätigt (Weisung im Wortlaut im Status-Block am Anfang von ADR 0002, 6.13);
der Satz davor bleibt als Stand vor dem Entscheid stehen.

**h) Nachzuführen.**

Nur als Liste; eingetragen wird sie in ADR 0002, Abschnitt 9.

- Summen und Stand-Zeile in `docs/05_Product_Backlog.md` nach der Aufnahme von
  R3-Q-010 — Product Owner, in dieser Einheit.
- O-28 in die Tabelle der offenen Punkte, ADR 0002, Abschnitt 8 — Software
  Architect, in dieser Einheit.
- Nach dem Bau von E4.1: Gate-Tabelle in CLAUDE.md — Koordinator;
  `.claude/rules/claude-konfiguration.md` und die Kopfkommentare der beiden Gates
  — umsetzende Rolle; `scripts/nachweise-erzeugen.sh` um das neue Artefakt —
  DevOps Engineer; die beiden Ausnahmezeilen (ADR-Datei und Backlog) für das
  dann vorhandene Prüfmittel aus
  `scripts/belege-ausnahmen.txt` entfernen — umsetzende Rolle.
- `docs/06_Definition_of_Ready_und_Done.md` nur, falls E4 die dortigen Festlegungen
  berührt — Requirements Engineer.

**Was dieser Abschnitt nicht ändert.** An `.claude/hooks/block-main-write.sh`, an
`.claude/hooks/block-prototype-import.sh`, an `.claude/settings.json` und am
`Makefile` ist keine Zeile geändert. ADR 0002, 6.12 und seine Nachträge bleiben
unberührt, ebenso ADR 0002, Abschnitt 10 und die dort am 2026-09-08 eingetragene
Abnahme. Die Kernarchitektur aus 5.1, die Entscheide `A1` bis `A13` und der
Modulschnitt bleiben unverändert; die Gates stehen an keiner Stelle zwischen
Freigabe und Ausführung (5.2). Keine D-Nummer wird vergeben, und D10 bleibt Lage
C. Nichts hier bereitet Gestrichenes vor (5.17, 5.18, 9.1, 5.10, 5.1).

**Und nichts hier ist ein Bau oder eine Freigabe.** Der Umfang von E4, der
Schnitt in E4.1 bis E4.3 und der Start der Umsetzung liegen beim Auftraggeber.
**Nachtrag vom 2026-09-22:** Umfang und Schnitt sind freigegeben, der Start
der Umsetzung ist angewiesen ("Nächste Einheit: E4.1 bauen."); gebaut ist in
dieser Einheit nichts.

---

#### Nachtrag vom 2026-10-22 — Schnitt aus ADR 0002 und Teil A angelegt (PS-2)

**Vorher galt.** Die Festlegung zu R3-Q-010 stand als ADR 0002, 6.13 ("Neunzehnte Fortschreibung vom 2026-09-21"), mit dem Status-Block, den Buchstaben a bis h und allen Nachträgen bis zum Nachtrag vom 2026-10-22 zum Bau von C3 in 6.13 c. Einen Stand als Tabellen gab es nicht; was galt, ergab erst die Folge der Nachträge, die frühere Sätze als Stand ihres Tages stehen lassen (ADR 0002, 6.1, Absatz "Anlass"). Wortlaut bis zum Schnitt beim Commit `ac6e0c17672ad9f0d139a59dba8ca319f46056c4`, Datei `docs/adr/0002-architekturentscheid-ziel-stack.md`, 6.13.

**Jetzt gilt.** Der Text von ADR 0002, 6.13 steht verschoben, nicht abgeschrieben, als Teil B dieses ADR: Reihenfolge, Überschriften, Kennungen (6.13 a bis h, Status-Block, Nachträge) und Wortlaut wie bis zum Schnitt; ein Verweis "ADR 0002, 6.13 …" in anderen Dateien findet dieselbe Stelle in Teil B. An der alten Stelle in ADR 0002 steht die Weiterleitung nach `.claude/rules/dokumentation.md` (Titel, neuer Ort, Commit-Prüfsumme des Schnitts). Neu ist Teil A mit dem Stand vom 2026-10-22: Entscheid, Festlegungen, Fallklassen, Grenzen, Preise, Posten und belegte Lücken, Zahlen, Restpunkte und Abnahmen als Tabellen. Teil A fasst zusammen und trifft keine neue Festlegung; bei einem Widerspruch gelten Teil B und ADR 0002, Abschnitt 10, bis Teil A berichtigt ist. Teil A wird künftig überschrieben; jede Änderung daran bekommt einen datierten Eintrag am Ende von Teil B in der Form dieses Nachtrags, und Teil B bleibt ausschliesslich anfügbar. Freigaben und Abnahmen werden weiter in ADR 0002, Abschnitt 10 eingetragen. An den beiden Gates, am Prüfmittel, an `.claude/settings.json` und am `Makefile` ändert der Schnitt keine Zeile.

**Weshalb.** Prozess-Schnitt PS-1: Die Regel in `.claude/rules/dokumentation.md`, fortgeschrieben am 2026-10-22 und angenommen durch den Merge des Pull Requests #29 (Merge-Commit `d7d539ebea07043201d58e36c8abafec54045848`), verlangt, dass ein ADR den aktuellen Stand als Teil A abbildet und ein datiertes Entscheidlog als Teil B führt, je Änderung "Vorher galt / Jetzt gilt / Weshalb"; bis zur Aufteilung (PS-2) galt für ADR 0002 der Stand vom 2026-10-22. Weisungen vom 2026-10-22 (zweiter Formweg), im Wortlaut: "Ich vertraue dir und deinen super Fähigkeiten und gehen nach deiner Empfehlung"; "Mach einfach, ich erlaube es dir. Vertraue dir." Schnitt und Form folgen der Vorlage `docs/vorlagen/2026-10-22_prozess-schnitt.md` und ihrem Anhang `docs/vorlagen/2026-10-22_prozess-schnitt/anhang-a-adr-aufteilung-software-architect.md` (Abschnitt "Form der neuen ADR"). Der Grund aus ADR 0002, 6.1, Absatz "Anlass" — "die früheren Fassungen bleiben im Text stehen, weil ein Nachweisdokument, dessen Irrtum verschwindet, als Nachweis untauglich ist" — bleibt gewahrt: Teil B behält jede frühere Fassung im Wortlaut, und der Wortlaut bis zum Schnitt bleibt beim Commit `ac6e0c17672ad9f0d139a59dba8ca319f46056c4` fest verweisbar.

**Abnahme von C3.** Die Abnahme von Posten 2, Posten 6 und des Teils von Posten 7 am Prototyp-Gate ist am 2026-10-22 erteilt (erster Formweg): Merge des Pull Requests #28, Merge-Commit `95cafc9cc31773a6c29d977ec9c3b97af5a1f047`, ohne Kommentare und ohne Reviews; eingetragen in ADR 0002, Abschnitt 10, wo auch der Umfang nach dem Text des Pull Requests steht. Nach der Vorlage im Status-Block (Nachtrag vom 2026-10-22 — C3) nicht umfasst sind Posten 3, 8, 9 und 10, der Teil von Posten 7 am main-Gate, die Restpunkte am main-Gate und der Prozess-Schnitt. Die Sätze im Status-Block und in 6.13 c, die diese Abnahme als künftig beschreiben, bleiben als Stand davor stehen (ADR 0002, 6.1, Absatz "Anlass").

Verfasst durch den Software Architect (4.3).

**Berichtigung vom 2026-10-22 (vor der Vorlage, nach der Textprüfung, Befunde ST-PS2-01, -02, -05 und -08).** Vorher galt: der Wortlaut von Teil A beim Commit `287ddbafa1935711c66345241c7e51c5d587601a` — Tabelle Posten mit SR-004 "im Register in Behebung" und SR-003 "Prototyp-Teil in Behebung", Tabelle Abnahmen ohne die Bestätigung der Zeile 2026-10-21 durch Merge #28, GM-5 mit "seit Delta 3" ohne Fundort in Teil B. Jetzt gilt: Tabelle Posten nach dem Register (SR-004 behoben mit Nachweis; SR-003 Prototyp-Teil behoben mit Nachweis, Eintrag offen wegen des main-Gate-Teils), Zeile 2026-10-21 der Abnahmen mit "bestätigt durch Merge #28 am 2026-10-22", GM-5 mit "mit Posten 4 c" und Fundort in Teil B (6.13 c, Nachtrag vom 2026-10-21, Absätze "Posten 4 a" und "Posten 4 c, Preise und Grenzen"). Weshalb: Befunde des Static Software Testers; massgeblich sind das Register (Nachtrag 2026-10-22 nach dem Merge des Pull Requests #28), ADR 0002, Abschnitt 10 (Bestätigung des Eintrags zu Posten 4 und 5) und Teil B.

#### Nachtrag vom 2026-10-26 — Annahme der Aufteilung und von Teil A (Merge des Pull Requests #30)

**Vorher galt.** Die Aufteilung — Teil B als unverändert verschobener Text von ADR 0002, 6.13 — und Teil A waren vorgelegt, die Annahme stand aus: Die Zeile "Status" im Kopf nannte weder PS-2 noch eine Annahme, und die Tabelle "Abnahmen" in Teil A endete mit der Abnahme von C3 vom 2026-10-22 (Merge #28). Wortlaut in `docs/adr/0004-pretooluse-gates.md` beim Commit `9d2b4949f59c1bd54e7cdb4756c5a1a9de99d002`.

**Jetzt gilt.** Die Aufteilung und Teil A sind angenommen am 2026-10-26 durch den Merge des Pull Requests #30 um 05:13:45 UTC durch das Konto des Repository-Eigentümers, Merge-Commit `80aee8dc978778b9184b9e9639328535f1708264`, ohne Kommentare und Reviews. Die Zeile "Status" nennt im Anschluss an ihren bisherigen Wortlaut, der stehen bleibt, die Anlage als eigener ADR mit PS-2 am 2026-10-22 und diesen Tatbestand; die Tabelle "Abnahmen" führt die Annahme als letzte Zeile. Die Restpunkte in Teil A bleiben offen; nach dem Text des Pull Requests sind sie von der Annahme nicht umfasst (Einordnung mit C4). Den Eintrag in ADR 0002, Abschnitt 10 schreibt der Protocol Master (Unterabschnitt "Annahme des Prozess-Schnitts PS-2 (Aufteilung von ADR 0002 in ADR 0003 bis 0005) — Merge des Pull Requests #30 — erteilt am 2026-10-26, eingetragen am 2026-10-26").

**Weshalb.** Erster Formweg nach ADR 0002, Abschnitt 10: Nach seinem Text ist der Merge des Pull Requests #30 die Annahme von PS-2, darunter die Verschiebung von ADR 0002, 6.13 unverändert als Teil B dieses ADR sowie dessen Kopf und Teil A. Die Zeile "Status" und die Tabelle "Abnahmen" gehören zum Stand; nach `.claude/rules/dokumentation.md`, Abschnitt "Architecture Decision Records", bekommt jede Änderung daran hier einen datierten Eintrag in dieser Form. Teil B vor diesem Nachtrag ist unverändert. Die Angaben zum Merge stammen aus der Erhebung des Koordinators vom 2026-10-26 (Fremdbeleg, von dieser Rolle nicht nachgemessen).
