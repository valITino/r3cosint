#!/usr/bin/env bash
# PreToolUse-Gate: kein direkter Schreibzugriff auf main (Projektauftrag 3.2 c).
#
# 3.2 (c): "Regeln wie 'nie direkt auf main pushen' oder 'kein Commit ohne
# bestandene Tests' gehoeren als Hook implementiert, nicht als Satz in
# CLAUDE.md." CLAUDE.md ist Kontext, keine Durchsetzung.
#
# Zwei Faelle:
#   1. Dateiaenderung, waehrend HEAD auf main/master steht.
#   2. Bash-Befehl, der auf main/master committet, merged oder pusht.
#
# Rueckgabewert 2 blockiert. Rueckgabewert 1 blockiert NICHT (3.4).
set -uo pipefail

if ! command -v jq >/dev/null 2>&1; then
  echo "Gate main-schutz: jq ist nicht installiert; das Gate kann nicht pruefen." >&2
  echo "Installieren (z.B. 'apt-get install -y jq') oder das Gate bewusst entfernen." >&2
  exit 2
fi

input=$(cat)
proj="${CLAUDE_PROJECT_DIR:-$PWD}"

git -C "$proj" rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0
branch=$(git -C "$proj" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
[ -n "$branch" ] || exit 0

is_protected() { [ "$1" = "main" ] || [ "$1" = "master" ]; }

tool=$(printf '%s' "$input" | jq -r '.tool_name // empty')

if [ "$tool" = "Bash" ]; then
  cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty')
  [ -n "$cmd" ] || exit 0

  # push mit ausdruecklichem Ziel main/master, auch als HEAD:main, in der
  # vollqualifizierten Ref-Form HEAD:refs/heads/main oder mit --force.
  # Die Ref-Form braucht ein eigenes Muster: im allgemeinen Muster darf vor
  # main kein '/' stehen, sonst wuerde jeder Zweigname wie 'fix/main-seite'
  # blockiert. Befund der statischen Pruefung vom 2026-08-25 (ausgefuehrt:
  # 'git push origin HEAD:refs/heads/main' von einem Arbeitszweig lief durch).
  if printf '%s' "$cmd" | grep -Eq 'git[[:space:]]+([^|;&]*[[:space:]])?push([[:space:]]|$)'; then
    if printf '%s' "$cmd" | grep -Eq '(^|[[:space:]:+])(main|master)([[:space:]]|$|["'\''])' \
        || printf '%s' "$cmd" | grep -Eq 'refs/(heads|for)/(main|master)([[:space:]]|$|["'\''])'; then
      echo "BLOCKIERT (Projektauftrag 3.2 c): Push nach main/master." >&2
      echo "Auf den Arbeitszweig pushen und die Aenderung ueber einen Pull Request fuehren." >&2
      echo "Aktueller Zweig: $branch" >&2
      exit 2
    fi
    if is_protected "$branch"; then
      echo "BLOCKIERT (Projektauftrag 3.2 c): Push, waehrend HEAD auf '$branch' steht." >&2
      echo "Zuerst einen Arbeitszweig anlegen: git switch -c <zweig>" >&2
      exit 2
    fi
  fi

  # Schreibende und historienveraendernde git-Verben. rebase, reset, am, apply
  # und stash pop/apply fehlten bis zum 2026-08-25 (ausgefuehrt belegt:
  # 'git rebase', 'git reset --hard', 'git am' liefen auf main durch).
  # 'git switch -c' und 'git checkout -b' bleiben bewusst frei: sie sind der
  # vorgesehene Ausweg von main herunter.
  if is_protected "$branch" && printf '%s' "$cmd" | grep -Eq 'git[[:space:]]+([^|;&]*[[:space:]])?(commit|merge|revert|cherry-pick|rebase|reset|am|apply|stash[[:space:]]+(pop|apply))([[:space:]]|$)'; then
    echo "BLOCKIERT (Projektauftrag 3.2 c): schreibender git-Befehl auf '$branch'." >&2
    echo "Zuerst einen Arbeitszweig anlegen: git switch -c <zweig>" >&2
    exit 2
  fi

  # Dateiaenderung ueber die Shell, waehrend HEAD auf main/master steht
  # (Befund der statischen Pruefung vom 2026-08-25: sed -i, tee und
  # Umleitungen liefen durch, waehrend dieselbe Aenderung ueber Write/Edit
  # blockiert war). Geprueft wird der Befehlstext; Umleitungen in fluechtige
  # Ziele (/dev/null, /tmp, Umgebungs-Tempverzeichnisse) bleiben frei. Ein
  # Fehlalarm kostet einen Versuch und der Ausweg ist immer derselbe: zuerst
  # einen Arbeitszweig anlegen. Das ist dieselbe bewusste Abwaegung wie beim
  # Textmuster-Gate insgesamt (.claude/rules/claude-konfiguration.md).
  if is_protected "$branch"; then
    bereinigt=$(printf '%s' "$cmd" | sed -E \
      -e 's/[0-9]?>&[0-9]//g' \
      -e 's/[0-9]?>>?[[:space:]]*(\/dev\/null|\/tmp\/[^[:space:]]*|"?\$\{?(TMPDIR|RUNNER_TEMP|SCRATCH[A-Z_]*)\}?[^[:space:]]*)//g')
    if printf '%s' "$bereinigt" | grep -Eq '(>>?|\btee[[:space:]]|sed[[:space:]]+-[a-zA-Z]*i|\b(mv|cp|rm|mkdir|touch|truncate|ln|install|patch)[[:space:]])'; then
      echo "BLOCKIERT (Projektauftrag 3.2 c): Shell-Befehl mit Schreibwirkung, waehrend HEAD auf '$branch' steht." >&2
      echo "Dateien werden auf einem Arbeitszweig geaendert, nie auf main." >&2
      echo "Anlegen mit: git switch -c <zweig>   danach den Befehl wiederholen." >&2
      echo "Fluechtige Ziele (/dev/null, /tmp) sind von dieser Pruefung ausgenommen." >&2
      exit 2
    fi
  fi
  exit 0
fi

# Dateiaendernde Werkzeuge
is_protected "$branch" || exit 0

fp=$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_input.notebook_path // .tool_input.path // empty')
[ -n "$fp" ] || exit 0
case "$fp" in
  "$proj"/*) rel="${fp#"$proj"/}" ;;
  /*)        exit 0 ;;
  *)         rel="$fp" ;;
esac

echo "BLOCKIERT (Projektauftrag 3.2 c): Schreibzugriff auf '$rel', waehrend HEAD auf '$branch' steht." >&2
echo "Entwickelt wird auf einem Arbeitszweig, nie direkt auf main." >&2
echo "Anlegen mit: git switch -c <zweig>   danach die Aenderung wiederholen." >&2
exit 2
