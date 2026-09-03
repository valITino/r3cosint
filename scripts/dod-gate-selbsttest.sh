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

# -----------------------------------------------------------------------------
# 6.12.25 j (Befund S4-03): der Selbsttest ist gegen Nebenlaeufigkeit gesperrt.
# Die Faelle Z-104..Z-108 verschieben das feste Ausweichverzeichnis
# /tmp/r3cosint-dod-gate beiseite und zurueck; zwei gleichzeitig laufende
# Selbsttests stoeren sich dabei (Scheinbefund, ausgefuehrt belegt: 144 von
# 145 im gestoerten Lauf). Dieser Prozess haelt deshalb fuer seine GESAMTE
# Laufzeit eine exklusive, NICHT wartende Sperre (flock -n) auf einer festen
# Datei UNTER /tmp -- nicht im Arbeitsbaum (6.1.3), unter einem ANDEREN Namen
# als das Ausweichverzeichnis des Gates, damit die Faelle Z-104..Z-108 sie
# nicht mitverschieben. Gelingt das nicht, hat der Lauf NICHT stattgefunden:
# Rueckgabewert 3 (weder 0 noch 2), Meldung auf stderr, sofortiges Ende VOR
# jeder weiteren Handlung -- es ist noch nichts angelegt, ein "trap
# aufraeumen" ist an dieser Stelle nicht noetig. Die Sperre loest sich beim
# Beenden dieses Skripts von selbst (Dateideskriptor schliesst).
# -----------------------------------------------------------------------------
SELBSTTEST_SPERRDATEI="/tmp/r3cosint-dod-gate-selbsttest.lock"
if ! exec {SELBSTTEST_SPERRE_FD}>"$SELBSTTEST_SPERRDATEI" || ! flock -n "$SELBSTTEST_SPERRE_FD"; then
  echo "Selbsttest laeuft bereits" >&2
  exit 3
fi

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
GEMELDETE_KENNUNGEN=()

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
# ZUSICHERUNGEN NACH KENNUNG (ADR 0002, 6.12.25 a)
#
# Je Kennung Z-nnn genau EINE Pruefung, je Pruefung genau EINE Kennung. Die
# Kennungen und ihr Wortlaut stehen ausschliesslich in der Tabelle 6.12.19
# dieses ADR -- dieses Skript wiederholt sie nicht, es LIEST sie am Ende
# (Abschnitt "Deckung") und vergleicht sie mechanisch mit dem, was unten
# tatsaechlich geprueft wurde.
#
# _melde ist der einzige Ort, der eine Zeile "BESTANDEN Z-nnn ..." oder
# "FEHLGESCHLAGEN Z-nnn ..." schreibt und eine Kennung als "gemeldet"
# registriert. Alle pruefe_*-Funktionen darunter sind duenne Wrapper, die je
# EINE der folgenden Messarten auf $G_RC/$G_STDOUT/$G_STDERR anwenden
# (Auftrag, Punkt 4): den tatsaechlichen Rueckgabewert, grep -F auf stderr
# oder stdout, eine Dateipruefung, eine JSON-Strukturpruefung mit jq, oder das
# Lesen einer Zaehlerdatei. Fuer "keine Datei im Baum waehrend des Laufs"
# gibt es keinen Wrapper -- das braucht einen Beobachter ohne Wartezeit
# WAEHREND des Gate-Aufrufs und steht deshalb bei den betroffenen Faellen
# selbst (DT3-B1, DT2-B2).
# -----------------------------------------------------------------------------
_kuerzen() { printf '%s' "$1" | head -c 300; }

_melde() {
  # $1=Kennung $2=Fall $3=Zusicherung $4=ok(0/1) $5=erwartet $6=erhalten
  local kennung="$1" fall="$2" zusicherung="$3" ok="$4" erwartet="$5" erhalten="$6"
  gesamt=$((gesamt + 1))
  GEMELDETE_KENNUNGEN+=("$kennung")
  if [ "$ok" -eq 1 ]; then
    bestanden=$((bestanden + 1))
    printf 'BESTANDEN %s %s: %s\n' "$kennung" "$fall" "$zusicherung"
  else
    fehlgeschlagene_faelle+=("$kennung $fall: $zusicherung")
    printf 'FEHLGESCHLAGEN %s %s: %s: erwartet %s, erhalten %s\n' \
      "$kennung" "$fall" "$zusicherung" "$erwartet" "$erhalten"
  fi
}

# pruefe_rc <kennung> <fall> <erwarteter_rc> -- misst den TATSAECHLICHEN
# Rueckgabewert des zuletzt ausgefuehrten rufe_gate/lauf-Aufrufs.
pruefe_rc() {
  local kennung="$1" fall="$2" erwartet_rc="$3"
  local ok=0
  [ "$G_RC" = "$erwartet_rc" ] && ok=1
  _melde "$kennung" "$fall" "Rueckgabewert $erwartet_rc" "$ok" "rc=$erwartet_rc" "rc=$G_RC"
}

# pruefe_rc_wert <kennung> <fall> <zusicherung> <erwartet> <erhalten_wert> --
# wie pruefe_rc, aber fuer einen ausserhalb von G_RC gelesenen Rueckgabewert
# (z. B. eines direkten "make"-Aufrufs statt des Gates).
pruefe_rc_wert() {
  local kennung="$1" fall="$2" zusicherung="$3" erwartet="$4" erhalten="$5"
  local ok=0
  [ "$erhalten" = "$erwartet" ] && ok=1
  _melde "$kennung" "$fall" "$zusicherung" "$ok" "rc=$erwartet" "rc=$erhalten"
}

pruefe_stdout_leer() {
  local kennung="$1" fall="$2"
  local ok=0
  [ -z "$G_STDOUT" ] && ok=1
  _melde "$kennung" "$fall" "Standardausgabe leer" "$ok" "leer" "'$(_kuerzen "$G_STDOUT")'"
}

pruefe_stderr_leer() {
  local kennung="$1" fall="$2"
  local ok=0
  [ -z "$G_STDERR" ] && ok=1
  _melde "$kennung" "$fall" "Fehlerausgabe leer" "$ok" "leer" "'$(_kuerzen "$G_STDERR")'"
}

# pruefe_stdout_enthaelt/pruefe_stderr_enthaelt <kennung> <fall> <zusicherung>
# <text> -- grep -F (fester String, kein Muster) auf G_STDOUT/G_STDERR.
pruefe_stdout_enthaelt() {
  local kennung="$1" fall="$2" zusicherung="$3" text="$4"
  local ok=0
  printf '%s' "$G_STDOUT" | grep -qF -- "$text" && ok=1
  _melde "$kennung" "$fall" "$zusicherung" "$ok" "stdout enthaelt '$text'" "stdout='$(_kuerzen "$G_STDOUT")'"
}

pruefe_stderr_enthaelt() {
  local kennung="$1" fall="$2" zusicherung="$3" text="$4"
  local ok=0
  printf '%s' "$G_STDERR" | grep -qF -- "$text" && ok=1
  _melde "$kennung" "$fall" "$zusicherung" "$ok" "stderr enthaelt '$text'" "stderr='$(_kuerzen "$G_STDERR")'"
}

pruefe_stderr_fehlt() {
  local kennung="$1" fall="$2" zusicherung="$3" text="$4"
  local ok=0
  printf '%s' "$G_STDERR" | grep -qF -- "$text" || ok=1
  _melde "$kennung" "$fall" "$zusicherung" "$ok" "stderr OHNE '$text'" "stderr='$(_kuerzen "$G_STDERR")'"
}

# pruefe_datei <kennung> <fall> <zusicherung> <pfad> <soll: existiert|fehlt>
pruefe_datei() {
  local kennung="$1" fall="$2" zusicherung="$3" pfad="$4" soll="$5"
  local ok=0 ist
  if [ -f "$pfad" ]; then ist="existiert"; else ist="fehlt"; fi
  [ "$ist" = "$soll" ] && ok=1
  _melde "$kennung" "$fall" "$zusicherung" "$ok" "$pfad $soll" "$pfad $ist"
}

# pruefe_json_einzelfeld <kennung> <fall> <feld> -- G_STDOUT ist GENAU EIN
# JSON-Objekt mit GENAU diesem einen Feld (jq, nicht grep -- eine
# Strukturaussage ist keine Textaussage).
pruefe_json_einzelfeld() {
  local kennung="$1" fall="$2" feld="$3"
  local ok=0
  if printf '%s' "$G_STDOUT" | jq -e --arg f "$feld" \
       'type == "object" and (keys == [$f])' >/dev/null 2>&1; then
    ok=1
  fi
  _melde "$kennung" "$fall" "Standardausgabe ist genau ein JSON-Objekt mit einzigem Feld $feld" \
    "$ok" "{\"$feld\": ...}" "stdout='$(_kuerzen "$G_STDOUT")'"
}

# pruefe_zaehler <kennung> <fall> <zaehlerdatei> <erwarteter_stand> -- liest
# die ZWEITE Zeile der Zaehlerdatei (der Zaehlerstand, siehe dod-gate.sh).
pruefe_zaehler() {
  local kennung="$1" fall="$2" datei="$3" erwartet="$4"
  local ok=0 erhalten
  erhalten=$(sed -n '2p' "$datei" 2>/dev/null || true)
  [ "$erhalten" = "$erwartet" ] && ok=1
  _melde "$kennung" "$fall" "Zaehlerstand $erwartet" "$ok" "$erwartet" "'$erhalten' (Datei: $datei)"
}

# pruefe_zaehler_schluessel <kennung> <fall> <zaehlerdatei> <erwarteter_schluessel>
# -- liest die ERSTE Zeile der Zaehlerdatei (der gezaehlte Schluessel; siehe
# dod-gate.sh, blockieren_mit_zaehlung: "printf '%s\n%s\n' "$primaer_schluessel"
# "$neue_zahl" > "$zaehler_datei""). 6.12.25 f (Kanal "Zaehlerdatei"): mehrere
# Zeilen der Tabelle 6.12.19 nannten diesen Kanal ausdruecklich, wurden aber
# ueber die Fehlerausgabe geprueft -- dieselbe Meldung traegt den Schluessel
# zwar auch, das belegt aber nicht, dass er PERSISTIERT wurde. Diese Funktion
# misst den genannten Kanal.
pruefe_zaehler_schluessel() {
  local kennung="$1" fall="$2" datei="$3" erwartet="$4"
  local ok=0 erhalten
  erhalten=$(sed -n '1p' "$datei" 2>/dev/null || true)
  [ "$erhalten" = "$erwartet" ] && ok=1
  _melde "$kennung" "$fall" "Zaehlerdatei traegt Schluessel $erwartet" "$ok" "$erwartet" "'$erhalten' (Datei: $datei)"
}

# zaehler_pfad <zustand> <fallkey> -- baut den Pfad der Zaehlerdatei aus dem
# Zustandsverzeichnis und dem Session-Schluessel (fallkey), genau wie
# dod-gate.sh ihn selbst bildet (sha256sum des session_id-Feldes).
zaehler_pfad() {
  printf '%s/r3cosint/dod-gate/zaehler-%s' "$1" "$(printf '%s' "$2" | sha256sum | cut -d' ' -f1)"
}

# pruefe_wahr <kennung> <fall> <zusicherung> <ok:0|1> <erwartet> <erhalten> --
# fuer Faelle, die ihre eigene Bedingung (Datei-Existenz, Beobachterergebnis
# u. Ae.) bereits vorher gebildet haben.
pruefe_wahr() {
  local kennung="$1" fall="$2" zusicherung="$3" ok="$4" erwartet="$5" erhalten="$6"
  _melde "$kennung" "$fall" "$zusicherung" "$ok" "$erwartet" "$erhalten"
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
# Werkzeugkasten mit einer ATTRAPPE fuer "mktemp", NUR fuer S3-05 (6.12.25 d):
# JEDER Aufruf (unabhaengig von "-p ...") gibt einen Pfad in einem
# Verzeichnis aus, das es GAR NICHT gibt -- "cd" darauf schlaegt fehl, "pwd
# -P" liefert leer, genau die Lage "physisch nicht aufloesbar". Eine echte
# fehlende Ausfuehrungsberechtigung liesse sich hier nicht herstellen: dieses
# Skript laeuft (wie Fall N-04 vermerkt) im Selbsttest als root, und root
# umgeht Dateimodus-Rechte einschliesslich des Ausfuehrungsbits fuer die
# Verzeichnisdurchquerung. Ein NICHT EXISTIERENDES Verzeichnis ist die
# andere, hier tatsaechlich herstellbare Lage aus 6.12.25 d ("oder ueber eine
# andere herstellbare Lage") und liefert dieselbe Beobachtung (leeres "cd &&
# pwd -P").
# -----------------------------------------------------------------------------
WERKZEUGKASTEN_FAKE_MKTEMP_UNAUFLOESBAR=$(neu_verzeichnis)
baue_werkzeugkasten "$WERKZEUGKASTEN_FAKE_MKTEMP_UNAUFLOESBAR"
rm -f "$WERKZEUGKASTEN_FAKE_MKTEMP_UNAUFLOESBAR/mktemp"
cat > "$WERKZEUGKASTEN_FAKE_MKTEMP_UNAUFLOESBAR/mktemp" <<'MKTEMPUNAUFEOF'
#!/bin/sh
echo "/dod-gate-selbsttest-s3-05-nicht-vorhanden-$$/tmp.attrappe"
exit 0
MKTEMPUNAUFEOF
chmod +x "$WERKZEUGKASTEN_FAKE_MKTEMP_UNAUFLOESBAR/mktemp"

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
pruefe_rc Z-001 "Kette mit A_FAIL" 2

# --- Fall 2: sauberes Gruen, keine Ausgabe ----------------------------------
baum=$(neuer_mock_baum)
m1=$(marken_zeile K1 D20 belege A_OK "" "" 0)
m2=$(marken_zeile K1 D1 bau B "" "" 0)
ausgabe=$(bauen_ausgabe "$baum" "$m1
$m2" "$D19_OK" "make dod: alle 2 Kettenschritte durchlaufen, keiner ungleich 0, 2 gueltige Marken gezaehlt.")
lauf "$baum" Stop "fall02" "$ausgabe" 0
pruefe_rc Z-002 "Kette gruen, ohne Lage C" 0
pruefe_stdout_leer Z-003 "Kette gruen, ohne Lage C"
pruefe_stderr_leer Z-004 "Kette gruen, ohne Lage C"

# --- Fall 3: terminierte Lage C, Eintrag gueltig -> 0 mit systemMessage ----
baum=$(neuer_mock_baum)
printf 'D7 abnahme|scripts/abnahme-abgleich.sh\tADR 0002, 6.12.5, Selbsttest.\n' > "$baum/.claude/hooks/dod-gate-terminierte-lagen.txt"
m1=$(marken_zeile K1 D20 belege A_OK "" "" 0)
m2=$(marken_zeile K1 D7 abnahme C scripts/abnahme-abgleich.sh "" 2)
ausgabe=$(bauen_ausgabe "$baum" "$m1
$m2" "$D19_OK" "make dod: alle 2 Kettenschritte durchlaufen, 1 davon ohne Urteil (Lage C): D7 abnahme FEHLT=scripts/abnahme-abgleich.sh, Rueckgabewert 2.")
lauf "$baum" Stop "fall03" "$ausgabe" 2
pruefe_rc Z-005 "Terminierte Lage C, Eintrag gueltig" 0
pruefe_json_einzelfeld Z-006 "Terminierte Lage C, Eintrag gueltig" systemMessage
pruefe_stdout_enthaelt Z-007 "Terminierte Lage C, Eintrag gueltig" \
  "die Kennung des Kettenschritts, der nicht geurteilt hat" "D7 abnahme"

# --- Fall 4: Lage C ohne Eintrag -> 2 ---------------------------------------
baum=$(neuer_mock_baum)
m1=$(marken_zeile K1 D20 belege A_OK "" "" 0)
m2=$(marken_zeile K1 D7 abnahme C scripts/abnahme-abgleich.sh "" 2)
ausgabe=$(bauen_ausgabe "$baum" "$m1
$m2" "$D19_OK" "make dod: alle 2 Kettenschritte durchlaufen, 1 davon ohne Urteil (Lage C): D7 abnahme FEHLT=scripts/abnahme-abgleich.sh, Rueckgabewert 2.")
lauf "$baum" Stop "fall04" "$ausgabe" 2
pruefe_rc Z-008 "Lage C ohne Eintrag" 2

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
pruefe_rc Z-009 "Eintrag vorhanden, Pruefmittel existiert inzwischen" 2
pruefe_stderr_enthaelt Z-010 "Eintrag vorhanden, Pruefmittel existiert inzwischen" \
  "Meldung fuehrt den beanstandeten Eintrag im Wortlaut auf" "scripts/abnahme-abgleich.sh"

# --- Fall 6: Eintrag vorhanden, Schritt meldet A_OK (veraltet) -------------
baum=$(neuer_mock_baum)
printf 'D7 abnahme|scripts/abnahme-abgleich.sh\tADR 0002, 6.12.5, Selbsttest.\n' > "$baum/.claude/hooks/dod-gate-terminierte-lagen.txt"
m1=$(marken_zeile K1 D20 belege A_OK "" "" 0)
m2=$(marken_zeile K1 D7 abnahme A_OK "" "" 0)
ausgabe=$(bauen_ausgabe "$baum" "$m1
$m2" "$D19_OK" "make dod: alle 2 Kettenschritte durchlaufen, keiner ungleich 0, 2 gueltige Marken gezaehlt.")
lauf "$baum" Stop "fall06" "$ausgabe" 0
pruefe_rc Z-011 "Eintrag vorhanden, Schritt meldet A_OK" 2
pruefe_stderr_enthaelt Z-012 "Eintrag vorhanden, Schritt meldet A_OK" \
  "Meldung fuehrt den beanstandeten Eintrag im Wortlaut auf" "D7 abnahme"

# --- Fall 7a: Eintrag ohne Grund --------------------------------------------
baum=$(neuer_mock_baum)
printf 'D7 abnahme|scripts/abnahme-abgleich.sh\t\n' > "$baum/.claude/hooks/dod-gate-terminierte-lagen.txt"
m1=$(marken_zeile K1 D7 abnahme C scripts/abnahme-abgleich.sh "" 2)
ausgabe=$(bauen_ausgabe "$baum" "$m1" "$D19_OK" "make dod: alle 1 Kettenschritte durchlaufen, 1 davon ohne Urteil (Lage C): D7 abnahme FEHLT=scripts/abnahme-abgleich.sh, Rueckgabewert 2.")
lauf "$baum" Stop "fall07a" "$ausgabe" 2
pruefe_rc Z-013 "Eintrag ohne Grund" 2

# --- Fall 7b: Eintrag mit nicht terminierbarem Pruefmittel (blosser Name) --
baum=$(neuer_mock_baum)
printf 'D11 geheimnisse|gitleaks\tADR 0002, 6.12.5, Selbsttest.\n' > "$baum/.claude/hooks/dod-gate-terminierte-lagen.txt"
m1=$(marken_zeile K1 D11 geheimnisse C gitleaks "" 2)
ausgabe=$(bauen_ausgabe "$baum" "$m1" "$D19_OK" "make dod: alle 1 Kettenschritte durchlaufen, 1 davon ohne Urteil (Lage C): D11 geheimnisse FEHLT=gitleaks, Rueckgabewert 2.")
lauf "$baum" Stop "fall07b" "$ausgabe" 2
pruefe_rc Z-014 "Eintrag mit nicht terminierbarem Pruefmittel" 2

# --- Fall 7c: Eintrag mit absolutem Pfad ------------------------------------
baum=$(neuer_mock_baum)
printf 'D7 abnahme|/scripts/abnahme-abgleich.sh\tADR 0002, 6.12.5, Selbsttest.\n' > "$baum/.claude/hooks/dod-gate-terminierte-lagen.txt"
m1=$(marken_zeile K1 D7 abnahme C /scripts/abnahme-abgleich.sh "" 2)
ausgabe=$(bauen_ausgabe "$baum" "$m1" "$D19_OK" "make dod: alle 1 Kettenschritte durchlaufen, 1 davon ohne Urteil (Lage C): D7 abnahme FEHLT=/scripts/abnahme-abgleich.sh, Rueckgabewert 2.")
lauf "$baum" Stop "fall07c" "$ausgabe" 2
pruefe_rc Z-015 "Eintrag mit absolutem Pfad" 2

# --- Fall 8: Marke nennt anderes Pruefmittel als der Schluessel ------------
baum=$(neuer_mock_baum)
printf 'D7 abnahme|scripts/abnahme-abgleich.sh\tADR 0002, 6.12.5, Selbsttest.\n' > "$baum/.claude/hooks/dod-gate-terminierte-lagen.txt"
m1=$(marken_zeile K1 D7 abnahme C ein-anderer-wert "" 2)
ausgabe=$(bauen_ausgabe "$baum" "$m1" "$D19_OK" "make dod: alle 1 Kettenschritte durchlaufen, 1 davon ohne Urteil (Lage C): D7 abnahme FEHLT=ein-anderer-wert, Rueckgabewert 2.")
lauf "$baum" Stop "fall08" "$ausgabe" 2
pruefe_rc Z-016 "Marke nennt anderes Pruefmittel als der Schluessel" 2

# --- Fall 9: stop_hook_active wahr bei roter Kette -> 0, Zaehler unveraendert
baum=$(neuer_mock_baum)
zustand9=$(neu_verzeichnis)
eingabe9=$(baue_eingabe "Stop" "$baum" "fall09" "true")
rufe_gate "$eingabe9" "$zustand9" "$WERKZEUGKASTEN_VOLL" "CLAUDE_PROJECT_DIR=$baum" "MOCK_AUSGABE=roter Muell" "MOCK_RC=2"
pruefe_rc Z-017 "stop_hook_active wahr bei roter Kette" 0
zaehlerdateien9=$(find "$zustand9" -name 'zaehler-*' 2>/dev/null | wc -l | tr -d ' ')
pruefe_wahr Z-018 "stop_hook_active wahr bei roter Kette" \
  "Zaehlerstand nach dem Aufruf derselbe wie davor" \
  "$([ "$zaehlerdateien9" = "0" ] && echo 1 || echo 0)" \
  "keine Zaehlerdatei (davor: keine)" "Zaehlerdateien=$zaehlerdateien9"

# --- Fall 10a (6.12.23 a, vierte Form): alle Schritte gruen, D19 VERLETZT,
# rc 2 -> Gate blockiert mit Schluessel "D19 VERLETZT".
baum=$(neuer_mock_baum)
m1=$(marken_zeile K1 D20 belege A_OK "" "" 0)
ausgabe_10a=$(bauen_ausgabe "$baum" "$m1" "VERLETZT -- versionierter Bestand veraendert." "make dod: alle 1 Kettenschritte durchlaufen, Rahmenpruefung D19 VERLETZT, Rueckgabewert 2.")
lauf "$baum" Stop "fall10a" "$ausgabe_10a" 2
pruefe_rc Z-019 "D19 VERLETZT, Form 4" 2

# --- Fall 10b: D19 Lage C, Form 4 -------------------------------------------
baum=$(neuer_mock_baum)
m1=$(marken_zeile K1 D20 belege A_OK "" "" 0)
ausgabe=$(bauen_ausgabe "$baum" "$m1" "C -- git fehlt, nicht beobachtet." "make dod: alle 1 Kettenschritte durchlaufen, Rahmenpruefung D19 C, Rueckgabewert 2.")
lauf "$baum" Stop "fall10b" "$ausgabe" 2
pruefe_rc Z-020 "D19 Lage C, Form 4" 2

echo
echo "--- Fehlende Pruefmittel (G10, 6.12.11) --------------------------------"
echo

# --- Z-021/022, Z-023/024, Z-025/026, Z-029/030, Z-031/032: jq, git, make,
#     timeout, flock einzeln aus dem Werkzeugkasten entfernt ---------------
baum=$(neuer_mock_baum)
for eintrag in \
  "jq|Z-021|Z-022" \
  "git|Z-023|Z-024" \
  "make|Z-025|Z-026" \
  "timeout|Z-029|Z-030" \
  "flock|Z-031|Z-032"; do
  werkzeug="${eintrag%%|*}"
  rest="${eintrag#*|}"
  z_rc="${rest%%|*}"
  z_msg="${rest#*|}"
  wzk=$(neu_verzeichnis)
  baue_werkzeugkasten "$wzk" "$werkzeug"
  zustand=$(neu_verzeichnis)
  eingabe=$(baue_eingabe "Stop" "$baum" "fall11-$werkzeug")
  rufe_gate "$eingabe" "$zustand" "$wzk" "CLAUDE_PROJECT_DIR=$baum" "MOCK_AUSGABE=x" "MOCK_RC=0"
  pruefe_rc "$z_rc" "Fehlendes $werkzeug" 2
  pruefe_stderr_enthaelt "$z_msg" "Fehlendes $werkzeug" "Meldung nennt $werkzeug" "GATE $werkzeug"
done

# --- Z-027/028: fehlendes Makefile -----------------------------------------
baum_ohne_makefile=$(neu_verzeichnis)
git -C "$baum_ohne_makefile" init -q
git -C "$baum_ohne_makefile" config user.email "selbsttest@example.invalid"
git -C "$baum_ohne_makefile" config user.name "Selbsttest"
mkdir -p "$baum_ohne_makefile/.claude/hooks"
: > "$baum_ohne_makefile/.claude/hooks/dod-gate-terminierte-lagen.txt"
git -C "$baum_ohne_makefile" add -A
git -C "$baum_ohne_makefile" commit -q -m init --allow-empty
lauf "$baum_ohne_makefile" Stop "fall11-makefile" "x" 0
pruefe_rc Z-027 "Fehlendes Makefile" 2
pruefe_stderr_enthaelt Z-028 "Fehlendes Makefile" "Meldung nennt Makefile" "GATE Makefile"

# --- Z-033/034: fehlende Liste der terminierten Lagen ----------------------
baum_ohne_liste=$(neuer_mock_baum)
rm -f "$baum_ohne_liste/.claude/hooks/dod-gate-terminierte-lagen.txt"
lauf "$baum_ohne_liste" Stop "fall11-liste" "x" 0
pruefe_rc Z-033 "Fehlende Liste der terminierten Lagen" 2
pruefe_stderr_enthaelt Z-034 "Fehlende Liste der terminierten Lagen" "Meldung nennt den Pfad der Liste" ".claude/hooks/dod-gate-terminierte-lagen.txt"

# --- Z-116..Z-121 (Entscheid g): sha256sum und mktemp fehlend, je drei -----
for eintrag in \
  "sha256sum|Z-116|Z-117|Z-118" \
  "mktemp|Z-119|Z-120|Z-121"; do
  werkzeug="${eintrag%%|*}"
  rest="${eintrag#*|}"
  z_rc="${rest%%|*}"
  rest="${rest#*|}"
  z_msg="${rest%%|*}"
  z_weg="${rest#*|}"
  wzk=$(neu_verzeichnis)
  baue_werkzeugkasten "$wzk" "$werkzeug"
  zustand=$(neu_verzeichnis)
  eingabe=$(baue_eingabe "Stop" "$baum" "fall11-$werkzeug")
  rufe_gate "$eingabe" "$zustand" "$wzk" "CLAUDE_PROJECT_DIR=$baum" "MOCK_AUSGABE=x" "MOCK_RC=0"
  pruefe_rc "$z_rc" "Fehlendes $werkzeug" 2
  pruefe_stderr_enthaelt "$z_msg" "Fehlendes $werkzeug" "Meldung nennt $werkzeug" "GATE $werkzeug"
  pruefe_stderr_enthaelt "$z_weg" "Fehlendes $werkzeug" "Meldung nennt den Beschaffungsweg" "naechster Schritt: coreutils installieren"
done

echo
echo "--- Zustandsverzeichnis nicht beschreibbar (6.12.9, Entscheid e) ------"
echo

# --- Z-035/036, Z-104/105: nicht beschreibbares Zustandsverzeichnis, /tmp
#     bleibt als Ausweich erreichbar -----------------------------------------
baum=$(neuer_mock_baum)
m1=$(marken_zeile K1 D20 belege A_OK "" "" 0)
m2=$(marken_zeile K1 D3 linter A_FAIL "" "" 2)
ausgabe=$(bauen_ausgabe "$baum" "$m1
$m2" "$D19_OK" "make dod: abgebrochen bei D3 linter, Rueckgabewert 2.")
zustand12_basis=$(neu_verzeichnis)
# chmod-basierte Schreibsperren wirken nicht, wenn dieser Selbsttest als root
# laeuft (root umgeht Dateimodus-Rechte). "hindernis" ist eine gewoehnliche
# DATEI, "mkdir -p .../hindernis/darunter" schlaegt damit STRUKTURELL fehl,
# unabhaengig vom Benutzer.
: > "$zustand12_basis/hindernis"
zustand12="$zustand12_basis/hindernis/darunter"
eingabe12=$(baue_eingabe "Stop" "$baum" "fall12")
sperre_fest="/tmp/r3cosint-dod-gate"
sperre_fest_war_verzeichnis=0
sperre_fest_sicherung=$(neu_verzeichnis)
if [ -d "$sperre_fest" ]; then
  sperre_fest_war_verzeichnis=1
  mv "$sperre_fest" "$sperre_fest_sicherung/verzeichnis"
fi
rufe_gate "$eingabe12" "$zustand12" "$WERKZEUGKASTEN_VOLL" "CLAUDE_PROJECT_DIR=$baum" "MOCK_AUSGABE=$ausgabe" "MOCK_RC=2"
pruefe_rc Z-035 "Nicht beschreibbares Zustandsverzeichnis bei roter Kette" 2
pruefe_stderr_enthaelt Z-036 "Nicht beschreibbares Zustandsverzeichnis bei roter Kette" \
  "Zusatz, dass nicht gezaehlt werden kann" "nicht zaehlen"
baum_hash12=$(printf '%s' "$baum" | sha256sum | cut -d' ' -f1)
sperre_datei12="/tmp/r3cosint-dod-gate/sperre-$baum_hash12.lock"
pruefe_datei Z-104 "Zustandsverzeichnis nicht beschreibbar" \
  "Sperrdatei besteht waehrend des Laufs unter /tmp" "$sperre_datei12" existiert
pruefe_rc Z-105 "Zustandsverzeichnis nicht beschreibbar" 2
rm -f "$sperre_datei12"
if [ "$sperre_fest_war_verzeichnis" -eq 1 ]; then
  mv "$sperre_fest_sicherung/verzeichnis" "$sperre_fest"
fi

echo
echo "--- Zustandsverzeichnis UND /tmp nicht beschreibbar (N-04, Entscheid e)"
echo

# --- Z-106/107/108: beide Auswege fuer die Sperre versperrt, ROTE Kette ----
baum=$(neuer_mock_baum)
m1=$(marken_zeile K1 D3 linter A_FAIL "" "" 2)
ausgabe=$(bauen_ausgabe "$baum" "$m1" "$D19_OK" "make dod: abgebrochen bei D3 linter, Rueckgabewert 2.")
zustand_n04_basis=$(neu_verzeichnis)
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
rufe_gate "$eingabe_n04" "$zustand_n04" "$WERKZEUGKASTEN_VOLL" "CLAUDE_PROJECT_DIR=$baum" "MOCK_AUSGABE=$ausgabe" "MOCK_RC=2"
sperre_entstand_n04=$(find "$zustand_n04" -name 'sperre-*' 2>/dev/null | wc -l | tr -d ' ')
[ -n "$sperre_entstand_n04" ] || sperre_entstand_n04=0
rm -f "$sperre_fest"
if [ "$sperre_fest_war_verzeichnis" -eq 1 ]; then
  mv "$sperre_fest_sicherung/verzeichnis" "$sperre_fest"
fi
pruefe_wahr Z-106 "Zustandsverzeichnis und /tmp nicht beschreibbar" \
  "an keinem der beiden Orte entsteht eine Sperrdatei" \
  "$([ "$sperre_entstand_n04" = "0" ] && echo 1 || echo 0)" \
  "keine Sperrdatei" "sperre_entstand=$sperre_entstand_n04"
pruefe_rc Z-107 "Zustandsverzeichnis und /tmp nicht beschreibbar" 2
pruefe_stderr_enthaelt Z-108 "Zustandsverzeichnis und /tmp nicht beschreibbar" \
  "Meldung nennt den Ausfall der Sperre" "Sperre nicht aktiv"

echo
echo "--- Innere Zeitueberschreitung (6.12.12) -------------------------------"
echo

baum=$(neuer_mock_baum)
lauf "$baum" Stop "fall13" "wird nie gedruckt" 0 "" "" "" "$WERKZEUGKASTEN_SCHNELLER_TIMEOUT" 5
pruefe_rc Z-037 "Innere Zeitueberschreitung" 2

echo
echo "--- Eskalation (G8, 6.12.9) --------------------------------------------"
echo

baum=$(neuer_mock_baum)
zustand_esk=$(neu_verzeichnis)
m1=$(marken_zeile K1 D20 belege A_OK "" "" 0)
m2=$(marken_zeile K1 D3 linter A_FAIL "" "" 2)
ausgabe_esk=$(bauen_ausgabe "$baum" "$m1
$m2" "$D19_OK" "make dod: abgebrochen bei D3 linter, Rueckgabewert 2.")
zaehler_datei_esk="$zustand_esk/r3cosint/dod-gate/zaehler-$(printf '%s' 'fall14' | sha256sum | cut -d' ' -f1)"

# 1. und 2. Mal: nur Zustand aufbauen, keine Tabellenzeile bindet daran.
lauf_mit_zustand "$zustand_esk" "$baum" Stop "fall14" "$ausgabe_esk" 2
lauf_mit_zustand "$zustand_esk" "$baum" Stop "fall14" "$ausgabe_esk" 2

# 3. Mal: Z-038/039/040.
lauf_mit_zustand "$zustand_esk" "$baum" Stop "fall14" "$ausgabe_esk" 2
pruefe_zaehler Z-038 "Dreimal derselbe Schluessel" "$zaehler_datei_esk" 3
pruefe_rc Z-039 "Dreimal derselbe Schluessel" 2
pruefe_stderr_enthaelt Z-040 "Dreimal derselbe Schluessel" \
  "die Meldung enthaelt die Zeile Eskalation 3.4: <Schluessel> woertlich" "Eskalation 3.4: D3 linter A_FAIL"

# Uebergabedatei anlegen (uncommittet) -- 4. Mal muss durchlassen.
mkdir -p "$baum/docs/uebergaben"
printf 'Uebergabe\n\nEskalation 3.4: D3 linter A_FAIL\n' > "$baum/docs/uebergaben/2026-09-02_selbsttest-eskalation.md"
lauf_mit_zustand "$zustand_esk" "$baum" Stop "fall14" "$ausgabe_esk" 2
pruefe_rc Z-041 "Uebergabedatei mit der geforderten Zeile, neu oder geaendert" 0
pruefe_zaehler Z-042 "Uebergabedatei mit der geforderten Zeile, neu oder geaendert" "$zaehler_datei_esk" 4

# Committen -> weiterhin Durchlass, jetzt ueber HEAD (Z-043/044, Befund DT-B4).
git -C "$baum" add -A
git -C "$baum" commit -q -m "Eskalationsuebergabe"
head_hat_datei43=0
git -C "$baum" ls-tree -r HEAD --name-only 2>/dev/null | \
  grep -qF "docs/uebergaben/2026-09-02_selbsttest-eskalation.md" && head_hat_datei43=1
pruefe_wahr Z-043 "Uebergabedatei mit der geforderten Zeile, committet" \
  "vor dem Aufruf des Gates fuehrt 'git ls-tree -r HEAD' die Datei -- sie ist wirklich in HEAD" \
  "$head_hat_datei43" "1 (Datei in HEAD)" "$head_hat_datei43"
lauf_mit_zustand "$zustand_esk" "$baum" Stop "fall14" "$ausgabe_esk" 2
pruefe_rc Z-044 "Uebergabedatei mit der geforderten Zeile, committet" 0

# Ein WEITERER Commit danach -- die Uebergabedatei wird ENTFERNT, damit sie
# aus "git ls-tree -r HEAD" wirklich verschwindet (ein blosser weiterer
# Commit daneben liesse sie dort stehen, "ls-tree -r HEAD" listet den
# gesamten Baum, nicht nur die zuletzt geaenderten Dateien -- ausgefuehrt
# belegt in einer frueheren Fassung dieses Falls).
git -C "$baum" rm -q "docs/uebergaben/2026-09-02_selbsttest-eskalation.md"
git -C "$baum" commit -q -m "weiterer Commit, Eskalationsuebergabe entfernt (nicht mehr HEAD)"
head_ohne_datei45=1
git -C "$baum" ls-tree -r HEAD --name-only 2>/dev/null | \
  grep -qF "docs/uebergaben/2026-09-02_selbsttest-eskalation.md" && head_ohne_datei45=0
aelterer_commit_hat_datei45=0
[ -n "$(git -C "$baum" log --all --format=%H -- "docs/uebergaben/2026-09-02_selbsttest-eskalation.md" 2>/dev/null)" ] && aelterer_commit_hat_datei45=1
pruefe_wahr Z-045 "Uebergabedatei nur in einem aelteren Commit" \
  "vor dem Aufruf fuehrt 'git ls-tree -r HEAD' die Datei NICHT, ein aelterer Commit dagegen schon" \
  "$([ "$head_ohne_datei45" -eq 1 ] && [ "$aelterer_commit_hat_datei45" -eq 1 ] && echo 1 || echo 0)" \
  "HEAD ohne, aelterer Commit mit Datei" "head_ohne=$head_ohne_datei45, aelterer_hat=$aelterer_commit_hat_datei45"
lauf_mit_zustand "$zustand_esk" "$baum" Stop "fall14" "$ausgabe_esk" 2
pruefe_rc Z-046 "Uebergabedatei nur in einem aelteren Commit" 2

# Dieselbe Eskalation (Datei wieder aktuell UND in HEAD) auf TaskCompleted
# (Z-047/048). "git rm" oben hat das nun leere Verzeichnis mit entfernt
# (Git raeumt leere Elternverzeichnisse beim Entfernen der letzten
# verfolgten Datei mit auf) -- deshalb hier erneut angelegt.
mkdir -p "$baum/docs/uebergaben"
printf 'Uebergabe\n\nEskalation 3.4: D3 linter A_FAIL\n\nErneut fuer Z-048 (TaskCompleted), DT-B4.\n' \
  > "$baum/docs/uebergaben/2026-09-02_selbsttest-eskalation.md"
git -C "$baum" add -A
git -C "$baum" commit -q -m "Eskalationsuebergabe wieder aktuell" || true
head_hat_datei48=0
git -C "$baum" diff-tree --no-commit-id --name-only -r HEAD 2>/dev/null | \
  grep -qF "docs/uebergaben/2026-09-02_selbsttest-eskalation.md" && head_hat_datei48=1
grund48_ok=0
if [ "$head_hat_datei48" -eq 1 ] && grep -qF "Eskalation 3.4: D3 linter A_FAIL" \
     "$baum/docs/uebergaben/2026-09-02_selbsttest-eskalation.md"; then
  grund48_ok=1
fi
pruefe_wahr Z-048 "Dieselbe Eskalation auf TaskCompleted" \
  "die Uebergabedatei mit der geforderten Zeile liegt vor und ist in HEAD enthalten" \
  "$grund48_ok" "1 (Datei mit Zeile in HEAD)" "$grund48_ok"
lauf_mit_zustand "$zustand_esk" "$baum" TaskCompleted "fall14" "$ausgabe_esk" 2
pruefe_rc Z-047 "Dieselbe Eskalation auf TaskCompleted" 2

echo
echo "--- Vierter Durchlass, danach erneut Blocks (6.12.24 d, DT2-B1; S3-07) -"
echo

# --- Z-125..Z-129: eigene, isolierte Sequenz, Uebergabedatei liegt von
#     Anfang an vor (die Datei muss bereits beim VIERTEN Aufruf bestehen,
#     damit der Zaehlerstand bei diesem Durchlass genau 4 ist). -------------
baum_v4=$(neuer_mock_baum)
zustand_v4=$(neu_verzeichnis)
m1=$(marken_zeile K1 D20 belege A_OK "" "" 0)
m2=$(marken_zeile K1 D3 linter A_FAIL "" "" 2)
ausgabe_v4=$(bauen_ausgabe "$baum_v4" "$m1
$m2" "$D19_OK" "make dod: abgebrochen bei D3 linter, Rueckgabewert 2.")
mkdir -p "$baum_v4/docs/uebergaben"
printf 'Uebergabe\n\nEskalation 3.4: D3 linter A_FAIL\n' > "$baum_v4/docs/uebergaben/2026-09-02_v4-uebergabe.md"
git -C "$baum_v4" add -A
git -C "$baum_v4" commit -q -m "Uebergabe von Anfang an vorhanden"
zaehler_datei_v4="$zustand_v4/r3cosint/dod-gate/zaehler-$(printf '%s' 'fall-v4' | sha256sum | cut -d' ' -f1)"

lauf_mit_zustand "$zustand_v4" "$baum_v4" Stop "fall-v4" "$ausgabe_v4" 2
lauf_mit_zustand "$zustand_v4" "$baum_v4" Stop "fall-v4" "$ausgabe_v4" 2
lauf_mit_zustand "$zustand_v4" "$baum_v4" Stop "fall-v4" "$ausgabe_v4" 2

# 4. Mal: Durchlass.
lauf_mit_zustand "$zustand_v4" "$baum_v4" Stop "fall-v4" "$ausgabe_v4" 2
pruefe_zaehler Z-125 "Vierter Durchlass nach der Eskalation, danach erneut Blocks" "$zaehler_datei_v4" 4

# 5. Mal: weiterer Durchlass, Zaehler 5, Meldung nennt "5. Mal in Folge".
lauf_mit_zustand "$zustand_v4" "$baum_v4" Stop "fall-v4" "$ausgabe_v4" 2
pruefe_zaehler Z-126 "Vierter Durchlass, danach erneut Blocks" "$zaehler_datei_v4" 5
pruefe_stdout_enthaelt Z-128 "Vierter Durchlass, danach erneut Blocks" \
  "die Meldung des fuenften Ereignisses nennt das fuenfte Mal" "5. Mal in Folge"
# 6.12.25 g (Befund S4-01/DT4-02): Z-129 misst NICHT die Abwesenheit des
# woertlichen Zitats "Eskalation 3.4: <Schluessel>" -- das Zitat traegt die
# Begruendung des Durchlasses und ist auf stdout jedes weiteren Durchlasses
# ZULAESSIG (dod-gate.sh Zeile ~519). Gemessen wird die FORDERUNG selbst,
# Zeichenfolge "verlangt die Uebergabedatei" (dod-gate.sh Zeile ~538, nur im
# BLOCK bei genau drittem Mal ausgegeben) -- auf KEINEM der beiden Kanaele,
# am fuenften Ereignis (dieser Stop-Aufruf) UND an einem TaskCompleted im
# selben Zustand (gleicher Zaehlerschluessel).
gefunden129_stop=0
printf '%s%s' "$G_STDOUT" "$G_STDERR" | grep -qF "verlangt die Uebergabedatei" && gefunden129_stop=1

# 6. Mal: weiterer Durchlass, Zaehler 6.
lauf_mit_zustand "$zustand_v4" "$baum_v4" Stop "fall-v4" "$ausgabe_v4" 2
pruefe_zaehler Z-127 "Vierter Durchlass, danach erneut Blocks" "$zaehler_datei_v4" 6

# 7. Mal, als TaskCompleted im selben Zustand (zweiter Messpunkt fuer Z-129).
lauf_mit_zustand "$zustand_v4" "$baum_v4" TaskCompleted "fall-v4" "$ausgabe_v4" 2
gefunden129_tc=0
printf '%s%s' "$G_STDOUT" "$G_STDERR" | grep -qF "verlangt die Uebergabedatei" && gefunden129_tc=1

pruefe_wahr Z-129 "Vierter Durchlass, danach erneut Blocks" \
  "bei jedem Ereignis nach dem vierten Durchlass -- geprueft am fuenften Ereignis (Stop) und an einem TaskCompleted im selben Zustand -- enthaelt weder stdout noch stderr die Zeichenfolge 'verlangt die Uebergabedatei'" \
  "$([ "$gefunden129_stop" -eq 0 ] && [ "$gefunden129_tc" -eq 0 ] && echo 1 || echo 0)" \
  "keine Forderung auf beiden Kanaelen bei beiden Ereignissen" \
  "stop_gefunden=$gefunden129_stop, taskcompleted_gefunden=$gefunden129_tc"

echo
echo "--- Mehrere Abweichungen zugleich (6.12.25 b, Befund S3-01) -----------"
echo

# --- Z-049..Z-053: A_FAIL, zwei ungedeckte Lagen C, D19 VERLETZT zugleich --
baum=$(neuer_mock_baum)
m1=$(marken_zeile K1 D20 belege A_OK "" "" 0)
m2=$(marken_zeile K1 D7 abnahme C scripts/abnahme-abgleich.sh "" 2)
m3=$(marken_zeile K1 D10 prototyp-trennung C scripts/prototyp-trennung-pruefen.sh "" 2)
m4=$(marken_zeile K1 D3 linter A_FAIL "" "" 2)
ausgabe_s301=$(bauen_ausgabe "$baum" "$m1
$m2
$m3
$m4" "VERLETZT -- versionierter Bestand veraendert." "make dod: alle 4 Kettenschritte durchlaufen, 2 davon ohne Urteil (Lage C): D7 abnahme FEHLT=scripts/abnahme-abgleich.sh, D10 prototyp-trennung FEHLT=scripts/prototyp-trennung-pruefen.sh, Rueckgabewert 2.")
zustand_s301=$(neu_verzeichnis)
lauf_mit_zustand "$zustand_s301" "$baum" Stop "fall-s3-01" "$ausgabe_s301" 2
pruefe_rc Z-049 "Lauf mit A_FAIL, zwei ungedeckten Lagen C und D19 VERLETZT zugleich" 2
# 6.12.4 definiert den Schluessel einer ungedeckten Lage C VOLLSTAENDIG als
# "<D> <ziel> C <fehlendes Pruefmittel>" -- nicht als blosses Praefix. Die
# erste Abweichung in Kettenreihenfolge ist hier D7 abnahme mit
# FEHLT=scripts/abnahme-abgleich.sh (siehe m2 oben), der Schluessel traegt
# diesen Wert mit.
pruefe_zaehler_schluessel Z-050 "Lauf mit A_FAIL, zwei ungedeckten Lagen C und D19 VERLETZT zugleich" \
  "$(zaehler_pfad "$zustand_s301" "fall-s3-01")" "D7 abnahme C scripts/abnahme-abgleich.sh"
pruefe_stderr_enthaelt Z-051 "Lauf mit A_FAIL, zwei ungedeckten Lagen C und D19 VERLETZT zugleich" \
  "die Blockmeldung nennt jede A_FAIL-Marke" "weitere Abweichung: Schritt D3 linter meldet Lage A_FAIL"
pruefe_stderr_enthaelt Z-052 "Lauf mit A_FAIL, zwei ungedeckten Lagen C und D19 VERLETZT zugleich" \
  "die Blockmeldung nennt jede ungedeckte Lage C mit ihrem FEHLT=-Wert" \
  "weitere Abweichung: Schritt D10 prototyp-trennung meldet Lage C mit FEHLT=scripts/prototyp-trennung-pruefen.sh"
pruefe_stderr_enthaelt Z-053 "Lauf mit A_FAIL, zwei ungedeckten Lagen C und D19 VERLETZT zugleich" \
  "die Blockmeldung nennt den D19-Befund" "weitere Abweichung: D19 meldet VERLETZT"

echo
echo "--- FEHLT= und SCHWELLE= zugleich (6.12.4) ------------------------------"
echo

# --- Z-054/055 ---------------------------------------------------------------
baum=$(neuer_mock_baum)
printf 'D3 linter|scripts/nicht-vorhanden.sh\tADR 0002, 6.12.5, Selbsttest.\n' > "$baum/.claude/hooks/dod-gate-terminierte-lagen.txt"
m1=$(marken_zeile K1 D3 linter C scripts/nicht-vorhanden.sh OHNE_SCHWELLE 2)
ausgabe=$(bauen_ausgabe "$baum" "$m1" "$D19_OK" "make dod: alle 1 Kettenschritte durchlaufen, 1 davon ohne Urteil (Lage C): D3 linter FEHLT=scripts/nicht-vorhanden.sh, Rueckgabewert 2.")
lauf "$baum" Stop "fall20" "$ausgabe" 2
enthaelt_richtig54=0
printf '%s' "$G_STDOUT" | grep -qF "D3 linter FEHLT=scripts/nicht-vorhanden.sh" && enthaelt_richtig54=1
enthaelt_ohne_schwelle54=0
printf '%s' "$G_STDOUT" | grep -qF "OHNE_SCHWELLE" && enthaelt_ohne_schwelle54=1
pruefe_wahr Z-054 "Marke mit FEHLT= und SCHWELLE= zugleich" \
  "der gelesene FEHLT=-Wert ist genau der Pfad, ohne den SCHWELLE=-Teil" \
  "$([ "$enthaelt_richtig54" -eq 1 ] && [ "$enthaelt_ohne_schwelle54" -eq 0 ] && echo 1 || echo 0)" \
  "'D3 linter FEHLT=scripts/nicht-vorhanden.sh' ohne 'OHNE_SCHWELLE'" "stdout='$(_kuerzen "$G_STDOUT")'"
pruefe_rc Z-055 "Marke mit FEHLT= und SCHWELLE= zugleich" 0

echo
echo "--- D19-Formen (G7, N-02) ------------------------------------------------"
echo

# --- Z-056..Z-063: acht Kombinationen, je mit und ohne Zusatztext ----------
baum=$(neuer_mock_baum)
m1=$(marken_zeile K1 D20 belege A_OK "" "" 0)
for eintrag in \
  "OHNE_BEFUND.|erfolg|0|Z-056" \
  "OHNE_BEFUND -- Text.|erfolg|0|Z-057" \
  "VERLETZT.|d19|2|Z-058" \
  "VERLETZT -- Text.|d19|2|Z-059" \
  "B.|erfolg|2|Z-060" \
  "B -- Text.|erfolg|2|Z-061" \
  "C.|d19|2|Z-062" \
  "C -- Text.|d19|2|Z-063"; do
  form="${eintrag%%|*}"
  rest="${eintrag#*|}"
  art="${rest%%|*}"
  rest="${rest#*|}"
  mock_rc="${rest%%|*}"
  kennung="${rest#*|}"
  schluesselwort="${form%%[ .]*}"
  if [ "$art" = "erfolg" ]; then
    schluss="make dod: alle 1 Kettenschritte durchlaufen, keiner ungleich 0, 1 gueltige Marken gezaehlt."
  else
    schluss="make dod: alle 1 Kettenschritte durchlaufen, Rahmenpruefung D19 ${schluesselwort}, Rueckgabewert 2."
  fi
  ausgabe=$(bauen_ausgabe "$baum" "$m1" "$form" "$schluss")
  lauf "$baum" Stop "fall-d19-$kennung" "$ausgabe" "$mock_rc"
  case "$schluesselwort" in
    OHNE_BEFUND)
      pruefe_rc "$kennung" "D19-Zeile $form" 0
      ;;
    VERLETZT)
      pruefe_stderr_enthaelt "$kennung" "D19-Zeile $form" "die Auswertung ordnet der Zeile VERLETZT zu" "Schluessel: D19 VERLETZT"
      ;;
    B)
      pruefe_stderr_enthaelt "$kennung" "D19-Zeile $form" "die Auswertung ordnet der Zeile Lage B zu" "Schluessel: D19 B-widerspruch"
      ;;
    C)
      pruefe_stderr_enthaelt "$kennung" "D19-Zeile $form" "die Auswertung ordnet der Zeile Lage C zu" "Schluessel: D19 C"
      ;;
  esac
done

echo
echo "--- D19 Lage B bei rc0, obwohl das Gate einen Arbeitsbaum bestimmt hat"
echo "    (S-01) -----------------------------------------------------------"
echo

# --- Z-142/143 ----------------------------------------------------------------
baum=$(neuer_mock_baum)
m1=$(marken_zeile K1 D20 belege A_OK "" "" 0)
ausgabe_s01=$(bauen_ausgabe "$baum" "$m1" "B -- kein Git-Arbeitsbaum." "make dod: alle 1 Kettenschritte durchlaufen, keiner ungleich 0, 1 gueltige Marken gezaehlt.")
lauf "$baum" Stop "fall-s01" "$ausgabe_s01" 0
pruefe_rc Z-142 "D19-Zeile meldet Lage B bei Rueckgabewert 0, obwohl das Gate einen Arbeitsbaum bestimmt hat" 2
pruefe_stderr_enthaelt Z-143 "D19-Zeile meldet Lage B bei Rueckgabewert 0" \
  "der gezaehlte Schluessel ist genau D19 B-widerspruch und nicht KETTE ausgabe-unlesbar" "Schluessel: D19 B-widerspruch"

echo
echo "--- TaskCompleted bei roter Kette ----------------------------------------"
echo

# --- Z-064 ---------------------------------------------------------------
baum=$(neuer_mock_baum)
m1=$(marken_zeile K1 D3 linter A_FAIL "" "" 2)
ausgabe=$(bauen_ausgabe "$baum" "$m1" "$D19_OK" "make dod: abgebrochen bei D3 linter, Rueckgabewert 2.")
lauf "$baum" TaskCompleted "fall22" "$ausgabe" 2
pruefe_rc Z-064 "TaskCompleted bei roter Kette" 2

echo
echo "--- SubagentStop und echte Rollendateien (G13, 6.12.14; N-03) ---------"
echo

# --- Z-065/067/068: echte Rolle static-software-tester (kein Edit/Write) --
baum_sst=$(neuer_mock_baum)
cp "$REPO_WURZEL/.claude/agents/static-software-tester.md" "$baum_sst/.claude/agents/static-software-tester.md"
summe_quelle68=$(sha256sum "$REPO_WURZEL/.claude/agents/static-software-tester.md" | cut -d' ' -f1)
summe_kopie68=$(sha256sum "$baum_sst/.claude/agents/static-software-tester.md" | cut -d' ' -f1)
pruefe_wahr Z-068 "N-03: echte Rollendatei im Scheinbaum" \
  "die im Scheinbaum verwendete Rollendatei ist pruefsummengleich mit der aus .claude/agents/" \
  "$([ "$summe_quelle68" = "$summe_kopie68" ] && echo 1 || echo 0)" \
  "$summe_quelle68" "$summe_kopie68"
zustand_sst=$(neu_verzeichnis)
marker_sst=$(neu_verzeichnis)/marker
eingabe_sst=$(baue_eingabe "SubagentStop" "$baum_sst" "fall-sst" "false" "a1" "static-software-tester")
rufe_gate "$eingabe_sst" "$zustand_sst" "$WERKZEUGKASTEN_VOLL" "CLAUDE_PROJECT_DIR=$baum_sst" "MOCK_AUSGABE=roter Muell, duerfte nie gelesen werden" "MOCK_RC=2" "MOCK_MARKER=$marker_sst"
pruefe_rc Z-065 "SubagentStop echte Rolle static-software-tester" 0
pruefe_wahr Z-067 "SubagentStop einer Rolle ohne veraenderndes Werkzeug" \
  "die Attrappe von make dod verzeichnet keinen Aufruf" \
  "$([ ! -e "$marker_sst" ] && echo 1 || echo 0)" \
  "keine Markerdatei" "$([ -e "$marker_sst" ] && echo "Markerdatei besteht" || echo "keine Markerdatei")"

# --- Z-066: echte Rolle pentester (kein Edit/Write) ------------------------
baum_pt=$(neuer_mock_baum)
cp "$REPO_WURZEL/.claude/agents/pentester.md" "$baum_pt/.claude/agents/pentester.md"
zustand_pt=$(neu_verzeichnis)
eingabe_pt=$(baue_eingabe "SubagentStop" "$baum_pt" "fall-pt" "false" "a1" "pentester")
rufe_gate "$eingabe_pt" "$zustand_pt" "$WERKZEUGKASTEN_VOLL" "CLAUDE_PROJECT_DIR=$baum_pt" "MOCK_AUSGABE=roter Muell, duerfte nie gelesen werden" "MOCK_RC=2"
pruefe_rc Z-066 "SubagentStop echte Rolle pentester" 0

# --- Z-069/070: echte Rolle devops-engineer (mit Edit/Write), ROTE Kette --
baum_dev=$(neuer_mock_baum)
cp "$REPO_WURZEL/.claude/agents/devops-engineer.md" "$baum_dev/.claude/agents/devops-engineer.md"
m1=$(marken_zeile K1 D3 linter A_FAIL "" "" 2)
ausgabe_dev=$(bauen_ausgabe "$baum_dev" "$m1" "$D19_OK" "make dod: abgebrochen bei D3 linter, Rueckgabewert 2.")
zustand_dev=$(neu_verzeichnis)
marker_dev=$(neu_verzeichnis)/marker
eingabe_dev=$(baue_eingabe "SubagentStop" "$baum_dev" "fall-devops" "false" "a1" "devops-engineer")
rufe_gate "$eingabe_dev" "$zustand_dev" "$WERKZEUGKASTEN_VOLL" "CLAUDE_PROJECT_DIR=$baum_dev" "MOCK_AUSGABE=$ausgabe_dev" "MOCK_RC=2" "MOCK_MARKER=$marker_dev"
pruefe_wahr Z-069 "SubagentStop echte Rolle devops-engineer" \
  "die Attrappe von make dod verzeichnet einen Aufruf" \
  "$([ -e "$marker_dev" ] && echo 1 || echo 0)" \
  "Markerdatei besteht" "$([ -e "$marker_dev" ] && echo "Markerdatei besteht" || echo "keine Markerdatei")"
pruefe_rc Z-070 "SubagentStop echte Rolle devops-engineer" 2

echo
echo "--- agent_type: Aufloesung ueber name:, nicht ueber den Dateinamen (G13)"
echo

# --- Z-071/072: agent_type ueber name: aufgeloest (anders-benannt.md) -----
baum=$(neuer_mock_baum)
zustand25=$(neu_verzeichnis)
marker25=$(neu_verzeichnis)/marker
eingabe25=$(baue_eingabe "SubagentStop" "$baum" "fall25" "false" "a1" "attrappe-pruefer")
rufe_gate "$eingabe25" "$zustand25" "$WERKZEUGKASTEN_VOLL" "CLAUDE_PROJECT_DIR=$baum" "MOCK_AUSGABE=roter Muell" "MOCK_RC=2" "MOCK_MARKER=$marker25"
pruefe_wahr Z-071 "agent_type, der ueber name: aufzuloesen ist und nicht ueber den Dateinamen" \
  "die Attrappe von make dod verzeichnet keinen Aufruf" \
  "$([ ! -e "$marker25" ] && echo 1 || echo 0)" \
  "keine Markerdatei" "$([ -e "$marker25" ] && echo "Markerdatei besteht" || echo "keine Markerdatei")"
pruefe_rc Z-072 "agent_type, der ueber name: aufzuloesen ist" 0

# --- Z-073/074: unbekannter agent_type -> Kette laeuft (roter Lauf) -------
baum=$(neuer_mock_baum)
m1=$(marken_zeile K1 D3 linter A_FAIL "" "" 2)
ausgabe=$(bauen_ausgabe "$baum" "$m1" "$D19_OK" "make dod: abgebrochen bei D3 linter, Rueckgabewert 2.")
zustand26a=$(neu_verzeichnis)
marker26a=$(neu_verzeichnis)/marker
eingabe26a=$(baue_eingabe "SubagentStop" "$baum" "fall26a" "false" "a1" "voellig-unbekannte-rolle")
rufe_gate "$eingabe26a" "$zustand26a" "$WERKZEUGKASTEN_VOLL" "CLAUDE_PROJECT_DIR=$baum" "MOCK_AUSGABE=$ausgabe" "MOCK_RC=2" "MOCK_MARKER=$marker26a"
pruefe_wahr Z-073 "SubagentStop mit unbekanntem agent_type" \
  "die Attrappe von make dod verzeichnet einen Aufruf" \
  "$([ -e "$marker26a" ] && echo 1 || echo 0)" \
  "Markerdatei besteht" "$([ -e "$marker26a" ] && echo "Markerdatei besteht" || echo "keine Markerdatei")"
pruefe_rc Z-074 "SubagentStop mit unbekanntem agent_type" 2

# --- Z-075/076: leerer agent_type -> Kette laeuft (roter Lauf) ------------
zustand26b=$(neu_verzeichnis)
marker26b=$(neu_verzeichnis)/marker
eingabe26b=$(baue_eingabe "SubagentStop" "$baum" "fall26b" "false" "a1" "")
rufe_gate "$eingabe26b" "$zustand26b" "$WERKZEUGKASTEN_VOLL" "CLAUDE_PROJECT_DIR=$baum" "MOCK_AUSGABE=$ausgabe" "MOCK_RC=2" "MOCK_MARKER=$marker26b"
pruefe_wahr Z-075 "SubagentStop mit leerem agent_type" \
  "die Attrappe von make dod verzeichnet einen Aufruf" \
  "$([ -e "$marker26b" ] && echo 1 || echo 0)" \
  "Markerdatei besteht" "$([ -e "$marker26b" ] && echo "Markerdatei besteht" || echo "keine Markerdatei")"
pruefe_rc Z-076 "SubagentStop mit leerem agent_type" 2

# --- Z-077/078: mehrdeutiger agent_type (zwei Treffer) -> roter Lauf -----
cp "$baum/.claude/agents/attrappe-schreiber.md" "$baum/.claude/agents/zweite-kopie.md"
git -C "$baum" add -A
git -C "$baum" commit -q -m "mehrdeutiger agent_type"
zustand26c=$(neu_verzeichnis)
marker26c=$(neu_verzeichnis)/marker
eingabe26c=$(baue_eingabe "SubagentStop" "$baum" "fall26c" "false" "a1" "attrappe-schreiber")
rufe_gate "$eingabe26c" "$zustand26c" "$WERKZEUGKASTEN_VOLL" "CLAUDE_PROJECT_DIR=$baum" "MOCK_AUSGABE=$ausgabe" "MOCK_RC=2" "MOCK_MARKER=$marker26c"
pruefe_wahr Z-077 "SubagentStop mit mehrdeutigem agent_type" \
  "die Attrappe von make dod verzeichnet einen Aufruf" \
  "$([ -e "$marker26c" ] && echo 1 || echo 0)" \
  "Markerdatei besteht" "$([ -e "$marker26c" ] && echo "Markerdatei besteht" || echo "keine Markerdatei")"
pruefe_rc Z-078 "SubagentStop mit mehrdeutigem agent_type" 2

echo
echo "--- Flacher Klon (G16) -----------------------------------------------"
echo

# --- Z-079/080: ein .git/shallow im Scheinbaum, kein echter Netz-Klon -----
scheinbaum_klon=$(neu_verzeichnis)
git -C "$scheinbaum_klon" init -q
git -C "$scheinbaum_klon" config user.email "selbsttest@example.invalid"
git -C "$scheinbaum_klon" config user.name "Selbsttest"
cp "$ECHTES_MAKEFILE" "$scheinbaum_klon/Makefile"
mkdir -p "$scheinbaum_klon/scripts"
cp "$ECHTER_BELEGPRUEFER" "$scheinbaum_klon/scripts/belege-pruefen.sh"
git -C "$scheinbaum_klon" add -A
git -C "$scheinbaum_klon" commit -q -m init
kopf_sha_klon=$(git -C "$scheinbaum_klon" rev-parse HEAD)
printf '%s\n' "$kopf_sha_klon" > "$scheinbaum_klon/.git/shallow"
ausgabe79=$(make -s -C "$scheinbaum_klon" belege 2>&1)
rc79=$?
pruefe_rc_wert Z-079 "Flacher Klon" "Rueckgabewert 2" 2 "$rc79"
gehalt80=0
printf '%s' "$ausgabe79" | grep -qF "git fetch --unshallow" && gehalt80=1
pruefe_wahr Z-080 "Flacher Klon" "die Meldung nennt 'git fetch --unshallow'" \
  "$gehalt80" "1 (enthalten)" "$gehalt80"

echo
echo "--- Baumbestimmung ueber show-toplevel (6.12.13, B-02/B-03/DT-B5) -----"
echo

# --- Z-081..Z-095: fuenf Varianten von cwd, je rc0/stdout-leer/Baumzeile --
g12_pruefen() {
  local beschreibung="$1" cwd_wert="$2" proj_wert="$3" erwartete_wurzel="$4"
  local z_baum="$5" z_rc="$6" z_stdout="$7"
  local m1 ausgabe zustand eingabe
  m1=$(marke K1 D20 belege A_OK)
  ausgabe=$(bauen_ausgabe "$erwartete_wurzel" "$m1 (rueckgabewert=0)" "$D19_OK" "make dod: alle 1 Kettenschritte durchlaufen, keiner ungleich 0, 1 gueltige Marken gezaehlt.")
  zustand=$(neu_verzeichnis)
  eingabe=$(baue_eingabe "Stop" "$cwd_wert" "fall-g12-$beschreibung")
  rufe_gate "$eingabe" "$zustand" "$WERKZEUGKASTEN_VOLL" "CLAUDE_PROJECT_DIR=$proj_wert" "MOCK_AUSGABE=$ausgabe" "MOCK_RC=0"
  # Das Gate gibt bei sauberem Gruen NICHTS aus (6.12.15); die einzige
  # verfuegbare Bestaetigung, dass es DIE gebaute (und damit die erwartete)
  # Wurzel akzeptiert hat, ist die Abwesenheit eines Widerspruchs auf stderr
  # -- ein falsch aufgeloester Baum haette "KETTE baum-widerspruch" ausgeloest.
  pruefe_wahr "$z_baum" "$beschreibung" \
    "Baumzeile nennt die erwartete Wurzel (indirekt: sauberes Gruen ohne Baum-Widerspruch)" \
    "$([ "$G_RC" = "0" ] && [ -z "$G_STDERR" ] && echo 1 || echo 0)" \
    "rc=0, stderr leer" "rc=$G_RC, stderr='$(_kuerzen "$G_STDERR")'"
  pruefe_rc "$z_rc" "$beschreibung" 0
  pruefe_stdout_leer "$z_stdout" "$beschreibung"
}

baum=$(neuer_mock_baum)
mkdir -p "$baum/ein/unterverzeichnis"
g12_pruefen "cwd in einem Unterverzeichnis des Baums, gruener Scheinbaum" "$baum/ein/unterverzeichnis" "$baum" "$baum" Z-083 Z-081 Z-082

baum=$(neuer_mock_baum)
g12_pruefen "cwd mit Schraegstrich am Ende, gruener Scheinbaum" "$baum/" "$baum/" "$baum" Z-086 Z-084 Z-085

baum=$(neuer_mock_baum)
symlink_verz=$(neu_verzeichnis)
ln -s "$baum" "$symlink_verz/verweis"
g12_pruefen "cwd ueber einen Symlink auf den Baum, gruener Scheinbaum" "$symlink_verz/verweis" "$symlink_verz/verweis" "$baum" Z-089 Z-087 Z-088

baum=$(neuer_mock_baum)
ausserhalb=$(neu_verzeichnis)
g12_pruefen "cwd ausserhalb jedes Arbeitsbaums dieses Repositories" "$ausserhalb" "$baum" "$baum" Z-092 Z-090 Z-091

baum=$(neuer_mock_baum)
worktree_verz=$(neu_verzeichnis)
rm -rf "$worktree_verz"
if git -C "$baum" worktree add -q -b fall-worktree "$worktree_verz" >/dev/null 2>&1; then
  AUFRAEUM_VERZEICHNISSE+=("$worktree_verz")
  worktree_wurzel=$(cd "$worktree_verz" && pwd -P)
  m1=$(marke K1 D20 belege A_OK)
  ausgabe=$(bauen_ausgabe "$worktree_wurzel" "$m1 (rueckgabewert=0)" "$D19_OK" "make dod: alle 1 Kettenschritte durchlaufen, keiner ungleich 0, 1 gueltige Marken gezaehlt.")
  zustand=$(neu_verzeichnis)
  eingabe=$(baue_eingabe "Stop" "$worktree_wurzel" "fall-worktree")
  rufe_gate "$eingabe" "$zustand" "$WERKZEUGKASTEN_VOLL" "CLAUDE_PROJECT_DIR=$baum" "MOCK_AUSGABE=$ausgabe" "MOCK_RC=0"
  pruefe_wahr Z-093 "Zweiter Arbeitsbaum (git worktree), cwd darin" \
    "die Baumzeile nennt den zweiten Baum, nicht den Hauptbaum" \
    "$([ "$worktree_wurzel" != "$baum" ] && [ "$G_RC" = "0" ] && [ -z "$G_STDERR" ] && echo 1 || echo 0)" \
    "worktree != baum, rc=0, stderr leer" "worktree=$worktree_wurzel, baum=$baum, rc=$G_RC, stderr='$(_kuerzen "$G_STDERR")'"
  pruefe_rc Z-094 "Zweiter Arbeitsbaum (git worktree), cwd darin" 0
  pruefe_stdout_leer Z-095 "Zweiter Arbeitsbaum (git worktree), cwd darin"
else
  echo "HINWEIS  Zweiter Arbeitsbaum (worktree): 'git worktree add' ist in dieser Umgebung fehlgeschlagen -- Z-093 bis Z-095 bleiben ungemessen und werden von der Deckungspruefung genannt."
fi

echo
echo "--- Baumzeile falsch bzw. fehlend (S-03/S-10) --------------------------"
echo

# --- Z-096/097: Baumzeile nennt einen ANDEREN Baum ------------------------
baum=$(neuer_mock_baum)
anderer_baum_s03=$(neu_verzeichnis)
m1=$(marken_zeile K1 D20 belege A_OK "" "" 0)
ausgabe_s03=$(bauen_ausgabe "$anderer_baum_s03" "$m1" "$D19_OK" "make dod: alle 1 Kettenschritte durchlaufen, keiner ungleich 0, 1 gueltige Marken gezaehlt.")
zustand_s03=$(neu_verzeichnis)
lauf_mit_zustand "$zustand_s03" "$baum" Stop "fall-s03" "$ausgabe_s03" 0
pruefe_rc Z-096 "Baumzeile nennt einen anderen Baum" 2
pruefe_zaehler_schluessel Z-097 "Baumzeile nennt einen anderen Baum" \
  "$(zaehler_pfad "$zustand_s03" "fall-s03")" "KETTE baum-widerspruch"

# --- Z-144/145: Baumzeile fehlt GANZ ---------------------------------------
baum=$(neuer_mock_baum)
m1=$(marken_zeile K1 D20 belege A_OK "" "" 0)
ausgabe_s10=$(printf '=== Uebersicht Definition-of-Done-Kette (make dod) ===\n%s\n\nmake dod: D19: %s\n%s\n' \
  "$m1" "$D19_OK" "make dod: alle 1 Kettenschritte durchlaufen, keiner ungleich 0, 1 gueltige Marken gezaehlt.")
zustand_s10=$(neu_verzeichnis)
lauf_mit_zustand "$zustand_s10" "$baum" Stop "fall-s10" "$ausgabe_s10" 0
pruefe_rc Z-144 "Baumzeile fehlt ganz" 2
pruefe_zaehler_schluessel Z-145 "Baumzeile fehlt ganz" \
  "$(zaehler_pfad "$zustand_s10" "fall-s10")" "KETTE ausgabe-unlesbar"

echo
echo "--- Weder XDG_STATE_HOME noch HOME gesetzt (set -u) --------------------"
echo

# --- Z-098..Z-100: rote Kette ----------------------------------------------
baum=$(neuer_mock_baum)
m1=$(marken_zeile K1 D3 linter A_FAIL "" "" 2)
ausgabe_b01r=$(bauen_ausgabe "$baum" "$m1" "$D19_OK" "make dod: abgebrochen bei D3 linter, Rueckgabewert 2.")
eingabe_b01r=$(baue_eingabe "Stop" "$baum" "fall-b01-rot")
rufe_gate_ohne_home "$eingabe_b01r" "$WERKZEUGKASTEN_VOLL" "CLAUDE_PROJECT_DIR=$baum" "MOCK_AUSGABE=$ausgabe_b01r" "MOCK_RC=2"
pruefe_rc Z-098 "Weder XDG_STATE_HOME noch HOME gesetzt, rote Kette" 2
pruefe_stderr_enthaelt Z-099 "Weder XDG_STATE_HOME noch HOME gesetzt, rote Kette" \
  "Zusatz, dass nicht gezaehlt werden kann" "nicht zaehlen"
enthaelt_bestimmbar100=0
printf '%s' "$G_STDERR" | grep -qF "nicht bestimmbar" && enthaelt_bestimmbar100=1
enthaelt_beschreibbar100=0
printf '%s' "$G_STDERR" | grep -qF "nicht beschreibbar" && enthaelt_beschreibbar100=1
pruefe_wahr Z-100 "Weder XDG_STATE_HOME noch HOME gesetzt, rote Kette" \
  "der Zusatz sagt 'nicht bestimmbar' und nicht 'nicht beschreibbar'" \
  "$([ "$enthaelt_bestimmbar100" -eq 1 ] && [ "$enthaelt_beschreibbar100" -eq 0 ] && echo 1 || echo 0)" \
  "'nicht bestimmbar' vorhanden, 'nicht beschreibbar' nicht" "bestimmbar=$enthaelt_bestimmbar100, beschreibbar=$enthaelt_beschreibbar100"

# --- Z-101..Z-103: gruene Kette ---------------------------------------------
baum=$(neuer_mock_baum)
m1=$(marken_zeile K1 D20 belege A_OK "" "" 0)
ausgabe_b01g=$(bauen_ausgabe "$baum" "$m1" "$D19_OK" "make dod: alle 1 Kettenschritte durchlaufen, keiner ungleich 0, 1 gueltige Marken gezaehlt.")
eingabe_b01g=$(baue_eingabe "Stop" "$baum" "fall-b01-gruen")
rufe_gate_ohne_home "$eingabe_b01g" "$WERKZEUGKASTEN_VOLL" "CLAUDE_PROJECT_DIR=$baum" "MOCK_AUSGABE=$ausgabe_b01g" "MOCK_RC=0"
pruefe_wahr Z-101 "Weder XDG_STATE_HOME noch HOME gesetzt, gruene Kette" \
  "Rueckgabewert 0 -- nie 1" "$([ "$G_RC" = "0" ] && echo 1 || echo 0)" "rc=0" "rc=$G_RC"
pruefe_json_einzelfeld Z-102 "Weder XDG_STATE_HOME noch HOME gesetzt, gruene Kette" systemMessage
enthaelt_bestimmbar103=0
printf '%s' "$G_STDOUT" | grep -qF "nicht bestimmbar" && enthaelt_bestimmbar103=1
pruefe_wahr Z-103 "Weder XDG_STATE_HOME noch HOME gesetzt, gruene Kette" \
  "der Zusatz sagt 'nicht bestimmbar'" "$enthaelt_bestimmbar103" "1 (enthalten)" "$enthaelt_bestimmbar103"

echo
echo "--- TMPDIR zeigt in den geprueften Baum (6.12.25 c, DT3-B1) -----------"
echo

# --- Z-109/110/111: eigene Wegwerfdatei ausserhalb, D19 bleibt sauber, kein
#     Beobachtungsfenster im Baum -------------------------------------------
baum=$(neuer_mock_baum)
# 6.12.25-Nachbelegung (Koordinator, Vorlauf-Selbsttest 2026-09-03): das
# Zielverzeichnis von TMPDIR darf selbst NICHT dem Muster "tmp.*" folgen --
# sonst zaehlt der Beobachter (der genau dieses Muster sucht) sein eigenes,
# vom Selbsttest angelegtes Verzeichnis mit und meldet einen Scheinbefund
# (112 Treffer bei der vorherigen Benennung ueber "mktemp -d -p"). Das
# Verzeichnis besteht ueber die gesamte Laufzeit des Falls, ist aber vom
# Selbsttest selbst angelegt, nicht vom Gate oder der Kette -- es gehoert
# nicht zur Beobachtungsflaeche.
tmp_im_baum="$baum/tmpdir-im-baum"
mkdir -p "$tmp_im_baum"
m1=$(marken_zeile K1 D20 belege A_OK "" "" 0)
ausgabe=$(bauen_ausgabe "$baum" "$m1" "$D19_OK" "make dod: alle 1 Kettenschritte durchlaufen, keiner ungleich 0, 1 gueltige Marken gezaehlt.")
zustand_tmp=$(neu_verzeichnis)
spur_tmp=$(neu_verzeichnis)/spur
eingabe_tmp=$(baue_eingabe "Stop" "$baum" "fall-tmp-in-baum")
beobachter_stopp=$(neu_verzeichnis)/stopp
beobachter_treffer=$(neu_verzeichnis)/treffer
: > "$beobachter_treffer"
# 6.12.25 h (Befund DT4-01): der Beobachter beobachtet den GANZEN gepruef-
# ten Baum (alle Verzeichnisse ausser .git), nicht nur das Verzeichnis, auf
# das TMPDIR zeigt -- die Zusicherung Z-111 nennt "im Baum", nicht "im
# TMPDIR-Verzeichnis".
(
  while [ ! -e "$beobachter_stopp" ]; do
    find "$baum" -mindepth 1 -path "$baum/.git" -prune -o -name 'tmp.*' -print 2>/dev/null >> "$beobachter_treffer"
  done
) &
beobachter_pid=$!
rufe_gate "$eingabe_tmp" "$zustand_tmp" "$WERKZEUGKASTEN_VOLL" "CLAUDE_PROJECT_DIR=$baum" "MOCK_AUSGABE=$ausgabe" "MOCK_RC=0" "TMPDIR=$tmp_im_baum" "MOCK_TMP_SPUR=$spur_tmp"
: > "$beobachter_stopp"
wait "$beobachter_pid" 2>/dev/null
treffer_anzahl=$(wc -l < "$beobachter_treffer" | tr -d ' ')
kette_eigene_tmp=$(cat "$spur_tmp" 2>/dev/null || true)
ausserhalb109=0
case "$kette_eigene_tmp" in
  "$baum"|"$baum"/*) ausserhalb109=0 ;;
  *) [ -n "$kette_eigene_tmp" ] && ausserhalb109=1 ;;
esac
pruefe_wahr Z-109 "TMPDIR zeigt in den geprueften Baum" \
  "der physisch aufgeloeste Pfad der Wegwerfdatei liegt ausserhalb des geprueften Baums" \
  "$ausserhalb109" "ausserhalb von $baum" "kette_eigene_tmp=$kette_eigene_tmp"
# Z-110 ist am 2026-09-03 zurueckgezogen (6.12.25 h, Befund S4-02): im
# Attrappenaufbau ist "D19 meldet OHNE_BEFUND" nicht messbar, weil die
# D19-Zeile aus der vom Selbsttest selbst geschriebenen Attrappenausgabe
# stammt -- gemessen wuerde die eigene Vorgabe. Keine Pruefung mehr; die
# Deckungspruefung nimmt die Kennung als zurueckgezogen aus.
pruefe_wahr Z-111 "TMPDIR zeigt in den geprueften Baum" \
  "ein Beobachter ohne Wartezeit findet waehrend des gesamten Laufs im ganzen geprueften Baum (alle Verzeichnisse ausser .git) keine Datei mit dem Muster tmp.*" \
  "$([ "$treffer_anzahl" = "0" ] && echo 1 || echo 0)" "0 Treffer" "$treffer_anzahl Treffer"

echo
echo "--- Wegwerfdatei ausserhalb des Baums nicht anlegbar (Entscheid f) -----"
echo

# --- Z-112/113: erster mktemp-Aufruf im Baum, "-p /tmp" schlaegt fehl -----
baum=$(neuer_mock_baum)
m1=$(marken_zeile K1 D20 belege A_OK "" "" 0)
ausgabe=$(bauen_ausgabe "$baum" "$m1" "$D19_OK" "make dod: alle 1 Kettenschritte durchlaufen, keiner ungleich 0, 1 gueltige Marken gezaehlt.")
zustand_mktemp=$(neu_verzeichnis)
eingabe_mktemp=$(baue_eingabe "Stop" "$baum" "fall-mktemp-gate")
rufe_gate "$eingabe_mktemp" "$zustand_mktemp" "$WERKZEUGKASTEN_FAKE_MKTEMP" "CLAUDE_PROJECT_DIR=$baum" "MOCK_AUSGABE=$ausgabe" "MOCK_RC=0" "FAKE_MKTEMP_ZIEL=$baum"
pruefe_rc Z-112 "Wegwerfdatei ausserhalb des Baums nicht anlegbar" 2
pruefe_zaehler_schluessel Z-113 "Wegwerfdatei ausserhalb des Baums nicht anlegbar" \
  "$(zaehler_pfad "$zustand_mktemp" "fall-mktemp-gate")" "GATE mktemp"

echo
echo "--- Verzeichnis der Wegwerfdatei physisch nicht aufloesbar (6.12.25 d) -"
echo

# --- Z-114/115 (Runde 3, S3-05) --------------------------------------------
baum=$(neuer_mock_baum)
m1=$(marken_zeile K1 D20 belege A_OK "" "" 0)
ausgabe_s305=$(bauen_ausgabe "$baum" "$m1" "$D19_OK" "make dod: alle 1 Kettenschritte durchlaufen, keiner ungleich 0, 1 gueltige Marken gezaehlt.")
zustand_s305=$(neu_verzeichnis)
eingabe_s305=$(baue_eingabe "Stop" "$baum" "fall-s3-05")
rufe_gate "$eingabe_s305" "$zustand_s305" "$WERKZEUGKASTEN_FAKE_MKTEMP_UNAUFLOESBAR" "CLAUDE_PROJECT_DIR=$baum" "MOCK_AUSGABE=$ausgabe_s305" "MOCK_RC=0"
pruefe_rc Z-114 "Das Verzeichnis der Wegwerfdatei ist physisch nicht aufloesbar" 2
pruefe_zaehler_schluessel Z-115 "Das Verzeichnis der Wegwerfdatei ist physisch nicht aufloesbar" \
  "$(zaehler_pfad "$zustand_s305" "fall-s3-05")" "GATE mktemp"

echo
echo "--- Liste mit drei Verletzungen (2, 4, 6) in verschiedenen Zeilen -----"
echo

# --- Z-122/123/124 (Entscheid h) --------------------------------------------
baum=$(neuer_mock_baum)
mkdir -p "$baum/scripts"
: > "$baum/scripts/abnahme-abgleich.sh"
git -C "$baum" add -A
git -C "$baum" commit -q -m "artefakt entstanden"
printf 'D7 abnahme|scripts/abnahme-abgleich.sh\tADR 0002, 6.12.5, Selbsttest.\nD9 rueckkanal|scripts/rueckkanal-pruefen.sh\tGrund ohne die Wendung.\nD11 geheimnisse|gitleaks\tADR 0002, 6.12.5, Selbsttest.\n' \
  > "$baum/.claude/hooks/dod-gate-terminierte-lagen.txt"
marker_liste=$(neu_verzeichnis)/marker
zustand_liste=$(neu_verzeichnis)
eingabe_liste=$(baue_eingabe "Stop" "$baum" "fall-liste-drei")
rufe_gate "$eingabe_liste" "$zustand_liste" "$WERKZEUGKASTEN_VOLL" "CLAUDE_PROJECT_DIR=$baum" "MOCK_AUSGABE=darf nie gelesen werden" "MOCK_RC=0" "MOCK_MARKER=$marker_liste"
pruefe_rc Z-122 "Liste mit je einer Verletzung der Selbstpruefungen 2, 4 und 6 in verschiedenen Zeilen" 2
pruefe_wahr Z-123 "Liste mit je einer Verletzung der Selbstpruefungen 2, 4 und 6" \
  "die Attrappe von make dod verzeichnet keinen Aufruf -- geblockt wird vor dem Lauf der Kette" \
  "$([ ! -e "$marker_liste" ] && echo 1 || echo 0)" \
  "keine Markerdatei" "$([ -e "$marker_liste" ] && echo "Markerdatei besteht" || echo "keine Markerdatei")"
pruefe_stderr_enthaelt Z-124 "Liste mit je einer Verletzung der Selbstpruefungen 2, 4 und 6" \
  "der gezaehlte Schluessel stammt aus der Zeile mit der kleinsten Zeilennummer" "Schluessel: LISTE 2 D7 abnahme"

echo
echo "--- D12 mit mehreren fehlenden Gegenstaenden (N-08) ---------------------"
echo

# --- Z-130: git vorhanden, BEIDE D12-Skripte fehlen -> erster Gegenstand --
scheinbaum_n08=$(neu_verzeichnis)
git -C "$scheinbaum_n08" init -q
git -C "$scheinbaum_n08" config user.email "selbsttest@example.invalid"
git -C "$scheinbaum_n08" config user.name "Selbsttest"
cp "$ECHTES_MAKEFILE" "$scheinbaum_n08/Makefile"
git -C "$scheinbaum_n08" add -A
git -C "$scheinbaum_n08" commit -q -m init
ausgabe_n08=$(make -s -C "$scheinbaum_n08" nachweise 2>&1)
fehlt_gelesen_n08=$(printf '%s' "$ausgabe_n08" | grep -oE 'FEHLT=[^ :]+' | head -1)
pruefe_wahr Z-130 "D12 in Lage C mit mehreren fehlenden Gegenstaenden" \
  "der gelesene FEHLT=-Wert ist der erste Gegenstand (scripts/nachweise-erzeugen.sh vor scripts/nachweise-vollstaendig.sh)" \
  "$([ "$fehlt_gelesen_n08" = "FEHLT=scripts/nachweise-erzeugen.sh" ] && echo 1 || echo 0)" \
  "FEHLT=scripts/nachweise-erzeugen.sh" "$fehlt_gelesen_n08"

echo
echo "--- Kette ruft selbst mktemp auf: eigene Wegwerfdatei ausserhalb (DT2-B2)"
echo

# --- Z-131/132 ---------------------------------------------------------------
baum=$(neuer_mock_baum)
m1=$(marken_zeile K1 D20 belege A_OK "" "" 0)
ausgabe=$(bauen_ausgabe "$baum" "$m1" "$D19_OK" "make dod: alle 1 Kettenschritte durchlaufen, keiner ungleich 0, 1 gueltige Marken gezaehlt.")
zustand_dtb2=$(neu_verzeichnis)
spur_dtb2=$(neu_verzeichnis)/spur
eingabe_dtb2=$(baue_eingabe "Stop" "$baum" "fall-dtb2")
vorher_dtb2=$(find "$baum" -mindepth 1 2>/dev/null | sort)
rufe_gate "$eingabe_dtb2" "$zustand_dtb2" "$WERKZEUGKASTEN_VOLL" "CLAUDE_PROJECT_DIR=$baum" "MOCK_AUSGABE=$ausgabe" "MOCK_RC=0" "MOCK_TMP_SPUR=$spur_dtb2" "TMPDIR=$baum"
nachher_dtb2=$(find "$baum" -mindepth 1 2>/dev/null | sort)
neue_dateien_dtb2=$(comm -13 <(printf '%s\n' "$vorher_dtb2") <(printf '%s\n' "$nachher_dtb2") | wc -l | tr -d ' ')
kette_eigene_tmp_dtb2=$(cat "$spur_dtb2" 2>/dev/null || true)
tmpdir_uebergeben_ausserhalb=0
case "$kette_eigene_tmp_dtb2" in
  "$baum"|"$baum"/*) tmpdir_uebergeben_ausserhalb=0 ;;
  *) [ -n "$kette_eigene_tmp_dtb2" ] && tmpdir_uebergeben_ausserhalb=1 ;;
esac
pruefe_wahr Z-131 "TMPDIR in den Baum, und die Kette selbst legt eine Wegwerfdatei an" \
  "das an make dod uebergebene TMPDIR liegt ausserhalb des geprueften Baums" \
  "$tmpdir_uebergeben_ausserhalb" "ausserhalb von $baum" "kette_eigene_tmp=$kette_eigene_tmp_dtb2"
pruefe_wahr Z-132 "TMPDIR in den Baum, Kette legt selbst an" \
  "waehrend des Laufs entsteht im Baum keine Datei, auch keine unversionierte" \
  "$([ "$neue_dateien_dtb2" = "0" ] && echo 1 || echo 0)" "0 neue Dateien" "$neue_dateien_dtb2 neue Dateien"

echo
echo "--- Markenzahl gegen die Schlusszeile selbst (S-11, 6.12.24 k; S3-02) -"
echo

# --- Z-133/134: Form 1 behauptet 14 Marken, die Uebersicht traegt KEINE ---
baum=$(neuer_mock_baum)
ausgabe_s11a=$(printf 'make dod: geprueft wird %s.\n=== Uebersicht Definition-of-Done-Kette (make dod) ===\n\nmake dod: D19: %s\nmake dod: alle 14 Kettenschritte durchlaufen, keiner ungleich 0, 14 gueltige Marken gezaehlt.\n' "$baum" "$D19_OK")
lauf "$baum" Stop "fall-s11a" "$ausgabe_s11a" 0
pruefe_rc Z-133 "Baumzeile, Form-1-Schlusszeile, D19 OHNE_BEFUND, Rueckgabewert 0 und null Marken" 2
pruefe_stderr_enthaelt Z-134 "Form-1-Schlusszeile mit null Marken" \
  "der Schluessel ist KETTE ausgabe-unlesbar" "Schluessel: KETTE ausgabe-unlesbar"

# --- Z-135/136: Form 1 behauptet 3 Marken, die Uebersicht traegt nur EINE -
baum=$(neuer_mock_baum)
m1=$(marken_zeile K1 D20 belege A_OK "" "" 0)
ausgabe_s11b=$(bauen_ausgabe "$baum" "$m1" "$D19_OK" "make dod: alle 3 Kettenschritte durchlaufen, keiner ungleich 0, 3 gueltige Marken gezaehlt.")
lauf "$baum" Stop "fall-s11b" "$ausgabe_s11b" 0
pruefe_rc Z-135 "Schlusszeile Form 1 nennt eine andere Zahl, als Marken gelesen wurden" 2
pruefe_stderr_enthaelt Z-136 "Schlusszeile Form 1 mit abweichender Zahl" \
  "der Schluessel ist KETTE ausgabe-unlesbar" "Schluessel: KETTE ausgabe-unlesbar"

# --- Z-137/138: Form 2 (teilweise, mit gedeckter Lage C) abweichende Zahl -
baum=$(neuer_mock_baum)
printf 'D7 abnahme|scripts/abnahme-abgleich.sh\tADR 0002, 6.12.5, Selbsttest.\n' > "$baum/.claude/hooks/dod-gate-terminierte-lagen.txt"
m1=$(marken_zeile K1 D20 belege A_OK "" "" 0)
m2=$(marken_zeile K1 D7 abnahme C scripts/abnahme-abgleich.sh "" 2)
ausgabe_f2=$(bauen_ausgabe "$baum" "$m1
$m2" "$D19_OK" "make dod: alle 5 Kettenschritte durchlaufen, 1 davon ohne Urteil (Lage C): D7 abnahme FEHLT=scripts/abnahme-abgleich.sh, Rueckgabewert 2.")
lauf "$baum" Stop "fall-f2-abweichend" "$ausgabe_f2" 2
pruefe_rc Z-137 "Schlusszeile Form 2 nennt eine andere Zahl, als Marken gelesen wurden" 2
pruefe_stderr_enthaelt Z-138 "Schlusszeile Form 2 mit abweichender Zahl" \
  "der Schluessel ist KETTE ausgabe-unlesbar" "Schluessel: KETTE ausgabe-unlesbar"

# --- Z-139/140: Form 4 (D19 VERLETZT/C) abweichende Zahl -------------------
baum=$(neuer_mock_baum)
m1=$(marken_zeile K1 D20 belege A_OK "" "" 0)
ausgabe_f4=$(bauen_ausgabe "$baum" "$m1" "VERLETZT -- versionierter Bestand veraendert." "make dod: alle 5 Kettenschritte durchlaufen, Rahmenpruefung D19 VERLETZT, Rueckgabewert 2.")
lauf "$baum" Stop "fall-f4-abweichend" "$ausgabe_f4" 2
pruefe_rc Z-139 "Schlusszeile Form 4 nennt eine andere Zahl, als Marken gelesen wurden" 2
pruefe_stderr_enthaelt Z-140 "Schlusszeile Form 4 mit abweichender Zahl" \
  "der Schluessel ist KETTE ausgabe-unlesbar" "Schluessel: KETTE ausgabe-unlesbar"

# --- Z-141: Form 3 (Abbruch) -- wird NICHT auf die Zahl geprueft ----------
baum=$(neuer_mock_baum)
m1=$(marken_zeile K1 D20 belege A_OK "" "" 0)
m2=$(marken_zeile K1 D3 linter A_FAIL "" "" 2)
ausgabe_f3=$(bauen_ausgabe "$baum" "$m1
$m2" "$D19_OK" "make dod: abgebrochen bei D3 linter, Rueckgabewert 2.")
lauf "$baum" Stop "fall-f3-abweichend" "$ausgabe_f3" 2
gefunden141=0
printf '%s' "$G_STDERR" | grep -qF "Schluessel: D3 linter A_FAIL" && gefunden141=1
nicht_unlesbar141=1
printf '%s' "$G_STDERR" | grep -qF "Schluessel: KETTE ausgabe-unlesbar" && nicht_unlesbar141=0
pruefe_wahr Z-141 "Schlusszeile Form 3 (abgebrochen) mit abweichender Zahl" \
  "der gezaehlte Schluessel ist der Befund der Kette (D3 linter A_FAIL) und nicht KETTE ausgabe-unlesbar -- Form 3 wird nicht auf die Zahl geprueft" \
  "$([ "$gefunden141" -eq 1 ] && [ "$nicht_unlesbar141" -eq 1 ] && echo 1 || echo 0)" \
  "Schluessel: D3 linter A_FAIL, kein ausgabe-unlesbar" "gefunden=$gefunden141, nicht_unlesbar=$nicht_unlesbar141"

echo
echo "--- Wiederholtes GATE-Pruefmittel in derselben Sitzung (6.12.25 i) ----"
echo

# --- Z-146/147/148: das Verzeichnis der Wegwerfdatei ist physisch nicht
#     aufloesbar (Attrappe wie bei Z-114/115), zweimal in derselben Sitzung
#     -- der Schluessel "GATE mktemp" laeuft ueber dieselbe Zaehlung nach
#     6.12.9 wie jeder andere Block (6.12.25 i). Zaehlerdatei direkt lesen:
#     erste Zeile = Schluessel, zweite Zeile = Stand (siehe pruefe_zaehler*
#     oben). --------------------------------------------------------------
baum=$(neuer_mock_baum)
zustand_gm=$(neu_verzeichnis)
m1=$(marken_zeile K1 D20 belege A_OK "" "" 0)
ausgabe_gm=$(bauen_ausgabe "$baum" "$m1" "$D19_OK" "make dod: alle 1 Kettenschritte durchlaufen, keiner ungleich 0, 1 gueltige Marken gezaehlt.")
eingabe_gm=$(baue_eingabe "Stop" "$baum" "fall-gate-mktemp")
zaehler_datei_gm="$zustand_gm/r3cosint/dod-gate/zaehler-$(printf '%s' 'fall-gate-mktemp' | sha256sum | cut -d' ' -f1)"

rufe_gate "$eingabe_gm" "$zustand_gm" "$WERKZEUGKASTEN_FAKE_MKTEMP_UNAUFLOESBAR" "CLAUDE_PROJECT_DIR=$baum" "MOCK_AUSGABE=$ausgabe_gm" "MOCK_RC=0"
pruefe_stderr_enthaelt Z-146 "Verzeichnis der Wegwerfdatei physisch nicht aufloesbar, erstes Ereignis" \
  "die Fehlerausgabe nennt den Schluessel GATE mktemp" "GATE mktemp"
schluessel_gm1=$(sed -n '1p' "$zaehler_datei_gm" 2>/dev/null || true)
stand_gm1=$(sed -n '2p' "$zaehler_datei_gm" 2>/dev/null || true)
pruefe_wahr Z-147 "Verzeichnis der Wegwerfdatei physisch nicht aufloesbar, erstes Ereignis" \
  "die Zaehlerdatei traegt Schluessel GATE mktemp und Stand 1" \
  "$([ "$schluessel_gm1" = "GATE mktemp" ] && [ "$stand_gm1" = "1" ] && echo 1 || echo 0)" \
  "GATE mktemp|1" "$schluessel_gm1|$stand_gm1"

rufe_gate "$eingabe_gm" "$zustand_gm" "$WERKZEUGKASTEN_FAKE_MKTEMP_UNAUFLOESBAR" "CLAUDE_PROJECT_DIR=$baum" "MOCK_AUSGABE=$ausgabe_gm" "MOCK_RC=0"
schluessel_gm2=$(sed -n '1p' "$zaehler_datei_gm" 2>/dev/null || true)
stand_gm2=$(sed -n '2p' "$zaehler_datei_gm" 2>/dev/null || true)
pruefe_wahr Z-148 "Dasselbe Ausbleiben ein zweites Mal in derselben Sitzung" \
  "die Zaehlerdatei traegt Schluessel GATE mktemp und Stand 2" \
  "$([ "$schluessel_gm2" = "GATE mktemp" ] && [ "$stand_gm2" = "2" ] && echo 1 || echo 0)" \
  "GATE mktemp|2" "$schluessel_gm2|$stand_gm2"

# --- Z-149/150/151: fehlendes sha256sum, zweimal in derselben Sitzung -----
# dod-gate.sh (Zeilen ~193-214, Kommentar "N-09"): fehlt sha256sum, kann der
# uebliche gehashte Zaehler-Schluessel nicht gebildet werden -- die
# Zaehlerdatei traegt ersatzweise eine SANITIERTE Rohform von session_id
# (tr -c 'A-Za-z0-9_-' '_'), NICHT den Hash. "fall-gate-sha256sum" enthaelt
# nur bereits zulaessige Zeichen, die Sanitierung ist deshalb die Identitaet.
WERKZEUGKASTEN_OHNE_SHA256SUM_GS=$(neu_verzeichnis)
baue_werkzeugkasten "$WERKZEUGKASTEN_OHNE_SHA256SUM_GS" sha256sum
zustand_gs=$(neu_verzeichnis)
eingabe_gs=$(baue_eingabe "Stop" "$baum" "fall-gate-sha256sum")
zaehler_datei_gs="$zustand_gs/r3cosint/dod-gate/zaehler-fall-gate-sha256sum"

rufe_gate "$eingabe_gs" "$zustand_gs" "$WERKZEUGKASTEN_OHNE_SHA256SUM_GS" "CLAUDE_PROJECT_DIR=$baum" "MOCK_AUSGABE=x" "MOCK_RC=0"
pruefe_stderr_enthaelt Z-149 "Fehlendes sha256sum, erstes Ereignis" \
  "die Fehlerausgabe nennt den Schluessel GATE sha256sum" "GATE sha256sum"
schluessel_gs1=$(sed -n '1p' "$zaehler_datei_gs" 2>/dev/null || true)
stand_gs1=$(sed -n '2p' "$zaehler_datei_gs" 2>/dev/null || true)
pruefe_wahr Z-150 "Fehlendes sha256sum, erstes Ereignis" \
  "die Zaehlerdatei traegt Schluessel GATE sha256sum und Stand 1" \
  "$([ "$schluessel_gs1" = "GATE sha256sum" ] && [ "$stand_gs1" = "1" ] && echo 1 || echo 0)" \
  "GATE sha256sum|1" "$schluessel_gs1|$stand_gs1"

rufe_gate "$eingabe_gs" "$zustand_gs" "$WERKZEUGKASTEN_OHNE_SHA256SUM_GS" "CLAUDE_PROJECT_DIR=$baum" "MOCK_AUSGABE=x" "MOCK_RC=0"
schluessel_gs2=$(sed -n '1p' "$zaehler_datei_gs" 2>/dev/null || true)
stand_gs2=$(sed -n '2p' "$zaehler_datei_gs" 2>/dev/null || true)
pruefe_wahr Z-151 "Fehlendes sha256sum, zweites Ereignis in derselben Sitzung" \
  "die Zaehlerdatei traegt Schluessel GATE sha256sum und Stand 2" \
  "$([ "$schluessel_gs2" = "GATE sha256sum" ] && [ "$stand_gs2" = "2" ] && echo 1 || echo 0)" \
  "GATE sha256sum|2" "$schluessel_gs2|$stand_gs2"

echo
echo "--- Zweiter Selbsttest waehrend gehaltener Sperre (6.12.25 j) ---------"
echo

# --- Z-152/153: dieses Skript haelt seine Sperre (SELBSTTEST_SPERRE_FD,
#     flock -n, exklusiv) seit dem eigenen Skriptbeginn und fuer die
#     GESAMTE Laufzeit -- ein Unterprozess, der denselben Selbsttest ein
#     zweites Mal aufruft, kann die Sperre also nicht erwerben und muss
#     sofort (rc 3, stderr) enden. -----------------------------------------
zeit_start152=$(date +%s%N)
zweiter_stdout152=$(mktemp)
zweiter_stderr152=$(mktemp)
timeout 10 "$BASH_BIN" "$SKRIPT_VERZEICHNIS/dod-gate-selbsttest.sh" >"$zweiter_stdout152" 2>"$zweiter_stderr152"
zweiter_rc152=$?
zeit_ende152=$(date +%s%N)
dauer_ms152=$(( (zeit_ende152 - zeit_start152) / 1000000 ))
pruefe_wahr Z-152 "Zweiter Selbsttest, gestartet waehrend der erste die Sperre haelt" \
  "der zweite Aufruf endet innerhalb von 5 s mit Rueckgabewert 3" \
  "$([ "$zweiter_rc152" = "3" ] && [ "$dauer_ms152" -lt 5000 ] && echo 1 || echo 0)" \
  "rc=3, Dauer < 5000 ms" "rc=$zweiter_rc152, Dauer=${dauer_ms152}ms"
zweiter_stderr_inhalt152=$(cat "$zweiter_stderr152" 2>/dev/null || true)
gefunden153=0
printf '%s' "$zweiter_stderr_inhalt152" | grep -qF "Selbsttest laeuft bereits" && gefunden153=1
pruefe_wahr Z-153 "Zweiter Selbsttest, gestartet waehrend der erste die Sperre haelt" \
  "die Fehlerausgabe des zweiten Aufrufs traegt die Zeile 'Selbsttest laeuft bereits'" \
  "$gefunden153" "Selbsttest laeuft bereits" "$(printf '%s' "$zweiter_stderr_inhalt152" | head -c 200)"
rm -f "$zweiter_stdout152" "$zweiter_stderr152"

echo
echo "=== Zusammenfassung ==="
if [ "${#fehlgeschlagene_faelle[@]}" -gt 0 ]; then
  echo "Fehlgeschlagene Faelle:"
  for f in "${fehlgeschlagene_faelle[@]}"; do
    echo "  - $f"
  done
fi
echo "Selbsttest: $bestanden von $gesamt Zusicherungen bestanden"

# -----------------------------------------------------------------------------
# Deckung (ADR 0002, 6.12.25 a): Kennungen aus der Tabelle 6.12.19 dieser
# ADR-Datei (Zeilen, die mit "| Z-" beginnen) gegen die tatsaechlich
# gemeldeten Kennungen, in BEIDE Richtungen. Zurueckgezogene Kennungen
# (Wortlaut "zurueckgezogen" in der Zeile) sind ausgenommen und werden
# aufgezaehlt. Der Pfad zur ADR-Datei wird REPO-RELATIV bestimmt, nicht ueber
# einen absoluten Pfad der Arbeitsumgebung (das Skript liegt unter scripts/).
# -----------------------------------------------------------------------------
adr_pfad="$REPO_WURZEL/docs/adr/0002-architekturentscheid-ziel-stack.md"
echo
echo "=== Deckung gegen Tabelle 6.12.19 ($adr_pfad) ==="

tabellen_kennungen=()
zurueckgezogene_kennungen=()
if [ -f "$adr_pfad" ]; then
  while IFS= read -r zeile; do
    kennung=$(printf '%s' "$zeile" | sed -n 's/^| \(Z-[0-9][0-9]*\).*/\1/p')
    [ -n "$kennung" ] || continue
    case "$zeile" in
      *zurueckgezogen*|*zurückgezogen*)
        zurueckgezogene_kennungen+=("$kennung")
        ;;
      *)
        tabellen_kennungen+=("$kennung")
        ;;
    esac
  done < <(grep '^| Z-' "$adr_pfad")
else
  echo "FEHLER  ADR-Datei nicht gefunden: $adr_pfad"
fi

# Duplikate innerhalb der Tabelle selbst waeren ein Befund am ADR, nicht am
# Selbsttest -- hier nur gegen die vom Selbsttest gemeldeten Kennungen
# geprueft (Auftrag, Punkt 2: "doppelt gemeldete Kennungen sind ebenfalls
# ein Fehler").
deckung_fehler=0

ohne_pruefung=()
for k in "${tabellen_kennungen[@]}"; do
  gefunden=0
  for g in "${GEMELDETE_KENNUNGEN[@]:-}"; do
    [ "$g" = "$k" ] && gefunden=1 && break
  done
  [ "$gefunden" -eq 1 ] || ohne_pruefung+=("$k")
done

ohne_kennung=()
for g in "${GEMELDETE_KENNUNGEN[@]:-}"; do
  [ -n "$g" ] || continue
  gefunden=0
  for k in "${tabellen_kennungen[@]}"; do
    [ "$g" = "$k" ] && gefunden=1 && break
  done
  [ "$gefunden" -eq 1 ] || ohne_kennung+=("$g")
done

doppelt_gemeldet=()
if [ "${#GEMELDETE_KENNUNGEN[@]}" -gt 0 ]; then
  while IFS= read -r k; do
    [ -n "$k" ] && doppelt_gemeldet+=("$k")
  done < <(printf '%s\n' "${GEMELDETE_KENNUNGEN[@]}" | sort | uniq -d)
fi

if [ "${#zurueckgezogene_kennungen[@]}" -gt 0 ]; then
  echo "Zurueckgezogene Kennungen (von der Deckung ausgenommen): ${zurueckgezogene_kennungen[*]}"
fi

if [ "${#ohne_pruefung[@]}" -gt 0 ]; then
  deckung_fehler=1
  echo "Kennungen der Tabelle OHNE Pruefung: ${ohne_pruefung[*]}"
fi
if [ "${#ohne_kennung[@]}" -gt 0 ]; then
  deckung_fehler=1
  echo "Gemeldete Pruefungen mit einer Kennung, die NICHT in der Tabelle steht: ${ohne_kennung[*]}"
fi
if [ "${#doppelt_gemeldet[@]}" -gt 0 ]; then
  deckung_fehler=1
  echo "Doppelt gemeldete Kennungen: ${doppelt_gemeldet[*]}"
fi

echo "Deckung: ${#tabellen_kennungen[@]} Kennungen in der Tabelle, $((${#tabellen_kennungen[@]} - ${#ohne_pruefung[@]})) geprueft, ${#ohne_pruefung[@]} ohne Pruefung, ${#ohne_kennung[@]} ohne Kennung"

if [ "$bestanden" -eq "$gesamt" ] && [ "$deckung_fehler" -eq 0 ] && [ -f "$adr_pfad" ]; then
  exit 0
else
  exit 2
fi
