#!/usr/bin/env bash
# =============================================================================
# scripts/nachweise-vollstaendig-selbsttest.sh -- Pruefmittel fuer scripts/nachweise-vollstaendig.sh (Kettenschritt D12)
# =============================================================================
#
# Anforderung R3-Q-001 (das DoD-Gate stuetzt sich auf die Kette). Grundlage: ADR 0002, Abschnitt 5, Nachtrag vom 2026-10-29
# (Festlegung fuer G3), Zeilen zu D12 und "Faelle, Mutationen und Rueckgabewerte"; docs/12_Freigabe_Grundgeruest.md, Abschnitt 4,
# G3, Festlegungen 3 und 5. Muster: scripts/prototyp-trennung-pruefen-selbsttest.sh, scripts/abnahme-abgleich-selbsttest.sh und
# scripts/belege-pruefen-selbsttest.sh. Einheit G3.4.
#
# AUFRUF
#   bash scripts/nachweise-vollstaendig-selbsttest.sh [--mutationen] [--pruefer <pfad>]
#   Ohne --pruefer gilt scripts/nachweise-vollstaendig.sh DESSELBEN Baums, in dem dieses Pruefmittel liegt (der Aufrufort spielt
#   keine Rolle). --pruefer nennt ein anderes Skript (relativ zum Aufrufort), etwa eine Attrappe; im Modus --mutationen das Skript,
#   von dem die Mutanten abgeleitet werden. Der Erzeuger der Faelle ist, ausser in den Faellen mit Attrappe (KN-4, KN-5), der Code
#   des echten Erzeugers dieses Baums (scripts/nachweise-erzeugen.sh) mit der Artefaktliste des Falls.
#
# RUECKGABEWERT
#   0  alle Faelle bestanden und die Deckung ohne Abweichung ("nicht herstellbar" zaehlt weder als bestanden noch als gefallen, wird
#      gemeldet und beruehrt den Rueckgabewert nicht, GP-N1). Im Modus --mutationen zusaetzlich: jede Mutation erkannt, keine
#      wirkungslos, die Mutationsdeckung ohne Abweichung, der Arbeitsbaum nach dem Lauf unveraendert
#   2  mindestens ein Fall gefallen oder eine Abweichung der Deckung; im Modus --mutationen: die Grundlinie besteht nicht, oder eine
#      Mutation ist nicht erkannt oder wirkungslos, oder die Mutationsdeckung weicht ab, oder der Arbeitsbaum ist veraendert
#   3  Lage C des Pruefmittels: der Lauf hat nicht stattgefunden (fehlendes Werkzeug, unbekannter Parameter, fehlendes oder
#      formfehlerhaftes Skript, Erzeuger oder Mutationsdatei, kein Git-Arbeitsbaum um das Pruefmittel, ein Defekt des Pruefmittels)
#
# WERKZEUGE: bash, git, grep, sed (GNU, mit --sandbox), sort, uniq, mktemp, cp, mv, rm, mkdir, ln, chmod, cat, head, tr, cut, env,
#   timeout, cmp, sha256sum, readlink, id, date, dirname. Kein Netz, kein Python, kein uv, kein Docker.
#
# UMGEBUNG JEDES LAUFS: Das Skript laeuft unter "env -i" mit LC_ALL=C, TZ=UTC, HOME auf einem leeren Verzeichnis,
#   GIT_CONFIG_NOSYSTEM=1, GIT_CONFIG_GLOBAL=/dev/null und fester Identitaet; Zeitgrenze 60 s je Aufruf (je Fall anpassbar). Die
#   git-Aufrufe des Pruefmittels loeschen vorher die git-Variablen des Aufrufers.
#
# BAUM UND FAELLE: Ein Grundbaum je Lauf unter mktemp -d, ausserhalb des Arbeitsbaums (Aufraeumen per trap): git init, acht Dateien
#   der Sollmenge (.gitignore mit ignoriert/ und *.log, README.md, docs/a.md, docs/b.md, docs/sub/c.md, backend/src/paket/ mit zwei
#   Dateien, scripts/nachweise-erzeugen.sh), docs/leer/.gitkeep und docs/NACHWEISE.md. scripts/nachweise-erzeugen.sh ist der Code
#   des echten Erzeugers mit sieben Zeilen (sechs Dateien, davon zwei Verzeichniszeilen: docs/sub und backend/src/paket, und der
#   Erzeuger selbst); docs/NACHWEISE.md hat der Erzeuger des Baums erzeugt; alles ist committet, git status ist leer. Das gepruefte
#   Skript liegt im Baum unter scripts/nachweise-vollstaendig.sh und ist ueber .git/info/exclude ausgenommen (es wechselt je
#   Mutante). Je Fall eine Kopie des Grundbaums (cp -a), die Aenderung, eine Kopie des gepruefen Skripts und ein Lauf. Neue Dateien
#   eines Falls sind unversioniert, ausser der Fall ruft sauber auf (alles in einen Commit, git status leer). Attrappen des
#   Erzeugers (KN-4, KN-5): ein Ersatz von scripts/nachweise-erzeugen.sh, der eine vorgegebene Tabelle ablegt, vorgegebene Zeilen auf
#   die Fehlerausgabe schreibt und mit vorgegebenem Rueckgabewert endet. Ersatz-Werkzeuge im Suchpfad (git, grep, sort) simulieren
#   Ausfaelle (GP-N7).
#
# SOLL-ARTEN (Spalte 3 der Fallliste)
#   fund                Rueckgabewert 2; die Zeilen unter "=== Funde" sind genau die erwartete Menge (Zeilen FUND TAB KN-n TAB Pfad);
#                       "Befunde: n" gleich deren Zahl und letzte Zeile; die Fehlerausgabe ist leer
#   kein-fund           Rueckgabewert 0, keine Zeile unter "=== Funde", "Befunde: 0", Fehlerausgabe leer
#   kein-fund+ausgabe   wie kein-fund, dazu Aussagen ueber die Standardausgabe (ausgabe_mit, ausgabe_ohne)
#   lage-c              Rueckgabewert 3 vor dem Urteil; Fehlerausgabe mit "LAGE C -- <Kennung>:"; Standardausgabe ohne "Tabelle:",
#                       "=== Funde" und "Befunde:"
#   lage-c+funde        Rueckgabewert 3 nach dem Urteil: Lage C; die Funde stehen in derselben Standardausgabe (genau die erwartete
#                       Menge, auch keine); "Befunde: n" gleich deren Zahl
#   gleich              zwei Laeufe (mit gleichem oder verschiedenem Umfeld): Standardausgabe, Fehlerausgabe, Rueckgabewert gleich
#   schreibfrei         der Wegwerf-Baum ist nach dem Lauf wie davor, einschliesslich seines Git-Verzeichnisses
#   statisch            Aussage ueber den Text des geprueften Skripts, ohne Lauf
#   arbeitsbaum         der Arbeitsbaum ist nach dem ganzen Lauf wie davor; der Fall steht als letzter der Liste
#   Ein Fall kann nach dem Lauf eine eigene Pruefung ausfuehren (nach_lauf), die weitere Abweichungen meldet.
#
# FALLLISTE: Der Datenblock unten ("#F|"-Zeilen: Kennung|Klassen|Soll|Herkunft|Gegenstand) ist die maschinenlesbare Liste. Jede
#   Kennung hat genau eine Funktion f_N<nnn> weiter unten und umgekehrt (mechanisch geprueft). Kennungen N-nnn sind dauerhaft und
#   werden nie wiederverwendet.
#
# DECKUNG (als eigener Abschnitt der Ausgabe, nicht in der Zaehlung der Faelle): jede Kennung KN und GN im Kopfkommentar des
#   geprueften Skripts hat Faelle (KN-1 bis KN-6 und KN-9: mindestens einen mit Soll fund, lage-c oder lage-c+funde und einen mit
#   Soll kein-fund; KN-7, KN-8 und GN: mindestens einen); jede Klasse, die ein Fall nennt, steht im Kopfkommentar. Der
#   Kopfkommentar nennt die Kennungen einzeln, ohne Bereichsschreibweise.
#
# MODUS --mutationen: Mutationsdatei scripts/nachweise-vollstaendig-mutationen.txt im Verzeichnis dieses Skripts
#   Zeilenform: Kennung NM-nnn, Tabulator, Klasse (KN-Kennung), Tabulator, sed-Ausdruck (mit sed -E --sandbox auf eine Wegwerfkopie
#   des Skripts angewandt), Tabulator, Mindestsatz (Fallkennungen durch Komma), Tabulator, Grund. Zeilen mit # am Anfang und
#   Leerzeilen werden uebergangen. Nur ASCII, genau vier Tabulatoren je Zeile; eine Form, die der Modus nicht liest, ist Lage C.
#   Ablauf: (1) Grundlinie: alle Faelle und die Deckung gegen eine unveraenderte Kopie; besteht sie nicht, endet der Modus mit 2
#   ohne Mutation. (2) Je Mutation eine Kopie; ist sie byte-gleich mit dem Skript, verwirft bash -n sie oder endet sed mit einem
#   Fehler, ist die Mutation wirkungslos. (3) Erkannt ist sie, wenn jeder Fall ihres Mindestsatzes gegen die Mutante faellt; nur
#   diese Faelle laufen gegen sie. (4) Schluss: geprueft, erkannt, nicht erkannt, wirkungslos; die Mutationsdeckung (jede Klasse KN
#   des Kopfkommentars hat eine Mutation, deren Mindestsatz einen Fall dieser Klasse enthaelt); der Vergleich des Arbeitsbaums
#   vor und nach.
#
# GRENZEN DES PRUEFMITTELS
#   GP-N1  Der Fall "nicht lesbar" (N-075) ist als root nicht herstellbar; er wird gezaehlt und gemeldet, ohne Mutation.
#   GP-N2  Die Faelle mit Attrappe des Erzeugers (N-033 bis N-040, N-052 bis N-056) messen die Schnittstelle (Rueckgabewert, Zeilen der
#          Fehlerausgabe, Form der Tabelle) gegen frei gewaehlte Antworten. Dass der echte Erzeuger sie so liefert, messen N-001 (Form
#          der Tabelle), N-030 bis N-032 (Meldungen am Code des echten Erzeugers) und am echten Bestand "make nachweise".
#   GP-N3  Faelle mit Soll fund oder kein-fund messen die Fehlerausgabe nur auf "leer"; der Wortlaut der Meldungen von Lage C ist nur an
#          Kennung und Stichwort gemessen.
#   GP-N4  Der statische Fall N-091 liest den Text mit einem benannten Muster: ein Konstrukt, das das Muster nicht nennt, bleibt
#          unbemerkt; die uebrigen Zweige prueft der Static Software Tester am Code.
#   GP-N5  Die Verknuepfung (N-073) setzt ein Dateisystem mit symbolischen Verknuepfungen voraus; der Fall N-023 setzt git ab Version
#          2.31 voraus (GIT_CONFIG_COUNT), sonst "nicht herstellbar".
#   GP-N6  Die Faelle N-085 bis N-088 messen die Wirkung der Variablen des Aufrufers (GIT_DIR, GIT_WORK_TREE, GIT_INDEX_FILE,
#          Arbeitsverzeichnis, CDPATH), nicht die Liste der geloeschten Variablen. Ein Name, der aus der Liste im Skript faellt, ohne
#          dass ein Fall ihn nennt, bleibt unbemerkt. BASH_ENV des Aufrufers wirkt vor der ersten Zeile des Skripts und ist nicht
#          abwehrbar; sein Weg zu git und zum Erzeuger ist durch "env -i" geschlossen, aber ohne Fall.
#   GP-N7  Die Ersatz-Werkzeuge der Faelle N-041 und N-078 bis N-084 simulieren einen Fehler von git, grep und sort; sie messen die Reaktion
#          des Skripts, nicht einen echten Defekt. "export LC_ALL=C" und "unset CDPATH" sind nur ueber N-088 und die Sortierung
#          (N-007) mittelbar gemessen.
#
set -uo pipefail

# -----------------------------------------------------------------------------
# 0. Umfeld des Pruefmittels selbst: die git-Variablen des Aufrufers loeschen, Spracheinstellung C
# -----------------------------------------------------------------------------
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_COMMON_DIR GIT_NAMESPACE GIT_CEILING_DIRECTORIES GIT_DISCOVERY_ACROSS_FILESYSTEM GIT_SHALLOW_FILE GIT_GLOB_PATHSPECS GIT_NOGLOB_PATHSPECS GIT_LITERAL_PATHSPECS GIT_ICASE_PATHSPECS 2>/dev/null || true
unset "${!GIT_TRACE@}" 2>/dev/null || true
export LC_ALL=C

PM="nachweise-vollstaendig-selbsttest"
FALL_ZEITGRENZE_STANDARD=60
WERKZEUGE_PM="bash git grep sed sort uniq mktemp cp mv rm mkdir ln chmod cat head tr cut env timeout cmp sha256sum readlink id date dirname"
# Werkzeuge, die das gepruefte Skript und der Erzeuger aufrufen (geschlossene Liste im Kopfkommentar des Skripts); der Suchpfad der Faelle
# N-061 bis N-069 enthaelt genau sie, ausser dem einen, das fehlen soll
KASTEN_VOLL="bash git env dirname mktemp mkdir rm sort grep"

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
  PRUEFER="$ARBEITSBAUM/scripts/nachweise-vollstaendig.sh"
fi
[ -f "$PRUEFER" ] || lage_c_pm "geprueftes Skript nicht gefunden: $PRUEFER"
[ -r "$PRUEFER" ] || lage_c_pm "geprueftes Skript nicht lesbar: $PRUEFER"
ERZEUGER_ECHT="$ARBEITSBAUM/scripts/nachweise-erzeugen.sh"
[ -f "$ERZEUGER_ECHT" ] && [ -r "$ERZEUGER_ECHT" ] || lage_c_pm "der echte Erzeuger fehlt oder ist nicht lesbar: $ERZEUGER_ECHT"
ARB_COMMIT=$(git -C "$ARBEITSBAUM" rev-parse HEAD 2>/dev/null) || ARB_COMMIT="unbekannt"
PRUEFER_SHA=$(sha256sum "$PRUEFER" | cut -c1-16)
ERZ_SHA=$(sha256sum "$ERZEUGER_ECHT" | cut -c1-16)
MUTATIONSDATEI="$SKRIPT_VERZ/nachweise-vollstaendig-mutationen.txt"
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
# 7. Hilfen fuer die Fallfunktionen (f_N...): alle Pfade relativ zu $BAUM
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
erwarte() { # erwarte <klasse> <pfad> : ein erwarteter Fund (Zeile FUND TAB klasse TAB pfad); der Pfad in Anzeigeform
  anzeige_pfad "$2"
  ERW+=("FUND$TAB$1$TAB$ANZP")
}
erwarte_zahl() { FUND_ZAHL="$1"; }   # nur die Zahl der Fundzeilen messen (grosse Mengen)
ausgabe_mit() { AUSGABE_MIT+=("$1"); }
ausgabe_ohne() { AUSGABE_OHNE+=("$1"); }
lc() { LC_KENNUNG="$1"; }
lc_mit() { LC_MIT+=("$1"); }
lc_nicht() { LC_NICHT+=("$1"); }
nicht_herstellbar() { NH_GRUND="$1"; }
env_zusatz() { ENV_ZUSATZ+=("$1"); }
env_zusatz2() { ENV_ZUSATZ2+=("$1"); }
zeitgrenze() { ZEITGRENZE="$1"; }
skript_sed() { SKRIPT_SED="$1"; }
nach_lauf() { NACH_FN="$1"; }
als_root_nicht() { if [ "$(id -u)" = 0 ]; then nicht_herstellbar "als root nicht herstellbar (GP-N1)"; fi; }

# Zaehlzeilen der Ausgabe des gepruefen Skripts (Wortlaut siehe dessen Kopfkommentar)
zaehlung() { # zaehlung <tabellenzeilen> <pfade> <artefakte laut kopf> <sollmenge> <nicht committet>
  ausgabe_mit "Tabelle: $1 Zeilen, $2 Pfade, Artefakte laut Kopf $3"
  ausgabe_mit "Sollmenge: $4 Dateien (ohne .gitkeep und docs/NACHWEISE.md)"
  ausgabe_mit "Nicht committet (Hinweis, kein Fund): $5"
}
kn9() { # kn9 gleich <pfade> <artefakte> | kn9 offen <zeilen von git status>
  case "$1" in
    gleich) ausgabe_mit "KN-9: gleich -- die committete docs/NACHWEISE.md hat dieselben $2 Pfade und dieselbe Zahl der Artefakte ($3) wie die frische Liste" ;;
    offen) ausgabe_mit "KN-9: nicht beurteilt -- Arbeitsbaum nicht sauber (git status: $2 Zeile(n)); die committete Liste ist einen Commit alt" ;;
  esac
}
GRUND_PFADE=(.gitignore README.md docs/a.md docs/b.md docs/sub backend/src/paket scripts/nachweise-erzeugen.sh)
grundzaehlung() { zaehlung 7 7 7 8 0; kn9 gleich 7 7; }

# Der Erzeuger der Faelle: der Code des echten Erzeugers (Kopf bis "ARTEFAKTE=(", Fuss ab der Zeile ")") mit der Liste des Falls
ERZ_KOPF=""; ERZ_FUSS=""
erzeuger_vorlage_lesen() {
  local zeile phase=0
  while zeile=; IFS= read -r zeile || [ -n "$zeile" ]; do
    case "$phase" in
      0) ERZ_KOPF+="$zeile"$'\n'; if [ "$zeile" = "ARTEFAKTE=(" ]; then phase=1; fi ;;
      1) if [ "$zeile" = ")" ]; then ERZ_FUSS+="$zeile"$'\n'; phase=2; fi ;;
      2) ERZ_FUSS+="$zeile"$'\n' ;;
    esac
  done < "$ERZEUGER_ECHT"
  [ "$phase" = 2 ] || return 1
  return 0
}
liste() { # liste <pfad>... : scripts/nachweise-erzeugen.sh des Baums mit genau diesen Zeilen; "@<text>" ist eine Rohzeile
  local p z=""
  for p in "$@"; do
    case "$p" in
      @*) z+="${p#@}"$'\n' ;;
      *) z+="  \"Artefakt $p|$p|Beschreibung\""$'\n' ;;
    esac
  done
  printf '%s%s%s' "$ERZ_KOPF" "$z" "$ERZ_FUSS" > "$BAUM/scripts/nachweise-erzeugen.sh" || herstellung_fehler "liste"
}
sauber() { # alles in den Index und einen Commit: danach ist git status leer (Ignoriertes und das gepruefte Skript zaehlen nicht)
  gitg -C "$BAUM" add -A && gitg -C "$BAUM" commit -q -m "Fall $FALL_K" --allow-empty || herstellung_fehler "Commit des Falls"
}
neue_liste() { # docs/NACHWEISE.md des Baums mit dem Erzeuger des Baums (Standardziel) neu erzeugen; der Rueckgabewert gilt nicht
  ( cd "$BAUM" && env -i "${ENV_BASIS[@]}" "$BASH_BIN" scripts/nachweise-erzeugen.sh >/dev/null 2>&1 ) || true
}
tabelle_text() { # tabelle_text <artefakte> <pfad>... : eine Liste in der Form des Erzeugers; Zeilen nur mit Pfad, falschem Verweis, leerer Beschreibung
  local n="$1" p
  shift
  printf '# Nachweisverzeichnis\n\n| | |\n|---|---|\n| **Erzeugt durch** | `scripts/nachweise-erzeugen.sh` |\n| **Artefakte** | %s |\n\n| Artefakt | Pfad | Fester Verweis | Stand | Beschreibung |\n|---|---|---|---|---|\n' "$n"
  for p in "$@"; do printf '| Artefakt %s | `%s` | [`abc`](x) | 1999-01-01 |  |\n' "$p" "$p"; done
  printf '\n---\n'
}
committet_liste() { # committet_liste <artefakte> <pfad>... : docs/NACHWEISE.md des Baums mit diesem Inhalt (noch nicht committet)
  mkdir -p "$BAUM/docs" || herstellung_fehler "docs"
  tabelle_text "$@" > "$BAUM/docs/NACHWEISE.md" || herstellung_fehler "committet_liste"
}
erzeuger_attrappe() { # erzeuger_attrappe <rc> <tabellendatei oder -> [<zeile>...] : scripts/nachweise-erzeugen.sh des Baums = Ersatz
  local rc="$1" tab="$2" z
  shift 2
  {
    printf '#!/usr/bin/env bash\n'
    if [ "$tab" != "-" ]; then printf 'cp %q "$1"\n' "$tab"; fi
    for z in "$@"; do printf 'printf "%%s\\n" %q >&2\n' "$z"; done
    printf 'exit %s\n' "$rc"
  } > "$BAUM/scripts/nachweise-erzeugen.sh" || herstellung_fehler "Attrappe des Erzeugers"
}
git_ersatz() { # git_ersatz <unterbefehl> : Suchpfad aus allen Werkzeugen; git scheitert (Rueckgabewert 128) bei diesem Unterbefehl, sonst das echte git
  local echt
  echt=$(command -v git) || herstellung_fehler "git nicht aufloesbar"
  kasten $KASTEN_VOLL
  kasten_ersatz git <<EOS
#!/bin/sh
for a in "\$@"; do case "\$a" in $1) echo "fatal: simulierter Fehler" >&2; exit 128 ;; esac; done
exec $echt "\$@"
EOS
  env_zusatz "PATH=$KASTEN"
}
grep_ersatz() { # grep_ersatz : Suchpfad aus allen Werkzeugen; grep antwortet auf jeden Aufruf mit der Zahl 999 (Rueckgabewert 0)
  kasten $KASTEN_VOLL
  kasten_ersatz grep <<'EOS'
#!/bin/sh
echo 999
EOS
  env_zusatz "PATH=$KASTEN"
}
sort_ersatz() { # sort_ersatz fehler | erste : sort endet mit Rueckgabewert 2 beziehungsweise liefert nur die erste Zeile
  local echt kopf
  echt=$(command -v sort) || herstellung_fehler "sort nicht aufloesbar"
  kopf=$(command -v head) || herstellung_fehler "head nicht aufloesbar"
  kasten $KASTEN_VOLL
  if [ "$1" = fehler ]; then
    kasten_ersatz sort <<'EOS'
#!/bin/sh
exit 2
EOS
  else
    kasten_ersatz sort <<EOS
#!/bin/sh
$echt "\$@" | $kopf -n 1
EOS
  fi
  env_zusatz "PATH=$KASTEN"
}

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
  SKRIPT_ORT="scripts/nachweise-vollstaendig.sh"
  SKRIPT_SED=""
  NACH_FN=""
  FUND_ZAHL=""
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
  erzeuger_vorlage_lesen || return 1
  mkdir -p "$BAUM/scripts" "$BAUM/docs" || return 1
  printf 'ignoriert/\n*.log\n' > "$BAUM/.gitignore" || return 1
  printf '/scripts/nachweise-vollstaendig.sh\n' >> "$BAUM/.git/info/exclude" || return 1
  datei README.md 'Text'
  datei docs/a.md 'A'
  datei docs/b.md 'B'
  datei docs/sub/c.md 'C'
  datei docs/leer/.gitkeep
  datei backend/src/paket/__init__.py '"""Paket."""'
  datei backend/src/paket/modul.py 'def f():' '    return 1'
  liste "${GRUND_PFADE[@]}"
  gitg -C "$BAUM" add -A && gitg -C "$BAUM" commit -q -m "Grundbaum" || return 1
  neue_liste
  gitg -C "$BAUM" add -A && gitg -C "$BAUM" commit -q -m "Liste" || return 1
  [ -z "$(gitg -C "$BAUM" status --porcelain --untracked-files=all)" ] || return 1
  [ -f "$BAUM/docs/NACHWEISE.md" ] || return 1
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
vergleiche_funde() { # die gelesenen Fundzeilen (IST_FUNDE) gegen die erwartete Menge (ERW, Zeilen "FUND<TAB>KN-n<TAB>Pfad")
  local nz=${#IST_FUNDE[@]} e j found badn
  local -a benutzt
  if [ "$IST_ABSCHN" != 1 ]; then ERG=GEFALLEN; DETAIL+=("Abschnitt '=== Funde' ${IST_ABSCHN}-mal vorhanden statt einmal"); return; fi
  if [ "$IST_BEFUNDE" = x ]; then
    ERG=GEFALLEN; DETAIL+=("genau eine Zeile 'Befunde: n' erwartet, gelesen wurde keine oder mehr als eine")
  elif [ "$IST_BEFUNDE" != "$nz" ]; then
    ERG=GEFALLEN; DETAIL+=("'Befunde: $IST_BEFUNDE' ungleich der Zahl der Fundzeilen $nz")
  fi
  case "$IST_LETZTE" in "Befunde: "*) ;; *) ERG=GEFALLEN; DETAIL+=("die letzte Zeile der Standardausgabe ist nicht 'Befunde: n'") ;; esac
  if [ "$nz" -gt 0 ]; then
    badn=$(printf '%s\n' "${IST_FUNDE[@]}" | grep -cvE "^FUND${TAB}KN-[1-9]${TAB}.+\$") || true
    if [ "$badn" != 0 ]; then ERG=GEFALLEN; DETAIL+=("$badn Fundzeile(n) nicht in der Form FUND TAB KN-n TAB Pfad"); fi
  fi
  if [ "$nz" -gt 1 ]; then
    if ! printf '%s\n' "${IST_FUNDE[@]}" | sort -c 2>/dev/null; then ERG=GEFALLEN; DETAIL+=("die Fundzeilen sind nicht (Byte-)sortiert"); fi
    if [ -n "$(printf '%s\n' "${IST_FUNDE[@]}" | sort | uniq -d)" ]; then ERG=GEFALLEN; DETAIL+=("die Fundzeilen enthalten gleiche Zeilen"); fi
  fi
  if [ -n "$FUND_ZAHL" ]; then
    if [ "$nz" -ne "$FUND_ZAHL" ]; then ERG=GEFALLEN; DETAIL+=("erwartet $FUND_ZAHL Fundzeilen, gelesen $nz"); fi
    return
  fi
  benutzt=()
  for ((j = 0; j < nz; j++)); do benutzt[j]=0; done
  for e in "${ERW[@]+"${ERW[@]}"}"; do
    found=-1
    for ((j = 0; j < nz; j++)); do
      if [ "${benutzt[j]}" = 0 ] && [ "${IST_FUNDE[j]}" = "$e" ]; then found=$j; break; fi
    done
    if [ "$found" -ge 0 ]; then benutzt[found]=1; else ERG=GEFALLEN; DETAIL+=("fehlt: $(printf '%s' "$e" | tab_sichtbar)"); fi
  done
  for ((j = 0; j < nz; j++)); do
    if [ "${benutzt[j]}" = 0 ]; then ERG=GEFALLEN; DETAIL+=("zuviel: $(printf '%s' "${IST_FUNDE[j]}" | tab_sichtbar)"); fi
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

# Kennungen KN und GN aus dem Kopfkommentar des gepruefen Skripts (einzeln): eine je Zeile, sortiert, einmalig
kopf_kennungen() {
  local zeile n=0
  while IFS= read -r zeile || [ -n "$zeile" ]; do
    n=$((n + 1))
    if [ "$n" -eq 1 ]; then case "$zeile" in '#!'*) continue ;; esac; fi
    case "$zeile" in '#'*) printf '%s\n' "$zeile" ;; '') ;; *) break ;; esac
  done < "$PRUEFER" | grep -oE '\b(KN-[0-9]|GN-[0-9])\b' | sort -u
}
# Text des gepruefen Skripts ohne Kommentarzeilen und ohne Leerzeilen
code_text() { grep -vE '^[[:space:]]*(#|$)' "$PRUEFER"; }

# =============================================================================
# 10. Die Faelle: Datenblock (maschinenlesbar) und Fallfunktionen
# =============================================================================
#F|N-001|KN-1,KN-2,KN-3,KN-4,KN-5,KN-8,KN-9|kein-fund+ausgabe|Grundfall|Grundbaum mit dem Code des echten Erzeugers und sieben Zeilen: acht Dateien in der Sollmenge, alle erfasst, die committete Liste gleich der frischen, kein Fund, Zaehlzeilen
#F|N-002|KN-1,KN-9|fund|Datei ohne Zeile|neue versionierte Datei ohne Zeile bei sauberem Stand: Fund KN-1, KN-9 gleich
#F|N-003|KN-1,KN-9|fund|Datei ohne Zeile|neue unversionierte, nicht ignorierte Datei ohne Zeile: Fund KN-1, KN-9 nicht beurteilt
#F|N-004|KN-1,GN-3|kein-fund+ausgabe|Verzeichniszeile|neue Datei unter einem Verzeichnis mit Zeile ist erfasst (Durchlass, Grenze GN-3)
#F|N-005|KN-1|fund|Verzeichnisgrenze|die Zeile docs/sub deckt docs/sub2/d.md nicht: Verzeichnisse gelten als ganze Pfadsegmente
#F|N-006|KN-1|kein-fund|Verzeichniszeile|eine tief verschachtelte Datei unter docs/sub ist erfasst
#F|N-007|KN-1,KN-8|fund|Ausgabe|drei Dateien ohne Zeile in anderer Reihenfolge angelegt: Fundzeilen in Byte-Reihenfolge, Grossbuchstabe vor Kleinbuchstabe
#F|N-010|KN-2,KN-3,KN-4|fund|Zeile ohne Artefakt|Zeile fuer eine ignorierte Datei: Fund KN-2; die Meldung NICHT COMMITTET zaehlt nicht (Pfad nicht in der Sollmenge)
#F|N-011|KN-2,KN-3|fund|Zeile ohne Artefakt|Zeile fuer docs/leer/.gitkeep: ausgenommener Name, Fund KN-2
#F|N-012|KN-2|fund|Zeile ohne Artefakt|Verzeichniszeile ohne Datei der Sollmenge darunter (nur .gitkeep): Fund KN-2
#F|N-013|KN-2,KN-5|kein-fund+ausgabe|Wiederholung|derselbe gueltige Pfad in zwei Zeilen: acht Zeilen, sieben Pfade, kein Fund
#F|N-014|KN-2,KN-8|fund|Wiederholung|derselbe ungueltige Pfad in zwei Zeilen: ein Fund, nicht zwei
#F|N-020|KN-3|kein-fund+ausgabe|Ausschluss|.gitkeep in drei Verzeichnissen ohne Zeile: kein Fund
#F|N-021|KN-3|fund|Ausschluss|nur der Name .gitkeep und nur der Pfad docs/NACHWEISE.md sind ausgenommen: scripts/NACHWEISE.md und docs/.gitkeep2 sind Funde
#F|N-022|KN-3,GN-4|kein-fund+ausgabe|Ignoriertes|ignorierte Dateien ohne Zeile sind nicht Gegenstand (Durchlass, Grenze GN-4)
#F|N-023|KN-3,KN-6|fund|Umfeld|eine globale Ausschlussliste des Aufrufers (GIT_CONFIG_COUNT) aendert die Sollmenge nicht
#F|N-024|KN-3|fund|Name|Name mit Leerzeichen und Umlaut ohne Zeile: Fund mit dem Pfad wortgleich
#F|N-025|KN-3,KN-8|fund|Name|Name mit Zeilenumbruch ohne Zeile: Fund, der Pfad in der Ausgabe als Folge geschrieben
#F|N-026|KN-3,KN-5|kein-fund+ausgabe|Name|derselbe Name mit Zeile: gelesen, kein Fund, ein Hinweis NICHT COMMITTET
#F|N-030|KN-4|fund|Erzeuger|Zeile fuer eine nicht vorhandene Datei: der Erzeuger meldet FEHLT, Fund KN-4; die Tabelle hat keine Zeile dafuer, die Zahl im Kopf zaehlt sie
#F|N-031|KN-4|kein-fund+ausgabe|Erzeuger|unversionierte Datei mit Zeile: NICHT COMMITTET ist ein Hinweis mit Zahl und kein Fund
#F|N-032|KN-4|kein-fund+ausgabe|Erzeuger|NICHT COMMITTET fuer eine Verzeichniszeile mit einer Datei der Sollmenge darunter zaehlt als Hinweis
#F|N-033|KN-4|fund|Erzeuger|Attrappe: Rueckgabewert 1 mit FEHLT und NICHT COMMITTET: ein Fund KN-4 und ein Hinweis
#F|N-034|KN-4|lage-c|Erzeuger|Attrappe: Rueckgabewert 1 ohne Meldungszeile ist Lage C
#F|N-035|KN-4|lage-c|Erzeuger|Attrappe: Rueckgabewert 127 ist Lage C
#F|N-036|KN-4|lage-c|Erzeuger|Attrappe: Rueckgabewert 2 ist Lage C
#F|N-037|KN-4,KN-5|lage-c|Erzeuger|Attrappe: Rueckgabewert 0 mit leerer Tabelle ist Lage C
#F|N-038|KN-4,KN-5|lage-c|Erzeuger|Attrappe: Rueckgabewert 0 ohne geschriebenes Ziel ist Lage C
#F|N-039|KN-4|lage-c|Erzeuger|Attrappe: eine Zeile der Fehlerausgabe, die das Skript nicht kennt, ist Lage C
#F|N-040|KN-4,GN-2|kein-fund+ausgabe|Erzeuger|Attrappe: Rueckgabewert 0, Tabelle mit falschem Verweis, altem Stand und leerer Beschreibung: kein Fund (Grenze GN-2)
#F|N-041|KN-4,KN-9|lage-c+funde|Erzeuger|sauberer Stand, git log scheitert (Ersatz-git): der Erzeuger meldet NICHT COMMITTET fuer Pfade der Sollmenge, bei leerem git status unmoeglich: Lage C nicht-committet, die Zaehlzeilen stehen in derselben Ausgabe
#F|N-050|KN-5|fund|Tabelle|der Kopfblock mit dem Pfad des Erzeugers ist keine Artefaktzeile: ohne Zeile fuer den Erzeuger ist dieser ein Fund KN-1
#F|N-052|KN-5|lage-c|Tabelle|Attrappe: der Pfad einer Zeile ohne Rueckwaertsakzente ist Lage C
#F|N-053|KN-5|lage-c|Tabelle|Attrappe: eine Datei ohne Tabellenkopf ist Lage C
#F|N-054|KN-5|kein-fund+ausgabe|Tabelle|Attrappe: eine Zeile mit Pfad nach dem Ende der Tabelle gehoert nicht zur Tabelle
#F|N-055|KN-5|lage-c|Tabelle|Attrappe: dem Kopfblock fehlt die Zeile "| **Artefakte** | n |" (hier "| **Anzahl Artefakte** | n |"): Lage C
#F|N-056|KN-5|lage-c|Tabelle|Attrappe: die Zahl der Artefakte im Kopf (9) ist nicht die Zahl der Tabellenzeilen (7) plus der Meldungen FEHLT: (0): Lage C
#F|N-060|KN-6|lage-c|Umfeld|ein Argument
#F|N-061|KN-6|lage-c|Werkzeuge|bash fehlt im Suchpfad
#F|N-062|KN-6|lage-c|Werkzeuge|git fehlt im Suchpfad
#F|N-063|KN-6|lage-c|Werkzeuge|env fehlt im Suchpfad
#F|N-064|KN-6|lage-c|Werkzeuge|dirname fehlt im Suchpfad (der Erzeuger braucht es)
#F|N-065|KN-6|lage-c|Werkzeuge|mktemp fehlt im Suchpfad
#F|N-066|KN-6|lage-c|Werkzeuge|mkdir fehlt im Suchpfad
#F|N-067|KN-6|lage-c|Werkzeuge|rm fehlt im Suchpfad
#F|N-068|KN-6|lage-c|Werkzeuge|sort fehlt im Suchpfad
#F|N-069|KN-6|lage-c|Werkzeuge|grep fehlt im Suchpfad
#F|N-070|KN-6|lage-c|Umfeld|kein Git-Arbeitsbaum um die Wurzel des Skripts
#F|N-071|KN-6|lage-c|Umfeld|die Wurzel des Skripts ist nicht die oberste Ebene eines Git-Arbeitsbaums
#F|N-072|KN-6|lage-c|Erzeuger|der Erzeuger fehlt
#F|N-073|KN-6|lage-c|Erzeuger|der Erzeuger ist eine symbolische Verknuepfung
#F|N-074|KN-6|lage-c|Erzeuger|der Erzeuger ist ein Verzeichnis
#F|N-075|KN-6|lage-c|Erzeuger|der Erzeuger ist nicht lesbar
#F|N-076|KN-6,KN-7|lage-c|Ablage|die Ablage liegt im Arbeitsbaum
#F|N-077|KN-6|lage-c|Ablage|mktemp -d scheitert
#F|N-078|KN-6|lage-c|git|git ls-files scheitert
#F|N-079|KN-6,KN-8|lage-c+funde|Liste|die Zahl der gelesenen Eintraege der Liste weicht von der gezaehlten ab: Lage C in derselben Ausgabe
#F|N-080|KN-6,KN-8|lage-c+funde|sort|sort endet mit einem Fehler: Lage C, die Funde stehen ungeordnet in derselben Ausgabe
#F|N-081|KN-6,KN-8|lage-c+funde|sort|sort liefert nur die erste Zeile: Lage C, die Funde stehen in derselben Ausgabe
#F|N-082|KN-6,KN-8,KN-9|lage-c+funde|git|git status scheitert: Lage C, die Funde stehen in derselben Ausgabe, die Zeile KN-9 sagt "nicht beurteilt"
#F|N-083|KN-6,KN-8,KN-9|lage-c+funde|git|git ls-tree scheitert bei sauberem Stand: Lage C, die Funde stehen in derselben Ausgabe
#F|N-084|KN-6,KN-8,KN-9|lage-c+funde|git|git cat-file scheitert bei sauberem Stand: Lage C, die Funde stehen in derselben Ausgabe
#F|N-085|KN-6|fund|Umfeld|GIT_DIR, GIT_WORK_TREE und GIT_INDEX_FILE des Aufrufers aendern das Urteil nicht
#F|N-086|KN-6|kein-fund+ausgabe|Umfeld|Arbeitsverzeichnis in einem fremden Repository aendert das Urteil nicht
#F|N-088|KN-6|kein-fund+ausgabe|Umfeld|CDPATH des Aufrufers aendert die Wurzel bei relativem Aufruf nicht
#F|N-093|KN-6|statisch|Werkzeuge|die Pruefung der bash-Version steht vor der ersten Erklaerung eines assoziativen Feldes
#F|N-090|KN-7|schreibfrei|Schreibfrei|der Baum ist nach dem Lauf wie davor, auch docs/NACHWEISE.md und das Git-Verzeichnis
#F|N-091|KN-7|statisch|Schreibfrei|ausserhalb von Kommentarzeilen steht kein Here-String (Bash legt dafuer ab 64 KiB, vor Version 5.1 immer, eine Wegwerfdatei an)
#F|N-092|KN-7|fund|Ablage|die Ablage in TMPDIR ist nach dem Lauf entfernt
#F|N-100|KN-8|gleich|Ausgabe|zwei Laeufe mit verschiedener Zeitzone: dieselbe Ausgabe, keine Zeit
#F|N-102|KN-8|fund|Ausgabe|2400 Funde, Ausgabe ueber 64 KiB: die Zahl der Fundzeilen ist gleich "Befunde: 2400"
#F|N-110|KN-9|fund|committete Liste|sauberer Stand, die committete Liste fuehrt einen Pfad mehr: Fund KN-9
#F|N-111|KN-9|fund|committete Liste|sauberer Stand, die frische Liste fuehrt einen Pfad mehr: Fund KN-9
#F|N-112|KN-9|fund|committete Liste|sauberer Stand, gleiche Pfade, andere Zahl der Artefakte im Kopf: Fund KN-9 mit docs/NACHWEISE.md
#F|N-113|KN-9,GN-5|kein-fund+ausgabe|committete Liste|schmutziger Baum, Pfadmengen verschieden: nicht beurteilt, kein Fund (Grenze GN-5)
#F|N-114|KN-9|fund|committete Liste|sauberer Stand, docs/NACHWEISE.md nicht in HEAD: Fund KN-9
#F|N-115|KN-9|fund|committete Liste|sauberer Stand, die committete Datei hat keine Tabelle: Fund KN-9
#F|N-116|KN-9|fund|committete Liste|sauberer Stand, dem Kopfblock der committeten Liste fehlt die Zeile "| **Artefakte** | n |": Fund KN-9 mit docs/NACHWEISE.md
#F|N-120|GN-1|fund|Grenze GN-1|ein Pfad mit senkrechtem Strich laesst sich im Erzeuger nicht aufnehmen: Fund KN-1 (Fehlalarm)
#F|N-121|GN-1|kein-fund+ausgabe|Grenze GN-1|ein Rueckwaertsakzent im Pfad wird gelesen: erster und letzter Akzent der Spalte begrenzen den Pfad
#F|N-299|KN-7|arbeitsbaum|Arbeitsbaum|der Arbeitsbaum ist nach dem ganzen Lauf wie davor (letzter Fall der Liste)

# --- KN-1 ---
f_N001() { grundzaehlung; }
f_N002() { datei docs/neu.md 'x'; sauber; erwarte KN-1 docs/neu.md; zaehlung 7 7 7 9 0; kn9 gleich 7 7; }
f_N003() { datei docs/lose.md 'x'; erwarte KN-1 docs/lose.md; zaehlung 7 7 7 9 0; kn9 offen 1; }
f_N004() { datei backend/src/paket/neu.py 'x'; zaehlung 7 7 7 9 0; kn9 offen 1; }
f_N005() { datei docs/sub2/d.md 'x'; erwarte KN-1 docs/sub2/d.md; }
f_N006() { datei docs/sub/x/y/z.md 'x'; }
f_N007() { datei docs/z.md 'x'; datei docs/m.md 'x'; datei docs/A.md 'x'; erwarte KN-1 docs/A.md; erwarte KN-1 docs/m.md; erwarte KN-1 docs/z.md; }
# --- KN-2 ---
f_N010() { datei ignoriert/x.txt 'x'; liste "${GRUND_PFADE[@]}" ignoriert/x.txt; erwarte KN-2 ignoriert/x.txt; zaehlung 8 8 8 8 0; kn9 offen 1; }
f_N011() { liste "${GRUND_PFADE[@]}" docs/leer/.gitkeep; erwarte KN-2 docs/leer/.gitkeep; }
f_N012() { liste "${GRUND_PFADE[@]}" docs/leer; erwarte KN-2 docs/leer; }
f_N013() { liste "${GRUND_PFADE[@]}" README.md; zaehlung 8 7 8 8 0; kn9 offen 1; }
f_N014() { datei ignoriert/x.txt 'x'; liste "${GRUND_PFADE[@]}" ignoriert/x.txt ignoriert/x.txt; erwarte KN-2 ignoriert/x.txt; }
# --- KN-3 ---
f_N020() { datei .gitkeep; datei backend/.gitkeep; datei docs/sub/.gitkeep; zaehlung 7 7 7 8 0; kn9 offen 3; }
f_N021() { datei scripts/NACHWEISE.md 'x'; datei docs/.gitkeep2 'x'; erwarte KN-1 docs/.gitkeep2; erwarte KN-1 scripts/NACHWEISE.md; }
f_N022() { datei ignoriert/y.txt 'x'; datei debug.log 'x'; grundzaehlung; }
f_N023() {
  local probe
  probe=$(GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=core.excludesFile GIT_CONFIG_VALUE_0=/x gitg config --get core.excludesFile 2>/dev/null)
  if [ "$probe" != /x ]; then nicht_herstellbar "git kennt GIT_CONFIG_COUNT nicht (ab Version 2.31; GP-N5)"; fi
  printf 'docs/lose.md\n' > "$FALL/globale-ausschlussliste" || herstellung_fehler "Ausschlussliste"
  datei docs/lose.md 'x'
  env_zusatz "GIT_CONFIG_COUNT=1"; env_zusatz "GIT_CONFIG_KEY_0=core.excludesFile"; env_zusatz "GIT_CONFIG_VALUE_0=$FALL/globale-ausschlussliste"
  erwarte KN-1 docs/lose.md
}
f_N024() { local p=$'docs/mit Leerzeichen \xc3\xa4.md'; datei "$p" 'x'; erwarte KN-1 "$p"; }
f_N025() { local p=$'docs/zeilen\numbruch.md'; datei "$p" 'x'; erwarte KN-1 "$p"; }
f_N026() { local p=$'docs/mit Leerzeichen \xc3\xa4.md'; datei "$p" 'x'; liste "${GRUND_PFADE[@]}" "$p"; zaehlung 8 8 8 9 1; kn9 offen 2; }
# --- KN-4 ---
f_N030() { liste "${GRUND_PFADE[@]}" docs/fehlt.md; erwarte KN-4 docs/fehlt.md; zaehlung 7 7 8 8 0; kn9 offen 1; }
f_N031() { datei docs/lose.md 'x'; liste "${GRUND_PFADE[@]}" docs/lose.md; zaehlung 8 8 8 9 1; kn9 offen 2; }
f_N032() { datei docs/neuverz/f.md 'x'; liste "${GRUND_PFADE[@]}" docs/neuverz; zaehlung 8 8 8 9 1; kn9 offen 2; }
f_N033() {
  tabelle_text 8 "${GRUND_PFADE[@]}" > "$FALL/tab.md"
  erzeuger_attrappe 1 "$FALL/tab.md" "FEHLT: docs/x.md" "NICHT COMMITTET: docs/a.md" $'Nachweisverzeichnis erzeugt, aber unvollst\xc3\xa4ndig: mindestens ein Artefakt fehlt oder ist nicht committet.'
  erwarte KN-4 docs/x.md; zaehlung 7 7 8 8 1; kn9 offen 1
}
f_N034() { tabelle_text 7 "${GRUND_PFADE[@]}" > "$FALL/tab.md"; erzeuger_attrappe 1 "$FALL/tab.md"; lc erzeuger-ohne-meldung; }
f_N035() { tabelle_text 7 "${GRUND_PFADE[@]}" > "$FALL/tab.md"; erzeuger_attrappe 127 "$FALL/tab.md"; lc erzeuger-rueckgabewert; lc_mit "127"; }
f_N036() { tabelle_text 7 "${GRUND_PFADE[@]}" > "$FALL/tab.md"; erzeuger_attrappe 2 "$FALL/tab.md"; lc erzeuger-rueckgabewert; lc_mit "Rueckgabewert 2"; }
f_N037() { tabelle_text 0 > "$FALL/tab.md"; erzeuger_attrappe 0 "$FALL/tab.md"; lc tabelle; lc_mit "leere Tabelle"; }
f_N038() { erzeuger_attrappe 0 -; lc tabelle; lc_mit "kein Ziel"; }
f_N039() { tabelle_text 7 "${GRUND_PFADE[@]}" > "$FALL/tab.md"; erzeuger_attrappe 0 "$FALL/tab.md" "Warnung: unbekannte Meldung"; lc erzeuger-meldung; lc_mit "Warnung: unbekannte Meldung"; }
f_N040() { tabelle_text 7 "${GRUND_PFADE[@]}" > "$FALL/tab.md"; erzeuger_attrappe 0 "$FALL/tab.md"; zaehlung 7 7 7 8 0; kn9 offen 1; }
f_N041() { git_ersatz log; zaehlung 7 7 7 8 7; kn9 gleich 7 7; lc nicht-committet; lc_mit "NICHT COMMITTET fuer 7 Pfad(e)"; }
# --- KN-5 ---
f_N050() { liste .gitignore README.md docs/a.md docs/b.md docs/sub backend/src/paket; erwarte KN-1 scripts/nachweise-erzeugen.sh; }
f_N052() { local t; t=$(tabelle_text 1 README.md); t="${t//\`/}"; printf '%s\n' "$t" > "$FALL/tab.md"; erzeuger_attrappe 0 "$FALL/tab.md"; lc tabelle; lc_mit "Tabellenzeile 1"; }
f_N053() { printf '# Nachweisverzeichnis\n\nText ohne Tabelle\n' > "$FALL/tab.md"; erzeuger_attrappe 0 "$FALL/tab.md"; lc tabelle; lc_mit "Tabellenkopf"; }
f_N054() { { tabelle_text 7 "${GRUND_PFADE[@]}"; printf '| Artefakt X | `docs/fremd.md` | [`abc`](x) | 1999-01-01 |  |\n'; } > "$FALL/tab.md"; erzeuger_attrappe 0 "$FALL/tab.md"; zaehlung 7 7 7 8 0; kn9 offen 1; }
f_N055() { tabelle_text 7 "${GRUND_PFADE[@]}" | sed 's/^| \*\*Artefakte\*\* |/| **Anzahl Artefakte** |/' > "$FALL/tab.md" || herstellung_fehler "N-055"; erzeuger_attrappe 0 "$FALL/tab.md"; lc tabelle; lc_mit "keine lesbare Zeile"; }
f_N056() { tabelle_text 9 "${GRUND_PFADE[@]}" > "$FALL/tab.md"; erzeuger_attrappe 0 "$FALL/tab.md"; lc tabelle; lc_mit "Zahl der Artefakte im Kopf der frischen Liste (9)"; }
# --- KN-6 ---
f_N060() { ARGS=(x); lc aufruf; }
f_N061() { ohne_werkzeug bash; }
f_N062() { ohne_werkzeug git; }
f_N063() { ohne_werkzeug env; }
f_N064() { ohne_werkzeug dirname; }
f_N065() { ohne_werkzeug mktemp; }
f_N066() { ohne_werkzeug mkdir; }
f_N067() { ohne_werkzeug rm; }
f_N068() { ohne_werkzeug sort; }
f_N069() { ohne_werkzeug grep; }
f_N070() { SKRIPT_ORT="../ohnegit/scripts/nachweise-vollstaendig.sh"; lc git-arbeitsbaum; }
f_N071() { SKRIPT_ORT="unter/scripts/nachweise-vollstaendig.sh"; lc git-arbeitsbaum; lc_mit "nicht die oberste Ebene"; }
f_N072() { rm -f "$BAUM/scripts/nachweise-erzeugen.sh"; lc erzeuger; lc_mit "fehlt; ohne ihn"; }
f_N073() { rm -f "$BAUM/scripts/nachweise-erzeugen.sh"; ln -s "$ERZEUGER_ECHT" "$BAUM/scripts/nachweise-erzeugen.sh" || herstellung_fehler "Verknuepfung"; lc erzeuger-verknuepfung; }
f_N074() { rm -f "$BAUM/scripts/nachweise-erzeugen.sh"; mkdir "$BAUM/scripts/nachweise-erzeugen.sh" || herstellung_fehler "Verzeichnis"; lc erzeuger; lc_mit "keine regulaere Datei"; }
f_N075() { als_root_nicht; chmod 000 "$BAUM/scripts/nachweise-erzeugen.sh" || herstellung_fehler "chmod"; lc erzeuger; lc_mit "nicht lesbar"; }
f_N076() { mkdir "$BAUM/tmp" || herstellung_fehler "tmp"; env_zusatz "TMPDIR=$BAUM/tmp"; lc ablage; lc_mit "liegt im Arbeitsbaum"; }
f_N077() { env_zusatz "TMPDIR=$FALL/gibtsnicht"; lc ablage; lc_mit "mktemp -d schlug fehl"; }
f_N078() { git_ersatz ls-files; lc git-liste; }
f_N079() { grep_ersatz; lc liste; lc_mit "999 Eintraege"; }
f_N080() { sort_ersatz fehler; datei docs/p.md 'x'; datei docs/q.md 'x'; erwarte KN-1 docs/p.md; erwarte KN-1 docs/q.md; lc werkzeug:sort; lc_mit "endete mit einem Fehler"; }
f_N081() { sort_ersatz erste; datei docs/p.md 'x'; datei docs/q.md 'x'; erwarte KN-1 docs/p.md; erwarte KN-1 docs/q.md; lc werkzeug:sort; lc_mit "lieferte 1 Zeilen statt der erfassten 2"; }
f_N082() { git_ersatz status; datei docs/p.md 'x'; erwarte KN-1 docs/p.md; zaehlung 7 7 7 9 0; ausgabe_mit "KN-9: nicht beurteilt -- git status scheitert (Lage C)"; lc git-status; lc_mit "Rueckgabewert 128"; }
f_N083() { git_ersatz ls-tree; datei docs/p.md 'x'; sauber; erwarte KN-1 docs/p.md; zaehlung 7 7 7 9 0; ausgabe_mit "KN-9: nicht beurteilt -- git ls-tree scheitert (Lage C)"; lc git-kopf; lc_mit "Rueckgabewert 128"; }
f_N084() { git_ersatz cat-file; datei docs/p.md 'x'; sauber; erwarte KN-1 docs/p.md; zaehlung 7 7 7 9 0; ausgabe_mit "KN-9: nicht beurteilt -- git cat-file scheitert (Lage C)"; lc git-kopf; lc_mit "Rueckgabewert 128"; }
f_N085() {
  fremdes_repo
  env_zusatz "GIT_DIR=$FALL/fremd/.git"; env_zusatz "GIT_WORK_TREE=$FALL/fremd"; env_zusatz "GIT_INDEX_FILE=$FALL/fremd/.git/index"
  datei docs/lose.md 'x'; erwarte KN-1 docs/lose.md
}
f_N086() { fremdes_repo; CWD_WAHL="$FALL/fremd"; grundzaehlung; }
f_N088() { AUFRUF_REL=1; CWD_WAHL="$BAUM"; mkdir -p "$FALL/lockvogel/scripts" || herstellung_fehler "lockvogel"; env_zusatz "CDPATH=$FALL/lockvogel"; grundzaehlung; }
f_N093() {
  local a b
  STAT_SOLL="die Pruefung der bash-Version steht vor der ersten Erklaerung eines assoziativen Feldes (declare -A)"
  a=$(code_text | grep -n 'BASH_VERSINFO' | head -n 1 | cut -d: -f1); b=$(code_text | grep -n 'declare -A' | head -n 1 | cut -d: -f1)
  STAT_IST="BASH_VERSINFO in Codezeile ${a:-keine}, declare -A in Codezeile ${b:-keine}"
  if [ -n "$a" ] && [ -n "$b" ] && [ "$a" -lt "$b" ]; then STAT_OK=1; fi
}
# --- KN-7 ---
f_N090() { datei docs/lose.md 'x'; }
f_N091() {
  local treffer probe
  STAT_SOLL="ausserhalb von Kommentarzeilen steht kein Here-String (Bash legt dafuer ab 64 KiB, vor Version 5.1 immer, eine Wegwerfdatei an)"
  treffer=$(code_text | grep -c '<<<'); probe=$(printf '%s\nx <<< "y"\n' "$(code_text)" | grep -c '<<<')
  STAT_IST="Zeilen mit <<<: $treffer; Probe der Pruefung: $probe"
  if [ "$treffer" = 0 ] && [ "$probe" -ge 1 ]; then STAT_OK=1; fi
}
f_N092() { mkdir "$FALL/ablage" || herstellung_fehler "ablage"; env_zusatz "TMPDIR=$FALL/ablage"; datei docs/lose.md 'x'; erwarte KN-1 docs/lose.md; nach_lauf nach_N092; }
nach_N092() {
  local f n=0
  for f in "$FALL/ablage"/* "$FALL/ablage"/.[!.]* "$FALL/ablage"/..?*; do if [ -e "$f" ] || [ -L "$f" ]; then n=$((n + 1)); fi; done
  IST="$IST; Ablage nach dem Lauf: $n Eintraege"
  if [ "$n" -ne 0 ]; then ERG=GEFALLEN; DETAIL+=("die Ablage ist nach dem Lauf nicht entfernt"); fi
}
# --- KN-8 ---
f_N100() { datei docs/p.md 'x'; datei docs/q.md 'x'; env_zusatz "TZ=UTC"; env_zusatz2 "TZ=Asia/Tokyo"; erwarte KN-1 docs/p.md; erwarte KN-1 docs/q.md; }
f_N102() {
  local i n
  mkdir -p "$BAUM/docs/gen" || herstellung_fehler "docs/gen"
  for ((i = 1; i <= 2400; i++)); do printf -v n 'f%04d.md' "$i"; : > "$BAUM/docs/gen/$n"; done
  erwarte_zahl 2400; ausgabe_mit "Befunde: 2400"; nach_lauf nach_N102
}
nach_N102() {
  local groesse
  groesse=$(<"$FALL/aus.txt"); IST="$IST; Standardausgabe ${#groesse} Zeichen"
  if [ "${#groesse}" -lt 65536 ]; then ERG=GEFALLEN; DETAIL+=("die Standardausgabe ist kleiner als 64 KiB: der Fall misst die Schwelle der Here-Strings nicht"); fi
}
# --- KN-9 ---
f_N110() { committet_liste 7 "${GRUND_PFADE[@]}" docs/sub/c.md; sauber; erwarte KN-9 docs/sub/c.md; }
f_N111() { committet_liste 7 .gitignore README.md docs/a.md docs/sub backend/src/paket scripts/nachweise-erzeugen.sh; sauber; erwarte KN-9 docs/b.md; }
f_N112() { committet_liste 9 "${GRUND_PFADE[@]}"; sauber; erwarte KN-9 docs/NACHWEISE.md; }
f_N113() { committet_liste 7 "${GRUND_PFADE[@]}" docs/sub/c.md; sauber; datei README.md 'geaendert'; kn9 offen 1; }
f_N114() { gitg -C "$BAUM" rm -q docs/NACHWEISE.md || herstellung_fehler "git rm"; sauber; erwarte KN-9 docs/NACHWEISE.md; }
f_N115() { printf 'Kein Verzeichnis.\n' > "$BAUM/docs/NACHWEISE.md"; sauber; erwarte KN-9 docs/NACHWEISE.md; }
f_N116() { tabelle_text 7 "${GRUND_PFADE[@]}" | sed '/^| \*\*Artefakte\*\* |/d' > "$BAUM/docs/NACHWEISE.md" || herstellung_fehler "N-116"; sauber; erwarte KN-9 docs/NACHWEISE.md; ausgabe_mit "KN-9: Fund -- die committete docs/NACHWEISE.md hat keine lesbare Tabelle der Artefakte oder keine lesbare Zahl der Artefakte"; }
# --- GN ---
f_N120() { datei 'docs/a|b.md' 'x'; erwarte KN-1 'docs/a|b.md'; }
f_N121() { datei 'docs/x`y.md' 'x'; liste "${GRUND_PFADE[@]}" '@  "Artefakt|docs/x\`y.md|Beschreibung"'; zaehlung 8 8 8 9 1; kn9 offen 2; }
f_N299() { :; }

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
    fund) if [ -n "$FUND_ZAHL" ]; then sollt="Fund, $FUND_ZAHL Zeile(n)"; else sollt="Fund, ${#ERW[@]} Zeile(n)"; fi ;;
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
              if [ "$a" = "$s" ]; then d=1; fi
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
    [[ "$k" =~ ^N-[0-9]{3}$ ]] || lage_c_pm "Fallliste: ungueltige Kennung '$k'."
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
    k="N-${fn#f_N}"
    [ -n "${FL_SOLL[$k]+x}" ] || lage_c_pm "Funktion $fn hat keine Zeile in der Fallliste."
  done < <(compgen -A function | grep -E '^f_N[0-9]{3}$')
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
  for grp in KN GN; do
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
    if [ "${k:0:2}" = "KN" ]; then
      num="${k:3:1}"
      if { [ "$num" -le 6 ] || [ "$num" -eq 9 ]; } && [ "${KL_ANZ[$k]:-0}" -gt 0 ]; then
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
    [[ "$id" =~ ^NM-[0-9]{3}$ ]] || lage_c_pm "Mutationsdatei Zeile $zn: Kennung '$id' ist nicht NM-nnn."
    [ -z "${gesehen[$id]+x}" ] || lage_c_pm "Mutationsdatei Zeile $zn: Kennung $id doppelt."
    gesehen[$id]=1
    [[ "$kl" =~ ^KN-[0-9]$ ]] || lage_c_pm "Mutationsdatei Zeile $zn: Klasse '$kl' ist keine Kennung KN."
    [ -n "$ed" ] && [ -n "$gr" ] || lage_c_pm "Mutationsdatei Zeile $zn: sed-Ausdruck oder Grund fehlt."
    [[ "$ms" =~ ^N-[0-9]{3}(,N-[0-9]{3})*$ ]] || lage_c_pm "Mutationsdatei Zeile $zn: Mindestsatz '$ms' ist keine Liste von Fallkennungen."
    for f in ${ms//,/ }; do
      [ -n "${FL_SOLL[$f]+x}" ] || lage_c_pm "Mutationsdatei Zeile $zn: Fall $f des Mindestsatzes steht nicht in der Fallliste."
      [ "${FL_SOLL[$f]}" != arbeitsbaum ] || lage_c_pm "Mutationsdatei Zeile $zn: Fall $f (Soll arbeitsbaum) prueft das Skript nicht und steht in keinem Mindestsatz."
    done
    MUT_ID+=("$id"); MUT_KL+=("$kl"); MUT_ED+=("$ed"); MUT_MS+=("$ms"); MUT_GR+=("$gr")
  done < "$MUTATIONSDATEI"
  MUT_N=${#MUT_ID[@]}
  [ "$MUT_N" -gt 0 ] || lage_c_pm "Mutationsdatei ohne Mutation."
}

mutationsdeckung_pruefen() { # jede Klasse KN des Kopfkommentars hat eine Mutation mit einem Fall dieser Klasse im Mindestsatz
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
      KN) if [ -z "${abgedeckt[$k]+x}" ]; then fehl="$fehl $k"; anz=$((anz + 1)); fi ;;
    esac
  done < <(kopf_kennungen)
  if [ "$anz" -gt 0 ]; then
    echo "$PM: Mutationsdeckung ABWEICHUNG: $anz Klassen des Kopfkommentars ohne Mutation (kein Fall der Klasse in einem Mindestsatz):$fehl"
    MUT_ABW=$((MUT_ABW + anz))
  fi
  if [ "$MUT_ABW" -eq 0 ]; then
    echo "$PM: Mutationsdeckung: jede Klasse KN hat eine Mutation, ohne Abweichung"
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
  echo "$PM: Kopf -- Arbeitsbaum $ARBEITSBAUM, Commit $ARB_COMMIT, Skript $PRUEFER sha256 $PRUEFER_SHA, Erzeuger sha256 $ERZ_SHA, Mutationsdatei $MUT_SHA, Anforderung R3-Q-001, Einheit G3.4"
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
        N-[0-9]*) zeigen=0; case "$zeile" in *" GEFALLEN |"*|*" NICHT_HERSTELLBAR |"*) zeigen=1 ;; esac ;;
      esac
      if [ "$zeigen" = 1 ]; then printf '%s\n' "$zeile"; fi
    done < "$T/grundlinie.log"
  else
    echo "--- Faelle"
    for k in "${FL_ORDER[@]}"; do fall_ausfuehren "$k"; done
  fi
  echo "--- Zusammenfassung der Faelle"
  echo "$PM: ${#FL_ORDER[@]} Faelle: $ANZ_B bestanden, $ANZ_G gefallen, $ANZ_H nicht herstellbar"
  for grp in KN GN; do
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
