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

# Bash-Befehle: grobes Netz. Ein Schreibbefehl, dessen Text einen Import mit
# Bezug auf prototype/ traegt (Heredoc, echo mit Umleitung, sed), wuerde am
# pfadgenauen Pruefweg unten vorbeischreiben -- der kennt nur file_path und
# lief bei Bash bis zum 2026-08-25 gar nicht erst (Matcher ohne Bash,
# ausgefuehrt belegt). Blockiert wird nur die Kombination aus Schreibwirkung
# UND Importmuster mit prototype; reines Suchen und Lesen bleibt frei. Bei
# einem Fehlalarm die Datei mit dem Write-Werkzeug schreiben -- dort prueft
# das Gate pfadgenau (dieselbe Abwaegung wie beim main-Gate,
# .claude/rules/claude-konfiguration.md).
tool=$(printf '%s' "$input" | jq -r '.tool_name // empty')
if [ "$tool" = "Bash" ]; then
  cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty')
  [ -n "$cmd" ] || exit 0
  if printf '%s' "$cmd" | grep -Eq '(>>?|[|][[:space:]]*tee[[:space:]]|sed[[:space:]]+-[a-zA-Z]*i|<<)' \
      && printf '%s' "$cmd" | grep -Eq "(from|require|import|@import|__import__|import_module)[^|&]*prototype([./\"'[:space:]]|\$)"; then
    echo "BLOCKIERT (Projektauftrag 5.6): Shell-Befehl mit Schreibwirkung und einem Import, der 'prototype' beruehrt." >&2
    echo "Importe zwischen prototype/ und Produktionscode sind in beide Richtungen untersagt." >&2
    echo "Die Datei mit dem Write-Werkzeug schreiben -- dort prueft das Gate pfadgenau." >&2
    exit 2
  fi
  exit 0
fi

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

# Alle String-Werte aus tool_input ausser den Pfadfeldern und old_string.
# Deckt content (Write), new_string (Edit) und new_source (NotebookEdit) ab und
# ueberlebt Feldumbenennungen. old_string ist ausgenommen, weil es den ALTEN
# Stand traegt: ein Edit, das einen verbotenen Import ENTFERNT, hat das Muster
# nur in old_string und wuerde sonst blockiert -- das Gate hielte dann genau die
# Korrektur auf, die es erzwingen will (Befund der statischen Pruefung vom
# 2026-08-25, ausgefuehrt belegt).
payload=$(printf '%s' "$input" | jq -r '
  [ (.tool_input // {}) | to_entries[]
    | select(.value | type == "string")
    | select(.key | test("path|^old_string$"; "i") | not)
    | .value ] | join("\n")')
[ -n "$payload" ] || exit 0

Q="[\"'\`]"
NQ="[^\"'\`]"

if [ "${rel#prototype/}" != "$rel" ]; then
  # Richtung 2: Prototyp importiert aus dem Produktionscode. Massgebend sind
  # die Bauwurzeln aus ADR 0002 Abschnitt 5 (backend/, frontend/, deploy/);
  # die uebrigen Namen bleiben als Vorhalt fuer generische Layouts stehen.
  # Bis zum 2026-08-25 fehlten backend/ und frontend/ -- ein Import aus genau
  # den Verzeichnissen, die der ADR festlegt, lief durch (ausgefuehrt belegt).
  if printf '%s' "$payload" | grep -Eq \
      -e "(from|require\(|import\(|@import|import)[[:space:]]*\(?[[:space:]]*${Q}(\.\./)*(backend|frontend|deploy|src|app|lib|server|packages|apps)/" \
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
    -e "^[[:space:]]*(from|import)[[:space:]]+prototype([.[:space:]]|\$)" \
    -e "(import_module|__import__|import)[[:space:]]*\([[:space:]]*${Q}prototype[./]"; then
  echo "BLOCKIERT (Projektauftrag 5.6): '$rel' ist Produktionscode und importiert aus 'prototype/'." >&2
  echo "Der Prototyp ist ein Wegwerf-Prototyp; sein Code wird nach der Freigabe nicht weiterverwendet." >&2
  echo "Weiter gehen nur Bildschirmfluss, Komponenteninventar, Design-Tokens, Oberflaechentexte und" >&2
  echo "der synthetische Datenbestand - als Vorlage nachbauen, nicht importieren." >&2
  exit 2
fi
exit 0
