# Vorschlag Prozess-Schnitt, Punkt A.4: Product Backlog auf wartbare Form

Product Owner, Entwurf vom 2026-10-22. Nur Scratchpad. Im Repository ist nichts geschrieben worden (Bedingung des Koordinators: bis der Pull Request #28 gemergt ist). Grundlage: Entwurf des Koordinators (prozess-schnitt-entwurf.md, A.4) und die Weisungen vom 2026-10-22 (Backlog, offener Punkt 25).

Belegstand: Zahlen stammen aus Greps und Lesungen dieser Sitzung; die Quelle steht in Klammern. Nicht gelesen habe ich (ein Lesevorgang über die Zeilen 1 bis 103 wurde mit 37'387 Token über der Grenze von 25'000 abgewiesen, die Aufrufgrenze von 12 war danach erreicht): den Abschnitt "Wie dieser Backlog zu lesen ist" (Zeilen 10 bis 38) und die Feldnamen der Eintragstabellen. Beides steht in Abschnitt 6 als Prüfauftrag vor dem Bau. Mir fehlt Bash; die exakte Länge der längsten Zeile liefert der awk-Aufruf des Koordinators.

## 1. Ist-Stand in Zahlen

| Grösse | Wert | Messung |
|---|---|---|
| Zeilen | 845 (Dateiende nach Zeile 845; das Lesewerkzeug zeigt Zeile 846 als leer) | Lesung der Zeilen 816 bis 861 |
| Längste Zeile | Zeile 101 (R3-Q-010, Sammelposten "Offene Posten nach der Abnahme"): 15'000 bis 17'499 Zeichen | Grep in Blöcken zu 2'500 Zeichen, sechs volle Blöcke; exakt per awk |
| Zeilen mit mindestens 2'500 Zeichen | 13: Zeile 8 (Stand-Zelle, 7'500 bis 9'999), Zeile 101, Zeile 161 (5'000 bis 7'499); je 2'500 bis 4'999: Zeilen 60, 68, 92, 146, 155, 160, 165, 166, 844, 845 | derselbe Grep; Zeile 843 (Punkt 23) wurde nicht erfasst |
| Einträge | 91 Überschriften "### R3-… — Titel" in 8 Abschnitten: Etappe 0: 13, Etappe 1: 30, Etappe 2: 11, Etappe 3: 15, Etappe 4: 7, Etappe 5: 4, Etappe 6: 6, Zweite lieferfähige Fassung: 5 | Grep auf Überschriften |
| Nachführung-Absätze | 16, Zeilen 754 bis 791 im Abschnitt "# Summe und Ableitung" (ab Zeile 737). Ordnungszahlen 23 bis 13 lückenlos (Zeilen 754 bis 774), danach 7, 6, 4, 3, 2 (Zeilen 776 bis 791). Die Nummern 1, 5 und 8 bis 12 stehen nicht als Absatzanfang (Verbleib nicht geprüft). Kein Absatz erreicht 2'500 Zeichen | Grep auf "Nachführung" am Zeilenanfang |
| Offene Punkte | 25 Zeilen (821 bis 845) in der Tabelle "Nr. / Punkt / Wer entscheidet" ab Zeile 817. Erledigt ausdrücklich: 5 (Punkte 3, 18, 19, 21, 22). Gemischt: 2 (Punkt 23: (b) erledigt, (a) und (c) offen; Punkt 24: (a) bis (c) erledigt, die Posten laufen im Sammelposten weiter). Offen: 18 (Punkte 1, 2, 4 bis 17, 20, 25). Eine Statusspalte gibt es nicht; der Status steht im Zellentext ("Erledigt am …") | Lesung der Zeilen 816 bis 861 |
| Weitere Tabellen | Kopftabelle Zeilen 4 bis 8 (Arbeitsprodukt nach, Verantwortlich, Lebensdauer, Stand); Summentabelle mit den Zeilen "Erste Fassung, Summe" (748) und "Gesamt" (750) | Grep |
| Verweise von aussen | 114 Vorkommen des Pfads docs/05_Product_Backlog.md in 29 Dateien (ADR 0002: 43; Zustandsbericht 2026-09-02: 20; Makefile: 9; Roadmap: 6; Definition of Ready und Done: 5; ADR 0001: 3; Schwachstellenregister: 2; 12 Übergaben je 1; NACHWEISE.md, nachweise-erzeugen.sh, pull_request_template.md, CLAUDE.md, belege-pruefen.sh je 1 bis 2; belege-ausnahmen.txt: 4). Dazu 14 Treffer "Backlog … Zeile" in 10 Dateien (ADR 0002 Zeilen 10024, 10059, 10829, 11278; ADR 0001 Zeile 179; Definition of Ready und Done Zeile 116; Roadmap 205; Zustandsbericht 417; fünf Übergaben). CLAUDE.md nennt den Backlog in den Zeilen 24 (fünfmal), 190 und 195 | Grep über das Repository |

Schluss aus den Zahlen: Die Wartungslast sitzt nicht in den 91 Eintragsblöcken, sondern an vier Stellen: Stand-Zelle (Zeile 8), Sammelposten (Zeile 101), neun überlange Zellen in Eintragsblöcken (Zeilen 60, 68, 92, 146, 155, 160, 161, 165, 166) und die offenen Punkte 24 und 25. Die Nachführungen sind einzeln kurz; ihr Gewicht liegt in der Zahl und in der Prosa-Form.

## 2. Zielform

Grundsatz: Die 91 Eintragsblöcke bleiben mit ihrer Überschrift "### <Kennung> — <Titel>" in Reihenfolge und Wortlaut stehen. Grund: Der Belegprüfer D20 bildet die Menge der gültigen Anforderungskennungen aus den Überschriften "^#+ R3-…" der Datei docs/05_Product_Backlog.md (scripts/belege-pruefen.sh, Zeilen 107 und 257; Makefile, Zeilen 719 bis 721). Eine reine Tabellenform ohne diese Überschriften machte jede zitierte Kennung im Bestand zum Scheinfund. Ausserdem tragen die Blöcke die Abnahmekriterien, die nach 6.4 und 6.5 im Eintrag stehen müssen.

### 2.1 Gerüst der neuen Datei docs/05_Product_Backlog.md

1. "# Product Backlog" und Kopftabelle (vier Zeilen wie heute). Die Zeile "Stand" sinkt von 7'500 bis 9'999 auf höchstens 600 Zeichen: Datum, laufende Einheit, nächste Einheit, Verweis auf die Nachführungstabelle.
2. "## Wie dieser Backlog zu lesen ist" (heute Zeilen 10 bis 38), ergänzt um die Pflegeregel (4.2) und den Archivverweis mit 40-stelliger Commit-Prüfsumme.
3. "## Übersicht der Einträge": eine Tabelle, eine Zeile je Eintrag (91), in Backlog-Reihenfolge.
4. "## Posten unter R3-Q-010": Tabelle Posten 1 bis 10.
5. Die Etappen "# Etappe 0 — Vorlauf" bis "# Zweite lieferfähige Fassung" mit den 91 Blöcken, wörtlich in Überschrift und Reihenfolge; die neun überlangen Zellen und die Sammelposten-Zeile tragen nur den aktuellen Wortlaut.
6. "# Summe und Ableitung" mit der Summentabelle (Form und Werte unverändert) und neu "## Nachführungen" als Tabelle.
7. "# Offene Punkte des Backlogs" als Tabelle mit Status.

Überschriften, die wörtlich bleiben müssen: alle 91 "### R3-…"-Überschriften, "# Summe und Ableitung", "# Offene Punkte des Backlogs", "## Wie dieser Backlog zu lesen ist" und die Etappen-Überschriften. Für die Kennungen ist die Abhängigkeit von D20 belegt; ob D20 oder andere Prüfer auch Abschnittsüberschriften des Backlogs auflösen, habe ich nicht gelesen.

### 2.2 Übersichtstabelle (eine Zeile je Eintrag)

Spalten: Kennung | Titel | Art | Status | Prüfaufwand (h) | Letzter Nachtrag | ADR.

- Titel: höchstens 100 Zeichen, aus der Überschrift.
- Art: F, Q oder C nach dem Kennungsbuchstaben (funktional, Qualität, Randbedingung; 6.4).
- Status (Vorschlag, aus den Blöcken abzuleiten): neu, ready, nicht ready, in Arbeit, gebaut und verifiziert, teilweise abgenommen, abgenommen, gestrichen. 6.6 verlangt einen erkennbaren Status je Anforderung.
- Prüfaufwand: Zahl in Stunden. Die Summentabelle (6.8, Faustregel 28 bis 40 Stunden je Sprint) bildet ihre Werte aus dieser Spalte; die Summe rechnet der Koordinator mit awk nach, ich habe kein Bash.
- Letzter Nachtrag: Datum und ein Satz, höchstens 200 Zeichen.
- ADR: Kürzel mit Abschnitt, mit den endgültigen Nummern nach dem Schnitt des Software Architects (6.12 → ADR 0003, 6.13 → ADR 0004, 6.14 → ADR 0005, Entwurf A.2).

Zwei Beispielzeilen (Daten aus CLAUDE.md, Stand 2026-10-22; vor dem Eintragen gegen die Blöcke prüfen):

| Kennung | Titel | Art | Status | Prüfaufwand (h) | Letzter Nachtrag | ADR |
|---|---|---|---|---|---|---|
| R3-Q-010 | main-Gate und Prototyp-Gate: belegte Lücken geschlossen, … (Titel aus der Überschrift) | Q | abgenommen am 2026-09-23 (PR #21, Merge-Commit 9a84b9ccd1ecb81b19739f64defc5881e83e2db5); Posten 2, 6 und Prototyp-Teil von 7 gebaut und verifiziert, Abnahme ausstehend; Posten 3, 7 (main-Gate), 8 bis 10 offen | 5 | 2026-10-22: Posten 2, 6 und Prototyp-Teil von Posten 7 gebaut und verifiziert; Posten 8 bis 10 erfasst | 0004, 6.13 |
| R3-Q-011 | Fremde Inhalte im Harness: Regel und Skill zur Einschleusungsprüfung (Titel aus der Überschrift) | Q | abgenommen am 2026-09-25 (PR #25, Merge-Commit 0b6d59625423f53fcd0e8b3f22150d97ef2a17f4) mit fünf von sechs Kriterien; R3-Q-011_regel_im_startkontext offen | 6 | 2026-10-14: Abnahme eingetragen; Gegenprobe zu R3-Q-011_regel_im_startkontext nicht durchgeführt | 0005, 6.14 |

### 2.3 Tabelle "Posten unter R3-Q-010" (ersetzt den Inhalt der Zeile 101)

Spalten: Posten | Gegenstand | Gate | Lücken | Status | Abnahme | Register | Fundort. Daten aus CLAUDE.md, Stand 2026-10-22; vor dem Eintragen gegen ADR 0002, 6.13 und 6.13 c prüfen.

| Posten | Gegenstand | Gate | Lücken | Status | Abnahme | Register | Fundort |
|---|---|---|---|---|---|---|---|
| 1 | Ziele von push und worktree add lexikalisch normalisiert | main | L01 bis L04 | abgenommen | 2026-10-16, PR #26, Merge-Commit 5ada002023c0ff160c26c78659727c7e8623c6f5 | – | ADR 0002, 6.13 und 6.13 c, je Nachtrag vom 2026-10-14 |
| 2 | Schreibweisen require (, @import url(, src =/href = als JS-Zuweisung, __import__, import_module | Prototyp | L05 bis L08 | gebaut und verifiziert (C3, 2026-10-22) | Merge des Pull Requests der Sitzung ausstehend (Nummer nach dem Merge eintragen) | – | ADR 0002, 6.13 c, Nachtrag vom 2026-10-22 zum Bau von C3; Übergabe 2026-10-22_c3-prototyp-gate |
| 3 | Prototyp-Gate, Lücke L09 | Prototyp | L09 | offen, mit C4 terminiert | – | – | ADR 0002, 6.13 c |
| 4 | Befehlskette, Zeilenfortsetzung am Verb, Basename-Form | main | L17, L19, L21 | abgenommen | 2026-10-21, PR #27, Merge-Commit 998f81d9fffe3970baf870d04e44576eda534fcc | SR-002 (behoben) | ADR 0002, 6.13 c, Nachtrag vom 2026-10-21; Übergabe 2026-10-21_abschnitt-c-posten-4-5 |
| 5 | Umgehung bei grosser Eingabe (SIGPIPE unter pipefail) | beide | L20; am Prototyp-Gate L22, B64, B65 | abgenommen | 2026-10-21, PR #27, Merge-Commit 998f81d9fffe3970baf870d04e44576eda534fcc | SR-001 (CVSS 3.1 Basiswert 5.5, behoben) | wie Posten 4 |
| 6 | sed- und tr-Schritte ohne Prüfung des Rückgabewerts | Prototyp | L23, L24 | gebaut und verifiziert (C3) | ausstehend wie Posten 2 | SR-004 (CVSS 3.1 Basiswert 4.7, in Behebung bis zum Commit) | wie Posten 2 |
| 7 | keine eigene Zeitgrenze im Skript | beide | – | Prototyp-Teil gebaut und verifiziert (C3); main-Gate-Teil offen | Prototyp-Teil ausstehend wie Posten 2; main-Gate-Teil: eigene Einheit vor der Freigabe des Grundgerüsts, Einordnung durch den Auftraggeber ausstehend | SR-003 (Prototyp-Teil in Behebung, main-Gate-Teil offen) | wie Posten 2 |
| 8 | jq-Schritte ohne Prüfung des Rückgabewerts, Durchlass bei gemischter MultiEdit-Eingabe | Prototyp | – | offen, mit C4 terminiert | – | SR-005 | ADR 0002, 6.13 c, Nachtrag vom 2026-10-22 |
| 9 | (a) Formen ohne Anführungszeichen und mit Grossschreibung an den Dateiwerkzeugen; (b) src= und href= am Bash-Weg | Prototyp | – | offen, mit C4 terminiert | – | SR-006 | wie Posten 8 |
| 10 | Prüfmittel-Reste: Fall mit -k 1, import_module je Richtung, statische JS-Form als Gegenprobe zu P52 | Prüfmittel | DT-C3-03, ST-C3-03, ST-C3-04 | offen, mit C4 terminiert | – | ohne Registereintrag | wie Posten 8 |

Die Zeile 101 behält ihre Bezeichnung "Offene Posten nach der Abnahme" als Zeilenname im Block R3-Q-010 und enthält nur noch einen Satz mit Verweis auf diese Tabelle. Grund: ADR 0001 und ADR 0002 sowie Übergaben zitieren Zeilen eines Blocks beim Namen (zum Beispiel "R3-Q-011, Zeile Zerlegung" und "Achtung-Zeile"; ADR 0002 Zeilen 10024, 10059, 10829; ADR 0001 Zeile 179). Diese Zeilennamen bleiben in allen Blöcken erhalten.

### 2.4 Tabelle "Nachführungen" (ersetzt die nummerierte Prosa)

Spalten: Nr. | Datum | Einheit | Änderung | Fundort.

- Nr. bleibt als Spalte, weil der Text die Ordnungszahl als Verweis nutzt (Zeile 754: "an die Stelle der Angabe in der Zweiundzwanzigsten Nachführung tretend"). Die Ordnungswörter werden Zahlen; die Zuordnung steht einmal im Kopf der Tabelle.
- Änderung: ein Satz, höchstens 300 Zeichen. Die Vollfassung steht im Archiv.
- Fundort: Pull-Request-Nummer und Übergabedatei; der Merge-Commit wird in der nächsten Nachführung nachgetragen (wie bisher bei den Abnahmeeinträgen), weil die eigene Prüfsumme nicht im selben Commit stehen kann. Keine Zeilennummern (6.6, feste Verweise).
- Nr. 24 ist die Nachführung des Prozess-Schnitts selbst.

Bestandsliste der 16 Absätze (Datum und Anlass nach dem Absatzanfang; die Änderungssätze sind aus den Absätzen zu verdichten):

| Nr. | Datum | Anlass nach Absatzanfang |
|---|---|---|
| 23 | 2026-10-22 | Einheit C3 |
| 22 | 2026-10-21 | Einheit D1 |
| 21 | 2026-10-21 | nach dem Bau von Posten … |
| 20 | 2026-10-21 | nach dem Merge des Pull Requests … |
| 19 | 2026-10-14 | nach dem Bau von Posten … |
| 18 | 2026-10-14 | nach der Abnahme von R3-… |
| 17 | 2026-09-25 | nach dem Bau von E3.3 … |
| 16 | 2026-09-25 | nach dem Merge des Pull Requests … |
| 15 | 2026-09-24 | nach der Freigabe von E… |
| 14 | 2026-09-23 | nach der Einordnung von … |
| 13 | 2026-09-23 | nach der Abnahme von R3-… |
| 7 | 2026-09-22 | nach der Weisung des Auftraggebers … |
| 6 | 2026-09-21 | in zwei Teilen |
| 4 | 2026-08-31 | nach einer unabhängigen … |
| 3 | 2026-08-31 | nach Einordnung des Ver… |
| 2 | 2026-08-26 | nach Koordinatorenprüfung … |

### 2.5 Tabelle "Offene Punkte"

Spalten: Nr. | Punkt | Status | Stand | Wer entscheidet | Fundort.

- Nr. bleibt, weil CLAUDE.md und die Backlog-Zeilen die Punkte mit Nummer zitieren ("Backlog Punkt 19", "offener Punkt 22", "Punkt 25").
- Status: offen, teilweise, erledigt. Stand: Datum der letzten Änderung. Punkt: höchstens 300 Zeichen.
- Anfangsbelegung: erledigt 3 (2026-08-20), 18 (2026-09-22), 19 (2026-09-22), 21 (2026-09-24), 22 (2026-09-24); teilweise 23, 24; offen 1, 2, 4 bis 17, 20, 25.
- Die Wortlaute von Weisungen des Auftraggebers (Punkte 18, 19, 21, 22, 25) stehen nach den Zeilen selbst bereits in ADR 0002 (6.13 Status-Block, 6.14 g, Abschnitt 10) und in docs/06_Definition_of_Ready_und_Done.md. Die Zeile darf auf einen Zeiger schrumpfen, sobald eine Zitatprobe belegt, dass jedes zitierte Teilstück im Zielort wörtlich steht (grep -F). Entscheide gehen nie verloren, weil sie nur angefügt werden (Entwurf A.1).

### 2.6 Zellenlänge und Umfang

- Richtwert je Tabellenzelle 1'500 Zeichen, Obergrenze 3'000; ausgenommen die Abnahmekriterien (dort Obergrenze 5'000), damit ein testbares Kriterium nie gekürzt wird. Die Werte sind ein Vorschlag des Product Owners, kein Messergebnis; der Koordinator entscheidet, ob daraus eine Prüfung in make dod wird (DevOps Engineer).
- Der Umbau ändert keinen Eintrag, keinen Prüfaufwand und keine Summe. Prüfbar: 91 Überschriften, Summentabelle unverändert, Summe der Übersichtsspalte gleich Summentabelle.

### 2.7 Zwei Stufen

- Stufe 1 (Pflicht im Prozess-Schnitt): Kopf und Stand, Posten-Tabelle, Nachführungstabelle, Punktetabelle, Verkürzung der neun überlangen Zellen, Archiv.
- Stufe 2 (kann eine Folgeeinheit sein): Übersichtstabelle mit 91 Zeilen. Sie ist der teuerste Teil und nötig, wenn Status und Prüfaufwand je Eintrag künftig aus einer Tabelle gelesen werden sollen; sie hängt am ADR-Schnitt (ADR-Spalte).

## 3. Erhalt des heutigen Wortlauts

Kriterien: K1 Änderungshistorie erkennbar (Projektauftrag 6.6, Zeile 928); K2 feste Verweise mit Commit-Prüfsumme, Zeilenanker vermeiden (6.6, Zeile 938; dokumentation.md Zeilen 10 bis 20); K3 "fortgeschrieben, nicht stillschweigend überholt" (dokumentation.md Zeilen 35 und 36, gilt dem ADR, ist hier Massstab); K4 D20 und D7 prüfen gegen den Arbeitsbaum; K5 Wartungslast; K6 Migration mechanisch prüfbar.

| Kriterium | Option 1: eingefrorene Datei | Option 2: Historie nur in git |
|---|---|---|
| K1 | erfüllt: Archiv plus Nachführungstabelle | nur über Verweis erkennbar, nicht im Dokument |
| K2 | erfüllt: Pfad und Commit-Prüfsumme | erfüllt: blob/<40 Zeichen>/docs/05_Product_Backlog.md |
| K3 | erfüllt, wenn jede Änderung eine Nachführungszeile erhält | erfüllt unter derselben Bedingung |
| K4 | erfüllt: die 14 Zeilen-Treffer und 4 Ausnahmen bleiben gegen eine Datei im Arbeitsbaum prüfbar | nicht erfüllt: D20 kennt für Datei, Zeile und Anforderung nur den Arbeitsbaum; bei flachem Klon meldet D20 Lage C |
| K5 | Nachteil: eine zusätzliche Datei mit 845 Zeilen; kein Doppelbestand, weil sie nie fortgeschrieben wird | Vorteil: kein Zusatzbestand |
| K6 | Vorteil: Token-Vergleich alt gegen neu plus Archiv ist mit grep möglich | Nachteil: Vergleich nur mit git show und tiefem Klon |

Empfehlung: Option 1, mit zwei Schärfungen.

1. Pfad ausserhalb des D7-Globs: docs/archiv/05_Product_Backlog_bis_2026-10-22.md statt docs/05_Product_Backlog_bis_2026-10-22.md. D7 sucht den Backlog mit dem Muster "docs/05_Product_Backlog*.md" (Makefile Zeile 1206, Begründung Zeilen 1196 bis 1199); der Name aus dem Entwurf würde als zweiter Backlog erkannt und mit dem Abgleich "Backlog gegen Testkennungen" (6.6) gemischt, sobald D7 mit dem Grundgerüst scharf wird.
2. Einmaliger Schnitt, byte-identisch: Der Koordinator benennt die Datei nach dem Merge von Pull Request #28 mit git mv um (ein eigener Commit, die Historie folgt über die Umbenennung) und kopiert sie zurück nach docs/05_Product_Backlog.md. Die neue Datei beginnt als wörtliche Kopie; der Product Owner ändert sie nur an den benannten Stellen. Der Verweis mit der 40-stelligen Prüfsumme steht in der neuen Datei (Prüfsumme des Merge-Commits von Pull Request #28), nicht im Archiv; das Archiv bleibt unverändert. Es wird nie fortgeschrieben und nie ein zweites Mal angelegt.

Option 2 genügt 6.6 formal, trägt aber D20 nicht und lässt die 14 Zeilen-Treffer und die vier Ausnahmen ins Leere laufen.

Bauweise (spart Aufrufe und Abschreibfehler): Der Product Owner schreibt die Ersatzabschnitte (Kopf, Posten, Nachführungen, Punkte, die neun Zellen) als eigene Dateien im Scratchpad. Der Koordinator spleisst sie mit Bash anhand der Zeilennummern des byte-identischen Archivs in die neue Datei und prüft mit diff, dass nur die vorgesehenen Abschnitte abweichen. Ein Edit mit einer 16'000 Zeichen langen Zeile als alter Text wäre möglich, ist aber der fehleranfälligste Weg.

## 4. Regeltext, der geändert werden muss

### 4.1 Projektauftrag (Dokument des Auftraggebers: nur Vorschlag im Pull Request, der Merge entscheidet; weder der Product Owner noch der Koordinator ändern ihn von sich aus; Zeilen aus dem Grep dieser Sitzung)

| Stelle | Heute | Vorschlag |
|---|---|---|
| 6.6, Zeile 928 ("Lebenszyklus und Status") | "Jede Anforderung hat einen erkennbaren Status samt Änderungshistorie." | Satz anfügen: Die Änderungshistorie führt die Nachführungstabelle des Backlogs mit Fundort; ältere Wortlaute stehen in git (feste Verweise nach 6.6) und im eingefrorenen Stand bis 2026-10-22. |
| 6.6, Zeile 929 | "Das Änderungsprotokoll in Abschnitt 8 wird fortgeführt." | Eintrag "Prozess-Schnitt" in Abschnitt 8 (Zeile nicht erhoben). |
| 6.6, Zeile 938 | Zeilenanker vermeiden, Abschnittsname ergänzen | unverändert; optional anfügen: Fundorte im Backlog nennen Kennung, Posten-, Punkt- oder Nachführungsnummer, nie eine Zeilennummer. |
| 6.6, Zeile 940 | "Aufgenommen werden … Product Backlog, …" | "Product Backlog (dazu der eingefrorene Stand bis 2026-10-22)". |
| 3.3, Zeile 137 | Übergabedatei am Ende jeder Einheit | Das ist Entwurf C (eine Übergabedatei je Sitzung). Für das Backlog anfügen: Jede Backlog-Änderung erhält eine Zeile in der Nachführungstabelle; die Übergabedatei verweist darauf. |
| 6.3 Zeile 881, 6.4 Zeilen 889 bis 909, 6.5, 6.8 Zeile 1008 | Attribute je Eintrag, Satzschablone, Definition of Ready, Prüfaufwand | unverändert: Die Attribute bleiben in den Eintragsblöcken, der Prüfaufwand zusätzlich in der Übersicht. |

### 4.2 .claude/rules/dokumentation.md (Zeilen nach der nummerierten Lesung zu Beginn dieser Sitzung, Frontmatter Zeilen 1 bis 4 mitgezählt; vor dem Ändern mit grep -n prüfen)

- Zeilen 18 bis 20 ("Zeilenanker werden vermieden …"): Satz anfügen, dass Fundorte im Backlog Kennung, Posten-, Punkt- oder Nachführungsnummer nennen.
- Zeilen 22 bis 28 (Nachweisverzeichnis): Satz anfügen, dass der eingefrorene Backlog-Stand ein Artefakt mit eigener Zeile im Generator ist.
- Zeilen 35 und 36 ("Ein ADR bildet einen Stand ab. Ändert sich der Stand, wird der ADR fortgeschrieben, nicht stillschweigend überholt."): Das ist die Nachtrag-Regel, die Entwurf A.1 auf "aktueller Stand mit Entscheidlog" umstellt. Klarstellen: gilt für ADR, nicht für das Backlog.
- Neuer Abschnitt "## Product Backlog (6.3, 6.4, 6.6)" nach Zeile 41, vor Zeile 43 ("## Glossar (6.3)"). Vorgeschlagener Wortlaut:

```
## Product Backlog (6.3, 6.4, 6.6)
- Form: Übersichtstabelle; je Eintrag ein Block mit der Überschrift
  "### <Kennung> — <Titel>" (der Belegprüfer D20 liest die Kennungen aus diesen
  Überschriften); Tabellen "Posten unter R3-Q-010", "Nachführungen" und
  "Offene Punkte".
- Der Eintragsblock führt den aktuellen Stand. Der Verlauf steht in der
  Nachführungstabelle (eine Zeile je Änderung: Nr., Datum, Einheit, Änderung,
  Fundort) und in git. Keine Änderung ohne Zeile in der Tabelle.
- Entscheide des Auftraggebers und Abnahmen werden nur angefügt, nie
  überschrieben (Quelle bleibt ADR 0002, Abschnitt 10).
- Fundorte nennen Kennung, Posten-, Punkt- oder Nachführungsnummer, nie eine
  Zeilennummer.
- Der Stand bis 2026-10-22 liegt unverändert unter
  docs/archiv/05_Product_Backlog_bis_2026-10-22.md und wird nicht fortgeschrieben.
- Richtwert je Tabellenzelle 1'500 Zeichen, Obergrenze 3'000
  (Abnahmekriterien ausgenommen).
```

### 4.3 CLAUDE.md (Zeilen aus dem Grep dieser Sitzung)

- Zeile 24 (Zelle "5 Umsetzung", fünf Backlog-Verweise: Punkt 19, offener Punkt 22, "im Backlog unter R3-Q-011", "Backlog R3-Q-011", "Backlog Punkt 25"): fällt unter Entwurf A.3 (höchstens 10 Zeilen). Die Verweise bleiben gültig, solange "Punkt n" und die Kennungen stabil bleiben.
- Zeile 190 (Wo steht was, Zeile "Prüfmittel der beiden PreToolUse-Gates", Text "Backlog-Sammelposten unter R3-Q-010"): ändern in "Backlog, Tabelle Posten unter R3-Q-010".
- Zeile 195 (Wo steht was, Zeile "Fremde Inhalte im Harness", Text "Backlog-Eintrag R3-Q-011 in docs/05_Product_Backlog.md"): unverändert.
- Neue Zeile nach Zeile 196 (letzte Tabellenzeile "Schwachstellenregister"; Zählung aus den Fundzeilen 190 und 195 abgeleitet, vor dem Eintragen prüfen): "Product Backlog: Übersicht, Eintragsblöcke, Posten, Nachführungen, offene Punkte; eingefrorener Stand bis 2026-10-22" mit den Pfaden docs/05_Product_Backlog.md, docs/archiv/05_Product_Backlog_bis_2026-10-22.md und .claude/rules/dokumentation.md.

### 4.4 Folgeänderungen ausserhalb des Regeltexts

- scripts/nachweise-erzeugen.sh, Zeile 25 (Zeile "Product Backlog|docs/05_Product_Backlog.md|Einträge mit Kennung, Art, Abnahmekriterium und Prüfaufwand; Summen im Dokument"): eine Zeile für das Archiv anfügen; die Beschreibung bleibt zutreffend, solange die Summentabelle im Dokument bleibt (DevOps Engineer).
- scripts/belege-ausnahmen.txt, Zeilen 32, 39, 40, 55 (vier Ausnahmen mit der Datei docs/05_Product_Backlog.md: die dort ausgenommene Kennung (Zeile 32 der Ausnahmedatei), docs/datenschutz/, docs/konformitaet/, Commit 882ef55e377d… (in keinem Repository auflösbar, deshalb hier gekürzt)): für das Archiv doppeln; für die neue Datei nur behalten, was dort noch vorkommt. Ob D20 eine unbenutzte Ausnahme meldet, habe ich nicht gelesen.
- .github/pull_request_template.md (ein Treffer) und docs/06_Definition_of_Ready_und_Done.md Zeile 116 ("Zeilenform bleibt, wie der Backlog …"): ansehen und gegebenenfalls anpassen.
- ADR 0002 Zeilen 10024, 10059, 10829, 11278 und ADR 0001 Zeile 179 (Zeilen-Fundorte): bleiben gültig, solange die Zeilennamen in den Blöcken erhalten sind; sie wandern mit dem ADR-Schnitt des Software Architects.

## 5. Aufwand und Risiken

### 5.1 Aufwand in Aufrufen (Schätzung, plus/minus 30 Prozent; Feldnamen und Lesart nicht gelesen)

| Schritt | Rolle | Aufrufe |
|---|---|---|
| Umbenennen und zurückkopieren, make dod, awk-Messung der Zeilenlängen, Inventur von Kennungen, Prüfsummen, Daten und Abnahmekriterium-Namen aus dem Archiv | Koordinator (Bash) | 6 bis 8 |
| Stufe 1: Lesen von Kopf, Summe und Nachführungen, offenen Punkten, Zeile 101 und neun Zellen; Schreiben der Ersatzabschnitte; Greps | Product Owner | 18 bis 22 |
| Spleissen, diff, Zählprobe (91 Überschriften, Zitatprobe, Summe) | Koordinator (Bash) | 4 bis 6 |
| Statische Prüfung des ganzen Diffs (Entwurf B), Fundort-Treffer, Zitatprobe | Static Software Tester | 8 bis 12 |
| Ausnahmen, Generatorzeile, optional Zellenlängenprüfung in make dod | DevOps Engineer | 4 bis 6 |
| Regeltext (dokumentation.md, CLAUDE.md, Vorschlag zum Projektauftrag) | Koordinator | 6 bis 8 |
| Summe Stufe 1 | | 46 bis 62 |
| Stufe 2: Übersichtstabelle (Greps auf Prüfaufwand und Status je Etappe, drei bis vier Schreibvorgänge) | Product Owner | 10 bis 14 |
| Stufe 2: Prüfung | Static Software Tester | 4 bis 6 |

Bei Etappen von höchstens 20 Aufrufen (Entwurf E) sind das für den Product Owner zwei Etappen in Stufe 1 und eine in Stufe 2; die übrigen Rollen laufen in eigenen Etappen.

### 5.2 Risiken

1. D20 und die Überschriften: Fehlt eine "### R3-…"-Überschrift oder ändert sich die Kennung, wird jede Fundstelle im Bestand ein Scheinfund (belege-pruefen.sh Zeile 107; Makefile Zeilen 719 bis 721). Gegenmassnahme: 91 Überschriften wörtlich, Zählprobe vorher und nachher.
2. Ausnahmen: Die vier Einträge in belege-ausnahmen.txt hängen am Pfad der Datei. Ohne Doppelung für das Archiv entstehen Befunde im Archiv.
3. D7-Glob: Ein Archivname im Muster docs/05_Product_Backlog*.md wird als zweiter Backlog gelesen (Makefile Zeile 1206). Gegenmassnahme: Pfad docs/archiv/.
4. Zeilen-Fundorte: 14 Treffer "Backlog … Zeile" in 10 Dateien und 114 Pfadverweise in 29 Dateien. Die Zeilennamen der Blöcke (Zerlegung, Achtung, "Offene Posten nach der Abnahme") und die Nummern der Posten, Punkte und Nachführungen müssen erhalten bleiben; die Pfadverweise bleiben gültig. Gegenmassnahme: grep -n jedes der 14 Treffer nach dem Umbau, Prüfung am Gegenstand durch den Static Software Tester (D20 prüft nur, ob der Fundort existiert, nicht ob er die Aussage trägt: belege-pruefen.sh Zeilen 49, 50, 781).
5. Verlust von Entscheiden und Prüfsummen durch Verdichten: Gegenmassnahme: Token-Inventur im Archiv (40-stellige Hexketten, Daten, Kennungen R3-, SR-, DT-, ST-, L, G, A, GM-, KM-, Abnahmekriterium-Namen) gegen neue Datei plus Archiv; jede Kennung und jeder Kriteriumsname muss in der neuen Datei stehen, weil sie das aktuelle Backlog bildet.
6. Werkzeuglage: Der Product Owner hat kein Bash und kein git. Umbenennen, Kopie, Spleissen, awk und make dod braucht der Koordinator oder der DevOps Engineer. Die Summenprobe (Übersichtsspalte gegen Summentabelle) ebenso, damit keine Handrechnung entscheidet.
7. Reihenfolge: Der ADR-Schnitt (Software Architect, A.2) soll vor Stufe 2 stehen, sonst muss die ADR-Spalte zweimal geschrieben werden. Stufe 1 hängt nicht daran.
8. Nachweisverzeichnis: Ohne Zeile im Generator fehlt das Archiv in NACHWEISE.md (6.6, Zeile 940 listet den Product Backlog als Artefakt).
9. Rückfall auf Gewohnheit: Wird die Nachführungszeile nicht je Änderung geschrieben, ist die Historie nur noch in git und 6.6 Zeile 928 formal unerfüllt. Gegenmassnahme: Pflicht im neuen Abschnitt, Prüfpunkt im Auftrag an die statische Prüfung.

## 6. Nicht belegt in diesem Lauf, vor dem Bau zu prüfen

1. Abschnitt "Wie dieser Backlog zu lesen ist" (Zeilen 10 bis 38): Wortlaut, insbesondere die bestehende Nachtrag-Regel ("nur anfügen, Wortlaut nie überschreiben"; nach meinem Stand auch in ADR 0002, 6.1, Absatz "Anlass"). Sie ist im neuen Abschnitt zu ersetzen oder einzugrenzen.
2. Feldnamen und Zeilennamen der Eintragstabellen (Beispiel: R3-Q-011 Zeilen 144 bis 167). Der Vorschlag setzt voraus, dass jeder Block Prüfaufwand und Abnahmekriterien trägt; einen Statuswert je Eintrag habe ich nicht belegt gesehen.
3. Zeilen 737 bis 753 und 783 bis 816 (Summentabelle, Verbleib der Nachführungs-Nummern 1, 5, 8 bis 12).
4. Ob D20 oder ein anderer Kettenschritt Abschnittsüberschriften des Backlogs auflöst und ob D20 unbenutzte Ausnahmen meldet.
5. Genaue Länge der längsten Zeile (awk).

Rückfragen an den Koordinator: (a) Archivpfad docs/archiv/ statt des Namens im Entwurf (wegen des D7-Globs)? (b) Stufe 2 in dieser Einheit oder als Folgeeinheit nach dem ADR-Schnitt? (c) Zellenlängen nur als Regel oder als Prüfung in make dod? (d) Spleissen durch den Koordinator, wie in Abschnitt 3 beschrieben?
