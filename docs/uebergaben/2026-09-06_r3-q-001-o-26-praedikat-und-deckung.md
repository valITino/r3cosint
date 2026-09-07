# Übergabe 2026-09-06 — R3-Q-001: O-26 umgesetzt, Runden 9 bis 11, nach 3.4 abgebrochen, O-27 vorgelegt

Eskalation 3.4: R3-Q-001 Abnahmekriterium 6.12.27 g Teil 2 (Fremdmutationsrunde)

Arbeitseinheit auf den Entscheid des Auftraggebers vom 2026-09-06 zu O-26.
Vorangegangen ist der Bericht des Koordinators vom 2026-09-05 ("O-26
entscheiden; gitleaks in die Umgebungsdefinition aufnehmen; /usage prüfen;
Empfehlung unverändert: noch nicht mergen. Nach der Weisung zu O-26 folgen eine
Einheit Umsetzung mit neunter Runde, dann der Merge beider Pull Requests, dann
E4 und E3, dann das Grundgerüst als erster Produktcode."). Antwort des
Auftraggebers im Wortlaut: "Na dann weiter gehts, so wie du es sagst". Lesart:
Der Vorschlag O-26 wird angenommen, wie er in ADR 0002, 6.12.26 g steht — alle
fünf Bausteine (a) bis (e) werden umgesetzt, danach läuft die neunte Prüfrunde
nach dem Abnahmekriterium. Das ist keine förmliche Freigabe der Entscheidpunkte
E-A bis E-K und keine Abnahme des Gates (Abschnitt 10). Vorangegangen ist die
Einheit vom 2026-09-03/04 (`docs/uebergaben/2026-09-04_r3-q-001-o-25-kanal-und-mutation.md`,
Commit `ce8ed8a0487d6b7dc8b2f805d3110996fd50e765`), die nach Projektauftrag 3.4
abgebrochen wurde. Diese Einheit erstreckt sich über den 2026-09-06 und den
2026-09-07 (Abschluss); sie hat die Nutzungsgrenze der Sitzung mehrfach
gerissen und einen Neustart des Containers gegen 11:10 UTC überstanden
(Arbeitsbaum und Zwischenstände blieben erhalten). Die Einheit wurde als
Aufgabe #14 geführt (O-23, Entscheid E-H).

## Ergebnis in einem Absatz

Der Entscheid O-26 ist vollständig umgesetzt: Die Tabelle 6.12.19 trägt je
Zeile ein Prädikat aus einem geschlossenen Vorrat von neun Werten, das die
Messhülle über ihren Namen bindet und der Selbsttest maschinell abgleicht; die
Tabelle wird gegen den Text des ADR gehalten (jeder Zählschlüssel aus 6.12.4,
jedes Element der Markengrammatik aus 6.12.7, jede normative Aussage aus 6.12.9
und 6.12.15 hat eine Zeile, in beide Richtungen) und zusätzlich gegen das Gate
selbst (jedes Schlüsselliteral aus `dod-gate.sh` hat eine Zeile); die
Ausgabeform ist als Invariante über alle Gate-Aufrufe gemessen. Der Selbsttest
umfasst 207 Zusicherungen, beide Modi enden mit Rückgabewert 0 (207 von 207;
197 von 197 tabelleneigenen Mutationen erkannt, zehn begründete Ausnahmen).
Teil 1 des Abnahmekriteriums aus 6.12.27 g ist in den Runden 9, 10 und 11
erfüllt und statisch bestätigt. **Teil 2 — eine Fremdmutationsrunde ohne
blockierenden Befund in den vier Kategorien — ist dreimal nicht erfüllt**
(Runde 9: drei, Runde 10: sieben, Runde 11: zehn unerkannte Fremdmutationen).
Die Einheit ist deshalb, wie in ADR 0002, 6.12.27 j Punkt 8 vorab festgelegt,
**nach Projektauftrag 3.4 abgebrochen**; kein Befund der Runde 11 ist in dieser
Einheit behoben. Die Klasse ist benannt: Die Deckung war je Runde an einer
Aufzählung festgemacht (Schlüssel, Kürzel, Aussagen), nicht am Gegenstand
(Schwächungen des Markenmusters, unbetretene Ausgangspfade des Gates, mehrere
Aufrufstellen einer Aussage). Das Gate selbst war in elf Runden gegen echte
Bäume nie falsch grün. Vorgelegt wird **O-27** (ADR 0002, 6.12.27 k) mit zwei
Wegen und der Einschätzung des Koordinators.

## Der Entscheid O-26 und seine Ausformung (ADR 0002, 6.12.27)

Der Software Architect hat den Entscheid als Abschnitt 6.12.27 des ADR 0002
festgeschrieben und in dieser Einheit dreimal fortgeschrieben; er lief auf
einem anderen Modell als der DevOps Engineer, hat nichts ausgeführt und die
Tabellenänderungen als Zuordnungsdateien geliefert, die der Koordinator
mechanisch eingesetzt und geprüft hat.

- **a) bis h) (Grundfassung):** Entscheid mit Wortlaut und Lesart (a);
  Prädikatvorrat mit neun Werten `zeile-woertlich`, `enthaelt`, `gleich`,
  `einzelfeld`, `leer`, `existiert`, `fehlt`, `ausserhalb`, `kleiner` — die
  Ergänzung `kleiner` für `Z-152` und `Z-181` begründet — und Bindungsregeln
  Wortlaut zu Prädikat (b); Schlüsseldeckung gegen 6.12.4 mit
  Ersetzungsvorschrift in beide Richtungen — die vollständige Erhebung fand
  zehn ungedeckte Schlüssel statt des einen aus `DT8-02` (c);
  Grammatikdeckung über eine neue Elementtabelle in 6.12.7 (d); `Z-040` und
  `Z-080` berichtigt, `Z-156` bis `Z-184` neu (e); Zahlen und Meldepflicht des
  Baus (f); das Abnahmekriterium — Teil 1: tabelleneigene Mutationen
  vollständig erkannt und alle Deckungen ohne Abweichung; Teil 2: eine
  Fremdmutationsrunde in den Kategorien Schlüssel (6.12.4), Grammatik (6.12.7),
  Schwellen und Ereignisfolge (6.12.9) und Ausgabeform (6.12.15), blind
  gewählt, ohne blockierenden Befund; 3.4 gilt für die blockierenden Befunde
  dieser Runde (g); Entscheide zu S8-01, S8-03, S8-05, S8-06, S8-07 (h).
- **i) (nach Runde 9):** Beleglage der Runde 9; zehntes Grammatikelement
  `ENDE`; Aussagentabellen in 6.12.9 (`E01` bis `E22`) und 6.12.15 (`A01` bis
  `A07`) mit mechanischer Aussagendeckung über Etiketten `Aussage <KUERZEL>: `
  in der Fallspalte; typisierte Hüllen für die Kanäle `beobachter` und
  `datei` (S9-01, S9-02); Regel "der tragende, positive Teil bindet" (S9-03);
  Schlüsseldeckung mit vollständiger Übereinstimmung des Backtick-Abschnitts
  (S9-04); Grenze der Grammatikdeckung benannt (S9-05); `Z-185` bis `Z-193`.
- **j) (nach Runde 10):** Beleglage der Runde 10 und die Klasse "Deckung an
  der Aufzählung statt am Gegenstand"; Gegenstandsdeckung Schlüssel aus den
  Literalen des Gates (24 Literale, neun davon ohne Zeile); Ausgabeform als
  Invariante über alle Gate-Aufrufe mit der neuen Aussage `A08` (das Gate
  endet ausschliesslich mit 0 oder 2); elftes Grammatikelement `ANFANG` und
  eine Erzeugerseiten-Zeile (`Z-199`, Marken des echten `Makefile` gegen das
  aus dem Gate gelesene Muster); `Z-194` bis `Z-208`; `Z-109` im Wortlaut
  verankert (S10-01), `Z-190` in der Mutationsspalte verengt (S10-07);
  Entscheide zu S10-02, S10-04, S10-05, S10-06; Punkt 8: Runde 11 als dritter
  Versuch an Teil 2, ihr Fehlschlag vorab als Abbruch nach 3.4 festgelegt;
  Punkt 9: die eine Berichtigung am Gate (Meldungsform des Blocks `GATE jq`,
  Zeile 110, kein Verhaltenswechsel).
- **k) (nach Runde 11, Abschluss dieser Einheit):** Beleglage der Runde 11,
  Abbruch nach 3.4, Vorlage O-27 — geschrieben vom Software Architect nach
  dem Entscheid des Koordinators; Abschnitt 8 mit neuer Zeile O-27, Abschnitt
  9 mit Zeile "Nachtrag k", Kopfzeile.
- Weiter geändert: Absatz vor der Tabelle 6.12.19; zwei Berichtigungen in
  6.12.26 a (Kanal `selbsttest` um die statische Lesung erweitert; "Menge" auf
  Reihenfolge); Abschnitt 8: O-26 "entschieden am 2026-09-06, siehe 6.12.27";
  Abschnitt 9: Zeilen "Siebzehnte Fortschreibung" mit Nachträgen i, j und k;
  Kopfzeile. **Abschnitt 10 ist unverändert** (keine Freigabe, keine Abnahme).
- Tabelle 6.12.19 am Ende: 208 Zeilen `Z-001` bis `Z-208`, sieben Spalten
  (neu: Prädikat), `Z-110` zurückgezogen, also 207 Zusicherungen und 209
  Messhüllen; Verteilung der Prädikate `gleich` 132, `enthaelt` 35, `fehlt` 12,
  `leer` 9, `existiert` 7, `einzelfeld` 6, `ausserhalb` 4, `kleiner` 2,
  `zeile-woertlich` 2 — vom Koordinator mechanisch geprüft (keine Dublette,
  keine Lücke, 7 Spalten je Zeile) und in den Runden 9 bis 11 statisch
  bestätigt. Form der neuen ADR-Zeilen (1383 hinzugefügt, 161 entfernt
  gegenüber `ecd0f0029b7945c473a26385f74da70fbb937156`, vor Nachtrag k): 0
  Eszett, 0 typografische Anführungszeichen, 0 veränderliche Zweigverweise
  (Regel 6.6).

## Was gebaut ist

Gebaut hat der DevOps Engineer in sechs Phasen (mehrere Instanzen wegen der
Zuggrenzen und des Sitzungslimits; die Prüfer liefen auf einem anderen Modell,
3.4). Der Koordinator hat jede Phase mit eigenem Lauf abgenommen (eigenes
`XDG_STATE_HOME`, Prüfsummen von Gate, Selbsttest, Mutationsdatei, `Makefile`,
Lagenliste und ADR vorher und nachher gleich, `git status` unverändert).

- **`scripts/dod-gate-selbsttest.sh`** (4427 Zeilen): `PRAEDIKAT_VORRAT` mit
  neun Werten; `_melde` meldet Kanal und Prädikat (`[kanal/praedikat]`); jede
  typisierte Hülle bindet ihr Prädikat über den Namen; neue Zeilenhüllen
  `pruefe_stderr_zeile` (`Z-040`) und `pruefe_selbsttest_zeile` (`Z-153`, je
  `grep -Fxq`); typisierte Datei- und Beobachterhüllen (`pruefe_datei`,
  `pruefe_datei_ausserhalb`, `pruefe_datei_gleich`, `pruefe_beobachter`,
  `pruefe_beobachter_enthaelt_ausserhalb`, `beobachter_start` flach und
  rekursiv mit Zeitmarke je Protokollzeile, `beobachter_start_spur` für
  `Z-109`); `pruefe_json_einzelfeld` mit `jq -es` und `length == 1`;
  `pruefe_kette_fehlt`; die vier Invariantenhüllen über jeden Gate-Aufruf
  (Protokoll `rufe_gate`/`rufe_gate_ohne_home`, 124 Aufrufe); `pruefe_wahr`
  verbleibt nur für `dauer` und `selbsttest` (`Z-152`, `Z-181`); die
  `*_wahr`-Hüllen nehmen das Prädikat aus einem je Hülle festen Teilvorrat,
  die Wache lässt den Fall fehlschlagen. Beide Tabellenparser lesen sieben
  Spalten (Kanal Spalte 3, Prädikat Spalte 4, Zusicherung Spalte 5); Rückzug
  über die Kanalspalte (S8-01). Mechanische Prüfungen am Ende: Deckung,
  Kanalabgleich, Prädikatabgleich, Schlüsseldeckung (6.12.4, Vollmatch,
  Gegenrichtung), Gegenstandsdeckung Schlüssel (Literale aus dem Gate,
  Variablenanteil als ein oder mehr Wörter), Grammatikdeckung (6.12.7, elf
  Kürzel), Aussagendeckung (6.12.9 und 6.12.15, 30 Kürzel, Gegenrichtung und
  Etikettwache). Zählersicherung: Zähler werden am Ende aus den gemeldeten
  Kennungen neu gebildet, Divergenz wird gemeldet, jede FEHLGESCHLAGEN-Meldung
  erzwingt Rückgabewert 2. Mutationsmodus `--mutationen` unverändert nach
  6.12.26 b, ergänzt um eine `make`-Attrappe im Werkzeugkasten für `Z-164` und
  `Z-165` (GNU make liefert bei fehlgeschlagenem Rezept immer 2, nie den
  `exit N` der Rezeptzeile — Befund aus dem Bau, mit Gegenbeleg).
- **`scripts/dod-gate-mutationen.txt`**: 207 Einträge, 197 mit `sed` und
  zehn mit `keine` (`Z-152`, `Z-153` Grund 1; `Z-043`, `Z-045`, `Z-048`,
  `Z-068` Grund 2; `Z-114`, `Z-139`, `Z-155`, `Z-169` Grund 3). `Z-040` auf die
  Eskalationsschwelle (M-01) umgestellt; `Z-198` trifft beide Anker des Gates
  (awk-Vorfilter Zeile 858 und `marken_muster` Zeile 885), weil die Mutation
  am Muster allein ein äquivalenter Mutant ist; `Z-199` zielt auf
  `MARKE_SUFFIX` des `Makefile`; die Bereichsanker von `Z-021`, `Z-022` und
  `Z-192` vom alten Wortlaut auf `^if ! command -v jq` umgestellt. Konvention
  der Datei (kein Hochkomma im Ausdruck) nach einer Nachbesserung an `Z-170`
  bis `Z-173` eingehalten.
- **`.claude/hooks/dod-gate.sh`**: drei Änderungen, keine davon ändert das
  Verhalten — der alte, unerreichbare Block `GATE sha256sum` entfernt (S8-03),
  Nicht-ASCII in zwei Kommentaren ersetzt (S8-07), und Zeile 110 in die
  einheitliche Meldungsform gebracht ("dod-gate: BLOCKIERT. Schluessel: GATE
  jq. 'jq' ist nicht installiert; die Eingabe auf der Standardeingabe kann
  nicht gelesen werden.", 6.12.27 j Punkt 9). `Makefile`,
  `.claude/settings.json` und `.claude/hooks/dod-gate-terminierte-lagen.txt`
  sind unverändert (bytegleich mit `ecd0f0029b7945c473a26385f74da70fbb937156`).
- **Endstand beider Modi** (Lauf des Koordinators am 2026-09-06, 22:55 UTC,
  in den Runden 11 statisch und dynamisch bestätigt): Normalmodus "Selbsttest:
  207 von 207 Zusicherungen bestanden", "Deckung: 207 Kennungen in der
  Tabelle, 207 geprueft, 0 ohne Pruefung, 0 ohne Kennung", "Kanalabgleich: 207
  Kennungen, 0 Abweichungen", "Praedikatabgleich: 207 Kennungen, 0
  Abweichungen", "Schluesseldeckung: 14 Schluessel, 0 ohne Zeile, 0 fremde
  Schluessel", "Grammatikdeckung: 11 Kuerzel, 0 ohne Zeile", "Aussagendeckung:
  30 Kuerzel, 0 ohne Zeile, 0 fremde Etiketten, 0 Doppeletiketten",
  "Gegenstandsdeckung Schluessel: 24 Literale, 0 ohne Zeile", Rückgabewert 0,
  41 s; Mutationsmodus "Mutationen: 197 geprueft, 197 erkannt, 0 nicht
  erkannt, 10 ohne Mutation (keine), 0 wirkungslos", Rückgabewert 0, 173 s.

## Bau in sechs Phasen und Zwischenkontrollen

- **Phase 1** (Parser, Prädikatmeldung und -abgleich, Schlüssel- und
  Grammatikdeckung, Gate S8-03/S8-07): Lauf 153 von 154 (`Z-080`), 29
  Kennungen ohne Prüfung — erwartet. Befund aus dem Bau: `Z-080` im
  berichtigten Wortlaut war am `Makefile` falsch (der Beschaffungsweg steht
  auf der eigenen Zeile "Beschaffen: …", Zeile 712, nicht auf der
  Lage-C-Zeile 711); gemeldet statt angepasst, Wortlaut vom Architekten
  berichtigt.
- **Zwischenkontrolle SST-B5-01** (Static Software Tester, statisch ohne Lauf):
  nicht bestanden, Fehlerklasse ja. Blockierend SST-B5-01 (`Z-130` meldete
  `gleich`, mass aber `grep -qF` — Prädikat aus der Tabelle abgeschrieben
  statt aus der Messung, Selbstauskunft statt Bindung) und SST-B5-02 (`Z-080`
  folgte der berichtigten Zeile noch nicht). Zahl der anfänglichen
  Prädikatabweichungen am alten Bau, aus dem Diff bestimmt: eine mechanisch
  zwingend (`Z-040`), zwei sachlich (dazu `Z-153`); die vom Bau gemeldete 0
  stammte aus einem Lauf nach der Umstellung und mass nichts (SST-B5-08).
  Nachrangig SST-B5-03 bis SST-B5-10, darunter zusammengesetzte Messungen
  (SST-B5-09) und die Präfix-Eigenschaft der zwei `LISTE`-Schlüssel
  (SST-B5-10) — beide an den Architekten (Nachtrag i, S9-03 und S9-04).
- **Phase 2** (SST-B5-01 bis SST-B5-07 behoben, `Z-156` bis `Z-184` gebaut):
  183 von 183, alle Abgleiche 0. Für die Grammatikzeilen `Z-170` bis `Z-179`
  liefert das Gate den im ADR abgeleiteten Ausgang (`KETTE ausgabe-unlesbar`,
  Rückgabewert 2) — bestätigt, keine Abweichung.
- **Zwischenkontrolle SST-B5-02** (Static Software Tester, Schnappschuss von
  Phase 2): bestanden, Fehlerklasse nein; alle Behebungen und alle 29 neuen
  Fälle einzeln nachgeprüft; nachrangig SST-B5-11 bis SST-B5-16 (in Phase 3
  und 5 behoben). `Z-165` in zwei Anläufen des Bauers fehlgeschlagen, im
  dritten und im Koordinatorlauf bestanden — Schwelle 3.4 nicht berührt.
- **Phase 3** (Mutationen): 183 Einträge, erster Lauf vier nicht erkannt
  (`Z-164`: spätere Konsistenzwache fängt den Fall; `Z-171` bis `Z-173`: Feld
  und Trennleerzeichen als eine Gruppe), zweiter Lauf 173 von 173.
- **Phase 4** war die Verifikation Runde 9 (unten).
- **Phase 5** (Runde-9-Befunde, `Z-185` bis `Z-193`, Aussagendeckung,
  typisierte Beobachter- und Dateihüllen): Der erste Normallauf 189 von 192,
  weil die neue Beobachterhülle Trefferzeilen je Abfrage statt Dateien
  zählte, den Wurzelordner des Scheinbaums traf und alte Rückstände unter
  `/tmp` sah; im Mutationsmodus danach 179 von 182 (`Z-106`, `Z-109`,
  `Z-188`). Ursache des `Z-109`-Fehlschlags im Original: `/tmp` der Sandbox
  trug rund 91 000 verwaiste `tmp.*`-Einträge aus abgebrochenen Läufen; ein
  Glob dauerte länger als die Haltezeit der Wegwerfdatei. Massnahmen:
  Sandbox-Hygiene durch den Koordinator (91 431 Einträge älter als 120
  Minuten entfernt, kein Eingriff ins Repository) und der Beobachter für
  `Z-109` an die Spur gebunden (`beobachter_start_spur`). Endstand 192 von
  192; 182 von 182.
- **Phase 6** (Nachtrag j: Gegenstandsdeckung Schlüssel, Invarianten,
  `ANFANG`, Erzeugerseite, `Z-194` bis `Z-208`): Die Invariante `Z-196`
  (`A05`) fiel im **Original** an genau einem Pfad, dem Block `GATE jq` —
  dieselbe Klasse wie DT10-06/07, von der Invariante gefunden statt von einer
  Prüfrunde; Entscheid des Koordinators: Meldungsform an dieser einen Stelle
  vereinheitlichen (6.12.27 j Punkt 9). Befund am Selbsttest aus dem ersten
  6b-Lauf: "FEHLGESCHLAGEN Z-196" bei Schlusszeile "206 von 206" und
  Rückgabewert 0 — ein Variablenschatten (Parameter `gesamt` der neuen Hülle
  `pruefe_kette_fehlt` überschrieb den globalen Zähler); behoben und doppelt
  gesichert (Zählersicherung oben), Beleg: Lauf vor der Gate-Änderung "206
  von 207" mit Rückgabewert 2. `Z-199` zweimal vor dem Bau berichtigt (die
  Übersichtszeilen tragen den Suffix, die rohen Marken nicht; neuer minimaler
  Scheinbaum mit echtem `Makefile` und echtem Belegprüfer — `make dod` dort
  Rückgabewert 2, Form 2, 14 Übersichtszeilen, Lage B für D1, D2, D3, D4, D18,
  D5, D6, D8, D9, D10 und Lage C für D20, D7, D11, D12). Erster Mutationslauf
  196 von 197: `Z-198` war am Muster allein nicht erkennbar, weil das Gate die
  Übersichtszeilen vorab mit awk auf `^::LAGE ` filtert — Folge: die
  Fremdmutation M08 der Runde 10 (DT10-04) war am Gate wirkungslos, der
  Prüfer hatte sie an einer Musterprobe belegt, nicht am Gate; ADR und
  Mutation berichtigt. Endstand 207 von 207; 197 von 197.

## Verifikation (3.4)

Alle Prüfungen liefen auf einem anderen Modell als die Umsetzung, je in einer
Wegwerfkopie des Arbeitsbaums; die Prüfsummen der sechs Dateien im Original
waren vorher und nachher gleich, `git status` unverändert. Die Prüfer durften
Mutationsdatei und Tabelle 6.12.19 erst nach der schriftlichen Wahl ihrer
Fremdmutationen lesen (Zeitmarken im Prüfprotokoll). `shellcheck` fehlt in
der Umgebung: Lage C der statischen Prüfung in allen Runden.

### Runde 9 (Stand nach Phase 3: 183 Zusicherungen, 173 Mutationen)

- **Statisch: nicht bestanden, Fehlerklasse ja, Teil 1 erfüllt.** Alle
  Zahlen aus 6.12.27 f eigenständig bestätigt, alle 173 `sed`-Ausdrücke
  einzeln wirksam, 29 neue und drei berichtigte Zeilen Wort für Wort geprüft.
  Blockierend S9-01 (`Z-109`) und S9-02 (`Z-106`): zwei Altzeilen melden den
  Kanal `beobachter`, ohne einen Beobachter zu benutzen — Selbstauskunft statt
  Bindung bei den freien Kanälen (Klasse S5-01, für dieses Kriterium zweiter
  Auftritt, Schwelle 3.4 nicht erreicht). Nachrangig S9-03 bis S9-07.
- **Dynamisch: nicht bestanden, Fehlerklasse ja, Teil 1 erfüllt, Teil 2
  nicht.** 19 Fremdmutationen um 09:18:36 UTC blind gewählt, erster Blick in
  die Mutationsdatei 09:20:39; zehn deckungsgleich, sieben Ersatzmutationen
  nachgewählt (als schwächere Blindheit offengelegt). 16 nicht
  deckungsgleiche (3/4/5/4 je Kategorie), **drei nicht erkannt, alle aus der
  Nachwahl**: DT9-01 (Endanker `$` des `marken_muster` entfernt — die
  Elementtabelle kannte die Terminierung nicht), DT9-02 ("anderer Schlüssel
  setzt den Zähler auf eins" ungemessen), DT9-03 ("ein Durchlass löscht den
  Zähler" ungemessen). Negativbefunde: Gate gegen die Kopie als echten Baum
  für alle drei Ereignisse fail-closed, Eskalationsfolge über zehn Ereignisse
  lückenlos, 21 Gate-Läufe nur mit 0 oder 2, Nebenläufigkeit serialisiert.
- **Entscheid des Koordinators:** kein Abbruch — erster Fehlschlag an Teil 2.
  Behebung an der Quelle: Terminierung als Grammatikelement, Aussagentabellen
  mit mechanischer Aussagendeckung, typisierte Hüllen für `beobachter` und
  `datei` (Nachtrag i, Phase 5), danach Runde 10.

### Runde 10 (Stand nach Phase 5: 192 Zusicherungen, 182 Mutationen)

- **Statisch: bestanden, Fehlerklasse nein, Teil 1 erfüllt.** Zahlen aus
  6.12.27 f und i bestätigt, alle 182 `sed`-Ausdrücke wirksam,
  Schlüsseldeckung mit Vollmatch nachgerechnet (S9-04 behoben), Grammatik
  10/0, Aussagen 29/0 aus der ADR-Datei allein, S9-01/S9-02 behoben.
  Nachrangig S10-01 bis S10-08 (Entscheide in 6.12.27 j Punkt 6).
- **Dynamisch: nicht bestanden, Fehlerklasse ja, Teil 1 bestätigt, Teil 2
  nicht.** 31 Fremdmutationen (7/8/8/8) um 20:55:43 UTC festgeschrieben, erster
  Blick 20:55:49, Nachwahl von vier (als solche gekennzeichnet); 35
  Mutationen, alle wirksam, **sieben nicht erkannt** (drei blind, vier aus der
  Nachwahl): DT10-01 `LISTE 5` ungemessen, DT10-02 `LISTE 6` an fünf Stellen
  ungemessen, DT10-03 `GATE dod-gate-terminierte-lagen.txt` ungemessen,
  DT10-04 Zeilenanker `^` des Musters (M08 — nach Phase 6 als am Gate
  wirkungslos erkannt, siehe oben), DT10-05 Abschluss auf der Erzeugerseite
  (`MARKE_SUFFIX` im `Makefile`; die Kette fängt es als falsch rot, kein
  falsches Grün), DT10-06 `A04` auf dem Pfad des dritten Ereignisses, DT10-07
  `A05` auf dem Pfad ab dem vierten Ereignis. Kategorie Schwellen und
  Ereignisfolge vollständig erkannt. Klasse (Prüfer): Die Deckung ist an der
  Aufzählung festgemacht, nicht am Gegenstand.
- **Entscheid des Koordinators:** kein Abbruch — zweiter Fehlschlag an Teil 2.
  Behebung an der Klasse: Gegenstandsdeckung Schlüssel aus dem Gate,
  Ausgabeform als Invariante, `ANFANG` und Erzeugerseite, je Literal eine
  Zeile (Nachtrag j, Phase 6). **Runde 11 als dritter Versuch, ihr Fehlschlag
  vorab als Abbruch nach 3.4 festgelegt** (6.12.27 j Punkt 8).

### Runde 11 (Endstand: 207 Zusicherungen, 197 Mutationen)

- **Statisch: bestanden, Fehlerklasse nein, Teil 1 erfüllt.** Beide Modi in
  der Kopie mit Rückgabewert 0 (207 von 207, alle Deckungen und Abgleiche 0,
  Gegenstandsdeckung 24/0; 197 von 197, 174 s). Alle Zahlen aus 6.12.27 j
  Punkt 7 eigenständig bestätigt; Gegenstandsdeckung unabhängig und strenger
  nachgerechnet (24/0); alle 197 `sed`-Ausdrücke einzeln wirksam (`Z-198`
  trifft beide Anker, `Z-208` genau fünf Zeilen); Invarianten erfassen alle
  124 Gate-Aufrufe, einzeln trennscharf; Zählersicherung geschlossen;
  Gate-Diff genau die drei Blöcke plus Zeile 110; `Makefile` und Lagenliste
  bytegleich; Abschnitt 10 zeichengleich; ASCII 0, Eszett 0, typografische
  Anführungszeichen 0, veränderliche Zweigverweise 0. Nachrangig S11-01 bis S11-10; darunter
  eine **neue Klasse "eine Deckung besteht leer, wenn ihr Lesen misslingt"**:
  S11-04 (`Z-199` besteht bei leerem `marken_muster`, weil ein leeres Muster
  jede Zeile trifft), S11-05 (Gegenstandsdeckung ohne Mindestzahl und
  Gegenrichtung — "0 Literale, 0 ohne Zeile" bestünde), S11-06
  (Grammatikdeckung ohne Mindestzahl und Gegenrichtung); ferner S11-02
  (Mutationsspalte `Z-190` nennt die Zweigbeschränkung nicht), S11-03
  (`Z-194` bis `Z-197` gleicher Falltext), S11-09 (Variablenanteil als
  Zeichen statt Wörter, heute folgenlos), S11-10 (Auswahl der
  Übersichtszeilen enger als der Zeilenwortlaut); S11-01, S11-07, S11-08
  betrafen Zahlen im Entwurf dieser Übergabe (berichtigt).
- **Dynamisch: nicht bestanden, Fehlerklasse ja, Teil 2 nicht erfüllt —
  dritter Fehlschlag.** 31 Fremdmutationen um 23:07:05 UTC blind gewählt
  (7 Schlüssel, 8 Grammatik, 8 Schwellen und Ereignisfolge, 8 Ausgabeform),
  Wirkungsproben am Gate 23:08 bis 23:09, erster Blick in Mutationsdatei und
  Tabelle 23:10:22, **keine Nachwahl**; 29 verhaltensändernd, zwei
  äquivalent (G7: Anker allein am Muster — bestätigt den Befund aus Phase 6;
  E5). 19 erkannt, **zehn nicht erkannt, alle in den vier Kategorien**:
  - Grammatik (Gate Zeile 885, je Rückgabewert 2 → 0 für eine missgebildete
    Marke): DT11-01 `ABSCHLUSS` gegen einfachen Doppelpunkt; DT11-02
    Leerzeichen vor der Rückgabewertklammer; DT11-03 `KENNUNG` leer statt
    fehlend (Doppelleerzeichen; die Einheitlichkeitsprüfung der Lauf-Kennung
    griffe nicht mehr); DT11-04 `SCHWELLE` mit zusätzlicher Alternative;
    DT11-05 `ENDE` mit nachlaufendem Leerzeichen.
  - Schwellen und Ereignisfolge: DT11-06 `E21` zweite Hälfte ("genannt werden
    alle") nur an einer der drei Aufrufstellen von
    `weitere_abweichungen_ausgeben` gemessen; die Tabellenmutation `Z-051`
    trifft alle drei zugleich und verdeckt das.
  - Ausgabeform: DT11-07, DT11-08, DT11-09 `A08` an drei Blockpfaden, die der
    Selbsttest nie aufruft (ungültiges JSON, unbekanntes Ereignis, kein
    bestimmbarer Baum; `exit 2` → `exit 3` unerkannt); DT11-10 Zeile 119 ohne
    `>&2` (Blockgrund auf der Standardausgabe, unerkannt).
  - **DT11-11, Befund am Original ohne Mutation:** dieselben drei Blockpfade
    (Zeilen 119/120, 127/128, 429/430) und der Pfad "Sperre länger als 120 s"
    (Zeilen 581 bis 584, gelesen, nicht ausgeführt) enden mit 2, ohne dass die
    Fehlerausgabe "Schluessel: " nennt — dieselbe Klasse wie `GATE jq`
    (6.12.27 j Punkt 9); die Invariante `Z-196` erreicht diese Pfade nicht.
  - Negativbefunde: Die Gegenstandsdeckung Schlüssel wirkt — sechs
    Umbenennungen an je einer von mehreren Fundstellen erkannt, Kategorie
    Schlüssel als einzige vollständig (7 von 7); Schwellen und Ereignisfolge
    bis auf DT11-06 erfüllt; 22 Gate-Aufrufe gegen echte Bäume nur mit 0 oder
    2, Ausgabeform je Durchlasspfad, Eskalationsfolge über 15 Ereignisse nach
    `E14` bis `E20` (`TaskCompleted` blockt weiter, der Zähler zählt über den
    Durchlass hinweg), Nebenläufigkeit serialisiert, D19-Unversehrtheit.
  - Klasse (Prüfer): Nachtrag j hat die Deckung am Gegenstand nur für die
    Schlüssel gebaut. Für die Grammatik fehlt sie (die Elementtabelle zählt
    auf, woraus die Marke besteht, nicht auf wie viele Arten jedes Element
    verletzt werden kann), und für Ausgabeform und Ereignisfolge gilt die
    Invariante über alle **protokollierten** Aufrufe, nicht über alle
    **Pfade** des Gates.
- **Entscheid des Koordinators: Abbruch nach 3.4**, wie in 6.12.27 j Punkt 8
  vorab festgelegt (Runden 9, 10 und 11 sind drei Fehlschläge an Teil 2).
  Kein Befund der Runde 11 wird in dieser Einheit behoben — auch nicht
  DT11-11 und S11-04 bis S11-06, obwohl jede Behebung klein wäre: Weiter zu
  beheben, ohne den Massstab zu ändern, hiesse, einen zwölften Versuch an
  einem Kriterium zu beginnen, das dreimal nicht konvergiert ist (3.4). Der
  Stand wird mit dieser Übergabe committet und dem Auftraggeber vorgelegt.

## Vorgelegt: O-27 (ADR 0002, 6.12.27 k)

Zwei Wege, je mechanisch beschrieben; der Entscheid liegt beim Auftraggeber.

- **Weg (a) — Deckung am Gegenstand für Pfade und Grammatik, eine weitere
  Einheit mit Runde 12.** (a1) Pfaddeckung: Der Selbsttest erhebt aus dem
  Gate jede Ausgangsstelle (jedes `exit`) und verlangt, dass die
  protokollierten Aufrufe jede Stelle mindestens einmal beschritten haben —
  messbar über eine Ausführungsspur des Gates (`bash -x` mit `BASH_XTRACEFD`
  in einer Wegwerfkopie, ohne Änderung am Gate); damit decken die Invarianten
  `A01`, `A04`, `A05`, `A08` alle Pfade, DT11-07 bis DT11-10 eingeschlossen.
  (a2) Grammatik am Gegenstand: Der Selbsttest erzeugt aus dem `marken_muster`
  des Gates mechanisch Schwächungen (je Anker entfernt, je `+` zu `*`, je
  Zeichenklasse geweitet, je Literal optional, je Alternative erweitert) und
  verlangt, dass jede Schwächung, die eine missgebildete Probemarke annimmt,
  eine Zeile fallen lässt — vollständig relativ zum Muster, nicht zur
  Aufzählung (DT11-01 bis DT11-05). Dazu DT11-06 (je Aufrufstelle eine
  Messung), DT11-11 als Gate-Berichtigung (Meldungsform an den drei
  Vor-Eingabe-Pfaden und am Sperrpfad, kein Verhaltenswechsel) und S11-04 bis
  S11-06 (Deckungen fail-closed: Mindestzahl, leeres Muster ist ein
  Fehlschlag).
- **Weg (b) — Abnahmekriterium ändern.** Teil 2 wird auf das Gate bezogen:
  Blockierend ist nur eine Fremdmutation, die am Gate gegen einen echten oder
  einen Attrappenbaum ein **falsches Grün** erzeugt und keine Zeile fallen
  lässt; Formänderungen (falsch rot, Meldungsform, Rückgabewert 3 statt 2)
  sind nachrangig. Festzuhalten ist, dass Runde 11 auch unter (b) nicht
  bestanden hätte: DT11-01 bis DT11-05 sind falsches Grün am Gate für
  missgebildete Marken — erreichbar allerdings nur mit einer gefälschten
  Marke, die die richtige Lauf-Kennung trägt.
- **Einschätzung des Koordinators (seine, kein Entscheid):** Weg (a) in
  **einer** weiteren Einheit mit Runde 12. Fällt auch sie, ist die Fähigkeit
  der Aufzählung erschöpft, und dann ist (b) mit dokumentierter Restlücke der
  ehrliche Abschluss. Das Gate selbst war in elf Runden gegen echte Bäume nie
  falsch grün; was die Runden gefunden haben, sind Lücken im **Nachweis**,
  nicht im Schutz.

## Nachführung

| Datei | Änderung |
|---|---|
| `docs/adr/0002-architekturentscheid-ziel-stack.md` | 6.12.27 a bis k (Entscheid O-26, Prädikatbindung, Schlüssel-, Grammatik-, Aussagen- und Gegenstandsdeckung, Abnahmekriterium, Nachträge aus Bau und Runden 9 bis 11, Abbruch, O-27); Tabelle 6.12.19 mit sieben Spalten und `Z-001` bis `Z-208`; Elementtabelle 6.12.7 (elf Kürzel); Aussagentabellen 6.12.9 (`E01` bis `E22`) und 6.12.15 (`A01` bis `A08`); Berichtigungen 6.12.26 a; Abschnitt 8 O-26 entschieden, O-27 vorgelegt; Abschnitt 9 Siebzehnte Fortschreibung mit Nachträgen i, j, k; Kopfzeile. Abschnitt 10 unverändert |
| `scripts/dod-gate-selbsttest.sh` | Prädikatmeldung und -abgleich; Schlüssel-, Gegenstands-, Grammatik- und Aussagendeckung; Invarianten über alle Gate-Aufrufe; typisierte Beobachter- und Dateihüllen mit Zeitmarke; 207 Zusicherungen; Zählersicherung |
| `scripts/dod-gate-mutationen.txt` | 207 Einträge (197 `sed`, zehn `keine`) |
| `.claude/hooks/dod-gate.sh` | S8-03 (toter Block entfernt), S8-07 (ASCII), Zeile 110 (Meldungsform `GATE jq`, 6.12.27 j Punkt 9) — keine Verhaltensänderung |
| `CLAUDE.md` | Lieferreihenfolge, Tabelle "Aktive Gates", "Wo steht was" |
| `docs/05_Product_Backlog.md` | R3-Q-001: Nachweis (beide Modi, Schlusszeilen), Stand 2026-09-06, Sammelposten für die offenen Befunde der Runde 11 |
| `scripts/nachweise-erzeugen.sh`, `docs/NACHWEISE.md` | Beschreibung des Selbsttests und der Mutationsdatei nachgeführt; Nachweise neu erzeugt |
| Methodik-Repository | `UEBERGABE.md` (methodischer Anteil), `methodik/entscheide.md` V16 (O-26 als methodischer Entscheid), O-26 geschlossen, O-27 offen |

Nicht nachgeführt, weil nicht Sache dieser Einheit:
`docs/06_Definition_of_Ready_und_Done.md` (Bestätigung der Neufassung von D10
und D12, Abnahmekriterium — Requirements Engineer, Abschnitt 9),
`docs/04_Kontextmodell.md` (Software Architect, eigene Einheit).

## Was offen ist

1. **O-27** (ADR 0002, 6.12.27 k) — Entscheid des Auftraggebers zwischen Weg
   (a) und Weg (b). Teil 2 des Abnahmekriteriums und die Abnahme des Gates
   bleiben offen. Unbehoben aus Runde 11: DT11-01 bis DT11-10 (blockierend
   nach 6.12.27 g), DT11-11 (Meldungsform an vier Blockpfaden des Gates, kein
   falsches Grün), S11-04 bis S11-06 (Deckungen fail-open bei misslungenem
   Lesen).
2. **Nachrangige Befunde** als Backlog-Posten unter R3-Q-001: S11-02, S11-03,
   S11-09, S11-10; S10-06 (`E21`/`E22` als Anwesenheitsprüfung, benannte
   Grenze); SST-B5-09 (zusammengesetzte Messungen, nur der tragende Teil
   bindet — als Regel entschieden, S9-03); S9-05 (`Z-171` bis `Z-173` für das
   Gate formgleich, benannte Grenze). Fremdmutationen ausserhalb der vier
   Kategorien: keine in den Runden 9 bis 11.
3. **Förmliche Freigabe der Entscheidpunkte E-A bis E-K und Abnahme des Gates**
   (ADR 0002, Abschnitt 10): Formweg ist der Merge des Pull Requests;
   Empfehlung des Koordinators im Bericht an den Auftraggeber: noch nicht
   mergen, zuerst O-27 entscheiden.
4. **Bestätigung der Neufassung von D10 und D12** in der Definition of Done;
   `docs/06_Definition_of_Ready_und_Done.md` zum Abnahmekriterium vom
   Requirements Engineer zu prüfen (Abschnitt 9).
5. **Wirkung über den Harness** (Antwort bei roter Kette in einer Sitzung mit
   Projektwurzel `r3cosint` beenden) — in dieser Sitzung nicht prüfbar, weil
   die Projektwurzel das übergeordnete Verzeichnis dreier Repositories ist.
6. **Umgebung**: `gitleaks` ist seit dem 2026-09-06 in der Sitzungsumgebung
   vorhanden (`/usr/local/bin/gitleaks`); `shellcheck` fehlt weiterhin (Lage
   C der statischen Prüfung in allen Runden).
7. **O-15, O-19, O-20, O-23** unverändert beim Auftraggeber; R3-Q-005 bleibt
   die benannte Lücke.
8. **Sandbox-Hygiene**: `/tmp` der Sitzung sammelt Rückstände abgebrochener
   Läufe (91 431 am 2026-09-06 entfernt); der Selbsttest räumt regulär per
   `trap` auf, abgebrochene Instanzen nicht.

## Protokoll der ausgeführten Befehle (Koordinator)

| Befehl | Ergebnis |
|---|---|
| `command -v gitleaks` (2026-09-06) | `/usr/local/bin/gitleaks` |
| Tabellenprüfung vor der Fortschreibung | 155 Zeilen, 6 Spalten, keine Dublette, keine Lücke |
| Prädikatspalte mechanisch eingesetzt (`spalte-einfuegen.py`) | 153 Zeilen mit Spalte, 2 ersetzt (`Z-040`, `Z-080`), 29 angehängt |
| Tabellenprüfung nach dem Einsetzen | 184 Zeilen, 7 Spalten, keine Dublette, keine Lücke, Prädikate 117/34/8/7/7/5/3/2/2 |
| Schlüsseldeckung nach der Vorschrift 6.12.27 c (Prototyp) | vor: 4 von 14 gedeckt; nach: 14 von 14, Gegenrichtung 0 |
| Selbsttest nach Phase 1 | 153 von 154 (`Z-080`), 29 ohne Prüfung, Rückgabewert 2; Mutationsmodus Deckungsabbruch, Rückgabewert 2 |
| Selbsttest nach Phase 2 | 183 von 183, alle Abgleiche 0, Rückgabewert 0 |
| Selbsttest nach Phase 3 | Mutationen 173 von 173, 10 `keine`, 0 wirkungslos, Rückgabewert 0; 183 von 183, Rückgabewert 0 |
| Etiketten und `Z-185` bis `Z-193` mechanisch eingesetzt (`etiketten-einfuegen.py`) | 193 Zeilen, 7 Spalten, Prädikate 122/34/10/8/7/5/4/2/2 |
| Selbsttest nach Phase 5, Zwischenstand 11:05 UTC | Mutationen 182 von 182, Rückgabewert 0; Normalmodus Rückgabewert 2 (`Z-109` im Original) |
| `find /tmp -maxdepth 1 -name 'tmp.*' -mmin +120 -exec rm -rf {} +` (20:35 UTC) | 91 431 verwaiste Einträge entfernt, 329 verblieben |
| Selbsttest nach Phase 5, Endstand (20:47 UTC) | 192 von 192, alle Deckungen 0, Rückgabewert 0, 32 s; Mutationen 182 von 182, Rückgabewert 0, 159 s; Prüfsummen gleich |
| `Z-194` bis `Z-208` mechanisch eingesetzt | 208 Zeilen, 7 Spalten, Prädikate 132/35/12/9/7/6/4/2/2 |
| Selbsttest nach Phase 6, Teilschritt 6b, erster Lauf | "FEHLGESCHLAGEN Z-196" bei "206 von 206", Rückgabewert 0 (Zählerfehler, behoben); nach der Behebung "206 von 207", Rückgabewert 2; nach Gate-Zeile 110 "207 von 207", Rückgabewert 0 |
| Selbsttest nach Phase 6, Endstand (22:55 UTC) | 207 von 207, alle Deckungen und Abgleiche 0, Gegenstandsdeckung 24/0, Rückgabewert 0, 41 s; Mutationen 197 von 197, 10 `keine`, 0 wirkungslos, Rückgabewert 0, 173 s; Prüfsummen gleich |
| Prüfsummen der sechs Dateien vor Runde 11 und beim Abschluss (2026-09-07) | gleich: Gate `b35a0484…`, Selbsttest `d4c3dadf…`, Mutationsdatei `f27b2f4e…`, `Makefile` `ef30045f…`, Lagenliste `e853558b…` |
| `make dod` nach dem Commit, mit versionierter Übergabedatei (2026-09-07, 05:05 UTC) | D20 Belegprüfer `A_FAIL`, drei Funde der Art `pfad` in dieser Datei (die Kurzformen docs/06 und docs/04 standen in Rückwärtsakzenten und bezeichnen keine Datei); der Lauf vor dem Commit hatte die Datei nicht geprüft, weil der Belegprüfer nur versionierte Dateien liest — behoben mit dem nächsten Commit dieses Zweigs, danach Form 2 |
| `make dod` im Arbeitsbaum vor dem Commit (2026-09-07, 03:55 UTC, 9,6 s; Übergabedatei noch nicht versioniert) | Schlusszeile Form 2: alle 14 Kettenschritte durchlaufen, 3 ohne Urteil (Lage C, terminiert): D7 `FEHLT=scripts/abnahme-abgleich.sh`, D10 `FEHLT=scripts/prototyp-trennung-pruefen.sh`, D12 `FEHLT=scripts/nachweise-vollstaendig.sh`; D20 Belegprüfer `A_OK`, D11 `A_OK` (`gitleaks` vorhanden), D19 `OHNE_BEFUND`, Rückgabewert 2 |
