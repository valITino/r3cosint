# Übergabe 2026-09-23 (1) — E4.1: Prüfmittel für die beiden PreToolUse-Gates am heutigen Stand (R3-Q-010)

Erste Arbeitseinheit des Tages, als Aufgabe #1 geführt (O-23, Entscheid E-H).
Grundlage: Sitzungsauftrag vom 2026-09-23 ("E4 bauen, nach Plan, ohne Umwege"),
Weisung vom 2026-09-22 ("Nächste Einheit: E4.1 bauen."), ADR 0002, 6.13 d bis g,
Backlog R3-Q-010. Ausgangslage geprüft: `main` enthält
`3c712292c74c14c8d7934f1edcfbbe3deceaad84`; Arbeitszweig von `main`
(`b60c82041799837e2714551d6dcb05c3552b16bd`) gestartet.

## Ergebnis in einem Absatz

Das Prüfmittel `scripts/pretooluse-gates-selbsttest.sh` besteht und ist grün:
202 Fälle im Normalmodus (Rückgabewert 0), zehn Mutationen im Modus
`--mutationen` gegen eine grüne Grundlinie alle erkannt (Rückgabewert 0),
Arbeitsbaum in beiden Läufen nachweislich unverändert. Es führt die 37 Proben
vom 2026-09-21 unter ihren Kennungen, die zehn Zusatzfälle als ZF1a bis ZF10d,
die rekonstruierbaren Klassen vom 2026-08-25 und je Fallklasse der
Kopfkommentare mindestens einen Fall; die offenen Lücken ST-04, ST-05, ST-09,
ST-13 und P-01 stehen als "belegte Lücke" mit dem heute gemessenen Rückgabewert
0 als Soll (28 Fälle), damit der Lauf grün endet und die Lücke belegt bleibt
(ADR 0002, 6.13 g). Keine Zeile an den beiden Gates, am `Makefile` und an der
Kette. Abgeschlossen sind `R3-Q-010_pruefmittel_je_gate` und
`R3-Q-010_main_gate_fremdbelegt`; ST-01 bis ST-03 sind damit erstmals von
Prüfrollen auf einem anderen Modell belegt — nach einer ersten Runde mit
blockierendem Befund, Behebung und Nachprüfung (bestanden).

## Entscheidungen dieser Einheit

1. **Ein Skript, zwei Modi, vier lokale Klone, kein Netz.** main-Fälle laufen
   gegen einen Wegwerf-Klon des lokalen Repositories auf `main` (Commit aus der
   ersten vorhandenen Ref `origin/main`, sonst lokal `main`, sonst HEAD; die
   Kopfzeile nennt Commit und Ref), dazu ein zweiter main-Klon als Ziel der
   Kontextwechsel, ein Klon auf einem Arbeitszweig als Gegenprobenkontext und
   einer auf `master`. Geprüft werden die Gate-Dateien des Arbeitsbaums, lesend;
   Prüfrollen können über `GATE_MAIN_UEBERSCHREIBUNG` und
   `GATE_PROTOTYP_UEBERSCHREIBUNG` eine Kopie prüfen.
2. **Fünf Klassen je Fall:** blockierend (Soll 2), durchlaufend (Soll 0),
   belegte Lücke (Soll = heute gemessen, Befundkennung im Vermerk), Grenze
   (im Kopfkommentar benannt, Soll 0), Prüfstand (Prüffall, Soll = heutiger
   Stand, kein Befund; ADR 0002, 6.13 d Nr. 9 und 10).
3. **Ausgangsmenge.** 37 Proben vom 2026-09-21 unverändert, G04 mit Soll 2; die
   zehn Zusatzfälle (Nr. 7 mit python über B09); aus der Übergabe vom 2026-08-25
   nur die in ihren Tabellen genannten Klassen — **die einzelnen 29 und 18
   Proben sind dort nicht überliefert** und nicht rekonstruierbar.
4. **Beobachtungen als Prüffälle, nicht als Befunde:** ZF2a — die Subshell-Form
   `(cd <main-Klon> && git commit -m x)` wird erkannt, obwohl der Rumpfkommentar
   sie als Grenze nennt; ZF7b — `perl -e` mit `open(F,">...")` wird allein wegen
   `>` erkannt; L01 bis L04 — vier vom Dynamic Software Tester belegte Lücken
   am main-Gate (`ma"in"`, `\main`, worktree mit `ma"in"`, `worktree add -B`),
   Aufnahme nur als Fortschreibung von ADR 0002, 6.13 c.
5. **Nach dem Wortlaut der Kriterien belegte Lücken, nicht Prüfstand** (Befund
   N-3): die Python-Modul-, Punkt- und Funktionsform in Richtung 2 (B35, B41,
   B42, Klasse P-01) und der Rückstrich-Pfad (ZF5e, ST-04); sie gehören zu E4.2.
6. **Zähleinheit der Fallklassen:** main-Gate Kopfkommentar (KM-1 bis KM-9,
   GM-1 bis GM-3) plus die im Rumpf benannte "BEWUSSTE GRENZE" (GM-4, nach
   ADR 0002, 6.13 c); Prototyp-Gate (KP-1, KP-2), keine Grenze benannt — P-10
   folgt mit E4.3. Zehn statt neun Mutationen: die Annahme "einstellig" aus
   ADR 0002, 6.13 d ist um eins überschritten; die Mutationen bleiben im Skript.
7. **Ein Fehler des Koordinators:** Der Bauauftrag erwartete zu MP4 auch P08 als
   fallend; MultiEdit liest `old_string` in `edits[]` strukturell nie. Erwartung
   auf P05 gekürzt, kein Befund am Gate.

## Verifikation auf einem anderen Modell

**Runde 1, statisch:** `pruefmittel_je_gate` bestanden, `main_gate_fremdbelegt`
**nicht bestanden** — B-1: A02 bis A05 laufen im main-Klon, wo die Sperre
"Push, während HEAD auf main steht" jeden Push sperrt; kein Fall hängt an den
mit `0b3510a3fd8b219c82c093b34be3aff50c68f7e0` erweiterten Zeichenklassen.
Dazu N-1 bis N-11 (nicht blockierend) und T-1 bis T-5 (Text).
**Runde 1, dynamisch** (eigenes Probeskript, 28 eigene Formen, eigene Mutation
je Gate): beide Kriterien **nicht bestanden** — DT-E41-01, derselbe Befund,
ausgeführt belegt (Lauf mit zurückgesetzter ST-01-Behebung endet 0); dazu
DT-E41-02 (keine Gate-Kopie prüfbar), DT-E41-03 (Inhaltsprüfsummen aus fremdem
Arbeitsverzeichnis nicht erhoben), DT-E41-04 (vier neue Lücken, oben L01 bis
L04). ST-02, ST-03 und die Gegenproben fremdbelegt.
**Behebung** (SecDevOps Engineer auf Entscheid des Koordinators): A38 bis A42
als trennscharfe ST-01-Fälle im Arbeitszweig-Kontext, ZF1a/ZF1b dorthin
verlegt, Mutation MM5 (Zeichenklassen auf den Stand vor
`0b3510a3fd8b219c82c093b34be3aff50c68f7e0`),
weitere Klassen vom 2026-08-25 (A43 bis A49, G36 bis G39), N-2, N-4 bis N-8,
DT-E41-02 und DT-E41-03 behoben; N-9 und N-11 an E4.3 und den Software
Architect (Wortlaut 6.13 d Punkt 2: ein Teil der main-Fälle läuft sachgerecht
im Arbeitszweig-Klon, auf master oder ohne Repository).
**Nachprüfung** (je eine Runde): statisch und dynamisch je **bestanden** für beide Kriterien am Stand
`c992f38b25e9019e` (SHA-256-Präfix des Skripts); B-1/DT-E41-01 behoben und
ausgeführt belegt — die Kopien mit zurückgesetzter ST-01-Behebung fallen jetzt
mit A38 bis A41; DT-E41-02, DT-E41-03 behoben, L01 bis L04 geführt. Restbefunde,
nicht blockierend: N-2-Rest (FEHLEND in einer Kriterienliste wirkt nicht auf den
Rückgabewert), NEU-1 (Überschreibung am Rückgabewert nicht erkennbar; vor einer
Einbindung in die Kette zu neutralisieren), NEU-4 (ungestagte Löschung macht den
Lauf rot, Meldung nennt die Ursache nicht), N-DT-1 (relativer Überschreibungspfad
gibt falsches Rot); zwei weitere Formen aus DT-E41-04 nicht geführt. Nach der
Nachprüfung nur Text: Kommentare, die Vermerke von B41 und B42, zwei
Ausgabezeilen, MM5 in der Kennungsliste von `pruefmittel_je_gate`; beide Modi
danach erneut grün (Koordinator), Stand `7227f22986621f95`.

## Was offen bleibt

- E4.2 (ST-04, ST-05, P-01 einschliesslich B35, B41, B42, ZF5e) und E4.3
  (ST-09, ST-13, benannte Grenzen, P-10; N-9): je Befund zuerst das Soll auf 2
  setzen, dann das Gate ändern, dann den Vermerk entfernen (ADR 0002, 6.13 g).
- L01 bis L04 und ZF2a: Entscheid des Software Architects (Fortschreibung).
- Unverändert: O-28 (bedingt), O-15, R3-Q-005, offene Punkte 12, 15 und 20 des
  Backlogs; Restbefunde der Übergaben vom 2026-09-22; Nachweisfluss.

## Protokoll (Koordinator)

- Ausgangslage: `git fetch origin main`, Vorfahrprüfung, Arbeitszweig mit
  `git checkout -B` auf `origin/main`; Starthooks für `gitleaks` und die
  Git-Historie von Hand ausgeführt; `make dod` in der erwarteten Form (drei
  terminierte Lagen C, D20 und D11 A_OK, D19 OHNE_BEFUND, Rückgabewert 2).
- Vormessung aller Sollwerte gegen `b60c82041799837e2714551d6dcb05c3552b16bd`
  in Wegwerf-Klonen (Probeskripte des Koordinators, nicht versioniert).
- Bauauftrag an den SecDevOps Engineer (Rolle auf anderem Modell als die
  Prüfrollen); Kontrolllauf; Prüfaufträge, Behebungsauftrag, Nachprüfaufträge;
  eigene Nachführung: CLAUDE.md, Nachweiserzeuger, diese Übergabe; ADR 0002
  durch den Software Architect, Backlog durch den Product Owner.
- `git add`, `make dod`, Commit mit Kennung R3-Q-010, Push; `docs/NACHWEISE.md`
  neu erzeugt, `make dod`, zweiter Commit, Push; Methodik-Repository (S9,
  Übergabevermerk), Commit, Push.
