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
# nicht mehr -- Restbefunde der Nachpruefung vom 2026-09-23, als benannte Grenze GP-2
# entschieden im Nachtrag vom 2026-09-23 zu ADR 0002, 6.13 c),
# weil die Produktionswurzeln generische Namen sind und ein
# Vorspann wie "mock/backend/" im Prototyp ein Fehlalarm waere.
#
# Nachtrag vom 2026-10-22 (Posten 2 unter R3-Q-010, gebaut mit C3; ADR 0002, 6.13 c, Nachtrag vom
# 2026-10-21 zur Abnahme von Posten 4 und 5, Festlegung fuer C3): Die vier Schreibweisen des
# Konstrukts, die bis dahin als fuer beide Richtungen SYMMETRISCHE Luecken offen waren, sind an den
# Dateiwerkzeugen in BEIDEN Richtungen geschlossen: Leerraum vor der Klammer bei require, die Form
# "@import url(", Leerraum um das Gleichheitszeichen bei src UND href (gleicher Musterteil) und
# __import__ mit einem Modulnamen ohne Punkt oder Schraegstrich; import_module ist mitgezogen und hat seit
# Posten 10 (C4, 2026-10-27) je Richtung eigene Faelle (B101 bis B104, Gegenproben P96 bis P99) und
# Mutationen (MP60 bis MP63). Vormals (hier als Beleg stehen gelassen): "ohne eigenen Fall und ohne eigene
# Mutation (Fall und Mutation folgen mit der naechsten Aenderung am Prototyp-Gate, Posten 3)". Die Importwoerter
# stehen einmal in IMPORTWORT, die Attributform einmal in ATTR (beide im Rumpf bei WURZELN); beide
# Richtungen lesen dieselbe Definition, und die Mutationen des Pruefmittels finden je geaenderter
# Stelle genau einen Suchtext. Vormals (Stand bis 2026-10-21, hier als Beleg stehen gelassen):
# "Bekannte, fuer beide Richtungen SYMMETRISCHE Luecken (Leerraum vor "(" bei require, "@import
# url(", Leerraum um "=" bei src/href, "__import__('prototype')" ohne Punkt/Schraegstrich) sind
# unveraendert offen; Entscheid ueber eine Behebung liegt beim Software Architect (Fortschreibung
# nach 6.13 c) und wird als Pruefstand gemessen."
#
# Die Attributform ATTR gilt auch fuer JS-Zuweisungen an src/href (etwa el.src = "../backend/y" in
# einer Prototyp-Datei, x.href = "../prototype/z" im Produktionscode): gewollt, Entscheid des
# Software Architects vom 2026-10-22; eigener Sachverhalt mit B72 und B73 (Soll 2) und den Gegenproben
# P53 und P54 (Soll 0), gemessen mit MP18.
#
# GEWOLLTER DURCHLASS (Posten 2): Der blosse Modulname ohne Punkt, bei dem das Anfuehrungszeichen
# unmittelbar auf den Namen folgt, gilt nur fuer die Python-Formen __import__ und import_module,
# NICHT fuer das dynamische import( der JS-Form: import("backend") in einer Prototyp-Datei bleibt
# frei (Fall P52). GRUND: Ein blosser JS-Modulname ist kein Pfad ueber die Trennung, sondern ein
# Paketname; backend, frontend und deploy sind generische Namen, und ein Paket dieses Namens im
# Prototyp waere ein Fehlalarm. Richtung 1 ist davon nicht betroffen: "prototype" ist ein bestimmter
# Name, und das dynamische import( ist dort schon ueber das Importwort-Muster erfasst (die
# Asymmetrie der Namenslogik, siehe oben). Entschieden vom Software Architect am 2026-10-22: gewollt,
# nicht gesperrt; die statische Form ist ebenso frei (seit Posten 10 mit Fall P100 und Mutation MP64);
# den Weg ueber Aufloesungskonfiguration (Alias,
# baseUrl, Workspace) schloesse eine Sperre nicht, er faellt unter GP-1 (P-10).
#
# Fallklassen im Pruefmittel (scripts/pretooluse-gates-selbsttest.sh): KP-7 fasst die vier
# Schreibweisen in beiden Richtungen als gedeckte Klasse (vormals GP-3 (grenze), seit 2026-10-22
# gedeckt), GP-4 die Grenze an der Schnittstelle (unten), KP-8 die Rueckgabewerte der sed- und
# tr-Schritte, KP-9 die Zeitgrenze des Gates (seit C4 mit dem Nachlauf -k 1, S38). Seit C4 (2026-10-27): KP-10 die jq-Schritte
# (Posten 8), KP-11 und KP-12 die Bezugsformen ohne Anfuehrungszeichen und in Grossschreibung an den Dateiwerkzeugen und am
# Bash-Weg (Posten 9), KP-13 die Bereinigung des Dateipfads und GP-5 die Verknuepfungen (Posten 3), KP-14 den Waisenprozess und
# GP-7 seine Grenze (DT-C4-01), GP-6 die Python-Formen in Richtung 2 (Posten 10); KP-7 umfasst dazu import_module je Richtung und
# die statische JS-Form (P100). GP-6 (Einordnung nach 6.13 d): Die Python-Formen in Richtung 2 kennen bewusst nur die Bauwurzeln
# backend, frontend und deploy, nicht die generischen Namen der Variable WURZELN; eine Python-Form mit einem generischen Namen
# (from lib import helper) in einer Prototyp-Datei bleibt frei (P101), weil ein import app in einem Python-Prototyp ein plausibles
# Fremdmodul waere und der Fehlalarm teurer als die engere Deckung.
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
# Seit Posten 5 (2026-10-21, ADR 0002, 6.13 c, SR-001 des Schwachstellenregisters)
# gilt zusaetzlich: Jede Pruefung eines Textes mit 'grep -q' -- bei Bash die
# Schreibwirkung und das Importmuster, an den Dateiwerkzeugen die Richtung 2 und
# die Richtung 1 -- laeuft ueber die Hilfsfunktion trifft (im Rumpf), nicht mehr
# ueber 'printf | grep -Eq'. Nicht ueber trifft laufen die jq-Schritte (tool, cmd, fp, payload); sie
# pruefen seit Posten 8 (C4, 2026-10-27; SR-005) ihren Rueckgabewert ueber schritt_geprueft wie die sed-
# und tr-Schritte (siehe unten). Vormals (Stand bis 2026-10-26, hier als Beleg stehen gelassen): "jq ist
# vorher auf Vorhandensein geprueft und die Eingabe als auswertbar bestaetigt (ST-13); ein Fehler danach
# ist durch keine ausgefuehrte Probe belegt -- Annahme der Bauform (ADR 0002, 6.13 c, Festlegung fuer
# C3, Posten 6)." Die Probe liegt seit DT-C3-02 vor: Ein MultiEdit mit einer Zeichenkette mit Import
# ueber die Trennung in edits[0].new_string und einem Objekt in edits[1].new_string laesst den
# Ausdruck fuer payload beim Zusammenfuegen abbrechen; payload blieb leer, das Gate endete mit 0.
# Die sed- und tr-Schritte pruefen seit Posten 6 (C3, 2026-10-22;
# vormals belegte Luecke L23, L24: ohne sed oder tr lief ein sonst gesperrter Befehl mit
# Rueckgabewert 0 durch) ihren Rueckgabewert ueber die Hilfsfunktion schritt_geprueft (im Rumpf):
# je Schritt, dessen Ergebnis in die Entscheidung eingeht -- am Bash-Weg cmd_flach (sed fuer die
# Zeilenkommentare, sed in der Schleife ueber die Blockkommentare, tr) und bereinigt (sed), am Weg
# der Dateiwerkzeuge payload_norm (sed, sed in der Schleife, tr) --, endet jeder andere Ausgang als
# 0 ueber pruefung_unmoeglich mit Rueckgabewert 2 und einer Meldung, die das Werkzeug und seinen
# Rueckgabewert nennt (ADR 0002, 6.13 b). Die Auswertung steht in der Hauptshell, nie in einer
# Subshell. Nicht Gegenstand sind die Schritte der Meldung zu ST-13 (wc, tr, cut): sie entscheiden
# nichts. Fehlendes sed oder tr sperrt damit.
# Posten 8 (C4, 2026-10-27; SR-005, DT-C3-02): Dasselbe gilt fuer die vier jq-Schritte, deren Ergebnis
# in die Entscheidung eingeht -- tool (Werkzeugname), cmd (Befehl am Bash-Weg), fp (Dateipfad) und
# payload (Inhalt am Weg der Dateiwerkzeuge): je unmittelbar nach der Zuweisung ueber schritt_geprueft,
# mit dem Rueckgabewert der Pipeline unter pipefail; jeder andere Ausgang als 0 endet ueber
# pruefung_unmoeglich mit Rueckgabewert 2 und einer Meldung, die jq, den Rueckgabewert und die Stelle
# nennt (ADR 0002, 6.13 b). Aus dem Durchlass ist so eine Sperre geworden. Die jq-Ausdruecke selbst sind
# unveraendert: Ein Ausdruck, der andere Typen uebersprange oder umwandelte, waere eine neue Auswertung
# ohne belegte Luecke; die Sperre ist die sichere Richtung. Die Wache fuer jq (Vorhandensein) und die
# Pruefung der Eingabe zu ST-13 bleiben, wie sie sind. PREIS in sicherer Richtung: Eine Werkzeugeingabe,
# an der ein jq-Schritt scheitert, sperrt auch ohne Bezug ueber die Trennung, etwa ein MultiEdit mit einem
# Objekt statt einer Zeichenkette in new_string. Nicht Gegenstand ist das main-Gate (Restpunkt jq am
# main-Gate). Fallklasse KP-10 im Pruefmittel.
#
# Posten 9 (C4, 2026-10-27; SR-006, DT-C3-01 und die Beobachtung am Bash-Weg): Bezugsformen, die das Gate nicht erkannte, weil jedes
# Muster ein Anfuehrungszeichen verlangte und die Attributnamen nur klein geschrieben traf; gemessen am 2026-10-27 vor dem Bau: alle
# folgenden Formen Rueckgabewert 0. (a) An den Dateiwerkzeugen, in beiden Richtungen: der Attributwert ohne Anfuehrungszeichen
# (src=../prototype/x.js, href=..., je Richtung ein eigenes Muster neben dem mit Anfuehrungszeichen; der Wert besteht aus Zeichen
# ausser Anfuehrungszeichen, Leerraum und ">" und endet an Leerraum, ">" oder Zeilenende -- er reicht nicht ueber Leerraum hinweg,
# sonst traefe ein spaeteres Wort derselben Zeile, etwa ein alt-Text mit docs/prototype/), die CSS-Form ohne Anfuehrungszeichen
# (@import url(../prototype/x.css); der Wert besteht aus Zeichen ausser Anfuehrungszeichen, Leerraum und ")" und endet an ")" oder
# Leerraum) und die Grossschreibung von src, href, @import und url (SRC=, Href=, @IMPORT URL(); die uebrigen Importwoerter bleiben,
# wie sie sind. Beide Richtungen lesen dieselben Definitionen ATTR, ATIMPORT und URLKLAMMER (Kriterium
# R3-Q-010_prototyp_gate_richtungsgleichheit). (b) Am Bash-Weg erweitert die Wortgruppe des groben Netzes um ATTR -- das Attribut mit
# Gleichheitszeichen, nicht das blosse Wort src, das mit jedem Kopieren aus einem Verzeichnis src/ eine neue Fehlalarmklasse oeffnete --
# und erkennt @import ohne Ruecksicht auf die Schreibweise; Richtung 1 erfasst das Netz ueber den Bezugspfad, Richtung 2 ueber das Ziel
# der Schreibwirkung (das Wort prototype hinter dem Importwort); ohne Anfuehrungszeichen wirkte das Netz schon vorher, weil es keins
# verlangt. Nicht Gegenstand von (a): JS- und Python-Formen ohne Anfuehrungszeichen oder in Grossschreibung (Anfuehrungszeichen sind dort
# Syntax, Grossschreibung ist dort kein Import); die Grossschreibung im Pfad ("../PROTOTYPE/"), weil nicht belegt ist, dass ein Werkzeug
# der Kette Pfade ohne Ruecksicht auf die Schreibweise aufloest; url( ausserhalb von @import (etwa in background) und JSX-Ausdruecke wie
# src={...}, beide nicht erkannt und nicht gemessen.
# PREIS in sicherer Richtung (neue Fehlalarmklasse, a): Zuweisungen an Namen, die auf src oder href enden, in Gross- oder Mischschreibung
# oder ohne Anfuehrungszeichen, die einen Pfad ueber die Trennung nennen, ohne ein Import zu sein, etwa IMG_SRC=../prototype/x.png in
# einem Shell-Skript oder einer Umgebungsdatei unter deploy/ (klein geschrieben und mit Anfuehrungszeichen sperrt dieselbe Zuweisung
# schon seit 2026-10-22, weil ATTR keine linke Wortgrenze hat); dazu Werte ohne Anfuehrungszeichen in Kommentaren des Codes, wie beim
# bewussten Preis der unbereinigten Fassung. Ausweg wie dort: den Pfad im Kommentar nicht ausschreiben oder den Namen aendern.
# PREIS (b): Ein Befehl mit Schreibwirkung, der src= oder href= als Text traegt und dahinter prototype nennt, sperrt auch ohne Bezug
# ueber die Trennung, etwa eine Notiz mit src= in eine Datei unter prototype/ oder eine Shell-Variable SRC=prototype/screens vor einem
# cp -- derselbe Preis, den das Netz fuer die Importwoerter schon traegt; Ausweg: die Datei mit dem Write-Werkzeug schreiben, wo das Gate
# pfadgenau prueft. Fallklassen im Pruefmittel: KP-11 (a), KP-12 (b).
#
# Posten 3 (C4, 2026-10-27; L09, belegt seit 2026-09-23): Das Gate ordnete den Dateipfad ohne Bereinigung zu. Ein Pfad mit einem Segment
# "." oder ".." oder mit doppeltem Schraegstrich landete im falschen Zweig: {AB}/./prototype/x.js mit einem Import aus dem Produktionscode
# galt als Produktionscode, die Pruefung der Richtung 2 lief nicht (Rueckgabewert 0); dieselbe Ursache fuehrte an der Prosa-Ausnahme vorbei
# (ein Pfad ueber docs/ mit .. zurueck in den Produktionscode wurde nicht geprueft) und wirkte beim doppelten Schraegstrich hinter dem
# Projektverzeichnis. Seit Posten 3 laeuft vor jeder Zuordnung (Projektpraefix, Prosa-Ausnahme, Richtung) die Hilfsfunktion pfad_bereinigen,
# lexikalisch und in der Shell selbst, ohne externes Werkzeug: (1) mehrere Schraegstriche werden zu einem; (2) Segmente "." entfallen;
# (3) ein Segment ".." hebt das vorangehende Segment auf, wenn es eines gibt, das nicht ".." ist; am Anfang eines absoluten Pfads entfaellt es,
# am Anfang eines relativen Pfads bleibt es stehen; (4) ein Schraegstrich am Ende entfaellt. Dieselbe Bereinigung gilt fuer das
# Projektverzeichnis, damit der Vergleich beide Seiten gleich behandelt (CLAUDE_PROJECT_DIR mit Schraegstrich am Ende: am 2026-10-27 vor
# dem Bau gemessen Durchlass, B99). Ein relativer Pfad, der danach mit ".." beginnt, wird wie bisher als Pfad im Projekt zugeordnet und nicht
# als ausserhalb freigegeben (B100, P94). FOLGEN, keine neue Luecke (die Datei liegt dort, wohin der bereinigte Pfad zeigt, vorbehaltlich der
# Grenze): Ein absoluter Pfad mit dem Projektpraefix, der erst ueber ".." aus dem Projekt hinausfuehrt, liegt nach der Bereinigung ausserhalb und
# ist, wie jeder solche Pfad, nicht Gegenstand des Gates (Rueckgabewert 0; vorher wurde er wie Produktionscode geprueft, P91); ein Pfad, der
# ueber ".." in docs/ oder .claude/ endet, faellt unter die Prosa-Ausnahme (vorher geprueft, P90).
# BENANNTE GRENZE (GP-5): keine Aufloesung symbolischer Verknuepfungen und kein Zugriff auf das Dateisystem. Eine Verknuepfung im
# Produktionscode, die auf prototype/ zeigt (oder umgekehrt), und ein Projektverzeichnis, das ueber eine Verknuepfung erreicht wird, werden nach
# dem Pfadtext zugeordnet, nicht nach dem Ziel (P92, Soll 0). GRUENDE: Die Zieldatei muss beim Write nicht bestehen; das Ergebnis haengte sonst
# vom Zustand des Arbeitsbaums ab; ein weiteres Werkzeug waere eine weitere Abhaengigkeit mit eigener Pruefung. Das Anlegen einer Verknuepfung
# mit ln ist am Bash-Weg eine Schreibwirkung ohne Importmuster und bleibt frei. Vormals (Stand bis 2026-10-26, hier als Beleg stehen gelassen):
# L09 war eine belegte Luecke (Soll 0, Fallklasse belegte-luecke, Pruefstand seit 2026-09-23). Fallklassen im Pruefmittel: KP-13 (die
# Bereinigung), GP-5 (die Verknuepfungen).
# GRUND: Unter 'set -uo pipefail' liefert die Pipeline aus printf und 'grep -q'
# den Wert 141 (SIGPIPE), wenn grep nach einem fruehen Treffer endet, waehrend
# printf noch schreibt; die Bedingung galt dann als nicht erfuellt, und der Befehl
# lief durch (B2-GATE-D05, DT-B2-10: ab etwa 64 KiB zufaellig, ab 128 KiB sicher).
# Das Gate hatte dieselbe Bauform wie das main-Gate. Gemessen am 2026-10-21 vor dem Bau: L22
# (Bash), B64 (Richtung 1 ueber Write) und B65 (Richtung 2 ueber Write) gaben bei einer
# Kommentarzeile aus 200000 Zeichen Rueckgabewert 0.
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
# etwa 64 KiB bis 128 KiB faellt aus der Entscheidung. Die Zeitgrenze zieht seit Posten 7 das Gate
# selbst (siehe den folgenden Absatz), nicht mehr allein der Hook.
#
# Posten 7, Teil am Prototyp-Gate (C3, 2026-10-22; ADR 0002, 6.13 c, Nachtrag vom 2026-10-21 zur
# Abnahme von Posten 4 und 5, Festlegung fuer C3; Schwachstellenregister SR-003, dessen Status fuer
# diesen Teil der Vulnerability Manager setzt): EIGENE ZEITGRENZE des Gates von 12 s mit einem
# Nachlauf von 1 s (timeout -k 1 12), zusammen hoechstens 13 s, unter der Grenze des Pruefmittels
# (14 s) und der des Harness (15 s, .claude/settings.json). Der Abstand zur Grenze des Harness ist
# eine ANNAHME DER BAUFORM (.claude/rules/claude-konfiguration.md, Abschnitt "Hooks"; ADR 0002,
# 6.12.12); die Wirkung im laufenden Harness ist nicht gemessen. Vorher war die Ueberschreitung der
# Hook-Grenze ein Durchlass (ein Hook, der sie reisst, wird abgebrochen und laesst durch).
# MECHANIK: Unmittelbar nach dem Entfernen von POSIXLY_CORRECT und nach set -uo pipefail ruft sich das
# Skript selbst unter timeout -k 1 12 auf: mit dem laufenden bash ($BASH, weil die PATH-Varianten des
# Pruefmittels kein bash fuehren), ueber $0 (die Mutationsprobe faehrt eine Kopie des Gates, der
# innere Lauf muss dieselbe Kopie sein) und mit dem festen Argument --innerer-lauf-zeitgrenze. Der
# innere Lauf ist das Gate wie vorher und liest die Standardeingabe; der aeussere Teil liest sie nicht
# und ruft ausser timeout, mktemp und rm (aus dem PATH; kill, wait, read und printf sind Builtins) kein Werkzeug auf (seit DT-C4-01,
# siehe den Absatz unten). Das feste Argument oeffnet keinen Weg an der Grenze
# vorbei: den Aufruf setzt .claude/settings.json, die Werkzeugeingabe kommt allein ueber die
# Standardeingabe. ABBILDUNG: 0 nur, wenn der innere Lauf mit 0 endet; eine 2 bleibt 2; jeder andere
# Ausgang -- Ueberschreitung (124), Abbruch nach dem Nachlauf (137), Fehler von timeout (125 bis
# 127), ein Rueckgabewert 1 des inneren Laufs (etwa ein Abbruch unter set -u) -- endet mit 2 und
# einer Meldung (6.13 b), die die Grenze und den naechsten Schritt nennt. Fehlt timeout, sperrt das
# Gate mit einer Meldung, die timeout nennt, wie bei jq. PREIS in sicherer Richtung: Eine Eingabe,
# deren Pruefung laenger als 12 s braucht, sperrt. Gemessen am 2026-10-21 vor dem Bau (CPU frei,
# ganzes Gate, Bash und Write): Zeile aus '&' 5000000 Zeichen 1,2 s bzw. 1,6 s, 10000000 Zeichen
# 2,6 s bzw. 3,7 s; '#' und 'a' 10000000 Zeichen 2,4 s bis 3,6 s; Leerzeichen und '"' 5000000
# Zeichen 1,2 s bis 2,0 s; bei 93 Laeufen aus 31 Formen aus 150000 gleichen Zeichen hoechstens
# 0,13 s. Nachmessung am 2026-10-22 nach dem Bau (andere Last, Original-Gate daneben): acht Eingaben
# aus je 10000000 Zeichen (Bash: '&', Leerzeichen, '#', 'a'; Write: Kommentarzeile, 'a', Leerzeichen im
# Prototyp, '&') gebautes Gate 2,5 s bis 4,5 s, Original-Gate 2,3 s bis 4,4 s (Messung des SecDevOps
# Engineers); nach der Messung des Dynamic Software Testers 2,86 s bis 5,06 s, Maximum 5,06 s (Write mit 'a',
# einmal; drei Wiederholungen 4,16 s bis 4,79 s); beide Messungen am Gate vor C4. Hoechster belegter Wert nach
# dem Bau von C4 (neue Muster, Bereinigung des Pfads, Ablage des aeusseren Teils; DT-C3-04): 7,18 s (Dynamic
# Software Tester, 2026-10-27, 07:58 bis 08:01 UTC, Last 0,06, Write mit Leerzeichen im Prototyp, am gestagten
# Gate; Maximum von 7,184 s bei drei Laeufen je Eingabe). Seine Gegenmessung unter gleichen Bedingungen: Gate
# vor C4 6,099 s bis 6,758 s, gebautes Gate 6,266 s bis 7,051 s, die Mittelwerte liegen 0,09 s bis 0,12 s
# auseinander; das ist Streuung der Umgebung und keine Folge von C4 (das Gate vor C4 brauchte unter denselben
# Bedingungen bis zu 6,76 s); alle Rueckgabewerte 0, unter der Grenze von 12 s. Eigene Messung daneben
# (SecDevOps Engineer, 2026-10-27, Last 1 Minute zu Beginn 0,00, am Zwischenstand mit der sha256 decf859d...,
# der sich vom Endstand nur in Kommentarzeilen unterscheidet; die acht Formen je dreimal nacheinander,
# Eingaben aus je 10000000 Zeichen selbst erzeugt, Pfad backend/x.py, bei Leerzeichen im Prototyp
# prototype/x.js): gebautes Gate 2,18 s bis 4,43 s (Maximum 4,43 s, Write mit '&'), Gate vor C4 daneben 2,24 s
# bis 4,70 s (Maximum 4,70 s); eine harmlose Eingabe braucht (zehn Laeufe) 0,042 s bis 0,052 s, im
# Ausgangsstand 0,035 s bis 0,041 s. Die Zeiten schwanken mit der Umgebung um etwa das 1,6- bis 1,8-Fache bei
# gleicher Eingabe (2,2 s bis 4,7 s in dieser Messung, 3,79 s bis 7,18 s in der des Dynamic Software Testers);
# massgeblich ist der hoechste
# belegte Wert mit seinem Datum, eine Quote nennt dieser Kommentar nicht. Eine Eingabe ueber 12 s ist fuer
# dieses Gate nicht gefunden (Berichtigung Delta 2, ST-C2-D-05). Das Pruefmittel zieht je Gate-Aufruf
# zusaetzlich eine
# eigene Grenze von 14 s und wertet eine Ueberschreitung als Durchlass; seine Faelle messen die
# Grenze: S25 (cat um 20 s verzoegert, Soll 2; gemessen am 2026-10-22: Rueckgabewert 2 nach 12,0 s),
# S26 (um 4 s, Soll 0; Rueckgabewert 0 nach 4,0 s), S27 (PATH ohne timeout, Soll 2), S28 (timeout
# endet mit 125, Soll 2). Der Nachlauf -k 1 hat seit Posten 10 (C4, 2026-10-27) einen Fall und eine Mutation: S38
# laesst den inneren Lauf TERM ueberstehen (BASH_ENV mit trap "" TERM und eine Attrappe von cat, die TERM ignoriert und
# 20 s schlaeft; ohne Aenderung am Gate), Ende nach 13,0 s mit Rueckgabewert 2 und der Meldung zur Zeitgrenze
# (Rueckgabewert 137); MP65 entfernt -k 1, dann liefe der innere Lauf bis zum Ende der Attrappe, ueber der Grenze des
# Pruefmittels von 14 s. Vormals (hier als Beleg stehen gelassen): "UNGEMESSEN ist der Nachlauf -k 1: Er hat keinen
# Fall und keine Mutation und ist nur durch die Probe vom 2026-10-22 belegt (inneres Skript ignoriert SIGTERM:
# Rueckgabewert 137 nach 13,0 s); eine Mutation, die ihn entfernt, erkennt S25 nicht, weil das verzoegerte cat schon
# auf TERM endet." Die Ausnahme von 6.13 d (ADR 0002, 6.13 c, Nachtrag vom 2026-10-21)
# entfaellt fuer dieses Gate. Das main-Gate hat noch keine eigene Grenze (Posten 7, Teil am
# main-Gate, offen; dort ist eine Eingabe ueber 15 s beschrieben).
# Fehlt grep, blockiert das Gate mit Rueckgabewert 2 und einer Meldung (S11; vorher
# Durchlass).
# Fehlt sed oder tr, blockiert das Gate seit Posten 6 ebenso (L23, L24, S20 bis S24, S29, S30; vorher
# Durchlass).
#
# DT-C4-01 (C4, 2026-10-27; Befund des Dynamic Software Testers, Bezug SR-003 Prototyp-Teil; Festlegung: ADR 0004, Teil B, Nachtrag vom
# 2026-10-27 -- DT-C4-01: Waisenprozess, Festlegung der Behebung): Waisenprozess und Kanaele des Aufrufers. Vormals (Stand bis 2026-10-26,
# hier als Beleg stehen gelassen; DT-C3-05 hatte es als Grenze unter Bedingung eingeordnet) belegte Luecke: Ignorierte ein vom inneren Lauf
# aufgerufenes Werkzeug TERM (Attrappe von cat mit trap "" TERM und sleep 22), endete das Gate nach 12,006 s bis 12,012 s mit Rueckgabewert 2;
# stdout schloss mit dem Gate, stderr erst nach 22,017 s bis 22,022 s, mit dem Ende des Waisenprozesses (fuenf Laeufe mit Aufrufern in Python
# und Node; dieselbe Attrappe ohne das Ignorieren von TERM: beide Kanaele nach 12,007 s). Ursache: Der aeussere Teil rief timeout und den inneren
# Lauf ohne Umleitung auf; der innere Lauf erbte stdin, stdout und stderr des Aufrufers, und das cat, das die Eingabe liest, hielt fd 2; das KILL
# aus -k 1 ging nicht hinaus, weil timeout nur auf sein direktes Kind wartet. Ein Aufrufer, der bis zum Schliessen der Kanaele wartet, haette
# 22 s und damit ueber die Grenze des Harness von 15 s hinaus gewartet; ein Hook, der seine Grenze reisst, wird abgebrochen und laesst durch.
# Ob der Harness auf das Ende des Prozesses oder auf das Schliessen der Kanaele wartet, ist nicht gemessen; das Gate darf darauf nicht bauen
# (ADR 0002, 6.13 b).
# BEHEBUNG, allein am aeusseren Teil: Er legt mit mktemp -d eine Ablage an (fehlt mktemp oder scheitert es: Rueckgabewert 2, Meldung mit mktemp),
# ruft timeout -k 1 12 mit dem inneren Lauf im Hintergrund auf (&) und wartet mit wait auf dessen Prozessnummer. ANNAHME DER BAUFORM: GNU timeout
# macht sich ohne --foreground zum Fuehrer einer eigenen Prozessgruppe; die Prozessnummer von timeout ist damit zugleich die Nummer der
# Gruppe (gemessen mit S35). Die Standardeingabe wird dem Hintergrundlauf ausdruecklich uebergeben (ein Hintergrundaufruf ohne Jobsteuerung liest
# sonst aus /dev/null, und jede Eingabe waere nicht auswertbar); stdout und stderr des inneren Laufs gehen je in eine Datei der Ablage, nicht in
# die Kanaele des Aufrufers. Endet wait mit einem anderen Ausgang als 0, schickt der aeussere Teil kill -KILL an die Prozessgruppe (Builtin; ein
# Fehler, weil die Gruppe schon leer ist, wird nicht ausgewertet). Danach gibt er den Inhalt beider Dateien mit Builtins der Shell (read, printf)
# auf seinen eigenen stdout und stderr weiter, nicht mit cat oder einem anderen Werkzeug aus dem PATH -- die Attrappen des Pruefmittels ersetzen
# gerade solche Werkzeuge --, dann folgt seine eigene Meldung wie bisher; zuletzt entfernt rm die Ablage (scheitert das, aendert es die Entscheidung
# nicht). Die Abbildung der Ausgaenge (0; 2; 124 und 137; jeder andere) bleibt. Damit haelt kein Waisenprozess die Kanaele des Harness: Sie erbt nur
# das aeussere Gate, und sie schliessen mit seinem Ende; die Mitglieder der Gruppe raeumt das KILL ab. PREIS in sicherer Richtung: Der aeussere
# Teil haengt zusaetzlich von mktemp ab; fehlt es, sperrt das Gate.
# BENANNTE GRENZE (GP-7): Ein Werkzeug, das sich mit setsid oder setpgid aus der Gruppe loest, und ein Prozess im Zustand D ueberleben das KILL;
# nach dem Ausgang 0 raeumt das Gate nicht ab, ein im Hintergrund zurueckgelassener Prozess ueberdauert es dann ebenfalls. Solche Prozesse halten
# die Kanaele des Harness nicht, weil die Entkopplung auch ohne das Abraeumen traegt (P95), aber sie ueberdauern das Gate; der Zustand D ist ohne
# Fall. Fallklassen im Pruefmittel: KP-14 (die Behebung), GP-7 (die Grenze).
#
# BENANNTE GRENZE (P-10, ADR 0002, 6.13 c: benannte Grenze, keine neue
# Faehigkeit): 5.6 nennt drei Trennungen: eigenes Verzeichnis, keine
# gemeinsamen Abhaengigkeiten, keine Importe in beide Richtungen. Dieses
# Gate prueft NUR die Importe. Ob Prototyp und Produktionscode dieselben
# Abhaengigkeiten (package.json, pyproject.toml) fuehren und wie diese aufgeloest werden
# (Alias, baseUrl, Workspace), prueft weder dieses Gate noch ein Kettenschritt:
# Abhaengigkeiten und ihre Aufloesung sind GP-1 (P-10). Eine Sperre schloesse den Weg ueber
# Aufloesungskonfiguration nicht (siehe GEWOLLTER DURCHLASS, Posten 2).
#
# BENANNTE GRENZE (GP-4, Schnittstelle zum Harness; ADR 0002, 6.13 c, Nachtrag vom 2026-09-23,
# Fall ZF10d; im Kopfkommentar benannt seit 2026-10-22): Der Bash-Weg haengt an der Gleichheit des
# Werkzeugnamens mit "Bash". Ein anderer Name mit einem Feld command (etwa "bash" in Kleinschreibung)
# nimmt den Weg der Dateiwerkzeuge, findet dort keinen Pfad und endet mit Rueckgabewert 0, auch bei
# einem Befehl, den das Gate unter dem Namen "Bash" sperren wuerde. Die Schreibweise des Namens setzt
# der Harness (Matcher in .claude/settings.json); das Gate kann sie nicht erzwingen. Gemessen mit
# ZF10d (Soll 0, Klasse grenze).
#
# Belegt und geprueft ueber scripts/pretooluse-gates-selbsttest.sh.
#
# AUSNAHME FUER FLUECHTIGE ZIELE (DT-E43-5, seit E4.3, wie im main-Gate):
# Umleitungen nach /dev/null, unter /tmp und in die Verzeichnisse aus TMPDIR,
# RUNNER_TEMP und SCRATCH* werden vor der Schreibwirkungspruefung aus dem
# Befehlstext entfernt, sonst waere reines Suchen mit "2>/dev/null" ein
# Fehlalarm. Ein Ziel mit '..' faellt nicht unter die Ausnahme, '/dev/null'
# nur mit Wortgrenze (DT-E43-6, behoben am 2026-09-23).
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
# Seit Delta 2 (2026-10-21, ADR 0002, 6.13 c; ST-C2-D-01): Die Variable POSIXLY_CORRECT
# wird hier aus der Umgebung des Gates entfernt, vor dem ersten sed. GNU sed liest unter
# ihr [^\n] als "nicht Rueckstrich und nicht n": 's#//[^\n]*##' (Kommentarentfernung in
# cmd_flach und payload_norm) entfernte einen Zeilenkommentar nur bis zum ersten n; der
# Rest des Kommentars ('ntar' in '// Kommentar') blieb zwischen 'from' und dem Pfad stehen,
# und der Import war kein Import mehr (S18, Dateiwerkzeuge). Im groben Netz fuer Bash trennt
# ein '&' oder '|' im Rest Import und Pfad zusaetzlich (S19; Berichtigung Delta 3,
# ST-C2-E-04: nicht das '&' war die Ursache). Mutation MP15. bash startet unter der
# Variable im POSIX-Modus; das Entfernen der Variable beendet ihn.
unset POSIXLY_CORRECT
set -uo pipefail

# Posten 7, Teil am Prototyp-Gate (C3, 2026-10-22; Kopfkommentar, Absatz "Posten 7"): eigene Zeitgrenze.
# Aeusserer Teil: liest die Standardeingabe nicht; Werkzeuge aus dem PATH: timeout, mktemp und rm (seit DT-C4-01, C4,
# 2026-10-27, Kopfkommentar, Absatz "DT-C4-01"); command -v, kill, wait, read und printf sind Builtins. Innerer Lauf:
# das Gate wie bisher, aufgerufen mit dem festen Argument.
if [ "${1:-}" != "--innerer-lauf-zeitgrenze" ]; then
  if ! command -v timeout >/dev/null 2>&1; then
    echo "Gate prototyp-trennung: timeout ist nicht installiert; das Gate kann seine Zeitgrenze nicht ziehen und blockiert (ADR 0002, 6.13 b)." >&2
    echo "Naechster Schritt: timeout (Paket coreutils) installieren und den Befehl wiederholen." >&2
    exit 2
  fi
  if ! command -v mktemp >/dev/null 2>&1; then
    echo "Gate prototyp-trennung: mktemp ist nicht installiert; das Gate kann die Ausgabe seines inneren Laufs nicht ablegen und blockiert (ADR 0002, 6.13 b)." >&2
    echo "Naechster Schritt: mktemp (Paket coreutils) installieren und den Befehl wiederholen." >&2
    exit 2
  fi
  zg_ablage=$(mktemp -d)
  zg_mk=$?
  if [ "$zg_mk" != 0 ] || [ ! -d "$zg_ablage" ]; then
    echo "Gate prototyp-trennung: mktemp -d scheitert (Rueckgabewert $zg_mk); das Gate kann die Ausgabe seines inneren Laufs nicht ablegen und blockiert (ADR 0002, 6.13 b)." >&2
    echo "Naechster Schritt: das temporaere Verzeichnis (TMPDIR) auf Platz und Rechte pruefen und den Befehl wiederholen." >&2
    exit 2
  fi
  # DT-C4-01: der innere Lauf laeuft im Hintergrund, mit der Standardeingabe des Aufrufers (0<&0: sonst /dev/null) und mit stdout und stderr in Dateien der Ablage,
  # nicht in den Kanaelen des Aufrufers; die Prozessnummer von timeout ist zugleich die Nummer seiner Prozessgruppe (Annahme der Bauform, Kopfkommentar).
  timeout -k 1 12 "$BASH" "$0" --innerer-lauf-zeitgrenze 0<&0 >"$zg_ablage/aus" 2>"$zg_ablage/fehler" &
  zg_pid=$!
  wait "$zg_pid"
  zg_status=$?
  [ "$zg_status" = 0 ] || kill -KILL -- "-$zg_pid" 2>/dev/null
  while IFS= read -r zg_zeile || [ -n "$zg_zeile" ]; do printf '%s\n' "$zg_zeile"; done < "$zg_ablage/aus"
  while IFS= read -r zg_zeile || [ -n "$zg_zeile" ]; do printf '%s\n' "$zg_zeile" >&2; done < "$zg_ablage/fehler"
  rm -rf "$zg_ablage" 2>/dev/null
  case "$zg_status" in
    0) exit 0 ;;
    2) exit 2 ;;
    124|137) echo "Gate prototyp-trennung: Zeitgrenze von 12 s (Nachlauf 1 s) ueberschritten (Rueckgabewert $zg_status); das Gate kann nicht fertig pruefen und blockiert (ADR 0002, 6.13 b)." >&2 ;;
    *) echo "Gate prototyp-trennung: Pruefung abgebrochen (Rueckgabewert $zg_status, Zeitgrenze 12 s mit Nachlauf 1 s); das Gate kann nicht pruefen und blockiert (ADR 0002, 6.13 b)." >&2 ;;
  esac
  echo "Naechster Schritt: die Eingabe verkleinern oder den Befehl in kleinere, getrennte Aufrufe zerlegen und wiederholen." >&2
  exit 2
fi

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

# Posten 5 (2026-10-14 erfasst, 2026-10-21 gebaut, ADR 0002, 6.13 c, SR-001):
# trifft TEXT GREP-ARGUMENTE ist die eine Stelle, an der dieses Gate einen Text mit
# 'grep -q' gegen ein Muster prueft (die Muster stehen unveraendert an den
# Aufrufstellen). Andere Pruefungen eines Musters laufen nicht ueber trifft: der
# jq-Ausdruck mit test() zur Auswahl der Felder der Werkzeugeingabe (ST-C2-D-04).
# Rueckgabewert 0: Treffer, 1: kein Treffer; jeder andere Ausgang beendet das Gate
# mit Rueckgabewert 2 und einer Meldung. Grund, Form und Grenze: Kopfkommentar,
# Absatz "Seit Posten 5".
pruefung_unmoeglich() {
  echo "Gate prototyp-trennung: Pruefung nicht moeglich ($1); das Gate kann nicht pruefen und blockiert (ADR 0002, 6.13 b)." >&2
  echo "Naechster Schritt: das genannte Werkzeug (grep, sed, tr oder jq) im PATH pruefen (command -v) und den Befehl wiederholen; bei jq kann auch eine Werkzeugeingabe die Ursache sein, in der ein Feld keine Zeichenkette ist (etwa ein Objekt in new_string): dann jedes Feld als Zeichenkette fassen; bleibt die Meldung, den Befehl in getrennte Aufrufe zerlegen." >&2
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

# Posten 6 (C3, 2026-10-22; ADR 0002, 6.13 c, Festlegung fuer C3): schritt_geprueft <Rueckgabewert>
# <Werkzeug> <Stelle> wertet den Rueckgabewert eines sed-, tr- oder (seit Posten 8, C4, 2026-10-27) jq-Schritts, dessen Ergebnis in die
# Entscheidung eingeht. Aufruf unmittelbar nach der Zuweisung, mit $? als erstem Argument; jeder andere
# Ausgang als 0 beendet das Gate ueber pruefung_unmoeglich mit Rueckgabewert 2. Laeuft in der
# Hauptshell, nie in einer Subshell (dort beendete exit nur die Subshell).
schritt_geprueft() {
  [ "$1" = 0 ] || pruefung_unmoeglich "$2, Rueckgabewert $1, $3"
}

# Posten 3 (C4, 2026-10-27; L09): pfad_bereinigen <Pfad> setzt BEREINIGT auf den lexikalisch bereinigten Pfad; Aufruf vor jeder Zuordnung
# (Projektpraefix, Prosa-Ausnahme, Richtung), fuer den Dateipfad und das Projektverzeichnis. Reine Shell, ohne externes Werkzeug (kein
# realpath, kein readlink, kein sed) und ohne Subshell, damit keine neue Abhaengigkeit und keine neue ungepruefte Stelle entsteht.
# (1) Mehrere Schraegstriche werden zu einem; (2) Segmente "." entfallen; (3) ein Segment ".." hebt das vorangehende Segment auf, wenn
# es eines gibt, das nicht ".." ist; am Anfang eines absoluten Pfads entfaellt es, am Anfang eines relativen Pfads bleibt es stehen;
# (4) ein Schraegstrich am Ende entfaellt. Keine Aufloesung symbolischer Verknuepfungen, kein Zugriff auf das Dateisystem (GP-5).
pfad_bereinigen() {
  local rest="$1" seg abs=0 n
  local -a out=()
  [ "${rest:0:1}" = "/" ] && abs=1
  while [ -n "$rest" ]; do
    case "$rest" in
      */*) seg="${rest%%/*}"; rest="${rest#*/}" ;;
      *) seg="$rest"; rest="" ;;
    esac
    case "$seg" in
      "") : ;;
      ".") : ;;
      "..") n=${#out[@]}; if [ "$n" -gt 0 ] && [ "${out[$((n - 1))]}" != ".." ]; then unset "out[$((n - 1))]"; elif [ "$abs" = 0 ]; then out+=(".."); fi ;;
      *) out+=("$seg") ;;
    esac
  done
  BEREINIGT=""
  for seg in ${out[@]+"${out[@]}"}; do BEREINIGT="${BEREINIGT}${seg}/"; done
  BEREINIGT="${BEREINIGT%/}"
  [ "$abs" = 1 ] && BEREINIGT="/${BEREINIGT}"
  return 0
}

proj="${CLAUDE_PROJECT_DIR:-$PWD}"
pfad_bereinigen "$proj"; proj="$BEREINIGT"

# Posten 9 (C4, 2026-10-27; SR-006): ATTR, ATIMPORT und URLKLAMMER stehen hier, vor dem Bash-Weg, einmal und werden von beiden Wegen
# (grobes Netz am Bash-Weg, Dateiwerkzeuge) und beiden Richtungen gelesen. Zeichenklassen im Muster, nicht grep -i fuer den ganzen
# Aufruf: -i traefe auch den Verzeichnisnamen, die Bauwurzeln und die JS- und Python-Formen. ATTR: src oder href mit optionalem Leerraum
# um das Gleichheitszeichen; ATIMPORT: das Wort @import; URLKLAMMER: url mit optionalem Leerraum vor der Klammer -- je ohne Ruecksicht
# auf die Schreibweise (SRC=, Href=, @IMPORT URL(). Vormals nur in Kleinschreibung, und ATTR stand erst hinter dem Bash-Weg.
ATTR='([sS][rR][cC]|[hH][rR][eE][fF])[[:space:]]*=[[:space:]]*'
ATIMPORT='@[iI][mM][pP][oO][rR][tT]'
URLKLAMMER='[uU][rR][lL][[:space:]]*\('

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
schritt_geprueft $? jq "Werkzeugname"
if [ "$tool" = "Bash" ]; then
  cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty')
  schritt_geprueft $? jq "Befehl am Bash-Weg"
  [ -n "$cmd" ] || exit 0
  # Fuer die Importpruefung den Befehl zu einer Zeile zusammenziehen und
  # Kommentare entfernen -- ein Heredoc mit ueber mehrere Zeilen verteiltem oder
  # durch Kommentar getrenntem Import entginge sonst dem zeilenweisen grep
  # (Befunde der statischen Pruefung vom 2026-08-25).
  cmd_flach=$(printf '%s' "$cmd" | sed 's#//[^\n]*##')
  schritt_geprueft $? sed "Zeilenkommentare am Bash-Weg"
  for _i in 1 2 3 4 5; do
    neu=$(printf '%s' "$cmd_flach" | sed 's#/\*[^*]*\*/##g')
    schritt_geprueft $? sed "Blockkommentare am Bash-Weg"
    [ "$neu" = "$cmd_flach" ] && break
    cmd_flach="$neu"
  done
  cmd_flach=$(printf '%s' "$cmd_flach" | tr '\n\t' '  ')
  schritt_geprueft $? tr "Zeilenumbrueche am Bash-Weg"
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
  # reines Suchen mit "2>/dev/null" ein Fehlalarm. Ein Ziel mit '..' faellt
  # nicht unter die Ausnahme, '/dev/null' nur mit Wortgrenze (DT-E43-6,
  # behoben am 2026-09-23).
  bereinigt=$(printf '%s' "$cmd" | sed -E \
    -e 's/[0-9]?>&[0-9]//g' \
    -e 's/[0-9]?>>?[[:space:]]*\/dev\/null([[:space:]]|$|[;|&)])/\1/g' \
    -e 's/[0-9]?>>?[[:space:]]*(\/tmp\/([^[:space:].;|&)]|\.[^.[:space:];|&)])*|"?\$\{?(TMPDIR|RUNNER_TEMP|SCRATCH[A-Z_]*)\}?([^[:space:].;|&)]|\.[^.[:space:];|&)])*)([[:space:];|&)]|$)/\5/g')
  schritt_geprueft $? sed "Bereinigung der Umleitungsziele am Bash-Weg"
  schreibwirkung='(>>?|\btee[[:space:]]|sed[[:space:]]+-[a-zA-Z]*i|<<)|(\b(mv|cp|rm|mkdir|touch|truncate|ln|install|patch|dd)[[:space:]]|\b(python[0-9.]*|perl|ruby|node|deno|php|Rscript)[[:space:]]+([^|;&]*[[:space:]]+)?-[a-zA-Z]*(c|e|i|p|r|n)([^a-zA-Z]|$)|\b(ed|ex)[[:space:]])'
  if trifft "$bereinigt" -e "$schreibwirkung" \
      && trifft "$cmd_flach" -e "(from|require|import|${ATIMPORT}|__import__|import_module|${ATTR})[^|&]*prototype([./\"'[:space:]]|\$)"; then
    echo "BLOCKIERT (Projektauftrag 5.6): Shell-Befehl mit Schreibwirkung und einem Import, der 'prototype' beruehrt." >&2
    echo "Importe zwischen prototype/ und Produktionscode sind in beide Richtungen untersagt." >&2
    echo "Die Datei mit dem Write-Werkzeug schreiben -- dort prueft das Gate pfadgenau." >&2
    exit 2
  fi
  exit 0
fi

fp=$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_input.notebook_path // .tool_input.path // empty')
schritt_geprueft $? jq "Dateipfad am Weg der Dateiwerkzeuge"
[ -n "$fp" ] || exit 0

# Posten 3 (C4, 2026-10-27; L09): der Pfad wird vor jeder Zuordnung bereinigt (Kopfkommentar, Absatz "Posten 3").
pfad_bereinigen "$fp"; fp="$BEREINIGT"

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
schritt_geprueft $? jq "Dateiinhalt am Weg der Dateiwerkzeuge"
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
schritt_geprueft $? sed "Zeilenkommentare am Weg der Dateiwerkzeuge"
for _i in 1 2 3 4 5; do
  neu=$(printf '%s' "$payload_norm" | sed 's#/\*[^*]*\*/##g')
  schritt_geprueft $? sed "Blockkommentare am Weg der Dateiwerkzeuge"
  [ "$neu" = "$payload_norm" ] && break
  payload_norm="$neu"
done
payload_norm=$(printf '%s' "$payload_norm" | tr '\n\t' '  ')
schritt_geprueft $? tr "Zeilenumbrueche am Weg der Dateiwerkzeuge"
pruefstoff=$(printf '%s\n%s' "$payload" "$payload_norm")

Q="[\"'\`]"
NQ="[^\"'\`]"

# Verzeichnisliste der Richtung 2 (Prototyp importiert aus dem Produktionscode)
# EINMAL definiert und ueber ${WURZELN} in den betroffenen Mustern verwendet --
# sonst kaeme der Suchtext der Mutationsprobe MP3
# (scripts/pretooluse-gates-selbsttest.sh) mehrfach vor und waere nicht mehr
# eindeutig ersetzbar (R3-Q-010, E4.2).
WURZELN='backend|frontend|deploy|src|app|lib|server|packages|apps'
# Posten 2 (C3, 2026-10-22; Kopfkommentar, Nachtrag vom 2026-10-22): Importwort-Gruppe und Attributform
# EINMAL definiert und von beiden Richtungen gelesen (wie WURZELN). IMPORTWORT: from, require mit
# optionalem Leerraum vor der Klammer, import(, @import mit optionalem url( und import. ATTR: src oder
# href mit optionalem Leerraum um das Gleichheitszeichen. Seit Posten 9 (C4, 2026-10-27) steht ATTR oben bei proj (vor dem Bash-Weg);
# @import und url( in IMPORTWORT lesen ATIMPORT und URLKLAMMER (ohne Ruecksicht auf die Schreibweise); UQ und UQK sind die Zeichen
# eines Werts ohne Anfuehrungszeichen: ausser Anfuehrungszeichen und Leerraum nicht ">" (src= und href=) bzw. nicht ")" (url( ).
IMPORTWORT="(from|require[[:space:]]*\(|import\(|${ATIMPORT}([[:space:]]+${URLKLAMMER})?|import)"
UQ="[^\"'\`[:space:]>]"
UQK="[^\"'\`[:space:])]"

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
  if trifft "$pruefstoff" \
      -e "${IMPORTWORT}[[:space:]]*\(?[[:space:]]*${Q}((\.\./)*|\./(\.\./)+)(${WURZELN})/" \
      -e "${IMPORTWORT}[[:space:]]*\(?[[:space:]]*${Q}[@~#]/" \
      -e "${ATTR}${Q}(\./)?(\.\./)+(${WURZELN})/" \
      -e "${ATTR}(\./)?(\.\./)+(${WURZELN})/" \
      -e "${ATIMPORT}[[:space:]]+${URLKLAMMER}[[:space:]]*(\./)?(\.\./)+(${WURZELN})/" \
      -e "^[[:space:]]*(from|import)[[:space:]]+(backend|frontend|deploy)([.[:space:]]|\$)" \
      -e "(import_module|__import__|import)[[:space:]]*\([[:space:]]*${Q}(backend|frontend|deploy)[./]" \
      -e "(import_module|__import__)[[:space:]]*\([[:space:]]*${Q}(backend|frontend|deploy)${Q}" \
      -e "${IMPORTWORT}[[:space:]]*\(?[[:space:]]*${Q}(\./)?(\.\./)+(backend|frontend|deploy)${Q}" \
      -e "${IMPORTWORT}[[:space:]]*\(?[[:space:]]*${Q}(\.\.\\\\)+(backend|frontend|deploy)(\\\\|${Q})"; then
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
if trifft "$pruefstoff" \
    -e "${IMPORTWORT}[[:space:]]*\(?[[:space:]]*${Q}(${NQ}*[/\\\\])?prototype(/|\\\\|${Q})" \
    -e "${ATTR}${Q}(${NQ}*[/\\\\])?prototype(/|\\\\|${Q})" \
    -e "${ATTR}(${UQ}*[/\\\\])?prototype(/|\\\\|[[:space:]>]|\$)" \
    -e "${ATIMPORT}[[:space:]]+${URLKLAMMER}[[:space:]]*(${UQK}*[/\\\\])?prototype(/|\\\\|[[:space:])]|\$)" \
    -e "^[[:space:]]*(from|import)[[:space:]]+prototype([.[:space:]]|\$)" \
    -e "(import_module|__import__|import)[[:space:]]*\([[:space:]]*${Q}prototype[./]" \
    -e "(import_module|__import__)[[:space:]]*\([[:space:]]*${Q}prototype${Q}"; then
  echo "BLOCKIERT (Projektauftrag 5.6): Richtung 1 (Produktionscode -> Prototyp): '$rel' ist Produktionscode und importiert aus 'prototype/'." >&2
  echo "Der Prototyp ist ein Wegwerf-Prototyp; sein Code wird nach der Freigabe nicht weiterverwendet." >&2
  echo "Weiter gehen nur Bildschirmfluss, Komponenteninventar, Design-Tokens, Oberflaechentexte und" >&2
  echo "der synthetische Datenbestand - als Vorlage nachbauen, nicht importieren." >&2
  exit 2
fi
exit 0
