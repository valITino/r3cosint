#!/usr/bin/env bash
# =============================================================================
# scripts/dod-gate-selbsttest.sh — Selbsttest fuer .claude/hooks/dod-gate.sh
# =============================================================================
#
# Bau auf Weisung vom 2026-09-02, foermliche Freigabe ausstehend (ADR 0002,
# Abschnitt 10). Grundlage: ADR 0002, Abschnitt 6.12.19 (G17).
#
# "Jedes Hook-Skript wird vor dem Einbau gegen einen blockierenden und einen
# durchzulassenden Fall geprueft. Ein ungetestetes Gate ist kein Gate."
# (.claude/rules/claude-konfiguration.md, Abschnitt "Hooks")
#
# ZWEI PRUEFEBENEN (ADR 0002, 6.12.19), keine ersetzt die andere:
#   1. Formpruefungen gegen eine ATTRAPPE von "make dod" -- nur so lassen
#      sich Lagen herstellen, die am heutigen Bestand nicht herstellbar sind
#      (ein A_FAIL, ein VERLETZT, eine fehlende Marke, ein Rueckgabewert 7).
#      Die Attrappe steht NIE in der versionierten .claude/settings.json.
#   2. Ein ROTER und ein GRUENER Lauf gegen das ECHTE Makefile. Der gruene
#      Lauf braucht einen Scheinbaum (eigenes Git-Repository), weil PROJ sich
#      nicht ueberschreiben laesst. OB dieser Scheinbaum mit dem ECHTEN
#      Belegpruefer (D20) gruen wird, behauptet dieser Selbsttest NICHT --
#      faellt es anders aus, wird das gemeldet, der Scheinbaum wird nicht
#      zurechtgebogen (ADR 0002, 6.12.19).
#
# Das Skript ist im Selbsttest UNMITTELBAR ueber die Standardeingabe geprueft
# (nicht ueber den Harness) -- Herstellbarkeit jedes Falls und Determinismus,
# siehe ADR 0002, 6.12.19, letzter Absatz.
#
# Verifikation dieses Skripts UND des Gates: Static und Dynamic Software
# Tester auf einem anderen Modell als die Umsetzung (3.4). Diese Rolle prueft
# sich nicht selbst.
#
# Rueckgabewert: 0 nur bei vollstaendigem Bestehen ALLER geprueften Faelle,
# sonst 2. Kein Netzzugriff; alle Scheinbaeume liegen unter mktemp und werden
# am Ende aufgeraeumt.
# =============================================================================

set -uo pipefail

SKRIPT_VERZEICHNIS="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_WURZEL="$(cd "$SKRIPT_VERZEICHNIS/.." && pwd)"
GATE="$REPO_WURZEL/.claude/hooks/dod-gate.sh"
ECHTES_MAKEFILE="$REPO_WURZEL/Makefile"
ECHTER_BELEGPRUEFER="$REPO_WURZEL/scripts/belege-pruefen.sh"

BASH_BIN="$(command -v bash)"

# Alle Wegwerfverzeichnisse dieses Laufs, damit sie am Ende sicher entfernt
# werden -- auch bei einem fehlgeschlagenen Fall.
AUFRAEUM_VERZEICHNISSE=()
aufraeumen() {
  local d
  for d in "${AUFRAEUM_VERZEICHNISSE[@]:-}"; do
    [ -n "$d" ] && [ -d "$d" ] && chmod -R u+rwx "$d" 2>/dev/null && rm -rf "$d" 2>/dev/null
  done
}
trap aufraeumen EXIT

bestanden=0
gesamt=0
fehlgeschlagene_faelle=()

# -----------------------------------------------------------------------------
# neu_verzeichnis: registriert ein mktemp-Verzeichnis zum Aufraeumen und gibt
# den Pfad aus.
# -----------------------------------------------------------------------------
neu_verzeichnis() {
  local d
  d=$(mktemp -d)
  AUFRAEUM_VERZEICHNISSE+=("$d")
  printf '%s' "$d"
}

# -----------------------------------------------------------------------------
# baue_werkzeugkasten <zielverzeichnis> <ausgeschlossenes-werkzeug ...>
# Symlinks fuer die von dod-gate.sh und seiner Kette benutzten Werkzeuge,
# AUSSER den genannten -- fuer die "Pruefmittel fehlt"-Faelle (G10).
# -----------------------------------------------------------------------------
baue_werkzeugkasten() {
  local dir="$1"; shift
  local ausschluss=" $* "
  local w p
  mkdir -p "$dir"
  for w in jq git make timeout flock bash sh cat sed grep awk mktemp sha256sum sleep \
           cut printf basename dirname find sort head tail xargs rm mkdir \
           touch date tr env true false wc expr; do
    case "$ausschluss" in
      *" $w "*) continue ;;
    esac
    p=$(command -v "$w" 2>/dev/null) || continue
    ln -sf "$p" "$dir/$w" 2>/dev/null || true
  done
}

# -----------------------------------------------------------------------------
# neuer_mock_baum: ein frisches Git-Repository mit einer steuerbaren
# Attrappe von "make dod" (Ziel "dod" druckt $MOCK_AUSGABE und endet mit
# $MOCK_RC, beides zur LAUFZEIT aus der Umgebung gelesen -- der Selbsttest
# exportiert beide vor jedem Gate-Aufruf), zwei Attrappen-Rollen und einer
# LEEREN Liste terminierter Lagen (von jedem Fall bei Bedarf ueberschrieben).
# -----------------------------------------------------------------------------
neuer_mock_baum() {
  local d
  d=$(neu_verzeichnis)
  git -C "$d" init -q
  git -C "$d" config user.email "selbsttest@example.invalid"
  git -C "$d" config user.name "Selbsttest"
  mkdir -p "$d/.claude/agents" "$d/.claude/hooks" "$d/docs/uebergaben"
  cat > "$d/Makefile" <<'MAKEEOF'
.PHONY: dod
dod:
	sleep "$${MOCK_SLEEP:-0}"
	[ -z "$${MOCK_MARKER:-}" ] || : > "$$MOCK_MARKER"
	if [ -n "$${MOCK_TMP_SPUR:-}" ]; then t=$$(mktemp); printf '%s' "$$t" > "$$MOCK_TMP_SPUR"; rm -f "$$t"; fi
	printf '%s\n' "$$MOCK_AUSGABE"
	exit "$${MOCK_RC:-0}"
MAKEEOF
  # MOCK_MARKER (S-06): wird nur angelegt, wenn das Rezept TATSAECHLICH
  # laeuft -- ein Fall, der beweisen soll, dass die Kette VOR dem Lauf
  # blockiert wurde, prueft die Abwesenheit dieser Datei.
  # MOCK_TMP_SPUR (DT2-B2): die Attrappe ruft SELBST "mktemp" auf (wie die
  # echte Kette es in D6/D12 tut) und schreibt den dabei entstandenen Pfad in
  # die genannte Datei -- so laesst sich pruefen, WELCHES Verzeichnis die
  # Kette als TMPDIR sah, ohne die eigene Standardausgabe des Gates zu
  # missbrauchen (6.12.15 verbietet, die Kettenausgabe dort erscheinen zu
  # lassen).
  : > "$d/.claude/hooks/dod-gate-terminierte-lagen.txt"
  cat > "$d/.claude/agents/attrappe-schreiber.md" <<'AGENTEOF'
---
name: attrappe-schreiber
description: Attrappenrolle mit Schreibrecht, nur fuer den Selbsttest.
tools: Read, Grep, Glob, Edit, Write, Bash
---
Attrappe fuer den Selbsttest von dod-gate.sh.
AGENTEOF
  cat > "$d/.claude/agents/anders-benannt.md" <<'AGENTEOF'
---
name: attrappe-pruefer
description: Attrappenrolle ohne Schreibrecht, nur fuer den Selbsttest. Der Dateiname weicht ABSICHTLICH vom Frontmatter-Feld "name:" ab (G13, 6.12.14).
tools: Read, Grep, Glob, Bash, Skill
---
Attrappe fuer den Selbsttest von dod-gate.sh.
AGENTEOF
  printf '%s\n' "init" > "$d/README.txt"
  git -C "$d" add -A
  git -C "$d" commit -q -m "init"
  printf '%s' "$d"
}

# -----------------------------------------------------------------------------
# rufe_gate <input-json> [zustand-basis] [path] [extra-env-KEY=WERT ...]
# Ruft dod-gate.sh unmittelbar mit dem gegebenen JSON auf der Standardeingabe
# auf. Schreibt stdout/stderr/rc in globale Variablen G_STDOUT/G_STDERR/G_RC.
# -----------------------------------------------------------------------------
rufe_gate() {
  local eingabe="$1" zustand="$2" pfad="$3"; shift 3
  local zwischenpfad_stdout zwischenpfad_stderr
  zwischenpfad_stdout=$(mktemp)
  zwischenpfad_stderr=$(mktemp)
  ( printf '%s' "$eingabe" | env -i \
      PATH="$pfad" \
      HOME="${HOME:-/root}" \
      XDG_STATE_HOME="$zustand" \
      "$@" \
      "$BASH_BIN" "$GATE" ) >"$zwischenpfad_stdout" 2>"$zwischenpfad_stderr"
  G_RC=$?
  G_STDOUT=$(cat "$zwischenpfad_stdout")
  G_STDERR=$(cat "$zwischenpfad_stderr")
  rm -f "$zwischenpfad_stdout" "$zwischenpfad_stderr"
}

# -----------------------------------------------------------------------------
# rufe_gate_ohne_home <input-json> <path> [extra-env-KEY=WERT ...]
# Wie rufe_gate, aber OHNE automatischen HOME-Fallback und OHNE
# XDG_STATE_HOME -- fuer B-01 (HOME und XDG_STATE_HOME fehlen beide unter
# "set -u").
# -----------------------------------------------------------------------------
rufe_gate_ohne_home() {
  local eingabe="$1" pfad="$2"; shift 2
  local zwischenpfad_stdout zwischenpfad_stderr
  zwischenpfad_stdout=$(mktemp)
  zwischenpfad_stderr=$(mktemp)
  ( printf '%s' "$eingabe" | env -i \
      PATH="$pfad" \
      "$@" \
      "$BASH_BIN" "$GATE" ) >"$zwischenpfad_stdout" 2>"$zwischenpfad_stderr"
  G_RC=$?
  G_STDOUT=$(cat "$zwischenpfad_stdout")
  G_STDERR=$(cat "$zwischenpfad_stderr")
  rm -f "$zwischenpfad_stdout" "$zwischenpfad_stderr"
}

# -----------------------------------------------------------------------------
# pruefe <beschreibung> <erwarteter-rc> [muster-stdout] [muster-stderr]
# Wertet G_RC/G_STDOUT/G_STDERR aus (von rufe_gate gesetzt) und zaehlt.
# Ein leeres Muster wird nicht geprueft.
# -----------------------------------------------------------------------------
pruefe() {
  local beschreibung="$1" erwarteter_rc="$2" muster_stdout="${3:-}" muster_stderr="${4:-}"
  gesamt=$((gesamt + 1))
  local ok=1
  if [ "$G_RC" != "$erwarteter_rc" ]; then
    ok=0
  fi
  if [ -n "$muster_stdout" ] && ! printf '%s' "$G_STDOUT" | grep -qE "$muster_stdout"; then
    ok=0
  fi
  if [ -n "$muster_stderr" ] && ! printf '%s' "$G_STDERR" | grep -qE "$muster_stderr"; then
    ok=0
  fi
  if [ "$ok" -eq 1 ]; then
    bestanden=$((bestanden + 1))
    printf 'BESTANDEN  %s\n' "$beschreibung"
  else
    fehlgeschlagene_faelle+=("$beschreibung")
    printf 'FEHLGESCHLAGEN  %s (rc=%s, erwartet %s)\n' "$beschreibung" "$G_RC" "$erwarteter_rc"
    printf '  stdout: %s\n' "$G_STDOUT" | head -c 500
    printf '\n  stderr: %s\n' "$G_STDERR" | head -c 500
    printf '\n'
  fi
}

WERKZEUGKASTEN_VOLL=$(neu_verzeichnis)
baue_werkzeugkasten "$WERKZEUGKASTEN_VOLL"

REAL_TIMEOUT="$(command -v timeout)"

# -----------------------------------------------------------------------------
# Werkzeugkasten mit VERKUERZTER innerer Zeitgrenze, NUR fuer den Fall
# "innere Zeitueberschreitung": dod-gate.sh ruft fest "timeout -k 10 600
# make ..." auf (ADR 0002, 6.12.12) -- 600 s real abzuwarten waere fuer einen
# automatisierten Selbsttest nicht vertretbar. Der Schalter "-k 10 600" wird
# hier auf "-k 1 2" verkuerzt, das ECHTE "timeout" (fester Pfad) macht danach
# genau dasselbe. Getestet wird damit die AUSWERTUNG von 124/137 im Gate,
# nicht coreutils' timeout selbst (das ist etabliert und nicht Gegenstand
# dieses Selbsttests).
# -----------------------------------------------------------------------------
WERKZEUGKASTEN_SCHNELLER_TIMEOUT=$(neu_verzeichnis)
baue_werkzeugkasten "$WERKZEUGKASTEN_SCHNELLER_TIMEOUT"
rm -f "$WERKZEUGKASTEN_SCHNELLER_TIMEOUT/timeout"
cat > "$WERKZEUGKASTEN_SCHNELLER_TIMEOUT/timeout" <<TIMEOUTEOF
#!/bin/sh
if [ "\$1" = "-k" ] && [ "\$2" = "10" ] && [ "\$3" = "600" ]; then
  shift 3
  exec "$REAL_TIMEOUT" -k 1 2 "\$@"
fi
exec "$REAL_TIMEOUT" "\$@"
TIMEOUTEOF
chmod +x "$WERKZEUGKASTEN_SCHNELLER_TIMEOUT/timeout"

# -----------------------------------------------------------------------------
# Werkzeugkasten mit einer ATTRAPPE fuer "make" selbst, NUR fuer den einen
# Fall "Rueckgabewert weder 0 noch 2": GNU Make wandelt JEDE fehlgeschlagene
# Rezeptzeile in seinen EIGENEN Rueckgabewert 2 um (empirisch geprueft, siehe
# Uebergabe dieser Arbeitseinheit) -- ein anderer Wert als 0/1/2/124/137 laesst
# sich mit einem echten Makefile nicht herstellen. Die Attrappe umgeht NUR
# diese Umwandlung; sie druckt weiterhin MOCK_AUSGABE und liefert MOCK_RC
# unveraendert.
# -----------------------------------------------------------------------------
WERKZEUGKASTEN_FAKE_MAKE=$(neu_verzeichnis)
baue_werkzeugkasten "$WERKZEUGKASTEN_FAKE_MAKE"
rm -f "$WERKZEUGKASTEN_FAKE_MAKE/make"
cat > "$WERKZEUGKASTEN_FAKE_MAKE/make" <<'FAKEMAKEEOF'
#!/bin/sh
printf '%s\n' "$MOCK_AUSGABE"
exit "${MOCK_RC:-0}"
FAKEMAKEEOF
chmod +x "$WERKZEUGKASTEN_FAKE_MAKE/make"

# -----------------------------------------------------------------------------
# Werkzeugkasten mit einer ATTRAPPE fuer "mktemp", NUR fuer S-07/N-06b: der
# ERSTE Aufruf (ohne "-p /tmp") liefert eine Datei INNERHALB von
# $FAKE_MKTEMP_ZIEL (vom Fall auf den Scheinbaum gesetzt) -- das muss die
# N-06-Ausweichlogik des Gates ausloesen; der ZWEITE Aufruf ("mktemp -p
# /tmp", der Ausweich selbst) schlaegt absichtlich fehl, damit der Fall
# "GATE mktemp" (beide Wege versperrt) herstellbar ist.
# -----------------------------------------------------------------------------
REAL_MKTEMP="$(command -v mktemp)"
WERKZEUGKASTEN_FAKE_MKTEMP=$(neu_verzeichnis)
baue_werkzeugkasten "$WERKZEUGKASTEN_FAKE_MKTEMP"
rm -f "$WERKZEUGKASTEN_FAKE_MKTEMP/mktemp"
cat > "$WERKZEUGKASTEN_FAKE_MKTEMP/mktemp" <<MKTEMPEOF
#!/bin/sh
if [ "\$1" = "-p" ] && [ "\$2" = "/tmp" ]; then
  exit 1
fi
mkdir -p "\$FAKE_MKTEMP_ZIEL"
exec "$REAL_MKTEMP" -p "\$FAKE_MKTEMP_ZIEL"
MKTEMPEOF
chmod +x "$WERKZEUGKASTEN_FAKE_MKTEMP/mktemp"

# -----------------------------------------------------------------------------
# baue_eingabe <ereignis> <cwd> <session_id> [stop_hook_active] [agent_id]
#              [agent_type]
# -----------------------------------------------------------------------------
baue_eingabe() {
  local ereignis="$1" cwd="$2" session="$3" sa="${4:-}" ai="${5:-}" at="${6:-}"
  jq -nc --arg e "$ereignis" --arg c "$cwd" --arg s "$session" \
         --arg sa "$sa" --arg ai "$ai" --arg at "$at" '
    {hook_event_name: $e, cwd: $c, session_id: $s}
    + (if $sa != "" then {stop_hook_active: ($sa == "true")} else {} end)
    + (if $ai != "" then {agent_id: $ai} else {} end)
    + (if $at != "" then {agent_type: $at} else {} end)
  '
}

# -----------------------------------------------------------------------------
# lauf <baum> <ereignis> <session_id> <mock_ausgabe> <mock_rc>
#      [stop_hook_active] [agent_id] [agent_type] [werkzeugkasten] [mock_sleep]
# Bequemer Wrapper: setzt CLAUDE_PROJECT_DIR=baum, cwd=baum, frisches
# Zustandsverzeichnis je Aufruf (ausser explizit anders gewuenscht -- siehe
# lauf_mit_zustand fuer die Eskalationsfaelle, die denselben Zustand ueber
# mehrere Aufrufe teilen muessen).
# -----------------------------------------------------------------------------
lauf() {
  local baum="$1" ereignis="$2" session="$3" mock_ausgabe="$4" mock_rc="$5"
  local sa="${6:-}" ai="${7:-}" at="${8:-}" wzk="${9:-$WERKZEUGKASTEN_VOLL}" schlaf="${10:-0}"
  local zustand eingabe
  zustand=$(neu_verzeichnis)
  eingabe=$(baue_eingabe "$ereignis" "$baum" "$session" "$sa" "$ai" "$at")
  rufe_gate "$eingabe" "$zustand" "$wzk" \
    "CLAUDE_PROJECT_DIR=$baum" "MOCK_AUSGABE=$mock_ausgabe" "MOCK_RC=$mock_rc" "MOCK_SLEEP=$schlaf"
}

# -----------------------------------------------------------------------------
# lauf_mit_zustand <zustand> <baum> <ereignis> <session_id> <mock_ausgabe>
#                  <mock_rc> [stop_hook_active] [agent_id] [agent_type]
# Wie "lauf", aber mit VORGEGEBENEM Zustandsverzeichnis -- fuer die
# Eskalationsfaelle (G8), die ueber mehrere Aufrufe hinweg denselben Zaehler
# teilen muessen.
# -----------------------------------------------------------------------------
lauf_mit_zustand() {
  local zustand="$1" baum="$2" ereignis="$3" session="$4" mock_ausgabe="$5" mock_rc="$6"
  local sa="${7:-}" ai="${8:-}" at="${9:-}"
  local eingabe
  eingabe=$(baue_eingabe "$ereignis" "$baum" "$session" "$sa" "$ai" "$at")
  rufe_gate "$eingabe" "$zustand" "$WERKZEUGKASTEN_VOLL" \
    "CLAUDE_PROJECT_DIR=$baum" "MOCK_AUSGABE=$mock_ausgabe" "MOCK_RC=$mock_rc"
}

# -----------------------------------------------------------------------------
# marke <kennung> <D> <ziel> <lage> [fehlt] [zusatz]
# Baut eine wohlgeformte "::LAGE ...::"-Zeile in der Grammatik aus G6/G7.
# -----------------------------------------------------------------------------
marke() {
  local kennung="$1" d="$2" ziel="$3" lage="$4" fehlt="${5:-}" zusatz="${6:-}"
  local s="::LAGE $kennung $d $ziel $lage"
  [ -n "$fehlt" ] && s="$s FEHLT=$fehlt"
  [ -n "$zusatz" ] && s="$s $zusatz"
  s="$s::"
  printf '%s' "$s"
}

# -----------------------------------------------------------------------------
# marken_zeile <kennung> <D> <ziel> <lage> <fehlt> <zusatz> <rueckgabewert>
# -----------------------------------------------------------------------------
marken_zeile() {
  local m
  m=$(marke "$1" "$2" "$3" "$4" "$5" "$6")
  printf '%s (rueckgabewert=%s)' "$m" "$7"
}

# -----------------------------------------------------------------------------
# bauen_ausgabe <baum> <marken-text, mehrzeilig> <d19-zeile-ohne-praefix> <schluss-zeile>
# -----------------------------------------------------------------------------
bauen_ausgabe() {
  local baum="$1" marken="$2" d19="$3" schluss="$4"
  printf 'make dod: geprueft wird %s.\n=== Uebersicht Definition-of-Done-Kette (make dod) ===\n%s\n\nmake dod: D19: %s\n%s\n' \
    "$baum" "$marken" "$d19" "$schluss"
}

D19_OK="OHNE_BEFUND -- Arbeitsbaum unveraendert."

echo "=== Selbsttest dod-gate.sh (ADR 0002, 6.12.19) ==="
echo
echo "--- Ebene 1: Formpruefungen gegen eine Attrappe von 'make dod' ---"
echo

# --- Fall 1: A_FAIL blockiert -----------------------------------------------
baum=$(neuer_mock_baum)
m1=$(marken_zeile K1 D20 belege A_OK "" "" 0)
m2=$(marken_zeile K1 D3 linter A_FAIL "" "" 2)
ausgabe=$(bauen_ausgabe "$baum" "$m1
$m2" "$D19_OK" "make dod: abgebrochen bei D3 linter, Rueckgabewert 2.")
lauf "$baum" Stop "fall01" "$ausgabe" 2
pruefe "01 Kette mit A_FAIL -> 2" 2 "" "D3 linter A_FAIL"

# --- Fall 2: sauberes Gruen, keine Ausgabe ----------------------------------
baum=$(neuer_mock_baum)
m1=$(marken_zeile K1 D20 belege A_OK "" "" 0)
m2=$(marken_zeile K1 D1 bau B "" "" 0)
ausgabe=$(bauen_ausgabe "$baum" "$m1
$m2" "$D19_OK" "make dod: alle 2 Kettenschritte durchlaufen, keiner ungleich 0, 2 gueltige Marken gezaehlt.")
lauf "$baum" Stop "fall02" "$ausgabe" 0
gesamt=$((gesamt + 1))
if [ "$G_RC" = "0" ] && [ -z "$G_STDOUT" ] && [ -z "$G_STDERR" ]; then
  bestanden=$((bestanden + 1)); echo "BESTANDEN  02 Kette gruen ohne Lage C -> 0, keine Ausgabe"
else
  fehlgeschlagene_faelle+=("02 Kette gruen ohne Lage C")
  echo "FEHLGESCHLAGEN  02 Kette gruen ohne Lage C (rc=$G_RC, stdout='$G_STDOUT', stderr='$G_STDERR')"
fi

# --- Fall 3: terminierte Lage C, Eintrag gueltig -> 0 mit systemMessage ----
baum=$(neuer_mock_baum)
printf 'D7 abnahme|scripts/abnahme-abgleich.sh\tADR 0002, 6.12.5, Selbsttest.\n' > "$baum/.claude/hooks/dod-gate-terminierte-lagen.txt"
m1=$(marken_zeile K1 D20 belege A_OK "" "" 0)
m2=$(marken_zeile K1 D7 abnahme C scripts/abnahme-abgleich.sh "" 2)
ausgabe=$(bauen_ausgabe "$baum" "$m1
$m2" "$D19_OK" "make dod: alle 2 Kettenschritte durchlaufen, 1 davon ohne Urteil (Lage C): D7 abnahme FEHLT=scripts/abnahme-abgleich.sh, Rueckgabewert 2.")
lauf "$baum" Stop "fall03" "$ausgabe" 2
pruefe "03 Terminierte Lage C, Eintrag gueltig -> 0 mit systemMessage" 0 '"systemMessage".*D7 abnahme'

# --- Fall 4: Lage C ohne Eintrag -> 2 ---------------------------------------
baum=$(neuer_mock_baum)
m1=$(marken_zeile K1 D20 belege A_OK "" "" 0)
m2=$(marken_zeile K1 D7 abnahme C scripts/abnahme-abgleich.sh "" 2)
ausgabe=$(bauen_ausgabe "$baum" "$m1
$m2" "$D19_OK" "make dod: alle 2 Kettenschritte durchlaufen, 1 davon ohne Urteil (Lage C): D7 abnahme FEHLT=scripts/abnahme-abgleich.sh, Rueckgabewert 2.")
lauf "$baum" Stop "fall04" "$ausgabe" 2
pruefe "04 Lage C ohne Eintrag -> 2" 2 "" "D7 abnahme C"

# --- Fall 5: Eintrag vorhanden, Pruefmittel existiert inzwischen (veraltet) -
baum=$(neuer_mock_baum)
mkdir -p "$baum/scripts"
: > "$baum/scripts/abnahme-abgleich.sh"
git -C "$baum" add -A && git -C "$baum" commit -q -m "artefakt entstanden"
printf 'D7 abnahme|scripts/abnahme-abgleich.sh\tADR 0002, 6.12.5, Selbsttest.\n' > "$baum/.claude/hooks/dod-gate-terminierte-lagen.txt"
m1=$(marken_zeile K1 D20 belege A_OK "" "" 0)
m2=$(marken_zeile K1 D7 abnahme C scripts/abnahme-abgleich.sh "" 2)
ausgabe=$(bauen_ausgabe "$baum" "$m1
$m2" "$D19_OK" "make dod: alle 2 Kettenschritte durchlaufen, 1 davon ohne Urteil (Lage C): D7 abnahme FEHLT=scripts/abnahme-abgleich.sh, Rueckgabewert 2.")
lauf "$baum" Stop "fall05" "$ausgabe" 2
pruefe "05 Eintrag vorhanden, Pruefmittel existiert inzwischen -> 2 (veraltet, LISTE 2)" 2 "" "LISTE 2 D7 abnahme"

# --- Fall 6: Eintrag vorhanden, Schritt meldet A_OK (veraltet) -------------
baum=$(neuer_mock_baum)
printf 'D7 abnahme|scripts/abnahme-abgleich.sh\tADR 0002, 6.12.5, Selbsttest.\n' > "$baum/.claude/hooks/dod-gate-terminierte-lagen.txt"
m1=$(marken_zeile K1 D20 belege A_OK "" "" 0)
m2=$(marken_zeile K1 D7 abnahme A_OK "" "" 0)
ausgabe=$(bauen_ausgabe "$baum" "$m1
$m2" "$D19_OK" "make dod: alle 2 Kettenschritte durchlaufen, keiner ungleich 0, 2 gueltige Marken gezaehlt.")
lauf "$baum" Stop "fall06" "$ausgabe" 0
pruefe "06 Eintrag vorhanden, Schritt meldet A_OK -> 2 (veraltet, LISTE 3)" 2 "" "LISTE 3 D7 abnahme"

# --- Fall 7a: Eintrag ohne Grund --------------------------------------------
baum=$(neuer_mock_baum)
printf 'D7 abnahme|scripts/abnahme-abgleich.sh\t\n' > "$baum/.claude/hooks/dod-gate-terminierte-lagen.txt"
m1=$(marken_zeile K1 D7 abnahme C scripts/abnahme-abgleich.sh "" 2)
ausgabe=$(bauen_ausgabe "$baum" "$m1" "$D19_OK" "make dod: alle 1 Kettenschritte durchlaufen, 1 davon ohne Urteil (Lage C): D7 abnahme FEHLT=scripts/abnahme-abgleich.sh, Rueckgabewert 2.")
lauf "$baum" Stop "fall07a" "$ausgabe" 2
pruefe "07a Eintrag ohne Grund -> 2 (LISTE 4 1)" 2 "" "LISTE 4 1"

# --- Fall 7b: Eintrag mit nicht terminierbarem Pruefmittel (blosser Name) --
baum=$(neuer_mock_baum)
printf 'D11 geheimnisse|gitleaks\tADR 0002, 6.12.5, Selbsttest.\n' > "$baum/.claude/hooks/dod-gate-terminierte-lagen.txt"
m1=$(marken_zeile K1 D11 geheimnisse C gitleaks "" 2)
ausgabe=$(bauen_ausgabe "$baum" "$m1" "$D19_OK" "make dod: alle 1 Kettenschritte durchlaufen, 1 davon ohne Urteil (Lage C): D11 geheimnisse FEHLT=gitleaks, Rueckgabewert 2.")
lauf "$baum" Stop "fall07b" "$ausgabe" 2
pruefe "07b Eintrag mit nicht terminierbarem Pruefmittel -> 2 (LISTE 6 1)" 2 "" "LISTE 6 1"

# --- Fall 7c: Eintrag mit absolutem Pfad ------------------------------------
baum=$(neuer_mock_baum)
printf 'D7 abnahme|/scripts/abnahme-abgleich.sh\tADR 0002, 6.12.5, Selbsttest.\n' > "$baum/.claude/hooks/dod-gate-terminierte-lagen.txt"
m1=$(marken_zeile K1 D7 abnahme C /scripts/abnahme-abgleich.sh "" 2)
ausgabe=$(bauen_ausgabe "$baum" "$m1" "$D19_OK" "make dod: alle 1 Kettenschritte durchlaufen, 1 davon ohne Urteil (Lage C): D7 abnahme FEHLT=/scripts/abnahme-abgleich.sh, Rueckgabewert 2.")
lauf "$baum" Stop "fall07c" "$ausgabe" 2
pruefe "07c Eintrag mit absolutem Pfad -> 2 (LISTE 6 1)" 2 "" "LISTE 6 1"

# --- Fall 8: Marke nennt anderes Pruefmittel als der Schluessel ------------
baum=$(neuer_mock_baum)
printf 'D7 abnahme|scripts/abnahme-abgleich.sh\tADR 0002, 6.12.5, Selbsttest.\n' > "$baum/.claude/hooks/dod-gate-terminierte-lagen.txt"
m1=$(marken_zeile K1 D7 abnahme C ein-anderer-wert "" 2)
ausgabe=$(bauen_ausgabe "$baum" "$m1" "$D19_OK" "make dod: alle 1 Kettenschritte durchlaufen, 1 davon ohne Urteil (Lage C): D7 abnahme FEHLT=ein-anderer-wert, Rueckgabewert 2.")
lauf "$baum" Stop "fall08" "$ausgabe" 2
pruefe "08 Marke nennt anderes Pruefmittel als Schluessel -> 2 (LISTE 5 D7 abnahme)" 2 "" "LISTE 5 D7 abnahme"

# --- Fall 9: stop_hook_active wahr bei roter Kette -> 0, Zaehler unveraendert
baum=$(neuer_mock_baum)
zustand9=$(neu_verzeichnis)
eingabe9=$(baue_eingabe "Stop" "$baum" "fall09" "true")
rufe_gate "$eingabe9" "$zustand9" "$WERKZEUGKASTEN_VOLL" "CLAUDE_PROJECT_DIR=$baum" "MOCK_AUSGABE=roter Muell" "MOCK_RC=2"
gesamt=$((gesamt + 1))
zaehlerdateien9=$(find "$zustand9" -name 'zaehler-*' 2>/dev/null | wc -l | tr -d ' ')
if [ "$G_RC" = "0" ] && printf '%s' "$G_STDOUT" | grep -q "stop_hook_active" && [ "$zaehlerdateien9" = "0" ]; then
  bestanden=$((bestanden + 1)); echo "BESTANDEN  09 stop_hook_active wahr bei roter Kette -> 0, Zaehler unveraendert"
else
  fehlgeschlagene_faelle+=("09 stop_hook_active")
  echo "FEHLGESCHLAGEN  09 stop_hook_active (rc=$G_RC, zaehlerdateien=$zaehlerdateien9)"
fi

# --- Fall 10a (6.12.23 a, vierte Form): alle Schritte gruen, D19 VERLETZT,
# rc 2 -> Gate blockiert mit Schluessel "D19 VERLETZT".
baum=$(neuer_mock_baum)
m1=$(marken_zeile K1 D20 belege A_OK "" "" 0)
ausgabe_10a=$(bauen_ausgabe "$baum" "$m1" "VERLETZT -- versionierter Bestand veraendert." "make dod: alle 1 Kettenschritte durchlaufen, Rahmenpruefung D19 VERLETZT, Rueckgabewert 2.")
lauf "$baum" Stop "fall10a" "$ausgabe_10a" 2
pruefe "10a D19 VERLETZT, Form 4 -> 2" 2 "" "D19 VERLETZT"

# --- Fall 10a-widerspruch: DIESELBE Attrappe UND DERSELBE Baum wie 10a
# (Form-4-Text, D19 VERLETZT), aber MOCK_RC=0 -> Parse-Regel "Rueckgabewert 0
# nur mit Form 1" (6.12.23 a) verletzt -> Schluessel
# "KETTE schlusszeile-widerspruch". Ein NEUER Baum waere hier falsch: die
# Ausgabe nennt den Baum von 10a woertlich in ihrer ersten Zeile, ein anderer
# CLAUDE_PROJECT_DIR ergaebe stattdessen "KETTE baum-widerspruch".
lauf "$baum" Stop "fall10a-widerspruch" "$ausgabe_10a" 0
pruefe "10a-widerspruch dieselbe Attrappe mit rc 0 -> KETTE schlusszeile-widerspruch" 2 "" "KETTE schlusszeile-widerspruch"

# --- Fall 10b: D19 Lage C, Form 4 -------------------------------------------
baum=$(neuer_mock_baum)
m1=$(marken_zeile K1 D20 belege A_OK "" "" 0)
ausgabe=$(bauen_ausgabe "$baum" "$m1" "C -- git fehlt, nicht beobachtet." "make dod: alle 1 Kettenschritte durchlaufen, Rahmenpruefung D19 C, Rueckgabewert 2.")
lauf "$baum" Stop "fall10b" "$ausgabe" 2
pruefe "10b D19 Lage C, Form 4 -> 2" 2 "" "D19 C"

# --- Fall 11: fehlende Pruefmittel (G10) ------------------------------------
baum=$(neuer_mock_baum)
for werkzeug in jq git make timeout flock sha256sum mktemp; do
  wzk=$(neu_verzeichnis)
  baue_werkzeugkasten "$wzk" "$werkzeug"
  zustand=$(neu_verzeichnis)
  eingabe=$(baue_eingabe "Stop" "$baum" "fall11-$werkzeug")
  rufe_gate "$eingabe" "$zustand" "$wzk" "CLAUDE_PROJECT_DIR=$baum" "MOCK_AUSGABE=x" "MOCK_RC=0"
  pruefe "11 fehlendes $werkzeug -> 2, mit Nennung" 2 "" "GATE $werkzeug"
done
# fehlende Liste der terminierten Lagen
baum_ohne_liste=$(neuer_mock_baum)
rm -f "$baum_ohne_liste/.claude/hooks/dod-gate-terminierte-lagen.txt"
lauf "$baum_ohne_liste" Stop "fall11-liste" "x" 0
pruefe "11 fehlende Liste der terminierten Lagen -> 2, mit Nennung" 2 "" "GATE dod-gate-terminierte-lagen.txt"
# fehlendes Makefile
baum_ohne_makefile=$(neu_verzeichnis)
git -C "$baum_ohne_makefile" init -q
mkdir -p "$baum_ohne_makefile/.claude/hooks"
: > "$baum_ohne_makefile/.claude/hooks/dod-gate-terminierte-lagen.txt"
git -C "$baum_ohne_makefile" add -A
git -C "$baum_ohne_makefile" -c user.email=t@example.invalid -c user.name=t commit -q -m init --allow-empty
lauf "$baum_ohne_makefile" Stop "fall11-makefile" "x" 0
pruefe "11 fehlendes Makefile -> 2, mit Nennung" 2 "" "GATE Makefile"

# --- Fall 12: nicht beschreibbares Zustandsverzeichnis bei roter Kette -----
baum=$(neuer_mock_baum)
m1=$(marken_zeile K1 D20 belege A_OK "" "" 0)
m2=$(marken_zeile K1 D3 linter A_FAIL "" "" 2)
ausgabe=$(bauen_ausgabe "$baum" "$m1
$m2" "$D19_OK" "make dod: abgebrochen bei D3 linter, Rueckgabewert 2.")
zustand12_basis=$(neu_verzeichnis)
# chmod-basierte Schreibsperren wirken nicht, wenn dieser Selbsttest als root
# laeuft (root umgeht Dateimodus-Rechte). Stattdessen ein Pfad, der
# STRUKTURELL nicht anlegbar ist: "hindernis" ist eine gewoehnliche DATEI,
# "mkdir -p .../hindernis/darunter" schlaegt damit unabhaengig vom Benutzer
# mit ENOTDIR fehl.
: > "$zustand12_basis/hindernis"
zustand12="$zustand12_basis/hindernis/darunter"
eingabe12=$(baue_eingabe "Stop" "$baum" "fall12")
rufe_gate "$eingabe12" "$zustand12" "$WERKZEUGKASTEN_VOLL" "CLAUDE_PROJECT_DIR=$baum" "MOCK_AUSGABE=$ausgabe" "MOCK_RC=2"
pruefe "12 nicht beschreibbares Zustandsverzeichnis bei roter Kette -> 2, mit Zusatz" 2 "" "nicht zaehlen"
# S-07: N-04s Ausweich muss TATSAECHLICH unter dem festen Pfad entstehen,
# nicht nur behauptet werden.
baum_hash12=$(printf '%s' "$baum" | sha256sum | cut -d' ' -f1)
sperre_datei12="/tmp/r3cosint-dod-gate/sperre-$baum_hash12.lock"
gesamt=$((gesamt + 1))
if [ -f "$sperre_datei12" ]; then
  bestanden=$((bestanden + 1)); echo "BESTANDEN  S-07 Ausweich-Sperrdatei unter /tmp/r3cosint-dod-gate/ entstanden"
  rm -f "$sperre_datei12"
else
  fehlgeschlagene_faelle+=("S-07 Ausweich-Sperrdatei unter /tmp/r3cosint-dod-gate/")
  echo "FEHLGESCHLAGEN  S-07 Ausweich-Sperrdatei erwartet unter $sperre_datei12, nicht gefunden"
fi

# --- Fall 13: innere Zeitueberschreitung ------------------------------------
baum=$(neuer_mock_baum)
lauf "$baum" Stop "fall13" "wird nie gedruckt" 0 "" "" "" "$WERKZEUGKASTEN_SCHNELLER_TIMEOUT" 5
pruefe "13 innere Zeitueberschreitung -> 2" 2 "" "zeitueberschreitung"

# --- Fall 13b: Rueckgabewert weder 0 noch 2 --------------------------------
# Mit einem ECHTEN GNU Make ist dieser Fall nicht herstellbar: jede
# fehlgeschlagene Rezeptzeile wird von GNU Make selbst IMMER zu dessen
# eigenem Rueckgabewert 2 (empirisch geprueft, Uebergabe dieser
# Arbeitseinheit) -- ein "exit 7" im Rezept liefert am Ende trotzdem 2. Die
# Attrappe fuer "make" selbst (WERKZEUGKASTEN_FAKE_MAKE) umgeht NUR diese
# Umwandlung und liefert MOCK_RC unveraendert.
baum=$(neuer_mock_baum)
lauf "$baum" Stop "fall13b" "irgendeine unlesbare Ausgabe" 7 "" "" "" "$WERKZEUGKASTEN_FAKE_MAKE"
pruefe "13b Rueckgabewert weder 0 noch 2 -> 2, mit Nennung" 2 "" "rueckgabewert=7"

echo
echo "--- Eskalation (G8, 6.12.9) ---"
echo

# --- Faelle 14-18: dreimal derselbe Schluessel, viertes Mal Uebergabedatei --
baum=$(neuer_mock_baum)
zustand_esk=$(neu_verzeichnis)
m1=$(marken_zeile K1 D20 belege A_OK "" "" 0)
m2=$(marken_zeile K1 D3 linter A_FAIL "" "" 2)
ausgabe_esk=$(bauen_ausgabe "$baum" "$m1
$m2" "$D19_OK" "make dod: abgebrochen bei D3 linter, Rueckgabewert 2.")

lauf_mit_zustand "$zustand_esk" "$baum" Stop "fall14" "$ausgabe_esk" 2
pruefe "14a erstes Mal -> 2, keine Eskalationsforderung" 2 "" "1\. Mal in Folge"
lauf_mit_zustand "$zustand_esk" "$baum" Stop "fall14" "$ausgabe_esk" 2
pruefe "14b zweites Mal -> 2, keine Eskalationsforderung" 2 "" "2\. Mal in Folge"
lauf_mit_zustand "$zustand_esk" "$baum" Stop "fall14" "$ausgabe_esk" 2
pruefe "14c drittes Mal -> verlangt Uebergabedatei (3.4)" 2 "" "Eskalation 3\.4: D3 linter A_FAIL"

lauf_mit_zustand "$zustand_esk" "$baum" Stop "fall14" "$ausgabe_esk" 2
pruefe "14d viertes Mal ohne Uebergabedatei -> weiterhin 2" 2 "" "erwartet eine Datei"

# Uebergabedatei anlegen, NEU/GEAENDERT nach git status (nicht committet)
mkdir -p "$baum/docs/uebergaben"
printf 'Uebergabe\n\nEskalation 3.4: D3 linter A_FAIL\n' > "$baum/docs/uebergaben/2026-09-02_selbsttest-eskalation.md"
lauf_mit_zustand "$zustand_esk" "$baum" Stop "fall14" "$ausgabe_esk" 2
pruefe "15 Uebergabedatei neu/geaendert -> Durchlass ab dem vierten Mal" 0 '"systemMessage".*Eskalation 3\.4'

# committen -> weiterhin Durchlass (jetzt ueber "im juengsten Commit enthalten")
git -C "$baum" add -A
git -C "$baum" commit -q -m "Eskalationsuebergabe"
lauf_mit_zustand "$zustand_esk" "$baum" Stop "fall14" "$ausgabe_esk" 2
pruefe "16 Uebergabedatei committet und in HEAD -> Durchlass" 0 '"systemMessage".*Eskalation 3\.4'

# ein WEITERER Commit danach -> Uebergabedatei nur noch in einem AELTEREN Commit
printf 'spaeter\n' > "$baum/docs/uebergaben/2026-09-02_noch-eine-datei.md"
git -C "$baum" add -A
git -C "$baum" commit -q -m "weiterer Commit, Eskalationsuebergabe nicht mehr HEAD"
lauf_mit_zustand "$zustand_esk" "$baum" Stop "fall14" "$ausgabe_esk" 2
pruefe "17 Uebergabedatei nur in aelterem Commit -> weiterhin 2" 2 "" "erwartet eine Datei"

# TaskCompleted blockiert trotz derselben (jetzt wieder aktuellen) Uebergabe
# DT-B4: Der Inhalt MUSS sich gegenueber dem letzten Commit aendern -- sonst
# committet git nichts ("nothing to commit"), HEAD bleibt der Commit aus
# Fall 17 (der die Datei NICHT enthaelt), und der Fall bloeckte auch OHNE die
# TaskCompleted-Sonderregel, belegte also nichts. Eine zusaetzliche Zeile
# macht den Inhalt neu; der Commit und seine Wirkung werden selbst geprueft
# statt stillschweigend vorausgesetzt.
printf 'Uebergabe\n\nEskalation 3.4: D3 linter A_FAIL\n\nErneut fuer Fall 18 (TaskCompleted), DT-B4.\n' > "$baum/docs/uebergaben/2026-09-02_selbsttest-eskalation.md"
git -C "$baum" add -A
if ! git -C "$baum" commit -q -m "Eskalationsuebergabe wieder aktuell (Fall 18)"; then
  fehlgeschlagene_faelle+=("18 Vorbereitung: git commit fand keine Aenderung")
  echo "FEHLGESCHLAGEN  18 Vorbereitung: git commit fand keine Aenderung -- die Uebergabedatei war nicht neu genug."
  gesamt=$((gesamt + 1))
elif ! git -C "$baum" diff-tree --no-commit-id --name-only -r HEAD | grep -qF "docs/uebergaben/2026-09-02_selbsttest-eskalation.md"; then
  fehlgeschlagene_faelle+=("18 Vorbereitung: Uebergabedatei nicht in HEAD")
  echo "FEHLGESCHLAGEN  18 Vorbereitung: die Uebergabedatei steht nicht im juengsten Commit (HEAD)."
  gesamt=$((gesamt + 1))
fi
lauf_mit_zustand "$zustand_esk" "$baum" TaskCompleted "fall14" "$ausgabe_esk" 2
pruefe "18 dieselbe Eskalation (echt in HEAD) auf TaskCompleted -> weiterhin 2" 2 "" "TaskCompleted blockiert"

# --- S-04 (Entscheid d): ein weiterer Stop-Lauf am selben Schluessel ------
# Der Zaehler wird bei einem Eskalations-Durchlass NICHT geloescht, sondern
# zaehlt WEITER -- "unveraendert" waere die falsche Beschreibung. Die Zeilen
# 14-18 haben den Zaehler bereits mehrfach erhoeht (auch bei einem Durchlass
# schreibt blockieren_mit_zaehlung die neue Zahl VOR der Fallunterscheidung);
# der erwartete Wert wird deshalb aus dem VORHER gelesenen Bestand berechnet,
# nicht als feste Zahl geraten (dieselbe Lehre wie DT-B4/S-01: die Behauptung
# muss die Zaehlerdatei selbst lesen, nicht nur den Rueckgabewert).
zaehler_datei_s04="$zustand_esk/r3cosint/dod-gate/zaehler-$(printf '%s' 'fall14' | sha256sum | cut -d' ' -f1)"
alter_wert_s04=$(sed -n '2p' "$zaehler_datei_s04" 2>/dev/null || echo 0)
case "$alter_wert_s04" in ''|*[!0-9]*) alter_wert_s04=0 ;; esac
lauf_mit_zustand "$zustand_esk" "$baum" Stop "fall14" "$ausgabe_esk" 2
erwarteter_wert_s04=$((alter_wert_s04 + 1))
pruefe "S-04a weiterer Stop-Lauf am selben Schluessel -> Durchlass, ${erwarteter_wert_s04}. Mal in Folge" 0 "\"systemMessage\".*${erwarteter_wert_s04}\\. Mal in Folge"
gesamt=$((gesamt + 1))
if [ -f "$zaehler_datei_s04" ] && [ "$(sed -n '2p' "$zaehler_datei_s04" 2>/dev/null)" = "$erwarteter_wert_s04" ]; then
  bestanden=$((bestanden + 1)); echo "BESTANDEN  S-04b Zaehlerdatei zaehlt weiter (Inhalt: $erwarteter_wert_s04), wird NICHT geloescht"
else
  fehlgeschlagene_faelle+=("S-04b Zaehlerdatei zaehlt weiter")
  echo "FEHLGESCHLAGEN  S-04b Zaehlerdatei (Datei='$zaehler_datei_s04', 2. Zeile='$(sed -n '2p' "$zaehler_datei_s04" 2>/dev/null)', erwartet='$erwarteter_wert_s04')"
fi
lauf_mit_zustand "$zustand_esk" "$baum" TaskCompleted "fall14" "$ausgabe_esk" 2
pruefe "S-04c TaskCompleted nach weiterem Durchlass -> weiterhin 2" 2 "" "TaskCompleted blockiert"

echo
echo "--- Weitere Formfaelle ---"
echo

# --- Fall 19: mehrere ungedeckte Lagen C + D19-Befund -----------------------
baum=$(neuer_mock_baum)
m1=$(marken_zeile K1 D20 belege A_OK "" "" 0)
m2=$(marken_zeile K1 D7 abnahme C scripts/abnahme-abgleich.sh "" 2)
m3=$(marken_zeile K1 D10 prototyp-trennung C scripts/prototyp-trennung-pruefen.sh "" 2)
ausgabe=$(bauen_ausgabe "$baum" "$m1
$m2
$m3" "VERLETZT -- versionierter Bestand veraendert." "make dod: alle 3 Kettenschritte durchlaufen, 2 davon ohne Urteil (Lage C): D7 abnahme FEHLT=scripts/abnahme-abgleich.sh, D10 prototyp-trennung FEHLT=scripts/prototyp-trennung-pruefen.sh, Rueckgabewert 2.")
lauf "$baum" Stop "fall19" "$ausgabe" 2
pruefe "19 mehrere ungedeckte Lagen C + D19-Befund -> erste Abweichung (D7)" 2 "" "Schluessel: D7 abnahme C"

# --- Fall 20: Marke mit FEHLT= und SCHWELLE= zugleich -----------------------
baum=$(neuer_mock_baum)
printf 'D3 linter|scripts/nicht-vorhanden.sh\tADR 0002, 6.12.5, Selbsttest.\n' > "$baum/.claude/hooks/dod-gate-terminierte-lagen.txt"
m1=$(marken_zeile K1 D3 linter C scripts/nicht-vorhanden.sh OHNE_SCHWELLE 2)
ausgabe=$(bauen_ausgabe "$baum" "$m1" "$D19_OK" "make dod: alle 1 Kettenschritte durchlaufen, 1 davon ohne Urteil (Lage C): D3 linter FEHLT=scripts/nicht-vorhanden.sh, Rueckgabewert 2.")
lauf "$baum" Stop "fall20" "$ausgabe" 2
pruefe "20 FEHLT= und SCHWELLE= zugleich -> richtig zerlegt, gedeckt" 0 '"systemMessage".*D3 linter'

# --- Fall 21: D19-Zeile in allen vier Schluesselwortformen -----------------
# Jede Form gepaart mit der Schlusszeile, die "make dod" nach 6.12.23 a
# tatsaechlich dazu ausgeben wuerde: OHNE_BEFUND/B -> Form 1 (rc 0 AUF DER
# KETTENSEITE, D19 Lage B hebt gesamt_rc nicht), VERLETZT/C -> Form 4 (rc 2).
# ERWARTET ist der Rueckgabewert des GATES, nicht der Kette -- bei "B" weichen
# beide voneinander ab: die Kette meldet sauber (Form 1, rc 0), das Gate
# blockiert trotzdem, weil es selbst einen echten Arbeitsbaum bestimmt hat und
# D19 "kein Git-Arbeitsbaum" dem widerspricht (6.12.4, "D19 B-widerspruch").
# N-02 (6.12.19): ALLE VIER Schluesselwoerter je MIT und OHNE Zusatztext --
# vorher deckten nur 5 von 8 Kombinationen ab (VERLETZT./B./C. ohne Zusatz
# fehlten). Das Schluesselwort steht jetzt als EIGENES Feld (nicht mehr aus
# "form" abgeleitet) -- "${form%% *}" liefert bei "VERLETZT." (kein
# Leerzeichen) faelschlich "VERLETZT." samt Punkt und haette eine unlesbare
# D19-Zeile gebaut.
# S-01: jeder Fall prueft jetzt zusaetzlich zum Rueckgabewert den ZAEHL-
# SCHLUESSEL selbst (fuenftes Feld) -- vor allem fuer "B" den Schluessel
# "D19 B-widerspruch"; eine Pruefung, die nur den Rueckgabewert liest, kann
# einen richtigen Rueckgabewert aus dem falschen Schluessel nicht von einem
# richtigen aus dem richtigen Schluessel unterscheiden (dieselbe Fehlerklasse
# wie DT-B4).
baum=$(neuer_mock_baum)
m1=$(marken_zeile K1 D20 belege A_OK "" "" 0)
for eintrag in \
  "OHNE_BEFUND|OHNE_BEFUND -- Text.|erfolg|0|0|" \
  "OHNE_BEFUND|OHNE_BEFUND.|erfolg|0|0|" \
  "VERLETZT|VERLETZT -- Text.|d19|2|2|D19 VERLETZT" \
  "VERLETZT|VERLETZT.|d19|2|2|D19 VERLETZT" \
  "B|B -- Text.|erfolg|0|2|D19 B-widerspruch" \
  "B|B.|erfolg|0|2|D19 B-widerspruch" \
  "C|C -- Text.|d19|2|2|D19 C" \
  "C|C.|d19|2|2|D19 C"; do
  schluesselwort="${eintrag%%|*}"
  rest0="${eintrag#*|}"
  form="${rest0%%|*}"
  rest="${rest0#*|}"
  art="${rest%%|*}"
  rest2="${rest#*|}"
  mock_rc="${rest2%%|*}"
  rest3="${rest2#*|}"
  erwartet="${rest3%%|*}"
  erwarteter_schluessel="${rest3#*|}"
  if [ "$art" = "erfolg" ]; then
    schluss="make dod: alle 1 Kettenschritte durchlaufen, keiner ungleich 0, 1 gueltige Marken gezaehlt."
  else
    schluss="make dod: alle 1 Kettenschritte durchlaufen, Rahmenpruefung D19 ${schluesselwort}, Rueckgabewert 2."
  fi
  ausgabe=$(bauen_ausgabe "$baum" "$m1" "$form" "$schluss")
  lauf "$baum" Stop "fall21-$form" "$ausgabe" "$mock_rc"
  if [ -n "$erwarteter_schluessel" ]; then
    pruefe "21 D19-Form '$form' richtig zugeordnet (Schluessel $erwarteter_schluessel)" "$erwartet" "" "Schluessel: $erwarteter_schluessel"
  else
    pruefe "21 D19-Form '$form' richtig zugeordnet" "$erwartet"
  fi
done

# --- Fall 21b (6.12.23 b): LISTE vor der ersten Kettenabweichung -----------
# D3 linter meldet A_FAIL als ERSTE Uebersichtszeile; D7 abnahme traegt einen
# von der Liste abweichenden FEHLT-Wert (Selbstpruefung 5) als SPAETERE Zeile.
# Trotz der frueheren Position von A_FAIL in der Uebersicht muss der
# LISTE-Schluessel gewinnen (Rangfolge GATE -> LISTE -> erste
# Kettenabweichung -> D19, 6.12.23 b).
baum=$(neuer_mock_baum)
printf 'D7 abnahme|scripts/abnahme-abgleich.sh\tADR 0002, 6.12.5, Selbsttest.\n' > "$baum/.claude/hooks/dod-gate-terminierte-lagen.txt"
m1=$(marken_zeile K1 D3 linter A_FAIL "" "" 2)
m2=$(marken_zeile K1 D7 abnahme C ein-anderer-wert "" 2)
ausgabe=$(bauen_ausgabe "$baum" "$m1
$m2" "$D19_OK" "make dod: abgebrochen bei D3 linter, Rueckgabewert 2.")
lauf "$baum" Stop "fall-reihenfolge" "$ausgabe" 2
pruefe "21b Reihenfolge: LISTE 5 vor frueherer Kettenabweichung (A_FAIL)" 2 "" "Schluessel: LISTE 5 D7 abnahme"

# --- Fall 22: TaskCompleted bei roter Kette ---------------------------------
baum=$(neuer_mock_baum)
m1=$(marken_zeile K1 D3 linter A_FAIL "" "" 2)
ausgabe=$(bauen_ausgabe "$baum" "$m1" "$D19_OK" "make dod: abgebrochen bei D3 linter, Rueckgabewert 2.")
lauf "$baum" TaskCompleted "fall22" "$ausgabe" 2
pruefe "22 TaskCompleted bei roter Kette -> 2" 2

echo
echo "--- SubagentStop und Rollenaufloesung (G13, 6.12.14) ---"
echo

# --- Fall 23: Rolle mit Bash, ohne Edit/Write/NotebookEdit -----------------
baum=$(neuer_mock_baum)
zustand23=$(neu_verzeichnis)
eingabe23=$(baue_eingabe "SubagentStop" "$baum" "fall23" "false" "a1" "attrappe-pruefer")
rufe_gate "$eingabe23" "$zustand23" "$WERKZEUGKASTEN_VOLL" "CLAUDE_PROJECT_DIR=$baum" "MOCK_AUSGABE=roter Muell, duerfte nie gelesen werden" "MOCK_RC=2"
pruefe "23 SubagentStop Rolle ohne Schreibrecht -> 0, kein Lauf" 0 '"systemMessage".*kein Werkzeug mit Schreibrecht'

# --- Fall 24: Rolle mit Edit/Write -> Kette laeuft --------------------------
baum=$(neuer_mock_baum)
m1=$(marken_zeile K1 D20 belege A_OK "" "" 0)
ausgabe=$(bauen_ausgabe "$baum" "$m1" "$D19_OK" "make dod: alle 1 Kettenschritte durchlaufen, keiner ungleich 0, 1 gueltige Marken gezaehlt.")
lauf "$baum" SubagentStop "fall24" "$ausgabe" 0 "false" "a1" "attrappe-schreiber"
pruefe "24 SubagentStop Rolle mit Edit/Write -> Kette laeuft, sauberes Gruen" 0

# --- Fall 25: agent_type ueber name: aufgeloest, nicht ueber Dateinamen ----
# "anders-benannt.md" traegt "name: attrappe-pruefer" -- Datei- und Rollenname
# weichen absichtlich voneinander ab (siehe neuer_mock_baum).
baum=$(neuer_mock_baum)
zustand25=$(neu_verzeichnis)
eingabe25=$(baue_eingabe "SubagentStop" "$baum" "fall25" "false" "a1" "attrappe-pruefer")
rufe_gate "$eingabe25" "$zustand25" "$WERKZEUGKASTEN_VOLL" "CLAUDE_PROJECT_DIR=$baum" "MOCK_AUSGABE=roter Muell" "MOCK_RC=2"
pruefe "25 agent_type ueber name: aufgeloest (nicht Dateiname) -> kein Lauf" 0 '"systemMessage".*kein Werkzeug mit Schreibrecht'

# --- Fall 26: unbekannter/leerer/mehrdeutiger agent_type -> Kette laeuft ---
baum=$(neuer_mock_baum)
m1=$(marken_zeile K1 D20 belege A_OK "" "" 0)
ausgabe=$(bauen_ausgabe "$baum" "$m1" "$D19_OK" "make dod: alle 1 Kettenschritte durchlaufen, keiner ungleich 0, 1 gueltige Marken gezaehlt.")
lauf "$baum" SubagentStop "fall26a" "$ausgabe" 0 "false" "a1" "voellig-unbekannte-rolle"
pruefe "26a unbekannter agent_type -> Kette laeuft" 0
lauf "$baum" SubagentStop "fall26b" "$ausgabe" 0 "false" "a1" ""
pruefe "26b leerer agent_type -> Kette laeuft" 0
# Mehrdeutig: zweite Rolle mit demselben name: anlegen.
cp "$baum/.claude/agents/attrappe-schreiber.md" "$baum/.claude/agents/zweite-kopie.md"
git -C "$baum" add -A
git -C "$baum" commit -q -m "mehrdeutiger agent_type"
lauf "$baum" SubagentStop "fall26c" "$ausgabe" 0 "false" "a1" "attrappe-schreiber"
pruefe "26c mehrdeutiger agent_type (zwei Treffer) -> Kette laeuft" 0

echo
echo "--- N-03 (G13, 6.12.14): ECHTE Rollendateien, nicht die Attrappe ------"
echo

# --- Fall N-03a: echte Rolle static-software-tester (kein Edit/Write) ------
baum=$(neuer_mock_baum)
cp "$REPO_WURZEL/.claude/agents/static-software-tester.md" "$baum/.claude/agents/static-software-tester.md"
zustand_sst=$(neu_verzeichnis)
eingabe_sst=$(baue_eingabe "SubagentStop" "$baum" "fall-sst" "false" "a1" "static-software-tester")
rufe_gate "$eingabe_sst" "$zustand_sst" "$WERKZEUGKASTEN_VOLL" "CLAUDE_PROJECT_DIR=$baum" "MOCK_AUSGABE=roter Muell, duerfte nie gelesen werden" "MOCK_RC=2"
pruefe "N-03a echte Rolle static-software-tester (kein Edit/Write) -> 0, kein Lauf" 0 '"systemMessage".*kein Werkzeug mit Schreibrecht'

# --- Fall N-03b: echte Rolle pentester (kein Edit/Write) -------------------
baum=$(neuer_mock_baum)
cp "$REPO_WURZEL/.claude/agents/pentester.md" "$baum/.claude/agents/pentester.md"
zustand_pt=$(neu_verzeichnis)
eingabe_pt=$(baue_eingabe "SubagentStop" "$baum" "fall-pt" "false" "a1" "pentester")
rufe_gate "$eingabe_pt" "$zustand_pt" "$WERKZEUGKASTEN_VOLL" "CLAUDE_PROJECT_DIR=$baum" "MOCK_AUSGABE=roter Muell, duerfte nie gelesen werden" "MOCK_RC=2"
pruefe "N-03b echte Rolle pentester (kein Edit/Write) -> 0, kein Lauf" 0 '"systemMessage".*kein Werkzeug mit Schreibrecht'

# --- Fall N-03c (Gegenfall): echte Rolle devops-engineer (Edit/Write) ------
baum=$(neuer_mock_baum)
cp "$REPO_WURZEL/.claude/agents/devops-engineer.md" "$baum/.claude/agents/devops-engineer.md"
m1=$(marken_zeile K1 D20 belege A_OK "" "" 0)
ausgabe=$(bauen_ausgabe "$baum" "$m1" "$D19_OK" "make dod: alle 1 Kettenschritte durchlaufen, keiner ungleich 0, 1 gueltige Marken gezaehlt.")
lauf "$baum" SubagentStop "fall-devops" "$ausgabe" 0 "false" "a1" "devops-engineer"
pruefe "N-03c echte Rolle devops-engineer (Edit/Write) -> Kette laeuft, sauberes Gruen" 0

echo
echo "--- N-05 (6.12.23 b): LISTE-Reihenfolge bei mehreren fehlerhaften Zeilen"
echo

# --- Fall N-05: Verstoss gegen Selbstpruefung 6 in Zeile 1, gegen 4 in Zeile 2
# Erwartet: die FRUEHERE Zeile (6) gewinnt, unabhaengig von der Pruefungsart.
baum=$(neuer_mock_baum)
printf 'D11 geheimnisse|gitleaks\tADR 0002, 6.12.5, Selbsttest.\nD7 abnahme|scripts/abnahme-abgleich.sh\tGrund ohne die Wendung.\n' > "$baum/.claude/hooks/dod-gate-terminierte-lagen.txt"
m1=$(marken_zeile K1 D20 belege A_OK "" "" 0)
ausgabe=$(bauen_ausgabe "$baum" "$m1" "$D19_OK" "make dod: alle 1 Kettenschritte durchlaufen, keiner ungleich 0, 1 gueltige Marken gezaehlt.")
lauf "$baum" Stop "fall-n05" "$ausgabe" 0
pruefe "N-05 Verstoss 6 (Zeile 1) vor Verstoss 4 (Zeile 2) -> LISTE 6 1" 2 "" "Schluessel: LISTE 6 1"

echo
echo "--- B-01 (set -u): HOME und XDG_STATE_HOME fehlen beide -------------"
echo

# --- Fall B-01: kein HOME, kein XDG_STATE_HOME -> KEIN Abbruch mit rc=1 ----
baum=$(neuer_mock_baum)
m1=$(marken_zeile K1 D20 belege A_OK "" "" 0)
ausgabe=$(bauen_ausgabe "$baum" "$m1" "$D19_OK" "make dod: alle 1 Kettenschritte durchlaufen, keiner ungleich 0, 1 gueltige Marken gezaehlt.")
eingabe_b01=$(baue_eingabe "Stop" "$baum" "fall-b01")
rufe_gate_ohne_home "$eingabe_b01" "$WERKZEUGKASTEN_VOLL" "CLAUDE_PROJECT_DIR=$baum" "MOCK_AUSGABE=$ausgabe" "MOCK_RC=0"
# S-02/S-13: seit dem Nachtrag meldet ein sonst sauberes Gruen den Ausfall
# des Zaehlwerks -- B-01s Lage (weder XDG_STATE_HOME noch HOME gesetzt) ist
# GENAU dieser Fall, die Meldung muss "nicht bestimmbar" nennen (nicht
# "nicht beschreibbar", das waere der ANDERE Fall, S-13).
pruefe "B-01 weder HOME noch XDG_STATE_HOME gesetzt -> 0, kein Absturz (set -u), meldet 'nicht bestimmbar'" 0 '"systemMessage".*nicht bestimmbar.*weder XDG_STATE_HOME noch HOME gesetzt'
if [ -n "$G_STDERR" ]; then
  fehlgeschlagene_faelle+=("B-01 stderr sollte bei rc=0 leer sein")
  gesamt=$((gesamt + 1))
  echo "FEHLGESCHLAGEN  B-01 stderr sollte bei rc=0 leer sein (stderr='$G_STDERR')"
fi

echo
echo "--- B-02/B-03/DT-B5 (6.12.13): Baumbestimmung ueber show-toplevel ----"
echo

# Gemeinsame gruene Kettenausgabe fuer alle fuenf G12-Faelle; "geprueft wird"
# nennt jeweils die vom Test selbst als korrekt erwartete, physisch
# aufgeloeste Wurzel -- weicht das Gate davon ab, meldet es
# "KETTE baum-widerspruch" und der Fall wird nicht mit 0/leer enden.
g12_pruefen() {
  local beschreibung="$1" cwd_wert="$2" proj_wert="$3" erwartete_wurzel="$4"
  local m1 ausgabe zustand eingabe
  m1=$(marke K1 D20 belege A_OK)
  ausgabe=$(bauen_ausgabe "$erwartete_wurzel" "$m1 (rueckgabewert=0)" "$D19_OK" "make dod: alle 1 Kettenschritte durchlaufen, keiner ungleich 0, 1 gueltige Marken gezaehlt.")
  zustand=$(neu_verzeichnis)
  eingabe=$(baue_eingabe "Stop" "$cwd_wert" "fall-g12-$beschreibung")
  rufe_gate "$eingabe" "$zustand" "$WERKZEUGKASTEN_VOLL" "CLAUDE_PROJECT_DIR=$proj_wert" "MOCK_AUSGABE=$ausgabe" "MOCK_RC=0"
  echo "MELDUNG  $beschreibung: aufgeloeste Wurzel (vom Test erwartet) = $erwartete_wurzel"
  gesamt=$((gesamt + 1))
  if [ "$G_RC" = "0" ] && [ -z "$G_STDOUT" ] && [ -z "$G_STDERR" ]; then
    bestanden=$((bestanden + 1)); echo "BESTANDEN  $beschreibung -> 0, sauberes Gruen (Wurzel richtig aufgeloest)"
  else
    fehlgeschlagene_faelle+=("$beschreibung")
    echo "FEHLGESCHLAGEN  $beschreibung (rc=$G_RC, stdout='$G_STDOUT', stderr='$G_STDERR')"
  fi
}

# --- B-02: cwd MIT Schraegstrich am Ende ------------------------------------
baum=$(neuer_mock_baum)
g12_pruefen "B-02-schraegstrich" "$baum/" "$baum/" "$baum"

# --- B-03: cwd UEBER EINEN SYMLINK ------------------------------------------
baum=$(neuer_mock_baum)
symlink_verz=$(neu_verzeichnis)
ln -s "$baum" "$symlink_verz/verweis"
g12_pruefen "B-03-symlink" "$symlink_verz/verweis" "$symlink_verz/verweis" "$baum"

# --- B-03: cwd in einem UNTERVERZEICHNIS, CLAUDE_PROJECT_DIR = Wurzel ------
baum=$(neuer_mock_baum)
mkdir -p "$baum/ein/unterverzeichnis"
g12_pruefen "B-03-unterverzeichnis" "$baum/ein/unterverzeichnis" "$baum" "$baum"

# --- DT-B5a: cwd AUSSERHALB jedes Repositories -> Rueckfall auf PROJECT_DIR
baum=$(neuer_mock_baum)
ausserhalb=$(neu_verzeichnis)
g12_pruefen "DT-B5-ausserhalb-repo" "$ausserhalb" "$baum" "$baum"

# --- DT-B5b: cwd in einem ZWEITEN Arbeitsbaum (git worktree add) -----------
baum=$(neuer_mock_baum)
worktree_verz=$(neu_verzeichnis)
rm -rf "$worktree_verz"
if git -C "$baum" worktree add -q -b fall-worktree "$worktree_verz" >/dev/null 2>&1; then
  AUFRAEUM_VERZEICHNISSE+=("$worktree_verz")
  worktree_wurzel=$(cd "$worktree_verz" && pwd -P)
  g12_pruefen "DT-B5-worktree" "$worktree_wurzel" "$baum" "$worktree_wurzel"
else
  fehlgeschlagene_faelle+=("DT-B5-worktree Vorbereitung: git worktree add fehlgeschlagen")
  echo "FEHLGESCHLAGEN  DT-B5-worktree Vorbereitung: git worktree add fehlgeschlagen"
  gesamt=$((gesamt + 1))
fi

echo
echo "--- N-04: Sperre entfaellt nicht still, wenn Zustandsverzeichnis und"
echo "    /tmp-Ausweich beide nicht moeglich sind ----------------------------"
echo

# --- Fall N-04: weder Zustandsverzeichnis noch fester /tmp-Ausweich moeglich
baum=$(neuer_mock_baum)
m1=$(marken_zeile K1 D20 belege A_OK "" "" 0)
ausgabe=$(bauen_ausgabe "$baum" "$m1" "$D19_OK" "make dod: alle 1 Kettenschritte durchlaufen, keiner ungleich 0, 1 gueltige Marken gezaehlt.")
zustand_n04_basis=$(neu_verzeichnis)
# Wie Fall 12: "hindernis" ist eine DATEI, "mkdir -p .../hindernis/darunter"
# schlaegt damit strukturell fehl, unabhaengig vom Benutzer (root umgeht
# Dateimodus-Rechte, aber nicht ENOTDIR).
: > "$zustand_n04_basis/hindernis"
zustand_n04="$zustand_n04_basis/hindernis/darunter"
sperre_fest="/tmp/r3cosint-dod-gate"
sperre_fest_war_verzeichnis=0
sperre_fest_sicherung=$(neu_verzeichnis)
if [ -d "$sperre_fest" ]; then
  sperre_fest_war_verzeichnis=1
  mv "$sperre_fest" "$sperre_fest_sicherung/verzeichnis"
fi
: > "$sperre_fest"
eingabe_n04=$(baue_eingabe "Stop" "$baum" "fall-n04")
rufe_gate "$eingabe_n04" "$zustand_n04" "$WERKZEUGKASTEN_VOLL" "CLAUDE_PROJECT_DIR=$baum" "MOCK_AUSGABE=$ausgabe" "MOCK_RC=0"
rm -f "$sperre_fest"
if [ "$sperre_fest_war_verzeichnis" -eq 1 ]; then
  mv "$sperre_fest_sicherung/verzeichnis" "$sperre_fest"
fi
pruefe "N-04 weder Zustandsverzeichnis noch /tmp-Ausweich moeglich -> 0, meldet fehlende Sperre" 0 '"systemMessage".*Sperre nicht aktiv'

echo
echo "--- N-06: TMPDIR zeigt in den Baum -- Wegwerfdatei darf nicht dort landen"
echo

# --- Fall N-06: TMPDIR im Scheinbaum ----------------------------------------
baum=$(neuer_mock_baum)
tmp_im_baum="$baum/.tmp-im-baum"
mkdir -p "$tmp_im_baum"
m1=$(marken_zeile K1 D20 belege A_OK "" "" 0)
ausgabe=$(bauen_ausgabe "$baum" "$m1" "$D19_OK" "make dod: alle 1 Kettenschritte durchlaufen, keiner ungleich 0, 1 gueltige Marken gezaehlt.")
zustand_n06=$(neu_verzeichnis)
eingabe_n06=$(baue_eingabe "Stop" "$baum" "fall-n06")
rufe_gate "$eingabe_n06" "$zustand_n06" "$WERKZEUGKASTEN_VOLL" "CLAUDE_PROJECT_DIR=$baum" "MOCK_AUSGABE=$ausgabe" "MOCK_RC=0" "TMPDIR=$tmp_im_baum"
dateien_im_tmp=$(find "$tmp_im_baum" -type f 2>/dev/null | wc -l | tr -d ' ')
gesamt=$((gesamt + 1))
if [ "$G_RC" = "0" ] && [ -z "$G_STDOUT" ] && [ -z "$G_STDERR" ] && [ "$dateien_im_tmp" = "0" ]; then
  bestanden=$((bestanden + 1)); echo "BESTANDEN  N-06 TMPDIR im Baum -> 0, sauberes Gruen, keine Datei im Baum"
else
  fehlgeschlagene_faelle+=("N-06 TMPDIR im Baum")
  echo "FEHLGESCHLAGEN  N-06 TMPDIR im Baum (rc=$G_RC, stdout='$G_STDOUT', stderr='$G_STDERR', dateien=$dateien_im_tmp)"
fi

echo
echo "--- S-07/N-06b: beide Auswege fuer die eigene Wegwerfdatei versperrt -"
echo

# --- Fall S-07/N-06b: mktemp-Attrappe -- erster Aufruf liefert einen Pfad
#     IM Baum, "-p /tmp" (der Ausweich) schlaegt an --------------------------
baum=$(neuer_mock_baum)
m1=$(marken_zeile K1 D20 belege A_OK "" "" 0)
ausgabe=$(bauen_ausgabe "$baum" "$m1" "$D19_OK" "make dod: alle 1 Kettenschritte durchlaufen, keiner ungleich 0, 1 gueltige Marken gezaehlt.")
zustand_mktemp=$(neu_verzeichnis)
eingabe_mktemp=$(baue_eingabe "Stop" "$baum" "fall-mktemp-gate")
rufe_gate "$eingabe_mktemp" "$zustand_mktemp" "$WERKZEUGKASTEN_FAKE_MKTEMP" "CLAUDE_PROJECT_DIR=$baum" "MOCK_AUSGABE=$ausgabe" "MOCK_RC=0" "FAKE_MKTEMP_ZIEL=$baum"
pruefe "S-07/N-06b eigene Wegwerfdatei im Baum, /tmp-Ausweich schlaegt fehl -> GATE mktemp" 2 "" "GATE mktemp"

echo
echo "--- DT2-B2: TMPDIR wird an die Kette SELBST weitergereicht -----------"
echo

# --- Fall DT2-B2: die Kette ruft SELBST mktemp auf (wie D6/D12 im echten
#     Makefile) -- ihre eigene Wegwerfdatei darf trotz TMPDIR=Baum nicht im
#     Baum entstehen, weil das Gate TMPDIR fuer den Kettenlauf auf das
#     (bereits sicher aufgeloeste) Verzeichnis der EIGENEN Wegwerfdatei setzt.
baum=$(neuer_mock_baum)
m1=$(marken_zeile K1 D20 belege A_OK "" "" 0)
ausgabe=$(bauen_ausgabe "$baum" "$m1" "$D19_OK" "make dod: alle 1 Kettenschritte durchlaufen, keiner ungleich 0, 1 gueltige Marken gezaehlt.")
zustand_dtb2=$(neu_verzeichnis)
spur_dtb2=$(neu_verzeichnis)/spur
eingabe_dtb2=$(baue_eingabe "Stop" "$baum" "fall-dtb2")
rufe_gate "$eingabe_dtb2" "$zustand_dtb2" "$WERKZEUGKASTEN_VOLL" "CLAUDE_PROJECT_DIR=$baum" "MOCK_AUSGABE=$ausgabe" "MOCK_RC=0" "MOCK_TMP_SPUR=$spur_dtb2" "TMPDIR=$baum"
gesamt=$((gesamt + 1))
kette_eigene_tmp=$(cat "$spur_dtb2" 2>/dev/null || true)
if [ "$G_RC" = "0" ] && [ -n "$kette_eigene_tmp" ]; then
  case "$kette_eigene_tmp" in
    "$baum"|"$baum"/*)
      fehlgeschlagene_faelle+=("DT2-B2 TMPDIR an Kette weitergereicht")
      echo "FEHLGESCHLAGEN  DT2-B2: die Kette legte ihre eigene Wegwerfdatei im Baum an ($kette_eigene_tmp)"
      ;;
    *)
      bestanden=$((bestanden + 1)); echo "BESTANDEN  DT2-B2 TMPDIR an Kette weitergereicht, eigene mktemp-Datei ($kette_eigene_tmp) liegt ausserhalb des Baums"
      ;;
  esac
else
  fehlgeschlagene_faelle+=("DT2-B2 TMPDIR an Kette weitergereicht")
  echo "FEHLGESCHLAGEN  DT2-B2 (rc=$G_RC, spur='$kette_eigene_tmp')"
fi

echo
echo "--- S-03/S-10: Baumzeile falsch bzw. fehlend --------------------------"
echo

# --- Fall S-03: Baumzeile nennt einen ANDEREN Baum -> KETTE baum-widerspruch
baum=$(neuer_mock_baum)
anderer_baum_s03=$(neu_verzeichnis)
m1=$(marken_zeile K1 D20 belege A_OK "" "" 0)
ausgabe_s03=$(bauen_ausgabe "$anderer_baum_s03" "$m1" "$D19_OK" "make dod: alle 1 Kettenschritte durchlaufen, keiner ungleich 0, 1 gueltige Marken gezaehlt.")
lauf "$baum" Stop "fall-s03" "$ausgabe_s03" 0
pruefe "S-03 Baumzeile nennt anderen Baum -> KETTE baum-widerspruch" 2 "" "Schluessel: KETTE baum-widerspruch"

# --- Fall S-10: Baumzeile FEHLT GANZ -> KETTE ausgabe-unlesbar (kein
#     Widerspruch -- ein Widerspruch braucht zwei Angaben, hier fehlt eine) --
baum=$(neuer_mock_baum)
m1=$(marken_zeile K1 D20 belege A_OK "" "" 0)
ausgabe_s10=$(printf '=== Uebersicht Definition-of-Done-Kette (make dod) ===\n%s\n\nmake dod: D19: %s\n%s\n' \
  "$m1" "$D19_OK" "make dod: alle 1 Kettenschritte durchlaufen, keiner ungleich 0, 1 gueltige Marken gezaehlt.")
lauf "$baum" Stop "fall-s10" "$ausgabe_s10" 0
pruefe "S-10 fehlende Baumzeile -> KETTE ausgabe-unlesbar (nicht baum-widerspruch)" 2 "" "Schluessel: KETTE ausgabe-unlesbar"

echo
echo "--- S-11: Markenzahl gegen die Schlusszeile selbst -------------------"
echo

# --- Fall S-11a: Form 1 behauptet 14 Marken, die Uebersicht traegt KEINE ---
baum=$(neuer_mock_baum)
ausgabe_s11a=$(printf 'make dod: geprueft wird %s.\n=== Uebersicht Definition-of-Done-Kette (make dod) ===\n\nmake dod: D19: %s\nmake dod: alle 14 Kettenschritte durchlaufen, keiner ungleich 0, 14 gueltige Marken gezaehlt.\n' "$baum" "$D19_OK")
lauf "$baum" Stop "fall-s11a" "$ausgabe_s11a" 0
pruefe "S-11a null Marken trotz Form-1-Erfolg -> KETTE ausgabe-unlesbar" 2 "" "Schluessel: KETTE ausgabe-unlesbar"

# --- Fall S-11b: Form 1 behauptet 3 Marken, die Uebersicht traegt nur EINE -
baum=$(neuer_mock_baum)
m1=$(marken_zeile K1 D20 belege A_OK "" "" 0)
ausgabe_s11b=$(bauen_ausgabe "$baum" "$m1" "$D19_OK" "make dod: alle 3 Kettenschritte durchlaufen, keiner ungleich 0, 3 gueltige Marken gezaehlt.")
lauf "$baum" Stop "fall-s11b" "$ausgabe_s11b" 0
pruefe "S-11b Markenzahl (1) weicht von Schlusszeile (3) ab -> KETTE ausgabe-unlesbar" 2 "" "Schluessel: KETTE ausgabe-unlesbar"

echo
echo "--- S-05: N-08 gegen das ECHTE Makefile --------------------------------"
echo

# --- Fall S-05: make -s nachweise mit PATH ohne git -> FEHLT=git -----------
scheinbaum_s05=$(neu_verzeichnis)
git -C "$scheinbaum_s05" init -q
git -C "$scheinbaum_s05" config user.email "selbsttest@example.invalid"
git -C "$scheinbaum_s05" config user.name "Selbsttest"
cp "$ECHTES_MAKEFILE" "$scheinbaum_s05/Makefile"
git -C "$scheinbaum_s05" add -A
git -C "$scheinbaum_s05" commit -q -m init
wzk_s05=$(neu_verzeichnis)
baue_werkzeugkasten "$wzk_s05" git
ausgabe_s05=$(PATH="$wzk_s05" make -s -C "$scheinbaum_s05" nachweise 2>&1)
gesamt=$((gesamt + 1))
if printf '%s' "$ausgabe_s05" | grep -qE '::LAGE [^ ]+ D12 nachweise C FEHLT=git::'; then
  bestanden=$((bestanden + 1)); echo "BESTANDEN  S-05 N-08 gegen echtes Makefile: fehlendes git -> FEHLT=git"
else
  fehlgeschlagene_faelle+=("S-05 N-08 gegen echtes Makefile")
  echo "FEHLGESCHLAGEN  S-05 (Ausgabe: $(printf '%s' "$ausgabe_s05" | tr '\n' ' ' | head -c 400))"
fi

echo
echo "--- S-06 (Entscheid h): drei Verstoesse -- die Kette darf NICHT laufen"
echo

# --- Fall S-06: Verstoss gegen 2 (Zeile 1), gegen 4 (Zeile 2), gegen 6
#     (Zeile 3) -- Zeile 1 gewinnt (LISTE 2), UND die Attrappe darf ihre
#     Markerdatei NICHT anlegen (Beweis, dass "make dod" gar nicht lief). ---
baum=$(neuer_mock_baum)
mkdir -p "$baum/scripts"
: > "$baum/scripts/abnahme-abgleich.sh"
git -C "$baum" add -A
git -C "$baum" commit -q -m "artefakt entstanden (S-06)"
printf 'D7 abnahme|scripts/abnahme-abgleich.sh\tADR 0002, 6.12.5, Selbsttest.\nD9 rueckkanal|scripts/rueckkanal-pruefen.sh\tGrund ohne die Wendung.\nD11 geheimnisse|gitleaks\tADR 0002, 6.12.5, Selbsttest.\n' > "$baum/.claude/hooks/dod-gate-terminierte-lagen.txt"
marker_s06=$(neu_verzeichnis)/marker
zustand_s06=$(neu_verzeichnis)
eingabe_s06=$(baue_eingabe "Stop" "$baum" "fall-s06")
rufe_gate "$eingabe_s06" "$zustand_s06" "$WERKZEUGKASTEN_VOLL" "CLAUDE_PROJECT_DIR=$baum" "MOCK_AUSGABE=darf nie gelesen werden" "MOCK_RC=0" "MOCK_MARKER=$marker_s06"
pruefe "S-06 drei Verstoesse (2,4,6), Verstoss 2 zuerst -> LISTE 2 D7 abnahme" 2 "" "Schluessel: LISTE 2 D7 abnahme"
gesamt=$((gesamt + 1))
if [ ! -e "$marker_s06" ]; then
  bestanden=$((bestanden + 1)); echo "BESTANDEN  S-06 Kette lief NICHT (keine Markerdatei)"
else
  fehlgeschlagene_faelle+=("S-06 Kette lief NICHT (keine Markerdatei)")
  echo "FEHLGESCHLAGEN  S-06: Markerdatei besteht trotzdem -- die Kette ist gelaufen"
fi

echo
echo "--- S-12: git status -z, Umbenennung der Uebergabedatei --------------"
echo

# --- Fall S-12: Uebergabedatei per "git mv" umbenannt (uncommittet) -------
baum_s12=$(neuer_mock_baum)
zustand_s12=$(neu_verzeichnis)
m1=$(marken_zeile K1 D20 belege A_OK "" "" 0)
m2=$(marken_zeile K1 D3 linter A_FAIL "" "" 2)
ausgabe_s12=$(bauen_ausgabe "$baum_s12" "$m1
$m2" "$D19_OK" "make dod: abgebrochen bei D3 linter, Rueckgabewert 2.")
lauf_mit_zustand "$zustand_s12" "$baum_s12" Stop "fall-s12" "$ausgabe_s12" 2
lauf_mit_zustand "$zustand_s12" "$baum_s12" Stop "fall-s12" "$ausgabe_s12" 2
lauf_mit_zustand "$zustand_s12" "$baum_s12" Stop "fall-s12" "$ausgabe_s12" 2
mkdir -p "$baum_s12/docs/uebergaben"
printf 'Uebergabe\n\nEskalation 3.4: D3 linter A_FAIL\n' > "$baum_s12/docs/uebergaben/2026-09-02_s12-alt.md"
git -C "$baum_s12" add -A
git -C "$baum_s12" commit -q -m "Uebergabe unter dem alten Namen"
git -C "$baum_s12" mv "docs/uebergaben/2026-09-02_s12-alt.md" "docs/uebergaben/2026-09-02_s12-neu.md"
lauf_mit_zustand "$zustand_s12" "$baum_s12" Stop "fall-s12" "$ausgabe_s12" 2
pruefe "S-12 umbenannte Uebergabedatei (git mv, uncommittet) -> Durchlass" 0 '"systemMessage".*Eskalation 3\.4'

echo
echo "--- Ebene 2: roter und gruener Lauf gegen das ECHTE Makefile ---"
echo

# -----------------------------------------------------------------------------
# Fall 27 (roter Lauf): backend/pyproject.toml OHNE gueltigen Inhalt -> "uv
# sync" schlaegt fehl -> D1 bau A_FAIL -> Kette bricht dort ab. Kein Netzzugriff
# noetig: uv bricht am kaputten TOML ab, bevor es etwas herunterlaedt.
# -----------------------------------------------------------------------------
scheinbaum_rot=$(neu_verzeichnis)
git -C "$scheinbaum_rot" init -q
git -C "$scheinbaum_rot" config user.email "selbsttest@example.invalid"
git -C "$scheinbaum_rot" config user.name "Selbsttest"
cp "$ECHTES_MAKEFILE" "$scheinbaum_rot/Makefile"
printf '# CLAUDE.md (Scheinbaum)\n' > "$scheinbaum_rot/CLAUDE.md"
mkdir -p "$scheinbaum_rot/backend"
printf 'dies ist kein gueltiges TOML {{{\n' > "$scheinbaum_rot/backend/pyproject.toml"
git -C "$scheinbaum_rot" add -A
git -C "$scheinbaum_rot" commit -q -m init
if command -v uv >/dev/null 2>&1; then
  zustand27=$(neu_verzeichnis)
  eingabe27=$(baue_eingabe "Stop" "$scheinbaum_rot" "fall27")
  rufe_gate "$eingabe27" "$zustand27" "$WERKZEUGKASTEN_VOLL" "CLAUDE_PROJECT_DIR=$scheinbaum_rot"
  pruefe "27 roter Lauf gegen echtes Makefile (kaputtes pyproject.toml) -> 2" 2
else
  echo "UEBERSPRUNGEN  27 roter Lauf gegen echtes Makefile: 'uv' fehlt in dieser Umgebung."
fi

# -----------------------------------------------------------------------------
# Fall 28 (gruener Lauf): Scheinbaum mit CLAUDE.md, den beiden Bezugsdokumenten
# in pruefbarer Form, dem echten Makefile, dem echten Belegpruefer samt
# Ausnahmeliste, Attrappen fuer die vier noch nicht gebauten Skripte und dem
# ECHTEN gitleaks im Suchpfad (heute unter /usr/local/bin installiert -- die
# ADR-Formulierung "gitleaks-Attrappe", 6.12.19, galt, solange gitleaks nicht
# zur Verfuegung stand; jetzt darf das echte Werkzeug benutzt werden).
#
# Befund vom 2026-09-02 (Uebergabe dieser Arbeitseinheit): Der fruehere Fall 28
# meldete "bestanden", sobald das Gate den Lauf NACHWEISBAR ausgewertet hatte
# (rc 0 oder 2) -- unabhaengig davon, ob der Lauf tatsaechlich gruen wurde. Die
# Kette meldete D20 Lage C mit FEHLT=belege-pruefmittel (Belegpruefer rc=3):
# der Projektauftrag der Minimalform trug nur eine "## N."-Ueberschrift, keine
# "### N.M"-Unterabschnittsueberschrift -- der Belegpruefer bildet seine
# Referenzmenge der Projektauftrag-Abschnitte AUSSCHLIESSLICH aus
# Ueberschriften der Form N.M (belege-pruefen.sh, Pruefung 5; PA_ABSCHNITTE).
# Behoben durch eine zusaetzliche Unterabschnittsueberschrift unten.
#
# Fall 28 prueft jetzt ECHTES Gruen, nicht nur eine auswertbare Form (ADR 0002,
# 6.12.19: "Ob ein solcher Baum mit dem ECHTEN Belegpruefer gruen wird, ist mit
# einem ausgefuehrten Lauf festzustellen"; hier ausgefuehrt und belegt). ZWEI
# Pruefungen gegen DIESELBE Kette:
#   1. "make -C <baum> dod" DIREKT, nicht ueber das Gate -- liefert
#      Schlusszeile und Lage-Marken auch dann, wenn das Gate sie bei sauberem
#      Gruen unterdrueckt (Fall 2).
#   2. Danach DASSELBE ueber das Gate -- muss mit Rueckgabewert 0 UND OHNE
#      jede Ausgabe durchlassen (sauberes Gruen, Fall 2).
# Bestanden nur, wenn BEIDE gruen sind UND die Schlusszeile aus (1) der Form 1
# entspricht ("alle 14 Kettenschritte durchlaufen, keiner ungleich 0, 14
# gueltige Marken gezaehlt."). Bleibt der Lauf rot, wird das GEMELDET
# (Schlusszeile und Lage-Marken der Kette), der Fall NICHT gelockert.
# -----------------------------------------------------------------------------
scheinbaum_gruen=$(neu_verzeichnis)
git -C "$scheinbaum_gruen" init -q
git -C "$scheinbaum_gruen" config user.email "selbsttest@example.invalid"
git -C "$scheinbaum_gruen" config user.name "Selbsttest"
cp "$ECHTES_MAKEFILE" "$scheinbaum_gruen/Makefile"
mkdir -p "$scheinbaum_gruen/scripts" "$scheinbaum_gruen/docs" "$scheinbaum_gruen/.claude/hooks"
cp "$ECHTER_BELEGPRUEFER" "$scheinbaum_gruen/scripts/belege-pruefen.sh"
: > "$scheinbaum_gruen/scripts/belege-ausnahmen.txt"
: > "$scheinbaum_gruen/.claude/hooks/dod-gate-terminierte-lagen.txt"
cat > "$scheinbaum_gruen/CLAUDE.md" <<'EOF'
# CLAUDE.md (Scheinbaum fuer den Selbsttest von dod-gate.sh)

Verweist auf docs/00_Projektauftrag.md, Abschnitt 1.1.
EOF
cat > "$scheinbaum_gruen/docs/00_Projektauftrag.md" <<'EOF'
# Projektauftrag (Minimalform fuer den Selbsttest)

## 1. Zweck

Minimaler Auftragstext, damit der Belegpruefer eine gueltige Menge von
Abschnittsnummern bilden kann. Verweist auf R3-X-000 (docs/05_Product_Backlog.md).

### 1.1 Geltungsbereich

Der Belegpruefer bildet seine Referenzmenge NUR aus Ueberschriften der Form
"N.M" (belege-pruefen.sh, Pruefung 5); eine blosse "N."-Ueberschrift wie oben
reicht dafuer NICHT -- ohne diesen Unterabschnitt bleibt die Referenzmenge
leer und der Belegpruefer faellt mit Rueckgabewert 3 in Lage C
(Projektauftrag 1.1).
EOF
cat > "$scheinbaum_gruen/docs/05_Product_Backlog.md" <<'EOF'
# Product Backlog (Minimalform fuer den Selbsttest)

## R3-X-000: Beispieleintrag

**Abnahme:** `make abnahme` bestanden (Abschnitt 1).
EOF
for skript in abnahme-abgleich prototyp-trennung-pruefen nachweise-vollstaendig rueckkanal-pruefen; do
  cat > "$scheinbaum_gruen/scripts/$skript.sh" <<'EOF'
#!/usr/bin/env bash
exit 0
EOF
  chmod +x "$scheinbaum_gruen/scripts/$skript.sh"
done
cat > "$scheinbaum_gruen/scripts/nachweise-erzeugen.sh" <<'EOF'
#!/usr/bin/env bash
ziel="${1:-/dev/stdout}"
printf '# Nachweise (Attrappe fuer den Selbsttest)\n' > "$ziel"
exit 0
EOF
chmod +x "$scheinbaum_gruen/scripts/nachweise-erzeugen.sh"
git -C "$scheinbaum_gruen" add -A
git -C "$scheinbaum_gruen" commit -q -m init
wzk_gruen=$(neu_verzeichnis)
baue_werkzeugkasten "$wzk_gruen"
GITLEAKS_ECHT="$(command -v gitleaks 2>/dev/null || true)"
[ -n "$GITLEAKS_ECHT" ] && ln -sf "$GITLEAKS_ECHT" "$wzk_gruen/gitleaks"

# --- Pruefung 1: die Kette DIREKT, ohne das Gate -----------------------------
kette_stdout28=$(mktemp)
( env -i PATH="$wzk_gruen" HOME="${HOME:-/root}" \
    make -C "$scheinbaum_gruen" --no-print-directory dod ) >"$kette_stdout28" 2>&1
kette_rc28=$?
kette_ausgabe28=$(cat "$kette_stdout28")
rm -f "$kette_stdout28"
kette_schlusszeile28=$(printf '%s\n' "$kette_ausgabe28" | grep -E '^make dod: (alle|abgebrochen)' | tail -1)
kette_marken28=$(printf '%s\n' "$kette_ausgabe28" | grep -E '^::LAGE ')
kette_form1_erwartet='make dod: alle 14 Kettenschritte durchlaufen, keiner ungleich 0, 14 gueltige Marken gezaehlt.'

# --- Pruefung 2: DIESELBE Kette ueber das Gate -- muss sauberes Gruen sein --
zustand28=$(neu_verzeichnis)
eingabe28=$(baue_eingabe "Stop" "$scheinbaum_gruen" "fall28")
rufe_gate "$eingabe28" "$zustand28" "$wzk_gruen" "CLAUDE_PROJECT_DIR=$scheinbaum_gruen"

echo "MELDUNG  28 gruener Lauf gegen echtes Makefile + echten Belegpruefer:"
echo "  Kette direkt: rc=$kette_rc28, Schlusszeile: $kette_schlusszeile28"
echo "  Gate: rc=$G_RC, stdout='$G_STDOUT', stderr (erste 800 Zeichen): $(printf '%s' "$G_STDERR" | head -c 800)"

gesamt=$((gesamt + 1))
if [ "$kette_rc28" = "0" ] \
   && [ "$kette_schlusszeile28" = "$kette_form1_erwartet" ] \
   && [ "$G_RC" = "0" ] && [ -z "$G_STDOUT" ] && [ -z "$G_STDERR" ]; then
  bestanden=$((bestanden + 1))
  echo "BESTANDEN  28 gruener Lauf gegen echtes Makefile + echten Belegpruefer, sauberes Gruen belegt (ADR 0002, 6.12.19)"
else
  fehlgeschlagene_faelle+=("28 gruener Lauf nicht gruen")
  echo "FEHLGESCHLAGEN  28 gruener Lauf nicht gruen"
  echo "  Schlusszeile der Kette: $kette_schlusszeile28"
  echo "  Lage-Marken der Kette:"
  printf '%s\n' "$kette_marken28"
fi

# -----------------------------------------------------------------------------
# Fall 29 (G16, flacher Klon): direkt gegen das Makefile-Ziel "belege" eines
# flachen Klons des ECHTEN Repositories -- nicht ueber das ganze Gate, um
# keinen vollen "make dod"-Lauf (D7/D10/D12 etc.) fuer diesen einen,
# eng gefassten Fall zu brauchen.
# -----------------------------------------------------------------------------
flacher_klon=$(neu_verzeichnis)
if git clone -q --depth 1 "file://$REPO_WURZEL" "$flacher_klon/klon" 2>/tmp/klon-fehler.txt; then
  klon="$flacher_klon/klon"
  # Der Klon holt den zuletzt COMMITTETEN Stand; das ECHTE Makefile im
  # Arbeitsbaum kann Aenderungen dieser Arbeitseinheit tragen, die noch nicht
  # committet sind (3.1, "Kein Commit" fuer diese Einheit). Das aktuelle
  # Makefile wird deshalb ins geklonte (weiterhin FLACHE) Repository kopiert,
  # bevor "belege" darin laeuft -- die Historie des Klons selbst bleibt
  # unangetastet.
  cp "$ECHTES_MAKEFILE" "$klon/Makefile"
  ausgabe29=$(make -C "$klon" belege 2>&1)
  rc29=$?
  gesamt=$((gesamt + 1))
  if printf '%s' "$ausgabe29" | grep -q "git fetch --unshallow"; then
    bestanden=$((bestanden + 1))
    echo "BESTANDEN  29 flacher Klon -> LAGE C mit 'git fetch --unshallow' in der Meldung (rc=$rc29)"
  else
    fehlgeschlagene_faelle+=("29 flacher Klon")
    echo "FEHLGESCHLAGEN  29 flacher Klon: 'git fetch --unshallow' nicht in der Meldung (rc=$rc29)"
    printf '%s\n' "$ausgabe29" | head -c 800
  fi
else
  echo "UEBERSPRUNGEN  29 flacher Klon: 'git clone --depth 1' auf dieses Repository ist hier nicht moeglich."
fi

echo
echo "=== Zusammenfassung ==="
if [ "${#fehlgeschlagene_faelle[@]}" -gt 0 ]; then
  echo "Fehlgeschlagene Faelle:"
  for f in "${fehlgeschlagene_faelle[@]}"; do
    echo "  - $f"
  done
fi
echo "Selbsttest: $bestanden von $gesamt Faellen bestanden"
if [ "$bestanden" -eq "$gesamt" ]; then
  exit 0
else
  exit 2
fi
