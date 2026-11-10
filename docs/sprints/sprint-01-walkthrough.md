# Walkthrough vor Sprint 1 — Befundliste

| | |
|---|---|
| **Arbeitsprodukt nach** | Projektauftrag 6.7 (Reviewtechnik "Walkthrough der Backlog-Einträge vor dem Sprint"; Fehlerfindung getrennt von Fehlerkorrektur) und `docs/06_Definition_of_Ready_und_Done.md`, Teil 1, Abschnitt "Geltung" (einmalige Sichtung des Bestands gegen die vier Glieder, Befundliste ohne Lösungsvorschlag) |
| **Einheit** | S1 (Sprint 1 der Etappe 1: Sprintplanung mit Walkthrough) |
| **Datum** | 2026-11-05 |
| **Verfasser-Rolle** | Requirements Engineer |
| **Gegenstand** | Das Sprint Backlog des Product Owners für Sprint 1: R3-F-008, R3-F-012, R3-F-001, R3-F-011, R3-F-003, R3-F-005. Dazu die vom Product Owner zurückgestellten Einträge der Hypothese des Koordinators, R3-F-020 und R3-F-019, die zum Vergleich gesichteten Kandidaten R3-F-007 und R3-F-010 und, kurz, R3-F-002 und R3-F-009 (nicht gezogen). Wortlaut der Einträge in `docs/05_Product_Backlog.md`, Abschnitt "Etappe 1 — Fundament: Server, Protokoll, Datenbestand"; die Eintragsblöcke sind nicht verändert |
| **Massstab** | Je Abnahmekriterium die vier Glieder Umfang, Prüfsatz, Nachbedingung und Gegenprobe nach `docs/06_Definition_of_Ready_und_Done.md`, Teil 1, "Notation der Abnahmekriterien (R6)" (Vorschlag zur Bestätigung durch den Auftraggeber, bisher nicht bestätigt; hier als Prüfraster verwendet, nicht als gesetzte Regel); je Eintrag die Kriterien R3 (eindeutig, Fachbegriffe im Glossar `docs/03_Glossar.md`), R4 (vollständig in sich, offene Punkte als Annahme benannt) und R6 (prüfbar, hier: in Sprint 1 als ehrlicher Test formulierbar, ohne Teile auszulassen); dazu der Schnitt nach Sachverhalt (D7) und die Backlog-Kriterien B1, B2 und B6, wo ein Befund sie berührt |
| **Grundlage** | Projektauftrag 4.4, 5.3, 5.4, 5.5, 5.8, 6.5, 6.7; ADR 0002 (Modulschnitt, Abschnitt 4.1; A2, A3, A13), Angaben zum Stand der Pakete und des Stapels Test/Schulung aus der Tatsachendatei des Koordinators vom 2026-11-05 und Zusammensetzung des Sprint Backlogs nach dem Bericht des Product Owners vom 2026-11-05 (beides Fremdbeleg, nicht selbst gemessen) |
| **Nicht geprüft** | R1, R2, R5, R7 bis R10 (Ready-Prüfung des Product Owners); Prüfaufwand; Reihenfolge und Sprintschnitt |

## Lesart der Schwere

| Schwere | Bedeutung |
|---|---|
| **blockiert** | Das Kriterium lässt sich in Sprint 1 nicht als ehrlicher Test formulieren oder lässt mehr als eine Lesart zu, von der abhängt, ob der Test überhaupt grün werden kann. Der Eintrag erfüllt in dieser Form die Definition of Ready für Sprint 1 aus Sicht des Requirements Engineers nicht |
| **Nachbesserung** | Kein Blocker. Ein Glied oder eine Annahme fehlt; die Nachbesserung kommt als eigener Backlog-Eintrag über den Product Owner (B4) |
| **Hinweis** | Kein Blocker, keine Nachbesserung zwingend; zur Kenntnis für Product Owner, Software Architect oder GRC-Rolle |

## Übersicht

Die Spalte "Einschätzung" ist ein Hinweis an den Product Owner und ersetzt
seine Ready-Prüfung nicht.

| Eintrag | Rolle im Walkthrough | blockiert | Nachbesserung | Hinweis | Einschätzung aus Sicht des Requirements Engineers |
|---|---|---|---|---|---|
| R3-F-008 | Sprint Backlog | 0 | 6 | 2 | in Sprint 1 prüfbar; Umfang der Manipulationen und Bedeutung der Ermittlungsspur offen |
| R3-F-012 | Sprint Backlog | 0 | 4 | 1 | in Sprint 1 prüfbar; Aufrufweg und Form der Meldung offen |
| R3-F-001 | Sprint Backlog | 0 | 10 | 4 | in Sprint 1 ehrlich prüfbar; Annahmen zu Spur, Person und Fallkategorie offen |
| R3-F-011 | Sprint Backlog | 0 | 5 | 2 | in Sprint 1 für die Fallangaben und die Entitäten aus R3-F-003 prüfbar; Suchform und Prüfsummenverfahren offen |
| R3-F-003 | Sprint Backlog | 0 | 7 | 2 | in Sprint 1 prüfbar; Erzeugungsweg, Zähleinheit und Gegenprobe offen |
| R3-F-005 | Sprint Backlog | 1 | 9 | 4 | nicht ready in dieser Form: die Lesart von "vollständiger Herkunftsnachweis" für Werkzeug und Abfrage entscheidet, ob der Test in Sprint 1 grün werden kann (W1-83) |
| Querschnitt | Sprint Backlog | 0 | 1 | 1 | — |
| R3-F-020 | nicht gezogen | 2 | 13 | 5 | nicht ready in dieser Form: R3-F-020_loeschweg_vollstaendig blockiert (W1-19, W1-21); die beiden anderen Kriterien sind prüfbar mit Nachbesserungen |
| R3-F-019 | nicht gezogen | 0 | 4 | 3 | prüfbar; "leere Umgebung" und "laufendes System" ohne beobachtbare Bestimmung |
| R3-F-007 | Vergleich, nicht gezogen | 1 | 1 | 0 | nicht ehrlich prüfbar in Sprint 1 (W1-61) |
| R3-F-010 | Vergleich, nicht gezogen | 1 | 2 | 0 | nicht ehrlich prüfbar in Sprint 1 (W1-63) |
| R3-F-002 | nicht gezogen | 1 | 2 | 0 | nicht ehrlich prüfbar ohne registriertes Werkzeug (W1-66) |
| R3-F-009 | nicht gezogen | 1 | 2 | 0 | nicht ehrlich prüfbar ohne ausgeführte Abfrage (W1-69) |
| **Summe** | | **7** | **66** | **24** | 97 Befunde; davon im Sprint Backlog (sechs Einträge und Querschnitt) 1 blockierend, 42 Nachbesserung, 16 Hinweis |

Die Kennungen W1-01 bis W1-73 sind vor der Festlegung des Sprint Backlogs
vergeben, W1-74 bis W1-96 danach für R3-F-003 und R3-F-005; die Abschnitte stehen in
der Reihenfolge der Sichtung, die zurückgestellten Einträge sind im Titel
ihres Abschnitts gekennzeichnet.

## Befunde

### R3-F-001 — Fall eröffnen und schliessen

| Kennung | Testname | Glied oder Kriterium | Befund | Schwere |
|---|---|---|---|---|
| W1-01 | R3-F-001_fall_traegt_regime | Umfang | Die Story nennt fünf Angaben bei der Eröffnung (Aktenzeichen, ermittelnde Person, Rechtsgrundlage, Rechtsregime, Aufbewahrungsklasse), das Kriterium prüft nur das Rechtsregime; ob eine fehlende andere Angabe die Eröffnung abweist, ist nicht benannt. | Nachbesserung |
| W1-02 | R3-F-001_fall_traegt_regime | Umfang, R3 | Das Kriterium nennt als zulässige Regime "R1 StPO oder R2 PolG", die Prioritätsordnung in 4.4 führt R1 bis R5; ob eine Eröffnung mit R3, R4 oder R5 zulässig ist oder abgewiesen wird, ist nicht benannt (Teil von 4.4). | Nachbesserung |
| W1-03 | R3-F-001_fall_traegt_regime | Nachbedingung | Für die abgewiesene Eröffnung ohne Regime sind weder die beobachtbare Reaktion (Meldung, Protokolleintrag der Abweisung oder keiner) noch der Zustand danach (kein Fall angelegt) benannt. | Nachbesserung |
| W1-04 | R3-F-001_fall_traegt_regime | Gegenprobe | Der zulässige Fall (Eröffnung mit gesetztem Regime gelingt) ist nur über das Wort "nur" mitgemeint und nicht als Prüffall benannt. | Hinweis |
| W1-05 | R3-F-001_fall_traegt_regime | Nachbedingung | "Die Prüffrist der Aufbewahrungsklasse beginnt" nennt keine beobachtbare Grösse, an der der Beginn abgelesen wird (Zustand des Falls nach 4.4, Zeitpunkt der Fälligkeit). | Nachbesserung |
| W1-06 | R3-F-001_fall_traegt_regime | R4 | "Beide Vorgänge erzeugen je einen Protokolleintrag" lässt offen, in welcher der zwei Spuren der Eintrag steht und was er enthält; die Arbeitsspur nach R3-F-007 und 5.3 zählt Abfragen, Ergebnisse, Schlussfolgerungen und Freigaben auf, nicht Eröffnung und Schliessung eines Falls. | Nachbesserung |
| W1-07 | R3-F-001_fall_traegt_regime | R4 | Offen ist, wer vor der Anmeldung aus Etappe 3 (R3-F-051) als ermittelnde Person und als handelnder Fallverantwortlicher gilt und ob die Beschränkung "Fall eröffnen und schliessen" auf die Rolle Fallverantwortlicher (5.8) Teil des Kriteriums ist. | Nachbesserung |
| W1-08 | R3-F-001_fall_traegt_regime | R3 | Die Story verwendet "Aufbewahrungsklasse", 4.4, Punkt 3b, und der Modulschnitt in ADR 0002, Abschnitt 4.1, "Fallkategorie" für dasselbe eine Feld. | Hinweis |
| W1-09 | R3-F-001_fall_traegt_regime | R3 | "Aktenzeichen", "ermittelnde Person" und "Rechtsgrundlage" stehen nicht im Glossar, und der Unterschied zwischen Rechtsgrundlage und Rechtsregime als zwei Feldern desselben Falls ist nirgends bestimmt. | Nachbesserung |
| W1-10 | R3-F-001_fall_traegt_regime | R4 | Offen ist, ob die Fallkategorie nach der Eröffnung änderbar ist (4.4, Punkt 3b: "Ändert sich später die rechtliche Würdigung, ändert sich die Frist automatisch mit") und wie die Kategorie "Nichtanhandnahme oder Einstellung", die erst mit dem Ausgang feststeht, bei der Eröffnung gewählt wird. | Nachbesserung |
| W1-11 | R3-F-001_fall_traegt_regime | R4 | Die Fallkategorien in 4.4, Punkt 3, sind an der Verfolgungsverjährung nach StGB verankert; welche Kategorie ein Fall unter R2 PolG ohne hängiges Strafverfahren trägt, ist nicht benannt (Teil von 4.4). | Nachbesserung |
| W1-12 | R3-F-001_fall_traegt_regime | R4 | Das Schliessen eines bereits geschlossenen Falls und die Wiederaufnahme, die 4.4 bei der Löschsperre nennt, sind weder als zulässig noch als abzuweisen benannt. | Hinweis |
| W1-13 | R3-F-001_fall_traegt_regime | Schnitt (D7) | Ein Testname trägt drei Sachverhalte: Bedingung der Eröffnung, Schliessen mit Fristbeginn und Protokollierung beider Vorgänge. | Hinweis |

### R3-F-020 — Aufbewahrung als Zustandsmodell, Löschwege vollständig (nicht gezogen, vom Product Owner zurückgestellt)

Gesichtet vor der Festlegung des Sprint Backlogs; die Befunde bleiben für den
Walkthrough des Sprints stehen, in den der Eintrag gezogen wird.

| Kennung | Testname | Glied oder Kriterium | Befund | Schwere |
|---|---|---|---|---|
| W1-14 | R3-F-020_frist_loescht_nicht | Umfang | Nicht benannt ist, über welche Fallkategorien das Kriterium gilt (eine, jede konfigurierte, auch "keine Ablauffrist, Prüfung alle 5 Jahre"). | Nachbesserung |
| W1-15 | R3-F-020_frist_loescht_nicht | Prüfsatz, R4 | Nicht benannt ist, wie der Ablauf der Prüffrist im Test herbeigeführt wird (Zeitquelle) und welcher Bestandteil den Ablauf feststellt (periodischer Lauf, Prüfung beim Zugriff). | Nachbesserung |
| W1-16 | R3-F-020_frist_loescht_nicht | Nachbedingung | Der Zustand des Falls nach Ablauf ("Prüfung fällig" nach 4.4) und ein Protokolleintrag sind nicht benannt, und "unverändert vorhanden" nennt keine Zähleinheit (Fallangaben, abhängige Daten). | Nachbesserung |
| W1-17 | R3-F-020_frist_loescht_nicht | Gegenprobe | Es fehlt der Prüffall, dass vor Ablauf der Prüffrist keine Aufgabe besteht; ein Stand, der bei jedem Fall eine Aufgabe anlegt, besteht das Kriterium. | Nachbesserung |
| W1-18 | R3-F-020_frist_loescht_nicht | R3, R4 | "Aufgabe" stand bis zu dieser Einheit nicht im Glossar; offen sind ihre Form, ihr Empfänger bei mehreren oder nicht mehr vorhandenen Fallverantwortlichen und ihr Ablageort, während die Aufgaben in der Oberfläche erst mit R3-F-059 (Etappe 3) entstehen. | Nachbesserung |
| W1-19 | R3-F-020_loeschweg_vollstaendig | R6, Umfang | Von den acht genannten Ablageorten bestehen in Sprint 1 nach dem Stand der Pakete der Graph (Etappe 4), Anhänge und Asservate (Form offen, offener Punkt 11), der Suchindex (R3-F-054, Etappe 3), Vorschaubilder und abgeleitete Auswertungen nicht; eine Suche mit null Treffern über nicht vorhandene Ablageorte ist grün ohne Aussage, das Kriterium lässt sich in Sprint 1 nicht ohne ausgelassene Teile als ehrlicher Test formulieren. | blockiert |
| W1-20 | R3-F-020_loeschweg_vollstaendig | Gegenprobe | Es fehlt der Prüffall, dass dieselbe Suche vor der Löschung die Fallwerte an jedem Ablageort findet; ohne ihn ist "null Treffer" auch dann grün, wenn die Werte nie dort lagen. | Nachbesserung |
| W1-21 | R3-F-020_loeschweg_vollstaendig | R3, B1 | Der Grabstein-Eintrag trägt eine "Fallnummer", die Suche nach den Fallwerten soll null Treffer liefern; was die Fallnummer ist (Aktenzeichen, also selbst ein Fallwert, oder eine Kennung des Systems), ist nirgends bestimmt, und davon hängt ab, ob beide Teile des Kriteriums zugleich erfüllbar sind. | blockiert |
| W1-22 | R3-F-020_loeschweg_vollstaendig | R4 | Das Kriterium setzt bei der "ausgeführten Löschung" an; der Weg dorthin über "Zur Löschung freigegeben" im Vier-Augen-Prinzip mit Widerruf (4.4), die beiden beteiligten Personen und welche davon die "freigebende Person" im Grabstein ist, sind nicht benannt, und verschiedene Personen sind vor der Anmeldung aus Etappe 3 nicht unterscheidbar. | Nachbesserung |
| W1-23 | R3-F-020_loeschweg_vollstaendig | R4, Prüfsatz | "Fallwerte" ist nicht bestimmt: welche Angaben des Falls gesucht werden, ob Werte aus Entitäten dazugehören, die es in Sprint 1 nicht gibt, und ob Prüfsummen im Protokoll als Treffer zählen. | Nachbesserung |
| W1-24 | R3-F-020_loeschweg_vollstaendig | Umfang | Sicherungen und der eigene Schlüssel je Fall (4.4, Punkt 5, Problem B) kommen im Kriterium nicht vor; kein Kriterium der gesichteten Einträge prüft, dass der Schlüssel mit der Löschung vernichtet ist. | Nachbesserung |
| W1-25 | R3-F-020_loeschweg_vollstaendig | Nachbedingung | Wovon die "Prüfsumme" im Grabstein-Eintrag gebildet ist, ist nicht benannt. | Hinweis |
| W1-26 | R3-F-020_loeschweg_vollstaendig | Verfolgbarkeit (B5) | "Die Kettenprüfung bleibt unversehrt" stützt sich auf R3-F-012 und auf R3-F-011 (Protokoll ohne Falldaten, 4.4, Problem A); der Eintrag führt seitwärts nur R3-F-024. | Hinweis |
| W1-27 | R3-F-020_loeschsperre | Nachbedingung | Die Reaktion auf den Löschversuch (Abweisung, Meldung, Protokolleintrag nach 4.4, Punkt 4) und der Zustand des Falls danach sind nicht benannt. | Nachbesserung |
| W1-28 | R3-F-020_loeschsperre | Gegenprobe | Es fehlt der Prüffall, dass derselbe Fall ohne Löschsperre oder nach ihrer Aufhebung gelöscht werden kann; das Kriterium ist auch grün, wenn keine Löschung gebaut ist. | Nachbesserung |
| W1-29 | R3-F-020_loeschsperre | Umfang | "Unabhängig von jeder Frist" nennt nicht, über welche Zustände das Kriterium gilt (Aktiv, Abgeschlossen, Prüfung fällig, Zur Löschung freigegeben mit terminierter Löschung). | Nachbesserung |
| W1-30 | R3-F-020_loeschsperre | R3 | 4.4 führt die Löschsperre als Zustand des Zustandsmodells, das Glossar als Markierung neben dem Zustand; welche Lesart gilt, ist offen. | Hinweis |
| W1-31 | R3-F-020_loeschsperre | R4 | Wer die Löschsperre setzt und wer sie aufhebt, ist im Eintrag und in 4.4 nicht benannt; die Aufhebung kommt in 4.4 nicht vor. | Hinweis |
| W1-32 | Eintrag als Ganzes | Umfang | Der Titel nennt das Zustandsmodell, die drei Kriterien decken die Zustände Verlängert und Archiviert, den Widerruf der Freigabe zur Löschung, die Protokollpflicht von Verlängerung, Sperre und Freigabe und die Fristen als Konfiguration je Fallkategorie (alles 4.4, Punkte 2 und 4) nicht ab. | Nachbesserung |
| W1-33 | Eintrag als Ganzes | B6 | Der Eintrag bildet 4.4 ab, also den präskriptiven Teil, und trägt als funktionale Anforderung die Kano-Einordnung "Basisfaktor" statt "gesetzt"; ob er beim Sprintschnitt priorisiert oder nur terminiert wird, ist aus dem Eintrag nicht ablesbar. | Hinweis |

### R3-F-008 — Verkettung über SHA-256, ausschliesslich anfügbar

| Kennung | Testname | Glied oder Kriterium | Befund | Schwere |
|---|---|---|---|---|
| W1-34 | R3-F-008_kette_bricht_bei_aenderung | Umfang | Nicht benannt ist, an welcher Spur und an welcher Stelle geändert oder entfernt wird (erster, mittlerer, letzter Eintrag); das Entfernen des letzten Eintrags hinterlässt keinen Nachfolger mit gebrochener Vorgängerprüfsumme, ein Test am mittleren Eintrag ist grün, ohne dass dieser Fall erkannt wird; Einfügen und Vertauschen sind nicht genannt. | Nachbesserung |
| W1-35 | R3-F-008_kette_bricht_bei_aenderung | Prüfsatz, R4 | Offen ist, auf welchem Weg der Test einen Eintrag ändert oder entfernt, wenn Aktualisierungs- und Löschbefehle zugleich abgewiesen werden (mit welcher Datenbankrolle, an welchen Auslösern vorbei). | Nachbesserung |
| W1-36 | R3-F-008_kette_bricht_bei_aenderung | Umfang | "Die Protokolltabelle" steht in der Einzahl bei zwei Spuren; welche Datenbankrollen den Befehl absetzen (Anwendung, Migration, Eigentümer) und ob TRUNCATE (ADR 0002, A2) und Schemaänderungen dazugehören, ist nicht benannt. | Nachbesserung |
| W1-37 | R3-F-008_kette_bricht_bei_aenderung | Nachbedingung | Wie die Bruchstelle benannt wird, ist nicht bestimmt, und der Zustand nach einem abgewiesenen Befehl (Bestand unverändert) ist nicht genannt. | Nachbesserung |
| W1-38 | R3-F-008_kette_bricht_bei_aenderung | Gegenprobe | Der zulässige Fall (Anfügen eines Eintrags läuft durch, ein unversehrter Bestand besteht die Prüfung) fehlt in diesem Eintrag. | Nachbesserung |
| W1-39 | R3-F-008_kette_bricht_bei_aenderung | Schnitt (D7), B2 | Ein Testname trägt drei Sachverhalte (Erkennen einer Änderung, Erkennen einer Entfernung, Abweisung durch die Datenbank); das Benennen der Bruchstelle überschneidet sich mit R3-F-012_pruefung_meldet_bruch. | Hinweis |
| W1-40 | Eintrag als Ganzes | R3, B1 | "Jeder Eintrag beider Spuren" ist verkettet und ausschliesslich anfügbar, die Ermittlungsspur enthält nach 5.3 und Glossar Entitäten, Beziehungsgraph und Berichtsentwurf, die der Löschweg aus R3-F-020 erreichen muss, während 4.4, Problem A, sagt, Fallinhalte lägen im Datenbestand und nicht im Protokoll; ob die Ermittlungsspur ein anfügbares Protokoll oder der Inhalt selbst ist, lässt mehr als eine Lesart zu. | Nachbesserung |
| W1-41 | Eintrag als Ganzes | R6 | Einträge der Ermittlungsspur entstehen nach dem Backlog mit R3-F-006, das nicht im Sprint Backlog steht; welche Einträge in Sprint 1 in dieser Spur liegen, an denen "beider Spuren" geprüft wird, ist nicht benannt. | Hinweis |

### R3-F-011 — Protokoll ohne zweite Kopie der Falldaten

| Kennung | Testname | Glied oder Kriterium | Befund | Schwere |
|---|---|---|---|---|
| W1-42 | R3-F-011_keine_klardaten_im_protokoll | Umfang | "Die Protokolltabellen" sind nicht aufgezählt (beide Spuren, Grabstein, Aufgaben), und Protokolle ausserhalb von Tabellen (Ausgaben der Anwendung, der Datenbank, der Container) sind weder ein- noch ausgeschlossen. | Nachbesserung |
| W1-43 | R3-F-011_keine_klardaten_im_protokoll | Prüfsatz | "Die Klartextwerte eines Testfalls" nennt weder die Felder (Aktenzeichen, ermittelnde Person, Rechtsgrundlage) noch die Form der Suche (Teilzeichenkette, Gross- und Kleinschreibung, Kodierung etwa in JSON). | Nachbesserung |
| W1-44 | R3-F-011_keine_klardaten_im_protokoll | R6, Umfang | Die Story nennt Namen, Adressen und Telefonnummern, die als Eigenschaften von Entitäten nach R3-F-003 entstehen; ob der Testfall eine Entität mit diesen Eigenschaften enthält oder nur die Fallangaben, ist nicht benannt, und ohne sie bliebe der Teil der Story ungeprüft. | Nachbesserung |
| W1-45 | R3-F-011_keine_klardaten_im_protokoll | Nachbedingung, R4 | "Die zugehörigen Prüfsummen sind vorhanden" nennt das Verfahren nicht; eine Prüfsumme über einen Wert mit wenig Spielraum wie eine Telefonnummer ist durch Durchprobieren umkehrbar, und ob sie mit dem eigenen Schlüssel je Fall nach 4.4, Punkt 5, Problem B, gebildet wird, ist offen. | Nachbesserung |
| W1-46 | R3-F-011_keine_klardaten_im_protokoll | Gegenprobe | Es fehlt der Prüffall, dass dieselbe Suche die Werte im Datenbestand findet; ohne ihn ist "null Treffer" auch grün, wenn nie etwas geschrieben wurde. | Nachbesserung |
| W1-47 | R3-F-011_keine_klardaten_im_protokoll | R3 | Story und 5.3 nennen "unkenntlich gemacht oder als Prüfsumme", das Kriterium prüft nur die Prüfsumme; "unkenntlich gemacht" ist nicht bestimmt. | Hinweis |
| W1-48 | Eintrag als Ganzes | B1 | Die Arbeitsspur hält nach R3-F-007 "jede Abfrage mit Werkzeug und Parametern" fest, Parameter wie ein gesuchter Name sind Klartext; das Verhältnis zu diesem Eintrag ist nicht aufgelöst (nicht Gegenstand von Sprint 1). | Hinweis |

### R3-F-012 — Kettenprüfung auf Verlangen

| Kennung | Testname | Glied oder Kriterium | Befund | Schwere |
|---|---|---|---|---|
| W1-49 | R3-F-012_pruefung_meldet_bruch | Umfang | Nicht benannt ist, ob eine Prüfung beide Spuren zusammen oder je Spur prüft und ob je Fall oder über den Gesamtbestand; die Zähleinheit von "Anzahl verifizierter Einträge" folgt daraus und ist offen. | Nachbesserung |
| W1-50 | R3-F-012_pruefung_meldet_bruch | Prüfsatz | "Ein manipulierter Bestand" nennt die Manipulationsarten nicht (Änderung, Entfernen, Einfügen, Vertauschen, Abschneiden am Ende). | Nachbesserung |
| W1-51 | R3-F-012_pruefung_meldet_bruch | Nachbedingung | Die Form der "Position des ersten Bruchs" bei zwei Spuren und mehreren Fällen ist nicht bestimmt, und ob die Prüfung den Bestand unverändert lässt und selbst einen Protokolleintrag erzeugt, ist nicht genannt. | Nachbesserung |
| W1-52 | R3-F-012_pruefung_meldet_bruch | R4 | "Auf Verlangen" nennt weder den Aufrufweg (Funktion, Kommandozeile, Schnittstelle; die Anwendung hat nach dem Stand keine Route, der MCP-Server entsteht mit R3-F-013) noch, wer die Prüfung verlangen darf. | Nachbesserung |
| W1-53 | R3-F-012_pruefung_meldet_bruch | Gegenprobe | Die Gegenprobe ist mit dem unversehrten Bestand vorhanden; der leere Bestand ist nicht genannt. | Hinweis |

### R3-F-003 — Kanonischer Datenbestand nach FollowTheMoney

| Kennung | Testname | Glied oder Kriterium | Befund | Schwere |
|---|---|---|---|---|
| W1-74 | R3-F-003_ftm_schemakonform | Umfang, R6 | "Erzeugte Entitäten" nennt weder, durch wen oder über welchen Weg sie erzeugt werden (Schreibpfad des Moduls kanon, Testcode, später eine Quelle), noch die Zähleinheit (jede erzeugte Entität, je Entitätstyp eine); prüft der Test Entitäten, die er selbst ohne den Schreibpfad gebaut hat, ist er grün, ohne dass der Bestand gebaut ist. | Nachbesserung |
| W1-75 | R3-F-003_ftm_schemakonform | Umfang, R3, B1 | Die Story nennt Personen, Firmen, Vermögenswerte und Beziehungen, das Glossar zählt zur Entität auch IP-Adresse, Domain und Wallet; welche Entitätstypen nach FollowTheMoney und welche nach STIX 2.1 (R3-F-004) abgelegt werden, ist nicht abgegrenzt. | Nachbesserung |
| W1-76 | R3-F-003_ftm_schemakonform | Prüfsatz | Als Abweisungsfall ist nur der unbekannte Entitätstyp benannt; ob fehlende Pflichtangaben, unbekannte oder falsch typisierte Eigenschaften und Beziehungen auf nicht vorhandene Entitäten unter "validieren" fallen, ist offen. | Nachbesserung |
| W1-77 | R3-F-003_ftm_schemakonform | Prüfsatz, R3 | "Erzeugte Entitäten validieren gegen das Schema" lässt zwei Lesarten zu: Prüfung beim Schreiben mit Abweisung oder Prüfung über den abgelegten Bestand. | Nachbesserung |
| W1-78 | R3-F-003_ftm_schemakonform | Nachbedingung | "Abgewiesen statt still übernommen" nennt weder die beobachtbare Reaktion (Meldung, Protokolleintrag) noch den Zustand danach (kein Teil des Datensatzes im Bestand). | Nachbesserung |
| W1-79 | R3-F-003_ftm_schemakonform | Gegenprobe | Es fehlt der Prüffall, dass eine schemakonforme Entität je betroffenem Typ abgelegt wird und danach im Bestand lesbar ist. | Nachbesserung |
| W1-80 | Eintrag als Ganzes | R4 | Ob jede Entität einem Fall zugeordnet ist, ist nicht benannt; davon hängen der spätere Löschweg (R3-F-020) und der Testfall von R3-F-011 ab. | Nachbesserung |
| W1-81 | Eintrag als Ganzes | R4 | Das Glossar sagt, eine Entität trage "immer ... eine Klassifizierungsstufe"; ob Entitäten in Sprint 1 ohne Klassifizierung abgelegt werden, ist nicht benannt (Klassifizierung im Suchindex: R3-F-054, Etappe 3). | Hinweis |
| W1-82 | Eintrag als Ganzes | R4 | Die Fassung des FollowTheMoney-Schemas, gegen die geprüft wird, ist nicht benannt; sie berührt die Reproduzierbarkeit (5.4, R3-Q-002). | Hinweis |

### R3-F-005 — Herkunftsnachweis nach W3C PROV an jedem Datenpunkt

| Kennung | Testname | Glied oder Kriterium | Befund | Schwere |
|---|---|---|---|---|
| W1-83 | R3-F-005_kein_knoten_ohne_herkunft | R3, R4, R6 | "Vollständiger Herkunftsnachweis" mit Werkzeug und Abfrage lässt zwei Lesarten zu, Verweise auf bestehende Datensätze (ein Eintrag im Werkzeugverzeichnis, ein Abfrageeintrag der Arbeitsspur; ADR 0002, A2: NOT NULL-Fremdschlüssel) oder frei gesetzte Werte; die erste ist in Sprint 1 ohne Werkzeugverzeichnis und Abfragepfad nicht erfüllbar, die zweite belegt nur nicht leere Felder, und davon hängt ab, ob und was der Test in Sprint 1 grün zeigen kann. | blockiert |
| W1-84 | R3-F-005_kein_knoten_ohne_herkunft | R3 | Die Story nennt Werkzeug, Abfrage, Zeitpunkt und erhebende Person, das Glossar (Herkunftsnachweis) Quelle, Zeitpunkt der Erhebung und "von wem"; welche Angaben zusammen "vollständig" sind, ist nicht bestimmt. | Nachbesserung |
| W1-85 | R3-F-005_kein_knoten_ohne_herkunft | R4 | Wer vor der Anmeldung aus Etappe 3 (R3-F-051) als erhebende Person gilt und ob die Angabe auf eine bestehende Person verweisen muss, ist nicht benannt. | Nachbesserung |
| W1-86 | R3-F-005_kein_knoten_ohne_herkunft | Umfang, R3 | Titel und 5.4 sprechen vom Datenpunkt, das Kriterium von Knoten und Kante; ob einzelne Eigenschaften einer Entität Datenpunkte sind und was eine Kante ist, wenn FollowTheMoney Beziehungen selbst als Entitäten führt, ist nicht bestimmt. | Nachbesserung |
| W1-87 | R3-F-005_kein_knoten_ohne_herkunft | Umfang | "Der gesamte Datenbestand" nennt die Menge nicht: nur der kanonische Datenbestand oder auch Fall, Spuren und Grabstein, und mit welcher Zähleinheit. | Nachbesserung |
| W1-88 | R3-F-005_kein_knoten_ohne_herkunft | Prüfsatz | "Der Versuch ... zu schreiben" nennt nicht, über welche schreibenden Wege er unternommen wird (Schnittstelle des Moduls kanon, unmittelbarer Datenbankzugriff der Anwendungsrolle, mehrere Datenpunkte in einem Vorgang). | Nachbesserung |
| W1-89 | R3-F-005_kein_knoten_ohne_herkunft | Prüfsatz | Die Formen des unvollständigen Nachweises sind nicht benannt (je fehlende Angabe einzeln, leerer Wert, Verweis ins Leere). | Nachbesserung |
| W1-90 | R3-F-005_kein_knoten_ohne_herkunft | Nachbedingung | Die Reaktion auf den abgewiesenen Schreibversuch (Meldung, Protokolleintrag) und der Zustand danach (weder Knoten noch Kante noch Teil davon geschrieben, bei einer Kante auch kein halber Zustand) sind nicht benannt. | Nachbesserung |
| W1-91 | R3-F-005_kein_knoten_ohne_herkunft | Gegenprobe | Es fehlen zwei Prüffälle: das Schreiben mit vollständigem Nachweis gelingt, und die Prüfung über den Bestand findet einen eingebrachten Datenpunkt ohne Herkunft; ohne sie ist "null Datenpunkte ohne Herkunft" auch bei leerem Bestand oder wirkungsloser Prüfung grün. | Nachbesserung |
| W1-92 | Eintrag als Ganzes | R4 | Datenpunkte, die nicht aus einer Abfrage stammen, etwa Werte aus einem Asservat (Glossar: Herkunftsangabe auf das Asservat) oder von Hand im Graphen gesetzte (R3-F-072), haben weder Werkzeug noch Abfrage; ob sie nach diesem Kriterium "vollständig" sind, ist nicht benannt. | Nachbesserung |
| W1-93 | R3-F-005_kein_knoten_ohne_herkunft | R4 | Ob "Zeitpunkt" der Zeitpunkt der Erhebung oder des Schreibens ist, ist nicht benannt. | Hinweis |
| W1-94 | Eintrag als Ganzes | Umfang | Der Titel nennt W3C PROV, das Kriterium prüft PROV nicht; nach ADR 0002, A2, entsteht PROV erst beim Export (Etappe 4). | Hinweis |
| W1-95 | R3-F-005_kein_knoten_ohne_herkunft | R4 | Ob "eine Prüfung über den gesamten Datenbestand" eine Funktion des Produkts ist (wie die Kettenprüfung) oder allein eine Abfrage des Tests, ist nicht benannt. | Hinweis |
| W1-96 | R3-F-005_kein_knoten_ohne_herkunft | Schnitt (D7) | Ein Testname trägt zwei Sachverhalte: Abweisung am Schreibpfad und Bestandsaussage über den ganzen Datenbestand. | Hinweis |

### R3-F-019 — Durchgängiges Setup vom Klonen bis zum Start (nicht gezogen, vom Product Owner zurückgestellt)

Gesichtet vor der Festlegung des Sprint Backlogs; die Befunde bleiben stehen.

| Kennung | Testname | Glied oder Kriterium | Befund | Schwere |
|---|---|---|---|---|
| W1-54 | R3-F-019_setup_bricht_verstaendlich_ab | Prüfsatz | "Eine leere Umgebung" ist nicht bestimmt (vorhanden oder nicht: Docker, Netzzugang, geladene Images; die Begrenzung anonymer Abrufe bei Docker Hub, M-G21-01, ist nicht berücksichtigt). | Nachbesserung |
| W1-55 | R3-F-019_setup_bricht_verstaendlich_ab | Nachbedingung | "Endet mit laufendem System" nennt kein beobachtbares Merkmal; der Stapel Test/Schulung veröffentlicht keine Ports, die Anwendung hat keine Route und verbindet sich nach dem Stand von G2 nicht mit der Datenbank. | Nachbesserung |
| W1-56 | R3-F-019_setup_bricht_verstaendlich_ab | Umfang | "Mit absichtlich fehlender Voraussetzung" lässt offen, ob eine oder jede Voraussetzung geprüft wird, und die Voraussetzungen sind nicht aufgezählt. | Nachbesserung |
| W1-57 | R3-F-019_setup_bricht_verstaendlich_ab | Nachbedingung | Der Zustand nach dem Abbruch (was das Setup angelegt hat und was nachweislich nicht existiert, etwa Geheimnisdateien, Datenträger, Container) ist nicht benannt. | Nachbesserung |
| W1-58 | Eintrag als Ganzes | Umfang | Die Story und 5.5 verlangen Abfragen nur dort, wo die Eingabe zwingend vom Benutzer kommt (Secrets, Zugangsdaten, Umgebungswahl), und einen verständlichen Abbruch "jedes Schritts"; das Kriterium prüft beides nicht. | Hinweis |
| W1-59 | R3-F-019_setup_bricht_verstaendlich_ab | R4 | Wie eine interaktive Abfrage in einem maschinellen Testlauf beantwortet wird, ist nicht benannt. | Hinweis |
| W1-60 | Eintrag als Ganzes | R4 | Offen ist, ob das Setup nur Test/Schulung herstellt (5.16, kein Zugang zur Produktion) und ob die Abnahme in Sprint 1 den Stand am Ende von Sprint 1 meint, obwohl "laufendes System" mit jeder Etappe mehr umfasst. | Hinweis |

### R3-F-007 — Arbeitsspur (Vergleich, nicht gezogen)

| Kennung | Testname | Glied oder Kriterium | Befund | Schwere |
|---|---|---|---|---|
| W1-61 | R3-F-007_arbeitsspur_vollstaendig | R6 | Der Durchlauf setzt Abfragen über registrierte Werkzeuge, erteilte Freigaben (R3-F-014) und Schlussfolgerungen des Modells voraus; keines davon entsteht in Sprint 1, ein ehrlicher Test ist nicht formulierbar. | blockiert |
| W1-62 | R3-F-007_arbeitsspur_vollstaendig | Umfang | Die Story zählt "jedes Ergebnis" zur Arbeitsspur, das Kriterium zählt Abfrageeinträge, Freigaben und Schlussfolgerungen, nicht die Ergebnisse und nicht die Negativbefunde. | Nachbesserung |

### R3-F-010 — Trennung von Quellenaussage und Schlussfolgerung (Vergleich, nicht gezogen)

| Kennung | Testname | Glied oder Kriterium | Befund | Schwere |
|---|---|---|---|---|
| W1-63 | R3-F-010_jede_zeile_klassifiziert | R6 | "Jeder Knoten" setzt den kanonischen Datenbestand (R3-F-003, R3-F-004), eine Schlussfolgerung das Sprachmodell und "Darstellung und Export" Etappe 4 voraus; in Sprint 1 bliebe von dem Kriterium nur ein Teil prüfbar. | blockiert |
| W1-64 | R3-F-010_jede_zeile_klassifiziert | Umfang, R3 | "Jeder Eintrag trägt genau eine der beiden Kennzeichnungen" erfasst auch Protokolleinträge ohne Aussage, wie sie R3-F-001 und R3-F-020 in Sprint 1 erzeugen (Fall eröffnet, Löschung ausgeführt); welche Kennzeichnung sie tragen, ist offen. | Nachbesserung |
| W1-65 | R3-F-010_jede_zeile_klassifiziert | Nachbedingung | "Optisch abgesetzt" nennt kein prüfbares Merkmal. | Nachbesserung |

### R3-F-002 — Fallbindung: kein Werkzeug ohne Fall (nicht gezogen)

| Kennung | Testname | Glied oder Kriterium | Befund | Schwere |
|---|---|---|---|---|
| W1-66 | R3-F-002_kein_werkzeug_ohne_fall | R6, Gegenprobe | Ohne registriertes Werkzeug ist die Iteration "über alle registrierten Werkzeuge" leer und grün, und der zulässige Fall (Aufruf mit gültigem Fallbezug läuft durch) fehlt; in Sprint 1 entsteht kein Werkzeug. | blockiert |
| W1-67 | R3-F-002_kein_werkzeug_ohne_fall | R4 | "Gültiger Fallbezug" ist nicht bestimmt: Ob ein geschlossener Fall, ein Fall in "Prüfung fällig", ein Fall mit Löschsperre oder ein gelöschter Fall gültig ist, ist nicht benannt. | Nachbesserung |
| W1-68 | R3-F-002_kein_werkzeug_ohne_fall | Nachbedingung | "Protokolliert" nennt Spur und Inhalt nicht, und der Zustand nach der Abweisung (keine Abfrage an die Quelle, kein Kontingentverbrauch) ist nicht genannt. | Nachbesserung |

### R3-F-009 — Negativbefunde erscheinen zwingend (nicht gezogen)

| Kennung | Testname | Glied oder Kriterium | Befund | Schwere |
|---|---|---|---|---|
| W1-69 | R3-F-009_negativbefund_protokolliert | R6 | Das Kriterium setzt eine ausgeführte Abfrage über ein registriertes Werkzeug voraus; keine entsteht in Sprint 1. | blockiert |
| W1-70 | R3-F-009_negativbefund_protokolliert | Prüfsatz | "Ein Protokoll, das nur Treffer enthält, lässt den Test fehlschlagen" lässt zwei Lesarten zu (ein absichtlich veränderter Stand als Prüffall, oder eine Aussage über den Bestand) und nennt den Prüffall nicht. | Nachbesserung |
| W1-71 | R3-F-009_negativbefund_protokolliert | Gegenprobe | Es fehlt der Prüffall, dass eine Abfrage mit Treffer keinen Negativbefund erzeugt. | Nachbesserung |

### Querschnitt des Sprint Backlogs

| Kennung | Testname | Glied oder Kriterium | Befund | Schwere |
|---|---|---|---|---|
| W1-72 | R3-F-001, R3-F-008, R3-F-009, R3-F-011, R3-F-012 | R3 | Für denselben Gegenstand stehen "Protokoll", "Protokolltabelle", "Protokolltabellen" und "beide Spuren" nebeneinander. | Hinweis |
| W1-73 | R3-F-008, R3-F-012, R3-F-020 | R4 | Ob die Verkettung je Fall oder über den Gesamtbestand läuft, ist in keinem der drei Einträge benannt; davon hängen die Bruchstelle, die Zählung der Kettenprüfung und der Platz des Grabstein-Eintrags in der Kette ab. | Nachbesserung |

## Glossar

Nachgetragen in `docs/03_Glossar.md` mit dieser Einheit, weil Sprint 1 die
Begriffe als Bezeichner braucht (ADR 0002, A13) und R3 sie im Glossar verlangt:
Aufgabe, Datenpunkt, Fallkategorie, Fallverantwortlicher, Kettenprüfung,
Klardaten, Löschweg, Protokolleintrag, Prüffrist, Rechtsregime, Verkettung; bei
Aufbewahrungsklasse das Synonym
Fallkategorie vermerkt, bei Grabstein-Eintrag die Kurzform. Nicht eingetragen,
weil keine Bestimmung belegt ist: Aktenzeichen, Fallnummer, ermittelnde Person,
Rechtsgrundlage als Feld des Falls, Ablageort; sie stehen im Glossar unter "Zu
ergänzen". Die Befunde W1-08, W1-09, W1-18 und W1-21 bleiben davon unberührt:
Das Glossar bestimmt Begriffe, es ändert keinen Eintrag.

## Was dieser Walkthrough nicht ist

Er ist keine Nachbesserung, keine Priorisierung und keine Änderung an den
Einträgen. Die Eintragsblöcke in `docs/05_Product_Backlog.md` sind unverändert.
Im Review wird gesammelt, nicht diskutiert und nicht gelöst (6.7); jede
Korrektur kommt als eigener Backlog-Eintrag über den Product Owner herein (B4),
Korrekturen am präskriptiven Teil aus 4.4 (W1-02, W1-11, W1-32, W1-33)
entscheidet die GRC-Rolle gemeinsam mit dem Auftraggeber (6.6). Ob ein Eintrag
in Sprint 1 gezogen wird, entscheidet der Product Owner in seiner Ready-Prüfung;
die Einschätzungen in der Übersicht sind Hinweise dazu. Der Massstab der vier
Glieder ist ein Vorschlag zur Bestätigung durch den Auftraggeber; ein Befund
nach diesem Massstab ist kein Verstoss gegen eine gesetzte Regel.

## Nachtrag vom 2026-11-05 (Einheit D22)

Verfasser-Rolle: Requirements Engineer. Anlass: Annahme von Sprint 1 durch den
Merge des Pull Requests #52 am 2026-11-05 (Merge-Commit
`729fa34109c4e097d02d07ad9cd8ac06e2f67b72`), mit dem die Entscheidpunkte
E-S1-01 bis E-S1-22 je nach der Empfehlung entschieden sind (Angabe des
Koordinators, Fremdbeleg). Die Befunde W1-01 bis W1-96 und die Übersicht
bleiben im Stand der Einheit S1; dieser Nachtrag ändert keinen Befund und
schlägt keine Lösung vor.

**Vermerk zu W1-64.** E-S1-08 (ADR 0007, Entscheidpunkte; Spalte kennzeichnung
in Entscheid 13) ist mit dem Merge #52 nach (a) entschieden: zwei Werte;
quellenaussage heisst "erhoben oder festgestellt" (von einer Quelle, einer
Person oder dem System), schlussfolgerung "vom Modell gefolgert". Das ist die
Lesart des Software Architects für Protokolleinträge ohne Aussage, wie sie
W1-64 nennt. Der Befund W1-64 bleibt stehen: Der Wortlaut des Backlog-Eintrags
R3-F-010 ist unverändert, und eine Korrektur des Eintrags kommt als eigener
Backlog-Eintrag über den Product Owner (B4).

**Befund W1-97** (Prüfung der Annahme in E-S1-10 als Restpunkt vor S1.3).

| Kennung | Testname | Glied oder Kriterium | Befund | Schwere |
|---|---|---|---|---|
| W1-97 | R3-F-001_fall_traegt_regime | R4, R3 | E-S1-10 (a), entschieden mit dem Merge #52, macht das Aktenzeichen unter den nicht gelöschten Fällen eindeutig und stützt sich auf die Annahme, Teilverfahren trügen eigene Aktenzeichen. Der Eintrag R3-F-001 trägt diese Annahme nicht: Story und Kriterium nennen das Aktenzeichen nur als Angabe bei der Eröffnung, weder Eindeutigkeit noch Teilverfahren kommen vor, und das Kriterium benennt keine Abweisung einer Eröffnung wegen eines bestehenden Aktenzeichens. 4.4 nennt das Aktenzeichen nicht; der Begriff ist nicht bestimmt (W1-09, Glossar "Zu ergänzen" Nr. 4). Nicht benannt ist damit, ob dasselbe Aktenzeichen in mehr als einem nicht gelöschten Fall vorkommen darf, etwa bei Teilverfahren, bei einem Fall, der unter R2 eröffnet ist und in ein Strafverfahren nach R1 übergeht, oder bei einer Wiederaufnahme (4.4, Löschsperre) eines abgeschlossenen, also nicht gelöschten Falls. | Nachbesserung |

Schwere nach der Lesart oben: Das Kriterium lässt sich mit und ohne
Eindeutigkeit als ehrlicher Test formulieren und grün zeigen; offen ist eine
Annahme (R4), keine zweite Lesart, von der abhängt, ob der Test grün werden
kann. Mit W1-97 zählt R3-F-001 zehn Befunde der Schwere Nachbesserung, die
Befundliste 97 Befunde (7 blockiert, 66 Nachbesserung, 24 Hinweis), davon im
Sprint Backlog 1 blockierend, 42 Nachbesserung, 16 Hinweis.

**Vermerk zu W1-83.** E-S1-21 ist mit dem Merge #52 nach (a) entschieden:
Werkzeug und Abfrage sind in Sprint 1 Texte fester Form, geprüft wird
Vollständigkeit, nicht Echtheit (ADR 0007, Entscheid 25 und Grenze GS-6;
`docs/sprints/sprint-01.md`, Hindernis H-7). W1-83 bleibt damit als
Festlegung des Software Architects gefasst, nicht als Änderung des
Backlog-Eintrags R3-F-005; der Wortlaut des Kriteriums ist unverändert, und
der Befund bleibt in der Liste stehen.

## Nachtrag vom 2026-11-09 (vor der Einheit S1.3)

Verfasser-Rolle: Requirements Engineer. Anlass: Restpunkt aus ADR 0007,
E-S1-10 (Prüfung der Annahme vor S1.3), und Auftrag des Koordinators vom
2026-11-09. Die Befunde W1-01 bis W1-97 und ihre Schwere bleiben unverändert;
die Zahlen der Befundliste (97 Befunde: 7 blockiert, 66 Nachbesserung, 24
Hinweis; im Sprint Backlog 1, 42, 16) sind am Dokument nachgezählt, und die
Zeile "Summe" der Übersicht ist darauf berichtigt (Nachtrag zur Berichtigung
der Summenzeile unten).

**Vermerk zu W1-97: bearbeitet.** Der Befund bleibt in der Liste stehen; die
Nachbesserung ist als Fortschreibung des Eintrags R3-F-001 in
`docs/05_Product_Backlog.md` vorgenommen (Zeile "Stand 2026-11-09"): zweites
Abnahmekriterium `R3-F-001_aktenzeichen_eindeutig` und Zeile "Achtung" mit den
Annahmen zu Teilverfahren, Übergang von R2 nach R1 und Wiederaufnahme; die
Ready-Bestätigung durch den Product Owner und seine Zeile in der Tabelle
Nachführungen liegen vor: Ready-Bestätigung im Eintrag R3-F-001 von
`docs/05_Product_Backlog.md`, Zeile "Stand 2026-11-09" (ready mit Vorbehalt
bis E-S13-01), und Nachführung Nr. 65 (dazu Nr. 66 für den Bau). Im Glossar `docs/03_Glossar.md` steht der Eintrag
Aktenzeichen als Vorschlag zur Bestätigung durch den Auftraggeber, mit der
Abgrenzung zur Fallnummer; "Zu ergänzen" Nr. 4 ist nachgeführt. Die
Bestätigung der Annahmen und des Glossarvorschlags geht dem Auftraggeber (S-01)
als Vorlage im Pull Request der Einheit S1.3 zu. Die Befunde W1-09 und W1-21
bleiben davon unberührt: W1-21 hängt an R3-F-020, das nicht gezogen ist.

**Nachtrag zur Berichtigung der Summenzeile (2026-11-09).** Die Zeile "Summe"
der Übersicht stand im Stand der Einheit S1 (96 Befunde; 7, 65, 24; im Sprint
Backlog 1, 41, 16) und war mit W1-97 aus dem Nachtrag vom 2026-11-05 nicht
nachgeführt. Nachgezählt am Dokument über die Schwere-Spalte der Befundzeilen
W1-01 bis W1-97: 97 Befunde, 7 blockiert, 66 Nachbesserung, 24 Hinweis; davon
in den Abschnitten der sechs Einträge des Sprint Backlogs, im Querschnitt und
mit W1-97 (R3-F-001) 1 blockierend, 42 Nachbesserung, 16 Hinweis. Die Zeile
"Summe" ist auf diese Werte berichtigt. Die Zeile R3-F-001 der Übersicht ist
ebenso von 9 auf 10 Nachbesserung berichtigt (W1-97 mitgezählt), sodass die
Einzelzeilen die Summe 66 ergeben. Die Befunde selbst sind unverändert.

## Nachtrag vom 2026-11-09 (Einheit D25)

Verfasser-Rolle: Requirements Engineer. Anlass: Merge des Pull Requests #55
am 2026-11-09 (Merge-Commit `3cb896da222feefc0df124c8447a443f2dfab7ae`; erster
Formweg, ohne Kommentar; Angabe des Koordinators, Fremdbeleg), mit dem die
Vorlagen E-S13-01 bis E-S13-04 je nach der Empfehlung entschieden sind. Die
Befunde W1-01 bis W1-97, ihre Schwere, die Übersicht und die Zeile "Summe"
bleiben unverändert; dieser Nachtrag fügt keinen Befund hinzu und schlägt
keine Lösung vor.

**Vermerk zu W1-97: abgeschlossen.** E-S13-01 ist nach (a) entschieden: Die
Eindeutigkeit des Aktenzeichens unter den nicht gelöschten Fällen nach der
Angleichung und die drei Annahmen der Zeile "Achtung" des Eintrags R3-F-001
(Teilverfahren, Übergang von R2 nach R1, Wiederaufnahme) gelten für den Bau
als entschieden (ADR 0007, Festlegung S1.3; gebaut in S1.3, abgenommen mit
demselben Merge). E-S13-02 ist nach (b) entschieden: Der Glossareintrag
Aktenzeichen bleibt Vorschlag zur Bestätigung durch den Auftraggeber (S-01),
bis er den Begriff ausdrücklich bestimmt. Die Vorlage aus W1-97 ist damit
erledigt und W1-97 abgeschlossen; der Befund bleibt in der Liste stehen. Die
Befunde W1-09 und W1-21 bleiben unberührt. Glossar "Zu ergänzen" Nr. 4 bleibt
offen: Die Bestimmung der Begriffe Aktenzeichen und Fallnummer liegt beim
Auftraggeber.

## Nachtrag vom 2026-11-09 (Einheit S1.4)

Verfasser-Rolle: Requirements Engineer. Anlass: Auftrag des Koordinators vom
2026-11-09, die Befunde der Schwere Nachbesserung zu R3-F-003 und R3-F-005 vor
der Festlegung S1.4 zu bearbeiten, wie W1-97 vor S1.3 (Stand des Repositories
nach der Angabe des Koordinators, Fremdbeleg). Die Befunde W1-01 bis W1-97,
ihre Schwere, die Übersicht und die Zeile "Summe" bleiben unverändert; dieser
Nachtrag fügt keinen Befund hinzu. Die Hinweise W1-81, W1-82 und W1-93 bis
W1-96 sind mitbearbeitet, soweit ADR 0007 die Antwort gibt.

**Vermerk zu W1-74 bis W1-82 und W1-84 bis W1-96: bearbeitet.** Die Befunde
bleiben in der Liste stehen; die Nachbesserung ist als Fortschreibung der
Einträge R3-F-003 und R3-F-005 in `docs/05_Product_Backlog.md` vorgenommen
(je Zeile "Stand 2026-11-09"), gestützt auf ADR 0007, Entscheide 24 und 25 und
die mit dem Merge #52 entschiedenen E-S1-07 a, E-S1-12 a, E-S1-13 a, E-S1-15 a
und E-S1-21 a. Was ADR 0007 nicht beantwortet, steht als Annahme in der Zeile
"Achtung" des Eintrags und als Vorlage oder Frage unten.

| Befund | Bearbeitet durch | Offen |
|---|---|---|
| W1-74 | R3-F-003, Präzisierung: Erzeugungsweg kanon.service.schreiben, Zähleinheit Knoten und Kante | — |
| W1-75 | R3-F-003, Präzisierung (a) und "Achtung" (1) | Vorlage E-S14-01; Abgrenzung zu STIX 2.1 mit R3-F-004 |
| W1-76 | R3-F-003, Präzisierung (b): unbekanntes und abstraktes Schema, unbekannte Eigenschaft, Kante ohne bestehende Enden | FA-S14-03 (Pflichteigenschaften, Werttypen) |
| W1-77 | R3-F-003, Präzisierung: Prüfung beim Schreiben mit Abweisung | — |
| W1-78 | R3-F-003, Präzisierung (b) und "Achtung" (4): Fehlerklasse aus core, kein Teil im Bestand, Spur unverändert, kein Protokolleintrag | — |
| W1-79 | R3-F-003, Präzisierung (a): Gegenprobe je Schema des Vorrats | Vorrat nach E-S14-01 |
| W1-80 | R3-F-003, "Achtung" (2): genau ein Fall (E-S1-12 a) | FA-S14-01, FA-S14-02 |
| W1-81 | R3-F-003, "Achtung" (5); Glossar, Entität (Vorschlag) | — |
| W1-82 | R3-F-003, "Achtung" (6): Fassung in `backend/uv.lock` | — |
| W1-84 | R3-F-005, Präzisierung des ersten Kriteriums: fünf Angaben nach Entscheid 25; Glossar, Herkunftsnachweis (Vorschlag) | — |
| W1-85 | R3-F-005, Präzisierung und "Achtung" (1): Benutzerkennung ohne Verweis (E-S1-07 a, GS-1) | — |
| W1-86 | R3-F-005, Präzisierung: Datenpunkt ist Knoten oder Kante, Eigenschaften Teil davon (E-S1-15 a); Kantenschemata in beziehung (Entscheid 24); Glossar, Datenpunkt (Vorschlag) | FA-S14-10 (Kante als Ende einer Kante) |
| W1-87 | R3-F-005, zweites Kriterium: Tabellen entitaet und beziehung aller Fälle, Zähleinheit Knoten und Kante | — |
| W1-88 | R3-F-005, Präzisierung: Weg über kanon und unmittelbarer Weg der Anwendungsrolle | FA-S14-04 (mehrere Datenpunkte in einem Vorgang) |
| W1-89 | R3-F-005, Präzisierung: je Angabe fehlend, leer, ausserhalb der Form, Verweis ins Leere | FA-S14-02, FA-S14-07 |
| W1-90 | R3-F-005, Präzisierung und "Achtung" (5): Reaktion je Weg, kein halber Zustand | FA-S14-04 |
| W1-91 | R3-F-005, Gegenprobe im ersten Kriterium; zweites Kriterium mit eingebrachtem Datenpunkt und nicht leerem Bestand | — |
| W1-92 | R3-F-005, "Achtung" (7): in Sprint 1 nicht erreichbar | FA-S14-11, Wiedervorlage R3-F-024 und R3-F-072 |
| W1-93 | R3-F-005, "Achtung" (2): Zeitpunkt der Erhebung | FA-S14-06 |
| W1-94 | R3-F-005, "Achtung" (8): PROV erst beim Export | — |
| W1-95 | R3-F-005, zweites Kriterium: Funktion des Produkts (Entscheid 25) | — |
| W1-96 | R3-F-005, zweites Abnahmekriterium als eigener Testname | — |

W1-83 bleibt im Stand des Vermerks aus dem Nachtrag vom 2026-11-05: entschieden
mit E-S1-21 a; die Präzisierung von R3-F-005 übernimmt diese Lesart.

**Vorlage an den Auftraggeber.** E-S14-01 (W1-75, W1-79): Welche Schemata von
FollowTheMoney in Sprint 1 geschrieben werden können. (a) Alle nicht
abstrakten Knoten- und Kantenschemata der Bibliothek; (b) ein geschlossener
Vorrat nach der Story von R3-F-003 (Personen, Firmen, Vermögenswerte und die
Kantenschemata zwischen ihnen), die Liste legt der Software Architect in der
Festlegung S1.4 fest, jede Erweiterung kommt mit ihrem Eintrag. Empfehlung des
Requirements Engineers: (b). Die Vorlage geht dem Auftraggeber im Pull Request
der Einheiten D25 und S1.4 zu.

**Fragen an den Software Architect (Festlegung S1.4).** FA-S14-01 Schreiben in
einen abgeschlossenen Fall; FA-S14-02 Verweise über Fallgrenzen (Kante mit
einem Ende in einem anderen Fall, Datenpunkt mit dem Herkunftssatz eines
anderen Falls); FA-S14-03 fehlende Pflichteigenschaften und Werte ausserhalb
des Typs einer Eigenschaft; FA-S14-04 Prüfung vor jedem Schreiben und mehrere
Datenpunkte in einer Transaktion; FA-S14-05 ein Herkunftssatz für mehrere
Datenpunkte; FA-S14-06 Bedeutung von zeitpunkt im Herkunftssatz und ein
Zeitpunkt nach dem Schreiben; FA-S14-07 Formen, die herkunft_pruefen zählt, und
ob sie die Kennungen nennt; FA-S14-08 Kennzeichnung der Spureinträge entitaet
und beziehung im Verhältnis zur Kennzeichnung des Herkunftssatzes; FA-S14-09
zweite Ablage derselben FollowTheMoney-Kennung im selben Fall; FA-S14-10
Kantenschemata, deren Ende selbst eine Kante wäre; FA-S14-11 Herkunftssatz
für Datenpunkte ohne Abfrage (Wiedervorlage, nicht S1.4).

Im Glossar `docs/03_Glossar.md` stehen zu den Einträgen Datenpunkt,
Herkunftsnachweis und Entität Vorschläge zur Ergänzung. Die Ready-Bestätigung
und die Zeile in der Tabelle Nachführungen des Backlogs schreibt der Product
Owner.

**Ergänzung nach der Festlegung S1.4 (2026-11-09).** Die Fragen FA-S14-01 bis
FA-S14-11 sind in der Festlegung S1.4 des Software Architects beantwortet
(ADR 0007, Festlegung S1.4); die Antworten sind in den Zeilen "Achtung" der
Einträge R3-F-003 und R3-F-005 vermerkt, die Annahmen bleiben stehen. Zu W1-82
gilt nach der Lieferkettenprüfung E-S1-13 (b): massgeblich ist die Fassung
4.11.2 der versionierten Schemadateien nach ihrer Quellendatei, nicht die
Sperrdatei des Backends; die Zeile W1-82 der Tabelle oben ist damit überholt
(R3-F-003, "Achtung" (6)). Zu W1-89 und W1-91 ist das zweite Kriterium von
R3-F-005 nach FA-S14-07 fortgeschrieben (vier Formen als Zählwerte). Offen
bleibt E-S14-01 (Vorlage an den Auftraggeber). Die Abweisungsfälle aus
FA-S14-01, -02, -03, -09 und -10 sind auf Entscheid des Koordinators vom
2026-11-09 in die Präzisierung (b) der Abnahmezeile von R3-F-003 aufgenommen;
den Prüfaufwand bewertet der Product Owner.

## Nachtrag vom 2026-11-09 (Einheit S1.5)

Verfasser-Rolle: Requirements Engineer. Anlass: Auftrag des Koordinators vom
2026-11-09, die Befunde zu R3-F-011 vor der Festlegung S1.5 zu bearbeiten, wie
W1-97 vor S1.3 und W1-74 bis W1-96 vor S1.4 (Stand des Repositories nach der
Angabe des Koordinators, Fremdbeleg). Die Befunde W1-01 bis W1-97, ihre
Schwere, die Übersicht und die Zeile "Summe" bleiben unverändert; dieser
Nachtrag fügt keinen Befund hinzu. Der Hinweis W1-47 und der Querschnitt W1-72,
soweit er R3-F-011 betrifft, sind mitbearbeitet; W1-48 ist nicht Gegenstand.

**Vermerk zu W1-42 bis W1-47 und W1-72 (R3-F-011): bearbeitet.** Die Befunde
bleiben in der Liste stehen; die Nachbesserung ist als Fortschreibung des
Eintrags R3-F-011 in `docs/05_Product_Backlog.md` vorgenommen (Präzisierung in
der Zeile "Abnahme", zweite Zeile "Achtung", Zeile "Stand 2026-11-09"),
gestützt auf ADR 0007, Entscheide 17 und 26 (fortgeschrieben mit der Festlegung
S1.4, angenommen mit dem Merge des Pull Requests #56) und die mit dem Merge #52
entschiedenen E-S1-06 b und E-S1-07 a. Was ADR 0007 nicht beantwortet, steht
als Annahme in der zweiten Zeile "Achtung" des Eintrags und als Frage unten.

| Befund | Stand | Fundort | Offen |
|---|---|---|---|
| W1-42 | erledigt durch Fortschreibung, Teil "Protokolle ausserhalb von Tabellen" als Wiedervorlage benannt | R3-F-011, Präzisierung der Zeile "Abnahme" (ermittlungsspur, arbeitsspur, kettenkopf; Spalten aus dem Katalog); zweite Zeile "Achtung" (1): Ausgaben von Anwendung, Datenbank, Containern und Tests, Grabstein und Aufgaben nicht Gegenstand in Sprint 1 | Wiedervorlage bei R3-F-020 und R3-F-019; ob ein eigener Eintrag nötig ist, entscheidet der Product Owner |
| W1-43 | erledigt durch Fortschreibung; Spaltentypen und Textform an die Festlegung S1.5 verwiesen | R3-F-011, Präzisierung: Klartextwerte (Aktenzeichen, Rechtsgrundlage, ermittelnde Person, Eigenschaftswerte, Abfragetexte, FollowTheMoney-Kennungen), zulässiger Klartext nach Entscheid 17, Form der Suche (roh, normalisiert, JSON-Maskierung; Teilzeichenkette; ohne Gross- und Kleinschreibung) | FA-S15-01 (ermittelnde Person), FA-S15-03 (Spaltentypen, Textform) |
| W1-44 | erledigt durch Fortschreibung | R3-F-011, Präzisierung, Satz "Testfall": Knoten des Schemas Person mit Name, Adresse und Telefonnummer, zweiter Knoten, Kante, je mit Herkunftssatz, über kanon.service.schreiben | — |
| W1-45 | erledigt durch Fortschreibung; Umkehrbarkeit für Leser der Datenbank offen (Begründung: Fallschlüssel unverschlüsselt bis O-6) | R3-F-011, Präzisierung, Sätze "Die zugehörigen Prüfsummen", "Schlüssel je Fall" und "Ohne Schlüssel"; zweite Zeile "Achtung" (2) | O-6 (vor R3-F-020), ADR 0007, GS-5; FA-S15-04 (Nachrechnung unabhängig vom Produkt) |
| W1-46 | erledigt durch Fortschreibung; Weg der Manipulation an die Festlegung S1.5 verwiesen | R3-F-011, Präzisierung, Satz "Gegenprobe" (a) am Bestand fall, entitaet, beziehung, herkunft und (b) an eingebrachtem Klartext in beiden Spuren | FA-S15-02 |
| W1-47 | erledigt durch Fortschreibung | R3-F-011, Präzisierung, Satz "Unkenntlich gemacht": in Sprint 1 allein Pseudonym nach E-S1-06 | — |
| W1-72 (soweit R3-F-011) | erledigt durch Fortschreibung für R3-F-011; Glossareintrag offen (Begründung: in dieser Teileinheit keine Änderung am Glossar) | R3-F-011, Präzisierung, erster Satz: Protokoll und Protokolltabellen heissen ermittlungsspur, arbeitsspur und kettenkopf | Vorschlag für das Glossar im Bericht an den Koordinator; R3-F-001, R3-F-008, R3-F-009 und R3-F-012 unberührt |

**Fragen an den Software Architect (Festlegung S1.5).** FA-S15-01 Ob die
ermittelnde Person zu den Klartextwerten nach Entscheid 26 gehört (die Nutzlast
führt sie als Pseudonym, die Aufzählung in Entscheid 26 nennt sie nicht);
FA-S15-02 Weg der Manipulation der Teststufe, mit dem Gegenprobe (b) Klartext
in eine Spalte der anfügbaren Spurtabellen einbringt, und ob danach der
Zustand der Wegwerfinstanz zurückgesetzt wird; FA-S15-03 welche Datentypen des
Katalogs als Text- oder JSON-Spalte gelten (darunter Zeichenketten fester
Länge, json, jsonb, Felder und Spalten binärer Prüfsummen) und welche Textform
einer JSON-Spalte durchsucht wird; FA-S15-04 ob der Test das Pseudonym
unabhängig vom Code des Produkts nachrechnet (Schlüssel aus fall_schluessel
über die Teststufe, HMAC aus der Standardbibliothek) und welches Feld der
Spureinträge entitaet und beziehung als Prüfsumme des Abfragetexts gilt
(abfrage_pseudonym oder abfrage_bindung).

Die Ready-Bestätigung, die Bewertung des Prüfaufwands und die Zeile in der
Tabelle Nachführungen des Backlogs schreibt der Product Owner.

**Ergänzung nach der Festlegung S1.5 (2026-11-09).** Die Fragen FA-S15-01 bis
FA-S15-04 sind in der Festlegung S1.5 des Software Architects beantwortet
(ADR 0007, Festlegung S1.5, Zeile "Antworten auf die Fragen des Requirements
Engineers"): FA-S15-01 ja, die ermittelnde Person gehört zu den
Klartextwerten, Entscheid 26 ist fortgeschrieben; FA-S15-02 über die
Manipulation der Teststufe als letzter Schritt des Tests (Zeile "Gegenprobe
(b)"); FA-S15-03 Zeichenketten sowie json und jsonb, geschlossene Typliste,
kettenkopf mit zwei durchsuchten Spalten; FA-S15-04 ja, zweiter Rechenweg,
Prüfsumme des Abfragetexts ist abfrage_pseudonym. Die Fragen Q-RE-2 bis Q-RE-8
des Software Architects zur Fortschreibung des Eintrags sind erledigt durch
Nachziehen der noch nicht committeten Präzisierung von R3-F-011 in
`docs/05_Product_Backlog.md` (Zeile "Abnahme", zweite Zeile "Achtung", Zeile
"Stand 2026-11-09" mit "Nachgezogen an die Festlegung S1.5"): Q-RE-2
abgewiesener Schreibversuch im Testfall; Q-RE-3 mehr als 0 durchsuchte Spalten
auch für kettenkopf; Q-RE-4 geschlossene Typliste; Q-RE-5 JSON-maskierte
Zeichen in den Testwerten erlaubt und gewollt; Q-RE-6 Trennschärfe je
Suchbegriff statt Mindestlänge je Wert; Q-RE-7 Suchfläche jede Tabelle des
Schemas ausser der Positivliste der Klartexttabellen, die drei
Protokolltabellen als Mindestmass; Q-RE-8 Suchformen NFD und JSON mit und ohne
ASCII-Maskierung, Teilwerte, positive Formprüfung, Auffangen der
Prozessausgaben. Q-RE-1 ist in Q-RE-8 aufgegangen. Die Spalte "Offen" der
Tabelle oben ist für FA-S15-01 bis FA-S15-04 damit erledigt; für W1-42 und
W1-45 bleiben die Wiedervorlagen und O-6 offen. Die erneute Ready-Prüfung
schreibt der Product Owner.

## Nachtrag vom 2026-11-10 (Einheit D27)

Verfasser-Rolle: Requirements Engineer. Anlass: Merge des Pull Requests #57
am 2026-11-10 (Merge-Commit `c2b187b8b2b2706b4a85ac404a1a23148cdcd884`; erster
Formweg, ohne Kommentar; Angabe des Koordinators, Fremdbeleg), mit dem S1.5
abgenommen und E-D26-01 nach (a) entschieden ist. Die Befunde W1-01 bis W1-97,
ihre Schwere, die Übersicht und die Zeile "Summe" bleiben unverändert; dieser
Nachtrag fügt keinen Befund hinzu und schlägt keine Lösung vor.

**Vermerk zu W1-72: Glossarvorschläge eingetragen.** Der im Nachtrag vom
2026-11-09 (Einheit S1.5) als offen geführte Glossareintrag ist in
`docs/03_Glossar.md` als Vorschlag eingetragen, gekennzeichnet und nicht
bestätigt: Protokoll (Sammelbegriff für ermittlungsspur, arbeitsspur und
kettenkopf; Protokolltabellen als Synonym; "die Protokolltabelle" in der
Einzahl nicht verwenden) und Pseudonym neu, bei Klardaten und Protokolleintrag
je ein Vorschlag zur Ergänzung. Die Bestätigung geht dem Auftraggeber als
Vorlage E-D27-01 im Pull Request der Einheiten D27 und S2 zu. Der Befund W1-72
bleibt in der Liste stehen; die Einträge R3-F-001, R3-F-008, R3-F-009 und
R3-F-012 sind unverändert.
