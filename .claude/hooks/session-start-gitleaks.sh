#!/usr/bin/env bash
# SessionStart-Hook: stellt das Pruefmittel "gitleaks" fuer den Kettenschritt
# D11 (make geheimnisse) bereit, wenn es in der Sitzungsumgebung fehlt.
#
# Zweck: ADR 0002, Abschnitt 10, Entscheidpunkt E-E ("gitleaks bleibt
# blockierend"), Weisung vom 2026-09-22. Die Sitzungsumgebung ist ein
# ephemerer Container; gitleaks musste am 2026-09-02, 2026-09-07 und
# 2026-09-21 je von Hand installiert werden, sonst meldet D11 Lage C.
#
# Warum dieser Hook UNTER KEINEN UMSTAENDEN blockiert: SessionStart ist ein
# Kanal, kein Gate. Rueckgabewert 2 wird in diesem Hook nicht verwendet; ob
# SessionStart ihn als Blockade wertet, wird hier nicht behauptet. Dieser
# Hook darf eine Sitzung so wenig verhindern wie session-start-eingang.sh.
# Das Skript endet deshalb auf JEDEM Weg mit Rueckgabewert 0, auch bei jedem
# Fehlschlag der Bereitstellung.
#
# Die eine Gegenstelle dieses Hooks: zwei Abrufe (Archiv und
# Pruefsummendatei) bei github.com/gitleaks/gitleaks/releases/..., nur dann,
# wenn gitleaks fehlt, nur an diese feste, fest verdrahtete URL. Das ist
# Beschaffung eines Pruefmittels fuer die Kette, kein Rueckkanal des
# Produkts (5.4): keine Telemetrie, kein Fehlerbericht, keine
# Aktualisierungsabfrage, keine durch Umgebungsvariable uebersteuerbare
# Gegenstelle. curl liest HTTPS_PROXY/https_proxy und CURL_CA_BUNDLE aus der
# Umgebung von selbst, aber keine .curlrc: -q als erster Parameter beider
# curl-Aufrufe sorgt dafuer, dass die Standardkonfiguration aus CURL_HOME,
# XDG_CONFIG_HOME oder HOME nicht gelesen wird -- Eintraege wie url,
# connect-to oder Upload-Optionen dort koennten sonst eine andere
# Gegenstelle ansprechen. Die Start-URL ist fest verdrahtet; --proto '=https'
# und --proto-redir '=https' erlauben Umleitungen nur ueber https, den
# Zielhost der Umleitung bestimmt dabei die Gegenstelle -- GitHub liefert
# Release-Dateien ueblicherweise ueber eine Umleitung aus. Tragend bleibt
# die doppelte Pruefsummenpruefung (Schritt f), nicht die Adresse.
#
# Grenze: NUR linux_x64 ist gepinnt (Version, Archivname und SHA-256 unten
# als Konstanten). Jede andere Architektur wird ausdruecklich NICHT
# bereitgestellt -- eine Zusicherung ohne geprueften Wert gibt es nicht.
#
# Schreibt nie in den Arbeitsbaum: Ist CLAUDE_PROJECT_DIR nicht gesetzt oder
# leer, bricht der Hook in Fall B sofort ab, noch vor jedem Schreibvorgang
# (fail-closed wie das DoD-Gate) -- ohne bestimmbaren Arbeitsbaum wird
# nichts geschrieben. Ist CLAUDE_PROJECT_DIR gesetzt, werden das
# Basisverzeichnis fuer das temporaere Verzeichnis (Schritt d) und der
# naechste bereits vorhandene Vorfahre jedes Zielkandidaten (Schritt h)
# JEWEILS VOR dem ersten Anlegen oder Schreiben physisch dagegen geprueft
# (Praefixvergleich mit abschliessendem Schraegstrich, ermittelt ueber
# readlink -f oder ersatzweise cd -P/pwd -P). Liegt eines davon im
# Arbeitsbaum, installiert der Hook nichts. Damit ist "schreibt nie in den
# Arbeitsbaum" unbedingt wahr, nicht nur eine Absicht.
#
# Dieser Hook ist Bereitstellung, nicht Pruefmittel: Die Kette (D11) bleibt
# das Pruefmittel. Fehlt gitleaks trotz diesem Hook -- weil eine
# Voraussetzung fehlt, die Architektur nicht gepinnt ist, ein Download
# scheitert oder eine Pruefsumme nicht passt --, meldet D11 Lage C, nicht
# dieser Hook.
#
# Ersetzt kein Binary, das zum Pruefzeitpunkt (VOR jedem Download, siehe die
# Pruefung zwischen Schritt b und Schritt d) unter einem Zielkandidaten
# (/usr/local/bin oder $HOME/.local/bin) liegt -- etwa weil das Verzeichnis
# nicht im PATH steht und Fall A es deshalb nicht gefunden hat. Die
# Zusicherung gilt fuer diesen Pruefzeitpunkt, nicht unbedingt: zwischen der
# Pruefung und der atomaren Installation (Schritt h, mv -f) liegen bis zu
# rund 92 s Download und Pruefsummenpruefung, ohne Sperre. Ein zweiter,
# gleichzeitiger Lauf ist nicht abgesichert; das ist nicht vorgesehen, weil
# SessionStart auf startup|resume gematcht ist.
#
# Vierte Behebungsrunde vom 2026-09-22 (statische Nachpruefung, B-14 bis
# B-16): die Runden eins und drei betrafen den Git-Historie-Hook, Runde zwei
# (Codex-Review, Pull Request r3cosint#17, P2: curl -q gegen eine gelesene
# .curlrc und der Ersetzungsschutz) betraf beide Hooks -- ihre Aenderungen an
# dieser Datei sind an den betroffenen Stellen kommentiert (oben bei -q,
# unten bei Schritt b/d und den curl-Aufrufen). B-14 -- ein
# haengender Symlink unter einem Zielkandidaten wurde von der Pruefung
# "[ -e ]" allein nicht erkannt (haengender Symlink: "[ -e ]" falsch, "[ -L ]"
# wahr); ein Download waere gefolgt, mv -f haette den Symlink durch eine
# regulaere Datei ersetzt. Die Pruefung ist um "[ -L ]" erweitert (Schritt
# zwischen b und d). B-16 -- die bisherige Meldung benannte den PATH als
# Ursache, obwohl die Pruefung auch auf ein Verzeichnis, eine nicht
# ausfuehrbare Datei oder, seit B-14, einen haengenden Symlink zutrifft; die
# Meldung nennt jetzt nur, was geprueft wurde, keine Ursache, die darueber
# hinausgeht. B-15 -- die Kopfzusicherung "Ersetzt kein Binary" war zuvor
# unbedingt formuliert; der Mechanismus wirkt aber nur zum Pruefzeitpunkt,
# ohne Sperre gegen einen gleichzeitigen zweiten Lauf (siehe oben).
#
# Fuenfte Behebungsrunde vom 2026-09-22 (reine Textbefunde der
# Schlusspruefung s3 des Static Software Testers, keine Codezeile geaendert):
# S3-02 -- ein UTF-8-Umlaut im Kopfkommentar verletzte das Kriterium "reines
# ASCII", ersetzt; S3-06 -- ein Bezugswort ohne Bezug im Absatz zur
# Ersetzungs-Zusicherung berichtigt; S3-05 -- der Absatz zur vierten Runde
# nennt jetzt, welche Runden welche Datei betrafen. Die Runden zwei, vier und
# fuenf an diesem Hook sind in
# docs/uebergaben/2026-09-22_git-historie-starthook.md
# (Nachtrag nach dem Codex-Review) belegt.
#
# Anforderungskennung: R3-Q-001 (dieser Hook setzt den Entscheidpunkt E-E des
# Definition-of-Done-Gates aus R3-Q-001 um, ADR 0002, Abschnitt 10).
# Pruefberichte des Static und des Dynamic Software Testers vom 2026-09-22
# sind in der Uebergabe
# docs/uebergaben/2026-09-22_weisung-r3-q-010-freigabe-gitleaks-starthook.md
# zusammengefasst.
#
# Zeitbudget (settings.json-Grenze 120 s): zwei Downloads zu je hoechstens
# zwei Versuchen (Erstversuch plus ein Wiederholversuch, --retry 1) a
# hoechstens 20 s (--max-time 20) ergeben hoechstens 2 * 2 * 20 s = 80 s;
# dazu je Download rund 1 s Wartezeit zwischen den beiden Versuchen, macht
# 2 * 1 s = 2 s; dazu der Probelauf der entpackten Datei mit hoechstens 10 s
# (timeout 10, sofern vorhanden; fehlt es, laeuft der Probelauf ohne
# Zeitgrenze -- dann faengt allein die Grenze aus settings.json, siehe die
# Rueckfallzweige ohne timeout weiter unten); dazu Pruefsummenpruefung,
# Entpacken, chmod und Installation,
# alle im Millisekundenbereich. 80 s + 2 s + 10 s + Rest liegt deutlich unter
# der Grenze von 120 s aus settings.json. --connect-timeout 10 begrenzt
# zusaetzlich die Verbindungsphase innerhalb der 20 s je Versuch. Ein Hook,
# der seine Zeitgrenze aus settings.json reisst, wird ohne Meldung
# abgebrochen und laesst durch (.claude/rules/claude-konfiguration.md);
# dieses Budget haelt die Grenze ein.
#
# Grenze des Signalverhaltens (gemessen 2026-09-22): bash fuehrt einen
# Signal-Trap erst aus, wenn die gerade laufende Vordergrundanweisung
# zurueckkehrt. Bei einem Signal nur an den Hook-Prozess verzoegert sich das
# Ende deshalb um bis zu rund 42 s je Download (die laufende curl-Anweisung
# muss zuerst zurueckkehren) beziehungsweise um bis zu 10 s in Fall A (der
# Probelauf mit timeout 10, sofern vorhanden; fehlt es, laeuft der Probelauf
# ohne Zeitgrenze -- dann faengt allein die Grenze aus settings.json). Der
# Rueckgabewert 0 ist zugesichert, sein
# Zeitpunkt nicht. Trifft TERM oder HUP die ganze Prozessgruppe (nicht nur
# diesen Prozess), schreibt die Shell zusaetzlich "Terminated"
# beziehungsweise "Hangup" auf stderr (gemessen); die Standardausgabe bleibt
# leer. Das wird von diesem Hook nicht abgefangen und ist eine benannte
# Grenze. Downloads und Pruefsummenpruefung sind unabhaengig davon
# unterbrechbar: bei einem harten Ende durch SIGKILL bleibt das temporaere
# Verzeichnis unter ${TMPDIR:-/tmp} stehen (kein Trap kann das abfangen); bei normalem
# Ende und bei den abgefangenen Signalen HUP, INT und TERM wird aufgeraeumt.
set -uo pipefail

# Der Signal-Trap steht bewusst ganz oben, direkt nach set -uo pipefail:
# auch ein Signal waehrend Fall A (vor Anlage des temporaeren Verzeichnisses)
# endet damit mit 0. Sobald das temporaere Verzeichnis existiert, loest ein
# Signal zusaetzlich den weiter unten gesetzten EXIT-Trap aus, der es
# aufraeumt. Zum Zeitpunkt, zu dem der Trap tatsaechlich laeuft, siehe die
# Grenze des Signalverhaltens im Kopfkommentar oben.
trap 'exit 0' HUP INT TERM

melden() {
    printf '[session-start-gitleaks] %s\n' "$1"
}

# Nimmt eine moeglicherweise mehrzeilige Werkzeugausgabe, schneidet sie auf
# die erste Zeile zurueck und entfernt fuehrende und schliessende
# Leerzeichen -- Grundlage sowohl fuer den exakten Versionsvergleich als
# auch fuer knappe, einzeilige Meldungen.
erste_zeile_ohne_leerraum() {
    local eingabe="$1"
    local zeile="${eingabe%%$'\n'*}"
    zeile="${zeile#"${zeile%%[![:space:]]*}"}"
    zeile="${zeile%"${zeile##*[![:space:]]}"}"
    printf '%s' "$zeile"
}

# Physischer (aufgeloester) Pfad eines Verzeichnisses, fuer den
# Arbeitsbaum-Vergleich unten. readlink -f bevorzugt, cd -P/pwd -P als
# Rueckfall, falls readlink fehlt oder -f nicht unterstuetzt.
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

# Wahr, wenn der uebergebene Pfad physisch innerhalb von CLAUDE_PROJECT_DIR
# liegt (Praefixvergleich mit abschliessendem Schraegstrich). Ohne gesetztes
# CLAUDE_PROJECT_DIR, ohne existierenden Pfad oder ohne aufloesbaren Pfad:
# falsch, nicht blockierend (der Aufrufer entscheidet, was das bedeutet).
im_arbeitsbaum() {
    local kandidat="$1"
    local projekt="${CLAUDE_PROJECT_DIR:-}"
    [ -n "$projekt" ] || return 1
    [ -e "$kandidat" ] || return 1
    local projekt_physisch kandidat_physisch
    projekt_physisch="$(physischer_pfad "$projekt")"
    kandidat_physisch="$(physischer_pfad "$kandidat")"
    [ -n "$projekt_physisch" ] && [ -n "$kandidat_physisch" ] || return 1
    case "${kandidat_physisch%/}/" in
        "${projekt_physisch%/}/"*) return 0 ;;
        *) return 1 ;;
    esac
}

# Naechster bereits vorhandener Vorfahre eines Pfads (kein dirname): steigt
# ueber Parametererweiterung auf, bis ein existierendes Verzeichnis
# gefunden ist. Dient dazu, den Arbeitsbaum-Vergleich VOR jedem mkdir
# durchzufuehren -- an einem Pfad, der noch nicht existiert, liefe
# im_arbeitsbaum sonst leer (siehe dort: [ -e "$kandidat" ] || return 1).
# Nur fuer absolute Pfade: ein relativer Pfad wird abgelehnt (nichts
# ausgegeben, Rueckgabewert 1), weil "${p%/*}" ihn sonst unveraendert liesse
# und die Schleife nicht terminierte. Aendert die Parametererweiterung p
# ausnahmsweise dennoch nicht (zusaetzliche Absicherung), wird abgebrochen
# und "/" geliefert.
vorfahre_ermitteln() {
    local p="$1"
    case "$p" in
        /*) ;;
        *) return 1 ;;
    esac
    while [ ! -d "$p" ]; do
        if [ "$p" = "/" ] || [ -z "$p" ]; then
            p="/"
            break
        fi
        local vorher="$p"
        p="${p%/*}"
        if [ "$p" = "$vorher" ]; then
            p="/"
            break
        fi
        [ -n "$p" ] || p="/"
    done
    printf '%s' "$p"
}

# Konstanten (c): Version, Archivname, gepinnte Pruefsumme, Basis-URL und
# Name der veroeffentlichten Pruefsummendatei. Der Pruefsummenwert ist am
# 2026-09-07 und 2026-09-21 gegen die veroeffentlichte Pruefsummendatei
# geprueft worden (Uebergaben dieser Tage); fuer den 2026-09-02 ist eine
# Pruefsummenpruefung belegt, der Wert dort nicht woertlich. Er steht in
# ADR 0002, Abschnitt 10, E-E.
VERSION="8.21.2"
ARCHIV="gitleaks_${VERSION}_linux_x64.tar.gz"
PRUEFSUMME="5bc41815076e6ed6ef8fbecc9d9b75bcae31f39029ceb55da08086315316e3ba"
BASIS_URL="https://github.com/gitleaks/gitleaks/releases/download/v${VERSION}/"
PRUEFSUMMENDATEI="gitleaks_${VERSION}_checksums.txt"

# Fall A: gitleaks ist bereits vorhanden. Keine Installation, keine
# Aenderung -- nur melden, was da ist.
if command -v gitleaks >/dev/null 2>&1; then
    pfad="$(command -v gitleaks)"
    if command -v timeout >/dev/null 2>&1; then
        ausgabe="$(timeout 10 "$pfad" version 2>/dev/null)"
    else
        ausgabe="$("$pfad" version 2>/dev/null)"
    fi
    version_zeile="$(erste_zeile_ohne_leerraum "$ausgabe")"
    melden "gitleaks gefunden unter $pfad, 'gitleaks version': $version_zeile"
    if [ "$version_zeile" != "$VERSION" ]; then
        melden "weicht von der gepinnten Fassung $VERSION ab; nichts geaendert"
    fi
    exit 0
fi

# Fall B: gitleaks fehlt. Bereitstellung nach den Schritten a bis i (c, die
# Konstanten, steht oberhalb von Fall A; dazu, zwischen a und b, die
# Bestimmbarkeit des Arbeitsbaums; dazu, zwischen b und d, die
# Kandidatenliste und die Pruefung auf ein bereits vorhandenes Binary),
# jeder Fehlschlag bricht mit einer Meldung ab und endet mit 0.

# a) Pruefmittel des Hooks selbst. 'install' wird nicht mehr gebraucht --
# Schritt h installiert ausschliesslich ueber mktemp, cp, chmod und mv.
fehlende=""
for werkzeug in curl sha256sum tar gzip mktemp awk uname grep mkdir chmod mv rm cp; do
    command -v "$werkzeug" >/dev/null 2>&1 || fehlende="${fehlende:+$fehlende, }$werkzeug"
done

if [ -n "$fehlende" ]; then
    melden "kann nicht bereitstellen: $fehlende fehlt -- D11 meldet Lage C"
    exit 0
fi

# Arbeitsbaum muss bestimmbar sein, bevor irgendetwas angelegt oder
# geschrieben wird (fail-closed wie das DoD-Gate): ohne CLAUDE_PROJECT_DIR
# laesst sich "schreibt nie in den Arbeitsbaum" nicht pruefen, also wird in
# diesem Fall nichts geschrieben.
if [ -z "${CLAUDE_PROJECT_DIR:-}" ]; then
    melden "Arbeitsbaum nicht bestimmbar (CLAUDE_PROJECT_DIR fehlt) -- nichts installiert"
    exit 0
fi
projekt_pfad_geprueft="$(physischer_pfad "$CLAUDE_PROJECT_DIR")"
if [ -z "$projekt_pfad_geprueft" ]; then
    melden "Arbeitsbaum nicht bestimmbar (CLAUDE_PROJECT_DIR nicht aufloesbar) -- nichts installiert"
    exit 0
fi

# b) Architektur: nur x86_64 ist gepinnt und wird bereitgestellt.
architektur="$(uname -m 2>/dev/null)"
if [ "$architektur" != "x86_64" ]; then
    melden "keine gepinnte Pruefsumme fuer $architektur, nichts installiert"
    exit 0
fi

# Kandidatenliste (fuer Schritt h) bereits hier bestimmen -- nur ein
# absoluter $HOME wird uebernommen: ein relativer Pfad wuerde relativ zum
# aktuellen Arbeitsverzeichnis angelegt, also womoeglich im Arbeitsbaum.
kandidaten=("/usr/local/bin")
home_verzeichnis="${HOME:-}"
case "$home_verzeichnis" in
    /*) kandidaten+=("$home_verzeichnis/.local/bin") ;;
esac

# Ersetzt kein Binary zum Pruefzeitpunkt: liegt unter einem Kandidaten
# bereits ein Eintrag namens gitleaks -- Datei, Verzeichnis oder Symlink,
# auch ein haengender --, wird das VOR jedem Download geprueft, es erfolgt in
# diesem Fall kein Abruf und keine Installation. "[ -e ]" allein prueft bei
# einem haengenden Symlink (Ziel fehlt) falsch (B-14); deshalb zusaetzlich
# "[ -L ]", das unabhaengig vom Ziel wahr ist, sobald der Pfad selbst ein
# Symlink ist.
for kandidat in "${kandidaten[@]}"; do
    if [ -e "$kandidat/gitleaks" ] || [ -L "$kandidat/gitleaks" ]; then
        melden "unter $kandidat/gitleaks liegt bereits ein Eintrag (Datei, Verzeichnis oder Symlink), der nicht als 'gitleaks' im PATH ausfuehrbar ist -- nicht ersetzt; D11 meldet Lage C, bis dort ein ausfuehrbares gitleaks im PATH liegt"
        exit 0
    fi
done

# d) Temporaeres Verzeichnis, nie im Arbeitsbaum. Das Basisverzeichnis wird
# VOR mktemp gegen den Arbeitsbaum geprueft: jedes von mktemp darin
# angelegte Verzeichnis liegt zwangslaeufig ebenfalls ausserhalb, wenn das
# Basisverzeichnis es tut, eine nachtraegliche Pruefung des angelegten
# Verzeichnisses entfaellt deshalb. Der Signal-Trap ist bereits oben,
# direkt nach set -uo pipefail, gesetzt; er loest bei einem Signal den
# gleich gesetzten EXIT-Trap aus, der das temporaere Verzeichnis aufraeumt.
basis_tmp="${TMPDIR:-/tmp}"
if im_arbeitsbaum "$basis_tmp"; then
    melden "Basisverzeichnis der Zwischenablage liegt im Arbeitsbaum -- nichts geladen, nichts installiert"
    exit 0
fi
tmpdir="$(mktemp -d "${basis_tmp%/}/session-start-gitleaks.XXXXXX" 2>/dev/null)"
if [ -z "$tmpdir" ] || [ ! -d "$tmpdir" ]; then
    melden "kann nicht bereitstellen: temporaeres Verzeichnis nicht anlegbar -- D11 meldet Lage C"
    exit 0
fi
temp_datei=""
trap 'rm -rf "$tmpdir" 2>/dev/null; [ -n "${temp_datei:-}" ] && rm -f "$temp_datei" 2>/dev/null' EXIT

archiv_pfad="$tmpdir/$ARCHIV"
pruefsummendatei_pfad="$tmpdir/$PRUEFSUMMENDATEI"

# e) Download beider Dateien -- die beiden Abrufe bei der einen Gegenstelle
# dieses Hooks, nur an die feste Basis-URL oben. -fsL ohne -S: curl bleibt
# auch bei Fehlschlag auf stderr still, die eigene Meldung des Hooks traegt
# den Fehlschlag. --proto-redir '=https' bindet auch eine Umleitung an
# https (siehe Kopfkommentar). -q als erster Parameter: keine .curlrc wird
# gelesen.
if ! curl -q -fsL --proto '=https' --proto-redir '=https' --tlsv1.2 --connect-timeout 10 --max-time 20 --retry 1 \
    -o "$archiv_pfad" "${BASIS_URL}${ARCHIV}"; then
    melden "Download des Archivs fehlgeschlagen (${BASIS_URL}${ARCHIV}) -- nichts installiert"
    exit 0
fi
if ! curl -q -fsL --proto '=https' --proto-redir '=https' --tlsv1.2 --connect-timeout 10 --max-time 20 --retry 1 \
    -o "$pruefsummendatei_pfad" "${BASIS_URL}${PRUEFSUMMENDATEI}"; then
    melden "Download der Pruefsummendatei fehlgeschlagen (${BASIS_URL}${PRUEFSUMMENDATEI}) -- nichts installiert"
    exit 0
fi

# f) Doppelte Pruefung, beide zwingend, fail-closed. Vor dieser Pruefung
# wird nichts entpackt und nichts ausgefuehrt.
gemessen="$(sha256sum "$archiv_pfad" 2>/dev/null | awk '{print $1}')"
if [ "$gemessen" != "$PRUEFSUMME" ]; then
    melden "Pruefsumme stimmt nicht ueberein -- nichts installiert (gemessen: ${gemessen:-leer}, erwartet: $PRUEFSUMME)"
    exit 0
fi

erwartete_zeile="${PRUEFSUMME}  ${ARCHIV}"
if ! grep -F -x -q -- "$erwartete_zeile" "$pruefsummendatei_pfad" 2>/dev/null; then
    melden "Pruefsumme stimmt nicht ueberein -- nichts installiert (veroeffentlichte Pruefsummendatei enthaelt nicht die Zeile '$erwartete_zeile')"
    exit 0
fi

# g) Nur den Member 'gitleaks' entpacken, pruefen, Probelauf.
if ! tar -xzf "$archiv_pfad" -C "$tmpdir" gitleaks 2>/dev/null; then
    melden "Entpacken fehlgeschlagen -- nichts installiert"
    exit 0
fi
if [ -L "$tmpdir/gitleaks" ]; then
    melden "entpacktes Element 'gitleaks' ist ein symbolischer Link -- nichts installiert"
    exit 0
fi
if [ ! -f "$tmpdir/gitleaks" ]; then
    melden "entpacktes Element 'gitleaks' ist keine regulaere Datei -- nichts installiert"
    exit 0
fi
if ! chmod 0755 "$tmpdir/gitleaks" 2>/dev/null; then
    melden "chmod auf die entpackte Datei fehlgeschlagen -- nichts installiert"
    exit 0
fi
if command -v timeout >/dev/null 2>&1; then
    probelauf="$(timeout 10 "$tmpdir/gitleaks" version 2>/dev/null)"
else
    probelauf="$("$tmpdir/gitleaks" version 2>/dev/null)"
fi
probelauf_zeile="$(erste_zeile_ohne_leerraum "$probelauf")"
if [ "$probelauf_zeile" != "$VERSION" ]; then
    melden "Probelauf der entpackten Datei meldet nicht $VERSION ('$probelauf_zeile') -- nichts installiert"
    exit 0
fi

# h) Zielverzeichnis: Schleife ueber die Kandidatenliste von oben
# (/usr/local/bin und, falls absolut, $HOME/.local/bin -- schon nach
# Schritt b bestimmt und dort auf ein vorhandenes Binary geprueft). Vor
# jedem mkdir wird der naechste bereits vorhandene Vorfahre des Kandidaten
# gegen den Arbeitsbaum geprueft (existiert der Kandidat schon, ist das der
# Kandidat selbst) -- erst danach mkdir -p. Liegt der Kandidat im
# Arbeitsbaum, wird NICHT abgebrochen (das koennte einen spaeteren,
# zulaessigen Kandidaten verhindern): stattdessen continue zum naechsten
# Kandidaten. Installation je Kandidat atomar: mktemp legt eine temporaere
# Datei IM Zielverzeichnis an, cp schreibt den Inhalt hinein (die Datei
# besteht durch mktemp bereits), chmod setzt die Rechte, mv -f benennt sie
# auf den endgueltigen Namen um. Scheitert ein Kandidat aus einem anderen
# Grund, wird die temporaere Datei entfernt und der naechste Kandidat
# versucht.
ziel=""
versucht=""
for kandidat in "${kandidaten[@]}"; do
    vorfahre="$(vorfahre_ermitteln "$kandidat")"
    if [ -z "$vorfahre" ]; then
        continue
    fi
    if im_arbeitsbaum "$vorfahre"; then
        melden "Zielverzeichnis $kandidat liegt im Arbeitsbaum -- nichts installiert"
        continue
    fi

    mkdir -p "$kandidat" 2>/dev/null
    [ -d "$kandidat" ] || continue

    versucht="${versucht:+$versucht, }$kandidat"

    temp_datei="$(mktemp "$kandidat/.gitleaks.neu.XXXXXX" 2>/dev/null)"
    if [ -z "$temp_datei" ] || [ ! -f "$temp_datei" ]; then
        continue
    fi

    if cp "$tmpdir/gitleaks" "$temp_datei" 2>/dev/null && chmod 0755 "$temp_datei" 2>/dev/null \
        && mv -f "$temp_datei" "$kandidat/gitleaks" 2>/dev/null; then
        ziel="$kandidat"
        temp_datei=""
        break
    fi
    rm -f "$temp_datei" 2>/dev/null
    temp_datei=""
done

if [ -z "$ziel" ]; then
    melden "Installation fehlgeschlagen (${versucht:-keine Kandidaten erreichbar}) -- nichts installiert"
    exit 0
fi

# i) Erfolg -- oder installiert, aber nicht auffindbar (PATH).
if command -v gitleaks >/dev/null 2>&1; then
    melden "gitleaks $VERSION bereitgestellt nach $ziel/gitleaks, Pruefsumme des Archivs geprueft (gepinnt und veroeffentlicht)"
else
    melden "installiert nach $ziel/gitleaks, aber nicht im PATH -- D11 meldet weiterhin Lage C, bis PATH das Verzeichnis enthaelt"
fi

exit 0
