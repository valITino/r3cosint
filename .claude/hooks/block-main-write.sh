#!/usr/bin/env bash
# PreToolUse-Gate: kein direkter Schreibzugriff auf main (Projektauftrag 3.2 c).
#
# 3.2 (c): "Regeln wie 'nie direkt auf main pushen' oder 'kein Commit ohne
# bestandene Tests' gehoeren als Hook implementiert, nicht als Satz in
# CLAUDE.md." CLAUDE.md ist Kontext, keine Durchsetzung.
#
# Zwei Faelle:
#   1. Dateiaenderung, waehrend HEAD auf main/master steht.
#   2. Bash-Befehl, der auf main/master committet, merged oder pusht.
#
# GRENZE DIESES GATES, ehrlich benannt: Es prueft den TEXT des Bash-Befehls.
# Gegen einen Interpreter, der mit eigener Datei-API schreibt, oder gegen einen
# zweiten, auf main ausgecheckten Arbeitsbaum, der ausserhalb dieser Sitzung
# angelegt wurde, ist Textpruefung grundsaetzlich nicht dicht. Dieses Gate ist
# deshalb die ZWEITE Verteidigungslinie. Die harte Zusicherung gegen Schreiben
# auf main liefert das serverseitige GitHub-Ruleset (Force-Push-Sperre,
# Pull-Request-Pflicht); das Gate faengt die haeufigen Wege frueh und laut ab,
# damit ein Fehler nicht erst am Server auffaellt. Es deckt: die gaengigen
# Interpreter mit Inline-Code, das Anlegen eines Arbeitsbaums auf main und
# Mirror-/Wildcard-Pushes (Befunde der statischen Pruefung vom 2026-08-25).
#
# Rueckgabewert 2 blockiert. Rueckgabewert 1 blockiert NICHT (3.4).
set -uo pipefail

if ! command -v jq >/dev/null 2>&1; then
  echo "Gate main-schutz: jq ist nicht installiert; das Gate kann nicht pruefen." >&2
  echo "Installieren (z.B. 'apt-get install -y jq') oder das Gate bewusst entfernen." >&2
  exit 2
fi

input=$(cat)
proj="${CLAUDE_PROJECT_DIR:-$PWD}"

git -C "$proj" rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0
branch=$(git -C "$proj" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
[ -n "$branch" ] || exit 0

is_protected() { [ "$1" = "main" ] || [ "$1" = "master" ]; }

tool=$(printf '%s' "$input" | jq -r '.tool_name // empty')

if [ "$tool" = "Bash" ]; then
  cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty')
  [ -n "$cmd" ] || exit 0

  # Einen zweiten Arbeitsbaum auf main/master anzulegen ist ein Weg, spaeter an
  # main vorbeizuschreiben. 'git worktree add <pfad> main' checkt main direkt
  # aus und wird gesperrt; 'git worktree add -b <neuerzweig> <pfad> main' zweigt
  # dagegen einen NEUEN Zweig von main ab und checkt diesen aus -- das ist
  # zulaessig und darf nicht blockieren (Falsch-Positiv-Befund 2026-08-25).
  if printf '%s' "$cmd" | grep -Eq 'git[[:space:]]+([^|;&]*[[:space:]])?worktree[[:space:]]+add([[:space:]]|$)' \
      && ! printf '%s' "$cmd" | grep -Eq 'worktree[[:space:]]+add[^|;&]*[[:space:]]-[bB]([[:space:]]|=)' \
      && { printf '%s' "$cmd" | grep -Eq '(^|[[:space:]])(main|master)([[:space:]]|$|["'\''])' \
           || printf '%s' "$cmd" | grep -Eq 'refs/(heads|for)/(main|master)'; }; then
    echo "BLOCKIERT (Projektauftrag 3.2 c): Arbeitsbaum auf main/master anlegen." >&2
    echo "Ein zweiter Arbeitsbaum auf main umgeht den Schutz. Einen neuen Zweig abzweigen:" >&2
    echo "  git worktree add -b <zweig> <pfad> main" >&2
    exit 2
  fi

  # Geschuetzter Zielkontext bestimmen. Der Schutz gilt, wenn der Projektbaum
  # selbst auf main/master steht ODER wenn der Befehl den Kontext in einen
  # anderen Checkout wechselt, der auf main/master steht -- ueber 'cd', 'pushd',
  # 'git -C <pfad>' oder 'env -C <pfad>'. Ohne diese Aufloesung liesse sich mit
  # 'cd <main-checkout> && git commit' oder 'cd <main-checkout> && sed -i datei'
  # an main vorbeischreiben (Befund N1 der statischen Pruefung vom 2026-08-25,
  # ausgefuehrt belegt). Jeder gefundene Kontextpfad wird aufgeloest; ist einer
  # geschuetzt, gilt der ganze Befehl als geschuetzter Kontext.
  #
  # BEWUSSTE GRENZE: Erfasst werden die gebraeuchlichen Idiome. Ein in eine
  # Subshell '(cd x; ...)', in 'bash -c "cd x; ..."' oder in ein anderes
  # Programm verlagerter Kontextwechsel ist mit Textpruefung nicht sicher
  # erkennbar. Das ist die im Kopf benannte Grenze; die harte Zusicherung
  # liefert das serverseitige Ruleset, nicht dieses Gate.
  if is_protected "$branch"; then ziel_geschuetzt=1; else ziel_geschuetzt=0; fi
  while IFS= read -r kp; do
    [ -n "$kp" ] || continue
    kb=$(git -C "$kp" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
    if is_protected "$kb"; then ziel_geschuetzt=1; fi
  done < <(printf '%s' "$cmd" \
    | grep -oE '(^|[;&|[:space:](])(cd|pushd|git[[:space:]]+-C|env[[:space:]]+-C)[[:space:]]+("[^"]+"|'\''[^'\'']+'\''|[^[:space:];&|)]+)' \
    | sed -E 's/^[;&|( [:space:]]*(cd|pushd|git[[:space:]]+-C|env[[:space:]]+-C)[[:space:]]+//; s/^"//; s/"$//; s/^'\''//; s/'\''$//')

  # push mit ausdruecklichem Ziel main/master, auch als HEAD:main, in der
  # vollqualifizierten Ref-Form HEAD:refs/heads/main oder mit --force.
  # Die Ref-Form braucht ein eigenes Muster: im allgemeinen Muster darf vor
  # main kein '/' stehen, sonst wuerde jeder Zweigname wie 'fix/main-seite'
  # blockiert. Befund der statischen Pruefung vom 2026-08-25 (ausgefuehrt:
  # 'git push origin HEAD:refs/heads/main' von einem Arbeitszweig lief durch).
  if printf '%s' "$cmd" | grep -Eq 'git[[:space:]]+([^|;&]*[[:space:]])?push([[:space:]]|$)'; then
    # --mirror, --all und Wildcard-Refspecs uebertragen alle lokalen Zweige,
    # darunter main, ohne 'main' im Text zu nennen (Befund 2026-08-25).
    if printf '%s' "$cmd" | grep -Eq '(^|[[:space:]])(--mirror|--all)([[:space:]]|$)' \
        || printf '%s' "$cmd" | grep -Eq 'refs/heads/\*|[[:space:]:+]\*:|:\*([[:space:]]|$)'; then
      echo "BLOCKIERT (Projektauftrag 3.2 c): Sammel-Push (--mirror/--all/Wildcard) uebertraegt auch main." >&2
      echo "Nur den Arbeitszweig ausdruecklich pushen: git push -u origin <zweig>" >&2
      exit 2
    fi
    if printf '%s' "$cmd" | grep -Eq '(^|[[:space:]:+])(main|master)([[:space:]]|$|["'\''])' \
        || printf '%s' "$cmd" | grep -Eq 'refs/(heads|for)/(main|master)([[:space:]]|$|["'\''])'; then
      echo "BLOCKIERT (Projektauftrag 3.2 c): Push nach main/master." >&2
      echo "Auf den Arbeitszweig pushen und die Aenderung ueber einen Pull Request fuehren." >&2
      echo "Aktueller Zweig: $branch" >&2
      exit 2
    fi
    if is_protected "$branch"; then
      echo "BLOCKIERT (Projektauftrag 3.2 c): Push, waehrend HEAD auf '$branch' steht." >&2
      echo "Zuerst einen Arbeitszweig anlegen: git switch -c <zweig>" >&2
      exit 2
    fi
  fi

  # Schreibende und historienveraendernde git-Verben. rebase, reset, am, apply
  # und stash pop/apply fehlten bis zum 2026-08-25 (ausgefuehrt belegt:
  # 'git rebase', 'git reset --hard', 'git am' liefen auf main durch).
  # 'git switch -c' und 'git checkout -b' bleiben bewusst frei: sie sind der
  # vorgesehene Ausweg von main herunter. Geprueft wird der geschuetzte
  # Zielkontext (oben), damit auch 'cd <main-checkout> && git commit' und
  # 'git -C <main-worktree> commit' greifen.
  if [ "$ziel_geschuetzt" = 1 ] && printf '%s' "$cmd" | grep -Eq 'git[[:space:]]+([^|;&]*[[:space:]])?(commit|merge|revert|cherry-pick|rebase|reset|am|apply|stash[[:space:]]+(pop|apply))([[:space:]]|$)'; then
    echo "BLOCKIERT (Projektauftrag 3.2 c): schreibender git-Befehl auf einem geschuetzten Zweig (main/master)." >&2
    echo "Zuerst einen Arbeitszweig anlegen: git switch -c <zweig>" >&2
    exit 2
  fi

  # Dateiaenderung ueber die Shell in einem geschuetzten Kontext (Befund der
  # statischen Pruefung vom 2026-08-25: sed -i, tee und Umleitungen liefen
  # durch, waehrend dieselbe Aenderung ueber Write/Edit blockiert war; N1:
  # 'cd <main-checkout> && sed -i' lief ebenfalls durch). Geprueft wird der
  # Befehlstext; Umleitungen in fluechtige Ziele (/dev/null, /tmp,
  # Umgebungs-Tempverzeichnisse) bleiben frei. Ein Fehlalarm kostet einen
  # Versuch und der Ausweg ist immer derselbe: zuerst einen Arbeitszweig
  # anlegen. Das ist dieselbe bewusste Abwaegung wie beim Textmuster-Gate
  # insgesamt (.claude/rules/claude-konfiguration.md).
  #
  # Interpreter mit Inline-Code (python -c, perl -e/-i, node -e, ruby -e ...)
  # schreiben ueber ihre eigene Datei-API, ohne dass ein Umleitungszeichen oder
  # ein Schreib-Schluesselwort im Text steht (Befund 2026-08-25). In einem
  # geschuetzten Kontext werden sie deshalb pauschal blockiert -- eine bewusste
  # Ueberdeckung: auf main wird ohnehin nicht gearbeitet, und der Ausweg ist ein
  # Arbeitszweig. Vollstaendig ist die Textpruefung hier nicht (siehe Kopf); die
  # harte Zusicherung liegt beim serverseitigen Ruleset.
  if [ "$ziel_geschuetzt" = 1 ]; then
    bereinigt=$(printf '%s' "$cmd" | sed -E \
      -e 's/[0-9]?>&[0-9]//g' \
      -e 's/[0-9]?>>?[[:space:]]*(\/dev\/null|\/tmp\/[^[:space:]]*|"?\$\{?(TMPDIR|RUNNER_TEMP|SCRATCH[A-Z_]*)\}?[^[:space:]]*)//g')
    if printf '%s' "$bereinigt" | grep -Eq '(>>?|\btee[[:space:]]|sed[[:space:]]+-[a-zA-Z]*i|\b(mv|cp|rm|mkdir|touch|truncate|ln|install|patch|dd)[[:space:]]|\b(python[0-9.]*|perl|ruby|node|deno|php|Rscript)[[:space:]]+([^|;&]*[[:space:]]+)?-[a-zA-Z]*(c|e|i|p|r|n)([^a-zA-Z]|$)|\b(ed|ex)[[:space:]])'; then
      echo "BLOCKIERT (Projektauftrag 3.2 c): Shell-Befehl mit moeglicher Schreibwirkung in einem geschuetzten Kontext (main/master)." >&2
      echo "Dateien werden auf einem Arbeitszweig geaendert, nie auf main." >&2
      echo "Anlegen mit: git switch -c <zweig>   danach den Befehl wiederholen." >&2
      echo "Fluechtige Ziele (/dev/null, /tmp) sind von dieser Pruefung ausgenommen." >&2
      exit 2
    fi
  fi
  exit 0
fi

# Dateiaendernde Werkzeuge
is_protected "$branch" || exit 0

fp=$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_input.notebook_path // .tool_input.path // empty')
[ -n "$fp" ] || exit 0
case "$fp" in
  "$proj"/*) rel="${fp#"$proj"/}" ;;
  /*)        exit 0 ;;
  *)         rel="$fp" ;;
esac

echo "BLOCKIERT (Projektauftrag 3.2 c): Schreibzugriff auf '$rel', waehrend HEAD auf '$branch' steht." >&2
echo "Entwickelt wird auf einem Arbeitszweig, nie direkt auf main." >&2
echo "Anlegen mit: git switch -c <zweig>   danach die Aenderung wiederholen." >&2
exit 2
