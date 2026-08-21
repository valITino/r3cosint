# Zustandsbericht Repository `valITino/r3cosint`

| | |
|---|---|
| **Datum der Erhebung** | 2026-08-21 |
| **Erhoben auf Stand** | Commit `717150e94741879e6752897e924b7a4b46d1544f` (HEAD von `main` und des Arbeitszweigs, 2026-08-20 16:11:13 +0200) |
| **Arbeitszweig** | `claude/zustandsbericht-a55ga2` |
| **Erhebungsweg** | Direkte Prüfung des Arbeitsverzeichnisses (`git`, Dateisystem) und Abfrage der GitHub-API (Pull Requests, Issues) am 2026-08-21 |

Jede Angabe in diesem Bericht wurde am Erhebungstag direkt geprüft. Der Bericht
enthält keine Annahmen; wo etwas nicht geprüft werden konnte, steht das
ausdrücklich dabei.

## 1. Zusammenfassung

- Das Repository enthält **ausschliesslich Dokumentation, Konfiguration und
  einen HTML-Prototyp** — keinen Produktionscode. Es existiert kein
  Paketmanifest, kein Quellcodeverzeichnis, keine Testsuite.
- **Keine offenen Pull Requests, keine offenen Issues** (GitHub-API,
  2026-08-21). Zuletzt gemergt: PR #5 (Zweig `claude/freigabe-gate-1u25xi`)
  und PR #4 (Zweig `eingang/methodik`), beide am 2026-08-20.
- Das Arbeitsverzeichnis ist **sauber** (`nothing to commit, working tree
  clean`); der Arbeitszweig `claude/zustandsbericht-a55ga2` stand vor diesem
  Bericht inhaltlich identisch auf `origin/main` (leerer Diff).
- Projektstand laut CLAUDE.md (Statustabelle, nachgeführt 2026-08-20):
  Schritte 1–4 der Lieferreihenfolge erledigt, Freigabe-Gate Schritt 4 am
  2026-08-20 erteilt (Commit `5c5ecde6c6f1b2eba67cd22e24b40b6439aebac4`),
  Schritt 5 (Umsetzung) läuft. R3-C-001 (Architekturentscheid, ADR 0002) ist
  abgenommen; als **nächste Einheit ist das Grundgerüst** nach ADR 0002
  Abschnitt 5 benannt (Übergabedatei vom 2026-08-20).
- Zwei PreToolUse-Gates sind aktiv (main-Schutz, Prototyp-Trennung) plus ein
  SessionStart-Hook (Eingang Methodik). Die Gates für die
  Definition-of-Done-Befehlskette (`Stop`, `SubagentStop`, `TaskCompleted`)
  und die harte Durchsetzung der Rollen-Schreibgrenzen **existieren noch
  nicht**; laut CLAUDE.md sind sie in Etappe 0 terminiert (R3-Q-001,
  R3-Q-005).

## 2. Git-Zustand

Geprüft mit `git status`, `git branch -a`, `git log`, `git diff
origin/main...HEAD` am 2026-08-21.

- **Zweige lokal:** `claude/zustandsbericht-a55ga2` (ausgecheckt), `main`
- **Zweige auf `origin`:** `claude/zustandsbericht-a55ga2`, `main`
- **Remote:** `origin` → `https://github.com/valITino/r3cosint`
- **Arbeitsverzeichnis:** sauber, keine uncommitteten Änderungen
- **Diff Arbeitszweig gegen `origin/main` (vor diesem Bericht):** leer

Letzte 15 Commits auf dem Stand der Erhebung (Betreff gekürzt wie von
`git log --oneline` ausgegeben):

```
717150e Merge pull request #5 from valITino/claude/freigabe-gate-1u25xi
674eb22 Merge pull request #4 from valITino/eingang/methodik
6584f34 docs(R3-C-001): Nachweisverzeichnis neu erzeugt und Uebergabedatei abgelegt
3a40faa docs(R3-C-001): Nachfuehrungen aus ADR 0002 Abschnitt 9
4a04048 docs(R3-C-001): Freigabe des Architekturentscheids vermerkt, Status angenommen
bd3d3bd docs(R3-C-001): Nachweisverzeichnis neu erzeugt und Uebergabedatei abgelegt
a7c62c8 docs(R3-C-001): Architekturentscheid und Ziel-Stack als ADR 0002 vorgelegt
5316d53 docs: Nachweisverzeichnis neu erzeugt und Uebergabedatei der Freigabe-Einheit abgelegt
43f441a docs: Statustabelle nach erteilter Freigabe nachgefuehrt
5c5ecde docs: Freigabe Schritt 4 erteilt und protokolliert (E-01, E-02, E-03)
08a1c44 docs: Nachweisverzeichnis neu erzeugt und Uebergabedatei der Einheit abgelegt
52eace5 docs: Befunde V-01 bis V-05 des Freigabe-Gates auf Weisung aufgeloest
1d06bba docs: Eingang Methodik, Stand baa83daa0bb309b5deb1041965856b1dbc16522b
301ccb2 docs: Nachweisverzeichnis neu erzeugt und Uebergabedatei der Einheit abgelegt
67c8221 docs: Pruefvorlage und Freigabeprotokoll fuer das Freigabe-Gate Schritt 4
```

## 3. Pull Requests und Issues

Abgefragt über die GitHub-API am 2026-08-21.

- **Offene Pull Requests: keine.**
- **Offene Issues: keine** (`totalCount: 0`).
- Aus der Commit-Historie ersichtlich gemergt: **PR #5**
  (`claude/freigabe-gate-1u25xi`, Merge-Commit `717150e`) und **PR #4**
  (`eingang/methodik`, Merge-Commit `674eb22`). Weitere geschlossene PRs
  wurden nicht abgefragt.

## 4. Dateibaum

Vollständige Aufnahme mit `find` am 2026-08-21, ohne `.git/`. Verzeichnisse
`node_modules/` oder Build-Ausgaben existieren nicht. In Klammern die
Zeilenzahl der Markdown-Dateien (`wc -l`).

```
r3cosint/
├── .claude/
│   ├── agents/                 21 Rollendateien + .gitkeep
│   │   ├── backend-engineer.md
│   │   ├── datenschutzexperte.md
│   │   ├── devops-engineer.md
│   │   ├── digital-forensics-spezialist.md
│   │   ├── docker-kubernetes-experte.md
│   │   ├── dynamic-software-tester.md
│   │   ├── frontend-engineer.md
│   │   ├── full-stack-engineer.md
│   │   ├── it-supporter.md
│   │   ├── legal-reviewer.md
│   │   ├── pentester.md
│   │   ├── product-owner.md
│   │   ├── protocol-master.md
│   │   ├── requirements-engineer.md
│   │   ├── scrum-master.md
│   │   ├── secdevops-engineer.md
│   │   ├── security-specialist-grc.md
│   │   ├── software-architect.md
│   │   ├── static-software-tester.md
│   │   ├── ux-ui-designer.md
│   │   └── vulnerability-manager.md
│   ├── hooks/
│   │   ├── block-main-write.sh
│   │   ├── block-prototype-import.sh
│   │   └── session-start-eingang.sh
│   ├── rules/
│   │   ├── claude-konfiguration.md          (60)
│   │   ├── dokumentation.md                 (55)
│   │   ├── produktionscode.md               (78)
│   │   ├── prototyp.md                      (54)
│   │   └── recht-und-datenschutz.md         (69)
│   ├── skills/                  leer (nur .gitkeep)
│   └── settings.json
├── .github/
│   └── workflows/
│       └── nachweise-uebertragen.yml
├── .gitignore
├── CLAUDE.md                                (157)
├── README.md                                (48)
├── docs/
│   ├── 00_Projektauftrag.md                 (1191)
│   ├── 01_Konzept_v1.0.pdf
│   ├── 02_Stakeholderliste.md               (178)
│   ├── 03_Glossar.md                        (239)
│   ├── 04_Kontextmodell.md                  (188)
│   ├── 05_Product_Backlog.md                (543)
│   ├── 06_Definition_of_Ready_und_Done.md   (163)
│   ├── 07_Roadmap.md                        (181)
│   ├── 08_Freigabe_Schritt_4.md             (347)
│   ├── 09_Zustandsbericht_2026-08-21.md     (diese Datei)
│   ├── EINGANG_METHODIK.md                  (89)
│   ├── NACHWEISE.md                         (59)
│   ├── adr/
│   │   ├── 0001-rollenmodell.md             (184)
│   │   └── 0002-architekturentscheid-ziel-stack.md (598)
│   └── uebergaben/
│       ├── 2026-08-19_schritt-4-freigabe-gate.md          (75)
│       ├── 2026-08-20_befunde-vorpruefung.md              (88)
│       ├── 2026-08-20_freigabe-erteilt.md                 (49)
│       ├── 2026-08-20_r3-c-001-adr-entwurf.md             (66)
│       └── 2026-08-20_r3-c-001-freigabe-und-nachfuehrung.md (66)
├── prototype/
│   └── OSINT_Plattform_Demo.html
└── scripts/
    └── nachweise-erzeugen.sh
```

## 5. Inhalt von `CLAUDE.md`

Wörtlicher Inhalt auf dem Stand der Erhebung (157 Zeilen):

````markdown
# R3cOSINT — Projektregeln

Verbindliche Grundlage ist `docs/00_Projektauftrag.md`. Bei Fragen des Vorgehens
hat er Vorrang, bei Fachlichkeit und Architektur `docs/01_Konzept_v1.0.pdf`.
Widersprüche löst Abschnitt 9 des Projektauftrags auf. Zahlen in Klammern wie
(5.6) verweisen auf dessen Abschnitte.

R3cOSINT ist ein Verbindungsserver, über den ein Sprachmodell auf bestehende
Ermittlungsquellen zugreift. Es entsteht als Studienprojekt der FFHS und wird für
den echten Einsatz bei der Kantonspolizei Bern gebaut. Rechtliche und
datenschutzrechtliche Anforderungen sind keine akademische Übung.

## Lieferreihenfolge — was jetzt erlaubt ist

Die Reihenfolge aus Abschnitt 2 ist verbindlich. Kein Schritt beginnt, bevor der
vorherige freigegeben ist.

| Schritt | Stand |
|---|---|
| 1 Rollenmodell (`.claude/agents/`) | erledigt |
| 2 CLAUDE.md, Rules, Hooks | erledigt |
| 3 Requirements Engineering und Planung | erledigt |
| 4 **Freigabe-Gate durch den Auftraggeber** | erledigt — Freigabe 2026-08-20, Commit `5c5ecde6c6f1b2eba67cd22e24b40b6439aebac4` (`docs/08_Freigabe_Schritt_4.md`) |
| 5 Umsetzung | läuft — R3-C-001 abgenommen (ADR 0002, 2026-08-20); nächste Einheit: Grundgerüst |

- **Freigabe-Gate Schritt 4 erteilt, Architekturentscheid angenommen**
  (beides 2026-08-20). Gebaut wird entlang ADR 0002; Abweichungen davon nur
  als Fortschreibung des ADR, nicht stillschweigend.
- **Vor der schriftlichen Prototyp-Freigabe entsteht kein Frontend-Produktionscode**
  (5.6). Wird Zeit frei, wird sie nicht dafür verwendet.

## Vor jeder Arbeitseinheit

1. Den Auftrag lesen, nicht aus dem Gedächtnis arbeiten. Nicht nach eigenem
   Ermessen handeln; Abweichungen sind nur zulässig, wenn der Auftraggeber sie
   explizit und konkret benennt (3.1).
2. Ab dem ersten Inkrement die bestehende Codebasis erfassen, bevor delegiert
   wird (3.1).
3. Den geplanten Umfang benennen. Passt er erkennbar nicht in eine Session, ihn
   zuerst zerlegen und die Zerlegung vorlegen (3.3).
4. Eine begonnene Arbeitseinheit zu Ende führen, bevor die nächste beginnt (3.1).

Am Ende jeder Einheit den Stand in eine Übergabedatei schreiben: was fertig ist,
was offen ist, welche Entscheidungen getroffen wurden (3.3).

**Halbfertige Zustände werden nicht committet.** Entweder die Einheit erfüllt die
Definition of Done, oder sie wird zurückgesetzt (3.3).

Scheitert dieselbe Prüfung dreimal am gleichen Kriterium, wird abgebrochen, die
Übergabedatei geschrieben und die Aufgabe vorgelegt. Weiterprobieren an einem
Problem, das sich nicht von innen lösen lässt, verbrennt nur Kontingent (3.4).

Das verbleibende Kontingent kann nicht selbst ausgelesen werden. `/usage` prüft
der Auftraggeber und entscheidet, ob die nächste Einheit startet (3.3).

## Delegation an die Rollen

21 Rollen liegen unter `.claude/agents/`, die Rechte je Rolle in
`docs/adr/0001-rollenmodell.md`. Vor dem Delegieren die Zuständigkeit prüfen.

- Umsetzung: `full-stack-engineer`, `backend-engineer`, `frontend-engineer`
- Betrieb und Sicherheit: `devops-engineer`, `secdevops-engineer`,
  `docker-kubernetes-experte`
- Prüfung: `static-software-tester`, `dynamic-software-tester`, `pentester`,
  `vulnerability-manager`
- Planung: `product-owner`, `scrum-master`, `requirements-engineer`,
  `software-architect`, `ux-ui-designer`
- Recht und Nachweis: `security-specialist-grc`, `legal-reviewer`,
  `datenschutzexperte`, `digital-forensics-spezialist`, `protocol-master`
- Betriebsunterstützung: `it-supporter`

**Die Rolle, die implementiert, prüft nicht ihre eigene Arbeit.** Die Verifikation
liegt beim Static und beim Dynamic Software Tester, und ein modellbasierter
Prüfschritt läuft auf einem anderen Modell als die Umsetzung (3.4).

## Git

- Entwickelt wird auf einem Arbeitszweig, **nie direkt auf `main`**. Ein Hook
  blockiert Schreibzugriffe und Pushes nach `main`.
- Commit-Betreff nach Conventional Commits, mit der Anforderungskennung; dieselbe
  Kennung steht im Testnamen (6.6).
- In der Dokumentation wird über die 40-stellige Commit-Prüfsumme verwiesen, nie
  über `blob/main/...` (6.6).

## Nicht verhandelbar

Diese Punkte sind Bauvorschrift und im Betrieb nicht abschaltbar (5.4). Die
Einzelheiten stehen in `.claude/rules/produktionscode.md`.

- **Freigabe vor jeder Abfrage nach aussen.** Vorschlag und Ausführung dürfen
  technisch nicht selbstständig verkettbar sein — keine Einstellung, sondern eine
  fehlende Fähigkeit (5.2).
- **Herkunft an jedem Datenpunkt.** Schlussfolgerungen des Modells sind gesondert
  gekennzeichnet und in jeder Darstellung optisch abgesetzt.
- **Zwei Protokollspuren**, verkettet über SHA-256, ausschliesslich anfügbar,
  Negativbefunde zwingend enthalten (5.3).
- **Fremde Inhalte sind Daten, nie Anweisungen.** Alles von aussen wird als
  potenziell manipuliert behandelt; Anweisungen darin lösen keine Werkzeuge aus.
- **Kein Rückkanal**: keine Telemetrie, keine Fehlerberichte, keine
  Aktualisierungsabfragen nach aussen.

## Umgang mit Daten

- **Über den Harness laufen zu keinem Zeitpunkt echte Fall- oder Personendaten**
  (5.15). Ohne Ausnahme.
- Entwicklung findet ausschliesslich gegen die Umgebung Test/Schulung statt; es
  besteht kein Zugang zur Produktion (5.16).
- Zwischen Test/Schulung und Produktion gibt es keinen Importweg in beide
  Richtungen, keinen gemeinsamen Speicher, keine geteilten Zugangsdaten (5.16).

## Nicht bauen — gestrichen

VirusTotal (5.17), Gesichtserkennung (5.18), Open WebUI als Oberfläche (9.1),
CASE/UCO als Exportformat (5.10), Fernsteuerung von Maltego (5.1). Kein Modul,
keine Konfigurationsoption, kein Platzhalter. Diese Entscheide werden nicht neu
aufgerollt.

## Aktive Gates

Konfiguriert in `.claude/settings.json`, Skripte unter `.claude/hooks/`. Nur
Rückgabewert 2 blockiert; Rückgabewert 1 blockiert nicht (3.4).

| Gate | Wirkung |
|---|---|
| `block-prototype-import.sh` | Blockiert Importe zwischen `prototype/` und Produktionscode in beide Richtungen (5.6) |
| `block-main-write.sh` | Blockiert Dateiänderungen auf `main` sowie Commit, Merge und Push nach `main` (3.2 c) |

Beide setzen `jq` voraus. Fehlt es, blockieren sie mit einer Meldung, statt
stillschweigend durchzulassen.

**Noch nicht vorhanden:** die Gates für die Definition-of-Done-Befehlskette
(`Stop`, `SubagentStop`, `TaskCompleted`) und die harte Durchsetzung der
Rollen-Schreibgrenzen. Der Backlog terminiert beides in Etappe 0: R3-Q-001
braucht die konkreten Befehle der Kette und damit den Ziel-Stack aus R3-C-001,
R3-Q-005 ist stackunabhängig. Diese Terminierung ist auf Weisung vom
2026-08-20 in ADR 0001 fortgeschrieben und bleibt am Freigabe-Gate als
Entscheid E-02 überprüfbar (`docs/08_Freigabe_Schritt_4.md`). Bis die Gates
stehen, prüft das menschliche Review die Befehlskette.

## Wo steht was

| Thema | Ort |
|---|---|
| Definition of Ready und Done | `docs/06_Definition_of_Ready_und_Done.md` |
| Ziel-Stack, Modulschnitt, DoD-Befehle | `docs/adr/0002-architekturentscheid-ziel-stack.md` |
| Prototyp und synthetische Daten | `.claude/rules/prototyp.md` |
| Verfahrensgarantien, Protokoll, Klassifizierung | `.claude/rules/produktionscode.md` |
| ADR, Nachweise, Verfolgbarkeit, Glossar | `.claude/rules/dokumentation.md` |
| Rechtsregime, Aufbewahrung, Belegpflicht | `.claude/rules/recht-und-datenschutz.md` |
| Rollendateien, Hooks, Mechanismen | `.claude/rules/claude-konfiguration.md` |
| Rechte je Rolle | `docs/adr/0001-rollenmodell.md` |

## Sprache

Deutsch, Schweizer Schreibweise: `ss` statt `ß`. Anweisungen konkret und
überprüfbar formulieren — "vor jedem Commit `npm test` ausführen" statt
"Änderungen testen" (3.2).
````

## 6. Inhalt von `.claude/settings.json`

Wörtlicher Inhalt auf dem Stand der Erhebung:

```json
{
  "$schema": "https://json.schemastore.org/claude-code-settings.json",
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write|Edit|NotebookEdit",
        "hooks": [
          {
            "type": "command",
            "command": "bash \"${CLAUDE_PROJECT_DIR}/.claude/hooks/block-prototype-import.sh\"",
            "timeout": 15,
            "statusMessage": "Prüft Trennung Prototyp / Produktionscode (5.6)"
          }
        ]
      },
      {
        "matcher": "Write|Edit|NotebookEdit|Bash",
        "hooks": [
          {
            "type": "command",
            "command": "bash \"${CLAUDE_PROJECT_DIR}/.claude/hooks/block-main-write.sh\"",
            "timeout": 15,
            "statusMessage": "Prüft Schreibzugriff auf main (3.2 c)"
          }
        ]
      }
    ],
    "SessionStart": [
      {
        "matcher": "startup|resume|clear|compact",
        "hooks": [
          {
            "type": "command",
            "command": "bash \"${CLAUDE_PROJECT_DIR}/.claude/hooks/session-start-eingang.sh\"",
            "timeout": 10,
            "statusMessage": "Liest den Eingang aus dem Methodik-Repository (6.6)"
          }
        ]
      }
    ]
  }
}
```

Wirkung, geprüft gegen die Hook-Skripte unter `.claude/hooks/`:

| Hook | Ereignis | Skript | Zweck |
|---|---|---|---|
| Prototyp-Trennung | `PreToolUse` auf `Write`, `Edit`, `NotebookEdit` | `block-prototype-import.sh` | Blockiert Importe zwischen `prototype/` und Produktionscode in beide Richtungen (Projektauftrag 5.6) |
| main-Schutz | `PreToolUse` auf `Write`, `Edit`, `NotebookEdit`, `Bash` | `block-main-write.sh` | Blockiert Dateiänderungen bei ausgechecktem `main`/`master` sowie Bash-Befehle, die dorthin committen, mergen oder pushen (3.2 c) |
| Eingang Methodik | `SessionStart` (`startup`, `resume`, `clear`, `compact`) | `session-start-eingang.sh` | Gibt die Einträge aus `docs/EINGANG_METHODIK.md` als Sitzungskontext mit (6.6); blockiert nie |

Beide Gates prüfen zuerst, ob `jq` installiert ist, und blockieren mit
Rückgabewert 2 samt Meldung, falls es fehlt — sie lassen dann nicht
stillschweigend durch.

## 7. Automatisierung ausserhalb der Sandbox

`.github/workflows/nachweise-uebertragen.yml`: GitHub-Arbeitsablauf, der bei
einem Versionsschild (`v*`) oder von Hand (`workflow_dispatch`) das
Nachweisverzeichnis `docs/NACHWEISE.md` neu erzeugt
(`scripts/nachweise-erzeugen.sh`), auf Zweigverweise und unvollständige
Commit-Prüfsummen prüft und es in das Verzeichnis `nachweise/` des
Repositories `valITino/r3coscrum` (Repo B) überträgt. Zugriff über das
Repository-Secret `NACHWEISE_TOKEN`; geschrieben wird ausschliesslich nach
`nachweise/`. Ob der Arbeitsablauf bereits gelaufen ist, wurde nicht geprüft;
seit dem letzten Stand existiert im Repository kein Versionsschild-Auslöser,
der geprüft worden wäre (Tags wurden nicht abgefragt).

## 8. Offene Punkte auf dem Stand der Erhebung

Quelle: `docs/uebergaben/2026-08-20_r3-c-001-freigabe-und-nachfuehrung.md`
(jüngste Übergabedatei) und CLAUDE.md.

1. **Nächste Umsetzungseinheit: Grundgerüst** nach ADR 0002 Abschnitt 5
   (Backend Engineer und DevOps Engineer) — lauffähiger, fachlogikfreier
   Stand mit Makefile-Einstieg; danach R3-Q-001 und die übrigen
   Etappe-0-Einträge. `CHANGELOG.md` entsteht mit dem Grundgerüst.
2. **DoD-Gates fehlen:** `Stop`-/`SubagentStop`-/`TaskCompleted`-Kette
   (R3-Q-001, braucht die Befehle aus ADR 0002) und harte
   Rollen-Schreibgrenzen (R3-Q-005). Bis dahin prüft das menschliche Review
   die Befehlskette.
3. **O-4:** Der Backlog-Eintrag zu TheHive/Cortex wartet auf eine fachliche
   Angabe des Auftraggebers; Termin vor Etappe 2 (Product Owner).
4. Technische Bestätigung der DoD-Befehlskette samt der Befunde zu D10 und
   D12 durch DevOps Engineer und Auftraggeber, mit R3-Q-001; Schwellenwerte
   E-07/E-08.

## 9. Nicht geprüft

- Inhaltliche Richtigkeit der PDF `docs/01_Konzept_v1.0.pdf` (nicht geöffnet).
- Geschlossene Pull Requests über #4/#5 hinaus, Tags/Releases und Läufe des
  GitHub-Arbeitsablaufs (nicht abgefragt).
- Der Zustand des Zielrepositories `valITino/r3coscrum` (Repo B); es liegt
  ausserhalb des Zugriffs dieser Sitzung.
