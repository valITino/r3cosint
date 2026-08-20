# Übergabe — Arbeitseinheit «R3-C-001: Freigabe vermerkt und nachgeführt»

| | |
|---|---|
| **Arbeitsprodukt nach** | Projektauftrag 3.3 (Übergabedatei je Arbeitseinheit) |
| **Einheit** | Abschluss von R3-C-001: Freigabevermerk in ADR 0002 und Nachführungen aus dessen Abschnitt 9 |
| **Weisung** | Auftraggeber, 2026-08-20: «Freigegeben, O-1 bestätigt» |
| **Datum** | 2026-08-20 |
| **Zweig** | `claude/freigabe-gate-1u25xi` |

## Was fertig ist

- ADR 0002: Status «angenommen», Freigabevermerk in Abschnitt 10 ausgefüllt
  (freigegeben ohne Auflagen; O-1 bestätigt — Rahmenwerk jetzt, konkrete
  Komponentenbibliothek nach dem Prototyp-Review als O-2). Freigabe-Commit
  `4a0404839af65f45e29a8b18e795fa9e070e8643`. Damit ist die Abnahme von
  R3-C-001 erfüllt.
- Nachführungen aus ADR Abschnitt 9:
  - `docs/04_Kontextmodell.md` (Software Architect): offene Punkte 1 und 3
    entschieden, Punkt 2 als O-4 neu terminiert; Suchindex, Netzlayout und
    Stapeltrennung an den bestehenden Stellen ergänzt, Diagramm unverändert.
  - `docs/06_Definition_of_Ready_und_Done.md`: verweist für die konkreten
    Befehle auf ADR 0002 Abschnitt 6 (eine Wahrheit statt Kopie); offener
    Punkt 3 entsprechend umformuliert.
  - `docs/05_Product_Backlog.md`: Achtung-Vermerk bei R3-C-001 (erfüllt,
    O-1 bestätigt); Zählungen unverändert (76 Einträge, 323 h).
  - CLAUDE.md: Schritt 5 «läuft — R3-C-001 abgenommen, nächste Einheit
    Grundgerüst»; ADR 0002 in «Wo steht was».
- Gegenprüfung durch den Static Software Tester (anderes Modell als die
  Umsetzung, 3.4): **bestanden**; ein geringer Befund — docs/06 nannte für
  die Bestätigung der Befehlskette nur den DevOps Engineer statt DevOps und
  Auftraggeber wie in der Quelle — vor dem Commit behoben.
- `docs/NACHWEISE.md` nach den Commits neu erzeugt und zusammen mit dieser
  Übergabedatei committet (22 Artefakte).

## Was offen ist

- **Nächste Umsetzungseinheit: Grundgerüst** nach ADR 0002 Abschnitt 5
  (Backend Engineer und DevOps Engineer) — lauffähiger, fachlogikfreier
  Stand mit Makefile-Einstieg; danach R3-Q-001 und die übrigen
  Etappe-0-Einträge.
- **O-4:** Der Backlog-Eintrag zu TheHive/Cortex braucht zuerst eine
  fachliche Angabe des Auftraggebers (was soll mit den beiden Systemen
  geschehen); ohne sie wäre jedes Abnahmekriterium erfunden. Termin: vor
  Etappe 2 (Product Owner).
- Technische Bestätigung der DoD-Befehlskette samt der Befunde zu D10 und
  D12 durch DevOps Engineer und Auftraggeber, mit R3-Q-001; Schwellenwerte
  E-07/E-08.
- Der Arbeitszweig ist nicht nach `main` gemergt; der Merge läuft über
  einen Pull Request des Auftraggebers. CHANGELOG.md entsteht mit dem
  Grundgerüst (DevOps Engineer).

## Welche Entscheidungen getroffen wurden

1. Die pauschale Weisung «Freigegeben, O-1 bestätigt» wurde als Entscheid
   ohne Auflagen protokolliert; Namen bleiben nach dem offenen Entscheid
   E-11 draussen, die Zuordnung läuft über S-01.
2. `docs/06` verweist auf die Befehlstabelle im ADR, statt sie zu kopieren —
   zwei Quellen derselben Wahrheit liefen auseinander (Grundsatz aus 6.6).
3. Der TheHive/Cortex-Eintrag wurde bewusst **nicht** angelegt: Die
   Einbindungstiefe ist eine fachliche Frage an den Auftraggeber; ein
   Eintrag ohne diese Angabe würde Anforderungen erfinden (ADR 0002, O-4).
4. Modelltrennung nach 3.4 wie in den Vorprüfungen dieser Session: Die
   Gegenprüfung lief auf `sonnet`, weil die Umsetzung (Software Architect)
   auf `opus` lief; einmalige, prüfungsbezogene Abweichung von der
   Rollendatei des Testers.
