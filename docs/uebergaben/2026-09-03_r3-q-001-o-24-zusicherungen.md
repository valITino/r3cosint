# Übergabe 2026-09-03 — R3-Q-001: O-24 umgesetzt, Prüftabelle in Zusicherungen zerlegt, nach 3.4 erneut abgebrochen

Eskalation 3.4: Selbsttestfall besteht, ohne seine Behauptung zu belegen

Arbeitseinheit auf Weisung des Auftraggebers vom 2026-09-03: "O-24 entscheiden:
Tabellenzeilen zerlegen, dann die vier Befunde beheben." Vorangegangen ist die
Einheit vom 2026-09-02/03 (`docs/uebergaben/2026-09-02_r3-q-001-gate-gebaut.md`,
Commit `ada573b74eb603ef0eba415ab153940fd7080dbf`), die nach Projektauftrag 3.4
abgebrochen wurde, weil die Fehlerklasse "ein Selbsttestfall besteht, ohne
seine Behauptung zu belegen" dreimal aufgetreten war. Diese Einheit hat die
Nutzungsgrenze der Sitzung zweimal gerissen und ist nach der Rücksetzung
fortgesetzt worden.

## Ergebnis in einem Absatz

Der Entscheid O-24 ist umgesetzt: Die Prüftabelle 6.12.19 führt 153 einzeln
gekennzeichnete Zusicherungen (`Z-001` bis `Z-153`, `Z-110` zurückgezogen, 152
wirksam), der Selbsttest meldet je Kennung genau eine Prüfung und prüft die
Deckung gegen die Tabelle mechanisch in beide Richtungen; die vier offenen
Befunde der Vorgängereinheit sind behoben und in Runde 4 und 5 von beiden
Prüfern mit eigenen Läufen belegt. Das Gate verhält sich in allen dynamischen
Prüfpunkten beider Runden richtig. Trotzdem ist die Einheit **erneut nach 3.4
abgebrochen**: Dieselbe Fehlerklasse ist in Runde 4 zum vierten und in Runde 5
zum fünften Mal aufgetreten — jetzt nicht mehr als fehlende Prüfung, sondern
als Prüfung, die einen anderen Kanal misst als ihre Zeile nennt (16 Zeilen),
oder deren Aufbau die verletzende Lage gar nicht herstellt (`Z-111`). Der
mechanische Deckungsprüfer sieht Kennungen; Messumfang und Trennschärfe sieht
er nicht. Vorgelegt wird **O-25**: beides maschinell erzwingen.

## Der Entscheid O-24 und seine Ausformung (ADR 0002, 6.12.25)

- a) Jede Zeile der Tabelle 6.12.19 trägt genau **eine** Zusicherung mit einer
  dreistelligen Kennung `Z-nnn`, die nie umnummeriert wird; neue Zeilen werden
  angehängt, entfallene bleiben mit Kennung und dem Wort "zurückgezogen"
  stehen. Der Selbsttest meldet je Kennung genau eine Prüfung (`BESTANDEN
  Z-nnn …` / `FEHLGESCHLAGEN Z-nnn …`) und prüft die Deckung in beide
  Richtungen gegen die Tabelle in der ADR-Datei; fehlt eine Prüfung oder eine
  Kennung, endet er ungleich 0.
- f) (nach Runde 4) Jede Zusicherung nennt ihren Messumfang ausdrücklich:
  Kanal, Ereignis und, wo es darauf ankommt, Anzahl; die Prüfung misst genau
  diesen Umfang. 78 Zeilen wurden dafür präzisiert.
- b) bis e), g) bis j): Entscheide zu den einzelnen Befunden (unten).

## Was gebaut ist

| Artefakt | Änderung |
|---|---|
| `scripts/dod-gate-selbsttest.sh` | Auf Zusicherungskennungen umgestellt: je Kennung genau eine Prüfung über eine Meldefunktion; Kanalhüllen für Rückgabewert, Standard- und Fehlerausgabe, Zählerdatei, Dateiort, Beobachter ohne Wartezeit; mechanische Deckungsprüfung gegen `grep '^| Z-'` der ADR-Datei in beide Richtungen mit Rückgabewert 2 bei Abweichung; Sperre für die ganze Laufzeit (`flock` auf `/tmp/r3cosint-dod-gate-selbsttest.lock`; ein zweiter Aufruf endet nach wenigen Millisekunden mit Rückgabewert 3 und "Selbsttest laeuft bereits"). Stand: 152 von 152 Zusicherungen bestanden, Deckung 152/152/0/0. 1641 Zeilen |
| `.claude/hooks/dod-gate.sh` | b) Die Blockmeldung nennt **alle** Abweichungen des Laufs (jede `A_FAIL`-Marke, jede ungedeckte Lage C, der D19-Befund) als eigene Zeilen "weitere Abweichung"; gezählt wird weiterhin die erste in Kettenreihenfolge. c) Das Zielverzeichnis der Wegwerfdatei wird **vor** dem Anlegen bestimmt (`TMPDIR` physisch aufgelöst, im Baum → `/tmp`), die Wache nach dem Anlegen bleibt; die Kette erhält dasselbe Verzeichnis als `TMPDIR`. d) Ein physisch nicht auflösbares Verzeichnis der Wegwerfdatei ist `GATE mktemp`, fail-closed. i) **Alle** `GATE`-Blöcke ausser `GATE jq` laufen über die Zählung nach 6.12.9; fehlt `sha256sum`, bildet das Gate den Namen der Zählerdatei aus der bereinigten Rohform der `session_id` (im ADR noch nicht terminiert, S5-02). 1130 Zeilen |
| `docs/adr/0002-architekturentscheid-ziel-stack.md` | 6.12.25 a) bis k); Tabelle 6.12.19 neu gefasst (Kennung, Fall, Zusicherung, Herkunft); 6.12.24 f fortgeschrieben; 6.12.9 (Zählung aller GATE-Blöcke ausser jq); Abschnitt 8 (O-24 entschieden am 2026-09-03, neu O-25); Abschnitt 9; Kopfzeile (dreizehnte Fortschreibung) |

Stand am echten Bestand (Koordinator, DevOps Engineer und beide Prüfer, je
ausgeführt): `make dod` Schlusszeile Form 2, D7/D10/D12 in terminierter Lage C,
D19 `OHNE_BEFUND`, Rückgabewert 2; Gate darauf Rückgabewert 0 mit
`systemMessage` "Durchlass mit terminierten Lagen C … Baum: /home/user/r3cosint."

## Die vier offenen Befunde der Vorgängereinheit

| Befund | Entscheid | Behebung | Zusicherungen |
|---|---|---|---|
| S3-01 Blockmeldung nannte nur den gezählten Schlüssel | 6.12.25 b | Alle Abweichungen als eigene Zeilen; Zählschlüssel unverändert | Z-050 bis Z-053 |
| DT3-B1 Wegwerfdatei 6,9 ms im Baum | 6.12.25 c | Zielverzeichnis vor dem Anlegen bestimmt; `TMPDIR` für die Kette | Z-109, Z-111, Z-131, Z-132 |
| S3-05 unauflösbares Verzeichnis fiel offen aus | 6.12.25 d | `GATE mktemp`, Rückgabewert 2, gezählt | Z-114, Z-115, Z-146 bis Z-148 |
| S3-02/S3-07 Formen 2 und 4; verneinende Hälfte von Entscheid d | 6.12.25 e, g | Prüfungen für Form 2, Form 4, Form 3 als Gegenprobe; `Z-129` misst bei fünftem `Stop` und `TaskCompleted` beide Kanäle auf das Fehlen der Forderung | Z-129, Z-137 bis Z-141 |

Alle vier sind von beiden Prüfern mit eigenen Läufen als behoben belegt
(Runde 4 statisch und dynamisch, Runde 5 dynamisch Prüfpunkte 3 bis 6).

## Verifikation (3.4)

Umsetzung: DevOps Engineer auf Sonnet. Prüfung: Static und Dynamic Software
Tester auf Opus, unabhängig, je in einem Wegwerf-Klon mit eigenem
Zustandsverzeichnis; der versionierte Bestand blieb nach jeder Prüfung
unverändert (je belegt).

**Runde 4 — dynamisch bestanden, statisch nicht bestanden.** Ohne
Beanstandung: Deckung 145 zu 145 in beide Richtungen, zwei
Manipulationsproben erkannt, Behebungen b) bis d) im Code mit eigenen Läufen
belegt, Rückgabewerte nur 0 und 2, Ausgabedisziplin. Blockierend S4-01: die
neu geschriebene Zeile `Z-129` sagte "keine weitere Meldung enthält die Zeile
Eskalation 3.4:", gemessen wurde nur die Fehlerausgabe des vierten
Ereignisses, und die Durchlassmeldungen der Ereignisse 5 und 6 zitieren die
Übergabezeile — Wortlaut weiter als Messung und weiter als das Gemeinte
(vierter Auftritt der Fehlerklasse). Nicht blockierend: S4-02 (`Z-110` im
Attrappenaufbau nicht messbar), S4-03 (Selbsttest nicht
nebenläufigkeitsfest), S4-04 (`GATE mktemp` genannt, nicht gezählt), DT4-01
(`Z-111` beobachtete nur das TMPDIR-Verzeichnis), DT4-02 (`Z-129` nur
Fehlerausgabe). Antwort: Entscheide f) bis j) und die Behebung durch den
DevOps Engineer; der Koordinator hat die vierte Wiederholung als Teil der
angeordneten Behebung behandelt und eine fünfte Runde entscheiden lassen.

**Runde 5 — beide nicht bestanden, Abbruch nach 3.4.** Ohne Beanstandung:
Selbsttest 152 von 152 mit Deckung 152/152/0/0 unabhängig reproduziert, drei
Manipulationsproben erkannt, Sperre (zweiter Aufruf Rückgabewert 3 nach 9
beziehungsweise 12 ms), Eskalation über sechs Ereignisse mit der Forderung
nur beim dritten und Zähler 1 bis 6, Beobachter über den ganzen Baum 0
Treffer bei 38 458 Runden mit belegter Empfindlichkeit, `GATE mktemp` und
`GATE sha256sum` je mit Zählerdatei `|1` und `|2`, alle vier Abweichungen
genannt, echter Baum Form 2 und Gate 0, Ausgabeform in 11 Läufen ohne Fehler,
alle `exit`-Werte 0 oder 2, kein Schreiben in den Baum. Blockierend:

- **S5-01** (statisch): 16 Zusicherungen messen einen anderen Kanal als den in
  ihrer Zeile genannten — "Zählerdatei" gemessen auf der Fehlerausgabe
  (Z-124, Z-134, Z-136, Z-138, Z-140, Z-141, Z-143), "Baumzeile" gemessen als
  Rückgabewert 0 mit leerer Fehlerausgabe (Z-083, Z-086, Z-089, Z-092,
  Z-093), "Fehlerausgabe" gemessen auf der Standardausgabe oder in der
  Kettenausgabe (Z-054, Z-080, Z-130), "Beobachter während des Laufs"
  gemessen nach dem Lauf (Z-104). Die Kanal/Ereignis-Durchsicht des DevOps
  Engineers war stichprobenartig; die Präzisierung der Tabelle nach f) wurde
  nicht durchgängig in die Messungen übernommen.
- **DT5-01** (dynamisch): `Z-111` stellt kein Beobachtungsfenster her — die
  Attrappenkette löscht ihre Wegwerfdatei sofort nach dem Anlegen. Mutation
  genau einer Zeile des Gates (Wegfall der `TMPDIR`-Zuweisung vor `make`):
  `Z-111` erkennt sie in 1 von 3 Durchgängen, `Z-109` und `Z-131` in 3 von 3.
  Die sachliche Eigenschaft ist über `Z-109`, `Z-131` und den unabhängigen
  Prüfpunkt 4 belegt; die Zahl "152 von 152" ist es als Ganzes nicht.

Nicht blockierend: S5-02 (Ausweichname der Zählerdatei bei fehlendem
`sha256sum` im ADR nicht terminiert), S5-03 (`Z-018` misst die Abwesenheit
der Zählerdatei statt einen gleichgebliebenen Stand).

## Weshalb abgebrochen wurde, und was vorgelegt wird (O-25)

Fünf Auftritte derselben Fehlerklasse: DT-B4 (Runde 1), S-01 (Runde 2), S3-01
(Runde 3), S4-01 (Runde 4), S5-01 mit DT5-01 (Runde 5). Jede Runde hat den
**Wortlaut** der Zusicherungen geschärft (a: je Zeile eine Zusicherung; f: je
Zusicherung ein Kanal) und die **Messung** dabei nicht zwingend mitgezogen.
Die Kopplung von Tabelle und Test ist mechanisch nur über die Kennung; Kanal
und Trennschärfe stehen in der Tabelle als Fliesstext und im Test als Wahl
einer Hülle — dazwischen prüft nichts. Der Koordinator hat sich vor Runde 5
festgelegt, bei erneutem Auftreten nach 3.4 abzubrechen, und tut das.

Beide Prüfer schlagen unabhängig voneinander dasselbe vor (als Vorschlag
gekennzeichnet, kein Entscheid), und der Koordinator übernimmt es als
Empfehlung für **O-25** (ADR 0002, Abschnitt 8):

1. **Kanalspalte, maschinell abgeglichen.** Die Tabelle 6.12.19 erhält eine
   Spalte "Kanal" mit festem Wertevorrat (Rückgabewert, Standardausgabe,
   Fehlerausgabe, Zählerdatei, Datei, Beobachter, Baumzeile). Jede Messhülle
   des Selbsttests meldet ihren Kanal mit; die Deckungsprüfung vergleicht je
   Kennung Tabelle und tatsächlich benutzte Messart und endet bei Abweichung
   ungleich 0. Damit ist S5-01 eine Lage, die die Maschine findet.
2. **Mutationsprobe je Zusicherung.** Jede Zeile nennt die Änderung am Gate,
   die sie fehlschlagen lassen muss; der Selbsttest führt in einem
   Mutationsmodus jede Mutation aus und verlangt genau den Fehlschlag der
   zugehörigen Zusicherung. Damit ist DT5-01 eine Lage, die die Maschine
   findet — ein Selbsttest, der seine eigene Verneinung nicht erkennt, ist
   kein Beleg.

Reihenfolge: erst 1, dann 2; die 16 Zeilen aus S5-01, `Z-111`, `Z-018` und
S5-02 werden in derselben Einheit behoben. Erst die sechste Prüfrunde belegt
den Stand danach.

## Nachführung

| Datei | Änderung |
|---|---|
| `CLAUDE.md` | Lieferreihenfolge und Tabelle "Aktive Gates": O-24 umgesetzt, 152 Zusicherungen mit mechanischer Deckung, fünfte Runde nicht bestanden, O-25 vorgelegt |
| `docs/05_Product_Backlog.md` | R3-Q-001: Nachweis (152 Zusicherungen, Deckung mechanisch), Stand 2026-09-03 mit O-25 |
| `docs/adr/0002-architekturentscheid-ziel-stack.md` | 6.12.25 k (Beleglage Runde 5), Abschnitt 8 (O-25), Kopfzeile — durch den Software Architect |
| `docs/NACHWEISE.md` | Neu erzeugt nach dem Commit |
| Methodik-Repository | `UEBERGABE.md` (methodischer Anteil), `methodik/entscheide.md` V14 (O-24 als methodischer Entscheid des Auftraggebers), offener Punkt O-25 |

Ein vom DevOps Engineer geschriebener Übergabeentwurf zur Umstellung des
Selbsttests wurde nicht in das Repository übernommen; seine Feststellungen
(Deckung 145 zu 145 mit `comm` gegengeprüft, `_melde` als einzige Meldestelle,
Deckungsprüfung am Skriptende) sind hier aufgenommen. Eine Einheit trägt eine
Übergabe, geschrieben vom Koordinator.

## Was offen ist

1. **O-25** (oben) — Entscheid des Auftraggebers, danach eine Einheit
   Umsetzung und die sechste Prüfrunde.
2. **Förmliche Freigabe der Entscheidpunkte E-A bis E-K und Abnahme des
   Gates** (ADR 0002, Abschnitt 10). Formweg ist der Merge des Pull Requests.
   Die Empfehlung des Koordinators steht im Bericht an den Auftraggeber: erst
   nach O-25 und bestandener sechster Runde mergen.
3. **Bestätigung der Neufassung von D10 und D12** in der Definition of Done.
4. **Wirkung über den Harness**: in einer Sitzung mit Projektwurzel `r3cosint`
   eine Antwort bei roter Kette beenden und den Block beobachten.
5. **Umgebung**: `gitleaks` muss in der Umgebungsdefinition der Sitzung
   stehen; ohne `gitleaks` blockiert D11 jede Beendigung (E-E, Option b).
6. **O-15, O-19, O-20, O-23** unverändert beim Auftraggeber; R3-Q-005 bleibt
   die benannte Lücke.
7. **Nicht geprüft**: Nebenläufigkeit mehrerer Gate-Aufrufe unter echtem
   Wettlauf um die Sperre; die innere Zeitgrenze über ein echtes Reissen;
   `shellcheck` fehlt in der Umgebung; die Trennschärfe der übrigen 149
   Zusicherungen (nur `Z-109`, `Z-111`, `Z-131` sind über eine Mutation
   geprüft).

## Protokoll der ausgeführten Befehle (Koordinator)

| Befehl | Ergebnis |
|---|---|
| `bash scripts/dod-gate-selbsttest.sh` vor der Fortsetzung des DevOps Engineers | 142 von 144, 8 Kennungen ohne Prüfung, Rückgabewert 2 |
| `bash scripts/dod-gate-selbsttest.sh` nach der Behebung, eigenes `XDG_STATE_HOME` | 152 von 152, Deckung 152/152/0/0, `Z-110` zurückgezogen, Rückgabewert 0, 0 `FEHLGESCHLAGEN`, Arbeitsbaum unverändert |
| `bash -n` auf beide Skripte | 0 |
| Formprüfung (Eszett, typografische Anführungszeichen, Zweigverweise) über Gate, Selbsttest, ADR-Diff und diese Übergabe | 0 Treffer |
| Wegwerfkopie mit `git add --intent-to-add .`, `bash scripts/belege-pruefen.sh` | siehe Commit-Protokoll: 0 Befunde vor dem Commit |
| Berichte der Prüfer, Runden 4 und 5 | statisch 4 und 3 Befunde, dynamisch 2 und 1 Befunde; Auszüge in ADR 0002, 6.12.25 k |
