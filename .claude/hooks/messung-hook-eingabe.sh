#!/usr/bin/env bash
# PreToolUse-Hook: Messung M-R5 -- schreibt auf, welche Felder die Eingabe
# eines PreToolUse-Hooks traegt. Kanal, kein Gate.
#
# Zweck: Messung M-R5 nach ADR 0006, Teil A (Anforderung R3-Q-005,
# Rollen-Schreibgrenzen). Vor dem Bau des Gates wird gemessen, ob die Eingabe
# im Subagenten agent_type und agent_id traegt, ob ein Hook aus dem hooks-Feld
# einer Rollendatei feuert und sein Argument erhaelt, welche Umgebungsvariablen
# (nur Namen) der Hook sieht und wann eine Aenderung wirkt. Das Skript und sein
# Eintrag in .claude/settings.json entfallen in R5.2 im selben Arbeitsstand,
# in dem das Gate entsteht.
#
# Was geschrieben wird: genau eine Zeile je Aufruf, TAB-getrennt, je als
# name=wert: zeit, arg, ereignis, werkzeug, agent_type, agent_id, session_id,
# cwd, scratchpad_dir, permission_mode, schluessel (Namen der obersten
# JSON-Schluessel), umgebung (NAMEN aller Umgebungsvariablen), jq, eingabe
# (bytes=Zahl oder ungueltig). Fehlende Felder stehen als "-"; TAB und
# Zeilenumbruch in Werten werden durch ein Leerzeichen ersetzt.
# Was nie geschrieben wird: nichts aus tool_input (auch kein Dateipfad), nie
# der Wert einer Umgebungsvariablen.
#
# Rueckgabewert: auf jedem Weg 0 (fehlendes jq, ungueltige Eingabe, nicht
# schreibbare Ablage, fehlendes Argument, Zeitueberschreitung). Keine Ausgabe
# auf Standardausgabe und Fehlerausgabe. Eingabe hoechstens 4 MB.
# Zeitgrenze: die ganze Arbeit laeuft unter "timeout -k 1 5" (Selbstaufruf
# mit innerem Modus), kuerzer als die Grenze 10 s in settings.json.
# Ablageort: ${TMPDIR:-/tmp}/r3cosint-messung-r5/eingabe.log (Verzeichnis 700,
# Datei 600, ausserhalb des Arbeitsbaums).
# Grenzen: Die Umgebungsnamen werden als Erstes im inneren Lauf erhoben, vor
# jedem export (danach LC_ALL=C, damit bytes Bytes zaehlt); sie stammen aus der inneren bash; sie setzt PWD, SHLVL
# und OLDPWD selbst, diese Namen erscheinen auch, wenn der Aufrufer sie nicht
# setzt. Nie in den Arbeitsbaum, wenn CLAUDE_PROJECT_DIR gesetzt ist (liegt der
# Ablageordner darunter, lexikalisch oder physisch, wird nichts geschrieben);
# sonst nur, soweit TMPDIR nicht hineinzeigt. Fehlt timeout, schreibt der Hook
# nichts und endet mit 0.
# Vor dem Schreiben drei Pruefungen, bei Misserfolg wird nichts geschrieben
# (weiter mit Rueckgabewert 0, ohne Ausgabe): (1) der Ablageordner ist keine
# symbolische Verknuepfung; (2) er gehoert dem eigenen Benutzer (stat -c %u
# gleich id -u); (3) eingabe.log ist, falls vorhanden, eine regulaere Datei und
# keine Verknuepfung.
#
# Aufrufformen: aus .claude/settings.json ohne Argument (arg=-); aus dem
# hooks-Feld einer Rollendatei mit der Rollenkennung als Argument.

unset CDPATH
set -u

if [ "${1:-}" = "--innen-r5" ]; then
  arg="${2:-}"
  [ -n "$arg" ] || arg="-"
  umgebung="$(compgen -e 2>/dev/null | LC_ALL=C sort | paste -sd, - 2>/dev/null | tr '\t\n\r' '   ')"
  export LC_ALL=C
  eingabe="$(head -c 4194304 2>/dev/null; echo x)"
  eingabe="${eingabe%x}"
  bytes="${#eingabe}"
  [ -n "$umgebung" ] || umgebung="-"
  zeit="$(date -u +%FT%TZ 2>/dev/null)"
  [ -n "$zeit" ] || zeit="-"
  arg="$(printf '%s' "$arg" | tr '\t\n\r' '   ')"
  jqstatus="fehlt"
  felder="ereignis=-	werkzeug=-	agent_type=-	agent_id=-	session_id=-	cwd=-	scratchpad_dir=-	permission_mode=-	schluessel=-"
  einginfo="ungueltig"
  if command -v jq >/dev/null 2>&1; then
    jqstatus="ok"
    if printf '%s' "$eingabe" | jq -e 'type=="object"' >/dev/null 2>&1; then
      einginfo="bytes=$bytes"
      f="$(printf '%s' "$eingabe" | jq -r '
        def s: if . == null or . == "" then "-" else (tostring | gsub("[\\t\\n\\r]"; " ")) end;
        ["ereignis=" + (.hook_event_name|s), "werkzeug=" + (.tool_name|s),
         "agent_type=" + (.agent_type|s), "agent_id=" + (.agent_id|s),
         "session_id=" + (.session_id|s), "cwd=" + (.cwd|s),
         "scratchpad_dir=" + (.scratchpad_dir|s), "permission_mode=" + (.permission_mode|s),
         "schluessel=" + ((keys|join(","))|s)] | join("\t")' 2>/dev/null)"
      [ -n "$f" ] && felder="$f"
    fi
  fi
  zeile="zeit=$zeit	arg=$arg	$felder	umgebung=$umgebung	jq=$jqstatus	eingabe=$einginfo"
  (
    umask 077
    d="${TMPDIR:-/tmp}/r3cosint-messung-r5"
    [ -L "$d" ] && exit 0
    if [ -n "${CLAUDE_PROJECT_DIR:-}" ]; then
      p="${CLAUDE_PROJECT_DIR%/}/"
      case "$d/" in "$p"*) exit 0 ;; esac
      elt="$(dirname "$d")"
      [ -d "$elt" ] || exit 0
      ep="$(cd -P "$elt" 2>/dev/null && pwd -P)"
      [ -n "$ep" ] || exit 0
      pp="$(cd -P "${CLAUDE_PROJECT_DIR}" 2>/dev/null && pwd -P)/"
      case "$ep/r3cosint-messung-r5/" in "$pp"*) exit 0 ;; esac
    fi
    mkdir -p "$d" 2>/dev/null || exit 0
    [ -L "$d" ] && exit 0
    [ -d "$d" ] || exit 0
    [ "$(stat -c %u "$d" 2>/dev/null)" = "$(id -u 2>/dev/null)" ] || exit 0
    chmod 700 "$d" 2>/dev/null
    if [ -e "$d/eingabe.log" ] || [ -L "$d/eingabe.log" ]; then
      [ -L "$d/eingabe.log" ] && exit 0
      [ -f "$d/eingabe.log" ] || exit 0
    fi
    printf '%s\n' "$zeile" >> "$d/eingabe.log"
  ) >/dev/null 2>&1
  exit 0
fi

if command -v timeout >/dev/null 2>&1; then
  timeout -k 1 5 bash "$0" --innen-r5 "${1:-}" >/dev/null 2>&1
fi
exit 0
