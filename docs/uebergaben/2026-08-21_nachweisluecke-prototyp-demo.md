# Übergabe — Arbeitseinheit «Lücke im Nachweisverzeichnis geschlossen»

| | |
|---|---|
| **Arbeitsprodukt nach** | Projektauftrag 3.3 (Übergabedatei je Arbeitseinheit) |
| **Einheit** | Einheit 3 dieser Session: Prototyp-Demo in die Artefaktliste, `paths`-Filter mitgewachsen |
| **Weisung** | Auftraggeber, 2026-08-21 (drei Einheiten, je ein Commit, ein Pull Request) |
| **Datum** | 2026-08-21 |
| **Zweig** | `claude/commit-identity-contributor-rules-banrlq` |

## Was fertig ist

- `scripts/nachweise-erzeugen.sh`: `prototype/OSINT_Plattform_Demo.html`
  als Artefakt «Prototyp Demo» mit der Beschreibung «Interaktiver
  Prototyp, Wegwerf» in die `ARTEFAKTE`-Liste aufgenommen. Damit löst der
  nächste Lauf die beiden in Repo B unaufgelöst gebliebenen Platzhalter
  auf, die auf diese Datei verweisen.
- `.github/workflows/nachweise-uebertragen.yml`: Der `paths`-Filter des
  Push-Auslösers ist um `prototype/**` und `CLAUDE.md` gewachsen —
  erzwungen durch den Achtung-Absatz der Regel
  `.claude/rules/versionierung-und-nachweisfluss.md`: wächst die
  Artefaktliste über die Filterpfade hinaus, muss der Filter mitwachsen,
  sonst entsteht dort eine Lücke (ein Push, der nur das Artefakt ändert,
  würde den Nachweisfluss nicht auslösen).
- Alle Prosa-Stellen, die die Filterpfade aufzählen, sind nachgeführt und
  bewusst auf «Pfade der Artefaktliste» verallgemeinert, damit sie beim
  nächsten Wachstum nicht erneut veralten: Kopf- und Filterkommentar in
  `nachweise-uebertragen.yml`, Kettenauslösungs-Kommentar in
  `meilenstein-tag.yml`, Punkte 1 und 2 der Regeldatei (Punkt 1 zählt als
  einzige Stelle die konkreten Pfade auf), Fusstext des Erzeuger-Skripts.
- Probelauf des Skripts: Rückgabewert 0, 23 Artefakte, der neue Eintrag
  trägt die vollständige 40-stellige Prüfsumme
  `783081fe6d13fef8ab89bc9d5f62d3e2e368716a`; die Prüfungen des CI-Laufs
  (kein Zweigverweis, nur vollständige Prüfsummen) bestehen. `bash -n`
  und YAML-Parser ohne Befund.
- `docs/NACHWEISE.md` wurde bewusst **nicht** von Hand neu erzeugt und
  committet: die Neuerzeugung übernimmt der CI-Lauf beim Merge nach
  `main` (Entscheid der Vorgängersession, Übergabe
  `2026-08-21_nachweisfluss-automatisierung.md`).

## Was offen ist

- **Gegenprüfung:** Der Static Software Tester (anderes Modell als die
  Umsetzung, 3.4) prüft den Gesamtdiff der drei Einheiten; das Ergebnis
  wird im Pull Request dokumentiert, Befunde werden vor dem Merge
  behandelt.
- Erster Lauf nach dem Merge im Actions-Verlauf prüfen: erwartet wird
  eine Übertragung nach Repo B mit 23 Artefakten, welche die beiden
  Platzhalter auflöst.
- Der eingefrorene Abzug (`workflow_dispatch` mit `abzug`) erfasst nur
  `md`-, `json`- und `sh`-Dateien; die Prototyp-Demo (`html`) würde —
  wie heute schon das Konzept-PDF — nicht eingefroren. Ob der Abzug
  html/pdf erfassen soll, entscheidet der Auftraggeber.
- Unverändert offen aus der Vorgängersession: die beiden Arbeitsabläufe,
  die Regeldatei `versionierung-und-nachweisfluss.md` und die
  Übergabedateien stehen selbst nicht in der Artefaktliste; Aufnahme
  wäre eine Ergänzung durch den Protocol Master auf Weisung.

## Welche Entscheidungen getroffen wurden

1. **`CLAUDE.md` in den `paths`-Filter aufgenommen — über den Wortlaut
   der Weisung hinaus, offengelegt:** `CLAUDE.md` steht seit Anbeginn in
   der Artefaktliste (Artefakt «Projektregeln»), fehlte aber im Filter —
   eine vorbestehende Lücke derselben Art, die die Regel verbietet. Ohne
   diese eine Zeile wäre die nachgeführte Aussage «der Filter deckt alle
   Pfade der Artefaktliste ab» falsch gewesen. Rückgängigmachen kostet
   eine Zeile im Review.
2. **Artefaktname «Prototyp Demo»,** angelehnt an «Interaktive Demo» im
   Projektauftrag und unterscheidbar vom Artefakt «Regel Prototyp»; Pfad
   und Beschreibung exakt nach Weisung.
3. **Einordnung in der Liste** nach den ADRs und vor `CLAUDE.md`: die
   Demo ist Projektartefakt, keine Claude-Konfiguration. Die Reihenfolge
   ist reine Darstellung; die Auflösung der Platzhalter läuft über den
   Pfad.
