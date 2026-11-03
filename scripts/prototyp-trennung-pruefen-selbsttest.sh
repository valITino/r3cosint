#!/usr/bin/env bash
# =============================================================================
# scripts/prototyp-trennung-pruefen-selbsttest.sh -- Pruefmittel fuer scripts/prototyp-trennung-pruefen.sh (Kettenschritt D10)
# =============================================================================
#
# Anforderung R3-Q-001 (das DoD-Gate stuetzt sich auf die Kette). Grundlage: ADR 0002, Abschnitt 5, Nachtrag vom 2026-10-29
# (Festlegung fuer G3), Zeilen zu D10 und "Faelle, Mutationen und Rueckgabewerte"; docs/12_Freigabe_Grundgeruest.md, Abschnitt 4,
# G3, Festlegungen 2 und 5. Muster: scripts/belege-pruefen-selbsttest.sh und scripts/abnahme-abgleich-selbsttest.sh. Einheit G3.3.
#
# AUFRUF
#   bash scripts/prototyp-trennung-pruefen-selbsttest.sh [--mutationen] [--pruefer <pfad>]
#   Ohne --pruefer gilt scripts/prototyp-trennung-pruefen.sh DESSELBEN Baums, in dem dieses Pruefmittel liegt (der Aufrufort spielt
#   keine Rolle). --pruefer nennt ein anderes Skript (relativ zum Aufrufort), etwa eine Attrappe; im Modus --mutationen das Skript,
#   von dem die Mutanten abgeleitet werden. Das Gate der Faelle ist, ausser in den Faellen mit Attrappe, das echte Gate dieses Baums,
#   .claude/hooks/block-prototype-import.sh, unveraendert.
#
# RUECKGABEWERT
#   0  alle Faelle bestanden und die Deckung ohne Abweichung ("nicht herstellbar" zaehlt weder als bestanden noch als gefallen, wird
#      gemeldet und beruehrt den Rueckgabewert nicht, GP-D1). Im Modus --mutationen zusaetzlich: jede Mutation erkannt, keine
#      wirkungslos, die Mutationsdeckung ohne Abweichung, der Arbeitsbaum nach dem Lauf unveraendert
#   2  mindestens ein Fall gefallen oder eine Abweichung der Deckung; im Modus --mutationen: die Grundlinie besteht nicht, oder eine
#      Mutation ist nicht erkannt oder wirkungslos, oder die Mutationsdeckung weicht ab, oder der Arbeitsbaum ist veraendert
#   3  Lage C des Pruefmittels: der Lauf hat nicht stattgefunden (fehlendes Werkzeug, unbekannter Parameter, fehlendes oder
#      formfehlerhaftes Skript, Gate oder Mutationsdatei, kein Git-Arbeitsbaum um das Pruefmittel, ein Defekt des Pruefmittels)
#
# WERKZEUGE: bash, git, grep, sed (GNU, mit --sandbox), sort, uniq, mktemp, cp, mv, rm, mkdir, ln, chmod, cat, head, tr, cut, env,
#   timeout, cmp, sha256sum, readlink, id, date, mkfifo, jq, sleep. Kein Netz, kein Python, kein uv, kein Docker.
#
# UMGEBUNG JEDES LAUFS: Das Skript laeuft unter "env -i" mit LC_ALL=C, TZ=UTC, HOME auf einem leeren Verzeichnis,
#   GIT_CONFIG_NOSYSTEM=1, GIT_CONFIG_GLOBAL=/dev/null und fester Identitaet; Zeitgrenze 60 s je Aufruf (je Fall anpassbar). Die
#   git-Aufrufe des Pruefmittels loeschen vorher die git-Variablen des Aufrufers.
#
# BAUM UND FAELLE: Ein Grundbaum je Lauf unter mktemp -d, ausserhalb des Arbeitsbaums (Aufraeumen per trap): git init und ein
#   Commit mit dem echten Gate unter .claude/hooks/, .gitignore (ignoriert/ und *.log), prototype/seite.html und prototype/app.js,
#   backend/src/paket/__init__.py und modul.py, backend/tests/test_modul.py, docs/hinweis.md. Je Fall eine Kopie des Grundbaums
#   (cp -a), die Aenderung, eine Kopie des geprueften Skripts nach scripts/prototyp-trennung-pruefen.sh der Kopie (das Skript
#   bestimmt seine Wurzel aus seinem Ort) und ein Lauf. Neue Dateien eines Falls sind unversioniert, ausser der Fall fuegt sie mit
#   vers hinzu. Grundfall: fuenf Textdateien (prototype 2, backend 3), kein Fund, "Kontrollprobe: 4 von 4".
#   Attrappen des Gates: nur wo das echte Gate die Antwort nicht liefern kann (KD-4: die vier Antworten der Kontrollprobe einzeln;
#   KD-5: Rueckgabewert 1, 124 und 137, 2 ohne Ausgabe, 0 mit Ausgabe; die Attrappe gibt jedes andere Ereignis an das echte Gate
#   weiter). Die Antworten "2 ohne Marke" und "Zeitgrenze" des KD-5 werden am echten Gate gemessen, mit einem Ersatz fuer grep im
#   Suchpfad, der bei einer Marke im Inhalt fehlschlaegt oder haengt (D-067, D-068).
#
# SOLL-ARTEN (Spalte 3 der Fallliste)
#   fund                Rueckgabewert 2; die Zeilen unter "=== Funde" sind genau die erwartete Menge (Pfad, Art, Teil der Meldezeile);
#                       "Befunde: n" gleich deren Zahl und letzte Zeile; die Fehlerausgabe ist leer; "Kontrollprobe: 4 von 4"
#   kein-fund           Rueckgabewert 0, keine Zeile unter "=== Funde", "Befunde: 0", Fehlerausgabe leer, "Kontrollprobe: 4 von 4"
#   kein-fund+ausgabe   wie kein-fund, dazu Aussagen ueber die Standardausgabe (ausgabe_mit, ausgabe_ohne)
#   lage-c              Rueckgabewert 3 vor dem Urteil; Fehlerausgabe mit "LAGE C -- <Kennung>:"; Standardausgabe ohne "Geprueft:",
#                       "=== Funde" und "Befunde:"
#   lage-c+funde        Rueckgabewert 3 nach dem Urteil: Lage C je Datei; die Funde stehen in derselben Ausgabe (genau die erwartete
#                       Menge, auch keine); "Befunde: n" gleich deren Zahl
#   gleich              zwei Laeufe (mit gleichem oder verschiedenem Umfeld): Standardausgabe, Fehlerausgabe, Rueckgabewert gleich
#   schreibfrei         der Wegwerf-Baum ist nach dem Lauf wie davor, einschliesslich seines Git-Verzeichnisses
#   statisch            Aussage ueber den Text des geprueften Skripts, ohne Lauf
#   arbeitsbaum         der Arbeitsbaum ist nach dem ganzen Lauf wie davor; der Fall steht als letzter der Liste
#   Ein Fall kann nach dem Lauf eine eigene Pruefung ausfuehren (nach_lauf), die weitere Abweichungen meldet.
#
# FALLLISTE: Der Datenblock unten ("#F|"-Zeilen: Kennung|Klassen|Soll|Herkunft|Gegenstand) ist die maschinenlesbare Liste. Jede
#   Kennung hat genau eine Funktion f_D<nnn> weiter unten und umgekehrt (mechanisch geprueft). Kennungen D-nnn sind dauerhaft und
#   werden nie wiederverwendet.
#
# DECKUNG (als eigener Abschnitt der Ausgabe, nicht in der Zaehlung der Faelle): jede Kennung KD und GD im Kopfkommentar des
#   geprueften Skripts hat Faelle (KD-1 bis KD-7: mindestens einen mit Soll fund, lage-c oder lage-c+funde und einen mit Soll
#   kein-fund; KD-8, KD-9 und GD: mindestens einen); jede Klasse, die ein Fall nennt, steht im Kopfkommentar oder ist eine Grenze
#   des Gates (GP). Der Kopfkommentar nennt die Kennungen einzeln, ohne Bereichsschreibweise.
#
# MODUS --mutationen: Mutationsdatei scripts/prototyp-trennung-pruefen-mutationen.txt im Verzeichnis dieses Skripts
#   Zeilenform: Kennung DM-nnn, Tabulator, Klasse (KD-Kennung), Tabulator, sed-Ausdruck (mit sed -E --sandbox auf eine Wegwerfkopie
#   des Skripts angewandt), Tabulator, Mindestsatz (Fallkennungen durch Komma), Tabulator, Grund. Zeilen mit # am Anfang und
#   Leerzeilen werden uebergangen. Nur ASCII, genau vier Tabulatoren je Zeile; eine Form, die der Modus nicht liest, ist Lage C.
#   Ablauf: (1) Grundlinie: alle Faelle und die Deckung gegen eine unveraenderte Kopie; besteht sie nicht, endet der Modus mit 2
#   ohne Mutation. (2) Je Mutation eine Kopie; ist sie byte-gleich mit dem Skript, verwirft bash -n sie oder endet sed mit einem
#   Fehler, ist die Mutation wirkungslos. (3) Erkannt ist sie, wenn jeder Fall ihres Mindestsatzes gegen die Mutante faellt; nur
#   diese Faelle laufen gegen sie. (4) Schluss: geprueft, erkannt, nicht erkannt, wirkungslos; die Mutationsdeckung (jede Klasse KD
#   des Kopfkommentars hat eine Mutation, deren Mindestsatz einen Fall dieser Klasse enthaelt); der Vergleich des Arbeitsbaums
#   vor und nach.
#
# GRENZEN DES PRUEFMITTELS
#   GP-D1  Die Faelle "nicht lesbar" (D-088, D-097) sind als root nicht herstellbar; sie werden gezaehlt und gemeldet, ohne Mutation.
#   GP-D2  Das echte Gate liefert nur die Rueckgabewerte 0 und 2; 1, 124 und 137 sowie "2 ohne Ausgabe" und "0 mit Ausgabe" des KD-5
#          sind nur an der Attrappe gemessen (D-060 bis D-066). Am echten Gate gemessen sind "2 ohne Marke" und die Zeitgrenze.
#   GP-D3  Die Fehlerausgabe der Faelle mit Soll fund oder kein-fund wird nur auf "leer" gemessen; der Wortlaut der Meldungen von
#          Lage C ist nur an Kennung und Stichwort gemessen.
#   GP-D4  Die statischen Faelle (D-098, D-099) lesen den Text mit benannten Mustern: ein Befehl, den das Muster nicht nennt, bleibt
#          unbemerkt; die uebrigen Zweige prueft der Static Software Tester am Code.
#   GP-D5  Die Verknuepfungen und Fifos (D-089, D-103, D-104, D-107, D-109, D-110, D-121) setzen ein Dateisystem mit symbolischen
#          Verknuepfungen und mkfifo voraus.
#   GP-D6  Die Faelle D-091 bis D-093 messen die Wirkung der Variablen des Aufrufers, nicht die Liste der geloeschten Variablen. Ein
#          Name, der aus der Liste im Skript faellt, ohne dass ein Fall ihn nennt, bleibt unbemerkt. BASH_ENV des Aufrufers wirkt
#          vor der ersten Zeile des Skripts und ist nicht abwehrbar; sein Weg in das Gate ist durch "env -i" geschlossen, aber ohne Fall.
#   GP-D7  "export LC_ALL=C" im Skript hat keine beobachtbare Wirkung auf die Faelle: dazu gibt es weder Fall noch Mutation.
#   GP-D8  Das Gesamtbudget von 120 s wird an einer Kopie mit BUDGET_S=2 gemessen (D-152), nicht mit 120 s; der Wert 120 selbst ist
#          ungemessen.
#
set -uo pipefail

# -----------------------------------------------------------------------------
# 0. Umfeld des Pruefmittels selbst: die git-Variablen des Aufrufers loeschen, Spracheinstellung C
# -----------------------------------------------------------------------------
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_COMMON_DIR GIT_NAMESPACE GIT_CEILING_DIRECTORIES GIT_DISCOVERY_ACROSS_FILESYSTEM GIT_SHALLOW_FILE GIT_GLOB_PATHSPECS GIT_NOGLOB_PATHSPECS GIT_LITERAL_PATHSPECS GIT_ICASE_PATHSPECS 2>/dev/null || true
unset "${!GIT_TRACE@}" 2>/dev/null || true
export LC_ALL=C

PM="prototyp-trennung-pruefen-selbsttest"
FALL_ZEITGRENZE_STANDARD=60
WERKZEUGE_PM="bash git grep sed sort uniq mktemp cp mv rm mkdir ln chmod cat head tr cut env timeout cmp sha256sum readlink id date mkfifo jq sleep"
# Werkzeuge, die das gepruefte Skript und das Gate aufrufen (geschlossene Liste im Kopfkommentar des Skripts); der Suchpfad der Faelle
# D-070 bis D-083 enthaelt genau sie, ausser dem einen, das fehlen soll
KASTEN_VOLL="bash git jq grep timeout mktemp mkdir env rm cat sed tr cut wc"

lage_c_pm() { # lage_c_pm <Meldung> [<Beschaffungsweg>]
  echo "$PM: LAGE C des Pruefmittels -- $1" >&2
  if [ $# -ge 2 ]; then echo "$PM: Beschaffen: $2" >&2; fi
  echo "$PM: Rueckgabewert 3: der Lauf hat nicht stattgefunden." >&2
  exit 3
}

# -----------------------------------------------------------------------------
# 1. Parameter: [--mutationen] [--pruefer <pfad>]
# -----------------------------------------------------------------------------
MODUS="normal"
PRUEFER_ARG=""
while [ $# -gt 0 ]; do
  case "$1" in
    --mutationen) MODUS="mutationen"; shift ;;
    --pruefer)
      [ $# -ge 2 ] || lage_c_pm "Parameter --pruefer ohne Pfad."
      [ -z "$PRUEFER_ARG" ] || lage_c_pm "Parameter --pruefer mehrfach angegeben."
      PRUEFER_ARG="$2"; shift 2 ;;
    *) lage_c_pm "unbekannter Parameter '$1'; erlaubt ist [--mutationen] [--pruefer <pfad>]." ;;
  esac
done

# -----------------------------------------------------------------------------
# 2. Werkzeuge des Pruefmittels
# -----------------------------------------------------------------------------
for w in $WERKZEUGE_PM; do
  command -v "$w" >/dev/null 2>&1 || lage_c_pm "Werkzeug '$w' fehlt." "Werkzeug installieren"
done
# Der Mutationsmodus wendet die Ausdruecke der Mutationsdatei mit sed -E --sandbox an (e, r und w sind verboten); versteht sed die
# Option nicht oder ignoriert er sie, ist das Lage C des Pruefmittels.
if ! printf 'x\n' | sed -E --sandbox -e 's/x/y/' >/dev/null 2>&1 || printf 'x\n' | sed -E --sandbox -e 'w /dev/null' >/dev/null 2>&1; then
  lage_c_pm "sed versteht die Option --sandbox nicht (oder ignoriert sie)." "GNU sed ab Version 4.3 installieren"
fi
BASH_BIN=$(command -v bash)
case "$BASH_BIN" in
  /*) ;;
  *) lage_c_pm "bash ist nicht als absoluter Pfad aufloesbar ('$BASH_BIN')." ;;
esac
GREP_BIN=$(command -v grep)
MKTEMP_BIN=$(command -v mktemp)
case "$GREP_BIN$MKTEMP_BIN" in
  /*/*) ;;
  *) lage_c_pm "grep oder mktemp ist nicht als absoluter Pfad aufloesbar." ;;
esac

# -----------------------------------------------------------------------------
# 3. Arbeitsbaum = Baum, in dem dieses Pruefmittel liegt; der Aufrufort spielt keine Rolle
# -----------------------------------------------------------------------------
SKRIPT_QUELLE="${BASH_SOURCE[0]}"
case "$SKRIPT_QUELLE" in */*) SKRIPT_VERZ_ROH="${SKRIPT_QUELLE%/*}" ;; *) SKRIPT_VERZ_ROH="." ;; esac
SKRIPT_VERZ=$(cd "$SKRIPT_VERZ_ROH" >/dev/null 2>&1 && pwd -P) || lage_c_pm "Verzeichnis des Skripts nicht aufloesbar."
ARBEITSBAUM=$(git -C "$SKRIPT_VERZ" rev-parse --show-toplevel 2>/dev/null) || lage_c_pm "kein Git-Arbeitsbaum um das Verzeichnis des Skripts ($SKRIPT_VERZ)."
if [ -n "$PRUEFER_ARG" ]; then
  case "$PRUEFER_ARG" in
    /*) PRUEFER="$PRUEFER_ARG" ;;
    *) PRUEFER="$PWD/$PRUEFER_ARG" ;;
  esac
else
  PRUEFER="$ARBEITSBAUM/scripts/prototyp-trennung-pruefen.sh"
fi
[ -f "$PRUEFER" ] || lage_c_pm "geprueftes Skript nicht gefunden: $PRUEFER"
[ -r "$PRUEFER" ] || lage_c_pm "geprueftes Skript nicht lesbar: $PRUEFER"
GATE_ECHT="$ARBEITSBAUM/.claude/hooks/block-prototype-import.sh"
[ -f "$GATE_ECHT" ] && [ -r "$GATE_ECHT" ] || lage_c_pm "das echte Gate fehlt oder ist nicht lesbar: $GATE_ECHT"
ARB_COMMIT=$(git -C "$ARBEITSBAUM" rev-parse HEAD 2>/dev/null) || ARB_COMMIT="unbekannt"
PRUEFER_SHA=$(sha256sum "$PRUEFER" | cut -c1-16)
GATE_SHA=$(sha256sum "$GATE_ECHT" | cut -c1-16)
MUTATIONSDATEI="$SKRIPT_VERZ/prototyp-trennung-pruefen-mutationen.txt"
MUT_SHA="-"
if [ -f "$MUTATIONSDATEI" ] && [ -r "$MUTATIONSDATEI" ]; then
  MUT_SHA=$(sha256sum "$MUTATIONSDATEI" | cut -c1-16)
elif [ "$MODUS" = "mutationen" ]; then
  lage_c_pm "Mutationsdatei fehlt oder ist nicht lesbar: $MUTATIONSDATEI"
fi

# -----------------------------------------------------------------------------
# 4. Schnappschuss des Arbeitsbaums VOR jeder weiteren Handlung: Statusliste und Pruefsumme jeder Datei, die versioniert oder
#    unversioniert und nicht ignoriert ist
# -----------------------------------------------------------------------------
schnappschuss() { # schnappschuss <verzeichnis> : Zustand auf der Standardausgabe
  local d="$1" f
  env GIT_OPTIONAL_LOCKS=0 git -C "$d" status --porcelain --untracked-files=all || return 1
  echo "--- Pruefsummen"
  git -C "$d" ls-files -z -c -o --exclude-standard | sort -z -u | while IFS= read -r -d '' f; do
    if [ -L "$d/$f" ]; then
      printf 'L %s\n' "$f"
    elif [ -f "$d/$f" ]; then
      printf 'F %s %s\n' "$(sha256sum < "$d/$f" | cut -c1-64)" "$f"
    else
      printf '? %s\n' "$f"
    fi
  done
  return 0
}

# -----------------------------------------------------------------------------
# 5. Wegwerfverzeichnis ausserhalb des Arbeitsbaums, Aufraeumen auch bei Abbruch
# -----------------------------------------------------------------------------
T=$(mktemp -d) || lage_c_pm "mktemp -d fehlgeschlagen."
T=$(cd "$T" && pwd -P)
case "$T/" in
  "$ARBEITSBAUM"/*) rm -rf "$T"; lage_c_pm "Wegwerfverzeichnis liegt im Arbeitsbaum ($T)." ;;
esac
aufraeumen() {
  chmod -R u+rwx "$T" >/dev/null 2>&1
  rm -rf "$T"
}
trap aufraeumen EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

# -----------------------------------------------------------------------------
# 6. Umgebung jedes Laufs: LC_ALL=C, TZ=UTC, HOME auf ein leeres Verzeichnis, GIT_CONFIG_NOSYSTEM=1, GIT_CONFIG_GLOBAL=/dev/null,
#    feste Identitaet. Das Skript laeuft unter "env -i" mit genau diesen Variablen.
# -----------------------------------------------------------------------------
HOME_LEER="$T/home"
mkdir -p "$HOME_LEER" || lage_c_pm "Verzeichnis $HOME_LEER nicht anlegbar."
ENV_BASIS=(
  "PATH=$PATH"
  "HOME=$HOME_LEER"
  "XDG_CONFIG_HOME=$HOME_LEER"
  "LC_ALL=C"
  "TZ=UTC"
  "GIT_CONFIG_NOSYSTEM=1"
  "GIT_CONFIG_GLOBAL=/dev/null"
  "GIT_AUTHOR_NAME=Selbsttest"
  "GIT_AUTHOR_EMAIL=selbsttest@example.invalid"
  "GIT_AUTHOR_DATE=2026-01-01T00:00:00Z"
  "GIT_COMMITTER_NAME=Selbsttest"
  "GIT_COMMITTER_EMAIL=selbsttest@example.invalid"
  "GIT_COMMITTER_DATE=2026-01-01T00:00:00Z"
)
gitg() { env "${ENV_BASIS[@]}" git "$@"; }

# =============================================================================
# 7. Hilfen fuer die Fallfunktionen (f_D...): alle Pfade relativ zu $BAUM
# =============================================================================
TAB=$'\t'
FALL_K="?"

herstellung_fehler() { # ein Fehler hier ist ein Defekt des Pruefmittels
  echo "$PM: FEHLER -- Herstellung des Falls $FALL_K fehlgeschlagen: $*" >&2
  exit 3
}
datei() { # datei <pfad> [<zeile>...] : Datei im Baum, jede Zeile mit Zeilenumbruch; ohne Zeilen eine leere Datei
  local p="$BAUM/$1"; shift
  mkdir -p "${p%/*}" || herstellung_fehler "Verzeichnis fuer $p"
  if [ $# -eq 0 ]; then : > "$p" || herstellung_fehler "Datei $p"; else printf '%s\n' "$@" > "$p" || herstellung_fehler "Datei $p"; fi
}
roh() { # roh <pfad> <printf-format> [<arg>...] : Datei mit genau diesem Inhalt (auch Bytes ausserhalb von ASCII, NUL)
  local p="$BAUM/$1" fmt="$2"; shift 2
  mkdir -p "${p%/*}" || herstellung_fehler "Verzeichnis fuer $p"
  printf "$fmt" "$@" > "$p" || herstellung_fehler "Datei $p"
}
vers() { # vers <pfad>... : in den Index (versioniert), auch wenn .gitignore den Pfad nennt
  gitg -C "$BAUM" add -f -- "$@" || herstellung_fehler "git add $*"
}
verknuepfung() { # verknuepfung <pfad> <ziel> : symbolische Verknuepfung im Baum
  local p="$BAUM/$1"
  mkdir -p "${p%/*}" || herstellung_fehler "Verzeichnis fuer $p"
  ln -s "$2" "$p" || herstellung_fehler "Verknuepfung $p"
}
anzeige_pfad() { # anzeige_pfad <pfad> : setzt ANZP wie das Skript (Steuerzeichen als Folge geschrieben)
  ANZP="$1"
  case "$ANZP" in *[[:cntrl:]]*) printf -v ANZP '%q' "$ANZP" ;; esac
}
erwarte() { # erwarte <pfad> <art> [<teil der Meldezeile>] : ein erwarteter Fund; der Pfad in Anzeigeform
  anzeige_pfad "$1"
  ERW+=("$ANZP$TAB$2$TAB${3:-}")
}
ausgabe_mit() { AUSGABE_MIT+=("$1"); }
ausgabe_ohne() { AUSGABE_OHNE+=("$1"); }
geprueft() { # geprueft <text> <prototype> <backend> <frontend> <deploy> <leer> <binaer> <nichtdateien> : erwartete Zeile "Geprueft: ..."
  ausgabe_mit "Geprueft: $1 Textdateien (prototype $2, backend $3, frontend $4, deploy $5); ungeprueft: $6 leer, $7 binaer, $8 Nicht-Dateien"
}
grundzaehlung() { geprueft 5 2 3 0 0 0 0 0; }
lc() { LC_KENNUNG="$1"; }
lc_mit() { LC_MIT+=("$1"); }
lc_nicht() { LC_NICHT+=("$1"); }
nicht_herstellbar() { NH_GRUND="$1"; }
env_zusatz() { ENV_ZUSATZ+=("$1"); }
env_zusatz2() { ENV_ZUSATZ2+=("$1"); }
zeitgrenze() { ZEITGRENZE="$1"; }
skript_sed() { SKRIPT_SED="$1"; }
nach_lauf() { NACH_FN="$1"; }
als_root_nicht() { if [ "$(id -u)" = 0 ]; then nicht_herstellbar "als root nicht herstellbar (GP-D1)"; fi; }

kasten() { # kasten <werkzeug>... : setzt KASTEN auf ein Verzeichnis aus Verknuepfungen auf genau diese Werkzeuge
  local box="$FALL/kasten" t p
  rm -rf "${box:?}"
  mkdir -p "$box" || herstellung_fehler "Werkzeugkasten $box"
  for t in "$@"; do
    p=$(command -v "$t") || herstellung_fehler "Werkzeug $t nicht aufloesbar"
    ln -s "$p" "$box/$t" || herstellung_fehler "Verknuepfung $t"
  done
  KASTEN="$box"
}
kasten_ersatz() { # kasten_ersatz <name> : ersetzt das Werkzeug <name> im Kasten durch das Skript auf der Standardeingabe
  local name="${1:?}"
  rm -f "${KASTEN:?}/${name}"
  cat > "$KASTEN/$name" || herstellung_fehler "Ersatz $name"
  chmod +x "$KASTEN/$name" || herstellung_fehler "chmod $name"
}
ohne_werkzeug() { # ohne_werkzeug <w> : Suchpfad mit allen Werkzeugen der Liste ausser <w>; Kennung werkzeug:<w>
  local t liste=""
  for t in $KASTEN_VOLL; do if [ "$t" != "$1" ]; then liste="$liste $t"; fi; done
  kasten $liste
  env_zusatz "PATH=$KASTEN"
  lc "werkzeug:$1"
}
fremdes_repo() { # fremdes_repo : legt $FALL/fremd an (eigenes Repository mit einer Datei)
  mkdir -p "$FALL/fremd" && gitg -C "$FALL/fremd" init -q && printf 'x\n' > "$FALL/fremd/x.txt" && gitg -C "$FALL/fremd" add -A \
    || herstellung_fehler "fremdes Repository"
}

# Attrappe des Gates: antwortet auf die vier Ereignisse der Kontrollprobe wie angegeben (P1 bis P4), auf jedes andere Ereignis wie
# SONST; Antworten: 0, 0err (0 mit Text), R1, R2 (Sperre mit Marke), X2 (2 ohne Marke), S2 (2 mit anderer Marke), N2 (2 ohne Ausgabe),
# E1, E124, E137, ECHT (das echte Gate), LANGSAM (3 s, dann das echte Gate). Dateien, deren Name auf x_rc1.py, x_rc2leer.py,
# x_rc2text.py, x_rc137.py, x_rc124.py, x_rc0text.py, x_marke_shell.py oder x_langsam.py endet, erhalten die Antwort ihres Namens.
gate_attrappe() { # gate_attrappe <P1> <P2> <P3> <P4> <SONST>
  local g="$BAUM/.claude/hooks/block-prototype-import.sh"
  rm -f "${g:?}"
  {
    printf '#!/usr/bin/env bash\n'
    printf 'P1=%q P2=%q P3=%q P4=%q SONST=%q ECHT_BASH=%q ECHT_GATE=%q\n' "$1" "$2" "$3" "$4" "$5" "$BASH_BIN" "$GATE_ECHT"
    cat <<'ATTRAPPE'
ev=$(cat)
pfad=$(printf '%s' "$ev" | jq -r '.tool_input.file_path')
inhalt=$(printf '%s' "$ev" | jq -r '.tool_input.content')
rel=${pfad#"$CLAUDE_PROJECT_DIR"/}
antwort() {
  case "$1" in
    0) exit 0 ;;
    0err) echo "Warnung: unerwartete Ausgabe des Gates" >&2; exit 0 ;;
    R1) echo "BLOCKIERT (Projektauftrag 5.6): Richtung 1 (Produktionscode -> Prototyp): '$rel' ist Produktionscode und importiert aus 'prototype/'." >&2; exit 2 ;;
    R2) echo "BLOCKIERT (Projektauftrag 5.6): Richtung 2 (Prototyp -> Produktionscode): '$rel' liegt im Prototyp und importiert aus dem Produktionscode." >&2; exit 2 ;;
    X2) echo "Gate prototyp-trennung: Pruefung nicht moeglich (grep 2, Schreiber 0); das Gate kann nicht pruefen und blockiert (ADR 0002, 6.13 b)." >&2; exit 2 ;;
    S2) echo "BLOCKIERT (Projektauftrag 5.6): Shell-Befehl mit Schreibwirkung und einem Import, der 'prototype' beruehrt." >&2; exit 2 ;;
    N2) exit 2 ;;
    E1) echo "Fehler im Gate" >&2; exit 1 ;;
    E124) exit 124 ;;
    E137) kill -KILL $$ ;;
    ECHT) printf '%s' "$ev" | "$ECHT_BASH" "$ECHT_GATE"; exit "${PIPESTATUS[1]}" ;;
    LANGSAM) sleep 3; printf '%s' "$ev" | "$ECHT_BASH" "$ECHT_GATE"; exit "${PIPESTATUS[1]}" ;;
  esac
  exit 99
}
case "$rel" in
  backend/kontrollprobe.js) if [[ $inhalt == *import* ]]; then antwort "$P1"; else antwort "$P2"; fi ;;
  prototype/kontrollprobe.js) if [[ $inhalt == *import* ]]; then antwort "$P3"; else antwort "$P4"; fi ;;
  *x_rc1.py) antwort E1 ;;
  *x_rc2leer.py) antwort N2 ;;
  *x_rc2text.py) antwort X2 ;;
  *x_rc137.py) antwort E137 ;;
  *x_rc124.py) antwort E124 ;;
  *x_rc0text.py) antwort 0err ;;
  *x_marke_shell.py) antwort S2 ;;
  *x_langsam.py) antwort LANGSAM ;;
  *) antwort "$SONST" ;;
esac
ATTRAPPE
  } > "$g" || herstellung_fehler "Attrappe des Gates"
}
# Attrappe, die jedes Ereignis an das echte Gate weitergibt (die Kontrollprobe besteht); nur die Dateien mit den Namen oben weichen ab
gate_attrappe_echt() { gate_attrappe ECHT ECHT ECHT ECHT ECHT; }

fall_zuruecksetzen() {
  ERW=()
  ENV_ZUSATZ=()
  ENV_ZUSATZ2=()
  AUSGABE_MIT=()
  AUSGABE_OHNE=()
  LC_KENNUNG=""
  LC_NICHT=()
  LC_MIT=()
  NH_GRUND=""
  CWD_WAHL=""
  AUFRUF_REL=""
  SKRIPT_ORT="scripts/prototyp-trennung-pruefen.sh"
  SKRIPT_SED=""
  NACH_FN=""
  ZEITGRENZE="$FALL_ZEITGRENZE_STANDARD"
  STAT_OK=""
  STAT_SOLL=""
  STAT_IST=""
  DETAIL=()
  ERG=""
  IST=""
  ARGS=()
  KASTEN=""
}

# =============================================================================
# 8. Grundbaum: synthetisch, ausserhalb des Arbeitsbaums
# =============================================================================
grundbaum_bauen() {
  GRUND="$T/grund"
  mkdir -p "$GRUND" || return 1
  gitg -C "$GRUND" init -q || return 1
  BAUM="$GRUND"
  FALL_K="Grundbaum"
  mkdir -p "$BAUM/.claude/hooks" "$BAUM/scripts" "$BAUM/docs" || return 1
  cp "$GATE_ECHT" "$BAUM/.claude/hooks/block-prototype-import.sh" || return 1
  printf 'ignoriert/\n*.log\n' > "$BAUM/.gitignore" || return 1
  datei prototype/seite.html '<p>Demo</p>'
  datei prototype/app.js 'const a = 1;'
  datei backend/src/paket/__init__.py '"""Paket."""'
  datei backend/src/paket/modul.py 'def f():' '    return 1'
  datei backend/tests/test_modul.py 'from paket.modul import f' '' 'def test_f():' '    assert f() == 1'
  datei docs/hinweis.md 'Text'
  gitg -C "$BAUM" add -A && gitg -C "$BAUM" commit -q -m "Grundbaum" || return 1
  return 0
}

# =============================================================================
# 9. Lauf des gepruefen Skripts und Bewertung
# =============================================================================
lauf_pruefer() { # lauf_pruefer <cwd> <aus> <fehler> [VAR=WERT...] : setzt LAUF_RC; das Skript liegt am Ort $SKRIPT_ORT des Baums
  local cwd="$1" out="$2" err="$3" skript="$BAUM/$SKRIPT_ORT"
  shift 3
  if [ "$AUFRUF_REL" = 1 ]; then skript="$SKRIPT_ORT"; fi
  ( cd "$cwd" && exec timeout -k 5 "$ZEITGRENZE" env -i "${ENV_BASIS[@]}" "$@" "$BASH_BIN" "$skript" "${ARGS[@]+"${ARGS[@]}"}" </dev/null ) >"$out" 2>"$err"
  LAUF_RC=$?
}
stderr_kopf() { head -n 3 "$1" 2>/dev/null | tr '\n' ' ' | cut -c1-300; }
tab_sichtbar() { tr '\t' '|'; }
zeitgrenze_ueberschritten() { # zeitgrenze_ueberschritten <rc> : setzt ERG und IST bei einer Ueberschreitung
  if [ "$1" = 124 ] || [ "$1" = 137 ]; then
    ERG=GEFALLEN; IST="Zeitgrenze von $ZEITGRENZE s ueberschritten (Rueckgabewert $1)"; return 0
  fi
  return 1
}
funde_lesen() { # funde_lesen <aus> : setzt IST_FUNDE, IST_BEFUNDE ("x", wenn nicht genau eine Zeile Befunde), IST_ABSCHN, IST_LETZTE
  IST_FUNDE=(); IST_BEFUNDE=x; IST_ABSCHN=0; IST_LETZTE=""
  local zeile in_funde=0 nb=0
  while IFS= read -r zeile || [ -n "$zeile" ]; do
    IST_LETZTE="$zeile"
    if [ "$zeile" = "=== Funde" ]; then IST_ABSCHN=$((IST_ABSCHN + 1)); in_funde=1; continue; fi
    if [ "$in_funde" = 1 ]; then
      if [ "$zeile" = "---" ]; then in_funde=0; continue; fi
      IST_FUNDE+=("$zeile")
      continue
    fi
    case "$zeile" in "Befunde: "*) nb=$((nb + 1)); IST_BEFUNDE="${zeile#Befunde: }" ;; esac
  done < "$1"
  if [ "$nb" -ne 1 ]; then IST_BEFUNDE=x; fi
}
feld() { # feld <zeile> <n> : n-tes Feld (1 bis 3) einer Zeile mit Tabulatoren, ohne Zusammenfassen leerer Felder
  local z="$1" n="$2" f1 f2 f3
  f1="${z%%"$TAB"*}"
  if [ "$f1" = "$z" ]; then f2=""; f3=""; else
    z="${z#*"$TAB"}"
    f2="${z%%"$TAB"*}"
    if [ "$f2" = "$z" ]; then f3=""; else f3="${z#*"$TAB"}"; fi
  fi
  case "$n" in 1) printf '%s' "$f1" ;; 2) printf '%s' "$f2" ;; 3) printf '%s' "$f3" ;; esac
}
vergleiche_funde() { # die gelesenen Fundzeilen (IST_FUNDE) gegen die erwartete Menge (ERW): je erwartetem Fund genau eine Zeile
  local nz=${#IST_FUNDE[@]} i e ek eg et ik ig it found teilweise j tabs
  local -a rest benutzt
  if [ "$IST_ABSCHN" != 1 ]; then ERG=GEFALLEN; DETAIL+=("Abschnitt '=== Funde' ${IST_ABSCHN}-mal vorhanden statt einmal"); return; fi
  if [ "$IST_BEFUNDE" = x ]; then
    ERG=GEFALLEN; DETAIL+=("genau eine Zeile 'Befunde: n' erwartet, gelesen wurde keine oder mehr als eine")
  elif [ "$IST_BEFUNDE" != "$nz" ]; then
    ERG=GEFALLEN; DETAIL+=("'Befunde: $IST_BEFUNDE' ungleich der Zahl der Fundzeilen $nz")
  fi
  case "$IST_LETZTE" in "Befunde: "*) ;; *) ERG=GEFALLEN; DETAIL+=("die letzte Zeile der Standardausgabe ist nicht 'Befunde: n'") ;; esac
  if [ "$nz" -gt 1 ] && [ -n "$(printf '%s\n' "${IST_FUNDE[@]}" | sort | uniq -d)" ]; then
    ERG=GEFALLEN; DETAIL+=("die Fundzeilen enthalten gleiche Zeilen")
  fi
  for i in "${IST_FUNDE[@]+"${IST_FUNDE[@]}"}"; do
    tabs="${i//[!$TAB]/}"
    if [ "${#tabs}" -ne 2 ] || [ -z "$(feld "$i" 1)" ] || [ -z "$(feld "$i" 2)" ] || [ -z "$(feld "$i" 3)" ]; then
      ERG=GEFALLEN; DETAIL+=("Fundzeile nicht in der Form Pfad TAB Art TAB Text: $(printf '%s' "$i" | tab_sichtbar)")
    fi
  done
  rest=("${IST_FUNDE[@]+"${IST_FUNDE[@]}"}")
  benutzt=()
  for ((j = 0; j < ${#rest[@]}; j++)); do benutzt[j]=0; done
  for e in "${ERW[@]+"${ERW[@]}"}"; do
    ek=$(feld "$e" 1); eg=$(feld "$e" 2); et=$(feld "$e" 3)
    found=-1; teilweise=-1
    for ((j = 0; j < ${#rest[@]}; j++)); do
      [ "${benutzt[j]}" = 0 ] || continue
      ik=$(feld "${rest[j]}" 1); ig=$(feld "${rest[j]}" 2); it=$(feld "${rest[j]}" 3)
      if [ "$ik" = "$ek" ] && [ "$ig" = "$eg" ]; then
        if [ -z "$et" ] || [[ $it == *"$et"* ]]; then found=$j; break; fi
        if [ "$teilweise" -lt 0 ]; then teilweise=$j; fi
      fi
    done
    if [ "$found" -ge 0 ]; then
      benutzt[found]=1
    elif [ "$teilweise" -ge 0 ]; then
      ERG=GEFALLEN; DETAIL+=("Fund $ek | $eg: Text '$(feld "${rest[teilweise]}" 3)' enthaelt nicht '$et'"); benutzt[teilweise]=1
    else
      ERG=GEFALLEN; DETAIL+=("fehlt: $ek | $eg")
    fi
  done
  for ((j = 0; j < ${#rest[@]}; j++)); do
    if [ "${benutzt[j]}" = 0 ]; then ERG=GEFALLEN; DETAIL+=("zuviel: $(printf '%s' "${rest[j]}" | tab_sichtbar)"); fi
  done
}
bewerte_funde() { # bewerte_funde <soll> <aus> <fehler> <rc>
  local soll="$1" out="$2" err="$3" rc="$4" erwrc
  if zeitgrenze_ueberschritten "$rc"; then return; fi
  case "$soll" in fund) erwrc=2 ;; *) erwrc=0 ;; esac
  funde_lesen "$out"
  IST="Rueckgabewert $rc, Befunde $IST_BEFUNDE, ${#IST_FUNDE[@]} Fundzeilen"
  if [ "$rc" != "$erwrc" ]; then ERG=GEFALLEN; DETAIL+=("Rueckgabewert $rc statt $erwrc"); fi
  if [ -s "$err" ]; then ERG=GEFALLEN; DETAIL+=("Fehlerausgabe nicht leer: $(stderr_kopf "$err")"); fi
  if [ "$(grep -cxF 'Kontrollprobe: 4 von 4' "$out")" != 1 ]; then ERG=GEFALLEN; DETAIL+=("die Zeile 'Kontrollprobe: 4 von 4' fehlt oder steht mehrfach"); fi
  vergleiche_funde
}
bewerte_lagec_funde() { # bewerte_lagec_funde <aus> <fehler> <rc> : Rueckgabewert 3 nach dem Urteil; die Funde stehen in derselben Ausgabe
  local out="$1" err="$2" rc="$3" n
  if zeitgrenze_ueberschritten "$rc"; then return; fi
  funde_lesen "$out"
  IST="Rueckgabewert $rc, Befunde $IST_BEFUNDE, ${#IST_FUNDE[@]} Fundzeilen, 'LAGE C -- $LC_KENNUNG:' $(if grep -qF -- "LAGE C -- $LC_KENNUNG:" "$err"; then echo ja; else echo nein; fi)"
  if [ "$rc" != 3 ]; then ERG=GEFALLEN; DETAIL+=("Rueckgabewert $rc statt 3"); fi
  if ! grep -qF -- "LAGE C -- $LC_KENNUNG:" "$err"; then ERG=GEFALLEN; DETAIL+=("Fehlerausgabe ohne 'LAGE C -- $LC_KENNUNG:'"); fi
  for n in "${LC_MIT[@]+"${LC_MIT[@]}"}"; do
    if ! grep -qF -- "$n" "$err"; then ERG=GEFALLEN; DETAIL+=("Fehlerausgabe nennt nicht '$n'"); fi
  done
  for n in "${LC_NICHT[@]+"${LC_NICHT[@]}"}"; do
    if grep -qF -- "$n" "$err"; then ERG=GEFALLEN; DETAIL+=("Fehlerausgabe nennt '$n'"); fi
  done
  vergleiche_funde
  if [ "$ERG" = GEFALLEN ]; then DETAIL+=("Fehlerausgabe: $(stderr_kopf "$err")"); fi
}
ausgabe_pruefen() { # ausgabe_pruefen <aus> : Aussagen ueber die Standardausgabe
  local out="$1" s
  for s in "${AUSGABE_MIT[@]+"${AUSGABE_MIT[@]}"}"; do
    if ! grep -qxF -- "$s" "$out"; then ERG=GEFALLEN; DETAIL+=("Standardausgabe enthaelt die Zeile nicht: $s"); fi
  done
  for s in "${AUSGABE_OHNE[@]+"${AUSGABE_OHNE[@]}"}"; do
    if grep -qxF -- "$s" "$out"; then ERG=GEFALLEN; DETAIL+=("Standardausgabe enthaelt die Zeile: $s"); fi
  done
}
bewerte_lagec() { # bewerte_lagec <aus> <fehler> <rc> : Lage C vor dem Urteil
  local out="$1" err="$2" rc="$3" n lc kn
  if zeitgrenze_ueberschritten "$rc"; then return; fi
  lc=nein; grep -qF 'LAGE C' "$err" && lc=ja
  kn=nein; grep -qF -- "LAGE C -- $LC_KENNUNG:" "$err" && kn=ja
  IST="Rueckgabewert $rc, 'LAGE C' $lc, Kennung '$LC_KENNUNG' $kn"
  if [ "$rc" != 3 ]; then ERG=GEFALLEN; DETAIL+=("Rueckgabewert $rc statt 3"); fi
  if [ "$lc" != ja ]; then ERG=GEFALLEN; DETAIL+=("Fehlerausgabe ohne 'LAGE C'"); fi
  if [ "$kn" != ja ]; then ERG=GEFALLEN; DETAIL+=("Fehlerausgabe ohne 'LAGE C -- $LC_KENNUNG:'"); fi
  for n in "${LC_NICHT[@]+"${LC_NICHT[@]}"}"; do
    if grep -qF -- "LAGE C -- $n:" "$err"; then ERG=GEFALLEN; DETAIL+=("Fehlerausgabe meldet '$n', obwohl der erste Mangel der Reihenfolge zu melden ist"); fi
  done
  for n in "${LC_MIT[@]+"${LC_MIT[@]}"}"; do
    if ! grep -qF -- "$n" "$err"; then ERG=GEFALLEN; DETAIL+=("Fehlerausgabe nennt nicht '$n'"); fi
  done
  if grep -q '^Befunde:' "$out"; then ERG=GEFALLEN; DETAIL+=("Standardausgabe enthaelt 'Befunde:'"); fi
  if grep -q '^=== Funde' "$out"; then ERG=GEFALLEN; DETAIL+=("Standardausgabe enthaelt den Abschnitt '=== Funde'"); fi
  if grep -q '^Geprueft:' "$out"; then ERG=GEFALLEN; DETAIL+=("Standardausgabe enthaelt 'Geprueft:'"); fi
  if [ "$ERG" = GEFALLEN ]; then DETAIL+=("Fehlerausgabe: $(stderr_kopf "$err")"); fi
}

baum_voll() { # baum_voll <wurzel> <verzeichnis> : jeder Eintrag unterhalb: Datei (Pfad, SHA-256), Verzeichnis (Pfad), Verknuepfung (Pfad, Ziel)
  local wz="$1" d="$2" p
  for p in "$d"/* "$d"/.[!.]* "$d"/..?*; do
    if [ -L "$p" ]; then
      printf 'L %s %s\n' "${p#"$wz"/}" "$(readlink "$p")"
    elif [ -d "$p" ]; then
      printf 'D %s\n' "${p#"$wz"/}"
      baum_voll "$wz" "$p"
    elif [ -f "$p" ]; then
      printf 'F %s %s\n' "$(sha256sum < "$p" | cut -c1-64)" "${p#"$wz"/}"
    fi
  done
}

# Kennungen KD und GD aus dem Kopfkommentar des gepruefen Skripts (einzeln): eine je Zeile, sortiert, einmalig
kopf_kennungen() {
  local zeile n=0
  while IFS= read -r zeile || [ -n "$zeile" ]; do
    n=$((n + 1))
    if [ "$n" -eq 1 ]; then case "$zeile" in '#!'*) continue ;; esac; fi
    case "$zeile" in '#'*) printf '%s\n' "$zeile" ;; '') ;; *) break ;; esac
  done < "$PRUEFER" | grep -oE '\b(KD-[0-9]|GD-[0-9])\b' | sort -u
}
# Text des gepruefen Skripts ohne Kommentarzeilen und ohne Leerzeilen
code_text() { grep -vE '^[[:space:]]*(#|$)' "$PRUEFER"; }

# =============================================================================
# 10. Die Faelle: Datenblock (maschinenlesbar) und Fallfunktionen
# =============================================================================
#F|D-001|KD-1,KD-2,KD-3,KD-4,KD-9|kein-fund+ausgabe|Grundfall|Grundbaum mit echtem Gate: Kontrollprobe 4 von 4, fuenf Textdateien, kein Fund, Zaehlzeilen
#F|D-002|KD-1,KD-3|fund|Richtung 1|Python-Form "from prototype import" in einer versionierten Datei unter backend/
#F|D-003|KD-1|fund|Richtung 1|JS-Import "../../prototype/helper" in einer neuen, versionierten Datei unter backend/
#F|D-004|KD-1,KD-3|fund|Richtung 1|require("../prototype/helper") unter frontend/ (Wurzel ohne Dateien im Grundbaum)
#F|D-005|KD-1,KD-3|fund|Richtung 1|script src="../prototype/x.js" in einer Datei unter deploy/
#F|D-006|KD-1|kein-fund+ausgabe|Richtung 1 (Gegenprobe)|Namen, die nur wie prototype beginnen oder es nennen (prototypes, es_prototype_alt, Kommentar), sind kein Fund
#F|D-007|KD-1,GD-2|kein-fund+ausgabe|Prosa|ein verbotener Import in einer .md-Datei unter backend/: das Gate nimmt Prosa aus, kein Fund (Durchlass GD-2)
#F|D-008|KD-1|fund|Richtung 1|dynamischer Import __import__("prototype") unter backend/
#F|D-010|KD-2,KD-3|fund|Richtung 2|JS-Import "../backend/helper" in einer Datei unter prototype/
#F|D-011|KD-2|fund|Richtung 2|script src="../backend/static/x.js" in einer HTML-Datei unter prototype/
#F|D-012|KD-2|fund|Richtung 2|Python-Form "from backend import" unter prototype/
#F|D-013|KD-2|kein-fund+ausgabe|Richtung 2 (Gegenprobe)|ein Import aus einem eigenen Unterverzeichnis des Prototyps ist kein Fund
#F|D-020|KD-3|fund|Auswahl|unversionierte, nicht ignorierte Datei mit verbotenem Import ist ein Fund (die Kette urteilt vor dem Commit)
#F|D-021|KD-3,GD-6|kein-fund+ausgabe|Auswahl|ignorierte Datei (*.log) mit verbotenem Import wird nicht geprueft (Durchlass GD-6)
#F|D-022|KD-3|fund|Auswahl|Dateiname mit Leerzeichen
#F|D-023|KD-3|fund|Auswahl|Dateiname mit Zeilenumbruch: der Pfad steht als Folge in einer Zeile, "Befunde: 1"
#F|D-024|KD-3,GD-5|kein-fund+ausgabe|Auswahl|verbotene Importe ausserhalb der vier Wurzeln (scripts/, tools/, Makefile, .github/) sind nicht Gegenstand (Durchlass GD-5)
#F|D-025|KD-3|fund|Auswahl|Umlaut im Namen und Latin-1-Bytes im Inhalt: die Datei geht an das Gate
#F|D-026|KD-3|kein-fund+ausgabe|Auswahl|Verzeichnisse, die nur wie eine Wurzel beginnen (prototypes/, prototype-alt/, backend2/), sind keine Wurzel
#F|D-040|KD-4|lage-c|Kontrollprobe|Gate liefert immer 0: 2 von 4, Lage C
#F|D-041|KD-4|lage-c|Kontrollprobe|Gate sperrt alles mit der Marke der Richtung 1: 1 von 4, Lage C
#F|D-042|KD-4|lage-c|Kontrollprobe|Gate sperrt nur die Richtung 1: 3 von 4, Lage C
#F|D-043|KD-4|lage-c|Kontrollprobe|Gate sperrt nur die Richtung 2: 3 von 4, Lage C
#F|D-044|KD-4|lage-c|Kontrollprobe|Gate vertauscht die Richtungen: 2 von 4, Lage C
#F|D-045|KD-4|lage-c|Kontrollprobe|Gate sperrt Unbeteiligtes der Richtung 1: 3 von 4, Lage C
#F|D-046|KD-4|lage-c|Kontrollprobe|Gate sperrt Unbeteiligtes der Richtung 2: 3 von 4, Lage C
#F|D-047|KD-4|lage-c|Kontrollprobe|Gate gibt bei einem Durchlauf Text aus: 3 von 4, Lage C
#F|D-048|KD-4|lage-c|Kontrollprobe|Gate sperrt ohne die Marke: 3 von 4, Lage C
#F|D-049|KD-4,KD-5|kein-fund+ausgabe|Kontrollprobe (Gegenprobe)|Attrappe, die jedes Ereignis an das echte Gate gibt: 4 von 4, kein Fund
#F|D-060|KD-5,KD-9|lage-c+funde|Gate-Antwort|Rueckgabewert 1: Lage C mit Dateiname, der Fund einer anderen Datei steht in derselben Ausgabe
#F|D-061|KD-5|lage-c+funde|Gate-Antwort|Rueckgabewert 2 ohne Ausgabe: Lage C mit Dateiname, kein Fund
#F|D-062|KD-5|lage-c+funde|Gate-Antwort|Rueckgabewert 2 mit Meldung "Pruefung nicht moeglich" (Attrappe): Lage C, kein Fund
#F|D-063|KD-5|lage-c+funde|Gate-Antwort|Rueckgabewert 137: Lage C mit Dateiname
#F|D-064|KD-5|lage-c+funde|Gate-Antwort|Rueckgabewert 124: Lage C mit Dateiname
#F|D-065|KD-5|lage-c+funde|Gate-Antwort|Rueckgabewert 0 mit Text auf der Fehlerausgabe: Lage C mit Dateiname
#F|D-066|KD-5|lage-c+funde|Gate-Antwort|Rueckgabewert 2 mit der Marke einer anderen Sperre (Shell-Befehl): Lage C, kein Fund
#F|D-067|KD-5|lage-c+funde|Gate-Antwort|echtes Gate, grep faellt bei einer Marke im Inhalt aus: "Pruefung nicht moeglich", Lage C, kein Fund
#F|D-068|KD-5|lage-c+funde|Gate-Antwort|echtes Gate, grep haengt: Zeitgrenze des Gates, Lage C, kein Fund
#F|D-070|KD-6|lage-c|Werkzeuge|bash fehlt im Suchpfad
#F|D-071|KD-6|lage-c|Werkzeuge|git fehlt im Suchpfad
#F|D-072|KD-6|lage-c|Werkzeuge|jq fehlt im Suchpfad
#F|D-073|KD-6|lage-c|Werkzeuge|grep fehlt im Suchpfad
#F|D-074|KD-6|lage-c|Werkzeuge|timeout fehlt im Suchpfad
#F|D-075|KD-6|lage-c|Werkzeuge|mktemp fehlt im Suchpfad
#F|D-076|KD-6|lage-c|Werkzeuge|mkdir fehlt im Suchpfad
#F|D-077|KD-6|lage-c|Werkzeuge|env fehlt im Suchpfad
#F|D-078|KD-6|lage-c|Werkzeuge|rm fehlt im Suchpfad
#F|D-079|KD-6|lage-c|Werkzeuge|cat fehlt im Suchpfad (das Gate braucht es)
#F|D-080|KD-6|lage-c|Werkzeuge|sed fehlt im Suchpfad (das Gate braucht es)
#F|D-081|KD-6|lage-c|Werkzeuge|tr fehlt im Suchpfad (das Gate braucht es)
#F|D-082|KD-6|lage-c|Werkzeuge|cut fehlt im Suchpfad (das Gate braucht es)
#F|D-083|KD-6|lage-c|Werkzeuge|wc fehlt im Suchpfad (das Gate braucht es)
#F|D-084|KD-6,KD-9|lage-c|Aufruf|ein Argument: unbekannter Aufruf ist Lage C
#F|D-085|KD-6|lage-c|Git-Arbeitsbaum|kein Git-Arbeitsbaum um die Wurzel des Skripts
#F|D-086|KD-6|lage-c|Git-Arbeitsbaum|die Wurzel des Skripts ist nicht die oberste Ebene des Git-Arbeitsbaums
#F|D-087|KD-6|lage-c|Gate|das Gate fehlt
#F|D-088|KD-6|lage-c|Gate|das Gate ist nicht lesbar
#F|D-089|KD-6,GP-5|lage-c|Gate|das Gate ist eine Verknuepfung
#F|D-090|KD-6|kein-fund+ausgabe|Umfeld|Aufruf aus dem Arbeitsverzeichnis eines fremden Repositories: das Urteil gilt dem Baum des Skripts
#F|D-091|KD-6|fund|Umfeld|git-Variablen des Aufrufers (GIT_DIR, GIT_WORK_TREE, GIT_INDEX_FILE) aendern das Urteil nicht
#F|D-092|KD-6|fund|Umfeld|CLAUDE_PROJECT_DIR, TMPDIR und HOME des Aufrufers aendern das Urteil nicht
#F|D-093|KD-6,KD-3|fund|Umfeld|globale git-Konfiguration des Aufrufers mit einer Ausschlussliste blendet keine Datei
#F|D-094|KD-6,KD-8|lage-c|Ablage|TMPDIR des Aufrufers zeigt in den Arbeitsbaum: Lage C, nichts wird dort geschrieben
#F|D-095|KD-6|lage-c|Ablage|TMPDIR des Aufrufers zeigt auf ein Verzeichnis, das nicht besteht: Lage C
#F|D-096|KD-6|lage-c|Auswahl|git ls-files scheitert (Index unlesbar): Lage C, nie "kein Fund"
#F|D-097|KD-6|lage-c+funde|Datei|eine nicht lesbare Textdatei: Lage C mit Dateiname
#F|D-098|KD-6|statisch|Werkzeuge|die Werkzeugliste im Kopfkommentar und die im Code nennen dieselben Werkzeuge
#F|D-099|KD-6|statisch|Werkzeuge|ausserhalb von Kommentarzeilen ruft das Skript keinen Befehl ausser denen der Liste auf (mit Probe der Pruefung)
#F|D-100|KD-7,GD-4|kein-fund+ausgabe|Nicht-Text|eine leere Datei geht nicht an das Gate, wird gezaehlt und genannt
#F|D-101|KD-7,GD-4|kein-fund+ausgabe|Nicht-Text|eine binaere Datei mit verbotenem Muster geht nicht an das Gate, wird gezaehlt und genannt (Durchlass GD-4)
#F|D-102|KD-7|kein-fund+ausgabe|Nicht-Text|eine Datei aus einem Zeilenumbruch ist Text, nicht leer und nicht binaer
#F|D-103|KD-7,GP-5|fund|Nicht-Text|eine versionierte Verknuepfung unter backend/ ist ein Fund
#F|D-104|KD-7|fund|Nicht-Text|eine unversionierte Verknuepfung auf ein Verzeichnis unter prototype/ ist ein Fund
#F|D-105|KD-7|fund|Nicht-Text|ein Untermodul (Eintrag 160000 im Index) unter backend/ ist ein Fund
#F|D-106|KD-7|fund|Nicht-Text|ein verschachteltes Repository unter backend/ ist ein Fund
#F|D-107|KD-7|kein-fund+ausgabe|Nicht-Text|ein Fifo an der Stelle einer versionierten Datei wird genannt und nie geoeffnet
#F|D-108|KD-7|kein-fund+ausgabe|Nicht-Text|eine versionierte Datei, die auf der Platte fehlt, wird genannt
#F|D-109|KD-7|fund|Nicht-Text|eine Verknuepfung ohne Ziel ist eine Verknuepfung (Fund), keine fehlende Datei
#F|D-110|KD-6|lage-c|Gate|.claude ist eine Verknuepfung: die Verknuepfung liegt auf dem Weg zum Gate
#F|D-111|KD-3,KD-6|lage-c+funde|Auswahl|die Zahl der gelesenen Eintraege weicht von der gezaehlten ab (grep -zc liefert 999): ein Lesefehler wirkt nicht wie das Ende der Liste, Lage C
#F|D-112|KD-6|kein-fund+ausgabe|Umfeld|CDPATH des Aufrufers aendert die Wurzel bei relativem Aufruf (bash scripts/prototyp-trennung-pruefen.sh, wie make ihn macht) nicht: Urteil wie ohne CDPATH, keine Lage C, kein Pfad auf der Standardausgabe
#F|D-120|GD-1|kein-fund+ausgabe|Grenze|Bezuege ohne Importwort (COPY prototype/, Volume, file:) erkennt das Gate nicht (Durchlass GD-1)
#F|D-121|GD-3|kein-fund+ausgabe|Grenze|Verknuepfung ausserhalb der Wurzeln, ueber die ein Import fuehrt, ist nicht Gegenstand (Durchlass GD-3)
#F|D-122|GP-1,GP-2,GP-6|kein-fund+ausgabe|Grenzen des Gates|Alias (GP-1), Wurzelpfad in Richtung 2 (GP-2), Python-Form mit generischem Namen in Richtung 2 (GP-6): Durchlass
#F|D-140|KD-8|schreibfrei|Kettengrundsatz|Baum mit Funden, leerer und binaerer Datei, Verknuepfung: nach dem Lauf wie davor
#F|D-141|KD-8,KD-6|kein-fund+ausgabe|Kettengrundsatz|das Gate arbeitet in der Ablage des Skripts, nicht im TMPDIR des Aufrufers; die Ablage ist nach dem Lauf entfernt
#F|D-150|KD-9,KD-1,KD-2|fund|Rueckgabewerte|Fund der Richtung 1 und der Richtung 2 in einem Lauf: Rueckgabewert 2, "Befunde: 2"
#F|D-151|KD-9|gleich|Gleiche Ausgabe|zwei Laeufe mit anderem Umfeld (TZ, Spracheinstellung): gleiche Ausgabe, keine Zeit, kein Zufallswert
#F|D-152|KD-9,KD-5|lage-c+funde|Gesamtbudget|Gesamtbudget ueberschritten (Kopie mit BUDGET_S=2): Lage C, die Funde davor stehen in derselben Ausgabe
#F|D-153|KD-8|arbeitsbaum|Kettengrundsatz|der Arbeitsbaum ist nach dem ganzen Lauf wie davor

f_D001() { grundzaehlung; ausgabe_mit "Kontrollprobe: 4 von 4"; ausgabe_mit "Befunde: 0"; }
f_D002() { datei backend/src/paket/modul.py 'from prototype import helper' 'def f():' '    return 1'
  erwarte backend/src/paket/modul.py "Richtung 1" "'backend/src/paket/modul.py' ist Produktionscode und importiert aus 'prototype/'"; }
f_D003() { datei backend/src/paket/ui.js 'import h from "../../prototype/helper";'; vers backend/src/paket/ui.js
  erwarte backend/src/paket/ui.js "Richtung 1" "Produktionscode -> Prototyp"; }
f_D004() { datei frontend/src/app.js 'const h = require("../prototype/helper");'; erwarte frontend/src/app.js "Richtung 1"; }
f_D005() { datei deploy/index.html '<script src="../prototype/x.js"></script>'; erwarte deploy/index.html "Richtung 1"; }
f_D006() { datei backend/src/paket/modul.py 'from prototypes import helper' 'import es_prototype_alt' '# der Prototyp wurde ersetzt' 'import h from "./prototypes/helper";' 'def f():' '    return 1'
  grundzaehlung; }
f_D007() { datei backend/LIESMICH.md 'import h from "../prototype/helper";'; geprueft 6 2 4 0 0 0 0 0; }
f_D008() { datei backend/dyn.py 'x = __import__("prototype")'; erwarte backend/dyn.py "Richtung 1"; }
f_D010() { datei prototype/app.js 'import h from "../backend/helper";'
  erwarte prototype/app.js "Richtung 2" "'prototype/app.js' liegt im Prototyp und importiert aus dem Produktionscode"; }
f_D011() { datei prototype/seite.html '<script src="../backend/static/x.js"></script>'; erwarte prototype/seite.html "Richtung 2"; }
f_D012() { datei prototype/modell.py 'from backend import x'; erwarte prototype/modell.py "Richtung 2"; }
f_D013() { datei prototype/app.js 'import h from "./lokal/helper";'; grundzaehlung; }
f_D020() { datei backend/neu.py 'from prototype import helper'; erwarte backend/neu.py "Richtung 1"; }
f_D021() { datei backend/zwischen.log 'from prototype import helper'; grundzaehlung; }
f_D022() { datei "backend/mit leerzeichen.py" 'from prototype import helper'; erwarte "backend/mit leerzeichen.py" "Richtung 1" "'backend/mit leerzeichen.py' ist Produktionscode"; }
f_D023() { local n=$'backend/mit\numbruch.py'; datei "$n" 'from prototype import helper'; erwarte "$n" "Richtung 1" "BLOCKIERT (Projektauftrag 5.6): Richtung 1"; }
f_D024() { datei scripts/x.js 'import h from "../prototype/helper";'; datei tools/x.js 'import h from "../prototype/helper";'
  datei Makefile 'x = import h from "../prototype/helper";'; datei .github/workflows/x.js 'import h from "../prototype/helper";'; grundzaehlung; }
f_D025() { local n=$'backend/uebung_\xc3\xa4.py'; roh "$n" 'caf\xe9 = 1\nfrom prototype import helper\n'; erwarte "$n" "Richtung 1"; }
f_D026() { datei prototypes/x.js 'import h from "../prototype/helper";'; datei prototype-alt/x.js 'import h from "../prototype/helper";'
  datei backend2/x.js 'import h from "../prototype/helper";'; grundzaehlung; }

f_D040() { gate_attrappe 0 0 0 0 0; lc kontrollprobe; ausgabe_mit "Kontrollprobe: 2 von 4"; }
f_D041() { gate_attrappe R1 R1 R1 R1 R1; lc kontrollprobe; ausgabe_mit "Kontrollprobe: 1 von 4"; }
f_D042() { gate_attrappe R1 0 0 0 ECHT; lc kontrollprobe; ausgabe_mit "Kontrollprobe: 3 von 4"; lc_mit "Ereignis 3"; }
f_D043() { gate_attrappe 0 0 R2 0 ECHT; lc kontrollprobe; ausgabe_mit "Kontrollprobe: 3 von 4"; lc_mit "Ereignis 1"; }
f_D044() { gate_attrappe R2 0 R1 0 ECHT; lc kontrollprobe; ausgabe_mit "Kontrollprobe: 2 von 4"; }
f_D045() { gate_attrappe R1 R1 R2 0 ECHT; lc kontrollprobe; ausgabe_mit "Kontrollprobe: 3 von 4"; lc_mit "Ereignis 2"; }
f_D046() { gate_attrappe R1 0 R2 R2 ECHT; lc kontrollprobe; ausgabe_mit "Kontrollprobe: 3 von 4"; lc_mit "Ereignis 4"; }
f_D047() { gate_attrappe R1 0err R2 0 ECHT; lc kontrollprobe; ausgabe_mit "Kontrollprobe: 3 von 4"; lc_mit "Ereignis 2"; }
f_D048() { gate_attrappe X2 0 R2 0 ECHT; lc kontrollprobe; ausgabe_mit "Kontrollprobe: 3 von 4"; lc_mit "Ereignis 1"; }
f_D049() { gate_attrappe_echt; grundzaehlung; ausgabe_mit "Kontrollprobe: 4 von 4"; }

# Fund (echtes Gate ueber die Attrappe) und eine Datei mit der Antwort ihres Namens in derselben Ausgabe: Lage C geht vor
kd5_datei() { # kd5_datei <name> <teil der Meldung>
  gate_attrappe_echt
  datei backend/fund_r1.py 'from prototype import helper'
  datei "backend/$1" 'x = 1'
  erwarte backend/fund_r1.py "Richtung 1"
  lc gate-antwort; lc_mit "backend/$1"; lc_mit "$2"
}
f_D060() { kd5_datei x_rc1.py "Rueckgabewert 1 ohne Sperrmeldung"; }
f_D061() { kd5_datei x_rc2leer.py "Rueckgabewert 2 ohne Sperrmeldung"; }
f_D062() { kd5_datei x_rc2text.py "Pruefung nicht moeglich"; }
f_D063() { kd5_datei x_rc137.py "Rueckgabewert 137 ohne Sperrmeldung"; }
f_D064() { kd5_datei x_rc124.py "Rueckgabewert 124 ohne Sperrmeldung"; }
f_D065() { kd5_datei x_rc0text.py "Rueckgabewert 0, aber das Gate hat Text ausgegeben"; }
f_D066() { kd5_datei x_marke_shell.py "Shell-Befehl"; }
# echtes Gate; ein Ersatz fuer grep im Suchpfad faellt bei ZZ-AUSFALL im Inhalt aus (Rueckgabewert 2) und haengt bei ZZ-HAENGT
grep_ersatz() {
  kasten $KASTEN_VOLL sleep
  kasten_ersatz grep <<GREPERSATZ
#!/usr/bin/env bash
in=\$(cat)
case "\$in" in
  *ZZ-AUSFALL*) exit 2 ;;
  *ZZ-HAENGT*) sleep 40; exit 2 ;;
esac
printf '%s' "\$in" | exec $GREP_BIN "\$@"
GREPERSATZ
  env_zusatz "PATH=$KASTEN"
}
f_D067() { grep_ersatz; datei backend/aus.py 'import foo  # ZZ-AUSFALL'; lc gate-antwort; lc_mit "backend/aus.py"; lc_mit "Pruefung nicht moeglich"; }
f_D068() { grep_ersatz; datei backend/haengt.py 'import foo  # ZZ-HAENGT'; lc gate-antwort; lc_mit "backend/haengt.py"; lc_mit "Zeitgrenze von 12 s"; }

f_D070() { ohne_werkzeug bash; }
f_D071() { ohne_werkzeug git; }
f_D072() { ohne_werkzeug jq; }
f_D073() { ohne_werkzeug grep; }
f_D074() { ohne_werkzeug timeout; }
f_D075() { ohne_werkzeug mktemp; }
f_D076() { ohne_werkzeug mkdir; }
f_D077() { ohne_werkzeug env; }
f_D078() { ohne_werkzeug rm; }
f_D079() { ohne_werkzeug cat; }
f_D080() { ohne_werkzeug sed; }
f_D081() { ohne_werkzeug tr; }
f_D082() { ohne_werkzeug cut; }
f_D083() { ohne_werkzeug wc; }
f_D084() { ARGS=(unerwartet); lc aufruf; }
f_D085() { rm -rf "${BAUM:?}/.git"; lc git-arbeitsbaum; }
f_D086() { SKRIPT_ORT="unter/scripts/prototyp-trennung-pruefen.sh"; lc git-arbeitsbaum; lc_mit "nicht die oberste Ebene"; }
f_D087() { rm -f "${BAUM:?}/.claude/hooks/block-prototype-import.sh"; lc gate; lc_mit "fehlt"; }
f_D088() { als_root_nicht; chmod 000 "$BAUM/.claude/hooks/block-prototype-import.sh"; lc gate; lc_mit "nicht lesbar"; }
f_D089() { rm -f "${BAUM:?}/.claude/hooks/block-prototype-import.sh"; ln -s "$GATE_ECHT" "$BAUM/.claude/hooks/block-prototype-import.sh" || herstellung_fehler "Verknuepfung"
  lc gate-verknuepfung; }
f_D090() { fremdes_repo; CWD_WAHL="$FALL/fremd"; grundzaehlung; ausgabe_mit "Kontrollprobe: 4 von 4"; }
f_D091() { fremdes_repo; datei backend/src/paket/modul.py 'from prototype import helper'
  env_zusatz "GIT_DIR=$FALL/fremd/.git"; env_zusatz "GIT_WORK_TREE=$FALL/fremd"; env_zusatz "GIT_INDEX_FILE=$FALL/fremd/.git/index"
  erwarte backend/src/paket/modul.py "Richtung 1"; }
f_D092() { mkdir -p "$FALL/tmpa" "$FALL/homa" || herstellung_fehler "Verzeichnisse"
  datei backend/src/paket/modul.py 'from prototype import helper'
  env_zusatz "CLAUDE_PROJECT_DIR=/anderswo"; env_zusatz "TMPDIR=$FALL/tmpa"; env_zusatz "HOME=$FALL/homa"
  erwarte backend/src/paket/modul.py "Richtung 1"; }
f_D093() { mkdir -p "$FALL/hg" || herstellung_fehler "hg"
  printf '*.py\n' > "$FALL/hg/ausschluss" || herstellung_fehler "Ausschlussliste"
  printf '[core]\n\texcludesFile = %s\n' "$FALL/hg/ausschluss" > "$FALL/hg/.gitconfig" || herstellung_fehler "gitconfig"
  datei backend/neu.py 'from prototype import helper'
  env_zusatz "HOME=$FALL/hg"; env_zusatz "XDG_CONFIG_HOME=$FALL/hg"; env_zusatz "GIT_CONFIG_GLOBAL=$FALL/hg/.gitconfig"
  erwarte backend/neu.py "Richtung 1"; }
f_D094() { mkdir -p "$BAUM/tmpin" || herstellung_fehler "tmpin"; env_zusatz "TMPDIR=$BAUM/tmpin"; lc ablage; lc_mit "Arbeitsbaum"; }
f_D095() { env_zusatz "TMPDIR=$FALL/gibt-es-nicht"; lc ablage; lc_mit "mktemp -d schlug fehl"; }
f_D096() { printf 'kaputt' > "$BAUM/.git/index" || herstellung_fehler "Index"; lc git-liste; ausgabe_mit "Kontrollprobe: 4 von 4"; }
f_D097() { als_root_nicht; datei backend/zu.py 'x = 1'; chmod 000 "$BAUM/backend/zu.py"; lc datei; lc_mit "backend/zu.py"; lc_mit "nicht lesbar"; }
f_D098() { STAT_SOLL="die Werkzeugliste im Kopfkommentar und die im Code nennen dieselben Werkzeuge"
  local kopf code
  kopf=$(sed -n '/^# WERKZEUGE (geschlossene Liste/{n;p;q}' "$PRUEFER" | sed -E 's/^#[[:space:]]+//; s/\..*$//; s/,//g' | tr ' ' '\n' | sort -u | tr '\n' ' ')
  code=$(sed -n 's/^WERKZEUGE="\(.*\)"$/\1/p' "$PRUEFER" | tr ' ' '\n' | sort -u | tr '\n' ' ')
  STAT_IST="Kopfkommentar: ${kopf:-leer}; Code: ${code:-leer}"
  if [ -n "$kopf" ] && [ "$kopf" = "$code" ]; then STAT_OK=1; fi; }
f_D099() { STAT_SOLL="ausserhalb von Kommentarzeilen ruft das Skript keinen Befehl ausser denen der Liste auf"
  local code muster treffer probe
  code=$(code_text | sed -E "s/\"[^\"]*\"//g; s/'[^']*'//g")
  muster='(^|[^A-Za-z0-9_./$-])(sort|uniq|head|tail|awk|find|xargs|readlink|realpath|dirname|basename|date|sleep|ln|cp|mv|chmod|touch|ls|stat|diff|cmp|comm|paste|tee|sha256sum|python3?|perl|ruby|node)([[:space:]]|$)'
  treffer=$(printf '%s\n' "$code" | grep -E -- "$muster" | head -n 3 | tr '\n' ' ')
  probe=$(printf '%s\nsort -u x\n' "$code" | grep -cE -- "$muster")
  STAT_IST="Treffer: ${treffer:-keine}; Probe der Pruefung: $probe Treffer"
  if [ -z "$treffer" ] && [ "$probe" -ge 1 ]; then STAT_OK=1; fi; }

f_D100() { datei backend/leer.py; ausgabe_mit "Leer: backend/leer.py"; geprueft 5 2 3 0 0 1 0 0; }
f_D101() { roh backend/daten.bin 'import h from "../prototype/h";\n\000\n'; ausgabe_mit "Binaer: backend/daten.bin"; geprueft 5 2 3 0 0 0 1 0; }
f_D102() { roh backend/nur_umbruch.py '\n'; geprueft 6 2 4 0 0 0 0 0; ausgabe_ohne "Leer: backend/nur_umbruch.py"; ausgabe_ohne "Binaer: backend/nur_umbruch.py"; }
f_D103() { verknuepfung backend/verweis.py ../prototype/app.js; vers backend/verweis.py; erwarte backend/verweis.py Verknuepfung "symbolische Verknuepfung"; }
f_D104() { verknuepfung prototype/zu_backend ../backend; erwarte prototype/zu_backend Verknuepfung; }
f_D105() { mkdir -p "$BAUM/backend/sub" || herstellung_fehler "backend/sub"
  local h; h=$(gitg -C "$BAUM" rev-parse HEAD) || herstellung_fehler "HEAD"
  gitg -C "$BAUM" update-index --add --cacheinfo "160000,$h,backend/sub" || herstellung_fehler "Untermodul"
  erwarte backend/sub Untermodul "Untermodul oder verschachteltes Repository"; }
f_D106() { mkdir -p "$BAUM/backend/nest" && gitg -C "$BAUM/backend/nest" init -q && printf 'x\n' > "$BAUM/backend/nest/a.py" || herstellung_fehler "verschachteltes Repository"
  erwarte backend/nest/ Untermodul; }
f_D107() { rm -f "${BAUM:?}/backend/src/paket/modul.py"; mkfifo "$BAUM/backend/src/paket/modul.py" || herstellung_fehler "mkfifo"
  zeitgrenze 20; ausgabe_mit "Nicht-Datei: backend/src/paket/modul.py (weder Datei noch Verknuepfung noch Verzeichnis)"; geprueft 4 2 2 0 0 0 0 1; }
f_D108() { rm -f "${BAUM:?}/backend/src/paket/modul.py"; ausgabe_mit "Nicht-Datei: backend/src/paket/modul.py (fehlt auf der Platte, nur im Index)"; geprueft 4 2 2 0 0 0 0 1; }
f_D109() { verknuepfung backend/ohne_ziel.py /gibt/es/nicht/x; erwarte backend/ohne_ziel.py Verknuepfung; }
f_D110() { mv "$BAUM/.claude" "$FALL/claude-echt" || herstellung_fehler "mv .claude"; ln -s "$FALL/claude-echt" "$BAUM/.claude" || herstellung_fehler "ln .claude"; lc gate-verknuepfung; }

f_D111() { kasten $KASTEN_VOLL
  kasten_ersatz grep <<GREPZAEHLT
#!/usr/bin/env bash
case "\$1" in -zc) echo 999; exit 0 ;; esac
exec $GREP_BIN "\$@"
GREPZAEHLT
  env_zusatz "PATH=$KASTEN"; lc liste; lc_mit "gelesen wurden 5"; lc_mit "999"; }
f_D112() { AUFRUF_REL=1; CWD_WAHL="$BAUM"; mkdir -p "$FALL/lockvogel/scripts" || herstellung_fehler "lockvogel"; env_zusatz "CDPATH=$FALL/lockvogel"; grundzaehlung; ausgabe_mit "Kontrollprobe: 4 von 4"; ausgabe_ohne "$FALL/lockvogel"; }
f_D120() { datei deploy/Dockerfile 'FROM scratch' 'COPY prototype/ /app/prototype/'
  datei deploy/compose.yml 'services:' '  a:' '    volumes:' '      - ./prototype:/app/prototype'
  datei frontend/package.json '{"dependencies": {"x": "file:../prototype"}}'
  geprueft 8 2 3 1 2 0 0 0; }
f_D121() { verknuepfung scripts/verweis ../prototype; datei backend/src/paket/ui.js 'import h from "../../scripts/verweis/helper";'; geprueft 6 2 4 0 0 0 0 0; }
f_D122() { datei backend/alias.js 'import h from "@proto/helper";'; datei prototype/abs.js 'import h from "/backend/x";'; datei prototype/modul.py 'from lib import helper'
  geprueft 8 4 4 0 0 0 0 0; }

f_D140() { datei backend/neu.py 'from prototype import helper'; datei backend/leer.py; roh backend/daten.bin 'x\000y\n'
  verknuepfung backend/verweis.py ../prototype/app.js; datei prototype/neu.js 'import h from "../backend/x";'; }
f_D141() { mkdir -p "$FALL/tmpx" || herstellung_fehler "tmpx"; : > "$FALL/mktemp.log" || herstellung_fehler "Protokoll"
  kasten $KASTEN_VOLL
  kasten_ersatz mktemp <<MKTEMPERSATZ
#!/usr/bin/env bash
printf 'TMPDIR=%s\n' "\${TMPDIR-<ungesetzt>}" >> "$FALL/mktemp.log"
exec $MKTEMP_BIN "\$@"
MKTEMPERSATZ
  env_zusatz "PATH=$KASTEN"; env_zusatz "TMPDIR=$FALL/tmpx"
  grundzaehlung; ausgabe_mit "Kontrollprobe: 4 von 4"; nach_lauf nach_D141; }
nach_D141() {
  local n=0 zeile ok=0 schlecht=0 arr
  shopt -s nullglob dotglob; arr=("$FALL/tmpx"/*); shopt -u nullglob dotglob
  if [ "${#arr[@]}" -ne 0 ]; then ERG=GEFALLEN; DETAIL+=("die Ablage ist nach dem Lauf nicht entfernt (${#arr[@]} Eintraege im TMPDIR des Aufrufers)"); fi
  while IFS= read -r zeile || [ -n "$zeile" ]; do
    n=$((n + 1))
    if [ "$n" -eq 1 ]; then
      if [ "$zeile" != "TMPDIR=$FALL/tmpx" ]; then ERG=GEFALLEN; DETAIL+=("der erste Aufruf von mktemp (die Ablage des Skripts) lief nicht im TMPDIR des Aufrufers: $zeile"); fi
      continue
    fi
    case "$zeile" in
      "TMPDIR=$FALL/tmpx/tmp."*/tmp) ok=$((ok + 1)) ;;
      *) schlecht=$((schlecht + 1)); DETAIL+=("Aufruf von mktemp durch das Gate mit anderem TMPDIR: $zeile") ;;
    esac
  done < "$FALL/mktemp.log"
  if [ "$schlecht" -ne 0 ] || [ "$ok" -lt 9 ]; then ERG=GEFALLEN; DETAIL+=("erwartet: mindestens 9 Aufrufe des Gates (vier der Kontrollprobe, fuenf Textdateien) im TMPDIR der Ablage, gelesen: $ok richtig, $schlecht falsch"); fi
  IST="$IST; mktemp-Aufrufe $n, davon des Gates $ok richtig und $schlecht falsch"
}
f_D150() { datei backend/src/paket/modul.py 'from prototype import helper' 'def f():' '    return 1'; datei prototype/app.js 'import h from "../backend/helper";'
  erwarte backend/src/paket/modul.py "Richtung 1"; erwarte prototype/app.js "Richtung 2"; }
f_D151() { datei backend/src/paket/modul.py 'from prototype import helper' 'def f():' '    return 1'; datei backend/leer.py
  erwarte backend/src/paket/modul.py "Richtung 1"; ausgabe_mit "Kontrollprobe: 4 von 4"
  env_zusatz2 "TZ=Asia/Tokyo"; env_zusatz2 "LC_ALL=C.UTF-8"; }
f_D152() { gate_attrappe_echt; datei backend/a_fund.py 'from prototype import helper'; datei backend/b_x_langsam.py 'x = 1'; datei backend/c_x_langsam.py 'x = 2'
  skript_sed 's~^BUDGET_S=120$~BUDGET_S=2~'
  erwarte backend/a_fund.py "Richtung 1"; lc gesamtbudget; lc_mit "Gesamtbudget"; }
f_D153() { :; }

# =============================================================================
# 11. Ausfuehrung eines Falls
# =============================================================================
declare -A FL_KLASSEN FL_SOLL FL_HERKUNFT FL_GEGENSTAND ERGEBNIS GRP_N GRP_B GRP_G GRP_H
FL_ORDER=(); GEFALLENE=()
ANZ_B=0; ANZ_G=0; ANZ_H=0

fall_ausfuehren() { # fall_ausfuehren <kennung>
  local k="$1" soll klassen gegen fn out err cwd sollt grp vor nach rc1 rc2 d a b s
  soll="${FL_SOLL[$k]}"; klassen="${FL_KLASSEN[$k]}"; gegen="${FL_GEGENSTAND[$k]}"; fn="f_${k//-/}"
  FALL_K="$k"
  FALL="$T/faelle/$k"; BAUM="$FALL/baum"
  fall_zuruecksetzen
  ERG="BESTANDEN"
  mkdir -p "$FALL" && cp -a "$GRUND" "$BAUM" || herstellung_fehler "Kopie des Grundbaums"
  "$fn"
  out="$FALL/aus.txt"; err="$FALL/fehler.txt"
  case "$soll" in
    fund) sollt="Fund, ${#ERW[@]} Zeile(n)" ;;
    kein-fund) sollt="kein Fund" ;;
    kein-fund+ausgabe) sollt="kein Fund, Aussage ueber die Standardausgabe" ;;
    lage-c) sollt="Lage C, Kennung $LC_KENNUNG" ;;
    lage-c+funde) sollt="Lage C, Kennung $LC_KENNUNG, ${#ERW[@]} Fund(e) in derselben Ausgabe" ;;
    gleich) sollt="zwei Laeufe mit gleicher Ausgabe" ;;
    schreibfrei) sollt="Baum vor und nach dem Lauf gleich" ;;
    statisch) sollt="$STAT_SOLL" ;;
    arbeitsbaum) sollt="Arbeitsbaum vor und nach dem ganzen Lauf gleich" ;;
    *) herstellung_fehler "unbekannte Soll-Art $soll" ;;
  esac
  if [ -n "$NH_GRUND" ]; then
    ERG="NICHT_HERSTELLBAR"; IST="nicht herstellbar: $NH_GRUND"
  else
    if [ "$soll" != statisch ] && [ "$soll" != arbeitsbaum ]; then
      mkdir -p "${BAUM}/${SKRIPT_ORT%/*}" && cp "$PRUEFER" "$BAUM/$SKRIPT_ORT" || herstellung_fehler "Kopie des gepruefen Skripts nach $SKRIPT_ORT"
      if [ -n "$SKRIPT_SED" ]; then
        sed -E --sandbox -e "$SKRIPT_SED" "$PRUEFER" > "$BAUM/$SKRIPT_ORT" || herstellung_fehler "Abwandlung des gepruefen Skripts"
        if cmp -s "$PRUEFER" "$BAUM/$SKRIPT_ORT"; then herstellung_fehler "die Abwandlung des gepruefen Skripts aendert nichts (Anker fehlt)"; fi
      fi
    fi
    cwd="${CWD_WAHL:-$BAUM}"
    case "$soll" in
      fund|kein-fund|kein-fund+ausgabe)
        lauf_pruefer "$cwd" "$out" "$err" "${ENV_ZUSATZ[@]+"${ENV_ZUSATZ[@]}"}"
        bewerte_funde "$soll" "$out" "$err" "$LAUF_RC"
        ausgabe_pruefen "$out"
        ;;
      lage-c)
        lauf_pruefer "$cwd" "$out" "$err" "${ENV_ZUSATZ[@]+"${ENV_ZUSATZ[@]}"}"
        bewerte_lagec "$out" "$err" "$LAUF_RC"
        ausgabe_pruefen "$out"
        ;;
      lage-c+funde)
        lauf_pruefer "$cwd" "$out" "$err" "${ENV_ZUSATZ[@]+"${ENV_ZUSATZ[@]}"}"
        bewerte_lagec_funde "$out" "$err" "$LAUF_RC"
        ausgabe_pruefen "$out"
        ;;
      gleich)
        if [ "${#ENV_ZUSATZ2[@]}" -eq 0 ]; then ENV_ZUSATZ2=("${ENV_ZUSATZ[@]+"${ENV_ZUSATZ[@]}"}"); fi
        lauf_pruefer "$cwd" "$FALL/aus1.txt" "$FALL/fehler1.txt" "${ENV_ZUSATZ[@]+"${ENV_ZUSATZ[@]}"}"; rc1=$LAUF_RC
        lauf_pruefer "$cwd" "$FALL/aus2.txt" "$FALL/fehler2.txt" "${ENV_ZUSATZ2[@]+"${ENV_ZUSATZ2[@]}"}"; rc2=$LAUF_RC
        a=gleich; cmp -s "$FALL/aus1.txt" "$FALL/aus2.txt" || a=verschieden
        b=gleich; cmp -s "$FALL/fehler1.txt" "$FALL/fehler2.txt" || b=verschieden
        IST="Rueckgabewerte $rc1 und $rc2, Standardausgabe $a, Fehlerausgabe $b"
        if [ "$rc1" = 124 ] || [ "$rc2" = 124 ]; then ERG=GEFALLEN; DETAIL+=("Zeitgrenze von $ZEITGRENZE s ueberschritten"); fi
        if [ ! -s "$FALL/aus1.txt" ] && [ ! -s "$FALL/fehler1.txt" ]; then ERG=GEFALLEN; DETAIL+=("der erste Lauf hat keine Ausgabe erzeugt: Gleichheit allein sagt dann nichts"); fi
        if [ "$rc1" != "$rc2" ]; then ERG=GEFALLEN; DETAIL+=("Rueckgabewerte verschieden"); fi
        if [ "$a" != gleich ]; then ERG=GEFALLEN; DETAIL+=("Standardausgabe verschieden: $(cmp "$FALL/aus1.txt" "$FALL/aus2.txt" 2>&1 | head -n 1 | cut -c1-120)"); fi
        if [ "$b" != gleich ]; then ERG=GEFALLEN; DETAIL+=("Fehlerausgabe verschieden: $(cmp "$FALL/fehler1.txt" "$FALL/fehler2.txt" 2>&1 | head -n 1 | cut -c1-120)"); fi
        for s in "${AUSGABE_MIT[@]+"${AUSGABE_MIT[@]}"}"; do
          if ! grep -qxF -- "$s" "$FALL/aus1.txt"; then ERG=GEFALLEN; DETAIL+=("Standardausgabe des ersten Laufs enthaelt die Zeile nicht: $s"); fi
        done
        if [ "${#ERW[@]}" -gt 0 ]; then
          funde_lesen "$FALL/aus1.txt"
          for s in "${ERW[@]}"; do
            d=0
            for a in "${IST_FUNDE[@]+"${IST_FUNDE[@]}"}"; do
              if [ "$(feld "$a" 1)" = "$(feld "$s" 1)" ] && [ "$(feld "$a" 2)" = "$(feld "$s" 2)" ]; then d=1; fi
            done
            if [ "$d" = 0 ]; then ERG=GEFALLEN; DETAIL+=("erster Lauf ohne den Fund: $(printf '%s' "$s" | tab_sichtbar)"); fi
          done
        fi
        ;;
      schreibfrei)
        vor=$(baum_voll "$BAUM" "$BAUM") || herstellung_fehler "Zustand des Baums vorher"
        lauf_pruefer "$cwd" "$out" "$err" "${ENV_ZUSATZ[@]+"${ENV_ZUSATZ[@]}"}"
        nach=$(baum_voll "$BAUM" "$BAUM") || herstellung_fehler "Zustand des Baums nachher"
        if [ ! -s "$out" ] && [ ! -s "$err" ]; then ERG=GEFALLEN; DETAIL+=("der Lauf hat keine Ausgabe erzeugt: Unveraendertheit allein sagt dann nichts"); fi
        if [ "$vor" = "$nach" ]; then
          IST="Rueckgabewert $LAUF_RC, Baum vorher gleich nachher"
        else
          ERG=GEFALLEN; IST="Rueckgabewert $LAUF_RC, Baum nach dem Lauf veraendert"
          printf '%s\n' "$vor" > "$FALL/vor.txt"; printf '%s\n' "$nach" > "$FALL/nach.txt"
          DETAIL+=("Unterschied: $(cmp "$FALL/vor.txt" "$FALL/nach.txt" 2>&1 | head -n 1 | cut -c1-120)")
        fi
        ;;
      statisch)
        IST="$STAT_IST"
        if [ "$STAT_OK" != 1 ]; then ERG=GEFALLEN; fi
        ;;
      arbeitsbaum)
        nach=$(schnappschuss "$ARBEITSBAUM") || herstellung_fehler "Zustand des Arbeitsbaums nachher"
        if [ "$SCHNAPP_VORHER" = "$nach" ]; then
          IST="Arbeitsbaum vor und nach dem Lauf gleich"
        else
          ERG=GEFALLEN; IST="Arbeitsbaum nach dem Lauf veraendert"
          printf '%s\n' "$SCHNAPP_VORHER" > "$T/arb-vor.txt"; printf '%s\n' "$nach" > "$T/arb-nach.txt"
          DETAIL+=("Unterschied: $(cmp "$T/arb-vor.txt" "$T/arb-nach.txt" 2>&1 | head -n 1 | cut -c1-120)")
        fi
        ;;
    esac
    if [ -n "$NACH_FN" ]; then "$NACH_FN"; fi
  fi
  ERGEBNIS[$k]="$ERG"
  grp="${klassen:0:2}"
  GRP_N[$grp]=$(( ${GRP_N[$grp]:-0} + 1 ))
  case "$ERG" in
    BESTANDEN) ANZ_B=$((ANZ_B + 1)); GRP_B[$grp]=$(( ${GRP_B[$grp]:-0} + 1 )) ;;
    GEFALLEN) ANZ_G=$((ANZ_G + 1)); GRP_G[$grp]=$(( ${GRP_G[$grp]:-0} + 1 )); GEFALLENE+=("$k") ;;
    NICHT_HERSTELLBAR) ANZ_H=$((ANZ_H + 1)); GRP_H[$grp]=$(( ${GRP_H[$grp]:-0} + 1 )) ;;
  esac
  printf '%s [%s] %s | Soll: %s | Ist: %s | %s\n' "$k" "$klassen" "$ERG" "$sollt" "$IST" "$gegen"
  for d in "${DETAIL[@]+"${DETAIL[@]}"}"; do printf '    %s\n' "$d"; done
  chmod -R u+rwx "$FALL" >/dev/null 2>&1
  rm -rf "${FALL:?}"
}

# =============================================================================
# 12. Fallliste lesen und pruefen
# =============================================================================
fallliste_lesen() {
  local tag k kl so he ge fn
  while IFS='|' read -r tag k kl so he ge; do
    [ "$tag" = "#F" ] || continue
    [[ "$k" =~ ^D-[0-9]{3}$ ]] || lage_c_pm "Fallliste: ungueltige Kennung '$k'."
    [ -z "${FL_SOLL[$k]+x}" ] || lage_c_pm "Fallliste: Kennung $k doppelt."
    case "$so" in
      fund|kein-fund|kein-fund+ausgabe|lage-c|lage-c+funde|gleich|schreibfrei|statisch|arbeitsbaum) ;;
      *) lage_c_pm "Fallliste: unbekannte Soll-Art '$so' bei $k." ;;
    esac
    [ -n "$kl" ] && [ -n "$ge" ] || lage_c_pm "Fallliste: Klassen oder Gegenstand fehlen bei $k."
    FL_ORDER+=("$k"); FL_KLASSEN[$k]="$kl"; FL_SOLL[$k]="$so"; FL_HERKUNFT[$k]="$he"; FL_GEGENSTAND[$k]="$ge"
  done < <(grep '^#F|' "$SKRIPT_QUELLE")
  [ "${#FL_ORDER[@]}" -gt 0 ] || lage_c_pm "Fallliste: keine Zeile '#F|' im Skript gelesen."
  for k in "${FL_ORDER[@]}"; do
    declare -F "f_${k//-/}" >/dev/null || lage_c_pm "Fall $k hat keine Funktion f_${k//-/}."
  done
  while IFS= read -r fn; do
    k="D-${fn#f_D}"
    [ -n "${FL_SOLL[$k]+x}" ] || lage_c_pm "Funktion $fn hat keine Zeile in der Fallliste."
  done < <(compgen -A function | grep -E '^f_D[0-9]{3}$')
}

# =============================================================================
# 13. Deckung: Kennungen des Kopfkommentars gegen die Faelle, in beide Richtungen
# =============================================================================
deckung_pruefen() {
  DECK_ABW=0
  local k cl grp n f cls fehl anz num
  local -A IM_KOPF=() KL_ANZ=() KL_ERK=() KL_KEIN=()
  while IFS= read -r k; do
    [ -n "$k" ] && IM_KOPF[$k]=1
  done < <(kopf_kennungen)
  for f in "${FL_ORDER[@]}"; do
    IFS=',' read -ra cls <<< "${FL_KLASSEN[$f]}"
    for cl in "${cls[@]}"; do
      KL_ANZ[$cl]=$(( ${KL_ANZ[$cl]:-0} + 1 ))
      case "${FL_SOLL[$f]}" in
        fund|lage-c|lage-c+funde) KL_ERK[$cl]=$(( ${KL_ERK[$cl]:-0} + 1 )) ;;
        kein-fund*) KL_KEIN[$cl]=$(( ${KL_KEIN[$cl]:-0} + 1 )) ;;
      esac
    done
  done
  echo "--- Deckung (getrennt von der Zaehlung der Faelle)"
  for grp in KD GD; do
    n=0
    for k in "${!IM_KOPF[@]}"; do if [ "${k:0:2}" = "$grp" ]; then n=$((n + 1)); fi; done
    if [ "$n" -gt 0 ]; then
      echo "$PM: Deckung: Gruppe $grp: $n Kennungen im Kopfkommentar des gepruefen Skripts"
    else
      echo "$PM: Deckung ABWEICHUNG: Gruppe $grp ohne Kennung im Kopfkommentar des gepruefen Skripts"
      DECK_ABW=$((DECK_ABW + 1))
    fi
  done
  fehl=""
  while IFS= read -r k; do
    [ -n "$k" ] || continue
    if [ "${KL_ANZ[$k]:-0}" -eq 0 ]; then fehl="$fehl $k"; DECK_ABW=$((DECK_ABW + 1)); fi
    if [ "${k:0:2}" = "KD" ]; then
      num="${k:3:1}"
      if [ "$num" -le 7 ] && [ "${KL_ANZ[$k]:-0}" -gt 0 ]; then
        if [ "${KL_ERK[$k]:-0}" -eq 0 ]; then echo "$PM: Deckung ABWEICHUNG: $k ohne Fall, der den Mangel erkennt (Soll fund, lage-c oder lage-c+funde)"; DECK_ABW=$((DECK_ABW + 1)); fi
        if [ "${KL_KEIN[$k]:-0}" -eq 0 ]; then echo "$PM: Deckung ABWEICHUNG: $k ohne Fall mit Soll kein Fund"; DECK_ABW=$((DECK_ABW + 1)); fi
      fi
    fi
  done < <(printf '%s\n' "${!IM_KOPF[@]}" | sort)
  if [ -n "$fehl" ]; then echo "$PM: Deckung ABWEICHUNG: Kennungen im Kopfkommentar ohne Fall:$fehl"; fi
  fehl=""; anz=0
  while IFS= read -r cl; do
    [ -n "$cl" ] || continue
    case "$cl" in GP-*) continue ;; esac
    if [ -z "${IM_KOPF[$cl]+x}" ]; then fehl="$fehl $cl"; anz=$((anz + 1)); fi
  done < <(printf '%s\n' "${!KL_ANZ[@]}" | sort)
  if [ "$anz" -gt 0 ]; then
    echo "$PM: Deckung ABWEICHUNG: $anz Klassen, die Faelle nennen, stehen nicht im Kopfkommentar des gepruefen Skripts:$fehl"
    DECK_ABW=$((DECK_ABW + anz))
  fi
  if [ "$DECK_ABW" -eq 0 ]; then
    echo "$PM: Deckung: ohne Abweichung"
  else
    echo "$PM: Deckung: $DECK_ABW Abweichungen"
  fi
}

# =============================================================================
# 14. Modus --mutationen: Mutationsdatei lesen, Mutationen fahren, Deckung der Mutationen
# =============================================================================
MUT_N=0; MUT_ABW=0
MUT_ID=(); MUT_KL=(); MUT_ED=(); MUT_MS=(); MUT_GR=()

mutationsdatei_lesen() { # Form der Mutationsdatei: ein Fehler hier ist Lage C des Pruefmittels
  local zeile zn=0 tabs id kl ed ms gr f
  local -A gesehen=()
  if LC_ALL=C grep -q '[^[:print:][:space:]]' "$MUTATIONSDATEI"; then
    lage_c_pm "Mutationsdatei $MUTATIONSDATEI enthaelt Zeichen ausserhalb von ASCII."
  fi
  while IFS= read -r zeile || [ -n "$zeile" ]; do
    zn=$((zn + 1))
    [ -z "$zeile" ] && continue
    case "$zeile" in \#*) continue ;; esac
    tabs="${zeile//[!$TAB]/}"
    [ "${#tabs}" -eq 4 ] || lage_c_pm "Mutationsdatei Zeile $zn: genau vier Tabulatoren erwartet (Kennung, Klasse, sed-Ausdruck, Mindestsatz, Grund)."
    IFS=$'\t' read -r id kl ed ms gr <<< "$zeile"
    [[ "$id" =~ ^DM-[0-9]{3}$ ]] || lage_c_pm "Mutationsdatei Zeile $zn: Kennung '$id' ist nicht DM-nnn."
    [ -z "${gesehen[$id]+x}" ] || lage_c_pm "Mutationsdatei Zeile $zn: Kennung $id doppelt."
    gesehen[$id]=1
    [[ "$kl" =~ ^KD-[0-9]$ ]] || lage_c_pm "Mutationsdatei Zeile $zn: Klasse '$kl' ist keine Kennung KD."
    [ -n "$ed" ] && [ -n "$gr" ] || lage_c_pm "Mutationsdatei Zeile $zn: sed-Ausdruck oder Grund fehlt."
    [[ "$ms" =~ ^D-[0-9]{3}(,D-[0-9]{3})*$ ]] || lage_c_pm "Mutationsdatei Zeile $zn: Mindestsatz '$ms' ist keine Liste von Fallkennungen."
    for f in ${ms//,/ }; do
      [ -n "${FL_SOLL[$f]+x}" ] || lage_c_pm "Mutationsdatei Zeile $zn: Fall $f des Mindestsatzes steht nicht in der Fallliste."
      [ "${FL_SOLL[$f]}" != arbeitsbaum ] || lage_c_pm "Mutationsdatei Zeile $zn: Fall $f (Soll arbeitsbaum) prueft das Skript nicht und steht in keinem Mindestsatz."
    done
    MUT_ID+=("$id"); MUT_KL+=("$kl"); MUT_ED+=("$ed"); MUT_MS+=("$ms"); MUT_GR+=("$gr")
  done < "$MUTATIONSDATEI"
  MUT_N=${#MUT_ID[@]}
  [ "$MUT_N" -gt 0 ] || lage_c_pm "Mutationsdatei ohne Mutation."
}

mutationsdeckung_pruefen() { # jede Klasse KD des Kopfkommentars hat eine Mutation mit einem Fall dieser Klasse im Mindestsatz
  MUT_ABW=0
  local i f cl k fehl="" anz=0 hat
  local -A abgedeckt=()
  local -a cls
  for ((i = 0; i < MUT_N; i++)); do
    hat=0
    for f in ${MUT_MS[$i]//,/ }; do
      IFS=',' read -ra cls <<< "${FL_KLASSEN[$f]}"
      for cl in "${cls[@]}"; do
        abgedeckt[$cl]=1
        if [ "$cl" = "${MUT_KL[$i]}" ]; then hat=1; fi
      done
    done
    if [ "$hat" = 0 ]; then
      echo "$PM: Mutationsdeckung ABWEICHUNG: ${MUT_ID[$i]} nennt die Klasse ${MUT_KL[$i]}, aber kein Fall des Mindestsatzes ${MUT_MS[$i]} gehoert zu ihr"
      MUT_ABW=$((MUT_ABW + 1))
    fi
  done
  while IFS= read -r k; do
    case "${k:0:2}" in
      KD) if [ -z "${abgedeckt[$k]+x}" ]; then fehl="$fehl $k"; anz=$((anz + 1)); fi ;;
    esac
  done < <(kopf_kennungen)
  if [ "$anz" -gt 0 ]; then
    echo "$PM: Mutationsdeckung ABWEICHUNG: $anz Klassen des Kopfkommentars ohne Mutation (kein Fall der Klasse in einem Mindestsatz):$fehl"
    MUT_ABW=$((MUT_ABW + anz))
  fi
  if [ "$MUT_ABW" -eq 0 ]; then
    echo "$PM: Mutationsdeckung: jede Klasse KD hat eine Mutation, ohne Abweichung"
  else
    echo "$PM: Mutationsdeckung: $MUT_ABW Abweichungen"
  fi
}

mutationen_fahren() { # alle Mutationen gegen Kopien des Skripts; Rueckgabewert 0 nur ohne Abweichung
  local i id kl ed ms gr mut f erg offen wl n_ok=0 n_nicht=0 n_wl=0 abw=0 nach
  mkdir -p "$T/mutanten" || lage_c_pm "Verzeichnis fuer die Mutanten nicht anlegbar."
  echo "--- Mutationen ($MUT_N; je Mutation laufen nur die Faelle des Mindestsatzes gegen die Mutante)"
  for ((i = 0; i < MUT_N; i++)); do
    id="${MUT_ID[$i]}"; kl="${MUT_KL[$i]}"; ed="${MUT_ED[$i]}"; ms="${MUT_MS[$i]}"; gr="${MUT_GR[$i]}"
    mut="$T/mutanten/$id.sh"; wl=""
    if ! sed -E --sandbox -e "$ed" "$PRUEFER_ORIG" > "$mut" 2> "$T/mutanten/$id.sed"; then
      wl="sed endet mit Fehler: $(head -n 1 "$T/mutanten/$id.sed" | cut -c1-120)"
    elif cmp -s "$PRUEFER_ORIG" "$mut"; then
      wl="die Kopie ist byte-gleich mit dem Skript"
    elif ! bash -n "$mut" 2> "$T/mutanten/$id.bash"; then
      wl="bash -n verwirft die Mutante: $(head -n 1 "$T/mutanten/$id.bash" | cut -c1-120)"
    fi
    if [ -n "$wl" ]; then
      n_wl=$((n_wl + 1))
      printf '%s [%s] WIRKUNGSLOS | %s | %s\n' "$id" "$kl" "$wl" "$gr"
      continue
    fi
    PRUEFER="$mut"
    erg=ERKANNT; offen=""
    for f in ${ms//,/ }; do
      fall_ausfuehren "$f" > "$T/mutanten/$id.fall"
      if [ "${ERGEBNIS[$f]}" != GEFALLEN ]; then erg=NICHT_ERKANNT; offen="$offen $f(${ERGEBNIS[$f]})"; fi
    done
    PRUEFER="$PRUEFER_ORIG"
    if [ "$erg" = ERKANNT ]; then
      n_ok=$((n_ok + 1))
      printf '%s [%s] ERKANNT | alle Faelle des Mindestsatzes %s gefallen | %s\n' "$id" "$kl" "$ms" "$gr"
    else
      n_nicht=$((n_nicht + 1))
      printf '%s [%s] NICHT_ERKANNT | nicht gefallen:%s (Mindestsatz %s) | %s\n' "$id" "$kl" "$offen" "$ms" "$gr"
    fi
  done
  echo "--- Zusammenfassung der Mutationen"
  echo "$PM: Mutationen: $MUT_N geprueft, $n_ok erkannt, $n_nicht nicht erkannt, $n_wl wirkungslos"
  mutationsdeckung_pruefen
  nach=$(schnappschuss "$ARBEITSBAUM") || lage_c_pm "Zustand des Arbeitsbaums nicht erhebbar."
  if [ "$SCHNAPP_VORHER" = "$nach" ]; then
    echo "$PM: Arbeitsbaum vor und nach dem ganzen Lauf gleich"
  else
    echo "$PM: ABWEICHUNG: Arbeitsbaum nach dem Lauf veraendert"; abw=1
  fi
  [ "$n_nicht" -eq 0 ] && [ "$n_wl" -eq 0 ] && [ "$MUT_ABW" -eq 0 ] && [ "$abw" -eq 0 ]
}

# =============================================================================
# 15. Hauptablauf
# =============================================================================
hauptablauf() {
  local k grp rc zeit0 zeit1 zeile zeigen
  zeit0=$(date +%s)
  SCHNAPP_VORHER=$(schnappschuss "$ARBEITSBAUM") || lage_c_pm "Zustand des Arbeitsbaums nicht erhebbar."
  fallliste_lesen
  echo "$PM: Kopf -- Arbeitsbaum $ARBEITSBAUM, Commit $ARB_COMMIT, Skript $PRUEFER sha256 $PRUEFER_SHA, Gate sha256 $GATE_SHA, Mutationsdatei $MUT_SHA, Anforderung R3-Q-001, Einheit G3.3"
  grundbaum_bauen || lage_c_pm "Grundbaum nicht herstellbar (Defekt des Pruefmittels oder der Umgebung)."
  echo "$PM: Modus $MODUS; Grundbau in $GRUND"
  if [ "$MODUS" = mutationen ]; then
    mutationsdatei_lesen
    PRUEFER_ORIG="$PRUEFER"
    PRUEFER="$T/grundlinie.sh"
    cp "$PRUEFER_ORIG" "$PRUEFER" || lage_c_pm "Kopie des Skripts nicht anlegbar."
    echo "--- Grundlinie: alle ${#FL_ORDER[@]} Faelle gegen eine unveraenderte Kopie des Skripts (gezeigt werden nur Faelle, die nicht bestehen)"
    : > "$T/grundlinie.log"
    for k in "${FL_ORDER[@]}"; do fall_ausfuehren "$k" >> "$T/grundlinie.log"; done
    zeigen=0
    while IFS= read -r zeile; do
      case "$zeile" in
        D-[0-9]*) zeigen=0; case "$zeile" in *" GEFALLEN |"*|*" NICHT_HERSTELLBAR |"*) zeigen=1 ;; esac ;;
      esac
      if [ "$zeigen" = 1 ]; then printf '%s\n' "$zeile"; fi
    done < "$T/grundlinie.log"
  else
    echo "--- Faelle"
    for k in "${FL_ORDER[@]}"; do fall_ausfuehren "$k"; done
  fi
  echo "--- Zusammenfassung der Faelle"
  echo "$PM: ${#FL_ORDER[@]} Faelle: $ANZ_B bestanden, $ANZ_G gefallen, $ANZ_H nicht herstellbar"
  for grp in KD GD GP; do
    echo "$PM: Gruppe $grp: ${GRP_N[$grp]:-0} Faelle, ${GRP_B[$grp]:-0} bestanden, ${GRP_G[$grp]:-0} gefallen, ${GRP_H[$grp]:-0} nicht herstellbar"
  done
  if [ "$ANZ_G" -gt 0 ]; then
    echo "$PM: gefallene Faelle (Kennung, Klassen, Herkunft):"
    for k in "${GEFALLENE[@]}"; do echo "  $k ${FL_KLASSEN[$k]} ${FL_HERKUNFT[$k]}"; done
    echo "$PM: gefallene Faelle: ${GEFALLENE[*]}" >&2
  fi
  deckung_pruefen
  rc=0
  if [ "$ANZ_G" -gt 0 ] || [ "$DECK_ABW" -gt 0 ]; then rc=2; fi
  if [ "$MODUS" = mutationen ]; then
    if [ "$rc" != 0 ]; then
      echo "$PM: Grundlinie NICHT bestanden: kein Mutationslauf"
    else
      echo "$PM: Grundlinie bestanden"
      mutationen_fahren || rc=2
    fi
  fi
  zeit1=$(date +%s)
  echo "$PM: Rueckgabewert $rc"
  echo "$PM: Dauer $((zeit1 - zeit0)) s" >&2
  return "$rc"
}
hauptablauf
exit $?
