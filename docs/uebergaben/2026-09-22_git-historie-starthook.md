# Übergabe 2026-09-22 (2) — Git-Historie beim Sitzungsstart nachgeholt (flacher Klon, E-F); Pull Requests beider Repositories eröffnet

Zweite Arbeitseinheit des Tages, als Aufgabe #3 geführt (O-23, Entscheid
E-H). Grundlage ist die Delegation des Auftraggebers auf den Bericht zur
ersten Einheit (`docs/uebergaben/2026-09-22_weisung-r3-q-010-freigabe-gitleaks-starthook.md`),
Wortlaut: "Ich überlasse es dir, da du einen besseren Überblick hast". Der
Bericht hatte zwei Fragen vorgelegt: den Merge der beiden Arbeitszweige samt
Eröffnung der Pull Requests und das Nachholen der Git-Historie bei flachem
Klon. Arbeitszweig `claude/awesome-knuth-blvzpb` in beiden Repositories,
aufgesetzt auf `7ef4f6176e4c13e0377020f082fbab9dfdabb7a6` (Produkt-Repository)
und `2b9a1a274151f563a1674912d56bab98741ad105` (Methodik-Repository).

## Ergebnis in einem Absatz

Beide delegierten Fragen sind entschieden und ausgeführt. Der flache Klon
wird nicht mehr von Hand behoben, sondern von einem dritten versionierten
`SessionStart`-Hook, `.claude/hooks/session-start-git-historie.sh`: Ist der
Klon flach, holt er die Historie vom konfigurierten Remote `origin` nach
(`git fetch --unshallow origin`); sonst tut er nichts. Er blockiert nie,
schreibt ausschliesslich in `.git/` und nie in den Arbeitsbaum, lässt
Zweige, HEAD und Index unberührt und ersetzt die Lage-C-Meldung von D20
(`FEHLT=git-historie`) nicht. Eingetragen in `.claude/settings.json`, der
Hook-Regel, `CLAUDE.md`, ADR 0002 (Abschnitt 10, E-F, Nachtrag; Kopfzeile;
Abschnitt 9) und im Nachweiserzeuger; Bau durch den SecDevOps Engineer,
Verifikation durch beide Prüferrollen auf einem anderen Modell (unten).
Danach sind die Pull Requests beider Repositories eröffnet; der Merge des
Pull Requests im Produkt-Repository gilt nach seinem Text als Abnahme der
beiden Starthooks über den ersten Formweg (ADR 0002, Abschnitt 10). Nächste
Einheit nach Weisung: E4.1, in einer neuen Sitzung von `main`.

## Entscheidungen dieser Einheit

1. **Nachholen der Historie als Hook — ja.** Der flache Klon war am
   2026-09-07 und am 2026-09-21 je von Hand behoben worden; in einer flachen
   Sitzung meldet D20 Lage C, und das DoD-Gate blockiert jede Beendigung,
   bis die Historie vollständig ist (ADR 0002, 6.12.17: "unbequem und
   richtig"). Dieselbe Klasse wie gitleaks — ein wiederholter Handgriff an
   der Umgebung ist ein Bauproblem. Der Hook automatisiert allein den in
   6.12.17 benannten Beschaffungsweg; an G16 und an der Kette ändert er
   nichts.
2. **Getrennter Hook, nicht Erweiterung des gitleaks-Hooks.** Ein Hook je
   Gegenstand: verschiedene Prüfmittel (git statt curl und sha256sum),
   verschiedene Fehlermodi, getrennt prüfbar.
3. **Der Remote ist der des Klons, nicht fest verdrahtet.** Anders als beim
   gitleaks-Hook gibt es keine gepinnte Adresse: `origin` gehört dem Klon,
   der Hook liest ihn aus der Git-Konfiguration, nicht aus einer
   Umgebungsvariable. Ohne `origin` holt er nichts nach.
4. **Merge und Pull Requests.** Der Merge ist der erste Formweg aus ADR 0002,
   Abschnitt 10; der Text des Pull Requests im Produkt-Repository sagt, was
   der Merge bedeutet (Abnahme der beiden Starthooks im Umfang der beiden
   Übergaben vom 2026-09-22 und Bestätigung des Eintrags der Weisungen) und
   was er nicht bedeutet (O-25, O-15, R3-Q-005, die Freigabe des
   Grundgerüsts, die offenen Punkte 12, 15 und 20 des Backlogs und die in den
   Übergaben benannten Restbefunde an den Hooks bleiben offen). Der Merge
   selbst liegt beim Auftraggeber: Das main-Gate sperrt ihn für den
   Koordinator, und er ist der Entscheid.

## Verifikation

Die Rolle, die schreibt, hat nicht geprüft (3.4); Bau auf dem Modell des
SecDevOps Engineers, Prüfung je auf einem anderen Modell.

**Dynamische Prüfung (Dynamic Software Tester): bestanden.** 25 Aufrufe in
neun Pflicht- und dreizehn Zusatzfällen gegen Wegwerfklone mit Tiefe 3
(`file://`-Remote) und gegen den echten, nicht flachen Klon: nachholen 3 auf
127 Commits in 0.25 s, danach nicht mehr flach; unerreichbarer `origin`,
fehlender `origin`, fehlendes `git`, fehlendes `timeout`, kein Arbeitsbaum,
leeres oder fehlendes `CLAUDE_PROJECT_DIR` (kein Rückfall auf das
Arbeitsverzeichnis, am flachen Klon gegengeprüft), Pfad mit Leerzeichen,
Symlink, führender Bindestrich, Unterverzeichnis, bare Klon, Idempotenz; 103
Dateiprüfsummen, Index-Prüfsumme, Index-Änderungszeit und `show-ref` vor und
nach dem Nachholen identisch — der Hook schreibt nur in `.git/`; das
Zeitbudget von 90 s greift gemessen (Stellvertreter-`git`, dessen `fetch`
300 s schläft: Ende nach 90.03 s, keine Restprozesse). Alle 25 Aufrufe
Rückgabewert 0, stderr leer, der echte Klon unverändert (HEAD, Status,
Commitzahl). Zwei nachrangige Befunde, nicht behoben: B-1 — ein `TERM`
während des laufenden `fetch` wirkt erst nach dessen Ende, und der Trap
beendet dann ohne Meldung (Rückgabewert 0, Klon bleibt flach, D20 meldet die
Lage); B-2 — zwei gleichzeitige Läufe gegen denselben flachen Klon: der an
der Git-Sperre gescheiterte meldet "fehlgeschlagen", während der andere
nachholt (falsches Rot, nie falsches Grün; Objektdatenbank intakt). Nicht
geprüft: ein echter HTTPS-Remote über den Proxy (alle Abrufe liefen über
`file://`), die Auslösung über das echte `SessionStart`-Ereignis, `SIGKILL`
mitten im `fetch`, partielle Klone (`--filter=blob:none`, dort ist der Klon
nicht "flach", die Historie aber ebenfalls unvollständig — weder Hook noch
D20 decken diesen Fall).

**Statische Prüfung (Static Software Tester):** erste Runde **nicht bestanden** —
B-01 blockierend: Der Kopfkommentar behauptete, keine Umgebungsvariable
ausser `CLAUDE_PROJECT_DIR` steuere den Hook; belegt war, dass `GIT_DIR`
Messung und Fetch-Ziel auf ein anderes Repository verlegt (mit
`GIT_DIR` des Methodik-Repositories zählte der Hook 55 statt 127 Commits).
Dazu neun nachrangige: B-02 altes `git` ohne `--is-shallow-repository` gibt
die Option auf stdout aus, und der Hook hätte einen flachen Klon als
vollständig gemeldet; B-03 Kommentar schrieb die Adressermittlung dem
falschen Kommando zu; B-04 Kommentar behauptete die Unmittelbarkeit des
Signal-Traps; B-05 kein `GIT_TERMINAL_PROMPT=0`; B-06 keine Prüfung, dass
`CLAUDE_PROJECT_DIR` die Repository-Wurzel ist; B-07 Zitat der Delegation
mit Punkt innerhalb der Anführungszeichen (in dieser Übergabe berichtigt:
die Nachricht des Auftraggebers endet ohne Punkt); B-08 eine überlange Zeile
in `CLAUDE.md` (berichtigt); B-09 der allgemeine Satz der Hook-Regel zur
Standardausgabe widersprach den `SessionStart`-Hooks (vorbestehend); B-10
Singular in der Meldung. Alle Regressionskriterien erfüllt, die fünf
Fundstellen widerspruchsfrei. Behebung in der **zweiten Fassung**
(206 Zeilen): die git-eigenen Variablen, die den Gegenstand verlegen
könnten, werden zu Beginn gelöscht; Wurzelprüfung mit physischem
Pfadvergleich; exakte Auswertung des Schalenzustands vor und nach dem
`fetch`; `GIT_TERMINAL_PROMPT=0`; der Trap meldet vor dem Ende; der Regelsatz
gilt ausdrücklich für die Gates, die drei `SessionStart`-Hooks geben Klartext
aus.

**Nachprüfung der zweiten Fassung (letzte Runde):** statisch **bestanden** — alle
zehn Befunde der ersten Runde am Quelltext nachgeschlagen und behoben,
Regressionskriterien erfüllt; acht nachrangige Restbefunde N-01 bis N-08,
keiner blockierend: ein Schreibfehler im Kommentar (vom Koordinator als
Formberichtigung ersetzt, ohne Wirkung im Rumpf), zwei ungenaue
Meldungstexte im Zweig "Schalenzustand nicht bestimmbar" (nach dem `fetch`
sagt er "nichts nachgeholt", und er nennt eine Ursache, die nicht gemessen
ist), zwei nicht gelöschte git-Variablen mit gemessener Wirkung
(`GIT_SHALLOW_FILE` verlegt die Schalenliste, `GIT_TRACE` schreibt eine
Datei ausserhalb von `.git/`), zwei zu absolute Zusicherungen im
Kopfkommentar (Rückgabewert bei `SIGKILL`/`SIGPIPE`; Reichweite von
`GIT_TERMINAL_PROMPT=0` gegenüber `GIT_ASKPASS` und `ssh`), ein beweglicher
Zeilenverweis auf das `Makefile`; benannte Grenze ohne Befund: eine über
`GIT_CONFIG_GLOBAL` untergeschobene `insteadOf`-Regel lenkt den Weg zur
Gegenstelle um, nicht den Gegenstand. Dynamisch **bestanden**, kein Befund:
acht Fälle, alle Rückgabewert 0, stderr leer; mit gesetztem `GIT_DIR` und
`GIT_WORK_TREE` misst und holt der Hook den richtigen Klon nach, das fremde
Repository bleibt unverändert; ein altes `git` ohne die Option führt zu
"Schalenzustand nicht bestimmbar" ohne `fetch`; ein Unterverzeichnis wird
als "nicht die Wurzel" abgewiesen, ein Symlink auf die Wurzel erkannt; ein
`TERM` während des `fetch` endet nach 90 s mit einer Meldung und
Rückgabewert 0, ohne Restprozesse.

**`make dod`** nach `git add`: Form 2 mit den drei terminierten Lagen C (D7, D10,
D12), D20 `A_OK`, D11 `A_OK`, D19 `OHNE_BEFUND`, Rückgabewert 2 — der
erwartete grüne Zustand, ohne Nachbesserung.

## Was offen ist

- **Merge der beiden Pull Requests durch den Auftraggeber**, dann E4.1 in
  einer neuen Sitzung von `main` (nach ADR 0002, 6.13 g ändert E4.1 keine
  Zeile an den beiden Gates).
- Alles, was die Übergabe der ersten Einheit unter "Was offen ist" führt:
  offene Punkte 12, 15 und 20 des Backlogs, O-28 bedingt offen, O-25 und
  O-15, `CHANGELOG.md`, die Bestätigung der Notation der Abnahmekriterien, die
  Kommentarzeilen "foermliche Freigabe ausstehend", die Restbefunde am
  gitleaks-Hook.
- Am neuen Hook, benannt und nicht behoben: Signal während des `fetch` endet
  ohne Meldung (B-1); gleichzeitige Läufe können ein falsches Rot melden
  (B-2); partielle Klone werden nicht erkannt — dort meldet auch D20 keine
  Lage C, obwohl die Historie unvollständig ist; ein echter HTTPS-Remote ist
  nicht gemessen — SecDevOps Engineer beziehungsweise Software Architect
  (partielle Klone gehören zu G16). Dazu die Befunde der statischen Prüfung:
  N-02/N-03 (Meldungstexte), N-04/N-05
  (`GIT_SHALLOW_FILE`, `GIT_TRACE` nicht gelöscht), N-06/N-08 (Kopfkommentar
  zu absolut), N-07 (Zeilenverweis) — SecDevOps Engineer, mit der nächsten
  Änderung am Hook.

## Protokoll der ausgeführten Befehle (Koordinator)

- Lesen von ADR 0002, 6.12.17 und des D20-Wächters im `Makefile` (Zeilen 703
  bis 713) als Massstab; Anlegen der Aufgabe #3.
- Delegation: SecDevOps Engineer (Hook, `settings.json`, Hook-Regel),
  Protocol Master (ADR 0002: E-F, Kopfzeile, Abschnitt 9), Static und Dynamic
  Software Tester (je zwei Runden: Prüfung, Behebung, Nachprüfung).
- Eigene Nachführung von `CLAUDE.md` (drei `SessionStart`-Hooks; 185 Zeilen)
  und `scripts/nachweise-erzeugen.sh` (zwei Artefaktzeilen); diese Übergabe;
  im Methodik-Repository der Nachtrag zu S8 und der Übergabevermerk nach dem
  Commit des Produkt-Repositories.
- `git add`, `make dod` (Form 2, drei terminierte Lagen C, D20 und D11 grün, D19 ohne Befund, Rückgabewert 2), Commit mit Kennung R3-Q-001, Push; danach
  `docs/NACHWEISE.md` neu erzeugt, `make dod`, zweiter Commit, Push.
- Pull Requests: unmittelbar nach dem ersten Commit dieser Einheit in beiden
  Repositories eröffnet; ihre Nummern trägt der zweite Commit dieser Einheit
  (Nachweisverzeichnis) hier nach.
