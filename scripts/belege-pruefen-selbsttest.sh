#!/usr/bin/env bash
# =============================================================================
# scripts/belege-pruefen-selbsttest.sh -- Pruefmittel fuer den Belegpruefer
# scripts/belege-pruefen.sh (Kettenschritt D20)
# =============================================================================
#
# Anforderung R3-Q-001 (das DoD-Gate stuetzt sich auf D20); offener Punkt O-15 (Abnahme des
# Belegpruefers). Grundlage: ADR 0002, 6.8, Nachtrag vom 2026-10-28 (Festlegung fuer G0) und
# docs/uebergaben/2026-10-28_d8-freigabe-grundgeruest-g0-belegpruefer.md, Abschnitt G0, Punkte 1
# bis 4, 8 und 11 (Festlegungen des Software Architects waehrend des Baus).
#
# STAND (G0.1 mit M5 bis M5d): Normalmodus (die Fallliste, 311 Faelle) und Modus --mutationen (die Mutationsdatei). Die
# Fallliste steht vor dem Code (Datenblock unten); gegen den Pruefer vor G0 fielen die Faelle, die P-1 bis P-12, die
# Stufe 2 (S-1 bis S-6), die Pruefungen 6 und 7 (Punkt 3) oder den Lage-C-Block nach 1d betreffen. Herkunft der Faelle:
# B-001 bis B-200 aus B1; B-201 bis B-220 aus B2 (Teilklon vor Archivstand, P-11 mit EB-4, Probe von Regel b, Zahlen mit
# mehr als 9 Stellen, Eintragsform von Pruefung 6 mit GB-27, KC-11 erweitert, voller Werkzeugkasten); B-221 bis B-229
# aus B3 (P-12 mit GB-28, Zahlenregeln im Archivstand, Vorrang des Wegs ohne Verknuepfung nach P-5); B-230 und B-231
# aus B4 (Bindestrich ohne Namen, Skill-Verzeichnis als Verknuepfung); B-232 bis B-241 aus B5 (Wert "leer",
# Kommentarzeilen in der Liste skills: und im Block metadata:, Grenzen GB-29 und GB-30, Schlussausgabe nennt die Grenzen);
# B-242 bis B-276 aus M5 (Behebungen nach der Pruefung B9/M2, ST-G0-01 bis ST-G0-24: Verknuepfung auf dem Weg zu Backlog,
# Projektauftrag, Ausnahmeliste und Pruefflaeche, Dateien der Form bezeichner=wert.md, Lesefehler von awk und grep ueber
# Huellen im Werkzeugkasten, Zaun mit Rueckwaertsakzent in der Sprachangabe, Fernquelle mit promisor, git-Variablen und
# alternates mit KC-12, Grenzen GB-31 bis GB-35, Zeile nur aus Leerraum). B-190 steht als letzter Fall der Fallliste (ST-G0-10).
# B-277 bis B-306 aus M5b (Behebung der Befunde der Fremdmutationsrunde M4, Punkt 13: je Mitglied einer Liste ein Fall, je Auszug
# ein zweites Vorkommen, Stoerer in den Bezugsdokumenten, Ausnahmeliste mit # im Grund und ohne Schlussumbruch, Werkzeugkasten mit
# allen Arten, Dateien unter .claude/, Umgebungsvariablen, Git-Verzeichnis ausserhalb von ./.git, GB-36, refs/replace).
# B-307 bis B-309 aus M5c (Behebung der Befunde der Nachpruefung Teil 1: ein Fall je Pfadangabe-Variable des Aufrufers, EB-3,
# ST-G0-25); B-296 misst zusaetzlich eine Ausnahme der Form datei:zeile (BM-142).
# B-310 und B-311 aus M5d (Befund W-14 des Dynamic Software Testers, Punkt 13 (6): ein Fall je Mitglied der Liste der
# Wurzelnamen ohne Schraegstrich in ist_pfadartig, GB-10; B-033 misst nur drei der fuenf Namen).
#
# AUFRUF
#   bash scripts/belege-pruefen-selbsttest.sh [--mutationen] [--pruefer <pfad>]
#   Ohne --pruefer gilt scripts/belege-pruefen.sh DESSELBEN Baums, in dem dieses Pruefmittel liegt
#   (git rev-parse --show-toplevel vom Verzeichnis des Skripts; der Aufrufort spielt keine Rolle).
#   --pruefer nennt einen anderen Pruefer (relativ zum Aufrufort), etwa eine Arbeitskopie ausserhalb
#   des Arbeitsbaums bis zur Einsetzung (B8); im Modus --mutationen der Pruefer, von dem die Mutanten abgeleitet werden.
#
# RUECKGABEWERT
#   0  alle Faelle bestanden und die Deckung ohne Abweichung ("nicht herstellbar" zaehlt weder als
#      bestanden noch als gefallen, wird gemeldet und beruehrt den Rueckgabewert nicht, GP-B1/GP-B2)
#   2  mindestens ein Fall gefallen oder eine Abweichung der Deckung. Im Modus --mutationen: die Grundlinie
#      besteht nicht, oder eine Mutation ist nicht erkannt oder wirkungslos, oder die Mutationsdeckung weicht ab,
#      oder der Arbeitsbaum ist nach dem Lauf veraendert; 0 nur ohne alles davon
#   3  Lage C des Pruefmittels: der Lauf hat nicht stattgefunden. Fehlendes bash, git, grep, sed, awk,
#      mktemp, flock, sha256sum oder cmp (dazu die Standardwerkzeuge, die der Code benutzt); ein sed, das die
#      Option --sandbox nicht versteht oder ignoriert (ST-G0-21); der
#      Archivstand liegt im Arbeitsbaum nicht als Commit vor (mit Beschaffungsweg); die Sperre ist
#      besetzt (flock -n auf /tmp/r3cosint-belege-pruefen-selbsttest.lock, vor jeder Handlung);
#      unbekannter Parameter; im Modus --mutationen eine fehlende, nicht lesbare oder formfehlerhafte
#      Mutationsdatei; ein Defekt des Pruefmittels
#
# WERKZEUGE: bash, git, grep, sed, awk, mktemp, flock, sha256sum, cmp und die Standardwerkzeuge sort,
#   dirname, cp, rm, mkdir, ln, chmod, cat, head, tail, tr, cut, wc, printf, date, env, timeout, readlink. Kein jq,
#   kein Python, kein Netz, kein Docker.
#
# UMGEBUNG JEDES LAUFS (2a Punkt 6): Der Pruefer laeuft unter "env -i" mit LC_ALL=C, TZ=UTC, HOME und
#   XDG_CONFIG_HOME auf einem leeren Verzeichnis, GIT_CONFIG_NOSYSTEM=1, GIT_CONFIG_GLOBAL=/dev/null,
#   GIT_ALLOW_PROTOCOL=file, GIT_CEILING_DIRECTORIES auf dem Wegwerfverzeichnis und fester Identitaet
#   und festem Zeitstempel (GIT_AUTHOR_*, GIT_COMMITTER_*); der Aufruf hat eine Zeitgrenze von 60 s
#   (Ueberschreitung: Fall gefallen, mit Vermerk; ein Fall darf eine eigene Grenze setzen, ZG_FALL, B-206). Die git-Aufrufe im Grundbaum und in den
#   Wegwerfverzeichnissen (gitg) setzen dieselben Variablen, laufen aber nicht unter env -i: die Umgebung des Aufrufers bleibt
#   zusaetzlich erhalten (ST-G0-32); die Aufrufe am Arbeitsbaum des Aufrufers (git -C <Arbeitsbaum>:
#   Archivstand, Status, Schnappschuss) laufen mit der Umgebung des Aufrufers (ST-G0-15).
#   Die status-Aufrufe am Arbeitsbaum des Aufrufers setzen dazu GIT_OPTIONAL_LOCKS=0: der Lauf frischt die Indexdatei des
#   Arbeitsbaums nicht auf (M5d, DT-G0-M6-01; Verhalten des Pruefmittels, dazu gibt es weder Fall noch Mutation).
#
# GRUNDBAUM UND FAELLE (2a Punkt 5): Ein Grundbaum je Lauf unter mktemp -d, nachweislich ausserhalb des
#   Arbeitsbaums (Aufraeumen per trap, auch bei Abbruch): git init, synthetisches Backlog (R3-A-001
#   Ebene 1, R3-B-002 Ebene 3, R3-C-003 Ebene 6), synthetischer Projektauftrag (1.1, 1.2, 5.4),
#   CLAUDE.md, leere Ausnahmeliste, Rollendatei rolle-a mit skills:, Skill skill-a mit
#   metadata.anforderung, docs/ziel.md mit 20 Zeilen. Die Objekte des Archivstands werden aus dem
#   Arbeitsbaum geholt, ohne Netz, auf zwei Wegen: (1) mit der Refspec der Festlegung
#   git fetch <arbeitsbaum> +refs/remotes/origin/archiv/r3coscrum:refs/remotes/origin/archiv/r3coscrum;
#   (2) nur wenn (1) scheitert, etwa weil die Fernreferenz im Arbeitsbaum fehlt, ueber die Pruefsumme
#   des Archivstands; scheitern beide, Lage C mit dem Beschaffungsweg des Archivstands. Die Archivpfade
#   der Faelle waehlt der Lauf aus dem Baum des Archivstands (git ls-tree -r --name-only). Je Fall
#   eine Kopie des Grundbaums (cp -a), die Aenderung, git add -A (ausser der Fall verlangt einen
#   anderen Index), ein Lauf des Pruefers mit der Kopie als Arbeitsverzeichnis.
#
# SOLL-ARTEN (Spalte 3 der Fallliste):
#   fund                Rueckgabewert 2; die Zeilen unter "=== Funde vollstaendig" (Datei:Zeile,
#                       Tabulator, Art, Tabulator, Wert) sind genau die erwartete Menge ganzer Zeilen
#                       (Mehrfachzeilen zaehlen einzeln); "Befunde: n" gleich deren Zahl
#   kein-fund           Rueckgabewert 0, keine Zeile unter "=== Funde vollstaendig", "Befunde: 0"
#   kein-fund+ausgabe   wie kein-fund, dazu Aussagen ueber die Standardausgabe
#   lage-c              Rueckgabewert 3; Fehlerausgabe mit "LAGE C", der Kennung und, wo 1d einen
#                       nennt, dem Beschaffungsweg; Standardausgabe ohne "Befunde:" und ohne "=== Funde"
#   gleich              zwei Laeufe ueber denselben Baum: Standardausgabe, Fehlerausgabe, Rueckgabewert gleich
#   schreibfrei         der Wegwerf-Baum ist nach dem Lauf wie davor, einschliesslich seines Git-Verzeichnisses (Status
#                       einschliesslich ignorierter und unversionierter Dateien; je Datei Pfad und SHA-256, je Verzeichnis
#                       der Pfad, je Verknuepfung das Ziel); der Schnappschuss schreibt selbst nicht (GIT_OPTIONAL_LOCKS=0)
#   statisch            Aussage ueber den Text des geprueften Pruefers, ohne Lauf (EB-2)
#   arbeitsbaum         der Arbeitsbaum ist nach dem ganzen Lauf wie davor (2a Punkt 8); der Fall steht als letzter der Liste
#   zeilenumbruch       GB-32 (Eigenschaft): Rueckgabewert 2; "Befunde: n" gleich der erwarteten Zahl der Funde; die Zeilen
#                       unter "=== Funde vollstaendig" sind genau die erwartete Menge, ihre Zahl ist groesser als n, weil ein
#                       Dateiname einen Zeilenumbruch traegt (ZN_BEFUNDE, ZN_ZEILEN im Fall)
#   Jedes Feld jeder erwarteten Fundzeile ist festgelegt (Punkt 11); es gibt keinen Platzhalter.
#   Wache gegen einen leeren Pruefer: ein Fall der Art gleich oder schreibfrei, dessen Lauf weder auf
#   der Standard- noch auf der Fehlerausgabe etwas schreibt, gilt als gefallen (Gleichheit oder
#   Unveraendertheit allein sagen dann nichts). Ein Lauf ohne Abschnitt "=== Funde vollstaendig"
#   gilt bei den Arten fund und kein-fund immer als gefallen.
#
# FALLLISTE: Der Datenblock unten ("#F|"-Zeilen: Kennung|Klassen|Soll|Herkunft|Gegenstand) ist die
#   maschinenlesbare Liste. Jede Kennung hat genau eine Funktion f_B<nnn> weiter unten und umgekehrt
#   (mechanisch geprueft). Kennungen B-nnn sind dauerhaft und werden nie wiederverwendet. Die
#   erwarteten Fundzeilen stehen in den Fallfunktionen.
#
# DECKUNG (2a Punkt 9, als eigener Abschnitt der Ausgabe nach den Faellen, nicht in der Fallzaehlung):
#   jede Kennung KB, KC, EB und GB im Kopfkommentar des geprueften Pruefers hat Faelle (KB: mindestens
#   einen mit Soll Fund und einen mit Soll kein Fund; KC, EB, GB: mindestens einen); jede Klasse, die
#   ein Fall nennt, steht im Kopfkommentar; jede Gruppe hat mindestens eine Kennung (eine leer gelesene
#   Liste ist eine Abweichung). Gegen einen Pruefer ohne Kennungen im Kopfkommentar ergibt die Deckung
#   erwartungsgemaess Abweichungen.
#
# MODUS --mutationen (2b): Mutationsdatei scripts/belege-pruefen-mutationen.txt im Verzeichnis dieses Skripts
#   Zeilenform: Kennung BM-nnn, Tabulator, Klasse (KB-, KC- oder EB-Kennung), Tabulator, sed-Ausdruck (mit sed -E --sandbox auf eine
#   Wegwerfkopie des Pruefers angewandt), Tabulator, Mindestsatz (Fallkennungen durch Komma), Tabulator, Grund. Zeilen mit
#   # am Anfang und Leerzeilen werden uebergangen. Nur ASCII, genau vier Tabulatoren je Zeile; eine Form, die der Modus nicht
#   liest, ist Lage C (Rueckgabewert 3) und kein stilles Uebergehen.
#   Ablauf: (1) Grundlinie: alle Faelle und die Deckung gegen eine unveraenderte Kopie des Pruefers; besteht sie nicht,
#   endet der Modus mit 2 ohne Mutation. (2) Je Mutation eine Kopie; ist sie byte-gleich mit dem Pruefer (cmp), verwirft
#   bash -n sie oder endet sed mit einem Fehler, ist die Mutation wirkungslos. (3) Erkannt ist sie, wenn jeder Fall ihres
#   Mindestsatzes gegen die Mutante faellt; nur diese Faelle laufen gegen sie ("nicht herstellbar" im Mindestsatz zaehlt als
#   nicht gefallen). (4) Schluss: geprueft, erkannt, nicht erkannt, wirkungslos; dazu die Mutationsdeckung und der Vergleich
#   des Arbeitsbaums vor und nach dem ganzen Lauf.
#   Mutationsdeckung (mechanisch, Abweichung ergibt 2): jede Klasse KB, KC und EB im Kopfkommentar des Pruefers hat
#   mindestens eine Mutation, deren Mindestsatz einen Fall dieser Klasse enthaelt; die Klasse jeder Zeile gehoert zu einem
#   Fall ihres Mindestsatzes; die Grenzen GB tragen keine Pflichtmutation; ein Fall mit Soll arbeitsbaum steht in keinem
#   Mindestsatz (er prueft den Pruefer nicht). Pflege: eine neue Klasse im Kopfkommentar des Pruefers verlangt Faelle und
#   mindestens eine Mutation; eine Aenderung am Pruefer, die einen sed-Ausdruck wirkungslos macht, verlangt die Anpassung der Zeile.
#
# GRENZEN DES PRUEFMITTELS
#   GP-B1  Die Faelle "nicht lesbar" zu KC-06 bis KC-08 (B-140, B-142, B-144) sind als root nicht
#          herstellbar; sie werden dort gezaehlt und gemeldet, ohne Mutation.
#   GP-B2  Der Fall zu P-10 (B-189) braucht die UTF-8-Spracheinstellung C.UTF-8; fehlt sie, zaehlt er
#          "nicht herstellbar", und die Mutation, die LC_ALL=C entfernt, gilt nicht als erkannt:
#          Kriterium (a) ist nur in einer Umgebung mit dieser Einstellung erfuellbar.
#   GP-B3  EB-2 prueft den Text des Pruefers mit einem benannten Muster (absoluter Pfad ab zwei
#          Teilen oder bekannter Wurzelname am Wortanfang; Kommentarzeilen und /dev/null ausgenommen);
#          ein zur Laufzeit zusammengesetzter Pfad bleibt dort unerkannt.
#   GP-B4  Der Fall zu EB-1 (B-190) verlangt einen ruhigen Arbeitsbaum; aendert eine andere Rolle waehrend
#          des Laufs eine Datei, faellt der Fall, gewollt in sicherer Richtung.
#   GP-B5  Faelle mit Soll Fund oder kein Fund messen die Fehlerausgabe nicht, nur Faelle der Soll-Arten
#          lage-c und gleich (Vergleich zweier Laeufe); eine abweichende Fehlerausgabe bleibt dort ungemessen.
#   GP-B6  Die Verknuepfungen im Grundbaum (KB-12, P-5) setzen ein Dateisystem mit symbolischen
#          Verknuepfungen voraus.
#   GP-B1 umfasst ausserdem den Fall zu KC-11 (versionierte Markdown-Datei nicht lesbar, B-218).
#   GP-B7  Die statische Pruefung der Umgebungsvariablen (EB-2, B-301) liest den Text des Pruefers mit einem benannten Muster
#          (gelesen: $name, ${name...}, ${!name...}; gesetzt oder geloescht: Zuweisung, local, declare, typeset, readonly,
#          export, for, read, mapfile, unset). Sie erkennt kein Lesen ueber Indirektion (${!name}, eval, env, printenv, ENVIRON
#          in awk) und nicht, was aufgerufene Werkzeuge selbst lesen. Fuer git gehoeren dazu die Konfiguration aus
#          GIT_CONFIG_PARAMETERS, GIT_CONFIG_COUNT mit GIT_CONFIG_KEY_n und GIT_CONFIG_VALUE_n, GIT_CONFIG_GLOBAL und
#          GIT_CONFIG_SYSTEM sowie die Dateien unter HOME und XDG_CONFIG_HOME: sie stehen nicht in der Liste aus OF-15 und sind
#          ungemessen, weil das Pruefmittel sie fuer jeden Lauf abschaltet (2a, Punkt 6).
#   GP-B8  Listen und Mengen sind an den Mitgliedern und Namen der Faelle gemessen; waechst eine Ausschlussliste (Regel a, GB-04,
#          GB-06, GB-07) um einen Namen oder ein Zeichen, das kein Fall nennt, faellt kein Fall. Ein Schrumpfen der Liste des
#          eigenen Baums faengt Nr. 1 (B-277 bis B-283, B-039).
#   GP-B9  Der Pruefer loescht GIT_CEILING_DIRECTORIES (EB-3), die das Pruefmittel fuer seine Laeufe auf das Wegwerfverzeichnis
#          setzt. Der Fall B-135 (kein Git-Arbeitsbaum am Arbeitsverzeichnis) setzt darum voraus, dass oberhalb des
#          mktemp-Verzeichnisses kein Git-Repository liegt (TMPDIR nicht in einem Repository); liegt dort eines, findet git
#          es, der Pruefer meldet kein KC-02, und B-135 faellt: sichere Richtung, kein falsches Gruen (ST-G0-34). B-149
#          (grep fehlt und kein Git-Arbeitsbaum) besteht dann weiter, weil die Meldung des fehlenden Werkzeugs vor dem
#          ersten git-Aufruf greift, misst aber nur noch einen seiner zwei Gegenstaende (die Reihenfolge dieser Meldung vor
#          KC-02 nicht mehr): B-149 verliert still einen Gegenstand.
#   GP-B10 GIT_ICASE_PATHSPECS steht in der Loeschliste des Pruefers (ST-G0-25), hat aber ohne sie keine beobachtbare
#          Wirkung: git ls-files -z -- '*.md' lieferte dann auch .MD-Namen, die der Pruefer danach gegen PRUEFFLAECHE_ERE
#          (Kleinschreibung) verwirft. Es gibt dazu weder Fall noch Mutation; das Entfernen des Namens bleibt unbemerkt.
# FESTLEGUNG gegen das Muster "je Regel ein Vertreter" (M5b, Punkt 13): Eine Regel, die eine Liste oder Menge fuehrt, hat einen
#   Fall je Mitglied; eine Regel, die Vorkommen sucht, hat einen Fall mit einem zweiten Vorkommen hinter einem gueltigen; misst
#   ein bestehender Fall ein Mitglied schon, genuegt er. Was sich so nicht messen laesst, ist Grenze des Pruefmittels (GP-B7, GP-B8, GP-B10).
# RESTLUECKEN nach M5c (nicht gemessen): ein Tabulator im Dateinamen (GB-32 nennt nur den Zeilenumbruch; Restpunkt der
#   Uebergabe, ST-G0-26); Zeilenabdeckung des Pruefers (kein Werkzeug dafuer in der Liste WERKZEUGE_PM, eine
#   Beschaffung braeuchte Netz); Werkzeugaufrufe in Zweigen, die kein Fall unter dem Werkzeugkasten durchlaeuft (Lage-C- und
#   Fehlerzweige), prueft allein der Static Software Tester am Code (P-2); ein Submodul als dritte Form eines Git-Verzeichnisses
#   ausserhalb von ./.git (B-302 deckt das getrennte Git-Verzeichnis, B-303 den verknuepften Arbeitsbaum); keine zweite blinde
#   Fremdmutationsrunde: ob die Faelle aus M5 und M5b ihrerseits nur je einen Vertreter messen, misst niemand blind.
#
# REIHENFOLGE-ERKENNTNIS (Teilklon, fuer B2 und B3): In einem Teilklon (extensions.partialClone) loest
#   jedes git cat-file auf ein FEHLENDES Objekt einen Nachlade-Abruf bei der Fernquelle aus und
#   schreibt "fatal: ... does not appear to be a git repository" auf die Fehlerausgabe. Der Pruefer
#   muss den Teilklon (KC-04) deshalb vor dem Archivstand (KC-05) und vor jeder Pruefsummenpruefung
#   erkennen. Gemessen am 2026-10-28.
#
# KC-01: Der Werkzeugkasten (KC01_KASTEN) enthaelt die geschlossene Werkzeugliste des Pruefers (git, grep, awk, sort,
#   dirname: die Befehle, die der Pruefer aufruft, P-2). B-207 laeuft mit dem vollen Kasten und verlangt den Grundfall:
#   ruft der Pruefer auf dem Weg des Grundfalls ein weiteres Werkzeug auf, scheitert dieser Fall. Die uebrigen Zweige des
#   Pruefers sichert dieser Fall nicht; sie prueft der Static Software Tester am Code (P-2).
# HUELLEN (ST-G0-03, B-249 bis B-257): Ein Fall kann im Werkzeugkasten awk oder grep durch eine Huelle ersetzen, die das
#   echte Werkzeug aufruft, aber mit 2 endet, wenn die Eingabe oder eine Datei unter den Operanden die Marke
#   PM-HUELLE-LESEFEHLER traegt und die Operanden die Nadel des Falls nennen. So laesst sich ein Lesefehler herstellen, den
#   ein echtes Werkzeug unter root nicht zeigt (GP-B1 gilt dort nicht).
# =============================================================================
#
# FALLLISTE (Datenblock, maschinenlesbar): #F|Kennung|Klassen|Soll|Herkunft|Gegenstand
# "Herkunft" nennt die Stelle der Festlegung, die der Fall misst; "(Gegenprobe)" sichert die Gegenseite.
#F|B-001|KB-24|kein-fund|Kopfkommentar|Grundfall: Grundbaum unveraendert
#F|B-002|KB-01|fund|Kopfkommentar|Zeilenverweis hinter dem Dateiende (docs/ziel.md hat 20 Zeilen)
#F|B-003|KB-01|fund|Kopfkommentar|Zeilenverweis um eins hinter dem Dateiende
#F|B-004|KB-01|fund|P-6|Zeilenverweis auf Zeile 0
#F|B-005|KB-01|kein-fund|Kopfkommentar|Zeilenverweis auf die letzte Zeile (20) und auf Zeile 1
#F|B-006|KB-01|kein-fund|Kopfkommentar|Zeilenverweis auf die letzte Zeile einer Datei ohne Schlussumbruch
#F|B-215|KB-01|fund|P-6 (Ergaenzung)|Zeilenverweis mit N von mehr als 9 Stellen (20 Stellen und 10 Stellen): Fund, kein Ueberlauf des Vergleichs
#F|B-216|KB-01,KB-02|kein-fund|P-6 (Gegenprobe)|Zahlen mit fuehrenden Nullen, dem Wert nach innerhalb der Datei (0000000000000000000020 und 000000000000000000001-0000000000000000000020)
#F|B-007|KB-02|fund|Kopfkommentar|Bereich mit M um eins hinter dem Ende
#F|B-008|KB-02|fund|P-6|Bereich mit N groesser M und N hinter dem Ende
#F|B-009|KB-02|fund|P-6|Bereich mit N groesser M, beide innerhalb der Datei
#F|B-010|KB-02|fund|P-6|Bereich mit N gleich 0
#F|B-011|KB-02|kein-fund|Kopfkommentar|Bereiche mit N hoechstens M hoechstens Zeilenzahl (2-5, 1-20, 7-7)
#F|B-219|KB-02|fund|P-6 (Ergaenzung)|Bereich mit M von 20 Stellen und Bereich mit N von 20 Stellen und M gleich 1: Fund, kein Ueberlauf des Vergleichs
#F|B-012|KB-03|fund|P-6|Zeilenanhang an einem Verzeichnis des eigenen Baums
#F|B-013|KB-03|fund|P-6 S-4|Zeilenanhang um eins hinter dem Ende eines Blobs im Archivstand (methodik/..., Zeilenzahl gemessen)
#F|B-014|KB-03|kein-fund|Stufe 2 (Gegenprobe)|Zeilenanhang auf Zeile 1 und auf die letzte Zeile eines Blobs im Archivstand
#F|B-015|KB-03|fund|P-6 S-4|Zeilenanhang an einem Verzeichnis des Archivstands (nachweise/.:2; ein blosser Name ohne Schraegstrich ist nicht pfadartig, GB-10)
#F|B-016|KB-03|fund|P-6|Praefix r3cosint/ mit Zeile hinter dem Ende (CLAUDE.md hat eine Zeile)
#F|B-017|KB-03|kein-fund|Kopfkommentar|Praefix r3cosint/ mit Zeile 1
#F|B-018|KB-03|fund|P-6 S-4|Praefix r3coscrum/ mit Zeile um eins hinter dem Ende (CLAUDE.md im Archivstand, Zeilenzahl gemessen)
#F|B-019|KB-03|kein-fund|Stufe 2 (Gegenprobe)|Praefix r3coscrum/ mit Zeile 1
#F|B-226|KB-03|fund|P-6 S-4|Zahlenregeln von P-6 im Archivstand: Zeile 0, N groesser M, N mit 20 Stellen und M hinter dem Ende, je an einer Archivdatei
#F|B-227|KB-03|fund|P-6 S-4|Praefix r3coscrum/ an einem Verzeichnis des Archivstands (r3coscrum/.github:2)
#F|B-020|KB-04|fund|Kopfkommentar|40 Hexzeichen ohne Objekt
#F|B-021|KB-04|fund|Kopfkommentar|Pruefsumme eines Baums statt eines Commits
#F|B-022|KB-04|kein-fund|Kopfkommentar|Commit des Grundbaums
#F|B-023|KB-04|kein-fund|Stufe 2 (Gegenprobe)|Commit des Archivstands
#F|B-024|KB-04|kein-fund|Stufe 2 (Gegenprobe)|Commit aus dem Verlauf des Archivstands (sein erster Elternteil)
#F|B-025|KB-04|kein-fund|Kopfkommentar|Folgen von 41 und von 64 Hexzeichen, deren erste 40 kein Objekt bezeichnen
#F|B-026|KB-05|fund|Kopfkommentar|blob/main in einer Adresse
#F|B-027|KB-05|fund|Kopfkommentar|tree/main in einer Adresse
#F|B-028|KB-05|kein-fund|Kopfkommentar|blob/ mit Commit-Pruefsumme des Grundbaums
#F|B-029|KB-06|fund|Kopfkommentar|Kennung ohne Ueberschrift im Backlog
#F|B-030|KB-06|fund|Kopfkommentar|Kennung, die im Backlog nur ohne Leerzeichen hinter dem Rautezeichen steht (die Zeile im Backlog und der Verweis)
#F|B-031|KB-06|kein-fund|Kopfkommentar|Kennungen mit Ueberschrift der Ebenen 1, 3 und 6
#F|B-032|KB-07|fund|Kopfkommentar|fehlende Dateien unter .claude/, .github/, docs/ und scripts/ (Zeilen 1 bis 4)
#F|B-033|KB-07|fund|Kopfkommentar|fehlende Wurzelnamen README.md, CONTRIBUTING.md, .gitignore (Zeilen 1 bis 3)
#F|B-034|KB-07|kein-fund|Kopfkommentar|vorhandene Datei, Verzeichnis mit und ohne Schraegstrich, Praefix ./, Wurzelnamen Makefile und CLAUDE.md
#F|B-035|KB-08|fund|Kopfkommentar|in .claude/skills/skill-a/SKILL.md: references/fehlt.md weder an der Wurzel noch neben der Datei
#F|B-036|KB-08|fund|Kopfkommentar|../fehlt.md aus docs/adr/0001-test.md
#F|B-037|KB-08|kein-fund|Kopfkommentar|references/x.md nur neben der nennenden SKILL.md vorhanden
#F|B-038|KB-08|kein-fund|Kopfkommentar|../ziel.md aus docs/adr/0001-test.md (innerhalb der Wurzel)
#F|B-039|KB-09|fund|Kopfkommentar|claude/fehlt.md (mit Endung), docs/fehlt (zwei Segmente im eigenen Baum), .claude/fehlt.md (Punkt an erster Stelle), x/fehlt.md (zweites Segment mit Punkt), builds/x/fehlt.md (kein Erzeugnissegment)
#F|B-040|KB-09|kein-fund|Kopfkommentar|dieselben fuenf Formen mit vorhandenem Ziel (claude/x.md, docs/adr, .claude/agents/rolle-a.md, x/y.md, builds/x/y.md)
#F|B-224|KB-09|fund|P-12|Regel a am bereinigten Pfad: dist/../docs/fehlt.md hat nach der Bereinigung kein Erzeugnissegment mehr
#F|B-041|KB-10|fund|Regel b|backend/ besteht (leer), Verweis backend/fehlt.py
#F|B-042|KB-10|fund|Regel b|backend/, frontend/, deploy/ und prototype/ bestehen (leer), je ein fehlender Pfad darunter
#F|B-043|KB-10|kein-fund|Regel b|keines der vier Verzeichnisse besteht, dieselben vier Verweise
#F|B-221|KB-10|kein-fund|P-12|Regel b bei fehlenden Baeumen: ./backend/fehlt.py, docs/../backend/fehlt.py, ./frontend/fehlt.ts, docs/../deploy/fehlt.yml, ./prototype/fehlt.js (das erste Segment gilt nach der Bereinigung)
#F|B-222|KB-10|fund|P-12|dieselben fuenf Schreibweisen bei bestehenden (leeren) Verzeichnissen backend/, frontend/, deploy/ und prototype/: Fund, Wert wie geschrieben
#F|B-044|KB-11|fund|Regel c d|methodik/fehlt.md, nachweise/fehlt/, sprints/fehlt.md, r3coscrum/fehlt.md, r3cosint/fehlt.md
#F|B-045|KB-11|kein-fund|Stufe 2 (Gegenprobe)|vorhandene Pfade im Archivstand (eine Datei unter methodik/, die Verzeichnisse nachweise/. und sprints/., r3coscrum/CLAUDE.md) und r3cosint/CLAUDE.md
#F|B-046|KB-11|fund|Regel d|Praefix gilt fuer den genannten Baum: r3coscrum/docs/ziel.md (nur im eigenen Baum) und r3cosint/<Archivdatei> (nur im Archivstand)
#F|B-225|KB-11|kein-fund|P-12 (Gegenprobe)|Regeln c und d am bereinigten Pfad: ./<Archivdatei>, docs/../<Archivdatei>, ./r3coscrum/<Wurzeldatei> und ./r3cosint/CLAUDE.md loesen in den genannten Baeumen auf
#F|B-047|KB-12|fund|P-5|../ausserhalb.md aus einer Datei der Wurzel, Ziel ausserhalb des Klons vorhanden
#F|B-048|KB-12|fund|P-5|docs/../../ausserhalb.md, Ziel ausserhalb des Klons vorhanden
#F|B-049|KB-12|fund|P-5|Verweis ueber ein Verzeichnis, das eine Verknuepfung ist (docs/lnk auf adr)
#F|B-050|KB-12|fund|P-5|Verweis auf eine Verknuepfung als Datei (docs/ziel-link.txt auf ziel.md)
#F|B-051|KB-12|fund|P-5|versionierte Markdown-Verknuepfung in der Pruefflaeche; ihr Ziel traegt einen falschen Verweis, der nicht gelesen wird
#F|B-052|KB-12|kein-fund|Kopfkommentar|docs/../CLAUDE.md und ./docs//ziel.md (bereinigt innerhalb der Wurzel)
#F|B-208|KB-12|fund|P-5|Probe von Regel b: backend ist eine Verknuepfung (auf docs), Verweis backend/fehlt.py
#F|B-220|KB-12|fund|P-5 (KC-11, Gegenprobe)|versionierte Markdown-Verknuepfung ohne Ziel (haengend): kein Lage C der Pruefflaeche, sondern Befund pfad-verknuepfung
#F|B-228|KB-12|kein-fund|P-5 (Vorrang)|Kandidat besteht wurzel- und verzeichnisrelativ, genau ein Weg ist eine Verknuepfung: der Weg ohne Verknuepfung geht vor (Makefile: die Wurzel ist die Verknuepfung, docs/Makefile eine Datei)
#F|B-229|KB-12|kein-fund|P-5 (Vorrang)|Umgekehrt: die Wurzel (Makefile) ist eine Datei, docs/Makefile eine Verknuepfung; der Weg ohne Verknuepfung geht vor
#F|B-201|KB-12|fund|P-12|Pfad mit methodik/ als erstem geschriebenem Segment, der nach der Bereinigung die Wurzel verlaesst (methodik/../../ausserhalb.md): Regel c greift nicht, der Pfad gilt als nicht vorhanden und wird an der Wurzel beurteilt (P-5)
#F|B-202|KB-12|kein-fund|P-12 (Gegenprobe)|Pfad mit methodik/ als erstem geschriebenem Segment, der nach der Bereinigung in der Wurzel bleibt (methodik/../CLAUDE.md): Regel c greift nicht, der Pfad wird an der Wurzel beurteilt und besteht
#F|B-053|KB-13|fund|Kopfkommentar|Projektauftrag 9.9, (9.8) und Abschnitt 9.7 ohne Ueberschrift, ohne ADR im Absatz, in drei Absaetzen (Zeilen 1, 3, 5)
#F|B-054|KB-13|kein-fund|Kopfkommentar|dieselben drei Formen mit vorhandener Nummer (1.1, 1.2, 5.4)
#F|B-055|KB-13|kein-fund|Kopfkommentar|Klammerform und Abschnittsform einer fehlenden Nummer mit dem Wort ADR im Absatz
#F|B-056|KB-13|fund|Kopfkommentar|die Form Projektauftrag N.M wird auch mit dem Wort ADR im Absatz geprueft
#F|B-205|KB-13|fund|P-11|Klammerform in einem Absatz, dessen vorheriger Absatz das Wort ADR traegt (Absatzgrenze gehalten)
#F|B-057|KB-14|fund|Punkt 3|Name im Feld skills: ohne Verzeichnis unter .claude/skills/
#F|B-058|KB-14|fund|Punkt 3|Verzeichnis unter .claude/skills/ ohne SKILL.md
#F|B-059|KB-14|kein-fund|Punkt 3 (Gegenprobe)|Rolle ohne skills: und Rolle ohne Frontmatter
#F|B-060|KB-14|kein-fund|Punkt 3 (Gegenprobe)|dieselbe Skill in zwei Rollen
#F|B-061|KB-14|kein-fund|Punkt 3 (Gegenprobe)|nur .claude/agents/<name>.md ist Quelle, eine Datei in tieferer Ebene wird nicht gelesen
#F|B-231|KB-14|fund|Punkt 3 (P-5)|Eintrag nennt ein Skill-Verzeichnis, das eine Verknuepfung ist (.claude/skills/skill-l auf skill-a): pfad-verknuepfung mit dem Pfad der SKILL.md
#F|B-233|KB-14|fund|Punkt 3 (Kommentarzeile)|Kommentarzeilen in der Liste (ohne und mit Einzug) beenden sie nicht: der Name ohne Verzeichnis dahinter ist ein Fund
#F|B-234|KB-14|kein-fund|Punkt 3 (Gegenprobe)|Kommentarzeilen (ohne und mit Einzug) in der Liste, gueltige Namen dahinter: kein Fund
#F|B-062|KB-15|fund|Punkt 3|Flussliste in eckigen Klammern
#F|B-063|KB-15|fund|Punkt 3|Skalar hinter skills:
#F|B-064|KB-15|fund|Punkt 3|leere Liste (skills: ohne Eintrag)
#F|B-065|KB-15|fund|Punkt 3|Namen ausserhalb des Musters: Skill_A und ../skill-a
#F|B-066|KB-15|fund|Punkt 3|skills: zweimal (zweites Vorkommen in Zeile 6)
#F|B-192|KB-15|fund|Punkt 3|ungleiche Anfuehrungszeichen vorn und hinten gelten nicht als paarig (OF-13)
#F|B-194|KB-15|fund|Punkt 3|skills: zweimal, beide Listen mit ungueltigem Namen: das Feld wird nicht weiter ausgewertet (OF-12)
#F|B-067|KB-15|kein-fund|Punkt 3 (Gegenprobe)|Blockliste mit Einzug, Name in Anfuehrungszeichen, Leerraum am Ende, Leerzeile in der Liste (OF-13)
#F|B-191|KB-15|kein-fund|Punkt 3 (Gegenprobe)|Name in einfachen geraden Anfuehrungszeichen (OF-13)
#F|B-068|KB-15|kein-fund|Punkt 3 (Gegenprobe)|die Liste endet an der ersten anderen Zeile
#F|B-069|KB-15|kein-fund|Punkt 3 (Gegenprobe)|eine eingerueckte Zeile skills: ist kein Schluessel
#F|B-209|KB-15|fund|Punkt 3 (F4)|Bindestrich ohne folgenden Leerraum (-skill-a)
#F|B-210|KB-15|fund|Punkt 3 (F4)|Tabulator im Einzug (YAML erlaubt ihn nicht)
#F|B-211|KB-15|kein-fund|Punkt 3 (F4, Gegenprobe)|Eintrag ohne Einzug und Eintrag mit Tabulator hinter dem Bindestrich gelten
#F|B-212|KB-15,GB-27|fund|Punkt 3 (GB-27)|Fehlalarm: Kommentar hinter dem Namen macht den Eintrag zur Formabweichung
#F|B-230|KB-15|fund|Punkt 3 (F4)|Bindestrich ohne Namen (Eintrag "-" allein): Formabweichung mit Wert "leer"
#F|B-070|KB-16|fund|Punkt 3|SKILL.md ohne Frontmatter
#F|B-071|KB-16|fund|Punkt 3|Frontmatter ohne metadata:
#F|B-072|KB-16|fund|Punkt 3|metadata: ohne anforderung:
#F|B-073|KB-16|fund|Punkt 3|Wert mit zwei Kennungen
#F|B-074|KB-16|fund|Punkt 3|Wert ohne Kennung
#F|B-075|KB-16|fund|Punkt 3|anforderung: zweimal (zweites Vorkommen in Zeile 6)
#F|B-076|KB-16|fund|Punkt 3|metadata: zweimal (zweites Vorkommen in Zeile 6, leerer zweiter Block)
#F|B-195|KB-16|fund|Punkt 3|anforderung: zweimal, beide Werte ungueltig: das Feld wird nicht weiter ausgewertet (OF-12)
#F|B-196|KB-16|fund|Punkt 3|metadata: zweimal, erster Block mit ungueltigem Wert: das Feld wird nicht weiter ausgewertet (OF-12)
#F|B-077|KB-16|fund|Punkt 3|Kennung ohne Ueberschrift im Backlog: Pruefung 3 und Pruefung 7 melden beide (GB-25)
#F|B-078|KB-16|kein-fund|Punkt 3 (Gegenprobe)|genau eine Kennung mit Ueberschrift: in Anfuehrungszeichen, mit Leerraum am Ende, Ebene 6
#F|B-193|KB-16|kein-fund|Punkt 3 (Gegenprobe)|Kennung in einfachen geraden Anfuehrungszeichen (OF-13)
#F|B-079|KB-16|kein-fund|Punkt 3 (Gegenprobe)|SKILL.md in anderer Verzeichnisebene ist keine Quelle
#F|B-213|KB-16,GB-27|fund|Punkt 3 (GB-27)|Fehlalarm: Kommentar hinter der Kennung macht anforderung zur Formabweichung
#F|B-232|KB-16|fund|Punkt 3 (Wert leer)|leere anforderung (anforderung: "" und anforderung: mit Leerraum): skill-anforderung mit Wert "leer", unterscheidbar von "fehlt"
#F|B-235|KB-16|fund|Punkt 3 (Kommentarzeile)|Kommentarzeile ohne Einzug im Block metadata: beendet ihn nicht: die ungueltige anforderung dahinter ist ein Fund
#F|B-236|KB-16|kein-fund|Punkt 3 (Gegenprobe)|Kommentarzeilen (ohne und mit Einzug) im Block metadata:, gueltige Kennung dahinter: kein Fund
#F|B-080|KB-17|fund|Punkt 3|Rollendatei: Zeile 1 aus drei Bindestrichen ohne schliessende Zeile; der offene Block nennt einen ungueltigen Skill-Namen, Pruefung 6 wertet nicht weiter aus (OF-11)
#F|B-081|KB-17|fund|Punkt 3|SKILL.md: Zeile 1 aus drei Bindestrichen ohne schliessende Zeile (gueltige Kennung im offenen Block, OF-11)
#F|B-082|KB-17|fund|Punkt 3|eine Zeile aus vier Bindestrichen schliesst das Frontmatter nicht
#F|B-197|KB-17|fund|Punkt 3|SKILL.md ohne schliessende Zeile: die Pruefungen 1 bis 5 lesen den Text weiter, Pruefung 7 wertet nicht aus (OF-11)
#F|B-083|KB-17|kein-fund|Punkt 3 (Gegenprobe)|geschlossenes Frontmatter mit Wagenruecklauf am Zeilenende (Rollendatei und SKILL.md)
#F|B-084|KB-18|fund|Kopfkommentar|falscher Verweis nach einem geschlossenen Zaun aus drei Rueckwaertsakzenten (Zeile 5)
#F|B-085|KB-18|fund|P-4|falscher Verweis nach einem Schlusszaun mit drei Leerzeichen Einzug (Zeile 5)
#F|B-086|KB-18|fund|P-4|falscher Verweis nach einem Block aus drei Tilden, in dem eine Zeile aus drei Rueckwaertsakzenten steht (Zeile 5)
#F|B-087|KB-18|fund|P-4|bis zum Dateiende offener Zaun (oeffnender Zaun in Zeile 2)
#F|B-088|KB-18|kein-fund|Kopfkommentar|falscher Verweis in einem Block aus drei Rueckwaertsakzenten
#F|B-089|KB-18|kein-fund|P-4|falscher Verweis in einem Block aus drei Tilden
#F|B-090|KB-18|kein-fund|P-4|falscher Verweis in einem Block mit drei Leerzeichen Einzug am Zaun
#F|B-091|KB-18|kein-fund|P-4|falscher Verweis in einem Block aus vier Rueckwaertsakzenten, der eine Zeile aus drei Rueckwaertsakzenten enthaelt
#F|B-092|KB-18|kein-fund|P-4 (Gegenprobe)|eine Zeile aus drei Tilden schliesst einen Block aus Rueckwaertsakzenten nicht
#F|B-093|KB-18|kein-fund|P-4|eine Zeile aus drei Rueckwaertsakzenten mit Text dahinter schliesst nicht
#F|B-094|KB-18|fund|Kopfkommentar|ein Schlusszaun aus fuenf Rueckwaertsakzenten schliesst einen Block aus dreien (Verweis danach sichtbar, Zeile 5)
#F|B-095|KB-18|kein-fund|Kopfkommentar|oeffnender Zaun mit Sprachangabe
#F|B-096|KB-19|fund|Kopfkommentar|falscher Verweis in einer versionierten Markdown-Datei der Wurzel
#F|B-097|KB-19|fund|Kopfkommentar|falscher Verweis in tiefen Unterverzeichnissen von docs/ und .claude/
#F|B-098|KB-19|fund|P-3|falscher Verweis in einer versionierten Datei mit Nicht-ASCII-Namen
#F|B-099|KB-19|fund|P-3|leere Pruefflaeche (keine versionierte Markdown-Datei; die Bezugsdokumente liegen unversioniert vor)
#F|B-198|KB-19|fund|P-3|leere Pruefflaeche laesst sich durch keine Ausnahme decken: die Ausnahme -:0 bleibt veraltet (OF-1)
#F|B-100|KB-19|kein-fund|Kopfkommentar|dieselbe Datei mit falschem Verweis, unversioniert
#F|B-101|KB-19|kein-fund|Kopfkommentar|Markdown-Dateien mit falschem Verweis unter scripts/, prototype/, backend/ und .github/
#F|B-102|KB-20|kein-fund|6.8.5|Schluessel Datei:Zeile deckt den Fund an dieser Zeile
#F|B-103|KB-20,KB-21|kein-fund|6.8.5|Schluessel Datei, senkrechter Strich, Wert mit geschriebenem Grund deckt den Fund in dieser Datei
#F|B-104|KB-20|fund|6.8.5|derselbe Wert in einer anderen Datei bleibt ein Fund
#F|B-105|KB-20|fund|P-8|Datei:Zeile an einer anderen Zeile: der Fund bleibt, die Ausnahme ist veraltet
#F|B-106|KB-20|fund|P-8|Datei, senkrechter Strich, anderer Wert: der Fund bleibt, die Ausnahme ist veraltet
#F|B-107|KB-21|fund|6.8.5|Zeile ohne Tabulator
#F|B-108|KB-21|fund|6.8.5|Tabulator ohne Grund
#F|B-109|KB-21|fund|P-7|Grund aus Leerzeichen allein
#F|B-110|KB-21|fund|6.8.5|Kommentar- und Leerzeilen werden uebergangen und mitgezaehlt: Eintrag ohne Grund in Zeile 4
#F|B-111|KB-21|fund|P-8|Eintrag ohne Grund, dessen Wert inzwischen besteht: je Eintrag hoechstens ein Befund (Grund vor Veraltung)
#F|B-112|KB-22|fund|6.8.5|blosser Wert ohne Datei (der Wert besteht nicht)
#F|B-113|KB-22|fund|P-8|blosser Wert, der besteht: je Eintrag hoechstens ein Befund (Form vor Veraltung)
#F|B-114|KB-22|fund|6.8.5|Schluessel Datei:abc
#F|B-115|KB-22|fund|P-8|Datei:Zeile mit sechsstelliger Nummer ist formgerecht und deckt keinen Fund: allein ausnahme-veraltet
#F|B-200|KB-22|kein-fund|6.8.5|Schluessel Datei:Zeile mit sechsstelliger Nummer (123456) deckt einen Fund an dieser Zeile: weder ausnahme-form noch ausnahme-veraltet
#F|B-116|KB-23|fund|P-8|Kennung ist inzwischen Ueberschrift
#F|B-117|KB-23|fund|P-8|Pruefsumme ist inzwischen ein Commit
#F|B-118|KB-23|fund|P-8|Pfad ist an der Wurzel entstanden
#F|B-119|KB-23|fund|P-8|Pfad ist neben der nennenden Datei entstanden
#F|B-120|KB-23|fund|P-8 S-5|Pfad ist im Archivstand entstanden
#F|B-121|KB-23|fund|P-8|die Datei der Ausnahme besteht nicht
#F|B-122|KB-23|fund|P-8|die Datei der Ausnahme besteht, liegt aber ausserhalb der Pruefflaeche
#F|B-123|KB-23|fund|P-8|Datei:Zeile an einer Zeile ohne Fund
#F|B-199|KB-23|fund|P-8|eine Ausnahme kann keinen Befund der Ausnahmeliste decken: der Eintrag auf die eigene Zeile der Liste bleibt veraltet (OF-8)
#F|B-124|KB-23|kein-fund|P-8 (Gegenprobe)|zwei Schluessel fuer denselben Fund, beide werden benutzt
#F|B-125|KB-24|fund|Kopfkommentar|fuenf Funde in vier Arten: Rueckgabewert 2, "Befunde: n" gleich der Zahl der Zeilen, Summe der Arten gleich n
#F|B-126|KB-24|kein-fund+ausgabe|S-6|Schlussausgabe nennt den Archivstand (Zeile "Repo B (r3coscrum): aufgeloest ueber den Archivstand <Stand> (Zweig archiv/r3coscrum)")
#F|B-127|KB-24|kein-fund+ausgabe|S-6|weder Abschnitt noch Zeile "Nicht pruefbar"
#F|B-128|KB-24|kein-fund+ausgabe|S-1|keine Zeile "Repo B (r3coscrum) mitgelesen"
#F|B-129|KB-24|kein-fund+ausgabe|Punkt 3|keine Zeile "NICHT eingebaut" (Pruefungen 6 und 7 sind gebaut)
#F|B-241|KB-24|kein-fund+ausgabe|Punkt 8|Schlussausgabe nennt jede Grenze GB des Kopfkommentars einzeln, und nur diese, und verweist auf den Kopfkommentar
#F|B-130|KC-01|lage-c|P-2|Werkzeug git fehlt im PATH
#F|B-131|KC-01|lage-c|P-2|Werkzeug grep fehlt im PATH
#F|B-132|KC-01|lage-c|P-2|Werkzeug awk fehlt im PATH
#F|B-133|KC-01|lage-c|P-2|Werkzeug sort fehlt im PATH
#F|B-134|KC-01|lage-c|P-2|Werkzeug dirname fehlt im PATH
#F|B-135|KC-02|lage-c|P-1|kein Git-Arbeitsbaum am Arbeitsverzeichnis
#F|B-136|KC-03|lage-c|P-9|flacher Klon (.git/shallow)
#F|B-137|KC-04|lage-c|P-9|Teilklon (extensions.partialClone)
#F|B-138|KC-05|lage-c|S-3|Grundbaum ohne die Objekte des Archivstands
#F|B-139|KC-06|lage-c|1d|Backlog fehlt
#F|B-140|KC-06|lage-c|1d GP-B1|Backlog nicht lesbar (als root nicht herstellbar)
#F|B-141|KC-07|lage-c|1d|Projektauftrag fehlt
#F|B-142|KC-07|lage-c|1d GP-B1|Projektauftrag nicht lesbar (als root nicht herstellbar)
#F|B-143|KC-08|lage-c|1d|Ausnahmeliste fehlt
#F|B-144|KC-08|lage-c|1d GP-B1|Ausnahmeliste nicht lesbar (als root nicht herstellbar)
#F|B-145|KC-08|kein-fund|1d (Gegenprobe)|Ausnahmeliste besteht und enthaelt nur Kommentarzeilen: kein Lage C
#F|B-146|KC-09|lage-c|1d|Backlog ohne Kennung als Ueberschrift
#F|B-147|KC-10|lage-c|1d|Projektauftrag ohne Abschnittsnummer als Ueberschrift
#F|B-148|KC-11|lage-c|P-3|beschaedigte Indexdatei, git ls-files endet ungleich 0
#F|B-149|KC-01,KC-02|lage-c|P-2|zwei Maengel: grep fehlt und kein Git-Arbeitsbaum; gemeldet wird der erste der Reihenfolge
#F|B-150|KC-03,KC-04|lage-c|P-9|zwei Maengel: flacher Klon und Teilklon; gemeldet wird der erste
#F|B-151|KC-05,KC-06|lage-c|S-3|zwei Maengel: Archivstand und Backlog fehlen; gemeldet wird der erste
#F|B-203|KC-04,KC-05|lage-c|P-9|zwei Maengel: Teilklon ohne die Objekte des Archivstands; der Teilklon wird zuerst gemeldet, ohne Nachlade-Abruf (kein "fatal" auf der Fehlerausgabe)
#F|B-204|KC-03,KC-05|lage-c|P-9|zwei Maengel: flacher Klon ohne die Objekte des Archivstands; gemeldet wird der flache Klon
#F|B-207|KC-01|kein-fund|P-2 (Gegenprobe)|Lauf mit PATH nur aus den fuenf Werkzeugen der geschlossenen Liste: Grundfall ohne Fund (nichts anderes wird aufgerufen)
#F|B-214|KC-04|lage-c|P-9|Teilklon allein an extensions.partialclone erkannt (Formatversion 0, fail-closed)
#F|B-217|KC-11|lage-c|P-3 (KC-11 erweitert)|versionierte Markdown-Datei fehlt im Arbeitsbaum und ist keine Verknuepfung (rm ohne git rm)
#F|B-218|KC-11|lage-c|P-3 GP-B1|versionierte Markdown-Datei nicht lesbar (als root nicht herstellbar)
#F|B-152|GB-01|kein-fund|Kopfkommentar|Durchlass: Verweis ausserhalb von Rueckwaertsakzenten
#F|B-153|GB-02|kein-fund|Kopfkommentar|Durchlass: Verweis ueber zwei Zeilen
#F|B-154|GB-03|kein-fund|Kopfkommentar|Durchlass: Kandidat mit Leerzeichen (Pfadteil eines Shell-Befehls)
#F|B-155|GB-04|kein-fund|Kopfkommentar|Durchlass: Anfuehrungszeichen " und ' im Kandidaten
#F|B-156|GB-04|kein-fund|Kopfkommentar|Durchlass: die Zeichen $ = * < > { } im Kandidaten
#F|B-157|GB-04|kein-fund|Kopfkommentar|Durchlass: drei Punkte, das Auslassungszeichen und das Zeichen @ im Kandidaten
#F|B-158|GB-04|kein-fund|Kopfkommentar|Durchlass: :// im Kandidaten, fuehrendes / und ~, Anfang blob/ und tree/
#F|B-159|GB-05|fund|Kopfkommentar|Fehlalarm: Platzhalter ohne Ausschlusszeichen (docs/adr/NNNN-titel.md)
#F|B-160|GB-06|kein-fund|Kopfkommentar|Durchlass: Zweignamen claude/a/b, origin/main, fix/a-b
#F|B-161|GB-06|fund|Kopfkommentar|Fehlalarm: release/a/b (drei Segmente) wird nicht als Zweigname erkannt
#F|B-162|GB-07|kein-fund|Kopfkommentar|Durchlass: erstes Segment valITino
#F|B-163|GB-08|kein-fund|Kopfkommentar|Durchlass: Punkt im ersten Segment ausser an erster Stelle, auch bei einem Verzeichnis, das besteht
#F|B-164|GB-09|kein-fund|Kopfkommentar|Durchlass: Inhaber/Repository (tests/architektur)
#F|B-165|GB-10|kein-fund|Kopfkommentar|Durchlass: Name ohne Schraegstrich ausser den fuenf Wurzelnamen (fehlt.md)
#F|B-166|GB-11|kein-fund|Kopfkommentar|Durchlass: Erzeugnis- und Abhaengigkeitsverzeichnis als Segment (sieben Namen)
#F|B-167|GB-12|kein-fund|Kopfkommentar|Durchlass: Tabelle ohne Leerzeile gilt als ein Absatz, das Wort ADR in einer anderen Zeile derselben Tabelle
#F|B-168|GB-13|kein-fund|Kopfkommentar|Durchlass: eigene Ueberschrift der nennenden Datei mit der Nummer
#F|B-169|GB-14|kein-fund|neu benannt|Durchlass: Abschnittsform eines fehlenden Unterabschnitts einer vorhandenen Nummer (Abschnitt 5.4.9)
#F|B-170|GB-14|kein-fund|neu benannt|Durchlass: Klammerform eines Unterabschnitts einer fehlenden Nummer ((9.9.1))
#F|B-171|GB-15|kein-fund|Kopfkommentar|Durchlass: Schluessel Datei, senkrechter Strich, Wert deckt ein zweites falsches Vorkommen in derselben Datei
#F|B-172|GB-16|kein-fund|neu benannt|Durchlass: Kurzform mit 12 Hexzeichen und 40 Hexzeichen in Grossschreibung
#F|B-173|GB-17|kein-fund|neu benannt|Durchlass: master hinter blob/ und tree/
#F|B-174|GB-18|kein-fund|neu benannt|Durchlass: Commit eines geloeschten Zweigs, dessen Objekt lokal vorliegt
#F|B-175|GB-19|kein-fund|neu benannt|Durchlass: vierstellige Form einer vorhandenen Kennung
#F|B-176|GB-20|kein-fund|6.8.4 O-18|Durchlass: Kennung, deren Ueberschrift den Zusatz (gestrichen) traegt
#F|B-177|GB-21|kein-fund|neu benannt|Durchlass: Kennung, die nur in einem Codeblock des Backlogs als Ueberschrift steht
#F|B-178|GB-22|kein-fund|neu benannt|Durchlass: Verweisziel im Arbeitsbaum, unversioniert
#F|B-179|GB-23|fund|Stufe 2|Fehlalarm: Pfad, der nur in einem spaeteren Stand des Zweigs besteht (Commit auf dem Archivstand im Grundbaum)
#F|B-180|GB-24|fund|P-4|Fehlalarm: Zaun hinter einem Zitatzeichen, Inhalt wird geprueft
#F|B-181|GB-24|fund|P-4|Fehlalarm: Zaun mit vier Leerzeichen Einzug, Inhalt wird geprueft
#F|B-182|GB-25|kein-fund|Punkt 3|Eigenschaft: eine Ausnahme fuer die Kennung in der Datei deckt anforderung und skill-anforderung
#F|B-183|GB-26|kein-fund|Punkt 3|Durchlass: derselbe Name zweimal in einer Liste ist kein eigener Fund
#F|B-223|GB-28|fund|P-12 (GB-28)|Fehlalarm: ../backend/fehlt.py und ../deploy/fehlt.yml aus einer Datei unter docs/ fuehren erst verzeichnisrelativ in einen fehlenden Baum und werden geprueft (Regel b greift nicht)
#F|B-237|GB-29|kein-fund|Punkt 3 (GB-29)|Durchlass: BOM vor dem Frontmatter einer Rollendatei: sie gilt als ohne Frontmatter, der ungueltige Eintrag bleibt ohne Befund
#F|B-238|GB-29|fund|Punkt 3 (GB-29)|Fehlalarm: BOM vor dem Frontmatter einer SKILL.md: skill-anforderung "fehlt" an Zeile 1
#F|B-239|GB-30|kein-fund|Punkt 3 (GB-30)|Durchlass: Zeilenenden nur aus Wagenruecklauf in einer Rollendatei: eine Zeile, kein Frontmatter, ungueltiger Eintrag ohne Befund
#F|B-240|GB-30|fund|Punkt 3 (GB-30)|Fehlalarm: Zeilenenden nur aus Wagenruecklauf in einer SKILL.md: skill-anforderung "fehlt" an Zeile 1
#F|B-184|EB-1|schreibfrei|Kopfkommentar|Lauf mit Funden veraendert den Baum nicht (einschliesslich seines Git-Verzeichnisses, M5b Nr. 12)
#F|B-185|EB-1|schreibfrei|Kopfkommentar|Lauf mit Lage C veraendert den Baum nicht (einschliesslich seines Git-Verzeichnisses, M5b Nr. 12)
#F|B-186|EB-2|statisch|S-1|der gepruefte Pruefer enthaelt ausserhalb von Kommentarzeilen keinen absoluten Pfad ausser /dev/null
#F|B-187|EB-2|statisch|Kopfkommentar|Gegenprobe der Prueffunktion: sie erkennt absolute Pfade in einem Probetext und uebergeht Kommentarzeilen und /dev/null
#F|B-188|EB-3|gleich|Kopfkommentar|zwei Laeufe ueber denselben Baum: Standardausgabe, Fehlerausgabe und Rueckgabewert gleich
#F|B-189|EB-3|gleich|P-10|zwei Laeufe ueber denselben Baum mit anderer Spracheinstellung des Aufrufers (C und C.UTF-8): gleich
#F|B-206|EB-4|fund|P-11|eine Datei aus 120000 Zeilen ohne Leerzeile (ein Absatz) mit einer Klammerform in der letzten Zeile haelt die Zeitgrenze des Falls (10 s) und liefert den Fund
#F|B-242|KC-06|lage-c|ST-G0-01 a|Backlog ist eine Verknuepfung auf eine Datei ausserhalb (Ziel mit Ueberschrift R3-Z-999); Kennung docs/05_Product_Backlog.md, Weg "durch die Datei selbst ersetzen"
#F|B-243|KC-06|lage-c|ST-G0-01 a|das Verzeichnis docs/ auf dem Weg zum Backlog ist eine Verknuepfung (kein_add nach git add)
#F|B-244|KC-07|lage-c|ST-G0-01 a|Projektauftrag ist eine Verknuepfung auf eine Datei ausserhalb (Ziel mit Ueberschrift 9.9; Verweis Projektauftrag 9.9)
#F|B-245|KC-08|lage-c|ST-G0-01 b|Ausnahmeliste ist eine Verknuepfung auf eine Datei ausserhalb, deren Eintrag einen Fund deckt
#F|B-246|KC-08|lage-c|ST-G0-01 b|das Verzeichnis scripts/ auf dem Weg zur Ausnahmeliste ist eine Verknuepfung
#F|B-247|KB-12|fund|ST-G0-01 c|versionierte docs/sub/x.md (Verzeichnis jetzt Verknuepfung auf ausserhalb, Ziel hat x.md mit falschem Verweis) und docs/sub2/y.md (Verknuepfung haengend), ohne erneutes git add: docs/sub/x.md:0 und docs/sub2/y.md:0 pfad-verknuepfung
#F|B-248|KB-19|fund|ST-G0-02, ST-G0-29|Wurzeldateien a=b.md (ohne ./ eine Zuweisung an awk) und -x.md (Gegenprobe der Dateiform: awk liest den Namen hinter dem Programmtext als Datei, nicht als Option) mit falschem Verweis in Zeile 1 und offenem Zaun in Zeile 2
#F|B-249|KC-11|lage-c|ST-G0-03|Huelle um awk (Nadel modus=text), markierte Datei: Lesefehler beim Ausblenden
#F|B-250|KC-11|lage-c|ST-G0-03|Huelle um awk (Nadel modus=offen): Lesefehler beim offenen Zaun
#F|B-251|KC-11|lage-c|ST-G0-03|Huelle um awk (Nadel modus=rolle), markierte Rollendatei
#F|B-252|KC-11|lage-c|ST-G0-03|Huelle um grep, Auszug Pruefung 4
#F|B-253|KC-11|lage-c|ST-G0-03|Huelle um grep, Auszug Pruefung 3
#F|B-254|KC-11|lage-c|ST-G0-03|Huelle um grep, Auszug Pruefung 2 (Commit)
#F|B-255|KC-11|lage-c|ST-G0-03|Huelle um grep, Auszug Pruefung 2 (blob/tree)
#F|B-256|KC-11|lage-c|ST-G0-03|Huelle um grep, Auszug Pruefung 5
#F|B-257|KC-11|fund|ST-G0-03 (Gegenprobe)|Huellen um awk und grep ohne markierte Eingabe sind durchlaessig: falscher Verweis wird gefunden
#F|B-258|KB-18|fund|ST-G0-05|Zeile ```a`b ist kein Zaun: Verweis in Zeile 3 sichtbar; danach Block mit Sprachangabe
#F|B-259|KB-18|kein-fund|ST-G0-05 (Gegenprobe)|~~~a~b bleibt ein Zaun (Tilden unveraendert)
#F|B-260|KC-04|lage-c|ST-G0-07|Fernquelle mit promisor wahr, lokale Ebene, Name mit Punkt (remote.fremd.quelle)
#F|B-261|KC-04|lage-c|ST-G0-07|Fernquelle mit promisor wahr in der globalen Ebene (GIT_CONFIG_GLOBAL)
#F|B-262|KC-04|kein-fund|ST-G0-07 (Gegenprobe)|Fernquelle mit promisor falsch
#F|B-263|EB-3|gleich|ST-G0-08|Lauf ohne Variablen gegen Lauf mit GIT_ALTERNATE_OBJECT_DIRECTORIES auf fremden Objektspeicher mit dem genannten Commit; Commit bleibt ein Fund (AUSGABE_MIT am ersten Lauf)
#F|B-264|EB-3|gleich|ST-G0-08|Lauf ohne Variablen gegen Lauf mit GIT_DIR auf ein anderes Repository
#F|B-265|KC-12|lage-c|ST-G0-08|objects/info/alternates mit Pfad eines fremden Objektspeichers; Kennung git-alternates, Weg git repack -a -d
#F|B-266|KC-12|lage-c|ST-G0-08|dasselbe bei einem .git als Datei (gitdir:-Verweis)
#F|B-267|KC-12|kein-fund|ST-G0-08 (Gegenprobe)|objects/info/alternates vorhanden und leer
#F|B-268|KC-04,KC-12|lage-c|ST-G0-08 (Reihenfolge)|Teilklon und alternates: gemeldet wird git-teilklon
#F|B-269|KC-12,KC-05|lage-c|ST-G0-08 (Reihenfolge)|alternates und Grundbaum ohne Archivobjekte: gemeldet wird git-alternates
#F|B-270|GB-31|kein-fund|ST-G0-06|Durchlass: Ueberschrift 9.9 nur im Codeblock des Projektauftrags, Verweis Projektauftrag 9.9
#F|B-271|GB-31|kein-fund|ST-G0-06|Durchlass: eigene Ueberschrift 8.8 nur im Codeblock der nennenden Datei, Klammerform (8.8) im Text
#F|B-272|GB-32|zeilenumbruch|ST-G0-12|Datei docs/a<NL>b.md mit falschem Verweis: rc 2, Befunde: 1, zwei Zeilen unter Funde vollstaendig (neue Soll-Art)
#F|B-273|GB-33|statisch|ST-G0-19|ausserhalb von Kommentarzeilen kein timeout im Pruefer (mit Probe der Pruefung)
#F|B-274|GB-34|kein-fund|ST-G0-23|Durchlass: docs/gross.MD, docs/gemischt.Md, docs/lang.markdown mit falschem Verweis
#F|B-275|GB-35|fund|ST-G0-24|Fehlalarm: r3cosint/backend/, r3cosint/frontend/, r3cosint/deploy/ und r3cosint/prototype/ bei fehlenden Baeumen
#F|B-276|KB-22|fund|ST-G0-20|Ausnahmeliste mit Zeile nur aus Leerraum (3 Leerzeichen) und Zeile nur aus Tabulator: je ausnahme-form
#F|B-277|KB-09|fund|M4 Nr. 1 (DT-G0-M4-01)|Liste des eigenen Baums (GB-09): .claude/fehlt, zwei Segmente, fehlendes Ziel, zweites Segment ohne Punkt
#F|B-278|KB-09|fund|M4 Nr. 1 (DT-G0-M4-01)|Liste des eigenen Baums (GB-09): .github/fehlt
#F|B-279|KB-09|fund|M4 Nr. 1 (DT-G0-M4-01)|Liste des eigenen Baums (GB-09): scripts/fehlt (Minimalbeispiel des Dynamic Software Testers)
#F|B-280|KB-09|fund|M4 Nr. 1 (DT-G0-M4-01)|Liste des eigenen Baums (GB-09): prototype/fehlt bei bestehendem leerem Verzeichnis prototype/
#F|B-281|KB-09|fund|M4 Nr. 1 (DT-G0-M4-01)|Liste des eigenen Baums (GB-09): backend/fehlt bei bestehendem leerem Verzeichnis backend/
#F|B-282|KB-09|fund|M4 Nr. 1 (DT-G0-M4-01)|Liste des eigenen Baums (GB-09): frontend/fehlt bei bestehendem leerem Verzeichnis frontend/
#F|B-283|KB-09|fund|M4 Nr. 1 (DT-G0-M4-01)|Liste des eigenen Baums (GB-09): deploy/fehlt bei bestehendem leerem Verzeichnis deploy/
#F|B-284|KB-04|fund|M4 Nr. 2 (DT-G0-M4-02)|Pruefung 2: Commit des Grundbaums, dahinter eine Pruefsumme ohne Objekt in derselben Zeile und eine in der folgenden Zeile
#F|B-285|KB-06|fund|M4 Nr. 2 (DT-G0-M4-02)|Pruefung 3: Kennung mit Ueberschrift, dahinter eine ohne in derselben Zeile und eine in der folgenden Zeile
#F|B-286|KB-07,KB-01|fund|M4 Nr. 2 (DT-G0-M4-02)|Pruefungen 1 und 4: vorhandenes, dahinter fehlendes Ziel, mit und ohne Zeilenanhang, in derselben und in der folgenden Zeile
#F|B-287|KB-13|fund|M4 Nr. 2 (DT-G0-M4-02)|Pruefung 5: vorhandene, dahinter fehlende Nummer in den drei Formen, in derselben und in der folgenden Zeile
#F|B-288|KB-05|fund|M4 Nr. 2 (DT-G0-M4-02)|Zweigform: blob/ mit Commit-Pruefsumme, dahinter blob/main in derselben Zeile, tree/main in der folgenden Zeile
#F|B-289|KB-13|fund|M4 Nr. 3 (DT-G0-M4-03)|Referenzmenge des Projektauftrags: Nummer im Fliesstext und Zeile aus Rautezeichen und Nummer ohne Leerzeichen sind keine Abschnitte, beide in den drei Formen genannt
#F|B-290|KB-09|fund|M4 Nr. 4 (DT-G0-M4-04)|Regel a: fehlende Ziele mit docs/src, docs/builds und den im Bestand ueblichen Pfadzeichen (Grossbuchstabe, Ziffer, Bindestrich, Unterstrich, Punkt im Dateinamen)
#F|B-291|KB-06|fund|M4 Nr. 5 (DT-G0-M4-05)|Kennung ohne Ueberschrift mit angrenzendem Wortzeichen: dahinter Unterstrich und Wort (Form der Testnamen nach 6.6), davor Wort mit Unterstrich
#F|B-292|KB-23|fund|M4 Nr. 6 (DT-G0-M4-06)|Ausnahmeliste: Eintrag mit # im Grund (nicht am Zeilenanfang), der keinen Fund deckt, ist veraltet
#F|B-293|KB-20|kein-fund|M4 Nr. 6 (DT-G0-M4-06)|Ausnahmeliste: Eintrag mit # im Grund deckt den einzigen Fund
#F|B-294|KB-23|fund|M4 Nr. 7 (DT-G0-M4-07)|Ausnahmeliste ohne Schlussumbruch: der Eintrag in der letzten Zeile deckt keinen Fund und ist veraltet
#F|B-295|KB-20|kein-fund|M4 Nr. 7 (DT-G0-M4-07)|Ausnahmeliste ohne Schlussumbruch: der Eintrag in der letzten Zeile deckt den einzigen Fund
#F|B-296|KC-01|fund|M4 Nr. 8 (DT-G0-M4-08)|PATH nur aus der geschlossenen Liste: ein falscher Verweis jeder Art (ausser bestand-leer), ein Archivpfad nach Regel c, die Eintraege ausnahme-form, -ohne-grund und -veraltet, dazu je eine deckende Ausnahme der Formen datei|wert und datei:zeile (M5c, BM-142)
#F|B-297|KC-01|fund|M4 Nr. 8b (DT-G0-M4-08)|PATH nur aus der geschlossenen Liste bei leerer Pruefflaeche: bestand-leer
#F|B-298|KB-19|fund|M4 Nr. 9 (DT-G0-M4-09)|Pruefflaeche: falscher Verweis in einer Datei direkt unter .claude/ (Minimalbeispiel des Dynamic Software Testers)
#F|B-299|KB-19|fund|M4 Nr. 9 (DT-G0-M4-09)|Pruefflaeche: falscher Verweis in einer Datei eine Ebene tiefer unter .claude/
#F|B-300|EB-2|fund|M4 Nr. 10 (DT-G0-M4-10)|Umgebung des Pruefers mit fremden Werten unter BELEGE_AUSNAHMEN, AUSNAHMEDATEI, BACKLOG, PROJEKTAUFTRAG, ARCHIVSTAND, PRUEFFLAECHE_ERE: drei Funde bleiben, der Archivpfad besteht
#F|B-301|EB-2|statisch|M4 Nr. 10b (DT-G0-M4-10)|der Pruefer liest ausserhalb von Kommentarzeilen nur Variablen, die er selbst setzt oder loescht (Erlaubnisliste PATH, BASH_REMATCH); Gegenprobe der Pruefung an einem Probetext
#F|B-302|KC-03|lage-c|M4 Nr. 11 a (DT-G0-M4-11)|flacher Klon bei getrenntem Git-Verzeichnis (.git als Datei), shallow im Git-Verzeichnis
#F|B-303|KC-03|lage-c|M4 Nr. 11 b (DT-G0-M4-11)|flacher Klon bei verknuepftem Arbeitsbaum, shallow im gemeinsamen Git-Verzeichnis (Fall mit dem Datei-Werkzeug geschrieben)
#F|B-304|KB-12|fund|M4 Nr. 13 (Hinweis zu FM-02)|..an der Wurzel verlaesst die Wurzel: ../CLAUDE.md aus der Wurzel und ../../CLAUDE.md aus docs/, CLAUDE.md an der Wurzel vorhanden
#F|B-305|GB-36|kein-fund|M4 Nr. 14 (SA-M4-01)|Durchlass: Pruefsumme ohne Objekt in Unterstrichen wie bei einer Hervorhebung und mit einem Buchstaben unmittelbar davor
#F|B-306|KB-11|fund|M4 Nr. 15 (SA-M4-02)|Messung: Ersatzreferenz unter refs/replace/ fuer den Archivstand auf einen Commit mit einem Pfad, den der Archivstand nicht hat; Verweis darauf nach Regel c
#F|B-307|EB-3|gleich|ST-G0-25|Lauf ohne Variablen gegen Lauf mit GIT_GLOB_PATHSPECS=1 (git ls-files '*.md' lieferte nur die Wurzeldateien); der Fund unter docs/ bleibt ein Fund (AUSGABE_MIT am ersten Lauf)
#F|B-308|EB-3|gleich|ST-G0-25|Lauf ohne Variablen gegen Lauf mit GIT_NOGLOB_PATHSPECS=1 (git ls-files '*.md' lieferte keine Datei: bestand-leer); der Fund bleibt (AUSGABE_MIT am ersten Lauf)
#F|B-309|EB-3|gleich|ST-G0-25|Lauf ohne Variablen gegen Lauf mit GIT_LITERAL_PATHSPECS=1 (git ls-files '*.md' lieferte keine Datei: bestand-leer); der Fund bleibt (AUSGABE_MIT am ersten Lauf)
#F|B-310|KB-07|fund|M5d W-14 (Punkt 13)|Wurzelname Makefile ohne Schraegstrich (GB-10), Datei im Baum entfernt
#F|B-311|KB-07|fund|M5d W-14 (Punkt 13)|Wurzelname CLAUDE.md ohne Schraegstrich (GB-10), Datei im Baum entfernt
#F|B-190|EB-1|arbeitsbaum|Kopfkommentar|der Arbeitsbaum des Aufrufers (git status --porcelain --ignored --untracked-files=all und Inhaltspruefsummen) ist nach dem ganzen Lauf gleich wie davor (2a Punkt 8)
#

set -uo pipefail

# -----------------------------------------------------------------------------
# 0. Umgebung des Aufrufers: git-eigene Variablen loeschen, Sortierung festlegen
# -----------------------------------------------------------------------------
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_COMMON_DIR GIT_NAMESPACE GIT_CEILING_DIRECTORIES GIT_DISCOVERY_ACROSS_FILESYSTEM GIT_SHALLOW_FILE 2>/dev/null || true
unset "${!GIT_TRACE@}" 2>/dev/null || true
export LC_ALL=C

PM="belege-pruefen-selbsttest"
STAND="78bcef984583e665edb28f0f2e7ef8f1da0a87dc"
BESCHAFFUNG_ARCHIV="git fetch origin +refs/heads/archiv/r3coscrum:refs/remotes/origin/archiv/r3coscrum"
SPERRDATEI="/tmp/r3cosint-belege-pruefen-selbsttest.lock"
FALL_ZEITGRENZE=60
# Werkzeuge, die dieses Pruefmittel selbst aufruft (Lage C des Pruefmittels, wenn eines fehlt).
# Die Festlegung nennt bash, git, grep, sed, awk, mktemp, flock, sha256sum, cmp; die uebrigen
# sind die Standardwerkzeuge, die der Code unten benutzt (Entscheid des Koordinators vom 2026-10-28).
WERKZEUGE_PM="bash git grep sed awk mktemp flock sha256sum cmp sort dirname cp rm mkdir ln chmod cat head tail tr cut wc printf date env timeout readlink"
# Werkzeugkasten fuer KC-01 (P-2): die geschlossene Werkzeugliste des geprueften Pruefers, genau die Befehle, die er aufruft;
# der Kasten eines Falls enthaelt alle Werkzeuge ausser dem fehlenden (B-207: alle; die Huellen der Faelle B-249 ff. ersetzen einzelne)
KC01_KASTEN="git grep awk sort dirname"

lage_c_pm() { # lage_c_pm <Meldung> [<Beschaffungsweg>]
  echo "$PM: LAGE C des Pruefmittels -- $1" >&2
  if [ $# -ge 2 ]; then echo "$PM: Beschaffen: $2" >&2; fi
  echo "$PM: Rueckgabewert 3: der Lauf hat nicht stattgefunden." >&2
  exit 3
}

# -----------------------------------------------------------------------------
# 1. Parameter: [--mutationen] [--pruefer <pfad>]
# -----------------------------------------------------------------------------
MODUS="normal"
PRUEFER_ARG=""
while [ $# -gt 0 ]; do
  case "$1" in
    --mutationen) MODUS="mutationen"; shift ;;
    --pruefer)
      [ $# -ge 2 ] || lage_c_pm "Parameter --pruefer ohne Pfad."
      [ -z "$PRUEFER_ARG" ] || lage_c_pm "Parameter --pruefer mehrfach angegeben."
      PRUEFER_ARG="$2"; shift 2 ;;
    *) lage_c_pm "unbekannter Parameter '$1'; erlaubt ist [--mutationen] [--pruefer <pfad>]." ;;
  esac
done

# -----------------------------------------------------------------------------
# 2. Sperre: ein zweiter Lauf endet mit 3 vor jeder Handlung (Muster dod-gate-selbsttest.sh)
# -----------------------------------------------------------------------------
command -v flock >/dev/null 2>&1 || lage_c_pm "Werkzeug 'flock' fehlt." "Werkzeug installieren"
if ! exec {SPERRE_FD}>"$SPERRDATEI"; then
  lage_c_pm "Sperrdatei $SPERRDATEI nicht anlegbar."
fi
if ! flock -n "$SPERRE_FD"; then
  lage_c_pm "ein anderer Lauf dieses Pruefmittels haelt die Sperre ($SPERRDATEI)."
fi

# -----------------------------------------------------------------------------
# 3. Werkzeuge des Pruefmittels
# -----------------------------------------------------------------------------
for w in $WERKZEUGE_PM; do
  command -v "$w" >/dev/null 2>&1 || lage_c_pm "Werkzeug '$w' fehlt." "Werkzeug installieren"
done
# ST-G0-21: Der Mutationsmodus wendet die Ausdruecke der Mutationsdatei mit sed -E --sandbox an (e, r und w sind verboten);
# versteht sed die Option nicht oder ignoriert er sie, ist das Lage C des Pruefmittels.
if ! printf 'x\n' | sed -E --sandbox -e 's/x/y/' >/dev/null 2>&1 || printf 'x\n' | sed -E --sandbox -e 'w /dev/null' >/dev/null 2>&1; then
  lage_c_pm "sed versteht die Option --sandbox nicht (oder ignoriert sie)." "GNU sed ab Version 4.3 installieren"
fi
BASH_BIN=$(command -v bash)
case "$BASH_BIN" in
  /*) ;;
  *) lage_c_pm "bash ist nicht als absoluter Pfad aufloesbar ('$BASH_BIN')." ;;
esac

# -----------------------------------------------------------------------------
# 4. Arbeitsbaum = Baum, in dem dieses Pruefmittel liegt (Festlegung 2a Punkt 1);
#    der Aufrufort spielt keine Rolle. Pruefer = scripts/belege-pruefen.sh desselben Baums,
#    ausser --pruefer nennt einen anderen Pfad (relativ zum Aufrufort).
# -----------------------------------------------------------------------------
SKRIPT_QUELLE="${BASH_SOURCE[0]}"
SKRIPT_VERZ=$(cd "$(dirname "$SKRIPT_QUELLE")" >/dev/null 2>&1 && pwd -P) || lage_c_pm "Verzeichnis des Skripts nicht aufloesbar."
ARBEITSBAUM=$(git -C "$SKRIPT_VERZ" rev-parse --show-toplevel 2>/dev/null) || lage_c_pm "kein Git-Arbeitsbaum um das Verzeichnis des Skripts ($SKRIPT_VERZ)."
if [ -n "$PRUEFER_ARG" ]; then
  case "$PRUEFER_ARG" in
    /*) PRUEFER="$PRUEFER_ARG" ;;
    *) PRUEFER="$PWD/$PRUEFER_ARG" ;;
  esac
else
  PRUEFER="$ARBEITSBAUM/scripts/belege-pruefen.sh"
fi
[ -f "$PRUEFER" ] || lage_c_pm "Pruefer nicht gefunden: $PRUEFER"
[ -r "$PRUEFER" ] || lage_c_pm "Pruefer nicht lesbar: $PRUEFER"

# Der Archivstand muss im Arbeitsbaum als Commit vorliegen (Lage C des Pruefmittels, mit Beschaffungsweg)
git -C "$ARBEITSBAUM" cat-file -e "${STAND}^{commit}" 2>/dev/null \
  || lage_c_pm "Archivstand $STAND ist im Arbeitsbaum nicht als Commit vorhanden." "$BESCHAFFUNG_ARCHIV"

ARB_COMMIT=$(git -C "$ARBEITSBAUM" rev-parse HEAD 2>/dev/null) || ARB_COMMIT="unbekannt"
ARB_SAUBER="sauber"
if [ -n "$(env GIT_OPTIONAL_LOCKS=0 git -C "$ARBEITSBAUM" status --porcelain 2>/dev/null)" ]; then
  ARB_SAUBER="mit Aenderungen"
fi
PRUEFER_SHA=$(sha256sum "$PRUEFER" | cut -c1-16)
MUTATIONSDATEI="$SKRIPT_VERZ/belege-pruefen-mutationen.txt"
MUT_SHA="-"
if [ -f "$MUTATIONSDATEI" ] && [ -r "$MUTATIONSDATEI" ]; then
  MUT_SHA=$(sha256sum "$MUTATIONSDATEI" | cut -c1-16)
elif [ "$MODUS" = "mutationen" ]; then
  lage_c_pm "Mutationsdatei fehlt oder ist nicht lesbar: $MUTATIONSDATEI"
fi

# -----------------------------------------------------------------------------
# 5. Schnappschuss des Arbeitsbaums VOR jeder weiteren Handlung (Fall "kein Schreiben in den
#    Arbeitsbaum", 2a Punkt 8): Statusliste einschliesslich ignorierter und unversionierter
#    Dateien, dazu die Pruefsumme jeder Datei.
# -----------------------------------------------------------------------------
schnappschuss() { # schnappschuss <verzeichnis> : Zustand auf der Standardausgabe
  local d="$1" f
  env GIT_OPTIONAL_LOCKS=0 git -C "$d" status --porcelain --ignored --untracked-files=all || return 1
  echo "--- Pruefsummen"
  {
    git -C "$d" ls-files -z -c -o --exclude-standard || return 1
    git -C "$d" ls-files -z -o -i --exclude-standard || return 1
  } | sort -z -u | while IFS= read -r -d '' f; do
    if [ -L "$d/$f" ]; then
      printf 'L %s %s\n' "$(sha256sum < "$d/$f" 2>/dev/null | cut -c1-64)" "$f"
    elif [ -f "$d/$f" ]; then
      printf 'F %s %s\n' "$(sha256sum < "$d/$f" | cut -c1-64)" "$f"
    else
      printf '? %s\n' "$f"
    fi
  done
}

# -----------------------------------------------------------------------------
# 6. Wegwerfverzeichnis ausserhalb des Arbeitsbaums, Aufraeumen auch bei Abbruch
# -----------------------------------------------------------------------------
T=$(mktemp -d) || lage_c_pm "mktemp -d fehlgeschlagen."
T=$(cd "$T" && pwd -P)
case "$T/" in
  "$ARBEITSBAUM"/*) rm -rf "$T"; lage_c_pm "Wegwerfverzeichnis liegt im Arbeitsbaum ($T)." ;;
esac
aufraeumen() {
  chmod -R u+rwx "$T" >/dev/null 2>&1
  rm -rf "$T"
}
trap aufraeumen EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

# -----------------------------------------------------------------------------
# 7. Umgebung jedes Laufs (2a Punkt 6): LC_ALL=C, TZ=UTC, HOME und XDG_CONFIG_HOME auf ein
#    leeres Verzeichnis, GIT_CONFIG_NOSYSTEM=1, GIT_CONFIG_GLOBAL=/dev/null,
#    GIT_ALLOW_PROTOCOL=file, feste Identitaet und Zeitstempel. Der Pruefer laeuft unter
#    "env -i" mit genau diesen Variablen; die git-Aufrufe des Pruefmittels (gitg) setzen dieselben Variablen, laufen aber
#    nicht unter env -i (ST-G0-32).
# -----------------------------------------------------------------------------
HOME_LEER="$T/home"
mkdir -p "$HOME_LEER" || lage_c_pm "Verzeichnis $HOME_LEER nicht anlegbar."
ENV_BASIS=(
  "PATH=$PATH"
  "HOME=$HOME_LEER"
  "XDG_CONFIG_HOME=$HOME_LEER"
  "LC_ALL=C"
  "TZ=UTC"
  "GIT_CONFIG_NOSYSTEM=1"
  "GIT_CONFIG_GLOBAL=/dev/null"
  "GIT_ALLOW_PROTOCOL=file"
  "GIT_CEILING_DIRECTORIES=$T"
  "GIT_AUTHOR_NAME=Selbsttest"
  "GIT_AUTHOR_EMAIL=selbsttest@example.invalid"
  "GIT_AUTHOR_DATE=2026-01-01T00:00:00Z"
  "GIT_COMMITTER_NAME=Selbsttest"
  "GIT_COMMITTER_EMAIL=selbsttest@example.invalid"
  "GIT_COMMITTER_DATE=2026-01-01T00:00:00Z"
)
gitg() { env "${ENV_BASIS[@]}" git "$@"; }

# =============================================================================
# 8. Hilfen fuer die Fallfunktionen (f_B...): alle Pfade relativ zu $BAUM
# =============================================================================
BT='```'
TL='~~~'
FALL_K="?"

herstellung_fehler() { # nicht herstellbare Faelle haben nicht_herstellbar; ein Fehler hier ist ein Defekt des Pruefmittels
  echo "$PM: FEHLER -- Herstellung des Falls $FALL_K fehlgeschlagen: $*" >&2
  exit 3
}
g() { gitg -C "$BAUM" "$@"; }
w() { # w <pfad> : Standardeingabe nach $BAUM/<pfad>
  mkdir -p "$(dirname "$BAUM/$1")" && cat > "$BAUM/$1" || herstellung_fehler "w $1"
}
wa() { # wa <pfad> : Standardeingabe an $BAUM/<pfad> anhaengen
  mkdir -p "$(dirname "$BAUM/$1")" && cat >> "$BAUM/$1" || herstellung_fehler "wa $1"
}
zeilen() { # zeilen <pfad> <zeile>... : jede Zeile mit Zeilenumbruch
  local p="$1"; shift
  mkdir -p "$(dirname "$BAUM/$p")" && printf '%s\n' "$@" > "$BAUM/$p" || herstellung_fehler "zeilen $p"
}
zeilen_an() { # zeilen_an <pfad> <zeile>... : anhaengen
  local p="$1"; shift
  printf '%s\n' "$@" >> "$BAUM/$p" || herstellung_fehler "zeilen_an $p"
}
md() { zeilen docs/fall.md "$@"; }
erwarte() { # erwarte <datei:zeile> <art> <wert> : eine erwartete Fundzeile
  ERW+=("$(printf '%s\t%s\t%s' "$1" "$2" "$3")")
}
ausnahme() { # ausnahme <schluessel> <grund> : Eintrag der Ausnahmeliste (Schluessel, Tabulator, Grund)
  printf '%s\t%s\n' "$1" "$2" >> "$BAUM/scripts/belege-ausnahmen.txt" || herstellung_fehler "ausnahme"
}
kein_add() { NO_ADD=1; }
nicht_herstellbar() { NH_GRUND="$1"; }
basis_ohne_archiv() { # Baum des Falls aus der Kopie des Grundbaums ohne die Objekte des Archivstands
  rm -rf "$BAUM" && cp -a "$GRUND_OHNE_ARCHIV" "$BAUM" || herstellung_fehler "Basis ohne Archivstand"
}
werkzeugkasten_ohne() { # werkzeugkasten_ohne <fehlendes> : setzt KASTEN auf ein Verzeichnis aus Verknuepfungen ohne dieses Werkzeug
  local fehlt="$1" box="$FALL/kasten-ohne-$1" t p
  mkdir -p "$box" || herstellung_fehler "Werkzeugkasten $box"
  for t in $KC01_KASTEN; do
    [ "$t" = "$fehlt" ] && continue
    p=$(command -v "$t") || herstellung_fehler "Werkzeug $t nicht aufloesbar"
    ln -s "$p" "$box/$t" || herstellung_fehler "Verknuepfung $t"
  done
  KASTEN="$box"
}

fall_zuruecksetzen() {
  ERW=()
  ENV_ZUSATZ=()
  ENV_ZUSATZ2=()
  NO_ADD=0
  NH_GRUND=""
  CWD_WAHL=""
  AUSGABE_MIT=()
  AUSGABE_OHNE=()
  AUSGABE_OHNE_ERE=()
  LC_KENNUNG=""
  LC_NICHT=()
  LC_WEG_F=""
  LC_WEG_ERE=""
  LC_MIT=()
  ZG_FALL=""
  STAT_OK=""
  STAT_SOLL=""
  STAT_IST=""
  ARTEN_PRUEFEN=0
  SCHLUSS_GB=0
  ZN_BEFUNDE=""
  ZN_ZEILEN=""
  DETAIL=()
  ERG=""
  IST=""
}

# =============================================================================
# 9. Grundbaum (2a Punkt 5): synthetisch, ausserhalb des Arbeitsbaums, Archivobjekte aus dem
#    Arbeitsbaum geholt (ohne Netz). Weg 1: die Refspec der Festlegung; Weg 2 (nur wenn Weg 1
#    scheitert, etwa weil die Fernreferenz im Arbeitsbaum fehlt): der Abruf ueber die Pruefsumme.
# =============================================================================
grundbaum_bauen() {
  GRUND="$T/grund"
  GRUND_OHNE_ARCHIV="$T/grund-ohne-archiv"
  mkdir -p "$GRUND" || return 1
  gitg -C "$GRUND" init -q || return 1
  gitg -C "$GRUND" symbolic-ref HEAD refs/heads/grund || return 1
  BAUM="$GRUND"
  zeilen CLAUDE.md '# Projektregeln (synthetisch)'
  printf 'all:\n\t@true\n' | w Makefile
  zeilen docs/00_Projektauftrag.md '# Projektauftrag (synthetisch)' '' '## 1.1 Erster Abschnitt' '' 'Text.' '' '## 1.2 Zweiter Abschnitt' '' 'Text.' '' '## 5.4 Verfahrensgarantien' '' 'Text.'
  zeilen docs/05_Product_Backlog.md '# R3-A-001 Erste Anforderung' '' 'Text.' '' '### R3-B-002 Zweite Anforderung' '' 'Text.' '' '###### R3-C-003 Dritte Anforderung' '' 'Text.'
  zeilen docs/adr/0001-test.md '# ADR 1 (synthetisch)' '' 'Text.'
  local i=1
  : > "$BAUM/docs/ziel.md"
  while [ "$i" -le 20 ]; do printf 'Zeile %d\n' "$i" >> "$BAUM/docs/ziel.md"; i=$((i + 1)); done
  zeilen .claude/agents/rolle-a.md '---' 'name: rolle-a' 'description: Synthetische Rolle' 'skills:' '  - skill-a' '---' '# Rolle A'
  zeilen .claude/skills/skill-a/SKILL.md '---' 'name: skill-a' 'description: Synthetische Skill' 'metadata:' '  anforderung: R3-A-001' '---' '# Skill A'
  mkdir -p "$BAUM/scripts" && : > "$BAUM/scripts/belege-ausnahmen.txt" || return 1
  gitg -C "$GRUND" add -A || return 1
  gitg -C "$GRUND" commit -q -m "Grundbaum" || return 1
  GRUND_COMMIT=$(gitg -C "$GRUND" rev-parse HEAD) || return 1
  GRUND_BAUM=$(gitg -C "$GRUND" rev-parse 'HEAD^{tree}') || return 1
  cp -a "$GRUND" "$GRUND_OHNE_ARCHIV" || return 1
  ARCHIV_WEG="Refspec"
  if ! gitg -C "$GRUND" fetch -q "$ARBEITSBAUM" "+refs/remotes/origin/archiv/r3coscrum:refs/remotes/origin/archiv/r3coscrum" 2>"$T/abruf.fehler"; then
    ARCHIV_WEG="Pruefsumme"
    gitg -C "$GRUND" fetch -q "$ARBEITSBAUM" "$STAND" 2>>"$T/abruf.fehler" || return 2
  fi
  gitg -C "$GRUND" cat-file -e "${STAND}^{commit}" 2>/dev/null || return 2
  return 0
}

archivpfade_waehlen() { # waehlt die Archivpfade der Faelle aus dem Baum des Archivstands (2a Punkt 5)
  local liste
  liste=$(gitg -C "$GRUND" ls-tree -r --name-only "$STAND") || return 1
  A_DATEI=$(printf '%s\n' "$liste" | grep -E '^methodik/.*\.md$' | sort | head -n 1)
  [ -n "$A_DATEI" ] || return 1
  A_ZEILEN=$(gitg -C "$GRUND" cat-file blob "$STAND:$A_DATEI" | awk 'END{print NR+0}')
  if printf '%s\n' "$liste" | grep -qx 'CLAUDE.md'; then
    A_WURZEL="CLAUDE.md"
  else
    A_WURZEL=$(printf '%s\n' "$liste" | grep -v '/' | sort | head -n 1)
  fi
  [ -n "$A_WURZEL" ] || return 1
  A_WZEILEN=$(gitg -C "$GRUND" cat-file blob "$STAND:$A_WURZEL" | awk 'END{print NR+0}')
  [ "$(gitg -C "$GRUND" cat-file -t "$STAND:nachweise" 2>/dev/null)" = "tree" ] || return 1
  [ "$(gitg -C "$GRUND" cat-file -t "$STAND:sprints" 2>/dev/null)" = "tree" ] || return 1
  [ "$(gitg -C "$GRUND" cat-file -t "$STAND:.github" 2>/dev/null)" = "tree" ] || return 1
  A_ELTERN=$(gitg -C "$GRUND" rev-parse "${STAND}^1" 2>/dev/null) || return 1
  [ "$A_ZEILEN" -ge 1 ] 2>/dev/null && [ "$A_WZEILEN" -ge 1 ] 2>/dev/null || return 1
  return 0
}

# =============================================================================
# 10. Lauf des Pruefers und Bewertung
# =============================================================================
H_FUNDE='=== Funde vollst'
H_ARTEN='=== Funde nach Pr'

lauf_pruefer() { # lauf_pruefer <cwd> <aus> <fehler> [VAR=WERT...] : setzt LAUF_RC
  local cwd="$1" out="$2" err="$3"
  shift 3
  ( exec {SPERRE_FD}>&-; cd "$cwd" && exec timeout -k 5 "${ZG_FALL:-$FALL_ZEITGRENZE}" env -i "${ENV_BASIS[@]}" "$@" "$BASH_BIN" "$PRUEFER" </dev/null ) >"$out" 2>"$err"
  LAUF_RC=$?
}
abschnitt_zahl() { awk -v h="$1" 'index($0,h)==1 {n++} END{print n+0}' "$2"; }
abschnitt_lesen() { awk -v h="$1" 'BEGIN{s=0} index($0,h)==1 {s=1; next} s && (index($0,"=== ")==1 || index($0,"---")==1) {s=0} s && length($0)>0 {print}' "$2"; }
befunde_lesen() { awk '/^Befunde: [0-9]+$/ {n++; v=$2} END{ if (n==1) print v; else print "x" }' "$1"; }
tab_sichtbar() { sed 's/\t/ <TAB> /g'; }
mengen_vergleichen() { # mengen_vergleichen <erwartet> <ist> : Abweichungen ("fehlt", "zuviel"), Mehrfachzeilen zaehlen einzeln
  { sed 's/^/E\t/' "$1"; sed 's/^/A\t/' "$2"; } | awk -F'\t' '
    $1 == "E" { e[substr($0, 3)]++; next }
    $1 == "A" { a[substr($0, 3)]++ }
    END {
      for (k in e) { n = a[k] + 0; for (i = n; i < e[k]; i++) print "fehlt\t" k }
      for (k in a) { n = e[k] + 0; for (i = n; i < a[k]; i++) print "zuviel\t" k }
    }' | sort
}
stderr_kopf() { head -n 3 "$1" 2>/dev/null | tr '\n' ' ' | cut -c1-300; }

bewerte_funde() { # bewerte_funde <soll> <aus> <fehler> <rc>
  local soll="$1" out="$2" err="$3" rc="$4" erwrc nabs bef nz badform i abw
  if [ "$rc" = 124 ] || [ "$rc" = 137 ]; then
    ERG=GEFALLEN; IST="Zeitgrenze von ${ZG_FALL:-$FALL_ZEITGRENZE} s ueberschritten (Rueckgabewert $rc)"; return
  fi
  case "$soll" in fund) erwrc=2 ;; *) erwrc=0 ;; esac
  nabs=$(abschnitt_zahl "$H_FUNDE" "$out")
  bef=$(befunde_lesen "$out")
  if [ "$nabs" != 1 ]; then
    ERG=GEFALLEN; IST="Rueckgabewert $rc, Abschnitt der Funde ${nabs}-mal vorhanden statt einmal"
    DETAIL+=("Fehlerausgabe: $(stderr_kopf "$err")")
    return
  fi
  abschnitt_lesen "$H_FUNDE" "$out" > "$FALL/ist.txt"
  nz=$(awk 'END{print NR+0}' "$FALL/ist.txt")
  badform=$(awk -F'\t' 'NF != 3 || $1 !~ /^[^\t]+:[0-9]+$/ || $2 == "" {n++} END{print n+0}' "$FALL/ist.txt")
  IST="Rueckgabewert $rc, Befunde $bef, $nz Fundzeilen"
  if [ "$rc" != "$erwrc" ]; then ERG=GEFALLEN; DETAIL+=("Rueckgabewert $rc statt $erwrc"); fi
  if [ "$bef" = x ]; then
    ERG=GEFALLEN; DETAIL+=("genau eine Zeile 'Befunde: n' erwartet, gelesen wurde keine oder mehr als eine")
  elif [ "$bef" != "$nz" ]; then
    ERG=GEFALLEN; DETAIL+=("'Befunde: $bef' ungleich der Zahl der Fundzeilen $nz")
  fi
  if [ "$badform" != 0 ]; then ERG=GEFALLEN; DETAIL+=("$badform Fundzeile(n) nicht in der Form Datei:Zeile, Tabulator, Art, Tabulator, Wert"); fi
  : > "$FALL/erwartet.txt"
  for i in "${ERW[@]+"${ERW[@]}"}"; do printf '%s\n' "$i" >> "$FALL/erwartet.txt"; done
  abw=$(mengen_vergleichen "$FALL/erwartet.txt" "$FALL/ist.txt")
  if [ -n "$abw" ]; then
    ERG=GEFALLEN
    while IFS= read -r i; do DETAIL+=("$(printf '%s' "$i" | tab_sichtbar)"); done <<< "$abw"
  fi
  if [ "$ERG" = GEFALLEN ] && [ "$rc" != 0 ] && [ "$rc" != 2 ]; then DETAIL+=("Fehlerausgabe: $(stderr_kopf "$err")"); fi
}

bewerte_zeilenumbruch() { # bewerte_zeilenumbruch <aus> <fehler> <rc> : GB-32, "Befunde: n" zaehlt die Funde, nicht die Zeilen
  local out="$1" err="$2" rc="$3" nabs bef nz i abw
  if [ "$rc" = 124 ] || [ "$rc" = 137 ]; then
    ERG=GEFALLEN; IST="Zeitgrenze von ${ZG_FALL:-$FALL_ZEITGRENZE} s ueberschritten (Rueckgabewert $rc)"; return
  fi
  nabs=$(abschnitt_zahl "$H_FUNDE" "$out")
  bef=$(befunde_lesen "$out")
  if [ "$nabs" != 1 ]; then
    ERG=GEFALLEN; IST="Rueckgabewert $rc, Abschnitt der Funde ${nabs}-mal vorhanden statt einmal"
    DETAIL+=("Fehlerausgabe: $(stderr_kopf "$err")")
    return
  fi
  abschnitt_lesen "$H_FUNDE" "$out" > "$FALL/ist.txt"
  nz=$(awk 'END{print NR+0}' "$FALL/ist.txt")
  IST="Rueckgabewert $rc, Befunde $bef, $nz Zeilen unter Funde vollstaendig"
  if [ "$rc" != 2 ]; then ERG=GEFALLEN; DETAIL+=("Rueckgabewert $rc statt 2"); fi
  if [ "$bef" != "$ZN_BEFUNDE" ]; then ERG=GEFALLEN; DETAIL+=("'Befunde: $bef' statt 'Befunde: $ZN_BEFUNDE'"); fi
  if [ "$nz" != "$ZN_ZEILEN" ]; then ERG=GEFALLEN; DETAIL+=("$nz Zeilen unter 'Funde vollstaendig' statt $ZN_ZEILEN"); fi
  : > "$FALL/erwartet.txt"
  for i in "${ERW[@]+"${ERW[@]}"}"; do printf '%s\n' "$i" >> "$FALL/erwartet.txt"; done
  abw=$(mengen_vergleichen "$FALL/erwartet.txt" "$FALL/ist.txt")
  if [ -n "$abw" ]; then
    ERG=GEFALLEN
    while IFS= read -r i; do DETAIL+=("$(printf '%s' "$i" | tab_sichtbar)"); done <<< "$abw"
  fi
}

bewerte_lagec() { # bewerte_lagec <aus> <fehler> <rc>
  local out="$1" err="$2" rc="$3" n lc kn
  if [ "$rc" = 124 ] || [ "$rc" = 137 ]; then
    ERG=GEFALLEN; IST="Zeitgrenze von ${ZG_FALL:-$FALL_ZEITGRENZE} s ueberschritten (Rueckgabewert $rc)"; return
  fi
  lc=nein; grep -qF 'LAGE C' "$err" && lc=ja
  kn=nein; grep -qF -- "$LC_KENNUNG" "$err" && kn=ja
  IST="Rueckgabewert $rc, 'LAGE C' $lc, Kennung '$LC_KENNUNG' $kn"
  if [ "$rc" != 3 ]; then ERG=GEFALLEN; DETAIL+=("Rueckgabewert $rc statt 3"); fi
  if [ "$lc" != ja ]; then ERG=GEFALLEN; DETAIL+=("Fehlerausgabe ohne 'LAGE C'"); fi
  if [ "$kn" != ja ]; then ERG=GEFALLEN; DETAIL+=("Fehlerausgabe ohne die Kennung '$LC_KENNUNG'"); fi
  for n in "${LC_NICHT[@]+"${LC_NICHT[@]}"}"; do
    if grep -qF -- "$n" "$err"; then ERG=GEFALLEN; DETAIL+=("Fehlerausgabe nennt '$n', obwohl der erste Mangel der Reihenfolge zu melden ist"); fi
  done
  if [ -n "$LC_WEG_F" ] && ! grep -qF -- "$LC_WEG_F" "$err"; then ERG=GEFALLEN; DETAIL+=("Fehlerausgabe ohne den Beschaffungsweg '$LC_WEG_F'"); fi
  if [ -n "$LC_WEG_ERE" ] && ! grep -qE -- "$LC_WEG_ERE" "$err"; then ERG=GEFALLEN; DETAIL+=("Fehlerausgabe ohne Beschaffungsweg (Muster '$LC_WEG_ERE')"); fi
  for n in "${LC_MIT[@]+"${LC_MIT[@]}"}"; do
    if ! grep -qF -- "$n" "$err"; then ERG=GEFALLEN; DETAIL+=("Fehlerausgabe nennt nicht '$n'"); fi
  done
  if grep -q '^Befunde:' "$out"; then ERG=GEFALLEN; DETAIL+=("Standardausgabe enthaelt 'Befunde:'"); fi
  if grep -q '^=== Funde' "$out"; then ERG=GEFALLEN; DETAIL+=("Standardausgabe enthaelt den Abschnitt '=== Funde'"); fi
  if [ "$ERG" = GEFALLEN ]; then DETAIL+=("Fehlerausgabe: $(stderr_kopf "$err")"); fi
}

kopf_kennungen() { # Kennungen KB, KC, GB und EB aus dem Kopfkommentar des geprueften Pruefers (2a Punkt 9): eine je Zeile, sortiert, einmalig
  awk 'NR==1 && /^#!/ {next} /^[[:space:]]*#/ {print; next} /^[[:space:]]*$/ {next} {exit}' "$PRUEFER" \
    | grep -oE '\b(KB|KC|GB)-[0-9]{2}\b|\bEB-[0-9]\b' | sort -u
}
schluss_grenzen_pruefen() { # schluss_grenzen_pruefen <aus> : die Schlussausgabe nennt genau die Grenzen GB des Kopfkommentars (Punkt 8)
  local out="$1" kopf_gb out_gb x
  kopf_gb=$(kopf_kennungen | grep '^GB-')
  out_gb=$(grep -oE '\bGB-[0-9]{2}\b' "$out" | sort -u)
  if [ -z "$kopf_gb" ]; then ERG=GEFALLEN; DETAIL+=("der Kopfkommentar nennt keine Grenze GB"); fi
  for x in $kopf_gb; do
    if ! printf '%s\n' "$out_gb" | grep -qx "$x"; then ERG=GEFALLEN; DETAIL+=("Schlussausgabe nennt $x nicht"); fi
  done
  for x in $out_gb; do
    if ! printf '%s\n' "$kopf_gb" | grep -qx "$x"; then ERG=GEFALLEN; DETAIL+=("Schlussausgabe nennt $x, der Kopfkommentar nicht"); fi
  done
  if ! grep -qF 'Kopfkommentar' "$out"; then ERG=GEFALLEN; DETAIL+=("Schlussausgabe verweist nicht auf den Kopfkommentar"); fi
}
ausgabe_pruefen() { # ausgabe_pruefen <aus> : Aussagen ueber die Standardausgabe (kein-fund+ausgabe)
  local out="$1" s
  if [ "$SCHLUSS_GB" = 1 ]; then schluss_grenzen_pruefen "$out"; fi
  for s in "${AUSGABE_MIT[@]+"${AUSGABE_MIT[@]}"}"; do
    if ! grep -qF -- "$s" "$out"; then ERG=GEFALLEN; DETAIL+=("Standardausgabe enthaelt nicht: $s"); fi
  done
  for s in "${AUSGABE_OHNE[@]+"${AUSGABE_OHNE[@]}"}"; do
    if grep -qF -- "$s" "$out"; then ERG=GEFALLEN; DETAIL+=("Standardausgabe enthaelt: $s"); fi
  done
  for s in "${AUSGABE_OHNE_ERE[@]+"${AUSGABE_OHNE_ERE[@]}"}"; do
    if grep -qE -- "$s" "$out"; then ERG=GEFALLEN; DETAIL+=("Standardausgabe enthaelt (Muster): $s"); fi
  done
}

arten_pruefen() { # arten_pruefen <aus> : Summe der Arten gleich n, je Art gleich der Zahl der Fundzeilen (KB-24)
  local out="$1" r
  abschnitt_lesen "$H_ARTEN" "$out" > "$FALL/arten.txt"
  r=$({ sed 's/^/E\t/' "$FALL/arten.txt"; sed 's/^/A\t/' "$FALL/ist.txt"; } | awk -F'\t' '
    $1 == "E" { if ($2 != "(keine)") { art[$2] = $3 + 0; summe += $3 } ; next }
    $1 == "A" { zahl[$3]++; gesamt++ }
    END {
      abw = 0
      for (k in art) if (art[k] != zahl[k] + 0) abw = 1
      for (k in zahl) if (!(k in art)) abw = 1
      if (summe != gesamt) abw = 1
      print (abw ? "abweichend" : "gleich") " (Summe der Arten " summe + 0 ", Fundzeilen " gesamt + 0 ")"
    }')
  case "$r" in
    gleich*) IST="$IST; Arten: $r" ;;
    *) ERG=GEFALLEN; DETAIL+=("Abschnitt 'Funde nach Pruefungsart' $r") ;;
  esac
}

verz_liste() { # verz_liste <wurzel> <verzeichnis> : alle Verzeichnisse unterhalb (ohne .git), Pfad relativ zur Wurzel
  local wz="$1" d="$2" p
  for p in "$d"/* "$d"/.[!.]* "$d"/..?*; do
    [ -d "$p" ] && [ ! -L "$p" ] || continue
    case "$p" in */.git) continue ;; esac
    printf 'D %s\n' "${p#"$wz"/}"
    verz_liste "$wz" "$p"
  done
}
zustand_baum() { # Schnappschuss plus Verzeichnisliste
  schnappschuss "$1" || return 1
  echo "--- Verzeichnisse"
  verz_liste "$1" "$1"
}
baum_voll() { # baum_voll <wurzel> <verzeichnis> : jeder Eintrag unterhalb, auch .git/: Datei (Pfad, SHA-256), Verzeichnis (Pfad), Verknuepfung (Pfad, Ziel)
  local wz="$1" d="$2" p
  for p in "$d"/* "$d"/.[!.]* "$d"/..?*; do
    if [ -L "$p" ]; then
      printf 'L %s %s\n' "$(readlink "$p")" "${p#"$wz"/}"
    elif [ -d "$p" ]; then
      printf 'D %s\n' "${p#"$wz"/}"
      baum_voll "$wz" "$p"
    elif [ -f "$p" ]; then
      printf 'F %s %s\n' "$(sha256sum < "$p" | cut -c1-64)" "${p#"$wz"/}"
    elif [ -e "$p" ]; then
      printf '? %s\n' "${p#"$wz"/}"
    fi
  done
}
zustand_baum_voll() { # Schnappschuss des Wegwerf-Baums einschliesslich seines Git-Verzeichnisses (EB-1, M5b Nr. 12); schreibt selbst nicht
  local d="$1"
  env "${ENV_BASIS[@]}" GIT_OPTIONAL_LOCKS=0 git -C "$d" status --porcelain --ignored --untracked-files=all || return 1
  echo "--- Baum"
  baum_voll "$d" "$d"
}

# =============================================================================
# 11. Faelle KB-01 bis KB-17 (B-001 bis B-083, B-191 bis B-197)
#     Je Fall: Aenderung am Baum, erwartete Fundzeilen (erwarte) oder Aussagen ueber die Ausgabe.
#     docs/fall.md ist die Datei, die der Fall mit seinen Verweisen beschreibt.
# =============================================================================
rolle_b() { # rolle_b <zeile>... : .claude/agents/rolle-b.md, Zeilen 1 bis 3 fest, die Argumente ab Zeile 4
  zeilen .claude/agents/rolle-b.md '---' 'name: rolle-b' 'description: x' "$@" '---' '# Rolle B'
}
skill_n() { # skill_n <name> <zeile>... : .claude/skills/<name>/SKILL.md, Zeilen 1 bis 3 fest, die Argumente ab Zeile 4
  local n="$1"; shift
  zeilen ".claude/skills/$n/SKILL.md" '---' "name: $n" 'description: x' "$@" '---' "# $n"
}
skill_b() { skill_n skill-b "$@"; }

# --- Grundfall -----------------------------------------------------------------
f_B001() { :; }

# --- KB-01 Pruefung 1, Einzelzeile -----------------------------------------------
f_B002() { md 'Siehe `docs/ziel.md:99` dazu.'; erwarte docs/fall.md:1 zeile docs/ziel.md:99; }
f_B003() { md 'Siehe `docs/ziel.md:21` dazu.'; erwarte docs/fall.md:1 zeile docs/ziel.md:21; }
f_B004() { md 'Siehe `docs/ziel.md:0` dazu.'; erwarte docs/fall.md:1 zeile docs/ziel.md:0; }
f_B005() { md 'Letzte Zeile `docs/ziel.md:20` und erste `docs/ziel.md:1` hier.'; }
f_B006() {
  printf 'a\nb\nc' | w docs/ohne-umbruch.md
  md 'Siehe `docs/ohne-umbruch.md:3` dazu.'
}

# --- KB-02 Pruefung 1, Bereich ---------------------------------------------------
f_B007() { md 'Siehe `docs/ziel.md:2-21` dazu.'; erwarte docs/fall.md:1 zeile docs/ziel.md:2-21; }
f_B008() { md 'Siehe `docs/ziel.md:50-10` dazu.'; erwarte docs/fall.md:1 zeile docs/ziel.md:50-10; }
f_B009() { md 'Siehe `docs/ziel.md:15-10` dazu.'; erwarte docs/fall.md:1 zeile docs/ziel.md:15-10; }
f_B010() { md 'Siehe `docs/ziel.md:0-5` dazu.'; erwarte docs/fall.md:1 zeile docs/ziel.md:0-5; }
f_B011() { md 'Bereich `docs/ziel.md:2-5` hier.' 'Bereich `docs/ziel.md:1-20` hier.' 'Bereich `docs/ziel.md:7-7` hier.'; }

# --- KB-03 Pruefung 1 an Verzeichnis, Archivpfad, Praefix r3cosint/ ---------------
f_B012() { md 'Siehe `docs/adr:3` dazu.'; erwarte docs/fall.md:1 zeile docs/adr:3; }
f_B013() {
  md "Siehe \`${A_DATEI}:$((A_ZEILEN + 1))\` dazu."
  erwarte docs/fall.md:1 zeile "${A_DATEI}:$((A_ZEILEN + 1))"
}
f_B014() { md "Erste \`${A_DATEI}:1\` und letzte \`${A_DATEI}:${A_ZEILEN}\` Zeile hier."; }
f_B015() { md 'Siehe `nachweise/.:2` dazu.'; erwarte docs/fall.md:1 zeile nachweise/.:2; }
f_B016() { md 'Siehe `r3cosint/CLAUDE.md:99` dazu.'; erwarte docs/fall.md:1 zeile r3cosint/CLAUDE.md:99; }
f_B017() { md 'Siehe `r3cosint/CLAUDE.md:1` dazu.'; }
f_B018() {
  md "Siehe \`r3coscrum/${A_WURZEL}:$((A_WZEILEN + 1))\` dazu."
  erwarte docs/fall.md:1 zeile "r3coscrum/${A_WURZEL}:$((A_WZEILEN + 1))"
}
f_B019() { md "Siehe \`r3coscrum/${A_WURZEL}:1\` dazu."; }

# --- KB-04 Pruefung 2, Commit-Pruefsumme -------------------------------------------
f_B020() { md 'Commit 0123456789abcdef0123456789abcdef01234567 dazu.'; erwarte docs/fall.md:1 commit 0123456789abcdef0123456789abcdef01234567; }
f_B021() { md "Baum $GRUND_BAUM dazu."; erwarte docs/fall.md:1 commit "$GRUND_BAUM"; }
f_B022() { md "Commit $GRUND_COMMIT dazu."; }
f_B023() { md "Stand $STAND dazu."; }
f_B024() { md "Vorgaenger $A_ELTERN dazu."; }
f_B025() {
  md 'Einundvierzig 0123456789abcdef0123456789abcdef012345678 hier.' \
     'Vierundsechzig 0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef hier.'
}

# --- KB-05 Pruefung 2, Zweigform ----------------------------------------------------
f_B026() { md 'Siehe https://github.com/x/y/blob/main/a.md dazu.'; erwarte docs/fall.md:1 blob-tree-verweis blob/main; }
f_B027() { md 'Siehe https://github.com/x/y/tree/main/docs dazu.'; erwarte docs/fall.md:1 blob-tree-verweis tree/main; }
f_B028() { md "Siehe https://github.com/x/y/blob/${GRUND_COMMIT}/docs/ziel.md dazu."; }

# --- KB-06 Pruefung 3 ---------------------------------------------------------------
f_B029() { md 'Siehe R3-Z-999 dazu.'; erwarte docs/fall.md:1 anforderung R3-Z-999; }
f_B030() {
  local n
  n=$(awk 'END{print NR+0}' "$BAUM/docs/05_Product_Backlog.md")
  zeilen_an docs/05_Product_Backlog.md '###R3-D-004 Ohne Leerzeichen'
  md 'Siehe R3-D-004 dazu.'
  erwarte "docs/05_Product_Backlog.md:$((n + 1))" anforderung R3-D-004
  erwarte docs/fall.md:1 anforderung R3-D-004
}
f_B031() { md 'Ebene 1: R3-A-001' 'Ebene 3: R3-B-002' 'Ebene 6: R3-C-003'; }

# --- KB-07 Pruefung 4, wurzelrelativ -------------------------------------------------
f_B032() {
  md '`.claude/fehlt.md`' '`.github/fehlt.yml`' '`docs/fehlt.md`' '`scripts/fehlt.sh`'
  erwarte docs/fall.md:1 pfad .claude/fehlt.md
  erwarte docs/fall.md:2 pfad .github/fehlt.yml
  erwarte docs/fall.md:3 pfad docs/fehlt.md
  erwarte docs/fall.md:4 pfad scripts/fehlt.sh
}
f_B033() {
  md '`README.md`' '`CONTRIBUTING.md`' '`.gitignore`'
  erwarte docs/fall.md:1 pfad README.md
  erwarte docs/fall.md:2 pfad CONTRIBUTING.md
  erwarte docs/fall.md:3 pfad .gitignore
}
f_B034() { md '`docs/ziel.md`' '`docs/adr`' '`docs/adr/`' '`./docs/ziel.md`' '`Makefile`' '`CLAUDE.md`'; }

# --- KB-08 Pruefung 4, verzeichnisrelativ --------------------------------------------
f_B035() {
  zeilen_an .claude/skills/skill-a/SKILL.md 'Siehe `references/fehlt.md`.'
  erwarte .claude/skills/skill-a/SKILL.md:8 pfad references/fehlt.md
}
f_B036() {
  zeilen_an docs/adr/0001-test.md 'Siehe `../fehlt.md`.'
  erwarte docs/adr/0001-test.md:4 pfad ../fehlt.md
}
f_B037() {
  zeilen .claude/skills/skill-a/references/x.md '# Referenz'
  zeilen_an .claude/skills/skill-a/SKILL.md 'Siehe `references/x.md`.'
}
f_B038() { zeilen_an docs/adr/0001-test.md 'Siehe `../ziel.md`.'; }

# --- KB-09 Pruefung 4, Gegenproben zu den Ausschlussregeln ----------------------------
f_B039() {
  md '`claude/fehlt.md`' '`docs/fehlt`' '`.claude/fehlt.md`' '`x/fehlt.md`' '`builds/x/fehlt.md`'
  erwarte docs/fall.md:1 pfad claude/fehlt.md
  erwarte docs/fall.md:2 pfad docs/fehlt
  erwarte docs/fall.md:3 pfad .claude/fehlt.md
  erwarte docs/fall.md:4 pfad x/fehlt.md
  erwarte docs/fall.md:5 pfad builds/x/fehlt.md
}
f_B040() {
  zeilen claude/x.md '# x'
  zeilen x/y.md '# y'
  zeilen builds/x/y.md '# y'
  md '`claude/x.md`' '`docs/adr`' '`.claude/agents/rolle-a.md`' '`x/y.md`' '`builds/x/y.md`'
}

# --- KB-10 Regel b, Scharfschaltung -----------------------------------------------------
f_B041() {
  mkdir -p "$BAUM/backend" || herstellung_fehler "mkdir backend"
  md '`backend/fehlt.py`'
  erwarte docs/fall.md:1 pfad backend/fehlt.py
}
f_B042() {
  mkdir -p "$BAUM/backend" "$BAUM/frontend" "$BAUM/deploy" "$BAUM/prototype" || herstellung_fehler "mkdir"
  md '`backend/fehlt.py`' '`frontend/fehlt.ts`' '`deploy/fehlt.yml`' '`prototype/fehlt.js`'
  erwarte docs/fall.md:1 pfad backend/fehlt.py
  erwarte docs/fall.md:2 pfad frontend/fehlt.ts
  erwarte docs/fall.md:3 pfad deploy/fehlt.yml
  erwarte docs/fall.md:4 pfad prototype/fehlt.js
}
f_B043() { md '`backend/fehlt.py`' '`frontend/fehlt.ts`' '`deploy/fehlt.yml`' '`prototype/fehlt.js`'; }

# --- KB-11 Regeln c und d, Archivstand ----------------------------------------------------
f_B044() {
  md '`methodik/fehlt.md`' '`nachweise/fehlt/`' '`sprints/fehlt.md`' '`r3coscrum/fehlt.md`' '`r3cosint/fehlt.md`'
  erwarte docs/fall.md:1 pfad methodik/fehlt.md
  erwarte docs/fall.md:2 pfad nachweise/fehlt/
  erwarte docs/fall.md:3 pfad sprints/fehlt.md
  erwarte docs/fall.md:4 pfad r3coscrum/fehlt.md
  erwarte docs/fall.md:5 pfad r3cosint/fehlt.md
}
f_B045() { md "\`${A_DATEI}\`" '`nachweise/.`' '`sprints/.`' "\`r3coscrum/${A_WURZEL}\`" '`r3cosint/CLAUDE.md`'; }
f_B046() {
  md '`r3coscrum/docs/ziel.md`' "\`r3cosint/${A_DATEI}\`"
  erwarte docs/fall.md:1 pfad r3coscrum/docs/ziel.md
  erwarte docs/fall.md:2 pfad "r3cosint/${A_DATEI}"
}

# --- Nachtraege zu KB-12 (B-201, B-202; P-12: Regel c greift am bereinigten Pfad nicht, Beurteilung an der Wurzel) ---
f_B201() { md '`methodik/../../ausserhalb.md`'; erwarte docs/fall.md:1 pfad methodik/../../ausserhalb.md; }
f_B202() { md '`methodik/../CLAUDE.md`'; }

# --- KB-12 Pfad ausserhalb und Verknuepfung -----------------------------------------------------
f_B047() {
  printf 'x\n' > "$FALL/ausserhalb.md" || herstellung_fehler "ausserhalb.md"
  zeilen NOTIZ.md 'Siehe `../ausserhalb.md` dazu.'
  erwarte NOTIZ.md:1 pfad ../ausserhalb.md
}
f_B048() {
  printf 'x\n' > "$FALL/ausserhalb.md" || herstellung_fehler "ausserhalb.md"
  md 'Siehe `docs/../../ausserhalb.md` dazu.'
  erwarte docs/fall.md:1 pfad docs/../../ausserhalb.md
}
f_B049() {
  ln -s adr "$BAUM/docs/lnk" || herstellung_fehler "ln lnk"
  md 'Siehe `docs/lnk/0001-test.md` dazu.'
  erwarte docs/fall.md:1 pfad-verknuepfung docs/lnk/0001-test.md
}
f_B050() {
  ln -s ziel.md "$BAUM/docs/ziel-link.txt" || herstellung_fehler "ln ziel-link"
  md 'Siehe `docs/ziel-link.txt` dazu.'
  erwarte docs/fall.md:1 pfad-verknuepfung docs/ziel-link.txt
}
f_B051() {
  zeilen scripts/ziel-mit-falschem-verweis.md 'Siehe `docs/fehlt-nicht-gelesen.md` dazu.'
  ln -s ../scripts/ziel-mit-falschem-verweis.md "$BAUM/docs/verknuepft.md" || herstellung_fehler "ln verknuepft"
  erwarte docs/verknuepft.md:0 pfad-verknuepfung docs/verknuepft.md
}
f_B052() { md '`docs/../CLAUDE.md`' '`./docs//ziel.md`'; }

# --- KB-13 Pruefung 5 -------------------------------------------------------------------------------
f_B053() {
  md 'Siehe Projektauftrag 9.9 zur Sache.' '' 'Nach (9.8) gilt dies.' '' 'Nach Abschnitt 9.7 gilt dies.'
  erwarte docs/fall.md:1 abschnitt 9.9
  erwarte docs/fall.md:3 abschnitt 9.8
  erwarte docs/fall.md:5 abschnitt 9.7
}
f_B054() { md 'Siehe Projektauftrag 1.1 zur Sache.' '' 'Nach (1.2) gilt dies.' '' 'Nach Abschnitt 5.4 gilt dies.'; }
f_B055() { md 'ADR 0002 nennt (9.8) und Abschnitt 9.7 dazu.'; }
f_B056() { md 'ADR 0002 nennt Projektauftrag 9.9 dazu.'; erwarte docs/fall.md:1 abschnitt 9.9; }

# --- KB-14 Pruefung 6 ---------------------------------------------------------------------------------
f_B057() {
  rolle_b 'skills:' '  - skill-fehlt'
  erwarte .claude/agents/rolle-b.md:5 skill skill-fehlt
}
f_B058() {
  zeilen .claude/skills/skill-leer/notiz.txt 'ohne SKILL.md'
  rolle_b 'skills:' '  - skill-leer'
  erwarte .claude/agents/rolle-b.md:5 skill skill-leer
}
f_B059() {
  zeilen .claude/agents/rolle-c.md '---' 'name: rolle-c' 'description: x' '---' '# Rolle C'
  zeilen .claude/agents/rolle-d.md '# Rolle ohne Frontmatter'
}
f_B060() { rolle_b 'skills:' '  - skill-a'; }
f_B061() { zeilen .claude/agents/unter/x.md '---' 'name: x' 'skills: [kaputt]' '---' '# X'; }

# --- KB-15 Pruefung 6, Form -----------------------------------------------------------------------------
f_B062() {
  rolle_b 'skills: [skill-a, skill-b]'
  erwarte .claude/agents/rolle-b.md:4 skill-form '[skill-a, skill-b]'
}
f_B063() {
  rolle_b 'skills: skill-a'
  erwarte .claude/agents/rolle-b.md:4 skill-form skill-a
}
f_B064() {
  rolle_b 'skills:'
  erwarte .claude/agents/rolle-b.md:4 skill-form leer
}
f_B065() {
  rolle_b 'skills:' '  - Skill_A' '  - ../skill-a'
  erwarte .claude/agents/rolle-b.md:5 skill-form Skill_A
  erwarte .claude/agents/rolle-b.md:6 skill-form ../skill-a
}
f_B066() {
  rolle_b 'skills:' '  - skill-a' 'skills:' '  - skill-a'
  erwarte .claude/agents/rolle-b.md:6 skill-form 'skills doppelt'
}
f_B067() { rolle_b 'skills:' '  - "skill-a"' '  - skill-a   ' '' '  - skill-a'; }
f_B068() { rolle_b 'skills:' '  - skill-a' 'tools: x' '  - skill-fehlt'; }
f_B069() { rolle_b 'tools:' '  skills: [kaputt]'; }

# --- KB-16 Pruefung 7 -------------------------------------------------------------------------------------
f_B070() {
  zeilen .claude/skills/skill-b/SKILL.md '# Skill B ohne Frontmatter'
  erwarte .claude/skills/skill-b/SKILL.md:1 skill-anforderung fehlt
}
f_B071() {
  skill_b
  erwarte .claude/skills/skill-b/SKILL.md:1 skill-anforderung fehlt
}
f_B072() {
  skill_b 'metadata:' '  autor: x'
  erwarte .claude/skills/skill-b/SKILL.md:1 skill-anforderung fehlt
}
f_B073() {
  skill_b 'metadata:' '  anforderung: R3-A-001, R3-B-002'
  erwarte .claude/skills/skill-b/SKILL.md:5 skill-anforderung 'R3-A-001, R3-B-002'
}
f_B074() {
  skill_b 'metadata:' '  anforderung: irgendwas'
  erwarte .claude/skills/skill-b/SKILL.md:5 skill-anforderung irgendwas
}
f_B075() {
  skill_b 'metadata:' '  anforderung: R3-A-001' '  anforderung: R3-B-002'
  erwarte .claude/skills/skill-b/SKILL.md:6 skill-anforderung 'anforderung doppelt'
}
f_B076() {
  skill_b 'metadata:' '  anforderung: R3-A-001' 'metadata:'
  erwarte .claude/skills/skill-b/SKILL.md:6 skill-anforderung 'metadata doppelt'
}
f_B077() {
  skill_b 'metadata:' '  anforderung: R3-Z-999'
  erwarte .claude/skills/skill-b/SKILL.md:5 anforderung R3-Z-999
  erwarte .claude/skills/skill-b/SKILL.md:5 skill-anforderung R3-Z-999
}
f_B078() {
  skill_n skill-b 'metadata:' '  anforderung: "R3-B-002"'
  skill_n skill-c 'metadata:' '  anforderung: R3-A-001   '
  skill_n skill-d 'metadata:' '  anforderung: R3-C-003'
}
f_B079() {
  zeilen .claude/skills/skill-a/unter/SKILL.md '# ohne Frontmatter'
  zeilen .claude/skills/SKILL.md '# ohne Frontmatter'
}

# --- KB-17 Frontmatter ---------------------------------------------------------------------------------------
f_B080() {
  zeilen .claude/agents/rolle-b.md '---' 'name: rolle-b' 'skills:' '  - skill-fehlt'
  erwarte .claude/agents/rolle-b.md:1 frontmatter 'nicht geschlossen'
}
f_B081() {
  zeilen .claude/skills/skill-b/SKILL.md '---' 'name: skill-b' 'metadata:' '  anforderung: R3-A-001'
  erwarte .claude/skills/skill-b/SKILL.md:1 frontmatter 'nicht geschlossen'
}
f_B082() {
  zeilen .claude/agents/rolle-b.md '---' 'name: rolle-b' 'skills:' '  - skill-a' '----' '# Rolle B'
  erwarte .claude/agents/rolle-b.md:1 frontmatter 'nicht geschlossen'
}
f_B083() {
  printf -- '---\r\nname: rolle-b\r\ndescription: x\r\nskills:\r\n  - skill-a\r\n---\r\n# Rolle B\r\n' | w .claude/agents/rolle-b.md
  printf -- '---\r\nname: skill-b\r\ndescription: x\r\nmetadata:\r\n  anforderung: R3-A-001\r\n---\r\n# Skill B\r\n' | w .claude/skills/skill-b/SKILL.md
}

# --- Nachtraege aus Punkt 11 (OF-11, OF-12, OF-13) -------------------------------------------------------------
f_B191() { rolle_b 'skills:' "  - 'skill-a'"; }
f_B192() {
  rolle_b 'skills:' "  - \"skill-a'"
  erwarte .claude/agents/rolle-b.md:5 skill-form "\"skill-a'"
}
f_B193() { skill_b 'metadata:' "  anforderung: 'R3-B-002'"; }
f_B194() {
  rolle_b 'skills:' '  - skill-fehlt' 'skills:' '  - skill-fehlt'
  erwarte .claude/agents/rolle-b.md:6 skill-form 'skills doppelt'
}
f_B195() {
  skill_b 'metadata:' '  anforderung: irgendwas' '  anforderung: nochmal'
  erwarte .claude/skills/skill-b/SKILL.md:6 skill-anforderung 'anforderung doppelt'
}
f_B196() {
  skill_b 'metadata:' '  anforderung: irgendwas' 'metadata:'
  erwarte .claude/skills/skill-b/SKILL.md:6 skill-anforderung 'metadata doppelt'
}
f_B197() {
  zeilen .claude/skills/skill-b/SKILL.md '---' 'name: skill-b' 'metadata:' '  anforderung: R3-Z-999' 'Siehe `docs/fehlt.md` hier.'
  erwarte .claude/skills/skill-b/SKILL.md:1 frontmatter 'nicht geschlossen'
  erwarte .claude/skills/skill-b/SKILL.md:4 anforderung R3-Z-999
  erwarte .claude/skills/skill-b/SKILL.md:5 pfad docs/fehlt.md
}

# =============================================================================
# 11b. Nachtraege waehrend B2 (B-205, B-208 bis B-213, B-215, B-216, B-219, B-220)
# =============================================================================
f_B205() { # P-11: das Merkmal ADR gilt je Absatz und ueberspannt keine Leerzeile
  md 'ADR 0002 nennt etwas dazu.' '' 'Nach (9.8) gilt dies.'
  erwarte docs/fall.md:3 abschnitt 9.8
}
f_B208() { # P-5, Probe von Regel b: backend ist eine Verknuepfung
  ln -s docs "$BAUM/backend" || herstellung_fehler "ln backend"
  md '`backend/fehlt.py`'
  erwarte docs/fall.md:1 pfad-verknuepfung backend/fehlt.py
}
f_B209() { rolle_b 'skills:' '  -skill-a'; erwarte .claude/agents/rolle-b.md:5 skill-form skill-a; }
f_B210() { rolle_b 'skills:' $'\t- skill-a'; erwarte .claude/agents/rolle-b.md:5 skill-form skill-a; }
f_B211() { rolle_b 'skills:' '- skill-a' $'-\tskill-a'; }
f_B212() { rolle_b 'skills:' '  - skill-a # Kommentar'; erwarte .claude/agents/rolle-b.md:5 skill-form 'skill-a # Kommentar'; }
f_B213() {
  skill_b 'metadata:' '  anforderung: R3-A-001 # Kommentar'
  erwarte .claude/skills/skill-b/SKILL.md:5 skill-anforderung 'R3-A-001 # Kommentar'
}
f_B215() { # P-6 Ergaenzung: N mit mehr als 9 Stellen gilt als groesser als jede Zeilenzahl
  md 'Siehe `docs/ziel.md:99999999999999999999` dazu.' 'Siehe `docs/ziel.md:1000000000` dazu.'
  erwarte docs/fall.md:1 zeile docs/ziel.md:99999999999999999999
  erwarte docs/fall.md:2 zeile docs/ziel.md:1000000000
}
f_B216() { md 'Mit Nullen `docs/ziel.md:0000000000000000000020` und `docs/ziel.md:000000000000000000001-0000000000000000000020`.'; }
f_B219() {
  md 'Siehe `docs/ziel.md:1-99999999999999999999` dazu.' 'Siehe `docs/ziel.md:99999999999999999999-1` dazu.'
  erwarte docs/fall.md:1 zeile docs/ziel.md:1-99999999999999999999
  erwarte docs/fall.md:2 zeile docs/ziel.md:99999999999999999999-1
}
f_B220() { # haengende Verknuepfung als Pruefflaechendatei: Befund, kein Lage C
  ln -s gibtsnicht.md "$BAUM/docs/haengt.md" || herstellung_fehler "ln haengt"
  erwarte docs/haengt.md:0 pfad-verknuepfung docs/haengt.md
}


# =============================================================================
# 12. Faelle KB-18 bis KB-24 (B-084 bis B-129, B-198, B-199)
# =============================================================================
AL="scripts/belege-ausnahmen.txt"   # Fundort der Ausnahmeliste

# --- KB-18 Ausblendung ---------------------------------------------------------------------------------
f_B084() { md 'Text vor dem Block.' "$BT" 'Inhalt' "$BT" 'Siehe `docs/fehlt.md` hier.'; erwarte docs/fall.md:5 pfad docs/fehlt.md; }
f_B085() { md 'Text.' "$BT" 'Inhalt' "   $BT" 'Siehe `docs/fehlt.md` hier.'; erwarte docs/fall.md:5 pfad docs/fehlt.md; }
f_B086() { md 'Text.' "$TL" "$BT" "$TL" 'Siehe `docs/fehlt.md` hier.'; erwarte docs/fall.md:5 pfad docs/fehlt.md; }
f_B087() { md 'Text.' "$BT" 'nur Text im offenen Block'; erwarte docs/fall.md:2 codeblock-offen "$BT"; }
f_B088() { md 'Text.' "$BT" 'Siehe `docs/fehlt.md` im Block.' "$BT" 'Ende.'; }
f_B089() { md 'Text.' "$TL" 'Siehe `docs/fehlt.md` im Block.' "$TL" 'Ende.'; }
f_B090() { md 'Text.' "   $BT" 'Siehe `docs/fehlt.md` im Block.' "   $BT" 'Ende.'; }
f_B091() { md 'Text.' '````' "$BT" 'Siehe `docs/fehlt.md` im Block.' "$BT" '````' 'Ende.'; }
f_B092() { md 'Text.' "$BT" "$TL" 'Siehe `docs/fehlt.md` im Block.' "$BT" 'Ende.'; }
f_B093() { md 'Text.' "$BT" "$BT kein Schluss" 'Siehe `docs/fehlt.md` im Block.' "$BT" 'Ende.'; }
f_B094() { md 'Text.' "$BT" 'Inhalt' '`````' 'Siehe `docs/fehlt.md` hier.'; erwarte docs/fall.md:5 pfad docs/fehlt.md; }
f_B095() { md 'Text.' '```bash' 'Siehe `docs/fehlt.md` im Block.' "$BT" 'Ende.'; }

# --- KB-19 Pruefflaeche ----------------------------------------------------------------------------------
f_B096() { zeilen NOTIZ.md 'Siehe `docs/fehlt.md` hier.'; erwarte NOTIZ.md:1 pfad docs/fehlt.md; }
f_B097() {
  zeilen docs/a/b/tief.md 'Siehe `docs/fehlt.md` hier.'
  zeilen .claude/x/y/tief.md 'Siehe `docs/fehlt.md` hier.'
  erwarte docs/a/b/tief.md:1 pfad docs/fehlt.md
  erwarte .claude/x/y/tief.md:1 pfad docs/fehlt.md
}
f_B098() {
  local name=$'docs/\303\274bersicht.md'
  zeilen "$name" 'Siehe `docs/fehlt.md` hier.'
  erwarte "${name}:1" pfad docs/fehlt.md
}
f_B099() { # leere Pruefflaeche: die Markdown-Dateien liegen im Arbeitsverzeichnis, aber nicht im Index
  kein_add
  g rm -r -q --cached docs .claude CLAUDE.md || herstellung_fehler "git rm --cached"
  erwarte '-:0' bestand-leer prueflaeche-leer
}
f_B100() { kein_add; zeilen NOTIZ.md 'Siehe `docs/fehlt.md` hier.'; }
f_B101() {
  zeilen scripts/notiz.md 'Siehe `docs/fehlt.md` hier.'
  zeilen prototype/notiz.md 'Siehe `docs/fehlt.md` hier.'
  zeilen backend/notiz.md 'Siehe `docs/fehlt.md` hier.'
  zeilen .github/notiz.md 'Siehe `docs/fehlt.md` hier.'
}
f_B198() { # leere Pruefflaeche, dazu eine Ausnahme -:0: keine Ausnahme kann bestand-leer decken, der Eintrag bleibt veraltet
  kein_add
  g rm -r -q --cached docs .claude CLAUDE.md || herstellung_fehler "git rm --cached"
  ausnahme '-:0' 'Beleg'
  erwarte '-:0' bestand-leer prueflaeche-leer
  erwarte "$AL:1" ausnahme-veraltet '-:0'
}

# --- KB-20 Ausnahme, Unterdrueckung ---------------------------------------------------------------------------
ausnahme_fall_md() { md 'Zeile eins.' 'Zeile zwei.' 'Siehe `docs/fehlt.md` hier.'; }   # der Verweis steht in Zeile 3
f_B102() { ausnahme_fall_md; ausnahme 'docs/fall.md:3' 'Beleg'; }
f_B103() { ausnahme_fall_md; ausnahme 'docs/fall.md|docs/fehlt.md' 'Beleg'; }
f_B104() {
  ausnahme_fall_md
  zeilen docs/andere.md 'Siehe `docs/fehlt.md` hier.'
  ausnahme 'docs/fall.md|docs/fehlt.md' 'Beleg'
  erwarte docs/andere.md:1 pfad docs/fehlt.md
}
f_B105() {
  ausnahme_fall_md
  ausnahme 'docs/fall.md:2' 'Beleg'
  erwarte docs/fall.md:3 pfad docs/fehlt.md
  erwarte "$AL:1" ausnahme-veraltet docs/fall.md:2
}
f_B106() {
  ausnahme_fall_md
  ausnahme 'docs/fall.md|docs/anders.md' 'Beleg'
  erwarte docs/fall.md:3 pfad docs/fehlt.md
  erwarte "$AL:1" ausnahme-veraltet 'docs/fall.md|docs/anders.md'
}

# --- KB-21 ausnahme-ohne-grund -----------------------------------------------------------------------------------
drei_zeilen() { md 'Zeile eins.' 'Zeile zwei.' 'Zeile drei.'; }
f_B107() { drei_zeilen; printf 'docs/fall.md:3\n' > "$BAUM/$AL"; erwarte "$AL:1" ausnahme-ohne-grund docs/fall.md:3; }
f_B108() { drei_zeilen; printf 'docs/fall.md:3\t\n' > "$BAUM/$AL"; erwarte "$AL:1" ausnahme-ohne-grund docs/fall.md:3; }
f_B109() { drei_zeilen; printf 'docs/fall.md:3\t   \n' > "$BAUM/$AL"; erwarte "$AL:1" ausnahme-ohne-grund docs/fall.md:3; }
f_B110() {
  drei_zeilen
  zeilen "$AL" '# Kommentar' '' '# noch ein Kommentar' 'docs/fall.md:3'
  erwarte "$AL:4" ausnahme-ohne-grund docs/fall.md:3
}
f_B111() {
  drei_zeilen
  printf 'docs/fall.md|docs/ziel.md\n' > "$BAUM/$AL"
  erwarte "$AL:1" ausnahme-ohne-grund 'docs/fall.md|docs/ziel.md'
}

# --- KB-22 ausnahme-form --------------------------------------------------------------------------------------------
f_B112() { ausnahme 'docs/fehlt.md' 'Beleg'; erwarte "$AL:1" ausnahme-form docs/fehlt.md; }
f_B113() { ausnahme 'docs/ziel.md' 'Beleg'; erwarte "$AL:1" ausnahme-form docs/ziel.md; }
f_B114() { drei_zeilen; ausnahme 'docs/fall.md:abc' 'Beleg'; erwarte "$AL:1" ausnahme-form docs/fall.md:abc; }
f_B115() { drei_zeilen; ausnahme 'docs/fall.md:123456' 'Beleg'; erwarte "$AL:1" ausnahme-veraltet docs/fall.md:123456; }

f_B200() { # sechsstellige Zeilennummer im Schluessel: formgerecht und benutzt (der Fund steht in Zeile 123456)
  # abwechselnd Text- und Leerzeilen: viele kurze Absaetze (ein einziger Absatz mit 123456 Zeilen braucht im heutigen Pruefer
  # wegen der Verkettung in der awk-Absatzbildung mehr als 60 s; gemessen am 2026-10-28, erster Entwurf dieses Falls)
  awk 'BEGIN { for (i = 1; i < 123456; i++) print (i % 2 ? "x" : ""); print "Siehe `docs/fehlt.md` hier." }' > "$BAUM/docs/lang.md" || herstellung_fehler "docs/lang.md"
  ausnahme 'docs/lang.md:123456' 'Beleg'
}

# --- KB-23 ausnahme-veraltet ---------------------------------------------------------------------------------------------
f_B116() {
  md 'Siehe R3-A-001 dazu.'
  ausnahme 'docs/fall.md|R3-A-001' 'Beleg'
  erwarte "$AL:1" ausnahme-veraltet 'docs/fall.md|R3-A-001'
}
f_B117() {
  md "Commit $GRUND_COMMIT dazu."
  ausnahme "docs/fall.md|$GRUND_COMMIT" 'Beleg'
  erwarte "$AL:1" ausnahme-veraltet "docs/fall.md|$GRUND_COMMIT"
}
f_B118() {
  md 'Siehe `docs/ziel.md` dazu.'
  ausnahme 'docs/fall.md|docs/ziel.md' 'Beleg'
  erwarte "$AL:1" ausnahme-veraltet 'docs/fall.md|docs/ziel.md'
}
f_B119() {
  zeilen .claude/skills/skill-a/references/x.md '# Referenz'
  zeilen_an .claude/skills/skill-a/SKILL.md 'Siehe `references/x.md`.'
  ausnahme '.claude/skills/skill-a/SKILL.md|references/x.md' 'Beleg'
  erwarte "$AL:1" ausnahme-veraltet '.claude/skills/skill-a/SKILL.md|references/x.md'
}
f_B120() {
  md "Siehe \`${A_DATEI}\` dazu."
  ausnahme "docs/fall.md|${A_DATEI}" 'Beleg'
  erwarte "$AL:1" ausnahme-veraltet "docs/fall.md|${A_DATEI}"
}
f_B121() {
  md 'Zeile eins.'
  ausnahme 'docs/gibtsnicht.md|docs/fehlt.md' 'Beleg'
  erwarte "$AL:1" ausnahme-veraltet 'docs/gibtsnicht.md|docs/fehlt.md'
}
f_B122() {
  zeilen scripts/notiz.md 'Siehe `docs/fehlt.md` hier.'
  ausnahme 'scripts/notiz.md|docs/fehlt.md' 'Beleg'
  erwarte "$AL:1" ausnahme-veraltet 'scripts/notiz.md|docs/fehlt.md'
}
f_B123() { drei_zeilen; ausnahme 'docs/fall.md:2' 'Beleg'; erwarte "$AL:1" ausnahme-veraltet docs/fall.md:2; }
f_B124() {
  ausnahme_fall_md
  ausnahme 'docs/fall.md:3' 'Beleg A'
  ausnahme 'docs/fall.md|docs/fehlt.md' 'Beleg B'
}
f_B199() { # eine Ausnahme kann keinen Befund der Ausnahmeliste decken
  ausnahme "$AL:1" 'Beleg'
  erwarte "$AL:1" ausnahme-veraltet "$AL:1"
}

# --- KB-24 Rueckgabewert und Zaehlung, Schlussausgabe ---------------------------------------------------------------------
f_B125() {
  md '`docs/fehlt-a.md`' '`docs/fehlt-b.md`' '`docs/ziel.md:99`' 'R3-Z-999' '0123456789abcdef0123456789abcdef01234567'
  erwarte docs/fall.md:1 pfad docs/fehlt-a.md
  erwarte docs/fall.md:2 pfad docs/fehlt-b.md
  erwarte docs/fall.md:3 zeile docs/ziel.md:99
  erwarte docs/fall.md:4 anforderung R3-Z-999
  erwarte docs/fall.md:5 commit 0123456789abcdef0123456789abcdef01234567
  ARTEN_PRUEFEN=1
}
UE=$'\303\274'   # ue-Umlaut, UTF-8
OE=$'\303\266'   # oe-Umlaut, UTF-8
f_B126() { AUSGABE_MIT+=("Repo B (r3coscrum): aufgel${OE}st ${UE}ber den Archivstand ${STAND} (Zweig archiv/r3coscrum)"); }
f_B127() { AUSGABE_OHNE_ERE+=("Nicht pr(${UE}|ue)fbar"); }
f_B128() { AUSGABE_OHNE+=("mitgelesen"); }
f_B129() { AUSGABE_OHNE+=("NICHT eingebaut"); }

# =============================================================================
# 11c. Nachtraege aus B3 und B4 (B-221 ff.): P-12 mit GB-28, Zahlenregeln im Archivstand, Vorrang des Wegs ohne
#      Verknuepfung (P-5), Eintraege und Verknuepfungen bei Pruefung 6
# =============================================================================
schreibweisen_vier_baeume() { # fuenf Schreibweisen, die Regel b erst nach der Bereinigung erkennt (P-12)
  md '`./backend/fehlt.py`' '`docs/../backend/fehlt.py`' '`./frontend/fehlt.ts`' '`docs/../deploy/fehlt.yml`' '`./prototype/fehlt.js`'
}
f_B221() { schreibweisen_vier_baeume; }
f_B222() {
  mkdir -p "$BAUM/backend" "$BAUM/frontend" "$BAUM/deploy" "$BAUM/prototype" || herstellung_fehler "mkdir"
  schreibweisen_vier_baeume
  erwarte docs/fall.md:1 pfad ./backend/fehlt.py
  erwarte docs/fall.md:2 pfad docs/../backend/fehlt.py
  erwarte docs/fall.md:3 pfad ./frontend/fehlt.ts
  erwarte docs/fall.md:4 pfad docs/../deploy/fehlt.yml
  erwarte docs/fall.md:5 pfad ./prototype/fehlt.js
}
f_B223() { # GB-28: erst verzeichnisrelativ in einen der vier Baeume (Fehlalarm, sichere Richtung)
  md '`../backend/fehlt.py`' '`../deploy/fehlt.yml`'
  erwarte docs/fall.md:1 pfad ../backend/fehlt.py
  erwarte docs/fall.md:2 pfad ../deploy/fehlt.yml
}
f_B224() { # P-12, Regel a am bereinigten Pfad
  md '`dist/../docs/fehlt.md`'
  erwarte docs/fall.md:1 pfad dist/../docs/fehlt.md
}
f_B225() { # P-12, Regeln c und d am bereinigten Pfad (Gegenprobe)
  md "\`./${A_DATEI}\`" "\`docs/../${A_DATEI}\`" "\`./r3coscrum/${A_WURZEL}\`" '`./r3cosint/CLAUDE.md`'
}
f_B226() { # S-4 mit den Zahlenregeln von P-6 im Archivstand
  md "\`${A_DATEI}:0\`" "\`${A_DATEI}:5-2\`" "\`${A_DATEI}:99999999999999999999\`" "\`${A_DATEI}:1-$((A_ZEILEN + 1))\`"
  erwarte docs/fall.md:1 zeile "${A_DATEI}:0"
  erwarte docs/fall.md:2 zeile "${A_DATEI}:5-2"
  erwarte docs/fall.md:3 zeile "${A_DATEI}:99999999999999999999"
  erwarte docs/fall.md:4 zeile "${A_DATEI}:1-$((A_ZEILEN + 1))"
}
f_B227() { # S-4, Regel d: Praefix r3coscrum/ an einem Verzeichnis des Archivstands
  md '`r3coscrum/.github:2`'
  erwarte docs/fall.md:1 zeile r3coscrum/.github:2
}
f_B228() { # P-5: besteht ein Kandidat ohne Verknuepfung, geht er vor (die Wurzel ist die Verknuepfung, docs/Makefile die Datei)
  rm -f "$BAUM/Makefile" || herstellung_fehler "rm Makefile"
  ln -s docs/ziel.md "$BAUM/Makefile" || herstellung_fehler "ln Makefile"
  printf 'all:\n' | w docs/Makefile
  md '`Makefile`'
}
f_B229() { # P-5 umgekehrt: die Wurzel ist die Datei, docs/Makefile die Verknuepfung
  ln -s ../Makefile "$BAUM/docs/Makefile" || herstellung_fehler "ln docs/Makefile"
  md '`Makefile`'
}
f_B230() { # F4: Bindestrich ohne Namen (Wert "leer", nicht leer)
  rolle_b 'skills:' '  -'
  erwarte .claude/agents/rolle-b.md:5 skill-form leer
}
f_B231() { # P-5: das Skill-Verzeichnis ist eine Verknuepfung
  ln -s skill-a "$BAUM/.claude/skills/skill-l" || herstellung_fehler "ln skill-l"
  rolle_b 'skills:' '  - skill-l'
  erwarte .claude/agents/rolle-b.md:5 pfad-verknuepfung .claude/skills/skill-l/SKILL.md
}

# =============================================================================
# 11d. Nachtraege aus B5 (B-232 bis B-241): Wert "leer", Kommentarzeilen in der Liste skills: und im Block metadata:,
#      Grenzen GB-29 (BOM) und GB-30 (Zeilenenden nur aus Wagenruecklauf), Schlussausgabe nennt die Grenzen
# =============================================================================
f_B232() { # Pruefung 7: leere anforderung (zwei Formen) ergibt skill-anforderung "leer", unterscheidbar von "fehlt"
  skill_n skill-b 'metadata:' '  anforderung: ""'
  skill_n skill-c 'metadata:' '  anforderung:   '
  erwarte .claude/skills/skill-b/SKILL.md:5 skill-anforderung leer
  erwarte .claude/skills/skill-c/SKILL.md:5 skill-anforderung leer
}
f_B233() { # Pruefung 6: Kommentarzeilen (ohne und mit Einzug) beenden die Liste nicht; der Name dahinter wird geprueft
  rolle_b 'skills:' '# Kommentar ohne Einzug' '  - skill-a' '  # Kommentar mit Einzug' '  - skill-fehlt'
  erwarte .claude/agents/rolle-b.md:8 skill skill-fehlt
}
f_B234() { rolle_b 'skills:' '# Kommentar' '  - skill-a' '  # Kommentar' '  - skill-a'; }   # Gegenprobe: gueltige Namen hinter Kommentarzeilen
f_B235() { # Pruefung 7: eine Kommentarzeile ohne Einzug beendet den Block metadata: nicht
  skill_b 'metadata:' '# Kommentar ohne Einzug' '  anforderung: kaputt'
  erwarte .claude/skills/skill-b/SKILL.md:6 skill-anforderung kaputt
}
f_B236() { skill_b 'metadata:' '# Kommentar' '  # eingerueckter Kommentar' '  anforderung: R3-A-001'; }   # Gegenprobe
f_B237() { # GB-29 Durchlass: BOM vor dem Frontmatter einer Rollendatei; sie gilt als ohne Frontmatter, der ungueltige Eintrag bleibt ohne Befund
  printf '\357\273\277---\nname: rolle-b\ndescription: x\nskills: [kaputt]\n---\n# Rolle B\n' | w .claude/agents/rolle-b.md
}
f_B238() { # GB-29 Fehlalarm: BOM vor dem Frontmatter einer SKILL.md ergibt skill-anforderung "fehlt"
  printf '\357\273\277---\nname: skill-b\ndescription: x\nmetadata:\n  anforderung: R3-A-001\n---\n# Skill B\n' | w .claude/skills/skill-b/SKILL.md
  erwarte .claude/skills/skill-b/SKILL.md:1 skill-anforderung fehlt
}
f_B239() { # GB-30 Durchlass: Zeilenenden nur aus Wagenruecklauf in einer Rollendatei; eine Zeile, kein Frontmatter, ungueltiger Eintrag ohne Befund
  printf -- '---\rname: rolle-b\rdescription: x\rskills: [kaputt]\r---\r# Rolle B\r' | w .claude/agents/rolle-b.md
}
f_B240() { # GB-30 Fehlalarm: Zeilenenden nur aus Wagenruecklauf in einer SKILL.md ergeben skill-anforderung "fehlt"
  printf -- '---\rname: skill-b\rdescription: x\rmetadata:\r  anforderung: R3-A-001\r---\r# Skill B\r' | w .claude/skills/skill-b/SKILL.md
  erwarte .claude/skills/skill-b/SKILL.md:1 skill-anforderung fehlt
}
f_B241() { SCHLUSS_GB=1; }   # Punkt 8: die Schlussausgabe nennt jede Grenze GB des Kopfkommentars einzeln, und nur diese, und verweist auf ihn

# =============================================================================
# 11e. Faelle aus M5 (B-242 bis B-276): Behebungen nach der Pruefung B9/M2 (ST-G0-01 bis ST-G0-24)
#      Verknuepfungen auf dem Weg zu den Dateien, die der Pruefer liest (B-242 bis B-247), Dateien der Form
#      bezeichner=wert.md (B-248), Lesefehler ueber Huellen im Werkzeugkasten (B-249 bis B-257), Zaun mit
#      Rueckwaertsakzent in der Sprachangabe (B-258, B-259), Fernquelle mit promisor (B-260 bis B-262), git-Variablen und
#      alternates (B-263 bis B-269), Grenzen GB-31 bis GB-35 (B-270 bis B-275), Zeile nur aus Leerraum (B-276)
# =============================================================================
LC_WEG_ERSETZEN="durch die Datei selbst ersetzen"
aussen() { mkdir -p "$FALL/aussen" || herstellung_fehler "Verzeichnis aussen"; }   # Ziele ausserhalb des Baums
ersetze_durch_verknuepfung() { # ersetze_durch_verknuepfung <pfad im Baum> <ziel> : der Pfad wird eine Verknuepfung auf <ziel>
  local pfad="${1:?}" ziel="${2:?}"
  rm -rf "${BAUM:?}/${pfad:?}" && ln -s "$ziel" "$BAUM/$pfad" || herstellung_fehler "Verknuepfung $pfad"
}

# --- ST-G0-01 a, b: Verknuepfung auf dem Weg zu Backlog, Projektauftrag und Ausnahmeliste (KC-06 bis KC-08) ---------------
f_B242() { # der Backlog ist eine Verknuepfung auf eine Datei ausserhalb; das Ziel traegt eine Ueberschrift mehr
  aussen
  cp "$BAUM/docs/05_Product_Backlog.md" "$FALL/aussen/backlog.md" && printf '\n### R3-Z-999 Nur im Ziel\n' >> "$FALL/aussen/backlog.md" || herstellung_fehler "Ziel des Backlogs"
  md 'Siehe R3-Z-999 dazu.'
  ersetze_durch_verknuepfung docs/05_Product_Backlog.md "$FALL/aussen/backlog.md"
  LC_KENNUNG="docs/05_Product_Backlog.md"; LC_WEG_F="$LC_WEG_ERSETZEN"; LC_NICHT=("referenzmenge")
}
f_B243() { # das Verzeichnis docs/ auf dem Weg zum Backlog ist eine Verknuepfung (Index bleibt, wie er war)
  kein_add
  g add -A || herstellung_fehler "git add"
  cp -a "$BAUM/docs" "$FALL/docs-ziel" || herstellung_fehler "Kopie docs"
  ersetze_durch_verknuepfung docs "$FALL/docs-ziel"
  LC_KENNUNG="docs/05_Product_Backlog.md"; LC_WEG_F="$LC_WEG_ERSETZEN"; LC_NICHT=("referenzmenge")
}
f_B244() { # der Projektauftrag ist eine Verknuepfung auf eine Datei ausserhalb; das Ziel traegt die Ueberschrift 9.9 mehr
  aussen
  cp "$BAUM/docs/00_Projektauftrag.md" "$FALL/aussen/projektauftrag.md" && printf '\n## 9.9 Nur im Ziel\n' >> "$FALL/aussen/projektauftrag.md" || herstellung_fehler "Ziel des Projektauftrags"
  md 'Siehe Projektauftrag 9.9 dazu.'
  ersetze_durch_verknuepfung docs/00_Projektauftrag.md "$FALL/aussen/projektauftrag.md"
  LC_KENNUNG="docs/00_Projektauftrag.md"; LC_WEG_F="$LC_WEG_ERSETZEN"; LC_NICHT=("referenzmenge")
}
f_B245() { # die Ausnahmeliste ist eine Verknuepfung auf eine Datei ausserhalb, deren Eintrag einen Fund deckt
  aussen
  md 'Siehe `docs/fehlt.md` hier.'
  printf 'docs/fall.md|docs/fehlt.md\tBeleg\n' > "$FALL/aussen/ausnahmen.txt" || herstellung_fehler "Ziel der Ausnahmeliste"
  ersetze_durch_verknuepfung "$AL" "$FALL/aussen/ausnahmen.txt"
  LC_KENNUNG="scripts/belege-ausnahmen.txt"; LC_WEG_F="$LC_WEG_ERSETZEN"
}
f_B246() { # das Verzeichnis scripts/ auf dem Weg zur Ausnahmeliste ist eine Verknuepfung
  kein_add
  g add -A || herstellung_fehler "git add"
  cp -a "$BAUM/scripts" "$FALL/scripts-ziel" || herstellung_fehler "Kopie scripts"
  ersetze_durch_verknuepfung scripts "$FALL/scripts-ziel"
  LC_KENNUNG="scripts/belege-ausnahmen.txt"; LC_WEG_F="$LC_WEG_ERSETZEN"
}

# --- ST-G0-01 c: Verzeichnis ueber einer Datei der Pruefflaeche ist im Arbeitsbaum eine Verknuepfung -----------------------
f_B247() { # docs/sub/x.md: Ziel hat eine gleichnamige Datei mit falschem Verweis; docs/sub2/y.md: haengende Verknuepfung
  aussen
  zeilen docs/sub/x.md 'Siehe `docs/fehlt.md` hier.'
  zeilen docs/sub2/y.md 'Siehe `docs/fehlt.md` hier.'
  g add -A || herstellung_fehler "git add"
  kein_add
  mkdir -p "$FALL/aussen/sub" && printf 'Siehe `docs/fehlt-im-ziel.md` hier.\n' > "$FALL/aussen/sub/x.md" || herstellung_fehler "Ziel von docs/sub"
  ersetze_durch_verknuepfung docs/sub "$FALL/aussen/sub"
  ersetze_durch_verknuepfung docs/sub2 "$FALL/aussen/gibtsnicht"
  erwarte docs/sub/x.md:0 pfad-verknuepfung docs/sub/x.md
  erwarte docs/sub2/y.md:0 pfad-verknuepfung docs/sub2/y.md
}

# --- ST-G0-02, ST-G0-29: Dateien der Form bezeichner=wert.md gehen mit ./ an awk (sonst eine Zuweisung); -x.md ist die Gegenprobe -------------------------
f_B248() {
  zeilen 'a=b.md' 'Siehe `docs/fehlt.md` hier.' "$BT" 'offener Block'
  zeilen '-x.md' 'Siehe `docs/fehlt.md` hier.' "$BT" 'offener Block'
  erwarte 'a=b.md:1' pfad docs/fehlt.md
  erwarte 'a=b.md:2' codeblock-offen "$BT"
  erwarte '-x.md:1' pfad docs/fehlt.md
  erwarte '-x.md:2' codeblock-offen "$BT"
}

# --- ST-G0-03: Lesefehler von awk und grep sind Lage C (KC-11), nie "kein Fund" ----------------------------------------------
# Werkzeugkasten mit Huellen: PATH enthaelt die Werkzeuge der geschlossenen Liste als Verknuepfungen, die genannten als Huelle
# um das echte Werkzeug. Die Huelle endet mit 2 (simulierter Lesefehler), wenn die Standardeingabe oder eine Datei unter ihren
# Operanden die Marke traegt und die Operanden die Nadel nennen; sonst reicht sie Operanden und Eingabe unveraendert weiter.
HUELLE_MARKE="PM-HUELLE-LESEFEHLER"
huellen_kasten() { # huellen_kasten <werkzeug> <nadel> [<werkzeug> <nadel>]...
  local box="$FALL/kasten-huelle" t p
  local -A nadel=()
  mkdir -p "$box" || herstellung_fehler "Huellenkasten"
  while [ $# -ge 2 ]; do nadel[$1]="$2"; shift 2; done
  for t in $KC01_KASTEN; do
    p=$(command -v "$t") || herstellung_fehler "Werkzeug $t nicht aufloesbar"
    if [ -n "${nadel[$t]+x}" ]; then
      {
        printf '#!%s\n' "$BASH_BIN"
        printf 'echt=%q\nmarke=%q\nnadel=%q\n' "$p" "$HUELLE_MARKE" "${nadel[$t]}"
        cat <<'HUELLE'
ein=""
IFS= read -r -d '' ein || true
treffer=0
case "$ein" in *"$marke"*) treffer=1 ;; esac
for a in "$@"; do
  if [ -f "$a" ]; then
    while IFS= read -r z || [ -n "$z" ]; do
      case "$z" in *"$marke"*) treffer=1 ;; esac
    done < "$a"
  fi
done
case "$*" in *"$nadel"*) ;; *) treffer=0 ;; esac
if [ "$treffer" = 1 ]; then echo "huelle: simulierter Lesefehler" >&2; exit 2; fi
printf '%s' "$ein" | exec "$echt" "$@"
HUELLE
      } > "$box/$t" || herstellung_fehler "Huelle $t"
      chmod +x "$box/$t" || herstellung_fehler "chmod Huelle $t"
    else
      ln -s "$p" "$box/$t" || herstellung_fehler "Verknuepfung $t"
    fi
  done
  KASTEN="$box"
  ENV_ZUSATZ=("PATH=$KASTEN")
}
marke_zeile() { printf 'Zeile mit %s darin.' "$HUELLE_MARKE"; }
lesefehler_erwarten() { LC_KENNUNG="prueflaeche"; LC_MIT=("$1"); LC_NICHT=("Befunde"); }
f_B249() { md "$(marke_zeile)"; huellen_kasten awk 'modus=text'; lesefehler_erwarten docs/fall.md; }     # Ausblendung der Codebloecke
f_B250() { md "$(marke_zeile)"; huellen_kasten awk 'modus=offen'; lesefehler_erwarten docs/fall.md; }    # Suche des offenen Zauns
f_B251() { rolle_b "# $HUELLE_MARKE"; huellen_kasten awk 'modus=rolle'; lesefehler_erwarten .claude/agents/rolle-b.md; }   # Frontmatter
f_B252() { md "$(marke_zeile)"; huellen_kasten grep '`[^`]+`'; lesefehler_erwarten docs/fall.md; }       # Auszug Pruefung 4
f_B253() { md "$(marke_zeile)"; huellen_kasten grep 'R3-[A-Z]-[0-9]{3}'; lesefehler_erwarten docs/fall.md; }   # Auszug Pruefung 3
f_B254() { md "$(marke_zeile)"; huellen_kasten grep '\b[0-9a-f]{40}\b'; lesefehler_erwarten docs/fall.md; }   # Auszug Pruefung 2, Commit
f_B255() { md "$(marke_zeile)"; huellen_kasten grep '(blob|tree)/main'; lesefehler_erwarten docs/fall.md; }   # Auszug Pruefung 2, blob und tree
f_B256() { md "$(marke_zeile)"; huellen_kasten grep 'Projektauftrag[[:space:]]+[0-9]+\.[0-9]+'; lesefehler_erwarten docs/fall.md; }   # Auszug Pruefung 5
f_B257() { # Gegenprobe: Huellen um awk und grep ohne markierte Eingabe sind durchlaessig, der falsche Verweis wird gefunden
  md 'Siehe `docs/fehlt.md` hier.'
  huellen_kasten awk 'modus=' grep '[0-9]'
  erwarte docs/fall.md:1 pfad docs/fehlt.md
}

# --- ST-G0-05: Zaun aus Rueckwaertsakzenten mit Rueckwaertsakzent in der Sprachangabe ist kein Zaun ---------------------------
f_B258() { md 'Text.' '```a`b' 'Siehe `docs/fehlt.md` hier.' '```text' 'Inhalt' "$BT"; erwarte docs/fall.md:3 pfad docs/fehlt.md; }
f_B259() { md 'Text.' '~~~a~b' 'Siehe `docs/fehlt.md` im Block.' "$TL" 'Ende.'; }   # Gegenprobe: Tilden unveraendert

# --- ST-G0-07: Fernquelle mit promisor wahr (KC-04) --------------------------------------------------------------------------
f_B260() { # lokale Ebene, Name der Fernquelle mit Punkt
  kein_add
  g add -A || herstellung_fehler "git add"
  g config remote.fremd.quelle.url "$FALL/gibtsnicht" && g config remote.fremd.quelle.promisor true || herstellung_fehler "git config"
  LC_KENNUNG="git-teilklon"; LC_WEG_ERE="vollst(ae|${AE})ndig"; LC_NICHT=("archivstand")
}
f_B261() { # globale Ebene (GIT_CONFIG_GLOBAL des Aufrufers)
  kein_add
  g add -A || herstellung_fehler "git add"
  printf '[remote "fremd"]\n\turl = %s\n\tpromisor = true\n' "$FALL/gibtsnicht" > "$FALL/global.cfg" || herstellung_fehler "global.cfg"
  ENV_ZUSATZ=("GIT_CONFIG_GLOBAL=$FALL/global.cfg")
  LC_KENNUNG="git-teilklon"; LC_WEG_ERE="vollst(ae|${AE})ndig"; LC_NICHT=("archivstand")
}
f_B262() { # Gegenprobe: promisor falsch
  kein_add
  g add -A || herstellung_fehler "git add"
  g config remote.fremd.url "$FALL/gibtsnicht" && g config remote.fremd.promisor false || herstellung_fehler "git config"
}

# --- ST-G0-08: git-Variablen des Aufrufers (EB-3) und objects/info/alternates (KC-12) ----------------------------------------
fremdes_repo() { # legt $FALL/fremd an (eigenes Repository mit einem Commit); setzt FREMD_COMMIT und FREMD_OBJEKTE
  mkdir -p "$FALL/fremd" || herstellung_fehler "Verzeichnis fremd"
  gitg -C "$FALL/fremd" init -q || herstellung_fehler "git init fremd"
  printf 'x\n' > "$FALL/fremd/x.txt" || herstellung_fehler "x.txt"
  gitg -C "$FALL/fremd" add -A && gitg -C "$FALL/fremd" commit -q -m fremd || herstellung_fehler "Commit im fremden Repository"
  FREMD_COMMIT=$(gitg -C "$FALL/fremd" rev-parse HEAD) || herstellung_fehler "rev-parse fremd"
  FREMD_OBJEKTE="$FALL/fremd/.git/objects"
}
f_B263() { # Lauf ohne Variablen gegen Lauf mit GIT_ALTERNATE_OBJECT_DIRECTORIES auf einen fremden Objektspeicher mit dem genannten Commit
  fremdes_repo
  md "Commit $FREMD_COMMIT dazu."
  AUSGABE_MIT+=("docs/fall.md:1"$'\t'"commit"$'\t'"$FREMD_COMMIT")
  ENV_ZUSATZ2=("GIT_ALTERNATE_OBJECT_DIRECTORIES=$FREMD_OBJEKTE")
}
f_B264() { # Lauf ohne Variablen gegen Lauf mit GIT_DIR auf ein anderes Repository
  fremdes_repo
  md "Commit $FREMD_COMMIT dazu."
  AUSGABE_MIT+=("docs/fall.md:1"$'\t'"commit"$'\t'"$FREMD_COMMIT")
  ENV_ZUSATZ2=("GIT_DIR=$FALL/fremd/.git")
}
f_B265() { # objects/info/alternates mit dem Pfad eines fremden Objektspeichers
  fremdes_repo
  kein_add
  g add -A || herstellung_fehler "git add"
  printf '%s\n' "$FREMD_OBJEKTE" > "$BAUM/.git/objects/info/alternates" || herstellung_fehler "alternates"
  LC_KENNUNG="git-alternates"; LC_WEG_F="git repack -a -d"
}
f_B266() { # dasselbe bei einem .git als Datei (gitdir:-Verweis)
  fremdes_repo
  kein_add
  g add -A || herstellung_fehler "git add"
  cp -a "$BAUM/.git" "$FALL/gitdir-extern" && rm -rf "${BAUM:?}/.git" && printf 'gitdir: %s\n' "$FALL/gitdir-extern" > "$BAUM/.git" || herstellung_fehler "gitdir-Verweis"
  printf '%s\n' "$FREMD_OBJEKTE" > "$FALL/gitdir-extern/objects/info/alternates" || herstellung_fehler "alternates"
  LC_KENNUNG="git-alternates"; LC_WEG_F="git repack -a -d"
}
f_B267() { # Gegenprobe: alternates vorhanden und leer
  kein_add
  g add -A || herstellung_fehler "git add"
  : > "$BAUM/.git/objects/info/alternates" || herstellung_fehler "alternates"
}
f_B268() { # zwei Maengel: Teilklon und alternates; gemeldet wird der Teilklon
  fremdes_repo
  teilklon_machen
  printf '%s\n' "$FREMD_OBJEKTE" > "$BAUM/.git/objects/info/alternates" || herstellung_fehler "alternates"
  LC_KENNUNG="git-teilklon"; LC_NICHT=("git-alternates"); LC_WEG_ERE="vollst(ae|${AE})ndig"
}
f_B269() { # zwei Maengel: alternates und Grundbaum ohne die Objekte des Archivstands; gemeldet wird alternates
  fremdes_repo
  basis_ohne_archiv
  printf '%s\n' "$FREMD_OBJEKTE" > "$BAUM/.git/objects/info/alternates" || herstellung_fehler "alternates"
  LC_KENNUNG="git-alternates"; LC_NICHT=("archivstand"); LC_WEG_F="git repack -a -d"
}

# --- Grenzen GB-31 bis GB-35 und ST-G0-20 --------------------------------------------------------------------------------------
f_B270() { # GB-31 (Durchlass): die Ueberschrift 9.9 steht nur in einem Codeblock des Projektauftrags
  zeilen_an docs/00_Projektauftrag.md '' "$BT" '## 9.9 Nur im Codeblock' "$BT"
  md 'Siehe Projektauftrag 9.9 dazu.'
}
f_B271() { # GB-31 (Durchlass): die eigene Ueberschrift 8.8 der nennenden Datei steht nur in einem Codeblock
  md "$BT" '## 8.8 Eigene Ueberschrift' "$BT" 'Siehe (8.8) im Text.'
}
f_B272() { # GB-32 (Eigenschaft): Dateiname mit Zeilenumbruch; "Befunde: n" zaehlt die Funde, nicht die Zeilen
  zeilen $'docs/a\nb.md' 'Siehe `docs/fehlt.md` hier.'
  ZN_BEFUNDE=1; ZN_ZEILEN=2
  ERW+=("docs/a")
  ERW+=($'b.md:1\tpfad\tdocs/fehlt.md')
}
timeout_aufrufe_in() { # Text auf der Standardeingabe; Ausgabe: Zeilennummer, Tabulator, Zeile (ausserhalb von Kommentarzeilen)
  awk '/^[[:space:]]*#/ {next} {print NR "\t" $0}' | grep -E '(^|[^A-Za-z0-9_.-])timeout([^A-Za-z0-9_.-]|$)'
}
f_B273() { # GB-33 (Eigenschaft, statisch): ausserhalb von Kommentarzeilen ruft der Pruefer kein timeout auf
  local treffer probe gelesen
  STAT_SOLL="ausserhalb von Kommentarzeilen ruft der Pruefer kein timeout auf (Probe der Pruefung: Zeilen 3 und 4)"
  probe=$'echo a\n# timeout im Kommentar\ntimeout 5 x\n  command timeout\n'
  gelesen=$(printf '%s' "$probe" | timeout_aufrufe_in | cut -f1 | tr '\n' ' ')
  treffer=$(timeout_aufrufe_in < "$PRUEFER")
  if [ "$gelesen" != "3 4 " ]; then
    STAT_OK=0; STAT_IST="die Pruefung trifft in der Probe '$gelesen' statt '3 4 '"
  elif [ -z "$treffer" ]; then
    STAT_OK=1; STAT_IST="kein Treffer (Probe der Pruefung gelesen: $gelesen)"
  else
    STAT_OK=0; STAT_IST="$(printf '%s\n' "$treffer" | awk 'END{print NR}') Treffer, erster: $(printf '%s\n' "$treffer" | head -n 1 | cut -c1-110)"
  fi
}
f_B274() { # GB-34 (Durchlass): .MD, .Md und .markdown gehoeren nicht zur Pruefflaeche
  zeilen docs/gross.MD 'Siehe `docs/fehlt.md` hier.'
  zeilen docs/gemischt.Md 'Siehe `docs/fehlt.md` hier.'
  zeilen docs/lang.markdown 'Siehe `docs/fehlt.md` hier.'
}
f_B275() { # GB-35 (Fehlalarm): Regel b gilt nach dem Abtrennen des Praefixes r3cosint/ nicht
  md '`r3cosint/backend/fehlt.py`' '`r3cosint/frontend/fehlt.ts`' '`r3cosint/deploy/fehlt.yml`' '`r3cosint/prototype/fehlt.js`'
  erwarte docs/fall.md:1 pfad r3cosint/backend/fehlt.py
  erwarte docs/fall.md:2 pfad r3cosint/frontend/fehlt.ts
  erwarte docs/fall.md:3 pfad r3cosint/deploy/fehlt.yml
  erwarte docs/fall.md:4 pfad r3cosint/prototype/fehlt.js
}
f_B276() { # ST-G0-20: eine Zeile nur aus Leerraum in der Ausnahmeliste ist ausnahme-form (Leerzeichen; Tabulator)
  printf '   \n\t\n' > "$BAUM/$AL" || herstellung_fehler "Ausnahmeliste"
  erwarte "$AL:1" ausnahme-form '   '
  erwarte "$AL:2" ausnahme-form ''
}

# =============================================================================
# 11f. Faelle aus M5b (B-277 bis B-306): Behebung der Befunde der Fremdmutationsrunde M4 (Punkt 13, Plan Nr. 1 bis 15)
#      Festlegung gegen das Muster "je Regel ein Vertreter": Eine Regel, die eine Liste oder Menge fuehrt, hat einen Fall je
#      Mitglied; eine Regel, die Vorkommen sucht, hat einen Fall mit einem zweiten Vorkommen hinter einem gueltigen; misst ein
#      bestehender Fall ein Mitglied schon, genuegt er. Was sich so nicht messen laesst, ist Grenze des Pruefmittels (GP-B7, GP-B8, GP-B10).
#      Nr. 1 B-277 bis B-283 | Nr. 2 B-284 bis B-288 | Nr. 3 B-289 | Nr. 4 B-290 | Nr. 5 B-291 | Nr. 6 B-292, B-293 |
#      Nr. 7 B-294, B-295 | Nr. 8 B-296, B-297 | Nr. 9 B-298, B-299 | Nr. 10 B-300, B-301 | Nr. 11 B-302, B-303 (c: B-266) |
#      Nr. 12 B-184, B-185 | Nr. 13 B-304 | Nr. 14 B-305 | Nr. 15 B-306
# =============================================================================

# --- Nr. 1 (DT-G0-M4-01): jedes Mitglied der Liste des eigenen Baums (GB-09); docs misst B-039 --------------------------------
# Ein Verweis aus zwei Segmenten auf ein fehlendes Ziel, zweites Segment ohne Punkt; fuer prototype, backend, frontend und deploy
# mit bestehendem leerem Verzeichnis, sonst gilt Regel b statt GB-09.
f_B277() { md '`.claude/fehlt`'; erwarte docs/fall.md:1 pfad .claude/fehlt; }
f_B278() { md '`.github/fehlt`'; erwarte docs/fall.md:1 pfad .github/fehlt; }
f_B279() { md '`scripts/fehlt`'; erwarte docs/fall.md:1 pfad scripts/fehlt; }
leeres_verzeichnis() { mkdir -p "$BAUM/$1" || herstellung_fehler "mkdir $1"; }
f_B280() { leeres_verzeichnis prototype; md '`prototype/fehlt`'; erwarte docs/fall.md:1 pfad prototype/fehlt; }
f_B281() { leeres_verzeichnis backend; md '`backend/fehlt`'; erwarte docs/fall.md:1 pfad backend/fehlt; }
f_B282() { leeres_verzeichnis frontend; md '`frontend/fehlt`'; erwarte docs/fall.md:1 pfad frontend/fehlt; }
f_B283() { leeres_verzeichnis deploy; md '`deploy/fehlt`'; erwarte docs/fall.md:1 pfad deploy/fehlt; }

# --- Nr. 2 (DT-G0-M4-02): je Auszug ein gueltiges Vorkommen, dahinter ein falsches in derselben und in der folgenden Zeile ------
f_B284() { # Pruefung 2: Commit des Grundbaums, dann eine Pruefsumme ohne Objekt
  md "Stand $GRUND_COMMIT, danach falsch 0123456789abcdef0123456789abcdef01234567." 'Falsch 89abcdef0123456789abcdef0123456789abcdef.'
  erwarte docs/fall.md:1 commit 0123456789abcdef0123456789abcdef01234567
  erwarte docs/fall.md:2 commit 89abcdef0123456789abcdef0123456789abcdef
}
f_B285() { # Pruefung 3: Kennung mit Ueberschrift, dann ohne
  md 'Siehe R3-A-001 und R3-Z-999.' 'Siehe R3-Z-998.'
  erwarte docs/fall.md:1 anforderung R3-Z-999
  erwarte docs/fall.md:2 anforderung R3-Z-998
}
f_B286() { # Pruefungen 1 und 4: vorhandenes, dann fehlendes Ziel, mit und ohne Zeilenanhang
  md '`docs/ziel.md` und `docs/fehlt-a.md`' '`docs/fehlt-b.md`' '`docs/ziel.md:5` und `docs/ziel.md:99`' '`docs/ziel.md:98`'
  erwarte docs/fall.md:1 pfad docs/fehlt-a.md
  erwarte docs/fall.md:2 pfad docs/fehlt-b.md
  erwarte docs/fall.md:3 zeile docs/ziel.md:99
  erwarte docs/fall.md:4 zeile docs/ziel.md:98
}
f_B287() { # Pruefung 5: vorhandene, dann fehlende Nummer in den drei Formen (je Zeile ein Absatz, kein Wort ADR)
  md 'Projektauftrag 1.1 und Projektauftrag 9.9 dazu.' '' 'Projektauftrag 9.8 dazu.' '' 'Nach (1.2) und (9.7) gilt dies.' '' 'Nach (9.6) gilt dies.' \
     '' 'Abschnitt 5.4 und Abschnitt 9.5 hier.' '' 'Abschnitt 9.4 hier.'
  erwarte docs/fall.md:1 abschnitt 9.9
  erwarte docs/fall.md:3 abschnitt 9.8
  erwarte docs/fall.md:5 abschnitt 9.7
  erwarte docs/fall.md:7 abschnitt 9.6
  erwarte docs/fall.md:9 abschnitt 9.5
  erwarte docs/fall.md:11 abschnitt 9.4
}
f_B288() { # Zweigform: blob/ mit Commit-Pruefsumme, dann blob/main; in der folgenden Zeile tree/main
  md "Siehe https://github.com/x/y/blob/${GRUND_COMMIT}/docs/ziel.md und https://github.com/x/y/blob/main/a.md hier." 'Siehe https://github.com/x/y/tree/main/docs hier.'
  erwarte docs/fall.md:1 blob-tree-verweis blob/main
  erwarte docs/fall.md:2 blob-tree-verweis tree/main
}

# --- Nr. 3 (DT-G0-M4-03): Stoerer im Projektauftrag, die keine Ueberschrift sind ------------------------------------------------
f_B289() { # eine Nummer im Fliesstext und eine Zeile aus Rautezeichen und Nummer ohne Leerzeichen; beide in den drei Formen genannt
  zeilen_an docs/00_Projektauftrag.md '' 'Version 9.9 im Text.' '##9.8 Ohne Leerzeichen'
  md 'Siehe Projektauftrag 9.9 zur Sache.' '' 'Nach (9.9) gilt dies.' '' 'Nach Abschnitt 9.9 gilt dies.' \
     '' 'Siehe Projektauftrag 9.8 zur Sache.' '' 'Nach (9.8) gilt dies.' '' 'Nach Abschnitt 9.8 gilt dies.'
  erwarte docs/fall.md:1 abschnitt 9.9
  erwarte docs/fall.md:3 abschnitt 9.9
  erwarte docs/fall.md:5 abschnitt 9.9
  erwarte docs/fall.md:7 abschnitt 9.8
  erwarte docs/fall.md:9 abschnitt 9.8
  erwarte docs/fall.md:11 abschnitt 9.8
}

# --- Nr. 4 (DT-G0-M4-04): Regel a ist eine geschlossene Liste (Rest: GP-B8) -----------------------------------------------------
f_B290() { # Segmente, die kein Erzeugnisverzeichnis sind: src, ein Name mit Listennamen als Anfang, die im Bestand ueblichen Pfadzeichen
  md '`docs/src/fehlt.md`' '`docs/builds/fehlt.md`' '`docs/Fehlt_Ziel-2.v1.md`'
  erwarte docs/fall.md:1 pfad docs/src/fehlt.md
  erwarte docs/fall.md:2 pfad docs/builds/fehlt.md
  erwarte docs/fall.md:3 pfad docs/Fehlt_Ziel-2.v1.md
}

# --- Nr. 5 (DT-G0-M4-05): Kennung mit angrenzendem Wortzeichen (Form der Testnamen nach 6.6) ------------------------------------
f_B291() { # dahinter Unterstrich und Wort; davor ein Wort mit Unterstrich unmittelbar vor der Kennung
  md 'Testname R3-Z-999_regel hier.' 'Vorsatz test_R3-Z-998 hier.'
  erwarte docs/fall.md:1 anforderung R3-Z-999
  erwarte docs/fall.md:2 anforderung R3-Z-998
}

# --- Nr. 6 (DT-G0-M4-06): ein Eintrag mit # im Grund, nicht am Zeilenanfang, ist kein Kommentar ------------------------------
f_B292() { # (a) KB-23: der Eintrag deckt keinen Fund und ist veraltet
  md 'Zeile eins.'
  printf 'docs/fall.md|docs/alt.md\tsiehe #12\n' > "$BAUM/$AL" || herstellung_fehler "Ausnahmeliste"
  erwarte "$AL:1" ausnahme-veraltet 'docs/fall.md|docs/alt.md'
}
f_B293() { # (b) KB-20: der Eintrag mit # im Grund deckt den einzigen Fund
  md 'Siehe `docs/fehlt.md` hier.'
  printf 'docs/fall.md|docs/fehlt.md\tBeleg #12\n' > "$BAUM/$AL" || herstellung_fehler "Ausnahmeliste"
}

# --- Nr. 7 (DT-G0-M4-07): die letzte Zeile der Ausnahmeliste ohne Schlussumbruch wird gelesen -----------------------------------
f_B294() { # (a) KB-23: der Eintrag in der letzten Zeile deckt keinen Fund
  md 'Zeile eins.'
  printf 'docs/fall.md|docs/alt.md\tGrund' > "$BAUM/$AL" || herstellung_fehler "Ausnahmeliste"
  erwarte "$AL:1" ausnahme-veraltet 'docs/fall.md|docs/alt.md'
}
f_B295() { # (b) KB-20: der Eintrag in der letzten Zeile deckt den einzigen Fund
  md 'Siehe `docs/fehlt.md` hier.'
  printf 'docs/fall.md|docs/fehlt.md\tBeleg' > "$BAUM/$AL" || herstellung_fehler "Ausnahmeliste"
}

# --- Nr. 8 (DT-G0-M4-08): ein Werkzeug ausserhalb der geschlossenen Liste im Lesepfad faellt mit PATH nur aus der Liste auf -----
f_B296() { # PATH nur aus git, grep, awk, sort, dirname: ein falscher Verweis jeder Art (ohne bestand-leer), dazu je eine deckende Ausnahme der Formen datei|wert und datei:zeile (BM-142)
  werkzeugkasten_ohne keines
  ENV_ZUSATZ=("PATH=$KASTEN")
  ln -s adr "$BAUM/docs/lnk" || herstellung_fehler "ln lnk"
  md 'Siehe `docs/ziel.md:99` dazu.' 'Commit 0123456789abcdef0123456789abcdef01234567 dazu.' 'Siehe https://github.com/x/y/blob/main/a.md dazu.' \
     'Siehe R3-Z-999 dazu.' '`docs/fehlt.md`' '`methodik/fehlt.md`' "\`${A_DATEI}\`" '`docs/lnk/0001-test.md`' \
     'Siehe Projektauftrag 9.9 dazu.' '`docs/fehlt-gedeckt.md`' '`docs/fehlt-gedeckt-z.md`'
  zeilen docs/offen.md 'Text.' "$BT" 'nur Text im offenen Block'
  rolle_b 'skills:' '  - skill-fehlt'
  zeilen .claude/agents/rolle-c.md '---' 'name: rolle-c' 'description: x' 'skills: [x]' '---' '# Rolle C'
  zeilen .claude/agents/rolle-d.md '---' 'name: rolle-d' 'skills:' '  - skill-a'
  skill_b 'metadata:' '  anforderung: irgendwas'
  printf 'nurwert\tGrund\ndocs/fall.md:20\ndocs/fall.md|docs/alt.md\tGrund\ndocs/fall.md|docs/fehlt-gedeckt.md\tBeleg\ndocs/fall.md:11\tBeleg\n' > "$BAUM/$AL" || herstellung_fehler "Ausnahmeliste"
  erwarte docs/fall.md:1 zeile docs/ziel.md:99
  erwarte docs/fall.md:2 commit 0123456789abcdef0123456789abcdef01234567
  erwarte docs/fall.md:3 blob-tree-verweis blob/main
  erwarte docs/fall.md:4 anforderung R3-Z-999
  erwarte docs/fall.md:5 pfad docs/fehlt.md
  erwarte docs/fall.md:6 pfad methodik/fehlt.md
  erwarte docs/fall.md:8 pfad-verknuepfung docs/lnk/0001-test.md
  erwarte docs/fall.md:9 abschnitt 9.9
  erwarte docs/offen.md:2 codeblock-offen "$BT"
  erwarte .claude/agents/rolle-b.md:5 skill skill-fehlt
  erwarte .claude/agents/rolle-c.md:4 skill-form '[x]'
  erwarte .claude/agents/rolle-d.md:1 frontmatter 'nicht geschlossen'
  erwarte .claude/skills/skill-b/SKILL.md:5 skill-anforderung irgendwas
  erwarte "$AL:1" ausnahme-form nurwert
  erwarte "$AL:2" ausnahme-ohne-grund docs/fall.md:20
  erwarte "$AL:3" ausnahme-veraltet 'docs/fall.md|docs/alt.md'
}
f_B297() { # derselbe PATH bei leerer Pruefflaeche (Zweig bestand-leer)
  werkzeugkasten_ohne keines
  ENV_ZUSATZ=("PATH=$KASTEN")
  kein_add
  g rm -r -q --cached docs .claude CLAUDE.md || herstellung_fehler "git rm --cached"
  erwarte '-:0' bestand-leer prueflaeche-leer
}

# --- Nr. 9 (DT-G0-M4-09): Dateien der Pruefflaeche in jeder Tiefe unter .claude/ -------------------------------------------------
f_B298() { zeilen .claude/notiz.md 'Siehe `docs/fehlt.md` hier.'; erwarte .claude/notiz.md:1 pfad docs/fehlt.md; }       # direkt unter .claude/
f_B299() { zeilen .claude/x/notiz.md 'Siehe `docs/fehlt.md` hier.'; erwarte .claude/x/notiz.md:1 pfad docs/fehlt.md; }   # eine Ebene tiefer

# --- Nr. 10 (DT-G0-M4-10): keine Umgebungsvariable des Aufrufers beeinflusst das Urteil (EB-2, S-1) ----------------------------------
f_B300() { # Lauf: drei Funde und ein Archivpfad, der besteht; fremde Werte unter den Namen, die der Pruefer fuehrt
  local f="$FALL/fremd-umgebung"
  mkdir -p "$f" || herstellung_fehler "Verzeichnis fremd-umgebung"
  md 'Siehe `docs/fehlt.md` hier.' 'Siehe R3-Z-999 dazu.' 'Siehe Projektauftrag 9.9 dazu.' "Siehe \`${A_DATEI}\` dazu."
  printf 'docs/fall.md|docs/fehlt.md\tBeleg\ndocs/fall.md|R3-Z-999\tBeleg\ndocs/fall.md|9.9\tBeleg\n' > "$f/ausnahmen.txt" || herstellung_fehler "fremde Ausnahmeliste"
  printf '# R3-Z-999 Fremd\n' > "$f/backlog.md" || herstellung_fehler "fremder Backlog"
  printf '# Projektauftrag\n\n## 9.9 Fremd\n' > "$f/projektauftrag.md" || herstellung_fehler "fremder Projektauftrag"
  ENV_ZUSATZ=("BELEGE_AUSNAHMEN=$f/ausnahmen.txt" "AUSNAHMEDATEI=$f/ausnahmen.txt" "BACKLOG=$f/backlog.md" "PROJEKTAUFTRAG=$f/projektauftrag.md" \
              "ARCHIVSTAND=1111111111111111111111111111111111111111" "PRUEFFLAECHE_ERE=^\$")
  erwarte docs/fall.md:1 pfad docs/fehlt.md
  erwarte docs/fall.md:2 anforderung R3-Z-999
  erwarte docs/fall.md:3 abschnitt 9.9
}
# Statische Pruefung (GP-B7: kein Lesen ueber Indirektion, nichts, was aufgerufene Werkzeuge selbst lesen). Gelesen wird $name, ${name...},
# ${!name...} ausserhalb von Kommentarzeilen. Gesetzt oder geloescht sind: Zuweisung (name=, name+=, name[...]=), local, declare, typeset,
# readonly, export, for name in, read, mapfile, unset. Erlaubnisliste, geschlossen, je mit Grund: PATH (Suchpfad der Werkzeuge der
# geschlossenen Liste; KC-01 prueft sie), BASH_REMATCH (setzt bash selbst bei =~).
FREMDVAR_AWK=$(cat <<'AWKEOF'
function setze(n) { if (n != "") gesetzt[n] = 1 }
function tokens_ab(s, kw,    p, t, i, k, w, n) {
  p = index(s, kw); if (p == 0) return
  t = substr(s, p + length(kw))
  sub(/[;|<>&)].*$/, "", t)
  n = split(t, w, /[[:space:]]+/)
  for (i = 1; i <= n; i++) { k = w[i]; sub(/=.*$/, "", k); if (k ~ /^[A-Za-z_][A-Za-z0-9_]*$/) setze(k) }
}
/^[[:space:]]*#/ { next }
{
  zeile[NR] = $0
  s = $0
  while (match(s, /[A-Za-z_][A-Za-z0-9_]*(\[[^]]*\])?\+?=/)) {
    n = substr(s, RSTART, RLENGTH); sub(/[\[+=].*$/, "", n); setze(n); s = substr(s, RSTART + RLENGTH)
  }
  s = $0
  if (s ~ /(^|[;&|({[:space:]])(local|declare|typeset|readonly|export)[[:space:]]/) {
    t = s; sub(/^.*(local|declare|typeset|readonly|export)[[:space:]]+/, "", t); sub(/[;|<>&)].*$/, "", t)
    m = split(t, w, /[[:space:]]+/)
    for (i = 1; i <= m; i++) { k = w[i]; sub(/=.*$/, "", k); if (k ~ /^[A-Za-z_][A-Za-z0-9_]*$/) setze(k) }
  }
  if (match(s, /(^|[;&|({[:space:]])for[[:space:]]+[A-Za-z_][A-Za-z0-9_]*[[:space:]]+in[[:space:]]/)) {
    t = substr(s, RSTART, RLENGTH); sub(/^[^f]*for[[:space:]]+/, "", t); sub(/[[:space:]].*$/, "", t); setze(t)
  }
  if (s ~ /(^|[;&|({[:space:]])read[[:space:]]/) tokens_ab(s, "read ")
  if (s ~ /(^|[;&|({[:space:]])mapfile[[:space:]]/) tokens_ab(s, "mapfile ")
  if (s ~ /(^|[;&|({[:space:]])unset[[:space:]]/) {
    t = s; sub(/^.*unset[[:space:]]+/, "", t)
    while (match(t, /[A-Za-z_][A-Za-z0-9_]*/)) { setze(substr(t, RSTART, RLENGTH)); t = substr(t, RSTART + RLENGTH) }
  }
}
END {
  erlaubt["PATH"] = 1; erlaubt["BASH_REMATCH"] = 1
  for (i = 1; i <= NR; i++) {
    if (!(i in zeile)) continue
    s = zeile[i]
    while (match(s, /\$(\{[!#]?)?[A-Za-z_][A-Za-z0-9_]*/)) {
      n = substr(s, RSTART, RLENGTH); sub(/^\$(\{[!#]?)?/, "", n)
      if (!(n in gesetzt) && !(n in erlaubt) && !(n in gemeldet)) { gemeldet[n] = 1; print i "\t" n }
      s = substr(s, RSTART + RLENGTH)
    }
  }
}
AWKEOF
)
f_B301() { # statisch: ausserhalb von Kommentarzeilen nur Variablen, die der Pruefer selbst setzt oder loescht (Erlaubnisliste: PATH, BASH_REMATCH)
  local treffer probe gelesen
  STAT_SOLL="ausserhalb von Kommentarzeilen liest der Pruefer nur Variablen, die er selbst setzt oder loescht (Erlaubnisliste PATH, BASH_REMATCH); Probe der Pruefung: nur Zeile 4"
  probe=$'# Kommentar mit $KOMMENTAR\neigen=1\necho "$eigen"\necho "${FREMD:-vorgabe}"\nunset GELOESCHT\necho "$GELOESCHT" "$PATH" "${BASH_REMATCH[0]}"\n'
  gelesen=$(printf '%s' "$probe" | awk "$FREMDVAR_AWK" | cut -f1 | tr '\n' ' ')
  treffer=$(awk "$FREMDVAR_AWK" "$PRUEFER")
  if [ "$gelesen" != "4 " ]; then
    STAT_OK=0; STAT_IST="die Pruefung trifft in der Probe '$gelesen' statt '4 '"
  elif [ -z "$treffer" ]; then
    STAT_OK=1; STAT_IST="keine fremde Variable gelesen (Probe der Pruefung gelesen: $gelesen)"
  else
    STAT_OK=0; STAT_IST="$(printf '%s\n' "$treffer" | awk 'END{print NR}') fremde Variable(n), erste: $(printf '%s\n' "$treffer" | head -n 1 | tr '\t' ' ' | cut -c1-110)"
  fi
}

# --- Nr. 11 (DT-G0-M4-11): Git-Verzeichnis ausserhalb von ./.git ---------------------------------------------------------------
# (a) hier: getrenntes Git-Verzeichnis, .git als Datei, die Datei shallow im Git-Verzeichnis; (b) B-303 (verknuepfter Arbeitsbaum, in
# teile/p38); (c) KC-12 mit alternates im getrennten Git-Verzeichnis misst B-266.
f_B302() {
  kein_add
  g add -A || herstellung_fehler "git add"
  cp -a "$BAUM/.git" "$FALL/gitdir-extern" && rm -rf "${BAUM:?}/.git" && printf 'gitdir: %s\n' "$FALL/gitdir-extern" > "$BAUM/.git" || herstellung_fehler "gitdir-Verweis"
  g rev-parse HEAD > "$FALL/gitdir-extern/shallow" || herstellung_fehler "shallow"
  LC_KENNUNG="git-historie"; LC_WEG_F="git fetch --unshallow"
}

# --- Nr. 13 (Hinweis zu FM-02): ".." an der Wurzel verlaesst die Wurzel, es wird nicht geklemmt --------------------------------------
f_B304() { # ../CLAUDE.md aus einer Datei der Wurzel und ../../CLAUDE.md aus docs/, CLAUDE.md an der Wurzel vorhanden
  zeilen NOTIZ.md 'Siehe `../CLAUDE.md` dazu.'
  md 'Siehe `../../CLAUDE.md` dazu.'
  erwarte NOTIZ.md:1 pfad ../CLAUDE.md
  erwarte docs/fall.md:1 pfad ../../CLAUDE.md
}

# --- Nr. 14 (SA-M4-01): GB-36, Durchlass -------------------------------------------------------------------------------------------
f_B305() { # eine Pruefsumme ohne Objekt in Unterstrichen wie bei einer Hervorhebung und eine mit einem Buchstaben unmittelbar davor
  md 'Hervorgehoben _0123456789abcdef0123456789abcdef01234567_ hier.' 'Davor g0123456789abcdef0123456789abcdef01234567 ein Buchstabe.'
}

# --- Nr. 15 (SA-M4-02): Ersatzreferenz unter refs/replace/ fuer den Archivstand (Messung) -----------------------------------------
f_B306() { # ein Commit ohne Eltern, dessen Baum einen Pfad traegt, den der Archivstand nicht hat, ersetzt den Archivstand
  local idx="$BAUM/.git/m5b-ersatz.idx" blob tree neu
  GIT_INDEX_FILE="$idx" gitg -C "$BAUM" read-tree "$STAND" || herstellung_fehler "read-tree"
  blob=$(printf 'nur im Ersatz\n' | gitg -C "$BAUM" hash-object -w --stdin) || herstellung_fehler "hash-object"
  GIT_INDEX_FILE="$idx" gitg -C "$BAUM" update-index --add --cacheinfo "100644,$blob,methodik/ersatz-nur-hier.md" || herstellung_fehler "update-index"
  tree=$(GIT_INDEX_FILE="$idx" gitg -C "$BAUM" write-tree) || herstellung_fehler "write-tree"
  neu=$(gitg -C "$BAUM" commit-tree "$tree" -m ersatz) || herstellung_fehler "commit-tree"
  gitg -C "$BAUM" update-ref "refs/replace/$STAND" "$neu" || herstellung_fehler "update-ref refs/replace"
  rm -f "$idx"
  md 'Siehe `methodik/ersatz-nur-hier.md` dazu.'
  erwarte docs/fall.md:1 pfad methodik/ersatz-nur-hier.md
}

# --- Nr. 11 (b) (DT-G0-M4-11): KC-03 bei einem verknuepften Arbeitsbaum, shallow im gemeinsamen Git-Verzeichnis -----------------
# Dieser Teil ist mit dem Datei-Werkzeug geschrieben, nicht als Befehlstext einer Shell (Vorgabe des Koordinators): der Fall legt mit
# git einen zweiten Arbeitsbaum an ("git worktree add"); diese Form erkennt der Hook gegen Schreibzugriffe nach main am Befehlstext.
# Der Prueferlauf geschieht im verknuepften Arbeitsbaum, dessen .git eine Datei ist; die Datei shallow liegt im gemeinsamen
# Git-Verzeichnis des Grundbaums. Wer den Flachklon am Dateinamen .git/shallow erkennt, sieht sie dort nicht.
f_B303() {
  kein_add
  g add -A || herstellung_fehler "git add"
  g worktree add -q --detach "$FALL/arbeitsbaum-verknuepft" || herstellung_fehler "git worktree add"
  g rev-parse HEAD > "$BAUM/.git/shallow" || herstellung_fehler "shallow"
  CWD_WAHL="$FALL/arbeitsbaum-verknuepft"
  LC_KENNUNG="git-historie"; LC_WEG_F="git fetch --unshallow"
}

# --- M5c, ST-G0-25: Pfadangabe-Variablen des Aufrufers (EB-3) -----------------------------------------------------------------------
# git ls-files -z -- '*.md' liefert mit GIT_GLOB_PATHSPECS=1 nur die Wurzeldateien (ein Fund unter docs/ ginge verloren: falsches
# Gruen), mit GIT_NOGLOB_PATHSPECS=1 oder GIT_LITERAL_PATHSPECS=1 keine Datei (bestand-leer). Die Variablen schliessen einander
# teilweise aus (git bricht ab), darum ein Fall je Variable. GIT_ICASE_PATHSPECS hat ohne die Loeschung keine beobachtbare Wirkung
# (GP-B10): dazu gibt es keinen Fall.
f_B307() { # Lauf ohne Variablen gegen Lauf mit GIT_GLOB_PATHSPECS=1: der Fund unter docs/ bleibt ein Fund
  md 'Siehe `docs/fehlt.md` dazu.'
  AUSGABE_MIT+=("docs/fall.md:1"$'\t'"pfad"$'\t'"docs/fehlt.md")
  ENV_ZUSATZ2=("GIT_GLOB_PATHSPECS=1")
}
f_B308() { # Lauf ohne Variablen gegen Lauf mit GIT_NOGLOB_PATHSPECS=1: die Pruefflaeche bleibt, der Fund bleibt
  md 'Siehe `docs/fehlt.md` dazu.'
  AUSGABE_MIT+=("docs/fall.md:1"$'\t'"pfad"$'\t'"docs/fehlt.md")
  ENV_ZUSATZ2=("GIT_NOGLOB_PATHSPECS=1")
}
f_B309() { # Lauf ohne Variablen gegen Lauf mit GIT_LITERAL_PATHSPECS=1: die Pruefflaeche bleibt, der Fund bleibt
  md 'Siehe `docs/fehlt.md` dazu.'
  AUSGABE_MIT+=("docs/fall.md:1"$'\t'"pfad"$'\t'"docs/fehlt.md")
  ENV_ZUSATZ2=("GIT_LITERAL_PATHSPECS=1")
}

# --- M5d, W-14: ein Fall je Mitglied der Liste der Wurzelnamen ohne Schraegstrich (GB-10, ist_pfadartig) ----------------
# B-033 misst README.md, CONTRIBUTING.md und .gitignore; Makefile und CLAUDE.md standen nur in B-034 (bestehende
# Dateien, Soll kein Fund): das Entfernen eines der beiden Namen aus der Liste blieb unbemerkt. Beide Dateien gehoeren
# zum Grundbaum und werden im Fall entfernt, sonst waere der Verweis kein Fund.
f_B310() { # Makefile fehlt an der Wurzel: der Verweis aus docs/ ist ein Fund
  rm -f "$BAUM/Makefile" || herstellung_fehler "rm Makefile"
  md '`Makefile`'
  erwarte docs/fall.md:1 pfad Makefile
}
f_B311() { # CLAUDE.md fehlt an der Wurzel: der Verweis aus docs/ ist ein Fund
  rm -f "$BAUM/CLAUDE.md" || herstellung_fehler "rm CLAUDE.md"
  md '`CLAUDE.md`'
  erwarte docs/fall.md:1 pfad CLAUDE.md
}

# =============================================================================
# 13. Faelle KC-01 bis KC-11 (B-130 bis B-151): Lage C des Pruefers, Rueckgabewert 3
#
# REIHENFOLGE-ERKENNTNIS (Teilklon, fuer B2/B3): In einem Teilklon (extensions.partialClone) loest
# jedes git cat-file auf ein FEHLENDES Objekt einen Nachlade-Abruf bei der Fernquelle aus und schreibt
# "fatal: ... does not appear to be a git repository" auf die Fehlerausgabe, bevor die eigentliche
# Meldung kommt. Der Pruefer muss den Teilklon (KC-04) deshalb VOR dem Archivstand (KC-05) und vor
# jeder Pruefsummenpruefung erkennen. Gemessen am 2026-10-28 (B0, Prototyp).
# =============================================================================
AE=$'\303\244'   # ae-Umlaut, UTF-8
kc01() { # kc01 <werkzeug> : PATH ohne dieses Werkzeug
  werkzeugkasten_ohne "$1"
  ENV_ZUSATZ=("PATH=$KASTEN")
  LC_KENNUNG="werkzeug:$1"
  LC_WEG_ERE='installier'
}
f_B130() { kc01 git; }
f_B131() { kc01 grep; }
f_B132() { kc01 awk; }
f_B133() { kc01 sort; }
f_B134() { kc01 dirname; }
f_B135() { kein_add; CWD_WAHL="$FALL/kein-repo"; mkdir -p "$CWD_WAHL" || herstellung_fehler "kein-repo"; LC_KENNUNG="git-arbeitsbaum"; }
flach_machen() { kein_add; g add -A || herstellung_fehler "git add"; g rev-parse HEAD > "$BAUM/.git/shallow" || herstellung_fehler "shallow"; }
teilklon_machen() { kein_add; g add -A || herstellung_fehler "git add"; g config core.repositoryformatversion 1 && g config extensions.partialClone origin || herstellung_fehler "git config"; }
f_B136() { flach_machen; LC_KENNUNG="git-historie"; LC_WEG_F="git fetch --unshallow"; }
f_B137() { teilklon_machen; LC_KENNUNG="git-teilklon"; LC_WEG_ERE="vollst(ae|${AE})ndig"; }
f_B138() { basis_ohne_archiv; LC_KENNUNG="archivstand"; LC_WEG_F="$BESCHAFFUNG_ARCHIV"; }
nicht_lesbar() { # nicht_lesbar <datei> : Lesbarkeit entziehen; als root nicht herstellbar (GP-B1)
  if [ "$EUID" -eq 0 ]; then nicht_herstellbar "als root laesst sich die Lesbarkeit nicht entziehen (GP-B1)"; return; fi
  kein_add
  g add -A || herstellung_fehler "git add"
  chmod 000 "$BAUM/$1" || herstellung_fehler "chmod 000 $1"
}
f_B139() { rm -f "$BAUM/docs/05_Product_Backlog.md" || herstellung_fehler "rm"; LC_KENNUNG="docs/05_Product_Backlog.md"; LC_MIT=("Pruefmittel fehlt"); LC_NICHT=("referenzmenge"); }
f_B140() { nicht_lesbar docs/05_Product_Backlog.md; LC_KENNUNG="docs/05_Product_Backlog.md"; LC_MIT=("Pruefmittel nicht lesbar"); LC_NICHT=("referenzmenge"); }
f_B141() { rm -f "$BAUM/docs/00_Projektauftrag.md" || herstellung_fehler "rm"; LC_KENNUNG="docs/00_Projektauftrag.md"; LC_MIT=("Pruefmittel fehlt"); LC_NICHT=("referenzmenge"); }
f_B142() { nicht_lesbar docs/00_Projektauftrag.md; LC_KENNUNG="docs/00_Projektauftrag.md"; LC_MIT=("Pruefmittel nicht lesbar"); LC_NICHT=("referenzmenge"); }
f_B143() { rm -f "$BAUM/$AL" || herstellung_fehler "rm"; LC_KENNUNG="scripts/belege-ausnahmen.txt"; LC_MIT=("Pruefmittel fehlt"); }
f_B144() { nicht_lesbar "$AL"; LC_KENNUNG="scripts/belege-ausnahmen.txt"; LC_MIT=("Pruefmittel nicht lesbar"); }
f_B145() { zeilen "$AL" '# nur Kommentar' '# zweite Kommentarzeile'; }
f_B146() { zeilen docs/05_Product_Backlog.md '# Backlog' '' 'Kein Eintrag.'; LC_KENNUNG="referenzmenge-backlog"; }
f_B147() { zeilen docs/00_Projektauftrag.md '# Projektauftrag' '' 'Ohne nummerierte Abschnitte.'; LC_KENNUNG="referenzmenge-projektauftrag"; }
f_B148() { kein_add; g add -A || herstellung_fehler "git add"; printf 'garbage' > "$BAUM/.git/index" || herstellung_fehler "index"; LC_KENNUNG="prueflaeche"; }
f_B149() {
  werkzeugkasten_ohne grep
  ENV_ZUSATZ=("PATH=$KASTEN")
  kein_add
  CWD_WAHL="$FALL/kein-repo"; mkdir -p "$CWD_WAHL" || herstellung_fehler "kein-repo"
  LC_KENNUNG="werkzeug:grep"; LC_NICHT=("git-arbeitsbaum")
}
f_B150() { flach_machen; g config core.repositoryformatversion 1 && g config extensions.partialClone origin || herstellung_fehler "git config"; LC_KENNUNG="git-historie"; LC_NICHT=("git-teilklon"); }
f_B151() { basis_ohne_archiv; rm -f "$BAUM/docs/05_Product_Backlog.md" || herstellung_fehler "rm"; LC_KENNUNG="archivstand"; LC_NICHT=("docs/05_Product_Backlog.md"); }

# --- Nachtraege zu KC (B-203, B-204): Reihenfolge Teilklon / flacher Klon vor Archivstand ---------------
f_B203() { # Teilklon ohne Archivobjekte: der Teilklon steht in der Reihenfolge vor dem Archivstand (siehe oben)
  basis_ohne_archiv
  teilklon_machen
  LC_KENNUNG="git-teilklon"; LC_NICHT=("archivstand" "does not appear to be a git repository"); LC_WEG_ERE="vollst(ae|${AE})ndig"
}
f_B204() { basis_ohne_archiv; flach_machen; LC_KENNUNG="git-historie"; LC_NICHT=("archivstand"); LC_WEG_F="git fetch --unshallow"; }

# =============================================================================
# 14. Faelle GB-01 bis GB-26 (B-152 bis B-183): benannte Grenzen
# =============================================================================
ELL=$'\342\200\246'   # Auslassungszeichen, UTF-8
f_B152() { md 'Siehe docs/fehlt.md ohne Rueckwaertsakzente dazu.'; }
f_B153() { md 'Beginn `docs/fehlt' '.md` Ende.'; }
f_B154() { md 'Aufruf `bash scripts/fehlt.sh` dazu.'; }
f_B155() { md '`"docs/fehlt.md"`' "\`'docs/fehlt.md'\`"; }
f_B156() { md '`docs/$fehlt.md`' '`docs/fehlt=1.md`' '`docs/fehlt*.md`' '`docs/<fehlt>.md`' '`docs/{fehlt}.md`'; }
f_B157() { md '`docs/fehlt...md`' "\`docs/fehlt${ELL}md\`" '`docs/fehlt@v1.md`'; }
f_B158() { md '`https://example.org/docs/fehlt.md`' '`/docs/fehlt.md`' '`~/docs/fehlt.md`' '`blob/docs/fehlt.md`' '`tree/docs/fehlt.md`'; }
f_B159() { md 'Schablone `docs/adr/NNNN-titel.md` dazu.'; erwarte docs/fall.md:1 pfad docs/adr/NNNN-titel.md; }
f_B160() { md '`claude/a/b`' '`origin/main`' '`fix/a-b`'; }
f_B161() { md '`release/a/b`'; erwarte docs/fall.md:1 pfad release/a/b; }
f_B162() { md '`valITino/fehlt/x.md`'; }
f_B163() { zeilen ver1.0/echt.md '# echt'; md '`docs.alt/fehlt.md`' '`ver1.0/fehlt.md`'; }
f_B164() { md '`tests/architektur`'; }
f_B165() { md '`fehlt.md`' '`fehlt`'; }
f_B166() {
  md '`docs/node_modules/fehlt.md`' '`docs/.venv/fehlt.md`' '`docs/dist/fehlt.md`' '`docs/build/fehlt.md`' \
     '`docs/__pycache__/fehlt.md`' '`docs/.pytest_cache/fehlt.md`' '`docs/.mypy_cache/fehlt.md`'
}
f_B167() { md '| Spalte | Text |' '|---|---|' '| ADR 0002 | nennt etwas |' '| Zeile | siehe (9.9) hier |'; }
f_B168() { zeilen docs/adr/0002-test.md '# ADR 0002 (synthetisch)' '' '## 7.3 Eigener Abschnitt' '' 'Siehe (7.3) oben.'; }
f_B169() { md 'Siehe Abschnitt 5.4.9 dazu.'; }
f_B170() { md 'Siehe (9.9.1) dazu.'; }
f_B171() {
  md 'Siehe `docs/fehlt.md` erstens.' 'Text.' 'Siehe `docs/fehlt.md` zweitens.'
  ausnahme 'docs/fall.md|docs/fehlt.md' 'Beleg'
}
f_B172() { md 'Kurzform abcdef012345 dazu.' 'Gross 0123456789ABCDEF0123456789ABCDEF01234567 dazu.'; }
f_B173() { md 'Siehe https://github.com/x/y/blob/master/docs/ziel.md dazu.' 'Siehe https://github.com/x/y/tree/master/docs dazu.'; }
f_B174() { # Commit eines geloeschten Zweigs: das Objekt liegt lokal vor, ist aber unerreichbar
  local sha
  g checkout -q -b gb18-tmp || herstellung_fehler "checkout -b"
  zeilen docs/unerreichbar.md 'x'
  g add -A && g commit -q -m "unerreichbar" || herstellung_fehler "commit"
  sha=$(g rev-parse HEAD) || herstellung_fehler "rev-parse"
  g checkout -q grund || herstellung_fehler "checkout grund"
  g branch -q -D gb18-tmp >/dev/null || herstellung_fehler "branch -D"
  md "Commit $sha dazu."
}
f_B175() { md 'Siehe R3-A-0011 dazu.'; }
f_B176() { zeilen_an docs/05_Product_Backlog.md '### R3-E-005 Gestrichene Anforderung (gestrichen)'; md 'Siehe R3-E-005 dazu.'; }
f_B177() { zeilen_an docs/05_Product_Backlog.md "$BT" '### R3-F-006 Nur im Codeblock' "$BT"; md 'Siehe R3-F-006 dazu.'; }
f_B178() { kein_add; zeilen docs/unversioniert.md 'Ziel.'; md 'Siehe `docs/unversioniert.md` dazu.'; g add docs/fall.md || herstellung_fehler "git add"; }
f_B179() { # Commit auf dem Archivstand im Grundbaum, Pfad nur dort; die Referenz zeigt auf den spaeteren Stand
  local idx="$BAUM/.git/gb23.idx" blob tree neu
  GIT_INDEX_FILE="$idx" gitg -C "$BAUM" read-tree "$STAND" || herstellung_fehler "read-tree"
  blob=$(printf 'spaeter\n' | gitg -C "$BAUM" hash-object -w --stdin) || herstellung_fehler "hash-object"
  GIT_INDEX_FILE="$idx" gitg -C "$BAUM" update-index --add --cacheinfo "100644,$blob,methodik/spaeter.md" || herstellung_fehler "update-index"
  tree=$(GIT_INDEX_FILE="$idx" gitg -C "$BAUM" write-tree) || herstellung_fehler "write-tree"
  neu=$(gitg -C "$BAUM" commit-tree "$tree" -p "$STAND" -m spaeter) || herstellung_fehler "commit-tree"
  gitg -C "$BAUM" update-ref refs/remotes/origin/archiv/r3coscrum "$neu" || herstellung_fehler "update-ref"
  rm -f "$idx"
  md 'Siehe `methodik/spaeter.md` dazu.'
  erwarte docs/fall.md:1 pfad methodik/spaeter.md
}
f_B180() { md "> $BT" '> `docs/fehlt.md`' "> $BT"; erwarte docs/fall.md:2 pfad docs/fehlt.md; }
f_B181() { md "    $BT" '    `docs/fehlt.md`' "    $BT"; erwarte docs/fall.md:2 pfad docs/fehlt.md; }
f_B182() {
  skill_b 'metadata:' '  anforderung: R3-Z-999'
  ausnahme '.claude/skills/skill-b/SKILL.md|R3-Z-999' 'Beleg'
}
f_B183() { rolle_b 'skills:' '  - skill-a' '  - skill-a'; }

# =============================================================================
# 15. Faelle EB-1 bis EB-3 (B-184 bis B-190): Eigenschaften
# =============================================================================
# Muster fuer EB-2: ein absoluter Pfad ab zwei Teilen oder ein bekannter Wurzelname am Wortanfang;
# Kommentarzeilen und /dev/null sind ausgenommen (GP-B3)
ABS_PFAD_ERE=$'(^|[[:space:]"\'=(:,;|&<>`])/([A-Za-z0-9._-]+/[A-Za-z0-9._-]|(home|tmp|root|usr|etc|var|opt|mnt|srv|proc|sys|bin|sbin|lib|lib64|run|dev|media|boot)([^A-Za-z0-9._-]|$))'
abs_pfade_in() { # Text auf der Standardeingabe; Ausgabe: Zeilennummer, Tabulator, Zeile
  awk '/^[[:space:]]*#/ {next} {print NR "\t" $0}' | sed 's#/dev/null##g' | grep -E "$ABS_PFAD_ERE"
}
fuenf_funde() { md '`docs/fehlt-a.md`' '`docs/fehlt-b.md`' '`docs/ziel.md:99`' 'R3-Z-999' '0123456789abcdef0123456789abcdef01234567'; }
f_B184() { fuenf_funde; }
f_B185() { rm -f "$BAUM/docs/05_Product_Backlog.md" || herstellung_fehler "rm"; }
f_B186() {
  local treffer
  STAT_SOLL="kein absoluter Pfad ausserhalb von Kommentarzeilen ausser /dev/null"
  treffer=$(abs_pfade_in < "$PRUEFER")
  if [ -z "$treffer" ]; then
    STAT_OK=1; STAT_IST="kein Treffer"
  else
    STAT_OK=0; STAT_IST="$(printf '%s\n' "$treffer" | awk 'END{print NR}') Treffer, erster: $(printf '%s\n' "$treffer" | head -n 1 | cut -c1-110)"
  fi
}
f_B187() { # Gegenprobe der Prueffunktion
  local probe gelesen
  STAT_SOLL="die Prueffunktion trifft genau die Zeilen 3, 4 und 6 des Probetexts"
  probe=$'#!/usr/bin/env bash\n# Kommentar mit /home/user/x\nx=/home/user/z\ncd /tmp\necho ok 2>/dev/null\ncat /etc/passwd\n'
  gelesen=$(printf '%s' "$probe" | abs_pfade_in | cut -f1 | tr '\n' ' ')
  if [ "$gelesen" = "3 4 6 " ]; then STAT_OK=1; STAT_IST="Treffer in den Zeilen $gelesen"; else STAT_OK=0; STAT_IST="Treffer in den Zeilen '$gelesen'"; fi
}
f_B188() { fuenf_funde; }
f_B189() { # P-10: andere Spracheinstellung des Aufrufers; ein Zeichen vor einer Pruefsumme ohne Objekt
  if ! printf '\303\244' | LC_ALL=C.UTF-8 grep -q '^.$' 2>/dev/null; then
    nicht_herstellbar "UTF-8-Spracheinstellung C.UTF-8 nicht installiert (GP-B2)"; return
  fi
  md "Pruefsumme ${AE}0123456789abcdef0123456789abcdef01234567 hier."
  ENV_ZUSATZ2=("LC_ALL=C.UTF-8")
}
f_B190() { :; }   # der Vergleich des Arbeitsbaums steht im Hauptablauf, nach dem letzten Fall

# =============================================================================
# 15b. Nachtraege waehrend B2 (B-206, B-207, B-214, B-217, B-218)
# =============================================================================
f_B207() { # P-2: voller Werkzeugkasten (nur die Werkzeuge der Liste): Grundfall ohne Fund
  werkzeugkasten_ohne keines
  ENV_ZUSATZ=("PATH=$KASTEN")
}
f_B214() { # P-9: Teilklon allein an extensions.partialclone erkannt (Formatversion 0)
  kein_add; g add -A || herstellung_fehler "git add"
  g config extensions.partialclone origin || herstellung_fehler "git config"
  LC_KENNUNG="git-teilklon"; LC_WEG_ERE="vollst(ae|${AE})ndig"
}
f_B217() { # KC-11: versionierte Markdown-Datei fehlt im Arbeitsbaum (rm ohne git rm), keine Verknuepfung
  kein_add
  rm -f "$BAUM/docs/adr/0001-test.md" || herstellung_fehler "rm"
  LC_KENNUNG="prueflaeche"; LC_MIT=("docs/adr/0001-test.md"); LC_WEG_ERE='wiederherstellen.*git rm'
}
f_B218() { nicht_lesbar docs/adr/0001-test.md; LC_KENNUNG="prueflaeche"; LC_MIT=("docs/adr/0001-test.md"); }
# EB-4 (P-11): Groesse und Zeitgrenze aus gemessenen Laeufen beider Fassungen: alte Verkettung etwa 9e-9 s mal Zeilenzahl im Quadrat
# (120000 Zeilen: weit ueber 100 s), neue Markierung 0,5 s bei 120000 und 0,9 s bei 250000 Zeilen; Grenze 10 s liegt dazwischen
EB4_ZEILEN=120000
EB4_ZEITGRENZE=10
f_B206() {
  ZG_FALL="$EB4_ZEITGRENZE"
  awk -v n="$EB4_ZEILEN" 'BEGIN { for (i = 1; i <= n; i++) print "x"; print "Nach (9.9) gilt dies." }' > "$BAUM/docs/lang-ohne-leerzeile.md" || herstellung_fehler "docs/lang-ohne-leerzeile.md"
  erwarte "docs/lang-ohne-leerzeile.md:$((EB4_ZEILEN + 1))" abschnitt 9.9
}


# =============================================================================
# 16. Ein Fall: Baum herstellen, Pruefer laufen lassen, bewerten, buchen
# =============================================================================
declare -A FL_KLASSEN=() FL_SOLL=() FL_HERKUNFT=() FL_GEGENSTAND=()
FL_ORDER=()
declare -A ERGEBNIS=() GRP_N=() GRP_B=() GRP_G=() GRP_H=()
ANZ_B=0; ANZ_G=0; ANZ_H=0
GEFALLENE=()
SCHNAPP_VORHER=""

fall_ausfuehren() { # fall_ausfuehren <kennung>
  local k="$1" soll klassen gegen fn out err cwd sollt grp vor nach rc1 rc2 d a b s
  soll="${FL_SOLL[$k]}"; klassen="${FL_KLASSEN[$k]}"; gegen="${FL_GEGENSTAND[$k]}"; fn="f_${k//-/}"
  FALL_K="$k"
  fall_zuruecksetzen
  ERG="BESTANDEN"
  FALL="$T/faelle/$k"; BAUM="$FALL/baum"
  mkdir -p "$FALL" && cp -a "$GRUND" "$BAUM" || herstellung_fehler "Kopie des Grundbaums"
  "$fn"
  out="$FALL/aus.txt"; err="$FALL/fehler.txt"
  case "$soll" in
    fund) sollt="Fund, ${#ERW[@]} Zeile(n)" ;;
    kein-fund) sollt="kein Fund" ;;
    kein-fund+ausgabe) sollt="kein Fund, Aussage ueber die Standardausgabe" ;;
    lage-c) sollt="Lage C, Kennung $LC_KENNUNG" ;;
    gleich) sollt="zwei Laeufe mit gleicher Ausgabe" ;;
    schreibfrei) sollt="Baum vor und nach dem Lauf gleich" ;;
    statisch) sollt="$STAT_SOLL" ;;
    arbeitsbaum) sollt="Arbeitsbaum vor und nach dem ganzen Lauf gleich" ;;
    zeilenumbruch) sollt="Rueckgabewert 2, Befunde $ZN_BEFUNDE, $ZN_ZEILEN Zeilen unter Funde vollstaendig" ;;
    *) herstellung_fehler "unbekannte Soll-Art $soll" ;;
  esac
  if [ -n "$NH_GRUND" ]; then
    ERG="NICHT_HERSTELLBAR"; IST="nicht herstellbar: $NH_GRUND"
  else
    if [ "$NO_ADD" = 0 ] && [ "$soll" != statisch ] && [ "$soll" != arbeitsbaum ]; then
      gitg -C "$BAUM" add -A || herstellung_fehler "git add -A"
    fi
    cwd="${CWD_WAHL:-$BAUM}"
    case "$soll" in
      fund|kein-fund|kein-fund+ausgabe)
        lauf_pruefer "$cwd" "$out" "$err" "${ENV_ZUSATZ[@]+"${ENV_ZUSATZ[@]}"}"
        bewerte_funde "$soll" "$out" "$err" "$LAUF_RC"
        if [ "$soll" = "kein-fund+ausgabe" ]; then ausgabe_pruefen "$out"; fi
        if [ "$ARTEN_PRUEFEN" = 1 ] && [ -f "$FALL/ist.txt" ]; then arten_pruefen "$out"; fi
        ;;
      lage-c)
        lauf_pruefer "$cwd" "$out" "$err" "${ENV_ZUSATZ[@]+"${ENV_ZUSATZ[@]}"}"
        bewerte_lagec "$out" "$err" "$LAUF_RC"
        ;;
      zeilenumbruch)
        lauf_pruefer "$cwd" "$out" "$err" "${ENV_ZUSATZ[@]+"${ENV_ZUSATZ[@]}"}"
        bewerte_zeilenumbruch "$out" "$err" "$LAUF_RC"
        ;;
      gleich)
        if [ "${#ENV_ZUSATZ2[@]}" -eq 0 ]; then ENV_ZUSATZ2=("${ENV_ZUSATZ[@]+"${ENV_ZUSATZ[@]}"}"); fi
        lauf_pruefer "$cwd" "$FALL/aus1.txt" "$FALL/fehler1.txt" "${ENV_ZUSATZ[@]+"${ENV_ZUSATZ[@]}"}"; rc1=$LAUF_RC
        lauf_pruefer "$cwd" "$FALL/aus2.txt" "$FALL/fehler2.txt" "${ENV_ZUSATZ2[@]+"${ENV_ZUSATZ2[@]}"}"; rc2=$LAUF_RC
        a=gleich; cmp -s "$FALL/aus1.txt" "$FALL/aus2.txt" || a=verschieden
        b=gleich; cmp -s "$FALL/fehler1.txt" "$FALL/fehler2.txt" || b=verschieden
        IST="Rueckgabewerte $rc1 und $rc2, Standardausgabe $a, Fehlerausgabe $b"
        if [ "$rc1" = 124 ] || [ "$rc2" = 124 ]; then ERG=GEFALLEN; DETAIL+=("Zeitgrenze von ${ZG_FALL:-$FALL_ZEITGRENZE} s ueberschritten"); fi
        if [ ! -s "$FALL/aus1.txt" ] && [ ! -s "$FALL/fehler1.txt" ]; then ERG=GEFALLEN; DETAIL+=("der erste Lauf hat keine Ausgabe erzeugt: Gleichheit allein sagt dann nichts"); fi
        if [ "$rc1" != "$rc2" ]; then ERG=GEFALLEN; DETAIL+=("Rueckgabewerte verschieden"); fi
        if [ "$a" != gleich ]; then ERG=GEFALLEN; DETAIL+=("Standardausgabe verschieden: $(cmp "$FALL/aus1.txt" "$FALL/aus2.txt" 2>&1 | sed 's/^.*differ: //')"); fi
        if [ "$b" != gleich ]; then ERG=GEFALLEN; DETAIL+=("Fehlerausgabe verschieden: $(cmp "$FALL/fehler1.txt" "$FALL/fehler2.txt" 2>&1 | sed 's/^.*differ: //')"); fi
        for s in "${AUSGABE_MIT[@]+"${AUSGABE_MIT[@]}"}"; do
          if ! grep -qF -- "$s" "$FALL/aus1.txt"; then ERG=GEFALLEN; DETAIL+=("Standardausgabe des ersten Laufs enthaelt nicht: $s"); fi
        done
        ;;
      schreibfrei)
        vor=$(zustand_baum_voll "$BAUM") || herstellung_fehler "Zustand des Baums vorher"
        lauf_pruefer "$cwd" "$out" "$err" "${ENV_ZUSATZ[@]+"${ENV_ZUSATZ[@]}"}"
        nach=$(zustand_baum_voll "$BAUM") || herstellung_fehler "Zustand des Baums nachher"
        if [ ! -s "$out" ] && [ ! -s "$err" ]; then ERG=GEFALLEN; DETAIL+=("der Lauf hat keine Ausgabe erzeugt: Unveraendertheit allein sagt dann nichts"); fi
        if [ "$vor" = "$nach" ]; then
          IST="Rueckgabewert $LAUF_RC, Baum vorher gleich nachher"
        else
          ERG=GEFALLEN; IST="Rueckgabewert $LAUF_RC, Baum nach dem Lauf veraendert"
          printf '%s\n' "$vor" > "$FALL/vor.txt"; printf '%s\n' "$nach" > "$FALL/nach.txt"
          while IFS= read -r d; do DETAIL+=("$d"); done < <(mengen_vergleichen "$FALL/vor.txt" "$FALL/nach.txt" | head -n 12)
        fi
        ;;
      statisch)
        IST="$STAT_IST"
        if [ "$STAT_OK" != 1 ]; then ERG=GEFALLEN; fi
        ;;
      arbeitsbaum)
        nach=$(zustand_baum "$ARBEITSBAUM") || herstellung_fehler "Zustand des Arbeitsbaums nachher"
        if [ "$SCHNAPP_VORHER" = "$nach" ]; then
          IST="Arbeitsbaum vor und nach dem Lauf gleich"
        else
          ERG=GEFALLEN; IST="Arbeitsbaum nach dem Lauf veraendert"
          printf '%s\n' "$SCHNAPP_VORHER" > "$T/arb-vor.txt"; printf '%s\n' "$nach" > "$T/arb-nach.txt"
          while IFS= read -r d; do DETAIL+=("$d"); done < <(mengen_vergleichen "$T/arb-vor.txt" "$T/arb-nach.txt" | head -n 12)
        fi
        ;;
    esac
  fi
  # buchen
  ERGEBNIS[$k]="$ERG"
  grp="${klassen:0:2}"
  GRP_N[$grp]=$(( ${GRP_N[$grp]:-0} + 1 ))
  case "$ERG" in
    BESTANDEN) ANZ_B=$((ANZ_B + 1)); GRP_B[$grp]=$(( ${GRP_B[$grp]:-0} + 1 )) ;;
    GEFALLEN) ANZ_G=$((ANZ_G + 1)); GRP_G[$grp]=$(( ${GRP_G[$grp]:-0} + 1 )); GEFALLENE+=("$k") ;;
    NICHT_HERSTELLBAR) ANZ_H=$((ANZ_H + 1)); GRP_H[$grp]=$(( ${GRP_H[$grp]:-0} + 1 )) ;;
  esac
  printf '%s [%s] %s | Soll: %s | Ist: %s | %s\n' "$k" "$klassen" "$ERG" "$sollt" "$IST" "$gegen"
  for d in "${DETAIL[@]+"${DETAIL[@]}"}"; do printf '    %s\n' "$d"; done
  chmod -R u+rwx "$FALL" >/dev/null 2>&1
  rm -rf "$FALL"
}

# =============================================================================
# 17. Fallliste lesen und pruefen
# =============================================================================
fallliste_lesen() {
  local tag k kl so he ge fn
  while IFS='|' read -r tag k kl so he ge; do
    [ "$tag" = "#F" ] || continue
    [[ "$k" =~ ^B-[0-9]{3}$ ]] || lage_c_pm "Fallliste: ungueltige Kennung '$k'."
    [ -z "${FL_SOLL[$k]+x}" ] || lage_c_pm "Fallliste: Kennung $k doppelt."
    case "$so" in
      fund|kein-fund|kein-fund+ausgabe|lage-c|gleich|schreibfrei|statisch|arbeitsbaum|zeilenumbruch) ;;
      *) lage_c_pm "Fallliste: unbekannte Soll-Art '$so' bei $k." ;;
    esac
    [ -n "$kl" ] && [ -n "$ge" ] || lage_c_pm "Fallliste: Klassen oder Gegenstand fehlen bei $k."
    FL_ORDER+=("$k"); FL_KLASSEN[$k]="$kl"; FL_SOLL[$k]="$so"; FL_HERKUNFT[$k]="$he"; FL_GEGENSTAND[$k]="$ge"
  done < <(grep '^#F|' "$SKRIPT_QUELLE")
  [ "${#FL_ORDER[@]}" -gt 0 ] || lage_c_pm "Fallliste: keine Zeile '#F|' im Skript gelesen."
  for k in "${FL_ORDER[@]}"; do
    declare -F "f_${k//-/}" >/dev/null || lage_c_pm "Fall $k hat keine Funktion f_${k//-/}."
  done
  while IFS= read -r fn; do
    k="B-${fn#f_B}"
    [ -n "${FL_SOLL[$k]+x}" ] || lage_c_pm "Funktion $fn hat keine Zeile in der Fallliste."
  done < <(compgen -A function | grep -E '^f_B[0-9]{3}$')
}

# =============================================================================
# 18. Deckung (2a Punkt 9): Kennungen des Kopfkommentars gegen die Faelle, in beide Richtungen
# =============================================================================
deckung_pruefen() {
  DECK_ABW=0
  local k cl grp n f cls fehl anz
  local -A IM_KOPF=() KL_ANZ=() KL_FUND=() KL_KEIN=()
  while IFS= read -r k; do
    [ -n "$k" ] && IM_KOPF[$k]=1
  done < <(kopf_kennungen)
  for f in "${FL_ORDER[@]}"; do
    IFS=',' read -ra cls <<< "${FL_KLASSEN[$f]}"
    for cl in "${cls[@]}"; do
      KL_ANZ[$cl]=$(( ${KL_ANZ[$cl]:-0} + 1 ))
      case "${FL_SOLL[$f]}" in
        fund) KL_FUND[$cl]=$(( ${KL_FUND[$cl]:-0} + 1 )) ;;
        kein-fund*) KL_KEIN[$cl]=$(( ${KL_KEIN[$cl]:-0} + 1 )) ;;
      esac
    done
  done
  echo "--- Deckung (2a Punkt 9; getrennt von der Zaehlung der Faelle)"
  for grp in KB KC EB GB; do
    n=0
    for k in "${!IM_KOPF[@]}"; do if [ "${k:0:2}" = "$grp" ]; then n=$((n + 1)); fi; done
    if [ "$n" -gt 0 ]; then
      echo "$PM: Deckung: Gruppe $grp: $n Kennungen im Kopfkommentar des Pruefers"
    else
      echo "$PM: Deckung ABWEICHUNG: Gruppe $grp ohne Kennung im Kopfkommentar des Pruefers"
      DECK_ABW=$((DECK_ABW + 1))
    fi
  done
  fehl=""
  while IFS= read -r k; do
    [ -n "$k" ] || continue
    if [ "${KL_ANZ[$k]:-0}" -eq 0 ]; then fehl="$fehl $k"; DECK_ABW=$((DECK_ABW + 1)); fi
    if [ "${k:0:2}" = "KB" ]; then
      if [ "${KL_ANZ[$k]:-0}" -gt 0 ] && [ "${KL_FUND[$k]:-0}" -eq 0 ]; then
        echo "$PM: Deckung ABWEICHUNG: $k ohne Fall mit Soll Fund"; DECK_ABW=$((DECK_ABW + 1))
      fi
      if [ "${KL_ANZ[$k]:-0}" -gt 0 ] && [ "${KL_KEIN[$k]:-0}" -eq 0 ]; then
        echo "$PM: Deckung ABWEICHUNG: $k ohne Fall mit Soll kein Fund"; DECK_ABW=$((DECK_ABW + 1))
      fi
    fi
  done < <(printf '%s\n' "${!IM_KOPF[@]}" | sort)
  if [ -n "$fehl" ]; then echo "$PM: Deckung ABWEICHUNG: Kennungen im Kopfkommentar ohne Fall:$fehl"; fi
  fehl=""; anz=0
  while IFS= read -r cl; do
    [ -n "$cl" ] || continue
    if [ -z "${IM_KOPF[$cl]+x}" ]; then fehl="$fehl $cl"; anz=$((anz + 1)); fi
  done < <(printf '%s\n' "${!KL_ANZ[@]}" | sort)
  if [ "$anz" -gt 0 ]; then
    echo "$PM: Deckung ABWEICHUNG: $anz Klassen, die Faelle nennen, stehen nicht im Kopfkommentar des Pruefers:$fehl"
    DECK_ABW=$((DECK_ABW + anz))
  fi
  n=0
  for f in "${FL_ORDER[@]}"; do
    IFS=',' read -ra cls <<< "${FL_KLASSEN[$f]}"
    k=0
    for cl in "${cls[@]}"; do if [ -n "${IM_KOPF[$cl]+x}" ]; then k=1; fi; done
    if [ "$k" -eq 0 ]; then n=$((n + 1)); fi
  done
  echo "$PM: Deckung: $n von ${#FL_ORDER[@]} Faellen nennen keine Kennung, die im Kopfkommentar steht"
  if [ "$DECK_ABW" -eq 0 ]; then
    echo "$PM: Deckung: ohne Abweichung"
  else
    echo "$PM: Deckung: $DECK_ABW Abweichungen"
  fi
}

# =============================================================================
# 19. Modus --mutationen (2b): Mutationsdatei lesen, Mutationen fahren, Deckung der Mutationen
# =============================================================================
MUT_N=0; MUT_ABW=0
MUT_ID=(); MUT_KL=(); MUT_ED=(); MUT_MS=(); MUT_GR=()
TAB=$'\t'

mutationsdatei_lesen() { # Form der Mutationsdatei: ein Fehler hier ist Lage C des Pruefmittels (der Lauf findet nicht statt)
  local zeile zn=0 tabs id kl ed ms gr f
  local -A gesehen=()
  if LC_ALL=C grep -q '[^[:print:][:space:]]' "$MUTATIONSDATEI"; then
    lage_c_pm "Mutationsdatei $MUTATIONSDATEI enthaelt Zeichen ausserhalb von ASCII."
  fi
  while IFS= read -r zeile || [ -n "$zeile" ]; do
    zn=$((zn + 1))
    [ -z "$zeile" ] && continue
    case "$zeile" in \#*) continue ;; esac
    tabs="${zeile//[!$TAB]/}"
    [ "${#tabs}" -eq 4 ] || lage_c_pm "Mutationsdatei Zeile $zn: genau vier Tabulatoren erwartet (Kennung, Klasse, sed-Ausdruck, Mindestsatz, Grund)."
    IFS=$'\t' read -r id kl ed ms gr <<< "$zeile"
    [[ "$id" =~ ^BM-[0-9]{3}$ ]] || lage_c_pm "Mutationsdatei Zeile $zn: Kennung '$id' ist nicht BM-nnn."
    [ -z "${gesehen[$id]+x}" ] || lage_c_pm "Mutationsdatei Zeile $zn: Kennung $id doppelt."
    gesehen[$id]=1
    [[ "$kl" =~ ^(KB-[0-9]{2}|KC-[0-9]{2}|EB-[0-9])$ ]] || lage_c_pm "Mutationsdatei Zeile $zn: Klasse '$kl' ist keine Kennung KB, KC oder EB."
    [ -n "$ed" ] && [ -n "$gr" ] || lage_c_pm "Mutationsdatei Zeile $zn: sed-Ausdruck oder Grund fehlt."
    [[ "$ms" =~ ^B-[0-9]{3}(,B-[0-9]{3})*$ ]] || lage_c_pm "Mutationsdatei Zeile $zn: Mindestsatz '$ms' ist keine Liste von Fallkennungen."
    for f in ${ms//,/ }; do
      [ -n "${FL_SOLL[$f]+x}" ] || lage_c_pm "Mutationsdatei Zeile $zn: Fall $f des Mindestsatzes steht nicht in der Fallliste."
      [ "${FL_SOLL[$f]}" != arbeitsbaum ] || lage_c_pm "Mutationsdatei Zeile $zn: Fall $f (Soll arbeitsbaum) prueft den Pruefer nicht und steht in keinem Mindestsatz."
    done
    MUT_ID+=("$id"); MUT_KL+=("$kl"); MUT_ED+=("$ed"); MUT_MS+=("$ms"); MUT_GR+=("$gr")
  done < "$MUTATIONSDATEI"
  MUT_N=${#MUT_ID[@]}
  [ "$MUT_N" -gt 0 ] || lage_c_pm "Mutationsdatei ohne Mutation."
}

mutationsdeckung_pruefen() { # jede Klasse KB, KC und EB des Kopfkommentars hat eine Mutation mit einem Fall dieser Klasse im Mindestsatz
  MUT_ABW=0
  local i f cl k fehl="" anz=0 hat
  local -A abgedeckt=()
  local -a cls
  for ((i = 0; i < MUT_N; i++)); do
    hat=0
    for f in ${MUT_MS[$i]//,/ }; do
      IFS=',' read -ra cls <<< "${FL_KLASSEN[$f]}"
      for cl in "${cls[@]}"; do
        abgedeckt[$cl]=1
        if [ "$cl" = "${MUT_KL[$i]}" ]; then hat=1; fi
      done
    done
    if [ "$hat" = 0 ]; then
      echo "$PM: Mutationsdeckung ABWEICHUNG: ${MUT_ID[$i]} nennt die Klasse ${MUT_KL[$i]}, aber kein Fall des Mindestsatzes ${MUT_MS[$i]} gehoert zu ihr"
      MUT_ABW=$((MUT_ABW + 1))
    fi
  done
  while IFS= read -r k; do
    case "${k:0:2}" in
      KB|KC|EB) if [ -z "${abgedeckt[$k]+x}" ]; then fehl="$fehl $k"; anz=$((anz + 1)); fi ;;
    esac
  done < <(kopf_kennungen)
  if [ "$anz" -gt 0 ]; then
    echo "$PM: Mutationsdeckung ABWEICHUNG: $anz Klassen des Kopfkommentars ohne Mutation (kein Fall der Klasse in einem Mindestsatz):$fehl"
    MUT_ABW=$((MUT_ABW + anz))
  fi
  if [ "$MUT_ABW" -eq 0 ]; then
    echo "$PM: Mutationsdeckung: jede Klasse KB, KC und EB hat eine Mutation, ohne Abweichung"
  else
    echo "$PM: Mutationsdeckung: $MUT_ABW Abweichungen"
  fi
}

mutationen_fahren() { # alle Mutationen gegen Kopien des Pruefers; Rueckgabewert 0 nur ohne Abweichung
  local i id kl ed ms gr mut f erg offen wl n_ok=0 n_nicht=0 n_wl=0 abw=0 nach
  mkdir -p "$T/mutanten" || lage_c_pm "Verzeichnis fuer die Mutanten nicht anlegbar."
  echo "--- Mutationen ($MUT_N; je Mutation laufen nur die Faelle des Mindestsatzes gegen die Mutante)"
  for ((i = 0; i < MUT_N; i++)); do
    id="${MUT_ID[$i]}"; kl="${MUT_KL[$i]}"; ed="${MUT_ED[$i]}"; ms="${MUT_MS[$i]}"; gr="${MUT_GR[$i]}"
    mut="$T/mutanten/$id.sh"; wl=""
    if ! sed -E --sandbox -e "$ed" "$PRUEFER_ORIG" > "$mut" 2> "$T/mutanten/$id.sed"; then
      wl="sed endet mit Fehler: $(head -n 1 "$T/mutanten/$id.sed" | cut -c1-120)"
    elif cmp -s "$PRUEFER_ORIG" "$mut"; then
      wl="die Kopie ist byte-gleich mit dem Pruefer"
    elif ! bash -n "$mut" 2> "$T/mutanten/$id.bash"; then
      wl="bash -n verwirft die Mutante: $(head -n 1 "$T/mutanten/$id.bash" | cut -c1-120)"
    fi
    if [ -n "$wl" ]; then
      n_wl=$((n_wl + 1))
      printf '%s [%s] WIRKUNGSLOS | %s | %s\n' "$id" "$kl" "$wl" "$gr"
      continue
    fi
    PRUEFER="$mut"
    erg=ERKANNT; offen=""
    for f in ${ms//,/ }; do
      fall_ausfuehren "$f" > "$T/mutanten/$id.fall"
      if [ "${ERGEBNIS[$f]}" != GEFALLEN ]; then erg=NICHT_ERKANNT; offen="$offen $f(${ERGEBNIS[$f]})"; fi
    done
    PRUEFER="$PRUEFER_ORIG"
    if [ "$erg" = ERKANNT ]; then
      n_ok=$((n_ok + 1))
      printf '%s [%s] ERKANNT | alle Faelle des Mindestsatzes %s gefallen | %s\n' "$id" "$kl" "$ms" "$gr"
    else
      n_nicht=$((n_nicht + 1))
      printf '%s [%s] NICHT_ERKANNT | nicht gefallen:%s (Mindestsatz %s) | %s\n' "$id" "$kl" "$offen" "$ms" "$gr"
    fi
  done
  echo "--- Zusammenfassung der Mutationen"
  echo "$PM: Mutationen: $MUT_N geprueft, $n_ok erkannt, $n_nicht nicht erkannt, $n_wl wirkungslos"
  mutationsdeckung_pruefen
  nach=$(zustand_baum "$ARBEITSBAUM") || lage_c_pm "Zustand des Arbeitsbaums nicht erhebbar."
  if [ "$SCHNAPP_VORHER" = "$nach" ]; then
    echo "$PM: Arbeitsbaum vor und nach dem ganzen Lauf gleich"
  else
    echo "$PM: ABWEICHUNG: Arbeitsbaum nach dem Lauf veraendert"; abw=1
  fi
  [ "$n_nicht" -eq 0 ] && [ "$n_wl" -eq 0 ] && [ "$MUT_ABW" -eq 0 ] && [ "$abw" -eq 0 ]
}

# =============================================================================
# 20. Hauptablauf
# =============================================================================
hauptablauf() {
  local k grp rc zeit0 zeit1 st
  zeit0=$(date +%s)
  SCHNAPP_VORHER=$(zustand_baum "$ARBEITSBAUM") || lage_c_pm "Zustand des Arbeitsbaums nicht erhebbar."
  fallliste_lesen
  echo "$PM: Kopf -- Arbeitsbaum $ARBEITSBAUM, Commit $ARB_COMMIT ($ARB_SAUBER), Pruefer $PRUEFER sha256 $PRUEFER_SHA, Mutationsdatei $MUT_SHA, Anforderung R3-Q-001, offener Punkt O-15"
  grundbaum_bauen
  st=$?
  if [ "$st" = 2 ]; then
    lage_c_pm "die Objekte des Archivstands $STAND liessen sich nicht in den Grundbaum holen: $(head -n 2 "$T/abruf.fehler" 2>/dev/null | tr '\n' ' ')" "$BESCHAFFUNG_ARCHIV"
  elif [ "$st" != 0 ]; then
    lage_c_pm "Grundbaum nicht herstellbar (Defekt des Pruefmittels oder der Umgebung)."
  fi
  archivpfade_waehlen || lage_c_pm "der Baum des Archivstands liefert nicht die Pfade fuer die Faelle (methodik/*.md, Wurzeldatei, nachweise/, sprints/, .github/, Elternteil)."
  echo "$PM: Modus $MODUS; Archivstand $STAND (abgerufen ueber $ARCHIV_WEG); Grundbaum-Commit $GRUND_COMMIT"
  echo "$PM: Archivpfade der Faelle: $A_DATEI ($A_ZEILEN Zeilen), Wurzeldatei $A_WURZEL ($A_WZEILEN Zeilen), Elternteil $A_ELTERN"
  if [ "$MODUS" = mutationen ]; then
    mutationsdatei_lesen
    PRUEFER_ORIG="$PRUEFER"
    PRUEFER="$T/grundlinie.sh"
    cp "$PRUEFER_ORIG" "$PRUEFER" || lage_c_pm "Kopie des Pruefers nicht anlegbar."
    echo "--- Grundlinie: alle ${#FL_ORDER[@]} Faelle gegen eine unveraenderte Kopie des Pruefers (gezeigt werden nur Faelle, die nicht bestehen)"
    : > "$T/grundlinie.log"
    for k in "${FL_ORDER[@]}"; do fall_ausfuehren "$k" >> "$T/grundlinie.log"; done
    awk '/^B-[0-9]+ / { p = ($0 ~ / (GEFALLEN|NICHT_HERSTELLBAR) [|]/) } p { print }' "$T/grundlinie.log"
  else
    echo "--- Faelle"
    for k in "${FL_ORDER[@]}"; do fall_ausfuehren "$k"; done
  fi
  echo "--- Zusammenfassung der Faelle"
  echo "$PM: ${#FL_ORDER[@]} Faelle: $ANZ_B bestanden, $ANZ_G gefallen, $ANZ_H nicht herstellbar"
  for grp in KB KC GB EB; do
    echo "$PM: Gruppe $grp: ${GRP_N[$grp]:-0} Faelle, ${GRP_B[$grp]:-0} bestanden, ${GRP_G[$grp]:-0} gefallen, ${GRP_H[$grp]:-0} nicht herstellbar"
  done
  if [ "$ANZ_G" -gt 0 ]; then
    echo "$PM: gefallene Faelle (Kennung, Klassen, Herkunft):"
    for k in "${GEFALLENE[@]}"; do echo "  $k ${FL_KLASSEN[$k]} ${FL_HERKUNFT[$k]}"; done
    echo "$PM: gefallene Faelle: ${GEFALLENE[*]}" >&2
  fi
  deckung_pruefen
  rc=0
  if [ "$ANZ_G" -gt 0 ] || [ "$DECK_ABW" -gt 0 ]; then rc=2; fi
  if [ "$MODUS" = mutationen ]; then
    if [ "$rc" != 0 ]; then
      echo "$PM: Grundlinie NICHT bestanden: kein Mutationslauf"
    else
      echo "$PM: Grundlinie bestanden"
      mutationen_fahren || rc=2
    fi
  fi
  zeit1=$(date +%s)
  echo "$PM: Rueckgabewert $rc"
  echo "$PM: Dauer $((zeit1 - zeit0)) s" >&2
  return "$rc"
}
hauptablauf
exit $?
