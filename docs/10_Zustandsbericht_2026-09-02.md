# Zustandsbericht 2026-09-02 — vollständige Review beider Repositories

Auf Weisung des Auftraggebers vom 2026-09-02: eine vollständige Review des
gesamten Projekts, dazu die Frage, ob das Team um Skills aus dem angebundenen
Repository `valITino/claude-skills-fullstack` zu ergänzen ist, und die Frage,
was vor dem Grundgerüst noch stehen muss. Vorgänger ist
`docs/09_Zustandsbericht_2026-08-21.md`; dieser Bericht ersetzt ihn nicht,
sondern misst den Stand zwölf Tage später.

**Was dieser Bericht ist und was nicht.** Er ist eine Bestandsaufnahme mit
Befunden; er behebt nichts. Jeder Befund trägt Datei, Stelle, Beleg und die
Rolle, die ihn beheben kann. Die Prüfung lief in elf Dimensionen auf einem
anderen Modell als die Umsetzung (Claude Opus für die Suche, Claude Sonnet für
die Widerlegung jedes Befunds); der Koordinator hat die Befunde, die den Rang
"blockierend" oder "erheblich" tragen, zusätzlich selbst am Bestand
nachgestellt. Befunde, die weder bestätigt noch widerlegt sind, stehen als
solche gekennzeichnet. Stand aller Angaben: 2026-09-02.

## 1. Zusammenfassung

- **Beide Repositories enthalten weiterhin keinen Produktionscode.** Das
  Produkt-Repository besteht aus Dokumentation, Konfiguration, Skripten, dem
  `Makefile` und dem HTML-Prototyp; kein `backend/`, kein `frontend/`, kein
  `deploy/`. Keine offenen Pull Requests, keine offenen Issues, kein
  Versionsschild (GitHub-API und `git tag`, 2026-09-02).
- **Heute erledigt:** Der Entwurf des Definition-of-Done-Gates (R3-Q-001)
  liegt als zwölfte Fortschreibung von ADR 0002, Abschnitt 6.12, vor, geprüft
  in zwei Runden auf einem anderen Modell, committet als
  `21cc3ddbf45668c2e185958f8e2a8d42eeaf0150` und nicht freigegeben. Elf
  Entscheidpunkte E-A bis E-K liegen beim Auftraggeber
  (`docs/uebergaben/2026-09-02_r3-q-001-entwurf-dod-gate.md`).
- **Die Review** lief in elf Dimensionen über beide Repositories und den
  angebundenen Skill-Bestand. 131 Befunde wurden gemeldet, jeder einzeln von
  einem unabhängigen Widerleger auf einem anderen Modell geprüft: 106
  bestätigt (3 blockierend, 51 erheblich, 52 gering), 25 widerlegt. Die
  Befunde mit Rang blockierend und erheblich hat der Koordinator zusätzlich
  selbst am Bestand nachgestellt (5.5).
- **Zwei Gegenstände sind blockierend.** Erstens lässt das main-Gate
  `block-main-write.sh` alltägliche Schreibweisen eines Pushes nach `main`
  durch (Zweigname in Anführungszeichen, Semikolon, Klammer); der Koordinator
  hat das mit dem Skript selbst nachgestellt: `git push origin main` wird
  blockiert, `git push origin 'main'` nicht. Die Zusage in `CLAUDE.md` unter
  "Aktive Gates" trifft damit nicht zu (ST-01, dazu ST-02 und ST-03).
  Zweitens ist `docs/NACHWEISE.md` im Produkt-Repository veraltet: Stand
  `edd895b9e4b210f39d0f1a94c891ce86a7c47fc9`, 48 Artefakte, während der
  Erzeuger heute 55 Artefakte führt und kein Arbeitsablauf die Datei in
  diesem Repository nachführt (NF-001, BER-06, NF-006, NF-007).
- **Die Kette und ihre Gates haben belegte Lücken**, die vor dem Grundgerüst
  wirksam werden: das Prototyp-Gate erkennt Verzeichnisimporte ohne
  Schrägstrich, Pfade mit `./` und die HTML-Form in Richtung Prototyp nach
  Produktionscode nicht (ST-04, ST-05, Prototyp P-01); D11 und D20 prüfen
  ihr Erkennungsmerkmal beziehungsweise vier ihrer Prüfmittel nicht (ADR
  P-03, P-04, P-05); D10 und D12 sind in `docs/06_Definition_of_Ready_und_Done.md`
  mit Prüfmitteln beschrieben, die die Kette nicht verwendet (P-07, P-08,
  NF-007); der Belegprüfer schaltet eine ganze Datei stumm, sobald ein
  Codezaun unpaarig ist (ST-06).
- **Der Nachweisfluss hat drei Lücken:** Der Auslösefilter des
  Arbeitsablaufs kennt das `Makefile` nicht (ST-08, NF-002, R-06, NF-008,
  NF-009), die Idempotenzprüfung vergleicht eine Zeile mit, die sich mit jedem
  Commit ändert (NF-003), und der eingefrorene Abzug lässt sechs von 55
  Artefakten still weg (NF-004, ST-15).
- **Vor dem Grundgerüst** stehen nach der Dokumentenlage fünf Arbeitseinheiten
  (Freigabe und Bau von R3-Q-001, Nachführungen, E4, E3), mindestens vier
  Entscheide des Auftraggebers (E-07, E-08, O-23, Notation R6), zehn offene
  Punkte des ADR mit Termin am Grundgerüst und zwei Umgebungslücken:
  `gitleaks` fehlt, der Docker-Daemon läuft nicht (Abschnitt 6).
- **Skills:** Der fremde Bestand liefert keinen Skill zur Übernahme. Der
  eigene Bestand zeigt zwei Prozeduren mehrerer Rollen ohne Skill (Übergabe
  schreiben; Gegenprüfung auf einem anderen Modell). Vor einem dritten Skill
  stehen der Entscheid, wer `.claude/skills/` schreibt, der terminierte
  Kontrollversuch zum Vorladen und die Abnahme der beiden bestehenden Skills
  (Abschnitt 7).
- **Methodik-Repository:** fünf erhebliche Befunde, alle an Angaben, die
  einen Stand versprechen und einen älteren liefern (Datumsaussage im Kopf
  der Entscheide, Verweis auf einen umbenannten Dateinamen, "D1 bis D12",
  drei überholte Verweisstände, leeres `sprints/` bei laufender Lieferung).

## 2. Git-Zustand beider Repositories

| Repository | `origin/main` | Arbeitszweig `claude/r3-dod-gates-hooks-fn5hia` | Offene Pull Requests | Offene Issues |
|---|---|---|---|---|
| `valITino/r3cosint` | `405ebada79a145ac537d8e4102ce46d029046475` (Merge PR #12, Eingang Methodik) | `21cc3ddbf45668c2e185958f8e2a8d42eeaf0150` (Entwurf R3-Q-001, siehe `docs/uebergaben/2026-09-02_r3-q-001-entwurf-dod-gate.md`) | keine (GitHub-API, 2026-09-02) | keine |
| `valITino/r3coscrum` | `31823e1ec97ccda69defa676b7d5aeae6dceac82` (Nachweise, Stand 405ebada) | `3d895e91e448aedf88946dca59d3bf2b2aa0220b` (Übergabe, methodischer Anteil) | keine | keine |

Beide Arbeitszweige sind am 2026-09-02 frisch von `origin/main` gesetzt und
tragen je einen Commit. Der Klon der Sitzung war flach; nach
`git fetch --unshallow` zählt `origin/main` des Produkt-Repositories 98
Commits. Das Produkt-Repository enthält weiterhin ausschliesslich
Dokumentation, Konfiguration, Skripte, das `Makefile` und den HTML-Prototyp:
kein `backend/`, kein `frontend/`, kein `deploy/`, kein Paketmanifest, keine
Testsuite (gemessen: `ls -A` der Wurzel zeigt `.claude`, `.github`,
`.gitignore`, `CLAUDE.md`, `CONTRIBUTING.md`, `Makefile`, `README.md`,
`docs`, `prototype`, `scripts`).

## 3. Werkzeugumgebung der Sitzung

Gemessen mit `command -v` und `--version` am 2026-09-02 in der
Cloud-Sitzung (Linux, 4 Prozessorkerne):

| Werkzeug | Stand | Bedeutung für die Kette |
|---|---|---|
| git 2.43.0, GNU Make 4.3, bash 5.2.21, jq 1.7, coreutils `timeout` 9.4, util-linux `flock` 2.39.3 | vorhanden | Prüfmittel von D19, D20 und der bestehenden Gates; `timeout` und `flock` sind Prüfmittel des entworfenen Gates (ADR 0002, 6.12.11) |
| uv 0.8.17, ruff 0.15.8, Python 3.11.15 | vorhanden | D1 bis D6 und D18, sobald `backend/pyproject.toml` besteht |
| node 22.22.2, npm 10.9.7 | vorhanden | Frontend-Anteil der Kette, erst nach der Prototyp-Freigabe (5.6) |
| Docker 29.3.1 | vorhanden | D1 und Bereitschaft, sobald `deploy/` besteht |
| gitleaks | **fehlt** | D11 ist Lage C; nach dem Entwurf 6.12 nicht terminierbar, das Gate bliebe rot, bis das Werkzeug installiert ist (E-E) |
| shellcheck | fehlt | kein Kettenschritt nennt es; die Hook-Skripte werden ohne statische Shell-Prüfung geprüft |

## 4. Stand der Lieferreihenfolge und der Kette

Nach `CLAUDE.md` (nachgeführt am 2026-09-02): Schritte 1 bis 4 erledigt,
Schritt 5 läuft. Erledigt seit dem Zustandsbericht vom 2026-08-21: C-Fix, E1,
E2, D2, E5, Befund F, Makefile mit `make dod` (2026-08-31), Belegprüfer als
Kettenschritt D20 (2026-09-01). R3-Q-001 ist entworfen und nicht gebaut
(ADR 0002, Abschnitt 6.12, Entwurf vom 2026-09-02). Danach E4, E3, dann das
Grundgerüst.

`make dod` am Stand `21cc3ddbf45668c2e185958f8e2a8d42eeaf0150` (ausgeführt
2026-09-02): D20 A_OK; D1, D2, D3, D4, D18, D5, D6 Lage B (kein
Produktionscode); D7 Lage C (das Abgleichskript scripts/abnahme-abgleich.sh fehlt), Abbruch,
D19 ohne Befund, Rückgabewert 2. Einzeln ausgeführt: D8 und D9 Lage B, D10,
D11 und D12 Lage C. Die Kette kennt damit heute vier Schritte ohne
Prüfmittel; drei davon entstehen mit dem Grundgerüst, einer (D11) mit der
Installation von `gitleaks`.

Aktive Gates (`.claude/settings.json`): `block-main-write.sh` und
`block-prototype-import.sh` als `PreToolUse`, `session-start-eingang.sh` als
`SessionStart`. Die Gates für die Definition-of-Done-Kette bestehen nicht;
ihr Entwurf liegt vor.

## 5. Befunde

**Vorgehen.** Elf Prüfdimensionen, je ein Prüfer auf Claude Opus mit
Lesezugriff auf beide Repositories, den Skill-Bestand und den Rohtext der
Hook-Dokumentation; höchstens 30 Befunde je Dimension. Jeder Befund ging an
einen Widerleger auf Claude Sonnet, der Zitat, Beleg und Regelverletzung am
Original nachprüfte und im Zweifel widerlegte. Die Massstäbe waren
Projektauftrag, Backlog, Definition of Ready und Done, ADR 0001 und 0002, die
Regeln unter `.claude/rules/` und die methodischen Entscheide. Historische
Dokumente (`docs/uebergaben/`, `docs/08_Freigabe_Schritt_4.md`,
`docs/09_Zustandsbericht_2026-08-21.md`) wurden nicht auf Aktualität
beanstandet. Der erste Lauf wurde durch die Nutzungsgrenze der Sitzung
unterbrochen und nach deren Rücksetzung fortgesetzt; zwei Dimensionen hatten
vor der Unterbrechung gemessen, ihre Widerleger danach — dazwischen liegt der
Commit `21cc3ddbf45668c2e185958f8e2a8d42eeaf0150`, der die Tabelle von
Abschnitt 8 in ADR 0002 geschlossen hat. Die Widerlegung von P-02 (Auftrag,
Backlog, Planung) und P-01 (ADR 0002, Makefile, Definition of Done) beruht
darauf: Der Befund war vor dem Commit richtig und ist mit ihm behoben.

**Lesehinweis.** Kennungen sind je Dimension vergeben und wiederholen sich
über Dimensionen hinweg (zum Beispiel P-01 in drei Dimensionen); die Spalte
"Dimension" macht sie eindeutig. Mehrere Dimensionen haben denselben
Gegenstand unabhängig gefunden; das ist kein Zählfehler, sondern ein Mass
für seine Sichtbarkeit. Die Vorschläge der Prüfer sind in den Rohdaten
enthalten und hier weggelassen; sie sind Vorschläge, keine Behebungen.
Vorschläge und vollständige Belege je Befund stehen in den Prüfprotokollen
der Sitzung und werden auf Verlangen als Anhang nachgeliefert.

### 5.1 Bestätigte Befunde mit Rang blockierend

| Kennung | Dimension | Datei | Befund | Zuständig |
|---|---|---|---|---|
| ST-01 | Hooks, Skripte, Arbeitsabläufe (Code) | .claude/hooks/block-main-write.sh | Die Zeichenklasse vor und nach main/master erfasst weder ein oeffnendes Anfuehrungszeichen noch ein Semikolon oder eine schliessende Klammer; ein Push nach main in diesen alltaeglichen Schreibweisen laeuft durch das Gate hindurch. | devops-engineer (Umsetzung), Verifikation static-software-tester und dynamic-software-tester nach ADR 0001 |
| NF-001 | Nachweisfluss und Automatik | docs/NACHWEISE.md | Die versionierte Fassung des Nachweisverzeichnisses in Repo A fuehrt 48 Artefakte und 22 ueberholte Commit-Pruefsummen, waehrend die Artefaktliste des Erzeugers 55 Eintraege hat. | Protocol Master (Projektauftrag 6.6, "Zustaendigkeit: Protocol Master fuer das Nachweisverzeichnis"), Entscheid beim Auftraggeber |
| BER-06 | Bereitschaft für das Grundgerüst | docs/NACHWEISE.md | Das Nachweisverzeichnis des Produkt-Repositories fuehrt einen 47 Commits alten Repository-Stand und 48 Artefakte, waehrend die von derselben Automatik erzeugte Kopie im Methodik-Repository den Stand des Arbeitszweigs und 55 Artefakte fuehrt; Makefile, Belegpruefer und die beiden Skills fehlen in der Fassung des Produkt-Repositories. | Protocol Master (4.2, 6.6), fuer den Arbeitsablauf DevOps Engineer |

### 5.2 Bestätigte Befunde mit Rang erheblich

| Kennung | Dimension | Datei | Befund | Zuständig |
|---|---|---|---|---|
| P-03 | Auftrag, Backlog, Planung | docs/adr/0002-architekturentscheid-ziel-stack.md | Der offene Punkt O-12 hat keine Zeile in der Tabelle der offenen Punkte, obwohl Abschnitt 6.5 ihn ausdruecklich anlegt und mehrere spaetere Abschnitte ihn als offen fuehren. | Software Architect |
| P-04 | Auftrag, Backlog, Planung | docs/05_Product_Backlog.md | Der Backlog fuehrt die Bestaetigung des Schnitts in erste und zweite lieferfaehige Fassung als offenen Punkt, obwohl derselbe Entscheid in docs/08_Freigabe_Schritt_4.md als E-03 am 2026-08-20 bestaetigt protokolliert ist. | Product Owner |
| P-05 | Auftrag, Backlog, Planung | docs/05_Product_Backlog.md | Das Abnahmekriterium verlangt, dass der ADR die Komponentenbibliothek nennt; ADR 0002 nennt bewusst keine, und die von ADR 0002 selbst terminierte Nachfuehrung dieses Abnahmekriteriums ist nicht ausgefuehrt, obwohl der Eintrag als abgenommen gefuehrt wird. | Product Owner |
| P-06 | Auftrag, Backlog, Planung | docs/05_Product_Backlog.md | Die Vorgabe aus 3.1, dass Architekturentscheid und Grundgeruest vorgelegt und freigegeben werden, ist nur zur Haelfte durch ein Abnahmekriterium gedeckt: kein Backlog-Eintrag prueft das Grundgeruest, das es zudem nicht gibt. | Product Owner mit Requirements Engineer |
| P-07 | Auftrag, Backlog, Planung | docs/05_Product_Backlog.md | Die Vorgabe aus 6.6, dass jede Anforderung einen erkennbaren Status samt Aenderungshistorie hat, ist weder umgesetzt noch als Backlog-Eintrag noch als belegte Streichung gefuehrt; der Backlog kennt kein Statusfeld je Eintrag. | Requirements Engineer mit Product Owner |
| P-08 | Auftrag, Backlog, Planung | docs/05_Product_Backlog.md | Der Eintrag erfasst bei der Falleroeffnung eine "Aufbewahrungsklasse" als Eingabefeld; genau dieses Feld hat der Projektauftrag in 4.4 Punkt 3b gestrichen und durch die Fallkategorie ersetzt. | Product Owner |
| P-09 | Auftrag, Backlog, Planung | docs/05_Product_Backlog.md | Die Vorgabe aus 5.17, dass die genaue Restzahl der Werkzeuge nach den Streichungen im Backlog festgehalten wird, ist nicht erfuellt; stattdessen fuehrt das Kontextmodell eine abgeleitete Gesamtzahl. | Product Owner |
| P-10 | Auftrag, Backlog, Planung | r3coscrum: methodik/entscheide.md | Der methodische Entscheid S7 schliesst eine Skill fuer eine einzelne Rolle aus; der Projektauftrag 5.12 verlangt ausdruecklich eine Skill-Definition fuer die Rolle IT Supporter, und kein Dokument loest den Widerspruch auf. | Auftraggeber, fachlich vorbereitet durch den Scrum Master und den Software Architect |
| P-11 | Auftrag, Backlog, Planung | docs/00_Projektauftrag.md | Die Tabelle der geklaerten Punkte fuehrt CASE/UCO weiterhin als festgelegtes Exportformat und verweist dabei auf 5.10, wo dieselbe Festlegung ausdruecklich zurueckgenommen ist. | Protocol Master, Freigabe der Baseline beim Auftraggeber |
| P-13 | Auftrag, Backlog, Planung | docs/05_Product_Backlog.md | Die Vorgabe aus 5.15, die Modellauswahl an einem versionierten Pruefsatz zu messen und bei jedem Modellwechsel erneut zu durchlaufen, hat weder einen Backlog-Eintrag noch eine belegte Streichung. | Product Owner mit Requirements Engineer |
| P-02 | ADR 0002, Makefile, Definition of Done | docs/adr/0002-architekturentscheid-ziel-stack.md | O-12 wird im ADR an mindestens acht Stellen als offener Punkt gefuehrt, hat aber in Abschnitt 8 keine Zeile. | Software Architect (ADR 0002) |
| P-03 | ADR 0002, Makefile, Definition of Done | Makefile | Der Makefile-Schritt D11 kennt keine Lage B und prueft sein Erkennungsmerkmal nicht, obwohl die Objekttabelle des ADR fuer D11 ein Erkennungsmerkmal und eine Lage B nennt. | DevOps Engineer (Makefile) beziehungsweise Software Architect (ADR 0002) |
| P-04 | ADR 0002, Makefile, Definition of Done | Makefile | Das Erkennungsmerkmal von D20 wird nirgends geprueft; ein leerer Bestand ergibt einen gruenen Schritt statt des vom ADR verlangten Befunds. | DevOps Engineer (Makefile) mit Software Architect (Skript, O-15 offen) |
| P-05 | ADR 0002, Makefile, Definition of Done | Makefile | Vier der in der Objekttabelle genannten Pruefmittel von D20 — bash, grep, sed, awk — werden weder im Makefile noch im Skript geprueft; ihr Fehlen ergaebe A_FAIL statt Lage C. | DevOps Engineer (Makefile) beziehungsweise Software Architect (ADR 0002) |
| P-06 | ADR 0002, Makefile, Definition of Done | Makefile | Der D19-Kommentarblock gibt die Festlegungstabelle des ADR in einem Stand wieder, den die vierte (6.4) und die neunte (6.9) Fortschreibung ueberholt haben; er nennt weder die Inhaltspruefsummen noch die Beobachtbarkeit des Index und traegt die vom ADR ausdruecklich berichtigte Formulierung ".git/ vorhanden". | DevOps Engineer (Makefile) |
| P-07 | ADR 0002, Makefile, Definition of Done | docs/06_Definition_of_Ready_und_Done.md | Das Kriterium D12 verlangt genau das, was der Kettengrundsatz des ADR dem Schritt untersagt, und wird von keinem Befehl der Kette geprueft. | DevOps Engineer mit Product Owner, Bestaetigung Auftraggeber (ADR 0002, Abschnitt 9) |
| P-08 | ADR 0002, Makefile, Definition of Done | docs/06_Definition_of_Ready_und_Done.md | Das Kriterium D10 nennt als Pruefmittel den PreToolUse-Hook, den das ADR fuer diesen Schritt ausdruecklich als untauglich befunden hat; das tatsaechliche Pruefmittel der Kette kommt darin nicht vor. | DevOps Engineer mit Product Owner, Bestaetigung Auftraggeber (ADR 0002, Abschnitt 9) |
| ST-02 | Hooks, Skripte, Arbeitsabläufe (Code) | .claude/hooks/block-main-write.sh | Die Zusage des Kopfkommentars, das Anlegen eines Arbeitsbaums auf main sei gedeckt, trifft nicht zu, sobald der Zweigname gequotet ist oder ein Semikolon folgt (V12: benannte Pruefung existiert im Code nur in engerer Form als im Kopf behauptet). | devops-engineer (Umsetzung), Verifikation static-software-tester nach ADR 0001 |
| ST-03 | Hooks, Skripte, Arbeitsabläufe (Code) | .claude/hooks/block-main-write.sh | Fehlt git, endet das Gate still mit 0 und laesst alles durch, waehrend es bei fehlendem jq mit 2 blockiert; die zweite Voraussetzung des Gates ist ungewacht. | devops-engineer (Umsetzung), Verifikation static-software-tester nach ADR 0001 |
| ST-04 | Hooks, Skripte, Arbeitsabläufe (Code) | .claude/hooks/block-prototype-import.sh | Alle vier Muster der Richtung 1 verlangen einen Schraegstrich hinter prototype; ein Verzeichnisimport ohne Schraegstrich — die uebliche Aufloesung ueber eine Indexdatei — wird nicht erkannt. | devops-engineer (Umsetzung), Verifikation static-software-tester nach ADR 0001 |
| ST-05 | Hooks, Skripte, Arbeitsabläufe (Code) | .claude/hooks/block-prototype-import.sh | Der Praefixteil (\.\./)* laesst nur Folgen von ../ zu; ein gleichwertiger relativer Pfad, der mit ./ beginnt, wird nicht erkannt, obwohl er dasselbe Ziel im Produktionscode benennt. | devops-engineer (Umsetzung), Verifikation static-software-tester nach ADR 0001 |
| ST-06 | Hooks, Skripte, Arbeitsabläufe (Code) | scripts/belege-pruefen.sh | Ein einzelner, unpaariger Codezaun in einer versionierten Markdown-Datei schaltet den gesamten Rest dieser Datei fuer alle fuenf Pruefungen stumm, ohne dass der Lauf das meldet; diese Grenze steht weder im Kopfkommentar noch in der Liste "Bisher benannte Grenzen" der Schlussausgabe. | static-software-tester meldet; Umsetzung durch die im Auftrag benannte Umsetzungsrolle nach Entscheid des Auftraggebers zu O-15 |
| ST-07 | Hooks, Skripte, Arbeitsabläufe (Code) | scripts/nachweise-erzeugen.sh | ${1:-...} behandelt ein leeres Argument wie ein fehlendes; scheitert mktemp, uebergibt D12 eine leere Zeichenkette und der Erzeuger schreibt in die versionierte Datei docs/NACHWEISE.md statt in eine Wegwerfdatei. | devops-engineer und protocol-master (Erzeuger), Verifikation static-software-tester nach ADR 0001 |
| ST-08 | Hooks, Skripte, Arbeitsabläufe (Code) | .github/workflows/nachweise-uebertragen.yml | Der paths-Filter fuehrt Makefile nicht, obwohl das Makefile seit dem 2026-08-31 in der Artefaktliste des Erzeugers steht; die an zwei Stellen niedergeschriebene Deckungsgleichheit besteht nicht. | devops-engineer und protocol-master; Nachfuehrung in .claude/rules/versionierung-und-nachweisfluss.md |
| R-01 | Rollen, Skills, ADR 0001 | .claude/skills/dod-kette-belegen/SKILL.md | Der Skill definiert Lage C enger als die verbindliche Fassung: er kennt nur das fehlende Pruefmittel, nicht das vorhandene, das die Aussage nicht traegt. | Auftraggeber — ADR 0001, Abschnitt 8: "Wer .claude/skills/ beschreiben darf. Abschnitt 4 weist .claude/ keiner Rolle zu" |
| R-02 | Rollen, Skills, ADR 0001 | .claude/agents/static-software-tester.md | Die Rolle, die die statischen Glieder der Kette ausfuehrt, beschreibt den Umfang der Kette auf dem Stand vom 2026-08-30; die Rahmenpruefung D19 und der seit dem 2026-09-01 erste Kettenschritt D20 fehlen. | Auftraggeber — ADR 0001, Abschnitt 4 und 8 weisen .claude/ keiner Rolle zu |
| R-03 | Rollen, Skills, ADR 0001 | docs/adr/0001-rollenmodell.md | Die auf die naechste Sitzung terminierte Pruefung, ob das Vorladen ueber skills: in dieser Umgebung wirkt, ist ueberfaellig und nirgends als durchgefuehrt belegt; damit steht das Werkzeug Skill bei neun Rollen weiter auf einer Begruendung, deren Frist abgelaufen ist. | Software Architect (Fortschreibung des ADR, 4.3), Entscheid ueber die Werkzeugliste beim Auftraggeber |
| R-04 | Rollen, Skills, ADR 0001 | docs/adr/0001-rollenmodell.md | R3-C-007 wird als erledigt beziehungsweise erfuellt gefuehrt, obwohl der Abnahmetest des Eintrags nirgends existiert; die Definition of Done verlangt ihn als bestandenen Test. | Software Architect (ADR-Fortschreibung) mit Product Owner (Abnahme im Backlog) |
| R-06 | Rollen, Skills, ADR 0001 | .claude/agents/devops-engineer.md | Die Rollendatei setzt die Ausloesepfade des Nachweis-Arbeitsablaufs mit der Artefaktliste gleich; seit der Aufnahme des Makefiles in die Artefaktliste stimmt diese Gleichsetzung nicht mehr, und eine Aenderung allein am Makefile loest keinen Nachweisfluss aus. | DevOps Engineer (Arbeitsablauf, 4.2); Rollendatei: Auftraggeber, da .claude/ keiner Rolle zugewiesen ist |
| NF-002 | Nachweisfluss und Automatik | .github/workflows/nachweise-uebertragen.yml | Der paths-Filter deckt den Pfad Makefile aus der Artefaktliste nicht ab; ein Push nach main, der nur das Makefile aendert, loest den Nachweisfluss nicht aus, obwohl der Kommentar Deckungsgleichheit behauptet. | DevOps Engineer (Projektauftrag 6.6, "DevOps Engineer fuer den Arbeitsablauf") |
| NF-003 | Nachweisfluss und Automatik | .github/workflows/nachweise-uebertragen.yml | Die Idempotenzpruefung vergleicht die ganze Datei, die in Zeile 8 den HEAD-Commit traegt; ein Lauf, der von einer Datei ausgeloest wird, die zwar unter den paths-Filter faellt, aber nicht in der Artefaktliste steht, schreibt deshalb trotz unveraenderter Nachweise nach Repo B. | DevOps Engineer |
| NF-004 | Nachweisfluss und Automatik | .github/workflows/nachweise-uebertragen.yml | Der Abzug sammelt nur Pfade mit den Endungen md, json und sh; sechs der 55 Artefakte fallen dadurch stillschweigend aus der Kopie, ohne dass der Lauf etwas meldet. | DevOps Engineer, fachlich mit Protocol Master |
| NF-005 | Nachweisfluss und Automatik | .claude/hooks/session-start-eingang.sh | Das Zeichenbudget des Hooks (20000 plus rund 2360 Rahmen) liegt weit ueber der Kappungsgrenze von 10'000 Zeichen, die Claude Code auf Hook-Ausgaben anwendet; oberhalb dieser Grenze erreicht die Einfassung des fremden Teils den Sitzungskontext nicht mehr vollstaendig, sondern als Vorschau samt Dateipfad. | DevOps Engineer mit Security Specialist GRC (Verfahrensgarantie 5.4) |
| NF-006 | Nachweisfluss und Automatik | .claude/rules/dokumentation.md | Die Regel beschreibt einen Mechanismus, der die versionierte Datei in Repo A nachfuehrt; ein solcher Mechanismus besteht nicht, weil der Arbeitsablauf nur lesend auf Repo A zugreift und ausschliesslich nach Repo B schreibt. | Protocol Master |
| NF-007 | Nachweisfluss und Automatik | docs/06_Definition_of_Ready_und_Done.md | Das Kriterium verlangt, dass die genannte Datei neu erzeugt ist; die Kette darf sie nach dem Kettengrundsatz aus ADR 0002 gerade nicht schreiben und erzeugt stattdessen eine Wegwerfdatei, sodass das Kriterium in dieser Formulierung von keiner Umsetzung erfuellt werden kann. | Requirements Engineer mit DevOps Engineer, Bestaetigung Auftraggeber |
| M-01 | Methodik-Repository | r3coscrum: methodik/entscheide.md | Der Kopfabsatz erklaert fuer alle Entscheide des Dokuments, sie seien spaetestens am 18. August 2026 dokumentiert und ihre Einzeldaten seien [OFFEN] — sieben Entscheide tragen inzwischen ein spaeteres, ausgeschriebenes Datum. | Protocol Master (ADR 0001, Nachweis- und Protokollfuehrung) |
| M-02 | Methodik-Repository | r3coscrum: methodik/entscheide.md | Der einzige Beleg von V11 verweist auf den Dateinamen docs/uebergaben/2026-08-31_belegpruefer-abbruch-nach-3-4.md, dessen Datum das Produkt-Repository am selben Tag als falsch berichtigt und in 2026-09-01_... umbenannt hat; derselbe Commit, der V11 auf den 2026-09-01 berichtigte, liess den Verweis auf die falsch datierte Fassung stehen. | Protocol Master (ADR 0001) |
| M-03 | Methodik-Repository | r3coscrum: methodik/scrum-aufbau.md | Die Angabe, die konkrete Befehlskette bestehe aus "D1 bis D12", gibt den Stand vom 2026-08-25 wieder; der Architekturentscheid haelt seit dem 2026-08-30 ausdruecklich fest, dass diese Aufzaehlung ueberholt ist. | Scrum Master (ADR 0001, Planungsartefakte) |
| M-04 | Methodik-Repository | r3coscrum: methodik/arbeitsprodukte.md | Drei als "Stand im Produkt-Repository" gefuehrte Verweise zeigen auf ueberholte Commits, obwohl das Nachweisverzeichnis im selben Repository fuer dieselben Artefakte neuere Staende fuehrt. | Requirements Engineer (Arbeitsprodukte nach 6.3), Nachfuehrung des Verweisstandes Protocol Master |
| M-05 | Methodik-Repository | r3coscrum: sprints/ | Der Scrum-Aufbau beschreibt Sprint Review und Retrospektive im Gegenwartsmodus als laufende Praxis mit Ablage unter sprints/, waehrend seit dem Beginn der Umsetzung am 2026-08-20 kein einziges Sprintergebnis und kein Meilenstein entstanden ist; das Dokument sagt nirgends, dass die laufende Lieferung ausserhalb von Sprints stattfindet. | Scrum Master mit dem Auftraggeber |
| S-01 | CLAUDE.md, Regeln, Eingangskanal | README.md | Der README behauptet im Praesens eine technische Durchsetzung der Definition of Done durch einen Hook, die es im Repository nicht gibt. | Auftraggeber (README und CLAUDE.md sind Steuerungsdateien der Wurzel; ADR 0001 Abschnitt 8 weist .claude/ und die Steuerungstexte keiner Rolle zu, sie wurden vo |
| S-02 | CLAUDE.md, Regeln, Eingangskanal | .claude/settings.json | Die beiden aktiven Gates tragen eine gegenueber dem Standard stark verkuerzte Zeitgrenze; ein an dieser Grenze abgebrochener Hook laesst den Werkzeugaufruf durch, und weder die Regel noch CLAUDE.md nennen diesen stillen Durchlassweg, obwohl beide Dokumente die Grenzen der Gates sonst ausdruecklich benennen. | SecDevOps Engineer (ADR 0001 Abschnitt 3, Zeile 75: "Pipeline- und Hook-Konfiguration"; ADR 0001 Abschnitt 8: "die Hook-Konfiguration liegt beim SecDevOps Engin |
| BER-03 | Bereitschaft für das Grundgerüst | docs/adr/0002-architekturentscheid-ziel-stack.md | Der in Abschnitt 6.5 angelegte offene Punkt O-12 fehlt in der Tabelle der offenen Punkte vollstaendig, obwohl er dort faellig "mit dem Grundgeruest" waere und an sechs weiteren Stellen des ADR als offen gefuehrt wird. | Software Architect (Fortschreibung von ADR 0002) |
| BER-04 | Bereitschaft für das Grundgerüst | docs/adr/0002-architekturentscheid-ziel-stack.md | Beide Stellen bezeichnen das Anlegen des Grundgeruests als "naechste Arbeitseinheit", waehrend die verbindliche Lieferreihenfolge in CLAUDE.md drei Arbeitseinheiten davorsetzt. | Software Architect (Fortschreibung von ADR 0002) |
| BER-07 | Bereitschaft für das Grundgerüst | docs/05_Product_Backlog.md | Das Abnahmekriterium von R3-C-002 ist mit dem heutigen Bestand nicht erfuellbar, weil der Projektauftrag die Altbezeichnung notwendigerweise nennt und die Ausnahmeklausel diese Stelle nicht deckt. | Product Owner mit Requirements Engineer |
| SK-02 | Skill-Bedarf | docs/adr/0001-rollenmodell.md | Die auf "zu Beginn der naechsten Sitzung" terminierte Feststellung, ob das Vorladen wirkt, ist in keinem Dokument des Bestandes als ausgefuehrt belegt, obwohl seit dem 2026-08-31 weitere Arbeitseinheiten mit Uebergabedateien abgeschlossen wurden. | Auftraggeber (Terminierung in ADR 0001 Abschnitt 5.1); fachlich vorzubereiten durch den Software Architect |
| SK-04 | Skill-Bedarf | .claude/skills/pruefbefund-melden/SKILL.md | Der Skill dehnt die Reichweite von Projektauftrag 5.3 auf den Pruefbericht aus ("gilt ... genauso"), waehrend die beiden Rollendateien, aus denen die Anforderung stammt, ausdruecklich nur "in Anlehnung an" 5.3 formulieren; im Schwesterskill ist genau dieses Metadatum am 2026-08-31 aus demselben Grund gestrichen worden. | Auftraggeber — ADR 0001 Abschnitt 8; fachlich vorzubereiten durch den Software Architect |
| P-01 | Prototyp (5.6) | .claude/hooks/block-prototype-import.sh | Das Gate blockiert in Richtung Produktionscode-zu-Prototyp auch die HTML-Form src=/href=, in der Gegenrichtung Prototyp-zu-Produktionscode dagegen nicht — genau die Form, in der die einzige Prototyp-Datei (eine HTML-Datei) einen solchen Bezug herstellen würde. | SecDevOps Engineer (ADR 0001, Abschnitt 8: "die Hook-Konfiguration liegt beim SecDevOps Engineer"); Verifikation Static Software Tester (3.4) |
| P-04 | Prototyp (5.6) | prototype/OSINT_Plattform_Demo.html | Die Demo trägt keinen dauerhaft sichtbaren Hinweis auf Demonstrationszweck und synthetische Daten; die Wörter "Demonstrationszweck" und "synthetisch" kommen in der Datei nicht vor. | UX/UI-Designer (Schreibrecht im Prototyp-Verzeichnis), im Rahmen von R3-F-050 |
| FORM-01 | Form, Sprache, Tabellen | .claude/skills/dod-kette-belegen/SKILL.md | Die Lage-C-Definition des Skills gibt den vor dem 2026-09-01 geltenden Wortlaut wieder und laesst die am 2026-09-01 in ADR 0002, 6.9.2 beschlossene Schaerfung weg; der Skill traegt im Kopf gleichwohl den Vermerk "Stand 2026-09-01". | Nach ADR 0001, Abschnitt 8, ist .claude/skills/ keiner Rolle zugewiesen ("Abschnitt 4 weist .claude/ keiner Rolle zu"); damit Koordinator beziehungsweise Auftra |
| FORM-03 | Form, Sprache, Tabellen | docs/adr/0002-architekturentscheid-ziel-stack.md | Der offene Punkt O-12 hat in der Registertabelle des Abschnitts 8 keine Zeile, obwohl derselbe ADR ihn an mehreren aktuellen Stellen als offen fuehrt. | Software Architect als Verfasser des ADR; Eintrag durch den Koordinator, wie bei den uebrigen Fortschreibungen vermerkt. |

### 5.3 Bestätigte Befunde mit Rang gering

| Kennung | Dimension | Datei | Befund |
|---|---|---|---|
| P-12 | Auftrag, Backlog, Planung | docs/00_Projektauftrag.md | Ein Absatz steht ohne Leerzeile mitten in der Tabelle der offenen Punkte; die Tabelle endet damit nach Zeile L, und die Zeile M erscheint als Fliesstext statt als Tabellenzeile. |
| P-14 | Auftrag, Backlog, Planung | docs/adr/0002-architekturentscheid-ziel-stack.md | O-1 steht in der Tabelle der offenen Punkte unmarkiert, obwohl derselbe ADR ihn in Abschnitt 10 als bestaetigt protokolliert; andere erledigte Zeilen derselben Tabelle tragen eine Marke. |
| P-15 | Auftrag, Backlog, Planung | docs/00_Projektauftrag.md | Dieser offene Punkt ist in keiner der gefuehrten Offene-Punkte-Listen terminiert und traegt weder Faelligkeit noch Abnahmekriterium. |
| P-18 | Auftrag, Backlog, Planung | docs/00_Projektauftrag.md | Die Zaehlung geht nicht auf: Der Einleitungssatz nennt elf urspruengliche Punkte, davon zehn erledigt, der Erledigt-Absatz zaehlt jedoch elf Buchstaben auf, und zwei davon stehen in derselben Tabelle zugleich als offen. |
| P-19 | Auftrag, Backlog, Planung | docs/05_Product_Backlog.md | Die Vorgabe aus 5.7, dass jede Anmeldung mit Zeitpunkt, Anbieter und Konto protokolliert wird, ist in keinem Abnahmekriterium abgebildet. |
| P-20 | Auftrag, Backlog, Planung | docs/05_Product_Backlog.md | Die Arbeitsprodukte, die den Prototyp nach 5.6 ueberleben, sind in keinem Abnahmekriterium des Prototyp-Eintrags verlangt. |
| P-21 | Auftrag, Backlog, Planung | docs/07_Roadmap.md | Die Roadmap weist die Wartezeiten nicht als eigene Positionen aus, sondern erklaert sie fuer in den Sprintzahlen enthalten; der Projektauftrag verlangt eigene Positionen. |
| P-22 | Auftrag, Backlog, Planung | docs/05_Product_Backlog.md | Das im Projektauftrag namentlich als Bestandteil von Anhang A genannte Werkzeug Hunchly hat weder einen Backlog-Eintrag noch eine belegte Streichung, waehrend die drei im selben Satz genannten Werkzeuge je einen Eintrag haben. |
| P-23 | Auftrag, Backlog, Planung | docs/05_Product_Backlog.md | Die Einleitung zu Etappe 6 sagt, ihre Eintraege bildeten die Bereitschaftsliste aus 5.16 ab; tatsaechlich liegt Bereitschaftspunkt 1 in Etappe 1 und Punkt 7 ist kein Eintrag, was die Einleitung nicht sagt. |
| P-24 | Auftrag, Backlog, Planung | docs/05_Product_Backlog.md | Die drei Punkte der betrieblichen Sorgfalt aus 5.15 (Herkunft und Pruefsumme der Gewichte, safetensors statt pickle, Fuehrung im Betriebsprotokoll) sind nur als Rolleninstruktion vorhanden, nicht als Backlog-Eintrag mit Abnahmekriterium. |
| P-09 | ADR 0002, Makefile, Definition of Done | Makefile | Fuer den Oberflaechen-Anteil von D8 fehlt die vom ADR als Pruefmittel genannte Skriptprobe; D8 ist der einzige Schritt der Reihe D1 bis D8, der sie nicht ausfuehrt. |
| P-10 | ADR 0002, Makefile, Definition of Done | docs/adr/0002-architekturentscheid-ziel-stack.md | Die Anmerkung zu D6 verweist auf D6 selbst; der Verweis ist zirkulaer und benennt die Quelle der drei Module nicht. |
| P-11 | ADR 0002, Makefile, Definition of Done | docs/adr/0002-architekturentscheid-ziel-stack.md | Die Kopfzeile sagt, die elfte Fortschreibung beruehre Abschnitt 9; Abschnitt 9 fuehrt keine Zeile der elften Fortschreibung. |
| P-12 | ADR 0002, Makefile, Definition of Done | docs/06_Definition_of_Ready_und_Done.md | Das Kriterium D1 traegt zwei Aenderungen aus ADR 0002 (6.2.1 und 6.7), die weder die Stand-Zeile noch die Fortschreibungstabelle dieses Dokuments verzeichnet. |
| P-13 | ADR 0002, Makefile, Definition of Done | Makefile | Die Bestandsaufnahme im Kopfkommentar ist unrichtig: unter scripts/ liegen seit dem 2026-09-01 zwei weitere Dateien, die derselbe Block in seiner D20-Zeile bereits voraussetzt. |
| ST-09 | Hooks, Skripte, Arbeitsabläufe (Code) | .claude/hooks/block-prototype-import.sh | Ein Interpreter mit Inline-Code schreibt ueber seine eigene Datei-Schnittstelle, ohne eines dieser Zeichen im Befehlstext zu tragen; das Prototyp-Gate erkennt darin keine Schreibwirkung, waehrend das main-Gate dieselbe Befehlsklasse ausdruecklich erfasst. |
| ST-10 | Hooks, Skripte, Arbeitsabläufe (Code) | .claude/settings.json | Der Matcher fuehrt den Ausloeser fork nicht; bei einer abgezweigten Sitzung laeuft der Eingangs-Hook nicht und der Kanal aus Projektauftrag 6.6, Gegenrichtung B nach A, bleibt in dieser Sitzung stumm. |
| ST-11 | Hooks, Skripte, Arbeitsabläufe (Code) | .claude/settings.json | Der Matcher fuehrt das Werkzeug PowerShell nicht; auf einer Umgebung, auf der es verfuegbar ist, laeuft keines der beiden Gates fuer einen darueber abgesetzten Befehl. |
| ST-12 | Hooks, Skripte, Arbeitsabläufe (Code) | scripts/belege-pruefen.sh | Fehlt das Werkzeug git, endet das Skript mit 2 (Befund am Bestand) statt mit 3 (Lage C) und meldet dabei eine falsche Ursache — es behauptet, es liege kein Git-Repository vor, obwohl das Repository da ist und nur das Werkzeug fehlt. |
| ST-14 | Hooks, Skripte, Arbeitsabläufe (Code) | scripts/belege-pruefen.sh | Der Kopf beschreibt die Ausnahme unbedingt ("'claude', 'origin', 'fix' ohne fuehrenden Punkt gelten als Git-Referenz ..., nicht als Pfad"); der Code wendet sie nur an, wenn das letzte Segment keine Dateiendung traegt. Die im Kopf benannte Pruefung existiert im Code in anderer Form (V12). |
| ST-15 | Hooks, Skripte, Arbeitsabläufe (Code) | .github/workflows/nachweise-uebertragen.yml | Der Abzug erfasst nur Dateien mit den Endungen md, json und sh; die uebrigen Artefakte des Nachweisverzeichnisses fallen still weg, obwohl der Schritt als eingefrorener Abzug der verwiesenen Dateien beschrieben ist. |
| R-08 | Rollen, Skills, ADR 0001 | .claude/skills/dod-kette-belegen/SKILL.md | Der Skill hat weder ein Verzeichnis references/ noch die vorgeschriebene Verweistabelle; die Bauform verlangt beides als festen Bestandteil einer SKILL.md. |
| R-10 | Rollen, Skills, ADR 0001 | .claude/skills/dod-kette-belegen/SKILL.md | Der Skill beschreibt D19 nur als Vorher-Nachher-Vergleich; dass ein gesetztes Maskierungsmerkmal fuer sich genommen Lage C ist, auch wenn es schon vor dem Lauf gesetzt war, fehlt. |
| R-11 | Rollen, Skills, ADR 0001 | .claude/agents/full-stack-engineer.md | Die erwartete Ausgabeform gibt die Definition-of-Done-Kette als fuenfgliedrige Aufzaehlung wieder; sie stammt aus dem als beispielhaft gekennzeichneten Aufbau in 3.4 und deckt die heute festgelegte Kette (D20, D1 bis D12, D18, Rahmenpruefung D19, Einstieg make dod) nicht ab. |
| R-12 | Rollen, Skills, ADR 0001 | .claude/agents/backend-engineer.md | Dieselbe fuenfgliedrige Aufzaehlung tritt an die Stelle der heute festgelegten Kette; der Einstieg make dod und die Schritte D7 bis D12, D18 und D20 fehlen. |
| R-15 | Rollen, Skills, ADR 0001 | docs/05_Product_Backlog.md | Die Aufzaehlung der Rollen, die ihre Schreibgrenze nur funktional benennen, fuehrt vier Rollen; der IT Supporter erfuellt dieselbe Beschreibung und ist nicht mitgefuehrt. |
| NF-008 | Nachweisfluss und Automatik | .claude/rules/versionierung-und-nachweisfluss.md | Die Regel zaehlt die Pfade der Artefaktliste ein drittes Mal auf und ist dabei veraltet: Makefile fehlt. |
| NF-009 | Nachweisfluss und Automatik | .github/workflows/meilenstein-tag.yml | Die Begruendung, weshalb ein vom Arbeitsablauf erzeugtes Versionsschild keinen zweiten Lauf ausloesen muss, stuetzt sich auf eine Deckungsgleichheit, die seit dem 2026-09-01 nicht mehr besteht. |
| NF-010 | Nachweisfluss und Automatik | .claude/settings.json | Der Matcher laesst die dokumentierte Quelle fork aus; in einer abgezweigten Sitzung laeuft der Eingangskanal nicht, ohne dass das auffaellt. |
| NF-012 | Nachweisfluss und Automatik | r3coscrum: nachweise/HINWEIS.md | Die Datei besteht ausschliesslich aus einem HTML-Kommentar; in der gerenderten Ansicht von GitHub zeigt sie nichts an, obwohl sie den Warnhinweis an den Leser tragen soll. |
| NF-013 | Nachweisfluss und Automatik | docs/EINGANG_METHODIK.md | Die Vorlage beschreibt eine Eintragsform, die der erzeugende Arbeitsablauf nicht schreibt; ein nach der Vorlage von Hand gesetzter Eintrag traegt kein Feld, an dem Hook und Arbeitsablauf den Anschlusspunkt erkennen. |
| M-06 | Methodik-Repository | r3coscrum: methodik/arbeitsprodukte.md | Die drei Verweislisten fuehren einen Eintrag "[Abschnitt 2]", der im Text der jeweiligen Datei nirgends vorkommt; zugleich fehlen in zwei der Listen Verweise, die der Text tatsaechlich fuehrt. |
| M-07 | Methodik-Repository | r3coscrum: methodik/entscheide.md | Die Herkunftsangabe gilt pauschal fuer alle Eintraege, obwohl sieben Eintraege nicht aus Abschnitt 8 des Projektauftrags stammen, sondern aus spaeteren Arbeitseinheiten. |
| S-03 | CLAUDE.md, Regeln, Eingangskanal | .claude/settings.json | Der Matcher laesst den dokumentierten Ausloesewert fork aus; in einer abgezweigten Sitzung laeuft der Eingangskanal aus dem Methodik-Repository nicht, ohne dass das sichtbar wird. |
| S-04 | CLAUDE.md, Regeln, Eingangskanal | docs/EINGANG_METHODIK.md | Die Eintragsvorlage nennt Feldnamen und eine Verweisform, die der erzeugende Arbeitsablauf nicht schreibt und die seine eigene Fortsetzungslogik nicht wiedererkennt; sie widerspricht ausserdem der Fliesstext-Vorgabe zwei Absaetze darueber in derselben Datei. |
| S-05 | CLAUDE.md, Regeln, Eingangskanal | .claude/rules/produktionscode.md | Die Regel laedt fuer die vorhandene Wurzeldatei Makefile, enthaelt aber keine einzige Aussage, die auf sie zutrifft, und ihr Eroeffnungssatz passt nicht auf sie; die Festlegungen, die den Makefile tatsaechlich binden, stehen in ADR 0002 Abschnitt 6 und in docs/06 und werden ueber keinen paths:-Eintrag geladen. |
| BER-09 | Bereitschaft für das Grundgerüst | docs/adr/0002-architekturentscheid-ziel-stack.md | Der Dateibaum, gegen den das Grundgeruest gebaut wird, zaehlt den Bestand von .claude/ auf und fuehrt skills/ nicht, obwohl dort seit dem 2026-08-31 zwei Skills liegen. |
| BER-10 | Bereitschaft für das Grundgerüst | docs/adr/0002-architekturentscheid-ziel-stack.md | Der Dateibaum fuehrt fuenf Skripte unter scripts/ und nennt weder belege-pruefen.sh noch belege-ausnahmen.txt, obwohl beide bestehen und seit dem 2026-09-01 Pruefmittel des ersten Kettenschritts D20 sind. |
| BER-11 | Bereitschaft für das Grundgerüst | docs/adr/0002-architekturentscheid-ziel-stack.md | Die Zeile fuehrt eine Nachfuehrung als offen und behauptet als Tatsache, keiner der Eintraege stehe in .gitignore, obwohl sie im selben Commit ausgefuehrt wurde; andere Zeilen derselben Tabelle tragen fuer diesen Fall den Vermerk "bereits umgesetzt, hiermit gedeckt". |
| BER-12 | Bereitschaft für das Grundgerüst | docs/05_Product_Backlog.md | Die beiden offenen Punkte zaehlen die Eintraege ohne benannten Stakeholder auf und lassen die Randbedingungen R3-C-003, R3-C-004 und R3-C-005 der Etappe 0 aus, die ebenfalls keinen Stakeholder benennen und damit R1 der Definition of Ready gleichermassen nicht erfuellen. |
| BER-13 | Bereitschaft für das Grundgerüst | docs/adr/0001-rollenmodell.md | Der ADR erklaert eine Umgebungsvariable fuer verbindlich, die in der am 2026-09-02 gelesenen Hook-Dokumentation nicht vorkommt. |
| SK-05 | Skill-Bedarf | .claude/skills/pruefbefund-melden/SKILL.md | Das als fuer alle drei Pruefrollen gleich erklaerte Pflichtfeld verlangt eine Zeilenangabe, die die Rollendatei des Pentesters weder fuehrt noch bei ihrem Pruefgegenstand — der laufenden Anwendung — hergibt. |
| SK-06 | Skill-Bedarf | .claude/skills/pruefbefund-melden/references/befundfelder.md | Das mitgelieferte Musterbeispiel erfuellt das Pflichtfeld nicht, das die zugehoerige SKILL.md aufstellt: Es nennt statt einer Zeile einen Abschnitt. |
| P-07 | Prototyp (5.6) | prototype/OSINT_Plattform_Demo.html | Es gibt keinen Generator mit festem Startwert; der erzeugte Datenbestand liegt fest verdrahtet in der versionierten Datei — also genau umgekehrt zu der Vorgabe, den Generator zu versionieren und den Datenbestand nicht. |
| P-08 | Prototyp (5.6) | prototype/OSINT_Plattform_Demo.html | Die verwendete Domain stammt nicht aus den für Beispiele vorgesehenen Domains; ".tld" ist keine reservierte Beispiel- oder Testendung im Sinne der Regel. |
| P-09 | Prototyp (5.6) | prototype/OSINT_Plattform_Demo.html | Die sechs Ansichten werden über onclick an Elementen ohne href, ohne role und ohne tabindex umgeschaltet; damit ist die Navigation nur mit der Maus bedienbar, nicht mit der Tastatur. |
| P-10 | Prototyp (5.6) | .claude/hooks/block-prototype-import.sh | Von den drei Trennungsanforderungen, die 5.6 im zitierten Satz nennt, prüft das Gate nur die Importe; "ohne gemeinsame Abhängigkeiten" wird von keinem Gate und von keinem Kettenschritt geprüft, und diese Grenze wird an keiner Stelle benannt. |
| FORM-02 | Form, Sprache, Tabellen | Makefile | Die im Makefile-Kopf gefuehrte Definition von Lage C gibt denselben ueberholten Wortlaut wieder wie FORM-01 und nennt nur das fehlende, nicht das vorhandene, aber nicht tragende Pruefmittel. |
| FORM-04 | Form, Sprache, Tabellen | docs/00_Projektauftrag.md | Ein Fliesstextsatz steht ohne Leerzeile zwischen zwei Tabellenzeilen; dadurch endet die Tabelle nach der Zeile L, und die nachfolgende Zeile M wird nicht mehr als Tabellenzeile, sondern als Fliesstext mit sichtbaren Pipe-Zeichen dargestellt. |
| FORM-05 | Form, Sprache, Tabellen | r3coscrum: methodik/scrum-aufbau.md | Die Stelle nennt die Definition-of-Done-Befehlskette als "D1 bis D12"; die Kette umfasst seit dem 2026-08-30 zusaetzlich D18 und die Rahmenpruefung D19, seit dem 2026-09-01 zusaetzlich D20 als ersten Schritt. |
| FORM-06 | Form, Sprache, Tabellen | docs/adr/0002-architekturentscheid-ziel-stack.md | Die Kopfzeile behauptet, die elfte Fortschreibung beruehre zusaetzlich Abschnitt 9; Abschnitt 9 enthaelt zu dieser Fortschreibung keinen Eintrag — die Nachfuehrungstabelle springt von der zehnten zur zwoelften Fortschreibung. |
| FORM-07 | Form, Sprache, Tabellen | docs/00_Projektauftrag.md | Der Einleitungssatz nennt zehn von elf Punkten als erledigt; der Abschlussabsatz desselben Abschnitts zaehlt elf erledigte Punkte auf. |

### 5.4 Widerlegte Befunde

Jeder dieser Befunde ist vom Widerleger am Original geprüft und als nicht tragend beurteilt worden; der Grund steht verkürzt. Zwei davon (BER-01, BER-02) beurteilt der Koordinator abweichend, siehe 5.5.

| Kennung | Dimension | Datei | Behauptung | Grund der Widerlegung |
|---|---|---|---|---|
| P-01 | Auftrag, Backlog, Planung | docs/05_Product_Backlog.md | Die beiden offenen Punkte, die die R1-Luecke der Definition of Ready festhalten, erfassen nur 10 von 81 Eintraegen ohne benannten Stakeholder; in Etappe 0 fehlen sechs, in Etappe 1 zweiundzwanzig Eintraege in der Aufzaeh | Die Zitate aus OP 12/15 stehen wörtlich so im Dokument, und die genannten Befehle liefern tatsächlich die genannten Zahlen (grep -c "S-[0-9][0-9]" -> 10, grep -c "**Stakeholder:**" -> 1, Etappe 0 = 11, Etappe 1 = 30 Überschriften, selbst geprüft). Die daraus gezogene Schlussfolgerung trägt aber nicht: R1 verlangt nur, dass der S |
| P-02 | Auftrag, Backlog, Planung | docs/adr/0002-architekturentscheid-ziel-stack.md | Die Tabelle der offenen Punkte ist durch acht Leerzeilen zwischen den Zeilen unterbrochen; ab O-11 endet die Tabelle nach Markdown-Regel und zwoelf Zeilen erscheinen als Fliesstext statt als Tabellenzeilen. | Der zitierte Befehl awk 'NR>=2985 && NR<=3022 ...' wurde selbst ausgeführt und liefert tatsächlich das behauptete Leerzeilen-Muster — aber an dieser Stelle (Zeilen 2985-3022) steht nicht die Tabelle der offenen Punkte aus Abschnitt 8, sondern ein Fliesstext in der elften Fortschreibung ("Zwei Berichtigungen an dieser Datei"), de |
| P-16 | Auftrag, Backlog, Planung | docs/00_Projektauftrag.md | Der offene Punkt zur Einstufung nach dem EU AI Act ist in keiner Offene-Punkte-Liste terminiert und in keinem Abnahmekriterium genannt. | Zitat 4.4, Zeile 124 gelesen: '[OFFEN] EU AI Act: Einstufung von Systemen im Bereich Strafverfolgung ist zu pruefen, nicht anzunehmen.' — Zitat stimmt. Ausgefuehrt: grep -n "^### 4\." docs/00_Projektauftrag.md zeigt 4.4 als 'Rechtliche Rollen — Praezisierung' unter Abschnitt 4, nicht 5 oder 6. Ausgefuehrt: grep -n "R3-C-013" -A6 |
| P-17 | Auftrag, Backlog, Planung | docs/00_Projektauftrag.md | Der offene Punkt zur Anwendbarkeit der DSGVO ist ebenfalls in keiner Offene-Punkte-Liste terminiert und in keinem Abnahmekriterium genannt. | Zitat 4.4, Zeile 122 gelesen: '- DSGVO, soweit Personen in der EU betroffen sind. [OFFEN] Anwendbarkeit ist zu klaeren, nicht zu unterstellen.' — Zitat stimmt. Ausgefuehrt: grep -n "DSGVO" docs/05_Product_Backlog.md docs/06_Definition_of_Ready_und_Done.md docs/07_Roadmap.md docs/adr/0001-rollenmodell.md docs/adr/0002-architektur |
| P-01 | ADR 0002, Makefile, Definition of Done | docs/adr/0002-architekturentscheid-ziel-stack.md | Die Tabelle der offenen Punkte ist durch Leerzeilen in neun Bloecke zerschnitten; nur der erste Block traegt Kopf- und Trennzeile, die uebrigen acht rendern nicht als Tabelle. | Die aktuelle Tabelle in Abschnitt 8 (Zeilen 3217-3243, Kopf- und Trennzeile 3219-3220) ist durchgehend ohne Leerzeilen -- eigene Ausfuehrung: awk 'NR>=3217 && NR<=3243 {if ($0=="") print NR}' docs/adr/0002-architekturentscheid-ziel-stack.md liefert keine Ausgabe (rc 0). Die vom Befund zitierten Zeilennummern 2987-3019 liegen aus |
| P-14 | ADR 0002, Makefile, Definition of Done | Makefile | Erreicht D7 die Lage A, werden die gefundenen Backlog-Dateien weder genannt noch an das Pruefmittel uebergeben; die Objekttabelle verlangt die Nennung in der Lage-Meldung. | Zitat aus ADR 0002 bestaetigt (docs/adr/0002-architekturentscheid-ziel-stack.md, Zeile 566, Zeile 'D7, zweiter Teil'): 'Treffen mehrere Dateien zu, werden alle beurteilt und in der Lage-Meldung genannt' steht dort woertlich in der Spalte Erkennungsmerkmal. Der Codebeleg trifft ebenfalls zu: im elif-Zweig des Ziels abnahme (Makef |
| ST-13 | Hooks, Skripte, Arbeitsabläufe (Code) | .claude/hooks/block-main-write.sh | Laesst sich die Eingabe auf stdin nicht als JSON lesen, bleiben alle abgeleiteten Werte leer und beide Gates enden mit 0; ein nicht lesbares Pruefmittel laesst still durch, statt zu blockieren. | Zitat und operativer Befund sind echt: selbst ausgefuehrt (CLAUDE_PROJECT_DIR=/home/user/r3cosint, jq vorhanden unter /usr/bin/jq) -- printf '' / bash .claude/hooks/block-main-write.sh -> rc=0; printf 'kein json' / ... -> rc=0 (jq meldet 'parse error' auf stderr, wird aber nicht ausgewertet); printf '{"tool_name":"Bash","tool_in |
| R-05 | Rollen, Skills, ADR 0001 | .claude/agents/static-software-tester.md | Fuer den Testcode des Dynamic Software Testers bleibt keine Rolle uebrig, die ihn auf einem anderen Modell prueft: Erzeuger und einziger in Frage kommender Pruefer laufen beide auf opus, und die Ausnahme nimmt den Gegens | Zitat aus static-software-tester.md Zeile 42 stimmt wörtlich, und beide Rollen laufen tatsächlich auf opus (Frontmatter beider Dateien geprüft). Die Lücke ist aber keine verdeckte oder widersprüchliche Stelle: ADR 0001 Abschnitt 2.3 ('Die Kehrseite ist in der Rollendatei des Static Software Testers festgehalten...') benennt exak |
| R-07 | Rollen, Skills, ADR 0001 | .claude/agents/protocol-master.md | Die Rolle soll docs/NACHWEISE.md erzeugen, kann das aber nach ihrer eigenen Datei nicht: sie fuehrt keine Befehle aus, und die Datei wird maschinell erzeugt und ueberschreibt jede Handaenderung. | Zitate an den genannten Stellen treffen zu (geprüft: Zeile 12, 25, 33 von .claude/agents/protocol-master.md; docs/NACHWEISE.md-Kopf; grep -n "nachweise-erzeugen/NACHWEISE" .github/workflows/*.yml, Rückgabewert 0). Der behauptete Widerspruch trägt aber nicht. docs/00_Projektauftrag.md, Zeile 978: "Zuständigkeit: Protocol Master ( |
| R-09 | Rollen, Skills, ADR 0001 | .claude/skills/dod-kette-belegen/SKILL.md | Die drei Bedingungen fuer einen gruenen Lauf nennen die Lauf-Kennung nicht, obwohl erst sie eine Marke dieses Laufs von einer fremden oder aelteren unterscheidbar macht. | Zitate treffen zu (SKILL.md Zeile 55–61 geprüft; Makefile Zeile 1649 und 633 selbst gelesen). Der behauptete Widerspruch entsteht aber nicht: Ein Lage-Marker ohne die Lauf-Kennung dieses Aufrufs matcht die Prüf-Regex im Makefile (Zeile ~1640ff., ^::LAGE\ $lauf_kennung\ ...) gar nicht — marke_ok bleibt 0, und das Makefile meldet  |
| R-13 | Rollen, Skills, ADR 0001 | .claude/agents/frontend-engineer.md | Dieselbe fuenfgliedrige Aufzaehlung tritt an die Stelle der heute festgelegten Kette; der Einstieg make dod und die Schritte D7 bis D12, D18 und D20 fehlen. | Zitat und Fundstelle stimmen: Zeile 31 von frontend-engineer.md lautet wortwörtlich "Befehlskette mit Rückgabewert 0: Build, Linter, Typprüfung, Testsuite, Abdeckungsschwelle (3.4)." als dritter Punkt unter "Erwartete Ausgabeform". Das allein trägt den Befund aber nicht: Dieselbe wörtliche Formulierung steht unverändert auch bei |
| R-14 | Rollen, Skills, ADR 0001 | .claude/agents/dynamic-software-tester.md | Die Kette ist auf zwei Glieder verkuerzt; die Rolle, der der Skill dod-kette-belegen vorgeladen ist, beschreibt die Definition of Done damit enger als jede andere Fundstelle. | Zitat und Fundstelle stimmen: Zeile 19 von dynamic-software-tester.md lautet wortwörtlich "Definition of Done als ausführbare Befehlskette: Testsuite grün, Testabdeckung über dem vereinbarten Schwellenwert (3.4)." als zweiter Punkt unter "Arbeitsgrundlage". Der Befund deutet dies als vollständige, aber zu enge Definition der pro |
| NF-011 | Nachweisfluss und Automatik | scripts/nachweise-erzeugen.sh | Die Artefaktliste fuehrt die SKILL.md, nicht aber die zu ihr gehoerende Referenzdatei references/befundfelder.md, obwohl die SKILL.md die Feldmenge je Rolle ausdruecklich dorthin auslagert. | Zitat verifiziert (SKILL.md Zeile 61-62: 'Je Rolle kommen Felder hinzu; die Aufstellung steht in references/befundfelder.md.'). Verifiziert per find: die Referenzdatei existiert und fehlt in der ARTEFAKTE-Liste (per Python-Abgleich gegen git ls-files bestätigt). Der Befund unterstellt jedoch eine übersehene Lücke aus der 'Binnen |
| M-08 | Methodik-Repository | r3coscrum: methodik/scrum-aufbau.md | Der offene Punkt fragt, ob Product Owner und Scrum Master Mensch oder Claude-Code-Rolle sind; ADR 0001 beantwortet das seit dem 2026-08-31, und der Scrum Master hat als Rolle bereits gehandelt. | Zitat bestätigt (r3coscrum/methodik/scrum-aufbau.md, Zeile 122-124): '[OFFEN] Die personelle Besetzung von Product Owner und Scrum Master (Mensch oder Claude-Code-Rolle, und wer konkret) ist im Projektauftrag nicht ausgewiesen.' Der Befund räumt selbst ein, dass diese wörtliche Aussage weiterhin richtig ist. Gelesen in r3cosint/ |
| BER-01 | Bereitschaft für das Grundgerüst | docs/05_Product_Backlog.md | Das Grundgeruest, das nach CLAUDE.md das naechste Arbeitsergebnis ist, hat keine Anforderungskennung, kein Abnahmekriterium und keinen geschaetzten Pruefaufwand; der einzige Eintrag, der es nennt, ist R3-C-001, und desse | Zitate und Zaehlungen sind korrekt (R3-C-001-Text, ADR-Kopf, 11 Ueberschriften in Etappe 0, Zeile '0 — Vorlauf / 10 / 32 h' -- alle selbst nachgeprueft, deckungsgleich). Der Schluss traegt aber nicht: R3-C-001s Formulierung bezieht sich ausdruecklich auf Architekturentscheid UND Grundgeruest 'als Architecture Decision Record', a |
| BER-02 | Bereitschaft für das Grundgerüst | docs/06_Definition_of_Ready_und_Done.md | ADR 0002 terminiert zwei offene Punkte auf "vor der Freigabe des Grundgeruests", aber ein Freigabe-Gate fuer das Grundgeruest ist in der Definition of Ready und Done nicht gefuehrt; wer freigibt, wogegen und in welcher F | Das Zitat ('Zwei Reihenfolge-Gates', Tabelle mit genau zwei Zeilen) stimmt, ebenso die Fundstellen O-15 und O-22 mit 'vor der Freigabe des Grundgeruests' / 'spaetestens vor der Freigabe des Grundgeruests' (selbst in Abschnitt 8 gelesen und per grep 'Freigabe des Grundgeruests' bestaetigt: nur diese beiden offenen Punkte referenz |
| BER-05 | Bereitschaft für das Grundgerüst | CLAUDE.md | Die verbindliche Lieferreihenfolge nennt vor dem Grundgeruest die Einheiten E4 und E3, deren Umfang in keinem Dokument des Repositories festgelegt ist; die Quelle des Plans, der Deep Review vom 2026-08-25, liegt nicht im | Die Einzelzitate stimmen (CLAUDE.md-Zeile, 'E4 (main-Gate) rueckt nach hinten' aus Zeile 102, 'die in E3 entsteht' aus Zeile 113 von docs/uebergaben/2026-08-25_eingangskanal-repariert.md, sowie das Fehlen von .claude/rules/fremde-inhalte-im-harness.md unter .claude/rules). Der als Beleg angefuehrte Befehl traegt aber selbst nich |
| BER-08 | Bereitschaft für das Grundgerüst | docs/07_Roadmap.md | Die Roadmap macht Etappe 1 von Etappe 0 abhaengig, obwohl drei Eintraege der Etappe 0 einen laufenden Programmstand voraussetzen, den erst das Grundgeruest und Etappe 1 herstellen; das Grundgeruest selbst ist in keiner E | Zitate sind textlich korrekt (Roadmap-Zeile zu Etappe 1 exakt geprüft; R3-C-003/004/005-Abnahmezitate exakt geprüft; ADR-0002-Zeile 'rueckkanal-pruefen.sh folgt mit R3-C-004' exakt geprüft; Makefile-Kommentarzeile zu D9 exakt geprüft: 'D9 rueckkanal Lage B — weder backend/ noch frontend/ noch deploy/ enthaelt eine Datei'). Die d |
| SK-01 | Skill-Bedarf | .claude/rules/claude-konfiguration.md | Die Regel behauptet die Wirkung des Vorladens als Tatsache, waehrend ADR 0001 Abschnitt 5.1 dieselbe Wirkung ausdruecklich als nicht belegt fuehrt und einen negativen Kontrollversuch protokolliert. | Das Zitat aus .claude/rules/claude-konfiguration.md, Abschnitt "Vorladen je Rolle", steht wörtlich so im Original (geprüft). Es besteht aber kein Widerspruch zu ADR 0001, Abschnitt 5.1. Der Regel-Satz beschreibt den dokumentierten Mechanismus des skills:-Felds – exakt dieselbe Aussage, die ADR 0001 selbst im Nachtrag zu Abschnit |
| SK-03 | Skill-Bedarf | .claude/skills/dod-kette-belegen/SKILL.md | Der Skill erklaert seinen Geltungsbereich auf jede Rolle, waehrend ADR 0001 Abschnitt 5.1 ihn genau acht Rollen zuordnet und diese Zuordnung damit begruendet, dass nur diese acht Arbeitseinheiten als fertig melden. | Beide Zitate stehen wörtlich im Original (geprüft: Zeile 22 in .claude/skills/dod-kette-belegen/SKILL.md, Tabellenzeile in ADR 0001 Abschnitt 5.1). Ein tragender Widerspruch ist damit aber nicht belegt. Die ADR-Tabellenzeile erklärt, weshalb das skills:-Feld – ein reines Vorlade-/Kontext-Feld – bei genau acht Rollen gesetzt ist, |
| P-02 | Prototyp (5.6) | docs/adr/0002-architekturentscheid-ziel-stack.md | Der ADR weist die maschinelle Barrierefreiheitsprüfung von R3-F-050 einem Prüfweg zu, der nach demselben ADR erst nach der Freigabe von R3-F-050 entstehen darf; damit benennt er für das Abnahmekriterium von R3-F-050 kein | Die Zitate stimmen: Zeile 342 nennt für R3-F-050 den Prüfweg "axe-Prüfung innerhalb der Playwright-Läufe", Zeile 474/491 datieren frontend/ auf die Zeit nach der Prototyp-Freigabe. Der behauptete Widerspruch entsteht aber erst durch eine Gleichsetzung, die der Text nicht herstellt: Dass "Playwright-Läufe" zwingend innerhalb des  |
| P-03 | Prototyp (5.6) | docs/05_Product_Backlog.md | Das Abnahmekriterium übernimmt zwei der drei verbindlichen Regeln zu synthetischen Daten aus 5.6 (Generator mit festem Startwert, keine realen Daten), lässt die dritte — den dauerhaft sichtbaren Hinweis in der Oberfläche | Der zitierte Backlog-Satz und die Gegenprobe (sed -n '425p' / grep -c -i -E "Demonstrationszweck/dauerhaft sichtbar" → 0, rc=1) sind korrekt. Der behauptete Regelverstoss trägt aber nicht: Der Projektauftrag selbst (docs/00_Projektauftrag.md, Zeile 491, Abschnitt 5.6) definiert "Maschinell prüfbar" für den Prototyp abschliessend |
| P-05 | Prototyp (5.6) | .claude/rules/prototyp.md | Die pfadgebundene Regel für prototype/** gibt die Verbindlichkeit der Demo wieder, ohne die beiden Fälle zu nennen, die 5.6 ausdrücklich von dieser Verbindlichkeit ausnimmt — den Umschalter zwischen lokalem Modell und Cl | Die Zitate und Gegenproben sind korrekt: .claude/rules/prototyp.md nennt nur die Gesichtsvergleich-Ausnahme, grep -q -E 'Umschalter/Aufbewahrungsklassen/...' .claude/rules/prototyp.md liefert rc=1, und die Demo enthält tatsächlich setLLM('local')/setLLM('cloud') (Zeilen 583/586/664) sowie ret:'A'/ret:'B'/Aufbewahrung (Zeilen 270 |
| P-06 | Prototyp (5.6) | .claude/rules/prototyp.md | Die Regeldatei führt die Sonderregelung für die Ansicht "Gesichtsvergleich" (5.18), nicht aber die gleichlautende Sonderregelung für den VirusTotal-Eintrag im Werkzeugkatalog der Demo, obwohl der Projektauftrag beide in  | Zitate und Gegenproben treffen zu (grep -q -i 'virustotal' .claude/rules/prototyp.md → rc=1; grep -n -i virustotal prototype/OSINT_Plattform_Demo.html → Zeile 348 vorhanden; Projektauftrag Zeile 815/817 wie zitiert). Dieselbe Erwägung wie bei P-05 trägt aber auch hier: .claude/rules/prototyp.md beansprucht keine Vollständigkeit  |
| FORM-08 | Form, Sprache, Tabellen | .claude/rules/prototyp.md | Die Anweisung nennt weder die Nummernbereiche noch die Beispiel-Domains und ist damit nicht ueberpruefbar formuliert, obwohl der Abschnitt als verbindlich ueberschrieben ist. | Das Zitat aus /home/user/r3cosint/.claude/rules/prototyp.md, Zeile 41 f., steht dort wörtlich (grep -n bestätigt, Rückgabewert 0). Der Befund übersieht jedoch, dass diese Formulierung keine eigenständige, unpräzise Erfindung von prototyp.md ist, sondern eine wörtliche Übernahme aus der übergeordneten Quelle selbst: docs/00_Proje |


### 5.5 Nachprüfung durch den Koordinator

Selbst am Bestand nachgestellt, jeweils lesend und ohne Änderung am
Arbeitsbaum, alle am 2026-09-02:

- ST-01 und ST-02: Aufruf von `.claude/hooks/block-main-write.sh` mit der
  JSON-Eingabe des Werkzeugs `Bash`. `git push origin main` → Rückgabewert 2;
  `git push origin 'main'`, `git push origin "main"`, `git push origin main;`,
  `(git push origin main)`, `git worktree add "/tmp/wt" "main"` → je 0.
- ST-03: gelesen, Zeile 35 des Skripts endet bei fehlendem Arbeitsbaum oder
  fehlendem `git` still mit 0; die `jq`-Wache darüber endet mit 2.
- ST-04 und ST-05: Aufruf von `.claude/hooks/block-prototype-import.sh`;
  `import h from "../prototype/helper";` → 2, `import h from "../prototype";`
  → 0; `import a from "../backend/api";` → 2, `import a from "./../backend/api";`
  → 0.
- ST-07: Zeile 15 von `scripts/nachweise-erzeugen.sh` gelesen
  (`${1:-docs/NACHWEISE.md}`); nicht ausgeführt, weil der Lauf die
  versionierte Datei änderte.
- ST-08, NF-002, R-06: der `paths`-Filter in
  `.github/workflows/nachweise-uebertragen.yml` nennt `docs/**`,
  `.claude/**`, `prototype/**`, `CLAUDE.md`, `.github/workflows/**`,
  `scripts/**`; das `Makefile` steht in der Artefaktliste des Erzeugers.
- NF-001 und BER-06: Kopf von `docs/NACHWEISE.md` (Stand `edd895b9…`, 48
  Artefakte); Artefaktliste des Erzeugers: 55 Zeilen.
- NF-005: `session-start-eingang.sh` ausgeführt, 9008 Zeichen Ausgabe;
  `max_zeichen=20000` im Skript; Kappung der Referenz bei 10 000 Zeichen.
- ADR P-03: Ziel `geheimnisse` setzt `hat_objekt=1` fest; Objekttabelle
  nennt für D11 das Merkmal ".git/ vorhanden" und eine Lage B.
- Backlog P-04, P-08: offener Punkt 3 gegen E-03 in
  `docs/08_Freigabe_Schritt_4.md`; "Aufbewahrungsklasse" in R3-F-001 gegen
  Projektauftrag 4.4.
- R-03, R-05, SK-02: ADR 0001, Abschnitt 5.1, Zeile 156 "Offene Prüfung,
  terminiert"; `model: opus` bei beiden Testerrollen.
- Prototyp P-04: `grep -c -i -E 'Demonstrationszweck|synthetisch'` auf die
  Demo-Datei → 0.
- FORM-04: Projektauftrag, Zeilen 1079 bis 1081, Fliesstextsatz zwischen den
  Tabellenzeilen L und M.
- S-01: `README.md`, Zeilen 32 und 33.
- O-12 (vierfach gefunden): `grep -c '^| O-12'` auf ADR 0002 → 0.
- Umgebung: `docker info` → Rückgabewert 1; `command -v gitleaks` → 1;
  `git tag | wc -l` → 0; `sprints/` im Methodik-Repository enthält nur
  `.gitkeep`.

Ein weiterer Befund des Koordinators, beim Ablegen dieses Berichts gemessen (K-01, erheblich): Der Belegprüfer grenzt seine Prüffläche über die Versionsverwaltung ab und liest deshalb **nur versionierte Dateien**. Eine neu angelegte, noch nicht dem Index hinzugefügte Datei wird von D20 nicht geprüft; `make dod` vor dem ersten `git add` ist für sie blind. Belegt: Die Übergabedatei vom 2026-09-02 lief vor ihrem Commit mit 0 Befunden durch und meldete unmittelbar nach dem Commit zwei Funde (Kurzform docs/06 in Rückwärtsakzenten, Abschnittsangabe ohne Nennung des ADR); beide sind in diesem Commit behoben. Dasselbe gilt für diesen Bericht, der erst nach `git add` geprüft wurde. Vorschlag: `git ls-files --others --exclude-standard` in die Prüffläche von D20 aufnehmen, oder die Grenze im Kopf des Skripts und in `docs/06_Definition_of_Ready_und_Done.md` benennen. Zuständig: DevOps Engineer (Makefile), Abnahme des Werkzeugs O-15.

Abweichende Beurteilung des Koordinators zu drei widerlegten Befunden: BER-01
(kein Backlog-Eintrag für das Grundgerüst), BER-02 (kein definiertes
Freigabe-Gate für das Grundgerüst) und BER-05 (Umfang von E4 und E3 nirgends
festgelegt) sind vom Widerleger zu Recht nicht als Regelverstoss bestätigt
worden; die zugrunde liegenden Tatsachen sind gemessen und bleiben für die
Planung des Grundgerüsts massgeblich (Abschnitt 6.5). P-06 derselben
Sache (Auftrag, Backlog, Planung) ist bestätigt. R-05 (beide Tester auf
demselben Modell, Testcode ohne Gegenprüfung) ist widerlegt, weil ADR 0001
die Lücke selbst benennt; die Lücke besteht und wird mit dem ersten Testcode
wirksam.

### 5.6 Negativbefunde

Je Dimension die Zahl der geprüften und in Ordnung befundenen Punkte, dazu
eine Auswahl; die vollständigen Listen stehen in den Prüfprotokollen.

**Auftrag, Backlog, Planung** (16 Negativbefunde, 8 nicht geprüfte Punkte):
- Summentabelle des Backlogs: Eintragszahlen und Pruefaufwand je Etappe stimmen exakt mit dem Dateiinhalt. Nachgerechnet mit einem python3-Skript ueber alle **Pruefaufwand:**-Zeilen, rc=0: Etappe 0 32 h (10 geschaetzte von 11 Eintraegen), Etappe 1 147 h (29 von 30), Etappe 2 37 h/11, Etappe 3 66 h/15, Etappe 4 32 h/7, Etappe 5 8 h
- Die drei nicht geschaetzten Eintraege sind an allen Stellen gleich behandelt: R3-Q-009, R3-F-029 und R3-F-094 tragen "offen (siehe Achtung)" bei Kano und Pruefaufwand, stehen in der Ausnahmezeile der Backlog-Summe und ebenso in der Roadmap ("Nicht in den obigen Summen enthalten").
- Roadmap, Abschnitt "Abgeleitete Sprintzahl": 352/40 = 8,8 -> 9; 352/28 = 12,6 -> 13; 370/40 = 9,25 -> 10; 370/28 = 13,2 -> 14; Wochen 18, 26, 20, 28. Alle vier Sprint- und alle vier Wochenzahlen sind bei Aufrundung auf volle Sprints richtig.
- Roadmap, Etappenfolge-Tabelle: Die Pruefaufwandsspalte (32, 147, 37, 66, 32, 8, 30, 18 h) ist deckungsgleich mit der Backlog-Summentabelle; die Sprintangaben bei 34 h Mittelwert sind rechnerisch stimmig.

**ADR 0002, Makefile, Definition of Done** (19 Negativbefunde, 7 nicht geprüfte Punkte):
- Zielnamen der Befehlsspalte: alle vierzehn in ADR 0002 Abschnitt 6 genannten make-Ziele existieren im Makefile. Beleg: .PHONY-Zeile woertlich "belege bau format-pruefen linter typen architekturvertraege test abdeckung abnahme abhaengigkeiten rueckkanal prototyp-trennung geheimnisse nachweise dod" gegen die Befehlsspalte (make be
- Ausfuehrungsreihenfolge: ADR 0002, Abschnitt 6, "Ein Einstieg fuer den Hook" woertlich "Die Reihenfolge beginnt neu mit **D20**, also D20, D1 bis D4, D18, D5 bis D12". Makefile woertlich: "schritte_liste=\"D20:belege D1:bau D2:format-pruefen D3:linter D4:typen D18:architekturvertraege D5:test D6:abdeckung D7:abnahme D8:abhaengig
- Befehle je Schritt, inhaltlich: D2 (ruff format --check backend), D3 (ruff check backend), D4 (mypy backend/src backend/tests), D5 (pytest -q --strict-markers, npm run test, npm run e2e), D6 (--cov=backend/src/r3cosint --cov-fail-under=80 und zweiter Lauf mit --cov=.../spur, /zugriff, /freigabe --cov-fail-under=100), D7 (pytest 
- D18, Erkennungsmerkmal: ADR "mindestens eine *.py-Datei unterhalb backend/src/"; Makefile woertlich "backend_py_datei=$$(find backend/src -type f -name '*.py' -print -quit 2>/dev/null)". Lage B "keine *.py-Datei unterhalb backend/src/ vorhanden" und Lage C bei fehlender oder nicht lesbarer backend/importvertraege.toml sind beide

**Hooks, Skripte, Arbeitsabläufe (Code)** (20 Negativbefunde, 10 nicht geprüfte Punkte):
- Syntax aller fuenf Shell-Dateien in Ordnung: bash -n je Datei -> rc=0 fuer .claude/hooks/block-main-write.sh, .claude/hooks/block-prototype-import.sh, .claude/hooks/session-start-eingang.sh, scripts/belege-pruefen.sh, scripts/nachweise-erzeugen.sh.
- Rueckgabewert-Disziplin der drei Hooks: grep -n 'exit [0-9]' .claude/hooks/*.sh zeigt ausschliesslich exit 0 und exit 2; kein einziges exit 1 an einer Stelle, die blockieren soll. Der SessionStart-Hook verwendet ueberhaupt nur exit 0, im Einklang mit der Hook-Referenz (/tmp/.../scratchpad/hooks.md): "For SessionStart, SubagentSt
- jq-Wache beider PreToolUse-Gates wirkt: PATH auf ein Verzeichnis ohne jq gesetzt (bash, cat, git, grep, sed, printf, od, tr, awk vorhanden), Eingabe tool_name=Bash / command="git commit": block-main-write.sh -> rc=2 mit "Gate main-schutz: jq ist nicht installiert; das Gate kann nicht pruefen."; block-prototype-import.sh -> rc=2 
- Kernfaelle des main-Gates blockieren: Projektbaum auf main (Wegwerf-Klon), je rc=2 fuer command="git commit -m x", command="echo hallo > datei.txt", command="cat datei / tee neu.txt", command='awk "BEGIN{print > \"x\"}" /dev/null', command="python3 -c ...", command="git rebase origin/main"; tool_name=Write mit file_path im Proje

**Rollen, Skills, ADR 0001** (20 Negativbefunde, 6 nicht geprüfte Punkte):
- Frontmatter gegen ADR 0001, Abschnitt 3: model, maxTurns und tools stimmen bei allen 21 Rollen wortgleich mit der Rollentabelle ueberein. Ausgefuehrt mit einem python3-Abgleich, der die 21 Tabellenzeilen aus docs/adr/0001-rollenmodell.md gegen das Frontmatter der 21 Dateien stellt (Rueckgabewert 0): "ADR-Tabellenzeilen: 21 / Abw
- R3-Q-007, erstes Abnahmekriterium (R3-Q-007_frontmatter_vollstaendig): In allen 21 Rollendateien sind name, description, tools, model und maxTurns gesetzt, und name stimmt mit dem Dateinamen ueberein. Ausgefuehrt mit python3 (Rueckgabewert 0): "Dateien: 21 / Fehlende Felder gesamt: 0 / name != Dateiname: []".
- R3-C-007 sachlich: Beide Skills unter .claude/skills/ werden vorgeladen, und kein skills:-Eintrag zeigt auf eine nicht vorhandene Skill. Ausgefuehrt mit python3 (Rueckgabewert 0): "skills verwendet: {'dod-kette-belegen', 'pruefbefund-melden'} vorhanden: {'dod-kette-belegen', 'pruefbefund-melden'} / Eintrag ohne Skill: set() / Sk
- Die Zuordnung der Skills entspricht Zeile fuer Zeile der Tabelle in ADR 0001, Abschnitt 5.1: pruefbefund-melden bei Static Software Tester, Dynamic Software Tester und Pentester; dod-kette-belegen bei Static und Dynamic Software Tester, Full-Stack, Backend, Frontend, DevOps, SecDevOps und Docker-/Kubernetes-Experte. Neun Rollen 

**Nachweisfluss und Automatik** (17 Negativbefunde, 7 nicht geprüfte Punkte):
- Commit-Identitaet: alle drei Arbeitsablaeufe setzen die vorgeschriebene Adresse. Ausgefuehrt: Lesen von nachweise-uebertragen.yml Zeile 253, meilenstein-tag.yml Zeile 160 und eingang.yml Zeile 218 -> jeweils "git config user.email \"41898282+github-actions[bot]@users.noreply.github.com\"". Die Namen r3cosint-nachweise[bot], r3co
- Gepinnte Aktionen: alle vier uses:-Stellen in beiden Repositories verwenden dieselbe 40-stellige Pruefsumme. Ausgefuehrt: grep -rn "uses:" .github/workflows/ -> drei Treffer in r3cosint, ein Treffer in r3coscrum, jeweils "actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1 # v7.0.1"; echo -n "3d3c42e5aac5ba805825da76410c18
- Schreibbereich in Repo B: der Arbeitsablauf legt ausschliesslich unterhalb von nachweise/ ab und fuegt auch nur dieses Verzeichnis dem Index hinzu. Zitat nachweise-uebertragen.yml, Zeilen 204-205 und 254: "mkdir -p \"repo-b/${ZIEL_VERZEICHNIS}\" / cp docs/NACHWEISE.md \"repo-b/${ZIEL_VERZEICHNIS}/NACHWEISE.md\"" und "git add \"$
- Der Stand in Repo B ist aktuell und stimmt mit dem Erzeuger ueberein. Ausgefuehrt: bash scripts/nachweise-erzeugen.sh <Wegwerfdatei> -> "55 Artefakte", RC=0; cmp <Wegwerfdatei> /home/user/r3coscrum/nachweise/NACHWEISE.md -> RC=0 (byteweise identisch). Die Stand-Zeile in r3coscrum/nachweise/NACHWEISE.md nennt 405ebada79a145ac537d

**Methodik-Repository** (19 Negativbefunde, 7 nicht geprüfte Punkte):
- Sprachregel, maschinell geprueft: Ueber alle Dateien des Repositories ausser .git findet ein python3-Lauf (nicht grep) kein Eszett und kein typografisches Anfuehrungszeichen aus der Menge U+201C, U+201D, U+201E, U+2018, U+2019, U+201A, U+00AB, U+00BB. Ergebnis: TOTAL 0, Rueckgabewert 0.
- Verweisintegritaet, vollstaendig geprueft: Alle 74 eindeutigen Verweise der Form github.com/valITino/{r3cosint/r3coscrum}/{blob/tree/commit}/<40 Stellen> loesen auf — Commit vorhanden (git cat-file -e <hash>^{commit}, rc 0) und, wo ein Pfad angegeben ist, Pfad im Commit vorhanden (git cat-file -e <hash>:<pfad>, rc 0). Kein einzi
- Keine Zweigverweise: eine Textsuche nach den beiden verbotenen Zweigformen liefert vier Treffer, alle vier Zitate der Regel selbst (CLAUDE.md:13, CONTRIBUTING.md:32, .github/pull_request_template.md:14, methodik/entscheide.md:51 in der Begruendung von S6). Kein tatsaechlicher Verweis auf einen Zweig.
- Drei nicht in r3cosint/r3coscrum aufloesbare Pruefsummen sind zu Recht dort nicht aufloesbar: 3d3c42e5aac5ba805825da76410c181273ba90b1 (actions/checkout v7.0.1, .github/workflows/eingang.yml Zeilen 37 und 49), 11d5960a326750d5838078e36cf38b85af677262 (actions/checkout v4.4.0, UEBERGABE.md Zeile 320, vergangener Stand) und 882ef5

**CLAUDE.md, Regeln, Eingangskanal** (17 Negativbefunde, 8 nicht geprüfte Punkte):
- Groessenvorgabe CLAUDE.md eingehalten. Massstab: .claude/rules/claude-konfiguration.md Zeile 139-141 "CLAUDE.md unter 200 Zeilen" und Projektauftrag 3.2 "Ziel unter 200 Zeilen pro CLAUDE.md". Ausgefuehrt: wc -l CLAUDE.md → "163 CLAUDE.md", Rueckgabewert 0.
- Zahl "21 Rollen" stimmt. Zitat CLAUDE.md Zeile 58: "21 Rollen liegen unter .claude/agents/". Ausgefuehrt: ls .claude/agents/*.md / grep -v gitkeep / wc -l → "21", Rueckgabewert 0. Die sechs Gruppen in CLAUDE.md Zeile 61-70 summieren sich ebenfalls auf 21 (3+3+4+5+5+1), und die 21 Dateinamen decken sich mit der Aufzaehlung "Betro
- Zahl "neun Rollen mit Skill" stimmt. Zitat ADR 0001 Kopfzeile: "das skills:-Feld ist bei neun Rollen gesetzt (R3-C-007 insoweit erfüllt); ... neun Rollen führen Skill in ihrer Werkzeugliste". Ausgefuehrt: grep -l '^skills:' .claude/agents/*.md / wc -l → "9", Rueckgabewert 0; grep -n '^tools:.*Skill' .claude/agents/*.md / wc -l →
- Tabelle "Aktive Gates" ist vollstaendig und trifft zu. .claude/settings.json enthaelt genau zwei PreToolUse-Gruppen (block-prototype-import.sh, block-main-write.sh) und einen SessionStart-Hook (session-start-eingang.sh) — deckungsgleich mit CLAUDE.md Zeile 124-131. Keine weitere Hook-Quelle: grep -ln '^hooks:' .claude/agents/*.m

**Bereitschaft für das Grundgerüst** (12 Negativbefunde, 9 nicht geprüfte Punkte):
- Summentabelle des Backlogs nachgerechnet: python3 Summierung jeder Zeile "Pruefaufwand:** N h" je Etappe (rc=0) ergibt Etappe 0 = 32 h / 10 gezaehlte Eintraege, Etappe 1 = 147 h / 29, Etappe 2 = 37 h / 11, Etappe 3 = 66 h / 15, Etappe 4 = 32 h / 7, Etappe 5 = 8 h / 4, Etappe 6 = 30 h / 6, zweite Fassung = 18 h / 4 — exakt die We
- Sprintzahlen der Roadmap nachgerechnet: 352 h / 40 h = 8,8 -> 9; 352 / 28 = 12,6 -> 13; 370 / 40 = 9,25 -> 10; 370 / 28 = 13,2 -> 14. Die Tabelle "Abgeleitete Sprintzahl" fuehrt genau 9, 13, 10 und 14.
- Die Kapazitaetsangabe stimmt ueber drei Dokumente ueberein: Projektauftrag 6.8 ("Kapazitaet [GEKLAERT]: 7 bis 10 Stunden pro Woche und Person ... 28 bis 40 Personenstunden"), Roadmap ("Kapazitaet Team je Sprint / **28 bis 40 h**") und r3coscrum/methodik/scrum-aufbau.md ("**28 bis 40 Personenstunden je Sprint**").
- Die Nachfuehrung von .gitignore aus ADR 0002, 6.2, ist sachlich vollstaendig: cat .gitignore (rc=0) enthaelt .pytest_cache/, .ruff_cache/, .mypy_cache/, .coverage, .coverage.*, htmlcov/, playwright-report/, test-results/ — alle in 6.2 genannten Gegenstaende. (Nur die Kennzeichnung in Abschnitt 9 fehlt, siehe BER-11.)

**Skill-Bedarf** (9 Negativbefunde, 7 nicht geprüfte Punkte):
- Zahl und Zuordnung der Skills stimmen mit ADR 0001 Abschnitt 5.1 ueberein. Ausgefuehrt: ls .claude/skills/ / wc -l -> 2, Rueckgabewert 0; grep -l "^skills:" .claude/agents/*.md / wc -l -> 9, Rueckgabewert 0; grep -c "^tools:.*Skill" .claude/agents/*.md / grep -v ":0" / wc -l -> 9, Rueckgabewert 0. Der ADR fuehrt neun Rollen mit 
- Die Zuordnung je Skill trifft die im ADR genannten Rollen: pruefbefund-melden bei static-software-tester.md, dynamic-software-tester.md, pentester.md; dod-kette-belegen bei diesen beiden Testern sowie backend-engineer.md, devops-engineer.md, docker-kubernetes-experte.md, frontend-engineer.md, full-stack-engineer.md, secdevops-en
- Die im Skill dod-kette-belegen genannten Einzelziele bestehen. Ausgefuehrt: grep -n "^[a-zA-Z_.-]*:" Makefile -> unter anderem 843:linter:, 1000:test:, 1517:dod:, Rueckgabewert 0. Der Skill nennt "make linter, make test" und make dod als Einstieg; alle drei Ziele stehen zudem in der .PHONY-Zeile 173.
- Die Aussage des Skills pruefbefund-melden zur Trennung von Finder und Bewerter deckt sich mit beiden Rollendateien. .claude/agents/pentester.md Zeile 27: "ohne eigene Risikoeinstufung", Zeile 33: "Bewertet und priorisiert seine eigenen Funde nicht; das liegt beim Vulnerability Manager". .claude/agents/vulnerability-manager.md Ze

**Prototyp (5.6)** (14 Negativbefunde, 7 nicht geprüfte Punkte):
- Sechs Ansichten vorhanden und über die Navigation erreichbar: grep -n "nv('inv')/nv('hist')/nv('exp')/nv('tools')/nv('face')/nv('set')" → rc=0, Treffer in den Zeilen 240, 241, 243, 245, 246, 247. Die Verteilerzeile 444 bildet dieselben sechs Schlüssel auf sechs Ansichtsfunktionen ab: $('wk').innerHTML=({inv:vInv,hist:vHist,exp:v
- Keine externen Verweise: grep -n -E "script src/link /img /<img/fetch\(/XMLHttpRequest/@import/https?:///url\(/WebSocket/EventSource/navigator\.send/new Image/srcset/<iframe/<embed/<object/<video/<audio/<source/integrity=/crossorigin" prototype/OSINT_Plattform_Demo.html → rc=1, keine Ausgabe. Die Datei enthält genau ein <style> 
- Keine E-Mail-Adressen: grep -q -E '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}' → rc=1. Die einzige Fundstelle von "@" ist @keyframes (Zeile 168).
- Keine Telefonnummern: grep -q -E '\+[0-9][0-9 ()/.-]{6,}[0-9]' → rc=1; auch das Muster für Schweizer Inlandschreibweise (0XX XXX XX XX) liefert keinen Treffer.

**Form, Sprache, Tabellen** (20 Negativbefunde, 9 nicht geprüfte Punkte):
- Eszett: keine Verletzung. Ausgefuehrt: python3-Suche ueber alle mit Git versionierten Dateien beider Repositories ausser .git (88 Dateien r3cosint, 18 Dateien r3coscrum; docs/01_Konzept_v1.0.pdf ist nicht UTF-8 und wurde als solches gemeldet) -> TREFFER_GESAMT 4, Rueckgabewert 0. Alle vier Treffer sind die Regel selbst, die das 
- Markdown-Tabellen, Spaltenzahl: keine Abweichung. Ausgefuehrt: python3-Skript ueber alle versionierten .md-Dateien beider Repositories, das Codebloecke ausblendet, Pipe-Zeichen innerhalb von Rueckwaertsakzenten und maskierte Pipe-Zeichen neutralisiert und je Tabelle jede Zeile gegen die Trennzeile zaehlt -> TABELLEN_GEPRUEFT 236
- Durch eine Leerzeile in zwei gleich aufgebaute Tabellen zerfallene Tabellen: keine. Ausgefuehrt: python3-Skript, das aufeinanderfolgende Tabellen mit identischer Kopfzeile sucht, die nur durch Leerzeilen getrennt sind -> keine Ausgabe, Rueckgabewert 0. Die offenen Punkte in ADR 0002, Abschnitt 8, bilden ausgefuehrt belegt eine e
- Markdown-Links auf lokale Dateien und Ankerlinks: keine vorhanden, also nichts kaputt. Ausgefuehrt: python3-Zaehlung ueber alle versionierten .md-Dateien beider Repositories -> MDLINKS_GESAMT 206, LOKAL 0, ANKER 0, Rueckgabewert 0. Alle 206 Links sind absolute URL.

## 6. Was vor dem Grundgerüst stehen muss

Die Reihenfolge ist freigegeben und in `CLAUDE.md` festgehalten: nach der
Freigabe Bau von R3-Q-001, danach E4, E3, dann das Grundgerüst. Die folgende
Liste ist aus den Dokumenten zusammengestellt, nicht aus Vermutung; jede Zeile
nennt den heutigen Stand mit Beleg. "Blockiert" heisst: Nach der
Dokumentenlage darf das Grundgerüst ohne diesen Punkt nicht beginnen oder
nicht als fertig gelten.

### 6.1 Arbeitseinheiten in der freigegebenen Reihenfolge

| Nr. | Punkt | Stand am 2026-09-02 | Wer | Blockiert |
|---|---|---|---|---|
| 1 | Freigabe des Entwurfs von R3-Q-001 (E-A bis E-K, mindestens E-A und E-H schriftlich) | offen; ADR 0002, 6.12: "Entwurf, dem Auftraggeber am 2026-09-02 zur Freigabe vorgelegt, nicht freigegeben" | Auftraggeber | ja |
| 2 | Bau von R3-Q-001: Hook-Skript, Liste der terminierten Lagen, drei Einträge in `.claude/settings.json`, vier Änderungen am `Makefile` (ADR 0002, Abschnitt 9) | nicht gebaut; `.claude/settings.json` enthält weder `Stop` noch `SubagentStop` noch `TaskCompleted` | DevOps Engineer mit SecDevOps Engineer; Verifikation Static und Dynamic Software Tester auf einem anderen Modell (3.4) | ja |
| 3 | Nachführungen nach der Abnahme von R3-Q-001 in `docs/06_Definition_of_Ready_und_Done.md`, `CLAUDE.md`, `.claude/rules/claude-konfiguration.md`, `docs/05_Product_Backlog.md`, `scripts/nachweise-erzeugen.sh`, `docs/adr/0001-rollenmodell.md` und `methodik/entscheide.md` | offen, hängt an 1 und 2 | je Zeile in ADR 0002, Abschnitt 9 | ja |
| 4 | E4, main-Gate | Umfang nur in einem Satz der Übergabe vom 2026-08-25 beschrieben ("E4 (main-Gate) rückt nach hinten"); kein Auftragstext | nicht benannt; Hook-Konfiguration liegt beim SecDevOps Engineer (ADR 0001) | ja |
| 5 | E3, Regel .claude/rules/fremde-inhalte-im-harness.md (noch nicht vorhanden) und die zurückgestellte Skill zur Einschleusungsprüfung | Regel fehlt; Umfang nirgends festgelegt | offen | ja |

Die drei Prüfrunden dieses Berichts haben am bestehenden main-Gate und am
Prototyp-Gate belegte Lücken gefunden (Abschnitt 5, Dimension Hooks und
Skripte). E4 ist damit nicht mehr nur "rückt nach hinten", sondern hat einen
messbaren Inhalt.

### 6.2 Ausstehende Entscheide des Auftraggebers mit Termin vor dem Grundgerüst

| Nr. | Punkt | Fundstelle | Stand | Blockiert |
|---|---|---|---|---|
| 6 | E-07, Abdeckungsschwelle D6 | `docs/08_Freigabe_Schritt_4.md`; ADR 0002 O-7; Termin "mit R3-Q-001" | offen | ja |
| 7 | E-08, Schwellen für Linter-Warnungen (D3) und Abhängigkeits-Schwachstellen (D8) | `docs/08_Freigabe_Schritt_4.md`, Termin "erste Umsetzungseinheit mit Code"; im `Makefile` als unbestätigt geführt | offen | ja, das Grundgerüst ist die erste Umsetzungseinheit mit Code |
| 8 | O-23 / E-H, ob jede Arbeitseinheit als Aufgabe geführt wird | ADR 0002, Abschnitt 8 | offen | ja |
| 9 | Bestätigung der Notation R6 der Abnahmekriterien | `docs/06_Definition_of_Ready_und_Done.md`, offener Punkt 4 | offen | ja, sobald das Grundgerüst eigene Abnahmekriterien erhält |
| 10 | E-10 (Schnitt R3-F-094), E-11 (Stakeholder-Nachtrag), E-04 bis E-06 (Release Manager, Schreibrechte Legal Reviewer, Standard IT Supporter), Werkzeugfragen 2 und 3 der Vorlage vom 2026-08-29 | je Fundstelle | offen | nein; E-04 berührt den Meilenstein |

### 6.3 Offene Punkte des ADR 0002 mit Termin am Grundgerüst

O-8 (Betriebsart D10, Form D12), O-10 (a) und (b) (gitleaks-Ausschlussliste;
Ablage der Zugangsdaten), O-11 (Abgleich der Wurzelpakete für D18), O-12
(Lauf der Kette auf der Gegenseite; in der Tabelle von Abschnitt 8 nicht
geführt), O-15 (Abnahme des Belegprüfers, "vor der Freigabe des
Grundgerüsts"), O-17 (Löschung einer maskierten Datei, "mit R3-Q-001"), O-18
(Aktualität der Bezugsdokumente), O-20 (Laufzeit gegen die Zeitgrenzen des
Gates), O-21 (ruff-Regelgruppe S), O-22 (Markdown-Strukturprüfer, "spätestens
vor der Freigabe des Grundgerüsts"). Alle offen; je Zuständigkeit in ADR 0002,
Abschnitt 8.

### 6.4 Umgebung

| Nr. | Punkt | Stand | Blockiert |
|---|---|---|---|
| 11 | `gitleaks` (D11, zwei Läufe) | fehlt (`command -v gitleaks`, Rückgabewert 1); D11 ist Lage C. Nach dem Entwurf 6.12 nicht terminierbar: mit dem Gate bliebe jede Arbeitseinheit blockiert, bis das Werkzeug installiert ist (Entscheid E-E) | ja |
| 12 | Docker-Daemon (D1 mit `deploy/compose.test.yml`, Integrationstests) | Programm vorhanden, Daemon nicht erreichbar (`docker info`, Rückgabewert 1). Heute Lage B; sobald `deploy/` entsteht, Lage C | ja, sobald `deploy/` entsteht |
| 13 | `pip-audit` (D8), `lint-imports` (D18), `mypy`, `pytest` | als gesperrte Abhängigkeiten von `backend/` verlangt (Makefile: "ein gleichnamiges Programm im PATH zählt nicht"); entstehen mit `backend/pyproject.toml` und `uv.lock` | mit dem Grundgerüst |

### 6.5 Was dem Grundgerüst selbst fehlt

- **Kein Backlog-Eintrag.** Das Grundgerüst hat keine Anforderungskennung,
  kein Abnahmekriterium und keinen geschätzten Prüfaufwand. Der einzige
  Eintrag, der es nennt, ist R3-C-001, und dessen Abnahme prüft nur den ADR;
  ADR 0002 sagt im Kopf "kein Grundgerüst auf Platte". Ohne Kennung ist D7 für
  dieses Ergebnis nicht erfüllbar, ohne Prüfaufwand ist der Sprintumfang nach
  6.8 nicht bemessbar (Tatsache aus BER-01; als Regelverstoss widerlegt, als
  Befund P-06 bestätigt).
- **Kein Freigabe-Gate.** `docs/06_Definition_of_Ready_und_Done.md` kennt
  "Zwei Reihenfolge-Gates" (Schritt 4 und Prototyp); ADR 0002 terminiert O-15
  und O-22 auf "vor der Freigabe des Grundgerüsts", ein Ereignis, das kein
  Dokument definiert (Tatsache aus BER-02; als Regelverstoss widerlegt, weil
  die Freigabe einer Arbeitseinheit kein Reihenfolge-Gate ist).
- **Kein Schnitt.** ADR 0002, Abschnitt 5, beschreibt `backend/` mit 14
  Modulverzeichnissen, Migrationen, vier Testverzeichnissen, `deploy/` mit
  zwei Compose-Stapeln und vier neuen Skripten. Eine Zerlegung in
  Arbeitseinheiten nach 3.3 liegt in keinem Dokument vor; Abschnitt 9 nennt in
  der Spalte "Wo" nur `backend/`, `deploy/` und `Makefile`, die Skripte fehlen
  dort.
- **Keine Sprintklammer.** `sprints/` im Methodik-Repository enthält nur eine
  leere Platzhalterdatei; der Scrum-Aufbau führt den Sprintstart als offen.
  Seit dem 2026-08-19 sind 23 Übergabedateien in Arbeitseinheiten nach 3.3
  entstanden, ohne Review und Retrospektive. Die Prüfkapazität von 28 bis 40
  Stunden je Sprint (6.8) hat damit keinen Ort, an dem sie gegen den Umfang
  gehalten wird.

### 6.6 Kurzantwort

Vor dem Grundgerüst stehen nach der Dokumentenlage fünf Arbeitseinheiten
(6.1), mindestens vier Entscheide (6.2, Nummern 6 bis 9), zehn offene Punkte
des ADR mit Termin am Grundgerüst (6.3) und zwei Umgebungslücken, die sich
nicht wegterminieren lassen (6.4, Nummern 11 und 12). Dem Grundgerüst selbst
fehlen Backlog-Eintrag, Freigabe-Gate und Schnitt (6.5). Das ist kein Grund,
langsamer zu werden, sondern die Reihenfolge, in der die Dinge zu tun sind:
Erst wenn die Kette blockieren kann (R3-Q-001) und weiss, wogegen (E-07,
E-08), ist ein Grundgerüst prüfbar, das sie zum ersten Mal scharf schaltet.

## 7. Skills aus dem angebundenen Repository

Massstab sind die methodischen Entscheide S6 (fremdes Material wird nie
wörtlich übernommen; übernommen werden Bauweise, Gliederung und Einsicht) und
S7 (ein Skill entsteht nur, wenn mehrere Rollen dieselbe Prozedur gleich
ausführen) sowie `.claude/rules/claude-konfiguration.md`. Geprüft wurde der
Stand `882ef55e377dbf9a4dbe496bb41ac6ccd0e555cf` des fremden Repositories, 67
Skills; die Auswertung vom 2026-08-31
(`docs/uebergaben/2026-08-31_skill-repository-ausgewertet.md`) wird nicht
wiederholt, sondern fortgeschrieben.

**Kurzantwort.** Der fremde Bestand liefert keinen Skill, der zu übernehmen
wäre. Er liefert Bauweise für höchstens zwei eigene, neu zu schreibende
Skills, und der Bedarf dafür entsteht aus dem eigenen Bestand: Zwei
Prozeduren, die mehrere Rollen belegt gleich ausführen, haben heute weder
Skill noch Regel noch Rollentext. Vor beiden steht ein Entscheid des
Auftraggebers und eine terminierte Messung.

### 7.1 Prozeduren mehrerer Rollen ohne Skill

| Prozedur | Belegte Rollen | Heutiger Ort | Lücke |
|---|---|---|---|
| Übergabedatei nach 3.3 schreiben | elf Rollendateien nennen sie, dazu `CLAUDE.md` | `CLAUDE.md` nennt drei Inhaltspunkte, sonst nichts; keine Vorlage unter `docs/vorlagen/` | ja; die Form der 23 Übergaben driftet belegt |
| Gegenprüfung auf einem anderen Modell (3.4) mit Prüflinsen und Widerlegern | Übergaben vom 2026-09-01 und 2026-09-02 beschreiben die Prozedur je neu | 3.4 als Festlegung; `pruefbefund-melden` regelt die Meldung, nicht den Aufbau der Prüfung | ja; wie Linsen gewählt, Widerleger geführt und Runden gezählt werden, steht nirgends |
| Dokument fortschreiben (vorher, jetzt, weshalb) | Software Architect, Product Owner, Requirements Engineer, DevOps Engineer, Protocol Master | ein Satz in `.claude/rules/dokumentation.md`, nur für ADR; die Bauform ist allein in ADR 0002 vorgelebt | teilweise |
| Commit mit Anforderungskennung; fester Verweis mit 40-stelliger Prüfsumme | alle schreibenden Rollen | `CONTRIBUTING.md`, `CLAUDE.md`, `.claude/rules/dokumentation.md`, maschinell D20 | nein, vollständig geregelt; kein Skill |
| Ausnahmeeintrag begründen; Hook-Selbsttest | heute eine Liste beziehungsweise ein Satz in der Regel; die zweite Liste und die Ausgestaltung des Selbsttests stehen im Entwurf 6.12 | ADR 0002, 6.8.5 und 6.12.19 | erst nach der Freigabe von 6.12 mehrrollig; bis dahin kein Skill |

### 7.2 Kandidaten (Vorschlag, kein Entscheid)

| Nr. | Name | Rollen | Quelle der Einsicht im fremden Bestand (nur Bauweise, S6) | Aufwand | Bedingung |
|---|---|---|---|---|---|
| 1 | Übergabe schreiben | die elf Rollen aus 7.1 | Skill "code-documenter": Validierungsschritt vor dem Berichtsschritt; Skill "spec-miner": Prüfpunkt vor dem Schreiben | rund 3 h | Entscheid nach 7.3 |
| 2 | Gegenprüfung auf einem anderen Modell | Static und Dynamic Software Tester, Pentester, Protocol Master, Requirements Engineer, Software Architect | Skill "the-fool": benannte Prüfmodi, je Modus eine eigene Referenzdatei, Modus vor der Prüfung wählen; Skill "code-reviewer": Umgang mit Widerspruch, Absicht in einem Satz zusammenfassen | rund 4 h | Entscheid nach 7.3; erst nach der Freigabe von 6.12, damit die Rundenzählung des Gates und die des Skills nicht auseinanderlaufen |
| 3 | Dokument fortschreiben | fünf Rollen aus 7.1 | Skill "architecture-designer": Vorlage als eigene Referenzdatei statt im Rumpf | rund 3 h | nachrangig, solange ADR 0002 täglich fortgeschrieben wird |
| 4 | Ausnahme eintragen | DevOps, SecDevOps; verifiziert durch beide Tester | keine; die Einsicht steht in ADR 0002, 6.8.5 | rund 2 h | nach der Freigabe von 6.12 |
| 5 | Hook-Selbsttest | SecDevOps, DevOps, beide Tester | Skill "test-master": Pflicht zur Gegenprobe, Trennung von Fehlschlag und Zufall | rund 2 h | nach der Freigabe von R3-Q-001 |

Ausdrücklich kein Skill: Commit-Konventionen (vollständig in `CONTRIBUTING.md`
und `CLAUDE.md`; ein Skill wäre die dritte Quelle derselben Wahrheit) und
feste Verweise mit Prüfsumme (Festlegung plus maschinelle Prüfung durch D20).

### 7.3 Abgelehnt, mit Grund

Ohne die Ablehnungen vom 2026-08-31 zu wiederholen (deren Vollständigkeit ist
geprüft: die gestrichenen Gegenstände ergeben einen Fehltreffer, `pgvector`
vier Dateien in zwei Skills, beides deckt sich mit der damaligen Auswertung):

| Kandidat im fremden Bestand | Grund |
|---|---|
| python-pro, sql-pro, api-designer, mcp-developer, prompt-engineer, debugging-wizard, feature-forge, spec-miner | Fachwissen oder Einzelrolle, keine Prozedur mehrerer Rollen (S7); verbindliche Teile sind bei uns Festlegungen in ADR 0002 oder in der Kette. mcp-developer verlangt zudem das Protokollieren von Protokollnachrichten zur Fehlersuche, gegen 5.12 und 5.3 |
| fastapi-expert, secure-code-guardian | bauen eine eigene Anmeldung mit Schlüssel im Quelltext; gegen A10 (OpenID Connect als einziger Anmeldeweg) und gegen ADR 0002, Abschnitt 5 |
| code-reviewer, security-reviewer, devops-engineer, architecture-designer, sre-engineer | führen eine Rolle als Skill; nach ADR 0001, Abschnitt 5.5 unzulässig, weil der Nachweis nach 6.6 sagen muss, wer geprüft hat. security-reviewer verlangt die CVSS-Einstufung vom Findenden (gegen R4 und die Pentester-Rolle); devops-engineer verkettet Vorschlag und Ausführung im selben Handelnden (gegen 5.2); sre-engineer setzt Produktionszugang voraus (gegen ADR 0001, 7.2) |
| test-master, code-documenter, the-fool | als Ganzes nicht übernehmbar (Berichtsteil durch `pruefbefund-melden` besetzt; Formfragen bei uns festgelegt; Modusauswahl über Rückfrage, englisch); nur die Bauweise fliesst in die Kandidaten 1, 2 und 5 |
| playwright-expert, react-expert, typescript-pro | Frontend; vor der schriftlichen Prototyp-Freigabe entsteht kein Frontend-Produktionscode (5.6) |
| postgres-pro, rag-architect | bereits am 2026-08-31 wegen `pgvector` (A4) abgelehnt |

### 7.4 Was vor dem dritten Skill zu entscheiden ist

1. **Wer `.claude/skills/` schreibt.** ADR 0001, Abschnitt 8, letzte Zeile:
   "Vor der dritten Skill ist zu entscheiden, ob das so bleibt." Jeder
   Kandidat aus 7.2 wäre die dritte Skill. Abschnitt 4 des ADR weist
   `.claude/` keiner Rolle zu; wer eine Skill schreibt, ist heute weder
   schreibberechtigt noch prüfbar zugeordnet.
2. **Der terminierte Kontrollversuch.** ADR 0001, Abschnitt 5.1, verlangt "zu
   Beginn der nächsten Sitzung" die Messung, ob das Vorladen über `skills:`
   wirkt. Sie ist seit dem 2026-08-31 nicht belegt. Solange sie fehlt,
   vervielfacht jeder weitere Skill einen unbelegten Mechanismus, und `Skill`
   steht in neun Werkzeuglisten ohne bestätigten Grund.
3. **Die Abnahme der beiden bestehenden Skills.** Beide sind nach 3.4
   abgebrochen und nicht abgenommen; `dod-kette-belegen` trägt die Lage C noch
   im Wortlaut vor der Schärfung vom 2026-09-01 (Befund R-01, FORM-01).

Empfohlene Reihenfolge: Kontrollversuch ausführen und ADR 0001 nachführen;
die bestehenden Skills berichtigen und abnehmen oder begründet ruhen lassen;
Zuständigkeit entscheiden; erst dann Kandidat 1, danach Kandidat 2, jeder
einzeln von einer anderen Instanz auf einem anderen Modell geprüft und an den
drei Stellen nachgeführt, die S7 nennt. R3-Q-001 steht in der freigegebenen
Reihenfolge vor allem davon.

## 8. Nicht geprüft

- Inhalt der PDF `docs/01_Konzept_v1.0.pdf`.
- Läufe der GitHub-Arbeitsabläufe (Actions) und der Inhalt von `nachweise/`
  im Methodik-Repository über Stichproben hinaus.
- Verhalten der Hook-Skripte im laufenden Harness; geprüft wurde ihr Verhalten
  bei unmittelbarem Aufruf mit JSON-Eingabe.
- Ob das Vorladen über `skills:` in dieser Umgebung wirkt (der in ADR 0001,
  5.1 terminierte Kontrollversuch); diese Sitzung kann keinen Startkontext
  einer anderen Rolle einsehen.
- Der fremde Skill-Bestand über die Dateien `SKILL.md` und die genannten
  Referenzdateien hinaus.
- Die Rollentexte gegen die zwölfte Fortschreibung von ADR 0002; sie ist ein
  nicht freigegebener Entwurf.
- Laufzeitverhalten des entworfenen Gates; es besteht kein Skript.
- Dynamisches Verhalten von Produktionscode; es gibt keinen.
