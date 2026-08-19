---
paths:
  - ".claude/**"
---

# Regeln für die Claude-Code-Konfiguration

Grundlage: Projektauftrag 3.2, 3.4, 4.1.

## Die vier Mechanismen nicht vermischen (3.2)

| Mechanismus | Ablageort | Wofür |
|---|---|---|
| CLAUDE.md | `./CLAUDE.md` | Kurze, immer gültige Projektregeln |
| Rules | `.claude/rules/*.md` | Themenspezifische Standards, pfadgebunden über `paths:` |
| Skills | `.claude/skills/<name>/SKILL.md` | Wiederverwendbare Prozeduren und Checklisten |
| Subagents | `.claude/agents/<name>.md` | Rollen mit eigenem Kontext, eigenen Tools, eigenem Modell |
| Hooks | `.claude/settings.json` | Harte Gates, die unabhängig vom Modell greifen |

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
- Das main-Gate prüft den **Text** des Bash-Befehls. Ein Befehl, der die Wörter
  nur als Inhalt trägt — etwa ein Heredoc, das diese Regel dokumentiert, oder ein
  `grep` danach — wird ebenfalls blockiert. Das ist gewollt: ein Fehlalarm kostet
  einen Versuch, ein übersehener Push nach `main` kostet mehr. In solchen Fällen
  die Datei mit dem `Write`-Werkzeug schreiben statt über die Shell.
- Bei `Stop`-Hooks: `stop_hook_active` prüfen und dann mit 0 enden, sonst
  blockiert ein nie erfüllbares Kriterium die Sitzung dauerhaft (3.4, Ebene 4).

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
