# Roadmap

| | |
|---|---|
| **Arbeitsprodukt nach** | Projektauftrag 6.8, 9.1 |
| **Verantwortlich** | Product Owner, Scrum Master |
| **Stand** | 2026-08-20, nachgeführt (V-04 aus `docs/08_Freigabe_Schritt_4.md`) |

## Grundlage der Zahlen

Diese Roadmap enthält Zahlen, **weil der Prüfaufwand geschätzt ist**. Vor der
Schätzung in `05_Product_Backlog.md` wurde keine Kalenderzahl geschrieben (6.8).

| Grösse | Wert | Quelle |
|---|---|---|
| Prüfaufwand erste Fassung | 300 h | Backlog, 71 Einträge |
| Prüfaufwand zweite Fassung | 23 h | Backlog, 5 Einträge |
| Prüfaufwand gesamt | 323 h | Backlog, 76 Einträge |
| Sprintlänge | 2 Wochen | 6.8, festgelegt |
| Kapazität je Person | 7 bis 10 h pro Woche | 6.8, geklärt |
| Kapazität Team je Sprint | **28 bis 40 h** | 6.8 |

**Der Sprintumfang bemisst sich an der Prüfkapazität, nicht an der
Erzeugungskapazität** (6.8). Claude Code kann in einem Sprint mehr produzieren,
als in 28 bis 40 Stunden sorgfältig geprüft werden kann. Der Product Owner nimmt
deshalb nur so viel in den Sprint, wie das Team prüfen kann. Ein wachsender
Bestand ungeprüfter Inkremente ist bei einem Werkzeug mit Nachweispflicht die
gefährlichste Form von Fortschritt.

## Abgeleitete Sprintzahl

300 h ÷ 40 h = **8 Sprints** im günstigen Fall.
300 h ÷ 28 h = **11 Sprints** im ungünstigen Fall.

| | Erste Fassung | Gesamt |
|---|---|---|
| Sprints bei 40 h | 8 | 9 |
| Sprints bei 28 h | 11 | 12 |
| Wochen bei 40 h | 16 | 18 |
| Wochen bei 28 h | 22 | 24 |

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

---

## Etappenfolge

Übernommen aus 6.8 und um die Oberfläche ergänzt. Die Etappe Gesichtserkennung
entfällt (5.18).

| # | Etappe | Prüfaufwand | Sprints bei 34 h | Voraussetzung |
|---|---|---|---|---|
| 0 | Vorlauf: Architekturentscheid, Umbenennung, Umgebungstrennung, Entwicklungs-Gates | 27 h | ~1 | Freigabe-Gate Schritt 4 |
| 1 | Fundament: Server, Protokoll, Datenbestand | 113 h | ~3 bis 4 | Etappe 0 |
| 2 | Freie Quellen ohne Beschaffung | 37 h | ~1 | Etappe 1 |
| 3 | Prototyp, Oberfläche, Anmeldestack | 59 h | ~2 | Prototyp-Freigabe für alles ab R3-F-051 |
| 4 | Darstellung und Export | 26 h | ~1 | Etappe 1, für den Graphen auch Etappe 3 |
| 5 | Lizenzierte Quellen | 8 h | <1 | Beschaffung durch den Auftraggeber |
| 6 | Härtung und Abnahme | 30 h | ~1 | alle vorherigen |
| — | Zweite Fassung | 23 h | ~1 | Entscheid nach der ersten Fassung |

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
| Fundament: Server, kanonischer Datenbestand, beide Protokollspuren | R3-F-003 bis R3-F-012 |
| Ermittlungskreislauf mit Freigabesperre | R3-F-013 bis R3-F-017, R3-F-060 |
| Anmeldung, Rollen, Klassifizierung | R3-F-051 bis R3-F-057 |
| Die freien Quellen ohne Beschaffung | R3-F-030 bis R3-F-040 |
| Fallverwaltung im Kern, Graph, Export | R3-F-001, R3-F-002, R3-F-058, R3-F-059, R3-F-072 bis R3-F-075 |
| Darstellung über Mermaid und draw.io | R3-F-070, R3-F-071 |
| Aufbewahrung, Löschwege, Offline-Betrieb | R3-F-020, R3-F-021 |
| Härtung und Abnahme | R3-C-010 bis R3-C-014 |
| **Summe** | **71 Einträge, 300 h Prüfaufwand** |

### Zweite Fassung — später

| Bereich | Eintrag | Prüfaufwand |
|---|---|---|
| Social-Media-Erweiterung (5.11) | R3-F-090 | 6 h |
| API-Zugang für Dritte (5.13) | R3-F-091 | 4 h |
| Diagnosebereich mit IT-Supporter-Skill (5.12) | R3-F-092 | 3 h |
| Reverse-Engineering-Bereich (5.14) | R3-F-093 | 5 h |
| Volle Fallverwaltung im Jira-Umfang | R3-F-094 | 5 h |
| **Summe** | **5 Einträge** | **23 h** |

**Hinweis zur zweiten Fassung.** Sie ist mit 23 h auffällig klein gegenüber der
ersten. Das liegt daran, dass die Grundlagen — Protokoll, Klassifizierung,
Freigabesperre — bereits in der ersten Fassung stehen und die Nachzügler darauf
aufsetzen. R3-F-094 ist bewusst grob und wird beim Schneiden voraussichtlich
wachsen; er erfüllt die Definition of Ready derzeit nicht.

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
| Freigabe-Gate Schritt 4 | **alles** | Auftraggeber |
| Architekturentscheid R3-C-001 | Etappe 1 und alles danach | Software Architect, Freigabe Auftraggeber |
| Prototyp-Freigabe R3-F-050 | alles ab R3-F-051 | Auftraggeber und Studienkollege |
| Beschaffung lizenzierter Quellen | nur Etappe 5 | Auftraggeber, Gruppenleitung |
| Anbindungsdaten Entra ID | nur den Wechsel auf den echten Mandanten, nicht die Entwicklung | KapoBE Informatik |
| Bestätigung der Fristenwerte (4.4) | nichts; gebaut wird mit den Startwerten | KapoBE, Bearbeitungsreglement |

**Punkt 7 der Bereitschaftsliste** — die Freigabe durch die zuständige Stelle der
Kantonspolizei Bern — ist der einzige, den der Auftraggeber nicht selbst abhaken
kann (5.16). Er steht am Ende der Etappe 6 und ist kein Backlog-Eintrag.
