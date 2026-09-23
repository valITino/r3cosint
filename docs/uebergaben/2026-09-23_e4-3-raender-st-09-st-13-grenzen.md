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

1. **Dieselbe Befehlsklassenliste in beiden Gates** (ST-09); die zweite Bedingung
   (Importmuster) bleibt, ein Kopierbefehl ohne Importmuster (B52) läuft durch.
2. **Unlesbare Eingabe fail-closed** wie jq- und git-Wache (6.13 b): "JSON-Objekt
   mit Objekt `tool_input`", Meldung mit Anfang (80 Zeichen) und Länge; eine
   wohlgeformte Eingabe eines anderen Werkzeugs (G40, P34) läuft durch.
3. **Grenzen festgeschrieben, nicht geschlossen** (6.13 c): P-10 mit Fall P35;
   Klammer-Subshell erkannt (ZF2a, KM-11), Grenze bleibt der untergeordnete
   Shell-Aufruf (GM-4: ZF2b, ZF2c); GM-1 bis GM-3 unverändert.
4. **Prüfstand-Fälle bleiben** (ZF9, ZF10a bis ZF10d, L01 bis L11): Aufnahme nur
   als Fortschreibung von 6.13 c durch den Software Architect.

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
  Meldungsprüfung der Eingabewache, Fallklassen KM-10, KM-11, KP-3, KP-4, GP-1
  bis GP-3 (22, jede Behauptung und Grenze beider Kopfkommentare mit Fall),
  Mutationen MP7, MM6, MP8, MP9; `BEFUND_VON` leer; Kriterienlisten nachgeführt.
- Nachführung: ADR 0002 (6.13 Nachtrag, Abschnitt 9, Kopftabelle), Backlog,
  CLAUDE.md, Nachweiserzeuger, diese Übergabe; Methodik-Repository.

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
  DST-E42-N1); DT-E43-6/N-1 und N-3 im Nachtrag unten behoben; DT-E43-4 (`deno eval`,
  `node --eval`, `bun -e` an beiden Gates nicht als Inline-Code erkannt,
  Parität besteht), Preis P38 (Suchbefehl mit zitiertem Interpreteraufruf samt
  Import blockiert).
- Nächste Einheit: Festlegung von E3, dann E3, dann Grundgerüst. Unverändert:
  O-28 (bedingt), O-15, R3-Q-005, Backlog-Punkte 12, 15, 20.

## Protokoll (Koordinator)

- Bauauftrag an den SecDevOps Engineer (6.13 g); Kontrolllauf nach Schritt 2
  (zwölf GEFALLEN-Zeilen) und Schritt 4 (230 von 230, 14 von 14); Prüfaufträge;
  Behebungsauftrag mit Ergänzungen (P38 Soll 2, G40 in AK); Kontrolllauf 247 von
  247, 15 von 15; Nachprüfung je Rolle; Entscheid zu DT-E43-7, Textbehebung N-2
  und T-3 (Kommentarzeilen); Kontrolllauf; Nachführung durch Software Architect
  (ADR 0002) und Product Owner (Backlog), Übriges durch den Koordinator.
- `git add`, `make dod` (drei terminierte Lagen C, D20 und D11 A_OK, D19
  OHNE_BEFUND, Rückgabewert 2), Commit R3-Q-010, Push; `docs/NACHWEISE.md`
  erzeugt, `make dod`, Commit, Push; Methodik-Repository; Pull Requests.

## Nachtrag vom selben Tag: DT-E43-6/N-1, N-3 und DT-E43-8 behoben

Auf Weisung ("Das, was richtig ist und effizient") vor dem Merge, Aufgabe #4. Beide
Gates textgleich: ein Umleitungsziel mit ".." fällt nicht mehr unter die Ausnahme
flüchtiger Ziele, "/dev/null" nur mit Wortgrenze (SecDevOps Engineer, 6.13 g: A50
bis A52 und B60 bis B62 fielen zuerst). Die Prüfrunde fand daran ein vorbestehendes
falsches Grün, DT-E43-8: ein Trenner samt Schreibverb direkt hinter dem flüchtigen
Ziel ("> /tmp/x;cp a datei") wurde mitverschluckt; behoben (Trenner beenden das
Ziel), Fälle A53 und B63. Prüfmittel: 258 Fälle, 19 Mutationen (neu MM7/MP10 für
die Ausnahme, MM8/MP11 für "length == 1", N-3), 23 Fallklassen (neu KM-12), beide
Modi Rückgabewert 0. Dynamische Runde auf einem anderen Modell: 258 von 258 und 19
von 19, direkte Messung an beiden Gates in Wegwerf-Klonen (je sechs Ziele mit Soll
2 und Soll 0, alle wie erwartet), vier Mutanten selbst erzeugt und trennscharf,
Gegenprobe mit den HEAD-Gates (je drei neue Fälle fallen), Nachmessung von
DT-E43-8 mit sieben Formen; Entscheid bestanden für alle drei.
