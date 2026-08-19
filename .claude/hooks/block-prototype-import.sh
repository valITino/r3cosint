#!/usr/bin/env bash
# PreToolUse-Gate: trennt Prototyp und Produktionscode (Projektauftrag 5.6).
#
# 5.6: "Der Prototyp liegt in einem eigenen Verzeichnis, getrennt vom
# Produktionscode, ohne gemeinsame Abhaengigkeiten und ohne Importe in beide
# Richtungen." Der haeufigste Fehler bei diesem Vorgehen ist, dass der Prototyp
# still zur Grundlage wird und Provisorien in die Produktion wandern.
#
# Rueckgabewert 2 blockiert und gibt stderr als Begruendung an Claude zurueck.
# Rueckgabewert 1 blockiert NICHT (3.4) und wird hier nirgends verwendet.
set -uo pipefail

if ! command -v jq >/dev/null 2>&1; then
  echo "Gate prototyp-trennung: jq ist nicht installiert; das Gate kann nicht pruefen." >&2
  echo "Installieren (z.B. 'apt-get install -y jq') oder das Gate bewusst entfernen." >&2
  exit 2
fi

input=$(cat)
proj="${CLAUDE_PROJECT_DIR:-$PWD}"

fp=$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_input.notebook_path // .tool_input.path // empty')
[ -n "$fp" ] || exit 0

case "$fp" in
  "$proj"/*) rel="${fp#"$proj"/}" ;;
  /*)        exit 0 ;;                 # ausserhalb des Projekts: nicht zustaendig
  *)         rel="$fp" ;;
esac

# Prosa darf prototype/ nennen. Geprueft wird nur Code.
case "$rel" in
  docs/*|.claude/*|*.md|*.txt|*.adoc|*.rst) exit 0 ;;
esac

# Alle String-Werte aus tool_input ausser den Pfadfeldern. Deckt content (Write),
# new_string (Edit) und new_source (NotebookEdit) ab und ueberlebt Feldumbenennungen.
payload=$(printf '%s' "$input" | jq -r '
  [ (.tool_input // {}) | to_entries[]
    | select(.value | type == "string")
    | select(.key | test("path"; "i") | not)
    | .value ] | join("\n")')
[ -n "$payload" ] || exit 0

Q="[\"'\`]"
NQ="[^\"'\`]"

if [ "${rel#prototype/}" != "$rel" ]; then
  # Richtung 2: Prototyp importiert aus dem Produktionscode.
  if printf '%s' "$payload" | grep -Eq \
      -e "(from|require\(|import\(|@import|import)[[:space:]]*\(?[[:space:]]*${Q}(\.\./)*(src|app|lib|server|packages|apps)/" \
      -e "(from|require\(|import\(|@import|import)[[:space:]]*\(?[[:space:]]*${Q}[@~#]/"; then
    echo "BLOCKIERT (Projektauftrag 5.6): '$rel' liegt im Prototyp und importiert aus dem Produktionscode." >&2
    echo "Der Prototyp ist Wegwerf-Code und haelt keine Abhaengigkeit in beide Richtungen." >&2
    echo "Benoetigte Werte im Prototyp eigenstaendig hinterlegen, statt sie zu importieren." >&2
    exit 2
  fi
  exit 0
fi

# Richtung 1: Produktionscode importiert aus dem Prototyp.
if printf '%s' "$payload" | grep -Eq \
    -e "(from|require\(|import\(|@import|import)[[:space:]]*\(?[[:space:]]*${Q}${NQ}*prototype/" \
    -e "(src|href)=${Q}${NQ}*prototype/" \
    -e "^[[:space:]]*(from|import)[[:space:]]+prototype([.[:space:]]|\$)"; then
  echo "BLOCKIERT (Projektauftrag 5.6): '$rel' ist Produktionscode und importiert aus 'prototype/'." >&2
  echo "Der Prototyp ist ein Wegwerf-Prototyp; sein Code wird nach der Freigabe nicht weiterverwendet." >&2
  echo "Weiter gehen nur Bildschirmfluss, Komponenteninventar, Design-Tokens, Oberflaechentexte und" >&2
  echo "der synthetische Datenbestand - als Vorlage nachbauen, nicht importieren." >&2
  exit 2
fi
exit 0
