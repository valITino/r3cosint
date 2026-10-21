# Übergabe 2026-10-21 — Abschnitt C: Abnahme von Posten 1 eingetragen, Posten 4 und 5 unter R3-Q-010 gebaut, Register angelegt

Sitzung vom 2026-10-21 (Fortsetzung der Sitzung vom 2026-10-14/15), Zweig ccr-0cbb4387-oe1i3c in beiden Repositories, neu gesetzt auf die Merge-Commits `5ada002023c0ff160c26c78659727c7e8623c6f5` (r3cosint, #26) und `44d6c5b5dbc4428d53708e8cfd20d7154e895e9d` (r3coscrum, #16). Weisung vom 2026-10-21 (zweiter Formweg, Wortlaut in ADR 0002, 6.13, Status-Block): Entscheide an den Koordinator delegiert.

## Fertig
- **C1** (Commit `0c8f149f235afffa1f85df21352d9fa09d283a5e`): Abnahme von Posten 1 (Merge #26, 2026-10-16) in ADR 0002, Abschnitt 10 eingetragen; Merge #16 vermerkt; Weisung vom 2026-10-21 im Wortlaut und fünf delegierte Entscheide in ADR 0002, 6.13 (Status-Block) und Abschnitt 9, Backlog (R3-Q-010, Punkt 24), CLAUDE.md. Statische Prüfung auf dem anderen model-Feld (Workflow, drei Bereiche), blockierende Befunde behoben, nachrangige als Restpunkte (unten).
- **C2** (Commit dieser Übergabe; Prüfsumme im Pull Request und in `docs/NACHWEISE.md`): Posten 5 (beide Gates) und Posten 4 a bis c (main-Gate) gebaut und verifiziert; Schwachstellenregister `docs/11_Schwachstellenregister.md` angelegt (SR-001 bis SR-004). Prüfmittel 447 Fälle, 49 Mutationen, 36 Fallklassen, beide Modi Rückgabewert 0; make dod in erwarteter Form (D7, D10, D12 Lage C; D11, D20 A_OK; D19 OHNE_BEFUND). Verifikation: Erstprüfung und vier Delta-Runden, je Static und Dynamic Software Tester auf dem anderen model-Feld; blockierende Befunde je Runde: DT-C2-02 (4 b), DT-C2-E-01 (4 c), ST-C2-F-01 (4 c) — alle behoben; Zählung nach 3.4 am Kriterium 4 c: zwei Scheitern, Delta 4 bestanden.
- Einordnungen des Software Architects (Vorbehalt 6.13 c): PIPESTATUS-Form für Posten 5; Preise in sicherer Richtung KM-14 (A89, A90), KM-17 (A102, A103, A139 bis A142, ...); Grenzen GM-5, GM-7 (erweitert), GM-9 (verallgemeinert); Zeitgrenze des Hooks bis Posten 7 von 6.13 d ausgenommen.

## Neu erfasst, nicht gebaut
- **Posten 6** (Prototyp-Gate: sed-/tr-Schritte ohne Rückgabewert-Prüfung; L23, L24): terminiert mit der nächsten Änderung am Prototyp-Gate (Posten 2, C3); SR-004 ohne Wert (Bewertung mit dem Bau).
- **Posten 7** (beide Gates ohne eigene Zeitgrenze im Skript; gemessen: `&`-Zeile 8 MB 14,22 s, 10 MB 19,82 s am main-Gate): terminiert mit der nächsten Änderung am jeweiligen Gate, spätestens vor der Freigabe des Grundgerüsts; SR-003 (CVSS 4.7).
- DT-C2-01 (quadratische Fortsetzungs-Schleife seit Posten 1, auf main seit Merge #26): in C2 behoben (lineare Form), im Register SR-002 (CVSS 5.5).

## Nicht begonnen (3.3)
- C3 (Posten 2 mit Posten 6), C4 (Posten 3), O-29, Freigabe des Grundgerüsts. Nächste Sitzung: C3.

## Offene Entscheide des Auftraggebers
- Abnahme von Posten 4 und 5 durch Merge des Pull Requests dieser Sitzung (Text: "Merge = Abnahme von Posten 4 und 5 unter R3-Q-010 ..."); nicht umfasst: Posten 2, 3, 6, 7; `R3-Q-011_regel_im_startkontext`; Terminierung von `Skill`; Berichtigung "6.1.2".
- Bestätigung der unter der Delegation getroffenen Einordnungen (Posten 6, 7; Reihenfolge).

## Restbefunde (nachrangig, nicht behoben)
- C1: C1-PM-PO-CLAUDE-03 (Stand-Zelle ohne Erteilungsdatum/Merge-Commit), -04 (Tabellenform Abschnitt 10); C1-SA-01 bis -04 behoben; C1-DELTA-REG-01 bis -04 behoben.
- C2, Gates (ohne weitere Änderung in dieser Einheit, Koordinator-Entscheid nach dem Muster aus 3.4): DT-C2-G-01 (Umleitungsoperator mit `&` vor dem Pfad, etwa `2>&1 ../main`, trennt den Abschnitt; die Basename-Form greift nicht; vorbestehend seit dem ersten Bau von 4 c; Fall mit Soll 0 mit der nächsten Änderung am main-Gate); ST-C2-G-03 (leeres Umleitungsziel in Anführungszeichen sperrt in sicherer Richtung, nicht als Preis benannt); ST-C2-G-01/G-02 (zwei Kommentarungenauigkeiten im main-Gate); benannte Grenzen ohne Sperre G105, G106, G110 bis G112; Wirkung im laufenden Harness ungemessen (die Hooks wirken in dieser Sitzung nicht); `dod-gate.sh` trägt dieselbe Bauform nur in sicherer Richtung (Lesebefund); DT-C2-G-02 betraf nur ein Skript des Dynamic Software Testers.
- Textprüfung C2 (eine Runde, reduzierte Prüftiefe; Einzeiler danach behoben, keine weitere Runde): Register C2-TEXT-REG-PO-KOORD-04 bis -06 (zwei Messwerte und die Quellangabe "C1-REG-07" ohne Fundort im ADR; Quellen sind die Berichte des Dynamic Software Testers und des Engineers und die Textrunde zu C1), -08/-09 (Register und Übergabe vor dem Commit erfasst); ADR C2-TEXT-SA-01 bis -03 und -06 bis -08 (Werte ohne Fundort im Text, Zuordnung der Preise A139 bis A142 und A149, Zitat der Zeitgrenze, zwei Restpunkte ohne Fundort, Form); Backlog -11/-12 behoben.

## Modellbeleg
Prüfrollen auf dem anderen model-Feld als die umsetzende Rolle; Beleg ausschliesslich über die Harness-Protokoll-Metadaten (keine Modellnamen in Repository-Dateien).

## Lehren
- Basename-Form ohne Tokenisierung: jede Erweiterung des Operandenmusters verschob, was verschluckt wird (drei Runden); Grenze benannt statt weiter erweitert.
- Prüfmittel: Zeitgrenze je Gate-Aufruf (14 s) und Vorab-Prüfung der Suchtexte vor Lauf C sparen Läufe.
