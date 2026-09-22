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
  offene Punkte 12, 15 und 20 des Backlogs, O-28 bedingt offen, O-15,
  `CHANGELOG.md`, die Bestätigung der Notation der Abnahmekriterien, die
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

## Nachtrag vom 2026-09-22 nach dem Codex-Review

Der Codex-Review am Pull Request r3coscrum#10 (Befund P2) hat einen
Widerspruch gefunden, der auch das Produkt-Repository betrifft: **O-25** ist
in ADR 0002, Abschnitt 8 seit dem 2026-09-03 als **entschieden** geführt
(sechzehnte Zeile der Tabelle, umgesetzt in 6.12.26; im Methodik-Repository
V15 und ein erledigter Punkt), wird aber seit der Einheit vom 2026-09-07 in
Kopfzeile, Abschnitt 10, `CLAUDE.md`, Backlog und Übergaben als "bleibt
offen" mitgeführt — ohne dass eine Stelle den Grund nennt. Am Bestand ist
kein Grund auffindbar; die massgebliche Stelle ist Abschnitt 8. Berichtigt in
dieser Einheit an den Stellen dieses Pull Requests, die den Stand tragen:
`CLAUDE.md` (Statustabelle, Gate-Zeile), Backlog (Stand-Vermerk R3-Q-001),
ADR 0002 (Status-Block von 6.13, Abnahmeeintrag in Abschnitt 10 mit
Berichtigungsvermerk nach 6.1.2), Nachweiserzeuger, diese Übergabe; im
Methodik-Repository der Eintrag zu O-27 und der Übergabevermerk dieser
Einheit. Nicht geändert, weil sie einen vergangenen Stand belegen: die
Übergaben vom 2026-09-07, 2026-09-21 und 2026-09-22 (erste Einheit), die
Kopfzeileneinträge vom 2026-09-07 und die Abnahmevorlage vom 2026-09-07 in
Abschnitt 10; sie führen O-25 weiterhin als offen, und dieser Nachtrag sagt,
dass das unzutreffend war. Wer den Stand plant, liest Abschnitt 8.

## Nachtrag vom 2026-09-22 nach dem Codex-Review am Pull Request #17

Der Codex-Code-Review (geprüfter Commit `bb6c1965fa271f7f1d28cc57d3c0fc192ad8cb15`)
hat fünf Befunde gemeldet; vier davon sind berechtigte Mängel an den beiden
Starthooks, der fünfte (Nachweisverzeichnis veraltet) war zum Zeitpunkt des
Reviews bereits durch die Folgecommits erledigt. Ein zweiter Lauf desselben
Reviews (geprüfter Commit `bbaca093baf58db32114d6ff5cfefd0122f416b0`) hat
einen sechsten Befund gemeldet: `GIT_SHALLOW_FILE` auf einen nicht
vorhandenen Pfad lässt git einen flachen Klon als nicht flach melden, der
Hook holt dann nichts nach — derselbe Sachverhalt wie N-04 der statischen
Prüfung, mit P2 in derselben Runde behoben (Löschliste) und als Fall K-D
nachgemessen. Alle sechs Threads sind am Pull Request beantwortet und
aufgelöst.

- **P1, Git-Historie-Hook:** `git fetch --unshallow origin` ohne Refspec
  verwendet die konfigurierten `remote.origin.fetch`-Refspecs; eine nicht
  standardmässige wie "+refs/heads/side:refs/heads/side" hätte beim
  Sitzungsstart einen lokalen Zweig geschrieben — im Widerspruch zur
  Zusicherung "Zweige unberührt". Erste Behebung: explizite Refspec
  `+refs/heads/*:refs/remotes/origin/*` in beiden Fetch-Zweigen. **Diese
  Behebung trug nur die Hälfte** (siehe unten): git zieht die konfigurierten
  Refspecs weiterhin als Refmap heran. Zweite Behebung: zusätzlich
  `--refmap=''` an beiden Fetch-Aufrufen. Der Hook schreibt seither in keiner
  gemessenen Lage unter refs/heads/.
- **P2, Git-Historie-Hook:** `GIT_TRACE` und die `GIT_TRACE2`-Varianten mit
  Pfad im Arbeitsbaum hätten jeden git-Aufruf dorthin schreiben lassen
  (derselbe Sachverhalt wie N-05 der statischen Prüfung). Behoben: alle
  Variablen mit Präfix `GIT_TRACE` und `GIT_SHALLOW_FILE` (N-04) werden zu
  Beginn gelöscht.
- **P2, gitleaks-Hook:** `curl` liest `.curlrc` aus `CURL_HOME`,
  `XDG_CONFIG_HOME` oder `HOME`; Einträge dort könnten eine andere
  Gegenstelle ansprechen. Behoben: `-q` als erster Parameter beider
  `curl`-Aufrufe.
- **P2, gitleaks-Hook:** Liegt `/usr/local/bin/gitleaks` vor, ist das
  Verzeichnis aber nicht im PATH, galt gitleaks als fehlend, und `mv -f`
  hätte das vorhandene Binary ersetzt. Behoben: die Kandidaten werden vor
  jedem Download auf einen vorhandenen Eintrag geprüft; liegt einer vor,
  meldet der Hook das und ersetzt nichts.

### Nachprüfung auf einem anderen Modell, in drei Runden

**Runde 1 (statisch s2, dynamisch r7) — nicht bestanden, ein blockierender
Befund, von beiden Rollen unabhängig gefunden.** Die erste Behebung von P1
stellte die Zusicherung "Zweige unberührt" nicht her: Eine Refspec auf der
Befehlszeile ersetzt die konfigurierten Refspecs nur als *Abrufliste*; als
*Refmap* — Abbildung der abgerufenen Refs auf lokale Refs — zieht git sie
weiterhin heran. Der Dynamic Software Tester hat es am Gegenstand gemessen
(Fall K-B2, konfigurierte Refspec `+refs/heads/<zweig>:refs/heads/side`: der
Hook schrieb `side` von `98512f42…` auf `bbaca093…`, Reflog
`fetch --unshallow origin +refs/heads/*:refs/remotes/origin/*: fast-forward`),
der Static Software Tester in Nachbildungen (Befund B-11, Läufe F, I, J:
darunter ein `forced update` über einen eigenen lokalen Commit und die
Einschleusung der Refspec allein über `GIT_CONFIG_COUNT`). Beide haben
`--refmap=''` als Kontrollmessung belegt und als Vorschlag gekennzeichnet.
Die übrigen drei Behebungen sind in beiden Prüfungen bestanden: `GIT_TRACE*`
und `GIT_SHALLOW_FILE` (K-C, K-D mit Kontrollen ohne Hook), `curl -q` (L-Q:
Download trotz `.curlrc` mit `url`/`connect-to` von der echten Gegenstelle,
byte-identisches Binary; statisch belegt, dass `-q` nur an erster Stelle
wirkt), Ersetzungsschutz (L-N: Binary vorhanden, PATH ohne das Verzeichnis,
kein Download, Prüfsumme unverändert; Marker-`curl` mit Kontrolle).

Nachrangige Befunde der statischen Nachprüfung, alle behoben: B-12
(Kopfkommentar zu eng: der Fetch schreibt auch Tags unter refs/tags/, die in
die geholte Historie zeigen, und entfernt bei `fetch.prune=true` veraltete
Remote-Tracking-Refs — Aufzählung ergänzt), B-13 (zwei Zitate der
Befehlszeile ohne Refspec: Zeitbudget-Absatz und Fehlschlagmeldung angepasst),
B-14 (`[ -e ]` übersieht einen hängenden Symlink, `mv -f` hätte ihn ersetzt —
Bedingung um `[ -L ]` erweitert), B-15 (Zusicherung "ersetzt nie ein
vorhandenes Binary" war unbedingt formuliert, wirkt aber nur zum
Prüfzeitpunkt — auf den Prüfzeitpunkt bezogen, kein `mv -n`, weil dessen
Rückgabewert je coreutils-Fassung nicht belegt ist), B-16 (Meldung behauptete
den PATH als Ursache, `[ -e ]` trifft auch Verzeichnis und unbrauchbare Datei
— Meldung nennt nur noch die Prüfung), B-17 (Texte: `CLAUDE.md`, Hook-Regel
und ADR 0002, E-E und E-F, zitierten die Befehlszeile ohne Refspec und
führten "vorhanden, aber nicht im PATH" nicht — je als Nachtrag nachgeführt).

**Entscheid des Koordinators zu `GIT_CONFIG_*`** (Restlücke aus B-11):
`GIT_CONFIG_COUNT`, `GIT_CONFIG_KEY_n` und `GIT_CONFIG_VALUE_n` werden nicht
gelöscht. Gemessen am 2026-09-22: Der Harness dieser Sitzungsumgebung setzt
darüber `credential.interactive=false` und zwei `url.….insteadOf`-Regeln; ein
Löschen könnte in anderen Umgebungen den Fetch-Weg kappen, und der Hook soll
das Prüfmittel bereitstellen, nicht verweigern. Die einzige darüber
eingeschleuste Wirkung auf Zweige, eine `remote.origin.fetch`-Refspec, ist
mit `--refmap=''` abgeschaltet (statische Läufe J und K). Was darüber sonst
eingeschleust werden kann, trifft jeden git-Aufruf der Sitzung und ist keine
Eigenschaft dieses Hooks. Das steht als Kommentar bei den `unset`-Zeilen des
Hooks und im zweiten Nachtrag zu E-F.

**Runde 2 (dynamisch r8) — bestanden, 42 von 42 Zusicherungen.** Nach dem
Einbau von `--refmap=''`: K-A (echter Klon, keine Änderung), K-B, K-B2
(`side` unverändert, nicht mehr flach, `refs/remotes/origin/*` aktualisiert),
K-B3 (Wildcard `+refs/heads/*:refs/heads/*` mit zwei lokalen Zweigen auf
HEAD~1: kein Zweig verändert), K-B4 (`fetch.prune=true`: kein Zweig
verändert; der von Hand angelegte veraltete Remote-Tracking-Ref wird entfernt
— gemessen, innerhalb der Zusicherung), K-B5 (`fetch.prune=true` plus
Wildcard in refs/heads/, lokaler Zweig ohne Gegenstück: nicht gelöscht).
Beide Kontrollen ohne `--refmap=''` (K-B2K, K-B3K) schreiben weiterhin lokale
Zweige, die Messung trennt also. Zweiter Lauf reproduzierbar (die einzige
Abweichung im Fingerabdruck des echten Klons waren zwei parallel
nachgeführte Textdateien, keine Ref-Änderung).

**Zählung nach 3.4 am Kriterium "Zweige unberührt":** erstes Scheitern Codex
P1 (Commit `bb6c1965…`), zweites Scheitern K-B2/B-11 (Arbeitsbaumstand mit
expliziter Refspec), drittes Antreten r8 ohne blockierenden Befund. Keine
Eskalation; eine vierte Messung an diesem Kriterium hätte es in dieser
Einheit nicht gegeben. Das Muster, das beide Prüfrollen unabhängig benannt
haben, gilt als Lehre: *Eine Zusicherung über das Verhalten eines fremden
Werkzeugs wurde aus dessen Dokumentation geschlossen, statt am Werkzeug
gemessen; die konfigurierte Refspec wirkt auf zwei Wegen, die Behebung deckte
nur den ersten.*

**Runde 3 (dynamisch r9, statisch s3) auf dem Endstand des Codes.**
r9 — bestanden, 99 von 99 Zusicherungen: Regression des r8-Skripts auf dem
Endstand (42 von 42, Skript mechanisch als inhaltsgleich belegt); neuer
Fehlschlagpfad K-F (Remote `origin` auf nicht vorhandenen Pfad gesetzt: rc 0,
stderr leer, genau eine Zeile mit der neuen Fehlschlagmeldung, Klon bleibt
flach, Zweige und HEAD unverändert) und K-F2 (kein Remote `origin`);
gitleaks-Hook L-S (hängender Symlink unter `$HOME/.local/bin/gitleaks`) und
L-V (Verzeichnis): rc 0, je genau die neue Meldung, kein Download
(Marker-`curl` mit Kontrolle), Eintrag und Inode unverändert, keine Reste;
`/usr/local/bin/gitleaks` byte-identisch und mit Zeitstempel zurückgespielt,
L-A danach `8.21.2`. s3 — nicht bestanden, ohne Verhaltensmangel: B-11 bis
B-17 als behoben bestätigt (B-11 in den Nachbildungen F3, I3, J3 am
Gegenstand; Pruning P, P2, P3 gemessen; der Entscheid zu `GIT_CONFIG_*` an
der Umgebung bestätigt), dazu zwei blockierende und fünf nachrangige
Textbefunde: S3-01 — drei Kommentarstellen des Git-Hooks führten einen Satz
in Anführungszeichen als Zitat aus `git-fetch(1)`, der dort nicht steht (die
Vorgabe stammte aus dem Auftrag des Koordinators an den SecDevOps Engineer;
behoben mit den wörtlichen Passagen zu `--refmap` und zum Abschnitt
"Configured Remote-tracking Branches"); S3-02 — ein UTF-8-Umlaut im
Kopfkommentar des gitleaks-Hooks (Kriterium reines ASCII; behoben); S3-03 —
Begründung zum Pruning widersprach der eigenen Begriffsbildung (behoben:
geprunt wird entlang der Befehlszeilen-Refspec als Abrufliste, `--refmap=''`
betrifft nur die Abbildung); S3-04 — `CLAUDE.md` gab die Ersetzungs-
Zusicherung unbedingt wieder (behoben: auf den Prüfzeitpunkt bezogen); S3-05
und S3-06 — Selbstbezüge der Rundenabsätze und ein Bezugswort (behoben);
S3-07 — die Artefaktzeile des Nachweiserzeugers nannte die Befehlszeile ohne
Refspec (behoben). S3-08, Klärungspunkt: "Codex" steht in Hook-Kommentar,
ADR, Backlog und dieser Übergabe. Entscheid des Koordinators: Das ist der
Name des Prüfereignisses (der Code-Review-Bot am Pull Request), also die
Herkunftsangabe der vier Befunde nach 6.6, kein Modellname des Projekts; die
Prüfrollen dieses Projekts werden weiterhin ohne Modellnamen als "auf einem
anderen Modell" geführt. 3.4-Zählung: S3-01 und S3-02 je erstes Scheitern an
einem neuen Kriterium.

**Runde 4 (statisch s4) auf dem Endstand aller Dateien — bestanden.** S3-01
bis S3-08 erledigt; die drei gesetzten Zitate sind wörtlich in `git-fetch(1)`
enthalten (frisch abgerufen, je ein Treffer, Abschnittszuordnung geprüft), das
frühere Zitat kommt im Repository nicht mehr vor; die Rümpfe beider Hooks
sind ohne Kommentarzeilen byte-gleich mit den in r9 gemessenen Fassungen, die
dynamische Messung r9 gilt damit weiter; beide Hooks reines ASCII, `bash -n`
ohne Befund, jeder Ausstieg `exit 0`; Form der neuen Zeilen ohne Befund. Ein
Hinweis ohne Befundrang (Rundenspanne im Kopf des gitleaks-Hooks) ist danach
vom Koordinator berichtigt, wieder nur im Kommentar. Endstand der Hooks:
`session-start-git-historie.sh` 336 Zeilen, `session-start-gitleaks.sh`
456 Zeilen.

Nicht behoben, offen (aus s2/r7/r8): Signalverhalten beider Hooks, weitere
Konfigurationsvektoren derselben Klasse (`remote.origin.mirror`,
`url.*.insteadOf`, `GIT_CONFIG_GLOBAL`, `remote.origin.tagOpt`), `GIT_ASKPASS`
und `GIT_SSH_COMMAND` (nicht in der Löschliste; ein Beleg wäre nur gegen eine
Gegenstelle mit Anmeldung zu führen), das echte `SessionStart`-Ereignis des
Harness (die Hooks wurden direkt aufgerufen), Messung nur über `file://`
statt über den HTTPS-Remote, `shellcheck` fehlt in der Umgebung (nicht
ersetzt).

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
- Pull Requests unmittelbar nach dem ersten Commit dieser Einheit eröffnet:
  Produkt-Repository `valITino/r3cosint` Pull Request #17 (Text: Merge gilt
  als Abnahme der beiden Starthooks, erster Formweg), Methodik-Repository
  `valITino/r3coscrum` Pull Request #10; beide zusammen zu mergen. Diese
  Nummern sind mit dem zweiten Commit dieser Einheit nachgetragen, das
  Nachweisverzeichnis mit dem dritten neu erzeugt.
