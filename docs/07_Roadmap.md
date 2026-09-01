# Roadmap

| | |
|---|---|
| **Arbeitsprodukt nach** | Projektauftrag 6.8, 9.1 |
| **Verantwortlich** | Product Owner, Scrum Master |
| **Stand** | 2026-08-26, nachgeführt (Befund F des Deep Reviews vom 2026-08-25, Nachführung durch den Product Owner; frühere Nachführung: V-04 aus `docs/08_Freigabe_Schritt_4.md`); 2026-08-31 durch den Scrum Master gegen den Backlog-Stand vom 2026-08-31 nachgeführt (dritte und vierte Nachführung des Product Owners; Einzelheiten unter "Grundlage der Zahlen" und in den Nachführungsvermerken unten) |

## Grundlage der Zahlen

Diese Roadmap enthält Zahlen, **weil der Prüfaufwand geschätzt ist**. Vor der
Schätzung in `05_Product_Backlog.md` wurde keine Kalenderzahl geschrieben (6.8).

| Grösse | Wert | Quelle |
|---|---|---|
| Prüfaufwand erste Fassung | 352 h | Backlog, 82 Einträge |
| Prüfaufwand zweite Fassung | 18 h | Backlog, 4 Einträge |
| Prüfaufwand gesamt | 370 h | Backlog, 86 Einträge |
| Sprintlänge | 2 Wochen | 6.8, festgelegt |
| Kapazität je Person | 7 bis 10 h pro Woche | 6.8, geklärt |
| Kapazität Team je Sprint | **28 bis 40 h** | 6.8 |

**Der Sprintumfang bemisst sich an der Prüfkapazität, nicht an der
Erzeugungskapazität** (6.8). Claude Code kann in einem Sprint mehr produzieren,
als in 28 bis 40 Stunden sorgfältig geprüft werden kann. Der Product Owner nimmt
deshalb nur so viel in den Sprint, wie das Team prüfen kann. Ein wachsender
Bestand ungeprüfter Inkremente ist bei einem Werkzeug mit Nachweispflicht die
gefährlichste Form von Fortschritt.

**Nicht in den obigen Summen enthalten**, wie im Backlog selbst ausgewiesen:
R3-Q-009 (Etappe 0) und R3-F-029 (Etappe 1) erfüllen die Definition of Ready
nicht und tragen deshalb keinen Prüfaufwand; R3-F-094 (zweite Fassung) ebenso
seit der vierten Nachführung des Backlogs vom 2026-08-31 (siehe "Zweite
Fassung — später" unten). Alle drei zählen erst mit, sobald sie im Backlog
geschätzt sind.

## Abgeleitete Sprintzahl

352 h ÷ 40 h = **9 Sprints** im günstigen Fall.
352 h ÷ 28 h = **13 Sprints** im ungünstigen Fall.

| | Erste Fassung | Gesamt |
|---|---|---|
| Sprints bei 40 h | 9 | 10 |
| Sprints bei 28 h | 13 | 14 |
| Wochen bei 40 h | 18 | 20 |
| Wochen bei 28 h | 26 | 28 |

Die Erhöhung des Prüfaufwands durch die Nachführung vom 2026-08-31 (344 h auf
352 h in der ersten Fassung, 367 h auf 370 h gesamt) ändert an dieser Tabelle
nichts: Bei Aufrundung auf volle Sprints bleiben 9, 13, 10 und 14 unverändert.
Das ist keine Ungenauigkeit, sondern dieselbe Rundungsregel wie zuvor.

**Was diese Zahlen nicht sind.** Kein Termin und keine Zusage. Sie sind eine
Ableitung aus einer Erstschätzung, die naturgemäss ungenau ist. Die Retrospektive
vergleicht je Sprint den geschätzten mit dem tatsächlichen Prüfaufwand und
kalibriert (6.8). Nach zwei bis drei Sprints ist die Zahl belastbar; vorher nicht.

**Wartezeiten sind eigene Positionen.** Die 80/20-Aufteilung beschreibt den
Umsetzungsanteil, nicht die Kalenderzeit. Der menschliche Anteil ist Review und
Freigabe und liegt damit auf dem kritischen Pfad: Jede Arbeitseinheit wartet auf
ihre Prüfung, bevor die nächste startet. Eine Roadmap, die das nicht ausweist,
ist systematisch zu optimistisch (6.8). Die Sprintzahlen oben enthalten diese
Wartezeiten bereits, weil sie aus Prüfstunden gerechnet sind.

**Zur früheren Zahl.** Die 13 Wochen des Konzeptdokuments gelten nicht mehr. Sie
kalkulierten mit Open WebUI, also mit einer Oberfläche, die nicht gebaut werden
musste (9.1). Die Grössenordnung der Verdopplung, die 9.1 zur Plausibilitäts-
prüfung nennt, bestätigt sich in dieser Schätzung.

**Nachführung 2026-08-26.** Befund F des Deep Reviews vom 2026-08-25 belegte
eine Lücke: ADR 0002 sicherte Eigenschaften zu, für die der Backlog kein
Abnahmekriterium führte. Der Product Owner hat acht neue Einträge eingeordnet
(`docs/05_Product_Backlog.md`, Stand 2026-08-26) und den Prüfaufwand von 300 h
auf 342 h (erste Fassung) angehoben. Die Sprintzahlen oben sind daraus neu
gerechnet, nicht fortgeschrieben.

**Zweite Nachführung 2026-08-26 (Koordinatorenprüfung).** Zwei unabhängige
Prüfinstanzen befanden die Einordnung von Befund F für nicht bestanden. Der
Product Owner hat R3-F-017 um ein zweites Abnahmekriterium ergänzt, das die
von ADR 0002, Abschnitt 3.7 zugesicherte Ursache prüft (keine
Werkzeugbeschreibung wird an das Modell übergeben) statt nur deren Wirkung;
der Prüfaufwand dieses Eintrags steigt von 8 h auf 10 h. R3-F-024 bleibt in
Etappe 1 mit selbstskalierend reformuliertem Abnahmekriterium; Einträge und
Prüfaufwand ändern sich dadurch nicht. Der Prüfaufwand der ersten Fassung
steigt von 342 h auf 344 h, der Gesamtaufwand von 365 h auf 367 h. Die
Sprintzahlen ändern sich dadurch nicht, weil die Rundung gleich bleibt.

**Nachführung 2026-08-31 (Scrum Master).** Auftrag war die Prüfung einer
gemeldeten Abweichung: Die Zahlen dieser Datei (344 h/79 Einträge erste
Fassung, 23 h/5 Einträge zweite Fassung, 367 h/84 Einträge gesamt) wichen von
der Summentabelle in `docs/05_Product_Backlog.md` (Stand 2026-08-31: 352 h/82,
18 h/4, 370 h/86) ab. Der Prüfaufwand ist Eintrag für Eintrag aus dem Backlog
nachgerechnet worden (Etappe für Etappe summiert, gegen jede
"Prüfaufwand:"-Zeile abgeglichen); jede Etappensumme trifft die
Backlog-eigene Summentabelle exakt — ein eigener Befund am Backlog ergibt
sich aus dieser Prüfung nicht.

Ein Abgleich über `git log` und `git show`, wie für diese Prüfung verlangt,
war nicht ausführbar: Das Arbeitsverzeichnis enthält kein `.git`, und dieser
Rolle steht kein Ausführungswerkzeug zur Verfügung. Ersatzweise wurde die
Vorversion rechnerisch aus den im Backlog selbst dokumentierten
Nachführungsvermerken rekonstruiert. **Nachtrag des Koordinators, mit `git`
belegt:** Die Rekonstruktion stimmt. `git show 549859f:docs/05_Product_Backlog.md`
— der Stand vom 2026-08-26 — führt "Erste Fassung, Summe 79 / 344 h",
"Zweite Fassung 5 / 23 h" und "Gesamt 84 / 367 h", also genau die Zahlen, die
diese Roadmap bis heute trug. Ergebnis: Die bisherigen Zahlen dieser
Roadmap entsprachen exakt dem Backlog-Stand unmittelbar nach der "Zweiten
Nachführung 2026-08-26" oben — dem Abschluss der Befund-F-Korrektur, nicht
einem misslungenen Zwischenstand. Jene Nachführung hatte ihr eigenes Ziel
erreicht. Die Abweichung entstand erst danach, weil der Backlog zweimal
weiter nachgeführt wurde, ohne dass diese Roadmap mitgezogen wurde:

- **Dritte Nachführung des Backlogs, 2026-08-31** (Einordnung des Vergleichs
  mit `valITino/claude-skills-fullstack`): drei neu geschätzte Einträge zur
  ersten Fassung, R3-Q-007 (Etappe 0, 3 h), R3-Q-008 (Etappe 0, 2 h) und
  R3-F-062 (Etappe 3, 3 h) — zusammen +3 Einträge, +8 h. Zwei weitere neue
  Einträge, R3-Q-009 (Etappe 0) und R3-F-029 (Etappe 1), erfüllen die
  Definition of Ready nicht und tragen keinen Prüfaufwand.
- **Vierte Nachführung des Backlogs, 2026-08-31** (unabhängige Prüfung des
  Backlog-Commits vom selben Tag): R3-F-094 auf Kano und Prüfaufwand offen
  gesetzt und aus der Summe der zweiten Fassung genommen — −1 Eintrag, −5 h.

Die Stand-Zeile dieser Datei blieb dabei auf "2026-08-26" stehen, obwohl der
Backlog seither zweimal weiter nachgeführt worden war. Der eigentliche Befund
ist deshalb nicht eine misslungene Nachführung am 2026-08-26, sondern eine
seither ausgebliebene Anschluss-Nachführung dieser Datei. Alle Zahlen dieser
Roadmap sind mit diesem Schritt auf den Backlog-Stand vom 2026-08-31 (vierte
Nachführung) gebracht; die abgeleiteten Sprint- und Wochenzahlen ändern sich
dadurch nicht (siehe "Abgeleitete Sprintzahl").

---

## Etappenfolge

Übernommen aus 6.8 und um die Oberfläche ergänzt. Die Etappe Gesichtserkennung
entfällt (5.18).

| # | Etappe | Prüfaufwand | Sprints bei 34 h | Voraussetzung |
|---|---|---|---|---|
| 0 | Vorlauf: Architekturentscheid, Umbenennung, Umgebungstrennung, Entwicklungs-Gates | 32 h | ~1 | Freigabe-Gate Schritt 4 |
| 1 | Fundament: Server, Protokoll, Datenbestand | 147 h | ~4 bis 5 | Etappe 0 |
| 2 | Freie Quellen ohne Beschaffung | 37 h | ~1 | Etappe 1 |
| 3 | Prototyp, Oberfläche, Anmeldestack | 66 h | ~2 | Prototyp-Freigabe für alles ab R3-F-051 |
| 4 | Darstellung und Export | 32 h | ~1 | Etappe 1, für den Graphen auch Etappe 3 |
| 5 | Lizenzierte Quellen | 8 h | <1 | Beschaffung durch den Auftraggeber |
| 6 | Härtung und Abnahme | 30 h | ~1 | alle vorherigen |
| — | Zweite Fassung | 18 h | ~1 | Entscheid nach der ersten Fassung |

Zahlen nachgerechnet gegen `docs/05_Product_Backlog.md`, Stand 2026-08-31
(Scrum Master).

### Warum diese Reihenfolge

**Etappe 1 vor allem anderen.** Nach Etappe 1 läuft ein System mit Datenbestand
und Protokollierung **ohne jede externe Abfrage**. Die Absicherungen aus 5.4
stehen damit vor der ersten echten Abfrage, nicht danach (6.8).

**Etappe 3 nach Etappe 2.** Die Oberfläche liegt nach den freien Quellen, damit
es beim Bau bereits echte Daten zum Anzeigen gibt statt Attrappen (6.8).

**Der Prototyp liegt vor Etappe 4.** Er blockiert die Etappen 1 und 2 nicht, weil
diese kein Frontend betreffen (6.8).

**Etappen 1 bis 3 können sofort beginnen**, sobald das Freigabe-Gate erteilt ist:
Sie setzen keine Beschaffung voraus (6.8).

### Einbettung des Prototyps

| Vorgabe | Umsetzung |
|---|---|
| Eigenes Sprint-Ziel | R3-F-050 ist alleiniges Ziel seines Sprints. Nicht nebenher in einem Sprint mitgeführt, in dem auch schon implementiert wird — er verlöre gegen die sichtbarere Arbeit (6.8) |
| Reihenfolge im Backlog | Einträge ab R3-F-051 haben eine Abhängigkeit auf die Prototyp-Freigabe und werden vorher nicht verfeinert und nicht geschätzt |
| Sprint Review als Prototyp-Review | Ergebnis ist entweder die Freigabe oder eine Liste konkreter Änderungen mit einem zweiten Durchgang |
| Zeitliche Einordnung | Nach Architekturentscheid und Grundgerüst (3.1), vor jedem Frontend-Inkrement. Backend- und Infrastrukturarbeiten laufen parallel |
| Kein Vorziehen | Wird Zeit frei, wird sie **nicht** für vorgezogenen Frontend-Code verwendet. Das würde das Gate aus 5.6 aushebeln |

---

## Schnitt in zwei lieferfähige Fassungen

Nach 9.1. Bei diesem Umfang ist ein Alles-oder-nichts-Termin riskant. **Vorschlag
des Product Owners an den Auftraggeber, keine Festlegung** — geschnitten wird
gemeinsam in Schritt 3.

### Erste Fassung — der Kernnutzen

Enthält die Basisfaktoren, ohne die das System unbrauchbar ist (6.4). Die
Tabelle ist eine thematische Auswahl der Kernbereiche; die Summenzeile zählt
alle Einträge der ersten Fassung, einschliesslich Etappe 0.

| Bereich | Einträge |
|---|---|
| Fundament: Server, kanonischer Datenbestand, beide Protokollspuren | R3-F-003 bis R3-F-012, R3-F-022, R3-F-027 |
| Ermittlungskreislauf mit Freigabesperre | R3-F-013 bis R3-F-017, R3-F-023, R3-F-026, R3-F-028, R3-F-060 |
| Anmeldung, Rollen, Klassifizierung | R3-F-051 bis R3-F-057 |
| Die freien Quellen ohne Beschaffung | R3-F-030 bis R3-F-040 |
| Fallverwaltung im Kern, Graph, Export | R3-F-001, R3-F-002, R3-F-024, R3-F-025, R3-F-058, R3-F-059, R3-F-072 bis R3-F-075 |
| Darstellung über Mermaid und draw.io | R3-F-070, R3-F-071 |
| Aufbewahrung, Löschwege, Offline-Betrieb | R3-F-020, R3-F-021 |
| Härtung und Abnahme | R3-C-010 bis R3-C-014 |
| **Summe** | **82 Einträge, 352 h Prüfaufwand** |

Nachgeführt am 2026-08-26 nach Befund F: sieben neue Einträge aus
`docs/05_Product_Backlog.md` sind den thematischen Zeilen zugeordnet
(R3-F-022, R3-F-027 zum Fundament; R3-F-023, R3-F-026, R3-F-028 zum
Ermittlungskreislauf; R3-F-024, R3-F-025 zu Fallverwaltung, Graph, Export).
R3-Q-006 ist — wie zahlreiche weitere Einträge der ersten Fassung, darunter
auch R3-Q-002 und R3-Q-003 — nicht einzeln in der obigen thematischen Tabelle
aufgeführt; diese Tabelle ist eine thematische Auswahl der Kernbereiche, keine
vollständige Liste (siehe Einleitung oben). Die Summenzeile zählt R3-Q-006
mit.

Nachgeführt am 2026-08-31 (Scrum Master) gegen den Backlog-Stand vom
2026-08-31: drei neue, im Backlog geschätzte Einträge sind in der Summenzeile
mitgezählt, aber ebenso wenig einzeln in der obigen Tabelle aufgeführt wie
R3-Q-006 — R3-Q-007 und R3-Q-008 (Etappe 0, aus dem Vergleich mit
`valITino/claude-skills-fullstack`) sowie R3-F-062 (Etappe 3, "Gesperrter
Gegenstand von nicht vorhandenem ununterscheidbar"). Zwei weitere neue
Einträge derselben Backlog-Nachführung, R3-Q-009 (Etappe 0) und R3-F-029
(Etappe 1), erfüllen die Definition of Ready nicht und tragen keinen
Prüfaufwand; sie zählen wie im Backlog nicht mit.

### Zweite Fassung — später

| Bereich | Eintrag | Prüfaufwand |
|---|---|---|
| Social-Media-Erweiterung (5.11) | R3-F-090 | 6 h |
| API-Zugang für Dritte (5.13) | R3-F-091 | 4 h |
| Diagnosebereich mit IT-Supporter-Skill (5.12) | R3-F-092 | 3 h |
| Reverse-Engineering-Bereich (5.14) | R3-F-093 | 5 h |
| Volle Fallverwaltung im Jira-Umfang | R3-F-094 | offen — nicht in der Summe |
| **Summe** | **4 Einträge** | **18 h** |

**Hinweis zur zweiten Fassung.** Sie ist mit 18 h auffällig klein gegenüber der
ersten. Das liegt daran, dass die Grundlagen — Protokoll, Klassifizierung,
Freigabesperre — bereits in der ersten Fassung stehen und die Nachzügler darauf
aufsetzen. R3-F-094 ist bewusst grob und erfüllt die Definition of Ready
derzeit nicht; seit der vierten Nachführung des Backlogs vom 2026-08-31 führt
er deshalb weder eine Kano-Einordnung noch einen Prüfaufwand und zählt nicht
in der Summenzeile — vorher war er mit 5 h als Leistungsfaktor mitgezählt.
Wird er beim Schneiden verfeinert und geschätzt, wächst die Summe der zweiten
Fassung entsprechend.

---

## Scrum-Rahmen

| Ereignis | Timebox bei zwei Wochen | Quelle |
|---|---|---|
| Sprint Planning | höchstens 4 Stunden | 6.8 |
| Daily Scrum | 15 Minuten | 6.8 |
| Sprint Review | höchstens 2 Stunden | 6.8 |
| Retrospektive | höchstens 1,5 Stunden | 6.8 |

**Commitments:** Product Goal für das Backlog, Sprint Goal für den Sprint
Backlog, Definition of Done für das Inkrement (6.8).

**Praktische Faustregel für die Sprintplanung:** Vor der Aufnahme eines Eintrags
wird der geschätzte **Prüfaufwand** notiert, nicht der Umsetzungsaufwand. Die
Summe darf 28 bis 40 Stunden nicht überschreiten (6.8).

**Die Retrospektive ist der Ort der Kalibrierung.** Sie vergleicht geschätzten
und tatsächlichen Prüfaufwand je Eintrag und korrigiert die Schätzungen.

---

## Was diese Roadmap blockiert

| Was | Blockiert | Wer löst es |
|---|---|---|
| Freigabe-Gate Schritt 4 | erledigt — Freigabe 2026-08-20 (`docs/08_Freigabe_Schritt_4.md`) | Auftraggeber |
| Architekturentscheid R3-C-001 | erledigt — ADR 0002 angenommen 2026-08-20 | Software Architect, Freigabe Auftraggeber |
| Prototyp-Freigabe R3-F-050 | alles ab R3-F-051 | Auftraggeber und Studienkollege |
| Beschaffung lizenzierter Quellen | nur Etappe 5 | Auftraggeber, Gruppenleitung |
| Anbindungsdaten Entra ID | nur den Wechsel auf den echten Mandanten, nicht die Entwicklung | KapoBE Informatik |
| Bestätigung der Fristenwerte (4.4) | nichts; gebaut wird mit den Startwerten | KapoBE, Bearbeitungsreglement |

**Punkt 7 der Bereitschaftsliste** — die Freigabe durch die zuständige Stelle der
Kantonspolizei Bern — ist der einzige, den der Auftraggeber nicht selbst abhaken
kann (5.16). Er steht am Ende der Etappe 6 und ist kein Backlog-Eintrag.
