# Übergabe — Arbeitseinheit «Befunde der Vorprüfung auflösen»

| | |
|---|---|
| **Arbeitsprodukt nach** | Projektauftrag 3.3 (Übergabedatei je Arbeitseinheit) |
| **Einheit** | Auflösung der Befunde V-01, V-02, V-04 und V-05 aus `docs/08_Freigabe_Schritt_4.md` |
| **Weisung** | Auftraggeber, 2026-08-20: «Löse noch diese Issues mit deinem Wissen und Intelligenz» |
| **Datum** | 2026-08-20 |
| **Zweig** | `claude/freigabe-gate-1u25xi` |

Die Weisung bezieht sich auf die am Gate vorgelegten Befunde; im Repository
existieren keine GitHub-Issues (offen und geschlossen je null, geprüft am
2026-08-20). **Die Gate-Freigabe E-01 selbst bleibt von dieser Einheit
unberührt beim Auftraggeber.**

## Was fertig ist

- **V-01:** Abhängigkeit in R3-Q-001 umformuliert — statt des nie vorhandenen
  Eintrags R3-C-020 verweist sie auf die Definition of Done und R3-C-001, mit
  Korrekturvermerk im Eintrag.
- **V-02:** Terminierung der Hooks als R3-Q-001 in Etappe 0 auf Weisung hin
  übernommen und ADR 0001 fortgeschrieben (Kopfzeile, Abschnitte 4, 7.4
  und 8). Die Bestätigung durch den Auftraggeber steht als E-02 am Gate aus
  und ist widerrufbar.
- **V-04:** Zwei neue Backlog-Einträge in Etappe 0: R3-Q-005
  (Rollen-Schreibgrenzen als PreToolUse-Gate, 3 h, unabhängig vom Ziel-Stack)
  und R3-C-007 (Skills je Rolle nachgeführt, 1 h, wird mit der ersten Skill
  fällig). Summen nachgezogen: Backlog und Roadmap neu 76 Einträge, 323 h;
  Etappe 0 neu 8 Einträge, 27 h; Gesamtumfang bei 40 Prüfstunden je Sprint
  neu 9 statt 8 Sprints (Rundung), bei 28 h unverändert 12.
- **V-05:** Als Festlegung dokumentiert — kein rückwirkender Handlungsbedarf,
  Kennungspflicht ab der ersten Umsetzungseinheit.
- `docs/08_Freigabe_Schritt_4.md` nachgeführt: Auflösungsvermerk je Befund,
  Stand der Befunde in Abschnitt 4, E-02 als Bestätigungs- statt
  Erstentscheid, Zählungen mit beiden Ständen (Prüfgegenstand und aktuell).
- CLAUDE.md: Gates-Absatz nennt jetzt R3-Q-001 und R3-Q-005 samt
  Fortschreibungsvermerk.
- `scripts/nachweise-erzeugen.sh`: Die Backlog-Beschreibung trägt keine fest
  verdrahtete Eintragszahl mehr — die Zahl war bereits einmal veraltet, die
  Summen stehen im Dokument selbst.

**Commit-Reihenfolge der Einheit:** zwei Commits — zuerst die inhaltlichen
Änderungen samt Skript, danach das neu erzeugte `docs/NACHWEISE.md` zusammen
mit dieser Übergabedatei. Das Verzeichnis wird aus committeten Ständen
erzeugt (bei nicht committeten Artefakten bricht das Skript mit
Rückgabewert 1 ab), deshalb diese Reihenfolge.

## Was offen ist

- **Die Freigabe selbst (E-01)** und die Bestätigung von E-02 und E-03 in der
  Freigabeerklärung, Abschnitt 6 des Gate-Dokuments.
- Die Entscheidungspunkte E-04 bis E-13 mit ihren Terminen.
- Die Linter-Prüfung von `scripts/nachweise-erzeugen.sh` (`shellcheck` in der
  Umgebung nicht verfügbar; `bash -n` endete mit 0).
- Ob die Stichprobe im Abnahmekriterium von R3-Q-005 (drei der dreizehn
  Rollen mit weicher Schreibgrenze) genügt, entscheidet der Product Owner bei
  der Verfeinerung (Hinweis H-8 der Gegenprüfung).

## Welche Entscheidungen getroffen wurden

1. Die Weisung des Auftraggebers wurde als explizite Benennung nach 3.1
   verstanden: Sie deckt die Auflösung der vorgelegten Befunde, nicht die
   Freigabe E-01. Wo ein Befund eine Richtungswahl verlangte (V-02), wurde
   die im Gate-Dokument empfohlene Richtung umgesetzt und die Umkehrung am
   Gate offengehalten.
2. R3-Q-005 formuliert die Anforderung (Blockade mit Rückgabewert 2), nicht
   den Mechanismus: Ob ein zentraler Hook die schreibende Rolle erkennen kann
   oder die Grenze je Rolle über das `hooks`-Feld im Frontmatter verankert
   wird, entscheidet die Umsetzung; der Eintrag hält beide Wege offen.
3. Die Rundungsfolge der Summenänderung wurde nicht geglättet, sondern
   ausgewiesen (9 statt 8 Sprints bei 40 h für den Gesamtumfang) — die
   Roadmap-Zahlen bleiben eine mechanische Ableitung aus der Schätzung.
4. Backlog und Roadmap tragen einen nachgeführten Stand mit Verweis auf die
   Befunde; die Korrekturhistorie bleibt über die Commits nachvollziehbar.
5. Die Einheit wurde vom Static Software Tester gegengeprüft (zweite und
   dritte Runde, anderes Modell als die Umsetzung, 3.4): zwei blockierende
   Befunde, fünf Korrekturen, zehn Hinweise, dazu die Nachbefunde der
   dritten Runde. 15 der 17 Punkte und die Nachbefunde wurden eingearbeitet
   — insbesondere die Fortschreibung von ADR 0001 Abschnitt 4 (dort stand
   noch «settings.json ist leer» und die alte Terminierung), die Trennung
   von Weisung und ausstehender Bestätigung E-02 im ADR und die getrennte
   Datierung von R3-Q-001 (terminiert in Schritt 3) und R3-Q-005 (ergänzt am
   2026-08-20). H-8 bleibt offen beim Product Owner, H-10 bewusst
   unverändert (historischer Stand der älteren Übergabedatei). Hinweis H-5
   wurde durch Umnummerierung gelöst: Der neue Eintrag trägt die Kennung
   R3-C-007 statt einer Nummer aus dem Etappe-6-Block, weil 007 bis 009 frei
   sind und eine Kennung vor dem ersten Commit noch ohne Kosten änderbar
   war; ab jetzt ist sie dauerhaft (6.6).
