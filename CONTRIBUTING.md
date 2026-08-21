# Mitwirken an R3cOSINT

Dieses Repository ist **öffentlich**. Es entsteht als Studienprojekt der FFHS
und wird für den echten Einsatz bei der Kantonspolizei Bern gebaut. Verbindliche
Grundlage jeder Arbeit ist `docs/00_Projektauftrag.md`; die Arbeitsweise mit
Claude Code steht in `CLAUDE.md`.

## Zweige und Pull Requests

- **Kein direkter Push auf `main`.** Jede Änderung — auch die kleinste — läuft
  über einen Pull Request von einem Arbeitszweig.
- **Externe Mitwirkende arbeiten aus einem Fork** und eröffnen den Pull Request
  von dort.
- **Kein Force Push, keine Historienänderung auf gemeinsamen Zweigen.**
  Gemeinsam ist ein Zweig, sobald andere auf ihm aufbauen können — `main` und
  jeder Zweig mit offenem Pull Request. Korrekturen kommen als neuer Commit,
  nicht als umgeschriebene Historie.
- **Der Merge erfolgt ausschliesslich durch den Repository-Eigentümer**
  (@valITino). Ein genehmigter Pull Request wird nicht selbst gemergt.
- Die Prüfliste der Pull-Request-Vorlage
  (`.github/pull_request_template.md`) wird vollständig ausgefüllt.

## Commits

- Commit-Betreff nach [Conventional Commits](https://www.conventionalcommits.org/de/v1.0.0/),
  z. B. `fix: …`, `docs: …`, `feat: …`. Aus den Betreffzeilen wird bei
  Meilensteinen die Version abgeleitet
  (`.claude/rules/versionierung-und-nachweisfluss.md`).
- Bei Arbeit an einem Backlog-Eintrag steht dessen Kennung im Betreff, z. B.
  `feat(R3-F-001): …`; dieselbe Kennung steht im Testnamen (Projektauftrag 6.6).
- Eine Arbeitseinheit gilt erst als fertig, wenn sie die **Definition of Done**
  erfüllt: `docs/06_Definition_of_Ready_und_Done.md`. Halbfertige Zustände
  werden nicht committet.

## Keine echten Fall- oder Personendaten

Das Repository ist öffentlich. Echte Fall- oder Personendaten haben hier nichts
verloren — **in keinem Commit**, keinem Issue, keinem Pull-Request-Text und
keinem Anhang. Entwickelt und getestet wird ausschliesslich mit synthetischen
Daten (Projektauftrag 5.15).

Wer versehentlich echte Daten gepusht hat, meldet das sofort dem
Repository-Eigentümer. Das Entfernen aus der Historie ist dann allein dessen
Sache — die einzige zulässige Ausnahme vom Verbot der Historienänderung.

## Sprache

Deutsch, Schweizer Schreibweise: `ss` statt `ß`.
