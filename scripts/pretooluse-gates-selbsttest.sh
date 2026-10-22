#!/usr/bin/env bash
# =============================================================================
# scripts/pretooluse-gates-selbsttest.sh -- Selbsttest fuer die beiden
# PreToolUse-Gates .claude/hooks/block-main-write.sh und
# .claude/hooks/block-prototype-import.sh
# =============================================================================
#
# Bau auf Weisung vom 2026-09-22 (Backlog R3-Q-010, Stand 2026-09-22;
# Sitzungsauftrag vom 2026-09-23).
#
# Fortschreibung am 2026-10-14 (Posten 1 unter R3-Q-010, ADR 0002, 6.13 c,
# Nachtrag vom 2026-09-23): L01 bis L04 sind geschlossen (Klasse blockierend,
# Soll 2), dazu A54 bis A57 und die Gegenproben G43 bis G46; G47 bis G49 messen
# die Grenze der Auswertung. Neu: die Fallklassen KM-13, GM-5 und GM-6 und die
# Mutationen MM9 bis MM11; ZF10a und ZF10b tragen die Klasse grenze.
#
# Nachtrag am 2026-10-14 (Behebung der ersten Verifikationsrunde zu Posten 1,
# Einordnung des Software Architects nach ADR 0002, 6.13 c): Verb, Sammel-Push-
# Optionen und die Ausnahme fuer -b/-B lesen wieder den Befehlstext (DT-B2-01,
# DT-B2-02; A58, A75, G55 bis G58). Geschlossen sind angehaengte und gebuendelte
# Werte hinter -b/-B (DT-B2-03; A59 bis A61, A73; Regressionsschutz A74),
# Zeilenfortsetzungen (DT-B2-04; A62 bis A64) und das Dollarzeichen vor
# Anfuehrungszeichen (DT-B2-07; L18, A69 bis A72). Neu: die Grenze GM-7 (G59,
# G60), Posten 4 (L17) und G61 bis G64 und G68 in GM-5. Die 15 Pruefstand-Faelle
# am Prototyp-Gate haben ihre Klasse aus der Spalte Folge erhalten (ZF9
# durchlaufend, ZF10c blockierend, ZF10d und L10 bis L16 grenze, L05 bis L09
# belegte-luecke; P38 bleibt pruefstand); ZF10a und ZF10b tragen ihren frueheren
# Wortlaut wieder. Zahlen: vor Posten 1 258 Faelle, 19 Mutationen, 23
# Fallklassen; nach der ersten Fassung 269, 22 und 26; jetzt 318 Faelle, 26
# Mutationen (MM9 bis MM15) und 28 Fallklassen (KM-13, GM-5, GM-6, GM-7, GM-8
# neu). Der Mindestsatz von MM5 ist auf A40 und A41 gekuerzt: A38 und A39 fallen
# bei MM5 nicht mehr, weil cmd_ziel die Anfuehrungszeichen deckt, und A68 nicht,
# weil cmd_ziel seit dem Dollar-Schritt auch $'main' zu main macht. Die Angabe
# zum Rueckgabewert 0 im Modus --mutationen nannte vor Posten 1 irrtuemlich 15
# Mutationen (es waren 19). Die Ueberschrift 11a nannte vor Posten 1 irrtuemlich
# "Zehn Mutationen" (es waren 19). Regressionsschutz: A65, A66, A74, A75, A76.
#
# Nachtrag am 2026-10-14 (zweite Verifikationsrunde): DT-B2-08 als Grenze GM-8
# (G69, G70), DT-B2-09 als belegte Luecke von Posten 4 b (L19), Basename-Form
# als Posten 4 c (L21), grosse Eingabe als Posten 5 (L20); Preise in sicherer
# Richtung A77 (B2-GATE-D04) und A78, A79 (GM-7, B2-PM-14); G71 in GM-5
# (Meldungskatalog); L01 bis L04 tragen den frueheren Wortlaut wieder; 318
# Faelle, 26 Mutationen, 28 Fallklassen.
#
# Nachtrag am 2026-10-21 (Posten 5 und Posten 4 unter R3-Q-010, ADR 0002, 6.13 c,
# Nachtrag vom 2026-10-14; Schwachstellenregister SR-001): Zuerst die Faelle mit
# Soll, dann die Gates, zuletzt die Vermerke (ADR 0002, 6.13 g). Posten 5 (beide
# Gates, B2-GATE-D05): L20 hat Soll 2; dazu A80 bis A84 (je eine Pruefstelle des
# main-Gates), L22, B64 und B65 (Bash, Richtung 1 und Richtung 2 am Prototyp-Gate;
# vor dem Bau gaben alle 0) und die Gegenproben G72, G73, P40 und P41; S10 und S11
# messen den Zweig "Pruefung nicht moeglich" (PATH ohne grep, Soll 2), S12 die
# Abschnittsbildung von Posten 4 a (PATH ohne tr, Soll 2, Mutation MM21); Mutationen
# MM16 und MP12 (der Abbruch des Schreibers gilt wieder als kein Treffer) sowie
# MM20 und MP13 (der Zweig gibt 1 statt zu blockieren). Posten 4 am main-Gate:
# L17, L19 und L21 haben Soll 2; dazu A85 bis A88 und A101 (Befehlskette), A89 und
# A90 (Preis, Fallklasse KM-14), A91 und A92 (Zeilenfortsetzung), A93 bis A100
# (Basename-Form), A102 und A103 (Preis: Woerter nur als Inhalt, Fallklasse KM-17) und die
# Gegenproben G74 bis G77 und G81 bis G87; G78 und G79 (heutige Fehlalarme) sowie
# G80 (Preis in GM-7) wechseln von 2 auf 0; G88 und G89 (GM-5) und G90, G91 (GM-9)
# messen Grenzen. MM12 ist neu gefasst, MM17 bis MM19 sind neu. Zahlen: vor diesem
# Nachtrag 318 Faelle, 26 Mutationen, 28 Fallklassen; jetzt 372 Faelle,
# 34 Mutationen, 35 Fallklassen (neu KM-14 bis KM-18, KP-5, GM-9). Die Ausgabezeile
# kuerzt Eingaben ueber 1000 Zeichen (L20 und die uebrigen grossen Eingaben).
# Posten 6 (neu, Entscheid des Koordinators auf Einordnung des Software Architects,
# nicht gebaut): L23 und L24 messen, dass die sed- und tr-Schritte des Prototyp-Gates
# keinen Rueckgabewert pruefen; ohne sed (Bash-Weg) oder tr (Weg der Dateiwerkzeuge)
# laeuft ein mit vollem PATH gesperrter Befehl durch (Soll 0, Klasse belegte-luecke,
# terminiert mit der naechsten Aenderung am Prototyp-Gate).
#
# Nachtrag am 2026-10-21 (Delta nach der Verifikation von C2; Befunde DT-C2-01 bis
# DT-C2-05, ST-C2-01 bis ST-C2-07, H-1; Entscheide des Software Architects): Zuerst die
# Faelle mit Soll, dann die Gates, zuletzt die Vermerke (ADR 0002, 6.13 g). Jeder
# Gate-Aufruf laeuft mit einer eigenen Zeitgrenze von 14 s (unter der Hook-Grenze von
# 15 s); eine Ueberschreitung (Rueckgabewert 124 von timeout) wertet das Pruefmittel als
# Durchlass 0 und vermerkt sie in grund. DT-C2-01: A104, A105 (50000
# Zeilenfortsetzungen), G94, MM22 (alte Schleife), MM14 neu gefasst. DT-C2-02: G92, G93
# mit G80 als Preise in GM-7 (Entscheid a). ST-C2-02: G95, A106 bis A109, MM23, MM17 und
# MM12 neu gefasst. DT-C2-03: A110, A111, G96, MM26. DT-C2-04: A112 bis A115, MM27.
# DT-C2-05: PATH-Variante grep-Attrappe, S13, S14, MM24, MP14. H-1: A116, A117 (150000
# Zeichen, linear gemessen). ST-C2-03 iii: G101. ST-C2-04: G97 bis G100 (GM-9
# verallgemeinert). ST-C2-06: PATH-Varianten sed-ohne-z und sed-ohne-trenner, S15, S16,
# MM25. Zahlen: vor dem Delta 372 Faelle, 34 Mutationen, 35 Fallklassen; jetzt 400
# Faelle, 41 Mutationen, 35 Fallklassen (KM-15 bis KM-18, KP-5 und GM-9 um Faelle
# erweitert, GM-7 um G92 und G93). Berichtigung zum Nachtrag vom selben Tag oben: S12
# misst seit dem Delta die Abschnittsbildung mit einem sed, das nur diesen Aufruf
# verweigert (PATH sed-ohne-trenner, Mutation MM21), nicht mehr den Wegfall von tr: die
# Abschnitte entstehen mit sed. Posten 7 (keine eigene Zeitgrenze im Gate) ist erfasst,
# nicht gebaut, ohne Fall und ohne Fallklasse.
#
# Nachtrag am 2026-10-21 (Delta 2 nach der Re-Verifikation des Delta; Befunde ST-C2-D-01 bis
# ST-C2-D-07, DT-C2-D-01; Entscheide des Koordinators): Zuerst die Faelle mit Soll, dann die
# Gates, zuletzt die Vermerke (ADR 0002, 6.13 g). ST-C2-D-07 (neue Fehlalarmklasse, im Bau
# behoben): G102, G103 mit Soll 0, Gegenproben A118, A119, MM28. DT-C2-D-01 (deckt
# ST-C2-D-06): A120 bis A129 mit Soll 2, Gegenprobe G104, MM29; der geplante Fall mit Soll 0
# zu ST-C2-D-06 entfaellt, der Fall mit Operanden in Anfuehrungszeichen und Leerraum ist A124.
# MM27 zielt auf die Operatorliste (umleit) der neuen Fassung. ST-C2-D-01: neue PATH-Wahl
# posix (voller PATH, dazu POSIXLY_CORRECT=1 in der Umgebung des Gates), S17 (main), S18
# (Prototyp, neue Fallklasse KP-6), MM30, MP15. ST-C2-D-02 bis ST-C2-D-05: Saetze in den
# Kopfkommentaren der Gates und die Messwerte der Faelle A116 und A117 (Endstand 0,23 s und 0,21 s).
# Posten 7: Eine Eingabe ueber 15 s ist gefunden (10000000 Zeichen '&' hinter 'git worktree
# add', 19,6 s); sie ist kein Fall, weil ein Lauf die Grenze von 14 s des Pruefmittels
# uebersteigt, und bleibt Gegenstand von Posten 7. Zahlen: vor Delta 2
# 400 Faelle, 41 Mutationen, 35 Fallklassen; jetzt 417 Faelle, 45 Mutationen, 36
# Fallklassen (KM-16 um S17, KM-17 um A118 bis A129 erweitert).
# Nachtrag am 2026-10-21 (Delta 3 nach der dynamischen Pruefung und dem statischen Bericht zu
# Delta 2; Befunde DT-C2-E-01, DT-C2-E-02, ST-C2-E-01 bis ST-C2-E-08; Entscheide des
# Koordinators): Zuerst die Faelle mit Soll, dann das Gate, dann die Vermerke (ADR 0002,
# 6.13 g). DT-C2-E-01 (blockierend): A131 bis A136 mit Soll 2 (< oder > in einem Wort in
# Anfuehrungszeichen vor dem Pfad), Gegenproben G107, G108, MM31 (zweite Fassung der
# Basename-Form entfernt); MM19 zielt auf die Bedingung beider Fassungen, MM28 auf den neuen
# Wortlaut der Umleitung mit Deskriptor, MM29 auf die neue Operandenfassung. DT-C2-E-02: A130
# ({fd}>/dev/null, MM32), G105 (Befehlssubstitution, Grenze GM-5), G106 (Option mit getrenntem
# Wert in Anfuehrungszeichen, Grenze GM-9). ST-C2-E-02: A137, A138 (maskierte Anfuehrung im
# Operanden, MM33; ersetzt die Benennung von R6 als GM-5). ST-C2-E-01: A139 bis A142 als Preis in
# sicherer Richtung (KM-17). ST-C2-E-04: S19 (Bash-Weg am Prototyp-Gate mit PATH-Wahl posix),
# Vermerk zu S18 berichtigt, MP15 erwartet auch S19. ST-C2-E-08: die Erweiterung des leeren
# Arrays posix_zusatz ist gegen bash vor 4.4 unter set -u abgesichert. Zahlen: vor Delta 3
# 417 Faelle, 45 Mutationen, 36 Fallklassen; jetzt 435 Faelle, 48 Mutationen, 36 Fallklassen.
# Nachtrag am 2026-10-21 (Delta 4 nach dem statischen Bericht zu Delta 3, ST-C2-F-01 bis
# ST-C2-F-03, und der dynamischen Pruefung von Delta 3, DT-C2-F-01 bis DT-C2-F-04; das
# Kriterium Posten 4 c ist zum dritten Mal in Pruefung, nach Projektauftrag 3.4 der letzte
# Versuch): Zuerst die Faelle mit Soll, dann das Gate, dann die Vermerke (ADR 0002, 6.13 g).
# Einzige Musteraenderung: Die Klasse in doppelten Anfuehrungszeichen laesst den Rueckstrich
# nur noch unmittelbar vor dem Zeilenende zu (Mischlesung ausgeschlossen); A143 bis A146 mit
# Soll 2, G109 mit Soll 0, Mutation MM34 (Klasse von Delta 3); MM33 und MM29 tragen den neuen
# Suchtext. Weiter nur Faelle und Benennungen: G110 bis G112 (Grenze GM-9), G113, A147 und
# A148 ({fd2}, {FD}), A149 (Preis KM-17). Zahlen: vor Delta 4 435 Faelle, 48 Mutationen, 36
# Fallklassen; jetzt 447 Faelle, 49 Mutationen, 36 Fallklassen.
# Nachtrag am 2026-10-22 (C3: Posten 2, Posten 6 und Teil von Posten 7 am Prototyp-Gate unter R3-Q-010,
# ADR 0002, 6.13 c, Nachtrag vom 2026-10-21 zur Abnahme von Posten 4 und 5 -- Festlegung fuer C3):
# Zuerst die Faelle mit Soll (Lauf A gegen das unveraenderte Gate: 19 von 471 Faellen fielen, mit S28 20 von
# 473, mit S29 und S30 22 von 475, mit B72 und B73 24 von 479), dann das Gate, zuletzt die Vermerke (ADR 0002, 6.13 g). Posten 2: L05 bis
# L08 haben Soll 2 und die Klasse blockierend (Vermerk mit dem frueheren Wortlaut); je Schreibweise ein Fall
# fuer Richtung 2 (B66 bis B69, B71) und href in Richtung 1 (B70), die Gegenproben P42 bis P51 (dieselbe
# Schreibweise ohne Bezug ueber die Trennung), P52 (gewollter Durchlass, Entscheid des Software Architects vom
# 2026-10-22: import("backend") bleibt frei) und, als eigener Sachverhalt, JS-Zuweisungen an src/href mit Leerraum
# (B72, B73, Gegenproben P53, P54); Mutationen MP16 bis MP20 und MP32. Posten 6: L23 und L24
# haben Soll 2; je geprueftem sed- oder tr-Schritt ein Fall, an dem er scheitert (S20 bis S24, S29, S30; die
# Schritte, die ein fehlendes Werkzeug nicht als erste erreichen, ueber sed-Attrappen nach dem Muster von
# sed-ohne-z: sed-ohne-schleife, sed-ohne-bereinigung, sed-ohne-kommentar); Mutationen MP21 bis MP27. Weshalb
# S29 und S30 zu den Faellen der Festlegung hinzukommen: Fehlt sed ganz (L23, S23), faengt die Pruefung des
# naechsten sed-Schritts den Ausfall auf; ohne eine Attrappe, die nur den Aufruf fuer die Zeilenkommentare
# verweigert, bliebe die Pruefung des ersten Schritts (MP21, MP25) von keinem Fall erreicht und die Mutation
# unerkannt. Posten 7 (Prototyp-Gate): S25 (cat um 20 s verzoegert, Soll 2), S26 (um 4 s, Soll 0), S27 (PATH
# ohne timeout, Soll 2), S28 (timeout endet mit 125, Soll 2: Zweig "jeder andere Ausgang"); Mutationen MP28 bis
# MP31; alle PATH-Varianten fuehren jetzt timeout, ausser ohne-timeout und der Attrappe timeout-fehler.
# Neue mechanische Pruefung in fall() (Entscheid 3 des Koordinators vom 2026-10-22): Bei Soll 2 am Prototyp-
# Gate nennt die Meldung bei den PATH-Wahlen ohne-sed, sed-ohne-schleife, sed-ohne-bereinigung und
# sed-ohne-kommentar das Werkzeug mit seinem Rueckgabewert ("(sed, Rueckgabewert "), bei ohne-tr "(tr,
# Rueckgabewert ", bei langsames-cat "Zeitgrenze", bei ohne-timeout "timeout ist nicht installiert", bei
# timeout-fehler "Rueckgabewert 125". GRUND: Fehlt ein Werkzeug, schreibt die Shell selbst "command not found"
# auf stderr (vorgemessen am unveraenderten Gate: L23 282 Bytes, L24 93, S20 93, S23 188); "stderr nicht leer"
# allein unterscheidet das nicht von einer Meldung des Gates, und eine Shell-Meldung ist kein Gate-Urteil. Die
# Pruefung wirkt nur bei gate=prototyp und Soll 2 und aendert keinen bestehenden Fall (S16 am main-Gate, ebenfalls
# PATH ohne sed, besteht unveraendert). Fallklassen: GP-3 ist KP-7 (gedeckt; vormals GP-3 (grenze), seit
# 2026-10-22 gedeckt), neu GP-4 (Grenze an der Schnittstelle, ZF10d), KP-8 (Rueckgabewerte der sed- und tr-
# Schritte), KP-9 (Zeitgrenze des Gates). Zahlen: vor C3 447 Faelle, 49 Mutationen, 36 Fallklassen; jetzt 479
# Faelle, 66 Mutationen (MP16 bis MP32), 39 Fallklassen.
# "Jedes Hook-Skript wird vor dem Einbau gegen einen blockierenden und einen
# durchzulassenden Fall geprueft. Ein ungetestetes Gate ist kein Gate."
# (.claude/rules/claude-konfiguration.md, Abschnitt "Hooks")
#
# ZWEI MODI:
#   1. Normalmodus (kein Parameter): 479 vorgemessene Faelle laufen gegen die
#      Gate-Dateien DES ARBEITSBAUMS (oder, nur fuer Pruefrollen, gegen eine
#      per Umgebungsvariable ueberschriebene Kopie, siehe Abschnitt 3a weiter
#      unten). main-Faelle laufen gegen einen Wegwerf-Klon auf main, einen auf
#      master, gegen den Arbeitszweig-Klon oder gegen ein Verzeichnis ohne
#      Repository (benannte Grenze); Prototyp-Faelle laufen gegen
#      den Arbeitsbaum selbst -- immer ueber die Gate-EINGABE, nie ueber echte
#      Schreibvorgaenge: die Gates selbst schreiben nie eine Datei, sie lesen
#      JSON von der Standardeingabe und urteilen.
#   2. Modus --mutationen (Gegenprobe): zuerst eine GRUNDLINIE -- die
#      vollstaendige Fallliste gegen die UNVERAENDERTEN Gates; ist sie nicht
#      gruen, endet der Modus sofort mit Rueckgabewert 2. Danach 66 fest im
#      Skript hinterlegte Mutationen, die je GENAU EINE Sperre schwaechen oder
#      eine Ausnahme entfernen (MP4, MP5, MP32), in einer Kopie eines Gates; die
#      vollstaendige Fallliste des betroffenen Gates laeuft gegen die Kopie.
#      Erwartet: mindestens der benannte Mindestsatz an Kennungen faellt. Im
#      Mutationsmodus laeuft der Normallauf nicht.
#
# Kein Netzzugriff: die vier Klone (main-Klon, zweiter main-Klon,
# master-Klon, Arbeitszweig-Klon) sind LOKALE Klone von CLAUDE_PROJECT_DIR
# selbst. Alle Wegwerfverzeichnisse liegen unter mktemp und werden per trap
# geraeumt. Der Lauf aendert keine versionierte Datei -- das prueft er an
# sich selbst: Statusliste (inklusive ignorierter Pfade), Inhaltspruefsummen
# der versionierten UND der unversionierten, nicht ignorierten Dateien, alle
# aus der Repository-Wurzel erhoben, VOR dem Anlegen der Wegwerfumgebung und
# nach dem letzten Fall verglichen. Git-eigene Umgebungsvariablen, die den
# Gegenstand verlegen koennten, werden vor dem ersten git-Aufruf geloescht;
# Klon und Checkout laufen mit "-c core.hooksPath=/dev/null".
#
# NIEDRIGERES MASS als scripts/dod-gate-selbsttest.sh (ADR 0002, 6.13 d
# verlangt das ausdruecklich): keine Zusicherungstabelle, keine mechanischen
# mehrstufigen Deckungen, keine separate Mutationsdatei -- die Fallliste, die
# 66 Mutationen, die 39 Fallklassen der Kopfkommentare und die Zuordnung zu
# den sieben Abnahmekriterien stehen FEST im Skript (Datenteil weiter unten).
#
# Verifikation dieses Skripts UND der beiden Gates: Static und Dynamic
# Software Tester, nicht die bauende Rolle selbst (3.4). Fuer eine eigene
# Mutationsprobe der Pruefrollen: die Umgebungsvariablen
# GATE_MAIN_UEBERSCHREIBUNG und GATE_PROTOTYP_UEBERSCHREIBUNG (siehe
# Abschnitt 3a) lassen dieses Skript gegen eine selbst erzeugte KOPIE eines
# Gates laufen, ohne die Datei im Arbeitsbaum zu beruehren. Ohne diese
# Variablen unveraendertes Verhalten. Die Pfade muessen ABSOLUT sein: ein
# relativer Pfad wird nach dem Wechsel in das Kontextverzeichnis nicht mehr
# gefunden und ergibt ein falsches Rot (ist=127; Restbefund N-DT-1 der
# dynamischen Nachpruefung vom 2026-09-23). Am Rueckgabewert ist eine
# Ueberschreibung nicht erkennbar, nur an der Kopfzeile: Wird dieses
# Pruefmittel je in die Kette (make dod) eingebunden, sind die beiden
# Variablen dort zu neutralisieren wie die GIT_*-Variablen (Restbefund
# NEU-1 der statischen Nachpruefung vom 2026-09-23); heute ruft die Kette es
# nicht auf.
#
# Rueckgabewert 0: Normalmodus -- alle 479 Faelle bestanden UND je Gate
# mindestens ein Fall mit Soll 2 und einer mit Soll 0 UND je Gate mindestens
# ein Fall der Klasse blockierend und einer der Klasse durchlaufend UND die
# gemessene Gesamtzahl entspricht der erwarteten Zahl UND der Arbeitsbaum
# blieb unveraendert UND alle Fallklassen sind gedeckt UND jede
# Befundkennung ist bekannt UND jedes Abnahmekriterium ist vollstaendig (die
# Listen der Abnahmekriterien werden ausgegeben und auf vorhandene Kennungen
# geprueft; eine fehlende Kennung erscheint dort als FEHLEND und wirkt seit
# E4.2 auf den Rueckgabewert -- Restbefund N-2/T-4 der statischen
# Nachpruefung vom 2026-09-23, behoben). Modus --mutationen -- die
# Grundlinie ist gruen UND alle 66 Mutationen erkannt UND der Arbeitsbaum
# blieb unveraendert. Sonst Rueckgabewert 2. Rueckgabewert 3: der Lauf kommt
# nicht zustande (ein Werkzeug fehlt, ein Klon ist nicht anlegbar, unbekannter
# Parameter) -- mit Meldung auf stderr.
# =============================================================================

set -uo pipefail

# -----------------------------------------------------------------------------
# 0. Git-eigene Umgebungsvariablen loeschen (N-6), vor dem ersten git-Aufruf
#    dieses Skripts -- wie .claude/hooks/session-start-git-historie.sh. Die so
#    bereinigte Umgebung erhalten ueber die normale Prozessvererbung auch die
#    Gates selbst (fall(), Abschnitt 10).
# -----------------------------------------------------------------------------
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_COMMON_DIR GIT_NAMESPACE GIT_CEILING_DIRECTORIES GIT_DISCOVERY_ACROSS_FILESYSTEM GIT_SHALLOW_FILE 2>/dev/null || true
unset "${!GIT_TRACE@}" 2>/dev/null || true

# -----------------------------------------------------------------------------
# 1. Parameter
# -----------------------------------------------------------------------------
MODUS="normal"
if [ $# -gt 0 ]; then
  if [ "$1" = "--mutationen" ] && [ $# -eq 1 ]; then
    MODUS="mutationen"
  else
    echo "pretooluse-gates-selbsttest: FEHLER -- unbekannter Parameter ('$*'); erlaubt ist kein Parameter oder genau '--mutationen'." >&2
    exit 3
  fi
fi

# -----------------------------------------------------------------------------
# 2. Werkzeuge, die dieser Lauf selbst braucht
# -----------------------------------------------------------------------------
for w in jq git mktemp sha256sum; do
  if ! command -v "$w" >/dev/null 2>&1; then
    echo "pretooluse-gates-selbsttest: FEHLER -- Werkzeug '$w' fehlt; der Lauf kommt nicht zustande." >&2
    exit 3
  fi
done

# -----------------------------------------------------------------------------
# 3. Arbeitsbaum und Gate-Dateien
# -----------------------------------------------------------------------------
SKRIPT_QUELLE="${BASH_SOURCE[0]}"
SKRIPT_VERZ=$(cd "$(dirname "$SKRIPT_QUELLE")" >/dev/null 2>&1 && pwd)
if [ -z "$SKRIPT_VERZ" ]; then
  echo "pretooluse-gates-selbsttest: FEHLER -- Verzeichnis des Skripts nicht aufloesbar." >&2
  exit 3
fi
if ! REPO_WURZEL=$(git -C "$SKRIPT_VERZ" rev-parse --show-toplevel 2>/dev/null); then
  echo "pretooluse-gates-selbsttest: FEHLER -- kein Repository um '$SKRIPT_VERZ'; der Lauf kommt nicht zustande." >&2
  exit 3
fi

GATE_MAIN="$REPO_WURZEL/.claude/hooks/block-main-write.sh"
GATE_PROTOTYP="$REPO_WURZEL/.claude/hooks/block-prototype-import.sh"
if [ ! -f "$GATE_MAIN" ]; then
  echo "pretooluse-gates-selbsttest: FEHLER -- Gate-Datei fehlt: $GATE_MAIN" >&2
  exit 3
fi
if [ ! -f "$GATE_PROTOTYP" ]; then
  echo "pretooluse-gates-selbsttest: FEHLER -- Gate-Datei fehlt: $GATE_PROTOTYP" >&2
  exit 3
fi

SHA_MAIN_VOLL=$(sha256sum "$GATE_MAIN" | cut -d' ' -f1)
SHA_PROTO_VOLL=$(sha256sum "$GATE_PROTOTYP" | cut -d' ' -f1)
SHA_MAIN_KURZ="${SHA_MAIN_VOLL:0:16}"
SHA_PROTO_KURZ="${SHA_PROTO_VOLL:0:16}"

# -----------------------------------------------------------------------------
# 3a. Ueberschreibung fuer Pruefrollen (DT-E41-02): mit eigener Mutation gegen
#     eine selbst erzeugte Kopie laufen, ohne die Datei im Arbeitsbaum
#     anzufassen. Ohne die Variablen unveraendertes Verhalten.
# -----------------------------------------------------------------------------
GATE_MAIN_AKTIV="$GATE_MAIN"
GATE_MAIN_ANZEIGE_ZUSATZ=""
if [ -n "${GATE_MAIN_UEBERSCHREIBUNG:-}" ]; then
  if [ ! -f "$GATE_MAIN_UEBERSCHREIBUNG" ]; then
    echo "pretooluse-gates-selbsttest: FEHLER -- GATE_MAIN_UEBERSCHREIBUNG '$GATE_MAIN_UEBERSCHREIBUNG' ist keine Datei." >&2
    exit 3
  fi
  GATE_MAIN_AKTIV="$GATE_MAIN_UEBERSCHREIBUNG"
  SHA_MAIN_VOLL=$(sha256sum "$GATE_MAIN_AKTIV" | cut -d' ' -f1)
  SHA_MAIN_KURZ="${SHA_MAIN_VOLL:0:16}"
  GATE_MAIN_ANZEIGE_ZUSATZ=" (UEBERSCHRIEBEN)"
fi
GATE_PROTOTYP_AKTIV="$GATE_PROTOTYP"
GATE_PROTOTYP_ANZEIGE_ZUSATZ=""
if [ -n "${GATE_PROTOTYP_UEBERSCHREIBUNG:-}" ]; then
  if [ ! -f "$GATE_PROTOTYP_UEBERSCHREIBUNG" ]; then
    echo "pretooluse-gates-selbsttest: FEHLER -- GATE_PROTOTYP_UEBERSCHREIBUNG '$GATE_PROTOTYP_UEBERSCHREIBUNG' ist keine Datei." >&2
    exit 3
  fi
  GATE_PROTOTYP_AKTIV="$GATE_PROTOTYP_UEBERSCHREIBUNG"
  SHA_PROTO_VOLL=$(sha256sum "$GATE_PROTOTYP_AKTIV" | cut -d' ' -f1)
  SHA_PROTO_KURZ="${SHA_PROTO_VOLL:0:16}"
  GATE_PROTOTYP_ANZEIGE_ZUSATZ=" (UEBERSCHRIEBEN)"
fi

# -----------------------------------------------------------------------------
# 4. Commit fuer die main/master-Klone
# -----------------------------------------------------------------------------
KLON_COMMIT=""
KLON_REF=""
for ref in refs/remotes/origin/main refs/heads/main HEAD; do
  if wert=$(git -C "$REPO_WURZEL" rev-parse --verify -q "$ref" 2>/dev/null); then
    KLON_COMMIT="$wert"
    KLON_REF="$ref"
    break
  fi
done
if [ -z "$KLON_COMMIT" ]; then
  echo "pretooluse-gates-selbsttest: FEHLER -- kein main-Commit ueber refs/remotes/origin/main, refs/heads/main oder HEAD aufloesbar; der Lauf kommt nicht zustande." >&2
  exit 3
fi

# -----------------------------------------------------------------------------
# 4a. Schnappschussfunktionen (N-5, DT-E41-03) -- aus der Repository-Wurzel
#     erhoben (die Klone unter Abschnitt 6 sind davon unbetroffen: eigene
#     Arbeitsbaeume unter mktemp).
# -----------------------------------------------------------------------------
schnappschuss_status() { git -C "$REPO_WURZEL" status --porcelain --untracked-files=all --ignored; }
schnappschuss_hash_inhalt() { ( cd "$REPO_WURZEL" && git ls-files -z | xargs -0 sha256sum ); }
schnappschuss_hash_unversioniert() { ( cd "$REPO_WURZEL" && git ls-files -z --others --exclude-standard | xargs -0 -r sha256sum ); }

# -----------------------------------------------------------------------------
# 4b. Vorher-Schnappschuss, VOR dem Anlegen der Wegwerfumgebung (N-5). Scheitert
#     eine Erhebung oder ist das Ergebnis der versionierten Pruefsummen leer,
#     ist die Unveraendertheit nicht belegbar (DT-E41-03): Meldung, und die
#     spaetere Vergleichspruefung zaehlt dann als verletzt (Rueckgabewert 2,
#     nicht 3 -- der Lauf selbst kommt zustande).
# -----------------------------------------------------------------------------
VORHER_OK=1
VORHER_STATUS=""
VORHER_HASH_INHALT=""
VORHER_HASH_UNVERSIONIERT=""
if ! VORHER_STATUS=$(schnappschuss_status); then VORHER_OK=0; fi
if ! VORHER_HASH_INHALT=$(schnappschuss_hash_inhalt) || [ -z "$VORHER_HASH_INHALT" ]; then VORHER_OK=0; fi
if ! VORHER_HASH_UNVERSIONIERT=$(schnappschuss_hash_unversioniert); then VORHER_OK=0; fi
if [ "$VORHER_OK" != 1 ]; then
  echo "pretooluse-gates-selbsttest: Arbeitsbaum: Inhaltspruefsummen nicht erhebbar." >&2
fi

# -----------------------------------------------------------------------------
# 5. Wegwerfverzeichnis, Aufraeumen per trap
# -----------------------------------------------------------------------------
T=$(mktemp -d) || { echo "pretooluse-gates-selbsttest: FEHLER -- mktemp -d fehlgeschlagen; der Lauf kommt nicht zustande." >&2; exit 3; }
aufraeumen() {
  chmod -R u+rwx "$T" >/dev/null 2>&1 || true
  rm -rf "$T"
}
trap aufraeumen EXIT

# -----------------------------------------------------------------------------
# 6. Umgebungen: main-Klon, zweiter main-Klon, master-Klon, Arbeitszweig-Klon,
#    kein Repo. "-c core.hooksPath=/dev/null" haelt Git-Hooks des Klons und
#    einer eingeschleusten Konfiguration fern (N-6).
# -----------------------------------------------------------------------------
klon_anlegen() {
  local ziel="$1" zweig="$2"
  if ! git -c core.hooksPath=/dev/null clone -q --no-checkout "$REPO_WURZEL" "$ziel" 2>"$T/klon-fehler"; then
    echo "pretooluse-gates-selbsttest: FEHLER -- Klon nach '$ziel' nicht anlegbar." >&2
    cat "$T/klon-fehler" >&2
    exit 3
  fi
  if ! git -C "$ziel" -c core.hooksPath=/dev/null checkout -q -B "$zweig" "$KLON_COMMIT" 2>"$T/klon-fehler"; then
    echo "pretooluse-gates-selbsttest: FEHLER -- Checkout '$zweig' in '$ziel' fehlgeschlagen." >&2
    cat "$T/klon-fehler" >&2
    exit 3
  fi
}
klon_anlegen "$T/main-klon" main
klon_anlegen "$T/zweiter-main" main
klon_anlegen "$T/master-klon" master
klon_anlegen "$T/arbeits-klon" claude/pruefzweig
mkdir -p "$T/kein-repo"

P_MK="$T/main-klon"
P_ZM="$T/zweiter-main"
P_MS="$T/master-klon"
P_AK="$T/arbeits-klon"
P_KR="$T/kein-repo"
P_AB="$REPO_WURZEL"

# -----------------------------------------------------------------------------
# 7. PATH-Varianten fuer die Wachen, absolute Pfade fuer bash und timeout
# -----------------------------------------------------------------------------
PATH_VOLL="$PATH"
BASH_BIN=$(command -v bash)
TIMEOUT_BIN=$(command -v timeout)
if [ -z "$BASH_BIN" ] || [ -z "$TIMEOUT_BIN" ]; then
  echo "pretooluse-gates-selbsttest: FEHLER -- bash oder timeout nicht aufloesbar; der Lauf kommt nicht zustande." >&2
  exit 3
fi

BIN_OHNE_GIT="$T/bin-ohne-git"
BIN_OHNE_JQ="$T/bin-ohne-jq"
mkdir -p "$BIN_OHNE_GIT" "$BIN_OHNE_JQ"
for w in cat grep sed tr jq timeout; do
  p=$(command -v "$w") || { echo "pretooluse-gates-selbsttest: FEHLER -- Werkzeug '$w' nicht aufloesbar." >&2; exit 3; }
  ln -s "$p" "$BIN_OHNE_GIT/$w"
done
for w in cat grep sed tr git timeout; do
  p=$(command -v "$w") || { echo "pretooluse-gates-selbsttest: FEHLER -- Werkzeug '$w' nicht aufloesbar." >&2; exit 3; }
  ln -s "$p" "$BIN_OHNE_JQ/$w"
done
BIN_OHNE_GREP="$T/bin-ohne-grep"
mkdir -p "$BIN_OHNE_GREP"
for w in cat sed tr jq git timeout; do
  p=$(command -v "$w") || { echo "pretooluse-gates-selbsttest: FEHLER -- Werkzeug '$w' nicht aufloesbar." >&2; exit 3; }
  ln -s "$p" "$BIN_OHNE_GREP/$w"
done
BIN_OHNE_SED="$T/bin-ohne-sed"
BIN_OHNE_TR="$T/bin-ohne-tr"
mkdir -p "$BIN_OHNE_SED" "$BIN_OHNE_TR"
for w in cat grep tr jq git timeout; do
  p=$(command -v "$w") || { echo "pretooluse-gates-selbsttest: FEHLER -- Werkzeug '$w' nicht aufloesbar." >&2; exit 3; }
  ln -s "$p" "$BIN_OHNE_SED/$w"
done
for w in cat grep sed jq git timeout; do
  p=$(command -v "$w") || { echo "pretooluse-gates-selbsttest: FEHLER -- Werkzeug '$w' nicht aufloesbar." >&2; exit 3; }
  ln -s "$p" "$BIN_OHNE_TR/$w"
done
# Delta 2026-10-21 (DT-C2-05, ST-C2-06): ein grep, der mit 1 endet, ohne zu lesen (der Schreiber
# bricht dann ab), und ein sed, das -z nicht kennt (andere Aufrufe gehen an das echte sed)
BIN_GREP_ATTRAPPE="$T/bin-grep-attrappe"
BIN_SED_OHNE_Z="$T/bin-sed-ohne-z"
mkdir -p "$BIN_GREP_ATTRAPPE" "$BIN_SED_OHNE_Z"
for w in cat sed tr jq git timeout; do
  p=$(command -v "$w") || { echo "pretooluse-gates-selbsttest: FEHLER -- Werkzeug '$w' nicht aufloesbar." >&2; exit 3; }
  ln -s "$p" "$BIN_GREP_ATTRAPPE/$w"
done
printf '#!/bin/sh\nexit 1\n' > "$BIN_GREP_ATTRAPPE/grep"
chmod +x "$BIN_GREP_ATTRAPPE/grep"
for w in cat grep tr jq git timeout; do
  p=$(command -v "$w") || { echo "pretooluse-gates-selbsttest: FEHLER -- Werkzeug '$w' nicht aufloesbar." >&2; exit 3; }
  ln -s "$p" "$BIN_SED_OHNE_Z/$w"
done
SED_ECHT=$(command -v sed) || { echo "pretooluse-gates-selbsttest: FEHLER -- Werkzeug 'sed' nicht aufloesbar." >&2; exit 3; }
printf '#!/bin/sh\ncase "$1" in -z*) exit 2 ;; esac\nexec "%s" "$@"\n' "$SED_ECHT" > "$BIN_SED_OHNE_Z/sed"
chmod +x "$BIN_SED_OHNE_Z/sed"
# ein sed, das nur die Abschnittsbildung von Posten 4 a (Trenner mit vorangestelltem Zeilenumbruch) verweigert
BIN_SED_OHNE_TRENNER="$T/bin-sed-ohne-trenner"
mkdir -p "$BIN_SED_OHNE_TRENNER"
for w in cat grep tr jq git timeout; do
  p=$(command -v "$w") || { echo "pretooluse-gates-selbsttest: FEHLER -- Werkzeug '$w' nicht aufloesbar." >&2; exit 3; }
  ln -s "$p" "$BIN_SED_OHNE_TRENNER/$w"
done
cat > "$BIN_SED_OHNE_TRENNER/sed" <<SEDEOF
#!/bin/sh
case "\$1" in
  's/[;&|]/\\n&/g') exit 2 ;;
esac
exec "$SED_ECHT" "\$@"
SEDEOF
chmod +x "$BIN_SED_OHNE_TRENNER/sed"
# C3 (2026-10-22, ADR 0002, 6.13 c, Festlegung fuer C3): Das Prototyp-Gate ruft ab Posten 7 selbst timeout auf; alle PATH-Varianten
# oben fuehren deshalb timeout, ausser der folgenden. Posten 7: PATH ohne timeout (das Gate sperrt mit einer Meldung, die timeout
# nennt) und zwei PATH-Varianten mit verlangsamtem cat (jeder innere Lauf liest die Eingabe mit cat): 20 s (ueber der Grenze des
# Pruefmittels von 14 s und ueber der des Gates von 12 s) und 4 s (deutlich darunter, Gegenprobe). Posten 6: PATH-Varianten mit
# einem sed, das nur die Schleife ueber die Blockkommentare bzw. nur die Bereinigung (sed -E) verweigert, fuer die Pruefstellen,
# die ein fehlendes sed nicht als erste erreicht.
BIN_OHNE_TIMEOUT="$T/bin-ohne-timeout"
mkdir -p "$BIN_OHNE_TIMEOUT"
for w in cat grep sed tr jq git; do
  p=$(command -v "$w") || { echo "pretooluse-gates-selbsttest: FEHLER -- Werkzeug '$w' nicht aufloesbar." >&2; exit 3; }
  ln -s "$p" "$BIN_OHNE_TIMEOUT/$w"
done
CAT_ECHT=$(command -v cat) || { echo "pretooluse-gates-selbsttest: FEHLER -- Werkzeug 'cat' nicht aufloesbar." >&2; exit 3; }
SLEEP_ECHT=$(command -v sleep) || { echo "pretooluse-gates-selbsttest: FEHLER -- Werkzeug 'sleep' nicht aufloesbar." >&2; exit 3; }
BIN_LANGSAMES_CAT="$T/bin-langsames-cat"
BIN_KURZES_CAT="$T/bin-kurzes-cat"
mkdir -p "$BIN_LANGSAMES_CAT" "$BIN_KURZES_CAT"
for w in grep sed tr jq git timeout; do
  p=$(command -v "$w") || { echo "pretooluse-gates-selbsttest: FEHLER -- Werkzeug '$w' nicht aufloesbar." >&2; exit 3; }
  ln -s "$p" "$BIN_LANGSAMES_CAT/$w"
  ln -s "$p" "$BIN_KURZES_CAT/$w"
done
printf '#!/bin/sh\n"%s" 20\nexec "%s" "$@"\n' "$SLEEP_ECHT" "$CAT_ECHT" > "$BIN_LANGSAMES_CAT/cat"
printf '#!/bin/sh\n"%s" 4\nexec "%s" "$@"\n' "$SLEEP_ECHT" "$CAT_ECHT" > "$BIN_KURZES_CAT/cat"
chmod +x "$BIN_LANGSAMES_CAT/cat" "$BIN_KURZES_CAT/cat"
BIN_SED_OHNE_SCHLEIFE="$T/bin-sed-ohne-schleife"
BIN_SED_OHNE_BEREINIGUNG="$T/bin-sed-ohne-bereinigung"
mkdir -p "$BIN_SED_OHNE_SCHLEIFE" "$BIN_SED_OHNE_BEREINIGUNG"
for w in cat grep tr jq git timeout; do
  p=$(command -v "$w") || { echo "pretooluse-gates-selbsttest: FEHLER -- Werkzeug '$w' nicht aufloesbar." >&2; exit 3; }
  ln -s "$p" "$BIN_SED_OHNE_SCHLEIFE/$w"
  ln -s "$p" "$BIN_SED_OHNE_BEREINIGUNG/$w"
done
cat > "$BIN_SED_OHNE_SCHLEIFE/sed" <<SEDEOF
#!/bin/sh
case "\$1" in
  's#/\*[^*]*\*/##g') exit 2 ;;
esac
exec "$SED_ECHT" "\$@"
SEDEOF
chmod +x "$BIN_SED_OHNE_SCHLEIFE/sed"
cat > "$BIN_SED_OHNE_BEREINIGUNG/sed" <<SEDEOF
#!/bin/sh
case "\$1" in
  -E) exit 2 ;;
esac
exec "$SED_ECHT" "\$@"
SEDEOF
chmod +x "$BIN_SED_OHNE_BEREINIGUNG/sed"
# Posten 7 (C3, 2026-10-22): ein timeout, das mit 125 endet (Fehler von timeout); misst den Zweig "jeder andere Ausgang"
# der Abbildung des Prototyp-Gates (ADR 0002, 6.13 c, Festlegung fuer C3).
BIN_TIMEOUT_FEHLER="$T/bin-timeout-fehler"
mkdir -p "$BIN_TIMEOUT_FEHLER"
for w in cat grep sed tr jq git; do
  p=$(command -v "$w") || { echo "pretooluse-gates-selbsttest: FEHLER -- Werkzeug '$w' nicht aufloesbar." >&2; exit 3; }
  ln -s "$p" "$BIN_TIMEOUT_FEHLER/$w"
done
printf '#!/bin/sh\nexit 125\n' > "$BIN_TIMEOUT_FEHLER/timeout"
chmod +x "$BIN_TIMEOUT_FEHLER/timeout"
# C3 (2026-10-22, Posten 6): ein sed, das nur den Aufruf fuer die Zeilenkommentare (erster sed-Schritt von cmd_flach und von
# payload_norm) verweigert. Fehlt sed ganz, faengt die Pruefung des naechsten sed-Schritts den Ausfall auf; diese Attrappe
# erreicht allein die Pruefung des ersten Schritts (Mutationen MP21 und MP25).
BIN_SED_OHNE_KOMMENTAR="$T/bin-sed-ohne-kommentar"
mkdir -p "$BIN_SED_OHNE_KOMMENTAR"
for w in cat grep tr jq git timeout; do
  p=$(command -v "$w") || { echo "pretooluse-gates-selbsttest: FEHLER -- Werkzeug '$w' nicht aufloesbar." >&2; exit 3; }
  ln -s "$p" "$BIN_SED_OHNE_KOMMENTAR/$w"
done
cat > "$BIN_SED_OHNE_KOMMENTAR/sed" <<SEDEOF
#!/bin/sh
case "\$1" in
  's#//[^\\n]*##') exit 2 ;;
esac
exec "$SED_ECHT" "\$@"
SEDEOF
chmod +x "$BIN_SED_OHNE_KOMMENTAR/sed"

# -----------------------------------------------------------------------------
# 8. Hilfsfunktionen zum Bauen der JSON-Eingaben (bj/wj, Sonderformen und
#    Platzhalter-Ersetzung; Form der Eingabe nach ADR 0002, 6.13 d Punkt 1)
# -----------------------------------------------------------------------------
bj() { jq -cn --arg c "$1" --arg t "${2:-Bash}" '{tool_name:$t, tool_input:{command:$c}}'; }
wj() { jq -cn --arg f "$1" --arg c "$2" --arg t "${3:-Write}" '{tool_name:$t, tool_input:{file_path:$f, content:$c}}'; }
ej() { jq -cn --arg t "${4:-Edit}" --arg f "$1" --arg o "$2" --arg n "$3" '{tool_name:$t, tool_input:{file_path:$f, old_string:$o, new_string:$n}}'; }
mej() { jq -cn --arg f "$1" --arg o "$2" --arg n "$3" '{tool_name:"MultiEdit", tool_input:{file_path:$f, edits:[{old_string:$o, new_string:$n}]}}'; }
nej() { jq -cn --arg p "$1" --arg s "$2" '{tool_name:"NotebookEdit", tool_input:{notebook_path:$p, new_source:$s}}'; }
rj() { jq -cn --arg f "$1" '{tool_name:"Read", tool_input:{file_path:$f}}'; }
wj_ohne_content() { jq -cn --arg f "$1" '{tool_name:"Write", tool_input:{file_path:$f}}'; }

# Platzhalter {MK} {ZM} {MS} {AK} {KR} {AB} literal ersetzen (N-7: Muster- UND
# Ersatzseite sind quotierte Parameterverweise -- ${s//"$muster"/"$ersatz"} --
# damit beide Seiten in jedem Fall literal bleiben, unabhaengig vom Inhalt).
ph() {
  local s="$1" muster ersatz
  muster='{MK}'; ersatz="$P_MK"; s="${s//"$muster"/"$ersatz"}"
  muster='{ZM}'; ersatz="$P_ZM"; s="${s//"$muster"/"$ersatz"}"
  muster='{MS}'; ersatz="$P_MS"; s="${s//"$muster"/"$ersatz"}"
  muster='{AK}'; ersatz="$P_AK"; s="${s//"$muster"/"$ersatz"}"
  muster='{KR}'; ersatz="$P_KR"; s="${s//"$muster"/"$ersatz"}"
  muster='{AB}'; ersatz="$P_AB"; s="${s//"$muster"/"$ersatz"}"
  printf '%s' "$s"
}
bj_ph() { bj "$(ph "$1")" "${2:-Bash}"; }
wj_ph() { wj "$(ph "$1")" "$(ph "$2")" "${3:-Write}"; }

# Posten 5 (2026-10-21, ADR 0002, 6.13 c, SR-001): grosse Eingaben. Eine
# Kommentarzeile aus 200000 Zeichen liegt ueber der Schwelle von 128 KiB, ab der
# die Pipeline aus printf und grep -q unter pipefail sicher mit 141 (SIGPIPE)
# endet (DT-B2-10). jq --arg scheitert ab 128 KB an der Argumentlaenge; die
# grossen Eingaben gehen deshalb ueber die Standardeingabe von jq (-Rs).
GROSS=$(head -c 200000 /dev/zero | tr '\0' '#')
bj_gross() { printf '%s\n# %s' "$(ph "$1")" "$GROSS" | jq -Rsc '{tool_name:"Bash", tool_input:{command:.}}'; }
wj_gross() { printf '%s\n// %s' "$2" "$GROSS" | jq -Rsc --arg f "$(ph "$1")" '{tool_name:"Write", tool_input:{file_path:$f, content:.}}'; }
# Delta DT-C2-01 (2026-10-21): 50000 Zeilen 'x \' (300 KB) hinter einem Befehl; die
# alte Schleife :a;N;ba brauchte dafuer ueber 60 s (quadratisch).
FORT=$(yes 'x \' | head -n 50000)
bj_fort() { printf '%s\n%s\nx' "$(ph "$1")" "$FORT" | jq -Rsc '{tool_name:"Bash", tool_input:{command:.}}'; }
# H-1 (Delta 2026-10-21): Zeilen aus 150000 Leerzeichen bzw. Ziffern
LEER=$(head -c 150000 /dev/zero | tr '\0' ' ')
ZIFF=$(head -c 150000 /dev/zero | tr '\0' '1')
bj_zeile() { printf '%s\n%s' "$(ph "$1")" "$2" | jq -Rsc '{tool_name:"Bash", tool_input:{command:.}}'; }

# -----------------------------------------------------------------------------
# 9. Buchhaltung
# -----------------------------------------------------------------------------
ERWARTETE_FAELLE=479
VOLLSTAENDIGKEIT_OK=1
declare -a ALLE_KENNUNGEN=()
declare -a BESTANDENE_KENNUNGEN=()
declare -a GEFALLENE_KENNUNGEN=()
declare -A URTEIL_VON=()
declare -A SOLL_VON=()
declare -A KLASSE_VON=()
declare -A GATE_VON=()

MAIN_SOLL2_ANZAHL=0
MAIN_SOLL0_ANZAHL=0
PROTO_SOLL2_ANZAHL=0
PROTO_SOLL0_ANZAHL=0
declare -A KLASSEN_ANZAHL_MAIN=()
declare -A KLASSEN_ANZAHL_PROTO=()

AKTIV_GATE_MAIN="$GATE_MAIN_AKTIV"
AKTIV_GATE_PROTOTYP="$GATE_PROTOTYP_AKTIV"
AKTIVE_MUTATION_GATE=""
declare -a MUTATION_GEFALLEN=()
MUTATION_GEPRUEFT=0
GRUNDLINIE_MODUS=0
GRUNDLINIE_GESAMT=0
GRUNDLINIE_BESTANDEN=0
declare -a GRUNDLINIE_GEFALLEN=()

# Befundkennung je Fall der Klasse belegte-luecke (Teil 4.3/4.5/4.6 der
# Fallliste unten, ADR 0002, 6.13 d), fuer die Ausgabezeile "belegte Luecken".
# Seit E4.3 leer: ST-09 und ST-13 sind geschlossen, keine Klasse
# belegte-luecke mehr in der Fallliste.
# Nachtrag 2026-10-14 (Posten 1 unter R3-Q-010, ADR 0002, 6.13 c, Nachtrag vom
# 2026-09-23): wieder gefuellt. L05 bis L08 (Posten 2) und L09 (Posten 3) sind
# belegte Luecken mit Soll 0 bis zum Bau ihres Postens (dann Soll 2, Klasse
# blockierend); L17 ist Posten 4 (DT-B2-05 c), L19 Posten 4 b (DT-B2-09), L21
# Posten 4 c (Basename-Form), L20 Posten 5 (B2-GATE-D05). L18 (DT-B2-07) stand
# hier bis zur Einordnung des Software Architects vom 2026-10-14 und ist
# geschlossen.
# Nachtrag 2026-10-21 (Posten 4 und 5 unter R3-Q-010): L17, L19, L20 und L21 sind
# geschlossen (Soll 2, Klasse blockierend; ihr frueherer Wortlaut steht im Vermerk
# hinter "vormals belegte Luecke: ") und hier entfernt; L05 bis L09 bleiben. Neu sind
# L23 und L24 (Posten 6, Prototyp-Gate: sed/tr ohne Rueckgabewert-Pruefung).
# Nachtrag 2026-10-22 (C3, Posten 2 und 6): L05 bis L08 sowie L23 und L24 sind geschlossen (Soll 2, Klasse blockierend;
# ihr frueherer Wortlaut steht im Vermerk hinter "vormals belegte Luecke: ") und hier entfernt; es bleibt L09 (Posten 3, C4).
declare -A BEFUND_VON=()
BEFUND_VON[L09]="Posten 3 unter R3-Q-010 (ADR 0002, 6.13 c)"

# -----------------------------------------------------------------------------
# 10. Ein Fall (fall <kennung> <gate> <klasse> <soll> <kontext> <cwd> <pfad>
#     <art> <werkzeug> <vermerk> <eingabe>)
# -----------------------------------------------------------------------------
fall() {
  if [ $# -ne 11 ]; then
    echo "pretooluse-gates-selbsttest: FEHLER -- fall() mit $# statt 11 Argumenten aufgerufen (erstes Argument: ${1:-?})." >&2
    exit 3
  fi
  local kennung="$1" gate="$2" klasse="$3" soll="$4" kontext_code="$5" cwd_wahl="$6" pfad_wahl="$7" art="$8" werkzeug="$9" vermerk="${10}" eingabe="${11}"

  if [ -n "$AKTIVE_MUTATION_GATE" ] && [ "$gate" != "$AKTIVE_MUTATION_GATE" ]; then
    return 0
  fi

  if [ -z "$AKTIVE_MUTATION_GATE" ] && [ -n "${URTEIL_VON[$kennung]+gesetzt}" ]; then
    echo "pretooluse-gates-selbsttest: FEHLER -- doppelte Kennung '$kennung' in der Fallliste." >&2
    exit 3
  fi

  local kontext_pfad
  case "$kontext_code" in
    MK) kontext_pfad="$P_MK" ;;
    MS) kontext_pfad="$P_MS" ;;
    AK) kontext_pfad="$P_AK" ;;
    KR) kontext_pfad="$P_KR" ;;
    AB) kontext_pfad="$P_AB" ;;
    *)
      echo "pretooluse-gates-selbsttest: FEHLER -- unbekannter Kontext-Code '$kontext_code' bei Fall $kennung." >&2
      exit 3
      ;;
  esac

  local gate_pfad
  if [ "$gate" = "main" ]; then gate_pfad="$AKTIV_GATE_MAIN"; else gate_pfad="$AKTIV_GATE_PROTOTYP"; fi

  local zielpfad
  if [ "$cwd_wahl" = "/" ]; then zielpfad="/"; else zielpfad="$kontext_pfad"; fi

  local pfadvar
  # Delta 2 (2026-10-21, ST-C2-D-01): die PATH-Wahl posix ist der volle PATH mit POSIXLY_CORRECT=1
  # in der Umgebung des Gates; der Prozess des Pruefmittels selbst bleibt unberuehrt.
  local -a posix_zusatz=()
  case "$pfad_wahl" in
    voll) pfadvar="$PATH_VOLL" ;;
    posix) pfadvar="$PATH_VOLL"; posix_zusatz=(POSIXLY_CORRECT=1) ;;
    ohne-git) pfadvar="$BIN_OHNE_GIT" ;;
    ohne-jq) pfadvar="$BIN_OHNE_JQ" ;;
    ohne-grep) pfadvar="$BIN_OHNE_GREP" ;;
    ohne-sed) pfadvar="$BIN_OHNE_SED" ;;
    ohne-tr) pfadvar="$BIN_OHNE_TR" ;;
    grep-attrappe) pfadvar="$BIN_GREP_ATTRAPPE" ;;
    sed-ohne-z) pfadvar="$BIN_SED_OHNE_Z" ;;
    sed-ohne-trenner) pfadvar="$BIN_SED_OHNE_TRENNER" ;;
    ohne-timeout) pfadvar="$BIN_OHNE_TIMEOUT" ;;
    langsames-cat) pfadvar="$BIN_LANGSAMES_CAT" ;;
    kurzes-cat) pfadvar="$BIN_KURZES_CAT" ;;
    sed-ohne-schleife) pfadvar="$BIN_SED_OHNE_SCHLEIFE" ;;
    sed-ohne-bereinigung) pfadvar="$BIN_SED_OHNE_BEREINIGUNG" ;;
    timeout-fehler) pfadvar="$BIN_TIMEOUT_FEHLER" ;;
    sed-ohne-kommentar) pfadvar="$BIN_SED_OHNE_KOMMENTAR" ;;
    *)
      echo "pretooluse-gates-selbsttest: FEHLER -- unbekannte PATH-Wahl '$pfad_wahl' bei Fall $kennung." >&2
      exit 3
      ;;
  esac

  : > "$T/lauf-aus"
  : > "$T/lauf-fehler"
  ( cd "$zielpfad" 2>/dev/null && printf '%s' "$eingabe" | env PATH="$pfadvar" CLAUDE_PROJECT_DIR="$kontext_pfad" ${posix_zusatz[@]+"${posix_zusatz[@]}"} "$TIMEOUT_BIN" 14 "$BASH_BIN" "$gate_pfad" >"$T/lauf-aus" 2>"$T/lauf-fehler" )
  local ist=$?
  # Delta DT-C2-01 (2026-10-21): Jeder Gate-Aufruf hat eine eigene Zeitgrenze von 14 s,
  # unter der Hook-Grenze von 15 s in .claude/settings.json. Reisst ein Hook diese
  # Grenze, bricht der Harness ihn ab und laesst durch (.claude/rules/
  # claude-konfiguration.md, Abschnitt Hooks); das Pruefmittel bildet das nach und
  # wertet die Ueberschreitung (Rueckgabewert 124 von timeout) als Durchlass 0.
  local zeitgrenze=""
  if [ "$ist" = 124 ]; then ist=0; zeitgrenze="zeitgrenze-14s-ueberschritten"; fi

  local stdout_bytes stderr_bytes
  stdout_bytes=$(wc -c < "$T/lauf-aus" | tr -d ' ')
  stderr_bytes=$(wc -c < "$T/lauf-fehler" | tr -d ' ')

  local urteil="BESTANDEN" gruende="" grund="-"
  if [ "$ist" != "$soll" ]; then gruende="${gruende}rueckgabewert,"; fi
  if [ "$stdout_bytes" != "0" ]; then gruende="${gruende}stdout-nicht-leer,"; fi
  if [ "$soll" = "2" ] && [ "$stderr_bytes" = "0" ]; then gruende="${gruende}stderr-leer-bei-soll-2,"; fi

  # B-1/DST-E42-03: bei Soll 2 und vollem PATH (Wachen-Faelle ohne-jq/ohne-git
  # ausgenommen) muss stderr den verletzten Abschnitt nennen und, beim
  # Prototyp-Gate an einem Dateiwerkzeug, die zur Datei passende Richtung.
  # Bash-Faelle des Prototyp-Gates nennen keine Richtung (die Bash-Meldung
  # kennt das Konstrukt "Richtung" nicht) und werden hier ausgenommen.
  if [ "$soll" = "2" ] && { [ "$pfad_wahl" = "voll" ] || [ "$pfad_wahl" = "posix" ]; }; then
    local stderr_text
    stderr_text=$(cat "$T/lauf-fehler")
    if [ "$art" = "ROH" ]; then
      # ST-13: die Wachen-Meldung ("Eingabe nicht auswertbar") ersetzt hier
      # die 5.6-/3.2-c-Meldung, wie bei den Wachen-Faellen ohne-jq/ohne-git.
      case "$stderr_text" in
        *"nicht auswertbar"*) : ;;
        *) gruende="${gruende}meldung-ohne-nicht-auswertbar," ;;
      esac
    elif [ "$gate" = "prototyp" ]; then
      case "$stderr_text" in
        *"Projektauftrag 5.6"*) : ;;
        *) gruende="${gruende}meldung-ohne-5.6," ;;
      esac
      local werkzeug_klein
      werkzeug_klein=$(printf '%s' "$werkzeug" | tr '[:upper:]' '[:lower:]')
      if [ "$werkzeug_klein" != "bash" ]; then
        local erwartete_richtung="Richtung 1"
        case "$eingabe" in
          *'"file_path":"prototype/'*|*'"notebook_path":"prototype/'*) erwartete_richtung="Richtung 2" ;;
        esac
        case "$stderr_text" in
          *"$erwartete_richtung"*) : ;;
          *) gruende="${gruende}meldung-ohne-richtung," ;;
        esac
      fi
    else
      case "$stderr_text" in
        *"Projektauftrag 3.2 c"*) : ;;
        *) gruende="${gruende}meldung-ohne-3.2c," ;;
      esac
    fi
  fi

  # C3 (2026-10-22, Posten 6 und Posten 7 am Prototyp-Gate): bei Soll 2 an diesen PATH-Wahlen nennt die Meldung des Prototyp-Gates
  # das Werkzeug mit seinem Rueckgabewert (sed, tr), die Zeitgrenze (langsames-cat) oder timeout (ohne-timeout); Wortlaut nach
  # ADR 0002, 6.13 b. Nur Prototyp-Gate: der Fall S16 fuehrt dieselbe PATH-Wahl ohne-sed am main-Gate, dessen Meldung unveraendert bleibt.
  if [ "$soll" = "2" ] && [ "$gate" = "prototyp" ]; then
    local stderr_wahl
    stderr_wahl=$(cat "$T/lauf-fehler")
    case "$pfad_wahl" in
      ohne-sed|sed-ohne-schleife|sed-ohne-bereinigung|sed-ohne-kommentar)
        case "$stderr_wahl" in
          *"(sed, Rueckgabewert "*) : ;;
          *) gruende="${gruende}meldung-ohne-sed," ;;
        esac
        ;;
      ohne-tr)
        case "$stderr_wahl" in
          *"(tr, Rueckgabewert "*) : ;;
          *) gruende="${gruende}meldung-ohne-tr," ;;
        esac
        ;;
      langsames-cat)
        case "$stderr_wahl" in
          *"Zeitgrenze"*) : ;;
          *) gruende="${gruende}meldung-ohne-zeitgrenze," ;;
        esac
        ;;
      ohne-timeout)
        case "$stderr_wahl" in
          *"timeout ist nicht installiert"*) : ;;
          *) gruende="${gruende}meldung-ohne-timeout," ;;
        esac
        ;;
      timeout-fehler)
        case "$stderr_wahl" in
          *"Rueckgabewert 125"*) : ;;
          *) gruende="${gruende}meldung-ohne-rueckgabewert-125," ;;
        esac
        ;;
    esac
  fi
  if [ -n "$gruende" ]; then
    urteil="GEFALLEN"
    grund="${gruende%,}"
  fi
  if [ -n "$zeitgrenze" ]; then
    if [ "$grund" = "-" ]; then grund="$zeitgrenze"; else grund="$grund,$zeitgrenze"; fi
  fi

  if [ "$GRUNDLINIE_MODUS" = "1" ]; then
    GRUNDLINIE_GESAMT=$((GRUNDLINIE_GESAMT+1))
    if [ "$urteil" = "BESTANDEN" ]; then
      GRUNDLINIE_BESTANDEN=$((GRUNDLINIE_BESTANDEN+1))
    else
      GRUNDLINIE_GEFALLEN+=("$kennung")
    fi
    return 0
  fi

  if [ -z "$AKTIVE_MUTATION_GATE" ]; then
    local eingabe_anzeige="${eingabe//$'\n'/\\n}"
    if [ "${#eingabe_anzeige}" -gt 1000 ]; then
      eingabe_anzeige="${eingabe_anzeige:0:200} ...[gekuerzt, ${#eingabe_anzeige} Zeichen]"
    fi
    printf '%s gate=%s werkzeug=%s soll=%s ist=%s %s klasse=%s stdout=%s stderr=%s grund=%s vermerk="%s" eingabe=%s\n' \
      "$kennung" "$gate" "$werkzeug" "$soll" "$ist" "$urteil" "$klasse" "$stdout_bytes" "$stderr_bytes" "$grund" "$vermerk" "$eingabe_anzeige"

    ALLE_KENNUNGEN+=("$kennung")
    GATE_VON["$kennung"]="$gate"
    KLASSE_VON["$kennung"]="$klasse"
    SOLL_VON["$kennung"]="$soll"
    URTEIL_VON["$kennung"]="$urteil"
    if [ "$urteil" = "BESTANDEN" ]; then
      BESTANDENE_KENNUNGEN+=("$kennung")
    else
      GEFALLENE_KENNUNGEN+=("$kennung")
    fi

    if [ "$gate" = "main" ]; then
      if [ "$soll" = "2" ]; then MAIN_SOLL2_ANZAHL=$((MAIN_SOLL2_ANZAHL+1)); else MAIN_SOLL0_ANZAHL=$((MAIN_SOLL0_ANZAHL+1)); fi
      KLASSEN_ANZAHL_MAIN["$klasse"]=$(( ${KLASSEN_ANZAHL_MAIN["$klasse"]:-0} + 1 ))
    else
      if [ "$soll" = "2" ]; then PROTO_SOLL2_ANZAHL=$((PROTO_SOLL2_ANZAHL+1)); else PROTO_SOLL0_ANZAHL=$((PROTO_SOLL0_ANZAHL+1)); fi
      KLASSEN_ANZAHL_PROTO["$klasse"]=$(( ${KLASSEN_ANZAHL_PROTO["$klasse"]:-0} + 1 ))
    fi
    if [ "$klasse" = "belegte-luecke" ] && [ -z "${BEFUND_VON[$kennung]+x}" ]; then
      echo "pretooluse-gates-selbsttest: unbekannte Befundkennung fuer '$kennung' (Klasse belegte-luecke ohne Eintrag in BEFUND_VON)." >&2
      VOLLSTAENDIGKEIT_OK=0
    fi
  else
    MUTATION_GEPRUEFT=$((MUTATION_GEPRUEFT+1))
    if [ "$urteil" = "GEFALLEN" ]; then
      MUTATION_GEFALLEN+=("$kennung")
    fi
  fi
}

# -----------------------------------------------------------------------------
# 11. Feste Daten: Mutationen, Fallklassen der Kopfkommentare,
#     Abnahmekriterien (ADR 0002, 6.13 d: einmal abgezaehlt, im Pruefmittel
#     gefuehrt, in der Ausgabe genannt -- entstehen nicht bei jedem Lauf neu)
# -----------------------------------------------------------------------------
declare -a MUT_KENNUNG=() MUT_GATE=() MUT_SUCH=() MUT_ERSATZ=() MUT_BESCHREIBUNG=() MUT_ERWARTET=()
mutation_definieren() {
  MUT_KENNUNG+=("$1"); MUT_GATE+=("$2"); MUT_SUCH+=("$3"); MUT_ERSATZ+=("$4"); MUT_BESCHREIBUNG+=("$5"); MUT_ERWARTET+=("$6")
}

declare -a FK_ID=() FK_GATE=() FK_TYP=() FK_TEXT=() FK_KENNUNGEN=()
fallklasse_definieren() {
  FK_ID+=("$1"); FK_GATE+=("$2"); FK_TYP+=("$3"); FK_TEXT+=("$4"); FK_KENNUNGEN+=("$5")
}

declare -a AK_ID=() AK_DOMAIN=() AK_KENNUNGEN=() AK_ANMERKUNG=()
abnahmekriterium_definieren() {
  AK_ID+=("$1"); AK_DOMAIN+=("$2"); AK_KENNUNGEN+=("$3"); AK_ANMERKUNG+=("$4")
}

# --- 11a. Sechsundsechzig Mutationen (ADR 0002, 6.13 d; 49 bis C2, MP16 bis MP32 mit C3) ---------------
mutation_definieren MM1 main 'worktree[[:space:]]+add([[:space:]]|$)' 'worktree[[:space:]]+addNIE([[:space:]]|$)' 'Sperre Arbeitsbaum auf main anlegen entfernt' 'A07 A08 A09 A37'
mutation_definieren MM2 main 'if ! command -v git >/dev/null 2>&1; then' 'if false; then' 'git-Wache entfernt (ST-03)' 'S03'
mutation_definieren MM3 main '(commit|merge|revert|cherry-pick|rebase|reset|am|apply|stash[[:space:]]+(pop|apply))' '(NIE)' 'Sperre schreibender git-Verben entfernt' 'A10 A14 A20 A21 A22 A30 A31 ZF3a ZF3b ZF3c ZF3d ZF3e ZF3f ZF3g'
mutation_definieren MM4 main 'is_protected "$branch" || exit 0' 'exit 0' 'Sperre der Dateiwerkzeuge auf main entfernt (Kopfkommentar Fall 1)' 'A12 A13'
mutation_definieren MM5 main "(^|[[:space:]:+\"'\\''(])(main|master)([[:space:]]|\$|[\"'\\'';&|)])" "(^|[[:space:]:+])(main|master)([[:space:]]|\$|[\"'\\''])" 'ST-01-Behebung zurueckgesetzt: Zeichenklassen der Push-Zielpruefung auf den Stand vor 0b3510a (kein Anfuehrungszeichen, kein Semikolon, keine Klammer); seit Posten 1 (2026-10-14) deckt cmd_ziel die Anfuehrungszeichen zusaetzlich, daher fallen A38, A39 und, seit dem Dollar-Schritt (DT-B2-07), A68 bei dieser Mutation nicht mehr' 'A40 A41'
mutation_definieren MP1 prototyp '-e "${ATTR}${Q}(${NQ}*[/\\\\])?prototype(/|\\\\|${Q})"' '-e "(NIE)=${Q}(${NQ}*[/\\\\])?prototype(/|\\\\|${Q})"' 'HTML-Formen src=/href= der Richtung 1 entfernt' 'P02 B34'
mutation_definieren MP2 prototyp '(>>?|\btee[[:space:]]|sed[[:space:]]+-[a-zA-Z]*i|<<)' '(NIE)' 'Erkennung der Schreibwirkung bei Bash entfernt (B-1: tee-Glied seit E4.3 ohne Pipe-Bindung)' 'B10 B11 B12 B13 B39 B40 B53'
mutation_definieren MP9 prototyp '\b(mv|cp|rm|mkdir|touch|truncate|ln|install|patch|dd)[[:space:]]' '\b(NIE)[[:space:]]' 'Dateiwerkzeug-Glied im Prototyp-Gate entfernt (B-2, DT-E43-2)' 'B54 B56'
mutation_definieren MP3 prototyp "WURZELN='backend|frontend|deploy|src|app|lib|server|packages|apps'" "WURZELN='NIE'" 'Verzeichnisliste WURZELN der Richtung 2 entfernt (Import-Pfade und src=/href=; die Python-Formen fuehren backend/frontend/deploy gesondert)' 'B05 B20 B21 B22 B37'
# P08 (MultiEdit) faellt bei dieser Mutation nicht, weil das Gate old_string
# innerhalb von edits[] ueber einen eigenen jq-Pfad strukturell nie liest;
# P08 bleibt Gegenprobe im Normalmodus.
mutation_definieren MP4 prototyp 'test("path|^old_string$"; "i")' 'test("path"; "i")' 'Ausnahme von old_string entfernt -- Regressionsschutz' 'P05'
mutation_definieren MP5 prototyp 'docs/*|.claude/*|*.md|*.txt|*.adoc|*.rst) exit 0 ;;' 'NIE-GESETZT) exit 0 ;;' 'Doku-Ausnahme entfernt -- Regressionsschutz' 'P03 P11 P18 P19 ZF9'
mutation_definieren MP6 prototyp 'Richtung 1 (Produktionscode -> Prototyp): ' '' 'Richtungsangabe der Richtung-1-Meldung entfernt' 'B01 B04 B27 P02'
mutation_definieren MP7 prototyp '\b(python[0-9.]*|perl|ruby|node|deno|php|Rscript)[[:space:]]+([^|;&]*[[:space:]]+)?-[a-zA-Z]*(c|e|i|p|r|n)([^a-zA-Z]|$)' '(NIE)' 'ST-09-Behebung zurueckgesetzt: Interpreter-mit-Inline-Code-Glied im Prototyp-Gate entfernt' 'B09 ZF7a ZF7c ZF7d'
mutation_definieren MM6 main 'type == "object" and (.tool_input | type == "object")' 'true' 'ST-13-Behebung zurueckgesetzt: die Eingabepruefung im main-Gate haelt keine Form mehr fest (vorgemessen: S01/S02 sind kein gueltiges JSON und lassen jq unabhaengig vom Filter scheitern, bleiben deshalb blockiert -- nur ZF8a/ZF8b werden durch diese Mutation durchgelassen)' 'ZF8a ZF8b'
mutation_definieren MP8 prototyp 'type == "object" and (.tool_input | type == "object")' 'true' 'ST-13-Behebung zurueckgesetzt: die Eingabepruefung im Prototyp-Gate haelt keine Form mehr fest (vorgemessen: S04/S05 sind kein gueltiges JSON und lassen jq unabhaengig vom Filter scheitern, bleiben deshalb blockiert -- nur ZF8c/ZF8d werden durch diese Mutation durchgelassen)' 'ZF8c ZF8d'
mutation_definieren MM7 main '[0-9]?>>?[[:space:]]*(\/tmp\/([^[:space:].;|&)]|\.[^.[:space:];|&)])*|"?\$\{?(TMPDIR|RUNNER_TEMP|SCRATCH[A-Z_]*)\}?([^[:space:].;|&)]|\.[^.[:space:];|&)])*)([[:space:];|&)]|$)/\5/g' '[0-9]?>>?[[:space:]]*(\/tmp\/[^[:space:];|&)]*|"?\$\{?(TMPDIR|RUNNER_TEMP|SCRATCH[A-Z_]*)\}?[^[:space:];|&)]*)([[:space:];|&)]|$)/\5/g' 'DT-E43-6-Behebung zurueckgesetzt: die ".."-Ausnahme im main-Gate auf die alte, uneingeschraenkte Form zurueckgesetzt (Trennerschutz DT-E43-8 bleibt erhalten)' 'A50 A51'
mutation_definieren MP10 prototyp '[0-9]?>>?[[:space:]]*(\/tmp\/([^[:space:].;|&)]|\.[^.[:space:];|&)])*|"?\$\{?(TMPDIR|RUNNER_TEMP|SCRATCH[A-Z_]*)\}?([^[:space:].;|&)]|\.[^.[:space:];|&)])*)([[:space:];|&)]|$)/\5/g' '[0-9]?>>?[[:space:]]*(\/tmp\/[^[:space:];|&)]*|"?\$\{?(TMPDIR|RUNNER_TEMP|SCRATCH[A-Z_]*)\}?[^[:space:];|&)]*)([[:space:];|&)]|$)/\5/g' 'DT-E43-6-Behebung zurueckgesetzt: die ".."-Ausnahme im Prototyp-Gate auf die alte, uneingeschraenkte Form zurueckgesetzt (Trennerschutz DT-E43-8 bleibt erhalten)' 'B60 B61'
mutation_definieren MM8 main 'length == 1' 'length >= 1' 'N-3: Kardinalitaetspruefung des JSON-Stroms im main-Gate abgeschwaecht' 'S08'
mutation_definieren MP11 prototyp 'length == 1' 'length >= 1' 'N-3: Kardinalitaetspruefung des JSON-Stroms im Prototyp-Gate abgeschwaecht' 'S09'
mutation_definieren MM9 main "; s/[\"'\\'']//g" '' 'Posten 1 zurueckgesetzt: das Entfernen der Anfuehrungszeichen in cmd_ziel ausser Kraft (die Rueckstriche bleiben)' 'L01 L03 A54 L04'
mutation_definieren MM10 main 's/\\(.)/\1/g; ' '' 'Posten 1 zurueckgesetzt: das Entfernen der Rueckstriche in cmd_ziel ausser Kraft (die Anfuehrungszeichen bleiben)' 'L02 A55 A67'
mutation_definieren MM11 main '[[:space:]]-[a-zA-Z]*[bB][[:space:]]*(main|master)' '[[:space:]]-[a-zA-Z]*[bB][[:space:]]*(NIE)' 'Posten 1 zurueckgesetzt: die Pruefung des Namens hinter -b/-B ausser Kraft, die Ausnahme greift wieder fuer main/master (L04)' 'L04 A56 A57'
MM12_SUCH=$(cat <<'X'
printf '%s' "$cmd_verb" | sed 's/[;&|]/\n&/g'
X
)
MM12_ERS=$(cat <<'X'
printf '%s' "$cmd_ziel" | sed 's/[;&|]/\n&/g'
X
)
mutation_definieren MM12 main "$MM12_SUCH" "$MM12_ERS" 'Posten 1, Behebung DT-B2-02 zurueckgesetzt: die Abschnitte und damit die Ausnahme fuer -b/-B lesen wieder cmd_ziel statt den Befehlstext (maskierte Leerzeichen im Pfad werden zu " -b ", ein Dollarzeichen vor Anfuehrungszeichen gibt ein -b)' 'A58 A75'
mutation_definieren MM13 main '-[a-zA-Z]*[bB][[:space:]]*(main|master)' '-[bB][[:space:]]+(main|master)' 'Posten 1, Behebung DT-B2-03 zurueckgesetzt: der Name hinter -b/-B nur getrennt und ohne Buchstaben davor (angehaengte und gebuendelte Werte -Bmain, -bmain, -fBmain, -qbmaster werden nicht erkannt)' 'A59 A60 A61 A73'
mutation_definieren MM14 main 's/\\\n|(\\[^\n])/\1/g' 's/NIE_GESETZT\n|(\\[^\n])/\1/g' 'Posten 1, Behebung DT-B2-04 zurueckgesetzt: der Schritt fuer die Zeilenfortsetzung (seit dem Delta vom 2026-10-21 in einem Durchgang mit sed -z) ausser Kraft: Rueckstrich und Zeilenumbruch fallen nicht mehr weg' 'A62 A63 A64'
mutation_definieren MM15 main 's/\$(' 's/NIE_GESETZT(' 'Posten 1, Einordnung DT-B2-07 zurueckgesetzt: der Dollar-Schritt in cmd_ziel ausser Kraft (das Dollarzeichen vor einem Anfuehrungszeichen bleibt stehen)' 'L18 A69 A70 A71 A72'
mutation_definieren MM16 main '[ "${st[1]:-}" = 0 ] && return 0' '[ "${st[1]:-}" = 0 ] && { [ "${st[0]:-}" = 0 ] && return 0; return 1; }' 'Posten 5 zurueckgesetzt (SR-001, B2-GATE-D05): bei einem Treffer gilt der Abbruch des Schreibers (SIGPIPE, 141) wieder als kein Treffer, wie bei printf | grep -Eq unter pipefail vor dem Bau; die Hilfsfunktion trifft liefert dann bei grossen Eingaben 1 statt 0' 'L20 A80 A81 A82 A83 A84'
mutation_definieren MP12 prototyp '[ "${st[1]:-}" = 0 ] && return 0' '[ "${st[1]:-}" = 0 ] && { [ "${st[0]:-}" = 0 ] && return 0; return 1; }' 'Posten 5 zurueckgesetzt (SR-001, B2-GATE-D05): wie MM16 am Prototyp-Gate; bei grossen Eingaben gilt der Abbruch des Schreibers wieder als kein Treffer (Bash, Richtung 1 und Richtung 2 am Dateiinhalt)' 'L22 B64 B65'
MM17_SUCH=$(cat <<'X'
sed 's/[;&|]/\n&/g'
X
)
mutation_definieren MM17 main "$MM17_SUCH" 'cat' 'Posten 4 a zurueckgesetzt (DT-B2-05 c): die Abschnitte werden nur noch am Zeilenumbruch getrennt, nicht mehr an ; & |; ein -b/-B in einem anderen Abschnitt derselben Zeile hebt die Sperre wieder fuer alle auf' 'L17 A85 A87 A88 A90 A101'
mutation_definieren MM18 main 'cmd_verb="$cmd_fort"' 'cmd_verb="$cmd"' 'Posten 4 b zurueckgesetzt (DT-B2-09): Verb, Sammel-Push-Optionen und Ausnahme lesen wieder den Befehlstext mit seinen Zeilenfortsetzungen' 'L19 A91 A92 G78 G79 G80'
mutation_definieren MM19 main 'if trifft "$basis_text" -e "$basis_muster" || trifft "$basis_alt" -e "$basis_muster"; then' 'if false; then' 'Posten 4 c zurueckgesetzt (L21): die Pruefung der Basename-Form ist ausser Kraft' 'L21 A93 A94 A95 A96 A97 A98 A99 A100'
mutation_definieren MM20 main 'pruefung_unmoeglich "grep ${st[1]:-?}, Schreiber ${st[0]:-?}"' 'return 1' 'Posten 5 zurueckgesetzt (Zweig Pruefung nicht moeglich): ein Fehler von grep, etwa ein fehlendes grep (127), gilt wieder als kein Treffer, statt das Gate mit Rueckgabewert 2 zu beenden' 'S10'
mutation_definieren MM21 main '[ $? = 0 ] || pruefung_unmoeglich "Abschnittsbildung"' '[ $? = 0 ] || true' 'Posten 4 a zurueckgesetzt (Abschnittsbildung fail-closed): ein Fehler des sed, das die Abschnitte bildet, wird uebergangen, der Rest bleibt leer und die Eingabe laeuft durch' 'S12'
MM22_SUCH=$(cat <<'X'
sed -zE 's/\\\n|(\\[^\n])/\1/g'
X
)
MM22_ERS=$(cat <<'X'
sed -E ':a; /(^|[^\\])(\\\\)*\\$/ { $!{ N; s/\\\n//; ba } }'
X
)
mutation_definieren MM22 main "$MM22_SUCH" "$MM22_ERS" 'DT-C2-01 zurueckgesetzt: die Zeilenfortsetzung wird wieder mit der Schleife :a; N; ba entfernt, bei 50000 Fortsetzungen quadratisch (ueber 60 s); das Pruefmittel zieht je Gate-Aufruf eine Zeitgrenze von 14 s und wertet Rueckgabewert 124 als Durchlass' 'A105'
MM23_ERS=$(cat <<'X'
tr ';&|' '\n\n\n'
X
)
mutation_definieren MM23 main "$MM17_SUCH" "$MM23_ERS" 'ST-C2-02 zurueckgesetzt: die Abschnitte entstehen wieder mit tr (der Trenner wird durch einen Zeilenumbruch ersetzt statt erhalten); ein main hinter einem Trenner liegt am Zeilenanfang und gilt als Ziel' 'G95'
mutation_definieren MM24 main '[ "${st[1]:-}" = 1 ] && [ "${st[0]:-}" = 0 ] && return 1' '[ "${st[1]:-}" = 1 ] && return 1' 'DT-C2-05 zurueckgesetzt (Posten 5): grep 1 gilt als kein Treffer, auch wenn der Schreiber abgebrochen hat (Vergleich mit dem Schreiber entfernt)' 'S13'
mutation_definieren MP14 prototyp '[ "${st[1]:-}" = 1 ] && [ "${st[0]:-}" = 0 ] && return 1' '[ "${st[1]:-}" = 1 ] && return 1' 'DT-C2-05 zurueckgesetzt (Posten 5) am Prototyp-Gate: grep 1 gilt als kein Treffer, auch wenn der Schreiber abgebrochen hat' 'S14'
mutation_definieren MM25 main '[ $? = 0 ] || pruefung_unmoeglich "Zeilenfortsetzungen"' '[ $? = 0 ] || true' 'ST-C2-06 zurueckgesetzt: ein Fehler des sed, das die Zeilenfortsetzung entfernt, wird uebergangen, cmd_fort bleibt leer und die Eingabe laeuft durch' 'S15'
mutation_definieren MM26 main '[[:space:]]+([^[:space:]-][^[:space:]]*)?/(main|master)' '[[:space:]]+[^[:space:]-][^[:space:]]*/(main|master)' 'DT-C2-03 zurueckgesetzt: die Basename-Form verlangt wieder ein Zeichen vor dem Schraegstrich (/main wird nicht erkannt)' 'A110 A111'
MM27_SUCH=$(cat <<'X'
umleit='(<<<|<<-?|<>|>>|>|<)'
X
)
MM27_ERS=$(cat <<'X'
umleit='(>>?|<)'
X
)
mutation_definieren MM27 main "$MM27_SUCH" "$MM27_ERS" 'DT-C2-04 zurueckgesetzt: <<<, <<, <> samt getrenntem Operanden werden vor der Wortzaehlung nicht entfernt' 'A112 A113 A114 A115'
mutation_definieren MP13 prototyp 'pruefung_unmoeglich "grep ${st[1]:-?}, Schreiber ${st[0]:-?}"' 'return 1' 'Posten 5 zurueckgesetzt (Zweig Pruefung nicht moeglich) am Prototyp-Gate: ein fehlendes grep (127) gilt wieder als kein Treffer, statt das Gate mit Rueckgabewert 2 zu beenden' 'S11'
MM28_SUCH=$(cat <<'X'
s/(^|[[:space:]])${deskr}${umleit}[[:space:]]*${operand}/\1/g; s/${umleit}[[:space:]]*${operand}//g
X
)
MM28_ERS=$(cat <<'X'
s/[0-9]*${umleit}[[:space:]]*${operand}//g
X
)
mutation_definieren MM28 main "$MM28_SUCH" "$MM28_ERS" 'ST-C2-D-07 zurueckgesetzt (Delta 2): eine Ziffer vor dem Umleitungszeichen gilt wieder immer als Dateideskriptor, auch am Wortende (../main1>x verliert das Wortende und wird gesperrt)' 'G102 G103'
MM29_SUCH=$(cat <<'X'
operand='([^[:space:]"'\''\\]|\\.|"([^"\\]|\\.)*("|\\?$)|'\''[^'\'']*('\''|$))*'
X
)
MM29_ERS=$(cat <<'X'
operand='([^[:space:]"'\''\\]|\\.)*'
X
)
mutation_definieren MM29 main "$MM29_SUCH" "$MM29_ERS" 'DT-C2-D-01 zurueckgesetzt (Delta 2): der Operand einer Umleitung kennt keine Anfuehrungszeichen mehr (nur Woerter und maskierte Zeichen); die zweite Haelfte eines Operanden in Anfuehrungszeichen bleibt als zweites Wort stehen und hebt die Sperre auf' 'A120 A121 A122 A123 A124 A125 A126 A127'
mutation_definieren MM30 main 'unset POSIXLY_CORRECT' ':' 'ST-C2-D-01 zurueckgesetzt (Delta 2): das main-Gate entfernt POSIXLY_CORRECT nicht mehr aus seiner Umgebung' 'S17'
mutation_definieren MP15 prototyp 'unset POSIXLY_CORRECT' ':' 'ST-C2-D-01 zurueckgesetzt (Delta 2): das Prototyp-Gate entfernt POSIXLY_CORRECT nicht mehr aus seiner Umgebung' 'S18 S19'
mutation_definieren MM31 main '|| trifft "$basis_alt" -e "$basis_muster"' '' 'DT-C2-E-01 zurueckgesetzt (Delta 3): die Basename-Form laeuft nur noch in der Fassung von Delta 2; ein < oder > in einem Wort in Anfuehrungszeichen vor dem Pfad laesst den Operanden den Pfad verschlucken und die Sperre entfaellt' 'A131 A132 A133 A134 A135 A136'
MM32_SUCH=$(cat <<'X'
deskr='([0-9]+|\{[A-Za-z_][A-Za-z0-9_]*\})'
X
)
MM32_ERS=$(cat <<'X'
deskr='([0-9]+)'
X
)
mutation_definieren MM32 main "$MM32_SUCH" "$MM32_ERS" 'DT-C2-E-02 zurueckgesetzt (Delta 3): ein Wort {name} vor dem Umleitungszeichen ist kein Dateideskriptor mehr; {fd} bleibt als zweites Wort stehen' 'A130'
MM33_SUCH=$(cat <<'X'
"([^"\\]|\\.)*("|\\?$)
X
)
MM33_ERS=$(cat <<'X'
"[^"]*("|$)
X
)
mutation_definieren MM33 main "$MM33_SUCH" "$MM33_ERS" 'ST-C2-E-02 zurueckgesetzt (Delta 3): ein Operand in doppelten Anfuehrungszeichen kennt keine maskierte Anfuehrung mehr; die Anfuehrung endet am maskierten Zeichen und der Rest bleibt als zweites Wort stehen' 'A137 A138 A144 A145'
MM34_SUCH=$(cat <<'X'
"([^"\\]|\\.)*("|\\?$)
X
)
MM34_ERS=$(cat <<'X'
"([^"\\]|\\.)*\\?("|$)
X
)
mutation_definieren MM34 main "$MM34_SUCH" "$MM34_ERS" 'ST-C2-F-01 zurueckgesetzt (Delta 4): der Rueckstrich vor dem schliessenden Anfuehrungszeichen ist wieder zugelassen (Klasse von Delta 3); ein maskiertes Anfuehrungszeichen kann als Rueckstrich plus schliessendes Anfuehrungszeichen gelesen werden (Mischlesung), der Operand verschluckt einen Pfad dahinter oder ein commit-ish' 'A143 A144 A145 G109'
# --- 11a (Fortsetzung). Siebzehn Mutationen der Einheit C3 (MP16 bis MP32; Posten 2, 6 und 7 am Prototyp-Gate) ---
# Posten 2: je geaenderter Stelle des Gates eine Mutation; MP32 schuetzt die Gegenprobe P52 (gewollter Durchlass, Entscheid des Software Architects vom 2026-10-22).
mutation_definieren MP16 prototyp 'require[[:space:]]*\(' 'require\(' 'Posten 2 zurueckgesetzt (C3): require mit Leerraum vor der Klammer wird in beiden Richtungen nicht mehr erkannt (IMPORTWORT wieder mit require\( ohne Leerraum)' 'L05 B66'
mutation_definieren MP17 prototyp '([[:space:]]+url[[:space:]]*\()?' '' 'Posten 2 zurueckgesetzt (C3): @import url( wird in beiden Richtungen nicht mehr erkannt (der optionale Teil url( in IMPORTWORT entfaellt)' 'L06 B67'
mutation_definieren MP18 prototyp "ATTR='(src|href)[[:space:]]*=[[:space:]]*'" "ATTR='(src|href)='" 'Posten 2 zurueckgesetzt (C3): Leerraum um das Gleichheitszeichen bei src und href wird in beiden Richtungen nicht mehr erkannt (ATTR wieder ohne Leerraum)' 'L07 B68 B69 B70 B72 B73'
mutation_definieren MP19 prototyp '-e "(import_module|__import__)[[:space:]]*\([[:space:]]*${Q}prototype${Q}"' '-e "(import_module|__import__)[[:space:]]*\([[:space:]]*${Q}prototypeNIE${Q}"' 'Posten 2 zurueckgesetzt (C3), Richtung 1: __import__ mit dem blossen Modulnamen ohne Punkt wird nicht mehr erkannt (import_module mitgezogen, ohne eigenen Fall)' 'L08'
mutation_definieren MP20 prototyp '-e "(import_module|__import__)[[:space:]]*\([[:space:]]*${Q}(backend|frontend|deploy)${Q}"' '-e "(import_module|__import__)[[:space:]]*\([[:space:]]*${Q}(backend|frontend|deploy)NIE${Q}"' 'Posten 2 zurueckgesetzt (C3), Richtung 2: __import__ mit dem blossen Modulnamen ohne Punkt wird nicht mehr erkannt (import_module mitgezogen, ohne eigenen Fall)' 'B71'
# Posten 6: je geprueftem sed- oder tr-Schritt eine Mutation, die den Aufruf von schritt_geprueft entfernt.
mutation_definieren MP21 prototyp 'schritt_geprueft $? sed "Zeilenkommentare am Bash-Weg"' ':' 'Posten 6 zurueckgesetzt (C3): die Pruefung des Rueckgabewerts des ersten sed-Schritts von cmd_flach (Zeilenkommentare) entfaellt; ein sed, das nur diesen Aufruf verweigert, laesst den Befehl durch' 'S29'
mutation_definieren MP22 prototyp 'schritt_geprueft $? sed "Blockkommentare am Bash-Weg"' ':' 'Posten 6 zurueckgesetzt (C3): die Pruefung des Rueckgabewerts des sed-Schritts der Schleife ueber die Blockkommentare von cmd_flach entfaellt; ein sed, das nur diesen Aufruf verweigert, laesst den Befehl durch' 'S21'
mutation_definieren MP23 prototyp 'schritt_geprueft $? tr "Zeilenumbrueche am Bash-Weg"' ':' 'Posten 6 zurueckgesetzt (C3): die Pruefung des Rueckgabewerts des tr-Schritts von cmd_flach entfaellt; ohne tr laeuft der Befehl durch' 'S20'
mutation_definieren MP24 prototyp 'schritt_geprueft $? sed "Bereinigung der Umleitungsziele am Bash-Weg"' ':' 'Posten 6 zurueckgesetzt (C3): die Pruefung des Rueckgabewerts des sed -E von bereinigt entfaellt; ein sed, das nur sed -E verweigert, laesst den Befehl durch' 'S22'
mutation_definieren MP25 prototyp 'schritt_geprueft $? sed "Zeilenkommentare am Weg der Dateiwerkzeuge"' ':' 'Posten 6 zurueckgesetzt (C3): die Pruefung des Rueckgabewerts des ersten sed-Schritts von payload_norm (Zeilenkommentare) entfaellt; ein sed, das nur diesen Aufruf verweigert, laesst die Datei durch' 'S30'
mutation_definieren MP26 prototyp 'schritt_geprueft $? sed "Blockkommentare am Weg der Dateiwerkzeuge"' ':' 'Posten 6 zurueckgesetzt (C3): die Pruefung des Rueckgabewerts des sed-Schritts der Schleife ueber die Blockkommentare von payload_norm entfaellt; ein sed, das nur diesen Aufruf verweigert, laesst die Datei durch' 'S24'
mutation_definieren MP27 prototyp 'schritt_geprueft $? tr "Zeilenumbrueche am Weg der Dateiwerkzeuge"' ':' 'Posten 6 zurueckgesetzt (C3): die Pruefung des Rueckgabewerts des tr-Schritts von payload_norm entfaellt; ohne tr laeuft ein Import ueber zwei Zeilen durch' 'L24'
# Posten 7: Grenze entfernt, Ueberschreitung als 0, Wache fuer fehlendes timeout, Zweig "jeder andere Ausgang".
mutation_definieren MP28 prototyp 'timeout -k 1 12 "$BASH" "$0" --innerer-lauf-zeitgrenze' '"$BASH" "$0" --innerer-lauf-zeitgrenze' 'Posten 7 zurueckgesetzt (C3): die eigene Zeitgrenze des Gates entfaellt (der innere Lauf wird ohne timeout aufgerufen); ein verlangsamtes cat laeuft bis zur Grenze des Pruefmittels von 14 s und gilt dort als Durchlass' 'S25'
mutation_definieren MP29 prototyp '124|137) echo "Gate prototyp-trennung: Zeitgrenze' '124|137) exit 0 ;; 99) echo "Gate prototyp-trennung: Zeitgrenze' 'Posten 7 zurueckgesetzt (C3): die Ueberschreitung der Zeitgrenze (124, 137) wird als 0 abgebildet statt mit 2 und Meldung' 'S25'
mutation_definieren MP30 prototyp 'if ! command -v timeout >/dev/null 2>&1; then' 'if false; then' 'Posten 7 zurueckgesetzt (C3): die Wache fuer fehlendes timeout entfaellt; der Aufruf scheitert mit 127 und endet ueber den Zweig fuer andere Ausgaenge ohne die Meldung, die timeout nennt' 'S27'
mutation_definieren MP31 prototyp '*) echo "Gate prototyp-trennung: Pruefung abgebrochen (Rueckgabewert' '*) exit 0 ;; 98) echo "Gate prototyp-trennung: Pruefung abgebrochen (Rueckgabewert' 'Posten 7 zurueckgesetzt (C3): jeder andere Ausgang als 0, 2, 124 und 137 (hier timeout mit 125) wird als 0 abgebildet statt mit 2 und Meldung' 'S28'
mutation_definieren MP32 prototyp '-e "(import_module|__import__)[[:space:]]*\([[:space:]]*${Q}(backend|frontend|deploy)${Q}"' '-e "(import_module|__import__|import)[[:space:]]*\([[:space:]]*${Q}(backend|frontend|deploy)${Q}"' 'Posten 2, gewollter Durchlass zurueckgesetzt (C3, Entscheid des Software Architects vom 2026-10-22): die Endung fuer den blossen Modulnamen gilt auch fuer das JS-import( ; import("backend") in einer Prototyp-Datei wird gesperrt (Fehlalarmklasse)' 'P52'

# --- 11b. Fallklassen der Kopfkommentare (ADR 0002, 6.13 d) -----------
fallklasse_definieren KM-1 main gedeckt 'Fall 1: Dateiaenderung, waehrend HEAD auf main/master steht' 'A12 A13 A48'
fallklasse_definieren KM-2 main gedeckt 'Fall 2: Bash-Befehl, der auf main/master committet' 'A10 A47'
fallklasse_definieren KM-3 main gedeckt 'Fall 2: ... merged' 'A14'
fallklasse_definieren KM-4 main gedeckt 'Fall 2: ... pusht' 'A01 A02 A03 A04 A05 A06 A18 A19 A34 A36 G04 ZF1a ZF1b A38 A39 A40 A41 A42'
fallklasse_definieren KM-5 main gedeckt 'die gaengigen Interpreter mit Inline-Code' 'A15 A27 A28 A29'
fallklasse_definieren KM-6 main gedeckt 'das Anlegen eines Arbeitsbaums auf main' 'A07 A08 A09 A37'
fallklasse_definieren KM-7 main gedeckt 'Mirror-/Wildcard-Pushes' 'A16 A17 A35'
fallklasse_definieren KM-8 main gedeckt 'VORAUSSETZUNG git: fehlt git, blockiert das Gate (Rueckgabewert 2)' 'S03'
fallklasse_definieren KM-9 main gedeckt 'analog zur jq-Wache' 'S06'
fallklasse_definieren GM-1 main grenze 'Interpreter, der mit eigener Datei-API schreibt (ohne Inline-Code im Text)' 'G09'
fallklasse_definieren GM-2 main grenze 'zweiter, auf main ausgecheckter Arbeitsbaum, der ausserhalb dieser Sitzung angelegt wurde' 'G10 A43'
fallklasse_definieren GM-3 main grenze 'git vorhanden, aber kein Arbeitsbaum -- ausserhalb eines Repositories' 'ZF4a ZF4b'
fallklasse_definieren GM-4 main grenze 'BEWUSSTE GRENZE: Kontextwechsel in einem untergeordneten Shell-Aufruf' 'ZF2b ZF2c'
fallklasse_definieren KP-1 prototyp gedeckt 'Importe Richtung 1: Produktionscode importiert aus prototype/' 'B01 B04 B27 P02 B45 B47'
fallklasse_definieren KP-2 prototyp gedeckt 'Importe Richtung 2: Prototyp importiert aus dem Produktionscode' 'B05 B22 ZF6e B46 B50'
fallklasse_definieren KM-10 main gedeckt 'unlesbare Eingabe blockiert (ST-13, E4.3)' 'S01 S02 ZF8a ZF8b S08'
fallklasse_definieren KM-11 main gedeckt 'Subshell in Klammern (N-9, E4.3)' 'ZF2a'
fallklasse_definieren KM-12 main gedeckt 'Shell-Schreibwirkung in einem geschuetzten Kontext, inklusive fluechtiger Ziele mit ".." und "/dev/null" ohne Wortgrenze sowie Trenner hinter fluechtigem Ziel (DT-E43-6, DT-E43-8, E4.3-Nachtrag)' 'A11 A50 A51 A52 A53'
fallklasse_definieren KP-3 prototyp gedeckt 'unlesbare Eingabe blockiert (ST-13, E4.3)' 'S04 S05 ZF8c ZF8d S09'
fallklasse_definieren KP-4 prototyp gedeckt 'Schreibwirkung derselben Befehlsklassen wie das main-Gate: Umleitung, tee, sed -i, Heredoc, Dateiwerkzeuge, Interpreter mit Inline-Code, ed/ex, fluechtige Ziele mit ".." und "/dev/null" ohne Wortgrenze sowie Trenner hinter fluechtigem Ziel (DT-E43-6, DT-E43-8)' 'B09 ZF7a ZF7c ZF7d B53 B54 B55 B56 B57 B58 B59 B60 B61 B62 B63'
fallklasse_definieren GP-1 prototyp grenze 'gemeinsame Abhaengigkeiten und ihre Aufloesung (Alias, baseUrl, Workspace) werden nicht geprueft (P-10, E4.3; Aufloesung seit 2026-10-22 benannt, Entscheid SA 2026-10-22)' 'P35'
fallklasse_definieren GP-2 prototyp grenze 'Asymmetrie der Pfadschreibweise in Richtung 2 (Wurzelpfad, Vorspann, src=/href= ohne Schraegstrich oder mit Rueckstrich, doppelter Rueckstrich, mehrfaches ./)' 'L10 L11 L12 L13 L14 L15 L16'
fallklasse_definieren KP-7 prototyp gedeckt 'Posten 2 (C3, 2026-10-22), vormals GP-3 (grenze), seit 2026-10-22 gedeckt: die vier Schreibweisen des Konstrukts in beiden Richtungen an den Dateiwerkzeugen -- Leerraum vor der Klammer bei require, @import url(, Leerraum um das Gleichheitszeichen bei src und href, __import__ mit Modulnamen ohne Punkt (import_module mitgezogen, ohne eigenen Fall und ohne eigene Mutation); gewollter Durchlass (Entscheid des Software Architects vom 2026-10-22): der blosse JS-Modulname import("backend") bleibt frei (P52); JS-Zuweisungen an src/href mit Leerraum sind gesperrt (B72, B73, Gegenproben P53, P54)' 'L05 L06 L07 L08 B66 B67 B68 B69 B70 B71 B72 B73 P42 P43 P44 P45 P46 P47 P48 P49 P50 P51 P52 P53 P54'
fallklasse_definieren KM-13 main gedeckt 'Ziele von push und worktree nach Entfernen von Anfuehrungszeichen, Rueckstrichen, Zeilenfortsetzungen und dem Dollar vor Anfuehrungszeichen verglichen; die Ausnahme fuer -b/-B greift nicht fuer main/master, getrennt, angehaengt oder gebuendelt (Posten 1, 2026-10-14)' 'L01 L02 L03 L04 L18 A54 A55 A56 A57 A58 A59 A60 A61 A62 A63 A64 A67 A68 A69 A70 A71 A72 A73 A74 A75 A76 A77'
fallklasse_definieren GM-5 main grenze "Grenze der Auswertung: Ziele aus Variable, Befehlssubstitution, eval, Brace-Expansion und Escape-Folgen in \$'...'-Wort (hex und oktal) und die Uebersetzung von \$\"...\" ueber einen Meldungskatalog werden nicht erkannt (Posten 1, 2026-10-14); seit Posten 4 a (2026-10-21) auch ein worktree add in einer Befehlssubstitution oder in Rueckwaertsakzenten innerhalb eines Ausnahme-Abschnitts (G88, G89); seit Delta 3 (2026-10-21) auch eine Befehlssubstitution als Umleitungsoperand (G105)" 'G47 G48 G49 G61 G62 G63 G64 G68 G71 G88 G89 G105'
fallklasse_definieren GM-6 main grenze 'Grenze an der Schnittstelle: Werkzeugname ungleich Bash (ZF10a, ZF10b; ADR 0002, 6.13 c, Nachtrag vom 2026-09-23; im Kopfkommentar seit Posten 1)' 'ZF10a ZF10b'
fallklasse_definieren GM-7 main grenze 'Ausnahme fuer -b/-B am Text, nicht an der Syntax der Shell: -b/-B in Anfuehrungszeichen oder Kommentar (DT-B2-05 a/b); als benannter Preis in sperrender Richtung: -b/-B main nur als Inhalt (A78, A79; B2-PM-14); seit Posten 4 b (2026-10-21) auch -b/-B in Anfuehrungszeichen jeder Art oder im Kommentar, auch wenn es erst ueber eine Zeilenfortsetzung neben worktree add rueckt: das Gate entfernt den Rueckstrich vor dem Zeilenumbruch auch dort, wo die Shell ihn nicht entfernt (einfache Anfuehrungszeichen, Kommentar; G80, G93), und liest -b dort als Ausnahme, wo die Shell die Zeile tatsaechlich fortsetzt (doppelte Anfuehrungszeichen; G92)' 'G59 G60 G80 G92 G93 A78 A79'
fallklasse_definieren GM-8 main grenze 'Grenze am Befehlstext: Verb oder Sammel-Push-Option in Anfuehrungszeichen oder hinter Rueckstrich wird nicht erkannt (DT-B2-08)' 'G69 G70'
fallklasse_definieren KM-14 main gedeckt 'Zielpruefung am Befehlstext, nicht am Abschnitt (Preis in sicherer Richtung, Posten 4 a, 2026-10-21): steht nach dem Abziehen der Ausnahme-Abschnitte noch ein worktree add ohne Ausnahme im Text, sperrt jedes main an anderer Stelle derselben Eingabe; Ausweg: getrennte Bash-Aufrufe' 'A89 A90'
fallklasse_definieren KM-15 main gedeckt 'Posten 4 a (DT-B2-05 c, 2026-10-21): die Ausnahme fuer -b/-B gilt nur fuer den worktree-add-Abschnitt, in dem sie steht; Abschnitte trennen ; & | und der Zeilenumbruch' 'L17 A85 A86 A87 A88 A101 A106 A107 A108 A109 S12'
fallklasse_definieren KM-16 main gedeckt 'Posten 4 b (DT-B2-09, 2026-10-21): Verb, Sammel-Push-Optionen und Ausnahme werden auf dem Befehlstext mit entfernten Zeilenfortsetzungen geprueft' 'L19 A91 A92 A104 A105 S15 S16 S17'
fallklasse_definieren KM-17 main gedeckt 'Posten 4 c (Basename-Form, 2026-10-21): ein worktree add ohne Ausnahme mit genau einem Wort, das auf /main oder /master endet, ohne --detach oder -d; Preis (bestehende Klasse Woerter nur als Inhalt): die Phrase als Inhalt sperrt wie schon die bisherige Sperrform (A102, A103); seit Delta 3 (2026-10-21) Preis in sicherer Richtung: schliesst ein Operand in Anfuehrungszeichen erst hinter einem Zeilenumbruch oder ; & |, sieht die Basename-Pruefung das commit-ish nicht (A139, A140); ebenso bei einem Wort in Anfuehrungszeichen mit < oder > hinter dem Pfad (A141, A142) und bei < oder > am Ende eines solchen Worts unmittelbar vor --detach oder -d (A149)' 'L21 A93 A94 A95 A96 A97 A98 A99 A100 A102 A103 A110 A111 A112 A113 A114 A115 A118 A119 A120 A121 A122 A123 A124 A125 A126 A127 A128 A129 A130 A131 A132 A133 A134 A135 A136 A137 A138 A139 A140 A141 A142 A143 A144 A145 A146 A147 A148 A149'
fallklasse_definieren KM-18 main gedeckt 'Posten 5 (SR-001, B2-GATE-D05, 2026-10-21): grosse Eingabe -- der Abbruch des Schreibers gilt nie als kein Treffer; kann eine Pruefung nicht laufen, blockiert das Gate' 'L20 A80 A81 A82 A83 A84 A116 A117 S10 S13'
fallklasse_definieren KP-5 prototyp gedeckt 'Posten 5 (SR-001, B2-GATE-D05, 2026-10-21) am Prototyp-Gate: grosse Eingabe bei Bash und am Dateiinhalt (Richtung 1 und Richtung 2); kann eine Pruefung nicht laufen, blockiert das Gate' 'L22 B64 B65 S11 S14'
fallklasse_definieren KP-6 prototyp gedeckt 'Delta 2 (ST-C2-D-01, 2026-10-21) am Prototyp-Gate: POSIXLY_CORRECT in der Umgebung aendert, wie GNU sed [^\n] liest (Kommentarentfernung); das Gate entfernt die Variable zu Beginn' 'S18 S19'
fallklasse_definieren GM-9 main grenze 'Grenze der Basename-Form (Posten 4 c, 2026-10-21): eine Option mit getrenntem Wert (--reason) zaehlt als zweites Wort, ein Pfad in Anfuehrungszeichen zerfaellt in mehrere Woerter (Leerzeichen, Semikolon, Raute, Umleitungszeichen, Zeilenumbruch; G91, G97 bis G100); seit Delta 3 (2026-10-21) auch eine Option mit getrenntem Wert in Anfuehrungszeichen (G106); seit Delta 4 (2026-10-21) auch < oder > als letztes Zeichen eines Worts in Anfuehrungszeichen vor dem Pfad (G111), ; & | oder ein Zeilenumbruch in einem solchen Wort (G112) und die Verbindung beider Fehlformen aus Delta 3 (G110)' 'G90 G91 G97 G98 G99 G100 G106 G110 G111 G112'
fallklasse_definieren GP-4 prototyp grenze 'Grenze an der Schnittstelle zum Harness: Werkzeugname ungleich Bash (ZF10d; ADR 0002, 6.13 c, Nachtrag vom 2026-09-23; im Kopfkommentar des Prototyp-Gates seit 2026-10-22; Gegenstueck zu GM-6 am main-Gate)' 'ZF10d'
fallklasse_definieren KP-8 prototyp gedeckt 'Posten 6 (C3, 2026-10-22): die sed- und tr-Schritte des Prototyp-Gates pruefen ihren Rueckgabewert -- Bash-Weg cmd_flach (sed, sed der Schleife, tr) und bereinigt (sed), Weg der Dateiwerkzeuge payload_norm (sed, sed der Schleife, tr); jeder andere Ausgang als 0 endet mit Rueckgabewert 2 und einer Meldung mit Werkzeug und Rueckgabewert' 'L23 L24 S20 S21 S22 S23 S24 S29 S30'
fallklasse_definieren KP-9 prototyp gedeckt 'Posten 7, Teil am Prototyp-Gate (C3, 2026-10-22): eigene Zeitgrenze des Gates von 12 s mit Nachlauf 1 s; Ueberschreitung, Fehler von timeout und fehlendes timeout enden mit Rueckgabewert 2 und einer Meldung; Gegenprobe S26' 'S25 S26 S27 S28'

# --- 11c. Abnahmekriterien (Backlog R3-Q-010; ADR 0002, 6.13 f) -------------------------
abnahmekriterium_definieren R3-Q-010_prototyp_gate_pfadformen fallliste 'B02 B03 B06 ZF5a ZF5b ZF5c ZF6a ZF6b ZF5e B43 B45 B46 B50 B51 ZF6f P01 P05 P09 P27 P30 P31 P32' 'geschlossen mit E4.2 (vormals ST-04/ST-05); Gegenproben P01 P05 P09 P27 P30 P31 P32'
abnahmekriterium_definieren R3-Q-010_prototyp_gate_richtungsgleichheit fallliste 'B07 B08 ZF6c ZF6d B35 B41 B42 B44 B47 B48 B49 P10 P02 B34 P28 P29 L05 L06 L07 L08 B66 B67 B68 B69 B70 B71 P42 P43 P44 P45 P46 P47 P48 P49 P50 P51 P52 B72 B73 P53 P54' 'geschlossen mit E4.2 (vormals P-01); Gegenprobe P10; Richtung 1 zum Vergleich P02 B34; Gegenproben P28 P29; Posten 2 (C3, 2026-10-22): L05 bis L08, B66 bis B73, Gegenproben P42 bis P54'
abnahmekriterium_definieren R3-Q-010_prototyp_gate_schreibwirkung fallliste 'B09 ZF7a ZF7c ZF7d ZF7b P06 P14 P15 P33 B52 B53 B54 B55 B56 B57 B58 B59 P36 P37 P38 B60 B61 B62 P39 B63' 'geschlossen mit E4.3 (vormals ST-09); Gegenproben P06 P14 P15 P33 B52 P36 P37; P38 vorgemessen mit Abweichung vom Behebungsauftrag (rc=2 statt 0), gemeldet, nicht angepasst; DT-E43-6 (E4.3-Nachtrag, 2026-09-23) mit B60 B61 B62, Gegenprobe P39; DT-E43-8 (E4.3-Nachtrag, 2026-09-23) mit B63'
abnahmekriterium_definieren R3-Q-010_gates_unlesbare_eingabe fallliste 'S01 S02 ZF8a ZF8b S04 S05 ZF8c ZF8d G01 P04 G40 P34' 'geschlossen mit E4.3 (vormals ST-13); Gegenproben G01 P04 G40 P34'
abnahmekriterium_definieren R3-Q-010_pruefmittel_je_gate gemischt 'G01 G02 G03 G05 G06 P01 P03 P04 P05 MM1 MM2 MM3 MM4 MM5 MP1 MP2 MP3 MP4 MP5 MM7 MM8 MP10 MP11 MM9 MM10 MM11 MM12 MM13 MM14 MM15 MM16 MM17 MM18 MM19 MM20 MM21 MM22 MM23 MM24 MM25 MM26 MM27 MM28 MM29 MM30 MM31 MM32 MM33 MM34 MP12 MP13 MP14 MP15 MP16 MP17 MP18 MP19 MP20 MP21 MP22 MP23 MP24 MP25 MP26 MP27 MP28 MP29 MP30 MP31 MP32' 'Zaehlung je Gate, Mutationsmodus MM1-MM5/MP1-MP5 und MM7/MM8/MP10/MP11 (DT-E43-6, N-3) und MM9 bis MM15 (Posten 1, 2026-10-14) und MM16 bis MM34, MP12 bis MP15 (Posten 4 und 5 sowie Delta, Delta 2, Delta 3 und Delta 4, 2026-10-21), Regressionsschutz G01 G02 G03 G05 G06 P01 P03 P04 P05; MP16 bis MP32 mit C3'
abnahmekriterium_definieren R3-Q-010_main_gate_fremdbelegt fallliste 'A02 A03 A04 A05 A06 A38 A39 A40 A41 A42 A07 A08 A09 S03 G01 G02 G03' 'ST-01 trennscharf im Kontext AK; ST-02/ST-03 behoben; Gegenproben G01 G02 G03'
abnahmekriterium_definieren R3-Q-010_benannte_grenzen fallklassen 'KM-1 KM-2 KM-3 KM-4 KM-5 KM-6 KM-7 KM-8 KM-9 GM-1 GM-2 GM-3 GM-4 KP-1 KP-2 KM-10 KM-11 KM-12 KP-3 KP-4 GP-1 GP-2 KP-7 KM-13 GM-5 GM-6 GM-7 GM-8 KM-14 KM-15 KM-16 KM-17 KM-18 KP-5 GM-9 KP-6 GP-4 KP-8 KP-9' 'Fallklassen der Kopfkommentare; P-10 benannt (GP-1), nicht geschlossen; Posten 1 (2026-10-14): KM-13, GM-5, GM-6, GM-7, GM-8; Posten 4 und 5 (2026-10-21): KM-14 bis KM-18, KP-5, GM-9; Delta 2 (2026-10-21): KP-6; C3: GP-3 ist KP-7 (gedeckt), neu GP-4, KP-8, KP-9'

# -----------------------------------------------------------------------------
# 12. Fallliste -- Teil 4.1 der Fallliste: main-Gate, Soll 2
# -----------------------------------------------------------------------------
faelle_4_1_main_soll2() {
  fall A01 main blockierend 2 MK - voll JSON Bash 'Push nach main; Kopfkommentar Fall 2 (pusht)' "$(bj_ph 'git push origin main')"
  fall A02 main blockierend 2 MK - voll JSON Bash 'ST-01 behoben (Commit 0b3510a3fd8b219c82c093b34be3aff50c68f7e0), Fremdbeleg fehlt bis E4.1, im Kontext MK von der Sperre "Push bei HEAD auf main" ueberdeckt (B-1); trennscharf: A38 bis A41' "$(bj_ph "git push origin 'main'")"
  fall A03 main blockierend 2 MK - voll JSON Bash 'ST-01 behoben, im Kontext MK von der Sperre "Push bei HEAD auf main" ueberdeckt (B-1); trennscharf: A38 bis A41' "$(bj_ph 'git push origin "main"')"
  fall A04 main blockierend 2 MK - voll JSON Bash 'ST-01 behoben, im Kontext MK von der Sperre "Push bei HEAD auf main" ueberdeckt (B-1); trennscharf: A38 bis A41' "$(bj_ph 'git push origin main;')"
  fall A05 main blockierend 2 MK - voll JSON Bash 'ST-01 behoben, im Kontext MK von der Sperre "Push bei HEAD auf main" ueberdeckt (B-1); trennscharf: A38 bis A41' "$(bj_ph '(git push origin main)')"
  fall A06 main blockierend 2 MK - voll JSON Bash 'Befehlskette (2026-09-21 unter ST-01 gefuehrt); die Form mit Leerzeichen nach main traf schon das Muster vor 0b3510a (T-4); trennscharf: A42' "$(bj_ph 'git push origin main && echo ok')"
  fall A07 main blockierend 2 MK - voll JSON Bash 'ST-02 behoben' "$(bj_ph 'git worktree add "/tmp/wt" "main"')"
  fall A08 main blockierend 2 MK - voll JSON Bash 'ST-02 behoben' "$(bj_ph 'git worktree add /tmp/wt main;')"
  fall A09 main blockierend 2 MK - voll JSON Bash 'ST-02 behoben' "$(bj_ph "git worktree add /tmp/wt 'main'")"
  fall A10 main blockierend 2 MK - voll JSON Bash 'Kopfkommentar Fall 2 (committet)' "$(bj_ph 'git commit -m x')"
  fall A11 main blockierend 2 MK - voll JSON Bash 'Shell-Schreibwirkung auf main (2026-08-25)' "$(bj_ph 'echo hallo > datei.txt')"
  fall A12 main blockierend 2 MK - voll JSON Write 'Kopfkommentar Fall 1: Dateiaenderung bei HEAD auf main (absoluter Pfad im Projektbaum)' "$(wj_ph '{MK}/frontend/x.ts' 'const a = 1;')"
  fall A13 main blockierend 2 MK - voll JSON Edit 'Kopfkommentar Fall 1 ueber Edit, relativer Pfad' "$(ej 'frontend/x.ts' 'a' 'b')"
  fall A14 main blockierend 2 MK - voll JSON Bash 'Kopfkommentar Fall 2 (merged)' "$(bj_ph 'git merge feature')"
  fall A15 main blockierend 2 MK - voll JSON Bash 'Kopfkommentar: Interpreter mit Inline-Code (2026-08-25, Runde 2 Nr. 2)' "$(bj_ph "python3 -c 'open(\"x\",\"w\").write(\"a\")'")"
  fall A16 main blockierend 2 AK - voll JSON Bash 'Kopfkommentar: Mirror-Push (2026-08-25, Runde 2 Nr. 3)' "$(bj_ph 'git push --mirror origin')"
  fall A17 main blockierend 2 AK - voll JSON Bash 'Wildcard-Refspec (2026-08-25)' "$(bj_ph "git push origin 'refs/heads/*'")"
  fall A18 main blockierend 2 AK - voll JSON Bash 'Push HEAD:main vom Arbeitszweig (2026-08-25)' "$(bj_ph 'git push origin HEAD:main')"
  fall A19 main blockierend 2 AK - voll JSON Bash 'Push mit --force (2026-08-25)' "$(bj_ph 'git push --force origin main')"
  fall A20 main blockierend 2 MK - voll JSON Bash 'historienveraenderndes Verb auf main (2026-08-25, Runde 1)' "$(bj_ph 'git rebase -i HEAD~2')"
  fall A21 main blockierend 2 MK - voll JSON Bash '2026-08-25, Runde 1' "$(bj_ph 'git reset --hard HEAD~1')"
  fall A22 main blockierend 2 MK - voll JSON Bash '2026-08-25, Runde 1' "$(bj_ph 'git am patch.mbox')"
  fall A23 main blockierend 2 MK - voll JSON Bash 'sed -i auf main (2026-08-25)' "$(bj_ph "sed -i 's/a/b/' datei.txt")"
  fall A24 main blockierend 2 MK - voll JSON Bash 'tee auf main (2026-08-25)' "$(bj_ph 'echo x | tee datei.txt')"
  fall A25 main blockierend 2 MK - voll JSON Bash 'rm auf main (2026-08-25)' "$(bj_ph 'rm -f datei.txt')"
  fall A26 main blockierend 2 MK - voll JSON Bash 'dd of= (2026-08-25, Runde 2 Nr. 2)' "$(bj_ph 'dd if=/dev/zero of=datei.bin bs=1 count=1')"
  fall A27 main blockierend 2 MK - voll JSON Bash 'Interpreter perl -e auf main' "$(bj_ph "perl -e 'print 1'")"
  fall A28 main blockierend 2 MK - voll JSON Bash 'Interpreter node -e auf main' "$(bj_ph 'node -e "console.log(1)"')"
  fall A29 main blockierend 2 MK - voll JSON Bash 'Interpreter php -r auf main' "$(bj_ph "php -r 'echo 1;'")"
  fall A30 main blockierend 2 MK - voll JSON Bash 'schreibender git-Verb' "$(bj_ph 'git cherry-pick abc123')"
  fall A31 main blockierend 2 MK - voll JSON Bash 'schreibender git-Verb' "$(bj_ph 'git stash pop')"
  fall A32 main blockierend 2 MK - voll JSON Bash 'Shell-Schreibwirkung' "$(bj_ph 'mv a.txt b.txt')"
  fall A33 main blockierend 2 MK - voll JSON Bash 'Anfuegende Umleitung' "$(bj_ph 'echo x >> datei.txt')"
  fall A34 main blockierend 2 AK - voll JSON Bash 'master gleichgestellt' "$(bj_ph 'git push origin master')"
  fall A35 main blockierend 2 AK - voll JSON Bash 'Sammel-Push --all (2026-08-25)' "$(bj_ph 'git push --all origin')"
  fall A36 main blockierend 2 AK - voll JSON Bash 'Ref-Form refs/for' "$(bj_ph 'git push origin HEAD:refs/for/main')"
  fall A37 main blockierend 2 AK - voll JSON Bash 'Arbeitsbaum auf master vom Arbeitszweig aus (2026-08-25, Runde 2 Nr. 1)' "$(bj_ph 'git worktree add ../wt master')"
  fall G04 main blockierend 2 MK - voll JSON Bash 'gewollte Wirkung laut Kopfkommentar: Push, waehrend HEAD auf main steht; ADR 0002, 6.13 d: Soll 2 (das Probeskript vom 2026-09-21 fuehrte irrtuemlich 0); Kennung G04 bleibt zur Rueckverfolgung' "$(bj_ph 'git push -u origin claude/arbeitszweig')"
  fall A38 main blockierend 2 AK - voll JSON Bash 'ST-01 behoben -- trennscharf im Arbeitszweig-Kontext (DT-E41-01, B-1): hier greift allein die Zielpruefung der Zeichenklassen, nicht die Sperre "Push bei HEAD auf main"' "$(bj_ph "git push origin 'main'")"
  fall A39 main blockierend 2 AK - voll JSON Bash 'ST-01 behoben, trennscharf (DT-E41-01, B-1)' "$(bj_ph 'git push origin "main"')"
  fall A40 main blockierend 2 AK - voll JSON Bash 'ST-01 behoben, trennscharf (DT-E41-01, B-1)' "$(bj_ph 'git push origin main;')"
  fall A41 main blockierend 2 AK - voll JSON Bash 'ST-01 behoben, trennscharf (DT-E41-01, B-1)' "$(bj_ph '(git push origin main)')"
  fall A42 main blockierend 2 AK - voll JSON Bash 'Befehlskette, trennscharf; die Form mit Leerzeichen nach main traf schon das Muster vor 0b3510a (T-4)' "$(bj_ph 'git push origin main && echo ok')"
  fall A44 main blockierend 2 MK - voll JSON Bash 'schreibender git-Verb (2026-08-25)' "$(bj_ph 'git apply patch.diff')"
  fall A45 main blockierend 2 MK - voll JSON Bash 'schreibender git-Verb (2026-08-25)' "$(bj_ph 'git stash apply')"
  fall A46 main blockierend 2 MK - voll JSON Bash 'schreibender git-Verb (2026-08-25)' "$(bj_ph 'git revert HEAD')"
  fall A47 main blockierend 2 MS - voll JSON Bash 'master gleichgestellt (Kopfkommentar Fall 2)' "$(bj_ph 'git commit -m x')"
  fall A48 main blockierend 2 MS - voll JSON Write 'master gleichgestellt (Kopfkommentar Fall 1)' "$(wj_ph '{MS}/frontend/x.ts' 'const a = 1;')"
  fall A49 main blockierend 2 MS - voll JSON Bash 'Shell-Schreibwirkung bei HEAD auf master' "$(bj_ph 'echo hallo > datei.txt')"
  fall A50 main blockierend 2 MK - voll JSON Bash 'Umleitungsziel mit ".." fuehrt in den Arbeitsbaum zurueck, /tmp-Form (DT-E43-6)' "$(bj_ph 'echo x > /tmp/../{MK}/datei.txt')"
  fall A51 main blockierend 2 MK - voll JSON Bash 'Umleitungsziel mit ".." fuehrt in den Arbeitsbaum zurueck, Variablenform (DT-E43-6)' "$(bj_ph 'echo x > "$TMPDIR"/../{MK}/datei.txt')"
  fall A52 main blockierend 2 MK - voll JSON Bash '"/dev/null" ohne Wortgrenze bleibt Schreibwirkung (DT-E43-6)' "$(bj_ph 'echo x > /dev/nullx')"
  fall A53 main blockierend 2 MK - voll JSON Bash 'Trenner hinter fluechtigem Ziel bleibt Schreibwirkung (DT-E43-8)' "$(bj_ph 'echo x > /tmp/x;cp a {MK}/datei.txt')"
  fall A54 main blockierend 2 AK - voll JSON Bash 'Posten 1 unter R3-Q-010 (ADR 0002, 6.13 c, Nachtrag vom 2026-09-23), geschlossen am 2026-10-14: Anfuehrungszeichen vor und mitten im Wort, Push; Variante von L01' "$(bj_ph 'git push origin "ma"in')"
  fall A55 main blockierend 2 AK - voll JSON Bash 'Posten 1 unter R3-Q-010 (ADR 0002, 6.13 c, Nachtrag vom 2026-09-23), geschlossen am 2026-10-14: Rueckstrich mitten im Wort, Push; Variante von L02' "$(bj_ph 'git push origin ma\in')"
  fall A56 main blockierend 2 AK - voll JSON Bash 'Posten 1 unter R3-Q-010 (ADR 0002, 6.13 c, Nachtrag vom 2026-09-23), geschlossen am 2026-10-14: neuer Zweig main mit -b, die Ausnahme greift nicht, Ausgangspunkt ein anderer Zweig; Variante von L04' "$(bj_ph 'git worktree add -b main /tmp/wt feature')"
  fall A57 main blockierend 2 AK - voll JSON Bash 'Posten 1 unter R3-Q-010 (ADR 0002, 6.13 c, Nachtrag vom 2026-09-23), geschlossen am 2026-10-14: neuer Zweig master mit -B, die Ausnahme greift nicht; Variante von L04' "$(bj_ph 'git worktree add -B master /tmp/wt')"
  fall A58 main blockierend 2 AK - voll JSON Bash 'Posten 1 unter R3-Q-010, DT-B2-02 (Regression des ersten Baus: 0 statt 2, die Ausnahme las cmd_ziel): maskierte Leerzeichen im Pfad lassen die Ausnahme fuer -b/-B nicht greifen, sie liest den Befehlstext; Mutation MM12; geschlossen am 2026-10-14' "$(bj_ph 'git worktree add /tmp/a\ -b\ x main')"
  fall A59 main blockierend 2 AK - voll JSON Bash 'Posten 1 unter R3-Q-010, DT-B2-03 (belegte Luecke): angehaengter Wert -Bmain, die Ausnahme greift nicht; Mutation MM13; geschlossen am 2026-10-14' "$(bj_ph 'git worktree add -Bmain /tmp/wt')"
  fall A60 main blockierend 2 AK - voll JSON Bash 'Posten 1 unter R3-Q-010, DT-B2-03 (belegte Luecke): angehaengter Wert -bmain; Mutation MM13; geschlossen am 2026-10-14' "$(bj_ph 'git worktree add -bmain /tmp/wt')"
  fall A61 main blockierend 2 AK - voll JSON Bash 'Posten 1 unter R3-Q-010, DT-B2-03 (belegte Luecke): angehaengter Wert mit Buchstaben vor b, -fBmain; Mutation MM13; geschlossen am 2026-10-14' "$(bj_ph 'git worktree add -fBmain /tmp/wt')"
  fall A62 main blockierend 2 AK - voll JSON Bash 'Posten 1 unter R3-Q-010, DT-B2-04 (belegte Luecke): Zeilenfortsetzung im Ziel des Push, die Shell macht aus ma, Rueckstrich, Zeilenumbruch, in das Wort main; Mutation MM14; geschlossen am 2026-10-14' "$(bj_ph "$(printf 'git push origin ma\\\nin')")"
  fall A63 main blockierend 2 AK - voll JSON Bash 'Posten 1 unter R3-Q-010, DT-B2-04 (belegte Luecke): Zeilenfortsetzung im Ziel von worktree add; Mutation MM14; geschlossen am 2026-10-14' "$(bj_ph "$(printf 'git worktree add /tmp/wt ma\\\nin')")"
  fall A64 main blockierend 2 AK - voll JSON Bash 'Posten 1 unter R3-Q-010, DT-B2-04 (belegte Luecke): Zeilenfortsetzung hinter -B, der Name ist main; Mutation MM14; geschlossen am 2026-10-14' "$(bj_ph "$(printf 'git worktree add -B \\\nmain /tmp/wt')")"
  fall A65 main blockierend 2 AK - voll JSON Bash 'Regressionsschutz zu DT-B2-04 (heute 2, muss 2 bleiben): ein Zeilenumbruch ohne Rueckstrich verbindet die Zeilen nicht, das -b der zweiten Zeile hebt die Sperre nicht auf' "$(bj_ph "$(printf 'git worktree add /tmp/wt main\ngit checkout -b x')")"
  fall A66 main blockierend 2 AK - voll JSON Bash 'Regressionsschutz zu DT-B2-04 (heute 2, muss 2 bleiben): zwei Rueckstriche vor dem Zeilenumbruch sind ein maskierter Rueckstrich und keine Zeilenfortsetzung' "$(bj_ph "$(printf 'git worktree add /tmp/wt main \\\\\ngit checkout -b x')")"
  fall A67 main blockierend 2 AK - voll JSON Bash 'Posten 1 unter R3-Q-010, DT-B2-06: Rueckstrich mitten im Wort bei worktree add, bisher kein worktree-Fall mit Rueckstrich (Mindestsatz von MM10)' "$(bj_ph 'git worktree add /tmp/wt ma\in')"
  fall A68 main blockierend 2 AK - voll JSON Bash 'Posten 1 unter R3-Q-010, B2-PM-09: das Wort main in Dollar-Anfuehrungszeichen bleibt beim Push gesperrt; Befehlstext UND cmd_ziel zaehlen, und mit dem Dollar-Schritt (DT-B2-07) liefert auch cmd_ziel das Wort main, deshalb bringt MM5 den Fall nicht mehr zu Fall und er steht nicht im Mindestsatz von MM5' "$(bj_ph "git push origin \$'main'")"
  fall A69 main blockierend 2 AK - voll JSON Bash 'Posten 1 unter R3-Q-010, DT-B2-07 (belegte Luecke): Dollar-Anfuehrungszeichen um das Wortende hinter -B, das Wort ist ma und in; Mutation MM15; geschlossen am 2026-10-14' "$(bj_ph "git worktree add -B ma\$'in' /tmp/wt")"
  fall A70 main blockierend 2 AK - voll JSON Bash 'Posten 1 unter R3-Q-010, DT-B2-07 (belegte Luecke): Dollar-Anfuehrungszeichen um den Wortanfang, Ziel von worktree add; Mutation MM15; geschlossen am 2026-10-14' "$(bj_ph "git worktree add /tmp/wt \$'ma'in")"
  fall A71 main blockierend 2 AK - voll JSON Bash 'Posten 1 unter R3-Q-010, DT-B2-07 (belegte Luecke): Dollar vor doppelten Anfuehrungszeichen hinter -B, ohne Meldungskatalog ergibt das Wort main; Mutation MM15; geschlossen am 2026-10-14' "$(bj_ph 'git worktree add -B $"main" /tmp/wt')"
  fall A72 main blockierend 2 AK - voll JSON Bash 'Posten 1 unter R3-Q-010, DT-B2-07 (belegte Luecke): Push, das Wort main mit Dollar-Anfuehrungszeichen um das Wortende; Mutation MM15; geschlossen am 2026-10-14' "$(bj_ph "git push origin ma\$'in'")"
  fall A73 main blockierend 2 AK - voll JSON Bash 'Posten 1 unter R3-Q-010, DT-B2-03 (belegte Luecke, gebuendelte Optionen): -qbmaster, Buchstaben vor b und angehaengter Wert; Mutation MM13; geschlossen am 2026-10-14' "$(bj_ph 'git worktree add -qbmaster /tmp/wt')"
  fall A74 main blockierend 2 AK - voll JSON Bash 'Posten 1 unter R3-Q-010, DT-B2-03: -fB main mit getrenntem Wert und Buchstaben vor B, heute schon 2 (Regressionsschutz: bleibt 2)' "$(bj_ph 'git worktree add -fB main /tmp/wt')"
  fall A75 main blockierend 2 AK - voll JSON Bash 'Regressionsschutz zu DT-B2-07 (heute 2, muss 2 bleiben): -b mit Dollar-Anfuehrungszeichen in einem Pfad in Anfuehrungszeichen hebt die Sperre nicht auf, weil die Ausnahme den Befehlstext liest und nicht cmd_ziel (Mutation MM12)' "$(bj_ph "git worktree add \"/tmp/x \$'-b' y\" main")"
  fall A76 main blockierend 2 AK - voll JSON Bash 'Regressionsschutz zu DT-B2-03 (heute 2, muss 2 bleiben): -fB in einem Pfad in Anfuehrungszeichen hebt die Sperre nicht auf; die Ausnahme gilt nur fuer -b/-B ohne Buchstaben davor' "$(bj_ph 'git worktree add "/tmp/x -fB y" main')"
  fall A77 main blockierend 2 AK - voll JSON Bash 'Preis (B2-GATE-D04): die Shell ergibt ein Wort mit Dollarzeichen vor main; das Zielmuster am Befehlstext wertet das Anfuehrungszeichen vor main (6.13 c zu L01 bis L03)' "$(bj_ph "git push origin \\\$'main'")"
  fall A78 main blockierend 2 AK - voll JSON Bash 'Preis GM-7, sperrende Richtung (B2-PM-14): Inhalt nennt -b/-B main' "$(bj_ph 'git commit -m "Doku: worktree add -b main"')"
  fall A79 main blockierend 2 AK - voll JSON Bash 'Preis GM-7, sperrende Richtung (B2-PM-14): Inhalt nennt -b/-B main' "$(bj_ph 'git worktree add -b feature "/tmp/a -B main"')"
  fall ZF1a main blockierend 2 AK - voll JSON Bash 'Zusatzfall 1 (vollqualifizierte Ref-Form), heute erstmals ausgefuehrt; Kontext AK, damit die Zeichenklassen ":" und "+" der Zielpruefung messen und nicht die Sperre "Push bei HEAD auf main" (N-1)' "$(bj_ph 'git push origin HEAD:refs/heads/main')"
  fall ZF1b main blockierend 2 AK - voll JSON Bash 'Zusatzfall 1 (Pluszeichen); Kontext AK, damit die Zeichenklassen ":" und "+" der Zielpruefung messen und nicht die Sperre "Push bei HEAD auf main" (N-1)' "$(bj_ph 'git push origin +main')"
  fall ZF2a main blockierend 2 AK - voll JSON Bash 'Subshell in Klammern erkannt; Grenze ist der untergeordnete Shell-Aufruf (N-9, E4.3)' "$(bj_ph '(cd {ZM} && git commit -m x)')"
  fall ZF3a main blockierend 2 AK - voll JSON Bash 'Zusatzfall 3 / Befund N1 (2026-08-25): cd auf absoluten Pfad eines main-Auscheckstands' "$(bj_ph 'cd {ZM} && git commit -m x')"
  fall ZF3b main blockierend 2 AK - voll JSON Bash 'Zusatzfall 3: relativer Pfad, Hook-CWD = Projektbaum' "$(bj_ph 'cd ../zweiter-main && git commit -m x')"
  fall ZF3c main blockierend 2 AK / voll JSON Bash 'Zusatzfall 3: relativer Pfad, Hook-CWD = / (Aufloesung gegen CLAUDE_PROJECT_DIR)' "$(bj_ph 'cd ../zweiter-main && git commit -m x')"
  fall ZF3d main blockierend 2 AK - voll JSON Bash 'Zusatzfall 3: pushd' "$(bj_ph 'pushd ../zweiter-main && git commit -m x')"
  fall ZF3e main blockierend 2 AK - voll JSON Bash 'Zusatzfall 3: git -C relativ' "$(bj_ph 'git -C ../zweiter-main commit -m x')"
  fall ZF3f main blockierend 2 AK - voll JSON Bash 'Zusatzfall 3: env -C' "$(bj_ph 'env -C ../zweiter-main git commit -m x')"
  fall ZF3g main blockierend 2 AK / voll JSON Bash 'Zusatzfall 3: git -C absolut, Hook-CWD = /' "$(bj_ph 'git -C {ZM} commit -m x')"
  fall ZF3h main blockierend 2 AK - voll JSON Bash 'Zusatzfall 3 / N1: Shell-Schreibwirkung im gewechselten Kontext' "$(bj_ph 'cd ../zweiter-main && sed -i s/a/b/ datei.txt')"
  fall S03 main blockierend 2 MK - ohne-git JSON Bash 'ST-03 behoben: git fehlt im Suchpfad, Gate blockiert mit Meldung auf stderr' "$(bj_ph 'git commit -m x')"
  fall S06 main blockierend 2 MK - ohne-jq JSON Bash 'jq-Wache des main-Gates (Kopfkommentar "analog zur jq-Wache")' "$(bj_ph 'git status')"
  fall S10 main blockierend 2 AK - ohne-grep JSON Bash 'Posten 5 unter R3-Q-010 (SR-001): fehlt grep im Suchpfad, kann das Gate nicht pruefen und blockiert mit Meldung auf stderr (vorher Durchlass, gemessen 0); Zweig Pruefung nicht moeglich der Hilfsfunktion trifft; Mutation MM20' "$(bj_ph 'git status')"
  fall S12 main blockierend 2 AK - sed-ohne-trenner JSON Bash 'Posten 4 a unter R3-Q-010, Abschnittsbildung fail-closed (Delta 2026-10-21): scheitert das sed, das die Abschnitte bildet (hier nachgebildet; die uebrigen sed-Aufrufe laufen), kann das Gate die Abschnitte nicht bilden und blockiert mit Meldung auf stderr; mit vollem PATH ist dieselbe Eingabe zulaessig (G03); Mutation MM21' "$(bj_ph 'git worktree add -b x /tmp/wt main')"
  fall S13 main blockierend 2 AK - grep-attrappe JSON Bash 'DT-C2-05 (Delta 2026-10-21): grep endet mit 1, ohne zu lesen (Attrappe); der Schreiber bricht ab (141), kein Treffer ist dann nicht glaubwuerdig und das Gate blockiert; Mutation MM24' "$(bj_gross 'git status')"
  fall S15 main blockierend 2 AK - sed-ohne-z JSON Bash 'ST-C2-06 (Delta 2026-10-21): ein sed ohne -z (Attrappe) kann die Zeilenfortsetzung nicht entfernen; das Gate blockiert mit Meldung auf stderr; Mutation MM25' "$(bj_ph 'git status')"
  fall S16 main blockierend 2 AK - ohne-sed JSON Bash 'ST-C2-06 (Delta 2026-10-21): fehlt sed im Suchpfad, kann das Gate die Zeilenfortsetzung nicht entfernen und blockiert mit Meldung auf stderr (das alte Gate gab hier 0)' "$(bj_ph 'git status')"
  fall S17 main blockierend 2 AK - posix JSON Bash 'ST-C2-D-01 (Delta 2 2026-10-21): POSIXLY_CORRECT=1 in der Umgebung des Gates; GNU sed liest dann [^\n] als "nicht Rueckstrich und nicht n", zwei Rueckstriche vor dem Zeilenumbruch galten als Fortsetzung, das -b dahinter als Ausnahme, der Befehl lief durch (rc 0); das Gate entfernt die Variable zu Beginn; Mutation MM30' "$(bj_ph $'git worktree add \'/tmp/a\\\\\n -b x\' main')"
  fall A80 main blockierend 2 AK - voll JSON Bash 'Posten 5 unter R3-Q-010 (SR-001, B2-GATE-D05): grosse Eingabe, Sammel-Push --mirror mit einer Kommentarzeile aus 200000 Zeichen; Pruefstellen Verb und Sammel-Push-Option ohne Abbruch des Schreibers' "$(bj_gross 'git push --mirror origin')"
  fall A81 main blockierend 2 AK - voll JSON Bash 'Posten 5 unter R3-Q-010 (SR-001, B2-GATE-D05): grosse Eingabe, Arbeitsbaum auf main mit einer Kommentarzeile aus 200000 Zeichen; Pruefstellen wt_add und Zielmuster ohne Abbruch des Schreibers' "$(bj_gross 'git worktree add /tmp/wt main')"
  fall A82 main blockierend 2 AK - voll JSON Bash 'Posten 5 unter R3-Q-010 (SR-001, B2-GATE-D05): grosse Eingabe, -B main mit einer Kommentarzeile aus 200000 Zeichen; Pruefstelle Namenspruefung ohne Abbruch des Schreibers' "$(bj_gross 'git worktree add -B main /tmp/wt')"
  fall A83 main blockierend 2 MK - voll JSON Bash 'Posten 5 unter R3-Q-010 (SR-001, B2-GATE-D05): grosse Eingabe, schreibendes git-Verb auf main mit einer Kommentarzeile aus 200000 Zeichen; Pruefstelle schreibende Verben ohne Abbruch des Schreibers' "$(bj_gross 'git commit -m x')"
  fall A84 main blockierend 2 MK - voll JSON Bash 'Posten 5 unter R3-Q-010 (SR-001, B2-GATE-D05): grosse Eingabe, Shell-Schreibwirkung auf main mit einer Kommentarzeile aus 200000 Zeichen; Pruefstelle Schreibwirkung ohne Abbruch des Schreibers' "$(bj_gross 'echo hallo > datei.txt')"
  fall A85 main blockierend 2 AK - voll JSON Bash 'Posten 4 a unter R3-Q-010 (DT-B2-05 c): die Ausnahme fuer -b/-B gilt nur fuer den worktree-add-Abschnitt, in dem sie steht; Trenner &&' "$(bj_ph 'git worktree add -b x /tmp/w1 main && git worktree add /tmp/w2 main')"
  fall A86 main blockierend 2 AK - voll JSON Bash 'Posten 4 a unter R3-Q-010 (DT-B2-05 c): die Ausnahme gilt nur im eigenen Abschnitt; Trenner Zeilenumbruch' "$(bj_ph $'git worktree add -b x /tmp/w1 main\ngit worktree add /tmp/w2 main')"
  fall A87 main blockierend 2 AK - voll JSON Bash 'Posten 4 a unter R3-Q-010 (DT-B2-05 c): die Ausnahme gilt nur im eigenen Abschnitt; Trenner ||' "$(bj_ph 'git worktree add -b x /tmp/w1 main || git worktree add /tmp/w2 main')"
  fall A88 main blockierend 2 AK - voll JSON Bash 'Posten 4 a unter R3-Q-010 (DT-B2-05 c): die Ausnahme gilt nur im eigenen Abschnitt; Trenner |' "$(bj_ph 'git worktree add -b x /tmp/w1 main | git worktree add /tmp/w2 main')"
  fall A89 main blockierend 2 AK - voll JSON Bash 'Preis in sicherer Richtung, vorbestehend, von Posten 4 a nicht geaendert: ein worktree add ohne Ausnahme sperrt, wenn main an anderer Stelle derselben Eingabe steht (die Zielpruefung liest den Befehlstext, nicht den Abschnitt)' "$(bj_ph 'git worktree add /tmp/w2 feature; git log main')"
  fall A90 main blockierend 2 AK - voll JSON Bash 'Preis Posten 4 a (gemessen vorher 0): nach dem Abschneiden des Ausnahme-Abschnitts bleibt ein worktree add ohne Ausnahme, und main steht an anderer Stelle; gesperrt wie A89, dieselbe Klasse' "$(bj_ph 'git worktree add -b x /tmp/w1 main; git worktree add /tmp/w2 feature; git log main')"
  fall A91 main blockierend 2 AK - voll JSON Bash 'Posten 4 b unter R3-Q-010 (DT-B2-09): das Verb worktree add durch eine Zeilenfortsetzung getrennt' "$(bj_ph $'git worktree \\\nadd /tmp/wt main')"
  fall A92 main blockierend 2 AK - voll JSON Bash 'Posten 4 b unter R3-Q-010 (DT-B2-09): die Sammel-Push-Option --all durch eine Zeilenfortsetzung getrennt' "$(bj_ph $'git push origin --\\\nall')"
  fall A93 main blockierend 2 AK - voll JSON Bash 'Posten 4 c unter R3-Q-010 (Basename-Form): ein Wort, das auf /master endet, kein commit-ish' "$(bj_ph 'git worktree add /tmp/wt/master')"
  fall A94 main blockierend 2 AK - voll JSON Bash 'Posten 4 c unter R3-Q-010 (Basename-Form): Option vor dem Wort' "$(bj_ph 'git worktree add -f ../main')"
  fall A95 main blockierend 2 AK - voll JSON Bash 'Posten 4 c unter R3-Q-010 (Basename-Form): Option hinter dem Wort' "$(bj_ph 'git worktree add ../main -q')"
  fall A96 main blockierend 2 AK - voll JSON Bash 'Posten 4 c unter R3-Q-010 (Basename-Form): Pfad in Anfuehrungszeichen' "$(bj_ph 'git worktree add "../main"')"
  fall A97 main blockierend 2 AK - voll JSON Bash 'Posten 4 c unter R3-Q-010 (Basename-Form): ein Kommentar hinter dem Wort zaehlt nicht als zweites Wort' "$(bj_ph 'git worktree add ../main # neu')"
  fall A98 main blockierend 2 AK - voll JSON Bash 'Posten 4 c unter R3-Q-010 (Basename-Form): Umleitungen hinter dem Wort zaehlen nicht als Woerter' "$(bj_ph 'git worktree add ../main >/dev/null 2>&1')"
  fall A99 main blockierend 2 AK - voll JSON Bash 'Posten 4 c unter R3-Q-010 (Basename-Form): schliessende Klammer einer Subshell hinter dem Wort' "$(bj_ph '(git worktree add ../main)')"
  fall A100 main blockierend 2 AK - voll JSON Bash 'Posten 4 c unter R3-Q-010 (Basename-Form): im Abschnitt hinter &&' "$(bj_ph 'git status && git worktree add ../main')"
  fall A101 main blockierend 2 AK - voll JSON Bash 'Posten 4 a unter R3-Q-010 (DT-B2-05 c): die Reihenfolge der Abschnitte spielt keine Rolle, der Abschnitt ohne Ausnahme steht vorn' "$(bj_ph 'git worktree add /tmp/w2 main; git worktree add -b x /tmp/w1 main')"
  fall A102 main blockierend 2 AK - voll JSON Bash 'Preis, Woerter nur als Inhalt (bestehende Klasse, Fallklasse KM-17 von Posten 4 c, nicht GM-7): die Phrase git worktree add ../main steht nur als Inhalt (echo in Anfuehrungszeichen); gemessen vorher 0; Ausweg: den Text mit dem Write-Werkzeug in eine Datei schreiben' "$(bj_ph 'echo "git worktree add ../main" > /tmp/x.txt')"
  fall A103 main blockierend 2 AK - voll JSON Bash 'Vergleichsfall zu A102, Woerter nur als Inhalt: die bisherige Sperrform als Inhalt (git worktree add mit main als Ziel in einer Commit-Meldung) sperrt vorher wie nachher; Ausweg: git commit -F <datei>' "$(bj_ph 'git commit -m "Doku: git worktree add /tmp/wt main"')"
  fall A104 main blockierend 2 AK - voll JSON Bash 'Posten 4 b, Delta DT-C2-01 (2026-10-21): zwei Zeilenfortsetzungen hintereinander (Gleichheit mit der alten Schleife); eine Form, die das Kontextzeichen verbraucht, liesse hier die zweite stehen' "$(bj_ph $'git \\\n\\\npush origin main')"
  fall A105 main blockierend 2 AK - voll JSON Bash 'DT-C2-01 (Delta 2026-10-21): 50000 Zeilenfortsetzungen (300 KB); die Schleife :a;N;ba brauchte dafuer ueber 60 s und riss die Hook-Grenze von 15 s (der Harness laesst dann durch); das Pruefmittel zieht je Gate-Aufruf eine Zeitgrenze von 14 s und wertet Rueckgabewert 124 als Durchlass; Mutation MM22 (alte Schleife)' "$(bj_fort 'git push origin main')"
  fall A106 main blockierend 2 AK - voll JSON Bash 'ST-C2-02 (Delta 2026-10-21): ein Trenner (&&) vor worktree add; der Trenner bleibt am Anfang des Abschnitts, die Basename-Form (Posten 4 c) muss ihn zulassen' "$(bj_ph 'true && git worktree add ../main')"
  fall A107 main blockierend 2 AK - voll JSON Bash 'ST-C2-02 (Delta 2026-10-21): ein Trenner (;) vor worktree add; die Basename-Form muss ihn zulassen' "$(bj_ph 'x; git worktree add ../main')"
  fall A108 main blockierend 2 AK - voll JSON Bash 'ST-C2-02 (Delta 2026-10-21): ein Trenner (|) vor worktree add; die Basename-Form muss ihn zulassen' "$(bj_ph 'x | git worktree add ../main')"
  fall A109 main blockierend 2 AK - voll JSON Bash 'ST-C2-02 (Delta 2026-10-21): ein Trenner vor worktree add mit main als commit-ish; das Zielmuster sieht main hinter einem Leerzeichen' "$(bj_ph 'true && git worktree add /tmp/w2 main')"
  fall A110 main blockierend 2 AK - voll JSON Bash 'DT-C2-03 (Delta 2026-10-21): Basename-Form ohne Praefix vor dem Schraegstrich; der Pfad /main legt den Arbeitsbaum auf main an; Mutation MM26' "$(bj_ph 'git worktree add /main')"
  fall A111 main blockierend 2 AK - voll JSON Bash 'DT-C2-03 (Delta 2026-10-21): wie A110 mit master und einer Option davor' "$(bj_ph 'git worktree add -f /master')"
  fall A112 main blockierend 2 AK - voll JSON Bash 'DT-C2-04 (Delta 2026-10-21): Umleitung <<< mit getrenntem Operanden zaehlt nicht als zweites Wort; Mutation MM27' "$(bj_ph 'git worktree add ../main <<< x')"
  fall A113 main blockierend 2 AK - voll JSON Bash 'DT-C2-04 (Delta 2026-10-21): der Operand von <<< sieht aus wie eine Option (-d) und darf die Sperre nicht aufheben' "$(bj_ph 'git worktree add ../main <<< -d')"
  fall A114 main blockierend 2 AK - voll JSON Bash 'DT-C2-04 (Delta 2026-10-21): Heredoc (<<) mit getrenntem Wort hinter dem Pfad' "$(bj_ph $'git worktree add ../main << x\nx')"
  fall A115 main blockierend 2 AK - voll JSON Bash 'DT-C2-04 (Delta 2026-10-21): Umleitung <> mit getrenntem Operanden' "$(bj_ph 'git worktree add ../main <> x')"
  fall A116 main blockierend 2 AK - voll JSON Bash 'H-1 (Delta 2026-10-21): die sed-Ausdruecke der Basename-Form bleiben bei einer Zeile aus 150000 Leerzeichen linear (gemessen 0,22 s im Endstand nach Delta 3; vorher 0,23 s und 0,20 s); bei einem quadratischen Ausdruck uebersteigt der Lauf die Zeitgrenze von 14 s und das Pruefmittel wertet das als Durchlass' "$(bj_zeile $'git worktree add -b x /tmp/w1 feature\ngit push origin main' "#${LEER}x)")"
  fall A117 main blockierend 2 AK - voll JSON Bash 'H-1 (Delta 2026-10-21): wie A116 mit einer Zeile aus 150000 Ziffern und einem Umleitungszeichen am Ende (gemessen 0,25 s im Endstand nach Delta 3; vorher 0,21 s und 0,18 s)' "$(bj_zeile $'git worktree add -b x /tmp/w1 feature\ngit push origin main' "#${ZIFF}x>")"
  fall A118 main blockierend 2 AK - voll JSON Bash 'ST-C2-D-07 (Delta 2 2026-10-21), Gegenprobe zu G102: eine Ziffer nach Leerraum vor dem Umleitungszeichen ist ein Dateideskriptor und faellt mit der Umleitung weg; der Arbeitsbaum entsteht auf main' "$(bj_ph 'git worktree add ../main 2>/dev/null')"
  fall A119 main blockierend 2 AK - voll JSON Bash 'ST-C2-D-07 (Delta 2 2026-10-21): eine Umleitung am Wort ohne Ziffer davor faellt weg; Gegenprobe zu G102 und G103' "$(bj_ph 'git worktree add ../main>x')"
  fall A120 main blockierend 2 AK - voll JSON Bash 'DT-C2-D-01 (Delta 2 2026-10-21): <<< mit einem Operanden in doppelten Anfuehrungszeichen mit Leerraum; die zweite Haelfte blieb als zweites Wort stehen (commit-ish), die Sperre entfiel, obwohl git den Arbeitsbaum auf main anlegt; Mutation MM29' "$(bj_ph 'git worktree add ../main <<< "a b"')"
  fall A121 main blockierend 2 AK - voll JSON Bash 'DT-C2-D-01 (Delta 2 2026-10-21): wie A120 mit einfachen Anfuehrungszeichen' "$(bj_ph "git worktree add ../main <<< 'a b'")"
  fall A122 main blockierend 2 AK - voll JSON Bash 'DT-C2-D-01 (Delta 2 2026-10-21): wie A120 ohne Leerraum vor dem Operanden' "$(bj_ph 'git worktree add ../main <<<"a b"')"
  fall A123 main blockierend 2 AK - voll JSON Bash 'DT-C2-D-01 (Delta 2 2026-10-21): Eingabeumleitung < mit Operanden in Anfuehrungszeichen mit Leerraum' "$(bj_ph 'git worktree add ../main < "a b"')"
  fall A124 main blockierend 2 AK - voll JSON Bash 'DT-C2-D-01 und ST-C2-D-06 (Delta 2 2026-10-21): Ausgabeumleitung > mit Operanden in Anfuehrungszeichen mit Leerraum; der fuer ST-C2-D-06 geplante Fall mit Soll 0 entfaellt, weil die Luecke geschlossen ist' "$(bj_ph 'git worktree add ../main > "a b"')"
  fall A125 main blockierend 2 AK - voll JSON Bash 'DT-C2-D-01 (Delta 2 2026-10-21): Dateideskriptor 2 mit Leerraum davor und Operanden in Anfuehrungszeichen' "$(bj_ph 'git worktree add ../main 2> "/tmp/a b"')"
  fall A126 main blockierend 2 AK - voll JSON Bash 'DT-C2-D-01 (Delta 2 2026-10-21): >> mit drei Woertern in Anfuehrungszeichen' "$(bj_ph 'git worktree add ../main >> "a b c"')"
  fall A127 main blockierend 2 AK - voll JSON Bash 'DT-C2-D-01 (Delta 2 2026-10-21): der Pfad selbst steht in Anfuehrungszeichen, dahinter <<< mit Operanden in Anfuehrungszeichen' "$(bj_ph 'git worktree add "../main" <<< "a b"')"
  fall A128 main blockierend 2 AK - voll JSON Bash 'DT-C2-D-01 (Delta 2 2026-10-21): Operand mit maskiertem Leerzeichen' "$(bj_ph 'git worktree add ../main <<< a\ b')"
  fall A129 main blockierend 2 AK - voll JSON Bash 'DT-C2-D-01 (Delta 2 2026-10-21): eine Anfuehrung, die am Zeilenende nicht geschlossen ist (sie schliesst in der naechsten Zeile), reicht fuer den Operanden bis zum Zeilenende; Mutation MM29' "$(bj_ph $'git worktree add ../main > "a\nb"')"
  fall A130 main blockierend 2 AK - voll JSON Bash 'DT-C2-E-02 (Delta 3 2026-10-21): ein Wort {name} vor dem Umleitungszeichen ist wie eine Ziffer ein Dateideskriptor (bash: {fd}>/dev/null); vorher blieb {fd} als zweites Wort stehen und hob die Sperre auf; Mutation MM32' "$(bj_ph 'git worktree add ../main {fd}>/dev/null')"
  fall A131 main blockierend 2 AK - voll JSON Bash 'DT-C2-E-01 (Delta 3 2026-10-21): < oder > in einem Wort in Anfuehrungszeichen vor dem Pfad; die Fassung von Delta 2 las die schliessende Anfuehrung als offene, der Operand nahm den Pfad mit und die Sperre entfiel (vor Delta 2: 2, mit Delta 2: 0); die zweite Fassung sperrt; Mutation MM31' "$(bj_ph 'git worktree add --lock --reason="a>b" ../main')"
  fall A132 main blockierend 2 AK - voll JSON Bash 'DT-C2-E-01 (Delta 3 2026-10-21): wie A131 mit einfachen Anfuehrungszeichen und <' "$(bj_ph "git worktree add --lock --reason='a<b' ../main")"
  fall A133 main blockierend 2 AK - voll JSON Bash 'DT-C2-E-01 (Delta 3 2026-10-21): wie A131, das Wort mit > steht in einer Option vor worktree' "$(bj_ph 'git -c "core.dstprobe=a>b" worktree add ../main')"
  fall A134 main blockierend 2 AK - voll JSON Bash 'DT-C2-E-01 (Delta 3 2026-10-21): wie A131, das Wort mit > ist eine Variablenzuweisung vor dem Befehl' "$(bj_ph 'X="a>b" git worktree add ../main')"
  fall A135 main blockierend 2 AK - voll JSON Bash 'DT-C2-E-01 (Delta 3 2026-10-21): wie A134 mit einfachen Anfuehrungszeichen, < und master' "$(bj_ph "X='a<b' git worktree add ../master")"
  fall A136 main blockierend 2 AK - voll JSON Bash 'DT-C2-E-01 (Delta 3 2026-10-21): wie A131 mit einer echten Umleitung 2>/dev/null am Ende' "$(bj_ph 'git worktree add --lock --reason="a>b" ../main 2>/dev/null')"
  fall A137 main blockierend 2 AK - voll JSON Bash 'ST-C2-E-02 (Delta 3 2026-10-21, deckt DT-C2-E-02 R6): maskierte Anfuehrung in einem Operanden in doppelten Anfuehrungszeichen; die Anfuehrung endete am maskierten Zeichen und der Rest blieb als zweites Wort stehen; Mutation MM33' "$(bj_ph 'git worktree add ../main <<< "a\"b c"')"
  fall A138 main blockierend 2 AK - voll JSON Bash 'ST-C2-E-02 (Delta 3 2026-10-21): wie A137 mit Leerraum um die maskierte Anfuehrung und einer Ausgabeumleitung' "$(bj_ph 'git worktree add ../main > "a \" b"')"
  fall A139 main blockierend 2 AK - voll JSON Bash 'ST-C2-E-01 (SST Delta 2, Delta 3 2026-10-21), Preis in sicherer Richtung (KM-17), Preis, Operand ueber Abschnittsgrenze: schliesst der Operand in Anfuehrungszeichen erst hinter einem Zeilenumbruch, sieht die Basename-Pruefung das commit-ish (feature) nicht mehr und sperrt; vor Delta 2: 0' "$(bj_ph $'git worktree add ../main <<< "a c\nb" feature')"
  fall A140 main blockierend 2 AK - voll JSON Bash 'ST-C2-E-01 (Delta 3 2026-10-21), Preis in sicherer Richtung (KM-17), Preis, Operand ueber Abschnittsgrenze, hier ein Semikolon in der Anfuehrung; vor Delta 2: 0' "$(bj_ph 'git worktree add ../main > "a c;b" feature')"
  fall A141 main blockierend 2 AK - voll JSON Bash 'ST-C2-E-01 (Delta 3 2026-10-21), Preis in sicherer Richtung (KM-17), Preis, Operand ueber Wortgrenze: ein < oder > in einem Wort in Anfuehrungszeichen HINTER dem Pfad laesst die Fassung von Delta 2 den Rest des Abschnitts (hier das commit-ish feature) verschlucken; die Basename-Pruefung sperrt; vor Delta 2: 0' "$(bj_ph 'git worktree add ../main --lock --reason="a>b" feature')"
  fall A142 main blockierend 2 AK - voll JSON Bash 'ST-C2-E-01 (Delta 3 2026-10-21), Preis in sicherer Richtung (KM-17), Preis, Operand ueber Wortgrenze: wie A141, verschluckt wird --detach; vor Delta 2: 0' "$(bj_ph 'git worktree add ../main --reason="a>b" --detach')"
  fall A143 main blockierend 2 AK - voll JSON Bash 'ST-C2-F-01 (Delta 4 2026-10-21), R1: der Operand "a b\"c"d\" ist laut Shell ein Wort (a b"cd"), dahinter steht der Pfad; die Mischlesung (maskiertes " als Rueckstrich plus schliessende Anfuehrung) verschluckte den Pfad und die Sperre entfiel (Delta 2: 2, Delta 3: 0); Mutation MM34' "$(bj_ph 'git worktree add > "a b\"c"d\" ../main')"
  fall A144 main blockierend 2 AK - voll JSON Bash 'ST-C2-F-01 (Delta 4 2026-10-21), R3: maskierte Anfuehrungen in einem Operanden hinter 2> verschluckten den Pfad (Delta 3: 0); Mutation MM33 und MM34' "$(bj_ph 'git worktree add 2> "err \"1\".log" ../main')"
  fall A145 main blockierend 2 AK - voll JSON Bash 'ST-C2-F-01 (Delta 4 2026-10-21), R4: wie A144 mit einer Ausgabeumleitung (Delta 3: 0); Mutation MM33 und MM34' "$(bj_ph 'git worktree add > "out \"q\"" ../main')"
  fall A146 main blockierend 2 AK - voll JSON Bash 'ST-C2-F-01 (Delta 4 2026-10-21), R5: ein Rueckstrich unmittelbar vor dem Zeilenende (hier vor dem Trenner |) bleibt zugelassen; der Pfad steht vor der Umleitung' "$(bj_ph 'git worktree add ../main > "a b\|c"')"
  fall A147 main blockierend 2 AK - voll JSON Bash 'DT-C2-F-03 (Delta 4 2026-10-21): ein Deskriptor {name} mit Ziffer im Namen; eine auf Kleinbuchstaben beschraenkte Klasse (Mutation X5 des DST) liesse {fd2} als zweites Wort stehen' "$(bj_ph 'git worktree add ../main {fd2}>/dev/null')"
  fall A148 main blockierend 2 AK - voll JSON Bash 'DT-C2-F-03 (Delta 4 2026-10-21): ein Deskriptor {NAME} in Grossbuchstaben' "$(bj_ph 'git worktree add ../main {FD}>/dev/null')"
  fall A149 main blockierend 2 AK - voll JSON Bash 'DT-C2-F-04 (Delta 4 2026-10-21), Preis in sicherer Richtung (KM-17), Preis, Operand ueber Wortgrenze: ein < oder > am Ende eines Worts in Anfuehrungszeichen unmittelbar vor --detach laesst die zweite Fassung --detach als Operanden lesen und sperren; vor Delta 2: 2, mit Delta 2: 0' "$(bj_ph 'git worktree add --lock --reason="a>" --detach ../main')"
}

# -----------------------------------------------------------------------------
# 13. Fallliste -- Teil 4.2 der Fallliste: main-Gate, Soll 0
# -----------------------------------------------------------------------------
faelle_4_2_main_soll0() {
  fall G01 main durchlaufend 0 MK - voll JSON Bash 'Gegenprobe 2026-09-21 (Regressionsschutz ADR 0002, 6.13 f Punkt 2)' "$(bj_ph 'git status')"
  fall G02 main durchlaufend 0 MK - voll JSON Bash 'Ausweg von main herunter (Regressionsschutz)' "$(bj_ph 'git switch -c claude/neu')"
  fall G03 main durchlaufend 0 MK - voll JSON Bash 'neuer Zweig ab main (Falsch-Positiv-Befund 2026-08-25; Regressionsschutz)' "$(bj_ph 'git worktree add -b claude/neu /tmp/wt main')"
  fall G05 main durchlaufend 0 MK - voll JSON Bash 'Suchen und Lesen (Regressionsschutz)' "$(bj_ph 'grep -rn main docs/')"
  fall G06 main durchlaufend 0 MK - voll JSON Bash 'Umleitung in fluechtiges Ziel (Regressionsschutz)' "$(bj_ph 'echo hallo > /dev/null')"
  fall G07 main durchlaufend 0 AK - voll JSON Write 'Fall 1 Gegenprobe: Schreiben auf einem Arbeitszweig' "$(wj_ph '{AK}/frontend/x.ts' 'const a = 1;')"
  fall G08 main durchlaufend 0 MK - voll JSON Write 'Pfad ausserhalb des Projektbaums: Gate nicht zustaendig' "$(wj_ph '/tmp/anderswo/x.ts' 'const a = 1;')"
  fall G09 main grenze 0 MK - voll JSON Bash 'Kopfkommentar: Interpreter, der mit eigener Datei-API schreibt, ohne Inline-Code im Text -- benannte Grenze' "$(bj_ph 'python3 skript.py')"
  fall G10 main grenze 0 AK - voll JSON Bash 'Kopfkommentar: zweiter, auf main ausgecheckter Arbeitsbaum, dessen Pfad nicht im Text steht -- benannte Grenze' "$(bj_ph 'cd "$ZWEITER" && git commit -m x')"
  fall G11 main durchlaufend 0 AK - voll JSON Bash 'Zweigname mit "main" als Teil bleibt frei (2026-08-25)' "$(bj_ph 'git push origin fix/main-seite')"
  fall G12 main durchlaufend 0 MK - voll JSON Bash 'fluechtiges Ziel /tmp' "$(bj_ph 'echo x > /tmp/datei.txt')"
  fall G13 main durchlaufend 0 AK - voll JSON Bash 'Push vom Arbeitszweig (Gegenprobe zu G04)' "$(bj_ph 'git push -u origin claude/arbeitszweig')"
  fall G14 main durchlaufend 0 AK - voll JSON Bash 'Commit auf dem Arbeitszweig (Gegenprobe zu A10)' "$(bj_ph 'git commit -m x')"
  fall G15 main durchlaufend 0 AK - voll JSON Bash 'Shell-Schreiben auf dem Arbeitszweig (Gegenprobe zu A11)' "$(bj_ph 'echo hallo > datei.txt')"
  fall G16 main durchlaufend 0 AK - voll JSON Bash 'cd in Nicht-Git-Verzeichnis (2026-08-25, Runde 4)' "$(bj_ph 'cd /tmp && ls')"
  fall G17 main durchlaufend 0 AK - voll JSON Bash 'cd in Unterverzeichnis des Arbeitszweig-Klons (Runde 4)' "$(bj_ph 'cd docs && git commit -m x')"
  fall G18 main durchlaufend 0 AK - voll JSON Bash 'git -C auf nicht existierenden Pfad (Runde 4)' "$(bj_ph 'git -C /nicht/vorhanden status')"
  fall G19 main durchlaufend 0 MK - voll JSON Bash 'Lesen auf main' "$(bj_ph 'cat datei.txt')"
  fall G20 main durchlaufend 0 MK - voll JSON Bash 'Lesen auf main' "$(bj_ph 'git log --oneline -3')"
  fall G21 main durchlaufend 0 MK - voll JSON Bash 'Lesen auf main' "$(bj_ph 'git diff')"
  fall G22 main durchlaufend 0 AK - voll JSON Bash 'Falsch-Positiv-Kontrolle vom Arbeitszweig aus' "$(bj_ph 'git worktree add -b claude/neu2 /tmp/wt2 main')"
  fall G23 main durchlaufend 0 AK - voll JSON Bash 'Pfad mit Leerzeichen, kein main-Kontext (Runde 4)' "$(bj_ph 'cd "ein pfad/mit leerzeichen" && git commit -m x')"
  fall G24 main durchlaufend 0 AK - voll JSON Bash 'cd - (Runde 4)' "$(bj_ph 'cd - && git status')"
  fall G25 main durchlaufend 0 AK - voll JSON Bash 'Interpreter mit Inline-Code auf dem Arbeitszweig (Gegenprobe zu A15)' "$(bj_ph 'python3 -c "print(1)"')"
  fall G26 main durchlaufend 0 AK - voll JSON Bash 'sed -i auf dem Arbeitszweig (Gegenprobe zu A23)' "$(bj_ph 'sed -i s/a/b/ datei.txt')"
  fall G27 main durchlaufend 0 MK - voll JSON Bash 'Ausweg von main herunter' "$(bj_ph 'git checkout -b claude/neu')"
  fall G28 main durchlaufend 0 MK - voll JSON Bash 'Lesen von main (fetch)' "$(bj_ph 'git fetch origin main')"
  fall G29 main durchlaufend 0 MK - voll JSON Bash 'Lesen' "$(bj_ph 'git branch --show-current')"
  fall G30 main durchlaufend 0 MK - voll JSON Bash 'Kette auf main starten ist kein Schreiben' "$(bj_ph 'make dod')"
  fall G31 main durchlaufend 0 MK - voll JSON Bash 'Umgebungs-Tempverzeichnis ausgenommen' "$(bj_ph 'echo x > "$TMPDIR/datei.txt"')"
  fall ZF2b main grenze 0 AK - voll JSON Bash 'Zusatzfall 2: untergeordneter Shell-Aufruf -- benannte Grenze (Rumpfkommentar "BEWUSSTE GRENZE"), gemessen 0' "$(bj_ph 'bash -c "cd {ZM} && git commit -m x"')"
  fall ZF2c main grenze 0 AK - voll JSON Bash 'Zusatzfall 2: sh -c, gemessen 0' "$(bj_ph "sh -c 'cd {ZM}; git commit -m x'")"
  fall ZF3i main durchlaufend 0 AK - voll JSON Bash 'Zusatzfall 3 Gegenprobe: Kontextwechsel ohne Schreibwirkung' "$(bj_ph 'git -C ../zweiter-main status')"
  fall ZF4a main grenze 0 KR - voll JSON Bash 'Zusatzfall 4: CLAUDE_PROJECT_DIR ohne .git -- Rueckgabewert 0 als bewusste Grenze (Kopfkommentar "VORAUSSETZUNG git")' "$(bj_ph 'git push origin main')"
  fall ZF4b main grenze 0 KR - voll JSON Write 'Zusatzfall 4 mit Dateiwerkzeug' "$(wj_ph '{KR}/x.ts' 'const a = 1;')"
  fall ZF10a main grenze 0 MK - voll JSON bash 'Klasse grenze nach Spalte Folge seit 2026-10-14 (Posten 1, erste Aenderung am Pruefmittel nach dem Nachtrag vom 2026-09-23): Grenze an der Schnittstelle (Werkzeugname), festgeschrieben in ADR 0002, 6.13 c, Nachtrag vom 2026-09-23, im Kopfkommentar benannt seit Posten 1 (Fallklasse GM-6); vormals Pruefstand: Zusatzfall 10: tool_name "bash" statt "Bash" -- Gleichheitspruefung greift nicht, Dateiwerkzeug-Zweig ohne file_path endet 0; heutiger Stand, kein Befund (ADR 0002, 6.13 d)' "$(bj_ph 'git push origin main' 'bash')"
  fall ZF10b main grenze 0 MK - voll JSON bash 'Klasse grenze nach Spalte Folge seit 2026-10-14 (Posten 1, erste Aenderung am Pruefmittel nach dem Nachtrag vom 2026-09-23): Grenze an der Schnittstelle (Werkzeugname), festgeschrieben in ADR 0002, 6.13 c, Nachtrag vom 2026-09-23, im Kopfkommentar benannt seit Posten 1 (Fallklasse GM-6); vormals Pruefstand: Zusatzfall 10, heutiger Stand 0' "$(bj_ph 'git commit -m x' 'bash')"
  fall G36 main durchlaufend 0 AK - voll JSON Bash 'cd in den Arbeitszweig-Klon selbst' "$(bj_ph 'cd {AK} && git commit -m x')"
  fall G37 main durchlaufend 0 AK - voll JSON Bash 'cd ohne Argument' "$(bj_ph 'cd && git status')"
  fall G38 main durchlaufend 0 AK - voll JSON Bash 'mehrfaches cd' "$(bj_ph 'cd docs && cd .. && git status')"
  fall G39 main durchlaufend 0 MS - voll JSON Bash 'Lesen auf master' "$(bj_ph 'git status')"
  fall G40 main durchlaufend 0 AK - voll JSON Read 'Gegenprobe ST-13 (main-Gate, E4.3): synthetisch (Read steht nicht im Matcher); realistische Gegenproben G01, P04. Kontext AK statt MK vorgemessen (in MK blockiert das Dateiwerkzeug-Geleise unabhaengig vom Werkzeugnamen jeden file_path auf main -- Restbefund, nicht Gegenstand von E4.3)' "$(rj 'x')"
  fall G41 main durchlaufend 0 MK - voll JSON Bash 'fluechtiges Ziel /tmp ohne ".." bleibt frei (DT-E43-6, Regressionsschutz)' "$(bj_ph 'echo x > /tmp/datei.txt')"
  fall G42 main durchlaufend 0 MK - voll JSON Bash 'Suchen mit 2>/dev/null bleibt frei (DT-E43-6, Regressionsschutz)' "$(bj_ph 'grep -r x . 2>/dev/null')"
  fall A43 main grenze 0 AK - voll JSON Bash 'Schreiben per Pfad in einen zweiten main-Auscheckstand ohne Kontextwechsel (2026-08-25, zweite Runde Nr. 1): heute 0 -- das ist die im Kopfkommentar benannte Grenze GM-2 (zweiter Arbeitsbaum ausserhalb der Sitzung); seit 2026-08-25 ist die Klasse ueber die worktree-Sperre abgedeckt, nicht ueber die Pfadpruefung' "$(bj_ph "sed -i 's/a/b/' ../zweiter-main/datei.txt")"
  fall L01 main blockierend 2 AK - voll JSON Bash 'Posten 1 unter R3-Q-010 (ADR 0002, 6.13 c, Nachtrag vom 2026-09-23), geschlossen am 2026-10-14; vormals Pruefstand: beobachtete Luecke DT-E41-04 (Dynamic Software Tester, 2026-09-23), heute 0; kein Befund des Zustandsberichts, nicht Gegenstand von R3-Q-010; Aufnahme nur als Fortschreibung von ADR 0002, 6.13 c' "$(bj_ph 'git push origin ma"in"')"
  fall L02 main blockierend 2 AK - voll JSON Bash 'Posten 1 unter R3-Q-010 (ADR 0002, 6.13 c, Nachtrag vom 2026-09-23), geschlossen am 2026-10-14; vormals Pruefstand: beobachtete Luecke DT-E41-04 (Dynamic Software Tester, 2026-09-23), heute 0; kein Befund des Zustandsberichts, nicht Gegenstand von R3-Q-010; Aufnahme nur als Fortschreibung von ADR 0002, 6.13 c' "$(bj_ph 'git push origin \main')"
  fall L03 main blockierend 2 AK - voll JSON Bash 'Posten 1 unter R3-Q-010 (ADR 0002, 6.13 c, Nachtrag vom 2026-09-23), geschlossen am 2026-10-14; vormals Pruefstand: beobachtete Luecke DT-E41-04 (Dynamic Software Tester, 2026-09-23), heute 0; kein Befund des Zustandsberichts, nicht Gegenstand von R3-Q-010; Aufnahme nur als Fortschreibung von ADR 0002, 6.13 c' "$(bj_ph 'git worktree add /tmp/wt ma"in"')"
  fall L04 main blockierend 2 AK - voll JSON Bash 'Posten 1 unter R3-Q-010 (ADR 0002, 6.13 c, Nachtrag vom 2026-09-23), geschlossen am 2026-10-14; vormals Pruefstand: beobachtete Luecke DT-E41-04 (Dynamic Software Tester, 2026-09-23), heute 0; kein Befund des Zustandsberichts, nicht Gegenstand von R3-Q-010; Aufnahme nur als Fortschreibung von ADR 0002, 6.13 c' "$(bj_ph 'git worktree add -B "main" /tmp/wt')"
  fall G43 main durchlaufend 0 AK - voll JSON Bash 'Posten 1 unter R3-Q-010, Gegenprobe: -b mit Anfuehrungszeichen um den Namen, Ausgangspunkt main bleibt zulaessig (Regressionsschutz, ADR 0002, 6.13 f Punkt 2)' "$(bj_ph 'git worktree add -b "claude/neu" /tmp/wt main')"
  fall G44 main durchlaufend 0 AK - voll JSON Bash 'Posten 1 unter R3-Q-010, Gegenprobe: Zweigname mit main als Teil in Anfuehrungszeichen bleibt frei (Gegenprobe zu L01, G11)' "$(bj_ph 'git push origin "feature/main-seite"')"
  fall G45 main durchlaufend 0 AK - voll JSON Bash 'Posten 1 unter R3-Q-010, Gegenprobe: Push eines Arbeitszweigs in einfachen Anfuehrungszeichen bleibt frei (Gegenprobe zu L01)' "$(bj_ph "git push origin 'claude/x'")"
  fall G46 main durchlaufend 0 AK - voll JSON Bash 'Posten 1 unter R3-Q-010, Gegenprobe: der Name hinter -b beginnt mit main, ist aber nicht main -- die Ausnahme greift weiter (Gegenprobe zu L04, A56)' "$(bj_ph 'git worktree add -b main-fix /tmp/wt main')"
  fall G47 main grenze 0 AK - voll JSON Bash 'Grenze der Auswertung (GM-5, seit Posten 1, 2026-10-14): das Ziel entsteht erst durch die Variable, gemessen 0' "$(bj_ph 'b=main; git push origin $b')"
  fall G48 main grenze 0 AK - voll JSON Bash 'Grenze der Auswertung (GM-5, seit Posten 1, 2026-10-14): das Ziel entsteht erst durch die Befehlssubstitution, gemessen 0' "$(bj_ph 'git push origin $(printf ma)in')"
  fall G49 main grenze 0 AK - voll JSON Bash 'Grenze der Auswertung (GM-5, seit Posten 1, 2026-10-14): worktree, das Ziel entsteht erst durch die Befehlssubstitution, gemessen 0; steht das Wort main im Klartext in der Substitution, blockiert das Zielmuster schon, das ist keine Grenze' "$(bj_ph 'git worktree add /tmp/wt $(printf ma)in')"
  fall G50 main durchlaufend 0 AK - voll JSON Bash 'DT-B2-03, Gegenprobe: der angehaengte Name beginnt mit main, ist aber nicht main (-bmainline), die Ausnahme greift weiter' "$(bj_ph 'git worktree add -bmainline /tmp/wt')"
  fall G51 main durchlaufend 0 AK - voll JSON Bash 'DT-B2-04, Gegenprobe: Zeilenfortsetzung, die nicht main ergibt (mainline)' "$(bj_ph "$(printf 'git push origin ma\\\ninline')")"
  fall G52 main durchlaufend 0 AK - voll JSON Bash 'Posten 1, Gegenprobe mit Rueckstrich (DT-B2-06): Zweigname mit main als Teil, Rueckstrich vor dem Schraegstrich' "$(bj_ph 'git push origin fix\/main-seite')"
  fall G53 main durchlaufend 0 AK - voll JSON Bash 'Posten 1, Gegenprobe mit Rueckstrich (DT-B2-06): Arbeitszweig mit Rueckstrich am Wortanfang' "$(bj_ph 'git push origin \claude/x')"
  fall G54 main durchlaufend 0 AK - voll JSON Bash 'Posten 1, Gegenprobe fuer worktree add (DT-B2-06): Pfad mit main als Teil in Anfuehrungszeichen bleibt frei' "$(bj_ph 'git worktree add /tmp/wt "feature/main-seite"')"
  fall G55 main durchlaufend 0 AK - voll JSON Bash 'DT-B2-01, Gegenprobe: das Wort push in Anfuehrungszeichen ist kein Verb; Verb und Sammel-Push-Optionen liest das Gate am Befehlstext, nicht an cmd_ziel (der erste Bau gab hier 2)' "$(bj_ph 'git log --all --grep "push"')"
  fall G56 main durchlaufend 0 AK - voll JSON Bash 'DT-B2-01, Gegenprobe: git push im Suchtext von git log -S, main als Revision (der erste Bau gab hier 2)' "$(bj_ph 'git log -S "git push" --oneline main')"
  fall G57 main durchlaufend 0 AK - voll JSON Bash 'DT-B2-01, Gegenprobe: push main im Text der Commit-Meldung (der erste Bau gab hier 2)' "$(bj_ph 'git commit -m "push main"')"
  fall G58 main durchlaufend 0 AK - voll JSON Bash 'DT-B2-01, Gegenprobe fuer worktree add: die Wortfolge im Suchtext von git log ist kein Verb (der erste Bau gab hier 2)' "$(bj_ph 'git log --all --grep "worktree add -b main"')"
  fall G59 main grenze 0 AK - voll JSON Bash 'Grenze GM-7 (DT-B2-05 a): -b in Anfuehrungszeichen laesst die Ausnahme greifen, gemessen 0; der Arbeitsbaum entsteht auf main' "$(bj_ph "git worktree add '/tmp/a -b x' main")"
  fall G60 main grenze 0 AK - voll JSON Bash 'Grenze GM-7 (DT-B2-05 b): -b im Kommentar laesst die Ausnahme greifen, gemessen 0; der Arbeitsbaum entsteht auf main' "$(bj_ph 'git worktree add /tmp/wt main # -b x')"
  fall G61 main grenze 0 AK - voll JSON Bash 'Grenze der Auswertung (GM-5, B2-PM-04): eval, das Ziel entsteht erst durch die Variable, gemessen 0' "$(bj_ph 'x=ma; eval "git push origin ${x}in"')"
  fall G62 main grenze 0 AK - voll JSON Bash 'Grenze der Auswertung (GM-5, B2-PM-04): Brace-Expansion, das Ziel entsteht erst durch die Auswertung, gemessen 0' "$(bj_ph 'git push origin {ma,}in')"
  fall G63 main grenze 0 AK - voll JSON Bash 'Grenze der Auswertung (GM-5, B2-PM-04): Wort in Dollar-Anfuehrungszeichen mit Escape-Folge, das Ziel entsteht erst durch die Auswertung, gemessen 0' "$(bj_ph "git push origin \$'\\x6dain'")"
  fall G64 main grenze 0 AK - voll JSON Bash 'Grenze der Auswertung (GM-5, DT-B2-07): -B mit Escape-Folge in Dollar-Anfuehrungszeichen, das Wort main entsteht erst durch die Auswertung, gemessen 0' "$(bj_ph "git worktree add -B \$'\\x6dain' /tmp/wt")"
  fall G65 main durchlaufend 0 AK - voll JSON Bash 'DT-B2-07, Gegenprobe: -B mit Dollar-Anfuehrungszeichen um einen anderen Namen, die Ausnahme greift weiter' "$(bj_ph "git worktree add -B \$'feature' /tmp/wt")"
  fall G66 main durchlaufend 0 AK - voll JSON Bash 'DT-B2-03, Gegenprobe: angehaengter Name fmain, nicht main (git legt den Zweig fmain an)' "$(bj_ph 'git worktree add -Bfmain /tmp/wt')"
  fall G67 main durchlaufend 0 AK - voll JSON Bash 'DT-B2-03, Gegenprobe: -fB mit anderem Namen, kein main im Befehl' "$(bj_ph 'git worktree add -fB feature /tmp/wt')"
  fall G68 main grenze 0 AK - voll JSON Bash 'Grenze der Auswertung (GM-5, DT-B2-07): oktale Escape-Folge in Dollar-Anfuehrungszeichen, das Wort main entsteht erst durch die Auswertung, gemessen 0' "$(bj_ph "git push origin \$'\\155ain'")"
  fall G69 main grenze 0 AK - voll JSON Bash 'DT-B2-08: Sammel-Push-Option in Anfuehrungszeichen (Grenze GM-8); heute 0, die Shell entfernt die Anfuehrungszeichen und git pusht alle Zweige' "$(bj_ph 'git push origin "--all"')"
  fall G70 main grenze 0 AK - voll JSON Bash 'DT-B2-08: Verb in Anfuehrungszeichen (Grenze GM-8); heute 0; vor Posten 1 0, erste Fassung 2, seit DT-B2-01 wieder 0' "$(bj_ph 'git pu"sh" origin main')"
  fall G71 main grenze 0 AK - voll JSON Bash 'Grenze der Auswertung (GM-5, B2-PM-15): $"..." uebersetzt die Shell ueber einen Meldungskatalog; ein Katalog kann zweig zu main uebersetzen, der Befehlstext traegt das Wort main nicht, gemessen 0' "$(bj_ph 'git push origin $"zweig"')"
  fall L17 main blockierend 2 AK - voll JSON Bash 'Posten 4 a unter R3-Q-010 (DT-B2-05 c), geschlossen am 2026-10-21; Mutation MM17; vormals belegte Luecke: Posten 4 unter R3-Q-010 (DT-B2-05 c), terminiert mit der naechsten Aenderung am main-Gate; heute 0: ein -b/-B in einem anderen worktree-add-Befehl derselben Eingabe hebt die Sperre fuer alle auf, der zweite Arbeitsbaum entsteht auf main' "$(bj_ph 'git worktree add -b x /tmp/w1 main; git worktree add /tmp/w2 main')"
  fall L18 main blockierend 2 AK - voll JSON Bash 'Posten 1 unter R3-Q-010, DT-B2-07 (Einordnung des Software Architects vom 2026-10-14: belegte Luecke, jetzt schliessen; vormals Soll 0 und Klasse belegte-luecke): -B mit dem Wort main in Dollar-Anfuehrungszeichen, das Dollarzeichen vor dem Anfuehrungszeichen entfaellt in cmd_ziel; Mutation MM15; geschlossen am 2026-10-14' "$(bj_ph "git worktree add -B \$'main' /tmp/wt")"
  fall L19 main blockierend 2 AK - voll JSON Bash 'Posten 4 b unter R3-Q-010 (DT-B2-09), geschlossen am 2026-10-21; Mutation MM18; vormals belegte Luecke: Posten 4 unter R3-Q-010, Buchstabe b (DT-B2-09), terminiert mit der naechsten Aenderung am main-Gate; heute 0: die Zeilenfortsetzung trennt das Verb, die Verb-Erkennung liest den Befehlstext zeilenweise' "$(bj_ph "$(printf 'git \\\npush origin main')")"
  # L20: die JSON-Eingabe entsteht ueber die Standardeingabe von jq, weil ein
  # Argument ab 128 KiB beim exec scheitert (E2BIG) und bj_ph deshalb ausfaellt.
  fall L20 main blockierend 2 AK - voll JSON Bash 'geschlossen am 2026-10-21, Posten 5, SR-001 (B2-GATE-D05); Mutation MM16; vormals belegte Luecke: Posten 5 unter R3-Q-010 (B2-GATE-D05, vorbestehend, beide Gates): grosse Eingabe -- unter set -o pipefail liefert printf | grep -Eq den Wert 141, wenn grep nach einem fruehen Treffer endet, die Bedingung gilt als nicht erfuellt und der Push nach main laeuft durch; heute 0' "$(bj_gross 'git push origin main')"
  fall L21 main blockierend 2 AK - voll JSON Bash 'Posten 4 c unter R3-Q-010 (Basename-Form), geschlossen am 2026-10-21; Mutation MM19; vormals belegte Luecke: Posten 4 unter R3-Q-010, Buchstabe c (Basename-Form, echtes git 2.43.0): worktree add <pfad>/main ohne commit-ish checkt den bestehenden Zweig main im neuen Arbeitsbaum aus; terminiert mit der naechsten Aenderung am main-Gate; heute 0' "$(bj_ph 'git worktree add ../main')"
  fall G72 main durchlaufend 0 AK - voll JSON Bash 'Posten 5 unter R3-Q-010, Gegenprobe zu A81 und A82: ein Arbeitsbaum mit neuem Zweig ab main (Ausnahme -b) und eine Kommentarzeile aus 200000 Zeichen bleibt zulaessig; Pruefstelle Ausnahme (negiert) ohne Abbruch des Schreibers' "$(bj_gross 'git worktree add -b x /tmp/wt main')"
  fall G73 main durchlaufend 0 AK - voll JSON Bash 'Posten 5 unter R3-Q-010, Gegenprobe zu L20 und A80: ein Push auf den Arbeitszweig mit einer Kommentarzeile aus 200000 Zeichen bleibt zulaessig' "$(bj_gross 'git push -u origin claude/pruefzweig')"
  fall G74 main durchlaufend 0 AK - voll JSON Bash 'Posten 4 a unter R3-Q-010, Gegenprobe zu L17: hinter dem Ausnahme-Abschnitt steht ein Befehl, der kein worktree add ist' "$(bj_ph 'git worktree add -b x /tmp/w1 main; git status')"
  fall G75 main durchlaufend 0 AK - voll JSON Bash 'Posten 4 a unter R3-Q-010, Gegenprobe zu A85: zwei Abschnitte, beide mit gueltiger Ausnahme' "$(bj_ph 'git worktree add -b x /tmp/w1 main && git worktree add -b y /tmp/w2 main')"
  fall G76 main durchlaufend 0 AK - voll JSON Bash 'Posten 4 a unter R3-Q-010, Gegenprobe zu A90: nach dem Abschneiden des Ausnahme-Abschnitts bleibt kein worktree add, main in einem anderen Befehl sperrt nicht' "$(bj_ph 'git worktree add -b x /tmp/w1 main; git log main')"
  fall G77 main durchlaufend 0 AK - voll JSON Bash 'Posten 4 b unter R3-Q-010, Gegenprobe zu A91: Verb durch Zeilenfortsetzung getrennt, die Ausnahme steht auf demselben Text (zulaessig)' "$(bj_ph $'git worktree \\\nadd -b x /tmp/wt main')"
  fall G78 main durchlaufend 0 AK - voll JSON Bash 'Posten 4 b unter R3-Q-010, heutiger Fehlalarm in sicherer Richtung (gemessen vorher 2): die Ausnahme steht hinter der Zeilenfortsetzung, die Shell liest ein zulaessiges worktree add mit -b' "$(bj_ph $'git worktree add \\\n  -b x /tmp/wt main')"
  fall G79 main durchlaufend 0 AK - voll JSON Bash 'Posten 4 b unter R3-Q-010, heutiger Fehlalarm in sicherer Richtung (gemessen vorher 2): die Shell liest x--all als ein Wort, das ist kein Sammel-Push' "$(bj_ph $'git push origin feature -o x\\\n--all')"
  fall G80 main grenze 0 AK - voll JSON Bash 'Posten 4 b unter R3-Q-010, Preis in der Grenze GM-7 (gemessen vorher 2): in einfachen Anfuehrungszeichen setzt der Rueckstrich vor dem Zeilenumbruch die Zeile nicht fort, das Gate entfernt das Paar trotzdem (lexikalischer Schritt) und liest -b als Ausnahme; die Shell legt den Arbeitsbaum auf main an' "$(bj_ph $'git worktree add \'/tmp/a \\\n-b x\' main')"
  fall G81 main durchlaufend 0 AK - voll JSON Bash 'Posten 4 c unter R3-Q-010, Gegenprobe zu L21: origin/main als zweites Wort ist das commit-ish und legt einen losgeloesten Arbeitsbaum an' "$(bj_ph 'git worktree add /tmp/wt origin/main')"
  fall G82 main durchlaufend 0 AK - voll JSON Bash 'Posten 4 c unter R3-Q-010, Gegenprobe zu L21: --detach' "$(bj_ph 'git worktree add --detach ../main')"
  fall G83 main durchlaufend 0 AK - voll JSON Bash 'Posten 4 c unter R3-Q-010, Gegenprobe zu L21: -d (echtes git 2.43.0: losgeloester Arbeitsbaum)' "$(bj_ph 'git worktree add -d ../main')"
  fall G84 main durchlaufend 0 AK - voll JSON Bash 'Posten 4 c unter R3-Q-010, Gegenprobe zu L21: ein zweites Wort ist das commit-ish' "$(bj_ph 'git worktree add ../main feature')"
  fall G85 main durchlaufend 0 AK - voll JSON Bash 'Posten 4 c unter R3-Q-010, Gegenprobe zu L21: neuer Zweig x in einem Pfad namens main (Ausnahme -b)' "$(bj_ph 'git worktree add -b x ../main')"
  fall G86 main durchlaufend 0 AK - voll JSON Bash 'Posten 4 c unter R3-Q-010, Gegenprobe zu L21: der Pfad endet auf main-fix, nicht auf main' "$(bj_ph 'git worktree add ../main-fix')"
  fall G87 main durchlaufend 0 AK - voll JSON Bash 'Posten 4 c unter R3-Q-010, Gegenprobe zu A98: ein zweites Wort ist das commit-ish, auch mit Umleitung' "$(bj_ph 'git worktree add ../main feature 2>&1')"
  fall G88 main grenze 0 AK - voll JSON Bash 'Posten 4 a unter R3-Q-010, Grenze GM-5 (Befehlssubstitution): ein worktree add in einer Befehlssubstitution innerhalb eines Ausnahme-Abschnitts bleibt unerkannt, gemessen 0 vor und nach Posten 4; die Shell fuehrt es aus und legt einen Arbeitsbaum auf main an' "$(bj_ph 'git worktree add -b x /tmp/w1 $(git worktree add /tmp/w2 main)')"
  fall G89 main grenze 0 AK - voll JSON Bash 'Posten 4 a unter R3-Q-010, Grenze GM-5 (Rueckwaertsakzente): wie G88, das worktree add steht in Rueckwaertsakzenten innerhalb eines Ausnahme-Abschnitts; gemessen 0 vor und nach Posten 4' "$(bj_ph 'git worktree add -b x /tmp/w1 `git worktree add /tmp/w2 main`')"
  fall G90 main grenze 0 AK - voll JSON Bash 'Posten 4 c unter R3-Q-010, Grenze der Basename-Form (GM-9): eine Option mit getrenntem Wert (--reason) zaehlt als zweites Wort, die Shell legt den Arbeitsbaum auf main an; gemessen 0 vor und nach Posten 4' "$(bj_ph 'git worktree add --lock --reason x ../main')"
  fall G91 main grenze 0 AK - voll JSON Bash 'Posten 4 c unter R3-Q-010, Grenze der Basename-Form (GM-9): ein Pfad mit Leerzeichen in Anfuehrungszeichen zerfaellt in zwei Woerter, die Shell legt den Arbeitsbaum auf main an; das Gate zerlegt nur an Leerraum und nachbildet die Token-Erkennung der Shell nicht; gemessen 0 vor und nach Posten 4' "$(bj_ph 'git worktree add "/tmp/my wt/main"')"
  fall G92 main grenze 0 AK - voll JSON Bash 'DT-C2-02 U-1 (Delta 2026-10-21, Entscheid des Software Architects Option a), Preis in der Grenze GM-7: in doppelten Anfuehrungszeichen entfernt die Shell den Rueckstrich vor dem Zeilenumbruch tatsaechlich, das Gate liest -b auf dem zusammengesetzten Text als Ausnahme; die Shell legt den Arbeitsbaum auf main an; vor Posten 4 gab das Gate hier 2' "$(bj_ph $'git worktree add "/tmp/a \\\n-b x" main')"
  fall G93 main grenze 0 AK - voll JSON Bash 'DT-C2-02 U-2 (Delta 2026-10-21, Entscheid des Software Architects Option a), Preis in der Grenze GM-7: ein Kommentar setzt in der Shell keine Zeile fort, das Gate entfernt das Paar trotzdem und liest -b im Kommentar als Ausnahme; die Shell legt den Arbeitsbaum auf main an; vor Posten 4 gab das Gate hier 2' "$(bj_ph $'git worktree add /tmp/wt main # \\\n -b x')"
  fall G94 main durchlaufend 0 AK - voll JSON Bash 'DT-C2-01, Gegenprobe zu A105: dieselben 50000 Zeilenfortsetzungen hinter einem zulaessigen Befehl' "$(bj_fort 'git status')"
  fall G95 main durchlaufend 0 AK - voll JSON Bash 'ST-C2-02 (Delta 2026-10-21), neue Fehlalarmklasse geschlossen: ein main hinter einem Trenner im Muster eines grep ist kein Ziel; mit tr statt erhaltenem Trenner gab das Gate hier 2, vor Posten 4 gab es 0; Mutation MM23' "$(bj_ph 'git worktree add /tmp/w feature && git branch | grep -E "dev|main"')"
  fall G96 main durchlaufend 0 AK - voll JSON Bash 'DT-C2-03, Gegenprobe zu A110: /mainx endet nicht auf /main' "$(bj_ph 'git worktree add /mainx')"
  fall G97 main grenze 0 AK - voll JSON Bash 'ST-C2-04 (Delta 2026-10-21), Grenze GM-9: ein Pfad in Anfuehrungszeichen zerfaellt an einem Semikolon in zwei Abschnitte, die Shell legt den Arbeitsbaum auf main an; gemessen 0' "$(bj_ph 'git worktree add "/tmp/a;b/main"')"
  fall G98 main grenze 0 AK - voll JSON Bash 'ST-C2-04 (Delta 2026-10-21), Grenze GM-9: ein Pfad in Anfuehrungszeichen mit Leerzeichen und Raute wird als Kommentar gelesen; gemessen 0' "$(bj_ph 'git worktree add "/tmp/a #b/main"')"
  fall G99 main grenze 0 AK - voll JSON Bash 'ST-C2-04 (Delta 2026-10-21), Grenze GM-9: ein Pfad in Anfuehrungszeichen mit < wird als Umleitung gelesen; gemessen 0' "$(bj_ph 'git worktree add "/tmp/a<b/main"')"
  fall G100 main grenze 0 AK - voll JSON Bash 'ST-C2-04 (Delta 2026-10-21), Grenze GM-9: ein Zeilenumbruch in Anfuehrungszeichen trennt den Pfad in zwei Abschnitte; gemessen 0' "$(bj_ph $'git worktree add "/tmp/a\nb/main"')"
  fall G101 main durchlaufend 0 AK - voll JSON Bash 'ST-C2-03 iii (Delta 2026-10-21), vormals Fehlalarm (Zielpruefung am Rohtext): die Shell liest foomain als ein Wort; vor Posten 4 gab das Gate hier 2; gewollt' "$(bj_ph $'git worktree add /tmp/wt foo\\\nmain')"
  fall G102 main durchlaufend 0 AK - voll JSON Bash 'ST-C2-D-07 (Delta 2 2026-10-21), neue Fehlalarmklasse geschlossen: die 1 vor dem > gehoert zum Wort ../main1 (kein Leerraum davor, also kein Dateideskriptor); der Umleitungsschritt frass das Wortende und das Gate gab 2 (Ende C2 und erstes Delta), HEAD vor Posten 4 gab 0; Mutation MM28' "$(bj_ph 'git worktree add ../main1>x')"
  fall G103 main durchlaufend 0 AK - voll JSON Bash 'ST-C2-D-07 (Delta 2 2026-10-21): wie G102 mit /dev/null und einem Pfad unter einem Verzeichnis; Mutation MM28' "$(bj_ph 'git worktree add ../x/main2>/dev/null')"
  fall G104 main durchlaufend 0 AK - voll JSON Bash 'DT-C2-D-01 (Delta 2 2026-10-21), Gegenprobe zu A120: das zweite Wort (feature) ist das commit-ish, die Umleitung ist kein Wort; der Arbeitsbaum entsteht auf feature' "$(bj_ph 'git worktree add ../main feature <<< "a b"')"
  fall G105 main grenze 0 AK - voll JSON Bash 'DT-C2-E-02 (Delta 3 2026-10-21), Grenze GM-5 (Auswertung der Shell): eine Befehlssubstitution als Operand zerfaellt an Leerraum, die zweite Haelfte bleibt als zweites Wort stehen; gemessen 0' "$(bj_ph 'git worktree add ../main <<< $(echo a b)')"
  fall G106 main grenze 0 AK - voll JSON Bash 'DT-C2-E-02 (Delta 3 2026-10-21), Grenze GM-9: eine Option mit getrenntem Wert, hier in Anfuehrungszeichen (--reason="a b"), zaehlt als zwei Woerter; gemessen 0 (vorbestehend)' "$(bj_ph 'git worktree add --lock --reason="a b" ../main')"
  fall G107 main durchlaufend 0 AK - voll JSON Bash 'DT-C2-E-01 (Delta 3 2026-10-21), Gegenprobe zu A131: das zweite Wort (feature) ist das commit-ish' "$(bj_ph 'git worktree add --lock --reason="a>b" ../main feature')"
  fall G108 main durchlaufend 0 AK - voll JSON Bash 'DT-C2-E-01 (Delta 3 2026-10-21), Gegenprobe zu A131: mit -b ist der Abschnitt eine Ausnahme (neuer Zweig, main nur Ausgangspunkt)' "$(bj_ph 'git worktree add --reason="a>b" -b x ../w main')"
  fall G109 main durchlaufend 0 AK - voll JSON Bash 'ST-C2-F-01 (Delta 4 2026-10-21), R2, Gegenprobe zu A143: der Operand "a\"b"c\" ist laut Shell ein Wort (a"bc"), dahinter steht das commit-ish feature; die Mischlesung verschluckte feature und das Gate sperrte (neue Fehlalarmform von Delta 3); Mutation MM34' "$(bj_ph 'git worktree add ../main > "a\"b"c\" feature')"
  fall G110 main grenze 0 AK - voll JSON Bash 'ST-C2-F-02 (Delta 4 2026-10-21), Grenze GM-9: die Verbindung beider Fehlformen aus Delta 3 (ein Wort in Anfuehrungszeichen mit > vor dem Pfad UND ein Operand in Anfuehrungszeichen mit Leerraum dahinter); gemessen 0' "$(bj_ph 'git worktree add --reason="a>b" ../main > "x y"')"
  fall G111 main grenze 0 AK - voll JSON Bash 'DT-C2-F-01 (Delta 4 2026-10-21), Grenze (benannt unter GM-9): < oder > als letztes Zeichen eines Worts in Anfuehrungszeichen vor dem Pfad; die Anfuehrung wird als offen gelesen und der Pfad verschluckt; gemessen 0 (vorbestehend, vor Delta 2: 0)' "$(bj_ph 'git worktree add --lock --reason="a>" ../main')"
  fall G112 main grenze 0 AK - voll JSON Bash 'DT-C2-F-02 (Delta 4 2026-10-21), Grenze GM-9: ein Semikolon in einem Wort in Anfuehrungszeichen vor dem Pfad trennt den Pfad vom Abschnitt; gemessen 0 (vorbestehend)' "$(bj_ph 'git worktree add --lock --reason="a;b" ../main')"
  fall G113 main durchlaufend 0 AK - voll JSON Bash 'DT-C2-F-03 (Delta 4 2026-10-21): -d (losgeloester Arbeitsbaum) mit einer Umleitung; ohne den Abzug von --detach und -d in der zweiten Fassung wuerde sie sperren (Mutation X3 des DST)' "$(bj_ph 'git worktree add -d ../main > /tmp/log')"
}

# -----------------------------------------------------------------------------
# 14. Fallliste -- Teil 4.3 der Fallliste: main-Gate, unlesbare Eingabe (ROH, ST-13)
# -----------------------------------------------------------------------------
faelle_4_3_main_roh() {
  fall S01 main blockierend 2 MK - voll ROH - 'geschlossen mit E4.3 (vormals ST-13)' ""
  fall S02 main blockierend 2 MK - voll ROH - 'geschlossen mit E4.3 (vormals ST-13)' 'kein json'
  fall ZF8a main blockierend 2 MK - voll ROH - 'geschlossen mit E4.3 (vormals ST-13): tool_input als Zeichenkette blockiert jetzt statt still durchzulaufen' '{"tool_name":"Bash","tool_input":"git push origin main"}'
  fall ZF8b main blockierend 2 MK - voll ROH - 'geschlossen mit E4.3 (vormals ST-13), Dateiwerkzeug' '{"tool_name":"Write","tool_input":"frontend/x.ts"}'
  fall S08 main blockierend 2 MK - voll ROH - 'JSON-Strom mit zwei Objekten, B-4' '{"tool_name":"Bash","tool_input":{"command":"git status"}}{"tool_name":"Bash","tool_input":{"command":"git push origin main"}}'
}

# -----------------------------------------------------------------------------
# 15. Fallliste -- Teil 4.4 der Fallliste: Prototyp-Gate, Soll 2 (Kontext AB)
# -----------------------------------------------------------------------------
faelle_4_4_proto_soll2() {
  fall B01 prototyp blockierend 2 AB - voll JSON Write 'Richtung 1 (Kopfkommentar)' "$(wj_ph 'frontend/src/a.ts' 'import h from "../prototype/helper";')"
  fall B04 prototyp blockierend 2 AB - voll JSON Write 'Richtung 1, Python-Form' "$(wj_ph 'backend/src/a.py' 'from prototype import demo')"
  fall B05 prototyp blockierend 2 AB - voll JSON Write 'Richtung 2 (Kopfkommentar)' "$(wj_ph 'prototype/x.js' 'import a from "../backend/api";')"
  fall B10 prototyp blockierend 2 AB - voll JSON Bash 'Heredoc mit Prototyp-Import (2026-08-25)' "$(bj_ph "$(printf 'cat > frontend/src/a.ts <<EOT\nimport h from "../prototype/helper";\nEOT')")"
  fall P02 prototyp blockierend 2 AB - voll JSON Write 'Richtung 1 mit src= (Gegenprobe zu P-01; Kennung P02 bleibt zur Rueckverfolgung)' "$(wj_ph 'frontend/src/demo.html' '<script src="../prototype/demo.js"></script>')"
  fall B11 prototyp blockierend 2 AB - voll JSON Bash 'Umleitung + Importmuster' "$(bj_ph 'echo "import h from \"../prototype/helper\";" > frontend/src/a.ts')"
  fall B12 prototyp blockierend 2 AB - voll JSON Bash 'sed -i + Importmuster' "$(bj_ph 'sed -i "1i import h from \"../prototype/helper\";" frontend/src/a.ts')"
  fall B13 prototyp blockierend 2 AB - voll JSON Bash 'tee + Importmuster' "$(bj_ph 'echo "import h from \"../prototype/helper\";" | tee frontend/src/a.ts')"
  fall B14 prototyp blockierend 2 AB - voll JSON MultiEdit 'edits[].new_string wird gelesen (2026-08-25)' "$(mej 'frontend/src/a.ts' 'x' 'import h from "../prototype/helper";')"
  fall B15 prototyp blockierend 2 AB - voll JSON Write 'Blockkommentar im Import (2026-08-25, Runde 2 Nr. 5)' "$(wj_ph 'frontend/src/a.ts' 'import h from /* c */ "../prototype/helper";')"
  fall B16 prototyp blockierend 2 AB - voll JSON Write 'mehrzeiliger Import, Prettier-Umbruch (Runde 2 Nr. 4)' "$(wj_ph 'frontend/src/a.ts' "$(printf 'import {\n  h\n} from\n  "../prototype/helper";')")"
  fall B17 prototyp blockierend 2 AB - voll JSON Write 'doppelter Schraegstrich (Rumpfkommentar "BEWUSSTER PREIS")' "$(wj_ph 'frontend/src/a.ts' 'import x from "prototype//y";')"
  fall B18 prototyp blockierend 2 AB - voll JSON Write 'Funktionsform (2026-08-25)' "$(wj_ph 'backend/src/a.py' 'm = importlib.import_module("prototype.demo")')"
  fall B19 prototyp blockierend 2 AB - voll JSON Write 'Funktionsform' "$(wj_ph 'backend/src/a.py' 'm = __import__("prototype.demo")')"
  fall B20 prototyp blockierend 2 AB - voll JSON Write 'Richtung 2, generisches src/' "$(wj_ph 'prototype/x.js' 'import a from "../src/api";')"
  fall B21 prototyp blockierend 2 AB - voll JSON Write 'Richtung 2, deploy/' "$(wj_ph 'prototype/x.js' 'import a from "../deploy/x";')"
  fall B22 prototyp blockierend 2 AB - voll JSON Write 'Richtung 2, Bauwurzel frontend/ (2026-08-25, Runde 1)' "$(wj_ph 'prototype/x.js' 'import a from "../frontend/x";')"
  fall B23 prototyp blockierend 2 AB - voll JSON NotebookEdit 'notebook_path/new_source' "$(nej 'backend/a.ipynb' 'from prototype import demo')"
  fall B24 prototyp blockierend 2 AB - voll JSON Edit 'Edit fuegt Import ein' "$(ej 'frontend/src/a.ts' 'x' 'import h from "../prototype/helper";')"
  fall B25 prototyp blockierend 2 AB - voll JSON Write 'Zeilenkommentar im Import (Befund N2, 2026-08-25)' "$(wj_ph 'frontend/src/a.ts' "$(printf 'import h from // Kommentar\n  "../prototype/helper";')")"
  fall B26 prototyp blockierend 2 AB - voll JSON Write 'verschachtelte Blockkommentare (Befund N3)' "$(wj_ph 'frontend/src/a.ts' 'import h from /* a /* b */ c */ "../prototype/helper";')"
  fall B27 prototyp blockierend 2 AB - voll JSON Write 'Punktform (2026-08-25 als "widerlegt" gefuehrt: wird erkannt)' "$(wj_ph 'backend/src/a.py' 'import prototype.daten')"
  fall B28 prototyp blockierend 2 AB - voll JSON Write 'bewusster Fehlalarm laut Rumpfkommentar "BEWUSSTER PREIS" -- gewollt' "$(wj_ph 'frontend/src/a.ts' '// Verboten: import { h } from "../prototype/helper";')"
  fall B29 prototyp blockierend 2 AB - voll JSON Write 'einfache Anfuehrungszeichen' "$(wj_ph 'frontend/src/a.ts' "import h from '../prototype/helper';")"
  fall B30 prototyp blockierend 2 AB - voll JSON Write 'Template-Literal' "$(wj_ph 'frontend/src/a.ts' 'import h from `../prototype/helper`;')"
  fall B31 prototyp blockierend 2 AB - voll JSON Write 'require( mit Schraegstrich' "$(wj_ph 'frontend/src/a.ts' 'const h = require("../prototype/helper");')"
  fall B32 prototyp blockierend 2 AB - voll JSON Write 'dynamisches import( mit Schraegstrich' "$(wj_ph 'frontend/src/a.ts' 'const h = await import("../prototype/helper");')"
  fall B33 prototyp blockierend 2 AB - voll JSON Write '@import mit Schraegstrich' "$(wj_ph 'frontend/src/a.css' '@import "../prototype/style.css";')"
  fall B34 prototyp blockierend 2 AB - voll JSON Write 'Richtung 1 mit href=' "$(wj_ph 'frontend/src/demo.html' '<link href="../prototype/style.css">')"
  fall B36 prototyp blockierend 2 AB - voll JSON Write 'Alias ~/' "$(wj_ph 'prototype/x.js' 'import a from "~/frontend/x";')"
  fall B37 prototyp blockierend 2 AB - voll JSON Write 'Richtung 2, require( mit ../../' "$(wj_ph 'prototype/x.js' 'const a = require("../../backend/api");')"
  fall B38 prototyp blockierend 2 AB - voll JSON Write 'absoluter Pfad innerhalb des Projektbaums' "$(wj_ph '{AB}/frontend/src/a.ts' 'import h from "../prototype/helper";')"
  fall B39 prototyp blockierend 2 AB - voll JSON Bash 'anfuegendes Heredoc' "$(bj_ph "$(printf 'cat >> frontend/src/a.ts <<'"'"'EOT'"'"'\nimport h from "../prototype/helper";\nEOT')")"
  fall B40 prototyp blockierend 2 AB - voll JSON Bash 'Umleitung mit Python-Form' "$(bj_ph 'printf "%s\n" "from prototype import demo" > backend/src/a.py')"
  fall ZF5d prototyp blockierend 2 AB - voll JSON Write 'Zusatzfall 5: Punktform mit Untermodul wird erkannt -- kein Befund' "$(wj_ph 'backend/src/a.py' 'from prototype.helper import x')"
  fall ZF6e prototyp blockierend 2 AB - voll JSON Write 'Zusatzfall 6: absoluter Alias @/ wird erkannt (Gegenprobe zur Alias-Zeile)' "$(wj_ph 'prototype/x.js' 'import a from "@/backend/api";')"
  fall B43 prototyp blockierend 2 AB - voll JSON Write 'Praefix ./ mit dynamischem import( in Richtung 2 (E4.2, Klasse ST-05)' "$(wj_ph 'prototype/x.js' 'const a = await import("./../backend/api");')"
  fall B44 prototyp blockierend 2 AB - voll JSON Write 'N-5: HTML src= mit ./../ in Richtung 2 (E4.2)' "$(wj_ph 'prototype/demo.html' '<script src="./../backend/app.js"></script>')"
  fall B45 prototyp blockierend 2 AB - voll JSON Write 'B-1 statisch: bare import ohne "from", Richtung 1 (E4.2)' "$(wj_ph 'frontend/src/a.ts' 'import "../prototype";')"
  fall B46 prototyp blockierend 2 AB - voll JSON Write 'B-1 statisch: bare import ohne "from", Richtung 2 (E4.2)' "$(wj_ph 'prototype/x.js' 'import "./../backend/api";')"
  fall B47 prototyp blockierend 2 AB - voll JSON Write 'N-5: a href= ohne Schraegstrich vor "prototype", Richtung 1 (E4.2)' "$(wj_ph 'frontend/src/demo.html' '<a href="../prototype">x</a>')"
  fall B48 prototyp blockierend 2 AB - voll JSON Write 'N-5: img src= mit Rueckstrich-Pfad, Richtung 1 (E4.2)' "$(wj_ph 'frontend/src/demo.html' '<img src="..\prototype\x.png">')"
  fall B49 prototyp blockierend 2 AB - voll JSON Write 'N-5: __import__ mit Punktform, Richtung 2 (E4.2, heute schon 2)' "$(wj_ph 'prototype/x.py' 'm = __import__("frontend.x")')"
  fall B50 prototyp blockierend 2 AB - voll JSON Write 'A2: Verzeichnisimport ohne Schraegstrich, Richtung 2, Bauwurzel backend (E4.2)' "$(wj_ph 'prototype/x.js' 'import x from "../backend";')"
  fall B51 prototyp blockierend 2 AB - voll JSON Write 'A2: Verzeichnisimport ohne Schraegstrich mit ./../../, Richtung 2, Bauwurzel frontend (E4.2)' "$(wj_ph 'prototype/x.ts' "import x from './../../frontend'")"
  fall ZF6f prototyp blockierend 2 AB - voll JSON Write 'Rueckstrich-Pfad in Richtung 2 (E4.2, Zusatz nach DST-E42-01 b)' "$(wj_ph 'prototype/x.js' 'import a from "..\backend\api";')"
  fall ZF7b prototyp blockierend 2 AB - voll JSON Bash 'Interpreterklasse seit E4.3 erkannt, vorher nur wegen des Zeichens >' "$(bj_ph "$(printf 'perl -e '"'"'open(F,">frontend/src/a.ts"); print F "import h from \\"../prototype/helper\\";"'"'"'')")"
  fall ZF10c prototyp blockierend 2 AB - voll JSON write 'Klasse blockierend nach Spalte Folge seit 2026-10-14 (Posten 1, erste Aenderung am Pruefmittel nach dem Nachtrag vom 2026-09-23); vormals Pruefstand: Zusatzfall 10: der Dateiwerkzeug-Pfad prueft den Werkzeugnamen nicht -- blockiert (2); heutiger Stand' "$(wj_ph 'frontend/src/a.ts' 'import h from "../prototype/helper";' 'write')"
  fall S07 prototyp blockierend 2 AB - ohne-jq JSON Write 'jq-Wache des Prototyp-Gates' "$(wj_ph 'frontend/src/a.ts' 'const a = 1;')"
  fall S11 prototyp blockierend 2 AB - ohne-grep JSON Bash 'Posten 5 unter R3-Q-010 (SR-001): fehlt grep im Suchpfad, kann das Gate nicht pruefen und blockiert mit Meldung auf stderr (vorher Durchlass, gemessen 0); Zweig Pruefung nicht moeglich der Hilfsfunktion trifft; Mutation MP13' "$(bj_ph 'ls prototype/')"
  fall S14 prototyp blockierend 2 AB - grep-attrappe JSON Bash 'DT-C2-05 (Delta 2026-10-21): grep endet mit 1, ohne zu lesen (Attrappe); der Schreiber bricht ab (141), kein Treffer ist dann nicht glaubwuerdig und das Gate blockiert; Mutation MP14' "$(bj_gross 'ls prototype/')"
  fall S18 prototyp blockierend 2 AB - posix JSON Write 'ST-C2-D-01 (Delta 2 2026-10-21): wie B25 mit "& mehr" im Zeilenkommentar; unter POSIXLY_CORRECT=1 entfernt GNU sed einen Zeilenkommentar nur bis zum ersten n (B25 ohne & verhaelt sich genauso): der Rest des Kommentars steht zwischen from und dem Pfad, der Import ist kein Import mehr und laeuft durch (rc 0); nicht das & ist die Ursache (ST-C2-E-04); das Gate entfernt die Variable zu Beginn; Mutation MP15' "$(wj_ph 'frontend/src/a.ts' "$(printf 'import h from // Kommentar & mehr\n  "../prototype/helper";')")"
  fall S19 prototyp blockierend 2 AB - posix JSON Bash 'ST-C2-E-04 (Delta 3 2026-10-21): Bash-Weg zu S18: ein Heredoc mit B25-Form und "& mehr" im Zeilenkommentar; unter POSIXLY_CORRECT=1 bleibt vom Kommentar der Rest nach dem ersten n stehen, das & trennt Import und Pfad im groben Netz fuer Bash (rc 0); das Gate entfernt die Variable zu Beginn; Mutation MP15' "$(bj_ph $'cat > frontend/src/a.ts <<\'EOF\'\nimport h from // Kommentar & mehr\n  "../prototype/helper";\nEOF')"
  fall B53 prototyp blockierend 2 AB - voll JSON Bash 'tee ohne Pipe, dieselbe Klasse wie das main-Gate (B-1)' "$(bj_ph "tee frontend/src/a.ts < <(printf '%s\n' 'import h from \"../prototype/helper\";')")"
  fall B54 prototyp blockierend 2 AB - voll JSON Bash 'Dateiwerkzeug mv mit Import im Kommentar (B-2)' "$(bj_ph 'mv /tmp/helper.ts frontend/src/a.ts # import h from "../prototype/helper"')"
  fall B55 prototyp blockierend 2 AB - voll JSON Bash 'ed/ex-Glied mit Import im Kommentar (B-2)' "$(bj_ph "ex -c 'wq' frontend/src/a.ts # import h from \"../prototype/helper\"")"
  fall B56 prototyp blockierend 2 AB - voll JSON Bash 'Dateiwerkzeug dd mit Import im Kommentar (B-2, vorgemessen)' "$(bj_ph 'dd if=/tmp/x of=frontend/src/a.ts # import h from "../prototype/helper"')"
  fall B57 prototyp blockierend 2 AB - voll JSON Bash 'tee ohne Pipe hinter sudo (DT-E43-1)' "$(bj_ph "echo \"import x from '../prototype/a'\" | sudo tee frontend/a.js")"
  fall B58 prototyp blockierend 2 AB - voll JSON Bash 'tee hinter |& (DT-E43-1)' "$(bj_ph "printf '%s' 'import x from \"../prototype/a\"' |& tee frontend/a.js")"
  fall B59 prototyp blockierend 2 AB - voll JSON Bash 'Rscript -e mit Inline-Code (DT-E43-4)' "$(bj_ph "Rscript -e 'writeLines(\"import h from \\\"../prototype/helper\\\";\", \"frontend/src/a.ts\")'")"
  fall B60 prototyp blockierend 2 AB - voll JSON Bash 'Umleitungsziel mit ".." fuehrt in den Arbeitsbaum zurueck, /tmp-Form (DT-E43-6)' "$(bj_ph "echo \"import x from '../prototype/a'\" > /tmp/../{AB}/frontend/a.js")"
  fall B61 prototyp blockierend 2 AB - voll JSON Bash 'Umleitungsziel mit ".." fuehrt in den Arbeitsbaum zurueck, Variablenform (DT-E43-6)' "$(bj_ph "echo \"import x from '../prototype/a'\" > \"\$TMPDIR\"/../{AB}/frontend/a.js")"
  fall B62 prototyp blockierend 2 AB - voll JSON Bash '"/dev/null" ohne Wortgrenze bleibt Schreibwirkung (DT-E43-6)' "$(bj_ph "echo \"import x from '../prototype/a'\" > /dev/nullx")"
  fall B63 prototyp blockierend 2 AB - voll JSON Bash 'Trenner hinter fluechtigem Ziel bleibt Schreibwirkung (DT-E43-8)' "$(bj_ph "echo \"import x from '../prototype/a'\" > /tmp/x;cp a {AB}/frontend/a.js")"
  fall L22 prototyp blockierend 2 AB - voll JSON Bash 'geschlossen am 2026-10-21, Posten 5, SR-001; Mutation MP12; Posten 5 unter R3-Q-010 (SR-001, B2-GATE-D05), neuer Fall am Prototyp-Gate: Umleitung mit Import aus prototype/ und eine Kommentarzeile aus 200000 Zeichen; Pruefstellen Schreibwirkung und Importmuster am Befehlstext ohne Abbruch des Schreibers' "$(bj_gross 'echo "import h from \"../prototype/helper\";" > frontend/src/a.ts')"
  fall B64 prototyp blockierend 2 AB - voll JSON Write 'Posten 5 unter R3-Q-010 (SR-001, B2-GATE-D05): Richtung 1 ueber das Write-Werkzeug, Import aus prototype/ in der ersten Zeile und eine Kommentarzeile aus 200000 Zeichen; Pruefstelle Richtung 1 am Dateiinhalt ohne Abbruch des Schreibers' "$(wj_gross 'frontend/src/a.ts' 'import h from "../prototype/helper";')"
  fall B65 prototyp blockierend 2 AB - voll JSON Write 'Posten 5 unter R3-Q-010 (SR-001, B2-GATE-D05): Richtung 2 ueber das Write-Werkzeug, Import aus dem Produktionscode in der ersten Zeile und eine Kommentarzeile aus 200000 Zeichen; Pruefstelle Richtung 2 am Dateiinhalt ohne Abbruch des Schreibers' "$(wj_gross 'prototype/x.js' 'import a from "../backend/api";')"
  fall B66 prototyp blockierend 2 AB - voll JSON Write 'Posten 2 unter R3-Q-010 (C3, 2026-10-22), Richtung 2 zu L05: Leerraum vor der Klammer bei require; Gegenprobe P43; Mutation MP16' "$(wj_ph 'prototype/x.js' 'const a = require ("../backend/api");')"
  fall B67 prototyp blockierend 2 AB - voll JSON Write 'Posten 2 unter R3-Q-010 (C3, 2026-10-22), Richtung 2 zu L06: @import url( ; Gegenprobe P45; Mutation MP17' "$(wj_ph 'prototype/x.css' '@import url("../frontend/style.css");')"
  fall B68 prototyp blockierend 2 AB - voll JSON Write 'Posten 2 unter R3-Q-010 (C3, 2026-10-22), Richtung 2 zu L07: Leerraum um das Gleichheitszeichen bei src; Gegenprobe P47; Mutation MP18' "$(wj_ph 'prototype/demo.html' '<img src = "../backend/x.png">')"
  fall B69 prototyp blockierend 2 AB - voll JSON Write 'Posten 2 unter R3-Q-010 (C3, 2026-10-22), Richtung 2: Leerraum um das Gleichheitszeichen bei href; Gegenprobe P49; Mutation MP18' "$(wj_ph 'prototype/demo.html' '<a href = "../frontend/index.html">x</a>')"
  fall B70 prototyp blockierend 2 AB - voll JSON Write 'Posten 2 unter R3-Q-010 (C3, 2026-10-22), Richtung 1: Leerraum um das Gleichheitszeichen bei href (L07 misst nur src); Gegenprobe P48; Mutation MP18' "$(wj_ph 'frontend/src/demo.html' '<link href = "../prototype/style.css">')"
  fall B71 prototyp blockierend 2 AB - voll JSON Write 'Posten 2 unter R3-Q-010 (C3, 2026-10-22), Richtung 2 zu L08: __import__ mit Modulnamen ohne Punkt; Gegenprobe P51; Mutation MP20' "$(wj_ph 'prototype/x.py' "m = __import__('backend')")"
  fall B72 prototyp blockierend 2 AB - voll JSON Write 'Posten 2 unter R3-Q-010 (C3, 2026-10-22), Richtung 2: JS-Zuweisung an src mit Leerraum (gewollt, Entscheid SA 2026-10-22; eigener Sachverhalt nach 6.13 f, Punkt 1); Gegenprobe P53; Mutation MP18' "$(wj_ph 'prototype/x.js' 'el.src = "../backend/y.png";')"
  fall B73 prototyp blockierend 2 AB - voll JSON Write 'Posten 2 unter R3-Q-010 (C3, 2026-10-22), Richtung 1: JS-Zuweisung an href mit Leerraum (gewollt, Entscheid SA 2026-10-22; eigener Sachverhalt nach 6.13 f, Punkt 1); Gegenprobe P54; Mutation MP18' "$(wj_ph 'frontend/src/a.js' 'link.href = "../prototype/z.css";')"
  fall S20 prototyp blockierend 2 AB - ohne-tr JSON Bash 'Posten 6 unter R3-Q-010 (C3, 2026-10-22): Bash-Weg, tr-Schritt von cmd_flach als erste Pruefstelle, die ohne tr scheitert; vor der Behebung Durchlass (rc 0); Mutation MP23' "$(bj_ph 'echo "import h from \"../prototype/helper\";" > frontend/src/a.ts')"
  fall S21 prototyp blockierend 2 AB - sed-ohne-schleife JSON Bash 'Posten 6 unter R3-Q-010 (C3, 2026-10-22): Bash-Weg, sed-Schritt der Schleife ueber die Blockkommentare von cmd_flach (PATH mit einem sed, das nur diesen Aufruf verweigert); vor der Behebung Durchlass (rc 0); Mutation MP22' "$(bj_ph 'echo "import h from \"../prototype/helper\";" > frontend/src/a.ts')"
  fall S22 prototyp blockierend 2 AB - sed-ohne-bereinigung JSON Bash 'Posten 6 unter R3-Q-010 (C3, 2026-10-22): Bash-Weg, sed-Schritt von bereinigt (PATH mit einem sed, das nur sed -E verweigert); vor der Behebung Durchlass (rc 0); Mutation MP24' "$(bj_ph 'echo "import h from \"../prototype/helper\";" > frontend/src/a.ts')"
  fall S23 prototyp blockierend 2 AB - ohne-sed JSON Write 'Posten 6 unter R3-Q-010 (C3, 2026-10-22): Weg der Dateiwerkzeuge, erster sed-Schritt von payload_norm (ohne sed im PATH); Eingabe wie B15, nur die normalisierte Fassung trifft; vor der Behebung Durchlass (rc 0); Mutationen MP25 und MP26 an den Einzelstellen (S30, S24)' "$(wj_ph 'frontend/src/a.ts' 'import h from /* c */ "../prototype/helper";')"
  fall S24 prototyp blockierend 2 AB - sed-ohne-schleife JSON Write 'Posten 6 unter R3-Q-010 (C3, 2026-10-22): Weg der Dateiwerkzeuge, sed-Schritt der Schleife ueber die Blockkommentare von payload_norm (PATH mit einem sed, das nur diesen Aufruf verweigert); Eingabe wie B15; vor der Behebung Durchlass (rc 0); Mutation MP26' "$(wj_ph 'frontend/src/a.ts' 'import h from /* c */ "../prototype/helper";')"
  fall S25 prototyp blockierend 2 AB - langsames-cat JSON Write 'Posten 7, Teil am Prototyp-Gate (C3, 2026-10-22): ein cat, das 20 s braucht (jeder innere Lauf liest die Eingabe mit cat), mit einer Eingabe, die ohne Verzoegerung mit 0 durchlaeuft; die eigene Zeitgrenze des Gates von 12 s sperrt mit Rueckgabewert 2; ohne die Grenze laeuft der Fall bis zur Grenze des Pruefmittels von 14 s und gilt als Durchlass; Gegenprobe S26; Mutationen MP28 und MP29; gemessen am 2026-10-22: Rueckgabewert 2 nach 12,0 s (Meldung Zeitgrenze, Rueckgabewert 124)' "$(wj_ph 'frontend/src/a.ts' 'const a = 1;')"
  fall S27 prototyp blockierend 2 AB - ohne-timeout JSON Write 'Posten 7, Teil am Prototyp-Gate (C3, 2026-10-22): PATH ohne timeout, harmlose Eingabe wie S25; das Gate sperrt mit einer Meldung, die timeout nennt, wie bei jq; Mutation MP30' "$(wj_ph 'frontend/src/a.ts' 'const a = 1;')"
  fall S28 prototyp blockierend 2 AB - timeout-fehler JSON Write 'Posten 7, Teil am Prototyp-Gate (C3, 2026-10-22): ein timeout, das mit 125 endet (Fehler von timeout), harmlose Eingabe wie S25; jeder andere Ausgang als 0 oder 2 endet mit Rueckgabewert 2 und einer Meldung (Zweig der Abbildung); Mutation MP31' "$(wj_ph 'frontend/src/a.ts' 'const a = 1;')"
  fall S29 prototyp blockierend 2 AB - sed-ohne-kommentar JSON Bash 'Posten 6 unter R3-Q-010 (C3, 2026-10-22): Bash-Weg, erster sed-Schritt von cmd_flach (PATH mit einem sed, das nur den Aufruf fuer die Zeilenkommentare verweigert); die Pruefung dieses Schritts erreicht kein Fall mit fehlendem sed, weil der sed der Schleife den Ausfall aufgefangen haette; vor der Behebung Durchlass (rc 0); Mutation MP21' "$(bj_ph 'echo "import h from \"../prototype/helper\";" > frontend/src/a.ts')"
  fall S30 prototyp blockierend 2 AB - sed-ohne-kommentar JSON Write 'Posten 6 unter R3-Q-010 (C3, 2026-10-22): Weg der Dateiwerkzeuge, erster sed-Schritt von payload_norm (PATH mit einem sed, das nur den Aufruf fuer die Zeilenkommentare verweigert); Eingabe wie B15; vor der Behebung Durchlass (rc 0); Mutation MP25' "$(wj_ph 'frontend/src/a.ts' 'import h from /* c */ "../prototype/helper";')"
}

# -----------------------------------------------------------------------------
# 16. Fallliste -- Teil 4.5 der Fallliste: Prototyp-Gate, Soll 0 (Kontext AB)
# -----------------------------------------------------------------------------
faelle_4_5_proto_soll0() {
  fall P01 prototyp durchlaufend 0 AB - voll JSON Write 'Import ohne Bezug auf die andere Seite (Regressionsschutz)' "$(wj_ph 'frontend/src/a.ts' 'import x from "./local";')"
  fall P03 prototyp durchlaufend 0 AB - voll JSON Write 'Doku-Ausnahme (Regressionsschutz)' "$(wj_ph 'docs/notiz.md' 'Der Prototyp importiert nichts: import h from "../prototype/helper"; ist verboten.')"
  fall P04 prototyp durchlaufend 0 AB - voll JSON Write 'Prototyp-Datei ohne Import (Regressionsschutz)' "$(wj_ph 'prototype/x.js' 'const a = 1;')"
  fall P05 prototyp durchlaufend 0 AB - voll JSON Edit 'Edit entfernt einen verbotenen Import (Falsch-Positiv-Kontrolle, Regressionsschutz)' "$(ej 'frontend/src/a.ts' 'import h from "../prototype/helper";' 'x')"
  fall P06 prototyp durchlaufend 0 AB - voll JSON Bash 'reines Suchen mit demselben Wortlaut' "$(bj_ph 'grep -rn "import h from \"../prototype/helper\"" frontend/')"
  fall P07 prototyp durchlaufend 0 AB - voll JSON Write 'ausserhalb des Projekts: nicht zustaendig' "$(wj_ph '/tmp/anderswo/a.ts' 'import h from "../prototype/helper";')"
  fall P08 prototyp durchlaufend 0 AB - voll JSON MultiEdit 'MultiEdit entfernt Import' "$(mej 'frontend/src/a.ts' 'import h from "../prototype/helper";' 'x')"
  fall P09 prototyp durchlaufend 0 AB - voll JSON Write 'Richtung 2 ohne Bezug auf Produktionscode' "$(wj_ph 'prototype/x.js' 'import a from "./local";')"
  fall P10 prototyp durchlaufend 0 AB - voll JSON Write 'HTML-Verweis im selben Verzeichnis' "$(wj_ph 'prototype/demo.html' '<script src="./demo.js"></script>')"
  fall P11 prototyp durchlaufend 0 AB - voll JSON Write 'Doku-Ausnahme *.txt' "$(wj_ph 'frontend/notiz.txt' 'import h from "../prototype/helper";')"
  fall P12 prototyp durchlaufend 0 AB - voll JSON Bash 'reines Lesen' "$(bj_ph 'cat frontend/src/a.ts')"
  fall P13 prototyp durchlaufend 0 AB - voll JSON Bash 'Schreibwirkung ohne Importmuster' "$(bj_ph 'echo "siehe prototype/" > notiz.txt')"
  fall P14 prototyp durchlaufend 0 AB - voll JSON Bash 'Interpreter ohne Importmuster (Gegenprobe zu ST-09)' "$(bj_ph "node -e 'console.log(1)'")"
  fall P15 prototyp durchlaufend 0 AB - voll JSON Bash 'Suchen mit dem Wortlaut von ST-04' "$(bj_ph 'grep -rn "require(\"../prototype\")" .')"
  fall P33 prototyp durchlaufend 0 AB - voll JSON Bash 'Gegenprobe zu ST-09 (E4.3): Interpreter mit Inline-Code ohne Importmuster' "$(bj_ph "python3 -c 'print(1)'")"
  fall B52 prototyp durchlaufend 0 AB - voll JSON Bash 'Kopieren ohne Importmuster ist keine Import-Verletzung; Schreibwirkung allein blockiert nicht (E4.3)' "$(bj_ph 'cp ../prototype/helper.js frontend/src/helper.js')"
  fall P34 prototyp durchlaufend 0 AB - voll JSON Read 'Gegenprobe ST-13 (Prototyp-Gate, E4.3): synthetisch (Read steht nicht im Matcher); realistische Gegenproben G01, P04' "$(rj 'x')"
  fall P35 prototyp grenze 0 AB - voll JSON Write 'P-10 (E4.3): gemeinsame Abhaengigkeiten werden nicht geprueft (benannte Grenze)' "$(wj_ph 'prototype/package.json' '{"dependencies": {"react": "18.0.0"}}')"
  fall P16 prototyp durchlaufend 0 AB - voll JSON Write 'aehnlicher Name ohne "prototype"' "$(wj_ph 'frontend/src/a.ts' 'import h from "../prototyp/helper";')"
  fall P17 prototyp durchlaufend 0 AB - voll JSON Write '"prototypes" ist nicht "prototype/"' "$(wj_ph 'frontend/src/a.ts' 'import h from "../prototypes/helper";')"
  fall P18 prototyp durchlaufend 0 AB - voll JSON Write 'Doku-Ausnahme *.md unter Produktionscode' "$(wj_ph 'frontend/README.md' 'import h from "../prototype/helper";')"
  fall P19 prototyp durchlaufend 0 AB - voll JSON Write 'Doku-Ausnahme docs/*' "$(wj_ph 'docs/x.py' 'from prototype import demo')"
  fall P20 prototyp durchlaufend 0 AB - voll JSON Write 'Zeichenkette ohne Importschluesselwort' "$(wj_ph 'frontend/src/a.ts' 'const s = "prototype/helper";')"
  fall P21 prototyp durchlaufend 0 AB - voll JSON Write 'Zeichenkette ohne Importschluesselwort, Richtung 2' "$(wj_ph 'prototype/x.js' 'const s = "backend/api";')"
  fall P22 prototyp durchlaufend 0 AB - voll JSON Bash 'Lesen' "$(bj_ph 'ls prototype/')"
  fall P23 prototyp durchlaufend 0 AB - voll JSON Bash 'Umleitung ohne Bezug auf prototype' "$(bj_ph 'echo "import x from \"./local\";" > frontend/src/a.ts')"
  fall P24 prototyp durchlaufend 0 AB - voll JSON Read 'Werkzeug ohne Inhalt' "$(rj 'frontend/src/a.ts')"
  fall P25 prototyp durchlaufend 0 AB - voll JSON Write 'Write ohne content' "$(wj_ohne_content 'frontend/src/a.ts')"
  fall P26 prototyp durchlaufend 0 AB - voll JSON Write '"prototype_alt" ist nicht "prototype/"' "$(wj_ph 'frontend/src/a.ts' 'import h from "../prototype_alt/helper";')"
  fall P27 prototyp durchlaufend 0 AB - voll JSON Write 'A1 Gegenprobe: Pfad verlaesst den Prototyp nicht (E4.2)' "$(wj_ph 'prototype/x.js' 'import u from "./lib/util";')"
  fall P28 prototyp durchlaufend 0 AB - voll JSON Write 'A1 Gegenprobe: HTML-Pfad relativ zum Dokument ohne ../ (E4.2)' "$(wj_ph 'prototype/demo.html' '<script src="src/main.js"></script>')"
  fall P29 prototyp durchlaufend 0 AB - voll JSON Write 'A1 Gegenprobe: ./ ohne folgendes ../ (HTML) (E4.2)' "$(wj_ph 'prototype/demo.html' '<script src="./app/app.js"></script>')"
  fall P30 prototyp durchlaufend 0 AB - voll JSON Write 'A1 Gegenprobe: ./ ohne folgendes ../ (Import) (E4.2)' "$(wj_ph 'prototype/x.js' 'const c = require("./app/config");')"
  fall P31 prototyp durchlaufend 0 AB - voll JSON Write 'A2 Gegenprobe: "app" ist keine Bauwurzel, kein Verzeichnisimport ohne Schraegstrich (E4.2)' "$(wj_ph 'prototype/components/x.js' 'import a from "../app";')"
  fall P32 prototyp durchlaufend 0 AB - voll JSON Write 'A3 Gegenprobe: "prototype" ohne vorangehenden Pfadtrenner oder Zeichenkettenanfang (E4.2)' "$(wj_ph 'frontend/src/a.ts' 'import x from "es-prototype";')"
  fall L05 prototyp blockierend 2 AB - voll JSON Write 'geschlossen am 2026-10-22 (Posten 2; Festlegung ADR 0002, 6.13 c, Nachtrag vom 2026-10-21 zur Abnahme von Posten 4 und 5 -- Festlegung fuer C3), Mutation MP16; vormals belegte Luecke: Klasse belegte-luecke nach Spalte Folge seit 2026-10-14 (Posten 1, erste Aenderung am Pruefmittel nach dem Nachtrag vom 2026-09-23); Posten 2 unter R3-Q-010 (ADR 0002, 6.13 c), Soll 2 mit dem Bau von Posten 2; vormals Pruefstand: beobachtete Luecke A5-Leerraum-require (2026-09-23), heute 0; Entscheid: Fortschreibung ADR 0002, 6.13 c' "$(wj_ph 'frontend/src/a.ts' 'const h = require ("../prototype/helper");')"
  fall L06 prototyp blockierend 2 AB - voll JSON Write 'geschlossen am 2026-10-22 (Posten 2; Festlegung ADR 0002, 6.13 c, Nachtrag vom 2026-10-21 zur Abnahme von Posten 4 und 5 -- Festlegung fuer C3), Mutation MP17; vormals belegte Luecke: Klasse belegte-luecke nach Spalte Folge seit 2026-10-14 (Posten 1, erste Aenderung am Pruefmittel nach dem Nachtrag vom 2026-09-23); Posten 2 unter R3-Q-010 (ADR 0002, 6.13 c), Soll 2 mit dem Bau von Posten 2; vormals Pruefstand: beobachtete Luecke A5-atimport-url (2026-09-23), heute 0; Entscheid: Fortschreibung ADR 0002, 6.13 c' "$(wj_ph 'frontend/src/a.css' '@import url("../prototype/theme.css");')"
  fall L07 prototyp blockierend 2 AB - voll JSON Write 'geschlossen am 2026-10-22 (Posten 2; Festlegung ADR 0002, 6.13 c, Nachtrag vom 2026-10-21 zur Abnahme von Posten 4 und 5 -- Festlegung fuer C3), Mutation MP18; vormals belegte Luecke: Klasse belegte-luecke nach Spalte Folge seit 2026-10-14 (Posten 1, erste Aenderung am Pruefmittel nach dem Nachtrag vom 2026-09-23); Posten 2 unter R3-Q-010 (ADR 0002, 6.13 c), Soll 2 mit dem Bau von Posten 2; vormals Pruefstand: beobachtete Luecke A5-Leerraum-Gleichheit (2026-09-23), heute 0; Entscheid: Fortschreibung ADR 0002, 6.13 c' "$(wj_ph 'frontend/src/demo.html' '<img src = "../prototype/x.png">')"
  fall L08 prototyp blockierend 2 AB - voll JSON Write 'geschlossen am 2026-10-22 (Posten 2; Festlegung ADR 0002, 6.13 c, Nachtrag vom 2026-10-21 zur Abnahme von Posten 4 und 5 -- Festlegung fuer C3), Mutation MP19; vormals belegte Luecke: Klasse belegte-luecke nach Spalte Folge seit 2026-10-14 (Posten 1, erste Aenderung am Pruefmittel nach dem Nachtrag vom 2026-09-23); Posten 2 unter R3-Q-010 (ADR 0002, 6.13 c), Soll 2 mit dem Bau von Posten 2; vormals Pruefstand: beobachtete Luecke A5-import-ohne-Punkt (2026-09-23), heute 0; Entscheid: Fortschreibung ADR 0002, 6.13 c' "$(wj_ph 'backend/src/a.py' "m = __import__('prototype')")"
  fall L09 prototyp belegte-luecke 0 AB - voll JSON Write 'Klasse belegte-luecke nach Spalte Folge seit 2026-10-14 (Posten 1, erste Aenderung am Pruefmittel nach dem Nachtrag vom 2026-09-23); Posten 3 unter R3-Q-010 (ADR 0002, 6.13 c), Soll 2 mit dem Bau von Posten 3; vormals Pruefstand: beobachtete Luecke B-1-dynamisch-unnormalisierter-Pfad (2026-09-23), heute 0; Entscheid: Fortschreibung ADR 0002, 6.13 c' "$(wj_ph '{AB}/./prototype/x.js' 'import a from "./../backend/api";')"
  fall L10 prototyp grenze 0 AB - voll JSON Write 'Klasse grenze nach Spalte Folge seit 2026-10-14 (Posten 1, erste Aenderung am Pruefmittel nach dem Nachtrag vom 2026-09-23); steht in GP-2; vormals Pruefstand: beobachtete Luecke A4-Wurzelpfad (2026-09-23), heute 0; Entscheid: Fortschreibung ADR 0002, 6.13 c' "$(wj_ph 'prototype/demo.html' '<script src="/backend/app.js"></script>')"
  fall L11 prototyp grenze 0 AB - voll JSON Write 'Klasse grenze nach Spalte Folge seit 2026-10-14 (Posten 1, erste Aenderung am Pruefmittel nach dem Nachtrag vom 2026-09-23); steht in GP-2; vormals Pruefstand: beobachtete Luecke A4-beliebiger-Vorspann (2026-09-23), heute 0; Entscheid: Fortschreibung ADR 0002, 6.13 c' "$(wj_ph 'prototype/x.js' 'import a from "../x/../backend/api";')"
  fall B02 prototyp blockierend 2 AB - voll JSON Write 'geschlossen mit E4.2 (vormals ST-04)' "$(wj_ph 'frontend/src/a.ts' 'import h from "../prototype";')"
  fall B03 prototyp blockierend 2 AB - voll JSON Write 'geschlossen mit E4.2 (vormals ST-04)' "$(wj_ph 'frontend/src/a.ts' "import h from '../../prototype'")"
  fall B06 prototyp blockierend 2 AB - voll JSON Write 'geschlossen mit E4.2 (vormals ST-05)' "$(wj_ph 'prototype/x.js' 'import a from "./../backend/api";')"
  fall B07 prototyp blockierend 2 AB - voll JSON Write 'geschlossen mit E4.2 (vormals P-01)' "$(wj_ph 'prototype/demo.html' '<script src="../backend/app.js"></script>')"
  fall B08 prototyp blockierend 2 AB - voll JSON Write 'geschlossen mit E4.2 (vormals P-01)' "$(wj_ph 'prototype/demo.html' '<link href="../frontend/style.css">')"
  fall B09 prototyp blockierend 2 AB - voll JSON Bash 'geschlossen mit E4.3 (vormals ST-09)' "$(bj_ph "$(printf 'python3 -c '"'"'open("frontend/src/a.ts","w").write("import h from \\"../prototype/helper\\";")'"'"'')")"
  fall ZF5a prototyp blockierend 2 AB - voll JSON Write 'geschlossen mit E4.2 (vormals ST-04)' "$(wj_ph 'frontend/src/a.ts' 'const h = require("../prototype");')"
  fall ZF5b prototyp blockierend 2 AB - voll JSON Write 'geschlossen mit E4.2 (vormals ST-04)' "$(wj_ph 'frontend/src/a.ts' 'const h = await import("../prototype");')"
  fall ZF5c prototyp blockierend 2 AB - voll JSON Write 'geschlossen mit E4.2 (vormals ST-04)' "$(wj_ph 'frontend/src/a.css' '@import "../prototype";')"
  fall ZF5e prototyp blockierend 2 AB - voll JSON Write 'geschlossen mit E4.2 (vormals ST-04)' "$(wj_ph 'frontend/src/a.ts' 'import h from "..\prototype\helper";')"
  fall ZF6a prototyp blockierend 2 AB - voll JSON Write 'geschlossen mit E4.2 (vormals ST-05)' "$(wj_ph 'prototype/x.js' 'const a = require("./../backend/api");')"
  fall ZF6b prototyp blockierend 2 AB - voll JSON Write 'geschlossen mit E4.2 (vormals ST-05)' "$(wj_ph 'prototype/x.css' '@import "./../frontend/style.css";')"
  fall ZF6c prototyp blockierend 2 AB - voll JSON Write 'geschlossen mit E4.2 (vormals P-01)' "$(wj_ph 'prototype/demo.html' '<img src="../backend/x.png">')"
  fall ZF6d prototyp blockierend 2 AB - voll JSON Write 'geschlossen mit E4.2 (vormals P-01)' "$(wj_ph 'prototype/demo.html' '<a href="../frontend/index.html">x</a>')"
  fall ZF7a prototyp blockierend 2 AB - voll JSON Bash 'geschlossen mit E4.3 (vormals ST-09, Zusatzfall 7, node -e)' "$(bj_ph "$(printf 'node -e '"'"'require("fs").writeFileSync("frontend/src/a.ts","import h from \\"../prototype/helper\\";")'"'"'')")"
  fall ZF7c prototyp blockierend 2 AB - voll JSON Bash 'geschlossen mit E4.3 (vormals ST-09, Zusatzfall 7, php -r)' "$(bj_ph "$(printf 'php -r '"'"'file_put_contents("frontend/src/a.ts","import h from \\"../prototype/helper\\";");'"'"'')")"
  fall ZF7d prototyp blockierend 2 AB - voll JSON Bash 'geschlossen mit E4.3 (vormals ST-09, Zusatzfall 7, ruby -e)' "$(bj_ph "$(printf 'ruby -e '"'"'File.write("frontend/src/a.ts","import h from \\"../prototype/helper\\";")'"'"'')")"
  fall ZF9 prototyp durchlaufend 0 AB - voll JSON Write 'Klasse durchlaufend nach Spalte Folge seit 2026-10-14 (Posten 1, erste Aenderung am Pruefmittel nach dem Nachtrag vom 2026-09-23); vormals Pruefstand: Zusatzfall 9: Reichweite der Ausnahmeliste (.claude/*), heute 0; Prueffall, kein Befund (ADR 0002, 6.13 d)' "$(wj_ph '.claude/hooks/x.sh' 'import h from "../prototype/helper";')"
  fall ZF10d prototyp grenze 0 AB - voll JSON bash 'Klasse grenze nach Spalte Folge seit 2026-10-14 (Posten 1, erste Aenderung am Pruefmittel nach dem Nachtrag vom 2026-09-23); Fallklasse GP-4 und Kopfkommentar des Prototyp-Gates seit 2026-10-22 (C3, Posten 2); vormals Pruefstand: Zusatzfall 10: Bash-Pfad haengt an der Gleichheit "Bash", tool_name "bash" endet 0; heutiger Stand' "$(bj_ph "$(printf 'cat > frontend/src/a.ts <<EOT\nimport h from "../prototype/helper";\nEOT')" 'bash')"
  fall B35 prototyp blockierend 2 AB - voll JSON Write 'geschlossen mit E4.2 (vormals P-01)' "$(wj_ph 'prototype/x.py' 'from backend.api import x')"
  fall B41 prototyp blockierend 2 AB - voll JSON Write 'geschlossen mit E4.2 (vormals P-01)' "$(wj_ph 'prototype/x.py' 'import importlib; m = importlib.import_module("backend.api")')"
  fall B42 prototyp blockierend 2 AB - voll JSON Write 'geschlossen mit E4.2 (vormals P-01)' "$(wj_ph 'prototype/x.py' 'import backend.api')"
  fall P36 prototyp durchlaufend 0 AB - voll JSON Bash 'Dateiwerkzeug mv ohne Importmuster (Gegenprobe zu B54, B-2)' "$(bj_ph 'mv frontend/src/a.ts frontend/src/b.ts')"
  fall P37 prototyp durchlaufend 0 AB - voll JSON Bash 'Suchen mit 2>/dev/null, fluechtiges Ziel ausgenommen (DT-E43-5)' "$(bj_ph "grep -r \"require('../prototype/a')\" . 2>/dev/null")"
  fall P38 prototyp pruefstand 2 AB - voll JSON Bash 'DT-E43-5, vorgemessen: rc=2 statt der im Behebungsauftrag angenommenen 0 -- die Interpreterklasse (python3 -c) matcht auf dem bereinigten Text unabhaengig von der Umleitung nach /dev/null, weil sie nicht auf ein Umleitungszeichen angewiesen ist; Abweichung gemeldet, keine Aenderung ohne Weisung' "$(bj_ph "python3 -c 'print(\"import h from \\\"../prototype/helper\\\"\")' > /dev/null")"
  fall P39 prototyp durchlaufend 0 AB - voll JSON Bash 'fluechtiges Ziel /tmp ohne "..", kein Schreiben in den Baum (DT-E43-6, Regressionsschutz)' "$(bj_ph "echo \"import x from '../prototype/a'\" > /tmp/a.js")"
  fall L12 prototyp grenze 0 AB - voll JSON Write 'Klasse grenze nach Spalte Folge seit 2026-10-14 (Posten 1, erste Aenderung am Pruefmittel nach dem Nachtrag vom 2026-09-23); steht in GP-2; vormals Pruefstand: benannte Grenze GP-2, heute 0; Aufnahme: Fortschreibung 6.13 c' "$(wj_ph 'prototype/demo.html' '<script src="../backend"></script>')"
  fall L13 prototyp grenze 0 AB - voll JSON Write 'Klasse grenze nach Spalte Folge seit 2026-10-14 (Posten 1, erste Aenderung am Pruefmittel nach dem Nachtrag vom 2026-09-23); steht in GP-2; vormals Pruefstand: benannte Grenze GP-2, heute 0; Aufnahme: Fortschreibung 6.13 c' "$(wj_ph 'prototype/demo.html' '<link href="..\frontend\style.css">')"
  fall L14 prototyp grenze 0 AB - voll JSON Write 'Klasse grenze nach Spalte Folge seit 2026-10-14 (Posten 1, erste Aenderung am Pruefmittel nach dem Nachtrag vom 2026-09-23); steht in GP-2; vormals Pruefstand: benannte Grenze GP-2, heute 0; Aufnahme: Fortschreibung 6.13 c' "$(wj_ph 'prototype/x.js' 'import a from "..\\backend\\api";')"
  fall L15 prototyp grenze 0 AB - voll JSON Write 'Klasse grenze nach Spalte Folge seit 2026-10-14 (Posten 1, erste Aenderung am Pruefmittel nach dem Nachtrag vom 2026-09-23); steht in GP-2; vormals Pruefstand: benannte Grenze GP-2, heute 0; Aufnahme: Fortschreibung 6.13 c' "$(wj_ph 'prototype/x.mjs' 'import "./././../backend/x.mjs";')"
  fall L16 prototyp grenze 0 AB - voll JSON Write 'Klasse grenze nach Spalte Folge seit 2026-10-14 (Posten 1, erste Aenderung am Pruefmittel nach dem Nachtrag vom 2026-09-23); steht in GP-2; vormals Pruefstand: benannte Grenze GP-2, heute 0; Aufnahme: Fortschreibung 6.13 c' "$(wj_ph 'prototype/demo.html' '<link href="~/frontend/x.css">')"
  fall P40 prototyp durchlaufend 0 AB - voll JSON Bash 'Posten 5 unter R3-Q-010, Gegenprobe zu L22: Schreibwirkung ohne Importmuster und eine Kommentarzeile aus 200000 Zeichen bleibt zulaessig' "$(bj_gross 'echo "siehe prototype/" > notiz.txt')"
  fall P41 prototyp durchlaufend 0 AB - voll JSON Write 'Posten 5 unter R3-Q-010, Gegenprobe zu B64 und B65: Dateiinhalt ohne Import und eine Kommentarzeile aus 200000 Zeichen bleibt zulaessig' "$(wj_gross 'frontend/src/a.ts' 'const a = 1;')"
  fall L23 prototyp blockierend 2 AB - ohne-sed JSON Bash 'geschlossen am 2026-10-22 (Posten 6; Festlegung ADR 0002, 6.13 c, Nachtrag vom 2026-10-21 zur Abnahme von Posten 4 und 5 -- Festlegung fuer C3), Mutationen MP21, MP22 und MP24 an den Einzelstellen (S29, S21, S22); vormals belegte Luecke: Posten 6 unter R3-Q-010 (2026-10-21), belegte Luecke, nicht gebaut, terminiert mit der naechsten Aenderung am Prototyp-Gate: die sed-Schritte (cmd_flach, bereinigt) pruefen keinen Rueckgabewert; ohne sed im PATH laeuft B11 (sperrt mit vollem PATH) durch; Soll = heutiger Stand 0' "$(bj_ph 'echo "import h from \"../prototype/helper\";" > frontend/src/a.ts')"
  fall L24 prototyp blockierend 2 AB - ohne-tr JSON Write 'geschlossen am 2026-10-22 (Posten 6; Festlegung ADR 0002, 6.13 c, Nachtrag vom 2026-10-21 zur Abnahme von Posten 4 und 5 -- Festlegung fuer C3), Mutation MP27; vormals belegte Luecke: Posten 6 unter R3-Q-010 (2026-10-21), belegte Luecke, nicht gebaut, terminiert mit der naechsten Aenderung am Prototyp-Gate: der tr-Schritt von payload_norm prueft keinen Rueckgabewert; ohne tr im PATH laeuft ein Import mit Zeilenumbruch (sperrt mit vollem PATH) durch; Soll = heutiger Stand 0' "$(wj_ph 'frontend/src/a.ts' $'import h from\n  "../prototype/helper";')"
  fall P42 prototyp durchlaufend 0 AB - voll JSON Write 'Posten 2 unter R3-Q-010 (C3, 2026-10-22), Gegenprobe zu L05: require mit Leerraum vor der Klammer, Pfad ohne Bezug ueber die Trennung (Produktionscode)' "$(wj_ph 'frontend/src/a.ts' 'const u = require ("./util");')"
  fall P43 prototyp durchlaufend 0 AB - voll JSON Write 'Posten 2 unter R3-Q-010 (C3, 2026-10-22), Gegenprobe zu B66: require mit Leerraum vor der Klammer, Pfad ohne Bezug ueber die Trennung (Prototyp)' "$(wj_ph 'prototype/x.js' 'const u = require ("./util");')"
  fall P44 prototyp durchlaufend 0 AB - voll JSON Write 'Posten 2 unter R3-Q-010 (C3, 2026-10-22), Gegenprobe zu L06: @import url( ohne Bezug ueber die Trennung (Produktionscode)' "$(wj_ph 'frontend/src/a.css' '@import url("./theme.css");')"
  fall P45 prototyp durchlaufend 0 AB - voll JSON Write 'Posten 2 unter R3-Q-010 (C3, 2026-10-22), Gegenprobe zu B67: @import url( ohne Bezug ueber die Trennung (Prototyp)' "$(wj_ph 'prototype/x.css' '@import url("./theme.css");')"
  fall P46 prototyp durchlaufend 0 AB - voll JSON Write 'Posten 2 unter R3-Q-010 (C3, 2026-10-22), Gegenprobe zu L07: Leerraum um das Gleichheitszeichen bei src ohne Bezug ueber die Trennung (Produktionscode)' "$(wj_ph 'frontend/src/demo.html' '<img src = "./x.png">')"
  fall P47 prototyp durchlaufend 0 AB - voll JSON Write 'Posten 2 unter R3-Q-010 (C3, 2026-10-22), Gegenprobe zu B68: Leerraum um das Gleichheitszeichen bei src ohne Bezug ueber die Trennung (Prototyp)' "$(wj_ph 'prototype/demo.html' '<img src = "./x.png">')"
  fall P48 prototyp durchlaufend 0 AB - voll JSON Write 'Posten 2 unter R3-Q-010 (C3, 2026-10-22), Gegenprobe zu B70: Leerraum um das Gleichheitszeichen bei href ohne Bezug ueber die Trennung (Produktionscode)' "$(wj_ph 'frontend/src/demo.html' '<link href = "./style.css">')"
  fall P49 prototyp durchlaufend 0 AB - voll JSON Write 'Posten 2 unter R3-Q-010 (C3, 2026-10-22), Gegenprobe zu B69: Leerraum um das Gleichheitszeichen bei href ohne Bezug ueber die Trennung (Prototyp)' "$(wj_ph 'prototype/demo.html' '<link href = "./style.css">')"
  fall P50 prototyp durchlaufend 0 AB - voll JSON Write 'Posten 2 unter R3-Q-010 (C3, 2026-10-22), Gegenprobe zu L08: __import__ mit Modulnamen ohne Punkt, ohne Bezug ueber die Trennung (Produktionscode)' "$(wj_ph 'backend/src/a.py' "m = __import__('os')")"
  fall P51 prototyp durchlaufend 0 AB - voll JSON Write 'Posten 2 unter R3-Q-010 (C3, 2026-10-22), Gegenprobe zu B71: __import__ mit Modulnamen ohne Punkt, ohne Bezug ueber die Trennung (Prototyp)' "$(wj_ph 'prototype/x.py' "m = __import__('os')")"
  fall S26 prototyp durchlaufend 0 AB - kurzes-cat JSON Write 'Posten 7, Teil am Prototyp-Gate (C3, 2026-10-22), Gegenprobe zu S25: dieselbe Eingabe, cat um 4 s verzoegert (deutlich unter der Grenze von 12 s), Rueckgabewert 0; gemessen am 2026-10-22: Rueckgabewert 0 nach 4,0 s' "$(wj_ph 'frontend/src/a.ts' 'const a = 1;')"
  fall P52 prototyp durchlaufend 0 AB - voll JSON Write 'Posten 2 unter R3-Q-010 (C3, 2026-10-22), gewollter Durchlass (Entscheid SA 2026-10-22): der blosse JS-Modulname import("backend") in einer Prototyp-Datei wird nicht gesperrt, die statische Form ebenso wenig; die Endung fuer den blossen Modulnamen gilt nur fuer import_module und __import__ (Python); Gegenprobe zu B71; Mutation MP32 faellt hier' "$(wj_ph 'prototype/x.js' 'const m = await import("backend");')"
  fall P53 prototyp durchlaufend 0 AB - voll JSON Write 'Posten 2 unter R3-Q-010 (C3, 2026-10-22), Gegenprobe zu B72: JS-Zuweisung an src mit Leerraum ohne Bezug ueber die Trennung (Prototyp)' "$(wj_ph 'prototype/x.js' 'el.src = "./y.png";')"
  fall P54 prototyp durchlaufend 0 AB - voll JSON Write 'Posten 2 unter R3-Q-010 (C3, 2026-10-22), Gegenprobe zu B73: JS-Zuweisung an href mit Leerraum ohne Bezug ueber die Trennung (Produktionscode)' "$(wj_ph 'frontend/src/a.js' 'link.href = "./z.css";')"
}

# -----------------------------------------------------------------------------
# 17. Fallliste -- Teil 4.6 der Fallliste: Prototyp-Gate, unlesbare Eingabe (ROH, ST-13)
# -----------------------------------------------------------------------------
faelle_4_6_proto_roh() {
  fall S04 prototyp blockierend 2 AB - voll ROH - 'geschlossen mit E4.3 (vormals ST-13)' ""
  fall S05 prototyp blockierend 2 AB - voll ROH - 'geschlossen mit E4.3 (vormals ST-13)' 'kein json'
  fall ZF8c prototyp blockierend 2 AB - voll ROH - 'geschlossen mit E4.3 (vormals ST-13), Dateiwerkzeug' '{"tool_name":"Write","tool_input":"frontend/src/a.ts"}'
  fall ZF8d prototyp blockierend 2 AB - voll ROH - 'geschlossen mit E4.3 (vormals ST-13), Bash' '{"tool_name":"Bash","tool_input":"echo x"}'
  fall S09 prototyp blockierend 2 AB - voll ROH - 'JSON-Strom mit zwei Objekten, B-4' '{"tool_name":"Bash","tool_input":{"command":"git status"}}{"tool_name":"Bash","tool_input":{"command":"git push origin main"}}'
}

alle_faelle() {
  faelle_4_1_main_soll2
  faelle_4_2_main_soll0
  faelle_4_3_main_roh
  faelle_4_4_proto_soll2
  faelle_4_5_proto_soll0
  faelle_4_6_proto_roh
}

# -----------------------------------------------------------------------------
# 18. Arbeitsbaum-Vergleich (D19-Grundsatz: der Lauf aendert nicht, worueber er
#     urteilt). Die Erhebung selbst steht in Abschnitt 4a/4b (VOR dem Anlegen
#     der Wegwerfumgebung, N-5); hier nur der Vergleich mit dem Nachher-Stand.
# -----------------------------------------------------------------------------
arbeitsbaum_unveraendert_pruefen() {
  local zweck="$1"
  local nachher_status nachher_hash_inhalt nachher_hash_unversioniert
  local ok=1
  if ! nachher_status=$(schnappschuss_status); then ok=0; fi
  if ! nachher_hash_inhalt=$(schnappschuss_hash_inhalt) || [ -z "$nachher_hash_inhalt" ]; then ok=0; fi
  if ! nachher_hash_unversioniert=$(schnappschuss_hash_unversioniert); then ok=0; fi
  if [ "$VORHER_OK" != 1 ] || [ "$ok" != 1 ] \
      || [ "$VORHER_STATUS" != "$nachher_status" ] \
      || [ "$VORHER_HASH_INHALT" != "$nachher_hash_inhalt" ] \
      || [ "$VORHER_HASH_UNVERSIONIERT" != "$nachher_hash_unversioniert" ]; then
    echo "pretooluse-gates-selbsttest: VERLETZT -- Arbeitsbaum hat sich waehrend $zweck veraendert (oder die Unveraendertheit war nicht belegbar)." >&2
    return 1
  fi
  echo "pretooluse-gates-selbsttest: Arbeitsbaum unveraendert (Statusliste inklusive ignorierter Pfade, Inhaltspruefsummen der versionierten und der unversionierten Dateien vorher/nachher gleich)"
  return 0
}

# -----------------------------------------------------------------------------
# 19. Normalmodus
# -----------------------------------------------------------------------------
normalmodus_ausfuehren() {
  echo "pretooluse-gates-selbsttest: Modus normal, Arbeitsbaum $REPO_WURZEL"
  echo "pretooluse-gates-selbsttest: Wegwerf-Klon auf main: $KLON_COMMIT (Ref $KLON_REF), Zweig main"
  echo "pretooluse-gates-selbsttest: Gate main $GATE_MAIN_AKTIV sha256 $SHA_MAIN_KURZ$GATE_MAIN_ANZEIGE_ZUSATZ"
  echo "pretooluse-gates-selbsttest: Gate prototyp $GATE_PROTOTYP_AKTIV sha256 $SHA_PROTO_KURZ$GATE_PROTOTYP_ANZEIGE_ZUSATZ"

  AKTIV_GATE_MAIN="$GATE_MAIN_AKTIV"
  AKTIV_GATE_PROTOTYP="$GATE_PROTOTYP_AKTIV"
  AKTIVE_MUTATION_GATE=""

  alle_faelle

  echo "pretooluse-gates-selbsttest: Gate main: $MAIN_SOLL2_ANZAHL Faelle mit Soll 2 (Ausgang: blockiert), $MAIN_SOLL0_ANZAHL Faelle mit Soll 0 (Ausgang: durchgelassen)"
  echo "pretooluse-gates-selbsttest: Gate prototyp: $PROTO_SOLL2_ANZAHL Faelle mit Soll 2 (Ausgang: blockiert), $PROTO_SOLL0_ANZAHL Faelle mit Soll 0 (Ausgang: durchgelassen)"
  local klasse zeile_main="pretooluse-gates-selbsttest: Gate main, nach Klasse:" zeile_proto="pretooluse-gates-selbsttest: Gate prototyp, nach Klasse:"
  for klasse in blockierend durchlaufend belegte-luecke grenze pruefstand; do
    zeile_main="$zeile_main $klasse=${KLASSEN_ANZAHL_MAIN[$klasse]:-0}"
    zeile_proto="$zeile_proto $klasse=${KLASSEN_ANZAHL_PROTO[$klasse]:-0}"
  done
  echo "$zeile_main"
  echo "$zeile_proto"
  local je_gate_ok=1
  if [ "${KLASSEN_ANZAHL_MAIN[blockierend]:-0}" -eq 0 ] || [ "${KLASSEN_ANZAHL_MAIN[durchlaufend]:-0}" -eq 0 ] \
      || [ "${KLASSEN_ANZAHL_PROTO[blockierend]:-0}" -eq 0 ] || [ "${KLASSEN_ANZAHL_PROTO[durchlaufend]:-0}" -eq 0 ]; then
    je_gate_ok=0
    echo "pretooluse-gates-selbsttest: ABWEICHUNG -- nicht je Gate mindestens ein Fall blockierend UND ein Fall durchlaufend." >&2
  fi

  local fallklassen_ok=1
  local n=${#FK_ID[@]} j
  for (( j=0; j<n; j++ )); do
    local id="${FK_ID[$j]}" gate="${FK_GATE[$j]}" typ="${FK_TYP[$j]}" text="${FK_TEXT[$j]}" kennungen="${FK_KENNUNGEN[$j]}"
    local ziel_soll=0
    [ "$typ" = "gedeckt" ] && ziel_soll=2
    local treffer=0 fehlend="" k
    for k in $kennungen; do
      if [ -z "${URTEIL_VON[$k]+x}" ]; then fehlend="$fehlend $k"; continue; fi
      if [ "${SOLL_VON[$k]}" = "$ziel_soll" ] && [ "${URTEIL_VON[$k]}" = "BESTANDEN" ]; then treffer=1; fi
    done
    local status
    if [ -n "$fehlend" ]; then
      status="FEHLEND:$fehlend"; fallklassen_ok=0
    elif [ "$treffer" -eq 1 ]; then
      status="gedeckt"
    else
      status="NICHT_GEDECKT"; fallklassen_ok=0
    fi
    echo "pretooluse-gates-selbsttest: Fallklasse $id ($gate, $typ) \"$text\" -> $kennungen: $status"
  done

  local ak_ok=1
  local m=${#AK_ID[@]}
  for (( j=0; j<m; j++ )); do
    local id="${AK_ID[$j]}" domain="${AK_DOMAIN[$j]}" kennungen="${AK_KENNUNGEN[$j]}" anmerkung="${AK_ANMERKUNG[$j]}"
    local fehlend="" k
    for k in $kennungen; do
      case "$domain" in
        fallliste)
          [ -n "${URTEIL_VON[$k]+x}" ] || fehlend="$fehlend $k"
          ;;
        fallklassen)
          local ok=0 fid
          for fid in "${FK_ID[@]}"; do [ "$fid" = "$k" ] && ok=1; done
          [ "$ok" -eq 1 ] || fehlend="$fehlend $k"
          ;;
        gemischt)
          local ok=0 mid
          if [ -n "${URTEIL_VON[$k]+x}" ]; then
            ok=1
          else
            for mid in "${MUT_KENNUNG[@]}"; do [ "$mid" = "$k" ] && ok=1; done
          fi
          [ "$ok" -eq 1 ] || fehlend="$fehlend $k"
          ;;
      esac
    done
    local status="vorhanden"
    if [ -n "$fehlend" ]; then status="FEHLEND:$fehlend"; ak_ok=0; fi
    echo "pretooluse-gates-selbsttest: Abnahmekriterium $id -> $kennungen ($anmerkung): $status"
  done

  local luecken_zeile="pretooluse-gates-selbsttest: belegte Luecken (Soll = heutiger Stand):"
  local luecken_leer=1
  local k
  for k in "${ALLE_KENNUNGEN[@]}"; do
    if [ "${KLASSE_VON[$k]}" = "belegte-luecke" ]; then
      luecken_zeile="$luecken_zeile $k ${BEFUND_VON[$k]:-UNBEKANNT},"
      luecken_leer=0
    fi
  done
  if [ "$luecken_leer" -eq 1 ]; then
    luecken_zeile="$luecken_zeile keine"
  fi
  echo "${luecken_zeile%,}"

  local arbeitsbaum_ok=1
  arbeitsbaum_unveraendert_pruefen "des Laufs" || arbeitsbaum_ok=0

  local gesamt=${#ALLE_KENNUNGEN[@]}
  local bestanden_anzahl=${#BESTANDENE_KENNUNGEN[@]}
  local alle_bestanden=1
  [ "$bestanden_anzahl" -eq "$gesamt" ] || alle_bestanden=0
  local zaehlung_ok=1
  if [ "$MAIN_SOLL2_ANZAHL" -eq 0 ] || [ "$MAIN_SOLL0_ANZAHL" -eq 0 ] || [ "$PROTO_SOLL2_ANZAHL" -eq 0 ] || [ "$PROTO_SOLL0_ANZAHL" -eq 0 ]; then
    zaehlung_ok=0
  fi

  local vollstaendigkeit_ok=1
  if [ "$gesamt" -ne "$ERWARTETE_FAELLE" ]; then
    echo "pretooluse-gates-selbsttest: ABWEICHUNG -- $gesamt statt $ERWARTETE_FAELLE Faelle gezaehlt." >&2
    vollstaendigkeit_ok=0
  fi
  if [ "$VOLLSTAENDIGKEIT_OK" != 1 ]; then vollstaendigkeit_ok=0; fi
  if [ "$je_gate_ok" != 1 ]; then vollstaendigkeit_ok=0; fi

  if [ "${#GEFALLENE_KENNUNGEN[@]}" -gt 0 ]; then
    echo "pretooluse-gates-selbsttest: gefallene Faelle: ${GEFALLENE_KENNUNGEN[*]}" >&2
  fi

  local rc=2
  if [ "$alle_bestanden" -eq 1 ] && [ "$zaehlung_ok" -eq 1 ] && [ "$arbeitsbaum_ok" -eq 1 ] \
      && [ "$fallklassen_ok" -eq 1 ] && [ "$vollstaendigkeit_ok" -eq 1 ] && [ "$ak_ok" -eq 1 ]; then
    rc=0
  fi

  echo "pretooluse-gates-selbsttest: $bestanden_anzahl von $gesamt Faellen bestanden, Rueckgabewert $rc."
  return "$rc"
}

# -----------------------------------------------------------------------------
# 20. Modus --mutationen
# -----------------------------------------------------------------------------
mutationsmodus_ausfuehren() {
  echo "pretooluse-gates-selbsttest: Modus mutationen, Arbeitsbaum $REPO_WURZEL"
  echo "pretooluse-gates-selbsttest: Wegwerf-Klon auf main: $KLON_COMMIT (Ref $KLON_REF), Zweig main"
  echo "pretooluse-gates-selbsttest: Gate main $GATE_MAIN_AKTIV sha256 $SHA_MAIN_KURZ$GATE_MAIN_ANZEIGE_ZUSATZ"
  echo "pretooluse-gates-selbsttest: Gate prototyp $GATE_PROTOTYP_AKTIV sha256 $SHA_PROTO_KURZ$GATE_PROTOTYP_ANZEIGE_ZUSATZ"

  local gesamt_mutationen=${#MUT_KENNUNG[@]}

  # N-4: Grundlinie -- die vollstaendige Fallliste gegen die UNVERAENDERTEN
  # Gate-Dateien (bzw. deren Ueberschreibung, DT-E41-02). Ist sie nicht gruen,
  # ist "ERKANNT" gegenstandslos: der Modus endet hier mit Rueckgabewert 2.
  GRUNDLINIE_MODUS=1
  GRUNDLINIE_GESAMT=0
  GRUNDLINIE_BESTANDEN=0
  GRUNDLINIE_GEFALLEN=()
  AKTIV_GATE_MAIN="$GATE_MAIN_AKTIV"
  AKTIV_GATE_PROTOTYP="$GATE_PROTOTYP_AKTIV"
  alle_faelle
  GRUNDLINIE_MODUS=0
  echo "pretooluse-gates-selbsttest: Grundlinie: $GRUNDLINIE_BESTANDEN von $GRUNDLINIE_GESAMT bestanden"
  if [ "$GRUNDLINIE_GESAMT" -eq 0 ] || [ "$GRUNDLINIE_BESTANDEN" -ne "$GRUNDLINIE_GESAMT" ]; then
    echo "pretooluse-gates-selbsttest: Grundlinie nicht gruen (gefallen: ${GRUNDLINIE_GEFALLEN[*]:-}) -- Mutationen laufen nicht." >&2
    arbeitsbaum_unveraendert_pruefen "der Grundlinie" || true
    echo "pretooluse-gates-selbsttest: 0 von $gesamt_mutationen Mutationen erkannt, Rueckgabewert 2."
    return 2
  fi

  local mutationslauf_ok=1
  local erkannt=0
  local i
  for (( i=0; i<gesamt_mutationen; i++ )); do
    local kennung="${MUT_KENNUNG[$i]}" gate="${MUT_GATE[$i]}" such="${MUT_SUCH[$i]}" ersatz="${MUT_ERSATZ[$i]}" beschreibung="${MUT_BESCHREIBUNG[$i]}" erwartet="${MUT_ERWARTET[$i]}"
    local original
    if [ "$gate" = "main" ]; then original="$GATE_MAIN_AKTIV"; else original="$GATE_PROTOTYP_AKTIV"; fi

    # N-8: Eindeutigkeit je VORKOMMEN, nicht nur je Zeile (grep -oF | wc -l).
    local vorkommen
    vorkommen=$(grep -oF -- "$such" "$original" | wc -l | tr -d ' ')
    if [ "$vorkommen" != "1" ]; then
      echo "MUT $kennung gate=$gate beschreibung=\"$beschreibung\" vorkommen=$vorkommen WIRKUNGSLOS_ODER_MEHRDEUTIG"
      mutationslauf_ok=0
      continue
    fi

    local kopie="$T/mutation-$kennung.sh"
    local inhalt neu
    inhalt=$(cat "$original")
    neu=${inhalt/"$such"/"$ersatz"}
    printf '%s\n' "$neu" > "$kopie"
    chmod +x "$kopie"

    AKTIV_GATE_MAIN="$GATE_MAIN_AKTIV"
    AKTIV_GATE_PROTOTYP="$GATE_PROTOTYP_AKTIV"
    if [ "$gate" = "main" ]; then AKTIV_GATE_MAIN="$kopie"; else AKTIV_GATE_PROTOTYP="$kopie"; fi
    AKTIVE_MUTATION_GATE="$gate"
    MUTATION_GEFALLEN=()
    MUTATION_GEPRUEFT=0

    alle_faelle

    AKTIVE_MUTATION_GATE=""

    local fehlend="" e
    for e in $erwartet; do
      local gefunden=0 g
      for g in "${MUTATION_GEFALLEN[@]:-}"; do [ "$g" = "$e" ] && gefunden=1; done
      [ "$gefunden" -eq 1 ] || fehlend="$fehlend $e"
    done

    local gefallen_liste="(keine)"
    [ "${#MUTATION_GEFALLEN[@]}" -gt 0 ] && gefallen_liste="${MUTATION_GEFALLEN[*]}"

    if [ "${#MUTATION_GEFALLEN[@]}" -eq 0 ]; then
      echo "MUT $kennung gate=$gate beschreibung=\"$beschreibung\" geprueft=$MUTATION_GEPRUEFT gefallen=$gefallen_liste erwartet=$erwartet NICHT_ERKANNT"
      mutationslauf_ok=0
    elif [ -n "$fehlend" ]; then
      echo "MUT $kennung gate=$gate beschreibung=\"$beschreibung\" geprueft=$MUTATION_GEPRUEFT gefallen=$gefallen_liste erwartet=$erwartet TEILWEISE_NICHT_ERKANNT fehlend=$fehlend"
      mutationslauf_ok=0
    else
      echo "MUT $kennung gate=$gate beschreibung=\"$beschreibung\" geprueft=$MUTATION_GEPRUEFT gefallen=$gefallen_liste erwartet=$erwartet ERKANNT"
      erkannt=$((erkannt+1))
    fi
  done

  arbeitsbaum_unveraendert_pruefen "des Mutationslaufs" || mutationslauf_ok=0

  local rc=2
  if [ "$erkannt" -eq "$gesamt_mutationen" ] && [ "$mutationslauf_ok" -eq 1 ]; then rc=0; fi
  echo "pretooluse-gates-selbsttest: $erkannt von $gesamt_mutationen Mutationen erkannt, Rueckgabewert $rc."
  return "$rc"
}

# -----------------------------------------------------------------------------
# 21. Hauptprogramm
# -----------------------------------------------------------------------------
if [ "$MODUS" = "mutationen" ]; then
  mutationsmodus_ausfuehren
  ENDCODE=$?
else
  normalmodus_ausfuehren
  ENDCODE=$?
fi
exit "$ENDCODE"
