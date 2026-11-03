#!/usr/bin/env bash
# =============================================================================
# scripts/nachweise-vollstaendig.sh -- Kettenschritt D12 (Nachweisverzeichnis vollstaendig)
# =============================================================================
#
# Anforderung R3-Q-001 (das DoD-Gate stuetzt sich auf die Kette). Grundlage: Projektauftrag 6.6 (das Nachweisverzeichnis nimmt die
# Artefakte des Projekts auf); ADR 0002, Abschnitt 5, Nachtrag vom 2026-10-29 (Festlegung fuer G3), Zeilen zu D12, und Abschnitt 6
# (Zeile D12: der Schritt schreibt nicht in den Arbeitsbaum); docs/12_Freigabe_Grundgeruest.md, Abschnitt 4, G3, Festlegung 3.
# Muster: scripts/belege-pruefen.sh (D20), scripts/abnahme-abgleich.sh (D7) und scripts/prototyp-trennung-pruefen.sh (D10). Einheit G3.4.
#
# ZWECK
#   Das Nachweisverzeichnis docs/NACHWEISE.md wird von scripts/nachweise-erzeugen.sh erzeugt; die Artefaktliste steht im Erzeuger. D12
#   prueft, dass kein nachweispflichtiges Artefakt in dieser Liste fehlt und keine Zeile ins Leere zeigt. Das Skript ruft den
#   Erzeuger selbst gegen ein Ziel in einer eigenen Ablage ausserhalb des Arbeitsbaums auf (Form (i) der Festlegung; der Schritt
#   erzeugt docs/NACHWEISE.md nicht, er prueft die frische Liste), liest die Spalte Pfad der Tabelle und die Meldungszeilen
#   "FEHLT:" und "NICHT COMMITTET:" und haelt sie gegen die Sollmenge S. Die Kette urteilt vor dem Commit (wie D11 und D10): Auch
#   unversionierte, nicht ignorierte Dateien gehoeren zu S.
#
# AUFRUF   bash scripts/nachweise-vollstaendig.sh        (kein Argument; ein Argument ist Lage C)
#   Die Wurzel ist das Verzeichnis ueber dem scripts/ dieses Skripts, nicht das Arbeitsverzeichnis des Aufrufers.
#
# ABLAUF (in dieser Reihenfolge; ein Mangel in den Schritten 1 bis 9 ist Lage C vor jedem Urteil, ausser wo unten "nach dem Urteil")
#   1  Aufruf, Werkzeuge der geschlossenen Liste (siehe WERKZEUGE) und die Version von bash (assoziative Felder ab Version 4).
#   2  Umfeld: die git-Variablen des Aufrufers werden geloescht (GIT_DIR, GIT_WORK_TREE, GIT_INDEX_FILE und weitere),
#      GIT_NO_REPLACE_OBJECTS=1, LC_ALL=C, kein CDPATH. Jeder git-Aufruf und der Aufruf des Erzeugers laufen unter "env -i" mit
#      festen Variablen (PATH des Aufrufers, leeres HOME, GIT_CONFIG_NOSYSTEM=1, GIT_CONFIG_GLOBAL=/dev/null, GIT_OPTIONAL_LOCKS=0).
#   3  Ablage: mktemp -d ausserhalb des Arbeitsbaums; ein trap raeumt in jedem Ausgang ab.
#   4  Git-Arbeitsbaum: die Wurzel des Skripts ist die oberste Ebene eines Git-Arbeitsbaums.
#   5  Erzeuger: scripts/nachweise-erzeugen.sh ist eine regulaere, lesbare Datei; auf dem Weg liegt keine Verknuepfung.
#   6  Sollmenge S (KN-3): git ls-files -z --cached --others --exclude-standard, ohne Dateien mit dem Namen .gitkeep und ohne
#      docs/NACHWEISE.md; Rueckgabewert geprueft; die gelesenen Eintraege werden gegen die von grep -z gezaehlten gehalten (ein
#      Lesefehler wirkt nicht wie das Ende der Liste; Abweichung: Lage C nach dem Urteil, Kennung liste).
#   7  Erzeuger: "bash scripts/nachweise-erzeugen.sh <absolutes Ziel in der Ablage>" unter env -i. Rueckgabewert 0 oder 1, sonst
#      Lage C. Die Fehlerausgabe darf nur die Zeilen "FEHLT: <Pfad>", "NICHT COMMITTET: <Pfad>" und die Schlusszeile des
#      Erzeugers ("Nachweisverzeichnis erzeugt, aber unvollstaendig: ...") tragen; jede andere Zeile ist Lage C. Rueckgabewert 1
#      ohne eine Zeile FEHLT: oder NICHT COMMITTET: ist Lage C.
#   8  Tabelle: gelesen wird die zweite Spalte (Pfad, in Rueckwaertsakzenten) jeder Zeile unter dem Tabellenkopf
#      "| Artefakt | Pfad | Fester Verweis | Stand | Beschreibung |" bis zur ersten Zeile, die nicht mit "| " beginnt; zusaetzlich
#      die Zahl der Artefakte aus dem Kopfblock ("| **Artefakte** | n |"); sie muss die Zahl der Tabellenzeilen plus die der Meldungen
#      "FEHLT:" des Erzeugers sein. Kein Ziel, kein Tabellenkopf, eine Zeile ohne diese Form, keine Zeile, keine lesbare Zahl oder eine
#      andere Zahl: Lage C, Kennung tabelle.
#   9  Abgleich (KN-1, KN-2, KN-4) und Vergleich der committeten Liste (KN-9, nur bei leerem git status; sonst "nicht beurteilt").
#      Ein Mangel hier ist Lage C NACH dem Urteil: die Funde stehen in derselben Ausgabe (Kennungen git-status, git-kopf, tabelle fuer
#      die committete Liste), die Zeile KN-9 sagt dann "nicht beurteilt ... (Lage C)"; bei der Kennung nicht-committet (unten) laeuft
#      der Vergleich weiter. Bei leerem git status ist jede Meldung NICHT COMMITTET fuer einen Pfad von S ein Mangel des Erzeugers
#      (sein git log scheitert unbemerkt): Lage C, Kennung nicht-committet.
#
# FEHLERKLASSEN (Kennungen einzeln, ohne Bereichsschreibweise; das Pruefmittel zaehlt sie aus diesem Kommentar ab)
#   KN-1  Datei ohne Zeile: eine Datei der Sollmenge S ohne Zeile mit ihrem Pfad oder dem eines Verzeichnisses ueber ihr ist ein
#         Fund (FUND TAB KN-1 TAB Pfad). Auch eine unversionierte, nicht ignorierte Datei. Ein Verzeichnis gilt als ganzes Pfadsegment
#         (docs/sub deckt docs/sub/x/y.md, nicht docs/sub2/y.md).
#   KN-2  Zeile ohne Artefakt: eine Zeile, deren Pfad weder eine Datei von S noch ein Verzeichnis mit einer Datei von S ist (etwa
#         eine ignorierte Datei, eine Datei namens .gitkeep, ein Verzeichnis nur mit .gitkeep), ist ein Fund (FUND TAB KN-2 TAB Pfad).
#         Mehrere gleiche Zeilen ergeben einen Fund.
#   KN-3  Sollmenge: S ist jede Datei aus git ls-files -z --cached --others --exclude-standard ausser Dateien mit dem Namen
#         .gitkeep (in jedem Verzeichnis) und ausser dem Pfad docs/NACHWEISE.md. Ignorierte Dateien sind nicht Gegenstand; eine
#         globale Ausschlussliste des Aufrufers aendert S nicht. Namen mit Leerzeichen, Umlauten und Zeilenumbruch werden
#         NUL-getrennt gelesen und in der Ausgabe mit Steuerzeichen als Folge geschrieben.
#   KN-4  Erzeuger: "FEHLT: <Pfad>" (Zeile fuer eine Datei, die nicht besteht) ist ein Fund (FUND TAB KN-4 TAB Pfad).
#         "NICHT COMMITTET: <Pfad>" fuer eine Datei von S oder ein Verzeichnis mit einer Datei von S ist ein Hinweis mit Zahl und
#         kein Fund (der Verweis entsteht mit dem Commit), bei leerem git status aber Lage C (nicht-committet: der Erzeuger wertet das
#         Scheitern seines git log nicht aus). Lage C: Rueckgabewert weder 0 noch 1, Rueckgabewert 1 ohne Meldungszeile, eine unbekannte
#         Zeile der Fehlerausgabe (etwa "dirname: command not found").
#   KN-5  Tabelle: nur die Zeilen unter dem Tabellenkopf sind Artefaktzeilen; der Kopfblock der Datei, auch seine Zeile
#         "Erzeugt durch" mit dem Pfad des Erzeugers, und der Text nach der Tabelle sind es nicht. Gleiche Pfade mehrerer Zeilen zaehlen
#         als ein Pfad ("Tabelle: n Zeilen, m Pfade"). Lage C: kein Ziel, kein Tabellenkopf, eine Zeile ohne die Form
#         | Name | `Pfad` | ... |, keine Zeile, keine lesbare Zeile "| **Artefakte** | n |" im Kopfblock, eine Zahl n, die nicht die Zahl
#         der Tabellenzeilen plus der Meldungen FEHLT: ist (der Erzeuger zaehlt die Eintraege seiner Liste, auch die fehlenden).
#   KN-6  Umfeld: ein Werkzeug der geschlossenen Liste fehlt, bash ist aelter als Version 4, ein Argument, kein Git-Arbeitsbaum um die
#         Wurzel (auch: die Wurzel ist nicht die oberste Ebene), der Erzeuger fehlt, ist keine regulaere Datei, nicht lesbar oder
#         eine Verknuepfung, die Ablage ist nicht herstellbar oder liegt im Arbeitsbaum, git ls-files, git status, git ls-tree oder
#         git cat-file scheitert. Das Umfeld des Aufrufers (git-Variablen, globale git-Konfiguration, CDPATH, Arbeitsverzeichnis)
#         aendert das Urteil nicht; ein TMPDIR im Arbeitsbaum oder ein TMPDIR, das nicht besteht, ist Lage C (Ablage).
#   KN-7  Schreibfrei: das Skript schreibt nichts in den Arbeitsbaum (Kettengrundsatz, ADR 0002, Abschnitt 6): das Ziel des
#         Erzeugers liegt in der Ablage, docs/NACHWEISE.md bleibt unveraendert, git laeuft ohne optionale Sperren, es gibt keinen
#         Here-String (Bash legt dafuer ab 64 KiB, vor Version 5.1 immer, eine Wegwerfdatei an); die Ablage ist nach dem Lauf entfernt.
#   KN-8  Rueckgabewerte, Ausgabe, Vorrang: 0 kein Fund, 2 mindestens ein Fund, 3 Lage C; Lage C geht einem Fund vor, beide stehen
#         in derselben Ausgabe, wo das Urteil schon gefallen ist (liste, werkzeug:sort, git-status, git-kopf, tabelle bei der committeten
#         Liste, nicht-committet); die Ausgabe traegt keine Zeit und keine
#         Zufallswerte; die Fundzeilen sind nach Byte-Reihenfolge sortiert und ohne gleiche Zeilen; "Befunde: n" zaehlt sie; endet sort
#         mit einem Fehler oder liefert es nicht so viele Zeilen wie Funde erfasst sind, ist das Lage C.
#   KN-9  Die committete Liste: bei leerem "git status --porcelain --untracked-files=all" werden die Pfadmenge und die Zahl der
#         Artefakte der in HEAD committeten docs/NACHWEISE.md gegen die frische Liste gehalten; jeder Pfad in nur einer der beiden
#         Mengen, eine abweichende Zahl der Artefakte (Fund auf docs/NACHWEISE.md), eine Datei ohne lesbare Tabelle oder ohne lesbare
#         Zahl der Artefakte und eine Datei, die in HEAD fehlt, sind Funde (FUND TAB KN-9 TAB Pfad). Bei nicht leerem git status ist die
#         committete Liste zwangslaeufig
#         einen Commit alt: "KN-9: nicht beurteilt", kein Fund. Verglichen werden weder Pruefsummen noch Stand noch Beschreibung (GN-2).
#
# SCHNITTSTELLE ZU DEN MELDUNGEN DES ERZEUGERS (hier vermerkt, nicht am Erzeuger; wie der Meldetext des Gates bei D10)
#   Die Zeilen "FEHLT: <Pfad>" und "NICHT COMMITTET: <Pfad>" der Fehlerausgabe, die Kopfzeile der Tabelle und die Zeile
#   "| **Artefakte** | n |" des Kopfblocks sind die Schnittstelle zwischen dem Erzeuger und D12. Aendert sich eine, wird die
#   Fehlerausgabe unbekannt, die Tabelle unlesbar oder die Zahl falsch: Lage C (rot, nie gruen). Gelesen am Erzeuger (Einheit G3.4, 2026-10-30):
#     Rueckgabewert 0 bei Erfolg, 1 wenn ein Artefakt fehlt oder nicht committet ist; je fehlender Datei eine Zeile "FEHLT: <Pfad>"
#     (ohne Tabellenzeile), je nicht committeter Datei "NICHT COMMITTET: <Pfad>" (mit Tabellenzeile "*noch nicht committet*"); bei
#     Rueckgabewert 1 eine Schlusszeile "Nachweisverzeichnis erzeugt, aber unvollstaendig: ..." (mit "a" mit Umlaut); alle Meldungen
#     auf stderr; die Zahl im Kopfblock ist die Zahl der Eintraege der Artefaktliste, auch der fehlenden.
#
# GRENZEN (benannt, nicht geschlossen; je Grenze ein Fall im Pruefmittel, der sie als Durchlass oder Fehlalarm misst)
#   GN-1  Pfade mit senkrechtem Strich oder Zeilenumbruch lassen sich im Erzeuger nicht als Zeile aufnehmen (Trennzeichen der
#         Artefaktliste, eine Zeile je Eintrag): die Datei ist ein KN-1, solange kein Verzeichnis ueber ihr eine Zeile hat
#         (Fehlalarm). Ein Rueckwaertsakzent im Pfad wird gelesen (erster und letzter Akzent der Spalte begrenzen den Pfad).
#   GN-2  Geprueft wird allein der Pfad: Name, fester Verweis, Stand und Beschreibung einer Zeile sind nicht Gegenstand; KN-9 vergleicht
#         keine Pruefsummen und keinen Stand (die Drift des Zustandsberichts vom 2026-09-02, NF-001, bleibt fuer die Pruefsummen
#         ungeprueft; dafuer bleibt die Neuerzeugung Abschlussschritt jeder Einheit).
#   GN-3  Eine Verzeichniszeile deckt jede Datei darunter, auch eine neue (Durchlass, nach der Festlegung gewollt: kleinere Liste).
#   GN-4  Ignorierte Dateien (.gitignore, .git/info/exclude) gehoeren nicht zu S (Durchlass); die globale und die Systemkonfiguration
#         von git gelten nicht.
#   GN-5  KN-9 urteilt nur am sauberen Stand (Kopf des Pull Requests, Klon des Pruefers, Lauf auf der Gegenseite); vor dem Commit einer
#         Einheit ist die committete Liste zwangslaeufig einen Commit alt, dort steht "nicht beurteilt" (Durchlass vor dem Commit).
#
# RUECKGABEWERTE
#   0  kein Fund
#   2  mindestens ein Fund (KN-1, KN-2, KN-4, KN-9), keine Lage C
#   3  Lage C (siehe oben); ein Fund daneben bleibt in der Ausgabe stehen, wo das Urteil schon gefallen ist; das Makefile stellt 3 als
#      Lage C mit FEHLT=nachweise-pruefmittel weiter, jeden anderen Wert ungleich 0 als A_FAIL
#
# AUSGABE (Standardausgabe, ohne Zeiten)
#   "Tabelle: n Zeilen, m Pfade, Artefakte laut Kopf k"; "Sollmenge: n Dateien (ohne .gitkeep und docs/NACHWEISE.md)"; "Nicht
#   committet (Hinweis, kein Fund): n"; "KN-9: ..." (gleich, nicht beurteilt oder Fund); "=== Funde" mit je einer Zeile
#   "FUND TAB KN-n TAB Pfad"; "---"; ein Hinweis auf die Grenzen; "Befunde: n". Fehlerausgabe: Lage C ("LAGE C -- <Kennung>: ...").
#   Bei einer Lage C vor dem Urteil fehlen "Tabelle:" bis "Befunde:".
#
# WERKZEUGE (geschlossene Liste, gleich den aufgerufenen Befehlen; alles Uebrige sind Builtins der Shell)
#   bash, git, env, dirname, mktemp, mkdir, rm, sort, grep. Das Skript ruft selbst bash, git, env, mktemp, mkdir, rm, sort und grep
#   auf; dirname braucht der Erzeuger (ohne dirname laeuft er in der falschen Wurzel). Fehlt eines, ist das Lage C mit Namen, nie
#   stilles Durchlassen. Jeder Teilschritt mit Rueckgabewert wird geprueft; ein Fehler ist nie "kein Fund".
#
# PFLEGE
#   Wer eine Datei anlegt, die nicht in einer Verzeichniszeile liegt, ergaenzt im selben Arbeitsstand die Zeile im Erzeuger (sonst
#   KN-1). Kann die anlegende Rolle den Erzeuger nicht schreiben, setzt der Koordinator die Zeile im selben Zug (ADR 0002,
#   Abschnitt 5, Zeile "D12, Sollmenge, Funde und Hinweise"). Eine neue Klasse oder Grenze in diesem Kommentar verlangt Faelle (und
#   fuer eine Klasse KN eine Mutation) im Pruefmittel scripts/nachweise-vollstaendig-selbsttest.sh.

set -uo pipefail

# KN-6: Sortierung, Zeichenklassen und Wortgrenzen haengen sonst von der Spracheinstellung des Aufrufers ab.
export LC_ALL=C
# KN-6: ein CDPATH des Aufrufers lenkt "cd scripts/.." bei relativem Aufruf um und schreibt den Zielpfad auf die Standardausgabe
unset CDPATH

PROG="nachweise-vollstaendig.sh"
TAB=$'\t'
NL=$'\n'
ERZEUGER_REL="scripts/nachweise-erzeugen.sh"
LISTE_REL="docs/NACHWEISE.md"
TABELLENKOPF='| Artefakt | Pfad | Fester Verweis | Stand | Beschreibung |'
RE_ARTEFAKTE='^\| \*\*Artefakte\*\* \| ([0-9]+) \|$'
WERKZEUGE="bash git env dirname mktemp mkdir rm sort grep"

ABLAGE=""
aufraeumen() { # KN-7: die Ablage wird in jedem Ausgang entfernt
  if [ -n "$ABLAGE" ]; then rm -rf "$ABLAGE"; fi
}
trap aufraeumen EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

lage_c() { # lage_c <kennung> <meldung> [<beschaffungsweg>] : Abbruch vor dem Urteil
  echo "$PROG: LAGE C -- $1: $2" >&2
  if [ $# -ge 3 ]; then echo "$PROG: Beschaffen: $3" >&2; fi
  echo "$PROG: Der Gegenstand besteht fort, die Pruefung faellt aus. Rueckgabewert 3 und nicht 2: ein ausgefallenes Pruefmittel ist kein Befund am Bestand." >&2
  exit 3
}

# Schritt 1: Aufruf, Werkzeuge, Version von bash
if [ "$#" -ne 0 ]; then
  lage_c "aufruf" "kein Argument erwartet, erhalten: $# Argument(e)." "bash scripts/nachweise-vollstaendig.sh"
fi
for w in $WERKZEUGE; do
  command -v "$w" >/dev/null 2>&1 || lage_c "werkzeug:$w" "Werkzeug '$w' fehlt im Suchpfad." "Werkzeug installieren"
done
if [ "${BASH_VERSINFO[0]:-0}" -lt 4 ]; then
  lage_c "werkzeug:bash" "bash ab Version 4 erforderlich (assoziative Felder), gefunden: ${BASH_VERSION:-unbekannt}." "bash ab Version 4 verwenden"
fi
BASH_BIN="$(command -v bash)"
case "$BASH_BIN" in
  /*) ;;
  *) lage_c "werkzeug:bash" "bash ist nicht als absoluter Pfad aufloesbar ('$BASH_BIN')." ;;
esac

# Schritt 2: die git-Variablen des Aufrufers loeschen, die Gegenstand, Objektspeicher oder die Deutung von Pfadangaben verlegen
# (Muster des Belegpruefers, Einheit G0); Ersatzobjekte unter refs/replace/ gelten nicht
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_COMMON_DIR GIT_OBJECT_DIRECTORY GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_NAMESPACE GIT_CEILING_DIRECTORIES GIT_SHALLOW_FILE GIT_DISCOVERY_ACROSS_FILESYSTEM GIT_GLOB_PATHSPECS GIT_NOGLOB_PATHSPECS GIT_LITERAL_PATHSPECS GIT_ICASE_PATHSPECS 2>/dev/null || true
unset "${!GIT_TRACE@}" 2>/dev/null || true
export GIT_NO_REPLACE_OBJECTS=1

# Die Wurzel ist das Verzeichnis ueber dem scripts/ dieses Skripts, nicht das Arbeitsverzeichnis des Aufrufers
QUELLE="${BASH_SOURCE[0]}"
case "$QUELLE" in */*) QUELLVERZ="${QUELLE%/*}" ;; *) QUELLVERZ="." ;; esac
WURZEL="$(cd "$QUELLVERZ/.." 2>/dev/null && pwd -P)" || WURZEL=""
[ -n "$WURZEL" ] || lage_c "git-arbeitsbaum" "das Verzeichnis ueber dem Skript ist nicht erreichbar ($QUELLVERZ/..)."

# Schritt 3: Ablage ausserhalb des Arbeitsbaums (KN-7)
ABLAGE="$(mktemp -d)" || ABLAGE=""
if [ -z "$ABLAGE" ] || [ ! -d "$ABLAGE" ]; then
  ABLAGE=""
  lage_c "ablage" "mktemp -d schlug fehl; die Ablage fuer die frische Liste ist nicht herstellbar." "das temporaere Verzeichnis (TMPDIR) auf Platz und Rechte pruefen"
fi
ABLAGE="$(cd "$ABLAGE" 2>/dev/null && pwd -P)" || lage_c "ablage" "die Ablage ist nicht erreichbar."
case "$ABLAGE/" in
  "$WURZEL"/*) lage_c "ablage" "die Ablage liegt im Arbeitsbaum ($WURZEL); das Skript schreibt nichts in den Arbeitsbaum (Kettengrundsatz)." "TMPDIR ausserhalb des Arbeitsbaums waehlen"
esac
mkdir "$ABLAGE/home" || lage_c "ablage" "Unterverzeichnis der Ablage nicht anlegbar."

git_neutral() { # git unter "env -i": keine globale und keine Systemkonfiguration, kein HOME des Aufrufers, keine optionalen Sperren
  env -i "PATH=$PATH" "HOME=$ABLAGE/home" "LC_ALL=C" "GIT_CONFIG_NOSYSTEM=1" "GIT_CONFIG_GLOBAL=/dev/null" "GIT_NO_REPLACE_OBJECTS=1" "GIT_OPTIONAL_LOCKS=0" git "$@"
}

# Schritt 4: Git-Arbeitsbaum
GITTOP="$(git_neutral -C "$WURZEL" rev-parse --show-toplevel 2>/dev/null)" || GITTOP=""
if [ -n "$GITTOP" ]; then GITTOP="$(cd "$GITTOP" 2>/dev/null && pwd -P)" || GITTOP=""; fi
if [ -z "$GITTOP" ] || [ "$GITTOP" != "$WURZEL" ]; then
  lage_c "git-arbeitsbaum" "die Wurzel des Skripts ($WURZEL) ist nicht die oberste Ebene eines Git-Arbeitsbaums (git meldet: ${GITTOP:-nichts})."
fi
cd "$WURZEL" || lage_c "git-arbeitsbaum" "Wurzel nicht erreichbar: $WURZEL"

# Hat ein Segment des Pfads (relativ zur Wurzel, die Datei selbst eingeschlossen) eine symbolische Verknuepfung? Jedes Segment wird
# einzeln mit -L geprueft, keines wird verfolgt. Zerlegt wird mit Parametererweiterung, ohne externes Werkzeug.
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

# Kurzform fuer Meldungen: erste Zeile einer Datei, auf 200 Zeichen gekuerzt
kopfzeile() { # kopfzeile <datei>
  local z=""
  IFS= read -r z < "$1" 2>/dev/null || true
  printf '%s' "${z:0:200}"
}
# Anzeigeform eines Textes: Steuerzeichen (Zeilenumbruch, Tabulator und andere) werden als Folge geschrieben, damit jede Zeile der
# Ausgabe eine Zeile bleibt und die Felder einer Fundzeile nicht zerfallen (KN-3)
anz() { # anz <text> : setzt ANZ
  ANZ="$1"
  case "$ANZ" in *[[:cntrl:]]*) printf -v ANZ '%q' "$ANZ" ;; esac
}

# Schritt 5: Erzeuger
if [ ! -e "$ERZEUGER_REL" ] && [ ! -L "$ERZEUGER_REL" ]; then
  lage_c "erzeuger" "der Erzeuger $ERZEUGER_REL fehlt; ohne ihn gibt es keine frische Liste, die D12 pruefen koennte."
fi
if weg_verknuepft "$ERZEUGER_REL"; then lage_c "erzeuger-verknuepfung" "auf dem Weg zu $ERZEUGER_REL liegt eine symbolische Verknuepfung; das Skript ruft keinen Erzeuger ueber eine Verknuepfung auf."; fi
[ -f "$ERZEUGER_REL" ] || lage_c "erzeuger" "$ERZEUGER_REL ist keine regulaere Datei."
[ -r "$ERZEUGER_REL" ] || lage_c "erzeuger" "$ERZEUGER_REL ist nicht lesbar."

declare -A SSET=() DIRSET=() PSET=() ASET=() NCSET=() FUNDSET=()
fund() { # fund <klasse> <pfad> : eine Fundzeile (gleiche Zeilen einmal)
  anz "$2"
  FUNDSET["FUND${TAB}$1${TAB}$ANZ"]=1
}

# Schritt 6: Sollmenge S (KN-3)
git_neutral ls-files -z --cached --others --exclude-standard > "$ABLAGE/liste" 2> "$ABLAGE/liste.err"
LISTE_RC=$?
if [ "$LISTE_RC" -ne 0 ]; then
  lage_c "git-liste" "git ls-files endet mit Rueckgabewert $LISTE_RC: $(kopfzeile "$ABLAGE/liste.err")"
fi
LAGEC=()
N_GELESEN=0; N_S=0
while IFS= read -r -d '' f; do
  N_GELESEN=$((N_GELESEN + 1))
  case "${f##*/}" in .gitkeep) continue ;; esac
  if [ "$f" = "$LISTE_REL" ]; then continue; fi
  if [ -n "${SSET["$f"]+x}" ]; then continue; fi
  SSET["$f"]=1
  N_S=$((N_S + 1))
  d="$f"
  while :; do
    case "$d" in */*) d="${d%/*}" ;; *) break ;; esac
    DIRSET["$d"]=1
  done
done < "$ABLAGE/liste"
# Ein Lesefehler an der Liste darf nicht wie ihr Ende wirken: die Zahl der gelesenen Eintraege wird gegen die Zahl der NUL-terminierten
# Eintraege der Datei gehalten, die grep zaehlt (ein zweiter Lesepfad)
LISTE_ZAHL="$(grep -zc '' "$ABLAGE/liste" 2> "$ABLAGE/grep.err")"
LISTE_ZAHL_RC=$?
if [ "$LISTE_ZAHL_RC" -gt 1 ]; then
  LAGEC+=("liste: die Eintraege der Liste sind nicht zaehlbar (grep endet mit Rueckgabewert $LISTE_ZAHL_RC: $(kopfzeile "$ABLAGE/grep.err")).")
elif [ "$LISTE_ZAHL" != "$N_GELESEN" ]; then
  LAGEC+=("liste: die Liste hat $LISTE_ZAHL Eintraege, gelesen wurden $N_GELESEN.")
fi

# Schritt 7: der Erzeuger gegen ein absolutes Ziel in der Ablage (KN-4, KN-7)
ZIEL="$ABLAGE/NACHWEISE.md"
env -i "PATH=$PATH" "HOME=$ABLAGE/home" "LC_ALL=C" "GIT_CONFIG_NOSYSTEM=1" "GIT_CONFIG_GLOBAL=/dev/null" "GIT_NO_REPLACE_OBJECTS=1" "GIT_OPTIONAL_LOCKS=0" \
  "$BASH_BIN" "$WURZEL/$ERZEUGER_REL" "$ZIEL" > "$ABLAGE/erz.out" 2> "$ABLAGE/erz.err"
ERZ_RC=$?
if [ "$ERZ_RC" -ne 0 ] && [ "$ERZ_RC" -ne 1 ]; then
  lage_c "erzeuger-rueckgabewert" "der Erzeuger endet mit Rueckgabewert $ERZ_RC (erwartet 0 oder 1): $(kopfzeile "$ABLAGE/erz.err")"
fi
FEHLT=(); NC=(); UNBEKANNT=""
while zeile=; IFS= read -r zeile || [ -n "$zeile" ]; do
  case "$zeile" in
    "FEHLT: "*) FEHLT+=("${zeile#FEHLT: }") ;;
    "NICHT COMMITTET: "*) NC+=("${zeile#NICHT COMMITTET: }") ;;
    "Nachweisverzeichnis erzeugt, aber unvollst"*) ;;
    "") ;;
    *) if [ -z "$UNBEKANNT" ]; then UNBEKANNT="$zeile"; fi ;;
  esac
done < "$ABLAGE/erz.err"
if [ -n "$UNBEKANNT" ]; then
  anz "$UNBEKANNT"
  lage_c "erzeuger-meldung" "die Fehlerausgabe des Erzeugers hat eine Zeile, die dieses Skript nicht kennt: '$ANZ'." "Schnittstelle zu den Meldungen des Erzeugers: Kopfkommentar dieses Skripts"
fi
if [ "$ERZ_RC" -eq 1 ] && [ "${#FEHLT[@]}" -eq 0 ] && [ "${#NC[@]}" -eq 0 ]; then
  lage_c "erzeuger-ohne-meldung" "der Erzeuger endet mit Rueckgabewert 1, aber ohne eine Zeile FEHLT: oder NICHT COMMITTET:."
fi

# Schritt 8: Tabelle lesen (KN-5)
tabelle_lesen() { # tabelle_lesen <eingabe> <ausgabe> : schreibt je Artefaktzeile den Pfad der Spalte 2 in <ausgabe>; setzt T_ZEILEN, T_ARTEFAKTE, T_URTEIL
  local zeile in_tab=0 skip=0 rest pfadsp pfad rn=0
  T_ZEILEN=0; T_ARTEFAKTE=""; T_URTEIL=kopf
  : > "$2" || return 1
  while zeile=; IFS= read -r zeile || [ -n "$zeile" ]; do
    if [ "$in_tab" = 0 ]; then
      if [[ $zeile =~ $RE_ARTEFAKTE ]]; then T_ARTEFAKTE="${BASH_REMATCH[1]}"; fi
      if [ "$zeile" = "$TABELLENKOPF" ]; then in_tab=1; skip=1; T_URTEIL=ok; fi
      continue
    fi
    if [ "$skip" = 1 ]; then skip=0; continue; fi
    case "$zeile" in "| "*) ;; *) break ;; esac
    rn=$((rn + 1))
    rest="${zeile#| }"
    case "$rest" in *" | "*) ;; *) T_URTEIL="zeile:$rn"; return 0 ;; esac
    rest="${rest#* | }"
    pfadsp="${rest%% | *}"
    case "$pfadsp" in \`*\`) ;; *) T_URTEIL="zeile:$rn"; return 0 ;; esac
    pfad="${pfadsp#\`}"; pfad="${pfad%\`}"
    if [ -z "$pfad" ]; then T_URTEIL="zeile:$rn"; return 0; fi
    printf '%s\n' "$pfad" >> "$2" || return 1
    T_ZEILEN=$((T_ZEILEN + 1))
  done < "$1"
  return 0
}
if [ ! -s "$ZIEL" ]; then
  lage_c "tabelle" "der Erzeuger hat kein Ziel geschrieben ($ZIEL fehlt oder ist leer)."
fi
tabelle_lesen "$ZIEL" "$ABLAGE/pfade.neu" || lage_c "tabelle" "die Pfadspalte der frischen Liste ist nicht lesbar (die Ablage ist nicht beschreibbar)."
case "$T_URTEIL" in
  ok) ;;
  kopf) lage_c "tabelle" "die frische Liste hat keinen Tabellenkopf '$TABELLENKOPF'; die Form des Erzeugers hat sich geaendert." ;;
  *) lage_c "tabelle" "Tabellenzeile ${T_URTEIL#zeile:} der frischen Liste hat nicht die Form | Name | \`Pfad\` | ... |." ;;
esac
if [ "$T_ZEILEN" -eq 0 ]; then lage_c "tabelle" "die frische Liste hat keine Artefaktzeile (leere Tabelle)."; fi
if [ -z "$T_ARTEFAKTE" ]; then lage_c "tabelle" "die frische Liste hat keine lesbare Zeile '| **Artefakte** | n |' im Kopfblock; die Form des Erzeugers hat sich geaendert."; fi
if [ "$T_ARTEFAKTE" != "$((T_ZEILEN + ${#FEHLT[@]}))" ]; then lage_c "tabelle" "die Zahl der Artefakte im Kopf der frischen Liste ($T_ARTEFAKTE) ist nicht die Zahl ihrer Tabellenzeilen ($T_ZEILEN) plus der Meldungen FEHLT: (${#FEHLT[@]})."; fi
N_ZEILEN="$T_ZEILEN"; ART_NEU="$T_ARTEFAKTE"
N_PFADE=0
while p=; IFS= read -r p || [ -n "$p" ]; do
  if [ -z "$p" ]; then continue; fi
  if [ -z "${PSET["$p"]+x}" ]; then PSET["$p"]=1; N_PFADE=$((N_PFADE + 1)); fi
done < "$ABLAGE/pfade.neu"

# Schritt 9: Abgleich (KN-1, KN-2, KN-4)
for f in "${!SSET[@]}"; do # KN-1: jede Datei von S braucht eine Zeile mit ihrem Pfad oder dem eines Verzeichnisses ueber ihr
  p="$f"; erfasst=0
  while :; do
    if [ -n "${PSET["$p"]+x}" ]; then erfasst=1; break; fi
    case "$p" in */*) p="${p%/*}" ;; *) break ;; esac
  done
  if [ "$erfasst" = 0 ]; then fund "KN-1" "$f"; fi
done
for p in "${!PSET[@]}"; do # KN-2: jede Zeile braucht eine Datei von S oder ein Verzeichnis mit einer solchen
  if [ -z "${SSET["$p"]+x}" ] && [ -z "${DIRSET["$p"]+x}" ]; then fund "KN-2" "$p"; fi
done
for p in "${FEHLT[@]+"${FEHLT[@]}"}"; do fund "KN-4" "$p"; done # KN-4: FEHLT: des Erzeugers
for p in "${NC[@]+"${NC[@]}"}"; do # KN-4: NICHT COMMITTET: ist ein Hinweis, gezaehlt nur fuer eine Datei von S oder ein Verzeichnis mit einer
  if [ -n "${SSET["$p"]+x}" ] || [ -n "${DIRSET["$p"]+x}" ]; then NCSET["$p"]=1; fi
done
N_NC=${#NCSET[@]}

# Schritt 9, KN-9: die committete Liste gegen die frische, nur bei leerem git status. Ein Mangel hier ist Lage C NACH dem Urteil
# (LAGEC): die erfassten Funde stehen in derselben Ausgabe, die Zeile KN-9 sagt dann "nicht beurteilt"
git_neutral status --porcelain --untracked-files=all > "$ABLAGE/status" 2> "$ABLAGE/status.err"
STATUS_RC=$?
if [ "$STATUS_RC" -ne 0 ]; then
  LAGEC+=("git-status: git status endet mit Rueckgabewert $STATUS_RC: $(kopfzeile "$ABLAGE/status.err")")
  KN9="KN-9: nicht beurteilt -- git status scheitert (Lage C)"
elif [ -s "$ABLAGE/status" ]; then
  N_STATUS=0
  while zeile=; IFS= read -r zeile || [ -n "$zeile" ]; do N_STATUS=$((N_STATUS + 1)); done < "$ABLAGE/status"
  KN9="KN-9: nicht beurteilt -- Arbeitsbaum nicht sauber (git status: $N_STATUS Zeile(n)); die committete Liste ist einen Commit alt"
else
  # Bei leerem git status ist jede Datei von S committet. Eine Meldung NICHT COMMITTET fuer einen Pfad von S ist dann ein Mangel des
  # Erzeugers (er wertet das Scheitern seines git log nicht aus und meldet "nicht committet"), kein Hinweis
  if [ "$N_NC" -gt 0 ]; then
    LAGEC+=("nicht-committet: bei leerem git status meldet der Erzeuger NICHT COMMITTET fuer $N_NC Pfad(e) der Sollmenge; das kann bei sauberem Stand nicht stimmen (sein git log scheitert).")
  fi
  git_neutral ls-tree -z HEAD -- "$LISTE_REL" > "$ABLAGE/lstree" 2> "$ABLAGE/lstree.err"
  LSTREE_RC=$?
  if [ "$LSTREE_RC" -ne 0 ]; then
    LAGEC+=("git-kopf: git ls-tree HEAD endet mit Rueckgabewert $LSTREE_RC: $(kopfzeile "$ABLAGE/lstree.err")")
    KN9="KN-9: nicht beurteilt -- git ls-tree scheitert (Lage C)"
  elif [ ! -s "$ABLAGE/lstree" ]; then
    fund "KN-9" "$LISTE_REL"
    KN9="KN-9: Fund -- $LISTE_REL ist in HEAD nicht vorhanden"
  else
    git_neutral cat-file blob "HEAD:$LISTE_REL" > "$ABLAGE/committet.md" 2> "$ABLAGE/cat.err"
    CAT_RC=$?
    if [ "$CAT_RC" -ne 0 ]; then
      LAGEC+=("git-kopf: git cat-file blob HEAD:$LISTE_REL endet mit Rueckgabewert $CAT_RC: $(kopfzeile "$ABLAGE/cat.err")")
      KN9="KN-9: nicht beurteilt -- git cat-file scheitert (Lage C)"
    elif ! tabelle_lesen "$ABLAGE/committet.md" "$ABLAGE/pfade.alt"; then
      LAGEC+=("tabelle: die Pfadspalte der committeten Liste ist nicht lesbar (die Ablage ist nicht beschreibbar).")
      KN9="KN-9: nicht beurteilt -- die committete Liste ist nicht lesbar (Lage C)"
    elif [ "$T_URTEIL" != ok ] || [ "$T_ZEILEN" -eq 0 ] || [ -z "$T_ARTEFAKTE" ]; then
      fund "KN-9" "$LISTE_REL"
      KN9="KN-9: Fund -- die committete $LISTE_REL hat keine lesbare Tabelle der Artefakte oder keine lesbare Zahl der Artefakte"
    else
      ART_ALT="$T_ARTEFAKTE"
      N_ABW=0
      while p=; IFS= read -r p || [ -n "$p" ]; do
        if [ -z "$p" ]; then continue; fi
        ASET["$p"]=1
        if [ -z "${PSET["$p"]+x}" ]; then fund "KN-9" "$p"; N_ABW=$((N_ABW + 1)); fi
      done < "$ABLAGE/pfade.alt"
      for p in "${!PSET[@]}"; do
        if [ -z "${ASET["$p"]+x}" ]; then fund "KN-9" "$p"; N_ABW=$((N_ABW + 1)); fi
      done
      if [ "$ART_ALT" != "$ART_NEU" ]; then fund "KN-9" "$LISTE_REL"; N_ABW=$((N_ABW + 1)); fi
      if [ "$N_ABW" -eq 0 ]; then
        KN9="KN-9: gleich -- die committete $LISTE_REL hat dieselben $N_PFADE Pfade und dieselbe Zahl der Artefakte ($ART_NEU) wie die frische Liste"
      else
        KN9="KN-9: Fund -- die committete $LISTE_REL weicht von der frischen Liste ab ($N_ABW Unterschiede; Zahl der Artefakte committet $ART_ALT, frisch $ART_NEU)"
      fi
    fi
  fi
fi

# Ausgabe (ohne Zeiten, KN-8): die Fundzeilen sind erfasst (gleiche Zeilen einmal), sort ordnet sie; die Zeilen der Antwort werden mit
# mapfile aus einer Pipe gezaehlt (linear, kein Here-String) und gegen die erfasste Zahl gehalten, beide als Zeichenketten, damit eine
# Zaehlung ohne Ergebnis ein Mangel ist. Endet sort mit einem Fehler oder weicht die Zahl ab, stehen die erfassten Funde ungeordnet in
# der Ausgabe, und das Ergebnis ist Lage C.
BEFUNDE=${#FUNDSET[@]}
SORTIERT=""
SORT_MANGEL=""
if [ "$BEFUNDE" -gt 0 ]; then
  if SORTIERT="$(printf '%s\n' "${!FUNDSET[@]}" | sort)"; then
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
echo "Tabelle: $N_ZEILEN Zeilen, $N_PFADE Pfade, Artefakte laut Kopf $ART_NEU"
echo "Sollmenge: $N_S Dateien (ohne .gitkeep und docs/NACHWEISE.md)"
echo "Nicht committet (Hinweis, kein Fund): $N_NC"
echo "$KN9"
echo "=== Funde"
if [ -n "$SORTIERT" ]; then printf '%s\n' "$SORTIERT"; fi
echo "---"
echo "$PROG: geprueft wird der Pfad der Zeilen, nicht ihr Inhalt; die benannten Grenzen GN-1 bis GN-5 stehen im Kopfkommentar."
echo "Befunde: $BEFUNDE"

if [ -n "$SORT_MANGEL" ]; then
  LAGEC+=("werkzeug:sort: $SORT_MANGEL Die erfassten Funde stehen oben ungeordnet in der Ausgabe.")
fi
# Rueckgabewert: Lage C geht einem Fund vor (KN-8)
if [ "${#LAGEC[@]}" -gt 0 ]; then
  for e in "${LAGEC[@]}"; do echo "$PROG: LAGE C -- $e" >&2; done
  echo "$PROG: Der Gegenstand besteht fort, die Pruefung faellt teilweise aus. Rueckgabewert 3 und nicht 2: ein ausgefallenes Pruefmittel ist kein Befund am Bestand; Funde stehen oben." >&2
  exit 3
fi
if [ "$BEFUNDE" -gt 0 ]; then exit 2; fi
exit 0
