#!/usr/bin/env bash
# =============================================================================
# dod-gate.sh — Definition-of-Done-Gate fuer Stop, SubagentStop, TaskCompleted
# =============================================================================
#
# Bau auf Weisung vom 2026-09-02, foermliche Freigabe ausstehend (ADR 0002,
# Abschnitt 10). Grundlage: docs/adr/0002-architekturentscheid-ziel-stack.md,
# Abschnitt 6.12 (zwoelfte Fortschreibung). Backlog: R3-Q-001.
#
# ZWECK: Erzwingt vor jedem Beendigungs- und jedem Abschlussversuch, dass die
# Definition-of-Done-Kette ("make dod") im geprueften Arbeitsbaum nachweisbar
# gelaufen ist und nichts gefunden hat -- mit Ausnahme terminierter Lagen C
# (6.12.5). Rueckgabewert 2 blockiert, Rueckgabewert 0 laesst durch
# (Projektauftrag 3.4; Rueckgabewert 1 blockiert NICHT und wird hier deshalb
# nie verwendet).
#
# REICHWEITE: Ein Skript fuer alle drei Ereignisse, verzweigt ueber
# hook_event_name. Kein Matcher (ADR 0002, 6.12.2). Die harte Zusicherung
# "die Aufgabe ist nicht abschliessbar" traegt ausschliesslich TaskCompleted;
# Stop und SubagentStop leisten je Beendigungsversuch eine erzwungene
# Fortsetzung mit Begruendung, nicht mehr (6.12.2, 6.12.18).
#
# WAS ES NICHT DECKT (6.12.18, 6.12.22, dieselbe Grenze wie bei den beiden
# PreToolUse-Gates dieses Projekts):
#   - Gegen einen Aufrufer, der die Umgebung beherrscht (BASH_ENV, ein
#     gefaelschtes "make"/"timeout"/"flock" frueher im PATH, ein veraendertes
#     Makefile), ist dieses Gate wirkungslos. Es setzt Disziplin durch, es
#     ersetzt keinen Lauf auf der Gegenseite (O-12).
#   - TaskCompleted feuert nur, wenn in der Sitzung ueberhaupt eine
#     Aufgabenliste gefuehrt wird (6.12.2, 6.12.18 Punkt 5). In einer Sitzung
#     ohne Aufgabenliste leisten Stop und SubagentStop nur die erzwungene
#     Fortsetzung, keine harte Sperre.
#   - Das Gate stuetzt sich auf die ganze Kette und damit auch auf D20
#     (scripts/belege-pruefen.sh), das nach Eskalationsregel 3.4 abgebrochen
#     und NICHT abgenommen ist (O-15). Ein Durchlass sagt nichts, was D20
#     selbst nicht traegt.
#   - Ueber Sitzungsgrenzen hinweg zaehlt dieses Gate nicht (6.12.9). Die
#     Eskalation nach drei Malen greift innerhalb einer Sitzung/eines
#     Subagenten; darueber hinaus traegt die Uebergabedatei, kein Zaehler.
#   - Ein Rolle mit "Bash", aber ohne "Edit"/"Write"/"NotebookEdit" KOENNTE
#     ueber die Shell schreiben, DARF es nach ADR 0001 aber nicht. Dieses Gate
#     misst das Recht, nicht die Faehigkeit (6.12.14) -- die harte
#     Durchsetzung der Schreibgrenzen ist R3-Q-005 und bleibt es.
#
# SELBSTTEST: scripts/dod-gate-selbsttest.sh (Formprüfungen gegen eine
# Attrappe von "make dod", dazu ein roter und ein gruener Lauf gegen das
# ECHTE Makefile). Ein ungetestetes Gate ist kein Gate
# (.claude/rules/claude-konfiguration.md, Abschnitt "Hooks").
#
# PRUEFMITTEL DIESES GATES (ADR 0002, 6.12.11), je mit eigenem Ausgang:
#   jq, git, GNU Make + das Makefile im bestimmten Baum,
#   .claude/hooks/dod-gate-terminierte-lagen.txt im bestimmten Baum (NUR fuer
#   deren FEHLEN, 6.12.23 b), timeout, flock -- fehlt eines, Rueckgabewert 2
#   mit Meldung und Beschaffungsweg. Das Zustandsverzeichnis (nur Zaehlwerk)
#   hat KEINEN eigenen Ausgang: das Gate urteilt unveraendert und sagt im
#   Blockfall, dass es nicht zaehlen kann.
#
# NACHTRAG 6.12.23 (Bau vom 2026-09-02, drei vom DevOps Engineer gemeldete
# Luecken im Entwurf, dort entschieden):
#   a) VIER Schlusszeilen statt drei (6.12.8/6.12.23 a): die vierte gilt fuer
#      einen vollstaendig gelaufenen Lauf ohne A_FAIL und ohne Lage C, dessen
#      Rahmenpruefung D19 dennoch VERLETZT oder Lage C meldet. Parse-Regel:
#      Rueckgabewert 0 nur zusammen mit Form 1 -- ein Verstoss blockiert unter
#      dem Schluessel `KETTE schlusszeile-widerspruch`.
#   b) Verstoesse gegen die Selbstpruefungen 2, 3, 4, 5, 6 der terminierten
#      Lagen zaehlen unter einem eigenen Schluesselraum `LISTE <Nummer>
#      <D> <ziel>` (2, 3, 5) beziehungsweise `LISTE <Nummer> <Zeilennummer>`
#      (4, 6); Selbstpruefung 1 bleibt `<D> <ziel> C <fehlendes Pruefmittel>`.
#      `GATE dod-gate-terminierte-lagen.txt` bezeichnet seither AUSSCHLIESSLICH
#      das Fehlen der Datei selbst.
#      Zaehlreihenfolge bei mehreren gleichzeitigen Abweichungen: GATE ... vor
#      LISTE ... (bei mehreren fehlerhaften Zeilen die erste in
#      Dateireihenfolge) vor der ersten Kettenabweichung vor D19 ....
#   c) Fehlt `jq`, blockiert das Gate weiterhin mit `GATE jq`, zaehlt diesen
#      Block aber NICHT: `session_id`/`agent_id` stehen im JSON, das ohne
#      `jq` nicht lesbar ist. Eine benannte, nicht behebbare Grenze (6.12.9).
#
# KEIN NETZZUGRIFF, KEIN SCHREIBEN IN DEN ARBEITSBAUM. Dieses Skript schreibt
# ausschliesslich die Zaehler- und die Sperrdatei im Zustandsverzeichnis
# (${XDG_STATE_HOME:-$HOME/.local/state}/r3cosint/dod-gate/) sowie eine
# Wegwerfdatei fuer die Kettenausgabe ausserhalb des Arbeitsbaums (5.4,
# CLAUDE.md, "Kein Rueckkanal").
#
# ZEITGRENZEN (G11, 6.12.12): 600 s innen (timeout -k 10), 120 s Wartezeit auf
# die Sperre, 900 s aussen in .claude/settings.json -- die innere Grenze ist
# die kleinere, damit ein zeitlich abgelaufener Hook nicht lautlos durchlaesst
# (die gelesene Referenz: ein Hook, der seine eigene Zeitgrenze reisst, wird
# abgebrochen und laesst durch, ohne Ausgabe).
#
# AUSGABEFORM (6.12.15): bei sauberem Gruen keine Ausgabe. Bei jedem anderen
# Durchlass genau ein JSON-Objekt {"systemMessage": "..."} auf der eigenen
# Standardausgabe. Beim Blockieren steht der Grund auf der Fehlerausgabe,
# die Standardausgabe bleibt leer. Kein "continue: false", kein eigenes
# Protokoll. Die Ausgabe der Kette gelangt NIE auf die eigene Standardausgabe
# dieses Skripts (6.12.15) -- Ausgangspunkt jeder Verletzung dieser Regel ist
# eine falsch geschriebene Weiterleitung, deshalb ist jede Stelle, die
# "$ausgabe_datei" liest, unten einzeln kommentiert.
# =============================================================================

set -uo pipefail

# -----------------------------------------------------------------------------
# 0. jq -- ohne dieses Werkzeug ist die Eingabe nicht lesbar. Fail-closed,
#    OHNE Zaehlung (die Zaehlung selbst braucht session_id aus dem JSON, das
#    ohne jq nicht gelesen werden kann -- eine unausweichliche Grenze, siehe
#    Kopfkommentar "PRUEFMITTEL").
# -----------------------------------------------------------------------------
if ! command -v jq >/dev/null 2>&1; then
  echo "dod-gate: GATE jq -- 'jq' ist nicht installiert; die Eingabe auf der Standardeingabe kann nicht gelesen werden." >&2
  echo "Beschaffen: z. B. 'apt-get install -y jq' oder https://jqlang.org/download/." >&2
  echo "dod-gate: naechster Schritt: jq installieren, dann erneut versuchen." >&2
  exit 2
fi

eingabe=$(cat)

if ! printf '%s' "$eingabe" | jq -e . >/dev/null 2>&1; then
  echo "dod-gate: die Eingabe auf der Standardeingabe ist kein gueltiges JSON. Fail-closed." >&2
  exit 2
fi

ereignis=$(printf '%s' "$eingabe" | jq -r '.hook_event_name // empty')
case "$ereignis" in
  Stop|SubagentStop|TaskCompleted) ;;
  *)
    echo "dod-gate: unbekanntes oder von diesem Gate nicht bedientes Ereignis '$ereignis'. Fail-closed (keine Fortsetzung ohne Pruefung)." >&2
    exit 2
    ;;
esac

session_id=$(printf '%s' "$eingabe" | jq -r '.session_id // empty')
agent_id=$(printf '%s' "$eingabe" | jq -r '.agent_id // empty')
cwd_feld=$(printf '%s' "$eingabe" | jq -r '.cwd // empty')
proj_feld="${CLAUDE_PROJECT_DIR:-}"

# -----------------------------------------------------------------------------
# 1. git -- fuer die Bestimmung des geprueften Baums (G12) und fuer die
#    Eskalationspruefung (G8). Bestmoegliche Baumangabe schon jetzt fuer die
#    Meldung, ohne git selbst zu benutzen.
# -----------------------------------------------------------------------------
baum_hinweis="${proj_feld:-${cwd_feld:-"(nicht bestimmbar)"}}"
if ! command -v git >/dev/null 2>&1; then
  echo "dod-gate: GATE git -- 'git' ist nicht installiert. Baum (unbestaetigt): $baum_hinweis." >&2
  echo "Beschaffen: git ueber den Paketmanager der Distribution installieren." >&2
  echo "dod-gate: naechster Schritt: git installieren, dann erneut versuchen." >&2
  exit 2
fi

# -----------------------------------------------------------------------------
# G12 (ADR 0002, 6.12.13): der gepruefte Baum ist DIE WURZEL des Arbeitsbaums,
# in dem "cwd" liegt (physisch aufgeloest), SOFERN "git rev-parse
# --git-common-dir" dort dasselbe Git-Verzeichnis liefert wie fuer
# CLAUDE_PROJECT_DIR; sonst gilt die Wurzel des Arbeitsbaums von
# CLAUDE_PROJECT_DIR, und ist CLAUDE_PROJECT_DIR selbst kein Arbeitsbaum, der
# physisch aufgeloeste Pfad von CLAUDE_PROJECT_DIR. Liegt cwd ausserhalb jedes
# Arbeitsbaums dieses Repositories, wird das NICHT gesondert gemeldet -- der
# Rueckfall auf CLAUDE_PROJECT_DIR deckt genau diesen Fall ab, "lieber kein
# Urteil als ein Urteil ueber das falsche Verzeichnis" gilt hier durch den
# Rueckfall selbst.
#
# B-02/B-03: eine rohe Uebernahme von cwd/CLAUDE_PROJECT_DIR (ohne Aufloesung)
# verglich den geprueften Baum zeichengenau mit der ersten Zeile der Kette
# (die "make" ueber "pwd -P" ausgibt) -- ein Schraegstrich am Ende oder ein
# Symlink im Pfad ergab dort faelschlich "KETTE baum-widerspruch", cwd in
# einem Unterverzeichnis ergab faelschlich "GATE Makefile". "git rev-parse
# --show-toplevel" loest Symlinks auf, endet nie auf "/" und bildet aus einem
# Unterverzeichnis dieselbe Wurzel -- empirisch belegt (Uebergabe dieser
# Arbeitseinheit).
# -----------------------------------------------------------------------------
cwd_git=""
[ -n "$cwd_feld" ] && [ -d "$cwd_feld" ] && cwd_git=$(git -C "$cwd_feld" rev-parse --git-common-dir 2>/dev/null || true)
proj_git=""
[ -n "$proj_feld" ] && [ -d "$proj_feld" ] && proj_git=$(git -C "$proj_feld" rev-parse --git-common-dir 2>/dev/null || true)

selber_baum=0
if [ -n "$proj_git" ] && [ -n "$cwd_git" ]; then
  proj_git_abs=$( (cd "$proj_feld" 2>/dev/null && cd "$proj_git" 2>/dev/null && pwd -P) || true)
  cwd_git_abs=$( (cd "$cwd_feld" 2>/dev/null && cd "$cwd_git" 2>/dev/null && pwd -P) || true)
  if [ -n "$proj_git_abs" ] && [ "$proj_git_abs" = "$cwd_git_abs" ]; then
    selber_baum=1
  fi
fi

baum=""
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
if [ -z "$baum" ]; then
  echo "dod-gate: weder CLAUDE_PROJECT_DIR noch das Eingabefeld 'cwd' ergeben einen bestimmbaren Arbeitsbaum. Fail-closed." >&2
  exit 2
fi

# -----------------------------------------------------------------------------
# 2. GNU Make + das Makefile im bestimmten Baum (EIN Pruefmittel, G10).
# -----------------------------------------------------------------------------
if ! command -v make >/dev/null 2>&1; then
  echo "dod-gate: GATE make -- GNU Make ist nicht installiert. Baum: $baum." >&2
  echo "Beschaffen: z. B. 'apt-get install -y make'." >&2
  echo "dod-gate: naechster Schritt: make installieren, dann erneut versuchen." >&2
  exit 2
fi
makefile_pfad="$baum/Makefile"
if [ ! -f "$makefile_pfad" ]; then
  echo "dod-gate: GATE Makefile -- $makefile_pfad fehlt. Baum: $baum." >&2
  echo "Der eine Einstieg der Definition-of-Done-Kette (ADR 0002, Abschnitt 6) besteht in diesem Baum nicht." >&2
  echo "dod-gate: naechster Schritt: im richtigen Baum arbeiten oder das Makefile wiederherstellen." >&2
  exit 2
fi

# -----------------------------------------------------------------------------
# 3. Die Liste der terminierten Lagen C -- fehlend blockiert, vorhanden und
#    LEER ist zulaessig (dieselbe Unterscheidung wie bei
#    scripts/belege-ausnahmen.txt, ADR 0002, 6.11.2 und 6.12.11).
# -----------------------------------------------------------------------------
terminiert_pfad="$baum/.claude/hooks/dod-gate-terminierte-lagen.txt"
if [ ! -f "$terminiert_pfad" ]; then
  echo "dod-gate: GATE dod-gate-terminierte-lagen.txt -- $terminiert_pfad fehlt. Baum: $baum." >&2
  echo "Ohne die Liste faellt jede terminierte Lage C stumm weg; das Gate blockiert lieber, als stillschweigend zu decken (ADR 0002, 6.12.11)." >&2
  echo "dod-gate: naechster Schritt: die Datei anlegen (auch leer zulaessig) oder wiederherstellen." >&2
  exit 2
fi

# -----------------------------------------------------------------------------
# 4. timeout, flock -- fuer die beiden Zeitgrenzen und die Serialisierung.
# -----------------------------------------------------------------------------
if ! command -v timeout >/dev/null 2>&1; then
  echo "dod-gate: GATE timeout -- 'timeout' (coreutils) ist nicht installiert. Baum: $baum." >&2
  echo "dod-gate: naechster Schritt: coreutils installieren, dann erneut versuchen." >&2
  exit 2
fi
if ! command -v flock >/dev/null 2>&1; then
  echo "dod-gate: GATE flock -- 'flock' (util-linux) ist nicht installiert. Baum: $baum." >&2
  echo "dod-gate: naechster Schritt: util-linux installieren, dann erneut versuchen." >&2
  exit 2
fi
# N-09: sha256sum (Baum-/Sperrdatei-Hash, Zaehler-Schluessel) und mktemp
# (Wegwerfdatei fuer die Kettenausgabe) sind PRUEFMITTEL dieses Gates
# (6.12.11), mit demselben Ausgang wie jq/git/make/timeout/flock.
if ! command -v sha256sum >/dev/null 2>&1; then
  echo "dod-gate: GATE sha256sum -- 'sha256sum' (coreutils) ist nicht installiert. Baum: $baum." >&2
  echo "dod-gate: naechster Schritt: coreutils installieren, dann erneut versuchen." >&2
  exit 2
fi
if ! command -v mktemp >/dev/null 2>&1; then
  echo "dod-gate: GATE mktemp -- 'mktemp' (coreutils) ist nicht installiert. Baum: $baum." >&2
  echo "dod-gate: naechster Schritt: coreutils installieren, dann erneut versuchen." >&2
  exit 2
fi

# -----------------------------------------------------------------------------
# G9 (6.12.10): stop_hook_active. NUR bei Stop und SubagentStop im Eingabe-
# Schema vorgesehen; bei TaskCompleted wird das Feld nicht ausgewertet (die
# gelesene Referenz fuehrt es dort nicht).
# -----------------------------------------------------------------------------
if [ "$ereignis" = "Stop" ] || [ "$ereignis" = "SubagentStop" ]; then
  stop_aktiv=$(printf '%s' "$eingabe" | jq -r 'if .stop_hook_active == true then "true" else "false" end')
  if [ "$stop_aktiv" = "true" ]; then
    msg="dod-gate: Reentranz-Schutz (stop_hook_active) -- wegen dieses Schutzes NICHT durchgesetzt, Zaehler unveraendert, Kette lief in diesem Aufruf nicht. Baum: $baum."
    jq -nc --arg m "$msg" '{systemMessage: $m}'
    exit 0
  fi
fi

# -----------------------------------------------------------------------------
# G13 (6.12.14): SubagentStop und Rollen ohne veranderndes Werkzeug. Aufgeloest
# wird ueber das Frontmatter-Feld "name:" ALLER Dateien unter .claude/agents/
# des GEPRUEFTEN Baums, nicht ueber den Dateinamen. Genau ein Treffer, dessen
# "tools:"-Zeile keines von Edit, Write, NotebookEdit enthaelt: die Kette
# laeuft fuer diese Rolle nicht. Kein Treffer, mehrere Treffer, leerer
# agent_type oder Zeichen ausserhalb von [A-Za-z0-9._:-]: als schreibberechtigt
# behandeln, die Kette laeuft (Fail-closed IN RICHTUNG DER PRUEFUNG, nicht in
# Richtung des Durchlasses).
# -----------------------------------------------------------------------------
if [ "$ereignis" = "SubagentStop" ]; then
  agent_type=$(printf '%s' "$eingabe" | jq -r '.agent_type // empty')
  rolle_schreibt=1
  if [ -n "$agent_type" ] && printf '%s' "$agent_type" | grep -Eq '^[A-Za-z0-9._:-]+$'; then
    agents_verzeichnis="$baum/.claude/agents"
    treffer=0
    tools_zeile=""
    if [ -d "$agents_verzeichnis" ]; then
      while IFS= read -r datei; do
        name_feld=$(sed -n 's/^name:[[:space:]]*//p' "$datei" 2>/dev/null | head -n1 | tr -d '\r')
        if [ "$name_feld" = "$agent_type" ]; then
          treffer=$((treffer + 1))
          tools_zeile=$(sed -n 's/^tools:[[:space:]]*//p' "$datei" 2>/dev/null | head -n1 | tr -d '\r')
        fi
      done < <(find "$agents_verzeichnis" -maxdepth 1 -type f -name '*.md' 2>/dev/null | sort)
    fi
    if [ "$treffer" -eq 1 ]; then
      if ! printf '%s' "$tools_zeile" | grep -Eq '(^|[, ])(Edit|Write|NotebookEdit)([, ]|$)'; then
        rolle_schreibt=0
      fi
    fi
    # treffer = 0 oder > 1: rolle_schreibt bleibt 1 (fail-closed zur Pruefung).
  fi
  if [ "$rolle_schreibt" -eq 0 ]; then
    msg="dod-gate: Rolle '$agent_type' hat unter .claude/agents/ kein Werkzeug mit Schreibrecht (Edit/Write/NotebookEdit) -- die Kette laeuft fuer diese Rolle nicht (ADR 0002, 6.12.14), Zaehler unveraendert. Baum: $baum."
    jq -nc --arg m "$msg" '{systemMessage: $m}'
    exit 0
  fi
fi

# -----------------------------------------------------------------------------
# G8 (6.12.9), G12 (6.12.13): Zustandsverzeichnis AUSSERHALB des Arbeitsbaums.
# Nicht beschreibbar ist KEIN eigener Ausgang (G10) -- das Gate urteilt
# unveraendert und sagt im Blockfall, dass es nicht zaehlen kann.
#
# B-01: unter "set -u" bricht die Lesung von $HOME ohne eigenen Standardwert
# ab, wenn HOME nicht gesetzt ist (Rueckgabewert 1, laesst durch). XDG_STATE_
# HOME und HOME werden deshalb EINZELN mit ${VAR:-} gelesen; ist auch HOME
# nicht gesetzt, ist das Zustandsverzeichnis nicht bestimmbar und gilt als
# nicht beschreibbar (Grund in jeder Zaehlmeldung, siehe zaehl_hinweis unten).
# -----------------------------------------------------------------------------
zustand_basis=""
zustand_grund=""
if [ -n "${XDG_STATE_HOME:-}" ]; then
  zustand_basis="$XDG_STATE_HOME/r3cosint/dod-gate"
elif [ -n "${HOME:-}" ]; then
  zustand_basis="$HOME/.local/state/r3cosint/dod-gate"
fi
zustand_beschreibbar=1
if [ -z "$zustand_basis" ]; then
  zustand_beschreibbar=0
  zustand_grund="weder XDG_STATE_HOME noch HOME gesetzt"
elif ! mkdir -p "$zustand_basis" 2>/dev/null || [ ! -w "$zustand_basis" ]; then
  zustand_beschreibbar=0
  zustand_grund="$zustand_basis"
fi

# Serialisierung eigener Laeufe (G12): eine Sperrdatei je gepruefter Baum
# (Name aus SHA-256 des Baumpfads), 120 s Wartezeit. Die Sperrdatei liegt im
# Zustandsverzeichnis, NICHT im Arbeitsbaum -- eine Sperrdatei im Baum waere
# eine Datei, die waehrend des Laufs entsteht und vergeht, und D19 saehe sie.
# Der Dateideskriptor bleibt bis zum Prozessende offen; die Sperre loest sich
# beim Beenden dieses Skripts von selbst, ein eigenes "flock -u" ist deshalb
# nicht noetig.
#
# N-04: Ist das Zustandsverzeichnis nicht beschreibbar, entfaellt die Sperre
# NICHT still -- die Sperrdatei liegt dann unter einem FESTEN Pfad in /tmp
# (nicht TMPDIR, damit alle Prozesse denselben Pfad sehen), gleicher Name aus
# dem Hash des Baumpfads. Ist auch das nicht moeglich, laeuft das Gate ohne
# Sperre und meldet das (ueber $sperre_hinweis) in JEDER Meldung ab hier.
baum_hash=$(printf '%s' "$baum" | sha256sum | cut -d' ' -f1)
sperre_aktiv=1
sperre_grund=""
sperr_datei=""
if [ "$zustand_beschreibbar" -eq 1 ]; then
  sperr_datei="$zustand_basis/sperre-$baum_hash.lock"
else
  sperre_ausweich="/tmp/r3cosint-dod-gate"
  if mkdir -p "$sperre_ausweich" 2>/dev/null && [ -w "$sperre_ausweich" ]; then
    sperr_datei="$sperre_ausweich/sperre-$baum_hash.lock"
  else
    sperre_aktiv=0
    sperre_grund="Zustandsverzeichnis nicht beschreibbar ($zustand_grund) und $sperre_ausweich ebenfalls nicht anlegbar/beschreibbar"
  fi
fi
if [ "$sperre_aktiv" -eq 1 ]; then
  # ACHTUNG: "2>/dev/null" darf NICHT an dieser Zeile stehen -- "exec" ohne
  # eigenes Kommandowort wendet JEDE Umleitung dauerhaft auf die laufende
  # Shell an, nicht nur auf den "exec"-Aufruf selbst. Ein "exec {fd}>datei
  # 2>/dev/null" haette die STANDARDFEHLERAUSGABE dieses gesamten Skripts ab
  # dieser Zeile stillschweigend nach /dev/null umgeleitet -- ausgefuehrt
  # belegt (leere Ausgabe, Rueckgabewert 2, keine Meldung).
  if exec {sperre_fd}>"$sperr_datei"; then
    if ! flock -w 120 "$sperre_fd"; then
      echo "dod-gate: ein anderer Lauf haelt die Sperre fuer diesen Baum seit mehr als 120 s. Baum: $baum." >&2
      echo "dod-gate: naechster Schritt: kurz abwarten und erneut versuchen; haengt die Sperre dauerhaft, $sperr_datei pruefen." >&2
      exit 2
    fi
  else
    sperre_aktiv=0
    sperre_grund="Sperrdatei $sperr_datei nicht anlegbar (exec fehlgeschlagen)"
  fi
fi
sperre_hinweis=""
if [ "$sperre_aktiv" -eq 0 ]; then
  sperre_hinweis=" Sperre nicht aktiv: $sperre_grund."
fi

# S-13: "nicht bestimmbar" (kein Pfad ermittelbar) ist ein ANDERER Befund als
# "nicht beschreibbar" (ein ermittelter Pfad laesst sich nicht anlegen/
# beschreiben) -- unterschiedlicher Wortlaut.
# S-02: dieser Hinweis erscheint kuenftig auch bei einem sonst BELEGTEN GRUEN
# (nicht nur im Blockfall wie bisher) -- beide gruenen Durchlasspfade werten
# ihn weiter unten aus.
zustand_hinweis=""
if [ "$zustand_beschreibbar" -eq 0 ]; then
  if [ -z "$zustand_basis" ]; then
    zustand_hinweis=" Das Zustandsverzeichnis ist nicht bestimmbar ($zustand_grund); das Gate kann nicht zaehlen."
  else
    zustand_hinweis=" Das Zustandsverzeichnis ist nicht beschreibbar ($zustand_grund); das Gate kann nicht zaehlen."
  fi
fi

# -----------------------------------------------------------------------------
# G8 (6.12.9): Zaehlung und Eskalation. Datei je session_id und, falls
# vorhanden, je agent_id im Zustandsverzeichnis. Diese Funktion wird fuer
# JEDEN blockierenden Schluessel aufgerufen -- auch fuer "GATE <Pruefmittel>",
# das die Klassifizierungstabelle (6.12.4) ausdruecklich als Schluessel fuehrt
# -- und entscheidet abschliessend ueber Block oder Eskalations-Durchlass.
# Ruft nie zurueck (exit).
# -----------------------------------------------------------------------------
zaehler_schluessel_teil=$(printf '%s' "$session_id" | sha256sum | cut -d' ' -f1)
if [ -n "$agent_id" ]; then
  zaehler_schluessel_teil="${zaehler_schluessel_teil}-$(printf '%s' "$agent_id" | sha256sum | cut -d' ' -f1)"
fi
zaehler_datei="$zustand_basis/zaehler-$zaehler_schluessel_teil"

loesche_zaehler() {
  if [ "$zustand_beschreibbar" -eq 1 ]; then
    rm -f "$zaehler_datei" 2>/dev/null || true
  fi
}

blockieren_mit_zaehlung() {
  # $1 = Schluessel (6.12.4), $2 = kurze Abweichungsmeldung, $3 = naechster Schritt
  primaer_schluessel="$1"
  abweichung_text="$2"
  naechster_schritt="$3"

  alt_schluessel=""
  alt_zahl=0
  if [ "$zustand_beschreibbar" -eq 1 ] && [ -f "$zaehler_datei" ]; then
    alt_schluessel=$(sed -n '1p' "$zaehler_datei" 2>/dev/null || true)
    alt_zahl=$(sed -n '2p' "$zaehler_datei" 2>/dev/null || echo 0)
    case "$alt_zahl" in ''|*[!0-9]*) alt_zahl=0 ;; esac
  fi
  if [ "$primaer_schluessel" = "$alt_schluessel" ]; then
    neue_zahl=$((alt_zahl + 1))
  else
    neue_zahl=1
  fi
  if [ "$zustand_beschreibbar" -eq 1 ]; then
    printf '%s\n%s\n' "$primaer_schluessel" "$neue_zahl" > "$zaehler_datei" 2>/dev/null || true
  fi

  zaehl_hinweis="$zustand_hinweis"

  if [ "$neue_zahl" -ge 4 ]; then
    handoff_zeile="Eskalation 3.4: $primaer_schluessel"
    handoff_gefunden=0
    if [ -d "$baum/docs/uebergaben" ]; then
      # S-12: die fruehere Fassung zerlegte "git status --porcelain" ZEILEN-
      # weise mit "sed -E 's/^.{3}//'" -- das zerbrach bei Umbenennungen
      # ("R  alt -> neu" ist in DIESEM Format eine Zeile mit einem Pfeil, kein
      # gueltiger Pfad) und bei von core.quotePath in Anfuehrungszeichen
      # gesetzten Pfaden. "-z" mit core.quotePath=false liefert NUL-getrennte,
      # unmaskierte Felder; bei einer Umbenennung/Kopie (Status enthaelt R
      # oder C) steht der NEUE Name bereits im ERSTEN Feld (empirisch
      # geprueft, Uebergabe dieser Arbeitseinheit), gefolgt von einem
      # ZWEITEN Feld mit dem ALTEN Namen -- dieses zweite Feld wird gelesen
      # und verworfen, sonst verschiebt es die Feldzaehlung der naechsten
      # Runde.
      while IFS= read -r -d '' s12_feld; do
        s12_status="${s12_feld:0:2}"
        pfad="${s12_feld:3}"
        case "$s12_status" in
          *R*|*C*) IFS= read -r -d '' s12_alter_pfad || true ;;
        esac
        [ -n "$pfad" ] || continue
        if [ -f "$baum/$pfad" ] && grep -qF "$handoff_zeile" "$baum/$pfad" 2>/dev/null; then
          handoff_gefunden=1
          break
        fi
      done < <(git -C "$baum" -c core.quotePath=false status --porcelain --untracked-files=all -z -- docs/uebergaben 2>/dev/null)
      # --untracked-files=all: ohne den Schalter kollabiert ein vollstaendig
      # unverfolgtes Verzeichnis (der Regelfall fuer eine frische
      # Uebergabedatei) auf EINE Zeile ("?? docs/uebergaben/"), und die
      # Datei selbst waere in der Liste nicht auffindbar (dieselbe Wache
      # wie beim M1-Fund im Makefile, Ziel "dod", D19).
      if [ "$handoff_gefunden" -eq 0 ]; then
        while IFS= read -r pfad; do
          [ -n "$pfad" ] || continue
          case "$pfad" in docs/uebergaben/*) ;; *) continue ;; esac
          if [ -f "$baum/$pfad" ] && grep -qF "$handoff_zeile" "$baum/$pfad" 2>/dev/null; then
            handoff_gefunden=1
            break
          fi
        done < <(git -C "$baum" diff-tree --no-commit-id --name-only -r HEAD 2>/dev/null)
      fi
    fi
    if [ "$handoff_gefunden" -eq 1 ] && { [ "$ereignis" = "Stop" ] || [ "$ereignis" = "SubagentStop" ]; }; then
      msg="dod-gate: Eskalation 3.4 fuer '$primaer_schluessel' (${neue_zahl}. Mal in Folge) -- Durchlass, weil eine Datei unter docs/uebergaben/ die Zeile 'Eskalation 3.4: $primaer_schluessel' traegt und neu/geaendert oder im juengsten Commit enthalten ist. Die Aufgabe gilt DESHALB NICHT als erledigt (3.4). Baum: $baum.$sperre_hinweis"
      jq -nc --arg m "$msg" '{systemMessage: $m}'
      exit 0
    fi
    echo "dod-gate: BLOCKIERT. Schluessel: $primaer_schluessel. $abweichung_text (${neue_zahl}. Mal in Folge)." >&2
    if [ "$ereignis" = "TaskCompleted" ]; then
      echo "dod-gate: TaskCompleted blockiert unabhaengig von einer Uebergabedatei weiter (ADR 0002, 6.12.9) -- eine Aufgabe gilt erst nach belegtem Gruen als erledigt." >&2
    else
      echo "dod-gate: erwartet eine Datei unter docs/uebergaben/ mit der woertlichen Zeile 'Eskalation 3.4: $primaer_schluessel', neu/geaendert oder im juengsten Commit." >&2
    fi
    echo "dod-gate: naechster Schritt: $naechster_schritt" >&2
    echo "dod-gate: Baum: $baum.$zaehl_hinweis$sperre_hinweis" >&2
    exit 2
  fi

  if [ "$neue_zahl" -eq 3 ]; then
    echo "dod-gate: BLOCKIERT. Schluessel: $primaer_schluessel. $abweichung_text (drittes Mal in Folge, 3.4)." >&2
    echo "dod-gate: verlangt die Uebergabedatei unter docs/uebergaben/ mit der woertlichen Zeile:" >&2
    echo "Eskalation 3.4: $primaer_schluessel" >&2
    echo "dod-gate: naechster Schritt: $naechster_schritt" >&2
    echo "dod-gate: Baum: $baum.$zaehl_hinweis$sperre_hinweis" >&2
    exit 2
  fi

  echo "dod-gate: BLOCKIERT. Schluessel: $primaer_schluessel ($neue_zahl. Mal in Folge). $abweichung_text" >&2
  echo "dod-gate: naechster Schritt: $naechster_schritt" >&2
  echo "dod-gate: Baum: $baum.$zaehl_hinweis$sperre_hinweis" >&2
  exit 2
}

# -----------------------------------------------------------------------------
# G4 (6.12.5): die terminierten Lagen C -- strukturelle Selbstpruefungen 2, 4
# und 6, unabhaengig davon, ob dieser Lauf die betroffenen Schritte ueberhaupt
# erreicht. Ein Verstoss blockiert VOR dem 600-s-Lauf der Kette.
#   Form: "<D-Nummer> <ziel>|<repository-relativer Pfad>\t<Grund>"
#   Leerzeilen und #-Zeilen werden uebergangen.
# -----------------------------------------------------------------------------
declare -A deckung_pfad=()
declare -A deckung_grund=()
declare -A deckung_zeile=()
terminiert_fehler=""
terminiert_fehler_schluessel=""
terminiert_zeilennr=0
while IFS= read -r zeile || [ -n "$zeile" ]; do
  terminiert_zeilennr=$((terminiert_zeilennr + 1))
  case "$zeile" in
    ''|'#'*) continue ;;
  esac
  if [ "${zeile#*$'\t'}" = "$zeile" ]; then
    terminiert_fehler="Zeile $terminiert_zeilennr ohne Tabulator zwischen Schluessel und Grund: '$zeile'"
    terminiert_fehler_schluessel="LISTE 6 $terminiert_zeilennr"
    break
  fi
  schluessel="${zeile%%$'\t'*}"
  grund="${zeile#*$'\t'}"
  if [ "${schluessel/|/}" = "$schluessel" ]; then
    terminiert_fehler="Zeile $terminiert_zeilennr: Schluessel '$schluessel' enthaelt kein '|' zwischen '<D-Nummer> <ziel>' und dem Pfad (Selbstpruefung 6)"
    terminiert_fehler_schluessel="LISTE 6 $terminiert_zeilennr"
    break
  fi
  d_ziel="${schluessel%%|*}"
  pfad="${schluessel#*|}"
  d_nummer="${d_ziel%% *}"
  ziel_name="${d_ziel#* }"
  if [ "$d_nummer" = "D19" ] || [ "$d_nummer" = "D20" ]; then
    terminiert_fehler="Zeile $terminiert_zeilennr: D-Nummer '$d_nummer' ist nicht terminierbar -- D19 ist kein Kettenschritt, D20 urteilt ueber die Nachweiskette selbst (ADR 0002, 6.12.5, Selbstpruefung 6)"
    terminiert_fehler_schluessel="LISTE 6 $terminiert_zeilennr"
    break
  fi
  case "$pfad" in
    /*)
      terminiert_fehler="Zeile $terminiert_zeilennr: Pfad '$pfad' ist absolut, kein repository-relativer Pfad (Selbstpruefung 6)"
      terminiert_fehler_schluessel="LISTE 6 $terminiert_zeilennr"
      break
      ;;
  esac
  case "$pfad" in
    */*) ;;
    *)
      terminiert_fehler="Zeile $terminiert_zeilennr: Pfad '$pfad' enthaelt keinen Verzeichnistrenner, ist also kein repository-relativer Pfad und kein terminierbares Werkzeug (Selbstpruefung 6)"
      terminiert_fehler_schluessel="LISTE 6 $terminiert_zeilennr"
      break
      ;;
  esac
  if [ -n "$terminiert_fehler" ]; then break; fi
  if [ -e "$baum/$pfad" ]; then
    terminiert_fehler="Zeile $terminiert_zeilennr: '$pfad' besteht im Baum bereits -- der Eintrag ist veraltet (ADR 0002, 6.12.5, Selbstpruefung 2)"
    terminiert_fehler_schluessel="LISTE 2 $d_nummer $ziel_name"
    break
  fi
  case "$grund" in
    *"ADR 0002, "*) ;;
    *)
      terminiert_fehler="Zeile $terminiert_zeilennr: Grund fehlt oder nennt nicht die Wendung 'ADR 0002, <Abschnitt>' (Selbstpruefung 4)"
      terminiert_fehler_schluessel="LISTE 4 $terminiert_zeilennr"
      break
      ;;
  esac
  deckung_pfad["$d_nummer $ziel_name"]="$pfad"
  deckung_grund["$d_nummer $ziel_name"]="$grund"
  deckung_zeile["$d_nummer $ziel_name"]="$terminiert_zeilennr"
done < "$terminiert_pfad"

# 6.12.23 b: Verstoesse gegen die Selbstpruefungen 2, 4, 6 zaehlen unter
# `LISTE <Nummer> ...` -- NICHT mehr unter `GATE dod-gate-terminierte-lagen.txt`
# (das bezeichnet seither ausschliesslich das Fehlen der Datei selbst). Die
# Schleife oben bricht bereits bei der ERSTEN fehlerhaften Zeile in
# Dateireihenfolge ab, das erfuellt "bei mehreren fehlerhaften Zeilen die
# erste in Dateireihenfolge" (6.12.23 b) fuer diese drei Selbstpruefungen.
if [ -n "$terminiert_fehler" ]; then
  blockieren_mit_zaehlung "$terminiert_fehler_schluessel" \
    "$terminiert_fehler." \
    "die Zeile in $terminiert_pfad korrigieren oder entfernen."
fi

# -----------------------------------------------------------------------------
# G11 (6.12.12): Lauf der Kette. Standard- und Fehlerausgabe gemeinsam in eine
# Wegwerfdatei AUSSERHALB des Arbeitsbaums; auf die eigene Standardausgabe
# dieses Skripts gelangt aus dieser Datei NIE etwas (6.12.15).
# -----------------------------------------------------------------------------
# N-06: "mktemp" folgt TMPDIR. Zeigt TMPDIR in den geprueften Baum, entstuende
# die Wegwerfdatei DORT -- ein Fund, den D19 dann dem Bestand zuschriebe. Der
# PHYSISCHE Pfad der frisch angelegten Datei wird deshalb gegen den (bereits
# physisch aufgeloesten) Baum geprueft; liegt er darin, wird sie geloescht und
# unter dem FESTEN Pfad /tmp (nicht TMPDIR) neu angelegt.
ausgabe_datei=$(mktemp) || { echo "dod-gate: GATE mktemp -- 'mktemp' konnte keine Wegwerfdatei anlegen. Baum: $baum.$sperre_hinweis" >&2; exit 2; }
ausgabe_verz_phys=$( (cd "$(dirname "$ausgabe_datei")" 2>/dev/null && pwd -P) || true)
ausgabe_datei_phys="${ausgabe_verz_phys:+$ausgabe_verz_phys/}$(basename "$ausgabe_datei")"
case "$ausgabe_datei_phys" in
  "$baum"|"$baum"/*)
    rm -f "$ausgabe_datei" 2>/dev/null || true
    ausgabe_datei=$(mktemp -p /tmp 2>/dev/null || true)
    if [ -z "$ausgabe_datei" ]; then
      echo "dod-gate: GATE mktemp -- TMPDIR zeigt in den geprueften Baum ($ausgabe_datei_phys) und 'mktemp -p /tmp' schlug fehl. Baum: $baum.$sperre_hinweis" >&2
      exit 2
    fi
    ausgabe_verz_phys=$( (cd "$(dirname "$ausgabe_datei")" 2>/dev/null && pwd -P) || true)
    ausgabe_datei_phys="${ausgabe_verz_phys:+$ausgabe_verz_phys/}$(basename "$ausgabe_datei")"
    case "$ausgabe_datei_phys" in
      "$baum"|"$baum"/*)
        rm -f "$ausgabe_datei" 2>/dev/null || true
        echo "dod-gate: GATE mktemp -- auch /tmp liegt im geprueften Baum ($ausgabe_datei_phys). Baum: $baum.$sperre_hinweis" >&2
        exit 2
        ;;
    esac
    ;;
esac
trap 'rm -f "$ausgabe_datei"' EXIT

# DT2-B2: OHNE diese Zeile erbte "make dod" das TMPDIR dieses Skripts
# unveraendert -- zeigte DAS in den Baum, haette die Kette SELBST (z. B.
# Makefile, Ziel "nachweise": nachweis_tmp; Ziel "abdeckung": covdatei) dort
# kurzzeitig eine Datei angelegt, unabhaengig davon, dass die WEGWERFDATEI
# DIESES Skripts (N-06) bereits sicher ausserhalb liegt. $ausgabe_verz_phys
# ist nach der Ausweich-Pruefung oben immer das Verzeichnis der TATSAECHLICH
# benutzten (nachweislich baumfremden) Wegwerfdatei.
TMPDIR="$ausgabe_verz_phys" timeout -k 10 600 make -C "$baum" dod >"$ausgabe_datei" 2>&1
kette_rc=$?

# -----------------------------------------------------------------------------
# Auswertung (6.12.3, 6.12.4, 6.12.8). Erst die Rahmenbedingungen: Zeit-
# ueberschreitung, unerwarteter Rueckgabewert, dann die Form der Ausgabe. Jede
# hier gefundene Abweichung ist per Definition "nicht nachweisbar gelaufen"
# und damit die erste in Kettenreihenfolge -- ohne eine lesbare Ausgabe gibt
# es keine spaetere Abweichung, die frueher stuende.
# -----------------------------------------------------------------------------
if [ "$kette_rc" -eq 124 ] || [ "$kette_rc" -eq 137 ]; then
  blockieren_mit_zaehlung "KETTE zeitueberschreitung" \
    "die Kette hat die innere Zeitgrenze (600 s) gerissen; kein Urteil ueber den Arbeitsbaum." \
    "'make -C $baum dod' selbst mit mehr Zeit laufen lassen und die Ursache klaeren; ggf. O-20 (ADR 0002) melden."
fi
if [ "$kette_rc" -ne 0 ] && [ "$kette_rc" -ne 2 ]; then
  blockieren_mit_zaehlung "KETTE rueckgabewert=$kette_rc" \
    "'make -C $baum dod' endete mit Rueckgabewert $kette_rc; bei normalem Aufruf sind nur 0 oder 2 belegt." \
    "'make -C $baum dod' selbst ausfuehren und die Ausgabe pruefen."
fi

geprueft_zeile=$(grep -m1 -E '^make dod: geprueft wird .+\.$' "$ausgabe_datei" || true)
# S-10: eine FEHLENDE Baumzeile ist ein fehlender Formbestandteil (Tabelle
# 6.12.4: "KETTE ausgabe-unlesbar"), kein Baum-WIDERSPRUCH -- ein Widerspruch
# setzt voraus, dass ZWEI Angaben bestehen und einander widersprechen. Beide
# Faelle deshalb getrennt gepruef, nicht mehr ueber denselben Platzhalter
# "<keine Zeile>" zusammengefasst.
if [ -z "$geprueft_zeile" ]; then
  blockieren_mit_zaehlung "KETTE ausgabe-unlesbar" \
    "die Ausgabe der Kette enthaelt keine Zeile 'make dod: geprueft wird ...' (fehlender Formbestandteil, kein Baum-Widerspruch, S-10)." \
    "'make -C $baum dod' selbst ausfuehren und die Ausgabe pruefen."
fi
geprueft_baum="${geprueft_zeile#make dod: geprueft wird }"
geprueft_baum="${geprueft_baum%.}"
if [ "$geprueft_baum" != "$baum" ]; then
  blockieren_mit_zaehlung "KETTE baum-widerspruch" \
    "die erste Zeile der Kette nennt '$geprueft_baum', das Gate hat '$baum' bestimmt." \
    "sicherstellen, dass genau ein Arbeitsbaum gemeint ist; die Kette direkt im Baum '$baum' ausfuehren."
fi

if ! grep -qF '=== Uebersicht Definition-of-Done-Kette (make dod) ===' "$ausgabe_datei"; then
  blockieren_mit_zaehlung "KETTE ausgabe-unlesbar" \
    "die Ausgabe der Kette enthaelt keine Uebersichtszeile." \
    "'make -C $baum dod' selbst ausfuehren und die Ausgabe pruefen."
fi

d19_treffer_anzahl=$(grep -cE '^make dod: D19: (OHNE_BEFUND|VERLETZT|B|C)( -- .*)?\.$' "$ausgabe_datei" || true)
if [ "$d19_treffer_anzahl" -ne 1 ]; then
  blockieren_mit_zaehlung "KETTE ausgabe-unlesbar" \
    "die Ausgabe traegt nicht genau eine D19-Zeile in der Grammatik aus G7 (gefunden: $d19_treffer_anzahl)." \
    "'make -C $baum dod' selbst ausfuehren und die Ausgabe pruefen."
fi
d19_zeile=$(grep -m1 -E '^make dod: D19: (OHNE_BEFUND|VERLETZT|B|C)( -- .*)?\.$' "$ausgabe_datei")
d19_schluesselwort=$(printf '%s' "$d19_zeile" | sed -E 's/^make dod: D19: ([A-Z_]+).*$/\1/')

# G7/6.12.23 a: VIER Formen (die vierte ist der Nachtrag aus dem Bau).
schluss_erfolg_muster='^make dod: alle [0-9]+ Kettenschritte durchlaufen, keiner ungleich 0, [0-9]+ gueltige Marken gezaehlt\.$'
schluss_teil_muster='^make dod: alle [0-9]+ Kettenschritte durchlaufen, [0-9]+ davon ohne Urteil \(Lage C\): .+, Rueckgabewert 2\.$'
schluss_abbruch_muster='^make dod: abgebrochen bei .+, Rueckgabewert [0-9]+\.$'
schluss_d19_muster='^make dod: alle [0-9]+ Kettenschritte durchlaufen, Rahmenpruefung D19 (VERLETZT|C), Rueckgabewert 2\.$'
schluss_gesamt_anzahl=$(grep -cE "$schluss_erfolg_muster|$schluss_teil_muster|$schluss_abbruch_muster|$schluss_d19_muster" "$ausgabe_datei" || true)
if [ "$schluss_gesamt_anzahl" -ne 1 ]; then
  blockieren_mit_zaehlung "KETTE ausgabe-unlesbar" \
    "die Ausgabe traegt nicht genau eine der vier Schlusszeilen aus G7 (gefunden: $schluss_gesamt_anzahl)." \
    "'make -C $baum dod' selbst ausfuehren und die Ausgabe pruefen."
fi
schluss_form=""
if grep -qE "$schluss_erfolg_muster" "$ausgabe_datei"; then schluss_form="erfolg"; fi
if grep -qE "$schluss_teil_muster" "$ausgabe_datei"; then schluss_form="teilweise"; fi
if grep -qE "$schluss_abbruch_muster" "$ausgabe_datei"; then schluss_form="abbruch"; fi
if grep -qE "$schluss_d19_muster" "$ausgabe_datei"; then schluss_form="d19"; fi

# 6.12.23 a, Parse-Regel: "Rueckgabewert 0 nur mit Form 1". Ein Lauf, der 0
# liefert, aber nicht Form 1 traegt (oder umgekehrt: eine andere Form als
# Form 1 bei Rueckgabewert 0), ist ein Widerspruch und blockiert eigenstaendig
# -- unabhaengig davon, was die spaetere Uebersicht-/D19-Auswertung faende.
if [ "$kette_rc" -eq 0 ] && [ "$schluss_form" != "erfolg" ]; then
  blockieren_mit_zaehlung "KETTE schlusszeile-widerspruch" \
    "Rueckgabewert der Kette war 0, die Schlusszeile ist aber nicht Form 1 (erfolg) -- nach 6.12.23 a ist Rueckgabewert 0 nur mit Form 1 vereinbar." \
    "'make -C $baum dod' selbst ausfuehren und die Ausgabe pruefen."
fi

# -----------------------------------------------------------------------------
# G2/G3 (6.12.3, 6.12.4): die Uebersichtszeilen einzeln lesen, IN REIHENFOLGE.
# Die Kette selbst schreibt sie in Ausfuehrungsreihenfolge (Makefile, Ziel
# "dod"); das Gate wiederholt diese Reihenfolge nicht als eigene Liste (das
# waere die von G2 ausdruecklich abgelehnte zweite Zahl/Liste), es liest sie.
#
# Marken tragen die Lauf-Kennung strukturell; sie steht im Muster unten an
# erster Stelle und wird nur zur GLEICHHEITSPRUEFUNG benutzt, nie inhaltlich
# geprueft (die Kennung ist dem Gate vorher nicht bekannt, 6.12.3).
# -----------------------------------------------------------------------------
uebersicht_zeilen=$(awk '
  /^=== Uebersicht Definition-of-Done-Kette \(make dod\) ===$/ { gefunden=1; next }
  gefunden && (/^::LAGE / || /^\(keine Marke\)/) { print; next }
  gefunden { exit }
' "$ausgabe_datei")

primaer_schluessel=""
primaer_text=""
primaer_naechster=""
erste_kennung=""
kennung_uneinheitlich=0
gedeckte_liste=()
declare -A gesehene_lage=()
# Zwischenspeicher fuer die Prioritaet aus 6.12.23 b: (1) GATE -- ausserhalb
# dieses Abschnitts, blockiert vor jedem Lauf; (2) LISTE (Selbstpruefungen 3
# und 5), bei mehreren fehlerhaften Zeilen die erste in DATEIreihenfolge
# (deckung_zeile), unabhaengig von der Position in der Uebersicht; (3) die
# erste Abweichung in UEBERSICHTreihenfolge (A_FAIL, ungedeckte Lage C ohne
# Eintrag, marke-fehlt); (4) D19. Deshalb werden LISTE-5-Kandidaten separat
# gesammelt statt sofort als primaer_schluessel gesetzt -- ein A_FAIL, das in
# der Uebersicht VOR einem LISTE-5-Fund steht, darf diesen nicht verdecken.
kette_abweichung_schluessel=""
kette_abweichung_text=""
kette_abweichung_naechster=""
liste5_kandidaten=()
marken_anzahl=0
# Das Muster spiegelt exakt die Grammatik aus G6/G7: "::LAGE <kennung> <D>
# <ziel> <Lage>[ FEHLT=<wert>][ SCHWELLE=...|OHNE_SCHWELLE]::" gefolgt vom
# festen Anhang " (rueckgabewert=N)" aus der Zusammenfassung im Makefile.
marken_muster='^::LAGE ([^ ]+) ([^ ]+) ([^ ]+) (A_OK|A_FAIL|B|C)( FEHLT=([^ :]+))?( (SCHWELLE=[^ :]+|OHNE_SCHWELLE))?:: \(rueckgabewert=(-?[0-9]+)\)$'

while IFS= read -r zeile; do
  [ -n "$zeile" ] || continue
  if [[ "$zeile" =~ $marken_muster ]]; then
    m_kennung="${BASH_REMATCH[1]}"
    m_d="${BASH_REMATCH[2]}"
    m_ziel="${BASH_REMATCH[3]}"
    m_lage="${BASH_REMATCH[4]}"
    m_fehlt="${BASH_REMATCH[6]}"
    if [ -z "$erste_kennung" ]; then
      erste_kennung="$m_kennung"
    elif [ "$m_kennung" != "$erste_kennung" ]; then
      kennung_uneinheitlich=1
    fi
    marken_anzahl=$((marken_anzahl + 1))
    gesehene_lage["$m_d $m_ziel"]="$m_lage"
    if [ "$m_lage" = "A_FAIL" ]; then
      if [ -z "$kette_abweichung_schluessel" ]; then
        kette_abweichung_schluessel="$m_d $m_ziel A_FAIL"
        kette_abweichung_text="Schritt $m_d $m_ziel meldet Lage A_FAIL (durchgefallen)."
        kette_abweichung_naechster="'make $m_ziel' einzeln ausfuehren, den Befund beheben, dann erneut versuchen."
      fi
    elif [ "$m_lage" = "C" ]; then
      hinterlegt="${deckung_pfad["$m_d $m_ziel"]:-}"
      if [ -n "$hinterlegt" ] && [ "$hinterlegt" = "$m_fehlt" ]; then
        gedeckte_liste+=("$m_d $m_ziel FEHLT=$m_fehlt")
      elif [ -n "$hinterlegt" ]; then
        # Selbstpruefung 5 (6.12.5): ein Eintrag BESTEHT fuer diesen Schritt,
        # nennt aber ein anderes Pruefmittel als die Marke -- ein Fehler der
        # LISTE (6.12.23 b), Prioritaet vor jeder Kettenabweichung, tie-break
        # ueber die Dateireihenfolge weiter unten.
        liste5_kandidaten+=("$m_d $m_ziel|$m_fehlt|$hinterlegt")
      elif [ -z "$kette_abweichung_schluessel" ]; then
        # Selbstpruefung 1: kein Eintrag fuer diesen Schritt -- ungedeckte
        # Lage C, unveraendert der Schluessel aus 6.12.4 (kein LISTE-Fehler).
        kette_abweichung_schluessel="$m_d $m_ziel C ${m_fehlt:-unbenannt}"
        kette_abweichung_text="Schritt $m_d $m_ziel meldet Lage C mit FEHLT=${m_fehlt:-unbenannt}; kein Eintrag in dod-gate-terminierte-lagen.txt."
        kette_abweichung_naechster="${m_fehlt:-das fehlende Pruefmittel} beschaffen, oder einen Eintrag '$m_d $m_ziel|${m_fehlt:-<pfad>}' mit Grund 'ADR 0002, <Abschnitt>' in $terminiert_pfad anlegen (ADR 0002, 6.12.5)."
      fi
    fi
  elif [[ "$zeile" == "(keine Marke)"* ]]; then
    if [ -z "$kette_abweichung_schluessel" ] && [ "$schluss_form" = "abbruch" ]; then
      abbruch_zeile=$(grep -m1 -E "$schluss_abbruch_muster" "$ausgabe_datei")
      abbruch_d_ziel=$(printf '%s' "$abbruch_zeile" | sed -E 's/^make dod: abgebrochen bei (.+), Rueckgabewert [0-9]+\.$/\1/')
      kette_abweichung_schluessel="KETTE marke-fehlt $abbruch_d_ziel"
      kette_abweichung_text="ein Schritt hat keine eigene, passende Lage-Marke ausgegeben (nicht nachweisbar gelaufen)."
      kette_abweichung_naechster="den betroffenen Schritt einzeln ausfuehren und die Ursache klaeren (hart abgebrochen? MAKE_REKURSIV umgeleitet? Ausgabe leer, fremd oder ohne Lauf-Kennung?)."
    fi
  fi
done <<< "$uebersicht_zeilen"

# -----------------------------------------------------------------------------
# S-11: die GELESENE Markenzahl gegen die Zahl in der Schlusszeile SELBST
# pruefen -- keine feste Zahl im Gate (die Kette wird waechst noch, ADR 0002
# Abschnitt 6). Form 1 nennt sie als "... N gueltige Marken gezaehlt.";
# Form 2 und 4 als "alle N Kettenschritte durchlaufen, ..."; Form 3
# (Abbruch) wird bewusst NICHT geprueft -- ein Abbruch mitten in der Kette
# hat planmaessig weniger Marken als Kettenschritte. Mindestens EINE Marke
# ist in Form 1/2/4 immer verlangt, unabhaengig davon, was die Schlusszeile
# selbst behauptet (eine Schlusszeile "0 gueltige Marken gezaehlt" waere
# selbst schon der Beweis, dass nichts nachweisbar gelaufen ist).
# -----------------------------------------------------------------------------
schluss_marken_erwartet=""
case "$schluss_form" in
  erfolg)
    schluss_marken_erwartet=$(grep -m1 -E "$schluss_erfolg_muster" "$ausgabe_datei" | sed -E 's/^make dod: alle [0-9]+ Kettenschritte durchlaufen, keiner ungleich 0, ([0-9]+) gueltige Marken gezaehlt\.$/\1/')
    ;;
  teilweise|d19)
    schluss_marken_erwartet=$(grep -m1 -E "$schluss_teil_muster|$schluss_d19_muster" "$ausgabe_datei" | sed -E 's/^make dod: alle ([0-9]+) Kettenschritte durchlaufen, .*$/\1/')
    ;;
esac
if [ -n "$schluss_marken_erwartet" ] \
   && { [ "$marken_anzahl" -eq 0 ] || [ "$marken_anzahl" -ne "$schluss_marken_erwartet" ]; }; then
  blockieren_mit_zaehlung "KETTE ausgabe-unlesbar" \
    "die Schlusszeile nennt $schluss_marken_erwartet Marken, tatsaechlich in der Uebersicht gelesen wurden $marken_anzahl (verlangt: mindestens eine, und Gleichheit, S-11)." \
    "'make -C $baum dod' selbst ausfuehren und die Ausgabe pruefen."
fi

# -----------------------------------------------------------------------------
# G4 (6.12.5), Selbstpruefungen 3 und 5, gemeinsam ausgewertet: bei mehreren
# fehlerhaften Zeilen der terminierten Lagen gewinnt die erste in DATEI-
# reihenfolge (6.12.23 b) -- deckung_zeile traegt die physische Zeilennummer
# aus der Strukturpruefung oben, fuer BEIDE Selbstpruefungen gleichermassen.
# Selbstpruefung 3: ein Eintrag zu einem Schritt, der in DIESEM Lauf eine
# ANDERE Lage als C meldet. Nur pruefbar fuer Schritte, die in diesem Lauf
# tatsaechlich eine Marke gezeigt haben -- lief ein Schritt nicht (frueherer
# Abbruch), bleibt der Eintrag unbeurteilt, nicht falsch.
# -----------------------------------------------------------------------------
liste_beste_zeile=""
liste_schluessel=""
liste_text=""
liste_naechster=""
for kandidat in "${liste5_kandidaten[@]:-}"; do
  [ -n "$kandidat" ] || continue
  kand_d_ziel="${kandidat%%|*}"
  kand_rest="${kandidat#*|}"
  kand_fehlt="${kand_rest%%|*}"
  kand_hinterlegt="${kand_rest#*|}"
  zeile_dieser="${deckung_zeile[$kand_d_ziel]}"
  if [ -z "$liste_beste_zeile" ] || [ "$zeile_dieser" -lt "$liste_beste_zeile" ]; then
    liste_beste_zeile="$zeile_dieser"
    liste_schluessel="LISTE 5 $kand_d_ziel"
    liste_text="Schritt $kand_d_ziel meldet Lage C mit FEHLT=${kand_fehlt:-unbenannt}; der Eintrag in dod-gate-terminierte-lagen.txt (Zeile $zeile_dieser) nennt '$kand_hinterlegt' -- Selbstpruefung 5, gilt als nicht gedeckt."
    liste_naechster="den Eintrag '$kand_d_ziel|$kand_hinterlegt' in $terminiert_pfad auf FEHLT=${kand_fehlt:-unbenannt} berichtigen oder entfernen."
  fi
done
for schluessel_d_ziel in "${!deckung_pfad[@]}"; do
  beobachtete_lage="${gesehene_lage[$schluessel_d_ziel]:-}"
  if [ -n "$beobachtete_lage" ] && [ "$beobachtete_lage" != "C" ]; then
    zeile_dieser="${deckung_zeile[$schluessel_d_ziel]}"
    if [ -z "$liste_beste_zeile" ] || [ "$zeile_dieser" -lt "$liste_beste_zeile" ]; then
      liste_beste_zeile="$zeile_dieser"
      liste_schluessel="LISTE 3 $schluessel_d_ziel"
      liste_text="Eintrag fuer '$schluessel_d_ziel' (Zeile $zeile_dieser in $terminiert_pfad) ist veraltet: der Schritt meldet in diesem Lauf Lage '$beobachtete_lage', nicht mehr C (ADR 0002, 6.12.5, Selbstpruefung 3)."
      liste_naechster="den Eintrag fuer '$schluessel_d_ziel' aus $terminiert_pfad entfernen."
    fi
  fi
done

# -----------------------------------------------------------------------------
# Rangfolge aus 6.12.23 b, ab hier angewandt: (2) LISTE vor (3) der ersten
# Kettenabweichung vor (4) D19. kennung_uneinheitlich ist kein Schluessel aus
# 6.12.4/6.12.23 und bleibt deshalb der reine Auffangfall, wenn sonst nichts
# gefunden wurde -- Marken, die einander widersprechen, sind so oder so nicht
# vertrauenswuerdig.
# -----------------------------------------------------------------------------
if [ -n "$liste_schluessel" ]; then
  primaer_schluessel="$liste_schluessel"
  primaer_text="$liste_text"
  primaer_naechster="$liste_naechster"
elif [ -n "$kette_abweichung_schluessel" ]; then
  primaer_schluessel="$kette_abweichung_schluessel"
  primaer_text="$kette_abweichung_text"
  primaer_naechster="$kette_abweichung_naechster"
fi

# -----------------------------------------------------------------------------
# D19 (6.12.4): nur ausgewertet, wenn weder LISTE noch die Uebersicht selbst
# eine Abweichung ergeben haben -- D19 klammert den GANZEN Lauf ein und ist
# damit zeitlich die LETZTE Beobachtung; "die erste Abweichung in
# Kettenreihenfolge" (G8/6.12.23 b) kann folglich nur dann D19 sein, wenn
# nichts davor greift.
# -----------------------------------------------------------------------------
if [ -z "$primaer_schluessel" ]; then
  case "$d19_schluesselwort" in
    VERLETZT)
      primaer_schluessel="D19 VERLETZT"
      primaer_text="D19 meldet VERLETZT -- der versionierte Bestand hat sich waehrend des Laufs veraendert."
      primaer_naechster="den Lauf wiederholen, wenn sonst nichts in den Baum schreibt; sonst den schreibenden Schritt finden (ADR 0002, Kettengrundsatz 6.1.3)."
      ;;
    C)
      primaer_schluessel="D19 C"
      primaer_text="D19 meldet Lage C -- das Beobachtungsmittel fehlt oder traegt die Aussage nicht."
      primaer_naechster="das fehlende Mittel beschaffen (siehe D19-Zeile: $d19_zeile) und erneut versuchen."
      ;;
    B)
      # Das Gate hat an dieser Stelle bereits einen Arbeitsbaum bestimmt
      # (geprueft_baum stimmt mit $baum ueberein) -- D19 Lage B widerspricht
      # dem (6.12.4, Zeile "D19-Zeile meldet Lage B, obwohl das Gate einen
      # Arbeitsbaum bestimmt hat").
      primaer_schluessel="D19 B-widerspruch"
      primaer_text="D19 meldet Lage B (kein Git-Arbeitsbaum), das Gate hat aber einen Arbeitsbaum bestimmt ($baum) -- Widerspruch."
      primaer_naechster="'make -C $baum dod' selbst ausfuehren und pruefen, ob $baum wirklich ein Git-Arbeitsbaum ist."
      ;;
  esac
fi

if [ -z "$primaer_schluessel" ] && [ "$kennung_uneinheitlich" -eq 1 ]; then
  primaer_schluessel="KETTE ausgabe-unlesbar"
  primaer_text="nicht alle Marken der Uebersicht tragen dieselbe Lauf-Kennung."
  primaer_naechster="'make -C $baum dod' selbst ausfuehren und die Ausgabe pruefen."
fi

# -----------------------------------------------------------------------------
# Konsistenzwache: der eigene Rueckgabewert der Kette und das Ergebnis der
# Textauswertung muessen zusammenpassen. Weichen sie voneinander ab, ist die
# Ausgabe nicht vertrauenswuerdig -- fail-closed statt eines der beiden Signale
# zu bevorzugen. Ein kette_rc von 2 BEI LEEREM primaer_schluessel ist KEIN
# Widerspruch, wenn mindestens eine gedeckte Lage C vorliegt: "make dod"
# bleibt bei einer terminierten Lage C selbst bei 2 (ADR 0002, 6.12.5, "die
# Gegenseite bleibt streng") -- das Gate darf trotzdem durchlassen.
# -----------------------------------------------------------------------------
# Ausnahme: ein Schluessel, der mit "GATE " oder "LISTE " beginnt, ist ein
# Urteil des Gates UEBER die Liste der terminierten Lagen selbst
# (Selbstpruefungen 1 bis 6, 6.12.5/6.12.23 b) -- unabhaengig vom
# Rueckgabewert der Kette, die an dieser Stelle durchaus 0 melden darf (der
# betroffene Schritt kann laengst wieder A_OK oder B sein, Selbstpruefung 3).
# S-01: "D19 B-widerspruch" (Tabelle 6.12.4) hat VORRANG vor dieser Wache --
# genau dieser Schluessel entsteht IMMER bei kette_rc=0 (D19 Lage B haelt den
# eigenen Rueckgabewert der Kette nicht ungleich 0, das echte Makefile
# bestaetigt das, Selbsttest Fall 21 "B"), ohne dass das ein Widerspruch waere.
# Die Wache greift nur fuer Abweichungen, die KEINEN eigenen Widerspruchs-
# schluessel tragen.
if [ -n "$primaer_schluessel" ] && [ "$kette_rc" -eq 0 ] \
   && [ "$primaer_schluessel" != "D19 B-widerspruch" ] \
   && [ "${primaer_schluessel#GATE }" = "$primaer_schluessel" ] \
   && [ "${primaer_schluessel#LISTE }" = "$primaer_schluessel" ]; then
  blockieren_mit_zaehlung "KETTE ausgabe-unlesbar" \
    "die Textauswertung findet eine Abweichung ($primaer_schluessel), der Rueckgabewert der Kette war aber 0 -- widerspruechlich." \
    "'make -C $baum dod' selbst ausfuehren und die Ausgabe pruefen."
fi
if [ -z "$primaer_schluessel" ] && [ "$kette_rc" -ne 0 ] && [ "${#gedeckte_liste[@]}" -eq 0 ]; then
  blockieren_mit_zaehlung "KETTE ausgabe-unlesbar" \
    "die Textauswertung findet keine Abweichung, der Rueckgabewert der Kette war aber $kette_rc -- widerspruechlich." \
    "'make -C $baum dod' selbst ausfuehren und die Ausgabe pruefen."
fi

# -----------------------------------------------------------------------------
# Ausgang (6.12.4, 6.12.15, 6.12.18).
# -----------------------------------------------------------------------------
if [ -n "$primaer_schluessel" ]; then
  blockieren_mit_zaehlung "$primaer_schluessel" "$primaer_text" "$primaer_naechster"
fi

# Belegtes Gruen: kein Kettenschritt hat A_FAIL oder eine ungedeckte Lage C
# gemeldet, D19 ist ohne Befund, die Marken sind einheitlich. Ein Durchlass
# wegen Ergebnis loescht den Zaehler (G8).
loesche_zaehler

if [ "${#gedeckte_liste[@]}" -gt 0 ]; then
  liste_text=$(printf '%s; ' "${gedeckte_liste[@]}")
  liste_text="${liste_text%; }"
  msg="dod-gate: Durchlass mit terminierten Lagen C: $liste_text (ADR 0002, 6.12.5). Diese Schritte haben in diesem Lauf NICHT geurteilt. Baum: $baum.$zustand_hinweis$sperre_hinweis"
  jq -nc --arg m "$msg" '{systemMessage: $m}'
  exit 0
fi

# Sauberes Gruen: keine Ausgabe -- AUSSER Zustandsverzeichnis oder Sperre sind
# in diesem Lauf ausgefallen (S-02/N-04): dann nennt eine systemMessage den
# Grund, auch bei einem sonst sauberen Durchlass.
if [ "$sperre_aktiv" -eq 0 ] || [ "$zustand_beschreibbar" -eq 0 ]; then
  msg="dod-gate: Durchlass (belegtes Gruen).$zustand_hinweis$sperre_hinweis Baum: $baum."
  jq -nc --arg m "$msg" '{systemMessage: $m}'
  exit 0
fi
exit 0
