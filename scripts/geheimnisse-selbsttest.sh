#!/usr/bin/env bash
# =============================================================================
# scripts/geheimnisse-selbsttest.sh -- Pruefmittel fuer das Rezept geheimnisse im Makefile (Kettenschritt D11)
# =============================================================================
#
# Anforderung R3-Q-001 (das DoD-Gate stuetzt sich auf die Kette). Grundlage: ADR 0002, Abschnitt 5, Nachtrag vom 2026-11-04
# (Festlegung fuer N3), Zeile "Pruefmittel fuer D11" und folgende; Offener Punkt O-30; Register SR-014 bis SR-020 (Teile zu D11) und
# die Fortschreibung (a) bis (j) vom 2026-11-03. Bauform: scripts/nachweise-vollstaendig-selbsttest.sh und
# scripts/prototyp-trennung-pruefen-selbsttest.sh. Einheit N3.2.
#
# GEGENSTAND: das Rezept geheimnisse im Makefile DESSELBEN Baums, in dem dieses Pruefmittel liegt (der Aufrufort spielt keine Rolle).
# Je Fall entsteht ein Wegwerf-Repository unter mktemp -d mit einer Kopie des Makefile und von scripts/gitleaks.toml; das Rezept laeuft
# dort unter "env -i" mit festem Umfeld. Ausgewertet werden die Marke (A_OK, A_FAIL, Lage C mit FEHLT=...), die Familienmeldungen der
# Selbstpruefung, die Fundzahlen von Lauf 1 und Lauf 2 und die Zahl der gelesenen Commits. Es gibt keinen Parameter --pruefer: das
# Rezept ist kein eigenes Skript. make dod ruft dieses Pruefmittel nicht auf (wie die uebrigen Selbsttests).
#
# AUFRUF
#   bash scripts/geheimnisse-selbsttest.sh [--mutationen]
#
# RUECKGABEWERT
#   0  alle Faelle bestanden, Deckung und Gegenstandsdeckung ohne Abweichung; "nicht herstellbar" zaehlt weder als bestanden noch als
#      gefallen, wird je mit Grund gemeldet (im Normalmodus mit der Zahl ausgewiesen) und beruehrt den Rueckgabewert nicht. Im Modus
#      --mutationen zusaetzlich: jede Mutation erkannt, keine wirkungslos, Mutationsdeckung ohne Abweichung, Arbeitsbaum unveraendert
#   2  ein Fall gefallen, eine Abweichung der Deckung oder der Gegenstandsdeckung, eine Mutation nicht erkannt oder wirkungslos,
#      oder der Arbeitsbaum ist nach dem Lauf veraendert
#   3  Lage C des Pruefmittels: der Lauf hat nicht stattgefunden (fehlendes Werkzeug, unbekannter Parameter, andere Fassung oder andere
#      Summe von gitleaks, TMPDIR nicht absolut oder im Arbeitsbaum, Mutationsdatei fehlt oder ist formfehlerhaft, ein Defekt des
#      Pruefmittels)
#
# WERKZEUGE (geschlossene Liste, vor dem ersten Gebrauch geprueft): bash, git, make, gitleaks, grep, sed (GNU, mit --sandbox), sort,
#   uniq, wc, seq, ls, mktemp, cp, rm, mkdir, chmod, cat, head, tail, tr, cut, env, timeout, cmp, sha256sum, date, dirname, find,
#   tee. Kein Netz, kein Python, kein uv, kein Docker.
#
# VORAUSSETZUNG gitleaks (Lage C bei Abweichung: "andere Fassung: Inventar und Familien zu wiederholen"): "gitleaks version" meldet
#   8.21.2 und das Binary traegt die SHA-256-Summe der Konstanten GITLEAKS_SHA256 unten. Die zehn Familien und das Inventar der 28
#   Muster im Rezept gelten nur fuer diese Fassung (Register SR-016); ein anderes Binary mit gleicher Versionsangabe trueg die Aussage
#   nicht. Herleitung der Konstanten: (1) .claude/hooks/session-start-gitleaks.sh pinnt das Release-Archiv
#   gitleaks_8.21.2_linux_x64.tar.gz mit der SHA-256-Summe 5bc41815076e6ed6ef8fbecc9d9b75bcae31f39029ceb55da08086315316e3ba; (2) daraus
#   das Binary gitleaks (tar -xzf, nur diese Datei); (3) dessen Summe, gemessen am 2026-11-04 (DevOps Engineer, N3.2): die Konstante.
#   Gemessen wurden dabei das Archiv (Download von der festen Adresse des Hooks) gegen den Pin des Hooks (gleich) und das daraus
#   entpackte Binary gegen /usr/local/bin/gitleaks (gleich); beide Summen sind im Befehlsprotokoll der Einheit. Hook und Pruefmittel
#   bleiben getrennt: der Hook pinnt das Archiv, das Pruefmittel das Binary. Stellungnahme dazu: SecDevOps Engineer (N3.2).
#
# ABLAGE: Ist TMPDIR gesetzt und nicht absolut oder im Arbeitsbaum, ist das Lage C, ohne dass mktemp aufgerufen wird (N2, Punkt h). Der
#   Pfad aus mktemp wird fuer den trap festgehalten. Das Pruefmittel schreibt nichts in den Arbeitsbaum und nichts ausserhalb seiner
#   Ablage; im Modus --mutationen wird der Arbeitsbaum vor und nach dem Lauf verglichen. Ersatzwerkzeuge (git, gitleaks, mktemp,
#   sha256sum und die uebrigen der Kaesten) sind ausschliesslich eigene Dateien in Verzeichnissen der Ablage, vorne im Suchpfad des
#   Falls, und rufen das echte Werkzeug mit absolutem Pfad auf; es gibt nie eine Verknuepfung auf eine Systemdatei und nie eine
#   Aenderung ausserhalb der Ablage.
#
# ERFUNDENE SCHLUESSEL (5.15): Kein von gitleaks erkennbarer Schluessel steht woertlich in diesem Pruefmittel oder in der
#   Mutationsdatei. Die Schluessel werden zur Laufzeit aus Teilen zusammengesetzt (schluessel_text); sie sind erfunden und kein
#   echtes Geheimnis. Keine Inline-Marke zum Unterdruecken von Funden im Quelltext (der Fall S-027 setzt sie zur Laufzeit), keine Ausnahme in
#   scripts/gitleaks.toml, kein Eintrag in einer Ausnahmeliste. D11 am Bestand mit diesem Pruefmittel endet mit A_OK.
#
# UMFELD JEDES LAUFS DES REZEPTS: "env -i" mit PATH, HOME (leeres Verzeichnis der Ablage), LC_ALL=C, TZ=UTC und TMPDIR (leeres
#   Verzeichnis je Fall); dazu je Fall die Zusaetze der Fallfunktion. Zeitgrenze 120 s je Lauf des Rezepts.
#
# FALLKLASSEN (einstellige Kennungen, einzeln)
#   KS-1  Familien der Selbstpruefung: je Familie und je Teilmuster von bau-dateien ein Pfad mit Schluessel: A_FAIL mit Meldung der
#         Familie und Fundzahl 0 in beiden Laeufen (belegt zugleich das Ueberspringen durch gitleaks); Nachbarpfade: mit Schluessel
#         A_FAIL allein durch den Fund, ohne Schluessel A_OK; Gross- und Kleinschreibung nach (g): a.Wsuo und xWsuo A_FAIL durch die
#         Familie, a.wsuo A_OK (GS-1), a.WSUO A_FAIL allein aus dem Fund; Pfade, die ein Muster mit (?i) in Grossschreibung
#         ueberspringt; Ausnahme scripts/gitleaks.toml. Buendelung nur hier (hoechstens fuenf Pfade je Familie in einem Fall).
#   KS-2  Funde der Laeufe: Schluessel unversioniert im Arbeitsbaum, nur in der Historie, nur in einer Merge-Aufloesung, im
#         Wurzel-Commit (log.showRoot=false), unter "* -diff", textconv, color.ui=always, mit Inline-Marke zum Unterdruecken, nach einem
#         Ersatzobjekt; ohne Schluessel A_OK. Jeder Fall hat eine Ursache.
#   KS-3  Regeln und Konfiguration: GITLEAKS_CONFIG mit leerer Datei, .gitleaks.toml im Baum, .gitleaksignore, scripts/gitleaks.toml
#         veraendert, fehlend, sha256sum fehlt, override der Summe.
#   KS-4  Umfeld des Aufrufers: GIT_DIR, HOME mit Ausschlussliste (attributes und Konfiguration in HOME), Umfeld der Aufrufe von
#         gitleaks (GIT_CONFIG_NOSYSTEM, GIT_ATTR_NOSYSTEM, GIT_NO_REPLACE_OBJECTS, leeres HOME), Arbeitsverzeichnis.
#   KS-5  Lage C des Rezepts: gitleaks fehlt, git fehlt, kein Arbeitsbaum, git log schreibt auf stderr, git log scheitert nur mit -m,
#         mktemp scheitert; der Fall mit Soll A_OK ist der Lauf am Geruest mit allen Werkzeugen (S-050).
#   KS-6  Plausibilitaet des Historienlaufs: Ersatz fuer gitleaks meldet "0 commits scanned" mit 0 oder keine Zeile: Lage C
#         FEHLT=gitleaks-historie; der echte Lauf am Geruest: A_OK mit mehr als 0 gelesenen Commits.
#   KS-7  Marke und Rueckgabewert: kein Lauf schneidet den anderen ab, beide Befunde erscheinen, A_FAIL und Lage C zugleich (die
#         Marke zeigt Lage C), je Lauf genau eine Marke; der Fall mit Soll A_OK ist S-050.
#   KS-8  schreibfrei: Arbeitsbaum (einschliesslich .git ausser dem Index) unveraendert und die Ablage des Laufs (TMPDIR) leer;
#         tragen S-050 (A_OK) und S-020 (A_FAIL); die Zusicherung prueft jeder Fall. Die Klasse hat beide Fallarten, eine Ausnahme
#         ist nicht benannt.
#
# GRENZEN (je mit einem Fall, der den Durchlass misst)
#   GS-1  Akzeptierte Dateiarten mit Punkt und Sperrdateien (b2): ein Schluessel in x.svg, a.zip, package-lock.json, yarn.lock,
#         go.sum, pnpm-lock.yaml, npm-shrinkwrap.json, a.wsuo, x.gem, Pipfile.lock bleibt unbemerkt (A_OK, Fundzahl 0). S-012, S-013.
#   GS-2  Fruehere Fassungen von scripts/gitleaks.toml: der Historienlauf liest sie nicht (A_OK, Fundzahl 0). S-014.
#   GS-3  Datei und Sollwert zusammen geaendert: die Bindung haelt nur, was die Kette erreicht (A_OK). S-015.
#   GS-4  Einstellungen in .git/config ausserhalb der gemessenen: gemessen wurden etwa 40 Einstellungen (diff.*, format.pretty,
#         log.*, core.*), keine blendet den Historienlauf; der Fall S-016 setzt zwoelf davon zugleich und erwartet den Fund. Ein
#         unbekannter Durchlass bleibt moeglich.
#   GS-5  Systemkonfiguration von git: nur in eigenem Mount-Namensraum herstellbar (wie N4-sys in G1); S-017 wird als "nicht
#         herstellbar" gemeldet, kein unshare im Pruefmittel. GIT_CONFIG_NOSYSTEM ist ueber das Umfeld der Aufrufe (S-042) gemessen.
#
# PRUEFMITTELGRENZEN
#   GP-S1  S-042 misst die Umgebungsvariablen, die gitleaks erreichen (Ersatz mit Protokoll), nicht die Wirkung einer
#          Systemkonfiguration (GS-5).
#   GP-S2  Die Ersatzwerkzeuge der Kaesten (S-035, S-051, S-052, S-055, S-060 bis S-064, S-070) simulieren Ausfaelle und messen die
#          Reaktion des Rezepts, nicht einen echten Defekt.
#   GP-S3  S-016 misst, dass die gesetzten Einstellungen den Fund nicht blenden; die Einstellungen sind eine Stichprobe (GS-4).
#   GP-S4  Die Zahl der gelesenen Commits ("N commits scanned.") ist eine Schnittstelle zu gitleaks 8.21.2: gemessen wurde, dass
#          sie unter -m nicht der Zahl von git rev-list --count --all entspricht (vgl. Befehlsprotokoll der Einheit); geprueft
#          wird allein "Zahl groesser 0". Genau eine passende Zeile muss vorliegen (S-063); nur die Fehlerausgabe von Lauf 2 zaehlt
#          (S-062, SD-N32-01 und SD-N32-02).
#   GP-S5  S-041 belegt die Ausschlussliste in HOME (attributes und Konfiguration des Aufrufers), nicht die Wirkung des leeren HOME;
#          die misst S-042 (SM-036). Grund: --text, --no-color und --root heben die Konfiguration im HOME auch ohne leeres HOME auf.
#
# RESTPUNKT (ohne eigene Mutation, wie ST-C6-10): Die vier uebrigen Fehlerzweige der Selbstpruefung im Rezept (mktemp -d schlaegt
#   fehl, git ls-files endet ungleich 0, grep der Ausnahme scripts/gitleaks.toml, grep mit Rueckgabewert ueber 1) haben weder Fall
#   noch Mutation; SM-017 deckt allein den Zweig des Treffers (ST-N32-01). Der Zweig "mktemp fuer die Ausgabe von Lauf 2 schlaegt
#   fehl" ist durch S-064 und SM-059 gedeckt.
#
# FALLLISTE: Der Datenblock unten ("#F|"-Zeilen: Kennung|Klassen|Soll|Herkunft|Gegenstand) ist die maschinenlesbare Liste. Jede
#   Kennung hat genau eine Funktion f_S<nnn> weiter unten und umgekehrt (mechanisch geprueft). Kennungen S-nnn sind dauerhaft und
#   werden nie wiederverwendet. Soll-Arten: ok (A_OK), fail (A_FAIL), lage-c, nh (nicht herstellbar).
#
# DECKUNG (eigener Abschnitt der Ausgabe): Jede Klasse KS und jede Grenze GS des Kopfkommentars hat Faelle; je Klasse KS mindestens
#   ein Fall mit Soll ok und mindestens einer mit Soll fail oder lage-c; je Grenze GS mindestens ein Fall. Jede Klasse, die ein Fall
#   nennt, steht im Kopfkommentar. GEGENSTANDSDECKUNG: die Familienliste der Schleife im Rezept wird aus dem Makefile gelesen; jede
#   Familie hat einen Fall in KS-1 (zur Laufzeit bewiesen: der Fall prueft ihren Block der Meldung) und, im Modus --mutationen,
#   eine Mutation (Klasse KS-1, Grund beginnt mit "Familie <name>:"); jede fehlende oder zusaetzliche ist eine Abweichung.
#
# MODUS --mutationen: Mutationsdatei scripts/geheimnisse-mutationen.txt im Verzeichnis dieses Skripts. Zeilenform: Kennung SM-nnn,
#   Tabulator, Klasse, Tabulator, sed-Ausdruck (sed -E --sandbox auf eine Wegwerfkopie des Makefile), Tabulator, Mindestsatz
#   (Fallkennungen durch Komma), Tabulator, Grund. Nur ASCII, genau vier Tabulatoren je Zeile. Ablauf: (1) Grundlinie: alle Faelle
#   und die Deckung gegen das unveraenderte Makefile; (2) je Mutation eine Kopie; byte-gleich oder sed-Fehler: wirkungslos; ein
#   Makefile, das auf dem Geruest keine Marke mehr liefert: Defekt der Mutation, ebenfalls wirkungslos; (3) erkannt ist die
#   Mutation, wenn jeder Fall ihres Mindestsatzes gegen die Mutante faellt; nur diese Faelle laufen gegen sie; (4) Schluss:
#   geprueft, erkannt, nicht erkannt, wirkungslos; Mutationsdeckung (jede Klasse KS hat eine Mutation, deren Mindestsatz einen Fall
#   dieser Klasse enthaelt; jede Familie eine eigene); Vergleich des Arbeitsbaums vor und nach.
#
# Obergrenze der Laufzeit (Vorgabe des Nachtrags, in der Arbeitsumgebung): Normalmodus 15 Minuten, Mutationsmodus 60 Minuten; die
#   gemessenen Werte stehen im gebauten Stand der Einheit.
#
set -uo pipefail

unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_COMMON_DIR GIT_NAMESPACE GIT_CEILING_DIRECTORIES GIT_DISCOVERY_ACROSS_FILESYSTEM GIT_SHALLOW_FILE GIT_GLOB_PATHSPECS GIT_NOGLOB_PATHSPECS GIT_LITERAL_PATHSPECS GIT_ICASE_PATHSPECS GIT_NO_REPLACE_OBJECTS GITLEAKS_CONFIG 2>/dev/null || true
unset "${!GIT_TRACE@}" 2>/dev/null || true
unset CDPATH
export LC_ALL=C

PM="geheimnisse-selbsttest"
GITLEAKS_VERSION="8.21.2"
GITLEAKS_SHA256="50b742abd7daad8bbddb6301f3017efb680632d9a5b3b4d8f137b3aac250e359"
WERKZEUGE_PM="bash git make gitleaks grep sed sort uniq wc seq ls mktemp cp rm mkdir chmod cat head tail tr cut env timeout cmp sha256sum date dirname find tee"
# Werkzeuge des Rezepts im Kasten (Suchpfad eines Falls, der ein Werkzeug entbehrt): jedes als eigene Datei mit absolutem Aufruf
KASTEN_WERKZEUGE="bash make env dirname sed tr head cut grep mktemp sha256sum tee git gitleaks rm cat sort"

lage_c_pm() { # lage_c_pm <Meldung>
  echo "$PM: LAGE C des Pruefmittels -- $1" >&2
  echo "$PM: Rueckgabewert 3: der Lauf hat nicht stattgefunden." >&2
  exit 3
}

MODUS="normal"
while [ $# -gt 0 ]; do
  case "$1" in
    --mutationen) MODUS="mutationen"; shift ;;
    *) lage_c_pm "unbekannter Parameter '$1'; erlaubt ist [--mutationen]." ;;
  esac
done

for w in $WERKZEUGE_PM; do
  command -v "$w" >/dev/null 2>&1 || lage_c_pm "Werkzeug '$w' fehlt."
done
if ! printf 'x\n' | sed -E --sandbox -e 's/x/y/' >/dev/null 2>&1 || printf 'x\n' | sed -E --sandbox -e 'w /dev/null' >/dev/null 2>&1; then
  lage_c_pm "sed versteht die Option --sandbox nicht (oder ignoriert sie)."
fi
for w in $KASTEN_WERKZEUGE; do
  case "$(command -v "$w")" in /*) ;; *) lage_c_pm "Werkzeug '$w' ist nicht als Datei mit absolutem Pfad aufloesbar." ;; esac
done

SKRIPT_QUELLE="${BASH_SOURCE[0]}"
case "$SKRIPT_QUELLE" in */*) SKRIPT_VERZ_ROH="${SKRIPT_QUELLE%/*}" ;; *) SKRIPT_VERZ_ROH="." ;; esac
SKRIPT_VERZ=$(cd "$SKRIPT_VERZ_ROH" >/dev/null 2>&1 && pwd -P) || lage_c_pm "Verzeichnis des Skripts nicht aufloesbar."
SKRIPT_PFAD="$SKRIPT_VERZ/${SKRIPT_QUELLE##*/}"
ARBEITSBAUM=$(git -C "$SKRIPT_VERZ" rev-parse --show-toplevel 2>/dev/null) || lage_c_pm "kein Git-Arbeitsbaum um das Verzeichnis des Skripts ($SKRIPT_VERZ)."
MAKEFILE_ECHT="$ARBEITSBAUM/Makefile"
TOML_ECHT="$ARBEITSBAUM/scripts/gitleaks.toml"
[ -f "$MAKEFILE_ECHT" ] && [ -r "$MAKEFILE_ECHT" ] || lage_c_pm "Makefile fehlt oder ist nicht lesbar: $MAKEFILE_ECHT"
[ -f "$TOML_ECHT" ] && [ -r "$TOML_ECHT" ] || lage_c_pm "scripts/gitleaks.toml fehlt oder ist nicht lesbar: $TOML_ECHT"
MUTATIONSDATEI="$SKRIPT_VERZ/geheimnisse-mutationen.txt"
if [ "$MODUS" = "mutationen" ]; then
  [ -f "$MUTATIONSDATEI" ] && [ -r "$MUTATIONSDATEI" ] || lage_c_pm "Mutationsdatei fehlt oder ist nicht lesbar: $MUTATIONSDATEI"
fi

# gitleaks: Fassung und Summe des Binary
GL_BIN=$(command -v gitleaks)
GL_VER=$("$GL_BIN" version 2>/dev/null | head -n 1)
GL_SUM=$(sha256sum "$GL_BIN" 2>/dev/null | cut -d' ' -f1)
if [ "$GL_VER" != "$GITLEAKS_VERSION" ] || [ "$GL_SUM" != "$GITLEAKS_SHA256" ]; then
  lage_c_pm "andere Fassung: Inventar und Familien zu wiederholen (gitleaks meldet '$GL_VER' mit Summe '$GL_SUM', erwartet $GITLEAKS_VERSION mit $GITLEAKS_SHA256)."
fi
BASH_BIN=$(command -v bash)
MAKE_BIN=$(command -v make)
GIT_BIN=$(command -v git)

# Ablage: TMPDIR vor mktemp pruefen (N2, Punkt h)
if [ -n "${TMPDIR+x}" ]; then
  case "$TMPDIR" in
    /*) ;;
    *) lage_c_pm "TMPDIR ist gesetzt und nicht absolut ('$TMPDIR')." ;;
  esac
  case "$TMPDIR/" in
    "$ARBEITSBAUM"/*) lage_c_pm "TMPDIR liegt im Arbeitsbaum ('$TMPDIR')." ;;
  esac
fi
T_ROH=$(mktemp -d) || lage_c_pm "mktemp -d fehlgeschlagen."
T=$(cd "$T_ROH" && pwd -P) || { rm -rf "$T_ROH"; lage_c_pm "Wegwerfverzeichnis nicht aufloesbar."; }
case "$T" in
  /?*) ;;
  *) rm -rf "$T_ROH"; lage_c_pm "Wegwerfverzeichnis ist nicht absolut ('$T')." ;;
esac
case "$T/" in
  "$ARBEITSBAUM"/*) rm -rf "$T_ROH" "$T"; lage_c_pm "Wegwerfverzeichnis liegt im Arbeitsbaum ($T)." ;;
esac
aufraeumen() { chmod -R u+rwx "$T" >/dev/null 2>&1; rm -rf "$T"; }
trap aufraeumen EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

# Schnappschuss des Arbeitsbaums (Modus --mutationen: vor und nach dem Lauf)
schnappschuss() { # schnappschuss <verzeichnis>
  local d="$1" f
  env GIT_OPTIONAL_LOCKS=0 git -C "$d" status --porcelain --untracked-files=all || return 1
  echo "--- Pruefsummen"
  ( cd "$d" && find . -path ./.git -prune -o \( -type f -o -type l \) -print | sort | while IFS= read -r f; do
      if [ -L "$f" ]; then printf 'L %s\n' "$f"; else printf 'F %s %s\n' "$(sha256sum < "$f" | cut -c1-64)" "$f"; fi
    done )
  echo "--- git"
  ( cd "$d" && { git rev-parse HEAD 2>/dev/null; git for-each-ref 2>/dev/null; find .git -type f ! -name index ! -name 'index.lock' ! -name 'fsmonitor*' | sort | while IFS= read -r f; do printf 'G %s %s\n' "$(sha256sum < "$f" | cut -c1-64)" "$f"; done; } )
  return 0
}
if [ "$MODUS" = "mutationen" ]; then
  SCHNAPP_VOR="$T/arbeitsbaum-vor.txt"
  schnappschuss "$ARBEITSBAUM" > "$SCHNAPP_VOR" || lage_c_pm "Schnappschuss des Arbeitsbaums nicht moeglich."
fi

HOME_LEER="$T/home"
mkdir -p "$HOME_LEER" "$T/faelle" "$T/tmp" "$T/ers" "$T/aus" "$T/mf" "$T/kasten" || lage_c_pm "Verzeichnisse der Ablage nicht anlegbar."
ENV_BASIS=(
  "PATH=$PATH" "HOME=$HOME_LEER" "XDG_CONFIG_HOME=$HOME_LEER" "LC_ALL=C" "TZ=UTC"
  "GIT_CONFIG_NOSYSTEM=1" "GIT_CONFIG_GLOBAL=/dev/null"
  "GIT_AUTHOR_NAME=Selbsttest" "GIT_AUTHOR_EMAIL=selbsttest@example.invalid" "GIT_AUTHOR_DATE=2026-01-01T00:00:00Z"
  "GIT_COMMITTER_NAME=Selbsttest" "GIT_COMMITTER_EMAIL=selbsttest@example.invalid" "GIT_COMMITTER_DATE=2026-01-01T00:00:00Z"
)
gitg() { env "${ENV_BASIS[@]}" "$GIT_BIN" "$@"; }

# =============================================================================
# Hilfen fuer die Fallfunktionen: alle Pfade relativ zu $BAUM
# =============================================================================
TAB=$'\t'
FALL_K="?"
MAKEFILE_QUELLE="$MAKEFILE_ECHT"

herstellung_fehler() { echo "$PM: FEHLER -- Herstellung des Falls $FALL_K fehlgeschlagen: $*" >&2; exit 3; }

# Erfundene Schluessel: erst zur Laufzeit zusammengesetzt (keine woertliche Form im Quelltext)
schluessel_text() { # privater Schluessel (erfunden) ; Argument 1 = Kennung des Falls (macht den Inhalt verschieden)
  local a='-----BEGIN RSA PRIV' b='ATE KEY-----' c='-----END RSA PRIV' body
  body=$(printf 'QUJD%.0s' $(seq 1 30))
  printf '%s%s\n%s\n%s%s\n' "$a" "$b" "$body" "$c" "$b"
}
aws_text() { printf 'aws_key = %s%s%s\n' 'AK' 'IA' "QYLPMNHGKJZTRWXV${1:-}"; }

datei() { local p="$BAUM/$1"; shift; mkdir -p "${p%/*}" || herstellung_fehler "Verzeichnis fuer $p"; if [ $# -eq 0 ]; then : > "$p"; else printf '%s\n' "$@" > "$p"; fi || herstellung_fehler "Datei $p"; }
schluessel_in() { local p="$BAUM/$1"; mkdir -p "${p%/*}" || herstellung_fehler "Verzeichnis fuer $p"; schluessel_text > "$p" || herstellung_fehler "Datei $p"; }
vers() { gitg -C "$BAUM" add -f -- "$@" || herstellung_fehler "git add $*"; }
commit() { gitg -C "$BAUM" commit -q -m "${1:-Fall $FALL_K}" --allow-empty || herstellung_fehler "git commit"; }
alles_committen() { gitg -C "$BAUM" add -f -A && commit "${1:-}"; }
entfernen() { gitg -C "$BAUM" rm -q -f -- "$@" || herstellung_fehler "git rm $*"; }

# Erwartungen
ERW_MARKE=""; ERW_L1="*"; ERW_L2="*"; FUND_SUMME=0
FAM_ERW=(); MIT=(); OHNE=(); ENV_ZUSATZ=(); MAKE_ARGS=(); NH_GRUND=""; NACH_FN=""; PFAD_VORNE=""; KASTEN_PFAD=""; CWD_ANDERS=""; Z2_POSITIV=0
FAM_BELEGT=""
pfad() { # pfad <familie|-> <fund 0|1> <pfad> : Datei mit erfundenem Schluessel im Baum, versioniert vorgemerkt; Erwartung dazu
  local fam="$1" fund="$2" p="$3" n=0 e
  schluessel_in "$p"
  vers "$p"
  FUND_SUMME=$((FUND_SUMME + fund))
  if [ "$fam" != "-" ]; then
    for e in "${FAM_ERW[@]:-}"; do case "$e" in "$fam "*) n=$((n + 1)) ;; esac; done
    [ "$n" -lt 5 ] || herstellung_fehler "mehr als fuenf Pfade der Familie $fam in einem Fall"
    FAM_ERW+=("$fam $p")
    case " $FAM_BELEGT " in *" $fam "*) ;; *) FAM_BELEGT="$FAM_BELEGT $fam" ;; esac
  fi
}
famerw() { FAM_ERW+=("$1 $2"); case " $FAM_BELEGT " in *" $1 "*) ;; *) FAM_BELEGT="$FAM_BELEGT $1" ;; esac; }
harmlos() { datei "$1" "harmlos"; vers "$1"; }
soll() { # soll <marke> <L1> <L2> : Marke A_OK, A_FAIL oder C:<name>; L1 und L2 Zahl, "-" (kein Ergebnis), "P" (Summe der Pfade) oder "*"
  ERW_MARKE="$1"; ERW_L1="$2"; ERW_L2="$3"
  [ "$ERW_L1" != "P" ] || ERW_L1="$FUND_SUMME"
  [ "$ERW_L2" != "P" ] || ERW_L2="$FUND_SUMME"
}
mit() { MIT+=("$1"); }
ohne() { OHNE+=("$1"); }
env_zusatz() { ENV_ZUSATZ+=("$1"); }
make_arg() { MAKE_ARGS+=("$1"); }
nicht_herstellbar() { NH_GRUND="$1"; }
nach_lauf() { NACH_FN="$1"; }
z2_positiv() { Z2_POSITIV=1; }
cwd_anders() { CWD_ANDERS="$1"; }

# Kasten: Verzeichnis mit eigenen Dateien (Aufruf per absolutem Pfad) fuer alle Werkzeuge ausser den genannten
kasten() { # kasten <name> [<fehlendes werkzeug>...] ; setzt KASTEN_PFAD
  local name="$1" w skip s; shift
  KASTEN_PFAD="$T/kasten/$name"
  mkdir -p "$KASTEN_PFAD" || herstellung_fehler "Kasten $name"
  for w in $KASTEN_WERKZEUGE; do
    skip=0
    for s in "$@"; do [ "$s" = "$w" ] && skip=1; done
    [ "$skip" -eq 1 ] && continue
    [ -e "$KASTEN_PFAD/$w" ] && continue
    printf '#!/bin/sh\nexec %s "$@"\n' "$(command -v "$w")" > "$KASTEN_PFAD/$w" || herstellung_fehler "Kasten $name/$w"
    chmod +x "$KASTEN_PFAD/$w"
  done
}
ersatz() { # ersatz <werkzeug> : Inhalt von der Standardeingabe als eigene Datei in der Ersatzablage des Falls (vorne im Suchpfad)
  local d="$T/ers/$FALL_K"
  mkdir -p "$d" || herstellung_fehler "Ersatzablage"
  cat > "$d/$1" || herstellung_fehler "Ersatz $1"
  chmod +x "$d/$1"
  PFAD_VORNE="$d"
}
null_commits_ersatz() { # gitleaks meldet fuer den Historienlauf "0 commits scanned" mit 0, sonst das echte
  ersatz gitleaks <<EOS
#!/bin/sh
for a in "\$@"; do case "\$a" in --log-opts*) printf '\033[90m5:00AM\033[0m \033[32mINF\033[0m 0 commits scanned.\n' >&2; exit 0 ;; esac; done
exec $GL_BIN "\$@"
EOS
}
stille_ersatz() { # gitleaks meldet fuer den Historienlauf nichts (keine Zeile) mit 0, sonst das echte
  ersatz gitleaks <<EOS
#!/bin/sh
for a in "\$@"; do case "\$a" in --log-opts*) exit 0 ;; esac; done
exec $GL_BIN "\$@"
EOS
}

# Grundstand des Baums: Makefile (Quelle des Falls), scripts/gitleaks.toml, README.md, docs/a.md; ein Commit
baum_neu() {
  rm -rf "$BAUM"; mkdir -p "$BAUM/scripts" "$BAUM/docs" || herstellung_fehler "Baum"
  cp "$MAKEFILE_QUELLE" "$BAUM/Makefile" || herstellung_fehler "Makefile"
  cp "$TOML_ECHT" "$BAUM/scripts/gitleaks.toml" || herstellung_fehler "gitleaks.toml"
  printf 'Wegwerf-Repository des Falls %s\n' "$FALL_K" > "$BAUM/README.md"
  printf 'harmlos\n' > "$BAUM/docs/a.md"
  gitg -C "$BAUM" init -q -b main . || herstellung_fehler "git init"
  gitg -C "$BAUM" add -f -A || herstellung_fehler "git add"
  commit "Grundstand"
}

MELDUNGEN=()
fehler() { MELDUNGEN+=("$1"); }

# Auswertung eines Laufs
lauf_zahl() { # lauf_zahl <abschnitt>
  local t="$1" n
  if printf '%s\n' "$t" | grep -q 'no leaks found'; then echo 0; return; fi
  n=$(printf '%s\n' "$t" | sed -nE 's/.*leaks found: ([0-9]+).*/\1/p' | tail -n 1)
  echo "${n:--}"
}

fall_lauf() { # fall_lauf <id> : fuehrt Fallfunktion und Rezept aus; setzt FALL_ERG (pass, fail, nh) und MELDUNGEN
  local id="$1" fn="f_${1/-/}" rc=0 klar abschn1 abschn2 marke_n marke m l1 l2 z2 ist soll_s e zeile cur f tmpf pfadv fam_ist=() fam_soll=() vor nach
  FALL_K="$id"; MELDUNGEN=(); FALL_ERG="pass"; UMFELD_LOG=""
  ERW_MARKE=""; ERW_L1="*"; ERW_L2="*"; FUND_SUMME=0; FAM_ERW=(); MIT=(); OHNE=(); ENV_ZUSATZ=(); MAKE_ARGS=(); NH_GRUND=""; NACH_FN=""; PFAD_VORNE=""; KASTEN_PFAD=""; CWD_ANDERS=""; Z2_POSITIV=0; FAM_BELEGT=""; HOME_FALL=""
  BAUM="$T/faelle/$id"
  baum_neu
  if ! declare -F "$fn" >/dev/null; then herstellung_fehler "Funktion $fn fehlt"; fi
  "$fn"
  if [ -n "$NH_GRUND" ]; then FALL_ERG="nh"; MELDUNGEN+=("nicht herstellbar: $NH_GRUND"); return 0; fi
  tmpf="$T/tmp/$id"; rm -rf "$tmpf"; mkdir -p "$tmpf" || herstellung_fehler "TMPDIR des Falls"
  pfadv="${KASTEN_PFAD:-$PATH}"
  [ -z "$PFAD_VORNE" ] || pfadv="$PFAD_VORNE:$pfadv"
  vor=$(schnappschuss "$BAUM" 2>&1)
  local cwd="$BAUM"; [ -z "$CWD_ANDERS" ] || cwd="$CWD_ANDERS"
  ( cd "$cwd" && timeout 120 env -i "PATH=$pfadv" "HOME=${HOME_FALL:-$HOME_LEER}" "LC_ALL=C" "TZ=UTC" "TMPDIR=$tmpf" "${ENV_ZUSATZ[@]}" "$MAKE_BIN" -f "$BAUM/Makefile" "${MAKE_ARGS[@]}" geheimnisse ) > "$T/aus/$id.roh" 2>&1
  rc=$?
  klar="$T/aus/$id.txt"
  sed 's/\x1b\[[0-9;]*m//g' "$T/aus/$id.roh" > "$klar"
  nach=$(schnappschuss "$BAUM" 2>&1)
  # Marke: genau eine
  marke_n=$(grep -c '^::LAGE ' "$klar" || true)
  [ "$marke_n" = 1 ] || fehler "Zahl der Marken: $marke_n statt 1 (Rueckgabewert $rc)"
  m=$(sed -nE 's/^::LAGE [^ ]+ D11 geheimnisse ([A-Z_]+)( FEHLT=([^ :]+))?::$/\1 \3/p' "$klar" | head -n 1)
  marke="${m%% *}"; [ -z "${m#* }" ] || marke="$marke:${m#* }"
  [ "$marke" = "$ERW_MARKE" ] || fehler "Marke '$marke' statt '$ERW_MARKE'"
  if [ "$ERW_MARKE" = "A_OK" ]; then [ "$rc" -eq 0 ] || fehler "Rueckgabewert $rc statt 0"; else [ "$rc" -ne 0 ] || fehler "Rueckgabewert 0 bei Marke '$ERW_MARKE'"; fi
  # Laeufe
  abschn1=$(sed -n '/Lauf 1\/2/,/Lauf 2\/2/p' "$klar")
  abschn2=$(sed -n '/Lauf 2\/2/,$p' "$klar")
  l1=$(lauf_zahl "$abschn1"); l2=$(lauf_zahl "$abschn2")
  [ "$ERW_L1" = "*" ] || [ "$l1" = "$ERW_L1" ] || fehler "Fundzahl Lauf 1: $l1 statt $ERW_L1"
  [ "$ERW_L2" = "*" ] || [ "$l2" = "$ERW_L2" ] || fehler "Fundzahl Lauf 2: $l2 statt $ERW_L2"
  if [ "$Z2_POSITIV" -eq 1 ]; then
    z2=$(printf '%s\n' "$abschn2" | sed -nE 's/.* ([0-9]+) commits scanned\..*/\1/p' | tail -n 1)
    case "$z2" in ''|*[!0-9]*) fehler "Zahl der gelesenen Commits fehlt" ;; *) [ "$z2" -gt 0 ] || fehler "Zahl der gelesenen Commits ist $z2" ;; esac
  fi
  # Familienbloecke
  cur=""
  while IFS= read -r zeile; do
    case "$zeile" in
      *"Selbstpruefung: Pfade der Familie "*) f="${zeile#*Pfade der Familie }"; cur="${f%%,*}" ;;
      "    "*) [ -z "$cur" ] || fam_ist+=("$cur ${zeile#    }") ;;
      *) cur="" ;;
    esac
  done < "$klar"
  ist=$(printf '%s\n' "${fam_ist[@]:-}" | sort); soll_s=$(printf '%s\n' "${FAM_ERW[@]:-}" | sort)
  [ "$ist" = "$soll_s" ] || fehler "Familienmeldungen: [$(printf '%s' "$ist" | tr '\n' ';')] statt [$(printf '%s' "$soll_s" | tr '\n' ';')]"
  for e in "${MIT[@]:-}"; do [ -z "$e" ] || grep -qF -e "$e" "$klar" || fehler "Ausgabe ohne '$e'"; done
  for e in "${OHNE[@]:-}"; do [ -z "$e" ] || ! grep -qF -e "$e" "$klar" || fehler "Ausgabe mit '$e'"; done
  # schreibfrei: Baum unveraendert, Ablage leer
  [ "$vor" = "$nach" ] || fehler "der Baum des Falls hat sich veraendert"
  [ -z "$(ls -A "$tmpf" 2>/dev/null)" ] || fehler "die Ablage des Laufs ist nicht leer: $(ls -A "$tmpf" | head -n 3 | tr '\n' ' ')"
  if [ -n "$NACH_FN" ]; then "$NACH_FN"; fi
  [ "${#MELDUNGEN[@]}" -eq 0 ] || FALL_ERG="fail"
  return 0
}

# =============================================================================
# FALLLISTE (Datenblock): Kennung|Klassen|Soll|Herkunft|Gegenstand
# =============================================================================
#F|S-001|KS-1|fail|SR-016 (a)|Familien venv, lib-python, dist-info: je ein Pfad mit Schluessel, Meldung der Familie, Fundzahl 0
#F|S-002|KS-1|fail|SR-016 (a), (b3)|Familien node_modules, gitleaks-toml, vendor-go, bower, vendor-ruby
#F|S-003|KS-1|fail|ST-N24-01|Familie endung-ohne-punkt: foodoc, x/zip, abin, a.Wsuo, xWsuo
#F|S-004|KS-1|fail|SR-016 (b3)|Familie bau-dateien, Teilmuster 1 bis 5 (vendor/modules.txt, gradlew, gradle.lockfile, mvnw, MavenWrapperDownloader.java)
#F|S-005|KS-1|fail|SR-016 (b3)|Familie bau-dateien, Teilmuster 6 bis 9 (jquery, swagger-ui, verification-metadata.xml, Database.refactorlog, go.mod)
#F|S-006|KS-1|fail|SR-016 (b3)|Familie bau-dateien, Teilmuster go.work, go.work.sum, @octokit/auth-token/README.md (nur Regel-Ueberspringen: Fund 1)
#F|S-007|KS-1|fail|SR-016|Nachbarpfade der Familien mit Schluessel: A_FAIL allein durch den Fund, keine Familienmeldung
#F|S-008|KS-1|ok|SR-016|Nachbarpfade ohne Schluessel: A_OK, die Selbstpruefung meldet keinen Pfad
#F|S-009|KS-1|fail|ST-N24-01|a.WSUO: A_FAIL allein aus dem Fund (Gross- und Kleinschreibung nach (g))
#F|S-010|KS-1|fail|SR-016|Pfade, die ein Muster mit (?i) in Grossschreibung ueberspringt (ENV/LIB, Lib/Python3.11, DIST-INFO)
#F|S-011|KS-1|fail|SR-016|weitere Nachbarpfade der Familien bau-dateien und endung-ohne-punkt mit Schluessel: A_FAIL allein durch den Fund
#F|S-012|KS-1,GS-1|ok|SR-016 (b2)|Durchlass: akzeptierte Dateiarten mit Punkt und Sperrdateien (x.svg, a.zip, package-lock.json, yarn.lock, go.sum): A_OK, Fundzahl 0
#F|S-013|KS-1,GS-1|ok|SR-016 (b2)|Durchlass: pnpm-lock.yaml, npm-shrinkwrap.json, a.wsuo, x.gem, Pipfile.lock: A_OK, Fundzahl 0
#F|S-014|KS-3,GS-2|ok|DT-G1-01|Durchlass: fruehere Fassung von scripts/gitleaks.toml mit Schluessel in der Historie
#F|S-015|KS-3,GS-3|ok|DT-G1-01|Durchlass: Datei und Sollwert zusammen geaendert
#F|S-016|GS-4|fail|DT-G1-06|Einstellungen in .git/config ausserhalb der gemessenen: Fund in der Historie bleibt sichtbar
#F|S-017|GS-5|nh|DT-G1-06|Systemkonfiguration von git: nur in eigenem Mount-Namensraum herstellbar
#F|S-020|KS-2,KS-8|fail|DT-G1-01|Schluessel unversioniert im Arbeitsbaum: Lauf 1 findet, Lauf 2 nicht; schreibfrei
#F|S-021|KS-2|fail|SR-014|Schluessel nur in der Historie: Lauf 2 findet
#F|S-022|KS-2|fail|DT-G1-08|Schluessel nur in einer Merge-Aufloesung (-m)
#F|S-023|KS-2|fail|DT-G1-06|Schluessel im Wurzel-Commit bei log.showRoot=false (--root)
#F|S-024|KS-2|fail|DT-G1-06|Schluessel nur in der Historie bei "* -diff" in .git/info/attributes (--text)
#F|S-025|KS-2|fail|DT-G1-06|Schluessel nur in der Historie bei textconv-Treiber (--no-textconv)
#F|S-026|KS-2|fail|DT-G1-06|Schluessel nur in der Historie bei color.ui=always (--no-color)
#F|S-027|KS-2|fail|SR-015|Schluessel mit Inline-Marke zum Unterdruecken (--ignore-gitleaks-allow)
#F|S-028|KS-2|fail|SR-019|Schluessel nach einem Ersatzobjekt (GIT_NO_REPLACE_OBJECTS)
#F|S-029|KS-2|ok|SR-014|Schluessel entfernt und nie committet: kein Fund, A_OK
#F|S-030|KS-3|fail|SR-014|.gitleaks.toml im Baum ohne Regeln (--config)
#F|S-031|KS-3|fail|SR-014|GITLEAKS_CONFIG mit leerer Datei im Umfeld des Aufrufers
#F|S-032|KS-3|fail|SR-017|.gitleaksignore im Baum unterdrueckt den Fund: Meldung, A_FAIL
#F|S-033|KS-3|fail|DT-G1-01|scripts/gitleaks.toml veraendert: Summe weicht ab
#F|S-034|KS-3|lage-c|SR-014|scripts/gitleaks.toml fehlt: Lage C
#F|S-035|KS-3|lage-c|DT-G1-01|sha256sum fehlt: Lage C
#F|S-036|KS-3|fail|DT-G1-01|override: Summe auf der Befehlszeile ersetzt den Sollwert nicht
#F|S-040|KS-4|fail|DT-G1-06|GIT_DIR des Aufrufers zeigt auf ein anderes Repository
#F|S-041|KS-4|fail|DT-G1-06|HOME des Aufrufers mit attributes "* -diff"
#F|S-042|KS-4|ok|DT-G1-06|Umfeld der Aufrufe von gitleaks: genau die gesetzten Variablen, leeres HOME
#F|S-043|KS-4|fail|DT-G1-06|Arbeitsverzeichnis des Aufrufers ist ein anderes Verzeichnis
#F|S-050|KS-5,KS-6,KS-7,KS-8|ok|DT-G1-05|Lauf am Geruest mit allen Werkzeugen: A_OK, Commits gelesen groesser 0, eine Marke, schreibfrei
#F|S-051|KS-5|lage-c|SR-014|gitleaks fehlt: Lage C
#F|S-052|KS-5|lage-c|SR-014|git fehlt: Lage C, Lauf 1 laeuft
#F|S-053|KS-5|lage-c|SR-014|kein Arbeitsbaum: Lage C git-arbeitsbaum
#F|S-054|KS-5|lage-c|SR-018|git log schreibt auf stderr (Grafts): Lage C git-log
#F|S-055|KS-5|lage-c|DT-G1-06|mktemp scheitert: A_FAIL-Zweige und Lage C git-log
#F|S-056|KS-5|lage-c|DT-G1-08|git log scheitert nur mit -m (Merge-Commit mit fehlendem Baum): Lage C git-log
#F|S-060|KS-6|lage-c|DT-G1-05|Ersatz fuer gitleaks meldet 0 commits scanned mit 0: Lage C gitleaks-historie
#F|S-061|KS-6|lage-c|DT-G1-05|Ersatz fuer gitleaks meldet keine Zeile mit 0: Lage C gitleaks-historie
#F|S-062|KS-6|lage-c|SD-N32-02|Ersatz fuer gitleaks schreibt die Zeile N commits scanned nur auf stdout: Lage C gitleaks-historie
#F|S-063|KS-6|lage-c|SD-N32-01|Ersatz fuer gitleaks schreibt zwei Zeilen (7 und 0 commits scanned): mehrere Zeilen sind Lage C gitleaks-historie
#F|S-064|KS-5,KS-6|lage-c|ST-N32-04|mktemp scheitert erst beim vierten Aufruf (Datei fuer die Ausgabe von Lauf 2): Lage C gitleaks-historie
#F|S-070|KS-7|lage-c|SR-014|A_FAIL und Lage C zugleich: Fund in Lauf 1 und 0 commits scanned in Lauf 2; die Marke zeigt Lage C
#F|S-071|KS-7|fail|SR-014|beide Laeufe finden: Fund im Baum und in der Historie, beide Befunde erscheinen
#F|S-072|KS-7|fail|SR-014|Lauf 1 findet, Lauf 2 laeuft trotzdem weiter und findet nichts (Schluessel nur im Baum, Historie leer)

# =============================================================================
# FALLFUNKTIONEN
# =============================================================================
f_S001() {
  pfad venv 0 env/lib/a.txt; pfad venv 0 virtualenv/lib64/b.txt
  pfad lib-python 0 lib/python3.11/x.txt
  pfad dist-info 0 pkg-1.0.dist-info/RECORD
  commit; soll A_FAIL P P
}
f_S002() {
  pfad node_modules 0 node_modules/a/b.js
  pfad gitleaks-toml 0 docs/gitleaks.toml
  pfad vendor-go 0 vendor/github.com/x/y.go
  pfad bower 0 bower_components/a.js
  pfad vendor-ruby 0 vendor/bundle/a.rb; pfad vendor-ruby 0 vendor/ruby/b.rb
  commit; soll A_FAIL P P
}
f_S003() {
  pfad endung-ohne-punkt 0 foodoc; pfad endung-ohne-punkt 0 x/zip; pfad endung-ohne-punkt 0 abin
  pfad endung-ohne-punkt 0 a.Wsuo; pfad endung-ohne-punkt 0 xWsuo
  commit; soll A_FAIL P P
}
f_S004() {
  pfad bau-dateien 0 vendor/modules.txt; pfad bau-dateien 0 gradlew; pfad bau-dateien 0 gradle.lockfile
  pfad bau-dateien 0 mvnw; pfad bau-dateien 0 .mvn/wrapper/MavenWrapperDownloader.java
  commit; soll A_FAIL P P
}
f_S005() {
  pfad bau-dateien 0 web/jquery-3.6.0.js; pfad bau-dateien 0 swagger-ui-bundle.js
  pfad bau-dateien 0 verification-metadata.xml; pfad bau-dateien 0 Database.refactorlog; pfad bau-dateien 0 go.mod
  commit; soll A_FAIL P P
}
f_S006() {
  pfad bau-dateien 0 go.work; pfad bau-dateien 0 go.work.sum
  pfad bau-dateien 1 @octokit/auth-token/README.md
  commit; soll A_FAIL P P
}
f_S007() {
  pfad - 1 env/libs/a.txt; pfad - 1 lib/python/a.txt; pfad - 1 node_module/a.txt; pfad - 1 vendor/gems/a.rb; pfad - 1 bower_component/a.js
  commit; soll A_FAIL P P; ohne "Pfade der Familie"
}
f_S008() {
  harmlos env/libs/a.txt; harmlos lib/python/a.txt; harmlos node_module/a.txt; harmlos vendor/gems/a.rb; harmlos bower_component/a.js
  harmlos vendors/modules.txt; harmlos xgradlew; harmlos jquery.js; harmlos go.modx; harmlos data.zipx
  commit; soll A_OK 0 0; mit "kein Pfad im Baum unter den zehn Familien"; z2_positiv
}
f_S009() {
  pfad - 1 a.WSUO; commit; soll A_FAIL P P; ohne "Pfade der Familie"
}
f_S010() {
  pfad venv 0 ENV/LIB/a.txt; pfad lib-python 0 Lib/Python3.11/b; pfad dist-info 0 pkg-1.0.DIST-INFO/x
  commit; soll A_FAIL P P
}
f_S011() {
  pfad - 1 vendors/modules.txt; pfad - 1 xgradlew; pfad - 1 jquery.js; pfad - 1 go.modx; pfad - 1 data.zipx
  commit; soll A_FAIL P P; ohne "Pfade der Familie"
}
f_S012() {
  pfad - 0 x.svg; pfad - 0 a.zip; pfad - 0 package-lock.json; pfad - 0 yarn.lock; pfad - 0 go.sum
  commit; soll A_OK P P; z2_positiv
}
f_S013() {
  pfad - 0 pnpm-lock.yaml; pfad - 0 npm-shrinkwrap.json; pfad - 0 a.wsuo; pfad - 0 x.gem; pfad - 0 Pipfile.lock
  commit; soll A_OK P P
}
f_S014() { # frueheren Stand von scripts/gitleaks.toml mit Schluessel committen, dann den Sollstand wiederherstellen
  { cat "$TOML_ECHT"; sed 's/^/# /' <(schluessel_text); } > "$BAUM/scripts/gitleaks.toml"
  vers scripts/gitleaks.toml; commit "fruehere Fassung"
  cp "$TOML_ECHT" "$BAUM/scripts/gitleaks.toml"; vers scripts/gitleaks.toml; commit "Sollstand"
  soll A_OK 0 0
}
f_S015() { # Datei und Sollwert zusammen geaendert: Schluessel als Kommentarzeilen in der Datei, neue Summe im Makefile
  local alt neu
  { cat "$TOML_ECHT"; sed 's/^/# /' <(schluessel_text); } > "$BAUM/scripts/gitleaks.toml"
  alt=$(sed -nE 's/^override GITLEAKS_KONFIG_SHA256 := ([0-9a-f]{64})$/\1/p' "$BAUM/Makefile" | head -n 1)
  neu=$(sha256sum < "$BAUM/scripts/gitleaks.toml" | cut -d' ' -f1)
  [ -n "$alt" ] || herstellung_fehler "Sollwert im Makefile nicht gefunden"
  sed -i "s/$alt/$neu/" "$BAUM/Makefile" || herstellung_fehler "sed"
  alles_committen; soll A_OK 0 0
}
f_S016() { # zwoelf Einstellungen, die den Historienlauf nicht blenden; Schluessel nur in der Historie
  local kv
  schluessel_in docs/k.txt; vers docs/k.txt; commit "Schluessel"; entfernen docs/k.txt; commit "entfernt"
  for kv in diff.noprefix=true diff.mnemonicPrefix=true diff.srcPrefix=X/ diff.dstPrefix=Y/ format.pretty=oneline log.decorate=full log.date=iso diff.renames=copies diff.algorithm=patience diff.colorMoved=zebra log.abbrevCommit=true core.quotePath=false; do
    gitg -C "$BAUM" config "${kv%%=*}" "${kv#*=}" || herstellung_fehler "git config $kv"
  done
  soll A_FAIL 0 1
}
f_S017() { nicht_herstellbar "die Systemkonfiguration von git ist nur in eigenem Mount-Namensraum herstellbar (kein unshare im Pruefmittel; wie N4-sys in G1)"; soll A_FAIL 0 1; }

f_S020() { schluessel_in k.txt; soll A_FAIL 1 0; mit "Lauf 2/2"; }
f_S021() { schluessel_in docs/k.txt; vers docs/k.txt; commit "Schluessel"; entfernen docs/k.txt; commit "entfernt"; soll A_FAIL 0 1; }
f_S022() { # -m liest den Merge-Commit je Elternteil: der Fund erscheint zweimal
  gitg -C "$BAUM" checkout -q -b zweig || herstellung_fehler "branch"
  datei docs/b.md "b"; vers docs/b.md; commit "zweig"
  gitg -C "$BAUM" checkout -q main || herstellung_fehler "checkout"
  datei docs/c.md "c"; vers docs/c.md; commit "main"
  gitg -C "$BAUM" merge -q --no-ff --no-commit zweig >/dev/null 2>&1 || herstellung_fehler "merge"
  schluessel_in docs/m.txt; vers docs/m.txt; commit "Merge mit Schluessel"
  entfernen docs/m.txt; commit "entfernt"
  soll A_FAIL 0 2
}
f_S023() { # Wurzel-Commit mit Schluessel, danach entfernt
  rm -rf "$BAUM/.git"; gitg -C "$BAUM" init -q -b main . || herstellung_fehler "init"
  schluessel_in docs/k.txt
  gitg -C "$BAUM" add -f -A || herstellung_fehler "add"; commit "Wurzel"
  entfernen docs/k.txt; commit "entfernt"
  gitg -C "$BAUM" config log.showRoot false
  soll A_FAIL 0 1
}
f_S024() { schluessel_in docs/k.txt; vers docs/k.txt; commit; entfernen docs/k.txt; commit "entfernt"; printf '* -diff\n' >> "$BAUM/.git/info/attributes"; soll A_FAIL 0 1; }
f_S025() {
  printf '*.txt diff=leer\n' > "$BAUM/.gitattributes"; vers .gitattributes; commit "attributes"
  schluessel_in docs/k.txt; vers docs/k.txt; commit; entfernen docs/k.txt; commit "entfernt"
  gitg -C "$BAUM" config diff.leer.textconv true
  soll A_FAIL 0 1
}
f_S026() { schluessel_in docs/k.txt; vers docs/k.txt; commit; entfernen docs/k.txt; commit "entfernt"; gitg -C "$BAUM" config color.ui always; soll A_FAIL 0 1; }
f_S027() {
  aws_text | sed 's/$/ gitleaks:'"allow"'/' > "$BAUM/docs/aws.txt"; vers docs/aws.txt; commit
  soll A_FAIL 1 1
}
f_S028() { # Ersatzobjekt: der Commit mit Schluessel wird durch den harmlosen Vorgaenger ersetzt
  local a b
  a=$(gitg -C "$BAUM" rev-parse HEAD)
  schluessel_in docs/k.txt; vers docs/k.txt; commit "Schluessel"
  b=$(gitg -C "$BAUM" rev-parse HEAD)
  entfernen docs/k.txt; commit "entfernt"
  gitg -C "$BAUM" replace "$b" "$a" || herstellung_fehler "git replace"
  soll A_FAIL 0 1
}
f_S029() { schluessel_in docs/k.txt; rm -f "$BAUM/docs/k.txt"; commit; soll A_OK 0 0; z2_positiv; }

f_S030() {
  printf 'title = "leer"\n' > "$BAUM/.gitleaks.toml"
  pfad - 1 docs/k.txt
  vers .gitleaks.toml; famerw gitleaks-toml .gitleaks.toml
  commit; soll A_FAIL P P
}
f_S031() {
  : > "$T/leer.toml"
  env_zusatz "GITLEAKS_CONFIG=$T/leer.toml"
  pfad - 1 docs/k.txt; commit; soll A_FAIL P P
}
f_S032() {
  pfad - 1 k.txt; printf 'k.txt:private-key:1\n' > "$BAUM/.gitleaksignore"; commit
  soll A_FAIL 0 0; mit ".gitleaksignore im Arbeitsbaum"
}
f_S033() { printf '# geaendert\n' >> "$BAUM/scripts/gitleaks.toml"; alles_committen; soll A_FAIL 0 0; mit "scripts/gitleaks.toml veraendert"; }
f_S034() { rm -f "$BAUM/scripts/gitleaks.toml"; alles_committen; soll C:scripts/gitleaks.toml - -; mit "scripts/gitleaks.toml fehlt"; }
f_S035() { kasten ohne-sha256sum sha256sum; soll C:sha256sum - -; mit "'sha256sum' ist nicht installiert"; }
f_S036() {
  local neu
  printf '# geaendert\n' >> "$BAUM/scripts/gitleaks.toml"; alles_committen
  neu=$(sha256sum < "$BAUM/scripts/gitleaks.toml" | cut -d' ' -f1)
  make_arg "GITLEAKS_KONFIG_SHA256=$neu"
  soll A_FAIL 0 0; mit "scripts/gitleaks.toml veraendert"
}

f_S040() { # GIT_DIR des Aufrufers zeigt auf ein anderes, harmloses Repository; der Schluessel steht nur in der Historie des Baums
  local anders="$T/anders-$FALL_K"
  rm -rf "$anders"; mkdir -p "$anders"; gitg -C "$anders" init -q -b main .; printf 'x\n' > "$anders/x"; gitg -C "$anders" add x; gitg -C "$anders" commit -q -m x
  schluessel_in docs/k.txt; vers docs/k.txt; commit; entfernen docs/k.txt; commit "entfernt"
  env_zusatz "GIT_DIR=$anders/.git"
  soll A_FAIL 0 1
}
f_S041() { # HOME des Aufrufers fuehrt "* -diff" (Ausschlussliste: attributes, Konfiguration in HOME); Schluessel nur in der Historie
  local h="$T/home-$FALL_K"
  rm -rf "$h"; mkdir -p "$h/.config/git"
  printf '* -diff\n' > "$h/.config/git/attributes"
  printf '[color]\n\tui = always\n[log]\n\tshowRoot = false\n' > "$h/.gitconfig"
  schluessel_in docs/k.txt; vers docs/k.txt; commit; entfernen docs/k.txt; commit "entfernt"
  HOME_FALL="$h"
  soll A_FAIL 0 1
}
f_S042() { # gitleaks wird mit genau den gesetzten Variablen aufgerufen
  local log="$T/umfeld-$FALL_K.log"
  : > "$log"
  ersatz gitleaks <<EOS
#!/bin/sh
$(command -v env) | $(command -v grep) -E '^(GIT_|GITLEAKS|HOME=|XDG_|TMPDIR=)' | $(command -v sort) >> $log
echo '--' >> $log
exec $GL_BIN "\$@"
EOS
  : > "$T/leer-$FALL_K.toml"
  env_zusatz "GITLEAKS_CONFIG=$T/leer-$FALL_K.toml"; env_zusatz "GIT_CONFIG_COUNT=1"; env_zusatz "GIT_CONFIG_KEY_0=color.ui"; env_zusatz "GIT_CONFIG_VALUE_0=always"
  env_zusatz "GIT_CONFIG_GLOBAL=/dev/null"; env_zusatz "XDG_CONFIG_HOME=$T/xdg"; env_zusatz "GIT_TRACE=0"
  UMFELD_LOG="$log"
  nach_lauf nl_umfeld
  soll A_OK 0 "*"
}
nl_umfeld() {
  local n h
  n=$(grep -c '^--$' "$UMFELD_LOG" || true)
  [ "$n" = 2 ] || fehler "Zahl der Aufrufe von gitleaks: $n statt 2"
  [ "$(grep -v -e '^--$' -e '^HOME=' "$UMFELD_LOG" | sort | uniq -c | tr -s ' ' | tr '\n' ';')" = " 2 GIT_ATTR_NOSYSTEM=1; 2 GIT_CONFIG_NOSYSTEM=1; 2 GIT_NO_REPLACE_OBJECTS=1;" ] || fehler "Variablen der Aufrufe von gitleaks: $(grep -v -e '^--$' -e '^HOME=' "$UMFELD_LOG" | sort | uniq -c | tr -s ' ' | tr '\n' ';')"
  for h in $(grep '^HOME=' "$UMFELD_LOG" | cut -d= -f2-); do
    case "$h" in "$HOME_LEER"|"") fehler "HOME der Aufrufe von gitleaks ist das HOME des Aufrufers oder leer" ;; /*) ;; *) fehler "HOME der Aufrufe von gitleaks ist nicht absolut: $h" ;; esac
  done
  [ "$(grep -c '^HOME=' "$UMFELD_LOG" || true)" = 2 ] || fehler "HOME fehlt in einem Aufruf von gitleaks"
}
f_S043() { # Aufrufer steht in einem anderen Verzeichnis (ohne Repository)
  local anders="$T/cwd-$FALL_K"
  mkdir -p "$anders"
  schluessel_in docs/k.txt; vers docs/k.txt; commit
  cwd_anders "$anders"
  soll A_FAIL 1 1
}

f_S050() { soll A_OK 0 0; z2_positiv; mit "Selbstpruefung: kein Pfad im Baum unter den zehn Familien"; mit "Lage A -- bestanden"; }
f_S051() { kasten ohne-gitleaks gitleaks; soll C:gitleaks - -; mit "'gitleaks' ist nicht installiert"; }
f_S052() { kasten ohne-git git; soll C:git 0 -; mit "'git' ist nicht installiert"; }
f_S053() { rm -rf "$BAUM/.git"; : > "$BAUM/CLAUDE.md"; soll C:git-arbeitsbaum 0 -; mit "kein Git-Arbeitsbaum"; }
f_S054() { printf '%s\n' "$(gitg -C "$BAUM" rev-parse HEAD)" > "$BAUM/.git/info/grafts"; soll C:git-log 0 -; mit "git log schreibt auf stderr"; }
f_S055() {
  ersatz mktemp <<'EOS'
#!/bin/sh
exit 1
EOS
  soll C:git-log 0 -; mit "Umfeld nicht herstellbar"
}
f_S056() { # Merge-Commit, dessen eigener Baum fehlt: git log -p -m scheitert, ohne -m nicht
  local m
  gitg -C "$BAUM" checkout -q -b zweig || herstellung_fehler "branch"
  datei docs/b.md "b"; vers docs/b.md; commit "zweig"
  gitg -C "$BAUM" checkout -q main || herstellung_fehler "checkout"
  datei docs/c.md "c"; vers docs/c.md; commit "main"
  gitg -C "$BAUM" merge -q --no-ff --no-commit zweig >/dev/null 2>&1 || herstellung_fehler "merge"
  datei docs/m.md "nur im Merge"; vers docs/m.md; commit "Merge"
  m=$(gitg -C "$BAUM" rev-parse 'HEAD^{tree}')
  chmod -R u+w "$BAUM/.git/objects" 2>/dev/null
  rm -f "$BAUM/.git/objects/${m:0:2}/${m:2}" || herstellung_fehler "Baumobjekt"
  soll C:git-log 0 -
}
f_S060() { null_commits_ersatz; soll C:gitleaks-historie 0 -; mit "0 commits scanned"; }
f_S061() { stille_ersatz; soll C:gitleaks-historie 0 -; }
ersatz_zeilen() { # ersatz_zeilen <kanal 1|2> <zahl>... : gitleaks schreibt fuer den Historienlauf je Zahl eine Zeile "N commits scanned." (mit Farbcodes) auf den Kanal, endet mit 0; sonst das echte
  local kanal="$1" z zeilen=""; shift
  for z in "$@"; do zeilen="$zeilen printf '\\033[90m5:00AM\\033[0m \\033[32mINF\\033[0m $z commits scanned.\\n' >&$kanal;"; done
  ersatz gitleaks <<EOS
#!/bin/sh
for a in "\$@"; do case "\$a" in --log-opts*) $zeilen exit 0 ;; esac; done
exec $GL_BIN "\$@"
EOS
}
f_S062() { ersatz_zeilen 1 7; soll C:gitleaks-historie 0 -; }
f_S063() { ersatz_zeilen 2 7 0; soll C:gitleaks-historie 0 -; }
f_S064() { # mktemp: Aufrufe des Rezepts: HOME, Selbstpruefung, Probe von git log, Ausgabe von Lauf 2 (der vierte scheitert)
  local zaehler="$T/ers/$FALL_K-zaehler" echt
  echt=$(command -v mktemp)
  : > "$zaehler"
  ersatz mktemp <<EOS
#!/bin/sh
read -r n < "$zaehler" || n=0
n=\$((n + 1))
echo "\$n" > "$zaehler"
if [ "\$n" -ge 4 ]; then exit 1; fi
exec $echt "\$@"
EOS
  echo 0 > "$zaehler"
  soll C:gitleaks-historie 0 0; mit "mktemp schlug fehl; die Ausgabe von Lauf 2"
}
f_S070() { null_commits_ersatz; schluessel_in docs/k.txt; soll C:gitleaks-historie 1 -; }
f_S071() { pfad - 1 docs/k.txt; commit; soll A_FAIL 1 1; mit "Lauf 1/2"; mit "Lauf 2/2"; }
f_S072() { schluessel_in docs/k.txt; soll A_FAIL 1 0; mit "Lauf 2/2"; z2_positiv; }

# =============================================================================
# DECKUNG
# =============================================================================
KENNUNGEN=(); declare -A K_KLASSEN K_SOLL
datenblock_lesen() {
  local z id kl so
  while IFS= read -r z; do
    case "$z" in
      '#F|'*) IFS='|' read -r _ id kl so _ <<<"$z"; KENNUNGEN+=("$id"); K_KLASSEN[$id]="$kl"; K_SOLL[$id]="$so" ;;
    esac
  done < "$SKRIPT_PFAD"
}
datenblock_lesen

DECK_ABW=()
deckung_pruefen() {
  local kopf_klassen k id so f kl ok fehl n funktionen fam
  kopf_klassen=$(sed -nE 's/^#   ((KS|GS)-[0-9]+)  .*/\1/p' "$SKRIPT_PFAD" | sort -u)
  # Funktionen gegen Kennungen
  funktionen=$(sed -nE 's/^f_S([0-9]+)\(\).*/S-\1/p' "$SKRIPT_PFAD" | sort)
  [ "$funktionen" = "$(printf '%s\n' "${KENNUNGEN[@]}" | sort)" ] || DECK_ABW+=("Kennungen der Liste und Fallfunktionen weichen ab")
  [ "$(printf '%s\n' "${KENNUNGEN[@]}" | sort | uniq -d | wc -l)" = 0 ] || DECK_ABW+=("doppelte Kennung")
  for k in $kopf_klassen; do
    n=0; ok=0; fehl=0
    for id in "${KENNUNGEN[@]}"; do
      case ",${K_KLASSEN[$id]}," in *",$k,"*) n=$((n + 1)); so="${K_SOLL[$id]}"; [ "$so" = ok ] && ok=$((ok + 1)); case "$so" in fail|lage-c) fehl=$((fehl + 1)) ;; esac ;; esac
    done
    case "$k" in
      KS-*) [ "$n" -gt 0 ] || DECK_ABW+=("Klasse $k ohne Fall"); [ "$ok" -gt 0 ] || DECK_ABW+=("Klasse $k ohne Fall mit Soll ok"); [ "$fehl" -gt 0 ] || DECK_ABW+=("Klasse $k ohne Fall mit Soll fail oder lage-c") ;;
      GS-*) [ "$n" -gt 0 ] || DECK_ABW+=("Grenze $k ohne Fall") ;;
    esac
  done
  for id in "${KENNUNGEN[@]}"; do
    IFS=',' read -r -a kl <<<"${K_KLASSEN[$id]}"
    for f in "${kl[@]}"; do case " $(echo $kopf_klassen) " in *" $f "*) ;; *) DECK_ABW+=("Fall $id nennt $f, im Kopfkommentar nicht genannt") ;; esac; done
  done
}
# Familienliste der Schleife im Rezept (aus der Kopie des Makefile gelesen)
familien_aus_makefile() { sed -nE 's/^[[:space:]]*for familie in ([a-z_ -]+); do[[:space:]]*$/\1/p' "$MAKEFILE_QUELLE" | head -n 1; }

# =============================================================================
# LAUF DER FAELLE
# =============================================================================
ANZ_B=0; ANZ_G=0; ANZ_H=0; GEFALLEN=(); NICHT_HERSTELLBAR=()
faelle_laufen() { # faelle_laufen : alle Faelle gegen MAKEFILE_QUELLE
  local id
  ANZ_B=0; ANZ_G=0; ANZ_H=0; GEFALLEN=(); NICHT_HERSTELLBAR=(); FAM_GEDECKT=""
  for id in "${KENNUNGEN[@]}"; do
    fall_lauf "$id"
    case "$FALL_ERG" in
      pass) ANZ_B=$((ANZ_B + 1)); case "${K_KLASSEN[$id]}" in *KS-1*) FAM_GEDECKT="$FAM_GEDECKT $FAM_BELEGT" ;; esac ;;
      nh) ANZ_H=$((ANZ_H + 1)); NICHT_HERSTELLBAR+=("$id: ${MELDUNGEN[0]}") ;;
      fail) ANZ_G=$((ANZ_G + 1)); GEFALLEN+=("$id"); printf '%s: GEFALLEN\n' "$id"; printf '    %s\n' "${MELDUNGEN[@]}" ;;
    esac
  done
}
gegenstandsdeckung() { # Familien des Makefile gegen die Familien der bestandenen Faelle
  local soll_fam ist_fam f
  soll_fam=$(familien_aus_makefile | tr ' ' '\n' | sort -u)
  ist_fam=$(printf '%s\n' $FAM_GEDECKT | sort -u)
  [ -n "$soll_fam" ] || { DECK_ABW+=("Familienliste im Rezept nicht lesbar"); return; }
  for f in $soll_fam; do case " $(echo $ist_fam) " in *" $f "*) ;; *) DECK_ABW+=("Familie $f im Rezept ohne bestandenen Fall in KS-1") ;; esac; done
  for f in $ist_fam; do case " $(echo $soll_fam) " in *" $f "*) ;; *) DECK_ABW+=("Familie $f im Fall, aber nicht in der Schleife des Rezepts") ;; esac; done
}

zeit0=$(date +%s)
deckung_pruefen
ENDE_RC=0

echo "$PM: gitleaks $GL_VER, Summe $GL_SUM; Arbeitsbaum $(git -C "$ARBEITSBAUM" rev-parse HEAD 2>/dev/null || echo unbekannt); Modus $MODUS"
HOME_FALL=""
faelle_laufen
echo "$PM: ${#KENNUNGEN[@]} Faelle: $ANZ_B bestanden, $ANZ_G gefallen, $ANZ_H nicht herstellbar"
for e in "${NICHT_HERSTELLBAR[@]:-}"; do [ -z "$e" ] || echo "$PM:   nicht herstellbar -- $e"; done
gegenstandsdeckung
echo "$PM: DECKUNG: ${#DECK_ABW[@]} Abweichung(en)"
for e in "${DECK_ABW[@]:-}"; do [ -z "$e" ] || echo "$PM:   Abweichung -- $e"; done
[ "$ANZ_G" -eq 0 ] || ENDE_RC=2
[ "${#DECK_ABW[@]}" -eq 0 ] || ENDE_RC=2

# =============================================================================
# MODUS --mutationen
# =============================================================================
if [ "$MODUS" = "mutationen" ]; then
  if [ "$ENDE_RC" -ne 0 ]; then
    echo "$PM: Grundlinie besteht nicht; keine Mutation geprueft."
    echo "$PM: Rueckgabewert 2"
    exit 2
  fi
  M_GEPRUEFT=0; M_ERKANNT=0; M_NICHT=0; M_WIRKUNGSLOS=0; M_IDS=(); MUT_ABW=(); MUT_KLASSEN_GEDECKT=""; fam_mutiert=""
  declare -A M_KLASSE M_MIN M_EXPR M_GRUND
  zeilen=0
  while IFS= read -r zeile || [ -n "$zeile" ]; do
    zeilen=$((zeilen + 1))
    case "$zeile" in ''|'#'*) continue ;; esac
    [ -z "$(printf '%s' "$zeile" | LC_ALL=C tr -d '\0-\177')" ] || lage_c_pm "Mutationsdatei Zeile $zeilen: Zeichen ausserhalb von ASCII."
    t="${zeile//[^$'\t']/}"
    [ "${#t}" -eq 4 ] || lage_c_pm "Mutationsdatei Zeile $zeilen: nicht genau vier Tabulatoren."
    IFS=$'\t' read -r mid mkl mexpr mmin mgrund <<<"$zeile"
    case "$mid" in SM-[0-9][0-9][0-9]) ;; *) lage_c_pm "Mutationsdatei Zeile $zeilen: Kennung '$mid' hat nicht die Form SM-nnn." ;; esac
    [ -n "$mkl" ] && [ -n "$mexpr" ] && [ -n "$mmin" ] && [ -n "$mgrund" ] || lage_c_pm "Mutationsdatei Zeile $zeilen: leeres Feld."
    for x in "${M_IDS[@]:-}"; do [ "$x" != "$mid" ] || lage_c_pm "Mutationsdatei: Kennung $mid doppelt."; done
    M_IDS+=("$mid"); M_KLASSE[$mid]="$mkl"; M_MIN[$mid]="$mmin"; M_EXPR[$mid]="$mexpr"; M_GRUND[$mid]="$mgrund"
  done < "$MUTATIONSDATEI"
  [ "${#M_IDS[@]}" -gt 0 ] || lage_c_pm "Mutationsdatei ohne Mutation."

  for mid in "${M_IDS[@]}"; do
    M_GEPRUEFT=$((M_GEPRUEFT + 1))
    mf="$T/mf/$mid"
    if ! sed -E --sandbox -e "${M_EXPR[$mid]}" "$MAKEFILE_ECHT" > "$mf" 2>"$T/mf/$mid.err"; then
      M_WIRKUNGSLOS=$((M_WIRKUNGSLOS + 1)); echo "$PM: $mid WIRKUNGSLOS (sed-Fehler)"; continue
    fi
    if cmp -s "$mf" "$MAKEFILE_ECHT"; then
      M_WIRKUNGSLOS=$((M_WIRKUNGSLOS + 1)); echo "$PM: $mid WIRKUNGSLOS (byte-gleich)"; continue
    fi
    MAKEFILE_QUELLE="$mf"
    # Lauffaehigkeit: das Rezept liefert auf dem Geruest noch genau eine Marke
    FALL_K="lauf-$mid"; BAUM="$T/faelle/lauf-$mid"
    baum_neu
    ( cd "$BAUM" && timeout 120 env -i "PATH=$PATH" "HOME=$HOME_LEER" LC_ALL=C TZ=UTC "TMPDIR=$T/tmp" "$MAKE_BIN" -f "$BAUM/Makefile" geheimnisse ) > "$T/aus/lauf-$mid.roh" 2>&1
    if [ "$(grep -c '^::LAGE ' "$T/aus/lauf-$mid.roh" || true)" != 1 ]; then
      M_WIRKUNGSLOS=$((M_WIRKUNGSLOS + 1)); echo "$PM: $mid WIRKUNGSLOS (die Mutante liefert auf dem Geruest keine Marke: Defekt der Mutation)"; MAKEFILE_QUELLE="$MAKEFILE_ECHT"; continue
    fi
    erkannt=1; nicht_gefallen=""
    IFS=',' read -r -a minfaelle <<<"${M_MIN[$mid]}"
    for id in "${minfaelle[@]}"; do
      case " ${KENNUNGEN[*]} " in *" $id "*) ;; *) MUT_ABW+=("$mid: Mindestsatz nennt unbekannten Fall $id"); continue ;; esac
      fall_lauf "$id"
      if [ "$FALL_ERG" != "fail" ]; then erkannt=0; nicht_gefallen="$nicht_gefallen $id"; fi
    done
    MAKEFILE_QUELLE="$MAKEFILE_ECHT"
    if [ "$erkannt" -eq 1 ]; then
      M_ERKANNT=$((M_ERKANNT + 1))
    else
      M_NICHT=$((M_NICHT + 1)); echo "$PM: $mid NICHT ERKANNT -- der Mindestsatz besteht gegen die Mutante:$nicht_gefallen"
    fi
    case "${M_GRUND[$mid]}" in "Familie "*) f="${M_GRUND[$mid]#Familie }"; fam_mutiert="$fam_mutiert ${f%%:*}" ;; esac
    for id in "${minfaelle[@]}"; do
      case ",${K_KLASSEN[$id]:-}," in *",${M_KLASSE[$mid]},"*) MUT_KLASSEN_GEDECKT="$MUT_KLASSEN_GEDECKT ${M_KLASSE[$mid]}" ;; esac
    done
  done
  for k in $(sed -nE 's/^#   (KS-[0-9]+)  .*/\1/p' "$SKRIPT_PFAD" | sort -u); do
    case " $MUT_KLASSEN_GEDECKT " in *" $k "*) ;; *) MUT_ABW+=("Klasse $k ohne Mutation, deren Mindestsatz einen Fall dieser Klasse enthaelt") ;; esac
  done
  soll_fam=$(familien_aus_makefile | tr ' ' '\n' | sort -u)
  for f in $soll_fam; do case " $fam_mutiert " in *" $f "*) ;; *) MUT_ABW+=("Familie $f ohne Mutation (Klasse KS-1, Grund beginnt mit 'Familie $f:')") ;; esac; done
  for f in $fam_mutiert; do case " $(echo $soll_fam) " in *" $f "*) ;; *) MUT_ABW+=("Mutation fuer Familie $f, die das Rezept nicht fuehrt") ;; esac; done
  echo "$PM: MUTATIONEN: $M_GEPRUEFT geprueft, $M_ERKANNT erkannt, $M_NICHT nicht erkannt, $M_WIRKUNGSLOS wirkungslos"
  echo "$PM: MUTATIONSDECKUNG: ${#MUT_ABW[@]} Abweichung(en)"
  for e in "${MUT_ABW[@]:-}"; do [ -z "$e" ] || echo "$PM:   Abweichung -- $e"; done
  [ "$M_NICHT" -eq 0 ] && [ "$M_WIRKUNGSLOS" -eq 0 ] && [ "${#MUT_ABW[@]}" -eq 0 ] || ENDE_RC=2
  SCHNAPP_NACH="$T/arbeitsbaum-nach.txt"
  schnappschuss "$ARBEITSBAUM" > "$SCHNAPP_NACH" || ENDE_RC=2
  if cmp -s "$SCHNAPP_VOR" "$SCHNAPP_NACH"; then echo "$PM: Arbeitsbaum nach dem Lauf unveraendert"; else echo "$PM: Arbeitsbaum nach dem Lauf VERAENDERT"; ENDE_RC=2; fi
fi

echo "$PM: Laufzeit $(( $(date +%s) - zeit0 )) s; Rueckgabewert $ENDE_RC"
exit "$ENDE_RC"
