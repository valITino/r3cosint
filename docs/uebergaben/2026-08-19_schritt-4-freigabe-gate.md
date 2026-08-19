# Übergabe — Arbeitseinheit «Freigabe-Gate Schritt 4 vorbereiten»

| | |
|---|---|
| **Arbeitsprodukt nach** | Projektauftrag 3.3 (Übergabedatei je Arbeitseinheit) |
| **Einheit** | Lieferschritt 4 nach Abschnitt 2 — Vorbereitung des Freigabe-Gates |
| **Datum** | 2026-08-19 |
| **Zweig** | `claude/freigabe-gate-1u25xi` |

Erste Übergabedatei des Projekts. Ablageort und Namensschema
`docs/uebergaben/JJJJ-MM-TT_<einheit>.md` gelten ab jetzt als Konvention;
frühere Einheiten haben ihren Stand in den Pull-Request-Beschreibungen
hinterlassen.

## Was fertig ist

- `docs/08_Freigabe_Schritt_4.md` — Prüfvorlage und Freigabeprotokoll für das
  Gate: Prüfgegenstand (Stand `41ccb72695d0755a879d50c2fd1ffd4ce2ae6ea1`),
  Prüffragen je Lieferschritt, Befunde der Vorprüfung V-01 bis V-05,
  Entscheidungspunkte E-01 bis E-13, ausfüllbare Freigabeerklärung, Ablauf
  nach der Freigabe samt Sitzungsmuster.
- CLAUDE.md nachgeführt: Schritt 3 «erledigt», Schritt 4 «vorbereitet» mit
  Verweis; der Absatz zu den noch fehlenden DoD-Gates nennt jetzt die
  Terminierung als R3-Q-001 aus Schritt 3 — ausdrücklich unter Vorbehalt des
  Entscheids E-02 am Gate.
- `scripts/nachweise-erzeugen.sh` um das neue Artefakt erweitert;
  `docs/NACHWEISE.md` im Anschluss an den Commit des Gate-Dokuments neu
  erzeugt (21 Artefakte).

## Was offen ist

- **Die Freigabe selbst.** Sie liegt beim Auftraggeber (S-01), geprüft wird
  gemeinsam mit dem Studienkollegen (S-02). Erteilt ist sie erst mit der
  ausgefüllten, committeten Freigabeerklärung in Abschnitt 6 des
  Gate-Dokuments. Bis dahin bleibt Schritt 5 gesperrt.
- Befund V-01: hängender Verweis «R3-C-020» in R3-Q-001 — Korrekturvorschlag
  liegt im Gate-Dokument, Einordnung durch den Product Owner nach Entscheid.
- Befund V-02: ADR 0001 (7.4) gegen DoD/Backlog beim Zeitpunkt der DoD-Hooks —
  Entscheid E-02 am Gate; je nach Ausgang ist ADR 0001 fortzuschreiben.
- Befund V-04: zwei Folgearbeiten aus ADR 0001 Abschnitt 8 (PreToolUse-Hook
  für die Rollen-Schreibgrenzen, `skills:`-Feld) ohne Backlog-Eintrag —
  Einordnung durch den Product Owner nach Entscheid.
- Die Entscheidungspunkte E-04 bis E-13 mit ihren Terminen.
- Aus der Gegenprüfung: die Linter-Prüfung von `scripts/nachweise-erzeugen.sh`
  ist offen, weil `shellcheck` in der Umgebung nicht verfügbar ist; die
  Bash-Syntaxprüfung (`bash -n`) endete mit 0.

## Welche Entscheidungen getroffen wurden

1. Die Vorbereitung greift dem Entscheid nicht vor: Befunde sind gesammelt und
   mit Vorschlag versehen, nicht behoben (6.7 — Fehlerfindung von
   Fehlerkorrektur trennen). Insbesondere wurden weder R3-Q-001 noch ADR 0001
   geändert.
2. Ausnahme: die Statustabelle und der Gates-Absatz in CLAUDE.md wurden
   nachgeführt, weil sie den tatsächlichen, bereits gemergten Stand falsch
   wiedergaben (Befund V-03, im Gate-Dokument ausgewiesen).
3. «Schriftlich» ist als «committet» konkretisiert, mit zwei zulässigen
   Formwegen (GitHub-Oberfläche oder beauftragte Session); Begründung ist die
   Nachweisbarkeit über die Commit-Historie (6.6).
4. Das Gate-Dokument wurde als Artefakt ins Nachweisverzeichnis aufgenommen;
   Übergabedateien dagegen nicht — sie sind Prozessstand, keine Artefakte im
   Sinne von 6.6.
5. Die Vorbereitung wurde vom Static Software Tester gegengeprüft, auf einem
   anderen Modell als die Umsetzung (3.4). Die elf Befunde sind eingearbeitet:
   E-03 ans Gate verschoben, E-13 ergänzt, E-11 um die S-03-Vertretung
   erweitert, V-03 präzisiert, V-04 und V-05 aufgenommen, die
   PreToolUse-Prüffrage berichtigt, der CLAUDE.md-Absatz unter Vorbehalt von
   E-02 gestellt und die Commit-Reihenfolge so korrigiert, dass diese
   Übergabedatei erst mit dem neu erzeugten Nachweisverzeichnis committet
   wird.

## Nächste Einheit

Nach erteilter Freigabe: R3-C-001 (Architekturentscheid), gemäss Abschnitt 7
des Gate-Dokuments. Ohne Freigabe: keine.
