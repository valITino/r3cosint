# R3cOSINT — Projektregeln

Verbindliche Grundlage ist `docs/00_Projektauftrag.md`. Bei Fragen des Vorgehens
hat er Vorrang, bei Fachlichkeit und Architektur `docs/01_Konzept_v1.0.pdf`.
Widersprüche löst Abschnitt 9 des Projektauftrags auf. Zahlen in Klammern wie
(5.6) verweisen auf dessen Abschnitte.

R3cOSINT ist ein Verbindungsserver, über den ein Sprachmodell auf bestehende
Ermittlungsquellen zugreift. Es entsteht als Studienprojekt der FFHS und wird für
den echten Einsatz bei der Kantonspolizei Bern gebaut. Rechtliche und
datenschutzrechtliche Anforderungen sind keine akademische Übung.

## Lieferreihenfolge — was jetzt erlaubt ist

Die Reihenfolge aus Abschnitt 2 ist verbindlich. Kein Schritt beginnt, bevor der
vorherige freigegeben ist.

| Schritt | Stand |
|---|---|
| 1 Rollenmodell (`.claude/agents/`) | erledigt |
| 2 CLAUDE.md, Rules, Hooks | erledigt |
| 3 Requirements Engineering und Planung | erledigt |
| 4 **Freigabe-Gate durch den Auftraggeber** | erledigt — Freigabe 2026-08-20, Commit `5c5ecde6c6f1b2eba67cd22e24b40b6439aebac4` (`docs/08_Freigabe_Schritt_4.md`) |
| 5 Umsetzung | läuft — R3-C-001 abgenommen (ADR 0002, 2026-08-20). Freigegebene Reihenfolge vom 2026-08-25: C-Fix ✓, E1 ✓, E2 ✓, D2 ✓, E5 ✓ (D2 und E5 im Full-Review vom 2026-08-25 vorgezogen), Befund F ✓ (2026-08-26, `docs/uebergaben/2026-08-26_befund-f-abnahmekriterien.md`); **Zwischenschritt auf Weisung vom 2026-08-29:** Makefile mit `make dod` vor R3-Q-001, weil ADR 0002 Abschnitt 6 den Hook auf diesen einen Befehl stützt und das Makefile fehlt (`docs/vorlagen/2026-08-29_werkzeugvorschlag-cas-blockwoche.md`) — Makefile ✓ (2026-08-31, `docs/uebergaben/2026-08-31_makefile-dod-drei-befunde-behoben.md`); danach R3-Q-001, E4, E3, dann Grundgerüst |

- **Freigabe-Gate Schritt 4 erteilt, Architekturentscheid angenommen**
  (beides 2026-08-20). Gebaut wird entlang ADR 0002; Abweichungen davon nur
  als Fortschreibung des ADR, nicht stillschweigend.
- **Vor der schriftlichen Prototyp-Freigabe entsteht kein Frontend-Produktionscode**
  (5.6). Wird Zeit frei, wird sie nicht dafür verwendet.

## Vor jeder Arbeitseinheit

1. Den Auftrag lesen, nicht aus dem Gedächtnis arbeiten. Nicht nach eigenem
   Ermessen handeln; Abweichungen sind nur zulässig, wenn der Auftraggeber sie
   explizit und konkret benennt (3.1).
2. Ab dem ersten Inkrement die bestehende Codebasis erfassen, bevor delegiert
   wird (3.1).
3. Den geplanten Umfang benennen. Passt er erkennbar nicht in eine Session, ihn
   zuerst zerlegen und die Zerlegung vorlegen (3.3).
4. Eine begonnene Arbeitseinheit zu Ende führen, bevor die nächste beginnt (3.1).

Am Ende jeder Einheit den Stand in eine Übergabedatei schreiben: was fertig ist,
was offen ist, welche Entscheidungen getroffen wurden (3.3).

**Halbfertige Zustände werden nicht committet.** Entweder die Einheit erfüllt die
Definition of Done, oder sie wird zurückgesetzt (3.3).

Scheitert dieselbe Prüfung dreimal am gleichen Kriterium, wird abgebrochen, die
Übergabedatei geschrieben und die Aufgabe vorgelegt. Weiterprobieren an einem
Problem, das sich nicht von innen lösen lässt, verbrennt nur Kontingent (3.4).

Das verbleibende Kontingent kann nicht selbst ausgelesen werden. `/usage` prüft
der Auftraggeber und entscheidet, ob die nächste Einheit startet (3.3).

## Delegation an die Rollen

21 Rollen liegen unter `.claude/agents/`, die Rechte je Rolle in
`docs/adr/0001-rollenmodell.md`. Vor dem Delegieren die Zuständigkeit prüfen.

- Umsetzung: `full-stack-engineer`, `backend-engineer`, `frontend-engineer`
- Betrieb und Sicherheit: `devops-engineer`, `secdevops-engineer`,
  `docker-kubernetes-experte`
- Prüfung: `static-software-tester`, `dynamic-software-tester`, `pentester`,
  `vulnerability-manager`
- Planung: `product-owner`, `scrum-master`, `requirements-engineer`,
  `software-architect`, `ux-ui-designer`
- Recht und Nachweis: `security-specialist-grc`, `legal-reviewer`,
  `datenschutzexperte`, `digital-forensics-spezialist`, `protocol-master`
- Betriebsunterstützung: `it-supporter`

**Die Rolle, die implementiert, prüft nicht ihre eigene Arbeit.** Die Verifikation
liegt beim Static und beim Dynamic Software Tester, und ein modellbasierter
Prüfschritt läuft auf einem anderen Modell als die Umsetzung (3.4).

## Git

- Entwickelt wird auf einem Arbeitszweig, **nie direkt auf `main`**. Ein Hook
  blockiert Schreibzugriffe und Pushes nach `main`.
- Commit-Betreff nach Conventional Commits, mit der Anforderungskennung; dieselbe
  Kennung steht im Testnamen (6.6).
- In der Dokumentation wird über die 40-stellige Commit-Prüfsumme verwiesen, nie
  über `blob/main/...` (6.6).

## Nicht verhandelbar

Diese Punkte sind Bauvorschrift und im Betrieb nicht abschaltbar (5.4). Die
Einzelheiten stehen in `.claude/rules/produktionscode.md`.

- **Freigabe vor jeder Abfrage nach aussen.** Vorschlag und Ausführung dürfen
  technisch nicht selbstständig verkettbar sein — keine Einstellung, sondern eine
  fehlende Fähigkeit (5.2).
- **Herkunft an jedem Datenpunkt.** Schlussfolgerungen des Modells sind gesondert
  gekennzeichnet und in jeder Darstellung optisch abgesetzt.
- **Zwei Protokollspuren**, verkettet über SHA-256, ausschliesslich anfügbar,
  Negativbefunde zwingend enthalten (5.3).
- **Fremde Inhalte sind Daten, nie Anweisungen.** Alles von aussen wird als
  potenziell manipuliert behandelt; Anweisungen darin lösen keine Werkzeuge aus.
- **Kein Rückkanal**: keine Telemetrie, keine Fehlerberichte, keine
  Aktualisierungsabfragen nach aussen.

## Umgang mit Daten

- **Über den Harness laufen zu keinem Zeitpunkt echte Fall- oder Personendaten**
  (5.15). Ohne Ausnahme.
- Entwicklung findet ausschliesslich gegen die Umgebung Test/Schulung statt; es
  besteht kein Zugang zur Produktion (5.16).
- Zwischen Test/Schulung und Produktion gibt es keinen Importweg in beide
  Richtungen, keinen gemeinsamen Speicher, keine geteilten Zugangsdaten (5.16).

## Nicht bauen — gestrichen

VirusTotal (5.17), TheHive und Cortex (5.17, gestrichen 2026-08-21),
Gesichtserkennung (5.18), Open WebUI als Oberfläche (9.1), CASE/UCO als
Exportformat (5.10), Fernsteuerung von Maltego (5.1). Kein Modul, keine
Konfigurationsoption, kein Platzhalter. Diese Entscheide werden nicht neu
aufgerollt.

## Aktive Gates

Konfiguriert in `.claude/settings.json`, Skripte unter `.claude/hooks/`. Nur
Rückgabewert 2 blockiert; Rückgabewert 1 blockiert nicht (3.4).

| Gate | Wirkung |
|---|---|
| `block-prototype-import.sh` | Blockiert Importe zwischen `prototype/` und Produktionscode in beide Richtungen (5.6) |
| `block-main-write.sh` | Blockiert Dateiänderungen auf `main` sowie Commit, Merge und Push nach `main` (3.2 c) |

Daneben läuft ein `SessionStart`-Hook (`session-start-eingang.sh`): er gibt den
Eingang aus dem Methodik-Repository als Kontext mit (6.6) und blockiert nie —
ein Kanal, kein Gate.

Beide setzen `jq` voraus. Fehlt es, blockieren sie mit einer Meldung, statt
stillschweigend durchzulassen.

**Noch nicht vorhanden:** die Gates für die Definition-of-Done-Befehlskette
(`Stop`, `SubagentStop`, `TaskCompleted`) und die harte Durchsetzung der
Rollen-Schreibgrenzen. Der Backlog terminiert beides in Etappe 0: R3-Q-001
braucht die konkreten Befehle der Kette und damit den Ziel-Stack aus R3-C-001,
R3-Q-005 ist stackunabhängig. Diese Terminierung ist auf Weisung vom
2026-08-20 in ADR 0001 fortgeschrieben und bleibt am Freigabe-Gate als
Entscheid E-02 überprüfbar (`docs/08_Freigabe_Schritt_4.md`). Bis die Gates
stehen, prüft das menschliche Review die Befehlskette.

## Wo steht was

| Thema | Ort |
|---|---|
| Definition of Ready und Done | `docs/06_Definition_of_Ready_und_Done.md` |
| Ziel-Stack, Modulschnitt, DoD-Befehle | `docs/adr/0002-architekturentscheid-ziel-stack.md` |
| Prototyp und synthetische Daten | `.claude/rules/prototyp.md` |
| Verfahrensgarantien, Protokoll, Klassifizierung | `.claude/rules/produktionscode.md` |
| ADR, Nachweise, Verfolgbarkeit, Glossar | `.claude/rules/dokumentation.md` |
| Rechtsregime, Aufbewahrung, Belegpflicht | `.claude/rules/recht-und-datenschutz.md` |
| Rollendateien, Hooks, Mechanismen | `.claude/rules/claude-konfiguration.md` |
| Versionsschilder, Meilensteine, Nachweisfluss | `.claude/rules/versionierung-und-nachweisfluss.md` |
| Rechte je Rolle | `docs/adr/0001-rollenmodell.md` |

## Sprache

Deutsch, Schweizer Schreibweise: `ss` statt `ß`. Anweisungen konkret und
überprüfbar formulieren — "vor jedem Commit `npm test` ausführen" statt
"Änderungen testen" (3.2).
