# Definition of Ready und Definition of Done

| | |
|---|---|
| **Arbeitsprodukt nach** | Projektauftrag 6.5, 6.8, 3.4 |
| **Verantwortlich** | Scrum Master (Prozess), Requirements Engineer (Ready), Static und Dynamic Software Tester (Done) |
| **Stand** | 2026-08-20, nachgeführt am 2026-08-30 (ADR 0002, Abschnitt 6.1: D18 ergänzt, D11 auf zwei Gegenstände erweitert, Kettengrundsatz aufgenommen; Commit `84450a71569120e8deb30ecb0349ea8a92f6d736`), ergänzt am 2026-08-31 um die Notation der Abnahmekriterien zu R6 — Vorschlag zur Bestätigung, am selben Tag nach Prüfbefund berichtigt (drittes Glied heisst "Nachbedingung" wie die Quelle; Ermessensanteil der Zählungen offengelegt), nachgeführt am 2026-09-01 (Rahmenprüfung **D19** aus der zweiten und vierten Fortschreibung von ADR 0002 vom 2026-08-30 nachgetragen — diese Nachführung stand seither offen; Kettenschritt **D20** aus der achten Fortschreibung vom 2026-09-01 aufgenommen; Kettengrundsatz zum Rückgabewert 0 übernommen), am selben Tag ein zweites Mal nachgeführt (neunte und zehnte Fortschreibung von ADR 0002: Beobachtbarkeit des Index als zweiter Teil des D19-Prüfmittels, Lage C für **alle** Schritte geschärft, Aussagegrenze der D19-Meldung, O-17 als offener Punkt aufgenommen), am selben Tag ein drittes Mal nachgeführt (Behebung eines blockierenden Befunds am Programmstand: D20 prüft jetzt alle sechs im Kriterium genannten Prüfmittel statt drei, geschärfte Lage C als nicht leere Referenzmenge bei den beiden Bezugsdokumenten, dritter Rückgabewert des Belegprüfers für Lage C von den Befunden am Bestand unterschieden; D19 mit einem ausgeführten Verletzungstest und einer laufbezogenen Aussage bei stummgeschaltetem Index ergänzt; O-18 als offener Punkt aufgenommen) |

Beide sind zu unterscheiden: **Ready gilt für den Eingang in den Sprint, Done
für den Ausgang** (6.8).

## Fortschreibungen dieses Dokuments

| Datum | Was vorher galt | Was jetzt gilt | Warum |
|---|---|---|---|
| 2026-08-30 | D11 (Teil 2, Befehlskette) prüfte nach dieser Tabelle "im Programmstand"; der dafür vorgeschlagene Befehl (`gitleaks detect` ohne `--no-git`) durchsuchte in der Praxis ausschliesslich die Git-Historie | D11 prüft zwei Gegenstände in zwei eigenständigen Läufen: Arbeitsbaum und Git-Historie; keiner ersetzt den anderen | Der Hook aus R3-Q-001 läuft als `Stop` beziehungsweise `SubagentStop`, also **vor** dem Commit — der Arbeitsbaum ist damit der Regelfall des Einsatzes. Belegt mit einem ausgeführten Lauf am 2026-08-30 |
| 2026-08-30 | Die Befehlskette (Teil 2) führte D1 bis D12; der von ADR 0002, Abschnitt 3.5, seit dem 2026-08-20 verlangte Importprüfer-Schritt fehlte in dieser Tabelle | Neuer Kettenschritt **D18** (Architekturverträge), in der Zielliste von `make dod` nach D4 und vor D5 eingeordnet | Löst einen Widerspruch innerhalb des ADR auf: Abschnitt 3.5 verlangte den Schritt als eigenen Kettenschritt, die Tabelle in Abschnitt 6 führte ihn nicht |
| 2026-08-30 | Kein Grundsatz hielt fest, dass ein Prüflauf den Arbeitsbaum unverändert lässt | Neuer Grundsatz: Kein Kettenschritt ändert eine versionierte Datei des Arbeitsbaums | Voraussetzung dafür, dass D11 den Arbeitsbaum zuverlässig beurteilt, unabhängig davon, welcher Schritt vorher lief |
| 2026-08-31 | R6 verlangte ein Abnahmekriterium, "das sich als Test formulieren lässt", ohne eine Form dafür zu nennen | Neuer Abschnitt "Notation der Abnahmekriterien (R6)" in Teil 1 — **als Vorschlag zur Bestätigung**, nicht als gesetzte Regel | Ohne benannte Form entsteht die Prüfbarkeit je Eintrag neu und ungleich. Die Form ist am Bestand erhoben, nicht von aussen gesetzt: sie schreibt fest, was die Arbeitseinheit "Befund F" am 2026-08-26 bereits angewandt hat |
| 2026-08-31 | Die erste Fassung desselben Tages nannte das dritte Glied "Erwartung" und behauptete zugleich, die Benennung sei die von Befund F. Das Wort "Erwartung" kommt weder in `docs/05_Product_Backlog.md` noch in `docs/uebergaben/2026-08-26_befund-f-abnahmekriterien.md` vor | Das dritte Glied heisst **Nachbedingung**, wie die Quelle. Der Abschnitt trennt jetzt ausdrücklich: die vier **Namen** sind wörtlich übernommen, die **Bestimmungen** der Glieder stehen dort zum ersten Mal, weil Befund F die Glieder benennt, ohne sie zu bestimmen. Dazu die Offenlegung des Ermessensanteils der Zahlen 11/6/4 | Befund einer unabhängigen Prüfung, nachgeprüft und zutreffend. Eine Notation, die ihre Geltung darauf stützt, am Bestand erhoben und nicht gesetzt zu sein, darf ihre Herkunft nicht falsch angeben — sonst trägt die Begründung nicht, mit der sie vorgelegt wird. Die beobachtbare Reaktion, die vorher unter "Erwartung" stand, bleibt erhalten: sie steht in der Nachbedingung, weil Befund F sie dort führt |
| 2026-09-01 | Diese Datei führte **D19 nicht**, obwohl ADR 0002 die Nummer bereits am 2026-08-30 vergeben hatte (zweite Fortschreibung, Abschnitt 6.2; Messweise nachgeschärft in 6.4). Wer die Freiheit einer D-Nummer an dieser Datei ablesen wollte, hielt D19 für frei | Die Rahmenprüfung **D19** (Unverändertheit des Arbeitsbaums) steht mit eigenem Kriterium unter dem Kettengrundsatz. Dazu die Vergaberegel: **eine D-Nummer ist vergeben, sobald ein ADR sie vergibt**, nicht erst, wenn die Nachführung sie erreicht hat; der gemeinsame Namensraum wird aus beiden Dokumenten gelesen, bei Abweichung gilt der frühere Vergabezeitpunkt | Die Nachführung stand seit dem 2026-08-30 offen (ADR 0002, Abschnitt 9). Beim Vergeben der nächsten Nummer wäre D19 ohne die ausdrückliche Regel ein zweites Mal vergeben worden; der Befund und die Regel stammen aus ADR 0002, 6.8.1 |
| 2026-09-01 | Die Zielliste von `make dod` führte D1 bis D4, D18, D5 bis D12. Über den Dokumentationsbestand — die einzige Artefaktklasse, die das Repository heute trägt — sagte die Kette nichts | Neuer Kettenschritt **D20** (Belege) als **erster** Schritt, vor D1, **ohne Lage B**. Die Reihe lautet D20, D1 bis D4, D18, D5 bis D12 | Entscheid des Auftraggebers vom 2026-09-01, ausgeführt in der achten Fortschreibung von ADR 0002, Abschnitt 6.8. Am Ende der Kette liefe der Schritt bis auf Weiteres nie, weil die Kette heute bei D7 abbricht, und er würde zum ersten Mal in genau dem Lauf greifen, in dem sich seine schärfste Regel selbst scharf schaltet (6.8.2) |
| 2026-09-01 | Teil 2 sagte, was jeder Schritt prüft, aber nicht, was ein **bestandener** Schritt behauptet. Unter "Was nicht als erledigt gilt" stand allein, dass ein grüner Prüflauf nicht genügt | Neuer Abschnitt "Was ein grüner Kettenschritt aussagt" mit dem Grundsatz: Rückgabewert 0 heisst, nichts von dem gefunden zu haben, was dieser Schritt sucht — nie, dass nichts vorhanden ist | ADR 0002, 6.8.4 erklärt den Satz ausdrücklich für **alle** Schritte und weist ihn in Abschnitt 9 dieser Datei zu. Er ändert an keinem Schritt das Verhalten, aber den Anspruch eines grünen `make dod`; bei einem Artefakt, dessen Ergebnis nach 5.3 ein Nachweis ist, ist das kein Nebenpunkt |
| 2026-09-01, zweite Nachführung des Tages | Das Kriterium D19 nannte als Prüfmittel allein die Aufnahme des Bestandes: Statusliste und Inhaltsprüfsummen. Dass ein Kettenschritt das Messmittel selbst stummschalten kann, war als Befund gemeldet und nicht entschieden (offener Punkt 7 unten) | Die **Beobachtbarkeit des Index** ist zweiter Teil des Prüfmittels von D19: Der Bestand der Maskierungsmerkmale verfolgter Dateien wird vor und nach dem Lauf erhoben, ein gesetztes Merkmal ergibt **Lage C**. Dazu zwei Massstäbe — **der Gegenstand wird relativ gemessen, das Instrument absolut verlangt** | Entscheid des Software Architects in ADR 0002, 6.9, auf den gemeldeten Befund hin. Ein Kettenschritt, der ein Maskierungsmerkmal setzt, verändert nicht den Gegenstand, sondern das Messmittel; D19 meldete dann "unverändert" über eine Datei, die es nicht mehr ansehen kann. Das Ergebnis wäre kein falsches Urteil, sondern ein Urteil ohne Grundlage |
| 2026-09-01, zweite Nachführung des Tages | Lage C hiess "Gegenstand vorhanden, Prüfmittel fehlt" | Lage C heisst: Prüfmittel **fehlt oder trägt die Aussage nicht** — es ist unlesbar, unbrauchbar oder stummgeschaltet. Das gilt für **alle** Kettenschritte, nicht nur für D19, und steht deshalb in einem eigenen Abschnitt in Teil 2 | ADR 0002, 6.9.2. Keine Ausweitung, sondern eine Klarstellung: D18 meldet Lage C bei vorhandener, aber unlesbarer Vertragsdatei, und D7 endet ungleich 0, wenn die gefundene Backlog-Datei keine Abnahmekriterien führt — die Bedingung war bereits weiter als ihr Wortlaut. Sie bestimmt, wann ein Schritt ungleich 0 endet, und gehört damit in das Dokument, das festlegt, was "Done" heisst |
| 2026-09-01, zweite Nachführung des Tages | Der Ausgang bei stummgeschaltetem Instrument war als "nicht beobachtbar" benannt | Die Meldung nennt, **welche Hälfte** des Instruments stumm ist, für welche Dateien, und was die andere Hälfte gemessen hat; sie behauptet nicht, der Arbeitsbaum sei unbeobachtet | ADR 0002, 6.10.2, gestützt auf einen ausgeführten Lauf des Koordinators zu O-16: Die Statusliste ist für eine maskierte Datei blind, die Inhaltsprüfsumme erfasst die Änderung weiterhin. Nach 5.3 ist die Ausgabe der Kette eine Protokollspur mit zwingenden Negativbefunden; ein Negativbefund, der zu viel behauptet, ist derselbe Mangel wie ein fehlender |
| 2026-09-01, dritte Nachführung des Tages | D20 nannte sechs Prüfmittel, deren Fehlen Lage C ergibt — `git`, den Arbeitsbaum, `scripts/belege-pruefen.sh`, `scripts/belege-ausnahmen.txt` sowie die beiden Bezugsdokumente `docs/05_Product_Backlog.md` und `docs/00_Projektauftrag.md`. Geprüft hatten das Makefile-Ziel `belege` und `scripts/belege-pruefen.sh` bis dahin nur die ersten drei. Ohne Bezugsdokument blieb die Referenzmenge leer, jede gültige Anforderungskennung im Bestand wurde zum Scheinfund, und das gemessene Ergebnis war A_FAIL mit hunderten Funden statt Lage C | Das Makefile-Ziel `belege` prüft jetzt vorab alle sechs Prüfmittel, `scripts/belege-pruefen.sh` zusätzlich vor jeder Verwendung. Für die beiden Bezugsdokumente genügt Vorhandensein allein nicht mehr: Sie müssen eine **nicht leere Referenzmenge** hergeben — mindestens eine Anforderungskennung als Überschrift im Backlog, mindestens eine Abschnittsnummer als Überschrift im Projektauftrag. Für `scripts/belege-ausnahmen.txt` gilt das nicht: eine vorhandene, leere Liste bleibt zulässig, nur eine fehlende ist Lage C. Der Belegprüfer gibt jetzt drei Rückgabewerte aus statt zwei: 0 keine Beanstandung, 2 mindestens ein Befund am Bestand, 3 Lage C; das Makefile führt beide roten Ausgänge getrennt als A_FAIL beziehungsweise Lage C weiter | Blockierender Befund einer unabhängigen Prüfung auf einem anderen Modell als die Umsetzung (2026-09-01). Das Kriterium D20 war richtig formuliert und nicht erfüllt, nicht umgekehrt. Behoben und mit drei ausgeführten Gegenproben belegt (Ausnahmeliste beiseitegelegt, Backlog beiseitegelegt, Backlog vorhanden aber ohne jede Anforderungskennung — je Lage C, Rückgabewert 3, Arbeitsbaum vorher/nachher gleich) |
| 2026-09-01, dritte Nachführung des Tages | Dass D19 bei einer tatsächlichen Verletzung meldet — und nicht nur bei Unverändertheit schweigt —, war nicht ausgeführt belegt; die unabhängige Prüfung liess genau diese Lücke ausdrücklich offen | Ausgeführter Test: `make dod` im Hintergrund gestartet, nach drei Sekunden eine verfolgte Datei geändert. D19 meldete "VERLETZT -- versionierter Bestand veraendert", nannte die geänderte Datei und zeigte beide Hälften des Prüfmittels — die Statuszeile und die abweichende Inhaltsprüfsumme | Erstmals ausgeführt belegt, dass D19 nicht nur schweigt, wenn nichts ist, sondern auch spricht, wenn etwas ist. Ein Instrument, das nur die Abwesenheit einer Veränderung feststellt, wäre von einem nicht messenden nicht unterscheidbar |
| 2026-09-01, dritte Nachführung des Tages | Bei stummgeschaltetem Index stand nur die allgemeine Aussage über die externe Messung des Koordinators vom 2026-09-01; keine Aussage bezog sich auf den jeweils laufenden Lauf selbst | Die Meldung bei stummgeschaltetem Index nennt zusätzlich, **laufbezogen**, ob Statusliste und Inhaltsprüfsummen vorher und nachher in diesem Lauf gleich waren — mit dem ausdrücklichen Zusatz, dass diese Gleichheit den Lauf **nicht entlastet**, weil sie nicht ausschliessen kann, was die blinde Hälfte gar nicht meldet | Schweigen ist keine Messung: eine laufbezogene Aussage ist stärker als eine allgemeine, darf aber nicht mehr behaupten, als sie trägt — deshalb der ausdrückliche Zusatz |

Quelle für die drei Zeilen vom 2026-08-30: ADR 0002, Abschnitt 6.1
(`docs/adr/0002-architekturentscheid-ziel-stack.md`), Fortschreibung vom
2026-08-30, Commit `84450a71569120e8deb30ecb0349ea8a92f6d736`. Einzelheiten
unten unter "Die Befehlskette".

Quelle für die sechs Zeilen der ersten beiden Nachführungen vom 2026-09-01:
derselbe ADR — Abschnitte 6.2 und
6.4 (D19 in seiner ersten Fassung), 6.8 (D20, Nummernvergabe, Kettengrundsatz)
sowie 6.9 und 6.10 (zweiter Teil des D19-Prüfmittels, geschärfte Lage C,
Aussagegrenze der Meldung). Worauf die Aussagen dieser Nachführungen im
Einzelnen beruhen, steht unten unter "Die Befehlskette", Absatz "Woraus die
Nachführung vom 2026-09-01 schöpft".

Quelle für die drei Zeilen der dritten Nachführung vom 2026-09-01: `Makefile`
(Ziel `belege` und der D19-Teil des Rezepts von `dod`) und
`scripts/belege-pruefen.sh`, beide vollständig gelesen — nicht ein Abschnitt
von ADR 0002, weil diese Nachführung eine Korrektur am Programmstand
nachzeichnet, keine neue Festlegung. Einzelheiten unten unter "Die
Befehlskette", Absatz "Woraus die dritte Nachführung vom 2026-09-01 schöpft".

---

# Teil 1 — Definition of Ready

Ein Backlog-Eintrag darf erst in einen Sprint gezogen werden, wenn **alle**
Kriterien erfüllt sind. Abgeleitet aus den IREB-Qualitätskriterien (6.5).

## Je Eintrag

| Nr. | Kriterium | Woran es geprüft wird |
|---|---|---|
| R1 | **adäquat** | Bildet ein tatsächliches, mit einem Stakeholder aus `02_Stakeholderliste.md` abgestimmtes Bedürfnis ab. Der Stakeholder ist im Eintrag benannt. |
| R2 | **notwendig** | Ohne den Eintrag fehlt dem Produkt etwas Benanntes. Ein Eintrag "wäre schön" erfüllt R2 nicht. |
| R3 | **eindeutig** | Der Eintrag lässt genau eine Lesart zu. Verwendete Fachbegriffe stehen im Glossar `03_Glossar.md`. |
| R4 | **vollständig in sich** | Der Eintrag ist ohne Rückfrage bearbeitbar. Offene Punkte sind entweder gelöst oder ausdrücklich als Annahme benannt. |
| R5 | **verständlich** | Ohne Zusatzerklärung lesbar, auch für jemanden, der nicht dabei war. |
| R6 | **prüfbar** | Es existiert mindestens ein Abnahmekriterium, das sich als Test formulieren lässt, mit dem Testnamen im Eintrag. Zur Form siehe unten "Notation der Abnahmekriterien (R6)". |
| R7 | **zugeordnet** | Anforderungsart nach 6.4 ist gesetzt: funktional, Qualität oder Randbedingung. |
| R8 | **geschätzt** | Der Prüfaufwand in Stunden ist geschätzt — **nicht** der Umsetzungsaufwand (6.8). |
| R9 | **verfolgbar** | Der Eintrag trägt eine dauerhafte Kennung und einen Rückverweis auf den Abschnitt des Projektauftrags (6.6). |
| R10 | **abhängigkeitsfrei oder aufgelöst** | Vorbedingungen sind entweder erledigt oder im Eintrag benannt. |

## Für das Backlog als Ganzes

| Nr. | Kriterium |
|---|---|
| B1 | **konsistent** — keine zwei Einträge widersprechen sich |
| B2 | **nicht redundant** — kein Sachverhalt steht zweimal |
| B3 | **vollständig** — nichts Relevantes aus Abschnitt 5 und 6 fehlt |
| B4 | **änderbar** — Änderungen kommen als neuer Eintrag herein und werden vom Product Owner eingeordnet (6.6) |
| B5 | **verfolgbar** in drei Richtungen: rückwärts zum Ursprung, vorwärts zu Umsetzung und Test, seitwärts zu abhängigen Anforderungen (6.6) |
| B6 | **konform zu 4.4** — der präskriptive Teil ist abgebildet und nicht wegpriorisiert |

## Drei Kriterien wiegen schwerer

Adäquatheit und Verständlichkeit sind nach IREB die wichtigsten. Für dieses
Projekt kommt **Prüfbarkeit gleichrangig dazu**, weil die Definition of Done
eine maschinell prüfbare Befehlskette verlangt (3.4). Ein Eintrag ohne testbares
Abnahmekriterium erfüllt die Definition of Ready nicht.

Die Definition of Ready ist der Ort, an dem der menschliche Anteil der
80/20-Aufteilung am meisten bewirkt: **Ein schlecht formulierter Eintrag erzeugt
sauberen Code für das falsche Problem** (6.5).

## Notation der Abnahmekriterien (R6)

**Vorschlag zur Bestätigung durch den Auftraggeber.** Bis zur Bestätigung
beschreibt dieser Abschnitt die geübte Praxis, er setzt sie nicht.

Die Zeilenform bleibt, wie der Backlog sie führt:
`- **Abnahme:** Test <Kennung>_<name> — <Bedingung>.` Die Bedingung ist **ein**
Satz aus vier Gliedern. Die Reihenfolge im Satz ist frei; es sind Satzglieder,
keine Überschriften und keine Tabellenspalten. Die vier Namen sind wörtlich die
der Arbeitseinheit "Befund F" vom 2026-08-26 (`docs/05_Product_Backlog.md`,
R3-F-024: "Unverändert bleiben Umfang, Prüfsatz, Nachbedingung und
Gegenprobe"; dieselbe Aufzählung in
`docs/uebergaben/2026-08-26_befund-f-abnahmekriterien.md`).

**Wörtlich sind die Namen, nicht die Bestimmungen: Befund F benennt die vier
Glieder und bestimmt keines davon.** Die Spalte "Was es benennt" steht deshalb
hier zum ersten Mal. Sie liest ab, wie Befund F die so benannten Glieder
anwendet, und setzt nichts von aussen hinzu — nachprüfbar an den vier
Kriterien von R3-F-024.

| Glied | Was es benennt | Wann Pflicht |
|---|---|---|
| **Umfang** | Menge und Zähleinheit, über die das Kriterium gilt ("je registriertes Werkzeug", "über alle schreibenden Stellen"). Ist die Zähleinheit strittig, wird sie ausdrücklich benannt | immer |
| **Prüfsatz** | die Eingaben oder Fälle, gegen die geprüft wird | sobald das Kriterium Eingaben kennt; entfällt bei einer reinen Bestands- oder Existenzaussage |
| **Nachbedingung** | was nach dem Lauf gilt: die beobachtbare Reaktion (Abweisung, Meldung, Protokolleintrag) **und** der Zustand danach, einschliesslich dessen, was nachweislich nicht existiert | immer |
| **Gegenprobe** | der zulässige Fall, der durchlaufen muss | bei jedem Kriterium, das eine Abweisung, eine Sperre oder eine Nullaussage verlangt |

Dass die Nachbedingung beides umfasst, ist abgelesen und nicht hinzugefügt:
`R3-F-024_schreibweg_name_von_der_person` führt die Abweisung "mit
Protokolleintrag, der die Stelle und die abgewiesene Angabe nennt" und den
Satz "nach dem Lauf existiert ausserhalb des je Fall vorgesehenen Ablageorts
keine neue und keine geänderte Datei" in einem Satz und trennt sie nicht.
Sachlich sind beides Aussagen über den Zustand nach dem Lauf. Ein Kriterium,
das nur die Reaktion nennt, lässt offen, was der abgewiesene Versuch
hinterlassen hat — bei einer Pfadangabe von aussen ist genau das die Frage.

Die Gegenprobe trägt am meisten: Ein Kriterium, das nur "null Treffer" oder
"wird abgewiesen" prüft, ist auch dann grün, wenn die geprüfte Funktion gar
nicht gebaut ist. Erst der zulässige Fall unterscheidet eine wirksame Sperre von
einer fehlenden Fähigkeit.

Geschnitten wird nach **Sachverhalt, nicht nach Prüffall**: Mehrere Eingaben
desselben Sachverhalts bleiben unter einem Testnamen, ein zweiter Sachverhalt
bekommt ein zweites Kriterium mit eigenem Namen (D7).

### Weshalb weder EARS noch Given/When/Then

Beide Formen sind an vierzehn Kriterien des Bestands geprüft (R3-C-001,
R3-C-002, R3-Q-001, R3-Q-002, R3-Q-005, R3-Q-007, R3-F-002, R3-F-005, R3-F-011,
R3-F-014, R3-F-018, R3-F-022, R3-F-024, R3-F-028) und **nicht** übernommen.

- **EARS** ist eine Notation für Anforderungssätze ("das System muss ..."), nicht
  für Abnahmekriterien. Die Satzform der Anforderung ist mit 6.4 bereits gesetzt
  — Satzschablone für funktionale Anforderungen, Aussagesatz mit Quelle für
  Randbedingungen. Eine zweite Satzform dort wäre eine Änderung am
  Projektauftrag, nicht an dieser Definition. Übernommen ist der Gedanke, der
  EARS trägt: dass der Geltungsbereich einer Aussage zum Satz gehört — bei uns
  das Glied Umfang.
- **Given/When/Then** hat kein Glied für den Umfang, obwohl in **elf der
  vierzehn** geprüften Kriterien gerade die Allaussage über eine Menge das
  Tragende ist. **Sechs der vierzehn** (R3-C-001, R3-C-002, R3-Q-007, R3-F-011,
  R3-F-014, R3-F-018) behaupten einen Bestand oder eine Nichtexistenz und kennen
  gar keinen Auslöser; das "When" bliebe leer oder würde gefüllt. Und
  Given/When/Then kennt ein Szenario je Kriterium: Es zerlegte
  `R3-F-024_schreibweg_name_von_der_person` (alle schreibenden Stellen mal acht
  Angriffsformen) in Dutzende Kriterien und höbe damit den Schnitt wieder auf,
  den "Befund F" am 2026-08-26 bewusst nach Sachverhalt gelegt hat. Ein Glied
  für die Gegenprobe fehlt ebenfalls; **vier der vierzehn** führen sie
  ausdrücklich mit.

Die drei Zahlen sind nachzählbar, aber nicht ermessensfrei, und das gehört
dazugesagt. R3-F-014 und R3-F-018 mischen eine Bestandsaussage mit einer
beiläufig genannten Handlung ("der Versuch, die Ausführung ohne
Freigabe-Kennung aufzurufen, wird abgewiesen"; "ein Wechsel des Endpunkts ...
lässt die Testsuite unverändert grün"); zu den sechs ohne Auslöser gezählt
sind sie, weil die tragende Aussage der Bestand ist. Bei der Gegenprobe führen
nur R3-F-022 und R3-F-024 das Wort; R3-Q-001 ("bei grünem Prüflauf endet er
mit 0") und R3-Q-005 ("ein zulässiger Schreibzugriff derselben Rollen läuft
durch") sind der Sache nach mitgezählt, nicht dem Wort nach. Wer streng nach
dem Wortlaut zählt, kommt auf vier statt sechs und auf zwei statt vier; die
Zählung der elf beruht auf derselben Art Urteil darüber, was ein Kriterium
trägt. Das Argument hängt an keiner der drei Zahlen im Einzelnen, sondern
daran, dass Umfang und Gegenprobe in keiner Zählweise Randfälle sind.

Zulässig bleibt Given/When/Then als Formulierungshilfe **innerhalb** eines
Kriteriums, wenn ein einzelner Prüffall eine mehrstufige Interaktion beschreibt
— nie als Ersatz für Umfang und Gegenprobe und nie als eigene Zeilenstruktur.

### Geltung

Gilt für **neue** Kriterien und für solche, die aus anderem Grund ohnehin
geändert werden. **Der Bestand wird nicht umgeschrieben.** Der Requirements
Engineer sichtet ihn einmalig im Walkthrough vor dem nächsten Sprint gegen die
vier Glieder und legt eine Befundliste ohne Lösungsvorschlag vor (6.7); jede
Nachbesserung kommt als eigener Backlog-Eintrag über den Product Owner herein
(B4). Erwarteter Schwerpunkt der Befunde ist die fehlende Gegenprobe.

## Zwei Reihenfolge-Gates

| Gate | Wirkung |
|---|---|
| Freigabe-Gate Schritt 4 (Abschnitt 2) | Vor der schriftlichen Freigabe erfüllt **kein** Umsetzungseintrag die Definition of Ready |
| Prototyp-Freigabe (5.6) | Frontend-Einträge ab R3-F-051 werden vorher nicht verfeinert und nicht geschätzt; Schätzungen vor dem Review wären Vermutungen (6.8) |

---

# Teil 2 — Definition of Done

**Das Abbruchkriterium ist ein Rückgabewert, kein Satz** (3.4). Die Aussage "Die
Aufgabe ist erledigt" ist kein Nachweis, sondern eine Behauptung.

## Die Befehlskette

Eine Aufgabe gilt als erledigt, wenn **jeder** Schritt mit Rückgabewert 0 endet.
Die Kette ist die verbindliche Form; die konkreten Befehle je Schritt stehen
als Vorschlag des Software Architects in **ADR 0002, Abschnitt 6** — die
Bestätigung durch DevOps Engineer und Auftraggeber steht aus (dortige offene
Punkte) — mit `make dod`
als einem Einstieg für die Gates aus R3-Q-001. Sie stehen dort genau einmal —
diese Tabelle nennt die Kriterien, der ADR die Befehle. Die technische
Bestätigung durch den DevOps Engineer und die abschliessende Bestätigung durch
den Auftraggeber — samt der Schwellenwerte aus E-07 und E-08 — erfolgen mit
R3-Q-001; dort werden auch die Befunde des ADR zu D10 und D12 behandelt.

Die Kette bestand bis zur Fortschreibung von ADR 0002, Abschnitt 6, am
2026-08-30 aus den Schritten D1 bis D12; seither ist sie um **D18** ergänzt,
und D11 prüft zwei statt einem Gegenstand. Die Nummer eines Kettenschritts ist
dabei eine Kennung, keine Reihenfolge: Frühere Nummern werden nicht neu
vergeben, ein neuer Schritt erhält die nächste freie Nummer, und die
Ausführungsreihenfolge steht in der Zielliste von `make dod`, nicht in der
Zahl. Einzelheiten und Begründung bei D11 und D18 unten sowie in ADR 0002,
Abschnitt 6.1.

**Seit dem 2026-09-01 zwei Nummern mehr.** In die Zielliste kommt **D20**
(Belege) hinzu, und zwar als **erster** Schritt vor D1; ausserhalb der
Zielliste steht die Rahmenprüfung **D19** (Unverändertheit des Arbeitsbaums),
die den ganzen Lauf einklammert und deshalb kein eigenes `make`-Ziel hat. Die
Ausführungsreihenfolge lautet damit D20, D1 bis D4, D18, D5 bis D12 (ADR 0002,
Abschnitt 6, "Ein Einstieg für den Hook", fortgeschrieben in 6.8.2). Die
Wendung "Kette D1 bis D12" ist damit ein zweites Mal unvollständig geworden und
wird hier nicht weiterverwendet.

**Wann eine D-Nummer vergeben ist.** Zur Nummernregel oben kommt der Satz aus
ADR 0002, 6.8.1: **Eine D-Nummer ist vergeben, sobald ein ADR sie vergibt** —
nicht erst, wenn die Nachführung sie erreicht hat. Der gemeinsame Namensraum
wird aus der Vereinigung dieses Dokuments und der Architekturentscheide
gelesen; bei Abweichung
gilt der frühere Vergabezeitpunkt. Anlass ist diese Datei selbst: Sie führte
D19 vom 2026-08-30 bis zum 2026-09-01 nicht, und wer die Freiheit einer Nummer
an ihr ablas, hätte D19 ein zweites Mal vergeben.

**Woraus die Nachführung vom 2026-09-01 schöpft.** Die Kriterien zu D19 und D20
und der Grundsatz weiter unten sind aus ADR 0002 geschrieben — Abschnitt 6
(Schritttabelle, Objekttabelle, Kettengrundsatz), 6.2.1 und 6.4 für D19,
6.8.1 bis 6.8.5 für D20 —, nicht aus einer Zusammenfassung davon. Zusätzlich
gelesen sind der Kopfkommentar des `Makefile`, sein Ziel `belege`, der
D19-Teil seines Ziels `dod` und der Kopfkommentar von
`scripts/belege-pruefen.sh`; daraus stammen ausschliesslich die Angaben zur
heutigen Umsetzung. **Nicht ausgeführt** hat diese Rolle `make dod` und
`bash scripts/belege-pruefen.sh`: Sie hat kein Ausführungswerkzeug und prüft
ihre eigene Arbeit ohnehin nicht (3.4). Jede Aussage über einen ausgeführten
Lauf — die in drei Runden gefangenen Fehlerklassen, null Funde über den
heutigen Bestand bei 30 Ausnahmen, das Umschlagen auf 46 Funde beim Entstehen
eines Teilbaums — ist **Fremdbeleg** aus
`docs/uebergaben/2026-09-01_belegpruefer-abbruch-nach-3-4.md` und aus ADR 0002,
6.8; sie ist hier nicht nachgeprüft und wird nicht als eigene Beobachtung
geführt.

**Ergänzung für die zweite Nachführung desselben Tages.** Für den zweiten Teil
des D19-Prüfmittels, die geschärfte Lage C und die Aussagegrenze der Meldung
sind zusätzlich gelesen: ADR 0002, 6.9 und 6.10 vollständig, die
D19-Festlegungstabelle und die Lagentabelle in Abschnitt 6 sowie die offenen
Punkte O-16 und O-17 in Abschnitt 8. Die Messtabelle weiter unten zu O-16 ist
ein **ausgeführter Lauf des Koordinators** — weder diese Rolle noch der
Software Architect hat ihn ausgeführt; ADR 0002, 6.10.1 führt ihn ebenfalls als
Fremdbeleg. Ebenfalls nachgeschlagen und nicht übernommen: dass die vier
Stellen, die im ADR die achte Fortschreibung uneinheitlich datierten, jetzt
denselben Tag tragen (offener Punkt 8 unten).

**Woraus die dritte Nachführung vom 2026-09-01 schöpft.** Eine unabhängige
Prüfung auf einem anderen Modell als die Umsetzung hatte am 2026-09-01 einen
blockierenden Befund zu D20 gemeldet: Das Kriterium nannte sechs Prüfmittel,
geprüft wurden bis dahin nur drei. Für die Behebung sind vollständig gelesen:
das Makefile-Ziel `belege` — namentlich der Wächter-Block, der `git`, den
Arbeitsbaum und die Existenz der drei Dateien vor jeder Verwendung prüft, und
die getrennte Auswertung des Rückgabewerts von `scripts/belege-pruefen.sh` (3
gegenüber jedem anderen Wert ungleich 0) — sowie `scripts/belege-pruefen.sh`
selbst, namentlich der Wächter für die drei Pfade, die Prüfung beider
Referenzmengen auf Nichtleere und der Abschnitt zum Rückgabewert. Für die
beiden Ergänzungen zu D19 ist vollständig gelesen der D19-Teil des Rezepts von
`dod` in `Makefile`, namentlich der Zweig, der die Statuszeile und die
Inhaltsprüfsumme-Differenz bei Abweichung meldet ("VERLETZT"), und der Zweig,
der bei stummgeschaltetem Index laufbezogen meldet, ob beide Hälften des
Instruments vorher und nachher gleich waren. **Nicht ausgeführt** hat diese
Rolle weder `make dod` noch `bash scripts/belege-pruefen.sh` — dieselbe
Einschränkung wie bei der Nachführung vom 2026-08-30 (3.4). Die drei
Gegenproben zu D20 (Ausnahmeliste beiseitegelegt, Backlog beiseitegelegt,
Backlog vorhanden aber ohne jede Anforderungskennung) und der Verletzungstest
zu D19 (Hintergrundlauf, Änderung nach drei Sekunden) sind **Fremdbeleg** aus
der unabhängigen Prüfung vom 2026-09-01; sie sind hier nicht selbst
nachvollzogen und werden nicht als eigene Beobachtung geführt.

| Nr. | Schritt | Kriterium |
|---|---|---|
| D1 | Bau | Der Programmstand baut fehlerfrei — aus der Sperrdatei und **ohne Zwischenspeicher**: jedes Paket wird geladen und dabei gegen `uv.lock` geprüft. Eine Abweichung zwischen `pyproject.toml` und `uv.lock` macht den Schritt rot (Entscheid des Auftraggebers vom 2026-08-31 zu O-13, ADR 0002, 6.7) |
| D2 | Formatierung | Keine Abweichung vom Projekt-Codingstandard |
| D3 | Linter | Null Fehler; Warnungen unterhalb des vereinbarten Schwellenwerts |
| D4 | Typprüfung | Null Fehler |
| D5 | Testsuite | Alle Tests grün, keine übersprungenen Tests ohne begründete Markierung |
| D6 | Testabdeckung | Über dem vereinbarten Schwellenwert; **Vorschlag zur Bestätigung: 80 Prozent Zeilenabdeckung, 100 Prozent für Module, die Protokoll, Klassifizierung oder Freigabesperre umsetzen** |
| D7 | Aufgabenspezifische Abnahmekriterien | Jedes Abnahmekriterium des Backlog-Eintrags liegt als bestandener Test mit der Anforderungskennung im Testnamen vor (6.6) |
| D8 | Abhängigkeitsprüfung | Keine Abhängigkeit mit bekannter Schwachstelle oberhalb der vereinbarten Schwelle |
| D9 | Kein Rückkanal | Der Prüfschritt aus R3-C-004 endet mit 0 |
| D10 | Prototyp-Trennung | Der Prüflauf des Gates `block-prototype-import.sh` findet keinen Verstoss |
| D11 | Geheimnisse | Secret-Scanning findet keinen Schlüssel und kein Token — geprüft in zwei eigenständigen Läufen, Arbeitsbaum und Git-Historie; keiner der beiden Läufe ersetzt den anderen (vorher: nur die Historie; Fortschreibung 2026-08-30, ADR 0002, Abschnitt 6.1.1) |
| D12 | Nachweise | Das Nachweisverzeichnis `docs/NACHWEISE.md` ist neu erzeugt und der Commit-Verweis stimmt |
| D18 | Architekturverträge | Der Importprüfer findet keinen Verstoss gegen die Modulgrenzen aus ADR 0002, Abschnitt 4.3; läuft in der Zielliste von `make dod` nach D4 und vor D5. Nummer D18, nicht D13: D13 bis D17 sind unten an die menschlich zu bestätigenden Bedingungen vergeben (Fortschreibung 2026-08-30, ADR 0002, Abschnitt 6.1.2) |
| D20 | Belege | Über die versionierten Markdown-Dateien der Wurzel, unter `docs/` und unter `.claude/` zeigt kein Zeilenverweis, keine Commit-Prüfsumme, keine Anforderungskennung, kein Pfadverweis und keine Abschnittsangabe des Projektauftrags auf etwas Nichtvorhandenes, und keine Stelle verwendet die nach 6.6 unzulässige Zweigform statt der Commit-Prüfsumme. **Ein grüner Lauf sagt, dass keine der geprüften Angaben ins Leere zeigt. Er sagt nicht, dass der Fundort die Behauptung trägt, die ihm zugeschrieben wird — das prüft kein Werkzeug, und es bleibt beim menschlichen Review.** Läuft als **erster** Schritt der Kette, vor D1. **Keine Lage B**: ein leerer Bestand wäre ein Befund und kein leerer Gegenstand. **Sechs Prüfmittel tragen die Prüfung, und alle sechs werden geprüft** — im Makefile-Ziel `belege` vorab, in `scripts/belege-pruefen.sh` zusätzlich vor jeder Verwendung: `git`, der Arbeitsbaum, `scripts/belege-pruefen.sh` selbst, `scripts/belege-ausnahmen.txt` sowie die beiden Bezugsdokumente `docs/05_Product_Backlog.md` und `docs/00_Projektauftrag.md`. Fehlt eines der sechs, ist das Lage C und endet ungleich 0 (Fortschreibung 2026-09-01, dritte Nachführung des Tages; zuvor prüften Makefile-Ziel und Skript nur die ersten drei — Befund einer unabhängigen Prüfung, das Kriterium war richtig formuliert und nicht erfüllt). **Für die beiden Bezugsdokumente genügt Vorhandensein allein nicht** (geschärfte Lage C: das Prüfmittel fehlt oder trägt die Aussage nicht): Sie müssen zusätzlich eine **nicht leere Referenzmenge** hergeben — mindestens eine Anforderungskennung als Überschrift in `docs/05_Product_Backlog.md`, mindestens eine Abschnittsnummer als Überschrift in `docs/00_Projektauftrag.md` —, sonst ist die vorhandene Datei derselbe Ausfall wie eine fehlende. **Für `scripts/belege-ausnahmen.txt` gilt das nicht**: eine vorhandene, leere Liste ist ein zulässiger Zustand — es gibt dann keine Ausnahmen —, nur eine fehlende Liste ist Lage C, weil sie jede begründete Ausnahme stumm wegfallen liesse. Das Skript gibt dabei **drei** Rückgabewerte aus, nicht zwei: 0 keine Beanstandung, 2 mindestens ein Befund am Bestand, 3 Lage C; das Makefile-Ziel führt beide roten Ausgänge getrennt weiter — A_FAIL beziehungsweise Lage C —, weil "etwas gefunden" und "nicht gemessen werden konnte" verschiedene Aussagen sind (ADR 0002, Abschnitt 6.11). Das Prüfmittel ist nach Eskalationsregel 3.4 abgebrochen und **nicht abgenommen** (offener Punkt 5 unten); die Aufnahme in die Kette hängt nicht an der Abnahme. Nummer D20, nicht D13 und nicht D19: beide sind vergeben (Fortschreibung 2026-09-01, ADR 0002, Abschnitt 6.8) |

## Wann ein Schritt urteilt, wann er entfällt, wann er ausfällt

*(Aufgenommen am 2026-09-01. Welche Bedingung für welchen Schritt gilt, steht
abschliessend in der Objekttabelle von ADR 0002, Abschnitt 6; hier steht, was
die drei Lagen für die Definition of Done bedeuten.)*

Jeder Kettenschritt urteilt über eine Sache, nicht über einen Verzeichnisnamen.
Jede Lage hat genau einen Ausgang:

| Lage | Bedingung | Ausgang |
|---|---|---|
| A | Gegenstand vorhanden, Prüfmittel vorhanden | Der Schritt urteilt: 0 oder ungleich 0 |
| B | Gegenstand nicht vorhanden | Der Schritt entfällt **mit Meldung**, Rückgabewert 0. Nicht jeder Schritt hat eine Lage B: Nennt die Objekttabelle für ihn keine, gibt es für ihn keine — er läuft immer. So beim zweiten Teil von D7 und bei D20; bei D10 und D12 ist eine Lage B benannt, die nach derselben Tabelle nicht eintritt |
| C | Gegenstand vorhanden, Prüfmittel **fehlt oder trägt die Aussage nicht** — es ist unlesbar, unbrauchbar oder stummgeschaltet *(geschärft am 2026-09-01, ADR 0002, 6.9.2)* | Rückgabewert **ungleich 0**. Ein fehlendes Prüfmittel ist kein bestandener Schritt, und ein vorhandenes, das nicht messen kann, ebenso wenig |

Die Schärfung von Lage C schafft keine neue Freiheit, sie bringt den Wortlaut
auf den Stand der bereits getroffenen Entscheidungen: D18 meldet Lage C, wenn
die Vertragsdatei zwar besteht, aber nicht lesbar ist, und D7 endet ungleich 0,
wenn die gefundene Backlog-Datei keine Abnahmekriterien führt. In beiden Fällen
ist das Prüfmittel da und trägt die Aussage nicht.

Für die Definition of Done heisst das: **Eine Aufgabe gilt auch dann nicht als
erledigt, wenn ein Schritt zwar lief, aber nicht messen konnte.** Und die Lage
wird ausgegeben, nicht erschlossen — ein Schritt, der mit 0 endet, muss von
einem unterscheidbar sein, der nichts geprüft hat.

## Ein Prüflauf verändert den Gegenstand nicht, über den er urteilt

Kein Kettenschritt ändert eine versionierte Datei des Arbeitsbaums — weder
erzeugend noch formatierend noch nebenbei ein Verzeichnis neu schreibend.
Erzeugnisse eines Bauschritts liegen ausschliesslich in Pfaden, die die
Versionsverwaltung ignoriert. Grund: Sonst hängt das Ergebnis eines Schrittes
davon ab, welcher Schritt vorher lief — mit D11 seit dieser Fortschreibung
unmittelbar wirksam, weil D11 über den Arbeitsbaum urteilt. Grundsatz
aufgenommen mit der Fortschreibung vom 2026-08-30, ADR 0002, Abschnitt 6.1.3.

### Beobachtet, nicht nur zugesichert — die Rahmenprüfung D19

*(Nachgetragen am 2026-09-01. Vergeben hat die Nummer ADR 0002 mit der zweiten
Fortschreibung vom 2026-08-30, Abschnitt 6.2.1; die Messweise ist in 6.4
desselben Tages nachgeschärft. Bis heute fehlte D19 in dieser Datei.)*

Der Grundsatz oben war bis dahin beobachtbar, aber von nichts beobachtet. Er
hängt jetzt an zwei voneinander unabhängigen Massnahmen, von denen keine die
andere ersetzt: je Schritt vermeidend — kein Kettenschritt ruft ein Werkzeug in
einer Betriebsart auf, die eine versionierte Datei schreiben kann — und je Lauf
beobachtend durch D19.

| Nr. | Prüfung | Kriterium |
|---|---|---|
| D19 | Unverändertheit des Arbeitsbaums | `make dod` nimmt unmittelbar **vor** dem ersten und unmittelbar **nach** dem letzten ausgeführten Kettenschritt den Bestand auf — die Statusliste `git status --porcelain --untracked-files=all` **und** eine Inhaltsprüfsumme je verfolgter Datei — und vergleicht beide Aufnahmen zeilenweise, einschliesslich der unverfolgten Einträge. Massstab ist vorher gegen nachher, **nicht** gegen einen sauberen Arbeitsbaum: Die Kette läuft vor dem Commit und trifft regelmässig einen bereits veränderten Arbeitsbaum an; das ist zulässig, ihn zu verändern nicht. Bei Abweichung endet `make dod` ungleich 0 und nennt die abweichenden Zeilen. Der Befund **kann einen grünen Lauf rot machen, nie einen roten grün**. Die Nachher-Aufnahme läuft auch dann, wenn die Kette an einem früheren Schritt abgebrochen ist — sonst bliebe gerade der Schritt unbeobachtet, der schreibt und zugleich scheitert. **Ergänzt am 2026-09-01 um den zweiten Teil des Prüfmittels (ADR 0002, 6.9): die Beobachtbarkeit des Index.** Vor und nach dem Lauf wird zusätzlich der Bestand der Maskierungsmerkmale verfolgter Dateien erhoben (`assume-unchanged`, `skip-worktree`). Für den **Gegenstand** gilt der relative Massstab oben, für das **Instrument** ein absoluter: Ein gesetztes Maskierungsmerkmal ist ein Befund, **auch wenn es schon vor dem Lauf gesetzt war**. Der Ausgang ist dann **Lage C** mit eigenem Befundtext und ungleich 0 — nicht eine Verletzung des Kettengrundsatzes, denn eine Verletzung ist damit gerade nicht festgestellt. Der Befundtext nennt, **welche Hälfte** des Instruments stumm ist, für welche Dateien, und was die andere Hälfte gemessen hat; er behauptet nicht, der Arbeitsbaum sei unbeobachtet (ADR 0002, 6.10.2) |

**Erstmals ausgeführt belegt (2026-09-01, dritte Nachführung des Tages).**
Dass D19 nicht nur schweigt, wenn nichts ist, sondern auch spricht, wenn etwas
ist, war bis dahin nicht ausgeführt belegt — die unabhängige Prüfung liess
genau diese Lücke ausdrücklich offen. Test: `make dod` im Hintergrund
gestartet, nach drei Sekunden eine verfolgte Datei geändert. D19 meldete
"VERLETZT -- versionierter Bestand veraendert", nannte die geänderte Datei und
zeigte beide Hälften des Prüfmittels — die Statuszeile und die abweichende
Inhaltsprüfsumme. Ein Instrument, das nur die Abwesenheit einer Veränderung
feststellt, wäre von einem nicht messenden nicht unterscheidbar; erst der
belegte Ausschlag unterscheidet beides.

Vier Eigenschaften gehören zur Kennung dazu:

- **D19 ist kein Schritt der Zielliste und hat kein eigenes `make`-Ziel.** Ein
  Schritt in der Liste sähe nur seinen eigenen Augenblick und könnte nicht
  beurteilen, was ein späterer Schritt schreibt; ein Schritt am Ende der Liste
  liefe bei einem früheren Abbruch gar nicht. Eine Nummer trägt die Prüfung
  trotzdem, damit Definition of Done, Backlog und Nachweise sie benennen können.
- **Gemessen wird der Inhalt, nicht die Namensliste.** Die blosse Statusliste
  sagt, **welche** Dateien abweichen, nicht **wie**: Eine schon vor dem Lauf
  geänderte Datei trägt vorher wie nachher denselben Eintrag, auch wenn ein
  Kettenschritt sie während des Laufs erneut ändert. Deshalb die Prüfsumme je
  verfolgter Datei (ADR 0002, 6.4). Der Preis — zwei Läufe über alle verfolgten
  Dateien je `make dod` — ist dort benannt und angenommen.
- **D19 ersetzt die Schalter je Schritt nicht, und umgekehrt.** `--locked`
  verhindert den häufigsten Fall, bevor er eintritt, und nennt seine Ursache;
  D19 fängt jeden Fall, an den niemand gedacht hat, kann aber nur feststellen,
  **dass** geschrieben wurde.
- **Der Arbeitsbaum wird über die Versionsverwaltung festgestellt, nicht über
  einen Verzeichnisnamen.** Ist die Versionsverwaltung nicht ausführbar, gilt
  hilfsweise die Anwesenheit von `.git` — als Datei **oder** als Verzeichnis,
  weil es in einem zusätzlichen Arbeitsbaum und in einem Untermodul eine Datei
  ist (ADR 0002, 6.9.3).

### Zwei Massstäbe, und weshalb sie sich nicht widersprechen

Ein bereits veränderter Arbeitsbaum ist der normale Betriebszustand vor einem
Commit und beeinträchtigt die Messung nicht — deshalb wird der **Gegenstand**
relativ gemessen, vorher gegen nachher. Ein maskierter Index beeinträchtigt die
Messung dagegen für die ganze Dauer des Laufs — deshalb wird das **Instrument**
absolut verlangt. Ein stummgeschaltetes Messmittel wird nicht dadurch
verlässlich, dass es schon vor dem Lauf stummgeschaltet war. Der Massstab kostet
im Normalfall nichts: Ein Maskierungsmerkmal entsteht nicht versehentlich, es
wird gesetzt; wo keines gesetzt ist, meldet der Schritt nichts (ADR 0002,
6.9.2 und 6.10.3).

### Was die Befundmeldung sagen darf

Wie weit die Maskierung die Messung beeinträchtigt, ist gemessen worden:

| Instrumententeil | Verhalten bei gesetztem `skip-worktree` und angehängter Zeile |
|---|---|
| Statusliste (`git status --porcelain --untracked-files=all`) | **blind** — die Änderung erscheint nicht |
| Inhaltsprüfsumme je verfolgter Datei | **erfasst die Änderung** — die Prüfsumme weicht vorher gegen nachher ab |

**Herkunft dieser Tabelle: ein ausgeführter Lauf des Koordinators vom
2026-09-01** (Wegwerf-Klon, Maskierung mit `git update-index --skip-worktree`
auf eine verfolgte Datei, danach eine Zeile angehängt, beide Hälften des
Instruments vorher und nachher aufgenommen). Übernommen als **Fremdbeleg** über
ADR 0002, 6.10.1; weder der Requirements Engineer noch der Software Architect
hat ihn ausgeführt.

Damit trägt für einen Lauf mit gesetzter Maskierung und ohne Abweichung der
Prüfsummen genau diese Aussage: *Der Inhalt der verfolgten Dateien ist
unverändert. Für die maskierten Dateien trägt allein die Inhaltsprüfsumme;
alles, was nur die Statusliste sieht, ist für sie nicht beurteilt.* Das ist
schwächer als "unbeobachtet" und schwächer als "unverändert" — und die einzige
der drei Aussagen, die belegt ist. Der Lauf deckt die Inhaltsänderung einer
vorhandenen, maskierten Datei ab; er sagt nichts über ihre Löschung (offener
Punkt 9 unten), nichts über Rechte- und Typwechsel und nichts über Einträge,
die allein die Statusliste sieht.

**Ergänzt am 2026-09-01 (dritte Nachführung des Tages) um die laufbezogene
Aussage.** Bis dahin war das oben nur eine allgemeine Aussage über die externe
Messung des Koordinators vom 2026-09-01, keine über den jeweils laufenden Lauf
selbst. Die Meldung bei stummgeschaltetem Index nennt jetzt zusätzlich, **für
diesen Lauf**, ob Statusliste und Inhaltsprüfsummen vorher und nachher gleich
waren — mit dem ausdrücklichen Zusatz, dass diese Gleichheit den Lauf **nicht
entlastet**: Sie kann nicht ausschliessen, was die blinde Hälfte für die
maskierten Dateien gar nicht meldet. Weichen sie ab, steht auch das in der
Meldung, mit der Differenz weiter unten. Schweigen wäre hier keine Messung.

Weshalb die Genauigkeit hier mehr ist als Wortklauberei: Nach 5.3 ist die
Ausgabe der Kette eine Protokollspur, und Negativbefunde sind darin zwingend
enthalten. Wer später liest, der Arbeitsbaum sei unbeobachtet gewesen,
schliesst daraus, über den Inhalt sei nichts bekannt gewesen — obwohl er
gemessen wurde.

## Was ein grüner Kettenschritt aussagt

*(Aufgenommen am 2026-09-01 aus ADR 0002, 6.8.4. Der Grundsatz gilt dort
ausdrücklich für alle Schritte und ändert an keinem Schritt das Verhalten.)*

> **Rückgabewert 0 eines Kettenschritts heisst: nichts von dem gefunden, was
> dieser Schritt sucht. Er heisst nie: nichts vorhanden.** Ein grünes
> `make dod` ist der Nachweis, dass die Kette gelaufen ist und nichts gefunden
> hat — nicht der Nachweis, dass die Arbeit richtig ist. Die menschlich
> bestätigten Bedingungen D13 bis D17 stehen genau deshalb daneben und werden
> durch keinen grünen Lauf ersetzt.

Jeder Schritt ist eine Negativaussage über seinen eigenen Suchraum: Eine
Formatprüfung sagt nichts über den Entwurf, eine Abhängigkeitsprüfung sagt
nicht, dass keine Schwachstelle besteht, sondern dass keine in der verwendeten
Datenbank steht, und ein Geheimnis-Scanner sagt nicht, dass kein Schlüssel
vorliegt, sondern dass keiner seinen Mustern entsprach. D20 sagt damit nichts
Schwächeres als die übrigen Schritte; er ist der einzige, dessen Werkzeug es
selbst ausspricht.

Zwei Folgen für die Definition of Done:

- Der Punkt "Ein grüner Prüflauf allein" weiter unten ist damit keine Aussage
  über das Vertrauen in ein einzelnes Werkzeug, sondern eine Eigenschaft der
  ganzen Kette. Die menschliche Prüfung wird nicht dadurch entbehrlich, dass
  mehr Schritte hinzukommen.
- **Kein Kettenschritt belegt, was ein anderer zu belegen hat.** D20 prüft, dass
  eine Anforderungskennung als Überschrift im Backlog steht; er sagt damit
  nicht, dass zu dieser Anforderung ein Test existiert — das ist die Aussage von
  D7 — und nicht, dass das Nachweisverzeichnis stimmt — das ist D12. Ein
  Abnahmekriterium nach R6 gilt erst mit dem bestandenen Test unter D7 als
  erfüllt.

## Ergänzende Bedingungen, die kein Befehl prüft

Diese Punkte sind Teil der Definition of Done, werden aber von Menschen oder
Rollen bestätigt, nicht von einem Rückgabewert:

| Nr. | Bedingung | Wer bestätigt |
|---|---|---|
| D13 | Die umsetzende Rolle hat ihre Arbeit **nicht** selbst verifiziert | Scrum Master |
| D14 | Static und Dynamic Software Tester haben geprüft, auf einem anderen Modell als die Umsetzung (3.4) | Beide Tester |
| D15 | Die Übergabedatei nach 3.3 ist geschrieben | Umsetzende Rolle |
| D16 | Bei Änderungen an Protokoll, Herkunft, Export oder Löschweg: Prüfbericht des Digital-Forensics-Spezialisten liegt vor | Digital-Forensics-Spezialist |
| D17 | Bei Änderungen am präskriptiven Teil (4.4): GRC-Rolle und Auftraggeber haben entschieden, nicht der Product Owner (6.6) | GRC-Rolle |

## Was nicht als erledigt gilt

- Ein Abnahmekriterium, das sich nicht als Test formulieren lässt. Es gilt als
  **offen** und geht an den Auftraggeber zurück (3.4).
- Ein halbfertiger Zustand. Entweder die Einheit erfüllt die Definition of Done,
  oder sie wird zurückgesetzt (3.3).
- Ein grüner Prüflauf allein. **Eine Prüfung, die nur feststellt, dass die Tests
  gelaufen sind, kann nicht feststellen, dass die Tests das Falsche testen**
  (3.4). Die Iterationspflicht ersetzt das menschliche Review nicht, sie
  entlastet es nur von offensichtlichen Mängeln.

## Durchsetzung

Die Kette wird über Hooks erzwungen, nicht über eine Absichtserklärung:

| Hook | Wirkung |
|---|---|
| `TaskCompleted` | Rückgabewert 2 verhindert, dass eine Aufgabe als abgeschlossen markiert wird, solange die Kette rot ist |
| `Stop` und `SubagentStop` | Rückgabewert 2 verhindert das Beenden und gibt über stderr zurück, was noch fehlt |

**Nur Rückgabewert 2 blockiert.** Rückgabewert 1 ist ein nicht blockierender
Fehler; ein Gate, das mit `exit 1` endet, ist wirkungslos, ohne dass das
auffällt (3.4).

Schutz vor der Endlosschleife, verbindlich (3.4, Ebene 4):
- **Reentranz:** Ist `stop_hook_active` gesetzt, endet der Hook mit 0.
- **Obergrenze:** Acht Blockaden in Folge ohne Fortschritt übersteuert Claude Code
  selbst; anpassbar über `CLAUDE_CODE_STOP_HOOK_BLOCK_CAP`. Notbremse, kein
  Ersatz für den Reentranz-Schutz.
- **Turn-Begrenzung:** `maxTurns` je Rolle, gesetzt in allen 21 Rollendateien.
- **Eskalation:** Scheitert dieselbe Prüfung dreimal am gleichen Kriterium, wird
  abgebrochen, die Übergabedatei geschrieben und die Aufgabe vorgelegt.

Diese Hooks entstehen als Backlog-Eintrag R3-Q-001. Sie konnten vor dieser
Definition nicht gebaut werden, weil es kein Kriterium gab, das sie prüfen
könnten.

## Definition of Done des Prototyps — Sonderfall

Für R3-F-050 gilt eine eigene Definition of Done (5.6), weil ein Prototyp keine
Fachlogik hat, die man testen könnte: maschinell prüfbar sind Bau, Erreichbarkeit
jeder Ansicht, Freiheit von toten Verweisen und die WCAG-2.2-AA-Prüfung; das
Abbruchkriterium ist zusätzlich die **schriftliche Zustimmung von Auftraggeber
und Studienkollegen**. Das ist eine ausdrückliche Ausnahme von 3.4 und gilt nur
für den Prototyp.

---

# Offene Punkte

| Nr. | Punkt | Wer entscheidet |
|---|---|---|
| 1 | Bestätigung der Abdeckungsschwelle in D6 | Auftraggeber |
| 2 | Schwellenwert für Linter-Warnungen (D3) und für Abhängigkeitsschwachstellen (D8) | Auftraggeber mit SecDevOps |
| 3 | Konkrete Befehle je Kettenschritt: eingesetzt am 2026-08-20 mit ADR 0002, Abschnitt 6 (Einstieg `make dod`), am 2026-08-30 fortgeschrieben (Abschnitt 6.1: D11 auf zwei Gegenstände erweitert, D18 ergänzt, Kettengrundsatz aufgenommen); offen bleibt die technische Bestätigung samt der Befunde zu D10 und D12 sowie der Prüffläche des Arbeitsbaumlaufs in D11 (O-10). **Nachgeführt am 2026-09-01:** dazu kommen die Rahmenprüfung D19 (ADR 0002, 6.2 und 6.4) und der Kettenschritt D20 (6.8); beide sind ebenso unbestätigt wie die übrige Kette. Dasselbe gilt für die Ergänzungen der neunten und zehnten Fortschreibung desselben Tages — zweiter Teil des D19-Prüfmittels, geschärfte Lage C, Aussagegrenze der Meldung — sowie für die dritte Nachführung desselben Tages: die Sechs-Prüfmittel-Prüfung und die geschärfte Referenzmengen-Bedingung bei D20, der ausgeführte Verletzungstest und die laufbezogene Aussage bei D19 | DevOps Engineer und Auftraggeber, mit R3-Q-001 |
| 4 | Bestätigung der Notation der Abnahmekriterien zu R6 (Teil 1): die vier Glieder **samt ihrer dort erstmals gegebenen Bestimmung** — die Namen stammen wörtlich aus Befund F, die Bestimmungen nicht —, die Pflicht zur Gegenprobe und die Geltung nur für neue und ohnehin geänderte Kriterien | Auftraggeber |
| 5 | **Abnahme des Prüfmittels von D20.** Es ist nach Eskalationsregel 3.4 abgebrochen und nicht abgenommen; seine Selbstauskunft erklärt die Liste der eigenen Grenzen ausdrücklich für unvollständig. Offen ist, welches Abnahmekriterium für ein Werkzeug gilt, das eine Nachweiskette blockiert (ADR 0002, O-15) | Static und Dynamic Software Tester, auf einem anderen Modell als die Umsetzung (3.4); Entscheid über das Abnahmekriterium beim Auftraggeber |
| 6 | **Aussagekraft von D20 je Arbeitsplatz.** Das Prüfmittel liest ein zweites Repository an einem fest verdrahteten Ort mit; fehlt es dort, zählt es die betroffenen Zeilen als nicht prüfbar, ohne dass diese Zählung in den Rückgabewert eingeht (ADR 0002, O-14) | DevOps Engineer mit Protocol Master |
| 7 | **Erledigt am 2026-09-01.** Befund der ersten Nachführung desselben Tages: Das Mittel von D19 stand in ADR 0002 und im `Makefile` verschieden — dort Statusliste und Inhaltsprüfsummen, hier zusätzlich die Maskierungsmerkmale des Index. Entschieden in ADR 0002, 6.9: Die Beobachtbarkeit des Index **ist** zweiter Teil des Prüfmittels, ein gesetztes Merkmal ergibt Lage C. Das Kriterium D19 oben ist entsprechend ergänzt | entschieden durch den Software Architect |
| 8 | **Erledigt am 2026-09-01.** Befund der ersten Nachführung desselben Tages: ADR 0002 datierte seine achte Fortschreibung uneinheitlich. Die vier abweichenden Stellen — Kriterium K5, D20-Zeile der Objekttabelle, offene Punkte O-14 und O-15 — tragen jetzt ebenfalls den 2026-09-01; am 2026-09-01 einzeln nachgeschlagen | erledigt durch den Software Architect |
| 9 | **Löschung einer maskierten, verfolgten Datei (ADR 0002, O-17).** Die Aufzählung der verfolgten Dateien führt sie weiter, weil sie im Index steht; die Prüfsummenbildung findet die Datei dann nicht vor. Ob die Aufnahme dadurch abweicht — die Löschung also trotz Maskierung sichtbar wird — oder unverändert bleibt, ist **nicht gemessen**. Am Ausgang ändert die Antwort nichts, die Maskierung bleibt Lage C; sie bestimmt allein, wie weit die Meldung sagen darf, der Inhalt sei beurteilt | DevOps Engineer mit einem ausgeführten Lauf, Verifikation Static und Dynamic Software Tester (3.4) |
| 10 | **Aktualität der Bezugsdokumente (ADR 0002, O-18).** D20 prüft `docs/05_Product_Backlog.md` und `docs/00_Projektauftrag.md` seit der dritten Nachführung vom 2026-09-01 auf Vorhandensein und auf eine nicht leere Referenzmenge — auf Aktualität prüft es nicht. Eine Anforderungskennung, die als Überschrift stehen bleibt, obwohl der Eintrag längst zurückgezogen ist, oder eine Fassung des Projektauftrags, die nicht mehr die geltende ist, fällt durch kein Netz dieses Kriteriums | DevOps Engineer mit Requirements Engineer |
