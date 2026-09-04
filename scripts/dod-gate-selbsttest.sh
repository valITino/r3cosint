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
# 6.12.26 b (Mutationsmodus): ueberschreibbar, damit ein isolierter
# Fall-Wiederholungslauf gegen eine MUTIERTE KOPIE laufen kann, ohne den
# Pruefgegenstand selbst zu veraendern. Ohne die Umgebungsvariablen bleibt
# das Verhalten gegenueber dem Normalmodus unveraendert.
# ::VORSPANN-START::
GATE="${GATE_UEBERSCHREIBUNG:-$REPO_WURZEL/.claude/hooks/dod-gate.sh}"
ECHTES_MAKEFILE="${MAKEFILE_UEBERSCHREIBUNG:-$REPO_WURZEL/Makefile}"
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
declare -A KANAL_GEMELDET=()

# -----------------------------------------------------------------------------
# 6.12.26 (Entscheid des Auftraggebers zu O-25): abschliessender Wertevorrat
# fuer den Kanal, den jede Zusicherung tatsaechlich misst. Kombinationen wie
# "stdout+stderr" oder "selbsttest+dauer" sind zulaessig, wenn die Tabelle sie
# so fuehrt (Z-129, Z-152) -- der Vorrat bindet die EINZELWERTE, nicht jede
# Kombination einzeln.
# -----------------------------------------------------------------------------
KANAL_VORRAT="rc stdout stderr zaehler datei beobachter kette selbsttest dauer"
kanal_gueltig() {
local kanal="$1" teil
IFS='+' read -ra _kt <<< "$kanal"
for teil in "${_kt[@]}"; do
  case " $KANAL_VORRAT " in
    *" $teil "*) ;;
    *) return 1 ;;
  esac
done
return 0
}

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
.PHONY: dod dod-baum-direkt
dod:
	sleep "$${MOCK_SLEEP:-0}"
	[ -z "$${MOCK_MARKER:-}" ] || : > "$$MOCK_MARKER"
	[ -z "$${MOCK_AUFRUFPROTOKOLL:-}" ] || printf 'TMPDIR=%s\n' "$${TMPDIR:-}" > "$$MOCK_AUFRUFPROTOKOLL"
	if [ -n "$${MOCK_TMP_SPUR:-}" ]; then t=$$(mktemp); printf '%s' "$$t" > "$$MOCK_TMP_SPUR"; sleep 0.3; rm -f "$$t"; fi
	printf '%s\n' "$$MOCK_AUSGABE"
	exit "$${MOCK_RC:-0}"
# dod-baum-direkt (Item 1, Runde 6): eigenes Attrappenziel, das die physisch
# aufgeloeste Wurzel NICHT aus MOCK_AUSGABE uebernimmt, sondern aus dem
# eigenen $(CURDIR) von make selbst -- make loest "-C <verzeichnis>" beim
# Wechsel physisch auf (chdir + erneutes getcwd). Ein Aufruf gegen dieses
# Ziel prueft deshalb unabhaengig von injiziertem Text, welchen Baum der
# direkte Aufruf tatsaechlich erreicht hat.
dod-baum-direkt:
	@echo "make dod: geprueft wird $(CURDIR)."
MAKEEOF
# MOCK_MARKER (S-06): wird nur angelegt, wenn das Rezept TATSAECHLICH
# laeuft -- ein Fall, der beweisen soll, dass die Kette VOR dem Lauf
# blockiert wurde, prueft die Abwesenheit dieser Datei.
# MOCK_TMP_SPUR (DT2-B2): die Attrappe ruft SELBST "mktemp" auf (wie die
# echte Kette es in D6/D12 tut) und schreibt den dabei entstandenen Pfad in
# die genannte Datei -- so laesst sich pruefen, WELCHES Verzeichnis die
# Kette als TMPDIR sah, ohne die eigene Standardausgabe des Gates zu
# missbrauchen (6.12.15 verbietet, die Kettenausgabe dort erscheinen zu
# lassen). Item 6 (Runde 6, DT5-01): die Attrappe haelt die Wegwerfdatei
# mindestens 300 ms (sleep 0.3 zwischen mktemp und rm), damit ein Beobachter
# ohne eigene Wartezeit ein Beobachtungsfenster hat -- ohne diese Haltezeit
# entstand und verschwand die Datei zu schnell, um zuverlaessig erkannt zu
# werden (in 1 von 3 Mutationsdurchgaengen verpasst).
# MOCK_AUFRUFPROTOKOLL (ADR 0002, 6.12.26 f, Entscheid 5): das AUFRUFPROTOKOLL
# haelt fest, was die Kette selbst an TMPDIR ERHALTEN hat (aus der Umgebung
# des Rezepts geschrieben) -- zu unterscheiden von der SPUR (MOCK_TMP_SPUR
# oben), die festhaelt, was die Kette aus diesem TMPDIR SELBST GEMACHT hat
# (Pfad ihrer eigenen mktemp-Datei). Beide Dateien liegen ausserhalb des
# geprueften Baums (neu_verzeichnis), damit ihre Existenz den D19-Vergleich
# der versionierten Dateien nicht verletzt.
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
# $1=Kennung $2=Kanal $3=Fall $4=Zusicherung $5=ok(0/1) $6=erwartet $7=erhalten
local kennung="$1" kanal="$2" fall="$3" zusicherung="$4" ok="$5" erwartet="$6" erhalten="$7"
gesamt=$((gesamt + 1))
GEMELDETE_KENNUNGEN+=("$kennung")
if ! kanal_gueltig "$kanal"; then
  echo "FEHLER  $kennung: unbekannter Kanal '$kanal' (Vorrat: $KANAL_VORRAT)" >&2
  kanal="$kanal(UNGUELTIG)"
fi
KANAL_GEMELDET["$kennung"]="$kanal"
if [ "$ok" -eq 1 ]; then
  bestanden=$((bestanden + 1))
  printf 'BESTANDEN %s [%s] %s: %s\n' "$kennung" "$kanal" "$fall" "$zusicherung"
else
  fehlgeschlagene_faelle+=("$kennung $fall: $zusicherung")
  printf 'FEHLGESCHLAGEN %s [%s] %s: %s: erwartet %s, erhalten %s\n' \
    "$kennung" "$kanal" "$fall" "$zusicherung" "$erwartet" "$erhalten"
fi
}

# pruefe_rc <kennung> <fall> <erwarteter_rc> -- misst den TATSAECHLICHEN
# Rueckgabewert des zuletzt ausgefuehrten rufe_gate/lauf-Aufrufs. Kanal: rc.
pruefe_rc() {
local kennung="$1" fall="$2" erwartet_rc="$3"
local ok=0
[ "$G_RC" = "$erwartet_rc" ] && ok=1
_melde "$kennung" "rc" "$fall" "Rueckgabewert $erwartet_rc" "$ok" "rc=$erwartet_rc" "rc=$G_RC"
}

# pruefe_rc_wert <kennung> <fall> <zusicherung> <erwartet> <erhalten_wert> --
# wie pruefe_rc, aber fuer einen ausserhalb von G_RC gelesenen Rueckgabewert
# (z. B. eines direkten "make"-Aufrufs statt des Gates). Kanal: rc.
pruefe_rc_wert() {
local kennung="$1" fall="$2" zusicherung="$3" erwartet="$4" erhalten="$5"
local ok=0
[ "$erhalten" = "$erwartet" ] && ok=1
_melde "$kennung" "rc" "$fall" "$zusicherung" "$ok" "rc=$erwartet" "rc=$erhalten"
}

pruefe_stdout_leer() {
local kennung="$1" fall="$2"
local ok=0
[ -z "$G_STDOUT" ] && ok=1
_melde "$kennung" "stdout" "$fall" "Standardausgabe leer" "$ok" "leer" "'$(_kuerzen "$G_STDOUT")'"
}

pruefe_stderr_leer() {
local kennung="$1" fall="$2"
local ok=0
[ -z "$G_STDERR" ] && ok=1
_melde "$kennung" "stderr" "$fall" "Fehlerausgabe leer" "$ok" "leer" "'$(_kuerzen "$G_STDERR")'"
}

# pruefe_stdout_enthaelt/pruefe_stderr_enthaelt <kennung> <fall> <zusicherung>
# <text> -- grep -F (fester String, kein Muster) auf G_STDOUT/G_STDERR.
pruefe_stdout_enthaelt() {
local kennung="$1" fall="$2" zusicherung="$3" text="$4"
local ok=0
printf '%s' "$G_STDOUT" | grep -qF -- "$text" && ok=1
_melde "$kennung" "stdout" "$fall" "$zusicherung" "$ok" "stdout enthaelt '$text'" "stdout='$(_kuerzen "$G_STDOUT")'"
}

pruefe_stderr_enthaelt() {
local kennung="$1" fall="$2" zusicherung="$3" text="$4"
local ok=0
printf '%s' "$G_STDERR" | grep -qF -- "$text" && ok=1
_melde "$kennung" "stderr" "$fall" "$zusicherung" "$ok" "stderr enthaelt '$text'" "stderr='$(_kuerzen "$G_STDERR")'"
}

pruefe_stderr_fehlt() {
local kennung="$1" fall="$2" zusicherung="$3" text="$4"
local ok=0
printf '%s' "$G_STDERR" | grep -qF -- "$text" || ok=1
_melde "$kennung" "stderr" "$fall" "$zusicherung" "$ok" "stderr OHNE '$text'" "stderr='$(_kuerzen "$G_STDERR")'"
}

# pruefe_datei <kennung> <fall> <zusicherung> <pfad> <soll: existiert|fehlt>
pruefe_datei() {
local kennung="$1" fall="$2" zusicherung="$3" pfad="$4" soll="$5"
local ok=0 ist
if [ -f "$pfad" ]; then ist="existiert"; else ist="fehlt"; fi
[ "$ist" = "$soll" ] && ok=1
_melde "$kennung" "datei" "$fall" "$zusicherung" "$ok" "$pfad $soll" "$pfad $ist"
}

# pruefe_json_einzelfeld <kennung> <fall> <feld> -- G_STDOUT ist GENAU EIN
# JSON-Objekt mit GENAU diesem einen Feld (jq, nicht grep -- eine
# Strukturaussage ist keine Textaussage). Kanal: stdout.
pruefe_json_einzelfeld() {
local kennung="$1" fall="$2" feld="$3"
local ok=0
if printf '%s' "$G_STDOUT" | jq -e --arg f "$feld" \
     'type == "object" and (keys == [$f])' >/dev/null 2>&1; then
  ok=1
fi
_melde "$kennung" "stdout" "$fall" "Standardausgabe ist genau ein JSON-Objekt mit einzigem Feld $feld" \
  "$ok" "{\"$feld\": ...}" "stdout='$(_kuerzen "$G_STDOUT")'"
}

# pruefe_zaehler <kennung> <fall> <zaehlerdatei> <erwarteter_stand> -- liest
# die ZWEITE Zeile der Zaehlerdatei (der Zaehlerstand, siehe dod-gate.sh).
pruefe_zaehler() {
local kennung="$1" fall="$2" datei="$3" erwartet="$4"
local ok=0 erhalten
erhalten=$(sed -n '2p' "$datei" 2>/dev/null || true)
[ "$erhalten" = "$erwartet" ] && ok=1
_melde "$kennung" "zaehler" "$fall" "Zaehlerstand $erwartet" "$ok" "$erwartet" "'$erhalten' (Datei: $datei)"
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
_melde "$kennung" "zaehler" "$fall" "Zaehlerdatei traegt Schluessel $erwartet" "$ok" "$erwartet" "'$erhalten' (Datei: $datei)"
}

# zaehler_pfad <zustand> <fallkey> -- baut den Pfad der Zaehlerdatei aus dem
# Zustandsverzeichnis und dem Session-Schluessel (fallkey), genau wie
# dod-gate.sh ihn selbst bildet (sha256sum des session_id-Feldes).
zaehler_pfad() {
printf '%s/r3cosint/dod-gate/zaehler-%s' "$1" "$(printf '%s' "$2" | sha256sum | cut -d' ' -f1)"
}

# pruefe_wahr <kennung> <kanal> <fall> <zusicherung> <ok:0|1> <erwartet>
# <erhalten> -- fuer Faelle, die ihre eigene Bedingung (Datei-Existenz,
# Beobachterergebnis u. Ae.) bereits vorher gebildet haben. Seit 6.12.26 f
# (S7-05, Runde 7) nimmt sie NUR NOCH die Kanaele beobachter, dauer,
# selbsttest, datei an (einzeln oder als Kombination wie "selbsttest+dauer",
# Z-152) -- fuer rc/stdout/stderr/zaehler/kette gibt es je eine typisierte
# Huelle (pruefe_rc*, pruefe_stdout_*, pruefe_stderr_*, pruefe_zaehler_*,
# pruefe_kette_*), die den Kanal ueber ihren NAMEN bindet statt ueber ein
# freies Argument, das der Aufrufer beliebig behaupten koennte (S7-05: 33
# Aufrufstellen liessen sich frei auf jeden Kanal einreden). Jede andere
# Kanalangabe ist ein Fehler des Selbsttests selbst, nicht des Gates.
PRUEFE_WAHR_VORRAT="beobachter dauer selbsttest datei"
pruefe_wahr() {
local kennung="$1" kanal="$2" fall="$3" zusicherung="$4" ok="$5" erwartet="$6" erhalten="$7"
local teil
IFS='+' read -ra _pwt <<< "$kanal"
for teil in "${_pwt[@]}"; do
  case " $PRUEFE_WAHR_VORRAT " in
    *" $teil "*) ;;
    *)
      echo "FEHLER  $kennung: unzulaessiger Kanal fuer pruefe_wahr: '$kanal' (Vorrat: $PRUEFE_WAHR_VORRAT)" >&2
      _melde "$kennung" "$kanal" "$fall" "$zusicherung" 0 "$erwartet" "unzulaessiger Kanal fuer pruefe_wahr: '$kanal'"
      return
      ;;
  esac
done
_melde "$kennung" "$kanal" "$fall" "$zusicherung" "$ok" "$erwartet" "$erhalten"
}

# pruefe_rc_wahr/pruefe_stdout_wahr/pruefe_stderr_wahr/pruefe_zaehler_wahr/
# pruefe_kette_wahr <kennung> <fall> <zusicherung> <ok:0|1> <erwartet>
# <erhalten> -- wie pruefe_wahr, aber der Kanal ist ueber den Funktionsnamen
# FEST gebunden, nicht ein freies Argument (S7-05). Fuer Faelle, deren
# Bedingung aus mehreren Teilbefunden auf demselben Kanal zusammengesetzt
# ist und die deshalb keine der einfachen pruefe_*_enthaelt/-_leer-Huellen
# nutzen koennen.
pruefe_rc_wahr() {
local kennung="$1" fall="$2" zusicherung="$3" ok="$4" erwartet="$5" erhalten="$6"
_melde "$kennung" "rc" "$fall" "$zusicherung" "$ok" "$erwartet" "$erhalten"
}
pruefe_stdout_wahr() {
local kennung="$1" fall="$2" zusicherung="$3" ok="$4" erwartet="$5" erhalten="$6"
_melde "$kennung" "stdout" "$fall" "$zusicherung" "$ok" "$erwartet" "$erhalten"
}
pruefe_stderr_wahr() {
local kennung="$1" fall="$2" zusicherung="$3" ok="$4" erwartet="$5" erhalten="$6"
_melde "$kennung" "stderr" "$fall" "$zusicherung" "$ok" "$erwartet" "$erhalten"
}
pruefe_zaehler_wahr() {
local kennung="$1" fall="$2" zusicherung="$3" ok="$4" erwartet="$5" erhalten="$6"
_melde "$kennung" "zaehler" "$fall" "$zusicherung" "$ok" "$erwartet" "$erhalten"
}
pruefe_kette_wahr() {
local kennung="$1" fall="$2" zusicherung="$3" ok="$4" erwartet="$5" erhalten="$6"
_melde "$kennung" "kette" "$fall" "$zusicherung" "$ok" "$erwartet" "$erhalten"
}
pruefe_stdout_stderr_wahr() {
local kennung="$1" fall="$2" zusicherung="$3" ok="$4" erwartet="$5" erhalten="$6"
_melde "$kennung" "stdout+stderr" "$fall" "$zusicherung" "$ok" "$erwartet" "$erhalten"
}

# pruefe_kette_zeile <kennung> <fall> <zusicherung> <erwartete_zeile>
# <erhaltene_zeile> -- Kanal "kette" (6.12.26 a): die vom Selbsttest DIREKT
# aufgerufene Kettenausgabe (Attrappenziel "dod-baum-direkt", nicht ueber das
# GATE), im Unterschied zu stdout/stderr des GATES selbst. Item 1 (Runde 6).
pruefe_kette_zeile() {
local kennung="$1" fall="$2" zusicherung="$3" erwartet="$4" erhalten="$5"
local ok=0
[ "$erhalten" = "$erwartet" ] && ok=1
_melde "$kennung" "kette" "$fall" "$zusicherung" "$ok" "$erwartet" "$erhalten"
}

# _kette_baum_direkt <cwd_feld> <proj_feld> -- spiegelt WOERTLICH die
# Baumbestimmung von dod-gate.sh (Zeilen ~402-427: cwd/proj im selben
# Git-Repository -> show-toplevel von cwd_feld; sonst Rueckfall auf
# proj_feld, dessen show-toplevel oder, falls proj_feld kein Git-Baum ist,
# dessen physisch aufgeloester Pfad). Fuer den DIREKTEN Kettenaufruf (Item 1,
# Runde 6), der ohne das GATE selbst auskommt.
_kette_baum_direkt() {
local cwd_feld="$1" proj_feld="$2"
local cwd_git="" proj_git="" selber_baum=0 baum=""
[ -n "$cwd_feld" ] && [ -d "$cwd_feld" ] && cwd_git=$(git -C "$cwd_feld" rev-parse --git-common-dir 2>/dev/null || true)
[ -n "$proj_feld" ] && [ -d "$proj_feld" ] && proj_git=$(git -C "$proj_feld" rev-parse --git-common-dir 2>/dev/null || true)
if [ -n "$proj_git" ] && [ -n "$cwd_git" ]; then
  local proj_git_abs cwd_git_abs
  proj_git_abs=$( (cd "$proj_feld" 2>/dev/null && cd "$proj_git" 2>/dev/null && pwd -P) || true)
  cwd_git_abs=$( (cd "$cwd_feld" 2>/dev/null && cd "$cwd_git" 2>/dev/null && pwd -P) || true)
  [ -n "$proj_git_abs" ] && [ "$proj_git_abs" = "$cwd_git_abs" ] && selber_baum=1
fi
if [ "$selber_baum" -eq 1 ]; then
  baum=$(git -C "$cwd_feld" rev-parse --show-toplevel 2>/dev/null || true)
fi
if [ -z "$baum" ] && [ -n "$proj_feld" ]; then
  if [ -n "$proj_git" ]; then
    baum=$(git -C "$proj_feld" rev-parse --show-toplevel 2>/dev/null || true)
  fi
  if [ -z "$baum" ] && [ -d "$proj_feld" ]; then
    baum=$( (cd "$proj_feld" 2>/dev/null && pwd -P) || true)
  fi
fi
printf '%s' "$baum"
}

# _kette_satellit_schreiben <zieldatei> -- Befund (Item 1, Runde 6,
# Nachpruefung Runde 7): das bisherige Attrappenziel "dod-baum-direkt" trug
# einen FEST VERDRAHTETEN Text (@echo ... $(CURDIR)) in der Attrappenkette
# selbst und las NIE aus $ECHTES_MAKEFILE -- eine Mutation an der ECHTEN
# Baumzeile (Makefile-Zeile "echo "make dod: geprueft wird $(PROJ)."") oder
# an der PROJ-Herleitung (pwd -P/-L) hatte deshalb auf die Messung ueberhaupt
# keinen Einfluss (Z-083/086/089/092/093 blieben NICHT ERKANNT). Diese
# Funktion holt die drei tragenden Zeilen -- Variablendefinition
# MAKEFILE_ROH, Herleitung PROJ und die Baumzeile selbst -- WOERTLICH aus
# $ECHTES_MAKEFILE (im Mutationsmodus die mutierte KOPIE) heraus und baut
# daraus ein eigenstaendiges, winziges Makefile-Fragment mit einem einzigen
# Ziel "dod-baum-zeile". Anker sind stabile Praefixe, die keine der fuenf
# Mutationen selbst veraendert (nur ihr JEWEILIGES Suffix aendert sich).
_kette_satellit_schreiben() {
local zieldatei="$1"
local z_roh z_proj z_echo
z_roh=$(grep -m1 '^MAKEFILE_ROH := \$(MAKEFILE_LIST)$' "$ECHTES_MAKEFILE")
z_proj=$(grep -m1 '^PROJ := \$(shell' "$ECHTES_MAKEFILE")
z_echo=$(grep -m1 'geprueft wird' "$ECHTES_MAKEFILE" | sed -E 's/^[[:space:]]+//')
{
  printf '%s\n' "$z_roh"
  printf '%s\n' "$z_proj"
  printf '.PHONY: dod-baum-zeile\n'
  printf 'dod-baum-zeile:\n'
  printf '\t@%s\n' "$z_echo"
} > "$zieldatei"
}

# kette_direkt_aufrufen <cwd_feld> <proj_feld> <erwartete_wurzel> -- ruft die
# Baumzeile DIREKT auf, wortgleich aus $ECHTES_MAKEFILE hergeleitet (siehe
# _kette_satellit_schreiben oben), ohne das GATE, und gibt
# "erste_zeile|erwartete_zeile" aus, getrennt durch ein Rohrzeichen, fuer
# pruefe_kette_zeile.
kette_direkt_aufrufen() {
local cwd_feld="$1" proj_feld="$2" erwartete_wurzel="$3"
local baum_direkt erste_zeile erwartet_phys satellit
baum_direkt=$(_kette_baum_direkt "$cwd_feld" "$proj_feld")
erste_zeile=""
if [ -n "$baum_direkt" ] && [ -d "$baum_direkt" ]; then
  satellit="$baum_direkt/.dod-baum-zeile.mk"
  _kette_satellit_schreiben "$satellit"
  erste_zeile=$(PATH="$WERKZEUGKASTEN_VOLL" make -s -C "$baum_direkt" -f .dod-baum-zeile.mk dod-baum-zeile 2>/dev/null | head -n 1)
  rm -f "$satellit"
fi
erwartet_phys=$( (cd "$erwartete_wurzel" 2>/dev/null && pwd -P) || printf '%s' "$erwartete_wurzel")
printf '%s|make dod: geprueft wird %s.' "$erste_zeile" "$erwartet_phys"
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

# =============================================================================
# FALLFUNKTIONEN (ADR 0002, 6.12.26 b, Fortschreibung DevOps O-25 Phase 2)
# =============================================================================
#
# Jeder Pruefaufbau ist eine eigene, selbststaendige Funktion: sie stellt
# ALLES, was sie braucht, selbst her (eigener Scheinbaum ueber
# neuer_mock_baum, eigenes Zustandsverzeichnis, eigene Lagenliste, eigene
# Attrappen im PATH) und verlaesst sich auf keine Variable, die eine
# ANDERE Fallfunktion gesetzt hat. Im Normalmodus ruft
# normal_modus_ausfuehren() alle Fallfunktionen in fester Reihenfolge
# (FALL_REIHENFOLGE); im Mutationsmodus ruft mutationsmodus_ausfuehren()
# je Kennung NUR die ueber FALL_ZU_KENNUNG registrierte Funktion, isoliert
# gegen eine mutierte Kopie.
# =============================================================================

# --- Fall 1: A_FAIL blockiert -----------------------------------------------
fall_z001() {
baum=$(neuer_mock_baum)
m1=$(marken_zeile K1 D20 belege A_OK "" "" 0)
m2=$(marken_zeile K1 D3 linter A_FAIL "" "" 2)
ausgabe=$(bauen_ausgabe "$baum" "$m1
$m2" "$D19_OK" "make dod: abgebrochen bei D3 linter, Rueckgabewert 2.")
lauf "$baum" Stop "fall01" "$ausgabe" 2
pruefe_rc Z-001 "Kette mit A_FAIL" 2

}

# --- Fall 2: sauberes Gruen, keine Ausgabe ----------------------------------
fall_z002_004() {
baum=$(neuer_mock_baum)
m1=$(marken_zeile K1 D20 belege A_OK "" "" 0)
m2=$(marken_zeile K1 D1 bau B "" "" 0)
ausgabe=$(bauen_ausgabe "$baum" "$m1
$m2" "$D19_OK" "make dod: alle 2 Kettenschritte durchlaufen, keiner ungleich 0, 2 gueltige Marken gezaehlt.")
lauf "$baum" Stop "fall02" "$ausgabe" 0
pruefe_rc Z-002 "Kette gruen, ohne Lage C" 0
pruefe_stdout_leer Z-003 "Kette gruen, ohne Lage C"
pruefe_stderr_leer Z-004 "Kette gruen, ohne Lage C"

}

# --- Fall 3: terminierte Lage C, Eintrag gueltig -> 0 mit systemMessage ----
fall_z005_007() {
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

}

# --- Fall 4: Lage C ohne Eintrag -> 2 ---------------------------------------
fall_z008() {
baum=$(neuer_mock_baum)
m1=$(marken_zeile K1 D20 belege A_OK "" "" 0)
m2=$(marken_zeile K1 D7 abnahme C scripts/abnahme-abgleich.sh "" 2)
ausgabe=$(bauen_ausgabe "$baum" "$m1
$m2" "$D19_OK" "make dod: alle 2 Kettenschritte durchlaufen, 1 davon ohne Urteil (Lage C): D7 abnahme FEHLT=scripts/abnahme-abgleich.sh, Rueckgabewert 2.")
lauf "$baum" Stop "fall04" "$ausgabe" 2
pruefe_rc Z-008 "Lage C ohne Eintrag" 2

}

# --- Fall 5: Eintrag vorhanden, Pruefmittel existiert inzwischen (veraltet) -
fall_z009_010() {
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

}

# --- Fall 6: Eintrag vorhanden, Schritt meldet A_OK (veraltet) -------------
fall_z011_012() {
baum=$(neuer_mock_baum)
printf 'D7 abnahme|scripts/abnahme-abgleich.sh\tADR 0002, 6.12.5, Selbsttest.\n' > "$baum/.claude/hooks/dod-gate-terminierte-lagen.txt"
m1=$(marken_zeile K1 D20 belege A_OK "" "" 0)
m2=$(marken_zeile K1 D7 abnahme A_OK "" "" 0)
ausgabe=$(bauen_ausgabe "$baum" "$m1
$m2" "$D19_OK" "make dod: alle 2 Kettenschritte durchlaufen, keiner ungleich 0, 2 gueltige Marken gezaehlt.")
lauf "$baum" Stop "fall06" "$ausgabe" 0
pruefe_rc Z-011 "Eintrag vorhanden, Schritt meldet A_OK" 2
# Z-012 (Runde 6, Mutationsprobe): "D7 abnahme" allein ist zu schwach -- der
# Schluessel ("LISTE 3 D7 abnahme") und der naechste Schritt tragen dieselbe
# Zeichenfolge UNABHAENGIG vom liste_text der Selbstpruefung 3 (dod-gate.sh
# Zeile ~1028) und ueberleben die Mutation, die dort Schluessel und
# Zeilennummer entfernt. "(Zeile 1 in" kommt in DIESEM Fall ausschliesslich
# aus liste_text und faellt mit der Mutation weg.
pruefe_stderr_enthaelt Z-012 "Eintrag vorhanden, Schritt meldet A_OK" \
  "Meldung fuehrt den beanstandeten Eintrag im Wortlaut auf" "(Zeile 1 in"

}

# --- Fall 7a: Eintrag ohne Grund --------------------------------------------
fall_z013() {
baum=$(neuer_mock_baum)
printf 'D7 abnahme|scripts/abnahme-abgleich.sh\t\n' > "$baum/.claude/hooks/dod-gate-terminierte-lagen.txt"
m1=$(marken_zeile K1 D7 abnahme C scripts/abnahme-abgleich.sh "" 2)
ausgabe=$(bauen_ausgabe "$baum" "$m1" "$D19_OK" "make dod: alle 1 Kettenschritte durchlaufen, 1 davon ohne Urteil (Lage C): D7 abnahme FEHLT=scripts/abnahme-abgleich.sh, Rueckgabewert 2.")
lauf "$baum" Stop "fall07a" "$ausgabe" 2
pruefe_rc Z-013 "Eintrag ohne Grund" 2

}

# --- Fall 7b: Eintrag mit nicht terminierbarer D-Nummer (D19/D20) ----------
# Die vormalige Fassung dieses Falls (Eintrag "D11 geheimnisse|gitleaks",
# blosser Name ohne Verzeichnistrenner) blockierte bereits ueber
# Selbstpruefung 6 "kein Verzeichnistrenner" (Zeile 647 in dod-gate.sh) --
# die D19/D20-Wache (Zeile 632) wurde dabei NIE erreicht, egal ob sie greift
# oder nicht. Die Mutation (Wache auf "if false" gesetzt) blieb deshalb
# unerkannt. Jetzt: eine sonst vollstaendig WOHLGEFORMTE Zeile mit "D19" als
# D-Nummer (Tabulator vorhanden, "|" vorhanden, Pfad mit Verzeichnistrenner,
# nicht absolut, im Baum nicht vorhanden, Grund nennt "ADR 0002, ..."), die
# NUR an der D19/D20-Wache scheitert. Der Ausgang wird als VOLLSTAENDIG
# gruener Lauf gebaut: unter korrektem Code bricht das Gate VOR dem
# Kettenlauf mit rc 2 (LISTE 6) ab, unter der Mutation (Wache uebersprungen)
# laeuft die Kette durch und liefert rc 0.
fall_z014() {
baum=$(neuer_mock_baum)
printf 'D19 rahmen|scripts/nicht-vorhandenes-werkzeug.sh\tADR 0002, 6.12.5, Selbsttest.\n' > "$baum/.claude/hooks/dod-gate-terminierte-lagen.txt"
m1=$(marke K1 D20 belege A_OK)
ausgabe=$(bauen_ausgabe "$baum" "$m1 (rueckgabewert=0)" "$D19_OK" "make dod: alle 1 Kettenschritte durchlaufen, keiner ungleich 0, 1 gueltige Marken gezaehlt.")
lauf "$baum" Stop "fall07b" "$ausgabe" 0
pruefe_rc Z-014 "Eintrag mit nicht terminierbarer D-Nummer (D19/D20), sonst wohlgeformte Zeile, sonst gruener Lauf" 2

}

# --- Fall 7c: Eintrag mit absolutem Pfad ------------------------------------
fall_z015() {
baum=$(neuer_mock_baum)
printf 'D7 abnahme|/scripts/abnahme-abgleich.sh\tADR 0002, 6.12.5, Selbsttest.\n' > "$baum/.claude/hooks/dod-gate-terminierte-lagen.txt"
m1=$(marken_zeile K1 D7 abnahme C /scripts/abnahme-abgleich.sh "" 2)
ausgabe=$(bauen_ausgabe "$baum" "$m1" "$D19_OK" "make dod: alle 1 Kettenschritte durchlaufen, 1 davon ohne Urteil (Lage C): D7 abnahme FEHLT=/scripts/abnahme-abgleich.sh, Rueckgabewert 2.")
lauf "$baum" Stop "fall07c" "$ausgabe" 2
pruefe_rc Z-015 "Eintrag mit absolutem Pfad" 2

}

# --- Fall 8: Marke nennt anderes Pruefmittel als der Schluessel ------------
fall_z016() {
baum=$(neuer_mock_baum)
printf 'D7 abnahme|scripts/abnahme-abgleich.sh\tADR 0002, 6.12.5, Selbsttest.\n' > "$baum/.claude/hooks/dod-gate-terminierte-lagen.txt"
m1=$(marken_zeile K1 D7 abnahme C ein-anderer-wert "" 2)
ausgabe=$(bauen_ausgabe "$baum" "$m1" "$D19_OK" "make dod: alle 1 Kettenschritte durchlaufen, 1 davon ohne Urteil (Lage C): D7 abnahme FEHLT=ein-anderer-wert, Rueckgabewert 2.")
lauf "$baum" Stop "fall08" "$ausgabe" 2
pruefe_rc Z-016 "Marke nennt anderes Pruefmittel als der Schluessel" 2

}

# --- Fall 9: stop_hook_active wahr bei roter Kette -> 0, Zaehler unveraendert
fall_z017_018() {
baum=$(neuer_mock_baum)
zustand9=$(neu_verzeichnis)
# Item 5 (Runde 6): Z-018 muss belegen, dass ein VORHANDENER Zaehlerstand
# durch den stop_hook_active-Durchlass NICHT veraendert wird -- die
# bisherige Messung (keine Zaehlerdatei vorhanden, weder davor noch danach)
# belegte nur die Abwesenheit, nicht die Unveraenderlichkeit. Vor dem Aufruf
# wird die Zaehlerdatei im Format des Gates (Zeile 1: Schluessel, Zeile 2:
# Stand) mit Stand 2 angelegt.
schluessel9="D3 linter A_FAIL"
zaehlerdatei9=$(zaehler_pfad "$zustand9" "fall09")
mkdir -p "$(dirname "$zaehlerdatei9")"
printf '%s\n%s\n' "$schluessel9" "2" > "$zaehlerdatei9"
eingabe9=$(baue_eingabe "Stop" "$baum" "fall09" "true")
rufe_gate "$eingabe9" "$zustand9" "$WERKZEUGKASTEN_VOLL" "CLAUDE_PROJECT_DIR=$baum" "MOCK_AUSGABE=roter Muell" "MOCK_RC=2"
pruefe_rc Z-017 "stop_hook_active wahr bei roter Kette" 0
schluessel9_nachher=$(sed -n '1p' "$zaehlerdatei9" 2>/dev/null || true)
stand9_nachher=$(sed -n '2p' "$zaehlerdatei9" 2>/dev/null || true)
pruefe_zaehler_wahr Z-018 "stop_hook_active wahr bei roter Kette, Zaehlerdatei vor dem Aufruf mit Schluessel und Stand 2 angelegt" \
  "Zaehlerdatei traegt nach dem Aufruf unveraendert denselben Schluessel und den Stand 2" \
  "$([ "$schluessel9_nachher" = "$schluessel9" ] && [ "$stand9_nachher" = "2" ] && echo 1 || echo 0)" \
  "Schluessel='$schluessel9', Stand=2" "Schluessel='$schluessel9_nachher', Stand='$stand9_nachher' (Datei: $zaehlerdatei9)"

}

# --- Fall 10a (6.12.23 a, vierte Form): alle Schritte gruen, D19 VERLETZT,
# rc 2 -> Gate blockiert mit Schluessel "D19 VERLETZT".
fall_z019() {
baum=$(neuer_mock_baum)
m1=$(marken_zeile K1 D20 belege A_OK "" "" 0)
ausgabe_10a=$(bauen_ausgabe "$baum" "$m1" "VERLETZT -- versionierter Bestand veraendert." "make dod: alle 1 Kettenschritte durchlaufen, Rahmenpruefung D19 VERLETZT, Rueckgabewert 2.")
lauf "$baum" Stop "fall10a" "$ausgabe_10a" 2
pruefe_rc Z-019 "D19 VERLETZT, Form 4" 2

}

# --- Fall 10b: D19 Lage C, Form 4 -------------------------------------------
fall_z020() {
baum=$(neuer_mock_baum)
m1=$(marken_zeile K1 D20 belege A_OK "" "" 0)
ausgabe=$(bauen_ausgabe "$baum" "$m1" "C -- git fehlt, nicht beobachtet." "make dod: alle 1 Kettenschritte durchlaufen, Rahmenpruefung D19 C, Rueckgabewert 2.")
lauf "$baum" Stop "fall10b" "$ausgabe" 2
pruefe_rc Z-020 "D19 Lage C, Form 4" 2

echo
echo "--- Fehlende Pruefmittel (G10, 6.12.11) --------------------------------"
echo

}

# --- Z-021/022, Z-023/024, Z-025/026, Z-029/030, Z-031/032: jq, git, make,
#     timeout, flock einzeln aus dem Werkzeugkasten entfernt ---------------
fall_z021_032() {
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

}

# --- Z-027/028: fehlendes Makefile -----------------------------------------
fall_z027_028() {
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

}

# --- Z-033/034: fehlende Liste der terminierten Lagen ----------------------
fall_z033_034() {
baum_ohne_liste=$(neuer_mock_baum)
rm -f "$baum_ohne_liste/.claude/hooks/dod-gate-terminierte-lagen.txt"
lauf "$baum_ohne_liste" Stop "fall11-liste" "x" 0
pruefe_rc Z-033 "Fehlende Liste der terminierten Lagen" 2
pruefe_stderr_enthaelt Z-034 "Fehlende Liste der terminierten Lagen" "Meldung nennt den Pfad der Liste" ".claude/hooks/dod-gate-terminierte-lagen.txt"

}

# --- Z-116..Z-121 (Entscheid g): sha256sum und mktemp fehlend, je drei -----
fall_z116_121() {
baum=$(neuer_mock_baum)
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

}

# --- Z-035/036, Z-104/105: nicht beschreibbares Zustandsverzeichnis, /tmp
#     bleibt als Ausweich erreichbar -----------------------------------------
fall_z035_036_104_105() {
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
baum_hash12=$(printf '%s' "$baum" | sha256sum | cut -d' ' -f1)
sperre_datei12="/tmp/r3cosint-dod-gate/sperre-$baum_hash12.lock"
# 6.12.26 (O-25, Kanalabgleich): Z-104 nennt den Kanal "beobachter" -- ein
# vorher/nachher-Test mit [ -f ] belegt nicht, dass die Sperrdatei WAEHREND
# des Laufs bestand. Ein Beobachter ohne Wartezeit poll't parallel zum
# Gate-Aufruf; MOCK_SLEEP=0.3 haelt die Kette lang genug offen, damit ein
# Beobachtungsfenster entsteht (wie bei Z-111, DT5-01).
beobachter_stopp104=$(neu_verzeichnis)/stopp
beobachter_treffer104=$(neu_verzeichnis)/treffer
: > "$beobachter_treffer104"
(
  if [ -n "${SELBSTTEST_SPERRE_FD:-}" ]; then exec {SELBSTTEST_SPERRE_FD}>&- 2>/dev/null || true; fi
  while [ ! -e "$beobachter_stopp104" ]; do
    [ -f "$sperre_datei12" ] && echo treffer >> "$beobachter_treffer104"
  done
) &
beobachter_pid104=$!
rufe_gate "$eingabe12" "$zustand12" "$WERKZEUGKASTEN_VOLL" "CLAUDE_PROJECT_DIR=$baum" "MOCK_AUSGABE=$ausgabe" "MOCK_RC=2" "MOCK_SLEEP=0.3"
: > "$beobachter_stopp104"
wait "$beobachter_pid104" 2>/dev/null
treffer104=$(wc -l < "$beobachter_treffer104" | tr -d ' ')
pruefe_rc Z-035 "Nicht beschreibbares Zustandsverzeichnis bei roter Kette" 2
pruefe_stderr_enthaelt Z-036 "Nicht beschreibbares Zustandsverzeichnis bei roter Kette" \
  "Zusatz, dass nicht gezaehlt werden kann" "nicht zaehlen"
pruefe_wahr Z-104 "beobachter" "Zustandsverzeichnis nicht beschreibbar" \
  "ein Beobachter ohne Wartezeit findet die Sperrdatei waehrend des Laufs unter /tmp" \
  "$([ "$treffer104" -gt 0 ] && echo 1 || echo 0)" ">=1 Treffer waehrend des Laufs" "$treffer104 Treffer"
pruefe_rc Z-105 "Zustandsverzeichnis nicht beschreibbar" 2
rm -f "$sperre_datei12"
if [ "$sperre_fest_war_verzeichnis" -eq 1 ]; then
  mv "$sperre_fest_sicherung/verzeichnis" "$sperre_fest"
fi

echo
echo "--- Zustandsverzeichnis UND /tmp nicht beschreibbar (N-04, Entscheid e)"
echo

}

# --- Z-106/107/108: beide Auswege fuer die Sperre versperrt, ROTE Kette ----
fall_z106_108() {
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
# Kontrolle des Koordinators, Punkt (d)/(a): die bisherige Messung sah nur
# INNERHALB von $zustand_n04 nach -- der Ausweichweg der Sperrdatei liegt
# aber unter dem FESTEN Pfad $sperre_fest ("/tmp/r3cosint-dod-gate"), NIE
# unter $zustand_n04. Die Mutation ersetzt $sperre_fest durch "/tmp" selbst
# (immer beschreibbar); die Sperrdatei entstuende dann direkt unter /tmp
# ("/tmp/sperre-<hash>.lock"), an einem Ort, den die bisherige Messung nie
# beobachtete. Deshalb zusaetzlich: Bestand von /tmp/sperre-*.lock VOR und
# NACH dem Lauf vergleichen (die Datei bleibt bis zum Prozessende offen,
# siehe Kommentar oben zu N-04, und wird danach nicht selbst geloescht).
tmp_sperre_vorher_n04=$(find /tmp -maxdepth 1 -name 'sperre-*.lock' 2>/dev/null | sort)
eingabe_n04=$(baue_eingabe "Stop" "$baum" "fall-n04")
rufe_gate "$eingabe_n04" "$zustand_n04" "$WERKZEUGKASTEN_VOLL" "CLAUDE_PROJECT_DIR=$baum" "MOCK_AUSGABE=$ausgabe" "MOCK_RC=2"
sperre_entstand_n04=$(find "$zustand_n04" -name 'sperre-*' 2>/dev/null | wc -l | tr -d ' ')
[ -n "$sperre_entstand_n04" ] || sperre_entstand_n04=0
tmp_sperre_nachher_n04=$(find /tmp -maxdepth 1 -name 'sperre-*.lock' 2>/dev/null | sort)
tmp_sperre_neu_n04=$(comm -13 <(printf '%s\n' "$tmp_sperre_vorher_n04") <(printf '%s\n' "$tmp_sperre_nachher_n04"))
tmp_sperre_neu_anzahl_n04=0
[ -n "$tmp_sperre_neu_n04" ] && tmp_sperre_neu_anzahl_n04=$(printf '%s\n' "$tmp_sperre_neu_n04" | grep -c .)
[ -n "$tmp_sperre_neu_n04" ] && printf '%s\n' "$tmp_sperre_neu_n04" | xargs -r rm -f
rm -f "$sperre_fest"
if [ "$sperre_fest_war_verzeichnis" -eq 1 ]; then
  mv "$sperre_fest_sicherung/verzeichnis" "$sperre_fest"
fi
pruefe_wahr Z-106 "beobachter" "Zustandsverzeichnis und /tmp nicht beschreibbar" \
  "an keinem der beiden Orte (Zustandsverzeichnis, fester Ausweichpfad /tmp/r3cosint-dod-gate) entsteht eine Sperrdatei -- auch nicht direkt unter /tmp" \
  "$([ "$sperre_entstand_n04" = "0" ] && [ "$tmp_sperre_neu_anzahl_n04" = "0" ] && echo 1 || echo 0)" \
  "keine Sperrdatei" "sperre_entstand=$sperre_entstand_n04, tmp_neu=$tmp_sperre_neu_anzahl_n04"
pruefe_rc Z-107 "Zustandsverzeichnis und /tmp nicht beschreibbar" 2
pruefe_stderr_enthaelt Z-108 "Zustandsverzeichnis und /tmp nicht beschreibbar" \
  "Meldung nennt den Ausfall der Sperre" "Sperre nicht aktiv"

echo
echo "--- Innere Zeitueberschreitung (6.12.12) -------------------------------"
echo

}

# --- Fall (Auftrag O-25 6.12.26 b, DevOps): Innere Zeitueberschreitung (Z-037), eigenstaendig herausgeloest aus der vormals unmarkierten Luecke zwischen den beiden Nachbarfaellen ------------------------
fall_z037() {
baum=$(neuer_mock_baum)
lauf "$baum" Stop "fall13" "wird nie gedruckt" 0 "" "" "" "$WERKZEUGKASTEN_SCHNELLER_TIMEOUT" 5
pruefe_rc Z-037 "Innere Zeitueberschreitung" 2

echo
echo "--- Eskalation (G8, 6.12.9) --------------------------------------------"
echo

}

# --- Fall (Auftrag O-25 6.12.26 b, DevOps): Eskalation (G8, 6.12.9), Z-038..Z-048, eigenstaendig herausgeloest aus derselben Luecke -------------------------------------------------------------
fall_z038_048() {
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
pruefe_wahr Z-043 "datei" "Uebergabedatei mit der geforderten Zeile, committet" \
  "vor dem Aufruf des Gates fuehrt 'git ls-tree -r HEAD' die Datei -- sie ist wirklich in HEAD" \
  "$head_hat_datei43" "1 (Datei in HEAD)" "$head_hat_datei43"
lauf_mit_zustand "$zustand_esk" "$baum" Stop "fall14" "$ausgabe_esk" 2
pruefe_rc Z-044 "Uebergabedatei mit der geforderten Zeile, committet" 0

# Ein WEITERER Commit danach -- die Uebergabedatei wird ENTFERNT, damit sie
# aus "git ls-tree -r HEAD" wirklich verschwindet (ein blosser weiterer
# Commit daneben liesse sie dort stehen, "ls-tree -r HEAD" listet den
# gesamten Baum, nicht nur die zuletzt geaenderten Dateien -- ausgefuehrt
# belegt in einer frueheren Fassung dieses Falls). Die vormalige Fassung
# ENTFERNTE die Uebergabedatei ("git rm" + Commit) -- damit unterschied sich
# rc unter der Mutation (Suche von HEAD auf "git log --pretty=format:
# --name-only", also die GANZE Historie ausgeweitet) NICHT vom korrekten
# Code: die Datei existierte gar nicht mehr im Baum, die Existenzpruefung
# "[ -f $baum/$pfad ]" schlug in BEIDEN Faellen fehl, egal wie weit die
# Namenssuche reichte. Jetzt bleibt die Datei UNVERAENDERT auf der Platte
# (weiterhin committet, weiterhin die geforderte Zeile) -- nur ein WEITERER,
# UNABHAENGIGER Commit sorgt dafuer, dass sie nicht mehr Teil von
# "git diff-tree ... -r HEAD" ist (das listet ausschliesslich, was sich IM
# LETZTEN Commit geaendert hat). Unter korrektem Code (nur HEAD) bleibt die
# Suche deshalb ergebnislos und das Gate blockiert (rc 2); unter der
# Mutation (ganze Historie) findet die Namenssuche die Datei ueber einen
# AELTEREN Commit, die Existenz- und Inhaltspruefung auf der Platte
# schlaegt jetzt aber AN, weil die Datei ja noch unveraendert vorhanden ist
# -- das Gate laesst faelschlich durch (rc 0).
mkdir -p "$baum/scripts"
printf 'unabhaengige Aenderung, beruehrt die Eskalationsuebergabe nicht\n' \
  > "$baum/scripts/unabhaengige-aenderung-z046.txt"
git -C "$baum" add -A
git -C "$baum" commit -q -m "weiterer, unabhaengiger Commit (Eskalationsuebergabe bleibt aus aelterem Commit unveraendert)"
diff_ohne_datei45=1
git -C "$baum" diff-tree --no-commit-id --name-only -r HEAD 2>/dev/null | \
  grep -qF "docs/uebergaben/2026-09-02_selbsttest-eskalation.md" && diff_ohne_datei45=0
datei_noch_vorhanden45=0
[ -f "$baum/docs/uebergaben/2026-09-02_selbsttest-eskalation.md" ] && \
  grep -qF "Eskalation 3.4: D3 linter A_FAIL" "$baum/docs/uebergaben/2026-09-02_selbsttest-eskalation.md" && \
  datei_noch_vorhanden45=1
aelterer_commit_hat_datei45=0
[ -n "$(git -C "$baum" log --all --format=%H -- "docs/uebergaben/2026-09-02_selbsttest-eskalation.md" 2>/dev/null)" ] && aelterer_commit_hat_datei45=1
pruefe_wahr Z-045 "datei" "Uebergabedatei nur in einem aelteren Commit, auf der Platte unveraendert vorhanden" \
  "vor dem Aufruf zeigt 'git diff-tree --no-commit-id --name-only -r HEAD' die Datei NICHT (sie ist nicht Teil des juengsten Commits), obwohl sie unveraendert mit der geforderten Zeile auf der Platte liegt und aus einem aelteren Commit stammt" \
  "$([ "$diff_ohne_datei45" -eq 1 ] && [ "$datei_noch_vorhanden45" -eq 1 ] && [ "$aelterer_commit_hat_datei45" -eq 1 ] && echo 1 || echo 0)" \
  "diff-tree HEAD ohne die Datei, Datei auf der Platte mit Zeile, aelterer Commit mit Datei" \
  "diff_ohne=$diff_ohne_datei45, noch_vorhanden=$datei_noch_vorhanden45, aelterer_hat=$aelterer_commit_hat_datei45"
lauf_mit_zustand "$zustand_esk" "$baum" Stop "fall14" "$ausgabe_esk" 2
pruefe_rc Z-046 "Uebergabedatei nur in einem aelteren Commit, auf der Platte unveraendert vorhanden" 2

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
pruefe_wahr Z-048 "datei" "Dieselbe Eskalation auf TaskCompleted" \
  "die Uebergabedatei mit der geforderten Zeile liegt vor und ist in HEAD enthalten" \
  "$grund48_ok" "1 (Datei mit Zeile in HEAD)" "$grund48_ok"
lauf_mit_zustand "$zustand_esk" "$baum" TaskCompleted "fall14" "$ausgabe_esk" 2
pruefe_rc Z-047 "Dieselbe Eskalation auf TaskCompleted" 2

echo
echo "--- Vierter Durchlass, danach erneut Blocks (6.12.24 d, DT2-B1; S3-07) -"
echo

}

# --- Z-125..Z-129: eigene, isolierte Sequenz, Uebergabedatei liegt von
#     Anfang an vor (die Datei muss bereits beim VIERTEN Aufruf bestehen,
#     damit der Zaehlerstand bei diesem Durchlass genau 4 ist). -------------
fall_z125_129() {
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

pruefe_stdout_stderr_wahr Z-129 "Vierter Durchlass, danach erneut Blocks" \
  "bei jedem Ereignis nach dem vierten Durchlass -- geprueft am fuenften Ereignis (Stop) und an einem TaskCompleted im selben Zustand -- enthaelt weder stdout noch stderr die Zeichenfolge 'verlangt die Uebergabedatei'" \
  "$([ "$gefunden129_stop" -eq 0 ] && [ "$gefunden129_tc" -eq 0 ] && echo 1 || echo 0)" \
  "keine Forderung auf beiden Kanaelen bei beiden Ereignissen" \
  "stop_gefunden=$gefunden129_stop, taskcompleted_gefunden=$gefunden129_tc"

echo
echo "--- Mehrere Abweichungen zugleich (6.12.25 b, Befund S3-01) -----------"
echo

}

# --- Z-049..Z-053: A_FAIL, zwei ungedeckte Lagen C, D19 VERLETZT zugleich --
fall_z049_053() {
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
# Z-052 (Nachschaerfung Mutationsprobe, 6.12.26 b): die reine Teilstring-
# Pruefung uebersah eine Mutation, die NUR den schluessel-Anhang der
# ungedeckten Lage C entfernt (alle_abweichung_schluessel), den Text-Anhang
# (alle_abweichung_text) aber unangetastet laesst. Weil beide Arrays danach
# nicht mehr gleich lang sind, verschieben sich die Indizes in
# weitere_abweichungen_ausgeben (dod-gate.sh) -- die D10-Zeichenkette taucht
# dabei zufaellig weiterhin irgendwo im Text auf, nur an der FALSCHEN Stelle,
# und die D19-Zeile faellt still weg. Ein reiner "enthaelt"-Test auf die
# D10-Zeichenkette misst das nicht; gezaehlt wird deshalb zusaetzlich die
# ANZAHL der "weitere Abweichung:"-Zeilen (muss exakt 3 sein: D10, D3, D19 --
# D7 ist der primaere Schluessel und wird nicht wiederholt).
weitere_anzahl_z052=$(printf '%s' "$G_STDERR" | grep -c '^dod-gate: weitere Abweichung:')
enthaelt_d10_z052=0
printf '%s' "$G_STDERR" | grep -qF "weitere Abweichung: Schritt D10 prototyp-trennung meldet Lage C mit FEHLT=scripts/prototyp-trennung-pruefen.sh" && enthaelt_d10_z052=1
pruefe_stderr_wahr Z-052 "Lauf mit A_FAIL, zwei ungedeckten Lagen C und D19 VERLETZT zugleich" \
  "die Blockmeldung nennt jede ungedeckte Lage C mit ihrem FEHLT=-Wert (genau 3 Zeilen 'weitere Abweichung', darunter D10)" \
  "$([ "$weitere_anzahl_z052" -eq 3 ] && [ "$enthaelt_d10_z052" -eq 1 ] && echo 1 || echo 0)" \
  "3 Zeilen 'weitere Abweichung:', darunter D10 mit FEHLT=scripts/prototyp-trennung-pruefen.sh" \
  "anzahl=$weitere_anzahl_z052, d10_enthalten=$enthaelt_d10_z052, stderr='$(_kuerzen "$G_STDERR")'"
pruefe_stderr_enthaelt Z-053 "Lauf mit A_FAIL, zwei ungedeckten Lagen C und D19 VERLETZT zugleich" \
  "die Blockmeldung nennt den D19-Befund" "weitere Abweichung: D19 meldet VERLETZT"

echo
echo "--- FEHLT= und SCHWELLE= zugleich (6.12.4) ------------------------------"
echo

}

# --- Z-054/055 ---------------------------------------------------------------
fall_z054_055() {
# Z-055 (Kanal rc): gedeckter Eintrag -- Durchlass, Rueckgabewert 0.
baum=$(neuer_mock_baum)
printf 'D3 linter|scripts/nicht-vorhanden.sh\tADR 0002, 6.12.5, Selbsttest.\n' > "$baum/.claude/hooks/dod-gate-terminierte-lagen.txt"
m1=$(marken_zeile K1 D3 linter C scripts/nicht-vorhanden.sh OHNE_SCHWELLE 2)
ausgabe=$(bauen_ausgabe "$baum" "$m1" "$D19_OK" "make dod: alle 1 Kettenschritte durchlaufen, 1 davon ohne Urteil (Lage C): D3 linter FEHLT=scripts/nicht-vorhanden.sh, Rueckgabewert 2.")
lauf "$baum" Stop "fall20" "$ausgabe" 2
pruefe_rc Z-055 "Marke mit FEHLT= und SCHWELLE= zugleich, gedeckter Eintrag" 0

# Z-054 (Kanal stderr): Item 2 (Runde 6) -- die Kennung verlangt einen BLOCK
# (ungedeckte Lage C); der bisherige Fall war ein Durchlass und mass die
# Standardausgabe. Eigener Baum, LEERE Liste, damit die Lage C ungedeckt ist
# und das GATE selbst blockiert.
baum54=$(neuer_mock_baum)
: > "$baum54/.claude/hooks/dod-gate-terminierte-lagen.txt"
m1_54=$(marken_zeile K1 D3 linter C scripts/nicht-vorhanden.sh OHNE_SCHWELLE 2)
ausgabe54=$(bauen_ausgabe "$baum54" "$m1_54" "$D19_OK" "make dod: alle 1 Kettenschritte durchlaufen, 1 davon ohne Urteil (Lage C): D3 linter FEHLT=scripts/nicht-vorhanden.sh, Rueckgabewert 2.")
lauf "$baum54" Stop "fall20-block" "$ausgabe54" 2
enthaelt_richtig54=0
printf '%s' "$G_STDERR" | grep -qF "FEHLT=scripts/nicht-vorhanden.sh" && enthaelt_richtig54=1
enthaelt_ohne_schwelle54=0
printf '%s' "$G_STDERR" | grep -qF "OHNE_SCHWELLE" && enthaelt_ohne_schwelle54=1
pruefe_stderr_wahr Z-054 "Marke mit FEHLT= und SCHWELLE= zugleich, ungedeckte Lage C" \
  "die Fehlerausgabe des GATES nennt als FEHLT=-Wert genau den Pfad, ohne den SCHWELLE=-Teil (Block, rc=2)" \
  "$([ "$enthaelt_richtig54" -eq 1 ] && [ "$enthaelt_ohne_schwelle54" -eq 0 ] && [ "$G_RC" = "2" ] && echo 1 || echo 0)" \
  "rc=2, stderr enthaelt 'FEHLT=scripts/nicht-vorhanden.sh' ohne 'OHNE_SCHWELLE'" "rc=$G_RC, stderr='$(_kuerzen "$G_STDERR")'"

echo
echo "--- D19-Formen (G7, N-02) ------------------------------------------------"
echo

}

# --- Z-056..Z-063: acht Kombinationen, je mit und ohne Zusatztext ----------
fall_z056_063() {
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

}

# --- Z-142/143 ----------------------------------------------------------------
fall_z142_143() {
baum=$(neuer_mock_baum)
m1=$(marken_zeile K1 D20 belege A_OK "" "" 0)
ausgabe_s01=$(bauen_ausgabe "$baum" "$m1" "B -- kein Git-Arbeitsbaum." "make dod: alle 1 Kettenschritte durchlaufen, keiner ungleich 0, 1 gueltige Marken gezaehlt.")
zustand_s01=$(neu_verzeichnis)
eingabe_s01=$(baue_eingabe "Stop" "$baum" "fall-s01")
rufe_gate "$eingabe_s01" "$zustand_s01" "$WERKZEUGKASTEN_VOLL" "CLAUDE_PROJECT_DIR=$baum" "MOCK_AUSGABE=$ausgabe_s01" "MOCK_RC=0"
pruefe_rc Z-142 "D19-Zeile meldet Lage B bei Rueckgabewert 0, obwohl das Gate einen Arbeitsbaum bestimmt hat" 2
zaehler_datei_s01=$(zaehler_pfad "$zustand_s01" "fall-s01")
pruefe_zaehler_schluessel Z-143 "D19-Zeile meldet Lage B bei Rueckgabewert 0" \
  "$zaehler_datei_s01" "D19 B-widerspruch"

echo
echo "--- TaskCompleted bei roter Kette ----------------------------------------"
echo

}

# --- Z-064 ---------------------------------------------------------------
fall_z064() {
baum=$(neuer_mock_baum)
m1=$(marken_zeile K1 D3 linter A_FAIL "" "" 2)
ausgabe=$(bauen_ausgabe "$baum" "$m1" "$D19_OK" "make dod: abgebrochen bei D3 linter, Rueckgabewert 2.")
lauf "$baum" TaskCompleted "fall22" "$ausgabe" 2
pruefe_rc Z-064 "TaskCompleted bei roter Kette" 2

echo
echo "--- SubagentStop und echte Rollendateien (G13, 6.12.14; N-03) ---------"
echo

}

# --- Z-065/067/068: echte Rolle static-software-tester (kein Edit/Write) --
fall_z065_068() {
baum_sst=$(neuer_mock_baum)
cp "$REPO_WURZEL/.claude/agents/static-software-tester.md" "$baum_sst/.claude/agents/static-software-tester.md"
summe_quelle68=$(sha256sum "$REPO_WURZEL/.claude/agents/static-software-tester.md" | cut -d' ' -f1)
summe_kopie68=$(sha256sum "$baum_sst/.claude/agents/static-software-tester.md" | cut -d' ' -f1)
pruefe_wahr Z-068 "datei" "N-03: echte Rollendatei im Scheinbaum" \
  "die im Scheinbaum verwendete Rollendatei ist pruefsummengleich mit der aus .claude/agents/" \
  "$([ "$summe_quelle68" = "$summe_kopie68" ] && echo 1 || echo 0)" \
  "$summe_quelle68" "$summe_kopie68"
zustand_sst=$(neu_verzeichnis)
marker_sst=$(neu_verzeichnis)/marker
eingabe_sst=$(baue_eingabe "SubagentStop" "$baum_sst" "fall-sst" "false" "a1" "static-software-tester")
rufe_gate "$eingabe_sst" "$zustand_sst" "$WERKZEUGKASTEN_VOLL" "CLAUDE_PROJECT_DIR=$baum_sst" "MOCK_AUSGABE=roter Muell, duerfte nie gelesen werden" "MOCK_RC=2" "MOCK_MARKER=$marker_sst"
pruefe_rc Z-065 "SubagentStop echte Rolle static-software-tester" 0
pruefe_wahr Z-067 "datei" "SubagentStop einer Rolle ohne veraenderndes Werkzeug" \
  "die Attrappe von make dod verzeichnet keinen Aufruf" \
  "$([ ! -e "$marker_sst" ] && echo 1 || echo 0)" \
  "keine Markerdatei" "$([ -e "$marker_sst" ] && echo "Markerdatei besteht" || echo "keine Markerdatei")"

}

# --- Z-066: echte Rolle pentester (kein Edit/Write) ------------------------
fall_z066() {
baum_pt=$(neuer_mock_baum)
cp "$REPO_WURZEL/.claude/agents/pentester.md" "$baum_pt/.claude/agents/pentester.md"
zustand_pt=$(neu_verzeichnis)
eingabe_pt=$(baue_eingabe "SubagentStop" "$baum_pt" "fall-pt" "false" "a1" "pentester")
rufe_gate "$eingabe_pt" "$zustand_pt" "$WERKZEUGKASTEN_VOLL" "CLAUDE_PROJECT_DIR=$baum_pt" "MOCK_AUSGABE=roter Muell, duerfte nie gelesen werden" "MOCK_RC=2"
pruefe_rc Z-066 "SubagentStop echte Rolle pentester" 0

}

# --- Z-069/070: echte Rolle devops-engineer (mit Edit/Write), ROTE Kette --
fall_z069_070() {
baum_dev=$(neuer_mock_baum)
cp "$REPO_WURZEL/.claude/agents/devops-engineer.md" "$baum_dev/.claude/agents/devops-engineer.md"
m1=$(marken_zeile K1 D3 linter A_FAIL "" "" 2)
ausgabe_dev=$(bauen_ausgabe "$baum_dev" "$m1" "$D19_OK" "make dod: abgebrochen bei D3 linter, Rueckgabewert 2.")
zustand_dev=$(neu_verzeichnis)
marker_dev=$(neu_verzeichnis)/marker
eingabe_dev=$(baue_eingabe "SubagentStop" "$baum_dev" "fall-devops" "false" "a1" "devops-engineer")
rufe_gate "$eingabe_dev" "$zustand_dev" "$WERKZEUGKASTEN_VOLL" "CLAUDE_PROJECT_DIR=$baum_dev" "MOCK_AUSGABE=$ausgabe_dev" "MOCK_RC=2" "MOCK_MARKER=$marker_dev"
pruefe_wahr Z-069 "datei" "SubagentStop echte Rolle devops-engineer" \
  "die Attrappe von make dod verzeichnet einen Aufruf" \
  "$([ -e "$marker_dev" ] && echo 1 || echo 0)" \
  "Markerdatei besteht" "$([ -e "$marker_dev" ] && echo "Markerdatei besteht" || echo "keine Markerdatei")"
pruefe_rc Z-070 "SubagentStop echte Rolle devops-engineer" 2

echo
echo "--- agent_type: Aufloesung ueber name:, nicht ueber den Dateinamen (G13)"
echo

}

# --- Z-071/072: agent_type ueber name: aufgeloest (anders-benannt.md) -----
fall_z071_072() {
baum=$(neuer_mock_baum)
zustand25=$(neu_verzeichnis)
marker25=$(neu_verzeichnis)/marker
eingabe25=$(baue_eingabe "SubagentStop" "$baum" "fall25" "false" "a1" "attrappe-pruefer")
rufe_gate "$eingabe25" "$zustand25" "$WERKZEUGKASTEN_VOLL" "CLAUDE_PROJECT_DIR=$baum" "MOCK_AUSGABE=roter Muell" "MOCK_RC=2" "MOCK_MARKER=$marker25"
pruefe_wahr Z-071 "datei" "agent_type, der ueber name: aufzuloesen ist und nicht ueber den Dateinamen" \
  "die Attrappe von make dod verzeichnet keinen Aufruf" \
  "$([ ! -e "$marker25" ] && echo 1 || echo 0)" \
  "keine Markerdatei" "$([ -e "$marker25" ] && echo "Markerdatei besteht" || echo "keine Markerdatei")"
pruefe_rc Z-072 "agent_type, der ueber name: aufzuloesen ist" 0

}

# --- Z-073/074: unbekannter agent_type -> Kette laeuft (roter Lauf) -------
fall_z073_074() {
baum=$(neuer_mock_baum)
m1=$(marken_zeile K1 D3 linter A_FAIL "" "" 2)
ausgabe=$(bauen_ausgabe "$baum" "$m1" "$D19_OK" "make dod: abgebrochen bei D3 linter, Rueckgabewert 2.")
zustand26a=$(neu_verzeichnis)
marker26a=$(neu_verzeichnis)/marker
eingabe26a=$(baue_eingabe "SubagentStop" "$baum" "fall26a" "false" "a1" "voellig-unbekannte-rolle")
rufe_gate "$eingabe26a" "$zustand26a" "$WERKZEUGKASTEN_VOLL" "CLAUDE_PROJECT_DIR=$baum" "MOCK_AUSGABE=$ausgabe" "MOCK_RC=2" "MOCK_MARKER=$marker26a"
pruefe_wahr Z-073 "datei" "SubagentStop mit unbekanntem agent_type" \
  "die Attrappe von make dod verzeichnet einen Aufruf" \
  "$([ -e "$marker26a" ] && echo 1 || echo 0)" \
  "Markerdatei besteht" "$([ -e "$marker26a" ] && echo "Markerdatei besteht" || echo "keine Markerdatei")"
pruefe_rc Z-074 "SubagentStop mit unbekanntem agent_type" 2

}

# --- Z-075/076: leerer agent_type -> Kette laeuft (roter Lauf) ------------
fall_z075_076() {
baum=$(neuer_mock_baum)
m1=$(marken_zeile K1 D3 linter A_FAIL "" "" 2)
ausgabe=$(bauen_ausgabe "$baum" "$m1" "$D19_OK" "make dod: abgebrochen bei D3 linter, Rueckgabewert 2.")
zustand26b=$(neu_verzeichnis)
marker26b=$(neu_verzeichnis)/marker
eingabe26b=$(baue_eingabe "SubagentStop" "$baum" "fall26b" "false" "a1" "")
rufe_gate "$eingabe26b" "$zustand26b" "$WERKZEUGKASTEN_VOLL" "CLAUDE_PROJECT_DIR=$baum" "MOCK_AUSGABE=$ausgabe" "MOCK_RC=2" "MOCK_MARKER=$marker26b"
pruefe_wahr Z-075 "datei" "SubagentStop mit leerem agent_type" \
  "die Attrappe von make dod verzeichnet einen Aufruf" \
  "$([ -e "$marker26b" ] && echo 1 || echo 0)" \
  "Markerdatei besteht" "$([ -e "$marker26b" ] && echo "Markerdatei besteht" || echo "keine Markerdatei")"
pruefe_rc Z-076 "SubagentStop mit leerem agent_type" 2

}

# --- Z-077/078: mehrdeutiger agent_type (zwei Treffer) -> roter Lauf -----
fall_z077_078() {
baum=$(neuer_mock_baum)
m1=$(marken_zeile K1 D3 linter A_FAIL "" "" 2)
ausgabe=$(bauen_ausgabe "$baum" "$m1" "$D19_OK" "make dod: abgebrochen bei D3 linter, Rueckgabewert 2.")
cp "$baum/.claude/agents/attrappe-schreiber.md" "$baum/.claude/agents/zweite-kopie.md"
git -C "$baum" add -A
git -C "$baum" commit -q -m "mehrdeutiger agent_type"
zustand26c=$(neu_verzeichnis)
marker26c=$(neu_verzeichnis)/marker
eingabe26c=$(baue_eingabe "SubagentStop" "$baum" "fall26c" "false" "a1" "attrappe-schreiber")
rufe_gate "$eingabe26c" "$zustand26c" "$WERKZEUGKASTEN_VOLL" "CLAUDE_PROJECT_DIR=$baum" "MOCK_AUSGABE=$ausgabe" "MOCK_RC=2" "MOCK_MARKER=$marker26c"
pruefe_wahr Z-077 "datei" "SubagentStop mit mehrdeutigem agent_type" \
  "die Attrappe von make dod verzeichnet einen Aufruf" \
  "$([ -e "$marker26c" ] && echo 1 || echo 0)" \
  "Markerdatei besteht" "$([ -e "$marker26c" ] && echo "Markerdatei besteht" || echo "keine Markerdatei")"
pruefe_rc Z-078 "SubagentStop mit mehrdeutigem agent_type" 2

echo
echo "--- Flacher Klon (G16) -----------------------------------------------"
echo

}

# --- Z-079/080: ein .git/shallow im Scheinbaum, kein echter Netz-Klon -----
fall_z079_080() {
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
ausgabe79_stdout=$(mktemp)
ausgabe79_stderr=$(mktemp)
make -s -C "$scheinbaum_klon" belege >"$ausgabe79_stdout" 2>"$ausgabe79_stderr"
rc79=$?
# Nachschaerfung Mutationsprobe (6.12.26 b): die bisherige Messung rief nur
# "make belege" direkt auf und pruefte dessen Rueckgabewert -- das GATE
# (dod-gate.sh) lief dabei gar nicht, die Mutation an dessen Zweig fuer die
# ungedeckte Lage C ("Selbstpruefung 1: kein Eintrag fuer diesen Schritt")
# hatte deshalb keinen Beruehrungspunkt mit dieser Zusicherung. Die
# Tabellenzeile (6.12.19) nennt die Mutation ausdruecklich als Verhalten
# DES GATES; gemessen wird deshalb jetzt der GATE-Aufruf selbst, mit einer
# Marke, die exakt die Lage nachbildet, die "make belege" fuer einen
# flachen Klon tatsaechlich meldet (D20 belege, Lage C, FEHLT=git-historie,
# siehe Makefile-Zielrezept "belege"), gegen eine LEERE Liste terminierter
# Lagen C -- also ungedeckt.
baum79=$(neuer_mock_baum)
m1_79=$(marken_zeile K1 D20 belege C git-historie "" 2)
ausgabe79g=$(bauen_ausgabe "$baum79" "$m1_79" "$D19_OK" "make dod: alle 1 Kettenschritte durchlaufen, 1 davon ohne Urteil (Lage C): D20 belege FEHLT=git-historie, Rueckgabewert 2.")
lauf "$baum79" Stop "fall79-gate" "$ausgabe79g" 2
pruefe_rc Z-079 "Flacher Klon" 2
# Item 3 (Runde 6): empirisch geprueft -- das GATE selbst (dod-gate.sh) gegen
# denselben flachen Klon aufgerufen (mit .claude/hooks/dod-gate-terminierte-
# lagen.txt im Scheinbaum) meldet in seiner EIGENEN Fehlerausgabe nur
# "FEHLT=git-historie" und "naechster Schritt: git-historie beschaffen",
# NIE den Wortlaut "git fetch --unshallow" -- den nennt ausschliesslich die
# Kette selbst (Makefile-Zeile 'echo "Beschaffen: git fetch --unshallow"').
# Tabelle 6.12.19 traegt fuer Z-080 seit ADR 0002, 6.12.26 e (Entscheid 1)
# den Kanal kette; gemessen wird die Fehlerausgabe des DIREKTEN
# Kettenaufrufs ueber pruefe_kette_wahr.
gehalt80=0
grep -qF "git fetch --unshallow" "$ausgabe79_stderr" && gehalt80=1
pruefe_kette_wahr Z-080 "Flacher Klon" "die Fehlerausgabe des DIREKTEN Kettenaufrufs (nicht die Standardausgabe) nennt 'git fetch --unshallow'" \
  "$gehalt80" "1 (enthalten in stderr des direkten Kettenaufrufs)" "$gehalt80"
rm -f "$ausgabe79_stdout" "$ausgabe79_stderr"

echo
echo "--- Baumbestimmung ueber show-toplevel (6.12.13, B-02/B-03/DT-B5) -----"
echo

}

# --- Z-081..Z-095: fuenf Varianten von cwd, je rc0/stdout-leer/Baumzeile --
fall_z081_095() {
g12_pruefen() {
  local beschreibung="$1" cwd_wert="$2" proj_wert="$3" erwartete_wurzel="$4"
  local z_baum="$5" z_rc="$6" z_stdout="$7"
  local m1 ausgabe zustand eingabe
  m1=$(marke K1 D20 belege A_OK)
  ausgabe=$(bauen_ausgabe "$erwartete_wurzel" "$m1 (rueckgabewert=0)" "$D19_OK" "make dod: alle 1 Kettenschritte durchlaufen, keiner ungleich 0, 1 gueltige Marken gezaehlt.")
  zustand=$(neu_verzeichnis)
  eingabe=$(baue_eingabe "Stop" "$cwd_wert" "fall-g12-$beschreibung")
  rufe_gate "$eingabe" "$zustand" "$WERKZEUGKASTEN_VOLL" "CLAUDE_PROJECT_DIR=$proj_wert" "MOCK_AUSGABE=$ausgabe" "MOCK_RC=0"
  pruefe_rc "$z_rc" "$beschreibung" 0
  pruefe_stdout_leer "$z_stdout" "$beschreibung"
  # Item 1 (Runde 6): die bisherige indirekte Messung (rc 0, stderr leer)
  # entfaellt fuer den Kanal "kette" -- sie belegte nur die Abwesenheit
  # eines Widerspruchs, nicht den tatsaechlich erreichten Baum. Gemessen
  # wird jetzt der DIREKTE Aufruf der Attrappenkette mit derselben
  # Baumbestimmung, die dod-gate.sh selbst verwendet.
  # S7-04/DT7-04: fuer den Symlink-Fall wird $z_baum leer uebergeben --
  # die allgemeine Messung ueber kette_direkt_aufrufen loest den Baum vor
  # dem make-Aufruf physisch auf und kann die dortige Mutation nicht sehen
  # (siehe Kommentar bei der "gesonderten Nachmessung" unten); nur DIESE
  # eine, spezifischere Messung traegt dort die Kennung Z-089. Eine leere
  # Kennung meldet nichts -- sonst traegt dieselbe Kennung zwei Meldungen
  # und die Schlusszahl weicht von der Zahl der Tabellenkennungen ab.
  if [ -n "$z_baum" ]; then
    local _kdz _erste _erwartet
    _kdz=$(kette_direkt_aufrufen "$cwd_wert" "$proj_wert" "$erwartete_wurzel")
    _erste="${_kdz%|*}"
    _erwartet="${_kdz##*|}"
    pruefe_kette_zeile "$z_baum" "$beschreibung" \
      "Direkter Aufruf der Attrappenkette (Ziel dod-baum-direkt) meldet die physisch aufgeloeste erwartete Wurzel" \
      "$_erwartet" "$_erste"
  fi
  }

baum=$(neuer_mock_baum)
mkdir -p "$baum/ein/unterverzeichnis"
g12_pruefen "cwd in einem Unterverzeichnis des Baums, gruener Scheinbaum" "$baum/ein/unterverzeichnis" "$baum" "$baum" Z-083 Z-081 Z-082

baum=$(neuer_mock_baum)
g12_pruefen "cwd mit Schraegstrich am Ende, gruener Scheinbaum" "$baum/" "$baum/" "$baum" Z-086 Z-084 Z-085

baum=$(neuer_mock_baum)
symlink_verz=$(neu_verzeichnis)
ln -s "$baum" "$symlink_verz/verweis"
g12_pruefen "cwd ueber einen Symlink auf den Baum, gruener Scheinbaum" "$symlink_verz/verweis" "$symlink_verz/verweis" "$baum" "" Z-087 Z-088
# Z-089, gesonderte Nachmessung (Kontrolle des Koordinators, Punkt (a)): die
# allgemeine Messung oben ueber kette_direkt_aufrufen loest den Baum ZUERST
# physisch auf (_kette_baum_direkt endet mit "pwd -P" bzw. "git
# rev-parse"), bevor sie make aufruft -- der Symlink ist zu diesem Zeitpunkt
# schon verschwunden, make wird ausserdem mit "-C <physischer Pfad>"
# aufgerufen, was den Symlink kein zweites Mal einfuehrt. Die Mutation an der
# PROJ-Herleitung (pwd -L statt pwd -P, dod-gate.sh Zeile ~896 betrifft sie
# nicht -- das ist die Makefile-Zeile "PROJ := $(shell cd ... && pwd -P)")
# hat unter "-C" deshalb keinen erreichbaren Effekt: "cd '.' && pwd -L"
# faellt in einer NEUEN Shell ohne symlinktragendes $PWD sofort auf den
# physischen Pfad zurueck, identisch zu "pwd -P" (empirisch geprueft). Nur
# ein BARER Aufruf -- ein "cd" in eine Shell, die den Symlink noch als $PWD
# traegt (kein "-C"), dann "make -f ..." -- laesst PROJ tatsaechlich ueber
# den Symlinkpfad rechnen, wenn die Mutation greift.
satellit89="$baum/.dod-baum-zeile-z089.mk"
_kette_satellit_schreiben "$satellit89"
zeile89=$( (cd "$symlink_verz/verweis" && PATH="$WERKZEUGKASTEN_VOLL" make -s -f "$(basename "$satellit89")" dod-baum-zeile) 2>/dev/null | head -n1)
rm -f "$satellit89"
pruefe_kette_zeile Z-089 "cwd ueber einen Symlink auf den Baum, BARER Aufruf (kein -C)" \
  "Bare 'cd' in den Symlink, dann 'make -f ...' (kein -C): die Baumzeile nennt die physisch aufgeloeste Wurzel, nicht den Pfad ueber den Symlink" \
  "make dod: geprueft wird $baum." "$zeile89"

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
  pruefe_rc Z-094 "Zweiter Arbeitsbaum (git worktree), cwd darin" 0
  pruefe_stdout_leer Z-095 "Zweiter Arbeitsbaum (git worktree), cwd darin"
  # Item 1 (Runde 6): direkter Aufruf der Attrappenkette statt der
  # bisherigen indirekten Messung -- siehe g12_pruefen weiter oben.
  worktree_kdz=$(kette_direkt_aufrufen "$worktree_wurzel" "$baum" "$worktree_wurzel")
  worktree_erste="${worktree_kdz%|*}"
  worktree_erwartet="${worktree_kdz##*|}"
  pruefe_kette_zeile Z-093 "Zweiter Arbeitsbaum (git worktree), cwd darin" \
    "Direkter Aufruf der Attrappenkette meldet den zweiten Baum (worktree), nicht den Hauptbaum" \
    "$worktree_erwartet" "$worktree_erste"
else
  echo "HINWEIS  Zweiter Arbeitsbaum (worktree): 'git worktree add' ist in dieser Umgebung fehlgeschlagen -- Z-093 bis Z-095 bleiben ungemessen und werden von der Deckungspruefung genannt."
fi

echo
echo "--- Baumzeile falsch bzw. fehlend (S-03/S-10) --------------------------"
echo

}

# --- Z-096/097: Baumzeile nennt einen ANDEREN Baum ------------------------
fall_z096_097() {
baum=$(neuer_mock_baum)
anderer_baum_s03=$(neu_verzeichnis)
m1=$(marken_zeile K1 D20 belege A_OK "" "" 0)
ausgabe_s03=$(bauen_ausgabe "$anderer_baum_s03" "$m1" "$D19_OK" "make dod: alle 1 Kettenschritte durchlaufen, keiner ungleich 0, 1 gueltige Marken gezaehlt.")
zustand_s03=$(neu_verzeichnis)
lauf_mit_zustand "$zustand_s03" "$baum" Stop "fall-s03" "$ausgabe_s03" 0
pruefe_rc Z-096 "Baumzeile nennt einen anderen Baum" 2
pruefe_zaehler_schluessel Z-097 "Baumzeile nennt einen anderen Baum" \
  "$(zaehler_pfad "$zustand_s03" "fall-s03")" "KETTE baum-widerspruch"

}

# --- Z-144/145: Baumzeile fehlt GANZ ---------------------------------------
fall_z144_145() {
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

}

# --- Z-098..Z-100: rote Kette ----------------------------------------------
fall_z098_100() {
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
pruefe_stderr_wahr Z-100 "Weder XDG_STATE_HOME noch HOME gesetzt, rote Kette" \
  "der Zusatz sagt 'nicht bestimmbar' und nicht 'nicht beschreibbar'" \
  "$([ "$enthaelt_bestimmbar100" -eq 1 ] && [ "$enthaelt_beschreibbar100" -eq 0 ] && echo 1 || echo 0)" \
  "'nicht bestimmbar' vorhanden, 'nicht beschreibbar' nicht" "bestimmbar=$enthaelt_bestimmbar100, beschreibbar=$enthaelt_beschreibbar100"

}

# --- Z-101..Z-103: gruene Kette ---------------------------------------------
fall_z101_103() {
baum=$(neuer_mock_baum)
m1=$(marken_zeile K1 D20 belege A_OK "" "" 0)
ausgabe_b01g=$(bauen_ausgabe "$baum" "$m1" "$D19_OK" "make dod: alle 1 Kettenschritte durchlaufen, keiner ungleich 0, 1 gueltige Marken gezaehlt.")
eingabe_b01g=$(baue_eingabe "Stop" "$baum" "fall-b01-gruen")
rufe_gate_ohne_home "$eingabe_b01g" "$WERKZEUGKASTEN_VOLL" "CLAUDE_PROJECT_DIR=$baum" "MOCK_AUSGABE=$ausgabe_b01g" "MOCK_RC=0"
pruefe_rc_wahr Z-101 "Weder XDG_STATE_HOME noch HOME gesetzt, gruene Kette" \
  "Rueckgabewert 0 -- nie 1" "$([ "$G_RC" = "0" ] && echo 1 || echo 0)" "rc=0" "rc=$G_RC"
pruefe_json_einzelfeld Z-102 "Weder XDG_STATE_HOME noch HOME gesetzt, gruene Kette" systemMessage
enthaelt_bestimmbar103=0
printf '%s' "$G_STDOUT" | grep -qF "nicht bestimmbar" && enthaelt_bestimmbar103=1
pruefe_stdout_wahr Z-103 "Weder XDG_STATE_HOME noch HOME gesetzt, gruene Kette" \
  "der Zusatz sagt 'nicht bestimmbar'" "$enthaelt_bestimmbar103" "1 (enthalten)" "$enthaelt_bestimmbar103"

echo
echo "--- TMPDIR zeigt in den geprueften Baum (6.12.25 c, DT3-B1) -----------"
echo

}

# --- Z-109/110/111: eigene Wegwerfdatei ausserhalb, D19 bleibt sauber, kein
#     Beobachtungsfenster im Baum -------------------------------------------
fall_z109_111() {
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
  if [ -n "${SELBSTTEST_SPERRE_FD:-}" ]; then exec {SELBSTTEST_SPERRE_FD}>&- 2>/dev/null || true; fi
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
pruefe_wahr Z-109 "beobachter" "TMPDIR zeigt in den geprueften Baum" \
  "der physisch aufgeloeste Pfad der Wegwerfdatei liegt ausserhalb des geprueften Baums" \
  "$ausserhalb109" "ausserhalb von $baum" "kette_eigene_tmp=$kette_eigene_tmp"
# Z-110 ist am 2026-09-03 zurueckgezogen (6.12.25 h, Befund S4-02): im
# Attrappenaufbau ist "D19 meldet OHNE_BEFUND" nicht messbar, weil die
# D19-Zeile aus der vom Selbsttest selbst geschriebenen Attrappenausgabe
# stammt -- gemessen wuerde die eigene Vorgabe. Keine Pruefung mehr; die
# Deckungspruefung nimmt die Kennung als zurueckgezogen aus.
pruefe_wahr Z-111 "beobachter" "TMPDIR zeigt in den geprueften Baum" \
  "ein Beobachter ohne Wartezeit findet waehrend des gesamten Laufs im ganzen geprueften Baum (alle Verzeichnisse ausser .git) keine Datei mit dem Muster tmp.*" \
  "$([ "$treffer_anzahl" = "0" ] && echo 1 || echo 0)" "0 Treffer" "$treffer_anzahl Treffer"

echo
echo "--- Wegwerfdatei ausserhalb des Baums nicht anlegbar (Entscheid f) -----"
echo

}

# --- Z-112/113: erster mktemp-Aufruf im Baum, "-p /tmp" schlaegt fehl -----
fall_z112_113() {
baum=$(neuer_mock_baum)
m1=$(marken_zeile K1 D20 belege A_OK "" "" 0)
ausgabe=$(bauen_ausgabe "$baum" "$m1" "$D19_OK" "make dod: alle 1 Kettenschritte durchlaufen, keiner ungleich 0, 1 gueltige Marken gezaehlt.")
zustand_mktemp=$(neu_verzeichnis)
eingabe_mktemp=$(baue_eingabe "Stop" "$baum" "fall-mktemp-gate")
# Mutationsprobe (6.12.26 b): TMPDIR zeigt hier absichtlich auf ein eigenes
# Verzeichnis AUSSERHALB von /tmp (woertlich) und ausserhalb von $baum, damit
# der ERSTE mktemp-Aufruf (Zeile 707) NICHT sofort ueber die Sonderpruefung
# "-p /tmp" der Attrappe scheitert, sondern (ueber FAKE_MKTEMP_ZIEL) im Baum
# landet und so den Ausweichpfad (Zeile 730 ff., Ruecksprung auf "mktemp -p
# /tmp" in Zeile 733) tatsaechlich durchlaeuft. Ohne diese Umleitung faellt
# das Gate schon bei der ERSTEN Anlegung (Zeile 707-709) mit demselben
# Schluessel "GATE mktemp" ab -- der Ausweichpfad in Zeile 733 bliebe
# unerreicht, und eine Mutation dort waere durch diese Zusicherung nicht
# feststellbar.
tmpdir_ausserhalb_112=$(neu_verzeichnis)
rufe_gate "$eingabe_mktemp" "$zustand_mktemp" "$WERKZEUGKASTEN_FAKE_MKTEMP" "CLAUDE_PROJECT_DIR=$baum" "MOCK_AUSGABE=$ausgabe" "MOCK_RC=0" "FAKE_MKTEMP_ZIEL=$baum" "TMPDIR=$tmpdir_ausserhalb_112"
pruefe_rc Z-112 "Wegwerfdatei ausserhalb des Baums nicht anlegbar" 2
pruefe_zaehler_schluessel Z-113 "Wegwerfdatei ausserhalb des Baums nicht anlegbar" \
  "$(zaehler_pfad "$zustand_mktemp" "fall-mktemp-gate")" "GATE mktemp"

echo
echo "--- Verzeichnis der Wegwerfdatei physisch nicht aufloesbar (6.12.25 d) -"
echo

}

# --- Z-114/115 (Runde 3, S3-05) --------------------------------------------
fall_z114_115() {
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

}

# --- Z-122/123/124 (Entscheid h; Z-124 Fall und Mutation praezisiert 6.12.26 f,
# Runde 7, S7-02) --------------------------------------------------------
fall_z122_124() {
baum=$(neuer_mock_baum)
mkdir -p "$baum/scripts"
: > "$baum/scripts/abnahme-abgleich.sh"
git -C "$baum" add -A
git -C "$baum" commit -q -m "artefakt entstanden"
# ZWEI fehlerhafte Zeilen mit VERSCHIEDENEN Selbstpruefungen (2 und 6), damit
# die Mutation (Abbruchanweisungen der Strukturpruefung entfernt) trennscharf
# ist: beide Verletzungen werden VOR der Wache "if [ -n "$terminiert_fehler" ]"
# geprueft (Zeilen 613-651 in dod-gate.sh, unbedingt je Zeile ausgewertet),
# unabhaengig vom Zustand einer vorangegangenen Zeile -- anders als eine
# Verletzung der Selbstpruefung 4, die HINTER der Wache liegt und deshalb bei
# entfernter Abbruchanweisung der ERSTEN Zeile nie erreicht wuerde.
printf 'D7 abnahme|scripts/abnahme-abgleich.sh\tADR 0002, 6.12.5, Selbsttest.\nD9 rueckkanal ohne tabulator\n' \
  > "$baum/.claude/hooks/dod-gate-terminierte-lagen.txt"
marker_liste=$(neu_verzeichnis)/marker
zustand_liste=$(neu_verzeichnis)
eingabe_liste=$(baue_eingabe "Stop" "$baum" "fall-liste-drei")
rufe_gate "$eingabe_liste" "$zustand_liste" "$WERKZEUGKASTEN_VOLL" "CLAUDE_PROJECT_DIR=$baum" "MOCK_AUSGABE=darf nie gelesen werden" "MOCK_RC=0" "MOCK_MARKER=$marker_liste"
pruefe_rc Z-122 "Liste mit zwei fehlerhaften Zeilen, die verschiedene Selbstpruefungen (2 und 6) verletzen" 2
pruefe_wahr Z-123 "datei" "Liste mit zwei fehlerhaften Zeilen (Selbstpruefungen 2 und 6)" \
  "die Attrappe von make dod verzeichnet keinen Aufruf -- geblockt wird vor dem Lauf der Kette" \
  "$([ ! -e "$marker_liste" ] && echo 1 || echo 0)" \
  "keine Markerdatei" "$([ -e "$marker_liste" ] && echo "Markerdatei besteht" || echo "keine Markerdatei")"
zaehler_datei_liste="$zustand_liste/r3cosint/dod-gate/zaehler-$(printf '%s' 'fall-liste-drei' | sha256sum | cut -d' ' -f1)"
pruefe_zaehler_schluessel Z-124 "Liste mit zwei fehlerhaften Zeilen, die verschiedene Selbstpruefungen (2 und 6) verletzen" \
  "$zaehler_datei_liste" "LISTE 2 D7 abnahme"

echo
echo "--- D12 mit mehreren fehlenden Gegenstaenden (N-08) ---------------------"
echo

}

# --- Z-130: D12 in Lage C mit mehreren fehlenden Gegenstaenden -------------
fall_z130() {
# ADR 0002, 6.12.26 e (Entscheid 1) und f (Punkte 8 und 13): die Marke von
# D12 mit FEHLT=scripts/nachweise-erzeugen.sh ist nur auf der DIREKT
# aufgerufenen Kettenausgabe (echtes Makefile, Ziel nachweise) Gegenstand --
# eine Mutation am GATE (dessen Markenauswertung) ist auf diesem Kanal
# unerkennbar, weil der direkte Kettenaufruf die Markenauswertung des Gates
# nie durchlaeuft. Die Mutation liegt deshalb am MAKEFILE selbst (der Wache
# vor dem zweiten fehlenden Gegenstand von D12, scripts/nachweise-
# vollstaendig.sh); Kanal "kette". $ECHTES_MAKEFILE ist im Mutationsmodus die
# mutierte KOPIE -- sie wird deshalb in den Scheinbaum kopiert, damit PROJ
# ueber MAKEFILE_LIST auf den Scheinbaum zeigt, nicht auf die echte Wurzel.
baum130=$(neuer_mock_baum)
cp "$ECHTES_MAKEFILE" "$baum130/Makefile.echt"
kette130=$(PATH="$WERKZEUGKASTEN_VOLL" make -s -C "$baum130" -f Makefile.echt nachweise 2>/dev/null || true)
marke130=$(printf '%s\n' "$kette130" | grep -F '::LAGE ' | grep -F ' D12 nachweise ' | head -n1)
richtig130=0; printf '%s' "$marke130" | grep -qF ' D12 nachweise C FEHLT=scripts/nachweise-erzeugen.sh' && richtig130=1
falsch130=0; printf '%s' "$marke130" | grep -qF 'FEHLT=scripts/nachweise-vollstaendig.sh' && falsch130=1
pruefe_kette_wahr Z-130 "D12 in Lage C mit mehreren fehlenden Gegenstaenden" \
  "die direkt aufgerufene Kettenausgabe (echtes Makefile, Ziel nachweise, im Scheinbaum ohne scripts/nachweise-erzeugen.sh und ohne scripts/nachweise-vollstaendig.sh) nennt in der Marke von D12 als FEHLT=-Wert den ersten Gegenstand scripts/nachweise-erzeugen.sh" \
  "$([ "$richtig130" -eq 1 ] && [ "$falsch130" -eq 0 ] && echo 1 || echo 0)" \
  "Marke mit ' D12 nachweise C FEHLT=scripts/nachweise-erzeugen.sh'" "Marke='$(_kuerzen "$marke130")'"
rm -f "$baum130/Makefile.echt"

echo
echo "--- Kette ruft selbst mktemp auf: eigene Wegwerfdatei ausserhalb (DT2-B2)"
echo

}

# --- Z-131/132 (ADR 0002, 6.12.26 f, Entscheid 5): der frueher hier
#     genutzte Beobachter (vorher/nachher-find im Baum) wies nur nach, dass
#     KEINE neue Datei im Baum entsteht -- er belegte nicht, WELCHES TMPDIR
#     die Kette ERHALTEN hat. Z-131 misst jetzt das AUFRUFPROTOKOLL der
#     Attrappe (was make dod an TMPDIR uebergeben bekam), Z-132 weiterhin die
#     SPUR (was die Kette aus diesem TMPDIR selbst gemacht hat, ueber ihre
#     eigene mktemp-Datei) -- beide Kanal "datei", kein Beobachter mehr. ----
fall_z131_132() {
baum=$(neuer_mock_baum)
m1=$(marken_zeile K1 D20 belege A_OK "" "" 0)
ausgabe=$(bauen_ausgabe "$baum" "$m1" "$D19_OK" "make dod: alle 1 Kettenschritte durchlaufen, keiner ungleich 0, 1 gueltige Marken gezaehlt.")
zustand_dtb2=$(neu_verzeichnis)
spur_dtb2=$(neu_verzeichnis)/spur
protokoll_dtb2=$(neu_verzeichnis)/aufrufprotokoll
eingabe_dtb2=$(baue_eingabe "Stop" "$baum" "fall-dtb2")
rufe_gate "$eingabe_dtb2" "$zustand_dtb2" "$WERKZEUGKASTEN_VOLL" "CLAUDE_PROJECT_DIR=$baum" "MOCK_AUSGABE=$ausgabe" "MOCK_RC=0" "MOCK_TMP_SPUR=$spur_dtb2" "MOCK_AUFRUFPROTOKOLL=$protokoll_dtb2" "TMPDIR=$baum"
tmpdir_uebergeben_dtb2=$(sed -n 's/^TMPDIR=//p' "$protokoll_dtb2" 2>/dev/null | head -n1)
uebergeben_ausserhalb_dtb2=0
case "$tmpdir_uebergeben_dtb2" in
  ""|"$baum"|"$baum"/*) ;;
  *) uebergeben_ausserhalb_dtb2=1 ;;
esac
pruefe_wahr Z-131 "datei" "TMPDIR in den Baum, und die Kette selbst legt eine Wegwerfdatei an" \
  "das im Aufrufprotokoll der Attrappe verzeichnete, an make dod uebergebene TMPDIR liegt ausserhalb des geprueften Baums" \
  "$uebergeben_ausserhalb_dtb2" "TMPDIR ausserhalb von $baum" "Aufrufprotokoll: TMPDIR=$tmpdir_uebergeben_dtb2"
kette_eigene_tmp_dtb2=$(cat "$spur_dtb2" 2>/dev/null || true)
spur_ausserhalb_dtb2=0
case "$kette_eigene_tmp_dtb2" in
  ""|"$baum"|"$baum"/*) ;;
  *) spur_ausserhalb_dtb2=1 ;;
esac
pruefe_wahr Z-132 "datei" "TMPDIR in den Baum, Kette legt selbst an" \
  "die Spurdatei der Attrappenkette (Pfad ihrer eigenen mktemp-Datei) liegt ausserhalb des geprueften Baums -- die Kette selbst sieht die Umlenkung" \
  "$spur_ausserhalb_dtb2" "Spur ausserhalb von $baum" "Spur=$kette_eigene_tmp_dtb2"

echo
echo "--- Markenzahl gegen die Schlusszeile selbst (S-11, 6.12.24 k; S3-02) -"
echo

}

# --- Z-133/134: Form 1 behauptet 14 Marken, die Uebersicht traegt KEINE ---
fall_z133_134() {
baum=$(neuer_mock_baum)
# 6.12.26 f (Runde 7, S7-02): Schlusszeile Form 1 nennt "0 gueltige Marken
# gezaehlt" bei tatsaechlich 0 gelesenen Marken -- gelesene und genannte Zahl
# stimmen ueberein, sodass allein der Disjunkt "marken_anzahl -eq 0" den
# Block traegt (der zweite Disjunkt, "-ne schluss_marken_erwartet", ist bei
# 0 gegen 0 falsch und traegt hier nichts).
ausgabe_s11a=$(printf 'make dod: geprueft wird %s.\n=== Uebersicht Definition-of-Done-Kette (make dod) ===\n\nmake dod: D19: %s\nmake dod: alle 0 Kettenschritte durchlaufen, keiner ungleich 0, 0 gueltige Marken gezaehlt.\n' "$baum" "$D19_OK")
zustand_s11a=$(neu_verzeichnis)
eingabe_s11a=$(baue_eingabe "Stop" "$baum" "fall-s11a")
rufe_gate "$eingabe_s11a" "$zustand_s11a" "$WERKZEUGKASTEN_VOLL" "CLAUDE_PROJECT_DIR=$baum" "MOCK_AUSGABE=$ausgabe_s11a" "MOCK_RC=0"
pruefe_rc Z-133 "Baumzeile, Form-1-Schlusszeile, D19 OHNE_BEFUND, Rueckgabewert 0 und null Marken" 2
zaehler_datei_s11a="$zustand_s11a/r3cosint/dod-gate/zaehler-$(printf '%s' 'fall-s11a' | sha256sum | cut -d' ' -f1)"
pruefe_zaehler_schluessel Z-134 "Form-1-Schlusszeile mit null Marken" \
  "$zaehler_datei_s11a" "KETTE ausgabe-unlesbar"

}

# --- Z-135/136: Form 1 behauptet 3 Marken, die Uebersicht traegt nur EINE -
fall_z135_136() {
baum=$(neuer_mock_baum)
m1=$(marken_zeile K1 D20 belege A_OK "" "" 0)
ausgabe_s11b=$(bauen_ausgabe "$baum" "$m1" "$D19_OK" "make dod: alle 3 Kettenschritte durchlaufen, keiner ungleich 0, 3 gueltige Marken gezaehlt.")
zustand_s11b=$(neu_verzeichnis)
eingabe_s11b=$(baue_eingabe "Stop" "$baum" "fall-s11b")
rufe_gate "$eingabe_s11b" "$zustand_s11b" "$WERKZEUGKASTEN_VOLL" "CLAUDE_PROJECT_DIR=$baum" "MOCK_AUSGABE=$ausgabe_s11b" "MOCK_RC=0"
pruefe_rc Z-135 "Schlusszeile Form 1 nennt eine andere Zahl, als Marken gelesen wurden" 2
zaehler_datei_s11b=$(zaehler_pfad "$zustand_s11b" "fall-s11b")
pruefe_zaehler_schluessel Z-136 "Schlusszeile Form 1 mit abweichender Zahl" \
  "$zaehler_datei_s11b" "KETTE ausgabe-unlesbar"

}

# --- Z-137/138: Form 2 (teilweise, mit gedeckter Lage C) abweichende Zahl -
fall_z137_138() {
baum=$(neuer_mock_baum)
printf 'D7 abnahme|scripts/abnahme-abgleich.sh\tADR 0002, 6.12.5, Selbsttest.\n' > "$baum/.claude/hooks/dod-gate-terminierte-lagen.txt"
m1=$(marken_zeile K1 D20 belege A_OK "" "" 0)
m2=$(marken_zeile K1 D7 abnahme C scripts/abnahme-abgleich.sh "" 2)
ausgabe_f2=$(bauen_ausgabe "$baum" "$m1
$m2" "$D19_OK" "make dod: alle 5 Kettenschritte durchlaufen, 1 davon ohne Urteil (Lage C): D7 abnahme FEHLT=scripts/abnahme-abgleich.sh, Rueckgabewert 2.")
zustand_f2=$(neu_verzeichnis)
eingabe_f2=$(baue_eingabe "Stop" "$baum" "fall-f2-abweichend")
rufe_gate "$eingabe_f2" "$zustand_f2" "$WERKZEUGKASTEN_VOLL" "CLAUDE_PROJECT_DIR=$baum" "MOCK_AUSGABE=$ausgabe_f2" "MOCK_RC=2"
pruefe_rc Z-137 "Schlusszeile Form 2 nennt eine andere Zahl, als Marken gelesen wurden" 2
zaehler_datei_f2=$(zaehler_pfad "$zustand_f2" "fall-f2-abweichend")
pruefe_zaehler_schluessel Z-138 "Schlusszeile Form 2 mit abweichender Zahl" \
  "$zaehler_datei_f2" "KETTE ausgabe-unlesbar"

}

# --- Z-139/140: Form 4 (D19 VERLETZT/C) abweichende Zahl -------------------
fall_z139_140() {
baum=$(neuer_mock_baum)
m1=$(marken_zeile K1 D20 belege A_OK "" "" 0)
ausgabe_f4=$(bauen_ausgabe "$baum" "$m1" "VERLETZT -- versionierter Bestand veraendert." "make dod: alle 5 Kettenschritte durchlaufen, Rahmenpruefung D19 VERLETZT, Rueckgabewert 2.")
zustand_f4=$(neu_verzeichnis)
eingabe_f4=$(baue_eingabe "Stop" "$baum" "fall-f4-abweichend")
rufe_gate "$eingabe_f4" "$zustand_f4" "$WERKZEUGKASTEN_VOLL" "CLAUDE_PROJECT_DIR=$baum" "MOCK_AUSGABE=$ausgabe_f4" "MOCK_RC=2"
pruefe_rc Z-139 "Schlusszeile Form 4 nennt eine andere Zahl, als Marken gelesen wurden" 2
zaehler_datei_f4=$(zaehler_pfad "$zustand_f4" "fall-f4-abweichend")
pruefe_zaehler_schluessel Z-140 "Schlusszeile Form 4 mit abweichender Zahl" \
  "$zaehler_datei_f4" "KETTE ausgabe-unlesbar"

}

# --- Z-141: Form 3 (Abbruch) -- wird NICHT auf die Zahl geprueft ----------
fall_z141() {
baum=$(neuer_mock_baum)
zustand_f3=$(neu_verzeichnis)
m1=$(marken_zeile K1 D20 belege A_OK "" "" 0)
m2=$(marken_zeile K1 D3 linter A_FAIL "" "" 2)
ausgabe_f3=$(bauen_ausgabe "$baum" "$m1
$m2" "$D19_OK" "make dod: abgebrochen bei D3 linter, Rueckgabewert 2.")
lauf_mit_zustand "$zustand_f3" "$baum" Stop "fall-f3-abweichend" "$ausgabe_f3" 2
# Item 4 (Runde 6): die Kennung war als Kanal "zaehler" gemeldet, aber gegen
# G_STDERR gemessen (Kanal "stderr") -- das ist der falsche Gegenstand fuer
# genau diese Behauptung ("der GEZAEHLTE Schluessel"). Gemessen wird jetzt
# direkt die Zaehlerdatei ueber pruefe_zaehler_schluessel.
pruefe_zaehler_schluessel Z-141 "Schlusszeile Form 3 (abgebrochen) mit abweichender Zahl" \
  "$(zaehler_pfad "$zustand_f3" "fall-f3-abweichend")" "D3 linter A_FAIL"

echo
echo "--- Wiederholtes GATE-Pruefmittel in derselben Sitzung (6.12.25 i) ----"
echo

}

# --- Z-146/147/148: das Verzeichnis der Wegwerfdatei ist physisch nicht
#     aufloesbar (Attrappe wie bei Z-114/115), zweimal in derselben Sitzung
#     -- der Schluessel "GATE mktemp" laeuft ueber dieselbe Zaehlung nach
#     6.12.9 wie jeder andere Block (6.12.25 i). Zaehlerdatei direkt lesen:
#     erste Zeile = Schluessel, zweite Zeile = Stand (siehe pruefe_zaehler*
#     oben). --------------------------------------------------------------
fall_z146_148() {
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
pruefe_zaehler_wahr Z-147 "Verzeichnis der Wegwerfdatei physisch nicht aufloesbar, erstes Ereignis" \
  "die Zaehlerdatei traegt Schluessel GATE mktemp und Stand 1" \
  "$([ "$schluessel_gm1" = "GATE mktemp" ] && [ "$stand_gm1" = "1" ] && echo 1 || echo 0)" \
  "GATE mktemp|1" "$schluessel_gm1|$stand_gm1"

rufe_gate "$eingabe_gm" "$zustand_gm" "$WERKZEUGKASTEN_FAKE_MKTEMP_UNAUFLOESBAR" "CLAUDE_PROJECT_DIR=$baum" "MOCK_AUSGABE=$ausgabe_gm" "MOCK_RC=0"
schluessel_gm2=$(sed -n '1p' "$zaehler_datei_gm" 2>/dev/null || true)
stand_gm2=$(sed -n '2p' "$zaehler_datei_gm" 2>/dev/null || true)
pruefe_zaehler_wahr Z-148 "Dasselbe Ausbleiben ein zweites Mal in derselben Sitzung" \
  "die Zaehlerdatei traegt Schluessel GATE mktemp und Stand 2" \
  "$([ "$schluessel_gm2" = "GATE mktemp" ] && [ "$stand_gm2" = "2" ] && echo 1 || echo 0)" \
  "GATE mktemp|2" "$schluessel_gm2|$stand_gm2"

}

# --- Z-149/150/151: fehlendes sha256sum, zweimal in derselben Sitzung -----
# dod-gate.sh (Zeilen ~193-214, Kommentar "N-09"): fehlt sha256sum, kann der
# uebliche gehashte Zaehler-Schluessel nicht gebildet werden -- die
# Zaehlerdatei traegt ersatzweise eine SANITIERTE Rohform von session_id
# (tr -c 'A-Za-z0-9_-' '_'), NICHT den Hash. "fall-gate-sha256sum" enthaelt
# nur bereits zulaessige Zeichen, die Sanitierung ist deshalb die Identitaet.
fall_z149_151() {
baum=$(neuer_mock_baum)
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
pruefe_zaehler_wahr Z-150 "Fehlendes sha256sum, erstes Ereignis" \
  "die Zaehlerdatei traegt Schluessel GATE sha256sum und Stand 1" \
  "$([ "$schluessel_gs1" = "GATE sha256sum" ] && [ "$stand_gs1" = "1" ] && echo 1 || echo 0)" \
  "GATE sha256sum|1" "$schluessel_gs1|$stand_gs1"

rufe_gate "$eingabe_gs" "$zustand_gs" "$WERKZEUGKASTEN_OHNE_SHA256SUM_GS" "CLAUDE_PROJECT_DIR=$baum" "MOCK_AUSGABE=x" "MOCK_RC=0"
schluessel_gs2=$(sed -n '1p' "$zaehler_datei_gs" 2>/dev/null || true)
stand_gs2=$(sed -n '2p' "$zaehler_datei_gs" 2>/dev/null || true)
pruefe_zaehler_wahr Z-151 "Fehlendes sha256sum, zweites Ereignis in derselben Sitzung" \
  "die Zaehlerdatei traegt Schluessel GATE sha256sum und Stand 2" \
  "$([ "$schluessel_gs2" = "GATE sha256sum" ] && [ "$stand_gs2" = "2" ] && echo 1 || echo 0)" \
  "GATE sha256sum|2" "$schluessel_gs2|$stand_gs2"

echo
echo "--- Zweiter Selbsttest waehrend gehaltener Sperre (6.12.25 j) ---------"
echo

}

# --- Z-152/153: dieses Skript haelt seine Sperre (SELBSTTEST_SPERRE_FD,
#     flock -n, exklusiv) seit dem eigenen Skriptbeginn und fuer die
#     GESAMTE Laufzeit -- ein Unterprozess, der denselben Selbsttest ein
#     zweites Mal aufruft, kann die Sperre also nicht erwerben und muss
#     sofort (rc 3, stderr) enden. -----------------------------------------
fall_z152_153() {
zeit_start152=$(date +%s%N)
zweiter_stdout152=$(mktemp)
zweiter_stderr152=$(mktemp)
timeout 10 "$BASH_BIN" "$SKRIPT_VERZEICHNIS/dod-gate-selbsttest.sh" >"$zweiter_stdout152" 2>"$zweiter_stderr152"
zweiter_rc152=$?
zeit_ende152=$(date +%s%N)
dauer_ms152=$(( (zeit_ende152 - zeit_start152) / 1000000 ))
pruefe_wahr Z-152 "selbsttest+dauer" "Zweiter Selbsttest, gestartet waehrend der erste die Sperre haelt" \
  "der zweite Aufruf endet innerhalb von 5 s mit Rueckgabewert 3" \
  "$([ "$zweiter_rc152" = "3" ] && [ "$dauer_ms152" -lt 5000 ] && echo 1 || echo 0)" \
  "rc=3, Dauer < 5000 ms" "rc=$zweiter_rc152, Dauer=${dauer_ms152}ms"
zweiter_stderr_inhalt152=$(cat "$zweiter_stderr152" 2>/dev/null || true)
gefunden153=0
printf '%s' "$zweiter_stderr_inhalt152" | grep -qF "Selbsttest laeuft bereits" && gefunden153=1
pruefe_wahr Z-153 "selbsttest" "Zweiter Selbsttest, gestartet waehrend der erste die Sperre haelt" \
  "die Fehlerausgabe des zweiten Aufrufs traegt die Zeile 'Selbsttest laeuft bereits'" \
  "$gefunden153" "Selbsttest laeuft bereits" "$(printf '%s' "$zweiter_stderr_inhalt152" | head -c 200)"
rm -f "$zweiter_stdout152" "$zweiter_stderr152"
}
# --- Z-154/155 (Runde 7, DT7-03; ADR 0002, 6.12.26 f, Entscheid 7): der
#     Durchlass nach der Eskalation ist an den GEZAEHLTEN Schluessel
#     gebunden -- eine Uebergabedatei mit fremdem Schluessel oeffnet ihn
#     nicht (Z-154, rc), und der Zaehler zaehlt weiter (Z-155, zaehler;
#     Mutation "keine", Grund 3, weil der Stand 4 nach Z-125 auch beim
#     Durchlass gilt und nur Z-154 die Verneinung trennt). ----------------
fall_z154_155() {
echo
echo "--- Uebergabedatei mit FREMDEM Schluessel (DT7-03, 6.12.26 f) ----------"
echo
baum=$(neuer_mock_baum)
m1=$(marken_zeile K1 D20 belege A_OK "" "" 0)
m2=$(marken_zeile K1 D3 linter A_FAIL "" "" 2)
ausgabe154=$(bauen_ausgabe "$baum" "$m1
$m2" "$D19_OK" "make dod: abgebrochen bei D3 linter, Rueckgabewert 2.")
zustand154=$(neu_verzeichnis)
zaehler_datei154=$(zaehler_pfad "$zustand154" "fall-z154")
lauf_mit_zustand "$zustand154" "$baum" Stop "fall-z154" "$ausgabe154" 2
lauf_mit_zustand "$zustand154" "$baum" Stop "fall-z154" "$ausgabe154" 2
lauf_mit_zustand "$zustand154" "$baum" Stop "fall-z154" "$ausgabe154" 2
# Uebergabedatei mit einem ANDEREN Schluessel als dem gezaehlten
# ("D5 typen A_FAIL" statt "D3 linter A_FAIL"), committet -> in HEAD.
mkdir -p "$baum/docs/uebergaben"
printf 'Uebergabe\n\nEskalation 3.4: D5 typen A_FAIL\n' > "$baum/docs/uebergaben/2026-09-03_selbsttest-fremder-schluessel.md"
git -C "$baum" add -A
git -C "$baum" commit -q -m "Uebergabedatei mit fremdem Schluessel"
lauf_mit_zustand "$zustand154" "$baum" Stop "fall-z154" "$ausgabe154" 2
pruefe_rc Z-154 "Vierter Stop nach drei Blocks am selben Kriterium, Uebergabedatei in HEAD mit FREMDEM Schluessel in der Eskalationszeile" 2
schluessel155=$(sed -n '1p' "$zaehler_datei154" 2>/dev/null || true)
stand155=$(sed -n '2p' "$zaehler_datei154" 2>/dev/null || true)
pruefe_zaehler_wahr Z-155 "Vierter Stop, Uebergabedatei mit fremdem Schluessel in der Eskalationszeile" \
  "die Zaehlerdatei traegt nach dem vierten Ereignis den gezaehlten Schluessel D3 linter A_FAIL (Zeile 1) mit dem Stand 4 (Zeile 2) -- der Zaehler zaehlt weiter und wird nicht zurueckgesetzt" \
  "$([ "$schluessel155" = "D3 linter A_FAIL" ] && [ "$stand155" = "4" ] && echo 1 || echo 0)" \
  "Schluessel 'D3 linter A_FAIL', Stand 4" "Schluessel '$schluessel155', Stand '$stand155' (Datei: $zaehler_datei154)"
}
# ::VORSPANN-ENDE::

# -----------------------------------------------------------------------------
# FALL_ZU_KENNUNG (Auftrag Punkt 2): ordnet jeder Kennung Z-nnn GENAU EINE
# Fallfunktion zu. Handgefuehrte Tabelle (nicht zur Laufzeit aus
# Zeilenbereichen dieser Datei bestimmt -- das war Befund S6-08/DT6-04);
# mehrere Kennungen duerfen auf dieselbe Funktion zeigen, wenn ihr
# Pruefaufbau derselbe ist. Z-110 ist am 2026-09-03 zurueckgezogen und hat
# absichtlich KEINEN Eintrag.
# -----------------------------------------------------------------------------
declare -A FALL_ZU_KENNUNG=(
  ["Z-001"]="fall_z001"
  ["Z-002"]="fall_z002_004"
  ["Z-003"]="fall_z002_004"
  ["Z-004"]="fall_z002_004"
  ["Z-005"]="fall_z005_007"
  ["Z-006"]="fall_z005_007"
  ["Z-007"]="fall_z005_007"
  ["Z-008"]="fall_z008"
  ["Z-009"]="fall_z009_010"
  ["Z-010"]="fall_z009_010"
  ["Z-011"]="fall_z011_012"
  ["Z-012"]="fall_z011_012"
  ["Z-013"]="fall_z013"
  ["Z-014"]="fall_z014"
  ["Z-015"]="fall_z015"
  ["Z-016"]="fall_z016"
  ["Z-017"]="fall_z017_018"
  ["Z-018"]="fall_z017_018"
  ["Z-019"]="fall_z019"
  ["Z-020"]="fall_z020"
  ["Z-021"]="fall_z021_032"
  ["Z-022"]="fall_z021_032"
  ["Z-023"]="fall_z021_032"
  ["Z-024"]="fall_z021_032"
  ["Z-025"]="fall_z021_032"
  ["Z-026"]="fall_z021_032"
  ["Z-027"]="fall_z027_028"
  ["Z-028"]="fall_z027_028"
  ["Z-029"]="fall_z021_032"
  ["Z-030"]="fall_z021_032"
  ["Z-031"]="fall_z021_032"
  ["Z-032"]="fall_z021_032"
  ["Z-033"]="fall_z033_034"
  ["Z-034"]="fall_z033_034"
  ["Z-035"]="fall_z035_036_104_105"
  ["Z-036"]="fall_z035_036_104_105"
  ["Z-037"]="fall_z037"
  ["Z-038"]="fall_z038_048"
  ["Z-039"]="fall_z038_048"
  ["Z-040"]="fall_z038_048"
  ["Z-041"]="fall_z038_048"
  ["Z-042"]="fall_z038_048"
  ["Z-043"]="fall_z038_048"
  ["Z-044"]="fall_z038_048"
  ["Z-045"]="fall_z038_048"
  ["Z-046"]="fall_z038_048"
  ["Z-047"]="fall_z038_048"
  ["Z-048"]="fall_z038_048"
  ["Z-049"]="fall_z049_053"
  ["Z-050"]="fall_z049_053"
  ["Z-051"]="fall_z049_053"
  ["Z-052"]="fall_z049_053"
  ["Z-053"]="fall_z049_053"
  ["Z-054"]="fall_z054_055"
  ["Z-055"]="fall_z054_055"
  ["Z-056"]="fall_z056_063"
  ["Z-057"]="fall_z056_063"
  ["Z-058"]="fall_z056_063"
  ["Z-059"]="fall_z056_063"
  ["Z-060"]="fall_z056_063"
  ["Z-061"]="fall_z056_063"
  ["Z-062"]="fall_z056_063"
  ["Z-063"]="fall_z056_063"
  ["Z-064"]="fall_z064"
  ["Z-065"]="fall_z065_068"
  ["Z-066"]="fall_z066"
  ["Z-067"]="fall_z065_068"
  ["Z-068"]="fall_z065_068"
  ["Z-069"]="fall_z069_070"
  ["Z-070"]="fall_z069_070"
  ["Z-071"]="fall_z071_072"
  ["Z-072"]="fall_z071_072"
  ["Z-073"]="fall_z073_074"
  ["Z-074"]="fall_z073_074"
  ["Z-075"]="fall_z075_076"
  ["Z-076"]="fall_z075_076"
  ["Z-077"]="fall_z077_078"
  ["Z-078"]="fall_z077_078"
  ["Z-079"]="fall_z079_080"
  ["Z-080"]="fall_z079_080"
  ["Z-081"]="fall_z081_095"
  ["Z-082"]="fall_z081_095"
  ["Z-083"]="fall_z081_095"
  ["Z-084"]="fall_z081_095"
  ["Z-085"]="fall_z081_095"
  ["Z-086"]="fall_z081_095"
  ["Z-087"]="fall_z081_095"
  ["Z-088"]="fall_z081_095"
  ["Z-089"]="fall_z081_095"
  ["Z-090"]="fall_z081_095"
  ["Z-091"]="fall_z081_095"
  ["Z-092"]="fall_z081_095"
  ["Z-093"]="fall_z081_095"
  ["Z-094"]="fall_z081_095"
  ["Z-095"]="fall_z081_095"
  ["Z-096"]="fall_z096_097"
  ["Z-097"]="fall_z096_097"
  ["Z-098"]="fall_z098_100"
  ["Z-099"]="fall_z098_100"
  ["Z-100"]="fall_z098_100"
  ["Z-101"]="fall_z101_103"
  ["Z-102"]="fall_z101_103"
  ["Z-103"]="fall_z101_103"
  ["Z-104"]="fall_z035_036_104_105"
  ["Z-105"]="fall_z035_036_104_105"
  ["Z-106"]="fall_z106_108"
  ["Z-107"]="fall_z106_108"
  ["Z-108"]="fall_z106_108"
  ["Z-109"]="fall_z109_111"
  ["Z-111"]="fall_z109_111"
  ["Z-112"]="fall_z112_113"
  ["Z-113"]="fall_z112_113"
  ["Z-114"]="fall_z114_115"
  ["Z-115"]="fall_z114_115"
  ["Z-116"]="fall_z116_121"
  ["Z-117"]="fall_z116_121"
  ["Z-118"]="fall_z116_121"
  ["Z-119"]="fall_z116_121"
  ["Z-120"]="fall_z116_121"
  ["Z-121"]="fall_z116_121"
  ["Z-122"]="fall_z122_124"
  ["Z-123"]="fall_z122_124"
  ["Z-124"]="fall_z122_124"
  ["Z-125"]="fall_z125_129"
  ["Z-126"]="fall_z125_129"
  ["Z-127"]="fall_z125_129"
  ["Z-128"]="fall_z125_129"
  ["Z-129"]="fall_z125_129"
  ["Z-130"]="fall_z130"
  ["Z-131"]="fall_z131_132"
  ["Z-132"]="fall_z131_132"
  ["Z-133"]="fall_z133_134"
  ["Z-134"]="fall_z133_134"
  ["Z-135"]="fall_z135_136"
  ["Z-136"]="fall_z135_136"
  ["Z-137"]="fall_z137_138"
  ["Z-138"]="fall_z137_138"
  ["Z-139"]="fall_z139_140"
  ["Z-140"]="fall_z139_140"
  ["Z-141"]="fall_z141"
  ["Z-142"]="fall_z142_143"
  ["Z-143"]="fall_z142_143"
  ["Z-144"]="fall_z144_145"
  ["Z-145"]="fall_z144_145"
  ["Z-146"]="fall_z146_148"
  ["Z-147"]="fall_z146_148"
  ["Z-148"]="fall_z146_148"
  ["Z-149"]="fall_z149_151"
  ["Z-150"]="fall_z149_151"
  ["Z-151"]="fall_z149_151"
  ["Z-152"]="fall_z152_153"
  ["Z-153"]="fall_z152_153"
  ["Z-154"]="fall_z154_155"
  ["Z-155"]="fall_z154_155"
)

# Reihenfolge des Normalmodus, identisch mit der vormaligen Fallreihenfolge.
FALL_REIHENFOLGE=(
  fall_z001
  fall_z002_004
  fall_z005_007
  fall_z008
  fall_z009_010
  fall_z011_012
  fall_z013
  fall_z014
  fall_z015
  fall_z016
  fall_z017_018
  fall_z019
  fall_z020
  fall_z021_032
  fall_z027_028
  fall_z033_034
  fall_z116_121
  fall_z035_036_104_105
  fall_z106_108
  fall_z037
  fall_z038_048
  fall_z125_129
  fall_z049_053
  fall_z054_055
  fall_z056_063
  fall_z142_143
  fall_z064
  fall_z065_068
  fall_z066
  fall_z069_070
  fall_z071_072
  fall_z073_074
  fall_z075_076
  fall_z077_078
  fall_z079_080
  fall_z081_095
  fall_z096_097
  fall_z144_145
  fall_z098_100
  fall_z101_103
  fall_z109_111
  fall_z112_113
  fall_z114_115
  fall_z122_124
  fall_z130
  fall_z131_132
  fall_z133_134
  fall_z135_136
  fall_z137_138
  fall_z139_140
  fall_z141
  fall_z146_148
  fall_z149_151
  fall_z152_153
  fall_z154_155
)

normal_modus_ausfuehren() {
  echo "=== Selbsttest dod-gate.sh (ADR 0002, 6.12.19) ==="
  echo
  echo "--- Ebene 1: Formpruefungen gegen eine Attrappe von 'make dod' ---"
  echo
  echo
  local _fn
  for _fn in "${FALL_REIHENFOLGE[@]}"; do
    "$_fn"
  done
}

zusammenfassung_und_deckung_ausgeben() {
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
  declare -A KANAL_TABELLE=()
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
          # dritte Spalte (Kanal): "| Kennung | Fall | Kanal | Zusicherung | ..."
          # Item 7 (Runde 6): vier Zeilen (Z-147, Z-148, Z-150, Z-151) tragen
          # ein maskiertes Rohrzeichen "\|" IN DER SPALTE ZUSICHERUNG (Beispiel:
          # "GATE mktemp\|1"). "awk -F'|'" kennt die Markdown-Maskierung nicht
          # und spaltet auch dort -- bei diesen vier Zeilen liegt das Zeichen
          # zwar erst NACH der Kanal-Spalte (kein Befund an $4 fuer genau
          # diese vier), aber jede kuenftige Zeile mit "\|" VOR der
          # Kanal-Spalte waere betroffen. Deshalb wird "\|" vor der Aufteilung
          # durch ein Platzhalterzeichen ersetzt (\x01, kommt in Markdown-Text
          # nicht vor) und NICHT zurueckgeschrieben, weil nur $4 gebraucht wird
          # und die Kanal-Spalte selbst kein "\|" enthaelt.
          kanal_zelle=$(printf '%s' "$zeile" | sed 's/\\|/\x01/g' | awk -F'|' '{print $4}' \
            | sed -e 's/^ *//' -e 's/ *$//' -e 's/\*\*//g' -e 's/`//g')
          KANAL_TABELLE["$kennung"]="$kanal_zelle"
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

  # -----------------------------------------------------------------------------
  # Kanalabgleich (ADR 0002, 6.12.26, Entscheid zu O-25): der von jeder
  # pruefe_*-Huelle an _melde gemeldete Kanal wird gegen die dritte Spalte der
  # Tabelle 6.12.19 abgeglichen. Nur Kennungen, die BEIDE Seiten kennen (in der
  # Tabelle UND gemeldet), werden verglichen -- eine fehlende Pruefung ist
  # bereits oben als "ohne Pruefung" erfasst, eine Kennung ohne Tabelleneintrag
  # bereits als "ohne Kennung"; hier geht es allein um den WERT bei
  # uebereinstimmender Kennung.
  # -----------------------------------------------------------------------------
  # ADR 0002, 6.12.26 e (Vierzehnte Fortschreibung, Entscheide 1 und 4): die
  # Ausnahmeliste ist ersatzlos entfernt. Tabelle 6.12.19 traegt fuer Z-080
  # und Z-130 den Kanal "kette", die Messung meldet fuer beide "kette" --
  # Tabelle und Messung stimmen ueberein, jede Kanalabweichung bleibt ein
  # Fehler.
  kanal_abweichungen=0
  for k in "${tabellen_kennungen[@]}"; do
    erwarteter_kanal="${KANAL_TABELLE[$k]:-}"
    gemeldeter_kanal="${KANAL_GEMELDET[$k]:-}"
    [ -n "$gemeldeter_kanal" ] || continue
    [ -n "$erwarteter_kanal" ] || continue
    if [ "$gemeldeter_kanal" != "$erwarteter_kanal" ]; then
      kanal_abweichungen=$((kanal_abweichungen + 1))
      deckung_fehler=1
      echo "Kanalabweichung: $k Tabelle=$erwarteter_kanal gemessen=$gemeldeter_kanal"
    fi
  done
  echo "Kanalabgleich: ${#tabellen_kennungen[@]} Kennungen, $kanal_abweichungen Abweichungen"

  if [ "$bestanden" -eq "$gesamt" ] && [ "$deckung_fehler" -eq 0 ] && [ -f "$adr_pfad" ]; then
    exit 0
  else
    exit 2
  fi
}

# =============================================================================
# MUTATIONSMODUS (ADR 0002, 6.12.26 b, Entscheid des Auftraggebers zu O-25)
# =============================================================================
#
# Aufruf: scripts/dod-gate-selbsttest.sh --mutationen
#
# Prueft, dass jede Zusicherung ihre eigene Verneinung erkennt. Der
# Pruefgegenstand (.claude/hooks/dod-gate.sh, Makefile) wird NIE veraendert
# -- mutiert wird ausschliesslich eine Kopie unter mktemp. Reihenfolge nach
# 6.12.26 b: (1) Deckung der Mutationsdatei gegen die ADR-Tabelle in beide
# Richtungen, (2) je Eintrag: Mutation auf eine Kopie anwenden und verlangen,
# dass sie sich vom Original unterscheidet, (3) den Fall der Kennung ISOLIERT
# gegen die mutierte Kopie laufen lassen und verlangen, dass GENAU diese
# Kennung FEHLGESCHLAGEN meldet.
#
# ISOLIERTER LAUF (Fortschreibung DevOps, O-25 Phase 2, Befund S6-08/DT6-04):
# nicht mehr ueber mechanisch bestimmte Zeilenbereiche -- jede Kennung ist
# ueber FALL_ZU_KENNUNG GENAU EINER selbststaendigen Fallfunktion fall_*()
# zugeordnet (oben, unmittelbar nach den Fallfunktionen deklariert). Ein
# isolierter Lauf besteht aus dem VORSPANN dieser Datei (alles zwischen den
# Sentinels ::VORSPANN-START:: und ::VORSPANN-ENDE:: -- Hilfsfunktionen UND
# saemtliche Fallfunktionen, OHNE die Sperre am Kopf dieser Datei, die der
# AEUSSERE Prozess bereits fuer den ganzen Mutationslauf haelt) gefolgt von
# GENAU EINEM Aufruf der registrierten Funktion. Jede Fallfunktion stellt
# ALLES, was sie braucht, selbst her (eigener Scheinbaum, eigenes
# Zustandsverzeichnis, eigene Attrappen) -- deshalb braucht dieser Lauf keine
# Variablen aus einem vorangehenden Block mehr (vormals Befund S6-08/DT6-04:
# 13 Kennungen brachen mit "unbound variable" ab). REPO_WURZEL wird fest vom
# AEUSSEREN Prozess uebernommen (nicht neu ueber BASH_SOURCE bestimmt, das im
# Wegwerfskript auf dessen eigenen /tmp-Pfad zeigen wuerde). Ein Fall, der
# trotzdem nicht laeuft, wird nicht stillschweigend als "nicht erkannt"
# gezaehlt, sondern ausdruecklich als "FALL NICHT LAUFFAEHIG" gemeldet
# (Auftrag Punkt 4) -- und zaehlt ebenfalls als nicht erkannt.
# =============================================================================

mutationsmodus_ausfuehren() {
  local selbsttest_pfad="$REPO_WURZEL/scripts/dod-gate-selbsttest.sh"
  local adr_pfad="$REPO_WURZEL/docs/adr/0002-architekturentscheid-ziel-stack.md"
  local mut_pfad="$REPO_WURZEL/scripts/dod-gate-mutationen.txt"
  local start_zeit ende_zeit
  start_zeit=$(date +%s)

  # --- ADR-Tabelle lesen: nicht zurueckgezogene Kennungen ---------------
  local -a tabellen_kennungen=()
  if [ -f "$adr_pfad" ]; then
    local zeile kennung
    while IFS= read -r zeile; do
      kennung=$(printf '%s' "$zeile" | sed -n 's/^| \(Z-[0-9][0-9]*\).*/\1/p')
      [ -n "$kennung" ] || continue
      case "$zeile" in
        *zurueckgezogen*|*zurückgezogen*) ;;
        *) tabellen_kennungen+=("$kennung") ;;
      esac
    done < <(grep '^| Z-' "$adr_pfad")
  else
    echo "Mutationsmodus: ADR-Datei nicht gefunden: $adr_pfad" >&2
    return 2
  fi
  if [ ! -f "$mut_pfad" ]; then
    echo "Mutationsmodus: Mutationsdatei nicht gefunden: $mut_pfad" >&2
    return 2
  fi

  # --- Mutationsdatei lesen ----------------------------------------------
  local -a mut_kennungen=()
  local -A MUT_ZIEL=() MUT_SED=() MUT_GRUND=()
  local k z m g
  while IFS=$'\t' read -r k z m g; do
    [ -n "${k:-}" ] || continue
    case "$k" in \#*) continue ;; esac
    mut_kennungen+=("$k")
    MUT_ZIEL["$k"]="$z"
    MUT_SED["$k"]="$m"
    MUT_GRUND["$k"]="$g"
  done < <(grep -v '^#' "$mut_pfad" | grep -v '^[[:space:]]*$')

  # --- 1. Deckung in beide Richtungen (6.12.26 b, Schritt 1) -------------
  local deckung_fehler=0 t gefunden
  for t in "${tabellen_kennungen[@]}"; do
    if [ -z "${MUT_ZIEL[$t]:-}" ]; then
      echo "Mutationsdeckung: Kennung $t der Tabelle OHNE Eintrag in dod-gate-mutationen.txt"
      deckung_fehler=1
    fi
  done
  for k in "${mut_kennungen[@]}"; do
    gefunden=0
    for t in "${tabellen_kennungen[@]}"; do [ "$t" = "$k" ] && gefunden=1 && break; done
    if [ "$gefunden" -eq 0 ]; then
      echo "Mutationsdeckung: Eintrag $k in dod-gate-mutationen.txt OHNE Kennung in der Tabelle (oder zurueckgezogen)"
      deckung_fehler=1
    fi
  done
  local -a doppelt
  mapfile -t doppelt < <(printf '%s\n' "${mut_kennungen[@]}" | sort | uniq -d)
  if [ "${#doppelt[@]}" -gt 0 ]; then
    echo "Mutationsdeckung: Kennung(en) mit mehr als einem Eintrag: ${doppelt[*]}"
    deckung_fehler=1
  fi
  # 6.12.26 b: die Mutationsdatei ist die ausfuehrbare Form der Tabelle --
  # sie deckt nur Kennungen, die auch im Register FALL_ZU_KENNUNG stehen
  # (also nicht Z-110, zurueckgezogen). Eine Kennung ohne registrierte
  # Fallfunktion kann nicht isoliert laufen.
  for k in "${mut_kennungen[@]}"; do
    case "${MUT_SED[$k]}" in keine) continue ;; esac
    if [ -z "${FALL_ZU_KENNUNG[$k]:-}" ]; then
      echo "Mutationsdeckung: Eintrag $k OHNE registrierte Fallfunktion in FALL_ZU_KENNUNG"
      deckung_fehler=1
    fi
  done
  echo "Mutationsdeckung: ${#tabellen_kennungen[@]} Kennungen in der Tabelle, ${#mut_kennungen[@]} Eintraege in der Mutationsdatei"
  if [ "$deckung_fehler" -ne 0 ]; then
    echo "Mutationen: abgebrochen wegen Deckungsabweichung, Schritte 2 und 3 nicht gelaufen"
    return 2
  fi

  # --- Vorspann fuer isolierte Kindprozesse, EINMAL extrahiert -----------
  local prefix_start prefix_end
  prefix_start=$(grep -n '^# ::VORSPANN-START::$' "$selbsttest_pfad" | head -1 | cut -d: -f1)
  prefix_end=$(grep -n '^# ::VORSPANN-ENDE::$' "$selbsttest_pfad" | head -1 | cut -d: -f1)
  if [ -z "$prefix_start" ] || [ -z "$prefix_end" ]; then
    echo "Mutationsmodus: Vorspann-Sentinels nicht gefunden -- abgebrochen" >&2
    return 2
  fi
  local vorspann_datei
  vorspann_datei=$(mktemp)
  # Befund (Auftrag Punkt 5, Nachbelegung): env -i loescht nur die
  # SHELL-VARIABLE SELBSTTEST_SPERRE_FD, NICHT den ererbten Dateideskriptor
  # selbst -- der bleibt beim fork() offen, unabhaengig von der Umgebung.
  # Die Pruefung "if [ -n "${SELBSTTEST_SPERRE_FD:-}" ]" in den einzelnen
  # Fallfunktionen greift deshalb hier NICHT (die Variable ist nach env -i
  # leer), obwohl der Deskriptor selbst noch offen ist und die Sperre des
  # AEUSSEREN, langlebigen Mutationslaufs haelt. Deshalb wird die Deskriptor-
  # NUMMER des AEUSSEREN Prozesses fest in den generierten Kindlauf
  # eingebacken (wie REPO_WURZEL) und dort als ALLERERSTE Anweisung
  # geschlossen -- unabhaengig davon, ob eine Fallfunktion selbst nochmal
  # schliesst. Ohne diese Zeile blieb die Sperre nach einem abgebrochenen
  # Mutationslauf haengen, weil ein Enkelprozess (env -i ... timeout 30
  # bash fall.sh) den Deskriptor weiterhielt, obwohl `timeout` nur den
  # unmittelbaren Kindprozess des AEUSSEREN Laufs signalisiert.
  {
    echo '#!/usr/bin/env bash'
    echo 'set -uo pipefail'
    if [ -n "${SELBSTTEST_SPERRE_FD:-}" ]; then
      printf 'exec %s>&- 2>/dev/null || true\n' "$SELBSTTEST_SPERRE_FD"
    fi
    printf 'REPO_WURZEL=%q\n' "$REPO_WURZEL"
    sed -n "$((prefix_start + 1)),$((prefix_end - 1))p" "$selbsttest_pfad"
  } > "$vorspann_datei"

  local geprueft=0 erkannt=0 nicht_erkannt=0 ohne_mutation=0 wirkungslos=0
  local arbeitsverz
  arbeitsverz=$(mktemp -d)

  for k in "${mut_kennungen[@]}"; do
    local ziel="${MUT_ZIEL[$k]}" ausdruck="${MUT_SED[$k]}"
    if [ "$ausdruck" = "keine" ]; then
      ohne_mutation=$((ohne_mutation + 1))
      continue
    fi
    geprueft=$((geprueft + 1))

    local original_pfad env_var
    case "$ziel" in
      dod-gate.sh)
        original_pfad="$REPO_WURZEL/.claude/hooks/dod-gate.sh"
        env_var="GATE_UEBERSCHREIBUNG"
        ;;
      Makefile)
        original_pfad="$REPO_WURZEL/Makefile"
        env_var="MAKEFILE_UEBERSCHREIBUNG"
        ;;
      dod-gate-terminierte-lagen.txt)
        original_pfad="$REPO_WURZEL/.claude/hooks/dod-gate-terminierte-lagen.txt"
        env_var=""
        ;;
      *)
        echo "MUTATION NICHT VERDRAHTET $k (unbekanntes Ziel '$ziel')"
        nicht_erkannt=$((nicht_erkannt + 1))
        continue
        ;;
    esac
    if [ -z "$env_var" ]; then
      echo "MUTATION NICHT VERDRAHTET $k (Ziel '$ziel' hat keinen Ueberschreibungsweg im Selbsttest)"
      nicht_erkannt=$((nicht_erkannt + 1))
      continue
    fi

    local kopie_verz kopie_pfad
    kopie_verz=$(mktemp -d -p "$arbeitsverz")
    kopie_pfad="$kopie_verz/$(basename "$original_pfad")"
    if ! sed -e "$ausdruck" "$original_pfad" > "$kopie_pfad" 2>"$kopie_verz/sed.err"; then
      echo "MUTATION FEHLGESCHLAGEN ANZUWENDEN $k: sed meldet einen Fehler ($(head -c 200 "$kopie_verz/sed.err"))"
      nicht_erkannt=$((nicht_erkannt + 1))
      continue
    fi
    if cmp -s "$original_pfad" "$kopie_pfad"; then
      echo "MUTATION WIRKUNGSLOS $k: die Kopie ist identisch mit dem Original ($ziel)"
      wirkungslos=$((wirkungslos + 1))
      continue
    fi

    local fallname="${FALL_ZU_KENNUNG[$k]:-}"
    if [ -z "$fallname" ]; then
      echo "MUTATION NICHT VERDRAHTET $k (keine Fallfunktion registriert)"
      nicht_erkannt=$((nicht_erkannt + 1))
      continue
    fi

    local falllauf_datei ausgabe_datei
    falllauf_datei="$kopie_verz/fall.sh"
    ausgabe_datei="$kopie_verz/ausgabe.log"
    cat "$vorspann_datei" > "$falllauf_datei"
    printf '%s\n' "$fallname" >> "$falllauf_datei"

    # Befund (Auftrag Punkt 5, Nachbelegung): "env" execve't OHNE eigenen
    # Fork in "timeout", und "timeout" selbst forkt INTERN nochmal einen
    # Beobachter, der bash/fall.sh erst startet -- dieser Beobachter-Prozess
    # (im System als "timeout 30 ..." sichtbar) fuehrt selbst NIE ein
    # Bash-Kommando aus und kann darum den Deskriptor nicht selbst schliessen
    # (die Schliess-Zeile im Vorspann laeuft nur INNERHALB von fall.sh, nicht
    # im timeout-Beobachter). Ein bash-Dateideskriptor, der ueber
    # "exec {fd}>datei" geoeffnet wurde, ist NICHT close-on-exec und bleibt
    # beim Aufruf von env/timeout offen. Deshalb wird der Deskriptor in einer
    # SUBSHELL -- die nur ihre EIGENE Kopie schliesst, die des aeusseren,
    # langlebigen Mutationslaufs bleibt unberuehrt -- VOR dem allerersten
    # exec (also VOR env) geschlossen; danach kann ihn keiner der
    # nachfolgenden Prozesse (env, timeout-Beobachter, bash/fall.sh) mehr
    # erben, weil er zu diesem Zeitpunkt in dieser Prozesskopie schon zu ist.
    (
      if [ -n "${SELBSTTEST_SPERRE_FD:-}" ]; then
        exec {SELBSTTEST_SPERRE_FD}>&- 2>/dev/null || true
      fi
      exec env -i PATH="$PATH" HOME="${HOME:-/root}" "$env_var=$kopie_pfad" \
        timeout 30 "$BASH_BIN" "$falllauf_datei"
    ) > "$ausgabe_datei" 2>&1
    local falllauf_rc=$?

    if grep -qE "^FEHLGESCHLAGEN $k " "$ausgabe_datei"; then
      echo "MUTATION ERKANNT $k"
      erkannt=$((erkannt + 1))
    elif grep -qE "^BESTANDEN $k " "$ausgabe_datei"; then
      echo "MUTATION NICHT ERKANNT $k"
      nicht_erkannt=$((nicht_erkannt + 1))
    elif [ "$falllauf_rc" -eq 127 ] || grep -qiE "unbound variable|command not found|syntax error" "$ausgabe_datei"; then
      echo "FALL NICHT LAUFFAEHIG $k (Fallfunktion $fallname, rc=$falllauf_rc, Ausschnitt: $(_kuerzen "$(cat "$ausgabe_datei")"))"
      nicht_erkannt=$((nicht_erkannt + 1))
    else
      echo "MUTATION NICHT ERKANNT $k (keine Zeile fuer $k im isolierten Lauf, rc=$falllauf_rc, Ausschnitt: $(_kuerzen "$(cat "$ausgabe_datei")"))"
      nicht_erkannt=$((nicht_erkannt + 1))
    fi
  done

  rm -f "$vorspann_datei"
  rm -rf "$arbeitsverz"

  ende_zeit=$(date +%s)
  echo "Mutationen: $geprueft geprueft, $erkannt erkannt, $nicht_erkannt nicht erkannt, $ohne_mutation ohne Mutation (keine), $wirkungslos wirkungslos, Dauer $((ende_zeit - start_zeit))s"

  if [ "$nicht_erkannt" -eq 0 ] && [ "$wirkungslos" -eq 0 ]; then
    return 0
  else
    return 2
  fi
}


if [ "${1:-}" = "--mutationen" ]; then
  mutationsmodus_ausfuehren
  exit $?
fi

normal_modus_ausfuehren
zusammenfassung_und_deckung_ausgeben
