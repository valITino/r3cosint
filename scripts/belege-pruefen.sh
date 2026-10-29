#!/usr/bin/env bash
#
# ============================================================================
# ABGENOMMEN (2026-10-28) -- Merge des Pull Requests #39
# ============================================================================
# Abgenommen am 2026-10-28 durch den Merge des Pull Requests #39 (Merge-Commit
# ba55b2dfdf0fd591f8649b56761766324b5c7b12), erster Formweg: ADR 0002,
# Abschnitt 10, Unterabschnitt "Abnahme von G0 (Belegpruefer D20, O-15, mit
# Pruefmittel; SR-009 bis SR-013) -- Merge des Pull Requests #39 -- erteilt am
# 2026-10-28, eingetragen am 2026-10-28". Einheit G0. Damit ist O-15 (Abnahme
# dieses Pruefers) erledigt; O-14 (Stufe 2 ueber den Archivstand) ist mit G0
# gebaut und abgenommen.
#
# Abnahmekriterium: docs/12_Freigabe_Grundgeruest.md, Abschnitt 4, G0,
# (a) bis (d). Ergebnisse:
#   (a) Pruefmittel scripts/belege-pruefen-selbsttest.sh mit 311 Faellen,
#       Modus --mutationen mit 162 Mutationen in
#       scripts/belege-pruefen-mutationen.txt. Endlauf des
#       Dynamic Software Testers am Endstand: Normalmodus 307 von 311
#       bestanden, 0 gefallen, 4 als root nicht herstellbar, Rueckgabewert 0;
#       Mutationsmodus 162 von 162 erkannt, 0 wirkungslos, Rueckgabewert 0.
#   (b) Jede Fehlerklasse hat beide Fallarten, jede der 36 Grenzen ihren Fall
#       (Abgleich des Static Software Testers).
#   (c) Fremdmutationsrunde des Dynamic Software Testers, blind gewaehlt, 32
#       Mutationen: am Stand G0.1 nicht erfuellt (10 falsches Gruen); jedes
#       falsche Gruen mit Fall und Mutation behoben, statisch nachgeprueft und
#       gezielt wiederholt (14 von 14 Mutanten erkannt); keine zweite Runde,
#       Restluecken benannt.
#   (d) make dod: D20 in Lage A bestanden (Dynamic Software Tester am Stand
#       nach M5c; vor dem Commit am Endstand wiederholt); im flachen Klon
#       Lage C (FEHLT=git-historie); bei fehlendem Archivstand Lage C (Kennung
#       archivstand); der Pruefer liest keinen Ort ausserhalb des
#       Repositories.
#
# Was ein gruener Lauf aussagt, bleibt wie im Abschnitt ZWECK UND GRENZE unten
# beschrieben ("der Verweis zeigt auf etwas Vorhandenes", nicht "die Aussage
# stimmt"). Der Satz der Schlussausgabe, die Liste der Grenzen sei nicht
# vollstaendig, bleibt als Selbstauskunft stehen und ist nicht das
# Abnahmekriterium (docs/12_Freigabe_Grundgeruest.md, Abschnitt 4, G0,
# Festlegung 6).
#
# Verlauf, Messungen und Restpunkte:
# docs/uebergaben/2026-10-28_d8-freigabe-grundgeruest-g0-belegpruefer.md,
# Abschnitt "Einheit G0". Fruehere Fassung dieses Kopfes (Block NICHT
# ABGENOMMEN, Stand 2026-09-01, und Block Stand 2026-10-28 (G0.2)) in git bis
# Commit 4a4f4db07dc101b5f0e46a0b072f97009355b148.
# ============================================================================
#
# ============================================================================
# Stand 2026-10-28 (G0.1) -- was sich mit G0 geaendert hat
# ============================================================================
# Anforderung R3-Q-001 (das DoD-Gate stuetzt sich auf D20); offener Punkt O-15 (Abnahme dieses Pruefers).
# Festlegung: ADR 0002, 6.8, Nachtrag vom 2026-10-28 (Festlegung fuer G0). Einzelheiten, Fallklassen und Grenzen:
# docs/uebergaben/2026-10-28_d8-freigabe-grundgeruest-g0-belegpruefer.md, Abschnitt "Einheit G0".
# Pruefmittel: scripts/belege-pruefen-selbsttest.sh (Normalmodus mit der Fallliste; Modus --mutationen mit der
# Mutationsdatei scripts/belege-pruefen-mutationen.txt). Aufruf: bash scripts/belege-pruefen-selbsttest.sh
# [--mutationen] [--pruefer <pfad>]. Das Pruefmittel liest die Kennungen der Klassen KB, KC und EB und der
# Grenzen GB aus diesem Kopfkommentar einzeln (ohne Bereichsschreibweise) und verlangt zu jeder Faelle (Deckung):
# was hier mit Kennung steht, hat dort Faelle, und jeder Fall nennt eine Kennung von hier.
# Gegenueber dem Stand vom 2026-09-01 gilt jetzt:
#   P-1   Kein Git-Arbeitsbaum ist Lage C (Rueckgabewert 3, vorher 2).
#   P-2   Geschlossene Werkzeugliste gleich den aufgerufenen Befehlen; ein fehlendes Werkzeug ist Lage C.
#   P-3   Die Pruefflaeche wird NUL-getrennt gelesen (auch Nicht-ASCII-Namen); scheitert git ls-files oder fehlt
#         oder ist unlesbar eine versionierte Markdown-Datei, ist das Lage C; eine leere Pruefflaeche ist ein Befund.
#   P-4   Codebloecke nach einer Teilmenge von CommonMark; ein bis zum Dateiende offener Zaun ist ein Befund.
#   P-5   Jeder Pfad wird lexikalisch bereinigt; kein Pfad fuehrt aus dem Repository oder ueber eine symbolische
#         Verknuepfung.
#   P-6   Zeilenverweise pruefen Anfang und Ende; der Zahlenvergleich ist fail-closed.
#   P-7   Ein Grund aus Leerraum allein ist kein Grund.
#   P-8   Veraltet ist eine Ausnahme, die im Lauf keinen Fund deckt (statt nach der Form ihres Werts).
#   P-9   Flacher Klon und Teilklon sind Lage C.
#   P-10  Der Pruefer setzt LC_ALL=C fuer sich selbst.
#   P-11  Das Wort ADR gilt je Absatz als Merkmal, Zeile fuer Zeile gesetzt (Laufzeit linear mit der Absatzlaenge).
#   P-12  Die Regeln a bis d entscheiden am wurzelrelativ bereinigten Pfad.
#   Stufe 2 (O-14, S-1 bis S-6): Repo B wird ueber den festen Archivstand aufgeloest statt ueber einen Nachbarordner;
#         "nicht pruefbar" entfaellt.
#   Pruefungen 6 und 7 (Punkt 3): Skill-Zuordnung der Rollen und Anforderung im Skill.
#   Neue Befundarten: pfad-verknuepfung, codeblock-offen, bestand-leer, skill, skill-form, skill-anforderung,
#   frontmatter; neu bestimmt: ausnahme-veraltet.
# Nachtrag M5 (2026-10-28, Behebung der Befunde aus der Pruefung B9/M2, ST-G0-01 bis ST-G0-24):
#   Eine Verknuepfung auf dem Weg zu einer Datei, die der Pruefer selbst liest, ist Lage C (Backlog, Projektauftrag,
#   Ausnahmeliste: KC-06 bis KC-08) beziehungsweise Befund pfad-verknuepfung (Datei der Pruefflaeche); jede Datei geht mit
#   vorangestelltem ./ an awk; ein Fehlschlag von awk oder eines grep-Auszugs beim Lesen ist Lage C (KC-11); ein Zaun aus
#   Rueckwaertsakzenten mit Rueckwaertsakzent in der Sprachangabe ist kein Zaun; KC-04 auch bei einer Fernquelle mit
#   promisor; der Pruefer loescht vor dem ersten git-Aufruf die git-Variablen des Aufrufers; neue Klasse KC-12
#   (objects/info/alternates mit Inhalt); neue Grenzen GB-31 bis GB-35; Textkorrekturen an Kopfkommentar und Schlussausgabe.
# Nachtrag M5b (2026-10-28, Behebung der Befunde der Fremdmutationsrunde M4, Punkt 13): Kommentarzeilen (neue Grenze
#   GB-36; EB-1 nennt das Git-Verzeichnis, EB-2 die Umgebungsvariablen), die Zeile der Schlussausgabe fuer GB-36 und,
#   nach der Messung zu SA-M4-02 (B-306), die eine Zeile export GIT_NO_REPLACE_OBJECTS=1: Ersatzobjekte unter
#   refs/replace/ gelten nicht.
# Nachtrag M5c (2026-10-28, Behebung der Befunde der Nachpruefung Teil 1, ST-G0-25 bis ST-G0-40): Die vier
#   Pfadangabe-Variablen GIT_GLOB_PATHSPECS, GIT_NOGLOB_PATHSPECS, GIT_LITERAL_PATHSPECS und GIT_ICASE_PATHSPECS
#   stehen in der Loeschliste (eine Codezeile, ST-G0-25, EB-3); die Zeile der Schlussausgabe zu GB-32 nennt den
#   Tabulator nicht mehr (ST-G0-26); alles Uebrige sind Kommentarzeilen (Grenze aus OF-16 mit Doppelfehler,
#   Beschaffungsweg beim Lesen, awk-Operand mit Bindestrich, Umbrueche, Schreibweise).
#
# belege-pruefen.sh — Herkunftsangaben gegen ihren Fundort prüfen
#
# Auftrag: docs/uebergaben/2026-08-31_skill-repository-ausgewertet.md,
# Abschnitt "Abbruch nach Eskalationsregel 3.4". Dreimal in Folge ist dieselbe
# Fehlerklasse aufgetreten: eine Aussage über die Herkunft war stärker, als
# die Quelle sie trägt (ein ADR-Zitat, das dort nicht steht; eine Zeilenangabe,
# an der heute etwas anderes steht; ein Beispiel ohne Beleg im Repository).
# Dieses Skript prüft maschinell, ob der genannte Fundort überhaupt existiert.
#
# NACHFÜHRUNG (Weisung des Koordinators, nach dem ersten Lauf mit 167 Funden):
# Ein Gate, das nichts mehr durchlässt, ist so kaputt wie eines, das alles
# durchlässt. Die grosse Mehrheit der 167 Funde war Rauschen (noch nicht
# gebaute Bäume, das andere Repository, Git-Referenzen, Erzeugnisverzeichnisse,
# ADR-interne Abschnittsnummern). Ziel ist NICHT null Funde, sondern dass jeder
# verbleibende Fund entweder ein echter Fehler ist oder eine Ausnahme mit
# geschriebenem Grund. Die Regeln unten setzen genau das um. Dabei ist ein
# echter Fehler im Skript selbst behoben worden: ein Pfadverweis gilt jetzt
# auch als erfüllt, wenn er relativ zum Verzeichnis der NENNENDEN Datei
# existiert (nicht nur relativ zur Repository-Wurzel) — sonst wäre z. B.
# `references/befundfelder.md` in .claude/skills/pruefbefund-melden/SKILL.md
# fälschlich als fehlend gemeldet worden.
#
# ZWECK UND GRENZE — WICHTIG
# Das Skript prüft, OB ein Fundort existiert (Datei, Zeile, Abschnitt,
# Anforderung, Commit). Es prüft NICHT, ob der Inhalt an diesem Fundort die
# Behauptung auch trägt, die ihm zugeschrieben wird. Ein grüner Lauf heisst
# "der Verweis zeigt auf etwas Vorhandenes", nicht "die Aussage stimmt". Das
# war der Auslöser der dritten gescheiterten Runde und wird hier nicht
# stillschweigend mitbehauptet.
#
# PRÜFFLÄCHE
# Alle mit Git versionierten Markdown-Dateien im Wurzelverzeichnis, unter docs/ und unter .claude/ (rekursiv), auch mit
# Nicht-ASCII-Namen (P-3: git ls-files -z, NUL-getrennt gelesen). Kein prototype/, kein backend/, kein frontend/ — dort
# gilt die Kette selbst (make dod), nicht dieses Skript —, und kein Markdown unter scripts/ oder .github/ (KB-19). Nur
# versionierte Dateien, damit ein nicht committetes Arbeitsdokument die Prüffläche nicht verfälscht; ein Verweisziel
# dagegen gilt auch unversioniert als vorhanden, wenn es im Arbeitsbaum liegt (GB-22).
# Eine leere Prüffläche ist ein Befund (Art bestand-leer, Fundort -:0, Wert prueflaeche-leer; ohne Ausnahmeprüfung, also
# durch keine Ausnahme zu decken). Scheitert git ls-files, oder fehlt eine versionierte Markdown-Datei der Prüffläche im
# Arbeitsbaum (und ist keine Verknüpfung und liegt hinter keiner Verknüpfung) oder ist nicht lesbar, ist das Lage C
# (KC-11, Kennung prueflaeche).
# Verknuepfungen (P-5, ST-G0-01 c): Eine Datei der Pruefflaeche, die selbst eine symbolische Verknuepfung ist oder
# unter einem Verzeichnis liegt, das im Arbeitsbaum eine ist (jedes Segment des Pfads wird einzeln mit -L geprueft),
# wird nicht gelesen (Art pfad-verknuepfung, Zeile 0, Wert ihr Pfad, wie git ihn fuehrt; kein Lage C); eine haengende
# Verknuepfung ist ein Befund, kein Lage C. Jeder Pfad eines Verweises wird lexikalisch bereinigt ("." und doppelte
# Schraegstriche entfallen, ".." hebt das vorige Segment auf); verlaesst er die Wurzel, gilt das Ziel als nicht
# vorhanden, ohne Dateizugriff (KB-12).
# Liegt auf dem bereinigten Pfad eine symbolische Verknuepfung, ist das ein Befund (pfad-verknuepfung); sie wird nie
# verfolgt. Vorrang (Auslegung aus B2, KB-12, ST-G0-04): Besteht ein Kandidat, wurzelrelativ oder verzeichnisrelativ,
# ohne Verknuepfung auf seinem Weg, geht er vor; pfad-verknuepfung ist es nur, wenn kein Kandidat ohne Verknuepfung besteht
# und einer ueber eine fuehrt.
#
# ARCHIVSTAND (Repo B, r3coscrum; Stufe 2, S-1 bis S-6)
# Repo B ist mit PS-4 in dieses Repository eingefaltet; sein Verlauf liegt im Zweig archiv/r3coscrum. Aufgelöst wird
# über einen FESTEN Commit dieses Zweigs, die Konstante ARCHIVSTAND (Kopf des Zweigs seit der Nachführung in Einheit
# D5): Prüfsummen im eigenen Objektspeicher, Pfade unter methodik/, nachweise/, sprints/ und mit dem Präfix
# r3coscrum/ im Baum dieses Commits (git cat-file -t <stand>:<pfad>). Der Prüfer liest keinen Ort ausserhalb des
# Repositories; es gibt dafür weder eine Umgebungsvariable noch eine Konfiguration (S-1, EB-2). Fehlt der Commit im
# eigenen Objektspeicher, ist das Lage C (KC-05, Kennung archivstand); die Meldung nennt den Beschaffungsweg: git fetch
# origin +refs/heads/archiv/r3coscrum:refs/remotes/origin/archiv/r3coscrum. "Nicht prüfbar" gibt es nicht mehr.
# GRENZE (GB-23): Ein Pfad, der nur in einem späteren Stand des Zweigs besteht, ist ein Fund; eine Nachführung des
# Zweigs ist eine Änderung an diesem Prüfer mit Fall.
#
# CODEBLOECKE (```) WERDEN VOR DEN PRUEFUNGEN 1 BIS 5 AUSGEBLENDET (KB-18)
# Text innerhalb umschlossener Codeblöcke ist zitierter oder wörtlich wiedergegebener Inhalt (Befehlsausgaben,
# Verzeichnisbäume, ein historischer Schnappschuss einer alten CLAUDE.md in docs/09_Zustandsbericht_2026-08-21.md). Er
# wird als Beispiel oder Beleg gezeigt, nicht als eigenständige, aktuelle Behauptung des Dokuments. Zeilennummern
# bleiben dabei erhalten (die Zeile wird geleert, nicht entfernt), Befunde zeigen also immer auf die richtige
# Originalzeile.
# Zäune (P-4): drei oder mehr Rückwärtsakzente oder Tilden, bis zu drei Leerzeichen Einzug; geschlossen nur durch einen
# Zaun desselben Zeichens, mindestens so lang wie der öffnende, danach nur Leerraum. Ein bis zum Dateiende offener Zaun
# ist ein Befund (Art codeblock-offen, Zeile des oeffnenden Zauns, Wert die Zaunzeichen). Ein Zaun aus Rueckwaertsakzenten,
# dessen Sprachangabe einen Rueckwaertsakzent enthaelt, ist nach CommonMark kein Zaun (ST-G0-05; Tilden unveraendert).
# GRENZE (GB-24): Zaeune in Zitatbloecken oder mit mehr als drei Leerzeichen Einzug werden nicht erkannt, ihr Inhalt wird
# geprueft. Die Pruefungen 6 und 7 (Frontmatter), die Referenzmengen des Backlogs und des Projektauftrags und die eigenen
# Ueberschriften der nennenden Datei (Pruefung 5) lesen den Rohtext, auch aus Codebloecken (GB-21, GB-31). Jede Datei
# geht mit vorangestelltem ./ an awk (ST-G0-02).
#
# DIE SIEBEN PRÜFUNGEN
#
# 1. Zeilenverweise. Ein Verweis der Form `datei:N` oder `datei:N-M`
#    (zwischen einzelnen Rückwärtsakzenten): Die Datei existiert (root- oder
#    verzeichnisrelativ, siehe Prüfung 4) und hat die genannten Zeilen: N mindestens 1,
#    N höchstens M, das Grössere von N und M höchstens die Zeilenzahl (P-6). Ein
#    Zeilenanhang an einem Verzeichnis ist ein Fund (Art zeile); eine Zahl mit mehr als
#    9 Stellen (ohne fuehrende Nullen) gilt als groesser als jede Zeilenzahl. Gilt auch fuer Pfade mit dem Praefix
#    r3cosint/ und für Pfade im Archivstand (S-4). Erkennt nur Verweise, die vollständig auf einer Zeile stehen
#    und deren Pfadteil kein Leerzeichen enthält. Ist die Datei selbst nicht
#    auffindbar, meldet bereits Prüfung 4 den Fund.
#
# 2. Commit-Prüfsummen. Jede Folge von genau 40 Kleinbuchstaben-Hexzeichen
#    (mit Wortgrenze) muss einen Commit bezeichnen, den dieses Repository
#    kennt (`git cat-file -e <wert>^{commit}` im eigenen Objektspeicher, der
#    auch die Objekte des Archivstands von Repo B enthält; S-4). Zusätzlich ist
#    jedes Vorkommen von `blob/main` oder
#    `tree/main` ein Befund — mit EINER Ausnahme: Stellen, an denen eine Regel
#    diese Form ausdrücklich als abschreckendes Beispiel zitiert, tragen einen
#    eigenen, mit Datei UND Zeile verankerten Ausnahmeeintrag (siehe unten,
#    Abschnitt AUSNAHMELISTE) -- nicht den blossen Wert, sonst deckte die
#    Ausnahme einen künftigen echten Verstoss in derselben Datei mit zu.
#    Bekannte Restfälle, die auch nach dem Abgleich mit dem Archivstand offenbleiben und
#    darum in der Ausnahmeliste stehen: Commit-Prüfsummen eines DRITTEN
#    Repositories (`valITino/claude-skills-fullstack`) und gepinnte
#    Drittanbieter-Commits (GitHub-Action-SHA, derzeit zwei Staende von actions/checkout) -- sie liegen
#    lokal nicht vor, das kann kein lokaler Rueckgleich aufloesen.
#
# 3. Anforderungskennungen. Jede Kennung der Form R3-<Buchstabe>-<drei
#    Ziffern> muss als Überschrift (`^#+ R3-...`) in docs/05_Product_Backlog.md
#    stehen.
#
# 4. Pfadverweise. Jeder Inline-Code-Verweis (zwischen einzelnen
#    Rückwärtsakzenten) wird als Pfadverweis behandelt, wenn er: kein
#    Leerzeichen enthält (schliesst Shell-Befehle wie `bash scripts/x.sh`
#    aus — deren Pfadteil wird dadurch NICHT geprüft, eine bekannte Lücke);
#    kein "://" enthält (keine URL); nicht mit "/" beginnt (keine absoluten
#    Systempfade wie `/tmp`, keine Slash-Befehle wie `/usage`); nicht mit "~"
#    beginnt (kein Heimverzeichnis wie `~/.cache/uv`); keines der Zeichen
#    " ' $ = * < > { } enthaelt und nicht die Zeichenfolge "..." oder das Auslassungszeichen (ein Zeichen)
#    (schliesst Shell-Variablen, Zuweisungen und Platzhalter wie
#    `.claude/agents/<name>.md` aus — ausgenommen Platzhalter ohne diese
#    Zeichen, etwa "NNNN" in einem Dateinamen-Muster, werden NICHT erkannt
#    und fälschlich als Pfad geprüft); kein "@" enthält (keine
#    versionsgepinnten fremden Referenzen wie `actions/checkout@v4`); nicht
#    mit "blob/" oder "tree/" beginnt (das übernimmt Prüfung 2).
#
#    Enthält der Kandidat ein "/", wird zusätzlich das erste Segment (vor dem
#    ersten "/") geprüft:
#      - "claude", "origin", "fix" ohne führenden Punkt gelten als
#        Git-Referenz (Branch- beziehungsweise Fernname), nicht als Pfad.
#        Das ist eine kleine, aus dem tatsächlichen Bestand belegte Liste
#        (`claude/next-step-g8slnq`, `origin/main`, `fix/main-seite`), kein
#        allgemeines Git-Flow-Schema — ein künftiges "release/..." oder
#        "hotfix/..." würde NICHT erkannt.
#      - "valITino" (der GitHub-Organisationsname beider Projekt-Repos und
#        des fremden Skill-Repositories) gilt als Repository-Verweis, nicht
#        als Pfad.
#      - Ein Punkt im ersten Segment ausserhalb der ersten Stelle (z. B.
#        "github.com", "mb-api.abuse.ch") gilt als Rechnername. "." und ".."
#        sind davon ausdrücklich ausgenommen (gültige Pfadsegmente, z. B. in
#        `../SKILL.md`).
#      - Besteht der Kandidat aus GENAU zwei Segmenten (ein einziges "/") UND
#        gehört das erste Segment NICHT zum eigenen Baum (.claude, .github,
#        docs, scripts, prototype, backend, frontend, deploy) UND enthält das
#        zweite Segment KEINEN Punkt, gilt das als fremdes
#        "Inhaber/Repository"-Muster (`actions/checkout`,
#        `Wh0am123/MCP-Kali-Server`, `decompiler-explorer/decompiler-explorer`)
#        und wird nicht als Pfad geprüft. GRENZE: Das nimmt auch einen
#        echten, bisher nicht existierenden Zwei-Segment-Pfad ausserhalb des
#        eigenen Baums fälschlich aus der Prüfung — z. B. `tests/architektur`
#        ohne vorangestelltes `backend/` würde nicht erkannt.
#    Ohne "/" wird nur geprüft, wenn der Kandidat exakt einem der
#    Wurzeldateinamen Makefile, CLAUDE.md, README.md, CONTRIBUTING.md,
#    .gitignore entspricht.
#
#    P-12: Die Regeln a bis d entscheiden am wurzelrelativ lexikalisch bereinigten Pfad (P-5): Regel a an dessen
#    Segmenten, die Regeln b bis d an dessen erstem Segment. ./backend/x und docs/../backend/x gehören damit zu
#    Regel b. Verlässt der Pfad wurzelrelativ die Wurzel, entscheidet keine der Regeln b bis d; er wird nach P-5
#    geprüft (Regel a fällt dann auf den Pfad wie geschrieben zurück). GRENZE (GB-28): Ein Verweis, der erst
#    verzeichnisrelativ in backend/, frontend/, deploy/ oder prototype/ führt (etwa ../backend/x aus docs/), fällt
#    nicht unter Regel b und wird auch geprüft, solange der Baum fehlt (Fehlalarm, sichere Richtung).
#
#    Danach gelten, in dieser Reihenfolge, vier weitere Regeln, bevor ein
#    Fund gemeldet wird:
#      a) Erzeugnis- und Abhängigkeitsverzeichnisse als Pfadsegment
#         (node_modules, .venv, dist, build, __pycache__, .pytest_cache,
#         .mypy_cache) sind NIE ein Fund, unabhängig vom Rest des Pfads —
#         sie werden im Bestand als Beispiele genannt und sollen gerade
#         nicht im Repository liegen.
#      b) Beginnt der Pfad mit backend/, frontend/, deploy/ oder prototype/
#         und existiert dieses oberste Verzeichnis (noch) NICHT, ist das
#         KEIN Fund — das ist der architekturgemäss geplante Zustand vor dem
#         Grundgerüst. Die Regel schaltet sich von selbst scharf: Sobald das
#         Verzeichnis angelegt ist, werden Pfade darunter wieder normal
#         geprüft.
#      c) Beginnt der Pfad mit methodik/, nachweise/ oder sprints/, gehört
#         er zu Repo B (r3coscrum) und wird im Baum des Archivstands geprüft:
#         git cat-file -t <stand>:<pfad> liefert blob (Datei) oder tree
#         (Verzeichnis), jeder andere Ausgang ist ein Fund pfad (S-4). Ein
#         Zeilenanhang wird nur an einem blob geprüft (Zeilenzahl über git
#         cat-file blob, Zahlenregeln wie Prüfung 1); an einem tree ist er ein
#         Fund zeile. Den Ausgang "nicht prüfbar" gibt es nicht mehr.
#      d) Beginnt der Pfad mit r3coscrum/ oder r3cosint/, ist der Name Teil
#         der Aussage und nicht des Pfads: er wird abgetrennt und der Rest im
#         genannten Baum geprüft. r3coscrum/: im Baum des Archivstands wie
#         unter c); r3cosint/: gegen die eigene Wurzel wie Prüfung 4 und 1.
#         Der Wert eines Funds ist der Pfadteil wie geschrieben, mit Präfix.
#
#    Für die Existenzprüfung selbst gilt: ein Pfad ist erfüllt, wenn er ALS
#    DATEI ODER VERZEICHNIS existiert — root-relativ ODER relativ zum
#    Verzeichnis der Datei, die ihn nennt (siehe NACHFÜHRUNG oben). Ein
#    optionaler Zeilenanhang `:N` oder `:N-M` wird vorher abgetrennt und an
#    Prüfung 1 übergeben.
#
#    P-5: Jeder Kandidat (root- und verzeichnisrelativ) wird vor der Prüfung lexikalisch
#    bereinigt ("." und doppelte Schrägstriche entfallen, ".." hebt das vorige Segment
#    auf). Verlässt er die Wurzel, gilt er als nicht vorhanden, ohne Dateizugriff. Liegt
#    auf dem bereinigten Pfad eine symbolische Verknüpfung (auch beim obersten Verzeichnis
#    der Probe von Regel b), ist das ein Befund (Art pfad-verknuepfung); sie wird nie
#    verfolgt. Vorrang (ST-G0-04, Auslegung aus B2): Besteht ein Kandidat, wurzel- oder verzeichnisrelativ, ohne
#    Verknuepfung auf seinem Weg, geht er vor (B-228, B-229); pfad-verknuepfung ist es nur, wenn kein Kandidat ohne
#    Verknuepfung besteht und einer ueber eine fuehrt.
#
#    Nicht erfasst: Pfade, die auf mehrere Zeilen verteilt oder ohne
#    Rückwärtsakzente genannt sind.
#
# 5. Abschnitte des Projektauftrags. Jede Angabe der Form `Projektauftrag
#    N.M` muss eine Überschrift (`^#+ N.M ...`) in docs/00_Projektauftrag.md
#    bezeichnen und wird IMMER geprüft — die Form ist unzweideutig. Die
#    Formen `(N.M)` und `Abschnitt N.M` werden dagegen NUR geprüft, wenn im
#    selben ABSATZ nirgends das Wort "ADR" steht. "Absatz" heisst: der
#    zusammenhängende Text zwischen zwei Leerzeilen; eine Markdown-Tabelle
#    ohne Leerzeile zwischen den Zeilen zählt dabei als EIN Absatz, auch über
#    viele Tabellenzeilen hinweg. Begründung: Die ADRs führen selbst eine
#    eigene N.M-Gliederung, ein Verweis wie "ADR 0002, Abschnitt 3.7" nennt
#    also die ADR-Gliederung, nicht den Projektauftrag — und "ADR 0002" steht
#    im Bestand oft mehrere Zeilen vor der eigentlichen Abschnittsangabe
#    (weicher Zeilenumbruch in Fliesstext, oder eine lange Tabellenzeile, die
#    "ADR" gar nicht wiederholt, weil die Zugehörigkeit zur ADR-Tabelle schon
#    aus der Zeile selbst hervorgeht). Eine reine Zeilenregel liess in einer
#    ersten Fassung genau diese Fälle durch; die Absatzregel schliesst sie.
#    P-11 (EB-4): Je Absatz wird nur das Merkmal "das Wort ADR kommt vor" gesetzt, Zeile für Zeile;
#    die Laufzeit wächst linear mit der Länge des Absatzes (vorher quadratisch).
#    GRENZE (GB-12), bewusst in Kauf genommen: Eine ganze mehrzeilige Tabelle ohne
#    Leerzeilen gilt als ein Absatz — nennt IRGENDEINE Zeile dieser Tabelle
#    "ADR", wird auch ein echter Projektauftrag-Verweis in einer ANDEREN
#    Zeile derselben Tabelle nicht mehr geprüft. Das ist eine benannte,
#    in Kauf genommene Lücke, keine falsche Meldung.
#
#    ZUSÄTZLICH, über die Absatzregel hinaus (GB-13): Für die Formen `(N.M)` und
#    `Abschnitt N.M` wird auch nicht geprüft, wenn die NENNENDE DATEI selbst
#    eine Ueberschrift mit dieser Nummer fuehrt (jede Datei mit eigener N.M-Gliederung, heute vor allem die ADRs).
#    Grund: In ADR 0002 nennt die Definition-of-Done-Tabelle eigene Abschnitte
#    ("Abschnitt 3.5 verlangt diesen Schritt …"), ohne das Wort "ADR" im
#    ganzen Tabellen-Absatz zu wiederholen — die Absatzregel allein liess
#    diesen konkreten Fall beim ersten Testlauf noch durch.
#
# 6. Skill-Zuordnung (Punkt 3). Jeder Name im Feld skills: einer Rollendatei (.claude/agents/<name>.md, nur diese
#    Ebene) braucht eine .claude/skills/<name>/SKILL.md als reguläre Datei (Art skill; ist das Skill-Verzeichnis oder die
#    SKILL.md eine Verknüpfung, ist das pfad-verknuepfung mit dem abgeleiteten Pfad .claude/skills/<name>/SKILL.md; KB-14).
#    Gelesen wird das Frontmatter als Rohtext, ein awk-Programm je Datei: Zeile 1 genau "---" (ein Wagenrücklauf am
#    Zeilenende wird übergangen), Ende an der nächsten Zeile genau "---"; fehlt sie, ist das allein der Befund
#    frontmatter (Zeile 1, Wert "nicht geschlossen"; KB-17), und die Prüfungen 6 und 7 werten die Datei nicht weiter aus.
#    Das Feld ist die Zeile ohne Einzug, die mit skills: beginnt. Kandidat ist jede folgende Zeile, die nach Leerraum mit
#    einem Bindestrich beginnt; Leerzeilen und Kommentarzeilen (nach Leerraum mit #) werden übergangen und beenden die
#    Liste nicht, die Liste endet an der ersten anderen nicht leeren Zeile. Eine Form, die der Prüfer nicht liest, ist ein
#    Befund (Art skill-form; KB-15): Flussliste oder Skalar hinter skills: (Wert der Rest), leere Liste (Wert "leer"), ein
#    Eintrag, der nicht die Form Einzug aus Leerzeichen, Bindestrich, Leerraum, Name hat (Tabulator im Einzug, Bindestrich
#    ohne folgenden Leerraum), ein Eintrag ohne Namen (Bindestrich allein, Wert "leer"), ein Name ausserhalb von
#    ^[a-z0-9]+(-[a-z0-9]+)*$ (nach Entfernen paariger gerader Anführungszeichen und des Leerraums) und skills: zweimal
#    (Wert "skills doppelt", keine weitere Auswertung des Feldes). Rollen ohne Frontmatter oder ohne skills: ergeben keinen
#    Fund. Dieselbe Skill in mehreren Rollen ist der Normalfall; derselbe Name zweimal in einer Liste wird je Eintrag
#    geprüft, ohne eigenen Fund (GB-26). Ein YAML-Kommentar hinter einem Namen wird nicht als Kommentar erkannt, der
#    Eintrag gilt als Formabweichung (GB-27, Fehlalarm). Eine UTF-8-Bytefolge (BOM) vor dem Frontmatter wird nicht
#    übergangen (GB-29), Zeilenenden nur aus Wagenrücklauf werden nicht erkannt (GB-30).
#
# 7. Anforderung im Skill (Punkt 3). Jede .claude/skills/<name>/SKILL.md (genau eine Verzeichnisebene) trägt im
#    Frontmatter (gelesen wie unter 6) unter metadata: genau eine eingerückte Zeile anforderung: mit genau einer Kennung
#    R3-<Buchstabe>-<drei Ziffern> (nach Entfernen paariger gerader Anführungszeichen und des Leerraums), die als
#    Überschrift im Backlog steht (Art skill-anforderung; KB-16). Fehlt das Frontmatter, metadata: oder anforderung:, ist
#    der Wert "fehlt" an Zeile 1; ist anforderung: leer, ist der Wert "leer" an dessen Zeile; metadata: oder anforderung:
#    zweimal ergibt allein den Befund an der zweiten Zeile ("metadata doppelt", "anforderung doppelt"); ein Wert, der
#    nicht genau eine Kennung ist, ergibt den gelesenen Wert, eine Kennung ohne Überschrift den Wert der Kennung. Der
#    Block von metadata: reicht bis zur ersten nicht leeren Zeile ohne Einzug, die keine Kommentarzeile ist;
#    Kommentarzeilen (nach Leerraum mit #) im Block werden übergangen. Ein Kommentar hinter der Kennung gehört zum
#    gelesenen Wert (GB-27). Eine Kennung ohne Überschrift meldet Prüfung 3 an derselben Zeile zusätzlich (GB-25). Alle
#    Meldungen der Prüfungen 6 und 7 gehen über die Ausnahmeprüfung (6.8.5).
#
# AUSNAHMELISTE (scripts/belege-ausnahmen.txt; 6.8.5)
# Aufbau je Zeile: der Schluessel, ein Tabulator, der Grund. Uebergangen und mitgezaehlt werden nur Zeilen ohne jedes
# Zeichen und Zeilen mit # am Anfang; eine Zeile nur aus Leerraum ist ausnahme-form (KB-22, ST-G0-20). Zwei
# Schluesselformen: datei:zeile (genau dieser Fundort, jeder Wert dort; die Zeilennummer hat keine Obergrenze) und
# datei|wert (dieser Wert in dieser Datei, zeilenunabhängig). Eine Ausnahme gilt für jede Prüfungsart am Fundort
# (GB-25). KB-20: Ein Fund wird nur von einem Schlüssel unterdrückt, der seinen Fundort oder seinen Wert in seiner
# Datei trifft; derselbe Wert in einer anderen Datei und dieselbe Datei an einer anderen Zeile bleiben Funde.
# Die Form datei|wert deckt auch ein zweites, falsches Vorkommen desselben Werts in derselben Datei (GB-15); für
# blob/main- und tree/main-Funde ist darum datei:zeile die vorgesehene Form.
# Je Eintrag höchstens ein Befund, in der Rangfolge Form, Grund, Veraltung; Fundort ist die Zeile der Liste, Wert der
# ganze Schlüssel, gemeldet ohne Ausnahmeprüfung (eine Ausnahme kann keinen Befund der Liste und keine leere Prüffläche
# decken):
#   KB-22 Art ausnahme-form: der Schlüssel hat keine der beiden Formen.
#   KB-21 Art ausnahme-ohne-grund: der Grund braucht ein Zeichen ausser Leerraum (P-7); ein Eintrag ohne Tabulator hat
#         keinen Grund.
#   KB-23 Art ausnahme-veraltet: der Eintrag hat im Lauf keinen Fund gedeckt, gleich welcher Schlüsselform (P-8).
#         ist_ausgenommen prüft beide Schlüssel eines Funds und vermerkt jeden passenden als benutzt; deckt ein Fund
#         mehrere Schlüssel, gelten alle als benutzt.
#
# RÜCKGABEWERT UND AUSGABE (KB-24)
# 0 — keine Beanstandung. 2 — mindestens ein Befund. 3 — Lage C: ein Prüfmittel fehlt oder trägt die Aussage
# nicht; dann urteilt der Lauf über den Bestand gar nicht. Die Trennung von 2 und 3 ist der Grund, weshalb 3
# überhaupt existiert: "rot, weil etwas gefunden wurde" und "rot, weil nicht gemessen werden konnte" sind verschiedene
# Aussagen, und das Makefile führt sie als A_FAIL beziehungsweise Lage C getrennt weiter (ADR 0002, Abschnitt 6.11).
# Standardausgabe: "=== Funde nach Prüfungsart ===" (je Art eine Zeile Art, Tabulator, Zahl; "(keine)" ohne Fund),
# "=== Funde vollständig ===" (je Fund eine Zeile Datei:Zeile, Tabulator, Art, Tabulator, Wert), dann "---", die
# Selbstauskunft mit den benannten Grenzen, die Zeile zu Repo B (Archivstand) und "Befunde: n"; n ist die Zahl der Zeilen
# unter "Funde vollständig" (ausser bei Dateinamen mit Zeilenumbruch, GB-32), die Summe der Arten ist n. Arten: zeile,
# commit, blob-tree-verweis, anforderung, pfad, pfad-verknuepfung, abschnitt, skill, skill-form, skill-anforderung,
# frontmatter, codeblock-offen, bestand-leer, ausnahme-ohne-grund, ausnahme-form, ausnahme-veraltet. Lage C geht auf
# die Fehlerausgabe, die Standardausgabe bleibt dann ohne "Befunde:" und ohne Abschnitt "Funde". EB-1: Das Skript
# schreibt nichts in den Arbeitsbaum und nichts in dessen Git-Verzeichnis, auch nicht bei Lage C: kein Schreibzugriff,
# keine Zwischendatei. Ausserhalb des Arbeitsbaums legt bash selbst fuer lange Here-Strings und Here-Documents eine
# temporaere Datei unter TMPDIR an (gemessen); sie gehoert nicht zum Skript (ST-G0-13).
#
# LAGE C (Rueckgabewert 3) stellt der Lauf selbst fest (ausser sein eigenes Fehlen, das das Makefile feststellt), vor jedem
# Urteil, in dieser Reihenfolge: KC-01; Loeschen der git-Variablen des Aufrufers; KC-02, KC-03, KC-04, KC-12, KC-05,
# KC-06 bis KC-08, KC-09, KC-10, KC-11; die Lage C beim Lesen (KC-11) tritt erst im Hauptteil ein und gibt wie jede
# Lage C kein Urteil aus. Bei zwei Maengeln gilt der erste. Die Meldung auf der Fehlerausgabe traegt "LAGE C", die
# Kennung und, wo einer festgelegt ist, den Beschaffungsweg.
#   KC-01 Werkzeug der geschlossenen Liste fehlt; Kennung werkzeug:<name>; Beschaffen: Werkzeug installieren.
#   KC-02 Kein Git-Arbeitsbaum am Arbeitsverzeichnis (P-1); Kennung git-arbeitsbaum; kein Beschaffungsweg.
#   KC-03 Flacher Klon (P-9); Kennung git-historie; Beschaffen: git fetch --unshallow.
#   KC-04 Teilklon, extensions.partialclone gesetzt, gleich welche Formatversion (P-9), oder eine Fernquelle mit promisor
#         wahr (Schluessel remote.<name>.promisor) in irgendeiner Konfigurationsebene (ST-G0-07); Kennung git-teilklon;
#         Beschaffen: vollstaendigen Klon anlegen (git clone ohne --filter). Steht vor dem Archivstand: in einem Teilklon
#         laedt git fehlende Objekte beim Zugriff nach (Netzzugriff, Schreiben in den Objektspeicher).
#   KC-12 Fremde Objektquelle: objects/info/alternates besteht und hat Inhalt (den Pfad liefert git rev-parse --git-path,
#         er trifft auch ein .git als Datei); Kennung git-alternates; Beschaffen: git repack -a -d, danach
#         objects/info/alternates entfernen. Vorhanden und leer ist kein Lage C; jeder Inhalt ist Lage C. Hinweis: Eine
#         haengende Verknuepfung als alternates-Datei wirkt in git nicht und ist kein Lage C (-s folgt der
#         Verknuepfung). Steht nach KC-04 und vor KC-05 (ST-G0-08).
#   KC-05 Archivstand nicht als Commit vorhanden (S-3); Kennung archivstand; Beschaffen: git fetch origin
#         +refs/heads/archiv/r3coscrum:refs/remotes/origin/archiv/r3coscrum.
#   KC-06 Backlog docs/05_Product_Backlog.md fehlt, ist nicht lesbar oder ist eine Verknuepfung (auch ein Verzeichnis auf
#         dem Weg; jedes Segment wird vor jedem anderen Zugriff mit -L geprueft; ST-G0-01); Kennung: der Pfad; bei
#         Verknuepfung Beschaffen: durch die Datei selbst ersetzen, sonst kein Beschaffungsweg.
#   KC-07 Projektauftrag docs/00_Projektauftrag.md fehlt, ist nicht lesbar oder ist eine Verknuepfung (wie KC-06); Kennung:
#         der Pfad; bei Verknuepfung Beschaffen: durch die Datei selbst ersetzen.
#   KC-08 Ausnahmeliste scripts/belege-ausnahmen.txt fehlt, ist nicht lesbar oder ist eine Verknuepfung (wie KC-06;
#         vorhanden und ohne Eintrag ist kein Lage C); Kennung: der Pfad; bei Verknuepfung Beschaffen: durch die Datei selbst
#         ersetzen.
#   KC-09 Referenzmenge des Backlogs leer, keine Kennung als Überschrift; Kennung referenzmenge-backlog.
#   KC-10 Referenzmenge des Projektauftrags leer, keine Abschnittsnummer als Überschrift; Kennung
#         referenzmenge-projektauftrag.
#   KC-11 Prüffläche nicht ermittelbar (git ls-files scheitert) oder eine versionierte Markdown-Datei der
#         Prüffläche fehlt im Arbeitsbaum (und ist keine Verknüpfung und liegt hinter keiner Verknüpfung) oder ist
#         nicht lesbar (P-3); Kennung prueflaeche, die Meldung nennt die Datei; Beschaffen bei fehlender Datei:
#         wiederherstellen oder die Loeschung mit git rm uebernehmen. Lage C beim Lesen (ST-G0-03): endet awk
#         (Ausblendung, Zaun, Frontmatter) mit einem Rueckgabewert ungleich 0 oder ein grep-Auszug der Pruefungen 2 bis
#         5 mit einem Rueckgabewert groesser 1 beim Lesen einer Datei, ist das ebenfalls KC-11, Kennung prueflaeche,
#         die Meldung nennt die Datei; sie tritt im Hauptteil ein, der Lauf gibt kein Urteil aus. Beschaffen bei einem
#         Lesefehler: Leserecht der Datei herstellen; endet das Werkzeug weiter ungleich 0, es pruefen (ST-G0-38). Lage
#         C gilt nur fuer Fehlschlaege, die zu einem Durchlass fuehren koennten: die drei awk-Aufrufe (Ausblendung,
#         offener Zaun, Frontmatter) und die fuenf grep-Auszuege der Pruefungen 2 bis 5.
#         Fehlschlaege, die nur Funde zu viel erzeugen, bleiben ein Fund: die Absatzbildung und der Auszug der eigenen
#         Ueberschriften in Pruefung 5, die Zahl aus dem Treffer, die Zeilenzahl einer Datei oder eines Blobs, jeder
#         git-Aufruf einer Pruefsumme oder eines Pfads, dirname und die Lesung der Referenzmengen (beide in sicherer
#         Richtung, ST-G0-28). Grenze (Doppelfehler, benannt, nicht behoben, ST-G0-27, OF-16): Ein einziger
#         Werkzeugfehlschlag ausserhalb der Lage C erzeugt einen Fund zu viel; trifft dieser Fund eine sonst veraltete
#         Ausnahme, zaehlt sie als benutzt, und der Lauf kann mit Rueckgabewert 0 statt 2 enden.
# Der Lauf setzt LC_ALL=C fuer sich selbst (P-10). Vor dem ersten git-Aufruf loescht er die git-Variablen des
# Aufrufers, die Gegenstand, Objektspeicher oder die Deutung von Pfadangaben verlegen (GIT_DIR, GIT_WORK_TREE,
# GIT_INDEX_FILE, GIT_COMMON_DIR, GIT_OBJECT_DIRECTORY, GIT_ALTERNATE_OBJECT_DIRECTORIES, GIT_NAMESPACE,
# GIT_CEILING_DIRECTORIES, GIT_SHALLOW_FILE, GIT_DISCOVERY_ACROSS_FILESYSTEM, die vier Pfadangabe-Variablen
# GIT_GLOB_PATHSPECS, GIT_NOGLOB_PATHSPECS, GIT_LITERAL_PATHSPECS und GIT_ICASE_PATHSPECS und alle Variablen
# GIT_TRACE*: die Liste von .claude/hooks/session-start-git-historie.sh plus GIT_DISCOVERY_ACROSS_FILESYSTEM und die
# vier Pfadangabe-Variablen; ST-G0-08, ST-G0-25, EB-3). Mit GIT_GLOB_PATHSPECS=1 lieferte der Aufruf zur Pruefflaeche
# (git ls-files, Pfadangabe '*.md') nur die Wurzeldateien (ein falsches Gruen fuer jeden Fund ausserhalb der Wurzel),
# mit GIT_LITERAL_PATHSPECS=1 oder GIT_NOGLOB_PATHSPECS=1 keine Datei (bestand-leer). Die GIT_CONFIG_*-Variablen
# bleiben. Er setzt GIT_NO_REPLACE_OBJECTS=1: Ersatzobjekte unter refs/replace/ gelten nicht (SA-M4-02, M5b Nr. 15).
#
# WERKZEUGE
# Nur bash und die geschlossene Liste git, grep, awk, sort, dirname (P-2): genau die Befehle, die das Skript aufruft;
# Befehle, die bash selbst mitbringt, zählen nicht. Fehlt ein Werkzeug der Liste, ist das Lage C (KC-01,
# werkzeug:<name>). Wer einen weiteren Befehl aufruft, nimmt ihn in die Liste (Variable WERKZEUGE im Skript) und hier
# auf. Kein sed, kein jq, kein Python, kein Netz.
#
# FEHLERKLASSEN, DIE DAS PRUEFMITTEL MISST (Kennung und Gegenstand; je Klasse Faelle mit Soll Fund und mit Soll kein Fund)
#   KB-01 Pruefung 1, Einzelzeile (datei:N)
#   KB-02 Pruefung 1, Bereich (datei:N-M)
#   KB-03 Pruefung 1 an einem Verzeichnis, an einem Archivpfad und mit dem Praefix r3cosint/ oder r3coscrum/
#   KB-04 Pruefung 2, Commit-Pruefsumme
#   KB-05 Pruefung 2, Zweigform (blob/main, tree/main)
#   KB-06 Pruefung 3, Anforderungskennung
#   KB-07 Pruefung 4, wurzelrelativer Pfad
#   KB-08 Pruefung 4, verzeichnisrelativer Pfad
#   KB-09 Pruefung 4, Gegenproben zu den Ausschlussregeln
#   KB-10 Regel b, Scharfschaltung der noch nicht gebauten Baeume
#   KB-11 Regeln c und d, Pfade im Archivstand
#   KB-12 Pfad ausserhalb der Wurzel und symbolische Verknuepfung
#   KB-13 Pruefung 5, Abschnitte des Projektauftrags
#   KB-14 Pruefung 6, Skill-Zuordnung der Rollen
#   KB-15 Pruefung 6, Form des Eintrags
#   KB-16 Pruefung 7, Anforderung im Skill
#   KB-17 Frontmatter (nicht geschlossen, Wagenruecklauf am Zeilenende)
#   KB-18 Ausblendung der Codebloecke
#   KB-19 Pruefflaeche
#   KB-20 Ausnahme, Unterdrueckung
#   KB-21 Ausnahme ohne Grund
#   KB-22 Ausnahme, Form des Schluessels
#   KB-23 Ausnahme, Veraltung
#   KB-24 Rueckgabewert, Zaehlung und Schlussausgabe
#
# EIGENSCHAFTEN DES LAUFS (je ein Fall und eine Mutation im Pruefmittel)
#   EB-1  Kein Schreiben: der Lauf schreibt nichts in den Arbeitsbaum und nichts in dessen Git-Verzeichnis (.git/ oder das
#         Verzeichnis, auf das ein .git als Datei zeigt), keine Zwischendatei, auch nicht bei Lage C (die temporaere Datei,
#         die bash selbst fuer lange Here-Strings unter TMPDIR anlegt, gehoert nicht zum Skript).
#   EB-2  Kein fester Ort: der Pruefer liest keinen Ort ausserhalb des Repositories; ausserhalb von Kommentarzeilen
#         enthaelt dieses Skript keinen absoluten Pfad ausser /dev/null. Er liest ausserdem keine Umgebungsvariable des
#         Aufrufers: ausser PATH und BASH_REMATCH (das bash selbst setzt) liest er nur Variablen, die er selbst setzt oder
#         loescht (S-1); die Konfiguration, die git selbst aus der Umgebung liest, ist davon nicht erfasst (GP-B7 des
#         Pruefmittels).
#   EB-3  Gleiche Eingabe, gleiche Ausgabe: zwei Laeufe ueber denselben Baum ergeben dieselbe Standard- und Fehlerausgabe
#         und denselben Rueckgabewert, auch bei anderer Spracheinstellung des Aufrufers (P-10) und bei gesetzten
#         git-Variablen des Aufrufers (GIT_DIR, GIT_ALTERNATE_OBJECT_DIRECTORIES, GIT_GLOB_PATHSPECS,
#         GIT_NOGLOB_PATHSPECS, GIT_LITERAL_PATHSPECS; ST-G0-08, ST-G0-25; GIT_ICASE_PATHSPECS ist ebenfalls geloescht,
#         hat aber keine beobachtbare Wirkung: GP-B10 des Pruefmittels).
#   EB-4  Laufzeit ohne quadratischen Anstieg mit der Laenge eines Absatzes (P-11).
#
# GRENZEN (einzeln, mit Kennung; Durchlass: ein falscher Verweis bleibt ohne Fund; Fehlalarm: ein richtiger wird gemeldet)
# Die Liste ist NICHT vollstaendig (siehe Schlussausgabe); jede Grenze hat im Pruefmittel einen Fall.
#   GB-01 (Durchlass) Verweise ausserhalb von Rueckwaertsakzenten werden nicht erfasst.
#   GB-02 (Durchlass) Ein Verweis, der ueber zwei Zeilen laeuft, wird nicht erfasst.
#   GB-03 (Durchlass) Ein Kandidat mit Leerzeichen, etwa der Pfadteil eines Shell-Befehls, wird nicht als Pfad
#         geprueft.
#   GB-04 (Durchlass) Kandidaten mit den Ausschlusszeichen und -formen (Anfuehrungszeichen, $ = * < > { } @, "...",
#         dem Auslassungszeichen als einem Zeichen, "://", fuehrendes / oder ~, Anfang blob/ oder tree/) werden nicht als
#         Pfad geprueft, auch wenn sie einen fehlenden Pfad nennen.
#   GB-05 (Fehlalarm) Ein Platzhalter ohne Ausschlusszeichen (etwa NNNN in einem Dateinamen) wird als Pfad geprueft.
#   GB-06 (Durchlass; Fehlalarm) Als Zweigname gelten nur claude/, origin/ und fix/ mit letztem Segment ohne Endung
#         (Durchlass); release/ mit drei Segmenten wird nicht erkannt (Fehlalarm).
#   GB-07 (Durchlass) Das erste Segment valITino gilt als Repository-Verweis und wird nicht als Pfad geprueft.
#   GB-08 (Durchlass) Ein Punkt im ersten Segment ausser an erster Stelle gilt als Rechnername, auch bei einem
#         Verzeichnis, das besteht.
#   GB-09 (Durchlass) Das Muster Inhaber/Repository (zwei Segmente, erstes nicht im eigenen Baum, zweites ohne Punkt)
#         nimmt auch echte Pfade aus.
#   GB-10 (Durchlass) Ohne Schraegstrich werden nur Makefile, CLAUDE.md, README.md, CONTRIBUTING.md und .gitignore
#         geprueft.
#   GB-11 (Durchlass) Regel a: Ein Erzeugnis- oder Abhaengigkeitsverzeichnis als Pfadsegment macht einen Verweis nie
#         zum Fund.
#   GB-12 (Durchlass) Pruefung 5: Das Wort ADR im Absatz nimmt Klammer- und Abschnittsform aus; eine Tabelle ohne
#         Leerzeile gilt als ein Absatz.
#   GB-13 (Durchlass) Pruefung 5: Eine eigene Ueberschrift der nennenden Datei mit der Nummer nimmt Klammer- und
#         Abschnittsform aus.
#   GB-14 (Durchlass) Pruefung 5: Die Abschnittsform eines Unterabschnitts wird an ihren ersten beiden Stufen
#         geprueft, die Klammerform eines Unterabschnitts gar nicht.
#   GB-15 (Durchlass) Eine Ausnahme datei|wert deckt auch ein zweites, falsches Vorkommen desselben Werts in derselben
#         Datei.
#   GB-16 (Durchlass) Pruefung 2: Kurzformen und Hexzeichen in Grossschreibung werden nicht geprueft.
#   GB-17 (Durchlass) Pruefung 2: Zweigverweise mit einem anderen Zweignamen als main hinter blob/ oder tree/ sind
#         kein Fund.
#   GB-18 (Durchlass) Pruefung 2: Ein Commit gilt als bekannt, solange sein Objekt lokal vorliegt, auch wenn er
#         unerreichbar ist.
#   GB-19 (Durchlass) Pruefung 3: Eine Kennung mit mehr als drei Ziffern wird an den ersten drei geprueft.
#   GB-20 (Durchlass) Pruefung 3: Geprueft wird das Vorhandensein der Kennung als Ueberschrift, nicht ihre Geltung
#         (O-18); eine gestrichene Anforderung gilt als vorhanden.
#   GB-21 (Durchlass) Pruefung 3: Die Referenzmenge besteht aus allen Ueberschriften des Backlogs, auch denen in
#         Codebloecken.
#   GB-22 (Durchlass) Ein Verweisziel gilt als vorhanden, wenn es im Arbeitsbaum liegt, auch unversioniert.
#   GB-23 (Fehlalarm) Archivstand fest: Ein Pfad, der nur in einem spaeteren Stand des Zweigs besteht, ist ein Fund;
#         eine Nachfuehrung des Zweigs ist eine Aenderung an diesem Pruefer mit Fall.
#   GB-24 (Fehlalarm) Zaeune in Zitatbloecken oder mit mehr als drei Leerzeichen Einzug werden nicht erkannt, ihr
#         Inhalt wird geprueft.
#   GB-25 (Eigenschaft) Eine Ausnahme gilt fuer jede Pruefungsart am Fundort; Pruefung 7 meldet eine unbekannte
#         Kennung zusaetzlich zu Pruefung 3.
#   GB-26 (Durchlass) Pruefung 6: Derselbe Name zweimal in einer Liste ist kein eigener Fund.
#   GB-27 (Fehlalarm) Pruefungen 6 und 7: Ein YAML-Kommentar hinter einem Namen oder Wert wird nicht als Kommentar
#         erkannt; der Eintrag gilt als Formabweichung (skill-form beziehungsweise skill-anforderung).
#   GB-28 (Fehlalarm) Regel b gilt am wurzelrelativ bereinigten Pfad; ein Verweis, der erst verzeichnisrelativ in
#         backend/, frontend/, deploy/ oder prototype/ fuehrt, wird geprueft, auch solange der Baum fehlt.
#   GB-29 (Durchlass; Fehlalarm) Pruefungen 6 und 7: Eine UTF-8-Bytefolge (BOM) vor der ersten Zeile aus drei
#         Bindestrichen wird nicht uebergangen; eine Rollendatei gilt als ohne Frontmatter und bleibt ohne Befund
#         (Durchlass), eine SKILL.md ergibt skill-anforderung "fehlt" (Fehlalarm).
#   GB-30 (Durchlass; Fehlalarm) Zeilenenden nur aus Wagenruecklauf werden nicht erkannt (uebergangen wird nur ein
#         Wagenruecklauf vor dem Zeilenvorschub); die Datei gilt als eine Zeile, das Frontmatter als nicht vorhanden:
#         Rollendatei ohne Befund (Durchlass), SKILL.md skill-anforderung "fehlt" (Fehlalarm).
#   GB-31 (Durchlass) Pruefung 5: Die Referenzmenge des Projektauftrags und die eigenen Ueberschriften der nennenden Datei
#         (GB-13) werden aus dem Rohtext gebildet, auch aus Codebloecken; eine Nummer, die nur dort als Ueberschrift steht,
#         gilt als vorhanden.
#   GB-32 (Eigenschaft) Dateinamen mit Zeilenumbruch (git ls-files -z laesst sie zu) brechen die
#         Ausgabeform: "Befunde: n" zaehlt die Funde, nicht die Zeilen unter "Funde vollstaendig"; der Rueckgabewert
#         bleibt 2, es gibt kein falsches Gruen.
#   GB-33 (Eigenschaft) Der Pruefer zieht keine eigene Zeitgrenze; sie liegt beim Aufrufer, im DoD-Gate bei dessen
#         Zeitgrenzen.
#   GB-34 (Durchlass) Zur Pruefflaeche gehoeren nur Namen auf .md in Kleinschreibung; .MD, .Md und .markdown nicht.
#   GB-35 (Fehlalarm) Regel d mit Praefix r3cosint/: Nach dem Abtrennen des Praefixes gilt Regel b nicht; ein Verweis
#         unter r3cosint/backend/, r3cosint/frontend/, r3cosint/deploy/ oder r3cosint/prototype/ ist ein Fund, solange der
#         Baum fehlt.
#   GB-36 (Durchlass) Pruefung 2: Eine Folge von 40 Hexzeichen, an die ein Wortzeichen grenzt (Buchstabe, Ziffer oder
#         Unterstrich), wird nicht geprueft; die Wortgrenze haelt laengere Hexfolgen fern (B-025). Eine Pruefsumme in
#         Unterstrichen wie bei einer Hervorhebung oder mit einem Buchstaben unmittelbar davor bleibt ohne Fund.

set -uo pipefail

# P-10 (G0.1, B2): Der Pruefer setzt die Spracheinstellung fuer sich selbst. Sortierung der Ausgabe,
# Zeichenklassen und Wortgrenzen der Pruefsummenpruefung haengen sonst von der Spracheinstellung des
# Aufrufers ab; gleiche Eingabe, gleiche Ausgabe (5.4).
export LC_ALL=C

BACKLOG="docs/05_Product_Backlog.md"
PROJEKTAUFTRAG="docs/00_Projektauftrag.md"
AUSNAHMEDATEI="scripts/belege-ausnahmen.txt"
# Fester Stand (S-2): Kopf des Zweigs archiv/r3coscrum seit der Nachfuehrung in Einheit D5. Ueber ihn loest der
# Pruefer Repo B auf (S-4); eine Nachfuehrung des Zweigs ist eine Aenderung an dieser Konstante mit Fall (GB-23).
ARCHIVSTAND="78bcef984583e665edb28f0f2e7ef8f1da0a87dc"
PRUEFFLAECHE_ERE='^([^/]+\.md|docs/.*\.md|\.claude/.*\.md)$'
# Quellen der Pruefungen 6 und 7 (Punkt 3): Rollendateien und Skills mit genau einer Verzeichnisebene
ROLLEN_ERE='^\.claude/agents/[^/]+\.md$'
SKILLS_ERE='^\.claude/skills/[^/]+/SKILL\.md$'

# --- LAGE C (Rueckgabewert 3): vor jedem Urteil, in fester Reihenfolge (G0, 1d) ------------------------
# KC-01 Werkzeuge, KC-02 Git-Arbeitsbaum, KC-03 flacher Klon, KC-04 Teilklon, KC-05 Archivstand,
# KC-06 bis KC-08 Bezugsdokumente und Ausnahmeliste, KC-09 und KC-10 Referenzmengen, KC-11 Pruefflaeche. M5: nach KC-01
# loescht der Lauf die git-Variablen des Aufrufers; nach KC-04 (auch Fernquelle mit promisor) folgt KC-12 (alternates);
# KC-11 tritt auch beim Lesen im Hauptteil ein.
# Bei zwei Maengeln meldet der Lauf den ersten der Reihenfolge. Je Meldung: Kennung, Text und, wo 1d
# einen nennt, der Beschaffungsweg. Der Teilklon steht vor dem Archivstand und vor jedem cat-file auf
# eine unbekannte Pruefsumme: in einem Teilklon laedt git fehlende Objekte beim Zugriff nach (Abruf
# bei der Fernquelle, "fatal" auf der Fehlerausgabe).
# --- Pruefmittel, die keine Werkzeuge sind: Lage C vor jeder Verwendung -------
# Befund der unabhaengigen Pruefung vom 2026-09-01 (Protocol Master auf einem
# anderen Modell als die Umsetzung), vom Koordinator gegen die Dateien und
# gegen einen isolierten Lauf nachgeprueft:
#
# ADR 0002 Abschnitt 6.8.3, die D20-Zeile der Objekttabelle und das
# D20-Kriterium in docs/06 nannten diese drei Dateien als Pruefmittel, deren
# Fehlen Lage C ergibt. Geprueft hat es niemand — weder dieses Skript noch das
# Makefile-Ziel "belege". Gemessen: "set -uo pipefail" ohne "-e" laesst
# "mapfile" ueber eine fehlende Datei mit Rueckgabewert 0 laufen; die
# Referenzmenge bleibt leer, und danach gilt jede gueltige Anforderungskennung
# im ganzen Bestand als ungueltig. Der Schritt waere rot mit hunderten
# Scheinfunden statt der einen richtigen Aussage "das Pruefmittel fehlt" —
# genau der Fehlermodus, den 6.8.3 als vermieden beschreibt.
#
# Der Massstab ist die geschaerfte Lage C (ADR 0002, Abschnitt 6.9): ein
# Pruefmittel fehlt ODER traegt die Aussage nicht. Fuer die beiden
# Bezugsdokumente gilt beides — die Datei muss lesbar sein UND eine nicht
# leere Referenzmenge hergeben; eine vorhandene, aber aussagelose Datei ist
# derselbe Ausfall wie eine fehlende. Fuer die Ausnahmeliste gilt nur der
# erste Teil: eine vorhandene Liste ohne Eintraege ist ein zulaessiger Zustand
# (es gibt dann keine Ausnahmen), eine fehlende dagegen laesst jede begruendete
# Ausnahme stumm wegfallen und faelscht das Ergebnis in die andere Richtung.
lage_c() { # lage_c <kennung> <meldung> [<beschaffungsweg>]
  echo "belege-pruefen.sh: LAGE C -- $1: $2" >&2
  if [ $# -ge 3 ]; then echo "belege-pruefen.sh: Beschaffen: $3" >&2; fi
  echo "Der Bestand besteht fort, die Pruefung faellt aus. Rueckgabewert 3 und" >&2
  echo "nicht 2: ein ausgefallenes Pruefmittel ist kein Befund am Bestand." >&2
  exit 3
}

# Hat ein Segment des Pfads (relativ zur Wurzel, die Datei selbst eingeschlossen) eine symbolische Verknuepfung? Jedes
# Segment wird einzeln mit -L geprueft, keines wird verfolgt (M5, ST-G0-01, P-5). Zerlegt wird mit Parametererweiterung
# statt mit read, damit auch ein Name mit Zeilenumbruch ganz geprueft wird.
weg_verknuepft() { # weg_verknuepft <pfad>
  local rest="$1" acc="" seg
  while [ -n "$rest" ]; do
    case "$rest" in
      */*) seg="${rest%%/*}"; rest="${rest#*/}" ;;
      *) seg="$rest"; rest="" ;;
    esac
    [ -n "$seg" ] || continue
    acc="${acc:+$acc/}$seg"
    if [ -L "$acc" ]; then return 0; fi
  done
  return 1
}

# Lage C beim Lesen (KC-11, M5, ST-G0-03): Endet awk oder ein grep-Auszug beim Lesen einer Datei der Pruefflaeche mit einem
# Rueckgabewert, der kein "Treffer oder keiner" ist, traegt die Aussage ueber diese Datei nicht. Der Lauf endet dann,
# bevor er ein Urteil ausgibt; ein Fehlschlag wird nie zu "kein Fund".
lesefehler() { # lesefehler <werkzeug> <datei> <rueckgabewert>
  lage_c "prueflaeche" "Lesefehler: $1 endete mit Rueckgabewert $3 beim Lesen der Datei $2; ohne diesen Auszug ist kein Urteil moeglich." "Leserecht der Datei herstellen; endet das Werkzeug weiter ungleich 0, es pruefen"
}

# KC-01 Werkzeuge (P-2): die geschlossene Liste ist gleich den Befehlen, die dieses Skript aufruft; was
# fehlt, ist Lage C. Wer einen weiteren Befehl aufruft, nimmt ihn hier auf. Fall B-207 sichert nur, dass der Grundfall keinen
# weiteren Befehl aufruft; die uebrigen Zweige prueft der Static Software Tester am Code (P-2).
WERKZEUGE="git grep awk sort dirname"
for w in $WERKZEUGE; do
  command -v "$w" >/dev/null 2>&1 || lage_c "werkzeug:$w" "Werkzeug '$w' fehlt im Suchpfad." "Werkzeug installieren"
done

# Vor dem ersten git-Aufruf loescht der Pruefer die git-eigenen Variablen des Aufrufers, die Gegenstand,
# Objektspeicher oder die Deutung von Pfadangaben verlegen (M5, ST-G0-08): die Liste von
# .claude/hooks/session-start-git-historie.sh, dazu GIT_DISCOVERY_ACROSS_FILESYSTEM, die vier Pfadangabe-Variablen
# GIT_GLOB_PATHSPECS, GIT_NOGLOB_PATHSPECS, GIT_LITERAL_PATHSPECS und GIT_ICASE_PATHSPECS (M5c, ST-G0-25) und alle
# Variablen, deren Name mit GIT_TRACE beginnt. Sonst loest eine fremde Pruefsumme auf
# (GIT_ALTERNATE_OBJECT_DIRECTORIES), der Lauf urteilt ueber ein anderes Repository als das am Arbeitsverzeichnis
# (GIT_DIR), oder der Aufruf zur Pruefflaeche (git ls-files, Pfadangabe '*.md') liefert nur die Wurzeldateien
# (GIT_GLOB_PATHSPECS) beziehungsweise keine Datei (GIT_LITERAL_PATHSPECS, GIT_NOGLOB_PATHSPECS). Die
# GIT_CONFIG_*-Variablen bleiben (Konfiguration, kein Gegenstand); die Pruefung auf eine Fernquelle mit promisor
# (KC-04) liest sie mit.
unset GIT_DIR GIT_WORK_TREE GIT_INDEX_FILE GIT_COMMON_DIR GIT_OBJECT_DIRECTORY GIT_ALTERNATE_OBJECT_DIRECTORIES GIT_NAMESPACE GIT_CEILING_DIRECTORIES GIT_SHALLOW_FILE GIT_DISCOVERY_ACROSS_FILESYSTEM GIT_GLOB_PATHSPECS GIT_NOGLOB_PATHSPECS GIT_LITERAL_PATHSPECS GIT_ICASE_PATHSPECS 2>/dev/null || true
unset "${!GIT_TRACE@}" 2>/dev/null || true
# Ersatzobjekte unter refs/replace/ gelten nicht (M5b, SA-M4-02): sonst liesse eine Ersatzreferenz fuer den Archivstand
# dessen Baum auf den Baum eines anderen Commits zeigen, und ein Pfad, den der Archivstand nicht hat, loeste auf
# (gemessen mit B-306 am Pruefer nach M5).
export GIT_NO_REPLACE_OBJECTS=1

# KC-02 Git-Arbeitsbaum (P-1): vorher Rueckgabewert 2, jetzt Lage C
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || REPO_ROOT=""
[ -n "$REPO_ROOT" ] || lage_c "git-arbeitsbaum" "kein Git-Arbeitsbaum am aktuellen Arbeitsverzeichnis."
cd "$REPO_ROOT" 2>/dev/null || lage_c "git-arbeitsbaum" "Wurzel des Arbeitsbaums nicht erreichbar: $REPO_ROOT"

# KC-03 flacher Klon (P-9)
FLACH="$(git rev-parse --is-shallow-repository 2>/dev/null)" || FLACH="unbekannt"
case "$FLACH" in
  false) ;;
  true) lage_c "git-historie" "flacher Klon: die vollstaendige Historie fehlt." "git fetch --unshallow" ;;
  *) lage_c "git-historie" "ob die Historie vollstaendig ist, laesst sich nicht ermitteln." "git fetch --unshallow" ;;
esac

# KC-04 Teilklon (P-9): extensions.partialclone gesetzt, gleich welche Formatversion (fail-closed). M5 (ST-G0-07): auch eine
# Fernquelle mit promisor wahr (Schluessel remote.<name>.promisor) in jeder Konfigurationsebene: git laedt dann
# fehlende Objekte beim Zugriff nach (Netzzugriff, Schreiben in den Objektspeicher), und eine fremde Fernquelle liesse
# Pruefsummen aufloesen.
git config --local --get extensions.partialclone >/dev/null 2>&1
TEILKLON_RC=$?
case "$TEILKLON_RC" in
  1) ;;
  0) lage_c "git-teilklon" "Teilklon (extensions.partialclone gesetzt): Objekte koennen fehlen und wuerden beim Zugriff nachgeladen." "vollstaendigen Klon anlegen (git clone ohne --filter)" ;;
  *) lage_c "git-teilklon" "ob ein Teilklon vorliegt, laesst sich nicht ermitteln (git config endete mit $TEILKLON_RC)." "vollstaendigen Klon anlegen (git clone ohne --filter)" ;;
esac
PROMISOR_AUS="$(git config --bool --get-regexp '^remote\..*\.promisor$' 2>/dev/null)"
PROMISOR_RC=$?
case "$PROMISOR_RC" in
  1) ;;
  0)
    while IFS= read -r PROMISOR_ZEILE; do
      case "${PROMISOR_ZEILE##* }" in
        true) lage_c "git-teilklon" "Teilklon (Fernquelle mit promisor wahr: ${PROMISOR_ZEILE% *}): Objekte koennen fehlen und wuerden beim Zugriff nachgeladen." "vollstaendigen Klon anlegen (git clone ohne --filter)" ;;
      esac
    done <<< "$PROMISOR_AUS"
    ;;
  *) lage_c "git-teilklon" "ob eine Fernquelle mit promisor besteht, laesst sich nicht ermitteln (git config endete mit $PROMISOR_RC)." "vollstaendigen Klon anlegen (git clone ohne --filter)" ;;
esac

# KC-12 Objektspeicher ohne fremde Quelle (M5, ST-G0-08): objects/info/alternates mit Inhalt laesst Pruefsummen und
# Objekte aus einem anderen Objektspeicher aufloesen, ausserhalb des Repositories. Den Pfad liefert git (--git-path),
# damit auch ein .git als Datei (gitdir:-Verweis, verknuepfter Arbeitsbaum) trifft. Vorhanden und leer ist kein Lage C.
# Steht nach KC-04 und vor KC-05, weil schon die Abfrage des Archivstands ueber eine fremde Quelle aufloesen koennte.
ALT_PFAD="$(git rev-parse --git-path objects/info/alternates 2>/dev/null)" || ALT_PFAD=""
[ -n "$ALT_PFAD" ] || lage_c "git-alternates" "ob der Objektspeicher fremde Quellen nennt, laesst sich nicht ermitteln." "git repack -a -d, danach objects/info/alternates entfernen"
if [ -s "$ALT_PFAD" ]; then
  lage_c "git-alternates" "der Objektspeicher nennt fremde Quellen (objects/info/alternates mit Inhalt): Pruefsummen und Objekte koennten dort aufloesen." "git repack -a -d, danach objects/info/alternates entfernen"
fi

# KC-05 Archivstand (S-3): der feste Commit muss im eigenen Objektspeicher vorliegen; ueber ihn loest der Pruefer Repo
# B auf (S-4)
git cat-file -e "${ARCHIVSTAND}^{commit}" 2>/dev/null \
  || lage_c "archivstand" "der Commit $ARCHIVSTAND (Kopf des Zweigs archiv/r3coscrum) liegt im eigenen Objektspeicher nicht vor." \
       "git fetch origin +refs/heads/archiv/r3coscrum:refs/remotes/origin/archiv/r3coscrum"

# KC-06 bis KC-08 Bezugsdokumente und Ausnahmeliste. M5 (ST-G0-01 a, b): Vor jedem anderen Zugriff auf die Datei wird jedes
# Segment ihres Pfads mit -L geprueft; eine Verknuepfung, auf der Datei oder auf einem Verzeichnis davor, liesse den
# Pruefer ihr Ziel lesen, auch ausserhalb des Repositories, und ist Lage C mit der Kennung der Datei.
for pruefmittel in "$BACKLOG" "$PROJEKTAUFTRAG" "$AUSNAHMEDATEI"; do
  if weg_verknuepft "$pruefmittel"; then
    lage_c "$pruefmittel" "Pruefmittel oder ein Verzeichnis auf seinem Weg ist eine symbolische Verknuepfung (gelesen wuerde ihr Ziel)." "bei Verknuepfung: durch die Datei selbst ersetzen"
  fi
  [ -f "$pruefmittel" ] || lage_c "$pruefmittel" "Pruefmittel fehlt."
  [ -r "$pruefmittel" ] || lage_c "$pruefmittel" "Pruefmittel nicht lesbar."
done

# KC-09 und KC-10 Referenzmengen: die Datei ist da, traegt die Aussage aber nicht
mapfile -t BACKLOG_IDS < <(grep -oE '^#{1,6}[[:space:]]+R3-[A-Z]-[0-9]{3}' "$BACKLOG" | grep -oE 'R3-[A-Z]-[0-9]{3}' | sort -u)
[ "${#BACKLOG_IDS[@]}" -gt 0 ] || lage_c "referenzmenge-backlog" "$BACKLOG traegt keine einzige Anforderungskennung als Ueberschrift."
mapfile -t PA_ABSCHNITTE < <(grep -oE '^#{1,6}[[:space:]]+[0-9]+\.[0-9]+' "$PROJEKTAUFTRAG" | grep -oE '[0-9]+\.[0-9]+' | sort -u)
[ "${#PA_ABSCHNITTE[@]}" -gt 0 ] || lage_c "referenzmenge-projektauftrag" "$PROJEKTAUFTRAG traegt keine einzige Abschnittsnummer als Ueberschrift."

# KC-11 Pruefflaeche ermittelbar und lesbar (P-3): versionierte Markdown-Dateien der Wurzel, unter docs/ und
# unter .claude/ (rekursiv), NUL-getrennt (git ls-files -z: auch Namen mit Nicht-ASCII-Zeichen). Scheitert
# git ls-files, ist die Pruefflaeche nicht ermittelbar: Lage C und nicht eine leere Liste. Die Markierung
# kann kein Dateiname sein (die Abfrage liefert nur Namen auf .md).
LS_MARKE="git-ls-files-fehlgeschlagen"
LS_OK=1
DATEIEN=()
while IFS= read -r -d '' f; do
  if [ "$f" = "$LS_MARKE" ]; then LS_OK=0; continue; fi
  if [[ "$f" =~ $PRUEFFLAECHE_ERE ]]; then DATEIEN+=("$f"); fi
done < <(git ls-files -z -- '*.md' 2>/dev/null || printf '%s\0' "$LS_MARKE")
[ "$LS_OK" = 1 ] || lage_c "prueflaeche" "die Pruefflaeche (git ls-files) laesst sich nicht ermitteln."
for f in "${DATEIEN[@]+"${DATEIEN[@]}"}"; do
  # M5 (ST-G0-01 c): eine Verknuepfung auf irgendeinem Segment des Pfads gilt wie eine Verknuepfung der Datei selbst
  # (Befund pfad-verknuepfung im Hauptteil, nicht gelesen, kein Lage C)
  weg_verknuepft "$f" && continue
  [ -f "$f" ] || lage_c "prueflaeche" "versionierte Markdown-Datei fehlt im Arbeitsbaum: $f" "Datei wiederherstellen oder die Loeschung mit git rm uebernehmen"
  [ -r "$f" ] || lage_c "prueflaeche" "versionierte Markdown-Datei nicht lesbar: $f" "Leserecht der Datei herstellen"
done


BEFUNDE_ANZAHL=0
declare -A ART_ANZAHL=()
FINDINGS_LISTE=()

# --- Codebloecke ausblenden, Zeilennummern erhalten (P-4) ---------------------------------------------
# Zaeune: mindestens drei Rueckwaertsakzente oder drei Tilden, bis zu drei Leerzeichen Einzug (ein Tabulator
# oder vier Leerzeichen machen aus der Zeile keinen Zaun). Ein Block schliesst nur mit einem Zaun desselben
# Zeichens, mindestens so lang wie der oeffnende, danach nur Leerraum. Ein Zaun, der bis zum Dateiende offen
# bleibt, ist ein Befund (codeblock-offen, Zeile des oeffnenden Zauns, Wert die Zaunzeichen). Das Programm
# kommt ohne Intervallausdruecke aus (mawk). M5 (ST-G0-05): Ein Zaun aus Rueckwaertsakzenten, dessen Sprachangabe einen
# Rueckwaertsakzent enthaelt, ist nach CommonMark kein Zaun und blendet nichts aus (Tilden: unveraendert). Modus text:
# jede Zeile eines Blocks und jeder Zaun wird geleert (die Zeile bleibt, die Nummern bleiben); Modus offen: Zeile und
# Zaunzeichen eines offenen Zauns.
BLENDEN_AWK='
{
  s = $0
  n = 0
  while (n < 4 && substr(s, n + 1, 1) == " ") n++
  zaun = ""
  zlen = 0
  rest = ""
  if (n <= 3) {
    c = substr(s, n + 1, 1)
    if (c == "`" || c == "~") {
      k = 0
      while (substr(s, n + k + 1, 1) == c) k++
      if (k >= 3) { zaun = c; zlen = k; rest = substr(s, n + k + 1) }
      if (zaun == "`" && index(rest, "`") > 0) { zaun = ""; zlen = 0; rest = "" }
    }
  }
  if (infence) {
    if (zaun == fz && zlen >= fl && rest ~ /^[[:space:]]*$/) infence = 0
    if (modus == "text") print ""
    next
  }
  if (zaun != "") {
    infence = 1; fz = zaun; fl = zlen; fzeile = NR
    if (modus == "text") print ""
    next
  }
  if (modus == "text") print s
}
END {
  if (modus == "offen" && infence) {
    z = ""
    for (i = 0; i < fl; i++) z = z fz
    print fzeile "\t" z
  }
}
'
# Jede Datei geht mit vorangestelltem ./ an awk (M5, ST-G0-02): sonst gilt ein Name der Form bezeichner=wert.md als
# Variablenzuweisung, und die Datei bliebe ungelesen. Ein Name mit fuehrendem Bindestrich liest awk hinter dem
# Programmtext nie als Option, sondern als Datei (ST-G0-29, gemessen); er braucht das ./ nicht, es schadet ihm nicht.
blenden() { awk -v modus=text "$BLENDEN_AWK" "./$1"; }
zaun_offen() { awk -v modus=offen "$BLENDEN_AWK" "./$1"; }

# --- Frontmatter der Rollen- und Skill-Dateien lesen (Punkt 3; Pruefungen 6 und 7) ---------------------------------
# Rohtext (nicht ausgeblendet), ein Programm je Datei. Ausgabe je Zeile: Zeile, Tabulator, Typ, Tabulator, Wert. Typen:
# frontmatter, skill-form, skill-anforderung (fertige Befunde mit ihrem Wert), name (ein gueltig geformter Name aus
# skills:, dessen SKILL.md der Aufrufer prueft) und kennung (eine Kennung aus anforderung:, die der Aufrufer gegen die
# Referenzmenge prueft). Das Frontmatter liegt vor, wenn Zeile 1 genau "---" ist (ein Wagenruecklauf am Zeilenende wird
# uebergangen) und endet an der naechsten Zeile genau "---"; fehlt sie, ist das allein der Befund frontmatter (OF-3,
# OF-11). Ein Schluessel zweimal ist allein der Befund an seiner zweiten Zeile (OF-12). Modus rolle: Feld skills:
# (F4: Kandidat ist jede Zeile, die nach Leerzeichen oder Tabulatoren mit einem Bindestrich beginnt; Leerzeilen und
# Kommentarzeilen werden uebergangen und beenden die Liste nicht; die Liste endet an der ersten anderen nicht leeren Zeile;
# ein leerer Wert (Eintrag ohne Namen, leere anforderung) wird als "leer" gemeldet). Modus skill: Feld
# metadata.anforderung. Ohne Intervallausdruecke (mawk); das einfache Anfuehrungszeichen steht als \047, weil das
# Programm in einfachen Anfuehrungszeichen steht.
FRONTMATTER_AWK='
function trim(s) {
  sub(/^[ \t]+/, "", s)
  sub(/[ \t]+$/, "", s)
  return s
}
function entquoten(s,   n, a) {
  s = trim(s)
  n = length(s)
  if (n >= 2) {
    a = substr(s, 1, 1)
    if ((a == "\"" || a == "\047") && substr(s, n, 1) == a) s = trim(substr(s, 2, n - 2))
  }
  return s
}
function leerwert(s) {
  return (s == "" ? "leer" : s)
}
function eintrag(i, z,   lead, rest, name) {
  match(z, /^[ \t]*-/)
  lead = substr(z, 1, RLENGTH - 1)
  rest = substr(z, RLENGTH + 1)
  if (lead ~ /^ *$/ && rest ~ /^[ \t]/) {
    name = entquoten(rest)
    if (name ~ /^[a-z0-9]+(-[a-z0-9]+)*$/) print i "\tname\t" name
    else print i "\tskill-form\t" leerwert(name)
  } else {
    print i "\tskill-form\t" leerwert(trim(rest))
  }
}
function rolle(bis,   i, n, kz, k2, rest, anz, z) {
  n = 0; kz = 0; k2 = 0
  for (i = 2; i <= bis; i++) {
    if (substr(L[i], 1, 7) == "skills:") {
      n++
      if (n == 1) kz = i
      else if (n == 2) k2 = i
    }
  }
  if (n == 0) return
  if (n >= 2) { print k2 "\tskill-form\tskills doppelt"; return }
  rest = trim(substr(L[kz], 8))
  if (rest != "") { print kz "\tskill-form\t" rest; return }
  anz = 0
  for (i = kz + 1; i <= bis; i++) {
    z = L[i]
    if (z ~ /^[ \t]*$/) continue
    if (z ~ /^[ \t]*#/) continue
    if (z !~ /^[ \t]*-/) break
    anz++
    eintrag(i, z)
  }
  if (anz == 0) print kz "\tskill-form\tleer"
}
function skill(bis,   i, nm, m1, m2, na, a1, a2, z, v) {
  nm = 0; na = 0; m1 = 0; m2 = 0; a1 = 0; a2 = 0
  for (i = 2; i <= bis; i++) {
    if (L[i] ~ /^metadata:[ \t]*$/) {
      nm++
      if (nm == 1) m1 = i
      else if (nm == 2) m2 = i
    }
  }
  if (nm == 0) { print 1 "\tskill-anforderung\tfehlt"; return }
  if (nm >= 2) { print m2 "\tskill-anforderung\tmetadata doppelt"; return }
  for (i = m1 + 1; i <= bis; i++) {
    z = L[i]
    if (z ~ /^[ \t]*$/) continue
    if (z ~ /^[ \t]*#/) continue
    if (z !~ /^[ \t]/) break
    if (z ~ /^[ \t]+anforderung:/) {
      na++
      if (na == 1) a1 = i
      else if (na == 2) a2 = i
    }
  }
  if (na == 0) { print 1 "\tskill-anforderung\tfehlt"; return }
  if (na >= 2) { print a2 "\tskill-anforderung\tanforderung doppelt"; return }
  v = L[a1]
  sub(/^[ \t]+anforderung:/, "", v)
  v = entquoten(v)
  if (v == "") print a1 "\tskill-anforderung\tleer"
  else if (v ~ /^R3-[A-Z]-[0-9][0-9][0-9]$/) print a1 "\tkennung\t" v
  else print a1 "\tskill-anforderung\t" v
}
{ sub(/\r$/, ""); L[NR] = $0 }
END {
  if (NR == 0 || L[1] != "---") {
    if (modus == "skill") print 1 "\tskill-anforderung\tfehlt"
    exit
  }
  ende = 0
  for (i = 2; i <= NR; i++) {
    if (L[i] == "---") { ende = i; break }
  }
  if (ende == 0) { print 1 "\tfrontmatter\tnicht geschlossen"; exit }
  if (modus == "rolle") rolle(ende - 1)
  else skill(ende - 1)
}
'
frontmatter_lesen() { awk -v modus="$1" "$FRONTMATTER_AWK" "./$2"; }

# --- Ausnahmeliste laden (6.8.5; P-7, P-8) -------------------------------------------------------------
# Je Zeile: Schluessel, Tabulator, Grund. Leerzeilen und Zeilen mit # am Anfang werden uebergangen und mitgezaehlt.
declare -A AUSNAHME_GRUND=()
declare -A AUSNAHME_BENUTZT=()
AE_ZN=(); AE_WERT=(); AE_GRUND=(); AE_FORM=()
zn=0
while IFS= read -r zeile || [ -n "$zeile" ]; do
  zn=$((zn+1))
  [ -z "$zeile" ] && continue
  case "$zeile" in \#*) continue ;; esac
  if [[ "$zeile" == *$'\t'* ]]; then wert="${zeile%%$'\t'*}"; grund="${zeile#*$'\t'}"; else wert="$zeile"; grund=""; fi
  # Schluesselformen: "datei:zeile" und "datei|wert"; eine andere Form ist selbst ein Befund (ausnahme-form).
  # Die Zeilennummer hat keine Obergrenze (Befund der Nachpruefung vom 2026-09-01).
  form=0
  if [[ "$wert" == *'|'* ]] || [[ "$wert" =~ ^[^|]+:[0-9]+$ ]]; then form=1; fi
  AE_ZN+=("$zn"); AE_WERT+=("$wert"); AE_GRUND+=("$grund"); AE_FORM+=("$form")
  if [ -n "$wert" ]; then AUSNAHME_GRUND["$wert"]="$grund"; fi
done < "$AUSNAHMEDATEI"

# BLOCKIERENDER BEFUND der Nachpruefung vom 2026-09-01, hier behoben:
# Ausnahmen waren als blosser TEXTWERT eingetragen. Damit unterdrueckte eine
# einzige Zeile jedes kuenftige Vorkommen desselben Wortlauts im GANZEN
# Bestand -- auch einen echten neuen Fehler. Ausgefuehrt belegt an zwei
# eingebauten Faellen ("docs/06" und "R3-C-020" an frischer Stelle: kein Fund).
# Das Skript kannte das Risiko: Fuer blob/main war der Schluessel bereits
# ortsgebunden, mit genau dieser Begruendung im Kopfkommentar -- die Loesung
# war nur auf eine von vier Kategorien angewandt.
# Damit war die Fehlerklasse, gegen die dieses Skript gebaut ist, in das
# Skript selbst gewandert: Eine Ausnahme mit richtigem historischem Grund
# wurde faktisch zu einer Aussage ueber alle kuenftigen Vorkommen.
# Jetzt ist jeder Schluessel ortsgebunden, und die zu breite Form laesst sich
# nicht mehr hinschreiben:
#   "datei:zeile"  -- genau dieser Fundort, jeder Wert dort
#   "datei|wert"   -- dieser Wert in dieser Datei, zeilenunabhaengig
# Ein Schluessel in einer anderen Form ist selbst ein Befund
# (Art "ausnahme-form"). Was bleibt: Ein zweites, echt falsches Vorkommen
# DESSELBEN Wertes in DERSELBEN Datei wird von einer "datei|wert"-Ausnahme
# weiterhin gedeckt. Das ist die verbleibende Luecke, und sie steht auch in
# der Schlussausgabe jedes Laufs.
# P-8: ist_ausgenommen prueft beide Schluessel und vermerkt jeden passenden als benutzt; eine Ausnahme, die im
# Lauf keinen Fund deckt, ist veraltet (am Ende des Laufs, gleich welcher Schluesselform).
ist_ausgenommen() {
  local datei="$1" zeile="$2" wert="$3" k1 k2 treffer=1
  k1="$datei:$zeile"
  k2="$datei|$wert"
  if [ -n "${AUSNAHME_GRUND["$k1"]+x}" ]; then AUSNAHME_BENUTZT["$k1"]=1; treffer=0; fi
  if [ -n "${AUSNAHME_GRUND["$k2"]+x}" ]; then AUSNAHME_BENUTZT["$k2"]=1; treffer=0; fi
  return "$treffer"
}

melden_roh() { # datei zeile art wert: ohne Ausnahmepruefung
  local datei="$1" zeile="$2" art="$3" wert="$4"
  FINDINGS_LISTE+=("$datei:$zeile"$'\t'"$art"$'\t'"$wert")
  ART_ANZAHL["$art"]=$(( ${ART_ANZAHL["$art"]:-0} + 1 ))
  BEFUNDE_ANZAHL=$((BEFUNDE_ANZAHL+1))
}

melden() { # datei zeile art wert
  if ist_ausgenommen "$1" "$2" "$4"; then
    return 0
  fi
  melden_roh "$1" "$2" "$3" "$4"
}

# P-3: eine leere Pruefflaeche ist ein Befund (6.8.3, Grund 1); gemeldet ohne Ausnahmepruefung (OF-1)
if [ "${#DATEIEN[@]}" -eq 0 ]; then
  melden_roh "-" 0 "bestand-leer" "prueflaeche-leer"
fi

# --- Referenzmengen (gelesen im Lage-C-Block) ---
ist_backlog_id() {
  local id="$1" k
  for k in "${BACKLOG_IDS[@]}"; do [ "$k" = "$id" ] && return 0; done
  return 1
}
ist_pa_abschnitt() {
  local a="$1" k
  for k in "${PA_ABSCHNITTE[@]}"; do [ "$k" = "$a" ] && return 0; done
  return 1
}

# --- Pfade (P-5, P-6) -----------------------------------------------------------------------------------
# Lexikalische Bereinigung ohne Dateizugriff: "." und leere Segmente (doppelte Schraegstriche) entfallen, ".."
# hebt das vorige Segment auf. Ergebnis in BEREINIGT; Rueckgabewert 1, wenn der Pfad die Wurzel verlaesst.
bereinigen() {
  local seg
  local -a segs=()
  BEREINIGT=""
  IFS='/' read -ra segs <<< "$1"
  for seg in "${segs[@]+"${segs[@]}"}"; do
    case "$seg" in
      ''|.) ;;
      ..)
        if [ -z "$BEREINIGT" ]; then return 1; fi
        case "$BEREINIGT" in
          */*) BEREINIGT="${BEREINIGT%/*}" ;;
          *) BEREINIGT="" ;;
        esac
        ;;
      *) BEREINIGT="${BEREINIGT:+$BEREINIGT/}$seg" ;;
    esac
  done
  return 0
}

# Art eines bereinigten Pfads (relativ zur Wurzel, ohne ".."): datei, verzeichnis, verknuepfung (ein Teilpfad ist
# eine symbolische Verknuepfung; sie wird nie verfolgt) oder fehlt.
pfad_art() {
  local p="$1" acc="" seg
  local -a segs=()
  PF_ART=fehlt
  if [ -z "$p" ]; then PF_ART=verzeichnis; return 0; fi
  IFS='/' read -ra segs <<< "$p"
  for seg in "${segs[@]}"; do
    acc="${acc:+$acc/}$seg"
    if [ -L "$REPO_ROOT/$acc" ]; then PF_ART=verknuepfung; return 0; fi
  done
  if [ -f "$REPO_ROOT/$p" ]; then PF_ART=datei
  elif [ -d "$REPO_ROOT/$p" ]; then PF_ART=verzeichnis
  fi
  return 0
}

# Aufloesung wie bisher (root- ODER verzeichnisrelativ zur nennenden Datei), jeder Kandidat lexikalisch bereinigt;
# verlaesst er die Wurzel, gilt er als nicht vorhanden, ohne Dateizugriff. Setzt AUF_ART (datei, verzeichnis,
# verknuepfung, fehlt) und AUFGELOEST. Ein vorhandener Kandidat ohne Verknuepfung geht vor einem Kandidaten mit.
pfad_aufloesen() { # pfad_aufloesen <pfad> <bezugdir>
  local p="$1" bezug="$2" k verkn=0
  local -a kand=("$p")
  if [ -n "$bezug" ] && [ "$bezug" != "." ]; then kand+=("$bezug/$p"); fi
  AUF_ART=fehlt
  AUFGELOEST=""
  for k in "${kand[@]}"; do
    bereinigen "$k" || continue
    pfad_art "$BEREINIGT"
    case "$PF_ART" in
      datei|verzeichnis) AUF_ART="$PF_ART"; AUFGELOEST="$BEREINIGT"; return 0 ;;
      verknuepfung) verkn=1 ;;
    esac
  done
  if [ "$verkn" = 1 ]; then AUF_ART=verknuepfung; fi
  return 0
}

# Zeilenanhang (P-6): N mindestens 1, N hoechstens M, das Groessere hoechstens die Zeilenzahl. Zahlen mit mehr als
# 9 Stellen (ohne fuehrende Nullen) gelten als groesser als jede Zeilenzahl (kein Ueberlauf des Vergleichs); scheitert
# ein Vergleich, ist der Anhang unzulaessig (fail-closed). Die Zeilenzahl liefert der Aufrufer: eine Datei des
# Arbeitsbaums oder ein Blob des Archivstands (S-4).
zeilen_ok() { # zeilen_ok <zeilenzahl> <n> <m>
  local anz="$1" n="$2" m="$3"
  if [[ "$n" =~ ^0*([0-9]+)$ ]]; then n="${BASH_REMATCH[1]}"; fi
  if [ -n "$m" ] && [[ "$m" =~ ^0*([0-9]+)$ ]]; then m="${BASH_REMATCH[1]}"; fi
  if [ "${#n}" -gt 9 ] || [ "${#m}" -gt 9 ]; then return 1; fi
  [ "$n" -ge 1 ] 2>/dev/null || return 1
  if [ -n "$m" ]; then
    [ "$n" -le "$m" ] 2>/dev/null || return 1
    [ "$m" -le "$anz" ] 2>/dev/null || return 1
  else
    [ "$n" -le "$anz" ] 2>/dev/null || return 1
  fi
  return 0
}

# Ein Pfad gegen die eigene Wurzel (Pruefung 4) mit seinem Zeilenanhang (Pruefung 1).
pruefe_in_wurzel() { # <datei> <zl> <pfad> <bezugdir> <pfadwert> <kandidat> <n> <m>
  local datei="$1" zl="$2" pfad="$3" bezug="$4" pfadwert="$5" kandidat="$6" n="$7" m="$8" anz
  pfad_aufloesen "$pfad" "$bezug"
  case "$AUF_ART" in
    fehlt) melden "$datei" "$zl" "pfad" "$pfadwert" ;;
    verknuepfung) melden "$datei" "$zl" "pfad-verknuepfung" "$pfadwert" ;;
    verzeichnis) if [ -n "$n" ]; then melden "$datei" "$zl" "zeile" "$kandidat"; fi ;;
    datei)
      if [ -n "$n" ]; then
        # "wc -l" zaehlt Zeilenumbrueche, nicht Zeilen: einer Datei ohne abschliessenden Umbruch fehlt die letzte Zeile.
        # "awk END{print NR+0}" zaehlt sie mit und liefert 0 fuer die leere Datei (Befund der statischen Pruefung vom
        # 2026-09-01).
        anz="$(awk 'END{print NR+0}' "$REPO_ROOT/$AUFGELOEST")"
        zeilen_ok "$anz" "$n" "$m" || melden "$datei" "$zl" "zeile" "$kandidat"
      fi
      ;;
  esac
  return 0
}

# Ein Pfad im Baum des Archivstands (Regel c; Regel d mit Praefix r3coscrum/) mit seinem Zeilenanhang (S-4). Der Pfad ist
# schon lexikalisch bereinigt und relativ zur Wurzel des Archivbaums (P-12: das erste Segment entscheidet an der
# bereinigten Fassung; was die Wurzel verlaesst, kommt hier nicht an). git cat-file -t liefert blob (Datei) oder tree
# (Verzeichnis); jeder andere Ausgang ist ein Fund pfad. Ein Zeilenanhang gilt nur an einem Blob, an einem Baum ist er
# ein Fund zeile; die Zeilenzahl eines Blobs zaehlt awk wie in Pruefung 1, die Zahlenregeln sind dieselben (zeilen_ok).
pruefe_im_archiv() { # <datei> <zl> <pfad> <pfadwert> <kandidat> <n> <m>
  local datei="$1" zl="$2" pfad="$3" pfadwert="$4" kandidat="$5" n="$6" m="$7" art anz
  if [ -z "$pfad" ]; then
    art=tree
  else
    art="$(git cat-file -t "${ARCHIVSTAND}:${pfad}" 2>/dev/null)" || art=""
  fi
  case "$art" in
    tree) if [ -n "$n" ]; then melden "$datei" "$zl" "zeile" "$kandidat"; fi ;;
    blob)
      if [ -n "$n" ]; then
        anz="$(git cat-file blob "${ARCHIVSTAND}:${pfad}" 2>/dev/null | awk 'END{print NR+0}')"
        zeilen_ok "$anz" "$n" "$m" || melden "$datei" "$zl" "zeile" "$kandidat"
      fi
      ;;
    *) melden "$datei" "$zl" "pfad" "$pfadwert" ;;
  esac
  return 0
}

ist_pfadartig() {
  local c="$1" erster rest
  case "$c" in
    *' '*) return 1 ;;
    *'://'*) return 1 ;;
    /*) return 1 ;;
    '~'*) return 1 ;;
    *'"'*|*"'"*|*'$'*|*'='*) return 1 ;;
    *'*'*|*'<'*|*'>'*|*'{'*|*'}'*|*'...'*|*'…'*) return 1 ;;
    *'@'*) return 1 ;;
    blob/*|tree/*) return 1 ;;
  esac
  case "$c" in
    */*)
      erster="${c%%/*}"
      # Befund der Nachpruefung vom 2026-09-01: Diese drei Namen wurden
      # unbesehen als Git-Referenz behandelt; ein echter, kaputter Pfad wie
      # "claude/nicht-vorhanden.md" blieb damit unsichtbar. Jetzt gilt die
      # Ausnahme nur, wenn das letzte Segment KEINE Dateiendung traegt --
      # Zweignamen tragen keine.
      case "$erster" in
        claude|origin|fix)
          case "${c##*/}" in
            *.*) : ;;
            *) return 1 ;;
          esac
          ;;
      esac
      [ "$erster" = "valITino" ] && return 1
      case "$erster" in
        .|..) : ;;
        ?*.*) return 1 ;;
      esac
      rest="${c#*/}"
      case "$rest" in
        */*) : ;;
        *)
          case "$erster" in
            .claude|.github|docs|scripts|prototype|backend|frontend|deploy) : ;;
            *)
              case "$rest" in
                *.*) : ;;
                *) return 1 ;;
              esac
              ;;
          esac
          ;;
      esac
      return 0
      ;;
    Makefile|CLAUDE.md|README.md|CONTRIBUTING.md|.gitignore) return 0 ;;
  esac
  return 1
}

ist_erzeugnisverzeichnis() {
  local p="$1" seg
  local IFS='/'
  local -a segs
  read -ra segs <<< "$p"
  for seg in "${segs[@]+"${segs[@]}"}"; do
    case "$seg" in
      node_modules|.venv|dist|build|__pycache__|.pytest_cache|.mypy_cache) return 0 ;;
    esac
  done
  return 1
}

git_hat_commit() { # Pruefung 2: nur der eigene Objektspeicher (S-4); er enthaelt die Objekte des Archivstands
  git cat-file -e "${1}^{commit}" 2>/dev/null
}

# Auszug aus dem ausgeblendeten Text (INHALT) fuer die Pruefungen 2 bis 5 (M5, ST-G0-03): grep endet mit 0 (Treffer) oder 1
# (keiner); jeder andere Rueckgabewert ist ein Lesefehler und Lage C. Das Ergebnis steht in AUSZUG.
auszug_holen() { # auszug_holen <datei> <ere>
  local rc
  AUSZUG="$(printf '%s\n' "$INHALT" | grep -noE "$2")"
  rc=$?
  if [ "$rc" -gt 1 ]; then lesefehler grep "$1" "$rc"; fi
  return 0
}

for DATEI in "${DATEIEN[@]+"${DATEIEN[@]}"}"; do
  # P-5: eine Datei der Pruefflaeche, die eine symbolische Verknuepfung ist oder unter einem verknuepften Verzeichnis liegt,
  # wird nicht gelesen (OF-2, M5 ST-G0-01 c): Datei:0, Wert der Pfad, wie git ihn fuehrt
  if weg_verknuepft "$DATEI"; then
    melden "$DATEI" 0 "pfad-verknuepfung" "$DATEI"
    continue
  fi
  # M5 (ST-G0-03): endet awk oder ein grep-Auszug beim Lesen mit einem Fehler, ist das Lage C (KC-11), nie "kein Fund"
  INHALT="$(blenden "$DATEI")" || lesefehler awk "$DATEI" "$?"
  BEZUGDIR="$(dirname -- "$DATEI")"

  # P-4: ein bis zum Dateiende offener Zaun ist ein Befund (OF-4)
  OFFEN="$(zaun_offen "$DATEI")" || lesefehler awk "$DATEI" "$?"
  if [ -n "$OFFEN" ]; then
    melden "$DATEI" "${OFFEN%%$'\t'*}" "codeblock-offen" "${OFFEN#*$'\t'}"
  fi

  # --- Prüfung 4: Pfadverweise (mit optionalem Prüfung-1-Zeilenanhang) ---
  auszug_holen "$DATEI" '`[^`]+`'
  while IFS=: read -r ZL ROH; do
    [ -z "${ZL:-}" ] && continue
    KANDIDAT="${ROH#\`}"
    KANDIDAT="${KANDIDAT%\`}"
    PFADTEIL="$KANDIDAT"
    ANHANG_N=""
    ANHANG_M=""
    if [[ "$KANDIDAT" =~ ^(.*):([0-9]+)(-([0-9]+))?$ ]]; then
      PFADTEIL="${BASH_REMATCH[1]}"
      ANHANG_N="${BASH_REMATCH[2]}"
      ANHANG_M="${BASH_REMATCH[4]}"
    fi

    ist_pfadartig "$PFADTEIL" || continue

    # P-12: die Regeln a bis d entscheiden am wurzelrelativ lexikalisch bereinigten Pfad (P-5), Regel a an dessen
    # Segmenten, die Regeln b bis d an dessen erstem Segment. Verlaesst der Pfad die Wurzel, bleibt das erste Segment leer
    # (keine der Regeln b bis d greift, der Pfad geht an Pruefung 4 und P-5) und Regel a faellt auf den Pfad wie
    # geschrieben zurueck. Die Pfadform (ist_pfadartig) gilt weiter fuer den Pfad wie geschrieben. Ein Verweis, der erst
    # verzeichnisrelativ in einen der vier Baeume fuehrt (../backend/x aus docs/), faellt nicht unter Regel b (GB-28).
    if bereinigen "$PFADTEIL"; then
      WZ_PFAD="$BEREINIGT"
      ERSTES_SEGMENT="${WZ_PFAD%%/*}"
    else
      WZ_PFAD="$PFADTEIL"
      ERSTES_SEGMENT=""
    fi

    ist_erzeugnisverzeichnis "$WZ_PFAD" && continue

    # Regel b) Noch nicht gebaute Bäume — kein Fund, solange sie fehlen. P-5: eine Verknuepfung als oberstes
    # Verzeichnis ist ein Befund (die Probe folgt ihr nicht), weder Scharfschaltung noch Ausnahme von der Pruefung.
    case "$ERSTES_SEGMENT" in
      backend|frontend|deploy|prototype)
        if [ -L "$REPO_ROOT/$ERSTES_SEGMENT" ]; then
          melden "$DATEI" "$ZL" "pfad-verknuepfung" "$PFADTEIL"
          continue
        fi
        [ ! -d "$REPO_ROOT/$ERSTES_SEGMENT" ] && continue
        ;;
    esac

    # Regel c) Pfade des Methodik-Repositories (Repo B): im Baum des Archivstands (S-4), am bereinigten Pfad (P-12).
    case "$ERSTES_SEGMENT" in
      methodik|nachweise|sprints)
        pruefe_im_archiv "$DATEI" "$ZL" "$WZ_PFAD" "$PFADTEIL" "$KANDIDAT" "$ANHANG_N" "$ANHANG_M"
        continue
        ;;
    esac

    # Regel d) Pfade mit vorangestelltem Repository-Namen. Der Name ist Teil der Aussage, nicht des Pfades; er
    # wird abgetrennt und der Rest im genannten Baum geprueft. r3cosint/: gegen die eigene Wurzel wie Pruefung 4
    # und 1 (P-6); r3coscrum/: im Baum des Archivstands wie unter c).
    case "$ERSTES_SEGMENT" in
      r3cosint|r3coscrum)
        REST_PFAD="${WZ_PFAD#*/}"
        [ "$REST_PFAD" = "$WZ_PFAD" ] && REST_PFAD=""
        if [ "$ERSTES_SEGMENT" = r3cosint ]; then
          pruefe_in_wurzel "$DATEI" "$ZL" "$REST_PFAD" "" "$PFADTEIL" "$KANDIDAT" "$ANHANG_N" "$ANHANG_M"
        else
          pruefe_im_archiv "$DATEI" "$ZL" "$REST_PFAD" "$PFADTEIL" "$KANDIDAT" "$ANHANG_N" "$ANHANG_M"
        fi
        continue
        ;;
    esac

    pruefe_in_wurzel "$DATEI" "$ZL" "$PFADTEIL" "$BEZUGDIR" "$PFADTEIL" "$KANDIDAT" "$ANHANG_N" "$ANHANG_M"
  done < <(printf '%s\n' "$AUSZUG")

  # --- Prüfung 3: Anforderungskennungen ---
  auszug_holen "$DATEI" 'R3-[A-Z]-[0-9]{3}'
  while IFS=: read -r ZL WERT; do
    [ -z "${ZL:-}" ] && continue
    if ! ist_backlog_id "$WERT"; then
      melden "$DATEI" "$ZL" "anforderung" "$WERT"
    fi
  done < <(printf '%s\n' "$AUSZUG")

  # --- Prüfung 2: Commit-Prüfsummen (gegen dieses Repository UND Repo B) ---
  auszug_holen "$DATEI" '\b[0-9a-f]{40}\b'
  while IFS=: read -r ZL WERT; do
    [ -z "${ZL:-}" ] && continue
    if ! git_hat_commit "$WERT"; then
      melden "$DATEI" "$ZL" "commit" "$WERT"
    fi
  done < <(printf '%s\n' "$AUSZUG")

  auszug_holen "$DATEI" '(blob|tree)/main'
  while IFS=: read -r ZL WERT; do
    [ -z "${ZL:-}" ] && continue
    melden "$DATEI" "$ZL" "blob-tree-verweis" "$WERT"
  done < <(printf '%s\n' "$AUSZUG")
  # --- Prüfung 5: Abschnitte des Projektauftrags ---
  # Absatzweise vorberechnen, ob irgendwo im selben Absatz (Text zwischen
  # zwei Leerzeilen; eine Tabelle ohne Leerzeile zwischen den Zeilen zählt
  # als ein Absatz) das Wort "ADR" steht — nicht nur in derselben Zeile,
  # weil weiche Zeilenumbrüche und Tabellenzeilen "ADR 0002" oft einige
  # Zeilen vor der eigentlichen Abschnittsangabe nennen.
  # P-11: je Absatz nur das Merkmal, ob das Wort ADR vorkommt, Zeile fuer Zeile gesetzt (vorher wurden die Zeilen
  # eines Absatzes verkettet und fuer jede Zeile neu durchsucht: Laufzeit mit dem Quadrat der Absatzlaenge). Gleiche
  # Bedeutung: ADR kann keine Zeilengrenze ueberspannen, die Verkettung trennte die Zeilen mit einem Leerzeichen.
  mapfile -t ADR_ABSATZ < <(printf '%s\n' "$INHALT" | awk '
    BEGIN { para = 1 }
    {
      if ($0 ~ /^[[:space:]]*$/) { para++; next }
      linepara[NR] = para
      if ($0 ~ /(^|[^A-Za-z])ADR([^A-Za-z]|$)/) adr[para] = 1
    }
    END {
      for (l = 1; l <= NR; l++) {
        p = (l in linepara) ? linepara[l] : 0
        print ((p in adr) ? 1 : 0)
      }
    }
  ')

  # Zusaetzlich: eigene Gliederung der nennenden Datei selbst (jede Datei mit
  # eigener N.M-Gliederung, heute vor allem die ADRs). Deckt die Faelle ab, in denen
  # eine Zeile INNERHALB der ADR auf einen eigenen Abschnitt verweist, ohne
  # "ADR" zu nennen — z. B. eine Tabellenzeile der Definition-of-Done-Kette
  # in ADR 0002 selbst ("Abschnitt 3.5 verlangt diesen Schritt …"), wo das
  # ganze Wort "ADR" nirgends im Absatz fällt, weil die Zugehörigkeit zum
  # Dokument selbstverständlich ist. Das ist eine Ergänzung zur vorgegebenen
  # Absatzregel, keine Ersetzung: Ein erster Lauf nur mit der Absatzregel
  # meldete diese Fälle noch als Fund (siehe Übergabe an den Koordinator).
  mapfile -t EIGENE_ABSCHNITTE < <(grep -oE '^#{1,6}[[:space:]]+[0-9]+\.[0-9]+' -- "$DATEI" | grep -oE '[0-9]+\.[0-9]+' | sort -u)
  ist_eigener_abschnitt() {
    local a="$1" k
    for k in "${EIGENE_ABSCHNITTE[@]+"${EIGENE_ABSCHNITTE[@]}"}"; do [ "$k" = "$a" ] && return 0; done
    return 1
  }

  auszug_holen "$DATEI" '\([0-9]+\.[0-9]+\)|Abschnitt[[:space:]]+[0-9]+\.[0-9]+|Projektauftrag[[:space:]]+[0-9]+\.[0-9]+'
  while IFS=: read -r ZL TREFFER; do
    [ -z "${ZL:-}" ] && continue
    N=$(printf '%s' "$TREFFER" | grep -oE '[0-9]+\.[0-9]+')
    case "$TREFFER" in
      Projektauftrag*)
        if ! ist_pa_abschnitt "$N"; then
          melden "$DATEI" "$ZL" "abschnitt" "$N"
        fi
        ;;
      *)
        if [ "${ADR_ABSATZ[$((ZL-1))]:-0}" != "1" ] && ! ist_eigener_abschnitt "$N"; then
          if ! ist_pa_abschnitt "$N"; then
            melden "$DATEI" "$ZL" "abschnitt" "$N"
          fi
        fi
        ;;
    esac
  done < <(printf '%s\n' "$AUSZUG")

  # --- Pruefungen 6 und 7: Frontmatter der Rollen- und der Skill-Dateien (Punkt 3), Rohtext ---
  # Pruefung 6 (Rollendateien): jeder Name im Feld skills: braucht .claude/skills/<name>/SKILL.md als regulaere Datei
  # (Existenzregel von Pruefung 4; eine Verknuepfung auf dem Weg ist pfad-verknuepfung, Wert der Pfad, P-5), sonst
  # Befund skill. Pruefung 7 (Skills): genau eine Kennung unter metadata.anforderung, die im Backlog steht; die
  # Meldung von Pruefung 3 an derselben Zeile kommt dazu (GB-25). Alle Meldungen gehen ueber melden (Ausnahmen, 6.8.5).
  ART67=""
  if [[ "$DATEI" =~ $ROLLEN_ERE ]]; then
    ART67=rolle
  elif [[ "$DATEI" =~ $SKILLS_ERE ]]; then
    ART67=skill
  fi
  if [ -n "$ART67" ]; then
    FM_AUS="$(frontmatter_lesen "$ART67" "$DATEI")" || lesefehler awk "$DATEI" "$?"
    while IFS=$'\t' read -r ZL TYP WERT; do
      [ -z "${ZL:-}" ] && continue
      case "$TYP" in
        frontmatter|skill-form|skill-anforderung)
          melden "$DATEI" "$ZL" "$TYP" "$WERT"
          ;;
        name)
          pfad_art ".claude/skills/$WERT/SKILL.md"
          case "$PF_ART" in
            datei) ;;
            verknuepfung) melden "$DATEI" "$ZL" "pfad-verknuepfung" ".claude/skills/$WERT/SKILL.md" ;;
            *) melden "$DATEI" "$ZL" "skill" "$WERT" ;;
          esac
          ;;
        kennung)
          if ! ist_backlog_id "$WERT"; then
            melden "$DATEI" "$ZL" "skill-anforderung" "$WERT"
          fi
          ;;
      esac
    done < <(printf '%s\n' "$FM_AUS")
  fi

done

# --- Ausnahmeliste: die Pflichtpruefungen je Eintrag (6.8.5; P-7, P-8) ---
# Je Eintrag hoechstens ein Befund, in der Rangfolge ausnahme-form, ausnahme-ohne-grund, ausnahme-veraltet. Fundort ist
# die Zeile der Liste, Wert der ganze Schluessel (OF-8); gemeldet ohne Ausnahmepruefung. Ein Grund braucht ein Zeichen
# ausser Leerraum (P-7). Veraltet ist ein Eintrag, der im Lauf keinen Fund gedeckt hat, gleich welcher Schluesselform.
n_ae=${#AE_ZN[@]}
i_ae=0
while [ "$i_ae" -lt "$n_ae" ]; do
  w_ae="${AE_WERT[$i_ae]}"
  if [ "${AE_FORM[$i_ae]}" != 1 ]; then
    melden_roh "$AUSNAHMEDATEI" "${AE_ZN[$i_ae]}" "ausnahme-form" "$w_ae"
  elif ! [[ "${AE_GRUND[$i_ae]}" =~ [^[:space:]] ]]; then
    melden_roh "$AUSNAHMEDATEI" "${AE_ZN[$i_ae]}" "ausnahme-ohne-grund" "$w_ae"
  elif [ -z "${AUSNAHME_BENUTZT["$w_ae"]+x}" ]; then
    melden_roh "$AUSNAHMEDATEI" "${AE_ZN[$i_ae]}" "ausnahme-veraltet" "$w_ae"
  fi
  i_ae=$((i_ae+1))
done

echo "=== Funde nach Prüfungsart ==="
if [ "${#ART_ANZAHL[@]}" -gt 0 ]; then
  for art in "${!ART_ANZAHL[@]}"; do
    printf '%s\t%d\n' "$art" "${ART_ANZAHL[$art]}"
  done | sort
else
  echo "(keine)"
fi

echo "=== Funde vollständig ==="
for zeile in "${FINDINGS_LISTE[@]+"${FINDINGS_LISTE[@]}"}"; do
  printf '%s\n' "$zeile"
done

echo "---"
echo "belege-pruefen.sh: geprueft sind Fundorte in sieben Pruefungen (1 Zeile, 2 Commit, 3 Anforderung, 4 Pfad, 5 Abschnitt des Projektauftrags, 6 Skill der Rolle, 7 Anforderung im Skill)."
echo "NICHT geprüft: ob der Inhalt an diesem Fundort die Behauptung trägt, die ihm zugeschrieben wird."
echo "ACHTUNG: Diese Liste der Grenzen ist NICHT vollstaendig. Drei adversarische"
echo "Pruefrunden haben je eine weitere gefunden, die hier nicht stand -- jedes Mal"
echo "in der Schicht, die die vorherige Behebung erst erreichbar gemacht hatte."
echo "Wer diesem Lauf vertraut, vertraut einem Werkzeug, dessen Selbstauskunft"
echo "dreimal unvollstaendig war. Der Rueckgabewert 0 heisst: nichts von dem"
echo "gefunden, was hier aufgezaehlt ist -- nicht: nichts vorhanden."
echo "Bisher benannte Grenzen (je Kennung im Kopfkommentar, Abschnitt GRENZEN):"
echo '  - GB-01 Verweise ausserhalb von Rückwärtsakzenten werden nicht erfasst.'
echo '  - GB-02 Ein Verweis über zwei Zeilen wird nicht erfasst.'
echo '  - GB-03 Ein Kandidat mit Leerzeichen (Pfadteil eines Shell-Befehls) wird nicht als Pfad geprüft.'
echo '  - GB-04 Kandidaten mit Ausschlusszeichen und -formen (Anfuehrungszeichen, $ = * < > { } @, ..., das Auslassungszeichen, ://, fuehrendes / oder ~, blob/ und tree/ am Anfang) werden nicht als Pfad geprueft.'
echo '  - GB-05 Ein Platzhalter ohne Ausschlusszeichen (etwa NNNN im Dateinamen) wird als Pfad geprüft (Fehlalarm).'
echo '  - GB-06 Zweignamen: nur claude/, origin/ und fix/ mit letztem Segment ohne Endung gelten nicht als Pfad; release/a/b wird geprüft (Fehlalarm).'
echo '  - GB-07 Das erste Segment valITino gilt als Repository-Verweis, nicht als Pfad.'
echo '  - GB-08 Ein Punkt im ersten Segment (ausser an erster Stelle) gilt als Rechnername, auch bei einem echten Pfad.'
echo '  - GB-09 Das Muster Inhaber/Repository (zwei Segmente, erstes nicht im eigenen Baum, zweites ohne Punkt) nimmt auch echte Pfade aus.'
echo '  - GB-10 Ohne Schrägstrich werden nur Makefile, CLAUDE.md, README.md, CONTRIBUTING.md und .gitignore geprüft.'
echo '  - GB-11 Ein Erzeugnis- oder Abhängigkeitsverzeichnis als Pfadsegment ist nie ein Fund.'
echo '  - GB-12 Prüfung 5: Das Wort ADR im Absatz nimmt Klammer- und Abschnittsform aus; eine Tabelle ohne Leerzeile gilt als ein Absatz.'
echo '  - GB-13 Prüfung 5: Eine eigene Überschrift der nennenden Datei mit der Nummer nimmt Klammer- und Abschnittsform aus.'
echo '  - GB-14 Prüfung 5: Die Abschnittsform eines Unterabschnitts wird an ihren ersten beiden Stufen geprüft, die Klammerform gar nicht.'
echo '  - GB-15 Eine Ausnahme datei|wert deckt auch ein zweites, falsches Vorkommen desselben Werts in derselben Datei.'
echo '  - GB-16 Prüfung 2: Kurzformen und Hexzeichen in Grossschreibung werden nicht geprüft.'
echo '  - GB-17 Prüfung 2: Zweigverweise mit anderem Zweignamen als main hinter blob/ oder tree/ sind kein Fund.'
echo '  - GB-18 Prüfung 2: Ein Commit gilt als bekannt, solange sein Objekt lokal vorliegt, auch unerreichbar.'
echo '  - GB-19 Prüfung 3: Eine Kennung mit mehr als drei Ziffern wird an den ersten drei geprüft.'
echo '  - GB-20 Prüfung 3: Geprüft wird das Vorhandensein der Kennung als Überschrift, nicht ihre Geltung.'
echo '  - GB-21 Prüfung 3: Die Referenzmenge besteht aus allen Überschriften des Backlogs, auch denen in Codeblöcken.'
echo '  - GB-22 Ein Verweisziel gilt als vorhanden, wenn es im Arbeitsbaum liegt, auch unversioniert.'
echo '  - GB-23 Archivstand fest: Ein Pfad, der nur in einem späteren Stand des Zweigs besteht, ist ein Fund (Fehlalarm).'
echo '  - GB-24 Zäune in Zitatblöcken oder mit mehr als drei Leerzeichen Einzug werden nicht erkannt, ihr Inhalt wird geprüft (Fehlalarm).'
echo '  - GB-25 Eine Ausnahme gilt für jede Prüfungsart am Fundort; Prüfung 7 meldet eine unbekannte Kennung zusätzlich zu Prüfung 3.'
echo '  - GB-26 Prüfung 6: Derselbe Name zweimal in einer Liste ist kein eigener Fund.'
echo '  - GB-27 Prüfungen 6 und 7: Ein YAML-Kommentar hinter einem Namen oder Wert gilt als Formabweichung (Fehlalarm).'
echo '  - GB-28 Regel b gilt am wurzelrelativ bereinigten Pfad; ein erst verzeichnisrelativ in einen der vier Bäume führender Verweis wird geprüft (Fehlalarm).'
echo '  - GB-29 Prüfungen 6 und 7: Eine UTF-8-Bytefolge (BOM) vor dem Frontmatter wird nicht übergangen (Rollendatei: Durchlass; SKILL.md: Fehlalarm).'
echo '  - GB-30 Zeilenenden nur aus Wagenrücklauf werden nicht erkannt, die Datei gilt als eine Zeile (Rollendatei: Durchlass; SKILL.md: Fehlalarm).'
echo '  - GB-31 Pruefung 5: Die Referenzmenge des Projektauftrags und die eigenen Ueberschriften der nennenden Datei werden aus dem Rohtext gebildet, auch aus Codebloecken (Durchlass).'
echo '  - GB-32 Dateinamen mit Zeilenumbruch brechen die Ausgabeform: "Befunde: n" zaehlt die Funde, nicht die Zeilen unter "Funde vollstaendig"; der Rueckgabewert bleibt 2.'
echo '  - GB-33 Der Pruefer zieht keine eigene Zeitgrenze; sie liegt beim Aufrufer.'
echo '  - GB-34 Zur Pruefflaeche gehoeren nur Namen auf .md in Kleinschreibung; .MD, .Md und .markdown nicht (Durchlass).'
echo '  - GB-35 Regel d mit Praefix r3cosint/: Nach dem Abtrennen des Praefixes gilt Regel b nicht; ein Verweis unter r3cosint/backend/, r3cosint/frontend/, r3cosint/deploy/ oder r3cosint/prototype/ ist ein Fund, solange der Baum fehlt (Fehlalarm).'
echo '  - GB-36 Pruefung 2: Eine Folge von 40 Hexzeichen, an die ein Wortzeichen grenzt (Buchstabe, Ziffer oder Unterstrich), wird nicht geprueft (Durchlass).'
echo "Repo B (r3coscrum): aufgelöst über den Archivstand $ARCHIVSTAND (Zweig archiv/r3coscrum)"
echo "Befunde: $BEFUNDE_ANZAHL"

if [ "$BEFUNDE_ANZAHL" -gt 0 ]; then
  exit 2
fi
exit 0

