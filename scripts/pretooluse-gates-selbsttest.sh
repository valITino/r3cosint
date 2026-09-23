#!/usr/bin/env bash
# =============================================================================
# scripts/pretooluse-gates-selbsttest.sh -- Selbsttest fuer die beiden
# PreToolUse-Gates .claude/hooks/block-main-write.sh und
# .claude/hooks/block-prototype-import.sh
# =============================================================================
#
# Bau auf Weisung vom 2026-09-22 (Backlog R3-Q-010, Stand 2026-09-22;
# Sitzungsauftrag vom 2026-09-23).
#
# "Jedes Hook-Skript wird vor dem Einbau gegen einen blockierenden und einen
# durchzulassenden Fall geprueft. Ein ungetestetes Gate ist kein Gate."
# (.claude/rules/claude-konfiguration.md, Abschnitt "Hooks")
#
# ZWEI MODI:
#   1. Normalmodus (kein Parameter): 258 vorgemessene Faelle laufen gegen die
#      Gate-Dateien DES ARBEITSBAUMS (oder, nur fuer Pruefrollen, gegen eine
#      per Umgebungsvariable ueberschriebene Kopie, siehe Abschnitt 3a weiter
#      unten). main-Faelle laufen gegen einen Wegwerf-Klon auf main, einen auf
#      master, gegen den Arbeitszweig-Klon oder gegen ein Verzeichnis ohne
#      Repository (benannte Grenze); Prototyp-Faelle laufen gegen
#      den Arbeitsbaum selbst -- immer ueber die Gate-EINGABE, nie ueber echte
#      Schreibvorgaenge: die Gates selbst schreiben nie eine Datei, sie lesen
#      JSON von der Standardeingabe und urteilen.
#   2. Modus --mutationen (Gegenprobe): zuerst eine GRUNDLINIE -- die
#      vollstaendige Fallliste gegen die UNVERAENDERTEN Gates; ist sie nicht
#      gruen, endet der Modus sofort mit Rueckgabewert 2. Danach 19 fest im
#      Skript hinterlegte Mutationen, die je GENAU EINE Sperre schwaechen oder
#      eine Ausnahme entfernen (MP4, MP5), in einer Kopie eines Gates; die
#      vollstaendige Fallliste des betroffenen Gates laeuft gegen die Kopie.
#      Erwartet: mindestens der benannte Mindestsatz an Kennungen faellt. Im
#      Mutationsmodus laeuft der Normallauf nicht.
#
# Kein Netzzugriff: die vier Klone (main-Klon, zweiter main-Klon,
# master-Klon, Arbeitszweig-Klon) sind LOKALE Klone von CLAUDE_PROJECT_DIR
# selbst. Alle Wegwerfverzeichnisse liegen unter mktemp und werden per trap
# geraeumt. Der Lauf aendert keine versionierte Datei -- das prueft er an
# sich selbst: Statusliste (inklusive ignorierter Pfade), Inhaltspruefsummen
# der versionierten UND der unversionierten, nicht ignorierten Dateien, alle
# aus der Repository-Wurzel erhoben, VOR dem Anlegen der Wegwerfumgebung und
# nach dem letzten Fall verglichen. Git-eigene Umgebungsvariablen, die den
# Gegenstand verlegen koennten, werden vor dem ersten git-Aufruf geloescht;
# Klon und Checkout laufen mit "-c core.hooksPath=/dev/null".
#
# NIEDRIGERES MASS als scripts/dod-gate-selbsttest.sh (ADR 0002, 6.13 d
# verlangt das ausdruecklich): keine Zusicherungstabelle, keine mechanischen
# mehrstufigen Deckungen, keine separate Mutationsdatei -- die Fallliste, die
# 19 Mutationen, die 23 Fallklassen der Kopfkommentare und die Zuordnung zu
# den sieben Abnahmekriterien stehen FEST im Skript (Datenteil weiter unten).
#
# Verifikation dieses Skripts UND der beiden Gates: Static und Dynamic
# Software Tester, nicht die bauende Rolle selbst (3.4). Fuer eine eigene
# Mutationsprobe der Pruefrollen: die Umgebungsvariablen
# GATE_MAIN_UEBERSCHREIBUNG und GATE_PROTOTYP_UEBERSCHREIBUNG (siehe
# Abschnitt 3a) lassen dieses Skript gegen eine selbst erzeugte KOPIE eines
# Gates laufen, ohne die Datei im Arbeitsbaum zu beruehren. Ohne diese
# Variablen unveraendertes Verhalten. Die Pfade muessen ABSOLUT sein: ein
# relativer Pfad wird nach dem Wechsel in das Kontextverzeichnis nicht mehr
# gefunden und ergibt ein falsches Rot (ist=127; Restbefund N-DT-1 der
# dynamischen Nachpruefung vom 2026-09-23). Am Rueckgabewert ist eine
# Ueberschreibung nicht erkennbar, nur an der Kopfzeile: Wird dieses
# Pruefmittel je in die Kette (make dod) eingebunden, sind die beiden
# Variablen dort zu neutralisieren wie die GIT_*-Variablen (Restbefund
# NEU-1 der statischen Nachpruefung vom 2026-09-23); heute ruft die Kette es
# nicht auf.
#
# Rueckgabewert 0: Normalmodus -- alle 258 Faelle bestanden UND je Gate
# mindestens ein Fall mit Soll 2 und einer mit Soll 0 UND je Gate mindestens
# ein Fall der Klasse blockierend und einer der Klasse durchlaufend UND die
# gemessene Gesamtzahl entspricht der erwarteten Zahl UND der Arbeitsbaum
# blieb unveraendert UND alle Fallklassen sind gedeckt UND jede
# Befundkennung ist bekannt UND jedes Abnahmekriterium ist vollstaendig (die
# Listen der Abnahmekriterien werden ausgegeben und auf vorhandene Kennungen
# geprueft; eine fehlende Kennung erscheint dort als FEHLEND und wirkt seit
# E4.2 auf den Rueckgabewert -- Restbefund N-2/T-4 der statischen
# Nachpruefung vom 2026-09-23, behoben). Modus --mutationen -- die
# Grundlinie ist gruen UND alle 15 Mutationen erkannt UND der Arbeitsbaum
# blieb unveraendert. Sonst Rueckgabewert 2. Rueckgabewert 3: der Lauf kommt
# nicht zustande (ein Werkzeug fehlt, ein Klon ist nicht anlegbar, unbekannter
# Parameter) -- mit Meldung auf stderr.
# =============================================================================

set -uo pipefail

# -----------------------------------------------------------------------------
# 0. Git-eigene Umgebungsvariablen loeschen (N-6), vor dem ersten git-Aufruf
#    dieses Skripts -- wie .claude/hooks/session-start-git-historie.sh. Die so
#    bereinigte Umgebung erhalten ueber die normale Prozessvererbung auch die
#    Gates selbst (fall(), Abschnitt 10).
# -----------------------------------------------------------------------------
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_COMMON_DIR GIT_NAMESPACE GIT_CEILING_DIRECTORIES GIT_DISCOVERY_ACROSS_FILESYSTEM GIT_SHALLOW_FILE 2>/dev/null || true
unset "${!GIT_TRACE@}" 2>/dev/null || true

# -----------------------------------------------------------------------------
# 1. Parameter
# -----------------------------------------------------------------------------
MODUS="normal"
if [ $# -gt 0 ]; then
  if [ "$1" = "--mutationen" ] && [ $# -eq 1 ]; then
    MODUS="mutationen"
  else
    echo "pretooluse-gates-selbsttest: FEHLER -- unbekannter Parameter ('$*'); erlaubt ist kein Parameter oder genau '--mutationen'." >&2
    exit 3
  fi
fi

# -----------------------------------------------------------------------------
# 2. Werkzeuge, die dieser Lauf selbst braucht
# -----------------------------------------------------------------------------
for w in jq git mktemp sha256sum; do
  if ! command -v "$w" >/dev/null 2>&1; then
    echo "pretooluse-gates-selbsttest: FEHLER -- Werkzeug '$w' fehlt; der Lauf kommt nicht zustande." >&2
    exit 3
  fi
done

# -----------------------------------------------------------------------------
# 3. Arbeitsbaum und Gate-Dateien
# -----------------------------------------------------------------------------
SKRIPT_QUELLE="${BASH_SOURCE[0]}"
SKRIPT_VERZ=$(cd "$(dirname "$SKRIPT_QUELLE")" >/dev/null 2>&1 && pwd)
if [ -z "$SKRIPT_VERZ" ]; then
  echo "pretooluse-gates-selbsttest: FEHLER -- Verzeichnis des Skripts nicht aufloesbar." >&2
  exit 3
fi
if ! REPO_WURZEL=$(git -C "$SKRIPT_VERZ" rev-parse --show-toplevel 2>/dev/null); then
  echo "pretooluse-gates-selbsttest: FEHLER -- kein Repository um '$SKRIPT_VERZ'; der Lauf kommt nicht zustande." >&2
  exit 3
fi

GATE_MAIN="$REPO_WURZEL/.claude/hooks/block-main-write.sh"
GATE_PROTOTYP="$REPO_WURZEL/.claude/hooks/block-prototype-import.sh"
if [ ! -f "$GATE_MAIN" ]; then
  echo "pretooluse-gates-selbsttest: FEHLER -- Gate-Datei fehlt: $GATE_MAIN" >&2
  exit 3
fi
if [ ! -f "$GATE_PROTOTYP" ]; then
  echo "pretooluse-gates-selbsttest: FEHLER -- Gate-Datei fehlt: $GATE_PROTOTYP" >&2
  exit 3
fi

SHA_MAIN_VOLL=$(sha256sum "$GATE_MAIN" | cut -d' ' -f1)
SHA_PROTO_VOLL=$(sha256sum "$GATE_PROTOTYP" | cut -d' ' -f1)
SHA_MAIN_KURZ="${SHA_MAIN_VOLL:0:16}"
SHA_PROTO_KURZ="${SHA_PROTO_VOLL:0:16}"

# -----------------------------------------------------------------------------
# 3a. Ueberschreibung fuer Pruefrollen (DT-E41-02): mit eigener Mutation gegen
#     eine selbst erzeugte Kopie laufen, ohne die Datei im Arbeitsbaum
#     anzufassen. Ohne die Variablen unveraendertes Verhalten.
# -----------------------------------------------------------------------------
GATE_MAIN_AKTIV="$GATE_MAIN"
GATE_MAIN_ANZEIGE_ZUSATZ=""
if [ -n "${GATE_MAIN_UEBERSCHREIBUNG:-}" ]; then
  if [ ! -f "$GATE_MAIN_UEBERSCHREIBUNG" ]; then
    echo "pretooluse-gates-selbsttest: FEHLER -- GATE_MAIN_UEBERSCHREIBUNG '$GATE_MAIN_UEBERSCHREIBUNG' ist keine Datei." >&2
    exit 3
  fi
  GATE_MAIN_AKTIV="$GATE_MAIN_UEBERSCHREIBUNG"
  SHA_MAIN_VOLL=$(sha256sum "$GATE_MAIN_AKTIV" | cut -d' ' -f1)
  SHA_MAIN_KURZ="${SHA_MAIN_VOLL:0:16}"
  GATE_MAIN_ANZEIGE_ZUSATZ=" (UEBERSCHRIEBEN)"
fi
GATE_PROTOTYP_AKTIV="$GATE_PROTOTYP"
GATE_PROTOTYP_ANZEIGE_ZUSATZ=""
if [ -n "${GATE_PROTOTYP_UEBERSCHREIBUNG:-}" ]; then
  if [ ! -f "$GATE_PROTOTYP_UEBERSCHREIBUNG" ]; then
    echo "pretooluse-gates-selbsttest: FEHLER -- GATE_PROTOTYP_UEBERSCHREIBUNG '$GATE_PROTOTYP_UEBERSCHREIBUNG' ist keine Datei." >&2
    exit 3
  fi
  GATE_PROTOTYP_AKTIV="$GATE_PROTOTYP_UEBERSCHREIBUNG"
  SHA_PROTO_VOLL=$(sha256sum "$GATE_PROTOTYP_AKTIV" | cut -d' ' -f1)
  SHA_PROTO_KURZ="${SHA_PROTO_VOLL:0:16}"
  GATE_PROTOTYP_ANZEIGE_ZUSATZ=" (UEBERSCHRIEBEN)"
fi

# -----------------------------------------------------------------------------
# 4. Commit fuer die main/master-Klone
# -----------------------------------------------------------------------------
KLON_COMMIT=""
KLON_REF=""
for ref in refs/remotes/origin/main refs/heads/main HEAD; do
  if wert=$(git -C "$REPO_WURZEL" rev-parse --verify -q "$ref" 2>/dev/null); then
    KLON_COMMIT="$wert"
    KLON_REF="$ref"
    break
  fi
done
if [ -z "$KLON_COMMIT" ]; then
  echo "pretooluse-gates-selbsttest: FEHLER -- kein main-Commit ueber refs/remotes/origin/main, refs/heads/main oder HEAD aufloesbar; der Lauf kommt nicht zustande." >&2
  exit 3
fi

# -----------------------------------------------------------------------------
# 4a. Schnappschussfunktionen (N-5, DT-E41-03) -- aus der Repository-Wurzel
#     erhoben (die Klone unter Abschnitt 6 sind davon unbetroffen: eigene
#     Arbeitsbaeume unter mktemp).
# -----------------------------------------------------------------------------
schnappschuss_status() { git -C "$REPO_WURZEL" status --porcelain --untracked-files=all --ignored; }
schnappschuss_hash_inhalt() { ( cd "$REPO_WURZEL" && git ls-files -z | xargs -0 sha256sum ); }
schnappschuss_hash_unversioniert() { ( cd "$REPO_WURZEL" && git ls-files -z --others --exclude-standard | xargs -0 -r sha256sum ); }

# -----------------------------------------------------------------------------
# 4b. Vorher-Schnappschuss, VOR dem Anlegen der Wegwerfumgebung (N-5). Scheitert
#     eine Erhebung oder ist das Ergebnis der versionierten Pruefsummen leer,
#     ist die Unveraendertheit nicht belegbar (DT-E41-03): Meldung, und die
#     spaetere Vergleichspruefung zaehlt dann als verletzt (Rueckgabewert 2,
#     nicht 3 -- der Lauf selbst kommt zustande).
# -----------------------------------------------------------------------------
VORHER_OK=1
VORHER_STATUS=""
VORHER_HASH_INHALT=""
VORHER_HASH_UNVERSIONIERT=""
if ! VORHER_STATUS=$(schnappschuss_status); then VORHER_OK=0; fi
if ! VORHER_HASH_INHALT=$(schnappschuss_hash_inhalt) || [ -z "$VORHER_HASH_INHALT" ]; then VORHER_OK=0; fi
if ! VORHER_HASH_UNVERSIONIERT=$(schnappschuss_hash_unversioniert); then VORHER_OK=0; fi
if [ "$VORHER_OK" != 1 ]; then
  echo "pretooluse-gates-selbsttest: Arbeitsbaum: Inhaltspruefsummen nicht erhebbar." >&2
fi

# -----------------------------------------------------------------------------
# 5. Wegwerfverzeichnis, Aufraeumen per trap
# -----------------------------------------------------------------------------
T=$(mktemp -d) || { echo "pretooluse-gates-selbsttest: FEHLER -- mktemp -d fehlgeschlagen; der Lauf kommt nicht zustande." >&2; exit 3; }
aufraeumen() {
  chmod -R u+rwx "$T" >/dev/null 2>&1 || true
  rm -rf "$T"
}
trap aufraeumen EXIT

# -----------------------------------------------------------------------------
# 6. Umgebungen: main-Klon, zweiter main-Klon, master-Klon, Arbeitszweig-Klon,
#    kein Repo. "-c core.hooksPath=/dev/null" haelt Git-Hooks des Klons und
#    einer eingeschleusten Konfiguration fern (N-6).
# -----------------------------------------------------------------------------
klon_anlegen() {
  local ziel="$1" zweig="$2"
  if ! git -c core.hooksPath=/dev/null clone -q --no-checkout "$REPO_WURZEL" "$ziel" 2>"$T/klon-fehler"; then
    echo "pretooluse-gates-selbsttest: FEHLER -- Klon nach '$ziel' nicht anlegbar." >&2
    cat "$T/klon-fehler" >&2
    exit 3
  fi
  if ! git -C "$ziel" -c core.hooksPath=/dev/null checkout -q -B "$zweig" "$KLON_COMMIT" 2>"$T/klon-fehler"; then
    echo "pretooluse-gates-selbsttest: FEHLER -- Checkout '$zweig' in '$ziel' fehlgeschlagen." >&2
    cat "$T/klon-fehler" >&2
    exit 3
  fi
}
klon_anlegen "$T/main-klon" main
klon_anlegen "$T/zweiter-main" main
klon_anlegen "$T/master-klon" master
klon_anlegen "$T/arbeits-klon" claude/pruefzweig
mkdir -p "$T/kein-repo"

P_MK="$T/main-klon"
P_ZM="$T/zweiter-main"
P_MS="$T/master-klon"
P_AK="$T/arbeits-klon"
P_KR="$T/kein-repo"
P_AB="$REPO_WURZEL"

# -----------------------------------------------------------------------------
# 7. PATH-Varianten fuer die Wachen, absolute Pfade fuer bash und timeout
# -----------------------------------------------------------------------------
PATH_VOLL="$PATH"
BASH_BIN=$(command -v bash)
TIMEOUT_BIN=$(command -v timeout)
if [ -z "$BASH_BIN" ] || [ -z "$TIMEOUT_BIN" ]; then
  echo "pretooluse-gates-selbsttest: FEHLER -- bash oder timeout nicht aufloesbar; der Lauf kommt nicht zustande." >&2
  exit 3
fi

BIN_OHNE_GIT="$T/bin-ohne-git"
BIN_OHNE_JQ="$T/bin-ohne-jq"
mkdir -p "$BIN_OHNE_GIT" "$BIN_OHNE_JQ"
for w in cat grep sed tr jq; do
  p=$(command -v "$w") || { echo "pretooluse-gates-selbsttest: FEHLER -- Werkzeug '$w' nicht aufloesbar." >&2; exit 3; }
  ln -s "$p" "$BIN_OHNE_GIT/$w"
done
for w in cat grep sed tr git; do
  p=$(command -v "$w") || { echo "pretooluse-gates-selbsttest: FEHLER -- Werkzeug '$w' nicht aufloesbar." >&2; exit 3; }
  ln -s "$p" "$BIN_OHNE_JQ/$w"
done

# -----------------------------------------------------------------------------
# 8. Hilfsfunktionen zum Bauen der JSON-Eingaben (bj/wj, Sonderformen und
#    Platzhalter-Ersetzung; Form der Eingabe nach ADR 0002, 6.13 d Punkt 1)
# -----------------------------------------------------------------------------
bj() { jq -cn --arg c "$1" --arg t "${2:-Bash}" '{tool_name:$t, tool_input:{command:$c}}'; }
wj() { jq -cn --arg f "$1" --arg c "$2" --arg t "${3:-Write}" '{tool_name:$t, tool_input:{file_path:$f, content:$c}}'; }
ej() { jq -cn --arg t "${4:-Edit}" --arg f "$1" --arg o "$2" --arg n "$3" '{tool_name:$t, tool_input:{file_path:$f, old_string:$o, new_string:$n}}'; }
mej() { jq -cn --arg f "$1" --arg o "$2" --arg n "$3" '{tool_name:"MultiEdit", tool_input:{file_path:$f, edits:[{old_string:$o, new_string:$n}]}}'; }
nej() { jq -cn --arg p "$1" --arg s "$2" '{tool_name:"NotebookEdit", tool_input:{notebook_path:$p, new_source:$s}}'; }
rj() { jq -cn --arg f "$1" '{tool_name:"Read", tool_input:{file_path:$f}}'; }
wj_ohne_content() { jq -cn --arg f "$1" '{tool_name:"Write", tool_input:{file_path:$f}}'; }

# Platzhalter {MK} {ZM} {MS} {AK} {KR} {AB} literal ersetzen (N-7: Muster- UND
# Ersatzseite sind quotierte Parameterverweise -- ${s//"$muster"/"$ersatz"} --
# damit beide Seiten in jedem Fall literal bleiben, unabhaengig vom Inhalt).
ph() {
  local s="$1" muster ersatz
  muster='{MK}'; ersatz="$P_MK"; s="${s//"$muster"/"$ersatz"}"
  muster='{ZM}'; ersatz="$P_ZM"; s="${s//"$muster"/"$ersatz"}"
  muster='{MS}'; ersatz="$P_MS"; s="${s//"$muster"/"$ersatz"}"
  muster='{AK}'; ersatz="$P_AK"; s="${s//"$muster"/"$ersatz"}"
  muster='{KR}'; ersatz="$P_KR"; s="${s//"$muster"/"$ersatz"}"
  muster='{AB}'; ersatz="$P_AB"; s="${s//"$muster"/"$ersatz"}"
  printf '%s' "$s"
}
bj_ph() { bj "$(ph "$1")" "${2:-Bash}"; }
wj_ph() { wj "$(ph "$1")" "$(ph "$2")" "${3:-Write}"; }

# -----------------------------------------------------------------------------
# 9. Buchhaltung
# -----------------------------------------------------------------------------
ERWARTETE_FAELLE=258
VOLLSTAENDIGKEIT_OK=1
declare -a ALLE_KENNUNGEN=()
declare -a BESTANDENE_KENNUNGEN=()
declare -a GEFALLENE_KENNUNGEN=()
declare -A URTEIL_VON=()
declare -A SOLL_VON=()
declare -A KLASSE_VON=()
declare -A GATE_VON=()

MAIN_SOLL2_ANZAHL=0
MAIN_SOLL0_ANZAHL=0
PROTO_SOLL2_ANZAHL=0
PROTO_SOLL0_ANZAHL=0
declare -A KLASSEN_ANZAHL_MAIN=()
declare -A KLASSEN_ANZAHL_PROTO=()

AKTIV_GATE_MAIN="$GATE_MAIN_AKTIV"
AKTIV_GATE_PROTOTYP="$GATE_PROTOTYP_AKTIV"
AKTIVE_MUTATION_GATE=""
declare -a MUTATION_GEFALLEN=()
MUTATION_GEPRUEFT=0
GRUNDLINIE_MODUS=0
GRUNDLINIE_GESAMT=0
GRUNDLINIE_BESTANDEN=0
declare -a GRUNDLINIE_GEFALLEN=()

# Befundkennung je Fall der Klasse belegte-luecke (Teil 4.3/4.5/4.6 der
# Fallliste unten, ADR 0002, 6.13 d), fuer die Ausgabezeile "belegte Luecken".
# Seit E4.3 leer: ST-09 und ST-13 sind geschlossen, keine Klasse
# belegte-luecke mehr in der Fallliste.
declare -A BEFUND_VON=()

# -----------------------------------------------------------------------------
# 10. Ein Fall (fall <kennung> <gate> <klasse> <soll> <kontext> <cwd> <pfad>
#     <art> <werkzeug> <vermerk> <eingabe>)
# -----------------------------------------------------------------------------
fall() {
  if [ $# -ne 11 ]; then
    echo "pretooluse-gates-selbsttest: FEHLER -- fall() mit $# statt 11 Argumenten aufgerufen (erstes Argument: ${1:-?})." >&2
    exit 3
  fi
  local kennung="$1" gate="$2" klasse="$3" soll="$4" kontext_code="$5" cwd_wahl="$6" pfad_wahl="$7" art="$8" werkzeug="$9" vermerk="${10}" eingabe="${11}"

  if [ -n "$AKTIVE_MUTATION_GATE" ] && [ "$gate" != "$AKTIVE_MUTATION_GATE" ]; then
    return 0
  fi

  if [ -z "$AKTIVE_MUTATION_GATE" ] && [ -n "${URTEIL_VON[$kennung]+gesetzt}" ]; then
    echo "pretooluse-gates-selbsttest: FEHLER -- doppelte Kennung '$kennung' in der Fallliste." >&2
    exit 3
  fi

  local kontext_pfad
  case "$kontext_code" in
    MK) kontext_pfad="$P_MK" ;;
    MS) kontext_pfad="$P_MS" ;;
    AK) kontext_pfad="$P_AK" ;;
    KR) kontext_pfad="$P_KR" ;;
    AB) kontext_pfad="$P_AB" ;;
    *)
      echo "pretooluse-gates-selbsttest: FEHLER -- unbekannter Kontext-Code '$kontext_code' bei Fall $kennung." >&2
      exit 3
      ;;
  esac

  local gate_pfad
  if [ "$gate" = "main" ]; then gate_pfad="$AKTIV_GATE_MAIN"; else gate_pfad="$AKTIV_GATE_PROTOTYP"; fi

  local zielpfad
  if [ "$cwd_wahl" = "/" ]; then zielpfad="/"; else zielpfad="$kontext_pfad"; fi

  local pfadvar
  case "$pfad_wahl" in
    voll) pfadvar="$PATH_VOLL" ;;
    ohne-git) pfadvar="$BIN_OHNE_GIT" ;;
    ohne-jq) pfadvar="$BIN_OHNE_JQ" ;;
    *)
      echo "pretooluse-gates-selbsttest: FEHLER -- unbekannte PATH-Wahl '$pfad_wahl' bei Fall $kennung." >&2
      exit 3
      ;;
  esac

  : > "$T/lauf-aus"
  : > "$T/lauf-fehler"
  ( cd "$zielpfad" 2>/dev/null && printf '%s' "$eingabe" | env PATH="$pfadvar" CLAUDE_PROJECT_DIR="$kontext_pfad" "$TIMEOUT_BIN" 20 "$BASH_BIN" "$gate_pfad" >"$T/lauf-aus" 2>"$T/lauf-fehler" )
  local ist=$?

  local stdout_bytes stderr_bytes
  stdout_bytes=$(wc -c < "$T/lauf-aus" | tr -d ' ')
  stderr_bytes=$(wc -c < "$T/lauf-fehler" | tr -d ' ')

  local urteil="BESTANDEN" gruende="" grund="-"
  if [ "$ist" != "$soll" ]; then gruende="${gruende}rueckgabewert,"; fi
  if [ "$stdout_bytes" != "0" ]; then gruende="${gruende}stdout-nicht-leer,"; fi
  if [ "$soll" = "2" ] && [ "$stderr_bytes" = "0" ]; then gruende="${gruende}stderr-leer-bei-soll-2,"; fi

  # B-1/DST-E42-03: bei Soll 2 und vollem PATH (Wachen-Faelle ohne-jq/ohne-git
  # ausgenommen) muss stderr den verletzten Abschnitt nennen und, beim
  # Prototyp-Gate an einem Dateiwerkzeug, die zur Datei passende Richtung.
  # Bash-Faelle des Prototyp-Gates nennen keine Richtung (die Bash-Meldung
  # kennt das Konstrukt "Richtung" nicht) und werden hier ausgenommen.
  if [ "$soll" = "2" ] && [ "$pfad_wahl" = "voll" ]; then
    local stderr_text
    stderr_text=$(cat "$T/lauf-fehler")
    if [ "$art" = "ROH" ]; then
      # ST-13: die Wachen-Meldung ("Eingabe nicht auswertbar") ersetzt hier
      # die 5.6-/3.2-c-Meldung, wie bei den Wachen-Faellen ohne-jq/ohne-git.
      case "$stderr_text" in
        *"nicht auswertbar"*) : ;;
        *) gruende="${gruende}meldung-ohne-nicht-auswertbar," ;;
      esac
    elif [ "$gate" = "prototyp" ]; then
      case "$stderr_text" in
        *"Projektauftrag 5.6"*) : ;;
        *) gruende="${gruende}meldung-ohne-5.6," ;;
      esac
      local werkzeug_klein
      werkzeug_klein=$(printf '%s' "$werkzeug" | tr '[:upper:]' '[:lower:]')
      if [ "$werkzeug_klein" != "bash" ]; then
        local erwartete_richtung="Richtung 1"
        case "$eingabe" in
          *'"file_path":"prototype/'*|*'"notebook_path":"prototype/'*) erwartete_richtung="Richtung 2" ;;
        esac
        case "$stderr_text" in
          *"$erwartete_richtung"*) : ;;
          *) gruende="${gruende}meldung-ohne-richtung," ;;
        esac
      fi
    else
      case "$stderr_text" in
        *"Projektauftrag 3.2 c"*) : ;;
        *) gruende="${gruende}meldung-ohne-3.2c," ;;
      esac
    fi
  fi

  if [ -n "$gruende" ]; then
    urteil="GEFALLEN"
    grund="${gruende%,}"
  fi

  if [ "$GRUNDLINIE_MODUS" = "1" ]; then
    GRUNDLINIE_GESAMT=$((GRUNDLINIE_GESAMT+1))
    if [ "$urteil" = "BESTANDEN" ]; then
      GRUNDLINIE_BESTANDEN=$((GRUNDLINIE_BESTANDEN+1))
    else
      GRUNDLINIE_GEFALLEN+=("$kennung")
    fi
    return 0
  fi

  if [ -z "$AKTIVE_MUTATION_GATE" ]; then
    local eingabe_anzeige="${eingabe//$'\n'/\\n}"
    printf '%s gate=%s werkzeug=%s soll=%s ist=%s %s klasse=%s stdout=%s stderr=%s grund=%s vermerk="%s" eingabe=%s\n' \
      "$kennung" "$gate" "$werkzeug" "$soll" "$ist" "$urteil" "$klasse" "$stdout_bytes" "$stderr_bytes" "$grund" "$vermerk" "$eingabe_anzeige"

    ALLE_KENNUNGEN+=("$kennung")
    GATE_VON["$kennung"]="$gate"
    KLASSE_VON["$kennung"]="$klasse"
    SOLL_VON["$kennung"]="$soll"
    URTEIL_VON["$kennung"]="$urteil"
    if [ "$urteil" = "BESTANDEN" ]; then
      BESTANDENE_KENNUNGEN+=("$kennung")
    else
      GEFALLENE_KENNUNGEN+=("$kennung")
    fi

    if [ "$gate" = "main" ]; then
      if [ "$soll" = "2" ]; then MAIN_SOLL2_ANZAHL=$((MAIN_SOLL2_ANZAHL+1)); else MAIN_SOLL0_ANZAHL=$((MAIN_SOLL0_ANZAHL+1)); fi
      KLASSEN_ANZAHL_MAIN["$klasse"]=$(( ${KLASSEN_ANZAHL_MAIN["$klasse"]:-0} + 1 ))
    else
      if [ "$soll" = "2" ]; then PROTO_SOLL2_ANZAHL=$((PROTO_SOLL2_ANZAHL+1)); else PROTO_SOLL0_ANZAHL=$((PROTO_SOLL0_ANZAHL+1)); fi
      KLASSEN_ANZAHL_PROTO["$klasse"]=$(( ${KLASSEN_ANZAHL_PROTO["$klasse"]:-0} + 1 ))
    fi
    if [ "$klasse" = "belegte-luecke" ] && [ -z "${BEFUND_VON[$kennung]+x}" ]; then
      echo "pretooluse-gates-selbsttest: unbekannte Befundkennung fuer '$kennung' (Klasse belegte-luecke ohne Eintrag in BEFUND_VON)." >&2
      VOLLSTAENDIGKEIT_OK=0
    fi
  else
    MUTATION_GEPRUEFT=$((MUTATION_GEPRUEFT+1))
    if [ "$urteil" = "GEFALLEN" ]; then
      MUTATION_GEFALLEN+=("$kennung")
    fi
  fi
}

# -----------------------------------------------------------------------------
# 11. Feste Daten: Mutationen, Fallklassen der Kopfkommentare,
#     Abnahmekriterien (ADR 0002, 6.13 d: einmal abgezaehlt, im Pruefmittel
#     gefuehrt, in der Ausgabe genannt -- entstehen nicht bei jedem Lauf neu)
# -----------------------------------------------------------------------------
declare -a MUT_KENNUNG=() MUT_GATE=() MUT_SUCH=() MUT_ERSATZ=() MUT_BESCHREIBUNG=() MUT_ERWARTET=()
mutation_definieren() {
  MUT_KENNUNG+=("$1"); MUT_GATE+=("$2"); MUT_SUCH+=("$3"); MUT_ERSATZ+=("$4"); MUT_BESCHREIBUNG+=("$5"); MUT_ERWARTET+=("$6")
}

declare -a FK_ID=() FK_GATE=() FK_TYP=() FK_TEXT=() FK_KENNUNGEN=()
fallklasse_definieren() {
  FK_ID+=("$1"); FK_GATE+=("$2"); FK_TYP+=("$3"); FK_TEXT+=("$4"); FK_KENNUNGEN+=("$5")
}

declare -a AK_ID=() AK_DOMAIN=() AK_KENNUNGEN=() AK_ANMERKUNG=()
abnahmekriterium_definieren() {
  AK_ID+=("$1"); AK_DOMAIN+=("$2"); AK_KENNUNGEN+=("$3"); AK_ANMERKUNG+=("$4")
}

# --- 11a. Zehn Mutationen (ADR 0002, 6.13 d) --------------------------
mutation_definieren MM1 main 'worktree[[:space:]]+add([[:space:]]|$)' 'worktree[[:space:]]+addNIE([[:space:]]|$)' 'Sperre Arbeitsbaum auf main anlegen entfernt' 'A07 A08 A09 A37'
mutation_definieren MM2 main 'if ! command -v git >/dev/null 2>&1; then' 'if false; then' 'git-Wache entfernt (ST-03)' 'S03'
mutation_definieren MM3 main '(commit|merge|revert|cherry-pick|rebase|reset|am|apply|stash[[:space:]]+(pop|apply))' '(NIE)' 'Sperre schreibender git-Verben entfernt' 'A10 A14 A20 A21 A22 A30 A31 ZF3a ZF3b ZF3c ZF3d ZF3e ZF3f ZF3g'
mutation_definieren MM4 main 'is_protected "$branch" || exit 0' 'exit 0' 'Sperre der Dateiwerkzeuge auf main entfernt (Kopfkommentar Fall 1)' 'A12 A13'
mutation_definieren MM5 main "(^|[[:space:]:+\"'\\''(])(main|master)([[:space:]]|\$|[\"'\\'';&|)])" "(^|[[:space:]:+])(main|master)([[:space:]]|\$|[\"'\\''])" 'ST-01-Behebung zurueckgesetzt: Zeichenklassen der Push-Zielpruefung auf den Stand vor 0b3510a (kein Anfuehrungszeichen, kein Semikolon, keine Klammer)' 'A38 A39 A40 A41'
mutation_definieren MP1 prototyp '-e "(src|href)=${Q}(${NQ}*[/\\\\])?prototype(/|\\\\|${Q})"' '-e "(NIE)=${Q}(${NQ}*[/\\\\])?prototype(/|\\\\|${Q})"' 'HTML-Formen src=/href= der Richtung 1 entfernt' 'P02 B34'
mutation_definieren MP2 prototyp '(>>?|\btee[[:space:]]|sed[[:space:]]+-[a-zA-Z]*i|<<)' '(NIE)' 'Erkennung der Schreibwirkung bei Bash entfernt (B-1: tee-Glied seit E4.3 ohne Pipe-Bindung)' 'B10 B11 B12 B13 B39 B40 B53'
mutation_definieren MP9 prototyp '\b(mv|cp|rm|mkdir|touch|truncate|ln|install|patch|dd)[[:space:]]' '\b(NIE)[[:space:]]' 'Dateiwerkzeug-Glied im Prototyp-Gate entfernt (B-2, DT-E43-2)' 'B54 B56'
mutation_definieren MP3 prototyp "WURZELN='backend|frontend|deploy|src|app|lib|server|packages|apps'" "WURZELN='NIE'" 'Verzeichnisliste WURZELN der Richtung 2 entfernt (Import-Pfade und src=/href=; die Python-Formen fuehren backend/frontend/deploy gesondert)' 'B05 B20 B21 B22 B37'
# P08 (MultiEdit) faellt bei dieser Mutation nicht, weil das Gate old_string
# innerhalb von edits[] ueber einen eigenen jq-Pfad strukturell nie liest;
# P08 bleibt Gegenprobe im Normalmodus.
mutation_definieren MP4 prototyp 'test("path|^old_string$"; "i")' 'test("path"; "i")' 'Ausnahme von old_string entfernt -- Regressionsschutz' 'P05'
mutation_definieren MP5 prototyp 'docs/*|.claude/*|*.md|*.txt|*.adoc|*.rst) exit 0 ;;' 'NIE-GESETZT) exit 0 ;;' 'Doku-Ausnahme entfernt -- Regressionsschutz' 'P03 P11 P18 P19 ZF9'
mutation_definieren MP6 prototyp 'Richtung 1 (Produktionscode -> Prototyp): ' '' 'Richtungsangabe der Richtung-1-Meldung entfernt' 'B01 B04 B27 P02'
mutation_definieren MP7 prototyp '\b(python[0-9.]*|perl|ruby|node|deno|php|Rscript)[[:space:]]+([^|;&]*[[:space:]]+)?-[a-zA-Z]*(c|e|i|p|r|n)([^a-zA-Z]|$)' '(NIE)' 'ST-09-Behebung zurueckgesetzt: Interpreter-mit-Inline-Code-Glied im Prototyp-Gate entfernt' 'B09 ZF7a ZF7c ZF7d'
mutation_definieren MM6 main 'type == "object" and (.tool_input | type == "object")' 'true' 'ST-13-Behebung zurueckgesetzt: die Eingabepruefung im main-Gate haelt keine Form mehr fest (vorgemessen: S01/S02 sind kein gueltiges JSON und lassen jq unabhaengig vom Filter scheitern, bleiben deshalb blockiert -- nur ZF8a/ZF8b werden durch diese Mutation durchgelassen)' 'ZF8a ZF8b'
mutation_definieren MP8 prototyp 'type == "object" and (.tool_input | type == "object")' 'true' 'ST-13-Behebung zurueckgesetzt: die Eingabepruefung im Prototyp-Gate haelt keine Form mehr fest (vorgemessen: S04/S05 sind kein gueltiges JSON und lassen jq unabhaengig vom Filter scheitern, bleiben deshalb blockiert -- nur ZF8c/ZF8d werden durch diese Mutation durchgelassen)' 'ZF8c ZF8d'
mutation_definieren MM7 main '[0-9]?>>?[[:space:]]*(\/tmp\/([^[:space:].;|&)]|\.[^.[:space:];|&)])*|"?\$\{?(TMPDIR|RUNNER_TEMP|SCRATCH[A-Z_]*)\}?([^[:space:].;|&)]|\.[^.[:space:];|&)])*)([[:space:];|&)]|$)/\5/g' '[0-9]?>>?[[:space:]]*(\/tmp\/[^[:space:];|&)]*|"?\$\{?(TMPDIR|RUNNER_TEMP|SCRATCH[A-Z_]*)\}?[^[:space:];|&)]*)([[:space:];|&)]|$)/\5/g' 'DT-E43-6-Behebung zurueckgesetzt: die ".."-Ausnahme im main-Gate auf die alte, uneingeschraenkte Form zurueckgesetzt (Trennerschutz DT-E43-8 bleibt erhalten)' 'A50 A51'
mutation_definieren MP10 prototyp '[0-9]?>>?[[:space:]]*(\/tmp\/([^[:space:].;|&)]|\.[^.[:space:];|&)])*|"?\$\{?(TMPDIR|RUNNER_TEMP|SCRATCH[A-Z_]*)\}?([^[:space:].;|&)]|\.[^.[:space:];|&)])*)([[:space:];|&)]|$)/\5/g' '[0-9]?>>?[[:space:]]*(\/tmp\/[^[:space:];|&)]*|"?\$\{?(TMPDIR|RUNNER_TEMP|SCRATCH[A-Z_]*)\}?[^[:space:];|&)]*)([[:space:];|&)]|$)/\5/g' 'DT-E43-6-Behebung zurueckgesetzt: die ".."-Ausnahme im Prototyp-Gate auf die alte, uneingeschraenkte Form zurueckgesetzt (Trennerschutz DT-E43-8 bleibt erhalten)' 'B60 B61'
mutation_definieren MM8 main 'length == 1' 'length >= 1' 'N-3: Kardinalitaetspruefung des JSON-Stroms im main-Gate abgeschwaecht' 'S08'
mutation_definieren MP11 prototyp 'length == 1' 'length >= 1' 'N-3: Kardinalitaetspruefung des JSON-Stroms im Prototyp-Gate abgeschwaecht' 'S09'

# --- 11b. Fallklassen der Kopfkommentare (ADR 0002, 6.13 d) -----------
fallklasse_definieren KM-1 main gedeckt 'Fall 1: Dateiaenderung, waehrend HEAD auf main/master steht' 'A12 A13 A48'
fallklasse_definieren KM-2 main gedeckt 'Fall 2: Bash-Befehl, der auf main/master committet' 'A10 A47'
fallklasse_definieren KM-3 main gedeckt 'Fall 2: ... merged' 'A14'
fallklasse_definieren KM-4 main gedeckt 'Fall 2: ... pusht' 'A01 A02 A03 A04 A05 A06 A18 A19 A34 A36 G04 ZF1a ZF1b A38 A39 A40 A41 A42'
fallklasse_definieren KM-5 main gedeckt 'die gaengigen Interpreter mit Inline-Code' 'A15 A27 A28 A29'
fallklasse_definieren KM-6 main gedeckt 'das Anlegen eines Arbeitsbaums auf main' 'A07 A08 A09 A37'
fallklasse_definieren KM-7 main gedeckt 'Mirror-/Wildcard-Pushes' 'A16 A17 A35'
fallklasse_definieren KM-8 main gedeckt 'VORAUSSETZUNG git: fehlt git, blockiert das Gate (Rueckgabewert 2)' 'S03'
fallklasse_definieren KM-9 main gedeckt 'analog zur jq-Wache' 'S06'
fallklasse_definieren GM-1 main grenze 'Interpreter, der mit eigener Datei-API schreibt (ohne Inline-Code im Text)' 'G09'
fallklasse_definieren GM-2 main grenze 'zweiter, auf main ausgecheckter Arbeitsbaum, der ausserhalb dieser Sitzung angelegt wurde' 'G10 A43'
fallklasse_definieren GM-3 main grenze 'git vorhanden, aber kein Arbeitsbaum -- ausserhalb eines Repositories' 'ZF4a ZF4b'
fallklasse_definieren GM-4 main grenze 'BEWUSSTE GRENZE: Kontextwechsel in einem untergeordneten Shell-Aufruf' 'ZF2b ZF2c'
fallklasse_definieren KP-1 prototyp gedeckt 'Importe Richtung 1: Produktionscode importiert aus prototype/' 'B01 B04 B27 P02 B45 B47'
fallklasse_definieren KP-2 prototyp gedeckt 'Importe Richtung 2: Prototyp importiert aus dem Produktionscode' 'B05 B22 ZF6e B46 B50'
fallklasse_definieren KM-10 main gedeckt 'unlesbare Eingabe blockiert (ST-13, E4.3)' 'S01 S02 ZF8a ZF8b S08'
fallklasse_definieren KM-11 main gedeckt 'Subshell in Klammern (N-9, E4.3)' 'ZF2a'
fallklasse_definieren KM-12 main gedeckt 'Shell-Schreibwirkung in einem geschuetzten Kontext, inklusive fluechtiger Ziele mit ".." und "/dev/null" ohne Wortgrenze sowie Trenner hinter fluechtigem Ziel (DT-E43-6, DT-E43-8, E4.3-Nachtrag)' 'A11 A50 A51 A52 A53'
fallklasse_definieren KP-3 prototyp gedeckt 'unlesbare Eingabe blockiert (ST-13, E4.3)' 'S04 S05 ZF8c ZF8d S09'
fallklasse_definieren KP-4 prototyp gedeckt 'Schreibwirkung derselben Befehlsklassen wie das main-Gate: Umleitung, tee, sed -i, Heredoc, Dateiwerkzeuge, Interpreter mit Inline-Code, ed/ex, fluechtige Ziele mit ".." und "/dev/null" ohne Wortgrenze sowie Trenner hinter fluechtigem Ziel (DT-E43-6, DT-E43-8)' 'B09 ZF7a ZF7c ZF7d B53 B54 B55 B56 B57 B58 B59 B60 B61 B62 B63'
fallklasse_definieren GP-1 prototyp grenze 'gemeinsame Abhaengigkeiten werden nicht geprueft (P-10, E4.3)' 'P35'
fallklasse_definieren GP-2 prototyp grenze 'Asymmetrie der Pfadschreibweise in Richtung 2 (Wurzelpfad, Vorspann, src=/href= ohne Schraegstrich oder mit Rueckstrich, doppelter Rueckstrich, mehrfaches ./)' 'L10 L11 L12 L13 L14 L15 L16'
fallklasse_definieren GP-3 prototyp grenze 'symmetrische Luecken beider Richtungen (Leerraum vor der Klammer, @import url(, Leerraum um =, __import__ ohne Punkt)' 'L05 L06 L07 L08'

# --- 11c. Abnahmekriterien (Backlog R3-Q-010; ADR 0002, 6.13 f) -------------------------
abnahmekriterium_definieren R3-Q-010_prototyp_gate_pfadformen fallliste 'B02 B03 B06 ZF5a ZF5b ZF5c ZF6a ZF6b ZF5e B43 B45 B46 B50 B51 ZF6f P01 P05 P09 P27 P30 P31 P32' 'geschlossen mit E4.2 (vormals ST-04/ST-05); Gegenproben P01 P05 P09 P27 P30 P31 P32'
abnahmekriterium_definieren R3-Q-010_prototyp_gate_richtungsgleichheit fallliste 'B07 B08 ZF6c ZF6d B35 B41 B42 B44 B47 B48 B49 P10 P02 B34 P28 P29' 'geschlossen mit E4.2 (vormals P-01); Gegenprobe P10; Richtung 1 zum Vergleich P02 B34; Gegenproben P28 P29'
abnahmekriterium_definieren R3-Q-010_prototyp_gate_schreibwirkung fallliste 'B09 ZF7a ZF7c ZF7d ZF7b P06 P14 P15 P33 B52 B53 B54 B55 B56 B57 B58 B59 P36 P37 P38 B60 B61 B62 P39 B63' 'geschlossen mit E4.3 (vormals ST-09); Gegenproben P06 P14 P15 P33 B52 P36 P37; P38 vorgemessen mit Abweichung vom Behebungsauftrag (rc=2 statt 0), gemeldet, nicht angepasst; DT-E43-6 (E4.3-Nachtrag, 2026-09-23) mit B60 B61 B62, Gegenprobe P39; DT-E43-8 (E4.3-Nachtrag, 2026-09-23) mit B63'
abnahmekriterium_definieren R3-Q-010_gates_unlesbare_eingabe fallliste 'S01 S02 ZF8a ZF8b S04 S05 ZF8c ZF8d G01 P04 G40 P34' 'geschlossen mit E4.3 (vormals ST-13); Gegenproben G01 P04 G40 P34'
abnahmekriterium_definieren R3-Q-010_pruefmittel_je_gate gemischt 'G01 G02 G03 G05 G06 P01 P03 P04 P05 MM1 MM2 MM3 MM4 MM5 MP1 MP2 MP3 MP4 MP5 MM7 MM8 MP10 MP11' 'Zaehlung je Gate, Mutationsmodus MM1-MM5/MP1-MP5 und MM7/MM8/MP10/MP11 (DT-E43-6, N-3), Regressionsschutz G01 G02 G03 G05 G06 P01 P03 P04 P05'
abnahmekriterium_definieren R3-Q-010_main_gate_fremdbelegt fallliste 'A02 A03 A04 A05 A06 A38 A39 A40 A41 A42 A07 A08 A09 S03 G01 G02 G03' 'ST-01 trennscharf im Kontext AK; ST-02/ST-03 behoben; Gegenproben G01 G02 G03'
abnahmekriterium_definieren R3-Q-010_benannte_grenzen fallklassen 'KM-1 KM-2 KM-3 KM-4 KM-5 KM-6 KM-7 KM-8 KM-9 GM-1 GM-2 GM-3 GM-4 KP-1 KP-2 KM-10 KM-11 KM-12 KP-3 KP-4 GP-1 GP-2 GP-3' 'Fallklassen der Kopfkommentare; P-10 benannt (GP-1), nicht geschlossen'

# -----------------------------------------------------------------------------
# 12. Fallliste -- Teil 4.1 der Fallliste: main-Gate, Soll 2
# -----------------------------------------------------------------------------
faelle_4_1_main_soll2() {
  fall A01 main blockierend 2 MK - voll JSON Bash 'Push nach main; Kopfkommentar Fall 2 (pusht)' "$(bj_ph 'git push origin main')"
  fall A02 main blockierend 2 MK - voll JSON Bash 'ST-01 behoben (Commit 0b3510a3fd8b219c82c093b34be3aff50c68f7e0), Fremdbeleg fehlt bis E4.1, im Kontext MK von der Sperre "Push bei HEAD auf main" ueberdeckt (B-1); trennscharf: A38 bis A41' "$(bj_ph "git push origin 'main'")"
  fall A03 main blockierend 2 MK - voll JSON Bash 'ST-01 behoben, im Kontext MK von der Sperre "Push bei HEAD auf main" ueberdeckt (B-1); trennscharf: A38 bis A41' "$(bj_ph 'git push origin "main"')"
  fall A04 main blockierend 2 MK - voll JSON Bash 'ST-01 behoben, im Kontext MK von der Sperre "Push bei HEAD auf main" ueberdeckt (B-1); trennscharf: A38 bis A41' "$(bj_ph 'git push origin main;')"
  fall A05 main blockierend 2 MK - voll JSON Bash 'ST-01 behoben, im Kontext MK von der Sperre "Push bei HEAD auf main" ueberdeckt (B-1); trennscharf: A38 bis A41' "$(bj_ph '(git push origin main)')"
  fall A06 main blockierend 2 MK - voll JSON Bash 'Befehlskette (2026-09-21 unter ST-01 gefuehrt); die Form mit Leerzeichen nach main traf schon das Muster vor 0b3510a (T-4); trennscharf: A42' "$(bj_ph 'git push origin main && echo ok')"
  fall A07 main blockierend 2 MK - voll JSON Bash 'ST-02 behoben' "$(bj_ph 'git worktree add "/tmp/wt" "main"')"
  fall A08 main blockierend 2 MK - voll JSON Bash 'ST-02 behoben' "$(bj_ph 'git worktree add /tmp/wt main;')"
  fall A09 main blockierend 2 MK - voll JSON Bash 'ST-02 behoben' "$(bj_ph "git worktree add /tmp/wt 'main'")"
  fall A10 main blockierend 2 MK - voll JSON Bash 'Kopfkommentar Fall 2 (committet)' "$(bj_ph 'git commit -m x')"
  fall A11 main blockierend 2 MK - voll JSON Bash 'Shell-Schreibwirkung auf main (2026-08-25)' "$(bj_ph 'echo hallo > datei.txt')"
  fall A12 main blockierend 2 MK - voll JSON Write 'Kopfkommentar Fall 1: Dateiaenderung bei HEAD auf main (absoluter Pfad im Projektbaum)' "$(wj_ph '{MK}/frontend/x.ts' 'const a = 1;')"
  fall A13 main blockierend 2 MK - voll JSON Edit 'Kopfkommentar Fall 1 ueber Edit, relativer Pfad' "$(ej 'frontend/x.ts' 'a' 'b')"
  fall A14 main blockierend 2 MK - voll JSON Bash 'Kopfkommentar Fall 2 (merged)' "$(bj_ph 'git merge feature')"
  fall A15 main blockierend 2 MK - voll JSON Bash 'Kopfkommentar: Interpreter mit Inline-Code (2026-08-25, Runde 2 Nr. 2)' "$(bj_ph "python3 -c 'open(\"x\",\"w\").write(\"a\")'")"
  fall A16 main blockierend 2 AK - voll JSON Bash 'Kopfkommentar: Mirror-Push (2026-08-25, Runde 2 Nr. 3)' "$(bj_ph 'git push --mirror origin')"
  fall A17 main blockierend 2 AK - voll JSON Bash 'Wildcard-Refspec (2026-08-25)' "$(bj_ph "git push origin 'refs/heads/*'")"
  fall A18 main blockierend 2 AK - voll JSON Bash 'Push HEAD:main vom Arbeitszweig (2026-08-25)' "$(bj_ph 'git push origin HEAD:main')"
  fall A19 main blockierend 2 AK - voll JSON Bash 'Push mit --force (2026-08-25)' "$(bj_ph 'git push --force origin main')"
  fall A20 main blockierend 2 MK - voll JSON Bash 'historienveraenderndes Verb auf main (2026-08-25, Runde 1)' "$(bj_ph 'git rebase -i HEAD~2')"
  fall A21 main blockierend 2 MK - voll JSON Bash '2026-08-25, Runde 1' "$(bj_ph 'git reset --hard HEAD~1')"
  fall A22 main blockierend 2 MK - voll JSON Bash '2026-08-25, Runde 1' "$(bj_ph 'git am patch.mbox')"
  fall A23 main blockierend 2 MK - voll JSON Bash 'sed -i auf main (2026-08-25)' "$(bj_ph "sed -i 's/a/b/' datei.txt")"
  fall A24 main blockierend 2 MK - voll JSON Bash 'tee auf main (2026-08-25)' "$(bj_ph 'echo x | tee datei.txt')"
  fall A25 main blockierend 2 MK - voll JSON Bash 'rm auf main (2026-08-25)' "$(bj_ph 'rm -f datei.txt')"
  fall A26 main blockierend 2 MK - voll JSON Bash 'dd of= (2026-08-25, Runde 2 Nr. 2)' "$(bj_ph 'dd if=/dev/zero of=datei.bin bs=1 count=1')"
  fall A27 main blockierend 2 MK - voll JSON Bash 'Interpreter perl -e auf main' "$(bj_ph "perl -e 'print 1'")"
  fall A28 main blockierend 2 MK - voll JSON Bash 'Interpreter node -e auf main' "$(bj_ph 'node -e "console.log(1)"')"
  fall A29 main blockierend 2 MK - voll JSON Bash 'Interpreter php -r auf main' "$(bj_ph "php -r 'echo 1;'")"
  fall A30 main blockierend 2 MK - voll JSON Bash 'schreibender git-Verb' "$(bj_ph 'git cherry-pick abc123')"
  fall A31 main blockierend 2 MK - voll JSON Bash 'schreibender git-Verb' "$(bj_ph 'git stash pop')"
  fall A32 main blockierend 2 MK - voll JSON Bash 'Shell-Schreibwirkung' "$(bj_ph 'mv a.txt b.txt')"
  fall A33 main blockierend 2 MK - voll JSON Bash 'Anfuegende Umleitung' "$(bj_ph 'echo x >> datei.txt')"
  fall A34 main blockierend 2 AK - voll JSON Bash 'master gleichgestellt' "$(bj_ph 'git push origin master')"
  fall A35 main blockierend 2 AK - voll JSON Bash 'Sammel-Push --all (2026-08-25)' "$(bj_ph 'git push --all origin')"
  fall A36 main blockierend 2 AK - voll JSON Bash 'Ref-Form refs/for' "$(bj_ph 'git push origin HEAD:refs/for/main')"
  fall A37 main blockierend 2 AK - voll JSON Bash 'Arbeitsbaum auf master vom Arbeitszweig aus (2026-08-25, Runde 2 Nr. 1)' "$(bj_ph 'git worktree add ../wt master')"
  fall G04 main blockierend 2 MK - voll JSON Bash 'gewollte Wirkung laut Kopfkommentar: Push, waehrend HEAD auf main steht; ADR 0002, 6.13 d: Soll 2 (das Probeskript vom 2026-09-21 fuehrte irrtuemlich 0); Kennung G04 bleibt zur Rueckverfolgung' "$(bj_ph 'git push -u origin claude/arbeitszweig')"
  fall A38 main blockierend 2 AK - voll JSON Bash 'ST-01 behoben -- trennscharf im Arbeitszweig-Kontext (DT-E41-01, B-1): hier greift allein die Zielpruefung der Zeichenklassen, nicht die Sperre "Push bei HEAD auf main"' "$(bj_ph "git push origin 'main'")"
  fall A39 main blockierend 2 AK - voll JSON Bash 'ST-01 behoben, trennscharf (DT-E41-01, B-1)' "$(bj_ph 'git push origin "main"')"
  fall A40 main blockierend 2 AK - voll JSON Bash 'ST-01 behoben, trennscharf (DT-E41-01, B-1)' "$(bj_ph 'git push origin main;')"
  fall A41 main blockierend 2 AK - voll JSON Bash 'ST-01 behoben, trennscharf (DT-E41-01, B-1)' "$(bj_ph '(git push origin main)')"
  fall A42 main blockierend 2 AK - voll JSON Bash 'Befehlskette, trennscharf; die Form mit Leerzeichen nach main traf schon das Muster vor 0b3510a (T-4)' "$(bj_ph 'git push origin main && echo ok')"
  fall A44 main blockierend 2 MK - voll JSON Bash 'schreibender git-Verb (2026-08-25)' "$(bj_ph 'git apply patch.diff')"
  fall A45 main blockierend 2 MK - voll JSON Bash 'schreibender git-Verb (2026-08-25)' "$(bj_ph 'git stash apply')"
  fall A46 main blockierend 2 MK - voll JSON Bash 'schreibender git-Verb (2026-08-25)' "$(bj_ph 'git revert HEAD')"
  fall A47 main blockierend 2 MS - voll JSON Bash 'master gleichgestellt (Kopfkommentar Fall 2)' "$(bj_ph 'git commit -m x')"
  fall A48 main blockierend 2 MS - voll JSON Write 'master gleichgestellt (Kopfkommentar Fall 1)' "$(wj_ph '{MS}/frontend/x.ts' 'const a = 1;')"
  fall A49 main blockierend 2 MS - voll JSON Bash 'Shell-Schreibwirkung bei HEAD auf master' "$(bj_ph 'echo hallo > datei.txt')"
  fall A50 main blockierend 2 MK - voll JSON Bash 'Umleitungsziel mit ".." fuehrt in den Arbeitsbaum zurueck, /tmp-Form (DT-E43-6)' "$(bj_ph 'echo x > /tmp/../{MK}/datei.txt')"
  fall A51 main blockierend 2 MK - voll JSON Bash 'Umleitungsziel mit ".." fuehrt in den Arbeitsbaum zurueck, Variablenform (DT-E43-6)' "$(bj_ph 'echo x > "$TMPDIR"/../{MK}/datei.txt')"
  fall A52 main blockierend 2 MK - voll JSON Bash '"/dev/null" ohne Wortgrenze bleibt Schreibwirkung (DT-E43-6)' "$(bj_ph 'echo x > /dev/nullx')"
  fall A53 main blockierend 2 MK - voll JSON Bash 'Trenner hinter fluechtigem Ziel bleibt Schreibwirkung (DT-E43-8)' "$(bj_ph 'echo x > /tmp/x;cp a {MK}/datei.txt')"
  fall ZF1a main blockierend 2 AK - voll JSON Bash 'Zusatzfall 1 (vollqualifizierte Ref-Form), heute erstmals ausgefuehrt; Kontext AK, damit die Zeichenklassen ":" und "+" der Zielpruefung messen und nicht die Sperre "Push bei HEAD auf main" (N-1)' "$(bj_ph 'git push origin HEAD:refs/heads/main')"
  fall ZF1b main blockierend 2 AK - voll JSON Bash 'Zusatzfall 1 (Pluszeichen); Kontext AK, damit die Zeichenklassen ":" und "+" der Zielpruefung messen und nicht die Sperre "Push bei HEAD auf main" (N-1)' "$(bj_ph 'git push origin +main')"
  fall ZF2a main blockierend 2 AK - voll JSON Bash 'Subshell in Klammern erkannt; Grenze ist der untergeordnete Shell-Aufruf (N-9, E4.3)' "$(bj_ph '(cd {ZM} && git commit -m x)')"
  fall ZF3a main blockierend 2 AK - voll JSON Bash 'Zusatzfall 3 / Befund N1 (2026-08-25): cd auf absoluten Pfad eines main-Auscheckstands' "$(bj_ph 'cd {ZM} && git commit -m x')"
  fall ZF3b main blockierend 2 AK - voll JSON Bash 'Zusatzfall 3: relativer Pfad, Hook-CWD = Projektbaum' "$(bj_ph 'cd ../zweiter-main && git commit -m x')"
  fall ZF3c main blockierend 2 AK / voll JSON Bash 'Zusatzfall 3: relativer Pfad, Hook-CWD = / (Aufloesung gegen CLAUDE_PROJECT_DIR)' "$(bj_ph 'cd ../zweiter-main && git commit -m x')"
  fall ZF3d main blockierend 2 AK - voll JSON Bash 'Zusatzfall 3: pushd' "$(bj_ph 'pushd ../zweiter-main && git commit -m x')"
  fall ZF3e main blockierend 2 AK - voll JSON Bash 'Zusatzfall 3: git -C relativ' "$(bj_ph 'git -C ../zweiter-main commit -m x')"
  fall ZF3f main blockierend 2 AK - voll JSON Bash 'Zusatzfall 3: env -C' "$(bj_ph 'env -C ../zweiter-main git commit -m x')"
  fall ZF3g main blockierend 2 AK / voll JSON Bash 'Zusatzfall 3: git -C absolut, Hook-CWD = /' "$(bj_ph 'git -C {ZM} commit -m x')"
  fall ZF3h main blockierend 2 AK - voll JSON Bash 'Zusatzfall 3 / N1: Shell-Schreibwirkung im gewechselten Kontext' "$(bj_ph 'cd ../zweiter-main && sed -i s/a/b/ datei.txt')"
  fall S03 main blockierend 2 MK - ohne-git JSON Bash 'ST-03 behoben: git fehlt im Suchpfad, Gate blockiert mit Meldung auf stderr' "$(bj_ph 'git commit -m x')"
  fall S06 main blockierend 2 MK - ohne-jq JSON Bash 'jq-Wache des main-Gates (Kopfkommentar "analog zur jq-Wache")' "$(bj_ph 'git status')"
}

# -----------------------------------------------------------------------------
# 13. Fallliste -- Teil 4.2 der Fallliste: main-Gate, Soll 0
# -----------------------------------------------------------------------------
faelle_4_2_main_soll0() {
  fall G01 main durchlaufend 0 MK - voll JSON Bash 'Gegenprobe 2026-09-21 (Regressionsschutz ADR 0002, 6.13 f Punkt 2)' "$(bj_ph 'git status')"
  fall G02 main durchlaufend 0 MK - voll JSON Bash 'Ausweg von main herunter (Regressionsschutz)' "$(bj_ph 'git switch -c claude/neu')"
  fall G03 main durchlaufend 0 MK - voll JSON Bash 'neuer Zweig ab main (Falsch-Positiv-Befund 2026-08-25; Regressionsschutz)' "$(bj_ph 'git worktree add -b claude/neu /tmp/wt main')"
  fall G05 main durchlaufend 0 MK - voll JSON Bash 'Suchen und Lesen (Regressionsschutz)' "$(bj_ph 'grep -rn main docs/')"
  fall G06 main durchlaufend 0 MK - voll JSON Bash 'Umleitung in fluechtiges Ziel (Regressionsschutz)' "$(bj_ph 'echo hallo > /dev/null')"
  fall G07 main durchlaufend 0 AK - voll JSON Write 'Fall 1 Gegenprobe: Schreiben auf einem Arbeitszweig' "$(wj_ph '{AK}/frontend/x.ts' 'const a = 1;')"
  fall G08 main durchlaufend 0 MK - voll JSON Write 'Pfad ausserhalb des Projektbaums: Gate nicht zustaendig' "$(wj_ph '/tmp/anderswo/x.ts' 'const a = 1;')"
  fall G09 main grenze 0 MK - voll JSON Bash 'Kopfkommentar: Interpreter, der mit eigener Datei-API schreibt, ohne Inline-Code im Text -- benannte Grenze' "$(bj_ph 'python3 skript.py')"
  fall G10 main grenze 0 AK - voll JSON Bash 'Kopfkommentar: zweiter, auf main ausgecheckter Arbeitsbaum, dessen Pfad nicht im Text steht -- benannte Grenze' "$(bj_ph 'cd "$ZWEITER" && git commit -m x')"
  fall G11 main durchlaufend 0 AK - voll JSON Bash 'Zweigname mit "main" als Teil bleibt frei (2026-08-25)' "$(bj_ph 'git push origin fix/main-seite')"
  fall G12 main durchlaufend 0 MK - voll JSON Bash 'fluechtiges Ziel /tmp' "$(bj_ph 'echo x > /tmp/datei.txt')"
  fall G13 main durchlaufend 0 AK - voll JSON Bash 'Push vom Arbeitszweig (Gegenprobe zu G04)' "$(bj_ph 'git push -u origin claude/arbeitszweig')"
  fall G14 main durchlaufend 0 AK - voll JSON Bash 'Commit auf dem Arbeitszweig (Gegenprobe zu A10)' "$(bj_ph 'git commit -m x')"
  fall G15 main durchlaufend 0 AK - voll JSON Bash 'Shell-Schreiben auf dem Arbeitszweig (Gegenprobe zu A11)' "$(bj_ph 'echo hallo > datei.txt')"
  fall G16 main durchlaufend 0 AK - voll JSON Bash 'cd in Nicht-Git-Verzeichnis (2026-08-25, Runde 4)' "$(bj_ph 'cd /tmp && ls')"
  fall G17 main durchlaufend 0 AK - voll JSON Bash 'cd in Unterverzeichnis des Arbeitszweig-Klons (Runde 4)' "$(bj_ph 'cd docs && git commit -m x')"
  fall G18 main durchlaufend 0 AK - voll JSON Bash 'git -C auf nicht existierenden Pfad (Runde 4)' "$(bj_ph 'git -C /nicht/vorhanden status')"
  fall G19 main durchlaufend 0 MK - voll JSON Bash 'Lesen auf main' "$(bj_ph 'cat datei.txt')"
  fall G20 main durchlaufend 0 MK - voll JSON Bash 'Lesen auf main' "$(bj_ph 'git log --oneline -3')"
  fall G21 main durchlaufend 0 MK - voll JSON Bash 'Lesen auf main' "$(bj_ph 'git diff')"
  fall G22 main durchlaufend 0 AK - voll JSON Bash 'Falsch-Positiv-Kontrolle vom Arbeitszweig aus' "$(bj_ph 'git worktree add -b claude/neu2 /tmp/wt2 main')"
  fall G23 main durchlaufend 0 AK - voll JSON Bash 'Pfad mit Leerzeichen, kein main-Kontext (Runde 4)' "$(bj_ph 'cd "ein pfad/mit leerzeichen" && git commit -m x')"
  fall G24 main durchlaufend 0 AK - voll JSON Bash 'cd - (Runde 4)' "$(bj_ph 'cd - && git status')"
  fall G25 main durchlaufend 0 AK - voll JSON Bash 'Interpreter mit Inline-Code auf dem Arbeitszweig (Gegenprobe zu A15)' "$(bj_ph 'python3 -c "print(1)"')"
  fall G26 main durchlaufend 0 AK - voll JSON Bash 'sed -i auf dem Arbeitszweig (Gegenprobe zu A23)' "$(bj_ph 'sed -i s/a/b/ datei.txt')"
  fall G27 main durchlaufend 0 MK - voll JSON Bash 'Ausweg von main herunter' "$(bj_ph 'git checkout -b claude/neu')"
  fall G28 main durchlaufend 0 MK - voll JSON Bash 'Lesen von main (fetch)' "$(bj_ph 'git fetch origin main')"
  fall G29 main durchlaufend 0 MK - voll JSON Bash 'Lesen' "$(bj_ph 'git branch --show-current')"
  fall G30 main durchlaufend 0 MK - voll JSON Bash 'Kette auf main starten ist kein Schreiben' "$(bj_ph 'make dod')"
  fall G31 main durchlaufend 0 MK - voll JSON Bash 'Umgebungs-Tempverzeichnis ausgenommen' "$(bj_ph 'echo x > "$TMPDIR/datei.txt"')"
  fall ZF2b main grenze 0 AK - voll JSON Bash 'Zusatzfall 2: untergeordneter Shell-Aufruf -- benannte Grenze (Rumpfkommentar "BEWUSSTE GRENZE"), gemessen 0' "$(bj_ph 'bash -c "cd {ZM} && git commit -m x"')"
  fall ZF2c main grenze 0 AK - voll JSON Bash 'Zusatzfall 2: sh -c, gemessen 0' "$(bj_ph "sh -c 'cd {ZM}; git commit -m x'")"
  fall ZF3i main durchlaufend 0 AK - voll JSON Bash 'Zusatzfall 3 Gegenprobe: Kontextwechsel ohne Schreibwirkung' "$(bj_ph 'git -C ../zweiter-main status')"
  fall ZF4a main grenze 0 KR - voll JSON Bash 'Zusatzfall 4: CLAUDE_PROJECT_DIR ohne .git -- Rueckgabewert 0 als bewusste Grenze (Kopfkommentar "VORAUSSETZUNG git")' "$(bj_ph 'git push origin main')"
  fall ZF4b main grenze 0 KR - voll JSON Write 'Zusatzfall 4 mit Dateiwerkzeug' "$(wj_ph '{KR}/x.ts' 'const a = 1;')"
  fall ZF10a main pruefstand 0 MK - voll JSON bash 'Zusatzfall 10: tool_name "bash" statt "Bash" -- Gleichheitspruefung greift nicht, Dateiwerkzeug-Zweig ohne file_path endet 0; heutiger Stand, kein Befund (ADR 0002, 6.13 d)' "$(bj_ph 'git push origin main' 'bash')"
  fall ZF10b main pruefstand 0 MK - voll JSON bash 'Zusatzfall 10, heutiger Stand 0' "$(bj_ph 'git commit -m x' 'bash')"
  fall G36 main durchlaufend 0 AK - voll JSON Bash 'cd in den Arbeitszweig-Klon selbst' "$(bj_ph 'cd {AK} && git commit -m x')"
  fall G37 main durchlaufend 0 AK - voll JSON Bash 'cd ohne Argument' "$(bj_ph 'cd && git status')"
  fall G38 main durchlaufend 0 AK - voll JSON Bash 'mehrfaches cd' "$(bj_ph 'cd docs && cd .. && git status')"
  fall G39 main durchlaufend 0 MS - voll JSON Bash 'Lesen auf master' "$(bj_ph 'git status')"
  fall G40 main durchlaufend 0 AK - voll JSON Read 'Gegenprobe ST-13 (main-Gate, E4.3): synthetisch (Read steht nicht im Matcher); realistische Gegenproben G01, P04. Kontext AK statt MK vorgemessen (in MK blockiert das Dateiwerkzeug-Geleise unabhaengig vom Werkzeugnamen jeden file_path auf main -- Restbefund, nicht Gegenstand von E4.3)' "$(rj 'x')"
  fall G41 main durchlaufend 0 MK - voll JSON Bash 'fluechtiges Ziel /tmp ohne ".." bleibt frei (DT-E43-6, Regressionsschutz)' "$(bj_ph 'echo x > /tmp/datei.txt')"
  fall G42 main durchlaufend 0 MK - voll JSON Bash 'Suchen mit 2>/dev/null bleibt frei (DT-E43-6, Regressionsschutz)' "$(bj_ph 'grep -r x . 2>/dev/null')"
  fall A43 main grenze 0 AK - voll JSON Bash 'Schreiben per Pfad in einen zweiten main-Auscheckstand ohne Kontextwechsel (2026-08-25, zweite Runde Nr. 1): heute 0 -- das ist die im Kopfkommentar benannte Grenze GM-2 (zweiter Arbeitsbaum ausserhalb der Sitzung); seit 2026-08-25 ist die Klasse ueber die worktree-Sperre abgedeckt, nicht ueber die Pfadpruefung' "$(bj_ph "sed -i 's/a/b/' ../zweiter-main/datei.txt")"
  fall L01 main pruefstand 0 AK - voll JSON Bash 'beobachtete Luecke DT-E41-04 (Dynamic Software Tester, 2026-09-23), heute 0; kein Befund des Zustandsberichts, nicht Gegenstand von R3-Q-010; Aufnahme nur als Fortschreibung von ADR 0002, 6.13 c' "$(bj_ph 'git push origin ma"in"')"
  fall L02 main pruefstand 0 AK - voll JSON Bash 'beobachtete Luecke DT-E41-04 (Dynamic Software Tester, 2026-09-23), heute 0; kein Befund des Zustandsberichts, nicht Gegenstand von R3-Q-010; Aufnahme nur als Fortschreibung von ADR 0002, 6.13 c' "$(bj_ph 'git push origin \main')"
  fall L03 main pruefstand 0 AK - voll JSON Bash 'beobachtete Luecke DT-E41-04 (Dynamic Software Tester, 2026-09-23), heute 0; kein Befund des Zustandsberichts, nicht Gegenstand von R3-Q-010; Aufnahme nur als Fortschreibung von ADR 0002, 6.13 c' "$(bj_ph 'git worktree add /tmp/wt ma"in"')"
  fall L04 main pruefstand 0 AK - voll JSON Bash 'beobachtete Luecke DT-E41-04 (Dynamic Software Tester, 2026-09-23), heute 0; kein Befund des Zustandsberichts, nicht Gegenstand von R3-Q-010; Aufnahme nur als Fortschreibung von ADR 0002, 6.13 c' "$(bj_ph 'git worktree add -B "main" /tmp/wt')"
}

# -----------------------------------------------------------------------------
# 14. Fallliste -- Teil 4.3 der Fallliste: main-Gate, unlesbare Eingabe (ROH, ST-13)
# -----------------------------------------------------------------------------
faelle_4_3_main_roh() {
  fall S01 main blockierend 2 MK - voll ROH - 'geschlossen mit E4.3 (vormals ST-13)' ""
  fall S02 main blockierend 2 MK - voll ROH - 'geschlossen mit E4.3 (vormals ST-13)' 'kein json'
  fall ZF8a main blockierend 2 MK - voll ROH - 'geschlossen mit E4.3 (vormals ST-13): tool_input als Zeichenkette blockiert jetzt statt still durchzulaufen' '{"tool_name":"Bash","tool_input":"git push origin main"}'
  fall ZF8b main blockierend 2 MK - voll ROH - 'geschlossen mit E4.3 (vormals ST-13), Dateiwerkzeug' '{"tool_name":"Write","tool_input":"frontend/x.ts"}'
  fall S08 main blockierend 2 MK - voll ROH - 'JSON-Strom mit zwei Objekten, B-4' '{"tool_name":"Bash","tool_input":{"command":"git status"}}{"tool_name":"Bash","tool_input":{"command":"git push origin main"}}'
}

# -----------------------------------------------------------------------------
# 15. Fallliste -- Teil 4.4 der Fallliste: Prototyp-Gate, Soll 2 (Kontext AB)
# -----------------------------------------------------------------------------
faelle_4_4_proto_soll2() {
  fall B01 prototyp blockierend 2 AB - voll JSON Write 'Richtung 1 (Kopfkommentar)' "$(wj_ph 'frontend/src/a.ts' 'import h from "../prototype/helper";')"
  fall B04 prototyp blockierend 2 AB - voll JSON Write 'Richtung 1, Python-Form' "$(wj_ph 'backend/src/a.py' 'from prototype import demo')"
  fall B05 prototyp blockierend 2 AB - voll JSON Write 'Richtung 2 (Kopfkommentar)' "$(wj_ph 'prototype/x.js' 'import a from "../backend/api";')"
  fall B10 prototyp blockierend 2 AB - voll JSON Bash 'Heredoc mit Prototyp-Import (2026-08-25)' "$(bj_ph "$(printf 'cat > frontend/src/a.ts <<EOT\nimport h from "../prototype/helper";\nEOT')")"
  fall P02 prototyp blockierend 2 AB - voll JSON Write 'Richtung 1 mit src= (Gegenprobe zu P-01; Kennung P02 bleibt zur Rueckverfolgung)' "$(wj_ph 'frontend/src/demo.html' '<script src="../prototype/demo.js"></script>')"
  fall B11 prototyp blockierend 2 AB - voll JSON Bash 'Umleitung + Importmuster' "$(bj_ph 'echo "import h from \"../prototype/helper\";" > frontend/src/a.ts')"
  fall B12 prototyp blockierend 2 AB - voll JSON Bash 'sed -i + Importmuster' "$(bj_ph 'sed -i "1i import h from \"../prototype/helper\";" frontend/src/a.ts')"
  fall B13 prototyp blockierend 2 AB - voll JSON Bash 'tee + Importmuster' "$(bj_ph 'echo "import h from \"../prototype/helper\";" | tee frontend/src/a.ts')"
  fall B14 prototyp blockierend 2 AB - voll JSON MultiEdit 'edits[].new_string wird gelesen (2026-08-25)' "$(mej 'frontend/src/a.ts' 'x' 'import h from "../prototype/helper";')"
  fall B15 prototyp blockierend 2 AB - voll JSON Write 'Blockkommentar im Import (2026-08-25, Runde 2 Nr. 5)' "$(wj_ph 'frontend/src/a.ts' 'import h from /* c */ "../prototype/helper";')"
  fall B16 prototyp blockierend 2 AB - voll JSON Write 'mehrzeiliger Import, Prettier-Umbruch (Runde 2 Nr. 4)' "$(wj_ph 'frontend/src/a.ts' "$(printf 'import {\n  h\n} from\n  "../prototype/helper";')")"
  fall B17 prototyp blockierend 2 AB - voll JSON Write 'doppelter Schraegstrich (Rumpfkommentar "BEWUSSTER PREIS")' "$(wj_ph 'frontend/src/a.ts' 'import x from "prototype//y";')"
  fall B18 prototyp blockierend 2 AB - voll JSON Write 'Funktionsform (2026-08-25)' "$(wj_ph 'backend/src/a.py' 'm = importlib.import_module("prototype.demo")')"
  fall B19 prototyp blockierend 2 AB - voll JSON Write 'Funktionsform' "$(wj_ph 'backend/src/a.py' 'm = __import__("prototype.demo")')"
  fall B20 prototyp blockierend 2 AB - voll JSON Write 'Richtung 2, generisches src/' "$(wj_ph 'prototype/x.js' 'import a from "../src/api";')"
  fall B21 prototyp blockierend 2 AB - voll JSON Write 'Richtung 2, deploy/' "$(wj_ph 'prototype/x.js' 'import a from "../deploy/x";')"
  fall B22 prototyp blockierend 2 AB - voll JSON Write 'Richtung 2, Bauwurzel frontend/ (2026-08-25, Runde 1)' "$(wj_ph 'prototype/x.js' 'import a from "../frontend/x";')"
  fall B23 prototyp blockierend 2 AB - voll JSON NotebookEdit 'notebook_path/new_source' "$(nej 'backend/a.ipynb' 'from prototype import demo')"
  fall B24 prototyp blockierend 2 AB - voll JSON Edit 'Edit fuegt Import ein' "$(ej 'frontend/src/a.ts' 'x' 'import h from "../prototype/helper";')"
  fall B25 prototyp blockierend 2 AB - voll JSON Write 'Zeilenkommentar im Import (Befund N2, 2026-08-25)' "$(wj_ph 'frontend/src/a.ts' "$(printf 'import h from // Kommentar\n  "../prototype/helper";')")"
  fall B26 prototyp blockierend 2 AB - voll JSON Write 'verschachtelte Blockkommentare (Befund N3)' "$(wj_ph 'frontend/src/a.ts' 'import h from /* a /* b */ c */ "../prototype/helper";')"
  fall B27 prototyp blockierend 2 AB - voll JSON Write 'Punktform (2026-08-25 als "widerlegt" gefuehrt: wird erkannt)' "$(wj_ph 'backend/src/a.py' 'import prototype.daten')"
  fall B28 prototyp blockierend 2 AB - voll JSON Write 'bewusster Fehlalarm laut Rumpfkommentar "BEWUSSTER PREIS" -- gewollt' "$(wj_ph 'frontend/src/a.ts' '// Verboten: import { h } from "../prototype/helper";')"
  fall B29 prototyp blockierend 2 AB - voll JSON Write 'einfache Anfuehrungszeichen' "$(wj_ph 'frontend/src/a.ts' "import h from '../prototype/helper';")"
  fall B30 prototyp blockierend 2 AB - voll JSON Write 'Template-Literal' "$(wj_ph 'frontend/src/a.ts' 'import h from `../prototype/helper`;')"
  fall B31 prototyp blockierend 2 AB - voll JSON Write 'require( mit Schraegstrich' "$(wj_ph 'frontend/src/a.ts' 'const h = require("../prototype/helper");')"
  fall B32 prototyp blockierend 2 AB - voll JSON Write 'dynamisches import( mit Schraegstrich' "$(wj_ph 'frontend/src/a.ts' 'const h = await import("../prototype/helper");')"
  fall B33 prototyp blockierend 2 AB - voll JSON Write '@import mit Schraegstrich' "$(wj_ph 'frontend/src/a.css' '@import "../prototype/style.css";')"
  fall B34 prototyp blockierend 2 AB - voll JSON Write 'Richtung 1 mit href=' "$(wj_ph 'frontend/src/demo.html' '<link href="../prototype/style.css">')"
  fall B36 prototyp blockierend 2 AB - voll JSON Write 'Alias ~/' "$(wj_ph 'prototype/x.js' 'import a from "~/frontend/x";')"
  fall B37 prototyp blockierend 2 AB - voll JSON Write 'Richtung 2, require( mit ../../' "$(wj_ph 'prototype/x.js' 'const a = require("../../backend/api");')"
  fall B38 prototyp blockierend 2 AB - voll JSON Write 'absoluter Pfad innerhalb des Projektbaums' "$(wj_ph '{AB}/frontend/src/a.ts' 'import h from "../prototype/helper";')"
  fall B39 prototyp blockierend 2 AB - voll JSON Bash 'anfuegendes Heredoc' "$(bj_ph "$(printf 'cat >> frontend/src/a.ts <<'"'"'EOT'"'"'\nimport h from "../prototype/helper";\nEOT')")"
  fall B40 prototyp blockierend 2 AB - voll JSON Bash 'Umleitung mit Python-Form' "$(bj_ph 'printf "%s\n" "from prototype import demo" > backend/src/a.py')"
  fall ZF5d prototyp blockierend 2 AB - voll JSON Write 'Zusatzfall 5: Punktform mit Untermodul wird erkannt -- kein Befund' "$(wj_ph 'backend/src/a.py' 'from prototype.helper import x')"
  fall ZF6e prototyp blockierend 2 AB - voll JSON Write 'Zusatzfall 6: absoluter Alias @/ wird erkannt (Gegenprobe zur Alias-Zeile)' "$(wj_ph 'prototype/x.js' 'import a from "@/backend/api";')"
  fall B43 prototyp blockierend 2 AB - voll JSON Write 'Praefix ./ mit dynamischem import( in Richtung 2 (E4.2, Klasse ST-05)' "$(wj_ph 'prototype/x.js' 'const a = await import("./../backend/api");')"
  fall B44 prototyp blockierend 2 AB - voll JSON Write 'N-5: HTML src= mit ./../ in Richtung 2 (E4.2)' "$(wj_ph 'prototype/demo.html' '<script src="./../backend/app.js"></script>')"
  fall B45 prototyp blockierend 2 AB - voll JSON Write 'B-1 statisch: bare import ohne "from", Richtung 1 (E4.2)' "$(wj_ph 'frontend/src/a.ts' 'import "../prototype";')"
  fall B46 prototyp blockierend 2 AB - voll JSON Write 'B-1 statisch: bare import ohne "from", Richtung 2 (E4.2)' "$(wj_ph 'prototype/x.js' 'import "./../backend/api";')"
  fall B47 prototyp blockierend 2 AB - voll JSON Write 'N-5: a href= ohne Schraegstrich vor "prototype", Richtung 1 (E4.2)' "$(wj_ph 'frontend/src/demo.html' '<a href="../prototype">x</a>')"
  fall B48 prototyp blockierend 2 AB - voll JSON Write 'N-5: img src= mit Rueckstrich-Pfad, Richtung 1 (E4.2)' "$(wj_ph 'frontend/src/demo.html' '<img src="..\prototype\x.png">')"
  fall B49 prototyp blockierend 2 AB - voll JSON Write 'N-5: __import__ mit Punktform, Richtung 2 (E4.2, heute schon 2)' "$(wj_ph 'prototype/x.py' 'm = __import__("frontend.x")')"
  fall B50 prototyp blockierend 2 AB - voll JSON Write 'A2: Verzeichnisimport ohne Schraegstrich, Richtung 2, Bauwurzel backend (E4.2)' "$(wj_ph 'prototype/x.js' 'import x from "../backend";')"
  fall B51 prototyp blockierend 2 AB - voll JSON Write 'A2: Verzeichnisimport ohne Schraegstrich mit ./../../, Richtung 2, Bauwurzel frontend (E4.2)' "$(wj_ph 'prototype/x.ts' "import x from './../../frontend'")"
  fall ZF6f prototyp blockierend 2 AB - voll JSON Write 'Rueckstrich-Pfad in Richtung 2 (E4.2, Zusatz nach DST-E42-01 b)' "$(wj_ph 'prototype/x.js' 'import a from "..\backend\api";')"
  fall ZF7b prototyp blockierend 2 AB - voll JSON Bash 'Interpreterklasse seit E4.3 erkannt, vorher nur wegen des Zeichens >' "$(bj_ph "$(printf 'perl -e '"'"'open(F,">frontend/src/a.ts"); print F "import h from \\"../prototype/helper\\";"'"'"'')")"
  fall ZF10c prototyp pruefstand 2 AB - voll JSON write 'Zusatzfall 10: der Dateiwerkzeug-Pfad prueft den Werkzeugnamen nicht -- blockiert (2); heutiger Stand' "$(wj_ph 'frontend/src/a.ts' 'import h from "../prototype/helper";' 'write')"
  fall S07 prototyp blockierend 2 AB - ohne-jq JSON Write 'jq-Wache des Prototyp-Gates' "$(wj_ph 'frontend/src/a.ts' 'const a = 1;')"
  fall B53 prototyp blockierend 2 AB - voll JSON Bash 'tee ohne Pipe, dieselbe Klasse wie das main-Gate (B-1)' "$(bj_ph "tee frontend/src/a.ts < <(printf '%s\n' 'import h from \"../prototype/helper\";')")"
  fall B54 prototyp blockierend 2 AB - voll JSON Bash 'Dateiwerkzeug mv mit Import im Kommentar (B-2)' "$(bj_ph 'mv /tmp/helper.ts frontend/src/a.ts # import h from "../prototype/helper"')"
  fall B55 prototyp blockierend 2 AB - voll JSON Bash 'ed/ex-Glied mit Import im Kommentar (B-2)' "$(bj_ph "ex -c 'wq' frontend/src/a.ts # import h from \"../prototype/helper\"")"
  fall B56 prototyp blockierend 2 AB - voll JSON Bash 'Dateiwerkzeug dd mit Import im Kommentar (B-2, vorgemessen)' "$(bj_ph 'dd if=/tmp/x of=frontend/src/a.ts # import h from "../prototype/helper"')"
  fall B57 prototyp blockierend 2 AB - voll JSON Bash 'tee ohne Pipe hinter sudo (DT-E43-1)' "$(bj_ph "echo \"import x from '../prototype/a'\" | sudo tee frontend/a.js")"
  fall B58 prototyp blockierend 2 AB - voll JSON Bash 'tee hinter |& (DT-E43-1)' "$(bj_ph "printf '%s' 'import x from \"../prototype/a\"' |& tee frontend/a.js")"
  fall B59 prototyp blockierend 2 AB - voll JSON Bash 'Rscript -e mit Inline-Code (DT-E43-4)' "$(bj_ph "Rscript -e 'writeLines(\"import h from \\\"../prototype/helper\\\";\", \"frontend/src/a.ts\")'")"
  fall B60 prototyp blockierend 2 AB - voll JSON Bash 'Umleitungsziel mit ".." fuehrt in den Arbeitsbaum zurueck, /tmp-Form (DT-E43-6)' "$(bj_ph "echo \"import x from '../prototype/a'\" > /tmp/../{AB}/frontend/a.js")"
  fall B61 prototyp blockierend 2 AB - voll JSON Bash 'Umleitungsziel mit ".." fuehrt in den Arbeitsbaum zurueck, Variablenform (DT-E43-6)' "$(bj_ph "echo \"import x from '../prototype/a'\" > \"\$TMPDIR\"/../{AB}/frontend/a.js")"
  fall B62 prototyp blockierend 2 AB - voll JSON Bash '"/dev/null" ohne Wortgrenze bleibt Schreibwirkung (DT-E43-6)' "$(bj_ph "echo \"import x from '../prototype/a'\" > /dev/nullx")"
  fall B63 prototyp blockierend 2 AB - voll JSON Bash 'Trenner hinter fluechtigem Ziel bleibt Schreibwirkung (DT-E43-8)' "$(bj_ph "echo \"import x from '../prototype/a'\" > /tmp/x;cp a {AB}/frontend/a.js")"
}

# -----------------------------------------------------------------------------
# 16. Fallliste -- Teil 4.5 der Fallliste: Prototyp-Gate, Soll 0 (Kontext AB)
# -----------------------------------------------------------------------------
faelle_4_5_proto_soll0() {
  fall P01 prototyp durchlaufend 0 AB - voll JSON Write 'Import ohne Bezug auf die andere Seite (Regressionsschutz)' "$(wj_ph 'frontend/src/a.ts' 'import x from "./local";')"
  fall P03 prototyp durchlaufend 0 AB - voll JSON Write 'Doku-Ausnahme (Regressionsschutz)' "$(wj_ph 'docs/notiz.md' 'Der Prototyp importiert nichts: import h from "../prototype/helper"; ist verboten.')"
  fall P04 prototyp durchlaufend 0 AB - voll JSON Write 'Prototyp-Datei ohne Import (Regressionsschutz)' "$(wj_ph 'prototype/x.js' 'const a = 1;')"
  fall P05 prototyp durchlaufend 0 AB - voll JSON Edit 'Edit entfernt einen verbotenen Import (Falsch-Positiv-Kontrolle, Regressionsschutz)' "$(ej 'frontend/src/a.ts' 'import h from "../prototype/helper";' 'x')"
  fall P06 prototyp durchlaufend 0 AB - voll JSON Bash 'reines Suchen mit demselben Wortlaut' "$(bj_ph 'grep -rn "import h from \"../prototype/helper\"" frontend/')"
  fall P07 prototyp durchlaufend 0 AB - voll JSON Write 'ausserhalb des Projekts: nicht zustaendig' "$(wj_ph '/tmp/anderswo/a.ts' 'import h from "../prototype/helper";')"
  fall P08 prototyp durchlaufend 0 AB - voll JSON MultiEdit 'MultiEdit entfernt Import' "$(mej 'frontend/src/a.ts' 'import h from "../prototype/helper";' 'x')"
  fall P09 prototyp durchlaufend 0 AB - voll JSON Write 'Richtung 2 ohne Bezug auf Produktionscode' "$(wj_ph 'prototype/x.js' 'import a from "./local";')"
  fall P10 prototyp durchlaufend 0 AB - voll JSON Write 'HTML-Verweis im selben Verzeichnis' "$(wj_ph 'prototype/demo.html' '<script src="./demo.js"></script>')"
  fall P11 prototyp durchlaufend 0 AB - voll JSON Write 'Doku-Ausnahme *.txt' "$(wj_ph 'frontend/notiz.txt' 'import h from "../prototype/helper";')"
  fall P12 prototyp durchlaufend 0 AB - voll JSON Bash 'reines Lesen' "$(bj_ph 'cat frontend/src/a.ts')"
  fall P13 prototyp durchlaufend 0 AB - voll JSON Bash 'Schreibwirkung ohne Importmuster' "$(bj_ph 'echo "siehe prototype/" > notiz.txt')"
  fall P14 prototyp durchlaufend 0 AB - voll JSON Bash 'Interpreter ohne Importmuster (Gegenprobe zu ST-09)' "$(bj_ph "node -e 'console.log(1)'")"
  fall P15 prototyp durchlaufend 0 AB - voll JSON Bash 'Suchen mit dem Wortlaut von ST-04' "$(bj_ph 'grep -rn "require(\"../prototype\")" .')"
  fall P33 prototyp durchlaufend 0 AB - voll JSON Bash 'Gegenprobe zu ST-09 (E4.3): Interpreter mit Inline-Code ohne Importmuster' "$(bj_ph "python3 -c 'print(1)'")"
  fall B52 prototyp durchlaufend 0 AB - voll JSON Bash 'Kopieren ohne Importmuster ist keine Import-Verletzung; Schreibwirkung allein blockiert nicht (E4.3)' "$(bj_ph 'cp ../prototype/helper.js frontend/src/helper.js')"
  fall P34 prototyp durchlaufend 0 AB - voll JSON Read 'Gegenprobe ST-13 (Prototyp-Gate, E4.3): synthetisch (Read steht nicht im Matcher); realistische Gegenproben G01, P04' "$(rj 'x')"
  fall P35 prototyp grenze 0 AB - voll JSON Write 'P-10 (E4.3): gemeinsame Abhaengigkeiten werden nicht geprueft (benannte Grenze)' "$(wj_ph 'prototype/package.json' '{"dependencies": {"react": "18.0.0"}}')"
  fall P16 prototyp durchlaufend 0 AB - voll JSON Write 'aehnlicher Name ohne "prototype"' "$(wj_ph 'frontend/src/a.ts' 'import h from "../prototyp/helper";')"
  fall P17 prototyp durchlaufend 0 AB - voll JSON Write '"prototypes" ist nicht "prototype/"' "$(wj_ph 'frontend/src/a.ts' 'import h from "../prototypes/helper";')"
  fall P18 prototyp durchlaufend 0 AB - voll JSON Write 'Doku-Ausnahme *.md unter Produktionscode' "$(wj_ph 'frontend/README.md' 'import h from "../prototype/helper";')"
  fall P19 prototyp durchlaufend 0 AB - voll JSON Write 'Doku-Ausnahme docs/*' "$(wj_ph 'docs/x.py' 'from prototype import demo')"
  fall P20 prototyp durchlaufend 0 AB - voll JSON Write 'Zeichenkette ohne Importschluesselwort' "$(wj_ph 'frontend/src/a.ts' 'const s = "prototype/helper";')"
  fall P21 prototyp durchlaufend 0 AB - voll JSON Write 'Zeichenkette ohne Importschluesselwort, Richtung 2' "$(wj_ph 'prototype/x.js' 'const s = "backend/api";')"
  fall P22 prototyp durchlaufend 0 AB - voll JSON Bash 'Lesen' "$(bj_ph 'ls prototype/')"
  fall P23 prototyp durchlaufend 0 AB - voll JSON Bash 'Umleitung ohne Bezug auf prototype' "$(bj_ph 'echo "import x from \"./local\";" > frontend/src/a.ts')"
  fall P24 prototyp durchlaufend 0 AB - voll JSON Read 'Werkzeug ohne Inhalt' "$(rj 'frontend/src/a.ts')"
  fall P25 prototyp durchlaufend 0 AB - voll JSON Write 'Write ohne content' "$(wj_ohne_content 'frontend/src/a.ts')"
  fall P26 prototyp durchlaufend 0 AB - voll JSON Write '"prototype_alt" ist nicht "prototype/"' "$(wj_ph 'frontend/src/a.ts' 'import h from "../prototype_alt/helper";')"
  fall P27 prototyp durchlaufend 0 AB - voll JSON Write 'A1 Gegenprobe: Pfad verlaesst den Prototyp nicht (E4.2)' "$(wj_ph 'prototype/x.js' 'import u from "./lib/util";')"
  fall P28 prototyp durchlaufend 0 AB - voll JSON Write 'A1 Gegenprobe: HTML-Pfad relativ zum Dokument ohne ../ (E4.2)' "$(wj_ph 'prototype/demo.html' '<script src="src/main.js"></script>')"
  fall P29 prototyp durchlaufend 0 AB - voll JSON Write 'A1 Gegenprobe: ./ ohne folgendes ../ (HTML) (E4.2)' "$(wj_ph 'prototype/demo.html' '<script src="./app/app.js"></script>')"
  fall P30 prototyp durchlaufend 0 AB - voll JSON Write 'A1 Gegenprobe: ./ ohne folgendes ../ (Import) (E4.2)' "$(wj_ph 'prototype/x.js' 'const c = require("./app/config");')"
  fall P31 prototyp durchlaufend 0 AB - voll JSON Write 'A2 Gegenprobe: "app" ist keine Bauwurzel, kein Verzeichnisimport ohne Schraegstrich (E4.2)' "$(wj_ph 'prototype/components/x.js' 'import a from "../app";')"
  fall P32 prototyp durchlaufend 0 AB - voll JSON Write 'A3 Gegenprobe: "prototype" ohne vorangehenden Pfadtrenner oder Zeichenkettenanfang (E4.2)' "$(wj_ph 'frontend/src/a.ts' 'import x from "es-prototype";')"
  fall L05 prototyp pruefstand 0 AB - voll JSON Write 'beobachtete Luecke A5-Leerraum-require (2026-09-23), heute 0; Entscheid: Fortschreibung ADR 0002, 6.13 c' "$(wj_ph 'frontend/src/a.ts' 'const h = require ("../prototype/helper");')"
  fall L06 prototyp pruefstand 0 AB - voll JSON Write 'beobachtete Luecke A5-atimport-url (2026-09-23), heute 0; Entscheid: Fortschreibung ADR 0002, 6.13 c' "$(wj_ph 'frontend/src/a.css' '@import url("../prototype/theme.css");')"
  fall L07 prototyp pruefstand 0 AB - voll JSON Write 'beobachtete Luecke A5-Leerraum-Gleichheit (2026-09-23), heute 0; Entscheid: Fortschreibung ADR 0002, 6.13 c' "$(wj_ph 'frontend/src/demo.html' '<img src = "../prototype/x.png">')"
  fall L08 prototyp pruefstand 0 AB - voll JSON Write 'beobachtete Luecke A5-import-ohne-Punkt (2026-09-23), heute 0; Entscheid: Fortschreibung ADR 0002, 6.13 c' "$(wj_ph 'backend/src/a.py' "m = __import__('prototype')")"
  fall L09 prototyp pruefstand 0 AB - voll JSON Write 'beobachtete Luecke B-1-dynamisch-unnormalisierter-Pfad (2026-09-23), heute 0; Entscheid: Fortschreibung ADR 0002, 6.13 c' "$(wj_ph '{AB}/./prototype/x.js' 'import a from "./../backend/api";')"
  fall L10 prototyp pruefstand 0 AB - voll JSON Write 'beobachtete Luecke A4-Wurzelpfad (2026-09-23), heute 0; Entscheid: Fortschreibung ADR 0002, 6.13 c' "$(wj_ph 'prototype/demo.html' '<script src="/backend/app.js"></script>')"
  fall L11 prototyp pruefstand 0 AB - voll JSON Write 'beobachtete Luecke A4-beliebiger-Vorspann (2026-09-23), heute 0; Entscheid: Fortschreibung ADR 0002, 6.13 c' "$(wj_ph 'prototype/x.js' 'import a from "../x/../backend/api";')"
  fall B02 prototyp blockierend 2 AB - voll JSON Write 'geschlossen mit E4.2 (vormals ST-04)' "$(wj_ph 'frontend/src/a.ts' 'import h from "../prototype";')"
  fall B03 prototyp blockierend 2 AB - voll JSON Write 'geschlossen mit E4.2 (vormals ST-04)' "$(wj_ph 'frontend/src/a.ts' "import h from '../../prototype'")"
  fall B06 prototyp blockierend 2 AB - voll JSON Write 'geschlossen mit E4.2 (vormals ST-05)' "$(wj_ph 'prototype/x.js' 'import a from "./../backend/api";')"
  fall B07 prototyp blockierend 2 AB - voll JSON Write 'geschlossen mit E4.2 (vormals P-01)' "$(wj_ph 'prototype/demo.html' '<script src="../backend/app.js"></script>')"
  fall B08 prototyp blockierend 2 AB - voll JSON Write 'geschlossen mit E4.2 (vormals P-01)' "$(wj_ph 'prototype/demo.html' '<link href="../frontend/style.css">')"
  fall B09 prototyp blockierend 2 AB - voll JSON Bash 'geschlossen mit E4.3 (vormals ST-09)' "$(bj_ph "$(printf 'python3 -c '"'"'open("frontend/src/a.ts","w").write("import h from \\"../prototype/helper\\";")'"'"'')")"
  fall ZF5a prototyp blockierend 2 AB - voll JSON Write 'geschlossen mit E4.2 (vormals ST-04)' "$(wj_ph 'frontend/src/a.ts' 'const h = require("../prototype");')"
  fall ZF5b prototyp blockierend 2 AB - voll JSON Write 'geschlossen mit E4.2 (vormals ST-04)' "$(wj_ph 'frontend/src/a.ts' 'const h = await import("../prototype");')"
  fall ZF5c prototyp blockierend 2 AB - voll JSON Write 'geschlossen mit E4.2 (vormals ST-04)' "$(wj_ph 'frontend/src/a.css' '@import "../prototype";')"
  fall ZF5e prototyp blockierend 2 AB - voll JSON Write 'geschlossen mit E4.2 (vormals ST-04)' "$(wj_ph 'frontend/src/a.ts' 'import h from "..\prototype\helper";')"
  fall ZF6a prototyp blockierend 2 AB - voll JSON Write 'geschlossen mit E4.2 (vormals ST-05)' "$(wj_ph 'prototype/x.js' 'const a = require("./../backend/api");')"
  fall ZF6b prototyp blockierend 2 AB - voll JSON Write 'geschlossen mit E4.2 (vormals ST-05)' "$(wj_ph 'prototype/x.css' '@import "./../frontend/style.css";')"
  fall ZF6c prototyp blockierend 2 AB - voll JSON Write 'geschlossen mit E4.2 (vormals P-01)' "$(wj_ph 'prototype/demo.html' '<img src="../backend/x.png">')"
  fall ZF6d prototyp blockierend 2 AB - voll JSON Write 'geschlossen mit E4.2 (vormals P-01)' "$(wj_ph 'prototype/demo.html' '<a href="../frontend/index.html">x</a>')"
  fall ZF7a prototyp blockierend 2 AB - voll JSON Bash 'geschlossen mit E4.3 (vormals ST-09, Zusatzfall 7, node -e)' "$(bj_ph "$(printf 'node -e '"'"'require("fs").writeFileSync("frontend/src/a.ts","import h from \\"../prototype/helper\\";")'"'"'')")"
  fall ZF7c prototyp blockierend 2 AB - voll JSON Bash 'geschlossen mit E4.3 (vormals ST-09, Zusatzfall 7, php -r)' "$(bj_ph "$(printf 'php -r '"'"'file_put_contents("frontend/src/a.ts","import h from \\"../prototype/helper\\";");'"'"'')")"
  fall ZF7d prototyp blockierend 2 AB - voll JSON Bash 'geschlossen mit E4.3 (vormals ST-09, Zusatzfall 7, ruby -e)' "$(bj_ph "$(printf 'ruby -e '"'"'File.write("frontend/src/a.ts","import h from \\"../prototype/helper\\";")'"'"'')")"
  fall ZF9 prototyp pruefstand 0 AB - voll JSON Write 'Zusatzfall 9: Reichweite der Ausnahmeliste (.claude/*), heute 0; Prueffall, kein Befund (ADR 0002, 6.13 d)' "$(wj_ph '.claude/hooks/x.sh' 'import h from "../prototype/helper";')"
  fall ZF10d prototyp pruefstand 0 AB - voll JSON bash 'Zusatzfall 10: Bash-Pfad haengt an der Gleichheit "Bash", tool_name "bash" endet 0; heutiger Stand' "$(bj_ph "$(printf 'cat > frontend/src/a.ts <<EOT\nimport h from "../prototype/helper";\nEOT')" 'bash')"
  fall B35 prototyp blockierend 2 AB - voll JSON Write 'geschlossen mit E4.2 (vormals P-01)' "$(wj_ph 'prototype/x.py' 'from backend.api import x')"
  fall B41 prototyp blockierend 2 AB - voll JSON Write 'geschlossen mit E4.2 (vormals P-01)' "$(wj_ph 'prototype/x.py' 'import importlib; m = importlib.import_module("backend.api")')"
  fall B42 prototyp blockierend 2 AB - voll JSON Write 'geschlossen mit E4.2 (vormals P-01)' "$(wj_ph 'prototype/x.py' 'import backend.api')"
  fall P36 prototyp durchlaufend 0 AB - voll JSON Bash 'Dateiwerkzeug mv ohne Importmuster (Gegenprobe zu B54, B-2)' "$(bj_ph 'mv frontend/src/a.ts frontend/src/b.ts')"
  fall P37 prototyp durchlaufend 0 AB - voll JSON Bash 'Suchen mit 2>/dev/null, fluechtiges Ziel ausgenommen (DT-E43-5)' "$(bj_ph "grep -r \"require('../prototype/a')\" . 2>/dev/null")"
  fall P38 prototyp pruefstand 2 AB - voll JSON Bash 'DT-E43-5, vorgemessen: rc=2 statt der im Behebungsauftrag angenommenen 0 -- die Interpreterklasse (python3 -c) matcht auf dem bereinigten Text unabhaengig von der Umleitung nach /dev/null, weil sie nicht auf ein Umleitungszeichen angewiesen ist; Abweichung gemeldet, keine Aenderung ohne Weisung' "$(bj_ph "python3 -c 'print(\"import h from \\\"../prototype/helper\\\"\")' > /dev/null")"
  fall P39 prototyp durchlaufend 0 AB - voll JSON Bash 'fluechtiges Ziel /tmp ohne "..", kein Schreiben in den Baum (DT-E43-6, Regressionsschutz)' "$(bj_ph "echo \"import x from '../prototype/a'\" > /tmp/a.js")"
  fall L12 prototyp pruefstand 0 AB - voll JSON Write 'benannte Grenze GP-2, heute 0; Aufnahme: Fortschreibung 6.13 c' "$(wj_ph 'prototype/demo.html' '<script src="../backend"></script>')"
  fall L13 prototyp pruefstand 0 AB - voll JSON Write 'benannte Grenze GP-2, heute 0; Aufnahme: Fortschreibung 6.13 c' "$(wj_ph 'prototype/demo.html' '<link href="..\frontend\style.css">')"
  fall L14 prototyp pruefstand 0 AB - voll JSON Write 'benannte Grenze GP-2, heute 0; Aufnahme: Fortschreibung 6.13 c' "$(wj_ph 'prototype/x.js' 'import a from "..\\backend\\api";')"
  fall L15 prototyp pruefstand 0 AB - voll JSON Write 'benannte Grenze GP-2, heute 0; Aufnahme: Fortschreibung 6.13 c' "$(wj_ph 'prototype/x.mjs' 'import "./././../backend/x.mjs";')"
  fall L16 prototyp pruefstand 0 AB - voll JSON Write 'benannte Grenze GP-2, heute 0; Aufnahme: Fortschreibung 6.13 c' "$(wj_ph 'prototype/demo.html' '<link href="~/frontend/x.css">')"
}

# -----------------------------------------------------------------------------
# 17. Fallliste -- Teil 4.6 der Fallliste: Prototyp-Gate, unlesbare Eingabe (ROH, ST-13)
# -----------------------------------------------------------------------------
faelle_4_6_proto_roh() {
  fall S04 prototyp blockierend 2 AB - voll ROH - 'geschlossen mit E4.3 (vormals ST-13)' ""
  fall S05 prototyp blockierend 2 AB - voll ROH - 'geschlossen mit E4.3 (vormals ST-13)' 'kein json'
  fall ZF8c prototyp blockierend 2 AB - voll ROH - 'geschlossen mit E4.3 (vormals ST-13), Dateiwerkzeug' '{"tool_name":"Write","tool_input":"frontend/src/a.ts"}'
  fall ZF8d prototyp blockierend 2 AB - voll ROH - 'geschlossen mit E4.3 (vormals ST-13), Bash' '{"tool_name":"Bash","tool_input":"echo x"}'
  fall S09 prototyp blockierend 2 AB - voll ROH - 'JSON-Strom mit zwei Objekten, B-4' '{"tool_name":"Bash","tool_input":{"command":"git status"}}{"tool_name":"Bash","tool_input":{"command":"git push origin main"}}'
}

alle_faelle() {
  faelle_4_1_main_soll2
  faelle_4_2_main_soll0
  faelle_4_3_main_roh
  faelle_4_4_proto_soll2
  faelle_4_5_proto_soll0
  faelle_4_6_proto_roh
}

# -----------------------------------------------------------------------------
# 18. Arbeitsbaum-Vergleich (D19-Grundsatz: der Lauf aendert nicht, worueber er
#     urteilt). Die Erhebung selbst steht in Abschnitt 4a/4b (VOR dem Anlegen
#     der Wegwerfumgebung, N-5); hier nur der Vergleich mit dem Nachher-Stand.
# -----------------------------------------------------------------------------
arbeitsbaum_unveraendert_pruefen() {
  local zweck="$1"
  local nachher_status nachher_hash_inhalt nachher_hash_unversioniert
  local ok=1
  if ! nachher_status=$(schnappschuss_status); then ok=0; fi
  if ! nachher_hash_inhalt=$(schnappschuss_hash_inhalt) || [ -z "$nachher_hash_inhalt" ]; then ok=0; fi
  if ! nachher_hash_unversioniert=$(schnappschuss_hash_unversioniert); then ok=0; fi
  if [ "$VORHER_OK" != 1 ] || [ "$ok" != 1 ] \
      || [ "$VORHER_STATUS" != "$nachher_status" ] \
      || [ "$VORHER_HASH_INHALT" != "$nachher_hash_inhalt" ] \
      || [ "$VORHER_HASH_UNVERSIONIERT" != "$nachher_hash_unversioniert" ]; then
    echo "pretooluse-gates-selbsttest: VERLETZT -- Arbeitsbaum hat sich waehrend $zweck veraendert (oder die Unveraendertheit war nicht belegbar)." >&2
    return 1
  fi
  echo "pretooluse-gates-selbsttest: Arbeitsbaum unveraendert (Statusliste inklusive ignorierter Pfade, Inhaltspruefsummen der versionierten und der unversionierten Dateien vorher/nachher gleich)"
  return 0
}

# -----------------------------------------------------------------------------
# 19. Normalmodus
# -----------------------------------------------------------------------------
normalmodus_ausfuehren() {
  echo "pretooluse-gates-selbsttest: Modus normal, Arbeitsbaum $REPO_WURZEL"
  echo "pretooluse-gates-selbsttest: Wegwerf-Klon auf main: $KLON_COMMIT (Ref $KLON_REF), Zweig main"
  echo "pretooluse-gates-selbsttest: Gate main $GATE_MAIN_AKTIV sha256 $SHA_MAIN_KURZ$GATE_MAIN_ANZEIGE_ZUSATZ"
  echo "pretooluse-gates-selbsttest: Gate prototyp $GATE_PROTOTYP_AKTIV sha256 $SHA_PROTO_KURZ$GATE_PROTOTYP_ANZEIGE_ZUSATZ"

  AKTIV_GATE_MAIN="$GATE_MAIN_AKTIV"
  AKTIV_GATE_PROTOTYP="$GATE_PROTOTYP_AKTIV"
  AKTIVE_MUTATION_GATE=""

  alle_faelle

  echo "pretooluse-gates-selbsttest: Gate main: $MAIN_SOLL2_ANZAHL Faelle mit Soll 2 (Ausgang: blockiert), $MAIN_SOLL0_ANZAHL Faelle mit Soll 0 (Ausgang: durchgelassen)"
  echo "pretooluse-gates-selbsttest: Gate prototyp: $PROTO_SOLL2_ANZAHL Faelle mit Soll 2 (Ausgang: blockiert), $PROTO_SOLL0_ANZAHL Faelle mit Soll 0 (Ausgang: durchgelassen)"
  local klasse zeile_main="pretooluse-gates-selbsttest: Gate main, nach Klasse:" zeile_proto="pretooluse-gates-selbsttest: Gate prototyp, nach Klasse:"
  for klasse in blockierend durchlaufend belegte-luecke grenze pruefstand; do
    zeile_main="$zeile_main $klasse=${KLASSEN_ANZAHL_MAIN[$klasse]:-0}"
    zeile_proto="$zeile_proto $klasse=${KLASSEN_ANZAHL_PROTO[$klasse]:-0}"
  done
  echo "$zeile_main"
  echo "$zeile_proto"
  local je_gate_ok=1
  if [ "${KLASSEN_ANZAHL_MAIN[blockierend]:-0}" -eq 0 ] || [ "${KLASSEN_ANZAHL_MAIN[durchlaufend]:-0}" -eq 0 ] \
      || [ "${KLASSEN_ANZAHL_PROTO[blockierend]:-0}" -eq 0 ] || [ "${KLASSEN_ANZAHL_PROTO[durchlaufend]:-0}" -eq 0 ]; then
    je_gate_ok=0
    echo "pretooluse-gates-selbsttest: ABWEICHUNG -- nicht je Gate mindestens ein Fall blockierend UND ein Fall durchlaufend." >&2
  fi

  local fallklassen_ok=1
  local n=${#FK_ID[@]} j
  for (( j=0; j<n; j++ )); do
    local id="${FK_ID[$j]}" gate="${FK_GATE[$j]}" typ="${FK_TYP[$j]}" text="${FK_TEXT[$j]}" kennungen="${FK_KENNUNGEN[$j]}"
    local ziel_soll=0
    [ "$typ" = "gedeckt" ] && ziel_soll=2
    local treffer=0 fehlend="" k
    for k in $kennungen; do
      if [ -z "${URTEIL_VON[$k]+x}" ]; then fehlend="$fehlend $k"; continue; fi
      if [ "${SOLL_VON[$k]}" = "$ziel_soll" ] && [ "${URTEIL_VON[$k]}" = "BESTANDEN" ]; then treffer=1; fi
    done
    local status
    if [ -n "$fehlend" ]; then
      status="FEHLEND:$fehlend"; fallklassen_ok=0
    elif [ "$treffer" -eq 1 ]; then
      status="gedeckt"
    else
      status="NICHT_GEDECKT"; fallklassen_ok=0
    fi
    echo "pretooluse-gates-selbsttest: Fallklasse $id ($gate, $typ) \"$text\" -> $kennungen: $status"
  done

  local ak_ok=1
  local m=${#AK_ID[@]}
  for (( j=0; j<m; j++ )); do
    local id="${AK_ID[$j]}" domain="${AK_DOMAIN[$j]}" kennungen="${AK_KENNUNGEN[$j]}" anmerkung="${AK_ANMERKUNG[$j]}"
    local fehlend="" k
    for k in $kennungen; do
      case "$domain" in
        fallliste)
          [ -n "${URTEIL_VON[$k]+x}" ] || fehlend="$fehlend $k"
          ;;
        fallklassen)
          local ok=0 fid
          for fid in "${FK_ID[@]}"; do [ "$fid" = "$k" ] && ok=1; done
          [ "$ok" -eq 1 ] || fehlend="$fehlend $k"
          ;;
        gemischt)
          local ok=0 mid
          if [ -n "${URTEIL_VON[$k]+x}" ]; then
            ok=1
          else
            for mid in "${MUT_KENNUNG[@]}"; do [ "$mid" = "$k" ] && ok=1; done
          fi
          [ "$ok" -eq 1 ] || fehlend="$fehlend $k"
          ;;
      esac
    done
    local status="vorhanden"
    if [ -n "$fehlend" ]; then status="FEHLEND:$fehlend"; ak_ok=0; fi
    echo "pretooluse-gates-selbsttest: Abnahmekriterium $id -> $kennungen ($anmerkung): $status"
  done

  local luecken_zeile="pretooluse-gates-selbsttest: belegte Luecken (Soll = heutiger Stand):"
  local luecken_leer=1
  local k
  for k in "${ALLE_KENNUNGEN[@]}"; do
    if [ "${KLASSE_VON[$k]}" = "belegte-luecke" ]; then
      luecken_zeile="$luecken_zeile $k ${BEFUND_VON[$k]:-UNBEKANNT},"
      luecken_leer=0
    fi
  done
  if [ "$luecken_leer" -eq 1 ]; then
    luecken_zeile="$luecken_zeile keine"
  fi
  echo "${luecken_zeile%,}"

  local arbeitsbaum_ok=1
  arbeitsbaum_unveraendert_pruefen "des Laufs" || arbeitsbaum_ok=0

  local gesamt=${#ALLE_KENNUNGEN[@]}
  local bestanden_anzahl=${#BESTANDENE_KENNUNGEN[@]}
  local alle_bestanden=1
  [ "$bestanden_anzahl" -eq "$gesamt" ] || alle_bestanden=0
  local zaehlung_ok=1
  if [ "$MAIN_SOLL2_ANZAHL" -eq 0 ] || [ "$MAIN_SOLL0_ANZAHL" -eq 0 ] || [ "$PROTO_SOLL2_ANZAHL" -eq 0 ] || [ "$PROTO_SOLL0_ANZAHL" -eq 0 ]; then
    zaehlung_ok=0
  fi

  local vollstaendigkeit_ok=1
  if [ "$gesamt" -ne "$ERWARTETE_FAELLE" ]; then
    echo "pretooluse-gates-selbsttest: ABWEICHUNG -- $gesamt statt $ERWARTETE_FAELLE Faelle gezaehlt." >&2
    vollstaendigkeit_ok=0
  fi
  if [ "$VOLLSTAENDIGKEIT_OK" != 1 ]; then vollstaendigkeit_ok=0; fi
  if [ "$je_gate_ok" != 1 ]; then vollstaendigkeit_ok=0; fi

  if [ "${#GEFALLENE_KENNUNGEN[@]}" -gt 0 ]; then
    echo "pretooluse-gates-selbsttest: gefallene Faelle: ${GEFALLENE_KENNUNGEN[*]}" >&2
  fi

  local rc=2
  if [ "$alle_bestanden" -eq 1 ] && [ "$zaehlung_ok" -eq 1 ] && [ "$arbeitsbaum_ok" -eq 1 ] \
      && [ "$fallklassen_ok" -eq 1 ] && [ "$vollstaendigkeit_ok" -eq 1 ] && [ "$ak_ok" -eq 1 ]; then
    rc=0
  fi

  echo "pretooluse-gates-selbsttest: $bestanden_anzahl von $gesamt Faellen bestanden, Rueckgabewert $rc."
  return "$rc"
}

# -----------------------------------------------------------------------------
# 20. Modus --mutationen
# -----------------------------------------------------------------------------
mutationsmodus_ausfuehren() {
  echo "pretooluse-gates-selbsttest: Modus mutationen, Arbeitsbaum $REPO_WURZEL"
  echo "pretooluse-gates-selbsttest: Wegwerf-Klon auf main: $KLON_COMMIT (Ref $KLON_REF), Zweig main"
  echo "pretooluse-gates-selbsttest: Gate main $GATE_MAIN_AKTIV sha256 $SHA_MAIN_KURZ$GATE_MAIN_ANZEIGE_ZUSATZ"
  echo "pretooluse-gates-selbsttest: Gate prototyp $GATE_PROTOTYP_AKTIV sha256 $SHA_PROTO_KURZ$GATE_PROTOTYP_ANZEIGE_ZUSATZ"

  local gesamt_mutationen=${#MUT_KENNUNG[@]}

  # N-4: Grundlinie -- die vollstaendige Fallliste gegen die UNVERAENDERTEN
  # Gate-Dateien (bzw. deren Ueberschreibung, DT-E41-02). Ist sie nicht gruen,
  # ist "ERKANNT" gegenstandslos: der Modus endet hier mit Rueckgabewert 2.
  GRUNDLINIE_MODUS=1
  GRUNDLINIE_GESAMT=0
  GRUNDLINIE_BESTANDEN=0
  GRUNDLINIE_GEFALLEN=()
  AKTIV_GATE_MAIN="$GATE_MAIN_AKTIV"
  AKTIV_GATE_PROTOTYP="$GATE_PROTOTYP_AKTIV"
  alle_faelle
  GRUNDLINIE_MODUS=0
  echo "pretooluse-gates-selbsttest: Grundlinie: $GRUNDLINIE_BESTANDEN von $GRUNDLINIE_GESAMT bestanden"
  if [ "$GRUNDLINIE_GESAMT" -eq 0 ] || [ "$GRUNDLINIE_BESTANDEN" -ne "$GRUNDLINIE_GESAMT" ]; then
    echo "pretooluse-gates-selbsttest: Grundlinie nicht gruen (gefallen: ${GRUNDLINIE_GEFALLEN[*]:-}) -- Mutationen laufen nicht." >&2
    arbeitsbaum_unveraendert_pruefen "der Grundlinie" || true
    echo "pretooluse-gates-selbsttest: 0 von $gesamt_mutationen Mutationen erkannt, Rueckgabewert 2."
    return 2
  fi

  local mutationslauf_ok=1
  local erkannt=0
  local i
  for (( i=0; i<gesamt_mutationen; i++ )); do
    local kennung="${MUT_KENNUNG[$i]}" gate="${MUT_GATE[$i]}" such="${MUT_SUCH[$i]}" ersatz="${MUT_ERSATZ[$i]}" beschreibung="${MUT_BESCHREIBUNG[$i]}" erwartet="${MUT_ERWARTET[$i]}"
    local original
    if [ "$gate" = "main" ]; then original="$GATE_MAIN_AKTIV"; else original="$GATE_PROTOTYP_AKTIV"; fi

    # N-8: Eindeutigkeit je VORKOMMEN, nicht nur je Zeile (grep -oF | wc -l).
    local vorkommen
    vorkommen=$(grep -oF -- "$such" "$original" | wc -l | tr -d ' ')
    if [ "$vorkommen" != "1" ]; then
      echo "MUT $kennung gate=$gate beschreibung=\"$beschreibung\" vorkommen=$vorkommen WIRKUNGSLOS_ODER_MEHRDEUTIG"
      mutationslauf_ok=0
      continue
    fi

    local kopie="$T/mutation-$kennung.sh"
    local inhalt neu
    inhalt=$(cat "$original")
    neu=${inhalt/"$such"/"$ersatz"}
    printf '%s\n' "$neu" > "$kopie"
    chmod +x "$kopie"

    AKTIV_GATE_MAIN="$GATE_MAIN_AKTIV"
    AKTIV_GATE_PROTOTYP="$GATE_PROTOTYP_AKTIV"
    if [ "$gate" = "main" ]; then AKTIV_GATE_MAIN="$kopie"; else AKTIV_GATE_PROTOTYP="$kopie"; fi
    AKTIVE_MUTATION_GATE="$gate"
    MUTATION_GEFALLEN=()
    MUTATION_GEPRUEFT=0

    alle_faelle

    AKTIVE_MUTATION_GATE=""

    local fehlend="" e
    for e in $erwartet; do
      local gefunden=0 g
      for g in "${MUTATION_GEFALLEN[@]:-}"; do [ "$g" = "$e" ] && gefunden=1; done
      [ "$gefunden" -eq 1 ] || fehlend="$fehlend $e"
    done

    local gefallen_liste="(keine)"
    [ "${#MUTATION_GEFALLEN[@]}" -gt 0 ] && gefallen_liste="${MUTATION_GEFALLEN[*]}"

    if [ "${#MUTATION_GEFALLEN[@]}" -eq 0 ]; then
      echo "MUT $kennung gate=$gate beschreibung=\"$beschreibung\" geprueft=$MUTATION_GEPRUEFT gefallen=$gefallen_liste erwartet=$erwartet NICHT_ERKANNT"
      mutationslauf_ok=0
    elif [ -n "$fehlend" ]; then
      echo "MUT $kennung gate=$gate beschreibung=\"$beschreibung\" geprueft=$MUTATION_GEPRUEFT gefallen=$gefallen_liste erwartet=$erwartet TEILWEISE_NICHT_ERKANNT fehlend=$fehlend"
      mutationslauf_ok=0
    else
      echo "MUT $kennung gate=$gate beschreibung=\"$beschreibung\" geprueft=$MUTATION_GEPRUEFT gefallen=$gefallen_liste erwartet=$erwartet ERKANNT"
      erkannt=$((erkannt+1))
    fi
  done

  arbeitsbaum_unveraendert_pruefen "des Mutationslaufs" || mutationslauf_ok=0

  local rc=2
  if [ "$erkannt" -eq "$gesamt_mutationen" ] && [ "$mutationslauf_ok" -eq 1 ]; then rc=0; fi
  echo "pretooluse-gates-selbsttest: $erkannt von $gesamt_mutationen Mutationen erkannt, Rueckgabewert $rc."
  return "$rc"
}

# -----------------------------------------------------------------------------
# 21. Hauptprogramm
# -----------------------------------------------------------------------------
if [ "$MODUS" = "mutationen" ]; then
  mutationsmodus_ausfuehren
  ENDCODE=$?
else
  normalmodus_ausfuehren
  ENDCODE=$?
fi
exit "$ENDCODE"
