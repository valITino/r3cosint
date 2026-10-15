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
# Nachtrag 2026-10-14 (Posten 1, ADR 0002, 6.13 c, Fortschreibung vom
# 2026-10-14): Gedeckt ist jeweils, was keine der Grenzen in diesem Kopf
# ausnimmt und kein offener Posten unter R3-Q-010 betrifft. Fuer das Anlegen
# eines Arbeitsbaums auf main sind das namentlich GM-5, GM-6, GM-7 und GM-8
# und die Posten 4 (Befehlskette, Zeilenfortsetzung, Basename-Form) und 5
# (grosse Eingabe), fuer Mirror-/Wildcard-Pushes GM-5, GM-6 und GM-8 und die
# Posten 4 (Zeilenfortsetzung) und 5.
# Nicht gedeckt ist der untergeordnete Shell-Aufruf mit Kontextwechsel
# ('bash -c "cd x; ..."', 'sh -c ...'), siehe die Grenze im Rumpf (N-9).
#
# VORAUSSETZUNG git: Fehlt git selbst, kann das Gate nicht pruefen und
# blockiert (Rueckgabewert 2), analog zur jq-Wache. Ist git vorhanden, aber es
# gibt keinen Arbeitsbaum -- etwa ausserhalb eines Repositories --, bleibt
# Rueckgabewert 0: eine bewusste Grenze, denn ohne Repository gibt es keinen
# Zweig, der main/master sein und geschuetzt werden koennte.
#
# Seit E4.3 (Backlog R3-Q-010, ADR 0002 6.13 g) gilt zusaetzlich: eine
# Eingabe, die sich nicht als JSON-Objekt mit einem Objekt tool_input lesen
# laesst, blockiert mit Rueckgabewert 2 und einer Meldung auf stderr, die die
# nicht lesbare Eingabe ueber ihren Anfang und ihre Laenge benennt (ST-13,
# fail-closed wie die jq-/git-Wache; ADR 0002, 6.13 b). Vorher lief eine
# leere, syntaktisch ungueltige oder mit tool_input als Zeichenkette
# versehene Eingabe still mit Rueckgabewert 0 durch. Das Prototyp-Gate
# (.claude/hooks/block-prototype-import.sh) fuehrt seit E4.3 dieselbe
# Befehlsklasse mit Schreibwirkung wie dieses Gate (dort das mit "bereinigt"
# gepruefte Muster, ST-09).
#
# Seit Posten 1 (2026-10-14, ADR 0002, 6.13 c) gilt zusaetzlich: Die Ziele von
# push und 'worktree add' werden nach dem Entfernen von Anfuehrungszeichen,
# Rueckstrichen und Zeilenfortsetzungen (Rueckstrich am Zeilenende, DT-B2-04)
# sowie des Dollarzeichens vor einem Anfuehrungszeichen (DT-B2-07) verglichen
# (cmd_ziel im Rumpf; L01 bis L03 des Pruefmittels, DT-E41-04), und die
# Ausnahme fuer -b/-B greift nicht, wenn der neue Zweig selbst main oder master
# heisst, getrennt oder angehaengt (-B main, -Bmain, -fBmain; DT-B2-03), L04.
# Der Schritt ist rein lexikalisch. Das Verb (push, 'worktree add'), die
# Sammel-Push-Optionen und die Ausnahme selbst liest das Gate weiter am
# Befehlstext, nicht an cmd_ziel (DT-B2-01, DT-B2-02; Grenze GM-8).
#
# GRENZE DER AUSWERTUNG, ehrlich benannt:
# benannt seit Posten 1 (2026-10-14, ADR 0002, 6.13 c): Ziele, die erst durch
# die Auswertung der Shell entstehen, werden nicht erkannt -- eine Variable
# ('b=main; git push origin $b'), eine Befehlssubstitution ($(...)), eval, eine
# Brace-Expansion. Was erst die Auswertung der Shell ergibt, bleibt unerkannt --
# Escape-Folgen in $'...' wie $'\x6dain' oder $'\155ain' und die Uebersetzung
# von $"..." ueber einen Meldungskatalog. Ohne Escape-Folge sind $'...' und
# $"..." lexikalisch: Das $ unmittelbar vor dem Anfuehrungszeichen entfaellt mit
# diesem (Posten 1, DT-B2-07). Die Pruefung ist lexikalisch, ohne Expansion:
# erkannt wird, was der Befehlstext selbst als Wort main oder master traegt,
# auch bei Anfuehrungszeichen, Rueckstrichen und Zeilenfortsetzungen
# (Rueckstrich am Zeilenende, DT-B2-04) im Wort. Gemessen wird die Grenze mit
# der Fallklasse GM-5 in scripts/pretooluse-gates-selbsttest.sh.
#
# GRENZE AN DER SCHNITTSTELLE (Werkzeugname), ehrlich benannt:
# benannt seit Posten 1 (2026-10-14, ADR 0002, 6.13 c): Festgeschrieben im
# Nachtrag vom 2026-09-23, laeuft der Bash-Zweig nur, wenn tool_name genau
# "Bash" lautet; unter einem anderen Namen wird ein Befehlstext nicht als
# Befehl geprueft (ZF10a, ZF10b des Pruefmittels, Fallklasse GM-6). Den
# Werkzeugnamen setzt der Harness, nicht das Modell. Ein weiteres
# Befehlswerkzeug im Matcher ist Gegenstand von ADR 0002, O-28.
#
# GRENZE DER AUSNAHME FUER -b/-B, ehrlich benannt:
# benannt seit Posten 1 (2026-10-14, ADR 0002, 6.13 c, Fortschreibung vom
# 2026-10-14): Die Ausnahme fuer -b/-B liest das Gate, wie schon vor Posten 1,
# am Text, nicht an der Syntax der Shell: Steht -b oder -B in
# Anfuehrungszeichen ('git worktree add "/tmp/a -b x" main') oder in einem
# Kommentar ('git worktree add /tmp/wt main # -b x'), greift die Ausnahme,
# obwohl der Arbeitsbaum auf main entsteht (DT-B2-05).
# Quotierung und Kommentar zu unterscheiden hiesse, die Token-Erkennung der
# Shell nachzubilden; jede Naeherung mit Mustern oeffnete neue Fehlalarme (eine
# Option in Anfuehrungszeichen wie "-b" x, eine Raute in einem Argument vor -b,
# -b nach dem Pfad). Gemessen wird die Grenze mit der Fallklasse GM-7 in
# scripts/pretooluse-gates-selbsttest.sh. Keine Grenze, sondern eine belegte
# Luecke ist, dass ein -b/-B in einem anderen worktree-add-Befehl derselben
# Eingabe die Sperre fuer alle aufhebt
# ('git worktree add -b x /tmp/w1 main; git worktree add /tmp/w2 main');
# sie ist als Posten 4 unter R3-Q-010 terminiert.
# Dieselbe Grenze gilt in der sperrenden Richtung, als benannter Preis: Den
# Namen hinter -b/-B prueft das Gate ebenfalls am Text, auf cmd_ziel, weil
# L04 selbst '-B "main"' ist. Nennt ein Befehl, den das Gate schon vor
# Posten 1 als 'worktree add' las, -b main oder -B main nur als Inhalt -- in
# einer Commit-Meldung, einem Suchmuster, einem Pfad in Anfuehrungszeichen
# oder einem Kommentar ('git commit -m "Doku: worktree add -b main"',
# 'git worktree add -b feature "/tmp/a -B main"') --, blockiert das Gate
# (B2-PM-14). Derselbe Inhalt ohne -b/-B blockierte schon vorher
# ('git commit -m "Doku: git worktree add /tmp/wt main"'). Eine engere
# Fassung, die nur einen git-Aufruf am Befehlsanfang zaehlt, liesse L04 hinter
# einem vorangestellten Befehl offen ('env git worktree add -B main /tmp/wt').
# Ausweg: eine Commit-Meldung mit dem Write-Werkzeug in eine Datei schreiben
# und 'git commit -F <datei>' verwenden; Pfad oder Kommentar ohne -b/-B main
# schreiben. Gemessen wird der Preis mit Faellen der Fallklasse GM-7 mit
# Soll 2 und dem Vermerk "Preis".
#
# GRENZE AM BEFEHLSTEXT (Verb und Sammel-Push-Optionen), ehrlich benannt:
# benannt seit Posten 1 (2026-10-14, ADR 0002, 6.13 c, Fortschreibung vom
# 2026-10-14): Das Verb (push, 'worktree add') und die Optionen des
# Sammel-Push (--mirror, --all, Wildcard-Refspec) prueft das Gate am
# Befehlstext, ohne Anfuehrungszeichen und Rueckstriche zu entfernen. Steht
# das Verb oder eine solche Option in Anfuehrungszeichen oder hinter einem
# Rueckstrich ('git pu"sh" origin main', 'git push origin "--all"',
# "git push origin '*:*'", 'git push "--mirror" origin'), wird der Befehl
# nicht erkannt (DT-B2-08). Anders als bei den Zielen wertet das Gate hier ein
# Anfuehrungszeichen neben dem Wort nicht; es zu entfernen liesse Text in
# Anfuehrungszeichen als Verb oder Option zaehlen und oeffnete neue Fehlalarme
# ('git push origin feature -o "ci.variable=X --all"'). Nicht zu dieser
# Grenze gehoert die Zeilenfortsetzung: dass sie das Verb trennt
# ('git \' + Zeilenumbruch + 'push origin main', DT-B2-09), ist eine belegte
# Luecke, terminiert als Posten 4 unter R3-Q-010. Gemessen wird die Grenze mit
# der Fallklasse GM-8 in scripts/pretooluse-gates-selbsttest.sh.
#
# Rueckgabewert 2 blockiert. Rueckgabewert 1 blockiert NICHT (3.4).
set -uo pipefail

if ! command -v jq >/dev/null 2>&1; then
  echo "Gate main-schutz: jq ist nicht installiert; das Gate kann nicht pruefen." >&2
  echo "Installieren (z.B. 'apt-get install -y jq') oder das Gate bewusst entfernen." >&2
  exit 2
fi

if ! command -v git >/dev/null 2>&1; then
  echo "Gate main-schutz: git ist nicht installiert; das Gate kann nicht pruefen." >&2
  echo "Installieren (z.B. 'apt-get install -y git') oder das Gate bewusst entfernen." >&2
  exit 2
fi

input=$(cat)

# ST-13: die Eingabe muss ein JSON-Objekt mit einem Objekt tool_input sein,
# sonst kann das Gate nicht pruefen und blockiert fail-closed wie die
# jq-/git-Wache oben (ADR 0002, 6.13 b).
if ! printf '%s' "$input" | jq -es 'length == 1 and (.[0] | type == "object" and (.tool_input | type == "object"))' >/dev/null 2>&1; then
  echo "Gate main-schutz: Eingabe nicht auswertbar (kein JSON-Objekt mit einem Objekt tool_input); das Gate kann nicht pruefen und blockiert (ADR 0002, 6.13 b)." >&2
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

git -C "$proj" rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0
branch=$(git -C "$proj" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
[ -n "$branch" ] || exit 0

is_protected() { [ "$1" = "main" ] || [ "$1" = "master" ]; }

tool=$(printf '%s' "$input" | jq -r '.tool_name // empty')

if [ "$tool" = "Bash" ]; then
  cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty')
  [ -n "$cmd" ] || exit 0

  # Posten 1 unter R3-Q-010 (2026-10-14, ADR 0002, 6.13 c, Nachtrag vom
  # 2026-09-23): Die Ziele von push und worktree werden nach dem Entfernen von
  # Anfuehrungszeichen, Rueckstrichen und Zeilenfortsetzungen (Rueckstrich am
  # Zeilenende, DT-B2-04) sowie des Dollarzeichens vor einem Anfuehrungszeichen
  # (DT-B2-07) verglichen, denn die Shell macht aus ma"in", "ma"in, ma\in,
  # ma\<Zeilenumbruch>in, $'main' und ma$'in' das Wort main (L01 bis L03 des
  # Pruefmittels, DT-E41-04, DT-B2-04, DT-B2-07). cmd_ziel entsteht in vier
  # Schritten, in dieser Reihenfolge: 1. Jedes Paar aus Rueckstrich und
  # Zeilenumbruch faellt weg, vor dem eine ungerade Zahl von Rueckstrichen steht
  # (Zeilenfortsetzung, DT-B2-04; nur das Paar -- ein maskierter Rueckstrich vor
  # dem Zeilenumbruch setzt die Zeile nicht fort, und andere Zeilen werden nicht
  # zusammengezogen). 2. Die uebrigen Rueckstriche fallen weg, das folgende
  # Zeichen bleibt. 3. Ein Dollarzeichen unmittelbar vor einem
  # Anfuehrungszeichen faellt weg (Dollar-Anfuehrungszeichen, ohne Escape-Folge
  # lexikalisch, DT-B2-07). 4. Die Anfuehrungszeichen fallen weg. Der Schritt
  # ist rein lexikalisch; was erst die Auswertung der Shell ergibt, bleibt
  # unerkannt (Grenze der Auswertung im Kopf). cmd_ziel dient NUR dem Vergleich
  # der Ziele und des Namens hinter -b/-B: ziel_hat prueft ein Zielmuster gegen
  # den Befehlstext, wie er ist, UND gegen cmd_ziel -- beide Fassungen zaehlen,
  # damit nichts entsperrt wird, was vor Posten 1 gesperrt war. Das Verb (push,
  # worktree add), die Sammel-Push-Optionen und die Ausnahme fuer -b/-B laufen
  # auf dem Befehlstext, nicht auf cmd_ziel: auf cmd_ziel galte ein Wort wie
  # "push" in Anfuehrungszeichen als Verb ('git log --grep "push"', DT-B2-01),
  # maskierte Leerzeichen in einem Pfad liessen die Ausnahme greifen ('git
  # worktree add /tmp/a\ -b\ x main', DT-B2-02), und der Dollar-Schritt machte
  # aus "/tmp/x $'-b' y" ein -b ('git worktree add "/tmp/x $'-b' y" main', A75
  # des Pruefmittels). Die Aufloesung des Kontexts weiter unten und die Pruefung
  # der Schreibwirkung bleiben ebenfalls auf cmd. Der Anker 'worktree add' der
  # Namenspruefung liegt auf cmd_ziel; wt_add am Befehlstext ist nur
  # Vorbedingung (Preis GM-7, Kopfkommentar).
  cmd_ziel=$(printf '%s' "$cmd" | sed -E ':a; /(^|[^\\])(\\\\)*\\$/ { $!{ N; s/\\\n//; ba } }' | sed -E 's/\\(.)/\1/g; s/\$(["'\''])/\1/g; s/["'\'']//g')
  ziel_hat() {
    printf '%s' "$cmd" | grep -Eq "$1" || printf '%s' "$cmd_ziel" | grep -Eq "$1"
  }

  # Einen zweiten Arbeitsbaum auf main/master anzulegen ist ein Weg, spaeter an
  # main vorbeizuschreiben. 'git worktree add <pfad> main' checkt main direkt
  # aus und wird gesperrt; 'git worktree add -b <neuerzweig> <pfad> main' zweigt
  # dagegen einen NEUEN Zweig von main ab und checkt diesen aus -- das ist
  # zulaessig und darf nicht blockieren (Falsch-Positiv-Befund 2026-08-25).
  # Die Ausnahme gilt nur fuer einen neuen Zweig mit anderem Namen: heisst der
  # Name hinter -b/-B selbst main oder master -- getrennt oder angehaengt (-B
  # main, -Bmain, -fBmain; DT-B2-03) --, greift sie nicht. -b legt dann einen
  # Zweig main an, -B setzt einen bestehenden auf den Ausgangspunkt zurueck und
  # checkt ihn im neuen Arbeitsbaum aus -- genau die Wirkung, die diese Sperre
  # verhindern soll (seit Posten 1, 2026-10-14; L04, A56, A57 und A59 bis A61
  # und A73 des Pruefmittels). Der Name wird auf cmd_ziel gelesen; die Ausnahme
  # selbst liest den Befehlstext, nicht die Syntax der Shell (Grenze GM-7 im
  # Kopf). Ein -b/-B in einem anderen worktree-add-Befehl derselben Eingabe hebt
  # die Sperre fuer alle auf (Posten 4 unter R3-Q-010, DT-B2-05 c; L17).
  wt_add=0
  if printf '%s' "$cmd" | grep -Eq 'git[[:space:]]+([^|;&]*[[:space:]])?worktree[[:space:]]+add([[:space:]]|$)'; then
    wt_add=1
  fi
  if [ "$wt_add" = 1 ] \
      && printf '%s' "$cmd_ziel" | grep -Eq 'git[[:space:]]+([^|;&]*[[:space:]])?worktree[[:space:]]+add[^|;&]*[[:space:]]-[a-zA-Z]*[bB][[:space:]]*(main|master)([[:space:]]|$|[;&|)])'; then
    echo "BLOCKIERT (Projektauftrag 3.2 c): neuer Zweig main/master in einem zweiten Arbeitsbaum." >&2
    echo "Die Ausnahme fuer -b/-B gilt nur fuer einen neuen Zweig mit anderem Namen als main/master;" >&2
    echo "-B setzt einen bestehenden Zweig zurueck und checkt ihn im neuen Arbeitsbaum aus. Abzweigen:" >&2
    echo "  git worktree add -b <zweig> <pfad> main" >&2
    exit 2
  fi
  if [ "$wt_add" = 1 ] \
      && ! printf '%s' "$cmd" | grep -Eq 'worktree[[:space:]]+add[^|;&]*[[:space:]]-[bB]([[:space:]]|=)' \
      && { ziel_hat '(^|[[:space:]"'\''(])(main|master)([[:space:]]|$|["'\'';&|)])' \
           || ziel_hat 'refs/(heads|for)/(main|master)'; }; then
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
  # BEWUSSTE GRENZE, seit E4.3 praezisiert (N-9): eine Subshell in Klammern
  # '(cd x; ...)' WIRD erkannt -- die oeffnende Klammer steht in der
  # Zeichenklasse vor cd/pushd/git -C/env -C weiter unten. NICHT erkannt wird
  # der untergeordnete Shell-Aufruf (bash -c, sh -c), etwa 'bash -c "cd x; ..."'
  # bzw. 'sh -c ...',
  # oder ein in ein anderes Programm verlagerter Kontextwechsel: das ist mit
  # Textpruefung nicht sicher erkennbar. Das ist die im Kopf benannte Grenze;
  # die harte Zusicherung liefert das serverseitige Ruleset, nicht dieses
  # Gate.
  if is_protected "$branch"; then ziel_geschuetzt=1; else ziel_geschuetzt=0; fi
  while IFS= read -r kp; do
    [ -n "$kp" ] || continue
    kb=$(git -C "$kp" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
    if is_protected "$kb"; then ziel_geschuetzt=1; fi
    # Relative Pfade zusaetzlich gegen CLAUDE_PROJECT_DIR aufloesen. 'git -C'
    # loest relativ zum CWD DIESES Hook-Prozesses auf, nicht zu dem, in dem der
    # gepruefte Befehl laufen wird -- steht der Hook-Prozess anderswo, ginge
    # 'cd ../main-klon && git commit' durch (ausgefuehrt belegt am 2026-08-25:
    # CWD=Projektbaum -> blockiert, CWD=/ -> nicht blockiert). Der Projektbaum
    # ist der beste verfuegbare Anker; welchen CWD der Harness dem Hook gibt,
    # ist von hier nicht feststellbar. Absolute Pfade sind davon nicht betroffen.
    case "$kp" in
      /*) ;;
      *)  kb=$(git -C "$proj/$kp" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "")
          if is_protected "$kb"; then ziel_geschuetzt=1; fi ;;
    esac
  done < <(printf '%s' "$cmd" \
    | grep -oE '(^|[;&|[:space:](])(cd|pushd|git[[:space:]]+-C|env[[:space:]]+-C)[[:space:]]+("[^"]+"|'\''[^'\'']+'\''|[^[:space:];&|)]+)' \
    | sed -E 's/^[;&|( [:space:]]*(cd|pushd|git[[:space:]]+-C|env[[:space:]]+-C)[[:space:]]+//; s/^"//; s/"$//; s/^'\''//; s/'\''$//')

  # push mit ausdruecklichem Ziel main/master, auch als HEAD:main, in der
  # vollqualifizierten Ref-Form HEAD:refs/heads/main oder mit --force.
  # Die Ref-Form braucht ein eigenes Muster: im allgemeinen Muster darf vor
  # main kein '/' stehen, sonst wuerde jeder Zweigname wie 'fix/main-seite'
  # blockiert. Befund der statischen Pruefung vom 2026-08-25 (ausgefuehrt:
  # 'git push origin HEAD:refs/heads/main' von einem Arbeitszweig lief durch).
  # Posten 1 (DT-B2-01): Verb und Sammel-Push-Optionen liest das Gate am
  # Befehlstext, wie vor Posten 1; nur die Ziele zaehlen auch an cmd_ziel.
  # Verb oder Option in Anfuehrungszeichen bleibt unerkannt (Grenze GM-8,
  # Kopfkommentar); das durch eine Zeilenfortsetzung getrennte Verb ist
  # Posten 4 (DT-B2-09).
  if printf '%s' "$cmd" | grep -Eq 'git[[:space:]]+([^|;&]*[[:space:]])?push([[:space:]]|$)'; then
    # --mirror, --all und Wildcard-Refspecs uebertragen alle lokalen Zweige,
    # darunter main, ohne 'main' im Text zu nennen (Befund 2026-08-25).
    if printf '%s' "$cmd" | grep -Eq '(^|[[:space:]])(--mirror|--all)([[:space:]]|$)' \
        || printf '%s' "$cmd" | grep -Eq 'refs/heads/\*|[[:space:]:+]\*:|:\*([[:space:]]|$)'; then
      echo "BLOCKIERT (Projektauftrag 3.2 c): Sammel-Push (--mirror/--all/Wildcard) uebertraegt auch main." >&2
      echo "Nur den Arbeitszweig ausdruecklich pushen: git push -u origin <zweig>" >&2
      exit 2
    fi
    if ziel_hat '(^|[[:space:]:+"'\''(])(main|master)([[:space:]]|$|["'\'';&|)])' \
        || ziel_hat 'refs/(heads|for)/(main|master)([[:space:]]|$|["'\'';&|)])'; then
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
  # insgesamt (.claude/rules/claude-konfiguration.md). Ein Ziel mit '..'
  # faellt nicht unter die Ausnahme, '/dev/null' nur mit Wortgrenze
  # (DT-E43-6, behoben am 2026-09-23).
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
      -e 's/[0-9]?>>?[[:space:]]*\/dev\/null([[:space:]]|$|[;|&)])/\1/g' \
      -e 's/[0-9]?>>?[[:space:]]*(\/tmp\/([^[:space:].;|&)]|\.[^.[:space:];|&)])*|"?\$\{?(TMPDIR|RUNNER_TEMP|SCRATCH[A-Z_]*)\}?([^[:space:].;|&)]|\.[^.[:space:];|&)])*)([[:space:];|&)]|$)/\5/g')
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
