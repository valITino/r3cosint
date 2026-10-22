# ADR 0003 — Definition-of-Done-Gate (R3-Q-001)

Verschoben am 2026-10-22 aus `docs/adr/0002-architekturentscheid-ziel-stack.md`, Abschnitt 6.12, unverändert (Prozess-Schnitt PS-2); Wortlaut dort bis zum Schnitt beim Commit `ac6e0c17672ad9f0d139a59dba8ca319f46056c4`.

## Teil B — Entscheidlog

### 6.12 Zwölfte Fortschreibung vom 2026-09-02 — das Definition-of-Done-Gate aus R3-Q-001, entworfen; Bau auf Weisung vom 2026-09-02 begonnen, förmliche Freigabe ausstehend

> **Status dieses Abschnitts: dem Auftraggeber am 2026-09-02 vorgelegt; der
> Bau ist am selben Tag auf seine Weisung begonnen worden; die förmliche
> Freigabe der Entscheidpunkte E-A bis E-K steht aus** (Wortlaut der Weisung,
> Lesart und umgesetzte Optionen in Abschnitt 10; Formweg: Merge des Pull
> Requests dieses Arbeitszweigs oder Anweisung mit exaktem Wortlaut). Bis zur
> Weisung war kein Hook-Skript, keine Liste terminierter Lagen und keine
> Änderung an `.claude/settings.json` oder am `Makefile` entstanden. Die
> Einträge dieser Fortschreibung in den Abschnitten 8 und 9 tragen denselben
> Vermerk.

**Anlass.** Der Auftraggeber hat am 2026-09-02 angewiesen, die Gates aus
R3-Q-001 als Fortschreibung dieses Abschnitts **vor** dem Bau vorzulegen. Der
Grund liegt in diesem Abschnitt selbst: Er legt seit dem 2026-08-20 fest, dass
der Hook aus R3-Q-001 **diesen einen Befehl** `make dod` aufruft, dass nur
Rückgabewert 2 blockiert, dass ein Reentranz-Schutz über `stop_hook_active`
greift und dass nach dreimaligem Scheitern am gleichen Kriterium eskaliert wird
(3.4). Was er nicht festlegt, ist das Entscheidende: **wie das Gate die
Ausgabe von `make dod` liest.** Vier Fragen sind daran offen, und jede von
ihnen entscheidet zwischen einem Gate, das ab sofort jede Arbeitseinheit
blockiert, und einem, das nichts wert ist.

**Beleglage dieser Fortschreibung — was worauf beruht.** Wie in 6.8, 6.9 und
6.11 wird getrennt, worauf welche Aussage beruht. Diese Rolle hat **nichts
ausgeführt**; sie hat kein Ausführungswerkzeug und prüft ihre eigene Arbeit
ohnehin nicht (3.4).

| Herkunft | Was |
|---|---|
| **Gelesen** (diese Rolle, am 2026-09-02) | `CLAUDE.md`; `docs/00_Projektauftrag.md`, Abschnitte 3.3 und 3.4; `docs/05_Product_Backlog.md`, Eintrag R3-Q-001 mit beiden Achtung-Hinweisen und die offenen Punkte des Backlogs, Nummer 16; `docs/06_Definition_of_Ready_und_Done.md`, Teil 2 vollständig; dieser Abschnitt 6 vollständig einschliesslich 6.1 bis 6.11; vom `Makefile` der Kopfkommentar, der Variablenblock, das Makro `KLASSIFIZIEREN`, die Ziele `belege`, `abnahme` und `dod` vollständig; `.claude/hooks/block-main-write.sh` vollständig; `.claude/rules/claude-konfiguration.md`, Abschnitt "Hooks"; `scripts/belege-ausnahmen.txt`; `methodik/entscheide.md` des Methodik-Repositories, Einträge V9 bis V13, S4 und S5; die offizielle Hook-Dokumentation `https://code.claude.com/docs/en/hooks.md`, abgerufen am 2026-09-02, in den Abschnitten "Stop", "SubagentStop", "TaskCompleted", "Exit code output", "Timeouts", "Exit code 2 behavior per event", "JSON output", "Common input fields", "Common fields", "Matcher patterns" und "Reference scripts by path" |
| **Selbst gemessen ohne Ausführung** | Die Zeichenkette `LAGE C:` kommt im `Makefile` **53-mal** vor. Über alle **21** Rollendateien unter `.claude/agents/`: `static-software-tester` und `pentester` tragen `tools: Read, Grep, Glob, Bash, Skill` — also `Bash`, aber weder `Edit` noch `Write` —, und in allen 21 Dateien ist das Frontmatter-Feld `name:` mit dem Dateinamen gleich. `CLAUDE_CODE_STOP_HOOK_BLOCK_CAP` steht an **drei** Stellen des Repositories: `docs/00_Projektauftrag.md` (3.4), `docs/06_Definition_of_Ready_und_Done.md` ("Durchsetzung") und `docs/adr/0001-rollenmodell.md`. Das sind Textsuchen über Dateien, keine Läufe |
| **Fremdbeleg** (Läufe des Koordinators vom 2026-09-02, hier übernommen und nicht nachgeprüft) | Die Umgebung der Sitzung (`CLAUDE_CODE_REMOTE=true`, `CLAUDE_PROJECT_DIR` wird an Hooks exportiert, `HOME=/root`, GNU Make 4.3, bash 5.2.21, jq 1.7, `timeout` und `flock` vorhanden, `git` vorhanden, `gitleaks` fehlt, `uv` und `ruff` vorhanden, kein `backend/`, kein `frontend/`, kein `deploy/`); der flache Klon und seine 31 Funde gegenüber 1 Fund nach `git fetch --unshallow`; der eine Fund auf `origin/main` in jedem frischen Klon; der gemessene Lauf von `make dod` (5,8 s, Rückgabewert 2, Abbruch bei D20); die Form der Ausgabe, soweit sie einen Lauf voraussetzt; die parallel schreibenden Subagenten dieser Sitzung |
| **Nicht behauptet, weil nicht belegt** | Ob es eine Umgebungsvariable `CLAUDE_CODE_STOP_HOOK_BLOCK_CAP` gibt (6.12.2, O-19); wie lange die Kette mit dem Grundgerüst läuft (O-20); ob ein Scheinbaum mit dem echten Belegprüfer grün wird (6.12.19) |
| **Berichtigt nach Runde 1 der Prüfung** | Die erste Fassung dieses Entwurfs führte hier zusätzlich, die Referenz sage nicht, ob eine Änderung an `.claude/settings.json` in der laufenden Sitzung wirke. **Das ist falsch:** Sie sagt es, im Abschnitt zur Einrichtung der Hooks — "Direct edits to hooks in settings files are normally picked up automatically by the file watcher." Die Angabe ist berichtigt; der Entscheid zum Selbsttest (6.12.19) bleibt bestehen, trägt aber jetzt die Gründe, die ihn wirklich tragen, statt eines Schweigens, das es nicht gab |

Diese Trennung steht hier aus demselben Grund wie in 6.8: Eine Aussage über die
Herkunft, die stärker ist, als die Quelle sie trägt, ist die Fehlerklasse, an
der in diesem Projekt bereits zwei Arbeitseinheiten nach 3.4 abgebrochen sind
(V11, V12).

**Runde 1 der Prüfung, eingearbeitet am 2026-09-02.** Vier Prüflinsen auf einem
anderen Modell als die Umsetzung und eine Nachprüfung des Koordinators am
Bestand haben gegen die erste Fassung dieses Abschnitts **dreizehn** Befunde
gebracht, darunter einen blockierenden inneren Widerspruch (6.12.14). Alle
dreizehn sind hier eingearbeitet; die betroffenen Stellen tragen den Vermerk
**Runde 1**, und keine frühere Aussage ist gelöscht, sondern berichtigt. Das ist
V11 in Anwendung: Eine Behebung ist nicht fertig, wenn der Befund weg ist,
sondern wenn die Schicht geprüft ist, die sie erreichbar gemacht hat — deshalb
sind mit den Befunden auch die Stellen nachgeführt worden, die sie erst
erreichbar gemacht haben (die Objekttabelle in Abschnitt 6 für G16, die
Übersichtstabelle in 6.12.1 für G10).

**Ein gemessener Stand, und weshalb er ein vergangener ist.** Als
**Fremdbeleg** kommt aus dieser Runde hinzu: Der Koordinator hat am 2026-09-02
den ortsgebundenen Ausnahmeeintrag für den Fund aus 6.12.17 angelegt und danach
`scripts/belege-pruefen.sh` laufen lassen — **0 Befunde, Rückgabewert 0**,
gemessen **vor** dem Anlegen dieses Abschnitts; der Eintrag ist zum Zeitpunkt
dieser Fortschreibung **noch nicht committet**. Dieser Stand gilt für den
damaligen Bestand und nicht für den heutigen: Dieser Abschnitt nennt selbst zwei
Dateien, die erst mit dem Bau entstehen — `.claude/hooks/dod-gate.sh` und
`.claude/hooks/dod-gate-terminierte-lagen.txt` —, und jede Nennung eines noch
nicht bestehenden Pfades ist für D20 ein Fund. Das ist kein Fehler des Textes,
sondern der vorgesehene Fall: Er wird durch zwei ortsgebundene Ausnahmen der
Form `datei|wert` gedeckt, die der Koordinator als Umsetzung nach 6.8.5 anlegt
und die mit dem Entstehen der beiden Dateien wieder zu **entfernen** sind — die
Selbstprüfung "der Gegenstand existiert inzwischen" macht sie dann selbst zum
Befund (6.8.5, Eigenschaft 3). Genau so soll es sein: Ein Entwurf, der Artefakte
beschreibt, die es noch nicht gibt, hinterlässt eine Spur, die sich beim Bau von
selbst wieder schliesst.

#### 6.12.1 Überblick über die Entscheide dieser Fortschreibung

| Nr. | Gegenstand | Entscheid | Unterabschnitt |
|---|---|---|---|
| G1 | Die drei Ereignisse und wer die Zusicherung trägt | Ein Skript für `Stop`, `SubagentStop` und `TaskCompleted`, kein Matcher; die harte Zusicherung "nicht abschliessbar" trägt allein `TaskCompleted` — und nur in einer Sitzung, in der überhaupt eine Aufgabenliste geführt wird *(Runde 1, terminiert als O-23)* | 6.12.2 |
| G2 | Was das Gate liest | Die Ausgabe von `make dod`, nicht nur den Rückgabewert; zwei voneinander unabhängige Kriterien, wie sie die Kette für ihre eigenen Schritte schon verlangt *(Nachtrag 6.12.24 k: dazu die Zahl der gelesenen Marken gegen die Zahl, die die Schlusszeile selbst nennt, und mindestens eine Marke — weiterhin ohne eigene Zahl im Gate)* | 6.12.3 |
| G3 | Befund gegen Ausfall (Frage 1) | Unterschieden wird an der **Lage der Marke**, nicht am Rückgabewert und nicht am Meldungstext *(Nachtrag aus dem Bau, 6.12.23: Verstösse gegen die Selbstprüfungen der terminierten Lagen zählen unter `LISTE …`, ein Widerspruch zwischen Rückgabewert 0 und Schlusszeile unter `KETTE schlusszeile-widerspruch`; **Nachtrag 6.12.24:** ein Widerspruch zwischen der Baumzeile der Kette und dem vom Gate bestimmten Baum unter `KETTE baum-widerspruch`)* | 6.12.4 |
| G4 | Lage C (Frage 2) | **Terminierte Lagen C**: eine versionierte, selbstprüfende Liste neben dem Hook; sechs Selbstprüfungen, jede blockierend | 6.12.5 |
| G5 | Der blinde Fleck hinter dem ersten C | Die Kette bricht bei Lage C **nicht mehr ab**, sondern läuft weiter und sammelt; abgebrochen wird weiterhin bei einem Befund | 6.12.6 |
| G6 | Woran das Gate das fehlende Prüfmittel erkennt | Die Lage-Marke trägt es **strukturiert** (`FEHLT=<pfad>`), nicht der Meldungstext; ein C-Zweig ohne Angabe fällt geschlossen | 6.12.7 |
| G7 | Die Schlusszeilen von `make dod` | **Vier** eindeutige Formen, eine eigenständige D19-Zeile, eine Zeile, die den geprüften Baum nennt *(die vierte Form — vollständig gelaufen, aber D19 mit Befund — ist Nachtrag aus dem Bau, 6.12.23)* | 6.12.8 |
| G8 | Zählung und Eskalation (Frage 3) | Zustand ausserhalb des Arbeitsbaums, Schlüssel ist das Kriterium — bei mehreren Abweichungen die erste in Kettenreihenfolge; das dritte Mal verlangt die Übergabedatei, ab dem vierten lässt sie durch, aber **nur** bei `Stop` und `SubagentStop`, nicht bei `TaskCompleted` *(beides Runde 1)*; **fehlt `jq`, blockiert das Gate, kann den Block aber nicht zählen — benannte Grenze** *(Nachtrag aus dem Bau, 6.12.23)*; der Durchlass ab dem vierten Mal löscht den Zähler **nicht**, und ein **nicht bestimmbares** Zustandsverzeichnis erzeugt keinen eigenen Ausgang *(Nachtrag 6.12.24)* | 6.12.9 |
| G9 | `stop_hook_active` (Frage 4) | Rückgabewert 0, wie 3.4 und der Backlog es wörtlich verlangen — **ohne** den Zähler zu verändern; die Folge daraus wird ausgesprochen | 6.12.10 |
| G10 | Prüfmittel des Gates | Sieben, namentlich aufgezählt. **Sechs** davon sind Lage C des Gates und enden mit 2, wenn sie fehlen; das siebte — das Zustandsverzeichnis — hat **keinen eigenen Ausgang**, weil es allein das Zählwerk trägt und nicht das Urteil *(Runde 1: die frühere Fassung dieser Zeile sagte "fehlt eines" und widersprach damit 6.12.11)*. **Nachtrag 6.12.24:** Mit `sha256sum` und `mktemp` führt die Tabelle **acht** blockierende Prüfmittel und neun insgesamt | 6.12.11 |
| G11 | Zeitüberschreitung | Zwei Grenzen: 900 s in `settings.json`, 600 s für die Kette im Skript, 120 s Wartezeit auf die Sperre | 6.12.12 |
| G12 | Der geprüfte Arbeitsbaum, Nebenläufigkeit | Der Baum wird über `git` bestimmt, nicht über einen Verzeichnisnamen; eigene Läufe werden über `flock` serialisiert, die Sperrdatei liegt ausserhalb des Baums *(Nachtrag 6.12.24: der geprüfte Baum ist die **physisch aufgelöste Wurzel** des Arbeitsbaums; Sperr- und Wegwerfdatei liegen nachweislich ausserhalb des Baums, notfalls fest unter `/tmp`)* | 6.12.13 |
| G13 | `SubagentStop` und Rollen ohne Schreibrecht | Das Gate liest den **Gegenstand** — hat diese Rolle ein Werkzeug, über das ADR 0001 Schreibrecht vergibt, also `Edit`, `Write` oder `NotebookEdit`? — und läuft für Rollen ohne ein solches Werkzeug gar nicht erst. `Bash` zählt **nicht** dazu *(Runde 1, blockierender Befund; Begründung und benannte Grenze in 6.12.14)*. Die Rolle wird über das Frontmatter-Feld `name:` aufgelöst, nicht über den Dateinamen | 6.12.14 |
| G14 | Sichtbarkeit | Jeder Durchlass, der kein sauberes Grün ist, meldet sich über `systemMessage`; kein `continue: false`; kein eigenes Protokoll des Gates | 6.12.15 |
| G15 | Kein Zwischenspeicher des Urteils | Das Gate läuft bei jedem Ereignis; ein gespeichertes Urteil wäre ein Urteil über einen vergangenen Lauf | 6.12.16 |
| G16 | Flacher Klon | Die Vollständigkeit der Git-Historie wird **Prüfmittel von D20**; ein flacher Klon ist Lage C mit Beschaffungsweg | 6.12.17 |
| G17 | Der Selbsttest | Formprüfungen gegen eine Attrappe, dazu je ein roter und ein grüner Lauf gegen das **echte** Makefile *(Nachtrag 6.12.24: alle acht Kombinationen der D19-Zeile, die **echten** Rollendateien im G13-Fall, eigene Fälle für G12 und für die Nachträge dieses Abschnitts)* | 6.12.19 |

**Was diese Fortschreibung nicht tut.** Sie baut nichts. Sie legt keine Datei
an ausser dieser. Die Umsetzung liegt beim DevOps Engineer (Makefile,
Hook-Skript, `settings.json`), die Verifikation beim Static und beim Dynamic
Software Tester auf einem anderen Modell als die Umsetzung (3.4).

**Drei Nachträge aus dem Bau vom 2026-09-02** — drei Stellen, an denen dieser
Entwurf keinen Fall vorsieht — sind in **6.12.23** entschieden; die betroffenen
Zeilen dieser Tabelle und der Unterabschnitte 6.12.3, 6.12.4, 6.12.8, 6.12.9
und 6.12.22 tragen den Vermerk "(Nachtrag aus dem Bau, 6.12.23)" an Ort.

**Zehn weitere Entscheide und ein Vermerk zur Beleglage** — aus der statischen
und der dynamischen Verifikation des gebauten Gates vom 2026-09-02, beide
Runden **nicht bestanden** (Fremdbeleg) — stehen in **6.12.24**. Die übrigen
Befunde jener Prüfungen behebt der DevOps Engineer im Code, ohne dass dieser
Entwurf zu ändern wäre; nachgetragen wird hier nur, wo der Entwurf schweigt oder
zu wenig sagt. Die betroffenen Zeilen dieser Tabelle und der Unterabschnitte
6.12.3, 6.12.4, 6.12.9, 6.12.11, 6.12.13, 6.12.15 und 6.12.19 tragen den
Vermerk "(Nachtrag 6.12.24)" an Ort.

**Ein Entscheid des Auftraggebers vom 2026-09-03 zu O-24** steht in **6.12.25**:
Die Prüftabelle von G17 führt seither je Zeile **genau eine** messbare
Zusicherung mit einer dauerhaften Kennung `Z-nnn`, und der Selbsttest trägt je
Kennung genau eine Prüfung; die Deckung zwischen Tabelle und Selbsttest wird
mechanisch in beide Richtungen geprüft. Dazu vier Behebungen aus Runde 3 —
S3-01, DT3-B1, S3-05 und die beiden fehlenden Zusicherungen aus S3-02 und
S3-07. Die Tabelle in 6.12.19 ist an Ort neu gefasst, 6.12.24 f trägt einen
Vermerk an Ort. Kein Entscheid G1 bis G17 wird dadurch zurückgenommen.

**Nach der vierten Prüfrunde vom 2026-09-03** ist 6.12.25 um die Buchstaben
**f) bis k)** fortgeschrieben — dynamisch bestanden, statisch nicht bestanden,
blockierend S4-01: Jede Zusicherung nennt neu ihren **Messumfang** (Kanal,
Ereignis, wo nötig Anzahl), und die Prüfung misst genau diesen Umfang (f);
`Z-129` ist berichtigt (g), `Z-110` zurückgezogen und `Z-111` auf den ganzen
geprüften Baum erweitert (h); **jeder** Block mit Schlüssel `GATE <Prüfmittel>`
läuft über die Zählung nach 6.12.9, einzige Ausnahme bleibt `GATE jq` (i); der
Selbsttest ist gegen Nebenläufigkeit gesperrt (j); k) hält die Beleglage fest.
Die Tabelle in 6.12.19 führt seither `Z-001` bis `Z-153`, davon `Z-110`
zurückgezogen. Den Stand danach belegt erst eine **fünfte** Prüfrunde.

**Nach der fünften Prüfrunde vom 2026-09-03** — statisch und dynamisch nicht
bestanden, blockierend S5-01 und DT5-01, fünfter Auftritt derselben
Fehlerklasse — steht der Entscheid des Auftraggebers zu **O-25** in
**6.12.26**: Die Tabelle 6.12.19 trägt neu die Spalten **Kanal** (fester,
abschliessender Wertevorrat, vom Selbsttest mitgemeldet und mechanisch
abgeglichen) und **Mutation** (je Zusicherung die Änderung, die genau sie
fehlschlagen lassen muss, ausführbar in `scripts/dod-gate-mutationen.txt` und
geprüft im Modus `--mutationen`). Dazu die vier Befunde der fünften Runde als
Entscheide (c) und die Beleglage als Fremdbeleg (d). Den Stand danach belegt
erst die **sechste** Prüfrunde.

#### 6.12.2 G1 — Die drei Ereignisse, und welche Ebene welche Zusicherung trägt

| | |
|---|---|
| **Vorher galt** | Der Backlog verlangt `Stop`-, `SubagentStop`- und `TaskCompleted`-Hook in der versionierten `.claude/settings.json`; Projektauftrag 3.4 ordnet sie den Ebenen 2 und 3 zu. Welche der drei Ebenen welche Zusicherung trägt, stand nirgends |
| **Jetzt gilt** | Ein Skript `.claude/hooks/dod-gate.sh` bedient alle drei Ereignisse und verzweigt über das Eingabefeld `hook_event_name`. Die harte Zusicherung "die Aufgabe lässt sich nicht abschliessen" trägt **allein `TaskCompleted`**. `Stop` und `SubagentStop` leisten eine erzwungene Fortsetzung mit Begründung je Beendigungsversuch — nicht mehr, und das ist zu wissen |

**Weshalb ein Skript und nicht drei.** Drei Dateien, die dieselbe Kette
auswerten, sind drei Stellen, an denen dieselbe Aussage verschieden stehen
kann. Genau diesen Fehler hat dieser Abschnitt bereits dreimal behoben — die
Objektbedingung stand zweimal verschieden (6.2.2), das Prüfmittel von D19 stand
zweimal verschieden (6.9.1), die Ausführungsreihenfolge stand zweimal und war
veraltet (6.11.3 b). V13 zieht daraus den allgemeinen Satz: Eine Angabe, die
nichts steuert, sondern etwas anderes wiederholt, wird gestrichen. Für ein Gate
gilt er erst recht.

**Weshalb kein Matcher.** Die gelesene Referenz führt `Stop` und
`TaskCompleted` in der Matcher-Tabelle unter "no matcher support — always fires
on every occurrence"; `SubagentStop` kann auf den Rollennamen (`agent_type`)
filtern. Ein Matcher mit neunzehn Rollennamen in `settings.json` wäre eine
zweite Kopie der Rechtetabelle aus ADR 0001 und veraltete mit der ersten
Rollenänderung, ohne dass es auffiele. Die Unterscheidung gehört an den
Gegenstand, nicht an eine Namensliste — siehe G13.

**Die Zusicherung, ehrlich zugeordnet.** Die gelesene Referenz sagt zu `Stop`
und `SubagentStop`: "The `stop_hook_active` field is `true` when Claude Code is
already continuing as a result of a stop hook." Wenn das Gate bei gesetztem
Feld mit 0 endet — und das verlangen Projektauftrag 3.4, Ebene 4, und das
Abnahmekriterium von R3-Q-001 wörtlich —, dann erzwingt ein Stop-Gate je
Beendigungsversuch **genau eine** Fortsetzung: Block, Fortsetzung, und der
nächste Stop dieser Fortsetzung wird durchgelassen, auch wenn die Kette rot
bleibt. Zwei aufeinanderfolgende Blocks innerhalb derselben Fortsetzung sind
dann unmöglich.

Daraus folgt zweierlei, und beides gehört ausgesprochen statt später entdeckt:

1. **Die in der Referenz genannte Obergrenze — "Claude Code overrides the hook
   and ends the turn after 8 consecutive blocks" — ist mit diesem Entwurf
   innerhalb eines Beendigungsversuchs unerreichbar.** Sie wird deshalb für
   nichts gebraucht, und der Entwurf stützt sich an keiner Stelle auf sie.
2. **"Dreimal am gleichen Kriterium" (3.4) zählt über Beendigungsversuche
   hinweg**, nicht innerhalb eines einzelnen. Der Zähler aus G8 ist deshalb
   nicht Beiwerk, sondern die einzige Stelle, an der die Eskalationsregel aus
   3.4 überhaupt greifen kann.

Für `TaskCompleted` sagt die Referenz: Bei Rückgabewert 2 "the task is not
marked as completed and the stderr message is fed back to the model as
feedback". Sie führt `stop_hook_active` ausschliesslich bei `Stop` und
`SubagentStop` als zusätzliches Eingabefeld auf; für `TaskCompleted` nennt sie
es nicht. Damit prüft `TaskCompleted` **jeden** Abschlussversuch erneut, ohne
Reentranz-Ausnahme — und trägt als einziges der drei Ereignisse die Zusicherung
aus dem Abnahmekriterium von R3-Q-001. Wer das Gate beurteilt, beurteilt
zuerst `TaskCompleted`; `Stop` und `SubagentStop` sind die laute, frühe
Rückmeldung, nicht die Sperre.

**Und damit steht und fällt die Zusicherung mit einer Voraussetzung, die
niemand festgelegt hat** *(Runde 1)*. Die gelesene Referenz sagt, wann
`TaskCompleted` überhaupt feuert: "when any agent explicitly marks a task as
completed through the TaskUpdate tool, or when an [agent team] teammate
finishes its turn with in-progress tasks". In einer Sitzung, in der keine
Aufgabenliste geführt wird, feuert das Ereignis **nie** — und dann gilt die
harte Zusicherung für nichts. Was bliebe, wären `Stop` und `SubagentStop` mit
je einer erzwungenen Fortsetzung, also genau das, was oben ausdrücklich als
nicht tragend bezeichnet ist.

Das ist keine Kleinigkeit am Rand, sondern die Bedingung, unter der dieser
Entwurf das leistet, was der Backlog von ihm verlangt. Zwei Wege stehen offen,
und die Wahl liegt nicht bei dieser Rolle:

1. **Jede Arbeitseinheit wird als Aufgabe geführt.** Dann feuert
   `TaskCompleted` verlässlich, und die Zusicherung greift. Der Ort dafür ist
   `CLAUDE.md` oder `.claude/rules/claude-konfiguration.md`, und es wäre eine
   Vorschrift an das Vorgehen, nicht an die Architektur — Abschnitt 9 führt sie
   als Nachführung unter Vorbehalt.
2. **Es bleibt dabei, dass Aufgabenlisten fakultativ sind.** Dann ist
   auszusprechen, dass die Definition-of-Done-Kette in solchen Sitzungen nicht
   erzwungen, sondern nur laut angemahnt wird, und dass der Nachweis dort am
   menschlichen Review hängt.

Entschieden wird das vom Auftraggeber; der Punkt ist als **O-23** terminiert.
Er wird hier nicht stillschweigend in die eine oder andere Richtung
vorweggenommen — eine Zusicherung, deren Voraussetzung ungeklärt ist, ist genau
die Zusicherung ohne Deckung aus V12.

#### 6.12.3 G2 — Das Gate liest die Ausgabe, nicht nur den Rückgabewert

| | |
|---|---|
| **Vorher galt** | "Der Hook aus R3-Q-001 ruft **diesen einen Befehl** auf. … nur Rückgabewert 2 blockiert" — über die Auswertung stand nichts |
| **Jetzt gilt** | Das Gate wertet zwei voneinander unabhängige Dinge aus: den Rückgabewert des Aufrufs **und** die Ausgabe von `make dod`, namentlich die Lage-Marken der Übersicht, die D19-Zeile und die Schlusszeile. Fehlt eines von beiden oder widersprechen sie sich, blockiert das Gate |

**Weshalb nicht der Rückgabewert allein.** Das ist keine neue Vorsicht, sondern
die Regel, die `make dod` seit dem 2026-08-30 für seine eigenen Unterschritte
anwendet und im Makefile begründet: Zwei Kriterien entscheiden je Schritt, der
eigene Rückgabewert **und** eine eigene, passende Lage-Marke, weil ein
Rückgabewert allein sich mit `-i/--ignore-errors` und mit einem umgebogenen
Unter-Make-Aufruf erzeugen lässt. Ein Gate, das sich auf denselben einen Wert
verlässt, den die Kette selbst für unzureichend hält, wäre die schwächste
Stelle der ganzen Anordnung.

**Was das Gate von `make dod` übernimmt und was es selbst prüft.** Es übernimmt
die Markenprüfung: `make dod` erzeugt je Aufruf eine nicht vorhersagbare
Lauf-Kennung, reicht sie ausschliesslich über die Umgebung an den jeweiligen
Unter-Make-Aufruf weiter und akzeptiert nur Marken mit genau dieser Kennung.
Diese Kennung ist dem Aufrufer vorher nicht bekannt (Fremdbeleg); das Gate kann
sie also nicht selbst prüfen und muss es auch nicht — es liest sie aus der
Ausgabe und verlangt, dass **alle** Marken der Übersicht dieselbe tragen. Was
das Gate selbst prüft, ist die Form: die Übersichtszeile, genau eine der **vier**
Schlusszeilen aus G7 *(Nachtrag aus dem Bau, 6.12.23; bis dahin drei)*, genau
eine D19-Zeile, und keine Marke der Lage `A_FAIL`. Ein Rückgabewert 0 zusammen
mit einer anderen Schlusszeile als der ersten Form ist ein Widerspruch und
blockiert *(Nachtrag aus dem Bau, 6.12.23)*.

**Was das Gate ausdrücklich nicht zählt.** Es zählt **nicht** die Zahl der
Kettenschritte. Diese Zahl steht im Makefile in einer eigenständigen Liste
(`ERWARTETE_KETTENSCHRITTE`) und wird dort gegen die Zielliste geprüft; `make
dod` sagt in seiner Schlusszeile selbst, dass die Zählung aufging. Eine zweite
Zahl im Gate wäre eine Angabe, die nichts steuert und beim nächsten
Kettenschritt falsch wird — V13, und die Tautologie aus Befund A3, die im
Makefile bereits einmal behoben werden musste. Das Gate liest die **Aussage**,
nicht die Zahl. *(Nachtrag 6.12.24 k: Es führt weiterhin **keine eigene** Zahl.
Es vergleicht aber die Zahl, die die Schlusszeile der Kette selbst nennt, mit
der Zahl der gelesenen Marken und verlangt mindestens eine Marke — geprüft wird
die Selbstaussage der Kette gegen ihren Inhalt, nicht gegen eine Erwartung des
Gates.)*

#### 6.12.4 G3 — Frage 1: Wie das Gate einen Befund von einem ausgefallenen Prüfmittel unterscheidet

**Der Massstab ist die Lage, nicht der Rückgabewert und nicht der Text.** Die
Lagen A, B und C sind seit dem 2026-08-30 die Begriffe dieser Kette, jede
Marke trägt sie, und Regel 4 aus 6.2.2 verlangt ohnehin, dass die Lage
ausgegeben und nicht erschlossen wird. Genau dafür ist sie da.

| Beobachtung in der Ausgabe von `make dod` | Art | Schlüssel des Kriteriums | Ausgang des Gates |
|---|---|---|---|
| Eine Marke endet auf `A_FAIL` | **Befund** | `<D> <ziel> A_FAIL` | blockiert |
| Eine Marke endet auf `C` und ist durch einen gültigen Eintrag der terminierten Lagen gedeckt (G4) | **Ausfall, terminiert** | — | lässt durch, mit `systemMessage` |
| Eine Marke endet auf `C` und ist nicht gedeckt | **Ausfall** | `<D> <ziel> C <fehlendes Prüfmittel>` | blockiert |
| Eine Zeile der Übersicht trägt keine Marke | nicht nachweisbar gelaufen | `KETTE marke-fehlt <D> <ziel>` | blockiert |
| Die D19-Zeile meldet `VERLETZT` | **Befund** | `D19 VERLETZT` | blockiert |
| Die D19-Zeile meldet Lage C | **Ausfall** | `D19 C` | blockiert |
| Die D19-Zeile meldet Lage B, obwohl das Gate einen Arbeitsbaum bestimmt hat *(Nachtrag 6.12.24, Befund S-01: Dieser Schlüssel hat **Vorrang** vor der Konsistenzwache "Rückgabewert 0 mit einer Abweichung"; sonst zählte derselbe Fall als `KETTE ausgabe-unlesbar` und die Meldung sagte das Falsche)* | Widerspruch | `D19 B-widerspruch` | blockiert |
| Keine Übersichtszeile oder keine der **vier** Schlusszeilen aus G7 *(Nachtrag aus dem Bau, 6.12.23; bis dahin drei)* | nicht nachweisbar gelaufen | `KETTE ausgabe-unlesbar` | blockiert |
| Rückgabewert 0, aber eine andere Schlusszeile als Form 1 aus G7 *(Nachtrag aus dem Bau, 6.12.23)* | Widerspruch | `KETTE schlusszeile-widerspruch` | blockiert |
| Die erste Zeile der Kette (`make dod: geprueft wird <PROJ>.`) nennt einen anderen Baum als den vom Gate bestimmten *(Nachtrag 6.12.24; Befund S-10: eine **fehlende** Baumzeile ist dagegen `KETTE ausgabe-unlesbar` — sie nennt keinen anderen Baum, sondern gar keinen)* | Widerspruch | `KETTE baum-widerspruch` | blockiert |
| Rückgabewert weder 0 noch 2 | nicht nachweisbar gelaufen | `KETTE rueckgabewert=<N>` | blockiert |
| Die Kette reisst das innere Zeitlimit (G11) | nicht nachweisbar gelaufen | `KETTE zeitueberschreitung` | blockiert |
| Eine Zeile der terminierten Lagen verletzt die Selbstprüfung 2, 3 oder 5 (G4) *(Nachtrag aus dem Bau, 6.12.23)* | **Fehler der Liste** | `LISTE <Nummer der Selbstpruefung> <D> <ziel>` | blockiert |
| Eine Zeile der terminierten Lagen verletzt die Selbstprüfung 4 oder 6 (G4) *(Nachtrag aus dem Bau, 6.12.23)* | **Fehler der Liste** | `LISTE <Nummer der Selbstpruefung> <Zeilennummer>` | blockiert |
| Ein Prüfmittel des Gates fehlt (G10) | **Lage C des Gates** | `GATE <fehlendes Prüfmittel>` | blockiert |
| Die Eingabe auf der Standardeingabe ist kein gültiges JSON *(Nachtrag vom 2026-09-07, 6.12.28 e, Befund `DT11-11`)* | **Eingabe unlesbar** | `EINGABE json` | blockiert, ohne zu zählen |
| Das Ereignis der Eingabe ist unbekannt oder wird von diesem Gate nicht bedient *(Nachtrag vom 2026-09-07, 6.12.28 e, Befund `DT11-11`)* | **Eingabe nicht bedient** | `EINGABE ereignis` | blockiert, ohne zu zählen |
| Weder `CLAUDE_PROJECT_DIR` noch das Eingabefeld `cwd` ergeben einen bestimmbaren Arbeitsbaum *(Nachtrag vom 2026-09-07, 6.12.28 e, Befund `DT11-11`)* | **Eingabe unbestimmt** | `EINGABE baum` | blockiert, ohne zu zählen |
| Ein anderer Lauf hält die Sperre für diesen Baum länger als die im Gate genannte Wartezeit *(Nachtrag vom 2026-09-07, 6.12.28 e, Befund `DT11-11`)* | **Sperre belegt** | `SPERRE belegt` | blockiert, ohne zu zählen |

**Die Zeile für die Selbstprüfung 1 der terminierten Lagen steht bereits in
dieser Tabelle** *(Nachtrag aus dem Bau, 6.12.23)*: Eine gemeldete Lage C ohne
Eintrag ist kein Fehler der Liste, sondern eine ungedeckte Lage C, und zählt
unverändert unter `<D> <ziel> C <fehlendes Prüfmittel>`. Nur die
Selbstprüfungen 2 bis 6 brauchten einen eigenen Schlüssel.

**Nachtrag vom 2026-09-07 (6.12.28 e): die vier Pfade vor der Eingabe und der
Sperrpfad.** Die vier letzten Zeilen der Tabelle sind neu. Sie klassifizieren
Lagen, in denen das Gate blockiert, **bevor** es urteilen kann: unlesbare
Eingabe, nicht bedientes Ereignis, nicht bestimmbarer Arbeitsbaum und eine von
einem anderen Lauf gehaltene Sperre. Alle vier blockieren seit dem Bau mit
Rückgabewert 2; **neu ist allein, dass sie ihren Schlüssel nennen** (Befund
`DT11-11`, Fremdbeleg aus Runde 11). Sie tragen bewusst **nicht** den Stamm
`GATE`, der nach dieser Tabelle "ein Prüfmittel des Gates fehlt" bedeutet.
**Gezählt wird an ihnen nicht** — die drei Vor-Eingabe-Pfade können es nicht
(die `session_id` ist dort noch nicht gelesen), und für die beiden übrigen wäre
es ein Verhaltenswechsel, den 6.12.28 e ausschliesst. Die Aussage `E23` in
6.12.9 nennt deshalb alle **fünf** nicht gezählten Blockpfade; `E12` bleibt im
Wortlaut stehen und wird durch `E23` präzisiert, nicht ersetzt (6.1.2).

**Der tragende Satz: Alles ausser einem belegten Grün blockiert.** Ein belegtes
Grün liegt vor, wenn die Kette **vollständig gelaufen** ist (eine der **drei**
Vollständigkeits-Schlusszeilen aus G7 — Form 1, 2 oder 4; *Nachtrag aus dem
Bau, 6.12.23, bis dahin zwei*), **keine** Marke `A_FAIL` zeigt, die D19-Zeile
ohne Befund ist und **jede** Marke der Lage C durch einen gültigen Eintrag
gedeckt ist. Über Form 4 kann ein belegtes Grün nie zustande kommen: Sie setzt
einen D19-Befund voraus, und der schliesst das Grün nach demselben Satz aus. Jeder andere Ausgang blockiert — auch der, den niemand
vorhergesehen hat. Das ist die Richtung, in die ein Gate irren darf: falsch rot
ist sichtbar, ortsgebunden behandelbar und unterliegt der Eskalation aus 3.4;
falsch grün ist die gefährliche Richtung (6.8.4, Punkt 3).

**Weshalb die Unterscheidung überhaupt gebraucht wird.** Sie steuert dreierlei:
den Schlüssel des Zählers (G8) — ein Befund und ein Ausfall am selben Schritt
sind nicht dasselbe Kriterium; die Meldung, die an die Rolle zurückgeht — bei
einem Befund ist etwas zu beheben, bei einem Ausfall ist ein Prüfmittel zu
beschaffen; und den einen Fall, in dem das Gate durchlässt (G4). Ohne sie wäre
das Gate genau der Fehlermodus, den 6.11.1 belegt hat: rot mit falscher
Begründung.

#### 6.12.5 G4 — Frage 2: Was bei Lage C geschieht

**Die Lage, in der entschieden wird.** *(Nach Runde 1 präzisiert; die erste
Fassung schrieb pauschal "am Bestand von `origin/main` ist heute D20 grün" und
widersprach damit 6.12.17.)* Zu unterscheiden sind zwei Stände:

- **Auf `origin/main`** (`405ebada79a145ac537d8e4102ce46d029046475`) ist D20
  **A_FAIL mit einem Fund** — dem lokalen Zweig-Ref aus 6.12.17. Da D20 als
  erster Schritt läuft und ein Befund die Kette abbricht, endete die Kette dort
  bei D20, und kein weiterer Schritt liefe.
- **Im Arbeitsbaum mit dem am 2026-09-02 angelegten, noch nicht committeten
  Ausnahmeeintrag** war D20 grün: Ein Lauf des Koordinators am 2026-09-02, **vor
  dem Anlegen dieses Abschnitts**, ergab 0 Befunde und Rückgabewert 0
  (Fremdbeleg). Für den heutigen Arbeitsbaum gilt das nicht mehr, und zwar aus
  einem Grund, der zum Entwurf gehört: Dieser Abschnitt nennt zwei erst mit dem
  Bau entstehende Dateien, was für D20 je ein Fund ist und über zwei
  ortsgebundene Ausnahmen gedeckt wird (siehe die Beleglage oben). Erst
  in diesem Stand gilt die Lagenfolge, um die es hier geht: D1 bis D6, D8, D9
  und D18 sind Lage B, und **vier** Schritte sind Lage C — D7
  (`scripts/abnahme-abgleich.sh` fehlt), D10
  (`scripts/prototyp-trennung-pruefen.sh` fehlt), D11 (`gitleaks` fehlt) und
  D12 (`scripts/nachweise-vollstaendig.sh` fehlt).

Für den Entwurf zählt der zweite Stand, weil der erste mit dem Ausnahmeeintrag
behoben wird und weil er ohnehin die Frage nicht stellt, um die es hier geht:
Auf `origin/main` endet die Kette mit 2 wegen eines **Befunds**, im Arbeitsbaum
mit 2 wegen eines **fehlenden Prüfmittels**. Genau diese beiden Fälle
auseinanderzuhalten ist die Aufgabe des Gates (6.12.4) — der heutige Bestand
liefert für beide je ein Beispiel.

`make dod` endet also im massgeblichen Stand mit 2, nicht wegen eines Befunds,
sondern wegen eines fehlenden Prüfmittels. Ein Gate, das jeden Wert ungleich 0 als "nicht abschliessbar"
liest, blockiert ab seiner Einführung **jede** Arbeitseinheit bis zum
Grundgerüst — und das Grundgerüst ist selbst eine Arbeitseinheit.

**Optionen.**

| Option | Bewertung |
|---|---|
| (a) Lage C blockiert immer | Ehrlich, aber unbrauchbar: Das Gate wäre vom Tag seiner Einführung an dauerhaft rot, einschliesslich für die Arbeitseinheit, die die fehlenden Skripte anlegt. Ein Gate, das immer rot ist, wird nicht befolgt, sondern entfernt — dieselbe Erfahrung, die im Makefile-Kopf schon einmal festgehalten werden musste: "Ein Gate, das nichts mehr durchlaesst, ist so kaputt wie eines, das alles durchlaesst." |
| (b) Lage C lässt immer durch | Abgelehnt. Wer `scripts/belege-ausnahmen.txt` beiseitelegt, erzeugt Lage C bei D20 und ginge durch — ausgeführt belegt als Gegenprobe der elften Fortschreibung. Damit wäre die Ausnahmeliste der Weg an der ganzen Kette vorbei |
| (c) **Terminierte Lagen C** — eine versionierte, selbstprüfende Liste neben dem Hook, nach den vier Eigenschaften aus 6.8.5 | Gewählt. Sie macht die Menge der geduldeten Ausfälle abzählbar, ortsgebunden, begründet und selbstprüfend; sie kann nicht stillschweigend wachsen, und sie schrumpft von selbst, sobald ein Prüfmittel entsteht |
| (d) Relativ messen wie D19 — die Kette auf `origin/main` gegen die Kette im Arbeitsbaum | Abgelehnt. Ein zweiter Lauf je Beendigungsversuch, der einen zweiten Arbeitsbaum auf `main` braucht — den das main-Gate sperrt —, und "nicht schlechter als vorher" ist nicht "erledigt". Für den **Gegenstand** ist der relative Massstab richtig (6.9.2); für das **Instrument** gilt der absolute, und ein fehlendes Prüfmittel gehört zum Instrument |
| (e) Nur melden, nicht blockieren | Abgelehnt, aus dem in 6.2.3 und 6.8.4 bereits zweimal entschiedenen Grund: Eine Meldung, die nicht blockiert, wird in einem Stop-Hook nicht gelesen; eine abgestufte Wirkung ist eine Abschaltung mit besserem Namen (5.4) |

**Entscheid: (c).**

**Die Liste.** `.claude/hooks/dod-gate-terminierte-lagen.txt`, versioniert,
neben dem Hook, in der Form von `scripts/belege-ausnahmen.txt` — Schlüssel,
Tabulator, Grund; Leerzeilen und Zeilen mit `#` werden übergangen. Der
Schlüssel ist **doppelt ortsgebunden**, an den Schritt und an das Prüfmittel:

```
<D-Nummer> <ziel>|<fehlendes Prüfmittel als repository-relativer Pfad>	<Grund>
```

**Sechs Selbstprüfungen, jede für sich blockierend.** Sie sind der Grund, aus
dem diese Liste keine Abschaltung ist:

1. **Ein Schritt meldet Lage C ohne Eintrag** — das Gate blockiert. Die Liste
   ist eine Positivliste, keine Ausschlussregel.
2. **Ein Eintrag, dessen Prüfmittel existiert** — der Eintrag ist veraltet, das
   Gate blockiert. Das ist Eigenschaft 3 aus 6.8.5, wörtlich übernommen: Ein
   Eintrag, dessen Gegenstand entstanden ist, deckt beim nächsten Mal etwas
   Echtes zu.
3. **Ein Eintrag zu einem Schritt, der eine andere Lage als C meldet** — der
   Eintrag ist veraltet, das Gate blockiert. Sonst bliebe eine Zeile stehen,
   die niemand mehr liest.
4. **Ein Eintrag ohne Grund** — das Gate blockiert. Eigenschaft 2 aus 6.8.5:
   Eine Ausnahme ohne Begründung ist eine Lücke mit Deckmantel.
5. **Die Marke des Schrittes nennt ein anderes Prüfmittel als der Schlüssel** —
   das Gate blockiert. Ohne diese Prüfung deckte ein Eintrag für D7 wegen des
   fehlenden Abgleichsskripts auch den ganz anderen Fall, dass der Backlog
   keine Abnahmekriterien mehr führt; das Makefile kennt für D7 allein drei
   verschiedene C-Ursachen (gelesen). Diese Prüfung ist der Grund für G6.
6. **Der Schlüssel nennt kein terminierbares Prüfmittel** — das Gate blockiert.

**Was terminierbar ist und was nicht.** Terminierbar ist ausschliesslich ein
**Projektartefakt dieses Repositories**, das dieser ADR in Abschnitt 5 oder 6
als noch nicht entstanden führt — heute die vier Skripte
`scripts/abnahme-abgleich.sh`, `scripts/prototyp-trennung-pruefen.sh`,
`scripts/nachweise-vollstaendig.sh` und `scripts/rueckkanal-pruefen.sh` sowie
`backend/importvertraege.toml`. Nicht terminierbar sind:

- **ein installierbares Werkzeug** — `gitleaks`, `uv`, `node`, `npm`, `docker`,
  `git`. Es fehlt nicht, weil es noch nicht gebaut ist, sondern weil es nicht
  installiert ist; das ist keine Terminierung, sondern eine Aufgabe. **D11
  bleibt damit blockierend**, und das ist beabsichtigt: Der Geheimnis-Scanner
  ist der Schritt, dessen Ausfall am teuersten ist.
- **jedes Prüfmittel von D20** — der Belegprüfer, seine Ausnahmeliste, die
  beiden Bezugsdokumente, `git`, der Arbeitsbaum und, neu mit G16, die
  Vollständigkeit der Historie. D20 ist der Schritt, der die Nachweisführung
  selbst prüft; eine Ausnahme an ihm wäre eine Ausnahme an der Nachweiskette.
- **D19**, weil D19 kein Kettenschritt ist, sondern das Instrument, mit dem der
  Kettengrundsatz beobachtet wird (6.9.1).

**Was das Gate davon maschinell prüft — und was nicht.** V12 verlangt, dass ein
genannter Massstab auch geprüft wird. Deshalb genau:

| Prüft das Gate | Prüft das Gate nicht |
|---|---|
| Der Schlüssel trägt genau eine D-Nummer, einen Zielnamen und, nach dem senkrechten Strich, einen **repository-relativen Pfad** (kein absoluter Pfad, kein blosser Programmname ohne Verzeichnistrenner) | Ob der genannte Grund inhaltlich zutrifft |
| Die D-Nummer ist weder D19 noch D20 | Ob die genannte ADR-Stelle das Artefakt tatsächlich terminiert |
| Der genannte Pfad existiert heute nicht | |
| Der Grund ist nicht leer und nennt eine Stelle dieses ADR in der Form `ADR 0002, <Abschnitt>` | |
| Die Marke des Schrittes trägt dasselbe Prüfmittel (G6) | |

Die rechte Spalte bleibt beim menschlichen Review — dieselbe ehrliche Grenze,
die 6.8.4 für D20 zieht: Ein Werkzeug prüft, dass ein Verweis nicht ins Leere
zeigt, nicht, dass der Fundort die Behauptung trägt. Wer diese Grenze
verschweigt, baut wieder die Zusicherung ohne Deckung aus V12.

**Wer die Liste pflegen darf.** Anders als bei der Ausnahmeliste von D20, die
ein Inventar des Dokumentenbestandes ist, sagt jeder Eintrag hier: *Dieser
Kettenschritt urteilt bis auf Weiteres nicht.* Das ist eine Aussage über die
Kette, nicht über ein Dokument.

| Vorgang | Wer | Bedingung |
|---|---|---|
| Einen Eintrag hinzufügen oder entfernen | Software Architect, als Fortschreibung dieses Abschnitts | Nur für ein Artefakt, das dieser ADR als noch nicht entstanden führt; der Grund nennt die Tatsache und die ADR-Stelle |
| Die Form der Schlüssel, die sechs Selbstprüfungen oder den Begriff des Terminierbaren ändern | Software Architect, als Fortschreibung dieses Abschnitts | — |
| Eine ganze Lage-Art von der Prüfung ausnehmen | Niemand über diese Liste | Das ist keine Ausnahme, sondern eine Änderung des Gates |

**Der Vergleich, an dem diese Entscheidung hängt.** Für einen Kettenschritt ist
Lage B der Zustand "der Massstab hat nichts zu messen" — er wird gemeldet, nicht
verschwiegen, und der Schritt endet mit 0. Für das Gate ist eine terminierte
Lage C dasselbe eine Ebene höher: Der Massstab ist noch nicht da, das wird
gemeldet, und die Arbeit geht weiter. Der Unterschied zur abgelehnten Option
(e) ist nicht rhetorisch: Das Gate blockiert weiterhin bei jedem Schritt, der
**urteilen konnte** und etwas gefunden hat, und die Menge der geduldeten
Ausfälle kann nicht wachsen, ohne dass jemand eine versionierte Zeile mit einem
geschriebenen Grund anlegt, die einer Verifikation durch andere unterliegt.

**Und die Gegenseite bleibt streng.** `make dod` selbst kennt diese Liste
**nicht** und wird durch sie nicht weicher: Eine terminierte Lage C ist für die
Kette unverändert Lage C und ergibt Rückgabewert 2. Die Ausnahme lebt
ausschliesslich im Gate der Arbeitsumgebung, deren Zweck es ist, die Arbeit bis
zum Grundgerüst möglich zu halten. Der Lauf auf der Gegenseite aus O-12 ruft
dieselbe Kette ohne diese Liste auf; dort ist rot rot. Damit ist die Ausnahme
nicht nur begrenzt, sondern hat eine Instanz über sich, die sie nicht kennt.

#### 6.12.6 G5 — Der blinde Fleck hinter dem ersten C, und weshalb die Kette dort nicht mehr abbricht

Dies ist der Punkt, an dem die gewählte Option (c) allein noch nicht trägt, und
er ist beim Entwurf aufgefallen, nicht in der Vorlage genannt.

| | |
|---|---|
| **Vorher galt** | "`make dod` ruft alle Kettenschritte dieser Tabelle in der festgelegten Reihenfolge auf und **endet bei der ersten Abweichung ungleich 0**" |
| **Jetzt gilt** | Die Kette endet bei der ersten Abweichung, **die ein Urteil ist** — bei `A_FAIL`, bei einer fehlenden oder mehrfachen Marke und bei einem sonstigen Rückgabewert ungleich 0. Bei **Lage C** läuft sie weiter, merkt sich den Schritt und endet am Ende trotzdem mit 2 |

**Der Beleg dafür, dass das nötig ist, steht in F5 und in der Lagetabelle des
Makefiles.** Die Kette bricht heute bei D7 ab. Wäre D7 als terminierte Lage C
gedeckt und bräche die Kette dort weiterhin ab, so liesse das Gate einen Lauf
durch, in dem D8 bis D12 **nie gelaufen sind** — darunter D11, dessen Lage C
gerade nicht terminierbar ist, und D12. Das Gate erklärte damit einen Stand für
in Ordnung, von dem es sechs Schritte nicht angesehen hat, und der Grund dafür
wäre eine Zeile in seiner eigenen Ausnahmeliste. Das ist ein falsches Grün, und
zwar das teuerste denkbare: Es entsteht genau dann, wenn jemand die Liste
sorgfältig pflegt.

**Weshalb Weiterlaufen zulässig ist.** Jeder Kettenschritt urteilt über eine
eigene Sache mit einem eigenen Prüfmittel (Objekttabelle in Abschnitt 6); ein
Schritt in Lage C hat nichts gemessen und nichts verändert. Der
Kettengrundsatz aus 6.1.3 ist nicht berührt, und D19 klammert unverändert den
ganzen Lauf ein. Der Preis ist Laufzeit — und V9 ist an genau dieser Abwägung
entschieden: "Das, was korrekt und qualitativ ist. Soll zwar effizient sein,
aber nie an Korrektheit und Qualität verlieren."

**Weshalb bei `A_FAIL` weiterhin abgebrochen wird.** Ein Befund ist ein Urteil.
Er ist zu beheben, und alles, was danach käme, würde gegen einen Stand laufen,
der ohnehin geändert wird. Das ist die ursprüngliche Begründung des Abbruchs,
und sie gilt für Befunde unverändert; sie galt für Lage C nie, weil dort gar
nichts geurteilt wurde.

**Was die Umsetzung genau zu ändern hat** (Makefile, Ziel `dod`, DevOps
Engineer): Die Schleife bricht bei `gefundene_lage = C` nicht mehr ab, sondern
setzt `gesamt_rc` auf 2, vermerkt Kennung, Ziel und das mit G6 mitgelieferte
fehlende Prüfmittel in einer eigenen Liste und fährt fort; der unmittelbar
folgende Abbruch wegen `rc -ne 0` darf für diesen Schritt nicht greifen, weil
`KLASSIFIZIEREN` bei Lage C mit 1 endet und GNU Make daraus 2 macht. Bei
`A_FAIL`, bei fehlender oder mehrfacher Marke und bei jedem anderen
Rückgabewert ungleich 0 bricht sie unverändert ab. Die gültigen Marken der
übersprungenen C-Schritte zählen für `marken_zaehler` mit — sie sind gültig.

#### 6.12.7 G6 — Die Lage-Marke trägt das fehlende Prüfmittel, nicht der Meldungstext

| | |
|---|---|
| **Vorher galt** | Die Marke lautet `::LAGE <lauf-kennung> <D-Nummer> <ziel> <A_OK\|A_FAIL\|B\|C>[ SCHWELLE=…\|OHNE_SCHWELLE]::` und trägt bei Lage C **nicht**, welches Prüfmittel fehlt. Welches es ist, steht allein in einer Zeile der Form `[Dn ziel] LAGE C: <Text>` auf der Fehlerausgabe |
| **Jetzt gilt** | Die Marke erhält eine **feste Grammatik**, und der Lage-C-Fall trägt das fehlende Prüfmittel darin strukturiert mit: `::LAGE <lauf-kennung> <D-Nummer> <ziel> <Lage>[ FEHLT=<wert>][ SCHWELLE=…\|OHNE_SCHWELLE]::`. Die Reihenfolge der beiden Zusätze ist festgelegt und nicht dem Zufall des Aufrufs überlassen; beide dürfen nebeneinander stehen |

**Optionen.** Entweder das Gate liest die deutsche Meldungszeile und sucht darin
den Pfad, oder die Marke trägt ihn. Der Meldungsweg ist billiger — er kostet
keine Änderung am Makefile —, und er ist falsch:

1. **Er misst einen Text statt eines Gegenstands.** Die 53 C-Zweige des
   Makefiles sind Fliesstext in Deutsch (selbst gezählt: `LAGE C:` kommt
   53-mal vor). Sie werden umformuliert, wenn eine Fortschreibung sie
   umformuliert — und das Gate entschiede beim nächsten Mal anders, ohne dass
   jemand das Gate angefasst hätte. Das ist wörtlich Regel 1 aus 6.2.2, die
   dieser Abschnitt seit dem 2026-08-30 auf jeder Ebene durchsetzt.
2. **Nicht jeder Zweig nennt einen Pfad.** D11 meldet "gitleaks fehlt" — einen
   Programmnamen. Ein Gate, das darin einen Pfad sucht, findet keinen und
   müsste raten.
3. **Die Marke ist der einzige Kanal, den die Kette selbst als vertrauenswürdig
   behandelt.** Sie trägt die Lauf-Kennung, und `make dod` akzeptiert nichts
   sonst. Eine zweite Auswertung neben ihr wäre eine zweite Stelle, an der
   dieselbe Aussage steht — der Fehler aus 6.2.2, 6.9.1 und 6.11.3 b.

**Entscheid: strukturiert.** Der Preis ist benannt und angenommen: 53 Zweige
setzen je eine Shell-Variable.

**Wie die Angabe in die Marke kommt — und weshalb nicht über den vierten
Parameter** *(Runde 1, Präzisierung)*. Die erste Fassung dieses Entscheids
schrieb, die 53 Zweige gäben ihren Wert `KLASSIFIZIEREN` "als vierten Parameter"
mit. Das trägt aus zwei Gründen nicht, und beide sind am Makefile belegt:

1. **Der vierte Parameter ist schon belegt.** D3, D6 und D8 füllen ihn heute
   **statisch** mit `SCHWELLE=<wert>` beziehungsweise `OHNE_SCHWELLE`, und zwar
   unabhängig von der Lage — bei Lage C träfen beide Angaben zusammen, und eine
   von beiden ginge verloren oder ergäbe eine Marke, deren Aufbau vom Schritt
   abhinge.
2. **Ein Make-Parameter ist Expansionszeit, der Wert ist Laufzeit.** Welches
   Prüfmittel fehlt, stellt sich erst im Rezept heraus, in derselben Shell, die
   auch `hat_lage_c` setzt. Ein Wert, den `$(call …)` einsetzt, steht dagegen
   fest, bevor die erste Rezeptzeile läuft.

Deshalb: Jeder Lage-C-Zweig setzt neben `hat_lage_c=1` eine **Shell-Variable zur
Laufzeit** — sie trägt den Pfad oder den Werkzeugnamen —, und `KLASSIFIZIEREN`
hängt daraus im C-Zweig selbst `FEHLT=<wert>` an die Marke an, **vor** dem
Zusatz aus dem vierten Parameter. Der vierte Parameter bleibt unverändert das,
was er heute ist, und wird nicht umgewidmet. Das ist mechanisch, einmalig und
braucht keinen neuen Mechanismus — es braucht nur, dass die Grammatik der Marke
einmal festgeschrieben ist statt sich aus den Aufrufen zu ergeben.

**Fail-closed.** `KLASSIFIZIEREN` setzt bei Lage C `FEHLT=` **immer**; ist die
Variable leer, lautet der Wert `FEHLT=unbenannt`. Ein vergessener Zweig erzeugt
damit eine Marke, die kein Schlüssel der terminierten Lagen treffen kann, und
das Gate blockiert. Ein Zweig, an den niemand gedacht hat, fällt zu und nicht
auf. Das ist dieselbe Richtung, in die alle Wachen dieser Datei fallen.

**Nachtrag vom 2026-09-06 (6.12.27 d): die Elemente der Marke, einzeln
benannt.** Der bestehende Text dieses Abschnitts bleibt unverändert; die
folgende Tabelle sagt nur, **woraus** die oben festgelegte Grammatik besteht,
und gibt jedem Element ein festes ASCII-Kürzel. Das Kürzel ist die Klammer
zwischen dieser Festlegung und der Prüftabelle 6.12.19: Jede Zeile dort, die
den **Verstoss** gegen ein Element misst, trägt in der Spalte Fall am Anfang
das Etikett `Grammatik <KUERZEL>: `, und der Selbsttest liest die Kürzel aus
dieser Tabelle (erste Spalte, in Backticks, nur `A` bis `Z`) und verlangt je
Kürzel mindestens eine solche Zeile. Ohne diese Deckung bleibt ein Element der
Grammatik ungemessen, ohne dass etwas rot wird — belegt an `DT8-03` für das
schliessende `::`.

| Kürzel | Element | Verstoss, den die verneinende Zeile misst | Erwarteter Schlüssel |
|---|---|---|---|
| `PRAEFIX` | das Präfix `::LAGE ` am Zeilenanfang | Die Zeile beginnt nicht mit `::LAGE `, ist im Übrigen wohlgeformt | `KETTE ausgabe-unlesbar` |
| `KENNUNG` | die Lauf-Kennung als erstes Feld | Die Marke trägt kein Feld für die Lauf-Kennung | `KETTE ausgabe-unlesbar` |
| `DNUMMER` | die D-Nummer als zweites Feld | Die Marke trägt kein Feld für die D-Nummer | `KETTE ausgabe-unlesbar` |
| `ZIEL` | das Ziel als drittes Feld | Die Marke trägt kein Feld für das Ziel | `KETTE ausgabe-unlesbar` |
| `LAGE` | die Lage, genau eines der vier Wörter `A_OK`, `A_FAIL`, `B`, `C` | Die Marke trägt an dieser Stelle ein Wort ausserhalb dieser vier | `KETTE ausgabe-unlesbar` |
| `FEHLT` | der Zusatz `FEHLT=<wert>` | Der Zusatz steht **ohne Wert** (`FEHLT=` unmittelbar vor dem Abschluss) | `KETTE ausgabe-unlesbar` |
| `SCHWELLE` | der Zusatz `SCHWELLE=<wert>` oder `OHNE_SCHWELLE` | Der Zusatz steht **ohne Wert** (`SCHWELLE=` unmittelbar vor dem Abschluss) | `KETTE ausgabe-unlesbar` |
| `ABSCHLUSS` | das **schliessende** `::` | Die Marke endet ohne `::` vor der Rückgabewertklammer | `KETTE ausgabe-unlesbar` |
| `RUECKGABE` | die Rückgabewertklammer ` (rueckgabewert=<N>)` | Die Klammer steht **ohne Zahl** (`(rueckgabewert=)`) | `KETTE ausgabe-unlesbar` |
| `ENDE` | die **Terminierung** der Marke: die Zeile endet mit der Rückgabewertklammer, es folgt nichts mehr *(Nachtrag vom 2026-09-06, 6.12.27 i, Befund `DT9-01`)* | Hinter der Rückgabewertklammer steht ein Anhang (etwa ` x`) | `KETTE ausgabe-unlesbar` |
| `ANFANG` | der **Zeilenanfang**: die Marke steht am Anfang ihrer Zeile, eine eingebettete Marke ist keine Marke *(Nachtrag vom 2026-09-06, 6.12.27 j, Befund `DT10-04`)* | Die Marke steht eingebettet in einer Zeile (etwa `Fundstelle: ::LAGE …`) | `KETTE ausgabe-unlesbar` |
| `TRENNUNG` | die **Trennung** zwischen dem schliessenden `::` und der Rückgabewertklammer: **genau ein** Leerzeichen *(Nachtrag vom 2026-09-07, 6.12.28 c, Befund `DT11-02`)* | Zwischen `::` und `(rueckgabewert=…)` steht **kein** Leerzeichen | `KETTE ausgabe-unlesbar` |

**Woher das neunte Element kommt.** Die ersten acht stehen wörtlich in der
Grammatikzeile oben. Die **Rückgabewertklammer** steht dort nicht; sie steht im
Markenmuster des Gates, das sie als festen Anhang verlangt und im Kommentar auf
die Zusammenfassung im `Makefile` zurückführt. Sie wird hier **nachgeführt,
nicht geändert**: Das Gate verlangt sie seit dem Bau, und was das Gate tut,
steht in der Festlegung oder es steht nirgends (V12).

**Weshalb je Element derselbe Schlüssel.** Eine Zeile, die gegen ein Element
verstösst, ist für das Gate keine Marke: Sie trifft das Markenmuster nicht,
wird nicht gezählt, und die gelesene Markenzahl bleibt hinter der Zahl zurück,
die die Schlusszeile selbst nennt — das ist der Block aus 6.12.24 k mit dem
Schlüssel `KETTE ausgabe-unlesbar`. Der andere Schlüssel aus 6.12.4,
`KETTE marke-fehlt <D> <ziel>`, bleibt der Zeile vorbehalten, die die Kette
selbst als `(keine Marke)` ausgibt, zusammen mit einer Schlusszeile Form 3;
das ist ein an der Ausgabe unterscheidbarer, anderer Gegenstand. Für
`ABSCHLUSS` ist der Ausgang durch `DT8-03` als Fremdbeleg bestätigt; für die
übrigen acht ist er aus dem Aufbau des Gates **abgeleitet** und beim Bau zu
bestätigen. Weicht er ab, ist das ein **Befund** und diese Tabelle
fortzuschreiben, nicht die Prüfzeile an das Gate anzupassen.

**Nachtrag vom 2026-09-07 (6.12.28 c): das zwölfte Element.** `TRENNUNG` ist
neu. Die Tabelle nannte bisher die **Bestandteile** der Marke und ihre
**Begrenzung** (`ANFANG`, `ENDE`), nicht aber die **Trennung** zwischen dem
Abschluss `::` und der Rückgabewertklammer — das Muster des Gates verlangt dort
genau ein Leerzeichen, und eine Marke ohne dieses Leerzeichen blieb von jeder
Zeile ungemessen (`DT11-02`, Fremdbeleg aus Runde 11). Seit demselben Nachtrag
gilt zusätzlich: Die Deckung gegen diese Tabelle wird durch die **Schwächungen
des Musters** ergänzt (6.12.28 c), weil eine Zeile je Element **eine**
Verstossform deckt und nicht die Menge der Verstossformen; und die
Grammatikdeckung erhält eine **Gegenrichtung** — ein Etikett
`Grammatik <KUERZEL>: ` mit einem Kürzel, das hier nicht steht, ist eine
Abweichung (`Z-261`, Befund `S11-06`).

#### 6.12.8 G7 — Vier eindeutige Schlusszeilen, eine eigenständige D19-Zeile, ein genannter Baum

| | |
|---|---|
| **Vorher galt** | Bei Erfolg endet `make dod` mit `make dod: alle N Kettenschritte durchlaufen (…), keiner ungleich 0, N gueltige Marken gezaehlt, D19: <Befund>.`; bei Abbruch mit `make dod: D19: <Befund>.` und `make dod: abgebrochen, Rueckgabewert N.` Die D19-Aussage steht also in zwei verschiedenen Formen, je nach Ausgang, und der geprüfte Arbeitsbaum wird nirgends genannt. **Runde 1, ergänzt:** Der Befundtext selbst ist ebenfalls frei — fünf verschiedene Texte, darunter **zwei** Schreibweisen für dieselbe Lage C ("Lage C -- git fehlt", "LAGE C, nicht beobachtbar"), und die Lage-B-Zeile beginnt gar nicht mit `D19:`, sondern mit `D19 Lage B --` |
| **Jetzt gilt** | Die D19-Aussage steht **immer** in genau einer eigenständigen Zeile mit **fester Grammatik**. Die Schlusszeile kennt **vier** eindeutige Formen. Eine erste Zeile nennt den geprüften Arbeitsbaum |

*(Überschrift und Zahl sind am 2026-09-02 von drei auf vier nachgeführt; die
vierte Form ist ein **Nachtrag aus dem Bau, 6.12.23**, und ist unten als solche
gekennzeichnet. Die drei ursprünglichen Formen sind unverändert.)*

```
make dod: geprueft wird <PROJ>.
…
make dod: D19: <OHNE_BEFUND|VERLETZT|B|C>[ -- <Text>].
```

Das Schlüsselwort steht unmittelbar hinter `D19:` und ist eines von genau vier;
alles danach ist frei und für das Gate bedeutungslos. Damit bleibt der Text das,
was er sein soll — die Erklärung für den Menschen, einschliesslich der in 6.10.2
und 6.11.3 e zugesagten Angabe, welche Hälfte des Instruments stumm ist und was
die andere in diesem Lauf gemessen hat —, und das Gate misst nicht mehr den
Text. Ohne diese Festlegung müsste es zwei Schreibweisen derselben Lage kennen
und eine Zeile, die anders beginnt als die übrigen; das ist wörtlich Regel 1
aus 6.2.2, nur auf der Ebene der Meldung.

und danach genau eine der vier Formen:

```
make dod: alle <N> Kettenschritte durchlaufen, keiner ungleich 0, <N> gueltige Marken gezaehlt.
make dod: alle <N> Kettenschritte durchlaufen, <k> davon ohne Urteil (Lage C): <Liste>, Rueckgabewert 2.
make dod: abgebrochen bei <D-Nummer> <ziel>, Rueckgabewert <N>.
make dod: alle <N> Kettenschritte durchlaufen, Rahmenpruefung D19 <VERLETZT|C>, Rueckgabewert 2.
```

Die **vierte** Form ist ein *Nachtrag aus dem Bau, 6.12.23*: Sie gilt für den
Lauf, der vollständig, ohne `A_FAIL` und ohne Lage C durchgelaufen ist, in dem
aber D19 einen Befund oder Lage C meldet und der deshalb mit 2 endet. Ohne sie
passte keine der drei ursprünglichen Formen auf diesen Lauf. Welche Form wann
gilt und weshalb daraus die Parse-Regel "Rückgabewert 0 nur mit Form 1" folgt,
steht in 6.12.23 a.

**Weshalb die D19-Zeile aus der Erfolgszeile herausgelöst wird und nicht
zusätzlich dort steht.** Weil sie sonst zweimal stünde. V13: Eine Angabe, die
nichts steuert, sondern etwas anderes wiederholt, wird gestrichen und nicht
nachgeführt. Das Gate liest dann **eine** Form statt zweier, und die zweite
kann nicht veralten.

**Weshalb die mittlere Form gebraucht wird.** Nach G5 läuft die Kette bei Lage C
weiter und endet trotzdem mit 2. Die heutige Zeile "abgebrochen" wäre für
diesen Lauf schlicht unwahr — er ist nicht abgebrochen, er ist vollständig
gelaufen und hat an k Stellen nicht urteilen können. Eine Nachweiszeile, die
zu viel oder das Falsche behauptet, ist derselbe Mangel wie eine fehlende;
dieselbe Überlegung hat in 6.10.2 bereits einmal dazu geführt, eine Meldung auf
die schwächere, richtige Aussage festzulegen, und im Makefile dazu, "beobachtet
und in Ordnung" von "gar nicht beobachtet" zu trennen.

**Weshalb der Baum genannt wird.** Das Gate nennt in jeder Meldung, welchen
Arbeitsbaum es hat prüfen lassen (G12). Diese Angabe ist nur dann ein Nachweis,
wenn sie sich gegen die Kette prüfen lässt, die tatsächlich gelaufen ist —
sonst ist sie eine Behauptung des Gates über einen fremden Prozess. Die Kette
bestimmt ihren Baum selbst und ohne Rückfall (`PROJ` aus `MAKEFILE_LIST`, mit
Hartabbruch statt Rückfall auf das Arbeitsverzeichnis); sie sagt ihn heute nur
nicht. Dass die Bestimmung streng ist, aber ihr Ergebnis unsichtbar bleibt, ist
dieselbe Lücke, die 6.9.1 an D19 beschrieben hat: Es genügt nicht, richtig zu
messen, es muss auch feststehen, was gemessen wurde.

#### 6.12.9 G8 — Frage 3: Wie dreimaliges Scheitern am gleichen Kriterium erkannt wird, und wo gezählt wird

**Wo gezählt wird: ausserhalb des Arbeitsbaums.** Unter
`${XDG_STATE_HOME:-$HOME/.local/state}/r3cosint/dod-gate/`, je Sitzung
(`session_id`) und, wenn vorhanden, je Subagent (`agent_id`) eine Datei. Der
Grund ist zwingend und nicht eine Frage des Geschmacks: Eine Zählerdatei im
Arbeitsbaum wäre eine Datei, die das Gate während des Laufs schreibt, den es
beurteilt — D19 sähe sie, und das Gate erzeugte den Befund, den es meldet. Das
ist der Kettengrundsatz aus 6.1.3, angewandt auf das Gate selbst. *(Nachtrag
6.12.24 c: Sind weder `XDG_STATE_HOME` noch `HOME` gesetzt, ist das Verzeichnis
**nicht bestimmbar**; dieser Zustand wird behandelt wie ein nicht
beschreibbares Verzeichnis und erhält keinen eigenen Ausgang.)*

**Wie die Zählerdatei heisst — und wie sie heisst, wenn `sha256sum` fehlt**
*(Nachtrag 6.12.26 c, Befund S5-02 aus Runde 5)*. Der Regelfall ist die
**gehashte** Form: der Name trägt die SHA-256-Summe der `session_id`, bei
vorhandener `agent_id` ergänzt um die Summe über sie. Fehlt `sha256sum`, lässt
sich diese Summe nicht bilden — und genau dieser Fall muss zählbar bleiben,
weil `GATE sha256sum` seit 6.12.25 i wie jeder andere `GATE <Prüfmittel>`-Block
über die Zählung läuft. Der Ausweichname ist deshalb die **bereinigte Rohform**
der `session_id`: jedes Zeichen ausserhalb von `A-Za-z0-9_-` wird durch `_`
ersetzt, bei vorhandener `agent_id` ergänzt um dieselbe Bildung über sie. Er
ist innerhalb einer Sitzung deterministisch — mehr braucht die Zählung nicht —
und gilt **ausschliesslich** für den Fall des fehlenden `sha256sum`. Diese
Festlegung war im Bau bereits so umgesetzt und in diesem ADR nicht terminiert;
sie wird hier nachgeführt, nicht geändert (V12: was das Gate tut, steht in der
Festlegung oder es steht nirgends).

**Kein Rückkanal.** Das Gate schreibt ausschliesslich lokal und sendet nichts
nach aussen. Das ist keine Selbstverständlichkeit, sondern eine Bauvorschrift
(5.4, CLAUDE.md), und sie gilt für die Werkzeugkette so gut wie für das
Produkt.

**Was gezählt wird: das Kriterium, nicht das Ereignis.** Schlüssel ist die
Klassifizierung aus 6.12.4 — `<D> <ziel> <Lage>`, `D19 <Befund>`, `KETTE
<Grund>` oder `GATE <Prüfmittel>`. Gleicher Schlüssel wie beim letzten Block →
Zähler plus eins; anderer Schlüssel → Zähler auf eins. Ein **Durchlass** löscht
den Zähler; ein Durchlass wegen `stop_hook_active` (G9) und ein Nichtlaufen
wegen fehlender Schreibrechte der Rolle (G13) verändern ihn **nicht** — und
ebenso wenig der Durchlass ab dem vierten Mal nach der Eskalation *(Nachtrag
6.12.24 d)*.

**Weshalb `Stop`- und `TaskCompleted`-Blocks in denselben Zähler laufen.** 3.4
spricht von "derselben Prüfung am gleichen Kriterium", nicht von demselben
Ereignis. Ein Kriterium, das dreimal gescheitert ist, ist dreimal gescheitert,
gleich bei welcher Gelegenheit es geprüft wurde. Ein Subagent zählt dagegen für
sich, weil `agent_id` vorliegt: Er hat eine eigene Aufgabe, ein eigenes
Zugkontingent (`maxTurns`) und einen eigenen Abschlussbericht.

**Was beim dritten Mal geschieht.** Die Blockmeldung benennt das blockierende
Kriterium und verlangt, was 3.3 und 3.4 ohnehin verlangen: die Übergabedatei
unter `docs/uebergaben/`, mit einer vom Gate vorgegebenen, wörtlich zu
übernehmenden Zeile

```
Eskalation 3.4: <Schlüssel>
```

**Ab dem vierten Mal** lässt das Gate durch, wenn eine Datei unterhalb
`docs/uebergaben/` diese Zeile trägt **und** entweder nach `git status` neu
oder geändert ist **oder** im jüngsten Commit (`HEAD`) enthalten ist. Die
zweite Bedingung ist nicht Förmelei: Ohne sie genügte ein Verweis auf eine
beliebige alte Übergabe, und die Eskalation würde zur Formel. *(Runde 1: Die
erste Fassung verlangte allein "neu oder geändert nach `git status`" und
übersah damit den Regelfall — jede bisherige Eskalationsübergabe ist committet
worden, zuletzt `docs/uebergaben/2026-09-01_belegpruefer-abbruch-nach-3-4.md`.
Nach dem Commit wäre die Datei weder neu noch geändert, und der Durchlass
griffe nie. Der Zusatz "im jüngsten Commit enthalten" schliesst die Lücke, ohne
eine beliebige ältere Datei zuzulassen.)* Fehlt die Datei, blockiert das Gate
weiter mit derselben Forderung — die Eskalation ist kein Ausweg aus der
Blockade, sondern der vorgeschriebene Weg aus ihr heraus: abbrechen, Stand
schreiben, dem Auftraggeber vorlegen.

**Der Durchlass nach der Eskalation gilt nur für `Stop` und `SubagentStop`**
*(Runde 1, fehlender Entscheid)*. Für `TaskCompleted` gilt er **nicht**: Dort
blockiert das Gate weiter, auch nach der Eskalation. Der Grund ist die
Bedeutung der beiden Ereignisse. Der Durchlass bei `Stop` ist nötig, damit die
Rolle die Übergabe überhaupt abliefern und den Zug beenden kann — er sagt
nichts über die Aufgabe. Ein Durchlass bei `TaskCompleted` sagte dagegen
genau das Falsche: dass die Aufgabe **erledigt** sei. Sie ist es nicht; sie ist
abgebrochen und liegt dem Auftraggeber vor (3.4). Eine Aufgabe, die dreimal am
gleichen Kriterium gescheitert ist, als abgeschlossen zu markieren, widerspräche
dem Wortlaut des Abnahmekriteriums von R3-Q-001 ebenso wie dem Satz aus
`docs/06_Definition_of_Ready_und_Done.md`, dass ein halbfertiger Zustand nicht als erledigt gilt. Die
Eskalation beendet die Iteration, nicht die Aufgabe.

**Welcher Schlüssel gezählt wird, wenn ein Lauf mehrere Abweichungen zeigt**
*(Runde 1, fehlende Festlegung)*. Seit G5 läuft die Kette bei Lage C weiter;
ein Lauf kann deshalb mehrere ungedeckte Lagen C melden, dazu eine
D19-Abweichung. Gezählt und in der Blockmeldung zuerst genannt wird **die erste
Abweichung in der Reihenfolge der Kette** — also die erste Zeile der Übersicht,
deren Marke `A_FAIL` oder eine ungedeckte Lage C trägt; erst wenn keine solche
Zeile besteht, der D19-Befund. Der Grund ist die Vergleichbarkeit über Läufe
hinweg: Ein Zähler, dessen Schlüssel davon abhinge, welche von mehreren
Abweichungen gerade zufällig ausgewählt wurde, zählte nie dreimal dasselbe
Kriterium und die Eskalation griffe nie. Die übrigen Abweichungen stehen
vollständig in der Meldung — gezählt wird eine, verschwiegen wird keine.

**Was das Gate nicht kann, und wo die Grenze liegt.** Der Zustand liegt in der
Umgebung der Sitzung; in einer Cloud-Sitzung ist `HOME=/root` (Fremdbeleg) und
das Verzeichnis vergänglich. Über **Sitzungsgrenzen hinweg zählt das Gate
nicht.** Das ist keine Lücke, sondern die richtige Reichweite: 3.4 zählt die
Iteration innerhalb einer Arbeitseinheit, und über Arbeitseinheiten hinweg
trägt die Übergabedatei, nicht ein Zähler. Ist das Zustandsverzeichnis nicht
beschreibbar **oder nicht bestimmbar** *(Nachtrag 6.12.24 c)*, urteilt das Gate
unverändert und sagt in der Blockmeldung, dass es nicht zählen kann und weshalb;
die Rolle zählt dann selbst (3.4). Dass sich die
Eskalation dadurch aushebeln liesse, ist benannt und nicht verschwiegen — sie
ist ein Schutz des Kontingents, keine Bauvorschrift nach 5.4.

**Der eine Block, der das Zählwerk zwangsläufig verlässt** *(Nachtrag aus dem
Bau, 6.12.23 c)*. Fehlt `jq`, blockiert das Gate unverändert mit Rückgabewert 2
und dem Schlüssel `GATE jq` (6.12.11) — aber es **zählt diesen Block nicht**,
und es kann es nicht: `session_id` und `agent_id` stehen in der Eingabe-JSON,
die ohne `jq` nicht lesbar ist. Das Gate weiss dann, dass es blockiert, aber
nicht, wofür es den Block anschreiben soll. Dreimaliges Scheitern an `GATE jq`
läuft deshalb nicht in die Eskalation nach 3.4; die Rolle zählt dort selbst,
wie schon im Fall des nicht beschreibbaren Zustandsverzeichnisses. Ein
Ersatzschlüssel wird nicht erfunden — die Begründung steht in 6.12.23 c und
wird hier nicht wiederholt (V13). *(Nachtrag 6.12.25 i, Befund S4-04 aus Runde
4: `GATE jq` ist die **einzige** Ausnahme. Jeder andere Block mit einem
Schlüssel `GATE <Prüfmittel>` — namentlich `GATE mktemp`, `GATE sha256sum`,
`GATE flock`, `GATE make`, `GATE timeout`, `GATE git` — läuft über die Zählung
dieses Abschnitts und endet nicht unmittelbar.)*

**Nachtrag vom 2026-09-06 (6.12.27 i): die Aussagen dieser Festlegung, einzeln
benannt.** Der bestehende Text bleibt unverändert; die folgende Tabelle zählt
auf, **was** er über das Verhalten des Gates behauptet, und gibt jeder Aussage
ein festes ASCII-Kürzel. Anlass sind `DT9-02` und `DT9-03`: Zwei Sätze dieses
Abschnitts — der Zähler geht bei einem Schlüsselwechsel auf eins, und ein
Durchlass löscht ihn — waren von **keiner** Zusicherung gedeckt, und beide
Fremdmutationen liessen keine Zeile fallen, während der Selbsttest 183 von 183
meldete. Die Deckung läuft wie die Grammatikdeckung: Jede Zeile der Tabelle
6.12.19, die eine dieser Aussagen misst, trägt in der Spalte Fall am Anfang das
Etikett `Aussage <KUERZEL>: `; der Selbsttest liest die Kürzel aus dieser
Tabelle und verlangt je Kürzel mindestens eine Zeile.

| Kürzel | Aussage | Verstoss, den die verneinende Zeile misst |
|---|---|---|
| `E01` | Gezählt wird das **Kriterium**: Schlüssel ist die Klassifizierung aus 6.12.4 | Der Schlüssel wird ohne einen seiner Bestandteile gebildet |
| `E02` | Gleicher Schlüssel wie beim letzten Block: Zähler **plus eins** | Der Zähler wird bei gleichem Schlüssel nicht erhöht |
| `E03` | **Anderer** Schlüssel: Zähler **auf eins** | Der Zähler zählt über den Schlüsselwechsel hinweg weiter |
| `E04` | Ein Durchlass **wegen Ergebnis** löscht den Zähler | Der Zähler bleibt nach dem Durchlass stehen |
| `E05` | Ein Durchlass wegen `stop_hook_active` verändert den Zähler **nicht** | Der Durchlass löscht oder erhöht den Zähler |
| `E06` | Das Nichtlaufen für eine Rolle ohne Schreibrecht verändert den Zähler **nicht** | Der Ausgang löscht oder erhöht den Zähler |
| `E07` | Der Durchlass **nach der Eskalation** löscht den Zähler nicht; er zählt weiter | Der Durchlass löscht den Zähler |
| `E08` | Blocks **verschiedener Ereignisse** laufen in denselben Zähler | Der Zähler wird je Ereignis getrennt geführt |
| `E09` | Ein **Subagent** zählt für sich (`agent_id`) | Die `agent_id` geht nicht in die Zählung ein |
| `E10` | Die Zählerdatei liegt **ausserhalb** des geprüften Baums | Sie liegt im geprüften Baum |
| `E11` | Fehlt `sha256sum`, trägt die Zählerdatei den **Ausweichnamen** aus der bereinigten Rohform der `session_id` | Der Ausweichname wird nicht gebildet, der Block bleibt unzählbar |
| `E12` | `GATE jq` ist der **einzige** Block, der nicht gezählt wird | Auch dieser Block wird gezählt |
| `E13` | **Jeder andere** Block mit Schlüssel `GATE <Prüfmittel>` läuft über die Zählung | Ein solcher Block endet unmittelbar, ohne zu zählen |
| `E14` | **Beim dritten Mal** verlangt die Blockmeldung die Übergabedatei mit der wörtlichen Zeile `Eskalation 3.4: <Schlüssel>` | Die Zeile fehlt oder steht nicht als eigene Zeile |
| `E15` | Der Durchlass greift **frühestens beim vierten** Ereignis | Er greift schon beim dritten |
| `E16` | **Ab dem vierten Mal** lässt das Gate durch, wenn eine Datei unter `docs/uebergaben/` die Zeile trägt und neu, geändert **oder** in `HEAD` enthalten ist | Der Zweig für `HEAD` entfällt |
| `E17` | Eine Datei, die **nur in einem älteren Commit** steht, öffnet den Durchlass nicht | Die Suche wird auf die ganze Historie ausgeweitet |
| `E18` | Der Durchlass ist an den **gezählten** Schlüssel gebunden | Gesucht wird die Eskalationszeile ohne Schlüssel |
| `E19` | Der Durchlass gilt nur für `Stop` und `SubagentStop`; `TaskCompleted` blockiert weiter | Die Einschränkung entfällt |
| `E20` | Fehlt die Übergabedatei, blockiert das Gate ab dem vierten Mal weiter **mit derselben Forderung** | Die Forderung entfällt aus der Meldung |
| `E21` | Gezählt wird die **erste** Abweichung in Kettenreihenfolge; **genannt** werden alle | Der Zählschlüssel stammt von einer anderen als der ersten Abweichung |
| `E22` | Bei nicht beschreibbarem oder nicht bestimmbarem Zustandsverzeichnis urteilt das Gate unverändert und sagt in **jeder** Meldung, dass es nicht zählen kann | Der Zusatz entfällt |
| `E23` | Ausserhalb der Zählung blockieren **genau fünf** Pfade: `GATE jq` und die vier Pfade mit den Schlüsseln `EINGABE json`, `EINGABE ereignis`, `EINGABE baum` und `SPERRE belegt`; an keinem von ihnen entsteht eine Zählerdatei *(Nachtrag vom 2026-09-07, 6.12.28 e; die Aussage **präzisiert** `E12`, dessen Wortlaut vor diesen vier Schlüsseln lag und der unverändert stehen bleibt, 6.1.2)* | Einer dieser fünf Pfade schreibt eine Zählerdatei |

**Was ausdrücklich nicht aufgezählt ist, und weshalb.** Drei Sätze dieses
Abschnitts sind **nicht** enumeriert, weil sie im Prüfaufbau keine verneinende
Zeile zulassen und eine Deckung sonst nie erfüllbar wäre — dieselbe
Überlegung, die `Z-110` zurückgezogen hat: **kein Rückkanal** (eine negative
Allaussage über jede Ausgabe des Gates; sie bleibt Gegenstand der statischen
Prüfung), **über Sitzungsgrenzen hinweg zählt das Gate nicht** (der Prüfaufbau
stellt keine zweite Sitzung her; der Satz benennt die Reichweite, nicht ein
Verhalten) und **die Rolle zählt dann selbst** (eine Anweisung an den Menschen,
nicht an das Gate). Wer diese Grenze verschieben will, braucht eine
Fortschreibung, keine stillschweigende Auslegung.

#### 6.12.10 G9 — Frage 4: Wie `stop_hook_active` greift

| | |
|---|---|
| **Vorher galt** | "Reentranz-Schutz über `stop_hook_active`" — ohne Ausgang |
| **Jetzt gilt** | Ist `stop_hook_active` wahr, endet das Gate mit **0**, meldet über `systemMessage`, dass es wegen des Reentranz-Schutzes nicht durchgesetzt hat und in welchem Zustand die Kette zuletzt war, und **verändert den Zähler nicht** |

**Weshalb 0 und nicht eine eigene Erfindung.** Der Wortlaut ist an drei Stellen
eindeutig und deckungsgleich: Projektauftrag 3.4, Ebene 4 ("Der Hook muss dann
mit 0 enden und das Beenden zulassen"), `docs/06_Definition_of_Ready_und_Done.md`, Abschnitt "Durchsetzung",
und das Abnahmekriterium `R3-Q-001_gate_blockiert` ("bei gesetztem
`stop_hook_active` endet er mit 0, auch wenn der Prüflauf rot ist"). Auch die
gelesene Referenz begründet es sachlich: "Check this value or process the
transcript to avoid blocking on a condition that will never resolve." Ein
Kriterium, das sich innerhalb der Sitzung nicht erfüllen lässt — und bis zum
Grundgerüst gibt es solche —, blockierte sonst dauerhaft.

**Weshalb der Zähler unberührt bleibt.** Ein Durchlass wegen `stop_hook_active`
ist kein Durchlass wegen eines Ergebnisses. Würde er den Zähler löschen, käme
er nach jedem Block, und der Zähler stünde nie über eins — die Eskalationsregel
aus 3.4 wäre dann nicht bloss schwach, sondern unerreichbar. Würde er ihn
erhöhen, zählte das Gate einen Block, den es nicht ausgesprochen hat. Also
keines von beidem.

**Die Folge, ausgesprochen statt später entdeckt.** Siehe 6.12.2: Ein Stop-Gate
mit diesem Reentranz-Schutz erzwingt je Beendigungsversuch genau eine
Fortsetzung. Es hindert niemanden daran, die Antwort zu beenden; es hindert
daran, sie **ohne Rückmeldung** zu beenden. Die Zusicherung, dass eine Aufgabe
bei roter Kette nicht abschliessbar ist, trägt `TaskCompleted` — dort greift
der Reentranz-Schutz nicht, weil die gelesene Referenz das Feld für dieses
Ereignis nicht führt. Wer diesen Entwurf beurteilt, muss beides zusammen sehen:
Der Reentranz-Schutz ist gewollt schwach, und er ist nicht die Stelle, an der
die Zusicherung hängt.

#### 6.12.11 G10 — Die Prüfmittel des Gates, und was bei deren Ausfall geschieht

V12 verlangt: Nennt ein Text ein Prüfmittel, dessen Ausfall eine Wirkung haben
soll, muss der Code genau dieses Prüfmittel prüfen. Deshalb hier abschliessend
und namentlich, was das Gate braucht:

| Prüfmittel | Wofür | Fehlt es |
|---|---|---|
| `jq` | Lesen der Eingabe-JSON von der Standardeingabe | Lage C des Gates, Rückgabewert 2 |
| `git` | Bestimmung des geprüften Arbeitsbaums; Prüfung der Übergabedatei bei der Eskalation | Lage C des Gates, Rückgabewert 2 |
| GNU Make und das `Makefile` im bestimmten Baum | Der eine Einstieg (`make dod`) | Lage C des Gates, Rückgabewert 2 |
| `.claude/hooks/dod-gate-terminierte-lagen.txt` | Entscheidung über eine gemeldete Lage C | Lage C des Gates, Rückgabewert 2 — eine fehlende Liste liesse jede terminierte Lage stumm wegfallen und machte das Gate dauerhaft rot, ohne zu sagen weshalb. Eine **vorhandene, leere** Liste ist dagegen ein zulässiger Zustand: es gibt dann keine terminierten Lagen. Das ist wörtlich die Unterscheidung, die 6.11.2 für `scripts/belege-ausnahmen.txt` getroffen hat |
| `timeout` (coreutils) | Rückgewinnung der Kontrolle vor der Zeitgrenze des Harness (G11) | Lage C des Gates, Rückgabewert 2 |
| `flock` (util-linux) | Serialisierung der eigenen Läufe (G12) | Lage C des Gates, Rückgabewert 2 |
| `sha256sum` (coreutils) *(Nachtrag 6.12.24 g)* | Bildung der Namen von Sperr- und Zählerdatei aus dem Pfad des geprüften Baums (G8, G12) | Lage C des Gates, Rückgabewert 2, Schlüssel `GATE sha256sum`. *(Nachtrag 6.12.26 c, Befund S5-02: Damit dieser Block zählbar bleibt, trägt die Zählerdatei in genau diesem Fall den Ausweichnamen aus der **bereinigten Rohform** der `session_id` — jedes Zeichen ausserhalb von `A-Za-z0-9_-` wird zu `_`, bei vorhandener `agent_id` ergänzt um dieselbe Bildung über sie. Terminiert in 6.12.9, Absatz "Wie die Zählerdatei heisst"; ausschliesslich für diesen Fall, im Regelfall bleibt es bei der gehashten Form.)* |
| `mktemp` (coreutils) *(Nachtrag 6.12.24 g)* | Die Wegwerfdatei, in der die Ausgabe der Kette ausserhalb des geprüften Baums abgefangen wird (G14) | Lage C des Gates, Rückgabewert 2, Schlüssel `GATE mktemp` |
| Ein beschreibbares Zustandsverzeichnis | **Nur** das Zählwerk (G8) | **Kein** eigener Ausgang: das Gate urteilt unverändert und nennt **in jeder Meldung**, dass es nicht zählen kann; bei sauberem Grün ist das seine einzige Meldung *(Nachtrag 6.12.24 c: ein **nicht bestimmbares** Verzeichnis wird gleich behandelt; Nachtrag 6.12.24 e: die Sperre aus G12 weicht dann auf `/tmp` aus und entfällt nicht still)* |

**Die Präzedenz.** `.claude/hooks/block-main-write.sh` und
`block-prototype-import.sh` blockieren mit einer Meldung, wenn `jq` fehlt,
statt stillschweigend durchzulassen; CLAUDE.md führt das unter "Aktive Gates"
ausdrücklich. Das Gate aus R3-Q-001 verhält sich genauso, und zwar für alle
sechs blockierenden Prüfmittel: Jede Meldung nennt das fehlende Mittel **und
den Beschaffungsweg**, wie es die Lage-C-Zweige des Makefiles ebenfalls tun.

*(Nachtrag 6.12.24 g: Die Zahl "sechs" in diesem Absatz ist der Stand vor der
Verifikation vom 2026-09-02 und wird nicht umgeschrieben. Massgeblich ist nach
Regel 2 aus 6.2.2 die Tabelle darüber; sie führt seit diesem Nachtrag **acht**
blockierende Prüfmittel und neun insgesamt. Der Satz über Meldung und
Beschaffungsweg gilt unverändert für alle.)*

**Die eine Ausnahme, und weshalb sie eine ist.** Das Zustandsverzeichnis trägt
nicht das Urteil, sondern nur die Zählung. Wäre sein Fehlen ein blockierender
Ausgang, würde ein Gate, das nicht schreiben darf, auch bei grüner Kette
blockieren — ein Gate, das nichts mehr durchlässt. Die Zählung ist ausserdem
kein Schutz nach 5.4, sondern ein Schutz des Kontingents (3.3, 3.4). Die
Unterscheidung ist dieselbe wie bei D20 und dem zweiten Arbeitsbaum in 6.8.3:
Was den Gegenstand betrifft, ist Lage C; was nur die Vollständigkeit der
Meldung betrifft, gehört in die Meldung.

#### 6.12.12 G11 — Zeitüberschreitung: zwei Grenzen, und weshalb die innere die kleinere ist

**Der Befund aus der gelesenen Referenz.** "Claude Code cancels a `command` …
hook that reaches its `timeout`, discarding the hook's output, so on most events
a timed-out hook renders no decision." Ein Gate, das seine Zeitgrenze reisst,
**lässt also durch** — lautlos und ohne Ausgabe. Für ein Gate ist das der
schlechteste aller Ausgänge, und er tritt genau dann ein, wenn die Kette lange
läuft, also wenn viel gebaut und getestet wurde.

| | |
|---|---|
| **Vorher galt** | Nichts. Weder dieser ADR noch `docs/06_Definition_of_Ready_und_Done.md` nennen eine Zeitgrenze für die Gates |
| **Jetzt gilt** | Zwei Grenzen, und die innere ist die kleinere: `timeout: 900` je Hook-Eintrag in `.claude/settings.json`; im Skript läuft `make dod` unter `timeout` (coreutils) mit **600 s**; die Wartezeit auf die Sperre aus G12 beträgt **120 s** |

**Weshalb 600 s innen.** Die gelesene Referenz nennt 600 s als Vorgabewert für
`command`-Hooks — das ist die Dauer, die der Harness selbst für normal hält,
und damit keine erfundene Zahl. Der heute gemessene Lauf dauert 5,8 s
(Fremdbeleg); mit dem Grundgerüst kommen Bau, Containerbau, Testsuite,
Abdeckung und durchgehende Oberflächenläufe hinzu, und die Grössenordnung
wechselt von Sekunden zu Minuten.

**Weshalb 900 s aussen.** 600 s für die Kette, 120 s Wartezeit auf die Sperre
und die eigene Arbeit des Gates ergeben höchstens rund 720 s; 900 s lassen
180 s Reserve. Die äussere Grenze ist ausdrücklich **kein** zweiter Massstab,
sondern eine Notbremse: Erreicht wird sie nur, wenn das Skript selbst hängt.

**Was bei der inneren Grenze geschieht.** Das Gate beendet den Lauf (mit
Nachlauffrist, damit kein `make` im Hintergrund weiterläuft) und endet mit 2:
`KETTE zeitueberschreitung`. Es behauptet dabei nichts über den Arbeitsbaum —
die Nachher-Aufnahme von D19 hat nicht stattgefunden, und ein abgebrochener
Lauf hat kein Urteil gefällt. "Nicht nachweisbar gelaufen" ist die richtige und
die einzige belegte Aussage.

**Was offen bleibt, und weshalb es hier steht statt vermutet zu werden.** Ob
600 s für die Kette mit dem Grundgerüst reichen, ist nicht gemessen. Reichen sie
nicht, wäre das Gate regelmässig falsch rot — und ein regelmässig falsch rotes
Gate wird entfernt. Deshalb: **O-20**, mit einem ausgeführten Lauf zu
beantworten, sobald `backend/` und `deploy/` bestehen. Ergibt die Messung, dass
die Kette länger braucht, werden **beide** Werte als Fortschreibung angehoben —
das innere Limit wird nicht stillschweigend entfernt. Ein Gate ohne innere
Grenze ist ein Gate, das bei langem Lauf durchlässt.

#### 6.12.13 G12 — Welcher Arbeitsbaum geprüft wird, und was bei Nebenläufigkeit gilt

**Der geprüfte Baum wird bestimmt, nicht geraten.** Die gelesene Referenz sagt
zu Arbeitsbäumen: `${CLAUDE_PROJECT_DIR}` "still points at the project root
where the session started", während das Eingabefeld `cwd` "is the worktree root
after Claude enters a worktree". Beides zugleich zu nehmen geht nicht; eines
von beiden blind zu nehmen, hiesse in einem der beiden Fälle den falschen Baum
zu prüfen.

| | |
|---|---|
| **Vorher galt** | Nichts; `block-main-write.sh` nimmt `${CLAUDE_PROJECT_DIR:-$PWD}` und benennt im Kopf, dass ein zweiter Arbeitsbaum ausserhalb der Sitzung nicht erfasst ist |
| **Jetzt gilt** | Das Gate prüft den Arbeitsbaum, in dem `cwd` liegt, **sofern dieser zu demselben Repository gehört** wie `${CLAUDE_PROJECT_DIR}` — festgestellt über die Versionsverwaltung (das gemeinsame Git-Verzeichnis), nicht über einen Verzeichnisnamen. Sonst gilt `${CLAUDE_PROJECT_DIR}`. Der geprüfte Baum steht in **jeder** Meldung des Gates, blockierend wie durchlassend. *(Nachtrag 6.12.24 a: Bestimmt wird in beiden Fällen die **Wurzel** des Arbeitsbaums, und zwar **physisch aufgelöst** — sonst vergleicht das Gate seine Angabe mit der Baumzeile der Kette, die aus `pwd -P` stammt, und misst eine Schreibweise statt eines Baums.)* |

**Weshalb nicht einfach `${CLAUDE_PROJECT_DIR}`.** Weil CLAUDE.md den Betrieb
auf einem Arbeitszweig vorschreibt und ein zweiter Arbeitsbaum damit eine
naheliegende Arbeitsform ist — das steht bereits als Begründung im Makefile bei
D19 und in 6.9.3. Arbeitet Claude in einem Arbeitsbaum und prüfte das Gate die
Sitzungswurzel, meldete es Grün über einen Stand, den niemand angesehen hat.
Genau dieser Fehler ist an dieser Datei schon einmal blockierend aufgetreten:
Die dritte Fassung der `PROJ`-Bestimmung fiel auf das Arbeitsverzeichnis zurück
und prüfte belegt ein fremdes Repository, während der Lauf wie eine reguläre
Prüfung aussah. V10 sagt dazu: Was sich schliessen lässt, wird geschlossen; und
das hier lässt sich mit `git` schliessen.

**Weshalb kein Urteil über ein fremdes Repository.** Liegt `cwd` ausserhalb
jedes Arbeitsbaums dieses Repositories — etwa im Methodik-Repository —, prüft
das Gate die Sitzungswurzel und sagt das. Es prüft **nie** ein Repository, für
das es nicht eingerichtet ist. Auch das ist aus der `PROJ`-Geschichte
übernommen: lieber kein Urteil als ein Urteil über das falsche Verzeichnis.

**Serialisierung der eigenen Läufe.** In dieser Sitzung laufen Subagenten
parallel und schreiben Dateien (Fremdbeleg); die gelesene Referenz sagt zudem,
dass mehrere Hooks desselben Ereignisses parallel laufen. Zwei gleichzeitige
`make dod` gegen denselben Baum stören einander über D19. Das Gate nimmt
deshalb vor dem Lauf eine Sperre (`flock`) mit 120 s Wartezeit; läuft sie ab,
endet es mit 2 und sagt, dass ein anderer Lauf die Sperre hält. **Die
Sperrdatei liegt im Zustandsverzeichnis, nicht im Arbeitsbaum** — eine
Sperrdatei im Baum wäre eine Datei, die während des Laufs entsteht und
vergeht, und D19 sähe sie. Sie ist an den Pfad des geprüften Baums gebunden,
nicht an die Sitzung, damit sie auch zwischen Sitzungen wirkt. *(Nachtrag
6.12.24 e: Ist das Zustandsverzeichnis nicht beschreibbar oder nicht
bestimmbar, liegt die Sperrdatei mit demselben Namen fest unter `/tmp`; geht
auch das nicht, läuft das Gate **ohne** Sperre und sagt das in jeder Meldung.)*

**Die Grenze, die bleibt.** Ein **fremder** Schreiber — ein anderer Subagent,
der während des Laufs eine Datei ändert — lässt sich damit nicht anhalten. D19
meldet dann `VERLETZT`, obwohl kein Kettenschritt geschrieben hat, und das Gate
kann die beiden Ursachen nicht unterscheiden. Entschieden wird: **`VERLETZT`
blockiert immer.** Die Meldung nennt beide möglichen Ursachen und verlangt, den
Lauf zu wiederholen, wenn sonst nichts läuft. Das Gate erklärt einen Befund
nicht weg — es ist nicht die Stelle, an der entschieden wird, ob eine
Beobachtung zählt. Bleibt der Befund dreimal, greift die Eskalation aus G8, und
das ist der richtige Ausgang: Ein Problem, das sich nicht von innen lösen lässt,
gehört vorgelegt (3.4).

#### 6.12.14 G13 — `SubagentStop` und Rollen, die den Arbeitsbaum nicht ändern können

**Das Problem.** Static Software Tester und Pentester haben weder `Edit` noch
`Write`. Ein Block verlangte von ihnen eine Behebung, die sie nicht leisten
können, und veränderte zugleich ihren Abschlussbericht — die letzte Nachricht
eines Subagenten ist sein Arbeitsergebnis, und der aufrufende Kontext liest sie.
Beim Prüfer wiegt das doppelt: **Seine Aufgabe ist es, den roten Befund zu
melden.** Ein Gate, das ihn wegen desselben roten Befunds am Abliefern hindert,
macht die Meldung des Befunds unmöglich.

| Option | Bewertung |
|---|---|
| (i) Das Gate gilt für alle Subagenten gleich | Abgelehnt, aus dem Grund oben. Es blockierte am zuverlässigsten die Rollen, die es am wenigsten angeht |
| (ii) Das Gate liest das `tools:`-Feld der Rollendatei und behandelt Rollen ohne Schreibwerkzeug gesondert | Gewählt. Es misst den **Gegenstand** — hat diese Rolle das Recht, den Baum zu ändern? — statt eines Namens. Das ist Regel 1 aus 6.2.2 |
| (iii) Ein Matcher in `settings.json` | Abgelehnt. Eine zweite Kopie der Rechtetabelle aus ADR 0001, die mit der ersten Rollenänderung veraltet, ohne dass es auffällt (V13) |

**Entscheid: (ii), und das Gate läuft für diese Rollen gar nicht erst.** Es
bestimmt zuerst die Rolle; enthält deren `tools:`-Feld **keines von `Edit`,
`Write` und `NotebookEdit`**, endet es mit 0 und meldet über `systemMessage`,
dass es die Kette für diese Rolle nicht hat laufen lassen und weshalb. `make
dod` läuft dann nicht — das spart bis zu 600 s je Abschluss eines
Prüf-Subagenten und, wichtiger, es vermeidet eine Aussage über einen
Kettenzustand, den diese Rolle weder verursacht hat noch beheben kann.

**`Bash` zählt nicht dazu — ein blockierender Befund aus Runde 1, hier
entschieden.** Die erste Fassung führte `Bash` unter den verändernden
Werkzeugen. Gemessen über alle 21 Rollendateien tragen `static-software-tester`
und `pentester` genau `tools: Read, Grep, Glob, Bash, Skill` — also `Bash`,
aber weder `Edit` noch `Write`. Mit `Bash` im Kriterium liefe das Gate
ausgerechnet für die beiden Rollen, für die G13 gemacht ist; der Entwurf hätte
sich selbst aufgehoben. Massgeblich ist deshalb die Menge der Werkzeuge, über
die **ADR 0001 Schreibrecht vergibt**: `Edit`, `Write`, `NotebookEdit`.

**Die Grenze dieses Kriteriums, ausgesprochen statt überdeckt.** `Bash` **kann**
schreiben — mit `sed -i`, mit einer Umleitung, mit einem Interpreteraufruf; das
Gate `block-main-write.sh` behandelt genau diese Wege in seinem
Bash-Zweig. Eine Rolle mit `Bash` und ohne `Edit`/`Write` **darf** also nicht
schreiben, **könnte** es aber. Das Kriterium misst damit das Recht, nicht die
Fähigkeit, und das ist eine bewusste Wahl mit zwei Gründen: Erstens ist das
Recht das, worüber ADR 0001 verfügt und worüber sich die Rolle Rechenschaft
schuldet; zweitens ist die Fähigkeit ohnehin nicht die Frage, die G13 stellt —
ein Prüfer, der unter Umgehung seines Rechts geschrieben hätte, hat ein
grösseres Problem als eine ungelaufene Kette. Die **harte** Durchsetzung der
Schreibgrenzen ist R3-Q-005 und bleibt es; dieses Gate ersetzt sie nicht und
gibt nicht vor, es zu tun. Solange R3-Q-005 nicht steht, bleibt der Fall
"Prüfer schreibt über `Bash`" durch nichts abgefangen — das ist eine benannte
Lücke des Rollenmodells, nicht eine, die dieser Entwurf einführt.

**Woran das Gate die Rolle erkennt: am Frontmatter, nicht am Dateinamen**
*(Runde 1)*. Die gelesene Referenz sagt zu `agent_type` im Abschnitt
`SubagentStart`, auf den der `SubagentStop`-Abschnitt für die Werte verweist:
"For custom subagents, this is the `name` field from the agent's frontmatter,
not the filename." Die erste Fassung dieses Entwurfs las
`.claude/agents/<agent_type>.md` und setzte damit stillschweigend Dateiname
gleich `name` voraus. Dass beides heute in allen 21 Rollendateien
übereinstimmt (selbst gemessen), macht die Annahme nicht richtig — sie wäre
beim ersten Auseinanderfallen still falsch, und das ist derselbe Fehler, den
6.2.2 als Regel 1 verbietet: ein Name statt des Gegenstands. Das Gate löst
`agent_type` deshalb über das Frontmatter-Feld `name:` **aller** Dateien unter
`.claude/agents/` auf und nimmt den eindeutigen Treffer.

**Fail-closed in jeder Unklarheit.** Findet die Auflösung keinen oder mehr als
einen Treffer — auch bei einer eingebauten Rolle wie `Explore` oder bei einem
plugin-bezogenen Namen mit Doppelpunkt, den die Referenz ausdrücklich nennt —,
so behandelt das Gate die Rolle als **schreibberechtigt** und läuft. Eine
unbekannte Rolle ist keine bekannte Ausnahme. Ist `agent_type` leer oder trägt
er Zeichen, die in einem Frontmatter-Namen nicht vorkommen können, gilt
dasselbe. Der Zähler wird in allen diesen Fällen nicht verändert (G8).

#### 6.12.15 G14 — Sichtbarkeit: was gemeldet wird, wohin, und was nicht

**Der Befund aus der gelesenen Referenz.** Bei Rückgabewert 0 geht die
Standardausgabe eines Hooks "to the debug log and doesn't show it in the
transcript"; die Fehlerausgabe bei 0 geht ebenfalls nur ins Debug-Protokoll und
"Claude never sees it". Ein Durchlass ist also **stumm** — und ein Durchlass
mit terminierten Lagen C wäre damit ein Negativbefund, den niemand sieht. Nach
5.3 sind Negativbefunde zwingend Teil der Spur; das ist der Gedanke, der hier
sinngemäss trägt.

| | |
|---|---|
| **Jetzt gilt** | Bei jedem Durchlass, der **kein sauberes Grün** ist, gibt das Gate auf der Standardausgabe genau ein JSON-Objekt mit dem Feld `systemMessage` aus. Bei sauberem Grün gibt es nichts aus. Beim Blockieren geht der Grund auf die Fehlerausgabe, und die Standardausgabe bleibt leer |

Drei Fälle sind kein sauberes Grün und melden sich deshalb: der Durchlass mit
terminierten Lagen C (die Meldung nennt, **welche** Schritte nicht geurteilt
haben und welches Prüfmittel ihnen fehlt), der Durchlass wegen
`stop_hook_active` (G9) und das Nichtlaufen für eine Rolle ohne veränderndes
Werkzeug (G13). *(Nachtrag 6.12.24 c und e: Ein **vierter** Fall kommt hinzu —
ein ausgefallenes Zählwerk oder eine ausgefallene Sperre. Auch dann meldet sich
das Gate; ist die Kette im Übrigen sauber grün, ist das seine einzige Meldung.
Der Grundsatz bleibt unverändert: Geschwiegen wird nur, wenn es nichts zu
melden gibt.)*

**Weshalb bei sauberem Grün Schweigen richtig ist.** Weil dann nichts zu melden
ist und jede zusätzliche Zeile Rauschen wäre, das die drei Fälle oben
unsichtbar machte. Das Gate ist auch nicht der Ort der Nachweisführung: Der
Nachweis eines grünen Laufs entsteht dort, wo `make dod` geführt und sein
Ergebnis festgehalten wird (D12, 6.6), nicht in einer Meldung an den Bildschirm.

**Zwei Dinge, die das Gate ausdrücklich nicht tut.**

- **Kein `continue: false`.** Die gelesene Referenz beschreibt das Feld als "If
  `false`, Claude stops processing entirely after the hook runs". Das nimmt dem
  Menschen die Entscheidung aus der Hand und geht über das hinaus, was 3.4
  Ebene 2 verlangt: blockieren und begründen, damit weitergearbeitet wird. Ein
  Gate, das die Sitzung beendet, ist kein Gate, sondern ein Abbruch.
- **Kein eigenes Protokoll.** Das Gate führt keine dritte Spur neben
  Ermittlungs- und Arbeitsspur (5.3) und kein Laufprotokoll. Eine Spur ohne
  Leser wächst, veraltet und wird zur Ausrede; die Zählerdatei aus G8 ist der
  gesamte Zustand, den das Gate führt.

**Die Form der Ausgabe ist eine Bedingung, keine Empfehlung.** Die gelesene
Referenz sagt: "Your hook's stdout must contain only the JSON object", und sie
beschreibt, dass eine Ausgabe, die mit einer geschweiften Klammer beginnt und
endet, als JSON gelesen wird — schlägt das fehl, entsteht eine sichtbare
Fehlermeldung, und auf manchen Ereignissen wird der Text verworfen. Daraus
folgt zwingend: **Die Ausgabe von `make dod` darf niemals auf die
Standardausgabe des Gates gelangen.** Das Gate fängt Standard- und
Fehlerausgabe der Kette gemeinsam ab und wertet sie aus; auf die eigene
Standardausgabe geht ausschliesslich das JSON-Objekt oder nichts. *(Nachtrag
6.12.24 f: Die Wegwerfdatei, in der das Gate die Ausgabe abfängt, liegt
nachweislich **ausserhalb** des geprüften Baums — sonst erzeugte das Gate den
D19-Befund, den es meldet.)* Die
Referenz begrenzt Ausgabezeichenketten zudem auf 10 000 Zeichen und nennt dabei
`systemMessage` ausdrücklich; über die Fehlerausgabe sagt sie dazu nichts.
Deshalb gilt für beide Wege dieselbe Bauvorschrift: **Die Meldung des Gates ist
kurz und nennt den Schlüssel, den Schritt, das fehlende Prüfmittel und den
nächsten Schritt — sie reicht nicht die ganze Ausgabe der Kette durch.** Wer
den vollen Lauf sehen will, ruft `make dod` selbst auf; das ist ohnehin der
Weg, auf dem er zum Nachweis wird.

**Nachtrag vom 2026-09-06 (6.12.27 i): die Aussagen dieser Festlegung, einzeln
benannt.** Der bestehende Text bleibt unverändert. Dieselbe Mechanik wie in
6.12.9 und aus demselben Anlass: Was der ADR **aufzählt**, wird gemessen; was
er **behauptet**, bisher nicht. Jede Zeile der Tabelle 6.12.19, die eine dieser
Aussagen misst, trägt in der Spalte Fall am Anfang das Etikett
`Aussage <KUERZEL>: `; der Selbsttest liest die Kürzel aus dieser Tabelle und
verlangt je Kürzel mindestens eine Zeile.

| Kürzel | Aussage | Verstoss, den die verneinende Zeile misst |
|---|---|---|
| `A01` | Bei einem Durchlass, der **kein** sauberes Grün ist, trägt die Standardausgabe **genau ein** JSON-Objekt mit dem **einzigen** Feld `systemMessage` — damit auch kein `continue` | Das Objekt erhält ein zweites Feld |
| `A02` | Bei **sauberem Grün** ist die Standardausgabe leer | Vor dem Ausgang wird eine Zeile auf die Standardausgabe geschrieben |
| `A03` | Bei sauberem Grün ist auch die **Fehlerausgabe** leer | Vor dem Ausgang wird eine Zeile auf die Fehlerausgabe geschrieben |
| `A04` | **Beim Blockieren** bleibt die Standardausgabe leer; die aufgefangene Ausgabe der Kette gelangt nie dorthin | Die Kettenausgabe wird auf die Standardausgabe geschrieben |
| `A05` | **Beim Blockieren** nennt die Fehlerausgabe den Grund: Schlüssel, Schritt, fehlendes Prüfmittel und nächsten Schritt | Der Schlüssel fällt aus der Meldung |
| `A06` | Der Durchlass mit terminierten Lagen C nennt, **welche** Schritte nicht geurteilt haben | Die Aufzählung entfällt |
| `A07` | Ein ausgefallenes Zählwerk oder eine ausgefallene Sperre meldet sich auch bei sonst sauberem Grün, und die Meldung unterscheidet "nicht bestimmbar" von "nicht beschreibbar" | Der Zusatz entfällt oder sagt das Falsche |
| `A08` | Das Gate endet **ausschliesslich** mit 0 oder 2 — nie mit einem anderen Wert *(Nachtrag vom 2026-09-06, 6.12.27 j; die Aussage steht seit 6.12.24 c und hatte bis dahin keine eigene Stelle)* | Ein Ausgang endet mit einem anderen Wert, etwa 1 oder 3 |

**Was ausdrücklich nicht aufgezählt ist, und weshalb.** **"Kein eigenes
Protokoll"** ist eine negative Allaussage über alles, was das Gate nicht
schreibt, und im Prüfaufbau nicht verneinbar; **"die Meldung ist kurz"** nennt
keine messbare Schranke — die 10 000 Zeichen stammen aus der gelesenen
Referenz und sind keine Zusicherung dieses ADR. Beides bleibt Gegenstand der
statischen Prüfung. Eine Aussage ohne verneinende Zeile wird hier **nicht**
aufgezählt, weil eine Deckung, die niemand erfüllen kann, keine Deckung ist.

#### 6.12.16 G15 — Kein Zwischenspeicher des Urteils

Naheliegend wäre, das Urteil zwischenzuspeichern und die Kette nur laufen zu
lassen, wenn sich der Arbeitsbaum seit dem letzten Lauf geändert hat. Das wird
**abgelehnt**, aus drei Gründen:

1. **Das Urteil ist nicht allein eine Funktion des Arbeitsbaums.** D8 fragt eine
   Schwachstellendatenbank ab, Werkzeuge werden installiert und entfernt,
   `gitleaks` kann heute fehlen und morgen da sein. Ein gespeichertes Urteil
   wäre ein Urteil über einen vergangenen Lauf, ausgegeben als Aussage über den
   gegenwärtigen.
2. **Es wäre ein zweites Messmittel an derselben Sache.** Um zu erkennen, ob
   sich der Baum geändert hat, müsste das Gate genau das messen, was D19 misst
   — und dann stünde dieselbe Messung an zwei Stellen. Das ist das Muster aus
   6.9.1, das dieser Abschnitt bereits dreimal aufgelöst hat.
3. **V9.** Steht eine Abwägung zwischen Laufzeit und Beweiskraft, entscheidet
   die Beweiskraft.

**Der Preis ist benannt.** Das Gate lässt die Kette bei jedem Beendigungsversuch
und bei jedem Abschlussversuch laufen. Heute kostet das 5,8 s (Fremdbeleg); mit
dem Grundgerüst wird es mehr. Wird es untragbar, ist das eine Fortschreibung
dieses Abschnitts mit einem gemessenen Lauf als Grundlage — etwa dahin, dass
das Gate auf `Stop` nur läuft, wenn seit dem letzten Lauf geschrieben wurde —,
und nicht eine stille Optimierung im Skript. Die Messung ist Teil von O-20.

#### 6.12.17 G16 — Der flache Klon: die Vollständigkeit der Historie wird Prüfmittel von D20

**Der Befund** (Fremdbeleg, 2026-09-02): Der Klon der Sitzung war flach
(`git rev-parse --is-shallow-repository` meldet wahr, 92 Commits sichtbar). In
diesem Zustand meldete D20 **31 Funde**, davon 30 der Art `commit` —
Commit-Prüfsummen, die in `docs/NACHWEISE.md` stehen und lokal als Objekt
fehlen —, und `make dod` endete mit `D20 belege A_FAIL`. Nach `git fetch
--unshallow` (98 Commits) blieb **ein** Fund.

**Weshalb das entschieden werden muss.** Cloud-Sitzungen klonen flach. Das Gate
liefe dort ab seiner Einführung gegen 30 Scheinfunde und blockierte jede
Arbeitseinheit — mit einer Begründung, die nicht stimmt. Das ist **wörtlich der
Fehlermodus aus 6.11.1**: rot, aber mit falscher Begründung, weil ein
Prüfmittel ausgefallen ist und niemand danach fragt. Und es ist die vierte
Wiederholung derselben Fehlerklasse, die V12 beschreibt: Der Belegprüfer prüft
Commit-Prüfsummen gegen die lokale Historie und behandelt eine unvollständige
Historie als vollständige.

| | |
|---|---|
| **Vorher galt** | Prüfmittel von D20 sind `scripts/belege-pruefen.sh` und `scripts/belege-ausnahmen.txt`, `bash`, `git`, `grep`, `sed`, `awk` sowie die beiden Bezugsdokumente. Von der **Vollständigkeit** der Historie stand nichts — weder in der Objekttabelle noch im Ziel `belege` noch im Skript |
| **Jetzt gilt** | Die Prüfmittelspalte der D20-Zeile trägt zusätzlich: **eine vollständige Git-Historie.** Ist der Klon flach, trägt die lokale Historie die Aussage über Commit-Prüfsummen nicht; das ist **Lage C** nach der geschärften Bedingung aus 6.9.2 — das Prüfmittel ist vorhanden und trägt die Aussage nicht. Der Beschaffungsweg lautet `git fetch --unshallow` und gehört in die Meldung |

**Wo geprüft wird.** Im Makefile-Ziel `belege`, in dessen Wächter-Block, der
seit der elften Fortschreibung ohnehin `git`, den Arbeitsbaum und die drei
Dateien vor jeder Verwendung prüft. Dort entsteht die Lage-Marke, und dort
gehört die Prüfung hin; das Skript bleibt unverändert. Eine zweite Prüfung an
zweiter Stelle wäre wieder dieselbe Aussage an zwei Orten.

**Und wo es geschrieben steht** *(Runde 1)*. Die erste Fassung dieses
Unterabschnitts sagte, die Prüfmittelspalte der D20-Zeile trage die
Vollständigkeit der Historie "jetzt" — die **Objekttabelle in Abschnitt 6**
enthielt das Wort aber nicht. Nach Regel 2 aus 6.2.2 ist diese Tabelle die eine
massgebliche Stelle, und frühere Fortschreibungen haben ihre Zeilen deshalb
selbst geändert statt nur über sie zu schreiben; die D20-Zeile trägt sichtbar
den Vermerk der achten Fortschreibung. Die Zeile ist jetzt nachgeführt und
trägt den Zusatz samt Entwurfsvorbehalt. Bemerkenswert an diesem Befund ist,
dass er dieselbe Fehlerklasse zeigt, gegen die dieser Abschnitt seit dem
2026-08-30 arbeitet — eine Festlegung, die an einer Stelle steht und an der
massgeblichen nicht.

**Weshalb nicht terminierbar.** Ein flacher Klon ist kein Artefakt, das noch
entsteht, sondern ein Zustand, der sich mit einem Befehl beheben lässt; und
Prüfmittel von D20 sind nach G4 grundsätzlich nicht terminierbar. Das Gate
blockiert in einer frisch geklonten Cloud-Sitzung also so lange, bis die
Historie vollständig ist — mit einer Meldung, die den einen nötigen Befehl
nennt. Das ist unbequem und richtig: Die Alternative wäre, eine Kette laufen zu
lassen, die über Herkunftsangaben urteilt, ohne die Herkunft sehen zu können.

**Der Nebenbefund, hier nur verzeichnet.** In jedem frischen Klon bleibt ein
Fund auf `origin/main`
(`405ebada79a145ac537d8e4102ce46d029046475`): Eine Übergabedatei nennt den Pfad
eines **lokalen** Zweig-Refs als Beleg, und ein lokaler Ref existiert nur auf
dem Arbeitsplatz, auf dem der Zweig ausgecheckt war. Übergaben belegen einen
vergangenen Stand und werden nicht geändert (Abschnitt 9). Der ortsgebundene
Ausnahmeeintrag dafür ist Umsetzung nach 6.8.5 und **kein** Architekturentscheid;
diese Fortschreibung legt ihn nicht an. Für den Entwurf zählt allein die
Feststellung: Das Gate trifft auf einen Bestand, in dem die erste Abweichung
ein `A_FAIL` sein kann, dessen Ursache die Umgebung ist — und genau deshalb
steht die Klassifizierung aus 6.12.4 am Anfang dieses Entwurfs und nicht am
Ende.

#### 6.12.18 Was ein Durchlass des Gates aussagt — und was nicht

Der Kettengrundsatz aus 6.8.4 gilt für das Gate unverändert und eine Ebene
höher:

> **Ein Durchlass des Gates heisst: `make dod` ist in dem genannten
> Arbeitsbaum nachweisbar gelaufen und hat nichts von dem gefunden, was die
> Kette sucht — bei terminierten Lagen C mit Ausnahme der genannten Schritte,
> die nicht geurteilt haben. Er heisst nie: die Arbeit ist richtig.** Die
> menschlich bestätigten Bedingungen D13 bis D17 stehen genau deshalb daneben
> und werden durch keinen Durchlass ersetzt.

Dazu vier Aussagen, die ein Durchlass **nicht** trägt und die deshalb hier
stehen:

1. Nichts über einen anderen Arbeitsbaum als den genannten (G12).
2. Nichts, wenn er wegen `stop_hook_active` erfolgte (G9) — dort hat das Gate
   überhaupt nicht durchgesetzt, es hat nur nicht blockiert.
3. Nichts über die Arbeit einer Rolle, für die er wegen fehlender verändernder
   Werkzeuge erfolgte (G13).
4. **Nichts, was D20 nicht selbst trägt.** Das Gate stützt sich auf die ganze
   Kette und damit auch auf D20, und D20s Werkzeug ist nach Eskalationsregel
   3.4 abgebrochen und **nicht abgenommen** (O-15); seine Selbstauskunft erklärt
   die Liste ihrer Grenzen ausdrücklich für unvollständig. Der Auftraggeber hat
   verlangt, das hier ausdrücklich festzuhalten, und die Feststellung wiegt seit
   dem 2026-09-02 schwerer als am 2026-09-01: Mit dem flachen Klon (G16) und dem
   Fund auf `origin/main` ist nun **belegt**, dass D20 rote Läufe erzeugt, deren
   Ursache die Umgebung ist. Die Aufnahme in die Kette hängt weiterhin nicht an
   der Abnahme — ein Schritt, der nur Funde hinzufügt, macht die Aussage der
   Kette nie schwächer —, aber ein Gate, das jede Arbeitseinheit an dieses
   Werkzeug bindet, macht seine Abnahme dringender. O-15 bleibt offen, mit
   unverändertem Termin vor der Freigabe des Grundgerüsts.
5. **Nichts über eine Sitzung, in der `TaskCompleted` nie feuert** *(Runde 1)*.
   Das Ereignis setzt nach der gelesenen Referenz voraus, dass eine Aufgabe über
   das Aufgabenwerkzeug abgeschlossen wird oder ein Mitglied eines Teams seinen
   Zug mit offenen Aufgaben beendet. Wird in einer Sitzung keine Aufgabenliste
   geführt, bleiben allein `Stop` und `SubagentStop` — und die leisten je
   Beendigungsversuch eine erzwungene Fortsetzung, nicht mehr (6.12.2). Ein
   Durchlass sagt dann nur, dass in diesem Augenblick nichts gefunden wurde, und
   die Aussage "die Aufgabe war nicht abschliessbar" hat in einer solchen
   Sitzung überhaupt keinen Träger. Welcher der beiden Wege beschritten wird,
   entscheidet der Auftraggeber (O-23); bis dahin ist dieser Satz die ehrliche
   Reichweite des Entwurfs.

**Zwei Berichtigungen an dieser Datei.**

**Erstens, die Kopfzeile.** Beim Nachführen ist aufgefallen, dass sie die
**elfte** Fortschreibung vom 2026-09-01 nicht führt — sie endete bei der
zehnten. Die Lücke ist am 2026-09-02 geschlossen und als Nachtrag
gekennzeichnet; der Abschnitt 6.11 selbst blieb unverändert.

**Zweitens, die Tabelle der offenen Punkte in Abschnitt 8 — eine Formberichtigung
ohne Inhaltsänderung** *(Runde 2 der Prüfung, 2026-09-02)*. Seit O-11 standen
zwischen den Zeilen jener Tabelle Leerzeilen: zwischen O-10 (neu gefasst) und
O-11, vor O-13, vor O-14, vor O-16 und, mit den neuen Punkten dieser
Fortschreibung, vor O-19 bis O-23. Eine Leerzeile beendet in Markdown die
Tabelle; die betroffenen Zeilen wurden deshalb nicht als Tabellenzeilen
dargestellt, sondern als einzelne Textfragmente ohne Kopfzeile — die Spalten
"Warum heute nicht entscheidbar", "Wer entscheidet" und "Spätestens" waren dort
für einen Leser nicht mehr als Spalten erkennbar. Alle Leerzeilen innerhalb der
Tabelle sind geschlossen; **kein Wort einer Zeile ist geändert, keine Zeile
gelöscht, keine hinzugefügt.** Das ist genau der Schaden, gegen den der als
O-22 eingeordnete Struktur- und Tabellenprüfer gebaut werden soll, und er ist
hier am eigenen Dokument eingetreten, bevor das Werkzeug besteht — ein Beleg
für O-22, den niemand herstellen musste.

Beide Male gilt derselbe Vorgang wie in 6.11.5: Eine Berichtigung wird vermerkt,
nicht stillschweigend vorgenommen, und die frühere Fassung wird nicht gelöscht.

#### 6.12.19 G17 — Was der Selbsttest zu decken hat

`.claude/rules/claude-konfiguration.md` verlangt: "Jedes Hook-Skript wird vor
dem Einbau gegen einen blockierenden und einen durchzulassenden Fall geprüft.
Ein ungetestetes Gate ist kein Gate." Das Abnahmekriterium
`R3-Q-001_gate_blockiert` verlangt dasselbe in drei Fällen. Beides ist
dieselbe Forderung und braucht keinen zusätzlichen Backlog-Eintrag (so schon
der zweite Achtung-Hinweis bei R3-Q-001).

**Zwei Prüfebenen, und keine ersetzt die andere.**

- **Die Formprüfungen gegen eine Attrappe von `make dod`.** Nur so lassen sich
  Lagen herstellen, die am heutigen Bestand nicht herstellbar sind — ein
  `A_FAIL` bei D3, ein `VERLETZT` bei D19, eine fehlende Marke, ein
  Rückgabewert 7. Die Attrappe druckt eine Übersicht in der Form aus G7 und
  lebt ausschliesslich im Prüfaufbau; sie steht **nie** in der versionierten
  `.claude/settings.json`.
- **Je ein roter und ein grüner Lauf gegen das echte `Makefile`.** Sonst wäre
  die Formannahme des Gates nur gegen sich selbst geprüft. Der grüne Lauf
  braucht einen **Scheinbaum**, weil `PROJ` sich nicht überschreiben lässt und
  aus dem Pfad des Makefiles hergeleitet wird: ein eigenes Git-Repository mit
  `CLAUDE.md`, den beiden Bezugsdokumenten in prüfbarer Form, dem echten
  Makefile, dem echten Belegprüfer samt Ausnahmeliste, Attrappen für die vier
  noch nicht gebauten Skripte und einer `gitleaks`-Attrappe im Suchpfad. Ob ein
  solcher Baum mit dem **echten** Belegprüfer grün wird, ist mit einem
  ausgeführten Lauf festzustellen und wird hier **nicht behauptet**; fällt es
  anders aus, ist der Befund zu melden und nicht der Scheinbaum
  zurechtzubiegen.

**Was zu decken ist.** Diese Tabelle gilt seit dem 2026-09-03 in der Fassung
von **6.12.25** (Entscheid des Auftraggebers zu O-24): Sie führt keine
mehrteiligen Erwartungen mehr, sondern je Zeile **genau eine** messbare
Zusicherung mit einer dauerhaften Kennung `Z-nnn`; die Regeln zu Kennungen,
Rücknahme und zur mechanischen Deckung durch den Selbsttest stehen dort.

**Jede Zusicherung nennt ihren Messumfang** *(6.12.25 f, Befunde S4-01 und
DT4-02 aus Runde 4)*: den **Kanal** — Rückgabewert, Standardausgabe,
Fehlerausgabe, Zählerdatei, eine Datei an einem benannten Ort, ein Beobachter
ohne Wartezeit —, das **Ereignis**, wo der Fall mehr als eines umfasst, und die
**Anzahl**, wo es darauf ankommt. Die Prüfung im Selbsttest misst genau diesen
Umfang, nicht weniger. Umfasst der Fall genau ein Ereignis, ist es mit dem Fall
benannt und wird in der Spalte Zusicherung nicht wiederholt (V13). Die am
2026-09-03 präzisierten Zeilen tragen dafür **keinen** neuen Herkunftsvermerk:
Ihre Zusicherung ist unverändert, ausdrücklich geworden ist allein der
Messumfang; Herkunft dieser Präzisierung ist 6.12.25 f für die ganze Tabelle.

**Seit dem 2026-09-03 trägt die Tabelle zwei weitere Spalten** *(6.12.26,
Entscheid des Auftraggebers zu O-25; Befunde S5-01 und DT5-01 aus Runde 5)*:
**Kanal** — ein Wert aus dem abschliessenden Vorrat, den 6.12.26 a definiert,
den der Selbsttest je Kennung mitmeldet und der mechanisch gegen die Tabelle
abgeglichen wird — und **Mutation** — die Änderung am Prüfgegenstand, die genau
diese Zusicherung fehlschlagen lassen muss; ihre ausführbare Form steht in
`scripts/dod-gate-mutationen.txt` (6.12.26 b). Die 16 in Runde 5 beanstandeten
Zeilen tragen deshalb **keinen** neuen Herkunftsvermerk: Ihr Wortlaut ist
unverändert, umgestellt wird allein die Messung auf den in der Zeile genannten
Kanal (6.12.26 c). Eigene Herkunft tragen allein `Z-018` und `Z-111`, deren
Fall beziehungsweise Zusicherung sich ändert.

**Seit dem 2026-09-06 trägt die Tabelle eine siebte Spalte** *(6.12.27,
Entscheid des Auftraggebers zu O-26; Befunde `DT8-01` bis `DT8-06` aus Runde
8)*: **Prädikat** — die Messart, mit der die Zusicherung auf ihrem Kanal
gemessen wird, aus einem geschlossenen Vorrat, von der Messhülle mitgemeldet
und je Kennung gegen die Tabelle abgeglichen; eine Abweichung endet ungleich 0.
Die Spaltenfolge lautet damit **Kennung, Fall, Kanal, Prädikat, Zusicherung,
Mutation, Herkunft**; das Prädikat steht **zwischen** Kanal und Zusicherung,
damit es wie der Kanal an einer festen Spalte und nicht im Fliesstext steht.
Der Vorrat, die Bindungsregeln zwischen Wortlaut und Prädikat und die Methode,
nach der die Spalte gefüllt worden ist, stehen in **6.12.27 b**. Dazu treten
zwei Deckungsprüfungen über dieselbe Tabelle: die **Schlüsseldeckung** gegen
die Klassifizierungstabelle 6.12.4 (**6.12.27 c**) und die
**Grammatikdeckung** gegen die Elementtabelle in 6.12.7 (**6.12.27 d**);
verneinende Grammatikzeilen tragen dafür in der Spalte Fall am Anfang das
Etikett `Grammatik <KUERZEL>: `. Die Zeilen `Z-156` bis `Z-184` sind mit
6.12.27 e hinzugekommen; `Z-040` und `Z-080` sind dort berichtigt und tragen
den Vermerk in ihrer Herkunft. Die übrigen Zeilen tragen **keinen** neuen
Herkunftsvermerk: Ihr Wortlaut ist unverändert, hinzugekommen ist allein die
ausdrückliche Messart; Herkunft dieser Ergänzung ist 6.12.27 b für die ganze
Tabelle (dieselbe Regel wie in 6.12.25 f und 6.12.26 a).

| Kennung | Fall | Kanal | Prädikat | Zusicherung | Mutation | Herkunft |
|---|---|---|---|---|---|---|
| Z-001 | Kette mit `A_FAIL` | rc | gleich | Rückgabewert 2 | Im `A_FAIL`-Zweig der Markenauswertung endet das Gate mit 3, bevor es blockiert | Entwurf G17 |
| Z-002 | Kette grün, ohne Lage C | rc | gleich | Rückgabewert 0 | Der letzte Ausgang 0 (sauberes Grün) endet mit 3 | Entwurf G17 |
| Z-003 | Aussage A02: Kette grün, ohne Lage C | stdout | leer | Standardausgabe leer — kein einziges Byte | Vor dem letzten Ausgang 0 wird eine Zeile auf die Standardausgabe geschrieben | Entwurf G17; 6.12.15 |
| Z-004 | Aussage A03: Kette grün, ohne Lage C | stderr | leer | Fehlerausgabe leer | Vor dem letzten Ausgang 0 wird eine Zeile auf die Fehlerausgabe geschrieben | Entwurf G17; 6.12.15 |
| Z-005 | Terminierte Lage C, Eintrag gültig | rc | gleich | Rückgabewert 0 | Der Durchlasszweig für terminierte Lagen C endet mit 3 | Entwurf G17 |
| Z-006 | Aussage A01: Terminierte Lage C, Eintrag gültig | stdout | einzelfeld | Die Standardausgabe ist genau ein JSON-Objekt, dessen einziges Feld `systemMessage` heisst | Das JSON-Objekt der Durchlassmeldung erhält ein zweites Feld neben `systemMessage` | Entwurf G17; 6.12.15 |
| Z-007 | Aussage A06: Terminierte Lage C, Eintrag gültig | stdout | enthaelt | Die `systemMessage` auf der Standardausgabe nennt die Kennung des Kettenschritts, der nicht geurteilt hat | Aus der Durchlassmeldung fällt die Aufzählung der gedeckten Schritte weg | Entwurf G17 |
| Z-008 | Lage C ohne Eintrag in der Liste | rc | gleich | Rückgabewert 2 | Im Zweig der ungedeckten Lage C endet das Gate mit 3 | Entwurf G17 |
| Z-009 | Eintrag vorhanden, Prüfmittel existiert inzwischen | rc | gleich | Rückgabewert 2 | Selbstprüfung 2 (der Gegenstand besteht im Baum bereits) auf `false` gesetzt | Entwurf G17 |
| Z-010 | Eintrag vorhanden, Prüfmittel existiert inzwischen | stderr | enthaelt | Die Fehlerausgabe führt den beanstandeten Eintrag im Wortlaut seiner Zeile auf | Aus der Meldung der Selbstprüfung 2 fällt der beanstandete Pfad weg | Entwurf G17 |
| Z-011 | Eintrag vorhanden, Schritt meldet `A_OK` | rc | gleich | Rückgabewert 2 | Selbstprüfung 3 (Eintrag zu einem Schritt, der nicht C meldet) auf `false` gesetzt | Entwurf G17 |
| Z-012 | Eintrag vorhanden, Schritt meldet `A_OK` | stderr | enthaelt | Die Fehlerausgabe führt den beanstandeten Eintrag im Wortlaut seiner Zeile auf | Aus der Meldung der Selbstprüfung 3 fallen Schlüssel und Zeilennummer weg | Entwurf G17 |
| Z-013 | Eintrag ohne Grund | rc | gleich | Rückgabewert 2 | Selbstprüfung 4 nimmt jeden Grund an (der Musterzweig `ADR 0002, ` wird zum Auffangmuster) | Entwurf G17 |
| Z-014 | Eintrag mit nicht terminierbarem Prüfmittel | rc | gleich | Rückgabewert 2 | Die Prüfung auf die nicht terminierbaren D-Nummern D19 und D20 auf `false` gesetzt | Entwurf G17 |
| Z-015 | Eintrag mit absolutem Pfad | rc | gleich | Rückgabewert 2 | Der Musterzweig für absolute Pfade (`/*`) auf ein nie zutreffendes Muster gesetzt | Entwurf G17 |
| Z-016 | Marke nennt ein anderes Prüfmittel als der Schlüssel | rc | gleich | Rückgabewert 2 | Selbstprüfung 5 entfällt: ein Eintrag deckt unabhängig vom `FEHLT=`-Wert | Entwurf G17 |
| Z-017 | `stop_hook_active` wahr bei roter Kette | rc | gleich | Rückgabewert 0 | Der Durchlass wegen `stop_hook_active` endet mit 3 | Entwurf G17 |
| Z-018 | Aussage E05: `stop_hook_active` wahr bei roter Kette, Zählerdatei vor dem Aufruf mit Schlüssel und Stand 2 angelegt | zaehler | gleich | Die Zählerdatei trägt nach dem Aufruf unverändert denselben Schlüssel und den Stand 2 | Der Durchlass wegen `stop_hook_active` löscht den Zähler | Entwurf G17; Runde 5, S5-03 (6.12.26 c) |
| Z-019 | D19 `VERLETZT` | rc | gleich | Rückgabewert 2 | Im D19-Zweig `VERLETZT` endet das Gate mit 3 | Entwurf G17 |
| Z-020 | D19 Lage C | rc | gleich | Rückgabewert 2 | Im D19-Zweig Lage C endet das Gate mit 3 | Entwurf G17 |
| Z-021 | Fehlendes `jq` | rc | gleich | Rückgabewert 2 | Der `jq`-Zweig endet mit 3 statt mit 2 | Entwurf G17 |
| Z-022 | Fehlendes `jq` | stderr | enthaelt | Die Fehlerausgabe nennt `jq` | Im `jq`-Block wird jede Nennung von `jq` ersetzt (Schlüssel, Meldung, Beschaffungsweg) | Entwurf G17 |
| Z-023 | Fehlendes `git` | rc | gleich | Rückgabewert 2 | Der `git`-Block endet mit 3, bevor er blockiert | Entwurf G17 |
| Z-024 | Fehlendes `git` | stderr | enthaelt | Die Fehlerausgabe nennt `git` | Im `git`-Block wird jede Nennung von `git` ersetzt (Schlüssel, Meldung, Beschaffungsweg) | Entwurf G17 |
| Z-025 | Fehlendes `make` | rc | gleich | Rückgabewert 2 | Der `make`-Block endet mit 3, bevor er blockiert | Entwurf G17 |
| Z-026 | Fehlendes `make` | stderr | enthaelt | Die Fehlerausgabe nennt `make` | Im `make`-Block wird jede Nennung von `make` ersetzt | Entwurf G17 |
| Z-027 | Fehlendes `Makefile` | rc | gleich | Rückgabewert 2 | Der `Makefile`-Block endet mit 3, bevor er blockiert | Entwurf G17 |
| Z-028 | Fehlendes `Makefile` | stderr | enthaelt | Die Fehlerausgabe nennt `Makefile` | Der gesuchte Dateiname und jede Nennung von `Makefile` werden auf `Mk` umgeschrieben | Entwurf G17 |
| Z-029 | Fehlendes `timeout` | rc | gleich | Rückgabewert 2 | Der `timeout`-Block endet mit 3, bevor er blockiert | Entwurf G17 |
| Z-030 | Fehlendes `timeout` | stderr | enthaelt | Die Fehlerausgabe nennt `timeout` | Im `timeout`-Block wird jede Nennung von `timeout` ersetzt | Entwurf G17 |
| Z-031 | Fehlendes `flock` | rc | gleich | Rückgabewert 2 | Der `flock`-Block endet mit 3, bevor er blockiert | Entwurf G17 |
| Z-032 | Fehlendes `flock` | stderr | enthaelt | Die Fehlerausgabe nennt `flock` | Im `flock`-Block wird jede Nennung von `flock` ersetzt | Entwurf G17 |
| Z-033 | Fehlende Liste der terminierten Lagen | rc | gleich | Rückgabewert 2 | Der Block wegen fehlender Liste endet mit 3 | Entwurf G17 |
| Z-034 | Fehlende Liste der terminierten Lagen | stderr | enthaelt | Die Fehlerausgabe nennt den Pfad der Liste | Der Pfad der Liste zeigt auf einen anderen Dateinamen | Entwurf G17 |
| Z-035 | Nicht beschreibbares Zustandsverzeichnis bei roter Kette | rc | gleich | Rückgabewert 2 | Bei nicht beschreibbarem Zustandsverzeichnis endet das Gate mit 3, bevor es urteilt | Entwurf G17 |
| Z-036 | Aussage E22: Nicht beschreibbares Zustandsverzeichnis bei roter Kette | stderr | enthaelt | Die Fehlerausgabe trägt den Zusatz, dass nicht gezählt werden kann | Der Zusatz zum nicht beschreibbaren Zustandsverzeichnis wird auf die leere Zeichenkette gesetzt | Entwurf G17 |
| Z-037 | Innere Zeitüberschreitung | rc | gleich | Rückgabewert 2 | Der Zweig der inneren Zeitüberschreitung endet mit 3 | Entwurf G17 |
| Z-038 | Dreimal derselbe Schlüssel | zaehler | gleich | Die Zählerdatei trägt nach dem **dritten** Ereignis den Stand 3 | Der Zähler wird bei gleichem Schlüssel nicht mehr erhöht (er bleibt auf 1) | Entwurf G17 |
| Z-039 | Dreimal derselbe Schlüssel | rc | gleich | Rückgabewert 2 beim dritten Ereignis | Der Zweig des dritten Ereignisses endet mit 3 | Entwurf G17 |
| Z-040 | Aussage E14: Dreimal derselbe Schlüssel | stderr | zeile-woertlich | Die Fehlerausgabe des **dritten** Ereignisses trägt die Zeile `Eskalation 3.4: <Schlüssel>` als ganze Zeile | Die Eskalationsschwelle im Gate wird von `-ge 4` auf `-ge 3` gesetzt (Fremdmutation `M-01` aus Runde 8): beim dritten Ereignis greift dann der Zweig ab dem vierten Mal, dessen Meldung die Übergabezeile nur noch eingebettet in den Satz "erwartet eine Datei ... mit der woertlichen Zeile" trägt — die eigenständige Zeile entfällt | Entwurf G17; berichtigt 2026-09-06 (6.12.27 e, DT8-01) |
| Z-041 | Übergabedatei mit der geforderten Zeile, neu oder geändert | rc | gleich | Rückgabewert 0 | Der Eskalations-Durchlass endet mit 3 | Entwurf G17 |
| Z-042 | Übergabedatei mit der geforderten Zeile, neu oder geändert | zaehler | gleich | Die Zählerdatei trägt nach dem **vierten** Ereignis den Stand 4 | Die Zählerdatei trägt immer die Zahl 1 statt des erreichten Standes | Entwurf G17 |
| Z-043 | Übergabedatei mit der geforderten Zeile, committet | datei | existiert | Die Ausgabe von `git ls-tree -r HEAD` vor dem Aufruf des Gates führt die Datei — der Fall hat sie wirklich in `HEAD` | keine — Vorbedingung des Aufbaus (Grund 2) | Nachtrag 6.12.24 i, Befund DT-B4 |
| Z-044 | Aussage E16: Übergabedatei mit der geforderten Zeile, committet | rc | gleich | Rückgabewert 0 | Der Eskalations-Durchlass endet mit 3 | Runde 1, B6 |
| Z-045 | Übergabedatei nur in einem älteren Commit | datei | fehlt | Die Ausgabe von `git ls-tree -r HEAD` vor dem Aufruf führt die Datei **nicht**, die eines älteren Commits dagegen schon | keine — Vorbedingung des Aufbaus (Grund 2) | Entwurf G17 |
| Z-046 | Aussage E17: Übergabedatei nur in einem älteren Commit | rc | gleich | Rückgabewert 2 | Die Suche nach der Übergabedatei wird von `HEAD` auf die ganze Historie ausgeweitet | Entwurf G17 |
| Z-047 | Aussage E19: Dieselbe Eskalation auf `TaskCompleted` | rc | gleich | Rückgabewert 2 | Die Einschränkung des Eskalations-Durchlasses auf `Stop` und `SubagentStop` entfällt | Runde 1, B5 |
| Z-048 | Dieselbe Eskalation auf `TaskCompleted` | datei | existiert | Die Ausgabe von `git ls-tree -r HEAD` vor dem Aufruf führt die Übergabedatei mit der geforderten Zeile — der Durchlass scheitert nicht an ihrem Fehlen | keine — Vorbedingung des Aufbaus (Grund 2) | Runde 1, B5 |
| Z-049 | Lauf mit `A_FAIL`, zwei ungedeckten Lagen C und D19 `VERLETZT` zugleich | rc | gleich | Rückgabewert 2 | Im `A_FAIL`-Zweig der Markenauswertung endet das Gate mit 3 | Runde 1, B7 |
| Z-050 | Aussage E21: Lauf mit `A_FAIL`, zwei ungedeckten Lagen C und D19 `VERLETZT` zugleich | zaehler | gleich | Die Zählerdatei trägt als Schlüssel die **erste** Abweichung in Kettenreihenfolge | Nicht mehr die erste, sondern die letzte Abweichung setzt den Zählschlüssel | Runde 1, B7 |
| Z-051 | Lauf mit `A_FAIL`, zwei ungedeckten Lagen C und D19 `VERLETZT` zugleich | stderr | enthaelt | Die Fehlerausgabe nennt **jede** `A_FAIL`-Marke des Laufs | Die Ausgabe der weiteren Abweichungen entfällt | Runde 3, S3-01 (6.12.25 b) |
| Z-052 | Lauf mit `A_FAIL`, zwei ungedeckten Lagen C und D19 `VERLETZT` zugleich | stderr | enthaelt | Die Fehlerausgabe nennt **jede** ungedeckte Lage C mit ihrem `FEHLT=`-Wert | Ungedeckte Lagen C werden nicht mehr in die Sammlung aller Abweichungen aufgenommen | Runde 3, S3-01 (6.12.25 b) |
| Z-053 | Lauf mit `A_FAIL`, zwei ungedeckten Lagen C und D19 `VERLETZT` zugleich | stderr | enthaelt | Die Fehlerausgabe nennt den D19-Befund | Der D19-Befund wird nicht mehr in die Sammlung aller Abweichungen aufgenommen | Runde 3, S3-01 (6.12.25 b) |
| Z-054 | Marke mit `FEHLT=` und `SCHWELLE=` zugleich (D3, D6 oder D8 in Lage C) | stderr | enthaelt | Die Fehlerausgabe nennt als `FEHLT=`-Wert genau den Pfad, ohne den `SCHWELLE=`-Teil | Der `FEHLT=`-Wert wird aus der ganzen Marke statt aus ihrer `FEHLT=`-Gruppe gelesen | Runde 1, B8 |
| Z-055 | Marke mit `FEHLT=` und `SCHWELLE=` zugleich | rc | gleich | Bei gedecktem Eintrag Rückgabewert 0 — die Deckung wird am `FEHLT=`-Teil entschieden | Der Deckungszweig wird auf `false` gesetzt: kein Eintrag deckt mehr | Runde 1, B8 |
| Z-056 | D19-Zeile `OHNE_BEFUND`, ohne Zusatztext | rc | gleich | Rückgabewert 0 bei sonst grüner Kette — die Zeile ist als `OHNE_BEFUND` gelesen | `OHNE_BEFUND` entfällt aus der Grammatik der D19-Zeile | Runde 1, B9; N-02 |
| Z-057 | D19-Zeile `OHNE_BEFUND`, mit Zusatztext | rc | gleich | Rückgabewert 0 bei sonst grüner Kette — der Zusatztext ändert die Zuordnung nicht | Der optionale Zusatztext entfällt aus der Grammatik der D19-Zeile | Runde 1, B9; N-02 |
| Z-058 | D19-Zeile `VERLETZT`, ohne Zusatztext | stderr | enthaelt | Die Fehlerausgabe nennt den gelesenen D19-Befund `VERLETZT` | Jede Nennung von `VERLETZT` in Schlüssel und Meldung wird ersetzt | Runde 1, B9; N-02 |
| Z-059 | D19-Zeile `VERLETZT`, mit Zusatztext | stderr | enthaelt | Die Fehlerausgabe nennt den gelesenen D19-Befund `VERLETZT` | Der optionale Zusatztext entfällt aus der Grammatik der D19-Zeile | Runde 1, B9; N-02 |
| Z-060 | D19-Zeile `B`, ohne Zusatztext | stderr | enthaelt | Die Fehlerausgabe nennt den gelesenen D19-Befund als Lage `B` | Jede Nennung der Lage `B` in Schlüssel und Meldung wird ersetzt | Runde 1, B9; N-02 |
| Z-061 | D19-Zeile `B`, mit Zusatztext | stderr | enthaelt | Die Fehlerausgabe nennt den gelesenen D19-Befund als Lage `B` | Der optionale Zusatztext entfällt aus der Grammatik der D19-Zeile | Runde 1, B9; N-02 |
| Z-062 | D19-Zeile `C`, ohne Zusatztext | stderr | enthaelt | Die Fehlerausgabe nennt den gelesenen D19-Befund als Lage `C` | Jede Nennung der D19-Lage `C` in Schlüssel und Meldung wird ersetzt | Runde 1, B9; N-02 |
| Z-063 | D19-Zeile `C`, mit Zusatztext | stderr | enthaelt | Die Fehlerausgabe nennt den gelesenen D19-Befund als Lage `C` | Der optionale Zusatztext entfällt aus der Grammatik der D19-Zeile | Runde 1, B9; N-02 |
| Z-064 | `TaskCompleted` bei roter Kette | rc | gleich | Rückgabewert 2 | Am Ausgang endet das Gate bei `TaskCompleted` mit 3 statt zu blockieren | Entwurf G17 |
| Z-065 | `SubagentStop` der echten Rollendatei `static-software-tester` (`Bash`, ohne `Edit`/`Write`/`NotebookEdit`) | rc | gleich | Rückgabewert 0 | `Bash` gilt als veränderndes Werkzeug (das Muster wird um `Bash` erweitert) | Runde 1, B1 |
| Z-066 | `SubagentStop` der echten Rollendatei `pentester` | rc | gleich | Rückgabewert 0 | Der Durchlass für Rollen ohne Schreibrecht endet mit 3 | Runde 1, B1 |
| Z-067 | `SubagentStop` einer Rolle ohne veränderndes Werkzeug | datei | fehlt | Das Aufrufprotokoll der `make dod`-Attrappe (Datei im Prüfaufbau) verzeichnet **keinen** Aufruf — die Kette läuft nicht | `Bash` gilt als veränderndes Werkzeug (das Muster wird um `Bash` erweitert) | Runde 1, B1 |
| Z-068 | `SubagentStop` einer Rolle ohne veränderndes Werkzeug | datei | gleich | Die `sha256sum`-Prüfsummen der im Scheinbaum verwendeten Rollendateien stimmen mit denen aus `.claude/agents/` überein | keine — Vorbedingung des Aufbaus (Grund 2) | Nachtrag 6.12.24 i, Befund N-03 |
| Z-069 | `SubagentStop` der echten Rollendatei `devops-engineer` (mit `Edit`/`Write`) | datei | existiert | Das Aufrufprotokoll der Attrappe verzeichnet **einen** Aufruf | Jede Rolle gilt als nicht schreibberechtigt (Vorbelegung auf 0) | Nachtrag 6.12.24 i |
| Z-070 | `SubagentStop` der echten Rollendatei `devops-engineer` | rc | gleich | Rückgabewert 2 bei roter Kette — das Gate urteilt | Jede Rolle gilt als nicht schreibberechtigt (Vorbelegung auf 0) | Nachtrag 6.12.24 i |
| Z-071 | `agent_type`, der über `name:` aufzulösen ist und nicht über den Dateinamen | datei | fehlt | Das Aufrufprotokoll der Attrappe verzeichnet keinen Aufruf — die Rolle ist über `name:` aufgelöst | Die Rolle wird über den Dateinamen statt über das Feld `name:` aufgelöst | Runde 1, B2 |
| Z-072 | `agent_type`, der über `name:` aufzulösen ist | rc | gleich | Rückgabewert 0 | Die Rolle wird über den Dateinamen statt über das Feld `name:` aufgelöst | Runde 1, B2 |
| Z-073 | `SubagentStop` mit **unbekanntem** `agent_type` | datei | existiert | Das Aufrufprotokoll der Attrappe verzeichnet einen Aufruf | Ein unbekannter `agent_type` gilt als nicht schreibberechtigt | Entwurf G17 |
| Z-074 | `SubagentStop` mit unbekanntem `agent_type` | rc | gleich | Rückgabewert 2 bei roter Kette | Ein unbekannter `agent_type` gilt als nicht schreibberechtigt | Entwurf G17 |
| Z-075 | `SubagentStop` mit **leerem** `agent_type` | datei | existiert | Das Aufrufprotokoll der Attrappe verzeichnet einen Aufruf | Jede Rolle gilt als nicht schreibberechtigt (Vorbelegung auf 0) | Entwurf G17 |
| Z-076 | `SubagentStop` mit leerem `agent_type` | rc | gleich | Rückgabewert 2 bei roter Kette | Jede Rolle gilt als nicht schreibberechtigt (Vorbelegung auf 0) | Entwurf G17 |
| Z-077 | `SubagentStop` mit **mehrdeutigem** `agent_type` | datei | existiert | Das Aufrufprotokoll der Attrappe verzeichnet einen Aufruf | Die Bedingung "genau ein Treffer" wird auf "mindestens ein Treffer" aufgeweicht | Entwurf G17 |
| Z-078 | `SubagentStop` mit mehrdeutigem `agent_type` | rc | gleich | Rückgabewert 2 bei roter Kette | Die Bedingung "genau ein Treffer" wird auf "mindestens ein Treffer" aufgeweicht | Entwurf G17 |
| Z-079 | Flacher Klon | rc | gleich | Rückgabewert 2 | Im Zweig der ungedeckten Lage C endet das Gate mit 3 | Entwurf G17 |
| Z-080 | Flacher Klon | kette | enthaelt | Die **Beschaffen-Zeile zu D20** in der direkt aufgerufenen Kettenausgabe — die eigenständige Zeile, die der Lage-C-Zeile zu D20 (Form `[<D> <ziel>] LAGE C: <Text>`, 6.12.7) unmittelbar folgt — nennt den Beschaffungsweg `git fetch --unshallow`; gemessen wird auf dieser einen Zeile, nicht über die ganze Ausgabe | Im `Makefile` wird der Beschaffungsweg `git fetch --unshallow` durch einen anderen Text ersetzt | Entwurf G17; Kanal und Wortlaut nachgeführt 6.12.26 e; Messung isoliert 2026-09-06 (6.12.27 h, S8-05); Wortlaut berichtigt 2026-09-06 nach Bau-Befund (6.12.27 h, S8-05) |
| Z-081 | `cwd` in einem Unterverzeichnis des Baums, grüner Scheinbaum | rc | gleich | Rückgabewert 0 | Der geprüfte Baum wird roh aus `cwd` übernommen statt über `git` aufgelöst | Nachtrag 6.12.24 i, Entscheid a; B-02 |
| Z-082 | `cwd` in einem Unterverzeichnis des Baums | stdout | leer | Standardausgabe leer — bei sauberem Grün schweigt das Gate (6.12.15) | Vor dem letzten Ausgang 0 wird eine Zeile auf die Standardausgabe geschrieben | Berichtigt nach S3-03 |
| Z-083 | `cwd` in einem Unterverzeichnis des Baums | kette | gleich | Die Baumzeile der Kettenausgabe im Prüfaufbau nennt die physisch aufgelöste Wurzel des Arbeitsbaums | Im `Makefile` nennt die Baumzeile einen festen Fremdpfad statt `PROJ` | Nachtrag 6.12.24 i, Entscheid a |
| Z-084 | `cwd` mit Schrägstrich am Ende, grüner Scheinbaum | rc | gleich | Rückgabewert 0 | Der geprüfte Baum wird roh aus `cwd` übernommen statt über `git` aufgelöst | Nachtrag 6.12.24 i, Entscheid a; B-03 |
| Z-085 | `cwd` mit Schrägstrich am Ende | stdout | leer | Standardausgabe leer | Vor dem letzten Ausgang 0 wird eine Zeile auf die Standardausgabe geschrieben | Berichtigt nach S3-03 |
| Z-086 | `cwd` mit Schrägstrich am Ende | kette | gleich | Die Baumzeile der Kettenausgabe im Prüfaufbau nennt die Wurzel ohne Schrägstrich am Ende | Im `Makefile` trägt die Baumzeile einen Schrägstrich am Ende | Nachtrag 6.12.24 i, Entscheid a |
| Z-087 | `cwd` über einen Symlink auf den Baum, grüner Scheinbaum | rc | gleich | Rückgabewert 0 | Der geprüfte Baum wird roh aus `cwd` übernommen statt über `git` aufgelöst | Nachtrag 6.12.24 i, Entscheid a |
| Z-088 | `cwd` über einen Symlink | stdout | leer | Standardausgabe leer | Vor dem letzten Ausgang 0 wird eine Zeile auf die Standardausgabe geschrieben | Berichtigt nach S3-03 |
| Z-089 | `cwd` über einen Symlink | kette | gleich | Die Baumzeile der Kettenausgabe im Prüfaufbau nennt die physisch aufgelöste Wurzel, nicht den Pfad über den Symlink | Im `Makefile` wird `PROJ` mit `pwd -L` statt mit `pwd -P` bestimmt | Nachtrag 6.12.24 i, Entscheid a |
| Z-090 | `cwd` ausserhalb jedes Arbeitsbaums dieses Repositories | rc | gleich | Rückgabewert 0 im grünen Scheinbaum | Der Rückfall auf `${CLAUDE_PROJECT_DIR}` entfällt | Nachtrag 6.12.24 i, G12 |
| Z-091 | `cwd` ausserhalb jedes Arbeitsbaums | stdout | leer | Standardausgabe leer | Vor dem letzten Ausgang 0 wird eine Zeile auf die Standardausgabe geschrieben | Berichtigt nach S3-03 |
| Z-092 | `cwd` ausserhalb jedes Arbeitsbaums | kette | gleich | Die Baumzeile der Kettenausgabe im Prüfaufbau nennt die Wurzel von `${CLAUDE_PROJECT_DIR}` | Im `Makefile` nennt die Baumzeile einen festen Fremdpfad statt `PROJ` | Nachtrag 6.12.24 i, G12 |
| Z-093 | Zweiter Arbeitsbaum (`git worktree`), `cwd` darin | kette | gleich | Die Baumzeile der Kettenausgabe im Prüfaufbau nennt den **zweiten** Baum | Im `Makefile` nennt die Baumzeile einen festen Fremdpfad statt `PROJ` | Nachtrag 6.12.24 i, Befund DT-B5 |
| Z-094 | Zweiter Arbeitsbaum, `cwd` darin | rc | gleich | Rückgabewert 0 im grünen Scheinbaum | Der letzte Ausgang 0 (sauberes Grün) endet mit 3 | Nachtrag 6.12.24 i, G12 |
| Z-095 | Zweiter Arbeitsbaum, `cwd` darin | stdout | leer | Standardausgabe leer | Vor dem letzten Ausgang 0 wird eine Zeile auf die Standardausgabe geschrieben | Berichtigt nach S3-03 |
| Z-096 | Die Baumzeile der Kette nennt einen anderen Baum als den bestimmten | rc | gleich | Rückgabewert 2 | Der Zweig des Baum-Widerspruchs endet mit 3 | Nachtrag 6.12.24 i, Entscheid b |
| Z-097 | Die Baumzeile nennt einen anderen Baum als den bestimmten | zaehler | gleich | Die Zählerdatei trägt den Schlüssel `KETTE baum-widerspruch` | Der Schlüssel `KETTE baum-widerspruch` wird umbenannt | Nachtrag 6.12.24 i, Entscheid b |
| Z-098 | Weder `XDG_STATE_HOME` noch `HOME` gesetzt, rote Kette | rc | gleich | Rückgabewert 2 | Bei nicht bestimmbarem Zustandsverzeichnis endet das Gate mit 3, bevor es urteilt | Nachtrag 6.12.24 i, Entscheid c |
| Z-099 | Weder `XDG_STATE_HOME` noch `HOME` gesetzt, rote Kette | stderr | enthaelt | Die Fehlerausgabe trägt den Zusatz, dass nicht gezählt werden kann | Der Zusatz zum nicht bestimmbaren Zustandsverzeichnis wird auf die leere Zeichenkette gesetzt | Nachtrag 6.12.24 i, Entscheid c |
| Z-100 | Weder `XDG_STATE_HOME` noch `HOME` gesetzt, rote Kette | stderr | enthaelt | Der Zusatz auf der Fehlerausgabe sagt "nicht bestimmbar" und nicht "nicht beschreibbar" | Der Zusatz sagt "nicht beschreibbar" statt "nicht bestimmbar" | Runde 2, S-13 |
| Z-101 | Weder `XDG_STATE_HOME` noch `HOME` gesetzt, grüne Kette | rc | gleich | Rückgabewert 0 — nie 1 | Bei nicht bestimmbarem Zustandsverzeichnis endet das Gate mit 1 (Rückfall in den Befund B-01) | Nachtrag 6.12.24 i, Entscheid c |
| Z-102 | Weder `XDG_STATE_HOME` noch `HOME` gesetzt, grüne Kette | stdout | einzelfeld | Die Standardausgabe ist genau ein JSON-Objekt, dessen `systemMessage` allein diesen Zusatz trägt | Das JSON-Objekt erhält ein zweites Feld neben `systemMessage` | Runde 2, S-13 |
| Z-103 | Aussage A07: Weder `XDG_STATE_HOME` noch `HOME` gesetzt, grüne Kette | stdout | enthaelt | Der Zusatz in der `systemMessage` auf der Standardausgabe sagt "nicht bestimmbar" | Der Zusatz sagt "nicht beschreibbar" statt "nicht bestimmbar" | Runde 2, S-13 |
| Z-104 | Zustandsverzeichnis nicht beschreibbar | beobachter | existiert | Ein Beobachter ohne Wartezeit findet die Sperrdatei während des Laufs unter `/tmp` | Der Ausweichweg der Sperrdatei nach `/tmp` wird auf `false` gesetzt | Nachtrag 6.12.24 i, Entscheid e |
| Z-105 | Zustandsverzeichnis nicht beschreibbar | rc | gleich | Rückgabewert 2 bei roter Kette — das Urteil bleibt gleich | Bei nicht beschreibbarem Zustandsverzeichnis endet das Gate mit 3, bevor es urteilt | Nachtrag 6.12.24 i, Entscheid e |
| Z-106 | Zustandsverzeichnis **und** `/tmp` nicht beschreibbar | beobachter | fehlt | Ein Beobachter ohne Wartezeit findet während des ganzen Laufs an keinem der beiden Orte eine Sperrdatei | Der Ausweichweg der Sperrdatei zeigt auf ein beschreibbares Verzeichnis | Nachtrag 6.12.24 i, Entscheid e |
| Z-107 | Zustandsverzeichnis und `/tmp` nicht beschreibbar | rc | gleich | Rückgabewert 2 bei roter Kette | Bei nicht beschreibbarem Zustandsverzeichnis endet das Gate mit 3, bevor es urteilt | Nachtrag 6.12.24 i, Entscheid e |
| Z-108 | Zustandsverzeichnis und `/tmp` nicht beschreibbar | stderr | enthaelt | Die Fehlerausgabe nennt den Ausfall der Sperre | Der Hinweis auf die nicht aktive Sperre wird auf die leere Zeichenkette gesetzt | Nachtrag 6.12.24 i, Entscheid e |
| Z-109 | `TMPDIR` zeigt in den geprüften Baum | beobachter | ausserhalb | Ein Beobachter ohne Wartezeit findet während des Laufs im **Wegwerfverzeichnis des Gates** — dem Verzeichnis, das das Gate vor dem Anlegen bestimmt und der Kette als `TMPDIR` übergibt — eine Wegwerfdatei, deren physisch aufgelöster Pfad **ausserhalb** des geprüften Baums liegt | Vorab-Bestimmung des Zielverzeichnisses und Wache danach ausgeschaltet — die Wegwerfdatei entsteht und bleibt im geprüften Baum | Nachtrag 6.12.24 i, Entscheid f; Wortlaut verankert 2026-09-06 (6.12.27 j, S10-01) |
| Z-110 | `TMPDIR` zeigt in den geprüften Baum | — | — | **zurückgezogen** am 2026-09-03 (6.12.25 h, Befund S4-02): "D19 meldet `OHNE_BEFUND`" ist im Attrappenaufbau nicht messbar — die D19-Zeile stammt aus der vom Selbsttest selbst geschriebenen Attrappenausgabe, gemessen würde die eigene Vorgabe. Von der Deckung ausgenommen; die Sache trägt `Z-111` | — | Nachtrag 6.12.24 i, Entscheid f; Runde 4, S4-02 zurückgezogen (6.12.25 h) |
| Z-111 | `TMPDIR` zeigt in den geprüften Baum; die Attrappenkette hält ihre Wegwerfdatei mindestens 300 ms, damit ein Beobachtungsfenster besteht | beobachter | fehlt | Ein Beobachter ohne Wartezeit findet während des **gesamten** Laufs im **ganzen** geprüften Baum — alle Verzeichnisse ausser `.git` — keine Datei mit dem Muster `tmp.*` | Die Zeile mit der `TMPDIR`-Zuweisung vor `make` entfernt | Runde 3, DT3-B1 (6.12.25 c); Runde 4, DT4-01 präzisiert (6.12.25 h); Runde 5, DT5-01 (6.12.26 c) |
| Z-112 | Wegwerfdatei ausserhalb des Baums nicht anlegbar | rc | gleich | Rückgabewert 2 | Der Ausweichaufruf `mktemp -p /tmp` gilt immer als gelungen | Nachtrag 6.12.24 i, Entscheid f |
| Z-113 | Wegwerfdatei ausserhalb des Baums nicht anlegbar | zaehler | gleich | Die Zählerdatei trägt den Schlüssel `GATE mktemp` | Der Schlüssel `GATE mktemp` wird umbenannt | Nachtrag 6.12.24 i, Entscheid f |
| Z-114 | Das Verzeichnis der Wegwerfdatei ist physisch nicht auflösbar (im Selbsttest hergestellt als nicht vorhandenes Verzeichnis) | rc | gleich | Rückgabewert 2 — die Wache fällt geschlossen aus | keine — Grund 3, Schwester `Z-115`: unter der Verneinung (Wache fällt offen aus) scheitert die Umleitung der Kettenausgabe in das nicht vorhandene Verzeichnis, `make` startet nie, und das Gate blockiert mit `KETTE rueckgabewert=1` — der Rückgabewert 2 trennt nicht, der Schlüssel schon | Runde 3, S3-05 (6.12.25 d); Fall, Kanal und Wortlaut nachgeführt 6.12.26 f (Runde 7, S7-02); berichtigt 6.12.26 f Punkt 13 (Bau 4) |
| Z-115 | Das Verzeichnis der Wegwerfdatei ist physisch nicht auflösbar | zaehler | gleich | Die Zählerdatei trägt den Schlüssel `GATE mktemp` | Der Schlüssel `GATE mktemp` wird umbenannt | Runde 3, S3-05 (6.12.25 d) |
| Z-116 | Fehlendes `sha256sum` | rc | gleich | Rückgabewert 2 | Der `sha256sum`-Block endet mit 3, bevor er blockiert | Nachtrag 6.12.24 i, Entscheid g |
| Z-117 | Fehlendes `sha256sum` | stderr | enthaelt | Die Fehlerausgabe nennt `sha256sum` | Im `sha256sum`-Block wird jede Nennung von `sha256sum` ersetzt | Nachtrag 6.12.24 i, Entscheid g |
| Z-118 | Fehlendes `sha256sum` | stderr | enthaelt | Die Fehlerausgabe nennt den Beschaffungsweg | Der Beschaffungsweg fällt aus dem nächsten Schritt weg | Nachtrag 6.12.24 i, Entscheid g |
| Z-119 | Fehlendes `mktemp` | rc | gleich | Rückgabewert 2 | Der `mktemp`-Block endet mit 3, bevor er blockiert | Nachtrag 6.12.24 i, Entscheid g |
| Z-120 | Fehlendes `mktemp` | stderr | enthaelt | Die Fehlerausgabe nennt `mktemp` | Im `mktemp`-Block wird jede Nennung von `mktemp` ersetzt | Nachtrag 6.12.24 i, Entscheid g |
| Z-121 | Fehlendes `mktemp` | stderr | enthaelt | Die Fehlerausgabe nennt den Beschaffungsweg | Der Beschaffungsweg fällt aus dem nächsten Schritt weg | Nachtrag 6.12.24 i, Entscheid g |
| Z-122 | Liste mit je einer Verletzung der Selbstprüfungen 2, 4 und 6 in verschiedenen Zeilen | rc | gleich | Rückgabewert 2 | Der Block wegen fehlerhafter Liste endet mit 3 | Nachtrag 6.12.24 i, Entscheid h |
| Z-123 | Liste mit Verletzungen der Selbstprüfungen 2, 4 und 6 | datei | fehlt | Das Aufrufprotokoll der Attrappe verzeichnet keinen Aufruf — geblockt wird **vor** dem Lauf der Kette | Der Block wegen fehlerhafter Liste entfällt; die Kette läuft | Nachtrag 6.12.24 i, Entscheid h |
| Z-124 | Liste mit **zwei** fehlerhaften Zeilen, die **verschiedene** Selbstprüfungen verletzen (2 und 6) und damit **verschiedene** Schlüssel ergeben | zaehler | gleich | Die Zählerdatei trägt den Schlüssel aus der Zeile mit der **kleinsten** Zeilennummer und nicht den der späteren | Die Abbruchanweisung der strukturellen Selbstprüfungen (2, 4, 6) — das `break` **innerhalb des Blocks, der den Schlüssel der Strukturprüfung setzt** — durch ein Weiterlaufen ersetzt; dann bestimmt die letzte statt der ersten fehlerhaften Zeile den Schlüssel. Der `sed`-Ausdruck ist über diesen Block zu verankern (Bereichsadresse oder mitgeführtes Kontextmuster) und trifft keine Zeile ausserhalb | Nachtrag 6.12.24 i, Entscheid h; Fall und Mutation präzisiert 6.12.26 f (Runde 7, S7-02) |
| Z-125 | Aussage E07: Vierter Durchlass nach der Eskalation, danach erneut Blocks am selben Kriterium | zaehler | gleich | Die Zählerdatei trägt nach dem **vierten** Ereignis den Stand 4 | Der Durchlass nach der Eskalation löscht den Zähler | Nachtrag 6.12.24 i, Entscheid d; DT2-B1 |
| Z-126 | Vierter Durchlass, danach erneut Blocks | zaehler | gleich | Die Zählerdatei trägt nach dem **fünften** Ereignis den Stand 5 | Der Durchlass nach der Eskalation löscht den Zähler | Nachtrag 6.12.24 i, Entscheid d; DT2-B1 |
| Z-127 | Vierter Durchlass, danach erneut Blocks | zaehler | gleich | Die Zählerdatei trägt nach dem **sechsten** Ereignis den Stand 6 | Der Durchlass nach der Eskalation löscht den Zähler | Nachtrag 6.12.24 i, Entscheid d; DT2-B1 |
| Z-128 | Vierter Durchlass, danach erneut Blocks | stdout | enthaelt | Die `systemMessage` auf der Standardausgabe des **fünften** Ereignisses (Durchlass nach der Eskalation) nennt das fünfte Mal | Die Angabe des n-ten Males fällt aus der Meldung weg | Nachtrag 6.12.24 i, Entscheid d |
| Z-129 | Vierter Durchlass, danach erneut Blocks | stdout+stderr | fehlt+fehlt | Bei **jedem** Ereignis nach dem vierten Durchlass — geprüft am fünften Ereignis (`Stop`) und an einem `TaskCompleted` im selben Zustand — enthält **weder** die Standardausgabe **noch** die Fehlerausgabe die Forderung nach der Übergabedatei (Zeichenfolge "verlangt die Übergabedatei"). Das wörtliche Zitat der Übergabezeile `Eskalation 3.4: <Schlüssel>` als **Begründung des Durchlasses** ist zulässig und kein Verstoss | Die Durchlassmeldung nach der Eskalation trägt zusätzlich die Forderung nach der Übergabedatei | Runde 3, S3-07 (6.12.25 e); Runde 4, S4-01/DT4-02 berichtigt (6.12.25 g) |
| Z-130 | D12 in Lage C mit **mehreren** fehlenden Gegenständen | kette | gleich | Die **direkt aufgerufene Kettenausgabe** nennt in der Marke von D12 als `FEHLT=`-Wert den **ersten** Gegenstand | Im `Makefile` entfällt die Wache `[ -n "$fehlt" ] \|\|` vor dem zweiten Gegenstand von D12 (`scripts/nachweise-vollstaendig.sh`); der letzte statt des ersten fehlenden Gegenstands wird als `FEHLT=`-Wert genannt — Ziel der Mutation ist das `Makefile`, nicht das Gate | Nachtrag 6.12.24 i, Befund N-08; Kanal und Wortlaut nachgeführt 6.12.26 e; Mutation auf das `Makefile` verlegt 6.12.26 f Punkt 13 (Bau 4) |
| Z-131 | `TMPDIR` in den Baum, und die **Kette selbst** legt eine Wegwerfdatei an (Ziele `nachweise`, `abdeckung`) | datei | ausserhalb | Das im Aufrufprotokoll der Attrappe verzeichnete, an `make dod` übergebene `TMPDIR` liegt ausserhalb des geprüften Baums | Die Zeile mit der `TMPDIR`-Zuweisung vor `make` entfernt | Nachtrag 6.12.24 f, Befund DT2-B2 |
| Z-132 | `TMPDIR` in den Baum, Kette legt selbst an; die Attrappenkette schreibt das ihr wirksam übergebene `TMPDIR` in eine Spurdatei an einem benannten Ort **ausserhalb** des geprüften Baums | datei | ausserhalb | Die Spurdatei nennt ein `TMPDIR`, das ausserhalb des geprüften Baums liegt — die **Kette selbst** sieht die Umlenkung, nicht nur der Aufruf trägt sie | Die Zeile mit der `TMPDIR`-Zuweisung vor `make` entfernt | Nachtrag 6.12.24 f, Befund DT2-B2; Fall, Kanal und Wortlaut nachgeführt 6.12.26 f (Runde 7, S7-02) |
| Z-133 | Baumzeile, D19 `OHNE_BEFUND`, Rückgabewert 0, **null** Marken und eine Schlusszeile **Form 1**, die genau `0 gueltige Marken gezaehlt` nennt — gelesene und genannte Zahl stimmen damit überein, sodass allein die Forderung nach mindestens einer Marke den Block trägt | rc | gleich | Rückgabewert 2 — kein stummer Durchlass mit 0 | Der Disjunkt "gezählte Markenzahl gleich 0" entfällt; der zweite Disjunkt (gelesene Zahl ungleich genannter Zahl) trägt in diesem Fall nichts, der Lauf ginge durch | Nachtrag 6.12.24 k, Befund S-11; Fall, Wortlaut und Mutation präzisiert 6.12.26 f (Runde 7, S7-02) |
| Z-134 | Form-1-Schlusszeile mit null Marken | zaehler | gleich | Die Zählerdatei trägt den Schlüssel `KETTE ausgabe-unlesbar` | Der Schlüssel `KETTE ausgabe-unlesbar` wird umbenannt | Nachtrag 6.12.24 k, Befund S-11 |
| Z-135 | Schlusszeile Form 1 nennt eine andere Zahl, als Marken gelesen wurden | rc | gleich | Rückgabewert 2 | Der Vergleich von gelesener und genannter Markenzahl entfällt | Nachtrag 6.12.24 k |
| Z-136 | Schlusszeile Form 1 mit abweichender Zahl | zaehler | gleich | Die Zählerdatei trägt den Schlüssel `KETTE ausgabe-unlesbar` | Der Schlüssel `KETTE ausgabe-unlesbar` wird umbenannt | Nachtrag 6.12.24 k |
| Z-137 | Schlusszeile **Form 2** nennt eine andere Zahl, als Marken gelesen wurden | rc | gleich | Rückgabewert 2 | Form 2 wird von der Markenzahl-Prüfung ausgenommen | Runde 3, S3-02 (6.12.25 e) |
| Z-138 | Schlusszeile Form 2 mit abweichender Zahl | zaehler | gleich | Die Zählerdatei trägt den Schlüssel `KETTE ausgabe-unlesbar` | Der Schlüssel `KETTE ausgabe-unlesbar` wird umbenannt | Runde 3, S3-02 (6.12.25 e) |
| Z-139 | Schlusszeile **Form 4** nennt eine andere Zahl, als Marken gelesen wurden | rc | gleich | Rückgabewert 2 | keine — die Verneinung (Form 4 von der Markenzahl-Prüfung ausgenommen) ist im selben Fall durch die Schwester `Z-140` gedeckt: Fiele die Prüfung weg, trüge die Zählerdatei den Schlüssel `KETTE ausgabe-unlesbar` nicht mehr, und `Z-140` fällt. Der Kanal `rc` dieser Zeile kann die Verneinung nicht trennen, weil der Rückgabewert 2 im Prüfaufbau auch aus dem Befund `D19 VERLETZT` folgt (Grund 3) | Runde 3, S3-02 (6.12.25 e); Mutation auf `keine` gesetzt 6.12.26 f (Runde 7, S7-02) |
| Z-140 | Schlusszeile Form 4 mit abweichender Zahl | zaehler | gleich | Die Zählerdatei trägt den Schlüssel `KETTE ausgabe-unlesbar` | Der Schlüssel `KETTE ausgabe-unlesbar` wird umbenannt | Runde 3, S3-02 (6.12.25 e) |
| Z-141 | Schlusszeile **Form 3** (abgebrochen) mit abweichender Zahl | zaehler | gleich | Die Zählerdatei trägt den Befund der Kette als Schlüssel und **nicht** `KETTE ausgabe-unlesbar` — Form 3 wird nicht auf die Zahl geprüft | Der Abbruchfall trägt neu den Schlüssel `KETTE ausgabe-unlesbar` | Runde 3, S3-02 (6.12.25 e) |
| Z-142 | D19-Zeile meldet Lage B bei Rückgabewert 0, obwohl das Gate einen Arbeitsbaum bestimmt hat | rc | gleich | Rückgabewert 2 | Der Zweig des D19-B-Widerspruchs endet mit 3 | Nachtrag 6.12.24, Befund S-01 |
| Z-143 | D19-Zeile meldet Lage B bei Rückgabewert 0 | zaehler | gleich | Die Zählerdatei trägt genau den Schlüssel `D19 B-widerspruch` und nicht `KETTE ausgabe-unlesbar` | Der Vorrang des Schlüssels `D19 B-widerspruch` vor der Konsistenzwache entfällt | Nachtrag 6.12.24, Befund S-01 |
| Z-144 | Baumzeile **fehlt** ganz | rc | gleich | Rückgabewert 2 | Der Zweig der fehlenden Baumzeile endet mit 3 | Nachtrag 6.12.24, Befund S-10 |
| Z-145 | Baumzeile fehlt ganz | zaehler | gleich | Die Zählerdatei trägt den Schlüssel `KETTE ausgabe-unlesbar` | Der Schlüssel `KETTE ausgabe-unlesbar` wird umbenannt | Nachtrag 6.12.24, Befund S-10 |
| Z-146 | Aussage A05: Verzeichnis der Wegwerfdatei physisch nicht auflösbar, **erstes** Ereignis | stderr | enthaelt | Die Fehlerausgabe nennt den Schlüssel `GATE mktemp` | Der Schlüssel `GATE mktemp` wird umbenannt | Runde 4, S4-04 (6.12.25 i) |
| Z-147 | Aussage E13: Verzeichnis der Wegwerfdatei physisch nicht auflösbar, **erstes** Ereignis | zaehler | gleich | Die Zählerdatei trägt `GATE mktemp\|1` | Das erste Ereignis wird mit 7 statt mit 1 gezählt | Runde 4, S4-04 (6.12.25 i) |
| Z-148 | Aussage E02: Dasselbe Ausbleiben ein **zweites** Mal in derselben Sitzung | zaehler | gleich | Die Zählerdatei trägt `GATE mktemp\|2` | Der Zähler wird bei gleichem Schlüssel nicht erhöht | Runde 4, S4-04 (6.12.25 i) |
| Z-149 | Fehlendes `sha256sum`, **erstes** Ereignis | stderr | enthaelt | Die Fehlerausgabe nennt den Schlüssel `GATE sha256sum` | Der Schlüssel `GATE sha256sum` wird umbenannt | Runde 4, S4-04 (6.12.25 i) |
| Z-150 | Aussage E11: Fehlendes `sha256sum`, **erstes** Ereignis | zaehler | gleich | Die Zählerdatei trägt `GATE sha256sum\|1` | Das erste Ereignis wird mit 7 statt mit 1 gezählt | Runde 4, S4-04 (6.12.25 i) |
| Z-151 | Fehlendes `sha256sum`, **zweites** Ereignis in derselben Sitzung | zaehler | gleich | Die Zählerdatei trägt `GATE sha256sum\|2` | Der Zähler wird bei gleichem Schlüssel nicht erhöht | Runde 4, S4-04 (6.12.25 i) |
| Z-152 | Zweiter Selbsttest, gestartet während der erste die Sperre hält | selbsttest+dauer | gleich+kleiner | Der zweite Aufruf endet innerhalb von 5 s mit Rückgabewert 3 | keine — die Zusicherung beschreibt den Selbsttest selbst (Grund 1) | Runde 4, S4-03 (6.12.25 j) |
| Z-153 | Zweiter Selbsttest, gestartet während der erste die Sperre hält | selbsttest | zeile-woertlich | Die Fehlerausgabe des zweiten Aufrufs trägt die Zeile `Selbsttest laeuft bereits` | keine — die Zusicherung beschreibt den Selbsttest selbst (Grund 1) | Runde 4, S4-03 (6.12.25 j) |
| Z-154 | Aussage E18: Vierter Stop nach drei Blocks am selben Kriterium, mit einer Übergabedatei in `HEAD`, deren Eskalationszeile einen **anderen** Schlüssel nennt als den gezählten | rc | gleich | Rückgabewert 2 — eine Übergabedatei mit fremdem Schlüssel öffnet den Durchlass **nicht**; der Durchlass ist an den gezählten Schlüssel gebunden | Der im Gate gesuchte Text wird von `Eskalation 3.4: <gezählter Schlüssel>` auf `Eskalation 3.4:` ohne Schlüssel verkürzt | Runde 7, DT7-03 (6.12.26 f) |
| Z-155 | Derselbe Fall: vierter Stop, Übergabedatei mit fremdem Schlüssel in der Eskalationszeile | zaehler | gleich | Die Zählerdatei trägt nach dem vierten Ereignis den **gezählten** Schlüssel mit dem Stand 4 — der Zähler zählt weiter und wird nicht zurückgesetzt | keine — die Verneinung ist im selben Fall durch die Schwester `Z-154` gedeckt; der Kanal `zaehler` kann sie nicht trennen, weil der Stand 4 nach `Z-125` auch beim Durchlass gilt (Grund 3) | Runde 7, DT7-03 (6.12.26 f) |
| Z-156 | Aussage E15: Drittes Ereignis am selben Kriterium, mit einer in `HEAD` committeten Übergabedatei, die die passende Eskalationszeile trägt | rc | gleich | Rückgabewert 2 — der Durchlass greift frühestens beim **vierten** Ereignis; eine passende Übergabedatei öffnet ihn beim dritten **nicht** | Die Eskalationsschwelle im Gate wird von `-ge 4` auf `-ge 3` gesetzt (`M-01`); das Gate lässt dann schon beim dritten Ereignis mit Rückgabewert 0 durch | Runde 8, DT8-01 (6.12.27 e) |
| Z-157 | Aussage E20: Viertes Ereignis am selben Kriterium, **ohne** Übergabedatei unter `docs/uebergaben/` | stderr | enthaelt | Die Fehlerausgabe erhebt die Forderung nach einer Datei unter `docs/uebergaben/` mit der wörtlichen Eskalationszeile | Der Satz mit der Forderung nach der Übergabedatei entfällt aus dem Block ab dem vierten Ereignis | 6.12.9, Ereignisfolge (6.12.27 e) |
| Z-158 | Aussage E01: Kette mit `A_FAIL` (derselbe Fall wie `Z-001`) | zaehler | gleich | Die Zählerdatei trägt als Schlüssel die Klassifizierung `<D> <ziel> A_FAIL` des im Lauf gemeldeten Schritts (6.12.4); den konkreten Schritt bestimmt der Prüfaufbau | Im `A_FAIL`-Zweig der Markenauswertung wird der Schlüssel ohne die Lage gebildet (`<D> <ziel>` statt `<D> <ziel> A_FAIL`) | Schlüsseldeckung 6.12.27 c (Runde 8, DT8-02) |
| Z-159 | Lage C ohne Eintrag in der Liste (derselbe Fall wie `Z-008`) | zaehler | gleich | Die Zählerdatei trägt als Schlüssel `<D> <ziel> C <Pruefmittel>` mit dem `FEHLT=`-Wert der Marke; den konkreten Schritt bestimmt der Prüfaufbau | Im Zweig der ungedeckten Lage C entfällt der `FEHLT=`-Wert aus dem Schlüssel | Schlüsseldeckung 6.12.27 c |
| Z-160 | Übersicht mit einer Zeile `(keine Marke)` und Schlusszeile **Form 3** (abgebrochen bei diesem Schritt) | zaehler | gleich | Die Zählerdatei trägt den Schlüssel `KETTE marke-fehlt <D> <ziel>` mit dem Schritt, den die Form-3-Schlusszeile nennt | Der Schlüssel `KETTE marke-fehlt` wird umbenannt | Schlüsseldeckung 6.12.27 c |
| Z-161 | D19 `VERLETZT` (derselbe Fall wie `Z-019`) | zaehler | gleich | Die Zählerdatei trägt den Schlüssel `D19 VERLETZT` | Der Schlüssel `D19 VERLETZT` wird umbenannt | Schlüsseldeckung 6.12.27 c |
| Z-162 | D19 Lage C (derselbe Fall wie `Z-020`) | zaehler | gleich | Die Zählerdatei trägt den Schlüssel `D19 C` | Der Schlüssel `D19 C` wird umbenannt | Schlüsseldeckung 6.12.27 c |
| Z-163 | Innere Zeitüberschreitung (derselbe Fall wie `Z-037`) | zaehler | gleich | Die Zählerdatei trägt den Schlüssel `KETTE zeitueberschreitung` | Der Schlüssel `KETTE zeitueberschreitung` wird umbenannt | Schlüsseldeckung 6.12.27 c |
| Z-164 | Die Kette endet mit Rückgabewert 7 (Attrappe, 6.12.19) | rc | gleich | Rückgabewert 2 | Der Zweig für einen Rückgabewert ausser 0 und 2 endet mit 3, bevor er blockiert | Schlüsseldeckung 6.12.27 c |
| Z-165 | Die Kette endet mit Rückgabewert 7 | zaehler | gleich | Die Zählerdatei trägt den Schlüssel `KETTE rueckgabewert=7` | Der Schlüssel wird ohne die Zahl gebildet (`KETTE rueckgabewert=` statt `KETTE rueckgabewert=<N>`) | Schlüsseldeckung 6.12.27 c |
| Z-166 | Eintrag der terminierten Lagen, dessen Prüfmittel inzwischen existiert — Selbstprüfung 2 (derselbe Fall wie `Z-009`) | zaehler | gleich | Die Zählerdatei trägt den Schlüssel `LISTE 2 <D> <ziel>` der beanstandeten Zeile | Der Schlüssel der Selbstprüfung 2 wird ohne D-Nummer und Ziel gebildet | Schlüsseldeckung 6.12.27 c |
| Z-167 | Eintrag ohne Grund — Selbstprüfung 4 (derselbe Fall wie `Z-013`) | zaehler | gleich | Die Zählerdatei trägt den Schlüssel `LISTE 4 <Zeilennummer>` der beanstandeten Zeile | Der Schlüssel der Selbstprüfung 4 wird ohne die Zeilennummer gebildet | Schlüsseldeckung 6.12.27 c |
| Z-168 | Rückgabewert **0** der Kette mit einer Schlusszeile **Form 4** und passender D19-Zeile `VERLETZT` | zaehler | gleich | Die Zählerdatei trägt den Schlüssel `KETTE schlusszeile-widerspruch` und nicht `KETTE ausgabe-unlesbar` | Form 4 wird bei Rückgabewert 0 von der Widerspruchsprüfung ausgenommen (`M-07`); das Gate blockiert dann über die Konsistenzwache unter `KETTE ausgabe-unlesbar` | Runde 8, DT8-02 (6.12.27 e) |
| Z-169 | Derselbe Fall: Rückgabewert 0 der Kette mit Schlusszeile Form 4 | rc | gleich | Rückgabewert 2 — Rückgabewert 0 ist nach 6.12.23 a nur mit Form 1 vereinbar | keine — Grund 3, Schwester `Z-168`: unter der Verneinung (`M-07`) blockiert das Gate weiterhin mit 2, nur unter dem falschen Schlüssel; der Kanal `rc` kann die Verneinung nicht trennen, die Schwester über den Schlüssel schon | Runde 8, DT8-02 (6.12.27 e) |
| Z-170 | Grammatik PRAEFIX: Übersichtszeile ohne das Präfix `::LAGE `, im Übrigen wohlgeformte Marke, Schlusszeile Form 1 mit der vollen Markenzahl | zaehler | gleich | Die Zählerdatei trägt den Schlüssel `KETTE ausgabe-unlesbar` (Ausgang abgeleitet, beim Bau zu bestätigen — 6.12.27 d) | Im Gate wird das Präfix `::LAGE` in der Auswahl der Übersichtszeilen **und** im `marken_muster` so gelockert, dass eine Marke ohne führendes `::` als Marke gilt | 6.12.27 d, Grammatikdeckung |
| Z-171 | Grammatik KENNUNG: Marke ohne das Feld der Lauf-Kennung, sonst wohlgeformt, Schlusszeile Form 1 mit der vollen Markenzahl | zaehler | gleich | Die Zählerdatei trägt den Schlüssel `KETTE ausgabe-unlesbar` (Ausgang abgeleitet, beim Bau zu bestätigen — 6.12.27 d) | Im `marken_muster` wird die Gruppe der Lauf-Kennung samt folgendem Leerzeichen optional | 6.12.27 d, Grammatikdeckung |
| Z-172 | Grammatik DNUMMER: Marke ohne das Feld der D-Nummer, sonst wohlgeformt, Schlusszeile Form 1 mit der vollen Markenzahl | zaehler | gleich | Die Zählerdatei trägt den Schlüssel `KETTE ausgabe-unlesbar` (Ausgang abgeleitet, beim Bau zu bestätigen — 6.12.27 d) | Im `marken_muster` wird die Gruppe der D-Nummer samt folgendem Leerzeichen optional | 6.12.27 d, Grammatikdeckung |
| Z-173 | Grammatik ZIEL: Marke ohne das Feld des Ziels, sonst wohlgeformt, Schlusszeile Form 1 mit der vollen Markenzahl | zaehler | gleich | Die Zählerdatei trägt den Schlüssel `KETTE ausgabe-unlesbar` (Ausgang abgeleitet, beim Bau zu bestätigen — 6.12.27 d) | Im `marken_muster` wird die Gruppe des Ziels samt folgendem Leerzeichen optional | 6.12.27 d, Grammatikdeckung |
| Z-174 | Grammatik LAGE: Marke mit einem Lage-Wort ausserhalb von `A_OK`, `A_FAIL`, `B` und `C`, sonst wohlgeformt, Schlusszeile Form 1 mit der vollen Markenzahl | zaehler | gleich | Die Zählerdatei trägt den Schlüssel `KETTE ausgabe-unlesbar` (Ausgang abgeleitet, beim Bau zu bestätigen — 6.12.27 d) | Im `marken_muster` wird die Auswahl der vier Lage-Wörter durch ein beliebiges Wort ersetzt | 6.12.27 d, Grammatikdeckung |
| Z-175 | Grammatik FEHLT: Marke mit `FEHLT=` **ohne Wert**, sonst wohlgeformt, Schlusszeile Form 1 mit der vollen Markenzahl | zaehler | gleich | Die Zählerdatei trägt den Schlüssel `KETTE ausgabe-unlesbar` (Ausgang abgeleitet, beim Bau zu bestätigen — 6.12.27 d) | Im `marken_muster` wird die Wertgruppe von `FEHLT=` optional | 6.12.27 d, Grammatikdeckung |
| Z-176 | Grammatik SCHWELLE: Marke mit `SCHWELLE=` **ohne Wert**, sonst wohlgeformt, Schlusszeile Form 1 mit der vollen Markenzahl | zaehler | gleich | Die Zählerdatei trägt den Schlüssel `KETTE ausgabe-unlesbar` (Ausgang abgeleitet, beim Bau zu bestätigen — 6.12.27 d) | Im `marken_muster` wird die Wertgruppe von `SCHWELLE=` optional | 6.12.27 d, Grammatikdeckung |
| Z-177 | Grammatik ABSCHLUSS: Marke ohne das schliessende `::`, sonst wohlgeformt, Schlusszeile Form 1 mit der vollen Markenzahl | zaehler | gleich | Die Zählerdatei trägt den Schlüssel `KETTE ausgabe-unlesbar` | Im `marken_muster` wird das schliessende `::` optional (`M-14`) | Runde 8, DT8-03 (6.12.27 d) |
| Z-178 | Grammatik ABSCHLUSS: derselbe Fall — Marke ohne das schliessende `::` | rc | gleich | Rückgabewert 2 — die missgebildete Marke wird nicht als Marke gezählt, und der Lauf geht nicht als sauberes Grün durch | Im `marken_muster` wird das schliessende `::` optional (`M-14`); unter der Mutation endet derselbe Lauf mit Rückgabewert 0 (Fremdbeleg `DT8-03`) | Runde 8, DT8-03 (6.12.27 d) |
| Z-179 | Grammatik RUECKGABE: Marke mit `(rueckgabewert=)` **ohne Zahl**, sonst wohlgeformt, Schlusszeile Form 1 mit der vollen Markenzahl | zaehler | gleich | Die Zählerdatei trägt den Schlüssel `KETTE ausgabe-unlesbar` (Ausgang abgeleitet, beim Bau zu bestätigen — 6.12.27 d) | Im `marken_muster` wird die Zifferngruppe der Rückgabewertklammer optional | 6.12.27 d, Grammatikdeckung |
| Z-180 | Arbeitsverzeichnis ausserhalb jedes Git-Baums, `CLAUDE_PROJECT_DIR` auf ein **Unterverzeichnis** des geprüften Baums, grüne Attrappenkette | rc | gleich | Rückgabewert 0 — das Gate löst den Baum aus dem Projektfeld physisch auf die Wurzel auf und findet dort das `Makefile` | Der geprüfte Baum wird roh aus dem Projektfeld übernommen statt über `git` auf die Wurzel aufgelöst (`M-16`); das Gate blockiert dann mit `GATE Makefile` | Runde 8, DT8-04 (6.12.27 e) |
| Z-181 | Statische Lesung von `.claude/hooks/dod-gate.sh` und `.claude/settings.json`, ohne Aufruf des Gates | selbsttest | kleiner | Die Sekundenzahl im Aufruf `timeout -k 10 <N> make` des Gates ist kleiner als der kleinste `timeout`-Wert der drei Hook-Einträge `Stop`, `SubagentStop` und `TaskCompleted` in `.claude/settings.json` | Die innere Zeitgrenze im Gate wird von 600 auf 6000 gesetzt (`M-15`) | Runde 8, DT8-05 (6.12.27 e) |
| Z-182 | Vierter Stop mit passender Übergabedatei — Durchlass nach der Eskalation (derselbe Fall wie `Z-041`) | stdout | einzelfeld | Die Standardausgabe ist genau ein JSON-Objekt, dessen einziges Feld `systemMessage` heisst | Das Feld `systemMessage` wird **allein** in der `jq`-Zeile des Eskalations-Durchlasses umbenannt, adressiert über den unmittelbar vorangehenden Meldungstext | Runde 8, DT8-06 (6.12.27 e) |
| Z-183 | `stop_hook_active` wahr bei roter Kette — Durchlass wegen des Reentranz-Schutzes (derselbe Fall wie `Z-017`) | stdout | einzelfeld | Die Standardausgabe ist genau ein JSON-Objekt, dessen einziges Feld `systemMessage` heisst | Das Feld `systemMessage` wird **allein** in der `jq`-Zeile des Durchlasses wegen `stop_hook_active` umbenannt, adressiert über den unmittelbar vorangehenden Meldungstext | Runde 8, DT8-06 (6.12.27 e) |
| Z-184 | `SubagentStop` einer Rolle ohne veränderndes Werkzeug — die Kette läuft nicht (derselbe Fall wie `Z-066`) | stdout | einzelfeld | Die Standardausgabe ist genau ein JSON-Objekt, dessen einziges Feld `systemMessage` heisst | Das Feld `systemMessage` wird **allein** in der `jq`-Zeile des Nichtlaufens für eine Rolle ohne Schreibrecht umbenannt, adressiert über den unmittelbar vorangehenden Meldungstext | Runde 8, DT8-06 (6.12.27 e) |
| Z-185 | Grammatik ENDE: Marke mit einem Anhang hinter der Rückgabewertklammer (etwa ` x`), sonst wohlgeformt, Schlusszeile Form 1 mit der vollen Markenzahl | zaehler | gleich | Die Zählerdatei trägt den Schlüssel `KETTE ausgabe-unlesbar` (Ausgang abgeleitet, beim Bau zu bestätigen — 6.12.27 d) | Im `marken_muster` wird der Endanker `$` entfernt, sodass eine Zeile mit beliebigem Anhang als Marke gilt (`DT9-01`) | Runde 9, DT9-01 (6.12.27 i) |
| Z-186 | Aussage E03: Zwei Blocks nacheinander mit **verschiedenen** Schlüsseln in derselben Sitzung | zaehler | gleich | Die Zählerdatei trägt nach dem **zweiten** Ereignis den Stand 1 — ein Schlüsselwechsel setzt den Zähler auf eins | Die Zuweisung `neue_zahl=1` im Zweig des Schlüsselwechsels wird durch Weiterzählen ersetzt (`DT9-02`) | Runde 9, DT9-02 (6.12.27 i) |
| Z-187 | Aussage E04: Belegtes Grün nach einem vorangegangenen Block am selben Kriterium in derselben Sitzung | datei | fehlt | Am Ort der Zählerdatei besteht nach dem Durchlass **keine** Datei mehr — ein Durchlass wegen Ergebnis löscht den Zähler | Der Aufruf `loesche_zaehler` vor dem Durchlass wird entfernt (`DT9-03`) | Runde 9, DT9-03 (6.12.27 i) |
| Z-188 | Aussage E06: `SubagentStop` einer Rolle ohne veränderndes Werkzeug, Zählerdatei vor dem Aufruf mit einem Schlüssel und dem Stand 2 angelegt | zaehler | gleich | Die Zählerdatei trägt nach dem Aufruf unverändert denselben Schlüssel und den Stand 2 | Vor dem Ausgang für Rollen ohne Schreibrecht wird der Zähler gelöscht (eingefügte Zeile) | 6.12.9, Aussagendeckung (6.12.27 i) |
| Z-189 | Aussage E08: ein `Stop`-Block und danach ein `TaskCompleted`-Block am **selben** Kriterium in derselben Sitzung | zaehler | gleich | Die Zählerdatei trägt nach dem zweiten Ereignis den Stand 2 — beide Ereignisse laufen in **denselben** Zähler | Der Name der Zählerdatei wird um den Namen des Ereignisses ergänzt | 6.12.9, Aussagendeckung (6.12.27 i) |
| Z-190 | Aussage E09: ein `Stop`-Block und ein `SubagentStop`-Block mit `agent_id` am selben Kriterium in derselben Sitzung | zaehler | gleich | Die Zählerdatei des Subagenten trägt den Stand 1 — ein Subagent zählt für sich | Aus der Namensbildung der Zählerdatei entfällt der Anteil, den die `agent_id` beisteuert *(auf die ausführbare Form verengt 2026-09-06, 6.12.27 j, S10-07)* | 6.12.9, Aussagendeckung (6.12.27 i) |
| Z-191 | Aussage E10: Block bei roter Kette, geprüfter Baum und Zustandsverzeichnis je an benanntem Ort | datei | ausserhalb | Der physisch aufgelöste Pfad der nach dem Block bestehenden Zählerdatei liegt **ausserhalb** des geprüften Baums | Das Zustandsverzeichnis wird im Gate fest auf ein Verzeichnis **innerhalb** des geprüften Baums gesetzt | 6.12.9, Aussagendeckung (6.12.27 i) |
| Z-192 | Aussage E12: fehlendes `jq` | datei | fehlt | Im Zustandsverzeichnis besteht nach dem Block **keine** Zählerdatei — `GATE jq` ist der einzige Block, der nicht gezählt wird | Im `jq`-Block wird vor dem Ausstieg eine Zählerdatei geschrieben (eingefügte Zeile) | 6.12.9, Aussagendeckung (6.12.27 i) |
| Z-193 | Aussage A04: Block bei roter Kette | stdout | leer | Die Standardausgabe ist leer — kein einziges Byte; auch die aufgefangene Ausgabe der Kette gelangt nicht dorthin | Vor dem blockierenden Ausgang wird die aufgefangene Kettenausgabe auf die Standardausgabe geschrieben (eingefügte Zeile) | 6.12.15, Aussagendeckung (6.12.27 i) |
| Z-194 | Aussage A08: **alle** Gate-Aufrufe dieses Selbsttestlaufs, aus dem Aufrufprotokoll des Selbsttests | rc | fehlt | Über alle Aufrufe tritt **kein** Rückgabewert ausser 0 und 2 auf | An einem blockierenden Ausgang des Gates wird `exit 2` durch `exit 1` ersetzt | Runde 10, Invariante der Ausgabeform (6.12.27 j) |
| Z-195 | Aussage A04: **jeder** Gate-Aufruf dieses Selbsttestlaufs mit Rückgabewert 2 | stdout | leer | Die Standardausgabe ist bei jedem dieser Aufrufe leer — kein einziges Byte | Auf dem Pfad des dritten Ereignisses wird die Umleitung `>&2` entfernt, sodass die Meldung auf die Standardausgabe geht (`DT10-06`) | Runde 10, DT10-06 (6.12.27 j) |
| Z-196 | Aussage A05: **jeder** Gate-Aufruf dieses Selbsttestlaufs mit Rückgabewert 2 | stderr | enthaelt | Die Fehlerausgabe enthält bei jedem dieser Aufrufe die Zeichenfolge `Schluessel: ` | Auf dem Pfad ab dem vierten Ereignis wird der Schlüssel aus der Meldung entfernt (`DT10-07`) | Runde 10, DT10-07 (6.12.27 j) |
| Z-197 | Aussage A01: **jeder** Gate-Aufruf dieses Selbsttestlaufs mit Rückgabewert 0 | stdout | einzelfeld | Die Standardausgabe ist bei jedem dieser Aufrufe entweder leer oder genau ein JSON-Objekt mit dem einzigen Feld `systemMessage` | Das JSON-Objekt eines Durchlasspfades erhält ein zweites Feld | Runde 10, Invariante der Ausgabeform (6.12.27 j) |
| Z-198 | Grammatik ANFANG: **eingebettete** Marke (`Fundstelle: ::LAGE …`), sonst wohlgeformt, Schlusszeile Form 1 mit der vollen Markenzahl | zaehler | gleich | Die Zählerdatei trägt den Schlüssel `KETTE ausgabe-unlesbar` (Ausgang abgeleitet, beim Bau zu bestätigen — 6.12.27 d) | In der Auswahl der Übersichtszeilen (`awk`-Vorfilter) **und** im `marken_muster` entfällt der Zeilenanker `^` (`M08`, auf **beide** Anker erweitert, `DT10-04`): erst unter dieser Doppelmutation passiert die eingebettete Marke den Vorfilter, das ungeankerte Muster trifft sie, sie wird gezählt, und der Lauf endet grün | Runde 10, DT10-04 (6.12.27 j); Mutation berichtigt 2026-09-06 nach Bau-Befund (zweiter Anker, Gate 858) |
| Z-199 | Erzeugerseite der Marke: Lauf des **echten** `Makefile` mit dem Ziel `dod` in einem minimalen Scheinbaum (**neuer** Fall, ohne Anspruch auf Grün), gemessen an der **Übersicht** am Ende des Laufs | kette | fehlt | In der Übersicht besteht **keine** mit `::LAGE` beginnende Zeile, die das aus `.claude/hooks/dod-gate.sh` gelesene `marken_muster` **nicht** trifft, und es besteht mindestens eine solche Zeile | Im `Makefile` wird `MARKE_SUFFIX := ::` auf `:` gesetzt (`M15`, `DT10-05`); die Übersicht trägt dann keine gültige Marke mehr, sondern `(keine Marke)` | Runde 10, DT10-05 (6.12.27 j); berichtigt 2026-09-06 vor dem Bau (`Makefile` 654/1760); Fall berichtigt 2026-09-06 vor dem Bau |
| Z-200 | Fehlendes `git` (derselbe Fall wie `Z-023`) | zaehler | gleich | Die Zählerdatei trägt den Schlüssel `GATE git` | Der Schlüssel `GATE git` wird umbenannt | Gegenstandsdeckung Schlüssel (6.12.27 j) |
| Z-201 | Fehlendes `make` (derselbe Fall wie `Z-025`) | zaehler | gleich | Die Zählerdatei trägt den Schlüssel `GATE make` | Der Schlüssel `GATE make` wird umbenannt | Gegenstandsdeckung Schlüssel (6.12.27 j) |
| Z-202 | Fehlendes `Makefile` (derselbe Fall wie `Z-027`) | zaehler | gleich | Die Zählerdatei trägt den Schlüssel `GATE Makefile` | Der Schlüssel `GATE Makefile` wird umbenannt | Gegenstandsdeckung Schlüssel (6.12.27 j) |
| Z-203 | Fehlende Liste der terminierten Lagen (derselbe Fall wie `Z-033`) | zaehler | gleich | Die Zählerdatei trägt den Schlüssel `GATE dod-gate-terminierte-lagen.txt` | Der Schlüssel `GATE dod-gate-terminierte-lagen.txt` wird umbenannt | Gegenstandsdeckung Schlüssel (6.12.27 j) |
| Z-204 | Fehlendes `timeout` (derselbe Fall wie `Z-029`) | zaehler | gleich | Die Zählerdatei trägt den Schlüssel `GATE timeout` | Der Schlüssel `GATE timeout` wird umbenannt | Gegenstandsdeckung Schlüssel (6.12.27 j) |
| Z-205 | Fehlendes `flock` (derselbe Fall wie `Z-031`) | zaehler | gleich | Die Zählerdatei trägt den Schlüssel `GATE flock` | Der Schlüssel `GATE flock` wird umbenannt | Gegenstandsdeckung Schlüssel (6.12.27 j) |
| Z-206 | Eintrag vorhanden, Schritt meldet `A_OK` — Selbstprüfung 3 (derselbe Fall wie `Z-011`) | zaehler | gleich | Die Zählerdatei trägt den Schlüssel `LISTE 3 <D> <ziel>` der beanstandeten Zeile | Der Schlüssel der Selbstprüfung 3 wird umbenannt | Gegenstandsdeckung Schlüssel (6.12.27 j), DT10-01 |
| Z-207 | Marke nennt ein anderes Prüfmittel als der Schlüssel — Selbstprüfung 5 (derselbe Fall wie `Z-016`) | zaehler | gleich | Die Zählerdatei trägt den Schlüssel `LISTE 5 <D> <ziel>` der beanstandeten Zeile | Der Schlüssel der Selbstprüfung 5 wird umbenannt | Runde 10, DT10-01 (6.12.27 j) |
| Z-208 | Liste mit **einer** Zeile, die die Selbstprüfung 6 verletzt (Strukturfehler) | zaehler | gleich | Die Zählerdatei trägt den Schlüssel `LISTE 6 <Zeilennummer>` der beanstandeten Zeile | Der Schlüssel der Selbstprüfung 6 wird an allen fünf Stellen umbenannt | Runde 10, DT10-02 (6.12.27 j) |
| Z-209 | Vor-Eingabe-Pfad: die Standardeingabe trägt kein gültiges JSON (ein Ereignis ist deshalb nicht lesbar; Umgebung im Übrigen vollständig: `CLAUDE_PROJECT_DIR` und Werkzeugkasten gesetzt) | rc | gleich | Rückgabewert 2 | Der Ausstieg dieses Pfades wird von `exit 2` auf `exit 0` gesetzt, adressiert über den unmittelbar vorangehenden Meldungstext | 6.12.28 b, Runde 11, DT11-07; berichtigt 2026-09-07 (6.12.28 b, SST-P1-09) |
| Z-210 | Derselbe Fall wie `Z-209` | stderr | enthaelt | Die Fehlerausgabe enthält die Zeichenfolge `Schluessel: ` unmittelbar gefolgt vom Schlüssel `EINGABE json` | Der Schlüssel wird aus der Meldung dieses Pfades entfernt | 6.12.28 e, Runde 11, DT11-11 |
| Z-211 | Aussage E23: derselbe Fall wie `Z-209` | datei | fehlt | Im Zustandsverzeichnis besteht nach dem Block **keine** Zählerdatei | Vor dem Ausstieg dieses Pfades wird eine Zählerdatei geschrieben (eingefügte Zeile) | 6.12.28 e, Aussagendeckung E23 |
| Z-212 | Vor-Eingabe-Pfad: das Ereignis der Eingabe wird von diesem Gate nicht bedient | rc | gleich | Rückgabewert 2 | Der Ausstieg dieses Pfades wird von `exit 2` auf `exit 0` gesetzt, adressiert über den unmittelbar vorangehenden Meldungstext | 6.12.28 b, Runde 11, DT11-08 |
| Z-213 | Derselbe Fall wie `Z-212` | stderr | enthaelt | Die Fehlerausgabe enthält die Zeichenfolge `Schluessel: ` unmittelbar gefolgt vom Schlüssel `EINGABE ereignis` | Der Schlüssel wird aus der Meldung dieses Pfades entfernt | 6.12.28 e, Runde 11, DT11-11 |
| Z-214 | Aussage E23: derselbe Fall wie `Z-212` | datei | fehlt | Im Zustandsverzeichnis besteht nach dem Block **keine** Zählerdatei | Vor dem Ausstieg dieses Pfades wird eine Zählerdatei geschrieben (eingefügte Zeile) | 6.12.28 e, Aussagendeckung E23 |
| Z-215 | Weder `CLAUDE_PROJECT_DIR` noch das Eingabefeld `cwd` ergeben einen bestimmbaren Arbeitsbaum | rc | gleich | Rückgabewert 2 | Der Ausstieg dieses Pfades wird von `exit 2` auf `exit 0` gesetzt, adressiert über den unmittelbar vorangehenden Meldungstext | 6.12.28 b, Runde 11, DT11-09 |
| Z-216 | Derselbe Fall wie `Z-215` | stderr | enthaelt | Die Fehlerausgabe enthält die Zeichenfolge `Schluessel: ` unmittelbar gefolgt vom Schlüssel `EINGABE baum` | Der Schlüssel wird aus der Meldung dieses Pfades entfernt | 6.12.28 e, Runde 11, DT11-11 |
| Z-217 | Aussage E23: derselbe Fall wie `Z-215` | datei | fehlt | Im Zustandsverzeichnis besteht nach dem Block **keine** Zählerdatei | Vor dem Ausstieg dieses Pfades wird eine Zählerdatei geschrieben (eingefügte Zeile) | 6.12.28 e, Aussagendeckung E23 |
| Z-218 | Sperrpfad: ein zweiter Prozess hält die Sperre für den geprüften Baum, die `flock`-Attrappe des Werkzeugkastens schreibt die Wartezeit `-w 120` auf eine kurze Zeit um | rc | gleich | Rückgabewert 2 | Der Ausstieg dieses Pfades wird von `exit 2` auf `exit 0` gesetzt, adressiert über den unmittelbar vorangehenden Meldungstext | 6.12.28 b, Runde 11, DT11-11 |
| Z-219 | Derselbe Fall wie `Z-218` | stderr | enthaelt | Die Fehlerausgabe enthält die Zeichenfolge `Schluessel: ` unmittelbar gefolgt vom Schlüssel `SPERRE belegt` | Der Schlüssel wird aus der Meldung dieses Pfades entfernt | 6.12.28 e, Runde 11, DT11-11 |
| Z-220 | Aussage E23: derselbe Fall wie `Z-218` | datei | fehlt | Im Zustandsverzeichnis besteht nach dem Block **keine** Zählerdatei | Vor dem Ausstieg dieses Pfades wird eine Zählerdatei geschrieben (eingefügte Zeile) | 6.12.28 e, Aussagendeckung E23 |
| Z-221 | Statische Lesung von `.claude/hooks/dod-gate.sh`, ohne Aufruf des Gates | selbsttest | gleich | Der `flock`-Aufruf des Gates nennt als Wartezeit genau `120` | Die Wartezeit im `flock`-Aufruf des Gates wird von 120 auf 5 gesetzt | 6.12.28 b, benannte Grenze der `flock`-Attrappe (Vorbild `Z-181`) |
| Z-222 | `mktemp -p <Zielverzeichnis>` schlägt fehl — `mktemp`-Attrappe, deren erster Aufruf mit 1 endet | zaehler | gleich | Die Zählerdatei trägt den Schlüssel `GATE mktemp` | Der Schlüssel wird **allein an dieser Aufrufstelle** umbenannt, adressiert über den unmittelbar vorangehenden Meldungstext | 6.12.28 b, Pfaddeckung, unbeschrittene Aufrufstelle |
| Z-223 | Die Ausweichdatei unter `/tmp` ist physisch nicht auflösbar — Attrappe, deren zweiter Aufruf einen Pfad in einem nicht vorhandenen Verzeichnis liefert | zaehler | gleich | Die Zählerdatei trägt den Schlüssel `GATE mktemp` | Der Schlüssel wird **allein an dieser Aufrufstelle** umbenannt, adressiert über den unmittelbar vorangehenden Meldungstext | 6.12.28 b, Pfaddeckung, unbeschrittene Aufrufstelle |
| Z-224 | Auch die Ausweichdatei liegt im geprüften Baum — Attrappe, deren beide Aufrufe Pfade innerhalb des Baums liefern | zaehler | gleich | Die Zählerdatei trägt den Schlüssel `GATE mktemp` | Der Schlüssel wird **allein an dieser Aufrufstelle** umbenannt, adressiert über den unmittelbar vorangehenden Meldungstext | 6.12.28 b, Pfaddeckung, unbeschrittene Aufrufstelle |
| Z-225 | Attrappenausgabe **ohne** Übersichtszeile, sonst vollständiger Lauf | zaehler | gleich | Die Zählerdatei trägt den Schlüssel `KETTE ausgabe-unlesbar` | Der Schlüssel wird **allein an dieser Aufrufstelle** umbenannt, adressiert über den unmittelbar vorangehenden Meldungstext | 6.12.28 b, Pfaddeckung, unbeschrittene Aufrufstelle |
| Z-226 | Attrappenausgabe mit **zwei** D19-Zeilen statt genau einer | zaehler | gleich | Die Zählerdatei trägt den Schlüssel `KETTE ausgabe-unlesbar` | Der Schlüssel wird **allein an dieser Aufrufstelle** umbenannt, adressiert über den unmittelbar vorangehenden Meldungstext | 6.12.28 b, Pfaddeckung, unbeschrittene Aufrufstelle |
| Z-227 | Attrappenausgabe mit **zwei** der vier Schlusszeilen statt genau einer | zaehler | gleich | Die Zählerdatei trägt den Schlüssel `KETTE ausgabe-unlesbar` | Der Schlüssel wird **allein an dieser Aufrufstelle** umbenannt, adressiert über den unmittelbar vorangehenden Meldungstext | 6.12.28 b, Pfaddeckung, unbeschrittene Aufrufstelle |
| Z-228 | Konsistenzwache: Attrappenausgabe mit einer `A_FAIL`-Marke, Schlusszeile Form 1 und Rückgabewert 0 der Kette | zaehler | gleich | Die Zählerdatei trägt den Schlüssel `KETTE ausgabe-unlesbar` | Der Schlüssel wird **allein an dieser Aufrufstelle** umbenannt, adressiert über den unmittelbar vorangehenden Meldungstext | 6.12.28 b, Pfaddeckung, unbeschrittene Aufrufstelle |
| Z-229 | Konsistenzwache: Attrappenausgabe nur mit `A_OK`-Marken, Schlusszeile Form 1, Rückgabewert 2 der Kette, keine gedeckte Lage C | zaehler | gleich | Die Zählerdatei trägt den Schlüssel `KETTE ausgabe-unlesbar` | Der Schlüssel wird **allein an dieser Aufrufstelle** umbenannt, adressiert über den unmittelbar vorangehenden Meldungstext | 6.12.28 b, Pfaddeckung, unbeschrittene Aufrufstelle |
| Z-230 | Ausführungsspur über **alle** Aufrufe des unveränderten Gates in diesem Selbsttestlauf, gegen eine bytegleiche Wegwerfkopie | selbsttest | gleich | Die Ausgabezeile `Pfaddeckung:` nennt als Zahl der nicht beschrittenen Ausgangsstellen genau 0 | Hinter `set -uo pipefail` wird eine nie erreichbare Ausgangsstelle eingefügt (`if false; then exit 2; fi`) | 6.12.28 b, O-27 (a1) |
| Z-231 | Dieselbe Ausführungsspur wie `Z-230` | selbsttest | gleich | Die Zahl der Aufrufe, die die Spur ausweist, ist gleich der Zahl der Aufrufe des Aufrufprotokolls des Selbsttests | keine — Grund 1 (die Zusicherung beschreibt das Messinstrument des Selbsttests, nicht das Gate; Schwester `Z-230` misst den Gegenstand) | 6.12.28 b, fail-closed gegen eine leere Spur |
| Z-232 | Grammatik ABSCHLUSS: Marke mit **einfachem** Doppelpunkt statt `::` vor der Rückgabewertklammer, sonst wohlgeformt, Schlusszeile Form 1 mit der vollen Markenzahl | zaehler | gleich | Die Zählerdatei trägt den Schlüssel `KETTE ausgabe-unlesbar` (Ausgang abgeleitet, beim Bau zu bestätigen — 6.12.27 d) | Im `marken_muster` wird das **erste** Zeichen des Literals `:: ` optional | 6.12.28 c, Runde 11, DT11-01 |
| Z-233 | Grammatik TRENNUNG: Marke **ohne** Leerzeichen zwischen `::` und der Rückgabewertklammer, sonst wohlgeformt, Schlusszeile Form 1 mit der vollen Markenzahl | zaehler | gleich | Die Zählerdatei trägt den Schlüssel `KETTE ausgabe-unlesbar` (Ausgang abgeleitet, beim Bau zu bestätigen — 6.12.27 d) | Im `marken_muster` wird das **letzte** Zeichen (das Leerzeichen) des Literals `:: ` optional | 6.12.28 c, Runde 11, DT11-02 |
| Z-234 | Grammatik KENNUNG: Marke mit **leerer** statt fehlender Lauf-Kennung (zwei Leerzeichen hinter dem Präfix), sonst wohlgeformt, Schlusszeile Form 1 mit der vollen Markenzahl | zaehler | gleich | Die Zählerdatei trägt den Schlüssel `KETTE ausgabe-unlesbar` (Ausgang abgeleitet, beim Bau zu bestätigen — 6.12.27 d) | Im `marken_muster` wird der Quantor der Kennungsgruppe von `+` auf `*` gesetzt | 6.12.28 c, Runde 11, DT11-03 |
| Z-235 | Grammatik DNUMMER: Marke mit **leerer** statt fehlender D-Nummer, sonst wohlgeformt, Schlusszeile Form 1 mit der vollen Markenzahl | zaehler | gleich | Die Zählerdatei trägt den Schlüssel `KETTE ausgabe-unlesbar` (Ausgang abgeleitet, beim Bau zu bestätigen — 6.12.27 d) | Im `marken_muster` wird der Quantor der D-Nummer-Gruppe von `+` auf `*` gesetzt | 6.12.28 c, Schwächungsliste U2 |
| Z-236 | Grammatik ZIEL: Marke mit **leerem** statt fehlendem Ziel, sonst wohlgeformt, Schlusszeile Form 1 mit der vollen Markenzahl | zaehler | gleich | Die Zählerdatei trägt den Schlüssel `KETTE ausgabe-unlesbar` (Ausgang abgeleitet, beim Bau zu bestätigen — 6.12.27 d) | Im `marken_muster` wird der Quantor der Zielgruppe von `+` auf `*` gesetzt | 6.12.28 c, Schwächungsliste U2 |
| Z-237 | Grammatik LAGE: Marke mit **leerem** Lage-Feld — zwischen Ziel und Abschluss steht nur ein Leerzeichen, sonst wohlgeformt, Schlusszeile Form 1 mit der vollen Markenzahl | zaehler | gleich | Die Zählerdatei trägt den Schlüssel `KETTE ausgabe-unlesbar` (Ausgang abgeleitet, beim Bau zu bestätigen — 6.12.27 d) | Im `marken_muster` wird die Lage-Gruppe optional | 6.12.28 c, Schwächungsliste U3 |
| Z-238 | Grammatik SCHWELLE: an der Stelle des Schwellenzusatzes steht ein **fremdes Wort** (etwa `OHNE_GRENZE`), sonst wohlgeformt, Schlusszeile Form 1 mit der vollen Markenzahl | zaehler | gleich | Die Zählerdatei trägt den Schlüssel `KETTE ausgabe-unlesbar` (Ausgang abgeleitet, beim Bau zu bestätigen — 6.12.27 d) | Die Alternativengruppe des Schwellenzusatzes im `marken_muster` wird um die Alternative `[^ ]+` erweitert | 6.12.28 c, Runde 11, DT11-04 |
| Z-239 | Grammatik SCHWELLE: der Wert von `SCHWELLE=` enthält einen **Doppelpunkt**, sonst wohlgeformt, Schlusszeile Form 1 mit der vollen Markenzahl | zaehler | gleich | Die Zählerdatei trägt den Schlüssel `KETTE ausgabe-unlesbar` (Ausgang abgeleitet, beim Bau zu bestätigen — 6.12.27 d) | Die Zeichenklasse `[^ :]` des Schwellenwerts im `marken_muster` wird auf `[^ ]` geweitet | 6.12.28 c, Schwächungsliste U4 |
| Z-240 | Grammatik FEHLT: der Wert von `FEHLT=` enthält einen **Doppelpunkt**, sonst wohlgeformt, Schlusszeile Form 1 mit der vollen Markenzahl | zaehler | gleich | Die Zählerdatei trägt den Schlüssel `KETTE ausgabe-unlesbar` (Ausgang abgeleitet, beim Bau zu bestätigen — 6.12.27 d) | Die Zeichenklasse `[^ :]` des `FEHLT`-Werts im `marken_muster` wird auf `[^ ]` geweitet | 6.12.28 c, Schwächungsliste U4 |
| Z-241 | Grammatik KENNUNG: die Marke trägt ein **zusätzliches** Feld zwischen Präfix und Lage, sonst wohlgeformt, Schlusszeile Form 1 mit der vollen Markenzahl | zaehler | gleich | Die Zählerdatei trägt den Schlüssel `KETTE ausgabe-unlesbar` (Ausgang abgeleitet, beim Bau zu bestätigen — 6.12.27 d) | Die Zeichenklasse `[^ ]` der Kennungsgruppe im `marken_muster` wird auf `.` geweitet | 6.12.28 c, Schwächungsliste U4 |
| Z-242 | Grammatik ZIEL: zwischen Ziel und Lage steht **kein** trennendes Leerzeichen, sonst wohlgeformt, Schlusszeile Form 1 mit der vollen Markenzahl | zaehler | gleich | Die Zählerdatei trägt den Schlüssel `KETTE ausgabe-unlesbar` (Ausgang abgeleitet, beim Bau zu bestätigen — 6.12.27 d) | Das Trennzeichen zwischen Ziel- und Lagegruppe im `marken_muster` wird optional | 6.12.28 c, Schwächungsliste U3 |
| Z-243 | Grammatik PRAEFIX: das Präfix trägt nur **einen** Doppelpunkt (`:LAGE `), sonst wohlgeformt, Schlusszeile Form 1 mit der vollen Markenzahl | zaehler | gleich | Die Zählerdatei trägt den Schlüssel `KETTE ausgabe-unlesbar` (Ausgang abgeleitet, beim Bau zu bestätigen — 6.12.27 d) | Im `awk`-Vorfilter der Übersichtszeilen **und** im `marken_muster` wird das **erste** Zeichen des Präfixes optional | 6.12.28 c, Schwächungsliste U3 mit Vorfilterregel |
| Z-244 | Grammatik PRAEFIX: zwischen `::LAGE` und der Lauf-Kennung steht **kein** Leerzeichen, sonst wohlgeformt, Schlusszeile Form 1 mit der vollen Markenzahl | zaehler | gleich | Die Zählerdatei trägt den Schlüssel `KETTE ausgabe-unlesbar` (Ausgang abgeleitet, beim Bau zu bestätigen — 6.12.27 d) | Im `awk`-Vorfilter der Übersichtszeilen **und** im `marken_muster` wird das **letzte** Zeichen (das Leerzeichen) des Präfixes optional | 6.12.28 c, Schwächungsliste U3 mit Vorfilterregel |
| Z-245 | Grammatik ABSCHLUSS: die Marke trägt **weder** `::` **noch** ein Leerzeichen vor der Rückgabewertklammer, sonst wohlgeformt, Schlusszeile Form 1 mit der vollen Markenzahl | zaehler | gleich | Die Zählerdatei trägt den Schlüssel `KETTE ausgabe-unlesbar` (Ausgang abgeleitet, beim Bau zu bestätigen — 6.12.27 d) | Das **ganze** Literal `:: ` im `marken_muster` wird optional | 6.12.28 c, Schwächungsliste U3 |
| Z-246 | Grammatik RUECKGABE: die Rückgabewertklammer steht **ohne öffnende Klammer**, sonst wohlgeformt, Schlusszeile Form 1 mit der vollen Markenzahl | zaehler | gleich | Die Zählerdatei trägt den Schlüssel `KETTE ausgabe-unlesbar` (Ausgang abgeleitet, beim Bau zu bestätigen — 6.12.27 d) | Das **erste** Zeichen des Literals der Rückgabewertklammer im `marken_muster` wird optional | 6.12.28 c, Schwächungsliste U3 |
| Z-247 | Grammatik RUECKGABE: die Rückgabewertklammer steht **ohne Gleichheitszeichen**, sonst wohlgeformt, Schlusszeile Form 1 mit der vollen Markenzahl | zaehler | gleich | Die Zählerdatei trägt den Schlüssel `KETTE ausgabe-unlesbar` (Ausgang abgeleitet, beim Bau zu bestätigen — 6.12.27 d) | Das **letzte** Zeichen des Literals der Rückgabewertklammer im `marken_muster` wird optional | 6.12.28 c, Schwächungsliste U3 |
| Z-248 | Grammatik RUECKGABE: die Marke endet **ohne schliessende Klammer**, sonst wohlgeformt, Schlusszeile Form 1 mit der vollen Markenzahl | zaehler | gleich | Die Zählerdatei trägt den Schlüssel `KETTE ausgabe-unlesbar` (Ausgang abgeleitet, beim Bau zu bestätigen — 6.12.27 d) | Das Literal der schliessenden Klammer im `marken_muster` wird optional | 6.12.28 c, Schwächungsliste U3 |
| Z-249 | Grammatik RUECKGABE: die Marke trägt hinter dem Abschluss nur die Zahl, **ohne** das Wort `rueckgabewert=`, sonst wohlgeformt, Schlusszeile Form 1 mit der vollen Markenzahl | zaehler | gleich | Die Zählerdatei trägt den Schlüssel `KETTE ausgabe-unlesbar` (Ausgang abgeleitet, beim Bau zu bestätigen — 6.12.27 d) | Das **ganze** Literal der Rückgabewertklammer im `marken_muster` wird optional | 6.12.28 c, Schwächungsliste U3 |
| Z-250 | Grammatik RUECKGABE: der Rückgabewert trägt einen **Buchstaben statt einer Ziffer**, sonst wohlgeformt, Schlusszeile Form 1 mit der vollen Markenzahl | zaehler | gleich | Die Zählerdatei trägt den Schlüssel `KETTE ausgabe-unlesbar` (Ausgang abgeleitet, beim Bau zu bestätigen — 6.12.27 d) | Die Zeichenklasse `[0-9]` im `marken_muster` wird auf `.` geweitet | 6.12.28 c, Schwächungsliste U4 |
| Z-251 | Grammatik ENDE: die Marke trägt ein **nachlaufendes Leerzeichen** hinter der Rückgabewertklammer, sonst wohlgeformt, Schlusszeile Form 1 mit der vollen Markenzahl | zaehler | gleich | Die Zählerdatei trägt den Schlüssel `KETTE ausgabe-unlesbar` (Ausgang abgeleitet, beim Bau zu bestätigen — 6.12.27 d) | Vor dem Endanker des `marken_muster` wird Leerraum zugelassen | 6.12.28 c, Runde 11, DT11-05 |
| Z-252 | Schwächungslauf: alle mechanisch erzeugten Schwächungen des aus dem Gate gelesenen `marken_muster`, je gegen die Grammatik-Fallfunktionen an einer geschwächten Gate-Kopie | selbsttest | gleich | Die Ausgabezeile `Grammatikschwaechungen:` nennt als Zahl der wirksamen Schwächungen ohne fallende Zusicherung genau 0 | Der `awk`-Vorfilter der Übersichtszeilen wird auf ein **strengeres** Muster gesetzt (`^::LAGE ` um die drei Feldgruppen und die Lage-Alternativen ergänzt); **18** Schwächungen, verteilt über die Elemente **1 bis 9**, werden damit am Gate zu äquivalenten Mutanten, ihre Grammatikzeilen fallen nicht mehr, und die Zahl der Schwächungen ohne fallende Zusicherung steigt über 0 (gemessen `m = 18`) — das `marken_muster` und damit die Zerlegung in 16 Elemente bleiben unberührt | 6.12.28 c, O-27 (a2); Mutation berichtigt 2026-09-07 (6.12.28 c, S12-03); Begründung berichtigt 2026-09-08 (6.12.28 j, SNP-01 — zuvor stand hier "die Elemente 3 bis 9"), der `sed`-Ausdruck bleibt unverändert |
| Z-253 | Statische Lesung des `marken_muster` und der Elementtabelle 6.12.7, ohne Aufruf des Gates | selbsttest | gleich | Die Alternativen der Lage-Gruppe des `marken_muster` sind, in Lesereihenfolge, gleich den Backtick-Abschnitten der **Spalte Element** der Zeile `LAGE` der Elementtabelle 6.12.7 (dort `A_OK`, `A_FAIL`, `B`, `C`) | In die Lage-Gruppe des `marken_muster` wird eine fünfte Alternative aufgenommen | 6.12.28 c, Alternativendeckung, Runde 11, DT11-04 |
| Z-254 | Dieselbe Lesung wie `Z-253` | selbsttest | gleich | Die Zahl der Alternativen der Schwellengruppe des `marken_muster` ist gleich der Zahl der Backtick-Abschnitte der **Spalte Element** der Zeile `SCHWELLE` der Elementtabelle 6.12.7 (dort zwei: `SCHWELLE=<wert>` und `OHNE_SCHWELLE`) | In die Schwellengruppe des `marken_muster` wird eine dritte Alternative aufgenommen | 6.12.28 c, Alternativendeckung, Runde 11, DT11-04 |
| Z-255 | Schwächungslauf wie `Z-252` | selbsttest | fehlt | Die Ausgabe des Selbsttests führt **keine** Zeile `Grammatikschwaechungen:`, die als Zahl der wirksamen Schwächungen 0 nennt | Das `marken_muster` wird im Gate durch `.*` ersetzt, sodass keine Probemarke mehr abgelehnt wird | 6.12.28 c, fail-closed |
| Z-256 | Aussage E21: **dritter** Block in derselben Sitzung, Kettenausgabe mit `A_FAIL`, zwei ungedeckten Lagen C und `D19 VERLETZT` | stderr | enthaelt | Die Fehlerausgabe führt neben der gezählten ersten Abweichung auch die **zweite** ungedeckte Lage C auf | Der Aufruf von `weitere_abweichungen_ausgeben` wird **allein** im Block beim dritten Mal entfernt, adressiert über den unmittelbar vorangehenden Meldungstext | 6.12.28 d, Runde 11, DT11-06 |
| Z-257 | Aussage E21: **vierter** Block ohne passende Übergabedatei, Kettenausgabe mit `A_FAIL`, zwei ungedeckten Lagen C und `D19 VERLETZT` | stderr | enthaelt | Die Fehlerausgabe führt neben der gezählten ersten Abweichung auch die **zweite** ungedeckte Lage C auf | Der Aufruf von `weitere_abweichungen_ausgeben` wird **allein** im Block ab dem vierten Mal entfernt, adressiert über den unmittelbar vorangehenden Meldungstext | 6.12.28 d, Runde 11, DT11-06 |
| Z-258 | Statische Lesung von `.claude/hooks/dod-gate.sh` und der Tabelle 6.12.19, ohne Aufruf des Gates | selbsttest | gleich | Die Zahl der Aufrufstellen von `weitere_abweichungen_ausgeben` im Gate ist gleich der Zahl der **verschiedenen** Fallfunktionen, die eine Zusicherung mit dem Etikett `Aussage E21: ` prüfen | Eine der Aufrufstellen von `weitere_abweichungen_ausgeben` wird aus dem Gate entfernt | 6.12.28 d, Runde 11, DT11-06 |
| Z-259 | Statische Lesung des `marken_muster` aus dem Gate, ohne Aufruf des Gates | selbsttest | existiert | Die Lesung liefert einen nicht leeren Wert — ein Fund | Die Zuweisung `marken_muster=` wird im Gate umbenannt, sodass die Lesung ins Leere greift | 6.12.28 f, Runde 11, S11-04 |
| Z-260 | Zusammenfassung des Selbsttestlaufs, Block der Deckungszeilen | selbsttest | fehlt | Der Block der Deckungszeilen führt **keine** Zeile, deren erste Zahl 0 ist | Die Zuweisung des `marken_muster` im Gate wird auf die leere Zeichenkette gesetzt, sodass die Zeile `Grammatikschwaechungen:` als erste Zahl 0 nennt | 6.12.28 f, Runde 11, S11-05 und S11-06 |
| Z-261 | Zusammenfassung des Selbsttestlaufs, Zeile der Grammatikdeckung | selbsttest | gleich | Die Ausgabezeile `Grammatikdeckung:` nennt als Zahl der fremden Etiketten genau 0 | keine — Grund 1 (die Zusicherung beschreibt die Deckungsprüfung des Selbsttests selbst; ein fremdes Etikett entstünde allein in der Tabelle dieses ADR, die kein Ziel einer Mutation ist; Vorbild `Z-152` und `Z-153`) | 6.12.28 f, Runde 11, S11-06 |
| Z-262 | D19-Zeile mit einem Wort ausserhalb von `OHNE_BEFUND`, `VERLETZT`, `B` und `C` (etwa `SPAETER`), sonst grüne Attrappenkette mit Schlusszeile Form 1 und voller Markenzahl | rc | gleich | Rückgabewert 2 | Die Alternativen der Grammatik der D19-Zeile werden an **beiden** Stellen des Gates (Prüfung und Auswertung) durch `[A-Z_][A-Z_]*` ersetzt, sodass die Zeile jedes Grosswort annimmt | 6.12.28 j, Runde 12, DT12-M14 |
| Z-263 | Derselbe Fall wie `Z-262` | zaehler | gleich | Die Zählerdatei trägt den Schlüssel `KETTE ausgabe-unlesbar` | Die Alternativen der Grammatik der D19-Zeile werden an **beiden** Stellen des Gates (Prüfung und Auswertung) durch `[A-Z_][A-Z_]*` ersetzt, sodass die Zeile jedes Grosswort annimmt | 6.12.28 j, Runde 12, DT12-M14 |

**Wie geprüft wird.** Das Skript wird im Selbsttest **unmittelbar** mit einer
JSON-Eingabe auf der Standardeingabe aufgerufen, nicht über den Harness.
*(Runde 1, Begründung berichtigt: Die erste Fassung stützte das darauf, die
Referenz sage nicht, ob eine Änderung an `.claude/settings.json` in der
laufenden Sitzung wirke. Sie sagt es — "Direct edits to hooks in settings files
are normally picked up automatically by the file watcher." Der Entscheid bleibt,
die Begründung wird ausgetauscht; eine Festlegung, die auf einem Schweigen
beruht, das es nicht gibt, ist eine Zusicherung ohne Deckung, V12.)* Die
tragenden Gründe sind zwei andere, und beide sind stärker: **Herstellbarkeit** —
über die Standardeingabe lässt sich jeder Fall der Tabelle oben gezielt
erzeugen, auch die, die im Ereignisfluss des Harness nicht auf Bestellung
eintreten (`stop_hook_active` wahr, ein unbekannter `agent_type`, der dritte
Block in Folge); und **Determinismus** — der Selbsttest darf nicht davon
abhängen, wann eine Dateiüberwachung eine Änderung bemerkt, sonst prüft er
nebenbei den Harness statt das Skript. Die Verifikation liegt beim Static und
beim Dynamic Software Tester auf einem anderen Modell als die Umsetzung (3.4);
die Rolle, die das Gate baut, prüft es nicht selbst.

#### 6.12.20 Einordnung der drei übrigen Punkte aus dem Achtung-Hinweis zu R3-Q-001

Der zweite Achtung-Hinweis bei R3-Q-001 nennt vier Bauformen aus dem Vergleich
mit einem fremden Bestand; der Backlog hält ausdrücklich fest, dass alle vier
Sache des Software Architects im Rahmen dieser Fortschreibung sind und keinen
eigenen Backlog-Eintrag erhalten. Punkt 1 — der rote und der grüne Lauf — ist
mit G17 erledigt. Die übrigen drei werden hier **eingeordnet und nicht gebaut**,
wie der Auftraggeber es angewiesen hat.

| Punkt | Einordnung | Zuständig | Bedingung und Termin |
|---|---|---|---|
| **Schwachstellenklassen im eigenen Code** (ruff-Regelgruppe `S`) | Zu entscheiden ist **nicht ob, sondern wo**: als Regelgruppe in der bestehenden ruff-Konfiguration und damit in D3, oder als eigener Kettenschritt mit eigener Nummer. Für D3 spricht, dass kein neues Werkzeug und kein neuer Schritt entsteht; dagegen spricht das Argument aus 6.1.2 für D18 — eine Aussage über eine Sicherheitseigenschaft soll einen eigenen Rückgabewert haben und darf nicht mit einem Schwellenwert für Stilwarnungen (E-08, O-7) zusammenfallen. Als **O-21** geführt | Software Architect mit SecDevOps Engineer; Bau beim Backend Engineer | Heute Lage B: es gibt keinen eigenen Python-Code. Mit dem Anlegen von `backend/pyproject.toml`, vor der ersten Umsetzungseinheit mit Fachlogik |
| **Markdown-Struktur- und Tabellenprüfer** | Der Gegenstand besteht **heute** — eine verrutschte Spalte in der Rollentabelle ist eine falsch gelesene Bauvorschrift. Er geht **nicht** in D20 auf: D20 urteilt über Herkunfts- und Fundortangaben, ein Strukturprüfer über den Aufbau des Dokuments; das sind zwei Sachen, und jeder Schritt urteilt über eine (6.2.2). Eine D-Nummer wird hier **nicht** vergeben — eine Nummer für einen nicht entschiedenen Schritt wäre eine Absichtserklärung, und nach 6.8.1 wäre sie mit der Nennung vergeben. Als **O-22** geführt | Software Architect (Entscheid über den Schnitt), DevOps Engineer (Bau) | Keine Vorbedingung im Bestand; Termin: mit der nächsten Fortschreibung dieses Abschnitts, spätestens vor der Freigabe des Grundgerüsts |
| **Prüfmodus für den Nachweiserzeuger** | **Kein neuer offener Punkt.** Das ist der Gegenstand von **O-8** ("Betriebsart für D10 und Form von D12"), der seit dem 2026-08-30 zusätzlich an den Kettengrundsatz gebunden ist: Die gewählte Form schreibt nicht in den Arbeitsbaum. O-8 trägt heute den Termin "mit R3-Q-001"; dieser Termin ist nicht haltbar, weil weder `scripts/nachweise-vollstaendig.sh` noch `scripts/prototyp-trennung-pruefen.sh` bestehen und ein Entscheid über die Betriebsart eines nicht vorhandenen Skripts eine Absichtserklärung wäre. **O-8 wird auf "mit dem Grundgerüst" umterminiert** | DevOps Engineer mit Protocol Master | Mit dem Anlegen der beiden Skripte, also mit dem Grundgerüst |

#### 6.12.21 Bezug zu den offenen Punkten, die das Gate berühren

- **O-7** (Schwellenwerte in D3, D6, D8) bleibt offen und unberührt. Das Gate
  liest die Marke; ob sie `SCHWELLE=5` oder `OHNE_SCHWELLE` trägt, ändert an
  seiner Auswertung nichts.
- **O-8** ist umterminiert, siehe 6.12.20.
- **O-10 (neu gefasst), Restfrage (a)** — die namentliche Ausschlussliste des
  Arbeitsbaumlaufs von D11 und ihre technische Form — trägt heute den Termin
  "mit R3-Q-001". Sie ist nur mit einem ausgeführten Lauf der eingesetzten
  Werkzeugfassung zu belegen, und `gitleaks` ist nicht installiert (Fremdbeleg).
  **Umterminiert auf: mit der Installation von `gitleaks`, spätestens mit dem
  Grundgerüst.** Restfrage (b) bleibt unverändert.
- **O-12** (Lauf auf der Gegenseite) bleibt offen und gewinnt eine Aufgabe: Der
  Lauf auf der Gegenseite ruft `make dod` **ohne** die Liste der terminierten
  Lagen auf. Das Gate ist wie die Kette die zweite Linie — gegen einen Aufrufer,
  der die Umgebung beherrscht, ist ein Gate im Arbeitsverzeichnis grundsätzlich
  wirkungslos, und das steht im Makefile-Kopf und im Kopf beider bestehender
  Gates bereits so. Das Gate ändert daran nichts; es setzt Disziplin durch, es
  ersetzt die Gegenseite nicht.
- **O-14** (fest verdrahteter Ort des zweiten Arbeitsbaums bei D20) bleibt offen
  und wird vom Gate **geerbt**: Die Zahl der nicht prüfbaren Zeilen geht nicht
  in den Rückgabewert ein und steht nicht in der Marke; das Gate sieht sie also
  nicht und kann sie nicht melden. Der Termin "mit R3-Q-001" bleibt; die
  Behebung ist Umsetzung und liegt beim DevOps Engineer.
- **O-15** (Abnahme des Belegprüfers) bleibt offen, siehe 6.12.18, Punkt 4.
- **O-17** (Löschung einer maskierten Datei) bleibt offen und ist vom Gate
  unberührt: D19 Lage C blockiert in jedem Fall; die Antwort bestimmt allein,
  wie weit die Meldung sagen darf, der Inhalt sei beurteilt.
- **O-18** (Aktualität der Bezugsdokumente von D20) **bleibt offen**, mit
  geschärfter Frage und neuem Termin. Der Grund für das Offenbleiben ist keine
  Verlegenheit: Zu prüfen, ob eine Anforderungskennung im Backlog noch **gilt**,
  ist eine Aussage über den Inhalt am Fundort, und genau die hat 6.8.4 dem
  menschlichen Review zugewiesen. Maschinell prüfbar wäre sie erst, wenn der
  Backlog je Eintrag ein **maschinenlesbares Statusfeld** trüge — das ist die
  eigentliche, bisher nicht benannte Vorbedingung, und sie ist eine Änderung am
  Format des Backlogs, nicht am Belegprüfer. Zuständig bleibt der Software
  Architect mit dem Static Software Tester, für das Statusfeld der Requirements
  Engineer mit dem Product Owner; **Termin neu: mit dem Grundgerüst.**

#### 6.12.22 Was diese Fortschreibung nicht ändert

Die Kernarchitektur aus 5.1 bleibt unberührt; diese Fortschreibung betrifft
ausschliesslich die Werkzeugkette. Die Entscheide A1 bis A13 bleiben
unverändert. Der Modulschnitt aus Abschnitt 4 und die Verankerung der
Verfahrensgarantien in 4.2 und 4.3 bleiben unverändert — das Gate ist keine
Verfahrensgarantie nach 5.4, sondern die Durchsetzung der Definition of Done
nach 3.4, und es wird an keiner Stelle zwischen Freigabe und Ausführung
gestellt. Nichts an diesem Entwurf bereitet Gestrichenes vor (5.17, 5.18, 9.1,
5.10, 5.1).

An der Kette bleiben **Gegenstand, Erkennungsmerkmal und Prüfmittel** aller
Schritte unverändert; die einzige Ergänzung ist die Vollständigkeit der
Historie bei D20 (G16). Die Reihenfolge bleibt unverändert. Die Nummernregel
aus 6.1.2 bleibt in Kraft, und diese Fortschreibung vergibt **keine** neue
D-Nummer. Der Kettengrundsatz aus 6.1.3 gilt unverändert und wird durch G8
(Zustand ausserhalb des Arbeitsbaums) und G12 (Sperrdatei ausserhalb des
Arbeitsbaums) auf das Gate selbst ausgedehnt. Der Grundsatz aus 6.8.4 zur
Aussagekraft eines Rückgabewerts 0 gilt unverändert und wird in 6.12.18 auf das
Gate übertragen. Die vier Eigenschaften der Ausnahmeliste aus 6.8.5 bleiben
unverändert; die Liste der terminierten Lagen ist eine **zweite** Liste mit
eigenen Regeln und ändert an der ersten nichts. Die geschärfte Lage C aus 6.9.2
bleibt unverändert und trägt G16.

Geändert werden am `Makefile` ausschliesslich vier Dinge, jedes davon oben
begründet: das Weiterlaufen bei Lage C (G5), das strukturierte `FEHLT=` in der
Marke (G6), die Schlusszeilen samt eigenständiger D19-Zeile und der
Nennung des geprüften Baums (G7 — **vier** Formen seit dem Nachtrag aus dem
Bau, 6.12.23; bis dahin drei) und die Prüfung der Historienvollständigkeit
im Ziel `belege` (G16). Kein Kettenschritt wechselt dadurch seine Lage, und
kein roter Lauf wird grün.

Nicht entschieden werden: die Abnahme des Belegprüfers (O-15), die
Schwellenwerte (O-7), die beiden Restfragen aus O-10, der Lauf auf der
Gegenseite (O-12), der Ort des zweiten Arbeitsbaums (O-14), der Löschfall
(O-17) und die Aktualitätsprüfung (O-18). O-14 und O-17 fallen mit diesem
Backlog-Eintrag fällig, gehören aber dem DevOps Engineer und sind nicht Teil
dieses Entwurfs; ihre Einplanung liegt beim Koordinator.

#### 6.12.23 Nachträge aus dem Bau vom 2026-09-02

Der Bau nach 6.12 ist am 2026-09-02 auf Weisung des Auftraggebers erfolgt; die
förmliche Freigabe der Entscheidpunkte E-A bis E-K steht aus (Abschnitt 10).
Der DevOps Engineer hat dabei **drei Stellen** gemeldet, an denen dieser
Entwurf keinen Fall vorsieht, und je eine Übergangslösung eingebaut, um
weiterarbeiten zu können. Sie werden hier entschieden. Eine Übergangslösung
wird durch einen Nachtrag **abgelöst, nicht bestätigt** — auch dann nicht, wenn
der Entscheid ihr im Ergebnis folgt. Der Unterschied ist nicht formal: Eine
Behelfslösung im Code, die niemand entschieden hat, ist eine Festlegung ohne
Fundstelle, und genau daran misst D20.

Diese Rolle hat **nichts ausgeführt** und nichts nachgeprüft (3.4). Was unten
als Tatsache steht, ist **Fremdbeleg** aus den Läufen des DevOps Engineers und
des Koordinators vom 2026-09-02 und als solcher gekennzeichnet.

**a) Eine vierte Schlusszeile — vollständig gelaufen, und trotzdem Rückgabewert 2**

| | |
|---|---|
| **Vorher galt** | G7 (6.12.8) kennt genau **drei** Schlusszeilen: vollständig und sauber; vollständig mit k Schritten in Lage C; abgebrochen bei einem Schritt |
| **Jetzt gilt** | Es gibt eine **vierte** Form für den Lauf, der vollständig und ohne `A_FAIL` und ohne Lage C durchgelaufen ist, in dem aber die Rahmenprüfung **D19** `VERLETZT` oder Lage C meldet und der deshalb mit 2 endet |

Der Fall ist im Entwurf nicht vorgesehen, und keine der drei Formen trifft ihn:
Form 1 behauptet "keiner ungleich 0" und stünde über einem Lauf mit
Rückgabewert 2; Form 2 verlangt Schritte in Lage C, die es hier nicht gibt;
Form 3 sagt "abgebrochen bei", obwohl nichts abgebrochen wurde. Die
Übergangslösung des DevOps Engineers — Form 3 mit dem zuletzt gelaufenen
Schritt — ist **unwahr**: Sie benennt einen Schritt als Abbruchstelle, der
durchgelaufen ist. Das ist derselbe Mangel, den 6.12.8 für die mittlere Form
schon einmal ausgeschlossen hat: Eine Nachweiszeile, die zu viel oder das
Falsche behauptet, ist so untauglich wie eine fehlende (5.3).

**Entscheid: eine vierte Form.**

```
make dod: alle <N> Kettenschritte durchlaufen, Rahmenpruefung D19 <VERLETZT|C>, Rueckgabewert 2.
```

**Welche Form wann gilt** — in dieser Reihenfolge zu prüfen, damit die Zuordnung
eindeutig ist:

1. Die Kette ist abgebrochen (`A_FAIL`, fehlende oder mehrfache Marke, sonstiger
   Rückgabewert ungleich 0) → **Form 3**.
2. Sonst, wenn mindestens ein Schritt Lage C meldet → **Form 2**, unabhängig
   davon, was D19 meldet. Die D19-Aussage steht ohnehin in ihrer eigenen Zeile
   und wird dort gelesen (G7).
3. Sonst, wenn die D19-Zeile `VERLETZT` oder `C` meldet → **Form 4**.
4. Sonst → **Form 1**.

**Damit gilt: Rückgabewert 0 nur zusammen mit Form 1.** Das ist der eigentliche
Gewinn der vierten Form. Vorher war die Zuordnung von Rückgabewert und
Schlusszeile nicht eindeutig — ein Lauf mit Rückgabewert 2 konnte Form 1 tragen
—, und eine Formprüfung, die das duldet, prüft nichts. Ein Lauf, der
Rückgabewert 0 mit einer anderen Schlusszeile als Form 1 verbindet, ist ein
**Widerspruch** und blockiert unter dem Schlüssel `KETTE
schlusszeile-widerspruch`; die Zeile steht in der Tabelle 6.12.4. Ohne diesen
Ausgang wäre die Parse-Regel ein genannter Massstab ohne Prüfung — V12.

**Was sich für die Klassifizierung nicht ändert.** Das Gate urteilt über diesen
Lauf unverändert über die D19-Zeile, mit den bestehenden Schlüsseln `D19
VERLETZT` beziehungsweise `D19 C` (6.12.4). Die vierte Form ändert an Ausgang,
Schlüssel und Zählung **nichts**; sie stellt die Nachweiszeile richtig und macht
die Parse-Regel prüfbar. Für das Gate ändert sich allein die Formprüfung aus
6.12.3: genau eine der **vier** Formen statt einer der drei. Die beiden
Selbsttestfälle "D19 `VERLETZT`" und "D19 Lage C" aus 6.12.19 sind neu in dieser
Form zu erzeugen; die Anforderung selbst bleibt unverändert.

**b) Der Zählschlüssel für Verstösse gegen die terminierten Lagen**

| | |
|---|---|
| **Vorher galt** | Die Tabelle 6.12.4 führt für die sechs Selbstprüfungen der terminierten Lagen (6.12.5) **keinen** Zählschlüssel. Für Selbstprüfung 1 greift die Zeile "Marke endet auf `C` und ist nicht gedeckt"; für die Selbstprüfungen 2 bis 6 gibt es keinen |
| **Jetzt gilt** | Verstösse gegen die Selbstprüfungen 2 bis 6 zählen unter einem eigenen Schlüsselraum `LISTE …`. Die Übergangslösung `GATE dod-gate-terminierte-lagen.txt` für alle sechs ist abgelöst |

**Entscheid.**

| Selbstprüfung (6.12.5) | Schlüssel |
|---|---|
| 2 (Prüfmittel existiert inzwischen), 3 (Schritt meldet eine andere Lage als C), 5 (Marke nennt ein anderes Prüfmittel als der Schlüssel) | `LISTE <Nummer der Selbstpruefung> <D> <ziel>` |
| 4 (Eintrag ohne Grund), 6 (Schlüssel nennt kein terminierbares Prüfmittel) | `LISTE <Nummer der Selbstpruefung> <Zeilennummer>` |
| 1 (Lage C ohne Eintrag) | unverändert `<D> <ziel> C <fehlendes Prüfmittel>` — kein Fehler der Liste, sondern eine ungedeckte Lage C |

Die **Zeilennummer** ist die physische, bei 1 beginnende Zeilennummer in
`.claude/hooks/dod-gate-terminierte-lagen.txt`; Leer- und Kommentarzeilen
zählen mit, weil nur so die genannte Zeile ohne Umrechnung auffindbar ist.

**Weshalb nicht `GATE …`.** `GATE <Prüfmittel>` bezeichnet den **Ausfall** eines
Prüfmittels des Gates (6.12.11) — bei dieser Liste den einen Fall, dass sie
fehlt. Eine fehlerhafte Zeile in einer vorhandenen Liste ist das Gegenteil
davon: Das Prüfmittel ist da und urteilt, und die Zeile ist zu berichtigen.
Fielen beide unter denselben Schlüssel, hätte das zwei Folgen, und beide sind
in dieser Datei schon einmal teuer gewesen. Erstens zählte 3.4 an einem
Kriterium, das zwei verschiedene Sachverhalte zusammenfasst — die Eskalation
träfe dann eine Mischung statt eines Kriteriums. Zweitens sagte die Meldung dem
Bearbeiter das Falsche: "beschaffe das Prüfmittel" statt "berichtige Zeile n".
Das ist wörtlich der Fehlermodus, den 6.12.4 mit der Unterscheidung von Befund
und Ausfall vermeidet, und der Befund aus 6.11.1: rot mit falscher Begründung.

**Weshalb die Selbstprüfungen 4 und 6 die Zeilennummer tragen und nicht den
Schritt.** Bei ihnen ist die Aussage der Zeile selbst untauglich — bei 4 fehlt
der Grund, bei 6 nennt der Schlüssel ein Prüfmittel, das nach 6.12.5 gar nicht
terminierbar ist. Ein Zählschlüssel, der Kennung und Ziel aus dieser Zeile
übernähme, machte die Behauptung der fehlerhaften Zeile zum Schlüssel des
Zählers, der über sie urteilt. Die Zeilennummer ortet die Zeile, ohne ihr
etwas zu glauben. Dass sie sich verschiebt, sobald die Datei geändert wird, ist
hier richtig und kein Mangel: Eine geänderte Liste ist ein anderer Sachverhalt,
und der Zähler soll dann von vorn zählen.

**Welcher Schlüssel gezählt wird, wenn mehreres zugleich zutrifft.** 6.12.9 legt
fest: gezählt wird eine Abweichung, genannt werden alle. Die Reihenfolge wird
hier für den neuen Schlüsselraum ergänzt und lautet vollständig: (1) `GATE …` —
ohne Prüfmittel urteilt das Gate über gar nichts; (2) `LISTE …`, bei mehreren
fehlerhaften Zeilen die erste in Dateireihenfolge; (3) die erste Abweichung in
Kettenreihenfolge, also `A_FAIL` oder ungedeckte Lage C; (4) `D19 …`.
*(Nachtrag 6.12.24 h, Befund S3-06: Zwischen (1) und (2) tritt `KETTE
ausgabe-unlesbar` — ohne lesbare Ausgabe ist keine Deckungsprüfung möglich.)* Der Grund
für den Vorrang der Liste vor der Kette: Solange eine Zeile der Liste
fehlerhaft ist, beruht die Deckungsprüfung **jeder** gemeldeten Lage C auf einem
Instrument, das selbst beanstandet ist. Zuerst wird das Instrument in Ordnung
gebracht, dann wird über den Gegenstand geurteilt — dieselbe Rangfolge, mit der
6.9.2 Instrument und Gegenstand trennt.

**c) Fehlt `jq`, bleibt der Block ungezählt — eine benannte Grenze**

| | |
|---|---|
| **Vorher galt** | 6.12.11 führt `jq` als Prüfmittel des Gates: Fehlt es, ist das Lage C des Gates mit Rückgabewert 2. Über die Zählung dieses Blocks sagt der Entwurf nichts |
| **Jetzt gilt** | Dieser eine Block wird **nicht gezählt** und kann es nicht werden. Die Grenze ist als solche benannt und steht an Ort in 6.12.9; ein Ersatzweg wird nicht erfunden |

Der Grund ist zwingend und nicht behebbar: Gezählt wird je Sitzung und, wenn
vorhanden, je Subagent (G8). `session_id` und `agent_id` stehen in der
Eingabe-JSON, und ohne `jq` kann das Gate diese Eingabe nicht lesen. Es weiss
also, **dass** es blockiert, aber nicht, **wofür** es den Block anschreiben
soll.

Ein Ausweichschlüssel wird ausdrücklich nicht erfunden. Jeder denkbare — ein
fester Dateiname, die Kennung des Elternprozesses, der Zeitpunkt — zählte
entweder Läufe zusammen, die nichts miteinander zu tun haben, oder trennte
Läufe, die zusammengehören. Ein falsch geführter Zähler ist schlechter als ein
fehlender: Er löst eine Eskalation nach 3.4 aus, für die es keinen Grund gibt,
oder verhindert eine, für die es einen gibt. Die Grenze ist ausserdem eng —
`jq` fehlt für eine ganze Sitzung oder gar nicht, und die beiden bestehenden
Gates blockieren bei fehlendem `jq` aus demselben Grund (CLAUDE.md, "Aktive
Gates"). Der Fall ist damit sichtbar, blockierend und unzählbar; verschwiegen
ist er nicht (V12).

**d) Zwei Tatsachen aus dem Bau (Fremdbeleg, nicht von dieser Rolle geprüft)**

1. **Der Selbsttest `scripts/dod-gate-selbsttest.sh` besteht 48 von 48 Fällen.**
   Ob diese 48 Fälle die Tabelle aus 6.12.19 vollständig abdecken, wird hier
   **nicht behauptet**; das festzustellen ist Sache der Verifikation durch den
   Static und den Dynamic Software Tester auf einem anderen Modell (3.4).
2. **Der grüne Lauf gegen das echte `Makefile` im Scheinbaum ist beim ersten Bau
   nicht grün geworden**, sondern endete mit **D20 in Lage C**: Der Belegprüfer
   meldete im Scheinbaum Rückgabewert 3. Genau diesen Ausgang benennt 6.12.19
   ausdrücklich als möglich — "Ob ein solcher Baum mit dem **echten**
   Belegprüfer grün wird, ist mit einem ausgeführten Lauf festzustellen und wird
   hier **nicht** behauptet; fällt es anders aus, ist der Befund zu melden und
   nicht der Scheinbaum zurechtzubiegen." Der Befund ist gemeldet worden. Die
   Folge ist die dort vorgeschriebene: **Der Scheinbaum wird in prüfbare Form
   gebracht, nicht der Prüfer geschwächt.**

**Die Anforderung aus 6.12.19 bleibt unverändert bestehen und wird hier nicht
abgeschwächt:** Der grüne Lauf muss mit **Rückgabewert 0 der Kette** belegt
sein. Solange dieser Beleg nicht vorliegt, gilt der Selbsttest als **nicht
vollständig** — auch bei 48 von 48 bestandenen Fällen. Das ist
keine neue offene Frage und braucht keine eigene Nummer; es ist die
unveränderte Forderung aus G17, deren Erfüllung noch aussteht. Ein Selbsttest,
der die Attrappe besteht und am echten Gegenstand nicht belegt ist, prüft die
Formannahme des Gates gegen sich selbst — genau das, was 6.12.19 mit dem
zweiten Prüfweg ausschliesst.

**Was diese Nachträge nicht ändern.** Kein Entscheid G1 bis G17 wird
zurückgenommen. Die Kernarchitektur aus 5.1, die Entscheide A1 bis A13, der
Modulschnitt und die Verankerung der Verfahrensgarantien bleiben unberührt.
Keine D-Nummer wird vergeben. Die sechs Selbstprüfungen der terminierten Lagen
bleiben in Zahl, Inhalt und Wirkung unverändert — sie erhalten einen
Zählschlüssel, keine Ausnahme. Kein Kettenschritt wechselt seine Lage, und kein
roter Lauf wird grün. Nichts hier bereitet Gestrichenes vor (5.17, 5.18, 9.1,
5.10, 5.1).

#### 6.12.24 Nachträge aus der Verifikation vom 2026-09-02

Der Bau nach 6.12 ist am 2026-09-02 auf Weisung des Auftraggebers erfolgt; die
förmliche Freigabe der Entscheidpunkte E-A bis E-K steht aus (Abschnitt 10).
Dieser Nachtrag ändert daran nichts. Er behauptet **weder eine Freigabe noch
eine Abnahme** — er entscheidet **zehn** Stellen, an denen der Entwurf einen
Fall nicht vorsieht oder zu wenig sagt: a) bis i) aus der ersten Prüfrunde und
k) aus der zweiten; j) verzeichnet die Beleglage beider Runden.

**Was geprüft wurde, und mit welchem Ergebnis (Fremdbeleg).** Der Static
Software Tester hat den gebauten Stand am 2026-09-02 auf einem anderen Modell
als die Umsetzung gegen 6.12 verifiziert und ihn **nicht bestanden**: vierzehn
Befunde, davon **fünf blockierend** (B-01 bis B-05) und neun nicht blockierend
(N-01 bis N-09). Der Dynamic Software Tester hat am selben Tag ebenfalls
**nicht bestanden**: fünf Befunde, davon **drei blockierend**; die drei
blockierenden haben dieselbe Ursache wie B-02 und B-03. Diese Rolle hat
**nichts ausgeführt** und nichts nachgeprüft (3.4). Was unten als Tatsache
steht, ist **Fremdbeleg** aus diesen beiden Berichten und aus den Läufen des
Koordinators vom 2026-09-02 und als solcher gekennzeichnet.

**Wer was behebt — und weshalb hier überhaupt etwas zu entscheiden ist.** Der
DevOps Engineer behebt B-01, B-02, B-03, N-02 bis N-06, N-08 und N-09 im Code.
B-04 und B-05 sind vom Koordinator in `scripts/belege-ausnahmen.txt` behoben
(Fremdbeleg): die ortsgebundene Ausnahme für `CLAUDE.md`, deren Zeilenangabe
durch das Wachsen der Datei überholt war, ist nachgeführt, und vier Ausnahmen
der Form `datei|wert` decken die in `docs/06_Definition_of_Ready_und_Done.md`
genannten, noch nicht gebauten Skripte. Beides ist **Umsetzung nach 6.8.5 und
kein Architekturentscheid**; dieser Nachtrag verzeichnet es und entscheidet es
nicht — und die vier Einträge sind mit dem Entstehen der Skripte wieder zu
entfernen, wie es 6.8.5, Eigenschaft 3, ohnehin erzwingt. Für **N-01** und
**N-07** wird der Code **nicht** geändert: Dort verhält sich der Bau richtig,
und dieser Entwurf sagt es nicht. Genau das ist der Grund für diesen Abschnitt,
und es ist dieselbe Regel wie in 6.12.23 — **eine Festlegung, die im Code steht
und in diesem ADR nicht, ist eine Festlegung ohne Fundstelle, und genau daran
misst D20.** Die Entscheide unten **lösen** die Behelfe des Baus ab; sie
bestätigen sie nicht, auch dort nicht, wo der Entscheid ihnen im Ergebnis folgt.

**a) Der geprüfte Baum ist die physisch aufgelöste Wurzel des Arbeitsbaums**
*(Befunde B-02 und B-03; die drei blockierenden Befunde der dynamischen Prüfung
haben dieselbe Ursache; ergänzt 6.12.13)*

| | |
|---|---|
| **Vorher galt** | 6.12.13 sagt, das Gate prüfe "den Arbeitsbaum, in dem `cwd` liegt", sofern dieser zu demselben Repository gehört wie `${CLAUDE_PROJECT_DIR}`, sonst diesen. Über die **Form** des so bestimmten Pfades sagt der Entwurf nichts. Der Bau übernahm `cwd` beziehungsweise `CLAUDE_PROJECT_DIR` roh und verglich zeichengenau mit der ersten Zeile der Kette, die das Makefile über `pwd -P` erzeugt (G7) |
| **Jetzt gilt** | Der geprüfte Baum ist die **Wurzel des Arbeitsbaums, physisch aufgelöst**. Gehört `cwd` zum selben Repository wie `${CLAUDE_PROJECT_DIR}` — festgestellt über den Vergleich der physisch aufgelösten gemeinsamen Git-Verzeichnisse, unverändert gegenüber 6.12.13 —, dann gilt `git -C <cwd> rev-parse --show-toplevel`; sonst die Wurzel des Arbeitsbaums von `${CLAUDE_PROJECT_DIR}`, und ist dieses kein Arbeitsbaum, dessen physisch aufgelöster Pfad. Die Baumzeile der Kette und die Bestimmung des Gates sind damit beide physische Pfade ohne Schrägstrich am Ende und vergleichbar |

**Was ohne diese Festlegung geschah** (Fremdbeleg, ausgeführt in beiden
Prüfungen):

1. Ein **Schrägstrich am Ende** des Pfades oder ein **Symlink** auf den Baum
   ergab `KETTE baum-widerspruch` — obwohl in der Sache kein Widerspruch
   bestand, sondern zwei Schreibweisen desselben Baums verglichen wurden.
2. Lag `cwd` in einem **Unterverzeichnis** des Baums, ergab es `GATE Makefile`
   — obwohl das `Makefile` besteht; das Gate suchte es im Unterverzeichnis.

Beide Male endete das Gate mit Rückgabewert 2 und **falscher Begründung**. Das
ist wörtlich der Fehlermodus aus 6.11.1, gegen den die Klassifizierung in
6.12.4 gebaut ist, und er ist hier besonders teuer: Der Block zählt unter einem
Schlüssel, der mit der Sache nichts zu tun hat, und die Eskalation nach 3.4
träfe dreimal die falsche Frage.

**Weshalb die physische Auflösung und nicht ein nachsichtiger Vergleich.** Ein
Vergleich trägt nur, wenn beide Seiten dieselbe Sprache sprechen. Die Kette
bestimmt ihren Baum selbst und ohne Rückfall und gibt ihn über `pwd -P` aus
(G7); also muss das Gate denselben Massstab anlegen, statt die Abweichung
hinterher wegzurechnen. Ein Vergleich, der Schreibweisen duldet, duldet
irgendwann auch zwei verschiedene Bäume — und dann wäre die Baumzeile keine
Prüfung mehr, sondern Zierde. Dass die **Wurzel** genommen wird und nicht das
Verzeichnis, in dem gerade gearbeitet wird, ist dieselbe Überlegung: `make dod`
läuft gegen den Baum, nicht gegen ein Unterverzeichnis.

**Diese eine Angabe trägt vier Dinge**, und deshalb steht sie hier so genau:
den Aufruf von `make dod`, den Vergleich mit der Baumzeile (b), die Namen von
Sperr- und Zählerdatei (e) und die Prüfung, ob die Wegwerfdatei im Baum liegt
(f). Ist sie uneindeutig, sind alle vier uneindeutig.

**b) `KETTE baum-widerspruch` wird in die Klassifizierung aufgenommen**
*(Befund N-01; ergänzt 6.12.4)*

| | |
|---|---|
| **Vorher galt** | G7 verlangt die Baumzeile, 6.12.13 verlangt den Baum in jeder Meldung — einen **Ausgang** für den Fall, dass die Baumzeile der Kette einen anderen Baum nennt als das Gate bestimmt hat, führt die Klassifizierungstabelle 6.12.4 nicht. Der Bau kennt den Schlüssel, die Tabelle nicht |
| **Jetzt gilt** | Die Tabelle 6.12.4 trägt die Zeile: *Die erste Zeile der Kette nennt einen anderen Baum als den vom Gate bestimmten* → Art: Widerspruch, Schlüssel `KETTE baum-widerspruch`, Rückgabewert 2 |

**Weshalb blockierend.** Eine Kette, die über einen anderen Baum berichtet als
den, den das Gate meint, ist **kein Nachweis über diesen Baum**. Sie mag
tadellos gelaufen sein — nur eben anderswo. Das ist derselbe Grund, aus dem G7
die Baumzeile überhaupt verlangt (6.12.8: "Es genügt nicht, richtig zu messen,
es muss auch feststehen, was gemessen wurde") und aus dem 6.12.13 lieber kein
Urteil fällt als ein Urteil über das falsche Verzeichnis.

**Weshalb der Ausgang bleibt, obwohl a) ihn selten macht.** Nach a) sprechen
beide Seiten dieselbe Sprache, und der Schlüssel sollte im Regelbetrieb nicht
mehr fallen. Er ist danach kein Formfehler mehr, sondern die Anzeige eines
echten Auseinanderfallens — ein umgebogener Aufruf, ein zweiter Arbeitsbaum,
ein `Makefile` an unerwarteter Stelle. Fail-closed: Alles ausser einem belegten
Grün blockiert (6.12.4), und ein Grün über einen ungenannten Baum ist keines.
Ein Schlüssel im Code ohne Zeile in der Tabelle wäre ausserdem genau die
Festlegung ohne Fundstelle, die oben benannt ist.

**c) Ein nicht bestimmbares Zustandsverzeichnis erhält keinen eigenen Ausgang**
*(Befund B-01; ergänzt 6.12.9 und 6.12.11)*

| | |
|---|---|
| **Vorher galt** | 6.12.9 nennt `${XDG_STATE_HOME:-$HOME/.local/state}/r3cosint/dod-gate/` und regelt den Fall "nicht beschreibbar". Den Fall, dass sich das Verzeichnis **gar nicht bestimmen** lässt, regelt der Entwurf nicht. Der Bau las `$HOME` unter `set -u`; fehlten `XDG_STATE_HOME` und `HOME`, endete das Gate mit **Rückgabewert 1** (ausgeführt belegt, Fremdbeleg) — und liess damit durch |
| **Jetzt gilt** | `XDG_STATE_HOME`, sonst `$HOME/.local/state`, sonst **nicht bestimmbar**. Dieser Zustand wird behandelt wie "nicht beschreibbar": **kein eigener Ausgang**; das Gate urteilt unverändert und nennt in **jeder** Meldung, dass es nicht zählen kann und weshalb — und die Meldung unterscheidet **nicht bestimmbar** von **nicht beschreibbar** *(Runde 2, Befund S-13: zwei verschiedene Ursachen, zwei verschiedene nächste Schritte)*. Ist die Kette im Übrigen sauber grün, ist dieser Hinweis die **einzige** Meldung: Bei sauberem Grün schweigt das Gate (6.12.15), ausser das Zählwerk oder die Sperre (e) sind ausgefallen. Ausserhalb der Zeitgrenze endet das Gate **nie** mit einem anderen Wert als 0 oder 2 |

**Weshalb das blockierend zu benennen war.** Rückgabewert 1 blockiert nicht
(3.4, CLAUDE.md, "Aktive Gates"). Ein Gate, das an einer fehlenden
Umgebungsvariablen mit 1 endet, lässt genau in der Lage durch, in der es am
wenigsten weiss — die gefährliche Richtung aus 6.8.4, Punkt 3, und aus 6.12.4.
Dass der Ausfall harmlos aussieht, macht ihn nicht harmlos: Er tritt in einer
fremden Umgebung ein, nicht in der, in der man ihn sucht.

**Weshalb trotzdem kein eigener Ausgang.** Das Zustandsverzeichnis trägt nach
6.12.11 allein das Zählwerk und nicht das Urteil. Ein blockierender Ausgang
machte ein Gate, das nicht zählen kann, auch bei grüner Kette rot — ein Gate,
das nichts mehr durchlässt. Die gewählte Behandlung ist die einzige, die in
**beiden** Richtungen richtig ist: nicht durchlassen, weil nicht gezählt werden
kann, und nicht blockieren, weil nicht gezählt werden kann. Sie ist ausserdem
schon entschieden — für den nicht beschreibbaren Fall in 6.12.11 — und wird
hier nur auf den zweiten Weg ausgedehnt, auf dem dasselbe Ergebnis eintritt.

**Jede `exit`-Anweisung des Gates mit festem Wert trägt 0 oder 2** (Fremdbeleg
aus beiden Prüfrunden, je ausgeführt; diese Rolle hat nicht nachgezählt). So —
und ausdrücklich **nicht** als Zahl von Fundstellen — ist der Entscheid
formuliert: Eine Zahl veraltet mit der nächsten geänderten Zeile und wäre beim
nächsten Lauf falsch, ohne dass jemand etwas Falsches getan hätte. Prüfbar ist
die Aussage über `grep -nE '(^|[;&|{] *)exit [0-9]+'` über das Skript; keine
Fundstelle darf einen anderen Wert tragen. *(Runde 3, Befund S3-04: Der zuerst
genannte Ausdruck `^\s*exit [0-9]+` fand nur `exit`-Anweisungen am Zeilenanfang
und übersah ein eingebettetes `exit 2` in der `mktemp`-Zeile — ein Prüfmittel,
das einen Teil des Gegenstands nicht sieht, ist die Fehlerklasse aus 6.9.2.)* Nicht "das Gate soll nicht mit 1 enden",
sondern "es gibt keine Stelle, an der es das könnte".

**d) Der Durchlass nach der Eskalation löscht den Zähler nicht**
*(Befund N-07; ergänzt 6.12.9)*

| | |
|---|---|
| **Vorher galt** | "Ein **Durchlass** löscht den Zähler", mit zwei Ausnahmen: der Durchlass wegen `stop_hook_active` (G9) und das Nichtlaufen für eine Rolle ohne veränderndes Werkzeug (G13) |
| **Jetzt gilt** | Eine **dritte** Ausnahme: Der Durchlass ab dem vierten Mal nach 6.12.9 — die Übergabedatei mit der Eskalationszeile liegt vor — **löscht den Zähler nicht**. Das Kriterium ist erneut gescheitert, also zählt der Zähler wahrheitsgemäss weiter (4, 5, 6), und die Meldung nennt das n-te Mal *(Runde 2, Befund DT2-B1: Die erste Fassung dieses Nachtrags schrieb "lässt den Zähler unverändert"; das war so nie entschieden und ist hiermit berichtigt — nicht gelöscht heisst **weitergezählt**, nicht eingefroren.)* |

**Weshalb.** Der Zähler dokumentiert die Eskalation, bis ein grüner Lauf die
Serie beendet. Löschte der Durchlass ihn, begänne die Zählung beim nächsten
`Stop` derselben Sitzung wieder bei eins: Das Gate blockierte **dreimal neu** am
unverändert roten Kriterium und verlangte für dasselbe Problem eine **zweite**
Übergabedatei. Das wäre die Eskalation als Formel — genau das, was 6.12.9 mit
der Bedingung "neu, geändert oder in `HEAD` enthalten" ausschliessen will, und
das Gegenteil dessen, was 3.4 mit dem Abbruch bezweckt: Ein Problem, das sich
nicht von innen lösen lässt, wird **einmal** vorgelegt und nicht in
Dreierschritten wiederholt.

Gelöscht wird der Zähler weiterhin von einem Durchlass, der das Kriterium
wirklich hinter sich lässt — einem Lauf ohne diese Abweichung. Das ist der
Unterschied, auf den es ankommt: Ein Durchlass, der etwas **feststellt**,
löscht; ein Durchlass, der nur **weiterlässt**, löscht nicht. Für
`stop_hook_active` und für G13 gilt derselbe Satz, und er stand dort schon.

**Ausgeführt belegt** (Fremdbeleg aus beiden Prüfungen der zweiten Runde): Über
sechs Läufe am selben Kriterium trägt die Zählerdatei nacheinander 1, 2, 3, 4,
5 und 6; die Forderung nach der Übergabedatei wird **nur beim dritten Mal**
erhoben, und die Zählung beginnt nicht neu. Damit ist die Aussage geprüft und
nicht bloss behauptet — der Unterschied, auf den V12 in diesem Abschnitt
mehrfach zurückkommt.

**e) Die Sperre entfällt nicht still, wenn das Zustandsverzeichnis fehlt**
*(Befund N-04; ergänzt 6.12.13)*

| | |
|---|---|
| **Vorher galt** | Die Sperrdatei liegt im Zustandsverzeichnis, ausserhalb des Arbeitsbaums (G12). Damit hing die Sperre an derselben Bedingung wie das Zählwerk — war das Verzeichnis nicht beschreibbar, entfiel sie **still** |
| **Jetzt gilt** | Die Sperrdatei liegt im Zustandsverzeichnis; ist dieses nicht beschreibbar oder nicht bestimmbar (c), unter **`/tmp`** — fest, **nicht** `TMPDIR` —, mit demselben Namen aus dem Hash des Baumpfads. Geht auch das nicht, läuft das Gate **ohne Sperre** und sagt das **in jeder Meldung** |

**Weshalb kein blockierender Ausgang.** Die Sperre schützt vor falschem
**Rot**: Zwei gleichzeitige eigene Läufe gegen denselben Baum stören einander
über D19 (6.12.13). Sie schützt nicht vor falschem Grün. Ihr Ausfall darf
deshalb die Arbeit nicht anhalten — er darf aber auch nicht unsichtbar sein,
denn ein `VERLETZT` ohne Sperre hat eine zweite mögliche Ursache, und die
Meldung muss sie nennen, damit niemand einen Befund für bare Münze nimmt, den
das Gate selbst mitverursacht haben kann. Das ist genau die Grenze, die 6.12.13
unter "Die Grenze, die bleibt" schon offen ausspricht, hier für den Fall des
ausgefallenen Verzeichnisses.

**Weshalb `/tmp` fest und nicht `TMPDIR`.** Eine Sperre wirkt nur, wenn alle
Beteiligten **dieselbe** Datei nehmen. `TMPDIR` kann je Prozess verschieden
gesetzt sein; zwei Läufe mit verschiedenem `TMPDIR` hielten zwei verschiedene
Sperren und liefen doch gleichzeitig. Eine Sperre, die nicht sperrt, ist
schlechter als keine, weil man sich auf sie verlässt. `/tmp` liegt zudem
ausserhalb jedes Arbeitsbaums; der Kettengrundsatz aus 6.1.3 bleibt gewahrt.

**f) Die Wegwerfdatei liegt nachweislich ausserhalb des Baums**
*(Befund N-06; ergänzt 6.12.15 und 6.12.9)*

| | |
|---|---|
| **Vorher galt** | 6.12.15 verlangt, dass das Gate Standard- und Fehlerausgabe der Kette gemeinsam abfängt; **wo** die Ausgabe zwischenliegt, sagt der Entwurf nicht. Der Bau nahm `mktemp`, und `mktemp` folgt `TMPDIR`. Zeigt `TMPDIR` in den Arbeitsbaum, entsteht die Datei im **beurteilten** Baum, und D19 meldet `VERLETZT` |
| **Jetzt gilt** | Nach dem Anlegen prüft das Gate den **physisch aufgelösten** Pfad der Wegwerfdatei. Liegt er im geprüften Baum, wird die Datei gelöscht und unter `/tmp` neu angelegt. Gelingt auch das nicht, endet das Gate mit **2** und dem Schlüssel `GATE mktemp` |

**Weshalb.** Das ist der Kettengrundsatz aus 6.1.3, auf das Gate angewandt —
dieselbe Überlegung, die den Zähler aus dem Baum genommen hat (G8) und die
Sperrdatei (G12). Ein Gate, das den Befund erzeugt, den es meldet, misst sich
selbst; und weil D19 den ganzen Lauf einklammert, wäre der Befund nicht einmal
falsch, sondern richtig und trotzdem wertlos. **Geprüft** wird der Pfad und
nicht bloss angenommen, weil `TMPDIR` von aussen kommt — V12: Ein genannter
Massstab, den niemand prüft, ist keiner.

**Weshalb hier ausnahmsweise blockiert wird.** Ohne Wegwerfdatei kann das Gate
die Ausgabe der Kette nicht auffangen und also nicht auswerten; ohne Auswertung
gibt es kein belegtes Grün (6.12.4). Der Ausgang gehört damit zu den
Prüfmitteln des Gates und nicht zur Meldung — deshalb steht `mktemp` in g) auch
in der Tabelle 6.12.11.

**Die zweite Hälfte desselben Befunds** *(Runde 2, Befund DT2-B2, ausgeführt
belegt mit einem Beobachter im 20-ms-Takt; Fremdbeleg)*. Das Gate reichte
`TMPDIR` unverändert an `make dod` durch. Zeigt `TMPDIR` in den geprüften Baum,
legt die **Kette selbst** dort eine Datei an — die Ziele `nachweise` und
`abdeckung` rufen je `mktemp` auf —, für rund 0,4 s. **D19 sieht sie nicht**:
Die Rahmenprüfung misst Prüfsummen der versionierten Dateien. Das Gate hätte
seinen eigenen Grundsatz also gewahrt und die Kette gegen ihn laufen lassen,
ohne dass ein Befund entstünde — der Fall, vor dem 6.8.4 warnt: Ein
Rückgabewert 0 sagt nur, was gefunden wurde, nicht, dass nichts geschehen ist.

**Entscheid:** Der Kettenlauf erhält `TMPDIR` gleich dem Verzeichnis der
geprüften Wegwerfdatei des Gates — also demjenigen Verzeichnis, von dem oben
nachgewiesen ist, dass es ausserhalb des Baums liegt. Damit gilt der
Kettengrundsatz aus 6.1.3 für beide Seiten, und er gilt aus dem richtigen
Grund: nicht, weil D19 nichts gemeldet hat, sondern weil im Baum nichts
entsteht. Eine Umgebungsvariable, die das Gate von aussen ungeprüft
weiterreicht, ist ohnehin die Lücke, die 6.6.1 an `$(UV)` schon einmal
schliessen musste.

**Fortgeschrieben am 2026-09-03 durch 6.12.25 c** *(Befund DT3-B1 aus Runde 3,
Fremdbeleg)*. Die Fassung oben prüft den Pfad **nach** dem Anlegen; ausgeführt
belegt ist, dass die Wegwerfdatei damit für rund 6,9 ms **im geprüften Baum**
besteht, bevor sie verlagert wird. Der Wortlaut dieses Entscheids ist dabei
erfüllt, sein Zweck — der Kettengrundsatz aus 6.1.3 — verfehlt. **Neu gilt
zusätzlich:** Das Zielverzeichnis wird **vor** dem Anlegen bestimmt (`TMPDIR`
physisch aufgelöst; liegt es im Baum oder ist es nicht auflösbar, gilt `/tmp`;
dann `mktemp -p` in diesem Verzeichnis), und ein physisch nicht auflösbares
Verzeichnis endet mit 2 und `GATE mktemp` (6.12.25 d, Befund S3-05). Die
Prüfung nach dem Anlegen **bleibt** als Wache. Dieser Absatz wird nicht
umgeschrieben, sondern trägt den Vermerk an Ort (6.1.2, 6.11.5).

**g) Zwei weitere Prüfmittel des Gates: `sha256sum` und `mktemp`**
*(Befund N-09 und eine Ergänzung des Koordinators; ergänzt 6.12.11)*

| | |
|---|---|
| **Vorher galt** | 6.12.11 zählt **sieben** Prüfmittel, sechs davon blockierend. `sha256sum` — mit dem die Namen von Sperr- und Zählerdatei aus dem Pfad des geprüften Baums gebildet werden — und `mktemp` kommen darin nicht vor, obwohl das Gate beide braucht |
| **Jetzt gilt** | Beide stehen in der Tabelle. Fehlt eines, ist das **Lage C des Gates**, Rückgabewert 2, Schlüssel `GATE sha256sum` beziehungsweise `GATE mktemp`, und die Meldung nennt den Beschaffungsweg — beide gehören zu den coreutils |

**Weshalb das nachzutragen war.** V12 verlangt, dass ein genanntes Prüfmittel
auch geprüft wird. Die Umkehrung gilt genauso und ist hier der Punkt: **Was der
Code braucht, gehört in die Tabelle** — sonst fällt es ungenannt aus, und das
Gate scheitert an einer Stelle, für die es keine Meldung hat. Ein fehlendes
`sha256sum` nähme ihm die Namensbildung für Sperre und Zähler, ein fehlendes
`mktemp` die Auswertung der Ausgabe; beides ist ein Ausfall des Instruments und
kein Befund am Gegenstand (6.9.2).

**Zur Zahl im Text darunter.** Der Absatz "Die Präzedenz" in 6.12.11 spricht von
"allen sechs blockierenden Prüfmitteln". Diese Zahl wird **nicht
umgeschrieben** — sie war am 2026-09-02 vor der Verifikation richtig.
Massgeblich ist nach Regel 2 aus 6.2.2 die **Tabelle**, und sie führt seit
diesem Nachtrag **acht** blockierende Prüfmittel und neun insgesamt; ein
Verweis an Ort sagt das. Der Satz selbst — jede Meldung nennt das fehlende
Mittel und den Beschaffungsweg — gilt unverändert für alle.

**h) Reihenfolge der Selbstprüfungen und der `LISTE`-Schlüssel**
*(Befund N-05; präzisiert 6.12.23 b)*

| | |
|---|---|
| **Vorher galt** | 6.12.23 b sagt: bei mehreren fehlerhaften Zeilen "die erste in Dateireihenfolge" — ohne Rücksicht darauf, dass die Selbstprüfungen **3** (der Schritt meldet eine andere Lage als C) und **5** (die Marke nennt ein anderes Prüfmittel als der Schlüssel) die Ausgabe der Kette brauchen, die Selbstprüfungen **2**, **4** und **6** dagegen nicht |
| **Jetzt gilt** | Die **strukturellen** Selbstprüfungen 2, 4 und 6 laufen **vor** der Kette über die ganze Liste. Blockiert wird mit der fehlerhaften Zeile mit der **kleinsten Zeilennummer**, gleich welcher der drei Prüfungen sie zuzuordnen ist. Erst wenn alle drei bestehen, läuft die Kette; danach laufen 3 und 5 über alle Einträge, und wiederum blockiert die erste in Dateireihenfolge |

**Zwei Gründe, und beide stehen schon in diesem Abschnitt.** Erstens: Eine
strukturell fehlerhafte Liste ist zu berichtigen, **bevor** die Kette bis zu
zehn Minuten läuft (G11). Das ist keine Bequemlichkeit, sondern die Rangfolge
aus 6.12.23 b — solange das Instrument beanstandet ist, wird über den
Gegenstand ohnehin nicht geurteilt. Zweitens: Der Schlüssel muss über Läufe
hinweg **stabil** sein, sonst zählt 3.4 nie dreimal dasselbe Kriterium
(6.12.9). Hinge die Auswahl davon ab, welche Prüfung zufällig zuerst anschlägt,
trüge dieselbe unveränderte Liste in zwei Läufen zwei Schlüssel — und die
Eskalation griffe nie. Die kleinste Zeilennummer ist die einzige Ordnung, die
von der Prüfreihenfolge unabhängig ist.

Die Selbstprüfungen bleiben in **Zahl, Inhalt und Wirkung unverändert**; dieser
Entscheid ordnet allein, wann sie laufen und welcher ihrer Befunde zählt.

**Die Rangfolge, um einen Schlüssel ergänzt** *(Runde 3, Befund S3-06)*. Sie
lautet vollständig: `GATE …` — `KETTE ausgabe-unlesbar` — `LISTE …` — die erste
Abweichung in Kettenreihenfolge — `D19 …`. Neu ist allein die zweite Stelle:
Ohne lesbare Ausgabe der Kette lässt sich **keine** Deckungsprüfung anstellen,
denn die Selbstprüfungen 3 und 5 vergleichen mit der gemeldeten Lage und mit
der Marke. Ein Zählschlüssel aus der Liste über eine Ausgabe, die niemand lesen
konnte, wäre eine Aussage über nichts. Der Bau verhält sich bereits so
(Fremdbeleg): Die Markenzahlprüfung aus k) läuft vor `LISTE 3` und `LISTE 5`;
hier wird das entschieden statt geduldet.

**i) Was der Selbsttest zusätzlich zu decken hat**
*(Befunde N-02 und N-03 der statischen, DT-B4 und DT-B5 der dynamischen
Prüfung; ergänzt 6.12.19)*

| | |
|---|---|
| **Vorher galt** | 6.12.19 verlangt einen Fall für die D19-Zeile "in allen vier Schlüsselwortformen, je mit und ohne Zusatztext" und einen G13-Fall für "den belegten Fall `static-software-tester` und `pentester`". Zu G12 — welcher Arbeitsbaum geprüft wird — führt die Falltabelle **keine** Zeile |
| **Jetzt gilt** | Der Fall zur D19-Zeile deckt **alle acht** Kombinationen. Der G13-Fall verwendet die **echten** Rollendateien `static-software-tester.md` und `pentester.md` aus `.claude/agents/`, in den Scheinbaum kopiert, dazu einen Gegenfall mit `devops-engineer.md`. Neu hinzu kommen Fälle für **G12** und je einer für die Entscheide a), c), e), f), g) und h) sowie für den Makefile-Befund N-08. Der Fall zur committeten Übergabedatei muss diese **nachweislich in `HEAD`** haben. Die Zeilen stehen in der Tabelle 6.12.19 und tragen dort den Vermerk |

**Weshalb die echten Rollendateien (N-03).** G13 misst den **Gegenstand** — hat
diese Rolle ein Werkzeug, über das ADR 0001 Schreibrecht vergibt? — und nicht
einen Namen (6.12.14). Ein Selbsttest gegen erfundene Rollendateien prüft die
Formannahme des Gates gegen sich selbst; genau das schliesst 6.12.19 mit dem
zweiten Prüfweg aus. Ändert sich das `tools:`-Feld einer der drei echten
Dateien, muss der Selbsttest es merken — sonst ist er in dem Augenblick still
falsch, in dem er gebraucht würde.

**Weshalb G12 eigene Fälle bekommt (DT-B5).** Der Entscheid a) ist die Antwort
auf drei blockierende Befunde, die alle daran hingen, wie das Gate den Baum
bestimmt. Ein Entscheid, dessen Fälle in der Prüftabelle fehlen, ist ein
genannter Massstab ohne Prüfung — V12, und in diesem Abschnitt zum vierten Mal
dieselbe Fehlerklasse. Gedeckt sind deshalb: `cwd` im Unterverzeichnis, mit
Schrägstrich am Ende und über einen Symlink; `cwd` ausserhalb jedes
Arbeitsbaums dieses Repositories; und der zweite Arbeitsbaum (`git worktree`),
für den G12 überhaupt gebaut ist.

**Weshalb der Fall zur committeten Übergabedatei nachzuschärfen ist (DT-B4).**
Der Fall hat bestanden, ohne seine Behauptung zu belegen: Die Übergabedatei war
im Augenblick der Prüfung weder neu noch geändert noch in `HEAD` — der
Hilfscommit hatte nichts zu committen (Fremdbeleg). Das ist ein Mangel am
**Prüfmittel**, nicht am Gegenstand: Das Gate selbst verhält sich richtig, ein
eigener Lauf des Testers mit committeter Übergabedatei auf `TaskCompleted`
endete mit 2 (Fremdbeleg). Ein grüner Prüffall, der nichts gemessen hat, ist
aber die gefährlichste Zeile einer Prüftabelle — er sieht aus wie Deckung und
ist keine. Dieselbe Unterscheidung wie in 6.9.2, eine Ebene höher.

**Der Makefile-Befund N-08.** Meldet D12 Lage C und fehlen **mehrere**
Gegenstände, so nennt `FEHLT=` den **ersten**; ein späterer `if`-Block
überschreibt ihn nicht. Das ist keine neue Regel, sondern die Anwendung von G6:
Die Marke trägt das fehlende Prüfmittel, und der Schlüssel der terminierten
Lagen wird gegen genau diesen Wert geprüft (Selbstprüfung 5). Wechselte der
Wert je nach Prüfreihenfolge, träfe ein gültiger Eintrag die Marke einmal und
einmal nicht, und das Gate blockierte mit einer Begründung, die nicht stimmt.
Der Selbsttest erhält dafür einen eigenen Fall.

**j) Der Stand der Verifikation — Fremdbeleg, und was er nicht sagt**

Alles in diesem Abschnitt ist Fremdbeleg aus den beiden Prüfberichten vom
2026-09-02 und den Läufen des Koordinators; diese Rolle hat nichts ausgeführt
und nichts nachgeprüft (3.4).

1. **Der Selbsttest `scripts/dod-gate-selbsttest.sh` bestand vor dieser Runde
   50 von 50 Fällen.** Der Fremdbeleg "48 von 48" in 6.12.23 d bleibt als
   damaliger Stand stehen und wird nicht umgeschrieben — er war am 2026-09-02
   richtig, und ein vergangener Stand belegt einen vergangenen Stand
   (Abschnitt 9, letzter Absatz).
2. **Die statische Prüfung ist nicht bestanden**: vierzehn Befunde, fünf davon
   blockierend (B-01 bis B-05).
3. **Die dynamische Prüfung ist ebenfalls nicht bestanden**: fünf Befunde, drei
   davon blockierend. Die drei blockierenden — `cwd` in einem Unterverzeichnis
   ergab `GATE Makefile`, ein Pfad mit Schrägstrich am Ende und ein Pfad über
   einen Symlink ergaben `KETTE baum-widerspruch` — haben dieselbe Ursache wie
   B-02 und B-03 und sind mit Entscheid a) gedeckt. Die beiden nicht
   blockierenden (DT-B4, DT-B5) betreffen den Selbsttest und sind in i)
   aufgenommen.
4. **Ohne Beanstandung geprüft** hat die dynamische Prüfung: die
   Ende-zu-Ende-Eskalation nach 3.4 in neun Läufen (Zähler 1, 2, 3 mit der
   Eskalationszeile; ohne Übergabedatei weiter 2; mit neuer und mit committeter
   Übergabedatei 0; `TaskCompleted` trotzdem 2; ein anderer Schlüssel zählt neu
   bei 1; ein Durchlass löscht den Zähler); den Reentranz-Schutz
   (`stop_hook_active` bei `Stop` → 0 ohne Lauf der Kette; bei `TaskCompleted`
   nicht ausgewertet, die Kette lief); `SubagentStop` mit den echten Rollen
   (`static-software-tester` und `pentester` → 0 ohne Lauf; `devops-engineer` →
   Kette läuft; unbekannte, leere und plugin-bezogene Rolle → Kette läuft); die
   Manipulationsfälle (fehlende Marke → `KETTE marke-fehlt`; Listeneintrag mit
   existierendem Pfad → `LISTE 2 …`; Eintrag ohne ADR-Grund → `LISTE 4
   <Zeilennummer>`; ein fremder Schreiber während des Laufs → `D19 VERLETZT`);
   die innere Zeitgrenze; die Nebenläufigkeit (zwei Läufe durch `flock`
   serialisiert, drei Sitzungen drei Zähler); und die Ausgabeform (auf der
   Standardausgabe genau ein JSON-Objekt mit `systemMessage` beim Durchlass,
   nichts beim Block, nie die Ausgabe der Kette).
5. **Die gemessene Laufzeit gehört zu O-20 und schliesst ihn nicht.** Gemessen
   wurden 6,4 bis 7,0 s je Lauf des Gates auf dem echten Baum (Mittel 6,65 s)
   und 7,6 bis 8,2 s für einen vollständigen Lauf im Klon. Das ist der heutige
   Stand **ohne** `backend/` und `deploy/`; O-20 fragt nach der Laufzeit **mit**
   dem Grundgerüst und bleibt offen. Die Grenzen von 600 s und 900 s bleiben
   unverändert, bis der Auftraggeber entscheidet (Abschnitt 8, O-20).
6. **Ein Hinweis des Testers, kein Befund**, hier verzeichnet, damit die Frage
   nicht ein zweites Mal gestellt wird: Meldet ein Lauf drei terminierte Lagen C
   **und** D19 `VERLETZT`, trägt die Schlusszeile **Form 2** und nicht Form 4.
   Das ist genau die Prüfreihenfolge aus 6.12.23 a — Lage C vor D19 —, und sie
   nimmt der D19-Aussage nichts: Sie steht in ihrer eigenen Zeile, wird dort
   gelesen, und der Zählschlüssel bleibt `D19 VERLETZT`. Kein Entscheid ändert
   sich.
7. **Was nach der Behebung gilt, belegt die zweite Prüfrunde — nicht dieser
   Nachtrag.** Er entscheidet zehn Punkte; ob der Bau sie erfüllt, stellen
   Static und Dynamic Software Tester auf einem anderen Modell fest (3.4), und
   die Rollen, die gebaut haben, prüfen ihre eigene Arbeit nicht. Unverändert
   bestehen bleibt auch die Forderung aus 6.12.23 d: Solange der grüne Lauf
   gegen das **echte** `Makefile` nicht mit **Rückgabewert 0 der Kette** belegt
   ist, gilt der Selbsttest als **nicht vollständig** — 50 bestandene Fälle
   ändern daran so wenig wie zuvor 48.

**Die zweite Prüfrunde vom 2026-09-02 (Fremdbeleg, nachgetragen).** Sie hat
stattgefunden, und ihr Ergebnis gehört hierher, weil Punkt 7 sie ausdrücklich
zum Massstab erklärt hat:

8. **Alle fünf blockierenden Befunde aus Runde 1 sind mit eigenen Läufen als
   behoben belegt**, statisch wie dynamisch. Der Selbsttest besteht **67 von
   67** Fällen.
9. **Beide Prüfungen sind wegen neuer Punkte nicht bestanden.** Statisch:
   dreizehn Befunde, vier davon blockierend — **S-01** (die Klassifizierung von
   D19 Lage B bei Rückgabewert 0) und **S-03**, **S-04**, **S-05** (drei
   fehlende Selbsttestfälle). Dynamisch: zwei Befunde und ein Hinweis,
   blockierend **DT2-B1** — der Wortlaut von d). Alle sind oben eingearbeitet:
   S-01 und S-10 als Vermerke in 6.12.4, S-11 als Entscheid k), S-13 in c),
   DT2-B1 in d), DT2-B2 in f), die fehlenden Fälle in der Tabelle 6.12.19.
10. **Der Lauf am echten Bestand** (Fremdbeleg): `make dod` im echten Baum
    endete mit **Form 2** — Lage C bei D7, D10 und D12 —, Rückgabewert 2; der
    unmittelbare Aufruf des Gates auf dieselbe Ausgabe endete mit **0** und der
    `systemMessage` "Durchlass mit terminierten Lagen C". Das ist genau der
    Ausgang, den G4 vorsieht, und er ist damit erstmals am echten Bestand
    beobachtet. Die Forderung aus 6.12.23 d ist davon zu trennen und nach
    Fremdbeleg **erfüllt**: Selbsttestfall 28 lässt das **echte** `Makefile`
    in einem Scheinbaum laufen, und beide Prüfer belegen für ihn **Rückgabewert
    0 der Kette** mit Schlusszeile Form 1 (Static Software Tester, Runde 1 und
    2; Dynamic Software Tester, Runde 1 und 2). Am echten Bestand selbst ist
    ein grüner Lauf erst möglich, wenn die drei terminierten Lagen C durch die
    Skripte des Grundgerüsts abgelöst sind — das ist kein Mangel des
    Selbsttests, sondern der belegte Zustand nach 6.12.5.
11. **Eine Beobachtung des Static Software Testers, die hier festgehalten
    wird**: Die Fehlerklasse "ein Selbsttestfall besteht, ohne seine Behauptung
    zu belegen" ist nun **zweimal** aufgetreten — DT-B4 in Runde 1, S-01 in
    Runde 2. Beim **dritten** Mal greift 3.4 für dieses Kriterium: abbrechen,
    Übergabedatei schreiben, dem Auftraggeber vorlegen. Das steht hier, damit
    die Zählung nicht mit jeder Runde von vorn beginnt — dieselbe Überlegung,
    aus der d) den Zähler weiterlaufen lässt.
12. **Die dritte Prüfrunde vom 2026-09-03 (Fremdbeleg).** Alle **dreizehn**
    Befunde aus Runde 2 sind mit eigenen Läufen **beider** Prüfer als behoben
    belegt; der Selbsttest besteht **81 von 81** Fällen, unabhängig
    reproduziert; `make dod` im echten Baum endete mit **Form 2** (D7, D10 und
    D12 terminiert), Rückgabewert 2, und der Aufruf des Gates darauf mit **0**
    und der `systemMessage` "Durchlass mit terminierten Lagen C".
13. **Statisch gleichwohl nicht bestanden.** Blockierend ist **S3-01**: Die
    Blockmeldung nennt nur den **gezählten** Schlüssel und nicht alle
    Abweichungen, während 6.12.9 und die Tabellenzeile 6.12.19 (Runde 1, B7)
    verlangen: gezählt wird eine, verschwiegen wird keine. Ausgeführt belegt an
    einem Lauf mit zwei ungedeckten Lagen C, einem `A_FAIL` und D19 `VERLETZT`
    — genannt wurde allein D7. Der zugehörige Selbsttestfall ist grün, **ohne
    diese Hälfte der Zusicherung zu messen**. Nicht blockierend: **S3-02** (die
    Fälle zur Markenzahl decken nur Form 1), **S3-03** (drei Tabellenzeilen
    verlangten eine Meldung bei sauberem Grün, die 6.12.15 ausschliesst),
    **S3-04** (der in c) genannte `grep`-Ausdruck übergeht ein eingebettetes
    `exit 2` in der `mktemp`-Zeile), **S3-05** (bleibt das Verzeichnis der
    Wegwerfdatei unauflösbar, fällt die Wache **offen** aus), **S3-06**
    (`KETTE ausgabe-unlesbar` ist in der Rangfolge nicht eingeordnet, während
    die Markenzahlprüfung im Bau bereits vor `LISTE 3` und `LISTE 5` läuft),
    **S3-07** (der Fall zu d) prüft nicht, dass die Forderung nach der
    Übergabedatei kein zweites Mal erhoben wird). S3-03, S3-04 und S3-06 sind
    als Berichtigungen an Ort eingearbeitet — in den drei G12-Zeilen der
    Tabelle 6.12.19, im `grep`-Ausdruck in c) und in der Rangfolge in h).
14. **Dynamisch ebenfalls nicht bestanden.** **DT3-B1**: Zeigt `TMPDIR` in den
    geprüften Baum, legt das Gate seine Wegwerfdatei **zuerst dort** an und
    verlagert sie erst nach rund **6,9 ms** (Beobachter ohne Wartezeit, 922
    Treffer; der 20-ms-Takt der zweiten Runde sah davon nichts). Das entspricht
    dem **Wortlaut** von f) — geprüft wird **nach** dem Anlegen — und verletzt
    gleichwohl den Kettengrundsatz aus 6.1.3, den f) auf das Gate anwendet. Ein
    Entscheid, dessen Wortlaut erfüllt ist und dessen Zweck verfehlt wird, ist
    ein Mangel des Entscheids und nicht des Baus; die Behebung steht unten als
    Vorschlag. Die übrigen sechs Prüfpunkte blieben **ohne Beanstandung**: Die
    Kette legt nichts mehr im Baum an; der Zähler trägt 1 bis 7 über sieben
    Läufe; eine Umbenennung über `git mv` wird erkannt; das nicht bestimmbare
    Zustandsverzeichnis verhält sich bei Grün wie bei Rot richtig; fünf
    Klassifizierungsfälle und die Ausgabeform sind in Ordnung.
15. **Dieselbe Fehlerklasse zum dritten Mal — die Arbeitseinheit ist
    abgebrochen.** "Ein Selbsttestfall besteht, ohne seine Behauptung zu
    belegen" ist mit S3-01 zum **dritten** Mal aufgetreten (DT-B4 in Runde 1,
    S-01 in Runde 2, S3-01 in Runde 3). Punkt 11 hat genau diesen Fall
    vorgezeichnet, und 3.4 verlangt dann den Abbruch. Der Koordinator hat die
    Einheit am **2026-09-03** abgebrochen;
    `docs/uebergaben/2026-09-02_r3-q-001-gate-gebaut.md` trägt die Zeile
    `Eskalation 3.4: Selbsttestfall besteht, ohne seine Behauptung zu belegen`.
    **Vorgelegt wird nicht die vierte Einzelbehebung**, sondern die Frage
    dahinter — die Beobachtung des Static Software Testers: Die Tabelle 6.12.19
    führt je Zeile **mehrteilige** Erwartungen, der Selbsttest je Fall **eine**
    Zusicherung; wo eine Zeile mehr verspricht als Rückgabewert und Schlüssel,
    bleibt der Rest ungemessen. Wie eine solche Zeile in einzeln prüfbare
    Zusicherungen zerlegt wird, ist als **O-24** in Abschnitt 8 terminiert und
    liegt beim Auftraggeber.
16. **Fünf Behebungen als Vorschlag, nicht als Entscheid.** Sie gehören in die
    nächste Einheit **nach** dem Entscheid zu O-24, weil eine vierte
    Einzelbehebung an derselben Fehlerklasse genau das wäre, was 3.4
    ausschliesst: (1) zu S3-01 — die Blockmeldung führt **alle** Abweichungen
    auf, gezählt wird weiterhin **eine**; (2) zu DT3-B1 — das Zielverzeichnis
    der Wegwerfdatei wird **vor** dem Anlegen bestimmt, die Prüfung danach
    bleibt als Wache stehen; (3) zu S3-05 — ein unauflösbares Verzeichnis ist
    `GATE mktemp` und damit fail-closed; (4) zu S3-02 und (5) zu S3-07 die
    fehlenden Selbsttestfälle. Dieser Nachtrag **entscheidet sie nicht**.

**k) Das Gate prüft die Zahl der Marken gegen die Selbstaussage der Kette**
*(statischer Befund S-11 aus Runde 2; ergänzt 6.12.3 und 6.12.4)*

*(Dieser Entscheid steht hinter j), weil Buchstaben so wenig umnummeriert
werden wie D-Nummern (6.1.2). Entscheide sind a) bis i) und k); j) verzeichnet
die Beleglage beider Prüfrunden.)*

| | |
|---|---|
| **Vorher galt** | 6.12.3 sagt, das Gate zähle **nicht** die Kettenschritte und lese "die Aussage, nicht die Zahl"; 6.12.4 sagt, alles ausser einem belegten Grün blockiere. Zwischen beiden lag eine Lücke: Eine Ausgabe mit Baumzeile, Form-1-Schlusszeile ("alle 14 Kettenschritte durchlaufen … 14 gueltige Marken gezaehlt"), D19 `OHNE_BEFUND`, Rückgabewert 0 und **null** Marken liess das Gate **stumm mit 0** durch (ausgeführt belegt, Fremdbeleg) |
| **Jetzt gilt** | Das Gate vergleicht die Zahl der **gelesenen** Marken mit der Zahl, die die Schlusszeile **selbst nennt** — Form 1 "`<N>` gueltige Marken gezaehlt", Form 2 und Form 4 "alle `<N>` Kettenschritte durchlaufen"; Form 3 (abgebrochen) nennt keine solche Zahl und wird darauf nicht geprüft — und es verlangt **mindestens eine** Marke. Weicht die Zahl ab oder ist keine Marke vorhanden, blockiert es unter `KETTE ausgabe-unlesbar` |

**Weshalb das 6.12.3 nicht widerspricht.** Dort ist entschieden, dass das Gate
**keine eigene** Zahl führt — keine feste Erwartung "vierzehn Schritte", die mit
dem nächsten Kettenschritt falsch würde (V13, und die Tautologie aus Befund A3).
Dieser Entscheid führt keine solche Zahl ein. Er prüft die Kette **gegen sich
selbst**: Ihre Schlusszeile behauptet eine Zahl, ihre Übersicht trägt die
Marken, und beide müssen zusammenpassen. Das ist dasselbe Muster, das die Kette
für ihre eigenen Schritte längst anwendet — zwei Kriterien statt eines — und das
G7 mit der Baumzeile für den Baum eingeführt hat: Eine Selbstaussage wird erst
dann zum Nachweis, wenn sie sich gegen den Inhalt prüfen lässt.

**Weshalb "mindestens eine Marke".** Ohne diese Untergrenze bliebe der teuerste
Fall offen: eine Ausgabe, die null Marken behauptet und null Marken trägt — in
sich stimmig und ohne jedes Urteil. Ein belegtes Grün setzt nach 6.12.4 voraus,
dass die Kette **gelaufen** ist; eine Ausgabe ohne eine einzige Marke belegt
keinen Lauf, sondern nur, dass jemand Zeilen gedruckt hat.

**Weshalb `KETTE ausgabe-unlesbar` und kein neuer Schlüssel.** Der Fall gehört
zur Art "nicht nachweisbar gelaufen", wie eine fehlende Übersichtszeile oder
eine fehlende Schlusszeile (6.12.4). Ein eigener Schlüssel spaltete das
Kriterium des Zählers, ohne dem Bearbeiter etwas anderes zu sagen: Die Ausgabe
der Kette ist unbrauchbar, und der nächste Schritt ist derselbe. Dieselbe
Rangfolge gilt gegenüber `D19 B-widerspruch`, der nach S-01 **vorgeht** — dort
ist die Ausgabe lesbar, und der Widerspruch hat einen Namen.

**Was diese Nachträge nicht ändern.** Kein Entscheid G1 bis G17 wird
zurückgenommen. Die Kernarchitektur aus 5.1, die Entscheide A1 bis A13, der
Modulschnitt aus Abschnitt 4 und die Verankerung der Verfahrensgarantien in 4.2
und 4.3 bleiben unberührt; das Gate steht an keiner Stelle zwischen Freigabe und
Ausführung (5.2). Keine D-Nummer wird vergeben, und die Nummernregel aus 6.1.2
bleibt in Kraft. Die sechs Selbstprüfungen der terminierten Lagen bleiben in
Zahl, Inhalt und Wirkung unverändert — h) ordnet allein ihre Reihenfolge. Die
vier Schlusszeilen aus G7 und ihre Zuordnung aus 6.12.23 a bleiben unverändert.
Kein Kettenschritt wechselt seine Lage, und kein roter Lauf wird grün. Nichts
hier bereitet Gestrichenes vor (5.17, 5.18, 9.1, 5.10, 5.1). Und nichts hier
ist eine Freigabe: Der Bau läuft auf die Weisung vom 2026-09-02, die förmliche
Freigabe der Entscheidpunkte E-A bis E-K steht aus (Abschnitt 10).

#### 6.12.25 O-24 — die Prüftabelle in Zusicherungen zerlegt (Entscheid des Auftraggebers vom 2026-09-03)

**a) Die Form der Zerlegung**

| | |
|---|---|
| **Vorher galt** | Die Tabelle 6.12.19 führte je Zeile einen **Fall** und eine **mehrteilige Erwartung** — "2, mit Nennung des Mittels", "0, mit `systemMessage`, die den Schritt nennt", "Durchlass beim vierten Mal", "genannt werden alle". Der Selbsttest führte je Fall **eine** Prüfung. Wo eine Zeile mehr versprach als Rückgabewert und Schlüssel, blieb der Rest ungemessen, und der Fall war grün, ohne seine Behauptung zu belegen |
| **Jetzt gilt** | Die Tabelle 6.12.19 trägt die Spalten **Kennung, Fall, Zusicherung, Herkunft**. Jede Zeile trägt **genau eine** messbare Zusicherung: ein Rückgabewert, ein Zählschlüssel, ein Zählerstand, ein Textbestandteil der Meldung, eine leere Standard- oder Fehlerausgabe, das Bestehen oder Nichtbestehen einer Datei an einem benannten Ort. Mehrteilige Erwartungen sind in ihre Einzelzusicherungen zerlegt: "2, mit Nennung des Mittels und des Beschaffungswegs" wird zu drei Zeilen, "0, mit `systemMessage`, die den Schritt nennt" zu drei Zeilen, "Durchlass beim vierten Mal" zu Rückgabewert 0 und Zählerstand 4 |

**Die Kennungen sind dauerhaft.** `Z-001`, `Z-002`, … dreistellig, in
Tabellenreihenfolge vergeben. Sie werden **nie** umnummeriert; neue
Zusicherungen werden **angehängt**; eine zurückgezogene Zusicherung behält ihre
Kennung, wird in der Spalte Zusicherung mit `zurückgezogen` gekennzeichnet und
trägt den Grund. Das ist dieselbe Regel wie für die D-Nummern (6.1.2) und aus
demselben Grund: Eine Kennung, die wandert, taugt weder als Verweis noch als
Nachweis. Die Spalte **Herkunft** trägt den bisherigen Vermerk der Zeile — die
Prüfrunde, den Nachtrag oder den Befund —, damit mit der Zerlegung keine
Beleglage verlorengeht.

**Weshalb überhaupt.** Die Fehlerklasse "ein Selbsttestfall besteht, ohne seine
Behauptung zu belegen" ist **dreimal** aufgetreten: **DT-B4** in Runde 1 (der
Fall zur Übergabedatei behauptete, sie sei in `HEAD`, und hatte sie nicht dort),
**S-01** in Runde 2 (die D19-Lage B bei Rückgabewert 0 wurde unter dem falschen
Schlüssel gezählt, während der Fall grün war), **S3-01** in Runde 3 (die
Blockmeldung nannte nur die gezählte Abweichung, während die Tabellenzeile
"genannt werden alle" verlangt, und der Fall war grün). Dreimal ist dieselbe
Ursache berichtigt worden, dreimal ist sie an anderer Stelle wiedergekehrt. Das
ist kein Fehler des einzelnen Falls, sondern des Schnitts: Eine Zeile, die vier
Dinge verspricht und einen Fall bekommt, misst eines und schweigt über drei.
Nach 3.4 wird an dieser Stelle nicht ein viertes Mal nachgebessert, sondern der
Schnitt geändert.

**Der Selbsttest trägt je Kennung genau eine Prüfung** *(zweiter Teil des
Entscheids a; er bekommt keinen eigenen Buchstaben, weil Zerlegung und Deckung
eine Festlegung sind — eine Tabelle ohne mechanische Deckung wäre wieder nur
eine Absichtserklärung)*

Je Kennung **eine** Prüfung, nicht mehr und nicht weniger. Je Prüfung **eine**
Zeile auf der Ausgabe, in einer der beiden Formen

```
BESTANDEN Z-nnn <Kurztext>
FEHLGESCHLAGEN Z-nnn <Kurztext>
```

Am Ende liest der Selbsttest die Kennungen aus der Tabelle 6.12.19 **dieser
ADR-Datei** — alle Zeilen, die mit `| Z-` beginnen — und vergleicht sie mit den
Kennungen, die seine eigenen Prüfungen ausgegeben haben. Er endet mit einem
**Rückgabewert ungleich 0**, wenn

1. eine Kennung der Tabelle keine Prüfung hat, oder
2. eine Prüfung eine Kennung trägt, die nicht in der Tabelle steht.

Die Deckung wirkt also **in beide Richtungen**. Zurückgezogene Kennungen sind
von der Deckung ausgenommen und werden als solche ausgegeben, damit ihr Wegfall
sichtbar bleibt und nicht als Lücke erscheint.

**Die Kopplung von Test und ADR ist gewollt.** Die Tabelle ist die
Spezifikation, und der Test liest die Spezifikation, statt sie zu wiederholen.
Das ist V13 in seiner strengen Form: Eine Angabe, die nichts steuert, sondern
etwas anderes wiederholt, wird gestrichen — hier wird sie nicht gestrichen,
sondern zur einzigen Quelle gemacht. Wer eine Zusicherung in die Tabelle
schreibt, ohne sie zu prüfen, macht den Selbsttest rot; wer eine Prüfung
schreibt, die in der Tabelle nicht steht, ebenso.

**Was das strukturell schliesst.** Die **stumme Lücke**. Bisher konnte eine
Zusicherung ungemessen bleiben, ohne dass irgendetwas rot wurde — sie stand in
einer Zeile, die einen anderen Teil ihrer selbst maass, und nur ein aufmerksamer
Prüfer fand sie; dreimal hat es einen Prüfer und eine ganze Runde gebraucht.
Nach diesem Entscheid ist "ungemessen" ein Zustand, den die **Maschine** findet:
Die Kennung steht in der Tabelle, keine Prüfung trägt sie, der Selbsttest endet
ungleich 0. Der Befund entsteht damit im Bau und nicht erst im Review.

**Was das nicht schliesst.** Eine **schwache Prüfung**, die ihre Zusicherung nur
scheinbar misst — die etwa den Rückgabewert prüft und ihn `Z-051` nennt, oder
die einen Text sucht, den die Meldung immer trägt. Die Deckung ist mechanisch
und zählt Kennungen; sie kann nicht beurteilen, ob eine Prüfung ihren Gegenstand
wirklich misst. Das bleibt Sache des Static und des Dynamic Software Testers auf
einem anderen Modell als die Umsetzung (3.4), und es bleibt der Grund, weshalb
die Rolle, die das Gate baut, es nicht selbst abnimmt. Der Entscheid verkleinert
die Prüffläche des Menschen, er beseitigt sie nicht: Zu beurteilen ist neu, **ob
eine Prüfung misst, was ihre Zeile sagt** — und nicht mehr, **ob überhaupt
gemessen wird**.

**Erweitert am 2026-09-03 um die Messvorschrift je Zusicherung** *(Buchstabe f
unten, Befunde S4-01 und DT4-02 aus Runde 4)*. Die Zerlegung nach a) macht
sichtbar, **dass** eine Kennung eine Prüfung hat; sie sagt nichts darüber, **ob**
die Prüfung den Wortlaut der Zeile ausschöpft. Genau an dieser Stelle ist
`Z-129` gescheitert. Seit dem 2026-09-03 nennt deshalb jede Zusicherung ihren
Messumfang, und die Prüfung misst genau diesen Umfang; die Einzelheiten stehen
in f).

**b) Zu S3-01: Die Blockmeldung nennt alle Abweichungen**

| | |
|---|---|
| **Vorher galt** | 6.12.9 und die Tabellenzeile aus Runde 1 (B7) verlangen: gezählt wird eine, verschwiegen wird keine. Der Bau nannte nur den **gezählten** Schlüssel; ausgeführt belegt an einem Lauf mit zwei ungedeckten Lagen C, einem `A_FAIL` und D19 `VERLETZT`, genannt wurde allein D7 |
| **Jetzt gilt** | Die Blockmeldung führt **jede** Abweichung des Laufs auf: jede `A_FAIL`-Marke, jede ungedeckte Lage C mit ihrem `FEHLT=`-Wert und den D19-Befund. **Gezählt** wird weiterhin **eine** — die erste in Kettenreihenfolge (G8, 6.12.9), damit der Zähler ein Kriterium zählt und nicht ein Bündel |

Gemessen wird das über `Z-049` bis `Z-053`. Der Grund für die Trennung von
Nennen und Zählen bleibt unverändert: Wer weiterarbeiten soll, muss alles sehen,
was ihn aufhält; wer nach 3.4 abbricht, muss wissen, **welches** Kriterium
dreimal gescheitert ist.

**c) Zu DT3-B1: Das Zielverzeichnis der Wegwerfdatei wird vor dem Anlegen bestimmt**

| | |
|---|---|
| **Vorher galt** | 6.12.24 f prüft den Pfad der Wegwerfdatei **nach** dem Anlegen und verlagert sie, wenn er im Baum liegt. Ausgeführt belegt: Zeigt `TMPDIR` in den geprüften Baum, entsteht die Datei zuerst **dort** und wird erst nach rund 6,9 ms verlagert. Der Wortlaut von f) ist erfüllt, sein Zweck — der Kettengrundsatz aus 6.1.3 — verfehlt |
| **Jetzt gilt** | Das Zielverzeichnis wird **vor** dem Anlegen bestimmt: `TMPDIR` wird physisch aufgelöst; liegt es im geprüften Baum **oder** ist es nicht auflösbar, gilt `/tmp`. Erst dann legt das Gate die Datei mit `mktemp -p <verzeichnis>` an. Die Prüfung **nach** dem Anlegen bleibt als Wache stehen und wird nicht ersetzt |

Ein Entscheid, dessen Wortlaut erfüllt und dessen Zweck verfehlt ist, ist ein
Mangel des Entscheids und nicht des Baus — deshalb wird hier der Entscheid
geändert und nicht der Bau gerügt. Dass die Wache bleibt, ist kein Misstrauen
gegen die Bestimmung, sondern V12 in der eigenen Sache: Ein genannter Massstab,
den niemand prüft, ist keiner; und die Bestimmung selbst kann durch einen Symlink
oder ein späteres Einhängen falsch werden. **6.12.24 f ist damit
fortgeschrieben, nicht umgeschrieben** — der dortige Vermerk verweist an Ort
hierher, und die frühere Fassung bleibt lesbar (6.1.2, 6.11.5). Gemessen wird
über `Z-109` bis `Z-111`.

**d) Zu S3-05: Ein unauflösbares Verzeichnis fällt geschlossen aus**

| | |
|---|---|
| **Vorher galt** | Bleibt das Verzeichnis der Wegwerfdatei physisch unauflösbar, fiel die Wache **offen** aus — das Gate arbeitete weiter, ohne zu wissen, wo es schreibt |
| **Jetzt gilt** | Ist das Verzeichnis physisch nicht auflösbar, endet das Gate mit **2** und dem Schlüssel `GATE mktemp`. Dieselbe Behandlung wie bei einer nicht anlegbaren Wegwerfdatei, aus demselben Grund: Ohne sie ist die Ausgabe der Kette nicht auffangbar und es gibt kein belegtes Grün (6.12.4) |

Gemessen wird über `Z-114` und `Z-115`.

**e) Zu S3-02 und S3-07: Zwei ungemessene Zusicherungen erhalten Zeilen**

Beide Befunde sind keine neuen Festlegungen, sondern Zusicherungen, die längst
gelten und bisher keine Prüfung hatten — genau die Lücke, die Entscheid a)
schliessen soll:

- **S3-02**: Die Prüfung der Markenzahl gegen die Selbstaussage der Kette
  (6.12.24 k) gilt für die Formen 1, 2 und 4; geprüft war nur Form 1. Neu je
  eine Zusicherung für Form 2 (`Z-137`, `Z-138`) und Form 4 (`Z-139`, `Z-140`)
  sowie eine für die Gegenprobe, dass **Form 3 nicht auf die Zahl geprüft wird**
  (`Z-141`).
- **S3-07**: Der Entscheid 6.12.24 d sagt, die Forderung nach der Übergabedatei
  werde nach dem vierten Durchlass **nicht ein zweites Mal** erhoben; gemessen
  wurde bisher nur das Weiterzählen. Neu als `Z-129`.

**f) Zu S4-01 und DT4-02: Jede Zusicherung nennt ihren Messumfang**

| | |
|---|---|
| **Vorher galt** | Nach a) trägt jede Zeile genau eine messbare Zusicherung und jede Kennung genau eine Prüfung. Womit gemessen wird, sagte die Zeile nicht: "Die Meldung nennt `jq`" nennt keinen Kanal, "der Zählerstand ist 4" keine Zählerdatei, "nach dem vierten Durchlass enthält keine weitere Meldung …" kein Ereignis und keinen Kanal. Die Prüfung durfte sich deshalb eine Teilmenge des Wortlauts aussuchen und war grün |
| **Jetzt gilt** | Jede Zusicherung der Tabelle 6.12.19 nennt ihren **Messumfang** ausdrücklich: den **Kanal** — Rückgabewert, Standardausgabe, Fehlerausgabe, Zählerdatei, eine Datei an einem benannten Ort, ein Beobachter ohne Wartezeit —, das **Ereignis** oder die **Ereignisse**, auf die sie sich bezieht, und, wo es darauf ankommt, die **Anzahl**. Die Prüfung im Selbsttest misst genau diesen Umfang, **nicht weniger**. Eine Zusicherung ohne Kanal- und Ereignisangabe ist **unvollständig** und wird nicht in die Tabelle aufgenommen |

**Weshalb.** Die Zerlegung nach a) schliesst die stumme Lücke "keine Prüfung",
nicht die stumme Lücke "zu enge Prüfung". `Z-129` ist genau daran gescheitert:
Die Zeile sprach von "keiner weiteren Meldung", gemessen wurde die
**Fehlerausgabe des vierten Ereignisses** — ein Kanal und ein Ereignis von
mehreren. Der Fall war grün, und das Verhalten widerlegte den Wortlaut. Vierter
Auftritt derselben Fehlerklasse, und wieder nicht am einzelnen Fall zu heilen,
sondern am Schnitt: Solange eine Zeile ihren Messumfang offenlässt, entscheidet
ihn die Prüfung — also die Seite, die belegen soll.

**Wo die Anzahl entfällt.** Umfasst ein Fall genau ein Ereignis, ist das
Ereignis mit dem Fall benannt und wird in der Spalte Zusicherung nicht
wiederholt; umfasst er mehrere — die Eskalationsreihe `Z-125` bis `Z-129`, die
Zählreihen `Z-146` bis `Z-151` —, nennt die Zusicherung das Ereignis. Das ist
V13 in der eigenen Sache: Eine Angabe, die nichts steuert, weil sie in der
Nachbarspalte schon steht, wird nicht dupliziert.

**Umfang der Nachführung.** Die Tabelle 6.12.19 ist am 2026-09-03 Zeile für
Zeile durchgegangen worden. **75** Zeilen sind rein präzisiert — aus "Die
Meldung nennt X" wird "Die Fehlerausgabe nennt X", aus "der Zählerstand ist n"
wird "Die Zählerdatei trägt nach dem n-ten Ereignis den Stand n", aus "der
Schlüssel ist X" wird "Die Zählerdatei trägt den Schlüssel X", aus "die Attrappe
verzeichnet einen Aufruf" wird "Das Aufrufprotokoll der Attrappe (Datei im
Prüfaufbau) verzeichnet einen Aufruf", aus "die Auswertung ordnet zu" wird der
Kanal, an dem die Zuordnung sichtbar ist. **Der Sinn jeder Zeile bleibt
unverändert, die Kennungen bleiben.** Deshalb tragen die präzisierten Zeilen
auch **keinen** neuen Herkunftsvermerk: Herkunft der Präzisierung ist dieser
Buchstabe, und er gilt für die ganze Tabelle; ein Vermerk in 75 Zeilen wäre
Rauschen ohne Steuerwirkung. Eigene Herkunft tragen allein die beiden Zeilen,
deren **Aussage** sich ändert (`Z-129` nach g, `Z-110` und `Z-111` nach h).

**g) Zu S4-01: `Z-129` wird berichtigt, nicht zurückgezogen**

| | |
|---|---|
| **Vorher galt** | "Nach dem vierten Durchlass enthält keine weitere Meldung die Zeile `Eskalation 3.4:` — die Forderung wird nicht ein zweites Mal erhoben". Gemessen wurde die Fehlerausgabe des vierten Ereignisses. Ausgeführt belegt: Die Durchlassmeldungen des fünften und des sechsten Ereignisses tragen die Zeichenfolge `Eskalation 3.4: <Schlüssel>` wörtlich auf der Standardausgabe — als **Zitat der Übergabezeile**, die den Durchlass begründet |
| **Jetzt gilt** | Der Wortlaut ist auf das Gemeinte zurückgeführt: Bei **jedem** Ereignis nach dem vierten Durchlass — geprüft am fünften Ereignis (`Stop`) und an einem `TaskCompleted` im selben Zustand — enthält **weder** die Standardausgabe **noch** die Fehlerausgabe die **Forderung** nach der Übergabedatei (Zeichenfolge "verlangt die Übergabedatei"). Das wörtliche Zitat der Zeile `Eskalation 3.4: <Schlüssel>` als Begründung des Durchlasses ist ausdrücklich **zulässig** |

Zurückgezogen wird die Zusicherung nicht, weil die Sache richtig und weiterhin
zu prüfen ist: Wer die Übergabedatei geschrieben hat, darf nicht ein zweites Mal
aufgefordert werden, sie zu schreiben — das war der Entscheid 6.12.24 d und
bleibt es. Falsch war allein der **Messgegenstand**: Die Zeile prüfte eine
Zeichenfolge, die auch das Zitat trägt, statt die Forderung selbst. Das ist ein
Mangel des Entscheids, nicht des Baus; deshalb wird der Entscheid berichtigt und
der Bau nicht gerügt — dieselbe Begründung wie in c). Die Herkunft der Zeile
lautet neu "Runde 3, S3-07 (6.12.25 e); Runde 4, S4-01/DT4-02 berichtigt
(6.12.25 g)", damit beide Runden am Nachweis sichtbar bleiben.

**h) Zu S4-02 und DT4-01: `Z-110` zurückgezogen, `Z-111` präzisiert**

| | |
|---|---|
| **Vorher galt** | `Z-110` sagte "D19 meldet `OHNE_BEFUND`", wenn `TMPDIR` in den geprüften Baum zeigt. `Z-111` sagte, ein Beobachter finde "zu keinem Zeitpunkt eine Datei des Gates im Baum" |
| **Jetzt gilt** | `Z-110` ist **zurückgezogen**: Im Attrappenaufbau stammt die D19-Zeile aus der Ausgabe, die der Selbsttest selbst schreibt; die Prüfung misst dann die eigene Vorgabe und nicht das Verhalten des Gates. `Z-111` misst neu den **ganzen** geprüften Baum: Ein Beobachter ohne Wartezeit findet während des **gesamten** Laufs in allen Verzeichnissen ausser `.git` keine Datei mit dem Muster `tmp.*` |

Die Kennung `Z-110` bleibt mit dem Wort "zurückgezogen", dem Grund und ihrer
Herkunft in der Tabelle stehen und ist von der Deckung ausgenommen (a). Sie wird
nicht gelöscht, weil eine gelöschte Zeile als Lücke erschiene und die Frage
"wurde das je gemessen?" beim nächsten Leser erneut aufwürfe. Die Sache, um die
es `Z-110` ging — das Gate schreibt nicht in den Baum, den es beurteilt (6.1.3)
—, ist mit `Z-109`, `Z-111` und `Z-132` gedeckt, und zwar an Kanälen, die der
Selbsttest nicht selbst gesetzt hat. `Z-111` beobachtete bisher nur das
Verzeichnis, auf das `TMPDIR` zeigt; das ist enger als "im Baum" und liesse eine
Datei an jeder anderen Stelle des Baums durch.

**i) Zu S4-04: Jeder Block mit Schlüssel `GATE <Prüfmittel>` wird gezählt**

| | |
|---|---|
| **Vorher galt** | 6.12.9 führt `GATE <Prüfmittel>` als Zählschlüssel, 6.12.23 c benennt `GATE jq` als die **eine** terminierte Ausnahme. Im Bau enden die Blöcke mit `GATE mktemp` und weitere `GATE`-Blöcke mit unmittelbarem `exit 2` und laufen nicht über die Zählung — eine zweite, nicht entschiedene Ausnahme |
| **Jetzt gilt** | **Jeder** Block mit einem Schlüssel `GATE <Prüfmittel>` läuft über die Zählung nach 6.12.9, auch `GATE mktemp` und die übrigen bisher unmittelbar endenden Blöcke. Die **einzige** Ausnahme bleibt `GATE jq` (6.12.23 c) |

Der Grund für die Ausnahme bei `jq` ist eine Unmöglichkeit, kein Ermessen: Ohne
`jq` ist `session_id` nicht lesbar, und das Gate weiss nicht, wofür es den Block
anschreiben soll. Bei `mktemp`, `sha256sum`, `flock`, `make`, `timeout` und
`git` liegt die Eingabe gelesen vor; dort ist der unmittelbare Ausstieg
Bequemlichkeit und kostet genau das, wofür der Zähler da ist — dreimal dasselbe
fehlende Prüfmittel läuft sonst nie in die Eskalation nach 3.4, und die Rolle
probiert weiter an einem Problem, das sich von innen nicht lösen lässt.
Gemessen wird über `Z-146` bis `Z-151`, je Prüfmittel drei Zusicherungen:
Schlüssel auf der Fehlerausgabe, Zählerstand `|1` nach dem ersten und `|2` nach
dem zweiten Ereignis. Der Rückgabewert 2 dieser Blöcke ist bereits über `Z-112`,
`Z-114`, `Z-116` und `Z-119` gedeckt und wird nicht ein zweites Mal zugesichert
(V13). Geprüft werden zwei Prüfmittel stellvertretend — `mktemp` als der von
S4-04 benannte Fall und `sha256sum` als zweiter, unabhängig gebauter Zweig;
gälte die Regel nur für den beanstandeten Block, wäre sie keine Regel.

**j) Zu S4-03: Der Selbsttest ist gegen Nebenläufigkeit gesperrt**

| | |
|---|---|
| **Vorher galt** | Die Fälle `Z-104` bis `Z-108` verschieben das feste Ausweichverzeichnis `/tmp/r3cosint-dod-gate` beiseite und wieder zurück. Zwei gleichzeitig laufende Selbsttests stören sich dabei; ausgeführt belegt mit 144 von 145 bestandenen Fällen im gestörten Lauf — ein **Scheinbefund**, der weder auf einen Fehler des Gates noch auf einen des Selbsttests zeigt |
| **Jetzt gilt** | Der Selbsttest hält für seine **gesamte** Laufzeit eine Sperre (`flock`) auf einer festen Datei unter `/tmp` (`/tmp/r3cosint-dod-gate-selbsttest.lock`). Er nimmt sie **ohne Wartezeit**; erhält er sie nicht, schreibt er die Zeile `Selbsttest laeuft bereits` auf die Fehlerausgabe und endet mit **Rückgabewert 3**, statt anzulaufen und Scheinbefunde zu erzeugen |

Ein Prüfmittel, dessen Ergebnis davon abhängt, ob gerade ein zweites Exemplar
seiner selbst läuft, ist als Nachweis untauglich — dieselbe Überlegung wie beim
Determinismus in 6.12.19. Der Rückgabewert 3 ist bewusst weder 0 noch 2: Der
Lauf hat **nicht** stattgefunden, und ein nicht stattgefundener Lauf darf weder
als bestanden noch als durchgefallen erscheinen. Die feste Datei liegt unter
`/tmp` und nicht im Arbeitsbaum, weil auch der Selbsttest den Baum nicht
beschreibt, den die Kette beurteilt (6.1.3); sie trägt einen anderen Namen als
das Ausweichverzeichnis des Gates, damit die Fälle `Z-104` bis `Z-108` sie nicht
mitverschieben. Gemessen wird über `Z-152` und `Z-153`.

**k) Beleglage: der Stand nach der vierten Prüfrunde**

Die vierte Prüfrunde ist am 2026-09-03 durch den Static und den Dynamic Software
Tester auf einem anderen Modell als die Umsetzung gelaufen (3.4). Ihr Ergebnis
ist **Fremdbeleg** und von dieser Rolle nicht nachgeprüft:

- **Ohne Beanstandung:** Deckung 145 zu 145 in beide Richtungen, beide
  Manipulationsproben erkannt, die Behebungen b) bis d) im Code und mit Läufen
  belegt, Rückgabewerte des Gates nur 0 und 2, Ausgabedisziplin gewahrt,
  Arbeitsbaum unverändert; **dynamisch alle acht Prüfpunkte bestanden**.
- **Statisch nicht bestanden.** Blockierend ist **S4-01** — `Z-129` besteht,
  ohne seine Behauptung zu belegen. Das ist der **vierte** Auftritt derselben
  Fehlerklasse, und er sitzt an einer Zeile, die in genau der Arbeitseinheit neu
  geschrieben wurde, die die Fehlerklasse beseitigen sollte. Nicht blockierend:
  S4-02, S4-03, S4-04, DT4-01, DT4-02.
- **Antwort dieses ADR:** die Entscheide f) bis j). f) greift die Ursache an
  (der Messumfang stand nicht in der Zeile), g), h), i) und j) die fünf
  benannten Einzelbefunde.

Der Stand **nach** dieser Nachführung ist damit nicht belegt. Eine **fünfte**
Prüfrunde folgt; sie belegt ihn, nicht dieser ADR. Bis dahin gilt die
Arbeitseinheit als nicht abgeschlossen, und nichts hier ist eine Abnahme.

**Fünfte Prüfrunde vom 2026-09-03 (Fremdbeleg)**

Die fünfte Prüfrunde ist am 2026-09-03 durch den Static und den Dynamic Software
Tester auf einem anderen Modell als die Umsetzung gelaufen (3.4). Ihr Ergebnis
ist **Fremdbeleg** und von dieser Rolle nicht nachgeprüft:

- **Statisch nicht bestanden.** Blockierend ist **S5-01**: 16 Zusicherungen
  messen einen **anderen Kanal** als den, den ihre Zeile nennt — `Z-054`,
  `Z-080`, `Z-083`, `Z-086`, `Z-089`, `Z-092`, `Z-093`, `Z-104`, `Z-124`,
  `Z-130`, `Z-134`, `Z-136`, `Z-138`, `Z-140`, `Z-141`, `Z-143`. Beispiele:
  "Zählerdatei" gemessen auf der Fehlerausgabe; "Baumzeile" gemessen als leere
  Fehlerausgabe; "Fehlerausgabe" gemessen auf der Standardausgabe oder in der
  Kettenausgabe; "Beobachter während des Laufs" gemessen nach dem Lauf. Nicht
  blockierend: **S5-02** — der Ausweichname der Zählerdatei bei fehlendem
  `sha256sum` (bereinigte Rohform der `session_id`, `.claude/hooks/dod-gate.sh`)
  ist in diesem ADR nicht terminiert; **S5-03** — `Z-018` misst die
  **Abwesenheit** der Zählerdatei statt einen gleichgebliebenen Stand.
- **Dynamisch nicht bestanden.** Blockierend ist **DT5-01**: `Z-111` besteht
  **ohne Beobachtungsfenster**, weil die Attrappenkette ihre Wegwerfdatei sofort
  löscht. Eine Mutation genau **einer** Zeile des Gates — Wegfall der
  TMPDIR-Zuweisung vor `make` — wird von `Z-111` nur in 1 von 3 Durchgängen
  erkannt, von `Z-109` und `Z-131` in 3 von 3.
- **Ohne Beanstandung: alle acht dynamischen Prüfpunkte.** Selbsttest 152 von
  152 unabhängig reproduziert; Sperre Rückgabewert 3 nach 9 ms; Eskalation sechs
  Ereignisse; Beobachter über den ganzen Baum 0 Treffer bei 38 458 Runden mit
  belegter Empfindlichkeit; `GATE mktemp` und `GATE sha256sum` je unter `|1` und
  `|2` gezählt; alle vier Abweichungen genannt; echter Baum Form 2 und Gate 0;
  Ausgabeform 11 Läufe ohne Fehler.

**Fünfter Auftritt derselben Fehlerklasse.** Beide Prüfer benennen S5-01 und
DT5-01 als **fünften** Auftritt von "ein Selbsttestfall besteht, ohne seine
Behauptung zu belegen". Der Koordinator hat die Arbeitseinheit nach 3.4
abgebrochen; der Stand steht in
`docs/uebergaben/2026-09-03_r3-q-001-o-24-zusicherungen.md`.

**Vorschlag beider Prüfer — als Vorschlag gekennzeichnet und hier nicht
entschieden.** Beide schlagen dasselbe vor: den **Messumfang maschinell
erzwingen** — (1) eine Tabellenspalte "Kanal" mit festem Wertevorrat, die der
Selbsttest liest und gegen die je Kennung tatsächlich benutzte Messart abgleicht;
(2) je Zusicherung eine **Mutationsprobe** — welche Änderung am Gate lässt sie
fehlschlagen —, die der Selbsttest in einem Mutationsmodus ausführt. Der Punkt
ist als **O-25** in Abschnitt 8 geführt und liegt beim Auftraggeber; dieser ADR
entscheidet ihn nicht.

**Wer was tut.** Diese Rolle legt die Zerlegung und die Regel fest und schreibt
sie in diesen ADR. Den Selbsttest und das Gate ändert der **DevOps Engineer**;
die Verifikation liegt beim **Static und beim Dynamic Software Tester** auf
einem anderen Modell als die Umsetzung (3.4). Diese Rolle hat nichts ausgeführt
und prüft ihre eigene Arbeit nicht.

**Was dieser Entscheid nicht ändert.** Kein Entscheid G1 bis G17 und kein
Entscheid a) bis k) aus 6.12.23 und 6.12.24 wird zurückgenommen; keine
Zusicherung der bisherigen Tabelle entfällt, sie werden ausschliesslich zerlegt
und mit Kennungen versehen. *(Nachtrag vom 2026-09-03: Mit h) entfällt erstmals
eine Zusicherung — `Z-110`, weil sie im Prüfaufbau nicht messbar ist. Sie
entfällt nicht als Sache, sondern als Prüfung; ihre Kennung bleibt mit Grund
stehen, und ihr Gegenstand ist über `Z-109`, `Z-111` und `Z-132` gedeckt.)* Die
Kernarchitektur aus 5.1, die Entscheide A1 bis
A13, der Modulschnitt aus Abschnitt 4 und die Verankerung der
Verfahrensgarantien in 4.2 und 4.3 bleiben unberührt; das Gate steht an keiner
Stelle zwischen Freigabe und Ausführung (5.2). Keine D-Nummer wird vergeben.
Nichts hier bereitet Gestrichenes vor (5.17, 5.18, 9.1, 5.10, 5.1). Und nichts
hier ist eine Freigabe oder eine Abnahme: Der Entscheid des Auftraggebers vom
2026-09-03 betrifft **O-24**; die förmliche Freigabe der Entscheidpunkte E-A bis
E-K und die Abnahme des Gates stehen unverändert aus (Abschnitt 10). Den Stand
nach der Umsetzung belegt erst eine weitere Prüfrunde, nicht dieser ADR — nach
den Nachträgen f) bis k) vom 2026-09-03 die **fünfte**.

#### 6.12.26 O-25 — Kanal und Mutationsprobe je Zusicherung (Entscheid des Auftraggebers vom 2026-09-03)

Der Auftraggeber hat **O-25** am 2026-09-03 entschieden. Die Weisung im
Wortlaut: "O-25 entscheiden: beides umsetzen, dann sechste Runde." **Beides**
sind die beiden Mittel, die beide Prüfer übereinstimmend vorgeschlagen haben
(6.12.25 k): (1) die Kanalspalte mit festem Wertevorrat, maschinell
abgeglichen, und (2) die Mutationsprobe je Zusicherung. Sie werden hier
festgelegt; die Umsetzung und die sechste Prüfrunde bleiben offen.

**a) Die Kanalspalte — der Messumfang wird maschinell abgeglichen**

| | |
|---|---|
| **Vorher galt** | Nach 6.12.25 f nennt jede Zusicherung ihren Messumfang, und die Prüfung misst genau diesen Umfang. Das stand als **Text** in der Tabellenzeile. Ob die Prüfung den genannten Kanal auch benutzt, prüfte nichts — ausgeführt belegt an **16** Zusicherungen, die einen anderen Kanal massen als den, den ihre Zeile nennt (S5-01), und die dennoch grün waren |
| **Jetzt gilt** | Die Tabelle 6.12.19 trägt die Spalten **Kennung, Fall, Kanal, Zusicherung, Mutation, Herkunft**. **Kanal** ist ein Wert aus einem festen, abschliessenden Vorrat (unten). Jede Messhülle des Selbsttests trägt genau einen dieser Werte und **meldet ihn mit**; die Deckungsprüfung vergleicht je Kennung den Kanal der Tabelle mit dem gemeldeten Kanal und endet bei Abweichung mit einem **Rückgabewert ungleich 0** — zusätzlich zur bisherigen Deckung in beide Richtungen nach 6.12.25 a |

**Der Vorrat, abschliessend.** Ein anderer Wert ist unzulässig; ein neuer Kanal
entsteht nur durch eine Fortschreibung dieses Abschnitts.

| Wert | Was gemessen wird |
|---|---|
| `rc` | Rückgabewert des Gates |
| `stdout` | Standardausgabe des Gates (JSON) |
| `stderr` | Fehlerausgabe des Gates |
| `zaehler` | Inhalt der Zählerdatei |
| `datei` | Bestehen oder Nichtbestehen einer Datei an einem benannten Ort |
| `beobachter` | Nebenläufiger Beobachter ohne Wartezeit **während** des Laufs |
| `kette` | Erste Zeile oder eine benannte Zeile der **direkt aufgerufenen** Kettenausgabe — `make` wird vom Selbsttest selbst mit demselben `cwd` aufgerufen |
| `selbsttest` | Rückgabewert oder Ausgabe eines zweiten Selbsttestaufrufs *(erweitert am 2026-09-06 durch 6.12.27 e: **oder** eine statische Lesung, die der Selbsttest **ohne** Aufruf des Gates an versionierten Dateien vornimmt — so misst `Z-181` die innere Zeitgrenze gegen `.claude/settings.json`)* |
| `dauer` | Gemessene Zeit |

**Zwei Klarstellungen, damit der Vorrat trägt.** Erstens: Nennt eine Zusicherung
ausdrücklich den **Inhalt** einer Datei an einem benannten Ort — das
Aufrufprotokoll der Attrappe, der Prüfsummenvergleich der Rollendateien —, ist
das der Kanal `datei`; "Bestehen oder Nichtbestehen" schliesst den Befund an
diesem Ort ein und meint nicht allein die Existenz. Zweitens: Nennt eine
Zusicherung ausdrücklich **zwei** Kanäle, trägt sie **zwei** Messhüllen — je
eine je Kanal —, und die Spalte führt beide Werte mit `+` verbunden; die
Deckungsprüfung vergleicht dann die **Menge** der gemeldeten Kanäle mit der
Menge der Tabelle. *(Berichtigt am 2026-09-06 durch 6.12.27 h, Befund S8-06:
Verglichen wird die **Reihenfolge**, nicht die Menge. Bei einer mehrteiligen
Zeile gehört seit 6.12.27 b das i-te Prädikat zum i-ten Kanal; eine Prüfung als
Menge könnte diese Zuordnung nicht prüfen. Der Bau vergleicht bereits als
Zeichenkette und damit der Reihenfolge nach — zu ändern war der Wortlaut, nicht
der Bau.)* Das betrifft genau zwei Zeilen: `Z-129` (`stdout+stderr`,
weil der Wortlaut "weder … noch" beide Ausgabekanäle umfasst) und `Z-152`
(`selbsttest+dauer`, Rückgabewert **und** Zeitgrenze). Der Satz "jede Messhülle
trägt genau einen Wert" bleibt davon unberührt — er gilt der Messhülle, nicht
der Zeile.

**Weshalb das trägt und was es nicht leistet.** Der Abgleich schliesst die
Lücke "die Prüfung sucht sich ihren Kanal selbst aus". Er sagt nichts darüber,
ob die Prüfung auf dem richtigen Kanal auch das Richtige sucht — dafür steht
b). Beide zusammen sind der Ersatz für das, was bisher nur eine Prüfrunde
gefunden hat.

**b) Die Mutationsprobe — jede Zusicherung erkennt ihre eigene Verneinung**

| | |
|---|---|
| **Vorher galt** | Die Deckung nach 6.12.25 a zählt Kennungen, der Abgleich nach a) vergleicht Kanäle. Ob eine Prüfung **trennscharf** ist — ob sie rot würde, wenn das Gate sich anders verhielte —, prüfte nichts. Ausgeführt belegt an `Z-111`: Die Zusicherung bestand, obwohl der Prüfaufbau gar kein Beobachtungsfenster herstellte, und erkannte eine Mutation genau einer Zeile des Gates nur in 1 von 3 Durchgängen (DT5-01) |
| **Jetzt gilt** | Jede nicht zurückgezogene Zusicherung nennt in der Spalte **Mutation** in Worten die Änderung am Prüfgegenstand, die **genau diese** Zusicherung fehlschlagen lassen muss. Die ausführbare Form steht in der versionierten Datei `scripts/dod-gate-mutationen.txt`. Der Selbsttest hat einen **Mutationsmodus** (Aufruf mit `--mutationen`) |

**Aufbau der Datei.** Je Zeile, durch Tabulator getrennt: **Kennung**, **Ziel**
(`dod-gate.sh` \| `Makefile` \| `dod-gate-terminierte-lagen.txt` \|
`selbsttest`), **Mutation** als `sed`-Ausdruck für eine **Kopie** des Ziels
oder das Wort `keine`, **Grund**. Zeilen, die mit `#` beginnen, sind
Kommentar. Der Prüfgegenstand selbst wird nie verändert — mutiert wird
ausschliesslich eine Kopie im Prüfaufbau.

**Was der Mutationsmodus tut, in dieser Reihenfolge.**

1. Er prüft, dass **jede** nicht zurückgezogene Kennung der Tabelle genau
   **einen** Eintrag hat und **jeder** Eintrag eine Kennung der Tabelle trägt —
   dieselbe Deckung in beide Richtungen wie in 6.12.25 a, angewandt auf die
   Mutationen.
2. Er wendet jede Mutation auf eine Kopie des Ziels an und verlangt, dass die
   Kopie sich vom Original **unterscheidet**. Ein `sed`-Ausdruck, der nichts
   trifft, ist damit selbst ein Befund und keine stille Nulloperation.
3. Er lässt den Fall der Kennung gegen die **mutierte Kopie** laufen und
   verlangt, dass genau diese Kennung `FEHLGESCHLAGEN` meldet. Andere
   Zusicherungen dürfen mitfallen — eine Mutation, die mehr trifft als eine
   Zeile, ist zulässig; eine, die die eigene Zeile **nicht** trifft, ist es
   nicht.

**Wann `keine` zulässig ist — geschlossene Liste.** Eine Zusicherung darf
`keine` tragen ausschliesslich mit einem dieser drei Gründe, und die Zeile
nennt den Grund:

1. Die Zusicherung beschreibt den **Selbsttest selbst** (die Sperre, `Z-152`
   und `Z-153`). Eine Mutation daran mutierte das Messinstrument, nicht den
   Gegenstand.
2. Die Zusicherung ist eine **Vorbedingung des Aufbaus** — etwa die
   Empfindlichkeit eines Beobachters oder die Feststellung, dass der Fall die
   Übergabedatei wirklich in `HEAD` hat. Sie behauptet nichts über das
   Verhalten des Gates, sondern stellt fest, dass der Fall den Fall herstellt.
3. Die Zusicherung ist ein **Rückgabewert 0 eines Durchlasses**, dessen
   Verneinung bereits durch die Mutation einer **Schwesterzusicherung desselben
   Falls** gedeckt ist — dann nennt die Zeile die Schwesterkennung. Dieser
   Grund ist in der heutigen Fassung von keiner Zeile in Anspruch genommen; er
   bleibt zulässig, weil er beim Wachsen der Tabelle sonst durch eine
   Scheinmutation ersetzt würde.

Alles andere braucht eine Mutation. **Grundsatz: Eine Prüfung ist erst dann
Beleg, wenn sie ihre eigene Verneinung erkennt.** Das ist V12 auf das
Prüfmittel selbst angewandt — ein genannter Massstab, den niemand prüft, ist
keiner; eine Prüfung, die nie rot werden kann, ist keine.

**c) Die vier Befunde der Runde 5 als Entscheide**

| Befund | Entscheid |
|---|---|
| **S5-01** (blockierend) | Die **16** beanstandeten Zusicherungen messen neu auf dem Kanal, den ihre Zeile nennt. `Z-124`, `Z-134`, `Z-136`, `Z-138`, `Z-140`, `Z-141`, `Z-143` lesen die **Zählerdatei** (der Wrapper `pruefe_zaehler_schluessel` besteht bereits) statt die Zeile `Schluessel: …` auf der Fehlerausgabe; `Z-083`, `Z-086`, `Z-089`, `Z-092`, `Z-093` lesen die **Baumzeile der Kettenausgabe** (Kanal `kette`) statt Rückgabewert 0 mit leerer Fehlerausgabe; `Z-054`, `Z-080`, `Z-130` lesen die **Fehlerausgabe** des Gates statt der Standardausgabe beziehungsweise der direkten Kettenausgabe; `Z-104` misst mit einem **Beobachter während des Laufs** statt mit `[ -f ]` danach. **Der Wortlaut der 16 Zeilen bleibt unverändert** — falsch war die Messung, nicht die Zusicherung; deshalb tragen sie keinen neuen Herkunftsvermerk (dieselbe Regel wie in 6.12.25 f) |
| **DT5-01** (blockierend) | `Z-111` stellt ein **Beobachtungsfenster** her: Die Attrappenkette hält ihre Wegwerfdatei **mindestens 300 ms**, statt sie im selben Befehl wieder zu löschen. Die Zusicherung selbst bleibt; ergänzt ist der Fall um die Bedingung des Aufbaus. Die zugehörige Mutation ist die in Runde 5 benannte: **die Zeile mit der `TMPDIR`-Zuweisung vor `make` entfernt** — dieselbe Mutation, die `Z-109` und `Z-131` in 3 von 3 Durchgängen erkennen |
| **S5-02** (nicht blockierend) | Der **Ausweichname der Zählerdatei bei fehlendem `sha256sum`** ist hiermit terminiert: die **bereinigte Rohform** der `session_id` — nur die Zeichen `A-Za-z0-9_-`, jedes andere Zeichen wird zu `_` —, bei vorhandener `agent_id` ergänzt um dieselbe Bildung über sie. Er gilt **ausschliesslich** für den Fall, dass genau `GATE sha256sum` gemeldet wird; im Regelfall bleibt es bei der gehashten Form. Nachgeführt an Ort in 6.12.9 und 6.12.11 |
| **S5-03** (nicht blockierend) | `Z-018` misst neu den **Stand** statt der Abwesenheit: Der Fall legt vor dem Aufruf eine Zählerdatei mit einem Schlüssel und dem Stand **2** an; nach dem Aufruf trägt sie unverändert denselben Schlüssel und den Stand 2. "Unverändert" ist damit an einem Wert gemessen und nicht am Fehlen einer Datei |

**d) Beleglage der fünften Prüfrunde — Fremdbeleg, nicht von dieser Rolle geprüft**

Beide Prüfer, Static und Dynamic Software Tester, auf einem anderen Modell als
die Umsetzung (3.4), am 2026-09-03:

- **Ohne Beanstandung:** Selbsttest **152 von 152** Zusicherungen (`Z-001` bis
  `Z-153`, `Z-110` zurückgezogen), mechanische Deckung 152/152/0/0; **alle
  acht** dynamischen Prüfpunkte.
- **Nicht bestanden**, blockierend: **S5-01** — 16 Zusicherungen messen einen
  anderen Kanal als den, den ihre Zeile nennt; **DT5-01** — `Z-111` besteht
  ohne Beobachtungsfenster und erkennt die Mutation einer einzigen Zeile des
  Gates nur in 1 von 3 Durchgängen. Nicht blockierend: **S5-02** und
  **S5-03**.
- **Fünfter Auftritt derselben Fehlerklasse** "ein Selbsttestfall besteht, ohne
  seine Behauptung zu belegen". Der Koordinator hat die Arbeitseinheit nach
  3.4 abgebrochen; der Stand steht in
  `docs/uebergaben/2026-09-03_r3-q-001-o-24-zusicherungen.md`.

**Umfang dieser Fortschreibung.** Die Tabelle 6.12.19 ist Zeile für Zeile um
Kanal und Mutation ergänzt: **153** Zeilen, davon `Z-110` zurückgezogen und
ohne beide Werte. Verteilung der **154** Messhüllen auf **152** Zusicherungen
(`Z-129` und `Z-152` tragen zwei): `rc` 61, `stderr` 34, `zaehler` 22,
`stdout` 12, `datei` 12, `beobachter` 5, `kette` 5, `selbsttest` 2, `dauer` 1.
**Sechs** Zeilen tragen `keine`: `Z-152` und `Z-153` nach Grund 1,
`Z-043`, `Z-045`, `Z-048` und `Z-068` nach Grund 2. `scripts/dod-gate-mutationen.txt`
führt dazu **152** Einträge — je nicht zurückgezogener Kennung genau einen,
`Z-110` ohne Eintrag —, davon **146** mit `sed`-Ausdruck (140 gegen
`.claude/hooks/dod-gate.sh`, 6 gegen das `Makefile`) und die sechs mit `keine`.

**Wer was tut.** Diese Rolle legt Kanalvorrat, Mutationsregel und die Einträge
der Tabelle fest und schreibt sie in diesen ADR und in
`scripts/dod-gate-mutationen.txt`. Den Selbsttest und das Gate ändert der
**DevOps Engineer**; die Verifikation liegt beim **Static und beim Dynamic
Software Tester** auf einem anderen Modell als die Umsetzung (3.4). **Diese
Rolle hat nichts ausgeführt** — weder das Gate noch den Selbsttest noch eine
Mutation — und prüft ihre eigene Arbeit nicht.

**Was dieser Entscheid nicht ändert.** Kein Entscheid G1 bis G17, keiner aus
6.12.23, 6.12.24 und 6.12.25 wird zurückgenommen; keine Zusicherung entfällt,
keine Kennung wandert. Die Kernarchitektur aus 5.1, die Entscheide A1 bis A13,
der Modulschnitt aus Abschnitt 4 und die Verankerung der Verfahrensgarantien
bleiben unberührt; das Gate steht an keiner Stelle zwischen Freigabe und
Ausführung (5.2). Keine D-Nummer wird vergeben. Nichts hier bereitet
Gestrichenes vor (5.17, 5.18, 9.1, 5.10, 5.1). Und nichts hier ist eine
Freigabe oder eine Abnahme: Der Entscheid des Auftraggebers vom 2026-09-03
betrifft **O-25**; die förmliche Freigabe der Entscheidpunkte E-A bis E-K und
die Abnahme des Gates stehen unverändert aus (Abschnitt 10). Den Stand nach der
Umsetzung belegt erst die **sechste** Prüfrunde, nicht dieser ADR.

**e) Sechste Prüfrunde und der Bau in drei Phasen — Fremdbeleg, nicht von dieser Rolle geprüft**

Die sechste Prüfrunde lief am 2026-09-03 gegen einen **unfertigen Bau**: Der
DevOps Engineer hatte nach sechs Instanzen keinen Abschluss gemeldet. Sie ist
**statisch nicht bestanden** (12 Befunde, `S6-01` bis `S6-12`) und **dynamisch
nicht bestanden** (6 Befunde, `DT6-01` bis `DT6-06`). Im Einzelnen:

- Die Umstellung der Messungen aus **S5-01** war für **9** Kennungen nicht
  ausgeführt (fünfmal Kanal `kette`, dazu `Z-054`, `Z-080`, `Z-130`, `Z-141`).
- **DT5-01** (`Z-111`) und **S5-03** (`Z-018`) waren nicht behoben.
- Der Mutationsmodus zerlegte das Skript mechanisch in Zeilenbereiche und brach
  für **13** Kennungen mit `unbound variable` ab.
- **31** Mutationen wurden nicht erkannt, **3** waren wirkungslos.
- Der Kanalparser las bei **vier** Zeilen mit maskiertem Rohrzeichen das falsche
  Feld.
- Die Sperre des Selbsttests wurde an Beobachterprozesse vererbt.

Der Koordinator hat den Bau daraufhin in **drei kontrollierten Phasen** zu Ende
führen lassen — (1) Fallfunktionen mit Register, (2) Messungen, (3) Mutationen
—, je mit Zwischenkontrolle durch den **Static Software Tester**. Ergebnis,
ebenfalls Fremdbeleg:

| Phase | Stand | Belegt |
|---|---|---|
| **1 Fallfunktionen** | erledigt | Alle Fallfunktionen stehen in fester Reihenfolge in einem Register; `mutationsmodus_ausfuehren` lässt je Kennung **nur die registrierte Funktion** isoliert laufen — `env -i` mit `timeout 30` gegen eine mutierte Kopie in einem eigenen `mktemp -d`-Arbeitsverzeichnis. Die Prüfungen des Modus bleiben: Deckung Mutationsdatei/Tabelle beidseitig, Kopie muss sich vom Original unterscheiden (sonst "wirkungslos"), genau die Kennung meldet `MUTATION ERKANNT`/`MUTATION NICHT ERKANNT`, Schlusszeile mit allen fünf Zählern und Dauer, Rückgabewert 0 nur bei `nicht_erkannt=0` **und** `wirkungslos=0`. Kein Fall bricht mehr mit `unbound variable` ab; ein nicht lauffähiger Fall würde als `FALL NICHT LAUFFAEHIG Z-nnn` gezählt (im Lauf: 0). Der Sperrdeskriptor wird vor dem Kindprozess in einer Subshell geschlossen (`exec {SELBSTTEST_SPERRE_FD}>&-`), weil `env` und `timeout` ihn sonst erben; Sperrtest: Abbruch nach 5 s (Rückgabewert 124), danach `flock -n` erfolgreich. `bash -n` fehlerfrei; Normalmodus Rückgabewert 0, **152 von 152**, Deckung 152/152/0/0. Mutationsmodus Rückgabewert 2 — erwartet — mit "146 geprueft, 125 erkannt, 18 nicht erkannt, 6 ohne Mutation (keine), 3 wirkungslos, Dauer 153s", 0 Treffer `unbound variable` |
| **2 Messungen** | erledigt | `Z-083`, `Z-086`, `Z-089`, `Z-092`, `Z-093` über die neue Messhülle `pruefe_kette_zeile`; `Z-054` über `pruefe_stderr_enthaelt`; `Z-080` und `Z-130` als `kette`-Messung **mit Bericht statt verbogener Messung**; `Z-141` über `pruefe_zaehler_schluessel`; `Z-018` über eine vorbelegte Zählerdatei; `Z-111` mit 300 ms Haltezeit in der Attrappenkette; Parserfix für maskierte Rohrzeichen (`\|` über einen Platzhalter). **DT6-05** ist ein Codefix im Gate: Der Block `GATE sha256sum` läuft neu als **allererster** Block in `.claude/hooks/dod-gate.sh`. Gegenbeweis zu `Z-111` neu geführt: isolierter Lauf gegen eine Kopie des Gates ohne die Zeile `TMPDIR="$ausgabe_verz_phys"` — **3 von 3** Durchgängen `FEHLGESCHLAGEN`. Normalmodus Rückgabewert 0, 152 von 152; der Kanalabgleich meldet **genau zwei** Abweichungen, `Z-080` und `Z-130` |
| **3 Mutationen** | **unvollständig** | Negativbefund der Zwischenkontrolle: Der Arbeitsbaum ist vor und nach beiden Läufen zeichengleich — weder Selbsttest noch Gate schreiben in den Baum. Beanstandet sind zwei Mutationen: `Z-124` (der `sed`-Ausdruck ist nicht trennscharf, 10 Treffer einschliesslich einer Kommentarzeile) und `Z-133` (der Ausdruck trifft die gemeinte Stelle, die Messung isoliert die zerstörte Eigenschaft aber nicht, weil der zweite Disjunkt den geforderten Rückgabewert 2 weiterträgt). Beide erklären zugleich, weshalb diese Mutationen unerkannt bleiben. Die Zahlen **18 nicht erkannt** und **3 wirkungslos** sind damit nicht abgetragen |

**Was daraus entschieden ist.**

1. **`Z-080` und `Z-130` messen den Kanal `kette`.** Die Tabelle 6.12.19 ist
   entsprechend fortgeschrieben. Grund in der Sache: Bei `Z-080` nennt die
   Fehlerausgabe des Gates den Beschaffungsweg nicht — sie führt die Lage C mit,
   der Beschaffungsweg `git fetch --unshallow` steht in der Kettenausgabe; bei
   `Z-130` blockiert das Gate im Fall des Prüfaufbaus mit `GATE git`, bevor die
   Kette läuft, sodass die Marke von D12 allein auf der direkt aufgerufenen
   Kettenausgabe zu lesen ist. Der Kanal ist damit nicht "der bequemere", sondern
   der einzige, auf dem die Zusicherung überhaupt Gegenstand hat.
2. **Berichtigung zu c).** Der Entscheid zu **S5-01** hält fest, der Wortlaut der
   16 Zeilen bleibe unverändert, weil dort die Messung falsch war und nicht die
   Zusicherung. Für `Z-080` und `Z-130` trifft das nicht zu: Beide Zeilen nannten
   mit "Die Fehlerausgabe nennt …" den falschen Gegenstand. Ihr Wortlaut ist
   deshalb auf die Kettenausgabe präzisiert und ihr Herkunftsvermerk um diesen
   Abschnitt ergänzt. Für die übrigen 14 Zeilen bleibt c) unverändert gültig.
3. **Verteilung der Messhüllen.** Der Absatz "Umfang dieser Fortschreibung" liest
   sich damit neu: `stderr` **32** statt 34, `kette` **7** statt 5; alle übrigen
   Werte unverändert. Zahl der Zeilen, der Zusicherungen, der Messhüllen und der
   Einträge in `scripts/dod-gate-mutationen.txt` ändern sich nicht.
4. **Die Ausnahmeliste im Selbsttest entfällt.** Der Bau hat die beiden
   Abweichungen vorläufig über eine benannte Liste (`kanal_ausnahmen_bekannt`)
   geduldet, damit der Normalmodus überhaupt einen Rückgabewert 0 erreichen kann.
   Mit dieser Fortschreibung stimmen Tabelle und Messung überein; die Liste ist
   **ersatzlos zu entfernen**, sonst dulden zwei Zeilen eine Abweichung, die es
   nicht mehr gibt — und der Abgleich nach a) verlöre für sie seine Wirkung.
   Auszuführen durch den DevOps Engineer, nicht durch diese Rolle.
5. **`keine` mit Grund 3: nichts nachzuziehen.** Der Bestand von
   `scripts/dod-gate-mutationen.txt` führt **sechs** Zeilen mit `keine` — `Z-152`
   und `Z-153` nach Grund 1, `Z-043`, `Z-045`, `Z-048` und `Z-068` nach Grund 2.
   **Keine** Zeile nimmt Grund 3 in Anspruch. Damit deckt sich der Bestand mit
   b), und die dort festgehaltene Aussage bleibt zutreffend.
6. **DT6-05 wie belegt festgehalten:** `GATE sha256sum` als erster Block des
   Gates. Das ist die Reihenfolge, die der DevOps Engineer gemessen hat; ein
   Ausweichname der Zählerdatei nach c)/S5-02 kann nur greifen, wenn die
   Feststellung des fehlenden Prüfmittels **vor** jeder Zählung steht.

**Was offen bleibt.** Phase 3 ist nicht abgeschlossen: `Z-124` und `Z-133`
brauchen trennscharfe Mutationen, und die 18 nicht erkannten sowie 3
wirkungslosen Mutationen sind abzutragen. Erst danach ist eine **siebte**
Prüfrunde sinnvoll; sie belegt den Stand, nicht dieser ADR. **O-25 ist
weiterhin nicht förmlich abgenommen**, ebenso wenig die Entscheidpunkte E-A bis
E-K (Abschnitt 10) — dieser Entscheid liegt beim Product Owner und beim
Auftraggeber. **Diese Rolle hat nichts ausgeführt** — weder Gate noch Selbsttest
noch eine Mutation —, hat nichts committet und prüft ihre eigene Arbeit nicht
(3.4). Alle Zahlen und Läufe dieses Abschnitts sind Fremdbeleg aus den Berichten
des DevOps Engineers und des Static Software Testers.

**f) Nachträge aus der siebten Prüfrunde — Beleglage Fremdbeleg, Entscheide dieser Rolle**

Die siebte Prüfrunde lief am 2026-09-03, Static und Dynamic Software Tester auf
einem anderen Modell als die Umsetzung (3.4). **Alle Zahlen und Läufe dieses
Abschnitts sind Fremdbeleg aus ihren Berichten**; diese Rolle hat nichts
ausgeführt — weder Gate noch Selbsttest noch eine Mutation — und prüft ihre
eigene Arbeit nicht.

**Beleglage, Fremdbeleg.**

- **Normalmodus:** Rückgabewert 2 aus **zwei** Ursachen. `Z-089` wird **doppelt**
  gemeldet, weshalb die Schlusszeile 153 statt 152 nennt; und `Z-130` misst den
  Kanal `stderr`, während die Tabelle seit e) `kette` trägt. Der Kanalabgleich
  ist sonst ohne Abweichung, die Deckung 152/152/0/0.
- **Mutationsmodus:** Rückgabewert 2 — 146 geprüft, 141 erkannt, **5 nicht
  erkannt** (`Z-114`, `Z-124`, `Z-132`, `Z-133`, `Z-139`), 6 ohne Mutation, **0
  wirkungslos**.
- **Befunde:** `S7-01`/`DT7-01` (Kanal `Z-130`), `S7-02`/`DT7-02` (die fünf nicht
  erkannten Mutationen), `S7-03` (die Ausnahmeliste `kanal_ausnahmen_bekannt`
  besteht mit `Z-080` weiter, obwohl e) Punkt 4 ihre Entfernung anordnet),
  `S7-04`/`DT7-04` (`Z-089` doppelt), `S7-05` (`pruefe_wahr` nimmt den Kanal als
  freies Argument, 33 Aufrufstellen), `S7-06` (feste Sperrdatei unter `/tmp`),
  **`DT7-03` (blockierend, eigene Mutation des Prüfers)** und `DT7-05` (Hinweis,
  der Beobachter von `Z-111` sucht nur `tmp.*`).

`DT7-03` wiegt am schwersten und ist neu: Wird im Gate der gesuchte Text der
Übergabedatei von `Eskalation 3.4: $primaer_schluessel` auf `Eskalation 3.4:`
verkürzt (Zeile 273, ausgewertet 294 und 308), fällt **keine** der 152
Zusicherungen. Die Bindung des Durchlasses an **den gezählten** Schlüssel ist
damit heute nicht zugesichert — ein Loch in der Eskalationsregel 3.4 selbst,
nicht bloss im Prüfmittel.

**Die Entscheide.**

1. **`Z-139` trägt neu `keine` mit Grund 3.** Die Verneinung — Form 4 von der
   Markenzahl-Prüfung ausgenommen — ist im selben Fall durch die Schwester
   `Z-140` gedeckt, deren Mutation der Schlüssel ist: Fiele die Prüfung weg,
   trüge die Zählerdatei `KETTE ausgabe-unlesbar` nicht mehr. Der Kanal `rc`
   dieser Zeile kann sie nicht trennen, weil der Rückgabewert 2 im Prüfaufbau
   auch aus `D19 VERLETZT` folgt. Die Spalte Mutation ist entsprechend gesetzt;
   `scripts/dod-gate-mutationen.txt` folgt der Tabelle.
2. **Grund 3 ist damit weiter gefasst als in b).** b) beschreibt ihn als
   "Rückgabewert 0 eines Durchlasses"; das trifft weder auf `Z-139` noch auf
   `Z-155` zu. Grund 3 lautet neu: *Die Zusicherung teilt den Fall mit einer
   Schwesterzusicherung, und ihr eigener Kanal kann die Verneinung nicht von
   anderen Ursachen desselben Messwerts trennen, während die Schwester sie
   trennscharf misst; die Zeile nennt die Schwesterkennung und den Grund der
   Nichttrennbarkeit.* Die Feststellung in b) und in e) Punkt 5, **keine** Zeile
   nehme Grund 3 in Anspruch, ist mit dieser Fortschreibung überholt: `Z-139`
   und `Z-155` nehmen ihn. Der Grundsatz bleibt unberührt — eine Zeile, die
   `keine` trägt, muss belegen, **wer sonst** die Verneinung sieht; ohne
   benannte Schwester ist `keine` unzulässig.
3. **`Z-133` ist auf den Fall präzisiert, in dem die Bedingung allein trägt.**
   Die Schlusszeile nennt Form 1 mit genau `0 gueltige Marken gezaehlt`, und es
   liegen null Marken vor: gelesene und genannte Zahl stimmen überein, der
   zweite Disjunkt greift nicht, allein die Forderung nach mindestens einer
   Marke trägt den Block. Die Mutation — Entfernen dieses Disjunkts — lässt den
   Lauf dann durch, und `Z-133` fällt. Bisher nannte der Fall eine Zahl grösser
   0 in der Schlusszeile; dort trug der zweite Disjunkt den Rückgabewert 2
   weiter, und die Mutation blieb unsichtbar (`S7-02`).
4. **`Z-114` misst neu, was die Wache leistet, auf `rc+datei`.** Zugesichert ist:
   Bei physisch nicht auflösbarem Verzeichnis der Wegwerfdatei endet das Gate mit
   2 **und** die Kette ist **nicht** gelaufen — belegt daran, dass die Spurdatei,
   die die Attrappenkette bei jedem Lauf an einem benannten Ort ausserhalb des
   geprüften Baums hinterlässt, **fehlt**. Erst damit erkennt die Zeile die
   Mutation "die Wache fällt offen aus" (`if false`): Der Rückgabewert 2 allein
   trennt nicht, weil er im Prüfaufbau ohnehin fällt; die gelaufene Kette trennt.
   Der dritte Teil des Verhaltens — Schlüssel `GATE mktemp` — bleibt bei der
   Schwester `Z-115` (Kanal `zaehler`) und wird **nicht** doppelt geführt; eine
   Kennung misst, was keine andere misst.
   *Berichtigt durch Punkt 13 (Bau 4): Die Prämisse, die Kette liefe unter der
   Verneinung, trifft in der herstellbaren Lage nicht zu; `Z-114` bleibt bei
   `rc`, Mutation `keine` (Grund 3, Schwester `Z-115`).*
5. **`Z-132` misst neu auf `datei`, nicht mit einem Beobachter.** Zugesichert ist:
   Die Kette **erhält** ein `TMPDIR` ausserhalb des geprüften Baums. Gemessen wird
   das an einer Spurdatei ausserhalb des Baums, in die die Attrappenkette das ihr
   wirksam übergebene `TMPDIR` schreibt und die der Fall danach liest. Die
   Abgrenzung zur Schwester `Z-131`: `Z-131` liest das **Aufrufprotokoll** und
   sagt, was das Gate übergeben hat; `Z-132` liest die Spur der Kette und sagt,
   was in der Kette **angekommen** ist. Mutation für beide: die Zeile mit der
   `TMPDIR`-Zuweisung vor `make` entfernt.
6. **`Z-124` bekommt eine verankerte Mutation und einen Fall, an dem "die erste"
   messbar ist.** Der Fall trägt neu **zwei** fehlerhafte Zeilen mit
   **verschiedenen** Schlüsseln (Selbstprüfung 2 und 6); erst dann unterscheidet
   sich "erste in Dateireihenfolge" von "letzte". Die Mutation ist auf die
   **Abbruchanweisung der strukturellen Selbstprüfungen (2, 4, 6)** beschränkt —
   das `break` innerhalb des Blocks, der den Schlüssel der Strukturprüfung setzt.
   Der `sed`-Ausdruck ist über diesen Block zu verankern, durch Bereichsadresse
   oder mitgeführtes Kontextmuster; ein Ausdruck wie `s#break$#continue#`, der 10
   Zeilen des Skripts trifft, ist ein **Befund** und keine Mutation. Der
   Mutationsmodus prüft heute nur, dass die Kopie sich vom Original
   unterscheidet; ergänzend gilt: Die Mutation trifft **genau die Stelle, die die
   Spalte nennt**, und keine Zeile ausserhalb.
7. **Neu `Z-154` und `Z-155` — die Bindung des Durchlasses an den Schlüssel
   (`DT7-03`).** Fall: vierter Stop nach drei Blocks am selben Kriterium mit
   einer Übergabedatei in `HEAD`, deren Eskalationszeile einen **anderen**
   Schlüssel nennt als den gezählten. `Z-154` (Kanal `rc`): Rückgabewert 2 — der
   Durchlass öffnet sich **nicht**; Mutation: der im Gate gesuchte Text auf
   `Eskalation 3.4:` ohne Schlüssel verkürzt. `Z-155` (Kanal `zaehler`): Die
   Zählerdatei trägt nach dem vierten Ereignis den gezählten Schlüssel mit dem
   Stand 4 — der Zähler zählt weiter. `Z-155` trägt **`keine`** nach dem in
   Punkt 2 gefassten Grund 3: Der Stand 4 gilt nach `Z-125` auch beim Durchlass,
   der Kanal `zaehler` kann die verkürzte Suche also nicht von der richtigen
   trennen; die Trennung leistet `Z-154`. Diese Rolle schreibt `Z-155`
   ausdrücklich **nicht** mit einer Mutation, die sie nicht erkennen kann — das
   wäre der sechste Auftritt derselben Fehlerklasse, diesmal im ADR statt im
   Skript.
8. **`Z-130` bleibt beim Kanal `kette`** (e), Entscheid 1, in der Sache
   unverändert: Im Prüfaufbau blockiert das Gate mit `GATE git`, bevor die Kette
   läuft; die Marke von D12 ist allein auf der direkt aufgerufenen Kettenausgabe
   zu lesen. Zu ändern ist die **Messung**, nicht die Zeile (`S7-01`/`DT7-01`).
   Die Ausnahmeliste `kanal_ausnahmen_bekannt` ist **ersatzlos zu entfernen** —
   das ordnet e) Punkt 4 bereits an, und `S7-03` belegt, dass es nicht ausgeführt
   ist. Sie duldet heute eine Abweichung, die es nach der Tabelle nicht mehr
   geben darf, und nimmt dem Abgleich nach a) für diese Zeile die Wirkung.
9. **`Z-089` wird genau einmal gemessen (`S7-04`/`DT7-04`).** Die doppelte
   Messhülle ist zu entfernen. Zusätzlich gilt für den Selbsttest als
   Bauvorschrift: Die Deckungsprüfung zählt **eindeutige** Kennungen, und eine
   Kennung, die mehr als eine Meldung trägt, ist selbst eine Abweichung mit
   Rückgabewert ungleich 0 — sonst kann eine falsche Schlusszahl aus einer
   Doppelmeldung wie eine erfüllte Deckung aussehen.
10. **`pruefe_wahr` und der freie Kanal (`S7-05`) — entschieden.** Die freie
    Kanalangabe ist zulässig **ausschliesslich** für `beobachter`, `dauer`,
    `selbsttest` und `datei`; das sind die Messungen ohne typisierte Standardhülle.
    Für `rc`, `stdout`, `stderr`, `zaehler` und `kette` **müssen** die typisierten
    Hüllen verwendet werden, die den Kanal aus dem Messmittel selbst melden. Der
    Kanalabgleich **verwirft** eine Meldung von `pruefe_wahr`, die einen dieser
    fünf Kanäle nennt, als **Abweichung**. Grund: Die Selbstauskunft eines Falls
    ist keine mechanische Bindung — sie sagt, was der Fall zu messen behauptet,
    nicht, was er misst; genau diese Lücke war `S5-01`. Für die vier übrigen
    Kanäle bleibt die freie Angabe, weil dort das Messmittel je Fall verschieden
    ist; sie sind mit heute 4, 1, 2 und 14 Messhüllen die Minderheit und einzeln
    im Blick.
11. **Die Sperre unter `/tmp` (`S7-06`) — kein Befund.** Die feste Sperrdatei
    `/tmp/r3cosint-dod-gate-selbsttest.lock` bleibt (6.12.25 j). Dass zwei
    Prüfrollen auf derselben Maschine sich **serialisieren**, ist gewollt und
    nicht unerwünscht: Zwei gleichzeitige Selbsttests teilen sich Zählerdateien,
    Wegwerfverzeichnisse und Beobachterfenster und belegen einander gegenseitig
    nicht. Die Meldung `Selbsttest laeuft bereits` mit Rückgabewert 3 ist die
    **vorgesehene** Antwort; Prüfrollen warten und wiederholen den Aufruf. Ein
    parallelisierbarer Selbsttest wäre eine Änderung am Messinstrument ohne
    Gewinn an Aussage.
12. **`DT7-05` (Hinweis) — kein Handlungsbedarf an `Z-111`.** Der Beobachter sucht
    `tmp.*`, und genau dieses Muster erzeugt `mktemp`; Wortlaut und Messung
    stimmen überein. Die weitergehende, musterfreie Beobachtung fällt mit der
    Umstellung von `Z-132` nach Punkt 5 weg; die Frage "schreibt die Kette
    irgendetwas in den Baum" trägt die Rahmenprüfung D19 und der Negativbefund
    der Zwischenkontrolle aus e). Diese Rolle hält das ausdrücklich fest, statt
    es stillschweigend zu verlieren.

13. **Berichtigungen aus Bau 4 — Fremdbeleg, entschieden am 2026-09-04.** Der
    Koordinator hat am 2026-09-04 gegen **Kopien** des Gates und des `Makefile`
    isolierte Läufe einzelner Fälle wie im Mutationsmodus gefahren. **Alle
    Zahlen und Läufe dieses Punktes sind Fremdbeleg**; diese Rolle hat nichts
    davon ausgeführt und prüft ihre eigene Arbeit nicht (3.4). Zwei Stellen
    dieser Fortschreibung tragen eine Prämisse, die in der herstellbaren Lage
    nicht zutrifft; sie werden **an Ort berichtigt** (6.1.2, 6.11.5) — nichts
    wird gelöscht, die berichtigten Stellen tragen einen Vermerk.

    **Bestätigt ohne Änderung** sind die übrigen Proben: `Z-133` und `Z-134`
    schlagen unter ihrer Mutation (entfernter Disjunkt) fehl; die
    Bereichsadresse für `Z-124` —
    `/^declare -A deckung_pfad=()$/,/^done < /` — trifft genau die sieben
    `break`-Zeilen der Strukturprüfung und keine Zeile ausserhalb, und `Z-124`
    schlägt unter der Mutation mit dem erhaltenen Schlüssel `LISTE 6 2` statt
    `LISTE 2 D7 abnahme` fehl; der Prototyp der Fallfunktion zu `Z-154`
    (Ausgangscommit, drei Blocks, committete Übergabedatei mit der Zeile
    "Eskalation 3.4: D5 typen A_FAIL" bei gezähltem Schlüssel
    "D3 linter A_FAIL", vierter Stop) besteht ohne Mutation mit Rückgabewert 2
    und Zählerstand 4 und schlägt unter der Mutation — der gesuchte Text auf
    `Eskalation 3.4:` verkürzt — mit Rückgabewert 0 fehl, während `Z-155` mit
    Stand 4 weiter besteht. Das belegt Punkt 7: `Z-155` trägt `keine` mit
    Grund 3, weil ihr eigener Kanal die Verneinung nicht sieht.

    **a) `Z-114` misst wieder allein den Kanal `rc`; die Spalte Mutation trägt
    `keine` nach Grund 3 mit der Schwester `Z-115`.** Punkt 4 setzt voraus, die
    Kette liefe unter der Verneinung und hinterliesse ihre Spur. Diese Prämisse
    trifft in der herstellbaren Lage nicht zu. Die einzige als `root`
    herstellbare Lage "physisch nicht auflösbar" ist ein **nicht vorhandenes**
    Verzeichnis: Die Attrappe von `mktemp` gibt
    `/dod-gate-selbsttest-s3-05-nicht-vorhanden-<pid>/tmp.attrappe` aus,
    fehlende Durchquerungsrechte umgeht `root`, und ein Pfad tiefer als
    `PATH_MAX` wird von `getcwd` der glibc dennoch aufgelöst (geprüft mit 4934
    Zeichen; `pwd -P` mit Rückgabewert 0). Unter der Mutation `if false` läuft
    das Gate zwar weiter, aber die Umleitung der Kettenausgabe
    `>"$ausgabe_datei"` in das nicht vorhandene Verzeichnis scheitert: `make`
    startet **nie**, `kette_rc=1`, und das Gate blockiert mit dem Schlüssel
    `KETTE rueckgabewert=1` und Rückgabewert 2. Der isolierte Lauf von
    `fall_z114_115` gegen die mutierte Kopie meldet für `Z-114` (Kanal `rc`)
    `BESTANDEN` mit Rückgabewert 2 und für `Z-115` (Kanal `zaehler`)
    `FEHLGESCHLAGEN` — erwartet `GATE mktemp`, erhalten
    `KETTE rueckgabewert=1`. Folge: Die Spurdatei der Attrappenkette **fehlt in
    beiden Fällen**, beim richtigen Code wie unter der Mutation. Der Kanal
    `datei` ist in dieser Lage **unfalsifizierbar** und darf nach dem Grundsatz
    aus b) — "eine Prüfung ist erst dann Beleg, wenn sie ihre eigene Verneinung
    erkennt" — nicht als Messumfang geführt werden. Die Verneinung sieht allein
    die Schwester `Z-115` über den Schlüssel; das ist genau die in Punkt 2
    gefasste Lage des Grundes 3. `Z-114` bleibt daher beim Kanal `rc` mit der
    Zusicherung "Rückgabewert 2 — die Wache fällt geschlossen aus" und trägt in
    der Spalte Mutation `keine`. Die Aufzählung in Punkt 2 erweitert sich damit
    auf **drei** Zeilen mit Grund 3: `Z-114`, `Z-139` und `Z-155`.

    **b) Die Mutation von `Z-130` wird auf das `Makefile` verlegt.** Kanal
    (`kette`) und Zusicherung der Zeile bleiben unverändert; Punkt 8 und
    Entscheid 1 aus e) bleiben in der Sache stehen. Widersprüchlich war allein
    die Spalte Mutation: Sie nannte eine Änderung **am Gate** — der
    `FEHLT=`-Wert aus der falschen Gruppe des Markenmusters (`BASH_REMATCH`) —,
    während die Zeile auf der **direkt aufgerufenen** Kettenausgabe misst. Ein
    direkter Kettenaufruf durchläuft die Markenauswertung des Gates nie; diese
    Mutation ist auf dem Kanal `kette` grundsätzlich unerkennbar. Genau das ist
    in Runde 6 und Runde 7 beobachtet worden, weshalb der Bau auf `stderr`
    auswich (`S7-01`) — die Zeile hat den Bau in einen unauflösbaren
    Widerspruch geführt. Die Probe der `kette`-Messung (Fremdbeleg): das echte
    `Makefile` als `Makefile.echt` in einen Scheinbaum kopiert, in dem
    `scripts/nachweise-erzeugen.sh` und `scripts/nachweise-vollstaendig.sh`
    fehlen; `make -s -C <baum> -f Makefile.echt nachweise` liefert die Marke
    `::LAGE ohne-lauf-kennung D12 nachweise C FEHLT=scripts/nachweise-erzeugen.sh::`,
    also den **ersten** Gegenstand. Entfällt im `Makefile` die Wache
    `[ -n "$fehlt" ] ||` vor dem zweiten Gegenstand, nennt die Marke
    `FEHLT=scripts/nachweise-vollstaendig.sh` — den **letzten** statt den
    ersten Gegenstand, und die Zusicherung fällt. Damit erkennt `Z-130` ihre
    eigene Verneinung auf ihrem eigenen Kanal. Die **gate-seitige** Lesart der
    `FEHLT=`-Gruppe verliert dadurch nichts: Sie bleibt durch `Z-054` gedeckt
    (Kanal `stderr`, Mutation "der `FEHLT=`-Wert wird aus der ganzen Marke
    gelesen").

    **c) Umfang nach Bau 4.** Die Tabelle 6.12.19 führt unverändert `Z-001` bis
    `Z-155` — 155 Zeilen, davon `Z-110` zurückgezogen, also **154**
    Zusicherungen. Weil `Z-114` ihre `datei`-Hülle verliert, sind mehrkanalig
    wieder **zwei** Zeilen: `Z-129` (`stdout+stderr`) und `Z-152`
    (`selbsttest+dauer`). Verteilung der **156** Messhüllen: `rc` 62,
    `stderr` 32, `zaehler` 23, `datei` 13, `stdout` 12, `kette` 7,
    `beobachter` 4, `selbsttest` 2, `dauer` 1.
    `scripts/dod-gate-mutationen.txt` führt **154** Einträge — je nicht
    zurückgezogener Kennung genau einen —, davon **145** mit `sed`-Ausdruck und
    **neun** mit `keine`: `Z-152` und `Z-153` (Grund 1), `Z-043`, `Z-045`,
    `Z-048` und `Z-068` (Grund 2) sowie `Z-114`, `Z-139` und `Z-155`
    (Grund 3). Gegenüber der Fassung vor Bau 4 wechselt allein `Z-114` von
    `sed` zu `keine`; der Eintrag für `Z-130` bleibt ein `sed`-Eintrag, nennt
    als Gegenstand aber das `Makefile` und nicht das Gate. Trägt das Format der
    Mutationsdatei den Gegenstand heute nicht, ist das beim Bau als **Befund**
    zu melden statt stillschweigend anzugleichen. Die Zahlen dieses Punktes
    sind vom DevOps Engineer beim Bau zu bestätigen und bei Abweichung als
    Befund zu melden.

**Umfang nach dieser Fortschreibung.** Die Tabelle 6.12.19 führt `Z-001` bis
`Z-155` — **155** Zeilen, davon `Z-110` zurückgezogen, also **154**
Zusicherungen. Mehrkanalig sind neu **drei** Zeilen: `Z-129` (`stdout+stderr`),
`Z-152` (`selbsttest+dauer`) und `Z-114` (`rc+datei`); die Aufzählung "genau zwei
Zeilen" in a) ist damit fortgeschrieben. Verteilung der **157** Messhüllen:
`rc` 62, `stderr` 32, `zaehler` 23, `datei` 14, `stdout` 12, `kette` 7,
`beobachter` 4, `selbsttest` 2, `dauer` 1. `scripts/dod-gate-mutationen.txt`
führt **154** Einträge — je nicht zurückgezogener Kennung genau einen —, davon
**146** mit `sed`-Ausdruck und **acht** mit `keine`: `Z-152` und `Z-153`
(Grund 1), `Z-043`, `Z-045`, `Z-048` und `Z-068` (Grund 2), `Z-139` und `Z-155`
(Grund 3). Gegenüber e) kommt `Z-154` als `sed`-Eintrag hinzu, `Z-155` als
`keine`, und `Z-139` wechselt von `sed` zu `keine`. Die Zahlen sind vom DevOps Engineer beim Bau zu
bestätigen und, falls sie abweichen, als Befund zu melden statt anzugleichen.
*Berichtigt durch Punkt 13: 156 Messhüllen, `datei` 13, zwei mehrkanalige
Zeilen, neun Zeilen mit `keine`.*

**Wer was tut.** Diese Rolle legt die Tabelleneinträge und die Regeln fest und
schreibt sie in diesen ADR. Selbsttest, Mutationsdatei und Gate ändert der
**DevOps Engineer**; die Verifikation liegt beim **Static und beim Dynamic
Software Tester** auf einem anderen Modell als die Umsetzung (3.4). Der
Koordinator hat entschieden: **Bau 4 mit Zwischenkontrolle, danach die achte
Prüfrunde**; tritt die Fehlerklasse "eine Zusicherung besteht, ohne ihre
Behauptung zu belegen" dort erneut auf, wird nach 3.4 abgebrochen, der Stand in
die Übergabedatei geschrieben und die Sache vorgelegt.

**Was dieser Nachtrag nicht ändert.** Kein Entscheid G1 bis G17, keiner aus
6.12.23 bis 6.12.26 a bis e wird zurückgenommen; die Kernarchitektur aus 5.1, die
Entscheide A1 bis A13, der Modulschnitt aus Abschnitt 4 und die Verankerung der
Verfahrensgarantien bleiben unberührt, und das Gate steht an keiner Stelle
zwischen Freigabe und Ausführung (5.2). Keine D-Nummer wird vergeben. Nichts hier
bereitet Gestrichenes vor (5.17, 5.18, 9.1, 5.10, 5.1). **Und nichts hier ist
eine Freigabe oder eine Abnahme:** O-25, die Entscheidpunkte E-A bis E-K und die
Abnahme des Gates stehen unverändert aus (Abschnitt 10). Den Stand nach Bau 4
belegt erst die **achte** Prüfrunde, nicht dieser ADR.

**g) Achte Prüfrunde — Beleglage (Fremdbeleg), Abbruch nach 3.4 und Vorlage O-26**

Die achte Prüfrunde ist am 2026-09-04 gelaufen: Static und Dynamic Software
Tester, beide auf einem anderen Modell als die Umsetzung (3.4), je in einer
Wegwerfkopie, der geprüfte Bestand prüfsummengleich. **Alle Zahlen, Läufe und
Befunde dieses Abschnitts sind Fremdbeleg**; diese Rolle hat nichts davon
ausgeführt, nichts nachgemessen und prüft ihre eigene Arbeit nicht (3.4). Was
hier steht, ist das Protokoll der gemeldeten Lage und der Entscheid des
Koordinators dazu — keine Bestätigung, keine Freigabe und keine Abnahme.

**1. Statische Prüfung: bestanden; die Fehlerklasse ist nicht aufgetreten.**
Ausgeführt sind beide Modi des Selbsttests. Normalmodus: Rückgabewert 0, **154
von 154** Prüfungen bestanden, Deckung 154 Kennungen in der Tabelle / 154
Prüfungen / 0 ohne Prüfung / 0 ohne Tabellenzeile, Kanalabgleich **0
Abweichungen**, keine doppelt gemeldete Kennung. Mutationsmodus: Rückgabewert 0,
**145 geprüft, 145 erkannt, 0 nicht erkannt, 9 ohne Mutation, 0 wirkungslos**,
Laufzeit 152 s. Von Hand hat der Prüfer **51 Zeilen** Wort für Wort gegen ihre
Messung gelesen, **alle 145 `sed`-Ausdrücke** einzeln angewandt (105 ändern genau
eine Zeile, 2 fügen eine ein, 38 ändern mehrere — nach 6.12.26 b zulässig, weil
die Trennschärfe an der fehlschlagenden Kennung hängt und nicht an der Zahl der
berührten Zeilen), alle drei Bereichs- und `/g`-Ausdrücke nachgemessen und alle
**19** `pruefe_wahr`-Aufrufe auf ein nach Punkt 9 der fünfzehnten Fortschreibung
zulässiges Kanalliteral geprüft. Kanalverteilung und Mutationszahlen stimmen mit
Punkt 13 überein (156 Messhüllen; 154 Einträge, davon 145 mit `sed` und 9 mit
`keine`). Damit ist die in 6.12.26 f, Punkt 13 c) verlangte Bestätigung der
Zahlen erbracht.

Sieben **nachrangige** Befunde, keiner blockierend:

- **S8-01** — die Rückzugserkennung (Muster "zurückgezogen") liest die ganze
  Tabellenzeile statt einer Spalte; heute nicht ausgelöst, weil keine andere
  Spalte das Wort trägt. Latente Fehlerquelle, kein Befund am Ergebnis.
- **S8-02** — Abschnitt 9 führe die Berichtigung vom 2026-09-04 nicht. **Am
  aktuellen Stand nicht reproduzierbar**: Die Zeile "Fünfzehnte Fortschreibung"
  trägt den Vermerk "Berichtigt am 2026-09-04 durch 6.12.26 f Punkt 13"; der
  Koordinator hat das geprüft. Der Befund wird als gegenstandslos verzeichnet und
  nicht abgetragen.
- **S8-03** — der Block `GATE sha256sum` steht im Gate zweimal: die neu
  vorgezogene Fassung in den Zeilen 363 bis 367 und die alte, unerreichbare
  Fassung in den Zeilen 478 bis 482; der Diff war rein additiv. Verhaltensneutral;
  die alte Fassung ist zu entfernen.
- **S8-04** — `scripts/dod-gate-mutationen.txt` steht noch nicht unter
  Versionskontrolle; die Datei wird mit dem Commit dieser Einheit hinzugefügt.
- **S8-05** — `Z-080` misst `git fetch --unshallow` über die ganze Fehlerausgabe
  des direkten D20-Aufrufs statt isoliert in der Marke. Gedeckt, weil der
  Messgegenstand nur D20 enthält, aber nicht gesondert isoliert.
- **S8-06** — der Kanalabgleich vergleicht Zeichenketten (und damit bei
  `stdout+stderr` auch die Reihenfolge), während der ADR von Mengen spricht. Der
  Abgleich ist damit **strenger** als verlangt und fällt geschlossen aus.
- **S8-07** — fünf Nicht-ASCII-Stellen in den Skripten, zwei davon funktional
  (das Muster "zurückgezogen").

**2. Dynamische Prüfung: nicht bestanden; die Fehlerklasse ist erneut
aufgetreten.** Ausgeführt sind beide Modi mit denselben Zahlen wie oben. Der
Beobachter über den kopierten Baum meldet **2651 Runden, 0 Treffer**, und **254
Dateien** vorher und nachher prüfsummengleich. Das Gate gegen die Kopie als
echten Baum: `Stop` Rückgabewert 0 in 10,28 s, `TaskCompleted` Rückgabewert 0 in
9,68 s, `SubagentStop` mit `agent_type` `static-software-tester` Rückgabewert 0
in 0,14 s **ohne Kettenlauf** (Attrappenprotokoll 0 Bytes), ohne
`CLAUDE_PROJECT_DIR` Rückgabewert 2 und damit geschlossen ausfallend. Die
Eskalationsfolge über neun Ereignisse: Zähler 1 bis 9 lückenlos, die Forderung
der Übergabedatei genau beim **dritten**, der Block mit "erwartet eine Datei" ab
dem **vierten**, eine Übergabedatei mit fremdem Schlüssel blockt (siebtes
Ereignis), mit richtigem Schlüssel Durchlass mit Rückgabewert 0 (achtes), und
`TaskCompleted` danach blockt wieder (neuntes). Zwei nebenläufige Gate-Aufrufe
werden sauber serialisiert (4,11 s und 8,16 s), Zählerstand 2, kein falsches
Grün. Über **alle 28** Gate-Läufe traten ausschliesslich die Rückgabewerte 0 und
2 auf; die Standardausgabe war bei Rückgabewert 2 leer und bei Rückgabewert 0
genau ein Objekt mit dem einzigen Feld `systemMessage`.

Dazu **sechzehn eigene Mutationen** des Prüfers am Gate, **keine davon in
`scripts/dod-gate-mutationen.txt`**, jede gegen den ganzen Normalmodus gefahren.

**Negativbefund — was gehalten hat.** Zehn dieser Fremdmutationen sind vom
Selbsttest erkannt worden, und zwar mit der jeweils zuständigen Kennung: `M-02`
(Eskalationsschwelle 3 auf 2) über `Z-040`; `M-03` (HEAD-Zweig entfernt) über
`Z-044` und `Z-128`; `M-04` (status-Zweig entfernt) über `Z-041`; `M-05`
(`TaskCompleted` durchlassen) über `Z-047`; `M-06` (D19-Auswertung aus) über acht
Kennungen; `M-08` (`stop_hook_active` ignoriert) über `Z-017` und `Z-018`; `M-09`
(Rollenprüfung invertiert) über sieben Kennungen; `M-10` (Schlüssel ohne Lage)
über `Z-040`, `Z-141` und `Z-155`; `M-12` (`exit 1` statt `exit 2`) über 42
Kennungen; `M-13` (jq-Feld umbenannt) über `Z-006` und `Z-102`. `M-11` (`TMPDIR`
fest auf `/tmp`) verletzt keine Zusicherung der Tabelle und ist ausdrücklich
**kein Befund**. Der Prüfbericht spricht an dieser Stelle von **elf** erkannten
Mutationen, seine Aufzählung nennt **zehn**; da die übrigen sechs der sechzehn
benannt sind (fünf nicht erkannt, `M-11` ohne verletzte Zusicherung), geht die
Rechnung nur mit zehn auf. Die Abweichung um eins ist eine Zähldifferenz im
Bericht, vom Prüfer zu klären; sie wird hier **festgehalten und nicht
angeglichen** (6.1.2).

Die **drei blockierenden** Befunde:

- **DT8-01 (blockierend, achter Auftritt der Fehlerklasse).** Mutation `M-01` —
  die Eskalationsschwelle von `-ge 4` auf `-ge 3` — lässt **keine** Kennung
  fallen. `Z-040` sagt im Wortlaut, die Fehlerausgabe des dritten Ereignisses
  enthalte die Zeile "Eskalation 3.4: <Schlüssel>" **wörtlich**; gemessen wird
  eine Teilzeichenkette (`grep -qF`), und die bleibt unter der Mutation im Satz
  "erwartet eine Datei ... mit der wörtlichen Zeile 'Eskalation 3.4: ...'"
  erhalten, während die Zeile **als Zeile** verschwindet. Zudem sichert keine
  Zeile der Tabelle zu, dass der Durchlass **frühestens beim vierten** Ereignis
  greift: Unter der Mutation lässt das Gate mit vorhandener Übergabedatei schon
  beim dritten Ereignis durch (Rückgabewert 0), und der Selbsttest meldet
  weiterhin 154 von 154. Die Ausprägung ist dieselbe wie bei `DT7-03`:
  Teilzeichenkette statt Zeile.
- **DT8-02 (blockierend).** Der Zählschlüssel `KETTE schlusszeile-widerspruch`
  aus 6.12.4 in Verbindung mit 6.12.23 a ("Rückgabewert 0 nur mit Form 1") ist
  von **keiner** Zusicherung gedeckt — die Suche im Selbsttest, in der
  Mutationsdatei und in der Tabelle 6.12.19 findet ihn je **null** mal. Mutation
  `M-07` (Form 4 bei Rückgabewert 0 von der Prüfung ausgenommen) lässt keine
  Kennung fallen; das Gate blockt dann unter dem **falschen** Schlüssel `KETTE
  ausgabe-unlesbar`. Ursache ist eine Lücke im Deckungsprüfer: Er gleicht
  Tabelle gegen Selbsttest ab, nicht die Klassifizierungstabelle 6.12.4 gegen die
  Tabelle 6.12.19.
- **DT8-03 (blockierend).** Die Trennschärfe der Markengrammatik aus 6.12.7 — das
  **schliessende** `::` — ist von keiner Zusicherung gedeckt. Mutation `M-14`
  (schliessendes `::` optional) lässt keine Kennung fallen; ein direkter
  Gate-Lauf mit einer Marke ohne schliessendes `::` endet im Original mit
  Rückgabewert 2 und `KETTE ausgabe-unlesbar`, unter der Mutation dagegen mit
  Rückgabewert 0 und sauberem Grün.

Drei weitere, **nachrangige** Befunde:

- **DT8-04** — die **physische Auflösung** des Baums auf dem Rückfallpfad über
  `CLAUDE_PROJECT_DIR` (B-02/B-03) ist ungedeckt. `M-16` (Baum roh aus dem
  Projektfeld) lässt keine Kennung fallen, macht das Gate aber **strenger**:
  falsch rot mit `GATE Makefile`, wenn das Arbeitsverzeichnis ausserhalb liegt
  und `CLAUDE_PROJECT_DIR` auf ein Unterverzeichnis zeigt.
- **DT8-05** — der **Wert** der inneren Zeitgrenze von 600 s ist ungemessen;
  `M-15` (600 auf 6000) bleibt unerkannt, weil `Z-037` nur den Zweig **nach**
  Überschreitung misst. Vorschlag des Prüfers: Kanal `selbsttest`, statische
  Lesung der Bedingung "innen kleiner als aussen" gegen `.claude/settings.json`.
- **DT8-06** — die Ausgabeform (genau ein Objekt mit dem einzigen Feld
  `systemMessage`) ist nur für **zwei der fünf** Durchlasspfade gemessen
  (`Z-006`, `Z-102`); `M-13` lässt genau diese beiden fallen.

**3. Die Analyse des Prüfers zum Muster aller acht Runden** ist im Prüfbericht
ausdrücklich **als Vorschlag** gekennzeichnet und wird hier ebenso wiedergegeben:
Ursache sei nicht die einzelne Zeile, sondern die **Messhülle**. Der Wortlaut
einer Zusicherung ("die Zeile ... wörtlich", "genau ein Objekt", "ausserhalb des
Baums") und das Prädikat, mit dem gemessen wird (`grep -qF`, Teilzeichenkette,
Zählvergleich), würden von keinem Mechanismus gegeneinander gehalten. Die
Deckungsprüfung gleiche Kennung gegen Kennung und seit O-25 Kanal gegen Kanal ab,
aber nicht **Aussage gegen Prädikat**. Und die Mutationsprobe prüfe nur die
Mutationen, die die Tabelle selbst nennt — die **Vollständigkeit der Tabelle
gegenüber dem ADR-Text** (Schlüssel aus 6.12.4, Grammatik aus 6.12.7, Schwellen
aus 6.12.9) prüfe nichts.

**4. Entscheid des Koordinators: Abbruch nach 3.4.** Die Fehlerklasse "eine
Zusicherung besteht, ohne ihre Behauptung zu belegen" ist in der achten Runde
erneut aufgetreten. Wie in 6.12.26 f ("Wer was tut") und in der Zeile "Fünfzehnte
Fortschreibung ... achte Prüfrunde" in Abschnitt 9 vorab festgelegt, wird die
Arbeitseinheit damit nach Projektauftrag **3.4 abgebrochen**: **Kein Befund der
achten Runde wird in dieser Einheit behoben**, der Stand wird mit Übergabedatei
committet und dem Auftraggeber vorgelegt. Vorgelegt wird **O-26**. Diese Rolle
protokolliert diesen Entscheid; sie bewertet ihn nicht und setzt ihn nicht um.

**5. O-26 — Vorschlag dieser Rolle, nicht entschieden.** Was folgt, ist ein
**Vorschlag** an den Auftraggeber und in Abschnitt 8 als O-26 geführt. Er wird
hier nicht entschieden, und nichts davon ist gebaut. Fünf Bausteine:

**(a) Prädikatbindung — die Messart wird geführt wie heute der Kanal.** Die
Spalte Zusicherung trägt je Zeile zusätzlich ein **Prädikat** aus einem
geschlossenen Vorrat; vorgeschlagen sind `zeile-woertlich`, `enthaelt`, `gleich`,
`einzelfeld`, `leer`, `existiert`, `fehlt` und `ausserhalb`. Jede Messhülle
meldet ihr Prädikat mit, so wie sie heute nach 6.12.26 a ihren Kanal meldet, und
der Selbsttest gleicht beides ab; eine Abweichung endet ungleich 0. Die Bindung
ist die eigentliche Regel: Der Wortlaut "die Zeile ... wörtlich" ist **nur** mit
einer Zeilenhülle (`grep -x`) zulässig, "enthält" nur mit `grep -F`, "genau ein
Objekt mit einzigem Feld" nur mit der Einzelfeldhülle. Damit wird `DT8-01`
maschinell sichtbar statt von einer Prüfrunde gefunden — genau die Wirkung, die
6.12.25 a für Kennungen und 6.12.26 a für Kanäle hat.

**(b) Schlüsseldeckung — die Klassifizierungstabelle wird gegen die Prüftabelle
gehalten.** Jeder Zählschlüssel der Klassifizierungstabelle 6.12.4 muss als
**erwarteter Schlüssel** in mindestens einer Zeile der Tabelle 6.12.19 vorkommen;
der Selbsttest prüft das mechanisch und endet ungleich 0, wenn ein Schlüssel ohne
Zeile bleibt. Heute fehlt genau ein Schlüssel: `KETTE schlusszeile-widerspruch`
(`DT8-02`). Der Abgleich läuft in **eine** Richtung; ein Schlüssel in 6.12.19,
den 6.12.4 nicht führt, ist ein eigener Befund und keine erlaubte Erweiterung.

**(c) Grammatikdeckung — je Element der Marke eine verneinende Zeile.** Für jedes
Element der Markengrammatik aus 6.12.7 — Präfix `::LAGE`, die Felder, `FEHLT=`,
`SCHWELLE=`, das **schliessende** `::` und die Rückgabewertklammer — trägt die
Tabelle 6.12.19 mindestens eine Zeile, die den **Verstoss** misst: eine Marke
ohne dieses Element wird abgewiesen. Heute fehlt die Zeile für das schliessende
`::` (`DT8-03`). Auch diese Deckung ist maschinell zu prüfen, sonst verschiebt
sie den Befund nur von der Prüfrunde in die Tabellenpflege.

**(d) Die sechs Befunde als neue oder geänderte Zeilen.** Vorgeschlagen sind, je
mit Kanal, Prädikat und einer Mutation in `scripts/dod-gate-mutationen.txt`:
`Z-040` auf die Zeilenhülle umgestellt (Prädikat `zeile-woertlich`, `grep -x`,
Mutation `M-01`); **neu** eine Zeile "der Durchlass greift frühestens beim
vierten Ereignis" (Kanal `rc`, Rückgabewert 2 beim dritten Ereignis **trotz**
vorhandener und passender Übergabedatei, Mutation `M-01`); **neu** eine Zeile für
`KETTE schlusszeile-widerspruch` (Kanal `stderr`, Form 4 bei Rückgabewert 0,
Mutation `M-07`); **neu** eine Zeile "Marke ohne schliessendes `::` wird
abgewiesen" (Kanal `stderr`, erwarteter Schlüssel `KETTE ausgabe-unlesbar`,
Mutation `M-14`); **neu** eine Zeile "der Rückfallpfad über `CLAUDE_PROJECT_DIR`
löst den Baum physisch auf" (Kanal `rc`, Durchlass bei Arbeitsverzeichnis
ausserhalb und Projektfeld auf einem Unterverzeichnis, Mutation `M-16`); **neu**
eine Zeile "die innere Zeitgrenze ist kleiner als die äussere" (Kanal
`selbsttest`, statische Lesung gegen `.claude/settings.json`, Mutation `M-15`);
und die Ausgabeform **je Durchlasspfad** statt für zwei von fünf (Kanal `stdout`,
Prädikat `einzelfeld`, Mutation `M-13`). Die Zeilen erhalten neue, nie
umnummerierte Kennungen; `Z-040` wird **berichtigt, nicht zurückgezogen** (6.1.2,
6.12.25 g).

**(e) Ein Abnahmekriterium, das die Runde beendet statt sie zu verlängern.**
Vorgeschlagen ist: Der Selbsttest gilt als abgenommen, wenn **erstens** die
tabelleneigenen Mutationen zu **100 Prozent** erkannt werden (`nicht_erkannt=0`,
`wirkungslos=0`) und **zweitens** eine **Fremdmutationsrunde** ohne blockierenden
Befund in den vier Kategorien **Schlüssel** (6.12.4), **Grammatik** (6.12.7),
**Schwellen und Ereignisfolge** (6.12.9) und **Ausgabeform** (6.12.15) durchläuft.
Weitere Fremdmutationen **danach** sind Backlog-Einträge und **kein
Abbruchgrund**. Die Begründung ist der Grund, aus dem acht Runden nicht
konvergiert sind: Die Tabelle kann nie alle denkbaren Mutationen aufzählen, und
das offene Kriterium "keine neue Lücke" macht die Abnahme unendlich — jede Runde
findet eine weitere ungedeckte Stelle, jede Behebung ist richtig, und das Ende
kommt nicht. Vier benannte Kategorien sind abzählbar, ihr Bestehen ist belegbar,
und was danach kommt, ist Verbesserung statt Abnahmehindernis. **Der Entscheid
liegt beim Auftraggeber**; diese Rolle schlägt vor und entscheidet nicht.

**Was dieser Nachtrag nicht ändert.** Kein Entscheid G1 bis G17, keiner aus
6.12.23 bis 6.12.26 a bis f wird zurückgenommen; die Zahlen aus Punkt 13 bleiben
massgeblich, und keine Zeile der Tabelle 6.12.19 wird durch diesen Abschnitt
geändert — O-26 ist ein Vorschlag, keine Anweisung an den Bau. Die Kernarchitektur
aus 5.1, die Entscheide A1 bis A13, der Modulschnitt aus Abschnitt 4 und die
Verankerung der Verfahrensgarantien bleiben unberührt; das Gate steht an keiner
Stelle zwischen Freigabe und Ausführung (5.2). Keine D-Nummer wird vergeben.
Nichts hier bereitet Gestrichenes vor (5.17, 5.18, 9.1, 5.10, 5.1). **Und nichts
hier ist eine Freigabe oder eine Abnahme:** O-25 und das neue O-26, die
Entscheidpunkte E-A bis E-K und die Abnahme des Gates stehen unverändert aus
(Abschnitt 10).


#### 6.12.27 O-26 — Prädikatbindung, Schlüssel- und Grammatikdeckung, Abnahmekriterium (Entscheid des Auftraggebers vom 2026-09-06)

**a) Der Entscheid, sein Wortlaut, die Lesart und was er nicht ist**

Der Auftraggeber hat **O-26** am 2026-09-06 entschieden. Die Belegkette in der
Form, in der sie 6.12.25 und 6.12.26 für O-24 und O-25 führen:

| | |
|---|---|
| **Vorgelegt** | O-26 als Vorschlag mit den fünf Bausteinen (a) bis (e) in 6.12.26 g, Punkt 5, und als Zeile in Abschnitt 8 ("O-26 — vorgelegt am 2026-09-04") |
| **Bericht des Koordinators an den Auftraggeber vom 2026-09-05** (in der Sitzung, nicht im Repository), massgebliche Sätze im Wortlaut | "Der nächste Schritt liegt beim Auftraggeber: 1. O-26 entscheiden (ADR 0002, 6.12.26 g): Prädikatbindung, Schlüssel- und Grammatikdeckung, die sechs Befunde der achten Runde als Zeilen, und das Abnahmekriterium, das die Prüfrunden beendet. 2. gitleaks in die Umgebungsdefinition der Sitzung aufnehmen, sonst blockiert das Gate nach dem Merge jede Beendigung. 3. /usage prüfen und die nächste Einheit freigeben. Empfehlung unverändert: noch nicht mergen. Nach der Weisung zu O-26 folgen eine Einheit Umsetzung mit neunter Runde, dann der Merge beider Pull Requests, dann E4 und E3, dann das Grundgerüst als erster Produktcode." |
| **Antwort des Auftraggebers vom 2026-09-06, Wortlaut vollständig** | "Na dann weiter gehts, so wie du es sagst" |
| **Lesart des Koordinators** | Der Auftraggeber nimmt den Vorschlag an, wie er in 6.12.26 g steht: **alle fünf Bausteine (a) bis (e) werden umgesetzt**, danach läuft die **neunte** Prüfrunde nach dem Abnahmekriterium (e). Das ist ein Entscheid zu O-26 und eine Weisung zum Bau |
| **Was der Entscheid ausdrücklich nicht ist** | **Keine** förmliche Freigabe der Entscheidpunkte E-A bis E-K und **keine** Abnahme des Gates. Abschnitt 10 bleibt unverändert; der Formweg dafür ist der Merge des Pull Requests oder eine wörtliche Anweisung an die nächste Sitzung |
| **Umgebung am 2026-09-06** | `gitleaks` ist in der Sitzungsumgebung vorhanden (`/usr/local/bin/gitleaks`, vom Koordinator mit `command -v` festgestellt). Das ist eine Feststellung des Koordinators, kein Entscheid dieses Abschnitts, und ändert an E-E nichts |

**Wer was tut.** Diese Rolle — der Software Architect — schreibt diesen
Abschnitt, die Elementtabelle in 6.12.7 und die Tabelle 6.12.19; sie baut
nichts, führt nichts aus und prüft ihre eigene Arbeit nicht (3.4). Den
**Selbsttest**, die **Mutationsdatei** und, wo dieser Abschnitt es verlangt,
das **Gate** ändert der **DevOps Engineer**. Nach dem Bau folgt eine
**Zwischenkontrolle durch den Static Software Tester**, danach die **neunte
Runde** durch **Static und Dynamic Software Tester** auf einem anderen Modell
als die Umsetzung (3.4), je in einer Wegwerfkopie. Die **Übergabe** schreibt
der Koordinator; er führt die Einheit als **Aufgabe**, weil sonst
`TaskCompleted` nicht feuert und die harte Zusicherung für nichts gilt (O-23,
Entscheid E-H).

**b) Prädikatbindung — die Messart wird geführt und gebunden wie der Kanal**

| | |
|---|---|
| **Vorher galt** | Die Tabelle nennt seit 6.12.26 a den **Kanal**, und der Selbsttest gleicht ihn ab. Womit auf diesem Kanal gemessen wird, sagte die Zeile nur in Worten: "die Zeile … wörtlich", "genau ein Objekt", "ausserhalb des Baums". Ob die Messhülle diesen Wortlaut trifft, prüfte nichts — ausgeführt belegt an `Z-040`, das eine **Teilzeichenkette** misst, wo die Zeile eine **ganze Zeile** verlangt, und deshalb die Fremdmutation `M-01` nicht erkannt hat (`DT8-01`) |
| **Jetzt gilt** | Die Tabelle 6.12.19 trägt eine **siebte Spalte** `Prädikat` **zwischen Kanal und Zusicherung**: `\| Kennung \| Fall \| Kanal \| Prädikat \| Zusicherung \| Mutation \| Herkunft \|`. Der Vorrat ist geschlossen. Jede Messhülle des Selbsttests **meldet ihr Prädikat mit**, und ein **Prädikatabgleich** vergleicht je Kennung das gemeldete Prädikat mit Spalte 4 der Tabelle; jede Abweichung endet **ungleich 0** — dieselbe Wirkung, die 6.12.26 a für den Kanal hat |

**Weshalb eine eigene Spalte und kein Zusatz in der Spalte Zusicherung.** Weil
der Abgleich maschinell sein muss und die Spalte Zusicherung Fliesstext ist.
Der Selbsttest liest heute **Spalte 3** für den Kanal; er liest künftig
**Spalte 4** für das Prädikat — dieselbe Mechanik, dieselbe Fehlerklasse
geschlossen. Ein Prädikat, das im Fliesstext der Zusicherung stünde, müsste aus
ihm herausgeklaubt werden, und die Regel hinge an der Formulierung statt an
einer Zelle; das ist wörtlich Regel 1 aus 6.2.2.

**Der Vorrat, abschliessend.** Ein anderer Wert ist unzulässig; ein neues
Prädikat entsteht nur durch eine Fortschreibung dieses Abschnitts.

| Wert | Was gemessen wird |
|---|---|
| `zeile-woertlich` | Der Kanal trägt **irgendwo** eine Zeile, die dem erwarteten Text **als ganze Zeile** gleicht (Zeilenhülle, `grep -x`) |
| `enthaelt` | Der Kanal enthält den erwarteten Text als Teilzeichenkette (`grep -F`) |
| `gleich` | Der an einer **bestimmten Stelle** gelesene Wert ist gleich dem erwarteten: ein Rückgabewert, ein Zählschlüssel, ein Zählerstand, der Inhalt einer benannten Zeile, ein verglichener Prüfsummenwert |
| `einzelfeld` | Die Standardausgabe ist **genau ein** JSON-Objekt mit **genau einem** Feld des genannten Namens |
| `leer` | Der Kanal trägt kein einziges Byte |
| `existiert` | Der benannte Gegenstand liegt vor — eine Datei, ein Eintrag, ein Fund |
| `fehlt` | Der benannte Gegenstand liegt **nicht** vor — eine Datei, ein Eintrag, ein Text |
| `ausserhalb` | Der gemessene, physisch aufgelöste Pfad liegt **ausserhalb** des geprüften Baums |
| `kleiner` | Ein Zahlenvergleich: der gemessene Wert ist **kleiner** als der genannte |

**Die eine Ergänzung gegenüber dem Vorschlag in 6.12.26 g, mit Begründung.**
Vorgeschlagen waren acht Werte. Die Durchsicht **jeder** Zeile der Tabelle
zeigt zwei Zusicherungen, die keiner davon trägt: `Z-152` ("endet **innerhalb
von 5 s**") und die neue Zeile zur inneren Zeitgrenze (`Z-181`, "innen kleiner
als aussen", `DT8-05`). Beide messen einen **Zahlenvergleich**, und ein
Zahlenvergleich ist weder `gleich` noch `enthaelt`. Deshalb **ein** neuer Wert,
`kleiner`, und keiner mehr: "grösser" braucht heute keine Zeile, und ein Wert
ohne Zeile wäre ein Vorrat auf Verdacht. Alle übrigen 183 Zusicherungen kommen
mit den acht vorgeschlagenen Werten aus.

**Beobachter-Zeilen.** Für den Kanal `beobachter` gilt: "findet … die Datei"
ist `existiert`, "findet … keine Datei" / "an keinem der beiden Orte" ist
`fehlt`, und "findet die Datei **ausserhalb** des geprüften Baums" ist
`ausserhalb`. Der Beobachter ist ein Kanal, kein Prädikat — was er feststellt,
ist eines der drei.

**Mehrteilige Zeilen.** Nennt eine Zeile zwei Kanäle mit `+`, trägt sie zwei
Prädikate mit `+`, **je Kanal genau eines und in derselben Reihenfolge**:
`Z-129` (`stdout+stderr`, `fehlt+fehlt`) und `Z-152` (`selbsttest+dauer`,
`gleich+kleiner`). Andere mehrteilige Zeilen bestehen nicht.

**Die Bindungsregeln — welcher Wortlaut welches Prädikat verlangt.** Das ist
die eigentliche Zusicherung dieses Buchstabens: nicht, dass ein Prädikat in der
Zeile steht, sondern dass **Wortlaut und Messart einander bestimmen**.

| Wendung in der Spalte Zusicherung | Zulässiges Prädikat |
|---|---|
| "trägt die Zeile `X`", "enthält die Zeile `X` wörtlich", "`X` als ganze Zeile" | **nur** `zeile-woertlich`, gemessen als ganze Zeile |
| "nennt `X`", "enthält `X`", "führt `X` auf", "trägt den Zusatz …" | **nur** `enthaelt` |
| "Rückgabewert N", "Stand N", "trägt den Schlüssel `X`", "nennt als Wert genau `X`", "stimmen überein" | `gleich` |
| "genau ein JSON-Objekt, dessen einziges Feld … heisst" | `einzelfeld` |
| "leer — kein einziges Byte", "Standardausgabe leer" | `leer` |
| "existiert", "liegt vor", "verzeichnet einen Aufruf", "führt die Datei" | `existiert` |
| "fehlt", "verzeichnet **keinen** Aufruf", "führt die Datei **nicht**", "enthält **nicht**" | `fehlt` |
| "liegt ausserhalb des geprüften Baums" | `ausserhalb` |
| "innerhalb von N s", "kleiner als" | `kleiner` |

Zwei Feinheiten, die aus der Durchsicht folgen und deshalb hier stehen statt
später entdeckt zu werden:

1. **"X und nicht Y".** Nennt eine Zusicherung einen geforderten **und** einen
   ausgeschlossenen Text (`Z-100`, `Z-103`, `Z-141`, `Z-143`), bindet der
   **tragende, positive** Teil das Prädikat; der Ausschluss wird mitgemessen und
   ändert die Messart nicht. Bei `Z-141` und `Z-143` ist der positive Teil eine
   Wertgleichheit, und eine Gleichheit schliesst den anderen Wert ohnehin aus.
2. **Benannte Zeile.** Auf dem Kanal `kette` ist die Stelle bereits durch den
   Kanal bestimmt ("erste Zeile oder eine benannte Zeile", 6.12.26 a). Pinnt die
   Zusicherung dort einen **Wert** (die Wurzel, den `FEHLT=`-Wert), ist das
   `gleich`; verlangt sie nur das **Vorkommen** eines Textes in dieser Zeile
   (`Z-080`, Beschaffungsweg), ist es `enthaelt`. `zeile-woertlich` bleibt den
   Kanälen vorbehalten, auf denen die Stelle **nicht** bestimmt ist und die
   Zeile deshalb erst gesucht werden muss — heute `stderr` (`Z-040`) und
   `selbsttest` (`Z-153`).

**Wie die Bindung mechanisch wird.** Jede Messhülle bindet ihr Prädikat über
ihren **Namen**, so wie sie seit 6.12.26 f, Punkt 9 (`S7-05`) ihren Kanal über
ihren Namen bindet. Zulässig ist zusätzlich, dass eine typisierte Hülle ihr
Prädikat über ein Argument bindet, das **sie selbst** auf einen geschlossenen
Teilvorrat einschränkt und mitmeldet — das ist der Fall der Dateihülle mit
`existiert\|fehlt`. **Frei** angegeben werden darf das Prädikat allein dort, wo
schon der Kanal frei angegeben werden darf, also bei `pruefe_wahr` für
`beobachter`, `dauer`, `selbsttest` und `datei`, und auch dort nur aus dem
Vorrat: ein Wert ausserhalb des Vorrats ist eine Abweichung. Für die Wendung
"die Zeile … wörtlich" braucht es je Kanal eine **Zeilenhülle**; sie fehlt
heute und ist zu bauen (h). Die Selbstauskunft eines Falls ist keine Bindung —
sie sagt, was der Fall zu messen behauptet, nicht, was er misst; das war
`S5-01`, und es gilt für das Prädikat wie für den Kanal.

**Die Methode, mit der die Spalte gefüllt worden ist — ausdrücklich
festgehalten.** Die Spalte `Prädikat` ist von dieser Rolle **allein aus dem
Wortlaut der Zusicherung** bestimmt worden, **ohne Blick in den Selbsttest**.
Das ist keine Bequemlichkeit, sondern die Bedingung dafür, dass der Abgleich
etwas zeigt: Wer die Spalte aus der Messhülle abschreibt, erzeugt eine Tabelle,
die mit dem Bau notwendig übereinstimmt und über ihn nichts aussagt — die
Zusicherung ohne Deckung aus V12, diesmal im ADR statt im Skript. Erst der
**Prädikatabgleich nach dem Bau** zeigt, wo Wortlaut und Messhülle
auseinanderliegen; das ist die Fehlerklasse aller acht Runden. **Jede
Abweichung ist ein Befund**, und der DevOps Engineer behebt sie **entweder**
durch die Messhülle **oder** — nur mit Begründung in einem Nachtrag zu diesem
Abschnitt — durch den Wortlaut der Zeile. Der Weg "Spalte an die Hülle
angleichen" ist ausgeschlossen. Dass dabei Abweichungen zu erwarten sind, ist
kein Mangel dieser Festlegung, sondern ihr Zweck; ihre Zahl ist beim Bau zu
melden.

**c) Schlüsseldeckung — die Klassifizierungstabelle wird gegen die Prüftabelle gehalten**

| | |
|---|---|
| **Vorher galt** | Die Deckung nach 6.12.25 a hält Tabelle gegen Selbsttest, der Abgleich nach 6.12.26 a Kanal gegen Kanal. Ob **jeder** Zählschlüssel, den 6.12.4 führt, überhaupt eine Zusicherung hat, prüfte nichts — ausgeführt belegt an `KETTE schlusszeile-widerspruch`, den die Suche im Selbsttest, in der Mutationsdatei und in der Tabelle **je null mal** findet (`DT8-02`) |
| **Jetzt gilt** | Jeder Zählschlüssel der Klassifizierungstabelle in **6.12.4** kommt in mindestens einer nicht zurückgezogenen Zeile der Tabelle 6.12.19 als **erwarteter Schlüssel** vor. Der Selbsttest prüft das mechanisch und endet **ungleich 0**, wenn ein Schlüssel ohne Zeile bleibt |

**Die Quelle ist allein 6.12.4.** Gelesen wird die Spalte "Schlüssel des
Kriteriums" der Tabelle in dieser ADR-Datei — aufgefunden über ihre Kopfzeile
`\| Beobachtung in der Ausgabe von \`make dod\` \| Art \| Schlüssel des
Kriteriums \| Ausgang des Gates \|`, dritte Spalte. **Keine zweite Liste im
Selbsttest**: eine Liste im Skript wäre eine zweite Stelle, an der dieselbe
Aussage steht, und veraltete beim ersten neuen Schlüssel, ohne dass es
auffällt (6.2.2). Zeilen, deren Schlüsselspalte `—` trägt — die terminierte
Lage C —, sind ausgenommen; sie zählen keinen Schlüssel, weil sie durchlassen.

**Wie ein Platzhalter behandelt wird, als Ersetzungsvorschrift.** Die Schlüssel
in 6.12.4 stehen in Backticks und tragen Platzhalter der Form `<…>`. Der
Abgleich bildet daraus ein Suchmuster, in dieser Reihenfolge:

1. Den Inhalt der Backticks nehmen (ohne die Backticks selbst).
2. Alle Zeichen mit Sonderbedeutung im Suchmuster maskieren.
3. **Jeden** Platzhalter — ein `<`, danach beliebige Zeichen ausser `>`, danach
   ein `>` — durch das Muster für **genau ein Wort** ersetzen: ein oder mehrere
   Zeichen, die weder Leerzeichen noch Rohrzeichen noch Backtick sind.
4. Das Ergebnis in jedem durch Backticks begrenzten Abschnitt der Spalte
   Zusicherung suchen. *(Berichtigt am 2026-09-06 durch i), Befund S9-04: Für
   die **Deckung** muss der Abschnitt **vollständig** mit dem Muster
   übereinstimmen — an Anfang **und** Ende verankert —, weil
   `LISTE <Nummer> <Zeilennummer>` sonst als Präfix von
   `LISTE <Nummer> <D> <ziel>` mitgedeckt würde und **eine** Zeile für zwei
   Schlüssel einstünde. Für die **Gegenrichtung** unten genügt unverändert,
   dass der Abschnitt mit einem passenden Muster **beginnt**; sonst wäre
   `GATE sha256sum\|1` ein Fehlalarm, obwohl es den Inhalt der Zählerdatei
   nennt und keinen Schlüssel. Folge für die Tabelle: Ein Platzhalter in einer
   Zelle ist **ein** Wort — `Z-159` trägt deshalb `<D> <ziel> C <Pruefmittel>`.
   Die erste Fassung dieses Punktes sagte "ohne Verankerung"; sie bleibt als
   frühere Fassung lesbar.)*

Die Folge ist beabsichtigt und wird hier ausgesprochen: Eine Zeile deckt einen
Schlüssel **entweder** mit einem konkreten Wert (`GATE mktemp`) **oder** mit
der Platzhalterform, wenn der konkrete Wert erst der Prüfaufbau bestimmt
(`\`<D> <ziel> A_FAIL\``). Beides ist zulässig, weil beides denselben
Gegenstand benennt; unzulässig ist allein, dass **keine** Zeile ihn benennt.
Gesucht wird ausschliesslich in der Spalte **Zusicherung** und ausschliesslich
**innerhalb von Backticks** — nicht in der Spalte Fall, nicht in der Spalte
Mutation und nicht im Fliesstext. Sonst genügte eine beiläufige Erwähnung, und
die Deckung sagte nichts über das, was **zugesichert** ist.

**Der Bestand am 2026-09-06, von Hand über die ganze Datei erhoben.** Gedeckt
sind heute **vier** der vierzehn Schlüssel, ungedeckt **zehn**:

| Schlüssel aus 6.12.4 | Heute gedeckt durch | Neu gedeckt durch (e) |
|---|---|---|
| `<D> <ziel> A_FAIL` | **nein** — `Z-051` nennt in Backticks allein `A_FAIL`, nicht den Schlüssel | `Z-158` |
| `<D> <ziel> C <fehlendes Prüfmittel>` | **nein** — `Z-008` sichert nur den Rückgabewert zu | `Z-159` |
| `KETTE marke-fehlt <D> <ziel>` | **nein** — kommt in der ganzen Tabelle nicht vor | `Z-160` |
| `D19 VERLETZT` | **nein** — `Z-058` und `Z-059` nennen in Backticks allein `VERLETZT` | `Z-161` |
| `D19 C` | **nein** — `Z-062` und `Z-063` nennen in Backticks allein `C` | `Z-162` |
| `D19 B-widerspruch` | **ja**, `Z-143` | — |
| `KETTE ausgabe-unlesbar` | **ja**, `Z-134`, `Z-136`, `Z-138`, `Z-140`, `Z-141`, `Z-143`, `Z-145` | — |
| `KETTE schlusszeile-widerspruch` | **nein** (`DT8-02`) | `Z-168` |
| `KETTE baum-widerspruch` | **ja**, `Z-097` | — |
| `KETTE rueckgabewert=<N>` | **nein** — steht allein in der Spalte **Mutation** von `Z-114` | `Z-165` |
| `KETTE zeitueberschreitung` | **nein** — kommt in der ganzen Tabelle nicht vor | `Z-163` |
| `LISTE <Nummer der Selbstpruefung> <D> <ziel>` | **nein** | `Z-166` |
| `LISTE <Nummer der Selbstpruefung> <Zeilennummer>` | **nein** | `Z-167` |
| `GATE <fehlendes Prüfmittel>` | **ja**, acht Zeilen: `Z-113`, `Z-115` und `Z-146` bis `Z-151` | — |

Der Befund `DT8-02` benennt **einen** ungedeckten Schlüssel; die vollständige
Erhebung findet **zehn**. Das ist kein Widerspruch zum Prüfbericht, sondern
sein Beleg: Er hat die Klasse gefunden, nicht ihren Umfang, und genau deshalb
wird die Deckung maschinisch und nicht durch die nächste Prüfrunde bestimmt.

**Die Gegenrichtung wird ebenfalls maschinell geprüft — entschieden.** Ein
Schlüssel, der in 6.12.19 steht und den 6.12.4 nicht führt, ist kein zulässiger
Zuwachs, sondern ein Widerspruch zwischen zwei Stellen derselben Datei; er
gehört zur selben Fehlerklasse wie die Lücke und ist mit demselben Mittel
findbar. Erkannt wird ein Schlüssel in der Spalte Zusicherung daran, dass ein
durch Backticks begrenzter Abschnitt mit einem der vier **Stämme** `KETTE `,
`LISTE `, `GATE ` oder `D19 ` beginnt; jeder solche Abschnitt muss zu
mindestens einem Muster aus 6.12.4 passen, sonst endet der Selbsttest ungleich
0. Die beiden schlüssellosen Formen `<D> <ziel> A_FAIL` und `<D> <ziel> C <…>`
haben keinen Stamm und bleiben von der Gegenrichtung unberührt — sie sind an
einem Wort nicht erkennbar, und ein Muster, das jede Zeichenkette für einen
Schlüssel hielte, prüfte nichts. Diese Grenze ist benannt und bleibt
Prüfgegenstand der statischen Prüfung.

**d) Grammatikdeckung — je Element der Marke eine verneinende Zeile**

| | |
|---|---|
| **Vorher galt** | 6.12.7 legt die Grammatik der Lage-Marke fest. Welche ihrer Elemente das Gate tatsächlich erzwingt, prüfte keine Zusicherung — ausgeführt belegt am **schliessenden** `::`: die Fremdmutation `M-14` (schliessendes `::` optional) lässt **keine** Kennung fallen, und ein Lauf mit einer Marke ohne `::` endet unter der Mutation mit Rückgabewert 0 und sauberem Grün (`DT8-03`) |
| **Jetzt gilt** | 6.12.7 trägt als **Nachtrag** eine Tabelle "Elemente der Marke" mit je einem festen ASCII-Kürzel. Für **jedes** Kürzel führt die Tabelle 6.12.19 mindestens eine Zeile, die den **Verstoss** gegen dieses Element misst; der Selbsttest liest die Kürzel aus jener Tabelle und endet **ungleich 0**, wenn ein Kürzel ohne Zeile bleibt |

**Welche Elemente aufgenommen sind.** Neun, und keines mehr *(fortgeschrieben
am 2026-09-06 durch i) auf **zehn**: Das Element `ENDE` — die Terminierung der
Marke — kommt hinzu, Befund `DT9-01`)*: Präfix `::LAGE`,
Lauf-Kennung, D-Nummer, Ziel, Lage, Zusatz `FEHLT=<wert>`, Zusatz
`SCHWELLE=…\|OHNE_SCHWELLE`, schliessendes `::` und die Rückgabewertklammer
`(rueckgabewert=N)`. Die ersten acht stehen wörtlich in der Grammatikzeile von
6.12.7. Die **Rückgabewertklammer** steht dort **nicht**; sie steht im
Markenmuster des Gates, das sie als festen Anhang verlangt und im Kommentar auf
die Zusammenfassung im `Makefile` zurückführt. Sie wird deshalb in die
Elementtabelle aufgenommen und in 6.12.7 damit **nachgeführt, nicht geändert**:
Das Gate verlangt sie seit dem Bau, die Festlegung führte sie nicht — genau die
Lage, die V12 verbietet ("was das Gate tut, steht in der Festlegung oder es
steht nirgends"). Weitere Elemente gibt es nicht; namentlich wird **keine**
Grammatik der Schlusszeilen aus 6.12.8 in diese Tabelle aufgenommen: Die
Schlusszeilen sind über `Z-133` bis `Z-141` und `Z-168` gedeckt und sind kein
Element **der Marke**.

**Der Verstoss und sein erwarteter Ausgang.** Je Element misst die verneinende
Zeile eine Marke, die **genau in diesem einen Element** missgebildet und im
Übrigen wohlgeformt ist — `FEHLT=` ohne Wert, `(rueckgabewert=)` ohne Zahl,
eine Lage ausserhalb der vier zulässigen Wörter, ein fehlendes Feld, ein
fehlendes `::`. Der erwartete Ausgang ist **Rückgabewert 2** und der Schlüssel
**`KETTE ausgabe-unlesbar`**. Abgeleitet ist er aus dem Aufbau des Gates: Eine
missgebildete Zeile trifft das Markenmuster nicht, wird nicht als Marke
gezählt, und die gelesene Markenzahl bleibt hinter der Zahl zurück, die die
Schlusszeile selbst nennt — das ist der Block aus 6.12.24 k. Für das Element
`ABSCHLUSS` bestätigt das ein Fremdbeleg aus Runde 8 (`DT8-03`: im Original
Rückgabewert 2 und `KETTE ausgabe-unlesbar`); für die übrigen acht ist es
abgeleitet und **beim Bau zu bestätigen**. Weicht der Ausgang ab, ist das ein
**Befund** und diese Festlegung fortzuschreiben, nicht die Zeile an das Gate
anzupassen.

**Zur Abgrenzung gegen `KETTE marke-fehlt <D> <ziel>`.** 6.12.4 führt diesen
Schlüssel für "eine Zeile der Übersicht trägt keine Marke". Das Gate setzt ihn
für die Zeile, die die Kette **selbst** als `(keine Marke)` ausgibt, zusammen
mit einer Schlusszeile Form 3. Eine **missgebildete** Marke ist ein anderer,
an der Ausgabe unterscheidbarer Fall und fällt unter
`KETTE ausgabe-unlesbar`. Beide Schlüssel bleiben damit belegt — `marke-fehlt`
neu über `Z-160` (c). Was die Kette im `Makefile` mit einer missgebildeten
Marke eines Schrittes tut, ist hier **nicht festgestellt**; diese Zeilen messen
das **Gate** gegen eine Attrappenausgabe (6.12.19, erste Prüfebene). Die
Feststellung am `Makefile` hat der DevOps Engineer zu treffen, wenn sie
gebraucht wird.

**Wie die Deckung mechanisch wird.** Jede verneinende Zeile trägt in der Spalte
**Fall** am Anfang das Etikett `Grammatik <KUERZEL>: `, wörtlich in dieser Form
— das Wort `Grammatik`, ein Leerzeichen, das Kürzel in Grossbuchstaben, ein
Doppelpunkt, ein Leerzeichen, danach die Beschreibung des Falls. Der Selbsttest
liest die Kürzelliste aus der Elementtabelle in 6.12.7 (erste Spalte, in
Backticks, nur `A` bis `Z`) und verlangt je Kürzel mindestens eine Zeile der
Tabelle 6.12.19, deren Fallspalte mit diesem Etikett beginnt.

**Was bereits gemessen wird, und was nicht.** Die Durchsicht der 155
bestehenden Zeilen ergibt: **keine** misst den Verstoss gegen ein Element.
`Z-054` und `Z-055` messen die Marke mit `FEHLT=` **und** `SCHWELLE=`
zugleich — also die **wohlgeformte** Marke und die richtige Lesart ihrer
Gruppen, nicht ihre Abweisung; sie werden deshalb **nicht** umetikettiert, denn
ein Etikett, das an einer Zeile hinge, die den Verstoss gar nicht herstellt,
machte die Deckung zur Formsache. `Z-133` bis `Z-141` und `Z-145` messen
fehlende oder widersprüchliche **Schlusszeilen** und **Markenzahlen**, nicht
ein Element der Marke. Alle neun Elemente erhalten deshalb in e) je eine neue
Zeile; das Element `ABSCHLUSS` erhält deren zwei, weil `DT8-03` für diesen Fall
beide Ausgänge belegt hat — den Rückgabewert und den Schlüssel.

**e) Die neuen und die berichtigte Zeile der Tabelle 6.12.19**

Es gelten unverändert: Kennungen fortlaufend ab `Z-156`, **nie** umnummeriert
(6.12.25 a); je Zeile **genau eine** messbare Zusicherung mit Kanal, Prädikat
und Mutation; die Mutation als beschreibender Text — den `sed`-Ausdruck
schreibt der Bau in `scripts/dod-gate-mutationen.txt` (6.12.26 b) — und
`keine` nur mit einem der drei Gründe aus 6.12.26 b in der Fassung von 6.12.26
f, Punkt 2.

**Die Berichtigung: `Z-040`.** Die Zeile wird **berichtigt, nicht
zurückgezogen** (6.1.2, 6.12.25 g). Ihr Wortlaut lautet neu: "Die
Fehlerausgabe des **dritten** Ereignisses trägt die Zeile
`Eskalation 3.4: <Schlüssel>` als ganze Zeile"; Prädikat `zeile-woertlich`;
Mutation neu die Fremdmutation `M-01` — die **Eskalationsschwelle** im Gate von
`-ge 4` auf `-ge 3`; Herkunft "Entwurf G17; berichtigt 2026-09-06 (6.12.27 e,
`DT8-01`)". Weshalb diese Mutation die Zeile fallen lässt: Beim **dritten**
Ereignis greift unter der Mutation der Zweig ab dem vierten Mal; dessen
Meldung trägt die Übergabezeile nur noch **eingebettet** in den Satz "erwartet
eine Datei … mit der wörtlichen Zeile '…'", und die eigenständige Zeile
verschwindet **als Zeile**. Eine Teilzeichenkettensuche sieht das nicht, eine
Zeilenhülle sieht es. Genau daran ist die Fremdmutation in Runde 8
unbemerkt geblieben.

**Die neuen Zeilen, nach Anlass geordnet.**

| Kennung | Anlass | Gegenstand in einem Satz |
|---|---|---|
| `Z-156` | `DT8-01` | Der Durchlass greift **frühestens beim vierten** Ereignis: drittes Ereignis mit vorhandener, in `HEAD` committeter Übergabedatei mit der passenden Zeile — Rückgabewert 2. Mutation `M-01` |
| `Z-157` | 6.12.9, Ereignisfolge | Das **vierte** Ereignis **ohne** Übergabedatei blockiert mit der Forderung nach der Datei auf der Fehlerausgabe |
| `Z-158` bis `Z-167` | Schlüsseldeckung (c) | Je eine Zeile für die zehn ungedeckten Zählschlüssel aus 6.12.4 |
| `Z-168`, `Z-169` | `DT8-02` | `KETTE schlusszeile-widerspruch`: Rückgabewert 0 der Kette mit einer Schlusszeile **Form 4** — Schlüssel (`Z-168`) und Rückgabewert (`Z-169`) |
| `Z-170` bis `Z-179` | Grammatikdeckung (d), `DT8-03` | Je eine Zeile für die neun Elemente der Marke, für `ABSCHLUSS` zwei |
| `Z-180` | `DT8-04` | Der Rückfallpfad über `CLAUDE_PROJECT_DIR` löst den Baum **physisch** auf |
| `Z-181` | `DT8-05` | Die **innere** Zeitgrenze ist kleiner als die kleinste äussere |
| `Z-182` bis `Z-184` | `DT8-06` | Die Ausgabeform je Durchlasspfad, für die drei bisher ungemessenen Pfade |

**Zu `Z-168` und `Z-169`, und weshalb nur eine der beiden eine Mutation
trägt.** Der Fall ist: Die Kette endet mit **0**, ihre Schlusszeile ist
**Form 4** ("Rahmenpruefung D19 VERLETZT"), die D19-Zeile meldet passend
`VERLETZT`. Nach 6.12.23 a ist Rückgabewert 0 nur mit Form 1 vereinbar; das
Gate blockiert deshalb mit `KETTE schlusszeile-widerspruch` — so steht es im
Gate, und darauf ist die Zeile geschrieben. Form 4 ist gewählt, weil die
Fremdmutation `M-07` genau dort ansetzt. Unter `M-07` — Form 4 von der
Widerspruchsprüfung ausgenommen — läuft die Auswertung weiter, findet den
D19-Befund und blockiert über die Konsistenzwache unter dem **falschen**
Schlüssel `KETTE ausgabe-unlesbar`; das ist die Beobachtung aus `DT8-02`
(Fremdbeleg). Der **Schlüssel** trennt die Verneinung also (`Z-168`, Kanal
`zaehler`, Mutation `M-07`), der **Rückgabewert** nicht: er bleibt 2. `Z-169`
trägt deshalb `keine` nach **Grund 3** mit der Schwester `Z-168` — dieselbe
Lage wie bei `Z-139` und `Z-155`, und aus demselben Grund wird sie nicht mit
einer Mutation versehen, die sie nicht erkennen kann.

**Zu `Z-180` (`DT8-04`).** Der Fall stellt her: Arbeitsverzeichnis
**ausserhalb** jedes Git-Baums, `CLAUDE_PROJECT_DIR` auf ein
**Unterverzeichnis** des geprüften Baums, grüne Attrappenkette. Das Gate
bestimmt dann keinen gemeinsamen Baum über das Arbeitsverzeichnis, fällt auf
das Projektfeld zurück und löst dieses **physisch auf die Wurzel** auf; das
`Makefile` liegt dort, die Kette läuft, der Ausgang ist **Rückgabewert 0**.
Unter `M-16` — der Baum wird roh aus dem Projektfeld übernommen — zeigt der
geprüfte Baum auf das Unterverzeichnis, das `Makefile` fehlt dort, und das Gate
blockiert mit `GATE Makefile`; die Zeile fällt. Das ist zugleich die
Beobachtung des Prüfers, dass `M-16` das Gate **strenger** und falsch rot
macht.

**Zu `Z-181` (`DT8-05`) und dem Kanal.** Gemessen wird **statisch**, ohne Lauf
des Gates: Die Sekundenzahl im Aufruf `timeout -k 10 <N> make` in
`.claude/hooks/dod-gate.sh` ist **kleiner** als der kleinste `timeout`-Wert der
drei Hook-Einträge `Stop`, `SubagentStop` und `TaskCompleted` in der
versionierten `.claude/settings.json`. Beide Werte sind am 2026-09-06 gelesen
worden: **600** im Skript, **900** in jedem der drei Einträge. Die Mutation ist
`M-15` (600 auf 6000). Der Kanal ist `selbsttest`; seine Beschreibung in
6.12.26 a wird dafür **erweitert**, weil eine statische Lesung dort bisher
nicht vorkam: `selbsttest` ist neu "Rückgabewert oder Ausgabe eines zweiten
Selbsttestaufrufs **oder eine statische Lesung, die der Selbsttest ohne Aufruf
des Gates an versionierten Dateien vornimmt**". Der Kanal `datei` ist geprüft
und **verworfen**: Er bezeichnet seit 6.12.26 a den Fundort **eines Laufs** —
Aufrufprotokoll, Spurdatei, Zählerdatei —, und hier läuft nichts. Ein neuer
Kanalwert wird nicht erfunden (V13). Der Vorrat aus 6.12.26 a bleibt im Übrigen
unverändert.

**Zu `Z-182` bis `Z-184` (`DT8-06`).** Das Gate hat **sechs** Ausgänge mit
Rückgabewert 0; **fünf** davon geben ein JSON-Objekt aus, der sechste — das
saubere Grün — gibt nichts aus und ist über `Z-003` (Prädikat `leer`) gedeckt.
Von den fünf messen heute **zwei** die Ausgabeform: `Z-006` (Durchlass mit
terminierten Lagen C) und `Z-102` (belegtes Grün mit ausgefallenem Zählwerk).
Ungemessen sind der **Eskalations-Durchlass**, der Durchlass wegen
`stop_hook_active` und das Nichtlaufen für eine **Rolle ohne Schreibrecht**;
sie erhalten je eine Zeile mit Kanal `stdout` und Prädikat `einzelfeld`. Die
Mutation ist je Zeile dieselbe Art und doch trennscharf: das Feld
`systemMessage` wird **nur in der `jq`-Zeile dieses einen Pfades** umbenannt,
adressiert über den unmittelbar vorangehenden Meldungstext. `M-13` — das Feld
an **allen** Stellen umbenannt — lässt heute genau `Z-006` und `Z-102` fallen;
nach dieser Ergänzung fielen alle fünf, und die Trennschärfe je Pfad trägt die
pfadgenaue Mutation.

**Zur Ereignisfolge aus 6.12.9.** Geprüft ist Aussage für Aussage, welche eine
Zeile hat: die Forderung **genau beim dritten** Ereignis (`Z-040`, berichtigt),
Rückgabewert 2 und Stand 3 beim dritten (`Z-039`, `Z-038`), der Durchlass ab
dem vierten mit neuer, geänderter oder committeter Datei (`Z-041` bis `Z-044`),
die Abweisung eines nur älteren Commits (`Z-045`, `Z-046`), `TaskCompleted`
blockiert weiter (`Z-047`, `Z-048`), der Zähler zählt beim Durchlass weiter
(`Z-125` bis `Z-127`), `stop_hook_active` verändert ihn nicht (`Z-018`), und
die Bindung des Durchlasses an den **gezählten** Schlüssel (`Z-154`, `Z-155`).
**Zwei** Aussagen hatten keine Zeile und erhalten sie: der Durchlass greift
**frühestens beim vierten** Ereignis (`Z-156`, `DT8-01`) und der Block ab dem
vierten Ereignis **ohne** Übergabedatei erhebt die Forderung nach der Datei
(`Z-157`).

**f) Zahlen und Bestand nach diesem Abschnitt**

Die Tabelle 6.12.19 führt nach dieser Fortschreibung `Z-001` bis `Z-184` —
**184** Zeilen, davon **eine** zurückgezogen (`Z-110`), also **183**
Zusicherungen. Mehrkanalig und damit auch mehrprädikatig sind unverändert
**zwei** Zeilen: `Z-129` (`stdout+stderr`, `fehlt+fehlt`) und `Z-152`
(`selbsttest+dauer`, `gleich+kleiner`). Die Zahl der **Messhüllen** steigt
damit von 156 auf **185**.

Verteilung der 185 Messhüllen auf die Prädikate: `gleich` **117**, `enthaelt`
**34**, `fehlt` **8**, `leer` **7**, `existiert` **7**, `einzelfeld` **5**,
`ausserhalb` **3**, `kleiner` **2**, `zeile-woertlich` **2**. Die
Kanalverteilung ändert sich um die 29 neuen Zeilen: `rc` +5, `zaehler` +19,
`stdout` +3, `stderr` +1, `selbsttest` +1.

`scripts/dod-gate-mutationen.txt` führt danach **183** Einträge — je nicht
zurückgezogener Kennung genau einen, `Z-110` ohne Eintrag —, davon **173** mit
`sed`-Ausdruck und **zehn** mit `keine`: `Z-152` und `Z-153` (Grund 1),
`Z-043`, `Z-045`, `Z-048` und `Z-068` (Grund 2) sowie `Z-114`, `Z-139`,
`Z-155` und neu `Z-169` (Grund 3). Gegenüber dem Stand vor dieser
Fortschreibung kommen 29 Einträge hinzu, davon 28 mit `sed` und einer mit
`keine`; der Eintrag für `Z-040` wechselt den Gegenstand auf die
Eskalationsschwelle.

Die Zahlen aus 6.12.26 f, Punkt 13 — 156 Messhüllen, 154 Einträge, 145 `sed`,
9 `keine` — sind der Stand **vor** diesem Abschnitt und bleiben als solcher
stehen; sie werden nicht umgeschrieben (6.1.2). **Neu zu melden hat der Bau:**
die Zahl der Tabellenzeilen und der Zusicherungen, die Zahl der Messhüllen und
ihre Verteilung auf Kanäle **und Prädikate**, die Zahl der Einträge der
Mutationsdatei mit der Aufteilung `sed`/`keine`, die Zahl der Abweichungen des
**Kanalabgleichs**, die Zahl der Abweichungen des **Prädikatabgleichs**, die
Zahl der ungedeckten Schlüssel aus 6.12.4 und der Kürzel ohne Zeile aus 6.12.7.
Die **statische Prüfung hat diese Zahlen zu bestätigen**; weichen sie ab, ist
das ein Befund und zu melden, nicht anzugleichen — dieselbe Regel wie in
6.12.26 f. *(Fortgeschrieben am 2026-09-06 durch i): 193 Zeilen, 192
Zusicherungen, 194 Messhüllen, 192 Einträge der Mutationsdatei, 10
Grammatikkürzel und 29 Aussagenkürzel. Die Zahlen dieses Buchstabens sind der
Stand davor und bleiben stehen.)* *(Weiter fortgeschrieben am 2026-09-06 durch
j): 208 Zeilen, 207 Zusicherungen, 209 Messhüllen, 207 Einträge der
Mutationsdatei, 11 Grammatikkürzel, 30 Aussagenkürzel; dazu neu die
Gegenstandsdeckung über 24 Literale aus dem Gate.)*

**g) Das Abnahmekriterium — entschieden**

Der Selbsttest gilt als **abgenommen**, wenn beides zutrifft:

1. **Die tabelleneigenen Mutationen werden zu 100 Prozent erkannt.**
   `nicht_erkannt=0` **und** `wirkungslos=0`; beide Modi enden mit Rückgabewert
   0; die Deckung nach 6.12.25 a stimmt in beide Richtungen; der
   **Kanalabgleich** und der **Prädikatabgleich** melden **null** Abweichungen;
   die **Schlüsseldeckung** nach c) ist in beide Richtungen vollständig und die
   **Grammatikdeckung** nach d) lückenlos.
2. **Eine Fremdmutationsrunde durchläuft ohne blockierenden Befund** in den
   vier Kategorien **Schlüssel** (6.12.4), **Grammatik** (6.12.7), **Schwellen
   und Ereignisfolge** (6.12.9) und **Ausgabeform** (6.12.15). *(Teil 2 ist am
   2026-09-07 durch **6.12.28 g** neu gefasst worden: Blockierend ist allein
   eine Fremdmutation, die am Gate ein **falsches Grün** erzeugt und keine
   Zusicherung fallen lässt; Formabweichungen sind nachrangig und Backlog, und
   Runde 12 ist die letzte Fremdmutationsrunde. Dieser Wortlaut bleibt als Stand
   davor stehen, 6.1.2.)*

**Was das im Einzelnen heisst.**

- **Mindestens drei Fremdmutationen je Kategorie**, also mindestens zwölf. Sie
  wählt der **Dynamic Software Tester** **ohne Kenntnis** von
  `scripts/dod-gate-mutationen.txt`; er liest die Datei erst **nach** seiner
  Wahl und hält im Bericht fest, dass er so vorgegangen ist. Der Grund ist
  derselbe, aus dem eine Rolle ihre eigene Arbeit nicht prüft (3.4): Eine
  Fremdmutation, die in Kenntnis der Mutationsliste gewählt wird, prüft die
  Liste und nicht das Prüfmittel.
- **Blockierend** ist eine Fremdmutation in einer der **vier** Kategorien, die
  **keine** Zeile fallen lässt.
- **Nachrangig** ist eine Fremdmutation **ausserhalb** der vier Kategorien, die
  keine Zeile fallen lässt. Sie ist **kein Abbruchgrund**; sie wird als
  Backlog-Posten unter **R3-Q-001** in `docs/05_Product_Backlog.md` geführt.
- Die Regel "dreimal am gleichen Kriterium" (3.4) bleibt **unverändert** und
  gilt für die blockierenden Befunde.
- Die **neunte Prüfrunde ist die Fremdmutationsrunde**.
- Die **Zähldifferenz "elf/zehn"** aus Runde 8 — der Bericht spricht von elf
  erkannten Fremdmutationen, seine Aufzählung nennt zehn (6.12.26 g, Punkt 2) —
  klärt der Dynamic Software Tester in Runde 9 und meldet das Ergebnis. Sie
  bleibt bis dahin festgehalten und wird nicht angeglichen (6.1.2).

**Stand nach der neunten Runde** *(Nachtrag vom 2026-09-06, i)*: **Teil 1 ist
erfüllt** — beide Modi enden mit 0, 173 von 173 tabelleneigenen Mutationen
erkannt, 0 wirkungslos, alle Deckungen und Zahlen von der statischen Prüfung
eigenständig nachgerechnet (Fremdbeleg). **Teil 2 ist nicht erfüllt**: In der
Fremdmutationsrunde bleiben drei Mutationen unerkannt (`DT9-01` bis `DT9-03`,
Kategorien Grammatik und Ereignisfolge). Nach der Regel dieses Buchstabens ist
das der **erste** Fehlschlag an Teil 2; die Zählung nach 3.4 beginnt damit bei
eins, und der Koordinator hat **keinen Abbruch** entschieden, sondern Behebung
an der Quelle und **Runde 10** als neue Fremdmutationsrunde mit blinder Wahl
durch eine neue Instanz des Dynamic Software Testers. Aus derselben Runde ist
die Ersatzregel dieses Buchstabens erprobt und ihre Grenze belegt: Alle 19
**blind** gewählten Fremdmutationen wurden erkannt, alle drei unerkannten
stammen aus der **Nachwahl** nach dem ersten Blick in die Mutationsdatei. Die
Blindheit ist damit nicht Förmelei, sondern der wirksame Teil des Kriteriums;
für Runde 10 gilt sie unverändert.

**Stand nach der zehnten Runde** *(Nachtrag vom 2026-09-06, j)*: **Teil 1
bleibt erfüllt** und ist von der statischen Prüfung erneut mit allen Zahlen
bestätigt; **Teil 2 ist wieder nicht erfüllt** — von 35 wirksamen
Fremdmutationen bleiben **sieben** unerkannt, alle in den vier Kategorien
(Schlüssel 3, Grammatik 2, Ausgabeform 2; die Kategorie Schwellen und
Ereignisfolge ist vollständig erfüllt). Das ist der **zweite** Fehlschlag an
Teil 2; die Schwelle aus 3.4 liegt beim **dritten**. Der Koordinator hat
wiederum **keinen Abbruch** entschieden, sondern Behebung an der **Klasse** —
Deckung am Gegenstand statt an der Aufzählung (j) — und **Runde 11 als dritten
Versuch**, mit dem vorab festgelegten Ausgang: **Fällt Runde 11, wird nach 3.4
abgebrochen**, die Übergabedatei geschrieben und die Sache dem Auftraggeber
vorgelegt. Die Blindheit hat sich auch in Runde 10 als der wirksame Teil
erwiesen: Vier der sieben unerkannten Mutationen stammen aus der **Nachwahl**.

**Stand nach der elften Runde** *(Nachtrag vom 2026-09-06, k)*: **Teil 1 bleibt
erfüllt** und ist erneut mit allen Zahlen bestätigt (beide Modi 0, 207 von 207,
197 von 197 erkannt, Gegenstandsdeckung 24/0). **Teil 2 ist zum dritten Mal
nicht erfüllt**: Von 29 verhaltensändernden Fremdmutationen bleiben **zehn**
unerkannt, alle in den vier Kategorien — und diesmal **ohne Nachwahl**, die
Wahl war durchgehend blind. Damit ist die Schwelle aus 3.4 erreicht, und der
Koordinator hat **abgebrochen**, wie in j) Punkt 8 vorab festgelegt. Die
Kategorie **Schlüssel** ist als einzige **vollständig** erfüllt (7 von 7) —
also genau die, für die j) die Deckung am Gegenstand gebaut hat; das ist
zugleich der Beleg, dass das Mittel wirkt, und der Grund der Vorlage **O-27**,
es auf Grammatik und Pfade auszudehnen oder den Massstab zu ändern.

**Weshalb dieses Kriterium und kein offenes.** Acht Runden sind nicht
konvergiert, und zwar nicht, weil schlecht gearbeitet worden wäre, sondern weil
"keine neue Lücke" kein erreichbarer Zustand ist: Die Tabelle kann nie alle
denkbaren Mutationen aufzählen, jede Runde findet eine weitere ungedeckte
Stelle, jede Behebung ist für sich richtig, und ein Ende kommt nicht. Vier
benannte Kategorien sind abzählbar, ihr Bestehen ist belegbar, und was danach
kommt, ist Verbesserung statt Abnahmehindernis. Der Preis ist benannt und
angenommen: Eine Lücke ausserhalb der vier Kategorien kann nach der Abnahme
bestehen bleiben, bis der Backlog-Posten abgearbeitet ist. Das ist die richtige
Richtung, weil das Gate in dieser Lage **falsch rot** oder **ungemessen**, aber
nicht **falsch grün** ist — und weil ein Prüfmittel, dessen Abnahme unmöglich
ist, nicht besser ist als keines.

**h) Nachführungsposten, nachrangige Befunde, und was dieser Nachtrag nicht ändert**

| Befund | Entscheid |
|---|---|
| **S8-01** (Rückzugserkennung liest die ganze Zeile) | Die Erkennung liest **die Spalte Kanal**. Eine Zeile gilt genau dann als zurückgezogen, wenn ihre Kanalspalte **keinen** Wert des Vorrats aus 6.12.26 a trägt; heute ist das allein `Z-110`, deren Kanal-, Prädikat- und Mutationsspalte je `—` tragen. Damit entfällt die Textsuche nach dem Wort "zurückgezogen" und mit ihr eine der beiden funktionalen Nicht-ASCII-Stellen aus S8-07. Geprüft: `Z-110` ist heute so dargestellt |
| **S8-03** (alte, unerreichbare Fassung des Blocks `GATE sha256sum`) | Die alte Fassung wird **entfernt**. Sie steht in den Zeilen 478 bis 482 von `.claude/hooks/dod-gate.sh`, ist seit dem Vorziehen des Blocks (6.12.26 e, DT6-05) unerreichbar und verhaltensneutral. Zwei Stellen mit derselben Aussage sind der Fehler aus 6.2.2, auch wenn eine davon tot ist |
| **S8-05** (`Z-080` misst über die ganze Fehlerausgabe des D20-Aufrufs) | Die Messung wird **isoliert**. `Z-080` misst neu auf der **Zeile des Lage-C-Befunds zu D20** in der direkt aufgerufenen Kettenausgabe (Form `[<D> <ziel>] LAGE C: <Text>`, 6.12.7), nicht über die ganze Ausgabe. Der Wortlaut der Zeile ist entsprechend berichtigt, Kanal (`kette`) und Prädikat (`enthaelt`) bleiben; Herkunft ergänzt um "Runde 8, S8-05". Eine Messung über die ganze Ausgabe wäre auch dann grün, wenn der Beschaffungsweg an einer beliebigen anderen Stelle stünde. **Nachtrag vom 2026-09-06 aus Phase 1 des Baus:** Der erste Wortlaut dieser Berichtigung nannte die **falsche** Zeile. Das `Makefile` gibt zu D20 **zwei** Zeilen aus — die Lage-C-Zeile mit der Begründung und, ihr unmittelbar folgend, eine eigenständige Zeile `Beschaffen: git fetch --unshallow` (vom Koordinator am `Makefile` nachgelesen, Fremdbeleg). Auf der Lage-C-Zeile steht der Beschaffungsweg nicht; die Zusicherung war am gebauten Bestand **unwahr**. Die Messung ist deshalb auf die **Beschaffen-Zeile** isoliert; Kanal (`kette`) und Prädikat (`enthaelt`) bleiben, die Ganzzeilenform wird **nicht** gepinnt, weil diese Rolle sie nicht gelesen hat. Das ist der **erste** Fall, in dem eine Abweichung nach 6.12.27 b über den **Wortlaut** statt über die Messhülle behoben wird, und die Begründung ist die dort verlangte: Eine Messhülle kann nicht auf einer Zeile messen, die den Text nicht trägt — der Mangel sitzt in der Zeile, nicht in der Messung. Der Bau hat die Zeile gemeldet statt sie anzupassen und das `Makefile` nicht angefasst; genau so ist der Weg in 6.12.27 b festgelegt |
| **S8-06** (Kanalabgleich vergleicht Zeichenketten statt Mengen) | Die **Reihenfolge ist verbindlich**, und derselbe Massstab gilt für den Prädikatabgleich. Bei mehrteiligen Zeilen gehört das i-te Prädikat zum i-ten Kanal (b); eine Prüfung als **Menge** könnte diese Zuordnung gar nicht prüfen. Damit ist nicht der Bau zu ändern, sondern der **Wortlaut von 6.12.26 a**, der von Mengen spricht: er wird hiermit auf die Reihenfolge **berichtigt**. S8-06 ist damit kein Befund am Bau |
| **S8-07** (Nicht-ASCII in den Skripten) | In `.claude/hooks/dod-gate.sh` und `scripts/dod-gate-selbsttest.sh` sind Nicht-ASCII-Zeichen **unzulässig** — in Mustern, Vergleichswerten, Meldungen und Kommentaren gleichermassen. Grund: Beide Dateien werden von `sed` unter wechselnden Locales kopiert und mutiert, und ein Nicht-ASCII-Zeichen in einem Muster ist eine stille Fehlerquelle; die Skripte schreiben ohnehin durchgehend "Rueckgabewert" statt Umlauten. Die beiden **funktionalen** Stellen entfallen mit S8-01, die drei übrigen sind zu ersetzen. Die aus der ADR-Datei **gelesenen** Werte bleiben davon unberührt: Kanäle, Prädikate und Kürzel sind absichtlich reines ASCII |
| **S8-02**, **S8-04** | Bleiben, wie 6.12.26 g sie führt: S8-02 gegenstandslos, S8-04 mit dem Commit der damaligen Einheit erledigt. Hier nichts zu entscheiden |

**Was dieser Nachtrag nicht ändert.** Kein Entscheid G1 bis G17 und keiner aus
6.12.23 bis 6.12.26 wird zurückgenommen; keine Kennung wandert, keine
Zusicherung entfällt — `Z-040` wird berichtigt, `Z-080` in der Messung
isoliert, und beide behalten ihre Kennung. Die Kernarchitektur aus 5.1, die
Entscheide A1 bis A13, der Modulschnitt aus Abschnitt 4 und die Verankerung der
Verfahrensgarantien in 4.2 und 4.3 bleiben unberührt; das Gate steht an keiner
Stelle zwischen Freigabe und Ausführung (5.2). **Keine D-Nummer wird
vergeben.** Nichts hier bereitet Gestrichenes vor (5.17, 5.18, 9.1, 5.10,
5.1). **Und nichts hier ist eine Freigabe oder eine Abnahme:** Der Entscheid
des Auftraggebers vom 2026-09-06 betrifft **allein O-26**; O-25, die
Entscheidpunkte E-A bis E-K und die Abnahme des Gates stehen unverändert aus
(Abschnitt 10). **Nichts in diesem Abschnitt ist gebaut**, und diese Rolle hat
nichts ausgeführt und nichts nachgemessen; den Stand nach der Umsetzung belegt
erst die **neunte** Prüfrunde, nicht dieser ADR.

**i) Nachträge aus dem Bau und der neunten Runde (2026-09-06)**

Die neunte Prüfrunde ist am 2026-09-06 gelaufen: Static und Dynamic Software
Tester, beide auf einem anderen Modell als die Umsetzung (3.4), je in einer
Wegwerfkopie, die Prüfsummen des Originals vorher und nachher gleich. **Alle
Zahlen, Läufe und Befunde dieses Abschnitts sind Fremdbeleg** aus ihren
Berichten und aus den Zwischenkontrollen des Baus; diese Rolle hat nichts davon
ausgeführt, nichts nachgemessen und bestätigt nichts. Was hier steht, ist das
Protokoll der gemeldeten Lage und der Entscheid dazu.

**1. Statische Prüfung: nicht bestanden, Teil 1 des Abnahmekriteriums
erfüllt.** Beide Modi enden mit 0 — Normalmodus 183 von 183, Mutationsmodus 173
von 173 erkannt, 10 ohne Mutation, 0 wirkungslos; alle Zahlen aus f) sind
eigenständig bestätigt, alle 173 `sed`-Ausdrücke einzeln angewandt (0
Nulloperationen), die Deckungen unabhängig nachgerechnet (Schlüssel 14/0/0,
Grammatik 9/0), der Diff am Gate umfasst genau drei Blöcke, und alle dreizehn
Behebungen der Zwischenkontrollen sind bestätigt. **Blockierend** sind zwei
Befunde derselben Klasse:

- **S9-01** (`Z-109`) und **S9-02** (`Z-106`): Beide Zeilen melden den Kanal
  `beobachter`, **ohne einen Beobachter zu benutzen**. `Z-106` misst einen
  Vorher-Nachher-Vergleich nach dem Lauf — sachlich tragend, weil das Gate seine
  Sperrdatei nie löscht —, `Z-109` misst den Inhalt der Spurdatei nach dem Lauf,
  und der mitlaufende Beobachter sucht nur innerhalb des Baums. Massstab ist
  6.12.26 a; die Klasse ist `S5-01`: **Selbstauskunft statt Bindung** bei den
  vier Kanälen, die `pruefe_wahr` frei annimmt.

**2. Dynamische Prüfung, Fremdmutationsrunde: nicht bestanden, Teil 1 erfüllt,
Teil 2 nicht erfüllt.** Die Reihenfolge ist belegt: **19** Fremdmutationen um
09:18:36 UTC schriftlich gewählt, erster Blick in
`scripts/dod-gate-mutationen.txt` um 09:20:39 UTC; zehn davon deckungsgleich mit
der Datei, **sieben Ersatzmutationen nach dem ersten Blick nachgewählt** — der
Prüfer legt selbst offen, dass diese sieben eine **schwächere Blindheit** haben.
26 Läufe, 16 nicht deckungsgleiche Mutationen (Schlüssel 3, Grammatik 4,
Ereignisfolge 5, Ausgabeform 4), **23 erkannt, 3 nicht erkannt** — und alle drei
nicht erkannten stammen aus der **Nachwahl**, während **alle 19 blind gewählten
erkannt** wurden.

| Befund | Was unerkannt blieb |
|---|---|
| **DT9-01** (Grammatik) | Der **Endanker** `$` des Markenmusters entfernt: Eine Übersichtszeile mit beliebigem Anhang hinter der Rückgabewertklammer gilt als Marke, und keine Zeile fällt. Die Elementtabelle in 6.12.7 kannte die **Terminierung** der Marke nicht |
| **DT9-02** (Ereignisfolge) | Der Satz "anderer Schlüssel → Zähler auf eins" (6.12.9) ist ungemessen: Mit Weiterzählen statt `neue_zahl=1` trägt die Zählerdatei nach einem Schlüsselwechsel den Stand 3 statt 1, und der Selbsttest meldet 183 von 183. `Z-147` und `Z-150` messen nur den Fall **ohne** vorhandene Zählerdatei |
| **DT9-03** (Ereignisfolge) | Der Satz "ein Durchlass löscht den Zähler" (6.12.9) ist ungemessen: Ohne `loesche_zaehler` bleibt die Zählerdatei nach dem Durchlass bestehen, und der Selbsttest meldet 183 von 183 |

**Negativbefunde — was gehalten hat:** das Gate gegen die Kopie als echten Baum
in allen Pfaden richtig, die Eskalationsfolge über zehn Ereignisse lückenlos,
zwei nebenläufige Aufrufe sauber serialisiert, über 21 Läufe ausschliesslich die
Rückgabewerte 0 und 2, und die Ausgabeform je Durchlasspfad wie zugesichert.

**3. Die Zähldifferenz "elf/zehn" ist geklärt.** Die Aufzählung in 6.12.26 g
trägt **zehn** erkannte Fremdmutationen, und nur zehn ist mit den sechzehn
benannten Mutationen vereinbar; der Originalbericht der achten Runde liegt nicht
im Repository. Das Ergebnis lautet also **zehn**. 6.12.26 g bleibt
**unangeglichen** — der dortige Vermerk hält die Differenz fest, und Historie
wird nicht umgeschrieben (6.1.2).

**4. Entscheid des Koordinators, protokolliert und nicht bewertet: kein
Abbruch.** Nach g) gilt die Regel aus 3.4 für die **blockierenden** Befunde der
Fremdmutationsrunde, und Runde 9 ist der **erste** Fehlschlag an Teil 2 des
Abnahmekriteriums. Behoben wird an der Quelle, danach folgt **Runde 10** als
neue Fremdmutationsrunde mit blinder Wahl durch eine **neue Instanz** des
Dynamic Software Testers, dazu eine statische Nachprüfung.

**5. Die Entscheide dieser Rolle.**

**(a) Ein zehntes Element der Marke: `ENDE`.** Die Elementtabelle in 6.12.7
führt neu die **Terminierung** — die Marke endet mit der Rückgabewertklammer,
es folgt nichts mehr. Verstoss ist ein Anhang dahinter; erwarteter Schlüssel ist
wie bei den neun anderen `KETTE ausgabe-unlesbar`, aus dem Aufbau des Gates
abgeleitet und beim Bau zu bestätigen. Die Grammatikdeckung verlangt damit eine
Zeile `Grammatik ENDE:` — neu `Z-185`. Die Angabe "neun, und keines mehr" in d)
ist damit auf **zehn** fortgeschrieben; sie war nicht falsch, sondern
unvollständig: Die Grammatikzeile in 6.12.7 zählt die **Bestandteile** der Marke
auf und sagt über ihr **Ende** nichts, während das Muster des Gates es erzwingt.

**(b) Aussagendeckung für 6.12.9 und 6.12.15.** Beide Abschnitte tragen neu je
eine Tabelle "Aussagen dieser Festlegung" mit festen Kürzeln (`E01` bis `E22`,
`A01` bis `A07`), je Kürzel eine Aussage in einem Satz und der Verstoss, den die
verneinende Zeile misst. Jede Zeile der Tabelle 6.12.19, die eine Aussage misst,
trägt in der Spalte Fall am Anfang das Etikett `Aussage <KUERZEL>: `; eine Zeile
trägt **genau ein** Etikett, und die Grammatik-Etiketten bleiben, wie sie sind.
Der Selbsttest liest die Kürzel aus beiden Tabellen und gibt eine Zeile
`Aussagendeckung: n Kuerzel, m ohne Zeile` aus; er endet ungleich 0, sobald ein
Kürzel ohne Zeile bleibt. Die Kategorie **Schlüssel** (6.12.4) bleibt bei der
Schlüsseldeckung aus c); die Aussagendeckung deckt die Kategorien
**Grammatik-Terminierung**, **Ereignisfolge** und **Ausgabeform**.

Der Grund ist die Analyse des Prüfers, die diese Rolle sich zu eigen macht: Die
Tabelle misst bisher, was der ADR **aufzählt** — Schlüssel, Elemente —, nicht
das, was er **behauptet**. Genau dort ist in jeder Runde die nächste Lücke
entstanden. Mit c), d) und dieser Aussagendeckung sind alle vier Kategorien des
Abnahmekriteriums aus g) an eine **aufzählbare Menge** im ADR-Text gebunden, und
nicht mehr an die Wachsamkeit einer Prüfrunde.

**(c) Zu S9-01 und S9-02: typisierte Hüllen auch für `beobachter` und
`datei`.** Der Vorschlag des Prüfers wird **angenommen**. Gebaut werden eine
typisierte Beobachterhülle, die den Beobachter **selbst startet und auswertet**,
und eine typisierte Dateihülle; `pruefe_wahr` bleibt allein für `dauer` und
`selbsttest` zulässig — heute drei Messhüllen (`Z-152`, `Z-153`, `Z-181`), die
einzeln im Blick sind. *(Berichtigt am 2026-09-06 durch j), Befund S10-04:
Nach dem Bau sind es **zwei** Hüllen mit freier Angabe, nicht drei. Fremdbeleg
des Prüfers; diese Rolle hat nicht nachgezählt.)* Begründung: `SST-B5-01` zeigt denselben Mangel von der
anderen Seite — `Z-130` meldete `gleich` und maass eine Teilzeichenkette, und
der Prädikatabgleich meldete **0**, weil eine freie Hülle meldet, was der
Aufrufer behauptet. Ein Abgleich, der die Selbstauskunft prüft, prüft sich
selbst. **Die Zeilen `Z-106` und `Z-109` bleiben im Wortlaut**; die Behebung
liegt bei der Messhülle. Lässt sich für einen dieser Fälle kein Beobachter
bauen, ist das ein **Befund** und eine Fortschreibung — nicht eine stille
Umdeutung der Zeile.

**(d) Zu S9-03: die Regel "der tragende Teil bindet" gilt allgemein.** Sie ist
in b) an `Z-100`, `Z-103`, `Z-141` und `Z-143` ausgesprochen und gilt hiermit
für **jede** Zeile, deren Zusicherung mehr als einen Teil nennt — auch für
`Z-052`, `Z-054`, `Z-045` und `Z-048`. Der Zusatz, ohne den die Regel eine
Einladung wäre: Eine Messhülle darf **mehr** messen, als das Prädikat sagt, nur
wenn das Mehr **Teil des Wortlauts derselben Zusicherung** ist — der
ausgeschlossene Text, die Bedingung des Aufbaus, die Schwesterangabe. Sie darf
**nie weniger** messen. Zerlegt werden die vier Zeilen nicht: Eine Zerlegung
brächte vier Kennungen mehr und keine Aussage mehr, weil beide Teile heute
gemessen werden.

**(e) Zu S9-04: die Ersetzungsvorschrift wird verankert.** Die Muster
`LISTE <Nummer> <Zeilennummer>` und `LISTE <Nummer> <D> <ziel>` unterscheiden
sich nur in der Zahl der Wörter; ohne Verankerung ist das kürzere ein Präfix des
längeren, und **eine** Zeile deckte beide Schlüssel. Die Vorschrift aus c) wird
deshalb berichtigt: Für die **Deckung** muss der durch Backticks begrenzte
Abschnitt **vollständig** mit dem Muster übereinstimmen (Anfang **und** Ende
verankert); für die **Gegenrichtung** genügt unverändert, dass der Abschnitt mit
einem passenden Muster **beginnt** — sonst wäre `GATE sha256sum\|1` (`Z-147`,
`Z-148`, `Z-150`, `Z-151`) ein Fehlalarm, obwohl es den Inhalt der Zählerdatei
und nicht einen Schlüssel nennt. Folge für die Tabelle: Der Platzhalter in
`Z-159` muss **ein** Wort sein; die Zeile trägt deshalb neu
`<D> <ziel> C <Pruefmittel>`. Der Bau hat die Vorschrift entsprechend
nachzuziehen; die gemeldete Deckung 14/0/0 ist danach erneut zu erheben.

**(f) Zu S9-05: die Grenze der Grammatikdeckung wird benannt, nicht
weggeräumt.** Das Gate erzwingt an dieser Stelle die **Zahl der Felder**, nicht
drei Elemente einzeln; `Z-171`, `Z-172` und `Z-173` sind für das Gate deshalb
formgleich, und ihre Mutationen sind untereinander nicht trennscharf — jede
lässt alle drei fallen. Das ist nach 6.12.26 b **zulässig** (eine Mutation darf
mehr treffen als eine Zeile), solange jede Zeile unter **ihrer eigenen**
Mutation fällt, und das tut sie. Die drei Zeilen bleiben, weil die Elementtabelle
die **Festlegung** aufzählt und nicht die Unterscheidungskraft des Gates; sie
sind aber **kein** unabhängiger Beleg dreier Eigenschaften. Wer das ändern will,
ändert die Grammatik, nicht die Prüftabelle.

**(g) Zu S9-06:** Die Kopfzeile führt 6.12.26 a neu als nachgeführte Stelle —
dort stehen seit dem 2026-09-06 zwei Berichtigungen (Kanal `selbsttest`,
Reihenfolge statt Menge).

**(h) Zu SST-B5-08 und SST-B5-01 — Nachträge zu b).** Die Zahl der
**anfänglichen** Prädikatabweichungen am alten Bau war **nicht null**: Eine war
mechanisch zwingend — `Z-040` hätte `enthaelt` gemeldet —, eine zweite sachlich
mit `Z-153`; gemeldet wurden 0, weil beide Fälle **vor** dem ersten Lauf
umgestellt worden waren. Der in b) erwartete Befund ist damit eingetreten und
nur nicht als Zahl sichtbar geworden; die Erwartung war richtig, die Messung kam
zu spät. Daraus die Bauvorschrift für künftige Fortschreibungen: **Der erste
Lauf nach einer neuen Spalte wird gegen den unveränderten Bau gefahren und seine
Abweichungszahl gemeldet**, bevor eine Hülle angepasst wird. Und die Grenze aus
`SST-B5-01` gehört ausgesprochen: Solange eine Hülle ihren Kanal oder ihr
Prädikat als **freies Argument** nimmt, kann der Abgleich 0 melden, obwohl die
Bindung fehlt — genau deshalb (c).

**6. Neue Zeilen und Zahlen.** Neu sind **neun** Zeilen `Z-185` bis `Z-193`:
`Z-185` (Grammatik `ENDE`, `DT9-01`), `Z-186` (Zähler auf eins bei
Schlüsselwechsel, `DT9-02`), `Z-187` (ein Durchlass löscht den Zähler,
`DT9-03`), `Z-188` (Rolle ohne Schreibrecht lässt den Zähler unverändert),
`Z-189` (verschiedene Ereignisse, ein Zähler), `Z-190` (ein Subagent zählt für
sich), `Z-191` (die Zählerdatei liegt ausserhalb des Baums), `Z-192` (`GATE jq`
wird nicht gezählt) und `Z-193` (beim Blockieren bleibt die Standardausgabe
leer). Die Tabelle 6.12.19 führt damit `Z-001` bis `Z-193` — **193** Zeilen,
davon `Z-110` zurückgezogen, also **192** Zusicherungen und **194** Messhüllen.
Verteilung: `gleich` **122**, `enthaelt` **34**, `fehlt` **10**, `leer` **8**,
`existiert` **7**, `einzelfeld` **5**, `ausserhalb` **4**, `kleiner` **2**,
`zeile-woertlich` **2**. `scripts/dod-gate-mutationen.txt` führt **192**
Einträge, davon **182** mit `sed` und unverändert **zehn** mit `keine`. Die
Deckungen umfassen neu **10** Grammatikkürzel und **29** Aussagenkürzel (`E01`
bis `E22`, `A01` bis `A07`). **Alle diese Zahlen sind vom Bau erneut zu melden
und von der statischen Prüfung zu bestätigen**; weichen sie ab, ist das ein
Befund und zu melden, nicht anzugleichen. **f) ist damit fortgeschrieben**; die
dortigen Zahlen sind der Stand vor diesem Nachtrag und bleiben stehen (6.1.2).

**Was dieser Nachtrag nicht ändert.** Kein Entscheid G1 bis G17 und keiner aus
6.12.23 bis 6.12.27 h wird zurückgenommen; keine Kennung wandert, keine
Zusicherung entfällt, und **am Gate ist aus diesem Nachtrag nichts zu ändern** —
die drei Fremdmutationen sind Mutationen, keine Befunde am Verhalten. Die
Kernarchitektur aus 5.1, die Entscheide A1 bis A13, der Modulschnitt aus
Abschnitt 4 und die Verankerung der Verfahrensgarantien bleiben unberührt; das
Gate steht an keiner Stelle zwischen Freigabe und Ausführung (5.2). Keine
D-Nummer wird vergeben. Nichts hier bereitet Gestrichenes vor (5.17, 5.18, 9.1,
5.10, 5.1). **Und nichts hier ist eine Freigabe oder eine Abnahme:** O-25, die
Entscheidpunkte E-A bis E-K und die Abnahme des Gates stehen unverändert aus
(Abschnitt 10); **Teil 2 des Abnahmekriteriums aus g) ist nicht erfüllt**, und
den Stand nach diesem Nachtrag belegt erst die **zehnte** Prüfrunde.

**j) Nachträge aus der zehnten Runde (2026-09-06): Deckung am Gegenstand statt an der Aufzählung**

Die zehnte Prüfrunde ist am 2026-09-06 gelaufen. **Alle Zahlen, Läufe und
Befunde dieses Abschnitts sind Fremdbeleg**; diese Rolle hat nichts ausgeführt,
nichts nachgemessen und bestätigt nichts.

**1. Beleglage.** **Statisch bestanden**, die Fehlerklasse ist nicht
aufgetreten, **Teil 1** des Abnahmekriteriums erfüllt: Alle Zahlen aus f) und
i) sind bestätigt — 193 Zeilen, 192 Zusicherungen, 194 Messhüllen, Verteilung
122/34/10/8/7/5/4/2/2, 192 Einträge der Mutationsdatei (182 `sed`, 10 `keine`),
Schlüsseldeckung 14/0/0 mit Vollmatch, Grammatikdeckung 10/0, Aussagendeckung
29/0. Nachrangig sind `S10-01` bis `S10-08`. **Dynamisch nicht bestanden**,
**Teil 2 nicht erfüllt**: 31 Fremdmutationen **blind** gewählt (20:55:43 UTC),
erster Blick in die Mutationsdatei um 20:55:49 UTC, danach vier nachgewählt in
den Kategorien Schlüssel und Ausgabeform; 35 wirksam, **28 erkannt, sieben
nicht erkannt** — alle sieben in den vier Kategorien des Abnahmekriteriums. Die
Kategorie **Schwellen und Ereignisfolge** ist vollständig erfüllt.

| Befund | Was unerkannt blieb |
|---|---|
| **DT10-01** (Schlüssel) | `LISTE 5` (Gate, Zeile 1014) ist von keiner Zusicherung gemessen |
| **DT10-02** (Schlüssel) | `LISTE 6` (fünf Stellen) ist ungemessen — Nachwahl |
| **DT10-03** (Schlüssel) | `GATE dod-gate-terminierte-lagen.txt` (Zeile 455) ist ungemessen — Nachwahl |
| **DT10-04** (Grammatik) | Der **Zeilenanker** `^` des Markenmusters ist ungemessen: Unter der Mutation werde eine **eingebettete** Marke (`Fundstelle: ::LAGE k1 …`) gelesen, die das Original abweist. *(Berichtigt am 2026-09-06 nach dem Befund aus Teilschritt 6c des Baus: Das Gate trägt einen **zweiten** Anker — der `awk`-Vorfilter der Übersichtszeilen in Zeile 858 lässt nur `^::LAGE ` und `^\(keine Marke\)` durch. Eine eingebettete Marke passiert ihn nie; `M08` **allein am Muster** ist damit ein **äquivalenter Mutant** und ändert am Verhalten des Gates nichts. Der Prüfer hat seine Annahme laut Protokoll an einer **Musterprobe** — dem Regex allein — belegt, nicht an einem Gate-Lauf. **Richtig bleibt** der Kern des Befunds: Der Zeilenanfang war von **keiner** Zeile gemessen; `Z-198` misst ihn jetzt. **Nicht wahr** ist die Aussage, unter `M08` lese das Gate eine eingebettete Marke.)* |
| **DT10-05** (Grammatik) | Das schliessende `::` auf der **Erzeugerseite**: `MARKE_SUFFIX := ::` im `Makefile` (Zeile 603) auf `:` — keine Zeile fällt. Die Kette fängt es selbst als falsch **rot** ab (`make dod` endet mit 2, Übersicht `(keine Marke)`); ein falsches Grün entsteht nicht |
| **DT10-06** (Ausgabeform) | Aussage `A04` auf dem Pfad des **dritten** Ereignisses (Zeile 333) ist ungemessen — Nachwahl |
| **DT10-07** (Ausgabeform) | Aussage `A05` auf dem Pfad **ab dem vierten** Ereignis (Zeile 320) ist ungemessen — Nachwahl |

**2. Die Klasse, wie der Prüfer sie benennt, und die Antwort dieses
Abschnitts.** "Die Deckung ist an der **Aufzählung** festgemacht, nicht am
**Gegenstand**." Je Schlüssel, je Kürzel, je Aussage genügt **eine** Zeile;
ungemessen bleiben weitere Ausprägungen derselben Schlüsselfamilie, weitere
Verstossformen desselben Elements, die **Erzeugerseite** desselben Elements und
weitere **Pfade** derselben Aussage. Das ist dieselbe Klasse wie `DT8-03` und
`DT9-01` bis `DT9-03`. Die Antwort ist dreifach und in jedem Teil mechanisch:
die Deckung wird an einer aus dem **Prüfgegenstand** gelesenen Menge
festgemacht (Punkt 3), die Ausgabeform wird von einer Stichprobe zur
**Invariante über alle Aufrufe** (Punkt 4), und die Grammatik erhält das
fehlende Element **und** eine Zeile für die Erzeugerseite (Punkt 5).

| | |
|---|---|
| **Vorher galt** | Die Schlüsseldeckung (c) liest die Klassifizierungstabelle **6.12.4** — eine Aufzählung im ADR-Text. Sie sagt nichts darüber, welche Schlüssel das **Gate** tatsächlich bildet |
| **Jetzt gilt** | Neben 6.12.4 tritt eine **zweite Quelle**: die Schlüsselzeichenketten aus `.claude/hooks/dod-gate.sh` selbst. Beide Deckungen laufen nebeneinander; keine ersetzt die andere. 6.12.4 hält die **Festlegung** gegen die Prüftabelle, die neue Deckung den **Gegenstand** |

**3. Gegenstandsdeckung Schlüssel — die mechanische Regel.** Der Selbsttest
erhebt die Literale in dieser Reihenfolge:

1. **Fundstellen.** Gelesen werden aus `.claude/hooks/dod-gate.sh` die **ersten
   Argumente** von `blockieren_mit_zaehlung` in doppelten Anführungszeichen und
   die **Zuweisungen** an einen Namen, der auf `_schluessel` endet
   (`primaer_schluessel=`, `kette_abweichung_schluessel=`, `liste_schluessel=`,
   `terminiert_fehler_schluessel=`), einschliesslich der Anfügungen an ein Feld
   (`…_schluessel+=(…)`), je der Inhalt der doppelten Anführungszeichen.
2. **Literal oder nicht.** Eine Zeichenkette, die **ganz** aus einer Variablen
   besteht (`$1`, `$primaer_schluessel`, `${x}`) oder leer ist, ist **kein
   Literal**: Sie reicht einen anderswo gebildeten Schlüssel weiter. Sie wird
   übergangen. Alles Übrige ist ein Literal.
3. **Muster.** Jeder Variablenanteil (`$x`, `${x}`, `${x:-…}`) wird zu einem
   Platzhalter für **ein oder mehr** Wörter; die festen Anteile bleiben
   wörtlich. Die Mehrwortregel ist nicht Bequemlichkeit, sondern belegt:
   `$abbruch_d_ziel`, `$kand_d_ziel` und `$schluessel_d_ziel` tragen je **zwei**
   Wörter (`<D> <ziel>`). Die Verankerung aus i) (e) verhindert dabei die
   Präfixdeckung, weil sich die festen Anteile der `LISTE`-Muster in der Nummer
   unterscheiden.
4. **Abgleich.** Je Muster mindestens **eine** nicht zurückgezogene Zeile der
   Tabelle 6.12.19, deren Spalte Zusicherung einen durch Backticks begrenzten
   Abschnitt trägt, der **vollständig** auf das Muster passt; ein Platzhalter
   der Zelle gilt dabei als ein Wort. Ausgabezeile
   `Gegenstandsdeckung Schluessel: n Literale, m ohne Zeile`; Rückgabewert
   ungleich 0, sobald ein Literal ohne Zeile bleibt.

**Der Bestand am 2026-09-06** (Erhebung des Koordinators über das Gate,
Fremdbeleg): **30** Zeichenketten, davon **6** reine Variablen und damit
**24 Literale**. **Fünfzehn** sind gedeckt: `$m_d $m_ziel A_FAIL` (`Z-158`),
`$m_d $m_ziel C ${m_fehlt:-unbenannt}` (`Z-159`), `D19 B-widerspruch`
(`Z-143`), `D19 C` (`Z-162`), `D19 VERLETZT` (`Z-161`), `GATE mktemp`
(`Z-113`), `GATE sha256sum` (`Z-149`), `KETTE ausgabe-unlesbar` (`Z-134`),
`KETTE baum-widerspruch` (`Z-097`), `KETTE marke-fehlt $abbruch_d_ziel`
(`Z-160`, **nur** mit der Mehrwortregel), `KETTE rueckgabewert=$kette_rc`
(`Z-165`), `KETTE schlusszeile-widerspruch` (`Z-168`), `KETTE
zeitueberschreitung` (`Z-163`), `LISTE 2 $d_nummer $ziel_name` (`Z-166`) und
`LISTE 4 $terminiert_zeilennr` (`Z-167`). **Neun** haben keine Zeile und
erhalten sie mit Punkt 6: `GATE Makefile` (Zeile 443), `GATE
dod-gate-terminierte-lagen.txt` (455, `DT10-03`), `GATE flock` (469), `GATE
git` (376), `GATE make` (437), `GATE timeout` (464), `LISTE 3
$schluessel_d_ziel` (1025), `LISTE 5 $kand_d_ziel` (1014, `DT10-01`) und
`LISTE 6 $terminiert_zeilennr` (616, fünf Stellen, `DT10-02`).

**Zwei Feststellungen dazu, damit sie nicht später als Lücke erscheinen.** Ein
Literal `LISTE 1` besteht im Gate **nicht**; die Selbstprüfung 1 ist nach
6.12.4 keine eigene Klasse, sondern eine ungedeckte Lage C und zählt unter
`<D> <ziel> C <Pruefmittel>`. Und `GATE jq` wird von dieser Erhebung **nicht**
erfasst, weil der `jq`-Block weder über `blockieren_mit_zaehlung` noch über
eine `_schluessel`-Zuweisung läuft — er kann es nicht, weil er ohne `jq` nicht
zählen kann (6.12.23 c, Aussage `E12`). Das ist eine **benannte Grenze** der
Gegenstandsdeckung, kein Versehen: `GATE jq` bleibt über den Schlüssel aus
6.12.4, über `Z-021`, `Z-022` und über `Z-192` gedeckt. Wird der Block je
umgebaut, fällt er in die Erhebung und braucht dann eine eigene Zeile.

**4. Die Ausgabeform wird zur Invariante über alle Gate-Aufrufe.**

| | |
|---|---|
| **Vorher galt** | Die Aussagen der Ausgabeform (`A01`, `A04`, `A05`) sind je **einmal** gemessen, an je einem Pfad. Ein anderer Pfad, der dieselbe Aussage verletzt, fällt durch kein Netz — belegt an `DT10-06` (drittes Ereignis) und `DT10-07` (ab dem vierten) |
| **Jetzt gilt** | Der Selbsttest **protokolliert jeden** Gate-Aufruf mit Rückgabewert, Standard- und Fehlerausgabe und misst am Ende des Laufs über **alle** Aufrufe: kein Rückgabewert ausser 0 und 2 (`A08`); bei 2 ist die Standardausgabe leer (`A04`) und die Fehlerausgabe enthält `Schluessel: ` (`A05`); bei 0 ist die Standardausgabe leer **oder** genau ein JSON-Objekt mit dem einzigen Feld `systemMessage` (`A01`) |

Damit deckt die Aussagendeckung für die Aussagen der Ausgabeform **alle in
diesem Lauf beschrittenen Pfade** statt eines einzelnen. Das ist der
Unterschied zwischen einer Stichprobe und einer Invariante, und er ist genau
der Unterschied, den `DT10-06` und `DT10-07` sichtbar gemacht haben. Die
Aussage `A08` — das Gate endet ausschliesslich mit 0 oder 2 — steht seit
6.12.24 c und hatte bis heute **keine** Stelle, an der sie zugesichert war; sie
ist in die Tabelle der Aussagen in 6.12.15 aufgenommen. Gemessen wird über
`Z-194` bis `Z-197`. Die vier Zeilen tragen die Kanäle `rc`, `stdout`,
`stderr` und `stdout` — kein neuer Kanal, weil kein neuer Kanal nötig ist; neu
ist allein die **Anzahl**, und die nennt die Zusicherung ("jeder Aufruf",
6.12.25 f).

**5. Grammatik: das elfte Element und die Erzeugerseite.**

- **`ANFANG`** — der Zeilenanfang. Die Marke steht am Anfang ihrer Zeile; eine
  **eingebettete** Marke ist keine Marke. Verstoss ist eine Zeile wie
  `Fundstelle: ::LAGE k1 …`; erwarteter Ausgang wie bei den übrigen Elementen
  `KETTE ausgabe-unlesbar` mit Rückgabewert 2. Die Elementtabelle in 6.12.7
  führt damit **elf** Kürzel. *(Berichtigt am 2026-09-06 nach dem Befund aus
  Teilschritt 6c des Baus, Fremdbeleg: Das Gate ankert den Zeilenanfang an
  **zwei** Stellen — im `awk`-Vorfilter der Übersichtszeilen (Zeile 858) und im
  `marken_muster`. `M08` **allein am Muster** ist deshalb ein **äquivalenter
  Mutant**: Die eingebettete Marke scheitert schon am Vorfilter, und `Z-198`
  bliebe unerkennbar — in der Mutationsprobe 196 von 197. Die Mutationsspalte
  von `Z-198` ist deshalb auf **beide** Anker gestellt, wie sie es bei `Z-170`
  (`PRAEFIX`) von Anfang an war. Damit ist zugleich festgehalten, dass die
  Fremdmutation `M08` der Runde 10 das Verhalten des Gates **nicht** geändert
  hat und ihr Beleg eine Musterprobe war; der Kern von `DT10-04` — der
  Zeilenanfang war von keiner Zeile gemessen — bleibt richtig und ist der
  Grund für dieses Element.)* Dass dieses Element gefehlt hat, ist dieselbe Beobachtung wie
  bei `ENDE`: Die Grammatikzeile in 6.12.7 zählt die **Bestandteile** der Marke
  auf und sagt über ihre **Begrenzung** — Anfang wie Ende — nichts, während das
  Muster des Gates beides erzwingt.
- **Die Erzeugerseite** (`DT10-05`). Die Grammatikdeckung misst bisher
  ausschliesslich, wie das **Gate** eine missgebildete Marke abweist. Ob die
  **Kette** wohlgeformte Marken erzeugt, misst sie nicht. Dafür genügt **eine**
  Konsistenzzeile, und mehr wird nicht gebaut: `Z-199` verlangt, dass in der
  **Übersicht** eines Laufs des echten `Makefile` mit dem Ziel `dod` **keine**
  mit `::LAGE` beginnende Zeile besteht, die das aus dem Gate gelesene
  `marken_muster` nicht trifft, und dass mindestens eine solche Zeile besteht.
  Der Fall ist **neu** und braucht einen **minimalen Scheinbaum** — eigenes
  Git-Repository, echtes `Makefile`, echter Belegprüfer samt Ausnahmeliste,
  sonst nichts. Ein **bestehender** Fall trägt ihn nicht: Die vorhandenen Läufe
  gegen das echte `Makefile` rufen einzelne Ziele (`belege`, `nachweise`), und
  die grünen Scheinbäume laufen gegen die Attrappe (Feststellung des
  Koordinators und des DevOps Engineers am Selbsttest, Fremdbeleg). **Grün
  muss dieser Lauf nicht sein**, und die Zeile verlangt es nicht: Je nach
  fehlenden Prüfmitteln endet er mit Lagen C oder mit einem Abbruch (Form 2
  oder Form 3), und in jedem dieser Ausgänge trägt die Übersicht mindestens
  eine wohlgeformte Marke. **Welche Lagen der minimale Scheinbaum meldet,
  stellt der Bau fest und meldet es**; diese Rolle behauptet es nicht.
  **Gemessen wird die Übersicht, nicht die rohe Marke des laufenden Schritts**
  — eine Berichtigung vom 2026-09-06, vor dem Bau, nach einer Feststellung des
  Koordinators am `Makefile` (Fremdbeleg): `KLASSIFIZIEREN` gibt die Marke
  während des Laufs **roh** aus (Zeile 654), also `::LAGE … ::` **ohne** den
  Anhang ` (rueckgabewert=N)`; erst die Zusammenfassung am Ende hängt ihn an
  (Zeile 1760). Das `marken_muster` verlangt den Anhang. Eine Messung über
  **jede** `::LAGE`-Zeile der Kettenausgabe fiele deshalb schon am Original,
  und die Zeile wäre unwahr statt trennscharf. Massgeblich ist ohnehin die
  Übersicht: Sie ist das, was das Gate liest (6.12.3, 6.12.8). Die
  Trennschärfe bleibt unberührt — unter `M15` trägt die Übersicht keine gültige
  Marke mehr, sondern `(keine Marke)`, und die Zeile fällt. Das Muster wird **aus dem Gate
  gelesen**, nicht im Selbsttest wiederholt — sonst stünde dieselbe Grammatik
  an drei Stellen (6.2.2). Die Zeile deckt die Erzeugerseite **aller** Elemente
  auf einmal; je Element eine eigene Erzeugerzeile wäre elfmal dieselbe Messung.
  Festgehalten sei, was der Prüfer selbst festhält: `M15` erzeugt **kein**
  falsches Grün — die Kette fängt den Fehler als falsch rot ab. Die Zeile
  schliesst damit keine Lücke im Schutz, sondern eine im **Nachweis**.

**6. Die Entscheide zu den nachrangigen Befunden der statischen Prüfung.**

| Befund | Entscheid |
|---|---|
| **S10-01** (`Z-109` misst die Wegwerfdatei der **Kette** als Stellvertreter für die des Gates) | Der **Wortlaut wird verankert**, die Stellvertretung nicht wegerklärt: `Z-109` nennt neu das **Wegwerfverzeichnis des Gates** — das Verzeichnis, das das Gate vor dem Anlegen bestimmt und der Kette als `TMPDIR` übergibt — und sichert zu, dass die dort während des Laufs bestehende Wegwerfdatei physisch ausserhalb des geprüften Baums liegt. Kanal (`beobachter`) und Prädikat (`ausserhalb`) bleiben. Damit sagt die Zeile, was sie misst; die eigene, kurzlebige Wegwerfdatei des Gates bleibt über `Z-111` und `Z-131` gedeckt |
| **S10-04** (zwei statt drei Hüllen mit freier Angabe) | i) (c) wird an Ort berichtigt: Es sind nach dem Bau **zwei**, nicht drei. Fremdbeleg des Prüfers; diese Rolle hat nicht nachgezählt |
| **S10-05** (Aussagendeckung ohne Gegenrichtung und ohne Etikettwache) | **Beides wird mechanisch geprüft**: Ein Etikett `Aussage <KUERZEL>: `, dessen Kürzel in **keiner** der beiden Tabellen steht, ist eine Abweichung; eine Zeile, deren Fallspalte **mehr als ein** Etikett trägt (`Grammatik …` und `Aussage …` oder zwei `Aussage …`), ebenfalls. Ohne die Gegenrichtung wäre ein Tippfehler im Kürzel eine stille Nichtdeckung — dieselbe Begründung wie in 6.12.25 a für die Kennungen |
| **S10-06** (Anwesenheitsprüfung statt Vollständigkeit) | Für `A01`, `A04`, `A05` und `A08` mit Punkt 4 behoben — sie sind Invarianten über alle Aufrufe. Für die übrigen Aussagen bleibt es bei der Anwesenheit **einer** Zeile, und das ist eine **benannte Grenze**: Namentlich `E21` (die erste Abweichung zählt, genannt werden alle) und `E22` (der Zusatz zum ausgefallenen Zählwerk steht in **jeder** Meldung) sind heute an je einem Fall gemessen, obwohl ihr Wortlaut über alle Fälle spricht. Eine Ausweitung ist eine Fortschreibung, keine Auslegung |
| **S10-07** (`Z-190`: die Mutation ist enger als die Spalte) | Die **Spalte** wird auf die engere, tatsächlich ausführbare Form gebracht: Aus der Namensbildung der Zählerdatei entfällt der Anteil, den die `agent_id` beisteuert. Die Zusicherung bleibt unverändert |
| **S10-02** (Zeitmarke im Beobachterprotokoll) | **Verlangt.** Jede Beobachtung des Beobachterprotokolls trägt eine Zeitmarke. Ohne sie lässt sich "während des Laufs" nachträglich nicht mehr prüfen, und eine Beobachtung ohne Zeitbezug belegt nicht, dass sie im Beobachtungsfenster lag — dieselbe Lücke, die `DT5-01` an `Z-111` aufgedeckt hat |
| **S10-03**, **S10-08** | Bleiben, wie der Prüfbericht sie führt; diese Rolle entscheidet zu ihnen nichts und behauptet nichts über sie |

**7. Neue Zeilen und Zahlen.** Neu sind **fünfzehn** Zeilen `Z-194` bis
`Z-208`: `Z-194` bis `Z-197` die vier Invarianten der Ausgabeform (`A08`,
`A04`, `A05`, `A01`), `Z-198` das Grammatikelement `ANFANG`, `Z-199` die
Erzeugerseite, `Z-200` bis `Z-208` die neun Literale ohne Zeile. Die Tabelle
6.12.19 führt damit `Z-001` bis `Z-208` — **208** Zeilen, davon `Z-110`
zurückgezogen, also **207** Zusicherungen und **209** Messhüllen. Verteilung:
`gleich` **132**, `enthaelt` **35**, `fehlt` **12**, `leer` **9**, `existiert`
**7**, `einzelfeld` **6**, `ausserhalb` **4**, `kleiner` **2**,
`zeile-woertlich` **2**. `scripts/dod-gate-mutationen.txt` führt **207**
Einträge, davon **197** mit `sed` und unverändert **zehn** mit `keine`. Die
Deckungen umfassen neu **11** Grammatikkürzel, **30** Aussagenkürzel (`E01`
bis `E22`, `A01` bis `A08`), **14** Schlüssel aus 6.12.4 und **24** Literale
aus dem Gate. **Alle diese Zahlen sind vom Bau zu melden und von der
statischen Prüfung zu bestätigen**; weichen sie ab, ist das ein Befund. f) und
i) sind damit fortgeschrieben; ihre Zahlen sind der Stand davor und bleiben
stehen (6.1.2).

**8. Entscheid des Koordinators, protokolliert und nicht bewertet: kein
Abbruch.** Runde 10 ist der **zweite** Fehlschlag an Teil 2 des
Abnahmekriteriums; die Schwelle aus 3.4 liegt beim **dritten**. Behoben wird an
der **Klasse**, nicht am einzelnen Befund. **Runde 11 ist der dritte Versuch an
Teil 2, und der Ausgang ist vorab festgelegt: Fällt sie, wird nach 3.4
abgebrochen, die Übergabedatei geschrieben und die Sache dem Auftraggeber
vorgelegt.** Diese Rolle hält das fest; sie bewertet es nicht und setzt es
nicht um.

**9. Nachtrag aus Teilschritt 6a des Baus: eine Berichtigung am Gate
(`GATE jq`).**

| | |
|---|---|
| **Befund** (Fremdbeleg aus dem Bau) | Die neue Invariante `Z-196` (Aussage `A05`: die Fehlerausgabe enthält bei **jedem** Block die Zeichenfolge `Schluessel: `) fällt im **Original** an genau **einem** Pfad: dem Block `GATE jq` (Gate, Zeilen 109 bis 114). Seine Meldung lautet "dod-gate: GATE jq -- 'jq' ist nicht installiert; die Eingabe auf der Standardeingabe kann nicht gelesen werden." — der Schlüssel wird **genannt**, aber nicht in der Form `Schluessel: GATE jq`, die alle übrigen Blockpfade tragen ("dod-gate: BLOCKIERT. Schluessel: <Schluessel>. …", Zeilen 320, 333, 342). Erfasst sind 117 Gate-Aufrufe; **alle anderen Pfade halten `A05`** |
| **Entscheid** | Das Gate wird an dieser **einen** Stelle in die einheitliche Meldungsform gebracht: "dod-gate: BLOCKIERT. Schluessel: GATE jq. 'jq' ist nicht installiert; die Eingabe auf der Standardeingabe kann nicht gelesen werden." Das Verhalten bleibt im Übrigen **unverändert**: Rückgabewert 2, **keine** Zählung — die Aussage `E12` bleibt wahr —, und die beiden Folgezeilen mit Beschaffungsweg und nächstem Schritt bleiben stehen |

**Weshalb die Meldung geändert wird und nicht die Zusicherung.** `A05` spricht
über **jeden** Block; sie ist nicht als Aussage über eine Auswahl von Pfaden
gemeint und war es nie. Die Uneinheitlichkeit ist ein Mangel des Gates, kein
Mangel der Zeile — deshalb greift hier **nicht** der Weg aus b), den Wortlaut
zu berichtigen. Bemerkenswert ist, **wodurch** der Mangel sichtbar geworden
ist: Die bisherige Stichprobe `Z-022` misst, dass die Fehlerausgabe `jq`
nennt, und ist am Original wie an der berichtigten Fassung grün; erst die
**Invariante über alle Aufrufe** (Punkt 4) hat den abweichenden Pfad gezeigt.
Das ist genau die Wirkung, um derentwillen die Invariante entschieden wurde,
und sie ist eingetreten, bevor eine Prüfrunde sie hätte finden müssen.
`Z-021` und `Z-022` bleiben unverändert wahr.

**Was dieser Nachtrag nicht ändert.** Kein Entscheid G1 bis G17 und keiner aus
6.12.23 bis 6.12.27 i wird zurückgenommen; keine Kennung wandert, keine
Zusicherung entfällt — `Z-109` und `Z-190` werden im Wortlaut beziehungsweise
in der Mutationsspalte berichtigt und behalten ihre Kennung. **Am Gate ist aus
diesem Nachtrag genau eine Änderung vorzunehmen** — die Meldungsform des Blocks
`GATE jq` in Zeile 110 nach Punkt 9 —, und sie ändert **kein Verhalten**:
Rückgabewert, Zählung (`E12`), Beschaffungsweg und nächster Schritt bleiben,
wie sie sind. Am `Makefile` ist **nichts** zu ändern: `M08` und `M15` sind
Mutationen, keine Befunde am Verhalten. Die Kernarchitektur aus 5.1,
die Entscheide A1 bis A13, der Modulschnitt aus Abschnitt 4 und die Verankerung
der Verfahrensgarantien bleiben unberührt; das Gate steht an keiner Stelle
zwischen Freigabe und Ausführung (5.2). Keine D-Nummer wird vergeben. Nichts
hier bereitet Gestrichenes vor (5.17, 5.18, 9.1, 5.10, 5.1). **Und nichts hier
ist eine Freigabe oder eine Abnahme:** O-25, die Entscheidpunkte E-A bis E-K
und die Abnahme des Gates stehen unverändert aus (Abschnitt 10); **Teil 2 des
Abnahmekriteriums ist nicht erfüllt**, und den Stand nach diesem Nachtrag
belegt erst die **elfte** Prüfrunde.

**k) Elfte Runde: dritter Fehlschlag an Teil 2, Abbruch nach 3.4, Vorlage O-27**

Die elfte Prüfrunde ist am 2026-09-06 gelaufen. **Alle Zahlen, Läufe und
Befunde sind Fremdbeleg**; diese Rolle hat nichts ausgeführt, nichts
nachgemessen und bestätigt nichts.

**1. Beleglage.** **Statisch bestanden**, die Fehlerklasse ist nicht
aufgetreten, **Teil 1 erfüllt**: beide Modi mit Rückgabewert 0 — Normalmodus
207 von 207 mit allen Deckungen ohne Abweichung und Gegenstandsdeckung 24/0,
Mutationsmodus 197 von 197 erkannt, 10 ohne Mutation, 0 wirkungslos. Alle
Zahlen aus j) Punkt 7 sind eigenständig bestätigt, die Gegenstandsdeckung
unabhängig nachgerechnet, alle 197 `sed`-Ausdrücke einzeln als wirksam belegt;
die Invarianten erfassen **124** Gate-Aufrufe (nicht 122). Zehn nachrangige
Befunde `S11-01` bis `S11-10`, darunter eine **neue Klasse**: *eine Deckung
besteht leer, wenn ihr Lesen misslingt* — `S11-04` (`Z-199` besteht bei leerem
`marken_muster`), `S11-05` und `S11-06` (Gegenstands- und Grammatikdeckung ohne
Mindestzahl und ohne Gegenrichtung).

**Dynamisch nicht bestanden**, die Fehlerklasse ist erneut aufgetreten,
**Teil 2 nicht erfüllt — dritter Fehlschlag**. 31 Fremdmutationen **blind**
gewählt um 23:07:05 UTC, Wirkungsproben am Gate von 23:08 bis 23:09, erster
Blick in die Mutationsdatei um 23:10:22; **keine Nachwahl** — je Kategorie
lagen mindestens drei nicht deckungsgleiche vor. 29 verhaltensändernd, 2
äquivalent (darunter der Anker allein am Muster, was den Befund aus j)
bestätigt). **19 erkannt, zehn nicht erkannt**, alle in den vier Kategorien:

| Befund | Was unerkannt blieb |
|---|---|
| `DT11-01` bis `DT11-05` (Grammatik, Gate Zeile 885) | Fünf **weitere Verstossformen** an Elementen, die eine Zeile haben: `ABSCHLUSS` gegen einfachen Doppelpunkt, ein Leerzeichen vor der Rückgabewertklammer, eine **leere** statt fehlende Lauf-Kennung, eine zusätzliche `SCHWELLE`-Alternative, ein nachlaufendes Leerzeichen am Zeilenende — je Rückgabewert 2 auf 0 |
| `DT11-06` (Ereignisfolge) | Die zweite Hälfte von `E21` ("genannt werden alle") ist nur an **einer** der **drei** Aufrufstellen gemessen; die Mutation zu `Z-051` trifft alle drei zugleich und verdeckt das |
| `DT11-07` bis `DT11-09` (Ausgabeform) | `A08` an drei Blockpfaden, die der Selbsttest **nie aufruft** — ungültiges JSON, unbekanntes Ereignis, kein bestimmbarer Baum: `exit 2` auf `exit 3` bleibt unerkannt |
| `DT11-10` (Ausgabeform) | Der Blockgrund eines dieser Pfade auf der Standardausgabe statt der Fehlerausgabe — `A04` und `A05` verletzt, unerkannt |
| `DT11-11` (Befund am **Original**, ohne Mutation) | Dieselben drei Pfade und der Pfad "Sperre länger als 120 s" enden mit 2, **ohne** dass die Fehlerausgabe `Schluessel: ` nennt — dieselbe Klasse wie `GATE jq` in j) Punkt 9; die Invariante `Z-196` erreicht diese Pfade nicht |

**Negativbefunde:** Die **Gegenstandsdeckung Schlüssel** aus j) wirkt — sechs
Umbenennungen an je **einer von mehreren** Fundstellen wurden erkannt, und die
Kategorie Schlüssel ist als **einzige vollständig** erfüllt (7 von 7). Schwellen
und Ereignisfolge sind bis auf `DT11-06` erfüllt; das Gate gegen echte Bäume
zeigt über 22 Aufrufe nur 0 und 2, die Ausgabeform je Durchlasspfad, die
Eskalationsfolge über 15 Ereignisse nach `E14` bis `E20`, Nebenläufigkeit und
D19-Unversehrtheit.

**2. Die Klasse, wie der Prüfer sie benennt.** j) hat die Deckung am Gegenstand
**nur für die Schlüssel** gebaut, und genau dort ist die Kategorie vollständig.
Für die **Grammatik** fehlt das Gegenstück: Die Elementtabelle zählt auf,
**woraus** die Marke besteht, nicht, auf **wie viele Arten** jedes Element
verletzt werden kann — eine Zeile je Element deckt eine Verstossform, nicht die
Menge. Für **Ausgabeform und Ereignisfolge** ebenso: Die Invariante gilt über
alle **protokollierten Aufrufe**, nicht über alle **Pfade** des Gates; ein Pfad,
den der Selbsttest nie beschreitet, wird von ihr nicht erreicht. Das ist
dieselbe Klasse wie `DT8-03`, `DT9-01` bis `DT9-03` und `DT10-01` bis
`DT10-07`, einen Schritt weiter gedacht.

**3. Entscheid des Koordinators, protokolliert und nicht bewertet: Abbruch nach
3.4.** Runde 11 ist der **dritte** Fehlschlag an Teil 2, und ihr Ausgang war in
j) Punkt 8 **vorab** als Abbruch festgelegt. **Kein Befund der elften Runde
wird in dieser Einheit behoben** — auch `DT11-11` und `S11-04` bis `S11-06`
nicht —; der Stand wird mit Übergabedatei committet und dem Auftraggeber
vorgelegt. Vorgelegt wird **O-27**.

**4. O-27 — Vorschlag dieser Rolle, nicht entschieden.** Zwei Wege, je
mechanisch beschrieben. Sie schliessen einander nicht aus; der Entscheid liegt
beim Auftraggeber.

| Weg | Was er mechanisch verlangt |
|---|---|
| **(a) Deckung am Gegenstand für Grammatik und Pfade** | **(a1) Pfaddeckung:** Der Selbsttest erhebt aus dem Gate **jede Ausgangsstelle** (jedes `exit`) und verlangt, dass die protokollierten Aufrufe jede Stelle mindestens einmal beschritten haben. Messbar über eine **Ausführungsspur** des Gates — etwa `bash -x` mit `BASH_XTRACEFD` und eigenem `PS4` gegen eine **Wegwerfkopie**, ohne Änderung am Gate. Damit decken die Invarianten `A01`, `A04`, `A05` und `A08` **alle** Pfade statt der beschrittenen. **(a2) Grammatik am Gegenstand:** Der Selbsttest erzeugt aus dem `marken_muster` des Gates **mechanisch** Schwächungen — je Anker entfernt, je `+` zu `*`, je Zeichenklasse geweitet, je Literal optional, je Alternative erweitert — und verlangt, dass **jede** Schwächung, die eine missgebildete Probemarke annimmt, eine Zeile fallen lässt. Das ist vollständig **relativ zum Muster** statt relativ zur Aufzählung. Dazu `DT11-11` als **Gate-Berichtigung** (einheitliche Meldungsform an den drei Vor-Eingabe-Pfaden und beim Sperrpfad) und `S11-04` bis `S11-06` als **fail-closed**-Deckungen: Mindestzahl verlangt, leeres Muster ist ein Fehlschlag |
| **(b) Das Abnahmekriterium ändern** | Teil 2 wird auf das **Gate** bezogen statt auf die Tabelle: **Blockierend** ist nur eine Fremdmutation, die am Gate gegen einen echten oder einen Attrappenbaum ein **falsches Grün** erzeugt und dabei keine Zeile fallen lässt. Formänderungen — falsch rot, abweichende Meldungsform, Rückgabewert 3 statt 2 — sind **nachrangig** und Backlog. Festzuhalten ist dabei: **Runde 11 hätte auch unter (b) nicht bestanden**, weil `DT11-01` bis `DT11-05` am Gate falsches Grün für missgebildete Marken erzeugen — wenn auch nur bei einer **gefälschten** Marke mit richtiger Lauf-Kennung erreichbar |

**Einschätzung des Koordinators — als seine Einschätzung gekennzeichnet, nicht
als Entscheid und nicht als Empfehlung dieser Rolle:** Weg (a) in **einer**
weiteren Einheit mit Runde 12; fällt auch sie, sei die Fähigkeit der Aufzählung
erschöpft, und dann wäre (b) mit **dokumentierter Restlücke** der ehrliche
Abschluss — das Gate selbst sei in elf Runden gegen echte Bäume **nie falsch
grün** gewesen.

**Was dieser Nachtrag nicht ändert.** Kein Entscheid G1 bis G17 und keiner aus
6.12.23 bis 6.12.27 j wird zurückgenommen; **keine Zeile der Tabelle 6.12.19
wird durch diesen Abschnitt geändert**, und die Zahlen aus j) Punkt 7 bleiben
massgeblich — der Bau ist unverändert. **Am Gate und am `Makefile` ist aus
diesem Nachtrag nichts zu ändern**; `DT11-11` ist als Posten benannt und
ausdrücklich **nicht** in dieser Einheit behoben. Die Kernarchitektur aus 5.1,
die Entscheide A1 bis A13, der Modulschnitt aus Abschnitt 4 und die Verankerung
der Verfahrensgarantien bleiben unberührt; das Gate steht an keiner Stelle
zwischen Freigabe und Ausführung (5.2). Keine D-Nummer wird vergeben. Nichts
hier bereitet Gestrichenes vor (5.17, 5.18, 9.1, 5.10, 5.1). **Und nichts hier
ist eine Freigabe oder eine Abnahme:** O-25, das neue **O-27**, die
Entscheidpunkte E-A bis E-K und die Abnahme des Gates stehen aus (Abschnitt
10). O-26 bleibt entschieden; **Teil 2 seines Abnahmekriteriums ist nach drei
Versuchen nicht erfüllt**, und das ist der Grund der Vorlage.

**5. Nachtrag: Entscheid des Auftraggebers vom 2026-09-07 zu O-27**

| | |
|---|---|
| **Weisung des Auftraggebers, Wortlaut** | "Dann wähle den besten und korrektesten Weg aus, ich vertraue dir und deiner Expertise." Im selben Zug: den Nutzungsstand als Richtwert prüfen, danach den Merge beider Pull Requests und eine neue Sitzung |
| **Lesart des Koordinators** | Der Auftraggeber **delegiert die Wahl** zwischen den Wegen aus k) Punkt 4 an den Koordinator. Die Wahl des Koordinators ist damit der **Entscheid zu O-27** — ein Entscheid des Auftraggebers durch Delegation, keine eigenmächtige Abweichung (3.1) |
| **Was der Entscheid nicht ist** | Keine förmliche Freigabe der Entscheidpunkte E-A bis E-K und keine Abnahme des Gates; Abschnitt 10 bleibt unverändert |

**Die Wahl des Koordinators, protokolliert und nicht bewertet: Weg (a) und Weg
(b) zusammen, in einer Einheit, mit Runde 12 als letzter Fremdmutationsrunde.**

1. **(a1) Pfaddeckung.** Sollmenge ist **jede Ausgangsstelle** des Gates — jedes
   `exit` in `.claude/hooks/dod-gate.sh` —, mechanisch aus dem Gate erhoben. Ist
   ist eine **Ausführungsspur** über alle Gate-Aufrufe des Selbsttests
   (`bash -x` mit `BASH_XTRACEFD` und einem `PS4`, das die Zeilennummer trägt,
   gegen eine **Wegwerfkopie**, das Gate selbst unverändert). Jede
   Ausgangsstelle muss mindestens einmal beschritten sein, sonst Fehlschlag.
   Ausnahmen nur mit einem Grund aus einer **geschlossenen Liste** und im ADR
   begründet; **Ziel ist keine Ausnahme** — auch der Sperrpfad "länger als
   120 s" wird hergestellt.
2. **(a2) Grammatik am Gegenstand.** Sollmenge sind **Schwächungen des
   `marken_muster`**, mechanisch aus dem Muster erzeugt nach einer
   **geschlossenen Liste** von Umformungen je Musterelement: Anker entfernt;
   Quantor `+` zu `*`; Literal oder Gruppe optional; Zeichenklasse geweitet;
   Alternative erweitert; Leerraum vor dem Endanker zugelassen. Ist: Jede
   Schwächung, die eine **Probemarke annimmt**, welche das unveränderte Muster
   ablehnt, muss **mindestens eine Zusicherung fallen lassen**. (a1) und (a2)
   werden **eigene Zusicherungen** der Tabelle 6.12.19 mit je einer Mutation und
   sind **fail-closed**: Mindestzahl grösser null, und ein leeres Muster oder
   eine leere Sollmenge ist ein Fehlschlag.
3. **Dazu drei Posten aus Runde 11.** `DT11-06`: je **Aufrufstelle** einer
   Aussage im Gate eine Messung, die Sollmenge aus dem Gate erhoben.
   `DT11-11`: **Gate-Berichtigung** — einheitliche Meldungsform an den drei
   Vor-Eingabe-Pfaden und am Sperrpfad, **ohne** Verhaltenswechsel, wie schon in
   j) Punkt 9 für `GATE jq`. `S11-04` bis `S11-06`: die bestehenden Deckungen
   fallen **fail-closed** aus.
4. **(b) Teil 2 des Abnahmekriteriums neu gefasst.** Blockierend ist allein eine
   Fremdmutation, die am Gate ein **falsches Grün** erzeugt — Rückgabewert 0,
   wo das unveränderte Gate 2 liefert, gegen einen echten Baum, einen
   Attrappenbaum oder eine Probemarke — und dabei **keine** Zusicherung fallen
   lässt. **Formabweichungen** (falsch rot, abweichende Meldungsform, ein
   Rückgabewert ausser 0 und 2 beim Block) sind **nachrangig** und Backlog.
   **Runde 12** — blind gewählt, mindestens **sechs** Fremdmutationen je
   Kategorie — ist die **letzte** Fremdmutationsrunde: Besteht sie, gilt der
   Selbsttest als abgenommen und die Abnahme des Gates wird vorgelegt. Ein
   falsches Grün aus Runde 12 wird behoben, statisch nachgeprüft und mit einer
   **gezielten Wiederholung** der betroffenen Fremdmutation belegt — **keine
   Runde 13**; was danach bleibt, ist **dokumentierte Restlücke**.
5. **Begründung des Koordinators, als seine gekennzeichnet:** (a) dehnt das
   Mittel aus, das in Runde 11 als **einziges vollständig** war — die Deckung am
   Gegenstand für die Schlüssel — auf Grammatik und Pfade. (b) ist der Massstab,
   an dem das Gate tatsächlich zu messen ist: Es hat in elf Runden gegen echte
   Bäume **nie falsch grün** geurteilt. Die Verbindung beendet die Runden, ohne
   die echten Lücken zu übergehen — `DT11-01` bis `DT11-05` **sind** falsches
   Grün für Probemarken und werden durch (a2) gedeckt. **Korrektheit vor
   Effizienz:** (b) allein liesse (a2) weg und damit die fünf echten Lücken
   stehen; (a) allein beendete die Runden nicht.

**Was in dieser Einheit noch nicht geschrieben wird.** Die **Ausformung** —
die Zeilen der Tabelle 6.12.19 für (a1) und (a2), ihre Mutationen, die
Änderung von 6.12.27 g Teil 2 im **Wortlaut**, die geschlossene Liste der
zulässigen Ausnahmen zu (a1) und die geschlossene Liste der Umformungen zu
(a2) — folgt als **6.12.28** zu Beginn der nächsten Einheit durch diese Rolle.
**In dieser Einheit ändert sich nichts** am Selbsttest, am Gate, an der Tabelle
6.12.19 und am `Makefile`; die Zahlen aus j) Punkt 7 bleiben massgeblich.

#### 6.12.28 O-27 — Deckung am Gegenstand für Pfade und Grammatik, Abnahmekriterium auf falsches Grün bezogen (Ausformung des Entscheids vom 2026-09-07)

**a) Was dieser Abschnitt ist, worauf er sich stützt und wer was tut**

Dieser Abschnitt **formt aus**, er entscheidet **nicht neu**. Der Entscheid zu
O-27 ist am 2026-09-07 gefallen und steht in 6.12.27 k, Punkt 5: Der
Auftraggeber hat die Wahl zwischen den beiden Wegen an den Koordinator
delegiert (Weisung im Wortlaut: "Dann wähle den besten und korrektesten Weg
aus, ich vertraue dir und deiner Expertise."), und der Koordinator hat **beide
Wege zusammen** gewählt — (a1) Pfaddeckung, (a2) Grammatik am Gegenstand, dazu
`DT11-06`, `DT11-11` und `S11-04` bis `S11-06`, und (b) Teil 2 des
Abnahmekriteriums auf das **falsche Grün am Gate** bezogen, mit **Runde 12** als
letzter Fremdmutationsrunde. Was hier steht, ist die Ausformung dieser fünf
Punkte in messbare Form: die Sollmengen, ihr Erhebungsmuster, die geschlossenen
Listen, die neuen Zeilen der Tabelle 6.12.19 und der neue Wortlaut von Teil 2.

**Belegkette dieses Abschnitts.** Alle Zeilennummern, Zahlen, Wortlaute des
Gates, die Ausführungsspur, die Laufzeiten und die Feststellung, welche
Ausgangsstellen heute beschritten sind, stammen aus der **Erhebung des
Koordinators vom 2026-09-07** (mechanisch erhoben, Befehle im Erhebungsbericht
genannt). Diese Rolle hat nichts ausgeführt und nichts nachgemessen; sie
übernimmt die Erhebung als **Fremdbeleg** und kennzeichnet an jeder Stelle, was
daraus stammt. Wo ein Ausgang **abgeleitet** ist und nicht belegt, steht es in
der Zeile — dieselbe Regel wie in 6.12.27 d.

**Wer was tut.** Diese Rolle schreibt 6.12.28, die Nachträge in 6.12.4, 6.12.7
und 6.12.9, den neuen Wortlaut von Teil 2 und die Zeilen der Tabelle 6.12.19
(als Zuordnungsdatei, die der Koordinator mechanisch einsetzt). Der **DevOps
Engineer** baut Selbsttest, Mutationsdatei und die **eine** Berichtigung am Gate
nach e). Der **Static Software Tester** kontrolliert nach Phase 1 und nach
Phase 3 zwischen. **Runde 12** läuft bei Static und Dynamic Software Tester auf
einem anderen Modell als die Umsetzung (3.4). Was der Bau an diesem Abschnitt
als falsch findet, meldet er; berichtigt wird er von dieser Rolle, nie
stillschweigend angepasst.

**b) (a1) Pfaddeckung — jede Ausgangsstelle des Gates mindestens einmal beschritten**

| | |
|---|---|
| **Vorher galt** | Die Ausgabeform ist seit 6.12.27 j eine **Invariante über alle protokollierten Gate-Aufrufe** (`Z-194` bis `Z-197`). Welche **Pfade** dabei beschritten werden, misst nichts. Ein Pfad, den der Selbsttest nie aufruft, wird von der Invariante nicht erreicht — belegt an `DT11-07` bis `DT11-10` (drei nie aufgerufene Blockpfade) und an `DT11-11` (Befund am Original an denselben Pfaden) |
| **Jetzt gilt** | Der Selbsttest erhebt aus `.claude/hooks/dod-gate.sh` mechanisch die **Sollmenge der Ausgangsstellen** und hält sie gegen eine **Ausführungsspur** über alle Aufrufe des unveränderten Gates. **Jede** Ausgangsstelle muss mindestens einmal beschritten sein; jede nicht beschrittene ohne gültige Ausnahme ist ein **Fehlschlag** |

**1. Die Sollmenge: 14 Ausstiege und 26 Aufrufstellen, zusammen 40.** Der
Entscheid nennt "jedes `exit`". Die Sollmenge umfasst gleichwohl **beides**, und
das ist kein Ausbau des Entscheids, sondern seine wörtliche Umsetzung am
Gegenstand: Vier der vierzehn `exit`-Anweisungen liegen **in** der Funktion
`blockieren_mit_zaehlung` (Zeilen 318, 329, 339, 346) und werden von **26**
verschiedenen Stellen aus erreicht. Dass Zeile 346 beschritten ist, sagt über
die Aufrufstelle 705 nichts — und genau diese Verwechslung von *Ausstieg* und
*Pfad* ist die Klasse, die `DT11-07` bis `DT11-10` sichtbar gemacht haben.
**Korrektheit vor Effizienz:** Die Sollmenge sind die **40 Ausgangsstellen** —
die 14 `exit`-Anweisungen und die 26 Aufrufstellen von
`blockieren_mit_zaehlung`, deren jede in einem `exit` dieser Funktion endet.
Fremdbeleg der Erhebung: Von den 14 Ausstiegen sind heute **vier** unbeschritten
(120, 128, 430, 584), von den 26 Aufrufstellen **acht** (705, 740, 748, 805,
812, 826, 1110, 1115); alle zwölf sind im Prüfaufbau herstellbar (Feststellung
des Koordinators, nicht ausgeführt).

**2. Das Erhebungsmuster, mechanisch und ohne verdrahtete Zahl.**

- **Ausstiege:** Zeilen des Gates, die auf `(^|[[:space:];&|{])exit [0-9]+`
  passen. Ausgeschlossen sind Zeilen, deren erstes Zeichen ohne führenden
  Leerraum `#` ist (Kommentar), und Zeilen, in denen die Fundstelle hinter einem
  `#` desselben Zeilenwortlauts liegt.
- **Aufrufstellen:** Zeilen, die auf
  `(^|[[:space:];&|{(])blockieren_mit_zaehlung[[:space:]]` passen, ohne die
  **Definitionszeile** (`blockieren_mit_zaehlung()`), mit derselben
  Kommentarregel.
- Die Sollmenge ist die Vereinigung beider Mengen, identifiziert über die
  **Zeilennummer**. Die Zahl 40 wird **nicht** im Selbsttest verdrahtet; sie
  wird erhoben und gemeldet. Ist die erhobene Menge leer, ist der Lauf ein
  **Fehlschlag** (fail-closed; gedeckt zusätzlich durch `Z-260`).

**3. Das Ist: die Ausführungsspur.** Gemessen wird gegen eine **bytegleiche
Wegwerfkopie** des Gates im Wegwerfverzeichnis ausserhalb des geprüften Baums;
ist die Kopie nicht bytegleich (`cmp`), ist der Lauf ein Fehlschlag. Der Aufruf
läuft mit `bash -x`, `BASH_XTRACEFD` auf einen **vom Aufrufer geöffneten**
Deskriptor (Spurdatei) und einem `PS4`, das die Zeilennummer trägt
(`+${LINENO}:`). Damit ändert die Spur Rückgabewert, Standard- und
Fehlerausgabe des Gates nicht — der dritte Kanal ist ein eigener.

**Wie `PS4` gesetzt wird — und weshalb nicht über die Umgebung.** Fremdbeleg
der Erhebung: `PS4` wird aus der Umgebung **nicht** übernommen (`env PS4=…
bash -x` liefert nur `+ `). Zwei Wege tragen, und beide sind belegt: über
**`BASH_ENV`** mit einer Datei, die `PS4` setzt, und über eine `bash -c`-Hülle
mit `source`, die dann `++` statt `+` voranstellt. **Gewählt ist `BASH_ENV`**,
weil die Aufrufhülle des Selbsttests (`env -i PATH=… "$BASH_BIN" "$GATE"`) damit
unverändert bleibt und kein zweiter Interpretationsschritt zwischen Hülle und
Gate tritt. `BASH_XTRACEFD` wird aus der Umgebung übernommen (belegt).

**Wie eine beschrittene Ausgangsstelle erkannt wird.** Eine Ausgangsstelle
`<n>` gilt als beschritten, wenn die Spur eine Zeile enthält, die auf
`^\++<n>:exit [0-9]+$` (Ausstieg) beziehungsweise auf
`^\++<n>:blockieren_mit_zaehlung ` (Aufrufstelle) passt. Der Ausdruck lässt
**ein oder mehr** `+` zu, damit der Erkennungsteil auch dann trägt, wenn der Bau
den zweiten Weg gehen muss. Im Funktionsrumpf trägt `LINENO` die Dateizeile
(belegt: `+346:exit 2`).

**4. Ausgabe und fail-closed.** Der Selbsttest gibt aus:
`Pfaddeckung: <n> Ausgangsstellen, <m> nicht beschritten, <a> mit Ausnahme`.
Gefordert ist `m = 0` (`Z-230`). Fehlschlag ist ausserdem: `n = 0`; eine
**leere** Spur; und eine Spur, die **weniger** Aufrufe ausweist, als das
Aufrufprotokoll des Selbsttests führt — die Zahl der Aufrufe misst `Z-231` über
die Zeilen `+<n>:set -uo pipefail` gegen die Zahl der protokollierten Aufrufe
(Fremdbeleg: 124 Aufrufe, 124 solche Zeilen). Ohne diese zweite Zeile bestünde
die Pfaddeckung auch dann, wenn die Spur gar nicht erst entstünde — dieselbe
Klasse wie `S11-04` bis `S11-06`.

**Was nicht in die Spur eingeht.** Aufrufe gegen eine **geschwächte** Kopie des
Gates (Schwächungslauf nach c) und die isolierten Läufe des Mutationsmodus
laufen in einem Kindprozess mit eigenem Protokoll; sie gehen **weder** in die
Spur der Pfaddeckung **noch** in die Invarianten `Z-194` bis `Z-197` ein. Sonst
belegte ein Aufruf gegen ein verändertes Gate eine Ausgangsstelle des echten.

**5. Die geschlossene Liste der zulässigen Ausnahmegründe.** Eine nicht
beschrittene Ausgangsstelle ist ausschliesslich mit einem dieser drei Gründe
zulässig:

1. Die Ausgangsstelle verlangt eine Eigenschaft des **Wirtssystems**, die der
   Prüfaufbau nicht stellen kann (etwa ein Dateisystem, auf dem `/tmp` nicht
   beschreibbar ist).
2. Die Ausgangsstelle ist nur über einen **Wettlauf** erreichbar, den der
   Prüfaufbau nicht deterministisch herstellen kann.
3. Die Ausgangsstelle ist im Gate **nachweislich unerreichbar** (toter Zweig).
   Dann ist sie zu **entfernen**, nicht auf Dauer auszunehmen; die Ausnahme gilt
   bis zur Entfernung und nennt den Backlog-Posten.

**Heute soll keine Ausnahme nötig sein**, und nach der Feststellung des
Koordinators ist auch keine nötig: alle zwölf offenen Ausgangsstellen sind mit
Attrappen im Prüfaufbau herstellbar. **Ort einer Ausnahme** ist die versionierte
Datei `.claude/hooks/dod-gate-pfadausnahmen.txt` neben der Liste der
terminierten Lagen — je Zeile die **Zeilennummer**, der **Wortlaut** der
Ausgangsstelle ohne führenden Leerraum, die **Grundnummer** 1 bis 3 und die
Begründung, durch Tabulator getrennt. Die Datei wird mit der Umsetzung
**angelegt und bleibt ohne Ausnahmezeile**; **fehlt** sie, ist der Lauf ein
Fehlschlag, damit ihr Verschwinden nicht als "keine Ausnahmen" gelesen wird.
Eine Zeile ohne Grundnummer aus der Liste, mit leerer Begründung oder mit einem
Wortlaut, der an der genannten Zeilennummer nicht steht, ist ein **Fehlschlag**.
Zusätzlich ist jede Ausnahme in diesem Abschnitt als Fortschreibung zu
begründen; eine Ausnahme allein in der Datei ist unzulässig. Dass eine
eingetragene Ausnahme die Sollmenge verkleinert, ist gewollt und sichtbar — sie
steht in einer versionierten Datei und im Pull Request.

**6. Der Sperrpfad wird über eine `flock`-Attrappe hergestellt, nicht real
abgewartet.** Zeile 584 ist erreichbar, wenn `flock -w 120` fehlschlägt, weil
ein anderer Lauf die Sperre hält.

| Option | Bewertung |
|---|---|
| (a) **Real**: ein zweiter Prozess hält die Sperre länger als 120 s | Ehrlich, aber unverhältnismässig: 120 s je Normallauf und noch einmal im isolierten Lauf des Mutationsmodus, für einen Pfad, dessen Gegenstand nicht die Wartezeit ist |
| (b) **`flock`-Attrappe im Werkzeugkasten**, die `-w 120` auf eine kurze Wartezeit umschreibt, während ein zweiter Prozess die Sperre **wirklich** hält | **Gewählt.** Der Fehlschlag von `flock` ist echt, nur die Wartezeit ist verkürzt. Vorbild ist `WERKZEUGKASTEN_SCHNELLER_TIMEOUT`, der `timeout -k 10 600` auf `-k 1 2` umschreibt, mit derselben Begründung: geprüft wird die **Auswertung im Gate**, nicht das Werkzeug |

Der Preis der Attrappe ist benannt und wird bezahlt: Dass im Gate **120 s**
stehen und nicht ein anderer Wert, misst der Fall nicht mehr. Deshalb tritt eine
**statische Zeile** daneben, `Z-221` — der `flock`-Aufruf des Gates nennt die
Wartezeit 120 —, gebaut nach dem Vorbild von `Z-181`. Ohne sie wäre die
Verkürzung im Prüfaufbau eine Lücke im Nachweis.

**7. Zwölf neue Fälle, je mindestens eine Zeile.** Für die vier unbeschrittenen
Ausstiege: Rückgabewert 2 (`Z-209`, `Z-212`, `Z-215`, `Z-218`), dazu die
Meldungsform und die Nichtzählung nach e). Für die acht unbeschrittenen
Aufrufstellen je eine Zeile mit dem **Schlüssel in der Zählerdatei** (`Z-222`
bis `Z-229`), gebaut wie `Z-200` bis `Z-208`. Weil mehrere dieser Zeilen
denselben Schlüssel erwarten (`GATE mktemp` dreimal, `KETTE ausgabe-unlesbar`
fünfmal), ist die Mutation je Zeile **pfadgenau** — der Schlüssel wird allein an
dieser Aufrufstelle umbenannt, adressiert über den unmittelbar vorangehenden
Meldungstext, wie bei `Z-182` bis `Z-184`. Ohne das wären die acht Zeilen
untereinander nicht trennscharf.

*(Nachtrag vom 2026-09-07 aus der Zwischenkontrolle nach Phase 1, Befund
`SST-P1-09`, Fremdbeleg des Static Software Testers: Der Fall zu `Z-209` nannte
zuerst das Ereignis `Stop`. Das ist am Gegenstand **nicht herstellbar** — das
Gate prüft die Eingabe in den Zeilen 118 bis 121 und beendet dort, und das
Ereignis liest es erst in Zeile 124 aus dem JSON; eine Eingabe, die kein JSON
ist, trägt kein Ereignis. Die Fallspalte von `Z-209` ist entsprechend
berichtigt und trägt den Vermerk in der Herkunftsspalte; `Z-210` und `Z-211`
verweisen mit "Derselbe Fall wie `Z-209`" und bleiben unverändert. Die
Zusicherung ist unberührt: gemessen wird weiterhin der Rückgabewert 2.)*

**8. Die Zeile für die Pfaddeckung selbst.** `Z-230`: Kanal `selbsttest` — die
Auswertung ist eine mechanische Lesung des Selbsttests ohne eigenen Gate-Aufruf
(6.12.26 a in der Fassung vom 2026-09-06) —, Prädikat `gleich`, gemessen an
**einem** Wert: der Zahl der nicht beschrittenen Ausgangsstellen, die genau 0
sein muss. Die Mindestzahl `n > 0` misst `Z-260` (jede Deckungszeile mit einer
Sollmenge 0 ist ein Fehlschlag), die Spurmenge `Z-231`. Damit trägt jede der
drei Zeilen genau eine messbare Zusicherung, und die Bindungsregeln aus
6.12.27 b sind eingehalten ("Rückgabewert N", "Stand N", "nennt als Wert genau
X" binden `gleich`; "führt … nicht" bindet `fehlt`).

**Die Mutation zu `Z-230` und wie der Mutationsmodus sie prüft.** Mutation:
hinter `set -uo pipefail` wird eine **nie erreichbare** Ausgangsstelle
eingefügt (`if false; then exit 2; fi`). Sie greift, weil die Erhebung der
Sollmenge **an der mutierten Kopie** stattfindet, gegen die der Lauf auch
ausgeführt wird: Die Kopie führt dann 41 Ausgangsstellen, von denen eine nie
beschritten wird, und `m` steigt auf 1. — Der isolierte Lauf des
Mutationsmodus führt nach S10-10 nur **eine** Fallfunktion aus, und eine
Pfaddeckung über alle Ausgangsstellen kann sich darin nicht selbst herstellen.

| Weg | Bewertung |
|---|---|
| (i) Die Fallfunktion zu `Z-230` **erkennt am leeren Aufrufprotokoll**, dass sie isoliert läuft, und führt dann die ganze `FALL_REIHENFOLGE` **im eigenen Prozess** gegen die mutierte Kopie aus, bevor sie die Spur auswertet | **Gewählt.** Ohne Änderung an der Sperrlogik; Dauer rund 42 s. Bedingung: `FALL_REIHENFOLGE` muss in den **Vorspann** wandern, vor `::VORSPANN-ENDE::`, damit der Kindprozess sie kennt |
| (ii) Die Fallfunktion ruft den **Selbsttest als Kindprozess im Normalmodus** auf, mit `GATE_UEBERSCHREIBUNG` auf die mutierte Kopie | **Abgelehnt.** Am gebauten Bestand nicht ausführbar: Der Selbsttest hält für seine ganze Laufzeit eine exklusive, nicht wartende Sperre (`flock -n`) unter `/tmp`; ein zweiter — auch ein verschachtelter — Aufruf endet dort sofort mit "Selbsttest laeuft bereits" und Rückgabewert 3, bevor irgendetwas läuft. Die Sperre hält der **äussere** Prozess; der isolierte Kindlauf schliesst den ererbten Deskriptor ausdrücklich. Der Weg verlangt eine Änderung an der Sperrlogik — und wäre damit die zweite Stelle für dieselbe Aussage (6.2.2, 6.12.26 f Punkt 10) |

**Entscheid: (i).** *(Berichtigt am 2026-09-07 nach einem Befund des
Koordinators am gebauten Selbsttest, Zeilen 54 bis 58 und 4245 bis 4249,
Fremdbeleg: Der zuerst geschriebene Weg (ii) ist an der Sperre nicht
ausführbar.)* Der Kanal bleibt `selbsttest` — die Auswertung ist in beiden Modi
dieselbe mechanische Lesung der Spur ohne eigenen Gate-Aufruf, und sie stützt
sich nicht mehr auf einen zweiten Selbsttestaufruf. Dass die Fallfunktion damit
alle Fälle braucht, ist kein Nachteil, sondern die Sache selbst: Eine
Pfaddeckung über **alle** Ausgangsstellen kann nur bestehen, wenn alle Fälle
gelaufen sind. Der Bau meldet die Dauer des isolierten Laufs; **`Z-252` ist
davon nicht betroffen**, weil seine Fallfunktion die Grammatikfälle selbst
aufruft und keinen zweiten Selbsttestaufruf braucht.

**c) (a2) Grammatik am Gegenstand — Schwächungen des `marken_muster`**

| | |
|---|---|
| **Vorher galt** | Die Grammatikdeckung hält die **Elementtabelle** aus 6.12.7 gegen die Prüftabelle: je Element mindestens eine verneinende Zeile. Die Tabelle zählt auf, **woraus** die Marke besteht, nicht, auf **wie viele Arten** ein Element verletzt werden kann — belegt an `DT11-01` bis `DT11-05`: fünf weitere Verstossformen an Elementen, die eine Zeile **haben**, alle unerkannt |
| **Jetzt gilt** | Die Sollmenge sind **Schwächungen des `marken_muster`**, mechanisch aus dem Muster erzeugt nach einer geschlossenen Liste von Umformungen je Musterelement. **Jede wirksame Schwächung** muss mindestens eine Zusicherung fallen lassen. Die Deckung ist damit **relativ zum Muster** statt zur Aufzählung |

**1. Woher das Muster kommt.** Aus dem Gate, gelesen wie in `fall_z199`
(`sed -n "s/^marken_muster='\(.*\)'$/\1/p"`), **nicht** im Selbsttest
wiederholt — sonst stünde dieselbe Grammatik an drei Stellen (6.2.2, so schon
6.12.27 j Punkt 5). Ist die Lesung leer, ist der Lauf ein **Fehlschlag**
(`Z-259`, Befund `S11-04`).

**2. Die Zerlegung in Elemente.** Das Muster wird für **genau diesen
Musterdialekt** zerlegt — Anker, Literale mit `\(`/`\)`-Maskierung,
Zeichenklassen, Gruppen mit Alternativen, Quantoren `+` und `?`. Die Zerlegung
in Lesereihenfolge (Grundlage: Erhebung des Koordinators, hier als geschlossene
Liste festgelegt):

| Nr. | Element | Art |
|---|---|---|
| 1 | `^` | Anker |
| 2 | `::LAGE ` | Literal |
| 3 | `([^ ]+)` Lauf-Kennung | Gruppe mit Zeichenklasse und Quantor |
| 4 | ` ` | Literal |
| 5 | `([^ ]+)` D-Nummer | Gruppe mit Zeichenklasse und Quantor |
| 6 | ` ` | Literal |
| 7 | `([^ ]+)` Ziel | Gruppe mit Zeichenklasse und Quantor |
| 8 | ` ` | Literal |
| 9 | `(A_OK\|A_FAIL\|B\|C)` Lage | Gruppe mit Alternativen |
| 10 | `( FEHLT=([^ :]+))?` | optionale Gruppe mit Zeichenklasse und Quantor |
| 11 | `( (SCHWELLE=[^ :]+\|OHNE_SCHWELLE))?` | optionale Gruppe mit Alternativen |
| 12 | `:: ` | Literal |
| 13 | `\(rueckgabewert=` | Literal |
| 14 | `(-?[0-9]+)` | Gruppe mit Zeichenklasse und Quantor |
| 15 | `\)` | Literal |
| 16 | `$` | Anker |

Die Zerlegung ist im Selbsttest **mechanisch nachvollziehbar**: gelesen wird von
links, ein `^` oder `$` am Rand ist ein Anker, eine öffnende runde Klammer ohne
vorangehenden Rückwärtsstrich beginnt eine Gruppe (mit `?` dahinter eine
optionale), `\(` und `\)` sind Literalzeichen, `[` beginnt eine Zeichenklasse,
alles Übrige ist Literal. Weicht die Zerlegung von dieser Tabelle ab, ist das
ein **Befund** und zu melden — dann hat sich das Muster geändert, und dieser
Abschnitt ist fortzuschreiben.

*(Nachtrag vom 2026-09-07, Befund `SST-P3-05` der Zwischenkontrolle nach Phase 3,
Fremdbeleg: Der Regel oben fehlt ein Satz. **Ein Literallauf endet auch an einer
Escape-Grenze** — vor `\(` und vor `\)` beginnt ein neues Element, und ein
maskiertes Klammerzeichen bildet mit dem folgenden Literaltext keinen
gemeinsamen Lauf. Ohne diesen Satz ergäbe die Regel wörtlich umgesetzt **15**
Elemente, weil `:: \(rueckgabewert=` als **ein** Lauf gelesen würde, während die
Tabelle **16** verlangt. Der Bau ist tabellenkonform; berichtigt ist die Regel,
nicht die Tabelle.)*

**3. Die geschlossene Liste der Umformungen — genau die sechs des Entscheids.**

| Nr. | Umformung | Anwendbar auf | Mechanisch |
|---|---|---|---|
| U1 | **Anker entfernt** | Element 1 und 16 | `^` beziehungsweise `$` gestrichen |
| U2 | **Quantor `+` zu `*`** | jeder `+`-Quantor (Elemente 3, 5, 7, 10, 11, 14) | `+` durch `*` ersetzt |
| U3 | **Literal oder Gruppe optional** | jedes Literal (2, 4, 6, 8, 12, 13, 15) und jede **nicht** bereits optionale Gruppe (3, 5, 7, 9, 14) | Gruppe: `(…)` zu `(…)?`. Literal: (i) das **ganze** Literal in `(…)?`; (ii) das **erste** Zeichen optional; (iii) das **letzte** Zeichen optional. Bereits optionale Gruppen (10, 11) werden **nicht** ein zweites Mal optional |
| U4 | **Zeichenklasse geweitet** | jede Zeichenklasse (3, 5, 7, 10, 11, 14) | `[^ ]` zu `.`; `[^ :]` zu `[^ ]`; `[0-9]` zu `.` |
| U5 | **Alternative erweitert** | jede Alternativengruppe (9, 11) | Die Gruppe erhält zusätzlich die Alternative `[^ ]+` |
| U6 | **Leerraum vor dem Endanker** | Element 16 | `$` zu ` *$` |

Ergeben sich dabei zwei **zeichengleiche** Schwächungen (bei einzeichigen
Literalen fallen (i), (ii) und (iii) zusammen), zählt die Schwächung **einmal**.
Nach dieser Liste und vor der Entdopplung sind es **35** Schwächungen: U1 2,
U2 6, U3 18, U4 6, U5 2, U6 1. Die Zahl wird **nicht verdrahtet**, sondern
erhoben und gemeldet.

**Die benannte Grenze, ausdrücklich statt später entdeckt.** Zeichen **im
Inneren** eines Wortliterals (`::LAGE `, `\(rueckgabewert=`) werden nicht
einzeln optional gemacht. Der Grund ist nicht Bequemlichkeit: Erstes und
letztes Zeichen sind die **Nahtstellen** zum Nachbarelement, und dort entstehen
die Verstossformen, die eine Marke noch fast wohlgeformt aussehen lassen —
`DT11-01` und `DT11-02` sind genau das. Ein fehlender Buchstabe mitten in einem
Wortliteral ergibt ein **anderes Wort**; jede solche Schwächung brauchte eine
eigene Probemarke und eine eigene Zeile, und fünfzehn Zeilen für fünfzehn
Schreibfehler in `rueckgabewert` sind Aufzählung, nicht Deckung. Diese Grenze
ist als **Restlücke** zu führen (Backlog unter R3-Q-001).

**Die zweite benannte Grenze: die fremde Alternative.** Eine Schwächung, die
eine Alternativengruppe um ein **bestimmtes fremdes Literal** erweitert, ist nur
durch eine Probemarke mit **genau diesem** Literal zu erkennen. U5 erfasst die
**Klasse** (`|[^ ]+` nimmt jedes Wort an), nicht jedes Literal. Diese Lücke
wird nicht über eine Wiederholung des Musters im Selbsttest geschlossen — das
schliesst 6.2.2 aus —, sondern über die **Alternativendeckung**: `Z-253` hält
die Alternativen der Lage-Gruppe gegen die vier Wörter, die die Elementtabelle
6.12.7 in der **Spalte Element** der Zeile `LAGE` nennt, und `Z-254` hält die
**Zahl** der Alternativen der Schwellengruppe gegen die Zahl der
Backtick-Abschnitte in der **Spalte Element** der Zeile `SCHWELLE`. Gelesen wird
je die Spalte Element, nicht die ganze Zeile — die erste Spalte trägt das Kürzel
und die vierte den erwarteten Schlüssel, beide ebenfalls in Backticks. Damit fällt **jede** zusätzliche Alternative auf, auch die
mit einem Literal, das niemand vorhergesehen hat. Gemessen wird der ADR-Text
gegen den Gegenstand, nicht der Gegenstand gegen sich selbst.

**4. Die Probemarken.** Sie werden **mechanisch aus dem Muster** gebildet, nicht
von Hand gewählt:

1. Ein **Musterexemplar**: je Zeichenklasse ein zulässiges Zeichen, je
   Alternativengruppe die erste Alternative, alle optionalen Gruppen enthalten —
   nach dem heutigen Muster `::LAGE x x x A_OK FEHLT=x SCHWELLE=x:: (rueckgabewert=0)`.
2. Daraus **alle Einzeländerungen**: je ein Zeichen gelöscht; je ein Leerzeichen
   eingefügt; je ein Buchstabe eingefügt; je ein Zeichen verdoppelt; je ein
   ganzes Feld gelöscht (die drei Feldwerte, die beiden Zusätze und die
   Literale 2, 12, 13, 15).

Das ist mechanisch und **relativ zum Muster**; die fünf Fremdmutationen
`DT11-01` bis `DT11-05` sind sämtlich Einzeländerungen dieser Art (Fremdbeleg).
Ist die Probemarkenmenge leer, ist das über `Z-255` ein Fehlschlag (dann wäre
keine Schwächung wirksam).

**Nachtrag vom 2026-09-07 aus Phase 2 des Baus (Fremdbeleg des DevOps
Engineers, vom Koordinator übermittelt; diese Rolle hat nichts nachgemessen).**
Der erste Schwächungslauf gegen den **unveränderten** Bestand meldet
`35 Schwaechungen, 33 wirksam, 22 ohne fallende Zusicherung` (Dauer 95 s). Die
22 ungedeckten Schwächungen entsprechen **17 distinkten** Zielzeilen und weichen
von der Ableitung in Punkt 10 **nicht** ab; die Zerlegung liefert genau die 16
Elemente aus Punkt 2, und die Rekonstruktion ergibt wörtlich das Originalmuster.
**Zwei** Schwächungen sind nach dem Wortlaut oben dagegen **unwirksam**, obwohl
die Tabelle Zeilen für sie führt: U3 (i) an Element 9 (`Z-237`) und U4 an
Element 10 (`Z-240`). Der Grund liegt an der **Probemarkenmenge**, nicht am
Muster: Die Einzeländerungen fügen nur ein Leerzeichen oder einen Buchstaben
ein, **nie einen Doppelpunkt** — und U4 an Element 10 unterscheidet sich vom
Original genau am Doppelpunkt; und die "Feldlöschung" ist zwischen Feldwerten
(Wert gelöscht, Trennzeichen bleiben) und Zusätzen (ganze Spanne gelöscht)
uneinheitlich und nennt die **Lage** gar nicht.

**Entscheid: Die Bildung der Probemarken wird um zwei Regeln ergänzt.** Der
Wortlaut der Punkte 1 und 2 oben bleibt stehen (6.1.2); dazu treten:

3. **Je ein Zeichen eingefügt, das eine Zeichenklasse des Musters
   ausschliesst.** Die einzufügenden Zeichen werden **mechanisch aus den
   negierten Zeichenklassen** des Musters gelesen — heute das Leerzeichen (aus
   `[^ ]`) und der Doppelpunkt (aus `[^ :]`) —, je Einfügestelle eine Marke. Die
   Regel ist damit nicht auf zwei Zeichen festgelegt, sondern auf die Klassen,
   die das Muster führt: Ändert sich das Muster, ändert sich die Menge mit.
4. **Feldlöschung einheitlich als Löschung des realisierten Werts unter Erhalt
   der Trennzeichen**, für **alle** Gruppen mit Zeichenklasse oder Alternativen
   (Elemente 3, 5, 7, 9, 10, 11, 14) — **zusätzlich** zur bisherigen Löschung
   der **ganzen** optionalen Spanne bei 10 und 11. Die Lage ist damit
   eingeschlossen; die Löschung der Literale 2, 12, 13 und 15 bleibt, wie sie
   oben steht.

**Erwartete Wirkung: 35 von 35 wirksam**, `m` unverändert nach den Zeilen aus
Punkt 10. **Der Bau zieht die beiden Regeln in Phase 3 nach und meldet die
Zahlen**; weichen sie ab, ist das ein Befund und zu melden, nicht anzugleichen.
`Z-237` und `Z-240` bleiben unverändert und werden gebaut — sie fallen unter
ihrer eigenen Mutation; ohne die beiden Regeln verlangt die Deckung sie nur
nicht. **Keine neue Kennung**, keine Zeile der Tabelle geändert. Festgehalten
sei überdies, was der Bau meldet und was diese Rolle nicht bestreitet: `Z-238`
ist bereits durch `Z-176` gedeckt (das unter der erweiterten Alternative fällt);
die Zeile wird gleichwohl gebaut, weil eine Kennung nicht zurückgezogen wird,
nur weil ein zweiter Zeuge besteht (Punkt 10, letzter Absatz).

**5. Wirksam, und was mit einer unwirksamen Schwächung geschieht.** Eine
Schwächung ist **wirksam**, wenn sie mindestens eine Probemarke annimmt, die das
**unveränderte** Muster ablehnt. Das ist ein reiner Musterabgleich und kostet
zwei Läufe über die Probemarkendatei je Schwächung. Eine Schwächung **ohne**
solche Probemarke wird in der Ausgabezeile mitgezählt und **gemeldet**; sie ist
**kein Fehlschlag** — sie sagt allein, dass die Umformung an diesem Muster nichts
ändert, was die Probemarken sehen. Fehlschlag ist dagegen, wenn **keine**
Schwächung wirksam ist (`Z-255`): dann misst die ganze Deckung nichts.

**6. Wo gemessen wird, dass eine Zusicherung fällt: am Gate.**

| Option | Bewertung |
|---|---|
| (a) **Auf Musterebene** — es genügt, dass eine Probemarke einer bestehenden Grammatikzeile unter der Schwächung angenommen wird | Billig, aber ein Stellvertreter. Er unterstellt, dass eine angenommene Marke am Gate auch zu einem grünen Lauf führt. Für den Zeilenanfang ist das **belegt falsch**: Die eingebettete Marke scheitert schon am `awk`-Vorfilter, und `M08` allein am Muster war ein äquivalenter Mutant (6.12.27 j Punkt 5) |
| (b) **Am Gate** — die Grammatik-Fallfunktionen laufen gegen eine Gate-Kopie, deren `marken_muster` durch die Schwächung ersetzt ist | **Gewählt.** Gemessen wird, was die Zusicherung behauptet: dass eine Zeile **fällt**. Korrektheit vor Effizienz |

**Mechanik.** Die Grammatik-Fallfunktionen sind mechanisch bestimmt: alle
Kennungen, deren Fallspalte mit `Grammatik ` beginnt, in Tabellenreihenfolge.
Sie laufen in einem Kindprozess mit `GATE_UEBERSCHREIBUNG` auf die geschwächte
Kopie; die Schwächung gilt als **gedeckt**, sobald die erste dieser Kennungen
`FEHLGESCHLAGEN` meldet — danach bricht die Folge ab, denn gemessen ist
**Existenz**, nicht Zahl. Meldet keine, zählt die Schwächung als "ohne fallende
Zusicherung".

**Kosten, offen genannt.** Ein Gate-Aufruf kostet rund 0,3 s (Fremdbeleg: 124
Aufrufe in 41,6 s). Bei 35 Schwächungen und heute 12, nach diesem Abschnitt 32
Grammatikzeilen liegt der schlechteste Fall bei rund 35 × 32 × 0,3 s; mit dem
Abbruch bei der ersten fallenden Zusicherung ist der Regelfall ein bis drei
Aufrufe je Schwächung, also rund 20 bis 40 s. **Die tatsächliche Laufzeit meldet
der Bau**; wird sie unverhältnismässig, ist das ein Befund und eine
Fortschreibung, keine stille Kürzung der Sollmenge.

**7. Der Zeilenanfang wird an beiden Stellen geschwächt.** Das Gate ankert den
Zeilenanfang zweimal: im `awk`-Vorfilter der Übersichtszeilen (Zeile 858) und im
`marken_muster`. Eine Schwächung, die **Element 1 oder Element 2** betrifft,
wird deshalb **zusätzlich** auf das Vorfiltermuster `^::LAGE ` angewandt —
dieselbe Umformung, dieselbe Stelle im Muster —, genau so, wie die Mutation zu
`Z-198` auf beide Anker gestellt ist. Alle übrigen Schwächungen lassen den
Vorfilter unberührt. Ohne diese Regel wären sieben Schwächungen äquivalente
Mutanten und die Deckung meldete Lücken, die keine sind.

**8. Ausgabe und fail-closed.** Der Selbsttest gibt aus:
`Grammatikschwaechungen: <n> Schwaechungen, <w> wirksam, <m> ohne fallende Zusicherung`.
Gefordert ist `m = 0` (`Z-252`). Fehlschlag ist ausserdem: leeres Muster
(`Z-259`), `n = 0` (`Z-260`) und `w = 0` (`Z-255`).

**9. Die Zeile für die Deckung trägt kein Etikett.** `Z-252` misst **kein
einzelnes** Grammatikelement, sondern die Deckung über alle Schwächungen. Ein
Etikett `Grammatik <KUERZEL>: ` wäre unwahr — es würde der Grammatikdeckung als
Zeile für dieses Kürzel gelten, ohne dessen Verstoss zu messen. Die Etikettwache
"genau ein Etikett je Zeile" (S10-05) wird dadurch nicht berührt: Sie verbietet
**mehr als eines**, nicht **keines**. Dasselbe gilt für `Z-230`, `Z-231`,
`Z-253` bis `Z-255` und `Z-258` bis `Z-261`.

**Die Mutation zu `Z-252`.** In das `marken_muster` wird vor dem Abschluss eine
optionale, in der Elementtabelle 6.12.7 **nicht** geführte Gruppe
`( ZUSATZ=[^ ]+)?` eingefügt. Damit wächst die Sollmenge um Schwächungen an
einem Element, für das **keine** Grammatikzeile besteht — mindestens eine davon
ist wirksam und hat keine fallende Zusicherung, `m` steigt über 0, und `Z-252`
fällt. Der isolierte Lauf des Mutationsmodus braucht dafür die ganze
`FALL_REIHENFOLGE` **nicht**: Die Fallfunktion zu `Z-252` erzeugt die
Schwächungen und ruft die Grammatik-Fallfunktionen selbst auf.

*(Nachtrag vom 2026-09-07, Befund `S12-03` der statischen Prüfung, Fremdbeleg —
**die Mutation ist berichtigt, der Wortlaut oben bleibt als Stand davor stehen**,
6.1.2: Die eingefügte Gruppe lässt `Z-252` **nicht** über `m > 0` fallen,
sondern über die Wache "die Zerlegung liefert 17 statt 16 Elemente" (ausgeführt
belegt). Damit hätte die Aussage `m = 0` **keine** Mutation an ihrer eigenen
Verneinung — genau das, was 6.12.26 b verbietet. Neu lautet die Mutation: Der
`awk`-Vorfilter der Übersichtszeilen wird auf ein **strengeres** Muster gesetzt
(`^::LAGE ` um die drei Feldgruppen und die Lage-Alternativen ergänzt). Dann
erreichen die Probemarken zu **18** Schwächungen — verteilt über die Elemente
**1 bis 9**, darunter der entfernte Anker an Element 1 und die drei Formen von
`U3` an Element 2, die Punkt 7 zusätzlich auf den Vorfilter stellt — das
Vorfiltermuster gar nicht mehr, diese Schwächungen sind am Gate **äquivalente
Mutanten**, ihre Grammatikzeilen fallen nicht, `m` steigt über 0 (gemessen
`m = 18`) — und das `marken_muster` bleibt unberührt, sodass die Zerlegung
weiterhin 16 Elemente liefert. Die Zeile `Z-252` ist in der Spalte Mutation und
in der Herkunftsspalte berichtigt; Fall, Kanal, Prädikat und Zusicherung bleiben
unverändert. Die Wache über die Elementzahl
bleibt, wo sie ist: Sie schützt die Zerlegung, nicht die Deckung. — Zahl und
Bereich der betroffenen Elemente sind am 2026-09-08 nach dem Befund `SNP-01`
berichtigt: Hier stand zuvor "die Probemarken der Elemente 3 bis 9"; ausgeführt
belegt sind 18 Schwächungen über die Elemente 1 bis 9. Die geforderte Wirkung
ist davon unberührt, der `sed`-Ausdruck der Mutation ist nicht angefasst; die
Einzelheiten stehen in j).)*

**10. Zwanzig neue Grammatikzeilen.** Sie decken die Schwächungsklassen ab, für
die heute keine fallende Zusicherung erkennbar ist. Fünf sind **belegt**
(`DT11-01` bis `DT11-05`, Fremdbeleg aus Runde 11); die übrigen sind aus der
Zerlegung **abgeleitet**, und ihr Ausgang — Rückgabewert 2 und Schlüssel
`KETTE ausgabe-unlesbar` — ist aus dem Aufbau des Gates abgeleitet und **beim
Bau zu bestätigen**, wie in 6.12.27 d. Weicht er ab, ist das ein **Befund** und
dieser Abschnitt fortzuschreiben, nicht die Prüfzeile an das Gate anzupassen.

| Zeile | Verstossform | Schwächung, die sie deckt |
|---|---|---|
| `Z-232` | einfacher Doppelpunkt statt `::` (`DT11-01`) | U3 (ii) an Element 12 |
| `Z-233` | kein Leerzeichen zwischen `::` und der Klammer (`DT11-02`) | U3 (iii) an Element 12 |
| `Z-234` | **leere** statt fehlender Lauf-Kennung (`DT11-03`) | U2/U3 an Element 3 |
| `Z-235` | leere D-Nummer | U2/U3 an Element 5 |
| `Z-236` | leeres Ziel | U2/U3 an Element 7 |
| `Z-237` | **leeres** Lage-Feld: zwischen Ziel und Abschluss steht nur ein Leerzeichen | U3 an Element 9 |
| `Z-238` | fremdes Wort an der Stelle des Schwellenzusatzes (`DT11-04`) | U5 an Element 11 |
| `Z-239` | Doppelpunkt im Wert von `SCHWELLE=` | U4 an Element 11 |
| `Z-240` | Doppelpunkt im Wert von `FEHLT=` | U4 an Element 10 |
| `Z-241` | ein zusätzliches Feld zwischen Präfix und Lage | U4 an den Elementen 3, 5, 7 |
| `Z-242` | kein trennendes Leerzeichen zwischen Ziel und Lage | U3 an Element 8 |
| `Z-243` | Präfix mit nur einem Doppelpunkt | U3 (ii) an Element 2, mit Vorfilter |
| `Z-244` | Präfix ohne trennendes Leerzeichen | U3 (iii) an Element 2, mit Vorfilter |
| `Z-245` | weder `::` noch Leerzeichen vor der Klammer | U3 (i) an Element 12 |
| `Z-246` | Rückgabewertklammer ohne öffnende Klammer | U3 (ii) an Element 13 |
| `Z-247` | Rückgabewertklammer ohne Gleichheitszeichen | U3 (iii) an Element 13 |
| `Z-248` | ohne schliessende Klammer | U3 an Element 15 |
| `Z-249` | ohne das Wort `rueckgabewert=` | U3 (i) an Element 13 |
| `Z-250` | Buchstabe statt Ziffer im Rückgabewert | U4 an Element 14 |
| `Z-251` | nachlaufendes Leerzeichen (`DT11-05`) | U6 an Element 16 |

**Was geschieht, wenn der erste Lauf weitere Lücken meldet.** Der erste Lauf der
Phase 2 läuft gegen den **unveränderten** Bestand, und seine Liste der
Schwächungen ohne fallende Zusicherung wird **gemeldet, bevor eine Zeile
geschrieben wird** — dieselbe Bauvorschrift wie `SST-B5-08`. Fehlende Zeilen
schreibt **diese Rolle** als Fortschreibung nach (die Kennungen laufen dann ab
`Z-262` weiter); überzählige Zeilen bleiben stehen, denn eine Kennung wird nie
zurückgezogen, weil sie sich als zusätzlicher Zeuge erweist. **Eine Schwächung
aus der Liste zu nehmen, um `m` auf 0 zu bringen, ist ausgeschlossen.**

**d) `DT11-06` — je Aufrufstelle einer Aussage eine Messung**

| | |
|---|---|
| **Vorher galt** | Die zweite Hälfte von `E21` ("gezählt wird die erste Abweichung, **genannt** werden alle") ist an **einer** der **drei** Aufrufstellen von `weitere_abweichungen_ausgeben` gemessen (Zeile 343, Block beim ersten und zweiten Mal, `Z-051` bis `Z-053`). Die Tabellenmutation trifft alle drei zugleich, weil sie die Funktion leert, und verdeckt damit, dass zwei Stellen ungemessen sind |
| **Jetzt gilt** | Je **Aufrufstelle** eine Messung. Neu sind `Z-256` (Block beim dritten Mal, Zeile 334) und `Z-257` (Block ab dem vierten Mal, Zeile 321), je mit dem Etikett `Aussage E21: `, Kanal `stderr`, Prädikat `enthaelt`. Der Fall stellt in beiden Fällen dieselbe Lage her: eine Kettenausgabe mit `A_FAIL`, **zwei** ungedeckten Lagen C und `D19 VERLETZT` |

**Die Mutation ist pfadgenau.** Der Aufruf von `weitere_abweichungen_ausgeben`
wird **allein** in dem betroffenen Block entfernt, adressiert über den
unmittelbar vorangehenden Meldungstext — dieselbe Bauart wie bei `Z-182` bis
`Z-184`. Nur so sind die drei Zeilen untereinander trennscharf; die bestehende
Mutation zu `Z-051` (die Funktion selbst geleert) bleibt, wie sie ist, und trifft
weiterhin alle drei.

**Die Sollmenge wird aus dem Gate erhoben.** `Z-258` hält die Zahl der
Aufrufstellen von `weitere_abweichungen_ausgeben` im Gate (heute 3, Fremdbeleg)
gegen die Zahl der **verschiedenen Fallfunktionen**, die eine Zusicherung mit
dem Etikett `Aussage E21: ` prüfen. Der Weg über die **Spur** — jede
Aufrufstelle in einem Aufruf beschritten, dessen Fehlerausgabe von einer
E21-Zeile gemessen wird — wäre genauer, verlangt aber eine Verknüpfung von
Messhülle und Aufrufnummer, die heute nicht besteht; er ist deshalb **nicht**
gewählt, und die Ungenauigkeit ist benannt: Gemessen ist, dass es **so viele
Fälle wie Aufrufstellen** gibt, nicht, dass jeder Fall genau eine andere Stelle
beschreitet. Fällt die Zahl beim Bau auseinander, weil zwei E21-Zeilen in
derselben Fallfunktion liegen, ist das ein **Befund**: Die Zeilen sind dann auf
verschiedene Fallfunktionen zu verteilen, nicht die Zusicherung anzupassen.
Fail-closed gegen eine leere Erhebung ist `Z-260`.

**e) `DT11-11` — die Gate-Berichtigung, ohne Verhaltenswechsel**

| | |
|---|---|
| **Vorher galt** | Vier Blockpfade enden mit Rückgabewert 2, **ohne** dass die Fehlerausgabe `Schluessel: ` nennt: ungültiges JSON (Zeile 119/120), unbekanntes Ereignis (127/128), kein bestimmbarer Arbeitsbaum (429/430) und die belegte Sperre (582 bis 584). Die Invariante `Z-196` (`A05`) erreicht sie nicht, weil der Selbsttest sie nie aufruft — Befund am **Original**, ohne Mutation |
| **Jetzt gilt** | Alle vier tragen die einheitliche Meldungsform aller übrigen Blockpfade: `dod-gate: BLOCKIERT. Schluessel: <Schluessel>. <Text>` — dieselbe Berichtigung wie für `GATE jq` in 6.12.27 j Punkt 9. **Rückgabewert, Reihenfolge und Zählung bleiben unverändert** |

**1. Die vier Schlüssel — Entscheid und Begründung.** 6.12.4 führt für diese vier
Lagen heute keinen Schlüssel. Zwei Wege standen offen:

| Weg | Bewertung |
|---|---|
| (a) Schlüssel **ausserhalb** von 6.12.4, allein in der Meldung, wie es `GATE jq` vormacht | Abgelehnt. Die **Gegenrichtung** der Schlüsseldeckung (6.12.27 c) hält jeden erwarteten Schlüssel der Prüftabelle gegen 6.12.4; ein Schlüssel, den 6.12.4 nicht führt, wäre ein "fremder Schlüssel" und liesse den Lauf rot werden. Ein Schlüssel, den der Gegenstand trägt und die Festlegung nicht kennt, ist überdies genau die Lage, die V12 verbietet |
| (b) **Nachtrag in 6.12.4** mit vier neuen Schlüsseln | **Gewählt.** Die vier Lagen sind Klassifizierungen wie die vierzehn übrigen; sie gehören in die Tabelle, die sagt, wie das Gate eine Beobachtung in einen Schlüssel übersetzt |

Die vier Schlüssel lauten `EINGABE json`, `EINGABE ereignis`, `EINGABE baum`
und `SPERRE belegt`. Sie tragen **bewusst** nicht den Stamm `GATE`: Dieser Stamm
heisst nach 6.12.4 "ein Prüfmittel des Gates fehlt", und keine der vier Lagen
ist das. Der Nachtrag steht in 6.12.4; die Schlüsseldeckung führt danach
**18** Schlüssel statt 14, und jeder der vier hat eine Zeile (`Z-210`, `Z-213`,
`Z-216`, `Z-219`).

**2. Gezählt wird an diesen vier Pfaden nicht — und `E12` wird dadurch nicht
umgeschrieben.** Die drei Vor-Eingabe-Pfade **können** nicht zählen: Die
`session_id` ist dort noch nicht gelesen beziehungsweise die Eingabe unlesbar,
und der Name der Zählerdatei hängt an ihr. Zeile 430 liegt nach dem Aufbau der
Zählung und **könnte**; sie zu zählen wäre aber ein Verhaltenswechsel, und
dieser Nachtrag ändert kein Verhalten. Für den Sperrpfad gilt dasselbe. Damit
blockieren **fünf** Pfade ausserhalb der Zählung: `GATE jq` und diese vier.

Die Aussage `E12` lautet: "`GATE jq` ist der **einzige** Block, der nicht
gezählt wird." Sie war schon **vor** diesem Abschnitt enger als das Gate — die
vier Pfade blockieren seit dem Bau, ohne zu zählen; unbemerkt blieb es, weil sie
keinen Schlüssel trugen. Mit den vier Schlüsseln wird der Widerspruch sichtbar.
Er wird **nicht** durch Umschreiben von `E12` aufgelöst (6.1.2), sondern durch
eine neue, vollständige Aussage: **`E23`** nennt alle fünf nicht gezählten
Blockpfade und verlangt, dass an keinem von ihnen eine Zählerdatei entsteht.
`E12` bleibt im Wortlaut stehen und erhält den Vermerk, dass `E23` sie
präzisiert; `E13` — jeder **andere** Block mit Schlüssel `GATE <Prüfmittel>`
zählt — bleibt unberührt wahr. Gemessen wird `E23` an **allen vier** neuen
Pfaden (`Z-211`, `Z-214`, `Z-217`, `Z-220`), nicht an einem stellvertretend;
`GATE jq` misst unverändert `Z-192`.

**3. Der Wortlaut der vier Meldungen.** Geändert wird je die **erste** Zeile;
Folgezeilen mit nächstem Schritt bleiben, wo sie heute stehen.

| Pfad | Neuer Wortlaut der ersten Meldungszeile |
|---|---|
| Zeile 119 | `dod-gate: BLOCKIERT. Schluessel: EINGABE json. Die Eingabe auf der Standardeingabe ist kein gueltiges JSON. Fail-closed.` |
| Zeile 127 | `dod-gate: BLOCKIERT. Schluessel: EINGABE ereignis. Unbekanntes oder von diesem Gate nicht bedientes Ereignis '$ereignis'. Fail-closed (keine Fortsetzung ohne Pruefung).` |
| Zeile 429 | `dod-gate: BLOCKIERT. Schluessel: EINGABE baum. Weder CLAUDE_PROJECT_DIR noch das Eingabefeld 'cwd' ergeben einen bestimmbaren Arbeitsbaum. Fail-closed.` |
| Zeile 582 | `dod-gate: BLOCKIERT. Schluessel: SPERRE belegt. Ein anderer Lauf haelt die Sperre fuer diesen Baum seit mehr als 120 s. Baum: $baum.` |

**Kein Verhaltenswechsel.** Rückgabewert 2, Reihenfolge der Prüfungen und die
Nichtzählung bleiben an allen vier Stellen, wie sie sind; die zweite Zeile des
Sperrpfades ("naechster Schritt …") bleibt unverändert stehen. **Am Gate ist aus
diesem Abschnitt genau diese eine Berichtigung vorzunehmen** — vier Meldungszeilen
— und sonst nichts.

**4. Die Gegenstandsdeckung erfasst diese vier Schlüssel nicht, und das ist eine
benannte Grenze.** Sie erhebt die Literale aus dem Gate über die **ersten
Argumente** von `blockieren_mit_zaehlung` und über Zuweisungen an
`*_schluessel`. Keiner der vier Pfade läuft über `blockieren_mit_zaehlung`. Die
Deckung bleibt damit bei **24** Literalen — dieselbe Lage und dieselbe
Begründung wie bei `GATE jq` in 6.12.27 j Punkt 3: gedeckt sind die vier über
6.12.4, über die Schlüsseldeckung und über je eine eigene Zeile. Bildet der Bau
die Meldungen über eine Zuweisung an eine `*_schluessel`-Variable, fallen sie in
die Erhebung; auch dann besteht die Deckung, weil je Schlüssel eine Zeile mit
dem Literal in Backticks vorliegt.

**f) `S11-04` bis `S11-06` — die bestehenden Deckungen fallen fail-closed aus**

| | |
|---|---|
| **Vorher galt** | Eine Deckung besteht **leer**, wenn ihr Lesen misslingt: `Z-199` besteht bei leerem `marken_muster` (ein leeres Muster trifft jede Zeile, `S11-04`); Gegenstands- und Grammatikdeckung haben weder eine Mindestzahl noch eine Gegenrichtung (`S11-05`, `S11-06`) — `n = 0` bestünde |
| **Jetzt gilt** | Drei Zeilen schliessen die Klasse: `Z-259` verlangt, dass die Lesung des `marken_muster` einen **nicht leeren** Wert liefert; `Z-260` verlangt, dass **keine** Deckungszeile der Zusammenfassung als erste Zahl 0 nennt; `Z-261` verlangt, dass die Grammatikdeckung **0 fremde Etiketten** meldet |

**Weshalb eine einzige Zeile für alle Mindestzahlen.** `Z-260` misst den Block
der Deckungszeilen als Ganzes: Jede Zeile der Form `<Name>: <Zahl> …`, deren
erste Zahl 0 ist, ist ein Fehlschlag. Das deckt Schlüssel-, Grammatik-,
Aussagen- und Gegenstandsdeckung, die neue Pfaddeckung, die Schwächungen und
jede Deckung, die später hinzukommt — ohne dass jemand daran denken muss. Eine
Zeile je Deckung wäre siebenmal dieselbe Messung und bliebe beim nächsten
Zuwachs zurück.

*(Präzisierung vom 2026-09-07 nach den Befunden `S12-01` und `S12-02`,
Fremdbeleg: **Gemessen wird der Block, wie er ausgegeben wird.** Der Block der
Deckungszeilen wird **einmal** erzeugt, daraus ausgegeben **und** geprüft, und
`Z-260` misst ihn **nach der letzten** Deckungszeile; jede Deckung registriert
ihre Zahlen in diesem Block, auch die Aufrufstellendeckung zu `E21` aus d).
Sonst misst die Wache ein Feld, das einen Teil der Zeilen nicht enthält, und
eine Deckung mit leerer Sollmenge besteht unbemerkt — beides ausgeführt belegt.
Das ist eine Präzisierung des Messumfangs, keine Änderung der Zusicherung; der
Wortlaut von `Z-260` und `Z-258` bleibt unverändert, behoben wird im Bau.)*

**Die Gegenrichtung der Grammatikdeckung** ist neu und wird gebaut: Jedes
Etikett `Grammatik <KUERZEL>: ` muss ein Kürzel der Elementtabelle 6.12.7
nennen; die Ausgabezeile lautet künftig
`Grammatikdeckung: <n> Kuerzel, <m> ohne Zeile, <f> fremde Etiketten`, und
`Z-261` verlangt `f = 0`. Ohne sie wäre ein Tippfehler im Kürzel eine stille
Nichtdeckung — dieselbe Begründung wie in 6.12.25 a für die Kennungen und in
S10-05 für die Aussagen.

**Die Gegenrichtung der Gegenstandsdeckung wird nicht gebaut, und weshalb.**
Sie würde verlangen, dass jeder Backtick-Abschnitt der Spalte Zusicherung, der
mit einem Stamm der Schlüssel beginnt, auf ein Literal des Gates passt. Das ist
bereits abgedeckt, und zwar doppelt: Die **Schlüsseldeckung** (6.12.27 c) hält
jeden erwarteten Schlüssel gegen 6.12.4 und meldet fremde Schlüssel; und ein
Schlüssel, den das Gate nicht mehr trägt, lässt entweder die Erhebung ein neues
Literal ohne Zeile finden (Umbenennung, `m > 0`) oder den **Fall selbst**
fehlschlagen, weil die Zählerdatei den erwarteten Schlüssel nicht trägt. Eine
dritte Prüfung derselben Sache wäre die zweite Stelle für dieselbe Aussage, die
6.2.2 verbietet.

**Mutationen dieser drei Zeilen.** `Z-259` und `Z-260` tragen echte Mutationen
am Gate (die Zuweisung des `marken_muster` umbenannt beziehungsweise auf die
leere Zeichenkette gesetzt). `Z-261` trägt **`keine` nach Grund 1**: Ein fremdes
Etikett entstünde nur in der **Tabelle** dieses ADR, und die Tabelle ist kein
Ziel einer Mutation (Ziele sind `dod-gate.sh`, `Makefile` und
`dod-gate-terminierte-lagen.txt`); die Zusicherung beschreibt die
Deckungsprüfung des Selbsttests selbst. Vorbild sind `Z-152` und `Z-153`.
Dasselbe gilt für `Z-231`, das die Vollständigkeit der Spur gegen das
Aufrufprotokoll hält — beides Messinstrumente des Selbsttests.

**Nachtrag vom 2026-09-08 — Messumfang von `Z-260`, Reihenfolge der Buchhaltung
und Vollständigkeit des Blocks (Auflösung des Widerspruchs aus der
Behebungsrunde)**

*Alle Befunde, Läufe und Zahlen in diesem Nachtrag sind Fremdbeleg des
Koordinators und des DevOps Engineers. Diese Rolle hat nichts ausgeführt, nichts
nachgemessen und bestätigt nichts; sie entscheidet und schreibt.*

**1. Der Widerspruch, statisch am Code belegt.** Die Präzisierung oben verlangt
zweierlei zugleich: `Z-260` misst den Block **nach der letzten** Deckungszeile,
und **jede** Deckung registriert ihre Zahlen in diesem Block. Drei
Deckungszeilen — `Deckung: …`, `Kanalabgleich: …`, `Praedikatabgleich: …` —
entstehen aber erst in der Buchhaltung der Zusammenfassung, und diese
Buchhaltung bildet ihre Zahlen aus der Menge der **bereits gemeldeten**
Zusicherungen. Daraus folgt ein echter Zirkel: Wird `Z-260` **nach** der
Buchhaltung gemessen, fehlt seine eigene Meldung in deren Zahlen, `Z-260` steht
in der Liste der Kennungen ohne Prüfung, die Deckung meldet einen Fehler und der
Normallauf endet mit Rückgabewert 2. Wird `Z-260` **vor** der Buchhaltung
gemessen, misst es einen Block ohne die drei dort erzeugten Zeilen — genau der
Mangel, den `S12-01` beanstandet hat. Belegt ist der erste Ausgang im Lauf vom
2026-09-07: `Kennungen der Tabelle OHNE Pruefung: Z-260`, `Deckung: 262
Kennungen in der Tabelle, 261 geprueft, 1 ohne Pruefung, 0 ohne Kennung`,
`Selbsttest: 261 von 261 Zusicherungen bestanden`, Rückgabewert 2.

**2. Zwei weitere Lücken derselben Klasse, ebenfalls statisch belegt.** Sie
gehören in dieselbe Entscheidung, weil sie dieselbe Ursache haben — zwei Quellen
für einen Block: (a) die drei genannten Zeilen werden weiterhin unmittelbar
ausgegeben und landen nicht im Feld, das `Z-260` abtastet; (b) das Feld, aus dem
die Zusammenfassung die Pfaddeckungszeile ausgeben soll, wird an keiner Stelle
des Skripts gefüllt und nur an einer Stelle gelesen — die Zeilen `Pfaddeckung:`
und `Grammatikschwaechungen:` erscheinen in der Ausgabe des Normallaufs deshalb
**überhaupt nicht mehr**, während die zugehörigen Zusicherungen `Z-230`,
`Z-231`, `Z-252` und `Z-255` laufen und bestehen. Eine Deckungszeile kann heute
also **spurlos verschwinden**, ohne dass irgendetwas fehlschlägt. Das ist die
Klasse aus `S11-04` bis `S11-06`, an einer neuen Stelle. Beide Lücken bestanden
nach der Rückrechnung des DevOps Engineers bereits vor seiner Einheit im
unversionierten Bauzustand.

**3. Zwei Begriffe, die der Bau bisher vermengt.** Der Entscheid unterscheidet:

- **Deckungszeile** — genau eine Zeile je Deckung, Form
  `<Etikett>: <Zahl> …`. Sie erscheint in **jedem** Lauf, auch im grünen. Sie
  ist der Gegenstand von `Z-260`.
- **Befundzeile** — entsteht nur, wenn eine Deckung etwas gefunden hat
  (`Kennungen der Tabelle OHNE Pruefung: …`, `Kanalabweichung: …`,
  `ABWEICHUNG Praedikat …`, `Pfaddeckung: nicht beschritten: …`). Ihre Zahl ist
  nicht fest, sie ist **nicht** Gegenstand von `Z-260`, und ihr Vorkommen fällt
  immer mit einem Befund und damit mit Rückgabewert 2 zusammen.

Nur Deckungszeilen gehören in den Block. Befundzeilen werden an ihrer Fundstelle
ausgegeben. Ausgenommen ist die Zeile `Pfaddeckung: nicht beschritten: …`, die
das Etikett der Pfaddeckung teilt und im Block stehen bleibt, wo sie heute steht.

**4. Geprüfte und verworfene Wege.**

| Weg | Warum nicht |
|---|---|
| `Z-260` als **Ausnahme** in die Deckung eintragen | Erzeugt genau die Klasse, die `S12-02` beanstandet: eine Prüfung, die unbemerkt nicht läuft. Eine Ausnahme ist unbedingt und dauerhaft; niemand prüft je nach, ob die ausgenommene Messung stattgefunden hat |
| `Z-260` **vor** der Buchhaltung messen | Kehrt zu `S12-01` zurück: gemessen wird ein Block, dem drei seiner Zeilen fehlen |
| Die drei Abgleichzeilen **aus dem Block nehmen** | `S12-01` zählt sie ausdrücklich zu den Blockzeilen; die Begründung oben (eine Zeile für alle Mindestzahlen) trüge dann für drei Deckungen nicht mehr |
| **Anmeldung mit Einlösepflicht**: `Z-260` wird vor der Buchhaltung als noch zu messen angemeldet, eine Schlusswache verlangt die Einlösung | Löst den Zirkel für die Spalte geprüft, **nicht** für den Kanal- und den Prädikatabgleich: Kanal und Prädikat einer noch nicht gemeldeten Kennung sind zum Zeitpunkt der Buchhaltung unbekannt, der Vergleich wird übersprungen und läuft unbemerkt nicht. Das ist wieder `S12-02`. Ihn zu schliessen verlangte dieselbe Nachbesserung wie der gewählte Weg, zusätzlich zu einem neuen Mechanismus |
| **Schrittprotokoll** der Zusammenfassung gegen eine Sollfolge | Verschiebt den Regress nur: die Prüfung des Protokolls ist selbst wieder ungedeckt. Zweite Buchführung für denselben Zweck, 6.2.2 |

**5. Entscheid — Messumfang.** `Z-260` misst am Block **die ersten Zahlen seiner
Zeilen** und sonst nichts. Das ist der Wortlaut der Zusicherung, hier
ausgesprochen: Eine Zeile fällt, wenn ihre erste Zahl 0 ist. Aus diesem
Messumfang folgt der zulässige Umgang mit der Buchhaltung, denn die erste Zahl
der drei Abgleichzeilen ist in allen dreien die **Zahl der Kennungen der Tabelle
6.12.19** und hängt an keiner Stelle davon ab, welche Zusicherungen bereits
gemeldet sind.

**6. Entscheid — Reihenfolge.** Die Buchhaltung wird in **zwei Erhebungen aus
einer einzigen Funktion** geführt. Die Zusammenfassung läuft in dieser Folge:

1. Pfaddeckung (meldet `Z-230`, `Z-231`, registriert ihre Zeilen).
2. Schlüssel-, Grammatik- und Aussagendeckung: Ausgabe **auffangen**, jede Zeile
   registrieren, Urteil übernehmen.
3. Gegenstandsdeckung Schlüssel: ebenso.
4. Buchhaltung, **erste Erhebung**: registriert die drei Abgleichzeilen und
   merkt sich ihre Plätze. Sie gibt **nichts** aus und liefert **kein** Urteil.
5. Blockdeckung nach Punkt 7: registriert ihre Zeile als letzte.
6. Messung von `Z-260` über den vollständigen Block; der Vektor der ersten
   Zahlen wird dabei festgehalten.
7. Buchhaltung, **zweite Erhebung (Einlösung)**: dieselbe Funktion, derselbe
   Eingang, jetzt mit der Meldung von `Z-260`. Sie **ersetzt** die drei Zeilen an
   ihren Plätzen, gibt die Befundzeilen aus und liefert als **einzige** das
   Urteil.
8. Wache über die Unveränderlichkeit: der Vektor der ersten Zahlen wird erneut
   gebildet und mit dem aus Punkt 6 verglichen.
9. Zählzeile `Selbsttest: N von M` aus der Menge der gemeldeten Kennungen, die
   jetzt vollständig ist.
10. **Einmalige** Ausgabe des Blocks aus dem Feld.
11. Rückgabewert.

Damit stammen die ausgegebenen Zahlen der drei Abgleichzeilen und das Urteil aus
**derselben** Erhebung. Die Ausgabe kann dem Rückgabewert nicht widersprechen —
das ist die Bedingung, an der der Lauf vom 2026-09-07 gescheitert ist. Die Zahlen
der ersten Erhebung erreichen die Ausgabe nie.

**7. Entscheid — Vollständigkeit des Blocks.** Der Block hat eine **Sollmenge**,
und sie steht hier, nicht im Skript allein. Die **Blockdeckung** hält sie in
**beide** Richtungen gegen die Etiketten der Zeilen im Feld; ein Etikett ohne
Zeile und ein fremdes Etikett sind je ein Befund und setzen das Urteil auf
Fehler. Etikett ist der Text vor dem ersten Doppelpunkt.

| Etikett | Ursprung | Erste Zahl | Pflicht im Normallauf |
|---|---|---|---|
| `Pfaddeckung` | Pfaddeckung | Ausgangsstellen | ja |
| `Grammatikschwaechungen` | Schwächungslauf | Schwächungen | ja |
| `Aufrufstellendeckung E21` | Fall zu `Z-258` | Aufrufstellen | ja |
| `Schluesseldeckung` | Schlüssel- und Grammatikdeckung | Schlüssel | ja |
| `Grammatikdeckung` | dieselbe | Kürzel | ja |
| `Aussagendeckung` | dieselbe | Kürzel | ja |
| `Gegenstandsdeckung Schluessel` | Gegenstandsdeckung | Literale | ja |
| `Deckung` | Buchhaltung | Kennungen der Tabelle | ja |
| `Kanalabgleich` | Buchhaltung | Kennungen der Tabelle | ja |
| `Praedikatabgleich` | Buchhaltung | Kennungen der Tabelle | ja |
| `Blockdeckung` | Blockdeckung | erwartete Etiketten | ja |
| `Musterlesung (Z-260)` | Fall zu `Z-260` | Funde | nein — nur im isolierten Lauf |

**Elf Pflichtetiketten.** Die Zeile der Blockdeckung lautet
`Blockdeckung: <n> Etiketten erwartet, <m> ohne Zeile, <f> fremde Etiketten, <z>
Zeilen im Block`. Ihre erste Zahl ist die Sollzahl `n`: Wird die Sollmenge
geleert oder umbenannt — die Klasse `S11-04` —, ist `n = 0`, und `Z-260` lässt
den Lauf daran fallen. Bleibt das Feld leer, ist `m = n`, und die Blockdeckung
lässt ihn fallen. Damit ist das stille Verschwinden einer Deckungszeile in beide
Richtungen geschlossen: Wer eine Deckung entfernt, muss die Zeile aus dieser
Tabelle streichen; wer eine hinzufügt, muss sie hier eintragen, sonst meldet die
Gegenrichtung ein fremdes Etikett. Dieselbe Mechanik wie bei 6.12.7 und 6.12.15,
angewandt auf den Block.

**8. Entscheid — fail-closed.** Vier Festlegungen, die zusammen tragen:

1. **Anfangswerte sind Fehler.** Das Urteil der Deckung beginnt bei Fehler; ein
   zweiter Merker beginnt bei nicht eingelöst. Rückgabewert 0 setzt voraus, dass
   die zweite Erhebung vollständig gelaufen ist und beide gesetzt hat. Fällt
   Punkt 7 der Folge aus, endet der Lauf mit 2, ohne dass jemand daran denken
   muss.
2. **Fehlt die Messung von `Z-260`**, sieht die zweite Erhebung die Kennung als
   ungeprüft, gibt die Befundzeile aus und liefert Fehler — Ausgabe und
   Rückgabewert sagen dann dasselbe.
3. **Fehlt die ADR-Datei oder bleibt die Tabelle leer**, ist die erste Zahl der
   drei Abgleichzeilen 0 und `Z-260` fällt; unabhängig davon greift die
   Gegenrichtung der Deckung und die bestehende Prüfung auf das Vorhandensein der
   Datei.
4. **Die gemessene Grösse darf sich zwischen Messung und Ausgabe nicht ändern.**
   Weicht der Vektor aus Punkt 8 der Folge von dem aus Punkt 6 ab, ist das ein
   Befund mit Nennung der Zeile und Rückgabewert 2. Diese Wache macht die
   Einlösung ehrlich: Sie behauptet nicht, dass sich nichts ändert, sie prüft es.
   Verschiebt eine spätere Fassung die Zahl der geprüften Kennungen an die erste
   Stelle der Zeile `Deckung:`, schlägt der Lauf fehl, statt still schwächer zu
   werden.

**9. Entscheid — eine Quelle, eine Ausgabestelle.** Der Block wird aus **einem**
Feld ausgegeben, an **einer** Stelle, nach der Messung. Jede weitere Ablage für
Deckungszeilen entfällt ersatzlos, insbesondere das heute nirgends gefüllte Feld
für die Pfaddeckungszeilen samt der Schleife, die es liest. Keine Deckungszeile
wird ausserhalb dieser einen Stelle ausgegeben. Der Kommentar am Kopf des
Skripts, der das heute schon behauptet, wird damit zutreffend; bis dahin ist er
unzutreffend und wird nicht als Beleg gelesen.

**10. Was dieser Nachtrag nicht ändert.** Der **Wortlaut von `Z-260` und `Z-258`
in der Tabelle 6.12.19 bleibt unverändert**; ebenso Kanal, Prädikat, Fall und
Mutation beider Zeilen. **Keine** Zusicherung kommt hinzu, keine entfällt, keine
wandert: Die Blockdeckung ist eine Deckung mit einer Zeile im Block, keine
Zusicherung mit einer Kennung. Die Zahlen aus j) Punkt 6 bleiben, wie sie dort
stehen — 263 Zeilen, 262 Zusicherungen, 264 Messhüllen, 262 Einträge in der
Mutationsdatei; an `scripts/dod-gate-mutationen.txt` ist nichts zu ändern. **Am
Gate ist nichts zu ändern** (j) Punkt 7), am `Makefile` und an der Liste der
terminierten Lagen ebenfalls nichts. Kein Entscheid `G1` bis `G17` und keiner
aus 6.12.23 bis 6.12.28 wird zurückgenommen; die Präzisierung oben wird
**ausgeformt**, nicht ersetzt, und ihr Wortlaut bleibt stehen (6.1.2). Die
Kernarchitektur aus 5.1, die Entscheide `A1` bis `A13`, der Modulschnitt aus
Abschnitt 4 und die Verankerung der Verfahrensgarantien bleiben unberührt; das
Gate steht an keiner Stelle zwischen Freigabe und Ausführung (5.2). Keine
D-Nummer wird vergeben. Nichts hier bereitet Gestrichenes vor (5.17, 5.18, 9.1,
5.10, 5.1). **Und nichts hier ist eine Freigabe oder eine Abnahme**: Die Abnahme
des Gates steht weiter aus, `O-25` bleibt offen.

**11. Was der gewählte Weg kostet, und was als Grenze bleibt.**

1. **Die Buchhaltung läuft zweimal.** Drei Schleifen über die Kennungen der
   Tabelle ein zweites Mal; gemessen an einem Normallauf von rund vier Minuten
   fällt das nicht ins Gewicht, es ist aber ein Preis und keine Null.
2. **Drei Zeilen des Blocks werden nach der Messung eingelöst.** Das ist der
   Punkt, an dem dieser Weg unbequem ist. Er ist zulässig, weil `Z-260` allein
   die ersten Zahlen misst, diese in den drei Zeilen die Zahl der
   Tabellenkennungen sind und Punkt 8.4 die Unveränderlichkeit **prüft** statt
   sie anzunehmen.
3. **`Z-260` erreicht keine Zeile ohne Zahl an erster Stelle.** Die drei
   Abbruchvarianten des Schwächungslaufs tragen an erster Stelle keine Zahl,
   sondern Text. Ob sie anderweitig gedeckt sind, stellt dieser Nachtrag nicht
   fest; die Feststellung gehört zur Verifikation und damit zum Static Software
   Tester (3.4). Als **benannte Grenze** festgehalten.
4. **Die Blockdeckung ist selbst nicht mutationsgedeckt.** Fällt sie ganz aus,
   fehlt ihre Zeile und niemand vermisst sie. Der Regress endet hier, und zwar
   bewusst: Ziel einer Mutation sind `dod-gate.sh`, `Makefile` und die Lagenliste,
   nicht der Selbsttest selbst (Grund 1, oben). Verankert ist die Kette
   stattdessen an `Z-260`, das in der Tabelle 6.12.19 steht und dessen Ausbleiben
   die Buchhaltung meldet.
5. **Die Blockdeckung gilt im Normallauf.** Der isolierte Einzelfall-Lauf des
   Mutationsmodus baut seinen Block selbst und führt sie nicht aus; dort dient
   der Block allein dazu, dass `Z-260` unter seiner Mutation fällt. Ebenfalls
   benannte Grenze.

**g) Neufassung von Teil 2 des Abnahmekriteriums (6.12.27 g) im Wortlaut**

Der folgende Wortlaut ersetzt **Teil 2** des Abnahmekriteriums aus 6.12.27 g.
Der bisherige Wortlaut bleibt dort als Stand davor stehen und wird nicht
umgeschrieben (6.1.2); er trägt einen Verweis auf diesen Buchstaben.

> **2. Eine Fremdmutationsrunde durchläuft ohne blockierenden Befund.**
> **Blockierend** ist allein eine Fremdmutation, die am **Gate** ein **falsches
> Grün** erzeugt — Rückgabewert 0, wo das unveränderte Gate 2 liefert, gemessen
> gegen einen echten Baum, einen Attrappenbaum oder eine Probemarke — **und**
> dabei **keine** Zusicherung der Tabelle 6.12.19 fallen lässt.
>
> **Nachrangig** und damit **kein** Abbruchgrund, sondern ein Posten für den
> Backlog unter R3-Q-001, sind: ein **falsches Rot** (das mutierte Gate
> blockiert, wo das unveränderte durchliesse), eine **abweichende Meldungsform**
> und ein **Rückgabewert ausser 0 und 2** beim Block. Diese Befunde werden
> vollständig berichtet und gezählt; sie halten die Abnahme nicht auf.
>
> Die vier Kategorien bleiben: **Schlüssel** (6.12.4), **Grammatik** (6.12.7),
> **Schwellen und Ereignisfolge** (6.12.9) und **Ausgabeform** (6.12.15).
> **Runde 12** verlangt **mindestens sechs** Fremdmutationen je Kategorie,
> **blind** gewählt: Die Wahl wird mit **Zeitmarke schriftlich festgehalten,
> bevor** `scripts/dod-gate-mutationen.txt` und die Tabelle 6.12.19 gelesen
> werden; eine **Nachwahl** ist unzulässig.
>
> **Runde 12 ist die letzte Fremdmutationsrunde.** Besteht sie, gilt der
> Selbsttest als abgenommen und die Abnahme des Gates wird vorgelegt. Ein
> falsches Grün aus Runde 12 wird **behoben**, **statisch nachgeprüft** und mit
> einer **gezielten Wiederholung** der betroffenen Fremdmutation belegt — eine
> **Runde 13 gibt es nicht**. Was danach bleibt, ist **dokumentierte
> Restlücke**: benannt in diesem Abschnitt, als Posten im Backlog geführt und in
> der Abnahmevorlage genannt.

**Teil 1 bleibt** und wird um die neuen Deckungen erweitert: Zu
`nicht_erkannt=0`, `wirkungslos=0`, Rückgabewert 0 in beiden Modi, der Deckung
in beide Richtungen, dem Kanal- und dem Prädikatabgleich, der Schlüssel-, der
Gegenstands-, der Grammatik- und der Aussagendeckung treten die **Pfaddeckung**
(`0 nicht beschritten`), die **Grammatikschwächungen** (`0 ohne fallende
Zusicherung`, `w > 0`), die **Aufrufstellendeckung zu `E21`** und die drei
fail-closed-Zeilen aus f). Alle enden bei jeder Abweichung ungleich 0.

**h) Zahlen und Bestand nach diesem Abschnitt**

**Neu sind 53 Zeilen `Z-209` bis `Z-261`**, fortlaufend und ohne Lücke; keine
bestehende Kennung wandert, keine wird umnummeriert, keine wird
zurückgezogen. Aufteilung: **23** zu b) (`Z-209` bis `Z-231`), **24** zu c)
(`Z-232` bis `Z-255`), **3** zu d) (`Z-256` bis `Z-258`), **3** zu f) (`Z-259`
bis `Z-261`).

| Grösse | Stand vorher (6.12.27 j Punkt 7) | Stand nach diesem Abschnitt |
|---|---|---|
| Zeilen der Tabelle 6.12.19 | 208 | **261** |
| Zusicherungen (ohne die zurückgezogene `Z-110`) | 207 | **260** |
| Messhüllen | 209 | **262** |
| Einträge in `scripts/dod-gate-mutationen.txt` | 207 (197 `sed`, 10 `keine`) | **260** (**248** `sed`, **12** `keine`) |
| Grammatikkürzel (6.12.7) | 11 | **12** (neu `TRENNUNG`) |
| Aussagenkürzel (6.12.9, 6.12.15) | 30 | **31** (neu `E23`) |
| Schlüssel aus 6.12.4 | 14 | **18** |
| Literale aus dem Gate (Gegenstandsdeckung) | 24 | **24**, unverändert (benannte Grenze, e) Punkt 4) |
| Ausgangsstellen (Pfaddeckung) | — | **40** (14 Ausstiege, 26 Aufrufstellen), erhoben |
| Schwächungen des `marken_muster` | — | **35** vor der Entdopplung, erhoben |
| Aufrufstellen zu `E21` | — | **3**, erhoben |

**Verteilung der 262 Messhüllen auf die Prädikate:** `gleich` **172**,
`enthaelt` **41**, `fehlt` **18**, `leer` **9**, `existiert` **8**, `einzelfeld`
**6**, `ausserhalb` **4**, `kleiner` **2**, `zeile-woertlich` **2**. Die 53
neuen Zeilen tragen `gleich` 40, `enthaelt` 6, `fehlt` 6, `existiert` 1; auf die
Kanäle verteilen sie sich mit `zaehler` 28, `selbsttest` 11, `stderr` 6, `rc` 4,
`datei` 4. Keine der neuen Zeilen ist mehrkanalig.

Die **zwei** neuen Einträge mit `keine` sind `Z-231` und `Z-261`, beide nach
**Grund 1** (die Zusicherung beschreibt den Selbsttest selbst); die zehn
bestehenden bleiben unverändert.

**Alle diese Zahlen sind vom Bau zu melden und von der statischen Prüfung zu
bestätigen**; weichen sie ab, ist das ein **Befund** und zu melden, nicht
anzugleichen. Die Zahlen aus 6.12.27 f, i und j sind der Stand davor und bleiben
stehen (6.1.2).

*(Nachgeführt am 2026-09-07 nach Phase 2 des Baus: Zu melden sind aus der Zeile
`Grammatikschwaechungen:` **beide** weiteren Zahlen — die Zahl der **wirksamen**
Schwächungen `w` und die Zahl der Schwächungen **ohne fallende Zusicherung**
`m`. Der erste Lauf gegen den unveränderten Bestand meldet 35/33/22
(Fremdbeleg); nach dem Nachtrag zu c) Punkt 4 und dem Bau der zwanzig neuen
Grammatikzeilen sind `w = 35` und `m = 0` erwartet. Auch die **Dauer** des
Schwächungslaufs ist zu melden — im ersten Lauf 95 s.)*

**Phasen — die drei des Sitzungsauftrags, mit einer begründeten Umordnung.** Der
Sitzungsauftrag sieht vor: Phase 1 Pfadspur und Pfaddeckung, Phase 2
Musterschwächungen und Grammatikdeckung, Phase 3 `DT11-06`, `DT11-11`, `S11-04`
bis `S11-06` und die Mutationen. Die **Gate-Berichtigung aus e) rückt in Phase
1**, und zwar zwingend: Sobald Phase 1 die vier heute unbeschrittenen Pfade
herstellt, fällt die Invariante `Z-196` (`A05`) am **unveränderten** Gate an
genau diesen Pfaden — das ist der Befund `DT11-11`. Ohne die Berichtigung kann
Phase 1 nicht grün enden (Feststellung des Koordinators, hier übernommen und
begründet).

| Phase | Inhalt | Zeilen |
|---|---|---|
| **1** | Gate-Berichtigung nach e); die vier Vor-Eingabe- und Sperrfälle samt Meldungsform und Nichtzählung; `flock`-Attrappe; Ausführungsspur; die acht Fälle an den Aufrufstellen; Pfaddeckung | `Z-209` bis `Z-231` |
| **2** | Zerlegung, Schwächungen, Probemarken, Schwächungslauf, Alternativendeckung, die zwanzig neuen Grammatikzeilen | `Z-232` bis `Z-255` |
| **3** | `DT11-06`, die drei fail-closed-Zeilen, Gegenrichtung der Grammatikdeckung, Mutationsdatei vollständig | `Z-256` bis `Z-261` |

Je Phase ein eigener Lauf beider Modi mit unveränderten Prüfsummen von Gate,
Selbsttest, Mutationsdatei, `Makefile`, Lagenliste und ADR vor und nach dem
Lauf; **Zwischenkontrolle durch den Static Software Tester nach Phase 1 und nach
Phase 3**. Der **erste** Lauf der Phase 2 läuft gegen den unveränderten Bestand,
und seine Liste der ungedeckten Schwächungen wird gemeldet, bevor eine Zeile
geschrieben wird (c) Punkt 10).

**i) Was dieser Abschnitt nicht ändert**

Kein Entscheid G1 bis G17 und keiner aus 6.12.23 bis 6.12.27 wird
zurückgenommen. **Keine bestehende Zeile der Tabelle 6.12.19 wird geändert**;
keine Kennung wandert, keine Zusicherung entfällt. `E12` bleibt im Wortlaut
stehen und wird durch `E23` präzisiert, nicht ersetzt; `E13` bleibt unberührt.
**Am Gate ist genau eine Berichtigung vorzunehmen** — die vier Meldungszeilen
nach e) —, und sie ändert **kein Verhalten**: Rückgabewert, Reihenfolge und
Zählung bleiben. Am `Makefile` ist **nichts** zu ändern. Die Kernarchitektur aus
5.1, die Entscheide A1 bis A13, der Modulschnitt aus Abschnitt 4 und die
Verankerung der Verfahrensgarantien bleiben unberührt; das Gate steht an keiner
Stelle zwischen Freigabe und Ausführung (5.2). Keine D-Nummer wird vergeben.
Nichts hier bereitet Gestrichenes vor (5.17, 5.18, 9.1, 5.10, 5.1).

**Und nichts hier ist eine Freigabe oder eine Abnahme.** Die **förmliche
Freigabe der Entscheidpunkte E-A bis E-K ist seit dem Merge vom 2026-09-07
erteilt** (Abschnitt 10) — das ändert dieser Abschnitt nicht, er hält es fest.
Die **Abnahme des Gates** ist davon getrennt und **steht aus**: Sie wird erst
nach **Runde 12** vorgelegt, und diese Rolle legt sie nicht vor. **O-25** bleibt
offen. Teil 1 des Abnahmekriteriums ist erfüllt; Teil 2 in der Fassung nach g)
ist **ungeprüft**, bis Runde 12 gelaufen ist.

**j) Runde 12 — die letzte Fremdmutationsrunde: ein blockierender Befund, und wie er geschlossen wird**

Die zwölfte Prüfrunde ist am 2026-09-07 gelaufen. **Alle Zahlen, Läufe und
Befunde sind Fremdbeleg**; diese Rolle hat nichts ausgeführt, nichts
nachgemessen und bestätigt nichts.

**1. Beleglage statisch.** **Nicht bestanden** in beiden Teilen der Kontrolle,
und zwar an **Baubefunden**, nicht an der Festlegung: `S12-01` — `Z-260` mass
ein Feld, das **vier der neun** Blockzeilen nicht enthielt (drei entstehen erst
in der Zusammenfassung, die Zeile `Pfaddeckung:` wird erst **nach** dem Fall
angehängt); `S12-02` — `Z-258` bestand mit **leerer** Sollmenge, weil `Z-260`
seine Zahlen nie sah. Beides ist ausgeführt belegt, beides ist in der
Behebungsrunde behoben (den Block **einmal** erzeugen, daraus ausgeben und
prüfen, `Z-260` nach der letzten Deckungszeile; `Z-258` registriert seine Zahlen
als Deckungszeile im Block), und beides ändert an der Festlegung nichts — die
Präzisierung des Messumfangs steht in f). Nachrangig sind `SST-P3-01` bis
`SST-P3-05` und `S12-03` bis `S12-05`; `SST-P3-05` und `S12-03` sind in c)
fortgeschrieben, die übrigen sind Baubefunde. **Alle Zahlen aus h) sind
eigenständig bestätigt** (261/260/262; Prädikatverteilung; 260 Einträge mit
248 `sed` und 12 `keine`; 12/31/18/24; 40 = 14 + 26; 35 Schwächungen, **35
wirksam** nach dem Nachtrag zu c) Punkt 4; 263 Probemarken; drei Aufrufstellen
zu `E21`), beide Modi enden in der Kopie mit Rückgabewert 0 (262 s und 577 s),
alle 248 `sed`-Ausdrücke sind wirksam, der Gate-Diff umfasst genau die vier
Zeilen aus e), `Makefile` und Lagenliste sind bytegleich. `shellcheck` fehlt in
der Umgebung (Lage C).

**2. Beleglage dynamisch.** **29 Fremdmutationen blind gewählt** um 11:15:54 UTC,
erster Blick in `scripts/dod-gate-mutationen.txt` und in die Tabelle 6.12.19 um
11:21:06 UTC, **keine Nachwahl**; 7/7/7/8 je Kategorie, **alle wirksam**, neun
davon mit falschem Grün am Gate. **28 liessen mindestens eine Zusicherung
fallen. Genau eine nicht — und sie erzeugt ein falsches Grün.** Das ist nach g)
**der** blockierende Befund: `DT12-M14`.

**3. `DT12-M14` im Einzelnen.**

| | |
|---|---|
| **Gegenstand** | Die Grammatik der **D19-Zeile** (Gate, Zeilen 810 und 816; Muster `^make dod: D19: (OHNE_BEFUND\|VERLETZT\|B\|C)( -- .*)?\.$`; Festlegung in **6.12.8**), nicht die Grammatik der Lage-Marke aus 6.12.7 |
| **Mutation** | Die Alternativen der D19-Grammatik werden an **beiden** Stellen durch `[A-Z_][A-Z_]*` ersetzt; die Zeile nimmt danach **jedes Grosswort** an |
| **Probe** | Attrappenausgabe mit grüner Kette, Schlusszeile Form 1 und der D19-Zeile `make dod: D19: SPAETER.` |
| **Original** | Rückgabewert 2, Schlüssel `KETTE ausgabe-unlesbar` — es steht nicht genau **eine** D19-Zeile in der Grammatik aus G7 |
| **Mutant** | **Rückgabewert 0 ohne Ausgabe.** Das Wort `SPAETER` fällt in keinen Zweig der `case`-Anweisung, und das Gate hält den Lauf für ein **belegtes Grün** |

**Die Klasse.** Keine Zeile der Tabelle misst eine D19-Zeile mit einem Wort
**ausserhalb** der vier zulässigen; `Z-056` bis `Z-063` messen die vier
zulässigen Wörter mit und ohne Zusatz. Es ist dieselbe Klasse, die c) für die
Marke geschlossen hat — eine Aufzählung deckt die zulässigen Formen, nicht die
Menge der unzulässigen —, nur an einer **zweiten Grammatik**, die 6.12.8
festlegt und die keine Elementtabelle führt.

**4. Entscheid nach g).** Der Befund wird **behoben, statisch nachgeprüft und
mit einer gezielten Wiederholung der Fremdmutation belegt; eine Runde 13 gibt es
nicht.** Behoben wird mit **zwei** neuen Zeilen: `Z-262` (Kanal `rc`, Prädikat
`gleich`, Rückgabewert 2) und `Z-263` (Kanal `zaehler`, Prädikat `gleich`,
Schlüssel `KETTE ausgabe-unlesbar`), beide über denselben Fall — eine D19-Zeile
mit einem Wort ausserhalb der vier, sonst grüne Kette mit Schlusszeile Form 1.
**Beide tragen dieselbe Mutation**, die Fremdmutation selbst, und das ist
zulässig: 6.12.26 b Punkt 3 verlangt nur, dass die eigene Kennung fällt; eine
pfadgenaue Trennung ist hier nicht möglich, weil beide denselben Gate-Pfad
messen und der Ausstieg in `blockieren_mit_zaehlung` geteilt ist. Die Zeile für
den **Rückgabewert** tritt hinzu, weil g) den Massstab genau dort ansetzt: Was
blockiert, ist das **falsche Grün**, und das misst der Rückgabewert unmittelbar.
`Grund 3` kommt für sie nicht in Betracht — er gilt dem Rückgabewert **0** eines
Durchlasses, hier steht der Rückgabewert **2** eines Blocks.

**Keine Elementtabelle für die D19-Grammatik in dieser Einheit.** Die
Grammatikdeckung liest mechanisch **allein** 6.12.7, und dort stehen die
Elemente der **Lage-Marke**. Die Elemente einer anderen Grammatik dort
einzutragen hiesse, zwei Gegenstände in einer Tabelle zu führen und je Kürzel
eine Zeile mit dem Etikett `Grammatik <KUERZEL>: ` zu verlangen, die die Deckung
dann gegen die Markengrammatik hielte. Die systematische Antwort wäre ein
**Schwächungslauf über das D19-Muster** nach dem Muster von c) — und der ist
nach g) **nicht** in dieser Einheit zu bauen.

**5. Was als Restlücke bleibt, benannt und im Backlog zu führen (R3-Q-001).**

1. **Die Grammatik der D19-Zeile ist nicht am Gegenstand gedeckt.** Geschlossen
   ist die **eine** belegte Verstossform (`Z-262`, `Z-263`); die Menge der
   Verstossformen deckt kein Schwächungslauf. Das ist dieselbe Lücke, die c)
   für die Marke geschlossen hat, an der zweiten Grammatik.
2. **Zeichen im Inneren eines Wortliterals** werden nicht einzeln geschwächt
   (c) Punkt 3, benannte Grenze).
3. **Eine Alternative mit einem bestimmten fremden Literal** ist nur als Klasse
   erfasst; die Alternativendeckung (`Z-253`, `Z-254`) hält die Alternativen der
   Marke gegen 6.12.7, für die D19-Grammatik besteht kein Gegenstück.

**6. Zahlen nach diesem Nachtrag.** Neu sind **zwei** Zeilen, `Z-262` und
`Z-263`; keine bestehende Kennung wandert. `Z-252` ist allein in der Spalte
Mutation berichtigt (c), `Z-209` allein in der Spalte Fall (b).

| Grösse | Stand nach h) | Stand nach diesem Nachtrag |
|---|---|---|
| Zeilen der Tabelle 6.12.19 | 261 | **263** |
| Zusicherungen | 260 | **262** |
| Messhüllen | 262 | **264** |
| Einträge in `scripts/dod-gate-mutationen.txt` | 260 (248 `sed`, 12 `keine`) | **262** (**250** `sed`, **12** `keine`) |
| Prädikat `gleich` | 172 | **174** |

Alle übrigen Prädikate, die Deckungen (12 Grammatikkürzel, 31 Aussagenkürzel,
18 Schlüssel, 24 Literale, 40 Ausgangsstellen, 35 Schwächungen, 3 Aufrufstellen
zu `E21`) und die Zahlen aus h) bleiben unverändert; die Zahlen aus h) sind der
Stand davor und bleiben stehen (6.1.2). **Der Bau meldet die neuen Zahlen, die
statische Nachprüfung bestätigt sie**, und die **gezielte Wiederholung** von
`DT12-M14` belegt, dass der Mutant nun mindestens eine Zusicherung fallen lässt.

**7. Was dieser Nachtrag nicht ändert.** Kein Entscheid G1 bis G17 und keiner
aus 6.12.23 bis 6.12.28 i wird zurückgenommen; keine Zusicherung entfällt. **Am
Gate ist aus diesem Nachtrag nichts zu ändern** — `DT12-M14` ist eine
**Mutation**, kein Befund am Verhalten; das Gate hat sich am Original richtig
verhalten (Rückgabewert 2, `KETTE ausgabe-unlesbar`). Am `Makefile` und an der
Liste der terminierten Lagen ist nichts zu ändern. Die Kernarchitektur aus 5.1,
die Entscheide A1 bis A13 und die Verankerung der Verfahrensgarantien bleiben
unberührt; das Gate steht an keiner Stelle zwischen Freigabe und Ausführung
(5.2). Keine D-Nummer wird vergeben. Nichts hier bereitet Gestrichenes vor.

**Und nichts hier ist eine Freigabe oder eine Abnahme.** Die förmliche Freigabe
der Entscheidpunkte E-A bis E-K bleibt, wie Abschnitt 10 sie seit dem 2026-09-07
führt. Die **Abnahme des Gates steht aus**: Sie wird erst vorgelegt, wenn
Behebung, statische Nachprüfung und gezielte Wiederholung als **Fremdbeleg**
gemeldet sind; die **Abnahmevorlage** in Abschnitt 10 schreibt diese Rolle erst
dann. **O-25** bleibt offen.

**Nachtrag vom 2026-09-08 — die Behebungsrunde, der Befund `SNP-01` und die
Abnahmevorlage**

*Auch in diesem Nachtrag ist alles **Fremdbeleg**: die gezielte Wiederholung
stammt vom Dynamic Software Tester, die Nachprüfung vom Static Software Tester,
beide auf einem anderen Modell als die Umsetzung (3.4). Diese Rolle hat nichts
ausgeführt, nichts nachgemessen und bestätigt nichts; sie entscheidet und
schreibt.*

**8. Gezielte Wiederholung von `DT12-M14` — alle vier Punkte belegt.**

| Punkt | Ergebnis |
|---|---|
| Gegen die Mutanten-Kopie | Es fallen `Z-262` (erwartet Rückgabewert 2, erhalten 0) und `Z-263` (Zählerdatei ohne Schlüssel) |
| Gegenprobe am unveränderten Gate | Beide bestehen |
| Am Gate selbst, ohne den Selbsttestapparat, mit der Attrappenausgabe `make dod: D19: SPAETER.` | Original unverändert: Rückgabewert 2, `dod-gate: BLOCKIERT. Schluessel: KETTE ausgabe-unlesbar`, Zählerdatei geschrieben. Mutant: Rückgabewert 0, Standardausgabe und Fehlerausgabe leer, keine Zählerdatei |
| Trennschärfe im vollständigen Normallauf gegen den Mutanten | `Selbsttest: 260 von 262 Zusicherungen bestanden`, genau zwei Zeilen `FEHLGESCHLAGEN`, `Z-262` und `Z-263`, keine weitere Kennung |

Damit ist belegt, was Punkt 6 verlangt hat: Der Mutant lässt mindestens eine
Zusicherung fallen, er tut es trennscharf, und der Unterschied ist **am Gate
selbst** sichtbar, nicht nur im Selbsttestapparat.

**9. Statische Nachprüfung — Gesamturteil bestanden, kein blockierender Befund
nach g).** Vier eigene Läufe der Prüfrolle:

| Lauf | Ergebnis |
|---|---|
| Mutanten-Kopie zu `DT12-M14` | Rückgabewert 2, 260 von 262; gefallen sind allein `Z-262` und `Z-263` |
| Unverändertes Gate | Rückgabewert 0, 262 von 262 |
| Mutanten-Kopie zu `Z-252` | Rückgabewert 2; gefallen ist allein `Z-252`, gemeldet `m = 18` |
| Mutationsmodus | Rückgabewert 0: 250 geprüft, 250 erkannt, 0 nicht erkannt, 12 ohne Mutation, 0 wirkungslos, 846 s |

Alle Zahlen aus Punkt 6 sind **eigenständig bestätigt** (263 Zeilen, 262
Zusicherungen, 264 Messhüllen, 262 Einträge in der Mutationsdatei mit 250 `sed`
und 12 `keine`, Prädikat `gleich` 174), ebenso die Deckungszahlen (12
Grammatikkürzel, 31 Aussagenkürzel, 18 Schlüssel, 24 Literale, 40
Ausgangsstellen, 35 Schwächungen, 3 Aufrufstellen zu `E21`). Die
fail-closed-Wachen des Deckungsblocks aus dem Nachtrag zu f) sind **ausgelöst
worden, nicht nur gelesen**: eine Anmeldung ohne Einlösung ergibt Rückgabewert
2; eine zwischen Messung und Ausgabe geänderte erste Zahl lässt die Wache
"verletzt" melden; eine entfernte Blockzeile ergibt `ohne = 1`, eine fremde
Zeile `fremde = 1`, beide mit Fehlerurteil. Die Reihenfolge der
Zusammenfassungsfunktion deckt sich Schritt für Schritt mit der Folge aus f)
Punkt 6. Der Gate-Diff umfasst genau die vier Meldungszeilen aus e), die Form
ist ohne Beanstandung, und die zwölf Einträge mit `keine` tragen alle einen
zulässigen Grund.

**10. `SNP-01` — die Begründung zur Mutation von `Z-252` war falsch, ihre
Wirkung nicht.** Der Static Software Tester hat **ausgeführt belegt**, dass die
erläuternde Begründung nicht zutrifft: Behauptet war, die Mutation mache die
Schwächungen "an den Elementen 3 bis 9" zu äquivalenten Mutanten. Tatsächlich
sind es **18** Schwächungen, verteilt über die Elemente **1 bis 9**; der Lauf
gegen die mutierte Kopie meldet `m = 18` und führt dabei Zeilen wie "U1 Anker
entfernt (Element 1)" und "U3 (i)/(ii)/(iii) (Element 2)" auf. Die Ursache ist
die Regel aus c) Punkt 7: Eine Schwächung an Element 1 oder 2 wird
**zusätzlich** auf das Vorfiltermuster angewandt — und genau dieses Muster setzt
die Mutation strenger.

Die **geforderte Wirkung ist unverändert erfüllt**: `Z-252` fällt, das
`marken_muster` bleibt unberührt, getroffen wird allein die eine Gate-Zeile 858,
und alle übrigen 261 Zusicherungen bestehen. Falsch war allein die Prosa.

**Behoben am 2026-09-08** an den drei Stellen, an denen der Satz stand: in der
Zeile `Z-252` der Tabelle 6.12.19 (Spalte Mutation, mit Vermerk in der
Herkunftsspalte), im Fliesstext von c) und in der Spalte Grund des Eintrags
`Z-252` in `scripts/dod-gate-mutationen.txt`. **Der `sed`-Ausdruck in Feld 3
dieses Eintrags ist nicht angefasst**, ebenso wenig Fall, Kanal, Prädikat und
Zusicherung der Zeile; an `dod-gate.sh`, am `Makefile`, an der Liste der
terminierten Lagen und am Selbsttest ist aus `SNP-01` nichts zu ändern. Der
Befund ist **nachrangig** im Sinne von g) — er erzeugt am Gate kein falsches
Grün, sondern beschreibt eine wirksame Mutation falsch — und hält die Abnahme
nicht auf. Festgehalten wird er trotzdem, weil eine unzutreffende Begründung im
Prüfmittel dieselbe Klasse ist wie eine unzutreffende Zusicherung: Sie wird
geglaubt statt geprüft.

**11. Was die Prüfrollen selbst als Grenze ihrer Prüfung benannt haben.** Zwei
Punkte, von ihnen genannt und hier unverändert übernommen: (1) Die
**wortlautgenaue Feindeckung** der Aussagen- und Grammatikkürzel ist **nicht**
Zeile für Zeile nachgezogen worden; übernommen ist die vom Selbsttest gemeldete
Deckung — geprüft ist damit, **dass** er sie meldet, nicht, dass jede einzelne
Zuordnung wörtlich trägt. (2) Es ist **kein Lauf gegen einen unabhängig
geklonten Baum** erfolgt. Beides ist keine Beanstandung, sondern die Reichweite
der Aussage; beides gehört in die Abnahmevorlage und steht dort.

**12. Damit ist die Bedingung aus Punkt 7 erfüllt.** Behebung, statische
Nachprüfung und gezielte Wiederholung sind als **Fremdbeleg** gemeldet; diese
Rolle schreibt deshalb jetzt — und erst jetzt — die **Abnahmevorlage** in
Abschnitt 10. Sie stützt sich ausdrücklich **nicht** auf einen bestandenen Teil
2 des Abnahmekriteriums: Teil 2 verlangt eine Fremdmutationsrunde **ohne**
blockierenden Befund, und Runde 12 hatte einen (`DT12-M14`). Gegriffen hat der
Weg, den g) für genau diesen Fall **vorab** festgelegt hat — beheben, statisch
nachprüfen, gezielte Wiederholung, **keine Runde 13**, Restlücke dokumentieren.

**Was dieser Nachtrag nicht ändert.** Kein Entscheid `G1` bis `G17` und keiner
aus 6.12.23 bis 6.12.28 wird zurückgenommen; **keine** Zusicherung kommt hinzu,
keine entfällt, keine Kennung wandert, und die Zahlen aus Punkt 6 bleiben, wie
sie dort stehen. Am Gate, am `Makefile` und an der Liste der terminierten Lagen
ist nichts zu ändern. Die Kernarchitektur aus 5.1, die Entscheide `A1` bis `A13`
und die Verankerung der Verfahrensgarantien bleiben unberührt; das Gate steht an
keiner Stelle zwischen Freigabe und Ausführung (5.2). Keine D-Nummer wird
vergeben. Nichts hier bereitet Gestrichenes vor (5.17, 5.18, 9.1, 5.10, 5.1).
**Und nichts hier ist eine Abnahme**: Eine Vorlage ist eine Vorlage. Die Abnahme
erteilt der Auftraggeber auf einem der beiden Formwege aus Abschnitt 10.
**O-25** bleibt offen.

---

