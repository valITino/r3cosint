#!/usr/bin/env bash
# =============================================================================
# scripts/prototyp-trennung-pruefen.sh -- Kettenschritt D10 (Prototyp-Trennung)
# =============================================================================
#
# Anforderung R3-Q-001 (das DoD-Gate stuetzt sich auf die Kette). Grundlage: Projektauftrag 5.6 ("ohne Importe in beide
# Richtungen"); ADR 0002, Abschnitt 5, Nachtrag vom 2026-10-29 (Festlegung fuer G3), Zeilen zu D10, und Abschnitt 6 (Zeile D10,
# Objekttabelle: Gegenstand ist "prototype/ vorhanden"); docs/12_Freigabe_Grundgeruest.md, Abschnitt 4, G3, Festlegung 2.
# Muster: scripts/belege-pruefen.sh (D20) und scripts/abnahme-abgleich.sh (D7). Einheit G3.3.
#
# ZWECK
#   Das Gate .claude/hooks/block-prototype-import.sh (PreToolUse, R3-Q-010) sieht nur, was gerade geschrieben wird. D10 prueft den
#   Bestand: Das Skript ruft das Gate UNVERAENDERT je Textdatei unter prototype/, backend/, frontend/ und deploy/ mit einem
#   nachgebildeten Ereignis des Werkzeugs Write auf und meldet jede Sperre der Richtung 1 (Produktionscode -> Prototyp) und der
#   Richtung 2 (Prototyp -> Produktionscode) als Fund. Es gibt eine Erkennungsgrammatik, die des Gates; dieses Skript fuehrt kein
#   eigenes Muster. Die Kette urteilt vor dem Commit (wie D11): Auch unversionierte, nicht ignorierte Dateien gehoeren zum Bestand.
#
# AUFRUF   bash scripts/prototyp-trennung-pruefen.sh        (kein Argument; ein Argument ist Lage C)
#   Die Wurzel ist das Verzeichnis ueber dem scripts/ dieses Skripts, nicht das Arbeitsverzeichnis des Aufrufers.
#
# ABLAUF (in dieser Reihenfolge; ein Mangel in den Schritten 1 bis 7 ist Lage C vor jedem Urteil)
#   1  Aufruf und Werkzeuge der geschlossenen Liste (siehe WERKZEUGE).
#   2  Umfeld: die git-Variablen des Aufrufers werden geloescht (GIT_DIR, GIT_WORK_TREE, GIT_INDEX_FILE und weitere), ebenso
#      CDPATH vor dem ersten cd; GIT_NO_REPLACE_OBJECTS=1, LC_ALL=C. Jeder git-Aufruf und jeder Aufruf des Gates laeuft unter
#      "env -i" mit festen Variablen (PATH des Aufrufers, leeres HOME, bei git GIT_CONFIG_NOSYSTEM=1 und GIT_CONFIG_GLOBAL=/dev/null).
#   3  Ablage: mktemp -d ausserhalb des Arbeitsbaums (TMPDIR, Home und Ereignisse des Gates); ein trap raeumt in jedem Ausgang ab.
#   4  Git-Arbeitsbaum: die Wurzel des Skripts ist die oberste Ebene eines Git-Arbeitsbaums.
#   5  Gate: .claude/hooks/block-prototype-import.sh ist eine regulaere, lesbare Datei; auf dem Weg liegt keine Verknuepfung.
#   6  Kontrollprobe (KD-4) mit vier Ereignissen gegen das Gate, das urteilen wird: je Richtung eines, das sperren muss, und eines,
#      das durchlaufen muss. Weicht eines ab, ist das Lage C ("Kontrollprobe: n von 4"); kein Urteil ueber den Bestand folgt.
#   7  Auswahl: git ls-files -z --cached --others --exclude-standard -- prototype backend frontend deploy (geschlossene Liste der
#      vier Wurzeln) in eine Datei der Ablage, Rueckgabewert geprueft.
#   8  Je Eintrag: Verknuepfung und Untermodul sind ein Fund (KD-7); eine Nicht-Datei (fehlt auf der Platte, Fifo und Aehnliches)
#      wird nie geoeffnet, nur genannt; eine leere und eine binaere Datei (NUL-Byte, GD-4) gehen nicht an das Gate und werden gezaehlt
#      und genannt; jede Textdatei geht mit einem Ereignis {"tool_name":"Write","tool_input":{"file_path":<absoluter Pfad>,
#      "content":<Inhalt>}} (jq --rawfile) an das Gate: unter "env -i" mit PATH, leerem HOME, TMPDIR in der Ablage,
#      CLAUDE_PROJECT_DIR (die Wurzel) und LC_ALL=C, unter timeout -k 1 20 je Aufruf, im Verzeichnis der Wurzel.
#   9  Antwort des Gates je Textdatei: Rueckgabewert 0 ohne Ausgabe ist kein Fund; Rueckgabewert 2 mit einer Zeile der Fehlerausgabe,
#      die mit "BLOCKIERT (Projektauftrag 5.6): Richtung 1" oder "...: Richtung 2" beginnt, ist ein Fund; JEDE andere Antwort (auch
#      ein Rueckgabewert 2 ohne diese Marke, 1, 124, 137, eine leere Antwort, ein Rueckgabewert 0 mit Ausgabe) ist Lage C mit
#      dem Dateinamen: das Gate sperrt auch, wenn es nicht pruefen kann (ADR 0004, Teil A, Entscheid 3); das ist ein ausgefallenes
#      Pruefmittel und kein Fund. Der Lauf geht bei den uebrigen Dateien weiter. Gesamtbudget 120 s (am Aufruf gemessen); ist es
#      ueberschritten, ist das Lage C, die uebrigen Dateien bleiben ungeprueft.
#
# FEHLERKLASSEN (Kennungen einzeln, ohne Bereichsschreibweise; das Pruefmittel zaehlt sie aus diesem Kommentar ab)
#   KD-1  Richtung 1: eine Datei unter backend/, frontend/ oder deploy/ (auch unversioniert) loest die Sperre "Richtung 1" aus.
#         Fund mit Pfad, Art "Richtung 1" und der ersten Meldezeile des Gates.
#   KD-2  Richtung 2: eine Datei unter prototype/ loest die Sperre "Richtung 2" aus. Fund wie KD-1, Art "Richtung 2".
#   KD-3  Auswahl: geprueft wird, was git ls-files unter den vier Wurzeln nennt, auch unversionierte, nicht ignorierte Dateien;
#         ignorierte Dateien, Dateien ausserhalb der vier Wurzeln und Prosa nach den Ausnahmen des Gates sind nicht Gegenstand
#         (GD-6, GD-5, GD-2). Namen mit Leerzeichen, Zeilenumbruch und Umlauten werden richtig gelesen (NUL-getrennt, Steuerzeichen
#         in der Ausgabe als Folge geschrieben); eine globale Ausschlussliste des Aufrufers aendert die Auswahl nicht; ein Lesefehler
#         an der Liste wirkt nicht wie ihr Ende (die gelesenen Eintraege werden gegen die von grep -z gezaehlten gehalten, sonst Lage C,
#         Kennung liste).
#   KD-4  Kontrollprobe: ein Gate, das immer 0 liefert, das nur eine Richtung sperrt, das die Richtungen vertauscht, das etwas
#         Unbeteiligtes sperrt oder bei einem Durchlauf Text ausgibt, besteht die Kontrollprobe nicht; Lage C, Kennung kontrollprobe.
#   KD-5  Fund gegen Pruefmittel: jede Antwort des Gates ausser Sperre mit Marke und Rueckgabewert 0 ohne Ausgabe ist Lage C mit
#         Dateiname (Kennung gate-antwort), nie ein Fund und nie "kein Fund"; ein Fund und eine solche Antwort stehen in derselben
#         Ausgabe, Lage C geht vor (Rueckgabewert 3).
#   KD-6  Umfeld: ein Werkzeug der geschlossenen Liste fehlt, ein Argument, kein Git-Arbeitsbaum um die Wurzel (auch: die Wurzel ist
#         nicht die oberste Ebene), das Gate fehlt, ist nicht lesbar oder eine Verknuepfung, die Ablage ist nicht herstellbar oder
#         liegt im Arbeitsbaum, git ls-files scheitert, eine Datei ist nicht lesbar, das Ereignis fuer das Gate ist nicht herstellbar
#         (jq endet ungleich 0; Kennung ereignis). Das Umfeld des Aufrufers (git-Variablen,
#         CLAUDE_PROJECT_DIR, BASH_ENV, TMPDIR, globale git-Konfiguration, Arbeitsverzeichnis, CDPATH) aendert das Urteil des Gates
#         und von git nicht ("env -i"; CDPATH loescht das Skript vor dem ersten cd, sonst lenkte es bei relativem Aufruf, wie make ihn
#         macht, "cd scripts/.." um und schriebe den Zielpfad auf die Standardausgabe); die eigene Shell des Skripts liest BASH_ENV
#         und exportierte Funktionen vor seiner ersten Zeile (GP-D6).
#   KD-7  Nicht-Text: eine Verknuepfung oder ein Untermodul (auch ein verschachteltes Repository) unter einer Wurzel ist ein Fund
#         (Art "Verknuepfung" beziehungsweise "Untermodul"); eine leere und eine binaere Datei gehen nicht an das Gate und werden
#         gezaehlt und genannt; eine Nicht-Datei wird einzeln mit Pfad genannt und nie geoeffnet (ein Fifo wuerde den Lauf haengen).
#   KD-8  Schreibfrei: das Skript schreibt nichts in den Arbeitsbaum (Kettengrundsatz, ADR 0002, Abschnitt 6); alle Dateien liegen
#         in der Ablage, und die Ablage ist nach dem Lauf entfernt.
#   KD-9  Rueckgabewerte, Ausgabe, Vorrang: 0 kein Fund, 2 mindestens ein Fund, 3 Lage C; Lage C geht einem Fund vor; die Ausgabe
#         traegt keine Zeit und keine Zufallswerte; "Befunde: n" zaehlt die Fundzeilen; das Gesamtbudget ist wirksam.
#
# SCHNITTSTELLE ZUM MELDETEXT DES GATES (hier vermerkt, nicht am Gate; das Gate bleibt unberuehrt)
#   Der Meldetext des Gates ist die Schnittstelle zu D10: eine Zeile, die mit "BLOCKIERT (Projektauftrag 5.6): Richtung 1" oder
#   "BLOCKIERT (Projektauftrag 5.6): Richtung 2" beginnt. Aendert er sich, wird jede Sperre Lage C und die Kontrollprobe faellt: rot
#   und nie gruen. Gemessen am echten Gate (Einheit G3.3, 2026-10-29, env -i wie oben, je Ereignis mehrere Laeufe):
#     backend/kontrollprobe.js mit einem Import aus ../prototype/helper: Rueckgabewert 2, vier Zeilen auf stderr, die erste
#       "BLOCKIERT (Projektauftrag 5.6): Richtung 1 (Produktionscode -> Prototyp): 'backend/kontrollprobe.js' ist Produktionscode
#       und importiert aus 'prototype/'."; stdout leer
#     dasselbe Ereignis mit "const x = 1;": Rueckgabewert 0, stdout und stderr leer
#     prototype/kontrollprobe.js mit einem Import aus ../backend/helper: Rueckgabewert 2, drei Zeilen auf stderr, die erste
#       "BLOCKIERT (Projektauftrag 5.6): Richtung 2 (Prototyp -> Produktionscode): 'prototype/kontrollprobe.js' liegt im Prototyp
#       und importiert aus dem Produktionscode."; stdout leer
#     dasselbe Ereignis mit "const x = 1;": Rueckgabewert 0, stdout und stderr leer
#   Je Aufruf des Gates 0,033 s bis 0,052 s. Das Ereignis ist auf die Felder beschraenkt, die das Gate liest (tool_name,
#   tool_input.file_path, tool_input.content); der Harness sendet weitere Felder (Schnittstelle zum Harness, GP-4 des Gates).
#
# GRENZEN (benannt, nicht geschlossen; je Grenze GD ein Fall im Pruefmittel, der sie als Durchlass misst; GP-4 und GP-7 ohne Fall)
#   GD-1  Bezuege ohne Importwort (COPY prototype/ in einem Dockerfile, Volumes in Compose, Abhaengigkeiten mit file:) erkennt das
#         Gate nicht. Das ist der Fall hinter der Objektbedingung aus ADR 0002, 6.2.2. Die Frage kommt in der Festlegung fuer G2
#         vor dem Bau von deploy/ zur Wiedervorlage: Fortschreibung von ADR 0004 am Gate oder eigene Regel in D10.
#   GD-2  Prosa: Dateien, die das Gate selbst ausnimmt (docs/, .claude/, *.md, *.txt, *.adoc, *.rst), sind unter den Wurzeln kein Fund.
#         Das gilt auch fuer einen Namen, der auf eine solche Endung und danach auf einen oder mehrere Zeilenumbrueche endet (das Gate
#         kuerzt abschliessende Zeilenumbrueche des Pfads).
#   GD-3  Verknuepfungen ausserhalb der vier Wurzeln, ueber die ein Importpfad fuehrt, sind nicht Gegenstand.
#   GD-4  Binaere und leere Dateien gehen nicht an das Gate; ein Muster darin bleibt unbemerkt (UTF-16 gilt als binaer). Binaer heisst:
#         grep -I sieht ein NUL-Byte im ersten Lesepuffer (gemessen 96 KiB) oder vor dem Ende der ersten Zeile; ein NUL-Byte erst danach
#         geht als Text an das Gate und endet dort in Fund oder Lage C, solange bash die Befehlsersetzung mit NUL-Byte meldet (gemessen
#         mit bash 5.2; die Meldung stammt von bash, nicht vom Gate).
#   GD-5  Pfade ausserhalb der vier Wurzeln (scripts/, .github/, Makefile, Wurzeldateien) sind nicht Gegenstand.
#   GD-6  Ignorierte Dateien (.gitignore, .git/info/exclude, core.excludesFile in .git/config) sind nicht Gegenstand; die globale
#         und die Systemkonfiguration von git gelten nicht.
#   GP-1, GP-2, GP-4, GP-5, GP-6, GP-7  D10 erbt die Grenzen des Gates (ADR 0004, Teil A; GP-3 ist seit dem 2026-10-22 als KP-7
#         gedeckt): GP-1 gemeinsame Abhaengigkeiten und ihre Aufloesung (Alias, baseUrl, Workspace), GP-2 Pfadschreibweise der
#         Richtung 2 praefixgebunden, GP-4 Werkzeugname ungleich Bash, GP-5 keine Aufloesung symbolischer Verknuepfungen (D10 meldet
#         eine Verknuepfung unter einer Wurzel selbst als Fund), GP-6 Python-Formen in Richtung 2 nur fuer backend, frontend,
#         deploy, GP-7 Prozesse ausserhalb der Gruppe. GP-4 und GP-7 sind ueber D10 nicht beobachtbar (das Skript sendet stets
#         Write und liest die Kanaele des Gates ueber Dateien).
#
# PREIS IN SICHERER RICHTUNG (keine Grenze, kein Durchlass)
#   Eine Textdatei, die das Gate nicht in 12 s prueft, meldet das Gate selbst (Rueckgabewert 2 ohne Marke): Lage C mit Dateiname.
#   Die Zeitgrenze je Aufruf (20 s) und das Gesamtbudget (120 s) sind am Aufruf gemessen, nicht an der CPU.
#
# RUECKGABEWERTE
#   0  kein Fund (die Kontrollprobe hat 4 von 4 bestanden, jede Textdatei hat das Gate ohne Sperre und ohne Ausgabe passiert)
#   2  mindestens ein Fund (Richtung 1, Richtung 2, Verknuepfung, Untermodul), keine Lage C
#   3  Lage C (siehe oben); ein Fund daneben bleibt in der Ausgabe stehen; das Makefile stellt 3 als Lage C mit
#      FEHLT=prototyp-trennung-pruefmittel weiter, jeden anderen Wert ungleich 0 als A_FAIL
#
# AUSGABE (Standardausgabe, ohne Zeiten)
#   "Kontrollprobe: n von 4"; "Geprueft: n Textdateien (prototype a, backend b, frontend c, deploy d); ungeprueft: x leer, y binaer,
#   z Nicht-Dateien"; je leere, binaere und Nicht-Datei eine Zeile "Leer:", "Binaer:" beziehungsweise "Nicht-Datei:" mit Pfad;
#   "=== Funde" mit je einer Zeile "Pfad TAB Art TAB Text" (Art: Richtung 1, Richtung 2, Verknuepfung, Untermodul; Text: erste
#   Meldezeile des Gates); "---"; ein Hinweis auf die Grenzen; "Befunde: n". Fehlerausgabe: Lage C ("LAGE C -- <Kennung>: ...").
#   Bei einer Lage C vor dem Urteil (Schritte 1 bis 7) fehlen "Geprueft:", "=== Funde" und "Befunde:".
#
# WERKZEUGE (geschlossene Liste, gleich den aufgerufenen Befehlen; alles Uebrige sind Builtins der Shell)
#   bash, git, jq, grep, timeout, mktemp, mkdir, env, rm, cat, sed, tr, cut, wc. Das Skript ruft selbst bash, git, jq, grep,
#   timeout, mktemp, mkdir, env und rm auf; cat, sed, tr, cut und wc braucht das Gate. Fehlt eines, ist das Lage C mit Namen, nie stilles
#   Durchlassen. Jeder Teilschritt mit Rueckgabewert wird geprueft; ein Fehler ist nie "kein Fund".
#
# PFLEGE
#   Die Liste der vier Wurzeln ist geschlossen (Dreiersatz-Muster von D9): eine weitere Bauwurzel verlangt eine Fortschreibung dieses
#   Kopfkommentars, Faelle und eine Mutation im Pruefmittel. Aendert sich der Meldetext des Gates, ist das eine Fortschreibung
#   dieser Schnittstelle (siehe oben). Eine neue Klasse oder Grenze in diesem Kommentar verlangt Faelle (und fuer eine Klasse KD
#   eine Mutation) im Pruefmittel scripts/prototyp-trennung-pruefen-selbsttest.sh.

set -uo pipefail

# KD-6: Sortierung, Zeichenklassen und Wortgrenzen haengen sonst von der Spracheinstellung des Aufrufers ab.
export LC_ALL=C
SECONDS=0

PROG="prototyp-trennung-pruefen.sh"
TAB=$'\t'
GATE_REL=".claude/hooks/block-prototype-import.sh"
BAUWURZELN=(prototype backend frontend deploy)
BUDGET_S=120
AUFRUF_S=20
MARKE_R1='BLOCKIERT (Projektauftrag 5.6): Richtung 1'
MARKE_R2='BLOCKIERT (Projektauftrag 5.6): Richtung 2'
WERKZEUGE="bash git jq grep timeout mktemp mkdir env rm cat sed tr cut wc"

ABLAGE=""
aufraeumen() { # KD-8: die Ablage wird in jedem Ausgang entfernt
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

# Schritt 1: Aufruf und Werkzeuge
if [ "$#" -ne 0 ]; then
  lage_c "aufruf" "kein Argument erwartet, erhalten: $# Argument(e)." "bash scripts/prototyp-trennung-pruefen.sh"
fi
for w in $WERKZEUGE; do
  command -v "$w" >/dev/null 2>&1 || lage_c "werkzeug:$w" "Werkzeug '$w' fehlt im Suchpfad." "Werkzeug installieren"
done
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
# KD-6: ein CDPATH des Aufrufers lenkt "cd scripts/.." bei relativem Aufruf um und schreibt den Zielpfad auf die Standardausgabe
unset CDPATH

# Die Wurzel ist das Verzeichnis ueber dem scripts/ dieses Skripts, nicht das Arbeitsverzeichnis des Aufrufers
QUELLE="${BASH_SOURCE[0]}"
case "$QUELLE" in */*) QUELLVERZ="${QUELLE%/*}" ;; *) QUELLVERZ="." ;; esac
WURZEL="$(cd "$QUELLVERZ/.." 2>/dev/null && pwd -P)" || WURZEL=""
[ -n "$WURZEL" ] || lage_c "git-arbeitsbaum" "das Verzeichnis ueber dem Skript ist nicht erreichbar ($QUELLVERZ/..)."

# Schritt 3: Ablage ausserhalb des Arbeitsbaums (KD-8)
ABLAGE="$(mktemp -d)" || ABLAGE=""
if [ -z "$ABLAGE" ] || [ ! -d "$ABLAGE" ]; then
  ABLAGE=""
  lage_c "ablage" "mktemp -d schlug fehl; die Ablage fuer Ereignisse und Antworten des Gates ist nicht herstellbar." "das temporaere Verzeichnis (TMPDIR) auf Platz und Rechte pruefen"
fi
ABLAGE="$(cd "$ABLAGE" 2>/dev/null && pwd -P)" || lage_c "ablage" "die Ablage ist nicht erreichbar."
case "$ABLAGE/" in
  "$WURZEL"/*) lage_c "ablage" "die Ablage liegt im Arbeitsbaum ($WURZEL); das Skript schreibt nichts in den Arbeitsbaum (Kettengrundsatz)." "TMPDIR ausserhalb des Arbeitsbaums waehlen" ;;
esac
mkdir "$ABLAGE/home" "$ABLAGE/tmp" || lage_c "ablage" "Unterverzeichnisse der Ablage nicht anlegbar."

git_neutral() { # git unter "env -i": keine globale und keine Systemkonfiguration, kein HOME des Aufrufers
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

# Schritt 5: Gate
if [ ! -e "$GATE_REL" ] && [ ! -L "$GATE_REL" ]; then
  lage_c "gate" "das Gate $GATE_REL fehlt; ohne es gibt es keine Erkennungsgrammatik, die D10 aufrufen koennte."
fi
if weg_verknuepft "$GATE_REL"; then lage_c "gate-verknuepfung" "auf dem Weg zu $GATE_REL liegt eine symbolische Verknuepfung; das Skript ruft kein Gate ueber eine Verknuepfung auf."; fi
[ -f "$GATE_REL" ] || lage_c "gate" "$GATE_REL ist keine regulaere Datei."
[ -r "$GATE_REL" ] || lage_c "gate" "$GATE_REL ist nicht lesbar."
GATE="$WURZEL/$GATE_REL"

# Kurzform fuer Meldungen: erste Zeile einer Datei, auf 200 Zeichen gekuerzt
kopfzeile() { # kopfzeile <datei>
  local z=""
  IFS= read -r z < "$1" 2>/dev/null || true
  printf '%s' "${z:0:200}"
}
# Anzeigeform eines Textes: Steuerzeichen (Zeilenumbruch, Tabulator und andere) werden als Folge geschrieben, damit jede Zeile
# der Ausgabe eine Zeile bleibt und die Felder einer Fundzeile nicht zerfallen (KD-3)
anz() { # anz <text> : setzt ANZ
  ANZ="$1"
  case "$ANZ" in *[[:cntrl:]]*) printf -v ANZ '%q' "$ANZ" ;; esac
}

ereignis_bauen() { # ereignis_bauen <relativer pfad> <inhaltsdatei> <zieldatei> : nur die Felder, die das Gate liest
  jq -n --arg p "$WURZEL/$1" --rawfile c "$2" '{tool_name:"Write",tool_input:{file_path:$p,content:$c}}' > "$3" 2> "$ABLAGE/jq.err"
}
gate_aufrufen() { # gate_aufrufen <ereignisdatei> : setzt G_RC; Ausgaben in $ABLAGE/g.aus und $ABLAGE/g.err
  env -i "PATH=$PATH" "HOME=$ABLAGE/home" "TMPDIR=$ABLAGE/tmp" "CLAUDE_PROJECT_DIR=$WURZEL" "LC_ALL=C" \
    timeout -k 1 "$AUFRUF_S" "$BASH_BIN" "$GATE" < "$1" > "$ABLAGE/g.aus" 2> "$ABLAGE/g.err"
  G_RC=$?
}
gate_einordnen() { # gate_einordnen : liest G_RC und die Ausgaben; setzt G_KLASSE (frei, fund1, fund2, andere) und G_ZEILE
  local zeile
  G_KLASSE=andere; G_ZEILE=""
  if [ "$G_RC" = 0 ]; then
    if [ ! -s "$ABLAGE/g.err" ] && [ ! -s "$ABLAGE/g.aus" ]; then G_KLASSE=frei; return; fi
    G_ZEILE="Rueckgabewert 0, aber das Gate hat Text ausgegeben: '$(kopfzeile "$ABLAGE/g.err")$(kopfzeile "$ABLAGE/g.aus")'"
    return
  fi
  if [ "$G_RC" = 2 ]; then
    while IFS= read -r zeile || [ -n "$zeile" ]; do
      case "$zeile" in
        "$MARKE_R1"*) G_KLASSE=fund1; G_ZEILE="$zeile"; return ;;
        "$MARKE_R2"*) G_KLASSE=fund2; G_ZEILE="$zeile"; return ;;
      esac
    done < "$ABLAGE/g.err"
  fi
  G_ZEILE="Rueckgabewert $G_RC ohne Sperrmeldung der Richtung 1 oder 2, Fehlerausgabe: '$(kopfzeile "$ABLAGE/g.err")'"
}

# Schritt 6: Kontrollprobe (KD-4) gegen das Gate, das urteilen wird: je Richtung ein Ereignis, das sperren muss, und eines, das
# durchlaufen muss. Die Pfade muessen nicht bestehen (das Gate loest nichts auf, GP-5).
PROBE_OK=0
PROBE_FEHLER=()
probe() { # probe <nr> <relativer pfad> <inhalt> <soll: fund1|fund2|frei> <beschreibung>
  local nr="$1" rel="$2" inhalt="$3" soll="$4" beschr="$5" ev="$ABLAGE/probe$1.json"
  if ! jq -n --arg p "$WURZEL/$rel" --arg c "$inhalt" '{tool_name:"Write",tool_input:{file_path:$p,content:$c}}' > "$ev" 2> "$ABLAGE/jq.err"; then
    PROBE_FEHLER+=("Ereignis $nr ($beschr): jq endet ungleich 0 ($(kopfzeile "$ABLAGE/jq.err"))")
    return
  fi
  gate_aufrufen "$ev"
  gate_einordnen
  if [ "$G_KLASSE" = "$soll" ]; then
    PROBE_OK=$((PROBE_OK + 1))
  else
    PROBE_FEHLER+=("Ereignis $nr ($beschr): erwartet $soll, gelesen $G_KLASSE: $G_ZEILE")
  fi
}
probe 1 "backend/kontrollprobe.js" $'import h from "../prototype/helper";\n' fund1 "Richtung 1 mit Import aus prototype/, muss sperren"
probe 2 "backend/kontrollprobe.js" $'const x = 1;\n' frei "Richtung 1 ohne Import, muss durchlaufen"
probe 3 "prototype/kontrollprobe.js" $'import h from "../backend/helper";\n' fund2 "Richtung 2 mit Import aus backend/, muss sperren"
probe 4 "prototype/kontrollprobe.js" $'const x = 1;\n' frei "Richtung 2 ohne Import, muss durchlaufen"
echo "Kontrollprobe: $PROBE_OK von 4"
if [ "$PROBE_OK" -ne 4 ]; then
  DETAIL=""
  for m in "${PROBE_FEHLER[@]+"${PROBE_FEHLER[@]}"}"; do DETAIL="$DETAIL [$m]"; done
  lage_c "kontrollprobe" "die Kontrollprobe des Gates ist nicht bestanden ($PROBE_OK von 4):$DETAIL" "Gate und Meldetext pruefen (Schnittstelle: Kopfkommentar dieses Skripts); ein Gate, das nicht sperrt oder dessen Meldetext sich geaendert hat, macht jede Sperre zu Lage C"
fi

# Schritt 7: Auswahl (KD-3)
git_neutral ls-files -z --cached --others --exclude-standard -- "${BAUWURZELN[@]}" > "$ABLAGE/liste" 2> "$ABLAGE/liste.err"
LISTE_RC=$?
if [ "$LISTE_RC" -ne 0 ]; then
  lage_c "git-liste" "git ls-files endet mit Rueckgabewert $LISTE_RC: $(kopfzeile "$ABLAGE/liste.err")"
fi

FUNDE=(); LEER=(); BINAER=(); NICHTDATEI=(); LAGEC=()
N_TEXT=0; N_P=0; N_B=0; N_F=0; N_D=0
N_GELESEN=0
BUDGET_UEBERSCHRITTEN=0

fund() { # fund <pfad> <art> <text>
  local p t
  anz "$1"; p="$ANZ"
  anz "$3"; t="$ANZ"
  FUNDE+=("$p${TAB}$2${TAB}$t")
}
lagec_datei() { # lagec_datei <pfad> <kennung> <text>
  local p
  anz "$1"; p="$ANZ"
  anz "$3"
  LAGEC+=("$2: $p: $ANZ")
}
zaehlen() { # zaehlen <pfad> : eine geprueft Textdatei, je Wurzel
  N_TEXT=$((N_TEXT + 1))
  case "${1%%/*}" in
    prototype) N_P=$((N_P + 1)) ;;
    backend) N_B=$((N_B + 1)) ;;
    frontend) N_F=$((N_F + 1)) ;;
    deploy) N_D=$((N_D + 1)) ;;
  esac
}

# Schritt 8 und 9: je Eintrag
while IFS= read -r -d '' f; do
  N_GELESEN=$((N_GELESEN + 1))
  if [ "$SECONDS" -ge "$BUDGET_S" ]; then BUDGET_UEBERSCHRITTEN=1; break; fi
  if [ -L "$f" ]; then
    fund "$f" "Verknuepfung" "symbolische Verknuepfung unter einer Bauwurzel; das Gate loest sie nicht auf (GP-5), ein Importpfad ueber sie bliebe ungeprueft."
    continue
  fi
  if [ -d "$f" ]; then
    fund "$f" "Untermodul" "Untermodul oder verschachteltes Repository unter einer Bauwurzel; sein Inhalt liegt ausserhalb dieses Baums und wird nicht geprueft."
    continue
  fi
  if [ ! -e "$f" ]; then anz "$f"; NICHTDATEI+=("$ANZ (fehlt auf der Platte, nur im Index)"); continue; fi
  if [ ! -f "$f" ]; then anz "$f"; NICHTDATEI+=("$ANZ (weder Datei noch Verknuepfung noch Verzeichnis)"); continue; fi
  if [ ! -r "$f" ]; then lagec_datei "$f" "datei" "nicht lesbar"; continue; fi
  if [ ! -s "$f" ]; then anz "$f"; LEER+=("$ANZ"); continue; fi
  grep -Iq '' -- "$f" 2> "$ABLAGE/grep.err"
  GREP_RC=$?
  if [ "$GREP_RC" -eq 1 ]; then anz "$f"; BINAER+=("$ANZ"); continue; fi
  if [ "$GREP_RC" -ne 0 ]; then lagec_datei "$f" "datei" "grep endet mit Rueckgabewert $GREP_RC: $(kopfzeile "$ABLAGE/grep.err")"; continue; fi
  if ! ereignis_bauen "$f" "$f" "$ABLAGE/ereignis.json"; then
    lagec_datei "$f" "ereignis" "das Ereignis ist nicht herstellbar (jq endet ungleich 0: $(kopfzeile "$ABLAGE/jq.err"))"
    continue
  fi
  gate_aufrufen "$ABLAGE/ereignis.json"
  gate_einordnen
  case "$G_KLASSE" in
    frei) zaehlen "$f" ;;
    fund1) zaehlen "$f"; fund "$f" "Richtung 1" "$G_ZEILE" ;;
    fund2) zaehlen "$f"; fund "$f" "Richtung 2" "$G_ZEILE" ;;
    *) lagec_datei "$f" "gate-antwort" "$G_ZEILE" ;;
  esac
done < "$ABLAGE/liste"
if [ "$BUDGET_UEBERSCHRITTEN" = 1 ]; then
  LAGEC+=("gesamtbudget: das Gesamtbudget von $BUDGET_S s ist ueberschritten; die uebrigen Dateien sind ungeprueft.")
fi

# Ein Lesefehler an der Liste darf nicht wie ihr Ende wirken: die Zahl der gelesenen Eintraege wird gegen die Zahl der NUL-terminierten
# Eintraege der Datei gehalten, die grep zaehlt (ein zweiter Lesepfad); ist das Budget ueberschritten, ist der Rest absichtlich ungelesen
LISTE_ZAHL="$(grep -zc '' "$ABLAGE/liste" 2> "$ABLAGE/grep.err")"
LISTE_ZAHL_RC=$?
if [ "$LISTE_ZAHL_RC" -gt 1 ]; then
  LAGEC+=("liste: die Eintraege der Liste sind nicht zaehlbar (grep endet mit Rueckgabewert $LISTE_ZAHL_RC: $(kopfzeile "$ABLAGE/grep.err")).")
elif [ "$BUDGET_UEBERSCHRITTEN" != 1 ] && [ "$LISTE_ZAHL" != "$N_GELESEN" ]; then
  LAGEC+=("liste: die Liste hat $LISTE_ZAHL Eintraege, gelesen wurden $N_GELESEN.")
fi

# Ausgabe (ohne Zeiten, KD-9)
printf 'Geprueft: %d Textdateien (prototype %d, backend %d, frontend %d, deploy %d); ungeprueft: %d leer, %d binaer, %d Nicht-Dateien\n' \
  "$N_TEXT" "$N_P" "$N_B" "$N_F" "$N_D" "${#LEER[@]}" "${#BINAER[@]}" "${#NICHTDATEI[@]}"
for e in "${LEER[@]+"${LEER[@]}"}"; do printf 'Leer: %s\n' "$e"; done
for e in "${BINAER[@]+"${BINAER[@]}"}"; do printf 'Binaer: %s\n' "$e"; done
for e in "${NICHTDATEI[@]+"${NICHTDATEI[@]}"}"; do printf 'Nicht-Datei: %s\n' "$e"; done
echo "=== Funde"
for e in "${FUNDE[@]+"${FUNDE[@]}"}"; do printf '%s\n' "$e"; done
echo "---"
echo "$PROG: geprueft wird, was das Gate an Importformen kennt; die benannten Grenzen GD-1 bis GD-6 und GP-1, GP-2, GP-4 bis GP-7 stehen im Kopfkommentar."
echo "Befunde: ${#FUNDE[@]}"

# Rueckgabewert: Lage C geht einem Fund vor (KD-9)
if [ "${#LAGEC[@]}" -gt 0 ]; then
  for e in "${LAGEC[@]}"; do echo "$PROG: LAGE C -- $e" >&2; done
  echo "$PROG: Der Gegenstand besteht fort, die Pruefung faellt fuer die genannten Dateien aus. Rueckgabewert 3 und nicht 2: ein ausgefallenes Pruefmittel ist kein Befund am Bestand; Funde stehen oben in derselben Ausgabe." >&2
  exit 3
fi
if [ "${#FUNDE[@]}" -gt 0 ]; then exit 2; fi
exit 0
