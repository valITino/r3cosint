# Definition of Ready und Definition of Done

| | |
|---|---|
| **Arbeitsprodukt nach** | Projektauftrag 6.5, 6.8, 3.4 |
| **Verantwortlich** | Scrum Master (Prozess), Requirements Engineer (Ready), Static und Dynamic Software Tester (Done) |
| **Stand** | 2026-08-20, nachgeführt (DoD-Befehle: ADR 0002, Abschnitt 6) |

Beide sind zu unterscheiden: **Ready gilt für den Eingang in den Sprint, Done
für den Ausgang** (6.8).

---

# Teil 1 — Definition of Ready

Ein Backlog-Eintrag darf erst in einen Sprint gezogen werden, wenn **alle**
Kriterien erfüllt sind. Abgeleitet aus den IREB-Qualitätskriterien (6.5).

## Je Eintrag

| Nr. | Kriterium | Woran es geprüft wird |
|---|---|---|
| R1 | **adäquat** | Bildet ein tatsächliches, mit einem Stakeholder aus `02_Stakeholderliste.md` abgestimmtes Bedürfnis ab. Der Stakeholder ist im Eintrag benannt. |
| R2 | **notwendig** | Ohne den Eintrag fehlt dem Produkt etwas Benanntes. Ein Eintrag "wäre schön" erfüllt R2 nicht. |
| R3 | **eindeutig** | Der Eintrag lässt genau eine Lesart zu. Verwendete Fachbegriffe stehen im Glossar `03_Glossar.md`. |
| R4 | **vollständig in sich** | Der Eintrag ist ohne Rückfrage bearbeitbar. Offene Punkte sind entweder gelöst oder ausdrücklich als Annahme benannt. |
| R5 | **verständlich** | Ohne Zusatzerklärung lesbar, auch für jemanden, der nicht dabei war. |
| R6 | **prüfbar** | Es existiert mindestens ein Abnahmekriterium, das sich als Test formulieren lässt, mit dem Testnamen im Eintrag. |
| R7 | **zugeordnet** | Anforderungsart nach 6.4 ist gesetzt: funktional, Qualität oder Randbedingung. |
| R8 | **geschätzt** | Der Prüfaufwand in Stunden ist geschätzt — **nicht** der Umsetzungsaufwand (6.8). |
| R9 | **verfolgbar** | Der Eintrag trägt eine dauerhafte Kennung und einen Rückverweis auf den Abschnitt des Projektauftrags (6.6). |
| R10 | **abhängigkeitsfrei oder aufgelöst** | Vorbedingungen sind entweder erledigt oder im Eintrag benannt. |

## Für das Backlog als Ganzes

| Nr. | Kriterium |
|---|---|
| B1 | **konsistent** — keine zwei Einträge widersprechen sich |
| B2 | **nicht redundant** — kein Sachverhalt steht zweimal |
| B3 | **vollständig** — nichts Relevantes aus Abschnitt 5 und 6 fehlt |
| B4 | **änderbar** — Änderungen kommen als neuer Eintrag herein und werden vom Product Owner eingeordnet (6.6) |
| B5 | **verfolgbar** in drei Richtungen: rückwärts zum Ursprung, vorwärts zu Umsetzung und Test, seitwärts zu abhängigen Anforderungen (6.6) |
| B6 | **konform zu 4.4** — der präskriptive Teil ist abgebildet und nicht wegpriorisiert |

## Drei Kriterien wiegen schwerer

Adäquatheit und Verständlichkeit sind nach IREB die wichtigsten. Für dieses
Projekt kommt **Prüfbarkeit gleichrangig dazu**, weil die Definition of Done
eine maschinell prüfbare Befehlskette verlangt (3.4). Ein Eintrag ohne testbares
Abnahmekriterium erfüllt die Definition of Ready nicht.

Die Definition of Ready ist der Ort, an dem der menschliche Anteil der
80/20-Aufteilung am meisten bewirkt: **Ein schlecht formulierter Eintrag erzeugt
sauberen Code für das falsche Problem** (6.5).

## Zwei Reihenfolge-Gates

| Gate | Wirkung |
|---|---|
| Freigabe-Gate Schritt 4 (Abschnitt 2) | Vor der schriftlichen Freigabe erfüllt **kein** Umsetzungseintrag die Definition of Ready |
| Prototyp-Freigabe (5.6) | Frontend-Einträge ab R3-F-051 werden vorher nicht verfeinert und nicht geschätzt; Schätzungen vor dem Review wären Vermutungen (6.8) |

---

# Teil 2 — Definition of Done

**Das Abbruchkriterium ist ein Rückgabewert, kein Satz** (3.4). Die Aussage "Die
Aufgabe ist erledigt" ist kein Nachweis, sondern eine Behauptung.

## Die Befehlskette

Eine Aufgabe gilt als erledigt, wenn **jeder** Schritt mit Rückgabewert 0 endet.
Die Kette ist die verbindliche Form; die konkreten Befehle je Schritt stehen
als Vorschlag des Software Architects in **ADR 0002, Abschnitt 6** — die
Bestätigung durch DevOps Engineer und Auftraggeber steht aus (dortige offene
Punkte) — mit `make dod`
als einem Einstieg für die Gates aus R3-Q-001. Sie stehen dort genau einmal —
diese Tabelle nennt die Kriterien, der ADR die Befehle. Die technische
Bestätigung durch den DevOps Engineer und die abschliessende Bestätigung durch
den Auftraggeber — samt der Schwellenwerte aus E-07 und E-08 — erfolgen mit
R3-Q-001; dort werden auch die Befunde des ADR zu D10 und D12 behandelt.

| Nr. | Schritt | Kriterium |
|---|---|---|
| D1 | Bau | Der Programmstand baut fehlerfrei |
| D2 | Formatierung | Keine Abweichung vom Projekt-Codingstandard |
| D3 | Linter | Null Fehler; Warnungen unterhalb des vereinbarten Schwellenwerts |
| D4 | Typprüfung | Null Fehler |
| D5 | Testsuite | Alle Tests grün, keine übersprungenen Tests ohne begründete Markierung |
| D6 | Testabdeckung | Über dem vereinbarten Schwellenwert; **Vorschlag zur Bestätigung: 80 Prozent Zeilenabdeckung, 100 Prozent für Module, die Protokoll, Klassifizierung oder Freigabesperre umsetzen** |
| D7 | Aufgabenspezifische Abnahmekriterien | Jedes Abnahmekriterium des Backlog-Eintrags liegt als bestandener Test mit der Anforderungskennung im Testnamen vor (6.6) |
| D8 | Abhängigkeitsprüfung | Keine Abhängigkeit mit bekannter Schwachstelle oberhalb der vereinbarten Schwelle |
| D9 | Kein Rückkanal | Der Prüfschritt aus R3-C-004 endet mit 0 |
| D10 | Prototyp-Trennung | Der Prüflauf des Gates `block-prototype-import.sh` findet keinen Verstoss |
| D11 | Geheimnisse | Secret-Scanning findet keinen Schlüssel und kein Token im Programmstand |
| D12 | Nachweise | Das Nachweisverzeichnis `docs/NACHWEISE.md` ist neu erzeugt und der Commit-Verweis stimmt |

## Ergänzende Bedingungen, die kein Befehl prüft

Diese Punkte sind Teil der Definition of Done, werden aber von Menschen oder
Rollen bestätigt, nicht von einem Rückgabewert:

| Nr. | Bedingung | Wer bestätigt |
|---|---|---|
| D13 | Die umsetzende Rolle hat ihre Arbeit **nicht** selbst verifiziert | Scrum Master |
| D14 | Static und Dynamic Software Tester haben geprüft, auf einem anderen Modell als die Umsetzung (3.4) | Beide Tester |
| D15 | Die Übergabedatei nach 3.3 ist geschrieben | Umsetzende Rolle |
| D16 | Bei Änderungen an Protokoll, Herkunft, Export oder Löschweg: Prüfbericht des Digital-Forensics-Spezialisten liegt vor | Digital-Forensics-Spezialist |
| D17 | Bei Änderungen am präskriptiven Teil (4.4): GRC-Rolle und Auftraggeber haben entschieden, nicht der Product Owner (6.6) | GRC-Rolle |

## Was nicht als erledigt gilt

- Ein Abnahmekriterium, das sich nicht als Test formulieren lässt. Es gilt als
  **offen** und geht an den Auftraggeber zurück (3.4).
- Ein halbfertiger Zustand. Entweder die Einheit erfüllt die Definition of Done,
  oder sie wird zurückgesetzt (3.3).
- Ein grüner Prüflauf allein. **Eine Prüfung, die nur feststellt, dass die Tests
  gelaufen sind, kann nicht feststellen, dass die Tests das Falsche testen**
  (3.4). Die Iterationspflicht ersetzt das menschliche Review nicht, sie
  entlastet es nur von offensichtlichen Mängeln.

## Durchsetzung

Die Kette wird über Hooks erzwungen, nicht über eine Absichtserklärung:

| Hook | Wirkung |
|---|---|
| `TaskCompleted` | Rückgabewert 2 verhindert, dass eine Aufgabe als abgeschlossen markiert wird, solange die Kette rot ist |
| `Stop` und `SubagentStop` | Rückgabewert 2 verhindert das Beenden und gibt über stderr zurück, was noch fehlt |

**Nur Rückgabewert 2 blockiert.** Rückgabewert 1 ist ein nicht blockierender
Fehler; ein Gate, das mit `exit 1` endet, ist wirkungslos, ohne dass das
auffällt (3.4).

Schutz vor der Endlosschleife, verbindlich (3.4, Ebene 4):
- **Reentranz:** Ist `stop_hook_active` gesetzt, endet der Hook mit 0.
- **Obergrenze:** Acht Blockaden in Folge ohne Fortschritt übersteuert Claude Code
  selbst; anpassbar über `CLAUDE_CODE_STOP_HOOK_BLOCK_CAP`. Notbremse, kein
  Ersatz für den Reentranz-Schutz.
- **Turn-Begrenzung:** `maxTurns` je Rolle, gesetzt in allen 21 Rollendateien.
- **Eskalation:** Scheitert dieselbe Prüfung dreimal am gleichen Kriterium, wird
  abgebrochen, die Übergabedatei geschrieben und die Aufgabe vorgelegt.

Diese Hooks entstehen als Backlog-Eintrag R3-Q-001. Sie konnten vor dieser
Definition nicht gebaut werden, weil es kein Kriterium gab, das sie prüfen
könnten.

## Definition of Done des Prototyps — Sonderfall

Für R3-F-050 gilt eine eigene Definition of Done (5.6), weil ein Prototyp keine
Fachlogik hat, die man testen könnte: maschinell prüfbar sind Bau, Erreichbarkeit
jeder Ansicht, Freiheit von toten Verweisen und die WCAG-2.2-AA-Prüfung; das
Abbruchkriterium ist zusätzlich die **schriftliche Zustimmung von Auftraggeber
und Studienkollegen**. Das ist eine ausdrückliche Ausnahme von 3.4 und gilt nur
für den Prototyp.

---

# Offene Punkte

| Nr. | Punkt | Wer entscheidet |
|---|---|---|
| 1 | Bestätigung der Abdeckungsschwelle in D6 | Auftraggeber |
| 2 | Schwellenwert für Linter-Warnungen (D3) und für Abhängigkeitsschwachstellen (D8) | Auftraggeber mit SecDevOps |
| 3 | Konkrete Befehle je Kettenschritt: eingesetzt am 2026-08-20 mit ADR 0002, Abschnitt 6 (Einstieg `make dod`); offen bleibt die technische Bestätigung samt der Befunde zu D10 und D12 | DevOps Engineer und Auftraggeber, mit R3-Q-001 |
