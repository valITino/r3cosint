# ADR 0002 — Architekturentscheid und Ziel-Stack

| | |
|---|---|
| **Titel** | Ziel-Stack, Modulschnitt, Datenzugriff und Grundgerüst für R3cOSINT |
| **Status** | **angenommen** — Freigabe des Auftraggebers am 2026-08-20, Abschnitt 10 |
| **Fortschreibung** | 2026-08-21 — O-4 entfallen: TheHive und Cortex mit der Neufassung von Projektauftrag 5.17 gestrichen; Abschnitte 8 und 9 nachgeführt. Der Optionenvergleich der Sprachwahl in Abschnitt 3.1 bleibt als damalige Entscheidungsgrundlage unverändert. — 2026-08-30 — Abschnitt 6 in drei Punkten fortgeschrieben: D11 prüft zwei Gegenstände (Arbeitsbaum und Git-Historie) statt nur der Historie; neuer Kettenschritt D18 für die Architekturverträge des Importprüfers, den Abschnitt 3.5 seit dem 2026-08-20 verlangt, ohne dass die Tabelle ihn führte; Kettengrundsatz "ein Prüflauf verändert den Gegenstand nicht, über den er urteilt" samt Folge für D12. Frühere Fassungen, Belege und Begründungen in Abschnitt 6.1; als Verweis berührt sind zusätzlich 1.3 (K5), 3.5, 3.12 sowie 8 (O-8, neu O-10) und 9. — 2026-08-30, **zweite Fortschreibung desselben Tages** nach einer abschliessenden adversarischen Prüfung: Die Kette schreibt keine Sperrdatei mehr (`uv sync --locked` und `uv run --locked` statt `--frozen`), die Unverändertheit des Arbeitsbaums wird als Rahmenprüfung **D19** tatsächlich beobachtet statt nur behauptet, die Objektbestimmung aller Kettenschritte steht neu einmal und einheitlich in einer eigenen Tabelle (löst den Widerspruch bei D18 und die fehlende Bedingung bei D10 auf), und die Prüffläche des Arbeitsbaumlaufs aus D11 ist festgelegt. Frühere Fassungen, Belege und Begründungen in Abschnitt 6.2; berührt sind zusätzlich 1.3 (K5), 3.11 und 8 (O-10 neu gefasst) sowie 9. — 2026-08-30, **dritte Fortschreibung desselben Tages** nach vier vom DevOps Engineer gemeldeten Abweichungen zwischen diesem ADR und dem Makefile: Jeder `uv`-Aufruf der Kette trägt `--project backend`, ohne das `--locked` wirkungslos bleibt (belegter Lauf); D7 erkennt seinen Gegenstand am Backlog statt am Dateinamen und hat keine Lage B mehr; `git` ist bei D11 Prüfmittel des Historienlaufs, sein Fehlen ist Lage C; der Abgleich der Wurzelpakete für D18 ist als O-11 terminiert. Frühere Fassungen, Belege und Begründungen in Abschnitt 6.3; berührt sind zusätzlich 8 (O-11 neu) und 9. — 2026-08-30, **vierte Fortschreibung desselben Tages**: D19 misst den Inhalt des Arbeitsbaums (Prüfsummen aller versionierten Dateien und die Maskierungsmerkmale des Index) statt nur der Statusliste; eine Änderung an einer bereits geänderten Datei blieb sonst unsichtbar. Belege in Abschnitt 6.4. — 2026-08-31, **fünfte Fortschreibung**: Die Reichweite der Kette ist entschieden statt offengelassen — sie schützt gegen Bequemlichkeit und Abkürzung, nicht gegen einen Aufrufer, der die Umgebung beherrscht; die harte Zusicherung liegt in einem Lauf auf der Gegenseite, neu als O-12 terminiert. Belege in Abschnitt 6.5. — 2026-08-31, **sechste Fortschreibung desselben Tages** nach einer eng gefassten Nachprüfung auf einem anderen Modell, die beide Änderungen der fünften Fortschreibung blockierend beanstandet hat: Die Positivliste um `$(UV)` gibt `UV_CACHE_DIR`, `XDG_CACHE_HOME` und `TMPDIR` nicht mehr frei (ein präparierter Zwischenspeicher erzeugte damit ein falsches `A_OK`, weil `--locked` ein bereits entpacktes Archiv nicht erneut prüft), und die Projektbestimmung fällt nicht mehr auf das Arbeitsverzeichnis zurück (die Kette prüfte sonst still ein fremdes Repository). Belege in Abschnitt 6.6; berührt ist zusätzlich 8 (O-13 neu). — 2026-08-31, **siebte Fortschreibung desselben Tages**: O-13 ist vom Auftraggeber entschieden — die Kette benutzt den Zwischenspeicher von `uv` nicht, `$(UV)` setzt `UV_NO_CACHE=1`. Damit ist der letzte Weg zu einem falschen `A_OK` über den Zwischenspeicher geschlossen statt nur abgegrenzt. Belege in Abschnitt 6.7; berührt ist zusätzlich 8 (O-13 entschieden). — 2026-09-01, **achte Fortschreibung** auf Entscheid des Auftraggebers: Der Belegprüfer `scripts/belege-pruefen.sh` wird als Kettenschritt **D20** aufgenommen und läuft **als erster Schritt, vor D1** — nicht am Ende, weil die Kette heute bei D7 abbricht und ein Schritt hinter D7 bis auf Weiteres nie liefe. D20 hat **keine Lage B**. Weil das Werkzeug seine eigene Unvollständigkeit einräumt, hält diese Fortschreibung fest, was ein grüner Lauf aussagt und was nicht, und verallgemeinert die Aussage auf die ganze Kette. Belege in Abschnitt 6.8; berührt sind zusätzlich 1.3 (K5), 8 (O-14 und O-15 neu) und 9. — 2026-09-01, **neunte Fortschreibung** nach einem vom Requirements Engineer gemeldeten Auseinanderlaufen von Festlegung und Umsetzung bei D19: Die **Beobachtbarkeit des Index** — `assume-unchanged` und `skip-worktree` — wird als Bestandteil des Prüfmittels aufgenommen, weil sie im Makefile beobachtet wird und im ADR nirgends vorkam. Der Ausgang "nicht beobachtbar" ist **Lage C**; dafür wird Lage C allgemein geschärft: ein Prüfmittel, das vorhanden ist, die Aussage aber nicht trägt, steht einem fehlenden gleich. Dazu die Unterscheidung, dass der **Gegenstand** relativ gemessen wird (vorher gegen nachher) und das **Instrument** absolut verlangt wird. Belege in Abschnitt 6.9; berührt sind zusätzlich 8 (O-16 neu) und 9. — 2026-09-01, **zehnte Fortschreibung desselben Tages**: O-16 ist mit einem ausgeführten Lauf beantwortet — die Maskierung schaltet **eine** Hälfte des D19-Instruments stumm, nicht beide; die Inhaltsprüfsumme misst weiter. Der Entscheid aus 6.9 bleibt unverändert, **eine Begründungszeile daraus wird berichtigt**, weil sie für beide Hälften behauptete, was nur für eine gilt, und die Befundmeldung wird auf die schwächere, richtige Aussage festgelegt. Der nicht gemessene Fall — Löschung einer maskierten Datei — ist als O-17 benannt statt vermutet. Belege in Abschnitt 6.10; berührt sind zusätzlich 8 (O-16 beantwortet, O-17 neu) und 9. — 2026-09-01, **elfte Fortschreibung** — *hier am 2026-09-02 nachgetragen; diese Kopfzeile führte sie nicht, siehe 6.12.18*: ein blockierender und fünf nachrangige Befunde einer unabhängigen Prüfung auf einem anderen Modell behoben. Der Belegprüfer unterscheidet neu einen dritten Rückgabewert (3 = Lage C) von einem Befund (2), und die sechs Prüfmittel von D20 werden vor jeder Verwendung geprüft statt nur drei. Belege in Abschnitt 6.11; berührt sind zusätzlich 8 (O-10 als überholt gekennzeichnet, O-18 neu) und 9. — 2026-09-02, **zwölfte Fortschreibung** — **Entwurf, dem Auftraggeber am 2026-09-02 vorgelegt, Bau auf Weisung vom selben Tag begonnen, förmliche Freigabe ausstehend (Abschnitt 10)**: Entwurf der Definition-of-Done-Gates aus R3-Q-001 (`Stop`, `SubagentStop`, `TaskCompleted`). Entschieden werden die vier Fragen des Auftraggebers — wie das Gate einen Befund von einem ausgefallenen Prüfmittel unterscheidet, was bei Lage C geschieht (terminierte Lagen C als versionierte, selbstprüfende Liste neben dem Hook), wie dreimaliges Scheitern am gleichen Kriterium gezählt wird und wie `stop_hook_active` greift — dazu die Prüfmittel des Gates, seine beiden Zeitgrenzen, der geprüfte Arbeitsbaum, die Behandlung von Rollen ohne veränderndes Werkzeug und die Aussagekraft eines Durchlasses. Die Kette selbst wird an vier Stellen fortgeschrieben: sie bricht bei Lage C nicht mehr ab, ihre Lage-Marke trägt das fehlende Prüfmittel, ihre Schlusszeilen sind eindeutig, und die Vollständigkeit der Git-Historie wird Prüfmittel von D20. Belege in Abschnitt 6.12. **Runde 1 der Prüfung am 2026-09-02 eingearbeitet:** vier Prüflinsen auf einem anderen Modell und eine Nachprüfung des Koordinators haben dreizehn Befunde gebracht, darunter einen blockierenden inneren Widerspruch — das Kriterium für Rollen ohne Schreibrecht zählte `Bash` zu den verändernden Werkzeugen und hätte damit gerade die beiden Prüferrollen erfasst, für die es gemacht ist. Alle dreizehn sind eingearbeitet und an den betroffenen Stellen als **Runde 1** gekennzeichnet; die D20-Zeile der Objekttabelle in Abschnitt 6 ist dabei selbst nachgeführt worden, weil nach Regel 2 aus 6.2.2 die Tabelle die massgebliche Stelle ist. Berührt sind zusätzlich 6 (Objekttabelle, D20), 8 (O-19 bis O-23 neu, O-8, O-10 (neu gefasst), O-15 und O-18 fortgeschrieben) und 9. **Nachträge aus dem Bau vom 2026-09-02, entschieden in 6.12.23:** drei vom DevOps Engineer gemeldete Stellen, an denen der Entwurf keinen Fall vorsieht — eine **vierte** Schlusszeile für den vollständig gelaufenen Lauf, dessen Rahmenprüfung D19 einen Befund oder Lage C meldet, samt der Parse-Regel "Rückgabewert 0 nur mit Form 1"; ein eigener Zählschlüsselraum `LISTE …` für die Selbstprüfungen 2 bis 6 der terminierten Lagen, damit ein Block wegen der Liste vom Ausfall eines Prüfmittels des Gates unterscheidbar bleibt; und die benannte Grenze, dass ein Block wegen fehlendem `jq` nicht zählbar ist. Nachgeführt sind an Ort die Überblickstabelle 6.12.1 und die Unterabschnitte 6.12.3, 6.12.4, 6.12.8, 6.12.9 und 6.12.22 sowie die `Makefile`-Zeile in Abschnitt 9. **Nachträge aus der Verifikation vom 2026-09-02, entschieden in 6.12.24:** Die statische Prüfung des gebauten Gates auf einem anderen Modell ist mit vierzehn Befunden **nicht bestanden**, die dynamische mit fünf Befunden ebenfalls **nicht**; die **zweite** Prüfrunde desselben Tages bestätigt alle Behebungen und ist wegen neuer Punkte selbst nicht bestanden (alles Fremdbeleg, eine dritte Runde folgt). Zehn Entscheide führen den Entwurf dort nach, wo er einen Fall nicht vorsieht: die Bestimmung des geprüften Baums als **physisch aufgelöste Wurzel** des Arbeitsbaums, ohne die ein Schrägstrich am Ende oder ein Symlink das Gate rot mit falscher Begründung machte; der Schlüssel `KETTE baum-widerspruch` in der Klassifizierungstabelle; das **nicht bestimmbare** Zustandsverzeichnis, das keinen eigenen Ausgang erhält, damit das Gate ausserhalb der Zeitgrenze nie mit einem anderen Wert als 0 oder 2 endet; der Durchlass nach der Eskalation, der den Zähler **nicht** löscht; Sperrdatei und Wegwerfdatei nachweislich ausserhalb des geprüften Baums; `sha256sum` und `mktemp` als siebtes und achtes blockierendes Prüfmittel des Gates; die Reihenfolge der Selbstprüfungen der terminierten Lagen; der Umfang des Selbsttests; und, aus der zweiten Runde, die Prüfung der Markenzahl gegen die **Selbstaussage der Kette**, ohne dass das Gate eine eigene Zahl führte. Nachgeführt sind an Ort die Überblickstabelle 6.12.1 und die Unterabschnitte 6.12.3, 6.12.4, 6.12.9, 6.12.11, 6.12.13, 6.12.15, 6.12.19 und 6.12.23 b sowie O-20 und der neue O-24 in Abschnitt 8 und Abschnitt 9. **Dritte Prüfrunde vom 2026-09-03 (Fremdbeleg):** Alle dreizehn Befunde der zweiten Runde sind mit eigenen Läufen beider Prüfer als behoben belegt, der Selbsttest besteht 81 von 81 Fällen — beide Prüfungen sind gleichwohl nicht bestanden (blockierend S3-01 und DT3-B1). Weil dieselbe Fehlerklasse — ein Selbsttestfall besteht, ohne seine Behauptung zu belegen — **zum dritten Mal** aufgetreten ist, ist die Arbeitseinheit am 2026-09-03 nach 3.4 **abgebrochen** und mit dem neuen offenen Punkt **O-24** (Abbildung der Tabelle 6.12.19 auf einzeln prüfbare Zusicherungen) vorgelegt worden; die zugehörigen Behebungen stehen in 6.12.24 j als **Vorschlag** und sind nicht entschieden. Berichtigt sind an Ort drei Stellen aus jener Runde (S3-03, S3-04, S3-06). Die Überschrift von 6.12 sagt neu, dass der Bau auf Weisung begonnen hat; die förmliche Freigabe der Entscheidpunkte E-A bis E-K und die Abnahme des Gates stehen unverändert aus (Abschnitt 10) |
| **Datum** | 2026-08-20 |
| **Kennung** | R3-C-001 |
| **Grundlage** | Projektauftrag 3.1, 3.4, 5.1 bis 5.18, 9.1; `docs/05_Product_Backlog.md` (Etappen 0 und 1); `docs/06_Definition_of_Ready_und_Done.md`; `docs/04_Kontextmodell.md`; `docs/adr/0001-rollenmodell.md` |
| **Lieferschritt** | Schritt 5 nach Abschnitt 2, erste Umsetzungseinheit; Freigabe-Gate Schritt 4 erteilt am 2026-08-20 (`docs/08_Freigabe_Schritt_4.md`, Abschnitt 6) |
| **Verfasst durch** | Software Architect (4.3) |

**Betroffene Dateien.** Dieser ADR legt an: `docs/adr/0002-architekturentscheid-ziel-stack.md` — sonst nichts. Er **beschreibt** ein Verzeichnislayout, er legt es nicht an. Welche Dateien nach der Freigabe nachzuführen sind, steht in Abschnitt 9.

**Was dieser ADR ist.** Der Architekturentscheid und das Grundgerüst nach 3.1: das Arbeitsergebnis, das vor der ersten Zeile Fachlogik vorliegt und freigegeben wird. Solange er nicht freigegeben ist, ist der Test `R3-C-001_adr_vorhanden` rot und damit jeder Test aus Etappe 1.

**Was dieser ADR nicht ist.** Kein Code, kein Grundgerüst auf Platte, keine Fachlogik. Die Umsetzung liegt bei Backend, Frontend und Full-Stack Engineer, die Verifikation beim Static und Dynamic Software Tester (3.4).

---

## 1. Kontext

### 1.1 Ausgangslage

Es existiert kein Produktionscode und kein festgelegter Tech-Stack (Projektauftrag, Abschnitt 0). Vorhanden sind der Projektauftrag, das Konzeptdokument, die Planungsartefakte aus Schritt 3 und der Wegwerf-Prototyp `prototype/OSINT_Plattform_Demo.html` — eine eigenständige HTML-Datei mit sechs Ansichten, deren Bildschirmfluss, Benennungen und Interaktionsmuster nach 5.6 verbindlich sind und deren Code nach 5.6 nicht weiterverwendet wird.

Das ist ein Neuaufbau ohne Altlast. Die praktische Folge für R3-C-002: Es entsteht keine Umbenennungsschuld, wenn die Namensgebung von Anfang an `r3cosint` lautet — in Paketnamen, Datenbanknamen, Schemanamen, Umgebungsvariablen und Image-Namen. Die Festlegungen in Abschnitt 5 und 6 dieses ADR verwenden ausschliesslich diese Bezeichnung.

### 1.2 Was gesetzt ist und hier nicht neu entworfen wird

| Vorgabe | Fundstelle | Wirkung auf diesen ADR |
|---|---|---|
| Kernarchitektur mit vier Ebenen 0 bis 3 | 5.1 | Wird verortet, nicht verändert |
| MCP-Server als **einziger** Zugang zu den Quellen, Anbieterschlüssel ausschliesslich serverseitig | 5.1, 5.17, R3-F-013 | Bestimmt den Modulschnitt in Abschnitt 4 |
| Kanonischer Datenbestand nach FollowTheMoney, STIX 2.1, W3C PROV | 5.1, R3-F-003 bis R3-F-005 | Wesentliches Kriterium der Sprachwahl |
| Datenhaltung PostgreSQL | 5.1 | Gesetzt; offen war nur `pgvector` (5.18) |
| Darstellung über Mermaid und draw.io, Teilgraphen statt Gesamtbild | 5.1, R3-F-070, R3-F-071 | Erzeugung serverseitig, siehe A6 und Abschnitt 4 |
| Acht Verfahrensgarantien, im Betrieb nicht abschaltbar | 5.4 | Abschnitt 4 weist je Garantie den Ort der Verankerung nach |
| Freigabesperre als fehlende Fähigkeit, nicht als Einstellung | 5.2, R3-F-014 | Eigener Entscheid A5 und Modulvertrag in 4.3 |
| Zwei Protokollspuren, SHA-256-verkettet, ausschliesslich anfügbar | 5.3, R3-F-006 bis R3-F-012 | Bestimmt den Datenzugriff, Entscheid A2 |
| Modellunabhängigkeit, ausschliesslich OpenAI-kompatible Schnittstelle | 5.15, R3-F-018 | Entscheid A7 |
| Trennung Test/Schulung und Produktion ohne Verbindungsweg | 5.16, R3-C-003 | Entscheid A10 |
| Klassifizierung wirkt im Suchindex, nicht in der Oberfläche | 5.8, R3-F-054 | Entscheid A3 |
| Vollständiger Offline-Betrieb, kein Rückkanal | 5.17, R3-C-004, R3-F-021 | Entscheide A10 und A11 |
| Eigenständige Anwendung statt Open WebUI | 9.1 | Entscheid A8 |
| Nicht gebaut, auch nicht als Platzhalter: VirusTotal, Gesichtserkennung, Open WebUI, CASE/UCO, Fernsteuerung von Maltego | 5.17, 5.18, 9.1, 5.10, 5.1 | Kommt in keinem Modul, keiner Konfigurationsoption und keiner Abhängigkeit dieses ADR vor |

Der Verzicht auf die Fernsteuerung von Maltego wird respektiert und nicht erneut geprüft (5.1). Maltego bleibt das manuelle Analysewerkzeug daneben und erhält Daten ausschliesslich über Dateien (draw.io, Mermaid).

### 1.3 Entscheidungskriterien

Jeder Entscheid in Abschnitt 3 wird gegen dieselben acht Kriterien geprüft. Sie stammen aus dem Auftrag, nicht aus einer allgemeinen Technikvorliebe.

| Nr. | Kriterium | Herkunft |
|---|---|---|
| K1 | Trägt die drei kanonischen Standards ohne Eigenbau des Schemas | 5.1, R3-F-003 bis R3-F-005 |
| K2 | Erlaubt, die Verfahrensgarantien **strukturell** zu verankern statt als Prüfung im Aufrufer | 5.4 |
| K3 | Vollständig offline betreibbar, ohne Rückkanal, ohne Aktualisierungsabfrage | 5.17, R3-C-004, R3-F-021 |
| K4 | Reproduzierbar: feste Programmstände, gleiche Eingabe gleiche Ausgabe, ein Jahr später wiederholbar | 5.4, R3-Q-002 |
| K5 | Maschinell prüfbar über eine Befehlskette mit Rückgabewert 0 | 3.4, DoD-Befehlskette nach Abschnitt 6 (bis zur Fortschreibung vom 2026-08-30 hier als "D1 bis D12" bezeichnet; die Kette umfasst seither zusätzlich D18, seit der zweiten Fortschreibung desselben Tages zusätzlich die Rahmenprüfung D19; seit der achten Fortschreibung vom 2026-09-01 zusätzlich D20, den ersten Schritt der Kette) |
| K6 | Nachweisbar: Herkunft, Versionen und Modulstand sind bei jedem Export benennbar | 5.10, 6.6 |
| K7 | Betreibbar von einer kleinen Dienststelle: Setup vom Klonen bis zum Start, Fehlermeldung statt Stacktrace | 5.5, R3-F-019 |
| K8 | Übersteht einen Modell-, Anbieter- und Mandantenwechsel als Konfigurationsänderung | 5.7, 5.15 |

Nicht Kriterium: Verbreitung um ihrer selbst willen, Neuheit, Geschwindigkeit der Entwicklung.

---

## 2. Überblick über die Entscheide

| Nr. | Gegenstand | Entscheid | Abschnitt |
|---|---|---|---|
| A1 | Sprache und Rahmenwerk des Backends | Python, ASGI-Rahmenwerk mit erzeugter OpenAPI-Beschreibung | 3.1 |
| A2 | Datenzugriff, Migrationen, anfügbares Protokoll | Typisierte SQL-Zugriffsschicht mit Migrationswerkzeug; Anfügbarkeit in der Datenbank erzwungen, nicht in der Anwendung | 3.2 |
| A3 | Suchindex | In PostgreSQL, kein zweiter Suchdienst | 3.3 |
| A4 | `pgvector` | **Nicht Bestandteil des Aufbaus** | 3.4 |
| A5 | Freigabesperre | Zwei Module ohne Aufrufkante, einmal verwendbare Freigabe-Kennung, Prozessgrenze | 3.5 |
| A6 | Graphdarstellung | Mermaid und `.drawio` werden serverseitig erzeugt; keine Einbettung eines fremden Dienstes | 3.6 |
| A7 | Anbindung des Sprachmodells | Eigene schlanke Zwischenschicht auf der OpenAI-kompatiblen HTTP-Schnittstelle; das Modell erhält **keine** Werkzeugaufruf-Fähigkeit | 3.7 |
| A8 | Rahmenwerk der Oberfläche | Einzelseitenanwendung in TypeScript mit React und Vite; Komponentenbibliothek bleibt bis zur Prototyp-Freigabe offen | 3.8 |
| A9 | Schnittstellenstil | HTTP/JSON nach OpenAPI, Typen für die Oberfläche werden daraus erzeugt | 3.9 |
| A10 | Anmeldestack | OpenID Connect als einziger Anmeldeweg, Entwicklung gegen einen selbst betriebenen Provider | 3.10 |
| A11 | Container- und Umgebungslayout | Zwei getrennte Compose-Stapel; genau ein Container hat einen Weg nach aussen | 3.11 |
| A12 | Teststack | pytest und Vitest/Playwright, Architekturtests als eigene Prüfstufe | 3.12 |
| A13 | Sprache der Bezeichner | Fachbegriffe des Glossars als Bezeichner, technische Begriffe englisch | 3.13 |

**Zu Versionsnummern.** Dieser ADR nennt keine. Verbindlich ist jeweils die zum Zeitpunkt der Umsetzung aktuelle, vom Hersteller unterstützte Fassung; festgelegt wird sie in den Sperrdateien (`uv.lock`, `package-lock.json`) und den Image-Prüfsummen, nicht in diesem Dokument. Eine Versionsnummer in einem Architekturentscheid ist ein Jahr später falsch, ohne dass es jemand merkt.

---

## 3. Entscheidungen

### 3.1 A1 — Sprache und Rahmenwerk des Backends

**Optionen.**

| Option | Bewertung |
|---|---|
| **Python mit einem ASGI-Rahmenwerk** (FastAPI-artig, Pydantic für Schemata) | Die Referenzimplementierungen der drei kanonischen Standards liegen in Python: FollowTheMoney wird im selben Ökosystem gepflegt wie OpenSanctions und dessen Abfragedienst `yente`, für STIX 2.1 pflegt OASIS eine Python-Bibliothek, für MISP ist PyMISP die offizielle Anbindung, für TheHive und Cortex existieren Python-Anbindungen. Das Model Context Protocol hat ein offizielles Python-SDK. Nachteil: Laufzeitgeschwindigkeit und ein schwächeres Typsystem als eine kompilierte Sprache |
| **TypeScript auf Node** (NestJS oder Fastify) | Ein Sprachstack für Backend und Oberfläche, offizielles MCP-SDK vorhanden, gutes Typsystem. Aber: Für FollowTheMoney, STIX 2.1 und die bestehenden Anbindungen an MISP, TheHive, Cortex und OpenSanctions müssten Schema- und Anbindungsarbeit nachgebaut oder über Zwischenprozesse geholt werden. 5.17 verlangt ausdrücklich das Gegenteil: bestehende Bausteine werden übernommen, nicht nachgebaut |
| **Go** | Robuste Einzeldatei-Auslieferung, gut für den Offline-Betrieb, starke Nebenläufigkeit. Dasselbe Ökosystem-Problem wie TypeScript, verschärft: für keinen der drei Standards liegt eine getragene Referenzbibliothek vor |

**Entscheid.** Das Backend wird in **Python** gebaut, mit einem ASGI-Rahmenwerk, das aus typisierten Modellen eine OpenAPI-Beschreibung erzeugt (FastAPI-Familie), und mit Pydantic als Schemaschicht an der Systemgrenze.

**Begründung.** K1 entscheidet allein. Der kanonische Datenbestand ist nach 5.1 der eigentliche Kern des Systems; ein Stack, in dem dessen Schemata nachgebaut werden müssten, verlagert das Projektrisiko genau dorthin, wo es am teuersten ist. Dazu kommt K7: `yente` selbst ist eine Python-Anwendung, ebenso mehrere der selbst zu betreibenden Werkzeuge aus R3-F-036; eine Dienststelle betreibt lieber eine Laufzeitumgebung als drei. Der Nachteil beim Typsystem wird über D4 (Typprüfung, null Fehler) und über die Architekturverträge aus 4.3 aufgefangen — nicht über Disziplin.

**Bewusst nicht gewählt: ein Rahmenwerk mit eingebauter Benutzerverwaltung und eingebautem Verwaltungsbereich** (Django-Familie). Es brächte Rollenverwaltung, Migrationen und einen Verwaltungsbereich mit. Dagegen sprechen zwei Punkte, die aus dem Auftrag stammen: Das Berechtigungsmodell aus 5.8 wirkt im Suchindex und über zwei nebeneinander laufende Berechtigungswege (Klassifizierungsberechtigung und fallbezogene Freigabeliste) — ein mitgebrachtes Berechtigungsmodell müsste dafür ohnehin umgangen werden, und ein umgangenes Standardmodell ist gefährlicher als keines. Zweitens ist ein mitgelieferter Verwaltungsbereich ein zweiter Zugang zu den Falldaten, an dem die Protokollpflicht für lesende Zugriffe (R3-F-057) und die Klassifizierung vorbeigehen. Ein solcher Zugang wird nicht gebaut.

**Abhängigkeitsverwaltung.** Ein Werkzeug mit Sperrdatei samt Prüfsummen und einem Modus, der ausschliesslich aus der Sperrdatei auflöst (`uv` mit `uv.lock`; geprüfte Alternative: Poetry). Grund: K4 und K3. Für den Offline-Betrieb gilt: Der **Bau** darf eine hausinterne Paketspiegelung voraussetzen, der **Betrieb** darf keinerlei ausgehende Verbindung voraussetzen.

### 3.2 A2 — Datenzugriff, Migrationen und das ausschliesslich anfügbare Protokoll

PostgreSQL ist gesetzt (5.1). Zu entscheiden ist der Weg dorthin.

**Optionen für die Zugriffsschicht.**

| Option | Bewertung |
|---|---|
| **Typisierte SQL-Werkzeugkasten- und Abbildungsschicht** (SQLAlchemy 2 im asynchronen Betrieb) mit **Alembic** für Migrationen | Erlaubt handgeschriebenes SQL dort, wo die Abfrage exakt sein muss, und Abbildung dort, wo sie es nicht sein muss. Migrationen sind versioniert, vorwärts und rückwärts prüfbar |
| **Reiner Treiber mit handgeschriebenem SQL** (asyncpg) | Volle Kontrolle, keine Abstraktionslecks — aber kein Migrationswerkzeug, kein Schutz gegen abweichende Schreibwege, und jede Klassifizierungsprüfung wäre in jeder Abfrage von Hand zu wiederholen |
| **Verschmelzung von API-Schema und Persistenzschema** (SQLModel-Muster) | Spart Schreibarbeit. Wird abgelehnt: Genau an der Naht zwischen Persistenz und Antwort sitzt das Risiko aus R3-F-054 — ein Feld, das in der Datenbank steht und deshalb in der Antwort landet, ist die Bauform des Klassifizierungslecks. Die beiden Schemata bleiben getrennt |

**Entscheid.** Typisierte Zugriffsschicht mit Migrationswerkzeug. Migrationen liegen in zwei Formen nebeneinander im selben Migrationsstrang: erzeugte Schemaschritte und **handgeschriebenes SQL** für alles, was die Datenbank selbst durchsetzen muss.

**Anfügbarkeit des Protokolls — vier Ebenen, nicht eine.** R3-F-008 verlangt, dass ein Aktualisierungs- oder Löschbefehl auf die Protokolltabelle abgewiesen wird. Eine Prüfung in der Anwendung erfüllt das nicht, weil sie sich umgehen lässt, indem man die Anwendung umgeht.

| Ebene | Mittel | Was sie verhindert |
|---|---|---|
| 1 | Getrennte Datenbankrollen: die Anwendungsrolle hat auf den Spurtabellen `INSERT` und `SELECT`, kein `UPDATE`, kein `DELETE`, kein `TRUNCATE` | Den versehentlichen und den bequemen Weg |
| 2 | Regel beziehungsweise Auslöser in der Datenbank, der `UPDATE` und `DELETE` mit Fehler beendet | Den Weg über eine falsch vergebene Berechtigung |
| 3 | Verkettung über SHA-256 je Eintrag, in der Anwendung gebildet und unabhängig nachrechenbar | Die nachträgliche Änderung durch jemanden mit Datenbankrechten |
| 4 | Kettenprüfung auf Verlangen mit Angabe der ersten Bruchstelle (R3-F-012) | Dass ein Bruch unbemerkt bleibt |

Die Migration, die Ebene 1 und 2 herstellt, ist handgeschriebenes SQL und wird als solche geprüft. Die Prüfsumme wird in der Anwendung gebildet, weil sie dort testbar, versionierbar und im Export nachvollziehbar ist; die Datenbank ist der zweite, unabhängige Rechenweg für die Prüfung.

**Herkunftsnachweis relational, PROV beim Export.** Der Herkunftsnachweis wird **relational** geführt: jeder Knoten und jede Kante trägt einen Fremdschlüssel auf einen Herkunftssatz, mit `NOT NULL`. Damit ist R3-F-005 („kein Knoten ohne Herkunft") eine Eigenschaft des Schemas und keine Zusicherung des Aufrufers. W3C PROV ist das **Austauschformat** und wird beim Export aus den relationalen Sätzen erzeugt (5.10). Ein PROV-Dokument als Speicherform wäre für die Abfragen, die R3-F-054 verlangt, das falsche Werkzeug.

**Keine Klardaten im Protokoll.** R3-F-011 wird im Schema verankert: Die Spurtabellen haben keine Spalten für Klartextwerte personenbezogener Angaben; sie führen Prüfsummen und Verweise. Die Falldaten liegen im Fallbestand, nicht im Protokoll. Das ist zugleich die Voraussetzung dafür, dass eine Fallöschung die Kette nicht bricht (4.4).

### 3.3 A3 — Suchindex

**Optionen.** Suchindex innerhalb von PostgreSQL (Volltext mit `tsvector`/GIN, Trigramm für Autovervollständigung) gegen einen eigenen Suchdienst (Elasticsearch/OpenSearch).

**Entscheid.** Der Suchindex von R3cOSINT liegt **in PostgreSQL**. Ein eigener Suchdienst wird nicht betrieben.

**Begründung.** R3-F-054 verlangt, dass eine ab Klassifizierung 1b eingestufte Entität in Trefferlisten, Autovervollständigung, Graphnachbarschaften, Exporten und Statistiken **gar nicht erst erscheint** — insbesondere darf sich die Trefferzahl nicht ändern. Das ist genau dann sauber erreichbar, wenn Suche und Datenbestand dieselbe Filterbedingung im selben Abfrageplan sehen. Ein zweiter Dienst bedeutet: ein zweites Berechtigungsmodell, ein zweiter Löschweg (R3-F-020 nennt den Suchindex ausdrücklich), eine zweite Kopie der Falldaten und ein zweiter Nachweis, dass beide gleich denken. Dazu K7 und K3: ein Suchdienst weniger im Setup, kein zusätzlicher Speicher- und Betriebsaufwand.

**Ehrliche Grenze.** Diese Wahl hat eine Obergrenze bei Bestandsgrösse und Suchkomfort. Sie ist an der erwarteten Grössenordnung eines Dezernatsbestandes vertretbar. Wird sie erreicht, ist der Ausweg **nicht** ein zweiter Index neben der Datenbank, sondern ein eigener Entscheid mit gemessenen Zahlen und einer belegten Antwort auf die Frage, wie Klassifizierung und Löschweg dort greifen. Diese Bedingung ist Teil des Entscheids.

**Abgrenzung.** Der selbst betriebene OpenSanctions-Dienst (`yente`, R3-F-035) bringt seinen eigenen Index für die Sanktionsdaten mit. Das ist ein eigenständiges System an der Kontextgrenze, kein Index über Falldaten. Es gehen keine Falldaten dorthin.

### 3.4 A4 — `pgvector`

5.18 verlangt eine ausdrückliche Prüfung: `pgvector` wird nur aufgenommen, wenn ein anderer Zweck als die gestrichene Gesichtserkennung sie rechtfertigt.

**Optionen.** (a) Jetzt aufnehmen für eine spätere semantische Suche über Falltexte. (b) Nicht aufnehmen; bei konkretem Bedarf als eigener Eintrag mit eigenem Entscheid.

**Entscheid.** **`pgvector` ist nicht Bestandteil des Aufbaus.** Keine Erweiterung, keine Spalte, keine Migration, kein Platzhalter, keine Konfigurationsoption.

**Begründung.**

1. **Es gibt keinen Bedarf mit Anforderung.** Weder Etappe 0 noch Etappe 1 noch eine spätere Etappe enthält einen Backlog-Eintrag, der semantische Suche verlangt. Eine Erweiterung auf Vorrat ist eine Entscheidung ohne Anforderung.
2. **Ein Vektorindex wäre ein zweiter Auffindungsweg.** R3-F-054 verlangt, dass eine 1b-Entität über **keinen** Weg auffindbar ist. Ein Ähnlichkeitsindex ist ein eigener Weg mit eigenem Filterbedarf; er müsste dieselbe Klassifizierungsbedingung tragen und im Löschweg aus R3-F-020 vollständig erreicht werden.
3. **Er wäre eine zweite Kopie des Inhalts.** Einbettungen sind aus Falltext abgeleitete Daten. Sie fallen unter dieselben Löschwege und dieselbe Zweckbindung — Aufwand, dem kein Nutzen gegenübersteht, solange niemand die Funktion angefordert hat.
4. **Er kollidiert mit K4.** Einbettungen hängen am Einbettungsmodell. Wechselt es, ändern sich die Ergebnisse, ohne dass sich Eingabe oder Programmstand geändert haben. R3-Q-002 verlangt das Gegenteil.
5. **Biometrische Vektoren sind ausgeschlossen** (5.18). Das gilt unabhängig von diesem Entscheid und bleibt auch dann so, wenn `pgvector` später aus einem anderen Grund hinzukommt.

**Bedingung für eine spätere Aufnahme.** Ein Backlog-Eintrag mit Abnahmekriterium, ein eigener ADR, und darin belegt: die Klassifizierungsbedingung wirkt auf dem Vektorindex, der Löschweg erreicht ihn, das Einbettungsmodell samt Version steht im Herkunftsnachweis und im Export. Ohne diese drei Nachweise wird er nicht aufgenommen.

Damit ist der offene Punkt 3 des Kontextmodells entschieden.

**Erweiterungen, die vorgesehen sind.** Trigramm-Unterstützung für Autovervollständigung und unscharfe Namenssuche sowie die für die Volltextsuche nötigen Wörterbücher. Sie müssen im Datenbank-Image offline vorhanden sein (K3).

### 3.5 A5 — Freigabesperre: Vorschlag und Ausführung technisch nicht verkettbar

5.2 und R3-F-014 verlangen keine Einstellung, sondern eine fehlende Fähigkeit. „Es existiert kein Codepfad" ist eine Aussage über die Struktur des Programms und muss als solche prüfbar sein.

**Optionen.** (a) Prüfung in der ausführenden Funktion („ist freigegeben?"). (b) Getrennte Module ohne Aufrufkante, einmal verwendbare Freigabe-Kennung, dazu Prozess- und Rechtegrenze.

**Entscheid.** Option (b), in vier Stufen:

1. **Zwei Module ohne Aufrufkante.** `freigabe.vorschlag` erzeugt eine Freigabevorlage und schreibt sie in den Zustand *offen*. `freigabe.ausfuehrung` nimmt Arbeit ausschliesslich mit einer Freigabe-Kennung an. Das Vorschlagsmodul importiert das Ausführungsmodul nicht und kennt weder dessen Namen noch dessen Adresse. Durchgesetzt über einen Architekturvertrag im Importprüfer (Abschnitt 3.12), der als eigener Kettenschritt läuft — seit der Fortschreibung vom 2026-08-30 als **D18** in der Tabelle in Abschnitt 6 geführt. Bis dahin verlangte dieser Satz einen Kettenschritt, den die eigene Tabelle des ADR nicht führte; Befund und Auflösung stehen in 6.1.
2. **Die Freigabe-Kennung entsteht nur an einem Ort.** Sie wird ausschliesslich von dem Endpunkt erzeugt, der eine angemeldete, interaktive Benutzersitzung voraussetzt. Ein Dienstzugang, ein API-Schlüssel nach 5.13 und der Aufrufweg des Sprachmodells können sie nicht erzeugen — nicht weil es verboten wäre, sondern weil dieser Weg dort nicht existiert.
3. **Einmalverwendung.** Die Kennung wird bei der Ausführung verbraucht (Zustandsübergang in derselben Transaktion). Eine zweite Ausführung mit derselben Kennung wird abgewiesen und protokolliert. Umfang und Zielmenge der Ausführung werden gegen die Vorlage geprüft; weicht sie ab, wird abgewiesen.
4. **Prozessgrenze.** Die Ausführung läuft im Beschaffungsprozess, der Vorschlag im Anwendungsprozess. Der Beschaffungsprozess nimmt Aufträge nur über die Warteschlange entgegen und liest die Freigabe selbst aus der Datenbank nach, statt der aufrufenden Seite zu glauben.

**Begründung.** Nur diese Form macht die Abnahme prüfbar. Der Test „es existiert kein Codepfad" wird zum Vertragstest des Importprüfers, „es existiert keine Konfiguration, die diese Prüfung deaktiviert" wird zur Aussage, dass keine Konfigurationsschlüssel dieses Namens existieren. Beides prüft eine Maschine. Die Prüfung „ist freigegeben?" in der ausführenden Funktion prüft dagegen nur, dass heute jemand daran gedacht hat.

**Absicherung mit R3-F-017.** Freigabesperre und Behandlung fremder Inhalte sichern sich gegenseitig (5.4). Deshalb ist zusätzlich in A7 festgelegt, dass das Sprachmodell überhaupt keine Werkzeuge auslösen kann.

### 3.6 A6 — Graphdarstellung und Export

**Entscheid.** Mermaid-Text und `.drawio`-Datei werden **serverseitig** erzeugt, deterministisch und mit stabiler Sortierung. Die Anzeige im Browser rendert den erzeugten Mermaid-Text mit einer lokal ausgelieferten Bibliothek.

**Begründung.** K4 und K6: Zwei Ermittlungsstände sollen zeilenweise vergleichbar sein (R3-F-070); das setzt eine deterministische Erzeugung voraus, die getestet werden kann. K3: Es wird **kein** eingebetteter fremder Zeichendienst verwendet — weder als eingebetteter Rahmen noch über einen Aufruf nach aussen. Eine Einbettung von `diagrams.net` wäre eine ausgehende Verbindung mit Fallinhalt und ist ausgeschlossen.

**Filterung.** Ab mehr als 50 Knoten erzeugt das System einen gefilterten Ausschnitt und weist die angewandte Filterung in der Ausgabe aus (R3-F-070). Die Filterung läuft über dieselbe Berechtigungsbedingung wie die Suche (A3), damit eine 1b-Entität auch als Graphnachbarschaft nicht erscheint.

**Offen und terminiert:** die interaktive Graphbearbeitung im Browser (R3-F-072, Etappe 4). Sie gehört zur Oberflächenschicht und wird mit der Komponentenbibliothek entschieden (Abschnitt 8, offener Punkt O-2).

### 3.7 A7 — Anbindung des Sprachmodells

**Optionen für den Zugriff.**

| Option | Bewertung |
|---|---|
| **Anbieter-SDK, auf eine eigene Adresse umgestellt** | Ausgereift, behandelt Datenstrom und Wiederholungen. Aber: Ein Anbieter-SDK ist eine Abhängigkeit, deren ausgehendes Verhalten für D9 (kein Rückkanal) je Fassung neu zu belegen wäre, und es widerspricht dem Bild von 5.15 Punkt 2 in einem System, dessen Anbieterunabhängigkeit ausdrücklich prüfbar sein soll |
| **Eigene schlanke Zwischenschicht** auf der dokumentierten OpenAI-kompatiblen HTTP-Schnittstelle | Kleine Oberfläche, vollständige Kontrolle über jede ausgehende Verbindung, einfache Aufzeichnung von Anfrage und Antwort für K4 und für die Arbeitsspur |

**Entscheid.** Eigene Zwischenschicht im Modul `llm`. Sie ist die **einzige** Stelle im Programm, die mit einem Modellendpunkt spricht. Anbieterspezifische Formate, Systemprompt-Konventionen und Werkzeugaufruf-Dialekte kommen ausserhalb dieses Moduls nicht vor; das ist die Aussage, die R3-F-018 prüft.

**Mehrere Modelle nebeneinander** sind vorgesehen (5.15): eine Zuordnungstabelle Aufgabentyp → Endpunkt und Modellname, als Konfiguration. Der Wechsel des Endpunkts und des Modellnamens ist damit eine Konfigurationsänderung. Modellname, Modellfassung, Endpunktkennung und Prüfsumme der Gewichte, soweit bekannt, werden je Aufruf in der Arbeitsspur und in jedem Export vermerkt (5.15 Punkt 3, R3-Q-002).

**Der zweite Teil dieses Entscheids ist der wichtigere: Das Sprachmodell erhält keine Werkzeugaufruf-Fähigkeit.** Es werden keine Werkzeugbeschreibungen an das Modell übergeben, und eine Modellantwort kann keinen Werkzeugaufruf auslösen. Das Modell liefert einen **Vorschlag** als strukturierte Ausgabe, die gegen ein eigenes Schema geprüft wird; alles, was dem Schema nicht entspricht, wird verworfen und protokolliert. Ausgeführt wird ausschliesslich über den Weg aus A5.

Das erledigt drei Anforderungen an einer Stelle: 5.2 (Vorschlag und Ausführung nicht verkettbar), R3-F-017 (eingeschleuster Text kann kein Werkzeug auslösen, weil das Modell keines auslösen kann) und R3-F-018 (kein Werkzeugaufruf-Dialekt im Code). Es kostet Bequemlichkeit — der geläufige Bauweg mit Werkzeugaufrufen des Modells entfällt. Das ist beabsichtigt: Genau dieser Bauweg ist der, den 5.4 als Punkt mit dem höchsten Umsetzungsrisiko benennt.

**Fremde Inhalte** werden dem Modell in einem gekennzeichneten Datenabschnitt übergeben, nie im Anweisungsabschnitt. Umgesetzt als Typ: Was aus dem Beschaffungsmodul kommt, ist ein eigener Datentyp `FremderInhalt` mit Quelle, Abrufzeitpunkt und Prüfsumme; die Zwischenschicht nimmt für den Datenabschnitt ausschliesslich diesen Typ entgegen. Eine Zeichenkette aus dem Netz kann dort nicht ankommen, ohne den Typ zu durchlaufen.

### 3.8 A8 — Rahmenwerk der Oberfläche, und was ausdrücklich offen bleibt

**Die Ausgangslage ist eine doppelte Vorgabe.** Die Abnahme von R3-C-001 verlangt, dass der ADR „Ziel-Stack, Rahmenwerk, Komponentenbibliothek, Modulgrenzen und Begründung je Entscheid" nennt. 5.6 hält gleichzeitig fest: „[OFFEN] Designsystem, Komponentenbibliothek und Zielplattformen. Diese Entscheidungen fallen nach dem Prototyp-Review, weil sie dann auf Beobachtungen beruhen statt auf Vermutungen."

Beides steht im Projektauftrag. Dieser ADR löst es so auf, dass er **trennt**:

| Jetzt entschieden | Ausdrücklich offen bis zur Prototyp-Freigabe (R3-F-050) |
|---|---|
| Rahmenwerk und Bauwerkzeug der Oberfläche | Konkrete Komponentenbibliothek |
| Auslieferungsform (Einzelseitenanwendung gegen die dokumentierte Schnittstelle) | Designsystem und Design-Tokens |
| Art der Komponentenbibliothek und die Kriterien ihrer Auswahl | Zielplattformen und Bildschirmgrössen |
| Prüfweg für Barrierefreiheit | Bibliothek für die interaktive Graphbearbeitung |

Der Grund für diese Trennung ist nicht Bequemlichkeit: Das Rahmenwerk bestimmt Verzeichnislayout, Bauwerkzeug, Prüfkette und Containerlayout und muss deshalb jetzt feststehen; die Komponentenbibliothek bestimmt Aussehen und Interaktionsdetails und beruht nach 5.6 auf dem, was das Prototyp-Review beobachtet. **Vor der schriftlichen Prototyp-Freigabe entsteht kein Frontend-Produktionscode** — dieser Entscheid ändert daran nichts.

**Dies ist dem Auftraggeber zur Entscheidung vorzulegen** (Abschnitt 8, O-1): Entweder er bestätigt diese Trennung, oder das Abnahmekriterium von R3-C-001 wird durch den Product Owner an 5.6 angepasst. Der Software Architect ändert den Backlog nicht.

**Optionen für das Rahmenwerk.**

| Option | Bewertung |
|---|---|
| **TypeScript mit React, gebaut mit Vite, als Einzelseitenanwendung** | Grösste Auswahl an ungestalteten, auf Barrierefreiheit geprüften Bausteinen und an Graphbibliotheken; grösster Vorrat an Beispielen, was bei rund 80 Prozent maschinell erzeugtem Code die Fehlerquote senkt. Nachteil: zweiter Sprachstack, zweite Werkzeugkette, grössere Lieferketten-Fläche (D8, D11) |
| **Serverseitig gerendertes HTML mit htmx**, aus dem Python-Backend | Kein zweiter Stack, kleinste Lieferkette, hervorragend offline. Wird nicht gewählt: Die Interaktionsdichte von Graphbearbeitung (R3-F-072), Freigabedialog mit Kontingentvorschau (R3-F-014) und dem sechsschrittigen Ermittlungskreislauf (R3-F-060) führt dazu, dass genau die riskantesten Teile in handgeschriebenem JavaScript ohne geprüfte Bausteine für Barrierefreiheit entstünden. Das verlagert das Risiko, statt es zu vermeiden |
| **Vue oder Svelte** | Beide tragfähig und schlanker. Ausschlaggebend dagegen: dünneres Angebot an ungestalteten, auf WCAG geprüften Bausteinen und weniger Beispielmaterial |
| **Angular** | Vollständiges Rahmenwerk mit mitgelieferten Antworten für Wegewahl, Formulare und Übersetzung; gut für langlebige Verwaltungsanwendungen. Dagegen: Die naheliegende Komponentenbibliothek bringt eine eigene Gestaltungssprache mit, die den in 5.6 als verbindlich erklärten Gestaltungsentscheidungen der Demo widerspräche |
| **Serverseitiges Rendern mit einem Node-Rahmenwerk** (Next-Familie) | Kein Nutzen: Die Anwendung liegt vollständig hinter der Anmeldung, Suchmaschinensichtbarkeit ist ohne Belang, und es entstünde eine zweite Laufzeitumgebung in Produktion — mehr Angriffsfläche und ein zusätzlicher Offline-Fall |

**Entscheid.** **TypeScript mit React, gebaut mit Vite, ausgeliefert als Einzelseitenanwendung gegen die dokumentierte HTTP-Schnittstelle.** In Produktion werden ausschliesslich statische Dateien ausgeliefert; es läuft keine Node-Laufzeitumgebung in Produktion.

**Entscheid zur Art der Komponentenbibliothek.** Die spätere Wahl ist auf **ungestaltete, auf Barrierefreiheit geprüfte Bausteine** eingeschränkt — nicht auf ein fertiges Designsystem mit eigener Gestaltungssprache. Grund: 5.6 erklärt Bildschirmfluss, Aufteilung, Benennungen und Interaktionsmuster der bestehenden Demo für verbindlich. Ein mitgebrachtes Designsystem würde sie überschreiben; ungestaltete Bausteine übernehmen Tastaturbedienung, Fokusführung und Rollenauszeichnung und überlassen die Gestaltung den Tokens aus dem Prototyp-Review.

Kriterien für die Auswahl nach der Prototyp-Freigabe, hier verbindlich festgelegt:

1. Vollständig lokal auslieferbar; kein Nachladen von Schriften, Symbolen oder Skripten aus einem fremden Netz zur Laufzeit (K3, R3-C-004).
2. Belegbare Eignung für WCAG 2.2 AA in Tastaturbedienung, Fokusreihenfolge und Rollenauszeichnung (R3-Q-003).
3. Freie Lizenz ohne Nutzungsbeschränkung für den behördlichen Einsatz.
4. Keine mitgelieferte Nutzungsmessung, keine Aktualisierungsabfrage.
5. Deckt das Komponenteninventar aus dem Prototyp-Review; Lücken werden benannt, nicht überdeckt.

**Zwischenstand zu den Zielplattformen**, bis das Review entscheidet: Arbeitsplatzrechner der Dienststelle mit aktuellem Browser, Bedienung mit Maus und Tastatur. Die vorhandene Demo ist ein Schreibtischlayout. Ob mobile Nutzung dazukommt, entscheidet das Review — es ist eine Anforderung, keine Selbstverständlichkeit.

### 3.9 A9 — Schnittstellenstil

**Optionen.** HTTP/JSON nach OpenAPI gegen GraphQL.

**Entscheid.** **HTTP/JSON, beschrieben durch eine erzeugte OpenAPI-Beschreibung.** Die TypeScript-Typen der Oberfläche werden aus dieser Beschreibung erzeugt, nicht von Hand geführt.

**Begründung.** 4.2 setzt OpenAPI als Arbeitsgrundlage des Backend Engineers. Fachlich entscheidend ist aber R3-F-054: Eine frei formulierbare Abfragesprache eröffnet für jedes Feld und jede Beziehung einen eigenen Weg zu einer Aussage über eine Entität — und damit für jeden dieser Wege eine eigene Stelle, an der die Klassifizierung greifen muss. Eine feste Menge von Endpunkten mit einer gemeinsamen Filterbedingung ist prüfbar; eine offene Abfragefläche ist es nicht. Erzeugte Typen verhindern zusätzlich, dass Oberfläche und Server auseinanderlaufen, ohne dass ein Test es merkt.

### 3.10 A10 — Anmeldestack

Die Protokollwahl ist in 5.7 bereits getroffen: OpenID Connect / OAuth 2.0, SAML nur als Rückfallebene über eine vorgelagerte Zwischenschicht. Hier ist nur die Technikwahl zu treffen.

**Entscheid.**

| Gegenstand | Entscheid | Begründung |
|---|---|---|
| Rolle der Anwendung | OIDC-Vertrauenspartei mit PKCE, Ermittlung über das Discovery-Dokument, Schlüsselbezug über JWKS, Behandlung von Erneuerungs-Token, Abmeldung | R3-F-051 zählt diese Punkte einzeln auf |
| Bibliothek | Eine gepflegte, standardkonforme OIDC-Bibliothek des Python-Ökosystems (Authlib-Klasse) | Selbstgebaute Token-Prüfung ist die falsche Stelle zum Sparen |
| Provider in Test/Schulung | Ein selbst betriebener Provider im Container (Keycloak-Klasse); geprüfte Alternative: ein schlanker Provider (Dex-Klasse) | Keycloak bildet Gruppen, Rollen und WebAuthn ab und läuft offline; ein schlanker Provider spart Betrieb, kann aber die Verfahren aus R3-F-052 nicht abbilden |
| Mandantenwechsel | Ausschliesslich Konfiguration: Discovery-Adresse, Client-Kennung, Geheimnis, Rückleitungsadressen, Scopes | 5.7; die Anwendung kennt nur Standard-OIDC |
| Rollenabbildung | Konfigurationstabelle Gruppe beziehungsweise App-Rolle → interne Rolle und Klassifizierungsberechtigung, **nicht im Code** | 5.7 ausdrücklich; R3-F-051 zweiter Test |
| Berechtigungsquelle | Ausschliesslich die interne Benutzerverwaltung. Der Identitätsanbieter beantwortet nur, **wer** jemand ist | 5.7; ein neu angemeldetes Konto ohne interne Zuweisung sieht eine leere Anwendung |

**Ehrliche Grenze.** Die Anbindungsdaten des Entra-ID-Mandanten liegen bei der Informatik der Kantonspolizei Bern (5.7). Sie blockieren ausschliesslich den Wechsel auf den echten Mandanten, nicht die Entwicklung. Die Liste der benötigten Angaben steht vollständig in 5.7 und wird nicht hier wiederholt.

**Offen und terminiert:** wo der zweite Faktor nach R3-F-052 durchgesetzt wird — im Provider oder in R3cOSINT. Das hängt an der MFA-Richtlinie des Mandanten und wird mit dem Anmeldestack in Etappe 3 entschieden (Abschnitt 8, O-3).

### 3.11 A11 — Container- und Umgebungslayout

**Optionen für die Orchestrierung.** Docker Compose gegen Kubernetes beziehungsweise Portainer.

**Entscheid.** **Docker mit Compose**, ein Stapel je Umgebung. Kubernetes wird nicht eingeführt.

**Begründung.** K7: R3-F-019 verlangt einen durchgängigen Weg vom Klonen bis zum laufenden System, betrieben von einer Dienststelle, nicht von einem Rechenzentrumsteam. Der Nutzen von Kubernetes — Skalierung über viele Knoten, rollende Auslieferung, Selbstheilung — trifft auf diesen Betrieb nicht zu, der Aufwand schon. Der Wechsel bleibt möglich, weil die Images dieselben blieben; er wird entschieden, wenn ein Bedarf mit Anforderung vorliegt, nicht vorher.

**Zwei Umgebungen ohne Verbindungsweg** (5.16, R3-C-003):

| Gegenstand | Umsetzung |
|---|---|
| Trennung | Zwei getrennte Compose-Stapel mit eigenem Netz, eigenen Datenträgern, eigener Datenbankinstanz, eigenem Artefaktspeicher, eigenem Satz Zugangsdaten |
| Kein gemeinsamer Speicher | Kein Datenträger und kein Netz wird von beiden Stapeln eingebunden. Es gibt kein Compose-Fragment, das beide beschreibt |
| Modus | Wird beim Start aus der Umgebungskonfiguration gelesen. Es existiert kein Endpunkt, keine Einstellung und kein Codepfad, der ihn zur Laufzeit ändert |
| Kennzeichnung | Das Band aus R3-F-061 hängt am beim Start gelesenen Modus und ist nicht ausblendbar |
| Kein Übertragungsweg | Es existiert kein Modul und kein Skript, das Daten von einer Umgebung in die andere überträgt. Wer Testdaten braucht, erhält den synthetischen Bestand aus 5.6 |

**Netzlayout — genau ein Container hat einen Weg nach aussen.** Das ist die tragende Entscheidung dieses Abschnitts:

| Container | Aufgabe | Ausgehendes Netz |
|---|---|---|
| `datenbank` | PostgreSQL | keines |
| `anwendung` | HTTP-Schnittstelle, Fachlogik, Vorschlagsseite | keines |
| `oberflaeche` | Auslieferung der statischen Dateien | keines |
| `beschaffung` | MCP-Anbindungen, Ausführungsseite, Anbieterschlüssel | **ausschliesslich über den Ausgangs-Vermittler** |
| `ausgang` | Vermittler, der die Positivliste durchsetzt und jeden Versuch protokolliert | nach aussen, nur auf Ziele der Positivliste |
| `modell` | lokale Sprachmodell-Instanz (in Produktion zwingend, 5.15, R3-C-006) | keines |
| `idp` | Identitätsanbieter in Test/Schulung | keines |

Damit sind drei Anforderungen nicht mehr nur Code, sondern Netzwerktopologie: R3-C-004 (kein Rückkanal — ein Container ohne Route kann keine Telemetrie senden), R3-F-015 (Positivliste — abgewiesen und protokolliert wird am Vermittler, unabhängig davon, welche Bibliothek die Verbindung versucht) und R3-F-021 (Offline-Betrieb — fällt der Vermittler weg, laufen Datenbestand und Darstellung weiter, und Abfragen nach aussen scheitern mit verständlicher Meldung).

**Anbieterschlüssel liegen ausschliesslich im Beschaffungsteil** (R3-F-013). Der Anwendungsprozess erhält sie gar nicht erst; er kann nicht ausliefern, was er nicht hat. Die Zurechenbarkeit zur Person entsteht über den Auftrag, der Fall, Person und Freigabe-Kennung trägt.

**Images.** Mehrstufig gebaut, Laufzeit ohne Bauwerkzeuge, Ausführung nicht als `root`, Basis-Images über Prüfsumme festgelegt (K4). Geheimnisse kommen als eingehängte Dateien, nie in ein Image, nie ins Repository.

**Zweite Fortschreibung 2026-08-30 — Geheimnisse liegen auch nicht im Arbeitsbaum.** Der Satz oben bleibt und wird um den Fall geschärft, den er nicht ausdrücklich nannte: Das Repository-Verzeichnis ist auch dann der falsche Ort für Zugangsdaten, wenn die Datei nicht committet wird. Zugangsdaten und Schlüsselmaterial liegen ausserhalb des Arbeitsbaums; der Prüfstapel hängt sie von dort ein. Die Dateien unter `deploy/konfiguration/{test,produktion}/` bleiben Beispieldateien ohne Geheimnisse (Abschnitt 5). Grund und Optionenvergleich stehen in 6.2.3: Der Arbeitsbaumlauf aus D11 sieht auch ignorierte Dateien, und die Alternative wäre gewesen, das Gate für genau die wertvollsten Pfade abzuschalten. Damit ist ein Fund im Arbeitsbaum immer ein Befund und nie ein Betriebszustand. Die betriebliche Form — Ablageort, Einhängung, Betriebsdokumentation — entscheiden SecDevOps und DevOps Engineer (O-10).

**Ehrliche Grenze zum Offline-Betrieb.** Der **Betrieb** ist vollständig offline möglich. Der **Bau** setzt eine Paketquelle voraus — im Haus eine Spiegelung, sonst das offene Netz. Das ist kein Widerspruch zu R3-F-021, aber es gehört benannt, weil es die Betriebsdokumentation betrifft. Zweite Grenze: Meldet sich ein Konto im Offline-Betrieb über einen externen Identitätsanbieter an, kann das nicht gelingen. Offline nutzbar ist die Anmeldung über den hausinternen Provider; das ist bei der Einrichtung der Produktion zu berücksichtigen.

### 3.12 A12 — Teststack und Prüfstufen

**Entscheid.**

| Stufe | Werkzeug | Zweck |
|---|---|---|
| Formatierung und Linter, Backend | Ruff (Formatierung und Prüfung in einem Werkzeug) | D2, D3 |
| Typprüfung, Backend | mypy im strengen Modus | D4 |
| Tests, Backend | pytest mit asynchroner Unterstützung, Abdeckungsmessung | D5, D6 |
| **Architekturverträge** | Importprüfer mit Verträgen (import-linter-Klasse) | D18 (Kettenschritt, seit der Fortschreibung vom 2026-08-30 in Abschnitt 6 geführt). Macht die Modulgrenzen aus Abschnitt 4 maschinell prüfbar — Voraussetzung für R3-F-014 und R3-F-018 |
| Integrationstests | Gegen eine PostgreSQL-Instanz aus dem Prüfstapel, kein Nachladen von Images zur Testzeit | K3, K4 |
| Linter und Typprüfung, Oberfläche | ESLint, Prettier, TypeScript-Compiler ohne Ausgabe | D2, D3, D4 |
| Tests, Oberfläche | Vitest für Einheiten, Playwright für durchgehende Abläufe | D5 |
| Barrierefreiheit | axe-Prüfung innerhalb der Playwright-Läufe, über alle Ansichten | R3-Q-003, R3-F-050 |
| Abhängigkeiten | `pip-audit` und `npm audit` | D8 |
| Geheimnisse | `gitleaks` | D11 |

**Testnamen und Verfolgbarkeit.** Jeder Abnahmetest trägt die Anforderungskennung im Namen (6.6). Da Python-Bezeichner keine Bindestriche zulassen, gilt die Abbildungsregel: `R3-F-008_kette_bricht_bei_aenderung` wird zu `test_R3_F_008_kette_bricht_bei_aenderung`. Ein eigener Prüfschritt vergleicht die Testnamen des Backlogs mit den gesammelten Testkennungen und meldet jede Anforderung ohne Test. Damit ist D7 kein Vertrauensakt.

**Modelltrennung.** Die umsetzende Rolle prüft nicht ihre eigene Arbeit; der Prüfschritt läuft auf einem anderen Modell (3.4, ADR 0001 Abschnitt 2.3). Das ist eine Vorgabe an den Ablauf, nicht an den Stack, und bleibt hier unverändert.

### 3.13 A13 — Sprache der Bezeichner

**Optionen.** (a) Durchgängig englische Bezeichner. (b) Fachbegriffe des Glossars als Bezeichner, technische Begriffe englisch.

**Entscheid.** Option (b). Modulnamen, Entitäten, Tabellen, Spalten und Zustände der **Fachlichkeit** tragen den Begriff aus `docs/03_Glossar.md`: `fall`, `freigabe`, `herkunft`, `ermittlungsspur`, `arbeitsspur`, `klassifizierung`, `negativbefund`, `positivliste`, `kontingent`, `grabstein`, `loeschsperre`. Technische Begriffe ohne Eintrag im Glossar bleiben englisch. Bezeichner sind ASCII (`pruefsumme`, nicht `prüfsumme`). Oberflächentexte sind deutsch mit Schweizer Schreibweise.

**Begründung.** 6.3 erklärt die Verwendung des Glossars für alle Arbeitsprodukte und Oberflächentexte für verpflichtend, und mehrere Begriffe verlieren beim Übersetzen ihre rechtliche Genauigkeit — die Unterscheidung von verdeckter Fahndung und verdeckter Ermittlung ebenso wie die Klassifizierungsstufen 1a und 1b, die nicht mit den Rangstufen der Rechtsregime verwechselt werden dürfen (Glossar, Homonym-Warnung). Ein Bezeichner, der wörtlich der Anforderung entspricht, macht die Verfolgbarkeit rückwärts lesbar statt nachschlagepflichtig. Der Preis ist ein gemischtsprachiger Code; er wird durch die Regel begrenzt, dass ausschliesslich Glossarbegriffe deutsch sind.

---

## 4. Modulschnitt und Verankerung der Verfahrensgarantien

### 4.1 Module

Ein Modul ist ein Python-Paket unter `backend/src/r3cosint/`. Die Ebenen beziehen sich auf 5.1.

| Modul | Ebene | Verantwortung |
|---|---|---|
| `core` | quer | Kennungen, Zeit in UTC nach ISO 8601, Prüfsummenbildung, Fehlerklassen, Konfiguration einschliesslich Umgebungsmodus |
| `kanon` | 2 | Kanonischer Datenbestand: FollowTheMoney-Entitäten, STIX-2.1-Objekte, Herkunftssätze. Einziger Schreibweg in den Datenbestand |
| `spur` | 2 | Beide Protokollspuren, Verkettung, Negativbefunde, Kennzeichnung Quellenaussage gegen Schlussfolgerung, Pseudonymisierung, Kettenprüfung |
| `fall` | 2 | Fall, Fallbindung, Rechtsregime, Fallkategorie, Zustandsmodell der Aufbewahrung, Löschwege, Grabstein, Löschsperre, fallbezogene Schlüssel |
| `zugriff` | 0/2 | Rollen, Klassifizierung als Zuordnung Stufe → Sichtbarkeitsregel, Freigabeliste je Entität, Organisationseinheit, Protokollierung lesender Zugriffe. Stellt die **eine** Filterbedingung bereit, die jeder Lesepfad benutzt |
| `freigabe.vorschlag` | 1 | Erzeugt Freigabevorlagen mit Vorschau: Abfragen, Ziele, Kontingentverbrauch |
| `freigabe.ausfuehrung` | 1 | Führt ausschliesslich gegen eine gültige, unverbrauchte Freigabe-Kennung aus |
| `beschaffung` | 1 | MCP-Anbindung als einziger Zugang zu den Quellen; Werkzeugverzeichnis; Fallbindung und Kontingentprüfung im Aufrufpfad |
| `ausgang` | 1 | Der einzige Ort mit einem HTTP-Client nach aussen; Positivliste, Protokollierung jedes Versuchs |
| `fremd` | 1 | Typ `FremderInhalt` mit Quelle, Zeitpunkt, Prüfsumme; jede von aussen bezogene Nutzlast wird hier gekapselt |
| `llm` | quer | Modellunabhängige Zwischenschicht, ausschliesslich OpenAI-kompatibel, ohne Werkzeugaufruf-Fähigkeit |
| `graph` | 3 | Filterung, Mermaid-Erzeugung, `.drawio`-Erzeugung |
| `export` | 2/3 | STIX, FollowTheMoney, W3C PROV, PDF/A-3, CSV und XLSX, Manifest mit SHA-256, Exportprotokoll |
| `api` | 0 | HTTP-Endpunkte, Anmeldung, Sitzung, Schemata der Aussenschnittstelle. **Keine Fachlogik** |
| `mcpsrv` | 1 | Bereitstellung eigener MCP-Server für die Quellen, bei denen kein gepflegter Baustein vorliegt |

### 4.2 Wo jede Verfahrensgarantie technisch sitzt

Die Spalte „Erzwungen durch" ist die eigentliche Aussage: eine Garantie, die nur im Aufrufer geprüft wird, ist keine.

| Garantie (5.4) | Modul | Erzwungen durch | Abnahme |
|---|---|---|---|
| **Fallbindung** | `beschaffung`, `fall` | Jeder Werkzeugaufruf läuft durch **einen** Aufrufpfad, der einen gültigen Fallbezug verlangt; die Werkzeuge selbst enthalten keine eigene Prüfung. Zusätzlich Fremdschlüssel auf den Fall in der Datenbank. Das Werkzeugverzeichnis ist auslesbar, damit der Test über alle registrierten Werkzeuge laufen kann | R3-F-002 |
| **Freigabe vor Ausführung** | `freigabe.vorschlag`, `freigabe.ausfuehrung` | Keine Aufrufkante zwischen den Modulen, geprüft durch Architekturvertrag; Freigabe-Kennung nur aus interaktiver Sitzung; Einmalverwendung in derselben Transaktion; Prozessgrenze | R3-F-014 |
| **Herkunft an jedem Datenpunkt** | `kanon` | `NOT NULL`-Fremdschlüssel auf den Herkunftssatz; einziger Schreibweg über `kanon`; Kennzeichnung Quellenaussage gegen Schlussfolgerung als Pflichtfeld ohne Vorgabewert | R3-F-005, R3-F-010 |
| **Positivliste nach aussen** | `ausgang` | Einziger HTTP-Client im Programm, geprüft durch Architekturvertrag; zusätzlich Netztopologie: nur `beschaffung` erreicht den Vermittler, nur der Vermittler erreicht das Netz | R3-F-015 |
| **Kontingentgrenzen** | `beschaffung`, `fall` | Zählung je Fall und je Tag in derselben Transaktion wie die Ausführung; Verbrauch erscheint in der Freigabevorschau | R3-F-016 |
| **Behandlung fremder Inhalte** | `fremd`, `llm` | Typgrenze: Der Datenabschnitt der Zwischenschicht nimmt ausschliesslich `FremderInhalt` an; das Modell hat keine Werkzeugaufruf-Fähigkeit | R3-F-017 |
| **Reproduzierbarkeit** | `core`, `export`, `llm` | Sperrdateien und Image-Prüfsummen; feste Sortierung in jeder Erzeugung; Modell-, Werkzeug- und Modulversionen im Export; Rohantworten mit Prüfsumme im Fallbestand, damit ein Lauf gegen denselben aufgezeichneten Quellstand wiederholbar ist | R3-Q-002 |
| **Kein Rückkanal** | `ausgang`, Betrieb | Kein ausgehendes Netz ausser über den Vermittler; Prüfschritt im Bauprozess gleicht alle Ziele gegen die Positivliste ab | R3-C-004 |

Ergänzend, ausserhalb der acht Garantien:

| Anforderung | Modul | Erzwungen durch |
|---|---|---|
| Protokoll ausschliesslich anfügbar | `spur` | Datenbankrechte, Auslöser in der Datenbank, Verkettung, Kettenprüfung (A2) |
| Protokoll ohne zweite Kopie der Falldaten | `spur` | Schema ohne Klartextspalten für personenbezogene Angaben |
| Klassifizierung wirkt im Suchindex | `zugriff` | **Eine** Filterbedingung, die Suche, Autovervollständigung, Graphnachbarschaft, Export und Statistik gemeinsam benutzen — auch für Trefferzahlen |
| Schlüssel serverseitig | Betrieb, `beschaffung` | Der Anwendungsprozess erhält keine Anbieterschlüssel |
| Löschweg vollständig | `fall` | Ein Löschweg, der alle Ablageorte auflistet und je Ablageort einen Test hat; fallbezogener Schlüssel wird vernichtet, Grabstein bleibt |

### 4.3 Architekturverträge, die als Test laufen

Diese Verträge sind der Grund, warum die Aussagen in Abschnitt 4.2 prüfbar sind und nicht nur behauptet:

1. `freigabe.vorschlag` importiert `freigabe.ausfuehrung` nicht — weder unmittelbar noch mittelbar.
2. Ausser `ausgang` importiert kein Modul eine Bibliothek für ausgehende HTTP-Verbindungen.
3. Ausser `llm` spricht kein Modul mit einem Modellendpunkt; ausserhalb von `llm` kommen anbieterspezifische Formate, Systemprompt-Konventionen und Werkzeugaufruf-Dialekte nicht vor.
4. Ausser `spur` schreibt kein Modul in die Spurtabellen.
5. Ausser `kanon` schreibt kein Modul in den kanonischen Datenbestand.
6. `api` enthält keine Fachlogik: es importiert Fachmodule, wird aber von keinem importiert.
7. Kein Modul importiert etwas aus `prototype/`, und `prototype/` importiert nichts aus dem Produktionscode (5.6; das bestehende Gate `.claude/hooks/block-prototype-import.sh` deckt den Schreibweg ab, der Vertrag deckt den bereits geschriebenen Stand ab).

### 4.4 Tragfähigkeit gegen Etappe 0 und Etappe 1

| Anforderung | Getragen durch |
|---|---|
| R3-C-002 Umbenennung | Namensgebung von Anfang an `r3cosint`; es entsteht keine Altbezeichnung |
| R3-C-003 zwei Umgebungen | A11, Modus beim Start, getrennte Stapel |
| R3-C-004 kein Rückkanal | A11 Netztopologie, `ausgang`, D9 |
| R3-C-005 keine echten Daten über den Harness | Entwicklung ausschliesslich gegen Test/Schulung; getrennte Zugangsdaten (5.16) |
| R3-Q-001 DoD-Gates | Abschnitt 6: ein Einstiegsbefehl, den der Hook aufruft |
| R3-Q-005 Rollen-Schreibgrenzen | Stackunabhängig; von diesem ADR unberührt |
| R3-F-001, R3-F-002 Fall und Fallbindung | `fall`, `beschaffung` |
| R3-F-003 bis R3-F-005 kanonischer Bestand | A1 (Bibliotheken), `kanon`, relationaler Herkunftsnachweis |
| R3-F-006 bis R3-F-012 beide Spuren | `spur`, A2 vierstufige Anfügbarkeit |
| R3-F-013 MCP als einziger Zugang | `beschaffung`, `mcpsrv`, Schlüssel nur im Beschaffungsteil |
| R3-F-014 Freigabesperre | A5, Architekturvertrag 1 |
| R3-F-015, R3-F-016 Positivliste und Kontingente | `ausgang`, `beschaffung` |
| R3-F-017 fremde Inhalte | A7, `fremd` |
| R3-F-018 Modellunabhängigkeit | A7, `llm`, Architekturvertrag 3 |
| R3-F-019 Setup | A11, ein Einstiegsbefehl je Umgebung, Abbruch mit Meldung statt Stacktrace |
| R3-F-020 Aufbewahrung und Löschwege | `fall`; ein Ablageort weniger, weil kein zweiter Suchdienst und kein Vektorindex existiert (A3, A4) |
| R3-F-021 Offline | A11 |
| R3-C-006 lokales Modell | A7 als Konfiguration; Container `modell` |
| R3-Q-002 Reproduzierbarkeit | A1 Sperrdateien, A11 Image-Prüfsummen, `export` |

---

## 5. Grundgerüst — Verzeichnislayout

**Beschreibung, nicht Ausführung.** Die Verzeichnisse werden nach der Freigabe von Backend Engineer und DevOps Engineer angelegt; das ist die nächste Arbeitseinheit und liefert das Grundgerüst nach 3.1 als lauffähigen, aber fachlogikfreien Stand.

```
/
├─ CLAUDE.md                     bestehend
├─ Makefile                      Einstieg für die Definition-of-Done-Kette (Abschnitt 6)
├─ .claude/                      bestehend: agents, rules, hooks, settings.json
├─ .github/workflows/            bestehend: Nachweisübertragung; dazu die Prüfkette
├─ docs/                         bestehend, einschliesslich adr/ und uebergaben/
├─ prototype/                    bestehend, getrennt, ohne gemeinsame Abhängigkeiten (5.6)
├─ backend/
│  ├─ pyproject.toml             Projekt- und Werkzeugkonfiguration
│  ├─ uv.lock                    Sperrdatei mit Prüfsummen (K4)
│  ├─ importvertraege.toml       Verträge aus 4.3, maschinell geprüft
│  ├─ src/r3cosint/
│  │  ├─ core/  kanon/  spur/  fall/  zugriff/
│  │  ├─ freigabe/{vorschlag,ausfuehrung}/
│  │  ├─ beschaffung/  ausgang/  fremd/  llm/
│  │  ├─ graph/  export/  api/  mcpsrv/
│  ├─ migrationen/
│  │  ├─ versionen/              erzeugte Schemaschritte
│  │  └─ sql/                    handgeschrieben: Rollen, Rechte, Auslöser der Spurtabellen
│  └─ tests/
│     ├─ einheit/  integration/  architektur/
│     └─ abnahme/                je Backlog-Eintrag ein Test mit der Kennung im Namen
├─ frontend/                     entsteht erst nach der Prototyp-Freigabe (5.6)
│  ├─ package.json  package-lock.json  vite.config.ts  tsconfig.json
│  ├─ src/{app,ansichten,komponenten,api,tokens}/
│  └─ tests/{einheit,e2e}/
├─ deploy/
│  ├─ compose.test.yml           Stapel Test/Schulung
│  ├─ compose.produktion.yml     Stapel Produktion, ohne jede Verbindung zum ersten
│  ├─ images/                    Dockerfiles je Container
│  └─ konfiguration/{test,produktion}/   Beispieldateien ohne Geheimnisse
└─ scripts/
   ├─ nachweise-erzeugen.sh      bestehend
   ├─ abnahme-abgleich.sh        folgt mit dem Grundgerüst, für D7
   ├─ nachweise-vollstaendig.sh  folgt mit dem Grundgerüst, für D12
   ├─ rueckkanal-pruefen.sh      folgt mit R3-C-004
   └─ prototyp-trennung-pruefen.sh  folgt, Stapelprüfung zum bestehenden Gate
```

Zwei Bauwurzeln (`backend/`, `frontend/`), ein Einstieg (`Makefile`). `frontend/` bleibt leer, bis die Prototyp-Freigabe vorliegt; das ist keine Nachlässigkeit, sondern das Gate aus 5.6.

---

## 6. Definition-of-Done-Befehlskette — Vorschlag je Kettenschritt

Dies löst den offenen Punkt 3 der Definition of Ready und Done. **Vorschlag des Software Architects, zu bestätigen durch DevOps Engineer und Auftraggeber.** Erwartet wird je Schritt Rückgabewert 0.

*Bis zur Fortschreibung vom 2026-08-30 trug dieser Abschnitt den Titel "Vorschlag zu D1 bis D12" und führte genau diese zwölf Schritte. Die Kette umfasst seither zusätzlich D18; die Nummer 18 ist eine Kennung, keine Reihenfolge (siehe unten und 6.1).*

| Nr. | Schritt | Befehl | Anmerkung |
|---|---|---|---|
| D1 | Bau | `make bau` → `uv sync --locked --project backend` · `uv run --locked --project backend python -m compileall -q backend/src` · falls `frontend/package.json` vorhanden: `npm ci --prefix frontend` und `npm run build --prefix frontend` · `docker compose -f deploy/compose.test.yml build` | **Dritte Fortschreibung 2026-08-30:** `--project backend` an beiden `uv`-Aufrufen; Beleg und Begründung in 6.3.1. Ohne die Angabe sucht `uv` das Projekt ausschliesslich aufwärts vom Arbeitsverzeichnis; aus der Repository-Wurzel wird `backend/pyproject.toml` nie gefunden, und `--locked` meldet lediglich "has no effect". Damit wäre der Entscheid der zweiten Fortschreibung wirkungslos geblieben. — **Zweite Fortschreibung 2026-08-30**, Beleg und Begründung in 6.2.1. Bis dahin stand hier `uv sync --frozen` mit der Anmerkung "Sperrdateien sind bindend; `--frozen` schlägt fehl, statt still aufzulösen". Das trug nicht: `--frozen` installiert stumm aus der Sperrdatei und meldet eine Abweichung zwischen `pyproject.toml` und `uv.lock` gerade **nicht**. `--locked` stellt die beabsichtigte Aussage her — die Sperrdatei bleibt unverändert, eine Abweichung endet ungleich 0. `npm ci` verhält sich bereits so und bleibt unverändert |
| D2 | Formatierung | `make format-pruefen` → `uv run --locked --project backend ruff format --check backend` · `npm run format-pruefen --prefix frontend` | |
| D3 | Linter | `make linter` → `uv run --locked --project backend ruff check backend` · `npm run linter --prefix frontend` mit `--max-warnings <Schwelle>` | Schwelle offen, Entscheid E-08 |
| D4 | Typprüfung | `make typen` → `uv run --locked --project backend mypy backend/src backend/tests` · `npm run typen --prefix frontend` | mypy im strengen Modus, null Fehler; das Oberflächenskript ruft den TypeScript-Compiler ohne Ausgabe auf |
| D5 | Testsuite | `make test` → `uv run --locked --project backend pytest -q --strict-markers` · `npm run test --prefix frontend` · `npm run e2e --prefix frontend` | Übersprungene Tests nur mit begründeter Markierung. **Dritte Fortschreibung 2026-08-30:** Das Arbeitsverzeichnis bleibt die Repository-Wurzel (6.3.1); welchen Gegenstand `pytest` ohne Pfadangabe von dort aus einsammelt, ist mit einem ausgeführten Lauf zu belegen (6.3.1, Nachweispflicht) |
| D6 | Abdeckung | `make abdeckung` → `uv run --locked --project backend pytest --cov=backend/src/r3cosint --cov-fail-under=80` und ein zweiter Lauf, ebenfalls mit `uv run --locked --project backend`, `--cov=backend/src/r3cosint/spur --cov=backend/src/r3cosint/zugriff --cov=backend/src/r3cosint/freigabe --cov-fail-under=100` | Die drei Module sind genau die aus D6: Protokoll, Klassifizierung, Freigabesperre. Werte offen, Entscheid E-07. Die Abdeckungsdatei liegt in einem von der Versionsverwaltung ignorierten Pfad (Kettengrundsatz) |
| D7 | Abnahmekriterien | `make abnahme` → `uv run --locked --project backend pytest -q -m abnahme` · `bash scripts/abnahme-abgleich.sh` | Der Abgleich vergleicht die Testnamen des Backlogs mit den gesammelten Testkennungen und meldet jede Anforderung ohne Test (6.6). Eigenes Projektartefakt, entsteht mit dem Grundgerüst. **Dritte Fortschreibung 2026-08-30:** D7 hat keine Lage B mehr — der Backlog samt Abnahmekriterien besteht seit der Freigabe von Schritt 3 dauerhaft. Findet der Schritt ihn nicht, ist das ein Befund und kein bestandener Schritt; Beleg und Begründung in 6.3.2 |
| D8 | Abhängigkeiten | `make abhaengigkeiten` → `uv run --locked --project backend pip-audit --strict` · `npm audit --prefix frontend --audit-level <Schwelle>` | Schwelle offen, Entscheid E-08. Offline setzt eine gespiegelte Schwachstellendatenbank voraus — DevOps |
| D9 | Kein Rückkanal | `make rueckkanal` → `bash scripts/rueckkanal-pruefen.sh` | Eigenes Projektartefakt, entsteht mit R3-C-004. Es gibt dafür kein Standardwerkzeug |
| D10 | Prototyp-Trennung | `make prototyp-trennung` → `bash scripts/prototyp-trennung-pruefen.sh` | **Befund:** Das bestehende `.claude/hooks/block-prototype-import.sh` ist ein `PreToolUse`-Hook und liest ein JSON-Ereignis von der Standardeingabe. Für D10 wird eine Stapelprüfung über den Bestand gebraucht — entweder als Betriebsart des bestehenden Skripts oder als eigenes Skript. Zu klären mit DevOps. **Zweite Fortschreibung 2026-08-30:** Diese Zeile nannte keine Objektbedingung. Das war keine Freiheit der Umsetzung, sondern hiess: der Schritt läuft immer. Damit das nicht wieder ausgelegt werden muss, steht die Bedingung jetzt in der Objekttabelle unterhalb dieser Tabelle; Begründung in 6.2.2 |
| D11 | Geheimnisse | `make geheimnisse` → **zwei Läufe, beide zwingend, jeder mit eigenem Rückgabewert.** (1) Arbeitsbaum: `gitleaks detect --no-git --redact --exit-code 1 --source .` (2) Git-Historie: `gitleaks detect --redact --exit-code 1`. Der Schritt endet ungleich 0, sobald einer der beiden Läufe ungleich 0 endet; kein Lauf schneidet den anderen ab, beide Befunde erscheinen | **Fortschreibung 2026-08-30**, frühere Fassung und Beleg in 6.1. `gitleaks detect` ohne `--no-git` durchsucht ausschliesslich die Git-Historie. Der Gegenstand, über den die Kette zur Laufzeit des Hooks aus R3-Q-001 urteilt, ist der Arbeitsbaum vor dem Commit — genau den sah die frühere Fassung nicht. **Zweite Fortschreibung 2026-08-30:** Die Prüffläche des Arbeitsbaumlaufs ist in 6.2.3 festgelegt — `.gitignore` wirkt auf `--no-git` nicht; deshalb liegen Zugangsdaten nicht im Arbeitsbaum, und ausgeschlossen werden ausschliesslich namentlich genannte Abhängigkeits- und Bauverzeichnisse. O-10 ist in seinem ersten Teil beantwortet und in Abschnitt 8 neu gefasst |
| D12 | Nachweise | `make nachweise` → `bash scripts/nachweise-erzeugen.sh` · `bash scripts/nachweise-vollstaendig.sh` | **Befund:** Ein Abgleich über `git diff --exit-code docs/NACHWEISE.md` kann nicht funktionieren. Die erzeugte Datei trägt den Stand des Repositories (`git rev-parse HEAD`); der ändert sich mit dem Commit, der die Datei enthält, weshalb der nächste Lauf immer eine Abweichung erzeugt. D12 prüft deshalb den Rückgabewert des Erzeugers — er endet mit 1, wenn ein Artefakt fehlt oder nicht committet ist — und zusätzlich, dass kein nachweispflichtiges Artefakt in der Liste fehlt. Zu klären mit Protocol Master und DevOps. **Fortschreibung 2026-08-30:** Der Schritt ruft den Erzeuger ausschliesslich in einer Betriebsart auf, die **nicht** in den Arbeitsbaum schreibt — er prüft und meldet, er erzeugt nicht. Grund ist der Kettengrundsatz unterhalb dieser Tabelle; das Erzeugen von `docs/NACHWEISE.md` bleibt Sache der Automatik (6.6, `.claude/rules/dokumentation.md`). Welche Form diese Betriebsart erhält — eigener Schalter am Erzeuger oder Lauf gegen ein temporäres Ziel mit Vergleich —, bleibt bei O-8 |
| D18 | Architekturverträge | `make architekturvertraege` → `uv run --locked --project backend lint-imports --config backend/importvertraege.toml`. Läuft in der Reihenfolge **nach D4 und vor D5** | **Fortschreibung 2026-08-30**, Begründung in 6.1. Abschnitt 3.5 verlangt diesen Schritt seit dem 2026-08-20 ausdrücklich, die Tabelle führte ihn nicht; Abschnitt 3.12 führt den Importprüfer als eigene Prüfstufe. Er belegt die Verträge aus 4.3 und damit R3-F-014 und R3-F-018. Die Nummer ist die nächste freie im gemeinsamen D-Namensraum — D13 bis D17 sind in `docs/06_Definition_of_Ready_und_Done.md`, Teil 2, an die menschlich bestätigten Bedingungen vergeben. **Zweite Fortschreibung 2026-08-30:** Hier stand die Objektbedingung "Existiert `backend/src/r3cosint/` ohne `backend/importvertraege.toml`, endet der Schritt ungleich 0: dann fehlt das Prüfmittel bei vorhandenem Gegenstand" — und im Absatz "Umgang mit noch nicht vorhandenen Teilbäumen" stand sie ein zweites Mal und anders. Sie steht jetzt einmal, in der Objekttabelle unterhalb dieser Tabelle; Beleg der entstandenen Lücke und Begründung in 6.2.2 |
| D20 | Belege | `make belege` → `bash scripts/belege-pruefen.sh`. Läuft in der Reihenfolge **als erster Schritt, vor D1** | **Achte Fortschreibung 2026-09-01**, Entscheid und Begründung in 6.8. Der Schritt prüft über die versionierten Markdown-Dateien der Wurzel, unter `docs/` und unter `.claude/`, ob Zeilenverweise, Commit-Prüfsummen, Anforderungskennungen, Pfadverweise und Abschnittsangaben des Projektauftrags auf etwas Vorhandenes zeigen, und ob ein Verweis die nach 6.6 unzulässige Zweigform statt der Commit-Prüfsumme verwendet. Er prüft **nicht**, ob der Inhalt am Fundort die Behauptung trägt (6.8.4). Er hat **keine Lage B** (6.8.3). `scripts/belege-ausnahmen.txt` ist Teil des Prüfmittels und trägt ausschliesslich ortsgebundene Schlüssel mit geschriebenem Grund (6.8.5). Das Werkzeug ist nach Eskalationsregel 3.4 abgebrochen und **nicht abgenommen**; die Abnahme ist als O-15 terminiert, die Aufnahme in die Kette hängt nicht an ihr (6.8.4) |

**Ein Prüflauf verändert den Gegenstand nicht, über den er urteilt.** *(Kettengrundsatz, aufgenommen mit der Fortschreibung vom 2026-08-30.)* Kein Kettenschritt ändert eine versionierte Datei des Arbeitsbaums — weder erzeugend noch formatierend noch nebenbei ein Verzeichnis neu schreibend. Erzeugnisse eines Bauschritts (D1) liegen ausschliesslich in Pfaden, die die Versionsverwaltung ignoriert. Drei Gründe, jeder für sich tragend:

1. **Sonst hängt das Ergebnis eines Schrittes davon ab, welcher Schritt vorher lief.** D11 urteilt seit dieser Fortschreibung über den Arbeitsbaum. Ein früher laufender Schritt, der in den Arbeitsbaum schreibt, verändert damit den Gegenstand von D11, und die Kette prüft nicht mehr den Stand, den sie zu prüfen vorgibt.
2. **K4.** Zwei Läufe hintereinander müssen dasselbe Ergebnis liefern. Ein schreibender Schritt macht den zweiten Lauf zu einem Lauf über einen anderen Gegenstand.
3. **Halbfertige Zustände werden nicht committet** (CLAUDE.md, 3.3). Ein Schritt, der schreibt, erzeugt unbemerkte Änderungen und drängt sie in den nächsten Commit — die Prüfung produziert dann genau das, was sie verhindern soll.

Die Einhaltung ist beobachtbar und braucht keine Zusicherung: Der Bestand der versionierten Dateien ist vor und nach `make dod` identisch. Die unmittelbare Folge steht in der Anmerkung zu D12.

**Zweite Fortschreibung vom 2026-08-30 — beobachtbar genügt nicht, beobachtet wird verlangt.** Bis dahin blieb es bei dem Satz oben: Die Einhaltung war beobachtbar, aber von nichts beobachtet, und die Kette selbst verletzte den Grundsatz an ihrer ersten Zeile (Beleg in 6.2.1). Der Grundsatz hängt jetzt an zwei voneinander unabhängigen Massnahmen; keine ersetzt die andere:

1. **Je Schritt vermeidend.** Kein Kettenschritt ruft ein Werkzeug in einer Betriebsart auf, die eine versionierte Datei schreiben kann. Das betrifft namentlich die Sperrdatei `uv.lock`: Jeder Aufruf von `uv` in der Kette trägt `--locked` — `uv sync --locked` in D1 und **jeder** `uv run --locked` in D2 bis D8 und D18, einschliesslich der Verfügbarkeitsproben eines Werkzeugs (`uv run --locked <werkzeug> --version`). Ein einziger Aufruf ohne den Schalter genügt, um die Sperrdatei neu zu schreiben, und er läuft in der Kette immer vor D11 und vor D19. *(Dritte Fortschreibung vom 2026-08-30: Jeder dieser Aufrufe trägt zusätzlich `--project backend`. Ohne die Angabe findet `uv` aus der Repository-Wurzel kein Projekt, und `--locked` bleibt wirkungslos — die Zusicherung dieses Punktes bestünde dann nur auf dem Papier. Beleg und Begründung in 6.3.1.)*
2. **Je Lauf beobachtend.** Die Rahmenprüfung **D19** vergleicht den Bestand vor und nach dem Lauf. Sie fängt auch das, was Punkt 1 nicht vorhersieht — ein Werkzeug, das eine Datei anlegt, an die niemand gedacht hat.

**D19 — Unverändertheit des Arbeitsbaums (Rahmenprüfung von `make dod`).** *(Neu mit der zweiten Fortschreibung vom 2026-08-30.)* D19 ist **kein Kettenschritt in der Zielliste**, sondern eine Eigenschaft von `make dod`. Der Grund ist inhaltlich: Ein Schritt in der Liste sieht nur seinen eigenen Augenblick; der Grundsatz gilt aber für den ganzen Lauf. Ein Schritt kann nicht prüfen, was ein späterer Schritt schreibt. Deshalb klammert D19 den Lauf ein, statt in ihm zu stehen.

| Gegenstand | Festlegung |
|---|---|
| Mittel | `git status --porcelain --untracked-files=all` **und** eine Inhaltsprüfsumme je verfolgter Datei (`git ls-files -z \| xargs -0 sha256sum`), unmittelbar vor dem ersten und unmittelbar nach dem letzten ausgeführten Kettenschritt; verglichen wird die vollständige Aufnahme zeilenweise, einschliesslich der unverfolgten Einträge (`??`). Fortgeschrieben am 2026-08-30, siehe 6.4 |
| Instrument, zweiter Teil | **Die Beobachtbarkeit des Index.** Erhoben wird zusätzlich der Bestand der Maskierungsmerkmale verfolgter Dateien (`git ls-files -v`, Statuszeichen `assume-unchanged` und `skip-worktree`), ebenfalls vor und nach dem Lauf. *(Neunte Fortschreibung 2026-09-01, Begründung in 6.9.)* |
| Massstab | **Zwei verschiedene Massstäbe, je nachdem, was gemessen wird.** Für den **Gegenstand** — den Bestand der Dateien — gilt: Vorher gegen Nachher, **nicht** gegen einen sauberen Arbeitsbaum. Die Kette läuft vor dem Commit und trifft regelmässig einen veränderten Arbeitsbaum an; das ist zulässig — ihn zu verändern ist es nicht. Für das **Instrument** gilt dagegen ein absoluter Massstab: Ein gesetztes Maskierungsmerkmal ist ein Befund, **auch wenn es schon vor dem Lauf gesetzt war**. Ein stummgeschaltetes Messmittel wird nicht dadurch verlässlich, dass es bereits vorher stummgeschaltet war. *(Neunte Fortschreibung 2026-09-01, 6.9.)* |
| Ausgang | Bei Abweichung des Gegenstands endet `make dod` ungleich 0 und nennt die abweichenden Zeilen. Ist das Instrument stummgeschaltet, endet `make dod` ebenfalls ungleich 0, mit **eigenem Befundtext** und als **Lage C** — nicht als Verletzung des Kettengrundsatzes, denn eine Verletzung ist damit gerade nicht festgestellt. Der Befundtext nennt, **welche Hälfte** des Instruments stumm ist und was die andere gemessen hat; er behauptet nicht, der Arbeitsbaum sei unbeobachtet. In beiden Fällen gilt: Der Befund kann einen grünen Lauf rot machen, nie einen roten grün. *(Neunte Fortschreibung 2026-09-01, 6.9; Genauigkeit der Meldung festgelegt mit der zehnten Fortschreibung desselben Tages, 6.10.2.)* |
| Auch bei Abbruch | Die Nachher-Aufnahme läuft auch dann, wenn die Kette an einem Schritt vorher abgebrochen ist. Sonst bliebe gerade der Schritt unbeobachtet, der schreibt und zugleich scheitert |
| Kennung | D19, die nächste freie Nummer im gemeinsamen D-Namensraum. Sie erhält **kein** eigenes `make`-Ziel, weil sie den Lauf einklammert; sie trägt trotzdem eine Nummer, damit Definition of Done, Backlog und Nachweise sie benennen können |

**Folge für `.gitignore`.** Damit D19 nicht an Werkzeugspeichern anschlägt, gehören die Zwischenspeicher der Prüfwerkzeuge in die Ignorierliste — `.pytest_cache/`, `.ruff_cache/`, `.mypy_cache/`, die Abdeckungsdateien und die Berichte der durchgehenden Oberflächenläufe. Heute steht keiner dieser Einträge in `.gitignore` (geprüft am 2026-08-30). Das ist nachzuführen (Abschnitt 9) und zugleich Bedingung dafür, dass der Arbeitsbaumlauf aus D11 nicht in Werkzeugspeichern sucht (6.2.3). Ein Prüfwerkzeug, dessen Zwischenspeicher sich nicht in einen ignorierten Pfad legen lässt, wird nicht durch eine Ausnahme von D19 aufgefangen, sondern ausgetauscht.

**Die Nummer eines Kettenschritts ist eine Kennung, keine Reihenfolge.** *(Aufgenommen mit der Fortschreibung vom 2026-08-30.)* Nummern werden nicht umnummeriert und nicht wiederverwendet; ein neuer Schritt erhält die nächste freie Nummer im gemeinsamen D-Namensraum von `docs/06_Definition_of_Ready_und_Done.md`, Teil 2 (Befehlskette und menschlich bestätigte Bedingungen zählen dort fortlaufend). Die Reihenfolge der Ausführung ergibt sich aus der Zielliste von `make dod`, nicht aus der Zahl. Begründung in 6.1.

**Woran ein Kettenschritt seinen Gegenstand erkennt.** *(Aufgenommen mit der zweiten Fortschreibung vom 2026-08-30; Anlass, Beleg und Begründung in 6.2.2.)* Jeder Kettenschritt urteilt über eine Sache, nicht über einen Verzeichnisnamen. Für jeden Schritt gelten dieselben drei Lagen, und jede hat genau einen Ausgang:

| Lage | Bedingung | Ausgang |
|---|---|---|
| A | Gegenstand vorhanden, Prüfmittel vorhanden | Der Schritt urteilt: 0 oder ungleich 0 |
| B | Gegenstand nicht vorhanden | Der Schritt entfällt **mit Meldung**, Rückgabewert 0 |
| C | Gegenstand vorhanden, Prüfmittel fehlt **oder trägt die Aussage nicht** — es ist unlesbar, unbrauchbar oder stummgeschaltet *(geschärft mit der neunten Fortschreibung vom 2026-09-01, 6.9.2)* | Rückgabewert **ungleich 0**. Ein fehlendes Prüfmittel ist kein bestandener Schritt, und ein vorhandenes, das nicht messen kann, ebenso wenig |

Dazu vier Regeln:

1. **Der Gegenstand wird als Sache benannt, das Erkennungsmerkmal als Beobachtung.** Ein Pfad darf das Merkmal sein, wenn er die tragende Ausprägung des Gegenstands ist — `backend/pyproject.toml` **ist** das erklärte Python-Projekt. Ein Pfad, der nur zufällig danebenliegt, ist es nicht: Ein Verzeichnis `backend/` sagt nichts darüber, ob Python-Code darin steht, und `backend/src/r3cosint/` sagt nichts darüber, ob es Produktionscode unter einem anderen Paketnamen gibt.
2. **Die Objektbedingung steht einmal.** Massgeblich ist ausschliesslich die Tabelle unten. Steht dieselbe Bedingung an einer zweiten Stelle dieses ADR anders, gilt die Tabelle, und die zweite Stelle wird als Fortschreibung berichtigt.
3. **Eine Bedingung wird nicht in der Umsetzung erfunden.** Nennt die Tabelle für einen Schritt keine Lage B, gibt es für ihn keine: Er läuft immer.
4. **Die Lage wird ausgegeben, nicht erschlossen.** Jeder Schritt nennt im Lauf, in welcher Lage er war. Ein Schritt, der mit 0 endet, muss von einem unterscheidbar sein, der nichts geprüft hat.

| Schritt | Gegenstand (die Sache) | Erkennungsmerkmal | Lage B, entfällt mit Meldung | Prüfmittel, dessen Fehlen Lage C ergibt |
|---|---|---|---|---|
| D1 bis D8, Backend-Anteil | Das erklärte Python-Projekt des Backends | `backend/pyproject.toml` vorhanden | Datei fehlt | `uv`; dazu je Schritt das aufgerufene Werkzeug (ruff, mypy, pytest, pytest-cov, pip-audit) |
| D1 bis D8, Oberflächen-Anteil | Das erklärte Projekt der Oberfläche | `frontend/package.json` vorhanden | Datei fehlt | `node` und `npm`; dazu das in `package.json` hinterlegte Skript |
| D1, Stapelbau | Der Prüfstapel Test/Schulung | `deploy/compose.test.yml` vorhanden | Datei fehlt | `docker` samt erreichbarem Daemon |
| D7, zweiter Teil | Die Abnahmekriterien des Backlogs | Eine Datei unterhalb `docs/`, die den Backlog trägt, führt Abnahmekriterien; als Suchmuster `docs/05_Product_Backlog*.md`, nicht der eine Dateiname. Treffen mehrere Dateien zu, werden alle beurteilt und in der Lage-Meldung genannt | **keine** — der Backlog besteht seit der Freigabe von Schritt 3 dauerhaft, der Schritt läuft immer *(dritte Fortschreibung 2026-08-30, 6.3.2; vorher: "keine Abnahmekriterien vorhanden")* | `scripts/abnahme-abgleich.sh`; dazu die Fundstelle selbst: findet das Suchmuster keine Datei oder führt die gefundene keine Abnahmekriterien, endet der Schritt ungleich 0 |
| D9 | Quelltext und Betriebskonfiguration, die eine ausgehende Verbindung öffnen könnten | mindestens eine Datei unterhalb `backend/`, `frontend/` oder `deploy/` | keiner der drei Bäume enthält eine Datei | `scripts/rueckkanal-pruefen.sh` |
| D10 | Die Trennung zwischen `prototype/` und dem Produktionscode, in beide Richtungen | `prototype/` vorhanden | `prototype/` fehlt — tritt nach 5.6 nicht ein, der Schritt läuft also immer | `scripts/prototyp-trennung-pruefen.sh` |
| D11 | Arbeitsbaum und Git-Historie des Repositories | `.git/` vorhanden | kein `.git/` | `gitleaks`; für den Historienlauf zusätzlich `git` *(dritte Fortschreibung 2026-08-30, 6.3.3; vorher stand hier allein `gitleaks`)* |
| D12 | Die nachweispflichtigen Artefakte nach 6.6 | `docs/` vorhanden — Bestandteil des Repositories, der Schritt läuft immer | tritt nicht ein | `scripts/nachweise-erzeugen.sh`, `scripts/nachweise-vollstaendig.sh` |
| D18 | **Python-Produktionscode unterhalb `backend/src/`, unabhängig davon, wie das Paket heisst** | mindestens eine `*.py`-Datei unterhalb `backend/src/` | keine `*.py`-Datei unterhalb `backend/src/` | `backend/importvertraege.toml`; `lint-imports` |
| D19 | Der Bestand der versionierten Dateien über die Dauer eines Laufs von `make dod` | Die Versionsverwaltung meldet einen Arbeitsbaum; ist `git` nicht ausführbar, hilfsweise die blosse Anwesenheit von `.git` — **als Datei oder als Verzeichnis**, weil `.git` in einem zusätzlichen Arbeitsbaum und in einem Untermodul eine Datei ist *(neunte Fortschreibung 2026-09-01, 6.9.3; vorher stand hier "`.git/` vorhanden")* | kein Arbeitsbaum und kein `.git` | `git`; dazu die **Beobachtbarkeit des Index**: Ist für eine verfolgte Datei `assume-unchanged` oder `skip-worktree` gesetzt, ist das Prüfmittel stummgeschaltet, und das ist Lage C *(neunte Fortschreibung 2026-09-01, 6.9.2)* |
| D20 | **Die Herkunfts- und Fundortangaben in den versionierten Markdown-Dateien des Repositories** — Wurzel, `docs/` und `.claude/` | Mindestens eine versionierte Markdown-Datei dieser Prüffläche, festgestellt über die Versionsverwaltung und nicht über einen Verzeichnisnamen | **keine** — der Bestand kann nicht leer sein, und ein leerer Bestand wäre ein Befund und kein leerer Gegenstand *(achte Fortschreibung 2026-09-01, 6.8.3)* | `scripts/belege-pruefen.sh` und `scripts/belege-ausnahmen.txt`; `bash`, `git`, `grep`, `sed`, `awk`; dazu die beiden Bezugsdokumente `docs/05_Product_Backlog.md` und `docs/00_Projektauftrag.md`, aus denen der Prüfer seine Referenzmengen bildet. Fehlt eines davon, ist das Lage C — nicht ein bestandener Schritt (6.8.3). Dazu die **Vollständigkeit der Git-Historie**: Ist der Klon flach (`git rev-parse --is-shallow-repository` meldet wahr), trägt die lokale Historie die Aussage über Commit-Prüfsummen nicht, und das ist nach der geschärften Bedingung Lage C mit dem Beschaffungsweg `git fetch --unshallow` *(zwölfte Fortschreibung 2026-09-02, 6.12.17 — **Bau auf Weisung vom 2026-09-02 begonnen, förmliche Freigabe ausstehend**; bis zur Freigabe gilt die Zeile ohne diesen Satz)* |

Zwei Anmerkungen zu dieser Tabelle:

- **Zu D6.** Die Abdeckungspfade folgen dem Modulbaum aus 4.1 — `backend/src/r3cosint/`, darin `spur`, `zugriff` und `freigabe`. Weicht ein Paketname davon ab, ist das ein Verstoss gegen 4.1 und A13 und wird dort behoben, nicht durch eine Lockerung des Pfades in der Kette. Der Schritt darf an einem falsch benannten Paket scheitern; er darf ihn nicht stillschweigend auslassen.
- **Zu D18.** Die Vertragsdatei nennt jedes oberste Paket unterhalb `backend/src/` als Wurzelpaket. Sonst liefe der Prüfer an vorhandenem Produktionscode vorbei und meldete Lage A, obwohl er nichts beurteilt hat. Wo dieser Abgleich sitzt — im Aufruf oder als Vertrag im Prüfer selbst —, entscheidet der DevOps Engineer. **Dritte Fortschreibung 2026-08-30:** Dieser Abgleich ist heute nicht gebaut, weil `backend/importvertraege.toml` noch nicht besteht; im Makefile steht er als Kommentar. Damit er mit dem Grundgerüst nicht vergessen wird, ist er als **O-11** in Abschnitt 8 terminiert — ein Kommentar ist keine Prüflogik, und für ihn gilt derselbe Satz wie für die auskommentierte Prüfung unten: Er bleibt still liegen, nachdem er gebraucht würde (6.3.4).

**Zwei Ebenen der Namensbindung.** Die Backend-Befehle stehen unmittelbar im Makefile, die Oberflächenbefehle laufen über Skripte in `frontend/package.json`. Damit steht jeder Werkzeugname genau einmal und an der Stelle, an der er hingehört; die Kette selbst bleibt unverändert, wenn ein Werkzeug ausgetauscht wird.

**Ein Einstieg für den Hook.** `make dod` ruft **alle Kettenschritte dieser Tabelle** in der festgelegten Reihenfolge auf — D1 bis D4, dann D18, dann D5 bis D12 — und endet bei der ersten Abweichung ungleich 0. *(Achte Fortschreibung 2026-09-01: Die Reihenfolge beginnt neu mit **D20**, also D20, D1 bis D4, D18, D5 bis D12. Begründung in 6.8.2.)* *(Bis zur Fortschreibung vom 2026-08-30 lautete dieser Satz: "ruft D1 bis D12 der Reihe nach auf". Die Aufzählung war dort zugleich die Reihenfolge; mit D18 gilt das nicht mehr.)* Der Hook aus R3-Q-001 ruft **diesen einen Befehl** auf. Damit hängt R3-Q-001 nur noch am Vorhandensein des Makefiles und nicht mehr an einzelnen Werkzeugnamen; ändert sich ein Werkzeug, ändert sich das Makefile, nicht der Hook. Für den Hook gelten unverändert: nur Rückgabewert 2 blockiert, Reentranz-Schutz über `stop_hook_active`, Eskalation nach dreimaligem Scheitern am gleichen Kriterium (3.4). *(Zweite Fortschreibung 2026-08-30: Die Rahmenprüfung D19 gehört zu `make dod`, steht aber nicht in der Zielliste. Sie nimmt vor dem ersten Schritt auf, vergleicht nach dem letzten ausgeführten Schritt und läuft auch dann, wenn die Kette vorher abgebrochen ist.)*

**Umgang mit noch nicht vorhandenen Teilbäumen.** *(Überholt durch die Objekttabelle oben, zweite Fortschreibung vom 2026-08-30. Der Absatz bleibt als frühere Fassung stehen. Seine Aussage zu `frontend/package.json` ist in die Tabelle übernommen; seine Aussage zu D18 ist durch sie ersetzt, weil sie der D18-Zeile derselben Tabelle widersprach — Beleg in 6.2.2. Der Satz zur auskommentierten Prüfung gilt unverändert und für alle Schritte.)* Solange `frontend/package.json` fehlt, entfallen die Oberflächenschritte und der Kettenschritt endet mit 0 und einer Meldung. Sobald die Datei existiert, laufen sie zwingend. Das ist als Bedingung im Makefile zu prüfen und nicht als auskommentierte Zeile abzubilden — eine auskommentierte Prüfung bleibt still liegen, nachdem sie gebraucht würde. Dasselbe gilt für D18 gegenüber dem Backend-Teilbaum, mit der Verschärfung aus der Tabelle: Fehlt `backend/` ganz, entfällt der Schritt mit Meldung; existiert `backend/src/r3cosint/` ohne `backend/importvertraege.toml`, endet er ungleich 0.

### 6.1 Fortschreibung vom 2026-08-30 — was vorher galt, was jetzt gilt, weshalb

**Anlass.** Beim Bau des Makefiles nach diesem Abschnitt hat eine adversarische Prüfung auf einem anderen Modell (3.4) zwei Mängel **an diesem ADR** belegt, nicht am Makefile: Das Makefile setzte den Wortlaut jeweils korrekt um, der Wortlaut trug nicht. Beide Mängel werden hier aufgelöst; die früheren Fassungen bleiben im Text stehen, weil ein Nachweisdokument, dessen Irrtum verschwindet, als Nachweis untauglich ist.

#### 6.1.1 D11 prüfte den falschen Gegenstand

| | |
|---|---|
| **Vorher galt** | `make geheimnisse` → `gitleaks detect --redact --exit-code 1` |
| **Jetzt gilt** | Zwei Läufe, beide zwingend, jeder mit eigenem Rückgabewert: Arbeitsbaum `gitleaks detect --no-git --redact --exit-code 1 --source .`, Git-Historie `gitleaks detect --redact --exit-code 1` |

**Beleg.** Ausgeführter Lauf am 2026-08-30 mit gitleaks 8.21.2: Ein RSA-Privatschlüssel, als nicht committete Datei im Arbeitsbaum abgelegt, wurde von `gitleaks detect --redact --exit-code 1` **nicht** gefunden; `gitleaks detect --no-git --redact --exit-code 1 --source .` fand ihn und endete mit 1. `gitleaks detect` ohne `--no-git` durchsucht ausschliesslich die Git-Historie.

**Weshalb das den Regelfall trifft und nicht den Randfall.** Der Hook aus R3-Q-001 läuft als `Stop` beziehungsweise `SubagentStop`, also **vor** dem Commit; CLAUDE.md untersagt zugleich das Committen halbfertiger Zustände. Der Gegenstand, über den die Kette zum Zeitpunkt ihres Laufs urteilt, ist damit systematisch der Arbeitsbaum. Ein Schlüssel, der dort liegt und noch nicht committet ist, ist genau der Fall, den ein Gate vor dem Commit abfangen soll — und der einzige, in dem das Abfangen noch etwas nützt. Ist das Geheimnis erst in der Historie, hilft kein Prüflauf mehr, sondern nur noch der Austausch des Geheimnisses; die Historie wird in diesem Projekt nicht umgeschrieben.

**Weshalb dennoch beide Gegenstände geprüft werden.** Der Lauf über die Historie fällt nicht weg. Er ist der einzige, der einen Fund aus einem früheren Commit meldet — etwa aus einem übernommenen Zweig oder aus der Zeit vor dem Bestehen dieser Kette. Ein Gate, das nur den Arbeitsbaum sieht, erklärt ein Repository für sauber, dessen dritter Commit einen Schlüssel trägt.

**Geprüfte Teilfragen des Vorschlags:**

1. **Ändert `--source .` gegenüber dem Vorgabewert etwas?** Am Verhalten nichts: Der Vorgabewert des Quellpfads ist das aktuelle Arbeitsverzeichnis. Aufgenommen wird die Angabe trotzdem, aus zwei Gründen. Erstens hängt die Aussage des Schrittes damit nicht mehr an einer ungeschriebenen Annahme über das Arbeitsverzeichnis, aus dem `make` gestartet wurde. Zweitens stehen die beiden Aufrufe unmittelbar nebeneinander; ihr Unterschied muss aus der Zeile lesbar sein, ohne dass man den Vorgabewert eines Werkzeugs kennt. Verbindlich ist: Beide Läufe beurteilen dieselbe Wurzel, nämlich das Repository-Verzeichnis.
2. **Wird ein `.gitleaksignore` nötig?** Nicht als Bestandteil dieses Entscheids und nicht auf Vorrat. Eine Ausnahmeliste entsteht ausschliesslich zu einem **belegten** Fehlalarm, je Eintrag mit Fundstelle und Begründung; eine pauschale Ausnahme für ein Verzeichnis oder eine Regel ist unzulässig, weil sie das Gate stillschweigend abschaltet. Dabei ist zu beachten, dass der Fingerabdruck eines Fundes für beide Läufe **verschieden** ist: Der Lauf über die Historie bildet ihn aus Commit, Datei, Regel und Zeile, der Lauf über den Arbeitsbaum ohne den Commit-Anteil. Eine Ausnahme, die in einem Lauf greift, greift im anderen nicht — auch das ist ein Grund, sie nur im belegten Einzelfall zu setzen und zu dokumentieren.
3. **Spielt die Reihenfolge der beiden Aufrufe eine Rolle?** Für die Aussage des Schrittes nicht, weil kein Lauf den anderen abschneidet: Beide laufen immer, beide Befunde erscheinen, und der Schritt endet ungleich 0, sobald einer ungleich 0 endete. Festgelegt wird sie dennoch — Arbeitsbaum zuerst —, damit die Ausgabe bei zwei Befunden immer gleich zu lesen ist und der Befund zuoberst steht, der vor dem Commit noch abwendbar ist. Ein Abbruch nach dem ersten Fund wäre ein Fehler: Dann bliebe der zweite Gegenstand ungeprüft, und der Schritt urteilte wieder nur über die Hälfte.

**Befund für den DevOps Engineer (neu als O-10 in Abschnitt 8).** Der Lauf über den Arbeitsbaum sieht auch Dateien, die die Versionsverwaltung nie aufnimmt — Bauerzeugnisse, Abhängigkeitsverzeichnisse, lokale Konfiguration. Welche Menge er beurteilt und wie er sich gegenüber `.gitignore` verhält, ist mit einem ausgeführten Lauf festzustellen und festzuhalten, nicht anzunehmen. Massgeblich ist der Grundsatz: Geprüft wird, was das Repository tragen kann; ausgeschlossen wird nur, was die Versionsverwaltung ohnehin nicht aufnimmt, und auch das nachvollziehbar.

**Hinweis zur Werkzeugfassung.** Festgelegt sind hier die beiden **Gegenstände** — Arbeitsbaum und Historie —, nicht die Schreibweise eines Unterbefehls. Führt die eingesetzte gitleaks-Fassung eigene Unterbefehle für Verzeichnis- und Historienlauf und kennzeichnet `detect` als überholt, ist der Wechsel zulässig, sobald ein ausgeführter Lauf die Gleichwertigkeit belegt; er wird als Fortschreibung vermerkt. Ein Wechsel, der einen der beiden Gegenstände fallen lässt, ist keine Fassungsanpassung, sondern eine Änderung dieses Entscheids.

#### 6.1.2 Der Kettenschritt für die Architekturverträge fehlte in der eigenen Tabelle

| | |
|---|---|
| **Vorher galt** | Abschnitt 3.5 verlangte den Importprüfer ausdrücklich "als eigener Kettenschritt", Abschnitt 3.12 führte ihn als eigene Prüfstufe — die Tabelle in Abschnitt 6 kannte ihn nicht. Ein Widerspruch innerhalb desselben angenommenen ADR |
| **Jetzt gilt** | D18 `make architekturvertraege` → `uv run lint-imports --config backend/importvertraege.toml`, in der Reihenfolge nach D4 und vor D5 *(seit der zweiten Fortschreibung desselben Tages `uv run --locked lint-imports`, 6.2.1)* |

**Weshalb ein eigener Schritt und keine Zuordnung zu einem bestehenden.** Die nächstliegende Alternative wäre gewesen, die Verträge als Tests unter `backend/tests/architektur/` in D5 laufen zu lassen und die Aussage in 3.5 zurückzunehmen. Dagegen sprechen drei Punkte:

1. **Eigener Rückgabewert für die stärkste Garantie.** Die Verträge aus 4.3 sind die Stelle, an der die Freigabesperre (5.2, R3-F-014) und die Modellunabhängigkeit (5.15, R3-F-018) als Struktur belegt werden. D5 erlaubt übersprungene Tests mit begründeter Markierung; ein übersprungener Vertragstest wäre ein abgeschalteter Verfahrensgarantie-Nachweis mit grünem Lauf. Ein eigener Schritt kann nicht übersprungen werden, ohne dass die Kette rot wird.
2. **Gleichbehandlung der Prüfstufen.** Jede Prüfstufe aus 3.12 hat einen eigenen Kettenschritt — Formatierung D2, Linter D3, Typprüfung D4, Tests D5, Abhängigkeiten D8, Geheimnisse D11. Der Importprüfer war die einzige Ausnahme, ohne dass ein Grund dafür genannt war.
3. **Er läuft früher und schneller als die Testsuite.** Ein Verstoss gegen eine Modulgrenze ist eine Aussage über die Struktur; sie soll vor dem Lauf der Testsuite fallen, nicht nach ihm. Deshalb die Stellung nach D4 und vor D5.

**Weshalb die Nummer 18 und keine Umnummerierung.** D13 bis D17 sind in `docs/06_Definition_of_Ready_und_Done.md`, Teil 2, an die menschlich bestätigten Bedingungen vergeben; `docs/08_Freigabe_Schritt_4.md` führt beide Tabellen ausdrücklich als einen Bereich ("D1–D12 plus die menschlich bestätigten Bedingungen D13–D17"). Ein Schritt "D13" wäre also eine Kollision, und ein Einschub als neues D5 würde D5 bis D12 verschieben. Der entscheidende Grund gegen jede Verschiebung: Die D-Nummern stehen in Dokumenten, die einen vergangenen Stand belegen und deshalb **nicht** geändert werden dürfen — Freigabevermerk vom 2026-08-20, Zustandsbericht vom 2026-08-21, die Übergabedateien. Eine Umnummerierung würde diese Nachweise falsch machen, ohne dass sie korrigierbar wären. Daraus folgt die Regel oberhalb: Nummern sind Kennungen, sie werden nicht umnummeriert und nicht wiederverwendet, und die Reihenfolge steht in der Zielliste von `make dod`.

**Was das für die Tragfähigkeit der Nummerierung heisst.** Sie trägt, sobald die Nummer nicht mehr als Reihenfolge gelesen wird. Jeder weitere Kettenschritt erhält die nächste freie Nummer (nach D18 also D19) und seine Stellung in der Kette über den Zielnamen. Die Zielnamen — `bau`, `linter`, `typen`, `architekturvertraege` — sind die Handhabe im Makefile; die Nummern bleiben die Handhabe für Verfolgbarkeit, Backlog und Definition of Done.

**Nicht berührt.** Der Vertrag 7 aus 4.3 (Trennung zu `prototype/`) bleibt zusätzlich Gegenstand von D10. Die Überschneidung ist beabsichtigt: zwei unabhängige Wege zur selben Aussage, ein Vertrag über den geschriebenen Stand und eine Stapelprüfung über den Bestand.

#### 6.1.3 Der Kettengrundsatz

| | |
|---|---|
| **Vorher galt** | Kein Satz dieses ADR sagte, dass ein Prüflauf den Arbeitsbaum unverändert lässt. D12 rief den Erzeuger des Nachweisverzeichnisses auf, der `docs/NACHWEISE.md` schreibt |
| **Jetzt gilt** | Der Grundsatz oberhalb dieses Unterabschnitts, und als Folge die geänderte Anmerkung zu D12: prüfende Betriebsart, kein Schreiben in den Arbeitsbaum |

**Weshalb er in Abschnitt 6 gehört und nicht in eine Betriebsanweisung.** Er ist keine Umsetzungsfrage, sondern eine Eigenschaft der Kette: Ohne ihn hängt das Ergebnis eines Schrittes davon ab, welcher Schritt vorher lief. Mit der Fortschreibung zu D11 wird das unmittelbar wirksam — D11 urteilt jetzt über den Arbeitsbaum, also darf kein Schritt vor D11 diesen Arbeitsbaum verändern. Ein Grundsatz, der in einer Betriebsanweisung stünde, wäre für die Umsetzung derselbe Satz, aber er wäre nicht Bestandteil des Entscheids, gegen den geprüft wird.

**Er war an einer Stelle bereits umgesetzt, nur nicht benannt.** D2 ruft `ruff format --check` und nicht `ruff format`, prüft also, statt zu formatieren. Der Grundsatz macht aus dieser einen richtigen Entscheidung eine Regel für alle Schritte.

**Abgrenzung.** Der Grundsatz verbietet nicht jedes Schreiben. Ein Bauschritt erzeugt Artefakte; das ist seine Aufgabe. Verboten ist die Änderung **versionierter** Dateien. Erzeugnisse liegen in Pfaden, die die Versionsverwaltung ignoriert — was zugleich Bedingung dafür ist, dass der Arbeitsbaumlauf aus D11 nicht in Bauerzeugnissen sucht.

#### 6.1.4 Was diese Fortschreibung nicht ändert

D1 bis D10 und D12 bleiben im Befehl unverändert; bei D12 ändert sich ausschliesslich die Betriebsart des Aufrufs, der Befund zum untauglichen `git diff`-Abgleich bleibt bestehen. Die Werkzeugwahl aus 3.12 bleibt unverändert. Die offenen Schwellenwerte (O-7) und die offenen Formfragen zu D10 und D12 (O-8) bleiben offen. Die drei am Makefile festgestellten Mängel, die diesen ADR nicht berühren — nicht ausgewertete Lage-Marke von `make dod`, falsche Lage-Zuordnung bei D9, schreibender D12-Lauf in seiner Makefile-Umsetzung —, behebt der DevOps Engineer in derselben Arbeitseinheit; der ADR-seitige Anteil des dritten Punktes ist 6.1.3.

### 6.2 Zweite Fortschreibung vom 2026-08-30 — was vorher galt, was jetzt gilt, weshalb

**Anlass.** Eine abschliessende adversarische Prüfung auf einem anderen Modell (3.4) hat nach der ersten Fortschreibung desselben Tages (Commit `84450a71569120e8deb30ecb0349ea8a92f6d736`) drei weitere Mängel **an diesem ADR** belegt — den ersten davon am neu aufgenommenen Kettengrundsatz selbst. Wie bei der ersten Fortschreibung bleiben die früheren Fassungen im Text stehen.

#### 6.2.1 Die Kette schrieb die Sperrdatei, über die sie urteilt

| | |
|---|---|
| **Vorher galt** | D1 `uv sync --frozen`, Anmerkung "Sperrdateien sind bindend; `--frozen` schlägt fehl, statt still aufzulösen"; D2 bis D8 und D18 `uv run <werkzeug>` **ohne** Schalter |
| **Jetzt gilt** | D1 `uv sync --locked`; jeder `uv run`-Aufruf der Kette mit `--locked`, einschliesslich der Verfügbarkeitsproben; dazu die Rahmenprüfung D19, die den Bestand vor und nach dem Lauf vergleicht |

**Beleg**, ausgeführter Lauf am 2026-08-30 mit der vollständigen Kette:

```
$ git status --short          ->  ?? Makefile
$ <Abhaengigkeit in pyproject.toml ergaenzt, uv.lock nicht neu erzeugt>
$ make -s dod
::LAGE D1 bau A_OK::          <- uv sync --frozen laeuft durch, es prueft die Drift nicht
$ git status --short
 M pyproject.toml
 M uv.lock                    <- versionierte Datei, durch den Prueflauf geaendert
```

`uv.lock` ist nicht in `.gitignore` (`git check-ignore` endet mit 1) und laut der D1-Zeile bindend, also versioniert. Der erste `uv run`-Aufruf nach einer Abweichung zwischen `pyproject.toml` und `uv.lock` schreibt sie neu. Damit verletzte die Kette den Grundsatz aus 6.1.3 an ihrer eigenen zweiten Zeile — und zwar im Regelfall, nämlich immer dann, wenn jemand eine Abhängigkeit ergänzt und der Stop-Hook läuft. Verschärfend trifft es D11: Seit der ersten Fortschreibung urteilt D11 über den Arbeitsbaum, und alle `uv run`-Schritte laufen vor D11.

**Geprüfte Teilfragen des Vorschlags:**

1. **Hat `--frozen` bei `uv run` dieselbe Bedeutung wie bei `uv sync`?** Für die Sperrdatei ja: Beide Aufrufe lassen sie unangetastet und lösen nicht neu auf. Der Vorschlag würde das Schreiben also tatsächlich beenden. Er greift trotzdem zu kurz, weil `--frozen` bei beiden Befehlen auch **nicht meldet**: Es installiert und läuft stumm gegen einen möglicherweise veralteten Stand. Genau das war schon der Fehler der bisherigen D1-Anmerkung, die `--frozen` ein Scheitern zuschrieb, das es nicht leistet. Ein Prüflauf, der gegen einen anderen Abhängigkeitsstand läuft als den erklärten, verletzt K4 und behauptet eine Reproduzierbarkeit, die er nicht hat.
2. **Was leistet `--locked` stattdessen?** Es sagt zu, dass die Sperrdatei unverändert bleibt, **und** endet ungleich 0, wenn sie es nicht bliebe. Beide Eigenschaften werden gebraucht: die erste für den Kettengrundsatz, die zweite für die Aussage der D1-Zeile. Deshalb `--locked` und nicht `--frozen` — an beiden Befehlen, damit in der Kette kein zweiter Schalter mit anderer Bedeutung steht. Die Wirkung im Überblick: ohne Schalter — schreibt, meldet nicht; `--frozen` — schreibt nicht, meldet nicht; `--locked` — schreibt nicht, meldet.
3. **Warum nicht zusätzlich das Herstellen der Umgebung unterbinden?** Weil die Umgebung in `.venv/` liegt und dieser Pfad von der Versionsverwaltung ignoriert wird; der Grundsatz verbietet ausschliesslich die Änderung versionierter Dateien (6.1.3, Abgrenzung). Ein Unterbinden machte jeden Schritt zusätzlich davon abhängig, dass vorher jemand D1 ausgeführt hat — eine ungeschriebene Vorbedingung, die genau die Art Abhängigkeit zwischen Schritten erzeugt, die der Grundsatz beseitigen soll.
4. **Gilt dasselbe für die Oberfläche?** Dort ist es bereits erfüllt und bleibt unverändert: `npm ci` verweigert den Lauf bei Abweichung zwischen `package.json` und `package-lock.json` und schreibt die Sperrdatei nicht — das ist die Entsprechung zu `--locked`. `npm audit` schreibt nicht; `npm audit fix` täte es und kommt in der Kette nicht vor. `npm run build` schreibt nach `frontend/dist/`, und `dist/` ist ignoriert.
5. **Soll die Nachprüfung ein Kettenschritt werden oder eine Eigenschaft von `make dod`?** Eine Eigenschaft von `make dod`, geführt als D19. Drei Gründe: Ein Schritt in der Zielliste sieht nur seinen eigenen Augenblick und könnte nicht beurteilen, was ein späterer Schritt schreibt. Ein Schritt am Ende der Liste liefe bei einem früheren Abbruch gar nicht — also gerade dann nicht, wenn ein Schritt schreibt und scheitert. Und ein Schritt in der Liste unterläge selbst der Reihenfolgeabhängigkeit, die er aufdecken soll. Eine Nummer erhält er trotzdem, damit Definition of Done, Backlog und Nachweise ihn benennen können.
6. **Ersetzt D19 die Schalter?** Nein, und umgekehrt auch nicht. `--locked` verhindert den häufigsten Fall, bevor er eintritt, und nennt seine Ursache; D19 fängt jeden Fall, an den niemand gedacht hat, kann aber nur feststellen **dass** etwas geschrieben wurde. Beide Massnahmen bleiben.

**Nachweispflicht.** Die Wirkung der Schalter ist hier aus der dokumentierten Bedeutung der Werkzeuge begründet, nicht aus einem eigenen Lauf: Diese Rolle hat kein Ausführungswerkzeug und prüft ihre eigene Arbeit ohnehin nicht (3.4). Zu belegen ist mit einem ausgeführten Lauf, jeweils mit künstlich erzeugter Abweichung zwischen `pyproject.toml` und `uv.lock`: (a) `uv sync --locked` und `uv run --locked <werkzeug>` enden ungleich 0, (b) `uv.lock` ist danach unverändert, (c) `make dod` meldet über D19 keine Abweichung im Arbeitsbaum, (d) die Aktualitätsprüfung von `--locked` kommt ohne ausgehende Verbindung aus (K3). Zuständig sind DevOps Engineer und die Testerrollen.

#### 6.2.2 Die Objektbedingung stand zweimal verschieden, und D10 hatte gar keine

| | |
|---|---|
| **Vorher galt** | Die D18-Zeile knüpfte Lage C an "Existiert `backend/src/r3cosint/` ohne `backend/importvertraege.toml`"; der Absatz "Umgang mit noch nicht vorhandenen Teilbäumen" nannte als Lage-B-Auslöser "Fehlt `backend/` ganz". D10 nannte keine Bedingung |
| **Jetzt gilt** | Eine allgemeine Regel, woran ein Kettenschritt seinen Gegenstand erkennt, samt einer Objekttabelle für alle Schritte — an genau einer Stelle in diesem ADR. D18 knüpft an Python-Produktionscode unterhalb `backend/src/`, unabhängig vom Paketnamen. D10 läuft, solange `prototype/` besteht |

**Beleg**, ausgeführter Lauf am 2026-08-30: Bei Produktionscode unter `backend/src/r3cosint_api/` — `backend/` vorhanden, `backend/src/r3cosint/` nicht — liefen D1 bis D4 als bestanden, und D18 meldete Lage B mit Rückgabewert 0. Die Architekturverträge blieben also ungeprüft, obwohl Produktionscode vorlag. Dass der Lauf trotzdem nicht grün wurde, lag allein an einem fest verdrahteten Abdeckungspfad in D6 — ein Zufall, kein Entwurf.

**Weshalb die Sache und nicht der Paketname.** Die Namensgebung aus 4.1 und A13 bleibt verbindlich; `backend/src/r3cosint/` ist der vorgeschriebene Ort. Aber ein Kettenschritt darf nicht davon abhängen, dass genau die Regel eingehalten ist, deren Einhaltung er mit absichern soll. Ein Verstoss gegen die Namensgebung muss die Prüfung **auslösen**, nicht abschalten. Deshalb erkennt D18 seinen Gegenstand an dem, was er ist — Python-Quelltext unterhalb der Bauwurzel `backend/src/` —, und die Vertragsdatei nennt jedes dort vorhandene oberste Paket als Wurzelpaket. Ein Paket, das die Vertragsdatei nicht nennt, ist damit ein Befund und kein blinder Fleck.

**Weshalb D10 immer läuft.** Denkbar wäre gewesen, D10 an das Vorhandensein von Produktionscode zu knüpfen; heute gäbe das Lage B, weil noch kein Produktionscode besteht. Dagegen sprechen drei Punkte. Erstens wechselte die Lage dann in dem Augenblick still, in dem die erste Produktionsdatei entsteht — ein Zustandswechsel, den niemand beobachtet, und genau das Muster, das bei D18 zum Befund geführt hat. Zweitens ist der Gegenstand von D10 die **Trennung** und nicht der Produktionscode; `prototype/` besteht nach 5.6 dauerhaft, und die Stapelprüfung urteilt über den Bestand. Drittens ist "ich kann das nicht beurteilen, das Prüfmittel fehlt" die ehrlichere Aussage als "es gibt nichts zu beurteilen". Praktisch ändert das an der Farbe der Kette heute nichts: D7, D11 und D12 stehen ohnehin in Lage C, solange ihre Skripte und Werkzeuge fehlen.

**Das gemeinsame Muster.** Die adversarische Prüfung hat es benannt: *Die Lage wird an einem Pfadnamen festgemacht statt am Gegenstand.* Es trat in beide Richtungen auf — der ADR liess die Bedingung bei D10 offen und die Umsetzung erfand eine; bei D18 nannte der ADR sie zweimal verschieden. Beides hat dieselbe Ursache: Die Objektbestimmung war nirgends grundsätzlich geregelt. Deshalb steht die Regel jetzt einmal in Abschnitt 6, vor der Aufzählung der Einzelfälle, und nicht je Schritt verstreut.

#### 6.2.3 Prüffläche des Arbeitsbaumlaufs in D11 — O-10 in seinem ersten Teil beantwortet

| | |
|---|---|
| **Vorher galt** | O-10 liess offen, welche Dateien der Arbeitsbaumlauf beurteilt und wie er sich gegenüber `.gitignore` verhält |
| **Jetzt gilt** | Die Frage ist beantwortet — `.gitignore` wirkt nicht — und die Folge ist entschieden: Zugangsdaten liegen nicht im Arbeitsbaum; ausgeschlossen werden ausschliesslich namentlich genannte Abhängigkeits- und Bauverzeichnisse. O-10 bleibt für zwei Restfragen offen |

**Beleg**, ausgeführter Lauf am 2026-08-30 mit gitleaks 8.21.2:

```
$ git check-ignore -v geheim.pem   ->  .gitignore:21:*.pem  geheim.pem
$ gitleaks detect --no-git --redact --exit-code 1 --source .   ->  leaks found: 1, rc=1
$ make -s geheimnisse              ->  ::LAGE D11 geheimnisse A_FAIL::, rc=2
```

Eine lokale, niemals committierbare `.env` oder ein `*.pem` blockiert damit die gesamte Kette und den künftigen Stop-Hook dauerhaft.

**Optionen.**

| Option | Bewertung |
|---|---|
| (a) Ausnahme je Fundstelle über `--gitleaks-ignore-path` | Für **committeten** Inhalt richtig und bereits geregelt (6.1.1, Punkt 2). Für eine lokale Zugangsdatei untauglich: Der Fingerabdruck hängt am Inhalt, ändert sich mit jedem Wechsel des Geheimnisses, ist in den beiden Läufen verschieden, und er müsste versioniert werden — eine Datei, die für jeden anderen Arbeitsplatz bedeutungslos ist und den Eintrag zum Dauerrauschen macht |
| (b) Pfadausschluss je Fundstelle mit Begründung | Für Abhängigkeits- und Bauverzeichnisse tragfähig, weil dort niemals Repository-Inhalt liegt. Für `.env` und `*.pem` unzulässig: Das sind genau die Pfade mit dem höchsten Wert, und ein Ausschluss schaltete das Gate für sie stillschweigend ab |
| (c) Trennung zwischen "blockiert" und "meldet" | Abgelehnt. Eine Meldung, die nicht blockiert, wird in einem Stop-Hook nicht gelesen. 5.4 verlangt Bauvorschriften, die im Betrieb nicht abschaltbar sind; eine abgestufte Wirkung ist eine Abschaltung mit besserem Namen |
| (d) Zugangsdaten liegen ausserhalb des Arbeitsbaums | Nimmt dem Problem die Ursache, statt das Gate zu schwächen. Kein Ausschluss, keine Ausnahmeliste, kein Verlust an Prüffläche — es gibt schlicht nichts zu finden. Setzt eine Betriebsanweisung und eine Stelle in der Betriebsdokumentation voraus |
| (e) Pauschaler Ausschluss alles von `.gitignore` Erfassten | Abgelehnt. Er höbe den Gewinn der ersten Fortschreibung wieder auf: Ein Schlüssel im Arbeitsbaum ist für die Versionsverwaltung unsichtbar, also sieht ihn der Historienlauf nie — der Arbeitsbaumlauf ist der **einzige**, der ihn sieht. Wer ihn ausschliesst, prüft doppelt dieselbe Hälfte |

**Entscheid.** (d) als Regel, (b) eng begrenzt als Mittel, (a) unverändert für belegte Fehlalarme an committetem Inhalt, (c) und (e) abgelehnt. Im Einzelnen:

1. **Zugangsdaten und Geheimnisse liegen nicht im Arbeitsbaum** — auch nicht in einer von der Versionsverwaltung ignorierten Datei. Das schärft A11 ("Geheimnisse kommen als eingehängte Dateien, nie in ein Image, nie ins Repository") um den Fall, den A11 nicht ausdrücklich nannte: Das Repository-Verzeichnis ist auch dann der falsche Ort, wenn die Datei nicht committet wird. Die Dateien unter `deploy/konfiguration/{test,produktion}/` sind nach Abschnitt 5 ohnehin Beispieldateien ohne Geheimnisse; die tatsächlichen Werte kommen von ausserhalb des Arbeitsbaums. Damit ist ein Fund im Arbeitsbaum immer ein Befund und nie ein Betriebszustand.
2. **Ausgeschlossen wird ausschliesslich, was kein Repository-Inhalt sein kann** — Abhängigkeits- und Bauverzeichnisse (`node_modules/`, `.venv/`, `dist/`, `build/`, die Zwischenspeicher der Prüfwerkzeuge). Das ist keine neue Freiheit, sondern der bereits in 6.1.1 gesetzte Massstab: "ausgeschlossen wird nur, was die Versionsverwaltung ohnehin nicht aufnimmt, und auch das nachvollziehbar". Der Ausschluss wird **namentlich aufgezählt** und versioniert abgelegt, nicht aus `.gitignore` abgeleitet — die Ableitung würde `.env` und `*.pem` mit ausschliessen und wäre damit Option (e). Er hat einen zweiten Zweck: Fremdpakete bringen Testschlüssel mit, und ein Lauf über `node_modules/` erzeugt Fehlalarme und Laufzeit ohne Erkenntnisgewinn.
3. **Der Schutz wird nicht abgestuft.** D11 bleibt blockierend, beide Läufe bleiben zwingend.

**Was offen bleibt und weshalb** (O-10 in Abschnitt 8 neu gefasst): die namentliche Ausschlussliste und ihre technische Form — Konfigurationsdatei des Werkzeugs oder Aufrufparameter —, weil sie an der eingesetzten Werkzeugfassung hängt und mit einem ausgeführten Lauf zu belegen ist (DevOps Engineer mit SecDevOps); und die betriebliche Form von Punkt 1 — wo die Zugangsdaten liegen, wie der Prüfstapel sie einhängt, wie das in der Betriebsdokumentation und in der Bereitschaftsliste steht (SecDevOps mit DevOps Engineer). Beides ist Umsetzung und Betrieb, nicht Architektur; diese Rolle entscheidet es nicht.

#### 6.2.4 Was diese Fortschreibung nicht ändert

Die Werkzeugwahl aus 3.12 bleibt unverändert. D9, D10, D11 und D12 bleiben im Befehl unverändert; bei D10 und D18 ändert sich ausschliesslich die Objektbedingung, bei D11 ausschliesslich die Prüffläche. Die beiden Läufe aus 6.1.1, der Kettengrundsatz aus 6.1.3 und die Nummernregel aus 6.1.2 bleiben in Kraft und werden durch D19 ergänzt, nicht ersetzt. Die offenen Schwellenwerte (O-7) und die offenen Formfragen zu D10 und D12 (O-8) bleiben offen. Der Befund zum untauglichen `git diff`-Abgleich in D12 bleibt bestehen.

### 6.3 Dritte Fortschreibung vom 2026-08-30 — vier gemeldete Abweichungen des Makefiles, entschieden

**Anlass.** Der DevOps Engineer hat die zweite Fortschreibung (Commit `1ab5898107e1d580929ea81da666d6efc31e772d`) im Makefile umgesetzt und dabei vier Abweichungen zwischen Wortlaut und Umsetzung **gemeldet, statt sie stillschweigend zu entscheiden**. Das ist der vorgesehene Weg (CLAUDE.md: Abweichungen von ADR 0002 nur als Fortschreibung). Drei davon sind hier zu entscheiden, die vierte ist zur Kenntnis genommen und terminiert. Wie bei den beiden vorangehenden Fortschreibungen bleiben die früheren Fassungen im Text stehen.

#### 6.3.1 `--locked` blieb ohne `--project backend` wirkungslos

| | |
|---|---|
| **Vorher galt** | `uv sync --locked` in D1 und `uv run --locked <werkzeug>` in D2 bis D8 und D18, ohne Angabe des Projekts |
| **Jetzt gilt** | Jeder `uv`-Aufruf der Kette trägt zusätzlich `--project backend`. Das Arbeitsverzeichnis aller Kettenschritte bleibt die Repository-Wurzel; alle Pfadangaben in den Befehlen bleiben repo-relativ, wie sie in der Tabelle stehen |

**Beleg**, ausgeführter Lauf am 2026-08-30 aus der Repository-Wurzel, `backend/pyproject.toml` vorhanden:

```
$ uv run --locked python -c "pass"
warning: `--locked` has no effect when used outside of a project

$ uv run --locked --project backend python -c "print('lief')"
Creating virtual environment at: backend/.venv
error: Unable to find lockfile at `uv.lock`. ...
```

`uv` sucht ein Projekt ausschliesslich **aufwärts** vom Arbeitsverzeichnis, nie abwärts. Das Makefile setzt das Arbeitsverzeichnis auf die Repository-Wurzel; `backend/pyproject.toml` liegt darunter und wird von dort nie gefunden. Der Entscheid der zweiten Fortschreibung — die Kette schreibt die Sperrdatei nicht und meldet eine Abweichung — war damit in seiner tragenden Hälfte unwirksam: Der Schalter meldete nur, dass er nichts bewirkt, und diese Warnung geht im Rauschen eines Kettenlaufs unter. Der zweite Aufruf zeigt, dass `--project backend` beides herstellt: Projektauflösung und die Aussage des Schalters.

**Optionen.**

| Option | Bewertung |
|---|---|
| (a) `--project backend` an jedem `uv`-Aufruf, Arbeitsverzeichnis unverändert die Repository-Wurzel | `--project` benennt das Projekt, ohne das Arbeitsverzeichnis zu wechseln. Alle Pfadargumente der Befehle bleiben wörtlich so gültig, wie sie in der Tabelle stehen — `backend/src` in D1 und D4, `backend/tests` in D4, `--cov=backend/src/r3cosint` in D6, `backend/importvertraege.toml` in D18 |
| (b) `--directory backend` | Wechselt das Arbeitsverzeichnis. Jedes der genannten Pfadargumente müsste umgeschrieben werden, und die Kette hätte zwei Pfadwelten: `uv`-Schritte relativ zu `backend/`, alle übrigen (gitleaks, die Skripte in `scripts/`, `docker compose -f deploy/...`) relativ zur Wurzel. Wer eine Zeile liest, müsste wissen, welcher Schritt das Verzeichnis wechselt |
| (c) Wechsel des Arbeitsverzeichnisses im Makefile mit angepassten Argumenten | Wie (b), zusätzlich im Makefile je Rezeptzeile herzustellen. Ein Zustand, den jede Zeile neu erzeugen muss, ist die fehleranfälligere Form derselben Sache |

**Entscheid: (a).** Vier Gründe, jeder für sich tragend.

1. **Ein Arbeitsverzeichnis für die ganze Kette.** Für D11 ist das seit 6.1.1, Punkt 1 bereits verbindlich: "Beide Läufe beurteilen dieselbe Wurzel, nämlich das Repository-Verzeichnis." Ein Schritt, der das Verzeichnis wechselt, macht diese Zusicherung von der Reihenfolge abhängig — dieselbe Art Abhängigkeit, die der Kettengrundsatz aus 6.1.3 beseitigen soll.
2. **Merkmal und Aufruf nennen dieselbe Sache.** Die Objekttabelle erkennt den Backend-Anteil von D1 bis D8 an `backend/pyproject.toml`. Genau diese Datei benennt `--project backend`. Damit prüft der Schritt das, woran er seinen Gegenstand erkennt, und nicht ein zufällig gleichnamiges Verzeichnis (Regel 1 der Objektbestimmung).
3. **Keine dreizehnfache Argumentänderung.** Die Pfadangaben in Abschnitt 6 sind an mehreren Stellen wörtlich in Gebrauch — der Abdeckungspfad aus D6 steht so auch in den Abdeckungsberichten und folgt dem Modulbaum aus 4.1. Eine Umschreibung aller Argumente wäre eine Änderung mit Fehlerfläche ohne Gewinn.
4. **Der Umgebungspfad bleibt ignoriert.** `uv` legt die Umgebung unter `backend/.venv/` an. `.gitignore` führt in Zeile 4 `.venv/` ohne führenden Schrägstrich, greift also auf jeder Ebene (geprüft am 2026-08-30). D19 schlägt daran nicht an; ein Nachtrag ist nicht nötig.

**Was hier nicht entschieden wird und zu belegen ist.** Aus dem unveränderten Arbeitsverzeichnis folgt, dass jeder Schritt seinen Gegenstand als Argument nennen oder aus `backend/pyproject.toml` beziehen muss. Für `ruff`, `mypy`, `compileall` und `lint-imports` steht er im Befehl; `pip-audit` beurteilt die Umgebung, also `backend/.venv/`. Bei `pytest` in D5 und D6 steht keine Pfadangabe, und das Arbeitsverzeichnis ist die Wurzel — welchen Gegenstand `pytest` von dort aus einsammelt und woher es seine Konfiguration nimmt, ist mit einem ausgeführten Lauf festzustellen, nicht anzunehmen. Sammelt es ausserhalb von `backend/` ein, erhält die D5- und D6-Zeile eine Pfadangabe; das wäre eine eigene Fortschreibung. Zuständig: DevOps Engineer, Verifikation bei den Testerrollen (3.4). Die Nachweispflicht aus 6.2.1 bleibt daneben bestehen und wird um einen Punkt (e) ergänzt: Der Lauf, der (a) bis (d) belegt, belegt zugleich, dass `--locked` nicht mehr mit "has no effect" antwortet.

#### 6.3.2 D7 erkannte seinen Gegenstand am Dateinamen

| | |
|---|---|
| **Vorher galt** | Objekttabelle, D7 zweiter Teil: Erkennungsmerkmal "`docs/05_Product_Backlog.md` führt Abnahmekriterien", Lage B "keine Abnahmekriterien vorhanden" |
| **Jetzt gilt** | Erkennungsmerkmal ist eine Datei unterhalb `docs/`, die den Backlog trägt, gefunden über das Suchmuster `docs/05_Product_Backlog*.md`. **D7 hat keine Lage B.** Findet der Schritt keine solche Datei oder führt die gefundene keine Abnahmekriterien, endet er ungleich 0 |

**Beleg**, festgestellt vor dieser Fortschreibung: Nach `mv docs/05_Product_Backlog.md docs/05_Product_Backlog_v2.md` meldete D7 Lage B mit Rückgabewert 0, obwohl der Backlog mit allen Abnahmekriterien unverändert vorlag. Das Makefile verwendet deshalb bereits das Suchmuster; der ADR nannte den einen Dateinamen.

**Entscheid und Begründung.** Der Glob wird **nicht** zurückgebaut, und er allein genügt auch nicht. Beide Teile folgen aus der eigenen Regel 1 der Objektbestimmung: Der Gegenstand von D7 sind die **Abnahmekriterien des Backlogs**, nicht eine Datei mit einem bestimmten Namen. Ein Dateiname ist hier nicht die tragende Ausprägung des Gegenstands — der Backlog bleibt derselbe, wenn er umbenannt, versioniert oder verschoben wird. Der Glob behebt den belegten Fall (Versionsanhang), aber er bleibt eine Namensbindung: `docs/backlog.md` fände er ebenso wenig. Deshalb wiegt der zweite Teil schwerer.

**Weshalb D7 keine Lage B mehr hat.** Der Backlog ist seit der Freigabe von Schritt 3 dauerhafter Bestandteil des Repositories, wie `docs/` für D12 und `prototype/` für D10. Ein Repository ohne Backlog mit Abnahmekriterien ist kein zulässiger Zustand dieses Projekts, über den ein Prüfschritt schweigend hinweggehen dürfte. Damit gilt Regel 3: Nennt die Tabelle keine Lage B, gibt es keine. Das ist zugleich die dauerhafte Antwort auf den belegten Fall — welchen Namen die Datei auch trägt, ein Nichtfinden macht die Kette rot statt grün, und "ich habe nichts gefunden" ist nie mehr ein bestandener Schritt. Der Glob bleibt als Suchmuster, damit eine zulässige Umbenennung nicht unnötig einen roten Lauf erzeugt; treffen mehrere Dateien zu, werden alle beurteilt und in der Lage-Meldung genannt (Regel 4).

**Wo die Erkennung auf Dauer sitzt.** Nicht im Makefile. `scripts/abnahme-abgleich.sh` entsteht mit dem Grundgerüst und kennt Backlog und Abnahmekriterien ohnehin; die Bestimmung des Gegenstands gehört dorthin, und das Makefile ruft nur auf. Bis das Skript besteht, trägt das Suchmuster im Makefile die Bestimmung. Das ist keine zweite Bedingung, sondern dieselbe an einem vorläufigen Ort.

#### 6.3.3 D11 — `git` ist Prüfmittel, nicht nur Erkennungsmerkmal

| | |
|---|---|
| **Vorher galt** | Objekttabelle, D11: Erkennungsmerkmal "`.git/` vorhanden", Prüfmittel "`gitleaks`" |
| **Jetzt gilt** | Prüfmittel: `gitleaks`; für den Historienlauf zusätzlich `git`. Fehlt `git` bei vorhandenem `.git/`, ist das Lage C — Rückgabewert ungleich 0 |

**Entscheid.** Das Makefile ist richtig, der ADR war ungenau. Die Trennung von Merkmal und Prüfmittel bleibt bestehen; sie war nur unvollständig ausgefüllt.

**Begründung.** D11 besteht aus zwei zwingenden Läufen mit verschiedenen Gegenständen (6.1.1). Der Arbeitsbaumlauf (`--no-git`) braucht `git` nicht. Der Historienlauf urteilt über die Git-Historie und kommt ohne `git` nicht an sie heran. Fehlt `git` bei vorhandenem `.git/`, ist der Gegenstand also vorhanden und ein Prüfmittel fehlt — das ist wörtlich Lage C, und der Satz "Ein fehlendes Prüfmittel ist kein bestandener Schritt" trifft hier den gefährlichsten Fall: Ein Schritt, der nur noch den Arbeitsbaum sieht und trotzdem grün meldet, erklärt ein Repository für sauber, dessen dritter Commit einen Schlüssel trägt (6.1.1). Das Merkmal bleibt `.git/`, weil es den Gegenstand bezeichnet; `git` bezeichnet die Fähigkeit, über ihn zu urteilen. D19 führt `git` aus demselben Grund bereits als Prüfmittel.

**Nicht geändert.** Der Arbeitsbaumlauf bleibt vom Vorhandensein von `git` unabhängig. Er entfällt nicht, wenn `git` fehlt — er läuft, sein Befund erscheint, und der Schritt endet trotzdem ungleich 0, weil der zweite Gegenstand unbeurteilt blieb. Kein Lauf schneidet den anderen ab (6.1.1, Teilfrage 3).

#### 6.3.4 D18 — der Abgleich der Wurzelpakete ist terminiert, nicht gebaut

Zur Kenntnis genommen, kein Entscheid nötig, aber ein offener Punkt. Die Anmerkung "Zu D18" verlangt, dass `backend/importvertraege.toml` jedes oberste Paket unterhalb `backend/src/` als Wurzelpaket nennt; sonst meldet der Prüfer Lage A, ohne etwas beurteilt zu haben. Genau dieser blinde Fleck war der Befund aus 6.2.2. Er ist heute nicht gebaut, weil die Vertragsdatei noch nicht besteht, und im Makefile als Kommentar hinterlegt.

**Weshalb das als offener Punkt geführt wird und nicht als erledigt.** Ein Kommentar ist keine Prüflogik. Der ADR sagt zur auskommentierten Prüfung bereits: Sie bleibt still liegen, nachdem sie gebraucht würde. Der Augenblick, in dem sie gebraucht wird, ist derselbe, in dem `backend/importvertraege.toml` entsteht — also mit dem Grundgerüst, in einer Arbeitseinheit einer anderen Rolle als der, die den Kommentar geschrieben hat. Ohne Eintrag in Abschnitt 8 hinge die Erinnerung an einer Zeile im Makefile. Neu als **O-11** terminiert.

#### 6.3.5 Was diese Fortschreibung nicht ändert

Die Werkzeugwahl aus 3.12 bleibt unverändert. Kein Kettenschritt wechselt sein Werkzeug, seine Stellung in der Reihenfolge oder seinen Gegenstand; D9, D10, D12, D18 und D19 bleiben unberührt. Der Kettengrundsatz aus 6.1.3, die Nummernregel aus 6.1.2, die beiden Läufe aus 6.1.1, die Objektbestimmung aus 6.2.2 und die Prüffläche aus 6.2.3 bleiben in Kraft. `--locked` bleibt und wird durch `--project backend` nicht ersetzt, sondern erst wirksam. Die offenen Schwellenwerte (O-7), die Formfragen zu D10 und D12 (O-8) und die beiden Restfragen aus O-10 bleiben offen.

---

### 6.4 Vierte Fortschreibung vom 2026-08-30 — D19 misst den Inhalt, nicht die Statusliste

**Eingetragen durch den Koordinator**, nicht durch den Software Architect. Der
Grund gehört zur Sache: Der Befund entstand beim Wirkungsnachweis zu B2 und ist
ausgeführt belegt; die Umsetzung im Makefile wäre sonst stillschweigend vom ADR
abgewichen, was CLAUDE.md untersagt. Der Software Architect prüft die
Formulierung bei nächster Gelegenheit nach.

**Was vorher galt.** Abschnitt 6.3 legte für D19 als Mittel `git status
--porcelain` fest, vorher und nachher, zeilenweise verglichen.

**Was jetzt gilt.** Die Aufnahme umfasst zusätzlich eine Inhaltsprüfsumme je
verfolgter Datei, und die Statusliste wird mit `--untracked-files=all` erhoben.

**Weshalb.** Die blosse Statusliste misst, **welche** Dateien abweichen, nicht
**wie**. Eine Datei, die schon vor dem Lauf geändert war, trägt vorher wie
nachher denselben Eintrag `` M datei`` — auch wenn ein Kettenschritt sie
während des Laufs erneut ändert. Ausgeführt belegt am 2026-08-30 in einem
`git worktree`:

```
Vorbedingung: " M Makefile  M README.md"
Kettenschritt haengt eine Zeile an README.md an
vorher:  make dod endete mit 0 -- "D19 ohne Befund"
nachher: make dod endet mit 2 -- "D19 verletzt"
```

Der Fall ist nicht der Randfall, sondern der Regelfall: Die Kette läuft nach
6.1.1 **vor** dem Commit, also auf einem Baum, der üblicherweise bereits
Änderungen trägt. Ohne die Prüfsumme wäre der Kettengrundsatz aus 6.1.3 genau
dort blind, wo er gebraucht wird.

**Einordnung in das Muster.** Die Schlussprüfung vom 2026-08-30 hat als Ursache
aller drei gescheiterten Runden benannt: *die Kette misst die Verfügbarkeit
eines Namens, nicht die Anwesenheit des Gegenstands.* Die Statusliste ist
derselbe Fehler eine Ebene höher — sie misst eine Liste von Namen statt den
Inhalt. Die Fortschreibung schliesst ihn an dieser Stelle.

**Preis, benannt statt verschwiegen.** Die Prüfsumme läuft zweimal je
`make dod` über alle verfolgten Dateien. Bei einem grossen Bestand ist das
spürbar; die Alternative wäre ein unbeobachtbarer Grundsatz. Sollte die Laufzeit
stören, ist die Antwort eine schnellere Prüfsumme, nicht eine ungenauere
Aufnahme.

### 6.5 Fünfte Fortschreibung vom 2026-08-31 — wogegen die Kette schützt, und wogegen nicht

**Eingetragen durch den Koordinator.** Fünf adversarische Prüfrunden haben ein
Muster erzeugt: Jede geschlossene Umgehung brachte eine neue hervor —
`PATH`, dann `UV_PROJECT_ENVIRONMENT`, dann `PYTHONPATH`, dann `BASH_ENV`.
Der ADR entscheidet deshalb, was er bisher offenliess: die Reichweite.

**Was jetzt gilt.** Die Definition-of-Done-Kette schützt gegen **Bequemlichkeit
und Abkürzung** — ein Schritt, der mit 0 endet, ohne geprüft zu haben; ein
fehlendes Prüfmittel, das als "keine Beanstandung" durchgeht; ein Schritt, der
den Gegenstand verändert, über den er urteilt; eine Lage-Marke, die etwas
anderes behauptet als der Rückgabewert. Das ist die Fehlerklasse aus 3.4.

Sie schützt **nicht** gegen jemanden, der die Umgebung des Aufrufs beherrscht.
Zwei ausgeführte Belege vom 2026-08-31. Ein dritter Fall, der **nicht** unter
diese Begründung fiel, ist am selben Tag hinzugekommen (6.6.1) und am selben
Tag geschlossen worden (6.7) — er ist deshalb kein Beleg mehr für diesen
Absatz, sondern für den Satz, der aus ihm folgt: **Eine Abgrenzung ist keine
Erlaubnis.**

1. **`BASH_ENV`.** Bash liest die Variable auch für nicht-interaktive Shells,
   und zwar **bevor die erste Rezeptzeile läuft**. Eine dort definierte Funktion
   `env` verschluckt jeden `$(UV)`-Aufruf; D1 bis D8 und D18 melden "bestanden",
   ohne dass ein Werkzeug lief.
2. **Ein gefälschtes `uv` früher im `PATH`** bedient die Umfeldprobe und den
   eigentlichen Aufruf zugleich.

**Weshalb das nicht zu schliessen ist.** Jede gesperrte Variable hat eine
Nachfolgerin, und die zuletzt gefundene wirkt **vor** dem ersten eigenen Befehl
der Datei. Eine Negativliste über die Umgebung kann nicht schliessen — dieselbe
Einsicht, die 6.2.2 für die Objektbestimmung festgehalten hat.

**Weshalb es vertretbar ist.** Wer `BASH_ENV` setzen kann, während `make dod`
aufgerufen wird, kann den Aufruf ebenso gut unterlassen oder das Makefile
ändern. Ein Gate im Arbeitsverzeichnis ist gegen den, der das
Arbeitsverzeichnis beherrscht, grundsätzlich wirkungslos.

**Folge, die in die Planung gehört.** Die Kette ist die **zweite Linie** — wie
die beiden PreToolUse-Gates, deren Kopfkommentare dasselbe festhalten. Die
harte Zusicherung liegt dort, wo der Aufrufer die Umgebung nicht beherrscht:
in einem Lauf auf der Gegenseite (Bauumgebung, Server), analog zum Ruleset, das
den Schutz von `main` trägt. **Solange dieser Lauf fehlt, ist die Kette die
Selbstprüfung eines kooperierenden Aufrufers.** Das ist beim Nachweis nach 5.3
mitzudenken und beim Zuschnitt von R3-Q-001 zu berücksichtigen.

**Neuer offener Punkt O-12:** Ein Lauf der Kette auf der Gegenseite, in einer
Umgebung, die der Aufrufer nicht setzt. Zuständig: DevOps Engineer mit
SecDevOps; fällig mit dem Grundgerüst, spätestens mit der Bereitschaftsliste.

### 6.6 Sechste Fortschreibung vom 2026-08-31 — die Reichweite aus 6.5 war zu weit gefasst, und die Projektbestimmung urteilte über das falsche Repository

**Eingetragen durch den Koordinator** nach einer sechsten, bewusst eng
gefassten Prüfrunde auf einem anderen Modell. Sie hat genau die beiden
Änderungen geprüft, die 6.5 nach sich zog, und für beide einen blockierenden
Befund erhoben. Beide sind behoben; hier steht, was vorher galt, was jetzt
gilt und weshalb.

#### 6.6.1 Die Positivliste um `$(UV)` war zu breit — der Zwischenspeicher hebelt `--locked` aus

| | |
|---|---|
| **Vorher galt** | Jeder `uv`-Aufruf läuft über eine leere Umgebung (`env -i`), durchgereicht wird nur eine Positivliste. Am 2026-08-31 wurde diese Liste um die Netz- und Zertifikatsvariablen erweitert, weil `uv` in einer Umgebung mit Proxy und eigener Wurzelzertifizierungsstelle sonst scheitert. Mitgenommen wurden dabei `UV_CACHE_DIR`, `XDG_CACHE_HOME` und `TMPDIR` |
| **Jetzt gilt** | Diese drei stehen nicht mehr auf der Liste. Durchgereicht wird ausschliesslich, was der Proxy- und Zertifikatsfall nachweislich braucht, dazu `LANG`/`LC_ALL` für die Kodierung der Ausgabe |

**Der Beleg.** `--locked` prüft die Prüfsumme eines Pakets beim
**Herunterladen**. Liegt ein bereits **entpacktes** Archiv im Zwischenspeicher,
wird es ohne erneute Prüfung ins Umfeld gelegt. Die Prüfung hat das mit einem
ausgeführten Lauf gezeigt: präparierter Zwischenspeicher, `.venv` gelöscht,
`make bau` erneut — Ergebnis `A_OK` bei manipuliertem Paketinhalt im Umfeld.
Der Weg über `HTTPS_PROXY` führt dagegen **nicht** zu einem falschen `A_OK`,
sondern zu einem sauberen Fehlschlag; dort trägt `--locked`.

**Weshalb das kein Sonderfall von 6.5 ist.** 6.5 begründet die Reichweite mit
dem Satz: Wer die Umgebung so weit beherrscht, kann den Aufruf ebenso gut
unterlassen. Für `UV_CACHE_DIR` trug dieser Satz nicht — es genügte **eine
einzige gesetzte Umgebungsvariable**, ohne Kontrolle über Shell oder `PATH`,
und diese Variable hatte die Kette selbst freigegeben. Der Befund richtet sich
also nicht gegen die Reichweite aus 6.5, sondern gegen ihre zu breite
Umsetzung. Nach der Entfernung der drei Variablen bleibt als Weg nur `HOME`
— das `uv` zwingend braucht und unter dem der Zwischenspeicher liegt —, und
für `HOME` trägt der Satz aus 6.5 wieder.

**Was bewusst nicht getan wurde.** Ein fest verdrahteter Zwischenspeicherpfad
wäre gegen `HOME` dicht, tauscht den Weg aber gegen zwei neue Fehler: Ein nicht
beschreibbarer Ort lässt **jeden** `uv`-Schritt als "Lage A — durchgefallen"
enden — genau die Falschaussage, welche die Erweiterung der Positivliste
beseitigen sollte —, und ein Zwischenspeicher im Arbeitsbaum käme unter den
Arbeitsbaumlauf von D11 (6.2.3: `.gitignore` wirkt dort nicht) und damit unter
einen Prüfer, der auf Paketinhalt nicht ausgelegt ist. Der wirksame Abschluss
ist `uv sync --no-cache`: jedes Paket wird neu geladen und dabei gegen die
Sperrdatei geprüft, um den Preis eines vollständigen Ladevorgangs je Lauf und
einer Netzabhängigkeit. Das ist eine Betriebsentscheidung, keine
Architekturentscheidung — **neu als O-13 in Abschnitt 8**.

#### 6.6.2 Die Projektbestimmung konnte still das falsche Repository prüfen

| | |
|---|---|
| **Vorher galt** | Das Projektverzeichnis `PROJ` wurde aus `$(MAKEFILE_LIST)` hergeleitet; scheiterte das (GNU Make trennt die Liste an Leerzeichen), fiel `PROJ` auf das Arbeitsverzeichnis zurück. Eine Wache prüfte, ob dort ein Marker liegt (`CLAUDE.md` oder `.git`) |
| **Jetzt gilt** | Kein Rückfall. `PROJ` wird aus dem **ganzen** Wert von `$(MAKEFILE_LIST)` hergeleitet — die Datei bindet nichts ein, die Liste trägt also genau einen Eintrag, und gespalten hat ihn immer erst `$(firstword)`. Lässt sich der Pfad nicht bestimmen, bricht der Lauf mit einer Erklärung ab |

**Der Beleg.** Die Wache mass, ob am Rückfallort *irgendein* Marker liegt —
nicht, ob es der *richtige* ist. Steht der Aufrufer in einem anderen echten
Arbeitsbaum (zwei Arbeitskopien nebeneinander sind die naheliegende
Arbeitsform, siehe 6.4), trägt der Rückfallort seinen eigenen Marker, die
Wache schweigt, und `make dod` prüft vollständig und unbemerkt das falsche
Repository. Mit zwei Arbeitskopien ausgeführt belegt. Kommt die falsche Kopie
weiter als die gemeinte, ist das ein **falsches Grün für einen Stand, den
niemand angesehen hat** — die Fehlerklasse, gegen die diese Kette gerade
schützen soll.

**Es ist dieselbe Ursache wie in 6.2.2.** Die Wache machte die Lage an einem
**Namen** fest ("hier liegt ein `CLAUDE.md`") statt am **Gegenstand** ("das ist
das Verzeichnis dieses Makefiles"). Die Behebung nimmt den Gegenstand: Der
Pfad, den GNU Make selbst gelesen hat, wird ungeteilt an die Shell gegeben.
Nebenbei ist damit die bisher als "nicht unterstützt" bezeichnete Aufrufart
`make -f '<pfad mit leerzeichen>/Makefile'` aus einem fremden
Arbeitsverzeichnis nicht mehr nur erkannt, sondern richtig aufgelöst.

**Präzisierung nach der Nachprüfung** — die erste Fassung dieses Absatzes
sagte "ausgeführt belegt für sieben Aufrufarten" und war damit zu weit:

- Für die **umbenannte Datei** (`make -f '<verzeichnis>/Projektregeln.mk'`)
  galt das nur für die Herleitung von `PROJ`, nicht für einen vollständigen
  `make dod`. Die Schleife in `dod` ruft jeden Kettenschritt als Unter-Make mit
  `-C "$(PROJ)"` auf; ohne `-f` sucht ein Unter-Make dort die Vorgabenamen
  `Makefile`/`makefile` und brach mit `No rule to make target 'bau'` ab, **bevor
  der erste Kettenschritt lief**. Der Fehler bestand schon vor dieser
  Fortschreibung und fiel sicher ab (Rückgabewert 2, Meldung "nicht nachweisbar
  gelaufen") — kein falsches Grün, aber eine Aufrufart, die nicht lief. Er ist
  in derselben Arbeitseinheit behoben: Der Unter-Make-Aufruf trägt jetzt
  zusätzlich `-f "$(MAKEFILE_NAME)"`, den **Basisnamen** dieser Datei. Der
  Basisname und nicht der Pfad, weil ein relativer `-f`-Pfad nach dem `-C` ein
  anderer wäre. Sieben Aufrufarten laufen jetzt vollständig an (ausgeführt
  belegt: aus dem Verzeichnis selbst, `-f ./Makefile`, `-C` mit und ohne
  Leerzeichen, `-f` mit Leerzeichen, `-f` mit Apostroph, umbenannte Datei mit
  und ohne fremdes Arbeitsverzeichnis).
- Für den **symbolischen Verweis** gilt die Aussage nur für einen Verweis
  *innerhalb* des Projektverzeichnisses. Zeigt ein Verweis von *aussen* auf das
  Makefile des Projekts, wird `PROJ` das Verzeichnis des Verweises — weder
  `dirname` noch `pwd -P` lösen einen Symlink in der letzten Pfadkomponente auf.
  Das ist gewollt: Ein in eine Arbeitskopie gelegter Verweis soll diese
  Arbeitskopie prüfen. Liegt der Verweis dagegen in einem Verzeichnis, das kein
  Projekt ist, greift die zweite Wache und bricht ab.

#### 6.6.3 Was diese Fortschreibung nicht ändert

Die Werkzeugwahl aus 3.12 bleibt unverändert. Kein Kettenschritt wechselt sein
Werkzeug, seine Stellung oder seinen Gegenstand; D1 bis D12, D18 und D19
bleiben im Befehl unberührt. Der Kettengrundsatz aus 6.1.3, die Nummernregel
aus 6.1.2, die beiden Läufe aus 6.1.1, die Objektbestimmung aus 6.2.2, die
Prüffläche aus 6.2.3, `--locked` mit `--project backend` aus 6.3.1 und die
Inhaltsprüfung aus 6.4 bleiben in Kraft. Die Reichweitenentscheidung aus 6.5
bleibt bestehen und wird durch 6.6.1 präzisiert, nicht aufgehoben. Offen
bleiben O-7, O-8, die beiden Restfragen aus O-10, O-11 und O-12; neu
hinzu kommt O-13.


### 6.7 Siebte Fortschreibung vom 2026-08-31 — O-13 entschieden: die Kette benutzt den Zwischenspeicher nicht

**Entscheid des Auftraggebers vom 2026-08-31**, wörtlich: "Das, was korrekt und
qualitativ ist. Soll zwar effizient sein, aber nie an Korrektheit und Qualität
verlieren." Damit ist O-13 in dem Tag entschieden, an dem er entstanden ist,
und zwar zugunsten der Beweiskraft.

| | |
|---|---|
| **Vorher galt** | Nach 6.6.1 blieb ein Restweg: `HOME` muss durchgereicht werden, weil `uv` ohne `HOME` nicht läuft, und der Zwischenspeicher liegt darunter. Wer `HOME` setzen oder in `~/.cache/uv` schreiben konnte, brachte D1 dazu, manipulierten Paketinhalt als "Lage A — bestanden" zu melden |
| **Jetzt gilt** | Jeder `uv`-Aufruf der Kette läuft mit `UV_NO_CACHE=1`. `uv` liest und schreibt den Zwischenspeicher nicht mehr, sondern benutzt ein temporäres Verzeichnis für die Dauer des Aufrufs; jedes Paket wird geladen und dabei gegen `uv.lock` geprüft |

**Weshalb die Umgebungsvariable und nicht der Schalter `--no-cache`.** Beide
wirken gleich (belegt geprüft). Die Variable wirkt aber für **jeden**
`uv`-Aufruf der Kette, auch für die, die erst später hinzukommen — der
Schalter müsste an jeder einzelnen Aufrufstelle stehen und fehlte dann
irgendwann an einer. Das ist dieselbe Überlegung wie bei `--project backend`
in 6.3.1, nur diesmal vorher statt hinterher angestellt.

**Weshalb sie gesetzt und nicht durchgereicht wird.** `$(UV)` beginnt mit
`env -i`: Die Umgebung wird geleert, danach setzt die Kette ihre eigenen
Werte. Eine von aussen mitgebrachte Fassung `UV_NO_CACHE=0` wird dabei
gelöscht und wirkt nicht (ausgeführt geprüft). Das ist der Unterschied
zwischen einer Einstellung und einer Bauvorschrift (5.4): Der Aufrufer kann
sie nicht abschalten.

**Beleg.** Synthetisches `backend/` mit einer echten externen Abhängigkeit,
Zwischenspeicher aufgebaut, das bereits entpackte Archiv manipuliert,
`backend/.venv` gelöscht, `HOME` auf dieses Heimatverzeichnis gerichtet:

- ohne `UV_NO_CACHE`: `::LAGE … D1 bau A_OK::` **mit** manipuliertem Inhalt in
  `backend/.venv` — das falsche Grün, reproduziert;
- mit `UV_NO_CACHE=1`: fünf Läufe hintereinander sauber, auch mit
  `UV_NO_CACHE=0` und mit `UV_CACHE_DIR` von aussen gesetzt.

**Der Preis, benannt und angenommen.** Ein Lauf, der wirklich installiert,
lädt den Abhängigkeitsbaum neu und braucht dafür Netz. Ein Lauf gegen ein
bereits vollständiges Umfeld installiert nichts und lädt deshalb auch nichts
(ausgeführt geprüft). Für eine Kette, deren Ergebnis nach 5.3 ein Nachweis
ist, ist ein wiederholbarer Ladevorgang der kleinere Preis als eine Aussage,
die auf einem Zwischenspeicher beruht, den niemand prüft.

**Folge für Abschnitt 6.5 und 6.6.** Fall 3 der Abgrenzung ist kein offener
Weg mehr. Er bleibt im Kopfabschnitt des Makefiles als Geschichte stehen, weil
er zeigt, was eine zu breite Positivliste anrichtet — und mit dem Satz, der
daraus folgt: **Eine Abgrenzung ist keine Erlaubnis.** Was sich schliessen
lässt, wird geschlossen; abgegrenzt wird nur, was sich im Makefile nicht
schliessen lässt. Fall 1 (`BASH_ENV`) und Fall 2 (gefälschtes `uv` im `PATH`)
bleiben genau das, und für sie bleibt O-12 die Antwort.

### 6.8 Achte Fortschreibung vom 2026-09-01 — der Belegprüfer wird Kettenschritt D20 und läuft als erster

**Anlass.** Der Auftraggeber hat am 2026-09-01 entschieden, den Belegprüfer in
die Definition-of-Done-Kette einzubinden. Ein zusätzlicher Kettenschritt ist
nach diesem Abschnitt eine Fortschreibung und keine stillschweigende Ergänzung;
die Übergabe des Werkzeugs hat die Entscheidung ausdrücklich dem Auftraggeber
vorgelegt statt sie vorwegzunehmen
(`docs/uebergaben/2026-09-01_belegpruefer-abbruch-nach-3-4.md`). Zu entscheiden
sind vier Dinge: die Kennung, die Stelle in der Kette, die Lage-Bedingung und
der Umgang damit, dass das Werkzeug nach Eskalationsregel 3.4 abgebrochen und
**nicht abgenommen** ist.

**Beleglage dieser Fortschreibung — was worauf beruht.** Diese Rolle hat den
Quelltext von `scripts/belege-pruefen.sh` und den Inhalt von
`scripts/belege-ausnahmen.txt` vollständig gelesen; sie hat das Skript **nicht
selbst ausgeführt**. Jede Aussage unten über die *Struktur* des Werkzeugs —
Prüffläche, Rückgabewerte, Zählweise, Ausnahmeformen, Regel für noch nicht
gebaute Bäume, Schlussausgabe — stammt aus dem gelesenen Quelltext und ist dort
nachprüfbar. Jede Aussage über einen *ausgeführten Lauf* — neun eingebaute
Fehlerklassen in drei Runden gefangen, null Funde über den heutigen Bestand bei
30 Ausnahmen, der Lauf verändert nichts, das Umschlagen von null auf 46 Funde
beim Entstehen eines Teilbaums — ist als Fremdbeleg aus der genannten Übergabe
übernommen und hier als solcher gekennzeichnet, nicht als eigene Beobachtung.
Diese Trennung steht hier, weil genau ihre Verletzung — *eine Aussage über die
Herkunft ist stärker, als die Quelle sie trägt* — die Fehlerklasse ist, an der
die vorangegangene Arbeitseinheit dreimal gescheitert ist und gegen die das
Werkzeug gebaut wurde.

#### 6.8.1 Die Kennung — D20

| | |
|---|---|
| **Vorher galt** | Der gemeinsame D-Namensraum führte D1 bis D12 (Kette), D13 bis D17 (menschlich bestätigte Bedingungen), D18 (Architekturverträge) und D19 (Rahmenprüfung) |
| **Jetzt gilt** | Der neue Kettenschritt heisst **D20** |

**Weshalb D20 und keine kleinere Nummer.** Die Nummernregel aus 6.1.2 gilt
unverändert: Nummern sind Kennungen, keine Reihenfolge; es wird nie
umnummeriert und nie wiederverwendet, weil die Nummern in Dokumenten stehen,
die einen vergangenen Stand belegen und deshalb nicht geändert werden dürfen.
D13 bis D17 sind in `docs/06_Definition_of_Ready_und_Done.md`, Teil 2, an die
menschlich bestätigten Bedingungen vergeben, D18 und D19 sind in diesem ADR
vergeben. Die nächste freie Nummer ist damit D20.

**Ein Punkt, der ohne ausdrückliche Entscheidung zu einer zweiten Vergabe
derselben Nummer geführt hätte.** `docs/06_Definition_of_Ready_und_Done.md`
führt D19 heute **noch nicht** — die Nachführung steht in Abschnitt 9 offen.
Wer die Freiheit einer Nummer an dieser Datei ablesen wollte, hielte D19 für
frei und vergäbe sie ein zweites Mal. Deshalb gilt hier ausdrücklich: **Eine
D-Nummer ist vergeben, sobald ein ADR sie vergibt**, nicht erst, wenn die
Nachführung sie erreicht hat. Der gemeinsame Namensraum wird aus der Vereinigung
beider Dokumente gelesen, und bei Abweichung gilt der frühere Vergabezeitpunkt.

#### 6.8.2 Die Stelle in der Kette — als erster Schritt, vor D1

| | |
|---|---|
| **Vorher galt** | `make dod` rief D1 bis D4, dann D18, dann D5 bis D12 auf |
| **Jetzt gilt** | `make dod` ruft **D20**, dann D1 bis D4, dann D18, dann D5 bis D12 auf. D20 ist der erste Schritt der Kette |

Das ist die eigentliche Entscheidung dieser Fortschreibung, und beide
Richtungen hatten ein Argument. Für das Ende sprach: Der Gegenstand von D20 ist
die Dokumentation, nicht die Software; die Kette ist bisher von der billigsten
strukturellen Prüfung zur teuersten geordnet, und ein Dokumentationsbefund darf
nicht wie ein Baufehler wirken. Für den Anfang sprachen vier Punkte, und sie
wiegen zusammen schwerer.

1. **Ein Schritt hinter D7 liefe bis auf Weiteres nie.** Die Kette bricht beim
   ersten Schritt ab, der ungleich 0 endet, und heute ist das D7: Der Backlog
   besteht und führt Abnahmekriterien, `scripts/abnahme-abgleich.sh` fehlt und
   entsteht erst mit dem Grundgerüst — nach der Objekttabelle oben ist das
   Lage C, und Lage C endet ungleich 0. Ein Kettenschritt, der nie läuft, ist
   dasselbe wie die auskommentierte Prüfung, die dieser Abschnitt bereits
   zweimal verworfen hat: *Er bleibt still liegen, nachdem er gebraucht würde.*
   Ein ADR-Eintrag, der ein Jahr lang keine Wirkung hat, ist keine Entscheidung,
   sondern eine Absichtserklärung.
2. **Sein Gegenstand ist der einzige, an dem heute tatsächlich gearbeitet
   wird.** Es besteht kein `backend/`, kein `frontend/`, kein `deploy/`; die
   Bau-, Prüf- und Testschritte finden dafür nach der Objekttabelle oben keinen
   Gegenstand. Was das Repository heute trägt, sind Texte:
   Projektauftrag, Backlog, Definition of Done, Regeln, Rollen, ADR,
   Übergaben. Eine Definition-of-Done-Kette, die über die einzige heute
   vorhandene Artefaktklasse **nichts** aussagt, ist für den heutigen Stand
   keine Kette.
3. **Er ist der billigste Schritt der Kette und hängt von keinem anderen
   ab.** Er braucht kein `uv`, kein `node`, kein `docker`, keinen
   Netzzugang und keinen Bau; nach dem Kopfkommentar des Skripts benutzt er
   `bash`, `git`, `grep`, `sed` und `awk` und kein Python. Damit gilt für ihn
   dieselbe Überlegung wie in 6.1.2 für die Stellung von D18: Ein Verstoss, der
   billig und früh feststellbar ist, soll vor den teuren Schritten fallen und
   nicht nach ihnen.
4. **Am Ende würde er in dem Augenblick scharf, in dem er am meisten
   Schaden anrichtet.** Das Skript behandelt Pfadverweise unter `backend/`,
   `frontend/`, `deploy/` und `prototype/` **nicht** als Fund, solange das
   oberste Verzeichnis fehlt (Regel b im Kopfkommentar, im Quelltext an der
   Prüfung der Pfadverweise umgesetzt); es schaltet sich von selbst scharf,
   sobald das Verzeichnis entsteht. D7 verlässt seine Lage C erst, wenn
   `scripts/abnahme-abgleich.sh` existiert — und dieses Skript entsteht nach
   der begründeten Ausnahme in `scripts/belege-ausnahmen.txt` mit **demselben**
   Grundgerüst wie `backend/`. Ein am Ende eingehängter D20 liefe also zum
   ersten Mal genau in dem Lauf, in dem sich zugleich seine schärfste Regel
   scharf schaltet. Die Übergabe nennt dafür einen ausgeführten Beleg: aus
   null Funden werden in diesem Augenblick 46. Das ist der stille
   Zustandswechsel, den 6.2.2 bei D18 und D10 bereits als Muster verworfen hat
   — *ein Zustandswechsel, den niemand beobachtet*. Vorn eingehängt, läuft der
   Schritt ab heute, wächst mit dem Bestand mit, und der Sprung findet nicht
   statt.

**Der Preis, benannt und angenommen.** Ein Fund in einem Dokument blockiert ab
sofort auch eine Arbeitseinheit, die mit Dokumentation nichts zu tun hat. Das
ist gewollt und nicht bloss hingenommen: Nach 5.3 ist das Ergebnis dieser Kette
ein Nachweis, und ein Nachweis, dessen Verweise ins Leere zeigen, ist als
Nachweis untauglich. Die Rückkopplung bleibt kurz, weil D20 der schnellste
Schritt ist, und jeder Fund ist ortsgebunden: Er ist entweder ein echter Fehler
oder er wird zur Ausnahme mit geschriebenem Grund (6.8.5). Scheitert dieselbe
Prüfung dreimal am gleichen Kriterium, gilt unverändert die Eskalation aus 3.4.

**Nicht entschieden wird hier**, ob D20 später an eine andere Stelle wandert.
Sollte die Kette einmal durchgehend grün laufen, ist die Stellung neu zu
bewerten — als Fortschreibung, nicht nebenbei. Die Kennung bleibt davon
unberührt; die Reihenfolge steht in der Zielliste von `make dod`, nicht in der
Zahl (6.1.2).

#### 6.8.3 Die Lage-Bedingung — und weshalb es für D20 keine Lage B geben kann

Die Objektbestimmung folgt der Regel aus 6.2.2: Der Gegenstand wird als Sache
benannt, das Erkennungsmerkmal als Beobachtung, die Bedingung steht einmal, und
zwar in der Objekttabelle in Abschnitt 6.

| Lage | Für D20 |
|---|---|
| **A** | Es besteht ein Git-Arbeitsbaum mit mindestens einer versionierten Markdown-Datei in der Prüffläche, und alle Prüfmittel sind vorhanden. Der Schritt urteilt: 0 oder ungleich 0 |
| **B** | **Gibt es nicht.** Siehe unten |
| **C** | Der Bestand besteht, aber ein Prüfmittel fehlt: kein `git` oder kein Git-Arbeitsbaum, `scripts/belege-pruefen.sh` oder `scripts/belege-ausnahmen.txt` fehlt oder ist nicht lesbar, oder eines der beiden Bezugsdokumente `docs/05_Product_Backlog.md` und `docs/00_Projektauftrag.md` fehlt. Rückgabewert ungleich 0 |

*Berichtigt mit der elften Fortschreibung (ADR 0002, Abschnitt 6.11):* Diese
Tabelle und der übrige Text von 6.8.3 sowie 6.8.4 kannten an dieser Stelle bis
dahin nur die Rückgabewerte 0 und 2 des Belegprüfers und behandelten damit
„das Prüfmittel selbst ist ausgefallen" als denselben Fall wie „am Bestand
wurde etwas gefunden". Seit der elften Fortschreibung unterscheidet das
Werkzeug selbst: Rückgabewert 2 heisst mindestens ein Befund, Rückgabewert 3
heisst Lage C. Beide sind „ungleich 0" im Sinn dieser Tabelle; Einzelheiten
in 6.11.2.

**Weshalb es keine Lage B geben kann — zwei voneinander unabhängige Gründe.**

1. **Der Bestand kann nicht leer sein.** Die Prüffläche umfasst die
   versionierten Markdown-Dateien der Wurzel, unter `docs/` und unter
   `.claude/`. `CLAUDE.md` und `docs/00_Projektauftrag.md` liegen darin und
   sind nach CLAUDE.md die verbindliche Grundlage des Projekts; ein Repository
   ohne sie ist nicht dieses Repository. Das ist dieselbe Begründung, mit der
   die dritte Fortschreibung vom 2026-08-30 (6.3.2) für D7 die Lage B
   gestrichen hat: Ein Gegenstand, der seit einer
   Freigabe dauerhaft besteht, wird nicht sinnvoll als "nicht vorhanden"
   behandelt — sein Fehlen ist ein Befund.
2. **Das Werkzeug könnte "leer" und "sauber" gar nicht unterscheiden.** Nach
   dem gelesenen Quelltext zählt das Skript Funde und endet bei null Funden mit
   Rückgabewert 0. Ein leerer Bestand ergibt ebenfalls null Funde. Die
   Unterscheidung zwischen *nichts gefunden* und *nichts geprüft* kann das
   Skript also nicht treffen — sie gehört deshalb in die Lage-Bestimmung des
   Kettenschritts und nicht in das Skript. Eine Lage B einzurichten hiesse,
   einen grünen Schritt zu erlauben, der über nichts geurteilt hat; das ist
   genau der Ausgang, den Regel 4 aus 6.2.2 untersagt.

**Weshalb ein fehlender Git-Arbeitsbaum Lage C ergibt und nicht Lage B.** Bei
D11 und D19 ist der Gegenstand selbst das Repository; ohne Repository gibt es
dort nichts zu beurteilen, also Lage B. Bei D20 ist der Gegenstand die
**Dokumentation**; sie besteht als Dateien unabhängig davon, ob eine
Versionsverwaltung läuft. `git` ist hier nur das Mittel, mit dem der Bestand
abgegrenzt wird. Fehlt es, besteht der Gegenstand fort und die Prüfung fällt
aus — das ist die Definition von Lage C. Der gelesene Quelltext verhält sich
bereits so: Findet das Skript am Arbeitsverzeichnis kein Git-Repository, endet
es mit einer Meldung und Rückgabewert 2 statt mit 0.

**Die beiden Bezugsdokumente sind Prüfmittel, nicht Beiwerk.** Das Skript
bildet seine Referenzmengen aus den Überschriften von
`docs/05_Product_Backlog.md` (gültige Anforderungskennungen) und
`docs/00_Projektauftrag.md` (gültige Abschnittsnummern). Fehlt eines davon,
bleibt die zugehörige Referenzmenge leer, und **jede** geprüfte Kennung
beziehungsweise Abschnittsangabe im ganzen Bestand wird zum Fund. Der Schritt
wäre dann zwar rot, aber mit einer falschen Begründung — hunderte Scheinfunde
statt der einen richtigen Aussage "das Prüfmittel fehlt". Deshalb stehen beide
Dateien in der Prüfmittelspalte: Lage C sagt, was los ist.

**Der zweite Arbeitsbaum ist kein Prüfmittel im Sinne von Lage C.** Das Skript
liest das Methodik-Repository an einem fest verdrahteten Ort ausserhalb dieses
Repositories mit, für Commit-Prüfsummen und für Pfade unter `methodik/`,
`nachweise/` und `sprints/`. Fehlt dieser Arbeitsbaum, zählt es die betroffenen
Zeilen nach dem gelesenen Quelltext als **nicht prüfbar**; diese Zählung geht
nicht in den Rückgabewert ein. Entschieden wird: Das ergibt **keine** Lage C —
der Schritt urteilt weiterhin über seinen eigenen Bestand, und ein Mitlesen,
das nur an einem Arbeitsplatz möglich ist, darf die Kette nicht an diesen
Arbeitsplatz binden. Aber nach Regel 4 aus 6.2.2 gilt: **Die Zahl der nicht
prüfbaren Zeilen gehört in die Lage-Meldung des Schrittes.** Ein Lauf, der
weniger prüfen konnte, muss von einem unterscheidbar sein, der alles geprüft
hat. Dass der Ort fest verdrahtet und nicht konfigurierbar ist, macht die
Aussage des Schrittes maschinenabhängig; das ist keine Architekturfrage, aber
es darf nicht unbemerkt bleiben und ist deshalb als **O-14** terminiert.

#### 6.8.4 Was ein grüner D20 aussagt — und was nicht

Dies ist der architektonisch erhebliche Teil. Das Werkzeug ist nach
Eskalationsregel 3.4 abgebrochen: Dreimal in Folge hat eine unabhängige Prüfung
eine reale Grenze gefunden, die in seiner Selbstauskunft fehlte, und jedes Mal
in der Schicht, welche die vorangegangene Behebung erst erreichbar gemacht
hatte. Die abgelieferte Fassung behauptet deshalb nicht mehr, die Liste ihrer
Grenzen sei vollständig; ihre Schlussausgabe sagt das ausdrücklich und schliesst
nach dem gelesenen Quelltext mit dem Satz, dass Rückgabewert 0 heisse, nichts
von dem gefunden zu haben, was dort aufgezählt ist — nicht, dass nichts
vorhanden sei.

**Was ein grüner D20 aussagt.** Kein Verweis der geprüften Klassen — Zeile,
Commit-Prüfsumme, Anforderungskennung, Pfad, Abschnitt des Projektauftrags,
Zweigform statt Commit-Prüfsumme — zeigt in der Prüffläche auf etwas, das es
nicht gibt, soweit die eingebauten Prüfungen reichen; und die Ausnahmeliste ist
formgerecht, begründet und nicht veraltet.

**Was ein grüner D20 nicht aussagt.** Erstens und vor allem nicht, dass der
Inhalt am genannten Fundort die Behauptung trägt, die ihm zugeschrieben wird —
das bleibt Sache des menschlichen Reviews, und das Skript sagt es selbst.
Zweitens nicht, dass alle Verweisformen erfasst sind: Pfade ausserhalb von
Rückwärtsakzenten und im Pfadteil von Shell-Befehlen werden nicht erfasst, das
Muster Inhaber/Repository nimmt auch echte künftige Zwei-Segment-Pfade aus, bei
der Abschnittsprüfung gilt eine Tabelle ohne Leerzeile als ein Absatz, und zwei
vorgesehene Prüfungen — Skill-Zuordnung im Rollen-Frontmatter und
Anforderungskennung im Skill-Frontmatter — sind nicht gebaut. Drittens und
entscheidend: **nicht, dass diese Aufzählung vollständig ist.**

*Berichtigt mit der elften Fortschreibung (ADR 0002, Abschnitt 6.11):* Bis
dahin kannte auch dieser Abschnitt für den Belegprüfer nur die Rückgabewerte
0 und 2 und behandelte „das Prüfmittel selbst ist ausgefallen" als denselben
Fall wie „am Bestand wurde etwas gefunden". Seit der genannten Fortschreibung
meldet das Werkzeug diesen Unterschied selbst, über einen dritten
Rückgabewert; Einzelheiten in 6.11.2.

**Schadet das der Kette oder tut es ihr gut? Es tut ihr gut, aus drei
Gründen.**

1. **Der Zusatz ist einseitig.** D20 teilt mit keinem anderen Schritt einen
   Gegenstand und kein Prüfmittel, und er kann nach dem gelesenen Quelltext
   nichts unterdrücken, was ein anderer Schritt meldet — er schreibt nichts,
   jede Ausgabe geht auf die Standard- oder die Fehlerausgabe, und die
   Übergabe belegt zusätzlich mit einem ausgeführten Lauf, dass er in keinem
   der beiden Arbeitsbäume etwas verändert. Für eine Zusicherung genügt das
   ohnehin nicht: Die Einhaltung des Kettengrundsatzes ist bei D20 wie bei
   jedem anderen Schritt **beobachtet**, nämlich durch D19. Ein Schritt, der
   nur Funde hinzufügen kann, macht die Aussage der Kette nie schwächer, als
   sie ohne ihn wäre. Ihn wegzulassen wäre nicht die vorsichtigere Wahl, es
   wäre die schwächere.
2. **Ein grüner Kettenschritt ist ohnehin nie eine positive Aussage.** `ruff
   format --check` sagt nicht, dass der Code gut entworfen ist; `pip-audit`
   sagt nicht, dass keine Schwachstelle besteht, sondern dass keine in der
   verwendeten Datenbank steht; `gitleaks` sagt nicht, dass kein Geheimnis
   vorliegt, sondern dass keines seinen Mustern entsprach. **Jeder** Schritt
   dieser Kette ist eine Negativaussage über den eigenen Suchraum. D20 sagt
   damit nichts Schwächeres als die übrigen — er ist der einzige, dessen
   Werkzeug es laut sagt. Daraus folgt kein Ausschluss, sondern ein
   Kettengrundsatz, der ab hier für alle Schritte gilt:

   > **Rückgabewert 0 eines Kettenschritts heisst: nichts von dem gefunden,
   > was dieser Schritt sucht. Er heisst nie: nichts vorhanden.** Ein grünes
   > `make dod` ist der Nachweis, dass die Kette gelaufen ist und nichts
   > gefunden hat — nicht der Nachweis, dass die Arbeit richtig ist. Die
   > menschlich bestätigten Bedingungen D13 bis D17 stehen genau deshalb
   > daneben und werden durch keinen grünen Lauf ersetzt.

   Dieser Grundsatz ändert an keinem Schritt das Verhalten. Er ändert, was die
   Kette zu behaupten beansprucht — und das ist bei einem Artefakt, dessen
   Ergebnis nach 5.3 ein Nachweis ist, kein Nebenpunkt.
3. **Die gefährliche Richtung ist abgedeckt.** Ein Kettenschritt kann falsch
   grün oder falsch rot sein. Falsch rot ist sichtbar, ortsgebunden behandelbar
   und unterliegt der Eskalation aus 3.4. Falsch grün ist die gefährliche
   Richtung — aber ohne D20 ist die Kette in dieser Dimension **immer** falsch
   grün, weil sie überhaupt nicht hinsieht. Ein Werkzeug, das einen Teil findet
   und den Rest nicht behauptet, ist jeder Lage überlegen, in der niemand
   sucht.

**Zwei Bedingungen, unter denen das gilt.**

- **D20 ist blockierend, nicht meldend.** Die naheliegende Milderung — der
  Schritt warnt, blockiert aber nicht, weil das Werkzeug nicht abgenommen ist —
  ist in diesem ADR bereits entschieden, und zwar gegen sie: 6.2.3 verwirft die
  Abstufung mit der Begründung, eine Meldung, die nicht blockiert, werde in
  einem Stop-Hook nicht gelesen, und eine abgestufte Wirkung sei eine
  Abschaltung mit besserem Namen (5.4). Für D20 gilt dasselbe. Wer dem Werkzeug
  nicht genug traut, um es blockieren zu lassen, nimmt es nicht in die Kette
  auf; ein sichtbar wirkungsloser Schritt ist die schlechteste der drei
  Möglichkeiten.
- **D20 belegt nichts, was ein anderer Schritt zu belegen hat.** Er prüft, dass
  eine Anforderungskennung als Überschrift im Backlog steht. Er sagt damit
  **nicht**, dass zu dieser Anforderung ein Test existiert — das ist die Aussage
  von D7 — und nicht, dass das Nachweisverzeichnis stimmt — das ist D12. Die
  Aussagen werden nicht vermischt, und ein grüner D20 ersetzt keinen der beiden.

**Die fehlende Abnahme wird nicht durch diese Fortschreibung geheilt.** Sie ist
als **O-15** terminiert: Ein Werkzeug, das eine Nachweiskette blockiert,
braucht eine Abnahme durch Static und Dynamic Software Tester auf einem anderen
Modell als die Umsetzung (3.4). Die Aufnahme in die Kette hängt nicht daran —
ein nicht abgenommenes Werkzeug, das Funde meldet und nichts darüber hinaus
behauptet, ist besser als kein Werkzeug —, aber der Zustand wird geführt und
nicht vergessen. Bis zur Abnahme gilt der Satz aus der Übergabe unverändert:
Was das Skript findet, ist unabhängig belegt; was es über sich selbst sagt, ist
es nicht.

#### 6.8.5 Die Ausnahmeliste ist Teil des Prüfmittels, nicht seine Umgehung

`scripts/belege-ausnahmen.txt` entscheidet, was ein Fund ist und was nicht. Sie
ist damit die einzige Stelle, an der sich D20 abschalten liesse, und deshalb
ein architektonischer Gegenstand.

**Was im ADR steht und was nicht.** Entschieden wird: Die **Regeln** der Liste
gehören in diesen ADR, die **Einträge** nicht. Die Einträge sind ein Inventar
des Bestandes; sie ändern sich mit jedem Dokument. Eine Liste, die
wöchentlich wechselt, in einem ADR zu führen, machte den ADR zum
Pflegegegenstand und seine Fortschreibungen bedeutungslos — dieselbe
Überlegung, mit der Abschnitt 2 keine Versionsnummern nennt. Die Liste liegt
versioniert neben dem Skript und wird dort gelesen.

**Vier Eigenschaften, die dieser ADR festlegt.** Sie sind im gelesenen
Quelltext bereits umgesetzt; sie stehen hier, weil sie sonst durch eine
Änderung am Skript stillschweigend wegfallen könnten.

1. **Jeder Schlüssel ist ortsgebunden.** Zulässig sind genau zwei Formen: die
   Bindung an einen Fundort aus Datei und Zeilennummer und die Bindung an einen
   Wert innerhalb einer bestimmten Datei. Eine dritte Form gibt es nicht; ein
   blosser Wert ohne Datei ist selbst ein Befund. Grund: Eine wertgebundene
   Ausnahme unterdrückt jedes künftige Vorkommen desselben Wortlauts im ganzen
   Bestand — auch einen echten neuen Fehler. Damit wäre die Fehlerklasse, gegen
   die das Werkzeug gebaut ist, in das Werkzeug selbst gewandert: eine Ausnahme
   mit richtigem historischem Grund würde zur Aussage über alle künftigen
   Vorkommen.
2. **Jeder Eintrag trägt einen geschriebenen Grund.** Ein Eintrag ohne Grund ist
   ein Befund. Eine Ausnahme ohne Begründung ist eine Lücke mit Deckmantel.
3. **Ein Eintrag, dessen Gegenstand entstanden ist, ist ein Befund.** Sonst
   deckt die Zeile beim nächsten Mal etwas Echtes zu. Die benannte Grenze dieses
   Rückgleichs — Schlüssel der Fundortform und nicht pfadförmige Werte werden
   nicht zurückgeglichen — bleibt eine benannte Grenze und wird nicht durch eine
   Neuformulierung überdeckt; die dritte Prüfrunde ist genau daran gescheitert,
   und die Behebung war eine Streichung, weil eine Streichung keinen neuen
   Fehlalarm einführen kann.
4. **Die Liste wird geschrieben, nicht abgeleitet.** Sie wird nicht zur Laufzeit
   erzeugt und nicht aus `.gitignore` oder einer anderen Quelle abgeleitet. Das
   ist derselbe Massstab wie in 6.2.3 für den Ausschluss bei D11: namentlich
   aufgezählt und versioniert abgelegt. Sie ist damit ausdrücklich **kein**
   erzeugtes Artefakt und fällt nicht unter die Regel für `docs/NACHWEISE.md`
   und den Ordner der Nachweise, die von Hand nie bearbeitet werden.

**Wer sie pflegen darf.** Auch das ist bereits entschieden, für die
Ausnahmeliste von D11 in 6.2.3, und wird übernommen statt neu erfunden: Eine
Ausnahme entsteht ausschliesslich zu einem **belegten** Fehlalarm, je Eintrag
mit Fundstelle und Begründung; eine pauschale Ausnahme ist unzulässig, weil sie
das Gate stillschweigend abschaltet. Daraus folgt für D20:

| Vorgang | Wer | Bedingung |
|---|---|---|
| Einen ortsgebundenen Eintrag hinzufügen oder entfernen | Die Rolle, deren Dokument den Fund ausgelöst hat | Nur zu einem belegten Fehlalarm, mit Fundstelle und geschriebenem Grund, der die **Tatsache** nennt und nicht die Absicht. Der Eintrag unterliegt der Verifikation wie jede andere Änderung; die schreibende Rolle prüft ihn nicht selbst (3.4) |
| Eine ganze Fallgruppe von der Prüfung ausnehmen | Niemand über die Ausnahmeliste | Das ist keine Ausnahme, sondern eine Änderung der Prüfung. Sie geht über eine Fortschreibung dieses ADR und eine Änderung am Skript, nicht über eine Zeile in der Liste |
| Die Form der Schlüssel, die beiden Selbstprüfungen oder die Prüffläche ändern | Software Architect, als Fortschreibung dieses ADR | Es sind die vier Eigenschaften oben |

**Die Grenze zwischen Ausnahme und Regel ist die tragende Unterscheidung.** Ein
Eintrag in der Liste sagt: *An dieser einen Stelle ist der Fund kein Fehler.*
Eine neue Regel im Skript sagt: *Diese Art von Stelle wird nicht mehr geprüft.*
Das Zweite ist eine Architekturentscheidung und darf nicht die Form des Ersten
annehmen. Genau diese Verwechslung — eine ortsungebundene Ausnahme, die
faktisch eine Regel war — ist der Befund der ersten der drei gescheiterten
Prüfrunden.

#### 6.8.6 Was diese Fortschreibung nicht ändert

D1 bis D12, D18 und D19 bleiben in Befehl, Objektbedingung und Prüfmitteln
unverändert; hinzu kommt allein D20 und seine Stellung vor D1. Die
Werkzeugwahl aus 3.12 bleibt unverändert — D20 ist kein Teststack, sondern eine
Prüfung über den Dokumentationsbestand. Der Kettengrundsatz aus 6.1.3 und seine
Beobachtung durch D19 aus 6.2.2 gelten für D20 unverändert und ohne Ausnahme.
Die Nummernregel aus 6.1.2 bleibt in Kraft und wird um den Satz ergänzt, dass
eine Nummer mit ihrer Vergabe in einem ADR vergeben ist (6.8.1). Die offenen
Schwellenwerte (O-7), die offenen Formfragen zu D10 und D12 (O-8), die
Restfragen aus O-10 und der Lauf auf der Gegenseite (O-12) bleiben offen. Der
Befund zum untauglichen Abgleich über einen Verzeichnisvergleich in D12 bleibt
bestehen. Nicht entschieden wird die Abnahme des Werkzeugs (O-15) und nicht der
fest verdrahtete Ort des zweiten Arbeitsbaums (O-14); beides ist terminiert,
nicht erledigt. Diese Fortschreibung legt keine Datei an ausser dieser: Die
Umsetzung im Makefile und die Nachführung von
`docs/06_Definition_of_Ready_und_Done.md` stehen in Abschnitt 9 und liegen bei
anderen Rollen.

### 6.9 Neunte Fortschreibung vom 2026-09-01 — die Beobachtbarkeit des Index gehört zum Prüfmittel von D19

**Anlass.** Der Requirements Engineer hat beim Nachtragen von D19 und D20 in
`docs/06_Definition_of_Ready_und_Done.md` gemeldet, dass das Prüfmittel von D19
an zwei Stellen verschieden steht, und hat den Befund ausdrücklich **nicht**
selbst gelöst. Das ist der vorgesehene Weg (CLAUDE.md: Abweichungen von diesem
ADR nur als Fortschreibung) und dasselbe Vorgehen, das schon der dritten
Fortschreibung vom 2026-08-30 zugrunde lag: melden statt stillschweigend
entscheiden.

**Beleglage dieser Fortschreibung.** Wie in 6.8 wird getrennt, worauf welche
Aussage beruht. Diese Rolle hat den D19-Teil des Ziels `dod` im Makefile
gelesen; sie hat **nichts ausgeführt**. Aussagen über den *Aufbau* der Umsetzung
— welche Grössen vor und nach dem Lauf erhoben werden, welcher Vergleich zu
welchem Ausgang führt, dass der Rückgabewert nur von 0 auf ungleich 0 angehoben
wird — stammen aus dem gelesenen Quelltext. Die Aussage, dass sich die
Beobachtung durch `git update-index --assume-unchanged` beziehungsweise
`--skip-worktree` tatsächlich abschalten lässt, ist **nicht** eigene
Beobachtung: Der Kommentar E5 an der betreffenden Stelle des Makefiles führt
dafür einen ausgeführten Beleg an, und diese Fortschreibung übernimmt ihn als
Fremdbeleg. Was dieser Beleg **nicht** abdeckt, ist in 6.9.4 als offener Punkt
festgehalten, statt es zu vermuten.

#### 6.9.1 Der Befund

| | |
|---|---|
| **Vorher galt** | Als Mittel von D19 nannten die Tabelle in Abschnitt 6 und die vierte Fortschreibung (6.4) die Statusliste `git status --porcelain --untracked-files=all` und eine Inhaltsprüfsumme je verfolgter Datei. Von den Maskierungsmerkmalen des Index stand in diesem ADR nichts |
| **Jetzt gilt** | Die Beobachtbarkeit des Index ist zweiter Teil des Prüfmittels: Der Bestand der Merkmale `assume-unchanged` und `skip-worktree` wird vor und nach dem Lauf erhoben. Ein gesetztes Merkmal ergibt Lage C mit eigenem Befundtext |

Die Umsetzung war der Festlegung also voraus. Das ist die unangenehmere der
beiden Richtungen — eine Umsetzung, die weniger tut als der ADR, ist ein
gewöhnlicher Mangel; eine, die mehr tut, ist eine Entscheidung, die niemand
getroffen hat. Beide Male gilt derselbe Satz aus 6.3: Der Befund wird
entschieden, nicht angeglichen.

**Zwei Wege standen offen.** Entweder die Beobachtung aus dem Makefile
entfernen, weil sie dort nichts zu suchen hat, oder sie in das Prüfmittel
aufnehmen. Entschieden wird: **aufnehmen.**

**Weshalb aufnehmen und nicht entfernen.** D19 sagt: Der Bestand der
versionierten Dateien ist vor und nach dem Lauf derselbe. Diese Aussage ruht auf
einem Messmittel, und ein Teil dieses Messmittels — `git status` — richtet sich
nach dem Index. Ein Kettenschritt, der ein Maskierungsmerkmal setzt, verändert
damit nicht den Gegenstand, sondern **das Messmittel**. Das Ergebnis wäre nicht
ein falsches Urteil, sondern ein Urteil ohne Grundlage: D19 meldete "unverändert"
über eine Datei, die es nicht mehr ansehen kann. Genau diese Falschaussage ist
der Grund, aus dem D19 überhaupt existiert — die zweite Fortschreibung hat sie
mit dem Satz eingeführt, beobachtbar genüge nicht, beobachtet werde verlangt.
Eine Beobachtung zu entfernen, die feststellt, ob überhaupt noch beobachtet
werden kann, hiesse, diesen Satz zurückzunehmen.

**Einordnung in das Muster.** Es ist zum dritten Mal derselbe Fehler auf einer
neuen Ebene. Die Schlussprüfung vom 2026-08-30 hat ihn benannt: *gemessen wird
die Verfügbarkeit eines Namens statt die Anwesenheit des Gegenstands.* 6.4 hat
ihn eine Ebene höher geschlossen: die Statusliste misst eine Liste von Namen
statt den Inhalt. Diese Fortschreibung schliesst ihn eine Ebene darüber: **Es
genügt nicht, den Gegenstand zu messen; es muss auch feststehen, dass das
Messmittel misst.** Damit ist die Reihe an ihrem Ende angelangt — was das
Messmittel des Messmittels prüft, ist keine Eigenschaft der Kette mehr, sondern
der Lauf auf der Gegenseite aus O-12.

#### 6.9.2 Der Ausgang "nicht beobachtbar" ist Lage C — und Lage C wird dafür geschärft

Der gemeldete Punkt trifft zu: Der Ausgang war bisher keine der drei Lagen. Das
ist selbst eine Festlegung, und sie wird hier getroffen.

**Optionen.**

| Option | Bewertung |
|---|---|
| (a) Eine vierte Lage D "Gegenstand vorhanden, Prüfmittel vorhanden, aber stummgeschaltet" | Beschreibt den Fall genau. Dagegen: Das Lagenschema gilt für **alle** Kettenschritte; eine vierte Lage müsste für jeden von ihnen bestimmt werden, obwohl sie nur bei D19 auftritt. Ein Schema um eines Einzelfalls willen zu erweitern, macht es für die anderen fünfzehn Fälle ungenauer |
| (b) Unter Lage C fassen und Lage C schärfen | Der Ausgang ist bereits derselbe: ungleich 0, kein bestandener Schritt. Der tragende Satz von Lage C — ein Schritt, der nicht urteilen kann, meldet nicht "bestanden" — passt wörtlich. Verlangt eine Präzisierung der C-Bedingung, die ohnehin fällig ist |
| (c) Als Verletzung des Kettengrundsatzes behandeln (wie eine Abweichung des Bestandes) | Abgelehnt. Das behauptete, der Arbeitsbaum sei verändert worden. Bekannt ist aber gerade das Gegenteil: Es ist **nicht bekannt**, ob er verändert wurde. Ein Nachweis, der Ungewissheit als Feststellung ausgibt, ist als Nachweis untauglich (5.3) — dieselbe Begründung, mit der die Schlusszeile schon einmal getrennt werden musste |
| (d) Nur melden, nicht blockieren | Abgelehnt, aus dem in 6.2.3 bereits entschiedenen Grund: Eine Meldung, die nicht blockiert, wird in einem Stop-Hook nicht gelesen; eine abgestufte Wirkung ist eine Abschaltung mit besserem Namen (5.4) |

**Entscheid: (b).** Lage C lautet neu — Gegenstand vorhanden, Prüfmittel fehlt
**oder trägt die Aussage nicht**: es ist unlesbar, unbrauchbar oder
stummgeschaltet. Der Ausgang bleibt unverändert ungleich 0.

**Weshalb das keine Ausweitung, sondern eine Klarstellung ist.** Die Umsetzung
behandelt einen vorhandenen, aber unbrauchbaren Prüfgegenstand schon heute als
Lage C, und dieser ADR trägt es an zwei Stellen mit: D18 meldet Lage C, wenn
`backend/importvertraege.toml` zwar existiert, aber nicht lesbar ist, und D7
endet nach 6.3.2 ungleich 0, wenn die gefundene Backlog-Datei keine
Abnahmekriterien führt — in beiden Fällen ist das Prüfmittel da und trägt die
Aussage nicht. Die C-Bedingung war also bereits weiter, als ihr Wortlaut sagte.
Diese Fortschreibung bringt den Wortlaut auf den Stand der bereits getroffenen
Entscheidungen, statt eine neue Freiheit zu schaffen.

**Der eigene Befundtext bleibt.** Lage C ist die Lage, nicht die Meldung. Ein
Lauf muss unterscheidbar machen, **welcher** C-Fall eingetreten ist — `git`
fehlt, oder `git` ist da und der Index ist maskiert. Das Makefile trennt beide
Texte bereits, und der Grund steht dort ausdrücklich als Anmerkung zur
Nachweiszeile nach 5.3: Eine Schlusszeile, die "beobachtet und in Ordnung" mit
"gar nicht beobachtet" verschmilzt, ist als Nachweis untauglich. Dieselbe
Trennung gilt jetzt auch begrifflich.

**Der absolute Massstab für das Instrument, und weshalb er dem Massstab für den
Gegenstand nicht widerspricht.** Für den Gegenstand gilt seit der zweiten
Fortschreibung: vorher gegen nachher, nicht gegen einen sauberen Arbeitsbaum —
ein bereits veränderter Arbeitsbaum ist zulässig. Für das Instrument gilt das
**nicht**: Ein Maskierungsmerkmal, das schon vor dem Lauf gesetzt war, ist
ebenso ein Befund wie eines, das während des Laufs gesetzt wurde. Der
Unterschied hat einen Grund, und es ist nicht Strenge um ihrer selbst willen:
Ein veränderter Arbeitsbaum ist der normale Betriebszustand vor einem Commit
und beeinträchtigt die Messung nicht. Ein maskierter Index beeinträchtigt sie
für die ganze Dauer des Laufs — die Vorher-Aufnahme ist dann bereits blind, und
ein Vergleich zweier blinder Aufnahmen ergibt zuverlässig "keine Abweichung".
Das ist dieselbe Unterscheidung, die 6.2.3 für D11 getroffen hat: Ein Fund im
Arbeitsbaum ist immer ein Befund und nie ein Betriebszustand. **Der Gegenstand
wird relativ gemessen, das Instrument absolut verlangt.**

#### 6.9.3 Ein zweiter, kleinerer Unterschied derselben Art in derselben Zeile

Beim Lesen des D19-Teils ist ein zweiter Punkt aufgefallen, den der gemeldete
Befund nicht nennt; er wird hier mitentschieden, weil er dieselbe Tabellenzeile
betrifft und dieselbe Ursache hat.

| | |
|---|---|
| **Vorher galt** | Die Objekttabelle nannte als Erkennungsmerkmal von D19 "`.git/` vorhanden" — ein Verzeichnisname |
| **Jetzt gilt** | Erkennungsmerkmal ist, dass die Versionsverwaltung einen Arbeitsbaum meldet; ist `git` nicht ausführbar, hilfsweise die Anwesenheit von `.git` als **Datei oder** Verzeichnis |

Der Grund steht als Anmerkung B2 im Makefile und ist dort als blockierender
Befund der Schlussprüfung vom 2026-08-30 vermerkt: In einem zusätzlichen
Arbeitsbaum und in einem Untermodul ist `.git` eine **Datei**, kein Verzeichnis.
Eine Prüfung auf ein Verzeichnis meldete dort Lage B und beobachtete nichts,
obwohl der Baum voll versioniert war — und der Betrieb auf einem Arbeitszweig
nach CLAUDE.md macht zusätzliche Arbeitsbäume zu einer naheliegenden
Arbeitsform. Das ist wörtlich Regel 1 aus 6.2.2: Die Lage wird an einem
Pfadnamen festgemacht statt am Gegenstand. Die Umsetzung hatte den Fehler
bereits behoben; nur die Tabelle, die nach Regel 2 allein massgeblich ist, trug
ihn noch.

#### 6.9.4 Was diese Fortschreibung offenlässt — O-16

Nicht entschieden, weil nicht ohne einen ausgeführten Lauf entscheidbar: **wie
weit die Maskierungsmerkmale die Messung tatsächlich beeinträchtigen.** Das
Instrument hat zwei Teile. Die Statusliste richtet sich nach dem Index; für sie
ist die Beeinträchtigung belegt. Die Inhaltsprüfsumme je verfolgter Datei liest
dagegen den Dateiinhalt über den Pfad. Ob sie eine Änderung an einer maskierten
Datei weiterhin erfasst — und damit, ob die Maskierung D19 halb oder ganz blind
macht —, ist eine Frage über das Verhalten eines Werkzeugs und wird hier
**nicht behauptet**, in keine der beiden Richtungen. Sie ist als **O-16**
terminiert und mit einem ausgeführten Lauf zu beantworten.

**Am Entscheid ändert die Antwort nichts, und das ist Absicht.** Fällt sie so
aus, dass die Prüfsumme weiterhin greift, bleibt die Maskierung trotzdem ein
Befund: Ein Instrument, dessen eine Hälfte stummgeschaltet ist, trägt die
Aussage von D19 nicht mehr vollständig, und die Kette soll nicht auf der
stillschweigenden Annahme beruhen, die andere Hälfte fange es schon auf. Die
Antwort bestimmt also nicht, **ob** gemeldet wird, sondern **wie genau** die
Befundmeldung sagen darf, was ungewiss geworden ist. Genau deshalb steht sie als
offener Punkt und nicht als Vermutung im Entscheid.

#### 6.9.5 Was diese Fortschreibung nicht ändert

Der Gegenstand von D19 bleibt unverändert der Bestand der versionierten Dateien
über die Dauer eines Laufs; die Aufnahme aus Statusliste und Inhaltsprüfsumme
aus 6.4 bleibt unverändert und wird ergänzt, nicht ersetzt. D19 bleibt
Rahmenprüfung ohne eigenes `make`-Ziel und ohne Platz in der Zielliste. Die
Eigenschaft "kann einen grünen Lauf rot machen, nie einen roten grün" bleibt.
Kein Kettenschritt D1 bis D12, D18 oder D20 ändert sich in Befehl,
Objektbedingung oder Prüfmitteln; die Schärfung von Lage C beschreibt für sie,
was bei D7 und D18 ohnehin schon galt. Der Kettengrundsatz aus 6.1.3, die
Nummernregel aus 6.1.2 und der Grundsatz aus 6.8.4 zur Aussagekraft eines
Rückgabewerts 0 bleiben in Kraft. Die offenen Punkte O-7, O-8, O-10, O-12, O-14
und O-15 bleiben offen. Nicht entschieden wird O-16.

**Erledigt und hier nur vermerkt:** Die in 6.8.1 festgestellte
Nachführungslücke — `docs/06_Definition_of_Ready_und_Done.md` führte D19 nicht,
weshalb die Nummer dort als frei erschien — ist geschlossen; D19 und D20 stehen
jetzt dort. Der Satz aus 6.8.1 bleibt als Regel bestehen: Eine D-Nummer ist
vergeben, sobald ein ADR sie vergibt.

### 6.10 Zehnte Fortschreibung vom 2026-09-01 — O-16 beantwortet: eine Hälfte des Instruments ist stumm, nicht beide

**Anlass.** O-16 ist am selben Tag beantwortet worden, an dem er entstanden ist,
und zwar mit dem Mittel, das dieser ADR dafür verlangt: einem ausgeführten Lauf
statt einer Vermutung. 6.9.4 hatte die Frage ausdrücklich in keine Richtung
behauptet. Sie ist jetzt gemessen.

**Beleglage — Fremdbeleg, kein eigener Lauf.** Die Zahlen unten stammen aus
einem Lauf des Koordinators, nicht aus einer eigenen Beobachtung dieser Rolle;
diese Rolle hat auch für diese Fortschreibung nichts ausgeführt. Übernommen wird
das Ergebnis als Fremdbeleg mit Angabe des Versuchsaufbaus, damit nachprüfbar
ist, was gemessen wurde — und, ebenso wichtig, was nicht.

#### 6.10.1 Das Messergebnis

**Versuchsaufbau** (Fremdbeleg): Wegwerf-Klon des Repositories,
`git update-index --skip-worktree CLAUDE.md`, danach eine Zeile an die Datei
angehängt; beide Hälften des Instruments jeweils vorher und nachher aufgenommen.

| Instrumententeil | vorher | nachher | Ergebnis |
|---|---|---|---|
| Statusliste (`git status --porcelain --untracked-files=all`) | 0 Zeilen | 0 Zeilen | **blind** — meldet die Änderung nicht |
| Inhaltsprüfsumme je verfolgter Datei | `36ef1067b2eaf772…` | `b58f937bac3b839e…` | **erfasst die Änderung** |

**Was das feststellt.** Die Maskierung schaltet **eine** Hälfte des Instruments
stumm, nicht beide. Die Inhaltsprüfsumme liest über den Pfad und sieht die
Änderung weiterhin.

**Was das nicht feststellt.** Der Versuch deckt die Änderung des Inhalts einer
vorhandenen, maskierten Datei ab. Er sagt nichts über die Löschung einer
maskierten Datei (6.10.4), nichts über Rechte- und Typwechsel und nichts über
Einträge, die allein die Statusliste sieht — unverfolgte Dateien und den
Zustand des Index. Diese Aufzählung ist die Grenze des Belegs, nicht die Grenze
des Instruments; sie wird hier genannt, weil ein Beleg, dessen Reichweite
unausgesprochen bleibt, wieder zu der Aussage würde, die stärker ist als ihre
Quelle.

#### 6.10.2 Was die Befundmeldung sagen darf — und was nicht mehr

| | |
|---|---|
| **Vorher galt** | Der Ausgang war als "nicht beobachtbar" benannt; die Tabelle in Abschnitt 6 sagte, ob der Kettengrundsatz verletzt sei, lasse sich "gerade nicht sagen" |
| **Jetzt gilt** | Die Meldung nennt, **welche Hälfte** des Instruments stumm ist, für **welche Dateien**, und was die andere Hälfte gemessen hat. Sie behauptet nicht mehr, der Arbeitsbaum sei unbeobachtet |

Der Koordinator hat den Befundtext im Makefile bereits so benannt — er nennt
ausdrücklich Lage C und führt das Messergebnis mit. Diese Fortschreibung deckt
das und legt den Massstab dafür fest.

**Die Aussage, die nach dem Messergebnis noch trägt**, lautet für einen Lauf mit
gesetzter Maskierung und ohne Abweichung der Prüfsummen: *Der Inhalt der
verfolgten Dateien ist unverändert. Für die maskierten Dateien trägt allein die
Inhaltsprüfsumme; alles, was nur die Statusliste sieht, ist für sie nicht
beurteilt.* Das ist schwächer als "unbeobachtet" und schwächer als "unverändert"
— und es ist die einzige der drei Aussagen, die belegt ist.

**Weshalb die Genauigkeit hier mehr ist als Wortklauberei.** Nach 5.3 ist die
Ausgabe der Kette eine Protokollspur, und Negativbefunde sind darin zwingend
enthalten. Ein Negativbefund, der zu viel behauptet, ist derselbe Mangel wie ein
fehlender: Wer später liest, "der Arbeitsbaum war unbeobachtet", schliesst
daraus, dass über den Inhalt nichts bekannt war — obwohl er gemessen wurde. Der
Protokolleintrag wäre dann in der einen Richtung falsch, in der er nicht falsch
sein darf. Dieselbe Überlegung hat im Makefile bereits dazu geführt, "beobachtet
und in Ordnung" von "gar nicht beobachtet" zu trennen; sie wird hier eine Stufe
feiner fortgesetzt.

#### 6.10.3 Der absolute Massstab bleibt — eine Zeile seiner Begründung wird berichtigt

**Der Entscheid aus 6.9.2 bleibt unverändert:** Ein gesetztes
Maskierungsmerkmal ist ein Befund, auch wenn es schon vor dem Lauf gesetzt war,
und der Ausgang ist Lage C.

**Berichtigt wird eine Begründungszeile.** 6.9.2 stützte den absoluten Massstab
unter anderem auf den Satz, die Vorher-Aufnahme sei dann bereits blind und ein
Vergleich zweier blinder Aufnahmen ergebe zuverlässig "keine Abweichung". Das
gilt nach dem Messergebnis **nur für die Statusliste**, nicht für das Instrument
als Ganzes. Der Satz war für beide Hälften formuliert und behauptete damit mehr,
als er trug. Er wird hier nicht gelöscht — 6.9 bleibt als früherer Stand stehen,
wie jede vorangegangene Fortschreibung —, sondern an dieser Stelle berichtigt.
Das ist genau der Vorgang, den dieser ADR von allen Beteiligten verlangt, und er
gilt auch für die Rolle, die ihn schreibt.

**Weshalb der Entscheid die Berichtigung übersteht — drei Gründe, die vom
Messergebnis unabhängig sind.**

1. **Ein Instrument mit einer stummen Hälfte ist kein vollständiges
   Instrument.** D19 hat zwei Teile, weil ein Teil nicht genügte; das war der
   Inhalt der vierten Fortschreibung. Wenn einer davon ausfällt, ist die
   Zusicherung von D19 nicht mehr die, die entschieden wurde. Ob der Rest
   "wahrscheinlich reicht", ist keine Kategorie einer Bauvorschrift (5.4).
2. **Die Reichweite des Rests ist selbst nicht vollständig gemessen.** Der
   Löschfall steht offen (6.10.4). Den absoluten Massstab auf eine Deckung zu
   stützen, deren Umfang unbekannt ist, wäre dieselbe Annahme, gegen die 6.9
   entschieden hat — nur eine Ebene versetzt.
3. **Der Massstab kostet im Normalfall nichts.** Ein Maskierungsmerkmal
   entsteht nicht versehentlich; es wird gesetzt. Wo keines gesetzt ist, meldet
   der Schritt nichts. Der absolute Massstab verlangt also niemandem etwas ab
   ausser dem, der das Messmittel stummgeschaltet hat — und dass genau das
   sichtbar wird, ist der Zweck.

**Was sich durch die Berichtigung tatsächlich ändert**, ist nicht die Farbe des
Laufs, sondern der Satz, mit dem er begründet wird: Der Befund heisst nicht mehr
"es konnte nichts beobachtet werden", sondern "das Instrument war unvollständig,
und zwar in diesem benannten Teil".

#### 6.10.4 Der nicht gemessene Fall — O-17

Ausdrücklich als Restpunkt geführt und nicht vermutet: **Was geschieht, wenn
eine maskierte, verfolgte Datei gelöscht wird?** Die Aufzählung der verfolgten
Dateien führt sie weiter, weil sie im Index steht; die Prüfsummenbildung findet
die Datei dann nicht vor. Ob die Aufnahme dadurch abweicht — und die Löschung
damit trotz Maskierung sichtbar wird — oder ob sie unverändert bleibt, ist
**nicht gemessen worden**. Dieser ADR behauptet dazu nichts und führt die Frage
als **O-17**.

Auch hier gilt, was schon für O-16 galt: Am Entscheid ändert die Antwort nichts.
Eine gesetzte Maskierung bleibt ein Befund, und der Ausgang bleibt Lage C. Die
Antwort bestimmt allein, wie weit die Meldung nach 6.10.2 sagen darf, dass der
Inhalt beurteilt sei. Fällt sie ungünstig aus, ist die Aussage über die
maskierten Dateien enger zu fassen — eine Fortschreibung der Meldung, nicht des
Entscheids.

#### 6.10.5 Was diese Fortschreibung nicht ändert

Der Entscheid aus 6.9 bleibt in allen Teilen: Die Beobachtbarkeit des Index ist
zweiter Teil des Prüfmittels von D19, ein gesetztes Maskierungsmerkmal ergibt
Lage C, der Gegenstand wird relativ gemessen und das Instrument absolut
verlangt, und die geschärfte Lage C gilt für alle Kettenschritte. Gegenstand,
Mittel und Massstab von D19 bleiben unverändert; geändert wird ausschliesslich,
was die **Meldung** behaupten darf. Kein Kettenschritt D1 bis D12, D18 oder D20
ändert sich. Der Kettengrundsatz aus 6.1.3, die Nummernregel aus 6.1.2 und der
Grundsatz aus 6.8.4 bleiben in Kraft — letzterer erhält mit diesem Fall sein
genauestes Beispiel: Ein Rückgabewert sagt, was der Schritt gefunden hat, und
eine Befundmeldung darf nicht mehr behaupten, als der Schritt messen konnte. Die
offenen Punkte O-7, O-8, O-10, O-12, O-14 und O-15 bleiben offen; O-16 ist
geschlossen, O-17 ist neu.

### 6.11 Elfte Fortschreibung vom 2026-09-01 — ein blockierender und fünf nachrangige Befunde behoben, eine Lücke geschlossen

**Anlass.** Eine unabhängige Prüfung auf einem anderen Modell als die
Umsetzung — Static Software Tester, Dynamic Software Tester und Protocol
Master, alle drei am 2026-09-01 — hat gegen die achte bis zehnte
Fortschreibung einen blockierenden und fünf nachrangige Befunde gebracht. Der
Koordinator hat jeden Befund gegen diese Datei und gegen einen ausgeführten
Lauf nachgeprüft und behoben. Diese Fortschreibung dokumentiert den Entscheid;
sie trifft ihn nicht neu.

**Beleglage dieser Fortschreibung.** Wie in 6.8 und 6.9 wird getrennt, worauf
welche Aussage beruht. Diese Rolle hat den vollständigen, bereits behobenen
Quelltext von `scripts/belege-pruefen.sh` und die einschlägigen Stellen von
`Makefile` gelesen; sie hat **nichts selbst ausgeführt**. Aussagen über die
*Struktur* der Behebung — der neue Rückgabewert 3, die vorgeschaltete Prüfung
der drei Dateien, die getrennte Auswertung im Makefile-Ziel `belege`, die
Ersetzung von `wc -l` durch `awk`, die Streichung der beiden Aufzählungen, die
ergänzte Lagetabelle, das Trimmen der beiden D7-Meldungen, die laufbezogene
Zeile im D19-Zweig — stammen aus dem gelesenen Quelltext und sind dort
nachprüfbar. Aussagen über einen *ausgeführten Lauf* — die drei Gegenproben zu
Lage C, der Hintergrundlauf von `make dod` mit einer während des Laufs
geänderten Datei, die 67 auf einen Schlussumbruch geprüften Dateien — sind als
Fremdbeleg des Koordinators übernommen und hier als solche gekennzeichnet,
nicht als eigene Beobachtung. Dieselbe Trennung wie in 6.8 und 6.9, aus
demselben Grund: Eine Aussage über die Herkunft, die stärker ist, als die
Quelle sie trägt, ist genau die Fehlerklasse, gegen die der Belegprüfer gebaut
wurde und die diese Fortschreibung selbst behebt.

#### 6.11.1 Der blockierende Befund — wortgetreu belegt

Behauptet war an drei Stellen, dass ein fehlendes Bezugsdokument Lage C
ergibt: hier in 6.8.3 mit dem Satz „Deshalb stehen beide Dateien in der
Prüfmittelspalte: Lage C sagt, was los ist.", in der D20-Zeile der
Objekttabelle in Abschnitt 6 mit dem Satz „Fehlt eines davon, ist das Lage
C — nicht ein bestandener Schritt (6.8.3)." und im D20-Kriterium von
`docs/06_Definition_of_Ready_und_Done.md`. Gebaut war davon nichts: Das
Makefile-Ziel `belege` prüfte vor dieser Fortschreibung genau drei
Bedingungen — Skript vorhanden, `git` installiert, Git-Arbeitsbaum
vorhanden —, und im Skript stand vor den beiden `mapfile`-Zeilen, die die
Referenzmengen aus `docs/05_Product_Backlog.md` und
`docs/00_Projektauftrag.md` bilden, keine Existenzprüfung; die Ausnahmeliste
wurde über `if [ -f "$AUSNAHMEDATEI" ]` stillschweigend als „keine Ausnahmen"
behandelt.

**Gemessen** (isolierter Lauf des Koordinators, 2026-09-01, Fremdbeleg): `set
-uo pipefail` ohne `-e` lässt `mapfile` über eine fehlende Datei mit
Rückgabewert 0 laufen. Die Referenzmenge bleibt leer, und danach gilt jede
gültige Anforderungskennung im Bestand als ungültig. Das Ergebnis wäre
Rückgabewert 2 mit hunderten Scheinfunden gewesen — genau der Fehlermodus,
den 6.8.3 als vermieden beschreibt, aber nicht baute.

#### 6.11.2 Was behoben wurde, und wie es geprüft ist

1. **Neuer Rückgabewert 3 des Belegprüfers.** `scripts/belege-pruefen.sh`
   unterscheidet jetzt: 0 = keine Beanstandung, 2 = mindestens ein Befund, 3 =
   Lage C — ein Prüfmittel fehlt oder trägt die Aussage nicht. Grund für die
   Trennung: „rot, weil etwas gefunden wurde" und „rot, weil nicht gemessen
   werden konnte" sind verschiedene Aussagen. Bis zu dieser Fortschreibung
   kannten 6.8.3 und 6.8.4 nur 0 und 2; das ist unvollständig geworden und in
   6.11.5 berichtigt.
2. **Prüfung vor jeder Verwendung.** Das Skript prüft vor jeder Verwendung
   `docs/05_Product_Backlog.md`, `docs/00_Projektauftrag.md` und
   `scripts/belege-ausnahmen.txt` auf Vorhandensein und Lesbarkeit, und
   zusätzlich — nach der geschärften Lage C aus 6.9 — ob die beiden
   Bezugsdokumente eine **nicht leere** Referenzmenge hergeben. Eine
   vorhandene, aber aussagelose Datei ist derselbe Ausfall wie eine fehlende.
   Für die Ausnahmeliste gilt nur der erste Teil: Eine vorhandene Liste ohne
   Einträge ist ein zulässiger Zustand, eine fehlende lässt jede begründete
   Ausnahme stumm wegfallen.
3. **Getrennte Auswertung im Makefile.** Das Ziel `belege` prüft dieselben
   drei Dateien vorab und wertet den Rückgabewert des Skripts getrennt aus: 3
   wird Lage C, jeder andere Wert ungleich 0 wird A_FAIL.

**Ausgeführt belegt am 2026-09-01** (Fremdbeleg, drei Gegenproben, Arbeitsbaum
jeweils vorher und nachher gleich):

- Ausnahmeliste beiseitegelegt: `make belege` meldet Lage C mit dem Hinweis,
  dass `scripts/belege-ausnahmen.txt` fehlt, samt einer entsprechenden
  Lage-Marke; das Skript allein endet mit Rückgabewert 3.
- Backlog beiseitegelegt: dieselbe Wirkung mit der auf den Backlog gemünzten
  Meldung, Skript ebenfalls 3.
- Backlog vorhanden, aber ohne jede Kennung als Überschrift: das Skript
  meldet, dass die Datei keine einzige Anforderungskennung als Überschrift
  trägt, und endet mit 3 — der zweite Teil der geschärften Lage C, erstmals
  ausgeführt belegt.

#### 6.11.3 Fünf nachrangige Befunde, ebenfalls behoben

a) **`wc -l` zählte Zeilenumbrüche statt Zeilen** (`scripts/belege-pruefen.sh`).
Einer Datei ohne abschliessenden Umbruch fehlte in der Zählung die letzte
Zeile; ein richtiger Verweis auf sie wäre fälschlich ein Fund gewesen — die
entgegengesetzte Fehlerrichtung zu den drei bisherigen Prüfrunden. Im
damaligen Bestand latent, weil alle 67 erfassten Dateien mit einem Umbruch
enden (Fremdbeleg, einzeln gemessen). Ersetzt durch `awk 'END{print NR+0}'`.
Gegenprobe: drei Zeilen ohne Schlussumbruch — `wc -l` sagt 2, `awk` sagt 3;
leere Datei: beide 0.

b) **Zwei veraltete Aufzählungen der Ausführungsreihenfolge** im
Makefile-Kommentar nannten D20 nicht, obwohl er seit dem 2026-09-01 als
erster Schritt läuft. Bemerkenswert: Der eine Absatz warnt wörtlich davor,
die Reihenfolge ein zweites Mal aufzuzählen, „die bei der nächsten
Fortschreibung erneut veralten könnte" — und führte im selben Absatz eine
solche Aufzählung, die genau so veraltet war. Die Aufzählungen sind
gestrichen, nicht nachgeführt: eine nachgeführte Aufzählung wäre beim
nächsten Schritt wieder falsch. Die Reihenfolge steht jetzt ausschliesslich
in `schritte_liste`.

c) **Die Lagetabelle im Makefile-Kopf führte D20 nicht.** Zeile ergänzt (Lage
A, keine Lage B nach 6.8.3), Überschrift auf „Stand des Bestands am
2026-08-30, um D20 ergänzt am 2026-09-01".

d) **Doppeltes Leerzeichen in zwei D7-Meldungen** (`Makefile`) durch `tr '\n'
' '` auf einem Einzeltreffer: `tr` macht auch aus dem abschliessenden
Zeilenumbruch ein Leerzeichen. Beide Pfade werden jetzt zusätzlich mit `sed`
beschnitten, je durch einen ausgeführten Lauf nachgemessen (Fremdbeleg).

e) **Der D19-Zweig für den stummgeschalteten Index sagte nicht, was die
andere Hälfte in DIESEM Lauf gemessen hat**, obwohl 6.10.2 genau das zusagt.
Er gab den allgemeinen O-16-Befund aus und schwieg über den Lauf; Schweigen
ist keine Messung. Der Code ist an die Zusage herangeführt worden, nicht die
Zusage abgeschwächt: Eine laufbezogene Zeile nennt jetzt, ob Statusliste und
Inhaltsprüfsummen vorher und nachher gleich waren, mit dem ausdrücklichen
Zusatz, dass diese Gleichheit den Lauf nicht entlastet, weil sie nicht
ausschliessen kann, was die blinde Hälfte gar nicht meldet. Ausgeführt belegt
am 2026-09-01 mit gesetztem `assume-unchanged` (Fremdbeleg).

#### 6.11.4 Eine geschlossene Lücke — D19 während eines laufenden `make dod`

Die dynamische Prüfung hat offengelassen, ob D19 eine **während des Laufs**
vorgenommene Änderung tatsächlich meldet — nur der Erfolgsfall war
beobachtet. Der Koordinator hat das am 2026-09-01 nachgeholt (Fremdbeleg):
`make dod` im Hintergrund gestartet, nach drei Sekunden eine verfolgte Datei
geändert. D19 meldete den Befund „VERLETZT", nannte den Kettengrundsatz als
Grundlage, benannte die betroffene Datei und zeigte **beide** Hälften des
Instruments — die Statuszeile und die geänderte Inhaltsprüfsumme. Damit ist
erstmals belegt, dass D19 nicht nur schweigt, wenn nichts ist, sondern auch
spricht, wenn etwas ist.

#### 6.11.5 Zwei Berichtigungen in dieser Datei

**Erstens, 6.8.3 und 6.8.4.** Beide Abschnitte nannten bis zu dieser
Fortschreibung nur die Rückgabewerte 0 und 2 des Belegprüfers und behandelten
damit „das Prüfmittel selbst ist ausgefallen" und „am Bestand wurde etwas
gefunden" als denselben Fall. Das ist seit 6.11.2 unvollständig; an beiden
Stellen steht jetzt ein kurzer Verweis auf diesen Abschnitt.

**Zweitens, die Tabelle der offenen Punkte in Abschnitt 8.** Sie führte
„O-10" zweimal: eine Zeile als offenen Punkt vom 2026-08-30, die
darunterliegende als „O-10 (neu gefasst)" mit dem Vermerk „Beantwortet am
2026-08-30". Die Nummernregel verlangt, dass die Nummer bleibt und Historie
nicht umgeschrieben wird; gelöscht wird deshalb keine Zeile. Die erste Zeile
ist als überholt gekennzeichnet und verweist auf die zweite.

#### 6.11.6 Neuer offener Punkt — O-18

Ob die drei Bezugsdokumente in der Prüfmittelspalte künftig auch auf
**Aktualität** und nicht nur auf Vorhandensein zu prüfen sind: Eine veraltete
Referenzmenge — eine Anforderungskennung, die im Backlog längst umbenannt
oder gestrichen wurde, ein Abschnitt des Projektauftrags, der verschoben
wurde — fällt heute durch kein Netz. Der Belegprüfer sieht nur, ob die
Dateien bestehen und eine nicht leere Referenzmenge hergeben, nicht, ob diese
Referenzmenge noch dem aktuellen Stand entspricht. Zuständig: Software
Architect mit dem Static Software Tester, terminiert mit R3-Q-001.

#### 6.11.7 Was diese Fortschreibung nicht ändert

Kennung, Stellung, Objektbedingung und die drei ursprünglichen Prüfmittel von
D20 bleiben unverändert; hinzu kommt ausschliesslich der dritte Rückgabewert
des Skripts und die vorgeschaltete Prüfung im Makefile, beide bereits als
Teil von 6.8 angelegt und hier zu Ende gebracht. Gegenstand, Mittel und
Massstab von D19 bleiben unverändert; geändert ist ausschliesslich, was die
laufbezogene Meldung zusätzlich nennt (6.11.3, Punkt e). Der Kettengrundsatz
aus 6.1.3, die Nummernregel aus 6.1.2 und der Grundsatz aus 6.8.4 zur
Aussagekraft eines Rückgabewerts 0 bleiben in Kraft; 6.8.4 gilt jetzt
sinngemäss auch für Rückgabewert 3 — auch er sagt nur, was das Prüfmittel
nicht leisten konnte, nie, dass am Bestand nichts wäre. D1 bis D12 und D18
bleiben unverändert. Die offenen Punkte O-7, O-8, O-10 (neu gefasst), O-12,
O-14, O-15 und O-17 bleiben offen. O-16 bleibt geschlossen. O-18 ist neu.

### 6.12 Zwölfte Fortschreibung vom 2026-09-02 — das Definition-of-Done-Gate aus R3-Q-001, entworfen; Bau auf Weisung vom 2026-09-02 begonnen, förmliche Freigabe ausstehend

> **Status dieses Abschnitts: dem Auftraggeber am 2026-09-02 vorgelegt; der
> Bau ist am selben Tag auf seine Weisung begonnen worden; die förmliche
> Freigabe der Entscheidpunkte E-A bis E-K steht aus** (Wortlaut der Weisung,
> Lesart und umgesetzte Optionen in Abschnitt 10; Formweg: Merge des Pull
> Requests dieses Arbeitszweigs oder Anweisung mit exaktem Wortlaut). Bis zur
> Weisung war kein Hook-Skript, keine Liste terminierter Lagen und keine
> Änderung an `.claude/settings.json` oder am `Makefile` entstanden. Die
> Einträge dieser Fortschreibung in den Abschnitten 8 und 9 tragen denselben
> Vermerk.

**Anlass.** Der Auftraggeber hat am 2026-09-02 angewiesen, die Gates aus
R3-Q-001 als Fortschreibung dieses Abschnitts **vor** dem Bau vorzulegen. Der
Grund liegt in diesem Abschnitt selbst: Er legt seit dem 2026-08-20 fest, dass
der Hook aus R3-Q-001 **diesen einen Befehl** `make dod` aufruft, dass nur
Rückgabewert 2 blockiert, dass ein Reentranz-Schutz über `stop_hook_active`
greift und dass nach dreimaligem Scheitern am gleichen Kriterium eskaliert wird
(3.4). Was er nicht festlegt, ist das Entscheidende: **wie das Gate die
Ausgabe von `make dod` liest.** Vier Fragen sind daran offen, und jede von
ihnen entscheidet zwischen einem Gate, das ab sofort jede Arbeitseinheit
blockiert, und einem, das nichts wert ist.

**Beleglage dieser Fortschreibung — was worauf beruht.** Wie in 6.8, 6.9 und
6.11 wird getrennt, worauf welche Aussage beruht. Diese Rolle hat **nichts
ausgeführt**; sie hat kein Ausführungswerkzeug und prüft ihre eigene Arbeit
ohnehin nicht (3.4).

| Herkunft | Was |
|---|---|
| **Gelesen** (diese Rolle, am 2026-09-02) | `CLAUDE.md`; `docs/00_Projektauftrag.md`, Abschnitte 3.3 und 3.4; `docs/05_Product_Backlog.md`, Eintrag R3-Q-001 mit beiden Achtung-Hinweisen und die offenen Punkte des Backlogs, Nummer 16; `docs/06_Definition_of_Ready_und_Done.md`, Teil 2 vollständig; dieser Abschnitt 6 vollständig einschliesslich 6.1 bis 6.11; vom `Makefile` der Kopfkommentar, der Variablenblock, das Makro `KLASSIFIZIEREN`, die Ziele `belege`, `abnahme` und `dod` vollständig; `.claude/hooks/block-main-write.sh` vollständig; `.claude/rules/claude-konfiguration.md`, Abschnitt "Hooks"; `scripts/belege-ausnahmen.txt`; `methodik/entscheide.md` des Methodik-Repositories, Einträge V9 bis V13, S4 und S5; die offizielle Hook-Dokumentation `https://code.claude.com/docs/en/hooks.md`, abgerufen am 2026-09-02, in den Abschnitten "Stop", "SubagentStop", "TaskCompleted", "Exit code output", "Timeouts", "Exit code 2 behavior per event", "JSON output", "Common input fields", "Common fields", "Matcher patterns" und "Reference scripts by path" |
| **Selbst gemessen ohne Ausführung** | Die Zeichenkette `LAGE C:` kommt im `Makefile` **53-mal** vor. Über alle **21** Rollendateien unter `.claude/agents/`: `static-software-tester` und `pentester` tragen `tools: Read, Grep, Glob, Bash, Skill` — also `Bash`, aber weder `Edit` noch `Write` —, und in allen 21 Dateien ist das Frontmatter-Feld `name:` mit dem Dateinamen gleich. `CLAUDE_CODE_STOP_HOOK_BLOCK_CAP` steht an **drei** Stellen des Repositories: `docs/00_Projektauftrag.md` (3.4), `docs/06_Definition_of_Ready_und_Done.md` ("Durchsetzung") und `docs/adr/0001-rollenmodell.md`. Das sind Textsuchen über Dateien, keine Läufe |
| **Fremdbeleg** (Läufe des Koordinators vom 2026-09-02, hier übernommen und nicht nachgeprüft) | Die Umgebung der Sitzung (`CLAUDE_CODE_REMOTE=true`, `CLAUDE_PROJECT_DIR` wird an Hooks exportiert, `HOME=/root`, GNU Make 4.3, bash 5.2.21, jq 1.7, `timeout` und `flock` vorhanden, `git` vorhanden, `gitleaks` fehlt, `uv` und `ruff` vorhanden, kein `backend/`, kein `frontend/`, kein `deploy/`); der flache Klon und seine 31 Funde gegenüber 1 Fund nach `git fetch --unshallow`; der eine Fund auf `origin/main` in jedem frischen Klon; der gemessene Lauf von `make dod` (5,8 s, Rückgabewert 2, Abbruch bei D20); die Form der Ausgabe, soweit sie einen Lauf voraussetzt; die parallel schreibenden Subagenten dieser Sitzung |
| **Nicht behauptet, weil nicht belegt** | Ob es eine Umgebungsvariable `CLAUDE_CODE_STOP_HOOK_BLOCK_CAP` gibt (6.12.2, O-19); wie lange die Kette mit dem Grundgerüst läuft (O-20); ob ein Scheinbaum mit dem echten Belegprüfer grün wird (6.12.19) |
| **Berichtigt nach Runde 1 der Prüfung** | Die erste Fassung dieses Entwurfs führte hier zusätzlich, die Referenz sage nicht, ob eine Änderung an `.claude/settings.json` in der laufenden Sitzung wirke. **Das ist falsch:** Sie sagt es, im Abschnitt zur Einrichtung der Hooks — "Direct edits to hooks in settings files are normally picked up automatically by the file watcher." Die Angabe ist berichtigt; der Entscheid zum Selbsttest (6.12.19) bleibt bestehen, trägt aber jetzt die Gründe, die ihn wirklich tragen, statt eines Schweigens, das es nicht gab |

Diese Trennung steht hier aus demselben Grund wie in 6.8: Eine Aussage über die
Herkunft, die stärker ist, als die Quelle sie trägt, ist die Fehlerklasse, an
der in diesem Projekt bereits zwei Arbeitseinheiten nach 3.4 abgebrochen sind
(V11, V12).

**Runde 1 der Prüfung, eingearbeitet am 2026-09-02.** Vier Prüflinsen auf einem
anderen Modell als die Umsetzung und eine Nachprüfung des Koordinators am
Bestand haben gegen die erste Fassung dieses Abschnitts **dreizehn** Befunde
gebracht, darunter einen blockierenden inneren Widerspruch (6.12.14). Alle
dreizehn sind hier eingearbeitet; die betroffenen Stellen tragen den Vermerk
**Runde 1**, und keine frühere Aussage ist gelöscht, sondern berichtigt. Das ist
V11 in Anwendung: Eine Behebung ist nicht fertig, wenn der Befund weg ist,
sondern wenn die Schicht geprüft ist, die sie erreichbar gemacht hat — deshalb
sind mit den Befunden auch die Stellen nachgeführt worden, die sie erst
erreichbar gemacht haben (die Objekttabelle in Abschnitt 6 für G16, die
Übersichtstabelle in 6.12.1 für G10).

**Ein gemessener Stand, und weshalb er ein vergangener ist.** Als
**Fremdbeleg** kommt aus dieser Runde hinzu: Der Koordinator hat am 2026-09-02
den ortsgebundenen Ausnahmeeintrag für den Fund aus 6.12.17 angelegt und danach
`scripts/belege-pruefen.sh` laufen lassen — **0 Befunde, Rückgabewert 0**,
gemessen **vor** dem Anlegen dieses Abschnitts; der Eintrag ist zum Zeitpunkt
dieser Fortschreibung **noch nicht committet**. Dieser Stand gilt für den
damaligen Bestand und nicht für den heutigen: Dieser Abschnitt nennt selbst zwei
Dateien, die erst mit dem Bau entstehen — `.claude/hooks/dod-gate.sh` und
`.claude/hooks/dod-gate-terminierte-lagen.txt` —, und jede Nennung eines noch
nicht bestehenden Pfades ist für D20 ein Fund. Das ist kein Fehler des Textes,
sondern der vorgesehene Fall: Er wird durch zwei ortsgebundene Ausnahmen der
Form `datei|wert` gedeckt, die der Koordinator als Umsetzung nach 6.8.5 anlegt
und die mit dem Entstehen der beiden Dateien wieder zu **entfernen** sind — die
Selbstprüfung "der Gegenstand existiert inzwischen" macht sie dann selbst zum
Befund (6.8.5, Eigenschaft 3). Genau so soll es sein: Ein Entwurf, der Artefakte
beschreibt, die es noch nicht gibt, hinterlässt eine Spur, die sich beim Bau von
selbst wieder schliesst.

#### 6.12.1 Überblick über die Entscheide dieser Fortschreibung

| Nr. | Gegenstand | Entscheid | Unterabschnitt |
|---|---|---|---|
| G1 | Die drei Ereignisse und wer die Zusicherung trägt | Ein Skript für `Stop`, `SubagentStop` und `TaskCompleted`, kein Matcher; die harte Zusicherung "nicht abschliessbar" trägt allein `TaskCompleted` — und nur in einer Sitzung, in der überhaupt eine Aufgabenliste geführt wird *(Runde 1, terminiert als O-23)* | 6.12.2 |
| G2 | Was das Gate liest | Die Ausgabe von `make dod`, nicht nur den Rückgabewert; zwei voneinander unabhängige Kriterien, wie sie die Kette für ihre eigenen Schritte schon verlangt *(Nachtrag 6.12.24 k: dazu die Zahl der gelesenen Marken gegen die Zahl, die die Schlusszeile selbst nennt, und mindestens eine Marke — weiterhin ohne eigene Zahl im Gate)* | 6.12.3 |
| G3 | Befund gegen Ausfall (Frage 1) | Unterschieden wird an der **Lage der Marke**, nicht am Rückgabewert und nicht am Meldungstext *(Nachtrag aus dem Bau, 6.12.23: Verstösse gegen die Selbstprüfungen der terminierten Lagen zählen unter `LISTE …`, ein Widerspruch zwischen Rückgabewert 0 und Schlusszeile unter `KETTE schlusszeile-widerspruch`; **Nachtrag 6.12.24:** ein Widerspruch zwischen der Baumzeile der Kette und dem vom Gate bestimmten Baum unter `KETTE baum-widerspruch`)* | 6.12.4 |
| G4 | Lage C (Frage 2) | **Terminierte Lagen C**: eine versionierte, selbstprüfende Liste neben dem Hook; sechs Selbstprüfungen, jede blockierend | 6.12.5 |
| G5 | Der blinde Fleck hinter dem ersten C | Die Kette bricht bei Lage C **nicht mehr ab**, sondern läuft weiter und sammelt; abgebrochen wird weiterhin bei einem Befund | 6.12.6 |
| G6 | Woran das Gate das fehlende Prüfmittel erkennt | Die Lage-Marke trägt es **strukturiert** (`FEHLT=<pfad>`), nicht der Meldungstext; ein C-Zweig ohne Angabe fällt geschlossen | 6.12.7 |
| G7 | Die Schlusszeilen von `make dod` | **Vier** eindeutige Formen, eine eigenständige D19-Zeile, eine Zeile, die den geprüften Baum nennt *(die vierte Form — vollständig gelaufen, aber D19 mit Befund — ist Nachtrag aus dem Bau, 6.12.23)* | 6.12.8 |
| G8 | Zählung und Eskalation (Frage 3) | Zustand ausserhalb des Arbeitsbaums, Schlüssel ist das Kriterium — bei mehreren Abweichungen die erste in Kettenreihenfolge; das dritte Mal verlangt die Übergabedatei, ab dem vierten lässt sie durch, aber **nur** bei `Stop` und `SubagentStop`, nicht bei `TaskCompleted` *(beides Runde 1)*; **fehlt `jq`, blockiert das Gate, kann den Block aber nicht zählen — benannte Grenze** *(Nachtrag aus dem Bau, 6.12.23)*; der Durchlass ab dem vierten Mal löscht den Zähler **nicht**, und ein **nicht bestimmbares** Zustandsverzeichnis erzeugt keinen eigenen Ausgang *(Nachtrag 6.12.24)* | 6.12.9 |
| G9 | `stop_hook_active` (Frage 4) | Rückgabewert 0, wie 3.4 und der Backlog es wörtlich verlangen — **ohne** den Zähler zu verändern; die Folge daraus wird ausgesprochen | 6.12.10 |
| G10 | Prüfmittel des Gates | Sieben, namentlich aufgezählt. **Sechs** davon sind Lage C des Gates und enden mit 2, wenn sie fehlen; das siebte — das Zustandsverzeichnis — hat **keinen eigenen Ausgang**, weil es allein das Zählwerk trägt und nicht das Urteil *(Runde 1: die frühere Fassung dieser Zeile sagte "fehlt eines" und widersprach damit 6.12.11)*. **Nachtrag 6.12.24:** Mit `sha256sum` und `mktemp` führt die Tabelle **acht** blockierende Prüfmittel und neun insgesamt | 6.12.11 |
| G11 | Zeitüberschreitung | Zwei Grenzen: 900 s in `settings.json`, 600 s für die Kette im Skript, 120 s Wartezeit auf die Sperre | 6.12.12 |
| G12 | Der geprüfte Arbeitsbaum, Nebenläufigkeit | Der Baum wird über `git` bestimmt, nicht über einen Verzeichnisnamen; eigene Läufe werden über `flock` serialisiert, die Sperrdatei liegt ausserhalb des Baums *(Nachtrag 6.12.24: der geprüfte Baum ist die **physisch aufgelöste Wurzel** des Arbeitsbaums; Sperr- und Wegwerfdatei liegen nachweislich ausserhalb des Baums, notfalls fest unter `/tmp`)* | 6.12.13 |
| G13 | `SubagentStop` und Rollen ohne Schreibrecht | Das Gate liest den **Gegenstand** — hat diese Rolle ein Werkzeug, über das ADR 0001 Schreibrecht vergibt, also `Edit`, `Write` oder `NotebookEdit`? — und läuft für Rollen ohne ein solches Werkzeug gar nicht erst. `Bash` zählt **nicht** dazu *(Runde 1, blockierender Befund; Begründung und benannte Grenze in 6.12.14)*. Die Rolle wird über das Frontmatter-Feld `name:` aufgelöst, nicht über den Dateinamen | 6.12.14 |
| G14 | Sichtbarkeit | Jeder Durchlass, der kein sauberes Grün ist, meldet sich über `systemMessage`; kein `continue: false`; kein eigenes Protokoll des Gates | 6.12.15 |
| G15 | Kein Zwischenspeicher des Urteils | Das Gate läuft bei jedem Ereignis; ein gespeichertes Urteil wäre ein Urteil über einen vergangenen Lauf | 6.12.16 |
| G16 | Flacher Klon | Die Vollständigkeit der Git-Historie wird **Prüfmittel von D20**; ein flacher Klon ist Lage C mit Beschaffungsweg | 6.12.17 |
| G17 | Der Selbsttest | Formprüfungen gegen eine Attrappe, dazu je ein roter und ein grüner Lauf gegen das **echte** Makefile *(Nachtrag 6.12.24: alle acht Kombinationen der D19-Zeile, die **echten** Rollendateien im G13-Fall, eigene Fälle für G12 und für die Nachträge dieses Abschnitts)* | 6.12.19 |

**Was diese Fortschreibung nicht tut.** Sie baut nichts. Sie legt keine Datei
an ausser dieser. Die Umsetzung liegt beim DevOps Engineer (Makefile,
Hook-Skript, `settings.json`), die Verifikation beim Static und beim Dynamic
Software Tester auf einem anderen Modell als die Umsetzung (3.4).

**Drei Nachträge aus dem Bau vom 2026-09-02** — drei Stellen, an denen dieser
Entwurf keinen Fall vorsieht — sind in **6.12.23** entschieden; die betroffenen
Zeilen dieser Tabelle und der Unterabschnitte 6.12.3, 6.12.4, 6.12.8, 6.12.9
und 6.12.22 tragen den Vermerk "(Nachtrag aus dem Bau, 6.12.23)" an Ort.

**Zehn weitere Entscheide und ein Vermerk zur Beleglage** — aus der statischen
und der dynamischen Verifikation des gebauten Gates vom 2026-09-02, beide
Runden **nicht bestanden** (Fremdbeleg) — stehen in **6.12.24**. Die übrigen
Befunde jener Prüfungen behebt der DevOps Engineer im Code, ohne dass dieser
Entwurf zu ändern wäre; nachgetragen wird hier nur, wo der Entwurf schweigt oder
zu wenig sagt. Die betroffenen Zeilen dieser Tabelle und der Unterabschnitte
6.12.3, 6.12.4, 6.12.9, 6.12.11, 6.12.13, 6.12.15 und 6.12.19 tragen den
Vermerk "(Nachtrag 6.12.24)" an Ort.

#### 6.12.2 G1 — Die drei Ereignisse, und welche Ebene welche Zusicherung trägt

| | |
|---|---|
| **Vorher galt** | Der Backlog verlangt `Stop`-, `SubagentStop`- und `TaskCompleted`-Hook in der versionierten `.claude/settings.json`; Projektauftrag 3.4 ordnet sie den Ebenen 2 und 3 zu. Welche der drei Ebenen welche Zusicherung trägt, stand nirgends |
| **Jetzt gilt** | Ein Skript `.claude/hooks/dod-gate.sh` bedient alle drei Ereignisse und verzweigt über das Eingabefeld `hook_event_name`. Die harte Zusicherung "die Aufgabe lässt sich nicht abschliessen" trägt **allein `TaskCompleted`**. `Stop` und `SubagentStop` leisten eine erzwungene Fortsetzung mit Begründung je Beendigungsversuch — nicht mehr, und das ist zu wissen |

**Weshalb ein Skript und nicht drei.** Drei Dateien, die dieselbe Kette
auswerten, sind drei Stellen, an denen dieselbe Aussage verschieden stehen
kann. Genau diesen Fehler hat dieser Abschnitt bereits dreimal behoben — die
Objektbedingung stand zweimal verschieden (6.2.2), das Prüfmittel von D19 stand
zweimal verschieden (6.9.1), die Ausführungsreihenfolge stand zweimal und war
veraltet (6.11.3 b). V13 zieht daraus den allgemeinen Satz: Eine Angabe, die
nichts steuert, sondern etwas anderes wiederholt, wird gestrichen. Für ein Gate
gilt er erst recht.

**Weshalb kein Matcher.** Die gelesene Referenz führt `Stop` und
`TaskCompleted` in der Matcher-Tabelle unter "no matcher support — always fires
on every occurrence"; `SubagentStop` kann auf den Rollennamen (`agent_type`)
filtern. Ein Matcher mit neunzehn Rollennamen in `settings.json` wäre eine
zweite Kopie der Rechtetabelle aus ADR 0001 und veraltete mit der ersten
Rollenänderung, ohne dass es auffiele. Die Unterscheidung gehört an den
Gegenstand, nicht an eine Namensliste — siehe G13.

**Die Zusicherung, ehrlich zugeordnet.** Die gelesene Referenz sagt zu `Stop`
und `SubagentStop`: "The `stop_hook_active` field is `true` when Claude Code is
already continuing as a result of a stop hook." Wenn das Gate bei gesetztem
Feld mit 0 endet — und das verlangen Projektauftrag 3.4, Ebene 4, und das
Abnahmekriterium von R3-Q-001 wörtlich —, dann erzwingt ein Stop-Gate je
Beendigungsversuch **genau eine** Fortsetzung: Block, Fortsetzung, und der
nächste Stop dieser Fortsetzung wird durchgelassen, auch wenn die Kette rot
bleibt. Zwei aufeinanderfolgende Blocks innerhalb derselben Fortsetzung sind
dann unmöglich.

Daraus folgt zweierlei, und beides gehört ausgesprochen statt später entdeckt:

1. **Die in der Referenz genannte Obergrenze — "Claude Code overrides the hook
   and ends the turn after 8 consecutive blocks" — ist mit diesem Entwurf
   innerhalb eines Beendigungsversuchs unerreichbar.** Sie wird deshalb für
   nichts gebraucht, und der Entwurf stützt sich an keiner Stelle auf sie.
2. **"Dreimal am gleichen Kriterium" (3.4) zählt über Beendigungsversuche
   hinweg**, nicht innerhalb eines einzelnen. Der Zähler aus G8 ist deshalb
   nicht Beiwerk, sondern die einzige Stelle, an der die Eskalationsregel aus
   3.4 überhaupt greifen kann.

Für `TaskCompleted` sagt die Referenz: Bei Rückgabewert 2 "the task is not
marked as completed and the stderr message is fed back to the model as
feedback". Sie führt `stop_hook_active` ausschliesslich bei `Stop` und
`SubagentStop` als zusätzliches Eingabefeld auf; für `TaskCompleted` nennt sie
es nicht. Damit prüft `TaskCompleted` **jeden** Abschlussversuch erneut, ohne
Reentranz-Ausnahme — und trägt als einziges der drei Ereignisse die Zusicherung
aus dem Abnahmekriterium von R3-Q-001. Wer das Gate beurteilt, beurteilt
zuerst `TaskCompleted`; `Stop` und `SubagentStop` sind die laute, frühe
Rückmeldung, nicht die Sperre.

**Und damit steht und fällt die Zusicherung mit einer Voraussetzung, die
niemand festgelegt hat** *(Runde 1)*. Die gelesene Referenz sagt, wann
`TaskCompleted` überhaupt feuert: "when any agent explicitly marks a task as
completed through the TaskUpdate tool, or when an [agent team] teammate
finishes its turn with in-progress tasks". In einer Sitzung, in der keine
Aufgabenliste geführt wird, feuert das Ereignis **nie** — und dann gilt die
harte Zusicherung für nichts. Was bliebe, wären `Stop` und `SubagentStop` mit
je einer erzwungenen Fortsetzung, also genau das, was oben ausdrücklich als
nicht tragend bezeichnet ist.

Das ist keine Kleinigkeit am Rand, sondern die Bedingung, unter der dieser
Entwurf das leistet, was der Backlog von ihm verlangt. Zwei Wege stehen offen,
und die Wahl liegt nicht bei dieser Rolle:

1. **Jede Arbeitseinheit wird als Aufgabe geführt.** Dann feuert
   `TaskCompleted` verlässlich, und die Zusicherung greift. Der Ort dafür ist
   `CLAUDE.md` oder `.claude/rules/claude-konfiguration.md`, und es wäre eine
   Vorschrift an das Vorgehen, nicht an die Architektur — Abschnitt 9 führt sie
   als Nachführung unter Vorbehalt.
2. **Es bleibt dabei, dass Aufgabenlisten fakultativ sind.** Dann ist
   auszusprechen, dass die Definition-of-Done-Kette in solchen Sitzungen nicht
   erzwungen, sondern nur laut angemahnt wird, und dass der Nachweis dort am
   menschlichen Review hängt.

Entschieden wird das vom Auftraggeber; der Punkt ist als **O-23** terminiert.
Er wird hier nicht stillschweigend in die eine oder andere Richtung
vorweggenommen — eine Zusicherung, deren Voraussetzung ungeklärt ist, ist genau
die Zusicherung ohne Deckung aus V12.

#### 6.12.3 G2 — Das Gate liest die Ausgabe, nicht nur den Rückgabewert

| | |
|---|---|
| **Vorher galt** | "Der Hook aus R3-Q-001 ruft **diesen einen Befehl** auf. … nur Rückgabewert 2 blockiert" — über die Auswertung stand nichts |
| **Jetzt gilt** | Das Gate wertet zwei voneinander unabhängige Dinge aus: den Rückgabewert des Aufrufs **und** die Ausgabe von `make dod`, namentlich die Lage-Marken der Übersicht, die D19-Zeile und die Schlusszeile. Fehlt eines von beiden oder widersprechen sie sich, blockiert das Gate |

**Weshalb nicht der Rückgabewert allein.** Das ist keine neue Vorsicht, sondern
die Regel, die `make dod` seit dem 2026-08-30 für seine eigenen Unterschritte
anwendet und im Makefile begründet: Zwei Kriterien entscheiden je Schritt, der
eigene Rückgabewert **und** eine eigene, passende Lage-Marke, weil ein
Rückgabewert allein sich mit `-i/--ignore-errors` und mit einem umgebogenen
Unter-Make-Aufruf erzeugen lässt. Ein Gate, das sich auf denselben einen Wert
verlässt, den die Kette selbst für unzureichend hält, wäre die schwächste
Stelle der ganzen Anordnung.

**Was das Gate von `make dod` übernimmt und was es selbst prüft.** Es übernimmt
die Markenprüfung: `make dod` erzeugt je Aufruf eine nicht vorhersagbare
Lauf-Kennung, reicht sie ausschliesslich über die Umgebung an den jeweiligen
Unter-Make-Aufruf weiter und akzeptiert nur Marken mit genau dieser Kennung.
Diese Kennung ist dem Aufrufer vorher nicht bekannt (Fremdbeleg); das Gate kann
sie also nicht selbst prüfen und muss es auch nicht — es liest sie aus der
Ausgabe und verlangt, dass **alle** Marken der Übersicht dieselbe tragen. Was
das Gate selbst prüft, ist die Form: die Übersichtszeile, genau eine der **vier**
Schlusszeilen aus G7 *(Nachtrag aus dem Bau, 6.12.23; bis dahin drei)*, genau
eine D19-Zeile, und keine Marke der Lage `A_FAIL`. Ein Rückgabewert 0 zusammen
mit einer anderen Schlusszeile als der ersten Form ist ein Widerspruch und
blockiert *(Nachtrag aus dem Bau, 6.12.23)*.

**Was das Gate ausdrücklich nicht zählt.** Es zählt **nicht** die Zahl der
Kettenschritte. Diese Zahl steht im Makefile in einer eigenständigen Liste
(`ERWARTETE_KETTENSCHRITTE`) und wird dort gegen die Zielliste geprüft; `make
dod` sagt in seiner Schlusszeile selbst, dass die Zählung aufging. Eine zweite
Zahl im Gate wäre eine Angabe, die nichts steuert und beim nächsten
Kettenschritt falsch wird — V13, und die Tautologie aus Befund A3, die im
Makefile bereits einmal behoben werden musste. Das Gate liest die **Aussage**,
nicht die Zahl. *(Nachtrag 6.12.24 k: Es führt weiterhin **keine eigene** Zahl.
Es vergleicht aber die Zahl, die die Schlusszeile der Kette selbst nennt, mit
der Zahl der gelesenen Marken und verlangt mindestens eine Marke — geprüft wird
die Selbstaussage der Kette gegen ihren Inhalt, nicht gegen eine Erwartung des
Gates.)*

#### 6.12.4 G3 — Frage 1: Wie das Gate einen Befund von einem ausgefallenen Prüfmittel unterscheidet

**Der Massstab ist die Lage, nicht der Rückgabewert und nicht der Text.** Die
Lagen A, B und C sind seit dem 2026-08-30 die Begriffe dieser Kette, jede
Marke trägt sie, und Regel 4 aus 6.2.2 verlangt ohnehin, dass die Lage
ausgegeben und nicht erschlossen wird. Genau dafür ist sie da.

| Beobachtung in der Ausgabe von `make dod` | Art | Schlüssel des Kriteriums | Ausgang des Gates |
|---|---|---|---|
| Eine Marke endet auf `A_FAIL` | **Befund** | `<D> <ziel> A_FAIL` | blockiert |
| Eine Marke endet auf `C` und ist durch einen gültigen Eintrag der terminierten Lagen gedeckt (G4) | **Ausfall, terminiert** | — | lässt durch, mit `systemMessage` |
| Eine Marke endet auf `C` und ist nicht gedeckt | **Ausfall** | `<D> <ziel> C <fehlendes Prüfmittel>` | blockiert |
| Eine Zeile der Übersicht trägt keine Marke | nicht nachweisbar gelaufen | `KETTE marke-fehlt <D> <ziel>` | blockiert |
| Die D19-Zeile meldet `VERLETZT` | **Befund** | `D19 VERLETZT` | blockiert |
| Die D19-Zeile meldet Lage C | **Ausfall** | `D19 C` | blockiert |
| Die D19-Zeile meldet Lage B, obwohl das Gate einen Arbeitsbaum bestimmt hat *(Nachtrag 6.12.24, Befund S-01: Dieser Schlüssel hat **Vorrang** vor der Konsistenzwache "Rückgabewert 0 mit einer Abweichung"; sonst zählte derselbe Fall als `KETTE ausgabe-unlesbar` und die Meldung sagte das Falsche)* | Widerspruch | `D19 B-widerspruch` | blockiert |
| Keine Übersichtszeile oder keine der **vier** Schlusszeilen aus G7 *(Nachtrag aus dem Bau, 6.12.23; bis dahin drei)* | nicht nachweisbar gelaufen | `KETTE ausgabe-unlesbar` | blockiert |
| Rückgabewert 0, aber eine andere Schlusszeile als Form 1 aus G7 *(Nachtrag aus dem Bau, 6.12.23)* | Widerspruch | `KETTE schlusszeile-widerspruch` | blockiert |
| Die erste Zeile der Kette (`make dod: geprueft wird <PROJ>.`) nennt einen anderen Baum als den vom Gate bestimmten *(Nachtrag 6.12.24; Befund S-10: eine **fehlende** Baumzeile ist dagegen `KETTE ausgabe-unlesbar` — sie nennt keinen anderen Baum, sondern gar keinen)* | Widerspruch | `KETTE baum-widerspruch` | blockiert |
| Rückgabewert weder 0 noch 2 | nicht nachweisbar gelaufen | `KETTE rueckgabewert=<N>` | blockiert |
| Die Kette reisst das innere Zeitlimit (G11) | nicht nachweisbar gelaufen | `KETTE zeitueberschreitung` | blockiert |
| Eine Zeile der terminierten Lagen verletzt die Selbstprüfung 2, 3 oder 5 (G4) *(Nachtrag aus dem Bau, 6.12.23)* | **Fehler der Liste** | `LISTE <Nummer der Selbstpruefung> <D> <ziel>` | blockiert |
| Eine Zeile der terminierten Lagen verletzt die Selbstprüfung 4 oder 6 (G4) *(Nachtrag aus dem Bau, 6.12.23)* | **Fehler der Liste** | `LISTE <Nummer der Selbstpruefung> <Zeilennummer>` | blockiert |
| Ein Prüfmittel des Gates fehlt (G10) | **Lage C des Gates** | `GATE <fehlendes Prüfmittel>` | blockiert |

**Die Zeile für die Selbstprüfung 1 der terminierten Lagen steht bereits in
dieser Tabelle** *(Nachtrag aus dem Bau, 6.12.23)*: Eine gemeldete Lage C ohne
Eintrag ist kein Fehler der Liste, sondern eine ungedeckte Lage C, und zählt
unverändert unter `<D> <ziel> C <fehlendes Prüfmittel>`. Nur die
Selbstprüfungen 2 bis 6 brauchten einen eigenen Schlüssel.

**Der tragende Satz: Alles ausser einem belegten Grün blockiert.** Ein belegtes
Grün liegt vor, wenn die Kette **vollständig gelaufen** ist (eine der **drei**
Vollständigkeits-Schlusszeilen aus G7 — Form 1, 2 oder 4; *Nachtrag aus dem
Bau, 6.12.23, bis dahin zwei*), **keine** Marke `A_FAIL` zeigt, die D19-Zeile
ohne Befund ist und **jede** Marke der Lage C durch einen gültigen Eintrag
gedeckt ist. Über Form 4 kann ein belegtes Grün nie zustande kommen: Sie setzt
einen D19-Befund voraus, und der schliesst das Grün nach demselben Satz aus. Jeder andere Ausgang blockiert — auch der, den niemand
vorhergesehen hat. Das ist die Richtung, in die ein Gate irren darf: falsch rot
ist sichtbar, ortsgebunden behandelbar und unterliegt der Eskalation aus 3.4;
falsch grün ist die gefährliche Richtung (6.8.4, Punkt 3).

**Weshalb die Unterscheidung überhaupt gebraucht wird.** Sie steuert dreierlei:
den Schlüssel des Zählers (G8) — ein Befund und ein Ausfall am selben Schritt
sind nicht dasselbe Kriterium; die Meldung, die an die Rolle zurückgeht — bei
einem Befund ist etwas zu beheben, bei einem Ausfall ist ein Prüfmittel zu
beschaffen; und den einen Fall, in dem das Gate durchlässt (G4). Ohne sie wäre
das Gate genau der Fehlermodus, den 6.11.1 belegt hat: rot mit falscher
Begründung.

#### 6.12.5 G4 — Frage 2: Was bei Lage C geschieht

**Die Lage, in der entschieden wird.** *(Nach Runde 1 präzisiert; die erste
Fassung schrieb pauschal "am Bestand von `origin/main` ist heute D20 grün" und
widersprach damit 6.12.17.)* Zu unterscheiden sind zwei Stände:

- **Auf `origin/main`** (`405ebada79a145ac537d8e4102ce46d029046475`) ist D20
  **A_FAIL mit einem Fund** — dem lokalen Zweig-Ref aus 6.12.17. Da D20 als
  erster Schritt läuft und ein Befund die Kette abbricht, endete die Kette dort
  bei D20, und kein weiterer Schritt liefe.
- **Im Arbeitsbaum mit dem am 2026-09-02 angelegten, noch nicht committeten
  Ausnahmeeintrag** war D20 grün: Ein Lauf des Koordinators am 2026-09-02, **vor
  dem Anlegen dieses Abschnitts**, ergab 0 Befunde und Rückgabewert 0
  (Fremdbeleg). Für den heutigen Arbeitsbaum gilt das nicht mehr, und zwar aus
  einem Grund, der zum Entwurf gehört: Dieser Abschnitt nennt zwei erst mit dem
  Bau entstehende Dateien, was für D20 je ein Fund ist und über zwei
  ortsgebundene Ausnahmen gedeckt wird (siehe die Beleglage oben). Erst
  in diesem Stand gilt die Lagenfolge, um die es hier geht: D1 bis D6, D8, D9
  und D18 sind Lage B, und **vier** Schritte sind Lage C — D7
  (`scripts/abnahme-abgleich.sh` fehlt), D10
  (`scripts/prototyp-trennung-pruefen.sh` fehlt), D11 (`gitleaks` fehlt) und
  D12 (`scripts/nachweise-vollstaendig.sh` fehlt).

Für den Entwurf zählt der zweite Stand, weil der erste mit dem Ausnahmeeintrag
behoben wird und weil er ohnehin die Frage nicht stellt, um die es hier geht:
Auf `origin/main` endet die Kette mit 2 wegen eines **Befunds**, im Arbeitsbaum
mit 2 wegen eines **fehlenden Prüfmittels**. Genau diese beiden Fälle
auseinanderzuhalten ist die Aufgabe des Gates (6.12.4) — der heutige Bestand
liefert für beide je ein Beispiel.

`make dod` endet also im massgeblichen Stand mit 2, nicht wegen eines Befunds,
sondern wegen eines fehlenden Prüfmittels. Ein Gate, das jeden Wert ungleich 0 als "nicht abschliessbar"
liest, blockiert ab seiner Einführung **jede** Arbeitseinheit bis zum
Grundgerüst — und das Grundgerüst ist selbst eine Arbeitseinheit.

**Optionen.**

| Option | Bewertung |
|---|---|
| (a) Lage C blockiert immer | Ehrlich, aber unbrauchbar: Das Gate wäre vom Tag seiner Einführung an dauerhaft rot, einschliesslich für die Arbeitseinheit, die die fehlenden Skripte anlegt. Ein Gate, das immer rot ist, wird nicht befolgt, sondern entfernt — dieselbe Erfahrung, die im Makefile-Kopf schon einmal festgehalten werden musste: "Ein Gate, das nichts mehr durchlaesst, ist so kaputt wie eines, das alles durchlaesst." |
| (b) Lage C lässt immer durch | Abgelehnt. Wer `scripts/belege-ausnahmen.txt` beiseitelegt, erzeugt Lage C bei D20 und ginge durch — ausgeführt belegt als Gegenprobe der elften Fortschreibung. Damit wäre die Ausnahmeliste der Weg an der ganzen Kette vorbei |
| (c) **Terminierte Lagen C** — eine versionierte, selbstprüfende Liste neben dem Hook, nach den vier Eigenschaften aus 6.8.5 | Gewählt. Sie macht die Menge der geduldeten Ausfälle abzählbar, ortsgebunden, begründet und selbstprüfend; sie kann nicht stillschweigend wachsen, und sie schrumpft von selbst, sobald ein Prüfmittel entsteht |
| (d) Relativ messen wie D19 — die Kette auf `origin/main` gegen die Kette im Arbeitsbaum | Abgelehnt. Ein zweiter Lauf je Beendigungsversuch, der einen zweiten Arbeitsbaum auf `main` braucht — den das main-Gate sperrt —, und "nicht schlechter als vorher" ist nicht "erledigt". Für den **Gegenstand** ist der relative Massstab richtig (6.9.2); für das **Instrument** gilt der absolute, und ein fehlendes Prüfmittel gehört zum Instrument |
| (e) Nur melden, nicht blockieren | Abgelehnt, aus dem in 6.2.3 und 6.8.4 bereits zweimal entschiedenen Grund: Eine Meldung, die nicht blockiert, wird in einem Stop-Hook nicht gelesen; eine abgestufte Wirkung ist eine Abschaltung mit besserem Namen (5.4) |

**Entscheid: (c).**

**Die Liste.** `.claude/hooks/dod-gate-terminierte-lagen.txt`, versioniert,
neben dem Hook, in der Form von `scripts/belege-ausnahmen.txt` — Schlüssel,
Tabulator, Grund; Leerzeilen und Zeilen mit `#` werden übergangen. Der
Schlüssel ist **doppelt ortsgebunden**, an den Schritt und an das Prüfmittel:

```
<D-Nummer> <ziel>|<fehlendes Prüfmittel als repository-relativer Pfad>	<Grund>
```

**Sechs Selbstprüfungen, jede für sich blockierend.** Sie sind der Grund, aus
dem diese Liste keine Abschaltung ist:

1. **Ein Schritt meldet Lage C ohne Eintrag** — das Gate blockiert. Die Liste
   ist eine Positivliste, keine Ausschlussregel.
2. **Ein Eintrag, dessen Prüfmittel existiert** — der Eintrag ist veraltet, das
   Gate blockiert. Das ist Eigenschaft 3 aus 6.8.5, wörtlich übernommen: Ein
   Eintrag, dessen Gegenstand entstanden ist, deckt beim nächsten Mal etwas
   Echtes zu.
3. **Ein Eintrag zu einem Schritt, der eine andere Lage als C meldet** — der
   Eintrag ist veraltet, das Gate blockiert. Sonst bliebe eine Zeile stehen,
   die niemand mehr liest.
4. **Ein Eintrag ohne Grund** — das Gate blockiert. Eigenschaft 2 aus 6.8.5:
   Eine Ausnahme ohne Begründung ist eine Lücke mit Deckmantel.
5. **Die Marke des Schrittes nennt ein anderes Prüfmittel als der Schlüssel** —
   das Gate blockiert. Ohne diese Prüfung deckte ein Eintrag für D7 wegen des
   fehlenden Abgleichsskripts auch den ganz anderen Fall, dass der Backlog
   keine Abnahmekriterien mehr führt; das Makefile kennt für D7 allein drei
   verschiedene C-Ursachen (gelesen). Diese Prüfung ist der Grund für G6.
6. **Der Schlüssel nennt kein terminierbares Prüfmittel** — das Gate blockiert.

**Was terminierbar ist und was nicht.** Terminierbar ist ausschliesslich ein
**Projektartefakt dieses Repositories**, das dieser ADR in Abschnitt 5 oder 6
als noch nicht entstanden führt — heute die vier Skripte
`scripts/abnahme-abgleich.sh`, `scripts/prototyp-trennung-pruefen.sh`,
`scripts/nachweise-vollstaendig.sh` und `scripts/rueckkanal-pruefen.sh` sowie
`backend/importvertraege.toml`. Nicht terminierbar sind:

- **ein installierbares Werkzeug** — `gitleaks`, `uv`, `node`, `npm`, `docker`,
  `git`. Es fehlt nicht, weil es noch nicht gebaut ist, sondern weil es nicht
  installiert ist; das ist keine Terminierung, sondern eine Aufgabe. **D11
  bleibt damit blockierend**, und das ist beabsichtigt: Der Geheimnis-Scanner
  ist der Schritt, dessen Ausfall am teuersten ist.
- **jedes Prüfmittel von D20** — der Belegprüfer, seine Ausnahmeliste, die
  beiden Bezugsdokumente, `git`, der Arbeitsbaum und, neu mit G16, die
  Vollständigkeit der Historie. D20 ist der Schritt, der die Nachweisführung
  selbst prüft; eine Ausnahme an ihm wäre eine Ausnahme an der Nachweiskette.
- **D19**, weil D19 kein Kettenschritt ist, sondern das Instrument, mit dem der
  Kettengrundsatz beobachtet wird (6.9.1).

**Was das Gate davon maschinell prüft — und was nicht.** V12 verlangt, dass ein
genannter Massstab auch geprüft wird. Deshalb genau:

| Prüft das Gate | Prüft das Gate nicht |
|---|---|
| Der Schlüssel trägt genau eine D-Nummer, einen Zielnamen und, nach dem senkrechten Strich, einen **repository-relativen Pfad** (kein absoluter Pfad, kein blosser Programmname ohne Verzeichnistrenner) | Ob der genannte Grund inhaltlich zutrifft |
| Die D-Nummer ist weder D19 noch D20 | Ob die genannte ADR-Stelle das Artefakt tatsächlich terminiert |
| Der genannte Pfad existiert heute nicht | |
| Der Grund ist nicht leer und nennt eine Stelle dieses ADR in der Form `ADR 0002, <Abschnitt>` | |
| Die Marke des Schrittes trägt dasselbe Prüfmittel (G6) | |

Die rechte Spalte bleibt beim menschlichen Review — dieselbe ehrliche Grenze,
die 6.8.4 für D20 zieht: Ein Werkzeug prüft, dass ein Verweis nicht ins Leere
zeigt, nicht, dass der Fundort die Behauptung trägt. Wer diese Grenze
verschweigt, baut wieder die Zusicherung ohne Deckung aus V12.

**Wer die Liste pflegen darf.** Anders als bei der Ausnahmeliste von D20, die
ein Inventar des Dokumentenbestandes ist, sagt jeder Eintrag hier: *Dieser
Kettenschritt urteilt bis auf Weiteres nicht.* Das ist eine Aussage über die
Kette, nicht über ein Dokument.

| Vorgang | Wer | Bedingung |
|---|---|---|
| Einen Eintrag hinzufügen oder entfernen | Software Architect, als Fortschreibung dieses Abschnitts | Nur für ein Artefakt, das dieser ADR als noch nicht entstanden führt; der Grund nennt die Tatsache und die ADR-Stelle |
| Die Form der Schlüssel, die sechs Selbstprüfungen oder den Begriff des Terminierbaren ändern | Software Architect, als Fortschreibung dieses Abschnitts | — |
| Eine ganze Lage-Art von der Prüfung ausnehmen | Niemand über diese Liste | Das ist keine Ausnahme, sondern eine Änderung des Gates |

**Der Vergleich, an dem diese Entscheidung hängt.** Für einen Kettenschritt ist
Lage B der Zustand "der Massstab hat nichts zu messen" — er wird gemeldet, nicht
verschwiegen, und der Schritt endet mit 0. Für das Gate ist eine terminierte
Lage C dasselbe eine Ebene höher: Der Massstab ist noch nicht da, das wird
gemeldet, und die Arbeit geht weiter. Der Unterschied zur abgelehnten Option
(e) ist nicht rhetorisch: Das Gate blockiert weiterhin bei jedem Schritt, der
**urteilen konnte** und etwas gefunden hat, und die Menge der geduldeten
Ausfälle kann nicht wachsen, ohne dass jemand eine versionierte Zeile mit einem
geschriebenen Grund anlegt, die einer Verifikation durch andere unterliegt.

**Und die Gegenseite bleibt streng.** `make dod` selbst kennt diese Liste
**nicht** und wird durch sie nicht weicher: Eine terminierte Lage C ist für die
Kette unverändert Lage C und ergibt Rückgabewert 2. Die Ausnahme lebt
ausschliesslich im Gate der Arbeitsumgebung, deren Zweck es ist, die Arbeit bis
zum Grundgerüst möglich zu halten. Der Lauf auf der Gegenseite aus O-12 ruft
dieselbe Kette ohne diese Liste auf; dort ist rot rot. Damit ist die Ausnahme
nicht nur begrenzt, sondern hat eine Instanz über sich, die sie nicht kennt.

#### 6.12.6 G5 — Der blinde Fleck hinter dem ersten C, und weshalb die Kette dort nicht mehr abbricht

Dies ist der Punkt, an dem die gewählte Option (c) allein noch nicht trägt, und
er ist beim Entwurf aufgefallen, nicht in der Vorlage genannt.

| | |
|---|---|
| **Vorher galt** | "`make dod` ruft alle Kettenschritte dieser Tabelle in der festgelegten Reihenfolge auf und **endet bei der ersten Abweichung ungleich 0**" |
| **Jetzt gilt** | Die Kette endet bei der ersten Abweichung, **die ein Urteil ist** — bei `A_FAIL`, bei einer fehlenden oder mehrfachen Marke und bei einem sonstigen Rückgabewert ungleich 0. Bei **Lage C** läuft sie weiter, merkt sich den Schritt und endet am Ende trotzdem mit 2 |

**Der Beleg dafür, dass das nötig ist, steht in F5 und in der Lagetabelle des
Makefiles.** Die Kette bricht heute bei D7 ab. Wäre D7 als terminierte Lage C
gedeckt und bräche die Kette dort weiterhin ab, so liesse das Gate einen Lauf
durch, in dem D8 bis D12 **nie gelaufen sind** — darunter D11, dessen Lage C
gerade nicht terminierbar ist, und D12. Das Gate erklärte damit einen Stand für
in Ordnung, von dem es sechs Schritte nicht angesehen hat, und der Grund dafür
wäre eine Zeile in seiner eigenen Ausnahmeliste. Das ist ein falsches Grün, und
zwar das teuerste denkbare: Es entsteht genau dann, wenn jemand die Liste
sorgfältig pflegt.

**Weshalb Weiterlaufen zulässig ist.** Jeder Kettenschritt urteilt über eine
eigene Sache mit einem eigenen Prüfmittel (Objekttabelle in Abschnitt 6); ein
Schritt in Lage C hat nichts gemessen und nichts verändert. Der
Kettengrundsatz aus 6.1.3 ist nicht berührt, und D19 klammert unverändert den
ganzen Lauf ein. Der Preis ist Laufzeit — und V9 ist an genau dieser Abwägung
entschieden: "Das, was korrekt und qualitativ ist. Soll zwar effizient sein,
aber nie an Korrektheit und Qualität verlieren."

**Weshalb bei `A_FAIL` weiterhin abgebrochen wird.** Ein Befund ist ein Urteil.
Er ist zu beheben, und alles, was danach käme, würde gegen einen Stand laufen,
der ohnehin geändert wird. Das ist die ursprüngliche Begründung des Abbruchs,
und sie gilt für Befunde unverändert; sie galt für Lage C nie, weil dort gar
nichts geurteilt wurde.

**Was die Umsetzung genau zu ändern hat** (Makefile, Ziel `dod`, DevOps
Engineer): Die Schleife bricht bei `gefundene_lage = C` nicht mehr ab, sondern
setzt `gesamt_rc` auf 2, vermerkt Kennung, Ziel und das mit G6 mitgelieferte
fehlende Prüfmittel in einer eigenen Liste und fährt fort; der unmittelbar
folgende Abbruch wegen `rc -ne 0` darf für diesen Schritt nicht greifen, weil
`KLASSIFIZIEREN` bei Lage C mit 1 endet und GNU Make daraus 2 macht. Bei
`A_FAIL`, bei fehlender oder mehrfacher Marke und bei jedem anderen
Rückgabewert ungleich 0 bricht sie unverändert ab. Die gültigen Marken der
übersprungenen C-Schritte zählen für `marken_zaehler` mit — sie sind gültig.

#### 6.12.7 G6 — Die Lage-Marke trägt das fehlende Prüfmittel, nicht der Meldungstext

| | |
|---|---|
| **Vorher galt** | Die Marke lautet `::LAGE <lauf-kennung> <D-Nummer> <ziel> <A_OK\|A_FAIL\|B\|C>[ SCHWELLE=…\|OHNE_SCHWELLE]::` und trägt bei Lage C **nicht**, welches Prüfmittel fehlt. Welches es ist, steht allein in einer Zeile der Form `[Dn ziel] LAGE C: <Text>` auf der Fehlerausgabe |
| **Jetzt gilt** | Die Marke erhält eine **feste Grammatik**, und der Lage-C-Fall trägt das fehlende Prüfmittel darin strukturiert mit: `::LAGE <lauf-kennung> <D-Nummer> <ziel> <Lage>[ FEHLT=<wert>][ SCHWELLE=…\|OHNE_SCHWELLE]::`. Die Reihenfolge der beiden Zusätze ist festgelegt und nicht dem Zufall des Aufrufs überlassen; beide dürfen nebeneinander stehen |

**Optionen.** Entweder das Gate liest die deutsche Meldungszeile und sucht darin
den Pfad, oder die Marke trägt ihn. Der Meldungsweg ist billiger — er kostet
keine Änderung am Makefile —, und er ist falsch:

1. **Er misst einen Text statt eines Gegenstands.** Die 53 C-Zweige des
   Makefiles sind Fliesstext in Deutsch (selbst gezählt: `LAGE C:` kommt
   53-mal vor). Sie werden umformuliert, wenn eine Fortschreibung sie
   umformuliert — und das Gate entschiede beim nächsten Mal anders, ohne dass
   jemand das Gate angefasst hätte. Das ist wörtlich Regel 1 aus 6.2.2, die
   dieser Abschnitt seit dem 2026-08-30 auf jeder Ebene durchsetzt.
2. **Nicht jeder Zweig nennt einen Pfad.** D11 meldet "gitleaks fehlt" — einen
   Programmnamen. Ein Gate, das darin einen Pfad sucht, findet keinen und
   müsste raten.
3. **Die Marke ist der einzige Kanal, den die Kette selbst als vertrauenswürdig
   behandelt.** Sie trägt die Lauf-Kennung, und `make dod` akzeptiert nichts
   sonst. Eine zweite Auswertung neben ihr wäre eine zweite Stelle, an der
   dieselbe Aussage steht — der Fehler aus 6.2.2, 6.9.1 und 6.11.3 b.

**Entscheid: strukturiert.** Der Preis ist benannt und angenommen: 53 Zweige
setzen je eine Shell-Variable.

**Wie die Angabe in die Marke kommt — und weshalb nicht über den vierten
Parameter** *(Runde 1, Präzisierung)*. Die erste Fassung dieses Entscheids
schrieb, die 53 Zweige gäben ihren Wert `KLASSIFIZIEREN` "als vierten Parameter"
mit. Das trägt aus zwei Gründen nicht, und beide sind am Makefile belegt:

1. **Der vierte Parameter ist schon belegt.** D3, D6 und D8 füllen ihn heute
   **statisch** mit `SCHWELLE=<wert>` beziehungsweise `OHNE_SCHWELLE`, und zwar
   unabhängig von der Lage — bei Lage C träfen beide Angaben zusammen, und eine
   von beiden ginge verloren oder ergäbe eine Marke, deren Aufbau vom Schritt
   abhinge.
2. **Ein Make-Parameter ist Expansionszeit, der Wert ist Laufzeit.** Welches
   Prüfmittel fehlt, stellt sich erst im Rezept heraus, in derselben Shell, die
   auch `hat_lage_c` setzt. Ein Wert, den `$(call …)` einsetzt, steht dagegen
   fest, bevor die erste Rezeptzeile läuft.

Deshalb: Jeder Lage-C-Zweig setzt neben `hat_lage_c=1` eine **Shell-Variable zur
Laufzeit** — sie trägt den Pfad oder den Werkzeugnamen —, und `KLASSIFIZIEREN`
hängt daraus im C-Zweig selbst `FEHLT=<wert>` an die Marke an, **vor** dem
Zusatz aus dem vierten Parameter. Der vierte Parameter bleibt unverändert das,
was er heute ist, und wird nicht umgewidmet. Das ist mechanisch, einmalig und
braucht keinen neuen Mechanismus — es braucht nur, dass die Grammatik der Marke
einmal festgeschrieben ist statt sich aus den Aufrufen zu ergeben.

**Fail-closed.** `KLASSIFIZIEREN` setzt bei Lage C `FEHLT=` **immer**; ist die
Variable leer, lautet der Wert `FEHLT=unbenannt`. Ein vergessener Zweig erzeugt
damit eine Marke, die kein Schlüssel der terminierten Lagen treffen kann, und
das Gate blockiert. Ein Zweig, an den niemand gedacht hat, fällt zu und nicht
auf. Das ist dieselbe Richtung, in die alle Wachen dieser Datei fallen.

#### 6.12.8 G7 — Vier eindeutige Schlusszeilen, eine eigenständige D19-Zeile, ein genannter Baum

| | |
|---|---|
| **Vorher galt** | Bei Erfolg endet `make dod` mit `make dod: alle N Kettenschritte durchlaufen (…), keiner ungleich 0, N gueltige Marken gezaehlt, D19: <Befund>.`; bei Abbruch mit `make dod: D19: <Befund>.` und `make dod: abgebrochen, Rueckgabewert N.` Die D19-Aussage steht also in zwei verschiedenen Formen, je nach Ausgang, und der geprüfte Arbeitsbaum wird nirgends genannt. **Runde 1, ergänzt:** Der Befundtext selbst ist ebenfalls frei — fünf verschiedene Texte, darunter **zwei** Schreibweisen für dieselbe Lage C ("Lage C -- git fehlt", "LAGE C, nicht beobachtbar"), und die Lage-B-Zeile beginnt gar nicht mit `D19:`, sondern mit `D19 Lage B --` |
| **Jetzt gilt** | Die D19-Aussage steht **immer** in genau einer eigenständigen Zeile mit **fester Grammatik**. Die Schlusszeile kennt **vier** eindeutige Formen. Eine erste Zeile nennt den geprüften Arbeitsbaum |

*(Überschrift und Zahl sind am 2026-09-02 von drei auf vier nachgeführt; die
vierte Form ist ein **Nachtrag aus dem Bau, 6.12.23**, und ist unten als solche
gekennzeichnet. Die drei ursprünglichen Formen sind unverändert.)*

```
make dod: geprueft wird <PROJ>.
…
make dod: D19: <OHNE_BEFUND|VERLETZT|B|C>[ -- <Text>].
```

Das Schlüsselwort steht unmittelbar hinter `D19:` und ist eines von genau vier;
alles danach ist frei und für das Gate bedeutungslos. Damit bleibt der Text das,
was er sein soll — die Erklärung für den Menschen, einschliesslich der in 6.10.2
und 6.11.3 e zugesagten Angabe, welche Hälfte des Instruments stumm ist und was
die andere in diesem Lauf gemessen hat —, und das Gate misst nicht mehr den
Text. Ohne diese Festlegung müsste es zwei Schreibweisen derselben Lage kennen
und eine Zeile, die anders beginnt als die übrigen; das ist wörtlich Regel 1
aus 6.2.2, nur auf der Ebene der Meldung.

und danach genau eine der vier Formen:

```
make dod: alle <N> Kettenschritte durchlaufen, keiner ungleich 0, <N> gueltige Marken gezaehlt.
make dod: alle <N> Kettenschritte durchlaufen, <k> davon ohne Urteil (Lage C): <Liste>, Rueckgabewert 2.
make dod: abgebrochen bei <D-Nummer> <ziel>, Rueckgabewert <N>.
make dod: alle <N> Kettenschritte durchlaufen, Rahmenpruefung D19 <VERLETZT|C>, Rueckgabewert 2.
```

Die **vierte** Form ist ein *Nachtrag aus dem Bau, 6.12.23*: Sie gilt für den
Lauf, der vollständig, ohne `A_FAIL` und ohne Lage C durchgelaufen ist, in dem
aber D19 einen Befund oder Lage C meldet und der deshalb mit 2 endet. Ohne sie
passte keine der drei ursprünglichen Formen auf diesen Lauf. Welche Form wann
gilt und weshalb daraus die Parse-Regel "Rückgabewert 0 nur mit Form 1" folgt,
steht in 6.12.23 a.

**Weshalb die D19-Zeile aus der Erfolgszeile herausgelöst wird und nicht
zusätzlich dort steht.** Weil sie sonst zweimal stünde. V13: Eine Angabe, die
nichts steuert, sondern etwas anderes wiederholt, wird gestrichen und nicht
nachgeführt. Das Gate liest dann **eine** Form statt zweier, und die zweite
kann nicht veralten.

**Weshalb die mittlere Form gebraucht wird.** Nach G5 läuft die Kette bei Lage C
weiter und endet trotzdem mit 2. Die heutige Zeile "abgebrochen" wäre für
diesen Lauf schlicht unwahr — er ist nicht abgebrochen, er ist vollständig
gelaufen und hat an k Stellen nicht urteilen können. Eine Nachweiszeile, die
zu viel oder das Falsche behauptet, ist derselbe Mangel wie eine fehlende;
dieselbe Überlegung hat in 6.10.2 bereits einmal dazu geführt, eine Meldung auf
die schwächere, richtige Aussage festzulegen, und im Makefile dazu, "beobachtet
und in Ordnung" von "gar nicht beobachtet" zu trennen.

**Weshalb der Baum genannt wird.** Das Gate nennt in jeder Meldung, welchen
Arbeitsbaum es hat prüfen lassen (G12). Diese Angabe ist nur dann ein Nachweis,
wenn sie sich gegen die Kette prüfen lässt, die tatsächlich gelaufen ist —
sonst ist sie eine Behauptung des Gates über einen fremden Prozess. Die Kette
bestimmt ihren Baum selbst und ohne Rückfall (`PROJ` aus `MAKEFILE_LIST`, mit
Hartabbruch statt Rückfall auf das Arbeitsverzeichnis); sie sagt ihn heute nur
nicht. Dass die Bestimmung streng ist, aber ihr Ergebnis unsichtbar bleibt, ist
dieselbe Lücke, die 6.9.1 an D19 beschrieben hat: Es genügt nicht, richtig zu
messen, es muss auch feststehen, was gemessen wurde.

#### 6.12.9 G8 — Frage 3: Wie dreimaliges Scheitern am gleichen Kriterium erkannt wird, und wo gezählt wird

**Wo gezählt wird: ausserhalb des Arbeitsbaums.** Unter
`${XDG_STATE_HOME:-$HOME/.local/state}/r3cosint/dod-gate/`, je Sitzung
(`session_id`) und, wenn vorhanden, je Subagent (`agent_id`) eine Datei. Der
Grund ist zwingend und nicht eine Frage des Geschmacks: Eine Zählerdatei im
Arbeitsbaum wäre eine Datei, die das Gate während des Laufs schreibt, den es
beurteilt — D19 sähe sie, und das Gate erzeugte den Befund, den es meldet. Das
ist der Kettengrundsatz aus 6.1.3, angewandt auf das Gate selbst. *(Nachtrag
6.12.24 c: Sind weder `XDG_STATE_HOME` noch `HOME` gesetzt, ist das Verzeichnis
**nicht bestimmbar**; dieser Zustand wird behandelt wie ein nicht
beschreibbares Verzeichnis und erhält keinen eigenen Ausgang.)*

**Kein Rückkanal.** Das Gate schreibt ausschliesslich lokal und sendet nichts
nach aussen. Das ist keine Selbstverständlichkeit, sondern eine Bauvorschrift
(5.4, CLAUDE.md), und sie gilt für die Werkzeugkette so gut wie für das
Produkt.

**Was gezählt wird: das Kriterium, nicht das Ereignis.** Schlüssel ist die
Klassifizierung aus 6.12.4 — `<D> <ziel> <Lage>`, `D19 <Befund>`, `KETTE
<Grund>` oder `GATE <Prüfmittel>`. Gleicher Schlüssel wie beim letzten Block →
Zähler plus eins; anderer Schlüssel → Zähler auf eins. Ein **Durchlass** löscht
den Zähler; ein Durchlass wegen `stop_hook_active` (G9) und ein Nichtlaufen
wegen fehlender Schreibrechte der Rolle (G13) verändern ihn **nicht** — und
ebenso wenig der Durchlass ab dem vierten Mal nach der Eskalation *(Nachtrag
6.12.24 d)*.

**Weshalb `Stop`- und `TaskCompleted`-Blocks in denselben Zähler laufen.** 3.4
spricht von "derselben Prüfung am gleichen Kriterium", nicht von demselben
Ereignis. Ein Kriterium, das dreimal gescheitert ist, ist dreimal gescheitert,
gleich bei welcher Gelegenheit es geprüft wurde. Ein Subagent zählt dagegen für
sich, weil `agent_id` vorliegt: Er hat eine eigene Aufgabe, ein eigenes
Zugkontingent (`maxTurns`) und einen eigenen Abschlussbericht.

**Was beim dritten Mal geschieht.** Die Blockmeldung benennt das blockierende
Kriterium und verlangt, was 3.3 und 3.4 ohnehin verlangen: die Übergabedatei
unter `docs/uebergaben/`, mit einer vom Gate vorgegebenen, wörtlich zu
übernehmenden Zeile

```
Eskalation 3.4: <Schlüssel>
```

**Ab dem vierten Mal** lässt das Gate durch, wenn eine Datei unterhalb
`docs/uebergaben/` diese Zeile trägt **und** entweder nach `git status` neu
oder geändert ist **oder** im jüngsten Commit (`HEAD`) enthalten ist. Die
zweite Bedingung ist nicht Förmelei: Ohne sie genügte ein Verweis auf eine
beliebige alte Übergabe, und die Eskalation würde zur Formel. *(Runde 1: Die
erste Fassung verlangte allein "neu oder geändert nach `git status`" und
übersah damit den Regelfall — jede bisherige Eskalationsübergabe ist committet
worden, zuletzt `docs/uebergaben/2026-09-01_belegpruefer-abbruch-nach-3-4.md`.
Nach dem Commit wäre die Datei weder neu noch geändert, und der Durchlass
griffe nie. Der Zusatz "im jüngsten Commit enthalten" schliesst die Lücke, ohne
eine beliebige ältere Datei zuzulassen.)* Fehlt die Datei, blockiert das Gate
weiter mit derselben Forderung — die Eskalation ist kein Ausweg aus der
Blockade, sondern der vorgeschriebene Weg aus ihr heraus: abbrechen, Stand
schreiben, dem Auftraggeber vorlegen.

**Der Durchlass nach der Eskalation gilt nur für `Stop` und `SubagentStop`**
*(Runde 1, fehlender Entscheid)*. Für `TaskCompleted` gilt er **nicht**: Dort
blockiert das Gate weiter, auch nach der Eskalation. Der Grund ist die
Bedeutung der beiden Ereignisse. Der Durchlass bei `Stop` ist nötig, damit die
Rolle die Übergabe überhaupt abliefern und den Zug beenden kann — er sagt
nichts über die Aufgabe. Ein Durchlass bei `TaskCompleted` sagte dagegen
genau das Falsche: dass die Aufgabe **erledigt** sei. Sie ist es nicht; sie ist
abgebrochen und liegt dem Auftraggeber vor (3.4). Eine Aufgabe, die dreimal am
gleichen Kriterium gescheitert ist, als abgeschlossen zu markieren, widerspräche
dem Wortlaut des Abnahmekriteriums von R3-Q-001 ebenso wie dem Satz aus
`docs/06_Definition_of_Ready_und_Done.md`, dass ein halbfertiger Zustand nicht als erledigt gilt. Die
Eskalation beendet die Iteration, nicht die Aufgabe.

**Welcher Schlüssel gezählt wird, wenn ein Lauf mehrere Abweichungen zeigt**
*(Runde 1, fehlende Festlegung)*. Seit G5 läuft die Kette bei Lage C weiter;
ein Lauf kann deshalb mehrere ungedeckte Lagen C melden, dazu eine
D19-Abweichung. Gezählt und in der Blockmeldung zuerst genannt wird **die erste
Abweichung in der Reihenfolge der Kette** — also die erste Zeile der Übersicht,
deren Marke `A_FAIL` oder eine ungedeckte Lage C trägt; erst wenn keine solche
Zeile besteht, der D19-Befund. Der Grund ist die Vergleichbarkeit über Läufe
hinweg: Ein Zähler, dessen Schlüssel davon abhinge, welche von mehreren
Abweichungen gerade zufällig ausgewählt wurde, zählte nie dreimal dasselbe
Kriterium und die Eskalation griffe nie. Die übrigen Abweichungen stehen
vollständig in der Meldung — gezählt wird eine, verschwiegen wird keine.

**Was das Gate nicht kann, und wo die Grenze liegt.** Der Zustand liegt in der
Umgebung der Sitzung; in einer Cloud-Sitzung ist `HOME=/root` (Fremdbeleg) und
das Verzeichnis vergänglich. Über **Sitzungsgrenzen hinweg zählt das Gate
nicht.** Das ist keine Lücke, sondern die richtige Reichweite: 3.4 zählt die
Iteration innerhalb einer Arbeitseinheit, und über Arbeitseinheiten hinweg
trägt die Übergabedatei, nicht ein Zähler. Ist das Zustandsverzeichnis nicht
beschreibbar **oder nicht bestimmbar** *(Nachtrag 6.12.24 c)*, urteilt das Gate
unverändert und sagt in der Blockmeldung, dass es nicht zählen kann und weshalb;
die Rolle zählt dann selbst (3.4). Dass sich die
Eskalation dadurch aushebeln liesse, ist benannt und nicht verschwiegen — sie
ist ein Schutz des Kontingents, keine Bauvorschrift nach 5.4.

**Der eine Block, der das Zählwerk zwangsläufig verlässt** *(Nachtrag aus dem
Bau, 6.12.23 c)*. Fehlt `jq`, blockiert das Gate unverändert mit Rückgabewert 2
und dem Schlüssel `GATE jq` (6.12.11) — aber es **zählt diesen Block nicht**,
und es kann es nicht: `session_id` und `agent_id` stehen in der Eingabe-JSON,
die ohne `jq` nicht lesbar ist. Das Gate weiss dann, dass es blockiert, aber
nicht, wofür es den Block anschreiben soll. Dreimaliges Scheitern an `GATE jq`
läuft deshalb nicht in die Eskalation nach 3.4; die Rolle zählt dort selbst,
wie schon im Fall des nicht beschreibbaren Zustandsverzeichnisses. Ein
Ersatzschlüssel wird nicht erfunden — die Begründung steht in 6.12.23 c und
wird hier nicht wiederholt (V13).

#### 6.12.10 G9 — Frage 4: Wie `stop_hook_active` greift

| | |
|---|---|
| **Vorher galt** | "Reentranz-Schutz über `stop_hook_active`" — ohne Ausgang |
| **Jetzt gilt** | Ist `stop_hook_active` wahr, endet das Gate mit **0**, meldet über `systemMessage`, dass es wegen des Reentranz-Schutzes nicht durchgesetzt hat und in welchem Zustand die Kette zuletzt war, und **verändert den Zähler nicht** |

**Weshalb 0 und nicht eine eigene Erfindung.** Der Wortlaut ist an drei Stellen
eindeutig und deckungsgleich: Projektauftrag 3.4, Ebene 4 ("Der Hook muss dann
mit 0 enden und das Beenden zulassen"), `docs/06_Definition_of_Ready_und_Done.md`, Abschnitt "Durchsetzung",
und das Abnahmekriterium `R3-Q-001_gate_blockiert` ("bei gesetztem
`stop_hook_active` endet er mit 0, auch wenn der Prüflauf rot ist"). Auch die
gelesene Referenz begründet es sachlich: "Check this value or process the
transcript to avoid blocking on a condition that will never resolve." Ein
Kriterium, das sich innerhalb der Sitzung nicht erfüllen lässt — und bis zum
Grundgerüst gibt es solche —, blockierte sonst dauerhaft.

**Weshalb der Zähler unberührt bleibt.** Ein Durchlass wegen `stop_hook_active`
ist kein Durchlass wegen eines Ergebnisses. Würde er den Zähler löschen, käme
er nach jedem Block, und der Zähler stünde nie über eins — die Eskalationsregel
aus 3.4 wäre dann nicht bloss schwach, sondern unerreichbar. Würde er ihn
erhöhen, zählte das Gate einen Block, den es nicht ausgesprochen hat. Also
keines von beidem.

**Die Folge, ausgesprochen statt später entdeckt.** Siehe 6.12.2: Ein Stop-Gate
mit diesem Reentranz-Schutz erzwingt je Beendigungsversuch genau eine
Fortsetzung. Es hindert niemanden daran, die Antwort zu beenden; es hindert
daran, sie **ohne Rückmeldung** zu beenden. Die Zusicherung, dass eine Aufgabe
bei roter Kette nicht abschliessbar ist, trägt `TaskCompleted` — dort greift
der Reentranz-Schutz nicht, weil die gelesene Referenz das Feld für dieses
Ereignis nicht führt. Wer diesen Entwurf beurteilt, muss beides zusammen sehen:
Der Reentranz-Schutz ist gewollt schwach, und er ist nicht die Stelle, an der
die Zusicherung hängt.

#### 6.12.11 G10 — Die Prüfmittel des Gates, und was bei deren Ausfall geschieht

V12 verlangt: Nennt ein Text ein Prüfmittel, dessen Ausfall eine Wirkung haben
soll, muss der Code genau dieses Prüfmittel prüfen. Deshalb hier abschliessend
und namentlich, was das Gate braucht:

| Prüfmittel | Wofür | Fehlt es |
|---|---|---|
| `jq` | Lesen der Eingabe-JSON von der Standardeingabe | Lage C des Gates, Rückgabewert 2 |
| `git` | Bestimmung des geprüften Arbeitsbaums; Prüfung der Übergabedatei bei der Eskalation | Lage C des Gates, Rückgabewert 2 |
| GNU Make und das `Makefile` im bestimmten Baum | Der eine Einstieg (`make dod`) | Lage C des Gates, Rückgabewert 2 |
| `.claude/hooks/dod-gate-terminierte-lagen.txt` | Entscheidung über eine gemeldete Lage C | Lage C des Gates, Rückgabewert 2 — eine fehlende Liste liesse jede terminierte Lage stumm wegfallen und machte das Gate dauerhaft rot, ohne zu sagen weshalb. Eine **vorhandene, leere** Liste ist dagegen ein zulässiger Zustand: es gibt dann keine terminierten Lagen. Das ist wörtlich die Unterscheidung, die 6.11.2 für `scripts/belege-ausnahmen.txt` getroffen hat |
| `timeout` (coreutils) | Rückgewinnung der Kontrolle vor der Zeitgrenze des Harness (G11) | Lage C des Gates, Rückgabewert 2 |
| `flock` (util-linux) | Serialisierung der eigenen Läufe (G12) | Lage C des Gates, Rückgabewert 2 |
| `sha256sum` (coreutils) *(Nachtrag 6.12.24 g)* | Bildung der Namen von Sperr- und Zählerdatei aus dem Pfad des geprüften Baums (G8, G12) | Lage C des Gates, Rückgabewert 2, Schlüssel `GATE sha256sum` |
| `mktemp` (coreutils) *(Nachtrag 6.12.24 g)* | Die Wegwerfdatei, in der die Ausgabe der Kette ausserhalb des geprüften Baums abgefangen wird (G14) | Lage C des Gates, Rückgabewert 2, Schlüssel `GATE mktemp` |
| Ein beschreibbares Zustandsverzeichnis | **Nur** das Zählwerk (G8) | **Kein** eigener Ausgang: das Gate urteilt unverändert und nennt **in jeder Meldung**, dass es nicht zählen kann; bei sauberem Grün ist das seine einzige Meldung *(Nachtrag 6.12.24 c: ein **nicht bestimmbares** Verzeichnis wird gleich behandelt; Nachtrag 6.12.24 e: die Sperre aus G12 weicht dann auf `/tmp` aus und entfällt nicht still)* |

**Die Präzedenz.** `.claude/hooks/block-main-write.sh` und
`block-prototype-import.sh` blockieren mit einer Meldung, wenn `jq` fehlt,
statt stillschweigend durchzulassen; CLAUDE.md führt das unter "Aktive Gates"
ausdrücklich. Das Gate aus R3-Q-001 verhält sich genauso, und zwar für alle
sechs blockierenden Prüfmittel: Jede Meldung nennt das fehlende Mittel **und
den Beschaffungsweg**, wie es die Lage-C-Zweige des Makefiles ebenfalls tun.

*(Nachtrag 6.12.24 g: Die Zahl "sechs" in diesem Absatz ist der Stand vor der
Verifikation vom 2026-09-02 und wird nicht umgeschrieben. Massgeblich ist nach
Regel 2 aus 6.2.2 die Tabelle darüber; sie führt seit diesem Nachtrag **acht**
blockierende Prüfmittel und neun insgesamt. Der Satz über Meldung und
Beschaffungsweg gilt unverändert für alle.)*

**Die eine Ausnahme, und weshalb sie eine ist.** Das Zustandsverzeichnis trägt
nicht das Urteil, sondern nur die Zählung. Wäre sein Fehlen ein blockierender
Ausgang, würde ein Gate, das nicht schreiben darf, auch bei grüner Kette
blockieren — ein Gate, das nichts mehr durchlässt. Die Zählung ist ausserdem
kein Schutz nach 5.4, sondern ein Schutz des Kontingents (3.3, 3.4). Die
Unterscheidung ist dieselbe wie bei D20 und dem zweiten Arbeitsbaum in 6.8.3:
Was den Gegenstand betrifft, ist Lage C; was nur die Vollständigkeit der
Meldung betrifft, gehört in die Meldung.

#### 6.12.12 G11 — Zeitüberschreitung: zwei Grenzen, und weshalb die innere die kleinere ist

**Der Befund aus der gelesenen Referenz.** "Claude Code cancels a `command` …
hook that reaches its `timeout`, discarding the hook's output, so on most events
a timed-out hook renders no decision." Ein Gate, das seine Zeitgrenze reisst,
**lässt also durch** — lautlos und ohne Ausgabe. Für ein Gate ist das der
schlechteste aller Ausgänge, und er tritt genau dann ein, wenn die Kette lange
läuft, also wenn viel gebaut und getestet wurde.

| | |
|---|---|
| **Vorher galt** | Nichts. Weder dieser ADR noch `docs/06_Definition_of_Ready_und_Done.md` nennen eine Zeitgrenze für die Gates |
| **Jetzt gilt** | Zwei Grenzen, und die innere ist die kleinere: `timeout: 900` je Hook-Eintrag in `.claude/settings.json`; im Skript läuft `make dod` unter `timeout` (coreutils) mit **600 s**; die Wartezeit auf die Sperre aus G12 beträgt **120 s** |

**Weshalb 600 s innen.** Die gelesene Referenz nennt 600 s als Vorgabewert für
`command`-Hooks — das ist die Dauer, die der Harness selbst für normal hält,
und damit keine erfundene Zahl. Der heute gemessene Lauf dauert 5,8 s
(Fremdbeleg); mit dem Grundgerüst kommen Bau, Containerbau, Testsuite,
Abdeckung und durchgehende Oberflächenläufe hinzu, und die Grössenordnung
wechselt von Sekunden zu Minuten.

**Weshalb 900 s aussen.** 600 s für die Kette, 120 s Wartezeit auf die Sperre
und die eigene Arbeit des Gates ergeben höchstens rund 720 s; 900 s lassen
180 s Reserve. Die äussere Grenze ist ausdrücklich **kein** zweiter Massstab,
sondern eine Notbremse: Erreicht wird sie nur, wenn das Skript selbst hängt.

**Was bei der inneren Grenze geschieht.** Das Gate beendet den Lauf (mit
Nachlauffrist, damit kein `make` im Hintergrund weiterläuft) und endet mit 2:
`KETTE zeitueberschreitung`. Es behauptet dabei nichts über den Arbeitsbaum —
die Nachher-Aufnahme von D19 hat nicht stattgefunden, und ein abgebrochener
Lauf hat kein Urteil gefällt. "Nicht nachweisbar gelaufen" ist die richtige und
die einzige belegte Aussage.

**Was offen bleibt, und weshalb es hier steht statt vermutet zu werden.** Ob
600 s für die Kette mit dem Grundgerüst reichen, ist nicht gemessen. Reichen sie
nicht, wäre das Gate regelmässig falsch rot — und ein regelmässig falsch rotes
Gate wird entfernt. Deshalb: **O-20**, mit einem ausgeführten Lauf zu
beantworten, sobald `backend/` und `deploy/` bestehen. Ergibt die Messung, dass
die Kette länger braucht, werden **beide** Werte als Fortschreibung angehoben —
das innere Limit wird nicht stillschweigend entfernt. Ein Gate ohne innere
Grenze ist ein Gate, das bei langem Lauf durchlässt.

#### 6.12.13 G12 — Welcher Arbeitsbaum geprüft wird, und was bei Nebenläufigkeit gilt

**Der geprüfte Baum wird bestimmt, nicht geraten.** Die gelesene Referenz sagt
zu Arbeitsbäumen: `${CLAUDE_PROJECT_DIR}` "still points at the project root
where the session started", während das Eingabefeld `cwd` "is the worktree root
after Claude enters a worktree". Beides zugleich zu nehmen geht nicht; eines
von beiden blind zu nehmen, hiesse in einem der beiden Fälle den falschen Baum
zu prüfen.

| | |
|---|---|
| **Vorher galt** | Nichts; `block-main-write.sh` nimmt `${CLAUDE_PROJECT_DIR:-$PWD}` und benennt im Kopf, dass ein zweiter Arbeitsbaum ausserhalb der Sitzung nicht erfasst ist |
| **Jetzt gilt** | Das Gate prüft den Arbeitsbaum, in dem `cwd` liegt, **sofern dieser zu demselben Repository gehört** wie `${CLAUDE_PROJECT_DIR}` — festgestellt über die Versionsverwaltung (das gemeinsame Git-Verzeichnis), nicht über einen Verzeichnisnamen. Sonst gilt `${CLAUDE_PROJECT_DIR}`. Der geprüfte Baum steht in **jeder** Meldung des Gates, blockierend wie durchlassend. *(Nachtrag 6.12.24 a: Bestimmt wird in beiden Fällen die **Wurzel** des Arbeitsbaums, und zwar **physisch aufgelöst** — sonst vergleicht das Gate seine Angabe mit der Baumzeile der Kette, die aus `pwd -P` stammt, und misst eine Schreibweise statt eines Baums.)* |

**Weshalb nicht einfach `${CLAUDE_PROJECT_DIR}`.** Weil CLAUDE.md den Betrieb
auf einem Arbeitszweig vorschreibt und ein zweiter Arbeitsbaum damit eine
naheliegende Arbeitsform ist — das steht bereits als Begründung im Makefile bei
D19 und in 6.9.3. Arbeitet Claude in einem Arbeitsbaum und prüfte das Gate die
Sitzungswurzel, meldete es Grün über einen Stand, den niemand angesehen hat.
Genau dieser Fehler ist an dieser Datei schon einmal blockierend aufgetreten:
Die dritte Fassung der `PROJ`-Bestimmung fiel auf das Arbeitsverzeichnis zurück
und prüfte belegt ein fremdes Repository, während der Lauf wie eine reguläre
Prüfung aussah. V10 sagt dazu: Was sich schliessen lässt, wird geschlossen; und
das hier lässt sich mit `git` schliessen.

**Weshalb kein Urteil über ein fremdes Repository.** Liegt `cwd` ausserhalb
jedes Arbeitsbaums dieses Repositories — etwa im Methodik-Repository —, prüft
das Gate die Sitzungswurzel und sagt das. Es prüft **nie** ein Repository, für
das es nicht eingerichtet ist. Auch das ist aus der `PROJ`-Geschichte
übernommen: lieber kein Urteil als ein Urteil über das falsche Verzeichnis.

**Serialisierung der eigenen Läufe.** In dieser Sitzung laufen Subagenten
parallel und schreiben Dateien (Fremdbeleg); die gelesene Referenz sagt zudem,
dass mehrere Hooks desselben Ereignisses parallel laufen. Zwei gleichzeitige
`make dod` gegen denselben Baum stören einander über D19. Das Gate nimmt
deshalb vor dem Lauf eine Sperre (`flock`) mit 120 s Wartezeit; läuft sie ab,
endet es mit 2 und sagt, dass ein anderer Lauf die Sperre hält. **Die
Sperrdatei liegt im Zustandsverzeichnis, nicht im Arbeitsbaum** — eine
Sperrdatei im Baum wäre eine Datei, die während des Laufs entsteht und
vergeht, und D19 sähe sie. Sie ist an den Pfad des geprüften Baums gebunden,
nicht an die Sitzung, damit sie auch zwischen Sitzungen wirkt. *(Nachtrag
6.12.24 e: Ist das Zustandsverzeichnis nicht beschreibbar oder nicht
bestimmbar, liegt die Sperrdatei mit demselben Namen fest unter `/tmp`; geht
auch das nicht, läuft das Gate **ohne** Sperre und sagt das in jeder Meldung.)*

**Die Grenze, die bleibt.** Ein **fremder** Schreiber — ein anderer Subagent,
der während des Laufs eine Datei ändert — lässt sich damit nicht anhalten. D19
meldet dann `VERLETZT`, obwohl kein Kettenschritt geschrieben hat, und das Gate
kann die beiden Ursachen nicht unterscheiden. Entschieden wird: **`VERLETZT`
blockiert immer.** Die Meldung nennt beide möglichen Ursachen und verlangt, den
Lauf zu wiederholen, wenn sonst nichts läuft. Das Gate erklärt einen Befund
nicht weg — es ist nicht die Stelle, an der entschieden wird, ob eine
Beobachtung zählt. Bleibt der Befund dreimal, greift die Eskalation aus G8, und
das ist der richtige Ausgang: Ein Problem, das sich nicht von innen lösen lässt,
gehört vorgelegt (3.4).

#### 6.12.14 G13 — `SubagentStop` und Rollen, die den Arbeitsbaum nicht ändern können

**Das Problem.** Static Software Tester und Pentester haben weder `Edit` noch
`Write`. Ein Block verlangte von ihnen eine Behebung, die sie nicht leisten
können, und veränderte zugleich ihren Abschlussbericht — die letzte Nachricht
eines Subagenten ist sein Arbeitsergebnis, und der aufrufende Kontext liest sie.
Beim Prüfer wiegt das doppelt: **Seine Aufgabe ist es, den roten Befund zu
melden.** Ein Gate, das ihn wegen desselben roten Befunds am Abliefern hindert,
macht die Meldung des Befunds unmöglich.

| Option | Bewertung |
|---|---|
| (i) Das Gate gilt für alle Subagenten gleich | Abgelehnt, aus dem Grund oben. Es blockierte am zuverlässigsten die Rollen, die es am wenigsten angeht |
| (ii) Das Gate liest das `tools:`-Feld der Rollendatei und behandelt Rollen ohne Schreibwerkzeug gesondert | Gewählt. Es misst den **Gegenstand** — hat diese Rolle das Recht, den Baum zu ändern? — statt eines Namens. Das ist Regel 1 aus 6.2.2 |
| (iii) Ein Matcher in `settings.json` | Abgelehnt. Eine zweite Kopie der Rechtetabelle aus ADR 0001, die mit der ersten Rollenänderung veraltet, ohne dass es auffällt (V13) |

**Entscheid: (ii), und das Gate läuft für diese Rollen gar nicht erst.** Es
bestimmt zuerst die Rolle; enthält deren `tools:`-Feld **keines von `Edit`,
`Write` und `NotebookEdit`**, endet es mit 0 und meldet über `systemMessage`,
dass es die Kette für diese Rolle nicht hat laufen lassen und weshalb. `make
dod` läuft dann nicht — das spart bis zu 600 s je Abschluss eines
Prüf-Subagenten und, wichtiger, es vermeidet eine Aussage über einen
Kettenzustand, den diese Rolle weder verursacht hat noch beheben kann.

**`Bash` zählt nicht dazu — ein blockierender Befund aus Runde 1, hier
entschieden.** Die erste Fassung führte `Bash` unter den verändernden
Werkzeugen. Gemessen über alle 21 Rollendateien tragen `static-software-tester`
und `pentester` genau `tools: Read, Grep, Glob, Bash, Skill` — also `Bash`,
aber weder `Edit` noch `Write`. Mit `Bash` im Kriterium liefe das Gate
ausgerechnet für die beiden Rollen, für die G13 gemacht ist; der Entwurf hätte
sich selbst aufgehoben. Massgeblich ist deshalb die Menge der Werkzeuge, über
die **ADR 0001 Schreibrecht vergibt**: `Edit`, `Write`, `NotebookEdit`.

**Die Grenze dieses Kriteriums, ausgesprochen statt überdeckt.** `Bash` **kann**
schreiben — mit `sed -i`, mit einer Umleitung, mit einem Interpreteraufruf; das
Gate `block-main-write.sh` behandelt genau diese Wege in seinem
Bash-Zweig. Eine Rolle mit `Bash` und ohne `Edit`/`Write` **darf** also nicht
schreiben, **könnte** es aber. Das Kriterium misst damit das Recht, nicht die
Fähigkeit, und das ist eine bewusste Wahl mit zwei Gründen: Erstens ist das
Recht das, worüber ADR 0001 verfügt und worüber sich die Rolle Rechenschaft
schuldet; zweitens ist die Fähigkeit ohnehin nicht die Frage, die G13 stellt —
ein Prüfer, der unter Umgehung seines Rechts geschrieben hätte, hat ein
grösseres Problem als eine ungelaufene Kette. Die **harte** Durchsetzung der
Schreibgrenzen ist R3-Q-005 und bleibt es; dieses Gate ersetzt sie nicht und
gibt nicht vor, es zu tun. Solange R3-Q-005 nicht steht, bleibt der Fall
"Prüfer schreibt über `Bash`" durch nichts abgefangen — das ist eine benannte
Lücke des Rollenmodells, nicht eine, die dieser Entwurf einführt.

**Woran das Gate die Rolle erkennt: am Frontmatter, nicht am Dateinamen**
*(Runde 1)*. Die gelesene Referenz sagt zu `agent_type` im Abschnitt
`SubagentStart`, auf den der `SubagentStop`-Abschnitt für die Werte verweist:
"For custom subagents, this is the `name` field from the agent's frontmatter,
not the filename." Die erste Fassung dieses Entwurfs las
`.claude/agents/<agent_type>.md` und setzte damit stillschweigend Dateiname
gleich `name` voraus. Dass beides heute in allen 21 Rollendateien
übereinstimmt (selbst gemessen), macht die Annahme nicht richtig — sie wäre
beim ersten Auseinanderfallen still falsch, und das ist derselbe Fehler, den
6.2.2 als Regel 1 verbietet: ein Name statt des Gegenstands. Das Gate löst
`agent_type` deshalb über das Frontmatter-Feld `name:` **aller** Dateien unter
`.claude/agents/` auf und nimmt den eindeutigen Treffer.

**Fail-closed in jeder Unklarheit.** Findet die Auflösung keinen oder mehr als
einen Treffer — auch bei einer eingebauten Rolle wie `Explore` oder bei einem
plugin-bezogenen Namen mit Doppelpunkt, den die Referenz ausdrücklich nennt —,
so behandelt das Gate die Rolle als **schreibberechtigt** und läuft. Eine
unbekannte Rolle ist keine bekannte Ausnahme. Ist `agent_type` leer oder trägt
er Zeichen, die in einem Frontmatter-Namen nicht vorkommen können, gilt
dasselbe. Der Zähler wird in allen diesen Fällen nicht verändert (G8).

#### 6.12.15 G14 — Sichtbarkeit: was gemeldet wird, wohin, und was nicht

**Der Befund aus der gelesenen Referenz.** Bei Rückgabewert 0 geht die
Standardausgabe eines Hooks "to the debug log and doesn't show it in the
transcript"; die Fehlerausgabe bei 0 geht ebenfalls nur ins Debug-Protokoll und
"Claude never sees it". Ein Durchlass ist also **stumm** — und ein Durchlass
mit terminierten Lagen C wäre damit ein Negativbefund, den niemand sieht. Nach
5.3 sind Negativbefunde zwingend Teil der Spur; das ist der Gedanke, der hier
sinngemäss trägt.

| | |
|---|---|
| **Jetzt gilt** | Bei jedem Durchlass, der **kein sauberes Grün** ist, gibt das Gate auf der Standardausgabe genau ein JSON-Objekt mit dem Feld `systemMessage` aus. Bei sauberem Grün gibt es nichts aus. Beim Blockieren geht der Grund auf die Fehlerausgabe, und die Standardausgabe bleibt leer |

Drei Fälle sind kein sauberes Grün und melden sich deshalb: der Durchlass mit
terminierten Lagen C (die Meldung nennt, **welche** Schritte nicht geurteilt
haben und welches Prüfmittel ihnen fehlt), der Durchlass wegen
`stop_hook_active` (G9) und das Nichtlaufen für eine Rolle ohne veränderndes
Werkzeug (G13). *(Nachtrag 6.12.24 c und e: Ein **vierter** Fall kommt hinzu —
ein ausgefallenes Zählwerk oder eine ausgefallene Sperre. Auch dann meldet sich
das Gate; ist die Kette im Übrigen sauber grün, ist das seine einzige Meldung.
Der Grundsatz bleibt unverändert: Geschwiegen wird nur, wenn es nichts zu
melden gibt.)*

**Weshalb bei sauberem Grün Schweigen richtig ist.** Weil dann nichts zu melden
ist und jede zusätzliche Zeile Rauschen wäre, das die drei Fälle oben
unsichtbar machte. Das Gate ist auch nicht der Ort der Nachweisführung: Der
Nachweis eines grünen Laufs entsteht dort, wo `make dod` geführt und sein
Ergebnis festgehalten wird (D12, 6.6), nicht in einer Meldung an den Bildschirm.

**Zwei Dinge, die das Gate ausdrücklich nicht tut.**

- **Kein `continue: false`.** Die gelesene Referenz beschreibt das Feld als "If
  `false`, Claude stops processing entirely after the hook runs". Das nimmt dem
  Menschen die Entscheidung aus der Hand und geht über das hinaus, was 3.4
  Ebene 2 verlangt: blockieren und begründen, damit weitergearbeitet wird. Ein
  Gate, das die Sitzung beendet, ist kein Gate, sondern ein Abbruch.
- **Kein eigenes Protokoll.** Das Gate führt keine dritte Spur neben
  Ermittlungs- und Arbeitsspur (5.3) und kein Laufprotokoll. Eine Spur ohne
  Leser wächst, veraltet und wird zur Ausrede; die Zählerdatei aus G8 ist der
  gesamte Zustand, den das Gate führt.

**Die Form der Ausgabe ist eine Bedingung, keine Empfehlung.** Die gelesene
Referenz sagt: "Your hook's stdout must contain only the JSON object", und sie
beschreibt, dass eine Ausgabe, die mit einer geschweiften Klammer beginnt und
endet, als JSON gelesen wird — schlägt das fehl, entsteht eine sichtbare
Fehlermeldung, und auf manchen Ereignissen wird der Text verworfen. Daraus
folgt zwingend: **Die Ausgabe von `make dod` darf niemals auf die
Standardausgabe des Gates gelangen.** Das Gate fängt Standard- und
Fehlerausgabe der Kette gemeinsam ab und wertet sie aus; auf die eigene
Standardausgabe geht ausschliesslich das JSON-Objekt oder nichts. *(Nachtrag
6.12.24 f: Die Wegwerfdatei, in der das Gate die Ausgabe abfängt, liegt
nachweislich **ausserhalb** des geprüften Baums — sonst erzeugte das Gate den
D19-Befund, den es meldet.)* Die
Referenz begrenzt Ausgabezeichenketten zudem auf 10 000 Zeichen und nennt dabei
`systemMessage` ausdrücklich; über die Fehlerausgabe sagt sie dazu nichts.
Deshalb gilt für beide Wege dieselbe Bauvorschrift: **Die Meldung des Gates ist
kurz und nennt den Schlüssel, den Schritt, das fehlende Prüfmittel und den
nächsten Schritt — sie reicht nicht die ganze Ausgabe der Kette durch.** Wer
den vollen Lauf sehen will, ruft `make dod` selbst auf; das ist ohnehin der
Weg, auf dem er zum Nachweis wird.

#### 6.12.16 G15 — Kein Zwischenspeicher des Urteils

Naheliegend wäre, das Urteil zwischenzuspeichern und die Kette nur laufen zu
lassen, wenn sich der Arbeitsbaum seit dem letzten Lauf geändert hat. Das wird
**abgelehnt**, aus drei Gründen:

1. **Das Urteil ist nicht allein eine Funktion des Arbeitsbaums.** D8 fragt eine
   Schwachstellendatenbank ab, Werkzeuge werden installiert und entfernt,
   `gitleaks` kann heute fehlen und morgen da sein. Ein gespeichertes Urteil
   wäre ein Urteil über einen vergangenen Lauf, ausgegeben als Aussage über den
   gegenwärtigen.
2. **Es wäre ein zweites Messmittel an derselben Sache.** Um zu erkennen, ob
   sich der Baum geändert hat, müsste das Gate genau das messen, was D19 misst
   — und dann stünde dieselbe Messung an zwei Stellen. Das ist das Muster aus
   6.9.1, das dieser Abschnitt bereits dreimal aufgelöst hat.
3. **V9.** Steht eine Abwägung zwischen Laufzeit und Beweiskraft, entscheidet
   die Beweiskraft.

**Der Preis ist benannt.** Das Gate lässt die Kette bei jedem Beendigungsversuch
und bei jedem Abschlussversuch laufen. Heute kostet das 5,8 s (Fremdbeleg); mit
dem Grundgerüst wird es mehr. Wird es untragbar, ist das eine Fortschreibung
dieses Abschnitts mit einem gemessenen Lauf als Grundlage — etwa dahin, dass
das Gate auf `Stop` nur läuft, wenn seit dem letzten Lauf geschrieben wurde —,
und nicht eine stille Optimierung im Skript. Die Messung ist Teil von O-20.

#### 6.12.17 G16 — Der flache Klon: die Vollständigkeit der Historie wird Prüfmittel von D20

**Der Befund** (Fremdbeleg, 2026-09-02): Der Klon der Sitzung war flach
(`git rev-parse --is-shallow-repository` meldet wahr, 92 Commits sichtbar). In
diesem Zustand meldete D20 **31 Funde**, davon 30 der Art `commit` —
Commit-Prüfsummen, die in `docs/NACHWEISE.md` stehen und lokal als Objekt
fehlen —, und `make dod` endete mit `D20 belege A_FAIL`. Nach `git fetch
--unshallow` (98 Commits) blieb **ein** Fund.

**Weshalb das entschieden werden muss.** Cloud-Sitzungen klonen flach. Das Gate
liefe dort ab seiner Einführung gegen 30 Scheinfunde und blockierte jede
Arbeitseinheit — mit einer Begründung, die nicht stimmt. Das ist **wörtlich der
Fehlermodus aus 6.11.1**: rot, aber mit falscher Begründung, weil ein
Prüfmittel ausgefallen ist und niemand danach fragt. Und es ist die vierte
Wiederholung derselben Fehlerklasse, die V12 beschreibt: Der Belegprüfer prüft
Commit-Prüfsummen gegen die lokale Historie und behandelt eine unvollständige
Historie als vollständige.

| | |
|---|---|
| **Vorher galt** | Prüfmittel von D20 sind `scripts/belege-pruefen.sh` und `scripts/belege-ausnahmen.txt`, `bash`, `git`, `grep`, `sed`, `awk` sowie die beiden Bezugsdokumente. Von der **Vollständigkeit** der Historie stand nichts — weder in der Objekttabelle noch im Ziel `belege` noch im Skript |
| **Jetzt gilt** | Die Prüfmittelspalte der D20-Zeile trägt zusätzlich: **eine vollständige Git-Historie.** Ist der Klon flach, trägt die lokale Historie die Aussage über Commit-Prüfsummen nicht; das ist **Lage C** nach der geschärften Bedingung aus 6.9.2 — das Prüfmittel ist vorhanden und trägt die Aussage nicht. Der Beschaffungsweg lautet `git fetch --unshallow` und gehört in die Meldung |

**Wo geprüft wird.** Im Makefile-Ziel `belege`, in dessen Wächter-Block, der
seit der elften Fortschreibung ohnehin `git`, den Arbeitsbaum und die drei
Dateien vor jeder Verwendung prüft. Dort entsteht die Lage-Marke, und dort
gehört die Prüfung hin; das Skript bleibt unverändert. Eine zweite Prüfung an
zweiter Stelle wäre wieder dieselbe Aussage an zwei Orten.

**Und wo es geschrieben steht** *(Runde 1)*. Die erste Fassung dieses
Unterabschnitts sagte, die Prüfmittelspalte der D20-Zeile trage die
Vollständigkeit der Historie "jetzt" — die **Objekttabelle in Abschnitt 6**
enthielt das Wort aber nicht. Nach Regel 2 aus 6.2.2 ist diese Tabelle die eine
massgebliche Stelle, und frühere Fortschreibungen haben ihre Zeilen deshalb
selbst geändert statt nur über sie zu schreiben; die D20-Zeile trägt sichtbar
den Vermerk der achten Fortschreibung. Die Zeile ist jetzt nachgeführt und
trägt den Zusatz samt Entwurfsvorbehalt. Bemerkenswert an diesem Befund ist,
dass er dieselbe Fehlerklasse zeigt, gegen die dieser Abschnitt seit dem
2026-08-30 arbeitet — eine Festlegung, die an einer Stelle steht und an der
massgeblichen nicht.

**Weshalb nicht terminierbar.** Ein flacher Klon ist kein Artefakt, das noch
entsteht, sondern ein Zustand, der sich mit einem Befehl beheben lässt; und
Prüfmittel von D20 sind nach G4 grundsätzlich nicht terminierbar. Das Gate
blockiert in einer frisch geklonten Cloud-Sitzung also so lange, bis die
Historie vollständig ist — mit einer Meldung, die den einen nötigen Befehl
nennt. Das ist unbequem und richtig: Die Alternative wäre, eine Kette laufen zu
lassen, die über Herkunftsangaben urteilt, ohne die Herkunft sehen zu können.

**Der Nebenbefund, hier nur verzeichnet.** In jedem frischen Klon bleibt ein
Fund auf `origin/main`
(`405ebada79a145ac537d8e4102ce46d029046475`): Eine Übergabedatei nennt den Pfad
eines **lokalen** Zweig-Refs als Beleg, und ein lokaler Ref existiert nur auf
dem Arbeitsplatz, auf dem der Zweig ausgecheckt war. Übergaben belegen einen
vergangenen Stand und werden nicht geändert (Abschnitt 9). Der ortsgebundene
Ausnahmeeintrag dafür ist Umsetzung nach 6.8.5 und **kein** Architekturentscheid;
diese Fortschreibung legt ihn nicht an. Für den Entwurf zählt allein die
Feststellung: Das Gate trifft auf einen Bestand, in dem die erste Abweichung
ein `A_FAIL` sein kann, dessen Ursache die Umgebung ist — und genau deshalb
steht die Klassifizierung aus 6.12.4 am Anfang dieses Entwurfs und nicht am
Ende.

#### 6.12.18 Was ein Durchlass des Gates aussagt — und was nicht

Der Kettengrundsatz aus 6.8.4 gilt für das Gate unverändert und eine Ebene
höher:

> **Ein Durchlass des Gates heisst: `make dod` ist in dem genannten
> Arbeitsbaum nachweisbar gelaufen und hat nichts von dem gefunden, was die
> Kette sucht — bei terminierten Lagen C mit Ausnahme der genannten Schritte,
> die nicht geurteilt haben. Er heisst nie: die Arbeit ist richtig.** Die
> menschlich bestätigten Bedingungen D13 bis D17 stehen genau deshalb daneben
> und werden durch keinen Durchlass ersetzt.

Dazu vier Aussagen, die ein Durchlass **nicht** trägt und die deshalb hier
stehen:

1. Nichts über einen anderen Arbeitsbaum als den genannten (G12).
2. Nichts, wenn er wegen `stop_hook_active` erfolgte (G9) — dort hat das Gate
   überhaupt nicht durchgesetzt, es hat nur nicht blockiert.
3. Nichts über die Arbeit einer Rolle, für die er wegen fehlender verändernder
   Werkzeuge erfolgte (G13).
4. **Nichts, was D20 nicht selbst trägt.** Das Gate stützt sich auf die ganze
   Kette und damit auch auf D20, und D20s Werkzeug ist nach Eskalationsregel
   3.4 abgebrochen und **nicht abgenommen** (O-15); seine Selbstauskunft erklärt
   die Liste ihrer Grenzen ausdrücklich für unvollständig. Der Auftraggeber hat
   verlangt, das hier ausdrücklich festzuhalten, und die Feststellung wiegt seit
   dem 2026-09-02 schwerer als am 2026-09-01: Mit dem flachen Klon (G16) und dem
   Fund auf `origin/main` ist nun **belegt**, dass D20 rote Läufe erzeugt, deren
   Ursache die Umgebung ist. Die Aufnahme in die Kette hängt weiterhin nicht an
   der Abnahme — ein Schritt, der nur Funde hinzufügt, macht die Aussage der
   Kette nie schwächer —, aber ein Gate, das jede Arbeitseinheit an dieses
   Werkzeug bindet, macht seine Abnahme dringender. O-15 bleibt offen, mit
   unverändertem Termin vor der Freigabe des Grundgerüsts.
5. **Nichts über eine Sitzung, in der `TaskCompleted` nie feuert** *(Runde 1)*.
   Das Ereignis setzt nach der gelesenen Referenz voraus, dass eine Aufgabe über
   das Aufgabenwerkzeug abgeschlossen wird oder ein Mitglied eines Teams seinen
   Zug mit offenen Aufgaben beendet. Wird in einer Sitzung keine Aufgabenliste
   geführt, bleiben allein `Stop` und `SubagentStop` — und die leisten je
   Beendigungsversuch eine erzwungene Fortsetzung, nicht mehr (6.12.2). Ein
   Durchlass sagt dann nur, dass in diesem Augenblick nichts gefunden wurde, und
   die Aussage "die Aufgabe war nicht abschliessbar" hat in einer solchen
   Sitzung überhaupt keinen Träger. Welcher der beiden Wege beschritten wird,
   entscheidet der Auftraggeber (O-23); bis dahin ist dieser Satz die ehrliche
   Reichweite des Entwurfs.

**Zwei Berichtigungen an dieser Datei.**

**Erstens, die Kopfzeile.** Beim Nachführen ist aufgefallen, dass sie die
**elfte** Fortschreibung vom 2026-09-01 nicht führt — sie endete bei der
zehnten. Die Lücke ist am 2026-09-02 geschlossen und als Nachtrag
gekennzeichnet; der Abschnitt 6.11 selbst blieb unverändert.

**Zweitens, die Tabelle der offenen Punkte in Abschnitt 8 — eine Formberichtigung
ohne Inhaltsänderung** *(Runde 2 der Prüfung, 2026-09-02)*. Seit O-11 standen
zwischen den Zeilen jener Tabelle Leerzeilen: zwischen O-10 (neu gefasst) und
O-11, vor O-13, vor O-14, vor O-16 und, mit den neuen Punkten dieser
Fortschreibung, vor O-19 bis O-23. Eine Leerzeile beendet in Markdown die
Tabelle; die betroffenen Zeilen wurden deshalb nicht als Tabellenzeilen
dargestellt, sondern als einzelne Textfragmente ohne Kopfzeile — die Spalten
"Warum heute nicht entscheidbar", "Wer entscheidet" und "Spätestens" waren dort
für einen Leser nicht mehr als Spalten erkennbar. Alle Leerzeilen innerhalb der
Tabelle sind geschlossen; **kein Wort einer Zeile ist geändert, keine Zeile
gelöscht, keine hinzugefügt.** Das ist genau der Schaden, gegen den der als
O-22 eingeordnete Struktur- und Tabellenprüfer gebaut werden soll, und er ist
hier am eigenen Dokument eingetreten, bevor das Werkzeug besteht — ein Beleg
für O-22, den niemand herstellen musste.

Beide Male gilt derselbe Vorgang wie in 6.11.5: Eine Berichtigung wird vermerkt,
nicht stillschweigend vorgenommen, und die frühere Fassung wird nicht gelöscht.

#### 6.12.19 G17 — Was der Selbsttest zu decken hat

`.claude/rules/claude-konfiguration.md` verlangt: "Jedes Hook-Skript wird vor
dem Einbau gegen einen blockierenden und einen durchzulassenden Fall geprüft.
Ein ungetestetes Gate ist kein Gate." Das Abnahmekriterium
`R3-Q-001_gate_blockiert` verlangt dasselbe in drei Fällen. Beides ist
dieselbe Forderung und braucht keinen zusätzlichen Backlog-Eintrag (so schon
der zweite Achtung-Hinweis bei R3-Q-001).

**Zwei Prüfebenen, und keine ersetzt die andere.**

- **Die Formprüfungen gegen eine Attrappe von `make dod`.** Nur so lassen sich
  Lagen herstellen, die am heutigen Bestand nicht herstellbar sind — ein
  `A_FAIL` bei D3, ein `VERLETZT` bei D19, eine fehlende Marke, ein
  Rückgabewert 7. Die Attrappe druckt eine Übersicht in der Form aus G7 und
  lebt ausschliesslich im Prüfaufbau; sie steht **nie** in der versionierten
  `.claude/settings.json`.
- **Je ein roter und ein grüner Lauf gegen das echte `Makefile`.** Sonst wäre
  die Formannahme des Gates nur gegen sich selbst geprüft. Der grüne Lauf
  braucht einen **Scheinbaum**, weil `PROJ` sich nicht überschreiben lässt und
  aus dem Pfad des Makefiles hergeleitet wird: ein eigenes Git-Repository mit
  `CLAUDE.md`, den beiden Bezugsdokumenten in prüfbarer Form, dem echten
  Makefile, dem echten Belegprüfer samt Ausnahmeliste, Attrappen für die vier
  noch nicht gebauten Skripte und einer `gitleaks`-Attrappe im Suchpfad. Ob ein
  solcher Baum mit dem **echten** Belegprüfer grün wird, ist mit einem
  ausgeführten Lauf festzustellen und wird hier **nicht behauptet**; fällt es
  anders aus, ist der Befund zu melden und nicht der Scheinbaum
  zurechtzubiegen.

**Was zu decken ist** — je ein Fall, jeder mit dem erwarteten Rückgabewert:

| Fall | Erwartet |
|---|---|
| Kette mit `A_FAIL` | 2 |
| Kette grün, ohne Lage C | 0, keine Ausgabe |
| Terminierte Lage C, Eintrag gültig | 0, mit `systemMessage`, die den Schritt nennt |
| Lage C ohne Eintrag | 2 |
| Eintrag vorhanden, Prüfmittel existiert inzwischen | 2 (veraltet) |
| Eintrag vorhanden, Schritt meldet A_OK | 2 (veraltet) |
| Eintrag ohne Grund; Eintrag mit nicht terminierbarem Prüfmittel; Eintrag mit absolutem Pfad | je 2 |
| Marke nennt ein anderes Prüfmittel als der Schlüssel | 2 |
| `stop_hook_active` wahr bei roter Kette | 0, Zähler unverändert |
| D19 `VERLETZT`; D19 Lage C | je 2 |
| Fehlendes `jq`, `git`, `make`, `Makefile`, `timeout`, `flock`, fehlende Liste | je 2, mit Nennung des Mittels |
| Nicht beschreibbares Zustandsverzeichnis bei roter Kette | 2, mit dem Zusatz, dass nicht gezählt werden kann |
| Innere Zeitüberschreitung | 2 |
| Dreimal derselbe Schlüssel | beim dritten Mal die Forderung nach der Übergabedatei |
| Übergabedatei mit der geforderten Zeile, neu oder geändert | Durchlass beim vierten Mal |
| Übergabedatei mit der geforderten Zeile, committet und **nachweislich** in `HEAD` enthalten *(Nachtrag 6.12.24 i, Befund DT-B4: der Fall muss die Datei wirklich in `HEAD` haben, sonst belegt er seine Behauptung nicht)* | Durchlass *(Runde 1, B6)* |
| Übergabedatei mit der geforderten Zeile, aber nur in einem älteren Commit | weiterhin 2 |
| Dieselbe Eskalation auf `TaskCompleted` | weiterhin 2, auch mit Übergabedatei *(Runde 1, B5)* |
| Lauf mit mehreren ungedeckten Lagen C und zusätzlich einem D19-Befund | 2; gezählt wird die erste Abweichung in Kettenreihenfolge, genannt werden alle *(Runde 1, B7)* |
| Marke mit `FEHLT=` und `SCHWELLE=` zugleich (D3, D6 oder D8 in Lage C) | richtig zerlegt, Deckung wird am `FEHLT=`-Teil geprüft *(Runde 1, B8)* |
| D19-Zeile in allen vier Schlüsselwortformen, je mit und ohne Zusatztext — also **alle acht** Kombinationen *(Nachtrag 6.12.24 i, Befund N-02)* | richtig zugeordnet *(Runde 1, B9)* |
| `TaskCompleted` bei roter Kette | 2 |
| `SubagentStop` einer Rolle mit `Bash`, aber ohne `Edit`/`Write`/`NotebookEdit` — der belegte Fall `static-software-tester` und `pentester`, mit den **echten** Rollendateien aus `.claude/agents/`, in den Scheinbaum kopiert *(Nachtrag 6.12.24 i, Befund N-03)* | 0, ohne Lauf der Kette *(Runde 1, B1)* |
| `SubagentStop` einer Rolle mit `Edit`/`Write` — als Gegenfall die echte Rollendatei `devops-engineer` *(Nachtrag 6.12.24 i)* | Kette läuft, Gate urteilt |
| `agent_type`, der über `name:` aufzulösen ist und nicht über den Dateinamen | richtig aufgelöst *(Runde 1, B2)* |
| `SubagentStop` mit unbekanntem, leerem oder mehrdeutigem `agent_type` | Kette läuft, Gate urteilt |
| Flacher Klon | 2, mit `git fetch --unshallow` in der Meldung |
| `cwd` in einem Unterverzeichnis des Baums; `cwd` mit Schrägstrich am Ende; `cwd` über einen Symlink auf den Baum — je im grünen Scheinbaum *(Nachtrag 6.12.24 i, Entscheid a; Befunde B-02, B-03 und die drei blockierenden Befunde der dynamischen Prüfung; Erwartung berichtigt nach S3-03)* | je 0; **kein** `KETTE baum-widerspruch`, **kein** `GATE Makefile`. Bei sauberem Grün **schweigt** das Gate (6.12.15); die Bestimmung ist über die Baumzeile der Kette belegt, eine falsche Bestimmung ergäbe `KETTE baum-widerspruch` |
| `cwd` ausserhalb jedes Arbeitsbaums dieses Repositories *(Nachtrag 6.12.24 i, G12; Erwartung berichtigt nach S3-03)* | Rückfall auf die Wurzel von `${CLAUDE_PROJECT_DIR}`. Bei sauberem Grün schweigt das Gate (6.12.15); die Bestimmung ist über die Baumzeile der Kette belegt, eine falsche Bestimmung ergäbe `KETTE baum-widerspruch` |
| Zweiter Arbeitsbaum desselben Repositories (`git worktree`), `cwd` darin *(Nachtrag 6.12.24 i, G12; Befund DT-B5; Erwartung berichtigt nach S3-03)* | das Gate prüft den **zweiten** Baum. Bei sauberem Grün schweigt es (6.12.15); dass der zweite Baum geprüft wurde, ist über die Baumzeile der Kette belegt, eine falsche Bestimmung ergäbe `KETTE baum-widerspruch` |
| Die Baumzeile der Kette nennt einen anderen Baum als den bestimmten *(Nachtrag 6.12.24 i, Entscheid b)* | 2, `KETTE baum-widerspruch` |
| Weder `XDG_STATE_HOME` noch `HOME` gesetzt, einmal bei roter und einmal bei grüner Kette *(Nachtrag 6.12.24 i, Entscheid c)* | 2 beziehungsweise 0 — **nie 1** —, je mit dem Zusatz, dass nicht gezählt werden kann; bei grüner Kette ist er die **einzige** Meldung, und er unterscheidet "nicht bestimmbar" von "nicht beschreibbar" *(S-13)* |
| Zustandsverzeichnis nicht beschreibbar; zusätzlich `/tmp` nicht beschreibbar *(Nachtrag 6.12.24 i, Entscheid e)* | im ersten Fall Sperre unter `/tmp`, im zweiten Lauf ohne Sperre; das Urteil bleibt gleich, die Meldung nennt den Ausfall |
| `TMPDIR` zeigt in den geprüften Baum *(Nachtrag 6.12.24 i, Entscheid f)* | die Wegwerfdatei entsteht ausserhalb des Baums, D19 bleibt ohne Befund; ist sie ausserhalb nicht anlegbar: 2 mit `GATE mktemp` |
| Fehlendes `sha256sum`; fehlendes `mktemp` *(Nachtrag 6.12.24 i, Entscheid g)* | je 2, mit Nennung des Mittels und des Beschaffungswegs |
| Liste mit je einer Verletzung der Selbstprüfungen 2, 4 und 6 in verschiedenen Zeilen *(Nachtrag 6.12.24 i, Entscheid h)* | 2 **vor** dem Lauf der Kette; der Schlüssel stammt aus der Zeile mit der kleinsten Zeilennummer |
| Vierter Durchlass nach der Eskalation, danach erneut ein Block am selben Kriterium *(Nachtrag 6.12.24 i, Entscheid d; Befund DT2-B1)* | der Zähler **zählt weiter** (4, 5, 6) und wird nicht gelöscht; die Meldung nennt das fünfte Mal, und die Forderung nach der Übergabedatei wird nicht ein zweites Mal erhoben |
| D12 in Lage C mit **mehreren** fehlenden Gegenständen *(Nachtrag 6.12.24 i, Befund N-08)* | `FEHLT=` nennt den **ersten**; kein späterer `if`-Block überschreibt ihn |
| `TMPDIR` zeigt in den geprüften Baum, und die **Kette selbst** legt eine Wegwerfdatei an (Ziele `nachweise` und `abdeckung`) *(Nachtrag 6.12.24 f, Befund DT2-B2)* | der Kettenlauf erhält `TMPDIR` ausserhalb des Baums; während des Laufs entsteht im Baum keine Datei, auch keine unversionierte |
| Ausgabe mit Baumzeile, Form-1-Schlusszeile, D19 `OHNE_BEFUND`, Rückgabewert 0 und **null** Marken *(Nachtrag 6.12.24 k, Befund S-11)* | 2, `KETTE ausgabe-unlesbar` — **nicht** stummer Durchlass mit 0 |
| Schlusszeile nennt eine andere Zahl, als Marken gelesen wurden (Formen 1, 2 und 4) *(Nachtrag 6.12.24 k)* | je 2, `KETTE ausgabe-unlesbar`; Form 3 wird nicht auf die Zahl geprüft |
| D19-Zeile meldet Lage B bei Rückgabewert 0, obwohl das Gate einen Arbeitsbaum bestimmt hat *(Nachtrag 6.12.24, Befund S-01)* | 2 unter `D19 B-widerspruch`, **nicht** unter `KETTE ausgabe-unlesbar` |
| Baumzeile **fehlt** ganz *(Nachtrag 6.12.24, Befund S-10)* | 2, `KETTE ausgabe-unlesbar` |

**Wie geprüft wird.** Das Skript wird im Selbsttest **unmittelbar** mit einer
JSON-Eingabe auf der Standardeingabe aufgerufen, nicht über den Harness.
*(Runde 1, Begründung berichtigt: Die erste Fassung stützte das darauf, die
Referenz sage nicht, ob eine Änderung an `.claude/settings.json` in der
laufenden Sitzung wirke. Sie sagt es — "Direct edits to hooks in settings files
are normally picked up automatically by the file watcher." Der Entscheid bleibt,
die Begründung wird ausgetauscht; eine Festlegung, die auf einem Schweigen
beruht, das es nicht gibt, ist eine Zusicherung ohne Deckung, V12.)* Die
tragenden Gründe sind zwei andere, und beide sind stärker: **Herstellbarkeit** —
über die Standardeingabe lässt sich jeder Fall der Tabelle oben gezielt
erzeugen, auch die, die im Ereignisfluss des Harness nicht auf Bestellung
eintreten (`stop_hook_active` wahr, ein unbekannter `agent_type`, der dritte
Block in Folge); und **Determinismus** — der Selbsttest darf nicht davon
abhängen, wann eine Dateiüberwachung eine Änderung bemerkt, sonst prüft er
nebenbei den Harness statt das Skript. Die Verifikation liegt beim Static und
beim Dynamic Software Tester auf einem anderen Modell als die Umsetzung (3.4);
die Rolle, die das Gate baut, prüft es nicht selbst.

#### 6.12.20 Einordnung der drei übrigen Punkte aus dem Achtung-Hinweis zu R3-Q-001

Der zweite Achtung-Hinweis bei R3-Q-001 nennt vier Bauformen aus dem Vergleich
mit einem fremden Bestand; der Backlog hält ausdrücklich fest, dass alle vier
Sache des Software Architects im Rahmen dieser Fortschreibung sind und keinen
eigenen Backlog-Eintrag erhalten. Punkt 1 — der rote und der grüne Lauf — ist
mit G17 erledigt. Die übrigen drei werden hier **eingeordnet und nicht gebaut**,
wie der Auftraggeber es angewiesen hat.

| Punkt | Einordnung | Zuständig | Bedingung und Termin |
|---|---|---|---|
| **Schwachstellenklassen im eigenen Code** (ruff-Regelgruppe `S`) | Zu entscheiden ist **nicht ob, sondern wo**: als Regelgruppe in der bestehenden ruff-Konfiguration und damit in D3, oder als eigener Kettenschritt mit eigener Nummer. Für D3 spricht, dass kein neues Werkzeug und kein neuer Schritt entsteht; dagegen spricht das Argument aus 6.1.2 für D18 — eine Aussage über eine Sicherheitseigenschaft soll einen eigenen Rückgabewert haben und darf nicht mit einem Schwellenwert für Stilwarnungen (E-08, O-7) zusammenfallen. Als **O-21** geführt | Software Architect mit SecDevOps Engineer; Bau beim Backend Engineer | Heute Lage B: es gibt keinen eigenen Python-Code. Mit dem Anlegen von `backend/pyproject.toml`, vor der ersten Umsetzungseinheit mit Fachlogik |
| **Markdown-Struktur- und Tabellenprüfer** | Der Gegenstand besteht **heute** — eine verrutschte Spalte in der Rollentabelle ist eine falsch gelesene Bauvorschrift. Er geht **nicht** in D20 auf: D20 urteilt über Herkunfts- und Fundortangaben, ein Strukturprüfer über den Aufbau des Dokuments; das sind zwei Sachen, und jeder Schritt urteilt über eine (6.2.2). Eine D-Nummer wird hier **nicht** vergeben — eine Nummer für einen nicht entschiedenen Schritt wäre eine Absichtserklärung, und nach 6.8.1 wäre sie mit der Nennung vergeben. Als **O-22** geführt | Software Architect (Entscheid über den Schnitt), DevOps Engineer (Bau) | Keine Vorbedingung im Bestand; Termin: mit der nächsten Fortschreibung dieses Abschnitts, spätestens vor der Freigabe des Grundgerüsts |
| **Prüfmodus für den Nachweiserzeuger** | **Kein neuer offener Punkt.** Das ist der Gegenstand von **O-8** ("Betriebsart für D10 und Form von D12"), der seit dem 2026-08-30 zusätzlich an den Kettengrundsatz gebunden ist: Die gewählte Form schreibt nicht in den Arbeitsbaum. O-8 trägt heute den Termin "mit R3-Q-001"; dieser Termin ist nicht haltbar, weil weder `scripts/nachweise-vollstaendig.sh` noch `scripts/prototyp-trennung-pruefen.sh` bestehen und ein Entscheid über die Betriebsart eines nicht vorhandenen Skripts eine Absichtserklärung wäre. **O-8 wird auf "mit dem Grundgerüst" umterminiert** | DevOps Engineer mit Protocol Master | Mit dem Anlegen der beiden Skripte, also mit dem Grundgerüst |

#### 6.12.21 Bezug zu den offenen Punkten, die das Gate berühren

- **O-7** (Schwellenwerte in D3, D6, D8) bleibt offen und unberührt. Das Gate
  liest die Marke; ob sie `SCHWELLE=5` oder `OHNE_SCHWELLE` trägt, ändert an
  seiner Auswertung nichts.
- **O-8** ist umterminiert, siehe 6.12.20.
- **O-10 (neu gefasst), Restfrage (a)** — die namentliche Ausschlussliste des
  Arbeitsbaumlaufs von D11 und ihre technische Form — trägt heute den Termin
  "mit R3-Q-001". Sie ist nur mit einem ausgeführten Lauf der eingesetzten
  Werkzeugfassung zu belegen, und `gitleaks` ist nicht installiert (Fremdbeleg).
  **Umterminiert auf: mit der Installation von `gitleaks`, spätestens mit dem
  Grundgerüst.** Restfrage (b) bleibt unverändert.
- **O-12** (Lauf auf der Gegenseite) bleibt offen und gewinnt eine Aufgabe: Der
  Lauf auf der Gegenseite ruft `make dod` **ohne** die Liste der terminierten
  Lagen auf. Das Gate ist wie die Kette die zweite Linie — gegen einen Aufrufer,
  der die Umgebung beherrscht, ist ein Gate im Arbeitsverzeichnis grundsätzlich
  wirkungslos, und das steht im Makefile-Kopf und im Kopf beider bestehender
  Gates bereits so. Das Gate ändert daran nichts; es setzt Disziplin durch, es
  ersetzt die Gegenseite nicht.
- **O-14** (fest verdrahteter Ort des zweiten Arbeitsbaums bei D20) bleibt offen
  und wird vom Gate **geerbt**: Die Zahl der nicht prüfbaren Zeilen geht nicht
  in den Rückgabewert ein und steht nicht in der Marke; das Gate sieht sie also
  nicht und kann sie nicht melden. Der Termin "mit R3-Q-001" bleibt; die
  Behebung ist Umsetzung und liegt beim DevOps Engineer.
- **O-15** (Abnahme des Belegprüfers) bleibt offen, siehe 6.12.18, Punkt 4.
- **O-17** (Löschung einer maskierten Datei) bleibt offen und ist vom Gate
  unberührt: D19 Lage C blockiert in jedem Fall; die Antwort bestimmt allein,
  wie weit die Meldung sagen darf, der Inhalt sei beurteilt.
- **O-18** (Aktualität der Bezugsdokumente von D20) **bleibt offen**, mit
  geschärfter Frage und neuem Termin. Der Grund für das Offenbleiben ist keine
  Verlegenheit: Zu prüfen, ob eine Anforderungskennung im Backlog noch **gilt**,
  ist eine Aussage über den Inhalt am Fundort, und genau die hat 6.8.4 dem
  menschlichen Review zugewiesen. Maschinell prüfbar wäre sie erst, wenn der
  Backlog je Eintrag ein **maschinenlesbares Statusfeld** trüge — das ist die
  eigentliche, bisher nicht benannte Vorbedingung, und sie ist eine Änderung am
  Format des Backlogs, nicht am Belegprüfer. Zuständig bleibt der Software
  Architect mit dem Static Software Tester, für das Statusfeld der Requirements
  Engineer mit dem Product Owner; **Termin neu: mit dem Grundgerüst.**

#### 6.12.22 Was diese Fortschreibung nicht ändert

Die Kernarchitektur aus 5.1 bleibt unberührt; diese Fortschreibung betrifft
ausschliesslich die Werkzeugkette. Die Entscheide A1 bis A13 bleiben
unverändert. Der Modulschnitt aus Abschnitt 4 und die Verankerung der
Verfahrensgarantien in 4.2 und 4.3 bleiben unverändert — das Gate ist keine
Verfahrensgarantie nach 5.4, sondern die Durchsetzung der Definition of Done
nach 3.4, und es wird an keiner Stelle zwischen Freigabe und Ausführung
gestellt. Nichts an diesem Entwurf bereitet Gestrichenes vor (5.17, 5.18, 9.1,
5.10, 5.1).

An der Kette bleiben **Gegenstand, Erkennungsmerkmal und Prüfmittel** aller
Schritte unverändert; die einzige Ergänzung ist die Vollständigkeit der
Historie bei D20 (G16). Die Reihenfolge bleibt unverändert. Die Nummernregel
aus 6.1.2 bleibt in Kraft, und diese Fortschreibung vergibt **keine** neue
D-Nummer. Der Kettengrundsatz aus 6.1.3 gilt unverändert und wird durch G8
(Zustand ausserhalb des Arbeitsbaums) und G12 (Sperrdatei ausserhalb des
Arbeitsbaums) auf das Gate selbst ausgedehnt. Der Grundsatz aus 6.8.4 zur
Aussagekraft eines Rückgabewerts 0 gilt unverändert und wird in 6.12.18 auf das
Gate übertragen. Die vier Eigenschaften der Ausnahmeliste aus 6.8.5 bleiben
unverändert; die Liste der terminierten Lagen ist eine **zweite** Liste mit
eigenen Regeln und ändert an der ersten nichts. Die geschärfte Lage C aus 6.9.2
bleibt unverändert und trägt G16.

Geändert werden am `Makefile` ausschliesslich vier Dinge, jedes davon oben
begründet: das Weiterlaufen bei Lage C (G5), das strukturierte `FEHLT=` in der
Marke (G6), die Schlusszeilen samt eigenständiger D19-Zeile und der
Nennung des geprüften Baums (G7 — **vier** Formen seit dem Nachtrag aus dem
Bau, 6.12.23; bis dahin drei) und die Prüfung der Historienvollständigkeit
im Ziel `belege` (G16). Kein Kettenschritt wechselt dadurch seine Lage, und
kein roter Lauf wird grün.

Nicht entschieden werden: die Abnahme des Belegprüfers (O-15), die
Schwellenwerte (O-7), die beiden Restfragen aus O-10, der Lauf auf der
Gegenseite (O-12), der Ort des zweiten Arbeitsbaums (O-14), der Löschfall
(O-17) und die Aktualitätsprüfung (O-18). O-14 und O-17 fallen mit diesem
Backlog-Eintrag fällig, gehören aber dem DevOps Engineer und sind nicht Teil
dieses Entwurfs; ihre Einplanung liegt beim Koordinator.

#### 6.12.23 Nachträge aus dem Bau vom 2026-09-02

Der Bau nach 6.12 ist am 2026-09-02 auf Weisung des Auftraggebers erfolgt; die
förmliche Freigabe der Entscheidpunkte E-A bis E-K steht aus (Abschnitt 10).
Der DevOps Engineer hat dabei **drei Stellen** gemeldet, an denen dieser
Entwurf keinen Fall vorsieht, und je eine Übergangslösung eingebaut, um
weiterarbeiten zu können. Sie werden hier entschieden. Eine Übergangslösung
wird durch einen Nachtrag **abgelöst, nicht bestätigt** — auch dann nicht, wenn
der Entscheid ihr im Ergebnis folgt. Der Unterschied ist nicht formal: Eine
Behelfslösung im Code, die niemand entschieden hat, ist eine Festlegung ohne
Fundstelle, und genau daran misst D20.

Diese Rolle hat **nichts ausgeführt** und nichts nachgeprüft (3.4). Was unten
als Tatsache steht, ist **Fremdbeleg** aus den Läufen des DevOps Engineers und
des Koordinators vom 2026-09-02 und als solcher gekennzeichnet.

**a) Eine vierte Schlusszeile — vollständig gelaufen, und trotzdem Rückgabewert 2**

| | |
|---|---|
| **Vorher galt** | G7 (6.12.8) kennt genau **drei** Schlusszeilen: vollständig und sauber; vollständig mit k Schritten in Lage C; abgebrochen bei einem Schritt |
| **Jetzt gilt** | Es gibt eine **vierte** Form für den Lauf, der vollständig und ohne `A_FAIL` und ohne Lage C durchgelaufen ist, in dem aber die Rahmenprüfung **D19** `VERLETZT` oder Lage C meldet und der deshalb mit 2 endet |

Der Fall ist im Entwurf nicht vorgesehen, und keine der drei Formen trifft ihn:
Form 1 behauptet "keiner ungleich 0" und stünde über einem Lauf mit
Rückgabewert 2; Form 2 verlangt Schritte in Lage C, die es hier nicht gibt;
Form 3 sagt "abgebrochen bei", obwohl nichts abgebrochen wurde. Die
Übergangslösung des DevOps Engineers — Form 3 mit dem zuletzt gelaufenen
Schritt — ist **unwahr**: Sie benennt einen Schritt als Abbruchstelle, der
durchgelaufen ist. Das ist derselbe Mangel, den 6.12.8 für die mittlere Form
schon einmal ausgeschlossen hat: Eine Nachweiszeile, die zu viel oder das
Falsche behauptet, ist so untauglich wie eine fehlende (5.3).

**Entscheid: eine vierte Form.**

```
make dod: alle <N> Kettenschritte durchlaufen, Rahmenpruefung D19 <VERLETZT|C>, Rueckgabewert 2.
```

**Welche Form wann gilt** — in dieser Reihenfolge zu prüfen, damit die Zuordnung
eindeutig ist:

1. Die Kette ist abgebrochen (`A_FAIL`, fehlende oder mehrfache Marke, sonstiger
   Rückgabewert ungleich 0) → **Form 3**.
2. Sonst, wenn mindestens ein Schritt Lage C meldet → **Form 2**, unabhängig
   davon, was D19 meldet. Die D19-Aussage steht ohnehin in ihrer eigenen Zeile
   und wird dort gelesen (G7).
3. Sonst, wenn die D19-Zeile `VERLETZT` oder `C` meldet → **Form 4**.
4. Sonst → **Form 1**.

**Damit gilt: Rückgabewert 0 nur zusammen mit Form 1.** Das ist der eigentliche
Gewinn der vierten Form. Vorher war die Zuordnung von Rückgabewert und
Schlusszeile nicht eindeutig — ein Lauf mit Rückgabewert 2 konnte Form 1 tragen
—, und eine Formprüfung, die das duldet, prüft nichts. Ein Lauf, der
Rückgabewert 0 mit einer anderen Schlusszeile als Form 1 verbindet, ist ein
**Widerspruch** und blockiert unter dem Schlüssel `KETTE
schlusszeile-widerspruch`; die Zeile steht in der Tabelle 6.12.4. Ohne diesen
Ausgang wäre die Parse-Regel ein genannter Massstab ohne Prüfung — V12.

**Was sich für die Klassifizierung nicht ändert.** Das Gate urteilt über diesen
Lauf unverändert über die D19-Zeile, mit den bestehenden Schlüsseln `D19
VERLETZT` beziehungsweise `D19 C` (6.12.4). Die vierte Form ändert an Ausgang,
Schlüssel und Zählung **nichts**; sie stellt die Nachweiszeile richtig und macht
die Parse-Regel prüfbar. Für das Gate ändert sich allein die Formprüfung aus
6.12.3: genau eine der **vier** Formen statt einer der drei. Die beiden
Selbsttestfälle "D19 `VERLETZT`" und "D19 Lage C" aus 6.12.19 sind neu in dieser
Form zu erzeugen; die Anforderung selbst bleibt unverändert.

**b) Der Zählschlüssel für Verstösse gegen die terminierten Lagen**

| | |
|---|---|
| **Vorher galt** | Die Tabelle 6.12.4 führt für die sechs Selbstprüfungen der terminierten Lagen (6.12.5) **keinen** Zählschlüssel. Für Selbstprüfung 1 greift die Zeile "Marke endet auf `C` und ist nicht gedeckt"; für die Selbstprüfungen 2 bis 6 gibt es keinen |
| **Jetzt gilt** | Verstösse gegen die Selbstprüfungen 2 bis 6 zählen unter einem eigenen Schlüsselraum `LISTE …`. Die Übergangslösung `GATE dod-gate-terminierte-lagen.txt` für alle sechs ist abgelöst |

**Entscheid.**

| Selbstprüfung (6.12.5) | Schlüssel |
|---|---|
| 2 (Prüfmittel existiert inzwischen), 3 (Schritt meldet eine andere Lage als C), 5 (Marke nennt ein anderes Prüfmittel als der Schlüssel) | `LISTE <Nummer der Selbstpruefung> <D> <ziel>` |
| 4 (Eintrag ohne Grund), 6 (Schlüssel nennt kein terminierbares Prüfmittel) | `LISTE <Nummer der Selbstpruefung> <Zeilennummer>` |
| 1 (Lage C ohne Eintrag) | unverändert `<D> <ziel> C <fehlendes Prüfmittel>` — kein Fehler der Liste, sondern eine ungedeckte Lage C |

Die **Zeilennummer** ist die physische, bei 1 beginnende Zeilennummer in
`.claude/hooks/dod-gate-terminierte-lagen.txt`; Leer- und Kommentarzeilen
zählen mit, weil nur so die genannte Zeile ohne Umrechnung auffindbar ist.

**Weshalb nicht `GATE …`.** `GATE <Prüfmittel>` bezeichnet den **Ausfall** eines
Prüfmittels des Gates (6.12.11) — bei dieser Liste den einen Fall, dass sie
fehlt. Eine fehlerhafte Zeile in einer vorhandenen Liste ist das Gegenteil
davon: Das Prüfmittel ist da und urteilt, und die Zeile ist zu berichtigen.
Fielen beide unter denselben Schlüssel, hätte das zwei Folgen, und beide sind
in dieser Datei schon einmal teuer gewesen. Erstens zählte 3.4 an einem
Kriterium, das zwei verschiedene Sachverhalte zusammenfasst — die Eskalation
träfe dann eine Mischung statt eines Kriteriums. Zweitens sagte die Meldung dem
Bearbeiter das Falsche: "beschaffe das Prüfmittel" statt "berichtige Zeile n".
Das ist wörtlich der Fehlermodus, den 6.12.4 mit der Unterscheidung von Befund
und Ausfall vermeidet, und der Befund aus 6.11.1: rot mit falscher Begründung.

**Weshalb die Selbstprüfungen 4 und 6 die Zeilennummer tragen und nicht den
Schritt.** Bei ihnen ist die Aussage der Zeile selbst untauglich — bei 4 fehlt
der Grund, bei 6 nennt der Schlüssel ein Prüfmittel, das nach 6.12.5 gar nicht
terminierbar ist. Ein Zählschlüssel, der Kennung und Ziel aus dieser Zeile
übernähme, machte die Behauptung der fehlerhaften Zeile zum Schlüssel des
Zählers, der über sie urteilt. Die Zeilennummer ortet die Zeile, ohne ihr
etwas zu glauben. Dass sie sich verschiebt, sobald die Datei geändert wird, ist
hier richtig und kein Mangel: Eine geänderte Liste ist ein anderer Sachverhalt,
und der Zähler soll dann von vorn zählen.

**Welcher Schlüssel gezählt wird, wenn mehreres zugleich zutrifft.** 6.12.9 legt
fest: gezählt wird eine Abweichung, genannt werden alle. Die Reihenfolge wird
hier für den neuen Schlüsselraum ergänzt und lautet vollständig: (1) `GATE …` —
ohne Prüfmittel urteilt das Gate über gar nichts; (2) `LISTE …`, bei mehreren
fehlerhaften Zeilen die erste in Dateireihenfolge; (3) die erste Abweichung in
Kettenreihenfolge, also `A_FAIL` oder ungedeckte Lage C; (4) `D19 …`.
*(Nachtrag 6.12.24 h, Befund S3-06: Zwischen (1) und (2) tritt `KETTE
ausgabe-unlesbar` — ohne lesbare Ausgabe ist keine Deckungsprüfung möglich.)* Der Grund
für den Vorrang der Liste vor der Kette: Solange eine Zeile der Liste
fehlerhaft ist, beruht die Deckungsprüfung **jeder** gemeldeten Lage C auf einem
Instrument, das selbst beanstandet ist. Zuerst wird das Instrument in Ordnung
gebracht, dann wird über den Gegenstand geurteilt — dieselbe Rangfolge, mit der
6.9.2 Instrument und Gegenstand trennt.

**c) Fehlt `jq`, bleibt der Block ungezählt — eine benannte Grenze**

| | |
|---|---|
| **Vorher galt** | 6.12.11 führt `jq` als Prüfmittel des Gates: Fehlt es, ist das Lage C des Gates mit Rückgabewert 2. Über die Zählung dieses Blocks sagt der Entwurf nichts |
| **Jetzt gilt** | Dieser eine Block wird **nicht gezählt** und kann es nicht werden. Die Grenze ist als solche benannt und steht an Ort in 6.12.9; ein Ersatzweg wird nicht erfunden |

Der Grund ist zwingend und nicht behebbar: Gezählt wird je Sitzung und, wenn
vorhanden, je Subagent (G8). `session_id` und `agent_id` stehen in der
Eingabe-JSON, und ohne `jq` kann das Gate diese Eingabe nicht lesen. Es weiss
also, **dass** es blockiert, aber nicht, **wofür** es den Block anschreiben
soll.

Ein Ausweichschlüssel wird ausdrücklich nicht erfunden. Jeder denkbare — ein
fester Dateiname, die Kennung des Elternprozesses, der Zeitpunkt — zählte
entweder Läufe zusammen, die nichts miteinander zu tun haben, oder trennte
Läufe, die zusammengehören. Ein falsch geführter Zähler ist schlechter als ein
fehlender: Er löst eine Eskalation nach 3.4 aus, für die es keinen Grund gibt,
oder verhindert eine, für die es einen gibt. Die Grenze ist ausserdem eng —
`jq` fehlt für eine ganze Sitzung oder gar nicht, und die beiden bestehenden
Gates blockieren bei fehlendem `jq` aus demselben Grund (CLAUDE.md, "Aktive
Gates"). Der Fall ist damit sichtbar, blockierend und unzählbar; verschwiegen
ist er nicht (V12).

**d) Zwei Tatsachen aus dem Bau (Fremdbeleg, nicht von dieser Rolle geprüft)**

1. **Der Selbsttest `scripts/dod-gate-selbsttest.sh` besteht 48 von 48 Fällen.**
   Ob diese 48 Fälle die Tabelle aus 6.12.19 vollständig abdecken, wird hier
   **nicht behauptet**; das festzustellen ist Sache der Verifikation durch den
   Static und den Dynamic Software Tester auf einem anderen Modell (3.4).
2. **Der grüne Lauf gegen das echte `Makefile` im Scheinbaum ist beim ersten Bau
   nicht grün geworden**, sondern endete mit **D20 in Lage C**: Der Belegprüfer
   meldete im Scheinbaum Rückgabewert 3. Genau diesen Ausgang benennt 6.12.19
   ausdrücklich als möglich — "Ob ein solcher Baum mit dem **echten**
   Belegprüfer grün wird, ist mit einem ausgeführten Lauf festzustellen und wird
   hier **nicht** behauptet; fällt es anders aus, ist der Befund zu melden und
   nicht der Scheinbaum zurechtzubiegen." Der Befund ist gemeldet worden. Die
   Folge ist die dort vorgeschriebene: **Der Scheinbaum wird in prüfbare Form
   gebracht, nicht der Prüfer geschwächt.**

**Die Anforderung aus 6.12.19 bleibt unverändert bestehen und wird hier nicht
abgeschwächt:** Der grüne Lauf muss mit **Rückgabewert 0 der Kette** belegt
sein. Solange dieser Beleg nicht vorliegt, gilt der Selbsttest als **nicht
vollständig** — auch bei 48 von 48 bestandenen Fällen. Das ist
keine neue offene Frage und braucht keine eigene Nummer; es ist die
unveränderte Forderung aus G17, deren Erfüllung noch aussteht. Ein Selbsttest,
der die Attrappe besteht und am echten Gegenstand nicht belegt ist, prüft die
Formannahme des Gates gegen sich selbst — genau das, was 6.12.19 mit dem
zweiten Prüfweg ausschliesst.

**Was diese Nachträge nicht ändern.** Kein Entscheid G1 bis G17 wird
zurückgenommen. Die Kernarchitektur aus 5.1, die Entscheide A1 bis A13, der
Modulschnitt und die Verankerung der Verfahrensgarantien bleiben unberührt.
Keine D-Nummer wird vergeben. Die sechs Selbstprüfungen der terminierten Lagen
bleiben in Zahl, Inhalt und Wirkung unverändert — sie erhalten einen
Zählschlüssel, keine Ausnahme. Kein Kettenschritt wechselt seine Lage, und kein
roter Lauf wird grün. Nichts hier bereitet Gestrichenes vor (5.17, 5.18, 9.1,
5.10, 5.1).

#### 6.12.24 Nachträge aus der Verifikation vom 2026-09-02

Der Bau nach 6.12 ist am 2026-09-02 auf Weisung des Auftraggebers erfolgt; die
förmliche Freigabe der Entscheidpunkte E-A bis E-K steht aus (Abschnitt 10).
Dieser Nachtrag ändert daran nichts. Er behauptet **weder eine Freigabe noch
eine Abnahme** — er entscheidet **zehn** Stellen, an denen der Entwurf einen
Fall nicht vorsieht oder zu wenig sagt: a) bis i) aus der ersten Prüfrunde und
k) aus der zweiten; j) verzeichnet die Beleglage beider Runden.

**Was geprüft wurde, und mit welchem Ergebnis (Fremdbeleg).** Der Static
Software Tester hat den gebauten Stand am 2026-09-02 auf einem anderen Modell
als die Umsetzung gegen 6.12 verifiziert und ihn **nicht bestanden**: vierzehn
Befunde, davon **fünf blockierend** (B-01 bis B-05) und neun nicht blockierend
(N-01 bis N-09). Der Dynamic Software Tester hat am selben Tag ebenfalls
**nicht bestanden**: fünf Befunde, davon **drei blockierend**; die drei
blockierenden haben dieselbe Ursache wie B-02 und B-03. Diese Rolle hat
**nichts ausgeführt** und nichts nachgeprüft (3.4). Was unten als Tatsache
steht, ist **Fremdbeleg** aus diesen beiden Berichten und aus den Läufen des
Koordinators vom 2026-09-02 und als solcher gekennzeichnet.

**Wer was behebt — und weshalb hier überhaupt etwas zu entscheiden ist.** Der
DevOps Engineer behebt B-01, B-02, B-03, N-02 bis N-06, N-08 und N-09 im Code.
B-04 und B-05 sind vom Koordinator in `scripts/belege-ausnahmen.txt` behoben
(Fremdbeleg): die ortsgebundene Ausnahme für `CLAUDE.md`, deren Zeilenangabe
durch das Wachsen der Datei überholt war, ist nachgeführt, und vier Ausnahmen
der Form `datei|wert` decken die in `docs/06_Definition_of_Ready_und_Done.md`
genannten, noch nicht gebauten Skripte. Beides ist **Umsetzung nach 6.8.5 und
kein Architekturentscheid**; dieser Nachtrag verzeichnet es und entscheidet es
nicht — und die vier Einträge sind mit dem Entstehen der Skripte wieder zu
entfernen, wie es 6.8.5, Eigenschaft 3, ohnehin erzwingt. Für **N-01** und
**N-07** wird der Code **nicht** geändert: Dort verhält sich der Bau richtig,
und dieser Entwurf sagt es nicht. Genau das ist der Grund für diesen Abschnitt,
und es ist dieselbe Regel wie in 6.12.23 — **eine Festlegung, die im Code steht
und in diesem ADR nicht, ist eine Festlegung ohne Fundstelle, und genau daran
misst D20.** Die Entscheide unten **lösen** die Behelfe des Baus ab; sie
bestätigen sie nicht, auch dort nicht, wo der Entscheid ihnen im Ergebnis folgt.

**a) Der geprüfte Baum ist die physisch aufgelöste Wurzel des Arbeitsbaums**
*(Befunde B-02 und B-03; die drei blockierenden Befunde der dynamischen Prüfung
haben dieselbe Ursache; ergänzt 6.12.13)*

| | |
|---|---|
| **Vorher galt** | 6.12.13 sagt, das Gate prüfe "den Arbeitsbaum, in dem `cwd` liegt", sofern dieser zu demselben Repository gehört wie `${CLAUDE_PROJECT_DIR}`, sonst diesen. Über die **Form** des so bestimmten Pfades sagt der Entwurf nichts. Der Bau übernahm `cwd` beziehungsweise `CLAUDE_PROJECT_DIR` roh und verglich zeichengenau mit der ersten Zeile der Kette, die das Makefile über `pwd -P` erzeugt (G7) |
| **Jetzt gilt** | Der geprüfte Baum ist die **Wurzel des Arbeitsbaums, physisch aufgelöst**. Gehört `cwd` zum selben Repository wie `${CLAUDE_PROJECT_DIR}` — festgestellt über den Vergleich der physisch aufgelösten gemeinsamen Git-Verzeichnisse, unverändert gegenüber 6.12.13 —, dann gilt `git -C <cwd> rev-parse --show-toplevel`; sonst die Wurzel des Arbeitsbaums von `${CLAUDE_PROJECT_DIR}`, und ist dieses kein Arbeitsbaum, dessen physisch aufgelöster Pfad. Die Baumzeile der Kette und die Bestimmung des Gates sind damit beide physische Pfade ohne Schrägstrich am Ende und vergleichbar |

**Was ohne diese Festlegung geschah** (Fremdbeleg, ausgeführt in beiden
Prüfungen):

1. Ein **Schrägstrich am Ende** des Pfades oder ein **Symlink** auf den Baum
   ergab `KETTE baum-widerspruch` — obwohl in der Sache kein Widerspruch
   bestand, sondern zwei Schreibweisen desselben Baums verglichen wurden.
2. Lag `cwd` in einem **Unterverzeichnis** des Baums, ergab es `GATE Makefile`
   — obwohl das `Makefile` besteht; das Gate suchte es im Unterverzeichnis.

Beide Male endete das Gate mit Rückgabewert 2 und **falscher Begründung**. Das
ist wörtlich der Fehlermodus aus 6.11.1, gegen den die Klassifizierung in
6.12.4 gebaut ist, und er ist hier besonders teuer: Der Block zählt unter einem
Schlüssel, der mit der Sache nichts zu tun hat, und die Eskalation nach 3.4
träfe dreimal die falsche Frage.

**Weshalb die physische Auflösung und nicht ein nachsichtiger Vergleich.** Ein
Vergleich trägt nur, wenn beide Seiten dieselbe Sprache sprechen. Die Kette
bestimmt ihren Baum selbst und ohne Rückfall und gibt ihn über `pwd -P` aus
(G7); also muss das Gate denselben Massstab anlegen, statt die Abweichung
hinterher wegzurechnen. Ein Vergleich, der Schreibweisen duldet, duldet
irgendwann auch zwei verschiedene Bäume — und dann wäre die Baumzeile keine
Prüfung mehr, sondern Zierde. Dass die **Wurzel** genommen wird und nicht das
Verzeichnis, in dem gerade gearbeitet wird, ist dieselbe Überlegung: `make dod`
läuft gegen den Baum, nicht gegen ein Unterverzeichnis.

**Diese eine Angabe trägt vier Dinge**, und deshalb steht sie hier so genau:
den Aufruf von `make dod`, den Vergleich mit der Baumzeile (b), die Namen von
Sperr- und Zählerdatei (e) und die Prüfung, ob die Wegwerfdatei im Baum liegt
(f). Ist sie uneindeutig, sind alle vier uneindeutig.

**b) `KETTE baum-widerspruch` wird in die Klassifizierung aufgenommen**
*(Befund N-01; ergänzt 6.12.4)*

| | |
|---|---|
| **Vorher galt** | G7 verlangt die Baumzeile, 6.12.13 verlangt den Baum in jeder Meldung — einen **Ausgang** für den Fall, dass die Baumzeile der Kette einen anderen Baum nennt als das Gate bestimmt hat, führt die Klassifizierungstabelle 6.12.4 nicht. Der Bau kennt den Schlüssel, die Tabelle nicht |
| **Jetzt gilt** | Die Tabelle 6.12.4 trägt die Zeile: *Die erste Zeile der Kette nennt einen anderen Baum als den vom Gate bestimmten* → Art: Widerspruch, Schlüssel `KETTE baum-widerspruch`, Rückgabewert 2 |

**Weshalb blockierend.** Eine Kette, die über einen anderen Baum berichtet als
den, den das Gate meint, ist **kein Nachweis über diesen Baum**. Sie mag
tadellos gelaufen sein — nur eben anderswo. Das ist derselbe Grund, aus dem G7
die Baumzeile überhaupt verlangt (6.12.8: "Es genügt nicht, richtig zu messen,
es muss auch feststehen, was gemessen wurde") und aus dem 6.12.13 lieber kein
Urteil fällt als ein Urteil über das falsche Verzeichnis.

**Weshalb der Ausgang bleibt, obwohl a) ihn selten macht.** Nach a) sprechen
beide Seiten dieselbe Sprache, und der Schlüssel sollte im Regelbetrieb nicht
mehr fallen. Er ist danach kein Formfehler mehr, sondern die Anzeige eines
echten Auseinanderfallens — ein umgebogener Aufruf, ein zweiter Arbeitsbaum,
ein `Makefile` an unerwarteter Stelle. Fail-closed: Alles ausser einem belegten
Grün blockiert (6.12.4), und ein Grün über einen ungenannten Baum ist keines.
Ein Schlüssel im Code ohne Zeile in der Tabelle wäre ausserdem genau die
Festlegung ohne Fundstelle, die oben benannt ist.

**c) Ein nicht bestimmbares Zustandsverzeichnis erhält keinen eigenen Ausgang**
*(Befund B-01; ergänzt 6.12.9 und 6.12.11)*

| | |
|---|---|
| **Vorher galt** | 6.12.9 nennt `${XDG_STATE_HOME:-$HOME/.local/state}/r3cosint/dod-gate/` und regelt den Fall "nicht beschreibbar". Den Fall, dass sich das Verzeichnis **gar nicht bestimmen** lässt, regelt der Entwurf nicht. Der Bau las `$HOME` unter `set -u`; fehlten `XDG_STATE_HOME` und `HOME`, endete das Gate mit **Rückgabewert 1** (ausgeführt belegt, Fremdbeleg) — und liess damit durch |
| **Jetzt gilt** | `XDG_STATE_HOME`, sonst `$HOME/.local/state`, sonst **nicht bestimmbar**. Dieser Zustand wird behandelt wie "nicht beschreibbar": **kein eigener Ausgang**; das Gate urteilt unverändert und nennt in **jeder** Meldung, dass es nicht zählen kann und weshalb — und die Meldung unterscheidet **nicht bestimmbar** von **nicht beschreibbar** *(Runde 2, Befund S-13: zwei verschiedene Ursachen, zwei verschiedene nächste Schritte)*. Ist die Kette im Übrigen sauber grün, ist dieser Hinweis die **einzige** Meldung: Bei sauberem Grün schweigt das Gate (6.12.15), ausser das Zählwerk oder die Sperre (e) sind ausgefallen. Ausserhalb der Zeitgrenze endet das Gate **nie** mit einem anderen Wert als 0 oder 2 |

**Weshalb das blockierend zu benennen war.** Rückgabewert 1 blockiert nicht
(3.4, CLAUDE.md, "Aktive Gates"). Ein Gate, das an einer fehlenden
Umgebungsvariablen mit 1 endet, lässt genau in der Lage durch, in der es am
wenigsten weiss — die gefährliche Richtung aus 6.8.4, Punkt 3, und aus 6.12.4.
Dass der Ausfall harmlos aussieht, macht ihn nicht harmlos: Er tritt in einer
fremden Umgebung ein, nicht in der, in der man ihn sucht.

**Weshalb trotzdem kein eigener Ausgang.** Das Zustandsverzeichnis trägt nach
6.12.11 allein das Zählwerk und nicht das Urteil. Ein blockierender Ausgang
machte ein Gate, das nicht zählen kann, auch bei grüner Kette rot — ein Gate,
das nichts mehr durchlässt. Die gewählte Behandlung ist die einzige, die in
**beiden** Richtungen richtig ist: nicht durchlassen, weil nicht gezählt werden
kann, und nicht blockieren, weil nicht gezählt werden kann. Sie ist ausserdem
schon entschieden — für den nicht beschreibbaren Fall in 6.12.11 — und wird
hier nur auf den zweiten Weg ausgedehnt, auf dem dasselbe Ergebnis eintritt.

**Jede `exit`-Anweisung des Gates mit festem Wert trägt 0 oder 2** (Fremdbeleg
aus beiden Prüfrunden, je ausgeführt; diese Rolle hat nicht nachgezählt). So —
und ausdrücklich **nicht** als Zahl von Fundstellen — ist der Entscheid
formuliert: Eine Zahl veraltet mit der nächsten geänderten Zeile und wäre beim
nächsten Lauf falsch, ohne dass jemand etwas Falsches getan hätte. Prüfbar ist
die Aussage über `grep -nE '(^|[;&|{] *)exit [0-9]+'` über das Skript; keine
Fundstelle darf einen anderen Wert tragen. *(Runde 3, Befund S3-04: Der zuerst
genannte Ausdruck `^\s*exit [0-9]+` fand nur `exit`-Anweisungen am Zeilenanfang
und übersah ein eingebettetes `exit 2` in der `mktemp`-Zeile — ein Prüfmittel,
das einen Teil des Gegenstands nicht sieht, ist die Fehlerklasse aus 6.9.2.)* Nicht "das Gate soll nicht mit 1 enden",
sondern "es gibt keine Stelle, an der es das könnte".

**d) Der Durchlass nach der Eskalation löscht den Zähler nicht**
*(Befund N-07; ergänzt 6.12.9)*

| | |
|---|---|
| **Vorher galt** | "Ein **Durchlass** löscht den Zähler", mit zwei Ausnahmen: der Durchlass wegen `stop_hook_active` (G9) und das Nichtlaufen für eine Rolle ohne veränderndes Werkzeug (G13) |
| **Jetzt gilt** | Eine **dritte** Ausnahme: Der Durchlass ab dem vierten Mal nach 6.12.9 — die Übergabedatei mit der Eskalationszeile liegt vor — **löscht den Zähler nicht**. Das Kriterium ist erneut gescheitert, also zählt der Zähler wahrheitsgemäss weiter (4, 5, 6), und die Meldung nennt das n-te Mal *(Runde 2, Befund DT2-B1: Die erste Fassung dieses Nachtrags schrieb "lässt den Zähler unverändert"; das war so nie entschieden und ist hiermit berichtigt — nicht gelöscht heisst **weitergezählt**, nicht eingefroren.)* |

**Weshalb.** Der Zähler dokumentiert die Eskalation, bis ein grüner Lauf die
Serie beendet. Löschte der Durchlass ihn, begänne die Zählung beim nächsten
`Stop` derselben Sitzung wieder bei eins: Das Gate blockierte **dreimal neu** am
unverändert roten Kriterium und verlangte für dasselbe Problem eine **zweite**
Übergabedatei. Das wäre die Eskalation als Formel — genau das, was 6.12.9 mit
der Bedingung "neu, geändert oder in `HEAD` enthalten" ausschliessen will, und
das Gegenteil dessen, was 3.4 mit dem Abbruch bezweckt: Ein Problem, das sich
nicht von innen lösen lässt, wird **einmal** vorgelegt und nicht in
Dreierschritten wiederholt.

Gelöscht wird der Zähler weiterhin von einem Durchlass, der das Kriterium
wirklich hinter sich lässt — einem Lauf ohne diese Abweichung. Das ist der
Unterschied, auf den es ankommt: Ein Durchlass, der etwas **feststellt**,
löscht; ein Durchlass, der nur **weiterlässt**, löscht nicht. Für
`stop_hook_active` und für G13 gilt derselbe Satz, und er stand dort schon.

**Ausgeführt belegt** (Fremdbeleg aus beiden Prüfungen der zweiten Runde): Über
sechs Läufe am selben Kriterium trägt die Zählerdatei nacheinander 1, 2, 3, 4,
5 und 6; die Forderung nach der Übergabedatei wird **nur beim dritten Mal**
erhoben, und die Zählung beginnt nicht neu. Damit ist die Aussage geprüft und
nicht bloss behauptet — der Unterschied, auf den V12 in diesem Abschnitt
mehrfach zurückkommt.

**e) Die Sperre entfällt nicht still, wenn das Zustandsverzeichnis fehlt**
*(Befund N-04; ergänzt 6.12.13)*

| | |
|---|---|
| **Vorher galt** | Die Sperrdatei liegt im Zustandsverzeichnis, ausserhalb des Arbeitsbaums (G12). Damit hing die Sperre an derselben Bedingung wie das Zählwerk — war das Verzeichnis nicht beschreibbar, entfiel sie **still** |
| **Jetzt gilt** | Die Sperrdatei liegt im Zustandsverzeichnis; ist dieses nicht beschreibbar oder nicht bestimmbar (c), unter **`/tmp`** — fest, **nicht** `TMPDIR` —, mit demselben Namen aus dem Hash des Baumpfads. Geht auch das nicht, läuft das Gate **ohne Sperre** und sagt das **in jeder Meldung** |

**Weshalb kein blockierender Ausgang.** Die Sperre schützt vor falschem
**Rot**: Zwei gleichzeitige eigene Läufe gegen denselben Baum stören einander
über D19 (6.12.13). Sie schützt nicht vor falschem Grün. Ihr Ausfall darf
deshalb die Arbeit nicht anhalten — er darf aber auch nicht unsichtbar sein,
denn ein `VERLETZT` ohne Sperre hat eine zweite mögliche Ursache, und die
Meldung muss sie nennen, damit niemand einen Befund für bare Münze nimmt, den
das Gate selbst mitverursacht haben kann. Das ist genau die Grenze, die 6.12.13
unter "Die Grenze, die bleibt" schon offen ausspricht, hier für den Fall des
ausgefallenen Verzeichnisses.

**Weshalb `/tmp` fest und nicht `TMPDIR`.** Eine Sperre wirkt nur, wenn alle
Beteiligten **dieselbe** Datei nehmen. `TMPDIR` kann je Prozess verschieden
gesetzt sein; zwei Läufe mit verschiedenem `TMPDIR` hielten zwei verschiedene
Sperren und liefen doch gleichzeitig. Eine Sperre, die nicht sperrt, ist
schlechter als keine, weil man sich auf sie verlässt. `/tmp` liegt zudem
ausserhalb jedes Arbeitsbaums; der Kettengrundsatz aus 6.1.3 bleibt gewahrt.

**f) Die Wegwerfdatei liegt nachweislich ausserhalb des Baums**
*(Befund N-06; ergänzt 6.12.15 und 6.12.9)*

| | |
|---|---|
| **Vorher galt** | 6.12.15 verlangt, dass das Gate Standard- und Fehlerausgabe der Kette gemeinsam abfängt; **wo** die Ausgabe zwischenliegt, sagt der Entwurf nicht. Der Bau nahm `mktemp`, und `mktemp` folgt `TMPDIR`. Zeigt `TMPDIR` in den Arbeitsbaum, entsteht die Datei im **beurteilten** Baum, und D19 meldet `VERLETZT` |
| **Jetzt gilt** | Nach dem Anlegen prüft das Gate den **physisch aufgelösten** Pfad der Wegwerfdatei. Liegt er im geprüften Baum, wird die Datei gelöscht und unter `/tmp` neu angelegt. Gelingt auch das nicht, endet das Gate mit **2** und dem Schlüssel `GATE mktemp` |

**Weshalb.** Das ist der Kettengrundsatz aus 6.1.3, auf das Gate angewandt —
dieselbe Überlegung, die den Zähler aus dem Baum genommen hat (G8) und die
Sperrdatei (G12). Ein Gate, das den Befund erzeugt, den es meldet, misst sich
selbst; und weil D19 den ganzen Lauf einklammert, wäre der Befund nicht einmal
falsch, sondern richtig und trotzdem wertlos. **Geprüft** wird der Pfad und
nicht bloss angenommen, weil `TMPDIR` von aussen kommt — V12: Ein genannter
Massstab, den niemand prüft, ist keiner.

**Weshalb hier ausnahmsweise blockiert wird.** Ohne Wegwerfdatei kann das Gate
die Ausgabe der Kette nicht auffangen und also nicht auswerten; ohne Auswertung
gibt es kein belegtes Grün (6.12.4). Der Ausgang gehört damit zu den
Prüfmitteln des Gates und nicht zur Meldung — deshalb steht `mktemp` in g) auch
in der Tabelle 6.12.11.

**Die zweite Hälfte desselben Befunds** *(Runde 2, Befund DT2-B2, ausgeführt
belegt mit einem Beobachter im 20-ms-Takt; Fremdbeleg)*. Das Gate reichte
`TMPDIR` unverändert an `make dod` durch. Zeigt `TMPDIR` in den geprüften Baum,
legt die **Kette selbst** dort eine Datei an — die Ziele `nachweise` und
`abdeckung` rufen je `mktemp` auf —, für rund 0,4 s. **D19 sieht sie nicht**:
Die Rahmenprüfung misst Prüfsummen der versionierten Dateien. Das Gate hätte
seinen eigenen Grundsatz also gewahrt und die Kette gegen ihn laufen lassen,
ohne dass ein Befund entstünde — der Fall, vor dem 6.8.4 warnt: Ein
Rückgabewert 0 sagt nur, was gefunden wurde, nicht, dass nichts geschehen ist.

**Entscheid:** Der Kettenlauf erhält `TMPDIR` gleich dem Verzeichnis der
geprüften Wegwerfdatei des Gates — also demjenigen Verzeichnis, von dem oben
nachgewiesen ist, dass es ausserhalb des Baums liegt. Damit gilt der
Kettengrundsatz aus 6.1.3 für beide Seiten, und er gilt aus dem richtigen
Grund: nicht, weil D19 nichts gemeldet hat, sondern weil im Baum nichts
entsteht. Eine Umgebungsvariable, die das Gate von aussen ungeprüft
weiterreicht, ist ohnehin die Lücke, die 6.6.1 an `$(UV)` schon einmal
schliessen musste.

**g) Zwei weitere Prüfmittel des Gates: `sha256sum` und `mktemp`**
*(Befund N-09 und eine Ergänzung des Koordinators; ergänzt 6.12.11)*

| | |
|---|---|
| **Vorher galt** | 6.12.11 zählt **sieben** Prüfmittel, sechs davon blockierend. `sha256sum` — mit dem die Namen von Sperr- und Zählerdatei aus dem Pfad des geprüften Baums gebildet werden — und `mktemp` kommen darin nicht vor, obwohl das Gate beide braucht |
| **Jetzt gilt** | Beide stehen in der Tabelle. Fehlt eines, ist das **Lage C des Gates**, Rückgabewert 2, Schlüssel `GATE sha256sum` beziehungsweise `GATE mktemp`, und die Meldung nennt den Beschaffungsweg — beide gehören zu den coreutils |

**Weshalb das nachzutragen war.** V12 verlangt, dass ein genanntes Prüfmittel
auch geprüft wird. Die Umkehrung gilt genauso und ist hier der Punkt: **Was der
Code braucht, gehört in die Tabelle** — sonst fällt es ungenannt aus, und das
Gate scheitert an einer Stelle, für die es keine Meldung hat. Ein fehlendes
`sha256sum` nähme ihm die Namensbildung für Sperre und Zähler, ein fehlendes
`mktemp` die Auswertung der Ausgabe; beides ist ein Ausfall des Instruments und
kein Befund am Gegenstand (6.9.2).

**Zur Zahl im Text darunter.** Der Absatz "Die Präzedenz" in 6.12.11 spricht von
"allen sechs blockierenden Prüfmitteln". Diese Zahl wird **nicht
umgeschrieben** — sie war am 2026-09-02 vor der Verifikation richtig.
Massgeblich ist nach Regel 2 aus 6.2.2 die **Tabelle**, und sie führt seit
diesem Nachtrag **acht** blockierende Prüfmittel und neun insgesamt; ein
Verweis an Ort sagt das. Der Satz selbst — jede Meldung nennt das fehlende
Mittel und den Beschaffungsweg — gilt unverändert für alle.

**h) Reihenfolge der Selbstprüfungen und der `LISTE`-Schlüssel**
*(Befund N-05; präzisiert 6.12.23 b)*

| | |
|---|---|
| **Vorher galt** | 6.12.23 b sagt: bei mehreren fehlerhaften Zeilen "die erste in Dateireihenfolge" — ohne Rücksicht darauf, dass die Selbstprüfungen **3** (der Schritt meldet eine andere Lage als C) und **5** (die Marke nennt ein anderes Prüfmittel als der Schlüssel) die Ausgabe der Kette brauchen, die Selbstprüfungen **2**, **4** und **6** dagegen nicht |
| **Jetzt gilt** | Die **strukturellen** Selbstprüfungen 2, 4 und 6 laufen **vor** der Kette über die ganze Liste. Blockiert wird mit der fehlerhaften Zeile mit der **kleinsten Zeilennummer**, gleich welcher der drei Prüfungen sie zuzuordnen ist. Erst wenn alle drei bestehen, läuft die Kette; danach laufen 3 und 5 über alle Einträge, und wiederum blockiert die erste in Dateireihenfolge |

**Zwei Gründe, und beide stehen schon in diesem Abschnitt.** Erstens: Eine
strukturell fehlerhafte Liste ist zu berichtigen, **bevor** die Kette bis zu
zehn Minuten läuft (G11). Das ist keine Bequemlichkeit, sondern die Rangfolge
aus 6.12.23 b — solange das Instrument beanstandet ist, wird über den
Gegenstand ohnehin nicht geurteilt. Zweitens: Der Schlüssel muss über Läufe
hinweg **stabil** sein, sonst zählt 3.4 nie dreimal dasselbe Kriterium
(6.12.9). Hinge die Auswahl davon ab, welche Prüfung zufällig zuerst anschlägt,
trüge dieselbe unveränderte Liste in zwei Läufen zwei Schlüssel — und die
Eskalation griffe nie. Die kleinste Zeilennummer ist die einzige Ordnung, die
von der Prüfreihenfolge unabhängig ist.

Die Selbstprüfungen bleiben in **Zahl, Inhalt und Wirkung unverändert**; dieser
Entscheid ordnet allein, wann sie laufen und welcher ihrer Befunde zählt.

**Die Rangfolge, um einen Schlüssel ergänzt** *(Runde 3, Befund S3-06)*. Sie
lautet vollständig: `GATE …` — `KETTE ausgabe-unlesbar` — `LISTE …` — die erste
Abweichung in Kettenreihenfolge — `D19 …`. Neu ist allein die zweite Stelle:
Ohne lesbare Ausgabe der Kette lässt sich **keine** Deckungsprüfung anstellen,
denn die Selbstprüfungen 3 und 5 vergleichen mit der gemeldeten Lage und mit
der Marke. Ein Zählschlüssel aus der Liste über eine Ausgabe, die niemand lesen
konnte, wäre eine Aussage über nichts. Der Bau verhält sich bereits so
(Fremdbeleg): Die Markenzahlprüfung aus k) läuft vor `LISTE 3` und `LISTE 5`;
hier wird das entschieden statt geduldet.

**i) Was der Selbsttest zusätzlich zu decken hat**
*(Befunde N-02 und N-03 der statischen, DT-B4 und DT-B5 der dynamischen
Prüfung; ergänzt 6.12.19)*

| | |
|---|---|
| **Vorher galt** | 6.12.19 verlangt einen Fall für die D19-Zeile "in allen vier Schlüsselwortformen, je mit und ohne Zusatztext" und einen G13-Fall für "den belegten Fall `static-software-tester` und `pentester`". Zu G12 — welcher Arbeitsbaum geprüft wird — führt die Falltabelle **keine** Zeile |
| **Jetzt gilt** | Der Fall zur D19-Zeile deckt **alle acht** Kombinationen. Der G13-Fall verwendet die **echten** Rollendateien `static-software-tester.md` und `pentester.md` aus `.claude/agents/`, in den Scheinbaum kopiert, dazu einen Gegenfall mit `devops-engineer.md`. Neu hinzu kommen Fälle für **G12** und je einer für die Entscheide a), c), e), f), g) und h) sowie für den Makefile-Befund N-08. Der Fall zur committeten Übergabedatei muss diese **nachweislich in `HEAD`** haben. Die Zeilen stehen in der Tabelle 6.12.19 und tragen dort den Vermerk |

**Weshalb die echten Rollendateien (N-03).** G13 misst den **Gegenstand** — hat
diese Rolle ein Werkzeug, über das ADR 0001 Schreibrecht vergibt? — und nicht
einen Namen (6.12.14). Ein Selbsttest gegen erfundene Rollendateien prüft die
Formannahme des Gates gegen sich selbst; genau das schliesst 6.12.19 mit dem
zweiten Prüfweg aus. Ändert sich das `tools:`-Feld einer der drei echten
Dateien, muss der Selbsttest es merken — sonst ist er in dem Augenblick still
falsch, in dem er gebraucht würde.

**Weshalb G12 eigene Fälle bekommt (DT-B5).** Der Entscheid a) ist die Antwort
auf drei blockierende Befunde, die alle daran hingen, wie das Gate den Baum
bestimmt. Ein Entscheid, dessen Fälle in der Prüftabelle fehlen, ist ein
genannter Massstab ohne Prüfung — V12, und in diesem Abschnitt zum vierten Mal
dieselbe Fehlerklasse. Gedeckt sind deshalb: `cwd` im Unterverzeichnis, mit
Schrägstrich am Ende und über einen Symlink; `cwd` ausserhalb jedes
Arbeitsbaums dieses Repositories; und der zweite Arbeitsbaum (`git worktree`),
für den G12 überhaupt gebaut ist.

**Weshalb der Fall zur committeten Übergabedatei nachzuschärfen ist (DT-B4).**
Der Fall hat bestanden, ohne seine Behauptung zu belegen: Die Übergabedatei war
im Augenblick der Prüfung weder neu noch geändert noch in `HEAD` — der
Hilfscommit hatte nichts zu committen (Fremdbeleg). Das ist ein Mangel am
**Prüfmittel**, nicht am Gegenstand: Das Gate selbst verhält sich richtig, ein
eigener Lauf des Testers mit committeter Übergabedatei auf `TaskCompleted`
endete mit 2 (Fremdbeleg). Ein grüner Prüffall, der nichts gemessen hat, ist
aber die gefährlichste Zeile einer Prüftabelle — er sieht aus wie Deckung und
ist keine. Dieselbe Unterscheidung wie in 6.9.2, eine Ebene höher.

**Der Makefile-Befund N-08.** Meldet D12 Lage C und fehlen **mehrere**
Gegenstände, so nennt `FEHLT=` den **ersten**; ein späterer `if`-Block
überschreibt ihn nicht. Das ist keine neue Regel, sondern die Anwendung von G6:
Die Marke trägt das fehlende Prüfmittel, und der Schlüssel der terminierten
Lagen wird gegen genau diesen Wert geprüft (Selbstprüfung 5). Wechselte der
Wert je nach Prüfreihenfolge, träfe ein gültiger Eintrag die Marke einmal und
einmal nicht, und das Gate blockierte mit einer Begründung, die nicht stimmt.
Der Selbsttest erhält dafür einen eigenen Fall.

**j) Der Stand der Verifikation — Fremdbeleg, und was er nicht sagt**

Alles in diesem Abschnitt ist Fremdbeleg aus den beiden Prüfberichten vom
2026-09-02 und den Läufen des Koordinators; diese Rolle hat nichts ausgeführt
und nichts nachgeprüft (3.4).

1. **Der Selbsttest `scripts/dod-gate-selbsttest.sh` bestand vor dieser Runde
   50 von 50 Fällen.** Der Fremdbeleg "48 von 48" in 6.12.23 d bleibt als
   damaliger Stand stehen und wird nicht umgeschrieben — er war am 2026-09-02
   richtig, und ein vergangener Stand belegt einen vergangenen Stand
   (Abschnitt 9, letzter Absatz).
2. **Die statische Prüfung ist nicht bestanden**: vierzehn Befunde, fünf davon
   blockierend (B-01 bis B-05).
3. **Die dynamische Prüfung ist ebenfalls nicht bestanden**: fünf Befunde, drei
   davon blockierend. Die drei blockierenden — `cwd` in einem Unterverzeichnis
   ergab `GATE Makefile`, ein Pfad mit Schrägstrich am Ende und ein Pfad über
   einen Symlink ergaben `KETTE baum-widerspruch` — haben dieselbe Ursache wie
   B-02 und B-03 und sind mit Entscheid a) gedeckt. Die beiden nicht
   blockierenden (DT-B4, DT-B5) betreffen den Selbsttest und sind in i)
   aufgenommen.
4. **Ohne Beanstandung geprüft** hat die dynamische Prüfung: die
   Ende-zu-Ende-Eskalation nach 3.4 in neun Läufen (Zähler 1, 2, 3 mit der
   Eskalationszeile; ohne Übergabedatei weiter 2; mit neuer und mit committeter
   Übergabedatei 0; `TaskCompleted` trotzdem 2; ein anderer Schlüssel zählt neu
   bei 1; ein Durchlass löscht den Zähler); den Reentranz-Schutz
   (`stop_hook_active` bei `Stop` → 0 ohne Lauf der Kette; bei `TaskCompleted`
   nicht ausgewertet, die Kette lief); `SubagentStop` mit den echten Rollen
   (`static-software-tester` und `pentester` → 0 ohne Lauf; `devops-engineer` →
   Kette läuft; unbekannte, leere und plugin-bezogene Rolle → Kette läuft); die
   Manipulationsfälle (fehlende Marke → `KETTE marke-fehlt`; Listeneintrag mit
   existierendem Pfad → `LISTE 2 …`; Eintrag ohne ADR-Grund → `LISTE 4
   <Zeilennummer>`; ein fremder Schreiber während des Laufs → `D19 VERLETZT`);
   die innere Zeitgrenze; die Nebenläufigkeit (zwei Läufe durch `flock`
   serialisiert, drei Sitzungen drei Zähler); und die Ausgabeform (auf der
   Standardausgabe genau ein JSON-Objekt mit `systemMessage` beim Durchlass,
   nichts beim Block, nie die Ausgabe der Kette).
5. **Die gemessene Laufzeit gehört zu O-20 und schliesst ihn nicht.** Gemessen
   wurden 6,4 bis 7,0 s je Lauf des Gates auf dem echten Baum (Mittel 6,65 s)
   und 7,6 bis 8,2 s für einen vollständigen Lauf im Klon. Das ist der heutige
   Stand **ohne** `backend/` und `deploy/`; O-20 fragt nach der Laufzeit **mit**
   dem Grundgerüst und bleibt offen. Die Grenzen von 600 s und 900 s bleiben
   unverändert, bis der Auftraggeber entscheidet (Abschnitt 8, O-20).
6. **Ein Hinweis des Testers, kein Befund**, hier verzeichnet, damit die Frage
   nicht ein zweites Mal gestellt wird: Meldet ein Lauf drei terminierte Lagen C
   **und** D19 `VERLETZT`, trägt die Schlusszeile **Form 2** und nicht Form 4.
   Das ist genau die Prüfreihenfolge aus 6.12.23 a — Lage C vor D19 —, und sie
   nimmt der D19-Aussage nichts: Sie steht in ihrer eigenen Zeile, wird dort
   gelesen, und der Zählschlüssel bleibt `D19 VERLETZT`. Kein Entscheid ändert
   sich.
7. **Was nach der Behebung gilt, belegt die zweite Prüfrunde — nicht dieser
   Nachtrag.** Er entscheidet zehn Punkte; ob der Bau sie erfüllt, stellen
   Static und Dynamic Software Tester auf einem anderen Modell fest (3.4), und
   die Rollen, die gebaut haben, prüfen ihre eigene Arbeit nicht. Unverändert
   bestehen bleibt auch die Forderung aus 6.12.23 d: Solange der grüne Lauf
   gegen das **echte** `Makefile` nicht mit **Rückgabewert 0 der Kette** belegt
   ist, gilt der Selbsttest als **nicht vollständig** — 50 bestandene Fälle
   ändern daran so wenig wie zuvor 48.

**Die zweite Prüfrunde vom 2026-09-02 (Fremdbeleg, nachgetragen).** Sie hat
stattgefunden, und ihr Ergebnis gehört hierher, weil Punkt 7 sie ausdrücklich
zum Massstab erklärt hat:

8. **Alle fünf blockierenden Befunde aus Runde 1 sind mit eigenen Läufen als
   behoben belegt**, statisch wie dynamisch. Der Selbsttest besteht **67 von
   67** Fällen.
9. **Beide Prüfungen sind wegen neuer Punkte nicht bestanden.** Statisch:
   dreizehn Befunde, vier davon blockierend — **S-01** (die Klassifizierung von
   D19 Lage B bei Rückgabewert 0) und **S-03**, **S-04**, **S-05** (drei
   fehlende Selbsttestfälle). Dynamisch: zwei Befunde und ein Hinweis,
   blockierend **DT2-B1** — der Wortlaut von d). Alle sind oben eingearbeitet:
   S-01 und S-10 als Vermerke in 6.12.4, S-11 als Entscheid k), S-13 in c),
   DT2-B1 in d), DT2-B2 in f), die fehlenden Fälle in der Tabelle 6.12.19.
10. **Der Lauf am echten Bestand** (Fremdbeleg): `make dod` im echten Baum
    endete mit **Form 2** — Lage C bei D7, D10 und D12 —, Rückgabewert 2; der
    unmittelbare Aufruf des Gates auf dieselbe Ausgabe endete mit **0** und der
    `systemMessage` "Durchlass mit terminierten Lagen C". Das ist genau der
    Ausgang, den G4 vorsieht, und er ist damit erstmals am echten Bestand
    beobachtet. Die Forderung aus 6.12.23 d ist davon zu trennen und nach
    Fremdbeleg **erfüllt**: Selbsttestfall 28 lässt das **echte** `Makefile`
    in einem Scheinbaum laufen, und beide Prüfer belegen für ihn **Rückgabewert
    0 der Kette** mit Schlusszeile Form 1 (Static Software Tester, Runde 1 und
    2; Dynamic Software Tester, Runde 1 und 2). Am echten Bestand selbst ist
    ein grüner Lauf erst möglich, wenn die drei terminierten Lagen C durch die
    Skripte des Grundgerüsts abgelöst sind — das ist kein Mangel des
    Selbsttests, sondern der belegte Zustand nach 6.12.5.
11. **Eine Beobachtung des Static Software Testers, die hier festgehalten
    wird**: Die Fehlerklasse "ein Selbsttestfall besteht, ohne seine Behauptung
    zu belegen" ist nun **zweimal** aufgetreten — DT-B4 in Runde 1, S-01 in
    Runde 2. Beim **dritten** Mal greift 3.4 für dieses Kriterium: abbrechen,
    Übergabedatei schreiben, dem Auftraggeber vorlegen. Das steht hier, damit
    die Zählung nicht mit jeder Runde von vorn beginnt — dieselbe Überlegung,
    aus der d) den Zähler weiterlaufen lässt.
12. **Die dritte Prüfrunde vom 2026-09-03 (Fremdbeleg).** Alle **dreizehn**
    Befunde aus Runde 2 sind mit eigenen Läufen **beider** Prüfer als behoben
    belegt; der Selbsttest besteht **81 von 81** Fällen, unabhängig
    reproduziert; `make dod` im echten Baum endete mit **Form 2** (D7, D10 und
    D12 terminiert), Rückgabewert 2, und der Aufruf des Gates darauf mit **0**
    und der `systemMessage` "Durchlass mit terminierten Lagen C".
13. **Statisch gleichwohl nicht bestanden.** Blockierend ist **S3-01**: Die
    Blockmeldung nennt nur den **gezählten** Schlüssel und nicht alle
    Abweichungen, während 6.12.9 und die Tabellenzeile 6.12.19 (Runde 1, B7)
    verlangen: gezählt wird eine, verschwiegen wird keine. Ausgeführt belegt an
    einem Lauf mit zwei ungedeckten Lagen C, einem `A_FAIL` und D19 `VERLETZT`
    — genannt wurde allein D7. Der zugehörige Selbsttestfall ist grün, **ohne
    diese Hälfte der Zusicherung zu messen**. Nicht blockierend: **S3-02** (die
    Fälle zur Markenzahl decken nur Form 1), **S3-03** (drei Tabellenzeilen
    verlangten eine Meldung bei sauberem Grün, die 6.12.15 ausschliesst),
    **S3-04** (der in c) genannte `grep`-Ausdruck übergeht ein eingebettetes
    `exit 2` in der `mktemp`-Zeile), **S3-05** (bleibt das Verzeichnis der
    Wegwerfdatei unauflösbar, fällt die Wache **offen** aus), **S3-06**
    (`KETTE ausgabe-unlesbar` ist in der Rangfolge nicht eingeordnet, während
    die Markenzahlprüfung im Bau bereits vor `LISTE 3` und `LISTE 5` läuft),
    **S3-07** (der Fall zu d) prüft nicht, dass die Forderung nach der
    Übergabedatei kein zweites Mal erhoben wird). S3-03, S3-04 und S3-06 sind
    als Berichtigungen an Ort eingearbeitet — in den drei G12-Zeilen der
    Tabelle 6.12.19, im `grep`-Ausdruck in c) und in der Rangfolge in h).
14. **Dynamisch ebenfalls nicht bestanden.** **DT3-B1**: Zeigt `TMPDIR` in den
    geprüften Baum, legt das Gate seine Wegwerfdatei **zuerst dort** an und
    verlagert sie erst nach rund **6,9 ms** (Beobachter ohne Wartezeit, 922
    Treffer; der 20-ms-Takt der zweiten Runde sah davon nichts). Das entspricht
    dem **Wortlaut** von f) — geprüft wird **nach** dem Anlegen — und verletzt
    gleichwohl den Kettengrundsatz aus 6.1.3, den f) auf das Gate anwendet. Ein
    Entscheid, dessen Wortlaut erfüllt ist und dessen Zweck verfehlt wird, ist
    ein Mangel des Entscheids und nicht des Baus; die Behebung steht unten als
    Vorschlag. Die übrigen sechs Prüfpunkte blieben **ohne Beanstandung**: Die
    Kette legt nichts mehr im Baum an; der Zähler trägt 1 bis 7 über sieben
    Läufe; eine Umbenennung über `git mv` wird erkannt; das nicht bestimmbare
    Zustandsverzeichnis verhält sich bei Grün wie bei Rot richtig; fünf
    Klassifizierungsfälle und die Ausgabeform sind in Ordnung.
15. **Dieselbe Fehlerklasse zum dritten Mal — die Arbeitseinheit ist
    abgebrochen.** "Ein Selbsttestfall besteht, ohne seine Behauptung zu
    belegen" ist mit S3-01 zum **dritten** Mal aufgetreten (DT-B4 in Runde 1,
    S-01 in Runde 2, S3-01 in Runde 3). Punkt 11 hat genau diesen Fall
    vorgezeichnet, und 3.4 verlangt dann den Abbruch. Der Koordinator hat die
    Einheit am **2026-09-03** abgebrochen;
    `docs/uebergaben/2026-09-02_r3-q-001-gate-gebaut.md` trägt die Zeile
    `Eskalation 3.4: Selbsttestfall besteht, ohne seine Behauptung zu belegen`.
    **Vorgelegt wird nicht die vierte Einzelbehebung**, sondern die Frage
    dahinter — die Beobachtung des Static Software Testers: Die Tabelle 6.12.19
    führt je Zeile **mehrteilige** Erwartungen, der Selbsttest je Fall **eine**
    Zusicherung; wo eine Zeile mehr verspricht als Rückgabewert und Schlüssel,
    bleibt der Rest ungemessen. Wie eine solche Zeile in einzeln prüfbare
    Zusicherungen zerlegt wird, ist als **O-24** in Abschnitt 8 terminiert und
    liegt beim Auftraggeber.
16. **Fünf Behebungen als Vorschlag, nicht als Entscheid.** Sie gehören in die
    nächste Einheit **nach** dem Entscheid zu O-24, weil eine vierte
    Einzelbehebung an derselben Fehlerklasse genau das wäre, was 3.4
    ausschliesst: (1) zu S3-01 — die Blockmeldung führt **alle** Abweichungen
    auf, gezählt wird weiterhin **eine**; (2) zu DT3-B1 — das Zielverzeichnis
    der Wegwerfdatei wird **vor** dem Anlegen bestimmt, die Prüfung danach
    bleibt als Wache stehen; (3) zu S3-05 — ein unauflösbares Verzeichnis ist
    `GATE mktemp` und damit fail-closed; (4) zu S3-02 und (5) zu S3-07 die
    fehlenden Selbsttestfälle. Dieser Nachtrag **entscheidet sie nicht**.

**k) Das Gate prüft die Zahl der Marken gegen die Selbstaussage der Kette**
*(statischer Befund S-11 aus Runde 2; ergänzt 6.12.3 und 6.12.4)*

*(Dieser Entscheid steht hinter j), weil Buchstaben so wenig umnummeriert
werden wie D-Nummern (6.1.2). Entscheide sind a) bis i) und k); j) verzeichnet
die Beleglage beider Prüfrunden.)*

| | |
|---|---|
| **Vorher galt** | 6.12.3 sagt, das Gate zähle **nicht** die Kettenschritte und lese "die Aussage, nicht die Zahl"; 6.12.4 sagt, alles ausser einem belegten Grün blockiere. Zwischen beiden lag eine Lücke: Eine Ausgabe mit Baumzeile, Form-1-Schlusszeile ("alle 14 Kettenschritte durchlaufen … 14 gueltige Marken gezaehlt"), D19 `OHNE_BEFUND`, Rückgabewert 0 und **null** Marken liess das Gate **stumm mit 0** durch (ausgeführt belegt, Fremdbeleg) |
| **Jetzt gilt** | Das Gate vergleicht die Zahl der **gelesenen** Marken mit der Zahl, die die Schlusszeile **selbst nennt** — Form 1 "`<N>` gueltige Marken gezaehlt", Form 2 und Form 4 "alle `<N>` Kettenschritte durchlaufen"; Form 3 (abgebrochen) nennt keine solche Zahl und wird darauf nicht geprüft — und es verlangt **mindestens eine** Marke. Weicht die Zahl ab oder ist keine Marke vorhanden, blockiert es unter `KETTE ausgabe-unlesbar` |

**Weshalb das 6.12.3 nicht widerspricht.** Dort ist entschieden, dass das Gate
**keine eigene** Zahl führt — keine feste Erwartung "vierzehn Schritte", die mit
dem nächsten Kettenschritt falsch würde (V13, und die Tautologie aus Befund A3).
Dieser Entscheid führt keine solche Zahl ein. Er prüft die Kette **gegen sich
selbst**: Ihre Schlusszeile behauptet eine Zahl, ihre Übersicht trägt die
Marken, und beide müssen zusammenpassen. Das ist dasselbe Muster, das die Kette
für ihre eigenen Schritte längst anwendet — zwei Kriterien statt eines — und das
G7 mit der Baumzeile für den Baum eingeführt hat: Eine Selbstaussage wird erst
dann zum Nachweis, wenn sie sich gegen den Inhalt prüfen lässt.

**Weshalb "mindestens eine Marke".** Ohne diese Untergrenze bliebe der teuerste
Fall offen: eine Ausgabe, die null Marken behauptet und null Marken trägt — in
sich stimmig und ohne jedes Urteil. Ein belegtes Grün setzt nach 6.12.4 voraus,
dass die Kette **gelaufen** ist; eine Ausgabe ohne eine einzige Marke belegt
keinen Lauf, sondern nur, dass jemand Zeilen gedruckt hat.

**Weshalb `KETTE ausgabe-unlesbar` und kein neuer Schlüssel.** Der Fall gehört
zur Art "nicht nachweisbar gelaufen", wie eine fehlende Übersichtszeile oder
eine fehlende Schlusszeile (6.12.4). Ein eigener Schlüssel spaltete das
Kriterium des Zählers, ohne dem Bearbeiter etwas anderes zu sagen: Die Ausgabe
der Kette ist unbrauchbar, und der nächste Schritt ist derselbe. Dieselbe
Rangfolge gilt gegenüber `D19 B-widerspruch`, der nach S-01 **vorgeht** — dort
ist die Ausgabe lesbar, und der Widerspruch hat einen Namen.

**Was diese Nachträge nicht ändern.** Kein Entscheid G1 bis G17 wird
zurückgenommen. Die Kernarchitektur aus 5.1, die Entscheide A1 bis A13, der
Modulschnitt aus Abschnitt 4 und die Verankerung der Verfahrensgarantien in 4.2
und 4.3 bleiben unberührt; das Gate steht an keiner Stelle zwischen Freigabe und
Ausführung (5.2). Keine D-Nummer wird vergeben, und die Nummernregel aus 6.1.2
bleibt in Kraft. Die sechs Selbstprüfungen der terminierten Lagen bleiben in
Zahl, Inhalt und Wirkung unverändert — h) ordnet allein ihre Reihenfolge. Die
vier Schlusszeilen aus G7 und ihre Zuordnung aus 6.12.23 a bleiben unverändert.
Kein Kettenschritt wechselt seine Lage, und kein roter Lauf wird grün. Nichts
hier bereitet Gestrichenes vor (5.17, 5.18, 9.1, 5.10, 5.1). Und nichts hier
ist eine Freigabe: Der Bau läuft auf die Weisung vom 2026-09-02, die förmliche
Freigabe der Entscheidpunkte E-A bis E-K steht aus (Abschnitt 10).


## 7. Konsequenzen

**7.1 Zwei Sprachstacks.** Python im Backend, TypeScript in der Oberfläche. Das kostet eine zweite Werkzeugkette, eine zweite Sperrdatei und eine grössere Lieferkettenfläche in D8 und D11. Angenommen wird das, weil die Alternative — ein Stack — an einer der beiden Seiten teurer wäre: entweder Nachbau der kanonischen Schemata oder handgeschriebene Interaktionslogik ohne geprüfte Bausteine für Barrierefreiheit.

**7.2 Die Garantien sitzen im Aufrufpfad, nicht im einzelnen Werkzeug.** Eine neue Quelle in Etappe 2 erbt Fallbindung, Freigabe, Protokollierung, Positivliste und Kontingentzählung, ohne dass die Anbindung sie selbst umsetzt. Umgekehrt heisst das: An diesem Aufrufpfad wird nichts vorbeigebaut, auch nicht „nur für einen Test". Die Architekturverträge aus 4.3 sind die Stelle, an der das auffällt.

**7.3 Kein zweiter Suchdienst und kein Vektorindex bedeutet weniger Löschwege.** R3-F-020 verlangt, dass eine Löschung jeden Ablageort erreicht. Jeder Speicher, den es nicht gibt, ist ein Nachweis, der nicht zu führen ist. Das ist der praktische Nutzen von A3 und A4, unabhängig von der Betriebsersparnis.

**7.4 Der Modell-Bauweg ist unbequemer als üblich.** Ohne Werkzeugaufrufe des Modells muss die Anwendung Vorschläge als strukturierte Ausgabe prüfen und den Ablauf selbst führen. Das ist mehr Arbeit als der geläufige Weg und der Preis dafür, dass eine Einschleusung in einem Leak-Seiten-Text technisch nichts auslösen kann.

**7.5 Die Oberfläche bleibt zur Hälfte offen — mit Termin.** Rahmenwerk und Bauwerkzeug stehen, Komponentenbibliothek und Designsystem folgen nach R3-F-050. Wer diese Trennung nicht bestätigt, muss entweder die Prototyp-Reihenfolge aus 5.6 aufgeben oder das Abnahmekriterium von R3-C-001 anpassen. Beides ist eine Entscheidung des Auftraggebers, nicht des Software Architects.

**7.6 Betrieb offline, Bau nicht.** Der Betrieb kommt ohne ausgehendes Netz aus. Der Bau braucht eine Paketquelle. Für die Dienststelle heisst das: entweder eine hausinterne Spiegelung oder ein Bauplatz mit Netzzugang und Auslieferung als Image. Das gehört in die Betriebsdokumentation und in Punkt 1 der Bereitschaftsliste.

**7.7 Dieser ADR bildet einen Stand ab.** Ändert sich eine Entscheidung, wird er fortgeschrieben, nicht stillschweigend überholt (`.claude/rules/dokumentation.md`). Nachgeordnete Entscheide entstehen als eigene ADR mit eigener Nummer.

---

## 8. Offene Punkte, die dieser ADR nicht entscheidet

| Nr. | Punkt | Warum heute nicht entscheidbar | Wer entscheidet | Spätestens |
|---|---|---|---|---|
| O-1 | Trennung „Rahmenwerk jetzt, Komponentenbibliothek nach dem Prototyp" (3.8) | Abnahmekriterium von R3-C-001 und 5.6 verlangen Verschiedenes | Auftraggeber; Anpassung des Backlogs durch den Product Owner | mit der Freigabe dieses ADR |
| O-2 | Komponentenbibliothek, Designsystem, Design-Tokens, Zielplattformen, Bibliothek für die Graphbearbeitung | 5.6: fällt nach dem Prototyp-Review, auf Beobachtungen statt Vermutungen | Software Architect mit UX/UI-Designer, Freigabe Auftraggeber; eigener ADR | unmittelbar nach R3-F-050, vor dem ersten Frontend-Produktionscode |
| O-3 | Ort der Durchsetzung des zweiten Faktors (Provider oder R3cOSINT) | Hängt an der MFA-Richtlinie des KapoBE-Mandanten, die noch nicht vorliegt | Software Architect mit Auftraggeber | vor R3-F-052, Etappe 3 |
| O-4 | Einbindungstiefe von TheHive und Cortex — **entfallen am 2026-08-21** | TheHive und Cortex sind mit der Neufassung von Projektauftrag 5.17 gestrichen; die frühere Nennung als zu übernehmende Anbindungen war eine Fehlübertragung aus dem Konzept. Ein Backlog-Eintrag wird nicht mehr angelegt (Begründung: Änderungsprotokoll des Projektauftrags, Abschnitt 8) | entfällt | entfällt |
| O-5 | Erzeugung und Prüfung von PDF/A-3 mit eingebetteten Daten (R3-F-074) | Die Wahl entscheidet über zusätzliche Abhängigkeiten und möglicherweise eine zweite Laufzeitumgebung im Prüfcontainer | Software Architect mit Backend Engineer; eigener ADR | vor Etappe 4 |
| O-6 | Verwaltung der fallbezogenen Schlüssel (4.4, Problem B): wo das Schlüsselmaterial liegt und wie es getrennt von den verschlüsselten Daten gesichert wird | Berührt Sicherung und Wiederherstellung (Bereitschaft 3) und ist mit SecDevOps und Datenschutz gemeinsam zu entscheiden | Software Architect mit SecDevOps und Datenschutzexperte; eigener ADR | vor R3-F-020, Etappe 1 |
| O-7 | Schwellenwerte in D3, D6 und D8 | Sind am Gate als E-07 und E-08 offen | Auftraggeber mit SecDevOps | mit R3-Q-001 beziehungsweise der ersten Umsetzungseinheit mit Code |
| O-8 | Betriebsart für D10 und Form von D12 (Befunde in Abschnitt 6) | Betrifft bestehende Skripte, die anderen Rollen gehören | DevOps Engineer mit Protocol Master | mit R3-Q-001. **Fortschreibung 2026-08-30:** Für D12 kommt die Bindung an den Kettengrundsatz aus 6.1.3 hinzu — die gewählte Form schreibt nicht in den Arbeitsbaum. **Zwölfte Fortschreibung 2026-09-02 (6.12.20, Bau auf Weisung vom 2026-09-02 begonnen, förmliche Freigabe ausstehend):** Termin neu **mit dem Grundgerüst** statt mit R3-Q-001. Weder `scripts/prototyp-trennung-pruefen.sh` noch `scripts/nachweise-vollstaendig.sh` bestehen; ein Entscheid über die Betriebsart eines nicht vorhandenen Skripts wäre eine Absichtserklärung. Der vierte Punkt des Achtung-Hinweises zu R3-Q-001 (Prüfmodus für den Nachweiserzeuger) fällt unter diesen Punkt und erhält keine eigene Nummer |
| O-9 | Anbindungsdaten des Entra-ID-Mandanten | Liegen bei der Informatik der Kantonspolizei Bern | KapoBE Informatik | blockiert nur den Mandantenwechsel, nicht die Entwicklung |
| O-10 — **überholt, siehe die Zeile „O-10 (neu gefasst)" darunter (ADR 0002, Abschnitt 6.11)** | Prüffläche des Arbeitsbaumlaufs in D11: welche Dateien er beurteilt, wie er sich gegenüber `.gitignore` verhält, und wie ein belegter Fehlalarm behandelt wird, dessen Fingerabdruck in den beiden Läufen verschieden ist (6.1.1) | **Neu am 2026-08-30, am selben Tag neu gefasst — diese Zeile bleibt stehen, weil Nummern nicht umnummeriert und Historie nicht umgeschrieben wird (6.1.2), ist aber durch die Zeile darunter ersetzt.** Mit einem ausgeführten Lauf der eingesetzten Werkzeugfassung festzustellen, nicht durch Annahme; berührt Laufzeit und Aussagekraft des Schrittes | DevOps Engineer mit SecDevOps | mit R3-Q-001 |
| O-10 (neu gefasst) | **Beantwortet am 2026-08-30 mit einem ausgeführten Lauf (gitleaks 8.21.2):** `--no-git` beachtet `.gitignore` nicht; eine ignorierte `.env` oder `*.pem` blockiert die ganze Kette. Entschieden in 6.2.3: Zugangsdaten liegen nicht im Arbeitsbaum (3.11), ausgeschlossen wird ausschliesslich, was kein Repository-Inhalt sein kann, der Schutz wird nicht abgestuft. **Offen bleiben zwei Restfragen:** (a) die namentliche Ausschlussliste für Abhängigkeits- und Bauverzeichnisse samt ihrer technischen Form — Werkzeugkonfiguration oder Aufrufparameter; (b) die betriebliche Form der Ablage von Zugangsdaten ausserhalb des Arbeitsbaums, einschliesslich Einhängung im Prüfstapel und Eintrag in die Betriebsdokumentation | (a) hängt an der eingesetzten Werkzeugfassung und ist mit einem ausgeführten Lauf zu belegen; (b) ist Betrieb und Sicherheit, nicht Architektur | (a) DevOps Engineer mit SecDevOps; (b) SecDevOps mit DevOps Engineer | (a) **zwölfte Fortschreibung 2026-09-02 (6.12.21, Bau auf Weisung vom 2026-09-02 begonnen, förmliche Freigabe ausstehend):** Termin neu **mit der Installation von `gitleaks`, spätestens mit dem Grundgerüst** — die Restfrage ist nur mit einem ausgeführten Lauf der eingesetzten Werkzeugfassung zu belegen, und `gitleaks` ist nicht installiert; (b) mit dem Grundgerüst, vor der ersten Umsetzungseinheit mit Code |
| O-11 | Abgleich für D18: Jedes oberste Paket unterhalb `backend/src/` ist in `backend/importvertraege.toml` als Wurzelpaket genannt — und wo dieser Abgleich sitzt, im Aufruf oder als Vertrag im Prüfer selbst | **Neu am 2026-08-30 (6.3.4).** Nicht baubar, solange `backend/importvertraege.toml` nicht besteht; heute im Makefile nur als Kommentar hinterlegt, und ein Kommentar ist keine Prüflogik. Ohne den Abgleich meldet D18 Lage A, ohne etwas beurteilt zu haben — der Befund aus 6.2.2 | DevOps Engineer mit Backend Engineer | mit dem Anlegen von `backend/importvertraege.toml`, also mit dem Grundgerüst und vor der ersten Umsetzungseinheit mit Fachlogik |
| O-13 — **entschieden am 2026-08-31, siehe 6.7** | Ob die Kette den Zwischenspeicher von `uv` benutzen darf oder ob D1 ohne ihn läuft. **Entscheid des Auftraggebers: ohne.** Umgesetzt mit `UV_NO_CACHE=1` in `$(UV)`, wirksam für jeden `uv`-Aufruf der Kette und von aussen nicht abschaltbar | **Neu am 2026-08-31 (6.6.1).** `--locked` prüft die Prüfsumme beim Herunterladen, nicht noch einmal für ein bereits entpacktes Archiv im Zwischenspeicher; ausgeführt belegt. Wer `HOME` setzen oder in `~/.cache/uv` schreiben kann, erhält damit ein falsches `A_OK` in D1. `--no-cache` schliesst das, kostet aber je Lauf einen vollständigen Ladevorgang und macht die Kette netzabhängig — eine Abwägung zwischen Laufzeit und Beweiskraft, die der Auftraggeber trifft, nicht die Umsetzung | Auftraggeber mit SecDevOps und DevOps Engineer | mit R3-Q-001; spätestens mit dem Lauf auf der Gegenseite (O-12), der denselben Punkt betrifft |
| O-14 | Der Belegprüfer liest das Methodik-Repository an einem **fest verdrahteten, nicht konfigurierbaren Ort ausserhalb dieses Repositories** mit. Offen ist, wie der Ort bestimmt wird, ohne die Aussage des Kettenschrittes an einen einzelnen Arbeitsplatz zu binden | **Neu am 2026-09-01 (6.8.3).** Auf einer Maschine ohne diesen Arbeitsbaum zählt das Skript die betroffenen Zeilen als "nicht prüfbar"; die Zählung geht nicht in den Rückgabewert ein. D20 wird dadurch nicht falsch, aber schwächer — und wie viel schwächer, hängt an der Maschine. `.claude/rules/dokumentation.md` untersagt absolute Pfade der Arbeitsumgebung ausdrücklich für Architecture Decision Records; für ein Skript sagt die Regel nichts, weshalb dieser Punkt eine Abwägung ist und kein Regelverstoss. Die Behebung ist Umsetzung (Umgebungsvariable, Suchpfad oder ausdrückliche Lage-Meldung), nicht Architektur | DevOps Engineer mit dem Protocol Master (Verfolgbarkeit über beide Repositories, 6.6) | mit R3-Q-001 |
| O-15 | **Abnahme des Belegprüfers.** Das Werkzeug ist nach Eskalationsregel 3.4 abgebrochen und nicht abgenommen; seine Selbstauskunft erklärt die Liste ihrer Grenzen ausdrücklich für unvollständig. Offen ist, welches Abnahmekriterium für ein Werkzeug gilt, das eine Nachweiskette blockiert | **Neu am 2026-09-01 (6.8.4).** Die Aufnahme in die Kette hängt nicht an der Abnahme — ein Schritt, der nur Funde hinzufügt und nichts darüber hinaus behauptet, macht die Kette nicht schwächer. Die Abnahme selbst ist damit nicht erledigt: Sie verlangt eine Prüfung auf einem anderen Modell als die Umsetzung (3.4) und eine Entscheidung darüber, ob "die Liste der Grenzen ist unvollständig" als Abnahmekriterium ausreicht. Dazu gehören die beiden benannten, nicht gebauten Prüfungen. **Zwölfte Fortschreibung 2026-09-02 (6.12.18, Bau auf Weisung vom 2026-09-02 begonnen, förmliche Freigabe ausstehend):** Das Gate aus R3-Q-001 stützt sich auf die ganze Kette und damit auf dieses nicht abgenommene Werkzeug; ein Befund von D20 blockiert damit jede Arbeitseinheit. Seit dem 2026-09-02 ist zudem belegt, dass D20 rote Läufe erzeugt, deren Ursache die Umgebung ist (flacher Klon, lokaler Zweig-Ref in einer Übergabe). Die Aufnahme in die Kette hängt weiterhin nicht an der Abnahme; die Dringlichkeit steigt | Static und Dynamic Software Tester, Entscheid über das Abnahmekriterium beim Auftraggeber | vor der Freigabe des Grundgerüsts |
| O-16 — **beantwortet am 2026-09-01, siehe 6.10** | Reichweite der Index-Maskierung gegenüber dem zweiten Teil des D19-Instruments: Macht die Maskierung D19 halb oder ganz blind? **Antwort, mit ausgeführtem Lauf belegt: halb.** Die Statusliste ist für die maskierte Datei blind, die Inhaltsprüfsumme erfasst die Änderung weiterhin | **Neu und geschlossen am 2026-09-01 (6.9.4, 6.10.1).** Die Frage war nur durch einen Lauf zu beantworten und ist in diesem ADR bis dahin in keine Richtung behauptet worden. Folge: Der Entscheid bleibt unverändert, eine Begründungszeile aus 6.9.2 ist berichtigt (6.10.3), und die Befundmeldung ist auf die schwächere, richtige Aussage festgelegt (6.10.2) | beantwortet durch den Koordinator, übernommen als Fremdbeleg | erledigt |
| O-17 | **Löschung einer maskierten, verfolgten Datei.** Die Aufzählung der verfolgten Dateien führt sie weiter, weil sie im Index steht; die Prüfsummenbildung findet die Datei nicht vor. Ob die Aufnahme dadurch abweicht — die Löschung also trotz Maskierung sichtbar wird — oder nicht, ist offen | **Neu am 2026-09-01 (6.10.4).** Der Versuch zu O-16 deckt die Inhaltsänderung einer vorhandenen Datei ab, nicht die Löschung. Dieser ADR behauptet dazu nichts. Am Entscheid ändert die Antwort nichts — die Maskierung bleibt ein Befund, der Ausgang Lage C; sie bestimmt allein, wie weit die Meldung nach 6.10.2 sagen darf, der Inhalt sei beurteilt | DevOps Engineer, Verifikation Static und Dynamic Software Tester (3.4) | mit R3-Q-001 |
| O-18 | Ob die drei Bezugsdokumente in der Prüfmittelspalte von D20 künftig auch auf **Aktualität** und nicht nur auf Vorhandensein zu prüfen sind — eine veraltete Referenzmenge fällt heute durch kein Netz | **Neu am 2026-09-01 (6.11.6).** Der Belegprüfer prüft seit der elften Fortschreibung, dass `docs/05_Product_Backlog.md` und `docs/00_Projektauftrag.md` bestehen, lesbar sind und eine nicht leere Referenzmenge hergeben — nicht, ob diese Referenzmenge noch dem aktuellen Stand entspricht. **Zwölfte Fortschreibung 2026-09-02 (6.12.21, Bau auf Weisung vom 2026-09-02 begonnen, förmliche Freigabe ausstehend):** Der Punkt bleibt offen, mit geschärfter Frage. Ob eine Anforderungskennung noch **gilt**, ist eine Aussage über den Inhalt am Fundort, und die hat 6.8.4 dem menschlichen Review zugewiesen. Maschinell prüfbar wird sie erst, wenn der Backlog je Eintrag ein **maschinenlesbares Statusfeld** trägt — das ist die eigentliche, bisher nicht benannte Vorbedingung und eine Änderung am Format des Backlogs, nicht am Belegprüfer | Software Architect mit dem Static Software Tester; für das Statusfeld Requirements Engineer mit Product Owner | mit R3-Q-001. **Zwölfte Fortschreibung 2026-09-02 (Entwurf):** Termin neu **mit dem Grundgerüst** |
| O-19 | **Die Umgebungsvariable `CLAUDE_CODE_STOP_HOOK_BLOCK_CAP` ist nicht belegt.** **Drei** Stellen des Repositories nennen sie und behandeln sie als gegeben *(dritte Fundstelle ergänzt in Runde 1)*: Projektauftrag 3.4, Ebene 4 ("Die Grenze ist über `CLAUDE_CODE_STOP_HOOK_BLOCK_CAP` anpassbar"), `docs/06_Definition_of_Ready_und_Done.md`, Abschnitt "Durchsetzung", und `docs/adr/0001-rollenmodell.md` ("Ebenso verbindlich sind der Reentranz-Schutz über `stop_hook_active` und die harte Obergrenze über `CLAUDE_CODE_STOP_HOOK_BLOCK_CAP`") — die dritte Stelle erklärt sie sogar für **verbindlich**. In der am 2026-09-02 gelesenen offiziellen Hook-Dokumentation kommt dieser Name nicht vor (selbst geprüft über eine Textsuche in `hooks.md`); dass er auch im Leitfaden fehlt, ist Fremdbeleg. Die Obergrenze 8 steht dort ohne Variablennamen. Offen ist, wie beide Dokumente damit umgehen | **Neu am 2026-09-02 (6.12.2, Bau auf Weisung vom 2026-09-02 begonnen, förmliche Freigabe ausstehend).** Der Entwurf des Gates stützt sich an keiner Stelle auf die Variable und braucht sie auch nicht: Mit dem Reentranz-Schutz aus 3.4 ist eine Folge von acht Blockaden innerhalb eines Beendigungsversuchs ohnehin unerreichbar. Der Befund ist damit nicht dringlich, aber er steht in einem Dokument, das verbindliche Grundlage ist, und wird deshalb nicht stillschweigend übergangen. Diese Rolle ändert weder den Projektauftrag noch `docs/06_Definition_of_Ready_und_Done.md` | Requirements Engineer mit Protocol Master, Entscheid über eine Änderung des Projektauftrags beim Auftraggeber; die Nachführung von `docs/adr/0001-rollenmodell.md` liegt beim Software Architect als Fortschreibung jenes ADR | mit der nächsten Nachführung von `docs/06_Definition_of_Ready_und_Done.md` |
| O-20 | **Laufzeit der Kette und die beiden Zeitgrenzen des Gates.** Festgelegt sind 900 s in `.claude/settings.json`, 600 s für `make dod` im Skript und 120 s Wartezeit auf die Sperre. Ob 600 s reichen, sobald Bau, Containerbau, Testsuite, Abdeckung und die durchgehenden Oberflächenläufe dazukommen, ist nicht gemessen | **Neu am 2026-09-02 (6.12.12 und 6.12.16, Bau auf Weisung vom 2026-09-02 begonnen, förmliche Freigabe ausstehend).** Der heutige Lauf dauert 5,8 s (Fremdbeleg); die Grössenordnung wechselt mit dem Grundgerüst von Sekunden zu Minuten. Reichen 600 s nicht, wäre das Gate regelmässig falsch rot, und ein regelmässig falsch rotes Gate wird entfernt. Reicht die Laufzeit je Beendigungsversuch insgesamt nicht aus, ist auch der Entscheid gegen einen Zwischenspeicher des Urteils (G15) neu zu bewerten. Beides ist mit einem ausgeführten Lauf zu beantworten und als Fortschreibung zu entscheiden, nicht im Skript stillschweigend anzupassen. **Nachtrag 6.12.24 j (Fremdbeleg aus der dynamischen Prüfung vom 2026-09-02, nicht von dieser Rolle nachgeprüft):** Gemessen wurden 6,4 bis 7,0 s je Lauf des Gates auf dem echten Baum (Mittel 6,65 s) und 7,6 bis 8,2 s für einen vollständigen Lauf im Klon. Das ist der Stand **ohne** `backend/` und `deploy/` und beantwortet die Frage nicht — sie lautet, ob 600 s **mit** dem Grundgerüst reichen. **O-20 bleibt offen**, die Grenzen von 600 s und 900 s bleiben unverändert, bis der Auftraggeber entscheidet | DevOps Engineer mit einem ausgeführten Lauf, Verifikation Static und Dynamic Software Tester (3.4); Änderung der Werte als Fortschreibung durch den Software Architect | mit dem Grundgerüst, sobald `backend/` und `deploy/` bestehen |
| O-21 | **Kettenschritt gegen Schwachstellenklassen im eigenen Code** (ruff-Regelgruppe `S`): als Regelgruppe in der bestehenden Konfiguration und damit in D3, oder als eigener Kettenschritt mit eigener Nummer | **Neu am 2026-09-02 (6.12.20, Bau auf Weisung vom 2026-09-02 begonnen, förmliche Freigabe ausstehend).** Punkt 2 des zweiten Achtung-Hinweises bei R3-Q-001, dort ausdrücklich dem Software Architect zugewiesen. Heute nicht entscheidbar, weil es keinen eigenen Python-Code gibt: D3 ist Lage B. Für D3 spricht, dass kein neues Werkzeug entsteht; dagegen das Argument aus 6.1.2 für D18 — eine Aussage über eine Sicherheitseigenschaft soll einen eigenen Rückgabewert haben und nicht mit einem Schwellenwert für Stilwarnungen (E-08, O-7) zusammenfallen | Software Architect mit SecDevOps Engineer; Bau beim Backend Engineer | mit dem Anlegen von `backend/pyproject.toml`, vor der ersten Umsetzungseinheit mit Fachlogik |
| O-22 | **Markdown-Struktur- und Tabellenprüfer** über den Dokumentenbestand: eigener Kettenschritt oder Aufnahme in ein bestehendes Werkzeug, und welche Prüfungen er trägt | **Neu am 2026-09-02 (6.12.20, Bau auf Weisung vom 2026-09-02 begonnen, förmliche Freigabe ausstehend).** Punkt 3 des zweiten Achtung-Hinweises bei R3-Q-001. Der Gegenstand besteht heute — eine verrutschte Spalte in der Rollentabelle ist eine falsch gelesene Bauvorschrift. Er geht **nicht** in D20 auf: D20 urteilt über Herkunfts- und Fundortangaben, ein Strukturprüfer über den Aufbau des Dokuments; das sind zwei Sachen (6.2.2). Eine D-Nummer ist bewusst **nicht** vergeben, weil eine Nummer für einen nicht entschiedenen Schritt eine Absichtserklärung wäre und nach 6.8.1 mit der Nennung vergeben wäre | Software Architect (Schnitt), DevOps Engineer (Bau) | mit der nächsten Fortschreibung von Abschnitt 6, spätestens vor der Freigabe des Grundgerüsts |
| O-23 | **Wovon die harte Zusicherung des Gates abhängt: dass eine Aufgabenliste geführt wird.** `TaskCompleted` ist nach 6.12.2 das einzige der drei Ereignisse, das die Zusicherung "die Aufgabe lässt sich nicht abschliessen" trägt. Nach der gelesenen Referenz feuert es aber nur, "when any agent explicitly marks a task as completed through the TaskUpdate tool, or when an agent team teammate finishes its turn with in-progress tasks". In einer Sitzung ohne Aufgabenliste feuert es nie, und die Zusicherung gilt dann für nichts | **Neu am 2026-09-02 (6.12.2, Bau auf Weisung vom 2026-09-02 begonnen, förmliche Freigabe ausstehend; Befund aus Runde 1 der Prüfung).** Zwei Wege stehen offen, und beide sind Vorgehen, nicht Architektur: (1) eine Vorschrift, dass jede Arbeitseinheit als Aufgabe geführt wird — Ort `CLAUDE.md` oder `.claude/rules/claude-konfiguration.md`, in Abschnitt 9 als bedingte Nachführung vorgemerkt; oder (2) es bleibt bei fakultativen Aufgabenlisten, dann ist auszusprechen, dass die Kette in solchen Sitzungen nur angemahnt und nicht erzwungen wird und der Nachweis dort am menschlichen Review hängt. Diese Rolle nimmt die Wahl nicht vorweg: Eine Zusicherung, deren Voraussetzung ungeklärt ist, wäre die Zusicherung ohne Deckung aus V12 | Auftraggeber; Umsetzung der gewählten Fassung durch den Protocol Master (CLAUDE.md) beziehungsweise den DevOps Engineer (Regeldatei) | mit der Freigabe von 6.12, weil der Entwurf ohne diese Wahl nicht beurteilbar ist |
| O-24 | **Abbildung der Tabelle 6.12.19 auf einzeln prüfbare Zusicherungen.** Die Tabelle führt je Zeile **mehrteilige** Erwartungen ("2, mit Nennung des Mittels"; "0, mit `systemMessage`, die den Schritt nennt"), der Selbsttest je Fall **eine** Zusicherung. Wo eine Zeile mehr verspricht als Rückgabewert und Schlüssel, bleibt der Rest ungemessen, und der Fall ist grün, ohne seine Behauptung zu belegen. Offen ist die Form der Zerlegung — eine Zeile je Erwartung, eine eigene Spalte mit den einzeln zu messenden Zusicherungen, oder die Regel, dass jeder Selbsttestfall genau eine Zusicherung trägt | **Neu am 2026-09-03 (6.12.24 j, Punkt 15).** Die Fehlerklasse "ein Selbsttestfall besteht, ohne seine Behauptung zu belegen" ist **dreimal** aufgetreten (DT-B4, S-01, S3-01). Nach 3.4 ist die Arbeitseinheit am 2026-09-03 abgebrochen und **dieser Punkt** vorgelegt worden statt einer vierten Einzelbehebung: Die Frage ist nicht, ob der einzelne Fall nachgebessert wird — das ist er dreimal worden —, sondern wie die Prüftabelle so geschnitten wird, dass eine unvollständig gemessene Zeile auffällt statt grün zu sein | Auftraggeber; Vorbereitung durch den Software Architect, Umsetzung durch den DevOps Engineer, Verifikation durch Static und Dynamic Software Tester (3.4) | **vor der Abnahme des Gates** aus R3-Q-001 |

Nicht offen, sondern entschieden und hier nur zur Klarstellung: `pgvector` (A4), Suchindex (A3), Orchestrierung (A11). Nicht offen, weil gestrichen: VirusTotal, Gesichtserkennung samt biometrischer Vektoren, Open WebUI, CASE/UCO, Fernsteuerung von Maltego; seit der Fortschreibung vom 2026-08-21 auch TheHive und Cortex (5.17).

---

## 9. Was dieser ADR nach seiner Freigabe auflöst und was nachzuführen ist

**Aufgelöst mit der Freigabe:**

| Offener Punkt | Fundstelle | Auflösung |
|---|---|---|
| Ziel-Stack, Rahmenwerk und Komponentenbibliothek der Oberfläche | `docs/04_Kontextmodell.md`, offener Punkt 1 | Stack und Rahmenwerk entschieden (A1, A8); Komponentenbibliothek terminiert als O-2 |
| Ob `pgvector` gebraucht wird | `docs/04_Kontextmodell.md`, offener Punkt 3; 5.18 | Entschieden: nein (A4) |
| Konkrete Befehle je Kettenschritt | `docs/06_Definition_of_Ready_und_Done.md`, offener Punkt 3 | Vorschlag in Abschnitt 6, zu bestätigen durch DevOps und Auftraggeber |
| Abhängigkeit von R3-Q-001 auf R3-C-001 | `docs/05_Product_Backlog.md`, R3-Q-001 | Aufgelöst: Der Hook ruft `make dod`; die Werkzeugnamen stehen im Makefile |
| Einbindungstiefe TheHive/Cortex | `docs/04_Kontextmodell.md`, offener Punkt 2 | **Nicht** aufgelöst; neu terminiert als O-4, mit dem Befund, dass zuerst ein Backlog-Eintrag fehlt. **Fortschreibung 2026-08-21:** O-4 ist inzwischen entfallen — TheHive und Cortex gestrichen (5.17 neu), Abschnitt 8 |

**Nachzuführen durch die zuständigen Rollen — nicht durch diese Arbeitseinheit:**

| Was | Wo | Wer |
|---|---|---|
| Suchindex in PostgreSQL, Container- und Netzlayout, Modulschnitt, Auflösung der offenen Punkte 1 und 3 | `docs/04_Kontextmodell.md` | Software Architect, eigene Arbeitseinheit |
| Konkrete Befehle in der Tabelle D1 bis D12, Befunde zu D10 und D12 | `docs/06_Definition_of_Ready_und_Done.md` | DevOps Engineer, Bestätigung Auftraggeber |
| **Fortschreibung 2026-08-30:** Kriterienzeile für den Kettenschritt D18 (Architekturverträge) in Teil 2; Kriterium D11 auf beide Gegenstände erweitert (Arbeitsbaum **und** Git-Historie); die Wendung "Kette D1 bis D12" ist unvollständig geworden | `docs/06_Definition_of_Ready_und_Done.md` | DevOps Engineer mit Product Owner, Bestätigung Auftraggeber mit R3-Q-001 |
| **Fortschreibung 2026-08-30:** zwei gitleaks-Läufe in D11, neues Ziel `architekturvertraege` für D18 in der Reihenfolge nach D4 und vor D5, D12 ohne Schreibvorgang in den Arbeitsbaum | `Makefile` | DevOps Engineer, in derselben Arbeitseinheit |
| **Fortschreibung 2026-08-30:** die Wendung "Kette D1 bis D12" im Rollenprofil | `.claude/agents/static-software-tester.md` | Rolle, die die Rollendateien pflegt (ADR 0001) |
| **Zweite Fortschreibung 2026-08-30:** `--locked` statt `--frozen` in D1 und an jedem `uv run`-Aufruf einschliesslich der Verfügbarkeitsproben; Rahmenprüfung D19 um die Zielliste von `make dod` gelegt, auch bei Abbruch laufend; Objektbedingungen aller Schritte an die Objekttabelle in Abschnitt 6 angeglichen — namentlich D18 (Python-Produktionscode unterhalb `backend/src/` statt `backend/src/r3cosint/`), D10 (läuft, solange `prototype/` besteht) und der Backend-Anteil von D1 bis D8 (`backend/pyproject.toml` statt `backend/`) | `Makefile` | DevOps Engineer |
| **Zweite Fortschreibung 2026-08-30:** Zwischenspeicher der Prüfwerkzeuge ergänzen (`.pytest_cache/`, `.ruff_cache/`, `.mypy_cache/`, Abdeckungsdateien, Berichte der durchgehenden Oberflächenläufe) — heute steht keiner davon dort, und ohne sie schlägt D19 an | `.gitignore` | DevOps Engineer |
| **Zweite Fortschreibung 2026-08-30:** Kriterienzeile für die Rahmenprüfung **D19** (Unverändertheit des Arbeitsbaums) in Teil 2; der Absatz zum Kettengrundsatz um die Beobachtung durch D19 ergänzt, weil "beobachtbar" dort bisher niemanden benennt, der beobachtet; Kriterium D1 um die Aussage ergänzt, dass eine Abweichung zwischen `pyproject.toml` und `uv.lock` den Schritt rot macht; Punkt 3 der offenen Punkte um den beantworteten Teil von O-10 nachgeführt | `docs/06_Definition_of_Ready_und_Done.md` | DevOps Engineer mit Product Owner, Bestätigung Auftraggeber mit R3-Q-001 |
| **Dritte Fortschreibung 2026-08-30:** `--project backend` an jedem `uv`-Aufruf (bereits umgesetzt, hiermit gedeckt); Suchmuster und **Wegfall der Lage B** bei D7 — ein Nichtfinden des Backlogs endet ungleich 0 statt mit 0; `git` als Prüfmittel des Historienlaufs in D11, sein Fehlen ergibt Lage C bei vorhandenem `.git/` (bereits umgesetzt, hiermit gedeckt) | `Makefile` | DevOps Engineer |
| **Dritte Fortschreibung 2026-08-30:** Kriterium D7 — der Schritt hat keine Lage B; Kriterium D11 um `git` als Prüfmittel des Historienlaufs ergänzt; die `uv`-Aufrufe der Kette tragen `--project backend` | `docs/06_Definition_of_Ready_und_Done.md` | DevOps Engineer mit Product Owner, Bestätigung Auftraggeber mit R3-Q-001 |
| **Dritte Fortschreibung 2026-08-30:** Nachweis mit ausgeführtem Lauf, dass `--locked --project backend` nicht mehr mit "has no effect" antwortet, und Feststellung, welchen Gegenstand `pytest` in D5 und D6 ohne Pfadangabe aus der Repository-Wurzel einsammelt (6.3.1) | ausgeführter Lauf, Ergebnis in die Übergabedatei | DevOps Engineer, Verifikation Static und Dynamic Software Tester (3.4) |
| **Achte Fortschreibung 2026-09-01:** neues Ziel `belege` für D20 (`bash scripts/belege-pruefen.sh`), eingehängt als **erster** Eintrag der Zielliste von `make dod` vor D1; `D20` in die eigenständige Liste der erwarteten Kettenschritte aufnehmen, sonst bricht die Kette an ihrer eigenen Vorprüfung ab; Lage-Marke des Schrittes nach der Objekttabelle — **keine Lage B**, fehlendes Prüfmittel und leerer Bestand ergeben Lage C; die Zahl der nicht prüfbaren Zeilen gehört in die Lage-Meldung (6.8.3); die Schlusszeile "D1 bis D12 plus D18" ist unvollständig geworden | `Makefile` | DevOps Engineer |
| **Achte Fortschreibung 2026-09-01:** Kriterienzeile für den Kettenschritt **D20** (Belege) in Teil 2, samt der Aussage, was ein grüner Lauf trägt und was nicht (6.8.4); der neue Kettengrundsatz "Rückgabewert 0 heisst: nichts von dem gefunden, was dieser Schritt sucht" gilt für alle Schritte und gehört in denselben Teil; die Wendung "Kette D1 bis D12" ist ein zweites Mal unvollständig geworden. Zusammen mit der noch offenen Nachführung von D19 aus der zweiten Fortschreibung vom 2026-08-30 nachzuführen — solange D19 dort fehlt, liest sich D19 als freie Nummer (6.8.1) | `docs/06_Definition_of_Ready_und_Done.md` | DevOps Engineer mit Product Owner, Bestätigung Auftraggeber mit R3-Q-001 |
| **Neunte Fortschreibung 2026-09-01:** Die Beobachtung der Index-Maskierung ist bereits umgesetzt und hiermit gedeckt — zu ändern ist allein die **Benennung** des Ausgangs: Der Befundtext "D19 nicht beobachtbar" nennt neu ausdrücklich **Lage C**, damit Marke und Nachweiszeile dieselbe Sprache sprechen wie die übrigen Schritte. Kein Verhaltenswechsel, keine Änderung am Rückgabewert. Ebenfalls gedeckt, nicht zu ändern: die Bestimmung des Arbeitsbaums über `git` statt über einen Verzeichnisnamen (6.9.3) | `Makefile` | DevOps Engineer |
| **Neunte Fortschreibung 2026-09-01:** Kriterium D19 um den zweiten Teil des Prüfmittels ergänzen (Beobachtbarkeit des Index; ein gesetztes `assume-unchanged` oder `skip-worktree` ist Lage C, auch wenn es schon vor dem Lauf gesetzt war) und um die Unterscheidung der beiden Massstäbe — Gegenstand relativ, Instrument absolut; die geschärfte Lage C gilt für **alle** Schritte und gehört in denselben Teil | `docs/06_Definition_of_Ready_und_Done.md` | Requirements Engineer mit DevOps Engineer, Bestätigung Auftraggeber mit R3-Q-001 |
| **Neunte Fortschreibung 2026-09-01 — erledigt am selben Tag:** ausgeführter Lauf zur Beantwortung von O-16. Ergebnis in 6.10.1; die Befundmeldung ist daraufhin in 6.10.2 festgelegt und im Makefile bereits so benannt worden | ausgeführter Lauf | erledigt durch den Koordinator |
| **Zehnte Fortschreibung 2026-09-01:** Die Benennung des Befundtextes (Lage C, mitgeführtes Messergebnis) ist umgesetzt und hiermit gedeckt. Zu prüfen bleibt allein, dass die Meldung nicht mehr behauptet, der Arbeitsbaum sei unbeobachtet, sondern nennt, **welche Hälfte** des Instruments stumm ist und was die andere gemessen hat (6.10.2) | `Makefile` | DevOps Engineer, Verifikation Static und Dynamic Software Tester (3.4) |
| **Zehnte Fortschreibung 2026-09-01:** ausgeführter Lauf zur Beantwortung von **O-17** — weicht die Aufnahme ab, wenn eine maskierte, verfolgte Datei gelöscht wird? Ergebnis in die Übergabedatei; fällt es ungünstig aus, ist die Aussage über maskierte Dateien in der Meldung enger zu fassen | ausgeführter Lauf | DevOps Engineer, Verifikation Static und Dynamic Software Tester (3.4) |
| **Zehnte Fortschreibung 2026-09-01:** Kriterium D19 — die Meldung bei stummgeschaltetem Instrument nennt die betroffene Hälfte und das Ergebnis der anderen; sie behauptet nicht, der Arbeitsbaum sei unbeobachtet | `docs/06_Definition_of_Ready_und_Done.md` | Requirements Engineer mit DevOps Engineer, Bestätigung Auftraggeber mit R3-Q-001 |
| **Zwölfte Fortschreibung 2026-09-02 — Entwurf, erst nach der Freigabe von 6.12 auszuführen:** vier Änderungen am Ziel `dod` und an den Kettenschritten. (1) Die Schleife bricht bei Lage C nicht mehr ab, sondern vermerkt Kennung, Ziel und fehlendes Prüfmittel und läuft weiter; abgebrochen wird bei `A_FAIL`, bei fehlender oder mehrfacher Marke und bei jedem anderen Rückgabewert ungleich 0 (G5, 6.12.6). (2) Feste Grammatik der Lage-Marke: `<Lage>[ FEHLT=<wert>][ SCHWELLE=…\|OHNE_SCHWELLE]`. Jeder der 53 Lage-C-Zweige setzt neben `hat_lage_c=1` eine **Shell-Variable zur Laufzeit** mit dem fehlenden Prüfmittel; `KLASSIFIZIEREN` hängt daraus im C-Zweig selbst `FEHLT=<wert>` an, vor dem Zusatz aus dem vierten Parameter, und bei leerer Variable lautet der Wert `FEHLT=unbenannt`. Der vierte Parameter wird **nicht** umgewidmet — D3, D6 und D8 belegen ihn statisch mit `SCHWELLE=`/`OHNE_SCHWELLE`, und bei Lage C stehen beide Zusätze nebeneinander (G6, 6.12.7; Fassung nach Runde 1 der Prüfung, die erste Fassung dieser Zeile sprach vom vierten Parameter und übersah dessen Belegung sowie den Unterschied zwischen Expansions- und Laufzeit). (3) **Vier** eindeutige Schlusszeilen (die vierte für den vollständig gelaufenen Lauf mit D19-Befund — Nachtrag aus dem Bau, 6.12.23 a; die Zeile hiess bis dahin "drei"), eine eigenständige D19-Zeile in **jedem** Ausgang mit fester Grammatik `make dod: D19: <OHNE_BEFUND\|VERLETZT\|B\|C>[ -- <Text>].` — heute fünf freie Befundtexte mit zwei Schreibweisen für Lage C und eine Lage-B-Zeile, die nicht mit `D19:` beginnt — und eine erste Zeile `make dod: geprueft wird <PROJ>.`; die D19-Angabe fällt aus der Erfolgszeile weg statt dort zusätzlich zu stehen (G7, 6.12.8). (4) Im Ziel `belege` prüft der Wächter-Block zusätzlich, ob der Klon flach ist; ist er es, ist das Lage C mit `git fetch --unshallow` als Beschaffungsweg (G16, 6.12.17). Kein Kettenschritt wechselt dadurch seine Lage, und kein roter Lauf wird grün | `Makefile` | DevOps Engineer; Verifikation Static und Dynamic Software Tester auf einem anderen Modell (3.4) |
| **Zwölfte Fortschreibung 2026-09-02 — Entwurf:** neues Hook-Skript nach 6.12, das `Stop`, `SubagentStop` und `TaskCompleted` bedient und über `hook_event_name` verzweigt; es fängt Standard- und Fehlerausgabe von `make dod` gemeinsam ab und lässt auf die eigene Standardausgabe ausschliesslich ein JSON-Objekt oder nichts | `.claude/hooks/dod-gate.sh` (neu) | DevOps Engineer; Verifikation Static und Dynamic Software Tester (3.4) |
| **Zwölfte Fortschreibung 2026-09-02 — Entwurf:** die Liste der terminierten Lagen C, versioniert, in der Form aus 6.12.5. Sie enthält beim Anlegen ausschliesslich Einträge für Artefakte, die dieser ADR als noch nicht entstanden führt; `gitleaks` und jedes Prüfmittel von D20 sind darin unzulässig | `.claude/hooks/dod-gate-terminierte-lagen.txt` (neu) | Software Architect legt die Einträge an (Fortschreibung dieses Abschnitts); DevOps Engineer baut die Auswertung; Verifikation Static und Dynamic Software Tester (3.4) |
| **Zwölfte Fortschreibung 2026-09-02 — Entwurf:** drei Hook-Einträge in der **versionierten** Datei, für `Stop`, `SubagentStop` und `TaskCompleted`, ohne Matcher, in Exec-Form mit `args`, das Skript über `${CLAUDE_PROJECT_DIR}` angesprochen, `timeout: 900` je Eintrag (G11, 6.12.12). Cloud-Sitzungen lesen die lokale `~/.claude/settings.json` nicht (3.4) | `.claude/settings.json` | DevOps Engineer |
| **Zwölfte Fortschreibung 2026-09-02 — Entwurf:** Abschnitt "Durchsetzung" um das Gate nachführen — die drei Ereignisse und wer die Zusicherung trägt (6.12.2), die Unterscheidung Befund/Ausfall (6.12.4), die terminierten Lagen C samt ihren sechs Selbstprüfungen (6.12.5), die Zählung und die Eskalation (6.12.9), das Verhalten bei `stop_hook_active` (6.12.10) und die Aussage eines Durchlasses (6.12.18). Zusätzlich: der Satz zur Obergrenze nennt heute eine Umgebungsvariable, die in der gelesenen Dokumentation nicht vorkommt (O-19); die Kriterienzeilen D7 bis D12 und D20 sind um das strukturierte `FEHLT=` und um das Weiterlaufen bei Lage C zu ergänzen; D20 zusätzlich um die Vollständigkeit der Historie als siebtes Prüfmittel | `docs/06_Definition_of_Ready_und_Done.md` | Requirements Engineer mit DevOps Engineer, Bestätigung Auftraggeber mit R3-Q-001 |
| **Zwölfte Fortschreibung 2026-09-02 — Entwurf:** Tabelle "Aktive Gates" um das Definition-of-Done-Gate ergänzen; der Absatz "Noch nicht vorhanden" ist für `Stop`, `SubagentStop` und `TaskCompleted` überholt, sobald das Gate steht (R3-Q-005 bleibt offen). In der Lieferreihenfolge ist R3-Q-001 als erledigt zu führen, sobald Abnahme und Verifikation vorliegen | `CLAUDE.md` | Protocol Master |
| **Zwölfte Fortschreibung 2026-09-02 — Entwurf:** Abschnitt "Hooks" um zwei belegte Sätze ergänzen, die dort fehlen und beide gegen ein wirkungsloses Gate schützen: Ein Hook, der seine Zeitgrenze reisst, wird abgebrochen und **lässt durch** — die Zeitgrenze ist deshalb im Skript selbst zu ziehen, kürzer als in `settings.json`; und die Standardausgabe eines Hooks darf ausschliesslich das JSON-Objekt tragen, weil eine misslungene Auswertung als Fehler erscheint. Beides ist der Referenz vom 2026-09-02 entnommen | `.claude/rules/claude-konfiguration.md` | DevOps Engineer mit Protocol Master |
| **Zwölfte Fortschreibung 2026-09-02 — Entwurf, Befund aus Runde 1 (B13):** Der Abschnitt zu den Hooks erklärt die harte Obergrenze "über `CLAUDE_CODE_STOP_HOOK_BLOCK_CAP`" für **verbindlich**. Die Variable ist in der am 2026-09-02 gelesenen Hook-Dokumentation nicht belegt (O-19); die Obergrenze 8 steht dort ohne Variablennamen. Die Stelle ist nachzuführen, sobald O-19 entschieden ist — eine verbindlich erklärte Einstellung, die es möglicherweise nicht gibt, ist als Bauvorschrift untauglich | `docs/adr/0001-rollenmodell.md` | Software Architect als Fortschreibung jenes ADR, nach dem Entscheid zu O-19 |
| **Zwölfte Fortschreibung 2026-09-02 — Entwurf, bedingt auf den Entscheid zu O-23 (Befund B4 aus Runde 1):** Wählt der Auftraggeber Weg (1), ist eine Vorschrift nachzuführen, dass **jede Arbeitseinheit als Aufgabe geführt wird** — sonst feuert `TaskCompleted` nicht, und die einzige harte Zusicherung des Gates trägt nichts (6.12.2, 6.12.18 Punkt 5). Wählt er Weg (2), ist an derselben Stelle festzuhalten, dass die Kette in Sitzungen ohne Aufgabenliste nur angemahnt und nicht erzwungen wird. Eine der beiden Fassungen ist zu schreiben, keine ist wegzulassen | `CLAUDE.md` oder `.claude/rules/claude-konfiguration.md` | Protocol Master (CLAUDE.md) beziehungsweise DevOps Engineer (Regeldatei), nach dem Entscheid des Auftraggebers |
| **Zwölfte Fortschreibung 2026-09-02 — Entwurf:** Das Abnahmekriterium `R3-Q-001_gate_blockiert` ist zu präzisieren. Es setzt heute "roter Prüflauf" mit "Rückgabewert ungleich 0" gleich; mit den terminierten Lagen C endet `make dod` mit 2, während das Gate mit 0 endet. Vorschlag: "rot" ersetzen durch "Befund — `A_FAIL`, D19 `VERLETZT` oder nicht nachweisbar gelaufen"; als eigener, ebenfalls zu prüfender Fall aufnehmen, dass ein Lauf, dessen einzige Abweichungen gedeckte terminierte Lagen C sind, mit 0 endet und sich über `systemMessage` meldet; dazu die weiteren Fälle aus 6.12.19. Der Eintrag trägt weiterhin keinen benannten Stakeholder (offener Punkt 12 des Backlogs) | `docs/05_Product_Backlog.md` | Product Owner mit Requirements Engineer, Bestätigung Auftraggeber |
| **Zwölfte Fortschreibung 2026-09-02 — Entwurf:** **drei** ortsgebundene Ausnahmeeinträge, jeder mit Tatsachengrund, jeder Umsetzung nach 6.8.5 und **kein** Architekturentscheid. (1) Für den Fund auf `origin/main` — der lokale Zweig-Ref als Beleg in einer Übergabedatei; die Übergabedatei selbst wird nicht geändert (siehe den letzten Absatz dieses Abschnitts). (2) und (3) Für die beiden Pfade `.claude/hooks/dod-gate.sh` und `.claude/hooks/dod-gate-terminierte-lagen.txt`, die dieser Abschnitt nennt und die erst mit dem Bau entstehen; Form `datei\|wert`, gebunden an `docs/adr/0002-architekturentscheid-ziel-stack.md`. **Die Einträge (2) und (3) sind mit dem Entstehen der beiden Dateien wieder zu entfernen** — die Selbstprüfung "der Gegenstand existiert inzwischen" macht sie dann selbst zum Befund (6.8.5, Eigenschaft 3), und genau das ist ihre Sollbruchstelle | `scripts/belege-ausnahmen.txt` | Die Rolle, deren Dokument den Fund ausgelöst hat; Verifikation durch eine andere Rolle (3.4) |
| **Zwölfte Fortschreibung 2026-09-02 — Entwurf:** Zeile für das neue Hook-Skript und die Liste der terminierten Lagen in der Artefaktliste des Nachweiserzeugers; Neuerzeugung des Nachweisverzeichnisses; Changelog | `scripts/nachweise-erzeugen.sh`, `docs/NACHWEISE.md`, `CHANGELOG.md` | Protocol Master (4.2, 6.6) |
| **Zwölfte Fortschreibung 2026-09-02 — Entwurf:** zu prüfen, ob ein methodischer Entscheid festzuhalten ist — die Unterscheidung zwischen einer Kette, die streng bleibt, und einem Gate der Arbeitsumgebung, das einen abzählbaren, selbstprüfenden und terminierten Ausfall duldet, während die Gegenseite ihn nicht kennt (6.12.5). Diese Rolle schlägt ihn vor und trägt ihn nicht selbst ein | `methodik/entscheide.md` im Methodik-Repository | Protocol Master mit dem Auftraggeber |
| **Nachträge aus der Verifikation 2026-09-02 (6.12.24, Bau auf Weisung begonnen, förmliche Freigabe ausstehend):** Entscheide zu den Befunden B-01, B-02, B-03, N-01, N-04 bis N-07 und N-09 — im Gate umgesetzt, N-01 und N-07 allein durch den Entscheid ohne Codeänderung — der geprüfte Baum als **physisch aufgelöste Wurzel** des Arbeitsbaums (a); der Schlüssel `KETTE baum-widerspruch` (b); kein Ausgang 1 mehr bei nicht bestimmbarem Zustandsverzeichnis, sondern dieselbe Behandlung wie bei einem nicht beschreibbaren (c); der Zähler bleibt beim Durchlass nach der Eskalation stehen (d); Sperrdatei unter `/tmp`, wenn das Zustandsverzeichnis ausfällt, und Lauf ohne Sperre mit Meldung, wenn auch das nicht geht (e); die Wegwerfdatei nachweislich ausserhalb des Baums, sonst `GATE mktemp` (f); `sha256sum` und `mktemp` als Prüfmittel mit eigenem Schlüssel (g); die Selbstprüfungen 2, 4 und 6 vor dem Lauf der Kette, Schlüssel aus der kleinsten Zeilennummer (h). **Nach Runde 2 zusätzlich:** der Zähler zählt beim Durchlass nach der Eskalation **weiter** statt still zu stehen, und die Meldung nennt das n-te Mal (d, DT2-B1); der Hinweis auf ein ausgefallenes Zählwerk steht in **jeder** Meldung, bei sauberem Grün als einzige, und unterscheidet "nicht bestimmbar" von "nicht beschreibbar" (c, S-13); der Kettenlauf erhält `TMPDIR` gleich dem Verzeichnis der geprüften Wegwerfdatei, damit auch die Kette nicht in den Baum schreibt (f, DT2-B2); die Zahl der gelesenen Marken wird gegen die Zahl der Schlusszeile geprüft, mindestens eine Marke verlangt, Abweichung `KETTE ausgabe-unlesbar` (k, S-11); `D19 B-widerspruch` geht der Konsistenzwache vor (S-01), eine fehlende Baumzeile ist `KETTE ausgabe-unlesbar` (S-10) | `.claude/hooks/dod-gate.sh` | DevOps Engineer; Verifikation Static und Dynamic Software Tester auf einem anderen Modell (3.4) |
| **Nachträge aus der Verifikation 2026-09-02 (6.12.24 i):** Selbsttest — alle **acht** Kombinationen der D19-Zeile (N-02); der G13-Fall mit den **echten** Rollendateien `static-software-tester.md` und `pentester.md` samt Gegenfall `devops-engineer.md` (N-03); eigene Fälle für G12 (Unterverzeichnis, Schrägstrich am Ende, Symlink, `cwd` ausserhalb des Repositories, zweiter Arbeitsbaum — DT-B5); die Übergabedatei des Falls zur Eskalation nachweislich in `HEAD` (DT-B4); je ein Fall für die Entscheide a), c), e), f), g) und h) sowie für D12 mit mehreren fehlenden Gegenständen (N-08). **Nach Runde 2 zusätzlich** die dort als fehlend beanstandeten Fälle (S-03, S-04, S-05) und je ein Fall für: null Marken bei Form-1-Schlusszeile und Rückgabewert 0 sowie abweichende Markenzahl (k, S-11); D19 Lage B bei Rückgabewert 0 unter `D19 B-widerspruch` (S-01); fehlende Baumzeile unter `KETTE ausgabe-unlesbar` (S-10); `TMPDIR` in den Baum, wobei die **Kette selbst** eine Wegwerfdatei anlegt (f, DT2-B2); Weiterzählen des Zählers nach dem vierten Durchlass (d, DT2-B1); die Meldung zum ausgefallenen Zählwerk bei grüner Kette (c, S-13) | `scripts/dod-gate-selbsttest.sh` | DevOps Engineer; Verifikation Static und Dynamic Software Tester (3.4) |
| **Nachträge aus der Verifikation 2026-09-02 (6.12.24 i, Befund N-08):** In D12 gewinnt bei mehreren fehlenden Gegenständen der **erste** in `FEHLT=`; kein späterer `if`-Block überschreibt ihn. Anwendung von G6, keine neue Regel | `Makefile` | DevOps Engineer |
| **Nachträge aus der Verifikation 2026-09-02 (6.12.24, Befunde B-04 und B-05) — bereits ausgeführt (Fremdbeleg, nicht von dieser Rolle geprüft):** die ortsgebundene Ausnahme für `CLAUDE.md`, deren Zeilenangabe durch das Wachsen der Datei überholt war, ist nachgeführt; vier Ausnahmen der Form `datei\|wert` decken die in `docs/06_Definition_of_Ready_und_Done.md` genannten, noch nicht gebauten Skripte. Umsetzung nach 6.8.5, **kein** Architekturentscheid; die vier Einträge sind mit dem Entstehen der Skripte wieder zu entfernen (6.8.5, Eigenschaft 3) | `scripts/belege-ausnahmen.txt` | Koordinator, ausgeführt am 2026-09-02; Verifikation durch eine andere Rolle (3.4) |
| **Nachträge aus der Verifikation 2026-09-02 (6.12.24 j):** **Drei** Prüfrunden sind gelaufen und in 6.12.24 j verzeichnet. Runde 3 (2026-09-03, Fremdbeleg): alle dreizehn Befunde aus Runde 2 sind mit eigenen Läufen **beider** Prüfer als behoben belegt, der Selbsttest besteht **81 von 81** Fällen, unabhängig reproduziert — und dennoch ist die Runde **nicht bestanden** (S3-01 statisch, DT3-B1 dynamisch, dazu sechs nicht blockierende Befunde). Weil dieselbe Fehlerklasse zum dritten Mal auftrat, ist die **Arbeitseinheit am 2026-09-03 nach 3.4 abgebrochen**, die Übergabedatei `docs/uebergaben/2026-09-02_r3-q-001-gate-gebaut.md` mit der Eskalationszeile geschrieben und **O-24** vorgelegt worden. Nachzuführen bleiben: der Entscheid zu O-24, danach die fünf in 6.12.24 j, Punkt 16, als Vorschlag festgehaltenen Behebungen und eine **vierte** Prüfrunde; erst sie belegt den Stand danach, dieser ADR belegt ihn nicht. Die Forderung aus 6.12.23 d — der grüne Lauf gegen das **echte** `Makefile` mit **Rückgabewert 0 der Kette** — ist nach Fremdbeleg beider Prüfer in beiden Runden durch Selbsttestfall 28 erfüllt; der Lauf am echten Bestand endete erwartungsgemäss mit Form 2 und Rückgabewert 2 (terminierte Lage C bei D7, D10 und D12) | Prüfbericht, Ergebnis in die Übergabedatei | Static und Dynamic Software Tester auf einem anderen Modell als die Umsetzung (3.4) |
| Backlog-Eintrag für TheHive/Cortex (O-4) — **entfallen am 2026-08-21**, O-4 gestrichen (5.17 neu); bleibt: Formulierung der Abnahme von R3-C-001 gegenüber 5.6 (O-1) | `docs/05_Product_Backlog.md` | Product Owner |
| Zeile für diesen ADR in der Artefaktliste des Erzeugers; Neuerzeugung des Nachweisverzeichnisses; Changelog | `scripts/nachweise-erzeugen.sh`, `docs/NACHWEISE.md`, `CHANGELOG.md` | Protocol Master (4.2, 6.6) |
| Statustabelle und Verweis auf den Ziel-Stack | `CLAUDE.md` | Protocol Master |
| Anlegen des Grundgerüsts nach Abschnitt 5 | `backend/`, `deploy/`, `Makefile` | Backend Engineer und DevOps Engineer, nächste Arbeitseinheit |

**Nicht nachzuführen, weil sie einen vergangenen Stand belegen:** `docs/08_Freigabe_Schritt_4.md`, `docs/09_Zustandsbericht_2026-08-21.md` und die Dateien unter `docs/uebergaben/`. Sie nennen die Kette als "D1 bis D12" beziehungsweise "D1–D12 plus D13–D17"; das war am Tag ihrer Entstehung richtig und bleibt als Nachweis unverändert. Genau deshalb werden D-Nummern nicht umnummeriert (6.1.2).

---

## 10. Freigabevermerk

R3-C-001 gilt erst als abgenommen, wenn hier die schriftliche Freigabe des Auftraggebers vermerkt ist und der Status oben auf „angenommen" steht. Bis dahin bleibt dieser ADR ein Vorschlag, und Etappe 1 beginnt nicht.

| | |
|---|---|
| **Vorgelegt am** | 2026-08-20 |
| **Entscheid des Auftraggebers** | **freigegeben**, ohne Auflagen |
| **Auflagen** | keine |
| **Entscheid zu O-1 (Trennung Rahmenwerk und Komponentenbibliothek)** | **bestätigt** — Rahmenwerk jetzt entschieden, die konkrete Komponentenbibliothek folgt nach dem Prototyp-Review als eigener ADR (O-2) |
| **Datum der Freigabe** | 2026-08-20 |
| **Auftraggeber (S-01)** | Freigabe erteilt in der Claude-Code-Session, Wortlaut «Freigegeben, O-1 bestätigt»; Name nach offenem Entscheid E-11 nicht im Repository geführt |

**Protokollvermerk zur Form:** Die Freigabe wurde am 2026-08-20 über den
zweiten Formweg erteilt (Anweisung an die Session) und von der Session in
diesen Vermerk übertragen; Urheber und Zeitpunkt belegt die Commit-Historie
des Arbeitszweigs.

### Vorlage der zwölften Fortschreibung (Abschnitt 6.12) und Weisung vom 2026-09-02

| | |
|---|---|
| **Vorgelegt am** | 2026-09-02, Commit `21cc3ddbf45668c2e185958f8e2a8d42eeaf0150`, mit `docs/uebergaben/2026-09-02_r3-q-001-entwurf-dod-gate.md` und den elf Entscheidpunkten E-A bis E-K |
| **Weisung des Auftraggebers, Wortlaut** | "Gehe nach der besten Lösung und Schritte. Einfach keine Annahmen und sei vollkommen sicher." |
| **Lesart des Koordinators** | Der Bau beginnt auf diese Weisung; je Entscheidpunkt wird die vom Software Architect empfohlene Option umgesetzt. Die Weisung entscheidet die elf Punkte nicht einzeln |
| **Förmliche Freigabe** | **steht aus.** Formweg wie beim Freigabe-Gate Schritt 4: Merge des Pull Requests dieses Arbeitszweigs oder Anweisung an die nächste Sitzung mit dem exakten Wortlaut; jede der unten umgesetzten Optionen kann dabei zurückgewiesen werden |

Vom Koordinator umgesetzte Optionen, je die Empfehlung des Architects:

| Nr. | Punkt | Umgesetzte Option |
|---|---|---|
| E-A | 6.12 als Ganzes | Bau nach 6.12 |
| E-B | Terminierte Lagen C (G4) | (a) |
| E-C | Kette bricht bei Lage C nicht mehr ab (G5) | (a) |
| E-D | `FEHLT=` strukturiert in der Marke (G6) | (a) |
| E-E | `gitleaks` bleibt blockierend | (a), verbunden mit (b): gitleaks 8.21.2 am 2026-09-02 in der Sitzungsumgebung installiert, Prüfsumme des Release-Archivs gegen die veröffentlichte Prüfsummendatei geprüft; die dauerhafte Bereitstellung in der Umgebung liegt beim Auftraggeber |
| E-F | Flacher Klon blockiert (G16) | (a) |
| E-G | Laufzeit je Beendigungsversuch (G15, O-20) | (a) |
| E-H | Reichweite der Zusicherung, Voraussetzung Aufgabenliste (G9, O-23) | (a): Wortlaut befolgen und vorschreiben, dass jede Arbeitseinheit als Aufgabe geführt wird |
| E-I | Abnahmekriterium `R3-Q-001_gate_blockiert` | (a) präzisieren |
| E-J | Durchlass nach der Eskalation | (a): nur `Stop` und `SubagentStop`; `TaskCompleted` blockiert weiter |
| E-K | `Bash` zählt nicht als Schreibwerkzeug (G13) | (a), mit benannter Lücke bis R3-Q-005 |

Formweg wie beim Freigabe-Gate Schritt 4: entweder direkte Bearbeitung dieser Datei über einen Pull Request oder Anweisung an die nächste Sitzung mit dem exakten Wortlaut des Entscheids. Massgeblich ist der committete Stand; Urheber und Zeitpunkt belegt die Commit-Historie.
