# Übergabe 2026-09-02 — R3-Q-001: das Definition-of-Done-Gate, entworfen und nicht gebaut

Arbeitseinheit: Schritte 1 und 2 des Auftrags vom 2026-09-02 — Bestand
erfassen, Entwurf als zwölfte Fortschreibung von Abschnitt 6 des
Architekturentscheids 0002 durch den Software Architect, adversarische Prüfung
auf einem anderen Modell, Einarbeitung, Vorlage an den Auftraggeber. Der
Auftrag sagt wörtlich: "Baue nichts, bevor ich den Entwurf freigegeben habe."
Deshalb ist in dieser Einheit **kein** Hook-Skript, keine Liste terminierter
Lagen, keine Änderung an `.claude/settings.json` und keine Änderung am
`Makefile` entstanden.

## Ausgangslage, gemessen

Beide Arbeitszweige `claude/r3-dod-gates-hooks-fn5hia` sind frisch von
`origin/main` gesetzt: Produkt-Repository
`405ebada79a145ac537d8e4102ce46d029046475`, Methodik-Repository
`31823e1ec97ccda69defa676b7d5aeae6dceac82`.

Zwei Abweichungen vom Auftragstext, beide vor dem Entwurf festgestellt:

1. **Der Klon der Sitzung war flach.** In diesem Zustand meldete D20 31 Funde,
   davon 30 Commit-Prüfsummen, die lokal als Objekt fehlten, und `make dod`
   endete mit `D20 belege A_FAIL` — nicht mit dem im Auftrag beschriebenen
   Abbruch bei D7. Nach `git fetch --unshallow` (98 Commits) blieb ein Fund.
   Der Entwurf macht daraus G16 (6.12.17): Die Vollständigkeit der Historie
   wird Prüfmittel von D20, ein flacher Klon ist Lage C mit Beschaffungsweg.
2. **Der eine verbleibende Fund liegt auf `origin/main` in jedem frischen
   Klon:** `docs/uebergaben/2026-08-30_dod-nachfuehrung-adr0002-abschnitt6-1.md`
   nennt den Pfad eines lokalen Zweig-Refs als Herkunft einer Prüfsumme; ein
   lokaler Ref besteht nur auf dem damaligen Arbeitsplatz. Übergaben belegen
   einen vergangenen Stand und werden nicht geändert. Angelegt ist deshalb
   eine ortsgebundene Ausnahme in `scripts/belege-ausnahmen.txt` (Form
   `datei|wert`, mit Tatsachengrund), Umsetzung nach 6.8.5 und kein
   Architekturentscheid. Danach: `bash scripts/belege-pruefen.sh` 0 Befunde,
   Rückgabewert 0; `make dod`: D20 A_OK, D1 bis D6 und D18 Lage B, Abbruch bei
   D7 mit Lage C, D19 ohne Befund, Rückgabewert 2 — der im Auftrag
   beschriebene Zustand.

Die offizielle Hook-Dokumentation ist am 2026-09-02 als Rohtext abgerufen
worden (`https://code.claude.com/docs/en/hooks.md`, 3771 Zeilen). Die für den
Entwurf tragenden Tatsachen daraus, je mit Fundstelle im Rohtext:
`stop_hook_active` gibt es bei `Stop` und `SubagentStop`, nicht bei
`TaskCompleted` (Zeilen 2327, 2412, 2472); "Claude Code overrides the hook and
ends the turn after 8 consecutive blocks" (2472); `TaskCompleted` feuert nur,
wenn eine Aufgabe über das Aufgabenwerkzeug abgeschlossen wird oder ein
Teammitglied seinen Zug mit offenen Aufgaben beendet (2406); ein Hook, der
seine Zeitgrenze reisst, wird abgebrochen und fällt keine Entscheidung
(Abschnitt "Timeouts"); Vorgabe 600 s für `command`-Hooks (428); Exec-Form
mit `args` (456 bis 468); `agent_type` ist bei eigenen Rollen das
Frontmatter-Feld `name`, nicht der Dateiname (2278); Änderungen an Hooks in
Settings-Dateien werden "normally picked up automatically by the file watcher"
(712); der Name `CLAUDE_CODE_STOP_HOOK_BLOCK_CAP` kommt im Rohtext nicht vor.

## Was fertig ist

**Der Entwurf.** `docs/adr/0002-architekturentscheid-ziel-stack.md`,
Abschnitt 6.12 mit den Unterabschnitten 6.12.1 bis 6.12.22, Status "Entwurf,
dem Auftraggeber am 2026-09-02 zur Freigabe vorgelegt, nicht freigegeben".
Siebzehn Entscheide G1 bis G17, darunter die Antworten auf die vier Fragen des
Auftrags:

- **Befund oder Ausfall** (G3, 6.12.4): unterschieden an der Lage der Marke,
  nicht am Rückgabewert und nicht am Meldungstext; alles ausser einem belegten
  Grün blockiert.
- **Lage C** (G4, 6.12.5): terminierte Lagen C als versionierte, selbstprüfende
  Positivliste neben dem Hook, sechs Selbstprüfungen, jede blockierend;
  terminierbar sind nur Projektartefakte, die der ADR als noch nicht
  entstanden führt — nie ein installierbares Werkzeug, nie ein Prüfmittel von
  D20, nie D19. Folge G5 (6.12.6): Die Kette bricht bei Lage C nicht mehr ab,
  sondern läuft weiter und endet trotzdem mit 2; sonst liesse das Gate Läufe
  durch, in denen D8 bis D12 nie gelaufen sind. Folge G6 (6.12.7): Die Marke
  trägt das fehlende Prüfmittel strukturiert als `FEHLT=`.
- **Dreimal am gleichen Kriterium** (G8, 6.12.9): Zählung ausserhalb des
  Arbeitsbaums je Sitzung und Subagent, Schlüssel ist das Kriterium; beim
  dritten Mal verlangt das Gate die Übergabedatei mit der Zeile
  `Eskalation 3.4: <Schlüssel>`; ab dem vierten Mal lassen `Stop` und
  `SubagentStop` durch, wenn die Datei neu, geändert oder in `HEAD`
  enthalten ist; `TaskCompleted` blockiert weiter.
- **`stop_hook_active`** (G9, 6.12.10): Rückgabewert 0, Zähler unverändert,
  Meldung über `systemMessage`. Ausgesprochene Folge: `Stop` erzwingt je
  Beendigungsversuch genau eine Fortsetzung; die harte Zusicherung trägt
  allein `TaskCompleted`, und die nur in einer Sitzung, die eine Aufgabenliste
  führt (O-23).

Dazu: die Prüfmittel des Gates (G10), zwei Zeitgrenzen 900 s aussen und 600 s
innen (G11), der über `git` bestimmte Arbeitsbaum und die `flock`-Sperre (G12),
Rollen ohne `Edit`/`Write`/`NotebookEdit` lassen die Kette nicht laufen (G13),
Sichtbarkeit über `systemMessage` und kein `continue: false` (G14), kein
Zwischenspeicher des Urteils (G15), der flache Klon (G16), der Selbsttest mit
Attrappe und echtem `Makefile` (G17). Die drei übrigen Punkte des
Achtung-Hinweises zu R3-Q-001 sind eingeordnet und nicht gebaut (6.12.20:
O-21, O-22, O-8 umterminiert). Die Abhängigkeit vom nicht abgenommenen
Belegprüfer (O-15) und die Aktualitätsfrage (O-18) sind ausdrücklich
festgehalten (6.12.18, 6.12.21).

Geändert sind ausserdem: die Kopfzeile "Fortschreibung" (die elfte
Fortschreibung vom 2026-09-01 fehlte dort und ist als Nachtrag ergänzt), die
D20-Zeile der Objekttabelle in Abschnitt 6 (Vollständigkeit der Historie,
unter Entwurfsvorbehalt), Abschnitt 8 (O-8, O-10, O-15, O-18 fortgeschrieben;
O-19 bis O-23 neu) und Abschnitt 9 (Nachführungen je Datei und Rolle, alle
"erst nach der Freigabe von 6.12 auszuführen").

**Die Prüfung des Entwurfs.** Nach Abschnitt 3.4 des Projektauftrags auf einem
anderen Modell als die Umsetzung: fünf Prüflinsen (Dokumentationstreue gegen
den Rohtext, Konsistenz ADR/DoD/Makefile, Umgehung, Fehlerklasse V11 bis V13,
Auftragstreue) und je Befund ein unabhängiger Widerleger, alle auf
Claude Sonnet; der Architect lief auf dem Sitzungsmodell. Der erste Lauf ist
durch die Nutzungsgrenze der Sitzung abgebrochen und nach deren Rücksetzung
fortgesetzt worden. Ergebnis von Runde 1: dreizehn Befunde aus vier Linsen und
der Nachprüfung des Koordinators, jeder einzeln am Original belegt — darunter
ein blockierender innerer Widerspruch (G13 zählte `Bash` zu den verändernden
Werkzeugen und hätte damit genau die zwei Rollen erfasst, für die G13 gedacht
ist), die falsche Behauptung, die Referenz schweige zur Wirkung von Änderungen
an `settings.json`, die nicht nachgeführte Objekttabelle, die Kollision von
`FEHLT=` mit `SCHWELLE=`, die fünf freien Texte der D19-Zeile, die Lücke bei
committeter Übergabedatei, die Frage, ob `TaskCompleted` nach der Eskalation
durchlässt, und die Voraussetzung, dass `TaskCompleted` überhaupt feuert. Alle
dreizehn sind eingearbeitet; die betroffenen Stellen tragen den Vermerk
"Runde 1". Ein Hinweis zur Beweiskraft: Die fortgesetzten Widerleger liefen
zeitgleich mit der Einarbeitung und haben sechs Befunde gegen den bereits
berichtigten Text geprüft; ihr "widerlegt" ist deshalb kein Urteil über die
erste Fassung. Massgeblich ist die Nachprüfung des Koordinators am
ursprünglichen Wortlaut (Befehle unten). Die fünfte Linse brachte einen
weiteren Befund: Der Ausnahmeeintrag in `scripts/belege-ausnahmen.txt` bestehe
im Arbeitsbaum, obwohl die Einheit nichts bauen sollte. Der Eintrag ist eine
Massnahme des Koordinators, damit D20 überhaupt messbar ist; der Entwurf legt
sie offen und weist die Verifikation einer anderen Rolle zu.

**Formprüfung.** Der Static Software Tester hat auf Claude Opus — anderes
Modell als der Architect — alle hinzugefügten Zeilen beider Dateien geprüft
(Eszett, typografische Anführungszeichen, Tabellenform, innere Verweise
6.12.N, G1 bis G17, O-19 bis O-23, messbare Zahlen, Prüfsummen, Daten,
Kopfzeile) und `make dod` ausgeführt. Ergebnis: sieben Befunde, fünf davon
blockierend, alle formaler Art — die neun Pfadfunde des Belegprüfers (unten),
eine im Präsens gehaltene Aussage "D20 ist grün", die im Arbeitsbaum mit dem
Entwurf nicht mehr galt, zwei Querverweise auf 6.12.15 statt 6.12.2, und die
Zeilen O-19 bis O-23, die wie schon O-11 bis O-18 durch Leerzeilen als
Fragmente statt als Tabelle standen. 25 Negativbefunde, darunter: alle 22
Unterabschnitte und alle 39 Verweise der Form 6.N.M vorhanden, kein Eszett,
keine typografischen Anführungszeichen, alle Zahlen des Entwurfs am Bestand
bestätigt (53, 21, 14 Aufrufe, fünf D19-Zuweisungen, drei Fundstellen), der
Ausnahmeeintrag formgerecht und sein Fundort und seine Prüfsumme belegt. Die
vier Textbefunde hat der Software Architect in Runde 2 behoben; die Tabelle
von Abschnitt 8 ist dabei als Formberichtigung ohne Inhaltsänderung
geschlossen worden.

**Belege am Entwurf.** Der Belegprüfer fand am Entwurf neun Pfadfunde: viermal
die Kurzform `docs/06` in Rückwärtsakzenten (durch den vollen Dateinamen
ersetzt) und fünfmal die zwei Dateien, die erst mit dem Bau entstehen
(Hook-Skript und Liste der terminierten Lagen; dafür zwei ortsgebundene
Ausnahmen der Form `datei|wert` mit dem Grund "entsteht mit der Umsetzung nach
Freigabe von 6.12"; beide sind mit dem Entstehen der Dateien wieder zu
entfernen). Der Schlusslauf steht im Protokoll unten.

## Entscheide, die der Auftraggeber trifft

Der Entwurf legt elf Entscheidpunkte vor (E-A bis E-K, Liste des Architects in
dieser Übergabe zusammengefasst; Einzelheiten je Unterabschnitt):

| Nr. | Punkt | Empfehlung des Architects |
|---|---|---|
| E-A | Freigabe von 6.12 als Ganzes | — |
| E-B | Terminierte Lagen C (G4) | so; die Alternativen sind ein dauerhaft rotes oder ein wertloses Gate, oder das Gate erst mit dem Grundgerüst |
| E-C | Kette bricht bei Lage C nicht mehr ab (G5) | so; sonst blinder Fleck hinter D7 |
| E-D | `FEHLT=` strukturiert in 53 Zweigen (G6) | strukturiert |
| E-E | `gitleaks` bleibt blockierend | so, oder installieren lassen; keine Ausnahme |
| E-F | Flacher Klon blockiert (G16) | so, mit `git fetch --unshallow` in der Meldung |
| E-G | Kette läuft bei jedem Beendigungsversuch, kein Zwischenspeicher (G15) | so, Messung mit dem Grundgerüst (O-20) |
| E-H | Reichweite des Reentranz-Schutzes und Voraussetzung Aufgabenliste (G9, O-23) | Wortlaut befolgen **und** vorschreiben, dass jede Arbeitseinheit als Aufgabe geführt wird |
| E-I | Abnahmekriterium `R3-Q-001_gate_blockiert` präzisieren | präzisieren (Vorschlag in Abschnitt 9) |
| E-J | Durchlass nach Eskalation nur für `Stop`/`SubagentStop` | so |
| E-K | `Bash` zählt nicht als Schreibwerkzeug (G13), Lücke bis R3-Q-005 benannt | so |

Ohne E-A und E-H ist der Entwurf nicht beurteilbar; die übrigen Punkte sind
Bestandteile von E-A, die einzeln zurückgewiesen werden können.

## Was offen ist

- Der Bau (Schritte 3 bis 7 des Auftrags) beginnt erst nach der schriftlichen
  Freigabe. Abschnitt 9 des ADR nennt je Datei, was dann zu ändern ist und wer
  es tut; die vier Änderungen am `Makefile` sind dort einzeln aufgeführt.
- O-15 (Abnahme des Belegprüfers) bleibt offen und wird mit dem Gate
  dringlicher; O-18, O-19, O-20, O-21, O-22, O-23 neu oder fortgeschrieben,
  je mit Zuständigkeit und Termin in Abschnitt 8.
- `CLAUDE_CODE_STOP_HOOK_BLOCK_CAP` steht in drei verbindlichen Dokumenten
  (Projektauftrag 3.4, `docs/06_Definition_of_Ready_und_Done.md`,
  `docs/adr/0001-rollenmodell.md`) und ist in der gelesenen Referenz nicht
  belegt (O-19). Diese Einheit ändert die drei Dokumente nicht.
- Ein methodischer Entscheid ist vorgeschlagen und nicht eingetragen: die
  Unterscheidung zwischen einer Kette, die streng bleibt, und einem Gate der
  Arbeitsumgebung, das einen abzählbaren, selbstprüfenden, terminierten
  Ausfall duldet, während die Gegenseite ihn nicht kennt (6.12.5). Eintrag in
  `methodik/entscheide.md` erst mit der Freigabe, durch den Protocol Master.
- Der Lieferreihenfolge in `CLAUDE.md` fehlte die Einheit vom 2026-09-01
  (`docs/uebergaben/2026-09-01_d20-pruefmittel-und-sechs-befunde.md`); die
  Zeile ist in dieser Einheit nachgeführt und nennt den Stand von R3-Q-001
  als "Entwurf vorgelegt, nicht freigegeben".
- Auf Weisung vom 2026-09-02 läuft daneben eine vollständige Review beider
  Repositories; sie wird als eigener Zustandsbericht gesondert übergeben.

## Nächste Schritte

1. Auftraggeber liest 6.12 und entscheidet E-A bis E-K, mindestens E-A und
   E-H schriftlich.
2. Nach der Freigabe: DevOps Engineer mit SecDevOps Engineer bauen nach
   Abschnitt 9 (Makefile, Hook-Skript, Liste, `settings.json`), Selbsttest nach
   6.12.19 mit ausgeführtem rotem und grünem Lauf; Static und Dynamic Software
   Tester prüfen auf einem anderen Modell; Nachführung von
   `docs/06_Definition_of_Ready_und_Done.md`, `CLAUDE.md`,
   `.claude/rules/claude-konfiguration.md`, `docs/05_Product_Backlog.md`,
   `scripts/nachweise-erzeugen.sh`, `docs/adr/0001-rollenmodell.md` und
   `methodik/entscheide.md`.
3. Danach E4, E3, Grundgerüst — unverändert nach der Reihenfolge vom
   2026-08-25.

## Protokoll der ausgeführten Befehle (Koordinator)

Alle Läufe aus `/home/user/r3cosint`, Rückgabewert in Klammern.

- `git rev-parse --is-shallow-repository` (0, `true`); `git fetch --unshallow`
  (0); danach `false`, `git rev-list --count HEAD` = 98.
- `bash scripts/belege-pruefen.sh` vor der Ausnahme: 31 Funde im flachen
  Klon (2), 1 Fund nach `--unshallow` (2); nach der Ausnahme 0 Funde (0).
- `make dod` nach der Ausnahme (2): D20 A_OK, D1 bis D6 und D18 B, D7 C,
  Abbruch, D19 ohne Befund.
- Einzelziele `make abhaengigkeiten rueckkanal prototyp-trennung geheimnisse
  nachweise`: D8 B, D9 B, D10 C, D11 C, D12 C.
- `grep -c 'LAGE C:' Makefile` = 53; `grep -n 'call KLASSIFIZIEREN' Makefile`
  (14 Aufrufe, vierter Parameter bei D3, D6, D8 belegt); `grep -n
  'd19_befund=' Makefile` (fünf Zuweisungen).
- `grep -m1 '^tools:' .claude/agents/*.md` und `grep -m1 '^name:'` über alle
  21 Rollendateien: `static-software-tester` und `pentester` ohne `Edit` und
  `Write`, mit `Bash`; `name:` gleich Dateiname in allen 21.
- `grep -rn 'STOP_HOOK_BLOCK_CAP' docs/ .claude/ CLAUDE.md`: drei Fundstellen
  (Projektauftrag Zeile 162, docs/06 Zeile 527, ADR 0001 Zeile 130).
- Rohtext der Hook-Referenz: `grep -n` auf `stop_hook_active`, `consecutive`,
  `TaskCompleted`, `"args"`, `file watcher`, `agent_type`, `BLOCK_CAP`
  (kein Treffer) — Fundstellen oben.
- Nach dem Entwurf: `bash scripts/belege-pruefen.sh` (2), neun Pfadfunde,
  siehe "Belege am Entwurf".
- Schlusslauf nach Runde 2, mit den drei Ausnahmeeinträgen und mit dieser
  Übergabedatei: `bash scripts/belege-pruefen.sh` 0 Befunde, 0 nicht prüfbar
  (0); `make dod` (2): D20 A_OK, D1 bis D6 und D18 Lage B, D7 Lage C, D19
  ohne Befund, Abbruch bei D7 — der dokumentierte und gewollte Zustand bis zum
  Grundgerüst.
