# Übergabe — Arbeitseinheit «Full-Review der Claude-Konfiguration»

| | |
|---|---|
| **Arbeitsprodukt nach** | Projektauftrag 3.3 (Übergabedatei je Arbeitseinheit) |
| **Einheit** | Full-Review auf Weisung; zieht D2 und E5 des freigegebenen Plans vor |
| **Weisung** | Auftraggeber, 2026-08-25 («bitte ein full-review und die nötigen, wichtigen und richtigen Anpassungen … Keine Annahmen, keine Halluzinationen») |
| **Datum** | 2026-08-25 |
| **Zweig** | `claude/next-step-g8slnq` |
| **Umfang** | 21 Rollendateien, 6 Regeln, 3 Hooks, settings.json, CLAUDE.md, Arbeitsabläufe und Querbezüge — beide Repositories |

## Vorgehen

Sieben parallele Prüfaufträge über den gesamten Konfigurationsbestand, dazu
deterministische Prüfungen (Frontmatter gegen ADR 0001, Eszett, Anführungszeichen,
`blob/main`). **Jeder Befund zählte nur mit wörtlichem Zitat aus der Datei oder
ausgeführtem Beleg**; jeder wurde vor der Behebung einzeln nachverifiziert.
Ergebnis: 56 Rohbefunde, davon bestätigt und behoben 49, widerlegt 1, bewusst
nicht behoben 6 (unten). Nach der Behebung: konsolidierter Prüfsatz 25 Punkte
ohne Beanstandung, Gate-Proben 29 + 18 Fälle, unabhängige Prüfung durch den
Static Software Tester auf anderem Modell gegen den eingefrorenen Stand.

## Was behoben ist

### Gates — durch Ausführung belegte Umgehungswege (Commit `b860cdf…`)

| Gate | Umgehung (vorher ausgeführt: lief durch) | Behebung |
|---|---|---|
| main-Gate | `git push origin HEAD:refs/heads/main` von einem Arbeitszweig | eigenes Muster für `refs/(heads|for)/…`; Zweignamen wie `fix/main-seite` bleiben frei |
| main-Gate | `git rebase`, `git reset --hard`, `git am` auf `main` | Verbliste erweitert (auch `apply`, `stash pop/apply`); `switch -c`/`checkout -b` bleiben als Ausweg frei |
| main-Gate | `sed -i`, `tee`, `>`-Umleitung, `rm` auf `main` — dieselbe Änderung war über Write/Edit blockiert | Shell-Schreibbefehle auf `main` blockiert; `/dev/null`, `/tmp`, Tempverzeichnisse ausgenommen |
| Prototyp-Gate | Import aus `backend/`/`frontend/` — genau den Bauwurzeln aus ADR 0002 — nicht erkannt | Verzeichnisliste um `backend|frontend|deploy` ergänzt |
| Prototyp-Gate | `importlib.import_module("prototype.demo")`, `__import__` | Muster für Funktionsform ergänzt |
| Prototyp-Gate | Matcher ohne `Bash`: per Heredoc/Umleitung geschriebener Import lief am Gate vorbei | Matcher erweitert; Bash grob geprüft (Schreibwirkung + Importmuster), pfadgenau bleibt der Write-Weg |
| Prototyp-Gate | Falsch-Positiv: ein Edit, das einen verbotenen Import **entfernt**, wurde blockiert | `old_string` von der Prüfung ausgenommen |

### D2 — Kollision 1a/1b/2 gegen R1 bis R5 (vorgezogen auf Weisung)

Projektauftrag 4.4 «Zur Bezeichnung»: «Die Ränge heissen R1 bis R5 und nicht
1a, 1b, 2.» Dagegen verstiessen: die Prio-Tabelle in
`recht-und-datenschutz.md`, die Regime-Aufzählungen in `legal-reviewer.md` und
`security-specialist-grc.md`, das Abnahmekriterium von R3-F-001 im Backlog —
und **die Homonym-Warnung des Glossars selbst**, die die verbotene Schreibweise
«Rechtsregime-Prio 1b» ausdrücklich empfahl. Alle auf R1 bis R5 gestellt
(R1 StPO, R2 PolG, R3 KDSG, R4 EU-EV 2016/680, R5 Archivierung);
Kennung und Testname von R3-F-001 unverändert (6.6). «Stufe 1b» in
`produktionscode.md` und `frontend-engineer.md` zu «Klassifizierung 1b»
ausgeschrieben. Dritte Kollisionsebene in Repo B: siehe dessen `UEBERGABE.md`.

### Nachführungen auf den entschiedenen Stand

- **13 Rollendateien** trugen denselben überholten Vermerk («offener Punkt der
  Lieferschritte 2 und 3») — nachgeführt auf die Terminierung als R3-Q-005
  (ADR 0001, Fortschreibung 2026-08-20).
- `docker-kubernetes-experte.md` erwartete Kubernetes-Manifeste und
  Cluster-Härtungsnachweise; ADR 0002 (A11) hat Kubernetes ausgeschlossen.
- `software-architect.md` führte pgvector als offen; A4 hat entschieden.
- `static-software-tester.md` verengte die DoD-Kette auf drei Glieder; massgebend
  ist D1 bis D12 (ADR 0002, Abschnitt 6).
- `devops-engineer.md` kannte nur einen der drei Auslöser des Nachweisflusses.
- `produktionscode.md` hätte **beim tatsächlichen Produktionscode nie geladen**:
  die `paths:` deckten `src/**` etc. ab, ADR 0002 legt `backend/`, `frontend/`,
  `deploy/` fest. Dazu TheHive/Cortex in beide Nicht-bauen-Listen (5.17).
- `prototyp.md` liess den 5.6-Punkt «Bearbeitung im Graphen» aus — der Prototyp
  hätte die Regel-DoD erfüllen können, ohne die geforderte Graph-Bearbeitung zu
  zeigen.
- `claude-konfiguration.md`: fünf statt vier Mechanismen, SessionStart als
  zweiter Hook-Zweck, `paths` um `CLAUDE.md`.
- `CLAUDE.md`: Stand-Tabelle auf die freigegebene Reihenfolge, SessionStart-Hook
  als Kanal ausgewiesen.
- `06_Definition_of_Ready_und_Done.md` erklärte die DoD-Befehle für
  «eingesetzt», während ADR 0002 sie als zu bestätigenden Vorschlag führt —
  auf den Vorschlagsstatus präzisiert.
- `07_Roadmap.md`: erledigte Blocker als erledigt gekennzeichnet.

### E5 (Repo-A-Anteil, vorgezogen auf Weisung)

- Artefaktliste in `scripts/nachweise-erzeugen.sh` um 25 Einträge: die 21
  Rollendateien, `versionierung-und-nachweisfluss.md` (einzige ungelistete
  Regel), beide Arbeitsabläufe, der Erzeuger selbst. `docs/uebergaben/` bewusst
  nicht aufgenommen: Prozessvermerke, keine Produktartefakte — bei Bedarf
  nachentscheidbar.
- `paths`-Auslöser von `nachweise-uebertragen.yml` um `.github/workflows/**`
  und `scripts/**` — eine Änderung an der Automatik selbst löste den
  Nachweisfluss bisher nicht aus.
- `docs/NACHWEISE.md` neu erzeugt (eigener Commit nach der Prüfung).

## Widerlegt und bewusst nicht behoben

- **Widerlegt:** «Punktform-Importe (`import prototype.daten`) nicht erkannt» —
  das dritte Muster erfasst sie; per Ausführung belegt. Bestätigt und behoben
  wurde stattdessen die Funktionsform (`import_module`).
- **Befund F (nicht angefasst, nächste Einheit):** Die Schemaprüfung der
  Modellantwort (ADR 0002, 3.7) hat kein Abnahmekriterium; R3-F-015 deckt
  Weiterleitungen, Namensauflösung und IP-Literale nicht. Das ist
  Anforderungsarbeit des Requirements Engineers, keine Konfigurationskorrektur.
- **`actions/checkout@v4`** bleibt an fünf Stellen auf beweglichem
  Versionsschild: zum Pinnen fehlt weiterhin der Zugriff auf die Prüfsumme
  (Sitzung auf `valITino/*` beschränkt). **Richtigstellung vom 2026-08-25:**
  Die Aussage war falsch. Öffentliche Repositories sind über den Git-Proxy
  lesbar; alle fünf Stellen sind auf
  `11d5960a326750d5838078e36cf38b85af677262` (v4.4.0) gepinnt, Dependabot
  hält sie aktuell.
- **Nicht angefasst:** die inhaltliche Bewertung geschlossener Entscheide;
  `maxTurns`-Werte (Startwerte laut ADR 0001, Korrektur erst bei Evidenz).

## Bemerkenswertes aus dem eigenen Prozess

Beim Härten des main-Gates ist mir ein **kyrillisches «е»** in einen Kommentar
geraten — entdeckt durch die eigene ASCII-Prüfung, unmittelbar nach einer
Einheit, deren Hauptbefund Unicode-Homoglyphen waren. Der Prüfsatz prüft
seither beide Gate-Skripte auf reines ASCII. Das bestätigt die Doktrin dieser
Einheiten: **nicht die Aufmerksamkeit prüft, sondern der Prüfsatz.**

## Zweite Prüfrunde: fünf weitere Gate-Umgehungen

Der erste unabhängige Prüflauf gegen den eingefrorenen Stand fiel **nicht
bestanden** aus — er fand fünf Umgehungswege, die die erste Härtungsrunde nicht
abgedeckt hatte, sowie drei Dokumentationsinkonsistenzen. Alle acht durch
Ausführung bestätigt und behoben (Commits `1f093ae…` und `1aa10a1…`).

| # | Umgehung (ausgeführt: lief durch) | Behebung |
|---|---|---|
| 1 | `git worktree add ../wt main`, dann `git -C ../wt commit` / `sed -i ../wt/…` | worktree-add auf main gesperrt; `git -C <pfad>` löst den Zweig jenes Pfads auf |
| 2 | `python -c`, `perl -e`, `node -e`, `php -r`, `dd of=` — schreiben ohne Umleitungszeichen | Interpreter mit Inline-Code auf `main` pauschal blockiert |
| 3 | `git push --mirror` / `--all` / Wildcard-Refspec — überträgt `main` ohne das Wort | Sammel-Pushes blockiert |
| 4 | mehrzeiliger Import (Prettier-Umbruch) — zeilenweiser grep sah ihn nicht | zusätzlich normalisierte Fassung (Kommentare weg, Zeilen flach) geprüft |
| 5 | `import/*c*/('prototype/foo')` — Kommentar bricht das Muster | Blockkommentare vor der Prüfung entfernt |
| 6 | Kommentar nannte `deploy/` fälschlich als Bauwurzel (ADR 0002: nur `backend/`, `frontend/`) | Zitat richtiggestellt |
| 7 | CLAUDE.md führte D2/E5 unmarkiert offen, obwohl im selben Commit erledigt | als erledigt gekennzeichnet |
| 8 | `paths`-Beschreibung in Regel und Rolle nicht mit dem erweiterten Filter nachgezogen | deckungsgleich gemacht |

**Ehrlichkeit zur Reichweite (Kopfkommentar beider Gates neu):** Eine
Textprüfung von Bash-Befehlen ist grundsätzlich nicht dicht — kein Muster fängt
jeden Interpreter. Die Gates sind die **zweite** Verteidigungslinie und fangen
die häufigen Wege früh und laut ab; die harte Zusicherung gegen Schreiben auf
`main` liefert das serverseitige GitHub-Ruleset, gegen Prototyp-Import der
pfadgenaue Write-Weg. Das steht jetzt so im Code, statt Dichtheit zu behaupten.

**Wieder ein eigener Homoglyph:** In der ersten Runde war mir ein kyrillisches
«е» in einen Gate-Kommentar geraten — von der eigenen ASCII-Prüfung gefangen.
Beide Gate-Skripte sind jetzt reines ASCII, im Prüfsatz verankert. Zum zweiten
Mal in dieser Sitzung bestätigt sich: der Prüfsatz prüft, nicht die
Aufmerksamkeit.

**MultiEdit vorsorglich:** Der Prüfer vermutete (ohne es verifizieren zu
können), ein `edits[]`-Array von MultiEdit entginge der Payload-Extraktion. Das
Werkzeug ist in dieser Umgebung nicht bestätigt und stand nicht im Matcher — der
Hook feuerte dafür also nie. Beides ist jetzt vorsorglich geschlossen: die
jq-Extraktion liest `edits[].new_string` (ohne `old_string`), MultiEdit steht in
beiden Matchern.

## Dritte Prüfrunde: der `cd`-Bypass und die Grenze der Textprüfung

Der bestätigende Prüflauf fiel erneut **nicht bestanden** aus — mit einem
kritischen Befund und drei kleineren. Alle behoben (Commit `5a4609c…`), rund 55
Gate-Proben grün.

| # | Befund | Behebung |
|---|---|---|
| N1 (kritisch) | `cd <main-checkout> && git commit` / `&& sed -i` umging das Gate — nur `git -C` löste den Kontext auf | geschützter Zielkontext aus `cd`, `pushd`, `git -C`, `env -C`; git-Verb- und Schreibprüfung hängen daran |
| — Falsch-Positiv | `git worktree add -b <neu> <p> main` (neuer Zweig ab main) wurde blockiert | nur direktes Auschecken von main gesperrt |
| N2 | Zeilenkommentare (`//`) umgingen die Prototyp-Normalisierung | vor den Blockkommentaren entfernt |
| N3 | verschachtelte Blockkommentare nur teilweise entfernt | Ersetzung läuft bis zum Fixpunkt |
| N4 | Kommentar behauptete fälschlich, MultiEdit sei nicht im Matcher | richtiggestellt; jq zusätzlich gegen fehlgeformtes `edits` gehärtet |

**Was diese dritte Runde grundsätzlich zeigt — und was daraus im Code steht.**
Jede Runde fand einen weiteren Bash-Idiom, mit dem sich `main` erreichen liess:
erst `git -C`, dann `cd &&`. Das ist kein Zufall, sondern die Natur einer
Textprüfung von Shell-Befehlen: sie ist gegen einen entschlossenen Umgeher nie
vollständig (die nächsten Kandidaten wären eine Subshell `(cd x; …)` oder
`bash -c "…"`). Der Kopfkommentar beider Gates sagt das jetzt ausdrücklich und
zieht die Konsequenz: **die Gates fangen die gebräuchlichen Idiome früh und
laut ab; die harte Zusicherung gegen Schreiben auf `main` liefert das
serverseitige GitHub-Ruleset, nicht dieses Gate.** Ich habe die gebräuchlichen
Idiome (`cd`, `pushd`, `git -C`, `env -C`) geschlossen und die verbleibende
Grenze benannt, statt eine vierte, fünfte Runde auf immer exotischere Formen zu
führen — das wäre der Wettlauf, den eine Textprüfung strukturell nicht gewinnt.

**Zur Eskalationsregel (3.4).** Die Gate-Prüfung ist zweimal am selben Kriterium
gescheitert (Runde-2-Befunde, dann N1). Die Regel greift bei dreimaligem
Scheitern. Ich lege den Stand deshalb hier vor: die dritte Runde ist behoben und
erneut zur Prüfung gegeben; sollte sie wieder Bash-Idiom-Umgehungen finden, ist
das genau das oben benannte strukturelle Limit — dann ist die richtige Antwort
nicht eine vierte Härtungsrunde, sondern der Verlass auf das serverseitige
Ruleset (die dokumentierte harte Linie), und die Sache gehört dem Auftraggeber
vorgelegt.

## Vierte Prüfrunde: bestanden

Zuschnitt geändert, nachdem der Auftraggeber das Ruleset bestätigt hat: kein
Idiom-Wettlauf mehr (die Integrität hängt nicht mehr am Hook), sondern
**Regressionen und Falsch-Positive** — ein Gate, das legitime Arbeit blockiert,
kostet ab jetzt jede Sitzung Zeit.

**Ergebnis: bestanden.** Über den ganzen geforderten Katalog kein einziger
Falsch-Positiv und keine Regression: `cd` in Unterverzeichnisse, in Nicht-Git-
Verzeichnisse, in Arbeitszweig-Klone, `/tmp`, Pfade mit Leerzeichen, relative
Pfade, `cd` ohne Argument, `cd -`, mehrfaches `cd`, `git -C` auf nicht
existierende Pfade — alles frei. Alle zuvor behobenen Umgehungen blockieren
weiter, alle Auswege bleiben offen. Robustheit: kein Pfad endet mit
Rückgabewert 1, keiner hängt, kaputtes JSON wird abgefangen.

Zwei informative Befunde kamen hinzu, beide nachgeprüft:

**Relative Pfade in der Kontextauflösung — behoben.** `git -C <relativ>` löst
gegen den CWD des Hook-Prozesses auf, nicht gegen den des geprüften Befehls.
Ausgeführt belegt: `cd ../main-klon && git commit` blockierte bei CWD =
Projektbaum, lief bei CWD = `/` durch. Kein Falsch-Positiv, sondern eine
Unterblockierung. Behoben: relative Pfade werden zusätzlich gegen
`CLAUDE_PROJECT_DIR` aufgelöst — der beste verfügbare Anker, da von hier nicht
feststellbar ist, welchen CWD der Harness dem Hook gibt. Nachgemessen: jetzt
CWD-unabhängig, keine neuen Falsch-Positive bei harmlosen relativen Zielen.

**Doku-Kommentar mit wörtlichem Importpfad — bewusst NICHT behoben.** Eine
Datei, deren Kommentar einen verbotenen Import als Beispiel zeigt, wird
blockiert. Der Prüfer hat belegt, dass das vorbestehend ist (identisch in
`6d96f30`), keine Regression. Wichtiger: **eine Behebung wäre ein Loch.**
Prüfte man nur die kommentarbereinigte Fassung, verstümmelte die
`//`-Bereinigung `import x from "prototype//y"` zu `import x from "prototype` —
ein echter Import passte auf kein Muster mehr (ausgeführt belegt). Der
Fehlalarm ist der günstigere Fehler; das steht jetzt samt Beleg und Ausweg als
Kommentar im Skript, damit es niemand später „wegoptimiert".

Damit ist Projektauftrag 3.4 erfüllt: Die Behebungen sind auf einem anderen
Modell als die Umsetzung geprüft.

## Beobachtung zur Rollenkonfiguration (vorgelegt, nicht geändert)

Der Static Software Tester ist in dieser Einheit **dreimal mitten in der Arbeit
gestoppt** — zuletzt nachweislich an der Turn-Grenze `maxTurns: 30` aus ADR
0001. Bei ausführungslastigen Prüfungen mit dutzenden Einzelproben reicht das
nicht. ADR 0001, Abschnitt 5.2, sieht genau diesen Fall vor: „Die Werte sind
Startwerte und werden korrigiert, sobald Rollen erkennbar zu früh abbrechen
oder zu lange laufen." Der Fall ist eingetreten und belegt. Eine Änderung an
`maxTurns` verlangt eine Fortschreibung von ADR 0001 und liegt beim
Auftraggeber — deshalb hier vermerkt statt nebenbei getan.

## Verifikation

- Konsolidierter Prüfsatz: 25 Punkte, ohne Beanstandung (Syntax aller Skripte,
  YAML/JSON, Textreinheit, jede Behebung einzeln).
- main-Gate: 29 Proben (Umgehungen blockiert, Lese- und Auswegfälle frei);
  Prototyp-Gate: 18 Proben inkl. Falsch-Positiv-Kontrollen.
- Frontmatter aller 21 Rollendateien unverändert deckungsgleich mit ADR 0001.
- Unabhängige Prüfung durch den Static Software Tester (anderes Modell) gegen
  die eingefrorenen Commits; Ergebnis im Abschnitt unten.

## Definition of Done

Für diese Einheit anwendbar und erfüllt: jede Behebung gegen Quelle oder durch
Ausführung belegt, Prüfsatz grün, kein halbfertiger Zustand, Übergabedatei
geschrieben, unabhängige Prüfung auf anderem Modell. `docs/NACHWEISE.md` nach
Abschluss neu erzeugt.
