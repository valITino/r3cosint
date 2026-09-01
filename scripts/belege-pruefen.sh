#!/usr/bin/env bash
#
# belege-pruefen.sh — Herkunftsangaben gegen ihren Fundort prüfen
#
# Auftrag: docs/uebergaben/2026-08-31_skill-repository-ausgewertet.md,
# Abschnitt "Abbruch nach Eskalationsregel 3.4". Dreimal in Folge ist dieselbe
# Fehlerklasse aufgetreten: eine Aussage über die Herkunft war stärker, als
# die Quelle sie trägt (ein ADR-Zitat, das dort nicht steht; eine Zeilenangabe,
# an der heute etwas anderes steht; ein Beispiel ohne Beleg im Repository).
# Dieses Skript prüft maschinell, ob der genannte Fundort überhaupt existiert.
#
# NACHFÜHRUNG (Weisung des Koordinators, nach dem ersten Lauf mit 167 Funden):
# Ein Gate, das nichts mehr durchlässt, ist so kaputt wie eines, das alles
# durchlässt. Die grosse Mehrheit der 167 Funde war Rauschen (noch nicht
# gebaute Bäume, das andere Repository, Git-Referenzen, Erzeugnisverzeichnisse,
# ADR-interne Abschnittsnummern). Ziel ist NICHT null Funde, sondern dass jeder
# verbleibende Fund entweder ein echter Fehler ist oder eine Ausnahme mit
# geschriebenem Grund. Die Regeln unten setzen genau das um. Dabei ist ein
# echter Fehler im Skript selbst behoben worden: ein Pfadverweis gilt jetzt
# auch als erfüllt, wenn er relativ zum Verzeichnis der NENNENDEN Datei
# existiert (nicht nur relativ zur Repository-Wurzel) — sonst wäre z. B.
# `references/befundfelder.md` in .claude/skills/pruefbefund-melden/SKILL.md
# fälschlich als fehlend gemeldet worden.
#
# ZWECK UND GRENZE — WICHTIG
# Das Skript prüft, OB ein Fundort existiert (Datei, Zeile, Abschnitt,
# Anforderung, Commit). Es prüft NICHT, ob der Inhalt an diesem Fundort die
# Behauptung auch trägt, die ihm zugeschrieben wird. Ein grüner Lauf heisst
# "der Verweis zeigt auf etwas Vorhandenes", nicht "die Aussage stimmt". Das
# war der Auslöser der dritten gescheiterten Runde und wird hier nicht
# stillschweigend mitbehauptet.
#
# PRÜFFLÄCHE
# Alle mit Git versionierten Markdown-Dateien im Wurzelverzeichnis, unter
# docs/ und unter .claude/ (rekursiv). Kein prototype/, kein backend/, kein
# frontend/ — dort gilt die Kette selbst (make dod), nicht dieses Skript.
# Nur versionierte Dateien (git ls-files), damit ein nicht committetes
# Arbeitsdokument die Prüffläche nicht verfälscht.
#
# ZWEITER ARBEITSBAUM (Repo B, r3coscrum)
# Fest angenommen unter /home/user/r3coscrum. Existiert dort ein Git-
# Arbeitsbaum, wird er für zwei Zwecke mitgelesen (siehe Prüfungen 2 und 4):
# Commit-Prüfsummen von Repo B und Pfade unter methodik/, nachweise/,
# sprints/. Der Pfad ist fest verdrahtet, nicht konfigurierbar — auf einer
# anderen Maschine mit anderem Ablageort greift der Mitlese-Zweig nicht, das
# Skript fällt dann auf "nicht prüfbar" beziehungsweise die einfache
# Prüfung gegen dieses Repository zurück.
#
# CODEBLÖCKE (```) WERDEN VOR JEDER PRÜFUNG AUSGEBLENDET
# Text innerhalb dreifach umschlossener Codeblöcke ist zitierter oder wörtlich
# wiedergegebener Inhalt (Befehlsausgaben, Verzeichnisbäume, ein historischer
# Schnappschuss einer alten CLAUDE.md in docs/09_Zustandsbericht_2026-08-21.md).
# Er wird als Beispiel oder Beleg gezeigt, nicht als eigenständige, aktuelle
# Behauptung des Dokuments. Zeilennummern bleiben dabei erhalten (die Zeile
# wird geleert, nicht entfernt), Befunde zeigen also immer auf die richtige
# Originalzeile.
#
# DIE FÜNF UMGESETZTEN PRÜFUNGEN
#
# 1. Zeilenverweise. Ein Verweis der Form `datei:N` oder `datei:N-M`
#    (zwischen einzelnen Rückwärtsakzenten): Die Datei existiert (root- oder
#    verzeichnisrelativ, siehe Prüfung 4) und hat mindestens N beziehungsweise
#    M Zeilen. Erkennt nur Verweise, die vollständig auf einer Zeile stehen
#    und deren Pfadteil kein Leerzeichen enthält. Ist die Datei selbst nicht
#    auffindbar, meldet bereits Prüfung 4 den Fund.
#
# 2. Commit-Prüfsummen. Jede Folge von genau 40 Kleinbuchstaben-Hexzeichen
#    (mit Wortgrenze) muss einen Commit bezeichnen, den dieses Repository ODER
#    — falls vorhanden — der Arbeitsbaum von Repo B (/home/user/r3coscrum)
#    kennt (`git cat-file -e <wert>^{commit}` gegen beide, sofern der zweite
#    existiert). Zusätzlich ist jedes Vorkommen von `blob/main` oder
#    `tree/main` ein Befund — mit EINER Ausnahme: Stellen, an denen eine Regel
#    diese Form ausdrücklich als abschreckendes Beispiel zitiert, tragen einen
#    eigenen, mit Datei UND Zeile verankerten Ausnahmeeintrag (siehe unten,
#    Regel 7 der Nachführung) — nicht den blossen Wert, sonst deckte die
#    Ausnahme einen künftigen echten Verstoss in derselben Datei mit zu.
#    Bekannte Restfälle, die auch nach dem Zwei-Repo-Abgleich offenbleiben und
#    darum in der Ausnahmeliste stehen: Commit-Prüfsummen eines DRITTEN
#    Repositories (`valITino/claude-skills-fullstack`) und ein gepinnter
#    Drittanbieter-Commit (GitHub-Action-SHA) — beide liegen lokal nicht vor,
#    das kann kein lokaler Rückgleich auflösen.
#
# 3. Anforderungskennungen. Jede Kennung der Form R3-<Buchstabe>-<drei
#    Ziffern> muss als Überschrift (`^#+ R3-...`) in docs/05_Product_Backlog.md
#    stehen.
#
# 4. Pfadverweise. Jeder Inline-Code-Verweis (zwischen einzelnen
#    Rückwärtsakzenten) wird als Pfadverweis behandelt, wenn er: kein
#    Leerzeichen enthält (schliesst Shell-Befehle wie `bash scripts/x.sh`
#    aus — deren Pfadteil wird dadurch NICHT geprüft, eine bekannte Lücke);
#    kein "://" enthält (keine URL); nicht mit "/" beginnt (keine absoluten
#    Systempfade wie `/tmp`, keine Slash-Befehle wie `/usage`); nicht mit "~"
#    beginnt (kein Heimverzeichnis wie `~/.cache/uv`); keines der Zeichen
#    " ' $ = * < > { } enthält und nicht die Zeichenfolge "..." oder "…"
#    (schliesst Shell-Variablen, Zuweisungen und Platzhalter wie
#    `.claude/agents/<name>.md` aus — ausgenommen Platzhalter ohne diese
#    Zeichen, etwa "NNNN" in einem Dateinamen-Muster, werden NICHT erkannt
#    und fälschlich als Pfad geprüft); kein "@" enthält (keine
#    versionsgepinnten fremden Referenzen wie `actions/checkout@v4`); nicht
#    mit "blob/" oder "tree/" beginnt (das übernimmt Prüfung 2).
#
#    Enthält der Kandidat ein "/", wird zusätzlich das erste Segment (vor dem
#    ersten "/") geprüft:
#      - "claude", "origin", "fix" ohne führenden Punkt gelten als
#        Git-Referenz (Branch- beziehungsweise Fernname), nicht als Pfad.
#        Das ist eine kleine, aus dem tatsächlichen Bestand belegte Liste
#        (`claude/next-step-g8slnq`, `origin/main`, `fix/main-seite`), kein
#        allgemeines Git-Flow-Schema — ein künftiges "release/..." oder
#        "hotfix/..." würde NICHT erkannt.
#      - "valITino" (der GitHub-Organisationsname beider Projekt-Repos und
#        des fremden Skill-Repositories) gilt als Repository-Verweis, nicht
#        als Pfad.
#      - Ein Punkt im ersten Segment ausserhalb der ersten Stelle (z. B.
#        "github.com", "mb-api.abuse.ch") gilt als Rechnername. "." und ".."
#        sind davon ausdrücklich ausgenommen (gültige Pfadsegmente, z. B. in
#        `../SKILL.md`).
#      - Besteht der Kandidat aus GENAU zwei Segmenten (ein einziges "/") UND
#        gehört das erste Segment NICHT zum eigenen Baum (.claude, .github,
#        docs, scripts, prototype, backend, frontend, deploy) UND enthält das
#        zweite Segment KEINEN Punkt, gilt das als fremdes
#        "Inhaber/Repository"-Muster (`actions/checkout`,
#        `Wh0am123/MCP-Kali-Server`, `decompiler-explorer/decompiler-explorer`)
#        und wird nicht als Pfad geprüft. GRENZE: Das nimmt auch einen
#        echten, bisher nicht existierenden Zwei-Segment-Pfad ausserhalb des
#        eigenen Baums fälschlich aus der Prüfung — z. B. `tests/architektur`
#        ohne vorangestelltes `backend/` würde nicht erkannt.
#    Ohne "/" wird nur geprüft, wenn der Kandidat exakt einem der
#    Wurzeldateinamen Makefile, CLAUDE.md, README.md, CONTRIBUTING.md,
#    .gitignore entspricht.
#
#    Danach gelten, in dieser Reihenfolge, drei weitere Regeln, bevor ein
#    Fund gemeldet wird:
#      a) Erzeugnis- und Abhängigkeitsverzeichnisse als Pfadsegment
#         (node_modules, .venv, dist, build, __pycache__, .pytest_cache,
#         .mypy_cache) sind NIE ein Fund, unabhängig vom Rest des Pfads —
#         sie werden im Bestand als Beispiele genannt und sollen gerade
#         nicht im Repository liegen.
#      b) Beginnt der Pfad mit backend/, frontend/, deploy/ oder prototype/
#         und existiert dieses oberste Verzeichnis (noch) NICHT, ist das
#         KEIN Fund — das ist der architekturgemäss geplante Zustand vor dem
#         Grundgerüst. Die Regel schaltet sich von selbst scharf: Sobald das
#         Verzeichnis angelegt ist, werden Pfade darunter wieder normal
#         geprüft.
#      c) Beginnt der Pfad mit methodik/, nachweise/ oder sprints/, gehört
#         er zu Repo B (r3coscrum). Existiert der zweite Arbeitsbaum (siehe
#         oben), wird dort geprüft — fehlt oder findet sich der Pfad dort
#         nicht, ist das ein normaler Fund. Existiert der zweite Arbeitsbaum
#         NICHT, wird die Zeile als "nicht prüfbar" gezählt, NICHT als Fund
#         — sie fliesst nicht in den Rückgabewert ein, erscheint aber
#         gesondert in der Ausgabe.
#
#    Für die Existenzprüfung selbst gilt: ein Pfad ist erfüllt, wenn er ALS
#    DATEI ODER VERZEICHNIS existiert — root-relativ ODER relativ zum
#    Verzeichnis der Datei, die ihn nennt (siehe NACHFÜHRUNG oben). Ein
#    optionaler Zeilenanhang `:N` oder `:N-M` wird vorher abgetrennt und an
#    Prüfung 1 übergeben.
#
#    Nicht erfasst: Pfade, die auf mehrere Zeilen verteilt oder ohne
#    Rückwärtsakzente genannt sind.
#
# 5. Abschnitte des Projektauftrags. Jede Angabe der Form `Projektauftrag
#    N.M` muss eine Überschrift (`^#+ N.M ...`) in docs/00_Projektauftrag.md
#    bezeichnen und wird IMMER geprüft — die Form ist unzweideutig. Die
#    Formen `(N.M)` und `Abschnitt N.M` werden dagegen NUR geprüft, wenn im
#    selben ABSATZ nirgends das Wort "ADR" steht. "Absatz" heisst: der
#    zusammenhängende Text zwischen zwei Leerzeilen; eine Markdown-Tabelle
#    ohne Leerzeile zwischen den Zeilen zählt dabei als EIN Absatz, auch über
#    viele Tabellenzeilen hinweg. Begründung: Beide ADRs führen selbst eine
#    eigene N.M-Gliederung, ein Verweis wie "ADR 0002, Abschnitt 3.7" nennt
#    also die ADR-Gliederung, nicht den Projektauftrag — und "ADR 0002" steht
#    im Bestand oft mehrere Zeilen vor der eigentlichen Abschnittsangabe
#    (weicher Zeilenumbruch in Fliesstext, oder eine lange Tabellenzeile, die
#    "ADR" gar nicht wiederholt, weil die Zugehörigkeit zur ADR-Tabelle schon
#    aus der Zeile selbst hervorgeht). Eine reine Zeilenregel liess in einer
#    ersten Fassung genau diese Fälle durch; die Absatzregel schliesst sie.
#    GRENZE, bewusst in Kauf genommen: Eine ganze mehrzeilige Tabelle ohne
#    Leerzeilen gilt als ein Absatz — nennt IRGENDEINE Zeile dieser Tabelle
#    "ADR", wird auch ein echter Projektauftrag-Verweis in einer ANDEREN
#    Zeile derselben Tabelle nicht mehr geprüft. Das ist eine benannte,
#    in Kauf genommene Lücke, keine falsche Meldung.
#
#    ZUSÄTZLICH, über die Absatzregel hinaus: Für die Formen `(N.M)` und
#    `Abschnitt N.M` wird auch nicht geprüft, wenn die NENNENDE DATEI selbst
#    eine Überschrift mit dieser Nummer führt (aktuell nur die beiden ADRs).
#    Grund: In ADR 0002 nennt die Definition-of-Done-Tabelle eigene Abschnitte
#    ("Abschnitt 3.5 verlangt diesen Schritt …"), ohne das Wort "ADR" im
#    ganzen Tabellen-Absatz zu wiederholen — die Absatzregel allein liess
#    diesen konkreten Fall beim ersten Testlauf noch durch.
# NICHT UMGESETZT (Zeitbudget dieser Einheit)
# Prüfung 6 (Skill-Zuordnung im Rollen-Frontmatter) und Prüfung 7
# (`metadata.anforderung` im Skill-Frontmatter) sind NICHT eingebaut. Das ist
# keine stillschweigende Lücke, sondern hier ausdrücklich vermerkt: Wer sich
# auf "belege-pruefen.sh ist grün" verlässt, deckt damit weder die
# `skills:`-Konsistenz noch die Anforderungskennung im Skill-Frontmatter ab.
#
# AUSNAHMELISTE (scripts/belege-ausnahmen.txt)
# Aufbau je Zeile: der Wert, ein Tabulator, der Grund. Leerzeilen und Zeilen
# mit # am Anfang werden übergangen. Ein Eintrag ohne Grund ist selbst ein
# Befund (Art "ausnahme-ohne-grund"). Ein Eintrag, dessen Gegenstand
# inzwischen existiert, ist ebenfalls ein Befund (Art "ausnahme-veraltet").
# Der Rückgleich ordnet jeden Ausnahmewert anhand seiner Form einer der
# prüfbaren Kategorien zu (Commit-Hash, Anforderungskennung, Pfad); eine
# Form, die zu keiner passt — insbesondere die Datei:Zeile-Schlüssel aus
# Regel 7 unten — wird nicht zurückgeglichen, das ist eine benannte Lücke.
#
# Normalerweise ist der "Wert" einer Ausnahme der geprüfte Wert selbst (ein
# Pfad, eine Kennung, ein Commit-Hash). EINE Ausnahme davon: Ausnahmen für
# `blob/main`/`tree/main`-Funde (Prüfungsart "blob-tree-verweis") tragen als
# Wert stattdessen "Datei:Zeile", nicht den blossen Text "blob/main" — sonst
# deckte eine einzelne Ausnahmezeile jedes künftige Vorkommen im ganzen
# Bestand ab, auch einen echten Verstoss in dann dieser oder anderen Dateien.
#
# RÜCKGABEWERT
# 0 — keine Beanstandung. 2 — mindestens ein Befund. "Nicht prüfbar"-Zeilen
# zählen nicht als Befund. Das Skript schreibt nichts: kein Schreibzugriff,
# keine Zwischendatei im Arbeitsbaum.
#
# WERKZEUGE
# Nur git, grep, sed, awk und Standard-Shell (bash). Kein Python.

set -uo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || {
  echo "belege-pruefen.sh: kein Git-Repository am aktuellen Arbeitsverzeichnis gefunden." >&2
  exit 2
}
cd "$REPO_ROOT" || exit 2

BACKLOG="docs/05_Product_Backlog.md"
PROJEKTAUFTRAG="docs/00_Projektauftrag.md"
AUSNAHMEDATEI="scripts/belege-ausnahmen.txt"

# Zweiter Arbeitsbaum (Repo B), fest verdrahteter Ort, siehe Kopfkommentar.
R3COSCRUM_ROOT=""
if [ -d "/home/user/r3coscrum" ]; then
  KANDIDAT_ROOT="$(git -C /home/user/r3coscrum rev-parse --show-toplevel 2>/dev/null || true)"
  [ -n "$KANDIDAT_ROOT" ] && R3COSCRUM_ROOT="$KANDIDAT_ROOT"
fi

BEFUNDE_ANZAHL=0
NICHT_PRUEFBAR_ANZAHL=0
declare -A ART_ANZAHL=()
declare -A NICHT_PRUEFBAR_ART_ANZAHL=()
FINDINGS_LISTE=()
NICHT_PRUEFBAR_LISTE=()

# --- Prüffläche: versionierte Markdown-Dateien, Wurzel + docs/ + .claude/ ---
mapfile -t DATEIEN < <(git ls-files -- '*.md' | grep -E '^([^/]+\.md|docs/.*\.md|\.claude/.*\.md)$')

# --- Codeblöcke ausblenden, Zeilennummern erhalten ---
blenden() {
  awk '
    /^```/ { infence = !infence; print ""; next }
    infence { print ""; next }
    { print }
  ' "$1"
}

# --- Ausnahmeliste laden ---
declare -A AUSNAHME_GRUND=()
AUSNAHME_ZEILEN=()
if [ -f "$AUSNAHMEDATEI" ]; then
  zn=0
  while IFS=$'\t' read -r wert grund || [ -n "${wert:-}" ]; do
    zn=$((zn+1))
    [ -z "${wert:-}" ] && continue
    case "$wert" in \#*) continue ;; esac
    AUSNAHME_GRUND["$wert"]="${grund:-}"
    AUSNAHME_ZEILEN+=("$zn"$'\t'"$wert"$'\t'"${grund:-}")
  done < "$AUSNAHMEDATEI"
fi

ist_ausgenommen() {
  local wert="$1"
  [ -n "${AUSNAHME_GRUND[$wert]+x}" ]
}

melden() {
  # datei zeile pruefung wert [ausnahme-schluessel]
  local datei="$1" zeile="$2" pruefung="$3" wert="$4" schluessel="${5:-$4}"
  if ist_ausgenommen "$schluessel"; then
    return 0
  fi
  FINDINGS_LISTE+=("$datei:$zeile"$'\t'"$pruefung"$'\t'"$wert")
  ART_ANZAHL["$pruefung"]=$(( ${ART_ANZAHL["$pruefung"]:-0} + 1 ))
  BEFUNDE_ANZAHL=$((BEFUNDE_ANZAHL+1))
}

nicht_pruefbar() {
  local datei="$1" zeile="$2" pruefung="$3" wert="$4"
  NICHT_PRUEFBAR_LISTE+=("$datei:$zeile"$'\t'"$pruefung"$'\t'"$wert")
  NICHT_PRUEFBAR_ART_ANZAHL["$pruefung"]=$(( ${NICHT_PRUEFBAR_ART_ANZAHL["$pruefung"]:-0} + 1 ))
  NICHT_PRUEFBAR_ANZAHL=$((NICHT_PRUEFBAR_ANZAHL+1))
}

# --- Referenzmengen ---
mapfile -t BACKLOG_IDS < <(grep -oE '^#{1,6}[[:space:]]+R3-[A-Z]-[0-9]{3}' "$BACKLOG" | grep -oE 'R3-[A-Z]-[0-9]{3}' | sort -u)
ist_backlog_id() {
  local id="$1" k
  for k in "${BACKLOG_IDS[@]}"; do [ "$k" = "$id" ] && return 0; done
  return 1
}

mapfile -t PA_ABSCHNITTE < <(grep -oE '^#{1,6}[[:space:]]+[0-9]+\.[0-9]+' "$PROJEKTAUFTRAG" | grep -oE '[0-9]+\.[0-9]+' | sort -u)
ist_pa_abschnitt() {
  local a="$1" k
  for k in "${PA_ABSCHNITTE[@]}"; do [ "$k" = "$a" ] && return 0; done
  return 1
}

# --- Existenzprüfung, root-relativ ---
pfad_existiert_wurzel() {
  local p="$1"
  p="${p#./}"
  p="${p%/}"
  [ -f "$REPO_ROOT/$p" ] || [ -d "$REPO_ROOT/$p" ]
}

# --- Existenzprüfung, root- ODER verzeichnisrelativ zur nennenden Datei ---
# Gibt bei Erfolg den root-relativen Pfad aus, der tatsächlich existiert.
pfad_aufloesen() {
  local p="$1" bezugdir="$2" kandidat
  p="${p#./}"
  p="${p%/}"
  if [ -f "$REPO_ROOT/$p" ] || [ -d "$REPO_ROOT/$p" ]; then
    printf '%s\n' "$p"
    return 0
  fi
  if [ -n "$bezugdir" ] && [ "$bezugdir" != "." ]; then
    kandidat="$bezugdir/$p"
    if [ -f "$REPO_ROOT/$kandidat" ] || [ -d "$REPO_ROOT/$kandidat" ]; then
      printf '%s\n' "$kandidat"
      return 0
    fi
  fi
  return 1
}

ist_pfadartig() {
  local c="$1" erster rest
  case "$c" in
    *' '*) return 1 ;;
    *'://'*) return 1 ;;
    /*) return 1 ;;
    '~'*) return 1 ;;
    *'"'*|*"'"*|*'$'*|*'='*) return 1 ;;
    *'*'*|*'<'*|*'>'*|*'{'*|*'}'*|*'...'*|*'…'*) return 1 ;;
    *'@'*) return 1 ;;
    blob/*|tree/*) return 1 ;;
  esac
  case "$c" in
    */*)
      erster="${c%%/*}"
      case "$erster" in
        claude|origin|fix) return 1 ;;
      esac
      [ "$erster" = "valITino" ] && return 1
      case "$erster" in
        .|..) : ;;
        ?*.*) return 1 ;;
      esac
      rest="${c#*/}"
      case "$rest" in
        */*) : ;;
        *)
          case "$erster" in
            .claude|.github|docs|scripts|prototype|backend|frontend|deploy) : ;;
            *)
              case "$rest" in
                *.*) : ;;
                *) return 1 ;;
              esac
              ;;
          esac
          ;;
      esac
      return 0
      ;;
    Makefile|CLAUDE.md|README.md|CONTRIBUTING.md|.gitignore) return 0 ;;
  esac
  return 1
}

ist_erzeugnisverzeichnis() {
  local p="$1" seg
  local IFS='/'
  local -a segs
  read -ra segs <<< "$p"
  for seg in "${segs[@]}"; do
    case "$seg" in
      node_modules|.venv|dist|build|__pycache__|.pytest_cache|.mypy_cache) return 0 ;;
    esac
  done
  return 1
}

git_hat_commit() {
  local wert="$1"
  git cat-file -e "${wert}^{commit}" 2>/dev/null && return 0
  if [ -n "$R3COSCRUM_ROOT" ]; then
    git -C "$R3COSCRUM_ROOT" cat-file -e "${wert}^{commit}" 2>/dev/null && return 0
  fi
  return 1
}

for DATEI in "${DATEIEN[@]}"; do
  INHALT="$(blenden "$DATEI")"
  BEZUGDIR="$(dirname "$DATEI")"

  # --- Prüfung 4: Pfadverweise (mit optionalem Prüfung-1-Zeilenanhang) ---
  while IFS=: read -r ZL ROH; do
    [ -z "${ZL:-}" ] && continue
    KANDIDAT="${ROH#\`}"
    KANDIDAT="${KANDIDAT%\`}"
    PFADTEIL="$KANDIDAT"
    ANHANG_N=""
    ANHANG_M=""
    if [[ "$KANDIDAT" =~ ^(.*):([0-9]+)(-([0-9]+))?$ ]]; then
      PFADTEIL="${BASH_REMATCH[1]}"
      ANHANG_N="${BASH_REMATCH[2]}"
      ANHANG_M="${BASH_REMATCH[4]}"
    fi

    ist_pfadartig "$PFADTEIL" || continue
    ist_erzeugnisverzeichnis "$PFADTEIL" && continue

    ERSTES_SEGMENT="${PFADTEIL%%/*}"

    # Regel b) Noch nicht gebaute Bäume — kein Fund, solange sie fehlen.
    case "$ERSTES_SEGMENT" in
      backend|frontend|deploy|prototype)
        [ ! -d "$REPO_ROOT/$ERSTES_SEGMENT" ] && continue
        ;;
    esac

    # Regel c) Pfade des Methodik-Repositories (Repo B).
    case "$ERSTES_SEGMENT" in
      methodik|nachweise|sprints)
        P="${PFADTEIL#./}"
        P="${P%/}"
        if [ -n "$R3COSCRUM_ROOT" ]; then
          if [ -f "$R3COSCRUM_ROOT/$P" ] || [ -d "$R3COSCRUM_ROOT/$P" ]; then
            :
          else
            melden "$DATEI" "$ZL" "pfad" "$PFADTEIL"
          fi
        else
          nicht_pruefbar "$DATEI" "$ZL" "pfad" "$PFADTEIL"
        fi
        continue
        ;;
    esac

    # Regel d) Pfade mit vorangestelltem Repository-Namen. Die Uebergaben
    # schreiben mehrfach "r3coscrum/CLAUDE.md" oder "r3cosint/.gitignore", um
    # zu sagen, in WELCHEM der beiden Repositories die Datei liegt. Der Name
    # ist dann Teil der Aussage, nicht des Pfades; er wird abgetrennt und der
    # Rest im genannten Arbeitsbaum geprueft. Fehlt der zweite Arbeitsbaum,
    # ist der Fall nicht pruefbar -- wie unter c).
    case "$ERSTES_SEGMENT" in
      r3cosint|r3coscrum)
        P="${PFADTEIL#*/}"
        P="${P%/}"
        if [ "$ERSTES_SEGMENT" = "r3cosint" ]; then
          WURZEL="$REPO_ROOT"
        else
          WURZEL="$R3COSCRUM_ROOT"
        fi
        if [ -z "$WURZEL" ]; then
          nicht_pruefbar "$DATEI" "$ZL" "pfad" "$PFADTEIL"
        elif [ -f "$WURZEL/$P" ] || [ -d "$WURZEL/$P" ]; then
          :
        else
          melden "$DATEI" "$ZL" "pfad" "$PFADTEIL"
        fi
        continue
        ;;
    esac

    if AUFGELOEST=$(pfad_aufloesen "$PFADTEIL" "$BEZUGDIR"); then
      if [ -n "$ANHANG_N" ] && [ -f "$REPO_ROOT/$AUFGELOEST" ]; then
        ZEILEN_IST=$(wc -l < "$REPO_ROOT/$AUFGELOEST")
        GRENZE="$ANHANG_N"
        [ -n "$ANHANG_M" ] && GRENZE="$ANHANG_M"
        if [ "$GRENZE" -gt "$ZEILEN_IST" ]; then
          melden "$DATEI" "$ZL" "zeile" "$KANDIDAT"
        fi
      fi
    else
      melden "$DATEI" "$ZL" "pfad" "$PFADTEIL"
    fi
  done < <(printf '%s\n' "$INHALT" | grep -noE '`[^`]+`')

  # --- Prüfung 3: Anforderungskennungen ---
  while IFS=: read -r ZL WERT; do
    [ -z "${ZL:-}" ] && continue
    if ! ist_backlog_id "$WERT"; then
      melden "$DATEI" "$ZL" "anforderung" "$WERT"
    fi
  done < <(printf '%s\n' "$INHALT" | grep -noE 'R3-[A-Z]-[0-9]{3}')

  # --- Prüfung 2: Commit-Prüfsummen (gegen dieses Repository UND Repo B) ---
  while IFS=: read -r ZL WERT; do
    [ -z "${ZL:-}" ] && continue
    if ! git_hat_commit "$WERT"; then
      melden "$DATEI" "$ZL" "commit" "$WERT"
    fi
  done < <(printf '%s\n' "$INHALT" | grep -noE '\b[0-9a-f]{40}\b')

  while IFS=: read -r ZL WERT; do
    [ -z "${ZL:-}" ] && continue
    melden "$DATEI" "$ZL" "blob-tree-verweis" "$WERT" "$DATEI:$ZL"
  done < <(printf '%s\n' "$INHALT" | grep -noE '(blob|tree)/main')

  # --- Prüfung 5: Abschnitte des Projektauftrags ---
  # Absatzweise vorberechnen, ob irgendwo im selben Absatz (Text zwischen
  # zwei Leerzeilen; eine Tabelle ohne Leerzeile zwischen den Zeilen zählt
  # als ein Absatz) das Wort "ADR" steht — nicht nur in derselben Zeile,
  # weil weiche Zeilenumbrüche und Tabellenzeilen "ADR 0002" oft einige
  # Zeilen vor der eigentlichen Abschnittsangabe nennen.
  mapfile -t ADR_ABSATZ < <(printf '%s\n' "$INHALT" | awk '
    {
      if ($0 ~ /^[[:space:]]*$/) { para++; next }
      linepara[NR] = para
      paratext[para] = paratext[para] " " $0
    }
    END {
      for (l = 1; l <= NR; l++) {
        p = (l in linepara) ? linepara[l] : 0
        print (paratext[p] ~ /(^|[^A-Za-z])ADR([^A-Za-z]|$)/) ? 1 : 0
      }
    }
  ')

  # Zusätzlich: eigene Gliederung der nennenden Datei selbst (nur die ADRs
  # führen aktuell eine eigene N.M-Gliederung). Deckt die Fälle ab, in denen
  # eine Zeile INNERHALB der ADR auf einen eigenen Abschnitt verweist, ohne
  # "ADR" zu nennen — z. B. eine Tabellenzeile der Definition-of-Done-Kette
  # in ADR 0002 selbst ("Abschnitt 3.5 verlangt diesen Schritt …"), wo das
  # ganze Wort "ADR" nirgends im Absatz fällt, weil die Zugehörigkeit zum
  # Dokument selbstverständlich ist. Das ist eine Ergänzung zur vorgegebenen
  # Absatzregel, keine Ersetzung: Ein erster Lauf nur mit der Absatzregel
  # meldete diese Fälle noch als Fund (siehe Übergabe an den Koordinator).
  mapfile -t EIGENE_ABSCHNITTE < <(grep -oE '^#{1,6}[[:space:]]+[0-9]+\.[0-9]+' "$DATEI" | grep -oE '[0-9]+\.[0-9]+' | sort -u)
  ist_eigener_abschnitt() {
    local a="$1" k
    for k in "${EIGENE_ABSCHNITTE[@]+"${EIGENE_ABSCHNITTE[@]}"}"; do [ "$k" = "$a" ] && return 0; done
    return 1
  }

  while IFS=: read -r ZL TREFFER; do
    [ -z "${ZL:-}" ] && continue
    N=$(printf '%s' "$TREFFER" | grep -oE '[0-9]+\.[0-9]+')
    case "$TREFFER" in
      Projektauftrag*)
        if ! ist_pa_abschnitt "$N"; then
          melden "$DATEI" "$ZL" "abschnitt" "$N"
        fi
        ;;
      *)
        if [ "${ADR_ABSATZ[$((ZL-1))]:-0}" != "1" ] && ! ist_eigener_abschnitt "$N"; then
          if ! ist_pa_abschnitt "$N"; then
            melden "$DATEI" "$ZL" "abschnitt" "$N"
          fi
        fi
        ;;
    esac
  done < <(printf '%s\n' "$INHALT" | grep -noE '\([0-9]+\.[0-9]+\)|Abschnitt[[:space:]]+[0-9]+\.[0-9]+|Projektauftrag[[:space:]]+[0-9]+\.[0-9]+')

done

# --- Ausnahmeliste: zwei Pflichtprüfungen ---
wert_existiert_bereits() {
  local w="$1"
  if [[ "$w" =~ ^[0-9a-f]{40}$ ]]; then
    git_hat_commit "$w" && return 0 || return 1
  elif [[ "$w" =~ ^R3-[A-Z]-[0-9]{3}$ ]]; then
    ist_backlog_id "$w" && return 0 || return 1
  elif [[ "$w" == *:*  ]]; then
    return 2  # Datei:Zeile-Schlüssel (Regel 7) -> nicht klassifizierbar
  elif ist_pfadartig "$w" || [ -f "$REPO_ROOT/$w" ] || [ -d "$REPO_ROOT/$w" ]; then
    pfad_existiert_wurzel "$w" && return 0 || return 1
  fi
  return 2  # nicht klassifizierbar -> kein Rückgleich
}

for eintrag in "${AUSNAHME_ZEILEN[@]+"${AUSNAHME_ZEILEN[@]}"}"; do
  IFS=$'\t' read -r ZN WERT GRUND <<<"$eintrag"
  if [ -z "$GRUND" ]; then
    FINDINGS_LISTE+=("$AUSNAHMEDATEI:$ZN"$'\t'"ausnahme-ohne-grund"$'\t'"$WERT")
    ART_ANZAHL["ausnahme-ohne-grund"]=$(( ${ART_ANZAHL["ausnahme-ohne-grund"]:-0} + 1 ))
    BEFUNDE_ANZAHL=$((BEFUNDE_ANZAHL+1))
    continue
  fi
  set +e
  wert_existiert_bereits "$WERT"
  RC=$?
  set -e 2>/dev/null || true
  if [ "$RC" -eq 0 ]; then
    FINDINGS_LISTE+=("$AUSNAHMEDATEI:$ZN"$'\t'"ausnahme-veraltet"$'\t'"$WERT")
    ART_ANZAHL["ausnahme-veraltet"]=$(( ${ART_ANZAHL["ausnahme-veraltet"]:-0} + 1 ))
    BEFUNDE_ANZAHL=$((BEFUNDE_ANZAHL+1))
  fi
done

echo "=== Funde nach Prüfungsart ==="
if [ "${#ART_ANZAHL[@]}" -gt 0 ]; then
  for art in "${!ART_ANZAHL[@]}"; do
    printf '%s\t%d\n' "$art" "${ART_ANZAHL[$art]}"
  done | sort
else
  echo "(keine)"
fi

echo "=== Funde vollständig ==="
for zeile in "${FINDINGS_LISTE[@]+"${FINDINGS_LISTE[@]}"}"; do
  printf '%s\n' "$zeile"
done

echo "=== Nicht prüfbar (kein Fund, zählt nicht zum Rückgabewert) ==="
if [ "${#NICHT_PRUEFBAR_ART_ANZAHL[@]}" -gt 0 ]; then
  for art in "${!NICHT_PRUEFBAR_ART_ANZAHL[@]}"; do
    printf '%s\t%d\n' "$art" "${NICHT_PRUEFBAR_ART_ANZAHL[$art]}"
  done | sort
fi
for zeile in "${NICHT_PRUEFBAR_LISTE[@]+"${NICHT_PRUEFBAR_LISTE[@]}"}"; do
  printf '%s\n' "$zeile"
done

echo "---"
echo "belege-pruefen.sh: geprüft sind Fundorte (Datei, Zeile, Abschnitt, Anforderung, Commit)."
echo "NICHT geprüft: ob der Inhalt an diesem Fundort die Behauptung trägt, die ihm zugeschrieben wird."
echo "NICHT eingebaut: Prüfung 6 (Skill-Zuordnung im Rollen-Frontmatter), Prüfung 7 (metadata.anforderung)."
echo "Repo B (r3coscrum) mitgelesen: $([ -n "$R3COSCRUM_ROOT" ] && echo ja || echo nein)"
echo "Befunde: $BEFUNDE_ANZAHL"
echo "Nicht prüfbar: $NICHT_PRUEFBAR_ANZAHL"

if [ "$BEFUNDE_ANZAHL" -gt 0 ]; then
  exit 2
fi
exit 0
