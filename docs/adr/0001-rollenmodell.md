# ADR 0001 — Rollenmodell als Subagents

- **Status:** angenommen
- **Datum:** 2026-08-19
- **Grundlage:** Projektauftrag `docs/00_Projektauftrag.md`, Abschnitt 4 (Rollenmodell), mit Bezügen zu 3.2 (Mechanismen), 3.4 (Iterationspflicht) und 6 (Requirements Engineering / Scrum)
- **Betrifft:** `.claude/agents/*.md`

## Kontext

Der Auftrag verlangt ein Rollenmodell für die Entwicklung. Nach 3.2 gehören Rollen in `.claude/agents/` (Subagents mit eigenem Kontextfenster, eigener Tool-Liste, eigenem Modell), nicht in Skills. Jede Rolle wird als eine Datei je Rolle angelegt, mit den Pflichtfeldern `name` und `description` sowie `tools`, `model` und `maxTurns`.

Dieser ADR hält fest, welche Rolle welche Rechte hat und warum. Er umfasst die Rollen aus 4.2 (Originalauftrag) und 4.3 (Ergänzungen). Der Release Manager (4.3, [OFFEN]) bleibt vorerst beim DevOps Engineer; eine eigene Rolle entsteht nur, wenn der Auftraggeber Freigabeprozesse formalisiert.

## Entscheidung

### Leitprinzipien

1. **Minimale Rechte.** Die Tool-Liste jeder Rolle richtet sich nach der Spalte „Schreibrechte" in 4.2 bzw. — für 4.3-Rollen — nach der engsten Rechteform, die den Auftrag erfüllt.
2. **`description` beschreibt den Auslösefall, nicht die Rolle** (4.1). Das `description`-Feld entscheidet über die Delegation und nennt deshalb die auslösende Situation.
3. **Verifikation auf anderem Modell als die Umsetzung** (3.4, Rollentrennung in der Schleife). Die umsetzenden Rollen laufen auf `sonnet`, die unabhängig prüfenden und die juristisch/architektonisch abwägenden Rollen auf `opus`. So ist die zweite Meinung nicht die Wiederholung der ersten.
4. **`maxTurns` je Rolle** (3.4, Endlosschleifen-Schutz), abgestuft nach Umfang der typischen Arbeitseinheit.

### Grenze der Durchsetzbarkeit auf Tool-Ebene

Die Frontmatter-Rechte kennen nur „darf `Edit`/`Write` aufrufen" oder nicht. Eine Einschränkung wie „nur `docs/`", „nur Testcode", „nur Register" oder „nur Planungsartefakte" lässt sich damit **nicht** verdrahten. Diese engeren Grenzen sind im Systemprompt jeder Rolle festgehalten und werden verbindlich erst über die Gates aus 3.4 (`PreToolUse`- bzw. `Stop`/`TaskCompleted`-Hooks in der versionierten `.claude/settings.json`) erzwungen. Die Hooks sind Gegenstand einer späteren Arbeitseinheit; dieser ADR legt die Rechte fest, nicht ihre Hook-Durchsetzung.

Konkret bedeutet das: Rollen mit der Rechteform „nein" (kein Schreibrecht) erhalten **kein** `Edit`/`Write`; Rollen mit einer eingeschränkten Schreibform („nur Dokumentation", „nur Testcode", „nur Register", „nur Planungsartefakte", „nur `docs/`") erhalten `Edit`/`Write` mit der Einschränkung als Instruktion.

### Rechte je Rolle

Legende Schreibrechte: **Code** = Produktionscode; **Test** = nur Testcode; **Doku** = nur Dokumentation; **Register/Plan/Backlog** = nur das genannte Artefakt; **nein** = keine.

| Rolle | Quelle | Modell | maxTurns | Tools | Schreibrechte (4.2/4.3) | Begründung der Rechte |
|---|---|---|---|---|---|---|
| Full-Stack Engineer | 4.2 | sonnet | 40 | Read, Grep, Glob, Edit, Write, Bash | Code (ja) | Baut über alle Schichten; braucht Schreiben und Ausführen. |
| Backend Engineer | 4.2 | sonnet | 40 | Read, Grep, Glob, Edit, Write, Bash | Code (ja) | Serverlogik, Datenmodell, Schnittstellen. |
| Frontend Engineer | 4.2 | sonnet | 40 | Read, Grep, Glob, Edit, Write, Bash | Code (ja) | UI-Umsetzung; kein Frontend-Code vor Prototyp-Freigabe (5.6). |
| DevOps Engineer | 4.2 (+ Release Manager) | sonnet | 40 | Read, Grep, Glob, Edit, Write, Bash | Code (ja) | Pipeline, Deployment, Nachweis-Workflow; übernimmt Release-Aufgaben. |
| SecDevOps Engineer | 4.2 | sonnet | 30 | Read, Grep, Glob, Edit, Write, Bash | Code (ja) | Härtet Pipeline und Lieferkette. |
| Docker-/Kubernetes-Experte | 4.2 | sonnet | 30 | Read, Grep, Glob, Edit, Write, Bash | Code (ja) | Container, Orchestrierung, Härtung, Analyse-Isolation. |
| Static Software Tester | 4.2 | opus | 30 | Read, Grep, Glob, Bash | nein | Analyse ohne Ausführung; kein `Edit`/`Write`. Bash nur für Linter/Typprüfer. Anderes Modell als Umsetzung (3.4). |
| Dynamic Software Tester | 4.2 | opus | 30 | Read, Grep, Glob, Edit, Write, Bash | Test | Schreibt nur Testcode; verifiziert die laufende Anwendung. Anderes Modell als Umsetzung (3.4). |
| Scrum Master | 4.2 | sonnet | 25 | Read, Grep, Glob, Edit, Write | Plan | Nur Planungsartefakte; kein Code, keine Priorisierung. |
| Pentester | 4.2 | opus | 25 | Read, Grep, Glob, Bash | nein | Findet Schwachstellen, kein `Edit`/`Write` (ausdrückliche Aufgabenvorgabe). Trennung Finder/Bewerter. |
| Vulnerability Manager | 4.2 | sonnet | 25 | Read, Grep, Glob, Edit, Write | Register | Bewertet und verfolgt; schreibt nur das Register. |
| Security Specialist GRC | 4.2 | opus | 30 | Read, Grep, Glob, Edit, Write, WebSearch, WebFetch | Doku | Konformitätsanalyse mit Fundstellen; Recherche braucht Web-Tools. |
| Legal Reviewer | 4.2 | opus | 25 | Read, Grep, Glob, Edit, Write, WebSearch, WebFetch | Doku | Juristische Gegenprüfung; keine Schreibrechte auf Code (ausdrückliche Aufgabenvorgabe). |
| Datenschutzexperte | 4.2 | opus | 25 | Read, Grep, Glob, Edit, Write, WebSearch, WebFetch | Doku | Löschkonzept, Bearbeitungsverzeichnis; nur Dokumentation. |
| Protocol Master | 4.2 | sonnet | 25 | Read, Grep, Glob, Edit, Write | nur `docs/` | ADRs, Changelog, Nachweisverzeichnis; Schreiben auf `docs/` beschränkt. |
| Product Owner | 4.3 | sonnet | 25 | Read, Grep, Glob, Edit, Write | Backlog | Ordnet das Backlog; kein Code. Getrennt vom Requirements Engineer (6.1). |
| Requirements Engineer | 4.3 | opus | 30 | Read, Grep, Glob, Edit, Write, WebSearch, WebFetch | Doku (RE-Arbeitsprodukte) | Erhebt testbare Anforderungen nach IREB; kein Code. |
| Software Architect | 4.3 | opus | 30 | Read, Grep, Glob, Edit, Write | Doku (ADR/Kontextmodell) | Entscheidet und dokumentiert; implementiert nicht selbst. |
| UX/UI Designer | 4.3 | sonnet | 30 | Read, Grep, Glob, Edit, Write | Prototyp (`prototype/`) | Entwirft und ergänzt den Wegwerf-Prototyp; kein Produktionscode. |
| Digital-Forensics-/Chain-of-Custody-Spezialist | 4.3 | opus | 30 | Read, Grep, Glob, Edit, Write, Bash | Doku (Spez./Prüfung) | Spezifiziert und verifiziert Herkunft und Verkettung; Bash für Prüfsummenkontrolle. |
| IT Supporter | 4.3 | sonnet | 30 | Read, Grep, Glob, Edit, Write, Bash | Code (Diagnose/Support) | Behebt Laufzeit- und Setup-Probleme; arbeitet gegen Protokolle ohne Fallinhalte. |

### Modellzuordnung — Zusammenfassung

- **`sonnet` (Umsetzung, Prozess, mechanisch):** Full-Stack, Backend, Frontend, DevOps, SecDevOps, Docker/Kubernetes, Scrum Master, Product Owner, Vulnerability Manager, Protocol Master, UX/UI Designer, IT Supporter.
- **`opus` (unabhängige Verifikation, juristische/architektonische Abwägung):** Static Tester, Dynamic Tester, Pentester, GRC, Legal Reviewer, Datenschutzexperte, Requirements Engineer, Software Architect, Digital-Forensics-Spezialist.

Die Trennung stellt sicher, dass jede modellbasierte Prüfung auf einem anderen Modell läuft als die geprüfte Umsetzung (3.4).

## Konsequenzen

- Die Rechte sind bewusst eng. Wer für eine Aufgabe zwei Rechteformen braucht (etwa Systembetrieb und Fallzugriff, vgl. 5.8), erhält beide Rollen zugewiesen; das ist im Protokoll sichtbar.
- Die instruktionsbasierten Einschränkungen („nur `docs/`", „nur Testcode" usw.) sind noch nicht hart durchgesetzt. Ihre Durchsetzung über Hooks in `.claude/settings.json` ist eine Folgearbeit (3.4) und wird in einem eigenen ADR festgehalten.
- Kein Zugriff einer Rolle auf die Produktionsumgebung; Entwicklung und Prüfung laufen gegen Test/Schulung mit synthetischen Daten (5.15, 5.16).
- `description`-Felder sind auf die Delegationsauslösung optimiert und sollten mit gleicher Sorgfalt gepflegt werden wie die Rechte, da sie über den Einsatz der Rolle entscheiden.
- Der Release Manager ist nicht als eigene Rolle angelegt. Wird er später abgetrennt, ist dieser ADR fortzuschreiben.
