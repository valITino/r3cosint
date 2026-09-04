# Übergabe 2026-09-04 — R3-Q-001: O-25 umgesetzt, Runden 6 bis 8, erneut nach 3.4 abgebrochen, O-26 vorgelegt

Eskalation 3.4: Selbsttestfall besteht, ohne seine Behauptung zu belegen

Arbeitseinheit auf Weisung des Auftraggebers vom 2026-09-03: "O-25 entscheiden:
beides umsetzen, dann sechste Runde." Vorangegangen ist die Einheit vom
2026-09-03 (`docs/uebergaben/2026-09-03_r3-q-001-o-24-zusicherungen.md`,
Commit `d96e3970b782c563fe8419cfc2c72200a85e6ec0`), die nach Projektauftrag 3.4
abgebrochen wurde, weil die Fehlerklasse "ein Selbsttestfall besteht, ohne
seine Behauptung zu belegen" zum fünften Mal aufgetreten war. Diese Einheit
hat die Nutzungsgrenze der Sitzung mehrfach gerissen und ist nach jeder
Rücksetzung am Stand auf der Platte fortgesetzt worden; sie erstreckt sich
über den 2026-09-03 und den 2026-09-04.

## Ergebnis in einem Absatz

Der Entscheid O-25 ist umgesetzt: Die Tabelle 6.12.19 trägt je Zeile einen
Kanal aus einem abschliessenden Wertevorrat, den der Selbsttest maschinell gegen
die tatsächlich benutzte Messhülle abgleicht, und je Zeile eine Mutation, die
der Selbsttest in einem eigenen Modus gegen eine Kopie ausführt; beide Modi
enden mit Rückgabewert 0 (154 von 154 Zusicherungen, Kanalabgleich ohne
Abweichung, 145 von 145 Mutationen erkannt, neun begründete Ausnahmen). Das
Gate verhält sich in allen dynamischen Prüfpunkten der Runden 6 bis 8 richtig,
ohne ein einziges falsches Grün. Trotzdem ist die Einheit **erneut nach 3.4
abgebrochen**: Die achte Runde ist statisch bestanden, dynamisch nicht — mit
sechzehn eigenen Mutationen, die in der Tabelle nicht stehen, hat der Prüfer
fünf Änderungen am Gate gefunden, die keine Zusicherung fallen lassen, darunter
eine Verschiebung der Eskalationsschwelle von vier auf drei (`Z-040` misst die
Zeile "Eskalation 3.4: …" als Teilzeichenkette statt als Zeile) und zwei
Behauptungen des ADR ohne jede Zeile (Zählschlüssel `KETTE
schlusszeile-widerspruch`, schliessendes `::` der Markengrammatik). Das ist der
achte Auftritt der Fehlerklasse "ein Selbsttestfall besteht, ohne seine
Behauptung zu belegen". Ursache ist nach der Analyse des Prüfers nicht die
einzelne Zeile, sondern die fehlende mechanische Bindung zwischen dem Wortlaut
einer Zusicherung und dem Prädikat, mit dem sie gemessen wird, und die fehlende
Deckung der Tabelle gegenüber dem ADR-Text ausserhalb der Tabelle. Vorgelegt
wird **O-26**, mit einem Abnahmekriterium, das die Runden beendet.

## Der Entscheid O-25 und seine Ausformung (ADR 0002, 6.12.26)

- **a) Kanalspalte, maschinell abgeglichen.** Die Tabelle 6.12.19 führt je
  Zeile eine Spalte "Kanal" mit abschliessendem Wertevorrat (`rc`, `stdout`,
  `stderr`, `zaehler`, `datei`, `beobachter`, `kette`, `selbsttest`, `dauer`;
  Kombinationen mit `+`). Jede Messhülle des Selbsttests meldet den Kanal, den
  sie tatsächlich misst; der Selbsttest gleicht ihn je Kennung gegen die
  Tabelle ab und endet bei Abweichung ungleich 0. Für `rc`, `stdout`,
  `stderr`, `zaehler` und `kette` sind seit f) typisierte Hüllen verbindlich,
  die den Kanal über ihren Namen binden; die freie Kanalangabe (`pruefe_wahr`)
  ist nur für `beobachter`, `dauer`, `selbsttest` und `datei` zulässig, jede
  andere Angabe ist ein Fehler des Selbsttests selbst.
- **b) Mutationsprobe je Zusicherung.** Jede Zeile nennt die Änderung an Gate
  oder Makefile, die sie fehlschlagen lassen muss, oder das Wort `keine` mit
  einem Grund aus einer geschlossenen Liste (1: die Zeile beschreibt den
  Selbsttest selbst; 2: Vorbedingung des Aufbaus; 3: die Zeile teilt den Fall
  mit einer Schwester, deren Kanal die Verneinung trennscharf misst, während
  der eigene sie nicht von anderen Ursachen desselben Messwerts trennen kann).
  Die ausführbare Form ist `scripts/dod-gate-mutationen.txt`; der Modus
  `scripts/dod-gate-selbsttest.sh --mutationen` prüft die Deckung der
  Mutationsdatei gegen die Tabelle in beide Richtungen, wendet jede Mutation
  auf eine Kopie an (die sich vom Original unterscheiden muss) und lässt den
  Fall der Kennung isoliert gegen die Kopie laufen; genau diese Kennung muss
  `FEHLGESCHLAGEN` melden. Der Prüfgegenstand wird nie verändert.
- **c)** Die vier Befunde der fünften Runde als Entscheide (S5-01: 16 Zeilen
  auf den gemessenen Kanal gestellt; DT5-01: `Z-111` mit Beobachtungsfenster;
  S5-02: Ausweichname der Zählerdatei terminiert; S5-03: `Z-018` misst einen
  gleichgebliebenen Stand).
- **e)** Beleglage der sechsten Runde und Entscheide daraus (Z-080 und Z-130
  auf `kette`; Ausnahmeliste im Selbsttest entfällt; `GATE sha256sum` als
  erster Block des Gates, DT6-05).
- **f)** Beleglage der siebten Runde und zwölf Entscheide daraus (`Z-124`,
  `Z-132`, `Z-133` präzisiert; `Z-139` und `Z-155` mit `keine` nach Grund 3,
  der dafür weiter gefasst ist; neu `Z-154` und `Z-155` zur Bindung des
  Durchlasses an den gezählten Schlüssel, DT7-03; typisierte Hüllen
  verbindlich, S7-05; Sperre unter `/tmp` bestätigt, S7-06), dazu **Punkt 13**
  mit den Berichtigungen aus Bau 4 (unten).

## Was gebaut ist

| Artefakt | Änderung |
|---|---|
| `scripts/dod-gate-selbsttest.sh` | Jeder Prüfaufbau ist eine selbstständige Fallfunktion `fall_*()`, die alles selbst herstellt (eigener Scheinbaum, eigenes Zustandsverzeichnis, eigene Attrappen); ein Register `FALL_ZU_KENNUNG` ordnet jeder Kennung genau eine Funktion zu, `FALL_REIHENFOLGE` legt die Reihenfolge des Normalmodus fest. Jede Messhülle meldet ihren Kanal; typisierte Hüllen `pruefe_rc*`, `pruefe_stdout_*`, `pruefe_stderr_*`, `pruefe_zaehler_*`, `pruefe_kette_*`; `pruefe_wahr` nimmt nur noch `beobachter`, `dauer`, `selbsttest`, `datei`. Kanalabgleich gegen die dritte Spalte der Tabelle (maskierte Rohrzeichen berücksichtigt), Deckung in beide Richtungen, doppelt gemeldete Kennungen sind eine Abweichung. Mutationsmodus `--mutationen` mit isolierten Kindprozessen (`env -i`, `timeout 30`, Vorspann zwischen zwei Sentinels, Sperrdeskriptor vor dem Kind geschlossen). Attrappenkette mit Aufrufprotokoll (`MOCK_AUFRUFPROTOKOLL`), Spur (`MOCK_TMP_SPUR`, 300 ms Haltezeit) und Marker. Neu `Z-154`/`Z-155`. 2948 Zeilen |
| `scripts/dod-gate-mutationen.txt` | **Neu.** Ausführbare Form der Spalte Mutation: 154 Einträge, je nicht zurückgezogener Kennung genau einer — 145 mit `sed`-Ausdruck (Ziel `dod-gate.sh` oder `Makefile`) und neun mit `keine` (`Z-152`, `Z-153` Grund 1; `Z-043`, `Z-045`, `Z-048`, `Z-068` Grund 2; `Z-114`, `Z-139`, `Z-155` Grund 3). Konventionen: Tabulator als Feldtrenner, `#` als Trennzeichen der `sed`-Ausdrücke, kein Hochkomma |
| `.claude/hooks/dod-gate.sh` | DT6-05: der Block `GATE sha256sum` läuft als allererster `GATE`-Block, damit der Ausweichname der Zählerdatei nach S5-02 nur greift, wenn genau dieses Prüfmittel fehlt (20 Zeilen). Sonst unverändert gegenüber Commit `d96e3970b782c563fe8419cfc2c72200a85e6ec0` |
| `docs/adr/0002-architekturentscheid-ziel-stack.md` | 6.12.26 a) bis f) mit Punkt 13; Tabelle 6.12.19 mit sechs Spalten (Kennung, Fall, Kanal, Zusicherung, Mutation, Herkunft), `Z-001` bis `Z-155`, `Z-110` zurückgezogen; 6.12.24 f fortgeschrieben; Abschnitt 8 (O-25 entschieden, Nachträge), Abschnitt 9 (vierzehnte und fünfzehnte Fortschreibung mit Berichtigung), Kopfzeile — durch den Software Architect |
| `scripts/nachweise-erzeugen.sh` | Neue Artefaktzeile für `scripts/dod-gate-mutationen.txt`, Beschreibung des Selbsttests nachgeführt (59 Artefakte) |

Stand am echten Bestand (Koordinator und DevOps Engineer, je ausgeführt):
`make dod` Schlusszeile Form 2 ("alle 14 Kettenschritte durchlaufen, 3 davon ohne Urteil (Lage C): D7 abnahme, D10 prototyp-trennung, D12 nachweise, Rueckgabewert 2"), D19 `OHNE_BEFUND`; Gate darauf mit `CLAUDE_PROJECT_DIR` Rückgabewert 0 in 10 s mit `systemMessage` "Durchlass mit terminierten Lagen C … Baum: /home/user/r3cosint."; ohne `CLAUDE_PROJECT_DIR` Rückgabewert 2 "weder CLAUDE_PROJECT_DIR noch das Eingabefeld cwd ergeben einen bestimmbaren Arbeitsbaum. Fail-closed." (G12, gewollt). Selbsttest Normalmodus Rückgabewert 0: "Selbsttest: 154 von 154 Zusicherungen bestanden", "Deckung: 154 Kennungen in der Tabelle, 154 geprueft, 0 ohne Pruefung, 0 ohne Kennung", "Kanalabgleich: 154 Kennungen, 0 Abweichungen"; Mutationsmodus Rückgabewert 0: "Mutationen: 145 geprueft, 145 erkannt, 0 nicht erkannt, 9 ohne Mutation (keine), 0 wirkungslos, Dauer 154s". Verteilung der 156 Messhüllen aus der Kanalspalte: `rc` 62, `stderr` 32, `zaehler` 23, `datei` 13, `stdout` 12, `kette` 7, `beobachter` 4, `selbsttest` 2, `dauer` 1 — gleich den Zahlen aus 6.12.26 f Punkt 13. Alle `exit`-Werte des Gates: 0 und 2.

## Bau 4 und die Berichtigungen des ADR (6.12.26 f, Punkt 13)

Der Bau lief nach der siebten Runde in einer vierten, kontrollierten Phase.
Zwei Entscheide aus f) hielten der Probe am Code nicht stand und sind vom
Software Architect an Ort berichtigt worden; die Proben hat der Koordinator
gegen Kopien ausgeführt, der versionierte Bestand blieb unverändert:

- **`Z-114` bleibt bei `rc`, Mutation `keine` (Grund 3, Schwester `Z-115`).**
  Entscheid 4 wollte `rc+datei` — Rückgabewert 2 **und** fehlende Spur der
  Attrappenkette —, weil unter der Verneinung ("die Wache fällt offen aus")
  die Kette liefe. Sie läuft nicht: Die einzige als `root` herstellbare Lage
  "physisch nicht auflösbar" ist ein nicht vorhandenes Verzeichnis (fehlende
  Durchquerungsrechte umgeht `root`; ein Pfad tiefer als `PATH_MAX` wird von
  glibc `getcwd` dennoch aufgelöst, geprüft mit 4934 Zeichen). Ohne die Wache
  scheitert die Umleitung der Kettenausgabe in dieses Verzeichnis, `make`
  startet nie, und das Gate blockiert mit dem Schlüssel `KETTE
  rueckgabewert=1` — Rückgabewert 2 in beiden Fällen, Spur in beiden Fällen
  fehlend. Gemessen: `BESTANDEN Z-114`, `FEHLGESCHLAGEN Z-115 … erhalten
  'KETTE rueckgabewert=1'`. Ein Kanal, der in der herstellbaren Lage nicht
  falsifizierbar ist, wird nicht als Messumfang geführt (Grundsatz aus b).
- **`Z-130` behält `kette`, die Mutation wechselt auf das Makefile.** Die
  Zeile nannte eine Mutation an der Markenauswertung des Gates
  (`BASH_REMATCH`-Gruppe), die ein direkter Kettenaufruf nie durchläuft — auf
  dem Kanal `kette` grundsätzlich unerkennbar, weshalb der Bau in Runde 6/7
  auf `stderr` ausgewichen war (S7-01). Neu misst der Fall die Marke von D12
  am **echten** Makefile (Kopie im Scheinbaum ohne beide Gegenstände, Ziel
  `nachweise` direkt aufgerufen): `::LAGE … D12 nachweise C
  FEHLT=scripts/nachweise-erzeugen.sh::`. Die Mutation entfernt im Makefile
  die Wache `[ -n "$fehlt" ] ||` vor dem zweiten Gegenstand; dann wird der
  letzte statt der erste genannt, und `Z-130` fällt. Die gate-seitige Lesart
  der `FEHLT=`-Gruppe bleibt bei `Z-054`.

Bestätigt haben die Proben die übrigen Entscheide aus f): `Z-133` (Form 1
mit `0 gueltige Marken gezaehlt`) und `Z-134` fallen unter der Mutation;
`Z-124` fällt mit erhaltenem Schlüssel `LISTE 6 2` statt `LISTE 2 D7
abnahme`, die Bereichsadresse trifft genau die sieben Abbruchanweisungen der
Strukturprüfung; der Prototyp von `Z-154` besteht ohne Mutation (Rückgabewert
2, Zähler 4) und fällt unter der verkürzten Suche (Rückgabewert 0), während
`Z-155` mit Stand 4 bestehen bleibt — genau der Grund 3.

**Zwischenkontrolle nach Bau 4** (Static Software Tester, Fremdbeleg): alle
Punkte der Lesekontrolle erfüllt (Register, Reihenfolge, Kanaldisziplin von
`pruefe_wahr` über 19 Aufrufe, Mutationsdatei 154/9, Stichprobe der
`sed`-Ausdrücke trifft genau die genannte Stelle), Normal- und Mutationsmodus
Rückgabewert 0, Bestand prüfsummengleich, isolierte Läufe der Mutationen
DT7-03 und Z-130 wie erwartet. **Ein Befund, SST-B4-01:** `Z-155` mass nur den
Stand (Zeile 2 der Zählerdatei), die Tabellenzeile sichert auch den
**gezählten Schlüssel** (Zeile 1) zu — die Fehlerklasse, zum sechsten Mal,
diesmal von der Zwischenkontrolle gefunden und **vor** der achten Runde
behoben: `Z-155` misst jetzt beide Zeilen über die typisierte Hülle
`pruefe_zaehler_wahr`. Der Koordinator zählt diesen Auftritt mit, wertet ihn
aber nicht als Abbruchgrund: Er ist an einer in dieser Einheit neu
geschriebenen Zeile aufgetreten und von der eigens dafür eingezogenen
Zwischenkontrolle gefunden worden, bevor eine Prüfrunde ihn sah — genau die
Schicht, die 6.12.26 e nach der sechsten Runde eingezogen hat.

## Verifikation (3.4)

Umsetzung: DevOps Engineer auf Sonnet, in Phasen mit Zwischenkontrolle durch
den Static Software Tester. Prüfung: Static und Dynamic Software Tester auf
Opus, unabhängig, je in einem Wegwerf-Klon mit eigenem Zustandsverzeichnis;
der versionierte Bestand blieb nach jeder Prüfung unverändert (je belegt).

**Runde 6 — beide nicht bestanden, gegen einen unfertigen Bau.** Der DevOps
Engineer hatte nach sechs Instanzen keinen Abschluss gemeldet; die Runde
lief trotzdem und fand 12 statische (S6-01 bis S6-12) und 6 dynamische
Befunde (DT6-01 bis DT6-06): 9 Kennungen ohne die Kanalumstellung aus S5-01,
DT5-01 und S5-03 nicht behoben, Mutationsmodus mit 13 Abbrüchen `unbound
variable`, 31 nicht erkannte und 3 wirkungslose Mutationen, Kanalparser bei
maskierten Rohrzeichen falsch, Sperre an Beobachter vererbt. Antwort: der
Bau in drei kontrollierten Phasen (Fallfunktionen mit Register; Messungen;
Mutationen), Entscheide in 6.12.26 e. Phase 3 blieb an `Z-124` und `Z-133`
hängen.

**Runde 7 — beide nicht bestanden.** Normalmodus Rückgabewert 2 (`Z-089`
doppelt gemeldet, `Z-130` misst `stderr` statt `kette`), Mutationsmodus
Rückgabewert 2 (146 geprüft, 141 erkannt, 5 nicht erkannt: `Z-114`, `Z-124`,
`Z-132`, `Z-133`, `Z-139`). Befunde S7-01 bis S7-06, DT7-01 bis DT7-05;
blockierend **DT7-03** (eigene Mutation des Prüfers): Wird der gesuchte Text
der Übergabedatei auf `Eskalation 3.4:` verkürzt, fällt keine der 152
Zusicherungen — die Bindung des Durchlasses an den **gezählten** Schlüssel war
nicht zugesichert. Antwort: 6.12.26 f mit zwölf Entscheiden und Bau 4.

**Runde 8 — statisch bestanden, dynamisch nicht bestanden; Abbruch nach 3.4.**
Statisch ohne Beanstandung: beide Modi Rückgabewert 0, 51 Zeilen von Hand
Wort für Wort gegen ihre Messung gelesen, alle 145 `sed`-Ausdrücke einzeln
angewandt (keiner wirkungslos, die drei Bereichsausdrücke treffen nur ihren
Bereich), alle 19 Aufrufe von `pruefe_wahr` mit zulässigem Kanal,
Kanalverteilung und Mutationszahlen gleich 6.12.26 f Punkt 13, `Z-155` und
`Z-018` messen beide Bestandteile ihrer Behauptung, kein Schreiben in den
Baum. Sieben nachrangige Befunde: S8-01 (Rückzugserkennung liest die ganze
Zeile), S8-02 (Vermerk in Abschnitt 9 — am aktuellen Stand nicht
reproduzierbar, der Vermerk steht seit dem Nachtrag des Architekten in der
Zeile der fünfzehnten Fortschreibung), S8-03 (der Block `GATE sha256sum`
steht nach dem Vorziehen zweimal im Gate, die alte Fassung ist unerreichbar),
S8-04 (Mutationsdatei noch nicht versioniert — mit diesem Commit erledigt),
S8-05 (`Z-080` misst über die ganze Fehlerausgabe des D20-Aufrufs), S8-06
(Kanalabgleich vergleicht Zeichenketten statt Mengen, strenger als verlangt),
S8-07 (fünf Nicht-ASCII-Stellen in den Skripten). Ergebnis des Prüfers:
"FEHLERKLASSE: nein".

Dynamisch ohne Beanstandung: Beobachter über den Baum 2651 Runden ohne
Treffer, 254 Dateien vorher/nachher gleich; Gate gegen die Kopie als echten
Baum für `Stop`, `TaskCompleted` und `SubagentStop` (letzteres ohne Kettenlauf,
belegt über eine Attrappe); Eskalationsfolge über neun Ereignisse mit Zähler 1
bis 9, Forderung genau beim dritten, Block mit fremdem Schlüssel, Durchlass mit
richtigem, Block bei `TaskCompleted`; zwei gleichzeitige Gate-Aufrufe sauber
serialisiert; 28 Läufe nur mit Rückgabewert 0 oder 2 und richtiger
Ausgabeform. **Sechzehn eigene Mutationen** am Gate, keine davon in der
Mutationsdatei: zehn erkannt (der Bericht zählt elf, seine Aufzählung nennt
zehn; im ADR als vom Prüfer zu klären vermerkt — unter anderem Schwelle 3 auf 2, Suche ohne
`HEAD`- oder ohne `status`-Zweig, `TaskCompleted`-Durchlass, D19-Auswertung aus,
`stop_hook_active` ignoriert, Rollenprüfung invertiert, `exit 1` statt 2 mit
42 fallenden Zeilen), eine ohne verletzte Zusicherung (fest `/tmp` als
`TMPDIR` — kein Befund, die Zeilen verlangen nur "ausserhalb des Baums"), und
**fünf nicht erkannt**:

- **DT8-01, blockierend:** Eskalationsschwelle von `-ge 4` auf `-ge 3`
  verschoben — keine Zeile fällt. `Z-040` sichert "die Fehlerausgabe des
  dritten Ereignisses enthält die Zeile `Eskalation 3.4: <Schlüssel>` wörtlich"
  zu, misst aber mit `grep -qF` eine Teilzeichenkette, die unter der Mutation
  im Satz "erwartet eine Datei … mit der woertlichen Zeile '…'" erhalten
  bleibt; und keine Zeile sichert zu, dass der Durchlass frühestens beim
  vierten Ereignis greift — mit vorhandener Übergabedatei liess das mutierte
  Gate schon beim dritten durch, Selbsttest 154 von 154. Dieselbe Ausprägung
  wie DT7-03 (Teilzeichenkette statt Zeile), an einer anderen Stelle.
- **DT8-02, blockierend:** Der Zählschlüssel `KETTE schlusszeile-widerspruch`
  (6.12.4, 6.12.23 a: Rückgabewert 0 nur mit Form 1) ist von keiner Zeile
  gedeckt; die Deckungsprüfung vergleicht Tabelle und Selbsttest, nicht die
  Klassifizierungstabelle mit der Tabelle.
- **DT8-03, blockierend:** Das schliessende `::` der Markengrammatik ist von
  keiner Zeile gedeckt; ohne es wird aus einem Block (`KETTE
  ausgabe-unlesbar`) ein sauberes Grün, und keine Zeile fällt.
- **DT8-04 bis DT8-06, nachrangig:** Rückfallpfad der Baumbestimmung über
  `CLAUDE_PROJECT_DIR` ungedeckt (die Mutation macht das Gate strenger); der
  Wert der inneren Zeitgrenze (600 s) ungemessen; die Ausgabeform ist nur für
  zwei der fünf Durchlasspfade gemessen.

Ergebnis des Prüfers: "FEHLERKLASSE: ja". Der Koordinator hat, wie in 6.12.26
f und Abschnitt 9 des ADR festgelegt, **abgebrochen**: Kein Befund der achten
Runde ist in dieser Einheit behoben; der Stand ist committet und vorgelegt.

## Nachführung

| Datei | Änderung |
|---|---|
| `CLAUDE.md` | Lieferreihenfolge und Tabelle "Aktive Gates": O-25 umgesetzt, 154 Zusicherungen mit Kanalabgleich und Mutationsprobe, Stand der achten Runde |
| `docs/05_Product_Backlog.md` | R3-Q-001: Nachweis (beide Modi des Selbsttests mit Schlusszeilen), Stand 2026-09-04 |
| `scripts/nachweise-erzeugen.sh` | Artefaktzeile für die Mutationsdatei, Beschreibung des Selbsttests |
| `docs/NACHWEISE.md` | Neu erzeugt nach dem Commit |
| Methodik-Repository | `UEBERGABE.md` (methodischer Anteil), `methodik/entscheide.md` V15 (O-25 als methodischer Entscheid des Auftraggebers: "Eine Prüfung ist erst dann Beleg, wenn sie ihre eigene Verneinung erkennt"), offener Punkt O-25 geschlossen |

## Was offen ist

1. **O-26** (ADR 0002, 6.12.26 g, Vorschlag des Software Architects nach
   der Analyse des Dynamic Software Testers) — Entscheid des Auftraggebers.
   Fünf Bausteine: (a) **Prädikatbindung** — die Spalte Zusicherung trägt ein
   Prädikat aus einem geschlossenen Vorrat, jede Messhülle meldet ihr Prädikat
   wie heute den Kanal, der Selbsttest gleicht beides ab; "die Zeile …
   wörtlich" ist nur mit einer Zeilenhülle zulässig. (b) **Schlüsseldeckung**
   — jeder Zählschlüssel der Klassifizierungstabelle 6.12.4 kommt in
   mindestens einer Zeile vor, maschinell geprüft. (c) **Grammatikdeckung** —
   je Element der Markengrammatik eine verneinende Zeile. (d) Die sechs
   Befunde DT8-01 bis DT8-06 als neue oder geänderte Zeilen mit Mutationen.
   (e) Ein **Abnahmekriterium**, das die Runden beendet: tabelleneigene
   Mutationen vollständig erkannt **und** eine Fremdmutationsrunde ohne
   blockierenden Befund in den Kategorien Schlüssel, Grammatik, Schwellen und
   Ereignisfolge, Ausgabeform; weitere Fremdmutationen danach sind Backlog,
   kein Abbruchgrund — die Tabelle kann nie alle denkbaren Mutationen
   aufzählen, und das offene Kriterium "keine neue Lücke" macht die Abnahme
   unendlich.
2. **Nachrangige Befunde der achten Runde** für die nächste Einheit: S8-01,
   S8-03 (alte Fassung des Blocks `GATE sha256sum` entfernen), S8-05, S8-06,
   S8-07, DT8-04 bis DT8-06.
3. **Förmliche Freigabe der Entscheidpunkte E-A bis E-K und Abnahme des
   Gates** (ADR 0002, Abschnitt 10). Formweg ist der Merge des Pull Requests;
   die Empfehlung des Koordinators steht im Bericht an den Auftraggeber.
4. **Bestätigung der Neufassung von D10 und D12** in der Definition of Done.
5. **Wirkung über den Harness**: in einer Sitzung mit Projektwurzel `r3cosint`
   eine Antwort bei roter Kette beenden und den Block beobachten; hier nicht
   möglich (Projektwurzel ist das übergeordnete Verzeichnis dreier
   Repositories).
6. **Umgebung**: `gitleaks` muss in der Umgebungsdefinition der Sitzung
   stehen; ohne `gitleaks` blockiert D11 jede Beendigung (E-E, Option b).
7. **O-15, O-19, O-20, O-23** unverändert beim Auftraggeber; R3-Q-005 bleibt
   die benannte Lücke; `shellcheck` fehlt weiterhin in der Umgebung.

## Protokoll der ausgeführten Befehle (Koordinator)

| Befehl | Ergebnis |
|---|---|
| `bash scripts/dod-gate-selbsttest.sh` vor Bau 4 (eigenes `XDG_STATE_HOME`) | 152 von 152 bestanden, Deckung 154/152/2/0 (`Z-154`, `Z-155` ohne Prüfung), Kanalabgleich 3 Abweichungen (`Z-114`, `Z-130`, `Z-132`), Rückgabewert 2, 49 s |
| `bash scripts/dod-gate-selbsttest.sh --mutationen` vor Bau 4 | abgebrochen wegen Deckungsabweichung (`Z-154`, `Z-155` ohne Eintrag), Rückgabewert 2 |
| Isolierte Fallläufe gegen mutierte Kopien (Z-133, Z-124, Z-114, Z-154-Prototyp; Makefile-Mutation für Z-130) | siehe Abschnitt "Bau 4"; Bestand unverändert (`git status` je vorher/nachher) |
| Probe "Verzeichnis tiefer als PATH_MAX" | 4934 Zeichen, `pwd -P` Rückgabewert 0 — als Lage "physisch nicht auflösbar" nicht herstellbar |
| `bash scripts/dod-gate-selbsttest.sh` nach Bau 4, eigenes `XDG_STATE_HOME` | 154 von 154, Deckung 154/154/0/0, Kanalabgleich 0 Abweichungen, Rückgabewert 0, 25 s; die fünf Prüfdateien vorher/nachher prüfsummengleich, `git status` unverändert |
| `bash scripts/dod-gate-selbsttest.sh --mutationen` nach Bau 4 | 145 geprüft, 145 erkannt, 0 nicht erkannt, 9 ohne Mutation, 0 wirkungslos, Rückgabewert 0, 154 s |
| Gate gegen `/home/user/r3cosint` (`Stop`, `CLAUDE_PROJECT_DIR` gesetzt, eigenes `XDG_STATE_HOME`) | Rückgabewert 0 in 10 s, `systemMessage` "Durchlass mit terminierten Lagen C: D7 …; D10 …; D12 …", Fehlerausgabe leer; ohne `CLAUDE_PROJECT_DIR` Rückgabewert 2 fail-closed (G12) |
| Berichte der Prüfer, Runde 8 | statisch bestanden mit 7 nachrangigen Befunden, dynamisch nicht bestanden mit 3 blockierenden und 3 nachrangigen Befunden; Auszüge in ADR 0002, 6.12.26 g |
| Formprüfung (Eszett, typografische Anführungszeichen, Zweigverweise) über die geänderten Zeilen von Gate, Selbsttest, Mutationsdatei, ADR und diese Übergabe | 0 Treffer |
| `make dod` im Arbeitsbaum vor dem Commit | siehe Commit-Protokoll: Schlusszeile Form 2, D19 `OHNE_BEFUND`, D20 0 Befunde |
