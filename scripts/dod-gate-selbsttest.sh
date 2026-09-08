#!/usr/bin/env bash
# =============================================================================
# scripts/dod-gate-selbsttest.sh -- Selbsttest fuer .claude/hooks/dod-gate.sh
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
# SST-P1-01 (Zwischenkontrolle nach Phase 1): SKRIPT_VERZEICHNIS stand vor
# ::VORSPANN-START:: und war im isolierten Kindlauf unbekannt -- fall_z152_153
# (Teil der von fall_z230_231/fall_z252_255 selbst ausgefuehrten
# FALL_REIHENFOLGE) griff darauf zu und starb unter set -u. Hier aus dem
# bereits eingebackenen REPO_WURZEL neu abgeleitet, identisch zur Definition
# oben (Skriptverzeichnis ist "scripts/" unter der Repo-Wurzel).
SKRIPT_VERZEICHNIS="$REPO_WURZEL/scripts"
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
declare -A PRAEDIKAT_GEMELDET=()

# DECKUNGSZEILEN (SST-P1-06/Z-260, O-27 Phase 3; S12-01/S12-02, Runde 12
# statisch; berichtigt 2026-09-08, ADR 0002 6.12.28 f, Nachtrag "Messumfang
# von Z-260, Reihenfolge der Buchhaltung und Vollstaendigkeit des Blocks"):
# jede Deckungsfunktion haengt ihre Ausgabezeile ueber deckungszeile_-
# registrieren hier an, ob im Normalmodus (kumulativ ueber den ganzen Lauf)
# oder in einem isolierten Einzelfall-Kindlauf (dort leer, bis der Fall
# selbst etwas anhaengt). Im Normalmodus laeuft die Buchhaltung der drei
# Abgleichzeilen ("Deckung:", "Kanalabgleich:", "Praedikatabgleich:") ueber
# buchhaltung_abgleich() in ZWEI Erhebungen aus EINER Funktion -- die erste
# registriert sie, BEVOR Z-260 den Block misst (sonst fehlten sie ihm), die
# zweite ERSETZT sie an derselben Stelle, NACHDEM Z-260 gemeldet ist (sonst
# fehlte Z-260 in ihren eigenen Zahlen); eine Wache haelt fest, dass sich
# die von Z-260 gemessenen ersten Zahlen dabei nicht aendern. Die
# Blockdeckung (11 Pflichtetiketten, 6.12.28 f Punkt 7) haelt die Etiketten
# des Feldes in beide Richtungen gegen diese Sollmenge und ist selbst die
# letzte Zeile des Blocks. Der Block wird EINMAL aus diesem Feld ausgegeben
# UND von Z-260 geprueft -- keine zweite, direkt echoende Quelle mehr
# (S12-01: vorher fehlten vier der neun Blockzeilen im Feld, weil sie direkt
# echoten statt zu registrieren; 6.12.28 f: zwei weitere Zeilen erschienen
# ueberhaupt nicht mehr, weil das gelesene Feld nirgends befuellt wurde).
declare -a DECKUNGSZEILEN=()

# deckungszeile_registrieren <zeile> -- haengt EINE Zeile an DECKUNGSZEILEN
# an und gibt ihren Index (0-basiert) auf stdout aus, damit ein Aufrufer,
# der die Zeile SPAETER mit vollstaendigen Zahlen ersetzen muss (die drei
# Abgleichzeilen unten, S12-01-Behebung), sie wiederfindet. Registriert nur
# -- gibt NICHT selbst auf die eigentliche Standardausgabe aus; das macht
# ausschliesslich der Block-Ausgabeschritt in zusammenfassung_und_deckung_-
# ausgeben bzw. der isolierte Lauf von fall_z260 am Ende seiner Registrierung.
deckungszeile_registrieren() {
DECKUNGSZEILEN+=("$1")
printf '%d\n' $(( ${#DECKUNGSZEILEN[@]} - 1 ))
}

# FALL_ZEITGRENZE (SST-P1-02): mechanische Zeitgrenze je Fallfunktion fuer
# den isolierten Kindlauf des Mutationsmodus, statt eines fest verdrahteten
# "timeout 30" fuer ALLE Faelle. Vorgabe 30s. fall_z230_231 fuehrt im
# isolierten Lauf selbst die GANZE FALL_REIHENFOLGE aus (gemessen: einige
# Sekunden je Einzelfall mal rund 90 Faelle) -- 900s Vorgabe plus Reserve.
# fall_z252_255 fuehrt den ganzen Schwaechungslauf (bis zu 35 Schwaechungen
# mal bis zu mehreren Grammatik-Fallfunktionen, je mit eigenem "timeout 30"
# darunter) selbst im isolierten Lauf aus -- 600s, gemessen deutlich unter
# dieser Grenze, mit Reserve fuer einen langsameren Rechner.
declare -A FALL_ZEITGRENZE=(
  ["fall_z230_231"]=900
  ["fall_z252_255"]=600
  ["fall_z260"]=120
)

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
[ -n "$kanal" ] || return 1
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
# PRAEDIKAT_VORRAT (ADR 0002, 6.12.27 b, O-26): abschliessender Wertevorrat
# fuer die Messart, mit der eine Zusicherung ihren Kanal misst. Kombinationen
# wie "gleich+kleiner" sind zulaessig, wenn die Tabelle sie so fuehrt (Z-152)
# -- der Vorrat bindet die EINZELWERTE, nicht jede Kombination einzeln.
# -----------------------------------------------------------------------------
PRAEDIKAT_VORRAT="zeile-woertlich enthaelt gleich einzelfeld leer existiert fehlt ausserhalb kleiner"
praedikat_gueltig() {
local praedikat="$1" teil
[ -n "$praedikat" ] || return 1
IFS='+' read -ra _pt <<< "$praedikat"
for teil in "${_pt[@]}"; do
  case " $PRAEDIKAT_VORRAT " in
    *" $teil "*) ;;
    *) return 1 ;;
  esac
done
return 0
}

# -----------------------------------------------------------------------------
# tabelle_lesen <adr_pfad> (O-27 Phase 3, SST-P1-06, Z-258/Z-260): liest
# Tabelle 6.12.19 EINMAL und fuellt die globalen Arrays tabellen_kennungen,
# zurueckgezogene_kennungen, KANAL_TABELLE, PRAEDIKAT_TABELLE, FALL_TABELLE
# und ZUSICHERUNG_TABELLE. Vormals INLINE in zusammenfassung_und_deckung_aus-
# geben, jetzt ausgelagert (6.2.2: eine Aussage, eine Stelle), damit sowohl
# Z-258 als auch der eigene Einzelfall-Lauf von Z-260 dieselbe Lesung ohne
# zweite Quelle wiederholen koennen. Die vier Assoziativfelder werden GLOBAL
# deklariert ("-g"), weil eine blosse "declare -A" innerhalb dieser Funktion
# sonst NUR fuer die Dauer dieses Aufrufs bestuende (anders als vorher, wo der
# Block direkt im Rumpf von zusammenfassung_und_deckung_ausgeben stand und
# seine "declare -A" bis zum Ende JENER Funktion lebte).
# -----------------------------------------------------------------------------
tabelle_lesen() {
local adr_pfad_tl="$1"
local zeile_tl kennung_tl zeile_maskiert_tl fall_zelle_tl kanal_zelle_tl praedikat_zelle_tl zusicherung_zelle_tl
tabellen_kennungen=()
zurueckgezogene_kennungen=()
declare -gA KANAL_TABELLE=()
declare -gA PRAEDIKAT_TABELLE=()
declare -gA FALL_TABELLE=()
declare -gA ZUSICHERUNG_TABELLE=()
if [ -f "$adr_pfad_tl" ]; then
  while IFS= read -r zeile_tl; do
    kennung_tl=$(printf '%s' "$zeile_tl" | sed -n 's/^| \(Z-[0-9][0-9]*\).*/\1/p')
    [ -n "$kennung_tl" ] || continue
    # Seit 6.12.27 (O-26) traegt die Tabelle SIEBEN Spalten: Kennung, Fall,
    # Kanal, Praedikat, Zusicherung, Mutation, Herkunft. Maskiertes "\|"
    # (Item 7, Runde 6) wird vor der Aufteilung durch \x01 ersetzt.
    zeile_maskiert_tl=$(printf '%s' "$zeile_tl" | sed 's/\\|/\x01/g')
    fall_zelle_tl=$(printf '%s' "$zeile_maskiert_tl" | awk -F'|' '{print $3}' | sed -e 's/^ *//' -e 's/ *$//')
    kanal_zelle_tl=$(printf '%s' "$zeile_maskiert_tl" | awk -F'|' '{print $4}' \
      | sed -e 's/^ *//' -e 's/ *$//' -e 's/\*\*//g' -e 's/`//g')
    praedikat_zelle_tl=$(printf '%s' "$zeile_maskiert_tl" | awk -F'|' '{print $5}' \
      | sed -e 's/^ *//' -e 's/ *$//' -e 's/\*\*//g' -e 's/`//g')
    zusicherung_zelle_tl=$(printf '%s' "$zeile_maskiert_tl" | awk -F'|' '{print $6}')
    # S8-01 (6.12.27 h): eine Zeile ist zurueckgezogen, wenn ihre Kanal-
    # spalte KEINEN Wert des Vorrats traegt (heute allein Z-110, deren
    # Kanal-, Praedikat- und Mutationsspalte je "--" tragen).
    if kanal_gueltig "$kanal_zelle_tl"; then
      tabellen_kennungen+=("$kennung_tl")
      KANAL_TABELLE["$kennung_tl"]="$kanal_zelle_tl"
      PRAEDIKAT_TABELLE["$kennung_tl"]="$praedikat_zelle_tl"
      FALL_TABELLE["$kennung_tl"]="$fall_zelle_tl"
      ZUSICHERUNG_TABELLE["$kennung_tl"]="$zusicherung_zelle_tl"
    else
      zurueckgezogene_kennungen+=("$kennung_tl")
    fi
  done < <(grep '^| Z-' "$adr_pfad_tl")
fi
}

# -----------------------------------------------------------------------------
# schluessel_und_grammatikdeckung <adr_pfad> (ADR 0002, 6.12.27 c/d, O-26):
# haelt die Klassifizierungstabelle 6.12.4 (Schluessel je Kriterium) und die
# Elementtabelle in 6.12.7 (Grammatik-Kuerzel der Lage-Marke) gegen die
# Zusicherungs- bzw. Fallspalte von Tabelle 6.12.19. Erwartet, dass der
# Aufrufer (zusammenfassung_und_deckung_ausgeben) die Arrays
# tabellen_kennungen, FALL_TABELLE und ZUSICHERUNG_TABELLE bereits gefuellt
# hat -- Bash vererbt lokale Variablen dynamisch an aufgerufene Funktionen.
# Rueckgabewert 0 nur bei vollstaendiger Deckung in beide Richtungen
# (Schluessel) bzw. lueckenloser Deckung (Grammatik).
# -----------------------------------------------------------------------------
_schluessel_muster() {
printf '%s' "$1" | sed -E 's/<[^>]*>/\x02/g' | sed -e 's/[.[\*^$()+?{}|\\]/\\&/g' | sed 's/\x02/[^ |`]+/g'
}
schluessel_und_grammatikdeckung() {
local adr_pfad="$1"
local fehler=0

local header4
header4=$(grep -n -E '^\| Beobachtung in der Ausgabe von `make dod` \| Art \| Schl[^ |]*ssel' "$adr_pfad" | head -n1 | cut -d: -f1)
local -a tabelle4_zeilen=()
if [ -n "$header4" ]; then
  while IFS= read -r z4; do
    case "$z4" in "|"*) tabelle4_zeilen+=("$z4") ;; *) break ;; esac
  done < <(tail -n +$((header4 + 2)) "$adr_pfad")
fi

local -a schluessel_liste=()
local z4b s4
for z4b in "${tabelle4_zeilen[@]}"; do
  s4=$(printf '%s' "$z4b" | awk -F'|' '{print $4}')
  case "$s4" in
    *'`'*'`'*)
      schluessel_liste+=("$(printf '%s' "$s4" | sed -n 's/.*`\([^`]*\)`.*/\1/p')")
      ;;
  esac
done

local -a backtick_abschnitte=()
local kk zinh abschnitt
for kk in "${tabellen_kennungen[@]}"; do
  zinh="${ZUSICHERUNG_TABELLE[$kk]:-}"
  while IFS= read -r abschnitt; do
    [ -n "$abschnitt" ] || continue
    backtick_abschnitte+=("$abschnitt")
  done < <(printf '%s' "$zinh" | grep -o '`[^`]*`' | sed -e 's/^`//' -e 's/`$//')
done

local schluessel_ohne_zeile=0
local s5 muster5 treffer5 a5
for s5 in "${schluessel_liste[@]}"; do
  muster5=$(_schluessel_muster "$s5")
  treffer5=0
  for a5 in "${backtick_abschnitte[@]}"; do
    if printf '%s' "$a5" | grep -qE -- "^${muster5}\$"; then treffer5=1; break; fi
  done
  if [ "$treffer5" -eq 0 ]; then
    schluessel_ohne_zeile=$((schluessel_ohne_zeile + 1))
    echo "Schluesseldeckung: Schluessel OHNE Zeile: $s5"
    fehler=1
  fi
done

local fremde_schluessel=0
local passt6 s6 muster6
for a5 in "${backtick_abschnitte[@]}"; do
  case "$a5" in
    "KETTE "*|"LISTE "*|"GATE "*|"D19 "*)
      passt6=0
      for s6 in "${schluessel_liste[@]}"; do
        muster6=$(_schluessel_muster "$s6")
        if printf '%s' "$a5" | grep -qE -- "^${muster6}"; then passt6=1; break; fi
      done
      if [ "$passt6" -eq 0 ]; then
        fremde_schluessel=$((fremde_schluessel + 1))
        echo "Schluesseldeckung: fremder Schluessel ohne Deckung in 6.12.4: $a5"
        fehler=1
      fi
      ;;
  esac
done
echo "Schluesseldeckung: ${#schluessel_liste[@]} Schluessel, $schluessel_ohne_zeile ohne Zeile, $fremde_schluessel fremde Schluessel"

local header7
header7=$(grep -n -E '^\| K[^ |]*rzel \| Element \|' "$adr_pfad" | head -n1 | cut -d: -f1)
local -a tabelle7_zeilen=()
if [ -n "$header7" ]; then
  while IFS= read -r z7; do
    case "$z7" in "|"*) tabelle7_zeilen+=("$z7") ;; *) break ;; esac
  done < <(tail -n +$((header7 + 2)) "$adr_pfad")
fi

local -a kuerzel_liste=()
local z7b s7
for z7b in "${tabelle7_zeilen[@]}"; do
  s7=$(printf '%s' "$z7b" | awk -F'|' '{print $2}' | sed -e 's/^ *//' -e 's/ *$//' -e 's/`//g')
  if [[ "$s7" =~ ^[A-Z]+$ ]]; then
    kuerzel_liste+=("$s7")
  fi
done

local kuerzel_ohne_zeile=0
local ku8 k8 treffer8
for ku8 in "${kuerzel_liste[@]}"; do
  treffer8=0
  for k8 in "${tabellen_kennungen[@]}"; do
    case "${FALL_TABELLE[$k8]:-}" in
      "Grammatik $ku8: "*) treffer8=1; break ;;
    esac
  done
  if [ "$treffer8" -eq 0 ]; then
    kuerzel_ohne_zeile=$((kuerzel_ohne_zeile + 1))
    echo "Grammatikdeckung: Kuerzel OHNE Zeile: $ku8"
    fehler=1
  fi
done

# Gegenrichtung (Z-261, wie schon bei der Aussagendeckung weiter unten,
# 6.12.27 j/S10-05): ein Etikett "Grammatik <KUERZEL>: " in der Fallspalte
# EINER Tabellenzeile, dessen Kuerzel in KEINER Zeile der Elementtabelle
# 6.12.7 steht, ist ein fremdes Etikett -- ohne diese Richtung waere ein
# Tippfehler im Kuerzel eine stille Nichtdeckung.
local fremde_grammatik_etiketten=0
local k8g fall_text8g etikett8g kuerzel8g treffer8g
for k8g in "${tabellen_kennungen[@]}"; do
  fall_text8g="${FALL_TABELLE[$k8g]:-}"
  while IFS= read -r etikett8g; do
    [ -n "$etikett8g" ] || continue
    kuerzel8g=$(printf '%s' "$etikett8g" | sed -E 's/^Grammatik ([A-Z]+): $/\1/')
    treffer8g=0
    for ku8 in "${kuerzel_liste[@]}"; do
      [ "$ku8" = "$kuerzel8g" ] && treffer8g=1 && break
    done
    if [ "$treffer8g" -eq 0 ]; then
      fremde_grammatik_etiketten=$((fremde_grammatik_etiketten + 1))
      echo "Grammatikdeckung: fremdes Etikett ohne Deckung in 6.12.7: $k8g Grammatik $kuerzel8g"
      fehler=1
    fi
  done < <(printf '%s' "$fall_text8g" | grep -oE 'Grammatik [A-Z]+: ')
done
echo "Grammatikdeckung: ${#kuerzel_liste[@]} Kuerzel, $kuerzel_ohne_zeile ohne Zeile, $fremde_grammatik_etiketten fremde Etiketten"

local -a aussage_header_zeilen=()
while IFS= read -r hnum; do
  [ -n "$hnum" ] && aussage_header_zeilen+=("$hnum")
done < <(grep -n -E '^\| K[^ |]*rzel \| Aussage \|' "$adr_pfad" | cut -d: -f1)

local -a aussage_kuerzel_liste=()
local h9 z9b s9
for h9 in "${aussage_header_zeilen[@]}"; do
  local -a tabelle9_zeilen=()
  while IFS= read -r z9; do
    case "$z9" in "|"*) tabelle9_zeilen+=("$z9") ;; *) break ;; esac
  done < <(tail -n +$((h9 + 2)) "$adr_pfad")
  for z9b in "${tabelle9_zeilen[@]}"; do
    s9=$(printf '%s' "$z9b" | awk -F'|' '{print $2}' | sed -e 's/^ *//' -e 's/ *$//' -e 's/`//g')
    if [[ "$s9" =~ ^[A-Z][A-Z0-9]*$ ]]; then
      aussage_kuerzel_liste+=("$s9")
    fi
  done
done

local aussage_ohne_zeile=0
local ku9 k9 treffer9
for ku9 in "${aussage_kuerzel_liste[@]}"; do
  treffer9=0
  for k9 in "${tabellen_kennungen[@]}"; do
    case "${FALL_TABELLE[$k9]:-}" in
      "Aussage $ku9: "*) treffer9=1; break ;;
    esac
  done
  if [ "$treffer9" -eq 0 ]; then
    aussage_ohne_zeile=$((aussage_ohne_zeile + 1))
    echo "Aussagendeckung: Kuerzel OHNE Zeile: $ku9"
    fehler=1
  fi
done

# S10-05 (6.12.27 j): Gegenrichtung UND Etikettwache, dieselbe Begruendung wie
# in 6.12.25 a fuer die Kennungen -- ohne die Gegenrichtung waere ein
# Tippfehler im Kuerzel eine stille Nichtdeckung. Ein Etikett "Aussage
# <KUERZEL>: ", dessen Kuerzel in KEINER der beiden Aussagentabellen steht
# (6.12.9, 6.12.15 -- hier bereits zu aussage_kuerzel_liste zusammengefuehrt),
# ist eine Abweichung (Gegenrichtung); eine Fallspalte, die MEHR ALS EIN
# Etikett traegt (Grammatik ... und Aussage ... oder zwei Aussage ...),
# ebenfalls (Etikettwache).
local fremde_etiketten=0 doppel_etiketten=0
local k10 fall_text10 etikett10 kuerzel10 ak10 treffer10
local -a aussage_etiketten10=() grammatik_etiketten10=()
for k10 in "${tabellen_kennungen[@]}"; do
  fall_text10="${FALL_TABELLE[$k10]:-}"
  aussage_etiketten10=()
  while IFS= read -r etikett10; do
    [ -n "$etikett10" ] && aussage_etiketten10+=("$etikett10")
  done < <(printf '%s' "$fall_text10" | grep -oE 'Aussage [A-Z][A-Z0-9]*: ')
  grammatik_etiketten10=()
  while IFS= read -r etikett10; do
    [ -n "$etikett10" ] && grammatik_etiketten10+=("$etikett10")
  done < <(printf '%s' "$fall_text10" | grep -oE 'Grammatik [A-Z]+: ')
  if [ "$(( ${#aussage_etiketten10[@]} + ${#grammatik_etiketten10[@]} ))" -gt 1 ]; then
    doppel_etiketten=$((doppel_etiketten + 1))
    echo "Aussagendeckung: Doppeletikett in $k10: $fall_text10"
    fehler=1
  fi
  for etikett10 in "${aussage_etiketten10[@]}"; do
    kuerzel10=$(printf '%s' "$etikett10" | sed -E 's/^Aussage ([A-Z][A-Z0-9]*): $/\1/')
    treffer10=0
    for ak10 in "${aussage_kuerzel_liste[@]}"; do
      [ "$ak10" = "$kuerzel10" ] && treffer10=1 && break
    done
    if [ "$treffer10" -eq 0 ]; then
      fremde_etiketten=$((fremde_etiketten + 1))
      echo "Aussagendeckung: fremdes Etikett ohne Deckung in 6.12.9/6.12.15: $k10 Aussage $kuerzel10"
      fehler=1
    fi
  done
done
echo "Aussagendeckung: ${#aussage_kuerzel_liste[@]} Kuerzel, $aussage_ohne_zeile ohne Zeile, $fremde_etiketten fremde Etiketten, $doppel_etiketten Doppeletiketten"

return "$fehler"
}

# -----------------------------------------------------------------------------
# gegenstandsdeckung_schluessel <gate_pfad> (ADR 0002, 6.12.27 j, Punkt 3):
# haelt die SCHLUESSELZEICHENKETTEN aus .claude/hooks/dod-gate.sh SELBST
# (nicht die Aufzaehlung in 6.12.4) gegen die Zusicherungsspalte von Tabelle
# 6.12.19. Erwartet wie schluessel_und_grammatikdeckung, dass der Aufrufer
# tabellen_kennungen und ZUSICHERUNG_TABELLE bereits gefuellt hat (dynamische
# Vererbung lokaler Variablen, siehe dort). Rueckgabewert 0 nur, wenn JEDES
# Literal eine volltreffende Zeile hat.
# -----------------------------------------------------------------------------
_gate_schluessel_muster() {
# Jeder Variablenanteil ($x, ${x}, ${x:-...}) wird -- anders als bei
# _schluessel_muster (die <...>-Platzhalter der ADR-eigenen Notation) -- zu
# einem Platzhalter fuer EIN ODER MEHR WOERTER (6.12.27 j, Punkt 3:
# "$abbruch_d_ziel", "$kand_d_ziel" und "$schluessel_d_ziel" tragen je ZWEI
# Woerter). Reihenfolge: ERST die Variablenanteile durch ein Sentinel-Byte
# ersetzen, DANN den restlichen (rein woertlichen) Text fuer die Verwendung
# als Regex escapen, ZULETZT das Sentinel-Byte durch das Platzhaltermuster
# ersetzen -- sonst wuerde das Escapen die Platzhalter selbst treffen.
printf '%s' "$1" \
  | sed -E 's/\$\{[A-Za-z_][A-Za-z0-9_]*(:-[^}]*)?\}/\x02/g' \
  | sed -E 's/\$[A-Za-z_][A-Za-z0-9_]*/\x02/g' \
  | sed -e 's/[.[\*^$()+?{}|\\]/\\&/g' \
  | sed 's/\x02/.+/g'
}
gegenstandsdeckung_schluessel() {
local gate_pfad="$1"
local fehler=0
local -a roh_inhalte=()

# 1. Fundstellen (Punkt 3.1): erste Argumente von blockieren_mit_zaehlung in
# doppelten Anfuehrungszeichen ...
local treffer11
while IFS= read -r treffer11; do
  [ -n "$treffer11" ] || continue
  roh_inhalte+=("$(printf '%s' "$treffer11" | sed -E 's/^blockieren_mit_zaehlung "//; s/"$//')")
done < <(grep -oE 'blockieren_mit_zaehlung "[^"]*"' "$gate_pfad")

# ... UND Zuweisungen an einen Namen, der auf "_schluessel" endet, je der
# Inhalt der doppelten Anfuehrungszeichen -- einfache Zuweisung ...
while IFS= read -r treffer11; do
  [ -n "$treffer11" ] || continue
  roh_inhalte+=("$(printf '%s' "$treffer11" | sed -E 's/^[A-Za-z_]+_schluessel="//; s/"$//')")
done < <(grep -oE '[A-Za-z_]+_schluessel="[^"]*"' "$gate_pfad")

# ... UND Anfuegungen an ein Feld ("..._schluessel+=(...)").
while IFS= read -r treffer11; do
  [ -n "$treffer11" ] || continue
  roh_inhalte+=("$(printf '%s' "$treffer11" | sed -E 's/^[A-Za-z_]+_schluessel\+=\("//; s/"\)$//')")
done < <(grep -oE '[A-Za-z_]+_schluessel\+=\("[^"]*"\)' "$gate_pfad")

# 2./3. Literal oder nicht (Punkt 3.2): ganz aus einer Variablen bestehend
# ($1, $primaer_schluessel, ${x}) oder leer -- kein Literal, uebergehen.
# Dedupliziert nach EXAKTEM Text (nicht nach Muster).
local -A literal_gesehen11=()
local -a literal_liste11=()
local roh11
for roh11 in "${roh_inhalte[@]}"; do
  [ -n "$roh11" ] || continue
  if [[ "$roh11" =~ ^\$[A-Za-z_][A-Za-z0-9_]*$ ]] \
     || [[ "$roh11" =~ ^\$\{[A-Za-z_][A-Za-z0-9_]*(:-[^}]*)?\}$ ]] \
     || [[ "$roh11" =~ ^\$[0-9]+$ ]]; then
    continue
  fi
  [ -n "${literal_gesehen11[$roh11]:-}" ] && continue
  literal_gesehen11["$roh11"]=1
  literal_liste11+=("$roh11")
done

# 4. Abgleich (Punkt 3.4): je Muster mindestens eine Zeile der Tabelle
# 6.12.19, deren Zusicherungsspalte einen Backtick-Abschnitt traegt, der
# VOLLSTAENDIG auf das Muster passt. Baut dieselben Backtick-Abschnitte wie
# schluessel_und_grammatikdeckung, zusaetzlich mit der jeweils deckenden
# Kennung fuer die Meldung.
local -a bt_abschnitt11=() bt_kennung11=()
local kk11 zinh11 abschnitt11
for kk11 in "${tabellen_kennungen[@]}"; do
  zinh11="${ZUSICHERUNG_TABELLE[$kk11]:-}"
  while IFS= read -r abschnitt11; do
    [ -n "$abschnitt11" ] || continue
    bt_abschnitt11+=("$abschnitt11")
    bt_kennung11+=("$kk11")
  done < <(printf '%s' "$zinh11" | grep -o '`[^`]*`' | sed -e 's/^`//' -e 's/`$//')
done

local literal_ohne_zeile=0
local l11 muster11 idx11 a11 treffer_lok11 deckt11
for l11 in "${literal_liste11[@]}"; do
  muster11=$(_gate_schluessel_muster "$l11")
  treffer_lok11=0
  deckt11=""
  for idx11 in "${!bt_abschnitt11[@]}"; do
    a11="${bt_abschnitt11[$idx11]}"
    if printf '%s' "$a11" | grep -qE -- "^${muster11}\$"; then
      treffer_lok11=1
      deckt11="${bt_kennung11[$idx11]}"
      break
    fi
  done
  if [ "$treffer_lok11" -eq 0 ]; then
    literal_ohne_zeile=$((literal_ohne_zeile + 1))
    echo "Gegenstandsdeckung Schluessel: Literal OHNE Zeile: $l11"
    fehler=1
  else
    echo "Gegenstandsdeckung Schluessel: Literal gedeckt: $l11 -> $deckt11"
  fi
done
echo "Gegenstandsdeckung Schluessel: ${#literal_liste11[@]} Literale, $literal_ohne_zeile ohne Zeile"

return "$fehler"
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
	if [ -n "$${MOCK_TMP_SPUR:-}" ]; then t=$$(mktemp); printf '%s' "$$t" > "$$MOCK_TMP_SPUR"; sleep "$${MOCK_TMP_HALTEZEIT:-0.3}"; rm -f "$$t"; fi
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
# mindestens 300 ms (Vorgabe "sleep 0.3", ueber MOCK_TMP_HALTEZEIT
# ueberschreibbar, zwischen mktemp und rm), damit ein Beobachter ohne eigene
# Wartezeit ein Beobachtungsfenster hat -- ohne diese Haltezeit entstand und
# verschwand die Datei zu schnell, um zuverlaessig erkannt zu werden (in 1
# von 3 Mutationsdurchgaengen verpasst). MOCK_TMP_HALTEZEIT ueberschreibt die
# Haltezeit bei Bedarf (Vorgabe bleibt 300 ms fuer alle Aufrufer -- Z-109
# bindet sich seit 2026-09-06 an "beobachter_start_spur" und braucht die
# Ueberschreibung nicht mehr, die Moeglichkeit bleibt fuer kuenftige Faelle
# bestehen).
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
# GATE_AUFRUF_PROTOKOLL/GATE_AUFRUF_ZAEHLER (ADR 0002, 6.12.27 j, Punkt 4,
# Z-194..Z-197): rufe_gate und rufe_gate_ohne_home sind die EINZIGEN zwei
# Aufrufstellen des Gates in diesem Selbsttest -- jeder Aufruf wird hier mit
# laufender Nummer protokolliert (rc/stdout/stderr je eine Datei), damit am
# Ende der Fallfolge eine Invariante ueber ALLE Aufrufe gemessen werden kann
# statt einer Stichprobe je Pfad (das war die Luecke hinter DT10-06/DT10-07).
# -----------------------------------------------------------------------------
GATE_AUFRUF_PROTOKOLL=$(neu_verzeichnis)
GATE_AUFRUF_ZAEHLER=0
_gate_aufruf_protokollieren() {
GATE_AUFRUF_ZAEHLER=$((GATE_AUFRUF_ZAEHLER + 1))
printf '%s' "$G_RC" > "$GATE_AUFRUF_PROTOKOLL/$GATE_AUFRUF_ZAEHLER.rc"
printf '%s' "$G_STDOUT" > "$GATE_AUFRUF_PROTOKOLL/$GATE_AUFRUF_ZAEHLER.stdout"
printf '%s' "$G_STDERR" > "$GATE_AUFRUF_PROTOKOLL/$GATE_AUFRUF_ZAEHLER.stderr"
}

# -----------------------------------------------------------------------------
# Ausfuehrungsspur (ADR 0002, 6.12.28 b, O-27 (a1)): ab hier ruft rufe_gate
# (und rufe_gate_ohne_home) das Gate NICHT mehr direkt auf, sondern ueber
# eine BYTEGLEICHE Wegwerfkopie ($GATE_SPURKOPIE, EINMAL je Selbsttestlauf
# angelegt, cmp-geprueft), mit "$BASH_BIN" -x, BASH_XTRACEFD auf einen von
# der Subshell des Aufrufers geoeffneten Deskriptor (angehaengt an
# $SPUR_DATEI) und BASH_ENV auf eine Datei, die PS4='+${LINENO}:' setzt.
# Erhebung des Koordinators vom 2026-09-07: PS4 aus der Umgebung wirkt NICHT
# ("env PS4=... bash -x" liefert nur "+ "), BASH_ENV wirkt, BASH_XTRACEFD
# wird aus der Umgebung uebernommen. Die Spur aendert rc/stdout/stderr des
# Gates NICHT (fd 9 ist ein eigener Kanal, von der eigentlichen Standard-
# und Fehlerausgabe getrennt). Ein isolierter Kindlauf des Mutationsmodus
# initialisiert Kopie, Spurdatei und BASH_ENV-Datei NEU, weil dieser ganze
# Block Teil des Vorspanns ist (S10-10-Folge).
# -----------------------------------------------------------------------------
SPUR_VERZEICHNIS=$(neu_verzeichnis)
GATE_SPURKOPIE="$SPUR_VERZEICHNIS/dod-gate-spurkopie.sh"
cp "$GATE" "$GATE_SPURKOPIE"
if cmp -s "$GATE" "$GATE_SPURKOPIE"; then
  SPUR_KOPIE_FEHLGESCHLAGEN=0
else
  SPUR_KOPIE_FEHLGESCHLAGEN=1
  echo "FEHLER  Ausfuehrungsspur: die Wegwerfkopie von $GATE ist nicht bytegleich (cmp)." >&2
fi
SPUR_DATEI="$SPUR_VERZEICHNIS/spur.log"
: > "$SPUR_DATEI"
SPUR_BASH_ENV="$SPUR_VERZEICHNIS/bash_env.sh"
cat > "$SPUR_BASH_ENV" <<'BASHENVEOF'
PS4='+${LINENO}:'
BASHENVEOF

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
    BASH_ENV="$SPUR_BASH_ENV" \
    BASH_XTRACEFD=9 \
    "$BASH_BIN" -x "$GATE_SPURKOPIE" ) 9>>"$SPUR_DATEI" >"$zwischenpfad_stdout" 2>"$zwischenpfad_stderr"
G_RC=$?
G_STDOUT=$(cat "$zwischenpfad_stdout")
G_STDERR=$(cat "$zwischenpfad_stderr")
rm -f "$zwischenpfad_stdout" "$zwischenpfad_stderr"
_gate_aufruf_protokollieren
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
    BASH_ENV="$SPUR_BASH_ENV" \
    BASH_XTRACEFD=9 \
    "$BASH_BIN" -x "$GATE_SPURKOPIE" ) 9>>"$SPUR_DATEI" >"$zwischenpfad_stdout" 2>"$zwischenpfad_stderr"
G_RC=$?
G_STDOUT=$(cat "$zwischenpfad_stdout")
G_STDERR=$(cat "$zwischenpfad_stderr")
rm -f "$zwischenpfad_stdout" "$zwischenpfad_stderr"
_gate_aufruf_protokollieren
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
# $1=Kennung $2=Kanal $3=Fall $4=Zusicherung $5=ok(0/1) $6=erwartet $7=erhalten $8=Praedikat
local kennung="$1" kanal="$2" fall="$3" zusicherung="$4" ok="$5" erwartet="$6" erhalten="$7" praedikat="${8:-}"
gesamt=$((gesamt + 1))
GEMELDETE_KENNUNGEN+=("$kennung")
if ! kanal_gueltig "$kanal"; then
  echo "FEHLER  $kennung: unbekannter Kanal '$kanal' (Vorrat: $KANAL_VORRAT)" >&2
  kanal="$kanal(UNGUELTIG)"
fi
if ! praedikat_gueltig "$praedikat"; then
  echo "FEHLER  $kennung: unbekanntes Praedikat '$praedikat' (Vorrat: $PRAEDIKAT_VORRAT)" >&2
  praedikat="$praedikat(UNGUELTIG)"
fi
KANAL_GEMELDET["$kennung"]="$kanal"
PRAEDIKAT_GEMELDET["$kennung"]="$praedikat"
if [ "$ok" -eq 1 ]; then
  bestanden=$((bestanden + 1))
  printf 'BESTANDEN %s [%s/%s] %s: %s\n' "$kennung" "$kanal" "$praedikat" "$fall" "$zusicherung"
else
  fehlgeschlagene_faelle+=("$kennung $fall: $zusicherung")
  printf 'FEHLGESCHLAGEN %s [%s/%s] %s: %s: erwartet %s, erhalten %s\n' \
    "$kennung" "$kanal" "$praedikat" "$fall" "$zusicherung" "$erwartet" "$erhalten"
fi
}

# pruefe_rc <kennung> <fall> <erwarteter_rc> -- misst den TATSAECHLICHEN
# Rueckgabewert des zuletzt ausgefuehrten rufe_gate/lauf-Aufrufs. Kanal: rc.
pruefe_rc() {
local kennung="$1" fall="$2" erwartet_rc="$3"
local ok=0
[ "$G_RC" = "$erwartet_rc" ] && ok=1
_melde "$kennung" "rc" "$fall" "Rueckgabewert $erwartet_rc" "$ok" "rc=$erwartet_rc" "rc=$G_RC" "gleich"
}

# pruefe_rc_wert <kennung> <fall> <zusicherung> <erwartet> <erhalten_wert> --
# wie pruefe_rc, aber fuer einen ausserhalb von G_RC gelesenen Rueckgabewert
# (z. B. eines direkten "make"-Aufrufs statt des Gates). Kanal: rc.
pruefe_rc_wert() {
local kennung="$1" fall="$2" zusicherung="$3" erwartet="$4" erhalten="$5"
local ok=0
[ "$erhalten" = "$erwartet" ] && ok=1
_melde "$kennung" "rc" "$fall" "$zusicherung" "$ok" "rc=$erwartet" "rc=$erhalten" "gleich"
}

pruefe_stdout_leer() {
local kennung="$1" fall="$2"
local ok=0
[ -z "$G_STDOUT" ] && ok=1
_melde "$kennung" "stdout" "$fall" "Standardausgabe leer" "$ok" "leer" "'$(_kuerzen "$G_STDOUT")'" "leer"
}

pruefe_stderr_leer() {
local kennung="$1" fall="$2"
local ok=0
[ -z "$G_STDERR" ] && ok=1
_melde "$kennung" "stderr" "$fall" "Fehlerausgabe leer" "$ok" "leer" "'$(_kuerzen "$G_STDERR")'" "leer"
}

# pruefe_stdout_enthaelt/pruefe_stderr_enthaelt <kennung> <fall> <zusicherung>
# <text> -- grep -F (fester String, kein Muster) auf G_STDOUT/G_STDERR.
pruefe_stdout_enthaelt() {
local kennung="$1" fall="$2" zusicherung="$3" text="$4"
local ok=0
printf '%s' "$G_STDOUT" | grep -qF -- "$text" && ok=1
_melde "$kennung" "stdout" "$fall" "$zusicherung" "$ok" "stdout enthaelt '$text'" "stdout='$(_kuerzen "$G_STDOUT")'" "enthaelt"
}

pruefe_stderr_enthaelt() {
local kennung="$1" fall="$2" zusicherung="$3" text="$4"
local ok=0
printf '%s' "$G_STDERR" | grep -qF -- "$text" && ok=1
_melde "$kennung" "stderr" "$fall" "$zusicherung" "$ok" "stderr enthaelt '$text'" "stderr='$(_kuerzen "$G_STDERR")'" "enthaelt"
}

pruefe_stderr_zeile() {
# ADR 0002, 6.12.27 b/h (S8-05, O-26): fuer die Wendung "die Zeile ... woert-
# lich" braucht es eine ZEILENhuelle (grep -Fxq), keine Teilzeichenkette --
# Z-040 (KETTE-Eskalation) war ueber pruefe_stderr_enthaelt trennscharf
# UNTERerkannt (DT8-01). Kanal stderr, Praedikat zeile-woertlich (fest).
local kennung="$1" fall="$2" zeile="$3"
local ok=0
printf '%s\n' "$G_STDERR" | grep -Fxq -- "$zeile" && ok=1
_melde "$kennung" "stderr" "$fall" "Fehlerausgabe traegt die Zeile '$zeile' woertlich" \
  "$ok" "$zeile" "stderr='$(_kuerzen "$G_STDERR")'" "zeile-woertlich"
}

# pruefe_selbsttest_zeile <kennung> <fall> <datei> <zeile> -- wie
# pruefe_stderr_zeile, aber auf einer gespeicherten Fehlerausgabe eines
# ZWEITEN Selbsttestaufrufs (Kanal selbsttest, Z-153). Kanal selbsttest,
# Praedikat zeile-woertlich (fest).
pruefe_selbsttest_zeile() {
local kennung="$1" fall="$2" datei="$3" zeile="$4"
local ok=0
grep -Fxq -- "$zeile" "$datei" 2>/dev/null && ok=1
_melde "$kennung" "selbsttest" "$fall" "Fehlerausgabe des zweiten Aufrufs traegt die Zeile '$zeile' woertlich" \
  "$ok" "$zeile" "datei=$datei" "zeile-woertlich"
}

pruefe_stderr_fehlt() {
local kennung="$1" fall="$2" zusicherung="$3" text="$4"
local ok=0
printf '%s' "$G_STDERR" | grep -qF -- "$text" || ok=1
_melde "$kennung" "stderr" "$fall" "$zusicherung" "$ok" "stderr OHNE '$text'" "stderr='$(_kuerzen "$G_STDERR")'" "fehlt"
}

# pruefe_datei <kennung> <fall> <zusicherung> <pfad> <soll: existiert|fehlt>
pruefe_datei() {
local kennung="$1" fall="$2" zusicherung="$3" pfad="$4" soll="$5"
local ok=0 ist
if [ -f "$pfad" ]; then ist="existiert"; else ist="fehlt"; fi
[ "$ist" = "$soll" ] && ok=1
case "$soll" in
  existiert|fehlt) ;;
  *) echo "FEHLER  $kennung: unzulaessiges Praedikat fuer pruefe_datei: '$soll' (nur existiert|fehlt)" >&2 ;;
esac
_melde "$kennung" "datei" "$fall" "$zusicherung" "$ok" "$pfad $soll" "$pfad $ist" "$soll"
}

# pruefe_kein_zaehler_im_verzeichnis <kennung> <fall> <zusicherung>
# <zustandsbasis> -- SST-P1-03 (Zwischenkontrolle nach Phase 1): misst das
# ganze Zustandsverzeichnis auf die Abwesenheit JEDER Datei "zaehler-*",
# statt einer EINEN, fest verdrahteten Hash-Pfades. Der vorherige Bau konnte
# eine Zaehlerdatei unter einem ANDEREN Namen nicht erkennen (belegt: eine
# Gate-Kopie, die "zaehler-deadbeef..." statt des erwarteten Hashs schreibt,
# bestand alle vier Faelle unveraendert). Kanal datei, Praedikat fehlt.
pruefe_kein_zaehler_im_verzeichnis() {
local kennung="$1" fall="$2" zusicherung="$3" zustandsbasis="$4"
local verz="$zustandsbasis/r3cosint/dod-gate"
local ok=0 gefunden=""
if [ ! -d "$verz" ]; then
  ok=1
else
  gefunden=$(find "$verz" -maxdepth 1 -type f -name 'zaehler-*' 2>/dev/null | sort | head -n1)
  [ -z "$gefunden" ] && ok=1
fi
_melde "$kennung" "datei" "$fall" "$zusicherung" "$ok" "keine Datei zaehler-* im Zustandsverzeichnis" \
  "$([ -n "$gefunden" ] && echo "gefunden: $gefunden" || echo "keine Datei zaehler-* (Verzeichnis: $verz)")" "fehlt"
}

# pruefe_datei_ausserhalb <kennung> <fall> <zusicherung> <pfad> <baum> --
# 6.12.27 i c: typisierte Dateihuelle fuer "liegt ausserhalb des geprueften
# Baums" -- der physisch aufgeloeste Pfad (Elternverzeichnis via pwd -P,
# falls die Datei nicht besteht wird der Pfad selbst als nicht aufloesbar
# und damit als "nicht ausserhalb" gewertet -- fail-closed zur Pruefung).
# Kanal datei, Praedikat ausserhalb (fest).
pruefe_datei_ausserhalb() {
local kennung="$1" fall="$2" zusicherung="$3" pfad="$4" baum="$5"
local ok=0 aufgeloest="" baum_aufgeloest
baum_aufgeloest=$( (cd "$baum" 2>/dev/null && pwd -P) || true)
if [ -n "$pfad" ]; then
  # Aufgeloest wird das ENTHALTENDE Verzeichnis -- bei einem Verzeichnispfad
  # es selbst, bei einem Dateipfad sein Elternverzeichnis (dirname). Das
  # traegt auch dann, wenn die BLATT-Datei selbst inzwischen geloescht ist
  # (z. B. eine Wegwerfdatei der Attrappenkette): geprueft wird der PHYSISCH
  # AUFGELOESTE ORT, nicht die Blattdatei.
  if [ -d "$pfad" ]; then
    aufgeloest=$( (cd "$pfad" 2>/dev/null && pwd -P) || true)
  else
    aufgeloest=$( (cd "$(dirname "$pfad")" 2>/dev/null && pwd -P) || true)
  fi
  if [ -n "$aufgeloest" ] && [ -n "$baum_aufgeloest" ]; then
    case "$aufgeloest" in
      "$baum_aufgeloest"|"$baum_aufgeloest"/*) ok=0 ;;
      *) ok=1 ;;
    esac
  fi
fi
_melde "$kennung" "datei" "$fall" "$zusicherung" "$ok" "ausserhalb $baum_aufgeloest" "$pfad -> ${aufgeloest:-nicht aufloesbar}" "ausserhalb"
}

# pruefe_datei_gleich <kennung> <fall> <zusicherung> <erwartet> <erhalten> --
# 6.12.27 i c: typisierte Dateihuelle fuer einen Wertevergleich an einer
# Datei (z. B. eine Pruefsumme) -- MISST, meldet nicht nur, was der Aufrufer
# schon verglichen hat. Kanal datei, Praedikat gleich (fest).
pruefe_datei_gleich() {
local kennung="$1" fall="$2" zusicherung="$3" erwartet="$4" erhalten="$5"
local ok=0
[ "$erhalten" = "$erwartet" ] && ok=1
_melde "$kennung" "datei" "$fall" "$zusicherung" "$ok" "$erwartet" "$erhalten" "gleich"
}

# _zeitmarke -- S10-02 (6.12.27 j): eine Zeitmarke je Beobachtung des
# Beobachterprotokolls, ohne die sich "waehrend des Laufs" im Nachhinein
# nicht mehr pruefen laesst (dieselbe Luecke, die DT5-01 an Z-111 aufgedeckt
# hat, jetzt fuer JEDE Protokollzeile geschlossen statt nur ueber ein
# aeusseres Beobachtungsfenster). $EPOCHREALTIME ist eine Bash-Variable
# (kein eigener Prozess, ab Bash 5.0), der Rueckfall "date +%s.%N" greift
# nur, falls sie einmal fehlt.
_zeitmarke() {
if [ -n "${EPOCHREALTIME:-}" ]; then
  printf '%s' "$EPOCHREALTIME"
else
  date +%s.%N
fi
}

# beobachter_start <protokolldatei> <muster> <tiefe: flach|rekursiv>
#   <verzeichnis>... -- 6.12.27 i c, nachgebessert nach dem Normallauf vom
# 2026-09-06 (88087/19197/7737 Scheintreffer): OHNE Zeitmarke zaehlte die
# Schleife bei jeder Abfrage JEDEN BEREITS BESTEHENDEN Treffer erneut --
# unter /tmp sammeln sich ueber den ganzen Selbsttest hinweg viele
# "tmp.*"/"sperre-*" Eintraege frueherer Faelle an, die nichts mit DIESEM
# Lauf zu tun haben. Jetzt: eine Zeitmarke (leere Datei) VOR dem Start,
# danach zaehlt "find -newer <Marke>" nur, was WAEHREND des Laufs NEU
# entsteht; "-mindepth 1" schliesst das beobachtete Verzeichnis selbst aus
# (sein eigener Name kann das Muster treffen, wenn es z. B. selbst unter
# /tmp/tmp.XXXXXXXXXX liegt).
# Nachgebessert ein zweites Mal nach dem Mutationslauf vom 2026-09-06 (Z-106
# NICHT ERKANNT, belegt an einer von Hand mutierten Kopie): zwei getrennte
# Ursachen. (1) Die vorherige Schleifenform prueft die Stoppdatei VOR der
# Abfrage -- wacht sie mitten im letzten Schlaf (0.1 s) auf und sieht die
# Stoppdatei bereits gesetzt, endet die Schleife OHNE die faellige letzte
# Abfrage. Jetzt Abfrage-dann-Pruefung (do-while): die Schleife bricht erst
# NACH einer Abfrage ab, wenn die Stoppdatei gesetzt ist. (2) "find" ohne
# Tiefenbegrenzung stieg REKURSIV in jedes unter /tmp liegende Verzeichnis
# ab -- ueber den ganzen Selbsttest hinweg sammeln sich dort sehr viele
# "tmp.*"-Verzeichnisse frueherer Faelle an (nie geloescht), ein einzelner
# rekursiver Durchlauf ueber die ganze Menge kann laenger dauern als das
# gesamte Beobachtungsfenster eines Falls (0.3 s). "readdir()" je Verzeichnis
# geschieht bei "find" EINMAL zu Beginn seines Besuchs dort -- eine Datei,
# die WAEHREND eines noch laufenden, tief rekursierenden Aufrufs unmittelbar
# unter /tmp entsteht, wird von DIESEM Aufruf nicht mehr gesehen, selbst wenn
# er noch lief, als sie entstand. Fuer /tmp deshalb "flach" (-maxdepth 1):
# eine schnelle, flache Verzeichnisauflistung statt eines rekursiven
# Durchlaufs -- die dort beobachteten Treffer (Sperr- und Wegwerfdateien)
# liegen immer unmittelbar im beobachteten Verzeichnis. Fuer den geprueften
# Baum bleibt "rekursiv" noetig: eine Mutation kann die Wegwerfdatei auch
# in einem UNTERverzeichnis des Baums entstehen lassen (Z-111, belegt an
# einer von Hand mutierten Kopie -- mit "flach" blieb die Mutation
# unerkannt, weil der Treffer zwei Ebenen unter dem Baum lag); ".git" bleibt
# dabei ausgeschlossen. Setzt die globalen Variablen
# BEOB_PID/BEOB_STOPP/BEOB_PROTOKOLL/BEOB_MARKE fuer pruefe_beobachter.
beobachter_start() {
BEOB_PROTOKOLL="$1"; local muster="$2" tiefe="$3"; shift 3
BEOB_STOPP="${BEOB_PROTOKOLL}.stopp"
BEOB_MARKE="${BEOB_PROTOKOLL}.marke"
: > "$BEOB_PROTOKOLL"
rm -f "$BEOB_STOPP"
: > "$BEOB_MARKE"
local -a verzeichnisse=("$@")
# "flach": Vorher-Liste der NAMEN je Verzeichnis (ein "readdir()", KEIN
# "stat()" je Eintrag) statt "find -newer" -- Befund vom 2026-09-06 (Z-109
# trotz "flach"+"-newer"+"-maxdepth 1" weiterhin verpasst, an einer Diagnose
# mit ausgegebenem Protokoll belegt): "/tmp" haeufte bis zu diesem spaeten
# Fall bereits so viele Eintraege an (nie geloeschte
# "neu_verzeichnis"-Verzeichnisse frueherer Faelle -- in diesem
# Entwicklungs-Sandkasten ueber 90000), dass EIN "find -maxdepth 1 -newer"
# (muss trotz Tiefenbegrenzung JEDEN direkten Eintrag einzeln staten)
# laenger dauert als das ganze Beobachtungsfenster (0.3 s). Ein reiner
# Namensvergleich (Vorher-Liste, dann je Abfrage neue Namen zaehlen) braucht
# kein "stat()".
# WICHTIG (zweiter Befund, selbes Datum): die Vorher-Liste wird deshalb HIER
# -- SYNCHRON, im Aufrufer, VOR dem Rueckgabe dieser Funktion und damit VOR
# dem nachfolgenden "rufe_gate" -- eingesammelt, NICHT im Hintergrund-
# prozess. Sammelte sie dort erst NACH dem Fork (also parallel zu
# "rufe_gate"), konnte bei starkem Rauschen das Einsammeln selbst laenger
# dauern als das 0.3-s-Fenster der Kette -- die WAEHREND dessen neu
# entstandene Wegwerfdatei geriet dann NOCH IN die Vorher-Liste hinein und
# galt faelschlich als "schon vorher da" (belegt: die erwartete Datei fehlte
# im Protokoll, obwohl die Spur ihre Entstehung bestaetigte). Jetzt steht
# die Vorher-Liste fest, BEVOR die Kette ueberhaupt startet. Die
# Verzeichnisliste laeuft in einer eigenen Prozessersetzung, damit
# "nullglob" nicht auf die aufrufende Shell durchschlaegt.
local -A beob_gesehen=()
if [ "$tiefe" = "flach" ]; then
  local verz name
  for verz in "${verzeichnisse[@]}"; do
    [ -d "$verz" ] || continue
    while IFS= read -r name; do
      [ -n "$name" ] && beob_gesehen["$verz/$name"]=1
    done < <(cd "$verz" 2>/dev/null && shopt -s nullglob && for _p in $muster; do printf '%s\n' "$_p"; done)
  done
fi
(
  if [ -n "${SELBSTTEST_SPERRE_FD:-}" ]; then exec {SELBSTTEST_SPERRE_FD}>&- 2>/dev/null || true; fi
  shopt -s nullglob
  local verz pfad name
  # ".../$(basename ...)" forkt einen eigenen Prozess JE EINTRAG -- bei
  # starkem Rauschen macht allein das Forken einen Durchlauf ueber alle
  # Treffer praktisch unbeendbar (belegt: ueber 46 s CPU-Zeit ohne
  # Fortschritt). "${pfad##*/}" ist eine reine Bash-Parametererweiterung
  # ohne eigenen Prozess und bleibt deshalb schnell. Fuer "rekursiv" bleibt
  # "find -newer" (der gepruefte Baum ist klein und nicht verrauscht, ".git"
  # ausgeschlossen).
  while true; do
    local fund aufgeloest
    for verz in "${verzeichnisse[@]}"; do
      [ -d "$verz" ] || continue
      if [ "$tiefe" = "flach" ]; then
        for pfad in "$verz"/$muster; do
          [ -e "$pfad" ] || continue
          name="${pfad##*/}"
          [ -n "${beob_gesehen[$verz/$name]:-}" ] && continue
          beob_gesehen["$verz/$name"]=1
          aufgeloest=$( (cd "$verz" 2>/dev/null && pwd -P) || true)
          [ -n "$aufgeloest" ] && printf '%s\t%s/%s\n' "$(_zeitmarke)" "$aufgeloest" "$name" >> "$BEOB_PROTOKOLL"
        done
      else
        while IFS= read -r fund; do
          [ -n "$fund" ] || continue
          aufgeloest=$( (cd "$(dirname "$fund")" 2>/dev/null && pwd -P) || true)
          [ -n "$aufgeloest" ] && printf '%s\t%s/%s\n' "$(_zeitmarke)" "$aufgeloest" "$(basename "$fund")" >> "$BEOB_PROTOKOLL"
        done < <(find "$verz" -mindepth 1 \( -path "$verz/.git" -o -path "$verz/.git/*" \) -prune -o -newer "$BEOB_MARKE" -name "$muster" -print 2>/dev/null)
      fi
    done
    [ -e "$BEOB_STOPP" ] && break
    sleep 0.1
  done
) &
BEOB_PID=$!
}

# beobachter_start_spur <protokolldatei> <spurdatei> -- 6.12.27 i c,
# Nachbesserung 2026-09-06 (Koordinator-Entscheid nach zwei erfolglosen
# Anlaeufen ueber ein Durchsuchen von /tmp): Z-109 misst nicht mehr durch
# Suchen nach einem Namensmuster in einem ganzen (in diesem Sandkasten
# potenziell stark verrauschten) Verzeichnis, sondern ist an die SPUR
# gebunden, die die Attrappenkette selbst schreibt (MOCK_TMP_SPUR): sie
# nennt den GENAUEN Pfad ihrer eigenen Wegwerfdatei. Der Hintergrundprozess
# pollt alle 0,05 s, ob die Spurdatei besteht und einen Pfad nennt, der
# SELBST (noch) existiert; sobald das zutrifft, wird der physisch
# aufgeloeste Pfad (Elternverzeichnis "cd && pwd -P" plus Basisname) EINMAL
# ins Protokoll geschrieben (kein erneutes Nachsehen noetig -- der Pfad
# aendert sich waehrend eines Laufs nicht). Damit ist die Messung
# unabhaengig von der Zahl anderer Eintraege im beobachteten Verzeichnis.
# Setzt dieselben globalen Variablen wie beobachter_start
# (BEOB_PID/BEOB_STOPP/BEOB_PROTOKOLL) fuer pruefe_beobachter_enthaelt_ausserhalb.
beobachter_start_spur() {
BEOB_PROTOKOLL="$1"; local spurdatei="$2"
BEOB_STOPP="${BEOB_PROTOKOLL}.stopp"
: > "$BEOB_PROTOKOLL"
rm -f "$BEOB_STOPP"
(
  if [ -n "${SELBSTTEST_SPERRE_FD:-}" ]; then exec {SELBSTTEST_SPERRE_FD}>&- 2>/dev/null || true; fi
  local pfad aufgeloest_verz gemeldet=0
  while true; do
    if [ "$gemeldet" -eq 0 ] && [ -s "$spurdatei" ]; then
      pfad=$(cat "$spurdatei" 2>/dev/null)
      if [ -n "$pfad" ] && [ -e "$pfad" ]; then
        aufgeloest_verz=$( (cd "$(dirname "$pfad")" 2>/dev/null && pwd -P) || true)
        if [ -n "$aufgeloest_verz" ]; then
          printf '%s\t%s/%s\n' "$(_zeitmarke)" "$aufgeloest_verz" "$(basename "$pfad")" >> "$BEOB_PROTOKOLL"
          gemeldet=1
        fi
      fi
    fi
    [ -e "$BEOB_STOPP" ] && break
    sleep 0.05
  done
) &
BEOB_PID=$!
}

# pruefe_beobachter <kennung> <fall> <zusicherung> <soll> [<baum>] --
# 6.12.27 i c: beendet den zuletzt mit beobachter_start gestarteten
# Beobachter (Stoppdatei, dann wait; zusaetzlich "kill" als Sicherung, falls
# der Hintergrundprozess die Stoppdatei aus irgendeinem Grund nicht sieht)
# und misst: existiert (mindestens ein verschiedener Treffer), fehlt (kein
# Treffer), ausserhalb (mindestens ein Treffer UND jeder physisch aufgeloeste
# Treffer liegt ausserhalb <baum>). "Treffer" heisst VERSCHIEDENE Dateien --
# das Protokoll kann dieselbe Datei ueber mehrere Abfragen hinweg mehrfach
# tragen, deshalb wird vor dem Zaehlen dedupliziert. Kanal beobachter,
# Praedikat = <soll>. S10-02 (6.12.27 j): jede Protokollzeile traegt seit dem
# Bau eine Zeitmarke vor dem Pfad ("Zeitmarke TAB Pfad") -- Dedup und
# Vergleich nehmen deshalb NUR den Pfadanteil (Feld 2, "cut -f2-"), nicht die
# ganze Zeile; sonst dedupliziert nichts mehr, weil die Zeitmarke bei jeder
# Beobachtung eine andere ist.
PRUEFE_BEOBACHTER_VORRAT="existiert fehlt ausserhalb"
pruefe_beobachter() {
local kennung="$1" fall="$2" zusicherung="$3" soll="$4" baum="${5:-}"
: > "$BEOB_STOPP"
wait "$BEOB_PID" 2>/dev/null
kill "$BEOB_PID" 2>/dev/null || true
local protokoll_dedupliziert
protokoll_dedupliziert=$(cut -f2- "$BEOB_PROTOKOLL" 2>/dev/null | sort -u)
local anzahl
anzahl=$(printf '%s\n' "$protokoll_dedupliziert" | grep -c . 2>/dev/null || true)
[ -n "$anzahl" ] || anzahl=0
local ok=0 baum_aufgeloest=""
case " $PRUEFE_BEOBACHTER_VORRAT " in
  *" $soll "*) ;;
  *)
    echo "FEHLER  $kennung: unzulaessiges Praedikat fuer pruefe_beobachter: '$soll' (Vorrat: $PRUEFE_BEOBACHTER_VORRAT)" >&2
    _melde "$kennung" "beobachter" "$fall" "$zusicherung" 0 "$soll" "unzulaessiges Praedikat" "$soll"
    return
    ;;
esac
case "$soll" in
  existiert) [ "$anzahl" -gt 0 ] && ok=1 ;;
  fehlt) [ "$anzahl" -eq 0 ] && ok=1 ;;
  ausserhalb)
    [ -n "$baum" ] && baum_aufgeloest=$( (cd "$baum" 2>/dev/null && pwd -P) || true)
    if [ "$anzahl" -gt 0 ]; then
      ok=1
      while IFS= read -r zeile; do
        [ -n "$zeile" ] || continue
        case "$zeile" in "$baum_aufgeloest"|"$baum_aufgeloest"/*) ok=0 ;; esac
      done <<<"$protokoll_dedupliziert"
    fi
    ;;
esac
_melde "$kennung" "beobachter" "$fall" "$zusicherung" "$ok" "$soll" "$anzahl verschiedene Treffer (Protokoll: $BEOB_PROTOKOLL)" "$soll"
}

# pruefe_beobachter_enthaelt_ausserhalb <kennung> <fall> <zusicherung>
# <erwarteter_pfad> <baum> -- 6.12.27 i c, Nachbesserung nach dem
# Mutationslauf vom 2026-09-06 (Z-109 NICHT ERKANNT): "pruefe_beobachter ...
# ausserhalb" gegen den GANZEN Beobachtungsort (hier: /tmp) fragt nur "gibt
# es dort waehrend des Laufs irgendetwas Neues, das dem Muster passt, und
# liegt ALLES davon ausserhalb des Baums" -- unter der Mutation (Wache aus,
# Wegwerfdatei bleibt im Baum) faellt DAS GATE selbst aus der Beobachtung
# heraus, aber der Selbsttest legt WAEHREND desselben Laufs SELBST laufend
# eigene "tmp.*"-Verzeichnisse unter /tmp an (Zustandsverzeichnis, Protokoll,
# Zeitmarke -- alle ueber "neu_verzeichnis"/"mktemp -d"). Die liegen ALLE
# ausserhalb des Baums und erfuellen "ausserhalb" folglich SCHEINBAR, ohne
# dass das Gate ueberhaupt etwas beigetragen hat. Diese Huelle bindet die
# Zusicherung stattdessen an EINEN NAMENTLICH BEKANNTEN Pfad -- hier die
# aus MOCK_TMP_SPUR gelesene, physisch aufgeloeste Wegwerfdatei der
# Attrappenkette selbst (dieselbe physische Lage wie das Gate seiner
# eigenen ausgabe_datei zuweist) -- und verlangt: GENAU DIESER Pfad steht
# (dedupliziert) im WAEHREND des Laufs gefuehrten Beobachterprotokoll (also
# tatsaechlich gesehen, nicht nur nachtraeglich vorhanden) UND er liegt
# physisch ausserhalb des Baums. Beendet den Beobachter wie pruefe_beobachter
# (Stoppdatei, wait, kill als Sicherung). Kanal beobachter, Praedikat
# ausserhalb.
pruefe_beobachter_enthaelt_ausserhalb() {
local kennung="$1" fall="$2" zusicherung="$3" erwarteter_pfad="$4" baum="$5"
: > "$BEOB_STOPP"
wait "$BEOB_PID" 2>/dev/null
kill "$BEOB_PID" 2>/dev/null || true
local erwartet_aufgeloest="" erwartet_verz
if [ -n "$erwarteter_pfad" ]; then
  erwartet_verz=$( (cd "$(dirname "$erwarteter_pfad")" 2>/dev/null && pwd -P) || true)
  [ -n "$erwartet_verz" ] && erwartet_aufgeloest="$erwartet_verz/$(basename "$erwarteter_pfad")"
fi
local baum_aufgeloest=""
[ -n "$baum" ] && baum_aufgeloest=$( (cd "$baum" 2>/dev/null && pwd -P) || true)
local gesehen=0 ok=0
# Nachbesserung 2026-09-06, zweite Runde (Koordinator-Entscheid): die erste
# Nachbesserung (ODER-Pruefung auf das Elternverzeichnis) war gegenstandslos
# -- die Messung ist inzwischen an "beobachter_start_spur" gebunden (siehe
# dort), das GENAU den aufgeloesten Spurpfad selbst ins Protokoll schreibt,
# nicht mehr an ein Durchsuchen von /tmp. "gesehen" prueft deshalb wieder
# ausschliesslich den aufgeloesten Spurpfad selbst. S10-02 (6.12.27 j): jede
# Protokollzeile traegt seit dem Bau eine Zeitmarke vor dem Pfad
# ("Zeitmarke TAB Pfad") -- verglichen wird deshalb nur der Pfadanteil
# (Feld 2, "cut -f2-"), nicht die ganze Zeile.
if [ -n "$erwartet_aufgeloest" ] \
   && cut -f2- "$BEOB_PROTOKOLL" 2>/dev/null | grep -qxF "$erwartet_aufgeloest"; then
  gesehen=1
fi
if [ "$gesehen" -eq 1 ]; then
  case "$erwartet_aufgeloest" in
    "$baum_aufgeloest"|"$baum_aufgeloest"/*) ok=0 ;;
    *) ok=1 ;;
  esac
fi
_melde "$kennung" "beobachter" "$fall" "$zusicherung" "$ok" \
  "gesehen und ausserhalb $baum_aufgeloest" \
  "erwartet=${erwartet_aufgeloest:-nicht aufloesbar}, gesehen=$gesehen (Protokoll: $BEOB_PROTOKOLL)" \
  "ausserhalb"
}

# pruefe_json_einzelfeld <kennung> <fall> <feld> -- G_STDOUT ist GENAU EIN
# JSON-Objekt mit GENAU diesem einen Feld (jq, nicht grep -- eine
# Strukturaussage ist keine Textaussage). Kanal: stdout.
pruefe_json_einzelfeld() {
local kennung="$1" fall="$2" feld="$3"
local ok=0
# SST-B5-07: "genau EIN JSON-Objekt" heisst genau ein Element im Eingabe-
# strom -- "jq -e" allein liefert 0 schon, wenn IRGENDEIN Wert (z. B. das
# LETZTE von zwei aneinandergehaengten Objekten) passt; "-es" (slurp) baut
# ein Array aus ALLEN gelesenen Werten, "length == 1" erzwingt, dass es
# wirklich nur einer war.
if printf '%s' "$G_STDOUT" | jq -es --arg f "$feld" \
     'length == 1 and (.[0] | type == "object" and (keys == [$f]))' >/dev/null 2>&1 \
   && [ "$(printf '%s' "$G_STDOUT" | jq -es --arg f "$feld" \
     'length == 1 and (.[0] | type == "object" and (keys == [$f]))' 2>/dev/null)" = "true" ]; then
  ok=1
fi
_melde "$kennung" "stdout" "$fall" "Standardausgabe ist genau ein JSON-Objekt mit einzigem Feld $feld" \
  "$ok" "{\"$feld\": ...}" "stdout='$(_kuerzen "$G_STDOUT")'" "einzelfeld"
}

# pruefe_zaehler <kennung> <fall> <zaehlerdatei> <erwarteter_stand> -- liest
# die ZWEITE Zeile der Zaehlerdatei (der Zaehlerstand, siehe dod-gate.sh).
pruefe_zaehler() {
local kennung="$1" fall="$2" datei="$3" erwartet="$4"
local ok=0 erhalten
erhalten=$(sed -n '2p' "$datei" 2>/dev/null || true)
[ "$erhalten" = "$erwartet" ] && ok=1
_melde "$kennung" "zaehler" "$fall" "Zaehlerstand $erwartet" "$ok" "$erwartet" "'$erhalten' (Datei: $datei)" "gleich"
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
_melde "$kennung" "zaehler" "$fall" "Zaehlerdatei traegt Schluessel $erwartet" "$ok" "$erwartet" "'$erhalten' (Datei: $datei)" "gleich"
}

# zaehler_pfad <zustand> <fallkey> -- baut den Pfad der Zaehlerdatei aus dem
# Zustandsverzeichnis und dem Session-Schluessel (fallkey), genau wie
# dod-gate.sh ihn selbst bildet (sha256sum des session_id-Feldes).
zaehler_pfad() {
printf '%s/r3cosint/dod-gate/zaehler-%s' "$1" "$(printf '%s' "$2" | sha256sum | cut -d' ' -f1)"
}

# zaehler_pfad_mit_agent <zustand> <session> <agent_id> -- spiegelt
# dod-gate.sh woertlich (session_id-Hash, bei vorhandener agent_id um deren
# Hash ergaenzt, "-"-getrennt).
zaehler_pfad_mit_agent() {
local teil
teil=$(printf '%s' "$2" | sha256sum | cut -d' ' -f1)
[ -n "$3" ] && teil="${teil}-$(printf '%s' "$3" | sha256sum | cut -d' ' -f1)"
printf '%s/r3cosint/dod-gate/zaehler-%s' "$1" "$teil"
}

# pruefe_wahr <kennung> <kanal> <praedikat> <fall> <zusicherung> <ok:0|1>
# <erwartet> <erhalten> -- fuer Faelle, die ihre eigene Bedingung (Datei-
# Existenz, Beobachterergebnis u. Ae.) bereits vorher gebildet haben. Seit
# 6.12.26 f (S7-05, Runde 7) nimmt sie NUR NOCH die Kanaele dauer und
# selbsttest an (einzeln oder als Kombination wie "selbsttest+dauer",
# Z-152) -- berichtigt 2026-09-06 (6.12.27 j, S10-03): der Kommentar nannte
# zusaetzlich "beobachter" und "datei", die PRUEFE_WAHR_VORRAT jedoch NIE
# gefuehrt hat (S10-04 haelt fest, dass es nach dem Bau zwei, nicht drei
# Kanaele mit freier Angabe sind). Fuer rc/stdout/stderr/zaehler/kette/datei
# gibt es je eine typisierte Huelle, die den Kanal ueber ihren NAMEN bindet
# statt ueber ein freies Argument (S7-05); fuer beobachter tragen
# pruefe_beobachter und pruefe_beobachter_enthaelt_ausserhalb den Kanal
# ebenso fest ueber ihren eigenen Namen, ohne ueber pruefe_wahr zu laufen.
# Seit 6.12.27 b (O-26) nimmt pruefe_wahr ZUDEM das Praedikat als freies
# Argument, ausschliesslich aus PRAEDIKAT_VORRAT (_melde prueft das
# zentral); jede unzulaessige Kanalangabe bleibt ein Fehler des Selbsttests
# selbst, nicht des Gates.
PRUEFE_WAHR_VORRAT="dauer selbsttest"
pruefe_wahr() {
local kennung="$1" kanal="$2" praedikat="$3" fall="$4" zusicherung="$5" ok="$6" erwartet="$7" erhalten="$8"
local teil
IFS='+' read -ra _pwt <<< "$kanal"
for teil in "${_pwt[@]}"; do
  case " $PRUEFE_WAHR_VORRAT " in
    *" $teil "*) ;;
    *)
      echo "FEHLER  $kennung: unzulaessiger Kanal fuer pruefe_wahr: '$kanal' (Vorrat: $PRUEFE_WAHR_VORRAT)" >&2
      _melde "$kennung" "$kanal" "$fall" "$zusicherung" 0 "$erwartet" "unzulaessiger Kanal fuer pruefe_wahr: '$kanal'" "$praedikat"
      return
      ;;
  esac
done
if ! praedikat_gueltig "$praedikat"; then
  echo "FEHLER  $kennung: unzulaessiges Praedikat fuer pruefe_wahr: '$praedikat' (Vorrat: $PRAEDIKAT_VORRAT)" >&2
  _melde "$kennung" "$kanal" "$fall" "$zusicherung" 0 "$erwartet" "unzulaessiges Praedikat fuer pruefe_wahr: '$praedikat'" "$praedikat"
  return
fi
_melde "$kennung" "$kanal" "$fall" "$zusicherung" "$ok" "$erwartet" "$erhalten" "$praedikat"
}

# pruefe_rc_wahr/pruefe_stdout_wahr/pruefe_stderr_wahr/pruefe_zaehler_wahr/
# pruefe_kette_wahr/pruefe_stdout_stderr_wahr <kennung> <praedikat> <fall>
# <zusicherung> <ok:0|1> <erwartet> <erhalten> -- wie pruefe_wahr, aber der
# Kanal ist ueber den Funktionsnamen FEST gebunden (S7-05). Seit 6.12.27 b
# (O-26) nimmt jede Huelle das Praedikat als ZWEITEN Parameter, beschraenkt
# auf einen je Huelle FESTEN Teilvorrat (enger als PRAEDIKAT_VORRAT).
_pruefe_teilvorrat_pruefen() {
local kennung="$1" huelle="$2" praedikat="$3" teilvorrat="$4"
case " $teilvorrat " in
  *" $praedikat "*) return 0 ;;
esac
echo "FEHLER  $kennung: unzulaessiges Praedikat fuer $huelle: '$praedikat' (Teilvorrat: $teilvorrat)" >&2
return 1
}
pruefe_rc_wahr() {
local kennung="$1" praedikat="$2" fall="$3" zusicherung="$4" ok="$5" erwartet="$6" erhalten="$7"
if ! _pruefe_teilvorrat_pruefen "$kennung" "pruefe_rc_wahr" "$praedikat" "gleich"; then
  _melde "$kennung" "rc" "$fall" "$zusicherung" 0 "$erwartet" "unzulaessiges Praedikat fuer pruefe_rc_wahr: '$praedikat'" "$praedikat"
  return
fi
_melde "$kennung" "rc" "$fall" "$zusicherung" "$ok" "$erwartet" "$erhalten" "$praedikat"
}
pruefe_stdout_wahr() {
local kennung="$1" praedikat="$2" fall="$3" zusicherung="$4" ok="$5" erwartet="$6" erhalten="$7"
if ! _pruefe_teilvorrat_pruefen "$kennung" "pruefe_stdout_wahr" "$praedikat" "enthaelt"; then
  _melde "$kennung" "stdout" "$fall" "$zusicherung" 0 "$erwartet" "unzulaessiges Praedikat fuer pruefe_stdout_wahr: '$praedikat'" "$praedikat"
  return
fi
_melde "$kennung" "stdout" "$fall" "$zusicherung" "$ok" "$erwartet" "$erhalten" "$praedikat"
}
pruefe_stderr_wahr() {
local kennung="$1" praedikat="$2" fall="$3" zusicherung="$4" ok="$5" erwartet="$6" erhalten="$7"
if ! _pruefe_teilvorrat_pruefen "$kennung" "pruefe_stderr_wahr" "$praedikat" "enthaelt"; then
  _melde "$kennung" "stderr" "$fall" "$zusicherung" 0 "$erwartet" "unzulaessiges Praedikat fuer pruefe_stderr_wahr: '$praedikat'" "$praedikat"
  return
fi
_melde "$kennung" "stderr" "$fall" "$zusicherung" "$ok" "$erwartet" "$erhalten" "$praedikat"
}
pruefe_zaehler_wahr() {
local kennung="$1" praedikat="$2" fall="$3" zusicherung="$4" ok="$5" erwartet="$6" erhalten="$7"
if ! _pruefe_teilvorrat_pruefen "$kennung" "pruefe_zaehler_wahr" "$praedikat" "gleich"; then
  _melde "$kennung" "zaehler" "$fall" "$zusicherung" 0 "$erwartet" "unzulaessiges Praedikat fuer pruefe_zaehler_wahr: '$praedikat'" "$praedikat"
  return
fi
_melde "$kennung" "zaehler" "$fall" "$zusicherung" "$ok" "$erwartet" "$erhalten" "$praedikat"
}
pruefe_kette_wahr() {
local kennung="$1" praedikat="$2" fall="$3" zusicherung="$4" ok="$5" erwartet="$6" erhalten="$7"
if ! _pruefe_teilvorrat_pruefen "$kennung" "pruefe_kette_wahr" "$praedikat" "gleich enthaelt"; then
  _melde "$kennung" "kette" "$fall" "$zusicherung" 0 "$erwartet" "unzulaessiges Praedikat fuer pruefe_kette_wahr: '$praedikat'" "$praedikat"
  return
fi
_melde "$kennung" "kette" "$fall" "$zusicherung" "$ok" "$erwartet" "$erhalten" "$praedikat"
}

# pruefe_kette_fehlt <kennung> <fall> <zusicherung> <anzahl_verfehlend>
# <anzahl_gesamt> -- ADR 0002, 6.12.27 j, Punkt 5 (Z-199, Erzeugerseite):
# Kanal kette, Praedikat FEST auf fehlt -- "unter den <anzahl_gesamt>
# Uebersichtszeilen fehlt jede, die das marken_muster NICHT trifft, UND es
# gibt mindestens eine". Anders als pruefe_kette_wahr (freies Praedikat
# gleich/enthaelt) bindet diese Huelle das Praedikat fest, weil die Aussage
# selbst eine Abwesenheitsaussage ist (keine verfehlende Zeile).
# WICHTIG (Befund des Koordinators, 2026-09-06): die Parameter duerfen NIE
# "gesamt" oder "bestanden" heissen -- Bash vererbt lokale Variablen
# dynamisch an aufgerufene Funktionen (dieselbe Mechanik, auf die sich
# schluessel_und_grammatikdeckung verlaesst), und ein lokaler Parameter
# NAMENS "gesamt" ueberschreibt fuer die Dauer dieses Aufrufs den GLOBALEN
# Zaehler, den _melde weiterzaehlt. Ursache des Befunds "206 von 206 trotz
# einem FEHLGESCHLAGEN": frueher hiess der zweite Zaehlparameter hier
# "gesamt" und schluckte GENAU EINEN Fortschritt des globalen Zaehlers
# (belegt: gesamt blieb bei 201, bestanden stieg auf 202).
pruefe_kette_fehlt() {
local kennung="$1" fall="$2" zusicherung="$3" verfehlend="$4" zeilen_gesamt="$5"
local ok=0
[ "$verfehlend" -eq 0 ] && [ "$zeilen_gesamt" -gt 0 ] && ok=1
_melde "$kennung" "kette" "$fall" "$zusicherung" "$ok" \
  "0 verfehlende Zeilen, mindestens 1 Zeile gesamt" \
  "$verfehlend verfehlende von $zeilen_gesamt Uebersichtszeilen" "fehlt"
}
pruefe_stdout_stderr_wahr() {
local kennung="$1" praedikat="$2" fall="$3" zusicherung="$4" ok="$5" erwartet="$6" erhalten="$7"
if ! _pruefe_teilvorrat_pruefen "$kennung" "pruefe_stdout_stderr_wahr" "$praedikat" "fehlt+fehlt"; then
  _melde "$kennung" "stdout+stderr" "$fall" "$zusicherung" 0 "$erwartet" "unzulaessiges Praedikat fuer pruefe_stdout_stderr_wahr: '$praedikat'" "$praedikat"
  return
fi
_melde "$kennung" "stdout+stderr" "$fall" "$zusicherung" "$ok" "$erwartet" "$erhalten" "$praedikat"
}

# pruefe_datei_wahr <kennung> <praedikat> <fall> <zusicherung> <ok:0|1>
# <erwartet> <erhalten> -- 6.12.27 i c: wie pruefe_rc_wahr, aber Kanal FEST
# auf datei, fuer Faelle, deren "existiert"/"fehlt"-Bedingung NICHT ein
# blosses "[ -f pfad ]" ist (z. B. ein Git-Index-Zustand: Z-043, Z-045,
# Z-048). Teilvorrat "existiert fehlt" -- "gleich"/"ausserhalb" haben eigene
# feste Huellen (pruefe_datei_gleich, pruefe_datei_ausserhalb).
pruefe_datei_wahr() {
local kennung="$1" praedikat="$2" fall="$3" zusicherung="$4" ok="$5" erwartet="$6" erhalten="$7"
if ! _pruefe_teilvorrat_pruefen "$kennung" "pruefe_datei_wahr" "$praedikat" "existiert fehlt"; then
  _melde "$kennung" "datei" "$fall" "$zusicherung" 0 "$erwartet" "unzulaessiges Praedikat fuer pruefe_datei_wahr: '$praedikat'" "$praedikat"
  return
fi
_melde "$kennung" "datei" "$fall" "$zusicherung" "$ok" "$erwartet" "$erhalten" "$praedikat"
}

# pruefe_invariante_rc_fehlt/pruefe_invariante_stdout_leer/
# pruefe_invariante_stderr_enthaelt/pruefe_invariante_stdout_einzelfeld
# <kennung> <fall> <zusicherung> <ok:0|1> <erwartet> <erhalten> -- ADR 0002,
# 6.12.27 j, Punkt 4 (Z-194..Z-197): VIER Huellen mit gebundenem Kanal UND
# gebundenem Praedikat (kein freier Parameter, anders als pruefe_rc_wahr &
# Co., die nur den Kanal binden) -- diese Aussagen sind Invarianten ueber
# ALLE Gate-Aufrufe eines Laufs, nicht Stichproben je Pfad, und tragen
# deshalb immer dasselbe Praedikat.
pruefe_invariante_rc_fehlt() {
local kennung="$1" fall="$2" zusicherung="$3" ok="$4" erwartet="$5" erhalten="$6"
_melde "$kennung" "rc" "$fall" "$zusicherung" "$ok" "$erwartet" "$erhalten" "fehlt"
}
pruefe_invariante_stdout_leer() {
local kennung="$1" fall="$2" zusicherung="$3" ok="$4" erwartet="$5" erhalten="$6"
_melde "$kennung" "stdout" "$fall" "$zusicherung" "$ok" "$erwartet" "$erhalten" "leer"
}
pruefe_invariante_stderr_enthaelt() {
local kennung="$1" fall="$2" zusicherung="$3" ok="$4" erwartet="$5" erhalten="$6"
_melde "$kennung" "stderr" "$fall" "$zusicherung" "$ok" "$erwartet" "$erhalten" "enthaelt"
}
pruefe_invariante_stdout_einzelfeld() {
local kennung="$1" fall="$2" zusicherung="$3" ok="$4" erwartet="$5" erhalten="$6"
_melde "$kennung" "stdout" "$fall" "$zusicherung" "$ok" "$erwartet" "$erhalten" "einzelfeld"
}

# pruefe_kette_zeile <kennung> <fall> <zusicherung> <erwartete_zeile>
# <erhaltene_zeile> -- Kanal "kette" (6.12.26 a): die vom Selbsttest DIREKT
# aufgerufene Kettenausgabe (Attrappenziel "dod-baum-direkt", nicht ueber das
# GATE), im Unterschied zu stdout/stderr des GATES selbst. Item 1 (Runde 6).
pruefe_kette_zeile() {
local kennung="$1" fall="$2" zusicherung="$3" erwartet="$4" erhalten="$5"
local ok=0
[ "$erhalten" = "$erwartet" ] && ok=1
_melde "$kennung" "kette" "$fall" "$zusicherung" "$ok" "$erwartet" "$erhalten" "gleich"
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
# Werkzeugkasten mit einer ATTRAPPE fuer "flock", NUR fuer den Sperrpfad
# (ADR 0002, 6.12.28 b Punkt 6, O-27 (a1), Z-218..Z-221): schreibt "-w 120"
# auf eine KURZE Wartezeit um, waehrend ein ZWEITER Prozess die Sperre
# WIRKLICH haelt -- der Fehlschlag von flock ist echt, nur die Wartezeit ist
# verkuerzt (Vorbild WERKZEUGKASTEN_SCHNELLER_TIMEOUT, dieselbe Begruendung:
# geprueft wird die Auswertung im Gate, nicht das Werkzeug).
# -----------------------------------------------------------------------------
REAL_FLOCK="$(command -v flock)"
WERKZEUGKASTEN_FAKE_FLOCK=$(neu_verzeichnis)
baue_werkzeugkasten "$WERKZEUGKASTEN_FAKE_FLOCK"
rm -f "$WERKZEUGKASTEN_FAKE_FLOCK/flock"
cat > "$WERKZEUGKASTEN_FAKE_FLOCK/flock" <<FLOCKEOF
#!/bin/sh
if [ "\$1" = "-w" ] && [ "\$2" = "120" ]; then
  shift 2
  exec "$REAL_FLOCK" -w 1 "\$@"
fi
exec "$REAL_FLOCK" "\$@"
FLOCKEOF
chmod +x "$WERKZEUGKASTEN_FAKE_FLOCK/flock"

# -----------------------------------------------------------------------------
# Drei ATTRAPPEN fuer "mktemp", je fuer eine der drei bisher unbeschrittenen
# Aufrufstellen von "mktemp" im Gate (ADR 0002, 6.12.28 b Punkt 7,
# Pfaddeckung, Z-222..Z-224):
#   Z-222 (Zeile 705): der ERSTE (und hier einzige) Aufruf endet mit 1.
#   Z-223 (Zeile 740): der erste Aufruf liefert einen Pfad IM Baum, der
#     zweite ("-p /tmp") einen Pfad in einem NICHT VORHANDENEN Verzeichnis
#     (Vorbild WERKZEUGKASTEN_FAKE_MKTEMP_UNAUFLOESBAR).
#   Z-224 (Zeile 748): BEIDE Aufrufe liefern Pfade INNERHALB des Baums --
#     das Gate loest den GELIEFERTEN Pfad physisch auf, nicht "/tmp" selbst.
# -----------------------------------------------------------------------------
WERKZEUGKASTEN_FAKE_MKTEMP_Z222=$(neu_verzeichnis)
baue_werkzeugkasten "$WERKZEUGKASTEN_FAKE_MKTEMP_Z222"
rm -f "$WERKZEUGKASTEN_FAKE_MKTEMP_Z222/mktemp"
cat > "$WERKZEUGKASTEN_FAKE_MKTEMP_Z222/mktemp" <<'MKZ222EOF'
#!/bin/sh
exit 1
MKZ222EOF
chmod +x "$WERKZEUGKASTEN_FAKE_MKTEMP_Z222/mktemp"

WERKZEUGKASTEN_FAKE_MKTEMP_Z223=$(neu_verzeichnis)
baue_werkzeugkasten "$WERKZEUGKASTEN_FAKE_MKTEMP_Z223"
rm -f "$WERKZEUGKASTEN_FAKE_MKTEMP_Z223/mktemp"
cat > "$WERKZEUGKASTEN_FAKE_MKTEMP_Z223/mktemp" <<MKZ223EOF
#!/bin/sh
if [ "\$1" = "-p" ] && [ "\$2" = "/tmp" ]; then
  echo "/dod-gate-selbsttest-z223-nicht-vorhanden-\$\$/tmp.attrappe"
  exit 0
fi
mkdir -p "\$FAKE_MKTEMP_ZIEL"
exec "$REAL_MKTEMP" -p "\$FAKE_MKTEMP_ZIEL"
MKZ223EOF
chmod +x "$WERKZEUGKASTEN_FAKE_MKTEMP_Z223/mktemp"

WERKZEUGKASTEN_FAKE_MKTEMP_Z224=$(neu_verzeichnis)
baue_werkzeugkasten "$WERKZEUGKASTEN_FAKE_MKTEMP_Z224"
rm -f "$WERKZEUGKASTEN_FAKE_MKTEMP_Z224/mktemp"
cat > "$WERKZEUGKASTEN_FAKE_MKTEMP_Z224/mktemp" <<MKZ224EOF
#!/bin/sh
mkdir -p "\$FAKE_MKTEMP_ZIEL"
exec "$REAL_MKTEMP" -p "\$FAKE_MKTEMP_ZIEL"
MKZ224EOF
chmod +x "$WERKZEUGKASTEN_FAKE_MKTEMP_Z224/mktemp"

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
zustand001=$(neu_verzeichnis)
lauf_mit_zustand "$zustand001" "$baum" Stop "fall01" "$ausgabe" 2
pruefe_rc Z-001 "Kette mit A_FAIL" 2
pruefe_zaehler_schluessel Z-158 "Kette mit A_FAIL (derselbe Fall wie Z-001)" \
  "$(zaehler_pfad "$zustand001" "fall01")" "D3 linter A_FAIL"
pruefe_datei_ausserhalb Z-191 "Aussage E10: Block bei roter Kette, gepruefter Baum und Zustandsverzeichnis je an benanntem Ort" \
  "der physisch aufgeloeste Pfad der nach dem Block bestehenden Zaehlerdatei liegt ausserhalb des geprueften Baums" \
  "$(zaehler_pfad "$zustand001" "fall01")" "$baum"
pruefe_stdout_leer Z-193 "Aussage A04: Block bei roter Kette"

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
zustand008=$(neu_verzeichnis)
lauf_mit_zustand "$zustand008" "$baum" Stop "fall04" "$ausgabe" 2
pruefe_rc Z-008 "Lage C ohne Eintrag" 2
pruefe_zaehler_schluessel Z-159 "Lage C ohne Eintrag in der Liste (derselbe Fall wie Z-008)" \
  "$(zaehler_pfad "$zustand008" "fall04")" "D7 abnahme C scripts/abnahme-abgleich.sh"

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
zustand009=$(neu_verzeichnis)
lauf_mit_zustand "$zustand009" "$baum" Stop "fall05" "$ausgabe" 2
pruefe_rc Z-009 "Eintrag vorhanden, Pruefmittel existiert inzwischen" 2
pruefe_stderr_enthaelt Z-010 "Eintrag vorhanden, Pruefmittel existiert inzwischen" \
  "Meldung fuehrt den beanstandeten Eintrag im Wortlaut auf" "scripts/abnahme-abgleich.sh"
pruefe_zaehler_schluessel Z-166 "Eintrag der terminierten Lagen, dessen Pruefmittel inzwischen existiert (derselbe Fall wie Z-009)" \
  "$(zaehler_pfad "$zustand009" "fall05")" "LISTE 2 D7 abnahme"

}

# --- Fall 6: Eintrag vorhanden, Schritt meldet A_OK (veraltet) -------------
fall_z011_012() {
baum=$(neuer_mock_baum)
printf 'D7 abnahme|scripts/abnahme-abgleich.sh\tADR 0002, 6.12.5, Selbsttest.\n' > "$baum/.claude/hooks/dod-gate-terminierte-lagen.txt"
m1=$(marken_zeile K1 D20 belege A_OK "" "" 0)
m2=$(marken_zeile K1 D7 abnahme A_OK "" "" 0)
ausgabe=$(bauen_ausgabe "$baum" "$m1
$m2" "$D19_OK" "make dod: alle 2 Kettenschritte durchlaufen, keiner ungleich 0, 2 gueltige Marken gezaehlt.")
zustand011=$(neu_verzeichnis)
lauf_mit_zustand "$zustand011" "$baum" Stop "fall06" "$ausgabe" 0
pruefe_rc Z-011 "Eintrag vorhanden, Schritt meldet A_OK" 2
# Z-012 (Runde 6, Mutationsprobe): "D7 abnahme" allein ist zu schwach -- der
# Schluessel ("LISTE 3 D7 abnahme") und der naechste Schritt tragen dieselbe
# Zeichenfolge UNABHAENGIG vom liste_text der Selbstpruefung 3 (dod-gate.sh
# Zeile ~1028) und ueberleben die Mutation, die dort Schluessel und
# Zeilennummer entfernt. "(Zeile 1 in" kommt in DIESEM Fall ausschliesslich
# aus liste_text und faellt mit der Mutation weg.
pruefe_stderr_enthaelt Z-012 "Eintrag vorhanden, Schritt meldet A_OK" \
  "Meldung fuehrt den beanstandeten Eintrag im Wortlaut auf" "(Zeile 1 in"
pruefe_zaehler_schluessel Z-206 "Eintrag vorhanden, Schritt meldet A_OK -- Selbstpruefung 3 (derselbe Fall wie Z-011)" \
  "$(zaehler_pfad "$zustand011" "fall06")" "LISTE 3 D7 abnahme"

}

# --- Fall 7a: Eintrag ohne Grund --------------------------------------------
fall_z013() {
baum=$(neuer_mock_baum)
printf 'D7 abnahme|scripts/abnahme-abgleich.sh\t\n' > "$baum/.claude/hooks/dod-gate-terminierte-lagen.txt"
m1=$(marken_zeile K1 D7 abnahme C scripts/abnahme-abgleich.sh "" 2)
ausgabe=$(bauen_ausgabe "$baum" "$m1" "$D19_OK" "make dod: alle 1 Kettenschritte durchlaufen, 1 davon ohne Urteil (Lage C): D7 abnahme FEHLT=scripts/abnahme-abgleich.sh, Rueckgabewert 2.")
zustand013=$(neu_verzeichnis)
lauf_mit_zustand "$zustand013" "$baum" Stop "fall07a" "$ausgabe" 2
pruefe_rc Z-013 "Eintrag ohne Grund" 2
pruefe_zaehler_schluessel Z-167 "Eintrag ohne Grund (derselbe Fall wie Z-013)" \
  "$(zaehler_pfad "$zustand013" "fall07a")" "LISTE 4 1"

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
zustand016=$(neu_verzeichnis)
lauf_mit_zustand "$zustand016" "$baum" Stop "fall08" "$ausgabe" 2
pruefe_rc Z-016 "Marke nennt anderes Pruefmittel als der Schluessel" 2
pruefe_zaehler_schluessel Z-207 "Marke nennt ein anderes Pruefmittel als der Schluessel -- Selbstpruefung 5 (derselbe Fall wie Z-016)" \
  "$(zaehler_pfad "$zustand016" "fall08")" "LISTE 5 D7 abnahme"

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
pruefe_json_einzelfeld Z-183 "stop_hook_active wahr bei roter Kette (derselbe Fall wie Z-017)" systemMessage
schluessel9_nachher=$(sed -n '1p' "$zaehlerdatei9" 2>/dev/null || true)
stand9_nachher=$(sed -n '2p' "$zaehlerdatei9" 2>/dev/null || true)
pruefe_zaehler_wahr Z-018 "gleich" "stop_hook_active wahr bei roter Kette, Zaehlerdatei vor dem Aufruf mit Schluessel und Stand 2 angelegt" \
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
zustand019=$(neu_verzeichnis)
lauf_mit_zustand "$zustand019" "$baum" Stop "fall10a" "$ausgabe_10a" 2
pruefe_rc Z-019 "D19 VERLETZT, Form 4" 2
pruefe_zaehler_schluessel Z-161 "D19 VERLETZT (derselbe Fall wie Z-019)" \
  "$(zaehler_pfad "$zustand019" "fall10a")" "D19 VERLETZT"

}

# --- Fall 10b: D19 Lage C, Form 4 -------------------------------------------
fall_z020() {
baum=$(neuer_mock_baum)
m1=$(marken_zeile K1 D20 belege A_OK "" "" 0)
ausgabe=$(bauen_ausgabe "$baum" "$m1" "C -- git fehlt, nicht beobachtet." "make dod: alle 1 Kettenschritte durchlaufen, Rahmenpruefung D19 C, Rueckgabewert 2.")
zustand020=$(neu_verzeichnis)
lauf_mit_zustand "$zustand020" "$baum" Stop "fall10b" "$ausgabe" 2
pruefe_rc Z-020 "D19 Lage C, Form 4" 2
pruefe_zaehler_schluessel Z-162 "D19 Lage C (derselbe Fall wie Z-020)" \
  "$(zaehler_pfad "$zustand020" "fall10b")" "D19 C"

echo
echo "--- Fehlende Pruefmittel (G10, 6.12.11) --------------------------------"
echo

}

# --- Z-021/022, Z-023/024, Z-025/026, Z-029/030, Z-031/032: jq, git, make,
#     timeout, flock einzeln aus dem Werkzeugkasten entfernt ---------------
fall_z021_032() {
baum=$(neuer_mock_baum)
for eintrag in \
  "jq|Z-021|Z-022|" \
  "git|Z-023|Z-024|Z-200" \
  "make|Z-025|Z-026|Z-201" \
  "timeout|Z-029|Z-030|Z-204" \
  "flock|Z-031|Z-032|Z-205"; do
  werkzeug="${eintrag%%|*}"
  rest="${eintrag#*|}"
  z_rc="${rest%%|*}"
  rest2="${rest#*|}"
  z_msg="${rest2%%|*}"
  z_gegenstand="${rest2#*|}"
  wzk=$(neu_verzeichnis)
  baue_werkzeugkasten "$wzk" "$werkzeug"
  zustand=$(neu_verzeichnis)
  eingabe=$(baue_eingabe "Stop" "$baum" "fall11-$werkzeug")
  rufe_gate "$eingabe" "$zustand" "$wzk" "CLAUDE_PROJECT_DIR=$baum" "MOCK_AUSGABE=x" "MOCK_RC=0"
  pruefe_rc "$z_rc" "Fehlendes $werkzeug" 2
  pruefe_stderr_enthaelt "$z_msg" "Fehlendes $werkzeug" "Meldung nennt $werkzeug" "GATE $werkzeug"
  if [ "$werkzeug" = "jq" ]; then
    pruefe_datei Z-192 "Aussage E12: fehlendes jq" \
      "im Zustandsverzeichnis besteht nach dem Block keine Zaehlerdatei -- GATE jq ist der einzige Block, der nicht gezaehlt wird" \
      "$(zaehler_pfad "$zustand" "fall11-$werkzeug")" fehlt
  fi
  if [ -n "$z_gegenstand" ]; then
    pruefe_zaehler_schluessel "$z_gegenstand" "Fehlendes $werkzeug (derselbe Fall wie $z_rc, Gegenstandsdeckung Schluessel)" \
      "$(zaehler_pfad "$zustand" "fall11-$werkzeug")" "GATE $werkzeug"
  fi
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
zustand027=$(neu_verzeichnis)
eingabe027=$(baue_eingabe "Stop" "$baum_ohne_makefile" "fall11-makefile")
rufe_gate "$eingabe027" "$zustand027" "$WERKZEUGKASTEN_VOLL" "CLAUDE_PROJECT_DIR=$baum_ohne_makefile" "MOCK_AUSGABE=x" "MOCK_RC=0"
pruefe_rc Z-027 "Fehlendes Makefile" 2
pruefe_stderr_enthaelt Z-028 "Fehlendes Makefile" "Meldung nennt Makefile" "GATE Makefile"
pruefe_zaehler_schluessel Z-202 "Fehlendes Makefile (derselbe Fall wie Z-027, Gegenstandsdeckung Schluessel)" \
  "$(zaehler_pfad "$zustand027" "fall11-makefile")" "GATE Makefile"

}

# --- Z-033/034: fehlende Liste der terminierten Lagen ----------------------
fall_z033_034() {
baum_ohne_liste=$(neuer_mock_baum)
rm -f "$baum_ohne_liste/.claude/hooks/dod-gate-terminierte-lagen.txt"
zustand033=$(neu_verzeichnis)
eingabe033=$(baue_eingabe "Stop" "$baum_ohne_liste" "fall11-liste")
rufe_gate "$eingabe033" "$zustand033" "$WERKZEUGKASTEN_VOLL" "CLAUDE_PROJECT_DIR=$baum_ohne_liste" "MOCK_AUSGABE=x" "MOCK_RC=0"
pruefe_rc Z-033 "Fehlende Liste der terminierten Lagen" 2
pruefe_stderr_enthaelt Z-034 "Fehlende Liste der terminierten Lagen" "Meldung nennt den Pfad der Liste" ".claude/hooks/dod-gate-terminierte-lagen.txt"
pruefe_zaehler_schluessel Z-203 "Fehlende Liste der terminierten Lagen (derselbe Fall wie Z-033, Gegenstandsdeckung Schluessel)" \
  "$(zaehler_pfad "$zustand033" "fall11-liste")" "GATE dod-gate-terminierte-lagen.txt"

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
beobachter_protokoll104=$(neu_verzeichnis)/protokoll
beobachter_start "$beobachter_protokoll104" "sperre-$baum_hash12.lock" flach "/tmp/r3cosint-dod-gate"
rufe_gate "$eingabe12" "$zustand12" "$WERKZEUGKASTEN_VOLL" "CLAUDE_PROJECT_DIR=$baum" "MOCK_AUSGABE=$ausgabe" "MOCK_RC=2" "MOCK_SLEEP=0.3"
pruefe_rc Z-035 "Nicht beschreibbares Zustandsverzeichnis bei roter Kette" 2
pruefe_stderr_enthaelt Z-036 "Nicht beschreibbares Zustandsverzeichnis bei roter Kette" \
  "Zusatz, dass nicht gezaehlt werden kann" "nicht zaehlen"
pruefe_beobachter Z-104 "Zustandsverzeichnis nicht beschreibbar" \
  "ein Beobachter ohne Wartezeit findet die Sperrdatei waehrend des Laufs unter /tmp" existiert
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
# S9-01/S9-02 (6.12.27 i c): waehrend des GANZEN Laufs beobachtet (nicht
# nur vorher/nachher) -- der Beobachter laeuft vom Start bis nach dem Ende
# des Gate-Aufrufs und deckt alle DREI moeglichen Orte ab (Zustands-
# verzeichnis, fester Ausweichpfad, direkt unter /tmp -- der dritte Ort ist
# nur unter der Mutation von Z-106 erreichbar und muss deshalb mitbeobachtet
# werden, sonst bliebe diese Mutation unerkannt).
beobachter_protokoll106=$(neu_verzeichnis)/protokoll
beobachter_start "$beobachter_protokoll106" "sperre-*" flach "$zustand_n04" "/tmp/r3cosint-dod-gate" "/tmp"
eingabe_n04=$(baue_eingabe "Stop" "$baum" "fall-n04")
rufe_gate "$eingabe_n04" "$zustand_n04" "$WERKZEUGKASTEN_VOLL" "CLAUDE_PROJECT_DIR=$baum" "MOCK_AUSGABE=$ausgabe" "MOCK_RC=2" "MOCK_SLEEP=0.3"
rm -f "$sperre_fest"
if [ "$sperre_fest_war_verzeichnis" -eq 1 ]; then
  mv "$sperre_fest_sicherung/verzeichnis" "$sperre_fest"
fi
pruefe_beobachter Z-106 "Zustandsverzeichnis und /tmp nicht beschreibbar" \
  "an keinem der drei Orte (Zustandsverzeichnis, fester Ausweichpfad /tmp/r3cosint-dod-gate, direkt unter /tmp) entsteht eine Sperrdatei, waehrend des GANZEN Laufs beobachtet" fehlt
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
zustand037=$(neu_verzeichnis)
eingabe037=$(baue_eingabe "Stop" "$baum" "fall13")
rufe_gate "$eingabe037" "$zustand037" "$WERKZEUGKASTEN_SCHNELLER_TIMEOUT" "CLAUDE_PROJECT_DIR=$baum" "MOCK_AUSGABE=wird nie gedruckt" "MOCK_RC=0" "MOCK_SLEEP=5"
pruefe_rc Z-037 "Innere Zeitueberschreitung" 2
pruefe_zaehler_schluessel Z-163 "Innere Zeitueberschreitung (derselbe Fall wie Z-037)" \
  "$(zaehler_pfad "$zustand037" "fall13")" "KETTE zeitueberschreitung"

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
pruefe_stderr_zeile Z-040 "Dreimal derselbe Schluessel" \
  "Eskalation 3.4: D3 linter A_FAIL"

# Uebergabedatei anlegen (uncommittet) -- 4. Mal muss durchlassen.
mkdir -p "$baum/docs/uebergaben"
printf 'Uebergabe\n\nEskalation 3.4: D3 linter A_FAIL\n' > "$baum/docs/uebergaben/2026-09-02_selbsttest-eskalation.md"
lauf_mit_zustand "$zustand_esk" "$baum" Stop "fall14" "$ausgabe_esk" 2
pruefe_rc Z-041 "Uebergabedatei mit der geforderten Zeile, neu oder geaendert" 0
pruefe_json_einzelfeld Z-182 "Vierter Stop mit passender Uebergabedatei -- Durchlass nach der Eskalation (derselbe Fall wie Z-041)" systemMessage
pruefe_zaehler Z-042 "Uebergabedatei mit der geforderten Zeile, neu oder geaendert" "$zaehler_datei_esk" 4

# Committen -> weiterhin Durchlass, jetzt ueber HEAD (Z-043/044, Befund DT-B4).
git -C "$baum" add -A
git -C "$baum" commit -q -m "Eskalationsuebergabe"
head_hat_datei43=0
git -C "$baum" ls-tree -r HEAD --name-only 2>/dev/null | \
  grep -qF "docs/uebergaben/2026-09-02_selbsttest-eskalation.md" && head_hat_datei43=1
pruefe_datei_wahr Z-043 "existiert" "Uebergabedatei mit der geforderten Zeile, committet" \
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
pruefe_datei_wahr Z-045 "fehlt" "Uebergabedatei nur in einem aelteren Commit, auf der Platte unveraendert vorhanden" \
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
pruefe_datei_wahr Z-048 "existiert" "Dieselbe Eskalation auf TaskCompleted" \
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

pruefe_stdout_stderr_wahr Z-129 "fehlt+fehlt" "Vierter Durchlass, danach erneut Blocks" \
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
pruefe_stderr_wahr Z-052 "enthaelt" "Lauf mit A_FAIL, zwei ungedeckten Lagen C und D19 VERLETZT zugleich" \
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
pruefe_stderr_wahr Z-054 "enthaelt" "Marke mit FEHLT= und SCHWELLE= zugleich, ungedeckte Lage C" \
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
pruefe_datei_gleich Z-068 "N-03: echte Rollendatei im Scheinbaum" \
  "die im Scheinbaum verwendete Rollendatei ist pruefsummengleich mit der aus .claude/agents/" \
  "$summe_quelle68" "$summe_kopie68"
zustand_sst=$(neu_verzeichnis)
marker_sst=$(neu_verzeichnis)/marker
eingabe_sst=$(baue_eingabe "SubagentStop" "$baum_sst" "fall-sst" "false" "a1" "static-software-tester")
rufe_gate "$eingabe_sst" "$zustand_sst" "$WERKZEUGKASTEN_VOLL" "CLAUDE_PROJECT_DIR=$baum_sst" "MOCK_AUSGABE=roter Muell, duerfte nie gelesen werden" "MOCK_RC=2" "MOCK_MARKER=$marker_sst"
pruefe_rc Z-065 "SubagentStop echte Rolle static-software-tester" 0
pruefe_datei Z-067 "SubagentStop einer Rolle ohne veraenderndes Werkzeug" \
  "die Attrappe von make dod verzeichnet keinen Aufruf" "$marker_sst" "fehlt"

}

# --- Z-066: echte Rolle pentester (kein Edit/Write) ------------------------
fall_z066() {
baum_pt=$(neuer_mock_baum)
cp "$REPO_WURZEL/.claude/agents/pentester.md" "$baum_pt/.claude/agents/pentester.md"
zustand_pt=$(neu_verzeichnis)
eingabe_pt=$(baue_eingabe "SubagentStop" "$baum_pt" "fall-pt" "false" "a1" "pentester")
rufe_gate "$eingabe_pt" "$zustand_pt" "$WERKZEUGKASTEN_VOLL" "CLAUDE_PROJECT_DIR=$baum_pt" "MOCK_AUSGABE=roter Muell, duerfte nie gelesen werden" "MOCK_RC=2"
pruefe_rc Z-066 "SubagentStop echte Rolle pentester" 0
pruefe_json_einzelfeld Z-184 "SubagentStop einer Rolle ohne veraenderndes Werkzeug (derselbe Fall wie Z-066)" systemMessage

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
pruefe_datei Z-069 "SubagentStop echte Rolle devops-engineer" \
  "die Attrappe von make dod verzeichnet einen Aufruf" "$marker_dev" "existiert"
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
pruefe_datei Z-071 "agent_type, der ueber name: aufzuloesen ist und nicht ueber den Dateinamen" \
  "die Attrappe von make dod verzeichnet keinen Aufruf" "$marker25" "fehlt"
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
pruefe_datei Z-073 "SubagentStop mit unbekanntem agent_type" \
  "die Attrappe von make dod verzeichnet einen Aufruf" "$marker26a" "existiert"
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
pruefe_datei Z-075 "SubagentStop mit leerem agent_type" \
  "die Attrappe von make dod verzeichnet einen Aufruf" "$marker26b" "existiert"
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
pruefe_datei Z-077 "SubagentStop mit mehrdeutigem agent_type" \
  "die Attrappe von make dod verzeichnet einen Aufruf" "$marker26c" "existiert"
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
# SST-B5-02: berichtigt -- der Beschaffungsweg steht auf der Zeile,
# die der Lage-C-Zeile zu D20 UNMITTELBAR FOLGT ("Beschaffen: git fetch
# --unshallow", Makefile Zeile 712), nicht auf der Lage-C-Zeile selbst.
zeile80=$(grep -F -A1 "[D20 belege] LAGE C:" "$ausgabe79_stderr" | tail -n1)
gehalt80=0
printf '%s' "$zeile80" | grep -qF "git fetch --unshallow" && gehalt80=1
pruefe_kette_wahr Z-080 "enthaelt" "Flacher Klon" "die Zeile unmittelbar nach dem Lage-C-Befund zu D20 in der direkt aufgerufenen Kettenausgabe nennt 'git fetch --unshallow'" \
  "$gehalt80" "'git fetch --unshallow' auf der Zeile nach der D20-LAGE-C-Zeile" "Zeile='$(_kuerzen "$zeile80")'"
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
pruefe_stderr_wahr Z-100 "enthaelt" "Weder XDG_STATE_HOME noch HOME gesetzt, rote Kette" \
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
pruefe_rc_wahr Z-101 "gleich" "Weder XDG_STATE_HOME noch HOME gesetzt, gruene Kette" \
  "Rueckgabewert 0 -- nie 1" "$([ "$G_RC" = "0" ] && echo 1 || echo 0)" "rc=0" "rc=$G_RC"
pruefe_json_einzelfeld Z-102 "Weder XDG_STATE_HOME noch HOME gesetzt, gruene Kette" systemMessage
enthaelt_bestimmbar103=0
printf '%s' "$G_STDOUT" | grep -qF "nicht bestimmbar" && enthaelt_bestimmbar103=1
pruefe_stdout_wahr Z-103 "enthaelt" "Weder XDG_STATE_HOME noch HOME gesetzt, gruene Kette" \
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
# 6.12.27 i c (S9-01, S9-02): ZWEI echte Beobachter laufen PARALLEL waehrend
# DESSELBEN Gate-Aufrufs -- einer scoped auf den Baum (Z-111: es darf dort
# KEINE Datei tmp.* entstehen, rekursiv, weil eine Mutation die Wegwerfdatei
# auch in einem Unterverzeichnis des Baums entstehen lassen kann), einer an
# der SPUR gebunden (Z-109). "tmp.*" (Punkt nach "tmp") trifft NICHT das
# selbsttesteigene "tmpdir-im-baum" (kein Punkt), deshalb keine Kollision
# mit diesem Verzeichnis.
protokoll_baum109=$(neu_verzeichnis)/protokoll
beobachter_start "$protokoll_baum109" "tmp.*" rekursiv "$baum"
pid_baum109="$BEOB_PID"
protokoll_ausserhalb109=$(neu_verzeichnis)/protokoll
# S9-03/S9-04 (6.12.27 i, zwei erfolglose Nachbesserungen am 2026-09-06 ueber
# ein Durchsuchen von /tmp -- einmal "pruefe_beobachter ... ausserhalb" gegen
# den GANZEN Ort /tmp, das SELBSTTEST-EIGENE "tmp.*"-Verzeichnisse als
# Scheinbeleg nahm; dann eine ODER-Pruefung auf das Elternverzeichnis, die
# fuer diesen Fall gegenstandslos war, weil das Elternverzeichnis hier
# schlicht "/tmp" selbst ist und nie als Protokolleintrag auftaucht):
# "beobachter_start_spur" bindet die Messung stattdessen an die Spur selbst
# (MOCK_TMP_SPUR) -- unabhaengig von jeder Namenssuche in /tmp.
beobachter_start_spur "$protokoll_ausserhalb109" "$spur_tmp"
pid_ausserhalb109="$BEOB_PID"
rufe_gate "$eingabe_tmp" "$zustand_tmp" "$WERKZEUGKASTEN_VOLL" "CLAUDE_PROJECT_DIR=$baum" "MOCK_AUSGABE=$ausgabe" "MOCK_RC=0" "TMPDIR=$tmp_im_baum" "MOCK_TMP_SPUR=$spur_tmp"
wegwerfdatei109=$(cat "$spur_tmp" 2>/dev/null || true)
BEOB_PID="$pid_ausserhalb109"; BEOB_STOPP="${protokoll_ausserhalb109}.stopp"; BEOB_PROTOKOLL="$protokoll_ausserhalb109"
pruefe_beobachter_enthaelt_ausserhalb Z-109 "TMPDIR zeigt in den geprueften Baum" \
  "ein Beobachter ohne Wartezeit findet waehrend des Laufs im Wegwerfverzeichnis des Gates -- dem Verzeichnis, das das Gate vor dem Anlegen bestimmt und der Kette als TMPDIR uebergibt -- eine Wegwerfdatei, deren physisch aufgeloester Pfad ausserhalb des geprueften Baums liegt" \
  "$wegwerfdatei109" "$baum"
# Z-110 ist am 2026-09-03 zurueckgezogen (6.12.25 h, Befund S4-02): im
# Attrappenaufbau ist "D19 meldet OHNE_BEFUND" nicht messbar, weil die
# D19-Zeile aus der vom Selbsttest selbst geschriebenen Attrappenausgabe
# stammt -- gemessen wuerde die eigene Vorgabe. Keine Pruefung mehr; die
# Deckungspruefung nimmt die Kennung als zurueckgezogen aus.
BEOB_PID="$pid_baum109"; BEOB_STOPP="${protokoll_baum109}.stopp"; BEOB_PROTOKOLL="$protokoll_baum109"
pruefe_beobachter Z-111 "TMPDIR zeigt in den geprueften Baum" \
  "ein Beobachter ohne Wartezeit findet waehrend des gesamten Laufs im ganzen geprueften Baum keine Datei mit dem Muster tmp.*" fehlt

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
pruefe_datei Z-123 "Liste mit zwei fehlerhaften Zeilen (Selbstpruefungen 2 und 6)" \
  "die Attrappe von make dod verzeichnet keinen Aufruf -- geblockt wird vor dem Lauf der Kette" "$marker_liste" "fehlt"
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
# SST-B5-01: der FEHLT=-Wert wird GELESEN (nicht als Teilzeichenkette
# gesucht) und mit dem erwarteten Wert VERGLICHEN -- eine Teilstring-Suche
# uebersaehe z. B. "scripts/nachweise-erzeugen.sh.bak".
wert130=$(printf '%s' "$marke130" | sed -n 's/.* FEHLT=\([^ :]*\).*/\1/p')
richtig130=0; [ "$wert130" = "scripts/nachweise-erzeugen.sh" ] && richtig130=1
pruefe_kette_wahr Z-130 "gleich" "D12 in Lage C mit mehreren fehlenden Gegenstaenden" \
  "die direkt aufgerufene Kettenausgabe (echtes Makefile, Ziel nachweise, im Scheinbaum ohne scripts/nachweise-erzeugen.sh und ohne scripts/nachweise-vollstaendig.sh) nennt in der Marke von D12 als FEHLT=-Wert genau scripts/nachweise-erzeugen.sh" \
  "$richtig130" "FEHLT=scripts/nachweise-erzeugen.sh" "FEHLT=$wert130 (Marke='$(_kuerzen "$marke130")')"
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
pruefe_datei_ausserhalb Z-131 "TMPDIR in den Baum, und die Kette selbst legt eine Wegwerfdatei an" \
  "das im Aufrufprotokoll der Attrappe verzeichnete, an make dod uebergebene TMPDIR liegt ausserhalb des geprueften Baums" \
  "$tmpdir_uebergeben_dtb2" "$baum"
kette_eigene_tmp_dtb2=$(cat "$spur_dtb2" 2>/dev/null || true)
spur_ausserhalb_dtb2=0
case "$kette_eigene_tmp_dtb2" in
  ""|"$baum"|"$baum"/*) ;;
  *) spur_ausserhalb_dtb2=1 ;;
esac
pruefe_datei_ausserhalb Z-132 "TMPDIR in den Baum, Kette legt selbst an" \
  "die Spurdatei der Attrappenkette (Pfad ihrer eigenen mktemp-Datei) liegt ausserhalb des geprueften Baums -- die Kette selbst sieht die Umlenkung" \
  "$kette_eigene_tmp_dtb2" "$baum"

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
pruefe_zaehler_wahr Z-147 "gleich" "Verzeichnis der Wegwerfdatei physisch nicht aufloesbar, erstes Ereignis" \
  "die Zaehlerdatei traegt Schluessel GATE mktemp und Stand 1" \
  "$([ "$schluessel_gm1" = "GATE mktemp" ] && [ "$stand_gm1" = "1" ] && echo 1 || echo 0)" \
  "GATE mktemp|1" "$schluessel_gm1|$stand_gm1"

rufe_gate "$eingabe_gm" "$zustand_gm" "$WERKZEUGKASTEN_FAKE_MKTEMP_UNAUFLOESBAR" "CLAUDE_PROJECT_DIR=$baum" "MOCK_AUSGABE=$ausgabe_gm" "MOCK_RC=0"
schluessel_gm2=$(sed -n '1p' "$zaehler_datei_gm" 2>/dev/null || true)
stand_gm2=$(sed -n '2p' "$zaehler_datei_gm" 2>/dev/null || true)
pruefe_zaehler_wahr Z-148 "gleich" "Dasselbe Ausbleiben ein zweites Mal in derselben Sitzung" \
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
pruefe_zaehler_wahr Z-150 "gleich" "Fehlendes sha256sum, erstes Ereignis" \
  "die Zaehlerdatei traegt Schluessel GATE sha256sum und Stand 1" \
  "$([ "$schluessel_gs1" = "GATE sha256sum" ] && [ "$stand_gs1" = "1" ] && echo 1 || echo 0)" \
  "GATE sha256sum|1" "$schluessel_gs1|$stand_gs1"

rufe_gate "$eingabe_gs" "$zustand_gs" "$WERKZEUGKASTEN_OHNE_SHA256SUM_GS" "CLAUDE_PROJECT_DIR=$baum" "MOCK_AUSGABE=x" "MOCK_RC=0"
schluessel_gs2=$(sed -n '1p' "$zaehler_datei_gs" 2>/dev/null || true)
stand_gs2=$(sed -n '2p' "$zaehler_datei_gs" 2>/dev/null || true)
pruefe_zaehler_wahr Z-151 "gleich" "Fehlendes sha256sum, zweites Ereignis in derselben Sitzung" \
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
pruefe_wahr Z-152 "selbsttest+dauer" "gleich+kleiner" "Zweiter Selbsttest, gestartet waehrend der erste die Sperre haelt" \
  "der zweite Aufruf endet innerhalb von 5 s mit Rueckgabewert 3" \
  "$([ "$zweiter_rc152" = "3" ] && [ "$dauer_ms152" -lt 5000 ] && echo 1 || echo 0)" \
  "rc=3, Dauer < 5000 ms" "rc=$zweiter_rc152, Dauer=${dauer_ms152}ms"
pruefe_selbsttest_zeile Z-153 "Zweiter Selbsttest, gestartet waehrend der erste die Sperre haelt" \
  "$zweiter_stderr152" "Selbsttest laeuft bereits"
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
pruefe_zaehler_wahr Z-155 "gleich" "Vierter Stop, Uebergabedatei mit fremdem Schluessel in der Eskalationszeile" \
  "die Zaehlerdatei traegt nach dem vierten Ereignis den gezaehlten Schluessel D3 linter A_FAIL (Zeile 1) mit dem Stand 4 (Zeile 2) -- der Zaehler zaehlt weiter und wird nicht zurueckgesetzt" \
  "$([ "$schluessel155" = "D3 linter A_FAIL" ] && [ "$stand155" = "4" ] && echo 1 || echo 0)" \
  "Schluessel 'D3 linter A_FAIL', Stand 4" "Schluessel '$schluessel155', Stand '$stand155' (Datei: $zaehler_datei154)"
}

# --- Z-156/157 (6.12.27 e, DT8-01): Ereignisfolge um die Eskalationsschwelle
fall_z156_157() {
baum156=$(neuer_mock_baum)
mkdir -p "$baum156/docs/uebergaben"
printf 'Uebergabe\n\nEskalation 3.4: D3 linter A_FAIL\n' > "$baum156/docs/uebergaben/2026-09-06_z156.md"
git -C "$baum156" add -A
git -C "$baum156" commit -q -m "vorab committierte Eskalationsuebergabe"
# SST-B5-13: Vorbedingung des Aufbaus GEWACHT, nicht nur hergestellt -- sonst
# bliebe unbemerkt, wenn die Uebergabedatei aus irgendeinem Grund nicht in
# HEAD landet. Genau EINE Meldung je Lauf (Wache ODER eigentliche Zusicherung).
if git -C "$baum156" cat-file -e HEAD:docs/uebergaben/2026-09-06_z156.md 2>/dev/null; then
  m1_156=$(marken_zeile K1 D3 linter A_FAIL "" "" 2)
  ausgabe156=$(bauen_ausgabe "$baum156" "$m1_156" "$D19_OK" "make dod: abgebrochen bei D3 linter, Rueckgabewert 2.")
  zustand156=$(neu_verzeichnis)
  lauf_mit_zustand "$zustand156" "$baum156" Stop "fall156" "$ausgabe156" 2
  lauf_mit_zustand "$zustand156" "$baum156" Stop "fall156" "$ausgabe156" 2
  lauf_mit_zustand "$zustand156" "$baum156" Stop "fall156" "$ausgabe156" 2
  pruefe_rc Z-156 "Drittes Ereignis am selben Kriterium, mit einer vorab committierten Uebergabedatei mit passender Eskalationszeile" 2
else
  pruefe_rc_wahr Z-156 "gleich" "Drittes Ereignis am selben Kriterium, mit einer vorab committierten Uebergabedatei mit passender Eskalationszeile" \
    "Vorbedingung nicht hergestellt: Uebergabedatei nicht in HEAD" 0 \
    "Vorbedingung nicht hergestellt: Uebergabedatei nicht in HEAD" "Uebergabedatei nicht in HEAD"
fi

baum157=$(neuer_mock_baum)
m1_157=$(marken_zeile K1 D3 linter A_FAIL "" "" 2)
ausgabe157=$(bauen_ausgabe "$baum157" "$m1_157" "$D19_OK" "make dod: abgebrochen bei D3 linter, Rueckgabewert 2.")
zustand157=$(neu_verzeichnis)
lauf_mit_zustand "$zustand157" "$baum157" Stop "fall157" "$ausgabe157" 2
lauf_mit_zustand "$zustand157" "$baum157" Stop "fall157" "$ausgabe157" 2
lauf_mit_zustand "$zustand157" "$baum157" Stop "fall157" "$ausgabe157" 2
lauf_mit_zustand "$zustand157" "$baum157" Stop "fall157" "$ausgabe157" 2
pruefe_stderr_enthaelt Z-157 "Viertes Ereignis am selben Kriterium, ohne Uebergabedatei unter docs/uebergaben/" \
  "die Fehlerausgabe erhebt die Forderung nach einer Datei unter docs/uebergaben/ mit der woertlichen Eskalationszeile" \
  "dod-gate: erwartet eine Datei unter docs/uebergaben/ mit der woertlichen Zeile 'Eskalation 3.4: D3 linter A_FAIL', neu/geaendert oder im juengsten Commit."
}

# --- Z-160 (Schluesseldeckung 6.12.27 c): KETTE marke-fehlt <D> <ziel> -----
fall_z160() {
baum160=$(neuer_mock_baum)
ausgabe160=$(bauen_ausgabe "$baum160" "(keine Marke)" "$D19_OK" "make dod: abgebrochen bei D3 linter, Rueckgabewert 2.")
zustand160=$(neu_verzeichnis)
lauf_mit_zustand "$zustand160" "$baum160" Stop "fall160" "$ausgabe160" 2
pruefe_zaehler_schluessel Z-160 "Uebersicht mit einer Zeile (keine Marke) und Schlusszeile Form 3 (abgebrochen bei diesem Schritt)" \
  "$(zaehler_pfad "$zustand160" "fall160")" "KETTE marke-fehlt D3 linter"
}

# --- Z-164/165 (Schluesseldeckung 6.12.27 c): Attrappe mit Rueckgabewert 7 -
fall_z164_165() {
# SST-B5-12: nutzt den VORBESTEHENDEN Werkzeugkasten WERKZEUGKASTEN_FAKE_MAKE
# (oben, Kommentar "NUR fuer den einen Fall Rueckgabewert weder 0 noch 2") --
# eine zweite, gleichbedeutende make-Attrappe eigens fuer diesen Fall entfaellt.
baum164=$(neuer_mock_baum)
m1_164=$(marken_zeile K1 D20 belege A_OK "" "" 0)
ausgabe164=$(bauen_ausgabe "$baum164" "$m1_164" "$D19_OK" "make dod: alle 1 Kettenschritte durchlaufen, keiner ungleich 0, 1 gueltige Marken gezaehlt.")
zustand164=$(neu_verzeichnis)
eingabe164=$(baue_eingabe "Stop" "$baum164" "fall164")
rufe_gate "$eingabe164" "$zustand164" "$WERKZEUGKASTEN_FAKE_MAKE" "CLAUDE_PROJECT_DIR=$baum164" "MOCK_AUSGABE=$ausgabe164" "MOCK_RC=7"
pruefe_rc Z-164 "Die Kette endet mit Rueckgabewert 7 (Attrappe)" 2
pruefe_zaehler_schluessel Z-165 "Die Kette endet mit Rueckgabewert 7" \
  "$(zaehler_pfad "$zustand164" "fall164")" "KETTE rueckgabewert=7"
}

# --- Z-168/169 (DT8-02): Rueckgabewert 0 mit Schlusszeile Form 4, D19 VERLETZT
fall_z168_169() {
baum168=$(neuer_mock_baum)
m1_168=$(marken_zeile K1 D20 belege A_OK "" "" 0)
ausgabe168=$(bauen_ausgabe "$baum168" "$m1_168" "VERLETZT -- versionierter Bestand veraendert." "make dod: alle 1 Kettenschritte durchlaufen, Rahmenpruefung D19 VERLETZT, Rueckgabewert 2.")
zustand168=$(neu_verzeichnis)
lauf_mit_zustand "$zustand168" "$baum168" Stop "fall168" "$ausgabe168" 0
pruefe_zaehler_schluessel Z-168 "Rueckgabewert 0 der Kette mit einer Schlusszeile Form 4 und passender D19-Zeile VERLETZT" \
  "$(zaehler_pfad "$zustand168" "fall168")" "KETTE schlusszeile-widerspruch"
pruefe_rc Z-169 "Derselbe Fall: Rueckgabewert 0 der Kette mit Schlusszeile Form 4" 2
}

# --- Z-170..Z-179 (Grammatikdeckung 6.12.27 d): je ein missgebildetes Element
fall_z170_179() {
baum17x=$(neuer_mock_baum)
schluss17x="make dod: alle 1 Kettenschritte durchlaufen, keiner ungleich 0, 1 gueltige Marken gezaehlt."

bad170="LAGE K1 D3 linter A_OK FEHLT=wert-x SCHWELLE=1200s:: (rueckgabewert=0)"
ausgabe170=$(bauen_ausgabe "$baum17x" "$bad170" "$D19_OK" "$schluss17x")
zustand170=$(neu_verzeichnis)
lauf_mit_zustand "$zustand170" "$baum17x" Stop "fall170" "$ausgabe170" 0
pruefe_zaehler_schluessel Z-170 "Grammatik PRAEFIX: Uebersichtszeile ohne das Praefix ::LAGE , im Uebrigen wohlgeformte Marke, Schlusszeile Form 1 mit der vollen Markenzahl" \
  "$(zaehler_pfad "$zustand170" "fall170")" "KETTE ausgabe-unlesbar"

bad171="::LAGE D3 linter A_OK FEHLT=wert-x SCHWELLE=1200s:: (rueckgabewert=0)"
ausgabe171=$(bauen_ausgabe "$baum17x" "$bad171" "$D19_OK" "$schluss17x")
zustand171=$(neu_verzeichnis)
lauf_mit_zustand "$zustand171" "$baum17x" Stop "fall171" "$ausgabe171" 0
pruefe_zaehler_schluessel Z-171 "Grammatik KENNUNG: Marke ohne das Feld der Lauf-Kennung, sonst wohlgeformt, Schlusszeile Form 1 mit der vollen Markenzahl" \
  "$(zaehler_pfad "$zustand171" "fall171")" "KETTE ausgabe-unlesbar"

bad172="::LAGE K1 linter A_OK FEHLT=wert-x SCHWELLE=1200s:: (rueckgabewert=0)"
ausgabe172=$(bauen_ausgabe "$baum17x" "$bad172" "$D19_OK" "$schluss17x")
zustand172=$(neu_verzeichnis)
lauf_mit_zustand "$zustand172" "$baum17x" Stop "fall172" "$ausgabe172" 0
pruefe_zaehler_schluessel Z-172 "Grammatik DNUMMER: Marke ohne das Feld der D-Nummer, sonst wohlgeformt, Schlusszeile Form 1 mit der vollen Markenzahl" \
  "$(zaehler_pfad "$zustand172" "fall172")" "KETTE ausgabe-unlesbar"

bad173="::LAGE K1 D3 A_OK FEHLT=wert-x SCHWELLE=1200s:: (rueckgabewert=0)"
ausgabe173=$(bauen_ausgabe "$baum17x" "$bad173" "$D19_OK" "$schluss17x")
zustand173=$(neu_verzeichnis)
lauf_mit_zustand "$zustand173" "$baum17x" Stop "fall173" "$ausgabe173" 0
pruefe_zaehler_schluessel Z-173 "Grammatik ZIEL: Marke ohne das Feld des Ziels, sonst wohlgeformt, Schlusszeile Form 1 mit der vollen Markenzahl" \
  "$(zaehler_pfad "$zustand173" "fall173")" "KETTE ausgabe-unlesbar"

bad174="::LAGE K1 D3 linter FOO FEHLT=wert-x SCHWELLE=1200s:: (rueckgabewert=0)"
ausgabe174=$(bauen_ausgabe "$baum17x" "$bad174" "$D19_OK" "$schluss17x")
zustand174=$(neu_verzeichnis)
lauf_mit_zustand "$zustand174" "$baum17x" Stop "fall174" "$ausgabe174" 0
pruefe_zaehler_schluessel Z-174 "Grammatik LAGE: Marke mit einem Lage-Wort ausserhalb von A_OK, A_FAIL, B und C, sonst wohlgeformt, Schlusszeile Form 1 mit der vollen Markenzahl" \
  "$(zaehler_pfad "$zustand174" "fall174")" "KETTE ausgabe-unlesbar"

bad175="::LAGE K1 D3 linter A_OK FEHLT= SCHWELLE=1200s:: (rueckgabewert=0)"
ausgabe175=$(bauen_ausgabe "$baum17x" "$bad175" "$D19_OK" "$schluss17x")
zustand175=$(neu_verzeichnis)
lauf_mit_zustand "$zustand175" "$baum17x" Stop "fall175" "$ausgabe175" 0
pruefe_zaehler_schluessel Z-175 "Grammatik FEHLT: Marke mit FEHLT= ohne Wert, sonst wohlgeformt, Schlusszeile Form 1 mit der vollen Markenzahl" \
  "$(zaehler_pfad "$zustand175" "fall175")" "KETTE ausgabe-unlesbar"

bad176="::LAGE K1 D3 linter A_OK FEHLT=wert-x SCHWELLE=:: (rueckgabewert=0)"
ausgabe176=$(bauen_ausgabe "$baum17x" "$bad176" "$D19_OK" "$schluss17x")
zustand176=$(neu_verzeichnis)
lauf_mit_zustand "$zustand176" "$baum17x" Stop "fall176" "$ausgabe176" 0
pruefe_zaehler_schluessel Z-176 "Grammatik SCHWELLE: Marke mit SCHWELLE= ohne Wert, sonst wohlgeformt, Schlusszeile Form 1 mit der vollen Markenzahl" \
  "$(zaehler_pfad "$zustand176" "fall176")" "KETTE ausgabe-unlesbar"

bad177="::LAGE K1 D3 linter A_OK FEHLT=wert-x SCHWELLE=1200s (rueckgabewert=0)"
ausgabe177=$(bauen_ausgabe "$baum17x" "$bad177" "$D19_OK" "$schluss17x")
zustand177=$(neu_verzeichnis)
lauf_mit_zustand "$zustand177" "$baum17x" Stop "fall177" "$ausgabe177" 0
pruefe_zaehler_schluessel Z-177 "Grammatik ABSCHLUSS: Marke ohne das schliessende ::, sonst wohlgeformt, Schlusszeile Form 1 mit der vollen Markenzahl" \
  "$(zaehler_pfad "$zustand177" "fall177")" "KETTE ausgabe-unlesbar"
pruefe_rc Z-178 "Grammatik ABSCHLUSS: derselbe Fall -- Marke ohne das schliessende ::" 2

bad179="::LAGE K1 D3 linter A_OK FEHLT=wert-x SCHWELLE=1200s:: (rueckgabewert=)"
ausgabe179=$(bauen_ausgabe "$baum17x" "$bad179" "$D19_OK" "$schluss17x")
zustand179=$(neu_verzeichnis)
lauf_mit_zustand "$zustand179" "$baum17x" Stop "fall179" "$ausgabe179" 0
pruefe_zaehler_schluessel Z-179 "Grammatik RUECKGABE: Marke mit (rueckgabewert=) ohne Zahl, sonst wohlgeformt, Schlusszeile Form 1 mit der vollen Markenzahl" \
  "$(zaehler_pfad "$zustand179" "fall179")" "KETTE ausgabe-unlesbar"
}

# --- Z-180 (DT8-04): cwd ausserhalb jedes Baums, CLAUDE_PROJECT_DIR auf ein
#     Unterverzeichnis des geprueften Baums -- physische Aufloesung auf die
#     Wurzel ueber "git rev-parse --show-toplevel".
fall_z180() {
baum180=$(neuer_mock_baum)
ausserhalb180=$(neu_verzeichnis)
m1_180=$(marken_zeile K1 D20 belege A_OK "" "" 0)
ausgabe180=$(bauen_ausgabe "$baum180" "$m1_180" "$D19_OK" "make dod: alle 1 Kettenschritte durchlaufen, keiner ungleich 0, 1 gueltige Marken gezaehlt.")
zustand180=$(neu_verzeichnis)
eingabe180=$(baue_eingabe "Stop" "$ausserhalb180" "fall180")
rufe_gate "$eingabe180" "$zustand180" "$WERKZEUGKASTEN_VOLL" "CLAUDE_PROJECT_DIR=$baum180/docs" "MOCK_AUSGABE=$ausgabe180" "MOCK_RC=0"
pruefe_rc Z-180 "Arbeitsverzeichnis ausserhalb jedes Git-Baums, CLAUDE_PROJECT_DIR auf ein Unterverzeichnis des geprueften Baums, gruene Attrappenkette" 0
}

# --- Z-181 (DT8-05): statische Lesung, kein Aufruf des Gates ---------------
fall_z181() {
timeout_gate181=$(grep -oE 'timeout -k 10 [0-9]+' "$GATE" | grep -oE '[0-9]+$' | head -n1)
timeout_min181=$(jq '[.hooks.Stop[].hooks[].timeout, .hooks.SubagentStop[].hooks[].timeout, .hooks.TaskCompleted[].hooks[].timeout] | min' "$REPO_WURZEL/.claude/settings.json")
pruefe_wahr Z-181 "selbsttest" "kleiner" "Statische Lesung von .claude/hooks/dod-gate.sh und .claude/settings.json, ohne Aufruf des Gates" \
  "die Sekundenzahl im Aufruf timeout -k 10 <N> make des Gates ist kleiner als der kleinste timeout-Wert der drei Hook-Eintraege Stop, SubagentStop und TaskCompleted in .claude/settings.json" \
  "$([ "$timeout_gate181" -lt "$timeout_min181" ] && echo 1 || echo 0)" \
  "< $timeout_min181" "$timeout_gate181"
}

# --- Z-185 (Grammatik ENDE, DT9-01, 6.12.27 i a) ---------------------------
fall_z185() {
baum185=$(neuer_mock_baum)
bad185="::LAGE K1 D3 linter A_OK FEHLT=wert-x SCHWELLE=1200s:: (rueckgabewert=0) x"
ausgabe185=$(bauen_ausgabe "$baum185" "$bad185" "$D19_OK" "make dod: alle 1 Kettenschritte durchlaufen, keiner ungleich 0, 1 gueltige Marken gezaehlt.")
zustand185=$(neu_verzeichnis)
lauf_mit_zustand "$zustand185" "$baum185" Stop "fall185" "$ausgabe185" 0
pruefe_zaehler_schluessel Z-185 "Grammatik ENDE: Marke mit einem Anhang hinter der Rueckgabewertklammer (etwa ' x'), sonst wohlgeformt, Schlusszeile Form 1 mit der vollen Markenzahl" \
  "$(zaehler_pfad "$zustand185" "fall185")" "KETTE ausgabe-unlesbar"
}

# --- Z-186 (Aussage E03, DT9-02) --------------------------------------------
fall_z186() {
baum186=$(neuer_mock_baum)
zustand186=$(neu_verzeichnis)
m1_186a=$(marken_zeile K1 D3 linter A_FAIL "" "" 2)
ausgabe186a=$(bauen_ausgabe "$baum186" "$m1_186a" "$D19_OK" "make dod: abgebrochen bei D3 linter, Rueckgabewert 2.")
lauf_mit_zustand "$zustand186" "$baum186" Stop "fall186" "$ausgabe186a" 2
m1_186b=$(marken_zeile K1 D7 abnahme C scripts/abnahme-abgleich.sh "" 2)
ausgabe186b=$(bauen_ausgabe "$baum186" "$m1_186b" "$D19_OK" "make dod: alle 1 Kettenschritte durchlaufen, 1 davon ohne Urteil (Lage C): D7 abnahme FEHLT=scripts/abnahme-abgleich.sh, Rueckgabewert 2.")
lauf_mit_zustand "$zustand186" "$baum186" Stop "fall186" "$ausgabe186b" 2
pruefe_zaehler Z-186 "Aussage E03: Zwei Blocks nacheinander mit verschiedenen Schluesseln in derselben Sitzung" \
  "$(zaehler_pfad "$zustand186" "fall186")" 1
}

# --- Z-187 (Aussage E04, DT9-03) --------------------------------------------
fall_z187() {
baum187=$(neuer_mock_baum)
zustand187=$(neu_verzeichnis)
m1_187a=$(marken_zeile K1 D3 linter A_FAIL "" "" 2)
ausgabe187a=$(bauen_ausgabe "$baum187" "$m1_187a" "$D19_OK" "make dod: abgebrochen bei D3 linter, Rueckgabewert 2.")
lauf_mit_zustand "$zustand187" "$baum187" Stop "fall187" "$ausgabe187a" 2
m1_187b=$(marken_zeile K1 D20 belege A_OK "" "" 0)
ausgabe187b=$(bauen_ausgabe "$baum187" "$m1_187b" "$D19_OK" "make dod: alle 1 Kettenschritte durchlaufen, keiner ungleich 0, 1 gueltige Marken gezaehlt.")
lauf_mit_zustand "$zustand187" "$baum187" Stop "fall187" "$ausgabe187b" 0
pruefe_datei Z-187 "Aussage E04: Belegtes Gruen nach einem vorangegangenen Block am selben Kriterium in derselben Sitzung" \
  "am Ort der Zaehlerdatei besteht nach dem Durchlass keine Datei mehr -- ein Durchlass wegen Ergebnis loescht den Zaehler" \
  "$(zaehler_pfad "$zustand187" "fall187")" fehlt
}

# --- Z-188 (Aussage E06) -----------------------------------------------------
fall_z188() {
baum188=$(neuer_mock_baum)
zustand188=$(neu_verzeichnis)
# S9-03 (6.12.27 i, Nachbesserung nach dem Mutationslauf vom 2026-09-06,
# Z-188 NICHT ERKANNT): die Eingabe traegt agent_id "a1" (SubagentStop) --
# das Gate faltet eine vorhandene agent_id IMMER in seinen eigenen
# Zaehlerpfad ein (Zeilen ~205-212 in dod-gate.sh), unabhaengig vom
# Ereignis. Die vorherige Fassung sah unter "zaehler_pfad" (OHNE Agent-
# Anteil) nach -- einem Pfad, den das Gate fuer DIESEN Aufruf nie anspricht.
# Die eingefuegte Mutationszeile "loesche_zaehler" traf deshalb eine andere,
# nicht bestehende Datei und blieb wirkungslos, ohne dass das ein Befund an
# der Huelle war -- der Fall sah selbst den falschen Ort an. Jetzt derselbe
# Pfad, den auch das Gate fuer diesen Aufruf bildet.
zaehlerdatei188=$(zaehler_pfad_mit_agent "$zustand188" "fall188" "a1")
mkdir -p "$(dirname "$zaehlerdatei188")"
printf 'X\n2\n' > "$zaehlerdatei188"
eingabe188=$(baue_eingabe "SubagentStop" "$baum188" "fall188" "false" "a1" "attrappe-pruefer")
rufe_gate "$eingabe188" "$zustand188" "$WERKZEUGKASTEN_VOLL" "CLAUDE_PROJECT_DIR=$baum188" "MOCK_AUSGABE=roter Muell, duerfte nie gelesen werden" "MOCK_RC=2"
schluessel188=$(sed -n '1p' "$zaehlerdatei188" 2>/dev/null || true)
stand188=$(sed -n '2p' "$zaehlerdatei188" 2>/dev/null || true)
pruefe_zaehler_wahr Z-188 "gleich" "Aussage E06: SubagentStop einer Rolle ohne veraenderndes Werkzeug, Zaehlerdatei vor dem Aufruf mit einem Schluessel und dem Stand 2 angelegt" \
  "Zaehlerdatei traegt nach dem Aufruf unveraendert denselben Schluessel und den Stand 2" \
  "$([ "$schluessel188" = "X" ] && [ "$stand188" = "2" ] && echo 1 || echo 0)" \
  "Schluessel=X, Stand=2" "Schluessel=$schluessel188, Stand=$stand188"
}

# --- Z-189 (Aussage E08) -----------------------------------------------------
fall_z189() {
baum189=$(neuer_mock_baum)
zustand189=$(neu_verzeichnis)
m1_189=$(marken_zeile K1 D3 linter A_FAIL "" "" 2)
ausgabe189=$(bauen_ausgabe "$baum189" "$m1_189" "$D19_OK" "make dod: abgebrochen bei D3 linter, Rueckgabewert 2.")
lauf_mit_zustand "$zustand189" "$baum189" Stop "fall189" "$ausgabe189" 2
lauf_mit_zustand "$zustand189" "$baum189" TaskCompleted "fall189" "$ausgabe189" 2
pruefe_zaehler Z-189 "Aussage E08: ein Stop-Block und danach ein TaskCompleted-Block am selben Kriterium in derselben Sitzung" \
  "$(zaehler_pfad "$zustand189" "fall189")" 2
}

# --- Z-190 (Aussage E09) -----------------------------------------------------
fall_z190() {
baum190=$(neuer_mock_baum)
zustand190=$(neu_verzeichnis)
m1_190=$(marken_zeile K1 D3 linter A_FAIL "" "" 2)
ausgabe190=$(bauen_ausgabe "$baum190" "$m1_190" "$D19_OK" "make dod: abgebrochen bei D3 linter, Rueckgabewert 2.")
lauf_mit_zustand "$zustand190" "$baum190" Stop "fall190" "$ausgabe190" 2
eingabe190=$(baue_eingabe "SubagentStop" "$baum190" "fall190" "false" "agent190" "attrappe-schreiber")
rufe_gate "$eingabe190" "$zustand190" "$WERKZEUGKASTEN_VOLL" "CLAUDE_PROJECT_DIR=$baum190" "MOCK_AUSGABE=$ausgabe190" "MOCK_RC=2"
pruefe_zaehler Z-190 "Aussage E09: ein Stop-Block und ein SubagentStop-Block mit agent_id am selben Kriterium in derselben Sitzung" \
  "$(zaehler_pfad_mit_agent "$zustand190" "fall190" "agent190")" 1
}

# -----------------------------------------------------------------------------
# fall_z198 (ADR 0002, 6.12.27 j, Punkt 5, DT10-04): Grammatik ANFANG --
# eine EINGEBETTETE Marke ("Fundstelle: ::LAGE ...") ist keine Marke, weil
# das marken_muster des Gates mit "^" ankert. Sonst wohlgeformt, Schlusszeile
# Form 1 mit der VOLLEN Markenzahl (1) -- der Widerspruch zwischen der
# behaupteten Zahl (1) und der tatsaechlich GELESENEN Zahl (0, weil die
# einzige Zeile nicht am Anfang steht) loest S-11 aus.
# -----------------------------------------------------------------------------
fall_z198() {
baum198=$(neuer_mock_baum)
zustand198=$(neu_verzeichnis)
marke198=$(marken_zeile K1 D3 linter A_OK "" "" 0)
marken198="Fundstelle: $marke198"
ausgabe198=$(bauen_ausgabe "$baum198" "$marken198" "$D19_OK" "make dod: alle 1 Kettenschritte durchlaufen, keiner ungleich 0, 1 gueltige Marken gezaehlt.")
lauf_mit_zustand "$zustand198" "$baum198" Stop "fall198" "$ausgabe198" 0
pruefe_zaehler_schluessel Z-198 "Grammatik ANFANG: eingebettete Marke (Fundstelle: ::LAGE K1 D3 linter A_OK:: (rueckgabewert=0)), sonst wohlgeformt, Schlusszeile Form 1 mit der vollen Markenzahl" \
  "$(zaehler_pfad "$zustand198" "fall198")" "KETTE ausgabe-unlesbar"
}

# -----------------------------------------------------------------------------
# fall_z199 (ADR 0002, 6.12.27 j, Punkt 5, DT10-05): Erzeugerseite der Marke.
# NEUER Fall -- minimaler Scheinbaum mit dem ECHTEN Makefile und dem ECHTEN
# Belegpruefer samt Ausnahmeliste, "make -s dod" darin unter WERKZEUGKASTEN_VOLL
# ausgefuehrt (grosser, aber nicht anspruchsvoller Lauf -- Gruen wird NICHT
# verlangt, 6.12.27 j Punkt 5). marken_muster wird AUS DEM GATE gelesen, nicht
# im Selbsttest wiederholt. Gemessen werden die UEBERSICHTSZEILEN (beginnen mit
# "::LAGE", enthalten " (rueckgabewert="), NICHT die rohen Marken waehrend des
# Laufs (die tragen den Anhang noch nicht, Makefile "KLASSIFIZIEREN").
# -----------------------------------------------------------------------------
fall_z199() {
baum199=$(neu_verzeichnis)
git -C "$baum199" init -q
git -C "$baum199" config user.email "selbsttest@example.invalid"
git -C "$baum199" config user.name "Selbsttest"
cp "$ECHTES_MAKEFILE" "$baum199/Makefile"
mkdir -p "$baum199/scripts" "$baum199/.claude/hooks"
cp "$ECHTER_BELEGPRUEFER" "$baum199/scripts/belege-pruefen.sh"
cp "$REPO_WURZEL/scripts/belege-ausnahmen.txt" "$baum199/scripts/belege-ausnahmen.txt"
: > "$baum199/.claude/hooks/dod-gate-terminierte-lagen.txt"
git -C "$baum199" add -A
git -C "$baum199" commit -q -m init

ausgabe199_stdout=$(mktemp)
ausgabe199_stderr=$(mktemp)
PATH="$WERKZEUGKASTEN_VOLL" make -s -C "$baum199" dod >"$ausgabe199_stdout" 2>"$ausgabe199_stderr"
rc199=$?

marken_muster199=$(sed -n "s/^marken_muster='\\(.*\\)'\$/\\1/p" "$GATE")

gesamt199=0
verfehlend199=0
zeilen199=""
while IFS= read -r zeile199; do
  case "$zeile199" in
    "::LAGE"*" (rueckgabewert="*)
      gesamt199=$((gesamt199 + 1))
      if ! printf '%s' "$zeile199" | grep -qE -- "$marken_muster199"; then
        verfehlend199=$((verfehlend199 + 1))
      fi
      zeilen199="$zeilen199$zeile199 | "
      ;;
  esac
done < <(cat "$ausgabe199_stdout" "$ausgabe199_stderr")

pruefe_kette_fehlt Z-199 \
  "Erzeugerseite der Marke: Lauf des echten Makefile mit dem Ziel dod in einem minimalen Scheinbaum, gemessen an der Uebersicht" \
  "in der Uebersicht besteht keine mit ::LAGE beginnende Zeile, die das aus dem Gate gelesene marken_muster nicht trifft, und es besteht mindestens eine solche Zeile" \
  "$verfehlend199" "$gesamt199"

echo "Z-199 Diagnose (kein Teil der Zusicherung, zur Meldung): make dod rc=$rc199, marken_muster='$marken_muster199', Uebersichtszeilen ($gesamt199): $zeilen199" >&2
rm -f "$ausgabe199_stdout" "$ausgabe199_stderr"
}

# -----------------------------------------------------------------------------
# fall_z208 (ADR 0002, 6.12.27 j, Punkt 7, DT10-02): NEUER Fall -- eine Liste
# mit GENAU EINER Zeile, die Selbstpruefung 6 verletzt (kein Tabulator
# zwischen Schluessel und Grund). Anders als fall_z122_124 (zwei Zeilen,
# verschiedene Selbstpruefungen, Prioritaet 2 vor 6) ist hier NUR die
# Selbstpruefung 6 verletzt, an Zeile 1 -- der Schluessel LISTE 6 1 ist
# eindeutig dieser einen Zeile zuzuordnen.
# -----------------------------------------------------------------------------
fall_z208() {
baum208=$(neuer_mock_baum)
printf 'D9 rueckkanal ohne tabulator\n' > "$baum208/.claude/hooks/dod-gate-terminierte-lagen.txt"
marker208=$(neu_verzeichnis)/marker
zustand208=$(neu_verzeichnis)
eingabe208=$(baue_eingabe "Stop" "$baum208" "fall208")
rufe_gate "$eingabe208" "$zustand208" "$WERKZEUGKASTEN_VOLL" "CLAUDE_PROJECT_DIR=$baum208" "MOCK_AUSGABE=darf nie gelesen werden" "MOCK_RC=0" "MOCK_MARKER=$marker208"
pruefe_zaehler_schluessel Z-208 "Liste mit einer Zeile, die die Selbstpruefung 6 verletzt (Zeile ohne Tabulator zwischen Schluessel und Grund)" \
  "$(zaehler_pfad "$zustand208" "fall208")" "LISTE 6 1"
}

# -----------------------------------------------------------------------------
# fall_z194_197 (ADR 0002, 6.12.27 j, Punkt 4): misst die Ausgabeform NICHT an
# einer Stichprobe, sondern als Invariante ueber ALLE Gate-Aufrufe DIESES
# Laufs, protokolliert von rufe_gate/rufe_gate_ohne_home in
# GATE_AUFRUF_PROTOKOLL. Wird als LETZTE Fallfunktion aufgerufen (Ende der
# Fallfolge, vor der Deckung) -- nur dann sind alle vorangehenden Aufrufe
# bereits protokolliert.
# -----------------------------------------------------------------------------
fall_z194_197() {
# SST-P1-04 (Wache): diese Funktion MUSS die LETZTE in FALL_REIHENFOLGE
# bleiben -- ihre Invarianten (A01/A04/A05/A08 unten) lesen das GESAMTE
# Aufrufprotokoll des Selbsttests bis GATE_AUFRUF_ZAEHLER; liefe sie
# frueher, blieben spaetere Gate-Aufrufe ungeprueft, ohne dass das auffiele.
if [ "${FALL_REIHENFOLGE[-1]:-}" != "fall_z194_197" ]; then
  echo "FEHLGESCHLAGEN WACHE fall_z194_197: ist NICHT die letzte Fallfunktion in FALL_REIHENFOLGE (letzte dort: '${FALL_REIHENFOLGE[-1]:-leer}') -- die Invarianten A01/A04/A05/A08 dieser Funktion wuerden dann nicht das gesamte Aufrufprotokoll des Laufs pruefen (SST-P1-04)." >&2
fi
# S10-10 (Koordinator-Befund, 2026-09-06): ein ISOLIERTER Mutationslauf ruft
# NUR diese eine Fallfunktion auf (kein vorangehender Fall hat das
# Aufrufprotokoll schon gefuellt) -- OHNE eigene Gate-Aufrufe waere
# GATE_AUFRUF_ZAEHLER hier 0, "seq 1 0" liefert nichts, und alle vier
# Invarianten waeren unter JEDER Mutation trivial "bestanden" (0 Aufrufe,
# 0 Verstoesse). Diese Funktion stellt sich deshalb selbst her: eine
# Eskalationsfolge mit VIER Aufrufen desselben Schluessels (durchlaeuft den
# Standardzweig, den "drittes Mal"-Zweig und den "viertes Mal"-Zweig, alle
# mit rc 2 -- keine Uebergabedatei vorhanden, also kein Durchlass) und ein
# stop_hook_active-Aufruf (rc 0, NICHT-leere Standardausgabe mit genau
# einem Feld systemMessage).
baum194x=$(neuer_mock_baum)
zustand194x=$(neu_verzeichnis)
m1_194x=$(marken_zeile K1 D3 linter A_FAIL "" "" 2)
ausgabe194x=$(bauen_ausgabe "$baum194x" "$m1_194x" "$D19_OK" "make dod: abgebrochen bei D3 linter, Rueckgabewert 2.")
lauf_mit_zustand "$zustand194x" "$baum194x" Stop "invarianten194" "$ausgabe194x" 2
lauf_mit_zustand "$zustand194x" "$baum194x" Stop "invarianten194" "$ausgabe194x" 2
lauf_mit_zustand "$zustand194x" "$baum194x" Stop "invarianten194" "$ausgabe194x" 2
lauf_mit_zustand "$zustand194x" "$baum194x" Stop "invarianten194" "$ausgabe194x" 2
zustand194y=$(neu_verzeichnis)
eingabe194y=$(baue_eingabe "Stop" "$baum194x" "invarianten194-reentranz" "true")
rufe_gate "$eingabe194y" "$zustand194y" "$WERKZEUGKASTEN_VOLL" "CLAUDE_PROJECT_DIR=$baum194x" "MOCK_AUSGABE=roter Muell, darf nie gelesen werden" "MOCK_RC=2"

local fall194="Aussage A08/A04/A05/A01: alle Gate-Aufrufe dieses Selbsttestlaufs, aus dem Aufrufprotokoll des Selbsttests"
local anzahl194=0
local rc_verstoss194=0 rc_beispiel194=""
local a04_verstoss194=0 a04_beispiel194=""
local a05_verstoss194=0 a05_beispiel194=""
local a01_verstoss194=0 a01_beispiel194=""
local i194 rc194 so194 se194 einzelfeld194
for i194 in $(seq 1 "$GATE_AUFRUF_ZAEHLER"); do
  [ -f "$GATE_AUFRUF_PROTOKOLL/$i194.rc" ] || continue
  anzahl194=$((anzahl194 + 1))
  rc194=$(cat "$GATE_AUFRUF_PROTOKOLL/$i194.rc")
  so194=$(cat "$GATE_AUFRUF_PROTOKOLL/$i194.stdout")
  se194=$(cat "$GATE_AUFRUF_PROTOKOLL/$i194.stderr")
  if [ "$rc194" != "0" ] && [ "$rc194" != "2" ]; then
    rc_verstoss194=$((rc_verstoss194 + 1))
    [ -n "$rc_beispiel194" ] || rc_beispiel194="Aufruf $i194: rc=$rc194"
  fi
  if [ "$rc194" = "2" ]; then
    if [ -n "$so194" ]; then
      a04_verstoss194=$((a04_verstoss194 + 1))
      [ -n "$a04_beispiel194" ] || a04_beispiel194="Aufruf $i194: stdout='$(_kuerzen "$so194")'"
    fi
    case "$se194" in
      *"Schluessel: "*) ;;
      *)
        a05_verstoss194=$((a05_verstoss194 + 1))
        [ -n "$a05_beispiel194" ] || a05_beispiel194="Aufruf $i194: stderr='$(_kuerzen "$se194")'"
        ;;
    esac
  fi
  if [ "$rc194" = "0" ] && [ -n "$so194" ]; then
    einzelfeld194=0
    if printf '%s' "$so194" | jq -es \
         'length == 1 and (.[0] | type == "object" and (keys == ["systemMessage"]))' >/dev/null 2>&1 \
       && [ "$(printf '%s' "$so194" | jq -es \
         'length == 1 and (.[0] | type == "object" and (keys == ["systemMessage"]))' 2>/dev/null)" = "true" ]; then
      einzelfeld194=1
    fi
    if [ "$einzelfeld194" -eq 0 ]; then
      a01_verstoss194=$((a01_verstoss194 + 1))
      [ -n "$a01_beispiel194" ] || a01_beispiel194="Aufruf $i194: stdout='$(_kuerzen "$so194")'"
    fi
  fi
done

local ok194=0; [ "$rc_verstoss194" -eq 0 ] && ok194=1
pruefe_invariante_rc_fehlt Z-194 "$fall194" \
  "Ueber alle Gate-Aufrufe dieses Laufs tritt kein Rueckgabewert ausser 0 und 2 auf" \
  "$ok194" "kein rc ausser 0/2" "${rc_beispiel194:-keine Abweichung} ($anzahl194 Aufrufe erfasst)"

local ok195=0; [ "$a04_verstoss194" -eq 0 ] && ok195=1
pruefe_invariante_stdout_leer Z-195 "$fall194" \
  "Bei jedem Gate-Aufruf mit Rueckgabewert 2 ist die Standardausgabe leer" \
  "$ok195" "stdout leer bei rc=2" "${a04_beispiel194:-keine Abweichung} ($anzahl194 Aufrufe erfasst)"

local ok196=0; [ "$a05_verstoss194" -eq 0 ] && ok196=1
pruefe_invariante_stderr_enthaelt Z-196 "$fall194" \
  "Bei jedem Gate-Aufruf mit Rueckgabewert 2 enthaelt die Fehlerausgabe 'Schluessel: '" \
  "$ok196" "stderr enthaelt 'Schluessel: ' bei rc=2" "${a05_beispiel194:-keine Abweichung} ($anzahl194 Aufrufe erfasst)"

local ok197=0; [ "$a01_verstoss194" -eq 0 ] && ok197=1
pruefe_invariante_stdout_einzelfeld Z-197 "$fall194" \
  "Bei jedem Gate-Aufruf mit Rueckgabewert 0 ist die Standardausgabe leer oder genau ein JSON-Objekt mit dem einzigen Feld systemMessage" \
  "$ok197" "leer oder {systemMessage: ...} bei rc=0" "${a01_beispiel194:-keine Abweichung} ($anzahl194 Aufrufe erfasst)"
}

# =============================================================================
# PHASE 1 VON O-27 (ADR 0002, 6.12.28 b): die vier Vor-Eingabe- und Sperr-
# faelle (Z-209..Z-220), die statische flock-Zeile (Z-221), die acht Faelle
# an den bisher unbeschrittenen Aufrufstellen von blockieren_mit_zaehlung
# (Z-222..Z-229) und die Pfaddeckung selbst (Z-230, Z-231).
# =============================================================================

# --- Z-209..Z-211: Vor-Eingabe-Pfad, ungueltiges JSON (DT11-07/DT11-11) ----
fall_z209_211() {
local zustand209
zustand209=$(neu_verzeichnis)
rufe_gate "dies ist kein gueltiges JSON {" "$zustand209" "$WERKZEUGKASTEN_VOLL"
pruefe_rc Z-209 "Vor-Eingabe-Pfad: die Standardeingabe traegt kein gueltiges JSON (ein Ereignis ist deshalb nicht lesbar; Umgebung im Uebrigen vollstaendig: CLAUDE_PROJECT_DIR und Werkzeugkasten gesetzt)" 2
pruefe_stderr_enthaelt Z-210 "Derselbe Fall wie Z-209" \
  "Fehlerausgabe enthaelt Schluessel: EINGABE json" "Schluessel: EINGABE json"
pruefe_kein_zaehler_im_verzeichnis Z-211 "Aussage E23: derselbe Fall wie Z-209" \
  "im Zustandsverzeichnis besteht nach dem Block keine Zaehlerdatei" \
  "$zustand209"
}

# --- Z-212..Z-214: Vor-Eingabe-Pfad, unbekanntes Ereignis (DT11-08/DT11-11)
fall_z212_214() {
local zustand212 eingabe212
zustand212=$(neu_verzeichnis)
eingabe212=$(baue_eingabe "PreToolUse" "/tmp" "fall-z212")
rufe_gate "$eingabe212" "$zustand212" "$WERKZEUGKASTEN_VOLL"
pruefe_rc Z-212 "Vor-Eingabe-Pfad: das Ereignis der Eingabe wird von diesem Gate nicht bedient" 2
pruefe_stderr_enthaelt Z-213 "Derselbe Fall wie Z-212" \
  "Fehlerausgabe enthaelt Schluessel: EINGABE ereignis" "Schluessel: EINGABE ereignis"
pruefe_kein_zaehler_im_verzeichnis Z-214 "Aussage E23: derselbe Fall wie Z-212" \
  "im Zustandsverzeichnis besteht nach dem Block keine Zaehlerdatei" \
  "$zustand212"
}

# --- Z-215..Z-217: kein bestimmbarer Arbeitsbaum (DT11-09/DT11-11) --------
fall_z215_217() {
local ausserhalb215 zustand215 eingabe215
ausserhalb215=$(neu_verzeichnis)
zustand215=$(neu_verzeichnis)
eingabe215=$(baue_eingabe "Stop" "$ausserhalb215" "fall-z215")
rufe_gate "$eingabe215" "$zustand215" "$WERKZEUGKASTEN_VOLL"
pruefe_rc Z-215 "Weder CLAUDE_PROJECT_DIR noch das Eingabefeld cwd ergeben einen bestimmbaren Arbeitsbaum" 2
pruefe_stderr_enthaelt Z-216 "Derselbe Fall wie Z-215" \
  "Fehlerausgabe enthaelt Schluessel: EINGABE baum" "Schluessel: EINGABE baum"
pruefe_kein_zaehler_im_verzeichnis Z-217 "Aussage E23: derselbe Fall wie Z-215" \
  "im Zustandsverzeichnis besteht nach dem Block keine Zaehlerdatei" \
  "$zustand215"
}

# --- Z-218..Z-220: Sperrpfad, flock-Attrappe haelt -w 120 auf -w 1 kurz ----
fall_z218_220() {
local baum218 baum218_real zustand218 baum_hash218 sperr_verz218 sperr_datei218 halter_pid218 eingabe218
baum218=$(neuer_mock_baum)
baum218_real=$(cd "$baum218" && git rev-parse --show-toplevel)
zustand218=$(neu_verzeichnis)
baum_hash218=$(printf '%s' "$baum218_real" | sha256sum | cut -d' ' -f1)
sperr_verz218="$zustand218/r3cosint/dod-gate"
mkdir -p "$sperr_verz218"
sperr_datei218="$sperr_verz218/sperre-$baum_hash218.lock"
(
  exec 8>"$sperr_datei218"
  flock 8
  sleep 3
) &
halter_pid218=$!
sleep 0.3
eingabe218=$(baue_eingabe "Stop" "$baum218" "fall-z218")
rufe_gate "$eingabe218" "$zustand218" "$WERKZEUGKASTEN_FAKE_FLOCK" \
  "CLAUDE_PROJECT_DIR=$baum218" "MOCK_AUSGABE=darf nie gelesen werden" "MOCK_RC=0"
pruefe_rc Z-218 "Sperrpfad: ein zweiter Prozess haelt die Sperre fuer den geprueften Baum, die flock-Attrappe des Werkzeugkastens schreibt die Wartezeit -w 120 auf eine kurze Zeit um" 2
pruefe_stderr_enthaelt Z-219 "Derselbe Fall wie Z-218" \
  "Fehlerausgabe enthaelt Schluessel: SPERRE belegt" "Schluessel: SPERRE belegt"
pruefe_kein_zaehler_im_verzeichnis Z-220 "Aussage E23: derselbe Fall wie Z-218" \
  "im Zustandsverzeichnis besteht nach dem Block keine Zaehlerdatei" \
  "$zustand218"
wait "$halter_pid218" 2>/dev/null || true
}

# --- Z-221: statische Lesung des flock-Aufrufs, ohne Aufruf des Gates -----
fall_z221() {
local flock_wartezeit221
flock_wartezeit221=$(grep -oE 'flock -w [0-9]+' "$GATE" | grep -oE '[0-9]+$' | head -n1)
pruefe_wahr Z-221 "selbsttest" "gleich" "Statische Lesung von .claude/hooks/dod-gate.sh, ohne Aufruf des Gates" \
  "der flock-Aufruf des Gates nennt als Wartezeit genau 120" \
  "$([ "$flock_wartezeit221" = "120" ] && echo 1 || echo 0)" \
  "120" "$flock_wartezeit221"
}

# --- Z-222: mktemp -p <Zielverzeichnis> schlaegt fehl (Zeile 705) ---------
fall_z222() {
local baum222 zustand222 eingabe222
baum222=$(neuer_mock_baum)
zustand222=$(neu_verzeichnis)
eingabe222=$(baue_eingabe "Stop" "$baum222" "fall-z222")
rufe_gate "$eingabe222" "$zustand222" "$WERKZEUGKASTEN_FAKE_MKTEMP_Z222" \
  "CLAUDE_PROJECT_DIR=$baum222" "MOCK_AUSGABE=darf nie gelesen werden" "MOCK_RC=0"
pruefe_zaehler_schluessel Z-222 "mktemp -p Zielverzeichnis schlaegt fehl -- mktemp-Attrappe, deren erster Aufruf mit 1 endet" \
  "$(zaehler_pfad "$zustand222" "fall-z222")" "GATE mktemp"
}

# --- Z-223: /tmp-Ausweichdatei physisch nicht aufloesbar (Zeile 740) ------
fall_z223() {
local baum223 zustand223 eingabe223 tmpdir223
baum223=$(neuer_mock_baum)
zustand223=$(neu_verzeichnis)
# TMPDIR MUSS auf ein Verzeichnis AUSSERHALB "/tmp" zeigen: sonst waere
# "ziel_verzeichnis" im Gate bereits beim ERSTEN Aufruf woertlich "/tmp"
# (Vorgabewert ohne TMPDIR), und die Attrappe koennte ersten und zweiten
# Aufruf nicht mehr am Argument "-p /tmp" unterscheiden (beide waeren
# identisch) -- belegt am Bau, erster Lauf traf faelschlich Zeile 723 statt
# 740.
tmpdir223=$(neu_verzeichnis)
eingabe223=$(baue_eingabe "Stop" "$baum223" "fall-z223")
rufe_gate "$eingabe223" "$zustand223" "$WERKZEUGKASTEN_FAKE_MKTEMP_Z223" \
  "CLAUDE_PROJECT_DIR=$baum223" "MOCK_AUSGABE=darf nie gelesen werden" "MOCK_RC=0" \
  "FAKE_MKTEMP_ZIEL=$baum223" "TMPDIR=$tmpdir223"
pruefe_zaehler_schluessel Z-223 "die Ausweichdatei unter /tmp ist physisch nicht aufloesbar -- Attrappe, deren zweiter Aufruf einen Pfad in einem nicht vorhandenen Verzeichnis liefert" \
  "$(zaehler_pfad "$zustand223" "fall-z223")" "GATE mktemp"
}

# --- Z-224: auch /tmp liegt im geprueften Baum (Zeile 748) ----------------
fall_z224() {
local baum224 zustand224 eingabe224
baum224=$(neuer_mock_baum)
zustand224=$(neu_verzeichnis)
eingabe224=$(baue_eingabe "Stop" "$baum224" "fall-z224")
rufe_gate "$eingabe224" "$zustand224" "$WERKZEUGKASTEN_FAKE_MKTEMP_Z224" \
  "CLAUDE_PROJECT_DIR=$baum224" "MOCK_AUSGABE=darf nie gelesen werden" "MOCK_RC=0" "FAKE_MKTEMP_ZIEL=$baum224"
pruefe_zaehler_schluessel Z-224 "auch die Ausweichdatei liegt im geprueften Baum -- Attrappe, deren beide Aufrufe Pfade innerhalb des Baums liefern" \
  "$(zaehler_pfad "$zustand224" "fall-z224")" "GATE mktemp"
}

# --- Z-225: Attrappenausgabe OHNE Uebersichtszeile (Zeile 805) ------------
fall_z225() {
local baum225 ausgabe225 zustand225
baum225=$(neuer_mock_baum)
# SST-P3-02: "sonst vollstaendiger Lauf" -- Marke, D19-Zeile und Schlusszeile
# Form 1 sind mitzugeben, NUR die Uebersichtszeile selbst entfaellt (die
# vorige Fassung liess auch Marke/D19/Schlusszeile weg und traf Zeile 805
# ohnehin schon ueber die fehlende Baumzeile allein -- nicht ueber die
# tatsaechlich abgezielte Pruefung "keine Uebersichtszeile trotz sonst
# vollstaendiger Ausgabe").
ausgabe225=$(printf 'make dod: geprueft wird %s.\n%s\n\nmake dod: D19: %s\n%s\n' \
  "$baum225" "$(marken_zeile K1 D3 linter A_OK "" "" 0)" "$D19_OK" \
  "make dod: alle 1 Kettenschritte durchlaufen, keiner ungleich 0, 1 gueltige Marken gezaehlt.")
zustand225=$(neu_verzeichnis)
lauf_mit_zustand "$zustand225" "$baum225" Stop "fall-z225" "$ausgabe225" 0
pruefe_zaehler_schluessel Z-225 "Attrappenausgabe ohne Uebersichtszeile, sonst vollstaendiger Lauf" \
  "$(zaehler_pfad "$zustand225" "fall-z225")" "KETTE ausgabe-unlesbar"
}

# --- Z-226: Attrappenausgabe mit ZWEI D19-Zeilen statt genau einer (SST-P1-07)
fall_z226() {
local baum226 ausgabe226 zustand226
baum226=$(neuer_mock_baum)
ausgabe226=$(printf 'make dod: geprueft wird %s.\n=== Uebersicht Definition-of-Done-Kette (make dod) ===\n%s\n\nmake dod: D19: %s\nmake dod: D19: %s\n%s\n' \
  "$baum226" "$(marken_zeile K1 D3 linter A_OK "" "" 0)" "$D19_OK" "$D19_OK" \
  "make dod: alle 1 Kettenschritte durchlaufen, keiner ungleich 0, 1 gueltige Marken gezaehlt.")
zustand226=$(neu_verzeichnis)
lauf_mit_zustand "$zustand226" "$baum226" Stop "fall-z226" "$ausgabe226" 0
pruefe_zaehler_schluessel Z-226 "Attrappenausgabe mit zwei D19-Zeilen statt genau einer" \
  "$(zaehler_pfad "$zustand226" "fall-z226")" "KETTE ausgabe-unlesbar"
}

# --- Z-227: Attrappenausgabe mit ZWEI der vier Schlusszeilen (SST-P1-08) --
fall_z227() {
local baum227 ausgabe227 zustand227
baum227=$(neuer_mock_baum)
ausgabe227=$(printf 'make dod: geprueft wird %s.\n=== Uebersicht Definition-of-Done-Kette (make dod) ===\n%s\n\nmake dod: D19: %s\n%s\n%s\n' \
  "$baum227" "$(marken_zeile K1 D3 linter A_OK "" "" 0)" "$D19_OK" \
  "make dod: alle 1 Kettenschritte durchlaufen, keiner ungleich 0, 1 gueltige Marken gezaehlt." \
  "make dod: abgebrochen bei D3 linter, Rueckgabewert 2.")
zustand227=$(neu_verzeichnis)
lauf_mit_zustand "$zustand227" "$baum227" Stop "fall-z227" "$ausgabe227" 0
pruefe_zaehler_schluessel Z-227 "Attrappenausgabe mit zwei der vier Schlusszeilen statt genau einer" \
  "$(zaehler_pfad "$zustand227" "fall-z227")" "KETTE ausgabe-unlesbar"
}

# --- Z-228: Konsistenzwache -- A_FAIL-Marke, Form 1, Rueckgabewert 0 -----
fall_z228() {
local baum228 m1_228 ausgabe228 zustand228
baum228=$(neuer_mock_baum)
m1_228=$(marken_zeile K1 D3 linter A_FAIL "" "" 0)
ausgabe228=$(bauen_ausgabe "$baum228" "$m1_228" "$D19_OK" "make dod: alle 1 Kettenschritte durchlaufen, keiner ungleich 0, 1 gueltige Marken gezaehlt.")
zustand228=$(neu_verzeichnis)
lauf_mit_zustand "$zustand228" "$baum228" Stop "fall-z228" "$ausgabe228" 0
pruefe_zaehler_schluessel Z-228 "Konsistenzwache: Attrappenausgabe mit einer A_FAIL-Marke, Schlusszeile Form 1 und Rueckgabewert 0 der Kette" \
  "$(zaehler_pfad "$zustand228" "fall-z228")" "KETTE ausgabe-unlesbar"
}

# --- Z-229: Konsistenzwache -- nur A_OK, keine gedeckte Lage C, rc != 0 ---
fall_z229() {
local baum229 m1_229 ausgabe229 zustand229
baum229=$(neuer_mock_baum)
m1_229=$(marken_zeile K1 D3 linter A_OK "" "" 2)
# SST-P3-01: die Tabelle verlangt Schlusszeile FORM 1 (nicht Form 3/
# abgebrochen) bei Rueckgabewert 2 der Kette und nur A_OK-Marken -- genau
# dieser Widerspruch (Form 1 behauptet vollen Erfolg, MOCK_RC=2 sagt rot,
# keine Marke traegt A_FAIL oder C) ist die Konsistenzwache, ausgefuehrt
# belegt gegen Zeile 1115 im Gate (dieselbe Zeile wie die Mutation zu Z-229).
ausgabe229=$(bauen_ausgabe "$baum229" "$m1_229" "$D19_OK" "make dod: alle 1 Kettenschritte durchlaufen, keiner ungleich 0, 1 gueltige Marken gezaehlt.")
zustand229=$(neu_verzeichnis)
lauf_mit_zustand "$zustand229" "$baum229" Stop "fall-z229" "$ausgabe229" 2
pruefe_zaehler_schluessel Z-229 "Konsistenzwache: Attrappenausgabe nur mit A_OK-Marken, Schlusszeile Form 1, Rueckgabewert 2 der Kette, keine gedeckte Lage C" \
  "$(zaehler_pfad "$zustand229" "fall-z229")" "KETTE ausgabe-unlesbar"
}

# --- Z-232..Z-251 (6.12.28 c Punkt 10, O-27 (a2)): zwanzig Verstossformen
#     gegen je ein Element des marken_muster, Vorbild fall_z170_179/fall_z185
#     -- je eine missgebildete Marke (Probemarke nach der Fallspalte),
#     Schlusszeile Form 1 mit der vollen Markenzahl (1), MOCK_RC=0 (die Kette
#     behauptet vollen Erfolg; das Gate liest 0 tatsaechliche Marken, der
#     Widerspruch zur behaupteten Markenzahl blockiert unter KETTE
#     ausgabe-unlesbar). Basis: "::LAGE K1 D3 linter A_OK FEHLT=wert-x
#     SCHWELLE=1200s:: (rueckgabewert=0)", je EIN gezielter Verstoss.
fall_z232_251() {
baum23x=$(neuer_mock_baum)
schluss23x="make dod: alle 1 Kettenschritte durchlaufen, keiner ungleich 0, 1 gueltige Marken gezaehlt."

# Z-232 (DT11-01): einfacher Doppelpunkt statt :: vor der Klammer
bad232="::LAGE K1 D3 linter A_OK FEHLT=wert-x SCHWELLE=1200s: (rueckgabewert=0)"
ausgabe232=$(bauen_ausgabe "$baum23x" "$bad232" "$D19_OK" "$schluss23x")
zustand232=$(neu_verzeichnis)
lauf_mit_zustand "$zustand232" "$baum23x" Stop "fall232" "$ausgabe232" 0
pruefe_zaehler_schluessel Z-232 "Grammatik ABSCHLUSS: Marke mit einfachem Doppelpunkt statt :: vor der Rueckgabewertklammer, sonst wohlgeformt, Schlusszeile Form 1 mit der vollen Markenzahl" \
  "$(zaehler_pfad "$zustand232" "fall232")" "KETTE ausgabe-unlesbar"

# Z-233 (DT11-02): kein Leerzeichen zwischen :: und der Klammer
bad233="::LAGE K1 D3 linter A_OK FEHLT=wert-x SCHWELLE=1200s::(rueckgabewert=0)"
ausgabe233=$(bauen_ausgabe "$baum23x" "$bad233" "$D19_OK" "$schluss23x")
zustand233=$(neu_verzeichnis)
lauf_mit_zustand "$zustand233" "$baum23x" Stop "fall233" "$ausgabe233" 0
pruefe_zaehler_schluessel Z-233 "Grammatik TRENNUNG: Marke ohne Leerzeichen zwischen :: und der Rueckgabewertklammer, sonst wohlgeformt, Schlusszeile Form 1 mit der vollen Markenzahl" \
  "$(zaehler_pfad "$zustand233" "fall233")" "KETTE ausgabe-unlesbar"

# Z-234 (DT11-03): leere statt fehlende Lauf-Kennung
bad234="::LAGE  D3 linter A_OK FEHLT=wert-x SCHWELLE=1200s:: (rueckgabewert=0)"
ausgabe234=$(bauen_ausgabe "$baum23x" "$bad234" "$D19_OK" "$schluss23x")
zustand234=$(neu_verzeichnis)
lauf_mit_zustand "$zustand234" "$baum23x" Stop "fall234" "$ausgabe234" 0
pruefe_zaehler_schluessel Z-234 "Grammatik KENNUNG: Marke mit leerer statt fehlender Lauf-Kennung (zwei Leerzeichen hinter dem Praefix), sonst wohlgeformt, Schlusszeile Form 1 mit der vollen Markenzahl" \
  "$(zaehler_pfad "$zustand234" "fall234")" "KETTE ausgabe-unlesbar"

# Z-235: leere D-Nummer
bad235="::LAGE K1  linter A_OK FEHLT=wert-x SCHWELLE=1200s:: (rueckgabewert=0)"
ausgabe235=$(bauen_ausgabe "$baum23x" "$bad235" "$D19_OK" "$schluss23x")
zustand235=$(neu_verzeichnis)
lauf_mit_zustand "$zustand235" "$baum23x" Stop "fall235" "$ausgabe235" 0
pruefe_zaehler_schluessel Z-235 "Grammatik DNUMMER: Marke mit leerer statt fehlender D-Nummer, sonst wohlgeformt, Schlusszeile Form 1 mit der vollen Markenzahl" \
  "$(zaehler_pfad "$zustand235" "fall235")" "KETTE ausgabe-unlesbar"

# Z-236: leeres Ziel
bad236="::LAGE K1 D3  A_OK FEHLT=wert-x SCHWELLE=1200s:: (rueckgabewert=0)"
ausgabe236=$(bauen_ausgabe "$baum23x" "$bad236" "$D19_OK" "$schluss23x")
zustand236=$(neu_verzeichnis)
lauf_mit_zustand "$zustand236" "$baum23x" Stop "fall236" "$ausgabe236" 0
pruefe_zaehler_schluessel Z-236 "Grammatik ZIEL: Marke mit leerem statt fehlendem Ziel, sonst wohlgeformt, Schlusszeile Form 1 mit der vollen Markenzahl" \
  "$(zaehler_pfad "$zustand236" "fall236")" "KETTE ausgabe-unlesbar"

# Z-237: leeres Lage-Feld -- zwischen Ziel und Abschluss steht nur EIN
# Leerzeichen (FEHLT/SCHWELLE ebenfalls abwesend, Weisung des Koordinators
# vom 2026-09-07 nach der Feststellung zur Feldloeschung).
bad237="::LAGE K1 D3 linter :: (rueckgabewert=0)"
ausgabe237=$(bauen_ausgabe "$baum23x" "$bad237" "$D19_OK" "$schluss23x")
zustand237=$(neu_verzeichnis)
lauf_mit_zustand "$zustand237" "$baum23x" Stop "fall237" "$ausgabe237" 0
pruefe_zaehler_schluessel Z-237 "Grammatik LAGE: Marke mit leerem Lage-Feld -- zwischen Ziel und Abschluss steht nur ein Leerzeichen, sonst wohlgeformt, Schlusszeile Form 1 mit der vollen Markenzahl" \
  "$(zaehler_pfad "$zustand237" "fall237")" "KETTE ausgabe-unlesbar"

# Z-238 (DT11-04): fremdes Wort an der Stelle des Schwellenzusatzes
bad238="::LAGE K1 D3 linter A_OK FEHLT=wert-x OHNE_GRENZE:: (rueckgabewert=0)"
ausgabe238=$(bauen_ausgabe "$baum23x" "$bad238" "$D19_OK" "$schluss23x")
zustand238=$(neu_verzeichnis)
lauf_mit_zustand "$zustand238" "$baum23x" Stop "fall238" "$ausgabe238" 0
pruefe_zaehler_schluessel Z-238 "Grammatik SCHWELLE: an der Stelle des Schwellenzusatzes steht ein fremdes Wort (etwa OHNE_GRENZE), sonst wohlgeformt, Schlusszeile Form 1 mit der vollen Markenzahl" \
  "$(zaehler_pfad "$zustand238" "fall238")" "KETTE ausgabe-unlesbar"

# Z-239: Doppelpunkt im Wert von SCHWELLE=
bad239="::LAGE K1 D3 linter A_OK FEHLT=wert-x SCHWELLE=12:00s:: (rueckgabewert=0)"
ausgabe239=$(bauen_ausgabe "$baum23x" "$bad239" "$D19_OK" "$schluss23x")
zustand239=$(neu_verzeichnis)
lauf_mit_zustand "$zustand239" "$baum23x" Stop "fall239" "$ausgabe239" 0
pruefe_zaehler_schluessel Z-239 "Grammatik SCHWELLE: der Wert von SCHWELLE= enthaelt einen Doppelpunkt, sonst wohlgeformt, Schlusszeile Form 1 mit der vollen Markenzahl" \
  "$(zaehler_pfad "$zustand239" "fall239")" "KETTE ausgabe-unlesbar"

# Z-240: Doppelpunkt im Wert von FEHLT= (Weisung des Koordinators)
bad240="::LAGE K1 D3 linter A_OK FEHLT=wert:x SCHWELLE=1200s:: (rueckgabewert=0)"
ausgabe240=$(bauen_ausgabe "$baum23x" "$bad240" "$D19_OK" "$schluss23x")
zustand240=$(neu_verzeichnis)
lauf_mit_zustand "$zustand240" "$baum23x" Stop "fall240" "$ausgabe240" 0
pruefe_zaehler_schluessel Z-240 "Grammatik FEHLT: der Wert von FEHLT= enthaelt einen Doppelpunkt, sonst wohlgeformt, Schlusszeile Form 1 mit der vollen Markenzahl" \
  "$(zaehler_pfad "$zustand240" "fall240")" "KETTE ausgabe-unlesbar"

# Z-241: ein zusaetzliches Feld zwischen Praefix und Lage
bad241="::LAGE K1 D3 linter EXTRA A_OK FEHLT=wert-x SCHWELLE=1200s:: (rueckgabewert=0)"
ausgabe241=$(bauen_ausgabe "$baum23x" "$bad241" "$D19_OK" "$schluss23x")
zustand241=$(neu_verzeichnis)
lauf_mit_zustand "$zustand241" "$baum23x" Stop "fall241" "$ausgabe241" 0
pruefe_zaehler_schluessel Z-241 "Grammatik KENNUNG: die Marke traegt ein zusaetzliches Feld zwischen Praefix und Lage, sonst wohlgeformt, Schlusszeile Form 1 mit der vollen Markenzahl" \
  "$(zaehler_pfad "$zustand241" "fall241")" "KETTE ausgabe-unlesbar"

# Z-242: kein trennendes Leerzeichen zwischen Ziel und Lage
bad242="::LAGE K1 D3 linterA_OK FEHLT=wert-x SCHWELLE=1200s:: (rueckgabewert=0)"
ausgabe242=$(bauen_ausgabe "$baum23x" "$bad242" "$D19_OK" "$schluss23x")
zustand242=$(neu_verzeichnis)
lauf_mit_zustand "$zustand242" "$baum23x" Stop "fall242" "$ausgabe242" 0
pruefe_zaehler_schluessel Z-242 "Grammatik ZIEL: zwischen Ziel und Lage steht kein trennendes Leerzeichen, sonst wohlgeformt, Schlusszeile Form 1 mit der vollen Markenzahl" \
  "$(zaehler_pfad "$zustand242" "fall242")" "KETTE ausgabe-unlesbar"

# Z-243: Praefix mit nur einem Doppelpunkt
bad243=":LAGE K1 D3 linter A_OK FEHLT=wert-x SCHWELLE=1200s:: (rueckgabewert=0)"
ausgabe243=$(bauen_ausgabe "$baum23x" "$bad243" "$D19_OK" "$schluss23x")
zustand243=$(neu_verzeichnis)
lauf_mit_zustand "$zustand243" "$baum23x" Stop "fall243" "$ausgabe243" 0
pruefe_zaehler_schluessel Z-243 "Grammatik PRAEFIX: das Praefix traegt nur einen Doppelpunkt (:LAGE ), sonst wohlgeformt, Schlusszeile Form 1 mit der vollen Markenzahl" \
  "$(zaehler_pfad "$zustand243" "fall243")" "KETTE ausgabe-unlesbar"

# Z-244: Praefix ohne trennendes Leerzeichen
bad244="::LAGEK1 D3 linter A_OK FEHLT=wert-x SCHWELLE=1200s:: (rueckgabewert=0)"
ausgabe244=$(bauen_ausgabe "$baum23x" "$bad244" "$D19_OK" "$schluss23x")
zustand244=$(neu_verzeichnis)
lauf_mit_zustand "$zustand244" "$baum23x" Stop "fall244" "$ausgabe244" 0
pruefe_zaehler_schluessel Z-244 "Grammatik PRAEFIX: zwischen ::LAGE und der Lauf-Kennung steht kein Leerzeichen, sonst wohlgeformt, Schlusszeile Form 1 mit der vollen Markenzahl" \
  "$(zaehler_pfad "$zustand244" "fall244")" "KETTE ausgabe-unlesbar"

# Z-245: weder :: noch Leerzeichen vor der Klammer
bad245="::LAGE K1 D3 linter A_OK FEHLT=wert-x SCHWELLE=1200s(rueckgabewert=0)"
ausgabe245=$(bauen_ausgabe "$baum23x" "$bad245" "$D19_OK" "$schluss23x")
zustand245=$(neu_verzeichnis)
lauf_mit_zustand "$zustand245" "$baum23x" Stop "fall245" "$ausgabe245" 0
pruefe_zaehler_schluessel Z-245 "Grammatik ABSCHLUSS: die Marke traegt weder :: noch ein Leerzeichen vor der Rueckgabewertklammer, sonst wohlgeformt, Schlusszeile Form 1 mit der vollen Markenzahl" \
  "$(zaehler_pfad "$zustand245" "fall245")" "KETTE ausgabe-unlesbar"

# Z-246: Rueckgabewertklammer ohne oeffnende Klammer
bad246="::LAGE K1 D3 linter A_OK FEHLT=wert-x SCHWELLE=1200s:: rueckgabewert=0)"
ausgabe246=$(bauen_ausgabe "$baum23x" "$bad246" "$D19_OK" "$schluss23x")
zustand246=$(neu_verzeichnis)
lauf_mit_zustand "$zustand246" "$baum23x" Stop "fall246" "$ausgabe246" 0
pruefe_zaehler_schluessel Z-246 "Grammatik RUECKGABE: die Rueckgabewertklammer steht ohne oeffnende Klammer, sonst wohlgeformt, Schlusszeile Form 1 mit der vollen Markenzahl" \
  "$(zaehler_pfad "$zustand246" "fall246")" "KETTE ausgabe-unlesbar"

# Z-247: Rueckgabewertklammer ohne Gleichheitszeichen
bad247="::LAGE K1 D3 linter A_OK FEHLT=wert-x SCHWELLE=1200s:: (rueckgabewert0)"
ausgabe247=$(bauen_ausgabe "$baum23x" "$bad247" "$D19_OK" "$schluss23x")
zustand247=$(neu_verzeichnis)
lauf_mit_zustand "$zustand247" "$baum23x" Stop "fall247" "$ausgabe247" 0
pruefe_zaehler_schluessel Z-247 "Grammatik RUECKGABE: die Rueckgabewertklammer steht ohne Gleichheitszeichen, sonst wohlgeformt, Schlusszeile Form 1 mit der vollen Markenzahl" \
  "$(zaehler_pfad "$zustand247" "fall247")" "KETTE ausgabe-unlesbar"

# Z-248: ohne schliessende Klammer
bad248="::LAGE K1 D3 linter A_OK FEHLT=wert-x SCHWELLE=1200s:: (rueckgabewert=0"
ausgabe248=$(bauen_ausgabe "$baum23x" "$bad248" "$D19_OK" "$schluss23x")
zustand248=$(neu_verzeichnis)
lauf_mit_zustand "$zustand248" "$baum23x" Stop "fall248" "$ausgabe248" 0
pruefe_zaehler_schluessel Z-248 "Grammatik RUECKGABE: die Marke endet ohne schliessende Klammer, sonst wohlgeformt, Schlusszeile Form 1 mit der vollen Markenzahl" \
  "$(zaehler_pfad "$zustand248" "fall248")" "KETTE ausgabe-unlesbar"

# Z-249: ohne das Wort rueckgabewert=
bad249="::LAGE K1 D3 linter A_OK FEHLT=wert-x SCHWELLE=1200s:: 0)"
ausgabe249=$(bauen_ausgabe "$baum23x" "$bad249" "$D19_OK" "$schluss23x")
zustand249=$(neu_verzeichnis)
lauf_mit_zustand "$zustand249" "$baum23x" Stop "fall249" "$ausgabe249" 0
pruefe_zaehler_schluessel Z-249 "Grammatik RUECKGABE: die Marke traegt hinter dem Abschluss nur die Zahl, ohne das Wort rueckgabewert=, sonst wohlgeformt, Schlusszeile Form 1 mit der vollen Markenzahl" \
  "$(zaehler_pfad "$zustand249" "fall249")" "KETTE ausgabe-unlesbar"

# Z-250: Buchstabe statt Ziffer im Rueckgabewert
bad250="::LAGE K1 D3 linter A_OK FEHLT=wert-x SCHWELLE=1200s:: (rueckgabewert=x)"
ausgabe250=$(bauen_ausgabe "$baum23x" "$bad250" "$D19_OK" "$schluss23x")
zustand250=$(neu_verzeichnis)
lauf_mit_zustand "$zustand250" "$baum23x" Stop "fall250" "$ausgabe250" 0
pruefe_zaehler_schluessel Z-250 "Grammatik RUECKGABE: der Rueckgabewert traegt einen Buchstaben statt einer Ziffer, sonst wohlgeformt, Schlusszeile Form 1 mit der vollen Markenzahl" \
  "$(zaehler_pfad "$zustand250" "fall250")" "KETTE ausgabe-unlesbar"

# Z-251 (DT11-05): nachlaufendes Leerzeichen hinter der Rueckgabewertklammer
bad251="::LAGE K1 D3 linter A_OK FEHLT=wert-x SCHWELLE=1200s:: (rueckgabewert=0) "
ausgabe251=$(bauen_ausgabe "$baum23x" "$bad251" "$D19_OK" "$schluss23x")
zustand251=$(neu_verzeichnis)
lauf_mit_zustand "$zustand251" "$baum23x" Stop "fall251" "$ausgabe251" 0
pruefe_zaehler_schluessel Z-251 "Grammatik ENDE: die Marke traegt ein nachlaufendes Leerzeichen hinter der Rueckgabewertklammer, sonst wohlgeformt, Schlusszeile Form 1 mit der vollen Markenzahl" \
  "$(zaehler_pfad "$zustand251" "fall251")" "KETTE ausgabe-unlesbar"
}

# -----------------------------------------------------------------------------
# pfaddeckung_pruefen (ADR 0002, 6.12.28 b, O-27 (a1), Z-230/Z-231): die
# Sollmenge (Ausstiege UND Aufrufstellen von blockieren_mit_zaehlung, ohne
# Definitionszeile, mit Kommentarregel) wird mechanisch aus $GATE erhoben,
# gegen die Ausfuehrungsspur $SPUR_DATEI gehalten (jede Stelle beschritten,
# wenn die Spur eine Zeile "^\++<n>:exit [0-9]+$" bzw.
# "^\++<n>:blockieren_mit_zaehlung " traegt), abzueglich der Ausnahmen aus
# .claude/hooks/dod-gate-pfadausnahmen.txt. Gibt die Zeile "Pfaddeckung: ..."
# aus und meldet Z-230 (m=0) sowie Z-231 (Spurzeilen "set -uo pipefail"
# gleich GATE_AUFRUF_ZAEHLER). Faellt (a) die Ausnahmedatei, (b) die
# Sollmenge (n=0) oder (c) die Spur (leer) aus, ist das ein Fehlschlag BEIDER
# Zeilen -- ohne fremde Kennung (6.12.28 b Punkt 4/5, fail-closed).
# Aufgerufen (a) im Normalmodus direkt aus zusammenfassung_und_deckung_aus-
# geben, VOR den Deckungspruefungen, und (b) im isolierten Mutationslauf aus
# fall_z230_231, NACHDEM diese die ganze FALL_REIHENFOLGE selbst ausgefuehrt
# hat.
# -----------------------------------------------------------------------------
pfaddeckung_pruefen() {
local fallpd="Ausfuehrungsspur ueber alle Aufrufe des unveraenderten Gates in diesem Selbsttestlauf, gegen eine bytegleiche Wegwerfkopie"
local ausnahmedatei_pd="$REPO_WURZEL/.claude/hooks/dod-gate-pfadausnahmen.txt"
local -a soll_pd=()
local treffer_pd nr_pd rest_pd getrimmt_pd vor_hash_pd

# SST-P1-05: SPUR_KOPIE_FEHLGESCHLAGEN wurde gesetzt (oben im Vorspann,
# cmp-Vergleich der Wegwerfkopie), aber nie ausgewertet -- eine Spur gegen
# eine NICHT bytegleiche Kopie waere kein Beleg fuer das unveraenderte Gate
# und musste bislang trotzdem als "beschritten" durchgehen (fail-open).
# Fail-closed wie die beiden Faelle darunter: Z-230/Z-231 fallen sofort,
# ohne fremde Kennung.
if [ "${SPUR_KOPIE_FEHLGESCHLAGEN:-0}" -eq 1 ]; then
  pruefe_wahr Z-230 "selbsttest" "gleich" "$fallpd" \
    "die Ausgabezeile Pfaddeckung: nennt als Zahl der nicht beschrittenen Ausgangsstellen genau 0" \
    0 "m=0" "Wegwerfkopie des Gates ist nicht bytegleich (cmp) -- Spur waere kein Beleg fuer das unveraenderte Gate"
  pruefe_wahr Z-231 "selbsttest" "gleich" "Dieselbe Ausfuehrungsspur wie Z-230" \
    "die Zahl der Aufrufe, die die Spur ausweist, ist gleich der Zahl der Aufrufe des Aufrufprotokolls des Selbsttests" \
    0 "Spurzeilen=$GATE_AUFRUF_ZAEHLER" "Wegwerfkopie des Gates ist nicht bytegleich (cmp)"
  return
fi

while IFS= read -r treffer_pd; do
  [ -n "$treffer_pd" ] || continue
  nr_pd="${treffer_pd%%:*}"
  rest_pd="${treffer_pd#*:}"
  getrimmt_pd="${rest_pd#"${rest_pd%%[![:space:]]*}"}"
  case "$getrimmt_pd" in '#'*) continue ;; esac
  vor_hash_pd="${rest_pd%%#*}"
  if printf '%s' "$vor_hash_pd" | grep -qE '(^|[[:space:];&|{])exit [0-9]+'; then
    soll_pd+=("$nr_pd")
  fi
done < <(grep -nE '(^|[[:space:];&|{])exit [0-9]+' "$GATE" 2>/dev/null)

while IFS= read -r treffer_pd; do
  [ -n "$treffer_pd" ] || continue
  nr_pd="${treffer_pd%%:*}"
  rest_pd="${treffer_pd#*:}"
  getrimmt_pd="${rest_pd#"${rest_pd%%[![:space:]]*}"}"
  case "$getrimmt_pd" in '#'*) continue ;; esac
  case "$rest_pd" in *'blockieren_mit_zaehlung()'*) continue ;; esac
  vor_hash_pd="${rest_pd%%#*}"
  if printf '%s' "$vor_hash_pd" | grep -qE '(^|[[:space:];&|{(])blockieren_mit_zaehlung[[:space:]]'; then
    soll_pd+=("$nr_pd")
  fi
done < <(grep -nE '(^|[[:space:];&|{(])blockieren_mit_zaehlung[[:space:]]' "$GATE" 2>/dev/null)

local n_pd=${#soll_pd[@]}

local -A beschritten_pd=()
local zeile_pd
if [ -f "$SPUR_DATEI" ]; then
  while IFS= read -r zeile_pd; do
    if [[ "$zeile_pd" =~ ^\+{1,}([0-9]+):exit\ [0-9]+$ ]]; then
      beschritten_pd["${BASH_REMATCH[1]}"]=1
    elif [[ "$zeile_pd" =~ ^\+{1,}([0-9]+):blockieren_mit_zaehlung\  ]]; then
      beschritten_pd["${BASH_REMATCH[1]}"]=1
    fi
  done < "$SPUR_DATEI"
fi

local ausnahmedatei_fehlschlag_pd=0
local -A ausnahme_pd=()
if [ ! -f "$ausnahmedatei_pd" ]; then
  ausnahmedatei_fehlschlag_pd=1
else
  local a_zeile_pd a_wortlaut_pd a_grund_pd a_begruendung_pd tatsaechlich_pd
  while IFS=$'\t' read -r a_zeile_pd a_wortlaut_pd a_grund_pd a_begruendung_pd; do
    [ -n "$a_zeile_pd" ] || continue
    case "$a_zeile_pd" in '#'*) continue ;; esac
    case "$a_grund_pd" in 1|2|3) ;; *) ausnahmedatei_fehlschlag_pd=1; continue ;; esac
    [ -n "$a_begruendung_pd" ] || { ausnahmedatei_fehlschlag_pd=1; continue; }
    tatsaechlich_pd=$(sed -n "${a_zeile_pd}p" "$GATE" 2>/dev/null)
    tatsaechlich_pd="${tatsaechlich_pd#"${tatsaechlich_pd%%[![:space:]]*}"}"
    if [ "$tatsaechlich_pd" != "$a_wortlaut_pd" ]; then
      ausnahmedatei_fehlschlag_pd=1
      continue
    fi
    ausnahme_pd["$a_zeile_pd"]=1
  done < "$ausnahmedatei_pd"
fi

local -a nicht_beschritten_pd=() mit_ausnahme_pd=()
local s_pd
for s_pd in "${soll_pd[@]}"; do
  [ -n "${beschritten_pd[$s_pd]:-}" ] && continue
  if [ -n "${ausnahme_pd[$s_pd]:-}" ]; then
    mit_ausnahme_pd+=("$s_pd")
  else
    nicht_beschritten_pd+=("$s_pd")
  fi
done
local m_pd=${#nicht_beschritten_pd[@]}
local a_pd=${#mit_ausnahme_pd[@]}

# SST-P1-06/S12-01: NICHT mehr direkt ausgeben -- die Zeile geht NUR ueber
# deckungszeile_registrieren ins Feld und wird erst vom Aufrufer im Block
# der Deckungszeilen ausgegeben. Die Meldung von Z-230/Z-231 selbst (unten)
# bleibt an dieser Stelle, VOR der Deckungszaehlung.
deckungszeile_registrieren "Pfaddeckung: $n_pd Ausgangsstellen, $m_pd nicht beschritten, $a_pd mit Ausnahme" >/dev/null
for s_pd in "${nicht_beschritten_pd[@]}"; do
  local wortlaut_pd
  wortlaut_pd=$(sed -n "${s_pd}p" "$GATE" 2>/dev/null)
  wortlaut_pd="${wortlaut_pd#"${wortlaut_pd%%[![:space:]]*}"}"
  deckungszeile_registrieren "Pfaddeckung: nicht beschritten: Zeile $s_pd: $wortlaut_pd" >/dev/null
done

local spurzeilen_pd
spurzeilen_pd=0
if [ -f "$SPUR_DATEI" ]; then
  spurzeilen_pd=$(grep -cE '^\+{1,}[0-9]+:set -uo pipefail$' "$SPUR_DATEI" 2>/dev/null || true)
fi

if [ "$ausnahmedatei_fehlschlag_pd" -eq 1 ]; then
  pruefe_wahr Z-230 "selbsttest" "gleich" "$fallpd" \
    "die Ausgabezeile Pfaddeckung: nennt als Zahl der nicht beschrittenen Ausgangsstellen genau 0" \
    0 "m=0" "Ausnahmedatei fehlt oder ungueltig: $ausnahmedatei_pd"
  pruefe_wahr Z-231 "selbsttest" "gleich" "Dieselbe Ausfuehrungsspur wie Z-230" \
    "die Zahl der Aufrufe, die die Spur ausweist, ist gleich der Zahl der Aufrufe des Aufrufprotokolls des Selbsttests" \
    0 "Spurzeilen=$GATE_AUFRUF_ZAEHLER" "Ausnahmedatei fehlt oder ungueltig: $ausnahmedatei_pd"
  return
fi
if [ "$n_pd" -eq 0 ] || [ -z "$(cat "$SPUR_DATEI" 2>/dev/null)" ]; then
  pruefe_wahr Z-230 "selbsttest" "gleich" "$fallpd" \
    "die Ausgabezeile Pfaddeckung: nennt als Zahl der nicht beschrittenen Ausgangsstellen genau 0" \
    0 "m=0" "Sollmenge leer (n=$n_pd) oder Spur leer"
  pruefe_wahr Z-231 "selbsttest" "gleich" "Dieselbe Ausfuehrungsspur wie Z-230" \
    "die Zahl der Aufrufe, die die Spur ausweist, ist gleich der Zahl der Aufrufe des Aufrufprotokolls des Selbsttests" \
    0 "Spurzeilen=$GATE_AUFRUF_ZAEHLER" "Sollmenge leer (n=$n_pd) oder Spur leer"
  return
fi

local ok230_pd=0; [ "$m_pd" -eq 0 ] && ok230_pd=1
pruefe_wahr Z-230 "selbsttest" "gleich" "$fallpd" \
  "die Ausgabezeile Pfaddeckung: nennt als Zahl der nicht beschrittenen Ausgangsstellen genau 0" \
  "$ok230_pd" "m=0" "m=$m_pd"

local ok231_pd=0; [ "$spurzeilen_pd" -eq "$GATE_AUFRUF_ZAEHLER" ] && ok231_pd=1
pruefe_wahr Z-231 "selbsttest" "gleich" "Dieselbe Ausfuehrungsspur wie Z-230" \
  "die Zahl der Aufrufe, die die Spur ausweist, ist gleich der Zahl der Aufrufe des Aufrufprotokolls des Selbsttests" \
  "$ok231_pd" "Spurzeilen=$GATE_AUFRUF_ZAEHLER" "Spurzeilen=$spurzeilen_pd"
}

# -----------------------------------------------------------------------------
# fall_z230_231 (Mutationsmodus, S10-10-Folge, 6.12.28 b Punkt 8 berichtigte
# Fassung): erkennt am LEEREN Aufrufprotokoll, dass sie isoliert laeuft, und
# fuehrt dann die ganze FALL_REIHENFOLGE (ohne sich selbst) im eigenen
# Prozess gegen die mutierte Kopie aus, bevor sie die Spur auswertet. Im
# Normalmodus wird sie NICHT aufgerufen -- dort laeuft pfaddeckung_pruefen
# direkt aus zusammenfassung_und_deckung_ausgeben.
# -----------------------------------------------------------------------------
fall_z230_231() {
if [ "$GATE_AUFRUF_ZAEHLER" -eq 0 ]; then
  local _fn230
  for _fn230 in "${FALL_REIHENFOLGE[@]}"; do
    "$_fn230"
  done
fi
pfaddeckung_pruefen
}

# =============================================================================
# GRAMMATIK AM GEGENSTAND (ADR 0002, 6.12.28 c, O-27 (a2)): Zerlegung des aus
# dem Gate gelesenen marken_muster in die 16 Elemente, die geschlossene
# Liste U1..U6 mechanisch je Element angewandt, Probemarken aus einem
# Musterexemplar, Wirksamkeit per Bash-Regex (wie das Gate selbst prueft),
# fallende Zusicherung am Gate ueber isolierte Kindlaeufe der bestehenden
# Grammatik-Fallfunktionen. Alle fuenf Bausteine sind vor dem Einbau ausser-
# halb des Repositories gegen das reale marken_muster verifiziert: 16
# Elemente (Rekonstruktion exakt), 35 Schwaechungen vor und nach der Ent-
# dopplung (U1=2, U2=6, U3=18, U4=6, U5=2, U6=1), Musterexemplar woertlich
# "::LAGE x x x A_OK FEHLT=x SCHWELLE=x:: (rueckgabewert=0)", 211 Probemarken,
# 33 von 35 Schwaechungen wirksam.
# =============================================================================

# -----------------------------------------------------------------------------
# _marken_muster_zerlegen <muster> -- Tokenizer fuer genau diesen Musterdialekt
# (6.12.28 c Punkt 1/2): ^ am Anfang und $ am Ende sind Anker; eine unescapte
# "(" beginnt eine Gruppe (mit "?" danach eine optionale), Tiefe gezaehlt bis
# zur schliessenden ")"; "\(" und "\)" sind je EIN logisches Literalzeichen
# (nicht Gruppengrenzen); alles Uebrige ist Literal, benachbarte Literal-
# zeichen bilden EINEN Lauf, der an jeder Anker-/Gruppen-/Escape-Grenze endet.
# Setzt die globalen Arrays ZL_TYP/ZL_TEXT/ZL_START/ZL_ORIGLEN (0-indiziert,
# Element Nr. i steht an Index i-1). Weicht die Zahl der Elemente von 16 ab,
# ist das ein Befund am ADR (6.12.28 c Punkt 1) -- der Aufrufer meldet das.
# -----------------------------------------------------------------------------
_marken_muster_zerlegen() {
  local m="$1"
  ZL_TYP=(); ZL_TEXT=(); ZL_START=(); ZL_ORIGLEN=()
  local n=${#m}
  local i=0
  local buf="" buf_start=-1
  while [ "$i" -lt "$n" ]; do
    local c="${m:$i:1}"
    if [ "$i" -eq 0 ] && [ "$c" = "^" ]; then
      if [ -n "$buf" ]; then ZL_TYP+=("Literal"); ZL_TEXT+=("$buf"); ZL_START+=("$buf_start"); ZL_ORIGLEN+=("${#buf}"); buf=""; fi
      ZL_TYP+=("Anker"); ZL_TEXT+=("^"); ZL_START+=("$i"); ZL_ORIGLEN+=(1)
      i=$((i+1)); continue
    fi
    if [ "$c" = '$' ] && [ "$((i+1))" -eq "$n" ]; then
      if [ -n "$buf" ]; then ZL_TYP+=("Literal"); ZL_TEXT+=("$buf"); ZL_START+=("$buf_start"); ZL_ORIGLEN+=("${#buf}"); buf=""; fi
      ZL_TYP+=("Anker"); ZL_TEXT+=('$'); ZL_START+=("$i"); ZL_ORIGLEN+=(1)
      i=$((i+1)); continue
    fi
    if [ "$c" = "\\" ] && [ "$((i+1))" -lt "$n" ]; then
      local c2="${m:$((i+1)):1}"
      if [ "$c2" = "(" ] || [ "$c2" = ")" ]; then
        if [ -n "$buf" ]; then ZL_TYP+=("Literal"); ZL_TEXT+=("$buf"); ZL_START+=("$buf_start"); ZL_ORIGLEN+=("${#buf}"); buf=""; fi
        buf="$c$c2"; buf_start=$i
        i=$((i+2)); continue
      fi
    fi
    if [ "$c" = "(" ]; then
      if [ -n "$buf" ]; then ZL_TYP+=("Literal"); ZL_TEXT+=("$buf"); ZL_START+=("$buf_start"); ZL_ORIGLEN+=("${#buf}"); buf=""; fi
      local depth=1
      local j=$((i+1))
      while [ "$j" -lt "$n" ] && [ "$depth" -gt 0 ]; do
        local cj="${m:$j:1}"
        if [ "$cj" = "\\" ] && [ "$((j+1))" -lt "$n" ]; then j=$((j+2)); continue; fi
        if [ "$cj" = "(" ]; then depth=$((depth+1)); fi
        if [ "$cj" = ")" ]; then depth=$((depth-1)); fi
        j=$((j+1))
      done
      local optional=0
      local jend=$j
      if [ "$jend" -lt "$n" ] && [ "${m:$jend:1}" = "?" ]; then optional=1; jend=$((jend+1)); fi
      local grouplen=$((jend - i))
      local grouptext="${m:$i:$grouplen}"
      if [ "$optional" -eq 1 ]; then ZL_TYP+=("Gruppe-optional"); else ZL_TYP+=("Gruppe"); fi
      ZL_TEXT+=("$grouptext"); ZL_START+=("$i"); ZL_ORIGLEN+=("$grouplen")
      i=$jend
      continue
    fi
    if [ -z "$buf" ]; then buf_start=$i; fi
    buf+="$c"
    i=$((i+1))
  done
  if [ -n "$buf" ]; then ZL_TYP+=("Literal"); ZL_TEXT+=("$buf"); ZL_START+=("$buf_start"); ZL_ORIGLEN+=("${#buf}"); fi
}

# _element_ersetzen <muster> <elementindex 1-basiert> <neuertext> -- spleisst
# neuertext an der Original-Position von Element idx (aus ZL_START/ZL_ORIGLEN
# der letzten _marken_muster_zerlegen) und gibt das neue Muster aus.
_element_ersetzen() {
  local m="$1" idx="$2" neu="$3"
  local off="${ZL_START[$((idx-1))]}"
  local orig_len="${ZL_ORIGLEN[$((idx-1))]}"
  printf '%s%s%s' "${m:0:$off}" "$neu" "${m:$((off+orig_len))}"
}

# -----------------------------------------------------------------------------
# _schwaechungen_erzeugen <muster> -- wendet U1..U6 (6.12.28 c Punkt 3) je
# Element mechanisch an. Setzt SCHW_LABEL/SCHW_MUSTER/SCHW_ELEMENT (0-
# indiziert) und SCHW_VORFILTER (die fuer Element 1/2 zusaetzlich am
# awk-Vorfilter "^::LAGE " noetige Fassung -- fuer alle anderen Elemente
# unveraendert "^::LAGE ", 6.12.28 c Punkt 7). Zeichengleiche Schwaechungen
# (volles resultierendes Muster identisch) zaehlen einmal (globaler Dedup).
# ROH_ANZAHL zaehlt vor der Entdopplung (erwartet 35, nicht verdrahtet).
# -----------------------------------------------------------------------------
_schwaechungen_erzeugen() {
  local m="$1"
  SCHW_LABEL=(); SCHW_MUSTER=(); SCHW_ELEMENT=(); SCHW_VORFILTER=()
  local -A gesehen=()
  ROH_ANZAHL=0
  local idx
  _sz_add() {
    local label="$1" text="$2"
    ROH_ANZAHL=$((ROH_ANZAHL+1))
    local neues_muster
    neues_muster=$(_element_ersetzen "$m" "$idx" "$text")
    [ -n "${gesehen[$neues_muster]:-}" ] && return
    gesehen["$neues_muster"]=1
    SCHW_LABEL+=("$label")
    SCHW_MUSTER+=("$neues_muster")
    SCHW_ELEMENT+=("$idx")
    if [ "$idx" -le 2 ]; then
      SCHW_VORFILTER+=("$(_element_ersetzen "^::LAGE " "$idx" "$text")")
    else
      SCHW_VORFILTER+=("^::LAGE ")
    fi
  }
  for idx in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16; do
    local typ="${ZL_TYP[$((idx-1))]}" text="${ZL_TEXT[$((idx-1))]}"
    case "$typ" in
      Anker)
        _sz_add "U1 Anker entfernt (Element $idx)" ""
        if [ "$idx" -eq 16 ]; then
          _sz_add "U6 Leerraum vor Endanker (Element $idx)" ' *$'
        fi
        ;;
      Literal)
        local -a logchars=() logstarts=()
        local li=0 llen=${#text}
        while [ "$li" -lt "$llen" ]; do
          local lc="${text:$li:1}"
          if [ "$lc" = "\\" ] && [ "$((li+1))" -lt "$llen" ]; then
            local lc2="${text:$((li+1)):1}"
            if [ "$lc2" = "(" ] || [ "$lc2" = ")" ]; then
              logchars+=("$lc$lc2"); logstarts+=("$li"); li=$((li+2)); continue
            fi
          fi
          logchars+=("$lc"); logstarts+=("$li"); li=$((li+1))
        done
        local lcount=${#logchars[@]}
        if [ "$lcount" -eq 1 ]; then
          _sz_add "U3 Literal optional, einzeichig (Element $idx)" "${text}?"
        else
          local erstes="${logchars[0]}"
          local rest_ab_1="${text:${#erstes}}"
          local letztes="${logchars[$((lcount-1))]}"
          local vor_letztem="${text:0:${logstarts[$((lcount-1))]}}"
          _sz_add "U3(i) ganzes Literal optional (Element $idx)" "(${text})?"
          _sz_add "U3(ii) erstes Zeichen optional (Element $idx)" "${erstes}?${rest_ab_1}"
          _sz_add "U3(iii) letztes Zeichen optional (Element $idx)" "${vor_letztem}${letztes}?"
        fi
        ;;
      Gruppe)
        _sz_add "U3(i) Gruppe optional (Element $idx)" "${text}?"
        if [[ "$text" == *'+'* ]]; then
          _sz_add "U2 Quantor + zu * (Element $idx)" "${text//+/\*}"
        fi
        if [[ "$text" == *'[^ :]'* ]]; then
          _sz_add "U4 Zeichenklasse [^ :] zu [^ ] (Element $idx)" "${text//\[^ :\]/[^ ]}"
        elif [[ "$text" == *'[^ ]'* ]]; then
          _sz_add "U4 Zeichenklasse [^ ] zu . (Element $idx)" "${text//\[^ \]/.}"
        elif [[ "$text" == *'[0-9]'* ]]; then
          _sz_add "U4 Zeichenklasse [0-9] zu . (Element $idx)" "${text//\[0-9\]/.}"
        fi
        if [ "$idx" -eq 9 ]; then
          _sz_add "U5 Alternative erweitert (Element $idx)" "${text%)}|[^ ]+)"
        fi
        ;;
      Gruppe-optional)
        if [[ "$text" == *'+'* ]]; then
          _sz_add "U2 Quantor + zu * (Element $idx)" "${text//+/\*}"
        fi
        if [[ "$text" == *'[^ :]'* ]]; then
          _sz_add "U4 Zeichenklasse [^ :] zu [^ ] (Element $idx)" "${text//\[^ :\]/[^ ]}"
        elif [[ "$text" == *'[^ ]'* ]]; then
          _sz_add "U4 Zeichenklasse [^ ] zu . (Element $idx)" "${text//\[^ \]/.}"
        elif [[ "$text" == *'[0-9]'* ]]; then
          _sz_add "U4 Zeichenklasse [0-9] zu . (Element $idx)" "${text//\[0-9\]/.}"
        fi
        if [ "$idx" -eq 11 ]; then
          _sz_add "U5 Alternative erweitert (Element $idx)" "${text%))?}|[^ ]+))?"
        fi
        ;;
    esac
  done
}

# -----------------------------------------------------------------------------
# _musterexemplar_bauen -- realisiert die 16 Elemente zu EINER Zeichenkette
# (6.12.28 c Punkt 4 Nr. 1): je Zeichenklasse ein zulaessiges Zeichen ("x"
# bzw. "0" bei [0-9]), je Alternativengruppe die erste Alternative, alle
# optionalen Gruppen enthalten. Setzt MX_TEXT sowie MX_START/MX_LEN (Position
# und Laenge der Realisierung JEDES Elements innerhalb MX_TEXT, fuer die
# Feld-Loeschungen unten).
# -----------------------------------------------------------------------------
_musterexemplar_bauen() {
  MX_TEXT=""
  MX_START=(); MX_LEN=()
  local idx
  for idx in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16; do
    local typ="${ZL_TYP[$((idx-1))]}" text="${ZL_TEXT[$((idx-1))]}"
    local stueck=""
    case "$typ" in
      Anker) stueck="" ;;
      Literal)
        stueck="${text//\\(/(}"; stueck="${stueck//\\)/)}"
        ;;
      Gruppe)
        case "$idx" in
          9) stueck="A_OK" ;;
          14) stueck="0" ;;
          *) stueck="x" ;;
        esac
        ;;
      Gruppe-optional)
        case "$idx" in
          10) stueck=" FEHLT=x" ;;
          11) stueck=" SCHWELLE=x" ;;
        esac
        ;;
    esac
    MX_START+=("${#MX_TEXT}")
    MX_LEN+=("${#stueck}")
    MX_TEXT+="$stueck"
  done
}

# -----------------------------------------------------------------------------
# _probemarken_erzeugen -- alle Einzelaenderungen aus dem Musterexemplar
# (6.12.28 c Punkt 4 Nr. 2): je ein Zeichen geloescht, je ein Leerzeichen
# eingefuegt, je ein Buchstabe eingefuegt, je ein Zeichen verdoppelt, dazu
# neun "ganzes Feld geloescht"-Marken (die drei Feldwerte 3/5/7 -- NUR der
# Wert, ohne das umgebende Trennzeichen; die beiden Zusaetze 10/11 -- die
# GANZE realisierte Spanne EINSCHLIESSLICH des fuehrenden Leerzeichens, weil
# dieses zur selben optionalen Gruppe gehoert; die Literale 2, 12, 13, 15).
# Setzt PROBEMARKEN, dedupliziert nach Zeicheninhalt.
# -----------------------------------------------------------------------------
_probemarken_erzeugen() {
  PROBEMARKEN=()
  local -A gesehen=()
  local ex="$MX_TEXT"
  local n=${#ex}
  local i
  for ((i=0; i<n; i++)); do
    local mark="${ex:0:$i}${ex:$((i+1))}"
    [ -z "${gesehen[$mark]:-}" ] && { gesehen["$mark"]=1; PROBEMARKEN+=("$mark"); }
  done
  for ((i=0; i<=n; i++)); do
    local mark="${ex:0:$i} ${ex:$i}"
    [ -z "${gesehen[$mark]:-}" ] && { gesehen["$mark"]=1; PROBEMARKEN+=("$mark"); }
  done
  for ((i=0; i<=n; i++)); do
    local mark="${ex:0:$i}q${ex:$i}"
    [ -z "${gesehen[$mark]:-}" ] && { gesehen["$mark"]=1; PROBEMARKEN+=("$mark"); }
  done
  for ((i=0; i<n; i++)); do
    local ch="${ex:$i:1}"
    local mark="${ex:0:$i}$ch$ch${ex:$((i+1))}"
    [ -z "${gesehen[$mark]:-}" ] && { gesehen["$mark"]=1; PROBEMARKEN+=("$mark"); }
  done
  local feldidx
  for feldidx in 3 5 7 10 11 2 12 13 15; do
    local st="${MX_START[$((feldidx-1))]}" ln="${MX_LEN[$((feldidx-1))]}"
    local mark="${ex:0:$st}${ex:$((st+ln))}"
    [ -z "${gesehen[$mark]:-}" ] && { gesehen["$mark"]=1; PROBEMARKEN+=("$mark"); }
  done

  # Nachtrag c Punkt 4, Regel 4 (O-27 Phase 3): Feldloeschung zusaetzlich als
  # Loeschung ALLEIN des realisierten WERTS (Trennzeichen/Literalpraefix wie
  # "FEHLT=" bleiben stehen), fuer die Elemente 3, 5, 7, 9, 10, 11, 14 --
  # zusaetzlich zur bestehenden Loeschung der ganzen Spanne bei 10 und 11
  # oben. Der Wertanfang wird mechanisch als Stelle NACH dem letzten "="
  # innerhalb der Elementspanne bestimmt; traegt das Element kein "=", ist
  # der Wert die ganze Spanne (deckungsgleich mit der bestehenden Regel,
  # ueber "gesehen" dedupliziert).
  for feldidx in 3 5 7 9 10 11 14; do
    local st="${MX_START[$((feldidx-1))]}" ln="${MX_LEN[$((feldidx-1))]}"
    local spanwert="${ex:$st:$ln}"
    local eqpos=-1 ci
    for ((ci=ln-1; ci>=0; ci--)); do
      if [ "${spanwert:$ci:1}" = "=" ]; then eqpos=$ci; break; fi
    done
    local wertstart=$st
    [ "$eqpos" -ge 0 ] && wertstart=$((st+eqpos+1))
    local mark="${ex:0:$wertstart}${ex:$((st+ln))}"
    [ -z "${gesehen[$mark]:-}" ] && { gesehen["$mark"]=1; PROBEMARKEN+=("$mark"); }
  done

  # Nachtrag c Punkt 4, Regel 3 (O-27 Phase 3): je Position wird zusaetzlich
  # EIN Zeichen aus der Menge der von negierten Zeichenklassen ("[^...]")
  # AUSGESCHLOSSENEN Zeichen eingefuegt -- mechanisch aus dem rohen Muster im
  # Gate gelesen, heute Leerzeichen und Doppelpunkt (Klassen "[^ ]"/"[^ :]").
  local roh_muster_pm
  roh_muster_pm=$(sed -n "s/^marken_muster='\(.*\)'\$/\1/p" "$GATE")
  local -a ausgeschlossen_pm=()
  local -A ausgeschlossen_gesehen_pm=()
  local klasse_pm zeichenliste_pm zi_pm zeichen_pm
  while IFS= read -r klasse_pm; do
    [ -n "$klasse_pm" ] || continue
    zeichenliste_pm="${klasse_pm#\[^}"
    zeichenliste_pm="${zeichenliste_pm%]}"
    for ((zi_pm=0; zi_pm<${#zeichenliste_pm}; zi_pm++)); do
      zeichen_pm="${zeichenliste_pm:$zi_pm:1}"
      [ -n "${ausgeschlossen_gesehen_pm[$zeichen_pm]:-}" ] && continue
      ausgeschlossen_gesehen_pm["$zeichen_pm"]=1
      ausgeschlossen_pm+=("$zeichen_pm")
    done
  done < <(printf '%s' "$roh_muster_pm" | grep -oE '\[\^[^]]*\]')
  local zch_pm
  for zch_pm in "${ausgeschlossen_pm[@]}"; do
    for ((i=0; i<=n; i++)); do
      local mark="${ex:0:$i}${zch_pm}${ex:$i}"
      [ -z "${gesehen[$mark]:-}" ] && { gesehen["$mark"]=1; PROBEMARKEN+=("$mark"); }
    done
  done
}

# _schwaechung_wirksam <original> <geschwaecht> -- 6.12.28 c Punkt 5: wirksam,
# wenn MINDESTENS EINE Probemarke die Schwaechung annimmt und das
# unveraenderte Muster ablehnt. Bash-Regex (=~), wie das Gate selbst prueft.
_schwaechung_wirksam() {
  local orig="$1" schw="$2"
  local mark
  for mark in "${PROBEMARKEN[@]}"; do
    if [[ "$mark" =~ $schw ]] && ! [[ "$mark" =~ $orig ]]; then
      return 0
    fi
  done
  return 1
}

# -----------------------------------------------------------------------------
# _schwaechung_kopie_bauen <neu_muster> <element_idx> <neu_vorfilter> <ziel>
# -- schreibt eine Gate-Kopie, in der die marken_muster-Zeile ersetzt ist;
# betrifft die Schwaechung Element 1 oder 2, wird zusaetzlich der
# awk-Vorfilter "/^::LAGE /" (Gate, Uebersichtszeilen-Filter) auf dieselbe
# Weise geschwaecht (6.12.28 c Punkt 7). Reine Bash-String-Operationen ueber
# mapfile -- kein sed/awk-Escaping des Musters noetig.
# -----------------------------------------------------------------------------
_schwaechung_kopie_bauen() {
  local neu_muster="$1" elidx="$2" neu_vorfilter="$3" ziel="$4"
  local -a zeilen
  mapfile -t zeilen < "$GATE"
  local i
  for i in "${!zeilen[@]}"; do
    case "${zeilen[$i]}" in
      marken_muster=*)
        zeilen[$i]="marken_muster='${neu_muster}'"
        ;;
    esac
    if [ "$elidx" -le 2 ]; then
      case "${zeilen[$i]}" in
        *'/^::LAGE /'*)
          zeilen[$i]="${zeilen[$i]//\/^::LAGE \//\/${neu_vorfilter}\/}"
          ;;
      esac
    fi
  done
  printf '%s\n' "${zeilen[@]}" > "$ziel"
}

# -----------------------------------------------------------------------------
# _grammatik_fallfunktionen_liste -- mechanisch bestimmt (6.12.28 c Punkt 5):
# alle Kennungen der Tabelle 6.12.19, deren Fallspalte mit "Grammatik "
# beginnt, in Tabellenreihenfolge, ueber FALL_ZU_KENNUNG auf Fallfunktionen
# abgebildet, jede Funktion EINMAL (dedupliziert). Kennungen ohne Eintrag in
# FALL_ZU_KENNUNG (noch nicht gebaut) werden uebergangen -- das ist genau der
# Zustand des ERSTEN Laufs (c Punkt 10), der nur die heute bestehenden
# Grammatik-Fallfunktionen kennt. Setzt GRAMMATIK_FUNKTIONEN.
# -----------------------------------------------------------------------------
_grammatik_fallfunktionen_liste() {
  GRAMMATIK_FUNKTIONEN=()
  local adr_pfad="$REPO_WURZEL/docs/adr/0002-architekturentscheid-ziel-stack.md"
  local -A gesehen=()
  local zeile kennung zeile_maskiert fall_zelle fn
  while IFS= read -r zeile; do
    kennung=$(printf '%s' "$zeile" | sed -n 's/^| \(Z-[0-9][0-9]*\).*/\1/p')
    [ -n "$kennung" ] || continue
    zeile_maskiert=$(printf '%s' "$zeile" | sed 's/\\|/\x01/g')
    fall_zelle=$(printf '%s' "$zeile_maskiert" | awk -F'|' '{print $3}' | sed -e 's/^ *//' -e 's/ *$//')
    case "$fall_zelle" in
      "Grammatik "*)
        fn="${FALL_ZU_KENNUNG[$kennung]:-}"
        [ -n "$fn" ] || continue
        [ -n "${gesehen[$fn]:-}" ] && continue
        gesehen["$fn"]=1
        GRAMMATIK_FUNKTIONEN+=("$fn")
        ;;
    esac
  done < <(grep '^| Z-' "$adr_pfad")
}

# -----------------------------------------------------------------------------
# fall_z252_255 (6.12.28 c Punkt 6, O-27 (a2)): erzeugt die Schwaechungen des
# aus dem Gate gelesenen marken_muster SELBST und ruft die
# Grammatik-Fallfunktionen selbst auf -- braucht FALL_REIHENFOLGE NICHT
# (anders als fall_z230_231), laeuft deshalb unveraendert im Normalmodus wie
# im isolierten Mutationslauf. Je wirksamer Schwaechung eine Gate-Kopie,
# isoliert (eigener Vorspann-Kindprozess, wie der Mutationsmodus) gegen die
# mechanisch bestimmten Grammatik-Fallfunktionen geprueft, Abbruch der Folge
# bei der ERSTEN Kennung, die FEHLGESCHLAGEN meldet (gedeckt = Existenz, nicht
# Zahl). Diese Kindlaeufe gehen weder in die Spur der Pfaddeckung noch in die
# Invarianten Z-194..Z-197 ein (eigenes Protokoll im Kindprozess).
# -----------------------------------------------------------------------------
fall_z252_255() {
local muster252
muster252=$(sed -n "s/^marken_muster='\(.*\)'\$/\1/p" "$GATE")
local fall252="Schwaechungslauf: alle mechanisch erzeugten Schwaechungen des aus dem Gate gelesenen marken_muster, je gegen die Grammatik-Fallfunktionen an einer geschwaechten Gate-Kopie"

if [ -z "$muster252" ]; then
  deckungszeile_registrieren "Grammatikschwaechungen: marken_muster leer -- Schwaechungslauf abgebrochen" >/dev/null
  pruefe_wahr Z-252 "selbsttest" "gleich" "$fall252" \
    "die Ausgabezeile Grammatikschwaechungen: nennt als Zahl der wirksamen Schwaechungen ohne fallende Zusicherung genau 0" \
    0 "m=0" "marken_muster leer"
  pruefe_wahr Z-255 "selbsttest" "fehlt" "Schwaechungslauf wie Z-252" \
    "die Ausgabe des Selbsttests fuehrt keine Zeile Grammatikschwaechungen:, die als Zahl der wirksamen Schwaechungen 0 nennt" \
    0 "keine Zeile mit w=0" "marken_muster leer"
  return
fi

_marken_muster_zerlegen "$muster252"
if [ "${#ZL_TYP[@]}" -ne 16 ]; then
  deckungszeile_registrieren "Grammatikschwaechungen: ${#ZL_TYP[@]} statt 16 Elemente -- Befund am ADR (6.12.28 c Punkt 1), Schwaechungslauf abgebrochen" >/dev/null
  pruefe_wahr Z-252 "selbsttest" "gleich" "$fall252" \
    "die Ausgabezeile Grammatikschwaechungen: nennt als Zahl der wirksamen Schwaechungen ohne fallende Zusicherung genau 0" \
    0 "m=0" "Zerlegung liefert ${#ZL_TYP[@]} statt 16 Elemente"
  pruefe_wahr Z-255 "selbsttest" "fehlt" "Schwaechungslauf wie Z-252" \
    "die Ausgabe des Selbsttests fuehrt keine Zeile Grammatikschwaechungen:, die als Zahl der wirksamen Schwaechungen 0 nennt" \
    0 "keine Zeile mit w=0" "Zerlegung liefert ${#ZL_TYP[@]} statt 16 Elemente"
  return
fi

_schwaechungen_erzeugen "$muster252"
_musterexemplar_bauen
_probemarken_erzeugen
if [ "${#PROBEMARKEN[@]}" -eq 0 ]; then
  deckungszeile_registrieren "Grammatikschwaechungen: 0 Probemarken -- Schwaechungslauf abgebrochen" >/dev/null
  pruefe_wahr Z-252 "selbsttest" "gleich" "$fall252" \
    "die Ausgabezeile Grammatikschwaechungen: nennt als Zahl der wirksamen Schwaechungen ohne fallende Zusicherung genau 0" \
    0 "m=0" "Probemarkenmenge leer"
  pruefe_wahr Z-255 "selbsttest" "fehlt" "Schwaechungslauf wie Z-252" \
    "die Ausgabe des Selbsttests fuehrt keine Zeile Grammatikschwaechungen:, die als Zahl der wirksamen Schwaechungen 0 nennt" \
    0 "keine Zeile mit w=0" "Probemarkenmenge leer"
  return
fi
_grammatik_fallfunktionen_liste

local prefix_start252 prefix_end252 selbsttest_pfad252
selbsttest_pfad252="$REPO_WURZEL/scripts/dod-gate-selbsttest.sh"
prefix_start252=$(grep -n '^# ::VORSPANN-START::$' "$selbsttest_pfad252" | head -1 | cut -d: -f1)
prefix_end252=$(grep -n '^# ::VORSPANN-ENDE::$' "$selbsttest_pfad252" | head -1 | cut -d: -f1)
local vorspann_datei252
vorspann_datei252=$(mktemp)
{
  echo '#!/usr/bin/env bash'
  echo 'set -uo pipefail'
  if [ -n "${SELBSTTEST_SPERRE_FD:-}" ]; then
    printf 'exec %s>&- 2>/dev/null || true\n' "$SELBSTTEST_SPERRE_FD"
  fi
  printf 'REPO_WURZEL=%q\n' "$REPO_WURZEL"
  sed -n "$((prefix_start252 + 1)),$((prefix_end252 - 1))p" "$selbsttest_pfad252"
} > "$vorspann_datei252"

local n252=${#SCHW_LABEL[@]}
local w252=0
local -a ohne252=()
local start_zeit252 ende_zeit252
start_zeit252=$(date +%s)
local idx252
for idx252 in "${!SCHW_LABEL[@]}"; do
  _schwaechung_wirksam "$muster252" "${SCHW_MUSTER[$idx252]}" || continue
  w252=$((w252+1))
  local kopie_verz252 kopie_pfad252
  kopie_verz252=$(mktemp -d)
  kopie_pfad252="$kopie_verz252/dod-gate.sh"
  _schwaechung_kopie_bauen "${SCHW_MUSTER[$idx252]}" "${SCHW_ELEMENT[$idx252]}" "${SCHW_VORFILTER[$idx252]}" "$kopie_pfad252"
  local gedeckt252=0 fn252
  for fn252 in "${GRAMMATIK_FUNKTIONEN[@]}"; do
    local falllauf252 ausgabe252
    falllauf252="$kopie_verz252/fall.sh"
    ausgabe252="$kopie_verz252/ausgabe.log"
    cat "$vorspann_datei252" > "$falllauf252"
    printf '%s\n' "$fn252" >> "$falllauf252"
    (
      if [ -n "${SELBSTTEST_SPERRE_FD:-}" ]; then
        exec {SELBSTTEST_SPERRE_FD}>&- 2>/dev/null || true
      fi
      exec env -i PATH="$PATH" HOME="${HOME:-/root}" GATE_UEBERSCHREIBUNG="$kopie_pfad252" \
        timeout 30 "$BASH_BIN" "$falllauf252"
    ) > "$ausgabe252" 2>&1
    if grep -qE '^FEHLGESCHLAGEN Z-' "$ausgabe252"; then
      gedeckt252=1
      break
    fi
  done
  rm -rf "$kopie_verz252"
  if [ "$gedeckt252" -eq 0 ]; then
    ohne252+=("${SCHW_LABEL[$idx252]} | ${SCHW_MUSTER[$idx252]}")
  fi
done
ende_zeit252=$(date +%s)
rm -f "$vorspann_datei252"

local m252=${#ohne252[@]}
deckungszeile_registrieren "Grammatikschwaechungen: $n252 Schwaechungen, $w252 wirksam, $m252 ohne fallende Zusicherung (Dauer $((ende_zeit252 - start_zeit252))s)" >/dev/null
local z252
for z252 in "${ohne252[@]}"; do
  echo "Grammatikschwaechungen: ohne fallende Zusicherung: $z252"
done

local ok252=0; [ "$m252" -eq 0 ] && ok252=1
pruefe_wahr Z-252 "selbsttest" "gleich" "$fall252" \
  "die Ausgabezeile Grammatikschwaechungen: nennt als Zahl der wirksamen Schwaechungen ohne fallende Zusicherung genau 0" \
  "$ok252" "m=0" "m=$m252"

local ok255=0; [ "$w252" -gt 0 ] && ok255=1
pruefe_wahr Z-255 "selbsttest" "fehlt" "Schwaechungslauf wie Z-252" \
  "die Ausgabe des Selbsttests fuehrt keine Zeile Grammatikschwaechungen:, die als Zahl der wirksamen Schwaechungen 0 nennt" \
  "$ok255" "keine Zeile mit w=0" "w=$w252"
}

# -----------------------------------------------------------------------------
# fall_z256/fall_z257 (6.12.28 d, Runde 11 DT11-06, O-27 Phase 3): Aussage E21
# ("gezaehlt wird die erste Abweichung, genannt werden ALLE") an den beiden
# UEBRIGEN Aufrufstellen von weitere_abweichungen_ausgeben im Gate -- der
# "drittes Mal"-Zweig (Z-256) und der "viertes Mal ohne Uebergabedatei"-Zweig
# (Z-257). Die dritte Aufrufstelle (Regelfall, 1./2. Mal) ist bereits durch
# Z-050/Z-051/Z-053 gedeckt (fall_z049_053). ABSICHTLICH zwei getrennte
# Fallfunktionen statt einer gemeinsamen: Z-258 vergleicht die Zahl der
# Aufrufstellen (3, statisch aus dem Gate) mit der Zahl der VERSCHIEDENEN
# Fallfunktionen, deren ADR-Fallspalte "Aussage E21: " traegt -- nur mit drei
# getrennten Funktionen (fall_z049_053, fall_z256, fall_z257) ist diese Zahl
# selbst wirklich 3 (6.2.2, keine geschoente Zaehlung).
#
# Zaehlerdatei WIRD VORAB geschrieben (Schluessel + Stand), statt drei/vier
# echte Gate-Aufrufe hintereinander laufen zu lassen (Vorbild fall_z038_048
# fuer die Mechanik, hier abgekuerzt): der Schluessel ist die ERSTE Abweichung
# in Kettenreihenfolge -- hier die A_FAIL-Marke, die als ERSTE Zeile der
# Uebersicht steht ("D3 linter A_FAIL"), VOR den beiden ungedeckten Lagen C.
# Ausgabe im Uebrigen wie fall_z049_053 (A_FAIL, zwei ungedeckte Lagen C,
# D19 VERLETZT), nur die Reihenfolge der Marken ist getauscht.
# -----------------------------------------------------------------------------
fall_z256() {
local baum256 m1_256 m2_256 m3_256 ausgabe256 zustand256 zaehlerdatei256
baum256=$(neuer_mock_baum)
m1_256=$(marken_zeile K1 D3 linter A_FAIL "" "" 2)
m2_256=$(marken_zeile K1 D7 abnahme C scripts/abnahme-abgleich.sh "" 2)
m3_256=$(marken_zeile K1 D10 prototyp-trennung C scripts/prototyp-trennung-pruefen.sh "" 2)
ausgabe256=$(bauen_ausgabe "$baum256" "$m1_256
$m2_256
$m3_256" "VERLETZT -- versionierter Bestand veraendert." "make dod: abgebrochen bei D3 linter, Rueckgabewert 2.")
zustand256=$(neu_verzeichnis)
zaehlerdatei256=$(zaehler_pfad "$zustand256" "fall-z256")
mkdir -p "$(dirname "$zaehlerdatei256")"
printf '%s\n2\n' "D3 linter A_FAIL" > "$zaehlerdatei256"
lauf_mit_zustand "$zustand256" "$baum256" Stop "fall-z256" "$ausgabe256" 2
pruefe_stderr_enthaelt Z-256 "Aussage E21: dritter Block in derselben Sitzung, Kettenausgabe mit A_FAIL, zwei ungedeckten Lagen C und D19 VERLETZT" \
  "die Blockmeldung des dritten Blocks nennt neben der gezaehlten ersten Abweichung auch die zweite ungedeckte Lage C" \
  "weitere Abweichung: Schritt D10 prototyp-trennung meldet Lage C mit FEHLT=scripts/prototyp-trennung-pruefen.sh"
}

fall_z257() {
local baum257 m1_257 m2_257 m3_257 ausgabe257 zustand257 zaehlerdatei257
baum257=$(neuer_mock_baum)
m1_257=$(marken_zeile K1 D3 linter A_FAIL "" "" 2)
m2_257=$(marken_zeile K1 D7 abnahme C scripts/abnahme-abgleich.sh "" 2)
m3_257=$(marken_zeile K1 D10 prototyp-trennung C scripts/prototyp-trennung-pruefen.sh "" 2)
ausgabe257=$(bauen_ausgabe "$baum257" "$m1_257
$m2_257
$m3_257" "VERLETZT -- versionierter Bestand veraendert." "make dod: abgebrochen bei D3 linter, Rueckgabewert 2.")
zustand257=$(neu_verzeichnis)
zaehlerdatei257=$(zaehler_pfad "$zustand257" "fall-z257")
mkdir -p "$(dirname "$zaehlerdatei257")"
printf '%s\n3\n' "D3 linter A_FAIL" > "$zaehlerdatei257"
# Frischer Mock-Baum ohne docs/uebergaben/ -- handoff_gefunden bleibt 0, das
# Gate faellt auf den Block OHNE Durchlass zurueck (viertes Mal, Zeile
# 315..330 im Gate).
lauf_mit_zustand "$zustand257" "$baum257" Stop "fall-z257" "$ausgabe257" 2
pruefe_stderr_enthaelt Z-257 "Aussage E21: vierter Block ohne passende Uebergabedatei, Kettenausgabe mit A_FAIL, zwei ungedeckten Lagen C und D19 VERLETZT" \
  "die Blockmeldung des vierten Blocks nennt neben der gezaehlten ersten Abweichung auch die zweite ungedeckte Lage C" \
  "weitere Abweichung: Schritt D10 prototyp-trennung meldet Lage C mit FEHLT=scripts/prototyp-trennung-pruefen.sh"
}

# -----------------------------------------------------------------------------
# fall_z258 (6.12.28 d, Aufrufstellendeckung zu E21): statische Lesung von
# .claude/hooks/dod-gate.sh (Zahl der Aufrufstellen von
# weitere_abweichungen_ausgeben, Definitionszeile ausgenommen) gegen die Zahl
# der VERSCHIEDENEN Fallfunktionen dieses Selbsttests, deren ADR-Fallspalte
# (FALL_TABELLE, via tabelle_lesen) mit "Aussage E21: " beginnt -- ueber
# FALL_ZU_KENNUNG auf Fallfunktionsnamen abgebildet, jede Funktion einmal.
# -----------------------------------------------------------------------------
fall_z258() {
local adr_pfad258 k258 fallname258 anzahl_funktionen258
adr_pfad258="$REPO_WURZEL/docs/adr/0002-architekturentscheid-ziel-stack.md"
tabelle_lesen "$adr_pfad258"

# S12-05: Erhebungsmuster wie bei den Aufrufstellen der Pfaddeckung
# (pfaddeckung_pruefen oben) -- Kommentarzeilen ausgeschlossen (Zeile ganz
# oder der Teil hinter "#"), die Definitionszeile
# "weitere_abweichungen_ausgeben() {" ausgeschlossen. Ein blosses
# "grep -c" ohne diese Regeln zaehlte auch Kommentare, die den Namen nur
# ERWAEHNEN, als Aufrufstelle mit -- das war der vorige Fehler.
local -a aufrufstellen_treffer258=()
local treffer258 nr258 rest258 getrimmt258 vor_hash258
while IFS= read -r treffer258; do
  [ -n "$treffer258" ] || continue
  nr258="${treffer258%%:*}"
  rest258="${treffer258#*:}"
  getrimmt258="${rest258#"${rest258%%[![:space:]]*}"}"
  case "$getrimmt258" in '#'*) continue ;; esac
  case "$rest258" in *'weitere_abweichungen_ausgeben()'*) continue ;; esac
  vor_hash258="${rest258%%#*}"
  if printf '%s' "$vor_hash258" | grep -qE '(^|[[:space:];&|{(])weitere_abweichungen_ausgeben([[:space:]]|$)'; then
    aufrufstellen_treffer258+=("$nr258")
  fi
done < <(grep -nE '(^|[[:space:];&|{(])weitere_abweichungen_ausgeben([[:space:]]|$)' "$GATE" 2>/dev/null)
local aufrufstellen258=${#aufrufstellen_treffer258[@]}

local -A gesehen258=()
for k258 in "${tabellen_kennungen[@]}"; do
  case "${FALL_TABELLE[$k258]:-}" in
    "Aussage E21: "*)
      fallname258="${FALL_ZU_KENNUNG[$k258]:-}"
      [ -n "$fallname258" ] && gesehen258["$fallname258"]=1
      ;;
  esac
done
anzahl_funktionen258=${#gesehen258[@]}
deckungszeile_registrieren "Aufrufstellendeckung E21: $aufrufstellen258 Aufrufstellen, $anzahl_funktionen258 Fallfunktionen" >/dev/null
pruefe_wahr Z-258 "selbsttest" "gleich" "Statische Lesung von .claude/hooks/dod-gate.sh und der Tabelle 6.12.19, ohne Aufruf des Gates" \
  "die Zahl der Aufrufstellen von weitere_abweichungen_ausgeben im Gate ist gleich der Zahl der verschiedenen Fallfunktionen, die eine Zusicherung mit dem Etikett Aussage E21: pruefen" \
  "$([ "$aufrufstellen258" -eq "$anzahl_funktionen258" ] && echo 1 || echo 0)" \
  "Aufrufstellen=$aufrufstellen258" "Fallfunktionen=$anzahl_funktionen258"
}

# -----------------------------------------------------------------------------
# fall_z259 (6.12.28 f, Runde 11 S11-04): statische Lesung des marken_muster
# aus dem Gate, ohne Aufruf des Gates -- die Lesung muss einen nicht leeren
# Fund liefern.
# -----------------------------------------------------------------------------
fall_z259() {
local muster259
muster259=$(sed -n "s/^marken_muster='\(.*\)'\$/\1/p" "$GATE")
pruefe_wahr Z-259 "selbsttest" "existiert" "Statische Lesung des marken_muster aus dem Gate, ohne Aufruf des Gates" \
  "die Lesung liefert einen nicht leeren Wert -- ein Fund" \
  "$([ -n "$muster259" ] && echo 1 || echo 0)" \
  "nicht leer" \
  "$([ -n "$muster259" ] && echo "nicht leer (Laenge ${#muster259})" || echo "leer")"
}

# -----------------------------------------------------------------------------
# _z260_pruefen (S12-01/S12-02, Runde 12 statisch): gemeinsame Messung fuer
# Z-260, aufgerufen NACH der letzten Registrierung des Blocks -- (a) direkt
# aus zusammenfassung_und_deckung_ausgeben im Normalmodus, NACH allen neun
# Deckungszeilen samt der Aufrufstellendeckung E21 (fall_z258 hat laengst
# registriert, da Teil von FALL_REIHENFOLGE), (b) aus fall_z260 selbst im
# isolierten Lauf. Generische Mindestzahlwache: keine Zeile im Feld darf als
# ERSTE Zahl nach "<Bezeichner>: " eine 0 nennen.
# -----------------------------------------------------------------------------
_z260_pruefen() {
local zeile260 rest260 erste_zahl260
local mindest_fehlschlag260=0
local -a nullzeilen260=()
for zeile260 in "${DECKUNGSZEILEN[@]}"; do
  rest260="${zeile260#*: }"
  erste_zahl260=$(printf '%s' "$rest260" | grep -oE '^[0-9]+' || true)
  if [ "$erste_zahl260" = "0" ]; then
    mindest_fehlschlag260=1
    nullzeilen260+=("$zeile260")
  fi
done
pruefe_wahr Z-260 "selbsttest" "fehlt" "Zusammenfassung des Selbsttestlaufs, Block der Deckungszeilen" \
  "der Block der Deckungszeilen fuehrt keine Zeile, deren erste Zahl 0 ist" \
  "$([ "$mindest_fehlschlag260" -eq 0 ] && echo 1 || echo 0)" \
  "keine Zeile mit erster Zahl 0 (${#DECKUNGSZEILEN[@]} Zeilen geprueft)" \
  "$([ "$mindest_fehlschlag260" -eq 1 ] && printf '%s | ' "${nullzeilen260[@]}" || echo keine)"
}

# -----------------------------------------------------------------------------
# fall_z260 -- NUR fuer den ISOLIERTEN Einzelfall-Kindlauf (Mutationsmodus
# oder manuelle Wiederholung). Im Normalmodus steht diese Funktion
# ABSICHTLICH NICHT in FALL_REIHENFOLGE (wie fall_z230_231) -- dort misst
# zusammenfassung_und_deckung_ausgeben Z-260 DIREKT ueber _z260_pruefen,
# nachdem der EINE, echte Block bereits vollstaendig registriert ist. Ein
# zweiter Lauf dieser Funktion IM SELBEN Prozess wuerde den Block verdoppeln
# und Z-260 doppelt melden -- deshalb der Ausschluss aus der Reihenfolge,
# nicht eine Bedingung hier drin.
# -----------------------------------------------------------------------------
fall_z260() {
local adr_pfad260 deckung_ausgabe260 gegenstand_ausgabe260 zeile260 muster260 anz_tab260
adr_pfad260="$REPO_WURZEL/docs/adr/0002-architekturentscheid-ziel-stack.md"
tabelle_lesen "$adr_pfad260"

# S12-01, Nachbildung der drei Abgleichzeilen wie im Normalmodus -- im
# isolierten Lauf hat ausser Z-260 selbst (unten) niemand gemeldet, die
# Zahlen "geprueft"/"Abweichungen" sind deshalb 0, ohne dass das ein
# Widerspruch waere.
anz_tab260=${#tabellen_kennungen[@]}
deckungszeile_registrieren "Deckung: $anz_tab260 Kennungen in der Tabelle, 0 geprueft, $anz_tab260 ohne Pruefung, 0 ohne Kennung" >/dev/null
deckungszeile_registrieren "Kanalabgleich: $anz_tab260 Kennungen, 0 Abweichungen" >/dev/null
deckungszeile_registrieren "Praedikatabgleich: $anz_tab260 Kennungen, 0 Abweichungen" >/dev/null

deckung_ausgabe260=$(schluessel_und_grammatikdeckung "$adr_pfad260")
while IFS= read -r zeile260; do
  [ -n "$zeile260" ] && deckungszeile_registrieren "$zeile260" >/dev/null
done <<< "$deckung_ausgabe260"
gegenstand_ausgabe260=$(gegenstandsdeckung_schluessel "$GATE")
while IFS= read -r zeile260; do
  [ -n "$zeile260" ] && deckungszeile_registrieren "$zeile260" >/dev/null
done <<< "$gegenstand_ausgabe260"

# Pfaddeckung ueber die eigene Spur NUR, wenn in DIESEM Lauf tatsaechlich
# Gate-Aufrufe bestehen (GATE_AUFRUF_ZAEHLER > 0). fall_z260 ruft das Gate
# selbst nie auf; im isolierten Einzelfall-Kindlauf (Mutationsmodus) ist der
# Zaehler deshalb 0, und pfaddeckung_pruefen traefe nur die fail-closed-
# Zweige "Sollmenge leer oder Spur leer" -- eine erfundene Pfaddeckungszeile
# waere kein Beleg fuer irgendetwas UND meldete Z-230/Z-231 fuer diesen
# Lauf, was hier fehl am Platz ist. Der isolierte Lauf registriert die
# Pfaddeckung deshalb schlicht NICHT, wenn es nichts zu belegen gibt.
if [ "${GATE_AUFRUF_ZAEHLER:-0}" -gt 0 ]; then
  pfaddeckung_pruefen
fi

# Billiger, mutationsempfindlicher Zusatz (Ziel der Mutation dieser Kennung:
# marken_muster im Gate wird leer) -- ohne den teuren Schwaechungslauf zu
# wiederholen, der bereits unter Z-252/Z-255 laeuft (6.2.2).
muster260=$(sed -n "s/^marken_muster='\(.*\)'\$/\1/p" "$GATE")
if [ -n "$muster260" ]; then
  deckungszeile_registrieren "Musterlesung (Z-260): 1 nicht leerer Fund" >/dev/null
else
  deckungszeile_registrieren "Musterlesung (Z-260): 0 nicht leerer Fund" >/dev/null
fi

_z260_pruefen
}

# -----------------------------------------------------------------------------
# fall_z261 (6.12.28 f, Runde 11 S11-06): Gegenrichtung der Grammatikdeckung
# -- die Ausgabezeile "Grammatikdeckung: ..." muss als Zahl der fremden
# Etiketten genau 0 nennen (keine Mutation, Grund 1: Vorbild Z-152/Z-153).
# -----------------------------------------------------------------------------
fall_z261() {
local adr_pfad261 deckung_ausgabe261 grammatikdeckung_zeile261 fremde261
adr_pfad261="$REPO_WURZEL/docs/adr/0002-architekturentscheid-ziel-stack.md"
tabelle_lesen "$adr_pfad261"
deckung_ausgabe261=$(schluessel_und_grammatikdeckung "$adr_pfad261")
grammatikdeckung_zeile261=$(printf '%s\n' "$deckung_ausgabe261" | grep -E '^Grammatikdeckung: [0-9]+ Kuerzel, [0-9]+ ohne Zeile, [0-9]+ fremde Etiketten$' | tail -n1)
fremde261=$(printf '%s' "$grammatikdeckung_zeile261" | sed -E 's/^Grammatikdeckung: [0-9]+ Kuerzel, [0-9]+ ohne Zeile, ([0-9]+) fremde Etiketten$/\1/')
[ -n "$fremde261" ] || fremde261=-1
pruefe_wahr Z-261 "selbsttest" "gleich" "Zusammenfassung des Selbsttestlaufs, Zeile der Grammatikdeckung" \
  "die Ausgabezeile Grammatikdeckung: nennt als Zahl der fremden Etiketten genau 0" \
  "$([ "$fremde261" = "0" ] && echo 1 || echo 0)" \
  "f=0" "f=$fremde261 (Zeile: '$grammatikdeckung_zeile261')"
}

# -----------------------------------------------------------------------------
# fall_z253_254 (6.12.28 c Punkt 3 "zweite benannte Grenze", Alternativen-
# deckung): statische Lesung des marken_muster und der Spalte Element der
# Zeilen LAGE/SCHWELLE der Elementtabelle 6.12.7, ohne Aufruf des Gates.
# -----------------------------------------------------------------------------
fall_z253_254() {
local muster253
muster253=$(sed -n "s/^marken_muster='\(.*\)'\$/\1/p" "$GATE")
local adr253="$REPO_WURZEL/docs/adr/0002-architekturentscheid-ziel-stack.md"

local lage_element253 schwelle_element253
lage_element253=$(grep -E '^\| `LAGE` \|' "$adr253" | head -n1 | awk -F'|' '{print $3}')
schwelle_element253=$(grep -E '^\| `SCHWELLE` \|' "$adr253" | head -n1 | awk -F'|' '{print $3}')

local -a erwartete_lage253=()
while IFS= read -r w253; do erwartete_lage253+=("$w253"); done < <(printf '%s' "$lage_element253" | grep -o '`[^`]*`' | sed -e 's/^`//' -e 's/`$//')

local lage_gruppe253
lage_gruppe253=$(printf '%s' "$muster253" | grep -oE '\(A_OK[^)]*\)' | head -n1)
local lage_inhalt253="${lage_gruppe253#\(}"
lage_inhalt253="${lage_inhalt253%\)}"
local -a tatsaechliche_lage253=()
IFS='|' read -ra tatsaechliche_lage253 <<< "$lage_inhalt253"

local gleich253=1
if [ "${#erwartete_lage253[@]}" -ne "${#tatsaechliche_lage253[@]}" ]; then
  gleich253=0
else
  local i253
  for i253 in "${!erwartete_lage253[@]}"; do
    [ "${erwartete_lage253[$i253]}" = "${tatsaechliche_lage253[$i253]}" ] || gleich253=0
  done
fi
pruefe_wahr Z-253 "selbsttest" "gleich" "Statische Lesung des marken_muster und der Elementtabelle 6.12.7, ohne Aufruf des Gates" \
  "die Alternativen der Lage-Gruppe des marken_muster sind, in Lesereihenfolge, gleich den Backtick-Abschnitten der Spalte Element der Zeile LAGE der Elementtabelle 6.12.7" \
  "$gleich253" "${erwartete_lage253[*]}" "${tatsaechliche_lage253[*]}"

local -a erwartete_schwelle254=()
while IFS= read -r w254; do erwartete_schwelle254+=("$w254"); done < <(printf '%s' "$schwelle_element253" | grep -o '`[^`]*`')
local schwelle_gruppe254
schwelle_gruppe254=$(printf '%s' "$muster253" | grep -oE 'SCHWELLE=[^)]*\)' | head -n1)
local anz_pipes254
anz_pipes254=$(printf '%s' "$schwelle_gruppe254" | tr -cd '|' | wc -c)
local anz_alt254=$((anz_pipes254 + 1))
local ok254=0
[ "${#erwartete_schwelle254[@]}" -eq "$anz_alt254" ] && ok254=1
pruefe_wahr Z-254 "selbsttest" "gleich" "Dieselbe Lesung wie Z-253" \
  "die Zahl der Alternativen der Schwellengruppe des marken_muster ist gleich der Zahl der Backtick-Abschnitte der Spalte Element der Zeile SCHWELLE der Elementtabelle 6.12.7" \
  "$ok254" "${#erwartete_schwelle254[@]}" "$anz_alt254"
}

# -----------------------------------------------------------------------------
# fall_z262_263 (6.12.28 j, Runde 12, Behebung DT12-M14): eine D19-Zeile mit
# einem Wort ausserhalb der vier zulaessigen (OHNE_BEFUND, VERLETZT, B, C) --
# hier SPAETER, wie die Tabelle als Beispiel nennt --, sonst eine gruene
# Attrappenkette: Baumzeile, Uebersichtszeile, EINE gueltige A_OK-Marke,
# Schlusszeile Form 1 mit der vollen Markenzahl (1), MOCK_RC=0. Ein Lauf, zwei
# Messungen (rc + Zaehlerschluessel aus demselben Zustandsverzeichnis) --
# Vorbild fall_z142_143. Am unveraenderten Gate trifft die Zeile das Muster
# in Zeile 810 nicht (d19_treffer_anzahl=0), die Kette blockiert mit dem
# Schluessel "KETTE ausgabe-unlesbar" und Rueckgabewert 2, unabhaengig vom
# MOCK_RC der Attrappenkette.
# -----------------------------------------------------------------------------
fall_z262_263() {
local baum262 m1_262 ausgabe262 zustand262 eingabe262 zaehler_datei262
baum262=$(neuer_mock_baum)
m1_262=$(marken_zeile K1 D20 belege A_OK "" "" 0)
ausgabe262=$(bauen_ausgabe "$baum262" "$m1_262" "SPAETER." "make dod: alle 1 Kettenschritte durchlaufen, keiner ungleich 0, 1 gueltige Marken gezaehlt.")
zustand262=$(neu_verzeichnis)
eingabe262=$(baue_eingabe "Stop" "$baum262" "fall-z262")
rufe_gate "$eingabe262" "$zustand262" "$WERKZEUGKASTEN_VOLL" "CLAUDE_PROJECT_DIR=$baum262" "MOCK_AUSGABE=$ausgabe262" "MOCK_RC=0"
pruefe_rc Z-262 "D19-Zeile mit einem Wort ausserhalb von OHNE_BEFUND, VERLETZT, B und C (SPAETER), sonst gruene Attrappenkette mit Schlusszeile Form 1 und voller Markenzahl" 2
zaehler_datei262=$(zaehler_pfad "$zustand262" "fall-z262")
pruefe_zaehler_schluessel Z-263 "Derselbe Fall wie Z-262" \
  "$zaehler_datei262" "KETTE ausgabe-unlesbar"
}

# Reihenfolge des Normalmodus, identisch mit der vormaligen Fallreihenfolge,
# erweitert um Z-209..Z-229 (6.12.28 b, O-27 Phase 1). Wandert seit dieser
# Einheit in den VORSPANN (vor ::VORSPANN-ENDE::), weil fall_z230_231 sie im
# isolierten Mutationslauf braucht (S10-10-Folge). fall_z230_231 selbst steht
# ABSICHTLICH NICHT in dieser Liste -- im Normalmodus wertet
# pfaddeckung_pruefen direkt aus der Zusammenfassung aus.
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
  fall_z156_157
  fall_z160
  fall_z164_165
  fall_z168_169
  fall_z170_179
  fall_z180
  fall_z181
  fall_z185
  fall_z186
  fall_z187
  fall_z188
  fall_z189
  fall_z190
  fall_z198
  fall_z199
  fall_z208
  fall_z209_211
  fall_z212_214
  fall_z215_217
  fall_z218_220
  fall_z221
  fall_z222
  fall_z223
  fall_z224
  fall_z225
  fall_z226
  fall_z227
  fall_z228
  fall_z229
  fall_z232_251
  fall_z253_254
  fall_z252_255
  fall_z256
  fall_z257
  fall_z258
  fall_z259
  fall_z261
  fall_z262_263
  fall_z194_197
)
# fall_z260 steht ABSICHTLICH NICHT in dieser Liste (S12-01, wie
# fall_z230_231) -- im Normalmodus misst zusammenfassung_und_deckung_aus-
# geben Z-260 direkt ueber _z260_pruefen, NACH der letzten Registrierung des
# einen, echten Blocks der Deckungszeilen.

# -----------------------------------------------------------------------------
# FALL_ZU_KENNUNG (Auftrag Punkt 2): ordnet jeder Kennung Z-nnn GENAU EINE
# Fallfunktion zu. Handgefuehrte Tabelle (nicht zur Laufzeit aus
# Zeilenbereichen dieser Datei bestimmt -- das war Befund S6-08/DT6-04);
# mehrere Kennungen duerfen auf dieselbe Funktion zeigen, wenn ihr
# Pruefaufbau derselbe ist. Z-110 ist am 2026-09-03 zurueckgezogen und hat
# absichtlich KEINEN Eintrag. Wandert seit O-27 Phase 2 (wie zuvor
# FALL_REIHENFOLGE in Phase 1) VOR ::VORSPANN-ENDE::, weil
# _grammatik_fallfunktionen_liste (aufgerufen aus fall_z252_255) sie auch im
# ISOLIERTEN Kindprozess braucht -- ohne diese Verschiebung wertet Bash
# "FALL_ZU_KENNUNG[$kennung]" dort als arithmetischen Index (die Assoziativitaet
# ist dem Kindprozess unbekannt) und bricht mit "Z: unbound variable" ab
# (Kennung "Z-170" als "Z minus 170" gelesen) -- am Bau gefunden und behoben.
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
  ["Z-156"]="fall_z156_157"
  ["Z-157"]="fall_z156_157"
  ["Z-158"]="fall_z001"
  ["Z-159"]="fall_z008"
  ["Z-160"]="fall_z160"
  ["Z-161"]="fall_z019"
  ["Z-162"]="fall_z020"
  ["Z-163"]="fall_z037"
  ["Z-164"]="fall_z164_165"
  ["Z-165"]="fall_z164_165"
  ["Z-166"]="fall_z009_010"
  ["Z-167"]="fall_z013"
  ["Z-168"]="fall_z168_169"
  ["Z-169"]="fall_z168_169"
  ["Z-170"]="fall_z170_179"
  ["Z-171"]="fall_z170_179"
  ["Z-172"]="fall_z170_179"
  ["Z-173"]="fall_z170_179"
  ["Z-174"]="fall_z170_179"
  ["Z-175"]="fall_z170_179"
  ["Z-176"]="fall_z170_179"
  ["Z-177"]="fall_z170_179"
  ["Z-178"]="fall_z170_179"
  ["Z-179"]="fall_z170_179"
  ["Z-180"]="fall_z180"
  ["Z-181"]="fall_z181"
  ["Z-182"]="fall_z038_048"
  ["Z-183"]="fall_z017_018"
  ["Z-184"]="fall_z066"
  ["Z-185"]="fall_z185"
  ["Z-186"]="fall_z186"
  ["Z-187"]="fall_z187"
  ["Z-188"]="fall_z188"
  ["Z-189"]="fall_z189"
  ["Z-190"]="fall_z190"
  ["Z-191"]="fall_z001"
  ["Z-192"]="fall_z021_032"
  ["Z-193"]="fall_z001"
  ["Z-198"]="fall_z198"
  ["Z-199"]="fall_z199"
  ["Z-200"]="fall_z021_032"
  ["Z-201"]="fall_z021_032"
  ["Z-202"]="fall_z027_028"
  ["Z-203"]="fall_z033_034"
  ["Z-204"]="fall_z021_032"
  ["Z-205"]="fall_z021_032"
  ["Z-206"]="fall_z011_012"
  ["Z-207"]="fall_z016"
  ["Z-208"]="fall_z208"
  ["Z-194"]="fall_z194_197"
  ["Z-195"]="fall_z194_197"
  ["Z-196"]="fall_z194_197"
  ["Z-197"]="fall_z194_197"
  ["Z-209"]="fall_z209_211"
  ["Z-210"]="fall_z209_211"
  ["Z-211"]="fall_z209_211"
  ["Z-212"]="fall_z212_214"
  ["Z-213"]="fall_z212_214"
  ["Z-214"]="fall_z212_214"
  ["Z-215"]="fall_z215_217"
  ["Z-216"]="fall_z215_217"
  ["Z-217"]="fall_z215_217"
  ["Z-218"]="fall_z218_220"
  ["Z-219"]="fall_z218_220"
  ["Z-220"]="fall_z218_220"
  ["Z-221"]="fall_z221"
  ["Z-222"]="fall_z222"
  ["Z-223"]="fall_z223"
  ["Z-224"]="fall_z224"
  ["Z-225"]="fall_z225"
  ["Z-226"]="fall_z226"
  ["Z-227"]="fall_z227"
  ["Z-228"]="fall_z228"
  ["Z-229"]="fall_z229"
  ["Z-230"]="fall_z230_231"
  ["Z-231"]="fall_z230_231"
  ["Z-232"]="fall_z232_251"
  ["Z-233"]="fall_z232_251"
  ["Z-234"]="fall_z232_251"
  ["Z-235"]="fall_z232_251"
  ["Z-236"]="fall_z232_251"
  ["Z-237"]="fall_z232_251"
  ["Z-238"]="fall_z232_251"
  ["Z-239"]="fall_z232_251"
  ["Z-240"]="fall_z232_251"
  ["Z-241"]="fall_z232_251"
  ["Z-242"]="fall_z232_251"
  ["Z-243"]="fall_z232_251"
  ["Z-244"]="fall_z232_251"
  ["Z-245"]="fall_z232_251"
  ["Z-246"]="fall_z232_251"
  ["Z-247"]="fall_z232_251"
  ["Z-248"]="fall_z232_251"
  ["Z-249"]="fall_z232_251"
  ["Z-250"]="fall_z232_251"
  ["Z-251"]="fall_z232_251"
  ["Z-252"]="fall_z252_255"
  ["Z-255"]="fall_z252_255"
  ["Z-253"]="fall_z253_254"
  ["Z-254"]="fall_z253_254"
  ["Z-256"]="fall_z256"
  ["Z-257"]="fall_z257"
  ["Z-258"]="fall_z258"
  ["Z-259"]="fall_z259"
  ["Z-260"]="fall_z260"
  ["Z-261"]="fall_z261"
  ["Z-262"]="fall_z262_263"
  ["Z-263"]="fall_z262_263"
)

# ::VORSPANN-ENDE::

# Die FALL_REIHENFOLGE steht seit dieser Einheit im VORSPANN (vor
# ::VORSPANN-ENDE::, oberhalb), weil der isolierte Mutationslauf von
# fall_z230_231 sie braucht (6.12.28 b Punkt 8, S10-10-Folge). Hier keine
# zweite Definition -- das waere die zweite Stelle fuer dieselbe Aussage
# (6.2.2).

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

# -----------------------------------------------------------------------------
# buchhaltung_abgleich <modus: bilden|einloesen> (ADR 0002, 6.12.28 f,
# Nachtrag vom 2026-09-08, Entscheid "Reihenfolge"): bildet aus
# GEMELDETE_KENNUNGEN/KANAL_GEMELDET/PRAEDIKAT_GEMELDET die drei
# Abgleichzeilen "Deckung: ...", "Kanalabgleich: ..." und
# "Praedikatabgleich: ...".
#
# modus=bilden (ERSTE Erhebung, VOR der Messung von Z-260): registriert die
# drei Zeilen NEU im Feld DECKUNGSZEILEN und merkt sich ihre Plaetze in
# BUCHHALTUNG_IDX_DECKUNG/_KANAL/_PRAEDIKAT. Keine Ausgabe, kein Urteil --
# Z-260 selbst ist an dieser Stelle noch nicht gemeldet, die Zahlen
# "geprueft"/"Abweichungen" sind deshalb noch nicht die endgueltigen. Die
# ERSTE Zahl jeder der drei Zeilen ist unabhaengig davon bereits die
# endgueltige (${#tabellen_kennungen[@]}, 6.12.28 f Punkt 5) -- genau darauf
# stuetzt sich die Zulaessigkeit dieses Vorgehens.
#
# modus=einloesen (ZWEITE Erhebung, NACH der Messung von Z-260): bildet
# dieselben drei Zeilen aus dem JETZT vollstaendigen GEMELDETE_KENNUNGEN neu,
# ERSETZT die Eintraege an den gemerkten Plaetzen, gibt die Befundzeilen aus
# (Fundstelle dieser Funktion) und setzt BUCHHALTUNG_FEHLER sowie
# BUCHHALTUNG_EINGELOEST=1.
# -----------------------------------------------------------------------------
BUCHHALTUNG_IDX_DECKUNG=-1
BUCHHALTUNG_IDX_KANAL=-1
BUCHHALTUNG_IDX_PRAEDIKAT=-1
BUCHHALTUNG_FEHLER=1
BUCHHALTUNG_EINGELOEST=0
buchhaltung_abgleich() {
local modus="$1"
local -a _ba_ohne_pruefung=() _ba_ohne_kennung=() _ba_doppelt=()
local k g gefunden

for k in "${tabellen_kennungen[@]}"; do
  gefunden=0
  for g in "${GEMELDETE_KENNUNGEN[@]:-}"; do
    [ "$g" = "$k" ] && gefunden=1 && break
  done
  [ "$gefunden" -eq 1 ] || _ba_ohne_pruefung+=("$k")
done

for g in "${GEMELDETE_KENNUNGEN[@]:-}"; do
  [ -n "$g" ] || continue
  gefunden=0
  for k in "${tabellen_kennungen[@]}"; do
    [ "$g" = "$k" ] && gefunden=1 && break
  done
  [ "$gefunden" -eq 1 ] || _ba_ohne_kennung+=("$g")
done

if [ "${#GEMELDETE_KENNUNGEN[@]}" -gt 0 ]; then
  while IFS= read -r k; do
    [ -n "$k" ] && _ba_doppelt+=("$k")
  done < <(printf '%s\n' "${GEMELDETE_KENNUNGEN[@]}" | sort | uniq -d)
fi

local _ba_fehler=0
[ "${#_ba_ohne_pruefung[@]}" -gt 0 ] && _ba_fehler=1
[ "${#_ba_ohne_kennung[@]}" -gt 0 ] && _ba_fehler=1
[ "${#_ba_doppelt[@]}" -gt 0 ] && _ba_fehler=1

local _ba_zeile_deckung="Deckung: ${#tabellen_kennungen[@]} Kennungen in der Tabelle, $((${#tabellen_kennungen[@]} - ${#_ba_ohne_pruefung[@]})) geprueft, ${#_ba_ohne_pruefung[@]} ohne Pruefung, ${#_ba_ohne_kennung[@]} ohne Kennung"

# Kanalabgleich (ADR 0002, 6.12.26, Entscheid zu O-25): der von jeder
# pruefe_*-Huelle an _melde gemeldete Kanal wird gegen die dritte Spalte der
# Tabelle 6.12.19 abgeglichen -- ADR 0002, 6.12.26 e: keine Ausnahmeliste
# mehr, jede Kanalabweichung bleibt ein Fehler.
local -a _ba_kanal_zeilen=()
local _ba_kanal_abw=0 erwarteter_kanal gemeldeter_kanal
for k in "${tabellen_kennungen[@]}"; do
  erwarteter_kanal="${KANAL_TABELLE[$k]:-}"
  gemeldeter_kanal="${KANAL_GEMELDET[$k]:-}"
  [ -n "$gemeldeter_kanal" ] || continue
  if [ -z "$erwarteter_kanal" ]; then
    _ba_kanal_abw=$((_ba_kanal_abw + 1))
    _ba_fehler=1
    _ba_kanal_zeilen+=("Kanalabweichung: $k Tabelle=leer gemessen=$gemeldeter_kanal")
    continue
  fi
  if [ "$gemeldeter_kanal" != "$erwarteter_kanal" ]; then
    _ba_kanal_abw=$((_ba_kanal_abw + 1))
    _ba_fehler=1
    _ba_kanal_zeilen+=("Kanalabweichung: $k Tabelle=$erwarteter_kanal gemessen=$gemeldeter_kanal")
  fi
done
local _ba_zeile_kanal="Kanalabgleich: ${#tabellen_kennungen[@]} Kennungen, $_ba_kanal_abw Abweichungen"

# Praedikatabgleich (ADR 0002, 6.12.27 b, O-26): dieselbe Mechanik, gegen
# Spalte 4 (Praedikat). S8-06: verglichen wird die Zeichenkette
# (Reihenfolge verbindlich), nicht als Menge.
local -a _ba_praedikat_zeilen=()
local _ba_praedikat_abw=0 erwartetes_praedikat gemeldetes_praedikat _ba_ist_ohne op
for k in "${tabellen_kennungen[@]}"; do
  erwartetes_praedikat="${PRAEDIKAT_TABELLE[$k]:-}"
  gemeldetes_praedikat="${PRAEDIKAT_GEMELDET[$k]:-}"
  _ba_ist_ohne=0
  for op in "${_ba_ohne_pruefung[@]:-}"; do [ "$op" = "$k" ] && _ba_ist_ohne=1 && break; done
  [ "$_ba_ist_ohne" -eq 1 ] && continue
  if [ -z "$erwartetes_praedikat" ]; then
    _ba_praedikat_abw=$((_ba_praedikat_abw + 1))
    _ba_fehler=1
    _ba_praedikat_zeilen+=("ABWEICHUNG Praedikat $k: gemeldet $gemeldetes_praedikat, Tabelle leer")
    continue
  fi
  if [ "$gemeldetes_praedikat" != "$erwartetes_praedikat" ]; then
    _ba_praedikat_abw=$((_ba_praedikat_abw + 1))
    _ba_fehler=1
    _ba_praedikat_zeilen+=("ABWEICHUNG Praedikat $k: gemeldet $gemeldetes_praedikat, Tabelle $erwartetes_praedikat")
  fi
done
local _ba_zeile_praedikat="Praedikatabgleich: ${#tabellen_kennungen[@]} Kennungen, $_ba_praedikat_abw Abweichungen"

if [ "$modus" = "bilden" ]; then
  # Index NICHT ueber "x=$(deckungszeile_registrieren ...)" lesen -- das
  # liefe in einer Subshell und die Anhaengung an DECKUNGSZEILEN ginge beim
  # Verlassen der Subshell verloren (nur die Ausgabe waere sichtbar). Wie
  # ueberall sonst in dieser Datei: Aufruf als eigene Anweisung mit
  # umgeleiteter Ausgabe, Index danach aus der (jetzt tatsaechlich
  # gewachsenen) Feldlaenge berechnet.
  deckungszeile_registrieren "$_ba_zeile_deckung" >/dev/null
  BUCHHALTUNG_IDX_DECKUNG=$((${#DECKUNGSZEILEN[@]} - 1))
  deckungszeile_registrieren "$_ba_zeile_kanal" >/dev/null
  BUCHHALTUNG_IDX_KANAL=$((${#DECKUNGSZEILEN[@]} - 1))
  deckungszeile_registrieren "$_ba_zeile_praedikat" >/dev/null
  BUCHHALTUNG_IDX_PRAEDIKAT=$((${#DECKUNGSZEILEN[@]} - 1))
  return 0
fi

# modus = einloesen: die drei Zeilen an ihren gemerkten Plaetzen ERSETZEN,
# nicht neu anhaengen -- das Feld waechst dabei nicht.
DECKUNGSZEILEN[$BUCHHALTUNG_IDX_DECKUNG]="$_ba_zeile_deckung"
DECKUNGSZEILEN[$BUCHHALTUNG_IDX_KANAL]="$_ba_zeile_kanal"
DECKUNGSZEILEN[$BUCHHALTUNG_IDX_PRAEDIKAT]="$_ba_zeile_praedikat"

if [ "${#_ba_ohne_pruefung[@]}" -gt 0 ]; then
  echo "Kennungen der Tabelle OHNE Pruefung: ${_ba_ohne_pruefung[*]}"
fi
if [ "${#_ba_ohne_kennung[@]}" -gt 0 ]; then
  echo "Gemeldete Pruefungen mit einer Kennung, die NICHT in der Tabelle steht: ${_ba_ohne_kennung[*]}"
fi
if [ "${#_ba_doppelt[@]}" -gt 0 ]; then
  echo "Doppelt gemeldete Kennungen: ${_ba_doppelt[*]}"
fi
local _bz
for _bz in "${_ba_kanal_zeilen[@]:-}"; do [ -n "$_bz" ] && echo "$_bz"; done
for _bz in "${_ba_praedikat_zeilen[@]:-}"; do [ -n "$_bz" ] && echo "$_bz"; done

BUCHHALTUNG_FEHLER="$_ba_fehler"
BUCHHALTUNG_EINGELOEST=1
}

zusammenfassung_und_deckung_ausgeben() {
  # Pfaddeckung (ADR 0002, 6.12.28 b, O-27 (a1)): laeuft im Normalmodus HIER,
  # als ERSTE Handlung dieser Funktion und damit VOR jeder Deckungspruefung,
  # damit Z-230/Z-231 in der Zaehlung "N von M Zusicherungen" und in der
  # Deckung gegen Tabelle 6.12.19 als geprueft gelten (6.12.28 b Punkt 8).
  pfaddeckung_pruefen
  echo
  echo "=== Zusammenfassung ==="
  if [ "${#fehlgeschlagene_faelle[@]}" -gt 0 ]; then
    echo "Fehlgeschlagene Faelle:"
    for f in "${fehlgeschlagene_faelle[@]}"; do
      echo "  - $f"
    done
  fi

  # -----------------------------------------------------------------------------
  # Deckung (ADR 0002, 6.12.25 a; Reihenfolge berichtigt 2026-09-08, ADR 0002
  # 6.12.28 f): Kennungen aus der Tabelle 6.12.19 dieser ADR-Datei (Zeilen,
  # die mit "| Z-" beginnen) gegen die tatsaechlich gemeldeten Kennungen, in
  # BEIDE Richtungen. Zurueckgezogene Kennungen sind ausgenommen und werden
  # aufgezaehlt -- erkannt seit 6.12.27 h (S8-01) ueber die KANALSPALTE
  # (kein Wert des Vorrats). Der Pfad zur ADR-Datei wird REPO-RELATIV
  # bestimmt, nicht ueber einen absoluten Pfad der Arbeitsumgebung (das
  # Skript liegt unter scripts/).
  # -----------------------------------------------------------------------------
  adr_pfad="$REPO_WURZEL/docs/adr/0002-architekturentscheid-ziel-stack.md"
  echo
  echo "=== Deckung gegen Tabelle 6.12.19 ($adr_pfad) ==="

  # tabelle_lesen (vormals inline, jetzt Vorspann-Funktion -- SST-P1-06,
  # Z-258/Z-260, 6.2.2) fuellt tabellen_kennungen/KANAL_TABELLE/
  # PRAEDIKAT_TABELLE/FALL_TABELLE/ZUSICHERUNG_TABELLE.
  tabelle_lesen "$adr_pfad"
  if [ ! -f "$adr_pfad" ]; then
    echo "FEHLER  ADR-Datei nicht gefunden: $adr_pfad"
  fi
  if [ "${#zurueckgezogene_kennungen[@]}" -gt 0 ]; then
    echo "Zurueckgezogene Kennungen (von der Deckung ausgenommen): ${zurueckgezogene_kennungen[*]}"
  fi

  # Anfangswerte auf Fehler (ADR 0002, 6.12.28 f Punkt 8.1): das Urteil
  # dieser Deckung gilt erst, wenn die ZWEITE Erhebung der Buchhaltung
  # (unten) es tatsaechlich gesetzt hat -- BUCHHALTUNG_EINGELOEST bleibt bis
  # dahin bei 0 und geht in die Rueckgabewert-Bedingung am Ende ein.
  deckung_fehler=1
  sonstige_fehler=0

  # ---------------------------------------------------------------------
  # Schluessel-, Grammatik- und Aussagendeckung sowie Gegenstandsdeckung
  # Schluessel (6.12.28 f, Entscheid "Reihenfolge" Punkte 2/3, Auftrag
  # Punkt 2): geben ihre Zeilen nicht mehr direkt aus -- die Ausgabe wird
  # HIER aufgefangen und JEDE Zeile (Deckungs- wie Befundzeile
  # gleichermassen) ueber deckungszeile_registrieren an das Feld gehaengt,
  # genau wie fall_z260 es fuer den isolierten Lauf bereits tut. Der
  # Rueckgabewert bleibt Urteil.
  # ---------------------------------------------------------------------
  local _sgd_ausgabe _sgd_zeile _sgd_rc _gds_ausgabe _gds_zeile _gds_rc
  _sgd_ausgabe=$(schluessel_und_grammatikdeckung "$adr_pfad")
  _sgd_rc=$?
  while IFS= read -r _sgd_zeile; do
    [ -n "$_sgd_zeile" ] && deckungszeile_registrieren "$_sgd_zeile" >/dev/null
  done <<< "$_sgd_ausgabe"
  [ "$_sgd_rc" -eq 0 ] || sonstige_fehler=1

  # ---------------------------------------------------------------------
  # Gegenstandsdeckung Schluessel (ADR 0002, 6.12.27 j, Punkt 3, O-26):
  # zweite, unabhaengige Deckung -- haelt die Schluesselzeichenketten aus
  # dem GATE SELBST (nicht der Aufzaehlung in 6.12.4) gegen die
  # Zusicherungsspalte. Ersetzt keine der beiden Deckungen oben, tritt
  # daneben (6.12.27 j, "Der Bestand am 2026-09-06").
  # ---------------------------------------------------------------------
  _gds_ausgabe=$(gegenstandsdeckung_schluessel "$GATE")
  _gds_rc=$?
  while IFS= read -r _gds_zeile; do
    [ -n "$_gds_zeile" ] && deckungszeile_registrieren "$_gds_zeile" >/dev/null
  done <<< "$_gds_ausgabe"
  [ "$_gds_rc" -eq 0 ] || sonstige_fehler=1

  # Buchhaltung, ERSTE Erhebung (6.12.28 f, Entscheid "Reihenfolge" Punkt 4):
  # registriert "Deckung:"/"Kanalabgleich:"/"Praedikatabgleich:" NEU im Feld
  # und merkt sich ihre Plaetze. Keine Ausgabe, kein Urteil -- Z-260 ist an
  # dieser Stelle noch nicht gemeldet.
  buchhaltung_abgleich bilden

  # -----------------------------------------------------------------------
  # Blockdeckung (6.12.28 f, Entscheid "Vollstaendigkeit des Blocks"): haelt
  # die ELF Pflichtetiketten der Tabelle in 6.12.28 f in BEIDE Richtungen
  # gegen die Etiketten (Text vor dem ersten Doppelpunkt) der Zeilen, die
  # bis hierhin im Feld stehen -- ihre EIGENE Zeile zaehlt als letzte dazu.
  # Laeuft NUR hier, nicht im isolierten Einzelfall-Lauf (benannte Grenze,
  # 6.12.28 f Punkt 11.5).
  # -----------------------------------------------------------------------
  local -a _block_soll=(
    "Pfaddeckung"
    "Grammatikschwaechungen"
    "Aufrufstellendeckung E21"
    "Schluesseldeckung"
    "Grammatikdeckung"
    "Aussagendeckung"
    "Gegenstandsdeckung Schluessel"
    "Deckung"
    "Kanalabgleich"
    "Praedikatabgleich"
    "Blockdeckung"
  )
  local -A _block_ist=()
  local _bdz _bde
  for _bdz in "${DECKUNGSZEILEN[@]}"; do
    _bde="${_bdz%%:*}"
    _block_ist["$_bde"]=1
  done
  _block_ist["Blockdeckung"]=1
  local _block_ohne=0 _bse
  for _bse in "${_block_soll[@]}"; do
    [ -n "${_block_ist[$_bse]:-}" ] || _block_ohne=$((_block_ohne + 1))
  done
  local _block_fremde=0 _bie _btreffer
  for _bie in "${!_block_ist[@]}"; do
    _btreffer=0
    for _bse in "${_block_soll[@]}"; do
      [ "$_bse" = "$_bie" ] && _btreffer=1 && break
    done
    [ "$_btreffer" -eq 1 ] || _block_fremde=$((_block_fremde + 1))
  done
  local _block_zeilen_im_block=$((${#DECKUNGSZEILEN[@]} + 1))
  deckungszeile_registrieren "Blockdeckung: ${#_block_soll[@]} Etiketten erwartet, $_block_ohne ohne Zeile, $_block_fremde fremde Etiketten, $_block_zeilen_im_block Zeilen im Block" >/dev/null
  if [ "$_block_ohne" -gt 0 ] || [ "$_block_fremde" -gt 0 ]; then
    sonstige_fehler=1
  fi

  # Messung von Z-260 (6.12.28 f, Entscheid "Reihenfolge" Punkt 6): ueber
  # den jetzt vollstaendigen Block. Der Vektor der ersten Zahlen wird davor
  # festgehalten (Wache "Unveraenderlichkeit", Punkt 8 unten).
  local -a _vektor_vor=()
  local _vz _vr _vn
  for _vz in "${DECKUNGSZEILEN[@]}"; do
    _vr="${_vz#*: }"
    _vn=$(printf '%s' "$_vr" | grep -oE '^[0-9]+' || true)
    _vektor_vor+=("$_vn")
  done
  _z260_pruefen

  # Buchhaltung, ZWEITE Erhebung (Einloesung, 6.12.28 f Punkt 7): dieselbe
  # Funktion, jetzt mit der Meldung von Z-260 -- ersetzt die drei Zeilen an
  # ihren Plaetzen, gibt die Befundzeilen aus, liefert als EINZIGE das
  # Urteil.
  buchhaltung_abgleich einloesen
  [ "$sonstige_fehler" -eq 1 ] && BUCHHALTUNG_FEHLER=1
  deckung_fehler="$BUCHHALTUNG_FEHLER"

  # Wache Unveraenderlichkeit (6.12.28 f Punkt 8.4): der Vektor der ersten
  # Zahlen darf sich zwischen der Messung (oben) und der Ausgabe (unten)
  # nicht geaendert haben -- geprueft, nicht angenommen.
  local -a _vektor_nach=()
  for _vz in "${DECKUNGSZEILEN[@]}"; do
    _vr="${_vz#*: }"
    _vn=$(printf '%s' "$_vr" | grep -oE '^[0-9]+' || true)
    _vektor_nach+=("$_vn")
  done
  local _vi
  if [ "${#_vektor_vor[@]}" -ne "${#_vektor_nach[@]}" ]; then
    echo "Wache Unveraenderlichkeit: verletzt -- Zahl der Zeilen im Block hat sich zwischen Messung und Ausgabe geaendert (${#_vektor_vor[@]} -> ${#_vektor_nach[@]})."
    deckung_fehler=1
  else
    for _vi in "${!_vektor_vor[@]}"; do
      if [ "${_vektor_vor[$_vi]}" != "${_vektor_nach[$_vi]}" ]; then
        echo "Wache Unveraenderlichkeit: verletzt -- Zeile $((_vi + 1)) im Block ('${DECKUNGSZEILEN[$_vi]}') hat ihre erste Zahl zwischen Messung und Ausgabe geaendert (${_vektor_vor[$_vi]} -> ${_vektor_nach[$_vi]})."
        deckung_fehler=1
      fi
    done
  fi

  # -----------------------------------------------------------------------------
  # Wache gegen Variablenschatten (Koordinator-Befund, 2026-09-06): "gesamt"
  # und "bestanden" sind einfache Skalare, die _melde bei JEDEM Aufruf
  # weiterzaehlt -- ein lokaler Parameter GLEICHEN NAMENS in irgendeiner
  # pruefe_*-Huelle (Bash vererbt lokale Variablen dynamisch, siehe
  # pruefe_kette_fehlt) ueberschreibt ihn fuer die Dauer dieses Aufrufs
  # unbemerkt. Massgeblich fuer M ("N von M") ist deshalb NICHT der
  # mitgefuehrte Skalar $gesamt, sondern die LAENGE von GEMELDETE_KENNUNGEN
  # -- ein Array-Append ("+=") ist gegen dieselbe Kollision unempfindlich,
  # weil kein pruefe_*-Parameter je "GEMELDETE_KENNUNGEN" heisst. N wird aus
  # derselben Quelle abzueglich der Fehlschlaege gebildet, nicht aus dem
  # mitgefuehrten $bestanden. Weicht der mitgefuehrte Skalar ab, ist DAS
  # SELBST ein Befund (eine pruefe_*-Huelle mit kollidierendem Parameter)
  # und wird gemeldet, aber NICHT die massgebliche Zahl. Gebildet ERST HIER
  # (6.12.28 f Punkt 9), NACH der Meldung von Z-260 -- vorher stimmte M
  # nicht mit der Tabelle ueberein (der Widerspruch, den dieser Nachtrag
  # aufloest).
  # -----------------------------------------------------------------------------
  melde_anzahl_m=${#GEMELDETE_KENNUNGEN[@]}
  melde_anzahl_n=$((melde_anzahl_m - ${#fehlgeschlagene_faelle[@]}))
  if [ "$melde_anzahl_m" -ne "$gesamt" ] || [ "$melde_anzahl_n" -ne "$bestanden" ]; then
    echo "WARNUNG Zaehler-Divergenz: mitgefuehrt gesamt=$gesamt bestanden=$bestanden, aus GEMELDETE_KENNUNGEN gebildet gesamt=$melde_anzahl_m bestanden=$melde_anzahl_n -- massgeblich ist Letzteres (Variablenschatten in einer pruefe_*-Huelle, S10-09)." >&2
  fi
  gesamt="$melde_anzahl_m"
  bestanden="$melde_anzahl_n"
  echo "Selbsttest: $bestanden von $gesamt Zusicherungen bestanden"

  # Einmalige Ausgabe des Blocks (6.12.28 f, Entscheid "eine Quelle, eine
  # Ausgabestelle"): EINE Quelle, EINE Ausgabestelle, nach der Messung --
  # keine Deckungszeile ausserhalb dieser Stelle.
  local _block_ausgabe_zeile
  for _block_ausgabe_zeile in "${DECKUNGSZEILEN[@]}"; do
    echo "$_block_ausgabe_zeile"
  done

  # Explizite, redundante Wache (Koordinator-Befund, 2026-09-06): eine
  # FEHLGESCHLAGEN-Meldung erzwingt den Rueckgabewert 2 -- unabhaengig davon,
  # ob $bestanden/$gesamt (oben bereits aus GEMELDETE_KENNUNGEN gebildet)
  # aus irgendeinem Grund doch wieder gleich waeren. Ein Selbsttest, der
  # eine FEHLGESCHLAGEN-Zeile ausgibt und mit 0 endet, ist ausgeschlossen.
  if [ "${#fehlgeschlagene_faelle[@]}" -gt 0 ]; then
    exit 2
  fi
  # Rueckgabewert 0 setzt zusaetzlich zu den bestehenden Bedingungen voraus,
  # dass die zweite Erhebung der Buchhaltung tatsaechlich gelaufen ist und
  # ihr Urteil gesetzt hat (6.12.28 f Punkt 8.1, Auftrag Punkt 11).
  if [ "$bestanden" -eq "$gesamt" ] && [ "$deckung_fehler" -eq 0 ] \
     && [ "$BUCHHALTUNG_EINGELOEST" -eq 1 ] && [ -f "$adr_pfad" ]; then
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
    local zeile kennung kanal_zelle_mut
    while IFS= read -r zeile; do
      kennung=$(printf '%s' "$zeile" | sed -n 's/^| \(Z-[0-9][0-9]*\).*/\1/p')
      [ -n "$kennung" ] || continue
      # S8-01 (6.12.27 h): dieselbe Rueckzugserkennung ueber die Kanalspalte
      # wie im Normalmodus, statt der frueheren Textsuche.
      kanal_zelle_mut=$(printf '%s' "$zeile" | sed 's/\\|/\x01/g' | awk -F'|' '{print $4}' \
        | sed -e 's/^ *//' -e 's/ *$//' -e 's/\*\*//g' -e 's/`//g')
      if kanal_gueltig "$kanal_zelle_mut"; then
        tabellen_kennungen+=("$kennung")
      fi
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
    local zeitgrenze="${FALL_ZEITGRENZE[$fallname]:-30}"
    (
      if [ -n "${SELBSTTEST_SPERRE_FD:-}" ]; then
        exec {SELBSTTEST_SPERRE_FD}>&- 2>/dev/null || true
      fi
      exec env -i PATH="$PATH" HOME="${HOME:-/root}" "$env_var=$kopie_pfad" \
        timeout "$zeitgrenze" "$BASH_BIN" "$falllauf_datei"
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
