# Übergabe — Arbeitseinheit «Regeln für Mitwirkende»

| | |
|---|---|
| **Arbeitsprodukt nach** | Projektauftrag 3.3 (Übergabedatei je Arbeitseinheit) |
| **Einheit** | Einheit 2 dieser Session: CONTRIBUTING.md, CODEOWNERS, Pull-Request-Vorlage |
| **Weisung** | Auftraggeber, 2026-08-21 (drei Einheiten, je ein Commit, ein Pull Request) |
| **Datum** | 2026-08-21 |
| **Zweig** | `claude/commit-identity-contributor-rules-banrlq` |

## Was fertig ist

- `CONTRIBUTING.md` **neu**, mit den fünf Punkten der Weisung: kein
  direkter Push auf `main`, jede Änderung über einen Pull Request und
  externe Mitwirkende aus einem Fork; kein Force Push und keine
  Historienänderung auf gemeinsamen Zweigen; Merge ausschliesslich durch
  den Repository-Eigentümer; Conventional Commits mit Verweis auf die
  Definition of Ready und Done (`docs/06_Definition_of_Ready_und_Done.md`)
  und die Versionsableitung; keine echten Fall- oder Personendaten in
  keinem Commit, weil das Repository öffentlich ist. Ergänzt um den
  Meldweg bei versehentlich gepushten echten Daten und den
  Sprachhinweis (Schweizer Schreibweise).
- `.github/CODEOWNERS` **neu**: `* @valITino` — der Eigentümer ist Code
  Owner für alle Pfade, ohne spezifischere Regeln.
- `.github/pull_request_template.md` **neu**, mit der Prüfliste aus der
  Weisung: betroffener Backlog-Eintrag (bzw. Weisung), Definition of Done
  erfüllt, Nachweise nachgeführt, keine echten Falldaten.

## Was offen ist

- Die Regeln in `CONTRIBUTING.md` sind Kontext, keine Durchsetzung
  (3.2 c). Hart erzwungen ist auf Claude-Seite nur das main-Gate
  (`block-main-write.sh`); der Schutz gegen direkte Pushes und Force
  Pushes durch Menschen liegt in den GitHub-Einstellungen
  (Branch-Protection) und damit beim Auftraggeber.
- Damit GitHub den Code Owner als Pflicht-Reviewer erzwingt, muss in der
  Branch-Protection «Require review from Code Owners» aktiv sein —
  Entscheidung und Einstellung beim Auftraggeber.
- Die Gegenprüfung durch den Static Software Tester erfolgt nach
  Abschluss aller drei Einheiten dieser Session über den Gesamtdiff;
  Ergebnis in der Übergabedatei der Einheit 3.

## Welche Entscheidungen getroffen wurden

1. **Ausnahme benannt statt verschwiegen:** Das Verbot der
   Historienänderung kennt genau einen Sonderfall — das Entfernen
   versehentlich gepushter echter Daten, ausschliesslich durch den
   Eigentümer. Ohne diese Nennung stünden Datenschutz und
   Force-Push-Verbot im Widerspruch.
2. **Prüfliste um «Weisung» ergänzt:** Nicht jede Einheit geht auf einen
   Backlog-Eintrag zurück (Beispiel: diese Session). Die Vorlage lässt
   deshalb Kennung **oder** Weisung des Auftraggebers zu, damit die
   Herkunft in jedem Fall benannt ist.
3. **Kein Eintrag in CLAUDE.md:** Die Weisung benennt drei Dateien;
   CONTRIBUTING.md richtet sich an menschliche Mitwirkende, nicht an die
   Session. Die Tabelle «Wo steht was» bleibt unverändert.
