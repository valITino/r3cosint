# Sprint 1 der Etappe 1 — Sprint-Planungsartefakt, Vorlage zur Annahme durch den Auftraggeber

| | |
|---|---|
| **Arbeitsprodukt nach** | Projektauftrag 6.8 (Sprint Planning, Sprint Goal, Sprint Backlog), 3.3 (Umfang benennen, zerlegen, Zerlegung vorlegen), 6.7 (Walkthrough der Backlog-Einträge vor dem Sprint), 6.5 (Definition of Ready); `docs/06_Definition_of_Ready_und_Done.md`, Teil 1 und Teil 2; `docs/07_Roadmap.md` |
| **Entscheidet** | Auftraggeber (S-01), durch den Merge des Pull Requests der Einheiten D21 und S1 |
| **Vorbereitet** | 2026-11-05, Einheit S1: Scrum Master (dieses Artefakt, Zusammenführung), Product Owner (Sprint Backlog, Ready-Prüfung), Software Architect (Festlegung `docs/adr/0007-datenzugriff-und-protokollschema.md`, Zerlegung), Requirements Engineer (Walkthrough `docs/sprints/sprint-01-walkthrough.md`). Textprüfung: siehe Übergabe `docs/uebergaben/2026-11-05_d21-etappe-1-sprint-1.md` (zwei Static Software Tester auf getrennten Modellfeldern; die Prüfung läuft nach der Abfassung dieses Artefakts) |
| **Weisung** | 2026-11-05, zweiter Formweg, Wortlaut: "Habe #51 gemerged, mach weiter mit Etappe 1" (Angabe des Koordinators, Fremdbeleg; Lesart des Koordinators in der Übergabe) |
| **Status** | vorgelegt am 2026-11-05; Annahme durch den Merge des Pull Requests der Einheiten D21 und S1 ohne Kommentar; die Erklärung in Abschnitt 8 füllt Claude Code nicht aus |

## 1. Was diese Vorlage ist

Sprint 1 ist der erste Sprint der Etappe 1 (Fundament: Server, Protokoll, Datenbestand). Etappe 1 umfasst 29 geschätzte Einträge mit 147 Stunden Prüfaufwand und passt nicht in eine Session; nach 3.3 wird sie zerlegt und die Zerlegung vorgelegt. Diese Vorlage bündelt das Sprint Planning nach 6.8: Sprint-Ziel, Sprint Backlog mit Prüfaufwand gegen die Prüfkapazität von 28 bis 40 Stunden, Ergebnis der Ready-Prüfung und des Walkthroughs, Festlegung und Zerlegung in Baueinheiten, Ereignisplan, Hindernisliste und Entscheidungspunkte.

Drei Festlegungen zur Form, wie in `docs/12_Freigabe_Grundgeruest.md`:

1. **Schriftlich heisst committet.** Erteilt ist die Annahme mit dem Merge des Pull Requests der Einheiten D21 und S1, dessen Text sagt, dass der Merge die Annahme nach dieser Vorlage bedeutet (erster Formweg), oder durch eine Anweisung an die Sitzung im exakten Wortlaut, die die Sitzung in Abschnitt 8 überträgt (zweiter Formweg).
2. **Claude Code füllt Abschnitt 8 nicht aus.** Ein Merge ohne Kommentar gilt als Annahme mit den Empfehlungen je Entscheidpunkt in Abschnitt 7. Abweichende Entscheide stehen im Text oder in einem Kommentar des Pull Requests oder ergehen als Weisung im Wortlaut.
3. **Geprüft wird der benannte Stand.** Was nach dem Merge-Stand des Pull Requests committet wird, ist nicht Gegenstand dieser Annahme.

**Einordnung aus E-R5-12 (c).** Der Auftraggeber hat E-R5-12 mit dem Merge des Pull Requests #51 nach der Empfehlung (c) entschieden (Wortlaut der Option: `docs/adr/0006-rollen-schreibgrenzen.md`, Teil A, Zeile E-R5-12). Für Sprint 1 gilt damit die Einordnung aus Option (b), wörtlich nach ADR 0006, Teil A, E-R5-12, Option (b): "Die harte Durchsetzung läuft bis auf weiteres allein über die Kette auf der Gegenseite (O-12, Lauf auf jedem Pull Request) und die serverseitigen Regeln von GitHub für main, deren Bestand der Auftraggeber bestätigt. Die Rollen-Schreibgrenzen bleiben Instruktion (ADR 0001, Abschnitt 4), und Etappe 1 beginnt in Abweichung von E-G-03 (a)." Option (c), wörtlich nach derselben Zeile: "Beides: Etappe 1 beginnt nach der Einordnung aus (b), in Abweichung von E-G-03 (a), und R3-Q-005 wird wieder aufgenommen, sobald der Auftraggeber nach (a) meldet, dass die Umgebung eingestellt ist; dann wird R5.1b einmal wiederholt. Der Messaufbau bleibt dafür auf main." Eine Bestätigung des Bestands der serverseitigen Regeln durch den Auftraggeber ist dieser Vorlage nicht belegt (offen). Eine Meldung liegt nicht vor (Angabe des Koordinators). Folge für diesen Sprint: Kein Gate hält in der Cloud-Sitzung eine Schreibgrenze ein; die Gegenseite ist die harte Linie (Abschnitt 6, Hindernis H-1).

**Sprint-Ereignisse und Formwege (Vorschlag, Entscheidpunkt E-S1-17).**

| Ereignis nach 6.8 | Form in diesem Projekt |
|---|---|
| Sprint Planning | diese Vorlage; Annahme durch den Merge |
| Daily Scrum | der Abschnitt je Baueinheit in der Übergabe: was ist fertig, was offen, was entschieden, was behindert |
| Sprint Review | der Merge des Pull Requests der letzten Baueinheit des Sprints; die Abnahme je Baueinheit erfolgt durch den Merge ihres Pull Requests (erster Formweg) |
| Retrospektive | Abschnitt "Retrospektive Sprint 1" in der Übergabe am Ende des Sprints, mit Massnahmen (Verantwortlicher, Termin) und dem Vergleich von geschätztem und tatsächlichem Prüfaufwand (Kalibrierung nach 6.8) |

Die Timeboxes nach 6.8 (Sprint Planning höchstens 4 Stunden, Daily Scrum 15 Minuten, Sprint Review höchstens 2 Stunden, Retrospektive höchstens 1,5 Stunden) gelten für die menschliche Prüfzeit des Auftraggebers je Ereignis.

## 2. Ausgangslage

- **Stand des Repositories:** Merge-Commit `59e6b7ee7b15d659c0e5aa1be4d3203b39ef0667` (Merge des Pull Requests #51). Grundgerüst G0 bis G4 abgenommen. `make dod` endet mit Rückgabewert 2 allein wegen D9 (Lage C, terminiert bis R3-C-004), D19 ohne Befund, Laufzeit 48 bis 88 s (Angaben des Koordinators, Fremdbeleg).
- **Umgebung:** Docker-Daemon ist nach jedem Neustart der Maschine neu zu starten; die Images sind vorhanden; Docker Hub begrenzt anonyme Abrufe (M-G21-01). Auf dem Runner der Gegenseite ist Docker vorhanden, die Images werden je Lauf geladen.
- **Etappe 1 nach dem Backlog:** 29 geschätzte Einträge, 147 Stunden Prüfaufwand; nach `docs/07_Roadmap.md` etwa 4 bis 5 Sprints. Prüfkapazität je Sprint 28 bis 40 Stunden (7 bis 10 Stunden je Woche und Person, zwei Wochen, 6.8).
- **Hypothese des Koordinators** (R3-F-001, R3-F-020, R3-F-008, R3-F-011, R3-F-012, R3-F-019, 29 Stunden) wurde vom Product Owner in zwei Einträgen geändert (Abschnitt 3 des Product Owners, hier Abschnitt 4).

**Was Sprint 1 nicht enthält und weshalb** (Product Owner; Massstab: Der Abnahmetest muss nach seinem Wortlaut am Ende des Sprints grün sein können, ohne Teile des Kriteriums auszulassen). Zurückgestellt, mit Sprint-Kandidat:

| Kennung | h | Grund | Kandidat |
|---|---|---|---|
| R3-F-002 | 3 | Test iteriert über alle registrierten Werkzeuge; ohne Werkzeugverzeichnis leer | Sprint 2 (nach R3-F-026) |
| R3-F-004 | 6 | Rundlauf MISP-Import (R3-F-030, Etappe 2) und STIX-Export (Etappe 4); in Etappe 1 nie grün | nach Schnitt (B4-Kandidat 2) |
| R3-F-006 | 5 | verlangt Berichtsentwurf (R3-F-075, Etappe 4) | nach Abfragepfad und Etappe 2 |
| R3-F-007 | 5 | setzt R3-F-013, R3-F-014, R3-F-017 und R3-F-018 voraus | nach Freigabe und Modellschicht |
| R3-F-009 | 3 | verlangt eine Abfrage mit leerem Ergebnis; kein Abfragepfad | mit dem ersten Abfragepfad |
| R3-F-010 | 5 | Darstellung und Export bestehen nicht | nach Etappe 3/4 oder nach Schnitt |
| R3-F-013 | 6 | setzt MCP-Server, Anbieterschlüssel und Anmeldung (Etappe 3) voraus | Folge-Sprint |
| R3-F-014 | 8 | Ausführungspfad muss bestehen | Sprint 2 oder 3 |
| R3-F-015 | 3 | Modul ausgang | Sprint 2 oder 3, zusammen mit R3-F-028 |
| R3-F-016 | 3 | Abfragen und Freigabevorschau; seitwärts R3-F-026 | nach R3-F-026 und R3-F-014 |
| R3-F-017 | 10 | Prüfsatz gegen Modell | nach R3-F-018 |
| R3-F-018 | 4 | Zwischenschicht zum Sprachmodell | Folge-Sprint (Modell) |
| R3-F-019 | 4 | kein System im Sinne des Eintrags: keine Route, keine Verbindung der Anwendung zur Datenbank, kein MCP-Server, kein Modell; in Sprint 1 grün, danach wieder unvollständig | mit R3-F-013 und R3-F-018 |
| R3-F-020 | 8 | Test verlangt null Treffer in acht Ablageorten, in Sprint 1 besteht einer; grün ohne Aussage (docs/06 warnt davor); der Eintrag lässt sich ohne Änderung nicht teilen (B4); das Zustandsmodell ist präskriptiv (4.4) und wird nicht wegpriorisiert, sondern terminiert | nach Schnitt, ab Sprint 2 |
| R3-F-021 | 3 | verlangt Graph und Export (Etappe 4) | nach Schnitt oder Etappe 4 |
| R3-F-022 | 6 | Prüfsatz je angebundener Quelle; keine Quelle in Etappe 1 | mit der ersten Quelle |
| R3-F-023 | 5 | Modellantworten; Modellschicht fehlt | nach R3-F-018 |
| R3-F-024 | 5 | selbstskalierend; keine schreibende Stelle besteht | mit dem ersten Ablageweg |
| R3-F-026 | 4 | Verzeichnis des Moduls beschaffung; Mechanismus des ersten Tests ist Sache des Software Architects | Sprint 2 (erster) |
| R3-F-027 | 6 | das Modul api hat keine Route; Obergrenzen unbestätigt (offener Punkt 8) | Sprint 2 oder 3 |
| R3-F-028 | 6 | Umwege der Positivliste; Modul ausgang | mit R3-F-015 |
| R3-C-006 | 4 | verlangt vollständigen Ermittlungsdurchlauf | spät in Etappe 1 |
| R3-Q-002 | 4 | verlangt Berichtsentwürfe und Export mit Modulversionen | spät in Etappe 1 |
| R3-F-029 | — | nicht ready (R6, R1), ungeschätzt | unverändert; Backlog, Punkt 13 |

Kandidaten für Sprint 2 (keine Festlegung, Product Owner): R3-F-026, R3-F-002, R3-F-009, R3-F-014, R3-F-015, R3-F-016, R3-F-028 (zusammen 30 Stunden); weitere je nach Stand R3-F-027, R3-F-024, R3-F-020 und R3-F-004.

## 3. Sprint-Ziel

Commitment nach 6.8 (Product Owner, Vorschlag; Wortlaut unverändert übernommen, Scrum Master hält ihn fest):

> Am Ende von Sprint 1 lassen sich in Test/Schulung auf Modulebene ein Fall mit gesetztem Rechtsregime eröffnen und schliessen, jeder dieser Vorgänge steht als SHA-256-verketteter, ausschliesslich anfügbarer Eintrag ohne Klardaten in beiden Spuren, die Kettenprüfung meldet den ersten Bruch, und der kanonische Bestand nimmt nur FollowTheMoney-konforme Datenpunkte mit vollständigem Herkunftsnachweis an.

Überprüfbar an den sechs Abnahmetests des Sprint Backlogs (Abschnitt 4) und am Lauf von `make dod`. "Vollständiger Herkunftsnachweis" ist nach der Lesart des Software Architects (ADR 0007, Teil A, Entscheid 25) zu lesen: Werkzeug und Abfrage sind in Sprint 1 Texte fester Form, die Vollständigkeit der Angaben wird geprüft, nicht ihre Echtheit (Grenze GS-6; Entscheidpunkt E-S1-21). Das Sprint-Ziel nennt "beiden Spuren"; die Einträge der Arbeitsspur entstehen mit R3-F-001, die der Ermittlungsspur mit R3-F-003 und R3-F-005 (ADR 0007, Entscheid 14 und 15). Nicht Teil des Ziels: Abfragepfad, Anmeldung, HTTP-Endpunkte, Löschweg, Setup, Export (ADR 0007, "Nicht Gegenstand").

## 4. Sprint Backlog

### 4.1 Einträge und Prüfaufwand

Geordnet nach Abhängigkeiten (Bauordnung des Product Owners). Stakeholder nach der Satzschablone des Eintrags, Zuordnung nach `docs/02_Stakeholderliste.md` (Product Owner).

| Pos. | Kennung | Titel | Prüfaufwand | Stakeholder (R1) | Ready | Abhängigkeiten | Baueinheit (ADR 0007) |
|---|---|---|---|---|---|---|---|
| 1 | R3-F-008 | Verkettung über SHA-256, ausschliesslich anfügbar | 6 h | S-08 Verteidigung und Gericht (mittelbar) | ready mit Vorbehalt nach R1 | Datenbank im Teststapel (E-S1-02) | S1.2 |
| 2 | R3-F-012 | Kettenprüfung auf Verlangen | 3 h | S-06 Datenschutzbeauftragter (Aufsicht) | ready mit Vorbehalt nach R1 | R3-F-008 | S1.2 |
| 3 | R3-F-001 | Fall eröffnen und schliessen | 4 h | S-03 Fallverantwortlicher | ready mit Vorbehalt nach R1 | R3-F-008 | S1.3 |
| 4 | R3-F-011 | Protokoll ohne zweite Kopie der Falldaten | 4 h | S-06 Datenschutzbeauftragter | ready mit Vorbehalt nach R1 | R3-F-008, R3-F-001, R3-F-003 (Testfall) | S1.5 |
| 5 | R3-F-003 | Kanonischer Datenbestand nach FollowTheMoney | 6 h | S-03 Ermittler | ready mit Vorbehalt nach R1 | Datenbank | S1.4 |
| 6 | R3-F-005 | Herkunftsnachweis nach W3C PROV an jedem Datenpunkt | 8 h | S-07 Staatsanwaltschaft | ready mit Vorbehalt nach R1; Walkthrough: ein blockierender Befund (W1-83), Abschnitt 4.3 | R3-F-003, R3-F-008 | S1.4 |

Grundlage der Baueinheit-Spalte: Zerlegung des Software Architects (Abschnitt 5). Die Einheit S1.1 trägt keinen Eintrag (Grundlage, Commits mit der Kennung R3-F-008).

**Summe und Nachweis gegen 28 bis 40 Stunden:** 6 + 3 + 4 + 4 + 6 + 8 = **31 Stunden**. 28 <= 31 <= 40; Abstand zur Untergrenze 3 Stunden, zur Obergrenze 9 Stunden. Die 9 Stunden bleiben nach dem Product Owner bewusst frei: Das Fundament (Datenbankanbindung, Migrationen, Datenbankrollen, Teststapel) hat keinen eigenen Eintrag und damit keinen eigenen Prüfaufwand, wird aber mitgeprüft; die Schätzungen sind nach 6.8 anfangs zu optimistisch, die Retrospektive kalibriert. Der Prüfaufwand ist nach 6.8 das Mass, nicht die Erzeugungskapazität. Ohne R3-F-005 läge die Summe bei 23 Stunden, unter der Untergrenze (Entscheidpunkt E-S1-21, Option b).

Ob der Prüfaufwand der Rollen ausser dem Auftraggeber (Digital-Forensics-Spezialist, Datenschutzexperte, GRC) im Prüfaufwand der Einträge enthalten ist, ist nach dem Product Owner "gedacht", nicht belegt; die Kalibrierung erfolgt in der Retrospektive (Abschnitt 9).

### 4.2 Ready-Prüfung (Product Owner, wörtlich übernommen in Auszügen; vollständige Tabellen je Eintrag R1 bis R10 im Bericht des Product Owners, Übergabe)

**Rolle:** Product Owner. **R1:** Die Lesart gilt seit 2026-09-22 (docs/06). Für alle sechs Einträge ist der Stakeholder aus der Satzschablone benannt und sein Bezug begründet. Eine unmittelbare Abstimmung mit diesem Stakeholder ist für keinen der sechs Einträge im Backlog belegt; belegt ist die pauschale Freigabe des Backlogs durch S-01 am 2026-08-20 (`docs/08_Freigabe_Schritt_4.md`, E-03). Der Product Owner legt deshalb einheitlich **"ready mit Vorbehalt nach R1"** fest. Der terminierte Schritt ist die Annahme des Sprint Backlogs durch den Auftraggeber (Merge des Pull Requests der Einheiten D21 und S1), geführt als neuer offener Punkt 29 im Backlog. Mit dem Merge tritt die Abstimmung mit S-01 ein und der Vorbehalt entfällt (Entscheidpunkt E-S1-20). Der Vermerk "Vorbehalt entfällt mit Datum" gehört in die Einträge; die Eintragsblöcke bleiben in dieser Einheit byte-gleich, der Vermerk ist deshalb eine Folgeeinheit nach dem Merge.

Gemeinsame Befunde des Product Owners: **R3** — Kettenprüfung, Verkettung und Klardaten stehen nicht als eigene Glossareinträge (Hinweis; der Requirements Engineer hat die Begriffe mit dieser Einheit nachgetragen, Abschnitt 4.3); **R10** — Grundgerüst abgenommen, R3-Q-005 ausgesetzt (keiner der sechs Einträge hängt daran), Fristenwerte (4.4) unbestätigt, Roadmap: "blockiert nichts; gebaut wird mit den Startwerten" (betrifft nur R3-F-001); **R6** — Notation nach docs/06 ist "Vorschlag zur Bestätigung" und gilt für neue Kriterien, die sechs Kriterien bleiben unverändert; **R7 bis R9** — Art "funktional", Prüfaufwand geschätzt, Kennung und Quelle vorhanden.

| Eintrag | R1 | R2 bis R10, Befund des Product Owners |
|---|---|---|
| R3-F-008 | ja, mit Vorbehalt (S-08 kann nicht befragt werden; Anforderungen aus 5.3 und 5.10 abgeleitet) | R4: Bedingung, dass der Test über beide Spuren läuft (Schnittbedingung B-2); R10: Datenbank im Teststapel (Bedingung B-1); sonst ja |
| R3-F-012 | ja, mit Vorbehalt (S-06) | R3 mit Hinweis (Begriff nicht im Glossar); R10: setzt R3-F-008; sonst ja |
| R3-F-001 | ja, mit Vorbehalt (S-03, erreichbar über S-01) | R4 mit Hinweis: in welcher Spur der Protokolleintrag steht (Lesart Arbeitsspur) und Prüffrist nach den Startwerten aus 4.4 im Eintrag nicht als Annahme; Gegenprobe nicht ausdrücklich |
| R3-F-011 | ja, mit Vorbehalt (S-06) | R4 mit Hinweis: "unkenntlich gemacht oder als Prüfsumme" offen; ungesalzene Prüfsumme bei kleinem Wertebereich erratbar (Frage an Software Architect und Datenschutzexperte) |
| R3-F-003 | ja, mit Vorbehalt (S-03) | R4 mit Hinweis: Schemafassung und Bibliothek sind Sache des Software Architects; Lieferkettenprüfung bei neuer Abhängigkeit |
| R3-F-005 | ja, mit Vorbehalt (S-07, Kontakt über S-01) | R4 mit Hinweis: Werkzeug, Abfrage, erhebende Person bestehen in Sprint 1 nicht; das Kriterium verlange Vollständigkeit, nicht Echtheit; Festlegung "relational, NOT NULL-Fremdschlüssel, PROV erst beim Export" in ADR 0002 (A2); Aufnahme setzt voraus, dass der Test mit dem Bestand wächst |

### 4.3 Ergebnis des Walkthroughs (Requirements Engineer)

Befundliste ohne Lösungsvorschlag: `docs/sprints/sprint-01-walkthrough.md`. Massstab sind die vier Glieder Umfang, Prüfsatz, Nachbedingung und Gegenprobe (Notation nach docs/06, Vorschlag zur Bestätigung; hier Prüfraster, nicht gesetzte Regel). Übersicht (die Spalte "Einschätzung" des Requirements Engineers ist ein Hinweis an den Product Owner und ersetzt dessen Ready-Prüfung nicht):

| Eintrag | blockiert | Nachbesserung | Hinweis |
|---|---|---|---|
| R3-F-008 | 0 | 6 | 2 |
| R3-F-012 | 0 | 4 | 1 |
| R3-F-001 | 0 | 9 | 4 |
| R3-F-011 | 0 | 5 | 2 |
| R3-F-003 | 0 | 7 | 2 |
| R3-F-005 | 1 | 9 | 4 |
| Querschnitt | 0 | 1 | 1 |
| **Summe Sprint Backlog** | **1** | **41** | **16** |

Zusätzlich gesichtet, nicht gezogen: R3-F-020 (2 blockiert, 13 Nachbesserung, 5 Hinweis), R3-F-019 (0, 4, 3), R3-F-007, R3-F-010, R3-F-002 und R3-F-009 (je 1 blockiert); Gesamtsumme des Walkthroughs 96 Befunde (7 blockiert, 65 Nachbesserung, 24 Hinweis). Die Begriffe Aufgabe, Datenpunkt, Fallkategorie, Fallverantwortlicher, Kettenprüfung, Klardaten, Löschweg, Protokolleintrag, Prüffrist, Rechtsregime und Verkettung sind mit der Einheit im Glossar nachgetragen; die GRC-Rolle hat die Stellen "Rechtsregime" und "Aufbewahrungsklasse/Fallkategorie" geprüft (beide tragen; Hinweise H-1 bis H-6, nicht blockierend, Übergabe).

**Blockierender Befund W1-83 (R3-F-005, Test `R3-F-005_kein_knoten_ohne_herkunft`).** "Vollständiger Herkunftsnachweis" mit Werkzeug und Abfrage lässt zwei Lesarten zu: Verweise auf bestehende Datensätze (Werkzeugverzeichnis, Abfrageeintrag der Arbeitsspur; ADR 0002, A2: NOT NULL-Fremdschlüssel) oder frei gesetzte Werte. Die erste ist in Sprint 1 ohne Werkzeugverzeichnis und Abfragepfad nicht erfüllbar, die zweite belegt nur nicht leere Felder; davon hängt ab, ob und was der Test in Sprint 1 grün zeigen kann. Umgang der Vorlage damit (6.7: gesammelt, nicht gelöst):

- Der Walkthrough löst den Befund nicht. Der Software Architect fasst ihn in ADR 0007 als **Entscheid Nr. 25** (Herkunftsnachweis: Werkzeug und Abfrage sind Texte fester Form mit Prüfbedingungen, kein Werkzeugverzeichnis) und als **Grenze GS-6** (Werkzeug und Abfrage nicht gegen ein Werkzeugverzeichnis geprüft); es ist dafür kein Entscheidpunkt E-S1-01 bis E-S1-15 vergeben (E-S1-15 betrifft die Zähleinheit Knoten/Kante, nicht W1-83). Damit der Auftraggeber die Lesart sieht und entscheidet, führt diese Vorlage sie als eigenen **Entscheidpunkt E-S1-21**.
- **Widerspruch, nicht aufgelöst:** Der Product Owner führt R3-F-005 als "ready mit Vorbehalt nach R1" und hält fest, der Requirements Engineer habe ihm keinen Befund gemeldet, der die Ready-Prüfung kippe (Stand seines Berichts); der Requirements Engineer führt denselben Eintrag nach W1-83 als "nicht ready in dieser Form". Die Befunde W1-74 bis W1-96 sind nach der Festlegung des Sprint Backlogs entstanden. Beide Positionen stehen unverändert in dieser Vorlage; der Auftraggeber entscheidet mit E-S1-21.
- Die 41 Nachbesserungen und 16 Hinweise im Sprint Backlog sind keine Blocker. Sie kommen, soweit gewünscht, als eigene Backlog-Einträge über den Product Owner (B4); die Eintragsblöcke bleiben unverändert. Annahmen, die der Bau treffen muss, stehen in der Festlegung des Software Architects (ADR 0007); wo der Walkthrough Fragen stellt, die ADR 0007 nicht beantwortet, bleiben sie offen (Abschnitt 7, E-S1-22).

## 5. Festlegung und Zerlegung in Baueinheiten mit Reihenfolge (3.3)

**Festlegung:** `docs/adr/0007-datenzugriff-und-protokollschema.md` (Software Architect; Status vorgeschlagen, Teil A Stand, Teil B Entscheidlog; nicht gebaut). Sie legt Zugriffsschicht, Treiber, Migrationen, Datenbankrollen, Schema der beiden Spuren mit Verkettung und Kettenprüfung, Fall, Bestand mit Herkunft, Teststufe mit Datenbank, die Verträge 4, 5 und 8 bis 10, Grenzen GS-1 bis GS-10 und die Entscheidpunkte E-S1-01 bis E-S1-15 fest. Die Annahme dieser Vorlage nimmt ADR 0007 an (Merge des Pull Requests der Einheiten D21 und S1, nach Empfehlung je Entscheidpunkt).

**Gemeinsam für alle Einheiten** (Software Architect): Je Einheit ein Pull Request, Merge = Abnahme. Der Backend Engineer baut Code und Einheits- und Integrationstests; der Dynamic Software Tester schreibt die Abnahmetests vor dem Bau aus dem Abnahmekriterium und verifiziert am Endstand mit Mutationslauf; der Static Software Tester prüft den ganzen Diff auf einem anderen Modellfeld; wer baut, prüft nicht (3.4). Abnahmekriterium jeder Einheit: `make dod` in der Form des Abnahmekriteriums (D9 einzige Lage C, Rückgabewert 2 allein wegen D9, D19 ohne Befund), D6 mit 80 % und den kritischen Modulen nach E-S1-14, D18 mit den Verträgen der Einheit, je Vertrag und je Auslöser oder Recht eine erkannte Mutation. Die Zeile eines Eintrags in `scripts/abnahme-ausnahmen.txt` entfällt in der Einheit, in der sein erster Abnahmetest gesammelt wird; dann müssen alle Testnamen des Eintrags bestehen (D7, KA-4 und KA-8); die Zeile entfernt der Product Owner.

| Einheit | Gegenstand | Einträge (Abnahme) | Rollen ausser Bau und Prüfung | Abnahmekriterium zusätzlich | Pull Request |
|---|---|---|---|---|---|
| S1.1 Datenzugriff und Teststufe | Abhängigkeiten (ohne followthemoney), core (konfiguration, fehler, zeit, kennung, datenbank), Alembic-Gerüst, Revision 0001 (Rollen und Schema), Fixture, Wache im `Makefile` vor D5 bis D7, D2 bis D4 über backend/migrationen, Vertrag 10, Schritt im Arbeitsablauf nach E-S1-03, Nachführung der Architekturtests | keiner (Grundlage für R3-F-008) | SecDevOps Engineer; DevOps Engineer; Docker-Kubernetes-Experte | Integrationstests Rollen (ohne Superuser-Rechte, anwendung ohne CREATE); Gegenprobe ohne Daemon: Lage C FEHLT=docker-daemon; Laufzeit gemessen (O-20); D7 unverändert | eigener Pull Request der Einheit |
| S1.2 Spur-Kern | Revisionen 0002 (fall, fallkategorie mit Startwerten, fall_schluessel) und 0003 (Spurtabellen, Kettenkopf, Auslöser, Rechte, Prüffunktion), Modul spur, Verträge 4 und 9 | R3-F-008, R3-F-012 | Digital-Forensics-Spezialist (D16); SecDevOps Engineer | Zeilen R3-F-008 und R3-F-012 entfernt; beide Rechenwege gleich an mindestens den vier Bruchgründen; Mutationen: Auslöser entfernt, GRANT UPDATE, ein Feld aus der Serialisierung entfernt, Kettenkopf ohne Auslöser | eigener Pull Request |
| S1.3 Fall | fall.service (eröffnen, schliessen), Eintragstypen fall_eroeffnet und fall_geschlossen, Vertrag 8 | R3-F-001 | Datenschutzexperte (Bearbeitungsverzeichnis, Löschkonzept als Entwurf); Security Specialist GRC (Vorrat R1 und R2, Startwerte als Vorschlag); D16 | Zeile R3-F-001 entfernt; Mutation: Prüfbedingung des Rechtsregimes entfernt | eigener Pull Request |
| S1.4 Bestand und Herkunft | followthemoney (E-S1-13, Lieferkette vor dem Bau), Revision 0004, kanon, Einträge entitaet und beziehung in der Ermittlungsspur, Vertrag 5 | R3-F-003, R3-F-005 | SecDevOps Engineer (Lieferkette); Datenschutzexperte; D16 | Zeilen R3-F-003 und R3-F-005 entfernt; Mutationen: NOT NULL der Herkunft entfernt, Abweisung des unbekannten Schemas entfernt | eigener Pull Request |
| S1.5 Keine Klardaten im Protokoll | Abnahme von R3-F-011 über einen Testfall mit Fall und Entitäten; Katalogsuche | R3-F-011 | Datenschutzexperte (Stellungnahme zur Pseudonymisierung, E-S1-06); D16 | Zeile R3-F-011 entfernt; Mutation: Pseudonymisierung eines Eigenschaftswerts ausgelassen, erkannt | eigener Pull Request |

(Tabelle gekürzt aus ADR 0007, Teil A, "Zerlegung von Sprint 1 und Reihenfolge"; massgeblich ist dessen Wortlaut. Die Nummern der Pull Requests stehen erst beim Anlegen fest.)

**Reihenfolge und Begründung** (Software Architect): S1.1 vor allem, weil jede Einheit die Teststufe braucht. Die Spurtabellen verweisen auf fall; deshalb legt S1.2 die Tabelle fall an, S1.3 baut die Vorgänge darauf, die je einen Eintrag über spur schreiben. Bestand und Herkunft schreiben Einträge in die Ermittlungsspur und folgen nach S1.2; R3-F-011 hat erst mit dem Bestand seinen vollen Testfall und steht deshalb zuletzt. S1.3 und S1.4 sind voneinander unabhängig, beide brauchen S1.2. **Abweichung von der Bauordnung des Product Owners** (R3-F-011 an vierter Stelle, vor R3-F-003): Der Software Architect legt R3-F-011 als letzte Einheit S1.5 (Entscheidpunkt E-S1-01); der Product Owner begründete seine Ordnung damit, dass R3-F-011 vor jedem weiteren Protokolleintrag mit Falldaten stehen müsse, um Altlasten zu vermeiden. Beide Begründungen stehen unverändert; die Pseudonymisierung selbst entsteht nach dem Software Architect schon in S1.2 und wird dort mit Einheitstests geprüft. Keine Einheit läuft neben einer anderen (CLAUDE.md, "Vor jeder Arbeitseinheit"). Commits von S1.1 tragen die Kennung R3-F-008, wenn der Product Owner nichts anderes festlegt (offene Frage, Abschnitt 6, H-8).

**D13 bis D17 je Einheit** (`docs/06_Definition_of_Ready_und_Done.md`, Teil 2):

| Bedingung | Bestätigung | S1.1 | S1.2 | S1.3 | S1.4 | S1.5 |
|---|---|---|---|---|---|---|
| D13 umsetzende Rolle hat nicht selbst verifiziert | Dynamic und Static Software Tester | ja | ja | ja | ja | ja |
| D14 Static und Dynamic Software Tester auf anderem Modell | beide | ja | ja | ja | ja | ja |
| D15 Übergabe | Scrum Master / Koordinator | ja | ja | ja | ja | ja |
| D16 Änderung an Protokoll, Herkunft, Export oder Löschweg: Prüfbericht | Digital-Forensics-Spezialist | nicht berührt (Revision 0001 legt Rollen und Schema, keine Spurtabelle) | ja | ja (neue Eintragstypen) | ja (Herkunft) | ja |
| D17 Änderung am präskriptiven Teil | GRC-Rolle und Auftraggeber | nicht berührt | nicht berührt | Stellungnahme der GRC-Rolle vorgesehen (Vorrat, Startwerte); ob D17 formal greift, siehe Abschnitt 6, H-9 | nicht berührt | nicht berührt |

D17 ist nach der Lesart dieser Vorlage nicht berührt, soweit 4.4 umgesetzt und nicht geändert wird. Die Startwerte der Prüffristen sind betriebliche Voreinstellungen, "Vorschlag zur Bestätigung" (4.4), konfigurierbar und nirgends fest verdrahtet (Entscheidpunkt E-S1-18).

## 6. Ereignisplan und Hindernisliste

### 6.1 Ereignisplan

Sprintbeginn ist der Merge des Pull Requests der Einheiten D21 und S1 (Tag 0). Sprintende ist zwei Wochen danach (Tag 14) oder die Abnahme der letzten Baueinheit, je nachdem, was zuerst eintritt. Einheiten, die am Sprintende nicht abgenommen sind, gehen in die Planung von Sprint 2 zurück; ein halbfertiger Zustand wird nicht als erledigt geführt (3.3). Konkrete Daten ergeben sich aus dem Zeitpunkt des Merges; sie stehen bis dahin nicht fest.

| Ereignis | Form (Formweg) | Timebox (6.8) | Zeitpunkt |
|---|---|---|---|
| Sprint Planning | diese Vorlage; Annahme durch den Merge | höchstens 4 h Prüfzeit des Auftraggebers | vorgelegt 2026-11-05; Sprintbeginn = Merge (Tag 0) |
| Daily Scrum | Abschnitt je Baueinheit in der Übergabe (fertig, offen, entschieden, Hindernis) | 15 min Prüfzeit je Eintrag | mit jeder Baueinheit, S1.1 bis S1.5 |
| Abnahme je Baueinheit | Merge des Pull Requests der Einheit (erster Formweg) | im Rahmen des Sprint Review | je Einheit, Pause bis zum Merge |
| Sprint Review | Merge des Pull Requests der letzten Baueinheit des Sprints (S1.5) | höchstens 2 h Prüfzeit | spätestens Tag 14 |
| Retrospektive | Abschnitt "Retrospektive Sprint 1" in der Übergabe, mit Massnahmen (je ein Verantwortlicher, ein Termin) und Vergleich von geschätztem und tatsächlichem Prüfaufwand | höchstens 1,5 h Prüfzeit | nach dem Review, spätestens Tag 14 |

**Wartezeiten auf menschliches Review liegen auf dem kritischen Pfad** (6.8) und werden als eigene Positionen ausgewiesen: Sechs Merges (Pull Request der Einheiten D21 und S1 sowie fünf Baueinheiten) stehen in strenger Reihenfolge, weil keine Einheit neben einer anderen läuft; jede Wartezeit auf einen Merge ist eine Position der Übergabe, nicht Teil der Bauzeit.

### 6.2 Hindernisliste (Stand 2026-11-05)

| Nr. | Hindernis | Betroffene Rolle | Datum | Stand | Nächster Schritt | Abschlussdatum |
|---|---|---|---|---|---|---|
| H-1 | Projekt-Hooks laufen in der Cloud-Sitzung nicht (R3-Q-005 ausgesetzt, SR-024 offen); die Rollen-Schreibgrenzen sind Instruktion (E-R5-12 c) | alle schreibenden Rollen; SecDevOps Engineer | 2026-11-05 | offen; Messaufbau auf main | Meldung des Auftraggebers, dass die Umgebung die Projekt-Hooks ausführt; dann R5.1b einmal wiederholen | offen |
| H-2 | Kette auf der Gegenseite rot bis R3-C-004 (gewollt; das Urteil liegt am Rückgabewert von `make dod` ohne Liste der terminierten Lagen) | DevOps Engineer; Auftraggeber | 2026-11-05 | gewollt, kein Fehler | Rückgabewert und Lagezeilen je Pull Request prüfen (D9 einzige Lage C) | mit R3-C-004 |
| H-3 | Docker-Daemon ist nach jedem Neustart der Maschine neu zu starten; Docker Hub begrenzt anonyme Abrufe (M-G21-01: Vorladen der drei Images im Setup-Skript, Vorlage ohne Entscheid) | DevOps Engineer; Dynamic Software Tester | 2026-11-05 | offen | Entscheid des Auftraggebers zur Vorlage M-G21-01; bis dahin Daemon je Sitzung starten | offen |
| H-4 | Die drei Wegwerf-Zweige bestehen weiter; der Push-Weg der Sitzung wurde beim Löschen mit HTTP 403 abgewiesen | Auftraggeber | 2026-11-05 | offen, Bitte im Pull Request von D17 | Löschen durch den Auftraggeber | offen |
| H-5 | Wartezeiten auf Merges liegen auf dem kritischen Pfad; sechs Merges in Reihe | Auftraggeber; Scrum Master | 2026-11-05 | läuft | Wartezeit je Merge als Position in der Übergabe | Tag 14 |
| H-6 | E-S1-03 ändert den abgenommenen Arbeitsablauf der Gegenseite (G4); Abrufgrenze M-G21-01 trifft auch den Runner | DevOps Engineer; SecDevOps Engineer | 2026-11-05 | zur Entscheidung (E-S1-03) | im Pull Request von S1.1 ausdrücklich nennen; Nachführung von `backend/tests/architektur/test_arbeitsablauf_gegenseite.py` | mit S1.1 |
| H-7 | Widerspruch zwischen Product Owner (R3-F-005 ready mit Vorbehalt) und Requirements Engineer (W1-83 blockiert) | Product Owner; Requirements Engineer | 2026-11-05 | nicht aufgelöst | Entscheid des Auftraggebers (E-S1-21) | mit der Annahme |
| H-8 | Einträge der Spuren in S1.2 vor dem Bestand (Ermittlungsspur-Eintragstypen erst mit S1.4); Kennung der Commits von S1.1 (Vorschlag des Software Architects: R3-F-008) vom Product Owner noch zu bestätigen | Product Owner; Software Architect | 2026-11-05 | aufgelöst am 2026-11-05 (ADR 0007, Nachbesserung) bis auf die Bestätigung der Commit-Kennung durch den Product Owner (offen) | Aufgelöst: In S1.2 schreibt die Testfixture einen synthetischen Fall unmittelbar in die Tabelle fall (samt Fallschlüssel), der Kettenkopf entsteht über spur.service.ketten_anlegen, alle vier Eintragstypen von Sprint 1 stehen ab Revision 0003 im Vorrat, und die Abnahmetests von R3-F-008 und R3-F-012 schreiben fall_eroeffnet in die Arbeitsspur und entitaet in die Ermittlungsspur mit synthetischer Nutzlast gleicher Form; echte Einträge kommen ab S1.3 aus fall und ab S1.4 aus kanon. Offen: Bestätigung der Commit-Kennung von S1.1 durch den Product Owner | 2026-11-05 (ohne die Commit-Kennung: vor S1.1) |
| H-9 | Berührung von D17 in S1.3 (Rechtsregime-Vorrat auf R1 und R2 beschränkt, E-S1-09; Startwerte): GRC-Stellungnahme vorgesehen, formale Geltung von D17 nicht entschieden; Walkthrough-Befunde W1-02, W1-11, W1-32, W1-33 am präskriptiven Teil entscheidet die GRC-Rolle mit dem Auftraggeber (6.6) | Security Specialist GRC; Auftraggeber | 2026-11-05 | offen | Klärung in der Annahme (E-S1-09) und vor S1.3 | vor S1.3 |
| H-10 | Begriff im Schema: ADR 0007 führte Tabelle und Spalte aufbewahrungsklasse; Glossar und GRC-Prüfung sagen "in Arbeitsprodukten Fallkategorie verwenden" (Synonym; W1-08, GRC-Hinweis H-5) | Software Architect; Requirements Engineer | 2026-11-05 | aufgelöst am 2026-11-05 (ADR 0007, Nachbesserung) | Aufgelöst: Der Bezeichner heisst jetzt fallkategorie nach dem Glossar (ADR 0007, Entscheide 9 und 22 und Teil B, Nachbesserung H-8 und H-10; Regel in Entscheid 28, Bezeichner nach ADR 0002, A13); Backlog-Eintrag R3-F-001 und Glossar sagen auch Aufbewahrungsklasse (Synonym, im ADR vermerkt) | 2026-11-05 |

## 7. Entscheidungspunkte

Ein Merge ohne Kommentar gilt als Entscheid nach der Empfehlung je Punkt (Abschnitt 1, Festlegung 2). **Herkunft der Nummern:** E-S1-01 bis E-S1-15 stammen vom Software Architect und sind Wortlaut und Nummer aus ADR 0007, Teil A, Tabelle "Entscheidpunkte" (dort mit den ausführlichen Optionen und Preisen; hier gekürzt, massgeblich ist der ADR). E-S1-16 bis E-S1-22 sind angehängt: E-S1-16 bis E-S1-20 vom Scrum Master (E-S1-18 bis E-S1-20 aus den Fragen A1 bis A3 des Product Owners), E-S1-21 und E-S1-22 vom Scrum Master zur Sichtbarmachung des Walkthrough-Ergebnisses.

### 7.1 Entscheidpunkte des Software Architects (ADR 0007)

| Nr. | Frage | Optionen und Preis (gekürzt) | Empfehlung |
|---|---|---|---|
| E-S1-01 | Zerlegung und Reihenfolge | (a) S1.1 bis S1.5, R3-F-011 zuletzt, abweichend vom Product Owner; Preis: R3-F-011 wird erst am Ende abgenommen. (b) Bauordnung des Product Owners, R3-F-011 in S1.3 allein mit Aktenzeichen und Rechtsgrundlage; Preis: Eigenschaftswerte der Entitäten (Namen, Adressen, Telefonnummern) nicht gedeckt | (a) |
| E-S1-02 | Wo die Datenbanktests in D5 bis D7 laufen (Abweichung vom Wortlaut von A12 "aus dem Prüfstapel") | (a) Wegwerf-Container mit Port auf 127.0.0.1; (b) Prüfdienst im Stapel; (c) Wegwerf-Container aus demselben Digest wie der Stapel, ohne Netz, Unix-Socket; Preis (c): Instanz ausserhalb des Stapels, verwaiste Container nach hartem Abbruch (GS-8) | (c) |
| E-S1-03 | Image auf der Gegenseite. **Ändert den abgenommenen Arbeitsablauf der Gegenseite (G4):** `.github/workflows/kette-gegenseite.yml` und `backend/tests/architektur/test_arbeitsablauf_gegenseite.py` | (a) ein Schritt vor `make dod`, der allein das Image des Dienstes datenbank über den Digest lädt; Preis: Änderung an einem abgenommenen Gegenstand, Abrufgrenze M-G21-01. (b) kein Schritt, Datenbankstufe auf der Gegenseite Lage C; Preis: die Gegenseite prüft die Spuren nicht | (a) |
| E-S1-04 | Rückweg der Migrationen | (a) jede Revision mit Rückweg; (b) Revisionen der Spurtabellen ohne Rückweg, übrige mit Rückweg | (b) |
| E-S1-05 | Kette je Spur oder je Spur und Fall | (a) je Spur über alle Fälle; (b) je Spur und Fall | (b) |
| E-S1-06 | Pseudonym im Protokoll | (a) SHA-256 ohne Schlüssel (erratbar bei kleinem Wertebereich); (b) HMAC-SHA-256 mit Schlüssel je Fall; Preis: Schlüssel unverschlüsselt in der Datenbank (GS-5, O-6 bleibt offen) | (b) |
| E-S1-07 | Person in den Spuren und in der Herkunft | (a) Benutzerkennung im Klartext, kein Falldatum; (b) Pseudonym mit Fallschlüssel; Preis: nach Fallöschung nicht zurechenbar | (a) |
| E-S1-08 | Kennzeichnung bei Vorgängen ohne Modell | (a) zwei Werte, Vorgänge = quellenaussage; (b) drei Werte; Preis: widerspricht dem Wortlaut "genau eine der beiden Kennzeichnungen" | (a) |
| E-S1-09 | Vorrat des Rechtsregimes | (a) nur R1 und R2; (b) R1 bis R5, Eröffnung nur mit R1 oder R2 | (a) |
| E-S1-10 | Eindeutigkeit des Aktenzeichens | (a) eindeutig unter nicht gelöschten Fällen; (b) nicht eindeutig | (a) |
| E-S1-11 | Festschreiben der Prüffrist | (a) prueffrist_bis beim Schliessen berechnet und gespeichert; (b) laufende Fristen folgen jeder Änderung | (a) |
| E-S1-12 | Bestand je Fall | (a) fall_kennung NOT NULL; (b) fallübergreifend | (a) |
| E-S1-13 | Validierung nach FollowTheMoney | (a) Bibliothek followthemoney nach Lieferkettenprüfung, Rückfall (b); (b) eigene Validierung gegen Schemadateien in fester Fassung | (a) |
| E-S1-14 | Abdeckungsschwelle D6 | (a) fall und kanon zusätzlich 100 %; (b) unverändert spur, zugriff, freigabe | (a) |
| E-S1-15 | Herkunft je Datensatz oder je Eigenschaftswert | (a) je Knoten und Kante; (b) je Eigenschaftswert (Aussagemodell) | (a) |

### 7.2 Entscheidpunkte dieser Vorlage und des Product Owners

| Nr. | Frage | Optionen und Preis | Empfehlung |
|---|---|---|---|
| E-S1-16 | Annahme von Sprint-Ziel (Abschnitt 3) und Sprint Backlog (Abschnitt 4, sechs Einträge, 31 Stunden gegen 28 bis 40) | (a) angenommen; (b) angenommen mit Auflagen; (c) nicht angenommen. Preis (a): 41 Nachbesserungen und 16 Hinweise des Walkthroughs gehen als Einträge nach B4 oder als Annahmen in ADR 0007 in den Bau | (a) |
| E-S1-17 | Abbildung der Sprint-Ereignisse auf die Formwege (Abschnitt 1, Tabelle; Timeboxes als Prüfzeit des Auftraggebers) | (a) wie Abschnitt 1; (b) zusätzliche Termine mit dem Auftraggeber; Preis (b): Wartezeit auf dem kritischen Pfad | (a) |
| E-S1-18 | Startwerte der Prüffristen nach 4.4 (1, 3, 7, 10, 15, 30 Jahre; unverjährbar Prüfung alle 5 Jahre; Frage A1 des Product Owners) | (a) bauen mit den Startwerten, konfigurierbar, nirgends fest verdrahtet, wie die Roadmap es führt; die Bestätigung durch die Kantonspolizei Bern im Bearbeitungsreglement bleibt ausstehend und blockiert nichts; (b) Bestätigung vor dem Bau; Preis: R3-F-001 wartet | (a) |
| E-S1-19 | Notation der Abnahmekriterien nach `docs/06_Definition_of_Ready_und_Done.md`, Teil 1 (Umfang, Prüfsatz, Nachbedingung, Gegenprobe; "Vorschlag zur Bestätigung durch den Auftraggeber"; Frage A2) | (a) für neue Kriterien bestätigen; die sechs Kriterien des Sprints bleiben unverändert; (b) nicht bestätigen; Preis: der Walkthrough bleibt ohne Massstab | (a) |
| E-S1-20 | Merge als Abstimmung nach R1 für die sechs Einträge "ready mit Vorbehalt nach R1" (Frage A3 des Product Owners) | (a) der Merge gilt als Abstimmung mit S-01, der Vorbehalt entfällt; der Vermerk in den Einträgen folgt in einer Einheit nach dem Merge (Frage K2 des Product Owners); (b) Abstimmung mit weiteren Stakeholdern (S-03, S-06, S-07) vor dem Bau; Preis: Wartezeit | (a) |
| E-S1-21 | Lesart von "vollständiger Herkunftsnachweis" bei R3-F-005 (W1-83; ADR 0007, Entscheid 25 und Grenze GS-6) | (a) Werkzeug und Abfrage sind in Sprint 1 Texte fester Form; geprüft wird Vollständigkeit, nicht Echtheit; Preis: der Test belegt nur nicht leere, formgerechte Felder. (b) R3-F-005 aus dem Sprint nehmen und die Lesart über B4 klären; Preis: Summe 23 Stunden, unter der Untergrenze von 28; Sprint-Ziel verliert den letzten Teilsatz | (a), die Position des Software Architects und des Product Owners; der Requirements Engineer hat keine Lösung vorgeschlagen |
| E-S1-22 | Umgang mit den Nachbesserungen des Walkthroughs | (a) nicht vor dem Bau einarbeiten; Annahmen des Baus stehen in ADR 0007, Nachbesserungen kommen bei Bedarf als eigene Einträge über den Product Owner (B4), die Eintragsblöcke bleiben unverändert; Preis: die Abnahmetests werden gegen den Wortlaut der Kriterien geschrieben, Lücken bleiben bis dahin Befunde; (b) Einarbeitung als eigene Einheit vor S1.1; Preis: Wartezeit, weitere Merges | (a) |

Zur Berührung des präskriptiven Teils (E-S1-09, W1-02, W1-11, W1-32, W1-33): Korrekturen an 4.4 entscheidet die GRC-Rolle gemeinsam mit dem Auftraggeber (6.6); E-S1-09 (a) ist eine Umsetzungsentscheidung zum Feld, keine Änderung von 4.4 (Hindernis H-9).

## 8. Annahmeerklärung

*Nicht ausgefüllt. Claude Code füllt diesen Abschnitt nicht aus; die Entscheidung liegt beim Auftraggeber. Die Folgeeinheit trägt den Entscheid aus dem Merge ein (ADR 0002, Abschnitt 10; Backlog, Punkt 29).*

### Entscheid (E-S1-16)

- [ ] **Angenommen.** Sprint 1 beginnt mit dem Merge; die erste Baueinheit ist S1.1.
- [ ] **Angenommen mit Auflagen.** Die Auflagen unten werden vor oder mit der genannten Einheit umgesetzt.
- [ ] **Nicht angenommen.** Nachbesserung gemäss Auflagen, danach erneute Vorlage.

### Auflagen

| Nr. | Auflage | Frist oder Bedingung |
|---|---|---|
| | | |

### Entscheide je Punkt

| Punkt | Entscheid |
|---|---|
| E-S1-01 bis E-S1-15 (ADR 0007) | |
| E-S1-17 bis E-S1-22 | |

### Erklärung

> Ich habe die Vorlage `docs/sprints/sprint-01.md` im Stand des Pull Requests der Einheiten D21 und S1 geprüft.
> Der Entscheid oben gilt.

| | |
|---|---|
| **Auftraggeber (S-01)** | |

### Formweg

Erster Formweg: Merge des Pull Requests der Einheiten D21 und S1; sein Text sagt, dass der Merge die Annahme von Sprint-Ziel, Sprint Backlog und Zerlegung nach dieser Vorlage bedeutet, mit den Empfehlungen je Entscheidpunkt, sofern kein Kommentar und keine Weisung anderes sagt. Zweiter Formweg: Anweisung an die nächste Sitzung im exakten Wortlaut des Entscheids; die Sitzung überträgt ihn hierher. Massgeblich ist der committete Stand; Urheber und Zeitpunkt belegt die Commit-Historie.

## 9. Nach der Annahme

1. Die erste Sitzung nach dem Merge trägt die Annahme ein: Protocol Master in ADR 0002, Abschnitt 10 und in Abschnitt 8 dieses Dokuments; Product Owner im Backlog (Nachführungen, Punkt 29, Vermerk "Vorbehalt entfällt" in den sechs Einträgen); Software Architect in ADR 0007 (Status nach den Entscheiden E-S1-01 bis E-S1-15 und ADR 0002, Abschnitt 4.3 mit den Verträgen 8 bis 10); Koordinator in CLAUDE.md.
2. **Erste Baueinheit** nach der Zerlegung: S1.1 (Datenzugriff und Teststufe). Jede Baueinheit beginnt mit der Erfassung der Codebasis (3.1) und dem Schnitt durch den Software Architect, wird von Static und Dynamic Software Tester auf einem anderen Modellfeld verifiziert (3.4) und durch den Merge ihres Pull Requests abgenommen. Pause je Pull Request bis zum Merge; ohne weitere Weisung je Einheit nach der Weisung vom 2026-11-05.
3. **Rückkopplung:** Jede Baueinheit trägt in der Übergabe den tatsächlichen Prüfaufwand des Auftraggebers ein, soweit er ihn nennt; nennt er ihn nicht, gilt die Wartezeit bis zum Merge als Ersatzmass und ist als solches benannt. Die Retrospektive vergleicht geschätzten und tatsächlichen Prüfaufwand (Kalibrierung nach 6.8, `docs/07_Roadmap.md`).
4. Was am Sprintende nicht abgenommen ist, geht in die Planung von Sprint 2 zurück.
5. Vor jedem Frontend-Inkrement steht das Gate aus 5.6; Sprint 1 berührt es nicht.
