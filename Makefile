# =============================================================================
# R3cOSINT — Makefile: Definition-of-Done-Befehlskette D1 bis D12 (plus D18)
# =============================================================================
#
# Grundlage: docs/adr/0002-architekturentscheid-ziel-stack.md, Abschnitt 6 und
# 6.1 (Fortschreibung vom 2026-08-30).
# Kriterien: docs/06_Definition_of_Ready_und_Done.md, Teil 2.
#
# Dieses Makefile ist der EINE Einstieg, den der noch zu bauende Hook aus
# R3-Q-001 aufruft (`make dod`). Aendert sich ein Werkzeug, aendert sich
# dieses Makefile, nicht der Hook (ADR 0002, Abschnitt 6, "Ein Einstieg fuer
# den Hook").
#
# D18 ist kein 13. Schritt in fortlaufender Zaehlung, sondern eine Kennung
# (ADR 0002, Abschnitt 6.1.2): D-Nummern werden nicht umnummeriert, weil sie
# in Dokumenten stehen, die einen vergangenen Stand belegen. D13 bis D17 sind
# bereits an die menschlich zu bestaetigenden Bedingungen aus
# docs/06_Definition_of_Ready_und_Done.md, Teil 2, vergeben; D18 ist die
# naechste freie Nummer. Die AUSFUEHRUNGSREIHENFOLGE steht ausschliesslich in
# der Zielliste von "dod" weiter unten: D1, D2, D3, D4, D18, D5, D6, D7, D8,
# D9, D10, D11, D12.
#
# -----------------------------------------------------------------------------
# Drei Lagen je Schritt, nicht zwei
# -----------------------------------------------------------------------------
#
#   Lage A — bestanden oder durchgefallen. Der Gegenstand der Pruefung
#            existiert, das Pruefmittel ist vorhanden, das Werkzeug lief.
#            Rueckgabewert entsprechend Erfolg oder Misserfolg.
#   Lage B — nicht anwendbar. Der Gegenstand der Pruefung existiert noch
#            nicht (z. B. backend/ fehlt). "Keine Beanstandung" ist wahr,
#            aber kein Freispruch. Rueckgabewert 0, MIT sichtbarer Meldung,
#            die nennt, welcher Schritt weshalb nicht anwendbar war.
#   Lage C — das Pruefmittel fehlt, obwaehrend es etwas zu pruefen gaebe.
#            Rueckgabewert 0 waere hier eine Luege. Der Schritt endet
#            ungleich 0 und nennt das fehlende Werkzeug samt Beschaffungsweg.
#
# Praezedenzfall im Projekt: .claude/hooks/block-main-write.sh und
# block-prototype-import.sh blockieren, wenn jq fehlt, statt stillschweigend
# durchzulassen (CLAUDE.md, Abschnitt "Aktive Gates": "Fehlt es, blockieren
# sie mit einer Meldung, statt stillschweigend durchzulassen.").
#
# -----------------------------------------------------------------------------
# Automatisches Scharfschalten
# -----------------------------------------------------------------------------
#
# Berichtigt (zweite Fortschreibung von ADR 0002 vom 2026-08-30, Abschnitt
# 6.2.2): Woran ein Kettenschritt seinen Gegenstand erkennt, stand in einer
# fruehen Fassung dieser Runde zweimal verschieden — hier als eigener,
# selbst erfundener Mechanismus (PRODUKTIONSCODE_ERKENNEN, eine generische
# Ausschlussliste), UND im ADR als literale Objekttabelle. Regel 2 der
# Objekttabelle (ADR 0002, Abschnitt 6): "Die Objektbedingung steht einmal.
# Massgeblich ist ausschliesslich die Tabelle [des ADR]." Der selbst
# erfundene Mechanismus ist deshalb entfernt; massgeblich ist ausschliesslich
# die Objekttabelle in ADR 0002, Abschnitt 6. Kurz, nicht normativ (bei
# Widerspruch gilt das ADR):
#   - D1 bis D8, Backend-Anteil: backend/pyproject.toml vorhanden (das
#     ERKLAERTE Python-Projekt, nicht nur ein Verzeichnis gleichen Namens).
#   - D1 bis D8, Oberflaechen-Anteil: frontend/package.json vorhanden.
#   - D1, Stapelbau: deploy/compose.test.yml vorhanden.
#   - D9: mindestens eine Datei unterhalb backend/, frontend/ oder deploy/ —
#     ein bewusst benannter, abgeschlossener Dreiersatz, keine generische
#     Suche (ADR 0002, Abschnitt 6, Objekttabelle, Zeile D9).
#   - D10: prototype/ vorhanden — nach 5.6 dauerhaft, der Schritt laeuft also
#     praktisch immer (ADR 0002, Abschnitt 6.2.2, "Weshalb D10 immer laeuft").
#   - D18: mindestens eine *.py-Datei unterhalb backend/src/, unabhaengig vom
#     Paketnamen (Befund zu 6.2.2: ein Paket unter z. B.
#     backend/src/r3cosint_api/ ist Produktionscode, auch wenn es nicht so
#     heisst, wie 4.1 es vorschreibt — ein Verstoss gegen die Namensgebung
#     muss die Pruefung AUSLOESEN, nicht abschalten).
# Jede dieser Bedingungen wird bei JEDEM Lauf zur LAUFZEIT geprueft, nicht als
# Kommentar hinterlegt: Erscheint der jeweilige Gegenstand, greift der Schritt
# beim naechsten Lauf zwingend, ohne dass dieses Makefile geaendert wird.
#
# -----------------------------------------------------------------------------
# Zuordnung D1 bis D12 und D18 zu einer Lage — Stand des Bestands am 2026-08-30
# -----------------------------------------------------------------------------
#
# Am heutigen Bestand existieren: kein backend/, kein frontend/package.json,
# kein deploy/. Vorhanden sind ausschliesslich Dokumentation, .claude/,
# prototype/OSINT_Plattform_Demo.html (eigenstaendige HTML-Datei ohne externe
# Verweise und ohne Importe, geprueft) und scripts/nachweise-erzeugen.sh.
# gitleaks fehlt. Die ausfuehrliche Begruendung je Schritt steht als Kommentar
# ueber dem jeweiligen Ziel; diese Tabelle ist nur die Kurzuebersicht.
# Reihenfolge hier wie in "dod": D1 bis D4, dann D18, dann D5 bis D12.
#
#   D1  bau                 Lage B  — nichts zu bauen (kein Teilbaum vorhanden)
#   D2  format-pruefen      Lage B  — nichts zu formatieren
#   D3  linter               Lage B  — nichts zu pruefen
#   D4  typen                Lage B  — nichts zu typpruefen
#   D18 architekturvertraege Lage B  — kein Paket unter backend/src/
#                                       vorhanden, keine Modulgrenzen, die
#                                       verletzt werden koennten
#   D5  test                 Lage B  — nichts zu testen
#   D6  abdeckung            Lage B  — nichts zu messen
#   D7  abnahme              Lage C  — Backlog existiert bereits mit echten
#                                       Abnahmekriterien, scripts/abnahme-
#                                       abgleich.sh fehlt vollstaendig
#   D8  abhaengigkeiten      Lage B  — nichts zu pruefen
#   D9  rueckkanal           Lage B  — weder backend/ noch frontend/ noch
#                                       deploy/ enthaelt eine Datei
#   D10 prototyp-trennung    Lage C  — prototype/ existiert bereits (ADR
#                                       0002, Abschnitt 6, Objekttabelle:
#                                       Gegenstand ist "prototype/ vorhanden",
#                                       nicht Produktionscode; der Schritt
#                                       laeuft nach 5.6 praktisch immer),
#                                       scripts/prototyp-trennung-pruefen.sh
#                                       fehlt vollstaendig
#   D11 geheimnisse          Lage C  — gitleaks fehlt, das Repository
#                                       existiert bereits und koennte
#                                       Geheimnisse enthalten (zwei Laeufe,
#                                       Arbeitsbaum und Historie, ADR 0002
#                                       Abschnitt 6.1.1)
#   D12 nachweise            Lage C  — scripts/nachweise-erzeugen.sh existiert
#                                       und laeuft echt; scripts/nachweise-
#                                       vollstaendig.sh fehlt vollstaendig
#
# Sobald backend/pyproject.toml, frontend/package.json oder
# deploy/compose.test.yml entstehen, wechseln D1 bis D8 automatisch nach
# Lage A. D9 wechselt nach Lage C, sobald backend/, frontend/ oder deploy/
# mindestens eine Datei enthaelt (ADR 0002, Abschnitt 6, Objekttabelle) und
# scripts/rueckkanal-pruefen.sh weiterhin fehlt. D10 ist bereits heute Lage C,
# weil prototype/ besteht (siehe Tabelle oben) und bleibt es, solange
# scripts/prototyp-trennung-pruefen.sh fehlt. D18 wechselt beim Erscheinen
# irgendeiner *.py-Datei unterhalb backend/src/ OHNE
# backend/importvertraege.toml sofort nach Lage C (Pruefmittel fehlt bei
# vorhandenem Gegenstand) — nicht erst, wenn zusaetzlich ein Werkzeug fehlt,
# und unabhaengig vom Namen des Pakets (ADR 0002, Abschnitt 6.2.2).
#
# Was dieses Makefile NICHT ist: kein Ersatz fuer die vier eigenen
# Projektskripte, die laut ADR 0002 Abschnitt 6 "mit dem Grundgeruest"
# entstehen (scripts/abnahme-abgleich.sh, scripts/rueckkanal-pruefen.sh,
# scripts/prototyp-trennung-pruefen.sh, scripts/nachweise-vollstaendig.sh),
# und kein Ersatz fuer backend/importvertraege.toml selbst, das laut ADR 0002
# Abschnitt 5 mit dem Grundgeruest entsteht. Fehlen sie, meldet der jeweilige
# Schritt das ehrlich statt es vorzutaeuschen.
# =============================================================================

SHELL := bash
.SHELLFLAGS := -uo pipefail -c
.ONESHELL:
.SILENT:
.DEFAULT_GOAL := dod

# GNU Make vor 3.82 kennt ".ONESHELL:" nicht und ignoriert das Spezialziel
# STILL, ohne Fehlermeldung. Ohne .ONESHELL zerfaellt jedes mehrzeilige
# Rezept dieser Datei in einzelne Shell-Aufrufe, Variablen wie hat_lage_c
# wandern nicht von Zeile zu Zeile weiter: Bash-Syntaxfehler und falsche
# Ergebnisse waeren die Folge, nicht sofort als "GNU Make zu alt" erkennbar.
# Deshalb hier ein Hartabbruch bei GNU Make < 3.82. Der Vergleich nutzt
# $(sort), weil GNU Make vor 4.4 keine eingebaute Zahlenvergleichsfunktion
# kennt; er setzt eine zweistellige Versionsschreibweise voraus (3.79 ..
# 3.82, danach 4.0, 4.1, ...), die der tatsaechlichen Versionsgeschichte von
# GNU Make entspricht.
ifeq ($(firstword $(sort 3.82 $(MAKE_VERSION))),$(MAKE_VERSION))
ifneq ($(MAKE_VERSION),3.82)
$(error Dieses Makefile braucht GNU Make ab 3.82 wegen .ONESHELL. Gefunden: $(MAKE_VERSION). Aeltere GNU-Make-Versionen ignorieren .ONESHELL still, die Rezepte zerfallen dann in Bash-Syntaxfehler)
endif
endif

.PHONY: bau format-pruefen linter typen architekturvertraege test abdeckung abnahme abhaengigkeiten rueckkanal prototyp-trennung geheimnisse nachweise dod

# Berichtigung (Full-Review 2026-08-30): Die fruehere Fassung dieses
# Kommentars behauptete, die eigene Kopie der Variable verhindere, dass
# "make -n dod" echte Kettenschritte ausloest. Das ist widerlegt (belegt
# mit einem Minimalbeispiel aussen/innen, GNU Make 4.3): ein Unter-Make-
# Aufruf bleibt unter "-n" ohnehin ein Trockenlauf, weil GNU Make "-n" ueber
# MAKEFLAGS an jeden Kindprozess weiterreicht -- unabhaengig davon, ob der
# Aufruf im Elternrezept woertlich "$(MAKE)" enthaelt. Der tatsaechliche,
# gemessene Grund liegt anderswo: Unter .ONESHELL wird das GESAMTE Rezept
# eines Ziels zu EINEM Text zusammengefasst, bevor GNU Make prueft, ob
# darin woertlich "$(MAKE)"/"${MAKE}" vorkommt. Enthielte "dod" diesen
# woertlichen Text irgendwo, wuerde GNU Make den KOMPLETTEN Rezeptkoerper
# von "dod" unter "-n" real ausfuehren -- die Schleife ueber alle
# Kettenschritte, jeder Unter-Make-Aufruf als echter Prozessstart, jede grep-
# Auswertung eingeschlossen. Jeder dieser Unter-Make-Aufrufe wuerde zwar
# (wegen der geerbten "-n") nur seinen EIGENEN Rezepttext ECHOEN statt
# ausfuehren -- aber dieser geechote Text enthaelt woertlich die Lage-
# Marke, weil sie Teil des angezeigten (nicht ausgefuehrten) "echo"-Befehls
# ist. Das eigene grep von "dod" faende in diesem geechoten, nie wirklich
# erzeugten Text eine scheinbar gueltige Marke -- ein falscher Gruenbericht
# durch Markenkollision im Rezeptabdruck, nicht durch real ausgeloeste
# Kettenschritte. Empirisch bestaetigt: mit woertlichem "$(MAKE)" im
# .ONESHELL-Rezept legt "make -n" auch harmlose, VOR dem $(MAKE)-Aufruf
# stehende Befehle real an (touch einer Testdatei); mit der eigenen Kopie
# MAKE_REKURSIV bleibt der gesamte Rezeptkoerper unter "-n" ein reiner
# Abdruck, es laeuft nichts real. Die Code-Aenderung (eigene Kopie statt
# "$(MAKE)") bleibt deshalb richtig -- nur die hier zuvor aufgeschriebene
# Begruendung war falsch.
#
# "override" zusaetzlich zu ":=": ohne "override" wuerde eine Befehlszeilen-
# Variable ("make MAKE_REKURSIV=... dod") diese Zuweisung schlagen und
# MAKE_REKURSIV auf einen beliebigen Nicht-Make-Befehl umbiegen koennen; die
# Schleife in "dod" wuerde dann augenscheinlich "erfolgreich" durchlaufen,
# ohne dass ein einziger Kettenschritt echt lief. "override" verhindert das.
override MAKE_REKURSIV := $(MAKE)

# Verzeichnis dieses Makefiles, unabhaengig vom Aufrufort. Noetig, damit
# "make -f /pfad/Makefile dod" aus einem FREMDEN Arbeitsverzeichnis nicht
# bei D1 abbricht: ohne "-C" sucht jeder Unter-Make-Aufruf im aktuellen
# Arbeitsverzeichnis nach einer Datei "Makefile"/"makefile" und findet dort
# keine, wenn dieses Verzeichnis nicht das Projektverzeichnis ist.
PROJ := $(dir $(abspath $(firstword $(MAKEFILE_LIST))))

# Zielkonflikt, absichtlich so geloest, nicht versehentlich: Ohne weitere
# Vorkehrung erzeugt "make -j4 dod" mehrere "jobserver unavailable"-
# Warnungen (je Unter-Make-Aufruf, weil MAKE_REKURSIV -- anders als ein
# woertliches, mit "+" praefigiertes "$(MAKE)" -- keinen Zugriff auf den
# Jobserver-Tokenpool des aeusseren Laufs bekommt). "+" als Rezeptpraefix
# WUERDE diesen Zugriff verschaffen, hebt aber genau die oben begruendete
# MAKE_REKURSIV-Vorkehrung wieder auf ("+" loest denselben "-n"-Sonderfall
# aus wie ein woertliches "$(MAKE)"). Deshalb hier bewusst KEIN "+": die
# Kette bleibt unter "-n" sicher, verzichtet dafuer unter "-j" auf
# Jobserver-Parallelitaet zwischen den Kettenschritten. Die Warnungen
# selbst werden im Aufruf in "dod" durch "-j1" (feste Seriellitaet je
# Unter-Make) und "env -u MAKEFLAGS" (keine geerbten Jobserver-Tokens im
# Kindprozess) unterdrueckt (beides empirisch geprueft).

# -----------------------------------------------------------------------------
# Schwellenwerte — NICHT ERFUNDEN. Siehe ADR 0002, Abschnitt 6 und Abschnitt 8
# (offener Punkt O-7), sowie docs/06_Definition_of_Ready_und_Done.md, Teil 2,
# "Offene Punkte".
# -----------------------------------------------------------------------------

# E-07 (D6, Testabdeckung): Vorschlag des Software Architects in ADR 0002,
# Abschnitt 6 — 80 Prozent Zeilenabdeckung, 100 Prozent fuer die Module, die
# Protokoll, Klassifizierung oder Freigabesperre umsetzen. UNBESTAETIGT durch
# Auftraggeber und SecDevOps (O-7). Ueberschreibbar auf der Befehlszeile,
# z. B.:
#   make abdeckung COV_FAIL_UNDER=70
# Bewusst ":=" statt "?=": Eine Befehlszeilen-Variable schlaegt in GNU Make
# ohnehin JEDE Makefile-Zuweisung, ":=" wie "?=" -- der dokumentierte
# Anwendungsfall oben bleibt also erhalten. "?=" liesse sich dagegen still
# ueber eine Umgebungsvariable absenken (z. B. "env COV_FAIL_UNDER=0 make
# abdeckung", ohne Sichtbarkeit auf der Befehlszeile). Betroffen waere die
# 100-Prozent-Schwelle fuer spur, zugriff und freigabe -- die drei Module,
# die CLAUDE.md unter "Nicht verhandelbar" fuehrt. Deshalb ":=".
COV_FAIL_UNDER := 80
COV_FAIL_UNDER_KRITISCH := 100
# Module aus ADR 0002, Abschnitt 4.1: spur (Protokoll), zugriff
# (Klassifizierung), freigabe (Freigabesperre).
KRITISCHE_MODULE := spur zugriff freigabe

# E-08 (D3, Linter-Warnungen; D8, Abhaengigkeitsschwachstellen): ADR 0002
# nennt fuer diese beiden Schwellen ausdruecklich KEINEN Zahlenwert, nur den
# Platzhalter "<Schwelle>" und den Vermerk "Schwelle offen, Entscheid E-08".
# Deshalb wird hier kein Wert erfunden; die Variablen bleiben leer. Solange
# sie leer sind, lassen D3 und D8 die zugehoerige Option beim Aufruf weg,
# statt eine unbestaetigte Zahl vorzutaeuschen, und melden das sichtbar.
# UNBESTAETIGT durch Auftraggeber und SecDevOps (O-7). Setzen mit z. B.:
#   make linter LINT_MAX_WARNINGS=0
#   make abhaengigkeiten AUDIT_LEVEL=high
LINT_MAX_WARNINGS ?=
AUDIT_LEVEL ?=

# -----------------------------------------------------------------------------
# Lage-Marke — aus Variablen zusammengesetzt, nicht als Literal im Quelltext.
# -----------------------------------------------------------------------------
# Frueher stand der vollstaendige Text "::LAGE ... ::" viermal woertlich im
# Quelltext von KLASSIFIZIEREN (einmal je Zweig). Ohne ".SILENT" echot GNU
# Make jede Rezeptzeile vor der Ausfuehrung; dadurch stand der Suchtext von
# "dod" (::LAGE...::) je Schritt fuenfmal im erfassten Text: viermal als
# Abdruck des Rezepts, einmal als echte Ausgabe -- "tail -n1" traf zwar in
# der Praxis meist die echte Zeile, war aber ein Zufallstreffer, kein
# belastbares Kriterium. ".SILENT" oben schaltet das Echo grundsaetzlich ab;
# zusaetzlich wird die Marke hier aus zwei Variablen und genau EINER
# Ausgabezeile je Aufruf zusammengesetzt, damit der Suchtext selbst bei
# einem spaeteren Wegfall von ".SILENT" nicht mehr woertlich im Quelltext
# steht.
#
# Einschleusungsschutz (Full-Review 2026-08-30, "Gering"-Befund): Ein
# aufgerufenes Skript kann in seiner eigenen Ausgabe eine markenfoermige
# Zeile hinterlassen -- absichtlich oder zufaellig (belegt:
# "echo 'Fundstelle: ::LAGE D9 rueckkanal A_OK::'" gefolgt von "kill -9").
# Die Kennung UND der Zielname allein reichen als Schutz nicht, weil beide
# aus dem Aufruf selbst ablesbar und nachahmbar sind. "dod" erzeugt deshalb
# je Lauf eine eigene, nicht vorhersagbare LAUF_KENNUNG (siehe dort) und
# reicht sie ausschliesslich ueber die Umgebung an den jeweiligen
# Unter-Make-Aufruf weiter; KLASSIFIZIEREN traegt sie in die Marke ein, "dod"
# akzeptiert nur eine Marke mit GENAU dieser Kennung. Eine Ausgabezeile, die
# nicht aus DIESEM Lauf stammt, kennt die Kennung nicht und wird nicht als
# Marke erkannt. Grenze der Massnahme, ehrlich benannt: Ein Werkzeug, das
# innerhalb desselben Laufs gezielt seine eigene Umgebung nach LAUF_KENNUNG
# durchsucht, koennte sie auslesen und eine Marke faelschen -- das ist eine
# Frage des Vertrauens in die aufgerufenen Werkzeuge (Lieferkette), nicht
# mehr eine Frage der Markenerkennung, und liegt bei SecDevOps, nicht bei
# diesem Makefile.
MARKE_PRAEFIX := ::LAGE
MARKE_SUFFIX := ::

# -----------------------------------------------------------------------------
# Gemeinsamer Abschluss eines Kettenschritts.
#
# Erwartet drei Shell-Variablen, die der Aufrufer vor dem Aufruf gesetzt hat:
#   hat_objekt      1, wenn es fuer diesen Schritt ueberhaupt etwas zu
#                   pruefen gibt (z. B. backend/ oder frontend/package.json
#                   vorhanden); sonst 0.
#   hat_lage_c      1, wenn ein benoetigtes Pruefmittel fehlt, obwohl es
#                   etwas zu pruefen gaebe; sonst 0. Hat Vorrang vor allem
#                   anderen — ein Rueckgabewert 0 waere sonst eine Luege.
#   fehlgeschlagen  1, wenn ein tatsaechlich gelaufenes Werkzeug einen Fehler
#                   gemeldet hat; sonst 0.
#
# $(1) = Kennung (z. B. D2), $(2) = Zielname (z. B. format-pruefen),
# $(3) = Begruendungstext fuer Lage B (ohne Komma, Komma trennt Call-
# Argumente), $(4) = optionaler Zusatz fuer die Marke selbst, z. B.
# "SCHWELLE=5" oder "OHNE_SCHWELLE" bei D3 (siehe dort) -- leer, wenn nicht
# uebergeben; andere Aufrufer lassen $(4) weg.
# -----------------------------------------------------------------------------
define KLASSIFIZIEREN
	if [ "$$hat_lage_c" -eq 1 ]; then
		lage="C"; marke_rc=1
	elif [ "$$hat_objekt" -eq 0 ]; then
		echo "[$(1) $(2)] Lage B -- nicht anwendbar: $(3)"
		lage="B"; marke_rc=0
	elif [ "$$fehlgeschlagen" -eq 1 ]; then
		echo "[$(1) $(2)] Lage A -- durchgefallen." >&2
		lage="A_FAIL"; marke_rc=1
	else
		echo "[$(1) $(2)] Lage A -- bestanden."
		lage="A_OK"; marke_rc=0
	fi
	echo "$(MARKE_PRAEFIX) $${LAUF_KENNUNG:-ohne-lauf-kennung} $(1) $(2) $${lage}$(if $(4), $(4))$(MARKE_SUFFIX)"
	exit $$marke_rc
endef

# =============================================================================
# D1 — Bau
# =============================================================================
# Objekt der Pruefung: backend/, frontend/package.json, deploy/compose.test.yml.
# Heute (2026-08-30): keiner der drei Teilbaeume existiert -> Lage B.
# Werkzeuge (uv, npm, docker) sind auf dieser Umgebung vorhanden; die
# Bedingungspruefung ist trotzdem zur Laufzeit da, weil das Makefile auch auf
# einem Rechner ohne diese Werkzeuge laufen muss. Fehlt ein Werkzeug, WAEHREND
# der zugehoerige Teilbaum existiert, ist das Lage C (etwas zu bauen, aber
# das Werkzeug fehlt) -- ausdruecklich auch fuer einen nicht erreichbaren
# Docker-Daemon bei vorhandenem deploy/compose.test.yml: das Programm ist da,
# der Dienst nicht, und "kein Fehler" waere hier falsch.
bau:
	set -uo pipefail
	cd "$(PROJ)" || { echo "[D1 bau] Kann nicht nach $(PROJ) wechseln." >&2; exit 1; }
	hat_objekt=0; hat_lage_c=0; fehlgeschlagen=0
	if [ -f backend/pyproject.toml ]; then
		hat_objekt=1
		echo "[D1 bau] backend/pyproject.toml vorhanden -- Backend wird gebaut."
		if ! command -v uv >/dev/null 2>&1; then
			echo "[D1 bau] LAGE C: backend/pyproject.toml existiert, aber 'uv' ist nicht installiert." >&2
			echo "Beschaffen: https://docs.astral.sh/uv/ (z. B. curl -LsSf https://astral.sh/uv/install.sh | sh)." >&2
			hat_lage_c=1
		else
			# A2, berichtigt (ADR 0002, Abschnitt 6.2.1, zweite Fortschreibung
			# 2026-08-30): erst "--frozen", dann in dieser Runde durch "--locked"
			# ersetzt. "--frozen" liess uv.lock zwar unangetastet, MELDETE eine
			# Abweichung zwischen pyproject.toml und uv.lock aber NICHT -- es
			# installierte und lief stumm gegen einen moeglicherweise veralteten
			# Stand (Verstoss gegen K4). "--locked" laesst die Sperrdatei ebenso
			# unangetastet UND endet ungleich 0 bei einer Abweichung. Gilt an
			# BEIDEN Aufrufen: "uv sync --project backend --locked" allein wuerde D1 selbst schuetzen,
			# aber ein nachfolgender "uv run" ohne eigenes "--locked" wuerde den
			# Sync-Zustand ein zweites Mal pruefen und koennte die versionierte
			# Sperrdatei still veraendern (Kettengrundsatz, ADR 0002, Abschnitt
			# 6.1.3/6.2.1) -- zusaetzlich beobachtet durch D19 (siehe "dod").
			#
			# "--project backend": ohne dieses Flag beim Testlauf entdeckt (siehe
			# Bericht der Arbeitseinheit): "cd $(PROJ)" oben setzt das Arbeits-
			# verzeichnis auf die Repository-Wurzel, nicht auf backend/. "uv" sucht
			# ein Projekt nur aufwaerts (in Vorfahren des Arbeitsverzeichnisses),
			# nie abwaerts -- ohne "--project backend" liefe jeder Aufruf "ausser-
			# halb eines Projekts" (uv meldet das als Warnung: "--locked has no
			# effect when used outside of a project") und "--locked" pruefte gar
			# nichts. "--project" AENDERT NICHT das Arbeitsverzeichnis (anders als
			# "--directory"), das Argument "backend/src" bleibt deshalb relativ zur
			# Repository-Wurzel gueltig, wie es die Tabelle in ADR 0002, Abschnitt
			# 6 woertlich vorgibt.
			uv sync --project backend --locked && uv run --project backend --locked python -m compileall -q backend/src || fehlgeschlagen=1
		fi
	fi
	if [ -f frontend/package.json ]; then
		hat_objekt=1
		echo "[D1 bau] frontend/package.json vorhanden -- Frontend wird gebaut."
		if ! command -v npm >/dev/null 2>&1 || ! command -v node >/dev/null 2>&1; then
			echo "[D1 bau] LAGE C: frontend/package.json existiert, aber 'npm' und/oder 'node' sind nicht installiert." >&2
			echo "Beschaffen: Node.js-Installation inklusive npm (https://nodejs.org)." >&2
			hat_lage_c=1
		else
			npm ci --prefix frontend && npm run build --prefix frontend || fehlgeschlagen=1
		fi
	fi
	if [ -f deploy/compose.test.yml ]; then
		hat_objekt=1
		echo "[D1 bau] deploy/compose.test.yml vorhanden -- Containerbau wird versucht."
		if ! command -v docker >/dev/null 2>&1; then
			echo "[D1 bau] LAGE C: deploy/compose.test.yml existiert, aber 'docker' ist nicht installiert." >&2
			echo "Beschaffen: Docker Engine (https://docs.docker.com/engine/install/)." >&2
			hat_lage_c=1
		elif ! docker info >/dev/null 2>&1; then
			echo "[D1 bau] LAGE C: deploy/compose.test.yml existiert, aber der Docker-Daemon ist nicht erreichbar." >&2
			echo "Docker-Dienst starten (z. B. sudo systemctl start docker, oder Docker Desktop starten)." >&2
			hat_lage_c=1
		else
			docker compose -f deploy/compose.test.yml build || fehlgeschlagen=1
		fi
	fi
	$(call KLASSIFIZIEREN,D1,bau,weder backend/pyproject.toml noch frontend/package.json noch deploy/compose.test.yml vorhanden. Nichts zu bauen.)

# =============================================================================
# D2 — Formatierung
# =============================================================================
# Objekt der Pruefung: Quellcode in backend/ und frontend/. Heute existiert
# keiner der beiden Baeume -> Lage B, wie im Auftrag als Beispiel benannt
# (ruff check backend ohne backend/). ruff und npm sind vorhanden; fehlten
# sie waehrend Code existiert, waere das Lage C (siehe uv/npm-Pruefung unten).
format-pruefen:
	set -uo pipefail
	cd "$(PROJ)" || { echo "[D2 format-pruefen] Kann nicht nach $(PROJ) wechseln." >&2; exit 1; }
	hat_objekt=0; hat_lage_c=0; fehlgeschlagen=0
	if [ -f backend/pyproject.toml ]; then
		hat_objekt=1
		if ! command -v uv >/dev/null 2>&1; then
			echo "[D2 format-pruefen] LAGE C: backend/pyproject.toml existiert, aber 'uv' fehlt." >&2
			hat_lage_c=1
		else
			uv run --project backend --locked ruff format --check backend || fehlgeschlagen=1
		fi
	fi
	if [ -f frontend/package.json ]; then
		hat_objekt=1
		if ! command -v npm >/dev/null 2>&1 || ! command -v node >/dev/null 2>&1; then
			echo "[D2 format-pruefen] LAGE C: frontend/package.json existiert, aber 'npm' und/oder 'node' fehlen." >&2
			hat_lage_c=1
		else
			# A5: Ein fehlendes npm-Skript ist Lage C (Pruefmittel fehlt bei
			# vorhandenem Gegenstand), nicht Lage A_FAIL (Pruefmittel lief und ist
			# durchgefallen). "npm run" allein kann das nicht unterscheiden -- ein
			# eigener Blick in package.json vorab schon.
			skript_pruefung=$$(npm pkg get scripts.format-pruefen --prefix frontend 2>/dev/null)
			if [ "$$skript_pruefung" = "{}" ]; then
				echo "[D2 format-pruefen] LAGE C: frontend/package.json existiert, aber das Skript 'format-pruefen' ist darin nicht definiert." >&2
				hat_lage_c=1
			else
				npm run format-pruefen --prefix frontend || fehlgeschlagen=1
			fi
		fi
	fi
	$(call KLASSIFIZIEREN,D2,format-pruefen,weder backend/pyproject.toml noch frontend/package.json vorhanden. Nichts zu formatieren.)

# =============================================================================
# D3 — Linter
# =============================================================================
# Objekt der Pruefung wie D2. Heute Lage B. LINT_MAX_WARNINGS ist Entscheid
# E-08 und unbestaetigt (siehe Variablenblock oben): ist sie leer, laeuft der
# Linter ohne erzwungene Schwelle und meldet das sichtbar, statt eine Zahl zu
# erfinden.
linter:
	set -uo pipefail
	cd "$(PROJ)" || { echo "[D3 linter] Kann nicht nach $(PROJ) wechseln." >&2; exit 1; }
	hat_objekt=0; hat_lage_c=0; fehlgeschlagen=0
	if [ -f backend/pyproject.toml ]; then
		hat_objekt=1
		if ! command -v uv >/dev/null 2>&1; then
			echo "[D3 linter] LAGE C: backend/pyproject.toml existiert, aber 'uv' fehlt." >&2
			hat_lage_c=1
		else
			uv run --project backend --locked ruff check backend || fehlgeschlagen=1
		fi
	fi
	if [ -f frontend/package.json ]; then
		hat_objekt=1
		if ! command -v npm >/dev/null 2>&1 || ! command -v node >/dev/null 2>&1; then
			echo "[D3 linter] LAGE C: frontend/package.json existiert, aber 'npm' und/oder 'node' fehlen." >&2
			hat_lage_c=1
		else
			# A5: fehlendes npm-Skript ist Lage C, siehe Begruendung bei D2.
			skript_pruefung=$$(npm pkg get scripts.linter --prefix frontend 2>/dev/null)
			if [ "$$skript_pruefung" = "{}" ]; then
				echo "[D3 linter] LAGE C: frontend/package.json existiert, aber das Skript 'linter' ist darin nicht definiert." >&2
				hat_lage_c=1
			elif [ -n "$(LINT_MAX_WARNINGS)" ]; then
				npm run linter --prefix frontend -- --max-warnings "$(LINT_MAX_WARNINGS)" || fehlgeschlagen=1
			else
				echo "[D3 linter] Hinweis: LINT_MAX_WARNINGS ist nicht gesetzt (E-08, unbestaetigt). Aufruf ohne Schwelle."
				npm run linter --prefix frontend || fehlgeschlagen=1
			fi
		fi
	fi
	# G2: Die Marke traegt jetzt den Vorbehalt (SCHWELLE=<Wert> bzw.
	# OHNE_SCHWELLE), nicht nur den Lage-Wert -- sonst ist "::LAGE D3 linter
	# A_OK::" identisch, ob mit oder ohne --max-warnings erzwungen wurde.
	# Schnittstelle zum spaeteren Hook aus R3-Q-001.
	$(call KLASSIFIZIEREN,D3,linter,weder backend/pyproject.toml noch frontend/package.json vorhanden. Nichts zu pruefen.,$(if $(LINT_MAX_WARNINGS),SCHWELLE=$(LINT_MAX_WARNINGS),OHNE_SCHWELLE))

# =============================================================================
# D4 — Typpruefung
# =============================================================================
# Objekt der Pruefung wie D2. Heute Lage B.
typen:
	set -uo pipefail
	cd "$(PROJ)" || { echo "[D4 typen] Kann nicht nach $(PROJ) wechseln." >&2; exit 1; }
	hat_objekt=0; hat_lage_c=0; fehlgeschlagen=0
	if [ -f backend/pyproject.toml ]; then
		hat_objekt=1
		if ! command -v uv >/dev/null 2>&1; then
			echo "[D4 typen] LAGE C: backend/pyproject.toml existiert, aber 'uv' fehlt." >&2
			hat_lage_c=1
		else
			uv run --project backend --locked mypy backend/src backend/tests || fehlgeschlagen=1
		fi
	fi
	if [ -f frontend/package.json ]; then
		hat_objekt=1
		if ! command -v npm >/dev/null 2>&1 || ! command -v node >/dev/null 2>&1; then
			echo "[D4 typen] LAGE C: frontend/package.json existiert, aber 'npm' und/oder 'node' fehlen." >&2
			hat_lage_c=1
		else
			# A5: fehlendes npm-Skript ist Lage C, siehe Begruendung bei D2.
			skript_pruefung=$$(npm pkg get scripts.typen --prefix frontend 2>/dev/null)
			if [ "$$skript_pruefung" = "{}" ]; then
				echo "[D4 typen] LAGE C: frontend/package.json existiert, aber das Skript 'typen' ist darin nicht definiert." >&2
				hat_lage_c=1
			else
				npm run typen --prefix frontend || fehlgeschlagen=1
			fi
		fi
	fi
	$(call KLASSIFIZIEREN,D4,typen,weder backend/pyproject.toml noch frontend/package.json vorhanden. Nichts zu typpruefen.)

# =============================================================================
# D18 — Architekturvertraege
# =============================================================================
# Kennung, keine Reihenfolge: D18 ist die naechste freie Nummer im
# gemeinsamen D-Namensraum (D13 bis D17 sind an die menschlich bestaetigten
# Bedingungen aus docs/06_Definition_of_Ready_und_Done.md, Teil 2, vergeben).
# Die AUSFUEHRUNGSREIHENFOLGE ist unten in "dod" festgelegt: nach D4, vor D5
# (ADR 0002, Abschnitt 6, D18, und Abschnitt 6.1.2, Punkt 3 -- ein Verstoss
# gegen eine Modulgrenze soll fallen, bevor die Testsuite laeuft, nicht
# danach).
#
# Objekt der Pruefung (ADR 0002, Abschnitt 6, Objekttabelle, Zeile D18):
# "Python-Produktionscode unterhalb backend/src/, unabhaengig davon, wie das
# Paket heisst" -- Erkennungsmerkmal ist EXPLIZIT "mindestens eine *.py-Datei
# unterhalb backend/src/", nicht ein Verzeichnis gleichen Namens und nicht
# der literale Name backend/src/r3cosint/ aus 4.1. Zwei fruehere Fassungen
# dieser Runde hatten das je verschieden gefasst (zuerst woertlich
# "-d backend/src/r3cosint" -- Befund A4 --, danach "irgendein Verzeichnis
# direkt unter backend/src/"): Beides war eine Umsetzungsentscheidung ueber
# eine Frage, die das ADR inzwischen selbst und einmalig beantwortet
# (Abschnitt 6.2.2, Regel 2: "Die Objektbedingung steht einmal"). Ein Paket
# unter z. B. backend/src/r3cosint_api/ ist damit sichtbar, obwohl es nicht
# so heisst, wie 4.1 es vorschreibt -- ein Verstoss gegen die Namensgebung
# muss D18 AUSLOESEN, nicht abschalten (6.2.2, "Weshalb die Sache und nicht
# der Paketname"). Fehlt bei vorhandener *.py-Datei die Datei
# backend/importvertraege.toml, oder ist sie nicht lesbar (A5 -- ein
# Berechtigungsfehler ist ein fehlendes Pruefmittel, keine durchgefallene
# Pruefung), ist das Lage C -- unabhaengig davon, ob 'uv' oder 'lint-imports'
# installiert waeren, denn das Pruefmittel des ADR ist die Vertragsdatei
# selbst, nicht nur das Werkzeug. Sind beide vorhanden, aber 'lint-imports'
# ueber 'uv' nicht aufloesbar, ist das ebenfalls Lage C, analog zur
# pip-audit-Behandlung in D8 oben.
#
# Anmerkung "Zu D18" (ADR 0002, Abschnitt 6): Die Vertragsdatei muss jedes
# oberste Paket unterhalb backend/src/ als Wurzelpaket nennen, sonst liefe
# der Pruefer an vorhandenem Produktionscode vorbei und meldete Lage A, ohne
# etwas beurteilt zu haben. Ob dieser Abgleich im Aufruf hier oder als
# Vertrag im Pruefer selbst sitzt, ist offen (DevOps Engineer entscheidet es;
# hier noch nicht umgesetzt, siehe Bericht).
architekturvertraege:
	set -uo pipefail
	cd "$(PROJ)" || { echo "[D18 architekturvertraege] Kann nicht nach $(PROJ) wechseln." >&2; exit 1; }
	hat_objekt=0; hat_lage_c=0; fehlgeschlagen=0
	backend_py_datei=""
	if [ -d backend/src ]; then
		backend_py_datei=$$(find backend/src -type f -name '*.py' -print -quit 2>/dev/null)
	fi
	if [ -n "$$backend_py_datei" ]; then
		hat_objekt=1
		if [ ! -f backend/importvertraege.toml ]; then
			echo "[D18 architekturvertraege] LAGE C: mindestens eine *.py-Datei unterhalb backend/src/ existiert (z. B. $$backend_py_datei), aber backend/importvertraege.toml fehlt." >&2
			echo "Das Pruefmittel fuer die Architekturvertraege aus ADR 0002 Abschnitt 4.3 fehlt bei vorhandenem Gegenstand (ADR 0002, Abschnitt 6, D18)." >&2
			hat_lage_c=1
		elif [ ! -r backend/importvertraege.toml ]; then
			# A5: nicht lesbar ist Lage C (Pruefmittel vorhanden, aber unbrauchbar),
			# nicht Lage A_FAIL -- sonst meldet ein Berechtigungsfehler faelschlich
			# eine durchgefallene Pruefung statt eines fehlenden Pruefmittels.
			echo "[D18 architekturvertraege] LAGE C: backend/importvertraege.toml existiert, ist aber nicht lesbar." >&2
			hat_lage_c=1
		elif ! command -v uv >/dev/null 2>&1; then
			echo "[D18 architekturvertraege] LAGE C: Python-Quelltext unterhalb backend/src/ und backend/importvertraege.toml existieren, aber 'uv' ist nicht installiert." >&2
			hat_lage_c=1
		elif ! uv run --project backend --locked lint-imports --version >/dev/null 2>&1; then
			echo "[D18 architekturvertraege] LAGE C: Python-Quelltext unterhalb backend/src/ und backend/importvertraege.toml existieren, aber 'lint-imports' ist nicht installiert (uv run lint-imports --version schlaegt fehl)." >&2
			echo "Beschaffen: import-linter als Abhaengigkeit von backend/ eintragen und 'uv sync' erneut ausfuehren." >&2
			hat_lage_c=1
		else
			uv run --project backend --locked lint-imports --config backend/importvertraege.toml || fehlgeschlagen=1
		fi
	fi
	$(call KLASSIFIZIEREN,D18,architekturvertraege,keine *.py-Datei unterhalb backend/src/ vorhanden. Es gibt keine Modulgrenzen die verletzt werden koennten.)

# =============================================================================
# D5 — Testsuite
# =============================================================================
# Objekt der Pruefung wie D2. Heute Lage B.
test:
	set -uo pipefail
	cd "$(PROJ)" || { echo "[D5 test] Kann nicht nach $(PROJ) wechseln." >&2; exit 1; }
	hat_objekt=0; hat_lage_c=0; fehlgeschlagen=0
	if [ -f backend/pyproject.toml ]; then
		hat_objekt=1
		if ! command -v uv >/dev/null 2>&1; then
			echo "[D5 test] LAGE C: backend/pyproject.toml existiert, aber 'uv' fehlt." >&2
			hat_lage_c=1
		else
			uv run --project backend --locked pytest -q --strict-markers || fehlgeschlagen=1
		fi
	fi
	if [ -f frontend/package.json ]; then
		hat_objekt=1
		if ! command -v npm >/dev/null 2>&1 || ! command -v node >/dev/null 2>&1; then
			echo "[D5 test] LAGE C: frontend/package.json existiert, aber 'npm' und/oder 'node' fehlen." >&2
			hat_lage_c=1
		else
			# A5: fehlendes npm-Skript ist Lage C, siehe Begruendung bei D2. Zwei
			# Skripte, zwei unabhaengige Pruefungen -- 'test' fehlend darf 'e2e'
			# nicht verdecken und umgekehrt.
			test_skript=$$(npm pkg get scripts.test --prefix frontend 2>/dev/null)
			if [ "$$test_skript" = "{}" ]; then
				echo "[D5 test] LAGE C: frontend/package.json existiert, aber das Skript 'test' ist darin nicht definiert." >&2
				hat_lage_c=1
			else
				npm run test --prefix frontend || fehlgeschlagen=1
			fi
			e2e_skript=$$(npm pkg get scripts.e2e --prefix frontend 2>/dev/null)
			if [ "$$e2e_skript" = "{}" ]; then
				echo "[D5 test] LAGE C: frontend/package.json existiert, aber das Skript 'e2e' ist darin nicht definiert." >&2
				hat_lage_c=1
			else
				npm run e2e --prefix frontend || fehlgeschlagen=1
			fi
		fi
	fi
	$(call KLASSIFIZIEREN,D5,test,weder backend/pyproject.toml noch frontend/package.json vorhanden. Nichts zu testen.)

# =============================================================================
# D6 — Testabdeckung
# =============================================================================
# Objekt der Pruefung: nur backend/ (ADR 0002 nennt fuer D6 ausschliesslich
# Backend-Befehle). Heute Lage B. Schwellen COV_FAIL_UNDER / _KRITISCH: E-07,
# unbestaetigt, siehe Variablenblock oben.
abdeckung:
	set -uo pipefail
	cd "$(PROJ)" || { echo "[D6 abdeckung] Kann nicht nach $(PROJ) wechseln." >&2; exit 1; }
	hat_objekt=0; hat_lage_c=0; fehlgeschlagen=0
	if [ -f backend/pyproject.toml ]; then
		hat_objekt=1
		if ! command -v uv >/dev/null 2>&1; then
			echo "[D6 abdeckung] LAGE C: backend/pyproject.toml existiert, aber 'uv' fehlt." >&2
			hat_lage_c=1
		elif ! uv run --project backend --locked python -c "import pytest_cov" >/dev/null 2>&1; then
			echo "[D6 abdeckung] LAGE C: backend/pyproject.toml existiert, aber 'pytest-cov' ist nicht installiert (uv run python -c 'import pytest_cov' schlaegt fehl)." >&2
			echo "Beschaffen: pytest-cov als Abhaengigkeit von backend/ eintragen und 'uv sync' erneut ausfuehren." >&2
			hat_lage_c=1
		else
			# E2 (zusaetzlich): COVERAGE_FILE zeigt auf eine Wegwerfdatei, damit
			# "make dod" keine ".coverage" im Arbeitsbaum hinterlaesst.
			covdatei=$$(mktemp)
			COVERAGE_FILE="$$covdatei" uv run --project backend --locked pytest --cov=backend/src/r3cosint --cov-fail-under=$(COV_FAIL_UNDER) || fehlgeschlagen=1
			kritische_flags=""
			for m in $(KRITISCHE_MODULE); do
				kritische_flags="$$kritische_flags --cov=backend/src/r3cosint/$$m"
			done
			COVERAGE_FILE="$$covdatei" uv run --project backend --locked pytest $$kritische_flags --cov-fail-under=$(COV_FAIL_UNDER_KRITISCH) || fehlgeschlagen=1
			rm -f "$$covdatei"
		fi
	fi
	# Gering-Befund: die Marke traegt jetzt den Schwellenvorbehalt wie D3,
	# nicht nur den Lage-Wert -- COV_FAIL_UNDER ist im Gegensatz zu
	# LINT_MAX_WARNINGS/AUDIT_LEVEL immer gesetzt (":=" mit festem
	# Startwert), deshalb kein OHNE_SCHWELLE-Zweig noetig.
	$(call KLASSIFIZIEREN,D6,abdeckung,kein backend/pyproject.toml vorhanden. Nichts zu messen.,SCHWELLE=$(COV_FAIL_UNDER)/$(COV_FAIL_UNDER_KRITISCH))

# =============================================================================
# D7 — Aufgabenspezifische Abnahmekriterien
# =============================================================================
# UEBERLEGUNG (verlangt vom Auftrag, keine Regel): Das Pruefmittel
# scripts/abnahme-abgleich.sh ist laut ADR 0002 "eigenes Projektartefakt,
# entsteht mit dem Grundgeruest" und fehlt vollstaendig. Trotzdem ist dies
# NICHT Lage B: Das Objekt der Pruefung ist nicht der Programmcode, sondern
# docs/05_Product_Backlog.md -- und dieses Dokument existiert bereits, mit
# realen Eintraegen und realen Abnahmekriterien, unabhaengig davon, ob
# backend/pyproject.toml existiert. Wuerde der Abgleich heute laufen, faende er fuer jedes
# Kriterium keinen Test (weil noch kein Code existiert) -- ein echtes,
# berechenbares Ergebnis, keine gegenstandslose Frage. "0" vorzutaeuschen
# waere deshalb eine Luege: Lage C.
abnahme:
	set -uo pipefail
	cd "$(PROJ)" || { echo "[D7 abnahme] Kann nicht nach $(PROJ) wechseln." >&2; exit 1; }
	hat_objekt=0; hat_lage_c=0; fehlgeschlagen=0
	if [ -f backend/pyproject.toml ]; then
		hat_objekt=1
		if ! command -v uv >/dev/null 2>&1; then
			echo "[D7 abnahme] LAGE C: backend/pyproject.toml existiert, aber 'uv' fehlt." >&2
			hat_lage_c=1
		else
			uv run --project backend --locked pytest -q -m abnahme || fehlgeschlagen=1
		fi
	fi
	# G1: fester Dateiname ersetzt durch Glob -- "docs/05_Product_Backlog.md"
	# allein uebersah z. B. eine Umbenennung nach "docs/05_Product_Backlog_v2.md"
	# und meldete danach faelschlich Lage B mit Rueckgabewert 0, obwohl der
	# Backlog nur umbenannt, nicht verschwunden war.
	backlog_datei=""
	if compgen -G "docs/05_Product_Backlog*.md" >/dev/null 2>&1; then
		backlog_datei=$$(compgen -G "docs/05_Product_Backlog*.md" | head -n1)
	fi
	if [ -n "$$backlog_datei" ]; then
		hat_objekt=1
		if [ -f scripts/abnahme-abgleich.sh ]; then
			bash scripts/abnahme-abgleich.sh || fehlgeschlagen=1
		else
			echo "[D7 abnahme] LAGE C: $$backlog_datei enthaelt bereits Abnahmekriterien, aber scripts/abnahme-abgleich.sh existiert nicht." >&2
			echo "Der Abgleich Backlog gegen Testkennungen (Projektauftrag 6.6) kann deshalb nicht laufen; 'bestanden' waere hier nicht belegt." >&2
			echo "Skript folgt mit dem Grundgeruest (ADR 0002, Abschnitt 5 und 6, D7)." >&2
			hat_lage_c=1
		fi
	fi
	$(call KLASSIFIZIEREN,D7,abnahme,weder backend/pyproject.toml noch docs/05_Product_Backlog*.md vorhanden. Nichts abzugleichen.)

# =============================================================================
# D8 — Abhaengigkeitspruefung
# =============================================================================
# Objekt der Pruefung: die Abhaengigkeiten von backend/ und frontend/. Heute
# existiert keiner der beiden Baeume -> nichts zu auditieren -> Lage B.
# AUDIT_LEVEL: E-08, unbestaetigt, siehe Variablenblock oben.
# Berichtigt (Full-Review 2026-08-30): Die fruehere Fassung dieses
# Kommentars behauptete, pip-audit muesse nicht separat auf Vorhandensein
# geprueft werden, weil "uv run" es aufloese. Das traegt empirisch nicht:
# "uv run pip-audit" schlaegt fehl, wenn pip-audit keine erklaerte
# Abhaengigkeit von backend/ ist -- der Fehlschlag sieht dann wie A_FAIL
# (durchgefallene Pruefung) aus, obwohl in Wahrheit das Pruefmittel fehlt
# (Lage C). Deshalb unten ein eigener Test auf "uv run pip-audit --version",
# analog zur gitleaks-Behandlung in D11.
abhaengigkeiten:
	set -uo pipefail
	cd "$(PROJ)" || { echo "[D8 abhaengigkeiten] Kann nicht nach $(PROJ) wechseln." >&2; exit 1; }
	hat_objekt=0; hat_lage_c=0; fehlgeschlagen=0
	if [ -f backend/pyproject.toml ]; then
		hat_objekt=1
		if ! command -v uv >/dev/null 2>&1; then
			echo "[D8 abhaengigkeiten] LAGE C: backend/pyproject.toml existiert, aber 'uv' fehlt." >&2
			hat_lage_c=1
		elif ! uv run --project backend --locked pip-audit --version >/dev/null 2>&1; then
			echo "[D8 abhaengigkeiten] LAGE C: backend/pyproject.toml existiert, aber 'pip-audit' ist nicht installiert (uv run pip-audit --version schlaegt fehl)." >&2
			echo "Beschaffen: pip-audit als Abhaengigkeit von backend/ eintragen und 'uv sync' erneut ausfuehren." >&2
			hat_lage_c=1
		else
			uv run --project backend --locked pip-audit --strict || fehlgeschlagen=1
		fi
	fi
	if [ -f frontend/package.json ]; then
		hat_objekt=1
		if ! command -v npm >/dev/null 2>&1 || ! command -v node >/dev/null 2>&1; then
			echo "[D8 abhaengigkeiten] LAGE C: frontend/package.json existiert, aber 'npm' und/oder 'node' fehlen." >&2
			hat_lage_c=1
		else
			if [ -n "$(AUDIT_LEVEL)" ]; then
				npm audit --prefix frontend --audit-level "$(AUDIT_LEVEL)" || fehlgeschlagen=1
			else
				echo "[D8 abhaengigkeiten] Hinweis: AUDIT_LEVEL ist nicht gesetzt (E-08, unbestaetigt). Aufruf ohne Schwelle."
				npm audit --prefix frontend || fehlgeschlagen=1
			fi
		fi
	fi
	if [ "$$hat_objekt" -eq 1 ]; then
		echo "[D8 abhaengigkeiten] Hinweis: Offline setzt eine gespiegelte Schwachstellendatenbank voraus (ADR 0002, Abschnitt 6, D8)."
	fi
	# Gering-Befund: die Marke traegt jetzt den Schwellenvorbehalt wie D3.
	$(call KLASSIFIZIEREN,D8,abhaengigkeiten,weder backend/pyproject.toml noch frontend/package.json vorhanden. Nichts zu pruefen.,$(if $(AUDIT_LEVEL),SCHWELLE=$(AUDIT_LEVEL),OHNE_SCHWELLE))

# =============================================================================
# D9 — Kein Rueckkanal
# =============================================================================
# Zweite Fortschreibung von ADR 0002 vom 2026-08-30, Abschnitt 6, Objekttabelle:
# Gegenstand ist "Quelltext und Betriebskonfiguration, die eine ausgehende
# Verbindung oeffnen koennten", Erkennungsmerkmal ist EXPLIZIT "mindestens
# eine Datei unterhalb backend/, frontend/ oder deploy/" -- ein bewusst
# benannter, ABGESCHLOSSENER Dreiersatz, keine generische "Produktionscode
# irgendwo"-Suche. Eine fruehere Fassung dieser Runde hatte D9 auf einen
# selbst erfundenen, generischen Mechanismus umgestellt (PRODUKTIONSCODE_
# ERKENNEN) und dabei woertlich behauptet, "Objekt der Pruefung ist deshalb
# jetzt konsistent zu D10" -- diese Behauptung war zu dem Zeitpunkt falsch
# (D10 kannte deploy/ damals nicht, Befund A1, blockierend) und ist mit der
# zweiten ADR-Fortschreibung ohnehin ueberholt: Der generische Mechanismus
# ist entfernt (Regel 2 der Objekttabelle: "Die Objektbedingung steht einmal
# [im ADR]"). D9 prueft jetzt genau die drei benannten Baeume, nicht mehr und
# nicht weniger -- "mindestens eine Datei", nicht nur ein leeres Verzeichnis.
rueckkanal:
	set -uo pipefail
	cd "$(PROJ)" || { echo "[D9 rueckkanal] Kann nicht nach $(PROJ) wechseln." >&2; exit 1; }
	hat_objekt=0; hat_lage_c=0; fehlgeschlagen=0
	rueckkanal_baeume=""
	for baum in backend frontend deploy; do
		if [ -d "$$baum" ]; then
			erste_datei=$$(find "$$baum" -type f -print -quit 2>/dev/null)
			if [ -n "$$erste_datei" ]; then
				hat_objekt=1
				rueckkanal_baeume="$$rueckkanal_baeume $$baum"
			fi
		fi
	done
	if [ "$$hat_objekt" -eq 1 ]; then
		if [ -f scripts/rueckkanal-pruefen.sh ]; then
			bash scripts/rueckkanal-pruefen.sh || fehlgeschlagen=1
		else
			echo "[D9 rueckkanal] LAGE C: Es existiert mindestens eine Datei unterhalb:$$rueckkanal_baeume, aber scripts/rueckkanal-pruefen.sh fehlt." >&2
			echo "Der Abgleich aller Ziele gegen die Positivliste (R3-C-004) kann deshalb nicht laufen." >&2
			echo "Skript folgt mit R3-C-004 (ADR 0002, Abschnitt 5 und 6, D9)." >&2
			hat_lage_c=1
		fi
	fi
	$(call KLASSIFIZIEREN,D9,rueckkanal,weder backend/ noch frontend/ noch deploy/ enthaelt eine Datei. Ohne Quelltext und Betriebskonfiguration gibt es keinen moeglichen Rueckkanal.)

# =============================================================================
# D10 — Prototyp-Trennung
# =============================================================================
# Zweite Fortschreibung von ADR 0002 vom 2026-08-30, Abschnitt 6, Objekttabelle
# und Abschnitt 6.2.2 ("Weshalb D10 immer laeuft"): Gegenstand ist "die
# Trennung zwischen prototype/ und dem Produktionscode, in beide Richtungen",
# Erkennungsmerkmal ist "prototype/ vorhanden" -- NICHT "existiert
# Produktionscode". Eine fruehere Fassung dieser Runde (Befund A1,
# BLOCKIEREND) pruefte woertlich "-d backend || -d frontend" -- OHNE deploy/:
# ein belegter Angriff (deploy/images/Dockerfile mit woertlich "COPY
# prototype/ /app/prototype/") blieb unerkannt, D10 meldete Lage B mit
# Rueckgabewert 0, und "make dod" endete gruen. Die naechste Fassung stellte
# darauf auf einen selbst erfundenen, generischen Mechanismus um
# (PRODUKTIONSCODE_ERKENNEN). Beides war eine Umsetzungsentscheidung ueber
# eine Frage, die dem ADR zusteht (Regel 3 der Objekttabelle: "Eine Bedingung
# wird nicht in der Umsetzung erfunden. Nennt die Tabelle fuer einen Schritt
# keine Lage B, gibt es fuer ihn keine: Er laeuft immer"). Die Tabelle nennt
# jetzt "prototype/ vorhanden" als Merkmal; da prototype/ nach 5.6 dauerhaft
# besteht, LAEUFT DER SCHRITT PRAKTISCH IMMER -- Lage B tritt nicht ein.
# prototype/OSINT_Plattform_Demo.html ist eine eigenstaendige HTML-Datei ohne
# Importe (geprueft am 2026-08-25); das aendert an der Objektbedingung nichts,
# weil der Gegenstand die TRENNUNG ist, nicht der Inhalt von prototype/
# selbst -- eine Stapelpruefung urteilt ueber den Bestand.
prototyp-trennung:
	set -uo pipefail
	cd "$(PROJ)" || { echo "[D10 prototyp-trennung] Kann nicht nach $(PROJ) wechseln." >&2; exit 1; }
	hat_objekt=0; hat_lage_c=0; fehlgeschlagen=0
	if [ -d prototype ]; then
		hat_objekt=1
	fi
	if [ "$$hat_objekt" -eq 1 ]; then
		if [ -f scripts/prototyp-trennung-pruefen.sh ]; then
			bash scripts/prototyp-trennung-pruefen.sh || fehlgeschlagen=1
		else
			echo "[D10 prototyp-trennung] LAGE C: prototype/ existiert, aber scripts/prototyp-trennung-pruefen.sh fehlt." >&2
			echo "Der bestehende Hook block-prototype-import.sh deckt nur den Schreibweg ab (PreToolUse), nicht den bereits geschriebenen Bestand." >&2
			echo "Betriebsart und Form sind mit DevOps und Protocol Master zu klaeren (ADR 0002, Abschnitt 8, O-8)." >&2
			hat_lage_c=1
		fi
	fi
	$(call KLASSIFIZIEREN,D10,prototyp-trennung,prototype/ fehlt -- tritt nach 5.6 nicht ein. Ohne prototype/ gibt es keine Trennung zu pruefen.)

# =============================================================================
# D11 — Geheimnisse
# =============================================================================
# Objekt der Pruefung: das Repository selbst -- immer vorhanden, unabhaengig
# von backend/frontend/deploy. gitleaks fehlt auf dieser Umgebung (geprueft
# am 2026-08-30). Das Repository koennte bereits heute Geheimnisse enthalten
# (z. B. versehentlich eingecheckte Zugangsdaten); "keine Beanstandung" waere
# deshalb eine Luege -> Lage C. Das ist der im Auftrag genannte Referenzfall
# fuer Lage C.
#
# Zwei Laeufe, beide zwingend, ADR 0002 Abschnitt 6.1.1 (Fortschreibung vom
# 2026-08-30): "gitleaks detect" OHNE "--no-git" durchsucht ausschliesslich
# die COMMITTETE Historie, nicht den Arbeitsbaum -- ein Geheimnis in einer
# noch nicht committeten Aenderung fiel durch die fruehere Fassung dieses
# Ziels durch. Belegter Lauf mit gitleaks 8.21.2 (ADR 0002, ebd.): ein nicht
# committeter RSA-Schluessel im Arbeitsbaum wurde von "gitleaks detect
# --redact --exit-code 1" NICHT gefunden, von "gitleaks detect --no-git
# --redact --exit-code 1 --source ." dagegen schon. Der Hook aus R3-Q-001
# laeuft als Stop/SubagentStop, also VOR dem Commit; der Arbeitsbaum ist
# damit der Gegenstand, auf den es ankommt. Der Historienlauf faellt trotzdem
# nicht weg -- er ist der einzige, der einen Fund aus einem frueheren Commit
# meldet. Reihenfolge Arbeitsbaum zuerst (der vor dem Commit noch abwendbare
# Befund steht zuoberst), aber KEIN Lauf schneidet den anderen ab: beide
# laufen immer, beide Befunde erscheinen, der Schritt endet ungleich 0,
# sobald einer der beiden ungleich 0 endet.
geheimnisse:
	set -uo pipefail
	cd "$(PROJ)" || { echo "[D11 geheimnisse] Kann nicht nach $(PROJ) wechseln." >&2; exit 1; }
	hat_objekt=1; hat_lage_c=0; fehlgeschlagen=0
	if ! command -v gitleaks >/dev/null 2>&1 || ! command -v git >/dev/null 2>&1; then
		echo "[D11 geheimnisse] LAGE C: 'gitleaks' und/oder 'git' sind nicht installiert. Das Repository existiert bereits und koennte Geheimnisse enthalten." >&2
		echo "Beschaffen: https://github.com/gitleaks/gitleaks (Release-Binary oder Paketmanager, z. B. 'brew install gitleaks') sowie git." >&2
		hat_lage_c=1
	else
		echo "[D11 geheimnisse] Lauf 1/2 -- Arbeitsbaum (gitleaks detect --no-git):"
		gitleaks detect --no-git --redact --exit-code 1 --source . || fehlgeschlagen=1
		echo "[D11 geheimnisse] Lauf 2/2 -- Git-Historie (gitleaks detect):"
		gitleaks detect --redact --exit-code 1 || fehlgeschlagen=1
	fi
	$(call KLASSIFIZIEREN,D11,geheimnisse,entfaellt -- das Repository existiert immer.)

# =============================================================================
# D12 — Nachweise
# =============================================================================
# UEBERLEGUNG: Zwei Teilschritte, unterschiedlicher Bestand. Objekt der
# Pruefung ist die Artefaktliste des Erzeugers (siehe scripts/nachweise-
# erzeugen.sh) -- bereits heute real und umfangreich (Dokumentation,
# Rollendateien, Hooks, Regeln), unabhaengig von backend/frontend.
# scripts/nachweise-erzeugen.sh EXISTIERT bereits und wird deshalb echt
# aufgerufen (die "Haelfte seines Pruefmittels", wie im Auftrag benannt).
# scripts/nachweise-vollstaendig.sh fehlt dagegen vollstaendig; sein Zweck
# (kein nachweispflichtiges Artefakt fehlt in der Liste) ist eine reale,
# nicht triviale Frage am bestehenden Bestand. "0" vorzutaeuschen waere eine
# Luege -> Lage C, unabhaengig von backend/frontend/deploy.
# E2: "make dod" darf als spaeterer Stop-Hook (R3-Q-001) nicht selbst
# ungefragt eine versionierte Datei aendern -- sonst erzeugt jeder Stopp
# eine Aenderung an docs/NACHWEISE.md, die niemand angefordert hat.
# scripts/nachweise-erzeugen.sh nimmt laut eigenem Kopf ein Ausgabeargument
# entgegen (geprueft); dieses Ziel nutzt es und schreibt in eine
# Wegwerfdatei. Der Zweck von D12 -- der Rueckgabewert des Erzeugers wird
# geprueft -- bleibt erfuellt, die Kette bleibt lesend.
nachweise:
	set -uo pipefail
	cd "$(PROJ)" || { echo "[D12 nachweise] Kann nicht nach $(PROJ) wechseln." >&2; exit 1; }
	hat_objekt=1; hat_lage_c=0; fehlgeschlagen=0
	if ! command -v git >/dev/null 2>&1; then
		echo "[D12 nachweise] LAGE C: 'git' ist nicht installiert; scripts/nachweise-erzeugen.sh braucht git (Commit-Pruefsummen je Artefakt)." >&2
		hat_lage_c=1
	elif [ -f scripts/nachweise-erzeugen.sh ]; then
		nachweis_tmp=$$(mktemp)
		bash scripts/nachweise-erzeugen.sh "$$nachweis_tmp" || fehlgeschlagen=1
		rm -f "$$nachweis_tmp"
	else
		echo "[D12 nachweise] LAGE C: scripts/nachweise-erzeugen.sh fehlt." >&2
		hat_lage_c=1
	fi
	if [ -f scripts/nachweise-vollstaendig.sh ]; then
		bash scripts/nachweise-vollstaendig.sh || fehlgeschlagen=1
	else
		echo "[D12 nachweise] LAGE C: scripts/nachweise-vollstaendig.sh fehlt. docs/NACHWEISE.md wird zwar erzeugt, aber dass kein nachweispflichtiges Artefakt in der Liste fehlt, ist damit nicht belegt." >&2
		echo "Skript folgt mit dem Grundgeruest (ADR 0002, Abschnitt 6, D12; zu klaeren mit Protocol Master und DevOps, Abschnitt 9)." >&2
		hat_lage_c=1
	fi
	$(call KLASSIFIZIEREN,D12,nachweise,entfaellt -- docs/ existiert immer.)

# =============================================================================
# dod — Ein Einstieg fuer den Hook (ADR 0002, Abschnitt 6)
# =============================================================================
# Ruft alle Kettenschritte dieser Datei in der festgelegten Reihenfolge auf
# und endet bei der ersten Abweichung ungleich 0. Gibt am Ende eine
# Uebersicht aus, die je gelaufenem Schritt zeigt, in welcher der drei Lagen
# er war -- das ist der eigentliche Wert fuer den spaeteren Hook aus
# R3-Q-001.
#
# Reihenfolge (ADR 0002, Abschnitt 6, "Ein Einstieg fuer den Hook",
# Fortschreibung vom 2026-08-30): D1 bis D4, dann D18, dann D5 bis D12. Bis
# zur Fortschreibung war die Aufzaehlung "D1 bis D12" zugleich die
# Reihenfolge; mit D18 gilt das nicht mehr (ADR 0002, Abschnitt 6.1.2: die
# Nummer eines Kettenschritts ist eine Kennung, keine Reihenfolge). Die
# tatsaechliche Reihenfolge steht ausschliesslich in "schritte_liste" unten
# -- an genau EINER Stelle, nicht zusaetzlich hier als Aufzaehlung, die bei
# der naechsten Fortschreibung erneut veralten koennte.
#
# Zwei Kriterien entscheiden je Schritt, nicht nur eines:
#   1. Der Unterschritt selbst endet mit Rueckgabewert 0.
#   2. Der Unterschritt hat eine EIGENE, zum erwarteten Schritt passende
#      Lage-Marke ausgegeben (Kennung UND Zielname stimmen), und diese
#      Marke endet weder auf "C" noch auf "A_FAIL".
# Fehlt eines der beiden, ist der Gesamtlauf ungleich 0. Das faengt: eine
# Marke, die C oder A_FAIL zeigt, obwohl der Unter-Make-Aufruf selbst 0
# zurueckgibt (moeglich unter -i/--ignore-errors, siehe die MAKEFLAGS-Wache
# unten); eine leere oder falsch zugeordnete Marke, z. B. weil MAKE_REKURSIV
# ueber die Befehlszeile auf einen Nicht-Make-Befehl umgebogen wurde
# (zusaetzlich durch "override" bei der Definition von MAKE_REKURSIV oben
# verhindert).
#
# Berichtigt (Full-Review 2026-08-30, "Gering"-Befund): Die fruehere Fassung
# dieses Absatzes behauptete, die beiden Kriterien seien UNABHAENGIG und
# Kriterium 2 fange insbesondere "einen hart abgebrochenen ('Killed')
# Schritt, der nie bis zur eigenen Marke kam". Belegter Gegenbeleg: ein
# Skript, das zuerst "echo 'Fundstelle: ::LAGE D9 rueckkanal A_OK::'"
# ausgibt und sich dann selbst mit "kill -9" beendet, erzeugt eine Zeile, die
# Kriterium 2 als GUELTIGE Marke akzeptiert (Kennung und Zielname passen).
# Der Gesamtlauf blieb in diesem Fall zwar rot -- aber NUR wegen Kriterium 1
# (der Unter-Make-Aufruf liefert bei einem getoeteten Prozess einen
# Rueckgabewert ungleich 0), nicht wegen Kriterium 2. Die beiden Kriterien
# waren an dieser Stelle also NICHT unabhaengig: Kriterium 2 liess sich durch
# reinen Text in der Ausgabe des gepruepften Werkzeugs taeuschen. Die
# Behebung ist LAUF_KENNUNG (siehe MARKE_PRAEFIX weiter oben): eine je Aufruf
# von "dod" neu erzeugte, nicht vorhersagbare Kennung, die "dod" nur ueber
# die Umgebung an den jeweiligen Unter-Make-Aufruf weiterreicht und
# ausschliesslich als Teil EINER GUELTIGEN Marke akzeptiert. Ein Werkzeug,
# das nicht gezielt seine eigene Prozessumgebung nach LAUF_KENNUNG
# durchsucht, kann diese Kennung nicht erraten. Grenze ehrlich benannt: ein
# Werkzeug, das die eigene Umgebung gezielt ausliest, koennte die Marke
# weiterhin faelschen -- das ist eine Frage der Lieferkette (SecDevOps),
# keine, die eine Markenpruefung im Makefile loesen kann.
#
# Erwartete Kettenschritte (Befund A3, mehrfach berichtigt): eine
# EIGENSTAENDIGE, im Makefile ausgeschriebene Liste (ERWARTETE_KETTENSCHRITTE
# unten) -- NICHT aus "schritte_liste" abgeleitet. Zwei fruehere Fassungen
# leiteten die erwartete Anzahl per "wc -w" AUS "schritte_liste" SELBST ab.
# Das ist eine Tautologie: Soll und Ist kamen aus derselben Zeile. Belegt:
# eine auf zwei Eintraege gekuerzte "schritte_liste" bestand die eigene
# Pruefung mit "alle 2 Kettenschritte durchlaufen". "dod" prueft jetzt VOR
# dem Lauf, dass "schritte_liste" die Kennungen aus ERWARTETE_KETTENSCHRITTE
# je genau einmal enthaelt -- weder weniger noch mehr -- und zaehlt am Ende
# gegen dieselbe, unabhaengige Liste.
#
# MAKEFLAGS-Wache (-i/--ignore-errors): GNU Make setzt bei -i/--ignore-
# errors den eigenen Rueckgabewert IMMER auf 0 -- unabhaengig davon, was
# das Rezept selbst tut oder mit "exit" zurueckgibt (empirisch geprueft mit
# GNU Make 4.3: ein Rezept mit "exit 5" liefert unter "make -i" den
# Rueckgabewert 0 an die aufrufende Shell). Ein "exit" im eigenen Rezept von
# "dod" kann das deshalb NICHT mehr korrigieren, sobald -i aktiv ist -- das
# muss VOR jeder Rezeptausfuehrung geschehen, als eigener Make-Fehler ueber
# "$(error ...)", der von -i nachweislich NICHT unterdrueckt wird (gleiche
# Pruefung). Die Wache wertet nur den Buchstaben-Cluster am Kopf von
# $(MAKEFLAGS) aus -- die zusammengezogenen Kurzoptionen ohne Bindestrich;
# Optionen mit eigenem Wert wie "-j4" stehen in eigenen, bindestrich-
# praefigierten Feldern und werden dadurch nicht faelschlich erfasst.
# "--ignore-errors" normalisiert sich in MAKEFLAGS auf dasselbe "i" wie
# "-i" (empirisch geprueft) und wird von derselben Wache erfasst.
#
# Rueckgabewert bei normalem Aufruf ohne "-q" (Berichtigung, G6: die
# fruehere Fassung dieses Kommentars behauptete das uneingeschraenkt):
# GNU Make bildet bei jedem gescheiterten Rezept, unabhaengig vom internen
# exit-Wert des Rezepts, selbst den Rueckgabewert 2 ("make: *** [...] Error
# N"). "make dod" liefert bei NORMALEM Aufruf deshalb ausschliesslich 0
# (alle Kettenschritte ohne Abweichung, alle Marken gueltig, D19 ohne Befund)
# oder 2 (Abbruch). Bei anderer Aufrufart weicht das ab -- empirisch
# geprueft: "make -q dod" (nur pruefen, ob etwas zu tun waere) liefert 1, ein
# fehlendes "make"-Programm liefert 127 vom Betriebssystem. Der spaetere
# Hook aus R3-Q-001 ruft "make dod" normal auf, nicht mit "-q".
#
# -----------------------------------------------------------------------------
# D19 — Unveraendertheit des Arbeitsbaums (Rahmenpruefung von "make dod")
# -----------------------------------------------------------------------------
# ADR 0002, Abschnitt 6, zweite Fortschreibung vom 2026-08-30. D19 ist KEIN
# Kettenschritt in der Zielliste, sondern eine Eigenschaft von "make dod": ein
# Schritt in der Liste saehe nur seinen eigenen Augenblick, der Grundsatz gilt
# aber fuer den ganzen Lauf. D19 klammert den Lauf ein, statt in ihm zu
# stehen, und hat deshalb auch KEIN eigenes "make"-Ziel.
#   Mittel:    "git status --porcelain" unmittelbar vor dem ersten und
#              unmittelbar nach dem letzten AUSGEFUEHRTEN Kettenschritt;
#              verglichen wird die vollstaendige Ausgabe zeilenweise,
#              einschliesslich der unverfolgten Eintraege ("??").
#   Massstab:  Vorher gegen Nachher, NICHT gegen einen sauberen Arbeitsbaum
#              -- die Kette laeuft vor dem Commit und trifft regelmaessig
#              einen veraenderten Arbeitsbaum an; das ist zulaessig, ihn zu
#              VERAENDERN ist es nicht.
#   Ausgang:   Bei Abweichung endet "make dod" ungleich 0 und nennt die
#              abweichenden Zeilen. Der Befund kann einen gruenen Lauf rot
#              machen, nie einen roten gruen (siehe unten: gesamt_rc wird nur
#              von 0 auf ungleich 0 gehoben, nie umgekehrt).
#   Auch bei Abbruch: die Nachher-Aufnahme laeuft auch dann, wenn die Kette
#              an einem Schritt vorher abgebrochen ist -- sonst bliebe genau
#              der Schritt unbeobachtet, der schreibt und zugleich scheitert.
#   Lage B:    kein .git/ vorhanden -- der Kettengrundsatz kann an einem
#              nicht versionierten Bestand nicht beobachtet werden, das ist
#              kein Fehler des Bestands.
#   Lage C:    .git/ vorhanden, aber 'git' nicht installiert -- das
#              Pruefmittel fehlt bei vorhandenem Gegenstand, kein stilles
#              Durchwinken.
# -----------------------------------------------------------------------------

# ERWARTETE_KETTENSCHRITTE — eigenstaendige, im Makefile ausgeschriebene
# Liste, siehe Befund A3 oben. Aenderung nur zusammen mit der Reihe in ADR
# 0002, Abschnitt 6, und mit "schritte_liste" im Rezept von "dod".
ERWARTETE_KETTENSCHRITTE := D1 D2 D3 D4 D18 D5 D6 D7 D8 D9 D10 D11 D12

DOD_MAKEFLAGS_ERSTES_WORT := $(firstword $(MAKEFLAGS))
dod:
ifneq ($(filter -%,$(DOD_MAKEFLAGS_ERSTES_WORT)),$(DOD_MAKEFLAGS_ERSTES_WORT))
ifneq ($(findstring i,$(DOD_MAKEFLAGS_ERSTES_WORT)),)
	$(error make dod: MAKEFLAGS enthaelt -i/--ignore-errors. Damit wuerde jeder Kettenschritt als Erfolg erscheinen, unabhaengig vom echten Ergebnis -- fuer eine Definition-of-Done-Kette unzulaessig. Ohne -i/--ignore-errors erneut aufrufen)
endif
endif
	set -uo pipefail
	# D19, Teil 1: Gegenstand und Pruefmittel feststellen, BEVOR irgendein
	# Kettenschritt laeuft ("vor dem ersten ausgefuehrten Schritt").
	d19_hat_repo=0
	d19_werkzeug_fehlt=0
	if [ -d "$(PROJ).git" ]; then
		d19_hat_repo=1
		if command -v git >/dev/null 2>&1; then
			d19_status_vorher=$$(git -C $(PROJ) status --porcelain)
		else
			d19_werkzeug_fehlt=1
			d19_status_vorher=""
		fi
	fi
	# LAUF_KENNUNG: siehe Begruendung beim MARKE_PRAEFIX-Block weiter oben.
	# PID + zwei $RANDOM + Nanosekunden -- ausreichend, um eine Ausgabezeile
	# aus einem FRUEHEREN oder FREMDEN Lauf sowie eine Zeile, die die
	# Kennung nicht kennt, von einer echten Marke DIESES Laufs zu
	# unterscheiden. Kein kryptographisches Geheimnis (siehe Grenze oben).
	lauf_kennung="$$$$-$${RANDOM}$${RANDOM}-$$(date +%s%N 2>/dev/null || date +%s)"
	schritte_liste="D1:bau D2:format-pruefen D3:linter D4:typen D18:architekturvertraege D5:test D6:abdeckung D7:abnahme D8:abhaengigkeiten D9:rueckkanal D10:prototyp-trennung D11:geheimnisse D12:nachweise"
	# A3, Teil 1: schritte_liste gegen die EIGENSTAENDIGE Liste
	# ERWARTETE_KETTENSCHRITTE pruefen, BEVOR ueberhaupt ein Kettenschritt
	# laeuft -- jede erwartete Kennung muss genau einmal vorkommen, keine
	# unerwartete Kennung darf vorkommen.
	for erwartete_kennung in $(ERWARTETE_KETTENSCHRITTE); do
		treffer=0
		for eintrag in $$schritte_liste; do
			if [ "$${eintrag%%:*}" = "$$erwartete_kennung" ]; then
				treffer=$$((treffer + 1))
			fi
		done
		if [ "$$treffer" -ne 1 ]; then
			echo "make dod: Kettenschritt $$erwartete_kennung kommt in der Zielliste $$treffer mal vor (erwartet: genau 1). Die Zielliste weicht von ERWARTETE_KETTENSCHRITTE ab." >&2
			exit 2
		fi
	done
	for eintrag in $$schritte_liste; do
		kennung_probe="$${eintrag%%:*}"
		bekannt=0
		for erwartete_kennung in $(ERWARTETE_KETTENSCHRITTE); do
			[ "$$kennung_probe" = "$$erwartete_kennung" ] && bekannt=1 && break
		done
		if [ "$$bekannt" -eq 0 ]; then
			echo "make dod: Zielliste enthaelt die unerwartete Kennung $$kennung_probe, die nicht in ERWARTETE_KETTENSCHRITTE steht." >&2
			exit 2
		fi
	done
	# A3, Teil 2: erwartete_marken kommt aus derselben eigenstaendigen Liste,
	# nicht aus schritte_liste (das war die Tautologie).
	erwartete_marken=$(words $(ERWARTETE_KETTENSCHRITTE))
	zusammenfassung=""
	gesamt_rc=0
	marken_zaehler=0
	letzter_schritt=""
	for eintrag in $$schritte_liste; do
		kennung="$${eintrag%%:*}"
		ziel="$${eintrag#*:}"
		letzter_schritt="$$kennung $$ziel"
		# G4: -C $(PROJ) haengt den Unter-Make-Aufruf nicht vom Aufrufort ab.
		# G5: -j1 und "env -u MAKEFLAGS" unterdruecken Jobserver-Warnungen bei
		# "make -j4 dod", ohne "+" als Rezeptpraefix zu benutzen (Zielkonflikt-
		# Kommentar bei MAKE_REKURSIV oben). LAUF_KENNUNG wird NUR ueber die
		# Umgebung dieses einen Aufrufs weitergereicht.
		out=$$(env -u MAKEFLAGS LAUF_KENNUNG="$$lauf_kennung" $(MAKE_REKURSIV) --no-print-directory -j1 -C $(PROJ) "$$ziel" 2>&1)
		rc=$$?
		echo "$$out"
		lagezeile=$$(printf '%s\n' "$$out" | grep -oE "::LAGE $$lauf_kennung [^ ]+ [^ ]+ [A-Za-z_]+[^:]*::" | tail -n1)
		marke_ok=0
		gefundene_lage=""
		if [[ "$$lagezeile" =~ ^::LAGE\ $$lauf_kennung\ ([^\ ]+)\ ([^\ ]+)\ ([A-Za-z_]+) ]]; then
			if [ "$${BASH_REMATCH[1]}" = "$$kennung" ] && [ "$${BASH_REMATCH[2]}" = "$$ziel" ]; then
				marke_ok=1
				gefundene_lage="$${BASH_REMATCH[3]}"
			fi
		fi
		zusammenfassung="$${zusammenfassung}$${lagezeile:-(keine Marke)} (rueckgabewert=$$rc)"$$'\n'
		if [ "$$marke_ok" -ne 1 ]; then
			echo "" >&2
			echo "make dod: Schritt $$kennung $$ziel hat keine eigene, passende Lage-Marke mit der Lauf-Kennung dieses Aufrufs ausgegeben -- nicht nachweisbar gelaufen (moeglich: hart abgebrochen, MAKE_REKURSIV umgeleitet, Ausgabe leer, fremd oder ohne die Lauf-Kennung)." >&2
			gesamt_rc=2
			break
		fi
		case "$$gefundene_lage" in
			C|A_FAIL)
				echo "" >&2
				echo "make dod: Schritt $$kennung $$ziel meldet in der eigenen Marke Lage '$$gefundene_lage' -- ungleich 0, unabhaengig vom Rueckgabewert des Unterschritts ($$rc)." >&2
				gesamt_rc=2
				break
				;;
		esac
		if [ "$$rc" -ne 0 ]; then
			echo "" >&2
			echo "make dod: Schritt $$kennung $$ziel endete mit Rueckgabewert $$rc." >&2
			gesamt_rc=$$rc
			break
		fi
		marken_zaehler=$$((marken_zaehler + 1))
	done
	echo ""
	echo "=== Uebersicht Definition-of-Done-Kette (make dod) ==="
	printf '%s' "$$zusammenfassung"
	# D19, Teil 2: "nach dem letzten AUSGEFUEHRTEN Schritt" -- hier, weil kein
	# weiterer Kettenschritt mehr laeuft, unabhaengig davon, ob die Schleife
	# vollstaendig durchlief oder vorher abgebrochen ist ("auch bei Abbruch").
	d19_verletzt=0
	if [ "$$d19_hat_repo" -eq 1 ]; then
		if [ "$$d19_werkzeug_fehlt" -eq 1 ]; then
			echo "" >&2
			echo "make dod: D19 LAGE C: .git/ ist vorhanden, aber 'git' ist nicht installiert -- der Kettengrundsatz (ADR 0002, Abschnitt 6, D19) kann nicht beobachtet werden, kein stilles Durchwinken." >&2
			if [ "$$gesamt_rc" -eq 0 ]; then gesamt_rc=2; fi
		else
			d19_status_nachher=$$(git -C $(PROJ) status --porcelain)
			if [ "$$d19_status_vorher" != "$$d19_status_nachher" ]; then
				d19_verletzt=1
				echo "" >&2
				echo "make dod: D19 verletzt (ADR 0002, Abschnitt 6, Kettengrundsatz): der Bestand der versionierten Dateien hat sich zwischen dem ersten und dem letzten ausgefuehrten Schritt ($$letzter_schritt) veraendert." >&2
				echo "make dod: Differenz von 'git status --porcelain' vorher/nachher (betroffene Dateien):" >&2
				diff <(printf '%s\n' "$$d19_status_vorher") <(printf '%s\n' "$$d19_status_nachher") >&2 || true
				# "kann gruen rot machen, nie rot gruen": nur von 0 auf ungleich 0 heben.
				if [ "$$gesamt_rc" -eq 0 ]; then gesamt_rc=2; fi
			fi
		fi
	else
		echo ""
		echo "make dod: D19 Lage B -- kein .git/ vorhanden, der Kettengrundsatz kann an einem nicht versionierten Bestand nicht beobachtet werden."
	fi
	if [ "$$gesamt_rc" -ne 0 ]; then
		echo "" >&2
		echo "make dod: abgebrochen, Rueckgabewert $$gesamt_rc." >&2
		exit $$gesamt_rc
	fi
	if [ "$$marken_zaehler" -ne "$$erwartete_marken" ]; then
		echo "" >&2
		echo "make dod: nur $$marken_zaehler von $$erwartete_marken gueltigen Marken gezaehlt -- Abbruch trotz Rueckgabewert 0 je Schritt." >&2
		exit 2
	fi
	echo ""
	echo "make dod: alle $$erwartete_marken Kettenschritte durchlaufen (D1 bis D12 plus D18), keiner ungleich 0, $$erwartete_marken gueltige Marken gezaehlt, D19 ohne Befund (Arbeitsbaum unveraendert oder kein .git/)."
	exit 0
