# Übergabe 2026-09-22 — Weisung aktenkundig: R3-Q-010 freigegeben, Schnitt bestätigt, Lesart zu 3.4 und zu R1; gitleaks dauerhaft als Starthook bereitgestellt

Arbeitseinheit auf Weisung des Auftraggebers vom 2026-09-22, als Aufgabe #2
geführt (O-23, Entscheid E-H). Arbeitszweig `claude/awesome-knuth-blvzpb` in
beiden Repositories, aufgesetzt auf den Commits `7c08a3268e707112af9c802eddb7c61975754593`
und `e5bab959aa4886eefc7983ce23916bbd798d8a83` (Produkt-Repository) sowie
`36716456ccc2af7a7363b98ec537886b2fea1f4c` (Methodik-Repository) der Einheit
vom 2026-09-21; die Pull Requests dieser beiden Einheiten sind nicht eröffnet
und nicht gemergt.

## Die Weisung im Wortlaut

Zwei Nachrichten des Auftraggebers in der Sitzung vom 2026-09-22 (zweiter
Formweg aus ADR 0002, Abschnitt 10: Anweisung an die Sitzung mit exaktem
Wortlaut):

1. "Umfang von R3-Q-010 freigegeben, Schnitt E4.1 bis E4.3 bestätigt. Zur
   Frage nach 3.4 gilt die Lesart des Koordinators: kein Abbruch. Nächste
   Einheit: E4.1 bauen. Zu C: Das, was richtig ist und Sinn macht."
2. "gitleaks permanent einbauen bitte." — verbunden mit der Frage, ob gemergt
   werden muss, damit weitergearbeitet werden kann, oder ob der Merge noch nicht
   relevant ist.

"C" bezeichnet den dritten Entscheidpunkt aus dem Bericht des Koordinators vom
2026-09-21: die Lesart von R1 der Definition of Ready für Einträge mit
benanntem Stakeholder, deren Abstimmung erst mit der Freigabe durch den
Auftraggeber eintritt (Backlog, offener Punkt 19). Mit "Das, was richtig ist
und Sinn macht" ist der Entscheid an den Koordinator delegiert — dieselbe Form
wie bei O-27 am 2026-09-07 (V17 im Methodik-Repository).

## Ergebnis in einem Absatz

Die vier Entscheide der Weisung sind aktenkundig: die Freigabe des Umfangs von
R3-Q-010 und die Bestätigung des Schnitts E4.1 bis E4.3 in ADR 0002, 6.13
(Status-Block, Buchstabe g, Schlussabsatz, Kopfzeile, Abschnitt 9), im Backlog
(offener Punkt 18 erledigt, Stand-Vermerk in R3-Q-010, siebte Nachführung) und
in `CLAUDE.md`; die Lesart des Koordinators zur Zählfrage nach 3.4 als
bestätigt in dieser Übergabe und als V18 im Methodik-Repository; die
delegierte Lesart zu R1 als Entscheid des Koordinators in
`docs/06_Definition_of_Ready_und_Done.md` (Kriterienzeile R1, Fortschreibungstabelle),
im Backlog (offener Punkt 19 erledigt, Punkt 15 ergänzt) und als V19 im
Methodik-Repository. Die dauerhafte Bereitstellung von `gitleaks` ist als
versionierter `SessionStart`-Hook `.claude/hooks/session-start-gitleaks.sh`
gebaut, in `.claude/settings.json` eingetragen und in der Hook-Regel, in
`CLAUDE.md`, in ADR 0002 (Abschnitt 10, E-E, Nachtrag) und im Nachweiserzeuger
nachgeführt; Bau durch den SecDevOps Engineer, statische und dynamische
Verifikation durch die beiden Prüferrollen auf einem anderen Modell
(Ergebnis unten). An E4 ist nichts gebaut: keine Zeile an den beiden
`PreToolUse`-Gates, keine am `Makefile`; die Änderung an `.claude/settings.json`
betrifft allein den Starthook. Nächste Einheit nach Weisung: E4.1.

## Entscheidungen dieser Einheit

1. **Lesart zu 3.4 — bestätigt, kein Abbruch.** Der Static Software Tester
   hatte in der Einheit vom 2026-09-21 die Zählfrage vorgelegt, ob ein viermal
   gemeldeter Punkt (`UEBERGABE.md` im Methodik-Repository) "dieselbe Prüfung
   dreimal am gleichen Kriterium" ist. Die Lesart des Koordinators — die ersten
   beiden Meldungen betrafen einen planmässig späteren Schritt, der die
   Commit-Prüfsumme voraussetzt und vor dem Commit nicht ausführbar war; die
   beiden letzten zwei berichtigte Sätze dieser Übergabe — gilt auf Weisung.
   Verallgemeinert als V18: 3.4 zählt Fehlschläge einer Prüfung am Gegenstand,
   nicht Wiederholungen einer Meldung über einen Schritt, der zum Prüfzeitpunkt
   noch nicht ausführbar war. Die Einheit vom 2026-09-21 gilt damit als
   ordentlich abgeschlossen, nicht als nach 3.4 abgebrochen. Was diese Lesart
   nicht ändert: Ein Schritt, der zum Prüfzeitpunkt ausführbar war und dreimal
   als offen gemeldet wird, bleibt ein dreimaliges Scheitern.
2. **Lesart zu R1 (Punkt C) — festhalten, kein Eintrag verlässt die Summe.**
   Entschieden vom Koordinator auf Delegation. Die Alternative, die Einträge
   aus der Summe zu nehmen, hätte einen bereits abgenommenen Eintrag
   (R3-Q-001) und die Etappe 0 rückwirkend ungeplant gemacht, ohne dass ein
   Bedürfnis weniger belegt wäre. Die Lesart macht die im Backlog geübte
   Praxis ausdrücklich, statt sie zu ändern, und sie heilt keinen fehlenden
   Stakeholder: R3-Q-001 bis R3-Q-009 ohne benannten Stakeholder bleiben in
   den offenen Punkten 12 und 15 und sind durch Benennung nachzuführen. Für
   R3-Q-010 ist die Abstimmung mit S-01 mit der Freigabe eingetreten; S-02
   bleibt offen. Die Lesart hat drei Fassungen gebraucht: Die erste liess den
   Vorbehalt pauschal "mit der Freigabe" entfallen, regelte den Sprint-Eingang
   nicht und begründete die Gleichsetzung von Freigabe und Abstimmung nicht;
   die dritte verlangt die Abstimmung mit **einem** benannten Stakeholder,
   bindet den Vorbehalt an einen terminierten Schritt, sperrt den Eintrag bis
   zu dessen Wegfall für den Sprint und lässt den Product Owner den Wegfall
   mit Datum vermerken. Acht kleinere Folgebefunde stehen als offener Punkt
   20 im Backlog.
3. **Form der Bereitstellung von gitleaks — versionierter Hook, nicht
   Umgebungsskript.** Die Weisung "permanent" ist als "in jeder neuen
   Sitzungsumgebung ohne Handarbeit vorhanden" gelesen. Ein Skript im
   Repository unter `.claude/hooks/`, das `SessionStart` aufruft, ist der
   einzige Ort, der mit dem Klon mitkommt und im Repository nachvollziehbar
   ist; ein Setup-Skript in der Umgebungskonfiguration der Weboberfläche läge
   ausserhalb des Repositories und ausserhalb der Nachweise nach 6.6. Der Hook
   ist Kanal, kein Gate: Er blockiert nie, und er ersetzt die Lage-C-Meldung
   von D11 nicht — fehlt `gitleaks` trotz Hook, sagt das die Kette, nicht der
   Hook. Gepinnt ist allein `linux_x64` mit der am 2026-09-07 und 2026-09-21 gegen
   die veröffentlichte Prüfsummendatei geprüften SHA-256 (für den 2026-09-02
   ist eine Prüfsummenprüfung belegt, der Wert dort nicht wörtlich); für
   andere Architekturen wird nichts installiert und das gemeldet. Die
   Installation setzt doppelte Übereinstimmung voraus (gepinnter Wert im
   Skript und veröffentlichte Prüfsummendatei); stimmt eines nicht, wird das
   Archiv nicht entpackt.
4. **Was der Hook bewusst nicht tut.** Er holt keine Git-Historie nach
   (`git fetch --unshallow`), obwohl ein flacher Klon am 2026-09-07 und am
   2026-09-21 je von Hand behoben wurde: Die Weisung nennt gitleaks, und D20
   meldet einen flachen Klon als Lage C `FEHLT=git-historie` selbst. Ob die
   Historie beim Sitzungsstart nachgeholt werden soll, ist eine eigene Frage
   an den Auftraggeber (unten unter "Offen"). Er liest keine Umgebungsvariable,
   die Prüfsumme, Adresse, Fassung oder Archivnamen übersteuert; `TMPDIR` und
   `HOME` bestimmen Zwischen- und Rückfallort, beide werden vor jedem
   Schreibvorgang physisch gegen den Arbeitsbaum geprüft, und ohne gesetztes
   `CLAUDE_PROJECT_DIR` wird nichts geschrieben — so schreibt er nie in den
   Arbeitsbaum (in der zweiten Fassung war das an einer Stelle gemessen
   falsch, siehe Verifikation; in der vierten behoben und nachgemessen).
5. **Merge-Frage.** Technisch ist ein Merge nicht Voraussetzung, um E4.1 zu
   bauen: Der Arbeitszweig trägt beide Einheiten, und die nächste Sitzung kann
   darauf aufsetzen. Empfohlen ist der Merge beider Zweige vor E4.1 trotzdem,
   aus drei Gründen: Erstens ist jede Einheit ein eigener Pull Request, dessen
   Merge den Stand nach `main` bringt, wo der Nachweisfluss
   (`nachweise-uebertragen.yml`) und der Eingang nach Repo B allein laufen —
   solange nicht gemergt ist, bleibt `docs/NACHWEISE.md` in Repo B auf dem
   Stand vom 2026-09-21 vor dieser Einheit und die Abnahme vom 2026-09-08
   steht in Repo B nicht als Nachweis. Zweitens wächst ein Zweig, der drei
   Einheiten trägt, gegen die automatischen Eingangs-Merges auf `main`
   (zuletzt Pull Request #16) und muss diese nachziehen. Drittens zeigt der
   Merge dem Auftraggeber genau den Stand, den die nächste Einheit
   voraussetzt. Die Pull Requests werden nur auf ausdrückliche Anweisung
   eröffnet; nach einem Merge startet der nächste Zweig von `main`.
6. **Übergabedateien werden nicht geändert.** Die Zählfrage nach 3.4 stand in
   der Übergabe vom 2026-09-21; ihr Entscheid steht hier, nicht dort
   (Übergaben belegen einen vergangenen Stand).

## Verifikation

Die Rolle, die schreibt, hat nicht geprüft (3.4). Umsetzung des Hooks durch
den SecDevOps Engineer und die Einträge des Protocol Masters und des Product
Owners liefen auf dem Modell dieser Rollen; die Prüfung lief je auf einem
anderen Modell (Rollendateien unter `.claude/agents/`, Modellfeld). Die Lesart
zu R1 hat der Requirements Engineer eingetragen und selbst dreimal fachlich
beanstandet; die Formprüfung seines Textes lief auf einem dritten Modell.

**Statische Prüfung, erste Runde (Static Software Tester):** Prüfgegenstände
Hook, `.claude/settings.json`, Hook-Regel, `CLAUDE.md`, Nachweiserzeuger, die
sechs Nachträge in ADR 0002, die Nachträge im Backlog und die mechanische
Formprüfung über 448 hinzugefügte Zeilen (kein Eszett, keine typografischen
Anführungszeichen, kein Modellname, kein Zweigverweis, alle Pfade in Backticks
vorhanden, alle Commit-Prüfsummen 40-stellig und auflösbar, Abschnittsangaben
ohne "ADR" nur für Abschnitte des Projektauftrags, Tabellenspalten gleich dem
Kopf, Wortlaut der Weisung über fünf Dateien zeichengleich). **Bestanden**,
ein ablaufbedingt blockierender Befund (die beiden neuen Dateien müssen vor
`make dod` versioniert sein, sonst endet D12 mit `A_FAIL` — Klasse K-01, in
dieser Einheit durch `git add` vor dem Kettenlauf beachtet) und 17
nachrangige Befunde: 13 am Hook (Zeitbudget mit 6 s Marge, Signal-Trap erst
nach Fall A, Symlink-Prüfung, Teilstringvergleich der Version, vier
ungeprüfte Werkzeuge, `-S` bei curl, mehrzeilige Ausgaben in der Meldung,
kein Rückfallziel bei fehlgeschlagener Installation, nicht atomare
Installation, drei Kommentarstellen, `TMPDIR` und `HOME` als Schreibort),
zwei am Backlog (offener Punkt 20 nicht in der Stand-Zeile; die
Anforderungskennung des Hooks nirgends im Backlog) und einer an dieser
Übergabe (Verweis auf Folgebefunde, die noch nicht drinstanden). Alle 13
Hook-Befunde sind behoben (dritte Fassung des Hooks, 308 Zeilen), die beiden
Backlog-Befunde durch den Product Owner (Stand-Zeile; Stand-Vermerk in
R3-Q-001: der Hook trägt die Kennung R3-Q-001, ist von der Abnahme vom
2026-09-08 nicht umfasst), der Übergabe-Befund durch diesen Abschnitt.

**Dynamische Prüfung, erste Runde (Dynamic Software Tester):** 13 Aufrufe
des Hooks in elf Fällen (vorhanden; fehlt mit echter Bereitstellung, 0.8 s,
Binary byteidentisch mit dem vorgefundenen; Archiv-Prüfsumme falsch;
Download scheitert; veröffentlichte Prüfsummendatei manipuliert, während das
Archiv echt ist; Architektur `aarch64` ohne Download; `sha256sum` fehlt;
Fassung 9.9.9; hängendes `gitleaks version`; installiert, aber nicht im PATH;
Abbruch durch Signal). Alle Aufrufe Rückgabewert 0, stderr in jedem Fall
leer, beide Prüfsummenprüfungen je einzeln wirksam, Arbeitsbaum vor und nach
der Prüfung identisch, keine Temp-Reste auf normalen Pfaden.
**Bestanden**, drei nachrangige Befunde: `gzip` nicht in der Vorprüfung
(behoben), inneres Zeitbudget 270 s über der Grenze 120 s und ein
Temp-Verzeichnis bleibt bei `SIGKILL` stehen (Zeitbudget behoben, `SIGKILL`
als Grenze im Kopfkommentar benannt — kein Trap kann es abfangen), keine
Anforderungskennung (behoben: R3-Q-001, Entscheidpunkt E-E). Gemessene
Abdeckung 8 von 16 Ausgangsstellen; ein Schwellenwert für Hook-Skripte ist
im Projekt nicht vereinbart.

**Nachprüfung, zweite Runde (beide Prüfer, je frisch, auf dem dritten Stand
des Hooks):** statisch **nicht bestanden** allein
wegen des unversionierten Prüfgegenstands (dieselbe Klasse K-01 wie oben,
durch `git add` vor dem Kettenlauf erledigt); in der Sache elf der dreizehn
Befunde vollständig behoben, zwei teilweise (drei unbedingt verwendete
Programme `chmod`, `mv`, `rm` fehlten weiter in der Vorprüfung; eine
Kommentarstelle im Rumpf), dazu zwölf neue nachrangige Befunde: N-01
`chmod` unbedingt verwendet, nur bedingt geprüft; N-02 `mv` ungeprüft; N-03
`rm` ungeprüft; N-04 `mkdir -p` vor der Arbeitsbaumprüfung; N-05 die Aussage
"unbedingt wahr" bei nicht gesetztem `CLAUDE_PROJECT_DIR`; N-06 die Wendung
"die einzige ausgehende Verbindung" im Rumpf; N-07 Signal-Trap wirkt erst
nach Ende des Kindprozesses, im Kommentar nicht dargestellt; N-08 `-L` ohne
`--proto-redir`; N-09 Testfallkennungen ohne Fundort im Bestand; N-10 die
Meldung nennt einen nicht versuchten Ort; N-11 vorhersagbarer Name der
Zwischendatei; N-12 stderr in den Versionsvergleich gemischt.
Dynamisch **nicht bestanden**: 24 Aufrufe in 16 Fällen, 23 mit Rückgabewert 0
(der einzige andere Wert ist `SIGKILL`, benannte Grenze), Bereitstellung in
0.9 s byteidentisch, Rückfallziel `$HOME/.local/bin` bei unbeschreibbarem
`/usr/local/bin` (per `chattr +i`) belegt, exakter Versionsvergleich und
Einzeiligkeit belegt, Übersteuerungsversuch über fünf Umgebungsvariablen
wirkungslos, stderr bei echtem `curl`-Fehlschlag leer — aber **DT2-01,
blockierend**: das Rückfallziel wurde angelegt, bevor es gegen den
Arbeitsbaum geprüft war, und bei `HOME` im Arbeitsbaum blieb ein leeres
Verzeichnis stehen; die Zusicherung "schreibt nie in den Arbeitsbaum" war in
dieser Fassung gemessen unwahr. Dazu DT2-02 (dieselbe Reihenfolge bei
`mktemp`, ohne Rest), DT2-03 (bei `TERM`/`HUP` an die Prozessgruppe schreibt
die Shell "Terminated"/"Hangup" auf stderr; Standardausgabe leer) und DT2-04
(ein Signal-Trap wirkt erst, wenn das laufende Kind endet: bis 42 s je
Download, 10 s in Fall A; Rückgabewert 0 zugesichert, Zeitpunkt nicht). Der
Prüfer hat einen eigenen Messfehler offengelegt (Hintergrundstart ohne
Job-Kontrolle erbt `SIGINT` auf ignoriert) und den Fall mit `set -m`
wiederholt.

**Dritte Behebungsrunde und dritte Nachprüfung (letzte am Hook):** Vierte Fassung des Hooks (359 Zeilen; alle
zwölf Punkte der zweiten Runde und DT2-01/DT2-02 behoben, `install` durch
`cp` und atomares `mv` ersetzt, `cp` in der Werkzeugliste, fail-closed ohne
`CLAUDE_PROJECT_DIR`, Arbeitsbaumprüfung vor jedem Anlegen). Dynamisch
**bestanden** — 14 Aufrufe in 13 Fällen, alle Rückgabewert 0, stderr leer;
DT2-01 und DT2-02 an der verantwortlichen Codestelle belegt (Ablaufspur mit
`PS4`: `mkdir -p` für den Arbeitsbaum-Kandidaten nicht ausgeführt, `strace`
mit null schreibenden Systemaufrufen im Arbeitsbaum); Umleitung über einen
fremden Host mit `--proto-redir` belegt, exakter Versionsvergleich trotz
Warnzeile auf stderr belegt; zwei nachrangige Befunde (DT3-01 dieselbe
Meldung an zwei Stellen mit und ohne Netzzugriff; DT3-02 `exit 0` statt
`continue` im Kandidatenzweig, nicht gemessen). Statisch **nicht
bestanden**: SST3-01 (blockierend) — `vorfahre_ermitteln()` terminierte für
einen relativen Pfad nicht (erreichbar über ein relativ gesetztes `HOME`,
etwa `HOME="~"`; Prozessorlast bis zur Zeitgrenze, dann stiller Abbruch), ein
echter Fehler, der mit der Behebung von DT2-01 neu entstanden war; dazu acht
nachrangige (SST3-02 Zwischendatei im Zielverzeichnis nicht vom Trap gedeckt,
SST3-03 Zeitbudget setzt `timeout` voraus, SST3-04 Ort des Restverzeichnisses,
SST3-05 Schrittbuchstaben, SST3-06 `CLAUDE_PROJECT_DIR` gesetzt, aber nicht
auflösbar, SST3-07 Wortlaut von N-06 nicht aktenkundig — hier nachgeholt,
SST3-08 drei Aufrufe ohne stderr-Umleitung, SST3-09 Schreibfehler). Alle
elf Punkte in der **fünften Fassung** (395 Zeilen) behoben: relatives `HOME`
wird als Kandidat verworfen und die Funktion kehrt für relative Pfade mit
leerem Ergebnis zurück, die Schleife ist zusätzlich gegen Stillstand
gesichert; nicht auflösbares `CLAUDE_PROJECT_DIR` endet fail-closed; der
EXIT-Trap räumt auch die Zwischendatei; die beiden Arbeitsbaum-Meldungen
sind unterscheidbar; ein Kandidat im Arbeitsbaum führt zum nächsten
Kandidaten statt zum Ende.

**Vierte Nachprüfung (fünfte Fassung; letzte Runde, danach keine Behebung
mehr ausser an einem blockierenden Befund):** statisch **bestanden**, kein
blockierender Befund; SST3-01 an einer Nachbildung mit 33 Eingaben unter
`timeout` als terminierend belegt, die Absicherung besteht dreifach; alle elf
Behebungen vorhanden und richtig, alle vierzehn Regressionskriterien erfüllt,
die Werkzeugliste deckt jedes unbedingt verwendete Programm; vier nachrangige
Befunde SST4-01 bis SST4-04 (ein Fehlschlagzweig der Zwischendatei nicht vom
Trap gedeckt, nur über einen Eingriff Dritter zwischen zwei Zeilen erreichbar;
`awk` in einer Rohrleitung ohne stderr-Umleitung; die Wendung "unbedingt wahr"
im Kopf gegen die fail-open-Richtung der Hilfsfunktion bei nicht auflösbarem
Pfad — die Zusicherung hält, aber aus einem Grund, den der Quelltext nicht
ausspricht; ein toter Wert). Dynamisch **bestanden**, kein Befund: sieben
Fälle, alle Rückgabewert 0, stderr leer; `HOME="~"` und `HOME="home/user"` bei
unbeschreibbarem `/usr/local/bin` enden nach rund 0.5 s mit "Installation
fehlgeschlagen (/usr/local/bin)" statt in der Endlosschleife, ohne Verzeichnis
im Arbeitsbaum oder im Arbeitsverzeichnis; `HOME` im Arbeitsbaum ergibt zwei
unterscheidbare Meldungen und kein Verzeichnis; nicht auflösbares
`CLAUDE_PROJECT_DIR` endet ohne Download; echte Bereitstellung in 1.2 s
byteidentisch. Die vier nachrangigen Befunde sind nicht mehr behoben und
stehen unten unter "Offen".

Kennungen der Prüffälle, weil der Hook-Kommentar auf diese Übergabe verweist:
dynamisch Runde 1 `DT-E-E-F-A` bis `DT-E-E-F-K`, Runde 2 `DT2-N-A` bis
`DT2-N-O` (Schema R3-Q-001, E-E, DT2) mit Befunden `DT2-01` bis `DT2-04`; statisch Runde 1 `SST-0922-B1`
und `SST-0922-01` bis `SST-0922-17`, Runde 2 `B-01` und `N-01` bis `N-12`.

**Lesart zu R1:** drei Runden des Requirements Engineers an seinem eigenen
Text — B-1 bis B-3 (Vorbehalt je Stakeholder, Sprint-Eingang, Gleichsetzung
Freigabe/Abstimmung) und B-4 bis B-9 (Bestimmtheit des terminierten
Schritts, Prüfmittel der Sprintsperre, Fachgebiet, Kopftext von Teil 1,
gesonderter Ausweis, Rückwirkung) sind eingearbeitet; B-10 bis B-17 sind als
offener Punkt 20 des Backlogs gesammelt und nicht mehr eingearbeitet (keine
weitere Runde; was bleibt, ist offener Punkt, nicht Abbruchgrund).

**Formprüfung der Texte, die nicht der ersten statischen Runde unterlagen**
(Definition of Ready in der dritten Fassung, diese Übergabe, die Einträge für
das Methodik-Repository) auf einem dritten Modell: **bestanden, kein Befund** — Form (kein Eszett, gerade
Anführungszeichen, kein Modellname, Tabellenspalten, Abschnittsangaben,
Pfade, 40-stellige und auflösbare Prüfsummen), Wortlaut der Weisung
zeichengleich über ADR 0002, Backlog, Übergabe und Methodik-Einträge, innere
Konsistenz der Lesart über Kopftext, R1-Zelle und Fortschreibungszeile, die
acht Sachverhalte des offenen Punkts 20 identisch mit B-10 bis B-17, die
Aussagen über den Hook durch seinen Quelltext gedeckt.

**`make dod`** nach `git add` aller geänderten und neuen Dateien: Form 2 mit den drei terminierten
Lagen C (D7, D10, D12), D20 `A_OK` (Befunde: 0), D11 `A_OK` (beide
`gitleaks`-Läufe), D19 `OHNE_BEFUND`, Rückgabewert 2 — der erwartete grüne
Zustand. Ein erster Lauf davor hatte an D20 zwei Befunde an dieser Übergabe
(eine Testfallkennung mit Schrägstrichen in Backticks, die der Belegprüfer als
Pfad las; das Wort für den verbotenen Zweigverweis im Fliesstext), beide
umformuliert.

## Was offen ist

- **Bau von E4.1** — nächste Einheit nach Weisung; nach ADR 0002, 6.13 g ändert
  E4.1 keine Zeile an den beiden Gates. Vorher empfohlen: Merge der beiden
  Arbeitszweige (Entscheidung 5), dann neue Sitzung, Zweig von `main`.
- **Frage an den Auftraggeber:** Soll ein flacher Klon beim Sitzungsstart
  ebenfalls durch einen Hook nachgeholt werden (`git fetch --unshallow`)?
  Bisher zweimal von Hand behoben; ohne Nachholen meldet D20 Lage C.
- Offene Punkte 12 und 15 des Backlogs (benannter Stakeholder für R3-Q-001 bis
  R3-Q-009 und weitere) — Requirements Engineer mit Product Owner; die Lesart
  zu R1 deckt sie ausdrücklich nicht.
- Offener Punkt 20 des Backlogs — die acht Folgebefunde B-10 bis B-17 des
  Requirements Engineers an der Lesart zu R1, nicht mehr eingearbeitet:
  "terminiert" heisst nur "als offener Punkt mit entscheidender Instanz
  geführt", ohne Datum oder Frist (B-10); kein Rückfall auf "nicht ready",
  wenn der terminierte Schritt ohne Abstimmung endet (B-11); Quelle und
  entscheidende Instanz für das Fachgebiet des Auftraggebers nicht benannt
  (B-12); die Sprintsperre hat kein mechanisches Prüfmittel und keine Spur
  (B-13); der gesonderte Ausweis von Einträgen mit Vorbehalt ist neu und im
  Bestand noch nicht geführt — derzeit trägt kein Eintrag einen Vorbehalt
  (B-14); die Deckung der Zählung vom 2026-09-21 steht nur in der
  Fortschreibungszeile, nicht in R1 (B-15); "Summe" und "ready mit
  ausdrücklichem Vorbehalt" stehen nicht im Glossar (B-16); die R1-Zelle
  trägt vier Regeln in einer Tabellenzelle (B-17) — Requirements Engineer
  mit Product Owner.
- Am Hook, aus der vierten Nachprüfung nicht mehr behoben (SST4-01 bis
  SST4-04): der Fehlschlagzweig, in dem die von `mktemp` gemeldete
  Zwischendatei nicht regulär ist, räumt nicht auf (nur durch Eingriff Dritter
  im Zielverzeichnis erreichbar); `awk` in der Prüfsummen-Rohrleitung ohne
  stderr-Umleitung; die Hilfsfunktion `im_arbeitsbaum` wertet einen nicht
  auflösbaren Pfad als "aussen" (fail-open), während die Projektpfad-Prüfung
  davor fail-closed ist — die Zusicherung hält, der Kopfkommentar nennt den
  Grund nicht; ein einmal gelesener, dann verworfener Wert
  `projekt_pfad_geprueft` — SecDevOps Engineer, mit der nächsten Änderung am
  Hook.
- Am Hook, nicht behoben und benannt: bei `SIGKILL` bleibt das temporäre
  Verzeichnis unter `/tmp` stehen (kein Trap kann das abfangen); ein
  Signal-Trap wirkt erst, wenn das laufende Kind endet (bis 42 s je Download);
  bei `TERM`/`HUP` an die ganze Prozessgruppe schreibt die Shell ein Wort auf
  stderr; welches Signal die Harness beim Reissen der Zeitgrenze sendet, ist
  nicht belegt; keine Sperre gegen zwei gleichzeitige Sitzungsstarts; die
  Echtheit des gepinnten Werts gegenüber einer dritten, unabhängigen Quelle
  ist nicht geprüft (belegt ist die Übereinstimmung von Download,
  veröffentlichter Prüfsummendatei und vorgefundenem Binary); sieben der
  Ausgangsstellen des Skripts sind nicht dynamisch gemessen (sie liegen
  hinter der doppelten Prüfsummenprüfung oder brauchen weitere Attrappen),
  ein Abdeckungsschwellenwert für Hook-Skripte ist im Projekt nicht
  vereinbart; `shellcheck` besteht in der Umgebung nicht.
- O-28 bedingt offen; O-25 und O-15 offen; `CHANGELOG.md` besteht nicht; die
  Bestätigung der Notation der Abnahmekriterien in
  `docs/06_Definition_of_Ready_und_Done.md` steht aus; die Kommentarzeilen
  "foermliche Freigabe ausstehend" in Gate und Lagenliste (Software
  Architect).
- Für andere Architekturen als `linux_x64` stellt der Hook nichts bereit; ein
  zweiter gepinnter Wert braucht einen ausgeführten Beleg auf einer solchen
  Umgebung.

## Protokoll der ausgeführten Befehle (Koordinator)

Diese Rolle hat weder gebaut noch geprüft noch die Fachtexte formuliert;
sie hat delegiert, zusammengeführt und ausgeführt:

- Lesen der Anker in ADR 0002, Backlog, Definition of Ready, Hook-Regel und
  `settings.json`; Abruf der veröffentlichten Prüfsummendatei
  `gitleaks_8.21.2_checksums.txt` (Zeile für `linux_x64` gleich dem gepinnten
  Wert; Zeilen für `linux_arm64` und `linux_x32` vorhanden, nicht gepinnt,
  weil ohne ausgeführten Beleg auf einer solchen Umgebung);
- Anlegen der Aufgabe #2; Delegation an SecDevOps Engineer (Hook, drei
  Fassungen), Protocol Master (ADR 0002), Product Owner (Backlog, vier
  Aufträge), Requirements Engineer (Definition of Ready, drei Fassungen),
  Static Software Tester (zwei Runden), Dynamic Software Tester (zwei
  Runden);
- eigene Nachführung von `CLAUDE.md` (Statuszeile, Absatz zu den beiden
  `SessionStart`-Hooks, Zeile in "Wo steht was"; 182 Zeilen) und
  `scripts/nachweise-erzeugen.sh` (zwei Artefaktzeilen); das Schreiben dieser
  Übergabe; die Einträge im Methodik-Repository (`methodik/entscheide.md`:
  V18, V19, S8, erledigter Punkt; `UEBERGABE.md`) unmittelbar nach dem Commit
  des Produkt-Repositories, weil sie dessen Prüfsumme tragen;
- `git add` aller geänderten und neuen Dateien vor `make dod` (K-01), `make
  dod` (Ergebnis oben), Commit mit Kennung R3-Q-001 im Betreff, Push auf den
  Arbeitszweig beider Repositories, danach `docs/NACHWEISE.md` neu erzeugt
  und in einem zweiten Commit versioniert.

Nicht ausgeführt: kein Pull Request eröffnet, kein Merge, nichts an den
beiden `PreToolUse`-Gates, am `Makefile` oder am DoD-Gate.
