---
paths:
  - ".claude/**"
  - "CLAUDE.md"
---

# Regeln für die Claude-Code-Konfiguration

Grundlage: Projektauftrag 3.2, 3.4, 4.1.

## Die fünf Mechanismen nicht vermischen (3.2)

| Mechanismus | Ablageort | Wofür |
|---|---|---|
| CLAUDE.md | `./CLAUDE.md` | Kurze, immer gültige Projektregeln |
| Rules | `.claude/rules/*.md` | Themenspezifische Standards, pfadgebunden über `paths:` |
| Skills | `.claude/skills/<name>/SKILL.md` | Wiederverwendbare Prozeduren und Checklisten |
| Subagents | `.claude/agents/<name>.md` | Rollen mit eigenem Kontext, eigenen Tools, eigenem Modell |
| Hooks | `.claude/settings.json` | Harte Gates, die unabhängig vom Modell greifen, und Kontext beim Sitzungsstart (`SessionStart`) |

CLAUDE.md ist **Kontext, keine Durchsetzung**. Wer eine Regel garantiert
durchsetzen will, braucht einen Hook.

## Hooks
- **Nur Rückgabewert 2 blockiert.** Rückgabewert 1 ist ein nicht blockierender
  Fehler; ein Gate, das mit `exit 1` endet, ist wirkungslos, ohne dass das
  auffällt (3.4).
- stderr eines mit 2 endenden Hooks geht als Begründung an Claude zurück. Die
  Meldung nennt deshalb den verletzten Abschnitt und den nächsten Schritt.
- Hooks gehören zwingend in die **versionierte** `.claude/settings.json`.
  Cloud-Sitzungen lesen die lokale `~/.claude/settings.json` nicht (3.4).
- Hook-Skripte liegen unter `.claude/hooks/` und werden über
  `"${CLAUDE_PROJECT_DIR}"` angesprochen, nie über einen relativen Pfad.
- Jedes Hook-Skript wird vor dem Einbau gegen einen blockierenden und einen
  durchzulassenden Fall geprüft. Ein ungetestetes Gate ist kein Gate.
- Das main-Gate und das Prototyp-Gate prüfen bei `Bash` den **Text** des
  Befehls. Ein Befehl, der die Wörter nur als Inhalt trägt — etwa ein Heredoc,
  das diese Regel dokumentiert — kann deshalb blockiert werden. Das ist gewollt:
  ein Fehlalarm kostet einen Versuch, ein übersehener Push nach `main` oder ein
  eingeschleuster Prototyp-Import kostet mehr. In solchen Fällen die Datei mit
  dem `Write`-Werkzeug schreiben statt über die Shell — dort prüfen die Gates
  pfadgenau.
- Bei `Stop`-Hooks: `stop_hook_active` prüfen und dann mit 0 enden, sonst
  blockiert ein nie erfüllbares Kriterium die Sitzung dauerhaft (3.4, Ebene 4).

## Skills (3.2 b)

Ein Skill ist eine **wiederverwendbare Prozedur oder Checkliste, die mehrere
Rollen gleich ausführen**. Was nur eine Rolle tut, gehört in ihre Rollendatei.
Was eine Festlegung ist, gehört in einen ADR oder in eine Regel. Diese
Abgrenzung ist der einzige Grund, aus dem ein Skill entsteht — jeder weitere
Skill kostet Pflege an drei Stellen (Skill, `skills:`-Feld je Rolle, ADR 0001).

### Bauform

Eine `SKILL.md` ist dünn und verweist auf Tiefe:

1. **Frontmatter** mit `name`, `description` und `metadata` (siehe unten).
2. **Auslösefall** — wann diese Prozedur gilt und wann ausdrücklich nicht.
3. **Kernablauf** als nummerierte Schritte.
4. **Positiv- und Negativliste** — was hineingehört und was nicht. Die
   Negativliste ist der nützlichere Teil; sie verhindert die Fehler, die eine
   Prozedur ohne sie jedes Mal neu macht.
5. **Verweistabelle** auf die Dateien unter `references/`, je Zeile mit der
   Bedingung, wann sie zu laden ist.

Höchstens 500 Zeilen je `SKILL.md`; Einzelheiten wandern nach `references/`.
Dateien im Skill-Verzeichnis werden **nicht** von selbst geladen — sie werden
nur gelesen, wenn die `SKILL.md` sie nennt.
Quelle: https://code.claude.com/docs/en/skills.md (geprüft am 2026-08-31).

### `description` entscheidet, ob der Skill überhaupt geladen wird

Nur `description` (und `when_to_use`) stehen dauerhaft im Kontext; der Rumpf
wird erst nachgeladen, wenn der Skill aufgerufen wird. Die `description`
beschreibt deshalb den **Auslösefall**, nicht den Gegenstand — dieselbe Regel
wie bei den Rollendateien, und aus demselben Grund.

### `metadata` — der Sammelschlüssel für die Verfolgbarkeit

`metadata` ist ein offizielles Feld, eine freie YAML-Abbildung, die Claude Code
selbst ignoriert. Bei uns steht darunter, was 6.6 verfolgbar macht:

```yaml
metadata:
  anforderung: R3-Q-001            # Kennung im Backlog
  auftrag: "3.4, 5.3"              # Abschnitte des Projektauftrags
  adr: docs/adr/0002-...md         # zuständiger Architekturentscheid
```

Eigene Felder gehören ausschliesslich hierhin. Belegt ist: Paketierung und
Übertragung brechen an einem unbekannten Frontmatter-Feld mit einem harten
Fehler ab (https://code.claude.com/docs/en/skills.md). Wie sich Claude Code
selbst gegenüber einem unbekannten Feld verhält, sagt die Dokumentation nicht
— was sie nicht sagt, wird hier auch nicht behauptet. `metadata` ist der Weg,
der in beiden Fällen trägt.

### `allowed-tools` wird bei uns nicht gesetzt

Das Feld existiert, wirkt aber anders, als sein Name nahelegt: Es **genehmigt
die aufgezählten Werkzeuge für diesen Turn vorab**, statt die verfügbaren zu
beschränken. Das ist eine Rechteausweitung ohne Rückfrage und widerspricht dem
Grundsatz der minimalen Rechte. Werkzeugrechte werden je **Rolle** vergeben,
nicht je Prozedur.

### Vorladen je Rolle

Das Frontmatter einer Rollendatei kennt ein `skills:`-Feld; die genannten
Skills werden beim Start vollständig in den Kontext des Subagenten gelegt.
Genau so wird die Zuordnung geführt — nicht durch die Hoffnung, der Skill
werde schon von selbst gefunden.

```yaml
skills:
  - pruefbefund-melden
```

### Was ein Skill nicht kann

Er erzwingt nichts. Ein Skill ist Anweisung, und Anweisungen sind Kontext.
Wer eine Regel garantiert durchsetzen will, braucht einen Hook — derselbe Satz
wie für `CLAUDE.md`, und er gilt hier genauso.

## Rollendateien (4.1)
- Eine Datei je Rolle, YAML-Frontmatter plus Systemprompt im Body.
- Frontmatter: `name`, `description`, `tools`, `model`, `maxTurns`.
- `name` stimmt mit dem Dateinamen überein.
- Das `description`-Feld beschreibt den **Auslösefall**, nicht die Rolle.
  Richtig: "Prüft Code auf Sicherheitslücken vor jedem Commit".
  Falsch: "Security-Experte".
- Tool-Liste nach dem Prinzip der minimalen Rechte, als Positivliste.
- `maxTurns` ist gesetzt (3.4, Endlosschleifen-Schutz).
- Das Frontmatter kann Schreibrechte **nicht** auf ein Verzeichnis begrenzen.
  Solche Einschränkungen stehen als Instruktion im Body und werden erst über
  Hooks hart. Nichts anderes behaupten.
- Änderungen an Modell, Tools, `maxTurns` oder Rechteform werden in
  `docs/adr/0001-rollenmodell.md` nachgeführt.

## Grössenvorgabe
CLAUDE.md unter 200 Zeilen. Wird es länger, wandert Detail hierher — mit
`paths:`-Scoping, damit es nur lädt, wenn passende Dateien berührt werden.
