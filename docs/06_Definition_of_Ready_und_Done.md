# Definition of Ready und Definition of Done

| | |
|---|---|
| **Arbeitsprodukt nach** | Projektauftrag 6.5, 6.8, 3.4 |
| **Verantwortlich** | Scrum Master (Prozess), Requirements Engineer (Ready), Static und Dynamic Software Tester (Done) |
| **Stand** | 2026-08-20, nachgeführt am 2026-08-30 (ADR 0002, Abschnitt 6.1: D18 ergänzt, D11 auf zwei Gegenstände erweitert, Kettengrundsatz aufgenommen; Commit `84450a71569120e8deb30ecb0349ea8a92f6d736`), ergänzt am 2026-08-31 um die Notation der Abnahmekriterien zu R6 — Vorschlag zur Bestätigung |

Beide sind zu unterscheiden: **Ready gilt für den Eingang in den Sprint, Done
für den Ausgang** (6.8).

## Fortschreibungen dieses Dokuments

| Datum | Was vorher galt | Was jetzt gilt | Warum |
|---|---|---|---|
| 2026-08-30 | D11 (Teil 2, Befehlskette) prüfte nach dieser Tabelle "im Programmstand"; der dafür vorgeschlagene Befehl (`gitleaks detect` ohne `--no-git`) durchsuchte in der Praxis ausschliesslich die Git-Historie | D11 prüft zwei Gegenstände in zwei eigenständigen Läufen: Arbeitsbaum und Git-Historie; keiner ersetzt den anderen | Der Hook aus R3-Q-001 läuft als `Stop` beziehungsweise `SubagentStop`, also **vor** dem Commit — der Arbeitsbaum ist damit der Regelfall des Einsatzes. Belegt mit einem ausgeführten Lauf am 2026-08-30 |
| 2026-08-30 | Die Befehlskette (Teil 2) führte D1 bis D12; der von ADR 0002, Abschnitt 3.5, seit dem 2026-08-20 verlangte Importprüfer-Schritt fehlte in dieser Tabelle | Neuer Kettenschritt **D18** (Architekturverträge), in der Zielliste von `make dod` nach D4 und vor D5 eingeordnet | Löst einen Widerspruch innerhalb des ADR auf: Abschnitt 3.5 verlangte den Schritt als eigenen Kettenschritt, die Tabelle in Abschnitt 6 führte ihn nicht |
| 2026-08-30 | Kein Grundsatz hielt fest, dass ein Prüflauf den Arbeitsbaum unverändert lässt | Neuer Grundsatz: Kein Kettenschritt ändert eine versionierte Datei des Arbeitsbaums | Voraussetzung dafür, dass D11 den Arbeitsbaum zuverlässig beurteilt, unabhängig davon, welcher Schritt vorher lief |
| 2026-08-31 | R6 verlangte ein Abnahmekriterium, "das sich als Test formulieren lässt", ohne eine Form dafür zu nennen | Neuer Abschnitt "Notation der Abnahmekriterien (R6)" in Teil 1 — **als Vorschlag zur Bestätigung**, nicht als gesetzte Regel | Ohne benannte Form entsteht die Prüfbarkeit je Eintrag neu und ungleich. Die Form ist am Bestand erhoben, nicht von aussen gesetzt: sie schreibt fest, was die Arbeitseinheit "Befund F" am 2026-08-26 bereits angewandt hat |

Quelle für die drei Zeilen vom 2026-08-30: ADR 0002, Abschnitt 6.1
(`docs/adr/0002-architekturentscheid-ziel-stack.md`), Fortschreibung vom
2026-08-30, Commit `84450a71569120e8deb30ecb0349ea8a92f6d736`. Einzelheiten
unten unter "Die Befehlskette".

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
keine Überschriften und keine Tabellenspalten. Die Benennung ist die, die die
Arbeitseinheit "Befund F" am 2026-08-26 bereits verwendet hat
(`docs/05_Product_Backlog.md`, R3-F-024: "Unverändert bleiben Umfang, Prüfsatz,
Nachbedingung und Gegenprobe").

| Glied | Was es benennt | Wann Pflicht |
|---|---|---|
| **Umfang** | Menge und Zähleinheit, über die das Kriterium gilt ("je registriertes Werkzeug", "über alle schreibenden Stellen"). Ist die Zähleinheit strittig, wird sie ausdrücklich benannt | immer |
| **Prüfsatz** | die Eingaben oder Fälle, gegen die geprüft wird | sobald das Kriterium Eingaben kennt; entfällt bei einer reinen Bestands- oder Existenzaussage |
| **Erwartung** | die beobachtbare Reaktion **und** die Nachbedingung: was danach gilt und was danach nachweislich nicht existiert | immer |
| **Gegenprobe** | der zulässige Fall, der durchlaufen muss | bei jedem Kriterium, das eine Abweisung, eine Sperre oder eine Nullaussage verlangt |

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

## Ein Prüflauf verändert den Gegenstand nicht, über den er urteilt

Kein Kettenschritt ändert eine versionierte Datei des Arbeitsbaums — weder
erzeugend noch formatierend noch nebenbei ein Verzeichnis neu schreibend.
Erzeugnisse eines Bauschritts liegen ausschliesslich in Pfaden, die die
Versionsverwaltung ignoriert. Grund: Sonst hängt das Ergebnis eines Schrittes
davon ab, welcher Schritt vorher lief — mit D11 seit dieser Fortschreibung
unmittelbar wirksam, weil D11 über den Arbeitsbaum urteilt. Grundsatz
aufgenommen mit der Fortschreibung vom 2026-08-30, ADR 0002, Abschnitt 6.1.3.

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
| 3 | Konkrete Befehle je Kettenschritt: eingesetzt am 2026-08-20 mit ADR 0002, Abschnitt 6 (Einstieg `make dod`), am 2026-08-30 fortgeschrieben (Abschnitt 6.1: D11 auf zwei Gegenstände erweitert, D18 ergänzt, Kettengrundsatz aufgenommen); offen bleibt die technische Bestätigung samt der Befunde zu D10 und D12 sowie der Prüffläche des Arbeitsbaumlaufs in D11 (O-10) | DevOps Engineer und Auftraggeber, mit R3-Q-001 |
| 4 | Bestätigung der Notation der Abnahmekriterien zu R6 (Teil 1): die vier Glieder, die Pflicht zur Gegenprobe und die Geltung nur für neue und ohnehin geänderte Kriterien | Auftraggeber |
