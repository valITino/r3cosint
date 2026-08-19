# R3cOSINT

KI-gestützte OSINT-Ermittlungsplattform. Ein eigener Verbindungsserver zu den
Ermittlungsquellen, mit lückenloser Nachvollziehbarkeit und automatischer
Beziehungsdarstellung.

Dieses Repository enthält das **Produkt**. Die methodische Begleitung liegt in
[r3coscrum](https://github.com/valITino/r3coscrum).

## Status

Studienprojekt mit realem Bezug zur Kantonspolizei Bern. In Entwicklung.
Noch kein Produktivbetrieb — die Voraussetzungen dafür stehen im Projektauftrag,
Abschnitt 5.16.

## Aufbau

| Pfad | Inhalt |
|---|---|
| `docs/00_Projektauftrag.md` | Bindende Vorgabe. Erste Anlaufstelle für alles |
| `docs/01_Konzept_v1.0.pdf` | Fachkonzept der Ermittlungsgruppe vom 13.08.2026 |
| `docs/adr/` | Architekturentscheide |
| `prototype/` | Interaktive Demo. Getrennt vom Produktionscode |
| `.claude/` | Rollen, Regeln, Skills und Hooks für Claude Code |

## Arbeitsweise

Die Umsetzung übernimmt weitgehend Claude Code, gesteuert über `CLAUDE.md` und
die Rollen unter `.claude/agents/`. Die Reihenfolge der Lieferungen und die
Freigabe-Gates stehen im Projektauftrag, Abschnitt 2.

Ein Backlog-Eintrag je Sitzung. Die Definition of Done wird über einen Hook
erzwungen, nicht über eine Bitte.

## Harte Regeln

- **Keine echten Fall- oder Personendaten** ausserhalb der Produktionsumgebung.
  Das gilt auch für die Entwicklung. Getestet wird mit synthetischen Daten.
- **Kein Import aus `prototype/`** in Produktionscode. Ein Hook blockiert das.
- **Kein direktes Schreiben auf `main`.** Änderungen laufen über Pull Requests.
- **Keine Zugangsdaten im Repository.** Secrets gehören in die
  Repository-Einstellungen.

## Verweise

Verweise auf Dateien dieses Repositories werden mit vollständiger
Commit-Prüfsumme gesetzt, nie auf `main`. Begründung im Projektauftrag,
Abschnitt 6.6.
