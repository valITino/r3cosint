# Übergabe — Arbeitseinheit «TheHive und Cortex gestrichen, O-4 entfällt»

| | |
|---|---|
| **Arbeitsprodukt nach** | Projektauftrag 3.3 (Übergabedatei je Arbeitseinheit) |
| **Einheit** | Einheit 1 dieser Session: Neufassung Projektauftrag 5.17 übernommen, O-4 gestrichen, Erwähnungen konsistent nachgeführt |
| **Weisung** | Auftraggeber, 2026-08-21: aktualisierte Fassung des Projektauftrags übernehmen, O-4 ersatzlos streichen mit Vermerk, Erwähnungen prüfen und entfernen, Änderungsprotokoll nachführen |
| **Datum** | 2026-08-21 |
| **Zweig** | `claude/zustandsbericht-a55ga2` |

## Was fertig ist

- `docs/00_Projektauftrag.md` durch die vom Auftraggeber angehängte Fassung
  ersetzt. Vor der Übernahme gegen den bisherigen Stand verglichen; die neue
  Fassung unterscheidet sich an genau zwei Stellen: Neufassung von 5.17
  (TheHive und Cortex gestrichen, mit Begründung — Fehlübertragung aus dem
  Konzept, Überschneidung mit der eigenen Fallverwaltung, Kontrollverlust
  über Abfragen nach aussen) und eine neue Zeile im Änderungsprotokoll
  (Abschnitt 8). Das Änderungsprotokoll ist damit nachgeführt; ein weiteres
  Änderungsprotokoll existiert nicht (`CHANGELOG.md` entsteht erst mit dem
  Grundgerüst).
- O-4 gestrichen, mit Vermerk statt spurloser Entfernung:
  - `docs/adr/0002-architekturentscheid-ziel-stack.md` als **Fortschreibung**
    (Regel `dokumentation.md`): Fortschreibungszeile im Kopf, O-4-Zeile in
    Abschnitt 8 auf «entfallen» mit Begründung, Nachführungszeile in
    Abschnitt 9 angepasst (O-1-Teil bleibt), TheHive/Cortex in die Liste
    «nicht offen, weil gestrichen» aufgenommen.
  - `docs/04_Kontextmodell.md`: Zeile TheHive/Cortex in 3.2 auf
    «keine — gestrichen» mit Begründung; offener Punkt 2 in Abschnitt 6 auf
    «entfallen» mit Verweis auf das Änderungsprotokoll.

- Gegenprüfung durch den Static Software Tester (anderes Modell als die
  Umsetzung, 3.4): zwei geringe Befunde — falscher Abschnittsverweis in der
  Fortschreibungszeile (Abschnitt 2 statt 3.1) und eine nicht nachgeführte
  Statuszeile in ADR Abschnitt 9 «Aufgelöst mit der Freigabe» — beide vor
  dem Commit behoben; alle übrigen Kriterien ohne Beanstandung.

## Fundstellenliste der Prüfung (docs/ und .claude/rules/)

Gesucht wurde repositoryweit, unabhängig von Gross-/Kleinschreibung, nach
`TheHive`, `Cortex` und `O-4`.

**Geändert (lebende Dokumente):**

| Fundstelle | Behandlung |
|---|---|
| `docs/00_Projektauftrag.md` 5.17 | Durch Neufassung des Auftraggebers ersetzt |
| `docs/04_Kontextmodell.md` 3.2 (Systemtabelle) und Abschnitt 6 (offener Punkt 2) | Auf gestrichen/entfallen gesetzt, mit Begründung |
| `docs/adr/0002-architekturentscheid-ziel-stack.md` Kopf, Abschnitt 8 (O-4), Abschnitt 9 (Nachführungsliste) | Fortgeschrieben, siehe oben |

**Gefunden, absichtlich unverändert (historische Aufzeichnungen — sie
protokollieren einen damaligen Stand; sie nachträglich zu ändern würde die
Nachvollziehbarkeit beschädigen, 5.3 sinngemäss):**

| Fundstelle | Art |
|---|---|
| `docs/adr/0002-…` Abschnitt 3.1 (Optionenvergleich der Sprachwahl, nennt TheHive/Cortex als damals bestehende Anbindungen) | Damalige Entscheidungsgrundlage; die Fortschreibungszeile im Kopf stellt den heutigen Stand klar. Die Statuszeile in Abschnitt 9 «Aufgelöst mit der Freigabe» erhielt auf Befund der Gegenprüfung zusätzlich einen Fortschreibungsvermerk |
| `docs/08_Freigabe_Schritt_4.md` (eine Erwähnung) | Freigabeprotokoll vom 2026-08-20 |
| `docs/uebergaben/2026-08-20_r3-c-001-adr-entwurf.md`, `docs/uebergaben/2026-08-20_r3-c-001-freigabe-und-nachfuehrung.md` | Übergabedateien früherer Einheiten |
| `docs/09_Zustandsbericht_2026-08-21.md` | Zustandsbericht, Momentaufnahme vor dieser Einheit |

**Keine Treffer:** `.claude/rules/` (alle fünf Regeldateien), `CLAUDE.md`,
`docs/05_Product_Backlog.md`, alle übrigen Dateien.

## Was offen ist

- **Ein Backlog-Eintrag O-4 existierte nie.** O-4 war der offene Punkt in
  ADR 0002, der das *Anlegen* eines Backlog-Eintrags terminierte; der
  Eintrag selbst wurde bewusst nie angelegt. Gestrichen wurde deshalb der
  offene Punkt samt geplantem Eintrag; im Product Backlog selbst gab es
  nichts zu streichen. Der Entfall-Vermerk steht dort, wo O-4 geführt wurde
  (ADR 0002, Kontextmodell).
- **Vorschlag an den Auftraggeber, nicht umgesetzt:** Die Liste «Nicht
  bauen — gestrichen» in `CLAUDE.md` könnte TheHive/Cortex (5.17)
  aufnehmen. CLAUDE.md lag ausserhalb des benannten Prüfumfangs
  (docs/ und .claude/rules/) und wurde nach 3.1 nicht eigenmächtig geändert.

## Welche Entscheidungen getroffen wurden

1. Historische Aufzeichnungen (Freigabeprotokoll, Übergabedateien,
   Zustandsbericht, damaliger Optionenvergleich im ADR) bleiben unverändert;
   der heutige Stand wird über Fortschreibung und Vermerke hergestellt, nicht
   durch Umschreiben der Historie.
2. ADR 0002 wurde fortgeschrieben statt stillschweigend überholt
   (Regel `dokumentation.md`).
