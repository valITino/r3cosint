#!/usr/bin/env bash
# =============================================================================
# scripts/abnahme-abgleich.sh -- Kettenschritt D7: Abnahmekriterien des Backlogs
# gegen die gesammelten Abnahmetests
# =============================================================================
#
# Anforderung R3-Q-001 (das DoD-Gate stuetzt sich auf die Kette). Festlegung: ADR 0002, Abschnitt 5, Nachtrag
# vom 2026-10-29 (Festlegung fuer G3), Zeilen zu D7; Vorlage: docs/12_Freigabe_Grundgeruest.md, Abschnitt 4, G3,
# Festlegung 1; Abbildungsregel der Testnamen: ADR 0002, 3.12, Absatz "Testnamen und Verfolgbarkeit"; Suchmuster
# und Lagen: ADR 0002, 6.3.2 und die Objekttabelle in Abschnitt 6, Zeile D7. Pruefmittel dieses Skripts:
# scripts/abnahme-abgleich-selbsttest.sh (Normalmodus mit der Fallliste, Modus --mutationen mit
# scripts/abnahme-abgleich-mutationen.txt). Einheit G3.2.
#
# ZWECK
#   Das Skript vergleicht die Testnamen, die der Backlog je Eintrag nennt, mit den Abnahmetests, die pytest
#   mit dem Marker abnahme sammelt, und meldet jeden Eintrag ohne Test und jeden Test ohne Eintrag (Projektauftrag
#   6.6). Eine Aussage ueber das Bestehen der Tests trifft es nicht: das Bestehen prueft der erste Teil des Ziels
#   abnahme im Makefile (pytest -m abnahme), das Gesammeltsein dieses Skript.
#
# AUFRUF
#   bash scripts/abnahme-abgleich.sh <Sammeldatei>
#   Die Sammeldatei ist das einzige Argument: die Standardausgabe von pytest -q -m abnahme --collect-only, eine
#   Knotenkennung je Zeile (Pfad.py::[Klasse::]Funktion[Parameter]); sie ist leer, wenn es kein backend/pyproject.toml
#   gibt. Das Makefile schreibt sie in eine Wegwerfdatei ausserhalb des Arbeitsbaums. Als Knotenkennung gilt jede Zeile,
#   die ".py::" enthaelt; alle anderen Zeilen (Zusammenfassung, Warnungen) werden nicht gelesen. Der Aufrufort spielt
#   keine Rolle: die Wurzel ist das Verzeichnis ueber dem scripts/ dieses Skripts.
#
# REGELN (Festlegung D7)
#   Q1  Quelle der Eintraege: jede Datei nach dem Suchmuster docs/05_Product_Backlog*.md. Ein Eintrag ist eine Zeile
#       "### " mit einer Kennung R3-[A-Z]-[0-9]{3}; sein Block reicht bis zur naechsten Ueberschrift (eine bis sechs
#       Rauten, ein Leerzeichen). Das Feld Etappe liest das Skript aus der ersten Zeile "- **Art:**" des Blocks.
#   Q2  Testnamen eines Eintrags sind allein die Woerter in Rueckwaertsakzenten in seinen Abnahmefeldzeilen (Zeilen,
#       die mit "- **Abnahme:" oder "- **Abnahme," beginnen, also auch "maschinell" und "menschlich"), die mit seiner
#       eigenen Kennung und einem Unterstrich beginnen. Der Rest nach dem Unterstrich ist [a-z0-9_]+.
#   Q3  Abbildung (ADR 0002, 3.12): R3-F-008_kette_bricht_bei_aenderung wird zu test_R3_F_008_kette_bricht_bei_aenderung.
#   Q4  Abnahmetest ist ein Test, den pytest mit dem Marker abnahme sammelt; sein Name ist der Funktionsname der
#       Knotenkennung: der Teil nach dem letzten "::", ohne den Parameterteil in eckigen Klammern.
#   Q5  Rueckwaerts (a), fuer jeden gesammelten Abnahmetest, auch eines ausgenommenen Eintrags: KA-1, KA-2, KA-3.
#       Vorwaerts (b), je faelligem Eintrag: KA-4, KA-5. Faellig ist jeder Eintrag ohne formfehlerfreie Zeile in
#       scripts/abnahme-ausnahmen.txt; eine Ausnahme gilt fuer den Eintrag mit allen seinen Testnamen, auch wenn sie
#       veraltet ist (KA-8 meldet das). (c) Eine leere Sammlung ist kein Fehlschlag: das Urteil traegt dieser Abgleich.
#   Q6  Ausnahmeliste scripts/abnahme-ausnahmen.txt: ASCII; Leerzeilen und Zeilen mit # am Anfang werden uebergangen;
#       jede andere Zeile besteht aus der Kennung, genau einem Tabulator und dem Grund in einem von drei Wortlauten:
#         nicht begonnen, Etappe <n>               (n = 0 bis 6, gleich dem Feld Etappe des Eintrags)
#         nicht begonnen, zweite Fassung           (das Feld Etappe des Eintrags lautet zweite Fassung)
#         geprueft ausserhalb von pytest: <Pfad>   (repository-relativer Pfad, Datei oder Verzeichnis, ohne fuehrenden
#                                                   Schraegstrich und ohne "..")
#       Eine Zeile mit Formfehler nimmt den Eintrag nicht aus.
#
# FEHLERKLASSEN (Rueckgabewert 2; jede Klasse hat im Pruefmittel Faelle Soll Fund und Soll kein Fund und eine Mutation)
#   KA-1  Rueckwaerts: Name eines gesammelten Abnahmetests ohne Kennung (beginnt nicht mit test_R3_, einem Grossbuchstaben,
#         einem Unterstrich, drei Ziffern und einem Unterstrich). Schluessel des Funds: der Name.
#   KA-2  Rueckwaerts: die Kennung im Namen hat keinen Eintrag im Backlog. Schluessel: der Name.
#   KA-3  Rueckwaerts: der Name ist keinem nach Q3 abgebildeten Testnamen seines Eintrags gleich. Schluessel: der Name.
#   KA-4  Vorwaerts: ein Testname eines faelligen Eintrags hat keinen gesammelten Abnahmetest dieses Namens.
#         Schluessel: der Testname.
#   KA-5  Vorwaerts: ein faelliger Eintrag hat keinen eigenen Testnamen. Schluessel: die Kennung.
#   KA-6  Backlog nicht abbildbar: eine Kennung mit mehr als einer Ueberschrift; ein eigener Testname, dessen Rest nicht
#         [a-z0-9_]+ ist; ein Testname mit fremder Kennung, der nicht als Testname seines eigenen Eintrags steht
#         (Querverweis ins Leere). Schluessel: die Kennung beziehungsweise der Testname.
#   KA-7  Ausnahmeliste, Form: Zeichen ausserhalb von ASCII, Feldzahl, Kennung ausserhalb der Form, Kennung doppelt, Grund
#         ausserhalb der drei Wortlaute, Pfad ohne repository-relative Form. Schluessel: die Kennung, sonst "Zeile n".
#   KA-8  Ausnahmeliste, veraltet: Kennung ohne Ueberschrift; ein gesammelter Abnahmetest mit der Kennung; Etappe im
#         Grund ungleich dem Feld Etappe der Kopfzeile oder fehlendes Feld; Pfad besteht nicht (auch nicht ohne
#         Verknuepfung auf dem Weg). Schluessel: die Kennung.
#
# LAGE C (Rueckgabewert 3; das Pruefmittel fehlt oder traegt die Aussage nicht. Die Klassen vor KC-7 melden vor jedem Urteil,
#   in dieser Reihenfolge, gemeldet wird der erste Mangel; die Standardausgabe bleibt dann ohne "Befunde:" und ohne Abschnitt
#   "Funde". KC-7 meldet nach dem Urteil und steht in der Standardausgabe der Funde.)
#   KC-1  Aufruf: nicht genau ein nicht leeres Argument.
#   KC-2  Werkzeuge: git oder sort fehlt, oder bash ist aelter als Version 4.
#   KC-3  Git-Arbeitsbaum: die Wurzel des Skripts ist nicht die oberste Ebene eines Git-Arbeitsbaums.
#   KC-4  Sammeldatei: fehlt, ist eine Verknuepfung, keine regulaere Datei oder nicht lesbar.
#   KC-5  Backlog: keine Datei nach dem Suchmuster; eine Datei ist eine Verknuepfung (auch ein Verzeichnis auf dem Weg),
#         keine regulaere Datei oder nicht lesbar; in allen Dateien zusammen keine Abnahmefeldzeile in einem Eintrag.
#   KC-6  Ausnahmeliste: fehlt, ist eine Verknuepfung (auch ein Verzeichnis auf dem Weg), keine regulaere Datei oder
#         nicht lesbar.
#   KC-7  Ausgabe: sort endet mit einem Fehler oder liefert nicht so viele Zeilen, wie Funde erfasst sind. Die Funde werden beim
#         Erfassen gezaehlt (gleiche Zeilen einmal); in diesem Fall stehen sie ungeordnet in der Standardausgabe, mit
#         "Befunde: n", und der Rueckgabewert ist 3: Lage C geht einem Fund vor, ein Fehler eines Teilschritts ist nie "kein Fund".
#   Ein Sammelfehler von pytest ist keine Lage C dieses Skripts: er entsteht an einer Testdatei, das Makefile stellt ihn
#   als A_FAIL fest und ruft das Skript dann nicht auf.
#
# EIGENSCHAFTEN
#   EA-1  Umfeld: das Skript setzt LC_ALL=C, loescht vor dem ersten cd ein CDPATH und vor dem ersten git-Aufruf die
#         git-Variablen des Aufrufers; es setzt GIT_NO_REPLACE_OBJECTS=1. Das Urteil haengt weder von der Spracheinstellung noch
#         von diesen Variablen noch von CDPATH ab (bei relativem Aufruf, wie make ihn macht, lenkte ein CDPATH "cd scripts/.."
#         um und schriebe den Zielpfad auf die Standardausgabe).
#   EA-2  Schreibfrei: das Skript schreibt keine Datei in den Arbeitsbaum (Kettengrundsatz, ADR 0002, Abschnitt 6). Eine
#         Wegwerfdatei legt es selbst nicht an; ein Here-String taete es (Bash legt ab 64 KiB, vor Version 5.1 immer, eine Datei
#         in TMPDIR beziehungsweise /tmp an), deshalb benutzt das Skript keinen.
#   EA-3  Gleiche Eingabe, gleiche Ausgabe (K4): keine Zeiten, keine Prozessnummern, sortierte Funde (ausser bei KC-7).
#   EA-4  Ausgabeform: die Zaehlzeilen, der Abschnitt "=== Funde" mit je einer Zeile Klasse TAB Schluessel TAB Grund und die
#         Schlusszeile "Befunde: n", n gleich der Zahl der Fundzeilen.
#   EA-5  Quelle: Eintraege und Testnamen entstehen allein aus den Zeilen nach Q1 und Q2; die Sammeldatei liefert allein
#         Zeilen mit ".py::".
#   EA-6  Beendigung: jede Lese-Schleife (Backlog, Ausnahmeliste, Sammeldatei) endet auch bei einem Lesefehler. bash laesst die
#         Variable bei einem Lesefehler unveraendert und liefert 1; das Skript leert die Zeilenvariable deshalb vor jedem Lesen
#         (while zeile=; IFS= read -r zeile ...), sonst wuerde die zuletzt gelesene Zeile erneut verarbeitet, ohne Ende (GA-7).
#
# GRENZEN (benannt, nicht geschlossen; je Grenze ein Fall im Pruefmittel, der sie misst)
#   GA-1  Geprueft wird das Gesammeltsein, nicht das Bestehen: ein uebersprungener oder als xfail markierter Abnahmetest
#         zaehlt als gesammelt (Durchlass). Entscheid mit dem ersten Abnahmetest (Etappe 1).
#   GA-2  Ein Test ohne Marker abnahme ist kein Abnahmetest: der Eintrag bleibt faellig (Fehlalarm).
#   GA-3  Abnahmetests ausserhalb von pytest (Oberflaeche) sammelt D7 nicht: der Eintrag braucht die Ausnahme
#         "geprueft ausserhalb von pytest" (Fehlalarm). Mit frontend/ folgt eine Fortschreibung.
#   GA-4  Testnamen ausserhalb der Abnahmefeldzeilen (Formulierung, Achtung, Nachweis, eingerueckte Zeilen) liest D7 nicht;
#         ein Fehler dort bleibt ohne Fund (Durchlass).
#   GA-5  Der Backlog wird zeilenweise gelesen. Zaeune (Codebloecke) und mehrzeilige Kommentare werden nicht erkannt: eine
#         Ueberschrift oder Abnahmefeldzeile darin gilt wie im Text (Fehlalarm, sichere Richtung). Zitate werden ebenfalls
#         nicht erkannt, wirken aber anders: eine Zeile "> ### R3-..." ist kein Eintrag, eine Zeile "> - **Abnahme:**" keine
#         Abnahmefeldzeile (die Anfangsmuster verlangen die Zeile ohne "> "), und eine Zitatzeile beendet keinen Block
#         (Durchlass: ein Zitat unter einem Eintrag bleibt Teil seines Blocks, seine Testnamen zaehlen nicht).
#   GA-6  Die Sammeldatei wird nicht auf Echtheit geprueft: jede Zeile mit ".py::" gilt als Knotenkennung (Durchlass bei
#         einer Sammeldatei von Hand). Das Makefile schreibt sie aus dem Lauf von pytest; die Kette schuetzt gegen
#         Bequemlichkeit, nicht gegen den, der die Umgebung des Aufrufs beherrscht (Makefile, Abschnitt "Wogegen diese
#         Kette schuetzt").
#   GA-7  Ein Lesefehler nach den Wachen -f und -r (Ein-/Ausgabefehler, Datei waehrend des Laufs entfernt) wird nicht als
#         Lage C erkannt: das Lesen endet wie am Dateiende. bash meldet "read error" auf der Fehlerausgabe, laesst die Variable
#         unveraendert und liefert 1; das Skript leert die Zeilenvariable vor jedem Lesen (EA-6). Gemessen: die Sammeldatei
#         /proc/self/mem, die schon beim ersten Lesen mit einem Ein-/Ausgabefehler endet (A-208), und ein Fehler nach der ersten
#         Zeile von Backlog, Ausnahmeliste und Sammeldatei mit ersetzter Funktion read (A-214 bis A-216). Folge am Dateiende:
#         beim Backlog Lage C (keine Abnahmefeldzeile) oder gekuerzte Eintraege (Durchlass), bei der Ausnahmeliste Funde statt
#         der Lage C (fehlende Ausnahmen machen Eintraege faellig), bei der Sammeldatei fehlende Tests (Funde; Durchlass nur,
#         wenn kein faelliger Eintrag Testnamen hat). Vor dem Leeren der Variablen kamen zwei Folgen hinzu (ST-G3-11): beim
#         ersten Lesen "unbound variable" mit Abbruch (Rueckgabewert 1, im Makefile A_FAIL), und nach mindestens einer gelesenen
#         Zeile wurde dieselbe Zeile erneut verarbeitet; die Schleife endete bei anhaltendem Fehler nicht.
#
# WAS EIN GRUENER LAUF AUSSAGT
#   Rueckgabewert 0 heisst: jeder faellige Eintrag hat zu jedem seiner Testnamen einen gesammelten Abnahmetest dieses
#   Namens, jeder gesammelte Abnahmetest gehoert nach Q3 zu einem Testnamen seines Eintrags, die Ausnahmeliste ist
#   formfehlerfrei und nicht veraltet. Er heisst nicht: die Tests bestehen, oder der Test prueft, was das Kriterium
#   verlangt.
#
# AUSGABE (Standardausgabe, ohne Zeiten)
#   Backlog, Zahl der Eintraege, Abnahmefeldzeilen und Testnamen, Zahl der Ausnahmen je Grund, Zahl der faelligen Eintraege
#   und der gesammelten Abnahmetests, dann "=== Funde" mit je einer Zeile "Klasse TAB Schluessel TAB Grund" (sortiert,
#   gleiche Zeilen einmal; bei KC-7 ungeordnet), dann "Befunde: n". Fehlerausgabe: nur bei Lage C.
#
# RUECKGABEWERTE
#   0  kein Fund
#   2  mindestens ein Fund
#   3  Lage C (siehe oben); das Makefile stellt 3 als Lage C mit FEHLT=abnahme-pruefmittel weiter, jeden anderen Wert
#      ungleich 0 als A_FAIL
#
# WERKZEUGE (geschlossene Liste, gleich den aufgerufenen Befehlen; alles Uebrige sind Builtins der Shell)
#   bash ab Version 4, git, sort. Jeder Teilschritt mit Rueckgabewert wird geprueft; ein Fehler ist nie "kein Fund".
#
# PFLEGE
#   Die Ausnahmeliste pflegt der Product Owner (die Datei schreibt die bauende Rolle nach seiner Angabe); ein neuer
#   Eintrag und seine Ausnahme, ebenso eine Streichung und die zugehoerigen Abnahmetests, entstehen im selben
#   Arbeitsstand. Eine neue Klasse oder Grenze in diesem Kopfkommentar verlangt Faelle (und fuer eine Klasse KA, KC, EA
#   eine Mutation) im Pruefmittel.

set -uo pipefail

# EA-1: Sortierung, Zeichenklassen und Wortgrenzen haengen sonst von der Spracheinstellung des Aufrufers ab.
export LC_ALL=C

PROG="abnahme-abgleich.sh"
AUSNAHMEDATEI="scripts/abnahme-ausnahmen.txt"
TAB=$'\t'
NL=$'\n'
BT='`'
MITTELPUNKT=$'\xc2\xb7'

lage_c() { # lage_c <kennung> <meldung> [<beschaffungsweg>]
  echo "$PROG: LAGE C -- $1: $2" >&2
  if [ $# -ge 3 ]; then echo "$PROG: Beschaffen: $3" >&2; fi
  echo "$PROG: Der Gegenstand besteht fort, die Pruefung faellt aus. Rueckgabewert 3 und nicht 2: ein ausgefallenes Pruefmittel ist kein Befund am Bestand." >&2
  exit 3
}

# KC-1 Aufruf
if [ "$#" -ne 1 ] || [ -z "$1" ]; then
  lage_c "aufruf" "genau ein nicht leeres Argument erwartet (die Sammeldatei), erhalten: $# Argument(e)." "bash scripts/abnahme-abgleich.sh <Sammeldatei>"
fi
SAMMEL="$1"
case "$SAMMEL" in /*) ;; *) SAMMEL="$PWD/$SAMMEL" ;; esac

# KC-2 Werkzeuge: die geschlossene Liste ist gleich den Befehlen, die dieses Skript aufruft
WERKZEUGE="git sort"
for w in $WERKZEUGE; do
  command -v "$w" >/dev/null 2>&1 || lage_c "werkzeug:$w" "Werkzeug '$w' fehlt im Suchpfad." "Werkzeug installieren"
done
if [ "${BASH_VERSINFO[0]:-0}" -lt 4 ]; then
  lage_c "werkzeug:bash" "bash ab Version 4 erforderlich (assoziative Felder), gefunden: ${BASH_VERSION:-unbekannt}." "bash ab Version 4 verwenden"
fi

# EA-1: die git-Variablen des Aufrufers loeschen, die Gegenstand, Objektspeicher oder die Deutung von Pfadangaben
# verlegen (Muster des Belegpruefers, Einheit G0); Ersatzobjekte unter refs/replace/ gelten nicht
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_COMMON_DIR GIT_OBJECT_DIRECTORY GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_NAMESPACE GIT_CEILING_DIRECTORIES GIT_SHALLOW_FILE GIT_DISCOVERY_ACROSS_FILESYSTEM GIT_GLOB_PATHSPECS GIT_NOGLOB_PATHSPECS GIT_LITERAL_PATHSPECS GIT_ICASE_PATHSPECS 2>/dev/null || true
unset "${!GIT_TRACE@}" 2>/dev/null || true
export GIT_NO_REPLACE_OBJECTS=1
# EA-1: ein CDPATH des Aufrufers lenkt "cd scripts/.." bei relativem Aufruf um und schreibt den Zielpfad auf die Standardausgabe
unset CDPATH

# KC-3 Git-Arbeitsbaum: die Wurzel ist das Verzeichnis ueber dem scripts/ dieses Skripts, nicht das Arbeitsverzeichnis
# des Aufrufers (ein Lauf aus einem fremden Repository urteilte sonst ueber das falsche)
QUELLE="${BASH_SOURCE[0]}"
case "$QUELLE" in */*) QUELLVERZ="${QUELLE%/*}" ;; *) QUELLVERZ="." ;; esac
WURZEL="$(cd "$QUELLVERZ/.." 2>/dev/null && pwd -P)" || WURZEL=""
[ -n "$WURZEL" ] || lage_c "git-arbeitsbaum" "das Verzeichnis ueber dem Skript ist nicht erreichbar ($QUELLVERZ/..)."
GITTOP="$(git -C "$WURZEL" rev-parse --show-toplevel 2>/dev/null)" || GITTOP=""
if [ -n "$GITTOP" ]; then GITTOP="$(cd "$GITTOP" 2>/dev/null && pwd -P)" || GITTOP=""; fi
if [ -z "$GITTOP" ] || [ "$GITTOP" != "$WURZEL" ]; then
  lage_c "git-arbeitsbaum" "die Wurzel des Skripts ($WURZEL) ist nicht die oberste Ebene eines Git-Arbeitsbaums (git meldet: ${GITTOP:-nichts})."
fi
cd "$WURZEL" || lage_c "git-arbeitsbaum" "Wurzel nicht erreichbar: $WURZEL"

# Hat ein Segment des Pfads (relativ zur Wurzel, die Datei selbst eingeschlossen) eine symbolische Verknuepfung? Jedes
# Segment wird einzeln mit -L geprueft, keines wird verfolgt. Zerlegt wird mit Parametererweiterung, ohne externes Werkzeug.
weg_verknuepft() { # weg_verknuepft <pfad>
  local rest="$1" acc="" seg
  while [ -n "$rest" ]; do
    case "$rest" in
      */*) seg="${rest%%/*}"; rest="${rest#*/}" ;;
      *) seg="$rest"; rest="" ;;
    esac
    [ -n "$seg" ] || continue
    acc="${acc:+$acc/}$seg"
    if [ -L "$acc" ]; then return 0; fi
  done
  return 1
}

# KC-4 Sammeldatei
if [ ! -e "$SAMMEL" ] && [ ! -L "$SAMMEL" ]; then
  lage_c "sammeldatei" "die Sammeldatei fehlt: $SAMMEL" "Sammellauf mit pytest -q -m abnahme --collect-only in eine Datei schreiben (make abnahme)"
fi
[ ! -L "$SAMMEL" ] || lage_c "sammeldatei" "die Sammeldatei ist eine Verknuepfung: $SAMMEL"
[ -f "$SAMMEL" ] || lage_c "sammeldatei" "die Sammeldatei ist keine regulaere Datei: $SAMMEL"
[ -r "$SAMMEL" ] || lage_c "sammeldatei" "die Sammeldatei ist nicht lesbar: $SAMMEL"

# KC-5 Backlog: jede Datei nach dem Suchmuster (ADR 0002, 6.3.2); der Backlog besteht seit der Freigabe von Schritt 3
# dauerhaft, sein Fehlen ist ein ausgefallenes Pruefmittel und kein leerer Gegenstand
BACKLOGS=()
for f in docs/05_Product_Backlog*.md; do
  if [ -e "$f" ] || [ -L "$f" ]; then BACKLOGS+=("$f"); fi
done
if [ "${#BACKLOGS[@]}" -eq 0 ]; then
  lage_c "backlog" "keine Datei nach dem Suchmuster docs/05_Product_Backlog*.md; aus dem Backlog bildet das Skript die Eintraege, ohne ihn ist jede Aussage ueber Abnahmetests unbelegt."
fi
for f in "${BACKLOGS[@]}"; do
  if weg_verknuepft "$f"; then lage_c "backlog-verknuepfung" "auf dem Weg zu $f liegt eine symbolische Verknuepfung; das Skript liest keine Datei ueber eine Verknuepfung."; fi
  [ -f "$f" ] || lage_c "backlog" "$f ist keine regulaere Datei."
  [ -r "$f" ] || lage_c "backlog" "$f ist nicht lesbar."
done

# KC-6 Ausnahmeliste
if [ ! -e "$AUSNAHMEDATEI" ] && [ ! -L "$AUSNAHMEDATEI" ]; then
  lage_c "ausnahmeliste" "$AUSNAHMEDATEI fehlt; ohne sie waere jeder Eintrag faellig und die Pflege der Ausnahmen nicht geprueft."
fi
if weg_verknuepft "$AUSNAHMEDATEI"; then lage_c "ausnahmeliste-verknuepfung" "auf dem Weg zu $AUSNAHMEDATEI liegt eine symbolische Verknuepfung; das Skript liest keine Datei ueber eine Verknuepfung."; fi
[ -f "$AUSNAHMEDATEI" ] || lage_c "ausnahmeliste" "$AUSNAHMEDATEI ist keine regulaere Datei."
[ -r "$AUSNAHMEDATEI" ] || lage_c "ausnahmeliste" "$AUSNAHMEDATEI ist nicht lesbar."

# --- Zustand -----------------------------------------------------------------------------------------------
declare -A E_VORH=() E_ARTGESEHEN=() E_ETAPPE=() E_HATET=() E_NAMEN=() E_NAMENSET=() EXC_OK=() EXC_GESEHEN=() COLL_SET=() FUNDSET=()
E_ORDER=()
FREMD=()
EXC_LIST=()
COLL_LIST=()
N_EINTRAEGE=0
N_ABNZEILEN=0
N_KNOTEN=0
N_EXC_ETAPPE=0
N_EXC_ZWEITE=0
N_EXC_GEPRUEFT=0
TRIM=""
SPANS=()

RE_UEBERSCHRIFT='^#{1,6}([ ]|$)'
RE_EINTRAG='^### (R3-[A-Z]-[0-9]{3})([^0-9]|$)'
RE_SPAN_NAME='^(R3-[A-Z]-[0-9]{3})_(.*)$'
RE_REST='^[a-z0-9_]+$'
RE_KENNUNG='^R3-[A-Z]-[0-9]{3}$'
RE_UNZULAESSIG="[^[:print:]${TAB}]"
RE_ETAPPE_GRUND='^nicht begonnen, Etappe [0-6]$'
RE_BEZEICHNER='^[A-Za-z0-9_]+$'
RE_TESTPRAEFIX='^test_R3_[A-Z]_[0-9]{3}_'

fund() { # fund <klasse> <schluessel> <grund> : ein Fund; Tabulatoren im Schluessel und im Grund werden zu Leerzeichen
  local z k="${2//$TAB/ }" g="${3//$TAB/ }"
  printf -v z '%s\t%s\t%s' "$1" "$k" "$g"
  FUNDSET["$z"]=1
}
trimmen() { # trimmen <text> : setzt TRIM auf den Text ohne Leerraum an den Enden
  TRIM="$1"
  TRIM="${TRIM#"${TRIM%%[![:space:]]*}"}"
  TRIM="${TRIM%"${TRIM##*[![:space:]]}"}"
}
spans_lesen() { # spans_lesen <zeile> : setzt SPANS auf die Woerter in Rueckwaertsakzenten (ein einzelner Akzent als Begrenzer)
  SPANS=()
  local rest="$1"
  while :; do
    case "$rest" in *"$BT"*) ;; *) return 0 ;; esac
    rest="${rest#*"$BT"}"
    case "$rest" in *"$BT"*) ;; *) return 0 ;; esac
    SPANS+=("${rest%%"$BT"*}")
    rest="${rest#*"$BT"}"
  done
}

# --- Backlog lesen (Q1, Q2) --------------------------------------------------------------------------------
# Alle drei Lese-Schleifen (Backlog, Ausnahmeliste, Sammeldatei) leeren die Zeilenvariable vor jedem Lesen (while zeile=; ...):
# bei einem Lesefehler laesst bash die Variable unveraendert und liefert 1; ohne das Leeren wuerde die zuletzt gelesene Zeile
# erneut verarbeitet und die Schleife endete nicht. So endet ein Lesefehler wie das Dateiende (EA-6, GA-7, ST-G3-11).
backlog_lesen() { # backlog_lesen <datei>
  local datei="$1" zeile cur="" sp sid srest et
  while zeile=; IFS= read -r zeile || [ -n "$zeile" ]; do  # Backlog
    if [[ $zeile =~ $RE_UEBERSCHRIFT ]]; then
      cur=""
      if [[ $zeile =~ $RE_EINTRAG ]]; then
        cur="${BASH_REMATCH[1]}"
        E_VORH["$cur"]=$(( ${E_VORH["$cur"]:-0} + 1 ))
        if [ "${E_VORH["$cur"]}" -eq 1 ]; then
          E_ORDER+=("$cur")
          E_NAMEN["$cur"]=""
          N_EINTRAEGE=$((N_EINTRAEGE + 1))
        fi
      fi
      continue
    fi
    [ -n "$cur" ] || continue
    if [[ $zeile == "- **Art:**"* ]] && [ -z "${E_ARTGESEHEN["$cur"]+x}" ]; then
      E_ARTGESEHEN["$cur"]=1
      if [[ $zeile == *"**Etappe:**"* ]]; then
        et="${zeile#*"**Etappe:**"}"
        et="${et%%"$MITTELPUNKT"*}"
        trimmen "$et"
        E_ETAPPE["$cur"]="$TRIM"
        E_HATET["$cur"]=1
      fi
      continue
    fi
    if [[ $zeile == "- **Abnahme:"* ]] || [[ $zeile == "- **Abnahme,"* ]]; then
      N_ABNZEILEN=$((N_ABNZEILEN + 1))
      spans_lesen "$zeile"
      for sp in "${SPANS[@]+"${SPANS[@]}"}"; do
        if [[ $sp =~ $RE_SPAN_NAME ]]; then
          sid="${BASH_REMATCH[1]}"
          srest="${BASH_REMATCH[2]}"
          if [ "$sid" = "$cur" ]; then
            if [[ $srest =~ $RE_REST ]]; then
              if [ -z "${E_NAMENSET["$cur|$srest"]+x}" ]; then
                E_NAMENSET["$cur|$srest"]=1
                E_NAMEN["$cur"]="${E_NAMEN["$cur"]} $srest"
              fi
            else
              fund "KA-6" "$sp" "Testname nicht abbildbar im Eintrag $cur (Rest nicht [a-z0-9_]+)"
            fi
          elif [[ $srest =~ $RE_REST ]]; then
            FREMD+=("$cur|$sid|$srest")
          else
            fund "KA-6" "$sp" "fremder Testname im Eintrag $cur, nicht abbildbar (Querverweis ins Leere)"
          fi
        fi
      done
    fi
  done < "$datei"
}
for f in "${BACKLOGS[@]}"; do backlog_lesen "$f"; done

# KC-5: ohne eine Abnahmefeldzeile in einem Eintrag gibt es nichts zu vergleichen
if [ "$N_ABNZEILEN" -eq 0 ]; then
  lage_c "backlog-abnahmekriterien" "gefunden wurde ${BACKLOGS[*]}, aber keine Abnahmefeldzeile (Zeile mit - **Abnahme: oder - **Abnahme, ) in einem Eintrag."
fi

# KA-6: doppelte Ueberschriften; fremde Testnamen gegen ihren eigenen Eintrag
for id in "${E_ORDER[@]+"${E_ORDER[@]}"}"; do
  if [ "${E_VORH["$id"]}" -gt 1 ]; then
    fund "KA-6" "$id" "Kennung mit mehr als einer Ueberschrift (${E_VORH["$id"]})"
  fi
done
for z in "${FREMD[@]+"${FREMD[@]}"}"; do
  # kein Here-String (Bash legt ab 64 KiB, vor Version 5.1 immer, eine Wegwerfdatei an; scheitert sie, behielten die Felder den
  # Wert der Vorrunde): die Felder werden mit Parametererweiterung geschnitten
  cur="${z%%|*}"; zrest="${z#*|}"; sid="${zrest%%|*}"; srest="${zrest#*|}"
  if [ -z "${E_NAMENSET["$sid|$srest"]+x}" ]; then
    fund "KA-6" "${sid}_${srest}" "fremder Testname im Eintrag $cur; im Eintrag $sid steht er nicht als Testname (Querverweis ins Leere)"
  fi
done

# --- Ausnahmeliste lesen (Q6): Form (KA-7) ------------------------------------------------------------------
ausnahmen_lesen() { # ausnahmen_lesen <datei>
  local datei="$1" zeile zn=0 tabs id grund pfad
  while zeile=; IFS= read -r zeile || [ -n "$zeile" ]; do  # Ausnahmeliste
    zn=$((zn + 1))
    [ -n "$zeile" ] || continue
    case "$zeile" in '#'*) continue ;; esac
    if [[ $zeile =~ $RE_UNZULAESSIG ]]; then
      fund "KA-7" "Zeile $zn" "Zeile $zn: Zeichen ausserhalb von ASCII (druckbare Zeichen und Tabulator erlaubt)"
      continue
    fi
    tabs="${zeile//[!$TAB]/}"
    if [ "${#tabs}" -ne 1 ]; then
      fund "KA-7" "Zeile $zn" "Zeile $zn: Feldzahl (genau ein Tabulator zwischen Kennung und Grund erwartet)"
      continue
    fi
    id="${zeile%%"$TAB"*}"
    grund="${zeile#*"$TAB"}"
    if ! [[ $id =~ $RE_KENNUNG ]]; then
      fund "KA-7" "Zeile $zn" "Zeile $zn: Kennung ausserhalb der Form R3-[A-Z]-[0-9]{3}"
      continue
    fi
    if [ -n "${EXC_GESEHEN["$id"]+x}" ]; then
      fund "KA-7" "$id" "Zeile $zn: Kennung doppelt (erste Zeile ${EXC_GESEHEN["$id"]})"
      continue
    fi
    EXC_GESEHEN["$id"]="$zn"
    if [[ $grund =~ $RE_ETAPPE_GRUND ]]; then
      N_EXC_ETAPPE=$((N_EXC_ETAPPE + 1))
    elif [ "$grund" = "nicht begonnen, zweite Fassung" ]; then
      N_EXC_ZWEITE=$((N_EXC_ZWEITE + 1))
    elif [[ $grund == "geprueft ausserhalb von pytest: "* ]]; then
      pfad="${grund#geprueft ausserhalb von pytest: }"
      if [ -z "$pfad" ] || [[ $pfad == /* ]] || [[ $pfad == ".." ]] || [[ $pfad == ../* ]] || [[ $pfad == */.. ]] || [[ $pfad == */../* ]]; then
        fund "KA-7" "$id" "Zeile $zn: Pfad ohne repository-relative Form (leer, fuehrender Schraegstrich oder Segment ..)"
        continue
      fi
      N_EXC_GEPRUEFT=$((N_EXC_GEPRUEFT + 1))
    else
      fund "KA-7" "$id" "Zeile $zn: Grund ausserhalb der drei Wortlaute"
      continue
    fi
    EXC_OK["$id"]="$grund"
    EXC_LIST+=("$id")
  done < "$datei"
}
ausnahmen_lesen "$AUSNAHMEDATEI"

# --- Sammeldatei lesen (Q4) ---------------------------------------------------------------------------------
sammel_lesen() { # sammel_lesen <datei>
  local datei="$1" zeile name
  while zeile=; IFS= read -r zeile || [ -n "$zeile" ]; do  # Sammeldatei
    case "$zeile" in *.py::*) ;; *) continue ;; esac
    N_KNOTEN=$((N_KNOTEN + 1))
    name="${zeile%%\[*}"
    name="${name##*::}"
    trimmen "$name"
    name="$TRIM"
    COLL_LIST+=("$name")
    if [[ $name =~ $RE_BEZEICHNER ]]; then COLL_SET["$name"]=1; fi
  done < "$datei"
}
sammel_lesen "$SAMMEL"

# --- Rueckwaerts (a): jeder gesammelte Abnahmetest, auch eines ausgenommenen Eintrags -------------------------
for fn in "${COLL_LIST[@]+"${COLL_LIST[@]}"}"; do
  if ! [[ $fn =~ $RE_TESTPRAEFIX ]]; then
    fund "KA-1" "${fn:-(leer)}" "Name beginnt nicht mit test_R3_, Grossbuchstabe, Unterstrich, drei Ziffern und Unterstrich"
    continue
  fi
  id="R3-${fn:8:1}-${fn:10:3}"
  if [ -z "${E_VORH["$id"]+x}" ]; then
    fund "KA-2" "$fn" "Kennung $id hat keinen Eintrag im Backlog"
    continue
  fi
  srest="${fn:14}"
  if ! [[ $srest =~ $RE_REST ]] || [ -z "${E_NAMENSET["$id|$srest"]+x}" ]; then
    fund "KA-3" "$fn" "Name entspricht keinem nach ADR 0002, 3.12 abgebildeten Testnamen des Eintrags $id"
  fi
done

# --- Ausnahmen: veraltet (KA-8) ----------------------------------------------------------------------------
for id in "${EXC_LIST[@]+"${EXC_LIST[@]}"}"; do
  grund="${EXC_OK["$id"]}"
  if [ -z "${E_VORH["$id"]+x}" ]; then
    fund "KA-8" "$id" "Kennung ohne Ueberschrift im Backlog"
    continue
  fi
  praefix="test_${id//-/_}_"
  for fn in "${COLL_LIST[@]+"${COLL_LIST[@]}"}"; do
    case "$fn" in
      "$praefix"*) fund "KA-8" "$id" "gesammelter Abnahmetest mit dieser Kennung ($fn): die Ausnahme ist zu streichen"; break ;;
    esac
  done
  case "$grund" in
    "nicht begonnen, Etappe "*)
      n="${grund#nicht begonnen, Etappe }"
      if [ -z "${E_HATET["$id"]+x}" ]; then
        fund "KA-8" "$id" "Feld Etappe fehlt in der Kopfzeile des Eintrags"
      elif [ "${E_ETAPPE["$id"]}" != "$n" ]; then
        fund "KA-8" "$id" "Etappe im Grund ($n) ungleich dem Feld Etappe der Kopfzeile (${E_ETAPPE["$id"]})"
      fi
      ;;
    "nicht begonnen, zweite Fassung")
      if [ -z "${E_HATET["$id"]+x}" ]; then
        fund "KA-8" "$id" "Feld Etappe fehlt in der Kopfzeile des Eintrags"
      elif [ "${E_ETAPPE["$id"]}" != "zweite Fassung" ]; then
        fund "KA-8" "$id" "Grund zweite Fassung ungleich dem Feld Etappe der Kopfzeile (${E_ETAPPE["$id"]})"
      fi
      ;;
    "geprueft ausserhalb von pytest: "*)
      pfad="${grund#geprueft ausserhalb von pytest: }"
      if weg_verknuepft "$pfad" || [ ! -e "$pfad" ]; then
        fund "KA-8" "$id" "Pfad besteht nicht (auch nicht ohne Verknuepfung auf dem Weg): $pfad"
      fi
      ;;
  esac
done

# --- Vorwaerts (b): je faelligem Eintrag ---------------------------------------------------------------------
N_FAELLIG=0
for id in "${E_ORDER[@]+"${E_ORDER[@]}"}"; do
  [ -z "${EXC_OK["$id"]+x}" ] || continue
  N_FAELLIG=$((N_FAELLIG + 1))
  namen="${E_NAMEN["$id"]}"
  if [ -z "$namen" ]; then
    fund "KA-5" "$id" "faelliger Eintrag ohne eigenen Testnamen (keine Ausnahme)"
    continue
  fi
  for srest in $namen; do
    fn="test_${id//-/_}_${srest}"
    if [ -z "${COLL_SET["$fn"]+x}" ]; then
      fund "KA-4" "${id}_${srest}" "Testname ohne gesammelten Abnahmetest $fn (faelliger Eintrag)"
    fi
  done
done

# --- Ausgabe -------------------------------------------------------------------------------------------------
# KC-7: Die Funde sind beim Erfassen gezaehlt (FUNDSET, gleiche Zeilen einmal). sort ordnet sie; die Zeilen der Antwort werden
# mit mapfile aus einer Pipe gezaehlt (linear, kein Here-String; die Ersetzung ${SORTIERT//[!$NL]/} waere quadratisch: 40 000
# Zeilen brauchten ueber vier Minuten, ST-G3-12) und gegen die erfasste Zahl gehalten, beide als Zeichenketten, damit eine
# Zaehlung ohne Ergebnis ein Mangel ist. Endet sort mit einem Fehler oder weicht die Zahl ab, stehen die erfassten Funde
# ungeordnet in der Ausgabe, und das Ergebnis ist Lage C.
BEFUNDE=${#FUNDSET[@]}
SORTIERT=""
SORT_MANGEL=""
if [ "$BEFUNDE" -gt 0 ]; then
  if SORTIERT="$(printf '%s\n' "${!FUNDSET[@]}" | sort -u)"; then
    SORT_ZEILEN=0
    if [ -n "$SORTIERT" ]; then
      SORT_ZEILEN="$(printf '%s\n' "$SORTIERT" | { mapfile -t SORT_FELD && echo "${#SORT_FELD[@]}"; })" || SORT_ZEILEN=""
    fi
    if [ -z "$SORT_ZEILEN" ]; then
      SORT_MANGEL="die Zeilen der Antwort von sort liessen sich nicht zaehlen."
    elif [ "$SORT_ZEILEN" != "$BEFUNDE" ]; then
      SORT_MANGEL="sort lieferte $SORT_ZEILEN Zeilen statt der erfassten $BEFUNDE."
    fi
  else
    SORT_MANGEL="sort endete mit einem Fehler beim Ordnen der Funde."
  fi
  if [ -n "$SORT_MANGEL" ]; then
    SORTIERT=""
    for z in "${!FUNDSET[@]}"; do SORTIERT="${SORTIERT:+$SORTIERT$NL}$z"; done
  fi
fi
LISTE_BACKLOG=""
for f in "${BACKLOGS[@]}"; do LISTE_BACKLOG="${LISTE_BACKLOG:+$LISTE_BACKLOG, }$f"; done

echo "Backlog: $LISTE_BACKLOG"
echo "Eintraege: $N_EINTRAEGE"
echo "Abnahmefeldzeilen: $N_ABNZEILEN"
echo "Testnamen: ${#E_NAMENSET[@]}"
echo "Ausnahmen: ${#EXC_LIST[@]}"
echo "Ausnahmen nicht begonnen, Etappe n: $N_EXC_ETAPPE"
echo "Ausnahmen nicht begonnen, zweite Fassung: $N_EXC_ZWEITE"
echo "Ausnahmen geprueft ausserhalb von pytest: $N_EXC_GEPRUEFT"
echo "Faellige Eintraege: $N_FAELLIG"
echo "Gesammelte Abnahmetests: $N_KNOTEN"
echo "=== Funde"
if [ -n "$SORTIERT" ]; then printf '%s\n' "$SORTIERT"; fi
echo "---"
echo "$PROG: geprueft wird das Gesammeltsein der Abnahmetests, nicht ihr Bestehen (GA-1); die benannten Grenzen GA-1 bis GA-7 stehen im Kopfkommentar."
echo "Befunde: $BEFUNDE"

if [ -n "$SORT_MANGEL" ]; then
  lage_c "werkzeug:sort" "$SORT_MANGEL Die erfassten Funde stehen oben ungeordnet in der Ausgabe." "sort pruefen (command -v sort)"
fi
if [ "$BEFUNDE" -gt 0 ]; then
  exit 2
fi
exit 0
