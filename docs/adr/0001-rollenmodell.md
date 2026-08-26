# ADR 0001 — Rollenmodell R3cOSINT

| | |
|---|---|
| **Titel** | Rollenmodell: 21 Rollen als Subagents unter `.claude/agents/` |
| **Status** | angenommen |
| **Datum** | 2026-08-19 |
| **Fortgeschrieben** | 2026-08-26 — Abschnitte 2.4, 3 und 5.2: `maxTurns` des Product Owners von 25 auf 50, nach gemessenem Abbruch an der Grenze (Begruendung in 5.2). 2026-08-25 — Abschnitte 2.4, 3 und 5.2: `maxTurns` des Static Software Testers von 30 auf 80, nach gemessenem Abbruch an der Grenze (Begründung in 5.2). 2026-08-20 — Abschnitte 4, 7.4 und 8: Stand der `settings.json`; Terminierung der Hooks (R3-Q-001 aus Schritt 3, R3-Q-005 ergänzt am 2026-08-20); Auflösung der Befunde V-02 und V-04 (`docs/08_Freigabe_Schritt_4.md`) |
| **Grundlage** | Projektauftrag Abschnitt 4 (4.1 Umsetzungsform, 4.2 Rollen aus dem Originalauftrag, 4.3 ergänzende Rollen, 4.4 rechtliche Rollen), ergänzend 3.2 und 3.4 |
| **Lieferschritt** | Schritt 1 nach Abschnitt 2 (Rollenmodell aufbauen) |

**Betroffene Dateien.** 21 Rollendateien unter `.claude/agents/`:

`backend-engineer.md`, `datenschutzexperte.md`, `devops-engineer.md`, `digital-forensics-spezialist.md`, `docker-kubernetes-experte.md`, `dynamic-software-tester.md`, `frontend-engineer.md`, `full-stack-engineer.md`, `it-supporter.md`, `legal-reviewer.md`, `pentester.md`, `product-owner.md`, `protocol-master.md`, `requirements-engineer.md`, `scrum-master.md`, `secdevops-engineer.md`, `security-specialist-grc.md`, `software-architect.md`, `static-software-tester.md`, `ux-ui-designer.md`, `vulnerability-manager.md`

sowie dieses Dokument, `docs/adr/0001-rollenmodell.md`.

---

## 1. Kontext

Der Originalauftrag beschreibt `CLAUDE.md` als "Orchestrator zwischen den SKILL.md (Skills bzw. Agenten)". Abschnitt 3.2 des Projektauftrags hält fest, dass diese Formulierung drei Mechanismen vermischt, die Claude Code getrennt behandelt: `CLAUDE.md`, Skills unter `.claude/skills/<name>/SKILL.md` und Subagents unter `.claude/agents/<name>.md`.

Konsequenz (a) aus 3.2 ist die massgebende Festlegung:

> Rollen gehören in `.claude/agents/`, nicht in Skills. Ein Subagent besitzt ein eigenes Kontextfenster, eine eigene Tool-Liste (`tools`, `disallowedTools`), ein eigenes Modell und einen eigenen Berechtigungsmodus (`permissionMode`). Genau das braucht ein Rollenmodell. Ein Skill kann das nicht, er ändert nur das Verhalten des Hauptagenten.

Ein Skill wird nur bei Bedarf anhand seines `description`-Felds geladen und bringt weder eigenes Kontextfenster noch eigene Tool-Liste noch eigenes Modell mit. Damit liesse sich weder abbilden, dass der Pentester lesen und analysieren, aber nicht schreiben darf, noch dass Umsetzung und Prüfung auf verschiedenen Modellen laufen (3.4). Skills bleiben nach 3.2 (b) für Standards und Prozeduren reserviert.

Abschnitt 4.1 legt die Form fest: YAML-Frontmatter plus Systemprompt im Body, `name` und `description` als Pflichtfelder, dazu je Rolle eine Tool-Liste nach dem Prinzip der minimalen Rechte, ein zugeordneter Standard und eine definierte Ausgabeform.

---

## 2. Entscheidung

Alle 21 Rollen aus 4.2 und 4.3 werden als Subagents unter `.claude/agents/` angelegt, je Rolle eine Datei. Es gelten vier Leitprinzipien.

### 2.1 Minimale Rechte (4.1)

Die Tool-Liste jeder Rolle ist eine Positivliste und enthält genau die Werkzeuge, die der Auftrag der Rolle erfordert. Lesen und Suchen (`Read`, `Grep`, `Glob`) hat jede Rolle. `Edit` und `Write` fehlen dort vollständig, wo 4.2 die Schreibrechte mit "nein" führt — beim Static Software Tester und beim Pentester. `Bash` erhalten nur Rollen, die Befehle ausführen müssen; wo `Bash` ausschliesslich lesenden Prüfläufen dient, ist das im Body ausdrücklich festgehalten. `WebSearch` und `WebFetch` sind auf die beiden Rollen begrenzt, deren Auftrag die Prüfung externer Rechtsquellen einschliesst (Security Specialist GRC, Legal Reviewer).

### 2.2 `description` als Auslösefall (4.1)

Das `description`-Feld entscheidet über die Delegation und beschreibt deshalb den Auslösefall, nicht die Rolle. Keine der 21 Beschreibungen ist eine Berufsbezeichnung; jede nennt eine Tätigkeit und die Bedingung, unter der sie greift. Neunzehn tun das über "sobald", "wenn" oder "bevor" — Beispiel Static Software Tester: "Prüft geänderten Code ohne Ausführung durch Review, Linting und Typprüfung, bevor eine Backlog-Aufgabe als erledigt gilt." Zwei Beschreibungen tragen die Bedingung im Objekt statt im Nebensatz: Der Full-Stack Engineer wird über den Zuschnitt der Aufgabe ausgelöst ("eine Backlog-Aufgabe ..., die Datenmodell, Serverlogik und Oberfläche zugleich berührt"), der IT Supporter über das auslösende Ereignis ("einen gemeldeten Laufzeitfehler").

### 2.3 Modelltrennung zwischen Umsetzung und Prüfung (3.4)

3.4 verlangt: Die Rolle, die implementiert, prüft nicht ihre eigene Arbeit; wo ein modellbasierter Prüfschritt eingesetzt wird, läuft er auf einem anderen Modell als die Umsetzung, sonst ist die zweite Meinung nur eine Wiederholung der ersten. Umgesetzt ist das über das `model`-Feld:

- Umsetzende und koordinierende Rollen laufen auf `sonnet`.
- Prüfende Rollen und Rollen mit Belegpflicht laufen auf `opus`: Static Software Tester, Dynamic Software Tester, Pentester, Software Architect, Requirements Engineer, Datenschutzexperte, Digital-Forensics-Spezialist, Security Specialist GRC.
- Wo Erstellung und Gegenprüfung ein Paar bilden, sind die Modelle bewusst verschieden. Der Security Specialist GRC erstellt die Konformitätsanalyse auf `opus`, der Legal Reviewer prüft sie auf `sonnet` gegen. Nicht die Modellstufe ist das Kriterium, sondern die Verschiedenheit.
- Die Kehrseite ist in der Rollendatei des Static Software Testers festgehalten: Weil Static und Dynamic Software Tester beide auf `opus` laufen, ist der Testcode des Dynamic Software Testers ausdrücklich nicht Prüfgegenstand des Static Software Testers — eine Prüfung auf demselben Modell wäre keine zweite Meinung.

Verwendet sind ausschliesslich die Aliase `sonnet` und `opus`; keine Rolle nennt eine feste Modell-ID, damit das Rollenmodell einen Modellwechsel überdauert.

### 2.4 `maxTurns` als Endlosschleifen-Schutz (3.4)

3.4, Ebene 4, verlangt verbindlich: "Turn-Begrenzung je Rolle: Im Frontmatter jedes Subagenten wird `maxTurns` gesetzt, damit eine delegierte Rolle nicht unbegrenzt weiterläuft." Jede der 21 Rollen trägt `maxTurns`. Die Staffelung folgt dem Arbeitsumfang der Rolle: 80 für den Static Software Tester (korrigiert am 2026-08-25, Begründung in 5.2), 50 für den Product Owner (korrigiert am 2026-08-26, Begründung in 5.2), 40 für die vier Rollen, die durchgängige Inkremente umsetzen, 30 für Rollen mit mehrschrittiger Analyse- oder Prüfarbeit, 25 für die übrigen Rollen mit eng umrissenem Arbeitsprodukt. `maxTurns` ergänzt die Eskalationsregel aus 3.4 (Abbruch nach dreimaligem Scheitern am gleichen Kriterium), es ersetzt sie nicht.

---

## 3. Rollentabelle — Stand der 21 Dateien

Spalte "Quelle" verweist auf den Abschnitt des Projektauftrags, aus dem die Rolle stammt. Spalte "Schreibrechte laut 4.2" gibt für die Rollen aus 4.2 den Wert der dortigen Tabellenspalte wieder; Tabelle 4.3 führt keine Schreibrechte-Spalte, was in der Spalte entsprechend vermerkt ist.

| Rolle | Quelle | Datei | model | maxTurns | tools | Schreibrechte laut 4.2 | Begründung der Rechte |
|---|---|---|---|---|---|---|---|
| Full-Stack Engineer | 4.2 | `full-stack-engineer.md` | sonnet | 40 | Read, Grep, Glob, Edit, Write, Bash | ja | Setzt Features über alle Schichten um; braucht Schreibzugriff auf Code und Tests sowie `Bash` für die Definition-of-Done-Befehlskette (3.4). |
| Backend Engineer | 4.2 | `backend-engineer.md` | sonnet | 40 | Read, Grep, Glob, Edit, Write, Bash | ja | Serverlogik, Datenmodell, Schnittstellen und Migrationsskripte; `Bash` für Build, Linter, Typprüfung, Testsuite. |
| Frontend Engineer | 4.2 | `frontend-engineer.md` | sonnet | 40 | Read, Grep, Glob, Edit, Write, Bash | ja | Oberflächenumsetzung mit Tests; `Bash` für Build und die automatisierte WCAG-2.2-AA-Prüfung. |
| DevOps Engineer | 4.2 | `devops-engineer.md` | sonnet | 40 | Read, Grep, Glob, Edit, Write, Bash | ja | Pipeline-, Arbeitsablauf- und Changelog-Dateien im Repository; `Bash` für Bau- und Sicherungsläufe gegen Test/Schulung. |
| SecDevOps Engineer | 4.2 | `secdevops-engineer.md` | sonnet | 30 | Read, Grep, Glob, Edit, Write, Bash | ja | Pipeline- und Hook-Konfiguration, SBOM, Secret-Scanning; `Bash`, weil die Wirkung über den Rückgabewert belegt wird (3.4). |
| Docker- und Kubernetes/Portainer-Experte | 4.2 | `docker-kubernetes-experte.md` | sonnet | 30 | Read, Grep, Glob, Edit, Write, Bash | ja | Containerdefinitionen und Manifeste je Umgebung; `Bash` für Härtungs- und Offline-Nachweise. |
| Static Software Tester | 4.2 | `static-software-tester.md` | opus | 80 | Read, Grep, Glob, Bash | nein | Kein `Edit`, kein `Write` — die Rolle meldet Befunde und behebt sie nicht. `Bash` ausschliesslich für lesende Prüfläufe (Linter, Typprüfung, statische Analyse). |
| Dynamic Software Tester | 4.2 | `dynamic-software-tester.md` | opus | 30 | Read, Grep, Glob, Edit, Write, Bash | nur Testcode | `Edit` und `Write` werden gebraucht, weil Testcode zu schreiben ist; die Begrenzung auf Testverzeichnisse und Testdaten steht als Instruktion im Body (siehe Abschnitt 4). `Bash` für die Testläufe. |
| Scrum Master | 4.2 | `scrum-master.md` | sonnet | 25 | Read, Grep, Glob, Edit, Write | nur Planungsartefakte | Schreibt Sprint-Planungsartefakt, Ereignisplan, Hindernisliste, Retrospektivprotokoll und Übergabedatei; kein `Bash`, weil die Rolle keine Befehle ausführt. |
| Pentester | 4.2 | `pentester.md` | opus | 25 | Read, Grep, Glob, Bash | nein | Kein `Edit`, kein `Write`. `Bash` dient ausschliesslich dem Ausführen von Prüfungen gegen die laufende Anwendung in Test/Schulung, nicht dem Ändern von Dateien. |
| Vulnerability Manager | 4.2 | `vulnerability-manager.md` | sonnet | 25 | Read, Grep, Glob, Edit, Write | nur Register | `Edit` und `Write` ausschliesslich für Schwachstellenregister und Statusübersichten; kein `Bash`, weil die Rolle bewertet und nicht sucht. |
| Security Specialist GRC | 4.2 | `security-specialist-grc.md` | opus | 30 | Read, Grep, Glob, Edit, Write, WebSearch, WebFetch | nur Dokumentation | Schreibt die Konformitätsanalyse; `WebSearch` und `WebFetch`, weil jede Aussage mit verifizierter Fundstelle zu führen ist (4.4). Kein `Bash`. |
| Legal Reviewer | 4.2 | `legal-reviewer.md` | sonnet | 25 | Read, Grep, Glob, Edit, Write, WebSearch, WebFetch | nur Dokumentation | Schreibt ausschliesslich den eigenen Prüfbericht; `WebSearch` und `WebFetch` zur Verifikation der angegebenen Fundstellen. Kein `Bash`. |
| Datenschutzexperte | 4.2 | `datenschutzexperte.md` | opus | 25 | Read, Grep, Glob, Edit, Write | nur Dokumentation | Schreibt Bearbeitungsverzeichnis und Löschkonzept; die technische Umsetzung des Löschwegs liegt bei Backend und DevOps, deshalb kein `Bash`. |
| Protocol Master | 4.2 | `protocol-master.md` | sonnet | 25 | Read, Grep, Glob, Edit, Write | ja, nur `docs/` | Führt Dokumentation, Changelog und Nachweisverzeichnis. Kein `Bash`: die Rolle ändert nichts am Git-Zustand, die Commit-Prüfsummen für die festen Verweise nach 6.6 werden ihr zugeliefert. |
| Product Owner | 4.3 | `product-owner.md` | sonnet | 50 | Read, Grep, Glob, Edit, Write | 4.3 ohne Schreibrechte-Spalte; laut Datei nur das Product Backlog samt Ordnung und Schätzung (6.3) | `Edit` und `Write` für das verantwortete Arbeitsprodukt; kein `Bash`, weil die Rolle ordnet und priorisiert, statt auszuführen. |
| Requirements Engineer | 4.3 | `requirements-engineer.md` | opus | 30 | Read, Grep, Glob, Edit, Write | 4.3 ohne Schreibrechte-Spalte; laut Datei ausschliesslich die Arbeitsprodukte aus 6.3 | Stakeholderliste, Glossar und Anforderungen sind Textartefakte; kein `Bash`, keine externe Recherche (6.8). |
| Software Architect | 4.3 | `software-architect.md` | opus | 30 | Read, Grep, Glob, Edit, Write | 4.3 ohne Schreibrechte-Spalte; laut Datei Architecture Decision Records und Kontextmodell, keine Fachlogik | Legt die ADR-Dateien unter `docs/adr/` selbst an (4.3); kein `Bash`, weil die Umsetzung bei den Engineer-Rollen liegt. |
| UX/UI Designer | 4.3 | `ux-ui-designer.md` | sonnet | 30 | Read, Grep, Glob, Edit, Write | 4.3 ohne Schreibrechte-Spalte; laut Datei ausschliesslich im getrennten Prototyp-Verzeichnis | Der Prototyp aus 5.6 wird geschrieben und ergänzt; den maschinell prüfbaren Teil seiner Definition of Done führt der Dynamic Software Tester aus, deshalb kein `Bash`. |
| Digital-Forensics- und Chain-of-Custody-Spezialist | 4.3 | `digital-forensics-spezialist.md` | opus | 30 | Read, Grep, Glob, Edit, Write, Bash | 4.3 ohne Schreibrechte-Spalte; laut Datei ausschliesslich Dokumentation zu Beweiskette und Herkunftsnachweis | `Bash` ausschliesslich für Prüfläufe ohne Zustandsänderung, insbesondere die Prüfsummenkontrolle an der Protokollkette (5.3). |
| IT Supporter | 4.3 | `it-supporter.md` | sonnet | 30 | Read, Grep, Glob, Edit, Write, Bash | 4.3 ohne Schreibrechte-Spalte; laut Datei nur die zur Fehlerbehebung nötigen Dateien | Behebt gemeldete Laufzeitfehler direkt (5.12), braucht dafür Schreibzugriff und `Bash`, um die Prüfkette der betroffenen Aufgabe auf Rückgabewert 0 zu bringen. |

Anmerkung zum Legal Reviewer: 3.2 (a) hält beispielhaft fest, der Legal Reviewer brauche gar keine Schreibrechte; die normative Spalte in Tabelle 4.2 führt dagegen "nur Dokumentation". Die Rollendatei folgt 4.2 und hält den Widerspruch fest, weil 3.2 (a) den Mechanismus erläutert und keine Rechtezuweisung trifft. Die Auflösung ist dem Auftraggeber vorzulegen.

Anmerkung zum IT Supporter: Die Tabellen 4.2 und 4.3 weisen dieser Rolle als einziger keine Arbeitsgrundlage und keinen zugeordneten Standard zu. Die Rollendatei erfindet keinen, sondern setzt die einschlägigen Abschnitte des Projektauftrags an deren Stelle und legt die Festlegung eines Standards dem Auftraggeber vor (4.1).

---

## 4. Grenze der Durchsetzbarkeit

Das Frontmatter eines Subagenten kann Schreibrechte **nicht** auf ein Verzeichnis begrenzen. `tools` und `disallowedTools` sind Listen von Tool-Namen beziehungsweise MCP-Mustern; ein Eintrag mit Pfadangabe ist für das Subagent-Frontmatter nicht dokumentiert. Was sich über `tools` durchsetzen lässt, ist ausschliesslich die Ja/Nein-Frage, ob eine Rolle überhaupt schreiben darf. Genau das ist beim Static Software Tester und beim Pentester umgesetzt: Ohne `Edit` und `Write` kann die Rolle nichts ändern.

Alle abgestuften Rechteformen aus 4.2 und 4.3 liegen unterhalb dieser Auflösung:

| Rechteform | Rollen | Zustand |
|---|---|---|
| nur Testcode | Dynamic Software Tester | Instruktion im Systemprompt |
| nur Planungsartefakte | Scrum Master | Instruktion im Systemprompt |
| nur Register | Vulnerability Manager | Instruktion im Systemprompt |
| nur Dokumentation | Security Specialist GRC, Legal Reviewer, Datenschutzexperte | Instruktion im Systemprompt |
| ja, nur `docs/` | Protocol Master | Instruktion im Systemprompt |
| Arbeitsprodukt-Begrenzung nach 4.3 | Product Owner, Requirements Engineer, Software Architect, UX/UI Designer, Digital-Forensics-Spezialist, IT Supporter | Instruktion im Systemprompt |

Jede dieser Rollen trägt in ihrem Abschnitt "Grenzen und Rechte" den ausdrücklichen Vermerk, dass die Einschränkung nicht durch das `tools`-Feld erzwungen wird, sondern als Instruktion gilt. Das ist bewusst so festgehalten, damit die Lücke nicht später für eine Durchsetzung gehalten wird.

**Wie die Begrenzung hart wird.** Nach 3.4 wirkt ein Gate nur, wenn es versioniert im Repository liegt; Cloud-Sitzungen von Claude Code on the web lesen die lokale `~/.claude/settings.json` nicht. Die harte Durchsetzung gehört deshalb in die versionierte `.claude/settings.json` des Repositories, und zwar über die Hook-Ebenen aus 3.4:

- `PreToolUse` blockiert einen Schreibzugriff ausserhalb des zulässigen Bereichs, bevor er stattfindet.
- `Stop` (für Subagenten sinngemäss `SubagentStop`) verhindert das vorzeitige Beenden.
- `TaskCompleted` verhindert, dass eine Aufgabe als abgeschlossen markiert wird, solange die Prüfkette rot ist.

Für alle drei gilt der in 3.4 als häufigster Fehler benannte Punkt: **Nur Rückgabewert 2 blockiert.** Ein Gate mit `exit 1` ist wirkungslos, ohne dass das auffällt. Ebenso verbindlich sind der Reentranz-Schutz über `stop_hook_active` und die harte Obergrenze über `CLAUDE_CODE_STOP_HOOK_BLOCK_CAP`.

**Diese Hooks existieren noch nicht.** *Fortgeschrieben am 2026-08-20:* Die ursprüngliche Fassung dieses Absatzes beschrieb `.claude/settings.json` als leer (`{}`) und ordnete das Anlegen der Hooks den Lieferschritten 2 und 3 zu. Inzwischen enthält die Datei die beiden `PreToolUse`-Gates aus Schritt 2 (Prototyp-Trennung, main-Schutz) und einen `SessionStart`-Hook; die hier gemeinten Hooks — Verzeichnisbeschränkung je Rolle und Prüfketten-Gates — fehlen weiterhin, und es besteht damit heute keine technische Verzeichnisbeschränkung für irgendeine Rolle. Terminiert ist diese Folgearbeit in Etappe 0: seit Schritt 3 als R3-Q-001 (`Stop`, `SubagentStop`, `TaskCompleted`), seit dem 2026-08-20 — mit der Auflösung von Befund V-04 — auch als R3-Q-005 (`PreToolUse`, Rollen-Schreibgrenzen); Einzelheiten in Konsequenz 7.4. Bis dahin bleibt die Rechtestaffelung eine Verhaltensvorgabe, kein Mechanismus.

---

## 5. Bewusst nicht gesetzte Felder

### 5.1 Kein `skills:`-Feld

3.2 (b) sieht vor, dass Skills pro Rolle über das `skills`-Frontmatter-Feld vorgeladen werden. Keine der 21 Dateien setzt es, weil unter `.claude/skills/` noch keine Skill existiert. Ein Verweis auf eine nicht vorhandene Skill wäre eine Behauptung ohne Gegenstand. Die Reihenfolge aus Abschnitt 2 ist bindend: Schritt 1 legt die Rollen an; Skills als wiederverwendbare Prozeduren und Checklisten entstehen mit den späteren Schritten. Sobald eine Skill vorliegt, wird das Feld je betroffener Rolle nachgetragen und dieser ADR fortgeschrieben.

### 5.2 Einordnung von `maxTurns`

`maxTurns` ist ein offiziell dokumentiertes Frontmatter-Feld und steht in der Referenztabelle der Subagent-Dokumentation. Dokumentiert ist dort allerdings nur die Bedeutung "Obergrenze der agentischen Turns, nach der der Subagent stoppt". Nicht dokumentiert sind: was ein agentischer Turn genau zählt, welches Verhalten das Erreichen der Grenze auslöst und welcher Wert ohne das Feld gilt.

Daraus folgt eine ehrliche Trennung: Dass `maxTurns` gesetzt wird, ist eine Vorgabe aus 3.4. Dass die Werte 25, 30 und 40 lauten, ist eine Projektfestlegung nach Arbeitsumfang und aus der Dokumentation nicht ableitbar. Die Werte sind Startwerte und werden korrigiert, sobald Rollen erkennbar zu früh abbrechen oder zu lange laufen.

**Zweite Korrektur, 2026-08-26 — derselbe Fall bei einer anderen Rolle.** Der Product Owner ist bei der Einordnung der Befund-F-Anforderungen mitten in der Arbeit gestoppt, nachweislich an der Turn-Grenze: Abbruch nach 29 Werkzeugaufrufen bei `maxTurns: 25`, der Fortsetzungslauf brauchte bis zum Bericht insgesamt 44 Werkzeugaufrufe. Bei dem gemessenen Verhältnis von rund 1,16 Werkzeugaufrufen je Turn entspricht das etwa 38 Turns für einen vollständigen Einordnungsdurchgang. **Der Wert steht neu auf 50** — rund 30 Prozent Reserve über dem gemessenen Bedarf, dieselbe Bemessung wie bei der ersten Korrektur.

Der Fall bestätigt die Erwartung aus dem vorangehenden Absatz ein zweites Mal und zeigt zugleich die Grenze der ursprünglichen Staffelung: Sie bemass den Wert am Umfang des *Arbeitsprodukts* der Rolle. Der Product Owner verantwortet mit dem Backlog ein eng umrissenes Arbeitsprodukt, doch eine Einordnung, die jede Zahl aus dem Dateiinhalt nachrechnet, statt sie fortzuschreiben, ist unabhängig davon aufwendig. Massgeblich ist nicht die Breite des Arbeitsprodukts, sondern die Zahl der Prüfschritte, die eine Arbeitseinheit verlangt.

**Erste Korrektur, 2026-08-25 — der Fall ist eingetreten.** Der Static Software Tester ist im Full-Review vom 2026-08-25 dreimal mitten in der Arbeit gestoppt, zuletzt nachweislich an der Turn-Grenze. Gemessen: Der Abbruch erfolgte nach 34 Werkzeugaufrufen bei `maxTurns: 30`; der anschliessende Fortsetzungslauf brauchte 35 weitere Werkzeugaufrufe bis zum Bericht. Ein vollständiger ausführungslastiger Prüfdurchgang liegt damit bei rund 69 Werkzeugaufrufen beziehungsweise etwa 61 Turns. **Der Wert steht neu auf 80** — rund 30 Prozent Reserve über dem gemessenen Bedarf, und weiterhin eine harte Obergrenze im Sinne von 3.4, Ebene 4.

Die Praxis liefert damit auch die fehlende Grössenordnung, die die Dokumentation nicht hergibt: Ein agentischer Turn entspricht in dieser Umgebung ungefähr einem Werkzeugaufruf (30 Turns ≙ 34 Aufrufe).

**Bewusst nicht mitgeändert:** Dynamic Software Tester (30) und Pentester (25) gehören derselben Klasse an — Prüfrollen, die ausführen statt nur zu lesen — und laufen vermutlich in dieselbe Grenze. Für sie liegt aber **keine Messung** vor; sie werden korrigiert, wenn sie erkennbar zu früh abbrechen, nicht auf Verdacht. Das Kriterium dafür ist dasselbe wie hier: ein belegter Abbruch an der Grenze vor geliefertem Arbeitsprodukt.

### 5.3 Positivliste statt `disallowedTools`

`disallowedTools` ist ebenfalls ein dokumentiertes Feld und liesse sich mit `tools` kombinieren. Verwendet wird trotzdem durchgängig die Positivliste, aus drei Gründen:

1. **4.1 verlangt minimale Rechte.** Wird `tools` weggelassen und nur eine Denylist gesetzt, erbt der Subagent alle übrigen Werkzeuge. Das ist das Gegenteil einer minimalen Rechtevergabe: Erlaubt ist dann alles, woran beim Schreiben der Denylist niemand gedacht hat.
2. **Eine Denylist veraltet still.** Kommt ein Werkzeug hinzu, landet es automatisch in jeder Rolle mit Denylist, ohne dass eine Datei geändert wurde. Eine Positivliste bleibt bei dem, was zum Zeitpunkt der Prüfung entschieden wurde.
3. **Nachweisbarkeit.** Für ein Projekt mit Nachweispflicht ist die Positivliste die belegbare Form: Was in der Datei steht, ist die vollständige Rechtemenge der Rolle. Die Begründung je Werkzeug steht in der Tabelle in Abschnitt 3 und im Body der jeweiligen Rolle.

### 5.4 Weitere Felder

Nicht gesetzt sind ferner `permissionMode`, `hooks`, `memory`, `background`, `isolation`, `color` und `mcpServers`. Für keines dieser Felder trifft der Projektauftrag eine Vorgabe; sie werden deshalb nicht auf Vorrat belegt. Die rollenspezifische Verankerung von Hooks über das `hooks`-Feld bleibt als Option für die Folgearbeit aus Abschnitt 4 offen.

---

## 6. Release Manager

4.3 führt den Release Manager als [OFFEN]: "Kann beim DevOps Engineer bleiben. Eigene Rolle nur, wenn Freigabeprozesse formalisiert werden müssen. Entscheidung durch Auftraggeber."

**Entscheid für diesen Stand:** Es wird keine eigene Rollendatei `release-manager.md` angelegt. Die Release-Aufgaben bleiben beim DevOps Engineer und sind dort ausdrücklich verankert: `CHANGELOG.md` nach Keep a Changelog, Versionsschilder nach Semantic Versioning (4.2) sowie der durch das Versionsschild ausgelöste GitHub-Arbeitsablauf für die Nachweisübertragung (6.6). Die Rollendatei `devops-engineer.md` hält den offenen Punkt und seine Herkunft im Abschnitt "Auftrag" fest, damit er nicht verlorengeht.

Die Entscheidung darüber liegt beim Auftraggeber und ist mit dieser Festlegung nicht vorweggenommen. Entscheidet er auf Abtrennung, sind drei Dinge zu tun: eine eigene Rollendatei anlegen, die Release-Aufgaben aus `devops-engineer.md` herauslösen, und diesen ADR fortschreiben — Rollentabelle in Abschnitt 3 und dieser Abschnitt.

---

## 7. Konsequenzen

**7.1 Jede abgestufte Rolle wird doppelt geführt.** Rechte liegen in zwei Formen vor: hart im `tools`-Feld, wo die Auflösung dafür reicht, und weich als Instruktion im Systemprompt, wo sie es nicht reicht. Beide Formen müssen übereinstimmen und beide müssen bei einer Änderung nachgezogen werden. Wird einer Rolle ein Werkzeug hinzugefügt, ohne den Body anzupassen, entsteht eine Rolle, deren Datei zwei verschiedene Aussagen über ihre Rechte macht. Bis die Hooks aus Abschnitt 4 existieren, ist die weiche Form für dreizehn der einundzwanzig Rollen die einzige.

**7.2 Keine Rolle erhält Zugang zur Produktionsumgebung.** Nach 5.16 findet Entwicklung ausschliesslich gegen Test/Schulung statt, und der Entwicklungskontext bekommt technisch keinen Zugang zur Produktion — nicht als Regel, sondern über getrennte Zugangsdaten. Nach 5.15 laufen über den Harness zu keinem Zeitpunkt echte Fall- oder Personendaten. Beides ist in den betroffenen Rollendateien als Grenze festgehalten. Praktische Folge: Punkt 3 der Bereitschaftsliste (Sicherung und nachgewiesene Wiederherstellung der Produktionsdatenbank) kann der DevOps Engineer vorbereiten und in Test/Schulung proben, aber nicht selbst gegen Produktion erbringen; Punkt 7 kann ohnehin nur der Auftraggeber abhaken.

**7.3 Die `description`-Felder sind Pflegegegenstand.** Sie entscheiden über die Delegation. Verschiebt sich der Zuschnitt einer Rolle, ohne dass die Beschreibung nachgezogen wird, wird entweder falsch delegiert oder gar nicht. Beschreibungen sind deshalb bei jeder Rollenänderung mitzuprüfen, insbesondere dort, wo zwei Rollen aneinandergrenzen: Static gegen Dynamic Software Tester, Pentester gegen Vulnerability Manager, Requirements Engineer gegen Product Owner, UX/UI Designer gegen Frontend Engineer, Security Specialist GRC gegen Legal Reviewer gegen Datenschutzexperte.

**7.4 Die Gates aus 3.4 sind ausstehende Folgearbeit.** Ohne `PreToolUse`-, `Stop`- beziehungsweise `SubagentStop`- und `TaskCompleted`-Hooks in der versionierten `.claude/settings.json` bleibt die Rechtestaffelung eine Verhaltensvorgabe. *Fortgeschrieben am 2026-08-20:* Die ursprüngliche Fassung verlangte diese Arbeit vor dem Freigabe-Gate in Schritt 4. Schritt 3 hat sie konkretisiert und anders terminiert: Die Definition-of-Done-Gates entstehen als R3-Q-001 in Etappe 0 — die Befehle der DoD-Kette hängen vom Ziel-Stack aus R3-C-001 ab (`docs/06_Definition_of_Ready_und_Done.md`, «Die Befehlskette», «Durchsetzung» und «Offene Punkte» Nr. 3). Die harte Durchsetzung der Rollen-Schreibgrenzen blieb in Schritt 3 ohne Backlog-Eintrag (Befund V-04) und kam am 2026-08-20 als R3-Q-005 hinzu, ebenfalls in Etappe 0. Auf Weisung des Auftraggebers vom 2026-08-20 ist Befund V-02 in dieser Richtung aufgelöst und der ADR fortgeschrieben (`docs/08_Freigabe_Schritt_4.md`); die Bestätigung durch den Auftraggeber steht als Entscheid E-02 am Freigabe-Gate aus.

**7.5 Der ADR bildet einen Stand ab.** Er beschreibt die 21 Dateien, wie sie am 2026-08-19 vorliegen. Änderungen an Modell, `maxTurns`, Tool-Liste oder Rechteform einer Rolle sind hier nachzuführen; das Nachführen in Changelog und Nachweisverzeichnis liegt beim Protocol Master (4.2, 6.6).

---

## 8. Offene Punkte, die dieser ADR nicht entscheidet

| Punkt | Fundstelle | Zuständig |
|---|---|---|
| Release Manager als eigene Rolle | 4.3 [OFFEN] | Auftraggeber |
| Schreibrechte des Legal Reviewers: 3.2 (a) "gar keine" gegen 4.2 "nur Dokumentation" | 3.2, 4.2 | Auftraggeber |
| Zugeordneter Standard für den IT Supporter | 4.1, 4.2, 4.3 | Auftraggeber |
| Hooks in der versionierten `.claude/settings.json` | 3.4; terminiert als R3-Q-001 und R3-Q-005 in Etappe 0 (Fortschreibung 2026-08-20) | Folgearbeit im Backlog |
| `skills:`-Feld je Rolle, sobald Skills existieren | 3.2 (b); terminiert als R3-C-007 (Fortschreibung 2026-08-20) | Folgearbeit im Backlog |
