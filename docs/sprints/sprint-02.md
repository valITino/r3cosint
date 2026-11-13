# Sprint 2 der Etappe 1 — Sprint-Planungsartefakt, Vorlage zur Annahme durch den Auftraggeber

| | |
|---|---|
| **Arbeitsprodukt nach** | Projektauftrag 6.8 (Sprint Planning, Sprint Goal, Sprint Backlog), 3.3 (Umfang benennen, zerlegen, Zerlegung vorlegen), 6.7 (Walkthrough der Backlog-Einträge vor dem Sprint), 6.5 (Definition of Ready); `docs/06_Definition_of_Ready_und_Done.md`, Teil 1 und Teil 2; `docs/07_Roadmap.md` |
| **Entscheidet** | Auftraggeber (S-01), durch den Merge des Pull Requests der Einheiten D27 und S2 |
| **Vorbereitet** | 2026-11-10, Einheit S2: Scrum Master (dieses Artefakt, Zusammenführung), Product Owner (Sprint Backlog, Ready-Prüfung), Software Architect (Festlegung ADR 0008, Ermittlungskreislauf-Kern, Zerlegung), Requirements Engineer (Walkthrough sprint-02-walkthrough, Glossarvorschläge). Textprüfung: siehe Übergabe 2026-11-10_s2-etappe-1-sprint-2 (die Prüfung läuft nach der Abfassung dieses Artefakts) |
| **Weisung** | 2026-11-05, zweiter Formweg, Wortlaut: "Habe gemerged und mache weiter, auch mit meiner Weisung, einfach mit allem." (Angabe des Koordinators, Fremdbeleg; Lesart des Koordinators in ADR 0002, Abschnitt 10: Fortsetzung mit allen anstehenden Einheiten ohne weitere Weisung je Einheit) |
| **Status** | **angenommen** mit dem Merge des Pull Requests #58 am 2026-11-10 (Merge-Commit `6d517d1fb0c7dc2e2317d0181198edf06b8d4cd2`); Abschnitt 8 übertragen in der Einheit D28 |

## 1. Was diese Vorlage ist

Sprint 2 ist der zweite Sprint der Etappe 1 (Fundament: Server, Protokoll, Datenbestand). Sprint 1 ist vollständig abgenommen (Abschnitt 2). Diese Vorlage bündelt das Sprint Planning nach 6.8: Sprint-Ziel, Sprint Backlog mit Prüfaufwand gegen die Prüfkapazität von 28 bis 40 Stunden, Ergebnis der Ready-Prüfung und des Walkthroughs, Festlegung und Zerlegung in Baueinheiten, Ereignisplan, Hindernisliste und Entscheidungspunkte.

Drei Festlegungen zur Form, wie in Sprint 1:

1. **Schriftlich heisst committet.** Erteilt ist die Annahme mit dem Merge des Pull Requests der Einheiten D27 und S2, dessen Text sagt, dass der Merge die Annahme nach dieser Vorlage bedeutet (erster Formweg), oder durch eine Anweisung an die Sitzung im exakten Wortlaut, die die Sitzung in Abschnitt 8 überträgt (zweiter Formweg).
2. **Claude Code füllt Abschnitt 8 nicht aus.** Ein Merge ohne Kommentar gilt als Annahme mit den Empfehlungen je Entscheidpunkt in Abschnitt 7. Abweichende Entscheide stehen im Text oder in einem Kommentar des Pull Requests oder ergehen als Weisung im Wortlaut.
3. **Geprüft wird der benannte Stand.** Was nach dem Merge-Stand des Pull Requests committet wird, ist nicht Gegenstand dieser Annahme.

Die Einordnung aus E-R5-12 (c) gilt unverändert (Hindernis H-1): Kein Gate hält in der Cloud-Sitzung eine Schreibgrenze ein; die harte Linie sind die Kette auf der Gegenseite und die serverseitigen Regeln für main.

**Sprint-Ereignisse und Formwege** (wie in Sprint 1 angenommen, E-S1-17 a; Entscheidpunkt E-S2-10 bestätigt sie für Sprint 2):

| Ereignis nach 6.8 | Form in diesem Projekt |
|---|---|
| Sprint Planning | diese Vorlage; Annahme durch den Merge |
| Daily Scrum | der Abschnitt je Baueinheit in der Übergabe |
| Sprint Review | der Merge des Pull Requests der letzten Baueinheit (S2.4); Abnahme je Baueinheit durch den Merge ihres Pull Requests |
| Retrospektive | Abschnitt "Retrospektive Sprint 2" in der Übergabe, mit Massnahmen und Vergleich von geschätztem und tatsächlichem Prüfaufwand |

Die Timeboxes nach 6.8 (Sprint Planning höchstens 4 Stunden, Daily Scrum 15 Minuten, Sprint Review höchstens 2 Stunden, Retrospektive höchstens 1,5 Stunden) gelten für die menschliche Prüfzeit des Auftraggebers je Ereignis.

## 2. Ausgangslage

- **Stand des Repositories:** Merge-Commit `c2b187b8b2b2706b4a85ac404a1a23148cdcd884` (Merge des Pull Requests #57 am 2026-11-10, 04:43:34 UTC): Abnahme von S1.5, Bestätigung von D26, Entscheid E-D26-01 (a), Sprint Review von Sprint 1. Einheit D27 (Eintrag der Abnahme, Retrospektive Sprint 1) ist committet (Commit der Einheit `ad3f5681b6e2d6fab894055b583d2738093409ea`, Nachweis-Commit `2307ffa72cdd595689c698dd59fee3a335f68034`; Angaben des Koordinators, Fremdbeleg).
- **Ergebnis von Sprint 1:** R3-F-008, R3-F-012, R3-F-001, R3-F-003, R3-F-005 und R3-F-011 abgenommen am Tag 4 von 14. Gebaut sind core, spur, fall und kanon, die Revisionen 0001 bis 0005 und elf Importverträge; 1087 Tests, davon 193 Abnahmetests. make dod endet in der Form des Abnahmekriteriums (D9 einzige Lage C bis R3-C-004) in etwa 230 bis 310 s. Prüfaufwand Sprint 1: 31 h nach dem Stand der Annahme, 37 h nach den Neubewertungen (Angaben des Koordinators, Fremdbeleg).
- **Umgebung:** Der Docker-Daemon ist nach jedem Neustart der Maschine neu zu starten (Hindernis H-3); die Images liegen vor. Die Kette auf der Gegenseite ist bis R3-C-004 gewollt rot (H-2).
- **Etappe 1 nach dem Backlog:** 29 geschätzte Einträge; Sprint 1 hat sechs gebaut. Prüfkapazität je Sprint 28 bis 40 Stunden (6.8).
- **Kalibrierung nach der Retrospektive Sprint 1 (Massnahme M-7):** Sprint 1 lag im Mittel 19 Prozent zu niedrig (31 h Planung gegen 37 h Neubewertung; der tatsächliche Prüfaufwand liegt nur als Ersatzmass Wartezeit vor). Planungssumme Sprint 2 deshalb 28 bis 33 h; Neubewertung nach der Festlegung höchstens 40 h; die Spanne mit Mehraufwand weist die Retrospektive aus. Ersatzmass für den tatsächlichen Prüfaufwand bleibt die Wartezeit vom Anlegen des Pull Requests bis zum Merge.
- **Hypothese des Koordinators und Entscheid des Product Owners:** Sprint 2 baut den Kern des Ermittlungskreislaufs als Dienstschicht ohne HTTP, ohne Sprachmodell und ohne echte Quelle. Der Product Owner hat die Hypothese bestätigt, keinen Eintrag gestrichen oder hinzugefügt. Massstab (aus Sprint 1): Ein Eintrag gehört nur hinein, wenn sein Abnahmetest nach dem Wortlaut am Ende des Sprints grün sein kann, ohne Teile des Kriteriums auszulassen.

**Was Sprint 2 nicht enthält** (Product Owner, Fassung nach dem Entscheid des Koordinators nach 3.4; Kandidaten ab Sprint 4 sind als "Folge-Sprint" mit Bedingung geführt):

| Kennung | h | Grund | Kandidat |
|---|---|---|---|
| R3-F-020 | 8 | präskriptiv (4.4), wird terminiert, nicht wegpriorisiert; Löschkonzept-Punkt 4 offen | Sprint 3 (terminiert) |
| R3-F-018 | 4 | Zwischenschicht zum Sprachmodell; Voraussetzung von R3-F-017 und R3-F-023 | Sprint 3, zuerst |
| R3-F-017 | 10 | Prüfsatz gegen das Modell; nach R3-F-018 | Sprint 3 |
| R3-F-023 | 5 | Modellantworten; nach R3-F-018 | Sprint 3 |
| R3-F-027 | 6 | das Modul api hat keine Route; Obergrenzen unbestätigt | Folge-Sprint, sobald api eine Route hat (R3-F-019) |
| R3-F-024 | 5 | selbstskalierend; kein Ablageweg, grün ohne Aussage | Folge-Sprint, mit dem ersten Ablageweg |
| R3-F-004 | 6 | Rundlauf MISP-Import (Etappe 2) und STIX-Export (Etappe 4); in Etappe 1 nie grün | Folge-Sprint, nach Schnitt (B4) |
| R3-F-006, R3-F-007, R3-F-010 | 5 je | verlangen Berichtsentwurf, Darstellung oder den Durchlauf mit Modell | nicht Sprint 3; R3-F-007 Folge-Sprint nach R3-F-013, R3-F-014, R3-F-017 und R3-F-018; R3-F-006 ab Etappe 4; R3-F-010 mit dem Durchlauf mit Modell |
| R3-F-013 | 6 | setzt MCP-Server, Anbieterschlüssel und Anmeldung (R3-F-051, Etappe 3) voraus | Folge-Sprint, nicht vor der Anmeldung; Etappenfrage H-19 |
| R3-F-019 | 4 | Setup; erst mit Modell und MCP-Server aussagekräftig; trägt Vormerkungen GS-52 bis GS-54, SR-029 | Folge-Sprint, mit R3-F-013 und R3-F-018 |
| R3-F-021, R3-F-022 | 3, 6 | Graph und Export fehlen; keine Quelle | nach Schnitt oder Etappe 4; mit der ersten Quelle |
| R3-C-006, R3-Q-002 | 4 je | verlangen vollständigen Durchlauf und Berichtsentwürfe | spät in Etappe 1 |
| R3-F-029 | offen | nicht ready, ungeschätzt | unverändert, Backlog Punkt 13 |

Vorschlag des Product Owners für Sprint 3, keine Festlegung: R3-F-020, R3-F-018, R3-F-017, R3-F-023, zusammen 27 h (unter der Untergrenze 28 h; die Planung von Sprint 3 findet einen weiteren Eintrag oder wartet die Neubewertung ab; R3-F-013 kommt als Füller in Frage, wenn die Etappenfrage H-19 es zulässt).

## 3. Sprint-Ziel

Commitment nach 6.8 (Product Owner, Vorschlag; Wortlaut unverändert, Scrum Master hält ihn fest):

> Am Ende von Sprint 2 lässt sich in Test/Schulung auf Modulebene eine Abfrage eines registrierten Werkzeugs für einen eröffneten Fall nur über eine Freigabe ausführen und nur gegen eine freigegebene Gegenstelle (auch nicht über Weiterleitung, zweite Namensauflösung oder umgeschriebene IP-Adresse), ein Aufruf ohne gültigen Fall, am Verzeichnis vorbei, ohne Freigabe-Kennung oder über der Kontingentgrenze wird abgewiesen, und eine Abfrage mit leerem Ergebnis steht als Negativbefund im Protokoll.

Überprüfbar an den benannten Abnahmetests der sieben Einträge (zehn Tests nach dem Product Owner) und am Lauf von make dod. Nicht Teil des Ziels: HTTP-Endpunkte, Anmeldung und "interaktive Sitzung" (Grenze GK-3), Sprachmodell, echte Quelle, Schemaprüfung der Quellantwort, Löschweg, Setup. Grenzen der Festlegung: GK-1 bis GK-17 in ADR 0008; die wichtigsten sind GK-1 (keine Prozessgrenze zwischen Vorschlag, Freigabe und Ausführung), GK-2 (ausgang ist ein Modul, kein Container) und GK-3 (ob ein Mensch bestätigt hat, ist vor der Anmeldung nicht prüfbar).

## 4. Sprint Backlog

### 4.1 Einträge und Prüfaufwand

Geordnet nach Baueinheit (Reihenfolge der Festlegung, Abschnitt 5). Stakeholder nach der Satzschablone des Eintrags (Product Owner).

| Pos. | Kennung | Titel | Planung | Neubewertung | Stakeholder (R1) | Ready | Baueinheit |
|---|---|---|---|---|---|---|---|
| 1 | R3-F-015 | Positivliste nach aussen | 3 h | 4 h | S-05 Administrator | ready mit Vorbehalt nach R1 | S2.1 |
| 2 | R3-F-028 | Positivliste nach aussen: Weiterleitung, Namensauflösung, IP-Literale | 6 h | 8 h | S-05 Administrator | ready mit Vorbehalt nach R1; Annahme drei Weiterleitungsschritte (E-S2-04) | S2.1 |
| 3 | R3-F-026 | Werkzeugverzeichnis: Vollständigkeit und Inhalt je Eintrag | 5 h (Backlog 4 h, 1 h Vormerkung DF-S15-D16-01) | 6 h | S-05 Administrator | ready mit Vorbehalt nach R1; Vormerkung als drittes Kriterium (B4) | S2.2 |
| 4 | R3-F-002 | Fallbindung: kein Werkzeug ohne Fall | 3 h | 4 h | S-06 Datenschutzbeauftragter (Aufsicht) | ready mit Vorbehalt nach R1, seit die Festlegung Q-PO-1 beantwortet | S2.2 |
| 5 | R3-F-014 | Freigabesperre zwischen Vorschlag und Ausführung | 8 h | 10 h | S-03 Ermittelnde | ready mit Vorbehalt nach R1; Grenze GK-3 | S2.3 |
| 6 | R3-F-016 | Kontingentgrenzen je Fall und je Tag | 3 h | 4 h | S-04 Dezernats- und Gruppenleitung | ready mit Vorbehalt nach R1; Annahmen UTC, Vorschau als Datenstruktur | S2.4 (Zähler in S2.2 gebaut) |
| 7 | R3-F-009 | Negativbefunde erscheinen zwingend | 3 h | 4 h | S-08 Verteidigung und Gericht (mittelbar) | ready mit Vorbehalt nach R1 | S2.4 |

Alle sieben Einträge sind Basisfaktoren. Die Bauordnung der Festlegung weicht von der Hypothese des Koordinators ab (Abschnitt 5, Entscheidpunkt E-S2-09). Die Ready-Prüfung R1 bis R10 mit allen Einzelbefunden liegt beim Product Owner (Übergabe); hier übernommen ist sein Ergebnis.

**Summe und Nachweis:**

- **Planung:** 3 + 6 + 5 + 3 + 8 + 3 + 3 = **31 Stunden**. Innerhalb 28 bis 33 h (M-7) und innerhalb 28 bis 40 h (6.8); Reserve 2 h bis 33 h, 9 h bis 40 h.
- **Neubewertung nach der Festlegung des Software Architects:** 4 + 8 + 6 + 4 + 10 + 4 + 4 = **40 Stunden**. Innerhalb 28 bis 40 h, genau an der Obergrenze, ohne Reserve. Die Neubewertung ist Vorschlag des Software Architects an den Product Owner (ADR 0008); der Product Owner hat sie entschieden und führt sie im Backlog (Nachführung Nr. 75, Angabe des Koordinators, Fremdbeleg).
- **Verschiebungsregel:** Steigt der Prüfaufwand einer Einheit vor deren Bau über die neu bewerteten Werte (jede Erhöhung, auch um 1 h), wird R3-F-009 (4 h) nach Sprint 3 verschoben; R3-F-016 bleibt, weil sein Zähler in S2.2 gebaut ist. Entscheid des Product Owners (Bericht, Nachtrag "Nach der Festlegung", (b); Angabe des Koordinators, Fremdbeleg), vermerkt in Nachführung Nr. 75 und in der Stand-Zeile von R3-F-009; Entscheidpunkt E-S2-08.
- **Nachtrag vom 2026-11-10 (Einheit S2.1, zweite Neubewertung; Angaben des Koordinators, Fremdbeleg):** Nach der Festlegung von S2.1 hat der Product Owner R3-F-028 von 8 h auf 10 h neu bewertet (Nachführung Nr. 78 des Backlogs; R3-F-015 bleibt 4 h; beide ready ohne Vorbehalt). Damit ist die Verschiebungsregel (E-S2-08 a) ausgelöst: R3-F-009 (4 h) geht nach Sprint 3. Sprint 2 liegt bei 40 - 4 + 2 = **38 Stunden**, nachgerechnet an den Positionen: 4 + 10 + 6 + 4 + 10 + 4 = 38 (R3-F-015, R3-F-028, R3-F-026, R3-F-002, R3-F-014, R3-F-016); innerhalb 28 bis 40 h, Reserve 2 h. Der angenommene Stand (sieben Einträge, 40 h) bleibt oben lesbar; die Tabelle zeigt ihn unverändert, Pos. 7 (R3-F-009) gilt seit dem Nachtrag als nach Sprint 3 verschoben, die Neubewertung von Pos. 2 (R3-F-028) als 10 h.
- Das Fundament ohne eigenen Eintrag (Modul ausgang, Testgegenstelle, Prüfwerkzeug, Teststufe) ist wie in Sprint 1 nicht bewertet, aber mitgeprüft. Ob der Prüfaufwand der Rollen ausser dem Auftraggeber im Prüfaufwand der Einträge enthalten ist, ist "gedacht", nicht belegt; die Retrospektive kalibriert.

### 4.2 Ready-Prüfung (Übernahme)

Die Ready-Prüfung des Product Owners (Ergebnis wörtlich übernommen, Einzeltabellen im Bericht, Übergabe): Sprint 1 ist abgenommen, R3-Q-005 ausgesetzt (kein Eintrag hängt daran). **R1:** Der Stakeholder ist aus der Satzschablone benannt; eine unmittelbare Abstimmung ist für keinen der sieben Einträge belegt, belegt ist die pauschale Freigabe durch S-01 am 2026-08-20. Alle sieben Einträge sind deshalb **ready mit Vorbehalt nach R1**; der Vorbehalt entfällt mit dem Merge der Vorlage (Entscheidpunkt E-S2-11, wie E-S1-20). **R3** mit Hinweis bei R3-F-014, R3-F-015, R3-F-016 und R3-F-028 (Freigabevorschau, Freigabe-Kennung, Gegenstelle, Weiterleitung hatten keinen Glossareintrag; der Requirements Engineer hat fünf gekennzeichnete Vorschläge in docs/03_Glossar.md eingetragen: Freigabe-Kennung, Freigabevorschau, Gegenstelle, Verbindungsversuch, Werkzeug, am 2026-11-10 an ADR 0008 angeglichen; die Vorlage E-D27-01 steht im Text des Pull Requests). **R6:** Notation nach docs/06 ist Vorschlag und gilt für neue Kriterien. **R7 bis R10:** erfüllt.

**R3-F-002:** Der Product Owner führte den Eintrag in seinem Bericht als nicht ready, bis die Festlegung Q-PO-1 beantwortet (Wohin protokolliert ein Aufruf ohne gültigen Fall, was ist ein gültiger Fallbezug). Die Festlegung beantwortet sie (ADR 0008, Entscheid 6 und 7, E-S2-01): gültig ist allein Zustand aktiv; Fall besteht, nicht aktiv: Eintrag abweisung in der Arbeitsspur dieses Falls; kein Fall: Zeile in einer Tabelle betriebsprotokoll ohne Parameter. R3-F-002 ist damit ready mit Vorbehalt nach R1 (Bericht des Product Owners, Nachtrag "Nach der Festlegung", (a); Angabe des Koordinators, Fremdbeleg). Der Ort je Lage wird vom Requirements Engineer als Zeile Achtung nachgetragen (B4, vor S2.2).

### 4.3 Ergebnis des Walkthroughs (Requirements Engineer)

Befundliste ohne Lösungsvorschlag: sprint-02-walkthrough (neue Datei dieser Einheit). **80 Befunde W2-01 bis W2-80: 11 blockierend, 55 Nachbesserung, 14 Hinweis.** Davon betreffen die sieben Einträge und den Querschnitt 69 Befunde (7 blockierend, 50 Nachbesserung, 12 Hinweis); die Reserve (R3-F-027, R3-F-024, R3-F-020, R3-F-004, nicht gezogen) 11 (4, 5, 2). Sechs Befunde sind für die GRC-Rolle gekennzeichnet (W2-21, W2-28, W2-34, W2-38, W2-69, W2-77).

| Eintrag | blockiert | Nachbesserung | Hinweis |
|---|---|---|---|
| R3-F-026 | 1 | 9 | 2 |
| R3-F-002 | 2 | 4 | 1 |
| R3-F-009 | 1 | 5 | 1 |
| R3-F-014 | 2 | 7 | 0 |
| R3-F-015 | 0 | 5 | 1 |
| R3-F-016 | 0 | 7 | 1 |
| R3-F-028 | 1 | 8 | 2 |
| Querschnitt | 0 | 5 | 4 |
| **Summe Sprint Backlog und Querschnitt** | **7** | **50** | **12** |

**Die sieben blockierenden Befunde sind Lesarten, die die Festlegung auflöst** (Muster wie W1-83 in Sprint 1; 6.7: der Walkthrough löst sie nicht):

| Befund | Gegenstand | Auflösung in ADR 0008 |
|---|---|---|
| W2-01, W2-13 | "Werkzeug" ohne Quelle; ob das synthetische Prüfwerkzeug zählt (R3-F-026, R3-F-002) | Entscheid 2; Ort des Prüfwerkzeugs: E-S2-02 |
| W2-14 | "protokolliert" bei einem Aufruf ohne gültigen Fall | Entscheid 7; Ort: E-S2-01 |
| W2-20 | welche "Abfrage" bei R3-F-009 | Entscheid 19 |
| W2-27 | Lesart "kein Codepfad" bei R3-F-014 | Entscheid 12 |
| W2-28 | menschliche Bestätigung ohne Anmeldung (GRC) | Entscheid 13, als Grenze GK-3 |
| W2-54 | Testgegenstelle im privaten Bereich gegen die Bereichsregel | Entscheid 15; E-S2-03 |

Die übrigen Nachbesserungen und Hinweise löst die Festlegung teils auf (Zuordnung je Befund in ADR 0008); nicht aufgelöst und beim Requirements Engineer bleiben W2-19 und W2-61 bis W2-65 (Glossar, Stakeholder "Aufsicht"). Sie kommen, soweit gewünscht, als Fortschreibung der Einträge über den Product Owner (B4); die Eintragsblöcke des Backlogs bleiben in dieser Einheit byte-gleich ausser angefügten Stand-Zeilen (Entscheidpunkt E-S2-12).

## 5. Festlegung und Zerlegung in Baueinheiten mit Reihenfolge (3.3)

**Festlegung:** Software Architect, ADR 0008 (Ermittlungskreislauf-Kern; Status vorgeschlagen; Teil A Stand, Teil B Entscheidlog; nicht gebaut): Entscheide 1 bis 25, Entscheidpunkte E-S2-01 bis E-S2-07, Vorgaben des Datenschutzexperten und Hinweise der GRC-Rolle, Schnittstelle, Verträge 11 bis 15, Teststufen, Zerlegung, Neubewertung, Grenzen GK-1 bis GK-17. Die Annahme dieser Vorlage nimmt ADR 0008 an. **Fortschreibungen angenommener Entscheide von ADR 0007**, die mit der Annahme gelten: Entscheid 9 (Rechte neuer Tabellen), Entscheid 14 (sechs neue Eintragstypen der Arbeitsspur: verbindungsversuch, abweisung, abfrage, negativbefund, vorschlag, freigabe), Entscheid 25 (werkzeug gegen das Verzeichnis), Entscheid 26 (Positivliste der Klartexttabellen um freigabevorlage), Vertrag 9 (Schichtung) und Grenze GS-47. In ADR 0002, 4.3, trägt der Protocol Master die Verträge 11 bis 15 nach.

**Gemeinsam für alle Einheiten:** Je Einheit ein Pull Request, Merge = Abnahme. Der Backend Engineer baut Code und Einheits- und Integrationstests; der Dynamic Software Tester schreibt die Abnahmetests vor dem Bau und verifiziert am Endstand mit Mutationslauf (Wiederherstellung nach Mutationen allein über gesicherte Bytes mit Prüfsumme, M-2); der Static Software Tester prüft den ganzen Diff auf einem anderen Modellfeld; wer baut, prüft nicht (3.4). Abnahmekriterium jeder Einheit: make dod am stillen Endstand in der Form des Abnahmekriteriums (D9 einzige Lage C), die Abnahmetests der Einheit gesammelt grün, ihre Zeilen aus `scripts/abnahme-ausnahmen.txt` entfernt, D6 100 % für die kritischen Module (neu beschaffung und ausgang), D18 ohne Bruch, jede Mutation erkannt oder als äquivalent begründet, Prüfbericht D16 trägt. Aufträge an Rollen werden nach Prüfgegenstand geschnitten, Zwischenstand als Datei vor der Zuggrenze (M-1).

| Einheit | Gegenstand | Einträge (Abnahme) | Prüfaufwand (neu) | Rollen ausser Bau und Prüfung |
|---|---|---|---|---|
| S2.1 Modul ausgang | httpx als Laufzeitabhängigkeit (E-S2-06), Positivliste, Ziel, Auflösung, Client; Revision 0006 (vier Typen); Testgegenstelle; Vertrag 13; Restpunkt DT-S15-01 | R3-F-015, R3-F-028 | 12 h | SecDevOps Engineer (Lieferkette httpx); Datenschutzexperte; GRC-Rolle (F-04) mit Legal Reviewer; D16; DevOps Engineer; Requirements Engineer (B4) |
| S2.2 Modul beschaffung | Verzeichnis, Aufrufkontext, Aufrufpfad mit Fallbindung, Zähler (gebaut, Abnahme in S2.4); Revision 0007 (kontingent, betriebsprotokoll); Prüfwerkzeuge im Testbaum (E-S2-02); kanon: zulaessige_werkzeuge; Verträge 13 und 14 | R3-F-026 (mit drittem Kriterium), R3-F-002 | 10 h | Datenschutzexperte (B-05); GRC-Rolle (F-02); D16; DevOps Engineer; Requirements Engineer (B4) |
| S2.3 Modul freigabe | Eingabe, Vorschlag, Erteilung, Ausführung; Revision 0008 (freigabevorlage; Typen vorschlag, freigabe); Verträge 11, 12, 15; Konfigurationstest | R3-F-014 | 10 h | SecDevOps Engineer; Datenschutzexperte (B-04); GRC-Rolle (F-03) mit Legal Reviewer; D16; Requirements Engineer (B4) |
| S2.4 Kontingent und Negativbefund | Abnahme des Zählers mit Vorschau; negativbefund im Aufrufpfad; Nebenläufigkeitsprobe; Abschnitt 7 der Konformitätsanalyse | R3-F-016, R3-F-009 | 8 h | GRC-Rolle (F-05) und Legal Reviewer; Datenschutzexperte; D16; Requirements Engineer (B4 zu R3-F-009) |

Summe der Spalte Prüfaufwand: 12 + 10 + 10 + 8 = 40 h (gleich Abschnitt 4.1).

**Nachtrag vom 2026-11-10 (Einheit S2.1; Angaben des Koordinators, Fremdbeleg; Übergabe `docs/uebergaben/2026-11-10_s2-etappe-1-sprint-2.md`, Abschnitt "Einheit S2.1"):** S2.1 ist am 2026-11-10 in den Teilen S2.1.1 bis S2.1.5 gebaut und verifiziert und mit dem Pull Request der Einheiten D28 und S2.1 zur Abnahme vorgelegt (abgenommen erst mit dem Merge). Prüfaufwand nach der zweiten Neubewertung 14 h (R3-F-015 4 h, R3-F-028 10 h; vorher 12 h). S2.4 enthält nach der Verschiebung von R3-F-009 nach Sprint 3 allein R3-F-016 (Kontingent, 4 h; vorher 8 h). Summe nach dem Nachtrag: 14 + 10 + 10 + 4 = 38 h (gleich dem Nachtrag in Abschnitt 4.1 dieses Dokuments). Die Zeilen der Tabelle oben zeigen den angenommenen Stand.

**Nachtrag vom 2026-11-13 (Einheit D29; Angaben des Koordinators, Fremdbeleg):** S2.1 (Modul ausgang; R3-F-015 und R3-F-028) ist abgenommen mit dem Merge des Pull Requests #59 der Einheiten D28 und S2.1 am 2026-11-13 um 09:18:57 UTC (Merge-Commit `2b3926f36d584d42f1c9bdbba6ee860d273d34f7`; erster Formweg, ohne Kommentar des Auftraggebers, ohne Review). Zugleich D28 bestätigt, E-D28-01 (a) und V-F04-1 (a) entschieden, die Fortschreibungen von ADR 0008 mit den Grenzen GK-18 bis GK-35, die Verschiebung von R3-F-009 nach Sprint 3 und der Registerentscheid angenommen. Offen im Sprint: S2.2 (R3-F-026, R3-F-002), S2.3 (R3-F-014), S2.4 (R3-F-016). Summe der offenen Einheiten nach dem Nachtrag vom 2026-11-10: 10 + 10 + 4 = 24 h.

**Abnahmekriterium zusätzlich je Einheit** (Auszug, massgeblich ADR 0008): S2.1 eine Gegenstelle ausserhalb der Liste zählt keine Verbindung, Protokoll der Bibliothek ohne URL; S2.2 das Prüfwerkzeug unmittelbar aufgerufen erreicht die Gegenstelle nicht, ein formgültiges, nicht registriertes werkzeug wird in kanon abgewiesen; S2.3 eine gültige Kennung läuft genau einmal, eine eingebrachte Variable ändert nichts; S2.4 zwei gleichzeitige Ausführungen an der Grenze: genau eine läuft, Treffer und HTTP 500 erzeugen keinen negativbefund.

**Reihenfolge und Begründung** (Software Architect): ausgang zuerst, weil er keine Voraussetzung ausser spur hat und der Aufrufpfad den Client und die Gegenstelle braucht; beschaffung vor freigabe, weil die Ausführung den Aufrufpfad ruft; der Zähler wird in S2.2 gebaut und erst in S2.4 abgenommen, weil "erscheint in der Freigabevorschau" die Vorlage aus S2.3 braucht; R3-F-009 zuletzt, weil es den ganzen Pfad braucht. **Abweichung von der Hypothese des Koordinators** (Verzeichnis zuerst) und von der Bauordnung des Product Owners (R3-F-026 zuerst): Folge: die Abnahmezeile von R3-F-016 steht erst in S2.4, obwohl sein Zähler in S2.2 gebaut ist (Entscheidpunkt E-S2-09). Fällt eine Einheit nach 3.4, bleibt die vorherige abnehmbar. Keine Einheit läuft neben einer anderen.

**Messungen vor dem Bau** (ADR 0008, Teil A, "Offene Punkte"; Hindernis H-20): httpx-Transport gegen eine vorgegebene Adresse (Backend Engineer mit der Lieferkettenprüfung des SecDevOps Engineers, vor S2.1); Vorrat der Klassen von ipaddress als Liste und Testkonstante mit is_global wahr (Dynamic Software Tester beim Schreiben der Abnahmetests, vor S2.1; die Dokumentationsbereiche sind bereits gemessen); Verhalten von spur.service.anfuegen gegenüber dem Fallzustand (Backend Engineer am Code, vor S2.2).

**D13 bis D17 je Einheit:** D13, D14 und D15 gelten für alle vier Einheiten. D16 (Prüfbericht des Digital-Forensics-Spezialisten) ist in allen vier berührt (neue Eintragstypen: S2.1 verbindungsversuch und abweisung, S2.2 abfrage und abweisung, S2.3 vorschlag und freigabe, S2.4 negativbefund). D17 (präskriptiver Teil) ist nach der Lesart von Sprint 1 nicht berührt, soweit 4.4 umgesetzt und nicht geändert wird; die Fortschreibung von R3-F-020 (Entscheidpunkt E-S2-15) ändert ein Kriterium von 4.4 und geht an GRC-Rolle und Auftraggeber (6.6).

## 6. Ereignisplan und Hindernisliste

### 6.1 Ereignisplan

Sprintbeginn (Tag 0) ist der Merge des Pull Requests der Einheiten D27 und S2, der Pull Request #58, am 2026-11-10 um 08:19:04 UTC; Tag 14 ist der 2026-11-24 oder die Abnahme der letzten Baueinheit, je nachdem, was zuerst eintritt (nachgeführt mit der Einheit D28). Einheiten, die am Sprintende nicht abgenommen sind, gehen in die Planung von Sprint 3 zurück; ein halbfertiger Zustand wird nicht als erledigt geführt (3.3). Je Ereignis steht hier nur Ergebnis und Verweis (M-6); das Fortschrittsprotokoll steht in der Übergabe.

| Ereignis | Form | Timebox (6.8) | Ergebnis und Verweis |
|---|---|---|---|
| Sprint Planning | diese Vorlage; Annahme durch den Merge | höchstens 4 h Prüfzeit | vorgelegt 2026-11-10; angenommen mit dem Merge des Pull Requests #58 am 2026-11-10 um 08:19:04 UTC (Tag 0); Verweis: Abschnitt 8 und Abschnitt 9; Wartezeit: Abschnitt 9 und Übergabe 2026-11-10_s2-etappe-1-sprint-2, Abschnitt D28 |
| Daily Scrum | Abschnitt je Baueinheit in der Übergabe | 15 min Prüfzeit je Eintrag | Verweis: Übergabe 2026-11-10_s2-etappe-1-sprint-2, Abschnitte S2.1 bis S2.3 und S2.4 (ohne R3-F-009); Fortschrittsprotokoll und Wartezeit je Merge nur dort |
| Daily Scrum, S2.1 | wie oben | wie oben | begonnen am 2026-11-10 nach dem Commit von D28, am selben Tag gebaut und verifiziert; zur Abnahme vorgelegt mit dem Pull Request der Einheiten D28 und S2.1 (Tag 0 von 14); Verlauf: Übergabe, Abschnitt "Einheit S2.1" |
| Abnahme S2.1 | Merge des Pull Requests #59 (Einheiten D28 und S2.1) | im Rahmen des Sprint Review | abgenommen am 2026-11-13 um 09:18:57 UTC (Tag 3 von 14, 3 Tage 0 h 59 min 53 s nach Tag 0; Merge-Commit `2b3926f36d584d42f1c9bdbba6ee860d273d34f7`; ohne Kommentar, ohne Review); Wartezeit vom Anlegen bis zum Merge 68 h 26 min 4 s als Ersatzmass (der Auftraggeber nannte keinen Prüfaufwand; Angaben des Koordinators); Verweis: Abschnitt 9 und Übergabe, Abschnitt D29 |
| Abnahme je Baueinheit | Merge des Pull Requests der Einheit | im Rahmen des Sprint Review | je Einheit; Wartezeit als eigene Position in der Übergabe (Ersatzmass) |
| Sprint Review | Merge des Pull Requests von S2.4 | höchstens 2 h Prüfzeit | Ergebnis und Datum folgen mit dem Merge |
| Retrospektive | Abschnitt "Retrospektive Sprint 2" in der Übergabe | höchstens 1,5 h Prüfzeit | Ergebnis folgt; Vergleich Planung 31 h, Neubewertung 40 h, zweite Neubewertung 38 h (ohne R3-F-009) und Wartezeit |

**Wartezeiten auf menschliches Review liegen auf dem kritischen Pfad** (6.8) und werden als eigene Positionen ausgewiesen: Fünf Merges (Pull Request der Einheiten D27 und S2 sowie vier Baueinheiten) stehen in strenger Reihenfolge; jede Wartezeit ist eine Position der Übergabe, nicht Teil der Bauzeit.

### 6.2 Hindernisliste (Stand 2026-11-13)

Entscheid zur Nummerierung: Die Nummern aus Sprint 1 werden fortgeführt (H-1 bis H-15 bleiben unter ihrer Nummer, neue ab H-16), damit der Verlauf in der Übergabe von Sprint 1 verfolgbar bleibt. Beobachtung PR-1 aus Sprint 1 wird mit Massnahme M-2 als eigene Zeile übernommen (Nummer PR-1 beibehalten). Aufgelöste Hindernisse aus Sprint 1 (H-5 bis H-10, H-12 und H-14) werden nicht übernommen; H-13 trägt in Sprint 1 den Stand "beobachtet" und das Abschlussdatum "offen" und wird übernommen.

| Nr. | Hindernis | Betroffene Rolle | Datum | Stand | Nächster Schritt | Abschlussdatum |
|---|---|---|---|---|---|---|
| H-1 | Projekt-Hooks laufen in der Cloud-Sitzung nicht (R3-Q-005 ausgesetzt, SR-024 offen); Rollen-Schreibgrenzen sind Instruktion (E-R5-12 c) | alle schreibenden Rollen; SecDevOps Engineer | 2026-11-05 | offen; Messaufbau auf main | Meldung des Auftraggebers, dass die Umgebung die Projekt-Hooks ausführt; dann R5.1b einmal wiederholen | offen |
| H-2 | Kette auf der Gegenseite rot bis R3-C-004 (gewollt; Urteil am Rückgabewert von make dod ohne Liste der terminierten Lagen) | DevOps Engineer; Auftraggeber | 2026-11-05 | gewollt, kein Fehler | Rückgabewert und Lagezeilen je Pull Request prüfen (D9 einzige Lage C) | mit R3-C-004 |
| H-3 | Docker-Daemon ist nach jedem Neustart der Maschine neu zu starten, achtmal belegt (achter Neustart beim Aufwecken am 2026-11-13, erstmals neu aufgesetzt: Arbeitsablage und Images verloren, Python-Umgebung, gitleaks und Git-Historie fehlten; Docker lief, vom Setup-Skript gestartet; vom Koordinator wiederhergestellt: Historie und gitleaks über die Hooks von Hand, drei Images über den Digest); Vorlagen M-G21-01 und "Daemon beim Aufwecken" ohne Entscheid | DevOps Engineer; Dynamic Software Tester | 2026-11-05 | offen; Daemon vom Setup-Skript gestartet, Images am 2026-11-13 neu geladen (Lesart des Koordinators: Weisung vom 2026-11-04 deckt es) | Entscheid des Auftraggebers zu den Vorlagen; bis dahin Daemon je Sitzung starten. Neu in Sprint 2: Testgegenstelle und Datenbankstufe brauchen ihn | offen |
| H-4 | Die drei Wegwerf-Zweige bestehen weiter (Löschen mit HTTP 403 abgewiesen) | Auftraggeber | 2026-11-05 | offen | Löschen durch den Auftraggeber | offen |
| H-11 | Bestand der serverseitigen Regeln von GitHub für main nicht belegt (E-R5-12 b) | Auftraggeber | 2026-11-05 | offen | Bestätigung oder Einrichtung durch den Auftraggeber | offen |
| H-13 | Störung der Release-Auslieferung von github.com am 2026-11-09 (gitleaks-Archiv HTTP 504, etwa 07:45 bis 08:03 UTC): zwei Versuche des Laufs der Kette auf der Gegenseite rot vor der Kette (fail-closed), der dritte Versuch in der erwarteten Form; kein Befund im Repository (aus Sprint 1 übernommen) | DevOps Engineer; Koordinator | 2026-11-09 | beobachtet | Ohne Massnahme im Repository; Kandidat für eine spätere Einheit: Zwischenspeicher des Archivs am Runner (neben der Vorlage M-G21-01) | offen |
| PR-1 | Beobachtung aus Sprint 1: Wiederherstellung nach Mutationen (aus der Retrospektive Sprint 1, Massnahme M-2) | Dynamic Software Tester; Koordinator | 2026-11-09 | Massnahme M-2 festgelegt (Retrospektive Sprint 1), wirkt ab Sprint 2; Wirkung erst durch einen Bericht aus Sprint 2 belegt | Wiederherstellung nach Mutationen allein über gesicherte Bytes mit Prüfsumme; Auswertung in der Retrospektive Sprint 2 | offen |
| H-15 | Zuggrenzen der Rollen in S1.5: sieben Fortsetzungen bei fünf Rollen | Koordinator; betroffene Rollen | 2026-11-09 | Massnahme M-1 festgelegt, wirkt ab S2.1; in der Planung von S2 wiederholt (H-16) | M-1: Aufträge nach Prüfgegenstand schneiden, Zwischenstand als Datei; Ziel höchstens 2 Fortsetzungen je Einheit | mit M-1, ab S2.1 |
| H-16 | H-15 wiederholt in der Einheit S2: Der Software Architect erreichte in zwei Läufen die Zuggrenze ohne Text; der dritte Lauf gelang nach Verdichtung der Eingaben und Aufteilung des Auftrags (Angaben des Koordinators, Fremdbeleg) | Koordinator; Software Architect | 2026-11-10 | M-1 ergänzt um abschliessende Leseliste und verdichtete Eingaben je Auftrag | In jedem Auftrag eine abschliessende Leseliste und verdichtete Eingaben (Koordinator, ab S2.1); Wirkung in der Retrospektive messen | mit M-1, ab S2.1 |
| H-17 | Die Gegenprüfung des Berichts des Product Owners scheiterte dreimal am gleichen Kriterium und wurde nach 3.4 abgebrochen; der Koordinator entschied den Inhalt der vierten Fassung (Angabe des Koordinators, Fremdbeleg) | Koordinator; Product Owner; Static Software Tester | 2026-11-10 | abgebrochen nach 3.4, Entscheid des Koordinators umgesetzt | Die Ready-Tabelle des Product Owners wird mit dem Merge geprüft; Wiederholung in der Retrospektive auswerten | 2026-11-10 (Abbruch), Auswertung in der Retrospektive |
| H-18 | Der erste Lauf des Arbeitsablaufs der Einheit brach wegen eines fehlenden Felds im Skript des Koordinators ab; nach der Berichtigung aus dem Zwischenspeicher fortgesetzt (Angabe des Koordinators, Fremdbeleg; Übergabe, Abschnitt Einheit S2, Entscheid (1)) | Koordinator | 2026-11-10 | beobachtet; behoben in der Einheit | Auswertung in der Retrospektive Sprint 2 | Retrospektive |
| H-19 | Etappenfrage zu R3-F-013 (Test verlangt Oberfläche und ausführende Person; Anmeldung R3-F-051 liegt in Etappe 3): gehört der Eintrag in Etappe 1? | Requirements Engineer; Product Owner | 2026-11-10 | offen | Requirements Engineer klärt über B4 vor der Planung von Sprint 3; davon hängt ab, ob R3-F-013 Sprint 3 füllt (27 h gegen 28 h) | vor der Planung von Sprint 3 |
| H-20 | Messungen vor dem Bau nach ADR 0008, Teil A, "Offene Punkte": Annahme 1 (httpx-Transport gegen vorgegebene Adresse) und Annahme 3 (Fallzustand bei spur.service.anfuegen) sind ungemessen; Annahme 2 (Bereiche von ipaddress) ist für die Dokumentationsbereiche 192.0.2.0/24, 198.51.100.0/24 und 203.0.113.0/24 gemessen (privat, Python 3.13.16) und entschieden, offen sind der Vorrat der Klassen als Liste und die Testkonstante mit is_global wahr | Backend Engineer (Annahmen 1 und 3); SecDevOps Engineer (Lieferkette httpx); Dynamic Software Tester (Annahme 2) | 2026-11-10 | offen | Stand S2.1: Annahmen 1 und 2 gemessen; nach ADR 0008: Annahme 1 vor S2.1 (Backend Engineer, mit der Lieferkettenprüfung des SecDevOps Engineers), Annahme 2 vor S2.1 (Dynamic Software Tester beim Schreiben der Abnahmetests), Annahme 3 vor S2.2 (Backend Engineer am Code) | vor S2.1 (Annahmen 1 und 2), vor S2.2 (Annahme 3) |
| H-21 | Die Textprüfung B der Einheit S2 scheiterte dreimal am gleichen Kriterium (falsche Zahlen und Zuordnungen in Texten des Koordinators, jeweils an Stellen, die nach der vorherigen Runde neu entstanden oder überholt waren) und wurde nach 3.4 ohne vierte Runde mit Vermerk vorgelegt (Angabe des Koordinators, Fremdbeleg; Übergabe `docs/uebergaben/2026-11-10_s2-etappe-1-sprint-2.md`, Abschnitt "Einheit S2", Absatz Textprüfung) | Koordinator | 2026-11-10 | abgebrochen nach 3.4, mit Vermerk vorgelegt | Ergänzung zu M-3: Messwerte der Übergabe erst am letzten Dokumentstand setzen und die Textprüfung B erst danach starten, ab D28; Auswertung in der Retrospektive Sprint 2 | Retrospektive |
| H-22 | H-15 wiederholt in S2.1: vier Fortsetzungen wegen der Zuggrenze (Software Architect bei der Nachbesserung der Festlegung; Dynamic Software Tester bei den Abnahmetests und bei der Verifikation; Backend Engineer in Teil B des Baus). Der Bau war nach Massnahme M-1 in drei Aufträge und der Client-Teil in drei geplante Läufe geteilt und blieb ausser in Teil B ohne erzwungene Fortsetzung. Der Dynamic Software Tester erreichte die Grenze im Mutationslauf; alle Dateien waren danach byte-gleich dem Stand vor dem Lauf (an 38 Prüfsummen nachgerechnet; Angabe des Koordinators, Fremdbeleg) | Koordinator; betroffene Rollen | 2026-11-10 | M-1 wirkt beim Bau, nicht bei Festlegung und Prüfung; Ziel höchstens 2 Fortsetzungen je Einheit (M-1) in S2.1 mit 4 verfehlt | Aufträge für Festlegung, Abnahmetests und Verifikation nach Prüfgegenstand teilen (Koordinator, ab S2.2); Auswertung in der Retrospektive Sprint 2 | mit M-1, ab S2.2 |
| H-23 | Eine Messdatei einer Prüfrolle im Testbaum störte die Sammlung der Tests bei gleichzeitigen Läufen anderer Rollen (Angabe des Koordinators, Fremdbeleg; Entscheid 25, Übergabe, Abschnitt "Einheit S2.1") | SecDevOps Engineer; DevOps Engineer; Koordinator | 2026-11-10 | behoben (Datei von der Rolle entfernt) | Messdateien der Prüfrollen liegen ausserhalb des Testbaums, wenn gleichzeitig andere Rollen die Kette fahren (Koordinator, in den Aufträgen ab S2.2) | 2026-11-10 |
| H-24 | Zwei Instanzen des Backend Engineers liessen die Formatierung über den ganzen Baum laufen; eine Rolle setzte einen Indexeintrag ohne Inhalt, vom Auftrag nicht gedeckt (beides von den Rollen gemeldet; Entscheide 15 und 22 des Koordinators, Fremdbeleg). Prüfsummen der Abnahmetests blieben gleich | Backend Engineer; DevOps Engineer; Koordinator | 2026-11-10 | beobachtet; ohne Schaden; Indexeintrag bleibt (der Abschlussablauf nimmt neue Dateien ohnehin in den Index) | In Aufträgen mit gleichzeitigen Instanzen die Formatierung auf die eigenen Dateien beschränken (Koordinator, ab S2.2); Auswertung in der Retrospektive | Retrospektive |
| H-25 | Der Belegprüfer D20 las Abschnittsnummern der Konformitätsanalyse als Abschnitte des Projektauftrags: zehn Funde in der Gegenprüfung (Entscheid 16, wie K-S13-01), danach ein zweites Mal im ersten Kettenlauf des Dynamic Software Testers (DT-S21-04): eine Zeile gab die Schreibweise der Analyse wörtlich wieder (Entscheid 29; Fremdbeleg) | Koordinator; Legal Reviewer; DevOps Engineer | 2026-11-10 | behoben: vier ortsgebundene Ausnahmen in der Ausnahmeliste des Belegprüfers, Zeile vom Legal Reviewer umschrieben ("Nummer 10.x der Analyse"), keine fünfte Ausnahme | Nummern von Abschnitten anderer Dokumente stets mit Dokumentnamen oder als "Nummer n.m" schreiben (alle Rollen, Aufträge des Koordinators) | 2026-11-10 |
| H-26 | Der zweite Kettenlauf des Dynamic Software Testers brach in D11 ab: gitleaks las einen synthetischen Testwert des Abnahmetests als Schlüssel (DT-S21-05, vom Tester ersetzt; D11 kennt keine Ausnahme); D12 hätte danach drei fehlende Artefaktzeilen gemeldet (vom Koordinator im Erzeuger nachgetragen). Der dritte Lauf war in der Form des Abnahmekriteriums (Übergabe, Abschnitt "Einheit S2.1", Verifikation; Fremdbeleg) | Dynamic Software Tester; Koordinator | 2026-11-10 | behoben; kein Abbruch nach 3.4 (zwei verschiedene Kriterien) | Vor dem Auftrag zum Kettenlauf am stillen Endstand fährt der Koordinator D20, D11 und D12 einzeln (Entscheid 30; ab S2.2) | 2026-11-10 |
| H-27 | Stapelbau in D1 bricht in der Sitzung ab (A_FAIL, Bake verlangt das Entitlement network.host): Die Umgebung bringt Docker Compose v5.6.1 (bisher v5.6.0); es baut immer über Bake, COMPOSE_BAKE gibt es nicht mehr. Grenze GA-07 ist in der Arbeitsumgebung der Sitzung eingetreten; auf der Gegenseite trug COMPOSE_BAKE=false am 2026-11-10 noch (Messungen des Koordinators, Fremdbeleg) | Software Architect; DevOps Engineer | 2026-11-13 | offen; Übergang "Übergangsregel der Sitzung" (ADR 0002, Abschnitt 5, Nachtrag vom 2026-11-13, Grenze GA-08): make dod mit DOCKER_BUILDKIT=0 in der Aufrufumgebung der Sitzung (Festlegung des Software Architects); Makefile, deploy/ und Arbeitsablauf unverändert. Risiko: gleicher Bruch auf der Gegenseite, sobald das Runner-Image Compose ab v5.6.1 führt | Vorlage E-D29-01 an den Auftraggeber, Empfehlung (a): eigene Einheit N4 nach der Abnahme von S2.2 und vor S2.3 (Rezept D1 über die Bake-Datei mit ausdrücklich erteilter Berechtigung network.host, Arbeitsablauf der Gegenseite ohne COMPOSE_BAKE); Entscheid mit dem Merge des nächsten Pull Requests | offen |

Retrospektive Sprint 1 (Massnahmen M-1 bis M-7) gilt für Sprint 2: M-1 siehe H-15 und H-16; M-2 Wiederherstellung über gesicherte Bytes; M-3 Zahlen vor der Textprüfung abgleichen (Ziel Sprint 2: höchstens 3 Einheiten mit Textprüfung B in der ersten Runde nicht bestanden); M-4 Zellenlängen im Backlog misst der Koordinator; M-5 Namen von Testdateien aus der Festlegung; M-6 Tabelle 6.1 mit Ergebnis und Verweis; M-7 Kalibrierung (Abschnitt 2).

## 7. Entscheidungspunkte

Ein Merge ohne Kommentar gilt als Entscheid nach der Empfehlung je Punkt (Abschnitt 1, Festlegung 2). **Herkunft der Nummern:** E-S2-01 bis E-S2-07 stammen vom Software Architect (ADR 0008, Teil A, Abschnitt "Entscheidpunkte"); Frage, Optionen mit Preis und Empfehlung sind in Abschnitt 7.1 wörtlich aus dem ADR übernommen. E-S2-08 bis E-S2-16 sind angehängt (Scrum Master, aus den Fragen F-1 bis F-6 des Product Owners und der Planung).

### 7.1 Entscheidpunkte des Software Architects (ADR 0008)

| Punkt | Frage | Optionen mit Preis | Empfehlung |
|---|---|---|---|
| E-S2-01 | Protokollort einer Abweisung ohne bestehenden Fall (R3-F-002, Nr. 7) | (a) Tabelle betriebsprotokoll in Sprint 2 (Revision 0007, Einheit S2.2; neue Bearbeitung B-05 im Bearbeitungsverzeichnis; Aufbewahrung als Prüfpunkt der Kantonspolizei Bern offen, GRC H-2). (b) Ohne Fall allein Rückgabe status abgewiesen, Protokoll erst mit R3-F-019; Preis: "protokolliert" ist für diesen Fall nicht erfüllt, R3-F-002 nicht ohne Auslassung grün (Massstab des Product Owners), Neuplanung nach Q-PO-1 | (a) |
| E-S2-02 | Ort des synthetischen Prüfwerkzeugs (Nr. 2, 25) | (a) Im Testbaum (backend/tests/werkzeuge/), in der Fixture registriert; das Produktionsverzeichnis bleibt ohne Eintrag; Preis: der Vollständigkeitstest (Nr. 5 a) ist am Produktionscode in Sprint 2 eine Aussage über null Funktionen, Trennschärfe über den Testbaum belegt. (b) Im Produktionscode unter beschaffung, registriert allein im Umgebungsmodus Test/Schulung; Preis: Prüfcode im Produkt und ein Umgebungsschalter im Verzeichnis (gegen 5.6 und 5.16) | (a) |
| E-S2-03 | Testgegenstelle gegen die Bereichsregel (R3-F-028, Q-PO-3, W2-54) | (a) Ein Literal-Eintrag der Positivliste unterliegt der Bereichsregel nicht (der Wortlaut von R3-F-028 bindet die Regel an aufgelöste Namen); R3-F-015 und der Weiterleitungs- und Literal-Teil von R3-F-028 laufen mit echter Verbindung gegen die Testgegenstelle auf der Rückschleife; für den zulässigen Fall der Namensauflösung liefert der steuerbare Auflöser eine Adresse, die die Bereichsregel zulässt (is_global wahr nach ipaddress; eine Dokumentationsadresse wie 192.0.2.1 ginge nicht, sie gilt als privat und wird abgewiesen), und ein austauschbarer Transport der Tests bildet sie auf die Gegenstelle ab; die Adresse wählt und misst der Dynamic Software Tester vor dem Bau in S2.1 und hält sie als eine benannte Testkonstante fest; Preis: der Namenspfad belegt die Verbindung "gegen genau diese Adresse" über den Transport-Ersatz, nicht über eine echte Verbindung (Grenze GK-5); die Testkonstante ist eine öffentliche Adresse ausserhalb der Dokumentationsbereiche, Abweichung von DS-S2-03 und H-6 für diesen einen Wert, ohne Verbindung und ohne Personenbezug (Stellungnahme des Datenschutzexperten in S2.1); ein Administrator kann eine private Adresse ausdrücklich freigeben. (b) Bereichsregel auch für Literal-Einträge; Preis: jeder zulässige Fall läuft allein über den Transport-Ersatz, R3-F-015 ohne echte Verbindung, schwächer | (a) |
| E-S2-04 | Höchstzahl der Weiterleitungsschritte (R3-F-028, Annahme; F-2 des Product Owners; mit S-05) | (a) 3, je Schritt geprüft, als Konfiguration ausgang_weiterleitungen_hoechstzahl mit Startwert 3; Prüffall mit einer Konstante änderbar. (b) Anderer Wert nach Angabe des Auftraggebers; Preis: keiner, der Startwert ist Daten | (a) |
| E-S2-05 | Tageswechsel der Kontingentgrenze und Startwerte (R3-F-016; F-6 und Q-PO-4 des Product Owners) | (a) Kalendertag in UTC (wie core.zeit und GS-25; eindeutig, ohne Sommerzeitsprung); Preis: der Tageswechsel liegt in Bern um 01:00 oder 02:00 Lokalzeit. (b) Kalendertag in Europe/Zurich; Preis: Zeitzonendaten im Code, zwei Tage mit 23 oder 25 Stunden, Abweichung von core. Startwerte der Grenzen gibt es allein für die Prüfwerkzeuge (Testdaten); produktive Werte kommen je Quelle mit ihrem Eintrag (betrieblich, GRC H-5) | (a) |
| E-S2-06 | HTTP-Bibliothek in ausgang (Nr. 15, 24) | (a) httpx als Laufzeitabhängigkeit nach Lieferkettenprüfung; Preis: ein Paket mehr im Laufzeit-Image, die Verbindung gegen eine vorgegebene Adresse braucht einen eigenen Transport (Annahme, Messung vor dem Bau). (b) Eigener minimaler HTTP/1.1-Client auf asyncio ohne Paket; Preis: eigener Parser und eigene TLS-Behandlung, mehr Prüfaufwand, keine Wiederverwendung für Etappe 2 | (a) |
| E-S2-07 | Fortschreibung der Konformitätsanalyse (F-02 bis F-05, Abschnitt 7) und der Datenschutzdokumente (B-04, B-05, LW-Zeilen) | (a) Je Baueinheit, vor dem Bau als Stellungnahme und nach dem Bau als Fortschreibung mit Gegenprüfung des Legal Reviewers (Bedingung der GRC-Rolle für R3-F-009; R-08); Preis: Prüfaufwand der Rollen in jeder Einheit, im Prüfaufwand nicht belegt. (b) Gesammelt am Sprintende; Preis: ein Klartextwert in einer anfügbaren Spur ist nachträglich nicht entfernbar, Abschnitt 7 fehlte bei der Abnahme von R3-F-009 | (a) |

### 7.2 Entscheidpunkte dieser Vorlage und des Product Owners

| Nr. | Frage | Optionen und Preis | Empfehlung |
|---|---|---|---|
| E-S2-08 | Annahme von Sprint-Ziel (Abschnitt 3) und Sprint Backlog (sieben Einträge, 31 h Planung, 40 h nach Neubewertung) mit der Verschiebungsregel (steigt der Prüfaufwand einer Einheit vor deren Bau über die neu bewerteten Werte, jede Erhöhung auch um 1 h: R3-F-009 nach Sprint 3) | (a) angenommen. (b) angenommen mit Auflagen, etwa R3-F-009 schon jetzt nach Sprint 3; Preis: Summe 36 h, Sprint-Ziel ohne den Negativbefund. (c) nicht angenommen. Preis (a): Obergrenze erreicht, ohne Reserve | (a) |
| E-S2-09 | Zerlegung S2.1 bis S2.4 und Reihenfolge (Abschnitt 5; ausgang zuerst; Abnahmezeile von R3-F-016 erst in S2.4) | (a) wie Abschnitt 5. (b) Reihenfolge der Hypothese (Verzeichnis zuerst); Preis: der Aufrufpfad hätte keinen Client und keine Gegenstelle zum Prüfen | (a) |
| E-S2-10 | Ereignisplan und Abbildung der Sprint-Ereignisse auf die Formwege (Abschnitte 1 und 6.1; Tag 0 = Merge, Tag 14 = Tag 0 plus 14 Tage) | (a) wie Sprint 1. (b) zusätzliche Termine mit dem Auftraggeber; Preis: Wartezeit auf dem kritischen Pfad | (a) |
| E-S2-11 | Merge als Abstimmung nach R1 für die sieben Einträge "ready mit Vorbehalt nach R1" (F-1 des Product Owners) | (a) der Merge gilt als Abstimmung mit S-01, der Vorbehalt entfällt mit dem Merge; der Vermerk in den Einträgen folgt als Stand-Zeile. (b) Abstimmung mit S-03 bis S-08 vor dem Bau; Preis: Wartezeit | (a) |
| E-S2-12 | Umgang mit den Nachbesserungen des Walkthroughs und den B4-Fortschreibungen der Einträge (R3-F-002, R3-F-009, R3-F-014, R3-F-015, R3-F-028, R3-F-026 mit drittem Kriterium) | (a) Fortschreibung durch den Requirements Engineer je vor der Baueinheit, die den Eintrag baut (wie E-S1-22); Preis: Abnahmetests werden gegen den fortgeschriebenen Wortlaut geschrieben. (b) alle in einer Einheit vor S2.1; Preis: Wartezeit, ein weiterer Merge | (a) |
| E-S2-13 | Kalibrierung nach M-7: Planung 28 bis 33 h, Neubewertung höchstens 40 h, Spanne mit Mehraufwand in der Retrospektive | (a) wie Abschnitt 2. (b) Planungssumme über 33 h zulassen; Preis: geringere Reserve | (a) |
| E-S2-14 | Obergrenzen für Feldlänge, Anfragegrösse und Anfragehäufigkeit (F-3 des Product Owners; R3-F-027) | (a) R3-F-027 nicht in Sprint 2; der Software Architect schlägt Werte vor, sobald api eine Route hat. (b) Werte jetzt vom Auftraggeber; Preis: Festlegung ohne Endpunkt | (a) |
| E-S2-15 | R3-F-020 terminieren auf Sprint 3 und das Kriterium Löschweg selbstskalierend fassen (F-4 des Product Owners; präskriptiv 4.4, nicht neu priorisiert, nur terminiert nach 6.2) | (a) Termin Sprint 3; die Fortschreibung zur selbstskalierenden Form (je bestehendem Ablageort) legen GRC-Rolle und Auftraggeber vor der Planung von Sprint 3 vor. (b) Kriterium unverändert; Preis: der Test ist in Sprint 3 grün ohne Aussage (docs/06) | (a) |
| E-S2-16 | Freiwillige Angabe des Prüfaufwands je Merge durch den Auftraggeber (F-5 des Product Owners; unter 1 h, bis 3 h, darüber) | (a) ja, freiwillig; ohne Angabe gilt das Ersatzmass Wartezeit. (b) keine Angabe; Preis: die Kalibrierung bleibt auf dem Ersatzmass | (a) |

**Vermerke ohne Entscheidpunkt:**

- **E-S2-G1** der GRC-Rolle (Form des versuchten Ziels im Protokolleintrag einer abgewiesenen Verbindung, bedingte Vorlage) ist durch die Festlegung erledigt: Lesart (a) gilt als Entscheid der Festlegung, jedes versuchte Ziel steht in der Spur als Pseudonym, bei einem Listenziel zusätzlich die Kennung des Listeneintrags im Klartext (ADR 0008, Entscheid 16). Kein eigener Entscheidpunkt.
- **Datenschutzexperte und GRC-Rolle** haben keine Vorlage an den Auftraggeber verlangt; kein Kandidat ist rechtlich blockiert. Die Zeitzone und die Kontingentwerte (F-6) sind durch E-S2-05 gedeckt, die Weiterleitungsschritte (F-2) durch E-S2-04.
- **Vorlage E-D27-01** (Glossar: Bestätigung der gekennzeichneten Vorschläge aus S1.5 und der fünf Vorschläge aus S2) steht im Text des Pull Requests, nicht in dieser Vorlage.
- Offene Vorlagen beim Auftraggeber, unverändert und ohne Entscheid: H-1, H-3, H-4, H-11, GP-6, Kriterien D10 und D12 vom 2026-09-02, O-31, O-32.

## 8. Annahmeerklärung

*Ausgefüllt am 2026-11-10 durch den Protocol Master im Auftrag des Koordinators nach dem Merge des Pull Requests #58 (erster Formweg; Protokollvermerk unten). Der Stand davor ("Nicht ausgefüllt") liegt in git im Stand des Pull Requests #58 (Kopf `92cf4b707e1d59578f57aef8b3d01dc2828c6ab3`).*

### Entscheid (E-S2-08)

- [x] **Angenommen.** Sprint 2 beginnt mit dem Merge; die erste Baueinheit ist S2.1.
- [ ] **Angenommen mit Auflagen.** Die Auflagen unten werden vor oder mit der genannten Einheit umgesetzt.
- [ ] **Nicht angenommen.** Nachbesserung gemäss Auflagen, danach erneute Vorlage.

### Auflagen

| Nr. | Auflage | Frist oder Bedingung |
|---|---|---|
| — | Keine Auflagen. | — |

### Entscheide je Punkt

| Punkt | Entscheid |
|---|---|
| E-S2-01 bis E-S2-07 (ADR 0008) | Je nach Empfehlung, mit dem Merge ohne Kommentar: E-S2-01 (a), E-S2-02 (a), E-S2-03 (a), E-S2-04 (a), E-S2-05 (a), E-S2-06 (a), E-S2-07 (a) |
| E-S2-09 bis E-S2-16 | Je nach Empfehlung, mit dem Merge ohne Kommentar: E-S2-09 (a), E-S2-10 (a), E-S2-11 (a), E-S2-12 (a), E-S2-13 (a), E-S2-14 (a), E-S2-15 (a), E-S2-16 (a); E-S2-08 (a) ist der Entscheid oben |

### Erklärung

> Ich habe die Vorlage sprint-02 im Stand des Pull Requests der Einheiten D27 und S2 geprüft.
> Der Entscheid oben gilt.

| | |
|---|---|
| **Auftraggeber (S-01)** | Erteilt durch den Merge des Pull Requests #58 am 2026-11-10, 08:19:04 UTC (Merge-Commit `6d517d1fb0c7dc2e2317d0181198edf06b8d4cd2`), durch das Konto des Repository-Eigentümers; eingetragen durch den Protocol Master, Einheit D28. Ohne Kommentar, ohne Review; der Wortlaut der Erklärung oben ist der in der Vorlage vorformulierte und nicht vom Auftraggeber geschrieben; Name nach offenem Entscheid E-11 nicht im Repository geführt |

**Protokollvermerk zur Form:** Die Annahme wurde durch den Merge des Pull Requests #58 erteilt (erster Formweg); sein Text sagt, dass der Merge die Annahme von Sprint-Ziel, Sprint Backlog und Zerlegung nach dieser Vorlage bedeutet, mit den Empfehlungen je Entscheidpunkt, sofern kein Kommentar und keine Weisung anderes sagt; ein abweichender Kommentar lag nicht vor. Die Angaben zum Merge sind den Tatsachen des Koordinators vom 2026-11-10 entnommen (GitHub-Schnittstelle und git) — Fremdbeleg, von dieser Rolle nicht nachgemessen. Einzelheiten: ADR 0002, Abschnitt 10, Unterabschnitt "Annahme von Sprint 2 der Etappe 1 ... Merge des Pull Requests #58 — erteilt am 2026-11-10, eingetragen am 2026-11-10".

### Formweg

Erster Formweg: Merge des Pull Requests der Einheiten D27 und S2; sein Text sagt, dass der Merge die Annahme von Sprint-Ziel, Sprint Backlog und Zerlegung nach dieser Vorlage bedeutet, mit den Empfehlungen je Entscheidpunkt, sofern kein Kommentar und keine Weisung anderes sagt. Zweiter Formweg: Anweisung an die nächste Sitzung im exakten Wortlaut des Entscheids; die Sitzung überträgt ihn hierher. Massgeblich ist der committete Stand; Urheber und Zeitpunkt belegt die Commit-Historie.

## 9. Nach der Annahme

**Stand 2026-11-10:** Vorlage vom 2026-11-10 erarbeitet (Einheit S2) und zur Annahme vorgelegt; Sprint 2 hat noch nicht begonnen. Planung 31 h, Neubewertung 40 h (Abschnitt 4.1). Nächster Schritt: Pull Request der Einheiten D27 und S2; Pause bis zum Merge, dann Baueinheit S2.1 (Modul ausgang), nach den Messungen vor dem Bau (H-20).

1. Die erste Sitzung nach dem Merge trägt die Annahme ein: Protocol Master in ADR 0002, Abschnitt 10 und in Abschnitt 8 dieses Dokuments; Product Owner im Backlog (Vermerk "Vorbehalt entfällt" in den sieben Einträgen); Software Architect in ADR 0008 (Status) und ADR 0007, Teil B; Koordinator in CLAUDE.md. Die Daten des Ereignisplans (Tag 0 und Tag 14) trägt dieselbe Einheit in Abschnitt 6.1 nach.
2. **Erste Baueinheit:** S2.1. Jede Baueinheit beginnt mit der Erfassung der Codebasis (3.1) und dem Schnitt durch den Software Architect, wird von Static und Dynamic Software Tester auf einem anderen Modellfeld verifiziert (3.4) und durch den Merge ihres Pull Requests abgenommen. Pause je Pull Request bis zum Merge.
3. **Rückkopplung:** Jede Baueinheit trägt in der Übergabe den tatsächlichen Prüfaufwand des Auftraggebers ein, soweit er ihn nennt; sonst gilt die Wartezeit bis zum Merge als Ersatzmass. Die Retrospektive vergleicht (Kalibrierung nach 6.8).
4. Was am Sprintende nicht abgenommen ist, geht in die Planung von Sprint 3 zurück.
5. Vor jedem Frontend-Inkrement steht das Gate aus 5.6; Sprint 2 berührt es nicht.

**Stand am 2026-11-10 (Tag 0), fortgeschrieben mit der Einheit D28 (Angaben des Koordinators, Fremdbeleg):** Sprint 2 ist mit dem Merge des Pull Requests #58 am 2026-11-10 um 08:19:04 UTC angenommen (erster Formweg, ohne Kommentar des Auftraggebers, ohne Review; Merge-Commit `6d517d1fb0c7dc2e2317d0181198edf06b8d4cd2`): alle Entscheidpunkte E-S2-01 bis E-S2-16 je (a), ADR 0008 angenommen, Vorbehalt nach R1 entfallen, E-D27-01 (a). Tag 0 = 2026-11-10, Tag 14 = 2026-11-24. Die Wartezeit vom Anlegen bis zum Merge beträgt 17 min 34 s als Ersatzmass (der Auftraggeber nannte keinen Prüfaufwand). Weisung vom 2026-11-10 zur Fortsetzung: Wortlaut und Lesart in ADR 0002, Abschnitt 10. Die Annahme ist mit der Einheit D28 eingetragen (Punkt 1 der Liste erledigt). Nächster Schritt: Baueinheit S2.1 (Modul ausgang; R3-F-015, R3-F-028) nach der Fortschreibung der beiden Einträge (E-S2-12 a) und den Messungen vor dem Bau (H-20). Abgenommen sind 0 h von 40 h.

**Stand am 2026-11-10 (Tag 0 von 14), fortgeschrieben mit der Einheit S2.1 (Angaben des Koordinators, Fremdbeleg):** Eine von vier Baueinheiten, S2.1 (Modul ausgang; R3-F-015, R3-F-028), ist gebaut und verifiziert und zur Abnahme vorgelegt; abgenommen ist sie erst mit dem Merge des Pull Requests der Einheiten D28 und S2.1. Nach Prüfaufwand sind 14 h von 38 h vorgelegt (R3-F-015 4 h, R3-F-028 10 h); abgenommen sind weiterhin 0 h. Die Verschiebungsregel ist ausgelöst: R3-F-009 geht nach Sprint 3, Sprint 2 liegt bei 38 h (Abschnitt 4.1, Nachtrag vom 2026-11-10; der angenommene Stand mit sieben Einträgen und 40 h bleibt lesbar). Neue Hindernisse H-22 bis H-26 (Abschnitt 6.2). Nächster Schritt: Merge des Pull Requests der Einheiten D28 und S2.1, danach D29 (Eintrag der Abnahme) und S2.2.

**Stand am 2026-11-13 (Tag 3 von 14), fortgeschrieben mit der Einheit D29 (Angaben des Koordinators, Fremdbeleg):** S2.1 ist abgenommen mit dem Merge des Pull Requests #59 am 2026-11-13 um 09:18:57 UTC (Merge-Commit `2b3926f36d584d42f1c9bdbba6ee860d273d34f7`; erster Formweg, ohne Kommentar des Auftraggebers, ohne Review), 3 Tage 0 h 59 min 53 s nach Tag 0. Abgenommen sind R3-F-015 (4 h) und R3-F-028 (10 h), zusammen 14 h von 38 h Prüfaufwand; offen sind S2.2 bis S2.4 (24 h). Die Wartezeit vom Anlegen des Pull Requests bis zum Merge beträgt 68 h 26 min 4 s als Ersatzmass (der Auftraggeber nannte keinen Prüfaufwand). Der Lauf der Kette auf der Gegenseite (Kennung 42819524925) war im ersten Versuch in der Form des Abnahmekriteriums (D9 einzige Lage C, 297 s). Hindernisse: H-3 fortgeschrieben (achter Neustart, erstmals neu aufgesetzt), neu H-27 (Stapelbau unter Compose v5.6.1, Übergang DOCKER_BUILDKIT=0). Die Annahmeerklärung in Abschnitt 8 bleibt unverändert. Nächste Schritte: D29 (eingetragen), dann S2.2 (beschaffung; R3-F-026, R3-F-002); der Pull Request folgt mit S2.2 (Merge = Abnahme von S2.2 und Bestätigung von D29).
