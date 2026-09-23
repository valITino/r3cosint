# Übergabe 2026-09-23 (3) — E4.3: Verhalten an den Rändern — ST-09, ST-13, benannte Grenzen und P-10 (R3-Q-010)

Dritte Arbeitseinheit des Tages, als Aufgabe #3 geführt (O-23, Entscheid E-H).
Grundlage: Sitzungsauftrag vom 2026-09-23, ADR 0002, 6.13 b, c und g, Backlog
R3-Q-010. Aufgesetzt auf E4.2 (`5467c30a42d5579f7ac56929222e5a2f39b81a12`,
Nachweisverzeichnis `40619e8fc813b4c1c0efbe15f2605b9b105837c5`).

## Ergebnis in einem Absatz

Die letzten beiden belegten Lücken sind geschlossen und die Grenzen benannt:
Das Prototyp-Gate führt bei Bash dieselbe Befehlsklassenliste als Schreibwirkung
wie das main-Gate (Interpreter mit Inline-Code, Dateiwerkzeuge, ed/ex) und
blockiert weiterhin nur zusammen mit einem Importmuster (ST-09); beide Gates
blockieren eine Eingabe, die kein JSON-Objekt mit einem Objekt `tool_input` ist,
mit Rückgabewert 2, leerer Standardausgabe und einer Meldung, die Anfang und
Länge der Eingabe nennt (ST-13, Entscheid ADR 0002, 6.13 b); die Nichtprüfung
gemeinsamer Abhängigkeiten steht als Grenze im Kopfkommentar des Prototyp-Gates
(P-10), die Subshell-Grenze des main-Gates ist präzisiert. Vorgehen nach 6.13 g:
Soll der zwölf Fälle zuerst auf 2, dann die Gates, dann die Vermerke. Das Prüfmittel
führt 247 Fälle, 15 Mutationen und 22 Fallklassen, beide Modi Rückgabewert 0,
die Zeile "belegte Lücken" ist leer. Abgeschlossen sind
`R3-Q-010_prototyp_gate_schreibwirkung`, `R3-Q-010_gates_unlesbare_eingabe` und
`R3-Q-010_benannte_grenzen` (je eine statische und eine dynamische Runde auf
einem anderen Modell, je eine Nachprüfung, alle drei bestanden). Damit sind alle
sieben Abnahmekriterien von R3-Q-010 gebaut und verifiziert; die Abnahme liegt
beim Auftraggeber (Merge). Keine Zeile am `Makefile`, an `.claude/settings.json`
und an der Kette.

## Entscheidungen dieser Einheit

1. **Dieselbe Befehlsklassenliste in beiden Gates** (ST-09): das Prototyp-Gate
   übernimmt den Ausdruck des main-Gates für Schreibwirkung; die zweite
   Bedingung (Importmuster im flachgezogenen Befehl) bleibt, ein Kopierbefehl
   ohne Importmuster (B52) läuft durch.
2. **Unlesbare Eingabe wird fail-closed behandelt** wie die jq- und die
   git-Wache (ADR 0002, 6.13 b); geprüft wird "JSON-Objekt mit Objekt
   `tool_input`", die Meldung nennt Anfang (80 Zeichen) und Länge der Eingabe;
   eine wohlgeformte Eingabe eines anderen Werkzeugs (G40, P34) läuft durch.
3. **Grenzen festgeschrieben, nicht geschlossen** (6.13 c): P-10 als Grenze mit
   durchlaufendem Fall P35 (`package.json` im Prototyp); die Subshell in
   Klammern wird erkannt (ZF2a, jetzt gedeckte Klasse KM-11), Grenze bleibt der
   untergeordnete Shell-Aufruf (GM-4: ZF2b, ZF2c); GM-1 bis GM-3 unverändert.
4. **Prüfstand-Fälle bleiben** (ZF9, ZF10a bis ZF10d, L01 bis L11): Aufnahme nur
   als Fortschreibung von ADR 0002, 6.13 c durch den Software Architect.

## Was gebaut ist

- `.claude/hooks/block-prototype-import.sh`: Schreibwirkung mit der
  Befehlsklassenliste des main-Gates (`tee` an jeder Stelle, Dateiwerkzeuge,
  Interpreter mit Inline-Code, ed/ex), Bereinigung flüchtiger Ziele wie im
  main-Gate, Eingabewache (JSON-Strom der Länge 1 mit Objekt `tool_input`),
  Kopfkommentar (ST-09, ST-13, Grenzen P-10 und Pfad-Asymmetrie, Preis der
  Textprüfung bei Suchbefehlen). `.claude/hooks/block-main-write.sh`:
  Eingabewache, Rumpfkommentar zur Subshell-Grenze präzisiert. Beide ASCII.
- `scripts/pretooluse-gates-selbsttest.sh`: 247 Fälle (main 67 mit Soll 2, 47 mit
  Soll 0; Prototyp 82 und 51): zwölf von belegte Lücke auf blockierend, ZF2a und
  ZF7b auf blockierend; neu P33 bis P38, B52 bis B59, G40, L12 bis L16, S08, S09;
  Meldungsprüfung für die Eingabewache ("nicht auswertbar"), Fallklassen KM-10,
  KM-11, KP-3, KP-4, GP-1, GP-2, GP-3 (22 Klassen, jede Behauptung und jede
  Grenze beider Kopfkommentare mit Fall), Mutationen MP7 (Interpreterglied), MM6
  und MP8 (Eingabewache), MP9 (Dateiwerkzeuge), `BEFUND_VON` leer, Listen der
  drei Kriterien nachgeführt.
- Nachführung: ADR 0002 (6.13 Nachtrag E4.3, Abschnitt 9, Kopftabelle), Backlog
  (Stand-Vermerk, zwölfte Nachführung), CLAUDE.md, Nachweiserzeuger, diese
  Übergabe; Methodik-Repository (Übergabevermerk).

## Verifikation auf einem anderen Modell

Massstab: Backlog R3-Q-010, ADR 0002, 6.13 b, c, d und g. Runde 1 statisch:
B-1 (`tee` nur hinter Pipe), B-2 (Dateiwerkzeuge, ed/ex ohne Fall und Mutation),
B-3 (Grenzen ohne Fallklasse), B-4 (JSON-Strom läuft durch), B-5, T-1 bis T-5. Runde 1 dynamisch: DT-E43-1 bis DT-E43-5
(dieselben Sachverhalte, dazu `grep` mit `2>/dev/null` als Fehlalarm). Behebung
durch den SecDevOps Engineer: `\btee`, Fälle B53 bis B59 und Mutation MP9,
Fallklassen GP-2 und GP-3 mit L12 bis L16, Eingabewache mit `jq -es` und
Länge 1 (S08, S09), Bereinigung flüchtiger Ziele (P37, P38 mit Soll 2 als
Prüfstand). Nachprüfung, je eine Runde: statisch bestanden, alle drei
Kriterien, kein blockierender Befund; dynamisch bestanden, 247 von 247 zweimal,
15 von 15 Mutationen, Gegenprobe mit den HEAD-Gates 225 von 247 mit genau den
22 erwarteten Fällen, zwei eigene Mutanten erkannt, 65 Proben im Wegwerf-Klon.
Der dynamische Prüfer hat `R3-Q-010_benannte_grenzen` zunächst nicht bestanden
gewertet (DT-E43-7: der im Kopfkommentar als Preis benannte Fall "/tmp/.."
hatte keinen Fall mit Soll 0); Entscheid des Koordinators: der Fall ist ein
offener Restbefund, keine benannte Grenze, der Kopfkommentar sagt das jetzt so;
der Prüfer hat darauf das Kriterium als bestanden gewertet (nur gelesen).
Textbefunde N-2 und T-3 durch den Koordinator behoben, nur Kommentarzeilen;
Kontrolllauf danach in beiden Modi Rückgabewert 0.

## Was offen bleibt

- Abnahme von R3-Q-010 durch Merge der Pull Requests (Formweg 1, ADR 0002,
  Abschnitt 10); Codex-Befunde daran: nur P1 beheben.
- Entscheid des Software Architects zu den Prüfstand-Fällen (Fortschreibung
  6.13 c) und zum Wortlaut von 6.13 d Punkt 2 (bereits präzisiert).
- Restbefunde aus E4.1 und E4.2 unverändert (NEU-1, NEU-4, N-DT-1, R-1/E-1,
  DST-E42-N1); neu aus E4.3: DT-E43-6/N-1
  (die Bereinigung flüchtiger Ziele greift in beiden Gates auch bei
  Umleitungen über "/tmp/.." und "$TMPDIR/.." sowie bei "/dev/nullx"; im
  Prototyp-Gate ein Rückschritt gegenüber E4.2, im main-Gate seit jeher;
  Vorschlag der Prüfer: `..`-Pfade von der Ausnahme ausnehmen und `/dev/null`
  nur mit Wortgrenze, in beiden Gates), N-3 (der Teil `length == 1` der
  Eingabewache ist durch keine Mutation belegt), DT-E43-4 (`deno eval`,
  `node --eval`, `bun -e` an beiden Gates nicht als Inline-Code erkannt,
  Parität besteht), Preis P38 (Suchbefehl mit zitiertem Interpreteraufruf samt
  Import blockiert).
- Nächste Einheit nach 6.13 g: E3 (eigene Festlegungseinheit), dann Grundgerüst.
- Unverändert: O-28 (bedingt), O-15, R3-Q-005, Backlog-Punkte 12, 15, 20.

## Protokoll (Koordinator)

- Bauauftrag an den SecDevOps Engineer (6.13 g); Kontrolllauf nach Schritt 2
  (zwölf GEFALLEN-Zeilen) und Schritt 4 (230 von 230, 14 von 14); Prüfaufträge;
  Behebungsauftrag mit Ergänzungen (P38 Soll 2, G40 in AK); Kontrolllauf 247 von
  247, 15 von 15; Nachprüfung je Rolle; Entscheid zu DT-E43-7, Textbehebung N-2
  und T-3 (Kommentarzeilen); Kontrolllauf; Nachführung durch Software Architect
  (ADR 0002) und Product Owner (Backlog), Übriges durch den Koordinator.
- `git add`, `make dod` (drei terminierte Lagen C, D20 und D11 A_OK, D19
  OHNE_BEFUND, Rückgabewert 2), Commit mit Kennung R3-Q-010, Push;
  `docs/NACHWEISE.md` neu erzeugt, `make dod`, zweiter Commit, Push;
  Methodik-Repository, Commit, Push; Pull Requests beider Repositories.
