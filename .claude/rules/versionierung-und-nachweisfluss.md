---
paths:
  - ".github/workflows/**"
  - "scripts/nachweise-erzeugen.sh"
  - "docs/NACHWEISE.md"
---

# Regeln für Versionsschilder und Nachweisfluss

Grundlage: Projektauftrag 6.6, 3.2 c. Umgesetzt in
`.github/workflows/nachweise-uebertragen.yml` und
`.github/workflows/meilenstein-tag.yml`.

## Wann getaggt wird

- Ein Versionsschild entsteht **ausschliesslich automatisch**, wenn ein Pull
  Request mit dem Label `meilenstein` nach `main` gemergt wird
  (`meilenstein-tag.yml`). Das Label vergibt der Auftraggeber; damit bleibt
  der Meilensteinentscheid bei ihm, die Mechanik bei der Automatik.
- Die Version wird nach Semantic Versioning aus den Conventional-Commit-
  Betreffzeilen seit dem letzten Versionsschild abgeleitet: `BREAKING
  CHANGE` im Betreff oder `!` nach dem Typ → major, `feat` → minor, `fix`,
  `docs`, `chore` und alles Übrige → patch. Ohne bisheriges Versionsschild
  beginnt die Zählung bei `v0.1.0`.
- Zum Versionsschild entsteht ein GitHub-Release mit den Betreffzeilen als
  Beschreibung.

## Claude Code taggt selbst nie

- Ein Versionsschild ist ein **Meilensteinentscheid des Auftraggebers**,
  keine Arbeitshandlung. Die Entscheidung fällt über das Label am Pull
  Request, nicht in einer Session.
- Ein Versionsschild zeigt auf einen Stand von `main`. Schreibhandlungen
  auf `main` sind für Claude Code durch das Gate gesperrt (3.2 c); ein
  eigenhändiges Tag wäre eine Umgehung dieser Sperre.
- Die Automatik läuft ausserhalb der Sandbox, mit eigenen Rechten, und ist
  im Verlauf des Repositories nachvollziehbar (6.6). Claude Code schreibt
  die Arbeitsabläufe; ausgeführt werden sie von GitHub.

## Commit-Identität der Automatik

- Jeder Commit und jedes Versionsschild, das die Arbeitsabläufe erzeugen —
  auch der Commit in Repo B — trägt als `user.email` die Adresse
  `41898282+github-actions[bot]@users.noreply.github.com`. Sie gehört dem
  GitHub-Konto `github-actions[bot]`; GitHub ordnet Commits über die
  E-Mail-Adresse einem Konto zu.
- `noreply@users.noreply.github.com` wird **nie** verwendet: GitHub liest
  aus dieser Adresse den Benutzernamen `noreply` und verlinkt jeden so
  erzeugten Commit auf das Profil einer unbeteiligten dritten Person.
- Der `user.name` bleibt der sprechende Name des jeweiligen
  Arbeitsablaufs (`r3cosint-nachweise[bot]`, `r3cosint-meilenstein[bot]`).
  Er ist reine Anzeige; die Zuordnung zum Konto läuft allein über die
  E-Mail-Adresse.
- Die Historie wird nicht umgeschrieben. Commits, die vor dieser Regel mit
  der alten Adresse entstanden sind, bleiben stehen; die Regel gilt für
  jeden neuen Commit.

## Wann der Nachweisfluss läuft

`nachweise-uebertragen.yml` läuft bei:

1. **Push nach `main`** mit Änderungen an den Pfaden der Artefaktliste —
   `docs/**`, `.claude/**`, `prototype/**` oder `CLAUDE.md` — der
   Regelfall nach jedem Merge. Bezug ist die Prüfsumme des Push-Commits.
2. **Versionsschild `v*`** — Bezug ist das Versionsschild. Von
   `meilenstein-tag.yml` erzeugte Versionsschilder lösen diesen Weg
   **nicht** aus (GitHub verhindert Kettenauslösung durch das eigene
   Token). Verloren geht dadurch heute nichts, weil der `paths`-Filter des
   Push-Auslösers alle Pfade der Artefaktliste abdeckt und der Push des
   Merges den Lauf deshalb bereits ausgelöst hat. **Achtung:** Wird die
   Artefaktliste um Pfade ausserhalb dieses Filters erweitert, muss der
   `paths`-Filter des Push-Auslösers mitwachsen, sonst entsteht hier eine
   Lücke.
3. **Manueller Start** mit eingegebenem Versionsschild, wahlweise mit
   eingefrorenem Abzug für die Abgabe.

Rauschen in Repo B verhindert nicht mehr der seltene Auslöser, sondern die
**Idempotenzprüfung**: Der Lauf erzeugt `docs/NACHWEISE.md` neu, vergleicht
mit dem Stand in Repo B und endet bei identischem Inhalt ohne
Schreibvorgang — protokolliert im Lauf. Geschrieben wird nur bei echter
Änderung; ein angeforderter Abzug erzwingt den Lauf. Die Prüfungen auf
Zweigverweise und unvollständige Prüfsummen bleiben davor geschaltet: ein
wertloser Nachweis wird nicht übertragen, sondern bricht den Lauf ab.

Zwei schnell aufeinanderfolgende Merges überholen sich nicht: beide
Arbeitsabläufe serialisieren ihre Läufe über eine Concurrency-Gruppe ohne
Abbruch des laufenden Laufs.
