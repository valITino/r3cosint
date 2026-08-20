# ADR 0002 — Architekturentscheid und Ziel-Stack

| | |
|---|---|
| **Titel** | Ziel-Stack, Modulschnitt, Datenzugriff und Grundgerüst für R3cOSINT |
| **Status** | **vorgeschlagen — zur Freigabe durch den Auftraggeber (R3-C-001)** |
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
| K5 | Maschinell prüfbar über eine Befehlskette mit Rückgabewert 0 | 3.4, DoD D1 bis D12 |
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

1. **Zwei Module ohne Aufrufkante.** `freigabe.vorschlag` erzeugt eine Freigabevorlage und schreibt sie in den Zustand *offen*. `freigabe.ausfuehrung` nimmt Arbeit ausschliesslich mit einer Freigabe-Kennung an. Das Vorschlagsmodul importiert das Ausführungsmodul nicht und kennt weder dessen Namen noch dessen Adresse. Durchgesetzt über einen Architekturvertrag im Importprüfer (Abschnitt 3.12), der als eigener Kettenschritt läuft.
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

**Ehrliche Grenze zum Offline-Betrieb.** Der **Betrieb** ist vollständig offline möglich. Der **Bau** setzt eine Paketquelle voraus — im Haus eine Spiegelung, sonst das offene Netz. Das ist kein Widerspruch zu R3-F-021, aber es gehört benannt, weil es die Betriebsdokumentation betrifft. Zweite Grenze: Meldet sich ein Konto im Offline-Betrieb über einen externen Identitätsanbieter an, kann das nicht gelingen. Offline nutzbar ist die Anmeldung über den hausinternen Provider; das ist bei der Einrichtung der Produktion zu berücksichtigen.

### 3.12 A12 — Teststack und Prüfstufen

**Entscheid.**

| Stufe | Werkzeug | Zweck |
|---|---|---|
| Formatierung und Linter, Backend | Ruff (Formatierung und Prüfung in einem Werkzeug) | D2, D3 |
| Typprüfung, Backend | mypy im strengen Modus | D4 |
| Tests, Backend | pytest mit asynchroner Unterstützung, Abdeckungsmessung | D5, D6 |
| **Architekturverträge** | Importprüfer mit Verträgen (import-linter-Klasse) | Macht die Modulgrenzen aus Abschnitt 4 maschinell prüfbar — Voraussetzung für R3-F-014 und R3-F-018 |
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

## 6. Definition-of-Done-Befehlskette — Vorschlag zu D1 bis D12

Dies löst den offenen Punkt 3 der Definition of Ready und Done. **Vorschlag des Software Architects, zu bestätigen durch DevOps Engineer und Auftraggeber.** Erwartet wird je Schritt Rückgabewert 0.

| Nr. | Schritt | Befehl | Anmerkung |
|---|---|---|---|
| D1 | Bau | `make bau` → `uv sync --frozen` · `uv run python -m compileall -q backend/src` · falls `frontend/package.json` vorhanden: `npm ci --prefix frontend` und `npm run build --prefix frontend` · `docker compose -f deploy/compose.test.yml build` | Sperrdateien sind bindend; `--frozen` schlägt fehl, statt still aufzulösen |
| D2 | Formatierung | `make format-pruefen` → `uv run ruff format --check backend` · `npm run format-pruefen --prefix frontend` | |
| D3 | Linter | `make linter` → `uv run ruff check backend` · `npm run linter --prefix frontend` mit `--max-warnings <Schwelle>` | Schwelle offen, Entscheid E-08 |
| D4 | Typprüfung | `make typen` → `uv run mypy backend/src backend/tests` · `npm run typen --prefix frontend` | mypy im strengen Modus, null Fehler; das Oberflächenskript ruft den TypeScript-Compiler ohne Ausgabe auf |
| D5 | Testsuite | `make test` → `uv run pytest -q --strict-markers` · `npm run test --prefix frontend` · `npm run e2e --prefix frontend` | Übersprungene Tests nur mit begründeter Markierung |
| D6 | Abdeckung | `make abdeckung` → `uv run pytest --cov=backend/src/r3cosint --cov-fail-under=80` und ein zweiter Lauf `--cov=backend/src/r3cosint/spur --cov=backend/src/r3cosint/zugriff --cov=backend/src/r3cosint/freigabe --cov-fail-under=100` | Die drei Module sind genau die aus D6: Protokoll, Klassifizierung, Freigabesperre. Werte offen, Entscheid E-07 |
| D7 | Abnahmekriterien | `make abnahme` → `uv run pytest -q -m abnahme` · `bash scripts/abnahme-abgleich.sh` | Der Abgleich vergleicht die Testnamen des Backlogs mit den gesammelten Testkennungen und meldet jede Anforderung ohne Test (6.6). Eigenes Projektartefakt, entsteht mit dem Grundgerüst |
| D8 | Abhängigkeiten | `make abhaengigkeiten` → `uv run pip-audit --strict` · `npm audit --prefix frontend --audit-level <Schwelle>` | Schwelle offen, Entscheid E-08. Offline setzt eine gespiegelte Schwachstellendatenbank voraus — DevOps |
| D9 | Kein Rückkanal | `make rueckkanal` → `bash scripts/rueckkanal-pruefen.sh` | Eigenes Projektartefakt, entsteht mit R3-C-004. Es gibt dafür kein Standardwerkzeug |
| D10 | Prototyp-Trennung | `make prototyp-trennung` → `bash scripts/prototyp-trennung-pruefen.sh` | **Befund:** Das bestehende `.claude/hooks/block-prototype-import.sh` ist ein `PreToolUse`-Hook und liest ein JSON-Ereignis von der Standardeingabe. Für D10 wird eine Stapelprüfung über den Bestand gebraucht — entweder als Betriebsart des bestehenden Skripts oder als eigenes Skript. Zu klären mit DevOps |
| D11 | Geheimnisse | `make geheimnisse` → `gitleaks detect --redact --exit-code 1` | |
| D12 | Nachweise | `make nachweise` → `bash scripts/nachweise-erzeugen.sh` · `bash scripts/nachweise-vollstaendig.sh` | **Befund:** Ein Abgleich über `git diff --exit-code docs/NACHWEISE.md` kann nicht funktionieren. Die erzeugte Datei trägt den Stand des Repositories (`git rev-parse HEAD`); der ändert sich mit dem Commit, der die Datei enthält, weshalb der nächste Lauf immer eine Abweichung erzeugt. D12 prüft deshalb den Rückgabewert des Erzeugers — er endet mit 1, wenn ein Artefakt fehlt oder nicht committet ist — und zusätzlich, dass kein nachweispflichtiges Artefakt in der Liste fehlt. Zu klären mit Protocol Master und DevOps |

**Zwei Ebenen der Namensbindung.** Die Backend-Befehle stehen unmittelbar im Makefile, die Oberflächenbefehle laufen über Skripte in `frontend/package.json`. Damit steht jeder Werkzeugname genau einmal und an der Stelle, an der er hingehört; die Kette selbst bleibt unverändert, wenn ein Werkzeug ausgetauscht wird.

**Ein Einstieg für den Hook.** `make dod` ruft D1 bis D12 der Reihe nach auf und endet bei der ersten Abweichung ungleich 0. Der Hook aus R3-Q-001 ruft **diesen einen Befehl** auf. Damit hängt R3-Q-001 nur noch am Vorhandensein des Makefiles und nicht mehr an einzelnen Werkzeugnamen; ändert sich ein Werkzeug, ändert sich das Makefile, nicht der Hook. Für den Hook gelten unverändert: nur Rückgabewert 2 blockiert, Reentranz-Schutz über `stop_hook_active`, Eskalation nach dreimaligem Scheitern am gleichen Kriterium (3.4).

**Umgang mit noch nicht vorhandenen Teilbäumen.** Solange `frontend/package.json` fehlt, entfallen die Oberflächenschritte und der Kettenschritt endet mit 0 und einer Meldung. Sobald die Datei existiert, laufen sie zwingend. Das ist als Bedingung im Makefile zu prüfen und nicht als auskommentierte Zeile abzubilden — eine auskommentierte Prüfung bleibt still liegen, nachdem sie gebraucht würde.

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
| O-4 | Einbindungstiefe von TheHive und Cortex | Es gibt dafür heute **keinen Backlog-Eintrag**. Ohne Anforderung mit Abnahmekriterium wäre jede Tiefenangabe erfunden. Der ehrliche erste Schritt ist ein Eintrag, nicht ein Entwurf | Product Owner legt den Eintrag an, danach Software Architect als eigener ADR | vor Etappe 2 |
| O-5 | Erzeugung und Prüfung von PDF/A-3 mit eingebetteten Daten (R3-F-074) | Die Wahl entscheidet über zusätzliche Abhängigkeiten und möglicherweise eine zweite Laufzeitumgebung im Prüfcontainer | Software Architect mit Backend Engineer; eigener ADR | vor Etappe 4 |
| O-6 | Verwaltung der fallbezogenen Schlüssel (4.4, Problem B): wo das Schlüsselmaterial liegt und wie es getrennt von den verschlüsselten Daten gesichert wird | Berührt Sicherung und Wiederherstellung (Bereitschaft 3) und ist mit SecDevOps und Datenschutz gemeinsam zu entscheiden | Software Architect mit SecDevOps und Datenschutzexperte; eigener ADR | vor R3-F-020, Etappe 1 |
| O-7 | Schwellenwerte in D3, D6 und D8 | Sind am Gate als E-07 und E-08 offen | Auftraggeber mit SecDevOps | mit R3-Q-001 beziehungsweise der ersten Umsetzungseinheit mit Code |
| O-8 | Betriebsart für D10 und Form von D12 (Befunde in Abschnitt 6) | Betrifft bestehende Skripte, die anderen Rollen gehören | DevOps Engineer mit Protocol Master | mit R3-Q-001 |
| O-9 | Anbindungsdaten des Entra-ID-Mandanten | Liegen bei der Informatik der Kantonspolizei Bern | KapoBE Informatik | blockiert nur den Mandantenwechsel, nicht die Entwicklung |

Nicht offen, sondern entschieden und hier nur zur Klarstellung: `pgvector` (A4), Suchindex (A3), Orchestrierung (A11). Nicht offen, weil gestrichen: VirusTotal, Gesichtserkennung samt biometrischer Vektoren, Open WebUI, CASE/UCO, Fernsteuerung von Maltego.

---

## 9. Was dieser ADR nach seiner Freigabe auflöst und was nachzuführen ist

**Aufgelöst mit der Freigabe:**

| Offener Punkt | Fundstelle | Auflösung |
|---|---|---|
| Ziel-Stack, Rahmenwerk und Komponentenbibliothek der Oberfläche | `docs/04_Kontextmodell.md`, offener Punkt 1 | Stack und Rahmenwerk entschieden (A1, A8); Komponentenbibliothek terminiert als O-2 |
| Ob `pgvector` gebraucht wird | `docs/04_Kontextmodell.md`, offener Punkt 3; 5.18 | Entschieden: nein (A4) |
| Konkrete Befehle je Kettenschritt | `docs/06_Definition_of_Ready_und_Done.md`, offener Punkt 3 | Vorschlag in Abschnitt 6, zu bestätigen durch DevOps und Auftraggeber |
| Abhängigkeit von R3-Q-001 auf R3-C-001 | `docs/05_Product_Backlog.md`, R3-Q-001 | Aufgelöst: Der Hook ruft `make dod`; die Werkzeugnamen stehen im Makefile |
| Einbindungstiefe TheHive/Cortex | `docs/04_Kontextmodell.md`, offener Punkt 2 | **Nicht** aufgelöst; neu terminiert als O-4, mit dem Befund, dass zuerst ein Backlog-Eintrag fehlt |

**Nachzuführen durch die zuständigen Rollen — nicht durch diese Arbeitseinheit:**

| Was | Wo | Wer |
|---|---|---|
| Suchindex in PostgreSQL, Container- und Netzlayout, Modulschnitt, Auflösung der offenen Punkte 1 und 3 | `docs/04_Kontextmodell.md` | Software Architect, eigene Arbeitseinheit |
| Konkrete Befehle in der Tabelle D1 bis D12, Befunde zu D10 und D12 | `docs/06_Definition_of_Ready_und_Done.md` | DevOps Engineer, Bestätigung Auftraggeber |
| Backlog-Eintrag für TheHive/Cortex (O-4); Formulierung der Abnahme von R3-C-001 gegenüber 5.6 (O-1) | `docs/05_Product_Backlog.md` | Product Owner |
| Zeile für diesen ADR in der Artefaktliste des Erzeugers; Neuerzeugung des Nachweisverzeichnisses; Changelog | `scripts/nachweise-erzeugen.sh`, `docs/NACHWEISE.md`, `CHANGELOG.md` | Protocol Master (4.2, 6.6) |
| Statustabelle und Verweis auf den Ziel-Stack | `CLAUDE.md` | Protocol Master |
| Anlegen des Grundgerüsts nach Abschnitt 5 | `backend/`, `deploy/`, `Makefile` | Backend Engineer und DevOps Engineer, nächste Arbeitseinheit |

---

## 10. Freigabevermerk

R3-C-001 gilt erst als abgenommen, wenn hier die schriftliche Freigabe des Auftraggebers vermerkt ist und der Status oben auf „angenommen" steht. Bis dahin bleibt dieser ADR ein Vorschlag, und Etappe 1 beginnt nicht.

| | |
|---|---|
| **Vorgelegt am** | 2026-08-20 |
| **Entscheid des Auftraggebers** | *offen — freigegeben / freigegeben mit Auflagen / zurückgewiesen* |
| **Auflagen** | *offen* |
| **Entscheid zu O-1 (Trennung Rahmenwerk und Komponentenbibliothek)** | *offen — bestätigt / Backlog anzupassen* |
| **Datum der Freigabe** | *offen* |
| **Auftraggeber (S-01)** | *offen; Name nach offenem Entscheid E-11 nicht im Repository geführt* |

Formweg wie beim Freigabe-Gate Schritt 4: entweder direkte Bearbeitung dieser Datei über einen Pull Request oder Anweisung an die nächste Sitzung mit dem exakten Wortlaut des Entscheids. Massgeblich ist der committete Stand; Urheber und Zeitpunkt belegt die Commit-Historie.
