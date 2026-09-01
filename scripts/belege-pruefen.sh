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
# CODEBLÖCKE (```) WERDEN VOR JEDER PRÜFUNG AUSGEBLENDET
# Text innerhalb dreifach umschlossener Codeblöcke ist zitierter oder wörtlich
# wiedergegebener Inhalt (Befehlsausgaben, Verzeichnisbäume, ein historischer
# Schnappschuss einer alten CLAUDE.md in docs/09_Zustandsbericht_2026-08-21.md).
# Er wird als Beispiel oder Beleg gezeigt, nicht als eigenständige, aktuelle
# Behauptung des Dokuments — und würde sonst mit veralteten oder erfundenen
# Nummern (Abschnitt, Anforderung) den Lauf mit Fundstellen überschwemmen, die
# gar keine eigene Aussage des Dokuments sind. Zeilennummern bleiben dabei
# erhalten (die Zeile wird geleert, nicht entfernt), Befunde zeigen also immer
# auf die richtige Originalzeile.
#
# DIE FÜNF UMGESETZTEN PRÜFUNGEN (Reihenfolge nach Nutzen, siehe Übergabe)
#
# 1. Zeilenverweise. Ein Verweis der Form `datei:N` oder `datei:N-M`
#    (zwischen einzelnen Rückwärtsakzenten): Die Datei existiert und hat
#    mindestens N beziehungsweise M Zeilen. Erkennt nur Verweise, die
#    vollständig auf einer Zeile stehen und deren Pfadteil keine Leerzeichen
#    enthält. Ist die Datei selbst nicht vorhanden, meldet bereits Prüfung 4
#    (Pfadverweise) den Fund — Prüfung 1 meldet in diesem Fall nichts
#    Zusätzliches, weil "hinter dem Dateiende" für eine nicht vorhandene Datei
#    keine sinnvolle Aussage ist.
#
# 2. Commit-Prüfsummen. Jede Folge von genau 40 Kleinbuchstaben-Hexzeichen
#    (mit Wortgrenze) muss einen Commit bezeichnen, den dieses Repository
#    kennt (`git cat-file -e <wert>^{commit}`). Zusätzlich ist jedes
#    Vorkommen von `blob/main` oder `tree/main` immer ein Befund — auch dort,
#    wo eine Regel diese Form nur als verbotenes Beispiel nennt; das Skript
#    liest keinen Satzzusammenhang, nur das Zeichenmuster. Bekannte,
#    erwartete Fundstellen aus diesem Grund: Commit-Prüfsummen, die auf ein
#    ANDERES Repository verweisen (Repo B r3coscrum, oder ein gepinnter
#    Drittanbieter-Commit wie eine GitHub Action), kann dieses Skript nicht
#    von einer echten Fehlangabe unterscheiden — `git cat-file` sieht nur
#    Objekte, die dieses Repository selbst kennt. Das ist eine Grenze der
#    Prüfung, kein Freibrief für einen Autor, sie zu ignorieren.
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
#    mit "blob/" oder "tree/" beginnt (das übernimmt Prüfung 2). Enthält der
#    Kandidat ein "/", wird zusätzlich das erste Segment (vor dem ersten "/")
#    geprüft: "claude" ohne führenden Punkt (der echte Ordner heisst
#    ".claude") und "valITino" (der GitHub-Organisationsname beider
#    Projekt-Repositories) gelten als Branchname beziehungsweise
#    Repository-Verweis, nicht als Pfad in diesem Repository; ein erstes
#    Segment mit einem Punkt ausserhalb der ersten Stelle (z. B.
#    "github.com", "mb-api.abuse.ch") gilt als Rechnername, nicht als Pfad.
#    Ohne "/" wird nur geprüft, wenn der Kandidat exakt einem der
#    Wurzeldateinamen Makefile, CLAUDE.md, README.md, CONTRIBUTING.md,
#    .gitignore entspricht (schliesst blosse Wörter wie `make` aus). Ein
#    optionaler Zeilenanhang `:N` oder `:N-M` wird für die Existenzprüfung
#    abgetrennt und an Prüfung 1 übergeben. Geprüft wird Existenz als Datei
#    ODER Verzeichnis. Nicht erfasst: Pfade, die auf mehrere Zeilen verteilt
#    oder ohne Rückwärtsakzente genannt sind, sowie andere
#    Organisationsnamen oder Rechnernamen ohne Punkt im ersten Segment (z. B.
#    `Wh0am123/MCP-Kali-Server`, `origin/main`) — die sehen weiterhin wie ein
#    nicht vorhandener Pfad aus und werden gemeldet.
#
# 5. Abschnitte des Projektauftrags. Jede Angabe der Form `(N.M)`,
#    `Abschnitt N.M` oder `Projektauftrag N.M` muss eine Überschrift
#    (`^#+ N.M ...`) in docs/00_Projektauftrag.md bezeichnen. GRENZE, die
#    bewusst nicht vollständig aufgelöst ist: Die ADRs (docs/adr/0001-...,
#    docs/adr/0002-...) führen selbst eine eigene N.M-Gliederung (z. B. ADR
#    0002 Abschnitt 3.11). Eine blosse `(3.11)` oder `Abschnitt 3.11`
#    INNERHALB derselben ADR-Datei wird nicht geprüft, wenn diese Datei
#    selbst eine Überschrift mit dieser Nummer führt (Selbstverweis auf die
#    eigene Gliederung). Ein Selbstverweis auf eine ANDERE Datei (z. B. "ADR
#    0002, Abschnitt 3.5" in docs/06_..., oder "ADR 0001 (7.4)" in einer
#    Übergabedatei) wird NICHT erkannt und wie ein Projektauftrag-Verweis
#    geprüft — das erzeugt hier bekannte, nicht falsch gemeinte Fundstellen,
#    solange der Text nicht selbst "ADR" unmittelbar vor der Nummer nennt.
#    Nur die Form "Projektauftrag N.M" ist unzweideutig und wird immer
#    geprüft.
#
# NICHT UMGESETZT (Zeitbudget dieser Einheit, Weisung des Koordinators)
# Prüfung 6 (Skill-Zuordnung im Rollen-Frontmatter) und Prüfung 7
# (`metadata.anforderung` im Skill-Frontmatter) sind NICHT eingebaut. Das ist
# keine stillschweigende Lücke, sondern hier ausdrücklich vermerkt: Wer sich
# auf "belege-pruefen.sh ist grün" verlässt, deckt damit weder die
# `skills:`-Konsistenz noch die Anforderungskennung im Skill-Frontmatter ab.
#
# AUSNAHMELISTE (scripts/belege-ausnahmen.txt)
# Aufbau je Zeile: der Wert, ein Tabulator, der Grund. Leerzeilen und Zeilen
# mit # am Anfang werden übergangen. Ein Eintrag ohne Grund ist selbst ein
# Befund (Art "ausnahme-ohne-grund") — eine Ausnahme ohne Begründung ist eine
# Lücke mit Deckmantel. Ein Eintrag, dessen Gegenstand inzwischen existiert
# (Datei/Verzeichnis vorhanden, Kennung im Backlog, Commit bekannt), ist
# ebenfalls ein Befund (Art "ausnahme-veraltet") — sonst deckt eine
# überflüssig gewordene Ausnahme beim nächsten Mal etwas Echtes zu. Der
# Rückgleich ordnet jeden Ausnahmewert anhand seiner Form einer der
# prüfbaren Kategorien zu (Commit-Hash, Anforderungskennung, Pfad); eine
# Form, die zu keiner passt, wird nicht zurückgeglichen — eine benannte
# Lücke, keine falsche Entscheidung.
#
# RÜCKGABEWERT
# 0 — keine Beanstandung. 2 — mindestens ein Befund. Das Skript schreibt
# nichts: kein Schreibzugriff, keine Zwischendatei im Arbeitsbaum.
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

BEFUNDE_ANZAHL=0

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
declare -A AUSNAHME_GRUND
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
  # datei zeile pruefung wert
  local datei="$1" zeile="$2" pruefung="$3" wert="$4"
  if ist_ausgenommen "$wert"; then
    return 0
  fi
  printf '%s:%s\t%s\t%s\n' "$datei" "$zeile" "$pruefung" "$wert"
  BEFUNDE_ANZAHL=$((BEFUNDE_ANZAHL+1))
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

# --- Pfad-/Zeilen-Existenzprüfung (auch für den Ausnahme-Rückgleich genutzt) ---
# Gibt per Echo "OK" oder "FEHLT:<Grund-Kürzel>" zurück.
pfad_existiert() {
  local p="$1"
  p="${p#./}"
  p="${p%/}"
  [ -f "$REPO_ROOT/$p" ] || [ -d "$REPO_ROOT/$p" ]
}

ist_pfadartig() {
  local c="$1" erster
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
      # Ohne führenden Punkt geschriebenes "claude/..." ist in diesem Bestand
      # durchgehend ein Branchname (z. B. claude/next-step-g8slnq), nie ein
      # Pfad — der echte Konfigurationsordner heisst ".claude" mit Punkt.
      [ "$erster" = "claude" ] && return 1
      # "valITino" ist der GitHub-Organisationsname der beiden Projekt-Repos
      # (r3cosint, r3coscrum) und des fremden Skill-Repositories; ein Verweis
      # "valITino/<repo>" benennt ein GitHub-Repository, keinen Pfad in
      # diesem Repository.
      [ "$erster" = "valITino" ] && return 1
      # Ein Punkt im ersten Segment, der nicht an Position 1 steht (also
      # nicht der führende Punkt von z. B. ".claude"), deutet auf einen
      # Rechnernamen hin (github.com/..., mb-api.abuse.ch/...), keinen
      # Repository-Pfad.
      case "$erster" in
        ?*.*) return 1 ;;
      esac
      return 0
      ;;
    Makefile|CLAUDE.md|README.md|CONTRIBUTING.md|.gitignore) return 0 ;;
  esac
  return 1
}

for DATEI in "${DATEIEN[@]}"; do
  INHALT="$(blenden "$DATEI")"

  # --- Prüfung 4: Pfadverweise (mit optionalem Prüfung-1-Zeilenanhang) ---
  while IFS=: read -r ZL ROH; do
    [ -z "${ZL:-}" ] && continue
    KANDIDAT="${ROH#\`}"
    KANDIDAT="${KANDIDAT%\`}"
    # Zeilenanhang zuerst abtrennen, DANACH den Pfadteil auf Pfadartigkeit
    # prüfen — sonst fällt z. B. "CLAUDE.md:42" durch die Wurzeldatei-
    # Positivliste, weil dort "CLAUDE.md:42" und nicht "CLAUDE.md" steht.
    PFADTEIL="$KANDIDAT"
    ANHANG_N=""
    ANHANG_M=""
    if [[ "$KANDIDAT" =~ ^(.*):([0-9]+)(-([0-9]+))?$ ]]; then
      PFADTEIL="${BASH_REMATCH[1]}"
      ANHANG_N="${BASH_REMATCH[2]}"
      ANHANG_M="${BASH_REMATCH[4]}"
    fi
    if ist_pfadartig "$PFADTEIL"; then
      if pfad_existiert "$PFADTEIL"; then
        if [ -n "$ANHANG_N" ] && [ -f "$REPO_ROOT/${PFADTEIL#./}" ]; then
          ZEILEN_IST=$(wc -l < "$REPO_ROOT/${PFADTEIL#./}")
          GRENZE="$ANHANG_N"
          [ -n "$ANHANG_M" ] && GRENZE="$ANHANG_M"
          if [ "$GRENZE" -gt "$ZEILEN_IST" ]; then
            melden "$DATEI" "$ZL" "zeile" "$KANDIDAT"
          fi
        fi
      else
        melden "$DATEI" "$ZL" "pfad" "$PFADTEIL"
      fi
    fi
  done < <(printf '%s\n' "$INHALT" | grep -noE '`[^`]+`')

  # --- Prüfung 3: Anforderungskennungen ---
  while IFS=: read -r ZL WERT; do
    [ -z "${ZL:-}" ] && continue
    if ! ist_backlog_id "$WERT"; then
      melden "$DATEI" "$ZL" "anforderung" "$WERT"
    fi
  done < <(printf '%s\n' "$INHALT" | grep -noE 'R3-[A-Z]-[0-9]{3}')

  # --- Prüfung 2: Commit-Prüfsummen ---
  while IFS=: read -r ZL WERT; do
    [ -z "${ZL:-}" ] && continue
    if ! git cat-file -e "${WERT}^{commit}" 2>/dev/null; then
      melden "$DATEI" "$ZL" "commit" "$WERT"
    fi
  done < <(printf '%s\n' "$INHALT" | grep -noE '\b[0-9a-f]{40}\b')

  while IFS=: read -r ZL WERT; do
    [ -z "${ZL:-}" ] && continue
    melden "$DATEI" "$ZL" "blob-tree-verweis" "$WERT"
  done < <(printf '%s\n' "$INHALT" | grep -noE '(blob|tree)/main')

  # --- Prüfung 5: Abschnitte des Projektauftrags ---
  mapfile -t EIGENE_ABSCHNITTE < <(grep -oE '^#{1,6}[[:space:]]+[0-9]+\.[0-9]+' "$DATEI" | grep -oE '[0-9]+\.[0-9]+' | sort -u)
  ist_eigener_abschnitt() {
    local a="$1" k
    for k in "${EIGENE_ABSCHNITTE[@]}"; do [ "$k" = "$a" ] && return 0; done
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
        if ! ist_eigener_abschnitt "$N" && ! ist_pa_abschnitt "$N"; then
          melden "$DATEI" "$ZL" "abschnitt" "$N"
        fi
        ;;
    esac
  done < <(printf '%s\n' "$INHALT" | grep -noE '\([0-9]+\.[0-9]+\)|Abschnitt[[:space:]]+[0-9]+\.[0-9]+|Projektauftrag[[:space:]]+[0-9]+\.[0-9]+')

done

# --- Ausnahmeliste: zwei Pflichtprüfungen ---
wert_existiert_bereits() {
  local w="$1"
  if [[ "$w" =~ ^[0-9a-f]{40}$ ]]; then
    git cat-file -e "${w}^{commit}" 2>/dev/null && return 0 || return 1
  elif [[ "$w" =~ ^R3-[A-Z]-[0-9]{3}$ ]]; then
    ist_backlog_id "$w" && return 0 || return 1
  elif ist_pfadartig "$w" || [ -f "$REPO_ROOT/$w" ] || [ -d "$REPO_ROOT/$w" ]; then
    pfad_existiert "$w" && return 0 || return 1
  fi
  return 2  # nicht klassifizierbar -> kein Rückgleich
}

for eintrag in "${AUSNAHME_ZEILEN[@]+"${AUSNAHME_ZEILEN[@]}"}"; do
  IFS=$'\t' read -r ZN WERT GRUND <<<"$eintrag"
  if [ -z "$GRUND" ]; then
    printf '%s:%s\t%s\t%s\n' "$AUSNAHMEDATEI" "$ZN" "ausnahme-ohne-grund" "$WERT"
    BEFUNDE_ANZAHL=$((BEFUNDE_ANZAHL+1))
    continue
  fi
  set +e
  wert_existiert_bereits "$WERT"
  RC=$?
  set -e 2>/dev/null || true
  if [ "$RC" -eq 0 ]; then
    printf '%s:%s\t%s\t%s\n' "$AUSNAHMEDATEI" "$ZN" "ausnahme-veraltet" "$WERT"
    BEFUNDE_ANZAHL=$((BEFUNDE_ANZAHL+1))
  fi
done

echo "---"
echo "belege-pruefen.sh: geprüft sind Fundorte (Datei, Zeile, Abschnitt, Anforderung, Commit)."
echo "NICHT geprüft: ob der Inhalt an diesem Fundort die Behauptung trägt, die ihm zugeschrieben wird."
echo "NICHT eingebaut: Prüfung 6 (Skill-Zuordnung im Rollen-Frontmatter), Prüfung 7 (metadata.anforderung)."
echo "Befunde: $BEFUNDE_ANZAHL"

if [ "$BEFUNDE_ANZAHL" -gt 0 ]; then
  exit 2
fi
exit 0
