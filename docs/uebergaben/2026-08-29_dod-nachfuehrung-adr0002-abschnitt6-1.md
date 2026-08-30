# Übergabe — Arbeitseinheit «DoD-Datei nach ADR 0002, Abschnitt 6.1, nachgeführt»

| | |
|---|---|
| **Arbeitsprodukt nach** | Projektauftrag 3.3 (Übergabedatei je Arbeitseinheit), 4.2 (Protocol Master) |
| **Einheit** | Zwei Dateien, die die Definition-of-Done-Kette benennen, gegen ADR 0002, Abschnitt 6.1 (Fortschreibung vom 2026-08-29) nachführen |
| **Datum** | 2026-08-29 |
| **Rolle** | Protocol Master |
| **Grundlage** | Auftrag des Koordinators; ADR 0002, `docs/adr/0002-architekturentscheid-ziel-stack.md`, Abschnitt 6 und 6.1; Nachzuführen-Tabelle in ADR 0002 Abschnitt 9 |
| **Commit der ADR-Fortschreibung** | `84450a71569120e8deb30ecb0349ea8a92f6d736` — ermittelt aus `.git/refs/heads/claude/next-step-g8slnq` und `.git/logs/HEAD` (Reflog-Zeile: `commit: docs(ADR 0002): Abschnitt 6 fortgeschrieben -- D11 berichtigt, D18 ergaenzt`), nicht Bash-gestützt, da diese Rolle kein `Bash`-Werkzeug führt |

## Worum es ging

Der Software Architect hat ADR 0002, Abschnitt 6, am 2026-08-29 um Abschnitt 6.1
fortgeschrieben: D11 prüft seither zwei Gegenstände (Arbeitsbaum und
Git-Historie statt nur Historie), ein neuer Kettenschritt D18
(Architekturverträge) ist eingefügt, und ein neuer Kettengrundsatz hält fest,
dass kein Prüflauf eine versionierte Datei ändert. Zwei Dateien, die die Kette
in eigenen Worten beschreiben, waren dadurch veraltet.

## Was fertig ist

**`docs/06_Definition_of_Ready_und_Done.md`** — vollständig nachgeführt:

- Stand-Zeile im Kopf um die Fortschreibung vom 2026-08-29 samt Commit-Verweis ergänzt.
- Neuer Abschnitt „Fortschreibungen dieses Dokuments" (vorher/jetzt/warum, dreizeilig, mit Quellenverweis auf ADR 0002 Abschnitt 6.1 und Commit) — Nachweisdokumentation nach dem Grundsatz, dass ein spurlos verschwindender Irrtum kein Nachweis ist.
- Absatz vor der Befehlskette-Tabelle: neue Regel „Nummer ist Kennung, keine Reihenfolge" aufgenommen, mit Verweis auf `make dod` als Ort der Ausführungsreihenfolge.
- Kriterienzeile **D11** auf beide Gegenstände erweitert (Arbeitsbaum und Git-Historie, zwei eigenständige Läufe), mit Vorher/Jetzt-Vermerk und Verweis auf ADR 0002, 6.1.1.
- Neue Kriterienzeile **D18** (Architekturverträge) ergänzt, mit Begründung der Nummer (nicht D13, weil D13–D17 an die menschlich bestätigten Bedingungen vergeben sind) und Verweis auf ADR 0002, 6.1.2.
- Neuer Abschnitt „Ein Prüflauf verändert den Gegenstand nicht, über den er urteilt" (Kettengrundsatz), mit Verweis auf ADR 0002, 6.1.3.
- Offener Punkt 3 der Fusstabelle um die Fortschreibung vom 2026-08-29 und den Verweis auf O-10 (Prüffläche des Arbeitsbaumlaufs) ergänzt.
- Teil 1 (Definition of Ready) und die Tabelle D13 bis D17 in Teil 2 („Ergänzende Bedingungen") sind unangetastet geblieben, wie verlangt.
- Sprachprüfung durchgeführt: kein Eszett, keine typografischen Anführungszeichen (per Grep verifiziert).

## Was offen bleibt — und weshalb

**`.claude/agents/static-software-tester.md` wurde nicht geändert.** Grund:
Die eigene Rollendatei dieser Rolle und `docs/adr/0001-rollenmodell.md`
(Zeile 83, Rollentabelle) legen die Schreibrechte des Protocol Master
ausdrücklich fest als „ja, nur `docs/`" und schliessen Dateien unter
`.claude/` wörtlich aus. ADR 0002 selbst weist die Nachführung dieser
konkreten Datei in Abschnitt 9 auch nicht dem Protocol Master zu, sondern der
„Rolle, die die Rollendateien pflegt (ADR 0001)". Eine Anweisung, die diese
Grenze überschreitet, kann nach den Rahmenbedingungen dieser Sitzung nicht als
Freigabe für eine Konfigurationsänderung gelten — Rollendateien unter
`.claude/agents/` sind Konfiguration im Sinn von
`.claude/rules/claude-konfiguration.md`. Die Datei bleibt daher unverändert.

**Vorschlag für den Fliesstext**, zur Übernahme durch die zuständige Rolle
(Name, `description`, `tools`, `model`, `maxTurns` bleiben davon unberührt):

Ersetzt werden soll in `.claude/agents/static-software-tester.md`, Zeile 16,
der Satz:

> Definition of Done als ausführbare Befehlskette mit Rückgabewert 0 (3.4).
> Massgebend ist die Kette D1 bis D12 aus ADR 0002, Abschnitt 6 (Einstieg
> `make dod`); diese Rolle führt deren statisch prüfbare Glieder aus —
> insbesondere Bau, Formatierung, Linter, Typprüfung, Abhängigkeits- und
> Geheimnisprüfung sowie die Architekturverträge des Importprüfers.

durch:

> Definition of Done als ausführbare Befehlskette mit Rückgabewert 0 (3.4).
> Massgebend ist die Kette aus ADR 0002, Abschnitt 6 (Einstieg `make dod`)
> samt der Fortschreibung vom 2026-08-29 in Abschnitt 6.1 — die Nummer eines
> Kettenschritts ist eine Kennung, keine Reihenfolge, und die Kette umfasst
> seither zusätzlich D18; diese Rolle führt die statisch prüfbaren Glieder
> aus — insbesondere Bau, Formatierung, Linter, Typprüfung, Abhängigkeits-
> und Geheimnisprüfung (Arbeitsbaum und Git-Historie, D11) sowie die
> Architekturverträge des Importprüfers (D18).

## Feststellungen und Abweichungen vom Auftrag

- **Zeilenangaben im Auftrag trafen nicht wörtlich zu.** Der Auftrag nannte
  „Zeilen um 74 bis 81 und um 163 bis 165: die Wendung 'D1 bis D12' trifft
  nicht mehr zu". Ein Grep über die gesamte Datei vor der Bearbeitung ergab:
  Die wörtliche Zeichenkette „D1 bis D12" kam an keiner Stelle der Datei vor
  (weder mit Bindestrich noch mit Gedankenstrich). Der in der Sache benannte
  Mangel bestand dennoch: Die Tabelle endete bei D12, ohne D18 zu nennen, und
  D11 nannte nur „im Programmstand" statt beider Gegenstände. Beides ist
  behoben; die Formulierung ist so gewählt, dass sie auch bei künftigen
  Ergänzungen (D19 und folgende) nicht erneut falsch wird.
- **Zuständigkeit laut ADR 0002 weicht vom erteilten Auftrag ab.** Abschnitt 9
  des ADR weist die Nachführung von `docs/06_Definition_of_Ready_und_Done.md`
  „DevOps Engineer mit Product Owner, Bestätigung Auftraggeber mit R3-Q-001"
  zu, nicht dem Protocol Master. Die inhaltliche Nachführung wurde dennoch
  ausgeführt, weil sie innerhalb der eigenen Schreibgrenze (`docs/`) liegt und
  ausdrücklich beauftragt war; die **technische Bestätigung** durch DevOps
  Engineer und Auftraggeber bleibt davon unberührt offen (R3-Q-001, wie im
  Dokument selbst vermerkt).
- Keine Änderung am Git-Zustand vorgenommen; kein Commit erstellt.

## Definition of Done dieser Einheit

Anwendbar und erfüllt: Nur `docs/` berührt, Änderungen inhaltlich gegen ADR
0002 Abschnitt 6/6.1 geprüft, Sprachprüfung (kein Eszett, gerade
Anführungszeichen) ausgeführt, Vorher/Jetzt/Warum je Änderung mit Datum und
ADR-Verweis festgehalten, Übergabedatei geschrieben, kein Produktionscode,
keine Konfiguration und keine Tests berührt. Nicht abgeschlossen und bewusst
offen gelassen: die Nachführung von `.claude/agents/static-software-tester.md`
(ausserhalb der Schreibgrenze dieser Rolle) sowie die technische Bestätigung
durch DevOps Engineer und Auftraggeber nach R3-Q-001.
