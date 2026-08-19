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

  # push mit ausdruecklichem Ziel main/master, auch als HEAD:main oder mit --force
  if printf '%s' "$cmd" | grep -Eq 'git[[:space:]]+([^|;&]*[[:space:]])?push([[:space:]]|$)'; then
    if printf '%s' "$cmd" | grep -Eq '(^|[[:space:]:+])(main|master)([[:space:]]|$|["'\''])'; then
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

  if is_protected "$branch" && printf '%s' "$cmd" | grep -Eq 'git[[:space:]]+([^|;&]*[[:space:]])?(commit|merge|revert|cherry-pick)([[:space:]]|$)'; then
    echo "BLOCKIERT (Projektauftrag 3.2 c): schreibender git-Befehl auf '$branch'." >&2
    echo "Zuerst einen Arbeitszweig anlegen: git switch -c <zweig>" >&2
    exit 2
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
