#!/usr/bin/env bash
# =============================================================================
# scripts/abnahme-abgleich-selbsttest.sh -- Pruefmittel fuer scripts/abnahme-abgleich.sh (Kettenschritt D7)
# =============================================================================
#
# Anforderung R3-Q-001 (das DoD-Gate stuetzt sich auf die Kette). Grundlage: ADR 0002, Abschnitt 5, Nachtrag vom
# 2026-10-29 (Festlegung fuer G3), Zeilen zu D7 und "Faelle, Mutationen und Rueckgabewerte"; docs/12_Freigabe_Grundgeruest.md,
# Abschnitt 4, G3, Festlegungen 1 und 5. Muster: scripts/belege-pruefen-selbsttest.sh. Einheit G3.2.
#
# AUFRUF
#   bash scripts/abnahme-abgleich-selbsttest.sh [--mutationen] [--pruefer <pfad>]
#   Ohne --pruefer gilt scripts/abnahme-abgleich.sh DESSELBEN Baums, in dem dieses Pruefmittel liegt (der Aufrufort spielt
#   keine Rolle). --pruefer nennt ein anderes Skript (relativ zum Aufrufort), etwa eine Attrappe; im Modus --mutationen das
#   Skript, von dem die Mutanten abgeleitet werden.
#
# RUECKGABEWERT
#   0  alle Faelle bestanden und die Deckung ohne Abweichung ("nicht herstellbar" zaehlt weder als bestanden noch als gefallen,
#      wird gemeldet und beruehrt den Rueckgabewert nicht, GP-A1). Im Modus --mutationen zusaetzlich: jede Mutation erkannt,
#      keine wirkungslos, die Mutationsdeckung ohne Abweichung, der Arbeitsbaum nach dem Lauf unveraendert
#   2  mindestens ein Fall gefallen oder eine Abweichung der Deckung; im Modus --mutationen: die Grundlinie besteht nicht, oder
#      eine Mutation ist nicht erkannt oder wirkungslos, oder die Mutationsdeckung weicht ab, oder der Arbeitsbaum ist veraendert
#   3  Lage C des Pruefmittels: der Lauf hat nicht stattgefunden (fehlendes Werkzeug, unbekannter Parameter, fehlendes oder
#      formfehlerhaftes Skript oder Mutationsdatei, kein Git-Arbeitsbaum um das Pruefmittel, ein Defekt des Pruefmittels)
#
# WERKZEUGE: bash, git, grep, sed (GNU, mit --sandbox), sort, mktemp, cp, mv, rm, mkdir, ln, chmod, cat, head, tr, cut, env, timeout,
#   cmp, sha256sum, readlink, id, date. Kein Netz, kein Python, kein uv, kein Docker.
#
# UMGEBUNG JEDES LAUFS: Das Skript laeuft unter "env -i" mit LC_ALL=C, TZ=UTC, HOME auf einem leeren Verzeichnis,
#   GIT_CONFIG_NOSYSTEM=1, GIT_CONFIG_GLOBAL=/dev/null und fester Identitaet; Zeitgrenze 60 s je Aufruf. Die git-Aufrufe des
#   Pruefmittels loeschen vorher die git-Variablen des Aufrufers.
#
# BAUM UND FAELLE: Ein Grundbaum je Lauf unter mktemp -d, ausserhalb des Arbeitsbaums (Aufraeumen per trap): git init, ein
#   synthetischer Backlog mit vier Eintraegen (R3-A-001 mit zwei Testnamen, R3-A-002 mit einem, R3-A-003 ohne, R3-A-004 mit einem),
#   die Ausnahmeliste, docs/ziel.md. Je Fall eine Kopie des Grundbaums (cp -a), die Aenderung, eine Kopie des geprueften Skripts nach
#   scripts/abnahme-abgleich.sh der Kopie (das Skript bestimmt seine Wurzel aus seinem Ort) und ein Lauf mit der Sammeldatei als
#   Argument. Die Sammeldatei liegt ausserhalb des Baums. Grundfall: zwei gesammelte Tests (R3-A-001_erster_test, R3-A-001_zweiter_test),
#   R3-A-002 bis R3-A-004 ausgenommen, R3-A-001 faellig: kein Fund.
#
# SOLL-ARTEN (Spalte 3 der Fallliste)
#   fund                Rueckgabewert 2; die Zeilen unter "=== Funde" sind genau die erwartete Menge (Klasse, Schluessel, Teil des
#                       Grundes); "Befunde: n" gleich deren Zahl; die Zeilen sind sortiert; die Fehlerausgabe ist leer
#   kein-fund           Rueckgabewert 0, keine Zeile unter "=== Funde", "Befunde: 0", Fehlerausgabe leer
#   kein-fund+ausgabe   wie kein-fund, dazu Aussagen ueber die Standardausgabe
#   lage-c              Rueckgabewert 3 vor dem Urteil (KC-1 bis KC-6); Fehlerausgabe mit "LAGE C" und der Kennung; Standardausgabe ohne
#                       "Befunde:" und ohne "=== Funde"
#   lage-c+funde        Rueckgabewert 3 nach dem Urteil (KC-7); Fehlerausgabe mit "LAGE C", der Kennung und den Teilen aus lc_mit; die Funde
#                       stehen ungeordnet in derselben Standardausgabe (genau die erwartete Menge), "Befunde: n" gleich deren Zahl
#   abbruch             Abbruch des Skripts mit Rueckgabewert 1 (Makefile: A_FAIL), ohne "Befunde:" in der Standardausgabe (zur Zeit ohne Fall: A-208 misst seit ST-G3-11 Funde)
#   gleich              zwei Laeufe (mit gleichem oder verschiedenem Umfeld): Standardausgabe, Fehlerausgabe, Rueckgabewert gleich
#   schreibfrei         der Wegwerf-Baum ist nach dem Lauf wie davor, einschliesslich seines Git-Verzeichnisses
#   statisch            Aussage ueber den Text des geprueften Skripts, ohne Lauf
#   arbeitsbaum         der Arbeitsbaum ist nach dem ganzen Lauf wie davor; der Fall steht als letzter der Liste
#
# FALLLISTE: Der Datenblock unten ("#F|"-Zeilen: Kennung|Klassen|Soll|Herkunft|Gegenstand) ist die maschinenlesbare Liste. Jede Kennung
#   hat genau eine Funktion f_A<nnn> weiter unten und umgekehrt (mechanisch geprueft). Kennungen A-nnn sind dauerhaft und werden nie
#   wiederverwendet. Die erwarteten Funde stehen in den Fallfunktionen.
#
# DECKUNG (als eigener Abschnitt der Ausgabe, nicht in der Zaehlung der Faelle): jede Kennung KA, KC, EA und GA im Kopfkommentar des
#   geprueften Skripts hat Faelle (KA: mindestens einen mit Soll Fund und einen mit Soll kein Fund; die uebrigen mindestens einen);
#   jede Klasse, die ein Fall nennt, steht im Kopfkommentar; jede Gruppe hat mindestens eine Kennung. Der Kopfkommentar nennt die
#   Kennungen einzeln, ohne Bereichsschreibweise.
#
# MODUS --mutationen: Mutationsdatei scripts/abnahme-abgleich-mutationen.txt im Verzeichnis dieses Skripts
#   Zeilenform: Kennung AM-nnn, Tabulator, Klasse (KA-, KC- oder EA-Kennung), Tabulator, sed-Ausdruck (mit sed -E --sandbox auf eine
#   Wegwerfkopie des Skripts angewandt), Tabulator, Mindestsatz (Fallkennungen durch Komma), Tabulator, Grund. Zeilen mit # am Anfang
#   und Leerzeilen werden uebergangen. Nur ASCII, genau vier Tabulatoren je Zeile; eine Form, die der Modus nicht liest, ist Lage C.
#   Ablauf: (1) Grundlinie: alle Faelle und die Deckung gegen eine unveraenderte Kopie; besteht sie nicht, endet der Modus mit 2 ohne
#   Mutation. (2) Je Mutation eine Kopie; ist sie byte-gleich mit dem Skript, verwirft bash -n sie oder endet sed mit einem Fehler,
#   ist die Mutation wirkungslos. (3) Erkannt ist sie, wenn jeder Fall ihres Mindestsatzes gegen die Mutante faellt; nur diese Faelle
#   laufen gegen sie. (4) Schluss: geprueft, erkannt, nicht erkannt, wirkungslos; die Mutationsdeckung (jede Klasse KA, KC und EA des
#   Kopfkommentars hat eine Mutation, deren Mindestsatz einen Fall dieser Klasse enthaelt); der Vergleich des Arbeitsbaums vor und nach.
#
# GRENZEN DES PRUEFMITTELS
#   GP-A1  Die Faelle "nicht lesbar" (A-133, A-146, A-164) sind als root nicht herstellbar; sie werden gezaehlt und gemeldet, ohne Mutation.
#   GP-A2  Der Fall A-171 braucht die Spracheinstellung C.utf8; fehlt sie, zaehlt er "nicht herstellbar".
#   GP-A3  Faelle mit Soll fund oder kein-fund messen die Fehlerausgabe nur auf "leer"; der Wortlaut der Meldungen von Lage C ist nur an
#          Kennung und Stichwort gemessen. Ausnahme: die Faelle mit Lesefehler (A-208, A-215, A-216) verlangen auf der Fehlerausgabe
#          allein Zeilen mit "read error".
#   GP-A4  Die statischen Faelle (A-185, A-210 bis A-213) lesen den Text mit benannten Mustern: ein Befehl, den ein Muster nicht nennt (die Liste
#          der Befehle in A-210), bleibt unbemerkt; die uebrigen Zweige prueft der Static Software Tester am Code.
#   GP-A5  Die Verknuepfungen (A-097, A-132, A-142, A-143, A-162, A-163) setzen ein Dateisystem mit symbolischen Verknuepfungen voraus.
#   GP-A6  Der Fall A-170 setzt voraus, dass die Variablen des Aufrufers (GIT_DIR und weitere) das Urteil des Skripts ohne das Loeschen
#          aendern wuerden; er misst die Wirkung, nicht die Liste der geloeschten Variablen. Ein Name, der aus der Liste im Skript faellt,
#          ohne dass ein Fall ihn nennt, bleibt unbemerkt.
#   GP-A7  GIT_NO_REPLACE_OBJECTS=1 im Skript hat auf git rev-parse --show-toplevel keine beobachtbare Wirkung: dazu gibt es weder Fall noch Mutation
#          (Vorgabe der Festlegung zu den Aufrufen von git).
#   GP-A8  Die Faelle A-208 und A-217 (GA-7) lesen /proc/self/mem; sie setzen voraus, dass schon das erste Lesen mit einem Ein-/Ausgabefehler
#          endet (Linux); sonst zaehlen sie "nicht herstellbar". A-208 misst die Folge am Dateiende (Sammlung leer: Funde), A-217 die
#          Annahme, dass bash die Variable bei einem Lesefehler unveraendert laesst.
#   GP-A9  Die Faelle A-180 und A-181 ersetzen sort im Suchpfad durch ein Skript unter /bin/sh (Rueckgabewert 2 beziehungsweise nur die erste
#          Zeile der Ausgabe); sie messen die Reaktion auf einen Fehler von sort, nicht einen echten Defekt.
#   GP-A10 Die Faelle A-214 bis A-216 ersetzen die Funktion read des Skripts (Umgebungsvariable BASH_FUNC_read%%) und lassen sie ab
#          dem zweiten Aufruf in der Lese-Funktion wie bei einem Ein-/Ausgabefehler enden; ein echter Lesefehler nach der ersten Zeile
#          ist ohne Mittel ausserhalb des Pruefmittels nicht herstellbar. Dass die Eingebaute sich so verhaelt, misst A-217.
#
#F|A-001|EA-4,KA-4,KC-7|kein-fund+ausgabe|Grundfall|Grundbaum: ein faelliger Eintrag mit zwei gesammelten Tests, drei Ausnahmen; Zaehlzeilen
#F|A-002|EA-5,GA-4|kein-fund|Q2|Namen in Formulierung, Achtung und Nachweis (auch fehlerhafte) sind keine Testnamen; nur Abnahmefeldzeilen zaehlen
#F|A-003|EA-5,KA-4|fund|Q2|Zeilen "Abnahme, maschinell:" und "Abnahme, menschlich:" werden gelesen: der Name der zweiten Zeile ohne Test
#F|A-004|EA-5,KA-4|kein-fund|Q2 (Gegenprobe)|dieselben zwei Zeilen, beide Namen gesammelt
#F|A-005|EA-5|kein-fund|Q1|nur Ueberschriften der Ebene drei mit Kennung sind Eintraege; "## R3-A-009" und "#### R3-A-010" beenden den Block, eine Abnahmezeile dahinter gehoert zu keinem Eintrag
#F|A-010|KA-1,EA-4|fund|Regel a|gesammelter Test ohne Kennung im Namen
#F|A-011|KA-1|fund|Regel a|sieben Schreibweisen ohne die Form test_R3_<Buchstabe>_<drei Ziffern>_
#F|A-012|KA-1,KA-4|kein-fund|Regel a (Gegenprobe)|Knotenkennungen mit Klasse, Parameterteil und :: im Parameterteil gelten mit dem Funktionsnamen
#F|A-013|KA-1|fund|Regel a|Knotenkennung ohne Funktionsnamen (Parameterteil allein)
#F|A-020|KA-2|fund|Regel a|Kennung mit Ziffern ohne Eintrag
#F|A-021|KA-2|fund|Regel a|Kennung mit Buchstaben ohne Eintrag
#F|A-022|KA-2|kein-fund|Regel a (Gegenprobe)|Kennung mit anderem Buchstaben und vorhandenem Eintrag
#F|A-030|KA-3|fund|Regel a|Name mit richtiger Kennung und fremdem Rest
#F|A-031|KA-3|fund|Regel a|Name mit der Kennung von R3-A-001 und dem Rest eines Namens von R3-A-002
#F|A-032|KA-3|fund|Regel a|Grossschreibung, Unterstrich am Ende und Teil des Namens: je kein abgebildeter Testname
#F|A-033|KA-3,KA-8|fund|Regel a|gesammelter Test eines ausgenommenen Eintrags mit falschem Namen: KA-3 und, weil ein Test besteht, KA-8
#F|A-034|KA-3|fund|Regel a|Name mit Zeichen ausserhalb von ASCII im Rest
#F|A-035|KA-3|kein-fund|Regel a (Gegenprobe)|Namen mit Ziffern und Unterstrichen im Rest, gesammelt wie abgebildet
#F|A-040|KA-4,GA-2|fund|Regel b|nur einer der zwei Tests gesammelt: der andere Name ist ein Fund (ein Test ohne Marker fehlt in der Sammeldatei)
#F|A-041|KA-4,GA-3|fund|Regel b, c|leere Sammlung bei faelligem Eintrag: beide Namen sind Funde (Abnahmetest ausserhalb von pytest fehlt in der Sammeldatei)
#F|A-042|KA-4,EA-5|fund|Q4|Zeilen mit dem Namen, aber ohne ".py::", sind keine Knotenkennungen
#F|A-043|KA-4,EA-5|kein-fund|Regel c|leere Sammlung, aber alle Eintraege ausgenommen: kein Fund
#F|A-044|KA-4|kein-fund|Q4 (Gegenprobe)|derselbe Name in zwei Modulen gesammelt
#F|A-050|KA-5|fund|Regel b|faelliger Eintrag mit "Nicht formulierbar" und ohne Ausnahme
#F|A-051|KA-5|kein-fund|Regel b (Gegenprobe)|derselbe Eintrag mit Ausnahme "nicht begonnen, Etappe 3"
#F|A-052|KA-5|fund|Regel b|faelliger Eintrag ohne jede Abnahmefeldzeile
#F|A-053|KA-5,KA-6|fund|Q2|faelliger Eintrag, dessen Abnahmezeile nur einen Namen eines anderen Eintrags nennt, der dort steht: KA-5, kein KA-6
#F|A-060|KA-6|fund|Q1|Kennung mit zwei Ueberschriften
#F|A-061|KA-6|fund|Q2|eigene Testnamen ohne Abbildung: Grossbuchstabe, Bindestrich, leerer Rest, Leerzeichen
#F|A-062|KA-6|fund|Q2|fremder Testname, den sein Eintrag nicht fuehrt
#F|A-063|KA-6|kein-fund|Q2 (Gegenprobe)|fremder Testname, den sein Eintrag fuehrt
#F|A-064|KA-6|fund|Q2|fremder Testname mit einer Kennung ohne Eintrag
#F|A-065|KA-6|fund|Q2|fremder Testname mit Grossbuchstabe im Rest
#F|A-066|KA-6|kein-fund|Q2 (Gegenprobe)|Woerter in Rueckwaertsakzenten ohne Kennung und Unterstrich, die Kennung allein, derselbe eigene Name zweimal
#F|A-067|KA-6|fund|Q1|dieselbe Kennung in zwei Backlog-Dateien
#F|A-070|KA-7|fund|Q6|Zeile ohne Tabulator (Leerzeichen statt Tabulator) und Zeile mit zwei Tabulatoren
#F|A-071|KA-7|fund|Q6|Kennung ausserhalb der Form: zwei Ziffern, Kleinschreibung, vier Ziffern, fuehrendes Leerzeichen
#F|A-072|KA-7|fund|Q6|Grund ausserhalb der drei Wortlaute, acht Schreibweisen
#F|A-073|KA-7|fund|Q6|Kennung doppelt: die zweite Zeile ist der Fund, die erste gilt
#F|A-074|KA-7|fund|Q6|Pfad ohne repository-relative Form: absolut und Segment ..
#F|A-075|KA-7|fund|Q6|Zeichen ausserhalb von ASCII und Wagenruecklauf am Zeilenende
#F|A-076|KA-7|kein-fund|Q6 (Gegenprobe)|Kommentarzeilen (auch mit Tabulator) und Leerzeilen werden uebergangen
#F|A-077|KA-7|fund|Q6|Zeile nur aus Leerzeichen und Zeile nur aus einem Tabulator
#F|A-078|KA-7,KA-4|fund|Q5|Zeile mit Formfehler nimmt den Eintrag nicht aus: KA-7 und KA-4
#F|A-079|KA-7|kein-fund|Q6 (Gegenprobe)|letzte Zeile ohne Schlussumbruch, gueltig
#F|A-080|KA-7|fund|Q6|letzte Zeile ohne Schlussumbruch, mit Formfehler
#F|A-090|KA-8|fund|Q6|Kennung ohne Ueberschrift im Backlog
#F|A-091|KA-8|fund|Q6|Ausnahme fuer einen Eintrag, zu dem ein Abnahmetest gesammelt ist
#F|A-092|KA-8|fund|Q6|Etappe im Grund ungleich dem Feld Etappe
#F|A-093|KA-8|fund|Q6|Feld Etappe fehlt (Kopfzeile ohne Feld und Eintrag ohne Kopfzeile)
#F|A-094|KA-8|fund|Q6|"zweite Fassung" bei Etappe 1 und "Etappe 1" bei zweite Fassung
#F|A-095|KA-8|fund|Q6|Pfad besteht nicht
#F|A-096|KA-8|kein-fund|Q6 (Gegenprobe)|Pfad als Verzeichnis mit und ohne Schraegstrich, mit ./ davor
#F|A-097|KA-8|fund|Q6|Pfad ueber eine Verknuepfung (Verzeichnis und Datei)
#F|A-098|KA-8|kein-fund|Q6 (Gegenprobe)|Etappe 0 und Etappe 6 bei passendem Feld
#F|A-099|KA-8,EA-5|kein-fund|Q1 (Gegenprobe)|Feld Etappe mit Leerraum und einem Folgefeld hinter dem Mittelpunkt
#F|A-110|KC-1|lage-c|Aufruf|kein Argument
#F|A-111|KC-1|lage-c|Aufruf|zwei Argumente
#F|A-112|KC-1|lage-c|Aufruf|leeres Argument
#F|A-113|KC-2|lage-c|Werkzeuge|git fehlt im Suchpfad
#F|A-114|KC-2|lage-c|Werkzeuge|sort fehlt im Suchpfad
#F|A-115|KC-2,KC-4|lage-c|Reihenfolge|git fehlt und die Sammeldatei fehlt: gemeldet wird git
#F|A-116|KC-2|kein-fund|Werkzeuge (Gegenprobe)|Suchpfad nur mit git und sort: Grundfall bestanden
#F|A-120|KC-3|lage-c|Arbeitsbaum|kein Git-Arbeitsbaum
#F|A-121|KC-3|lage-c|Arbeitsbaum|die Wurzel des Skripts liegt unterhalb der obersten Ebene eines Arbeitsbaums
#F|A-122|KC-3,EA-1|kein-fund|Arbeitsbaum (Gegenprobe)|Aufruf aus dem Arbeitsverzeichnis eines fremden Repositories: das Urteil gilt dem Baum des Skripts
#F|A-130|KC-4|lage-c|Sammeldatei|Sammeldatei fehlt
#F|A-131|KC-4|lage-c|Sammeldatei|Sammeldatei ist ein Verzeichnis
#F|A-132|KC-4|lage-c|Sammeldatei|Sammeldatei ist eine Verknuepfung auf eine regulaere Datei
#F|A-133|KC-4|lage-c|Sammeldatei|Sammeldatei nicht lesbar
#F|A-134|KC-4|kein-fund|Sammeldatei (Gegenprobe)|relativer Pfad der Sammeldatei bei anderem Arbeitsverzeichnis
#F|A-140|KC-5|lage-c|Backlog|keine Datei nach dem Suchmuster
#F|A-141|KC-5|lage-c|Backlog|Eintraege ohne jede Abnahmefeldzeile
#F|A-142|KC-5|lage-c|Backlog|Backlog-Datei ist eine Verknuepfung auf eine Datei ausserhalb
#F|A-143|KC-5|lage-c|Backlog|docs ist eine Verknuepfung
#F|A-144|KC-5|lage-c|Backlog|die Datei nach dem Suchmuster ist ein Verzeichnis
#F|A-145|KC-5|lage-c|Backlog|Abnahmefeldzeilen nur ausserhalb von Eintraegen
#F|A-146|KC-5|lage-c|Backlog|Backlog nicht lesbar
#F|A-147|KC-5,EA-5|kein-fund|Backlog (Gegenprobe)|zwei Dateien nach dem Suchmuster, verschiedene Kennungen: beide gelesen
#F|A-148|KC-5,EA-5|kein-fund|Backlog (Gegenprobe)|Dateien ausserhalb des Suchmusters (Unterverzeichnis, andere Endung) werden nicht gelesen
#F|A-160|KC-6|lage-c|Ausnahmeliste|Ausnahmeliste fehlt
#F|A-161|KC-6|lage-c|Ausnahmeliste|Ausnahmeliste ist ein Verzeichnis
#F|A-162|KC-6|lage-c|Ausnahmeliste|Ausnahmeliste ist eine Verknuepfung auf eine Datei ausserhalb
#F|A-163|KC-6|lage-c|Ausnahmeliste|scripts ist eine Verknuepfung
#F|A-164|KC-6|lage-c|Ausnahmeliste|Ausnahmeliste nicht lesbar
#F|A-165|KC-6|kein-fund|Ausnahmeliste (Gegenprobe)|leere Ausnahmeliste ist zulaessig
#F|A-166|KC-4,KC-5|lage-c|Reihenfolge|Sammeldatei fehlt und Backlog fehlt: gemeldet wird die Sammeldatei
#F|A-167|KC-5,KC-6|lage-c|Reihenfolge|Backlog fehlt und Ausnahmeliste fehlt: gemeldet wird der Backlog
#F|A-170|EA-1|gleich|Umfeld|Lauf ohne Variablen gegen Lauf mit den git-Variablen des Aufrufers auf ein fremdes Repository
#F|A-171|EA-1|gleich|Umfeld|Lauf mit LC_ALL=C gegen Lauf mit LC_ALL=C.utf8: ein Zeichen ausserhalb von ASCII bleibt ein Fund
#F|A-172|EA-2|schreibfrei|Kettengrundsatz|Grundfall: der Baum ist nach dem Lauf wie davor
#F|A-173|EA-2|schreibfrei|Kettengrundsatz|Fallbaum mit vielen Funden: der Baum ist nach dem Lauf wie davor
#F|A-174|EA-3|gleich|K4|zweimal derselbe Lauf mit vielen Funden: gleiche Ausgabe
#F|A-175|EA-4|fund|Ausgabeform|zehn Funde aus allen acht Klassen: sortiert, Zahl gleich "Befunde: n"
#F|A-176|EA-4|kein-fund+ausgabe|Ausgabeform|Zaehlzeilen, Abschnitt der Funde, Trennzeile und Schlusszeile im Grundfall
#F|A-180|KC-7|lage-c+funde|Ausgabe (ST-G3-01, ST-G3-04)|sort endet mit Rueckgabewert 2: die erfassten Funde stehen ungeordnet in der Ausgabe, Lage C vor dem Fund
#F|A-181|KC-7|lage-c+funde|Ausgabe (ST-G3-01)|sort liefert nur die erste Zeile (Rueckgabewert 0): die Zeilenzahl der Antwort wird gegen die erfasste Zahl gehalten, Lage C
#F|A-182|KC-7,EA-4|fund|Ausgabe (ST-G3-01)|800 Funde, Ausgabe ueber 64 KiB: die Zahl der Fundzeilen ist gleich "Befunde: 800", ohne Lage C
#F|A-183|EA-2|statisch|Kettengrundsatz (ST-G3-01)|ausserhalb von Kommentarzeilen steht kein Here-String (mit Probe der Pruefung)
#F|A-185|KC-7|statisch|Ausgabe (ST-G3-12)|die Zeilen der Antwort von sort werden nicht mit einer Ersetzung des Musters ueber die ganze Antwort gezaehlt (quadratisch; mit Probe der Pruefung)
#F|A-200|GA-1|kein-fund|Grenze GA-1|ein uebersprungener oder als xfail markierter Test gilt als gesammelt (Durchlass)
#F|A-201|GA-2|fund|Grenze GA-2|Test ohne Marker fehlt in der Sammeldatei: der Eintrag bleibt faellig (Fehlalarm)
#F|A-202|GA-3|fund|Grenze GA-3|Test ausserhalb von pytest, keine Ausnahme: der Eintrag ist faellig (Fehlalarm)
#F|A-203|GA-3|kein-fund|Grenze GA-3 (Gegenprobe)|derselbe Eintrag mit der Ausnahme "geprueft ausserhalb von pytest"
#F|A-204|GA-4|kein-fund|Grenze GA-4|fehlerhafte Namen ausserhalb der Abnahmefeldzeilen und in eingerueckter Zeile bleiben ohne Fund (Durchlass)
#F|A-205|GA-5|fund|Grenze GA-5|Ueberschrift und Abnahmefeldzeile in einem Zaun gelten als Eintrag (Fehlalarm)
#F|A-206|GA-6|kein-fund|Grenze GA-6|eine von Hand geschriebene Sammeldatei gilt (Durchlass)
#F|A-207|GA-5|kein-fund+ausgabe|Grenze GA-5 (ST-G3-05)|Zitate "> ### R3-..." und "> - **Abnahme:**" sind weder Eintrag noch Abnahmefeldzeile und beenden keinen Block
#F|A-208|GA-7|fund|Grenze GA-7 (ST-G3-08, ST-G3-11)|Lesefehler beim ersten Lesen der Sammeldatei (/proc/self/mem): das Lesen endet wie am Dateiende, die Sammlung ist leer, die Tests fehlen (Funde statt Abbruch)
#F|A-210|KC-2|statisch|Werkzeuge|ausserhalb von Kommentarzeilen ruft das Skript keinen Befehl der Liste auf (mit Probe der Pruefung)
#F|A-211|KC-2|statisch|Werkzeuge|die Pruefung der bash-Version steht vor der ersten Erklaerung eines assoziativen Feldes
#F|A-212|EA-3|statisch|K4|ausserhalb von Kommentarzeilen keine Zeit, keine Zufallszahl, keine Prozessnummer (mit Probe der Pruefung)
#F|A-213|EA-1|statisch|Umfeld|LC_ALL=C wird vor der ersten Pruefung des Suchpfads gesetzt
#F|A-214|EA-6,GA-7|lage-c|Beendigung (ST-G3-11)|Lesefehler nach der ersten Zeile des Backlogs: das Lesen endet wie am Dateiende, die zuletzt gelesene Zeile wird nicht erneut verarbeitet, Lage C backlog-abnahmekriterien
#F|A-215|EA-6,GA-7|fund|Beendigung (ST-G3-11)|Lesefehler nach der ersten Zeile der Ausnahmeliste: das Lesen endet wie am Dateiende, die Ausnahme fehlt, der Eintrag ist faellig
#F|A-216|EA-6,GA-7|fund|Beendigung (ST-G3-11)|Lesefehler nach der ersten Zeile der Sammeldatei: das Lesen endet wie am Dateiende, der zweite Test fehlt
#F|A-217|GA-7|statisch|Beendigung (ST-G3-11)|bash laesst die Variable bei einem Lesefehler unveraendert und liefert 1 (Annahme der Faelle A-208 und A-214 bis A-216)
#F|A-218|EA-1|kein-fund+ausgabe|Umfeld|CDPATH des Aufrufers aendert die Wurzel bei relativem Aufruf (bash scripts/abnahme-abgleich.sh <Sammeldatei>, wie make ihn macht) nicht: Urteil wie ohne CDPATH, keine Lage C, kein Pfad auf der Standardausgabe
#F|A-299|EA-2|arbeitsbaum|Kettengrundsatz|der Arbeitsbaum des Aufrufers ist nach dem ganzen Lauf gleich wie davor
#

set -uo pipefail

# -----------------------------------------------------------------------------
# 0. Umgebung des Aufrufers: git-eigene Variablen loeschen, Sortierung festlegen
# -----------------------------------------------------------------------------
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_OBJECT_DIRECTORY GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_COMMON_DIR GIT_NAMESPACE GIT_CEILING_DIRECTORIES GIT_DISCOVERY_ACROSS_FILESYSTEM GIT_SHALLOW_FILE GIT_GLOB_PATHSPECS GIT_NOGLOB_PATHSPECS GIT_LITERAL_PATHSPECS GIT_ICASE_PATHSPECS 2>/dev/null || true
unset "${!GIT_TRACE@}" 2>/dev/null || true
export LC_ALL=C

PM="abnahme-abgleich-selbsttest"
FALL_ZEITGRENZE=60
WERKZEUGE_PM="bash git grep sed sort mktemp cp mv rm mkdir ln chmod cat head tr cut env timeout cmp sha256sum readlink id date"
# Werkzeuge, die das gepruefte Skript aufruft (geschlossene Liste im Kopfkommentar des Skripts); der Suchpfad des Falls A-116 enthaelt
# genau sie
KASTEN_VOLL="git sort"

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
# 2. Werkzeuge des Pruefmittels
# -----------------------------------------------------------------------------
for w in $WERKZEUGE_PM; do
  command -v "$w" >/dev/null 2>&1 || lage_c_pm "Werkzeug '$w' fehlt." "Werkzeug installieren"
done
# Der Mutationsmodus wendet die Ausdruecke der Mutationsdatei mit sed -E --sandbox an (e, r und w sind verboten); versteht sed die
# Option nicht oder ignoriert er sie, ist das Lage C des Pruefmittels.
if ! printf 'x\n' | sed -E --sandbox -e 's/x/y/' >/dev/null 2>&1 || printf 'x\n' | sed -E --sandbox -e 'w /dev/null' >/dev/null 2>&1; then
  lage_c_pm "sed versteht die Option --sandbox nicht (oder ignoriert sie)." "GNU sed ab Version 4.3 installieren"
fi
BASH_BIN=$(command -v bash)
case "$BASH_BIN" in
  /*) ;;
  *) lage_c_pm "bash ist nicht als absoluter Pfad aufloesbar ('$BASH_BIN')." ;;
esac

# -----------------------------------------------------------------------------
# 3. Arbeitsbaum = Baum, in dem dieses Pruefmittel liegt; der Aufrufort spielt keine Rolle
# -----------------------------------------------------------------------------
SKRIPT_QUELLE="${BASH_SOURCE[0]}"
case "$SKRIPT_QUELLE" in */*) SKRIPT_VERZ_ROH="${SKRIPT_QUELLE%/*}" ;; *) SKRIPT_VERZ_ROH="." ;; esac
SKRIPT_VERZ=$(cd "$SKRIPT_VERZ_ROH" >/dev/null 2>&1 && pwd -P) || lage_c_pm "Verzeichnis des Skripts nicht aufloesbar."
ARBEITSBAUM=$(git -C "$SKRIPT_VERZ" rev-parse --show-toplevel 2>/dev/null) || lage_c_pm "kein Git-Arbeitsbaum um das Verzeichnis des Skripts ($SKRIPT_VERZ)."
if [ -n "$PRUEFER_ARG" ]; then
  case "$PRUEFER_ARG" in
    /*) PRUEFER="$PRUEFER_ARG" ;;
    *) PRUEFER="$PWD/$PRUEFER_ARG" ;;
  esac
else
  PRUEFER="$ARBEITSBAUM/scripts/abnahme-abgleich.sh"
fi
[ -f "$PRUEFER" ] || lage_c_pm "geprueftes Skript nicht gefunden: $PRUEFER"
[ -r "$PRUEFER" ] || lage_c_pm "geprueftes Skript nicht lesbar: $PRUEFER"
ARB_COMMIT=$(git -C "$ARBEITSBAUM" rev-parse HEAD 2>/dev/null) || ARB_COMMIT="unbekannt"
PRUEFER_SHA=$(sha256sum "$PRUEFER" | cut -c1-16)
MUTATIONSDATEI="$SKRIPT_VERZ/abnahme-abgleich-mutationen.txt"
MUT_SHA="-"
if [ -f "$MUTATIONSDATEI" ] && [ -r "$MUTATIONSDATEI" ]; then
  MUT_SHA=$(sha256sum "$MUTATIONSDATEI" | cut -c1-16)
elif [ "$MODUS" = "mutationen" ]; then
  lage_c_pm "Mutationsdatei fehlt oder ist nicht lesbar: $MUTATIONSDATEI"
fi

# -----------------------------------------------------------------------------
# 4. Schnappschuss des Arbeitsbaums VOR jeder weiteren Handlung: Statusliste und Pruefsumme jeder Datei, die versioniert oder
#    unversioniert und nicht ignoriert ist
# -----------------------------------------------------------------------------
schnappschuss() { # schnappschuss <verzeichnis> : Zustand auf der Standardausgabe
  local d="$1" f
  env GIT_OPTIONAL_LOCKS=0 git -C "$d" status --porcelain --untracked-files=all || return 1
  echo "--- Pruefsummen"
  git -C "$d" ls-files -z -c -o --exclude-standard | sort -z -u | while IFS= read -r -d '' f; do
    if [ -L "$d/$f" ]; then
      printf 'L %s\n' "$f"
    elif [ -f "$d/$f" ]; then
      printf 'F %s %s\n' "$(sha256sum < "$d/$f" | cut -c1-64)" "$f"
    else
      printf '? %s\n' "$f"
    fi
  done
  return 0
}

# -----------------------------------------------------------------------------
# 5. Wegwerfverzeichnis ausserhalb des Arbeitsbaums, Aufraeumen auch bei Abbruch
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
# 6. Umgebung jedes Laufs: LC_ALL=C, TZ=UTC, HOME auf ein leeres Verzeichnis, GIT_CONFIG_NOSYSTEM=1, GIT_CONFIG_GLOBAL=/dev/null,
#    feste Identitaet. Das Skript laeuft unter "env -i" mit genau diesen Variablen.
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
  "GIT_AUTHOR_NAME=Selbsttest"
  "GIT_AUTHOR_EMAIL=selbsttest@example.invalid"
  "GIT_AUTHOR_DATE=2026-01-01T00:00:00Z"
  "GIT_COMMITTER_NAME=Selbsttest"
  "GIT_COMMITTER_EMAIL=selbsttest@example.invalid"
  "GIT_COMMITTER_DATE=2026-01-01T00:00:00Z"
)
gitg() { env "${ENV_BASIS[@]}" git "$@"; }

# =============================================================================
# 7. Hilfen fuer die Fallfunktionen (f_A...): alle Pfade relativ zu $BAUM
# =============================================================================
BT='`'
ED=$'\xe2\x80\x94'
MP=$'\xc2\xb7'
TAB=$'\t'
FALL_K="?"

herstellung_fehler() { # ein Fehler hier ist ein Defekt des Pruefmittels
  echo "$PM: FEHLER -- Herstellung des Falls $FALL_K fehlgeschlagen: $*" >&2
  exit 3
}
zeilen() { # zeilen <pfad> <zeile>... : jede Zeile mit Zeilenumbruch
  local p="$1"; shift
  mkdir -p "${BAUM}/${p%/*}" 2>/dev/null
  printf '%s\n' "$@" > "$BAUM/$p" || herstellung_fehler "zeilen $p"
}
zeilen_an() { # zeilen_an <pfad> <zeile>... : anhaengen
  local p="$1"; shift
  printf '%s\n' "$@" >> "$BAUM/$p" || herstellung_fehler "zeilen_an $p"
}
zeilenzahl() { # zeilenzahl <datei> : setzt ZN auf die Zahl der Zeilen (auch ohne Schlussumbruch)
  local z
  ZN=0
  while IFS= read -r z || [ -n "$z" ]; do ZN=$((ZN + 1)); done < "$1"
}
kopfzeile() { # kopfzeile <etappe> : Kopfzeile eines Eintrags mit dem Feld Etappe
  printf -- '- **Art:** Funktional %s **Kano:** Basisfaktor %s **Pruefaufwand:** 2 h %s **Quelle:** 1.1 %s **Etappe:** %s\n' "$MP" "$MP" "$MP" "$MP" "$1"
}
bl_neu() { # Backlog neu mit Kopf, ohne Eintraege
  printf '# Product Backlog (synthetisch)\n\nEinleitung.\n\n# Etappe 1 %s Fundament\n\n' "$ED" > "$BAUM/docs/05_Product_Backlog.md" || herstellung_fehler "bl_neu"
}
eintrag() { # eintrag <kennung> <etappe> [<zeile>...] : Ueberschrift, Kopfzeile, die Zeilen und eine Leerzeile an den Backlog haengen
  local id="$1" et="$2"; shift 2
  {
    printf '### %s %s Titel von %s\n' "$id" "$ED" "$id"
    kopfzeile "$et"
    if [ "$#" -gt 0 ]; then printf '%s\n' "$@"; fi
    printf '\n'
  } >> "$BAUM/docs/05_Product_Backlog.md" || herstellung_fehler "eintrag $id"
}
abn() { # abn <kennung> <rest>... : Abnahmefeldzeile mit je einem Testnamen in Rueckwaertsakzenten
  local id="$1" z="- **Abnahme:** " r; shift
  for r in "$@"; do z="${z}Test ${BT}${id}_${r}${BT} $ED Text. "; done
  printf '%s\n' "${z% }"
}
ausn_neu() { : > "$BAUM/scripts/abnahme-ausnahmen.txt" || herstellung_fehler "ausn_neu"; }
ausn() { # ausn <kennung> <grund> : Zeile der Ausnahmeliste (Kennung, Tabulator, Grund); setzt ZN auf die Nummer der Zeile
  printf '%s\t%s\n' "$1" "$2" >> "$BAUM/scripts/abnahme-ausnahmen.txt" || herstellung_fehler "ausn"
  zeilenzahl "$BAUM/scripts/abnahme-ausnahmen.txt"
}
ausn_roh() { # ausn_roh <zeile> : eine Zeile der Ausnahmeliste wortgleich; setzt ZN
  printf '%s\n' "$1" >> "$BAUM/scripts/abnahme-ausnahmen.txt" || herstellung_fehler "ausn_roh"
  zeilenzahl "$BAUM/scripts/abnahme-ausnahmen.txt"
}
sammel() { # sammel <zeile>... : Sammeldatei neu
  printf '%s\n' "$@" > "$SAMMEL" || herstellung_fehler "sammel"
}
sammel_an() { printf '%s\n' "$@" >> "$SAMMEL" || herstellung_fehler "sammel_an"; }
sammel_grund() { # die zwei Tests des Grundfalls
  sammel 'tests/einheit/test_a.py::test_R3_A_001_erster_test' 'tests/einheit/test_a.py::test_R3_A_001_zweiter_test' '' '2/6 tests collected (4 deselected) in 0.01s'
}
erwarte() { # erwarte <klasse> <schluessel> [<teil des grundes>] : ein erwarteter Fund
  ERW+=("$(printf '%s\t%s\t%s' "$1" "$2" "${3-}")")
}
ausgabe_mit() { AUSGABE_MIT+=("$1"); }
erwarte_zahl() { FUND_ZAHL="$1"; }   # nur die Zahl der Fundzeilen messen (grosse Mengen)
nach_lauf() { NACH_FN="$1"; }          # eigene Pruefung nach dem Lauf
ausgabe_ohne() { AUSGABE_OHNE+=("$1"); }
fehler_nur() { ERR_NUR="$1"; }          # Fehlerausgabe nicht leer und nur Zeilen mit diesem Text (Faelle mit Lesefehler, GA-7)
# Die Funktion read fuer die Faelle A-214 bis A-216 (Umgebungsvariable BASH_FUNC_read%%, die bash beim Start einliest). Sie wirkt nur
# in der Funktion RD_ZIEL: die ersten RD_OK Aufrufe lesen wie die Eingebaute, danach endet jeder Aufruf wie bei einem Ein-/Ausgabefehler
# (Meldung "read error" auf der Fehlerausgabe, Variable unveraendert, Rueckgabewert 1); nach 20 solchen Fehlern bricht sie mit 97 ab,
# damit ein Skript, das nicht endet, nicht bis zur Zeitgrenze laeuft.
RD_FUNKTION='() { if [ "${FUNCNAME[1]:-}" = "${RD_ZIEL:-}" ]; then RD_N=$(( ${RD_N:-0} + 1 )); if [ "$RD_N" -gt "${RD_OK:-0}" ]; then echo "$0: read: read error: 0: Input/output error" >&2; if [ "$RD_N" -gt $(( ${RD_OK:-0} + 20 )) ]; then exit 97; fi; return 1; fi; fi; builtin read "$@"; }'
lesefehler_ab() { # lesefehler_ab <funktion> <n> : ab dem (n+1). Lesen in <funktion> ein Lesefehler
  env_zusatz "RD_ZIEL=$1"; env_zusatz "RD_OK=$2"; env_zusatz "BASH_FUNC_read%%=$RD_FUNKTION"
}
lc() { LC_KENNUNG="$1"; }
lc_nicht() { LC_NICHT+=("$1"); }
lc_mit() { LC_MIT+=("$1"); }
nicht_herstellbar() { NH_GRUND="$1"; }
env_zusatz() { ENV_ZUSATZ+=("$1"); }
env_zusatz2() { ENV_ZUSATZ2+=("$1"); }
kasten_aus() { # kasten_aus <werkzeug>... : setzt KASTEN auf ein Verzeichnis aus Verknuepfungen auf genau diese Werkzeuge
  local box="$FALL/kasten" t p
  rm -rf "$box"
  mkdir -p "$box" || herstellung_fehler "Werkzeugkasten $box"
  for t in "$@"; do
    p=$(command -v "$t") || herstellung_fehler "Werkzeug $t nicht aufloesbar"
    ln -s "$p" "$box/$t" || herstellung_fehler "Verknuepfung $t"
  done
  KASTEN="$box"
}
fremdes_repo() { # fremdes_repo : legt $FALL/fremd an (eigenes Repository mit einer Datei)
  mkdir -p "$FALL/fremd" && gitg -C "$FALL/fremd" init -q && printf 'x\n' > "$FALL/fremd/x.txt" && gitg -C "$FALL/fremd" add -A \
    || herstellung_fehler "fremdes Repository"
}

fall_zuruecksetzen() {
  ERW=()
  ENV_ZUSATZ=()
  ENV_ZUSATZ2=()
  AUSGABE_MIT=()
  AUSGABE_OHNE=()
  LC_KENNUNG=""
  LC_NICHT=()
  LC_MIT=()
  NH_GRUND=""
  CWD_WAHL=""
  AUFRUF_REL=""
  SKRIPT_ORT="scripts/abnahme-abgleich.sh"
  STAT_OK=""
  STAT_SOLL=""
  STAT_IST=""
  DETAIL=()
  ERG=""
  IST=""
  FUND_ZAHL=""
  NACH_FN=""
  ERR_NUR=""
  ARGS=("$SAMMEL")
}

# =============================================================================
# 8. Grundbaum: synthetisch, ausserhalb des Arbeitsbaums
# =============================================================================
grundbaum_bauen() {
  GRUND="$T/grund"
  mkdir -p "$GRUND" || return 1
  gitg -C "$GRUND" init -q || return 1
  BAUM="$GRUND"
  FALL_K="Grundbaum"
  mkdir -p "$BAUM/docs" "$BAUM/scripts" || return 1
  bl_neu
  eintrag R3-A-001 1 "$(abn R3-A-001 erster_test zweiter_test)" "- **Achtung:** fruehere Namen ${BT}R3-A-001_alter_name${BT} sind keine Testnamen."
  eintrag R3-A-002 2 "$(abn R3-A-002 ein_test)"
  eintrag R3-A-003 "zweite Fassung" "- **Abnahme:** Wird bei der Verfeinerung geschnitten."
  eintrag R3-A-004 0 "$(abn R3-A-004 geprueft_anderswo)"
  printf '# Summe und Ableitung\n\nText.\n' >> "$BAUM/docs/05_Product_Backlog.md" || return 1
  printf 'Zeile eins\nZeile zwei\n' > "$BAUM/docs/ziel.md" || return 1
  ausn_neu
  ausn_roh "# geprueft ausserhalb von pytest"
  ausn R3-A-004 "geprueft ausserhalb von pytest: docs/ziel.md"
  ausn_roh "# nicht begonnen"
  ausn R3-A-002 "nicht begonnen, Etappe 2"
  ausn R3-A-003 "nicht begonnen, zweite Fassung"
  return 0
}

# =============================================================================
# 9. Lauf des gepruefen Skripts und Bewertung
# =============================================================================
lauf_pruefer() { # lauf_pruefer <cwd> <aus> <fehler> [VAR=WERT...] : setzt LAUF_RC; das Skript liegt am Ort $SKRIPT_ORT des Baums
  local cwd="$1" out="$2" err="$3" skript="$BAUM/$SKRIPT_ORT"
  shift 3
  if [ "$AUFRUF_REL" = 1 ]; then skript="$SKRIPT_ORT"; fi
  ( cd "$cwd" && exec timeout -k 5 "$FALL_ZEITGRENZE" env -i "${ENV_BASIS[@]}" "$@" "$BASH_BIN" "$skript" "${ARGS[@]+"${ARGS[@]}"}" </dev/null ) >"$out" 2>"$err"
  LAUF_RC=$?
}
stderr_kopf() { head -n 3 "$1" 2>/dev/null | tr '\n' ' ' | cut -c1-300; }
tab_sichtbar() { tr '\t' '|'; }

funde_lesen() { # funde_lesen <aus> : setzt IST_FUNDE, IST_BEFUNDE ("x", wenn nicht genau eine Zeile Befunde), IST_ABSCHN, IST_LETZTE
  local in=0 zeile nb=0
  IST_FUNDE=(); IST_BEFUNDE="x"; IST_ABSCHN=0; IST_LETZTE=""
  while IFS= read -r zeile || [ -n "$zeile" ]; do
    IST_LETZTE="$zeile"
    case "$zeile" in
      "=== Funde") in=1; IST_ABSCHN=$((IST_ABSCHN + 1)); continue ;;
      "---") in=0; continue ;;
      "Befunde: "*) nb=$((nb + 1)); IST_BEFUNDE="${zeile#Befunde: }"; in=0; continue ;;
    esac
    if [ "$in" = 1 ]; then IST_FUNDE+=("$zeile"); fi
  done < "$1"
  [ "$nb" = 1 ] || IST_BEFUNDE="x"
}
feld() { # feld <zeile> <n> : n-tes Feld (1 bis 3) einer Zeile mit Tabulatoren, ohne Zusammenfassen leerer Felder
  local z="$1" a b
  a="${z%%"$TAB"*}"
  if [ "$2" = 1 ]; then printf '%s' "$a"; return; fi
  z="${z#*"$TAB"}"
  b="${z%%"$TAB"*}"
  if [ "$2" = 2 ]; then printf '%s' "$b"; return; fi
  if [ "$z" = "$b" ]; then return; fi
  printf '%s' "${z#*"$TAB"}"
}

bewerte_funde() { # bewerte_funde <soll> <aus> <fehler> <rc>
  local soll="$1" out="$2" err="$3" rc="$4" erwrc nz i e ek eg et ik ig it found j
  local -a rest benutzt
  if [ "$rc" = 124 ] || [ "$rc" = 137 ]; then
    ERG=GEFALLEN; IST="Zeitgrenze von $FALL_ZEITGRENZE s ueberschritten (Rueckgabewert $rc)"; return
  fi
  case "$soll" in fund) erwrc=2 ;; lage-c+funde) erwrc=3 ;; *) erwrc=0 ;; esac
  funde_lesen "$out"
  nz=${#IST_FUNDE[@]}
  IST="Rueckgabewert $rc, Befunde $IST_BEFUNDE, $nz Fundzeilen"
  if [ "$IST_ABSCHN" != 1 ]; then
    ERG=GEFALLEN; DETAIL+=("Abschnitt '=== Funde' ${IST_ABSCHN}-mal vorhanden statt einmal")
    DETAIL+=("Fehlerausgabe: $(stderr_kopf "$err")")
    return
  fi
  if [ "$rc" != "$erwrc" ]; then ERG=GEFALLEN; DETAIL+=("Rueckgabewert $rc statt $erwrc"); fi
  if [ "$IST_BEFUNDE" = x ]; then
    ERG=GEFALLEN; DETAIL+=("genau eine Zeile 'Befunde: n' erwartet, gelesen wurde keine oder mehr als eine")
  elif [ "$IST_BEFUNDE" != "$nz" ]; then
    ERG=GEFALLEN; DETAIL+=("'Befunde: $IST_BEFUNDE' ungleich der Zahl der Fundzeilen $nz")
  fi
  case "$IST_LETZTE" in "Befunde: "*) ;; *) ERG=GEFALLEN; DETAIL+=("die letzte Zeile der Standardausgabe ist nicht 'Befunde: n'") ;; esac
  if [ "$soll" = lage-c+funde ]; then
    local lcn
    if ! grep -qF -- "LAGE C -- $LC_KENNUNG:" "$err"; then ERG=GEFALLEN; DETAIL+=("Fehlerausgabe ohne 'LAGE C -- $LC_KENNUNG:'"); fi
    for lcn in "${LC_MIT[@]+"${LC_MIT[@]}"}"; do
      if ! grep -qF -- "$lcn" "$err"; then ERG=GEFALLEN; DETAIL+=("Fehlerausgabe nennt nicht '$lcn'"); fi
    done
    # nach dem Urteil stehen die Funde ungeordnet in der Ausgabe, aber ohne gleiche Zeilen
    if [ "$nz" -gt 1 ] && ! printf '%s\n' "${IST_FUNDE[@]}" | sort | sort -c -u 2>/dev/null; then ERG=GEFALLEN; DETAIL+=("die Fundzeilen enthalten gleiche Zeilen"); fi
  else
    if [ -n "$ERR_NUR" ]; then
      # Faelle mit Lesefehler (GA-7): die Fehlerausgabe ist allein die Meldung von bash oder der ersetzten Funktion read
      if [ ! -s "$err" ]; then
        ERG=GEFALLEN; DETAIL+=("Fehlerausgabe leer: erwartet wird die Meldung '$ERR_NUR'")
      elif grep -qvF -- "$ERR_NUR" "$err"; then
        ERG=GEFALLEN; DETAIL+=("Fehlerausgabe enthaelt mehr als die Meldung '$ERR_NUR': $(stderr_kopf "$err")")
      fi
    elif [ -s "$err" ]; then
      ERG=GEFALLEN; DETAIL+=("Fehlerausgabe nicht leer: $(stderr_kopf "$err")")
    fi
    # sortiert, ohne gleiche Zeilen
    if [ "$nz" -gt 1 ]; then
      if ! printf '%s\n' "${IST_FUNDE[@]}" | sort -c -u 2>/dev/null; then ERG=GEFALLEN; DETAIL+=("die Fundzeilen sind nicht sortiert oder enthalten gleiche Zeilen"); fi
    fi
  fi
  # jede Fundzeile hat drei Felder
  for i in "${IST_FUNDE[@]+"${IST_FUNDE[@]}"}"; do
    local tabs="${i//[!$TAB]/}"
    if [ "${#tabs}" -ne 2 ] || [ -z "$(feld "$i" 3)" ]; then ERG=GEFALLEN; DETAIL+=("Fundzeile nicht in der Form Klasse TAB Schluessel TAB Grund: $(printf '%s' "$i" | tab_sichtbar)"); fi
  done
  # erwartete Menge gegen gelesene Menge: je erwartetem Fund eine noch nicht zugeordnete Zeile mit gleicher Klasse und gleichem
  # Schluessel, bevorzugt eine, deren Grund den erwarteten Teil enthaelt
  if [ -n "$FUND_ZAHL" ]; then
    if [ "$nz" -ne "$FUND_ZAHL" ]; then ERG=GEFALLEN; DETAIL+=("erwartet $FUND_ZAHL Fundzeilen, gelesen $nz"); fi
    return
  fi
  rest=("${IST_FUNDE[@]+"${IST_FUNDE[@]}"}")
  benutzt=()
  for ((j = 0; j < ${#rest[@]}; j++)); do benutzt[j]=0; done
  for e in "${ERW[@]+"${ERW[@]}"}"; do
    ek=$(feld "$e" 1); eg=$(feld "$e" 2); et=$(feld "$e" 3)
    found=-1; teilweise=-1
    for ((j = 0; j < ${#rest[@]}; j++)); do
      [ "${benutzt[j]}" = 0 ] || continue
      ik=$(feld "${rest[j]}" 1); ig=$(feld "${rest[j]}" 2); it=$(feld "${rest[j]}" 3)
      if [ "$ik" = "$ek" ] && [ "$ig" = "$eg" ]; then
        if [ -z "$et" ] || [[ $it == *"$et"* ]]; then found=$j; break; fi
        if [ "$teilweise" -lt 0 ]; then teilweise=$j; fi
      fi
    done
    if [ "$found" -ge 0 ]; then
      benutzt[found]=1
    elif [ "$teilweise" -ge 0 ]; then
      ERG=GEFALLEN; DETAIL+=("Fund $ek $eg: Grund '$(feld "${rest[teilweise]}" 3)' enthaelt nicht '$et'"); benutzt[teilweise]=1
    else
      ERG=GEFALLEN; DETAIL+=("fehlt: $ek | $eg")
    fi
  done
  for ((j = 0; j < ${#rest[@]}; j++)); do
    if [ "${benutzt[j]}" = 0 ]; then ERG=GEFALLEN; DETAIL+=("zuviel: $(printf '%s' "${rest[j]}" | tab_sichtbar)"); fi
  done
}

ausgabe_pruefen() { # ausgabe_pruefen <aus> : Aussagen ueber die Standardausgabe
  local out="$1" s
  for s in "${AUSGABE_MIT[@]+"${AUSGABE_MIT[@]}"}"; do
    if ! grep -qxF -- "$s" "$out"; then ERG=GEFALLEN; DETAIL+=("Standardausgabe enthaelt die Zeile nicht: $s"); fi
  done
  for s in "${AUSGABE_OHNE[@]+"${AUSGABE_OHNE[@]}"}"; do
    if grep -qxF -- "$s" "$out"; then ERG=GEFALLEN; DETAIL+=("Standardausgabe enthaelt die Zeile: $s"); fi
  done
}

bewerte_lagec() { # bewerte_lagec <aus> <fehler> <rc>
  local out="$1" err="$2" rc="$3" n lc kn
  if [ "$rc" = 124 ] || [ "$rc" = 137 ]; then
    ERG=GEFALLEN; IST="Zeitgrenze von $FALL_ZEITGRENZE s ueberschritten (Rueckgabewert $rc)"; return
  fi
  lc=nein; grep -qF 'LAGE C' "$err" && lc=ja
  kn=nein; grep -qF -- "LAGE C -- $LC_KENNUNG:" "$err" && kn=ja
  IST="Rueckgabewert $rc, 'LAGE C' $lc, Kennung '$LC_KENNUNG' $kn"
  if [ "$rc" != 3 ]; then ERG=GEFALLEN; DETAIL+=("Rueckgabewert $rc statt 3"); fi
  if [ "$lc" != ja ]; then ERG=GEFALLEN; DETAIL+=("Fehlerausgabe ohne 'LAGE C'"); fi
  if [ "$kn" != ja ]; then ERG=GEFALLEN; DETAIL+=("Fehlerausgabe ohne 'LAGE C -- $LC_KENNUNG:'"); fi
  for n in "${LC_NICHT[@]+"${LC_NICHT[@]}"}"; do
    if grep -qF -- "LAGE C -- $n:" "$err"; then ERG=GEFALLEN; DETAIL+=("Fehlerausgabe meldet '$n', obwohl der erste Mangel der Reihenfolge zu melden ist"); fi
  done
  for n in "${LC_MIT[@]+"${LC_MIT[@]}"}"; do
    if ! grep -qF -- "$n" "$err"; then ERG=GEFALLEN; DETAIL+=("Fehlerausgabe nennt nicht '$n'"); fi
  done
  if grep -q '^Befunde:' "$out"; then ERG=GEFALLEN; DETAIL+=("Standardausgabe enthaelt 'Befunde:'"); fi
  if grep -q '^=== Funde' "$out"; then ERG=GEFALLEN; DETAIL+=("Standardausgabe enthaelt den Abschnitt '=== Funde'"); fi
  if [ "$ERG" = GEFALLEN ]; then DETAIL+=("Fehlerausgabe: $(stderr_kopf "$err")"); fi
}

baum_voll() { # baum_voll <wurzel> <verzeichnis> : jeder Eintrag unterhalb: Datei (Pfad, SHA-256), Verzeichnis (Pfad), Verknuepfung (Pfad, Ziel)
  local wz="$1" d="$2" p
  for p in "$d"/* "$d"/.[!.]* "$d"/..?*; do
    if [ -L "$p" ]; then
      printf 'L %s %s\n' "${p#"$wz"/}" "$(readlink "$p")"
    elif [ -d "$p" ]; then
      printf 'D %s\n' "${p#"$wz"/}"
      baum_voll "$wz" "$p"
    elif [ -f "$p" ]; then
      printf 'F %s %s\n' "$(sha256sum < "$p" | cut -c1-64)" "${p#"$wz"/}"
    fi
  done
}

# Kennungen KA, KC, EA und GA aus dem Kopfkommentar des gepruefen Skripts (einzeln): eine je Zeile, sortiert, einmalig
kopf_kennungen() {
  local zeile n=0
  while IFS= read -r zeile || [ -n "$zeile" ]; do
    n=$((n + 1))
    if [ "$n" -eq 1 ]; then case "$zeile" in '#!'*) continue ;; esac; fi
    case "$zeile" in '#'*) printf '%s\n' "$zeile" ;; '') ;; *) break ;; esac
  done < "$PRUEFER" | grep -oE '\b(KA|KC|EA|GA)-[0-9]+\b' | sort -u
}
# Text des gepruefen Skripts ohne Kommentarzeilen und ohne Leerzeilen
code_text() { grep -vE '^[[:space:]]*(#|$)' "$PRUEFER"; }

# =============================================================================
# 10. Die Faelle
# =============================================================================
f_A001() { ausgabe_mit "Backlog: docs/05_Product_Backlog.md"; ausgabe_mit "Eintraege: 4"; ausgabe_mit "Abnahmefeldzeilen: 4"; ausgabe_mit "Testnamen: 4"
  ausgabe_mit "Ausnahmen: 3"; ausgabe_mit "Ausnahmen nicht begonnen, Etappe n: 1"; ausgabe_mit "Ausnahmen nicht begonnen, zweite Fassung: 1"
  ausgabe_mit "Ausnahmen geprueft ausserhalb von pytest: 1"; ausgabe_mit "Faellige Eintraege: 1"; ausgabe_mit "Gesammelte Abnahmetests: 2"; ausgabe_mit "Befunde: 0"; }
f_A002() { bl_neu
  eintrag R3-A-001 1 "$(abn R3-A-001 erster_test zweiter_test)" "- **Formulierung:** Text mit ${BT}R3-A-001_nur_formulierung${BT} und ${BT}R3-A-001_Falsch-Name${BT}." \
    "- **Nachweis:** Text mit ${BT}R3-A-001_nachweis_Gross${BT}." "- **Achtung:** ${BT}R3-A-001_achtung${BT}."
  eintrag R3-A-002 2 "$(abn R3-A-002 ein_test)"
  eintrag R3-A-003 "zweite Fassung" "- **Abnahme:** Wird bei der Verfeinerung geschnitten."
  eintrag R3-A-004 0 "$(abn R3-A-004 geprueft_anderswo)"; }
f_A003() { eintrag R3-A-005 3 "- **Abnahme, maschinell:** Test ${BT}R3-A-005_maschinell_test${BT} $ED Text." "- **Abnahme, menschlich:** Test ${BT}R3-A-005_menschlich_test${BT} $ED Text."
  sammel_an 'tests/einheit/test_b.py::test_R3_A_005_maschinell_test'; erwarte KA-4 R3-A-005_menschlich_test "test_R3_A_005_menschlich_test"; }
f_A004() { eintrag R3-A-005 3 "- **Abnahme, maschinell:** Test ${BT}R3-A-005_maschinell_test${BT} $ED Text." "- **Abnahme, menschlich:** Test ${BT}R3-A-005_menschlich_test${BT} $ED Text."
  sammel_an 'tests/einheit/test_b.py::test_R3_A_005_maschinell_test' 'tests/einheit/test_b.py::test_R3_A_005_menschlich_test'; }
f_A005() { eintrag R3-A-006 3 "$(abn R3-A-006 ein_test)"; ausn R3-A-006 "nicht begonnen, Etappe 3" >/dev/null
  zeilen_an docs/05_Product_Backlog.md '## R3-A-009 - Ebene zwei' '' "$(abn R3-A-009 nach_ebene_zwei)" '' '#### R3-A-010 - Ebene vier' "$(abn R3-A-010 nach_ebene_vier)"
  ausgabe_mit "Eintraege: 5"; ausgabe_mit "Abnahmefeldzeilen: 5"; }

f_A010() { sammel_an 'tests/einheit/test_x.py::test_irgendwas'; erwarte KA-1 test_irgendwas; }
f_A011() { local n
  for n in test_r3_a_001_x test_R3_a_001_x test_R3_A_01_x test_R3_A_0011_x test_R3_A_001x Test_R3_A_001_x check_R3_A_001_x; do
    sammel_an "tests/einheit/test_x.py::$n"; erwarte KA-1 "$n"
  done; }
f_A012() { sammel 'tests/einheit/test_a.py::TestKlasse::test_R3_A_001_erster_test[a b]' 'tests/einheit/test_a.py::TestKlasse::test_R3_A_001_zweiter_test[x::y-z]'; }
f_A013() { sammel_an 'tests/einheit/test_x.py::[param]'; erwarte KA-1 "(leer)"; }

f_A020() { sammel_an 'tests/einheit/test_x.py::test_R3_A_999_irgendwas'; erwarte KA-2 test_R3_A_999_irgendwas "R3-A-999"; }
f_A021() { sammel_an 'tests/einheit/test_x.py::test_R3_Z_001_irgendwas'; erwarte KA-2 test_R3_Z_001_irgendwas "R3-Z-001"; }
f_A022() { eintrag R3-B-001 1 "$(abn R3-B-001 ok_test)"; sammel_an 'tests/einheit/test_b.py::test_R3_B_001_ok_test'; }

f_A030() { sammel_an 'tests/einheit/test_x.py::test_R3_A_001_anderer_name'; erwarte KA-3 test_R3_A_001_anderer_name "R3-A-001"; }
f_A031() { sammel_an 'tests/einheit/test_x.py::test_R3_A_001_ein_test'; erwarte KA-3 test_R3_A_001_ein_test; }
f_A032() { sammel_an 'tests/einheit/test_x.py::test_R3_A_001_Erster_Test' 'tests/einheit/test_x.py::test_R3_A_001_erster_test_' 'tests/einheit/test_x.py::test_R3_A_001_erster'
  erwarte KA-3 test_R3_A_001_Erster_Test; erwarte KA-3 test_R3_A_001_erster_test_; erwarte KA-3 test_R3_A_001_erster; }
f_A033() { sammel_an 'tests/einheit/test_x.py::test_R3_A_002_falsch'; erwarte KA-3 test_R3_A_002_falsch; erwarte KA-8 R3-A-002 "test_R3_A_002_falsch"; }
f_A034() { local n; n=$(printf 'test_R3_A_001_\xc3\xa4pfel'); sammel_an "tests/einheit/test_x.py::$n"; erwarte KA-3 "$n"; }
f_A035() { eintrag R3-A-005 3 "$(abn R3-A-005 r2d2_test a_1_b)"; sammel_an 'tests/einheit/test_b.py::test_R3_A_005_r2d2_test' 'tests/einheit/test_b.py::test_R3_A_005_a_1_b'; ausgabe_mit "Testnamen: 6"; }

f_A040() { sammel 'tests/einheit/test_a.py::test_R3_A_001_erster_test'; erwarte KA-4 R3-A-001_zweiter_test "test_R3_A_001_zweiter_test"; }
f_A041() { sammel; erwarte KA-4 R3-A-001_erster_test; erwarte KA-4 R3-A-001_zweiter_test; ausgabe_mit "Gesammelte Abnahmetests: 0"; }
f_A042() { sammel 'WARNING test_R3_A_001_erster_test ist langsam' 'tests/einheit::test_R3_A_001_zweiter_test' 'test_R3_A_001_erster_test' 'tests/einheit/test_a.py:12: Warnung test_R3_A_001_zweiter_test'
  erwarte KA-4 R3-A-001_erster_test; erwarte KA-4 R3-A-001_zweiter_test; ausgabe_mit "Gesammelte Abnahmetests: 0"; }
f_A043() { ausn R3-A-001 "nicht begonnen, Etappe 1" >/dev/null; sammel; ausgabe_mit "Faellige Eintraege: 0"; ausgabe_mit "Gesammelte Abnahmetests: 0"; ausgabe_mit "Ausnahmen: 4"; }
f_A044() { sammel_an 'tests/einheit/test_b.py::test_R3_A_001_erster_test'; ausgabe_mit "Gesammelte Abnahmetests: 3"; }

f_A050() { eintrag R3-A-005 3 "- **Abnahme:** Nicht formulierbar."; erwarte KA-5 R3-A-005 "ohne eigenen Testnamen"; }
f_A051() { eintrag R3-A-005 3 "- **Abnahme:** Nicht formulierbar."; ausn R3-A-005 "nicht begonnen, Etappe 3" >/dev/null; }
f_A052() { eintrag R3-A-005 3 "- **Formulierung:** Text ohne Abnahmefeld."; erwarte KA-5 R3-A-005; }
f_A053() { eintrag R3-A-005 3 "- **Abnahme:** Siehe Test ${BT}R3-A-001_erster_test${BT}."; erwarte KA-5 R3-A-005; }

f_A060() { eintrag R3-A-002 2 "$(abn R3-A-002 zweiter_block)"; erwarte KA-6 R3-A-002 "mehr als einer Ueberschrift"; ausgabe_mit "Eintraege: 4"; }
f_A061() { eintrag R3-A-005 3 "- **Abnahme:** Test ${BT}R3-A-005_Erster${BT} und ${BT}R3-A-005_mit-bindestrich${BT} und ${BT}R3-A-005_${BT} und ${BT}R3-A-005_a b${BT}."
  ausn R3-A-005 "nicht begonnen, Etappe 3" >/dev/null
  erwarte KA-6 R3-A-005_Erster "nicht abbildbar"; erwarte KA-6 R3-A-005_mit-bindestrich; erwarte KA-6 "R3-A-005_"; erwarte KA-6 "R3-A-005_a b"; }
f_A062() { bl_neu
  eintrag R3-A-001 1 "$(abn R3-A-001 erster_test zweiter_test)"
  eintrag R3-A-002 2 "- **Abnahme:** Test ${BT}R3-A-002_ein_test${BT} und ${BT}R3-A-001_nicht_dort${BT}."
  eintrag R3-A-003 "zweite Fassung" "- **Abnahme:** Wird bei der Verfeinerung geschnitten."
  eintrag R3-A-004 0 "$(abn R3-A-004 geprueft_anderswo)"
  erwarte KA-6 R3-A-001_nicht_dort "Querverweis ins Leere"; }
f_A063() { bl_neu
  eintrag R3-A-001 1 "$(abn R3-A-001 erster_test zweiter_test)"
  eintrag R3-A-002 2 "- **Abnahme:** Test ${BT}R3-A-002_ein_test${BT} und ${BT}R3-A-001_erster_test${BT}."
  eintrag R3-A-003 "zweite Fassung" "- **Abnahme:** Wird bei der Verfeinerung geschnitten."
  eintrag R3-A-004 0 "$(abn R3-A-004 geprueft_anderswo)"; }
f_A064() { eintrag R3-A-005 3 "- **Abnahme:** Test ${BT}R3-A-005_eigen${BT} und ${BT}R3-A-777_irgendwas${BT}."; ausn R3-A-005 "nicht begonnen, Etappe 3" >/dev/null
  erwarte KA-6 R3-A-777_irgendwas "R3-A-005"; }
f_A065() { eintrag R3-A-005 3 "- **Abnahme:** Test ${BT}R3-A-005_eigen${BT} und ${BT}R3-A-001_Gross${BT}."; ausn R3-A-005 "nicht begonnen, Etappe 3" >/dev/null
  erwarte KA-6 R3-A-001_Gross "nicht abbildbar"; }
f_A066() { eintrag R3-A-005 3 "- **Abnahme:** ${BT}stop_hook_active${BT}, ${BT}scripts/x.sh${BT}, ${BT}R3-A-001${BT} und Test ${BT}R3-A-005_eigen${BT}." "- **Abnahme, maschinell:** Test ${BT}R3-A-005_eigen${BT} noch einmal."
  ausn R3-A-005 "nicht begonnen, Etappe 3" >/dev/null; ausgabe_mit "Testnamen: 5"; }
f_A067() { zeilen docs/05_Product_Backlog_zwei.md '### R3-A-001 - noch einmal' "$(kopfzeile 1)" "$(abn R3-A-001 erster_test zweiter_test)"
  erwarte KA-6 R3-A-001 "mehr als einer Ueberschrift"; }

f_A070() { ausn_roh "R3-A-005 nicht begonnen, Etappe 3"; erwarte KA-7 "Zeile $ZN" "Feldzahl"
  ausn_roh "$(printf 'R3-A-006\tnicht begonnen,\tEtappe 3')"; erwarte KA-7 "Zeile $ZN" "Feldzahl"; }
f_A071() { local z
  for z in "R3-A-01" "r3-a-001" "R3-A-0011" " R3-A-005"; do ausn_roh "$(printf '%s\tnicht begonnen, Etappe 3' "$z")"; erwarte KA-7 "Zeile $ZN" "Kennung ausserhalb"; done; }
f_A072() { local g i=11
  for g in "nicht begonnen, Etappe 7" "nicht begonnen" "Nicht begonnen, Etappe 1" "nicht begonnen, Etappe 1 " "gestrichen" "nicht begonnen, Etappe 10" "geprueft ausserhalb von pytest:" "nicht begonnen, zweite  Fassung"; do
    ausn "R3-A-0$i" "$g" >/dev/null; erwarte KA-7 "R3-A-0$i" "Grund ausserhalb der drei Wortlaute"; i=$((i + 1))
  done; }
f_A073() { ausn R3-A-002 "nicht begonnen, Etappe 2" >/dev/null; erwarte KA-7 R3-A-002 "doppelt (erste Zeile 4)"; }
f_A074() { local g i=21
  for g in "/etc/passwd" "../x" "docs/../docs/ziel.md" ".." "docs/.." ""; do
    ausn "R3-A-0$i" "geprueft ausserhalb von pytest: $g" >/dev/null; erwarte KA-7 "R3-A-0$i" "repository-relative"; i=$((i + 1))
  done; }
f_A075() { ausn_roh "$(printf 'R3-A-005\tnicht begonnen, Etappe 3 \xc3\xa4')"; erwarte KA-7 "Zeile $ZN" "ASCII"
  ausn_roh "$(printf 'R3-A-006\tnicht begonnen, Etappe 3\r')"; erwarte KA-7 "Zeile $ZN" "ASCII"; }
f_A076() { ausn_roh "# Kommentar mit$(printf '\t')Tabulator"; ausn_roh ""; ausn_roh "#R3-A-005$(printf '\t')nicht begonnen, Etappe 3"; ausn_roh ""; ausgabe_mit "Ausnahmen: 3"; }
f_A077() { ausn_roh "   "; erwarte KA-7 "Zeile $ZN" "Feldzahl"; ausn_roh "$(printf '\t')"; erwarte KA-7 "Zeile $ZN" "Kennung ausserhalb"; }
f_A078() { ausn_neu; ausn R3-A-004 "geprueft ausserhalb von pytest: docs/ziel.md" >/dev/null; ausn R3-A-002 "nicht begonnen, Etappe 2 " >/dev/null; erwarte KA-7 R3-A-002 "Grund ausserhalb"
  ausn R3-A-003 "nicht begonnen, zweite Fassung" >/dev/null; erwarte KA-4 R3-A-002_ein_test; }
f_A079() { printf 'R3-A-004\tgeprueft ausserhalb von pytest: docs/ziel.md\nR3-A-002\tnicht begonnen, Etappe 2\nR3-A-003\tnicht begonnen, zweite Fassung' > "$BAUM/scripts/abnahme-ausnahmen.txt" || herstellung_fehler "A-079"
  ausgabe_mit "Ausnahmen: 3"; }
f_A080() { printf 'R3-A-004\tgeprueft ausserhalb von pytest: docs/ziel.md\nR3-A-002\tnicht begonnen, Etappe 2\nR3-A-003\tnicht begonnen, zweite Fassung\nR3-A-009 nicht begonnen' > "$BAUM/scripts/abnahme-ausnahmen.txt" || herstellung_fehler "A-080"
  erwarte KA-7 "Zeile 4" "Feldzahl"; }

f_A090() { ausn R3-A-099 "nicht begonnen, Etappe 1" >/dev/null; erwarte KA-8 R3-A-099 "ohne Ueberschrift"; }
f_A091() { sammel_an 'tests/einheit/test_b.py::test_R3_A_002_ein_test'; erwarte KA-8 R3-A-002 "gesammelter Abnahmetest"; }
f_A092() { ausn_neu; ausn R3-A-004 "geprueft ausserhalb von pytest: docs/ziel.md" >/dev/null; ausn R3-A-002 "nicht begonnen, Etappe 3" >/dev/null; ausn R3-A-003 "nicht begonnen, zweite Fassung" >/dev/null
  erwarte KA-8 R3-A-002 "Etappe im Grund (3) ungleich"; }
f_A093() { eintrag R3-A-005 3 "$(abn R3-A-005 x)"; printf '### R3-A-006 - ohne Kopfzeile\n%s\n\n' "$(abn R3-A-006 y)" >> "$BAUM/docs/05_Product_Backlog.md"
  printf '### R3-A-007 - Kopfzeile ohne Feld\n- **Art:** Funktional %s **Kano:** Basisfaktor\n%s\n\n' "$MP" "$(abn R3-A-007 z)" >> "$BAUM/docs/05_Product_Backlog.md"
  ausn R3-A-006 "nicht begonnen, Etappe 3" >/dev/null; erwarte KA-8 R3-A-006 "Feld Etappe fehlt"
  ausn R3-A-007 "nicht begonnen, zweite Fassung" >/dev/null; erwarte KA-8 R3-A-007 "Feld Etappe fehlt"
  ausn R3-A-005 "nicht begonnen, Etappe 3" >/dev/null; }
f_A094() { sammel; ausn_neu; ausn R3-A-004 "geprueft ausserhalb von pytest: docs/ziel.md" >/dev/null; ausn R3-A-002 "nicht begonnen, Etappe 2" >/dev/null
  ausn R3-A-003 "nicht begonnen, Etappe 1" >/dev/null; ausn R3-A-001 "nicht begonnen, zweite Fassung" >/dev/null
  erwarte KA-8 R3-A-003 "ungleich"; erwarte KA-8 R3-A-001 "zweite Fassung ungleich"; }
f_A095() { ausn_neu; ausn R3-A-004 "geprueft ausserhalb von pytest: docs/fehlt.md" >/dev/null; ausn R3-A-002 "nicht begonnen, Etappe 2" >/dev/null; ausn R3-A-003 "nicht begonnen, zweite Fassung" >/dev/null
  erwarte KA-8 R3-A-004 "Pfad besteht nicht"; }
f_A096() { ausn_neu; ausn R3-A-004 "geprueft ausserhalb von pytest: docs" >/dev/null; ausn R3-A-002 "geprueft ausserhalb von pytest: docs/" >/dev/null
  ausn R3-A-003 "geprueft ausserhalb von pytest: ./docs/ziel.md" >/dev/null; }
f_A097() { ln -s . "$BAUM/docs/lnk" && ln -s ziel.md "$BAUM/docs/ziel-link.txt" || herstellung_fehler "Verknuepfungen"
  ausn_neu; ausn R3-A-004 "geprueft ausserhalb von pytest: docs/lnk/ziel.md" >/dev/null; ausn R3-A-002 "geprueft ausserhalb von pytest: docs/ziel-link.txt" >/dev/null
  ausn R3-A-003 "nicht begonnen, zweite Fassung" >/dev/null
  erwarte KA-8 R3-A-004 "Pfad besteht nicht"; erwarte KA-8 R3-A-002 "Pfad besteht nicht"; }
f_A098() { eintrag R3-A-007 0 "$(abn R3-A-007 a)"; eintrag R3-A-008 6 "$(abn R3-A-008 b)"; ausn R3-A-007 "nicht begonnen, Etappe 0" >/dev/null; ausn R3-A-008 "nicht begonnen, Etappe 6" >/dev/null
  ausgabe_mit "Ausnahmen: 5"; }
f_A099() { bl_neu
  eintrag R3-A-001 1 "$(abn R3-A-001 erster_test zweiter_test)"
  eintrag R3-A-002 2 "$(abn R3-A-002 ein_test)"
  sed -i "s/\*\*Etappe:\*\* 2\$/**Etappe:** 2   $MP **Status:** offen/" "$BAUM/docs/05_Product_Backlog.md" || herstellung_fehler "sed"
  ausn_neu; ausn R3-A-002 "nicht begonnen, Etappe 2" >/dev/null; }

f_A110() { ARGS=(); lc aufruf; }
f_A111() { ARGS=("$SAMMEL" "$SAMMEL"); lc aufruf; }
f_A112() { ARGS=(""); lc aufruf; }
f_A113() { kasten_aus sort; env_zusatz "PATH=$KASTEN"; lc werkzeug:git; }
f_A114() { kasten_aus git; env_zusatz "PATH=$KASTEN"; lc werkzeug:sort; }
f_A115() { kasten_aus sort; env_zusatz "PATH=$KASTEN"; ARGS=("$FALL/gibt-es-nicht.txt"); lc werkzeug:git; lc_nicht sammeldatei; }
f_A116() { kasten_aus $KASTEN_VOLL; env_zusatz "PATH=$KASTEN"; }

f_A120() { rm -rf "$BAUM/.git" || herstellung_fehler "rm .git"; lc git-arbeitsbaum; }
f_A121() { mkdir -p "$BAUM/unter/docs" "$BAUM/unter/scripts" && cp "$BAUM/docs/05_Product_Backlog.md" "$BAUM/unter/docs/" && cp "$BAUM/scripts/abnahme-ausnahmen.txt" "$BAUM/unter/scripts/" \
    || herstellung_fehler "unter"
  SKRIPT_ORT="unter/scripts/abnahme-abgleich.sh"; lc git-arbeitsbaum; }
f_A122() { fremdes_repo; CWD_WAHL="$FALL/fremd"; ausgabe_mit "Befunde: 0"; }

f_A130() { ARGS=("$FALL/gibt-es-nicht.txt"); lc sammeldatei; lc_mit "fehlt"; }
f_A131() { mkdir -p "$FALL/ein-verzeichnis"; ARGS=("$FALL/ein-verzeichnis"); lc sammeldatei; lc_mit "keine regulaere Datei"; }
f_A132() { ln -s "$SAMMEL" "$FALL/sammel-link.txt" || herstellung_fehler "Verknuepfung"; ARGS=("$FALL/sammel-link.txt"); lc sammeldatei; lc_mit "Verknuepfung"; }
f_A133() { if [ "$(id -u)" = 0 ]; then nicht_herstellbar "als root nicht herstellbar (GP-A1)"; return; fi
  chmod 000 "$SAMMEL" || herstellung_fehler "chmod"; lc sammeldatei; lc_mit "nicht lesbar"; }
f_A134() { cp "$SAMMEL" "$FALL/rel-sammel.txt" || herstellung_fehler "cp"; ARGS=("rel-sammel.txt"); CWD_WAHL="$FALL"; ausgabe_mit "Gesammelte Abnahmetests: 2"; }

f_A140() { rm -f "$BAUM/docs/05_Product_Backlog.md" || herstellung_fehler "rm"; lc backlog; lc_mit "Suchmuster"; }
f_A141() { bl_neu; eintrag R3-A-001 1 "- **Formulierung:** Text."; eintrag R3-A-002 2 "- **Formulierung:** Text."; lc backlog-abnahmekriterien; }
f_A142() { printf '%s\n' "### R3-A-001 - ausserhalb" "$(kopfzeile 1)" "$(abn R3-A-001 erster_test)" > "$FALL/aussen.md" || herstellung_fehler "aussen"
  rm -f "$BAUM/docs/05_Product_Backlog.md" && ln -s "$FALL/aussen.md" "$BAUM/docs/05_Product_Backlog.md" || herstellung_fehler "Verknuepfung"; lc backlog-verknuepfung; }
f_A143() { mv "$BAUM/docs" "$BAUM/echt-docs" && ln -s echt-docs "$BAUM/docs" || herstellung_fehler "Verknuepfung"; lc backlog-verknuepfung; }
f_A144() { rm -f "$BAUM/docs/05_Product_Backlog.md" && mkdir "$BAUM/docs/05_Product_Backlog.md" || herstellung_fehler "mkdir"; lc backlog; lc_mit "keine regulaere Datei"; }
f_A145() { bl_neu; printf '%s\n' "$(abn R3-A-001 erster_test)" '' '## Abschnitt' '' "$(abn R3-A-002 ein_test)" > "$BAUM/docs/05_Product_Backlog.md" || herstellung_fehler "bl"; lc backlog-abnahmekriterien; }
f_A146() { if [ "$(id -u)" = 0 ]; then nicht_herstellbar "als root nicht herstellbar (GP-A1)"; return; fi
  chmod 000 "$BAUM/docs/05_Product_Backlog.md" || herstellung_fehler "chmod"; lc backlog; lc_mit "nicht lesbar"; }
f_A147() { zeilen docs/05_Product_Backlog_zwei.md '### R3-A-005 - zweite Datei' "$(kopfzeile 3)" "$(abn R3-A-005 ein_test)"; ausn R3-A-005 "nicht begonnen, Etappe 3" >/dev/null
  ausgabe_mit "Backlog: docs/05_Product_Backlog.md, docs/05_Product_Backlog_zwei.md"; ausgabe_mit "Eintraege: 5"; }
f_A148() { zeilen docs/archiv/05_Product_Backlog_alt.md '### R3-A-005 - im Unterverzeichnis' "$(kopfzeile 3)" "$(abn R3-A-005 ein_test)"
  zeilen docs/05_Product_Backlog.txt '### R3-A-006 - andere Endung' "$(kopfzeile 3)" "$(abn R3-A-006 ein_test)"; ausgabe_mit "Eintraege: 4"; ausgabe_mit "Backlog: docs/05_Product_Backlog.md"; }

f_A160() { rm -f "$BAUM/scripts/abnahme-ausnahmen.txt" || herstellung_fehler "rm"; lc ausnahmeliste; lc_mit "fehlt"; }
f_A161() { rm -f "$BAUM/scripts/abnahme-ausnahmen.txt" && mkdir "$BAUM/scripts/abnahme-ausnahmen.txt" || herstellung_fehler "mkdir"; lc ausnahmeliste; lc_mit "keine regulaere Datei"; }
f_A162() { printf 'R3-A-002\tnicht begonnen, Etappe 2\n' > "$FALL/aussen.txt" || herstellung_fehler "aussen"
  rm -f "$BAUM/scripts/abnahme-ausnahmen.txt" && ln -s "$FALL/aussen.txt" "$BAUM/scripts/abnahme-ausnahmen.txt" || herstellung_fehler "Verknuepfung"; lc ausnahmeliste-verknuepfung; }
f_A163() { mv "$BAUM/scripts" "$BAUM/echt-scripts" && ln -s echt-scripts "$BAUM/scripts" || herstellung_fehler "Verknuepfung"; lc ausnahmeliste-verknuepfung; }
f_A164() { if [ "$(id -u)" = 0 ]; then nicht_herstellbar "als root nicht herstellbar (GP-A1)"; return; fi
  chmod 000 "$BAUM/scripts/abnahme-ausnahmen.txt" || herstellung_fehler "chmod"; lc ausnahmeliste; lc_mit "nicht lesbar"; }
f_A165() { bl_neu; eintrag R3-A-001 1 "$(abn R3-A-001 erster_test zweiter_test)"; ausn_neu; ausgabe_mit "Ausnahmen: 0"; ausgabe_mit "Faellige Eintraege: 1"; }
f_A166() { ARGS=("$FALL/gibt-es-nicht.txt"); rm -f "$BAUM/docs/05_Product_Backlog.md" || herstellung_fehler "rm"; lc sammeldatei; lc_nicht backlog; }
f_A167() { rm -f "$BAUM/docs/05_Product_Backlog.md" "$BAUM/scripts/abnahme-ausnahmen.txt" || herstellung_fehler "rm"; lc backlog; lc_nicht ausnahmeliste; }

f_A170() { fremdes_repo
  env_zusatz2 "GIT_DIR=$FALL/fremd/.git"; env_zusatz2 "GIT_WORK_TREE=$FALL/fremd"; env_zusatz2 "GIT_INDEX_FILE=$FALL/fremd/.git/index"; env_zusatz2 "GIT_COMMON_DIR=$FALL/fremd/.git"
  env_zusatz2 "GIT_OBJECT_DIRECTORY=$FALL/fremd/.git/objects"; env_zusatz2 "GIT_NAMESPACE=fremd"; env_zusatz2 "GIT_CEILING_DIRECTORIES=$FALL"; env_zusatz2 "GIT_GLOB_PATHSPECS=1"
  ausgabe_mit "Befunde: 0"; }
f_A171() { local probe=$'\xc3\xa4'
  if ! LC_ALL=C.utf8 "$BASH_BIN" -c '[[ $1 =~ [[:print:]] ]]' x "$probe" 2>/dev/null; then nicht_herstellbar "Spracheinstellung C.utf8 fehlt oder behandelt das Zeichen nicht als druckbar (GP-A2)"; return; fi
  ausn_roh "$(printf 'R3-A-005\tnicht begonnen, Etappe 3 \xc3\xa4')"; erwarte KA-7 "Zeile $ZN" "ASCII"; env_zusatz2 "LC_ALL=C.utf8"; ausgabe_mit "Befunde: 1"; }
f_A172() { :; }
f_A173() { sammel 'tests/x.py::test_irgendwas' 'tests/x.py::test_R3_A_999_x' 'tests/x.py::test_R3_A_001_anders'; ausn_roh "R3-A-005 nicht begonnen, Etappe 3"; ausn R3-A-099 "nicht begonnen, Etappe 1" >/dev/null; }
f_A174() { f_A173; ausgabe_mit "Gesammelte Abnahmetests: 3"; }
f_A175() {
  sammel 'tests/x.py::test_irgendwas' 'tests/x.py::test_R3_A_999_x' 'tests/x.py::test_R3_A_001_anders' 'tests/x.py::test_R3_A_001_erster_test'
  ausn_roh "R3-A-005 nicht begonnen, Etappe 3"; ausn R3-A-099 "nicht begonnen, Etappe 1" >/dev/null
  eintrag R3-A-005 3 "- **Abnahme:** Nicht formulierbar."
  eintrag R3-A-006 3 "- **Abnahme:** Test ${BT}R3-A-006_Gross${BT}."
  eintrag R3-A-002 2 "$(abn R3-A-002 zweiter_block)"
  erwarte KA-1 test_irgendwas; erwarte KA-2 test_R3_A_999_x; erwarte KA-3 test_R3_A_001_anders; erwarte KA-4 R3-A-001_zweiter_test; erwarte KA-5 R3-A-005
  erwarte KA-5 R3-A-006; erwarte KA-6 R3-A-006_Gross; erwarte KA-6 R3-A-002; erwarte KA-7 "Zeile 6"; erwarte KA-8 R3-A-099
  ausgabe_mit "Befunde: 10"; }
f_A176() { ausgabe_mit "Gesammelte Abnahmetests: 2"; ausgabe_mit "Befunde: 0"; ausgabe_mit "---"; ausgabe_mit "=== Funde"; }

f_A200() { sammel 'tests/einheit/test_a.py::test_R3_A_001_erster_test' 'tests/einheit/test_a.py::test_R3_A_001_zweiter_test'; ausgabe_mit "Befunde: 0"; }
f_A201() { sammel 'tests/einheit/test_a.py::test_R3_A_001_erster_test'; erwarte KA-4 R3-A-001_zweiter_test; }
f_A202() { eintrag R3-A-005 3 "$(abn R3-A-005 oberflaeche_test)"; erwarte KA-4 R3-A-005_oberflaeche_test; }
f_A203() { eintrag R3-A-005 3 "$(abn R3-A-005 oberflaeche_test)"; ausn R3-A-005 "geprueft ausserhalb von pytest: docs/ziel.md" >/dev/null; ausgabe_mit "Ausnahmen geprueft ausserhalb von pytest: 2"; }
f_A204() { bl_neu
  eintrag R3-A-001 1 "$(abn R3-A-001 erster_test zweiter_test)" "  - **Abnahme:** eingerueckt mit ${BT}R3-A-001_Falsch-Name${BT}." "- **Nachweis:** ${BT}R3-A-001_Nachweis-Falsch${BT}."
  eintrag R3-A-002 2 "$(abn R3-A-002 ein_test)"
  eintrag R3-A-003 "zweite Fassung" "- **Abnahme:** Wird bei der Verfeinerung geschnitten."
  eintrag R3-A-004 0 "$(abn R3-A-004 geprueft_anderswo)"
  ausgabe_mit "Abnahmefeldzeilen: 4"; ausgabe_mit "Befunde: 0"; }
f_A205() { zeilen_an docs/05_Product_Backlog.md '```text' '### R3-A-008 - im Zaun' "$(kopfzeile 3)" "$(abn R3-A-008 im_zaun)" '```'
  erwarte KA-4 R3-A-008_im_zaun "faelliger Eintrag"; ausgabe_mit "Eintraege: 5"; }
f_A206() { sammel 'x.py::test_R3_A_001_erster_test' 'y.py::test_R3_A_001_zweiter_test'; ausgabe_mit "Gesammelte Abnahmetests: 2"; ausgabe_mit "Befunde: 0"; }

f_A210() { local dd probe_gut probe_schlecht
  # Befehle, die das Skript nicht aufruft (Builtins der Shell ausgenommen); geprueft wird jedes Wort ausserhalb von Kommentarzeilen
  dd='\b(awk|sed|grep|egrep|fgrep|cat|cut|tr|head|tail|wc|ls|find|xargs|dirname|basename|date|env|mktemp|readlink|realpath|touch|tee|rm|mv|cp|ln|mkdir|chmod|stat|timeout|flock|sha256sum|cmp|diff|uniq|comm|join|paste|nl|seq|jq|python3?|perl|ruby|node)\b'
  probe_gut=$'echo "ein Satz"\nx=$(git -C . rev-parse --show-toplevel)\nprintf \'%s\\n\' "a" | sort -u'
  probe_schlecht=$'x=$(cat datei)\nprintf \'%s\\n\' "a" | grep a'
  STAT_SOLL="kein Befehl der Liste ausserhalb von Kommentarzeilen; Probe schlaegt an"
  if ! printf '%s\n' "$probe_gut" | grep -qE "$dd" && printf '%s\n' "$probe_schlecht" | grep -qE "$dd"; then
    if code_text | grep -E "$dd" > "$FALL/treffer.txt"; then
      STAT_OK=0; STAT_IST="Befehl der Liste im Code: $(head -n 2 "$FALL/treffer.txt" | tr '\n' ' ' | cut -c1-200)"
    else
      STAT_OK=1; STAT_IST="kein Befehl der Liste im Code; Probe schlaegt an"
    fi
  else
    STAT_OK=0; STAT_IST="die Probe der Pruefung selbst ist defekt"
  fi; }
f_A211() { local a b
  STAT_SOLL="BASH_VERSINFO steht vor dem ersten declare -A"
  a=$(code_text | grep -n 'BASH_VERSINFO' | head -n 1 | cut -d: -f1); b=$(code_text | grep -n 'declare -A' | head -n 1 | cut -d: -f1)
  if [ -n "$a" ] && [ -n "$b" ] && [ "$a" -lt "$b" ]; then STAT_OK=1; STAT_IST="BASH_VERSINFO in Codezeile $a, declare -A in Codezeile $b"
  else STAT_OK=0; STAT_IST="BASH_VERSINFO in Codezeile '${a:-keine}', declare -A in Codezeile '${b:-keine}'"; fi; }
f_A212() { local dd probe_gut probe_schlecht
  dd='(\bdate\b|\$SECONDS|\$RANDOM|\$\$|\$BASHPID|EPOCHSECONDS|EPOCHREALTIME|\$SRANDOM)'
  probe_gut=$'echo "Eintraege: $N"\nx=${y}'
  probe_schlecht=$'echo "Lauf $SECONDS"\necho $$'
  STAT_SOLL="keine Zeit, Zufallszahl oder Prozessnummer im Code; Probe schlaegt an"
  if ! printf '%s\n' "$probe_gut" | grep -qE "$dd" && printf '%s\n' "$probe_schlecht" | grep -qE "$dd"; then
    if code_text | grep -E "$dd" > "$FALL/treffer.txt"; then
      STAT_OK=0; STAT_IST="Zeit, Zufallszahl oder Prozessnummer im Code: $(head -n 2 "$FALL/treffer.txt" | tr '\n' ' ' | cut -c1-200)"
    else
      STAT_OK=1; STAT_IST="nichts dergleichen im Code; Probe schlaegt an"
    fi
  else
    STAT_OK=0; STAT_IST="die Probe der Pruefung selbst ist defekt"
  fi; }
f_A213() { local a b
  STAT_SOLL="export LC_ALL=C steht vor der ersten Pruefung des Suchpfads (command -v)"
  a=$(code_text | grep -n '^export LC_ALL=C$' | head -n 1 | cut -d: -f1); b=$(code_text | grep -n 'command -v' | head -n 1 | cut -d: -f1)
  if [ -n "$a" ] && [ -n "$b" ] && [ "$a" -lt "$b" ]; then STAT_OK=1; STAT_IST="export LC_ALL=C in Codezeile $a, command -v in Codezeile $b"
  else STAT_OK=0; STAT_IST="export LC_ALL=C in Codezeile '${a:-keine}', command -v in Codezeile '${b:-keine}'"; fi; }

f_A180() { kasten_aus git sort; rm -f "${KASTEN:?}/sort"; printf '#!/bin/sh\nexit 2\n' > "$KASTEN/sort" || herstellung_fehler "sort-Attrappe"
  chmod +x "$KASTEN/sort" || herstellung_fehler "chmod"; env_zusatz "PATH=$KASTEN"
  sammel 'tests/einheit/test_a.py::test_R3_A_001_erster_test' 'tests/einheit/test_b.py::test_ohne_kennung'
  erwarte KA-4 R3-A-001_zweiter_test; erwarte KA-1 test_ohne_kennung; lc werkzeug:sort; lc_mit "endete mit einem Fehler"; }
f_A181() { local echtes kopf; echtes=$(command -v sort); kopf=$(command -v head); kasten_aus git sort; rm -f "${KASTEN:?}/sort"
  printf '#!/bin/sh\n%s "$@" | %s -n 1\n' "$echtes" "$kopf" > "$KASTEN/sort" || herstellung_fehler "sort-Attrappe"
  chmod +x "$KASTEN/sort" || herstellung_fehler "chmod"; env_zusatz "PATH=$KASTEN"
  sammel 'tests/einheit/test_a.py::test_R3_A_001_erster_test' 'tests/einheit/test_b.py::test_ohne_kennung'
  erwarte KA-4 R3-A-001_zweiter_test; erwarte KA-1 test_ohne_kennung; lc werkzeug:sort; lc_mit "lieferte 1 Zeilen statt der erfassten 2"; }
f_A182() { bl_neu; ausn_neu; sammel; local i id
  for ((i = 1; i <= 800; i++)); do printf -v id 'R3-A-%03d' "$i"; eintrag "$id" 1 "$(abn "$id" "t$i")"; done
  erwarte_zahl 800; ausgabe_mit "Befunde: 800"; ausgabe_mit "Faellige Eintraege: 800"; nach_lauf nach_A182; }
nach_A182() { local groesse; groesse=$(<"$FALL/aus.txt"); IST="$IST; Standardausgabe ${#groesse} Zeichen"
  if [ "${#groesse}" -lt 65536 ]; then ERG=GEFALLEN; DETAIL+=("die Standardausgabe ist kleiner als 64 KiB: der Fall misst die Schwelle der Here-Strings nicht"); fi; }
f_A183() { STAT_SOLL="ausserhalb von Kommentarzeilen steht kein Here-String (Bash legt dafuer ab 64 KiB, vor Version 5.1 immer, eine Wegwerfdatei an)"
  local treffer probe
  treffer=$(code_text | grep -c '<<<'); probe=$(printf '%s\nx <<< "y"\n' "$(code_text)" | grep -c '<<<')
  STAT_IST="Zeilen mit <<<: $treffer; Probe der Pruefung: $probe"
  if [ "$treffer" = 0 ] && [ "$probe" -ge 1 ]; then STAT_OK=1; fi; }
f_A207() { eintrag R3-A-005 3 "> ### R3-A-099 $ED im Zitat" "> - **Abnahme:** Zitat ${BT}R3-A-005_nur_im_zitat${BT} $ED Text." "$(abn R3-A-005 nach_zitat)"
  sammel_an 'tests/einheit/test_c.py::test_R3_A_005_nach_zitat'; ausgabe_mit "Eintraege: 5"; ausgabe_mit "Abnahmefeldzeilen: 5"; ausgabe_mit "Befunde: 0"; }
f_A208() { if [ ! -f /proc/self/mem ] || bash -c 'IFS= read -r x < /proc/self/mem' 2>/dev/null; then nicht_herstellbar "/proc/self/mem endet beim Lesen nicht mit einem Fehler (GP-A8)"; fi
  ARGS=(/proc/self/mem); fehler_nur "read error"; erwarte KA-4 R3-A-001_erster_test; erwarte KA-4 R3-A-001_zweiter_test; }
f_A214() { lesefehler_ab backlog_lesen 1; lc backlog-abnahmekriterien; lc_mit "keine Abnahmefeldzeile"; }
f_A215() { bl_neu; eintrag R3-A-005 3 "$(abn R3-A-005 oberflaeche_test)"; ausn_neu; ausn_roh "# Kommentar"
  ausn R3-A-005 "geprueft ausserhalb von pytest: docs/ziel.md" >/dev/null; sammel; lesefehler_ab ausnahmen_lesen 1; fehler_nur "read error"
  erwarte KA-4 R3-A-005_oberflaeche_test; }
f_A216() { lesefehler_ab sammel_lesen 1; fehler_nur "read error"; erwarte KA-4 R3-A-001_zweiter_test; }
f_A217() { STAT_SOLL="bash laesst die Variable bei einem Lesefehler unveraendert und liefert 1 (Annahme der Faelle A-208 und A-214 bis A-216)"
  local x=alt rc
  if [ ! -f /proc/self/mem ] || bash -c 'IFS= read -r x < /proc/self/mem' 2>/dev/null; then nicht_herstellbar "/proc/self/mem endet beim Lesen nicht mit einem Fehler (GP-A8)"; return; fi
  IFS= read -r x < /proc/self/mem 2>/dev/null; rc=$?
  STAT_IST="Rueckgabewert $rc, Variable '$x'"
  if [ "$rc" = 1 ] && [ "$x" = alt ]; then STAT_OK=1; fi; }
f_A185() { STAT_SOLL="die Zeilen der Antwort von sort werden nicht mit einer Ersetzung des Musters ueber die ganze Antwort gezaehlt (quadratisch, ST-G3-12)"
  local treffer probe
  treffer=$(code_text | grep -c 'SORTIERT//'); probe=$(printf '%s\nx="${SORTIERT//[!a]/}"\n' "$(code_text)" | grep -c 'SORTIERT//')
  STAT_IST="Zeilen mit SORTIERT//: $treffer; Probe der Pruefung: $probe"
  if [ "$treffer" = 0 ] && [ "$probe" -ge 1 ]; then STAT_OK=1; fi; }
f_A218() { AUFRUF_REL=1; CWD_WAHL="$BAUM"; mkdir -p "$FALL/lockvogel/scripts" || herstellung_fehler "lockvogel"; env_zusatz "CDPATH=$FALL/lockvogel"; ausgabe_mit "Gesammelte Abnahmetests: 2"; ausgabe_mit "Befunde: 0"; ausgabe_ohne "$FALL/lockvogel"; }
f_A299() { :; }

# =============================================================================
# 11. Ausfuehrung eines Falls
# =============================================================================
declare -A FL_KLASSEN FL_SOLL FL_HERKUNFT FL_GEGENSTAND ERGEBNIS GRP_N GRP_B GRP_G GRP_H
FL_ORDER=(); GEFALLENE=()
ANZ_B=0; ANZ_G=0; ANZ_H=0

fall_ausfuehren() { # fall_ausfuehren <kennung>
  local k="$1" soll klassen gegen fn out err cwd sollt grp vor nach rc1 rc2 d a b s
  soll="${FL_SOLL[$k]}"; klassen="${FL_KLASSEN[$k]}"; gegen="${FL_GEGENSTAND[$k]}"; fn="f_${k//-/}"
  FALL_K="$k"
  FALL="$T/faelle/$k"; BAUM="$FALL/baum"; SAMMEL="$FALL/sammel.txt"
  fall_zuruecksetzen
  ERG="BESTANDEN"
  mkdir -p "$FALL" && cp -a "$GRUND" "$BAUM" || herstellung_fehler "Kopie des Grundbaums"
  sammel_grund
  "$fn"
  out="$FALL/aus.txt"; err="$FALL/fehler.txt"
  case "$soll" in
    fund) if [ -n "$FUND_ZAHL" ]; then sollt="Fund, $FUND_ZAHL Zeile(n)"; else sollt="Fund, ${#ERW[@]} Zeile(n)"; fi ;;
    kein-fund) sollt="kein Fund" ;;
    kein-fund+ausgabe) sollt="kein Fund, Aussage ueber die Standardausgabe" ;;
    lage-c) sollt="Lage C, Kennung $LC_KENNUNG" ;;
    lage-c+funde) sollt="Lage C, Kennung $LC_KENNUNG, ${#ERW[@]} Fund(e) in derselben Ausgabe" ;;
    abbruch) sollt="Abbruch des Skripts mit Rueckgabewert 1 (Makefile: A_FAIL)" ;;
    gleich) sollt="zwei Laeufe mit gleicher Ausgabe" ;;
    schreibfrei) sollt="Baum vor und nach dem Lauf gleich" ;;
    statisch) sollt="$STAT_SOLL" ;;
    arbeitsbaum) sollt="Arbeitsbaum vor und nach dem ganzen Lauf gleich" ;;
    *) herstellung_fehler "unbekannte Soll-Art $soll" ;;
  esac
  if [ -n "$NH_GRUND" ]; then
    ERG="NICHT_HERSTELLBAR"; IST="nicht herstellbar: $NH_GRUND"
  else
    if [ "$soll" != statisch ] && [ "$soll" != arbeitsbaum ]; then
      mkdir -p "${BAUM}/${SKRIPT_ORT%/*}" && cp "$PRUEFER" "$BAUM/$SKRIPT_ORT" || herstellung_fehler "Kopie des gepruefen Skripts nach $SKRIPT_ORT"
    fi
    cwd="${CWD_WAHL:-$BAUM}"
    case "$soll" in
      fund|kein-fund|kein-fund+ausgabe|lage-c+funde)
        lauf_pruefer "$cwd" "$out" "$err" "${ENV_ZUSATZ[@]+"${ENV_ZUSATZ[@]}"}"
        bewerte_funde "$soll" "$out" "$err" "$LAUF_RC"
        if [ "$soll" = "kein-fund+ausgabe" ] || [ "${#AUSGABE_MIT[@]}" -gt 0 ] || [ "${#AUSGABE_OHNE[@]}" -gt 0 ]; then ausgabe_pruefen "$out"; fi
        ;;
      abbruch)
        lauf_pruefer "$cwd" "$out" "$err" "${ENV_ZUSATZ[@]+"${ENV_ZUSATZ[@]}"}"
        IST="Rueckgabewert $LAUF_RC"
        if [ "$LAUF_RC" = 124 ] || [ "$LAUF_RC" = 137 ]; then ERG=GEFALLEN; IST="Zeitgrenze von $FALL_ZEITGRENZE s ueberschritten (Rueckgabewert $LAUF_RC)"
        elif [ "$LAUF_RC" != 1 ]; then ERG=GEFALLEN; DETAIL+=("Rueckgabewert $LAUF_RC statt 1"); fi
        if grep -q '^Befunde:' "$out"; then ERG=GEFALLEN; DETAIL+=("Standardausgabe enthaelt 'Befunde:'"); fi
        ;;
      lage-c)
        lauf_pruefer "$cwd" "$out" "$err" "${ENV_ZUSATZ[@]+"${ENV_ZUSATZ[@]}"}"
        bewerte_lagec "$out" "$err" "$LAUF_RC"
        ;;
      gleich)
        if [ "${#ENV_ZUSATZ2[@]}" -eq 0 ]; then ENV_ZUSATZ2=("${ENV_ZUSATZ[@]+"${ENV_ZUSATZ[@]}"}"); fi
        lauf_pruefer "$cwd" "$FALL/aus1.txt" "$FALL/fehler1.txt" "${ENV_ZUSATZ[@]+"${ENV_ZUSATZ[@]}"}"; rc1=$LAUF_RC
        lauf_pruefer "$cwd" "$FALL/aus2.txt" "$FALL/fehler2.txt" "${ENV_ZUSATZ2[@]+"${ENV_ZUSATZ2[@]}"}"; rc2=$LAUF_RC
        a=gleich; cmp -s "$FALL/aus1.txt" "$FALL/aus2.txt" || a=verschieden
        b=gleich; cmp -s "$FALL/fehler1.txt" "$FALL/fehler2.txt" || b=verschieden
        IST="Rueckgabewerte $rc1 und $rc2, Standardausgabe $a, Fehlerausgabe $b"
        if [ "$rc1" = 124 ] || [ "$rc2" = 124 ]; then ERG=GEFALLEN; DETAIL+=("Zeitgrenze von $FALL_ZEITGRENZE s ueberschritten"); fi
        if [ ! -s "$FALL/aus1.txt" ] && [ ! -s "$FALL/fehler1.txt" ]; then ERG=GEFALLEN; DETAIL+=("der erste Lauf hat keine Ausgabe erzeugt: Gleichheit allein sagt dann nichts"); fi
        if [ "$rc1" != "$rc2" ]; then ERG=GEFALLEN; DETAIL+=("Rueckgabewerte verschieden"); fi
        if [ "$a" != gleich ]; then ERG=GEFALLEN; DETAIL+=("Standardausgabe verschieden: $(cmp "$FALL/aus1.txt" "$FALL/aus2.txt" 2>&1 | head -n 1 | cut -c1-120)"); fi
        if [ "$b" != gleich ]; then ERG=GEFALLEN; DETAIL+=("Fehlerausgabe verschieden: $(cmp "$FALL/fehler1.txt" "$FALL/fehler2.txt" 2>&1 | head -n 1 | cut -c1-120)"); fi
        for s in "${AUSGABE_MIT[@]+"${AUSGABE_MIT[@]}"}"; do
          if ! grep -qxF -- "$s" "$FALL/aus1.txt"; then ERG=GEFALLEN; DETAIL+=("Standardausgabe des ersten Laufs enthaelt die Zeile nicht: $s"); fi
        done
        if [ "${#ERW[@]}" -gt 0 ]; then
          funde_lesen "$FALL/aus1.txt"
          for s in "${ERW[@]}"; do
            d=0
            for a in "${IST_FUNDE[@]+"${IST_FUNDE[@]}"}"; do
              if [ "$(feld "$a" 1)" = "$(feld "$s" 1)" ] && [ "$(feld "$a" 2)" = "$(feld "$s" 2)" ]; then d=1; fi
            done
            if [ "$d" = 0 ]; then ERG=GEFALLEN; DETAIL+=("erster Lauf ohne den Fund: $(printf '%s' "$s" | tab_sichtbar)"); fi
          done
        fi
        ;;
      schreibfrei)
        vor=$(baum_voll "$BAUM" "$BAUM") || herstellung_fehler "Zustand des Baums vorher"
        lauf_pruefer "$cwd" "$out" "$err" "${ENV_ZUSATZ[@]+"${ENV_ZUSATZ[@]}"}"
        nach=$(baum_voll "$BAUM" "$BAUM") || herstellung_fehler "Zustand des Baums nachher"
        if [ ! -s "$out" ] && [ ! -s "$err" ]; then ERG=GEFALLEN; DETAIL+=("der Lauf hat keine Ausgabe erzeugt: Unveraendertheit allein sagt dann nichts"); fi
        if [ "$vor" = "$nach" ]; then
          IST="Rueckgabewert $LAUF_RC, Baum vorher gleich nachher"
        else
          ERG=GEFALLEN; IST="Rueckgabewert $LAUF_RC, Baum nach dem Lauf veraendert"
          printf '%s\n' "$vor" > "$FALL/vor.txt"; printf '%s\n' "$nach" > "$FALL/nach.txt"
          DETAIL+=("Unterschied: $(cmp "$FALL/vor.txt" "$FALL/nach.txt" 2>&1 | head -n 1 | cut -c1-120)")
        fi
        ;;
      statisch)
        IST="$STAT_IST"
        if [ "$STAT_OK" != 1 ]; then ERG=GEFALLEN; fi
        ;;
      arbeitsbaum)
        nach=$(schnappschuss "$ARBEITSBAUM") || herstellung_fehler "Zustand des Arbeitsbaums nachher"
        if [ "$SCHNAPP_VORHER" = "$nach" ]; then
          IST="Arbeitsbaum vor und nach dem Lauf gleich"
        else
          ERG=GEFALLEN; IST="Arbeitsbaum nach dem Lauf veraendert"
          printf '%s\n' "$SCHNAPP_VORHER" > "$T/arb-vor.txt"; printf '%s\n' "$nach" > "$T/arb-nach.txt"
          DETAIL+=("Unterschied: $(cmp "$T/arb-vor.txt" "$T/arb-nach.txt" 2>&1 | head -n 1 | cut -c1-120)")
        fi
        ;;
    esac
    if [ -n "$NACH_FN" ]; then "$NACH_FN"; fi
  fi
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
# 12. Fallliste lesen und pruefen
# =============================================================================
fallliste_lesen() {
  local tag k kl so he ge fn
  while IFS='|' read -r tag k kl so he ge; do
    [ "$tag" = "#F" ] || continue
    [[ "$k" =~ ^A-[0-9]{3}$ ]] || lage_c_pm "Fallliste: ungueltige Kennung '$k'."
    [ -z "${FL_SOLL[$k]+x}" ] || lage_c_pm "Fallliste: Kennung $k doppelt."
    case "$so" in
      fund|kein-fund|kein-fund+ausgabe|lage-c|lage-c+funde|abbruch|gleich|schreibfrei|statisch|arbeitsbaum) ;;
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
    k="A-${fn#f_A}"
    [ -n "${FL_SOLL[$k]+x}" ] || lage_c_pm "Funktion $fn hat keine Zeile in der Fallliste."
  done < <(compgen -A function | grep -E '^f_A[0-9]{3}$')
}

# =============================================================================
# 13. Deckung: Kennungen des Kopfkommentars gegen die Faelle, in beide Richtungen
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
  echo "--- Deckung (getrennt von der Zaehlung der Faelle)"
  for grp in KA KC EA GA; do
    n=0
    for k in "${!IM_KOPF[@]}"; do if [ "${k:0:2}" = "$grp" ]; then n=$((n + 1)); fi; done
    if [ "$n" -gt 0 ]; then
      echo "$PM: Deckung: Gruppe $grp: $n Kennungen im Kopfkommentar des gepruefen Skripts"
    else
      echo "$PM: Deckung ABWEICHUNG: Gruppe $grp ohne Kennung im Kopfkommentar des gepruefen Skripts"
      DECK_ABW=$((DECK_ABW + 1))
    fi
  done
  fehl=""
  while IFS= read -r k; do
    [ -n "$k" ] || continue
    if [ "${KL_ANZ[$k]:-0}" -eq 0 ]; then fehl="$fehl $k"; DECK_ABW=$((DECK_ABW + 1)); fi
    if [ "${k:0:2}" = "KA" ]; then
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
    echo "$PM: Deckung ABWEICHUNG: $anz Klassen, die Faelle nennen, stehen nicht im Kopfkommentar des gepruefen Skripts:$fehl"
    DECK_ABW=$((DECK_ABW + anz))
  fi
  if [ "$DECK_ABW" -eq 0 ]; then
    echo "$PM: Deckung: ohne Abweichung"
  else
    echo "$PM: Deckung: $DECK_ABW Abweichungen"
  fi
}

# =============================================================================
# 14. Modus --mutationen: Mutationsdatei lesen, Mutationen fahren, Deckung der Mutationen
# =============================================================================
MUT_N=0; MUT_ABW=0
MUT_ID=(); MUT_KL=(); MUT_ED=(); MUT_MS=(); MUT_GR=()

mutationsdatei_lesen() { # Form der Mutationsdatei: ein Fehler hier ist Lage C des Pruefmittels
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
    [[ "$id" =~ ^AM-[0-9]{3}$ ]] || lage_c_pm "Mutationsdatei Zeile $zn: Kennung '$id' ist nicht AM-nnn."
    [ -z "${gesehen[$id]+x}" ] || lage_c_pm "Mutationsdatei Zeile $zn: Kennung $id doppelt."
    gesehen[$id]=1
    [[ "$kl" =~ ^(KA|KC|EA)-[0-9]+$ ]] || lage_c_pm "Mutationsdatei Zeile $zn: Klasse '$kl' ist keine Kennung KA, KC oder EA."
    [ -n "$ed" ] && [ -n "$gr" ] || lage_c_pm "Mutationsdatei Zeile $zn: sed-Ausdruck oder Grund fehlt."
    [[ "$ms" =~ ^A-[0-9]{3}(,A-[0-9]{3})*$ ]] || lage_c_pm "Mutationsdatei Zeile $zn: Mindestsatz '$ms' ist keine Liste von Fallkennungen."
    for f in ${ms//,/ }; do
      [ -n "${FL_SOLL[$f]+x}" ] || lage_c_pm "Mutationsdatei Zeile $zn: Fall $f des Mindestsatzes steht nicht in der Fallliste."
      [ "${FL_SOLL[$f]}" != arbeitsbaum ] || lage_c_pm "Mutationsdatei Zeile $zn: Fall $f (Soll arbeitsbaum) prueft das Skript nicht und steht in keinem Mindestsatz."
    done
    MUT_ID+=("$id"); MUT_KL+=("$kl"); MUT_ED+=("$ed"); MUT_MS+=("$ms"); MUT_GR+=("$gr")
  done < "$MUTATIONSDATEI"
  MUT_N=${#MUT_ID[@]}
  [ "$MUT_N" -gt 0 ] || lage_c_pm "Mutationsdatei ohne Mutation."
}

mutationsdeckung_pruefen() { # jede Klasse KA, KC und EA des Kopfkommentars hat eine Mutation mit einem Fall dieser Klasse im Mindestsatz
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
      KA|KC|EA) if [ -z "${abgedeckt[$k]+x}" ]; then fehl="$fehl $k"; anz=$((anz + 1)); fi ;;
    esac
  done < <(kopf_kennungen)
  if [ "$anz" -gt 0 ]; then
    echo "$PM: Mutationsdeckung ABWEICHUNG: $anz Klassen des Kopfkommentars ohne Mutation (kein Fall der Klasse in einem Mindestsatz):$fehl"
    MUT_ABW=$((MUT_ABW + anz))
  fi
  if [ "$MUT_ABW" -eq 0 ]; then
    echo "$PM: Mutationsdeckung: jede Klasse KA, KC und EA hat eine Mutation, ohne Abweichung"
  else
    echo "$PM: Mutationsdeckung: $MUT_ABW Abweichungen"
  fi
}

mutationen_fahren() { # alle Mutationen gegen Kopien des Skripts; Rueckgabewert 0 nur ohne Abweichung
  local i id kl ed ms gr mut f erg offen wl n_ok=0 n_nicht=0 n_wl=0 abw=0 nach
  mkdir -p "$T/mutanten" || lage_c_pm "Verzeichnis fuer die Mutanten nicht anlegbar."
  echo "--- Mutationen ($MUT_N; je Mutation laufen nur die Faelle des Mindestsatzes gegen die Mutante)"
  for ((i = 0; i < MUT_N; i++)); do
    id="${MUT_ID[$i]}"; kl="${MUT_KL[$i]}"; ed="${MUT_ED[$i]}"; ms="${MUT_MS[$i]}"; gr="${MUT_GR[$i]}"
    mut="$T/mutanten/$id.sh"; wl=""
    if ! sed -E --sandbox -e "$ed" "$PRUEFER_ORIG" > "$mut" 2> "$T/mutanten/$id.sed"; then
      wl="sed endet mit Fehler: $(head -n 1 "$T/mutanten/$id.sed" | cut -c1-120)"
    elif cmp -s "$PRUEFER_ORIG" "$mut"; then
      wl="die Kopie ist byte-gleich mit dem Skript"
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
  nach=$(schnappschuss "$ARBEITSBAUM") || lage_c_pm "Zustand des Arbeitsbaums nicht erhebbar."
  if [ "$SCHNAPP_VORHER" = "$nach" ]; then
    echo "$PM: Arbeitsbaum vor und nach dem ganzen Lauf gleich"
  else
    echo "$PM: ABWEICHUNG: Arbeitsbaum nach dem Lauf veraendert"; abw=1
  fi
  [ "$n_nicht" -eq 0 ] && [ "$n_wl" -eq 0 ] && [ "$MUT_ABW" -eq 0 ] && [ "$abw" -eq 0 ]
}

# =============================================================================
# 15. Hauptablauf
# =============================================================================
hauptablauf() {
  local k grp rc zeit0 zeit1
  zeit0=$(date +%s)
  SCHNAPP_VORHER=$(schnappschuss "$ARBEITSBAUM") || lage_c_pm "Zustand des Arbeitsbaums nicht erhebbar."
  fallliste_lesen
  echo "$PM: Kopf -- Arbeitsbaum $ARBEITSBAUM, Commit $ARB_COMMIT, Skript $PRUEFER sha256 $PRUEFER_SHA, Mutationsdatei $MUT_SHA, Anforderung R3-Q-001, Einheit G3.2"
  grundbaum_bauen || lage_c_pm "Grundbaum nicht herstellbar (Defekt des Pruefmittels oder der Umgebung)."
  echo "$PM: Modus $MODUS; Grundbau in $GRUND"
  if [ "$MODUS" = mutationen ]; then
    mutationsdatei_lesen
    PRUEFER_ORIG="$PRUEFER"
    PRUEFER="$T/grundlinie.sh"
    cp "$PRUEFER_ORIG" "$PRUEFER" || lage_c_pm "Kopie des Skripts nicht anlegbar."
    echo "--- Grundlinie: alle ${#FL_ORDER[@]} Faelle gegen eine unveraenderte Kopie des Skripts (gezeigt werden nur Faelle, die nicht bestehen)"
    : > "$T/grundlinie.log"
    for k in "${FL_ORDER[@]}"; do fall_ausfuehren "$k" >> "$T/grundlinie.log"; done
    while IFS= read -r zeile; do
      case "$zeile" in
        A-[0-9]*) zeigen=0; case "$zeile" in *" GEFALLEN |"*|*" NICHT_HERSTELLBAR |"*) zeigen=1 ;; esac ;;
      esac
      if [ "${zeigen:-0}" = 1 ]; then printf '%s\n' "$zeile"; fi
    done < "$T/grundlinie.log"
  else
    echo "--- Faelle"
    for k in "${FL_ORDER[@]}"; do fall_ausfuehren "$k"; done
  fi
  echo "--- Zusammenfassung der Faelle"
  echo "$PM: ${#FL_ORDER[@]} Faelle: $ANZ_B bestanden, $ANZ_G gefallen, $ANZ_H nicht herstellbar"
  for grp in KA KC EA GA; do
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
