# ADR 0002 — Architekturentscheid und Ziel-Stack

| | |
|---|---|
| **Titel** | Ziel-Stack, Modulschnitt, Datenzugriff und Grundgerüst für R3cOSINT |
| **Status** | **angenommen** — Freigabe des Auftraggebers am 2026-08-20, Abschnitt 10 |
| **Fortschreibung** | 2026-08-21 — O-4 entfallen: TheHive und Cortex mit der Neufassung von Projektauftrag 5.17 gestrichen; Abschnitte 8 und 9 nachgeführt. Der Optionenvergleich der Sprachwahl in Abschnitt 3.1 bleibt als damalige Entscheidungsgrundlage unverändert. — 2026-08-30 — Abschnitt 6 in drei Punkten fortgeschrieben: D11 prüft zwei Gegenstände (Arbeitsbaum und Git-Historie) statt nur der Historie; neuer Kettenschritt D18 für die Architekturverträge des Importprüfers, den Abschnitt 3.5 seit dem 2026-08-20 verlangt, ohne dass die Tabelle ihn führte; Kettengrundsatz "ein Prüflauf verändert den Gegenstand nicht, über den er urteilt" samt Folge für D12. Frühere Fassungen, Belege und Begründungen in Abschnitt 6.1; als Verweis berührt sind zusätzlich 1.3 (K5), 3.5, 3.12 sowie 8 (O-8, neu O-10) und 9. — 2026-08-30, **zweite Fortschreibung desselben Tages** nach einer abschliessenden adversarischen Prüfung: Die Kette schreibt keine Sperrdatei mehr (`uv sync --locked` und `uv run --locked` statt `--frozen`), die Unverändertheit des Arbeitsbaums wird als Rahmenprüfung **D19** tatsächlich beobachtet statt nur behauptet, die Objektbestimmung aller Kettenschritte steht neu einmal und einheitlich in einer eigenen Tabelle (löst den Widerspruch bei D18 und die fehlende Bedingung bei D10 auf), und die Prüffläche des Arbeitsbaumlaufs aus D11 ist festgelegt. Frühere Fassungen, Belege und Begründungen in Abschnitt 6.2; berührt sind zusätzlich 1.3 (K5), 3.11 und 8 (O-10 neu gefasst) sowie 9. — 2026-08-30, **dritte Fortschreibung desselben Tages** nach vier vom DevOps Engineer gemeldeten Abweichungen zwischen diesem ADR und dem Makefile: Jeder `uv`-Aufruf der Kette trägt `--project backend`, ohne das `--locked` wirkungslos bleibt (belegter Lauf); D7 erkennt seinen Gegenstand am Backlog statt am Dateinamen und hat keine Lage B mehr; `git` ist bei D11 Prüfmittel des Historienlaufs, sein Fehlen ist Lage C; der Abgleich der Wurzelpakete für D18 ist als O-11 terminiert. Frühere Fassungen, Belege und Begründungen in Abschnitt 6.3; berührt sind zusätzlich 8 (O-11 neu) und 9 |
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
| K5 | Maschinell prüfbar über eine Befehlskette mit Rückgabewert 0 | 3.4, DoD-Befehlskette nach Abschnitt 6 (bis zur Fortschreibung vom 2026-08-30 hier als "D1 bis D12" bezeichnet; die Kette umfasst seither zusätzlich D18, seit der zweiten Fortschreibung desselben Tages zusätzlich die Rahmenprüfung D19) |
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
| Mittel | `git status --porcelain` unmittelbar vor dem ersten und unmittelbar nach dem letzten ausgeführten Kettenschritt; verglichen wird die vollständige Ausgabe zeilenweise, einschliesslich der unverfolgten Einträge (`??`) |
| Massstab | Vorher gegen Nachher, **nicht** gegen einen sauberen Arbeitsbaum. Die Kette läuft vor dem Commit und trifft regelmässig einen veränderten Arbeitsbaum an; das ist zulässig — ihn zu verändern ist es nicht |
| Ausgang | Bei Abweichung endet `make dod` ungleich 0 und nennt die abweichenden Zeilen. Der Befund kann einen grünen Lauf rot machen, nie einen roten grün |
| Auch bei Abbruch | Die Nachher-Aufnahme läuft auch dann, wenn die Kette an einem Schritt vorher abgebrochen ist. Sonst bliebe gerade der Schritt unbeobachtet, der schreibt und zugleich scheitert |
| Kennung | D19, die nächste freie Nummer im gemeinsamen D-Namensraum. Sie erhält **kein** eigenes `make`-Ziel, weil sie den Lauf einklammert; sie trägt trotzdem eine Nummer, damit Definition of Done, Backlog und Nachweise sie benennen können |

**Folge für `.gitignore`.** Damit D19 nicht an Werkzeugspeichern anschlägt, gehören die Zwischenspeicher der Prüfwerkzeuge in die Ignorierliste — `.pytest_cache/`, `.ruff_cache/`, `.mypy_cache/`, die Abdeckungsdateien und die Berichte der durchgehenden Oberflächenläufe. Heute steht keiner dieser Einträge in `.gitignore` (geprüft am 2026-08-30). Das ist nachzuführen (Abschnitt 9) und zugleich Bedingung dafür, dass der Arbeitsbaumlauf aus D11 nicht in Werkzeugspeichern sucht (6.2.3). Ein Prüfwerkzeug, dessen Zwischenspeicher sich nicht in einen ignorierten Pfad legen lässt, wird nicht durch eine Ausnahme von D19 aufgefangen, sondern ausgetauscht.

**Die Nummer eines Kettenschritts ist eine Kennung, keine Reihenfolge.** *(Aufgenommen mit der Fortschreibung vom 2026-08-30.)* Nummern werden nicht umnummeriert und nicht wiederverwendet; ein neuer Schritt erhält die nächste freie Nummer im gemeinsamen D-Namensraum von `docs/06_Definition_of_Ready_und_Done.md`, Teil 2 (Befehlskette und menschlich bestätigte Bedingungen zählen dort fortlaufend). Die Reihenfolge der Ausführung ergibt sich aus der Zielliste von `make dod`, nicht aus der Zahl. Begründung in 6.1.

**Woran ein Kettenschritt seinen Gegenstand erkennt.** *(Aufgenommen mit der zweiten Fortschreibung vom 2026-08-30; Anlass, Beleg und Begründung in 6.2.2.)* Jeder Kettenschritt urteilt über eine Sache, nicht über einen Verzeichnisnamen. Für jeden Schritt gelten dieselben drei Lagen, und jede hat genau einen Ausgang:

| Lage | Bedingung | Ausgang |
|---|---|---|
| A | Gegenstand vorhanden, Prüfmittel vorhanden | Der Schritt urteilt: 0 oder ungleich 0 |
| B | Gegenstand nicht vorhanden | Der Schritt entfällt **mit Meldung**, Rückgabewert 0 |
| C | Gegenstand vorhanden, Prüfmittel fehlt | Rückgabewert **ungleich 0**. Ein fehlendes Prüfmittel ist kein bestandener Schritt |

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
| D19 | Der Bestand der versionierten Dateien über die Dauer eines Laufs von `make dod` | `.git/` vorhanden | kein `.git/` | `git` |

Zwei Anmerkungen zu dieser Tabelle:

- **Zu D6.** Die Abdeckungspfade folgen dem Modulbaum aus 4.1 — `backend/src/r3cosint/`, darin `spur`, `zugriff` und `freigabe`. Weicht ein Paketname davon ab, ist das ein Verstoss gegen 4.1 und A13 und wird dort behoben, nicht durch eine Lockerung des Pfades in der Kette. Der Schritt darf an einem falsch benannten Paket scheitern; er darf ihn nicht stillschweigend auslassen.
- **Zu D18.** Die Vertragsdatei nennt jedes oberste Paket unterhalb `backend/src/` als Wurzelpaket. Sonst liefe der Prüfer an vorhandenem Produktionscode vorbei und meldete Lage A, obwohl er nichts beurteilt hat. Wo dieser Abgleich sitzt — im Aufruf oder als Vertrag im Prüfer selbst —, entscheidet der DevOps Engineer. **Dritte Fortschreibung 2026-08-30:** Dieser Abgleich ist heute nicht gebaut, weil `backend/importvertraege.toml` noch nicht besteht; im Makefile steht er als Kommentar. Damit er mit dem Grundgerüst nicht vergessen wird, ist er als **O-11** in Abschnitt 8 terminiert — ein Kommentar ist keine Prüflogik, und für ihn gilt derselbe Satz wie für die auskommentierte Prüfung unten: Er bleibt still liegen, nachdem er gebraucht würde (6.3.4).

**Zwei Ebenen der Namensbindung.** Die Backend-Befehle stehen unmittelbar im Makefile, die Oberflächenbefehle laufen über Skripte in `frontend/package.json`. Damit steht jeder Werkzeugname genau einmal und an der Stelle, an der er hingehört; die Kette selbst bleibt unverändert, wenn ein Werkzeug ausgetauscht wird.

**Ein Einstieg für den Hook.** `make dod` ruft **alle Kettenschritte dieser Tabelle** in der festgelegten Reihenfolge auf — D1 bis D4, dann D18, dann D5 bis D12 — und endet bei der ersten Abweichung ungleich 0. *(Bis zur Fortschreibung vom 2026-08-30 lautete dieser Satz: "ruft D1 bis D12 der Reihe nach auf". Die Aufzählung war dort zugleich die Reihenfolge; mit D18 gilt das nicht mehr.)* Der Hook aus R3-Q-001 ruft **diesen einen Befehl** auf. Damit hängt R3-Q-001 nur noch am Vorhandensein des Makefiles und nicht mehr an einzelnen Werkzeugnamen; ändert sich ein Werkzeug, ändert sich das Makefile, nicht der Hook. Für den Hook gelten unverändert: nur Rückgabewert 2 blockiert, Reentranz-Schutz über `stop_hook_active`, Eskalation nach dreimaligem Scheitern am gleichen Kriterium (3.4). *(Zweite Fortschreibung 2026-08-30: Die Rahmenprüfung D19 gehört zu `make dod`, steht aber nicht in der Zielliste. Sie nimmt vor dem ersten Schritt auf, vergleicht nach dem letzten ausgeführten Schritt und läuft auch dann, wenn die Kette vorher abgebrochen ist.)*

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
| O-8 | Betriebsart für D10 und Form von D12 (Befunde in Abschnitt 6) | Betrifft bestehende Skripte, die anderen Rollen gehören | DevOps Engineer mit Protocol Master | mit R3-Q-001. **Fortschreibung 2026-08-30:** Für D12 kommt die Bindung an den Kettengrundsatz aus 6.1.3 hinzu — die gewählte Form schreibt nicht in den Arbeitsbaum |
| O-9 | Anbindungsdaten des Entra-ID-Mandanten | Liegen bei der Informatik der Kantonspolizei Bern | KapoBE Informatik | blockiert nur den Mandantenwechsel, nicht die Entwicklung |
| O-10 | Prüffläche des Arbeitsbaumlaufs in D11: welche Dateien er beurteilt, wie er sich gegenüber `.gitignore` verhält, und wie ein belegter Fehlalarm behandelt wird, dessen Fingerabdruck in den beiden Läufen verschieden ist (6.1.1) | **Neu am 2026-08-30.** Mit einem ausgeführten Lauf der eingesetzten Werkzeugfassung festzustellen, nicht durch Annahme; berührt Laufzeit und Aussagekraft des Schrittes | DevOps Engineer mit SecDevOps | mit R3-Q-001 |
| O-10 (neu gefasst) | **Beantwortet am 2026-08-30 mit einem ausgeführten Lauf (gitleaks 8.21.2):** `--no-git` beachtet `.gitignore` nicht; eine ignorierte `.env` oder `*.pem` blockiert die ganze Kette. Entschieden in 6.2.3: Zugangsdaten liegen nicht im Arbeitsbaum (3.11), ausgeschlossen wird ausschliesslich, was kein Repository-Inhalt sein kann, der Schutz wird nicht abgestuft. **Offen bleiben zwei Restfragen:** (a) die namentliche Ausschlussliste für Abhängigkeits- und Bauverzeichnisse samt ihrer technischen Form — Werkzeugkonfiguration oder Aufrufparameter; (b) die betriebliche Form der Ablage von Zugangsdaten ausserhalb des Arbeitsbaums, einschliesslich Einhängung im Prüfstapel und Eintrag in die Betriebsdokumentation | (a) hängt an der eingesetzten Werkzeugfassung und ist mit einem ausgeführten Lauf zu belegen; (b) ist Betrieb und Sicherheit, nicht Architektur | (a) DevOps Engineer mit SecDevOps; (b) SecDevOps mit DevOps Engineer | (a) mit R3-Q-001; (b) mit dem Grundgerüst, vor der ersten Umsetzungseinheit mit Code |

| O-11 | Abgleich für D18: Jedes oberste Paket unterhalb `backend/src/` ist in `backend/importvertraege.toml` als Wurzelpaket genannt — und wo dieser Abgleich sitzt, im Aufruf oder als Vertrag im Prüfer selbst | **Neu am 2026-08-30 (6.3.4).** Nicht baubar, solange `backend/importvertraege.toml` nicht besteht; heute im Makefile nur als Kommentar hinterlegt, und ein Kommentar ist keine Prüflogik. Ohne den Abgleich meldet D18 Lage A, ohne etwas beurteilt zu haben — der Befund aus 6.2.2 | DevOps Engineer mit Backend Engineer | mit dem Anlegen von `backend/importvertraege.toml`, also mit dem Grundgerüst und vor der ersten Umsetzungseinheit mit Fachlogik |

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

Formweg wie beim Freigabe-Gate Schritt 4: entweder direkte Bearbeitung dieser Datei über einen Pull Request oder Anweisung an die nächste Sitzung mit dem exakten Wortlaut des Entscheids. Massgeblich ist der committete Stand; Urheber und Zeitpunkt belegt die Commit-Historie.
