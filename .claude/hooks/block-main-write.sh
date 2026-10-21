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
# Seit Posten 5 (2026-10-21, ADR 0002, 6.13 c, SR-001 des Schwachstellenregisters)
# gilt zusaetzlich: Jede Pruefung eines Textes mit 'grep -q' (push-Erkennung,
# Sammel-Push, Ziele, Verb 'worktree add', Namen hinter -b/-B,
# schreibende git-Verben, Schreibwirkung, Basename-Form) laeuft ueber die
# Hilfsfunktion trifft (im Rumpf), nicht mehr ueber 'printf | grep -Eq'. Nicht ueber
# trifft laufen die Zaehlung der Abschnitte (anzahl, grep -Ec), die Ausnahme fuer -b/-B (die
# Adresse des sed, das die Ausnahme-Abschnitte abzieht; ST-C2-D-04), die Aufloesung der
# Kontextpfade (grep -o im Prozess-Ersatz, ohne Rueckgabewert-Pruefung) und die
# Schritte mit sed, tr und jq; die Schritte von Posten 4 pruefen ihren Rueckgabewert
# einzeln (pruefung_unmoeglich), die uebrigen nicht.
# GRUND: Unter 'set -uo pipefail' liefert die Pipeline aus printf und 'grep -q'
# den Wert 141 (SIGPIPE), wenn grep nach einem fruehen Treffer endet, waehrend
# printf noch schreibt; die Bedingung galt dann als nicht erfuellt, und der Befehl
# lief durch (B2-GATE-D05, DT-B2-10: ab etwa 64 KiB zufaellig, ab 128 KiB sicher).
# Gemessen am 2026-10-21 vor dem Bau: L20 und A80 bis A84 gaben bei einer
# Kommentarzeile aus 200000 Zeichen Rueckgabewert 0. Posten 5 ist damit
# geschlossen; die Aufzaehlung offener Posten im Nachtrag vom 2026-10-14 oben
# gilt ohne ihn.
# FORM: dieselben Muster, dieselbe Pipeline; den Status liefert aber grep
# (PIPESTATUS), nicht die Pipeline. grep 0 ist ein Treffer, auch wenn der Schreiber
# mit 141 endete. grep 1 gilt nur als kein Treffer, wenn der Schreiber ganz
# geschrieben hat (Status 0). Jeder andere Ausgang -- ein Fehler von grep, ein
# Fehler des Schreibers ohne Treffer -- endet mit Rueckgabewert 2 und einer Meldung
# auf stderr, wie eine nicht auswertbare Eingabe (fail-closed). Gewaehlt nach
# Messung (200000 und 1000000 Zeichen, je 30 Laeufe): Ein Here-String braucht ab
# Pipe-Groesse eine Temp-Datei; scheitert diese (kein Platz), ist der Rueckgabewert
# 1 und von 'kein Treffer' nicht zu unterscheiden. 'grep -E' ohne -q mit Ausgabe
# nach /dev/null haengt an der Bauart von GNU grep. Die Form ist keine Auswertung
# und keine neue Erkennung. Die Vergleiche lesen die Elemente von PIPESTATUS mit
# leerem Vorgabewert (${st[1]:-}), damit ein unvollstaendiges PIPESTATUS unter
# 'set -u' nicht mit Rueckgabewert 1 und damit als Durchlass endet.
# GRENZE: Der Wettlauf zwischen printf und grep bleibt bestehen -- grep kann enden,
# bevor der Schreiber fertig ist --, entscheidet aber nicht mehr: Die Schwelle von
# etwa 64 KiB bis 128 KiB faellt aus der Entscheidung. Es bleibt die Zeitgrenze des
# Hooks in .claude/settings.json (15 s); ein Hook, der sie reisst, wird abgebrochen
# und laesst durch. Die Zeitgrenze (15 s) zieht der Harness; bis Posten 7 ohne
# Fallklasse (6.13 d, ausgenommen laut ADR 0002, 6.13 c, Nachtrag vom 2026-10-21).
# Posten 7 unter R3-Q-010 (2026-10-21, erfasst, nicht gebaut): keines der beiden Gates
# zieht eine eigene Zeitgrenze (ADR 0002, 6.12.12); eine Ueberschreitung ist ein
# Durchlass. Berichtigung Delta 2 und 3 (ST-C2-D-05, ST-C2-E-07): Eine Eingabe, die ein Lauf
# ueber 15 s braucht, ist gefunden. Eine Zeile aus 10000000 Zeichen '&' hinter 'git worktree
# add /tmp/wt feature' braucht 19,6 bis 20,8 s (drei Messreihen), weil die Abschnittsbildung
# aus jedem Trenner eine Zeile macht; ';' und '|' brauchen bei 5000000 Zeichen dieselbe
# Zeit. Sie ist Gegenstand von Posten 7 und kein Fall, denn ein Lauf braeuchte mehr als die
# Grenze von 14 s des Pruefmittels (und kostete 14 s je Lauf und je Mutation). Gemessen am
# 2026-10-21 (CPU frei, ganzes Gate, Zeile hinter 'git worktree add /tmp/wt feature'): '&'
# 150000 Zeichen 0,3 s, 1000000 Zeichen 1,5 bis 1,7 s, 5000000 Zeichen 7,8 bis 8,9 s, 7000000 Zeichen
# 11,8 s, 8000000 Zeichen 14,2 s, 9000000 Zeichen 17,2 s, 10000000 Zeichen 19,6 bis 20,8 s
# (mehr als linear; ueber 14 s ab 8 MB, ueber 15 s zwischen 8 und 9 MB); Kommentarzeile aus
# Rauten 1000000 Zeichen 0,7 s, 5000000 Zeichen 3,5 bis 3,6 s; 1700000 Zeilen 'x>' (5,1 MB) 7,0 bis 7,1 s;
# 400000 Zeilenfortsetzungen (2400072 Bytes: 400000 Zeilen 'x \' hinter 'git push origin main') 0,56 bis 0,62 s; bei 124
# Laeufen aus 31 Formen aus 150000 gleichen Zeichen (3 parallel) hoechstens 0,59 s (H-1,
# A116, A117; vor Delta 2: 0,47 s bei 96 Laeufen). Das Pruefmittel zieht je Gate-Aufruf eine
# eigene Grenze von 14 s und wertet eine Ueberschreitung als Durchlass (A105, MM22). Nicht
# gemessen ist die Wirkung im laufenden Harness, und nicht gemessen ist, ob der Harness
# einen Befehl dieser Groesse uebergibt.
# Fehlt grep oder sed, blockiert das Gate mit Rueckgabewert 2 und einer Meldung (S10,
# S16: fehlendes grep bzw. sed; vorher Durchlass). tr kommt nur noch im Fehlerpfad der
# Wache fuer eine nicht auswertbare Eingabe vor (Kuerzung der Eingabe in der Meldung;
# ST-C2-D-02).
#
# Seit Posten 4 (2026-10-21, ADR 0002, 6.13 c, Nachtrag vom 2026-10-14) gilt
# zusaetzlich, in drei Schritten; L17, L19 und L21 des Pruefmittels sind damit
# geschlossen, und die Aufzaehlung offener Posten im Nachtrag vom 2026-10-14 oben
# gilt ohne Posten 4. Die Schritte sind lexikalisch, ohne Auswertung.
# (b) Zeilenfortsetzung (DT-B2-09, L19). cmd_fort ist der Befehlstext, in dem nur die
#     Zeilenfortsetzungen entfernt sind (der erste Schritt von cmd_ziel). Verb (push,
#     'worktree add'), Sammel-Push-Optionen und die Ausnahme fuer -b/-B werden auf
#     cmd_fort geprueft; Anfuehrungszeichen und uebrige Rueckstriche bleiben (Grenze
#     GM-8). Zwei heutige Fehlalarme in sicherer Richtung entfallen: 'git worktree add'
#     mit Fortsetzung vor ' -b x ...' und 'git push origin feature -o x' mit
#     Fortsetzung vor '--all' (G78, G79). Preis in der Grenze GM-7 (G80): In einfachen
#     Anfuehrungszeichen setzt ein Rueckstrich vor dem Zeilenumbruch die Zeile nicht
#     fort; das Gate entfernt das Paar trotzdem und liest ein -b dahinter als Ausnahme.
#     Erweiterung der Grenze GM-7 (Entscheid des Software Architects, Option a, Delta
#     2026-10-21): -b/-B in Anfuehrungszeichen jeder Art oder im Kommentar zaehlt als
#     Ausnahme, auch wenn es erst ueber eine Zeilenfortsetzung neben worktree add rueckt
#     (G80 einfache und G92 doppelte Anfuehrungszeichen, G93 Kommentar); in doppelten
#     Anfuehrungszeichen setzt die Shell die Zeile tatsaechlich fort, im Kommentar und in
#     einfachen nicht. Nicht gewaehlt: die Fortsetzung vor der Ausnahme nicht zu entfernen
#     (G77 gaebe dann 2 statt 0, eine neue Fehlalarmklasse).
#     Die Zeilenfortsetzung wird in einem Durchgang entfernt (sed -z, Rueckstriche paarweise
#     von links); die fruehere Schleife war bei vielen Fortsetzungen quadratisch (DT-C2-01:
#     20000 Zeilen 9 s, 50000 Zeilen ueber 60 s, ueber der Hook-Grenze von 15 s).
# (a) Befehlskette (DT-B2-05 c, L17). Die Ausnahme fuer -b/-B gilt nur fuer den
#     worktree-add-Abschnitt, in dem sie steht. Abschnitte trennen ';', '&', '|' und der
#     Zeilenumbruch; der Trenner bleibt am Anfang des folgenden Abschnitts, damit ein main
#     hinter einem Trenner ('grep -E "dev|main"') wie vor Posten 4 kein Ziel ist (ST-C2-02,
#     neue Fehlalarmklasse, G95; Mutation MM23). Muster am Rest duerfen deshalb nicht am
#     Abschnittsanfang verankert sein; die Basename-Form ist es nicht (A106 bis A108).
#     Das Ziel wird im Befehlstext ohne die Abschnitte mit gueltiger
#     Ausnahme geprueft, am Befehlstext wie an cmd_ziel; der Name hinter -b/-B bleibt
#     eine Pruefung ueber die ganze Eingabe. Jeder Schritt der Abschnittsbildung wird
#     auf seinen Rueckgabewert geprueft und gegengezaehlt (nichtleere Abschnitte = Rest
#     plus Ausnahme-Abschnitte); scheitert etwas, endet das Gate mit Rueckgabewert 2,
#     nie mit einem verkleinerten Rest. PREIS in sicherer Richtung (Fallklasse KM-14,
#     'Zielpruefung am Befehlstext, nicht am Abschnitt'; A89, A90): Steht nach dem
#     Abziehen noch ein worktree add ohne Ausnahme im Text, sperrt jedes main an anderer
#     Stelle derselben Eingabe ('git worktree add /tmp/w2 feature; git log main'). Die
#     Zielpruefung laeuft am Text, weil ein Zeilenumbruch in Anfuehrungszeichen Verb und
#     Ziel trennen kann. Ausweg: getrennte Bash-Aufrufe.
# (c) Basename-Form (L21). Ein worktree-add-Abschnitt ohne Ausnahme, der nach den
#     Optionen genau ein Wort traegt, das auf /main oder /master endet, wird gesperrt:
#     'git worktree add ../main' checkt den Zweig main aus (echtes git 2.43.0). Nicht
#     gesperrt sind --detach und -d (losgeloester Arbeitsbaum) und ein zweites Wort, das
#     commit-ish ('git worktree add /tmp/wt origin/main'). Das Wort darf auch nur /main
#     sein (DT-C2-03, A110, A111). Am Abschnitt entfallen vorher ein Kommentar,
#     Umleitungen samt getrenntem Operanden (<<<, <<, <>, >, >>, <; DT-C2-04, A112 bis
#     A115) und eine schliessende Klammer.
#     PREIS (bestehende Klasse "Woerter nur als Inhalt", Fallklasse KM-17; A102, A103):
#     Die Pruefung liest Text, nicht die Syntax der Shell; 'echo "git worktree add
#     ../main" > /tmp/x.txt' sperrt wie schon 'git commit -m "Doku: git worktree add
#     /tmp/wt main"'. Ausweg: den Text mit dem Write-Werkzeug in eine Datei schreiben
#     oder 'git commit -F <datei>' verwenden.
# GRENZEN, die Posten 4 nicht schliesst (gemessen, Soll 0): Eine Option mit getrenntem
# Wert ('--lock --reason x ../main') zaehlt als zweites Wort, und ein Pfad in
# Anfuehrungszeichen zerfaellt, weil das Gate nur an Leerraum, ';', '&', '|', dem
# Zeilenumbruch, ' #' und den Umleitungszeichen zerlegt und die Token-Erkennung der
# Shell nicht nachbildet: 'git worktree add "/tmp/my wt/main"', mit Semikolon, mit ' #',
# mit '<' und mit Zeilenumbruch im Pfad (Fallklasse GM-9, G90, G91, G97 bis G100). Zur
# Aufzaehlung der Grenzen im Nachtrag vom 2026-10-14 oben (GM-5, GM-6, GM-7, GM-8):
# seit Posten 4 gehoert GM-9 dazu (ST-C2-07). Die Zaehlprobe der Abschnitte loest mit
# intakten Werkzeugen nicht aus; sie sichert nur gegen den stillen Ausfall des Abzugs
# der Ausnahme-Abschnitte (ST-C2-06). Ein
# worktree add in einer Befehlssubstitution oder in Rueckwaertsakzenten innerhalb eines
# Ausnahme-Abschnitts ('git worktree add -b x /tmp/w1 $(git worktree add /tmp/w2 main)')
# bleibt unerkannt, vor wie nach Posten 4 (Grenze der Auswertung, GM-5; G88, G89).
#
# Seit Delta 2 (2026-10-21, ADR 0002, 6.13 c, Nachtrag zu Posten 4 c; ST-C2-D-01, ST-C2-D-07,
# DT-C2-D-01) gilt zusaetzlich:
# (d) Ziffer vor dem Umleitungszeichen (ST-C2-D-07, neue Fehlalarmklasse, im Bau behoben).
#     Eine Ziffer ist nur dann ein Dateideskriptor, wenn davor Leerraum oder der Textanfang
#     steht. 'git worktree add ../main1>x' und '../x/main2>/dev/null' verloren vorher das
#     Wortende ('1>x' fiel weg, '../main' blieb) und wurden gesperrt, obwohl der
#     Arbeitsbaum nicht auf main entsteht (G102, G103; HEAD vor Posten 4: 0; Mutation
#     MM28). '../main 2>/dev/null' (A118) und '../main>x' (A119) bleiben gesperrt.
# (e) Operand in Anfuehrungszeichen (DT-C2-D-01, deckt ST-C2-D-06). Umleitung und Operand
#     werden auf dem Text mit seinen Anfuehrungszeichen entfernt (rest_roh, vor
#     ziel_normalisieren). Operand sind Woerter, Woerter in einfachen oder doppelten
#     Anfuehrungszeichen (auch mit Leerraum) und maskierte Zeichen ('a\ b'); eine am
#     Zeilenende nicht geschlossene Anfuehrung reicht bis zum Zeilenende. Vorher blieb die
#     zweite Haelfte des Operanden ('<<< "a b"', '> "/tmp/a b"') als zweites Wort stehen und
#     galt als commit-ish: die Sperre entfiel, obwohl git den Arbeitsbaum auf main anlegt
#     (A120 bis A128, A129 war schon vorher gesperrt; Mutation MM29; Gegenprobe G104). Der Schritt laeuft nur, wenn der
#     Text ein '<' oder '>' traegt (Laufzeit bei vielen Zeilen). Der erste Zielcheck (main
#     als Wort) liest rest_roh und rest_ziel unveraendert mit den Umleitungen. Der geplante
#     Eintrag zu GM-9 (ST-C2-D-06) entfaellt. Grenze GM-9 bleibt: eine Option mit
#     getrenntem Wert, auch in Anfuehrungszeichen (G106), und ein Pfad in Anfuehrungszeichen, der
#     an Leerraum, ';', '&', '|', ' #', '<' oder dem Zeilenumbruch zerfaellt (G90, G91, G97
#     bis G100).
# (f) Umgebung (ST-C2-D-01). Die Variable POSIXLY_CORRECT wird zu Beginn aus der Umgebung
#     des Gates entfernt, vor dem ersten sed (S17, Mutation MM30); siehe den Absatz vor
#     'set -uo pipefail'.
# (g) Zwei Fassungen der Basename-Form (DT-C2-E-01, Delta 3). Steht ein '<' oder '>' in einem
#     Wort in Anfuehrungszeichen vor dem Pfad ('--reason="a>b" ../main', 'X="a>b" git worktree
#     add ../main', 'git -c "k=a>b" worktree add ../main'), las die Fassung von Delta 2 die
#     schliessende Anfuehrung als offene; der Operand reichte bis zum Abschnittsende, nahm
#     den Pfad mit, und die Sperre entfiel (vor Delta 2: 2, mit Delta 2: 0; A131 bis A136).
#     Die Basename-Form laeuft deshalb in zwei Fassungen und sperrt, wenn eine trifft: die
#     Fassung von Delta 2 (basis_text) und die Fassung davor (basis_alt: Umleitung samt einem
#     unquotierten Wort auf dem Text ohne Anfuehrungszeichen, mit der Deskriptor-Bedingung aus
#     (d)). Die zweite Fassung fuegt nur Sperren hinzu; G102 und G103 bleiben unter beiden 0,
#     A120 bis A128 bleiben unter der ersten 2 (Gegenproben G107, G108; Mutation MM31; MM19
#     zielt auf die Bedingung beider Fassungen). Geschlossen ist damit nur die Form mit dem
#     Zeichen in der Wortmitte (A131 bis A136); ein '<' oder '>' als LETZTES Zeichen eines
#     solchen Worts ('--reason="a>" ../main', G111) und ';', '&', '|' oder ein Zeilenumbruch in
#     einem solchen Wort (G112) bleiben Durchlaesse (GM-9, siehe die Grenze weiter unten).
# (h) Deskriptor-Variable (DT-C2-E-02): Ein Wort '{name}' vor dem Umleitungszeichen ist wie
#     eine Ziffer ein Dateideskriptor ('git worktree add ../main {fd}>/dev/null', A130;
#     Mutation MM32). Maskierte Anfuehrung (ST-C2-E-02): In doppelten Anfuehrungszeichen
#     gehoert ein maskiertes Zeichen zum Operanden ('> "a \" b"', '<<< "a\"b c"', A137,
#     A138; Mutation MM33); in einfachen Anfuehrungszeichen ist der Rueckstrich kein
#     Maskierzeichen, dort bleibt das Muster. Seit Delta 4 (ST-C2-F-01) ist ein Rueckstrich
#     in doppelten Anfuehrungszeichen nur als Paar mit dem folgenden Zeichen oder unmittelbar
#     vor dem Zeilenende zugelassen; ein maskiertes Anfuehrungszeichen kann nicht mehr als
#     Rueckstrich plus schliessendes Anfuehrungszeichen gelesen werden (Mischlesung, die in
#     Delta 3 einen Pfad hinter dem Operanden verschluckte: A143 bis A145, G109; Mutation MM34).
# (i) PREIS in sicherer Richtung (ST-C2-E-01, Klasse KM-17): Schliesst ein Operand in
#     Anfuehrungszeichen erst hinter einem Zeilenumbruch oder hinter ';', '&' oder '|'
#     ('git worktree add ../main <<< "a c' + Zeilenumbruch + 'b" feature', '> "a c;b" feature'),
#     steht das commit-ish in einem anderen Abschnitt; die Basename-Pruefung sieht es nicht
#     und sperrt (A139, A140; vor Delta 2: 0). Ausweg: den Operanden ohne Zeilenumbruch und
#     ohne ';', '&', '|' schreiben. Dasselbe gilt fuer ein Wort in Anfuehrungszeichen mit '<'
#     oder '>' HINTER dem Pfad, dem ein commit-ish oder --detach folgt ('git worktree add
#     ../main --lock --reason="a>b" feature', A141, A142; vor Delta 2: 0). Ebenso ein '<' oder
#     '>' als letztes Zeichen eines solchen Worts unmittelbar vor --detach oder -d
#     ('--reason="a>" --detach ../main', A149; vor Delta 2: 2, mit Delta 2: 0): die zweite
#     Fassung liest --detach als Operanden.
# GRENZE DER UMLEITUNGS-ERKENNUNG (Delta 3 und 4; DT-C2-E-01, DT-C2-E-02, ST-C2-F-02,
#     DT-C2-F-01, DT-C2-F-02): Das Gate erkennt
#     Umleitungen mit Einzelmustern, nicht durch Zerlegung des Befehls in Woerter wie die
#     Shell. Je Pruefrunde fand sich eine weitere Wortform (Operand in Anfuehrungszeichen,
#     Ziffer am Wortende, '<' oder '>' in einem Wort in Anfuehrungszeichen vor dem Pfad,
#     '{fd}', maskierte Anfuehrung); das folgt aus Mustern statt Tokenisierung und wird hier
#     benannt, nicht mit einem weiteren Muster beantwortet. Gemessen und ohne Sperre (Soll 0):
#     eine Befehlssubstitution als Operand ('<<< $(echo a b)', G105, Grenze GM-5), eine
#     Option mit getrenntem Wert auch in Anfuehrungszeichen ('--reason="a b" ../main', G106,
#     Grenze GM-9) und, Soll 0 unter GM-9 (Delta 4): die Verbindung beider Fehlformen (ein
#     Wort in Anfuehrungszeichen mit '>' vor dem Pfad UND ein Operand in Anfuehrungszeichen
#     mit Leerraum dahinter, G110), ein '<' oder '>' als letztes Zeichen eines Worts in
#     Anfuehrungszeichen vor dem Pfad ('--reason="a>" ../main', G111) und ';', '&', '|' oder
#     ein Zeilenumbruch in einem solchen Wort ('--reason="a;b" ../main', G112). Seit Delta 4
#     wird das Operandenmuster nicht mehr erweitert (Projektauftrag 3.4: das Kriterium Posten
#     4 c ist zum dritten Mal in Pruefung). Keine neue Fallklasse.
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
# Nachtrag am 2026-10-21: geschlossen am 2026-10-21 (Posten 4 a; Absatz "Seit Posten 4"
# weiter oben, Fall L17).
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
# Nachtrag am 2026-10-21: die Zeilenfortsetzung am Verb ist geschlossen am 2026-10-21
# (Posten 4 b; Absatz "Seit Posten 4" weiter oben, Fall L19).
#
# Rueckgabewert 2 blockiert. Rueckgabewert 1 blockiert NICHT (3.4).
# Seit Delta 2 (2026-10-21, ADR 0002, 6.13 c; ST-C2-D-01): Die Variable POSIXLY_CORRECT
# wird hier aus der Umgebung des Gates entfernt, vor dem ersten sed. GNU sed liest unter
# ihr [^\n] als "nicht Rueckstrich und nicht n": Im sed-Ausdruck der Zeilenfortsetzung galten zwei
# Rueckstriche vor dem Zeilenumbruch als Fortsetzung, das -b dahinter als Ausnahme, und
# 'git worktree add '/tmp/a\\' + Zeilenumbruch + ' -b x' main' lief durch (S17, Mutation
# MM30). bash startet unter der Variable im POSIX-Modus; das Entfernen der Variable beendet
# ihn (gemessen mit 'set -o' vor und nach dem Entfernen).
unset POSIXLY_CORRECT
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

# Posten 5 (2026-10-14 erfasst, 2026-10-21 gebaut, ADR 0002, 6.13 c, SR-001):
# trifft TEXT GREP-ARGUMENTE ist die eine Stelle, an der dieses Gate einen Text mit
# 'grep -q' gegen ein Muster prueft (die Muster stehen unveraendert an den
# Aufrufstellen). Andere Pruefungen eines Musters laufen nicht ueber trifft: anzahl
# (grep -Ec), die Adressen des sed fuer die Ausnahme-Abschnitte und fuer --detach und -d
# (basis_text, basis_alt) und grep -o fuer die Kontextpfade (ST-C2-D-04, ST-C2-E-05).
# Rueckgabewert 0: Treffer, 1: kein Treffer; jeder andere Ausgang beendet das Gate
# mit Rueckgabewert 2 und einer Meldung. Grund, Form und Grenze: Kopfkommentar,
# Absatz "Seit Posten 5".
pruefung_unmoeglich() {
  echo "Gate main-schutz: Pruefung nicht moeglich ($1); das Gate kann nicht pruefen und blockiert (ADR 0002, 6.13 b)." >&2
  echo "Naechster Schritt: grep und sed im PATH pruefen (command -v grep sed) und den Befehl wiederholen; bleibt die Meldung, den Befehl in getrennte Aufrufe zerlegen." >&2
  exit 2
}
trifft() {
  local text="$1"
  local -a st
  shift
  printf '%s' "$text" | grep -Eq "$@"
  st=("${PIPESTATUS[@]}")
  [ "${st[1]:-}" = 0 ] && return 0
  [ "${st[1]:-}" = 1 ] && [ "${st[0]:-}" = 0 ] && return 1
  pruefung_unmoeglich "grep ${st[1]:-?}, Schreiber ${st[0]:-?}"
}
# anzahl TEXT GREP-ARGUMENTE: Anzahl der Zeilen mit Treffer in ANZAHL (Zaehlprobe
# der Abschnitte, Posten 4 a). Ein Fehler von grep beendet das Gate wie in trifft.
anzahl() {
  local st
  ANZAHL=$(printf '%s\n' "$1" | grep -Ec "${@:2}")
  st=$?
  [ "$st" -le 1 ] || pruefung_unmoeglich "Zaehlung, grep $st"
}

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
  # Seit Posten 4 b (2026-10-21, ADR 0002, 6.13 c): cmd_fort ist der Befehlstext, in dem
  # NUR die Zeilenfortsetzungen entfernt sind (der erste Schritt von cmd_ziel, DT-B2-04);
  # Anfuehrungszeichen und uebrige Rueckstriche bleiben. cmd_verb ist der Text, auf dem
  # Verb (push, worktree add), Sammel-Push-Optionen und die Ausnahme fuer -b/-B geprueft
  # werden (DT-B2-09; Grenze GM-8 bleibt). cmd_ziel entsteht aus cmd_fort in den
  # uebrigen drei Schritten (ziel_normalisieren). ziel_hat prueft ohne weitere
  # Argumente den Befehlstext und cmd_ziel, mit zwei Argumenten die dort genannten Texte.
  # Delta vom 2026-10-21 (DT-C2-01): cmd_fort entsteht in EINEM Durchgang. sed -z liest
  # den Text als einen Satz und die Rueckstriche paarweise von links: Rueckstrich und
  # Zeilenumbruch fallen weg, jedes andere Paar aus Rueckstrich und Zeichen bleibt, also
  # fortsetzt nur eine ungerade Zahl von Rueckstrichen vor dem Zeilenumbruch. Das ist
  # dieselbe Bedeutung wie die fruehere Schleife (:a; N; ba), die bei vielen
  # Fortsetzungen quadratisch war (20000 Zeilen 9 s, 50000 Zeilen ueber 60 s und damit
  # ueber der Hook-Grenze von 15 s; der Harness laesst dann durch). Gleichheit gegen die
  # Schleife gemessen an allen 88573 Zeichenfolgen aus Buchstabe, Rueckstrich und
  # Zeilenumbruch bis Laenge 10; verschieden nur dort, wo der Text auf Rueckstrich und
  # Zeilenumbruch endet, was hier nicht vorkommt, weil $(...) den letzten Zeilenumbruch
  # abschneidet. Ein NUL tragen Bash-Variablen nicht.
  cmd_fort=$(printf '%s' "$cmd" | sed -zE 's/\\\n|(\\[^\n])/\1/g')
  [ $? = 0 ] || pruefung_unmoeglich "Zeilenfortsetzungen"
  ziel_normalisieren() {
    sed -E 's/\\(.)/\1/g; s/\$(["'\''])/\1/g; s/["'\'']//g'
  }
  cmd_ziel=$(printf '%s' "$cmd_fort" | ziel_normalisieren)
  [ $? = 0 ] || pruefung_unmoeglich "Ziele"
  cmd_verb="$cmd_fort"
  # Seit Posten 4 b (2026-10-21), Nachtrag zu dem Absatz weiter oben, der ziel_hat die
  # Pruefung 'am Befehlstext, wie er ist' zuschreibt: Am worktree-add-Ziel ist das der Rest
  # ohne Zeilenfortsetzungen und ohne Ausnahme-Abschnitte (rest_roh), nicht der Rohtext;
  # 'git worktree add /tmp/wt foo\<Zeilenumbruch>main' ist ein Wort foomain und gibt 0
  # (vorher 2, Zielpruefung am Rohtext; gewollt, G101). Am Ziel von push bleibt der Rohtext
  # Teil der Pruefung (ziel_hat ohne Zusatzargumente): 'git push origin foo\<Zeilenumbruch>
  # main' gibt weiter 2.
  ziel_hat() {
    trifft "${2-$cmd}" -e "$1" || trifft "${3-$cmd_ziel}" -e "$1"
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
  # Seit Posten 4 (2026-10-21), Nachtrag zu den beiden Absaetzen oben: Die Ausnahme liest
  # cmd_verb, den Befehlstext ohne Zeilenfortsetzungen, und gilt je Abschnitt; ein -b/-B in
  # einem anderen Abschnitt hebt die Sperre nicht mehr auf (L17 geschlossen). -b/-B in
  # Anfuehrungszeichen jeder Art oder im Kommentar zaehlt weiter als Ausnahme, auch wenn es
  # erst ueber eine Zeilenfortsetzung neben worktree add rueckt (GM-7; G80, G92, G93).
  wt_muster='git[[:space:]]+([^|;&]*[[:space:]])?worktree[[:space:]]+add([[:space:]]|$)'
  wt_ausnahme='worktree[[:space:]]+add[^|;&]*[[:space:]]-[bB]([[:space:]]|=)'
  wt_add=0
  if trifft "$cmd_verb" -e "$wt_muster"; then
    wt_add=1
  fi
  if [ "$wt_add" = 1 ] \
      && trifft "$cmd_ziel" -e 'git[[:space:]]+([^|;&]*[[:space:]])?worktree[[:space:]]+add[^|;&]*[[:space:]]-[a-zA-Z]*[bB][[:space:]]*(main|master)([[:space:]]|$|[;&|)])'; then
    echo "BLOCKIERT (Projektauftrag 3.2 c): neuer Zweig main/master in einem zweiten Arbeitsbaum." >&2
    echo "Die Ausnahme fuer -b/-B gilt nur fuer einen neuen Zweig mit anderem Namen als main/master;" >&2
    echo "-B setzt einen bestehenden Zweig zurueck und checkt ihn im neuen Arbeitsbaum aus. Abzweigen:" >&2
    echo "  git worktree add -b <zweig> <pfad> main" >&2
    exit 2
  fi
  # Seit Posten 4 a (2026-10-21, ADR 0002, 6.13 c; DT-B2-05 c, L17): Die Ausnahme fuer
  # -b/-B gilt nur fuer den worktree-add-Abschnitt, in dem sie steht. Abschnitte trennen
  # ';', '&', '|' und der Zeilenumbruch (cmd_verb, Anfuehrungszeichen bleiben).
  # Der Trenner bleibt am Anfang des folgenden Abschnitts (vor jedem Trenner wird ein
  # Zeilenumbruch eingefuegt, Delta ST-C2-02): ein main hinter einem Trenner (etwa 'grep
  # -E "dev|main"') liegt dann nicht am Anfang eines Abschnitts und ist kein Ziel, wie vor
  # Posten 4. Muster am Rest duerfen deshalb nicht am Abschnittsanfang verankert sein; die
  # Basename-Form ist es nicht (A106 bis A108).
  # rest_roh ist der Text ohne die Abschnitte mit gueltiger Ausnahme, rest_ziel derselbe
  # Text nach ziel_normalisieren. Das Ziel wird am Rest geprueft; steht dort kein
  # worktree add mehr, gibt es nichts zu sperren. Jeder Schritt wird auf seinen
  # Rueckgabewert geprueft, und die Zaehlprobe verlangt: nichtleere Abschnitte = Rest
  # plus Ausnahme-Abschnitte. Scheitert etwas, endet das Gate mit 2, nie mit einem
  # verkleinerten Rest. Der Name main/master hinter -b/-B wird oben ueber die ganze
  # Eingabe geprueft.
  rest_roh=""
  rest_ziel=""
  if [ "$wt_add" = 1 ]; then
    abschnitte=$(printf '%s' "$cmd_verb" | sed 's/[;&|]/\n&/g')
    [ $? = 0 ] || pruefung_unmoeglich "Abschnittsbildung"
    rest_roh=$(printf '%s\n' "$abschnitte" | sed -E "/$wt_ausnahme/d")
    [ $? = 0 ] || pruefung_unmoeglich "Abzug der Ausnahme-Abschnitte"
    anzahl "$abschnitte" -e '[^[:space:]]'; n_alle=$ANZAHL
    anzahl "$rest_roh" -e '[^[:space:]]'; n_rest=$ANZAHL
    anzahl "$abschnitte" -e "$wt_ausnahme"; n_ausn=$ANZAHL
    [ $((n_rest + n_ausn)) -eq "$n_alle" ] || pruefung_unmoeglich "Zaehlprobe der Abschnitte: $n_alle, Rest $n_rest, Ausnahme $n_ausn"
    rest_ziel=$(printf '%s\n' "$rest_roh" | ziel_normalisieren)
    [ $? = 0 ] || pruefung_unmoeglich "Ziele der Abschnitte"
  fi
  if [ "$wt_add" = 1 ] \
      && trifft "$rest_roh" -e "$wt_muster" \
      && { ziel_hat '(^|[[:space:]"'\''(])(main|master)([[:space:]]|$|["'\'';&|)])' "$rest_roh" "$rest_ziel" \
           || ziel_hat 'refs/(heads|for)/(main|master)' "$rest_roh" "$rest_ziel"; }; then
    echo "BLOCKIERT (Projektauftrag 3.2 c): Arbeitsbaum auf main/master anlegen." >&2
    echo "Ein zweiter Arbeitsbaum auf main umgeht den Schutz. Einen neuen Zweig abzweigen:" >&2
    echo "  git worktree add -b <zweig> <pfad> main" >&2
    exit 2
  fi
  # Seit Posten 4 c (2026-10-21, ADR 0002, 6.13 c; L21): 'git worktree add <pfad>/main'
  # ohne commit-ish checkt den Zweig main aus (echtes git 2.43.0). Gesperrt wird ein
  # Abschnitt des Rests (ohne Ausnahme), der nach den Optionen genau ein Wort traegt,
  # das auf /main oder /master endet. Kein Fall sind --detach und -d (losgeloester
  # Arbeitsbaum) und ein zweites Wort (das commit-ish). Am Abschnitt entfallen vorher
  # ein Kommentar, Umleitungen und eine schliessende Klammer; mehr zerlegt das Gate nicht
  # (Grenze GM-9: eine Option mit getrenntem Wert wie --reason zaehlt als Wort).
  if [ "$wt_add" = 1 ]; then
    # Seit Delta 2 (2026-10-21, ST-C2-D-07, DT-C2-D-01), Nachtrag zu Posten 4 c: Umleitungen
    # samt Operand fallen auf dem Text mit seinen Anfuehrungszeichen weg (rest_roh), vor
    # ziel_normalisieren; erst danach entstehen basis_ziel und basis_text. Eine Ziffer vor
    # dem Umleitungszeichen ist ein Dateideskriptor nur nach Leerraum oder am Textanfang. Der
    # Schritt laeuft nur, wenn der Text ein '<' oder '>' traegt; sonst ist basis_ziel gleich
    # rest_ziel. Operatoren und Operand sind feste Muster, die Eingabe wird nicht ausgewertet.
    # Seit Delta 3 (2026-10-21, DT-C2-E-01, DT-C2-E-02, ST-C2-E-02), Nachtrag zu Delta 2: Die
    # Basename-Form laeuft in zwei Fassungen und sperrt, wenn eine trifft: basis_text (Fassung
    # von Delta 2, Umleitung samt Operand auf dem Text mit Anfuehrungszeichen; Operand: Wort,
    # Wort in Anfuehrungszeichen, maskiertes Zeichen) und basis_alt
    # (Fassung davor, Umleitung samt einem unquotierten Wort auf dem Text ohne
    # Anfuehrungszeichen, mit der Deskriptor-Bedingung); die zweite Fassung fuegt nur Sperren
    # hinzu. Ein Wort {name} vor dem Umleitungszeichen ist wie eine Ziffer ein Deskriptor.
    # In doppelten Anfuehrungszeichen gehoert ein maskiertes Zeichen zum Operanden; ein
    # Rueckstrich ist dort nur als Paar oder unmittelbar vor dem Zeilenende zugelassen, eine
    # Mischlesung (maskiertes Anfuehrungszeichen als Rueckstrich plus schliessendes) ist
    # ausgeschlossen (Delta 4, ST-C2-F-01).
    umleit='(<<<|<<-?|<>|>>|>|<)'
    deskr='([0-9]+|\{[A-Za-z_][A-Za-z0-9_]*\})'
    operand='([^[:space:]"'\''\\]|\\.|"([^"\\]|\\.)*("|\\?$)|'\''[^'\'']*('\''|$))*'
    basis_ziel="$rest_ziel"
    basis_alt=""
    if trifft "$rest_roh" -e '[<>]'; then
      basis_roh=$(printf '%s\n' "$rest_roh" | sed -E "s/(^|[[:space:]])${deskr}${umleit}[[:space:]]*${operand}/\1/g; s/${umleit}[[:space:]]*${operand}//g")
      [ $? = 0 ] || pruefung_unmoeglich "Umleitungen"
      basis_ziel=$(printf '%s\n' "$basis_roh" | ziel_normalisieren)
      [ $? = 0 ] || pruefung_unmoeglich "Ziele nach den Umleitungen"
      basis_alt=$(printf '%s\n' "$rest_ziel" | sed -E "s/[[:space:]]#.*$//; s/(^|[[:space:]])${deskr}${umleit}[[:space:]]*[^[:space:]]*/\1/g; s/${umleit}[[:space:]]*[^[:space:]]*//g; s/[[:space:]]*\)+[[:space:]]*$//; /(^|[[:space:]])(--detach|-[a-zA-Z]*d[a-zA-Z]*)([[:space:]]|$)/d")
      [ $? = 0 ] || pruefung_unmoeglich "Basename-Form, zweite Fassung"
    fi
    basis_text=$(printf '%s\n' "$basis_ziel" | sed -E 's/[[:space:]]#.*$//; s/[[:space:]]*\)+[[:space:]]*$//; /(^|[[:space:]])(--detach|-[a-zA-Z]*d[a-zA-Z]*)([[:space:]]|$)/d')
    [ $? = 0 ] || pruefung_unmoeglich "Basename-Form"
    basis_muster='git[[:space:]]+([^|;&]*[[:space:]])?worktree[[:space:]]+add([[:space:]]+-[^[:space:]]*)*[[:space:]]+([^[:space:]-][^[:space:]]*)?/(main|master)([[:space:]]+-[^[:space:]]*)*[[:space:]]*$'
    if trifft "$basis_text" -e "$basis_muster" || trifft "$basis_alt" -e "$basis_muster"; then
      echo "BLOCKIERT (Projektauftrag 3.2 c): Arbeitsbaum auf main/master anlegen (Pfad endet auf main/master, kein commit-ish)." >&2
      echo "'git worktree add <pfad>/main' ohne commit-ish checkt den Zweig main aus. Einen neuen Zweig abzweigen:" >&2
      echo "  git worktree add -b <zweig> <pfad> main" >&2
      exit 2
    fi
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
  # Nachtrag am 2026-10-21 (ST-C2-E-06): geschlossen am 2026-10-21 (Posten 4 b; Absatz "Seit Posten 4"
  # im Kopf, Fall L19).
  if trifft "$cmd_verb" -e 'git[[:space:]]+([^|;&]*[[:space:]])?push([[:space:]]|$)'; then
    # --mirror, --all und Wildcard-Refspecs uebertragen alle lokalen Zweige,
    # darunter main, ohne 'main' im Text zu nennen (Befund 2026-08-25).
    if trifft "$cmd_verb" -e '(^|[[:space:]])(--mirror|--all)([[:space:]]|$)' \
        || trifft "$cmd_verb" -e 'refs/heads/\*|[[:space:]:+]\*:|:\*([[:space:]]|$)'; then
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
  if [ "$ziel_geschuetzt" = 1 ] && trifft "$cmd" -e 'git[[:space:]]+([^|;&]*[[:space:]])?(commit|merge|revert|cherry-pick|rebase|reset|am|apply|stash[[:space:]]+(pop|apply))([[:space:]]|$)'; then
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
    if trifft "$bereinigt" -e '(>>?|\btee[[:space:]]|sed[[:space:]]+-[a-zA-Z]*i|\b(mv|cp|rm|mkdir|touch|truncate|ln|install|patch|dd)[[:space:]]|\b(python[0-9.]*|perl|ruby|node|deno|php|Rscript)[[:space:]]+([^|;&]*[[:space:]]+)?-[a-zA-Z]*(c|e|i|p|r|n)([^a-zA-Z]|$)|\b(ed|ex)[[:space:]])'; then
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
