# Übergabe — Arbeitseinheit «Nachweisfluss automatisiert, Meilenstein-Tagging»

| | |
|---|---|
| **Arbeitsprodukt nach** | Projektauftrag 3.3 (Übergabedatei je Arbeitseinheit) |
| **Einheit** | Einheit 2 dieser Session: Push-Auslöser und Idempotenz im Nachweisfluss, automatisches Versionsschild bei Meilenstein-Merges, Regel festgehalten |
| **Weisung** | Auftraggeber, 2026-08-21 (fünf Anforderungen an den Nachweisfluss, zwei Zusatzaufträge) |
| **Datum** | 2026-08-21 |
| **Zweig** | `claude/zustandsbericht-a55ga2` |

## Was fertig ist

- `.github/workflows/nachweise-uebertragen.yml`:
  - **Zusätzlicher Auslöser** Push nach `main`, eingeschränkt auf `docs/**`
    und `.claude/**`. Tag `v*` und `workflow_dispatch` unverändert. Die
    Filter stehen im selben `push`-Block; GitHub wertet `paths` bei
    Tag-Pushes nicht aus, ein Versionsschild löst also weiterhin immer aus.
  - **Bezug ohne Versionsschild:** Beim Push-Auslöser wird die Prüfsumme
    des Push-Commits (`GITHUB_SHA`) als Bezug verwendet; der
    Dispatch-Eingang `schild` bleibt für manuelle Läufe erhalten, beim
    Tag-Push gilt das Versionsschild. Beschriftungen in `HINWEIS.md` und im
    Abzugskopf von «Versionsschild»/«Schild» auf «Bezug» angepasst.
  - **Idempotenz:** Neuer Schritt nach dem Auschecken von Repo B vergleicht
    das erzeugte `docs/NACHWEISE.md` per `cmp` mit
    `nachweise/NACHWEISE.md` in Repo B. Bei identischem Inhalt enden die
    Schreibschritte ungenutzt und der Lauf protokolliert «Kein
    Schreibvorgang»; ein angeforderter Abzug erzwingt den Lauf. Der
    bestehende `git diff --cached --quiet`-Schutz vor Leercommits bleibt
    als zweites Netz.
  - Die Prüfungen auf Zweigverweise und unvollständige Prüfsummen sind
    unverändert und laufen weiterhin vor jedem Schreiben.
  - Die bestehende Concurrency-Gruppe (`cancel-in-progress: false`)
    serialisiert die Läufe; als solche kommentiert.
- `.github/workflows/meilenstein-tag.yml` **neu**: Nach dem Merge eines
  Pull Requests mit Label `meilenstein` nach `main` wird die Version nach
  Semantic Versioning aus den Conventional-Commit-Betreffzeilen seit dem
  letzten `v*`-Versionsschild abgeleitet (`BREAKING CHANGE` im Betreff oder
  `!` nach dem Typ → major, `feat` → minor, `fix`/`docs`/`chore` und alles
  Übrige → patch; ohne bisheriges Versionsschild Start bei `v0.1.0`), ein
  annotiertes Versionsschild auf den Merge-Commit gesetzt und ein
  GitHub-Release mit den Betreffzeilen als Beschreibung erzeugt.
  Concurrency-Gruppe gegen doppelte Versionsvergabe; `permissions:
  contents: write`, kein Zugriff auf Repo B.
- `.claude/rules/versionierung-und-nachweisfluss.md` **neu**: wann getaggt
  wird, wann der Nachweisfluss läuft, dass Claude Code selbst nie taggt und
  weshalb (Meilensteinentscheid des Auftraggebers via Label; Versionsschild
  zeigt auf `main`, Schreibhandlungen auf `main` sind gesperrt, 3.2 c;
  Automatik läuft ausserhalb der Sandbox, 6.6).
- `docs/00_Projektauftrag.md` Abschnitt 6.6 nachgeführt (Auslöser- und
  Versionsschild-Punkte in den Vorgaben, Tabellenzeile A → B) und das
  Änderungsprotokoll in Abschnitt 8 um die Zeile zum Nachweisfluss ergänzt.
- `scripts/nachweise-erzeugen.sh`: Der erzeugte Fusstext des
  Nachweisverzeichnisses beschreibt die neuen Auslöser und die Idempotenz;
  vorher hätte jede Neuerzeugung die veraltete Aussage «nur
  Versionsschild» wieder hineingeschrieben. Skript mit `bash -n`, beide
  Workflows mit einem YAML-Parser syntaxgeprüft.
- `CLAUDE.md`: neue Regeldatei in der Tabelle «Wo steht was» eingetragen.
- Gegenprüfung durch den Static Software Tester (anderes Modell als die
  Umsetzung, 3.4): ein blockierender Befund — fehlendes `paths:`-Frontmatter
  der neuen Regeldatei — und drei geringe (veralteter Kopf-Kommentar im
  Nachweis-Workflow; mögliche SIGPIPE-Falle bei der Tag-Ermittlung, ersetzt
  durch `git for-each-ref`; zu absolut formulierte Aussage «es geht nichts
  verloren» zur Kettenauslösung, jetzt an die Artefaktliste geknüpft und mit
  Warnhinweis versehen). Alle vier vor dem Commit behoben; die
  GitHub-Actions-Fachlichkeit (paths-/tags-Verhalten, Kontexte, Outputs,
  Injection-Schutz über `env:`) wurde ausdrücklich ohne Beanstandung
  geprüft.

## Was offen ist

- **Erster Lauf des Push-Auslösers** erfolgt mit dem Merge dieses Pull
  Requests nach `main`; Ergebnis im Actions-Verlauf prüfen (Erwartung:
  Übertragung, da `docs/NACHWEISE.md` in Repo B zuletzt vor dieser Session
  stand — oder «Kein Schreibvorgang», falls identisch).
- Das Label `meilenstein` muss im Repository einmalig angelegt werden,
  bevor der erste Meilenstein-Merge es tragen kann (Auftraggeber).
- `docs/NACHWEISE.md` im Repository trägt noch den Stand `3a40faa…`; die
  Neuerzeugung übernimmt künftig der Lauf selbst, eine committete
  Neuerzeugung in Repo A bleibt Meilensteinarbeit des Protocol Master.
- Die beiden neuen Arbeitsabläufe sind im Nachweisverzeichnis
  (`ARTEFAKTE`-Liste des Erzeugers) nicht aufgeführt; Aufnahme wäre eine
  Ergänzung durch den Protocol Master, nicht Teil dieser Weisung.

## Welche Entscheidungen getroffen wurden

1. **Idempotenz schlägt Abzug nicht:** Ein manuell angeforderter Abzug
   erzwingt den Lauf auch bei identischem Nachweisverzeichnis, weil er
   unabhängig vom Verzeichnisinhalt eine eingefrorene Kopie erzeugen soll.
2. **Kettenauslösung bewusst hingenommen:** Ein von `meilenstein-tag.yml`
   mit dem `GITHUB_TOKEN` erzeugtes Versionsschild löst
   `nachweise-uebertragen.yml` nicht aus (GitHub verhindert
   Kettenauslösung durch das eigene Token). Das ist dokumentiert und kein
   Verlust: Der Nachweisstand ist durch den Push des Merges bereits
   übertragen.
3. **Startversion `v0.1.0`** statt `v0.0.1`, wenn noch kein Versionsschild
   existiert — der erste Meilenstein ist mehr als ein Patch.
4. Kein Produktionscode entstanden; die Einheit umfasst ausschliesslich
   Arbeitsabläufe, Regeln und Dokumentation.
