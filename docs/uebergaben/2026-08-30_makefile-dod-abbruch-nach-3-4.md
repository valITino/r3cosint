# Übergabe — Makefile mit `make dod`, Abbruch nach Eskalationsregel 3.4

| | |
|---|---|
| **Arbeitsprodukt nach** | Projektauftrag 3.3 (Übergabedatei je Arbeitseinheit), 3.4 (Eskalation) |
| **Einheit** | Zwischenschritt vor R3-Q-001 auf Weisung des Auftraggebers vom 2026-08-29 |
| **Datum** | 2026-08-30 |
| **Zweig** | `claude/next-step-g8slnq` |
| **Ergebnis** | **Nicht abgenommen.** Abbruch nach 3.4 — dasselbe Kriterium dreimal gescheitert |
| **Stand der Datei** | `Makefile`, sha256 `a66d43287d2879c4eb2ac491a6b97da9d336bc1b34fe01f24d4e20207c2fb2e8` |

## Warum abgebrochen wird

3.4 verlangt: Scheitert dieselbe Prüfung dreimal am gleichen Kriterium, wird
abgebrochen, die Übergabedatei geschrieben und die Aufgabe vorgelegt.
Weiterprobieren an einem Problem, das sich nicht von innen lösen lässt,
verbrennt nur Kontingent.

Das gescheiterte Kriterium ist in allen drei Prüfungen dasselbe:
**Ein Kettenschritt endet mit 0, obwohl er nichts geprüft hat.**

| Runde | Befund |
|---|---|
| 1 | `dod` wertete die eigene Lage-Marke nicht aus; D9 meldete Lage B bei vorhandenem `deploy/` |
| 2 | D10 meldete Lage B, während `deploy/images/Dockerfile` `prototype/` in das Produktionsabbild kopierte — `make dod` grün (blockierend) |
| 3 | Lage C über den `PATH` umgangen; D11 „bestanden" ohne Historienlauf; D7 wieder Lage B |

Behoben wurde jedes Mal der belegte Einzelfall, nie das Muster. **Das Muster
lautet: Die Kette misst die Verfügbarkeit eines Namens, nicht die Anwesenheit
des Gegenstands oder des Prüfmittels.** Es sitzt an drei voneinander
unabhängigen Stellen:

- Werkzeugname im `PATH` statt Werkzeug im gesperrten Umfeld
- Pfadname `.git` als Verzeichnis statt Repository
- Dateiname des Backlogs statt Abnahmekriterien

Eine vierte Runde am Einzelfall führt absehbar zur vierten Wiederholung.

## Die zwei blockierenden Befunde

### B1 — Lage C ist über den `PATH` umgehbar

`uv run --project backend --locked <werkzeug>` fällt auf ein gleichnamiges
Programm im `PATH` zurück, wenn das Werkzeug **keine** erklärte, gesperrte
Abhängigkeit von `backend/` ist. Belegt am 2026-08-30:

```
$ ls backend/.venv/bin        ->  kein ruff
$ uv run --project backend --locked bash -c 'command -v ruff'
/root/.local/bin/ruff          <- ausserhalb des gesperrten Umfelds

$ PATH=fake:$PATH make dod     # Attrappen fuer ruff, mypy, lint-imports, pip-audit
make dod: alle 13 Kettenschritte durchlaufen (D1 bis D12 plus D18), keiner
          ungleich 0, 13 gueltige Marken gezaehlt, D19 ohne Befund.
RC=0
$ grep dependencies backend/pyproject.toml
dependencies = ["pytest-cov"]  <- kein ruff, mypy, lint-imports, pip-audit
```

**Das entwertet D18 in seiner tragenden Funktion.** Nach ADR 0002 Abschnitt 4.3
belegt D18 die Freigabesperre (5.2, R3-F-014) und die Modellunabhängigkeit
(5.15, R3-F-018). Hier meldete er „bestanden", ohne dass ein Prüfer lief.

Der Kommentar im Makefile behauptet ausdrücklich das Gegenteil
(„`uv run pip-audit` schlägt fehl, wenn pip-audit keine erklärte Abhängigkeit
ist") und ist damit widerlegt.

**Das richtige Muster steht bereits in derselben Datei:**
`uv run --project backend --locked python -c "import pytest_cov"` weist das
Prüfmittel im Umfeld nach statt im `PATH`. Gegenprobe: `python -c "import ruff"`
endet mit `ModuleNotFoundError`, während die Namensprobe erfolgreich ist.

### B2 — D19 ist im verlinkten Git-Worktree blind

`Makefile` prüft `[ -d "$(PROJ).git" ]`. In einem `git worktree` und in einem
Submodul ist `.git` eine **Datei**, kein Verzeichnis. D19 meldet dann Lage B und
beobachtet nichts — obwohl der Baum voll versioniert und `git` vorhanden ist.

```
$ git worktree add --detach ../wt HEAD && cd ../wt
$ make dod        # ein Kettenschritt haengt eine Zeile an README.md an
make dod: D19 Lage B -- kein .git/ vorhanden ...
RC=0
$ git status --short
 M README.md
```

Der Arbeitszweig-Betrieb nach CLAUDE.md macht `git worktree` zu einer
naheliegenden Arbeitsform; der Fall ist nicht exotisch.

## Was trägt — und es ist der grössere Teil

Alle sechs Behauptungen der vierten Behebungsrunde sind unabhängig belegt:

| | |
|---|---|
| D10 | hängt an `prototype/` und läuft immer — der blockierende Befund der zweiten Prüfung ist behoben |
| D19 | macht grün rot, nie rot grün, und läuft auch bei Abbruch |
| Markenerwartung | tautologiefrei; gekürzte Zielliste und verbogene Kennung enden beide ungleich 0 |
| `--locked` | alle 14 `uv`-Aufrufe tragen `--project backend --locked`; Drift endet ungleich 0, `uv.lock` bleibt bytegleich |
| Lage C | D2 bis D5 und D18 melden Lage C statt A_FAIL bei fehlendem Prüfmittel |
| D18 | erkennt Python-Code unterhalb `backend/src/` paketnamenunabhängig |

Ebenfalls ohne Beanstandung: Die `-i`-Wache hält in **dreizehn** geprüften
Varianten; `-n` führt nachweislich nichts aus (Kanarienvogel nicht angelegt);
`-q`, `-k`, `-j4`, `-e` und der Aufruf aus fremdem Arbeitsverzeichnis sind
unauffällig; `MAKE_REKURSIV` lässt sich nicht umbiegen; eine Marke ohne
Lauf-Kennung wird nicht anerkannt; keine der gestrichenen Grössen (VirusTotal,
TheHive, Cortex, Maltego, Open WebUI, CASE/UCO, Gesichtserkennung) kommt vor;
kein Kettenschritt öffnet selbst eine Verbindung.

Von den elf Angriffen der ersten Prüfung gelingt **keiner** wieder.

## Weitere Befunde, nach Schwere

**Erheblich:** Gefälschte Marke überschreibt die echte in der Übersicht, weil
`tail -n1` die spätere gewinnen lässt — der Lauf bleibt rot, aber das
Nachweisartefakt weist einen Negativbefund als bestanden aus (5.3). · D11 lässt
den Arbeitsbaumlauf entfallen, wenn `git` fehlt, obwohl er `git` nicht braucht
(ADR 6.3.3 verlangt ausdrücklich das Gegenteil). · D11 hat keine
Gegenstandsprüfung: ohne `.git/` meldet ein Sicherheitsgate „bestanden", weil
gitleaks trotz `ERR failed to scan Git repository` mit 0 endet. · D7 hat
weiterhin eine Lage B, die der seit `cabd321` geltende ADR verbietet. · D19
ist durch `git update-index --assume-unchanged` eines Kettenschritts
abschaltbar. · **Befehlseinschleusung über `LINT_MAX_WARNINGS` und
`AUDIT_LEVEL`**: Die Werte werden in doppelt gequotete Zeichenketten expandiert;
ein `"` im Wert bricht aus und führt Befehle aus — belegt, auch durch den
Einstieg `make dod` hindurch. · D1 meldet bei fehlendem `build`-Skript A_FAIL
statt Lage C.

**Mittel:** `git status --porcelain` ohne `--untracked-files=all` — eine
Repository-Einstellung entfernt den `??`-Teil still. · `$(PROJ)` bricht bei
Leerzeichen im Pfad und legt D19 still. · D7 beurteilt nur den ersten Treffer
und behauptet Ungeprüftes.

**Beantwortet, nicht behoben:** Der offene Punkt aus ADR 6.3.1 ist mit einem
ausgeführten Lauf geklärt — **pytest liest `backend/pyproject.toml` von der
Repository-Wurzel aus nicht.** `rootdir` ist die Wurzel, `configfile` fehlt,
Tests werden aus dem ganzen Repository eingesammelt, und `--strict-markers`
scheitert an einem nur dort deklarierten Marker. D5, D6 und D7 sind damit heute
nicht lauffähig und brauchen eine Pfadangabe oder `-c backend/pyproject.toml` —
nach 6.3.1 eine eigene Fortschreibung, keine Entscheidung im Makefile.

## Was in dieser Umgebung nicht prüfbar war

Diese Liste ist kein Makel der Arbeit, sondern die Grenze des Belegbaren. Sie
gehört in die Fortsetzung, nicht in eine Fussnote.

1. **Offline-Verhalten von `--locked`** (K3, Nachweispflicht ADR 6.2.1 Punkt d).
   Die Umgebung hat Netzzugang; die Auflösung in 5 ms deutet auf den
   Zwischenspeicher, ist aber kein Beweis.
2. **D1, Stapelbau, Lage A.** Der Docker-Daemon ist nicht erreichbar; geprüft
   ist ausschliesslich der Lage-C-Zweig.
3. **D8 gegen eine echte Schwachstellendatenbank.**
4. **D6 mit echten Abdeckungswerten** unter den unbestätigten Schwellen E-07.
5. **D11 gegen einen echten Fund** in Arbeitsbaum und Historie; die in ADR 6.2.3
   entschiedene Ausschlussliste existiert noch nicht (O-10).
6. **Die vier Projektskripte** `abnahme-abgleich.sh`, `rueckkanal-pruefen.sh`,
   `prototyp-trennung-pruefen.sh`, `nachweise-vollstaendig.sh` existieren nicht;
   alle Läufe, die sie erreichen, liefen gegen Attrappen.
7. **Ein Lauf gegen echten Backend-Produktionscode** und der gesamte
   Oberflächenzweig (kein `frontend/`, keine npm-Skripte).
8. **Der Hook aus R3-Q-001 existiert nicht.** Ob `make dod` als `Stop`
   beziehungsweise `SubagentStop` das erwartete Verhalten zeigt — nur
   Rückgabewert 2 blockiert, Reentranz über `stop_hook_active`, Eskalation nach
   dreimaligem Scheitern —, ist nur aus dem Rückgabewert von `make` abgeleitet,
   nie am laufenden Hook gemessen.
9. **Fremde Plattformen und Make-Fassungen** (GNU Make vor 3.82, BSD make,
   macOS, Alpine) — nur simuliert.

## Was dem Auftraggeber vorzulegen ist

1. **Wie wird ein Prüfmittel als „im gesperrten Umfeld vorhanden" nachgewiesen?**
   Das Muster liegt in derselben Datei vor. Zuständig: DevOps Engineer für die
   Umsetzung, Software Architect für die Spalte Prüfmittel der Objekttabelle.
2. **Bleibt die Objekterkennung im Makefile oder wandert sie in die vier
   Projektskripte?** ADR 6.3.2 deutet die zweite Richtung bereits an. Das ist
   die Entscheidung, die das Muster hinter allen drei Runden auflöst — solange
   jeder Kettenschritt seinen Gegenstand selbst errät, wiederholt es sich.
3. **Fortschreibung zu D5, D6 und D7** wegen des pytest-Befunds.
4. **Behandlung der Befehlseinschleusung** über `LINT_MAX_WARNINGS` und
   `AUDIT_LEVEL` durch SecDevOps und Vulnerability Manager.
5. **E-07 und E-08** bleiben unverändert offen (O-7).

## Empfehlung

Die Datei ist nicht wertlos — sie ist an dreizehn von dreizehn Stellen
mechanisch dicht gegen die Angriffe, die man ihr bisher zugedacht hat, und die
vierte Runde hat jede ihrer sechs Zusagen gehalten. Was fehlt, ist eine
Entscheidung, die oberhalb des Makefiles liegt: **woran ein Kettenschritt
seinen Gegenstand und sein Prüfmittel erkennt.** Diese Entscheidung dreimal im
Einzelfall nachzuholen hat dreimal nicht getragen.

Empfohlen wird deshalb, Punkt 1 und 2 zu entscheiden, **bevor** wieder Hand an
die Datei gelegt wird — und erst danach R3-Q-001 anzugehen, dessen Hook auf
`make dod` aufsetzt.
