#!/usr/bin/env bash
# SessionStart-Hook: holt die Git-Historie nach, wenn der Klon der Sitzung
# flach ist -- Pruefmittel des Kettenschritts D20 (ADR 0002, 6.12.17, G16).
#
# Zweck: ADR 0002, Abschnitt 10, Entscheidpunkt E-F ("Flacher Klon blockiert
# (G16)"), Weisung vom 2026-09-22, zur Frage delegiert, ob ein flacher Klon
# beim Sitzungsstart durch einen Hook nachgeholt werden soll. Ein flacher
# Klon ist Lage C (FEHLT=git-historie, Makefile, Ziel "belege", Zeilen 703
# bis 713): die lokale Git-Historie ist zwar vorhanden, traegt die Aussage
# ueber Commit-Pruefsummen aber nicht (ADR 0002, 6.9.2 und 6.12.17). Das
# musste am 2026-09-07 und am 2026-09-21 je von Hand nachgeholt werden
# (git fetch --unshallow).
#
# Behebungsrunde vom 2026-09-22 (statische Pruefung, B-01 bis B-10): ein
# blockierender Befund (B-01, GIT_DIR verlegte den Gegenstand) und neun
# nachrangige Befunde behoben.
#
# Zweite Behebungsrunde vom 2026-09-22 (Codex-Review, Pull Request
# r3cosint#17, P1 und P2): P1 -- der Fetch ohne Refspec haette die
# konfigurierten remote.origin.fetch-Refspecs verwendet und bei einer
# nicht-standardmaessigen Refspec einen lokalen Zweig unter refs/heads/
# schreiben koennen; behoben mit einer expliziten, sicheren Refspec, die nur
# Remote-Tracking-Refs schreibt (siehe "Was der Hook NIE tut" und Schritt e).
# P2 -- GIT_TRACE, seine Auspraegungen (GIT_TRACE2 und weitere) und
# GIT_SHALLOW_FILE (statischer Befund N-04) konnten bei gesetztem Pfad in
# den Arbeitsbaum schreiben beziehungsweise die Schalenliste verlegen;
# beide werden jetzt zusammen mit den bereits geloeschten git-eigenen
# Variablen entfernt (siehe die unset-Zeilen direkt nach dem Signal-Trap).
#
# Dritte Behebungsrunde vom 2026-09-22 (Nachmessung des Dynamic Software
# Testers, Fall K-B2): P1 war nur halb behoben. Eine Refspec auf der
# Befehlszeile ersetzt zwar die konfigurierten remote.origin.fetch-Refspecs
# als ABRUFLISTE, git zieht die konfigurierten Refspecs aber weiterhin als
# REFMAP heran -- die konfigurierten Refspecs entscheiden weiterhin, wohin
# die abgerufenen Refs lokal abgelegt werden (git-fetch(1), Abschnitt
# "Configured Remote-tracking Branches": "they are only used to decide
# where the refs that are fetched are stored by acting as a mapping"). Mit
# einer konfigurierten Refspec wie
# "+refs/heads/claude/awesome-knuth-blvzpb:refs/heads/side" schrieb der Fetch
# trotz expliziter Abrufliste weiterhin den lokalen Zweig refs/heads/side.
# Behoben mit zusaetzlich "--refmap=''" (git-fetch(1): der dokumentierte Weg,
# die konfigurierte Refmap abzuschalten) an beiden Fetch-Aufrufen (Schritt
# e). Erst die explizite Refspec UND das leere Refmap zusammen tragen die
# Zusicherung "Zweige unberuehrt".
#
# Fuenfte Behebungsrunde vom 2026-09-22 (statische Nachpruefung, B-12 und
# B-13; Nachmessung r8 des Dynamic Software Testers bestanden) -- die vierte
# Runde betraf den gitleaks-Hook (B-14 bis B-16), bisherige Absaetze stehen
# unveraendert oberhalb: B-12 -- die Aufzaehlung dessen, was
# der Fetch in .git/ schreibt, war zu eng: gemessen legt der Fetch auch Tags
# unter refs/tags/ an, die in die geholte Historie zeigen (git folgt Tags
# automatisch), und entfernt bei fetch.prune=true veraltete
# Remote-Tracking-Refs unter refs/remotes/origin/ entlang der
# Befehlszeilen-Refspec (DST r8, Fall K-B4; "--refmap=''" unterbindet das
# nicht). Beides liegt in .git/, betrifft nie refs/heads/. Die Aufzaehlung
# im Absatz "Was der Hook NIE tut" ist entsprechend ergaenzt. B-13 -- zwei
# Stellen zitierten die Befehlszeile ohne Refspec und Refmap (Zeitbudget-Satz
# und die Fehlschlagsmeldung in Schritt e); beide sind auf den tatsaechlichen
# Aufruf umgestellt. Dazu, nicht umgesetzt, als Entscheid festgehalten: die
# GIT_CONFIG_*-Variablen werden bewusst NICHT geloescht (siehe Kommentar bei
# den unset-Zeilen).
#
# Sechste Behebungsrunde vom 2026-09-22 (reine Textbefunde der Schlusspruefung
# s3 des Static Software Testers, kein Verhaltensmangel, keine Codezeile
# geaendert): S3-01 -- drei Stellen fuehrten einen Satz als woertliches
# git-fetch(1)-Zitat, der dort so nicht vorkommt (0 Treffer gegen
# https://git-scm.com/docs/git-fetch); an allen drei Stellen durch ein
# belegbares woertliches Zitat mit Quellenangabe ersetzt (Abschnitt
# "Was der Hook NIE tut", "Dritte Behebungsrunde" und der Kommentar in
# Schritt e). S3-03 -- die Begruendung, weshalb "--refmap=''" das Pruning
# nicht unterbindet, widersprach der eigenen Begriffsbildung; richtiggestellt
# (gemessen, SST Laeufe P, P2, P3): geprunt wird entlang der Abrufliste, das
# betrifft "--refmap=''" nicht. S3-05 -- dieser Absatz ergaenzt, dass die
# vierte Runde den gitleaks-Hook betraf.
#
# Warum dieser Hook UNTER KEINEN UMSTAENDEN blockiert: SessionStart ist ein
# Kanal, kein Gate. Rueckgabewert 2 wird in diesem Hook nicht verwendet; ob
# SessionStart ihn als Blockade wertet, wird hier nicht behauptet. Dieser
# Hook darf eine Sitzung so wenig verhindern wie session-start-eingang.sh
# und session-start-gitleaks.sh. Das Skript endet deshalb auf JEDEM Weg mit
# Rueckgabewert 0, auch bei jedem Fehlschlag des Nachholens und auch bei
# einem Signal (siehe die Absaetze zum Signal-Trap weiter unten).
#
# Was der Hook NIE tut: er aendert nie den Arbeitsbaum, nie einen Zweig, nie
# HEAD, nie den Index. "git fetch --unshallow" schreibt in .git/
# ausschliesslich: Objekte; Remote-Tracking-Refs unter refs/remotes/origin/
# (bei fetch.prune=true entfernt der Fetch darunter auch veraltete Eintraege
# entlang der Befehlszeilen-Refspec, wenn die Gegenstelle den Zweig nicht
# mehr fuehrt -- gemessen, DST r8, Fall K-B4; geprunt wird entlang der
# tatsaechlich verwendeten Abrufliste, hier der Befehlszeilen-Refspec;
# "--refmap=''" betrifft nur die Abbildung auf lokale Refs und unterbindet
# das Entfernen deshalb nicht); und
# Tags unter refs/tags/, die in die geholte Historie zeigen (git folgt Tags
# automatisch). Nie refs/heads/, nie HEAD, nie Index, nie Arbeitsbaum -- kein
# Checkout, kein Merge, kein Umschreiben eines lokalen Zweigs. Dazu gibt der
# Fetch-Aufruf (Schritt e) die Refspec
# '+refs/heads/*:refs/remotes/origin/*' explizit auf der Befehlszeile an:
# eine Refspec auf der Befehlszeile ersetzt die in remote.origin.fetch
# konfigurierten Refspecs als ABRUFLISTE. Das allein genuegt nicht: git zieht
# die konfigurierten Refspecs weiterhin als REFMAP heran: sie entscheiden
# weiterhin, wohin die abgerufenen Refs lokal abgelegt werden (git-fetch(1),
# Abschnitt "Configured Remote-tracking Branches": "they are only used to
# decide where the refs that are fetched are stored by acting as a
# mapping"). Ohne ein zusaetzliches "--refmap=''" koennte ein Klon mit einer
# nicht-standardmaessigen
# remote.origin.fetch-Refspec wie
# "+refs/heads/claude/awesome-knuth-blvzpb:refs/heads/side" durch den Fetch
# trotz expliziter Abrufliste einen LOKALEN Zweig (hier refs/heads/side)
# aktualisieren -- im Widerspruch zur Zusicherung "Zweige unberuehrt". Erst
# die explizite Refspec UND "--refmap=''" zusammen (Schritt e) schalten die
# konfigurierte Refmap ab und tragen diese Zusicherung (Codex-Review, Pull
# Request r3cosint#17, P1; Nachmessung des Dynamic Software Testers, Fall
# K-B2).
#
# Die eine ausgehende Verbindung dieses Hooks: der bereits konfigurierte
# Remote "origin" des vorhandenen Klons. Diese Adresse ist hier nicht fest
# verdrahtet -- sie gehoert dem Klon, nicht diesem Skript. Schritt e prueft
# mit "git remote get-url origin" nur, dass origin konfiguriert ist; die
# Adresse loest "git fetch" selbst aus der Konfiguration auf. git liest
# HTTPS_PROXY/https_proxy und die uebliche Proxy-Konfiguration der Umgebung
# von selbst. Das ist Nachholen eines Pruefmittels fuer die Kette, kein
# Rueckkanal des Produkts (5.4): keine Telemetrie, kein Fehlerbericht, keine
# Aktualisierungsabfrage. Das Skript liest selbst nur CLAUDE_PROJECT_DIR; die
# git-eigenen Variablen, die den Gegenstand verlegen koennten, werden zu
# Beginn geloescht (direkt nach dem Signal-Trap, siehe dort); Proxy-Variablen
# liest git von selbst.
#
# Zeitbudget (settings.json-Grenze 120 s): der Fetch-Aufruf in Schritt e
# (git fetch --unshallow --refmap='' origin
# '+refs/heads/*:refs/remotes/origin/*') laeuft unter "timeout 90" (sofern
# timeout vorhanden ist; fehlt es, laeuft der Fetch ohne Zeitgrenze -- dann
# faengt allein die Grenze aus settings.json, siehe den Rueckfallzweig in
# Schritt e). Alle uebrigen
# Schritte (is-inside-work-tree, show-toplevel, is-shallow-repository,
# rev-list --count, remote get-url) liegen im Millisekundenbereich. 90 s plus
# Rest liegt deutlich unter der Grenze von 120 s aus settings.json. Ein Hook,
# der seine Zeitgrenze aus settings.json reisst, wird ohne Meldung
# abgebrochen und laesst durch (.claude/rules/claude-konfiguration.md);
# dieses Budget haelt die Grenze ein.
#
# Grenze des Signalverhaltens (B-04): bash fuehrt einen Signal-Trap erst aus,
# wenn die gerade laufende Vordergrundanweisung zurueckkehrt. Bei einem
# Signal waehrend des Fetches (bis zu 90 s, siehe Zeitbudget) verzoegert sich
# das Ende deshalb um bis zu diese Zeitspanne. Der Rueckgabewert 0 ist
# zugesichert, sein Zeitpunkt nicht.
#
# Grenze (benannt, nicht gemessen): bricht der Fetch durch SIGKILL hart ab,
# kann git unvollstaendige Objekte in .git/ zuruecklassen. Git bereinigt das
# nach eigener Dokumentation beim naechsten Fetch selbst -- das ist hier
# nicht gemessen und wird nicht als Zusicherung dieses Hooks behauptet.
#
# Dieser Hook ist Nachholen, nicht Pruefmittel: D20 bleibt das Pruefmittel.
# Bleibt der Klon flach -- weil git fehlt, CLAUDE_PROJECT_DIR nicht die
# Repository-Wurzel ist, kein Remote origin konfiguriert ist oder der Fetch
# scheitert --, meldet D20 weiterhin Lage C FEHLT=git-historie, nicht dieser
# Hook. Kann der Schalenzustand gar nicht bestimmt werden (git kennt
# --is-shallow-repository nicht), misst ebenfalls D20, nicht dieser Hook.
#
# Anforderungskennung: R3-Q-001 (dieser Hook setzt den Entscheidpunkt E-F des
# Definition-of-Done-Gates aus R3-Q-001 um, ADR 0002, Abschnitt 10).
# Pruefberichte sind in der Uebergabe
# docs/uebergaben/2026-09-22_git-historie-starthook.md zusammengefasst
# (Datei entsteht mit dieser Einheit).
set -uo pipefail

melden() {
    printf '[session-start-git-historie] %s\n' "$1"
}

# Der Signal-Trap steht bewusst ganz oben, direkt nach set -uo pipefail und
# der Definition von melden(): auch ein Signal vor oder waehrend jedem
# Schritt endet damit mit 0. Zur Verzoegerung durch die laufende
# Vordergrundanweisung siehe den Kopfkommentar ("Grenze des
# Signalverhaltens", B-04). Der Hook legt kein temporaeres Verzeichnis an und
# braucht deshalb keinen zusaetzlichen EXIT-Trap.
trap 'melden "abgebrochen durch Signal -- Zustand der Git-Historie nicht gemeldet, D20 misst ihn"; exit 0' HUP INT TERM

# git liest seine eigenen Umgebungsvariablen selbst; damit sie den
# Gegenstand (das zu pruefende Repository) nicht verlegen -- belegt: mit
# gesetztem GIT_DIR zielten Zaehlung und Fetch auf ein anderes
# Repository --, werden sie hier geloescht, bevor irgendein git-Aufruf
# erfolgt (B-01). GIT_SHALLOW_FILE verlegt zusaetzlich die Schalenliste und
# wird ebenso geloescht (statischer Befund N-04). Proxy- und TLS-Variablen
# bleiben unangetastet, weil sie den Weg zur Gegenstelle bestimmen, nicht den
# Gegenstand.
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_COMMON_DIR GIT_OBJECT_DIRECTORY GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_NAMESPACE GIT_CEILING_DIRECTORIES GIT_SHALLOW_FILE 2>/dev/null || true

# Alle Variablen, deren Name mit GIT_TRACE beginnt (GIT_TRACE selbst,
# GIT_TRACE2 und ihre weiteren Auspraegungen), lassen bei gesetztem Pfad
# jeden git-Aufruf dorthin schreiben -- moeglich auch in den Arbeitsbaum, im
# Widerspruch zu "schreibt nie in den Arbeitsbaum" (Codex-Review, Pull
# Request r3cosint#17, P2). "${!GIT_TRACE@}" listet die Namen aller
# gesetzten Variablen mit diesem Praefix; das ist ein Listen-Zugriff wie bei
# einem Array, kein Dereferenzieren einer moeglicherweise ungesetzten
# Variable, und liefert deshalb unter "set -u" auch dann keinen Fehler, wenn
# keine solche Variable gesetzt ist -- dann expandiert der Ausdruck auf kein
# einziges Wort, und "unset" ohne Argumente ist ebenfalls fehlerfrei.
unset "${!GIT_TRACE@}" 2>/dev/null || true

# Entscheid zu GIT_CONFIG_* (Restluecke aus B-11, bewusst NICHT umgesetzt,
# fuenfte Behebungsrunde): GIT_CONFIG_COUNT, GIT_CONFIG_KEY_n und
# GIT_CONFIG_VALUE_n werden hier NICHT geloescht. Grund, gemessen am
# 2026-09-22 in dieser Sitzungsumgebung: der Harness setzt darueber
# credential.interactive=false und zwei url.https://github.com/.insteadOf
# -Regeln (fuer git@github.com: und ssh://git@github.com/); ein Loeschen
# koennte in anderen Umgebungen den Fetch-Weg (Anmeldung, URL-Umschreibung)
# kappen, und dieser Hook soll das Pruefmittel bereitstellen, nicht
# verweigern. Eine darueber eingeschleuste remote.origin.fetch-Refspec wirkt
# wegen --refmap='' nicht mehr auf refs/heads/ (statische Pruefung, Laeufe J
# und K). Was darueber sonst eingeschleust werden kann (etwa core.hooksPath),
# trifft jeden git-Aufruf der Sitzung gleichermassen und ist keine
# Eigenschaft dieses Hooks. GIT_REDIRECT_STDOUT und GIT_REDIRECT_STDERR sind
# auf Linux wirkungslos (gemessen) und stehen deshalb nicht in der
# unset-Liste oben.
#
# Physischer (aufgeloester) Pfad eines Verzeichnisses -- fuer den Vergleich
# CLAUDE_PROJECT_DIR gegen die Repository-Wurzel (B-06). readlink -f
# bevorzugt, cd -P/pwd -P als Rueckfall, falls readlink fehlt oder -f nicht
# unterstuetzt (Muster wie in session-start-gitleaks.sh).
physischer_pfad() {
    local pfad="$1"
    local ergebnis=""
    if command -v readlink >/dev/null 2>&1; then
        ergebnis="$(readlink -f -- "$pfad" 2>/dev/null)"
    fi
    if [ -z "$ergebnis" ]; then
        ergebnis="$(cd -P -- "$pfad" 2>/dev/null && pwd -P 2>/dev/null)"
    fi
    printf '%s' "$ergebnis"
}

# a) Pruefmittel: git ist zwingend, timeout optional (Rueckfall ohne
# Zeitgrenze siehe Kopfkommentar, Zeitbudget).
if ! command -v git >/dev/null 2>&1; then
    melden "kann nicht nachholen: git fehlt -- D20 meldet Lage C"
    exit 0
fi

# b) Arbeitsbaum muss bestimmbar sein -- fail-closed wie
# session-start-gitleaks.sh. Kein Rueckfall auf $PWD.
if [ -z "${CLAUDE_PROJECT_DIR:-}" ]; then
    melden "Arbeitsbaum nicht bestimmbar (CLAUDE_PROJECT_DIR fehlt) -- nichts nachgeholt"
    exit 0
fi
projekt="$CLAUDE_PROJECT_DIR"

# c) Kein Git-Arbeitsbaum unter dem bestimmten Pfad.
if [ "$(git -C "$projekt" rev-parse --is-inside-work-tree 2>/dev/null)" != "true" ]; then
    melden "kein Git-Arbeitsbaum unter CLAUDE_PROJECT_DIR -- nichts nachgeholt"
    exit 0
fi

# c2) CLAUDE_PROJECT_DIR muss die Wurzel des Repositories sein (B-06): sonst
# koennten Zaehlung und Fetch-Ziel wie bei einem verlegten GIT_DIR (B-01) an
# einem anderen Gegenstand haengen, hier ueber einen Unterordner statt einer
# Umgebungsvariable. Physischer Pfadvergleich, damit ein Symlink oder ein
# nicht aufgeloester Pfad keinen falschen Treffer erzeugt.
wurzel="$(git -C "$projekt" rev-parse --show-toplevel 2>/dev/null)"
projekt_physisch="$(physischer_pfad "$projekt")"
wurzel_physisch="$(physischer_pfad "$wurzel")"
if [ -z "$wurzel" ] || [ -z "$projekt_physisch" ] || [ -z "$wurzel_physisch" ] || [ "$projekt_physisch" != "$wurzel_physisch" ]; then
    melden "CLAUDE_PROJECT_DIR ist nicht die Wurzel des Repositories (${wurzel:-unbekannt}) -- nichts nachgeholt"
    exit 0
fi

# d) Schalenzustand vorher (B-02): "git rev-parse --is-shallow-repository"
# gibt bei bekannter Option exakt "true" oder "false" aus. Kennt eine
# git-Fassung die Option nicht, gibt sie den Optionsnamen auf stdout aus und
# endet trotzdem mit 0 -- ein Vergleich nur gegen "true" wuerde das
# faelschlich als "nicht flach" lesen. Deshalb wird exakt ausgewertet, mit
# einem eigenen dritten Zweig fuer jeden anderen Wert.
zustand_vorher="$(git -C "$projekt" rev-parse --is-shallow-repository 2>/dev/null)"
case "$zustand_vorher" in
    false)
        anzahl="$(git -C "$projekt" rev-list --count HEAD 2>/dev/null)"
        melden "Git-Historie vollstaendig (nicht flach), ${anzahl:-unbekannt} Commit(s), nichts zu tun"
        exit 0
        ;;
    true)
        : # flach -- weiter mit e)
        ;;
    *)
        melden "Schalenzustand nicht bestimmbar (git kennt --is-shallow-repository nicht) -- nichts nachgeholt; D20 misst"
        exit 0
        ;;
esac

# e) Flach: ohne konfigurierten Remote origin kein Fetch-Versuch.
if ! git -C "$projekt" remote get-url origin >/dev/null 2>&1; then
    melden "kein Remote origin -- nichts nachgeholt"
    exit 0
fi

vorher="$(git -C "$projekt" rev-list --count HEAD 2>/dev/null)"

# GIT_TERMINAL_PROMPT=0 (B-05): git wartet nie auf eine interaktive Eingabe
# (etwa Zugangsdaten), sondern bricht den Fetch sofort mit einem Fehler ab --
# in einer Sitzung ohne Terminal waere ein wartender Fetch sonst nicht von
# einem haengenden Prozess zu unterscheiden.
#
# Explizite Refspec '+refs/heads/*:refs/remotes/origin/*' (P1) UND
# '--refmap=""' (dritte Behebungsrunde, Nachmessung des Dynamic Software
# Testers, Fall K-B2): die Refspec auf der Befehlszeile ersetzt die in
# remote.origin.fetch konfigurierten Refspecs als ABRUFLISTE, git zieht sie
# aber weiterhin als REFMAP heran. Erst "--refmap=''" schaltet auch diese
# Refmap ab (git-fetch(1), Option --refmap: "Providing an empty <refspec>
# to the --refmap option causes Git to ignore the configured refspecs and
# rely entirely on the refspecs supplied as command-line arguments"); ohne
# diese Option koennte eine nicht-standardmaessige
# konfigurierte Refspec trotz expliziter Abrufliste einen lokalen Zweig
# unter refs/heads/ schreiben (siehe Kopfkommentar, "Was der Hook NIE tut").
# Beide Massnahmen zusammen tragen die Zusicherung "Zweige unberuehrt".
refspec='+refs/heads/*:refs/remotes/origin/*'
if command -v timeout >/dev/null 2>&1; then
    GIT_TERMINAL_PROMPT=0 timeout 90 git -C "$projekt" fetch --unshallow --refmap='' origin "$refspec" >/dev/null 2>&1
else
    GIT_TERMINAL_PROMPT=0 git -C "$projekt" fetch --unshallow --refmap='' origin "$refspec" >/dev/null 2>&1
fi

# Schalenzustand nachher, dieselbe exakte Auswertung wie in Schritt d
# (B-02).
zustand_nachher="$(git -C "$projekt" rev-parse --is-shallow-repository 2>/dev/null)"
case "$zustand_nachher" in
    false)
        nachher="$(git -C "$projekt" rev-list --count HEAD 2>/dev/null)"
        melden "Git-Historie nachgeholt: ${vorher:-unbekannt} -> ${nachher:-unbekannt} Commit(s), nicht mehr flach"
        ;;
    true)
        melden "Nachholen der Git-Historie fehlgeschlagen (git fetch --unshallow, Befehlszeile in Schritt e) -- D20 meldet Lage C FEHLT=git-historie"
        ;;
    *)
        melden "Schalenzustand nicht bestimmbar (git kennt --is-shallow-repository nicht) -- nichts nachgeholt; D20 misst"
        ;;
esac

exit 0
