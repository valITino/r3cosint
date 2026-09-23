#!/usr/bin/env bash
# PreToolUse-Gate: trennt Prototyp und Produktionscode (Projektauftrag 5.6).
#
# 5.6: "Der Prototyp liegt in einem eigenen Verzeichnis, getrennt vom
# Produktionscode, ohne gemeinsame Abhaengigkeiten und ohne Importe in beide
# Richtungen." Der haeufigste Fehler bei diesem Vorgehen ist, dass der Prototyp
# still zur Grundlage wird und Provisorien in die Produktion wandern.
#
# Seit E4.2 (Backlog R3-Q-010, ADR 0002 6.13 g) erkennt dieses Gate
# zusaetzlich: einen Verzeichnisimport ohne Schraegstrich ("../prototype",
# Richtung 1) und einen Windows-Pfad mit Rueckstrich ("..\prototype\helper",
# Richtung 1) -- "prototype" gilt dabei nur getroffen, wenn davor entweder
# der Zeichenkettenanfang oder ein Pfadtrenner (/ oder \) steht: "es-prototype"
# trifft deshalb nicht mehr, "./prototype" und "prototype//y" weiterhin
# (Preis der Namenslogik: ein beliebiger Vorspann, der auf einen Trenner
# endet, etwa "mock/backend/prototype", trifft ebenfalls -- das letzte
# Segment "prototype" entscheidet); ein vorangestelltes "./" vor MINDESTENS
# einem "../" in Richtung 2 (z. B. "./../backend/api"; ein Pfad, der den
# Prototyp nicht verlaesst, etwa "./lib/util" oder "src/main.js", ist seit
# der Behebung vom 2026-09-23 kein Treffer mehr -- vorher war "./" allein
# genug, ein Fehlalarm auf jeden generischen Namen aus WURZELN); fuer die
# Bauwurzeln backend/, frontend/ und deploy/ (die Bauwurzeln backend/ und
# frontend/ nach ADR 0002 sowie deploy/, siehe Begruendung bei Richtung 2)
# zusaetzlich der Verzeichnisimport ohne Schraegstrich und der
# Rueckstrich-Pfad in Richtung 2; die HTML-Formen src=/href= in Richtung 2
# (die Richtung 1 schon kannte, jetzt ebenfalls nur mit mindestens einem
# "../") sowie die Python-Formen "from backend import x", "import
# backend.api" und "importlib.import_module(...)" in Richtung 2 -- dort
# bewusst nur die Bauwurzeln backend/frontend/deploy, nicht die generischen
# Namen der Variable WURZELN (Begruendung dort).
#
# Benannte Grenze -- Asymmetrie der Pfadschreibweise: Richtung 1 ist bei der
# Pfadschreibweise bewusst weiter gefasst (ein beliebiger Vorspann vor einem
# Trenner reicht), weil "prototype" EIN bestimmter Name ist; Richtung 2 ist
# praefixgebunden (nur "../"-Ketten, optional mit einem "./" davor, kein
# beliebiger Vorspann, kein Wurzelpfad "/backend/..." oder Alias "~/frontend/..."
# in src=/href=; in src=/href= der Richtung 2 ausserdem nur Pfade MIT
# Schraegstrich hinter der Wurzel, also weder "../backend" noch
# "..\backend\app.js" -- Richtung 1 kennt beide Formen, B47 und B48 --,
# und beim Rueckstrich-Import nur der einfache Rueckstrich, nicht die in
# JS-Quelltext uebliche Verdopplung "..\\backend\\api"; ein mehrfaches "./"
# vor "../" wie "./././../backend" trifft seit der Behebung vom 2026-09-23
# nicht mehr -- Restbefunde der Nachpruefung vom 2026-09-23, Entscheid ueber
# eine Aufnahme als Fortschreibung von ADR 0002, 6.13 c),
# weil die Produktionswurzeln generische Namen sind und ein
# Vorspann wie "mock/backend/" im Prototyp ein Fehlalarm waere. Bekannte,
# fuer beide Richtungen SYMMETRISCHE Luecken (Leerraum vor "(" bei require,
# "@import url(", Leerraum um "=" bei src/href, "__import__('prototype')"
# ohne Punkt/Schraegstrich) sind unveraendert offen; Entscheid ueber eine
# Behebung liegt beim Software Architect (Fortschreibung nach 6.13 c) und
# wird als Pruefstand gemessen.
#
# Seit E4.3 (Backlog R3-Q-010, ADR 0002 6.13 g) erkennt dieses Gate bei Bash
# dieselbe Befehlsklasse mit Schreibwirkung wie das main-Gate
# (.claude/hooks/block-main-write.sh, dort das mit "bereinigt" gepruefte
# Muster): zusaetzlich zu Umleitung/tee/sed -i/Heredoc jetzt auch die
# Dateiwerkzeuge mv/cp/rm/mkdir/touch/truncate/ln/install/patch/dd, einen
# Interpreter mit Inline-Code (python/perl/ruby/node/deno/php/Rscript mit
# -c/-e/-i/-p/-r/-n) und ed/ex (ST-09, vorher wurden Interpreter wie
# "node -e" oder "python3 -c", die ueber ihre eigene Datei-API schreiben,
# ohne Umleitungszeichen im Befehlstext gar nicht als schreibend erkannt).
# Geprueft wird weiterhin nur die Kombination aus Schreibwirkung UND
# Importmuster mit "prototype" -- reines Kopieren ohne Importmuster (etwa
# "cp ../prototype/helper.js frontend/src/helper.js") bleibt frei, weil das
# Importmuster fehlt.
#
# Seit E4.3 gilt ausserdem: eine Eingabe, die sich nicht als JSON-Objekt mit
# einem Objekt tool_input lesen laesst, blockiert mit Rueckgabewert 2 und
# einer Meldung auf stderr, die die nicht lesbare Eingabe ueber ihren Anfang
# und ihre Laenge benennt (ST-13, analog zur jq-/git-Wache: das Gate kann
# nicht pruefen und blockiert deshalb, statt still durchzulassen; ADR 0002,
# 6.13 b). Vorher lief eine leere, syntaktisch ungueltige oder mit
# tool_input als Zeichenkette versehene Eingabe still mit Rueckgabewert 0
# durch.
#
# BENANNTE GRENZE (P-10, ADR 0002, 6.13 c: benannte Grenze, keine neue
# Faehigkeit): 5.6 nennt drei Trennungen: eigenes Verzeichnis, keine
# gemeinsamen Abhaengigkeiten, keine Importe in beide Richtungen. Dieses
# Gate prueft NUR die Importe. Ob Prototyp und Produktionscode dieselben
# Abhaengigkeiten (package.json, pyproject.toml) fuehren, prueft weder
# dieses Gate noch ein Kettenschritt.
#
# Belegt und geprueft ueber scripts/pretooluse-gates-selbsttest.sh.
#
# AUSNAHME FUER FLUECHTIGE ZIELE (DT-E43-5, seit E4.3, wie im main-Gate):
# Umleitungen nach /dev/null, unter /tmp und in die Verzeichnisse aus TMPDIR,
# RUNNER_TEMP und SCRATCH* werden vor der Schreibwirkungspruefung aus dem
# Befehlstext entfernt, sonst waere reines Suchen mit "2>/dev/null" ein
# Fehlalarm. OFFENER RESTBEFUND, keine benannte Grenze (DT-E43-6 und N-1 der
# Nachpruefung vom 2026-09-23, gefuehrt in docs/uebergaben/ vom 2026-09-23,
# E4.3): die Ausnahme greift auch bei "/tmp/.." und "$TMPDIR/.." sowie bei
# "/dev/nullx"; das gilt in beiden Gates gleich und ist zu beheben, nicht
# festzuschreiben.
#
# PREIS DER TEXTPRUEFUNG (B-5): "Suchen mit demselben Wortlaut" (P06, P15)
# bleibt frei, WEIL der reine Suchbefehl keine Schreibwirkung im Text traegt.
# Traegt der Suchtext selbst eine der Schreibwirkungs-Zeichenklassen -- etwa
# ein zitierter Interpreteraufruf mit Inline-Code samt Import als Suchtext
# ('grep -rn "python3 -c ...import h from \"../prototype/helper\"..." .') --,
# blockiert dieses Gate den Suchbefehl trotzdem: es liest nur Text und kann
# Suchtext von auszufuehrendem Code nicht unterscheiden. Ausweg: die Datei mit
# dem Write-Werkzeug schreiben, dort prueft das Gate pfadgenau statt textlich.
#
# Rueckgabewert 2 blockiert und gibt stderr als Begruendung an Claude zurueck.
# Rueckgabewert 1 blockiert NICHT (3.4) und wird hier nirgends verwendet.
set -uo pipefail

if ! command -v jq >/dev/null 2>&1; then
  echo "Gate prototyp-trennung: jq ist nicht installiert; das Gate kann nicht pruefen." >&2
  echo "Installieren (z.B. 'apt-get install -y jq') oder das Gate bewusst entfernen." >&2
  exit 2
fi

input=$(cat)

# ST-13: die Eingabe muss ein JSON-Objekt mit einem Objekt tool_input sein,
# sonst kann das Gate nicht pruefen und blockiert fail-closed wie die
# jq-Wache oben (ADR 0002, 6.13 b).
if ! printf '%s' "$input" | jq -es 'length == 1 and (.[0] | type == "object" and (.tool_input | type == "object"))' >/dev/null 2>&1; then
  echo "Gate prototyp-trennung: Eingabe nicht auswertbar (kein JSON-Objekt mit einem Objekt tool_input); das Gate kann nicht pruefen und blockiert (ADR 0002, 6.13 b)." >&2
  eingabe_laenge=$(printf '%s' "$input" | wc -c | tr -d ' ')
  if [ "$eingabe_laenge" = "0" ]; then
    echo "Anfang der Eingabe: leer (0 Bytes)" >&2
  else
    eingabe_anfang=$(printf '%s' "$input" | tr '\n\t\r' '   ' | cut -c1-80)
    echo "Anfang der Eingabe: '$eingabe_anfang' ($eingabe_laenge Bytes)" >&2
  fi
  exit 2
fi

proj="${CLAUDE_PROJECT_DIR:-$PWD}"

# Bash-Befehle: grobes Netz. Ein Schreibbefehl, dessen Text einen Import mit
# Bezug auf prototype/ traegt (Heredoc, echo mit Umleitung, sed), wuerde am
# pfadgenauen Pruefweg unten vorbeischreiben -- der kennt nur file_path und
# lief bei Bash bis zum 2026-08-25 gar nicht erst (Matcher ohne Bash,
# ausgefuehrt belegt). Blockiert wird nur die Kombination aus Schreibwirkung
# UND Importmuster mit prototype; reines Suchen und Lesen bleibt frei. Bei
# einem Fehlalarm die Datei mit dem Write-Werkzeug schreiben -- dort prueft
# das Gate pfadgenau (dieselbe Abwaegung wie beim main-Gate,
# .claude/rules/claude-konfiguration.md).
tool=$(printf '%s' "$input" | jq -r '.tool_name // empty')
if [ "$tool" = "Bash" ]; then
  cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty')
  [ -n "$cmd" ] || exit 0
  # Fuer die Importpruefung den Befehl zu einer Zeile zusammenziehen und
  # Kommentare entfernen -- ein Heredoc mit ueber mehrere Zeilen verteiltem oder
  # durch Kommentar getrenntem Import entginge sonst dem zeilenweisen grep
  # (Befunde der statischen Pruefung vom 2026-08-25).
  cmd_flach=$(printf '%s' "$cmd" | sed 's#//[^\n]*##')
  for _i in 1 2 3 4 5; do
    neu=$(printf '%s' "$cmd_flach" | sed 's#/\*[^*]*\*/##g')
    [ "$neu" = "$cmd_flach" ] && break
    cmd_flach="$neu"
  done
  cmd_flach=$(printf '%s' "$cmd_flach" | tr '\n\t' '  ')
  # ST-09: dieselbe Befehlsklasse mit Schreibwirkung wie das main-Gate (Kopf-
  # kommentar oben) -- Umleitung/tee/sed -i/Heredoc, dazu die Dateiwerkzeuge
  # mv/cp/rm/mkdir/touch/truncate/ln/install/patch/dd, ein Interpreter mit
  # Inline-Code und ed/ex. tee ohne Pipe (z. B. hinter '< <(...)' oder hinter
  # 'sudo'/'|&') zaehlt seit der Behebung vom 2026-09-23 ebenfalls, dieselbe
  # Klasse wie das main-Gate (\btee statt [|]...tee, B-1).
  #
  # Fluechtige Ziele wie im main-Gate ausgenommen (DT-E43-5, 2026-09-23):
  # Umleitungen nach /dev/null, /tmp/..., $TMPDIR/$RUNNER_TEMP/$SCRATCH...
  # werden vor der Schreibwirkungspruefung entfernt, sonst waere z. B. ein
  # reines Suchen mit "2>/dev/null" ein Fehlalarm.
  bereinigt=$(printf '%s' "$cmd" | sed -E \
    -e 's/[0-9]?>&[0-9]//g' \
    -e 's/[0-9]?>>?[[:space:]]*(\/dev\/null|\/tmp\/[^[:space:]]*|"?\$\{?(TMPDIR|RUNNER_TEMP|SCRATCH[A-Z_]*)\}?[^[:space:]]*)//g')
  schreibwirkung='(>>?|\btee[[:space:]]|sed[[:space:]]+-[a-zA-Z]*i|<<)|(\b(mv|cp|rm|mkdir|touch|truncate|ln|install|patch|dd)[[:space:]]|\b(python[0-9.]*|perl|ruby|node|deno|php|Rscript)[[:space:]]+([^|;&]*[[:space:]]+)?-[a-zA-Z]*(c|e|i|p|r|n)([^a-zA-Z]|$)|\b(ed|ex)[[:space:]])'
  if printf '%s' "$bereinigt" | grep -Eq "$schreibwirkung" \
      && printf '%s' "$cmd_flach" | grep -Eq "(from|require|import|@import|__import__|import_module)[^|&]*prototype([./\"'[:space:]]|\$)"; then
    echo "BLOCKIERT (Projektauftrag 5.6): Shell-Befehl mit Schreibwirkung und einem Import, der 'prototype' beruehrt." >&2
    echo "Importe zwischen prototype/ und Produktionscode sind in beide Richtungen untersagt." >&2
    echo "Die Datei mit dem Write-Werkzeug schreiben -- dort prueft das Gate pfadgenau." >&2
    exit 2
  fi
  exit 0
fi

fp=$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_input.notebook_path // .tool_input.path // empty')
[ -n "$fp" ] || exit 0

case "$fp" in
  "$proj"/*) rel="${fp#"$proj"/}" ;;
  /*)        exit 0 ;;                 # ausserhalb des Projekts: nicht zustaendig
  *)         rel="$fp" ;;
esac

# Prosa darf prototype/ nennen. Geprueft wird nur Code.
case "$rel" in
  docs/*|.claude/*|*.md|*.txt|*.adoc|*.rst) exit 0 ;;
esac

# Alle String-Werte aus tool_input ausser den Pfadfeldern und old_string.
# Deckt content (Write), new_string (Edit) und new_source (NotebookEdit) ab und
# ueberlebt Feldumbenennungen. old_string ist ausgenommen, weil es den ALTEN
# Stand traegt: ein Edit, das einen verbotenen Import ENTFERNT, hat das Muster
# nur in old_string und wuerde sonst blockiert -- das Gate hielte dann genau die
# Korrektur auf, die es erzwingen will (Befund der statischen Pruefung vom
# 2026-08-25, ausgefuehrt belegt).
payload=$(printf '%s' "$input" | jq -r '
  [ ( (.tool_input // {}) | to_entries[]
      | select(.value | type == "string")
      | select(.key | test("path|^old_string$"; "i") | not)
      | .value ),
    # MultiEdit fuehrt die Aenderungen in einem Array edits[]; je Eintrag zaehlt
    # nur new_string, nicht old_string (gleiche Begruendung wie oben). MultiEdit
    # steht seit dem 2026-08-25 in beiden Matchern der settings.json, damit der
    # Hook dafuer ueberhaupt feuert. Ob das Werkzeug in dieser Umgebung
    # tatsaechlich verfuegbar ist, ist offen; die Behandlung ist Vorsorge und
    # schadet nichts, falls es nie auftritt.
    ( (.tool_input.edits // []) | .[]? | objects | .new_string // empty )
  ] | join("\n")')
[ -n "$payload" ] || exit 0

# Zusaetzlich eine normalisierte Fassung: Kommentare entfernt, Zeilenumbrueche
# und Tabulatoren zu Leerzeichen. grep arbeitet zeilenweise; ein Import, dessen
# Schluesselwort, 'from' und Pfad ueber mehrere Zeilen verteilt sind
# (Prettier-Umbruch) oder durch einen Kommentar getrennt sind, entginge der
# zeilenweisen Pruefung (Befunde der statischen Pruefung vom 2026-08-25).
# Entfernt werden ZUERST Zeilenkommentare (// bis Zeilenende, N2) und DANN
# Blockkommentare -- letztere in einer Schleife, weil eine einzelne Ersetzung
# verschachtelte Kommentare '/* a /* b */ c */' nur teilweise aufloest (N3).
# Geprueft wird gegen Original UND normalisierte Fassung in einem Durchgang; die
# Anfuehrungszeichen-Grenzen der Muster verhindern, dass die zusammengezogene
# Zeile quer ueber unbeteiligte Zeichenketten hinweg falsch anschlaegt.
#
# BEWUSSTER PREIS -- nicht "wegoptimieren": Weil auch die UNBEREINIGTE Fassung
# geprueft wird, blockiert das Gate auch eine Datei, deren Kommentar einen
# verbotenen Importpfad woertlich als Beispiel zeigt
# ('// Verboten: import { h } from "../prototype/helper";'). Das ist ein
# Fehlalarm, und er ist der guenstigere Fehler. Wuerde nur die bereinigte
# Fassung geprueft, entkaeme ein echter Import: 'import x from "prototype//y"'
# wird von der //-Bereinigung zu 'import x from "prototype' verstuemmelt und
# passt auf kein Muster mehr (ausgefuehrt belegt am 2026-08-25). Wer den
# Fehlalarm beseitigen will, oeffnet damit dieses Loch. Ausweg fuer den
# Einzelfall: solche Beispiele in eine .md-Datei schreiben (Doku-Ausnahme
# weiter oben) oder den Pfad im Kommentar nicht woertlich ausschreiben.
payload_norm=$(printf '%s' "$payload" | sed 's#//[^\n]*##')
for _i in 1 2 3 4 5; do
  neu=$(printf '%s' "$payload_norm" | sed 's#/\*[^*]*\*/##g')
  [ "$neu" = "$payload_norm" ] && break
  payload_norm="$neu"
done
payload_norm=$(printf '%s' "$payload_norm" | tr '\n\t' '  ')
pruefstoff=$(printf '%s\n%s' "$payload" "$payload_norm")

Q="[\"'\`]"
NQ="[^\"'\`]"

# Verzeichnisliste der Richtung 2 (Prototyp importiert aus dem Produktionscode)
# EINMAL definiert und ueber ${WURZELN} in den betroffenen Mustern verwendet --
# sonst kaeme der Suchtext der Mutationsprobe MP3
# (scripts/pretooluse-gates-selbsttest.sh) mehrfach vor und waere nicht mehr
# eindeutig ersetzbar (R3-Q-010, E4.2).
WURZELN='backend|frontend|deploy|src|app|lib|server|packages|apps'

if [ "${rel#prototype/}" != "$rel" ]; then
  # Richtung 2: Prototyp importiert aus dem Produktionscode. Die Bauwurzeln
  # nach ADR 0002 Abschnitt 5 sind backend/ und frontend/ (Zitat: "Zwei
  # Bauwurzeln (backend/, frontend/), ein Einstieg (Makefile)"); deploy/ steht
  # im Verzeichnisbaum, ist aber dort ausdruecklich KEINE Bauwurzel -- es wird
  # zusaetzlich erfasst, weil ein Import daraus ebenso unerwuenscht waere. Die
  # uebrigen Namen bleiben Vorhalt fuer generische Layouts. Bis zum 2026-08-25
  # fehlten backend/ und frontend/ -- ein Import aus genau den Verzeichnissen,
  # die der ADR als Bauwurzeln festlegt, lief durch (ausgefuehrt belegt).
  #
  # Seit E4.2 (R3-Q-010, belegte Luecken ST-05 und P-01) zusaetzlich erkannt:
  # ein vorangestelltes "./" vor MINDESTENS einem "../" (ST-05, z. B.
  # "./../backend/api"; "./lib/util" bleibt frei); die HTML-Formen src=/href=, die Richtung 1 schon
  # kannte (P-01); und die Python-Formen "from backend import x",
  # "import backend.api" sowie "importlib.import_module(...)" (P-01) -- dort
  # bewusst NUR backend/ und frontend/ (Bauwurzeln nach ADR 0002) sowie
  # deploy/, nicht die generischen
  # Namen der Variable WURZELN (src, app, lib, server, packages, apps): ein
  # "import app" waere in einem Python-Prototyp ein plausibles Fremdmodul,
  # und der Fehlalarm daraus teurer als die engere Deckung.
  if printf '%s' "$pruefstoff" | grep -Eq \
      -e "(from|require\(|import\(|@import|import)[[:space:]]*\(?[[:space:]]*${Q}((\.\./)*|\./(\.\./)+)(${WURZELN})/" \
      -e "(from|require\(|import\(|@import|import)[[:space:]]*\(?[[:space:]]*${Q}[@~#]/" \
      -e "(src|href)=${Q}(\./)?(\.\./)+(${WURZELN})/" \
      -e "^[[:space:]]*(from|import)[[:space:]]+(backend|frontend|deploy)([.[:space:]]|\$)" \
      -e "(import_module|__import__|import)[[:space:]]*\([[:space:]]*${Q}(backend|frontend|deploy)[./]" \
      -e "(from|require\(|import\(|@import|import)[[:space:]]*\(?[[:space:]]*${Q}(\./)?(\.\./)+(backend|frontend|deploy)${Q}" \
      -e "(from|require\(|import\(|@import|import)[[:space:]]*\(?[[:space:]]*${Q}(\.\.\\\\)+(backend|frontend|deploy)(\\\\|${Q})"; then
    echo "BLOCKIERT (Projektauftrag 5.6): Richtung 2 (Prototyp -> Produktionscode): '$rel' liegt im Prototyp und importiert aus dem Produktionscode." >&2
    echo "Der Prototyp ist Wegwerf-Code und haelt keine Abhaengigkeit in beide Richtungen." >&2
    echo "Benoetigte Werte im Prototyp eigenstaendig hinterlegen, statt sie zu importieren." >&2
    exit 2
  fi
  exit 0
fi

# Richtung 1: Produktionscode importiert aus dem Prototyp.
# Seit E4.2 (ST-04) gilt "prototype" auch als getroffen, wenn direkt danach
# ein Rueckstrich oder ein schliessendes Anfuehrungszeichen folgt statt eines
# Schraegstrichs: ein Verzeichnisimport wie "../prototype" oder ein
# Windows-Pfad "..\prototype\helper" blieb sonst unerkannt (belegt ueber B02,
# B03, ZF5a, ZF5b, ZF5c, ZF5e). Vor "prototype" muss der Zeichenkettenanfang
# oder ein Pfadtrenner stehen ("es-prototype" trifft nicht). "prototypes/" und
# "prototype_alt/" treffen nicht, weil auf "prototype" ein Buchstabe folgt,
# der keine der drei Alternativen ist; "prototyp/" enthaelt die Zeichenkette
# "prototype" gar nicht.
if printf '%s' "$pruefstoff" | grep -Eq \
    -e "(from|require\(|import\(|@import|import)[[:space:]]*\(?[[:space:]]*${Q}(${NQ}*[/\\\\])?prototype(/|\\\\|${Q})" \
    -e "(src|href)=${Q}(${NQ}*[/\\\\])?prototype(/|\\\\|${Q})" \
    -e "^[[:space:]]*(from|import)[[:space:]]+prototype([.[:space:]]|\$)" \
    -e "(import_module|__import__|import)[[:space:]]*\([[:space:]]*${Q}prototype[./]"; then
  echo "BLOCKIERT (Projektauftrag 5.6): Richtung 1 (Produktionscode -> Prototyp): '$rel' ist Produktionscode und importiert aus 'prototype/'." >&2
  echo "Der Prototyp ist ein Wegwerf-Prototyp; sein Code wird nach der Freigabe nicht weiterverwendet." >&2
  echo "Weiter gehen nur Bildschirmfluss, Komponenteninventar, Design-Tokens, Oberflaechentexte und" >&2
  echo "der synthetische Datenbestand - als Vorlage nachbauen, nicht importieren." >&2
  exit 2
fi
exit 0
