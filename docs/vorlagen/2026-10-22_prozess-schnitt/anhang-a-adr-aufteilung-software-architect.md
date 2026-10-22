# Plan Software Architect: Aufteilung von ADR 0002 (Prozess-Schnitt, Punkt A.2)

Stand 2026-10-22. Nur Entwurf, nichts davon steht im Repository; Pull Request #28 ist noch offen.
Grundlage: die Weisungen vom 2026-10-22 (`daten-c3.md`) und der Entwurf des Koordinators (`prozess-schnitt-entwurf.md`, A.1 und A.2).
Gemessen am Arbeitsbaum vom 2026-10-22: ADR 0002 hat 11'686 Zeilen (Stand nach C3).

---

## 1. Schnitt: was wandert, was bleibt

| Teil von ADR 0002 | Zeilen heute | Umfang | Ziel |
|---|---|---|---|
| Kopf mit Zeile 7 ("Fortschreibung", rund 37'900 Zeichen) | 1–21 | 21 | bleibt; Zeile 7 wird durch die Tabelle "Fortschreibungen" ersetzt (Punkt 3) |
| 1 Kontext bis 5 Grundgerüst | 22–494 | 473 | bleibt |
| 6 DoD-Kette: Einleitung und 6.1 bis 6.11 | 495–1947 | 1'453 | bleibt (späterer Kandidat für ein eigenes ADR, nicht jetzt) |
| 6.12 Definition-of-Done-Gate (R3-Q-001) | 1948–7997 | 6'050 | **ADR 0003** |
| 6.13 PreToolUse-Gates und Prüfmittel (R3-Q-010) | 7998–10053 | 2'056 | **ADR 0004** |
| 6.14 Fremde Inhalte im Harness (R3-Q-011) | 10054–11057 | 1'004 | **ADR 0005** |
| 7 Konsequenzen | 11058–11075 | 18 | bleibt |
| 8 Offene Punkte (O-nn) | 11076–11113 | 38 | bleibt; die Kennungen O-nn bleiben in ADR 0002 zitierbar |
| 9 Was nachzuführen ist | 11114–11293 | 180 | bleibt als Bestand; wird mit einer letzten Zeile zum Schnitt abgeschlossen; danach steht die Nachführliste im Text des Pull Requests |
| 10 Freigabevermerk (Entscheidlog) | 11294–11686 | 393 | bleibt, ausschliesslich anfügbar |

Es wandern 9'110 Zeilen, also 78 %. Unter 6.12 bis 6.14 liegen 28 Überschriften ab Ebene 4. Nach dem Schnitt hat ADR 0002 rund 2'650 Zeilen, einschliesslich der Weiterleitungen und der Tabelle.

Dateinamen: docs/adr/0003-definition-of-done-gate.md, docs/adr/0004-pretooluse-gates.md, docs/adr/0005-fremde-inhalte-im-harness.md.

## 2. Form der neuen ADR

**Kopf** nach `.claude/rules/dokumentation.md`: Titel, Status, Datum, Grundlage, betroffene Dateien. Dazu ein Satz: "Teil A fasst zusammen; bei einem Widerspruch gelten Teil B und ADR 0002, Abschnitt 10, bis Teil A berichtigt ist."

**Teil A — Stand.** Diesen Teil schreibt der Software Architect neu, und nur er wird künftig überschrieben. Inhalt:
- Entscheid in fünf bis zehn Sätzen.
- Tabelle Festlegungen: Kennung, Festlegung, seit, Fundort in Teil B.
- Tabellen Fallklassen bzw. Abnahmekriterien, Grenzen, Preise.
- Tabelle Posten und belegte Lücken: Posten, Gegenstand, Status, terminiert, Register.
- Tabelle Restpunkte.
- Tabelle Abnahmen: Datum, Gegenstand, Merge-Commit, Unterabschnitt in ADR 0002, Abschnitt 10.
- Zahlen mit Datum (Fälle, Mutationen, Fallklassen bzw. Zusicherungen).

**Teil B — Entscheidlog.** Der bisherige Text wird verschoben, nicht abgeschrieben.
- Die Reihenfolge bleibt.
- Die Überschriften und Kennungen bleiben unverändert: 6.12.1 bis 6.12.28, 6.13 a bis g, Status-Blöcke, alle Nachträge. Ein Verweis wie "ADR 0002, 6.13 c, Nachtrag vom 2026-10-21" findet so in Teil B von ADR 0004 dieselbe Stelle.
- Neue Einträge kommen ans Ende, mit Datum.
- Jede Änderung an Teil A bekommt einen Eintrag in der Form aus 6.1: "Vorher galt / Jetzt gilt / Weshalb".

**Zwingend für ADR 0003.** Teil A darf keine Tabellenzeile tragen, die mit `| Z-` beginnt. Er darf auch keine der Kopfzeilen `| Kürzel | Element |`, `| Kürzel | Aussage |` und `| Beobachtung in der Ausgabe von `make dod` | Art | Schlüssel…` tragen. Grund: `scripts/dod-gate-selbsttest.sh` liest jede Zeile `^| Z-` und jeweils das erste Vorkommen dieser Kopfzeilen (`head -n1`; Zeilen 237, 260, 325 und 386 des Skripts). Eine Zusammenfassung in Teil A würde den Abgleich sonst auf die falsche Tabelle lenken.

## 3. Verweise, Kopfzeile, Abschnitt 10

**Weiterleitungen in ADR 0002.**
- Betroffen sind 31 Überschriften: 6.12, 6.13, 6.14 und die 28 tieferen. Jede bleibt mit unverändertem Wortlaut stehen.
- Darunter folgt je eine Zeile: "Verschoben am <Datum> nach ADR 000n, Teil B, unverändert; Wortlaut hier bis zum Schnitt: <fester Verweis auf `docs/adr/0002-architekturentscheid-ziel-stack.md` beim Commit vor dem Schnitt>".
- Umfang: etwa 62 Zeilen.
- Grund: 561 Zeilen in 38 Dateien verweisen auf "ADR 0002, 6.12/6.13/6.14 …". Mit den Weiterleitungen bleiben alle auflösbar, ohne dass eine dieser Dateien angefasst wird. Zugleich findet D20 die alten Nummern weiter als eigene Überschriften von ADR 0002.

**Zeile 7 — mein Vorschlag: keine Kopie als Datei, der Wortlaut bleibt in git.**
- ADR 0002 bekommt eine Tabelle "Fortschreibungen" mit einer Zeile je Datum: Datum, Nummern, Gegenstand, Fundort. Für die 32 Fortschreibungen sind das rund 20 Zeilen.
- Davor steht ein Satz mit dem festen Verweis auf den Commit vor dem Schnitt. Dort stehen Zeile 7, Abschnitt 9 und aller verschobene Text im alten Wortlaut.
- Gründe gegen docs/adr/0002-fortschreibungen-bis-2026-10-22.md:
  - Der feste Verweis mit Prüfsumme ist die Nachweisform nach 6.6.
  - Eine Kopie verdoppelt 37'900 Zeichen, die niemand mehr bearbeitet.
  - Die Kopie bräuchte eine eigene Behandlung in D20: Sie trägt Hunderte von Abschnittsangaben, deren Abschnitte nicht in dieser Datei stehen.
  - Sie bräuchte ausserdem eine Zeile im Nachweisverzeichnis.
- Die Tabelle ist neuer Text; der Static Software Tester gleicht sie gegen die alte Zeile 7 ab.

**Abschnitt 10** bleibt in ADR 0002 und ausschliesslich anfügbar. Die neuen ADR verweisen in ihrer Abnahmetabelle darauf. **Abschnitt 8** bleibt ebenfalls, weil "ADR 0002, O-nn" vielfach zitiert ist.

## 4. Welche Verweise brechen

Gezählt mit `grep -c 'ADR 0002, 6\.1[234]'` über das ganze Repository: 561 Zeilen in 38 Dateien.

| Bereich | Zeilen | Bricht? | Behandlung |
|---|---|---|---|
| ADR 0002 selbst | 164 | nein: Treffer im verschobenen Text wandern unverändert mit, die übrigen zeigen auf die Weiterleitungen | keine |
| ADR 0001 | 24 | nein | keine; neue Verweise ab dem Schnitt auf ADR 0003 bis 0005 |
| `docs/05_Product_Backlog.md` | 51 | nein | keine; neue Form nach A.4 |
| `docs/06_Definition_of_Ready_und_Done.md` | 20 | nein | keine |
| `docs/11_Schwachstellenregister.md` | 14 | nein | keine; neue Einträge zitieren ADR 0004 |
| `CLAUDE.md` | 9 | nein | mit A.3 ohnehin gekürzt; dabei auf ADR 0003 bis 0005 umstellen (Koordinator) |
| Regeln (`.claude/rules/claude-konfiguration.md` 5, `fremde-inhalte-im-harness.md` 6) | 11 | nein | mit A.1 umstellen (Koordinator) |
| Gates und ihre Listen unter `.claude/hooks/` (main-Gate 21, Prototyp-Gate 18, DoD-Gate 12, Pfadausnahmen 3, terminierte Lagen 1, Git-Historie 1) | 56 | nein | **nicht ändern.** Jede Änderung an einem Gate verlangt Prüfmittellauf und Verifikation; umstellen mit der nächsten fachlichen Änderung am jeweiligen Gate |
| `scripts/pretooluse-gates-selbsttest.sh` | 47 | nein, nur Text in Vermerken; das Skript liest das ADR nicht | keine |
| `scripts/dod-gate-selbsttest.sh` | 46 | **ja.** Das Skript liest ADR 0002 mechanisch: sieben fest verdrahtete Pfade (Zeilen 4808, 5029, 5126, 5179, 5199, 5849, 6087) und die Tabellen aus 6.12.4, 6.12.7, 6.12.9/6.12.15 und 6.12.19. Es bricht, sobald 6.12 aus ADR 0002 verschwindet | Pfade auf ADR 0003 umstellen (SecDevOps Engineer). Vor dem Commit beide Modi laufen lassen; die Zahlen müssen gleich bleiben (262 von 262; Mutationsmodus 250 geprüft, 250 erkannt). Verifikation durch SST und DST. Der Selbsttest gehört nicht zu `make dod`; ein Bruch fiele nicht von selbst auf |
| `Makefile` | 19 | nein, nur Kommentare und Meldungen | **nicht ändern** (Kette); umstellen mit der nächsten Änderung an der Kette |
| `scripts/nachweise-erzeugen.sh` | 13 | nein, aber die Artefaktliste kennt ADR 0003 bis 0005 nicht | drei Zeilen ergänzen (DevOps Engineer); läuft in D12 |
| `docs/NACHWEISE.md` | 13 | wird erzeugt | wird neu erzeugt |
| Übergaben (71), Vorlage (1), Zustandsbericht (2) | 74 | nein; sie belegen einen vergangenen Stand | keine |

**D20, gelesen in `scripts/belege-pruefen.sh`** (Kommentar Zeilen 185 bis 208, Logik ab Zeile 639). D20 prüft "Abschnitt N.M" gegen die Überschriften des Projektauftrags. Ausgenommen ist ein Verweis, wenn er in einem Absatz mit "ADR 0002" steht oder wenn N.M eine Überschrift der nennenden Datei ist. Daraus folgt:
- **(a)** "ADR 0002, 6.13 c" prüft D20 gar nicht gegen das ADR. Der Hinweis im Auftrag, D20 prüfe solche Fundorte, trifft nach dieser Lesung nicht zu; das ist vor dem Schnitt mit einem Trockenlauf zu bestätigen.
- **(b)** In ADR 0002 bleiben alle alten Nummern dank der Weiterleitungen eigene Überschriften; dort entstehen keine neuen Funde.
- **(c)** Neue Funde sind in ADR 0003 bis 0005 zu erwarten: Der verschobene Text nennt Abschnitte, die in ADR 0002 bleiben (etwa 6.1.3, 6.8.3, 6.9), ohne "ADR 0002" im selben Absatz. Für D20 sind das dann fremde Nummern.
- Empfehlung: Vor dem Commit `make belege` auf dem geschnittenen Stand laufen lassen.
  - Bevorzugt: D20 behandelt ADR 0002 bis 0005 als eine Gliederung. Das ist eine Änderung am nicht abgenommenen Belegprüfer (O-15) und braucht einen Fall im eigenen Prüfmittel.
  - Sind es nur wenige Funde: Ausnahmen mit Grund in `scripts/belege-ausnahmen.txt`.
  - In keinem Fall wird der verschobene Text geändert.

## 5. Aufwand und Risiken

**Aufwand.** Je Etappe höchstens 20 Aufrufe.

| Etappe | Rolle | Inhalt | Aufrufe |
|---|---|---|---|
| S1 Schnitt | DevOps Engineer (braucht Bash; der Software Architect hat keines, und 9'110 Zeilen lassen sich nicht über `Write` abschreiben) | Zeilenbereiche mit `sed -n` ausschneiden, Teil B der drei ADR anlegen, Weiterleitungen einsetzen, sha256 je ausgeschnittenem Bereich gegen Teil B; eigener Commit "nur verschoben" | 6–8 |
| S2 Teil A | Software Architect | Kopf und Teil A der drei ADR, Tabelle "Fortschreibungen", Abschluss von Abschnitt 9 | 10–14 |
| S3 Prüfmittel | SecDevOps Engineer, DevOps Engineer | `scripts/dod-gate-selbsttest.sh` auf ADR 0003 umstellen und in beiden Modi fahren; drei Zeilen in `scripts/nachweise-erzeugen.sh` | 5–7 plus Laufzeit |
| S4 Prüfung | SST, DST, Koordinator | Trockenlauf D20 und `make dod`; SST auf Teil A, Weiterleitungen, Tabelle und die Prüfsummen des Schnitts; DST auf den Selbsttest | 10–15 |

Zusammen 31 bis 44 Aufrufe in drei bis vier Etappen.

**Risiken.**
1. **Regelkonflikt.** ADR 0002, 6.1, Absatz "Anlass" sagt: "die früheren Fassungen bleiben im Text stehen, weil ein Nachweisdokument, dessen Irrtum verschwindet, als Nachweis untauglich ist". Dazu kommt die Praxis "nur anfügen". Teil A und die Ersetzung von Zeile 7 überschreiben Text. Zulässig ist der Schnitt deshalb nur zusammen mit der Regeländerung A.1 im selben Pull Request (Merge = Annahme). Die neue Form wahrt den Grund der Regel: Teil B behält jede frühere Fassung im Wortlaut, jede Änderung an Teil A bekommt einen Eintrag "Vorher galt / Jetzt gilt / Weshalb", und der feste Verweis auf den Commit vor dem Schnitt bleibt. Ich empfehle drei Commits in einem Pull Request: Regeln, Verschiebung, Teil A.
2. **Selbsttest des DoD-Gates.** Siehe Punkt 4: sieben Pfade, Lesen der Tabellen über das erste Vorkommen, nicht Teil von `make dod`. Gegenmittel: den Pfad mit dem Schnitt umstellen, beide Modi fahren, Teil A ohne die genannten Tabellenformen.
3. **D20.** Neue Funde in ADR 0003 bis 0005 sind zu erwarten (Punkt 4 c). Ein roter D20 macht `make dod` rot, und das DoD-Gate sperrt dann jedes Ende. Gegenmittel: Trockenlauf vor dem Commit, Behebung in D20 oder über Ausnahmen, verschobener Text unverändert.
4. **Grösse des Diffs.** Rund 9'100 verschobene Zeilen werden nicht durch Lesen geprüft, sondern über Prüfsummen. Der Commit "nur verschoben" zeigt sich mit `git diff --color-moved` als reine Verschiebung.
5. **Teil A ist neue Fehlerquelle.** Eine Zusammenfassung kann vom Log abweichen. Dagegen stehen der Kopfsatz zum Vorrang von Teil B und ein Abgleich durch den SST: Zahlen, Prüfsummen und Kennungen gegen Teil B.
6. **Laufende Arbeit.** Während des Schnitts ändert niemand ADR 0002, 6.12 bis 6.14. C4 und O-29 zitieren danach ADR 0004 bzw. 0005.
7. **Projektauftrag 3.3 und 6.6.** Feste Verweise mit Prüfsumme in Übergaben und Texten von Pull Requests zeigen auf alte Stände und bleiben gültig. Neue Verweise auf ADR 0003 bis 0005 nennen die Prüfsumme des Commits nach dem Schnitt. Die Fortschreibung von 3.3 und 6.6 entscheidet der Auftraggeber; im Pull Request steht sie nur als Vorschlag.
8. **Nachweisverzeichnis.** Ohne die drei Zeilen in `scripts/nachweise-erzeugen.sh` fehlen ADR 0003 bis 0005 in `docs/NACHWEISE.md`.
