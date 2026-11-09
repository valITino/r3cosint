# Gegenprüfung der Konformitätsanalyse (Legal Reviewer)

| | |
|---|---|
| **Gegenstand** | `docs/konformitaet/konformitaetsanalyse.md`, Stand 2026-11-09, erste Fassung, Funktion F-01 "Fall eröffnen und schliessen" (Einheit S1.3, R3-F-001) |
| **Prüfende Rolle** | Legal Reviewer (Projektauftrag 4.2, 4.4); Erstellung der Analyse liegt bei der GRC-Rolle |
| **Datum** | 2026-11-09 |
| **Arbeitsgrundlage** | Projektauftrag 4.4 (Prioritätsordnung R1 bis R5, Aufbewahrung, Zustandsmodell, Startwerte Punkt 3, Punkt 3b), `.claude/rules/recht-und-datenschutz.md` (Belegpflicht), Validierungsgrundsätze 6.7 (Fehlerfindung getrennt von Fehlerkorrektur) |
| **Grundsatz** | Dieser Bericht ist eine Grundlage für eine Prüfung, nicht deren Ergebnis. Er erteilt keine behördliche Freigabe. Die Konformitätsanalyse wurde nicht verändert; Korrekturen setzt die GRC-Rolle als eigene Einträge um |

## 1 Vorgehen und Belegstand der Prüfung

- **Projektauftrag und Repository:** Abschnitte 4.4, 5.3, 6.2, 6.4 im Arbeitsbaum gelesen. Die "gebaut"-Angaben zu Prüfbedingungen und Startwerten wurden in `backend/migrationen/sql/0002_fall.sql` und `0002_fall_startwerte.sql` stichprobenhaft abgeglichen (Rechtsregime-Vorrat R1 und R2, Zustandsvorrat, sieben Kategorien mit Monatswerten). Die Berechtigungen (GRANT) und der Code sind nicht Gegenstand dieser juristischen Prüfung.
- **KDSG vom 03.12.2025:** Der Erlasstext (Veröffentlichung des Grossen Rats, Quelle Q-1 der Analyse) wurde als Seitenbilder gelesen: Titelseite mit Erlassliste, Art. 1 bis 22, Art. 63 und 64, Teil II Ziffern 1 bis 3, 11 bis 17, 21 bis 24 und 37 bis 40 (jeweils der Ausschnitt mit Art. 141 PolG und Art. 14 ArchG), Teil III, Teil IV, Hinweis zum fakultativen Referendum. Nicht gelesen wurden die übrigen Seiten (Art. 23 bis 62 und die übrigen Änderungserlasse).
- **StGB:** Fedlex lieferte ohne JavaScript keinen Text (Abruf am 2026-11-09). Art. 97 StGB wurde nur an der nicht amtlichen Wiedergabe (Q-3 der Analyse) gelesen; Art. 10, 101 und 109 StGB sind nicht verifiziert.
- **StPO, PolG/BE (ausser den Änderungen im KDSG-Erlasstext), Verordnungen, BELEX:** nicht gelesen. Der Inkraftsetzungsbeschluss des Regierungsrats wurde nicht gefunden.
- **Ergebnisse:** "gedeckt" heisst, dass die Aussage mit der genannten Fundstelle übereinstimmt, soweit diese Rolle sie gelesen hat. Bei Fundstellen, die nur über eine nicht amtliche Quelle oder nach Projektauftrag gelesen sind, steht das im Vermerk.

## 2 Prüfeinträge je Aussage

| Nr. | Aussage (Abschnitt der Analyse) | Angegebene Fundstelle | Prüfergebnis | Vermerk |
|---|---|---|---|---|
| 1 | R1: StPO (Bund), Daten im hängigen Strafverfahren, kantonales Datenschutzgesetz nicht anwendbar (Abschnitt 2) | PA 4.4, Rechtsregime | gedeckt | Wortlaut der Tabelle in 4.4. Zur Gegenstelle im Erlasstext siehe Befund B-02 |
| 2 | R2: PolG/BE, BSG 551.1, vom 10.02.2019; Datenbearbeitung ausserhalb eines hängigen Verfahrens (Abschnitt 2) | PA 4.4, Rechtsregime; Erlasstext Teil II Ziffer 24 | gedeckt | Erlasstext nennt "Polizeigesetz vom 10. Februar 2019 (PolG)", BSG 551.1 |
| 3 | Änderung von Art. 141 Abs. 1 PolG: "Die Datenbearbeitung richtet sich nach der Datenschutzgesetzgebung, soweit dieses Gesetz nicht etwas anderes bestimmt." (Abschnitt 2; P-05) | Erlasstext Q-1, Teil II, Ziffer 24 | gedeckt | Wörtlich zutreffend, aber verkürzt: Der folgende Satz "Das Bundesrecht und spezialgesetzliche Bestimmungen bleiben vorbehalten." fehlt. Befund B-01 |
| 4 | Die Änderung von Art. 141 PolG ist erst mit dem KDSG in Kraft (Abschnitt 2) | Erlasstext Q-1 | gedeckt | Teil IV: "Der Regierungsrat bestimmt den Zeitpunkt des Inkrafttretens." gilt für die ganze Vorlage einschliesslich der Änderungserlasse. Die Analyse nennt nur Art. 64; Teil IV ist die genauere Fundstelle (Befund B-05) |
| 5 | R3: KDSG BSG 152.04, Totalrevision, Erlasstext vom 03.12.2025 gelesen (Abschnitt 2) | PA 4.4; Erlasstext | gedeckt | Erlass "152.04 Kantonales Datenschutzgesetz (KDSG)" neu publiziert; Teil III hebt das Datenschutzgesetz vom 19.02.1986 auf |
| 6 | R4: Einführungsverordnung zur Richtlinie 2016/680, Schengen-relevante Bearbeitung; Fortbestand nicht verifiziert (Abschnitt 2; P-02) | PA 4.4 | gedeckt | "Nicht verifiziert" ist zulässig und richtig gekennzeichnet. Hinweis zu P-02 bei B-04 |
| 7 | R5: Archivierungsgesetz (BSG 108.1), Art. 14 Abs. 1 mit Verweis auf "Artikel 16 KDSG"; Teil II, Ziffer 2 (Abschnitt 2) | Erlasstext Q-1 | gedeckt | Ziffer 2 ändert den Erlass 108.1 Archivierungsgesetz; Art. 14 Abs. 1: "Im Sinne von Artikel 16 KDSG nicht mehr benötigte Personendaten ..." |
| 8 | revDSG des Bundes nicht heranziehen; Kürzel 1a, 1b, 2 sind den Klassifizierungsstufen vorbehalten (Abschnitt 2) | PA 4.4, Rechtsregime und "Zur Bezeichnung" | gedeckt | Hinweis: Erlasstext Art. 3 Abs. 3 verweist für Behörden im Wettbewerb auf das Bundesgesetz über den Datenschutz; für F-01 ohne Bedeutung |
| 9 | 3.1 a: Fall trägt sein Regime bei der Eröffnung; Zitat "muss ein Fall bei der Eröffnung sein Regime tragen" (Abschnitt 3.1) | PA 4.4, Absatz "Warum die Aufteilung an der Spitze wichtig ist" | gedeckt | Zitat wörtlich |
| 10 | 3.1 a: gebaut sind `rechtsregime text NOT NULL` mit Prüfbedingung `fall_rechtsregime_vorrat` (R1, R2) (Abschnitt 3.1) | `backend/migrationen/sql/0002_fall.sql` | gedeckt | Stichprobe an der Datei. GRANT-Angabe nicht geprüft (nicht juristisch) |
| 11 | 3.1 b: Zulässigkeit entscheidet die Rechtsgrundlage im Einzelfall (Abschnitt 3.1) | PA 4.4, "Ersetzte Formulierung" und Einleitung | gedeckt | |
| 12 | 3.1 b: KDSG vom 03.12.2025, Art. 4 Abs. 1 (Rechtsgrundlage) (Abschnitt 3.1) | Erlasstext Q-1 | gedeckt | Art. 4 Abs. 1: Bearbeitung, soweit gesetzlich vorgesehen (Bst. a) oder zur Erfüllung einer gesetzlichen Aufgabe (Bst. b) |
| 13 | 3.1 b: Art. 6 Abs. 1 "Der Zweck der Bearbeitung muss bestimmt sein" (Abschnitt 3.1) | Erlasstext Q-1 | gedeckt | Zitat wörtlich |
| 14 | 3.1 c: Fristen ab Fallabschluss, Startwerte als Vorschlag, genau ein Feld Fallkategorie, Frist als Konfiguration, Frist löst nie Löschung aus (Abschnitt 3.1) | PA 4.4, Punkte 1, 2, 3, 3b, 4 | gedeckt | |
| 15 | 3.1 c: Art. 16 Abs. 2 KDSG "Sie legt für jede Datensammlung fest, ob und wie lange die Personendaten aufzubewahren sind" (Abschnitt 3.1, 5, 6) | Erlasstext Q-1 | gedeckt | Wörtlich. Der anschliessende Satz "Vorbehalten bleiben besondere Aufbewahrungsbestimmungen." fehlt in der Analyse (Befund B-01) |
| 16 | 3.1 c: Art. 16 Abs. 3 Bst. a (Aufbewahrung darüber hinaus zu Sicherungs- und Beweiszwecken) (Abschnitt 3.1, 3.2) | Erlasstext Q-1 | gedeckt | Wortlaut: "weiterhin zu Sicherungs- und Beweiszwecken benötigt werden". Die Brücke zur Verfolgbarkeit ist Auslegung nach PA 4.4, Punkt 3, nicht Gesetzestext; die Analyse führt sie als Vorschlag |
| 17 | 3.1 d: Protokollpflicht, "Das Protokoll darf keine zweite Kopie der Falldaten werden"; Problem A (Abschnitt 3.1) | PA 5.3; PA 4.4, Punkte 4 und 5 | gedeckt | Zitat in 5.3 vorhanden; Punkt 4 (Protokollpflicht) und Problem A in 4.4 |
| 18 | 3.1 e: Zustandsmodell mit acht Zeilen (Aktiv bis Löschsperre); in Sprint 1 erreichbar Aktiv und Abgeschlossen (Abschnitt 3.1) | PA 4.4, Punkt 2 | gedeckt | Die Tabelle in 4.4 führt acht Zeilen; die Analyse führt den Vorrat im Schema als sieben Zustände und die Löschsperre getrennt (W1-30), das ist eine Umsetzungsfrage, kein Widerspruch zu 4.4 |
| 19 | W1-02: R3 ist subsidiär; im Fall R1 ist das kantonale Datenschutzgesetz "ausdrücklich nicht anwendbar" (Abschnitt 3.2) | PA 4.4, Tabelle | gedeckt | Gedeckt als Wiedergabe von PA 4.4. Der Erlasstext sagt weniger: siehe Befund B-02 |
| 20 | W1-02: R4 ist eine Eigenschaft der Bearbeitung, R5 eine Phase nach dem Betriebszweck, kein Regime bei der Eröffnung (Abschnitt 3.2) | PA 4.4, Tabelle und Punkt 2 (Zustand Archiviert) | gedeckt | Die Spalte "Gilt für" in 4.4 trägt diese Lesart; sie ist Auslegung, nicht Wortlaut, und als Bestätigungsvorlage E-S13-G2 richtig geführt |
| 21 | W1-02: Der Absatz "Warum die Aufteilung an der Spitze wichtig ist" begründet das Feld allein mit StPO gegen PolG (Abschnitt 3.2) | PA 4.4 | gedeckt | |
| 22 | W1-11 Punkt 1: Bei einem Fall nach R2 mit bestimmtem Delikt im Raum gilt die Kategorie dieses Delikts (Abschnitt 3.2) | PA 4.4, Punkt 3; KDSG Art. 16 Abs. 3 Bst. a | gedeckt | Als Vorschlag gekennzeichnet, nicht als Festlegung; die Zuordnung setzt nach Punkt 6 die Kantonspolizei Bern |
| 23 | W1-11: Die Kantonspolizei Bern "setzt die Zuordnung der Fallkategorien" (Abschnitt 3.2) | PA 4.4, Punkt 6 | gedeckt | |
| 24 | W1-32: Zustände und Kriterien nach PA 4.4, Punkte 2 und 4, bei R3-F-020 (Abschnitt 3.2) | PA 4.4, Punkte 2 und 4 | gedeckt | Die Aussage zu den Abnahmekriterien des Backlog-Eintrags R3-F-020 ist nicht juristisch und nicht Gegenstand dieser Prüfung |
| 25 | W1-33: präskriptiver Teil wird "nicht neu priorisiert, sondern nur terminiert"; Randbedingungen aus dem präskriptiven Teil sind "gesetzt" (Abschnitt 3.2) | PA 6.2; PA 6.4, Absatz "Priorisierung" | gedeckt | Beide Stellen im Projektauftrag vorhanden |
| 26 | 4.1: Alle sieben gebauten Werte entsprechen PA 4.4, Punkt 3 (12, 36, 84, 120, 180, 360 Monate; unverjährbar 60 und 60) (Abschnitt 4.1) | PA 4.4, Punkt 3; `0002_fall_startwerte.sql` | gedeckt | Beide Seiten abgeglichen; 12, 36, 84, 120, 180, 360 und 60/60 stimmen |
| 27 | 4.1: Eine leere Folgeprüfung bei sechs Kategorien ist mit PA 4.4 vereinbar, weil eine neue Prüffrist erst durch einen Entscheid "Verlängert" entsteht (Abschnitt 4.1) | PA 4.4, Punkt 2 | gedeckt | |
| 28 | H-A: Nach Art. 97 Abs. 1 StGB gelten 30 Jahre bei lebenslänglicher Freiheitsstrafe, 15 Jahre bei Freiheitsstrafe über drei Jahre, 10 Jahre bei Freiheitsstrafe von drei Jahren, 7 Jahre bei einer anderen Strafe (Abschnitt 4.1) | Q-3 (nicht amtlich) | gedeckt | An Q-3 gelesen, Fassung seit 1. Januar 2014. Amtliche Fassung nicht verifiziert, in der Analyse so gekennzeichnet |
| 29 | H-A: Vorschlag für die Bezeichnung im Bearbeitungsreglement, "Taten, die nur mit einer anderen Strafe als Freiheitsstrafe bedroht sind" (Abschnitt 4.1) | Art. 97 Abs. 1 StGB (Q-3) | nicht gedeckt | Nach dem Wortlaut gilt "eine andere Strafe" als Auffang für jede Höchststrafe unterhalb der "Freiheitsstrafe von drei Jahren", also auch für Taten mit einer Freiheitsstrafe von weniger als drei Jahren. Der Vorschlag ist zu eng. Befund B-03 |
| 30 | H-A: Ob die Begriffsbestimmung des Vergehens in Art. 10 StGB das bestätigt, ist nicht verifiziert (Abschnitt 4.1) | Art. 10 StGB | Fundstelle nicht verifizierbar | Als nicht verifiziert gekennzeichnet; zulässig. Auch durch diese Rolle nicht abrufbar |
| 31 | H-B: Nach Art. 97 Abs. 2 StGB dauert die Verjährung bei bestimmten Delikten gegen Kinder mindestens bis zum vollendeten 25. Lebensjahr des Opfers (Abschnitt 4.1) | Q-3 (nicht amtlich) | gedeckt | An Q-3 gelesen (Art. 187, 188 und weitere Delikte gegen Kinder unter 16 Jahren) |
| 32 | H-B: Art. 101 und Art. 109 StGB sind nach PA 4.4 zitiert und nicht selbst verifiziert (Abschnitt 4.1) | Art. 101, 109 StGB | Fundstelle nicht verifizierbar | Zulässig, weil als nach PA 4.4 und nicht verifiziert gekennzeichnet. Auch durch diese Rolle nicht abrufbar |
| 33 | H-C: Nach PA 4.4, Punkt 3b, dritter Grund, ändert sich die Frist mit der rechtlichen Würdigung, protokolliert (Abschnitt 4.1) | PA 4.4, Punkt 3b | gedeckt | |
| 34 | E-S13-G1: Bestätigung der Werte liegt bei der Kantonspolizei Bern und blockiert die Umsetzung nicht; Werte sind betriebliche Voreinstellung (Abschnitt 4.2) | PA 4.4, Punkt 3 ("Wichtige Einordnung") und Punkt 6 | gedeckt | Wörtlich in 4.4: "betriebliche Voreinstellungen, keine rechtliche Festlegung"; Punkt 6 "blockiert die Umsetzung nicht" |
| 35 | E-S13-G2: E-S1-09 (a) ist eine Umsetzungsentscheidung und ändert PA 4.4 nicht (`docs/sprints/sprint-01.md`, H-9) (Abschnitt 4.2) | Sprintdokument, H-9 | Fundstelle nicht verifizierbar | Verfahrensdokument, nicht Gegenstand der juristischen Prüfung; die Rechtsaussage ("PA 4.4 sagt zum Vorrat nichts Abweichendes") ist an 4.4 gedeckt |
| 36 | P-01: Art. 63 hebt das Datenschutzgesetz vom 19.02.1986 auf; Art. 64 Abs. 1 "Der Regierungsrat bestimmt den Zeitpunkt des Inkrafttretens." (Abschnitt 6) | Erlasstext Q-1 | gedeckt | Wörtlich zutreffend |
| 37 | P-01: Eine nicht amtliche Sekundärquelle nennt September 2026; Datum nicht verifiziert (Abschnitt 6, 8) | Q-2 | gedeckt | Q-2 sagt: "Im Kanton Bern tritt im September 2026 das revidierte kantonale Datenschutzgesetz in Kraft."; einen Tag nennt der Text nicht. Die Analyse behauptet kein Datum. Ein Beschluss des Regierungsrats wurde auch von dieser Rolle nicht gefunden |
| 38 | P-01: gelesene Artikel Art. 3 Abs. 4, 4, 6, 9, 16, 18 bis 20, 22, 63, 64 (Abschnitt 6) | Erlasstext Q-1 | gedeckt | Alle genannten Artikel am Erlasstext vorhanden und gelesen |
| 39 | P-02: Ein Suchergebnis deutete eine befristete Geltung bis 31. August 2026 an (Abschnitt 6) | keine (Quelle "nicht gelesen") | Fundstelle nicht verifizierbar | Angabe ohne Fundstelle; von der Analyse nicht als Beleg geführt. Befund B-04 |
| 40 | P-05: Der Bundesgerichtsentscheid vom August 2026 zum PolG berührt die Frage (Abschnitt 6) | PA 4.4, Punkt 7 | Fundstelle nicht verifizierbar | Der Entscheid selbst ist nicht abgerufen; die Wiedergabe in PA 4.4, Punkt 7, ist gedeckt. Auch durch diese Rolle nicht verifiziert |
| 41 | P-06: Art. 18 bis 20 (Risikoanalyse, Datenschutzfolgenabschätzung, Vorabkontrolle) und Art. 22 (Verzeichnispflicht für Strafverfolgungsbehörden und Strafgerichte) (Abschnitt 6) | Erlasstext Q-1 | gedeckt | Inhalt der Artikel richtig umschrieben; ob F-01 sie auslöst, wird von der Analyse offen gelassen |
| 42 | P-07: Art. 3 Abs. 4 verweist für die Bearbeitung in Verfahren vor Gerichtsbehörden, der Staatsanwaltschaft und verwaltungsinternen Verwaltungsjustizbehörden auf das anwendbare Verfahrensrecht (Abschnitt 6) | Erlasstext Q-1 | gedeckt | Wortlaut: "Das anwendbare Verfahrensrecht regelt die Bearbeitung von Personendaten und die Rechte der betroffenen Personen in Verfahren vor a Gerichtsbehörden, b der Staatsanwaltschaft, c verwaltungsinternen Verwaltungsjustizbehörden." Die Polizei ist nicht genannt; die Analyse hält die Frage zu Recht offen |
| 43 | Q-1 ist der Erlasstext, wie vom Grossen Rat beschlossen, nicht die konsolidierte Fassung (Abschnitt 8) | Q-1 | gedeckt | Unterzeichnet "Bern, 3. Dezember 2025", mit Hinweis auf das fakultative Referendum |
| 44 | Bezugsstand ist der Merge-Commit `5f3c1693304256a0ce31f152543adcae72f24442` (Pull Request #54, Abnahme von S1.2) (Abschnitt 1) | CLAUDE.md; ADR 0007, Status | gedeckt | Commit-Prüfsumme und Zuordnung stehen in der Statuszeile von CLAUDE.md |
| 45 | Fedlex und BELEX waren nicht lesbar; daraus Stammendes steht als "nicht verifiziert" (Abschnitt 8) | eigene Abrufe | gedeckt | Der Fedlex-Abruf dieser Rolle lieferte ebenfalls nur den Hinweis auf einen JavaScript-fähigen Browser |
| 46 | Kopf: Die Analyse erteilt keine behördliche Freigabe und stellt nicht fest, dass die Anwendung für einen Polizeieinsatz gültig sei (Kopf) | PA 4.4, "Ersetzte Formulierung" | gedeckt | |

**Zahl der geprüften Aussagen: 46.** Gedeckt 40, nicht gedeckt 1 (Nr. 29), Fundstelle nicht verifizierbar 5 (Nr. 30, 32, 35, 39, 40).

## 3 Zuordnung der Funktion F-01 zur Prioritätsordnung

- **Rechtsregime als Feld mit R1 und R2:** Trägt. PA 4.4 begründet das Feld allein mit der Unterscheidung StPO (R1) gegen PolG (R2) ("Da beide Fälle im selben System vorkommen, muss ein Fall bei der Eröffnung sein Regime tragen"). Die Prüfbedingung im gebauten Schema führt genau R1 und R2.
- **Abweisung von R3, R4 und R5 als Regime des Falls:** Trägt als Auslegung der Spalte "Gilt für" in PA 4.4 (R3 subsidiärer Rahmen, R4 Eigenschaft der Bearbeitung, R5 Phase nach dem Betriebszweck). PA 4.4 sagt das nicht in einem Satz; die Analyse legt es als Bestätigungsvorlage E-S13-G2 vor und ändert PA 4.4 nicht. Das ist die richtige Form. Ergänzende Hinweise: Nach der Änderung von Art. 141 Abs. 1 PolG richtet sich die Datenbearbeitung der Polizei nach der Datenschutzgesetzgebung, soweit das PolG nichts anderes bestimmt. Für R2 gilt das KDSG damit über einen Verweis des PolG und nicht bloss als Rahmen neben dem PolG. Das ändert die Abweisung von R3 als Regime des Falls nicht, ist aber in der Formulierung "subsidiär" mitzulesen (Befund B-02).
- **R4 offen:** Die Analyse führt die Kennzeichnung der Schengen-relevanten Bearbeitung zu Recht als offen (K-4). Der Erlasstext enthält dazu eine lesbare Fundstelle (Art. 145 Abs. 3 PolG, geändert: Informationsaustausch mit Polizei- und Strafverfolgungsbehörden der Schengen-Staaten richtet sich nach dem Schengen-Informationsaustauschgesetz vom 21. März 2025 und Art. 355c StGB). Das ist ein Hinweis für P-02, keine Beurteilung.
- **Prüfmassstab "ein Fall trägt sein Regime ab Eröffnung":** In F-01 umgesetzt (3.1 a, 3.1 e).

## 4 Herleitung der Startwerte aus Art. 97 StGB

- Die Analyse behandelt die Werte durchgängig als "betriebliche Voreinstellung, keine rechtliche Festlegung" (E-S13-G1, K-2, Abschnitt 4.1). Das deckt PA 4.4, Punkt 3, "Wichtige Einordnung". Die Herleitung trägt in dieser Form.
- Die sieben Werte stimmen mit PA 4.4, Punkt 3, überein (Nr. 26).
- Zwei Genauigkeitsbefunde: Der Vorschlag in H-A ist zu eng (Befund B-03). Art. 97 Abs. 3 StGB (nach einem erstinstanzlichen Urteil tritt die Verjährung nicht mehr ein) begrenzt den Anker "so lange eine Verfolgung möglich ist"; das erwähnt die Analyse nicht (Restpunkt R-07).

## 5 Vermerk je Punkt "keine tragfähige Grundlage" (K-1 bis K-5)

| Punkt | Trägt die Feststellung? | Begründung |
|---|---|---|
| K-1 Fallkategorie bei R2 ohne Deliktsbezug | trägt | PA 4.4, Punkt 3, verankert alle Kategorien an der Verfolgungsverjährung; für Gefahrenabwehr und Prävention nennt 4.4 keinen Anker, und Art. 16 Abs. 3 Bst. a KDSG trägt nur den Beweiszweck. Die Einordnung von `nichtanhandnahme_einstellung` als nur dem Anker, nicht dem Namen nach passend ist zutreffend. Einschränkung: Eigene Aufbewahrungsbestimmungen des PolG sind nicht gelesen (P-05) |
| K-2 Höhe der Startwerte als Aufbewahrungsdauer | trägt, mit Einschränkung | PA 4.4 sagt selbst, die Verjährung regle die Verfolgbarkeit und nicht die Datenaufbewahrung; Art. 16 Abs. 2 KDSG delegiert die Festlegung an die Behörde. Die Einschränkung betrifft den Vorbehalt in Art. 16 Abs. 2 ("Vorbehalten bleiben besondere Aufbewahrungsbestimmungen"): Ob eine solche für R1 oder R2 besteht, ist weder in der Analyse noch hier geprüft. Die Feststellung gilt für die gelesenen Texte (KDSG, PA 4.4) |
| K-3 Übergang von R2 nach R1 | trägt | In PA 4.4 und im gelesenen Erlasstext fehlt jede Regelung des Übergangs. Art. 141 Abs. 1 PolG behält Bundesrecht vor, Art. 3 Abs. 4 KDSG verweist auf Verfahrensrecht; beides beantwortet die Frage nicht. Eigene Prüfung der StPO ist durch diese Rolle in diesem Lauf nicht erfolgt (Restpunkt R-03); die Feststellung ist deshalb "keine Grundlage in den herangezogenen Quellen", nicht "keine Grundlage im Recht" |
| K-4 Kennzeichnung der Schengen-relevanten Bearbeitung (R4) | trägt | PA 4.4 nennt R4 als Rang, bestimmt aber das Merkmal nicht. Der Fortbestand der Einführungsverordnung ist offen. Hinweis auf Art. 145 Abs. 3 PolG (Bestimmung zum Schengen-Informationsaustausch) in B-04 |
| K-5 Inhalt der Angabe "Rechtsgrundlage" und Abgrenzung zum Rechtsregime | trägt | PA 4.4 nennt die Rechtsgrundlage im Einzelfall, ohne das Feld zu bestimmen; Art. 4 Abs. 1 KDSG umschreibt die gesetzliche Grundlage der Bearbeitung, nicht das Feld in R3cOSINT. Die Lesart der Analyse ist ausdrücklich als Vorschlag gekennzeichnet und nicht als Beleg geführt |

## 6 Befunde, die vor der Vorlage an die zuständige Stelle zu bereinigen sind

Die GRC-Rolle setzt sie um; diese Rolle ändert die Analyse nicht.

| Nr. | Befund | Begründung | Betroffen |
|---|---|---|---|
| B-01 | Zitate unvollständig: Art. 141 Abs. 1 PolG, Satz 2 ("Das Bundesrecht und spezialgesetzliche Bestimmungen bleiben vorbehalten.") und Art. 16 Abs. 2 KDSG, Satz 2 ("Vorbehalten bleiben besondere Aufbewahrungsbestimmungen.") ergänzen und an P-05 binden | Beide Vorbehalte betreffen genau die Frage, welche Regel für R1 und R2 gilt und ob eine besondere Aufbewahrungsbestimmung besteht. Ein verkürztes Zitat lässt die Lücke kleiner erscheinen, als sie ist | Nr. 3, 15; Abschnitt 2, 3.1 c, P-05, K-2 |
| B-02 | Aussage "im Fall R1 ist das kantonale Datenschutzgesetz ausdrücklich nicht anwendbar" als Wiedergabe von PA 4.4 kennzeichnen und mit P-07 verbinden | Art. 3 Abs. 4 KDSG sagt, das anwendbare Verfahrensrecht regle die Bearbeitung "in Verfahren vor" Gerichtsbehörden, Staatsanwaltschaft und verwaltungsinternen Verwaltungsjustizbehörden. Von "ausdrücklich nicht anwendbar" und von der Polizei steht dort nichts. Die Analyse stellt die Frage unter P-07 richtig; Abschnitt 3.2 (W1-02) führt die Aussage aber ohne diesen Verweis. Zusätzlich ist zu vermerken, dass Art. 141 Abs. 1 PolG für R2 auf die Datenschutzgesetzgebung verweist | Nr. 1, 19; Abschnitt 2, 3.2 |
| B-03 | Formulierungsvorschlag in H-A streichen oder berichtigen | Art. 97 Abs. 1 StGB unterscheidet "eine Freiheitsstrafe von drei Jahren" (10 Jahre) und "eine andere Strafe" (7 Jahre). Die Auffangformel erfasst nach dem Wortlaut auch Freiheitsstrafen unter drei Jahren, nicht nur Taten ohne Freiheitsstrafe. Der Vorschlag "nur mit einer anderen Strafe als Freiheitsstrafe bedroht" würde Taten mit einer Höchststrafe von etwa zwei Jahren Freiheitsstrafe von der Kategorie `vergehen` ausschliessen und der 10-Jahres-Kategorie zuweisen. Richtig und ausreichend wäre die Feststellung, dass die Bezeichnungen `vergehen` und `freiheitsstrafe_bis_3_jahre` vom Wortlaut ("von drei Jahren", "andere Strafe") abweichen, und die Bitte um Klärung im Bearbeitungsreglement (P-03). PA 4.4 selbst führt "Freiheitsstrafe bis drei Jahre" (10 Jahre); das ist eine Abweichung von der Quelle, die als Prüfpunkt, nicht als Änderung von 4.4 zu melden ist | Nr. 29; Abschnitt 4.1, P-03 |
| B-04 | P-02: Angabe zur befristeten Geltung bis 31. August 2026 streichen oder ausdrücklich als "ohne Fundstelle, nicht verwertet" führen; Fundstelle Art. 145 Abs. 3 PolG (Verweis auf das Schengen-Informationsaustauschgesetz vom 21. März 2025 und Art. 355c StGB) als lesbaren Anhaltspunkt für R4 aufnehmen | Belegpflicht (PA 4.4, "Verschärfung durch den geplanten Produktivbetrieb"): Eine Angabe ohne Fundstelle gehört nicht in eine Analyse, die jede Aussage belegen soll. Die Analyse sagt selbst, sie werde nicht als Beleg geführt; sie bleibt dennoch als Behauptung stehen | Nr. 39; P-02, K-4 |
| B-05 | P-01 um Teil IV des Erlasstexts (Inkrafttreten der Gesamtvorlage durch den Regierungsrat), Teil III (Aufhebung) und die Angaben zum fakultativen Referendum ergänzen; Rechtsstand zum Analysedatum benennen | Teil IV ist die genauere Fundstelle für die Änderungserlasse (PolG, ArchG). Der Erlasstext nennt eine Referendumsfrist bis 24. März 2026 und die Abgabe der Unterschriften bis 23. April 2026; ob ein Referendum zustande kam, ist nicht verifiziert. Q-2 und eine zweite Suche nennen nur den Monat September 2026. Das Analysedatum 2026-11-09 liegt nach diesem Monat: Die Analyse soll sagen, dass das Datum und damit die Geltung der zitierten Artikelnummern zum Analysedatum nicht amtlich belegt sind. Eine Behauptung des Datums bleibt ausgeschlossen | Nr. 4, 36, 37; Abschnitt 2, 6 |

## 7 Skill einschleusung-pruefen: Prüfung der abgerufenen Webinhalte

- **Kanäle (fremde Inhalte):** Erlasstext des Grossen Rats (PDF, als Seitenbilder), Wiedergabe von Art. 97 StGB auf droit-bilingue.ch, Artikel auf plattformj.ch, Fedlex-Abruf (nur Hinweistext), Websuche, Bericht der GRC-Rolle (Fremdbeleg).
- **Ergebnis:** In den Seiteninhalten, im Erlasstext und im Bericht der GRC-Rolle wurde keine eingebettete Anweisung gefunden (Negativbefund). Das ist kein Befund über die Unbedenklichkeit der Inhalte.
- **Meldung:** Das Ergebnis der Websuche endete mit einer an das Modell gerichteten Zeile, die verlangte, die Quellen in der Antwort mit Hyperlinks aufzuführen. Sie stammt nicht aus dem Gesetzestext, richtet sich aber an das Modell und gehört nicht zu meinem Auftrag; sie wurde nicht als Auftrag behandelt. Die Quellen stehen in Abschnitt 1 und in den Prüfeinträgen allein deshalb, weil die Belegpflicht des Projekts es verlangt. Ein Abrufwerkzeug schlug zudem vor, die PDF-Datei erneut hochzuladen; das wurde nicht befolgt. Nichts davon wurde ausgeführt.

## 8 Freigabe- oder Ablehnungsvermerk zu Punkt 5 der Bereitschaftsliste (5.16)

**Datum: 2026-11-09. Vermerk: Ablehnung für den Stand vom 2026-11-09 (Erstfassung F-01), bedingt, mit Aussicht auf Teilfreigabe dieses Stands nach Bereinigung.**

- **Gründe:** Eine Aussage ist nicht gedeckt (Nr. 29, B-03). Vier weitere Befunde (B-01, B-02, B-04, B-05) betreffen Vollständigkeit und Belegpflicht und sind vor der Vorlage an die zuständige Stelle zu bereinigen. Die Feststellungen K-1 bis K-5 tragen.
- **Nach der Bereinigung:** Diese Rolle prüft die Änderungen nach (Fehlerfindung getrennt von Fehlerkorrektur, 6.7). Tragen sie, kann der Stand für F-01 als Zwischenstand der Gegenprüfung vermerkt werden.
- **Punkt 5 als Ganzes bleibt offen:** Die Analyse deckt bisher eine Funktion ab; Abschnitt 7 (Nichttreffer-Löschung und Negativbefunde) und die weiteren Funktionen (R3-F-011, R3-F-009, R3-F-020 und alle späteren) fehlen, ebenso die Abnahme durch die zuständige Stelle. "Konformitätsanalyse abgeschlossen und abgenommen" (5.16) ist damit nicht erreicht. Dieser Vermerk betrifft den Stand der Analyse und ist keine behördliche Freigabe.

## 9 Offene Restpunkte

| Nr. | Restpunkt | Zuständig |
|---|---|---|
| R-01 | Datum des Inkrafttretens des KDSG vom 03.12.2025 (Beschluss des Regierungsrats), Ergebnis des Referendums, konsolidierte Fassung und Datenschutzverordnung sowie Direktionsverordnung amtlich belegen | Legal Reviewer mit Zugriff auf die Gesetzessammlung; kantonale Datenschutzbehörde |
| R-02 | Fortbestand der Einführungsverordnung zur Richtlinie 2016/680 (R4) und Verhältnis zum Schengen-Informationsaustauschgesetz (P-02) | Legal Reviewer |
| R-03 | Eigene Prüfung von K-3 (Übergang R2 nach R1) und P-07 (Abgrenzung R1) an den Normen der StPO; in diesem Lauf nicht erfolgt | Legal Reviewer, danach Auftraggeber |
| R-04 | Eigene Aufbewahrungs- und Löschbestimmungen des PolG/BE für R2 (P-05, Vorbehalt in Art. 16 Abs. 2 KDSG und Art. 141 Abs. 1 PolG) | Legal Reviewer |
| R-05 | Amtliche Fassung von Art. 97 StGB; Art. 10, 101 und 109 StGB; Bundesgerichtsentscheid vom August 2026 | Legal Reviewer mit Zugriff auf Fedlex |
| R-06 | Die in der Analyse nicht berührten [OFFEN]-Punkte aus 4.4 (DSGVO-Anwendbarkeit, EU AI Act) und die Abgrenzung Art. 285a ff. StPO gegen Art. 298a ff. StPO für die Alias-Profile (5.11): für F-01 ohne Bezug, bei der jeweils berührten Funktion zu prüfen | GRC-Rolle, Legal Reviewer |
| R-07 | Art. 97 Abs. 3 StGB (keine Verjährung nach erstinstanzlichem Urteil) als Einschränkung des Ankers "so lange eine Verfolgung möglich ist" in der Herleitung der Startwerte vermerken | GRC-Rolle (nicht blockierend) |
| R-08 | Gegenprüfung je Fortschreibung der Analyse vermerken (Abschnitt 9 der Analyse) | Legal Reviewer, GRC-Rolle |

## 10 Quellen dieser Prüfung

- `docs/00_Projektauftrag.md`, 4.4, 5.3, 6.2, 6.4 (Arbeitsbaum, 2026-11-09).
- Kantonales Datenschutzgesetz (KDSG) vom 03.12.2025, Veröffentlichung des Grossen Rats des Kantons Bern, https://ogd.parl.apps.be.ch/pdf-upload/e0ae4b0d8cd94fe9aa60416c18cd8829-332.pdf (abgerufen 2026-11-09, Erlasstext, nicht konsolidiert).
- droit-bilingue.ch, StGB Art. 97, https://www.droit-bilingue.ch/de-en/3/31/311.0-97-128.html (abgerufen 2026-11-09, nicht amtlich).
- plattformj, "Neu ab 1. September", 31. August 2026, https://www.plattformj.ch/artikel/246281/ (abgerufen 2026-11-09, Sekundärquelle).
- Fedlex, SR 311.0 (abgerufen 2026-11-09, ohne Text, JavaScript erforderlich).

## 11 Nachprüfung vom 2026-11-09

Gegenstand: `docs/konformitaet/konformitaetsanalyse.md`, zweite Fassung vom 2026-11-09 (Bereinigung der Befunde B-01 bis B-05; Fortschreibungstabelle in Abschnitt 9 der Analyse). Dieser Abschnitt ist angefügt; die Abschnitte 1 bis 10 bleiben unverändert (Fehlerfindung getrennt von Fehlerkorrektur, 6.7). Die Analyse wurde nicht verändert, kein Commit.

### 11.1 Berichtigung der Artikelnummer in dieser Gegenprüfung

Die GRC-Rolle hat recht, ich habe mich geirrt. Am Erlasstext (Teil II, Ziffer 24, PolG) steht unter "Art. 144 Abs. 1 (unverändert) [FR: (geändert)], Abs. 3 (geändert)" auf der folgenden Seite der Absatz 3 zum direkten Informationsaustausch mit Polizei- und Strafverfolgungsbehörden der Schengen-Staaten (Schengen-Informationsaustauschgesetz vom 21. März 2025, Art. 355c StGB). Danach beginnt erst "Art. 145 Abs. 1". Der Absatz gehört damit zu **Art. 144 Abs. 3 PolG**. Meine Angaben "Art. 145 Abs. 3 PolG" in Abschnitt 3 (Absatz "R4 offen"), Abschnitt 5 (K-4) und Befund B-04 sind insoweit zu lesen als "Art. 144 Abs. 3 PolG". Die Fassung der GRC-Rolle (Abschnitt 2, K-4, P-02) ist gedeckt, auch im Wortlaut des Zitats.

### 11.2 Ergebnis je Befund

| Befund | Ergebnis | Begründung |
|---|---|---|
| B-01 Vorbehalte in Art. 141 Abs. 1 PolG und Art. 16 Abs. 2 KDSG | bereinigt | Beide Sätze stehen wörtlich in Abschnitt 2 (Zeile R2), 3.1 c, K-2 und P-05 und stimmen mit dem Erlasstext überein; die Bindung an P-05 ist hergestellt |
| B-02 "ausdrücklich nicht anwendbar" als PA-Wortlaut kennzeichnen | bereinigt | Zeile R1 und Abschnitt 3.2 (W1-02) nennen den Satz als Wortlaut von PA 4.4, geben Art. 3 Abs. 4 KDSG richtig wieder, verweisen auf P-07 und benennen den Verweis in Art. 141 Abs. 1 PolG für R2 |
| B-03 Formulierungsvorschlag in H-A | bereinigt | Der Vorschlag ist gestrichen; H-A stellt die Abweichung der Bezeichnungen von "eine Freiheitsstrafe von drei Jahren" (10 Jahre) und "eine andere Strafe" (7 Jahre) richtig dar und meldet sie als Prüfpunkt P-03, ohne PA 4.4 zu ändern. Die Wiedergabe, dass "eine andere Strafe" auch Freiheitsstrafen unter drei Jahren erfasst, entspricht dem Wortlaut an Q-3 |
| B-04 Angabe ohne Fundstelle in P-02 | bereinigt | Die Angabe "bis 31. August 2026" ist gestrichen; P-02 sagt "keine Fundstelle zum Fortbestand gefunden". Anhaltspunkt Art. 144 Abs. 3 PolG aufgenommen, richtig (11.1) |
| B-05 P-01 ergänzen | bereinigt | Teil I, II, III und IV, Referendumsdaten (24. Dezember 2025, 24. März 2026, 23. April 2026), "Ob ein Referendum zustande kam: nicht verifiziert" und der Rechtsstand zum Analysedatum als nicht amtlich belegt stehen in P-01; alle Angaben stimmen mit dem Erlasstext überein. Ein Datum wird nicht behauptet |

### 11.3 Neue Aussagen und Fundstellen

- **H-D (Art. 97 Abs. 3 StGB):** ist als [Fremdbeleg] des Legal Reviewers gekennzeichnet und von der GRC-Rolle nicht verifiziert. Ich bestätige den Wortlaut an Q-3 (nicht amtlich): "Ist vor Ablauf der Verjährungsfrist ein erstinstanzliches Urteil ergangen, so tritt die Verjährung nicht mehr ein." Amtlicher Wortlaut weiterhin nicht verifiziert (P-11). Die Einordnung für die Startwerte (Hinweis zu P-03) trägt.
- **Fundstelle der Teile III und IV, Referendumsangaben, Q-4:** gedeckt am Erlasstext beziehungsweise in dieser Datei.
- **Aussagen ohne belegte Fundstelle, neu hinzugekommen:** keine. Eine Auslegung ohne Beleg steht in Abschnitt 3.2 (W1-02): "Auch über den Verweis bleibt R3 ein Rahmen neben R2, kein eigenes Regime." Das ist Auslegung des Verweises in Art. 141 Abs. 1 PolG und des Wortes "subsidiär" in PA 4.4, nicht Wortlaut; als Auslegung ist sie vertretbar, sie sollte beim nächsten Stand als solche gekennzeichnet werden (nicht blockierend). Die Aussage "Für R2 gilt das KDSG damit über einen Verweis des PolG" setzt voraus, dass "Datenschutzgesetzgebung" das KDSG meint; das ist naheliegend, aber an der Quelle nicht ausgesprochen (nicht blockierend).
- **Unberührt:** Die Befunde Nr. 30, 32, 35, 39 und 40 aus Abschnitt 2 bleiben (Nr. 39 ist durch die Streichung erledigt). Der Kopf der Analyse und die Fortschreibungstabelle führen die Nachprüfung noch als ausstehend; die GRC-Rolle trägt dieses Ergebnis dort ein (Restpunkt R-08).

### 11.4 Vermerk zu Punkt 5 der Bereitschaftsliste (5.16)

**Datum: 2026-11-09. Teilfreigabe des Stands "zweite Fassung, Funktion F-01" als Zwischenstand der Gegenprüfung: ja.** Voraussetzungen sind erfüllt: B-01 bis B-05 bereinigt, kein neuer Befund, K-1 bis K-5 tragen weiterhin (K-3 mit dem Vermerk der GRC-Rolle "keine Grundlage in den herangezogenen Quellen"; K-2 und K-4 jetzt mit den Vorbehalten und dem Anhaltspunkt in Art. 144 Abs. 3 PolG). Diese Teilfreigabe betrifft den Stand der Analyse für F-01 und ist keine behördliche Freigabe.

**Punkt 5 als Ganzes bleibt offen.** Restpunkte:

| Nr. | Restpunkt | Stand in der Analyse |
|---|---|---|
| R-01 | Inkrafttreten, Referendum, konsolidierte Fassung, Verordnungen des KDSG | offen, P-01 |
| R-02 | Fortbestand der Einführungsverordnung zur Richtlinie 2016/680 | offen, P-02 |
| R-03 | StPO zu K-3 und P-07 | offen, P-10 |
| R-04 | Aufbewahrungsbestimmungen für R1 und R2 | offen, P-05 |
| R-05 | Amtliche Fassungen Art. 97, 10, 101, 109 StGB, Bundesgerichtsentscheid | offen, P-11 |
| R-06 | DSGVO, EU AI Act, Alias-Profile | offen, P-12 |
| R-07 | Art. 97 Abs. 3 StGB | übernommen als H-D und in P-03 |
| R-08 | Eintrag dieser Nachprüfung im Kopf und in der Fortschreibungstabelle der Analyse | durch die GRC-Rolle zu erledigen |
| neu | Abschnitt 7 (Nichttreffer-Löschung), weitere Funktionen, Abnahme durch die zuständige Stelle | fehlen |
| neu | Auslegungen in 11.3 als solche kennzeichnen | nicht blockierend |

## 12 Berichtigung (Nachtrag vom 2026-11-09)

Anlass: Textprüfung A der Einheit S1.3, Befund TA-S13-A-04. Befund B-01 (Abschnitt 6) nannte den Vorbehalt "Vorbehalten bleiben besondere Aufbewahrungsbestimmungen." in Art. 16 Abs. 2 KDSG "Satz 3".

Ergebnis der Zählung am Erlasstext (Quelle Q-1, Veröffentlichung des Grossen Rats, Seite 7, abgerufen 2026-11-09 unter https://ogd.parl.apps.be.ch/pdf-upload/e0ae4b0d8cd94fe9aa60416c18cd8829-332.pdf; als Seitenbild gelesen, fremder Inhalt, keine eingebettete Anweisung gefunden): Art. 16 Abs. 2 hat zwei Sätze. Satz 1: "Sie legt für jede Datensammlung fest, ob und wie lange die Personendaten aufzubewahren sind." Satz 2: "Vorbehalten bleiben besondere Aufbewahrungsbestimmungen." Der Vorbehalt ist Satz 2; die GRC-Rolle hat recht, P-05 der Analyse ("Satz 2") bleibt unverändert.

Berichtigt: Abschnitt 6, Befund B-01, "Satz 3" zu "Satz 2" (einzige Stelle mit "Satz 3"). Die Aussage Nr. 15 in Abschnitt 2 nennt keine Satzzahl und bleibt. Das Urteil der Nachprüfung (Abschnitt 11) bleibt unverändert.
