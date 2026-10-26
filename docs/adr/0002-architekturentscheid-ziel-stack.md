# ADR 0002 — Architekturentscheid und Ziel-Stack

| | |
|---|---|
| **Titel** | Ziel-Stack, Modulschnitt, Datenzugriff und Grundgerüst für R3cOSINT |
| **Status** | **angenommen** — Freigabe des Auftraggebers am 2026-08-20, Abschnitt 10 |
| **Fortschreibung** | Tabelle "Fortschreibungen" unten; Wortlaut der bisherigen Zeile bis zum Schnitt beim Commit `ac6e0c17672ad9f0d139a59dba8ca319f46056c4` |
| **Datum** | 2026-08-20 |
| **Kennung** | R3-C-001 |
| **Grundlage** | Projektauftrag 3.1, 3.4, 5.1 bis 5.18, 9.1; `docs/05_Product_Backlog.md` (Etappen 0 und 1); `docs/06_Definition_of_Ready_und_Done.md`; `docs/04_Kontextmodell.md`; `docs/adr/0001-rollenmodell.md` |
| **Lieferschritt** | Schritt 5 nach Abschnitt 2, erste Umsetzungseinheit; Freigabe-Gate Schritt 4 erteilt am 2026-08-20 (`docs/08_Freigabe_Schritt_4.md`, Abschnitt 6) |
| **Verfasst durch** | Software Architect (4.3) |

**Betroffene Dateien.** Dieser ADR legt an: `docs/adr/0002-architekturentscheid-ziel-stack.md` — sonst nichts. Er **beschreibt** ein Verzeichnislayout, er legt es nicht an. Welche Dateien nach der Freigabe nachzuführen sind, steht in Abschnitt 9.

**Was dieser ADR ist.** Der Architekturentscheid und das Grundgerüst nach 3.1: das Arbeitsergebnis, das vor der ersten Zeile Fachlogik vorliegt und freigegeben wird. Solange er nicht freigegeben ist, ist der Test `R3-C-001_adr_vorhanden` rot und damit jeder Test aus Etappe 1.

**Was dieser ADR nicht ist.** Kein Code, kein Grundgerüst auf Platte, keine Fachlogik. Die Umsetzung liegt bei Backend, Frontend und Full-Stack Engineer, die Verifikation beim Static und Dynamic Software Tester (3.4).

---

## Fortschreibungen

Die bisherige Kopfzeile "Fortschreibung", Abschnitt 9 und der nach ADR 0003, ADR 0004 und ADR 0005 verschobene Text von 6.12, 6.13 und 6.14 stehen im Wortlaut bis zum Schnitt in `docs/adr/0002-architekturentscheid-ziel-stack.md` beim Commit `ac6e0c17672ad9f0d139a59dba8ca319f46056c4`; die Tabelle führt je Eintrag jener Kopfzeile eine Zeile, in deren Reihenfolge, danach jede weitere Fortschreibung, und bei einem Widerspruch gilt der Wortlaut beim genannten Commit.

| Datum | Abschnitte | Gegenstand (kurz) | Fundort heute |
|---|---|---|---|
| 2026-08-21 | 8 (O-4), 9 | O-4 entfallen: TheHive und Cortex mit der Neufassung von Projektauftrag 5.17 gestrichen; der Optionenvergleich in 3.1 bleibt als damalige Entscheidungsgrundlage | ADR 0002, Abschnitt 8 (O-4) und Abschnitt 9 |
| 2026-08-30 | 6, 6.1; berührt 1.3 (K5), 3.5, 3.12, 8 (O-8, neu O-10), 9 | Abschnitt 6 in drei Punkten: D11 prüft Arbeitsbaum und Git-Historie; neuer Kettenschritt D18 für die Architekturverträge; Kettengrundsatz "ein Prüflauf verändert den Gegenstand nicht, über den er urteilt" samt Folge für D12 | ADR 0002, 6.1 |
| 2026-08-30 | 6, 6.2; berührt 1.3 (K5), 3.11, 8 (O-10 neu gefasst), 9 | Zweite Fortschreibung desselben Tages: keine Sperrdatei mehr (--locked statt --frozen), Rahmenprüfung D19, Objektbestimmung aller Kettenschritte in einer eigenen Tabelle, Prüffläche des Arbeitsbaumlaufs aus D11 | ADR 0002, 6.2 |
| 2026-08-30 | 6, 6.3; berührt 8 (O-11 neu), 9 | Dritte Fortschreibung desselben Tages: vier Abweichungen zwischen ADR und Makefile — --project backend an jedem uv-Aufruf, D7 ohne Lage B, git als Prüfmittel des Historienlaufs in D11, Abgleich der Wurzelpakete für D18 als O-11 terminiert | ADR 0002, 6.3 |
| 2026-08-30 | 6, 6.4 | Vierte Fortschreibung desselben Tages: D19 misst den Inhalt des Arbeitsbaums statt nur der Statusliste | ADR 0002, 6.4 |
| 2026-08-31 | 6, 6.5; O-12 | Fünfte Fortschreibung: Reichweite der Kette entschieden; die harte Zusicherung liegt in einem Lauf auf der Gegenseite, terminiert als O-12 | ADR 0002, 6.5 |
| 2026-08-31 | 6, 6.6; berührt 8 (O-13 neu) | Sechste Fortschreibung desselben Tages: Positivliste um $(UV) ohne UV_CACHE_DIR, XDG_CACHE_HOME und TMPDIR; Projektbestimmung ohne Rückfall auf das Arbeitsverzeichnis | ADR 0002, 6.6 |
| 2026-08-31 | 6, 6.7; berührt 8 (O-13 entschieden) | Siebte Fortschreibung desselben Tages: O-13 vom Auftraggeber entschieden, die Kette benutzt den Zwischenspeicher von uv nicht (UV_NO_CACHE=1) | ADR 0002, 6.7 |
| 2026-09-01 | 6, 6.8; berührt 1.3 (K5), 8 (O-14 und O-15 neu), 9 | Achte Fortschreibung: Belegprüfer `scripts/belege-pruefen.sh` als Kettenschritt D20, als erster Schritt vor D1, ohne Lage B; was ein grüner Lauf aussagt | ADR 0002, 6.8 |
| 2026-09-01 | 6, 6.9; berührt 8 (O-16 neu), 9 | Neunte Fortschreibung: Beobachtbarkeit des Index als Teil des Prüfmittels von D19; Lage C allgemein geschärft; Gegenstand relativ, Instrument absolut | ADR 0002, 6.9 |
| 2026-09-01 | 6, 6.10; berührt 8 (O-16 beantwortet, O-17 neu), 9 | Zehnte Fortschreibung desselben Tages: O-16 mit einem Lauf beantwortet, eine Hälfte des D19-Instruments stumm; eine Begründungszeile berichtigt; Löschung einer maskierten Datei als O-17 benannt | ADR 0002, 6.10 |
| 2026-09-01 | 6, 6.11; berührt 8 (O-10 überholt, O-18 neu), 9 | Elfte Fortschreibung, in der Kopfzeile am 2026-09-02 nachgetragen (6.12.18): ein blockierender und fünf nachrangige Befunde behoben; dritter Rückgabewert (3 = Lage C) im Belegprüfer; die sechs Prüfmittel von D20 vor jeder Verwendung geprüft | ADR 0002, 6.11 |
| 2026-09-02 | 6 (Objekttabelle, D20), 6.12 mit 6.12.1 bis 6.12.24; berührt 8 (O-19 bis O-24 neu; O-8, O-10, O-15 und O-18 fortgeschrieben), 9 | Zwölfte Fortschreibung: Entwurf des DoD-Gates aus R3-Q-001 (Stop, SubagentStop, TaskCompleted), vorgelegt, Bau auf Weisung vom selben Tag begonnen; Runde 1 der Prüfung, Nachträge aus Bau (6.12.23) und Verifikation (6.12.24); dritte Prüfrunde vom 2026-09-03, Abbruch nach 3.4, O-24 vorgelegt | ADR 0003, Teil B, 6.12 bis 6.12.24; Vorlage und Weisung in ADR 0002, Abschnitt 10, "Vorlage der zwölften Fortschreibung (Abschnitt 6.12) und Weisung vom 2026-09-02" |
| 2026-09-03 | 6.12.1, 6.12.19, 6.12.24 f, 6.12.25; berührt 8 (O-24, neu O-25), 9 | Dreizehnte Fortschreibung auf Entscheid zu O-24: Prüftabelle von G17 in Zusicherungen mit dauerhaften Kennungen zerlegt, mechanische Deckung in beide Richtungen; Nachtrag nach der vierten Prüfrunde (Messumfang je Zusicherung, Z-001 bis Z-153); Nachtrag nach der fünften Prüfrunde: Abbruch nach 3.4, O-25 vorgelegt | ADR 0003, Teil B, 6.12.25 |
| 2026-09-03 | 6.12.1, 6.12.9, 6.12.11, 6.12.19, 6.12.26; berührt 8 (O-25), 9 | Vierzehnte Fortschreibung auf Entscheid zu O-25: Spalten Kanal und Mutation in der Tabelle 6.12.19, `scripts/dod-gate-mutationen.txt` mit Modus --mutationen; die Befunde der fünften Runde als Entscheide | ADR 0003, Teil B, 6.12.26 |
| 2026-09-03 | 6.12.26 f; 8, 9 | Fünfzehnte Fortschreibung: Nachträge aus der siebten Prüfrunde (Z-124, Z-132 und Z-133 präzisiert; neu Z-154 und Z-155; typisierte Messhüllen verbindlich; Sperre unter /tmp bestätigt) | ADR 0003, Teil B, 6.12.26 f |
| 2026-09-04 | 6.12.26 f, Punkt 13 | ohne Nummer: Berichtigungen aus Bau 4 (Z-114 bleibt bei rc; Mutation von Z-130 auf das Makefile verlegt; 156 Messhüllen, neun Zeilen mit "keine") | ADR 0003, Teil B, 6.12.26 f, Punkt 13 |
| 2026-09-04 | 6.12.26 g; O-26 | Sechzehnte Fortschreibung: achte Prüfrunde, Abbruch nach 3.4, O-26 vorgelegt | ADR 0003, Teil B, 6.12.26 g |
| 2026-09-06 | 6.12.7, 6.12.19, 6.12.26 a, 6.12.27; berührt 8 (O-26), 9 | Siebzehnte Fortschreibung auf Entscheid zu O-26: Prädikatspalte, Schlüssel- und Grammatikdeckung, Z-040 berichtigt, Z-156 bis Z-184 neu, Abnahmekriterium mit einer Fremdmutationsrunde in vier Kategorien | ADR 0003, Teil B, 6.12.27 |
| 2026-09-06 | 6.12.7, 6.12.9, 6.12.15, 6.12.19, 6.12.27 i | Nachtrag i) desselben Tages nach der neunten Prüfrunde: Grammatikelement ENDE, Aussagendeckung (E01 bis E22, A01 bis A07), Z-185 bis Z-193; Runde 10 folgt | ADR 0003, Teil B, 6.12.27 i |
| 2026-09-06 | 6.12.7, 6.12.15, 6.12.19, 6.12.27 j | Nachtrag j) desselben Tages nach der zehnten Prüfrunde: Gegenstandsdeckung Schlüssel, Ausgabeform als Invariante (A08), Grammatikelement ANFANG mit Erzeugerseiten-Zeile, Z-194 bis Z-208; Runde 11 als dritter Versuch | ADR 0003, Teil B, 6.12.27 j |
| 2026-09-06 | 6.12.27 k; berührt 8 (O-27 neu) | Nachtrag k) desselben Tages nach der elften Prüfrunde: Teil 2 des Abnahmekriteriums zum dritten Mal nicht erfüllt, Abbruch nach 3.4, O-27 mit zwei Wegen vorgelegt | ADR 0003, Teil B, 6.12.27 k |
| 2026-09-07 | 6.12.27 k, Punkt 5 | ohne Nummer: O-27 entschieden, die Wahl an den Koordinator delegiert; beide Wege in einer Einheit, Teil 2 des Abnahmekriteriums neu gefasst, Runde 12 als letzte Fremdmutationsrunde | ADR 0003, Teil B, 6.12.27 k, Punkt 5 |
| 2026-09-07 | 6.12.4, 6.12.7, 6.12.9, 6.12.28; Abschnitt 10 | ohne Nummer: 6.12.28, O-27 ausgeformt (Pfaddeckung über 40 Ausgangsstellen, Grammatik am Gegenstand über 35 Schwächungen, Z-209 bis Z-261); förmliche Freigabe der Entscheidpunkte E-A bis E-K durch Merge, Merge-Commit `135e3614197a8150ad3d96fbf32eb0e893c9cbbc` | ADR 0003, Teil B, 6.12.28; ADR 0002, Abschnitt 10, "Förmliche Freigabe der Entscheidpunkte E-A bis E-K (2026-09-07)" |
| 2026-09-21 | Abschnitt 10, 9 | Neunzehnte Fortschreibung, Teil 1 von 2: Abnahme des DoD-Gates aus R3-Q-001, erteilt am 2026-09-08 durch Merge des Pull Requests #15 (Merge-Commit `9870b0d115b8ef330a7c19777af5741093e4f0e9`), ohne Auflagen | ADR 0002, Abschnitt 10, "Abnahme des DoD-Gates aus R3-Q-001 — erteilt am 2026-09-08, eingetragen am 2026-09-21" |
| 2026-09-21 | 6.13; O-28 | Neunzehnte Fortschreibung, Teil 2 von 2: E4 (R3-Q-010) festgelegt, nicht gebaut — beide PreToolUse-Gates, belegte Lücken, gemeinsames Prüfmittel mit Mutationsprobe, ST-11 als O-28 vertagt, Schnitt E4.1 bis E4.3 | ADR 0004, Teil B, 6.13 |
| 2026-09-22 | 6.13, Abschnitt 10 (E-E), 9 | Zwanzigste Fortschreibung: Umfang von R3-Q-010 freigegeben und Schnitt E4.1 bis E4.3 bestätigt (Weisung, zweiter Formweg); E-E, `.claude/hooks/session-start-gitleaks.sh` auf Weisung | ADR 0004, Teil B, 6.13; ADR 0002, Abschnitt 10, Unterabschnitt "Vorlage der zwölften Fortschreibung (Abschnitt 6.12) und Weisung vom 2026-09-02", Zeile E-E, Nachtrag vom 2026-09-22 |
| 2026-09-22 | Abschnitt 10 (E-F), 9 | Zwanzigste Fortschreibung, Teil 2: E-F, Nachholen der Git-Historie bei flachem Klon, `.claude/hooks/session-start-git-historie.sh`, auf Delegation | ADR 0002, Abschnitt 10, Unterabschnitt "Vorlage der zwölften Fortschreibung (Abschnitt 6.12) und Weisung vom 2026-09-02", Zeile E-F, Nachtrag vom 2026-09-22 |
| 2026-09-23 | 6.13, 9 | Einundzwanzigste Fortschreibung: E4.1 gebaut, Prüfmittel `scripts/pretooluse-gates-selbsttest.sh` mit 202 Fällen und zehn Mutationen; Präzisierung zu 6.13 d, Punkt 2 | ADR 0004, Teil B, 6.13 |
| 2026-09-23 | 6.13 | Einundzwanzigste Fortschreibung, Teil 2: E4.2 gebaut, ST-04, ST-05 und P-01 am Prototyp-Gate geschlossen, 225 Fälle | ADR 0004, Teil B, 6.13 |
| 2026-09-23 | 6.13 | Einundzwanzigste Fortschreibung, Teil 3: E4.3 gebaut, ST-09 und ST-13 geschlossen, Grenzen und P-10 benannt; die sieben Abnahmekriterien von R3-Q-010 gebaut und verifiziert | ADR 0004, Teil B, 6.13 |
| 2026-09-23 | Abschnitt 10; 6.13 (Status-Block, c), 9 | Zweiundzwanzigste Fortschreibung: Abnahme von R3-Q-010 durch Merge des Pull Requests #21 (Merge-Commit `9a84b9ccd1ecb81b19739f64defc5881e83e2db5`), ohne Auflagen; Prüfstand-Fälle ZF9, ZF10a bis ZF10d und L01 bis L16 entschieden, L01 bis L09 als drei Posten unter R3-Q-010 | ADR 0002, Abschnitt 10, Unterabschnitt zur Abnahme von R3-Q-010 (2026-09-23); ADR 0004, Teil B, 6.13, Status-Block und Buchstabe c |
| 2026-09-23 | 6.14; 8 (O-29), 9 | Dreiundzwanzigste Fortschreibung: E3 (R3-Q-011) festgelegt, nicht gebaut — Regel und Skill zur Einschleusungsprüfung, Kanäle, Prüfsatz, Rollenliste, Kontrollversuch zu SK-02, Versuch zur Ladung der Regel, Schnitt E3.1 bis E3.3 | ADR 0005, Teil B, 6.14 |
| 2026-09-24 | Abschnitt 10; 6.14 (Status-Block, g), 9 | Vierundzwanzigste Fortschreibung: Freigabe von E3 durch Merge des Pull Requests #23 (Merge-Commit `3e5caf71b2bca97b7f9764a19841025875974df7`), zugleich Bestätigung des Abnahmeeintrags zu R3-Q-010; Weisung vom 2026-09-24 | ADR 0002, Abschnitt 10, Unterabschnitt zur Freigabe von E3 (2026-09-24); ADR 0005, Teil B, 6.14, Status-Block und Buchstabe g, je Nachtrag vom 2026-09-24 |
| 2026-09-25 | Abschnitt 10; 6.14 (Status-Block, e), 9 | Fünfundzwanzigste Fortschreibung: Merges der Pull Requests #24 (Merge-Commit `0af86aa4e6485d6cdfe09829accfdb65a8a8c65a`) und #14 im Methodik-Repository (`ee56fea8572348799069ac0b866376764edf6694`) eingetragen; Regel verbindlich, Skill und Zuordnung angenommen | ADR 0002, Abschnitt 10, Unterabschnitt zu den Merges #24 und #14 (2026-09-25); ADR 0005, Teil B, 6.14, Status-Block und Buchstabe e, je Nachtrag vom 2026-09-25 |
| 2026-09-25 | 6.14 (Status-Block, d), 9 | Sechsundzwanzigste Fortschreibung: E3.3 gebaut — Versuch zur Regel ("gleich", Gegenprobe nicht durchgeführt), Kontrollversuch positiv (ADR 0001, Abschnitt 5.1, Commit `1f8865cc36701702f1bb61bc47e40cf948b51756`), Prüfsatz (Commit `818a17162bbbc51206138ddcecae907f5e4bb235`), Lauf und Abgleich bestanden | ADR 0005, Teil B, 6.14, Status-Block, Nachtrag vom 2026-09-25 "E3.3 gebaut", und Buchstabe d |
| 2026-10-14 | Abschnitt 10; 6.14 (Status-Block, e, g), 9 | Siebenundzwanzigste Fortschreibung: Abnahme von R3-Q-011 eingetragen, erteilt am 2026-09-25 durch Merge des Pull Requests #25 (Merge-Commit `0b6d59625423f53fcd0e8b3f22150d97ef2a17f4`; Methodik-Repository, Pull Request #15, `d349f3ce4bba8db8f919c188849acc452190ac44`), fünf der sechs Kriterien | ADR 0002, Abschnitt 10, Unterabschnitt zur Abnahme von R3-Q-011; ADR 0005, Teil B, 6.14, Status-Block, Buchstaben e und g, je Nachtrag vom 2026-10-14 |
| 2026-10-14 | 6.13 (Status-Block, c), 9 | Achtundzwanzigste Fortschreibung: Posten 1 unter R3-Q-010 gebaut und verifiziert (main-Gate, L01 bis L04 geschlossen, Grenzen GM-5 bis GM-8; Prüfmittel 318 Fälle, 26 Mutationen, 28 Fallklassen); Posten 4 und 5 erfasst | ADR 0004, Teil B, 6.13, Status-Block und Buchstabe c, je Nachtrag vom 2026-10-14 |
| 2026-10-21 | Abschnitt 10; 6.13 (Status-Block), 9 | Neunundzwanzigste Fortschreibung: Abnahme von Posten 1, erteilt am 2026-10-16 durch Merge des Pull Requests #26 (Merge-Commit `5ada002023c0ff160c26c78659727c7e8623c6f5`), zugleich Bestätigung des Eintrags zu R3-Q-011; Weisung vom 2026-10-21 und die an den Koordinator delegierten Entscheide | ADR 0002, Abschnitt 10, Unterabschnitt zur Abnahme von Posten 1; ADR 0004, Teil B, 6.13, Status-Block, Nachtrag vom 2026-10-21 zur Abnahme von Posten 1 |
| 2026-10-21 | 6.13 (Status-Block, c), 9 | Dreissigste Fortschreibung: Posten 4 und 5 gebaut und verifiziert (L17, L19, L20, L21 und L22 geschlossen; Prüfmittel 447 Fälle, 49 Mutationen, 36 Fallklassen), Register mit SR-001 bis SR-004 angelegt; Posten 6 und 7 erfasst | ADR 0004, Teil B, 6.13, Status-Block, Nachtrag vom 2026-10-21 zum Bau von Posten 4 und 5, und Buchstabe c, Nachtrag vom 2026-10-21 |
| 2026-10-21 | Abschnitt 10; 6.13 (Status-Block, c), 9 | Einunddreissigste Fortschreibung: Abnahme von Posten 4 und 5 durch Merge des Pull Requests #27 (Merge-Commit `998f81d9fffe3970baf870d04e44576eda534fcc`; Methodik-Repository, Pull Request #17, `f8cb47867fe09b80adb623a6c37fb6d800c49f1c`); Festlegung für C3 | ADR 0002, Abschnitt 10, Unterabschnitt zur Abnahme von Posten 4 und 5; ADR 0004, Teil B, 6.13, Status-Block und Buchstabe c, je Nachtrag vom 2026-10-21 zur Abnahme von Posten 4 und 5 |
| 2026-10-22 | 6.13 (Status-Block, c), 9 | Zweiunddreissigste Fortschreibung: C3 gebaut — Posten 2, Posten 6 und Teil von Posten 7 am Prototyp-Gate (L05 bis L08, L23 und L24 geschlossen; 479 Fälle, 66 Mutationen, 39 Fallklassen); Weisungen vom 2026-10-22; Posten 8 bis 10 erfasst | ADR 0004, Teil B, 6.13, Status-Block, Nachtrag vom 2026-10-22 — C3, und Buchstabe c, Nachtrag vom 2026-10-22 zum Bau von C3 |
| 2026-10-22 | Abschnitt 10; 6.13 (Status-Block), 9 | Dreiunddreissigste Fortschreibung (Eintrag des Protocol Masters dieser Sitzung): Abnahme von Posten 2, Posten 6 und des Teils von Posten 7 am Prototyp-Gate unter R3-Q-010 durch Merge des Pull Requests #28 (Merge-Commit `95cafc9cc31773a6c29d977ec9c3b97af5a1f047`); Annahme von PS-1 durch Merge des Pull Requests #29 (Merge-Commit `d7d539ebea07043201d58e36c8abafec54045848`); dazu die Bestätigung des Eintrags zu Posten 4 und 5 | ADR 0002, Abschnitt 10, Unterabschnitte "Abnahme von Posten 2, 6 und des Teils von Posten 7 am Prototyp-Gate unter R3-Q-010 — Prototyp-Gate L05 bis L08, L23, L24, eigene Zeitgrenze — erteilt am 2026-10-22, eingetragen am 2026-10-22" und "Annahme des Prozess-Schnitts PS-1 (Regeln) — Merge des Pull Requests #29 — erteilt am 2026-10-22, eingetragen am 2026-10-22", dazu im Unterabschnitt zur Abnahme von Posten 4 und 5 der Absatz "Bestätigung des Eintrags (Nachtrag vom 2026-10-22)"; ADR 0004, Teil B, 6.13, Status-Block, Nachtrag vom 2026-10-22 zur Abnahme von Posten 2, 6 und des Teils von Posten 7 am Prototyp-Gate |
| 2026-10-22 | 6.12, 6.13, 6.14, Kopfzeile "Fortschreibung", 9 | PS-2 (Prozess-Schnitt): 6.12 nach ADR 0003, 6.13 nach ADR 0004, 6.14 nach ADR 0005 verschoben, je unverändert als Teil B mit neuem Teil A; Weiterleitungen an den 31 Überschriften; Kopfzeile "Fortschreibung" durch diese Tabelle ersetzt; Abschnitt 9 abgeschlossen | ADR 0003, ADR 0004 und ADR 0005, je Teil A und Teil B; ADR 0002, Abschnitte "Fortschreibungen" und 9; Wortlaut bis zum Schnitt beim Commit `ac6e0c17672ad9f0d139a59dba8ca319f46056c4` |

---

## 1. Kontext

### 1.1 Ausgangslage

Es existiert kein Produktionscode und kein festgelegter Tech-Stack (Projektauftrag, Abschnitt 0). Vorhanden sind der Projektauftrag, das Konzeptdokument, die Planungsartefakte aus Schritt 3 und der Wegwerf-Prototyp `prototype/OSINT_Plattform_Demo.html` — eine eigenständige HTML-Datei mit sechs Ansichten, deren Bildschirmfluss, Benennungen und Interaktionsmuster nach 5.6 verbindlich sind und deren Code nach 5.6 nicht weiterverwendet wird.

Das ist ein Neuaufbau ohne Altlast. Die praktische Folge für R3-C-002: Es entsteht keine Umbenennungsschuld, wenn die Namensgebung von Anfang an `r3cosint` lautet — in Paketnamen, Datenbanknamen, Schemanamen, Umgebungsvariablen und Image-Namen. Die Festlegungen in Abschnitt 5 und 6 dieses ADR verwenden ausschliesslich diese Bezeichnung.

### 1.2 Was gesetzt ist und hier nicht neu entworfen wird

| Vorgabe | Fundstelle | Wirkung auf diesen ADR |
|---|---|---|
| Kernarchitektur mit vier Ebenen 0 bis 3 | 5.1 | Wird verortet, nicht verändert |
| MCP-Server als **einziger** Zugang zu den Quellen, Anbieterschlüssel ausschliesslich serverseitig | 5.1, 5.17, R3-F-013 | Bestimmt den Modulschnitt in Abschnitt 4 |
| Kanonischer Datenbestand nach FollowTheMoney, STIX 2.1, W3C PROV | 5.1, R3-F-003 bis R3-F-005 | Wesentliches Kriterium der Sprachwahl |
| Datenhaltung PostgreSQL | 5.1 | Gesetzt; offen war nur `pgvector` (5.18) |
| Darstellung über Mermaid und draw.io, Teilgraphen statt Gesamtbild | 5.1, R3-F-070, R3-F-071 | Erzeugung serverseitig, siehe A6 und Abschnitt 4 |
| Acht Verfahrensgarantien, im Betrieb nicht abschaltbar | 5.4 | Abschnitt 4 weist je Garantie den Ort der Verankerung nach |
| Freigabesperre als fehlende Fähigkeit, nicht als Einstellung | 5.2, R3-F-014 | Eigener Entscheid A5 und Modulvertrag in 4.3 |
| Zwei Protokollspuren, SHA-256-verkettet, ausschliesslich anfügbar | 5.3, R3-F-006 bis R3-F-012 | Bestimmt den Datenzugriff, Entscheid A2 |
| Modellunabhängigkeit, ausschliesslich OpenAI-kompatible Schnittstelle | 5.15, R3-F-018 | Entscheid A7 |
| Trennung Test/Schulung und Produktion ohne Verbindungsweg | 5.16, R3-C-003 | Entscheid A10 |
| Klassifizierung wirkt im Suchindex, nicht in der Oberfläche | 5.8, R3-F-054 | Entscheid A3 |
| Vollständiger Offline-Betrieb, kein Rückkanal | 5.17, R3-C-004, R3-F-021 | Entscheide A10 und A11 |
| Eigenständige Anwendung statt Open WebUI | 9.1 | Entscheid A8 |
| Nicht gebaut, auch nicht als Platzhalter: VirusTotal, Gesichtserkennung, Open WebUI, CASE/UCO, Fernsteuerung von Maltego | 5.17, 5.18, 9.1, 5.10, 5.1 | Kommt in keinem Modul, keiner Konfigurationsoption und keiner Abhängigkeit dieses ADR vor |

Der Verzicht auf die Fernsteuerung von Maltego wird respektiert und nicht erneut geprüft (5.1). Maltego bleibt das manuelle Analysewerkzeug daneben und erhält Daten ausschliesslich über Dateien (draw.io, Mermaid).

### 1.3 Entscheidungskriterien

Jeder Entscheid in Abschnitt 3 wird gegen dieselben acht Kriterien geprüft. Sie stammen aus dem Auftrag, nicht aus einer allgemeinen Technikvorliebe.

| Nr. | Kriterium | Herkunft |
|---|---|---|
| K1 | Trägt die drei kanonischen Standards ohne Eigenbau des Schemas | 5.1, R3-F-003 bis R3-F-005 |
| K2 | Erlaubt, die Verfahrensgarantien **strukturell** zu verankern statt als Prüfung im Aufrufer | 5.4 |
| K3 | Vollständig offline betreibbar, ohne Rückkanal, ohne Aktualisierungsabfrage | 5.17, R3-C-004, R3-F-021 |
| K4 | Reproduzierbar: feste Programmstände, gleiche Eingabe gleiche Ausgabe, ein Jahr später wiederholbar | 5.4, R3-Q-002 |
| K5 | Maschinell prüfbar über eine Befehlskette mit Rückgabewert 0 | 3.4, DoD-Befehlskette nach Abschnitt 6 (bis zur Fortschreibung vom 2026-08-30 hier als "D1 bis D12" bezeichnet; die Kette umfasst seither zusätzlich D18, seit der zweiten Fortschreibung desselben Tages zusätzlich die Rahmenprüfung D19; seit der achten Fortschreibung vom 2026-09-01 zusätzlich D20, den ersten Schritt der Kette) |
| K6 | Nachweisbar: Herkunft, Versionen und Modulstand sind bei jedem Export benennbar | 5.10, 6.6 |
| K7 | Betreibbar von einer kleinen Dienststelle: Setup vom Klonen bis zum Start, Fehlermeldung statt Stacktrace | 5.5, R3-F-019 |
| K8 | Übersteht einen Modell-, Anbieter- und Mandantenwechsel als Konfigurationsänderung | 5.7, 5.15 |

Nicht Kriterium: Verbreitung um ihrer selbst willen, Neuheit, Geschwindigkeit der Entwicklung.

---

## 2. Überblick über die Entscheide

| Nr. | Gegenstand | Entscheid | Abschnitt |
|---|---|---|---|
| A1 | Sprache und Rahmenwerk des Backends | Python, ASGI-Rahmenwerk mit erzeugter OpenAPI-Beschreibung | 3.1 |
| A2 | Datenzugriff, Migrationen, anfügbares Protokoll | Typisierte SQL-Zugriffsschicht mit Migrationswerkzeug; Anfügbarkeit in der Datenbank erzwungen, nicht in der Anwendung | 3.2 |
| A3 | Suchindex | In PostgreSQL, kein zweiter Suchdienst | 3.3 |
| A4 | `pgvector` | **Nicht Bestandteil des Aufbaus** | 3.4 |
| A5 | Freigabesperre | Zwei Module ohne Aufrufkante, einmal verwendbare Freigabe-Kennung, Prozessgrenze | 3.5 |
| A6 | Graphdarstellung | Mermaid und `.drawio` werden serverseitig erzeugt; keine Einbettung eines fremden Dienstes | 3.6 |
| A7 | Anbindung des Sprachmodells | Eigene schlanke Zwischenschicht auf der OpenAI-kompatiblen HTTP-Schnittstelle; das Modell erhält **keine** Werkzeugaufruf-Fähigkeit | 3.7 |
| A8 | Rahmenwerk der Oberfläche | Einzelseitenanwendung in TypeScript mit React und Vite; Komponentenbibliothek bleibt bis zur Prototyp-Freigabe offen | 3.8 |
| A9 | Schnittstellenstil | HTTP/JSON nach OpenAPI, Typen für die Oberfläche werden daraus erzeugt | 3.9 |
| A10 | Anmeldestack | OpenID Connect als einziger Anmeldeweg, Entwicklung gegen einen selbst betriebenen Provider | 3.10 |
| A11 | Container- und Umgebungslayout | Zwei getrennte Compose-Stapel; genau ein Container hat einen Weg nach aussen | 3.11 |
| A12 | Teststack | pytest und Vitest/Playwright, Architekturtests als eigene Prüfstufe | 3.12 |
| A13 | Sprache der Bezeichner | Fachbegriffe des Glossars als Bezeichner, technische Begriffe englisch | 3.13 |

**Zu Versionsnummern.** Dieser ADR nennt keine. Verbindlich ist jeweils die zum Zeitpunkt der Umsetzung aktuelle, vom Hersteller unterstützte Fassung; festgelegt wird sie in den Sperrdateien (`uv.lock`, `package-lock.json`) und den Image-Prüfsummen, nicht in diesem Dokument. Eine Versionsnummer in einem Architekturentscheid ist ein Jahr später falsch, ohne dass es jemand merkt.

---

## 3. Entscheidungen

### 3.1 A1 — Sprache und Rahmenwerk des Backends

**Optionen.**

| Option | Bewertung |
|---|---|
| **Python mit einem ASGI-Rahmenwerk** (FastAPI-artig, Pydantic für Schemata) | Die Referenzimplementierungen der drei kanonischen Standards liegen in Python: FollowTheMoney wird im selben Ökosystem gepflegt wie OpenSanctions und dessen Abfragedienst `yente`, für STIX 2.1 pflegt OASIS eine Python-Bibliothek, für MISP ist PyMISP die offizielle Anbindung, für TheHive und Cortex existieren Python-Anbindungen. Das Model Context Protocol hat ein offizielles Python-SDK. Nachteil: Laufzeitgeschwindigkeit und ein schwächeres Typsystem als eine kompilierte Sprache |
| **TypeScript auf Node** (NestJS oder Fastify) | Ein Sprachstack für Backend und Oberfläche, offizielles MCP-SDK vorhanden, gutes Typsystem. Aber: Für FollowTheMoney, STIX 2.1 und die bestehenden Anbindungen an MISP, TheHive, Cortex und OpenSanctions müssten Schema- und Anbindungsarbeit nachgebaut oder über Zwischenprozesse geholt werden. 5.17 verlangt ausdrücklich das Gegenteil: bestehende Bausteine werden übernommen, nicht nachgebaut |
| **Go** | Robuste Einzeldatei-Auslieferung, gut für den Offline-Betrieb, starke Nebenläufigkeit. Dasselbe Ökosystem-Problem wie TypeScript, verschärft: für keinen der drei Standards liegt eine getragene Referenzbibliothek vor |

**Entscheid.** Das Backend wird in **Python** gebaut, mit einem ASGI-Rahmenwerk, das aus typisierten Modellen eine OpenAPI-Beschreibung erzeugt (FastAPI-Familie), und mit Pydantic als Schemaschicht an der Systemgrenze.

**Begründung.** K1 entscheidet allein. Der kanonische Datenbestand ist nach 5.1 der eigentliche Kern des Systems; ein Stack, in dem dessen Schemata nachgebaut werden müssten, verlagert das Projektrisiko genau dorthin, wo es am teuersten ist. Dazu kommt K7: `yente` selbst ist eine Python-Anwendung, ebenso mehrere der selbst zu betreibenden Werkzeuge aus R3-F-036; eine Dienststelle betreibt lieber eine Laufzeitumgebung als drei. Der Nachteil beim Typsystem wird über D4 (Typprüfung, null Fehler) und über die Architekturverträge aus 4.3 aufgefangen — nicht über Disziplin.

**Bewusst nicht gewählt: ein Rahmenwerk mit eingebauter Benutzerverwaltung und eingebautem Verwaltungsbereich** (Django-Familie). Es brächte Rollenverwaltung, Migrationen und einen Verwaltungsbereich mit. Dagegen sprechen zwei Punkte, die aus dem Auftrag stammen: Das Berechtigungsmodell aus 5.8 wirkt im Suchindex und über zwei nebeneinander laufende Berechtigungswege (Klassifizierungsberechtigung und fallbezogene Freigabeliste) — ein mitgebrachtes Berechtigungsmodell müsste dafür ohnehin umgangen werden, und ein umgangenes Standardmodell ist gefährlicher als keines. Zweitens ist ein mitgelieferter Verwaltungsbereich ein zweiter Zugang zu den Falldaten, an dem die Protokollpflicht für lesende Zugriffe (R3-F-057) und die Klassifizierung vorbeigehen. Ein solcher Zugang wird nicht gebaut.

**Abhängigkeitsverwaltung.** Ein Werkzeug mit Sperrdatei samt Prüfsummen und einem Modus, der ausschliesslich aus der Sperrdatei auflöst (`uv` mit `uv.lock`; geprüfte Alternative: Poetry). Grund: K4 und K3. Für den Offline-Betrieb gilt: Der **Bau** darf eine hausinterne Paketspiegelung voraussetzen, der **Betrieb** darf keinerlei ausgehende Verbindung voraussetzen.

### 3.2 A2 — Datenzugriff, Migrationen und das ausschliesslich anfügbare Protokoll

PostgreSQL ist gesetzt (5.1). Zu entscheiden ist der Weg dorthin.

**Optionen für die Zugriffsschicht.**

| Option | Bewertung |
|---|---|
| **Typisierte SQL-Werkzeugkasten- und Abbildungsschicht** (SQLAlchemy 2 im asynchronen Betrieb) mit **Alembic** für Migrationen | Erlaubt handgeschriebenes SQL dort, wo die Abfrage exakt sein muss, und Abbildung dort, wo sie es nicht sein muss. Migrationen sind versioniert, vorwärts und rückwärts prüfbar |
| **Reiner Treiber mit handgeschriebenem SQL** (asyncpg) | Volle Kontrolle, keine Abstraktionslecks — aber kein Migrationswerkzeug, kein Schutz gegen abweichende Schreibwege, und jede Klassifizierungsprüfung wäre in jeder Abfrage von Hand zu wiederholen |
| **Verschmelzung von API-Schema und Persistenzschema** (SQLModel-Muster) | Spart Schreibarbeit. Wird abgelehnt: Genau an der Naht zwischen Persistenz und Antwort sitzt das Risiko aus R3-F-054 — ein Feld, das in der Datenbank steht und deshalb in der Antwort landet, ist die Bauform des Klassifizierungslecks. Die beiden Schemata bleiben getrennt |

**Entscheid.** Typisierte Zugriffsschicht mit Migrationswerkzeug. Migrationen liegen in zwei Formen nebeneinander im selben Migrationsstrang: erzeugte Schemaschritte und **handgeschriebenes SQL** für alles, was die Datenbank selbst durchsetzen muss.

**Anfügbarkeit des Protokolls — vier Ebenen, nicht eine.** R3-F-008 verlangt, dass ein Aktualisierungs- oder Löschbefehl auf die Protokolltabelle abgewiesen wird. Eine Prüfung in der Anwendung erfüllt das nicht, weil sie sich umgehen lässt, indem man die Anwendung umgeht.

| Ebene | Mittel | Was sie verhindert |
|---|---|---|
| 1 | Getrennte Datenbankrollen: die Anwendungsrolle hat auf den Spurtabellen `INSERT` und `SELECT`, kein `UPDATE`, kein `DELETE`, kein `TRUNCATE` | Den versehentlichen und den bequemen Weg |
| 2 | Regel beziehungsweise Auslöser in der Datenbank, der `UPDATE` und `DELETE` mit Fehler beendet | Den Weg über eine falsch vergebene Berechtigung |
| 3 | Verkettung über SHA-256 je Eintrag, in der Anwendung gebildet und unabhängig nachrechenbar | Die nachträgliche Änderung durch jemanden mit Datenbankrechten |
| 4 | Kettenprüfung auf Verlangen mit Angabe der ersten Bruchstelle (R3-F-012) | Dass ein Bruch unbemerkt bleibt |

Die Migration, die Ebene 1 und 2 herstellt, ist handgeschriebenes SQL und wird als solche geprüft. Die Prüfsumme wird in der Anwendung gebildet, weil sie dort testbar, versionierbar und im Export nachvollziehbar ist; die Datenbank ist der zweite, unabhängige Rechenweg für die Prüfung.

**Herkunftsnachweis relational, PROV beim Export.** Der Herkunftsnachweis wird **relational** geführt: jeder Knoten und jede Kante trägt einen Fremdschlüssel auf einen Herkunftssatz, mit `NOT NULL`. Damit ist R3-F-005 („kein Knoten ohne Herkunft") eine Eigenschaft des Schemas und keine Zusicherung des Aufrufers. W3C PROV ist das **Austauschformat** und wird beim Export aus den relationalen Sätzen erzeugt (5.10). Ein PROV-Dokument als Speicherform wäre für die Abfragen, die R3-F-054 verlangt, das falsche Werkzeug.

**Keine Klardaten im Protokoll.** R3-F-011 wird im Schema verankert: Die Spurtabellen haben keine Spalten für Klartextwerte personenbezogener Angaben; sie führen Prüfsummen und Verweise. Die Falldaten liegen im Fallbestand, nicht im Protokoll. Das ist zugleich die Voraussetzung dafür, dass eine Fallöschung die Kette nicht bricht (4.4).

### 3.3 A3 — Suchindex

**Optionen.** Suchindex innerhalb von PostgreSQL (Volltext mit `tsvector`/GIN, Trigramm für Autovervollständigung) gegen einen eigenen Suchdienst (Elasticsearch/OpenSearch).

**Entscheid.** Der Suchindex von R3cOSINT liegt **in PostgreSQL**. Ein eigener Suchdienst wird nicht betrieben.

**Begründung.** R3-F-054 verlangt, dass eine ab Klassifizierung 1b eingestufte Entität in Trefferlisten, Autovervollständigung, Graphnachbarschaften, Exporten und Statistiken **gar nicht erst erscheint** — insbesondere darf sich die Trefferzahl nicht ändern. Das ist genau dann sauber erreichbar, wenn Suche und Datenbestand dieselbe Filterbedingung im selben Abfrageplan sehen. Ein zweiter Dienst bedeutet: ein zweites Berechtigungsmodell, ein zweiter Löschweg (R3-F-020 nennt den Suchindex ausdrücklich), eine zweite Kopie der Falldaten und ein zweiter Nachweis, dass beide gleich denken. Dazu K7 und K3: ein Suchdienst weniger im Setup, kein zusätzlicher Speicher- und Betriebsaufwand.

**Ehrliche Grenze.** Diese Wahl hat eine Obergrenze bei Bestandsgrösse und Suchkomfort. Sie ist an der erwarteten Grössenordnung eines Dezernatsbestandes vertretbar. Wird sie erreicht, ist der Ausweg **nicht** ein zweiter Index neben der Datenbank, sondern ein eigener Entscheid mit gemessenen Zahlen und einer belegten Antwort auf die Frage, wie Klassifizierung und Löschweg dort greifen. Diese Bedingung ist Teil des Entscheids.

**Abgrenzung.** Der selbst betriebene OpenSanctions-Dienst (`yente`, R3-F-035) bringt seinen eigenen Index für die Sanktionsdaten mit. Das ist ein eigenständiges System an der Kontextgrenze, kein Index über Falldaten. Es gehen keine Falldaten dorthin.

### 3.4 A4 — `pgvector`

5.18 verlangt eine ausdrückliche Prüfung: `pgvector` wird nur aufgenommen, wenn ein anderer Zweck als die gestrichene Gesichtserkennung sie rechtfertigt.

**Optionen.** (a) Jetzt aufnehmen für eine spätere semantische Suche über Falltexte. (b) Nicht aufnehmen; bei konkretem Bedarf als eigener Eintrag mit eigenem Entscheid.

**Entscheid.** **`pgvector` ist nicht Bestandteil des Aufbaus.** Keine Erweiterung, keine Spalte, keine Migration, kein Platzhalter, keine Konfigurationsoption.

**Begründung.**

1. **Es gibt keinen Bedarf mit Anforderung.** Weder Etappe 0 noch Etappe 1 noch eine spätere Etappe enthält einen Backlog-Eintrag, der semantische Suche verlangt. Eine Erweiterung auf Vorrat ist eine Entscheidung ohne Anforderung.
2. **Ein Vektorindex wäre ein zweiter Auffindungsweg.** R3-F-054 verlangt, dass eine 1b-Entität über **keinen** Weg auffindbar ist. Ein Ähnlichkeitsindex ist ein eigener Weg mit eigenem Filterbedarf; er müsste dieselbe Klassifizierungsbedingung tragen und im Löschweg aus R3-F-020 vollständig erreicht werden.
3. **Er wäre eine zweite Kopie des Inhalts.** Einbettungen sind aus Falltext abgeleitete Daten. Sie fallen unter dieselben Löschwege und dieselbe Zweckbindung — Aufwand, dem kein Nutzen gegenübersteht, solange niemand die Funktion angefordert hat.
4. **Er kollidiert mit K4.** Einbettungen hängen am Einbettungsmodell. Wechselt es, ändern sich die Ergebnisse, ohne dass sich Eingabe oder Programmstand geändert haben. R3-Q-002 verlangt das Gegenteil.
5. **Biometrische Vektoren sind ausgeschlossen** (5.18). Das gilt unabhängig von diesem Entscheid und bleibt auch dann so, wenn `pgvector` später aus einem anderen Grund hinzukommt.

**Bedingung für eine spätere Aufnahme.** Ein Backlog-Eintrag mit Abnahmekriterium, ein eigener ADR, und darin belegt: die Klassifizierungsbedingung wirkt auf dem Vektorindex, der Löschweg erreicht ihn, das Einbettungsmodell samt Version steht im Herkunftsnachweis und im Export. Ohne diese drei Nachweise wird er nicht aufgenommen.

Damit ist der offene Punkt 3 des Kontextmodells entschieden.

**Erweiterungen, die vorgesehen sind.** Trigramm-Unterstützung für Autovervollständigung und unscharfe Namenssuche sowie die für die Volltextsuche nötigen Wörterbücher. Sie müssen im Datenbank-Image offline vorhanden sein (K3).

### 3.5 A5 — Freigabesperre: Vorschlag und Ausführung technisch nicht verkettbar

5.2 und R3-F-014 verlangen keine Einstellung, sondern eine fehlende Fähigkeit. „Es existiert kein Codepfad" ist eine Aussage über die Struktur des Programms und muss als solche prüfbar sein.

**Optionen.** (a) Prüfung in der ausführenden Funktion („ist freigegeben?"). (b) Getrennte Module ohne Aufrufkante, einmal verwendbare Freigabe-Kennung, dazu Prozess- und Rechtegrenze.

**Entscheid.** Option (b), in vier Stufen:

1. **Zwei Module ohne Aufrufkante.** `freigabe.vorschlag` erzeugt eine Freigabevorlage und schreibt sie in den Zustand *offen*. `freigabe.ausfuehrung` nimmt Arbeit ausschliesslich mit einer Freigabe-Kennung an. Das Vorschlagsmodul importiert das Ausführungsmodul nicht und kennt weder dessen Namen noch dessen Adresse. Durchgesetzt über einen Architekturvertrag im Importprüfer (Abschnitt 3.12), der als eigener Kettenschritt läuft — seit der Fortschreibung vom 2026-08-30 als **D18** in der Tabelle in Abschnitt 6 geführt. Bis dahin verlangte dieser Satz einen Kettenschritt, den die eigene Tabelle des ADR nicht führte; Befund und Auflösung stehen in 6.1.
2. **Die Freigabe-Kennung entsteht nur an einem Ort.** Sie wird ausschliesslich von dem Endpunkt erzeugt, der eine angemeldete, interaktive Benutzersitzung voraussetzt. Ein Dienstzugang, ein API-Schlüssel nach 5.13 und der Aufrufweg des Sprachmodells können sie nicht erzeugen — nicht weil es verboten wäre, sondern weil dieser Weg dort nicht existiert.
3. **Einmalverwendung.** Die Kennung wird bei der Ausführung verbraucht (Zustandsübergang in derselben Transaktion). Eine zweite Ausführung mit derselben Kennung wird abgewiesen und protokolliert. Umfang und Zielmenge der Ausführung werden gegen die Vorlage geprüft; weicht sie ab, wird abgewiesen.
4. **Prozessgrenze.** Die Ausführung läuft im Beschaffungsprozess, der Vorschlag im Anwendungsprozess. Der Beschaffungsprozess nimmt Aufträge nur über die Warteschlange entgegen und liest die Freigabe selbst aus der Datenbank nach, statt der aufrufenden Seite zu glauben.

**Begründung.** Nur diese Form macht die Abnahme prüfbar. Der Test „es existiert kein Codepfad" wird zum Vertragstest des Importprüfers, „es existiert keine Konfiguration, die diese Prüfung deaktiviert" wird zur Aussage, dass keine Konfigurationsschlüssel dieses Namens existieren. Beides prüft eine Maschine. Die Prüfung „ist freigegeben?" in der ausführenden Funktion prüft dagegen nur, dass heute jemand daran gedacht hat.

**Absicherung mit R3-F-017.** Freigabesperre und Behandlung fremder Inhalte sichern sich gegenseitig (5.4). Deshalb ist zusätzlich in A7 festgelegt, dass das Sprachmodell überhaupt keine Werkzeuge auslösen kann.

### 3.6 A6 — Graphdarstellung und Export

**Entscheid.** Mermaid-Text und `.drawio`-Datei werden **serverseitig** erzeugt, deterministisch und mit stabiler Sortierung. Die Anzeige im Browser rendert den erzeugten Mermaid-Text mit einer lokal ausgelieferten Bibliothek.

**Begründung.** K4 und K6: Zwei Ermittlungsstände sollen zeilenweise vergleichbar sein (R3-F-070); das setzt eine deterministische Erzeugung voraus, die getestet werden kann. K3: Es wird **kein** eingebetteter fremder Zeichendienst verwendet — weder als eingebetteter Rahmen noch über einen Aufruf nach aussen. Eine Einbettung von `diagrams.net` wäre eine ausgehende Verbindung mit Fallinhalt und ist ausgeschlossen.

**Filterung.** Ab mehr als 50 Knoten erzeugt das System einen gefilterten Ausschnitt und weist die angewandte Filterung in der Ausgabe aus (R3-F-070). Die Filterung läuft über dieselbe Berechtigungsbedingung wie die Suche (A3), damit eine 1b-Entität auch als Graphnachbarschaft nicht erscheint.

**Offen und terminiert:** die interaktive Graphbearbeitung im Browser (R3-F-072, Etappe 4). Sie gehört zur Oberflächenschicht und wird mit der Komponentenbibliothek entschieden (Abschnitt 8, offener Punkt O-2).

### 3.7 A7 — Anbindung des Sprachmodells

**Optionen für den Zugriff.**

| Option | Bewertung |
|---|---|
| **Anbieter-SDK, auf eine eigene Adresse umgestellt** | Ausgereift, behandelt Datenstrom und Wiederholungen. Aber: Ein Anbieter-SDK ist eine Abhängigkeit, deren ausgehendes Verhalten für D9 (kein Rückkanal) je Fassung neu zu belegen wäre, und es widerspricht dem Bild von 5.15 Punkt 2 in einem System, dessen Anbieterunabhängigkeit ausdrücklich prüfbar sein soll |
| **Eigene schlanke Zwischenschicht** auf der dokumentierten OpenAI-kompatiblen HTTP-Schnittstelle | Kleine Oberfläche, vollständige Kontrolle über jede ausgehende Verbindung, einfache Aufzeichnung von Anfrage und Antwort für K4 und für die Arbeitsspur |

**Entscheid.** Eigene Zwischenschicht im Modul `llm`. Sie ist die **einzige** Stelle im Programm, die mit einem Modellendpunkt spricht. Anbieterspezifische Formate, Systemprompt-Konventionen und Werkzeugaufruf-Dialekte kommen ausserhalb dieses Moduls nicht vor; das ist die Aussage, die R3-F-018 prüft.

**Mehrere Modelle nebeneinander** sind vorgesehen (5.15): eine Zuordnungstabelle Aufgabentyp → Endpunkt und Modellname, als Konfiguration. Der Wechsel des Endpunkts und des Modellnamens ist damit eine Konfigurationsänderung. Modellname, Modellfassung, Endpunktkennung und Prüfsumme der Gewichte, soweit bekannt, werden je Aufruf in der Arbeitsspur und in jedem Export vermerkt (5.15 Punkt 3, R3-Q-002).

**Der zweite Teil dieses Entscheids ist der wichtigere: Das Sprachmodell erhält keine Werkzeugaufruf-Fähigkeit.** Es werden keine Werkzeugbeschreibungen an das Modell übergeben, und eine Modellantwort kann keinen Werkzeugaufruf auslösen. Das Modell liefert einen **Vorschlag** als strukturierte Ausgabe, die gegen ein eigenes Schema geprüft wird; alles, was dem Schema nicht entspricht, wird verworfen und protokolliert. Ausgeführt wird ausschliesslich über den Weg aus A5.

Das erledigt drei Anforderungen an einer Stelle: 5.2 (Vorschlag und Ausführung nicht verkettbar), R3-F-017 (eingeschleuster Text kann kein Werkzeug auslösen, weil das Modell keines auslösen kann) und R3-F-018 (kein Werkzeugaufruf-Dialekt im Code). Es kostet Bequemlichkeit — der geläufige Bauweg mit Werkzeugaufrufen des Modells entfällt. Das ist beabsichtigt: Genau dieser Bauweg ist der, den 5.4 als Punkt mit dem höchsten Umsetzungsrisiko benennt.

**Fremde Inhalte** werden dem Modell in einem gekennzeichneten Datenabschnitt übergeben, nie im Anweisungsabschnitt. Umgesetzt als Typ: Was aus dem Beschaffungsmodul kommt, ist ein eigener Datentyp `FremderInhalt` mit Quelle, Abrufzeitpunkt und Prüfsumme; die Zwischenschicht nimmt für den Datenabschnitt ausschliesslich diesen Typ entgegen. Eine Zeichenkette aus dem Netz kann dort nicht ankommen, ohne den Typ zu durchlaufen.

### 3.8 A8 — Rahmenwerk der Oberfläche, und was ausdrücklich offen bleibt

**Die Ausgangslage ist eine doppelte Vorgabe.** Die Abnahme von R3-C-001 verlangt, dass der ADR „Ziel-Stack, Rahmenwerk, Komponentenbibliothek, Modulgrenzen und Begründung je Entscheid" nennt. 5.6 hält gleichzeitig fest: „[OFFEN] Designsystem, Komponentenbibliothek und Zielplattformen. Diese Entscheidungen fallen nach dem Prototyp-Review, weil sie dann auf Beobachtungen beruhen statt auf Vermutungen."

Beides steht im Projektauftrag. Dieser ADR löst es so auf, dass er **trennt**:

| Jetzt entschieden | Ausdrücklich offen bis zur Prototyp-Freigabe (R3-F-050) |
|---|---|
| Rahmenwerk und Bauwerkzeug der Oberfläche | Konkrete Komponentenbibliothek |
| Auslieferungsform (Einzelseitenanwendung gegen die dokumentierte Schnittstelle) | Designsystem und Design-Tokens |
| Art der Komponentenbibliothek und die Kriterien ihrer Auswahl | Zielplattformen und Bildschirmgrössen |
| Prüfweg für Barrierefreiheit | Bibliothek für die interaktive Graphbearbeitung |

Der Grund für diese Trennung ist nicht Bequemlichkeit: Das Rahmenwerk bestimmt Verzeichnislayout, Bauwerkzeug, Prüfkette und Containerlayout und muss deshalb jetzt feststehen; die Komponentenbibliothek bestimmt Aussehen und Interaktionsdetails und beruht nach 5.6 auf dem, was das Prototyp-Review beobachtet. **Vor der schriftlichen Prototyp-Freigabe entsteht kein Frontend-Produktionscode** — dieser Entscheid ändert daran nichts.

**Dies ist dem Auftraggeber zur Entscheidung vorzulegen** (Abschnitt 8, O-1): Entweder er bestätigt diese Trennung, oder das Abnahmekriterium von R3-C-001 wird durch den Product Owner an 5.6 angepasst. Der Software Architect ändert den Backlog nicht.

**Optionen für das Rahmenwerk.**

| Option | Bewertung |
|---|---|
| **TypeScript mit React, gebaut mit Vite, als Einzelseitenanwendung** | Grösste Auswahl an ungestalteten, auf Barrierefreiheit geprüften Bausteinen und an Graphbibliotheken; grösster Vorrat an Beispielen, was bei rund 80 Prozent maschinell erzeugtem Code die Fehlerquote senkt. Nachteil: zweiter Sprachstack, zweite Werkzeugkette, grössere Lieferketten-Fläche (D8, D11) |
| **Serverseitig gerendertes HTML mit htmx**, aus dem Python-Backend | Kein zweiter Stack, kleinste Lieferkette, hervorragend offline. Wird nicht gewählt: Die Interaktionsdichte von Graphbearbeitung (R3-F-072), Freigabedialog mit Kontingentvorschau (R3-F-014) und dem sechsschrittigen Ermittlungskreislauf (R3-F-060) führt dazu, dass genau die riskantesten Teile in handgeschriebenem JavaScript ohne geprüfte Bausteine für Barrierefreiheit entstünden. Das verlagert das Risiko, statt es zu vermeiden |
| **Vue oder Svelte** | Beide tragfähig und schlanker. Ausschlaggebend dagegen: dünneres Angebot an ungestalteten, auf WCAG geprüften Bausteinen und weniger Beispielmaterial |
| **Angular** | Vollständiges Rahmenwerk mit mitgelieferten Antworten für Wegewahl, Formulare und Übersetzung; gut für langlebige Verwaltungsanwendungen. Dagegen: Die naheliegende Komponentenbibliothek bringt eine eigene Gestaltungssprache mit, die den in 5.6 als verbindlich erklärten Gestaltungsentscheidungen der Demo widerspräche |
| **Serverseitiges Rendern mit einem Node-Rahmenwerk** (Next-Familie) | Kein Nutzen: Die Anwendung liegt vollständig hinter der Anmeldung, Suchmaschinensichtbarkeit ist ohne Belang, und es entstünde eine zweite Laufzeitumgebung in Produktion — mehr Angriffsfläche und ein zusätzlicher Offline-Fall |

**Entscheid.** **TypeScript mit React, gebaut mit Vite, ausgeliefert als Einzelseitenanwendung gegen die dokumentierte HTTP-Schnittstelle.** In Produktion werden ausschliesslich statische Dateien ausgeliefert; es läuft keine Node-Laufzeitumgebung in Produktion.

**Entscheid zur Art der Komponentenbibliothek.** Die spätere Wahl ist auf **ungestaltete, auf Barrierefreiheit geprüfte Bausteine** eingeschränkt — nicht auf ein fertiges Designsystem mit eigener Gestaltungssprache. Grund: 5.6 erklärt Bildschirmfluss, Aufteilung, Benennungen und Interaktionsmuster der bestehenden Demo für verbindlich. Ein mitgebrachtes Designsystem würde sie überschreiben; ungestaltete Bausteine übernehmen Tastaturbedienung, Fokusführung und Rollenauszeichnung und überlassen die Gestaltung den Tokens aus dem Prototyp-Review.

Kriterien für die Auswahl nach der Prototyp-Freigabe, hier verbindlich festgelegt:

1. Vollständig lokal auslieferbar; kein Nachladen von Schriften, Symbolen oder Skripten aus einem fremden Netz zur Laufzeit (K3, R3-C-004).
2. Belegbare Eignung für WCAG 2.2 AA in Tastaturbedienung, Fokusreihenfolge und Rollenauszeichnung (R3-Q-003).
3. Freie Lizenz ohne Nutzungsbeschränkung für den behördlichen Einsatz.
4. Keine mitgelieferte Nutzungsmessung, keine Aktualisierungsabfrage.
5. Deckt das Komponenteninventar aus dem Prototyp-Review; Lücken werden benannt, nicht überdeckt.

**Zwischenstand zu den Zielplattformen**, bis das Review entscheidet: Arbeitsplatzrechner der Dienststelle mit aktuellem Browser, Bedienung mit Maus und Tastatur. Die vorhandene Demo ist ein Schreibtischlayout. Ob mobile Nutzung dazukommt, entscheidet das Review — es ist eine Anforderung, keine Selbstverständlichkeit.

### 3.9 A9 — Schnittstellenstil

**Optionen.** HTTP/JSON nach OpenAPI gegen GraphQL.

**Entscheid.** **HTTP/JSON, beschrieben durch eine erzeugte OpenAPI-Beschreibung.** Die TypeScript-Typen der Oberfläche werden aus dieser Beschreibung erzeugt, nicht von Hand geführt.

**Begründung.** 4.2 setzt OpenAPI als Arbeitsgrundlage des Backend Engineers. Fachlich entscheidend ist aber R3-F-054: Eine frei formulierbare Abfragesprache eröffnet für jedes Feld und jede Beziehung einen eigenen Weg zu einer Aussage über eine Entität — und damit für jeden dieser Wege eine eigene Stelle, an der die Klassifizierung greifen muss. Eine feste Menge von Endpunkten mit einer gemeinsamen Filterbedingung ist prüfbar; eine offene Abfragefläche ist es nicht. Erzeugte Typen verhindern zusätzlich, dass Oberfläche und Server auseinanderlaufen, ohne dass ein Test es merkt.

### 3.10 A10 — Anmeldestack

Die Protokollwahl ist in 5.7 bereits getroffen: OpenID Connect / OAuth 2.0, SAML nur als Rückfallebene über eine vorgelagerte Zwischenschicht. Hier ist nur die Technikwahl zu treffen.

**Entscheid.**

| Gegenstand | Entscheid | Begründung |
|---|---|---|
| Rolle der Anwendung | OIDC-Vertrauenspartei mit PKCE, Ermittlung über das Discovery-Dokument, Schlüsselbezug über JWKS, Behandlung von Erneuerungs-Token, Abmeldung | R3-F-051 zählt diese Punkte einzeln auf |
| Bibliothek | Eine gepflegte, standardkonforme OIDC-Bibliothek des Python-Ökosystems (Authlib-Klasse) | Selbstgebaute Token-Prüfung ist die falsche Stelle zum Sparen |
| Provider in Test/Schulung | Ein selbst betriebener Provider im Container (Keycloak-Klasse); geprüfte Alternative: ein schlanker Provider (Dex-Klasse) | Keycloak bildet Gruppen, Rollen und WebAuthn ab und läuft offline; ein schlanker Provider spart Betrieb, kann aber die Verfahren aus R3-F-052 nicht abbilden |
| Mandantenwechsel | Ausschliesslich Konfiguration: Discovery-Adresse, Client-Kennung, Geheimnis, Rückleitungsadressen, Scopes | 5.7; die Anwendung kennt nur Standard-OIDC |
| Rollenabbildung | Konfigurationstabelle Gruppe beziehungsweise App-Rolle → interne Rolle und Klassifizierungsberechtigung, **nicht im Code** | 5.7 ausdrücklich; R3-F-051 zweiter Test |
| Berechtigungsquelle | Ausschliesslich die interne Benutzerverwaltung. Der Identitätsanbieter beantwortet nur, **wer** jemand ist | 5.7; ein neu angemeldetes Konto ohne interne Zuweisung sieht eine leere Anwendung |

**Ehrliche Grenze.** Die Anbindungsdaten des Entra-ID-Mandanten liegen bei der Informatik der Kantonspolizei Bern (5.7). Sie blockieren ausschliesslich den Wechsel auf den echten Mandanten, nicht die Entwicklung. Die Liste der benötigten Angaben steht vollständig in 5.7 und wird nicht hier wiederholt.

**Offen und terminiert:** wo der zweite Faktor nach R3-F-052 durchgesetzt wird — im Provider oder in R3cOSINT. Das hängt an der MFA-Richtlinie des Mandanten und wird mit dem Anmeldestack in Etappe 3 entschieden (Abschnitt 8, O-3).

### 3.11 A11 — Container- und Umgebungslayout

**Optionen für die Orchestrierung.** Docker Compose gegen Kubernetes beziehungsweise Portainer.

**Entscheid.** **Docker mit Compose**, ein Stapel je Umgebung. Kubernetes wird nicht eingeführt.

**Begründung.** K7: R3-F-019 verlangt einen durchgängigen Weg vom Klonen bis zum laufenden System, betrieben von einer Dienststelle, nicht von einem Rechenzentrumsteam. Der Nutzen von Kubernetes — Skalierung über viele Knoten, rollende Auslieferung, Selbstheilung — trifft auf diesen Betrieb nicht zu, der Aufwand schon. Der Wechsel bleibt möglich, weil die Images dieselben blieben; er wird entschieden, wenn ein Bedarf mit Anforderung vorliegt, nicht vorher.

**Zwei Umgebungen ohne Verbindungsweg** (5.16, R3-C-003):

| Gegenstand | Umsetzung |
|---|---|
| Trennung | Zwei getrennte Compose-Stapel mit eigenem Netz, eigenen Datenträgern, eigener Datenbankinstanz, eigenem Artefaktspeicher, eigenem Satz Zugangsdaten |
| Kein gemeinsamer Speicher | Kein Datenträger und kein Netz wird von beiden Stapeln eingebunden. Es gibt kein Compose-Fragment, das beide beschreibt |
| Modus | Wird beim Start aus der Umgebungskonfiguration gelesen. Es existiert kein Endpunkt, keine Einstellung und kein Codepfad, der ihn zur Laufzeit ändert |
| Kennzeichnung | Das Band aus R3-F-061 hängt am beim Start gelesenen Modus und ist nicht ausblendbar |
| Kein Übertragungsweg | Es existiert kein Modul und kein Skript, das Daten von einer Umgebung in die andere überträgt. Wer Testdaten braucht, erhält den synthetischen Bestand aus 5.6 |

**Netzlayout — genau ein Container hat einen Weg nach aussen.** Das ist die tragende Entscheidung dieses Abschnitts:

| Container | Aufgabe | Ausgehendes Netz |
|---|---|---|
| `datenbank` | PostgreSQL | keines |
| `anwendung` | HTTP-Schnittstelle, Fachlogik, Vorschlagsseite | keines |
| `oberflaeche` | Auslieferung der statischen Dateien | keines |
| `beschaffung` | MCP-Anbindungen, Ausführungsseite, Anbieterschlüssel | **ausschliesslich über den Ausgangs-Vermittler** |
| `ausgang` | Vermittler, der die Positivliste durchsetzt und jeden Versuch protokolliert | nach aussen, nur auf Ziele der Positivliste |
| `modell` | lokale Sprachmodell-Instanz (in Produktion zwingend, 5.15, R3-C-006) | keines |
| `idp` | Identitätsanbieter in Test/Schulung | keines |

Damit sind drei Anforderungen nicht mehr nur Code, sondern Netzwerktopologie: R3-C-004 (kein Rückkanal — ein Container ohne Route kann keine Telemetrie senden), R3-F-015 (Positivliste — abgewiesen und protokolliert wird am Vermittler, unabhängig davon, welche Bibliothek die Verbindung versucht) und R3-F-021 (Offline-Betrieb — fällt der Vermittler weg, laufen Datenbestand und Darstellung weiter, und Abfragen nach aussen scheitern mit verständlicher Meldung).

**Anbieterschlüssel liegen ausschliesslich im Beschaffungsteil** (R3-F-013). Der Anwendungsprozess erhält sie gar nicht erst; er kann nicht ausliefern, was er nicht hat. Die Zurechenbarkeit zur Person entsteht über den Auftrag, der Fall, Person und Freigabe-Kennung trägt.

**Images.** Mehrstufig gebaut, Laufzeit ohne Bauwerkzeuge, Ausführung nicht als `root`, Basis-Images über Prüfsumme festgelegt (K4). Geheimnisse kommen als eingehängte Dateien, nie in ein Image, nie ins Repository.

**Zweite Fortschreibung 2026-08-30 — Geheimnisse liegen auch nicht im Arbeitsbaum.** Der Satz oben bleibt und wird um den Fall geschärft, den er nicht ausdrücklich nannte: Das Repository-Verzeichnis ist auch dann der falsche Ort für Zugangsdaten, wenn die Datei nicht committet wird. Zugangsdaten und Schlüsselmaterial liegen ausserhalb des Arbeitsbaums; der Prüfstapel hängt sie von dort ein. Die Dateien unter `deploy/konfiguration/{test,produktion}/` bleiben Beispieldateien ohne Geheimnisse (Abschnitt 5). Grund und Optionenvergleich stehen in 6.2.3: Der Arbeitsbaumlauf aus D11 sieht auch ignorierte Dateien, und die Alternative wäre gewesen, das Gate für genau die wertvollsten Pfade abzuschalten. Damit ist ein Fund im Arbeitsbaum immer ein Befund und nie ein Betriebszustand. Die betriebliche Form — Ablageort, Einhängung, Betriebsdokumentation — entscheiden SecDevOps und DevOps Engineer (O-10).

**Ehrliche Grenze zum Offline-Betrieb.** Der **Betrieb** ist vollständig offline möglich. Der **Bau** setzt eine Paketquelle voraus — im Haus eine Spiegelung, sonst das offene Netz. Das ist kein Widerspruch zu R3-F-021, aber es gehört benannt, weil es die Betriebsdokumentation betrifft. Zweite Grenze: Meldet sich ein Konto im Offline-Betrieb über einen externen Identitätsanbieter an, kann das nicht gelingen. Offline nutzbar ist die Anmeldung über den hausinternen Provider; das ist bei der Einrichtung der Produktion zu berücksichtigen.

### 3.12 A12 — Teststack und Prüfstufen

**Entscheid.**

| Stufe | Werkzeug | Zweck |
|---|---|---|
| Formatierung und Linter, Backend | Ruff (Formatierung und Prüfung in einem Werkzeug) | D2, D3 |
| Typprüfung, Backend | mypy im strengen Modus | D4 |
| Tests, Backend | pytest mit asynchroner Unterstützung, Abdeckungsmessung | D5, D6 |
| **Architekturverträge** | Importprüfer mit Verträgen (import-linter-Klasse) | D18 (Kettenschritt, seit der Fortschreibung vom 2026-08-30 in Abschnitt 6 geführt). Macht die Modulgrenzen aus Abschnitt 4 maschinell prüfbar — Voraussetzung für R3-F-014 und R3-F-018 |
| Integrationstests | Gegen eine PostgreSQL-Instanz aus dem Prüfstapel, kein Nachladen von Images zur Testzeit | K3, K4 |
| Linter und Typprüfung, Oberfläche | ESLint, Prettier, TypeScript-Compiler ohne Ausgabe | D2, D3, D4 |
| Tests, Oberfläche | Vitest für Einheiten, Playwright für durchgehende Abläufe | D5 |
| Barrierefreiheit | axe-Prüfung innerhalb der Playwright-Läufe, über alle Ansichten | R3-Q-003, R3-F-050 |
| Abhängigkeiten | `pip-audit` und `npm audit` | D8 |
| Geheimnisse | `gitleaks` | D11 |

**Testnamen und Verfolgbarkeit.** Jeder Abnahmetest trägt die Anforderungskennung im Namen (6.6). Da Python-Bezeichner keine Bindestriche zulassen, gilt die Abbildungsregel: `R3-F-008_kette_bricht_bei_aenderung` wird zu `test_R3_F_008_kette_bricht_bei_aenderung`. Ein eigener Prüfschritt vergleicht die Testnamen des Backlogs mit den gesammelten Testkennungen und meldet jede Anforderung ohne Test. Damit ist D7 kein Vertrauensakt.

**Modelltrennung.** Die umsetzende Rolle prüft nicht ihre eigene Arbeit; der Prüfschritt läuft auf einem anderen Modell (3.4, ADR 0001 Abschnitt 2.3). Das ist eine Vorgabe an den Ablauf, nicht an den Stack, und bleibt hier unverändert.

### 3.13 A13 — Sprache der Bezeichner

**Optionen.** (a) Durchgängig englische Bezeichner. (b) Fachbegriffe des Glossars als Bezeichner, technische Begriffe englisch.

**Entscheid.** Option (b). Modulnamen, Entitäten, Tabellen, Spalten und Zustände der **Fachlichkeit** tragen den Begriff aus `docs/03_Glossar.md`: `fall`, `freigabe`, `herkunft`, `ermittlungsspur`, `arbeitsspur`, `klassifizierung`, `negativbefund`, `positivliste`, `kontingent`, `grabstein`, `loeschsperre`. Technische Begriffe ohne Eintrag im Glossar bleiben englisch. Bezeichner sind ASCII (`pruefsumme`, nicht `prüfsumme`). Oberflächentexte sind deutsch mit Schweizer Schreibweise.

**Begründung.** 6.3 erklärt die Verwendung des Glossars für alle Arbeitsprodukte und Oberflächentexte für verpflichtend, und mehrere Begriffe verlieren beim Übersetzen ihre rechtliche Genauigkeit — die Unterscheidung von verdeckter Fahndung und verdeckter Ermittlung ebenso wie die Klassifizierungsstufen 1a und 1b, die nicht mit den Rangstufen der Rechtsregime verwechselt werden dürfen (Glossar, Homonym-Warnung). Ein Bezeichner, der wörtlich der Anforderung entspricht, macht die Verfolgbarkeit rückwärts lesbar statt nachschlagepflichtig. Der Preis ist ein gemischtsprachiger Code; er wird durch die Regel begrenzt, dass ausschliesslich Glossarbegriffe deutsch sind.

---

## 4. Modulschnitt und Verankerung der Verfahrensgarantien

### 4.1 Module

Ein Modul ist ein Python-Paket unter `backend/src/r3cosint/`. Die Ebenen beziehen sich auf 5.1.

| Modul | Ebene | Verantwortung |
|---|---|---|
| `core` | quer | Kennungen, Zeit in UTC nach ISO 8601, Prüfsummenbildung, Fehlerklassen, Konfiguration einschliesslich Umgebungsmodus |
| `kanon` | 2 | Kanonischer Datenbestand: FollowTheMoney-Entitäten, STIX-2.1-Objekte, Herkunftssätze. Einziger Schreibweg in den Datenbestand |
| `spur` | 2 | Beide Protokollspuren, Verkettung, Negativbefunde, Kennzeichnung Quellenaussage gegen Schlussfolgerung, Pseudonymisierung, Kettenprüfung |
| `fall` | 2 | Fall, Fallbindung, Rechtsregime, Fallkategorie, Zustandsmodell der Aufbewahrung, Löschwege, Grabstein, Löschsperre, fallbezogene Schlüssel |
| `zugriff` | 0/2 | Rollen, Klassifizierung als Zuordnung Stufe → Sichtbarkeitsregel, Freigabeliste je Entität, Organisationseinheit, Protokollierung lesender Zugriffe. Stellt die **eine** Filterbedingung bereit, die jeder Lesepfad benutzt |
| `freigabe.vorschlag` | 1 | Erzeugt Freigabevorlagen mit Vorschau: Abfragen, Ziele, Kontingentverbrauch |
| `freigabe.ausfuehrung` | 1 | Führt ausschliesslich gegen eine gültige, unverbrauchte Freigabe-Kennung aus |
| `beschaffung` | 1 | MCP-Anbindung als einziger Zugang zu den Quellen; Werkzeugverzeichnis; Fallbindung und Kontingentprüfung im Aufrufpfad |
| `ausgang` | 1 | Der einzige Ort mit einem HTTP-Client nach aussen; Positivliste, Protokollierung jedes Versuchs |
| `fremd` | 1 | Typ `FremderInhalt` mit Quelle, Zeitpunkt, Prüfsumme; jede von aussen bezogene Nutzlast wird hier gekapselt |
| `llm` | quer | Modellunabhängige Zwischenschicht, ausschliesslich OpenAI-kompatibel, ohne Werkzeugaufruf-Fähigkeit |
| `graph` | 3 | Filterung, Mermaid-Erzeugung, `.drawio`-Erzeugung |
| `export` | 2/3 | STIX, FollowTheMoney, W3C PROV, PDF/A-3, CSV und XLSX, Manifest mit SHA-256, Exportprotokoll |
| `api` | 0 | HTTP-Endpunkte, Anmeldung, Sitzung, Schemata der Aussenschnittstelle. **Keine Fachlogik** |
| `mcpsrv` | 1 | Bereitstellung eigener MCP-Server für die Quellen, bei denen kein gepflegter Baustein vorliegt |

### 4.2 Wo jede Verfahrensgarantie technisch sitzt

Die Spalte „Erzwungen durch" ist die eigentliche Aussage: eine Garantie, die nur im Aufrufer geprüft wird, ist keine.

| Garantie (5.4) | Modul | Erzwungen durch | Abnahme |
|---|---|---|---|
| **Fallbindung** | `beschaffung`, `fall` | Jeder Werkzeugaufruf läuft durch **einen** Aufrufpfad, der einen gültigen Fallbezug verlangt; die Werkzeuge selbst enthalten keine eigene Prüfung. Zusätzlich Fremdschlüssel auf den Fall in der Datenbank. Das Werkzeugverzeichnis ist auslesbar, damit der Test über alle registrierten Werkzeuge laufen kann | R3-F-002 |
| **Freigabe vor Ausführung** | `freigabe.vorschlag`, `freigabe.ausfuehrung` | Keine Aufrufkante zwischen den Modulen, geprüft durch Architekturvertrag; Freigabe-Kennung nur aus interaktiver Sitzung; Einmalverwendung in derselben Transaktion; Prozessgrenze | R3-F-014 |
| **Herkunft an jedem Datenpunkt** | `kanon` | `NOT NULL`-Fremdschlüssel auf den Herkunftssatz; einziger Schreibweg über `kanon`; Kennzeichnung Quellenaussage gegen Schlussfolgerung als Pflichtfeld ohne Vorgabewert | R3-F-005, R3-F-010 |
| **Positivliste nach aussen** | `ausgang` | Einziger HTTP-Client im Programm, geprüft durch Architekturvertrag; zusätzlich Netztopologie: nur `beschaffung` erreicht den Vermittler, nur der Vermittler erreicht das Netz | R3-F-015 |
| **Kontingentgrenzen** | `beschaffung`, `fall` | Zählung je Fall und je Tag in derselben Transaktion wie die Ausführung; Verbrauch erscheint in der Freigabevorschau | R3-F-016 |
| **Behandlung fremder Inhalte** | `fremd`, `llm` | Typgrenze: Der Datenabschnitt der Zwischenschicht nimmt ausschliesslich `FremderInhalt` an; das Modell hat keine Werkzeugaufruf-Fähigkeit | R3-F-017 |
| **Reproduzierbarkeit** | `core`, `export`, `llm` | Sperrdateien und Image-Prüfsummen; feste Sortierung in jeder Erzeugung; Modell-, Werkzeug- und Modulversionen im Export; Rohantworten mit Prüfsumme im Fallbestand, damit ein Lauf gegen denselben aufgezeichneten Quellstand wiederholbar ist | R3-Q-002 |
| **Kein Rückkanal** | `ausgang`, Betrieb | Kein ausgehendes Netz ausser über den Vermittler; Prüfschritt im Bauprozess gleicht alle Ziele gegen die Positivliste ab | R3-C-004 |

Ergänzend, ausserhalb der acht Garantien:

| Anforderung | Modul | Erzwungen durch |
|---|---|---|
| Protokoll ausschliesslich anfügbar | `spur` | Datenbankrechte, Auslöser in der Datenbank, Verkettung, Kettenprüfung (A2) |
| Protokoll ohne zweite Kopie der Falldaten | `spur` | Schema ohne Klartextspalten für personenbezogene Angaben |
| Klassifizierung wirkt im Suchindex | `zugriff` | **Eine** Filterbedingung, die Suche, Autovervollständigung, Graphnachbarschaft, Export und Statistik gemeinsam benutzen — auch für Trefferzahlen |
| Schlüssel serverseitig | Betrieb, `beschaffung` | Der Anwendungsprozess erhält keine Anbieterschlüssel |
| Löschweg vollständig | `fall` | Ein Löschweg, der alle Ablageorte auflistet und je Ablageort einen Test hat; fallbezogener Schlüssel wird vernichtet, Grabstein bleibt |

### 4.3 Architekturverträge, die als Test laufen

Diese Verträge sind der Grund, warum die Aussagen in Abschnitt 4.2 prüfbar sind und nicht nur behauptet:

1. `freigabe.vorschlag` importiert `freigabe.ausfuehrung` nicht — weder unmittelbar noch mittelbar.
2. Ausser `ausgang` importiert kein Modul eine Bibliothek für ausgehende HTTP-Verbindungen.
3. Ausser `llm` spricht kein Modul mit einem Modellendpunkt; ausserhalb von `llm` kommen anbieterspezifische Formate, Systemprompt-Konventionen und Werkzeugaufruf-Dialekte nicht vor.
4. Ausser `spur` schreibt kein Modul in die Spurtabellen.
5. Ausser `kanon` schreibt kein Modul in den kanonischen Datenbestand.
6. `api` enthält keine Fachlogik: es importiert Fachmodule, wird aber von keinem importiert.
7. Kein Modul importiert etwas aus `prototype/`, und `prototype/` importiert nichts aus dem Produktionscode (5.6; das bestehende Gate `.claude/hooks/block-prototype-import.sh` deckt den Schreibweg ab, der Vertrag deckt den bereits geschriebenen Stand ab).

### 4.4 Tragfähigkeit gegen Etappe 0 und Etappe 1

| Anforderung | Getragen durch |
|---|---|
| R3-C-002 Umbenennung | Namensgebung von Anfang an `r3cosint`; es entsteht keine Altbezeichnung |
| R3-C-003 zwei Umgebungen | A11, Modus beim Start, getrennte Stapel |
| R3-C-004 kein Rückkanal | A11 Netztopologie, `ausgang`, D9 |
| R3-C-005 keine echten Daten über den Harness | Entwicklung ausschliesslich gegen Test/Schulung; getrennte Zugangsdaten (5.16) |
| R3-Q-001 DoD-Gates | Abschnitt 6: ein Einstiegsbefehl, den der Hook aufruft |
| R3-Q-005 Rollen-Schreibgrenzen | Stackunabhängig; von diesem ADR unberührt |
| R3-F-001, R3-F-002 Fall und Fallbindung | `fall`, `beschaffung` |
| R3-F-003 bis R3-F-005 kanonischer Bestand | A1 (Bibliotheken), `kanon`, relationaler Herkunftsnachweis |
| R3-F-006 bis R3-F-012 beide Spuren | `spur`, A2 vierstufige Anfügbarkeit |
| R3-F-013 MCP als einziger Zugang | `beschaffung`, `mcpsrv`, Schlüssel nur im Beschaffungsteil |
| R3-F-014 Freigabesperre | A5, Architekturvertrag 1 |
| R3-F-015, R3-F-016 Positivliste und Kontingente | `ausgang`, `beschaffung` |
| R3-F-017 fremde Inhalte | A7, `fremd` |
| R3-F-018 Modellunabhängigkeit | A7, `llm`, Architekturvertrag 3 |
| R3-F-019 Setup | A11, ein Einstiegsbefehl je Umgebung, Abbruch mit Meldung statt Stacktrace |
| R3-F-020 Aufbewahrung und Löschwege | `fall`; ein Ablageort weniger, weil kein zweiter Suchdienst und kein Vektorindex existiert (A3, A4) |
| R3-F-021 Offline | A11 |
| R3-C-006 lokales Modell | A7 als Konfiguration; Container `modell` |
| R3-Q-002 Reproduzierbarkeit | A1 Sperrdateien, A11 Image-Prüfsummen, `export` |

---

## 5. Grundgerüst — Verzeichnislayout

**Beschreibung, nicht Ausführung.** Die Verzeichnisse werden nach der Freigabe von Backend Engineer und DevOps Engineer angelegt; das ist die nächste Arbeitseinheit und liefert das Grundgerüst nach 3.1 als lauffähigen, aber fachlogikfreien Stand.

```
/
├─ CLAUDE.md                     bestehend
├─ Makefile                      Einstieg für die Definition-of-Done-Kette (Abschnitt 6)
├─ .claude/                      bestehend: agents, rules, hooks, settings.json
├─ .github/workflows/            bestehend: Nachweisübertragung; dazu die Prüfkette
├─ docs/                         bestehend, einschliesslich adr/ und uebergaben/
├─ prototype/                    bestehend, getrennt, ohne gemeinsame Abhängigkeiten (5.6)
├─ backend/
│  ├─ pyproject.toml             Projekt- und Werkzeugkonfiguration
│  ├─ uv.lock                    Sperrdatei mit Prüfsummen (K4)
│  ├─ importvertraege.toml       Verträge aus 4.3, maschinell geprüft
│  ├─ src/r3cosint/
│  │  ├─ core/  kanon/  spur/  fall/  zugriff/
│  │  ├─ freigabe/{vorschlag,ausfuehrung}/
│  │  ├─ beschaffung/  ausgang/  fremd/  llm/
│  │  ├─ graph/  export/  api/  mcpsrv/
│  ├─ migrationen/
│  │  ├─ versionen/              erzeugte Schemaschritte
│  │  └─ sql/                    handgeschrieben: Rollen, Rechte, Auslöser der Spurtabellen
│  └─ tests/
│     ├─ einheit/  integration/  architektur/
│     └─ abnahme/                je Backlog-Eintrag ein Test mit der Kennung im Namen
├─ frontend/                     entsteht erst nach der Prototyp-Freigabe (5.6)
│  ├─ package.json  package-lock.json  vite.config.ts  tsconfig.json
│  ├─ src/{app,ansichten,komponenten,api,tokens}/
│  └─ tests/{einheit,e2e}/
├─ deploy/
│  ├─ compose.test.yml           Stapel Test/Schulung
│  ├─ compose.produktion.yml     Stapel Produktion, ohne jede Verbindung zum ersten
│  ├─ images/                    Dockerfiles je Container
│  └─ konfiguration/{test,produktion}/   Beispieldateien ohne Geheimnisse
└─ scripts/
   ├─ nachweise-erzeugen.sh      bestehend
   ├─ abnahme-abgleich.sh        folgt mit dem Grundgerüst, für D7
   ├─ nachweise-vollstaendig.sh  folgt mit dem Grundgerüst, für D12
   ├─ rueckkanal-pruefen.sh      folgt mit R3-C-004
   └─ prototyp-trennung-pruefen.sh  folgt, Stapelprüfung zum bestehenden Gate
```

Zwei Bauwurzeln (`backend/`, `frontend/`), ein Einstieg (`Makefile`). `frontend/` bleibt leer, bis die Prototyp-Freigabe vorliegt; das ist keine Nachlässigkeit, sondern das Gate aus 5.6.

---

## 6. Definition-of-Done-Befehlskette — Vorschlag je Kettenschritt

Dies löst den offenen Punkt 3 der Definition of Ready und Done. **Vorschlag des Software Architects, zu bestätigen durch DevOps Engineer und Auftraggeber.** Erwartet wird je Schritt Rückgabewert 0.

*Bis zur Fortschreibung vom 2026-08-30 trug dieser Abschnitt den Titel "Vorschlag zu D1 bis D12" und führte genau diese zwölf Schritte. Die Kette umfasst seither zusätzlich D18; die Nummer 18 ist eine Kennung, keine Reihenfolge (siehe unten und 6.1).*

| Nr. | Schritt | Befehl | Anmerkung |
|---|---|---|---|
| D1 | Bau | `make bau` → `uv sync --locked --project backend` · `uv run --locked --project backend python -m compileall -q backend/src` · falls `frontend/package.json` vorhanden: `npm ci --prefix frontend` und `npm run build --prefix frontend` · `docker compose -f deploy/compose.test.yml build` | **Dritte Fortschreibung 2026-08-30:** `--project backend` an beiden `uv`-Aufrufen; Beleg und Begründung in 6.3.1. Ohne die Angabe sucht `uv` das Projekt ausschliesslich aufwärts vom Arbeitsverzeichnis; aus der Repository-Wurzel wird `backend/pyproject.toml` nie gefunden, und `--locked` meldet lediglich "has no effect". Damit wäre der Entscheid der zweiten Fortschreibung wirkungslos geblieben. — **Zweite Fortschreibung 2026-08-30**, Beleg und Begründung in 6.2.1. Bis dahin stand hier `uv sync --frozen` mit der Anmerkung "Sperrdateien sind bindend; `--frozen` schlägt fehl, statt still aufzulösen". Das trug nicht: `--frozen` installiert stumm aus der Sperrdatei und meldet eine Abweichung zwischen `pyproject.toml` und `uv.lock` gerade **nicht**. `--locked` stellt die beabsichtigte Aussage her — die Sperrdatei bleibt unverändert, eine Abweichung endet ungleich 0. `npm ci` verhält sich bereits so und bleibt unverändert |
| D2 | Formatierung | `make format-pruefen` → `uv run --locked --project backend ruff format --check backend` · `npm run format-pruefen --prefix frontend` | |
| D3 | Linter | `make linter` → `uv run --locked --project backend ruff check backend` · `npm run linter --prefix frontend` mit `--max-warnings <Schwelle>` | Schwelle offen, Entscheid E-08 |
| D4 | Typprüfung | `make typen` → `uv run --locked --project backend mypy backend/src backend/tests` · `npm run typen --prefix frontend` | mypy im strengen Modus, null Fehler; das Oberflächenskript ruft den TypeScript-Compiler ohne Ausgabe auf |
| D5 | Testsuite | `make test` → `uv run --locked --project backend pytest -q --strict-markers` · `npm run test --prefix frontend` · `npm run e2e --prefix frontend` | Übersprungene Tests nur mit begründeter Markierung. **Dritte Fortschreibung 2026-08-30:** Das Arbeitsverzeichnis bleibt die Repository-Wurzel (6.3.1); welchen Gegenstand `pytest` ohne Pfadangabe von dort aus einsammelt, ist mit einem ausgeführten Lauf zu belegen (6.3.1, Nachweispflicht) |
| D6 | Abdeckung | `make abdeckung` → `uv run --locked --project backend pytest --cov=backend/src/r3cosint --cov-fail-under=80` und ein zweiter Lauf, ebenfalls mit `uv run --locked --project backend`, `--cov=backend/src/r3cosint/spur --cov=backend/src/r3cosint/zugriff --cov=backend/src/r3cosint/freigabe --cov-fail-under=100` | Die drei Module sind genau die aus D6: Protokoll, Klassifizierung, Freigabesperre. Werte offen, Entscheid E-07. Die Abdeckungsdatei liegt in einem von der Versionsverwaltung ignorierten Pfad (Kettengrundsatz) |
| D7 | Abnahmekriterien | `make abnahme` → `uv run --locked --project backend pytest -q -m abnahme` · `bash scripts/abnahme-abgleich.sh` | Der Abgleich vergleicht die Testnamen des Backlogs mit den gesammelten Testkennungen und meldet jede Anforderung ohne Test (6.6). Eigenes Projektartefakt, entsteht mit dem Grundgerüst. **Dritte Fortschreibung 2026-08-30:** D7 hat keine Lage B mehr — der Backlog samt Abnahmekriterien besteht seit der Freigabe von Schritt 3 dauerhaft. Findet der Schritt ihn nicht, ist das ein Befund und kein bestandener Schritt; Beleg und Begründung in 6.3.2 |
| D8 | Abhängigkeiten | `make abhaengigkeiten` → `uv run --locked --project backend pip-audit --strict` · `npm audit --prefix frontend --audit-level <Schwelle>` | Schwelle offen, Entscheid E-08. Offline setzt eine gespiegelte Schwachstellendatenbank voraus — DevOps |
| D9 | Kein Rückkanal | `make rueckkanal` → `bash scripts/rueckkanal-pruefen.sh` | Eigenes Projektartefakt, entsteht mit R3-C-004. Es gibt dafür kein Standardwerkzeug |
| D10 | Prototyp-Trennung | `make prototyp-trennung` → `bash scripts/prototyp-trennung-pruefen.sh` | **Befund:** Das bestehende `.claude/hooks/block-prototype-import.sh` ist ein `PreToolUse`-Hook und liest ein JSON-Ereignis von der Standardeingabe. Für D10 wird eine Stapelprüfung über den Bestand gebraucht — entweder als Betriebsart des bestehenden Skripts oder als eigenes Skript. Zu klären mit DevOps. **Zweite Fortschreibung 2026-08-30:** Diese Zeile nannte keine Objektbedingung. Das war keine Freiheit der Umsetzung, sondern hiess: der Schritt läuft immer. Damit das nicht wieder ausgelegt werden muss, steht die Bedingung jetzt in der Objekttabelle unterhalb dieser Tabelle; Begründung in 6.2.2 |
| D11 | Geheimnisse | `make geheimnisse` → **zwei Läufe, beide zwingend, jeder mit eigenem Rückgabewert.** (1) Arbeitsbaum: `gitleaks detect --no-git --redact --exit-code 1 --source .` (2) Git-Historie: `gitleaks detect --redact --exit-code 1`. Der Schritt endet ungleich 0, sobald einer der beiden Läufe ungleich 0 endet; kein Lauf schneidet den anderen ab, beide Befunde erscheinen | **Fortschreibung 2026-08-30**, frühere Fassung und Beleg in 6.1. `gitleaks detect` ohne `--no-git` durchsucht ausschliesslich die Git-Historie. Der Gegenstand, über den die Kette zur Laufzeit des Hooks aus R3-Q-001 urteilt, ist der Arbeitsbaum vor dem Commit — genau den sah die frühere Fassung nicht. **Zweite Fortschreibung 2026-08-30:** Die Prüffläche des Arbeitsbaumlaufs ist in 6.2.3 festgelegt — `.gitignore` wirkt auf `--no-git` nicht; deshalb liegen Zugangsdaten nicht im Arbeitsbaum, und ausgeschlossen werden ausschliesslich namentlich genannte Abhängigkeits- und Bauverzeichnisse. O-10 ist in seinem ersten Teil beantwortet und in Abschnitt 8 neu gefasst |
| D12 | Nachweise | `make nachweise` → `bash scripts/nachweise-erzeugen.sh` · `bash scripts/nachweise-vollstaendig.sh` | **Befund:** Ein Abgleich über `git diff --exit-code docs/NACHWEISE.md` kann nicht funktionieren. Die erzeugte Datei trägt den Stand des Repositories (`git rev-parse HEAD`); der ändert sich mit dem Commit, der die Datei enthält, weshalb der nächste Lauf immer eine Abweichung erzeugt. D12 prüft deshalb den Rückgabewert des Erzeugers — er endet mit 1, wenn ein Artefakt fehlt oder nicht committet ist — und zusätzlich, dass kein nachweispflichtiges Artefakt in der Liste fehlt. Zu klären mit Protocol Master und DevOps. **Fortschreibung 2026-08-30:** Der Schritt ruft den Erzeuger ausschliesslich in einer Betriebsart auf, die **nicht** in den Arbeitsbaum schreibt — er prüft und meldet, er erzeugt nicht. Grund ist der Kettengrundsatz unterhalb dieser Tabelle; das Erzeugen von `docs/NACHWEISE.md` bleibt Sache der Automatik (6.6, `.claude/rules/dokumentation.md`). Welche Form diese Betriebsart erhält — eigener Schalter am Erzeuger oder Lauf gegen ein temporäres Ziel mit Vergleich —, bleibt bei O-8 |
| D18 | Architekturverträge | `make architekturvertraege` → `uv run --locked --project backend lint-imports --config backend/importvertraege.toml`. Läuft in der Reihenfolge **nach D4 und vor D5** | **Fortschreibung 2026-08-30**, Begründung in 6.1. Abschnitt 3.5 verlangt diesen Schritt seit dem 2026-08-20 ausdrücklich, die Tabelle führte ihn nicht; Abschnitt 3.12 führt den Importprüfer als eigene Prüfstufe. Er belegt die Verträge aus 4.3 und damit R3-F-014 und R3-F-018. Die Nummer ist die nächste freie im gemeinsamen D-Namensraum — D13 bis D17 sind in `docs/06_Definition_of_Ready_und_Done.md`, Teil 2, an die menschlich bestätigten Bedingungen vergeben. **Zweite Fortschreibung 2026-08-30:** Hier stand die Objektbedingung "Existiert `backend/src/r3cosint/` ohne `backend/importvertraege.toml`, endet der Schritt ungleich 0: dann fehlt das Prüfmittel bei vorhandenem Gegenstand" — und im Absatz "Umgang mit noch nicht vorhandenen Teilbäumen" stand sie ein zweites Mal und anders. Sie steht jetzt einmal, in der Objekttabelle unterhalb dieser Tabelle; Beleg der entstandenen Lücke und Begründung in 6.2.2 |
| D20 | Belege | `make belege` → `bash scripts/belege-pruefen.sh`. Läuft in der Reihenfolge **als erster Schritt, vor D1** | **Achte Fortschreibung 2026-09-01**, Entscheid und Begründung in 6.8. Der Schritt prüft über die versionierten Markdown-Dateien der Wurzel, unter `docs/` und unter `.claude/`, ob Zeilenverweise, Commit-Prüfsummen, Anforderungskennungen, Pfadverweise und Abschnittsangaben des Projektauftrags auf etwas Vorhandenes zeigen, und ob ein Verweis die nach 6.6 unzulässige Zweigform statt der Commit-Prüfsumme verwendet. Er prüft **nicht**, ob der Inhalt am Fundort die Behauptung trägt (6.8.4). Er hat **keine Lage B** (6.8.3). `scripts/belege-ausnahmen.txt` ist Teil des Prüfmittels und trägt ausschliesslich ortsgebundene Schlüssel mit geschriebenem Grund (6.8.5). Das Werkzeug ist nach Eskalationsregel 3.4 abgebrochen und **nicht abgenommen**; die Abnahme ist als O-15 terminiert, die Aufnahme in die Kette hängt nicht an ihr (6.8.4) |

**Ein Prüflauf verändert den Gegenstand nicht, über den er urteilt.** *(Kettengrundsatz, aufgenommen mit der Fortschreibung vom 2026-08-30.)* Kein Kettenschritt ändert eine versionierte Datei des Arbeitsbaums — weder erzeugend noch formatierend noch nebenbei ein Verzeichnis neu schreibend. Erzeugnisse eines Bauschritts (D1) liegen ausschliesslich in Pfaden, die die Versionsverwaltung ignoriert. Drei Gründe, jeder für sich tragend:

1. **Sonst hängt das Ergebnis eines Schrittes davon ab, welcher Schritt vorher lief.** D11 urteilt seit dieser Fortschreibung über den Arbeitsbaum. Ein früher laufender Schritt, der in den Arbeitsbaum schreibt, verändert damit den Gegenstand von D11, und die Kette prüft nicht mehr den Stand, den sie zu prüfen vorgibt.
2. **K4.** Zwei Läufe hintereinander müssen dasselbe Ergebnis liefern. Ein schreibender Schritt macht den zweiten Lauf zu einem Lauf über einen anderen Gegenstand.
3. **Halbfertige Zustände werden nicht committet** (CLAUDE.md, 3.3). Ein Schritt, der schreibt, erzeugt unbemerkte Änderungen und drängt sie in den nächsten Commit — die Prüfung produziert dann genau das, was sie verhindern soll.

Die Einhaltung ist beobachtbar und braucht keine Zusicherung: Der Bestand der versionierten Dateien ist vor und nach `make dod` identisch. Die unmittelbare Folge steht in der Anmerkung zu D12.

**Zweite Fortschreibung vom 2026-08-30 — beobachtbar genügt nicht, beobachtet wird verlangt.** Bis dahin blieb es bei dem Satz oben: Die Einhaltung war beobachtbar, aber von nichts beobachtet, und die Kette selbst verletzte den Grundsatz an ihrer ersten Zeile (Beleg in 6.2.1). Der Grundsatz hängt jetzt an zwei voneinander unabhängigen Massnahmen; keine ersetzt die andere:

1. **Je Schritt vermeidend.** Kein Kettenschritt ruft ein Werkzeug in einer Betriebsart auf, die eine versionierte Datei schreiben kann. Das betrifft namentlich die Sperrdatei `uv.lock`: Jeder Aufruf von `uv` in der Kette trägt `--locked` — `uv sync --locked` in D1 und **jeder** `uv run --locked` in D2 bis D8 und D18, einschliesslich der Verfügbarkeitsproben eines Werkzeugs (`uv run --locked <werkzeug> --version`). Ein einziger Aufruf ohne den Schalter genügt, um die Sperrdatei neu zu schreiben, und er läuft in der Kette immer vor D11 und vor D19. *(Dritte Fortschreibung vom 2026-08-30: Jeder dieser Aufrufe trägt zusätzlich `--project backend`. Ohne die Angabe findet `uv` aus der Repository-Wurzel kein Projekt, und `--locked` bleibt wirkungslos — die Zusicherung dieses Punktes bestünde dann nur auf dem Papier. Beleg und Begründung in 6.3.1.)*
2. **Je Lauf beobachtend.** Die Rahmenprüfung **D19** vergleicht den Bestand vor und nach dem Lauf. Sie fängt auch das, was Punkt 1 nicht vorhersieht — ein Werkzeug, das eine Datei anlegt, an die niemand gedacht hat.

**D19 — Unverändertheit des Arbeitsbaums (Rahmenprüfung von `make dod`).** *(Neu mit der zweiten Fortschreibung vom 2026-08-30.)* D19 ist **kein Kettenschritt in der Zielliste**, sondern eine Eigenschaft von `make dod`. Der Grund ist inhaltlich: Ein Schritt in der Liste sieht nur seinen eigenen Augenblick; der Grundsatz gilt aber für den ganzen Lauf. Ein Schritt kann nicht prüfen, was ein späterer Schritt schreibt. Deshalb klammert D19 den Lauf ein, statt in ihm zu stehen.

| Gegenstand | Festlegung |
|---|---|
| Mittel | `git status --porcelain --untracked-files=all` **und** eine Inhaltsprüfsumme je verfolgter Datei (`git ls-files -z \| xargs -0 sha256sum`), unmittelbar vor dem ersten und unmittelbar nach dem letzten ausgeführten Kettenschritt; verglichen wird die vollständige Aufnahme zeilenweise, einschliesslich der unverfolgten Einträge (`??`). Fortgeschrieben am 2026-08-30, siehe 6.4 |
| Instrument, zweiter Teil | **Die Beobachtbarkeit des Index.** Erhoben wird zusätzlich der Bestand der Maskierungsmerkmale verfolgter Dateien (`git ls-files -v`, Statuszeichen `assume-unchanged` und `skip-worktree`), ebenfalls vor und nach dem Lauf. *(Neunte Fortschreibung 2026-09-01, Begründung in 6.9.)* |
| Massstab | **Zwei verschiedene Massstäbe, je nachdem, was gemessen wird.** Für den **Gegenstand** — den Bestand der Dateien — gilt: Vorher gegen Nachher, **nicht** gegen einen sauberen Arbeitsbaum. Die Kette läuft vor dem Commit und trifft regelmässig einen veränderten Arbeitsbaum an; das ist zulässig — ihn zu verändern ist es nicht. Für das **Instrument** gilt dagegen ein absoluter Massstab: Ein gesetztes Maskierungsmerkmal ist ein Befund, **auch wenn es schon vor dem Lauf gesetzt war**. Ein stummgeschaltetes Messmittel wird nicht dadurch verlässlich, dass es bereits vorher stummgeschaltet war. *(Neunte Fortschreibung 2026-09-01, 6.9.)* |
| Ausgang | Bei Abweichung des Gegenstands endet `make dod` ungleich 0 und nennt die abweichenden Zeilen. Ist das Instrument stummgeschaltet, endet `make dod` ebenfalls ungleich 0, mit **eigenem Befundtext** und als **Lage C** — nicht als Verletzung des Kettengrundsatzes, denn eine Verletzung ist damit gerade nicht festgestellt. Der Befundtext nennt, **welche Hälfte** des Instruments stumm ist und was die andere gemessen hat; er behauptet nicht, der Arbeitsbaum sei unbeobachtet. In beiden Fällen gilt: Der Befund kann einen grünen Lauf rot machen, nie einen roten grün. *(Neunte Fortschreibung 2026-09-01, 6.9; Genauigkeit der Meldung festgelegt mit der zehnten Fortschreibung desselben Tages, 6.10.2.)* |
| Auch bei Abbruch | Die Nachher-Aufnahme läuft auch dann, wenn die Kette an einem Schritt vorher abgebrochen ist. Sonst bliebe gerade der Schritt unbeobachtet, der schreibt und zugleich scheitert |
| Kennung | D19, die nächste freie Nummer im gemeinsamen D-Namensraum. Sie erhält **kein** eigenes `make`-Ziel, weil sie den Lauf einklammert; sie trägt trotzdem eine Nummer, damit Definition of Done, Backlog und Nachweise sie benennen können |

**Folge für `.gitignore`.** Damit D19 nicht an Werkzeugspeichern anschlägt, gehören die Zwischenspeicher der Prüfwerkzeuge in die Ignorierliste — `.pytest_cache/`, `.ruff_cache/`, `.mypy_cache/`, die Abdeckungsdateien und die Berichte der durchgehenden Oberflächenläufe. Heute steht keiner dieser Einträge in `.gitignore` (geprüft am 2026-08-30). Das ist nachzuführen (Abschnitt 9) und zugleich Bedingung dafür, dass der Arbeitsbaumlauf aus D11 nicht in Werkzeugspeichern sucht (6.2.3). Ein Prüfwerkzeug, dessen Zwischenspeicher sich nicht in einen ignorierten Pfad legen lässt, wird nicht durch eine Ausnahme von D19 aufgefangen, sondern ausgetauscht.

**Die Nummer eines Kettenschritts ist eine Kennung, keine Reihenfolge.** *(Aufgenommen mit der Fortschreibung vom 2026-08-30.)* Nummern werden nicht umnummeriert und nicht wiederverwendet; ein neuer Schritt erhält die nächste freie Nummer im gemeinsamen D-Namensraum von `docs/06_Definition_of_Ready_und_Done.md`, Teil 2 (Befehlskette und menschlich bestätigte Bedingungen zählen dort fortlaufend). Die Reihenfolge der Ausführung ergibt sich aus der Zielliste von `make dod`, nicht aus der Zahl. Begründung in 6.1.

**Woran ein Kettenschritt seinen Gegenstand erkennt.** *(Aufgenommen mit der zweiten Fortschreibung vom 2026-08-30; Anlass, Beleg und Begründung in 6.2.2.)* Jeder Kettenschritt urteilt über eine Sache, nicht über einen Verzeichnisnamen. Für jeden Schritt gelten dieselben drei Lagen, und jede hat genau einen Ausgang:

| Lage | Bedingung | Ausgang |
|---|---|---|
| A | Gegenstand vorhanden, Prüfmittel vorhanden | Der Schritt urteilt: 0 oder ungleich 0 |
| B | Gegenstand nicht vorhanden | Der Schritt entfällt **mit Meldung**, Rückgabewert 0 |
| C | Gegenstand vorhanden, Prüfmittel fehlt **oder trägt die Aussage nicht** — es ist unlesbar, unbrauchbar oder stummgeschaltet *(geschärft mit der neunten Fortschreibung vom 2026-09-01, 6.9.2)* | Rückgabewert **ungleich 0**. Ein fehlendes Prüfmittel ist kein bestandener Schritt, und ein vorhandenes, das nicht messen kann, ebenso wenig |

Dazu vier Regeln:

1. **Der Gegenstand wird als Sache benannt, das Erkennungsmerkmal als Beobachtung.** Ein Pfad darf das Merkmal sein, wenn er die tragende Ausprägung des Gegenstands ist — `backend/pyproject.toml` **ist** das erklärte Python-Projekt. Ein Pfad, der nur zufällig danebenliegt, ist es nicht: Ein Verzeichnis `backend/` sagt nichts darüber, ob Python-Code darin steht, und `backend/src/r3cosint/` sagt nichts darüber, ob es Produktionscode unter einem anderen Paketnamen gibt.
2. **Die Objektbedingung steht einmal.** Massgeblich ist ausschliesslich die Tabelle unten. Steht dieselbe Bedingung an einer zweiten Stelle dieses ADR anders, gilt die Tabelle, und die zweite Stelle wird als Fortschreibung berichtigt.
3. **Eine Bedingung wird nicht in der Umsetzung erfunden.** Nennt die Tabelle für einen Schritt keine Lage B, gibt es für ihn keine: Er läuft immer.
4. **Die Lage wird ausgegeben, nicht erschlossen.** Jeder Schritt nennt im Lauf, in welcher Lage er war. Ein Schritt, der mit 0 endet, muss von einem unterscheidbar sein, der nichts geprüft hat.

| Schritt | Gegenstand (die Sache) | Erkennungsmerkmal | Lage B, entfällt mit Meldung | Prüfmittel, dessen Fehlen Lage C ergibt |
|---|---|---|---|---|
| D1 bis D8, Backend-Anteil | Das erklärte Python-Projekt des Backends | `backend/pyproject.toml` vorhanden | Datei fehlt | `uv`; dazu je Schritt das aufgerufene Werkzeug (ruff, mypy, pytest, pytest-cov, pip-audit) |
| D1 bis D8, Oberflächen-Anteil | Das erklärte Projekt der Oberfläche | `frontend/package.json` vorhanden | Datei fehlt | `node` und `npm`; dazu das in `package.json` hinterlegte Skript |
| D1, Stapelbau | Der Prüfstapel Test/Schulung | `deploy/compose.test.yml` vorhanden | Datei fehlt | `docker` samt erreichbarem Daemon |
| D7, zweiter Teil | Die Abnahmekriterien des Backlogs | Eine Datei unterhalb `docs/`, die den Backlog trägt, führt Abnahmekriterien; als Suchmuster `docs/05_Product_Backlog*.md`, nicht der eine Dateiname. Treffen mehrere Dateien zu, werden alle beurteilt und in der Lage-Meldung genannt | **keine** — der Backlog besteht seit der Freigabe von Schritt 3 dauerhaft, der Schritt läuft immer *(dritte Fortschreibung 2026-08-30, 6.3.2; vorher: "keine Abnahmekriterien vorhanden")* | `scripts/abnahme-abgleich.sh`; dazu die Fundstelle selbst: findet das Suchmuster keine Datei oder führt die gefundene keine Abnahmekriterien, endet der Schritt ungleich 0 |
| D9 | Quelltext und Betriebskonfiguration, die eine ausgehende Verbindung öffnen könnten | mindestens eine Datei unterhalb `backend/`, `frontend/` oder `deploy/` | keiner der drei Bäume enthält eine Datei | `scripts/rueckkanal-pruefen.sh` |
| D10 | Die Trennung zwischen `prototype/` und dem Produktionscode, in beide Richtungen | `prototype/` vorhanden | `prototype/` fehlt — tritt nach 5.6 nicht ein, der Schritt läuft also immer | `scripts/prototyp-trennung-pruefen.sh` |
| D11 | Arbeitsbaum und Git-Historie des Repositories | `.git/` vorhanden | kein `.git/` | `gitleaks`; für den Historienlauf zusätzlich `git` *(dritte Fortschreibung 2026-08-30, 6.3.3; vorher stand hier allein `gitleaks`)* |
| D12 | Die nachweispflichtigen Artefakte nach 6.6 | `docs/` vorhanden — Bestandteil des Repositories, der Schritt läuft immer | tritt nicht ein | `scripts/nachweise-erzeugen.sh`, `scripts/nachweise-vollstaendig.sh` |
| D18 | **Python-Produktionscode unterhalb `backend/src/`, unabhängig davon, wie das Paket heisst** | mindestens eine `*.py`-Datei unterhalb `backend/src/` | keine `*.py`-Datei unterhalb `backend/src/` | `backend/importvertraege.toml`; `lint-imports` |
| D19 | Der Bestand der versionierten Dateien über die Dauer eines Laufs von `make dod` | Die Versionsverwaltung meldet einen Arbeitsbaum; ist `git` nicht ausführbar, hilfsweise die blosse Anwesenheit von `.git` — **als Datei oder als Verzeichnis**, weil `.git` in einem zusätzlichen Arbeitsbaum und in einem Untermodul eine Datei ist *(neunte Fortschreibung 2026-09-01, 6.9.3; vorher stand hier "`.git/` vorhanden")* | kein Arbeitsbaum und kein `.git` | `git`; dazu die **Beobachtbarkeit des Index**: Ist für eine verfolgte Datei `assume-unchanged` oder `skip-worktree` gesetzt, ist das Prüfmittel stummgeschaltet, und das ist Lage C *(neunte Fortschreibung 2026-09-01, 6.9.2)* |
| D20 | **Die Herkunfts- und Fundortangaben in den versionierten Markdown-Dateien des Repositories** — Wurzel, `docs/` und `.claude/` | Mindestens eine versionierte Markdown-Datei dieser Prüffläche, festgestellt über die Versionsverwaltung und nicht über einen Verzeichnisnamen | **keine** — der Bestand kann nicht leer sein, und ein leerer Bestand wäre ein Befund und kein leerer Gegenstand *(achte Fortschreibung 2026-09-01, 6.8.3)* | `scripts/belege-pruefen.sh` und `scripts/belege-ausnahmen.txt`; `bash`, `git`, `grep`, `sed`, `awk`; dazu die beiden Bezugsdokumente `docs/05_Product_Backlog.md` und `docs/00_Projektauftrag.md`, aus denen der Prüfer seine Referenzmengen bildet. Fehlt eines davon, ist das Lage C — nicht ein bestandener Schritt (6.8.3). Dazu die **Vollständigkeit der Git-Historie**: Ist der Klon flach (`git rev-parse --is-shallow-repository` meldet wahr), trägt die lokale Historie die Aussage über Commit-Prüfsummen nicht, und das ist nach der geschärften Bedingung Lage C mit dem Beschaffungsweg `git fetch --unshallow` *(zwölfte Fortschreibung 2026-09-02, 6.12.17 — **Bau auf Weisung vom 2026-09-02 begonnen, förmliche Freigabe ausstehend**; bis zur Freigabe gilt die Zeile ohne diesen Satz)* |

Zwei Anmerkungen zu dieser Tabelle:

- **Zu D6.** Die Abdeckungspfade folgen dem Modulbaum aus 4.1 — `backend/src/r3cosint/`, darin `spur`, `zugriff` und `freigabe`. Weicht ein Paketname davon ab, ist das ein Verstoss gegen 4.1 und A13 und wird dort behoben, nicht durch eine Lockerung des Pfades in der Kette. Der Schritt darf an einem falsch benannten Paket scheitern; er darf ihn nicht stillschweigend auslassen.
- **Zu D18.** Die Vertragsdatei nennt jedes oberste Paket unterhalb `backend/src/` als Wurzelpaket. Sonst liefe der Prüfer an vorhandenem Produktionscode vorbei und meldete Lage A, obwohl er nichts beurteilt hat. Wo dieser Abgleich sitzt — im Aufruf oder als Vertrag im Prüfer selbst —, entscheidet der DevOps Engineer. **Dritte Fortschreibung 2026-08-30:** Dieser Abgleich ist heute nicht gebaut, weil `backend/importvertraege.toml` noch nicht besteht; im Makefile steht er als Kommentar. Damit er mit dem Grundgerüst nicht vergessen wird, ist er als **O-11** in Abschnitt 8 terminiert — ein Kommentar ist keine Prüflogik, und für ihn gilt derselbe Satz wie für die auskommentierte Prüfung unten: Er bleibt still liegen, nachdem er gebraucht würde (6.3.4).

**Zwei Ebenen der Namensbindung.** Die Backend-Befehle stehen unmittelbar im Makefile, die Oberflächenbefehle laufen über Skripte in `frontend/package.json`. Damit steht jeder Werkzeugname genau einmal und an der Stelle, an der er hingehört; die Kette selbst bleibt unverändert, wenn ein Werkzeug ausgetauscht wird.

**Ein Einstieg für den Hook.** `make dod` ruft **alle Kettenschritte dieser Tabelle** in der festgelegten Reihenfolge auf — D1 bis D4, dann D18, dann D5 bis D12 — und endet bei der ersten Abweichung ungleich 0. *(Achte Fortschreibung 2026-09-01: Die Reihenfolge beginnt neu mit **D20**, also D20, D1 bis D4, D18, D5 bis D12. Begründung in 6.8.2.)* *(Bis zur Fortschreibung vom 2026-08-30 lautete dieser Satz: "ruft D1 bis D12 der Reihe nach auf". Die Aufzählung war dort zugleich die Reihenfolge; mit D18 gilt das nicht mehr.)* Der Hook aus R3-Q-001 ruft **diesen einen Befehl** auf. Damit hängt R3-Q-001 nur noch am Vorhandensein des Makefiles und nicht mehr an einzelnen Werkzeugnamen; ändert sich ein Werkzeug, ändert sich das Makefile, nicht der Hook. Für den Hook gelten unverändert: nur Rückgabewert 2 blockiert, Reentranz-Schutz über `stop_hook_active`, Eskalation nach dreimaligem Scheitern am gleichen Kriterium (3.4). *(Zweite Fortschreibung 2026-08-30: Die Rahmenprüfung D19 gehört zu `make dod`, steht aber nicht in der Zielliste. Sie nimmt vor dem ersten Schritt auf, vergleicht nach dem letzten ausgeführten Schritt und läuft auch dann, wenn die Kette vorher abgebrochen ist.)*

**Umgang mit noch nicht vorhandenen Teilbäumen.** *(Überholt durch die Objekttabelle oben, zweite Fortschreibung vom 2026-08-30. Der Absatz bleibt als frühere Fassung stehen. Seine Aussage zu `frontend/package.json` ist in die Tabelle übernommen; seine Aussage zu D18 ist durch sie ersetzt, weil sie der D18-Zeile derselben Tabelle widersprach — Beleg in 6.2.2. Der Satz zur auskommentierten Prüfung gilt unverändert und für alle Schritte.)* Solange `frontend/package.json` fehlt, entfallen die Oberflächenschritte und der Kettenschritt endet mit 0 und einer Meldung. Sobald die Datei existiert, laufen sie zwingend. Das ist als Bedingung im Makefile zu prüfen und nicht als auskommentierte Zeile abzubilden — eine auskommentierte Prüfung bleibt still liegen, nachdem sie gebraucht würde. Dasselbe gilt für D18 gegenüber dem Backend-Teilbaum, mit der Verschärfung aus der Tabelle: Fehlt `backend/` ganz, entfällt der Schritt mit Meldung; existiert `backend/src/r3cosint/` ohne `backend/importvertraege.toml`, endet er ungleich 0.

### 6.1 Fortschreibung vom 2026-08-30 — was vorher galt, was jetzt gilt, weshalb

**Anlass.** Beim Bau des Makefiles nach diesem Abschnitt hat eine adversarische Prüfung auf einem anderen Modell (3.4) zwei Mängel **an diesem ADR** belegt, nicht am Makefile: Das Makefile setzte den Wortlaut jeweils korrekt um, der Wortlaut trug nicht. Beide Mängel werden hier aufgelöst; die früheren Fassungen bleiben im Text stehen, weil ein Nachweisdokument, dessen Irrtum verschwindet, als Nachweis untauglich ist.

#### 6.1.1 D11 prüfte den falschen Gegenstand

| | |
|---|---|
| **Vorher galt** | `make geheimnisse` → `gitleaks detect --redact --exit-code 1` |
| **Jetzt gilt** | Zwei Läufe, beide zwingend, jeder mit eigenem Rückgabewert: Arbeitsbaum `gitleaks detect --no-git --redact --exit-code 1 --source .`, Git-Historie `gitleaks detect --redact --exit-code 1` |

**Beleg.** Ausgeführter Lauf am 2026-08-30 mit gitleaks 8.21.2: Ein RSA-Privatschlüssel, als nicht committete Datei im Arbeitsbaum abgelegt, wurde von `gitleaks detect --redact --exit-code 1` **nicht** gefunden; `gitleaks detect --no-git --redact --exit-code 1 --source .` fand ihn und endete mit 1. `gitleaks detect` ohne `--no-git` durchsucht ausschliesslich die Git-Historie.

**Weshalb das den Regelfall trifft und nicht den Randfall.** Der Hook aus R3-Q-001 läuft als `Stop` beziehungsweise `SubagentStop`, also **vor** dem Commit; CLAUDE.md untersagt zugleich das Committen halbfertiger Zustände. Der Gegenstand, über den die Kette zum Zeitpunkt ihres Laufs urteilt, ist damit systematisch der Arbeitsbaum. Ein Schlüssel, der dort liegt und noch nicht committet ist, ist genau der Fall, den ein Gate vor dem Commit abfangen soll — und der einzige, in dem das Abfangen noch etwas nützt. Ist das Geheimnis erst in der Historie, hilft kein Prüflauf mehr, sondern nur noch der Austausch des Geheimnisses; die Historie wird in diesem Projekt nicht umgeschrieben.

**Weshalb dennoch beide Gegenstände geprüft werden.** Der Lauf über die Historie fällt nicht weg. Er ist der einzige, der einen Fund aus einem früheren Commit meldet — etwa aus einem übernommenen Zweig oder aus der Zeit vor dem Bestehen dieser Kette. Ein Gate, das nur den Arbeitsbaum sieht, erklärt ein Repository für sauber, dessen dritter Commit einen Schlüssel trägt.

**Geprüfte Teilfragen des Vorschlags:**

1. **Ändert `--source .` gegenüber dem Vorgabewert etwas?** Am Verhalten nichts: Der Vorgabewert des Quellpfads ist das aktuelle Arbeitsverzeichnis. Aufgenommen wird die Angabe trotzdem, aus zwei Gründen. Erstens hängt die Aussage des Schrittes damit nicht mehr an einer ungeschriebenen Annahme über das Arbeitsverzeichnis, aus dem `make` gestartet wurde. Zweitens stehen die beiden Aufrufe unmittelbar nebeneinander; ihr Unterschied muss aus der Zeile lesbar sein, ohne dass man den Vorgabewert eines Werkzeugs kennt. Verbindlich ist: Beide Läufe beurteilen dieselbe Wurzel, nämlich das Repository-Verzeichnis.
2. **Wird ein `.gitleaksignore` nötig?** Nicht als Bestandteil dieses Entscheids und nicht auf Vorrat. Eine Ausnahmeliste entsteht ausschliesslich zu einem **belegten** Fehlalarm, je Eintrag mit Fundstelle und Begründung; eine pauschale Ausnahme für ein Verzeichnis oder eine Regel ist unzulässig, weil sie das Gate stillschweigend abschaltet. Dabei ist zu beachten, dass der Fingerabdruck eines Fundes für beide Läufe **verschieden** ist: Der Lauf über die Historie bildet ihn aus Commit, Datei, Regel und Zeile, der Lauf über den Arbeitsbaum ohne den Commit-Anteil. Eine Ausnahme, die in einem Lauf greift, greift im anderen nicht — auch das ist ein Grund, sie nur im belegten Einzelfall zu setzen und zu dokumentieren.
3. **Spielt die Reihenfolge der beiden Aufrufe eine Rolle?** Für die Aussage des Schrittes nicht, weil kein Lauf den anderen abschneidet: Beide laufen immer, beide Befunde erscheinen, und der Schritt endet ungleich 0, sobald einer ungleich 0 endete. Festgelegt wird sie dennoch — Arbeitsbaum zuerst —, damit die Ausgabe bei zwei Befunden immer gleich zu lesen ist und der Befund zuoberst steht, der vor dem Commit noch abwendbar ist. Ein Abbruch nach dem ersten Fund wäre ein Fehler: Dann bliebe der zweite Gegenstand ungeprüft, und der Schritt urteilte wieder nur über die Hälfte.

**Befund für den DevOps Engineer (neu als O-10 in Abschnitt 8).** Der Lauf über den Arbeitsbaum sieht auch Dateien, die die Versionsverwaltung nie aufnimmt — Bauerzeugnisse, Abhängigkeitsverzeichnisse, lokale Konfiguration. Welche Menge er beurteilt und wie er sich gegenüber `.gitignore` verhält, ist mit einem ausgeführten Lauf festzustellen und festzuhalten, nicht anzunehmen. Massgeblich ist der Grundsatz: Geprüft wird, was das Repository tragen kann; ausgeschlossen wird nur, was die Versionsverwaltung ohnehin nicht aufnimmt, und auch das nachvollziehbar.

**Hinweis zur Werkzeugfassung.** Festgelegt sind hier die beiden **Gegenstände** — Arbeitsbaum und Historie —, nicht die Schreibweise eines Unterbefehls. Führt die eingesetzte gitleaks-Fassung eigene Unterbefehle für Verzeichnis- und Historienlauf und kennzeichnet `detect` als überholt, ist der Wechsel zulässig, sobald ein ausgeführter Lauf die Gleichwertigkeit belegt; er wird als Fortschreibung vermerkt. Ein Wechsel, der einen der beiden Gegenstände fallen lässt, ist keine Fassungsanpassung, sondern eine Änderung dieses Entscheids.

#### 6.1.2 Der Kettenschritt für die Architekturverträge fehlte in der eigenen Tabelle

| | |
|---|---|
| **Vorher galt** | Abschnitt 3.5 verlangte den Importprüfer ausdrücklich "als eigener Kettenschritt", Abschnitt 3.12 führte ihn als eigene Prüfstufe — die Tabelle in Abschnitt 6 kannte ihn nicht. Ein Widerspruch innerhalb desselben angenommenen ADR |
| **Jetzt gilt** | D18 `make architekturvertraege` → `uv run lint-imports --config backend/importvertraege.toml`, in der Reihenfolge nach D4 und vor D5 *(seit der zweiten Fortschreibung desselben Tages `uv run --locked lint-imports`, 6.2.1)* |

**Weshalb ein eigener Schritt und keine Zuordnung zu einem bestehenden.** Die nächstliegende Alternative wäre gewesen, die Verträge als Tests unter `backend/tests/architektur/` in D5 laufen zu lassen und die Aussage in 3.5 zurückzunehmen. Dagegen sprechen drei Punkte:

1. **Eigener Rückgabewert für die stärkste Garantie.** Die Verträge aus 4.3 sind die Stelle, an der die Freigabesperre (5.2, R3-F-014) und die Modellunabhängigkeit (5.15, R3-F-018) als Struktur belegt werden. D5 erlaubt übersprungene Tests mit begründeter Markierung; ein übersprungener Vertragstest wäre ein abgeschalteter Verfahrensgarantie-Nachweis mit grünem Lauf. Ein eigener Schritt kann nicht übersprungen werden, ohne dass die Kette rot wird.
2. **Gleichbehandlung der Prüfstufen.** Jede Prüfstufe aus 3.12 hat einen eigenen Kettenschritt — Formatierung D2, Linter D3, Typprüfung D4, Tests D5, Abhängigkeiten D8, Geheimnisse D11. Der Importprüfer war die einzige Ausnahme, ohne dass ein Grund dafür genannt war.
3. **Er läuft früher und schneller als die Testsuite.** Ein Verstoss gegen eine Modulgrenze ist eine Aussage über die Struktur; sie soll vor dem Lauf der Testsuite fallen, nicht nach ihm. Deshalb die Stellung nach D4 und vor D5.

**Weshalb die Nummer 18 und keine Umnummerierung.** D13 bis D17 sind in `docs/06_Definition_of_Ready_und_Done.md`, Teil 2, an die menschlich bestätigten Bedingungen vergeben; `docs/08_Freigabe_Schritt_4.md` führt beide Tabellen ausdrücklich als einen Bereich ("D1–D12 plus die menschlich bestätigten Bedingungen D13–D17"). Ein Schritt "D13" wäre also eine Kollision, und ein Einschub als neues D5 würde D5 bis D12 verschieben. Der entscheidende Grund gegen jede Verschiebung: Die D-Nummern stehen in Dokumenten, die einen vergangenen Stand belegen und deshalb **nicht** geändert werden dürfen — Freigabevermerk vom 2026-08-20, Zustandsbericht vom 2026-08-21, die Übergabedateien. Eine Umnummerierung würde diese Nachweise falsch machen, ohne dass sie korrigierbar wären. Daraus folgt die Regel oberhalb: Nummern sind Kennungen, sie werden nicht umnummeriert und nicht wiederverwendet, und die Reihenfolge steht in der Zielliste von `make dod`.

**Was das für die Tragfähigkeit der Nummerierung heisst.** Sie trägt, sobald die Nummer nicht mehr als Reihenfolge gelesen wird. Jeder weitere Kettenschritt erhält die nächste freie Nummer (nach D18 also D19) und seine Stellung in der Kette über den Zielnamen. Die Zielnamen — `bau`, `linter`, `typen`, `architekturvertraege` — sind die Handhabe im Makefile; die Nummern bleiben die Handhabe für Verfolgbarkeit, Backlog und Definition of Done.

**Nicht berührt.** Der Vertrag 7 aus 4.3 (Trennung zu `prototype/`) bleibt zusätzlich Gegenstand von D10. Die Überschneidung ist beabsichtigt: zwei unabhängige Wege zur selben Aussage, ein Vertrag über den geschriebenen Stand und eine Stapelprüfung über den Bestand.

#### 6.1.3 Der Kettengrundsatz

| | |
|---|---|
| **Vorher galt** | Kein Satz dieses ADR sagte, dass ein Prüflauf den Arbeitsbaum unverändert lässt. D12 rief den Erzeuger des Nachweisverzeichnisses auf, der `docs/NACHWEISE.md` schreibt |
| **Jetzt gilt** | Der Grundsatz oberhalb dieses Unterabschnitts, und als Folge die geänderte Anmerkung zu D12: prüfende Betriebsart, kein Schreiben in den Arbeitsbaum |

**Weshalb er in Abschnitt 6 gehört und nicht in eine Betriebsanweisung.** Er ist keine Umsetzungsfrage, sondern eine Eigenschaft der Kette: Ohne ihn hängt das Ergebnis eines Schrittes davon ab, welcher Schritt vorher lief. Mit der Fortschreibung zu D11 wird das unmittelbar wirksam — D11 urteilt jetzt über den Arbeitsbaum, also darf kein Schritt vor D11 diesen Arbeitsbaum verändern. Ein Grundsatz, der in einer Betriebsanweisung stünde, wäre für die Umsetzung derselbe Satz, aber er wäre nicht Bestandteil des Entscheids, gegen den geprüft wird.

**Er war an einer Stelle bereits umgesetzt, nur nicht benannt.** D2 ruft `ruff format --check` und nicht `ruff format`, prüft also, statt zu formatieren. Der Grundsatz macht aus dieser einen richtigen Entscheidung eine Regel für alle Schritte.

**Abgrenzung.** Der Grundsatz verbietet nicht jedes Schreiben. Ein Bauschritt erzeugt Artefakte; das ist seine Aufgabe. Verboten ist die Änderung **versionierter** Dateien. Erzeugnisse liegen in Pfaden, die die Versionsverwaltung ignoriert — was zugleich Bedingung dafür ist, dass der Arbeitsbaumlauf aus D11 nicht in Bauerzeugnissen sucht.

#### 6.1.4 Was diese Fortschreibung nicht ändert

D1 bis D10 und D12 bleiben im Befehl unverändert; bei D12 ändert sich ausschliesslich die Betriebsart des Aufrufs, der Befund zum untauglichen `git diff`-Abgleich bleibt bestehen. Die Werkzeugwahl aus 3.12 bleibt unverändert. Die offenen Schwellenwerte (O-7) und die offenen Formfragen zu D10 und D12 (O-8) bleiben offen. Die drei am Makefile festgestellten Mängel, die diesen ADR nicht berühren — nicht ausgewertete Lage-Marke von `make dod`, falsche Lage-Zuordnung bei D9, schreibender D12-Lauf in seiner Makefile-Umsetzung —, behebt der DevOps Engineer in derselben Arbeitseinheit; der ADR-seitige Anteil des dritten Punktes ist 6.1.3.

### 6.2 Zweite Fortschreibung vom 2026-08-30 — was vorher galt, was jetzt gilt, weshalb

**Anlass.** Eine abschliessende adversarische Prüfung auf einem anderen Modell (3.4) hat nach der ersten Fortschreibung desselben Tages (Commit `84450a71569120e8deb30ecb0349ea8a92f6d736`) drei weitere Mängel **an diesem ADR** belegt — den ersten davon am neu aufgenommenen Kettengrundsatz selbst. Wie bei der ersten Fortschreibung bleiben die früheren Fassungen im Text stehen.

#### 6.2.1 Die Kette schrieb die Sperrdatei, über die sie urteilt

| | |
|---|---|
| **Vorher galt** | D1 `uv sync --frozen`, Anmerkung "Sperrdateien sind bindend; `--frozen` schlägt fehl, statt still aufzulösen"; D2 bis D8 und D18 `uv run <werkzeug>` **ohne** Schalter |
| **Jetzt gilt** | D1 `uv sync --locked`; jeder `uv run`-Aufruf der Kette mit `--locked`, einschliesslich der Verfügbarkeitsproben; dazu die Rahmenprüfung D19, die den Bestand vor und nach dem Lauf vergleicht |

**Beleg**, ausgeführter Lauf am 2026-08-30 mit der vollständigen Kette:

```
$ git status --short          ->  ?? Makefile
$ <Abhaengigkeit in pyproject.toml ergaenzt, uv.lock nicht neu erzeugt>
$ make -s dod
::LAGE D1 bau A_OK::          <- uv sync --frozen laeuft durch, es prueft die Drift nicht
$ git status --short
 M pyproject.toml
 M uv.lock                    <- versionierte Datei, durch den Prueflauf geaendert
```

`uv.lock` ist nicht in `.gitignore` (`git check-ignore` endet mit 1) und laut der D1-Zeile bindend, also versioniert. Der erste `uv run`-Aufruf nach einer Abweichung zwischen `pyproject.toml` und `uv.lock` schreibt sie neu. Damit verletzte die Kette den Grundsatz aus 6.1.3 an ihrer eigenen zweiten Zeile — und zwar im Regelfall, nämlich immer dann, wenn jemand eine Abhängigkeit ergänzt und der Stop-Hook läuft. Verschärfend trifft es D11: Seit der ersten Fortschreibung urteilt D11 über den Arbeitsbaum, und alle `uv run`-Schritte laufen vor D11.

**Geprüfte Teilfragen des Vorschlags:**

1. **Hat `--frozen` bei `uv run` dieselbe Bedeutung wie bei `uv sync`?** Für die Sperrdatei ja: Beide Aufrufe lassen sie unangetastet und lösen nicht neu auf. Der Vorschlag würde das Schreiben also tatsächlich beenden. Er greift trotzdem zu kurz, weil `--frozen` bei beiden Befehlen auch **nicht meldet**: Es installiert und läuft stumm gegen einen möglicherweise veralteten Stand. Genau das war schon der Fehler der bisherigen D1-Anmerkung, die `--frozen` ein Scheitern zuschrieb, das es nicht leistet. Ein Prüflauf, der gegen einen anderen Abhängigkeitsstand läuft als den erklärten, verletzt K4 und behauptet eine Reproduzierbarkeit, die er nicht hat.
2. **Was leistet `--locked` stattdessen?** Es sagt zu, dass die Sperrdatei unverändert bleibt, **und** endet ungleich 0, wenn sie es nicht bliebe. Beide Eigenschaften werden gebraucht: die erste für den Kettengrundsatz, die zweite für die Aussage der D1-Zeile. Deshalb `--locked` und nicht `--frozen` — an beiden Befehlen, damit in der Kette kein zweiter Schalter mit anderer Bedeutung steht. Die Wirkung im Überblick: ohne Schalter — schreibt, meldet nicht; `--frozen` — schreibt nicht, meldet nicht; `--locked` — schreibt nicht, meldet.
3. **Warum nicht zusätzlich das Herstellen der Umgebung unterbinden?** Weil die Umgebung in `.venv/` liegt und dieser Pfad von der Versionsverwaltung ignoriert wird; der Grundsatz verbietet ausschliesslich die Änderung versionierter Dateien (6.1.3, Abgrenzung). Ein Unterbinden machte jeden Schritt zusätzlich davon abhängig, dass vorher jemand D1 ausgeführt hat — eine ungeschriebene Vorbedingung, die genau die Art Abhängigkeit zwischen Schritten erzeugt, die der Grundsatz beseitigen soll.
4. **Gilt dasselbe für die Oberfläche?** Dort ist es bereits erfüllt und bleibt unverändert: `npm ci` verweigert den Lauf bei Abweichung zwischen `package.json` und `package-lock.json` und schreibt die Sperrdatei nicht — das ist die Entsprechung zu `--locked`. `npm audit` schreibt nicht; `npm audit fix` täte es und kommt in der Kette nicht vor. `npm run build` schreibt nach `frontend/dist/`, und `dist/` ist ignoriert.
5. **Soll die Nachprüfung ein Kettenschritt werden oder eine Eigenschaft von `make dod`?** Eine Eigenschaft von `make dod`, geführt als D19. Drei Gründe: Ein Schritt in der Zielliste sieht nur seinen eigenen Augenblick und könnte nicht beurteilen, was ein späterer Schritt schreibt. Ein Schritt am Ende der Liste liefe bei einem früheren Abbruch gar nicht — also gerade dann nicht, wenn ein Schritt schreibt und scheitert. Und ein Schritt in der Liste unterläge selbst der Reihenfolgeabhängigkeit, die er aufdecken soll. Eine Nummer erhält er trotzdem, damit Definition of Done, Backlog und Nachweise ihn benennen können.
6. **Ersetzt D19 die Schalter?** Nein, und umgekehrt auch nicht. `--locked` verhindert den häufigsten Fall, bevor er eintritt, und nennt seine Ursache; D19 fängt jeden Fall, an den niemand gedacht hat, kann aber nur feststellen **dass** etwas geschrieben wurde. Beide Massnahmen bleiben.

**Nachweispflicht.** Die Wirkung der Schalter ist hier aus der dokumentierten Bedeutung der Werkzeuge begründet, nicht aus einem eigenen Lauf: Diese Rolle hat kein Ausführungswerkzeug und prüft ihre eigene Arbeit ohnehin nicht (3.4). Zu belegen ist mit einem ausgeführten Lauf, jeweils mit künstlich erzeugter Abweichung zwischen `pyproject.toml` und `uv.lock`: (a) `uv sync --locked` und `uv run --locked <werkzeug>` enden ungleich 0, (b) `uv.lock` ist danach unverändert, (c) `make dod` meldet über D19 keine Abweichung im Arbeitsbaum, (d) die Aktualitätsprüfung von `--locked` kommt ohne ausgehende Verbindung aus (K3). Zuständig sind DevOps Engineer und die Testerrollen.

#### 6.2.2 Die Objektbedingung stand zweimal verschieden, und D10 hatte gar keine

| | |
|---|---|
| **Vorher galt** | Die D18-Zeile knüpfte Lage C an "Existiert `backend/src/r3cosint/` ohne `backend/importvertraege.toml`"; der Absatz "Umgang mit noch nicht vorhandenen Teilbäumen" nannte als Lage-B-Auslöser "Fehlt `backend/` ganz". D10 nannte keine Bedingung |
| **Jetzt gilt** | Eine allgemeine Regel, woran ein Kettenschritt seinen Gegenstand erkennt, samt einer Objekttabelle für alle Schritte — an genau einer Stelle in diesem ADR. D18 knüpft an Python-Produktionscode unterhalb `backend/src/`, unabhängig vom Paketnamen. D10 läuft, solange `prototype/` besteht |

**Beleg**, ausgeführter Lauf am 2026-08-30: Bei Produktionscode unter `backend/src/r3cosint_api/` — `backend/` vorhanden, `backend/src/r3cosint/` nicht — liefen D1 bis D4 als bestanden, und D18 meldete Lage B mit Rückgabewert 0. Die Architekturverträge blieben also ungeprüft, obwohl Produktionscode vorlag. Dass der Lauf trotzdem nicht grün wurde, lag allein an einem fest verdrahteten Abdeckungspfad in D6 — ein Zufall, kein Entwurf.

**Weshalb die Sache und nicht der Paketname.** Die Namensgebung aus 4.1 und A13 bleibt verbindlich; `backend/src/r3cosint/` ist der vorgeschriebene Ort. Aber ein Kettenschritt darf nicht davon abhängen, dass genau die Regel eingehalten ist, deren Einhaltung er mit absichern soll. Ein Verstoss gegen die Namensgebung muss die Prüfung **auslösen**, nicht abschalten. Deshalb erkennt D18 seinen Gegenstand an dem, was er ist — Python-Quelltext unterhalb der Bauwurzel `backend/src/` —, und die Vertragsdatei nennt jedes dort vorhandene oberste Paket als Wurzelpaket. Ein Paket, das die Vertragsdatei nicht nennt, ist damit ein Befund und kein blinder Fleck.

**Weshalb D10 immer läuft.** Denkbar wäre gewesen, D10 an das Vorhandensein von Produktionscode zu knüpfen; heute gäbe das Lage B, weil noch kein Produktionscode besteht. Dagegen sprechen drei Punkte. Erstens wechselte die Lage dann in dem Augenblick still, in dem die erste Produktionsdatei entsteht — ein Zustandswechsel, den niemand beobachtet, und genau das Muster, das bei D18 zum Befund geführt hat. Zweitens ist der Gegenstand von D10 die **Trennung** und nicht der Produktionscode; `prototype/` besteht nach 5.6 dauerhaft, und die Stapelprüfung urteilt über den Bestand. Drittens ist "ich kann das nicht beurteilen, das Prüfmittel fehlt" die ehrlichere Aussage als "es gibt nichts zu beurteilen". Praktisch ändert das an der Farbe der Kette heute nichts: D7, D11 und D12 stehen ohnehin in Lage C, solange ihre Skripte und Werkzeuge fehlen.

**Das gemeinsame Muster.** Die adversarische Prüfung hat es benannt: *Die Lage wird an einem Pfadnamen festgemacht statt am Gegenstand.* Es trat in beide Richtungen auf — der ADR liess die Bedingung bei D10 offen und die Umsetzung erfand eine; bei D18 nannte der ADR sie zweimal verschieden. Beides hat dieselbe Ursache: Die Objektbestimmung war nirgends grundsätzlich geregelt. Deshalb steht die Regel jetzt einmal in Abschnitt 6, vor der Aufzählung der Einzelfälle, und nicht je Schritt verstreut.

#### 6.2.3 Prüffläche des Arbeitsbaumlaufs in D11 — O-10 in seinem ersten Teil beantwortet

| | |
|---|---|
| **Vorher galt** | O-10 liess offen, welche Dateien der Arbeitsbaumlauf beurteilt und wie er sich gegenüber `.gitignore` verhält |
| **Jetzt gilt** | Die Frage ist beantwortet — `.gitignore` wirkt nicht — und die Folge ist entschieden: Zugangsdaten liegen nicht im Arbeitsbaum; ausgeschlossen werden ausschliesslich namentlich genannte Abhängigkeits- und Bauverzeichnisse. O-10 bleibt für zwei Restfragen offen |

**Beleg**, ausgeführter Lauf am 2026-08-30 mit gitleaks 8.21.2:

```
$ git check-ignore -v geheim.pem   ->  .gitignore:21:*.pem  geheim.pem
$ gitleaks detect --no-git --redact --exit-code 1 --source .   ->  leaks found: 1, rc=1
$ make -s geheimnisse              ->  ::LAGE D11 geheimnisse A_FAIL::, rc=2
```

Eine lokale, niemals committierbare `.env` oder ein `*.pem` blockiert damit die gesamte Kette und den künftigen Stop-Hook dauerhaft.

**Optionen.**

| Option | Bewertung |
|---|---|
| (a) Ausnahme je Fundstelle über `--gitleaks-ignore-path` | Für **committeten** Inhalt richtig und bereits geregelt (6.1.1, Punkt 2). Für eine lokale Zugangsdatei untauglich: Der Fingerabdruck hängt am Inhalt, ändert sich mit jedem Wechsel des Geheimnisses, ist in den beiden Läufen verschieden, und er müsste versioniert werden — eine Datei, die für jeden anderen Arbeitsplatz bedeutungslos ist und den Eintrag zum Dauerrauschen macht |
| (b) Pfadausschluss je Fundstelle mit Begründung | Für Abhängigkeits- und Bauverzeichnisse tragfähig, weil dort niemals Repository-Inhalt liegt. Für `.env` und `*.pem` unzulässig: Das sind genau die Pfade mit dem höchsten Wert, und ein Ausschluss schaltete das Gate für sie stillschweigend ab |
| (c) Trennung zwischen "blockiert" und "meldet" | Abgelehnt. Eine Meldung, die nicht blockiert, wird in einem Stop-Hook nicht gelesen. 5.4 verlangt Bauvorschriften, die im Betrieb nicht abschaltbar sind; eine abgestufte Wirkung ist eine Abschaltung mit besserem Namen |
| (d) Zugangsdaten liegen ausserhalb des Arbeitsbaums | Nimmt dem Problem die Ursache, statt das Gate zu schwächen. Kein Ausschluss, keine Ausnahmeliste, kein Verlust an Prüffläche — es gibt schlicht nichts zu finden. Setzt eine Betriebsanweisung und eine Stelle in der Betriebsdokumentation voraus |
| (e) Pauschaler Ausschluss alles von `.gitignore` Erfassten | Abgelehnt. Er höbe den Gewinn der ersten Fortschreibung wieder auf: Ein Schlüssel im Arbeitsbaum ist für die Versionsverwaltung unsichtbar, also sieht ihn der Historienlauf nie — der Arbeitsbaumlauf ist der **einzige**, der ihn sieht. Wer ihn ausschliesst, prüft doppelt dieselbe Hälfte |

**Entscheid.** (d) als Regel, (b) eng begrenzt als Mittel, (a) unverändert für belegte Fehlalarme an committetem Inhalt, (c) und (e) abgelehnt. Im Einzelnen:

1. **Zugangsdaten und Geheimnisse liegen nicht im Arbeitsbaum** — auch nicht in einer von der Versionsverwaltung ignorierten Datei. Das schärft A11 ("Geheimnisse kommen als eingehängte Dateien, nie in ein Image, nie ins Repository") um den Fall, den A11 nicht ausdrücklich nannte: Das Repository-Verzeichnis ist auch dann der falsche Ort, wenn die Datei nicht committet wird. Die Dateien unter `deploy/konfiguration/{test,produktion}/` sind nach Abschnitt 5 ohnehin Beispieldateien ohne Geheimnisse; die tatsächlichen Werte kommen von ausserhalb des Arbeitsbaums. Damit ist ein Fund im Arbeitsbaum immer ein Befund und nie ein Betriebszustand.
2. **Ausgeschlossen wird ausschliesslich, was kein Repository-Inhalt sein kann** — Abhängigkeits- und Bauverzeichnisse (`node_modules/`, `.venv/`, `dist/`, `build/`, die Zwischenspeicher der Prüfwerkzeuge). Das ist keine neue Freiheit, sondern der bereits in 6.1.1 gesetzte Massstab: "ausgeschlossen wird nur, was die Versionsverwaltung ohnehin nicht aufnimmt, und auch das nachvollziehbar". Der Ausschluss wird **namentlich aufgezählt** und versioniert abgelegt, nicht aus `.gitignore` abgeleitet — die Ableitung würde `.env` und `*.pem` mit ausschliessen und wäre damit Option (e). Er hat einen zweiten Zweck: Fremdpakete bringen Testschlüssel mit, und ein Lauf über `node_modules/` erzeugt Fehlalarme und Laufzeit ohne Erkenntnisgewinn.
3. **Der Schutz wird nicht abgestuft.** D11 bleibt blockierend, beide Läufe bleiben zwingend.

**Was offen bleibt und weshalb** (O-10 in Abschnitt 8 neu gefasst): die namentliche Ausschlussliste und ihre technische Form — Konfigurationsdatei des Werkzeugs oder Aufrufparameter —, weil sie an der eingesetzten Werkzeugfassung hängt und mit einem ausgeführten Lauf zu belegen ist (DevOps Engineer mit SecDevOps); und die betriebliche Form von Punkt 1 — wo die Zugangsdaten liegen, wie der Prüfstapel sie einhängt, wie das in der Betriebsdokumentation und in der Bereitschaftsliste steht (SecDevOps mit DevOps Engineer). Beides ist Umsetzung und Betrieb, nicht Architektur; diese Rolle entscheidet es nicht.

#### 6.2.4 Was diese Fortschreibung nicht ändert

Die Werkzeugwahl aus 3.12 bleibt unverändert. D9, D10, D11 und D12 bleiben im Befehl unverändert; bei D10 und D18 ändert sich ausschliesslich die Objektbedingung, bei D11 ausschliesslich die Prüffläche. Die beiden Läufe aus 6.1.1, der Kettengrundsatz aus 6.1.3 und die Nummernregel aus 6.1.2 bleiben in Kraft und werden durch D19 ergänzt, nicht ersetzt. Die offenen Schwellenwerte (O-7) und die offenen Formfragen zu D10 und D12 (O-8) bleiben offen. Der Befund zum untauglichen `git diff`-Abgleich in D12 bleibt bestehen.

### 6.3 Dritte Fortschreibung vom 2026-08-30 — vier gemeldete Abweichungen des Makefiles, entschieden

**Anlass.** Der DevOps Engineer hat die zweite Fortschreibung (Commit `1ab5898107e1d580929ea81da666d6efc31e772d`) im Makefile umgesetzt und dabei vier Abweichungen zwischen Wortlaut und Umsetzung **gemeldet, statt sie stillschweigend zu entscheiden**. Das ist der vorgesehene Weg (CLAUDE.md: Abweichungen von ADR 0002 nur als Fortschreibung). Drei davon sind hier zu entscheiden, die vierte ist zur Kenntnis genommen und terminiert. Wie bei den beiden vorangehenden Fortschreibungen bleiben die früheren Fassungen im Text stehen.

#### 6.3.1 `--locked` blieb ohne `--project backend` wirkungslos

| | |
|---|---|
| **Vorher galt** | `uv sync --locked` in D1 und `uv run --locked <werkzeug>` in D2 bis D8 und D18, ohne Angabe des Projekts |
| **Jetzt gilt** | Jeder `uv`-Aufruf der Kette trägt zusätzlich `--project backend`. Das Arbeitsverzeichnis aller Kettenschritte bleibt die Repository-Wurzel; alle Pfadangaben in den Befehlen bleiben repo-relativ, wie sie in der Tabelle stehen |

**Beleg**, ausgeführter Lauf am 2026-08-30 aus der Repository-Wurzel, `backend/pyproject.toml` vorhanden:

```
$ uv run --locked python -c "pass"
warning: `--locked` has no effect when used outside of a project

$ uv run --locked --project backend python -c "print('lief')"
Creating virtual environment at: backend/.venv
error: Unable to find lockfile at `uv.lock`. ...
```

`uv` sucht ein Projekt ausschliesslich **aufwärts** vom Arbeitsverzeichnis, nie abwärts. Das Makefile setzt das Arbeitsverzeichnis auf die Repository-Wurzel; `backend/pyproject.toml` liegt darunter und wird von dort nie gefunden. Der Entscheid der zweiten Fortschreibung — die Kette schreibt die Sperrdatei nicht und meldet eine Abweichung — war damit in seiner tragenden Hälfte unwirksam: Der Schalter meldete nur, dass er nichts bewirkt, und diese Warnung geht im Rauschen eines Kettenlaufs unter. Der zweite Aufruf zeigt, dass `--project backend` beides herstellt: Projektauflösung und die Aussage des Schalters.

**Optionen.**

| Option | Bewertung |
|---|---|
| (a) `--project backend` an jedem `uv`-Aufruf, Arbeitsverzeichnis unverändert die Repository-Wurzel | `--project` benennt das Projekt, ohne das Arbeitsverzeichnis zu wechseln. Alle Pfadargumente der Befehle bleiben wörtlich so gültig, wie sie in der Tabelle stehen — `backend/src` in D1 und D4, `backend/tests` in D4, `--cov=backend/src/r3cosint` in D6, `backend/importvertraege.toml` in D18 |
| (b) `--directory backend` | Wechselt das Arbeitsverzeichnis. Jedes der genannten Pfadargumente müsste umgeschrieben werden, und die Kette hätte zwei Pfadwelten: `uv`-Schritte relativ zu `backend/`, alle übrigen (gitleaks, die Skripte in `scripts/`, `docker compose -f deploy/...`) relativ zur Wurzel. Wer eine Zeile liest, müsste wissen, welcher Schritt das Verzeichnis wechselt |
| (c) Wechsel des Arbeitsverzeichnisses im Makefile mit angepassten Argumenten | Wie (b), zusätzlich im Makefile je Rezeptzeile herzustellen. Ein Zustand, den jede Zeile neu erzeugen muss, ist die fehleranfälligere Form derselben Sache |

**Entscheid: (a).** Vier Gründe, jeder für sich tragend.

1. **Ein Arbeitsverzeichnis für die ganze Kette.** Für D11 ist das seit 6.1.1, Punkt 1 bereits verbindlich: "Beide Läufe beurteilen dieselbe Wurzel, nämlich das Repository-Verzeichnis." Ein Schritt, der das Verzeichnis wechselt, macht diese Zusicherung von der Reihenfolge abhängig — dieselbe Art Abhängigkeit, die der Kettengrundsatz aus 6.1.3 beseitigen soll.
2. **Merkmal und Aufruf nennen dieselbe Sache.** Die Objekttabelle erkennt den Backend-Anteil von D1 bis D8 an `backend/pyproject.toml`. Genau diese Datei benennt `--project backend`. Damit prüft der Schritt das, woran er seinen Gegenstand erkennt, und nicht ein zufällig gleichnamiges Verzeichnis (Regel 1 der Objektbestimmung).
3. **Keine dreizehnfache Argumentänderung.** Die Pfadangaben in Abschnitt 6 sind an mehreren Stellen wörtlich in Gebrauch — der Abdeckungspfad aus D6 steht so auch in den Abdeckungsberichten und folgt dem Modulbaum aus 4.1. Eine Umschreibung aller Argumente wäre eine Änderung mit Fehlerfläche ohne Gewinn.
4. **Der Umgebungspfad bleibt ignoriert.** `uv` legt die Umgebung unter `backend/.venv/` an. `.gitignore` führt in Zeile 4 `.venv/` ohne führenden Schrägstrich, greift also auf jeder Ebene (geprüft am 2026-08-30). D19 schlägt daran nicht an; ein Nachtrag ist nicht nötig.

**Was hier nicht entschieden wird und zu belegen ist.** Aus dem unveränderten Arbeitsverzeichnis folgt, dass jeder Schritt seinen Gegenstand als Argument nennen oder aus `backend/pyproject.toml` beziehen muss. Für `ruff`, `mypy`, `compileall` und `lint-imports` steht er im Befehl; `pip-audit` beurteilt die Umgebung, also `backend/.venv/`. Bei `pytest` in D5 und D6 steht keine Pfadangabe, und das Arbeitsverzeichnis ist die Wurzel — welchen Gegenstand `pytest` von dort aus einsammelt und woher es seine Konfiguration nimmt, ist mit einem ausgeführten Lauf festzustellen, nicht anzunehmen. Sammelt es ausserhalb von `backend/` ein, erhält die D5- und D6-Zeile eine Pfadangabe; das wäre eine eigene Fortschreibung. Zuständig: DevOps Engineer, Verifikation bei den Testerrollen (3.4). Die Nachweispflicht aus 6.2.1 bleibt daneben bestehen und wird um einen Punkt (e) ergänzt: Der Lauf, der (a) bis (d) belegt, belegt zugleich, dass `--locked` nicht mehr mit "has no effect" antwortet.

#### 6.3.2 D7 erkannte seinen Gegenstand am Dateinamen

| | |
|---|---|
| **Vorher galt** | Objekttabelle, D7 zweiter Teil: Erkennungsmerkmal "`docs/05_Product_Backlog.md` führt Abnahmekriterien", Lage B "keine Abnahmekriterien vorhanden" |
| **Jetzt gilt** | Erkennungsmerkmal ist eine Datei unterhalb `docs/`, die den Backlog trägt, gefunden über das Suchmuster `docs/05_Product_Backlog*.md`. **D7 hat keine Lage B.** Findet der Schritt keine solche Datei oder führt die gefundene keine Abnahmekriterien, endet er ungleich 0 |

**Beleg**, festgestellt vor dieser Fortschreibung: Nach `mv docs/05_Product_Backlog.md docs/05_Product_Backlog_v2.md` meldete D7 Lage B mit Rückgabewert 0, obwohl der Backlog mit allen Abnahmekriterien unverändert vorlag. Das Makefile verwendet deshalb bereits das Suchmuster; der ADR nannte den einen Dateinamen.

**Entscheid und Begründung.** Der Glob wird **nicht** zurückgebaut, und er allein genügt auch nicht. Beide Teile folgen aus der eigenen Regel 1 der Objektbestimmung: Der Gegenstand von D7 sind die **Abnahmekriterien des Backlogs**, nicht eine Datei mit einem bestimmten Namen. Ein Dateiname ist hier nicht die tragende Ausprägung des Gegenstands — der Backlog bleibt derselbe, wenn er umbenannt, versioniert oder verschoben wird. Der Glob behebt den belegten Fall (Versionsanhang), aber er bleibt eine Namensbindung: `docs/backlog.md` fände er ebenso wenig. Deshalb wiegt der zweite Teil schwerer.

**Weshalb D7 keine Lage B mehr hat.** Der Backlog ist seit der Freigabe von Schritt 3 dauerhafter Bestandteil des Repositories, wie `docs/` für D12 und `prototype/` für D10. Ein Repository ohne Backlog mit Abnahmekriterien ist kein zulässiger Zustand dieses Projekts, über den ein Prüfschritt schweigend hinweggehen dürfte. Damit gilt Regel 3: Nennt die Tabelle keine Lage B, gibt es keine. Das ist zugleich die dauerhafte Antwort auf den belegten Fall — welchen Namen die Datei auch trägt, ein Nichtfinden macht die Kette rot statt grün, und "ich habe nichts gefunden" ist nie mehr ein bestandener Schritt. Der Glob bleibt als Suchmuster, damit eine zulässige Umbenennung nicht unnötig einen roten Lauf erzeugt; treffen mehrere Dateien zu, werden alle beurteilt und in der Lage-Meldung genannt (Regel 4).

**Wo die Erkennung auf Dauer sitzt.** Nicht im Makefile. `scripts/abnahme-abgleich.sh` entsteht mit dem Grundgerüst und kennt Backlog und Abnahmekriterien ohnehin; die Bestimmung des Gegenstands gehört dorthin, und das Makefile ruft nur auf. Bis das Skript besteht, trägt das Suchmuster im Makefile die Bestimmung. Das ist keine zweite Bedingung, sondern dieselbe an einem vorläufigen Ort.

#### 6.3.3 D11 — `git` ist Prüfmittel, nicht nur Erkennungsmerkmal

| | |
|---|---|
| **Vorher galt** | Objekttabelle, D11: Erkennungsmerkmal "`.git/` vorhanden", Prüfmittel "`gitleaks`" |
| **Jetzt gilt** | Prüfmittel: `gitleaks`; für den Historienlauf zusätzlich `git`. Fehlt `git` bei vorhandenem `.git/`, ist das Lage C — Rückgabewert ungleich 0 |

**Entscheid.** Das Makefile ist richtig, der ADR war ungenau. Die Trennung von Merkmal und Prüfmittel bleibt bestehen; sie war nur unvollständig ausgefüllt.

**Begründung.** D11 besteht aus zwei zwingenden Läufen mit verschiedenen Gegenständen (6.1.1). Der Arbeitsbaumlauf (`--no-git`) braucht `git` nicht. Der Historienlauf urteilt über die Git-Historie und kommt ohne `git` nicht an sie heran. Fehlt `git` bei vorhandenem `.git/`, ist der Gegenstand also vorhanden und ein Prüfmittel fehlt — das ist wörtlich Lage C, und der Satz "Ein fehlendes Prüfmittel ist kein bestandener Schritt" trifft hier den gefährlichsten Fall: Ein Schritt, der nur noch den Arbeitsbaum sieht und trotzdem grün meldet, erklärt ein Repository für sauber, dessen dritter Commit einen Schlüssel trägt (6.1.1). Das Merkmal bleibt `.git/`, weil es den Gegenstand bezeichnet; `git` bezeichnet die Fähigkeit, über ihn zu urteilen. D19 führt `git` aus demselben Grund bereits als Prüfmittel.

**Nicht geändert.** Der Arbeitsbaumlauf bleibt vom Vorhandensein von `git` unabhängig. Er entfällt nicht, wenn `git` fehlt — er läuft, sein Befund erscheint, und der Schritt endet trotzdem ungleich 0, weil der zweite Gegenstand unbeurteilt blieb. Kein Lauf schneidet den anderen ab (6.1.1, Teilfrage 3).

#### 6.3.4 D18 — der Abgleich der Wurzelpakete ist terminiert, nicht gebaut

Zur Kenntnis genommen, kein Entscheid nötig, aber ein offener Punkt. Die Anmerkung "Zu D18" verlangt, dass `backend/importvertraege.toml` jedes oberste Paket unterhalb `backend/src/` als Wurzelpaket nennt; sonst meldet der Prüfer Lage A, ohne etwas beurteilt zu haben. Genau dieser blinde Fleck war der Befund aus 6.2.2. Er ist heute nicht gebaut, weil die Vertragsdatei noch nicht besteht, und im Makefile als Kommentar hinterlegt.

**Weshalb das als offener Punkt geführt wird und nicht als erledigt.** Ein Kommentar ist keine Prüflogik. Der ADR sagt zur auskommentierten Prüfung bereits: Sie bleibt still liegen, nachdem sie gebraucht würde. Der Augenblick, in dem sie gebraucht wird, ist derselbe, in dem `backend/importvertraege.toml` entsteht — also mit dem Grundgerüst, in einer Arbeitseinheit einer anderen Rolle als der, die den Kommentar geschrieben hat. Ohne Eintrag in Abschnitt 8 hinge die Erinnerung an einer Zeile im Makefile. Neu als **O-11** terminiert.

#### 6.3.5 Was diese Fortschreibung nicht ändert

Die Werkzeugwahl aus 3.12 bleibt unverändert. Kein Kettenschritt wechselt sein Werkzeug, seine Stellung in der Reihenfolge oder seinen Gegenstand; D9, D10, D12, D18 und D19 bleiben unberührt. Der Kettengrundsatz aus 6.1.3, die Nummernregel aus 6.1.2, die beiden Läufe aus 6.1.1, die Objektbestimmung aus 6.2.2 und die Prüffläche aus 6.2.3 bleiben in Kraft. `--locked` bleibt und wird durch `--project backend` nicht ersetzt, sondern erst wirksam. Die offenen Schwellenwerte (O-7), die Formfragen zu D10 und D12 (O-8) und die beiden Restfragen aus O-10 bleiben offen.

---

### 6.4 Vierte Fortschreibung vom 2026-08-30 — D19 misst den Inhalt, nicht die Statusliste

**Eingetragen durch den Koordinator**, nicht durch den Software Architect. Der
Grund gehört zur Sache: Der Befund entstand beim Wirkungsnachweis zu B2 und ist
ausgeführt belegt; die Umsetzung im Makefile wäre sonst stillschweigend vom ADR
abgewichen, was CLAUDE.md untersagt. Der Software Architect prüft die
Formulierung bei nächster Gelegenheit nach.

**Was vorher galt.** Abschnitt 6.3 legte für D19 als Mittel `git status
--porcelain` fest, vorher und nachher, zeilenweise verglichen.

**Was jetzt gilt.** Die Aufnahme umfasst zusätzlich eine Inhaltsprüfsumme je
verfolgter Datei, und die Statusliste wird mit `--untracked-files=all` erhoben.

**Weshalb.** Die blosse Statusliste misst, **welche** Dateien abweichen, nicht
**wie**. Eine Datei, die schon vor dem Lauf geändert war, trägt vorher wie
nachher denselben Eintrag `` M datei`` — auch wenn ein Kettenschritt sie
während des Laufs erneut ändert. Ausgeführt belegt am 2026-08-30 in einem
`git worktree`:

```
Vorbedingung: " M Makefile  M README.md"
Kettenschritt haengt eine Zeile an README.md an
vorher:  make dod endete mit 0 -- "D19 ohne Befund"
nachher: make dod endet mit 2 -- "D19 verletzt"
```

Der Fall ist nicht der Randfall, sondern der Regelfall: Die Kette läuft nach
6.1.1 **vor** dem Commit, also auf einem Baum, der üblicherweise bereits
Änderungen trägt. Ohne die Prüfsumme wäre der Kettengrundsatz aus 6.1.3 genau
dort blind, wo er gebraucht wird.

**Einordnung in das Muster.** Die Schlussprüfung vom 2026-08-30 hat als Ursache
aller drei gescheiterten Runden benannt: *die Kette misst die Verfügbarkeit
eines Namens, nicht die Anwesenheit des Gegenstands.* Die Statusliste ist
derselbe Fehler eine Ebene höher — sie misst eine Liste von Namen statt den
Inhalt. Die Fortschreibung schliesst ihn an dieser Stelle.

**Preis, benannt statt verschwiegen.** Die Prüfsumme läuft zweimal je
`make dod` über alle verfolgten Dateien. Bei einem grossen Bestand ist das
spürbar; die Alternative wäre ein unbeobachtbarer Grundsatz. Sollte die Laufzeit
stören, ist die Antwort eine schnellere Prüfsumme, nicht eine ungenauere
Aufnahme.

### 6.5 Fünfte Fortschreibung vom 2026-08-31 — wogegen die Kette schützt, und wogegen nicht

**Eingetragen durch den Koordinator.** Fünf adversarische Prüfrunden haben ein
Muster erzeugt: Jede geschlossene Umgehung brachte eine neue hervor —
`PATH`, dann `UV_PROJECT_ENVIRONMENT`, dann `PYTHONPATH`, dann `BASH_ENV`.
Der ADR entscheidet deshalb, was er bisher offenliess: die Reichweite.

**Was jetzt gilt.** Die Definition-of-Done-Kette schützt gegen **Bequemlichkeit
und Abkürzung** — ein Schritt, der mit 0 endet, ohne geprüft zu haben; ein
fehlendes Prüfmittel, das als "keine Beanstandung" durchgeht; ein Schritt, der
den Gegenstand verändert, über den er urteilt; eine Lage-Marke, die etwas
anderes behauptet als der Rückgabewert. Das ist die Fehlerklasse aus 3.4.

Sie schützt **nicht** gegen jemanden, der die Umgebung des Aufrufs beherrscht.
Zwei ausgeführte Belege vom 2026-08-31. Ein dritter Fall, der **nicht** unter
diese Begründung fiel, ist am selben Tag hinzugekommen (6.6.1) und am selben
Tag geschlossen worden (6.7) — er ist deshalb kein Beleg mehr für diesen
Absatz, sondern für den Satz, der aus ihm folgt: **Eine Abgrenzung ist keine
Erlaubnis.**

1. **`BASH_ENV`.** Bash liest die Variable auch für nicht-interaktive Shells,
   und zwar **bevor die erste Rezeptzeile läuft**. Eine dort definierte Funktion
   `env` verschluckt jeden `$(UV)`-Aufruf; D1 bis D8 und D18 melden "bestanden",
   ohne dass ein Werkzeug lief.
2. **Ein gefälschtes `uv` früher im `PATH`** bedient die Umfeldprobe und den
   eigentlichen Aufruf zugleich.

**Weshalb das nicht zu schliessen ist.** Jede gesperrte Variable hat eine
Nachfolgerin, und die zuletzt gefundene wirkt **vor** dem ersten eigenen Befehl
der Datei. Eine Negativliste über die Umgebung kann nicht schliessen — dieselbe
Einsicht, die 6.2.2 für die Objektbestimmung festgehalten hat.

**Weshalb es vertretbar ist.** Wer `BASH_ENV` setzen kann, während `make dod`
aufgerufen wird, kann den Aufruf ebenso gut unterlassen oder das Makefile
ändern. Ein Gate im Arbeitsverzeichnis ist gegen den, der das
Arbeitsverzeichnis beherrscht, grundsätzlich wirkungslos.

**Folge, die in die Planung gehört.** Die Kette ist die **zweite Linie** — wie
die beiden PreToolUse-Gates, deren Kopfkommentare dasselbe festhalten. Die
harte Zusicherung liegt dort, wo der Aufrufer die Umgebung nicht beherrscht:
in einem Lauf auf der Gegenseite (Bauumgebung, Server), analog zum Ruleset, das
den Schutz von `main` trägt. **Solange dieser Lauf fehlt, ist die Kette die
Selbstprüfung eines kooperierenden Aufrufers.** Das ist beim Nachweis nach 5.3
mitzudenken und beim Zuschnitt von R3-Q-001 zu berücksichtigen.

**Neuer offener Punkt O-12:** Ein Lauf der Kette auf der Gegenseite, in einer
Umgebung, die der Aufrufer nicht setzt. Zuständig: DevOps Engineer mit
SecDevOps; fällig mit dem Grundgerüst, spätestens mit der Bereitschaftsliste.

### 6.6 Sechste Fortschreibung vom 2026-08-31 — die Reichweite aus 6.5 war zu weit gefasst, und die Projektbestimmung urteilte über das falsche Repository

**Eingetragen durch den Koordinator** nach einer sechsten, bewusst eng
gefassten Prüfrunde auf einem anderen Modell. Sie hat genau die beiden
Änderungen geprüft, die 6.5 nach sich zog, und für beide einen blockierenden
Befund erhoben. Beide sind behoben; hier steht, was vorher galt, was jetzt
gilt und weshalb.

#### 6.6.1 Die Positivliste um `$(UV)` war zu breit — der Zwischenspeicher hebelt `--locked` aus

| | |
|---|---|
| **Vorher galt** | Jeder `uv`-Aufruf läuft über eine leere Umgebung (`env -i`), durchgereicht wird nur eine Positivliste. Am 2026-08-31 wurde diese Liste um die Netz- und Zertifikatsvariablen erweitert, weil `uv` in einer Umgebung mit Proxy und eigener Wurzelzertifizierungsstelle sonst scheitert. Mitgenommen wurden dabei `UV_CACHE_DIR`, `XDG_CACHE_HOME` und `TMPDIR` |
| **Jetzt gilt** | Diese drei stehen nicht mehr auf der Liste. Durchgereicht wird ausschliesslich, was der Proxy- und Zertifikatsfall nachweislich braucht, dazu `LANG`/`LC_ALL` für die Kodierung der Ausgabe |

**Der Beleg.** `--locked` prüft die Prüfsumme eines Pakets beim
**Herunterladen**. Liegt ein bereits **entpacktes** Archiv im Zwischenspeicher,
wird es ohne erneute Prüfung ins Umfeld gelegt. Die Prüfung hat das mit einem
ausgeführten Lauf gezeigt: präparierter Zwischenspeicher, `.venv` gelöscht,
`make bau` erneut — Ergebnis `A_OK` bei manipuliertem Paketinhalt im Umfeld.
Der Weg über `HTTPS_PROXY` führt dagegen **nicht** zu einem falschen `A_OK`,
sondern zu einem sauberen Fehlschlag; dort trägt `--locked`.

**Weshalb das kein Sonderfall von 6.5 ist.** 6.5 begründet die Reichweite mit
dem Satz: Wer die Umgebung so weit beherrscht, kann den Aufruf ebenso gut
unterlassen. Für `UV_CACHE_DIR` trug dieser Satz nicht — es genügte **eine
einzige gesetzte Umgebungsvariable**, ohne Kontrolle über Shell oder `PATH`,
und diese Variable hatte die Kette selbst freigegeben. Der Befund richtet sich
also nicht gegen die Reichweite aus 6.5, sondern gegen ihre zu breite
Umsetzung. Nach der Entfernung der drei Variablen bleibt als Weg nur `HOME`
— das `uv` zwingend braucht und unter dem der Zwischenspeicher liegt —, und
für `HOME` trägt der Satz aus 6.5 wieder.

**Was bewusst nicht getan wurde.** Ein fest verdrahteter Zwischenspeicherpfad
wäre gegen `HOME` dicht, tauscht den Weg aber gegen zwei neue Fehler: Ein nicht
beschreibbarer Ort lässt **jeden** `uv`-Schritt als "Lage A — durchgefallen"
enden — genau die Falschaussage, welche die Erweiterung der Positivliste
beseitigen sollte —, und ein Zwischenspeicher im Arbeitsbaum käme unter den
Arbeitsbaumlauf von D11 (6.2.3: `.gitignore` wirkt dort nicht) und damit unter
einen Prüfer, der auf Paketinhalt nicht ausgelegt ist. Der wirksame Abschluss
ist `uv sync --no-cache`: jedes Paket wird neu geladen und dabei gegen die
Sperrdatei geprüft, um den Preis eines vollständigen Ladevorgangs je Lauf und
einer Netzabhängigkeit. Das ist eine Betriebsentscheidung, keine
Architekturentscheidung — **neu als O-13 in Abschnitt 8**.

#### 6.6.2 Die Projektbestimmung konnte still das falsche Repository prüfen

| | |
|---|---|
| **Vorher galt** | Das Projektverzeichnis `PROJ` wurde aus `$(MAKEFILE_LIST)` hergeleitet; scheiterte das (GNU Make trennt die Liste an Leerzeichen), fiel `PROJ` auf das Arbeitsverzeichnis zurück. Eine Wache prüfte, ob dort ein Marker liegt (`CLAUDE.md` oder `.git`) |
| **Jetzt gilt** | Kein Rückfall. `PROJ` wird aus dem **ganzen** Wert von `$(MAKEFILE_LIST)` hergeleitet — die Datei bindet nichts ein, die Liste trägt also genau einen Eintrag, und gespalten hat ihn immer erst `$(firstword)`. Lässt sich der Pfad nicht bestimmen, bricht der Lauf mit einer Erklärung ab |

**Der Beleg.** Die Wache mass, ob am Rückfallort *irgendein* Marker liegt —
nicht, ob es der *richtige* ist. Steht der Aufrufer in einem anderen echten
Arbeitsbaum (zwei Arbeitskopien nebeneinander sind die naheliegende
Arbeitsform, siehe 6.4), trägt der Rückfallort seinen eigenen Marker, die
Wache schweigt, und `make dod` prüft vollständig und unbemerkt das falsche
Repository. Mit zwei Arbeitskopien ausgeführt belegt. Kommt die falsche Kopie
weiter als die gemeinte, ist das ein **falsches Grün für einen Stand, den
niemand angesehen hat** — die Fehlerklasse, gegen die diese Kette gerade
schützen soll.

**Es ist dieselbe Ursache wie in 6.2.2.** Die Wache machte die Lage an einem
**Namen** fest ("hier liegt ein `CLAUDE.md`") statt am **Gegenstand** ("das ist
das Verzeichnis dieses Makefiles"). Die Behebung nimmt den Gegenstand: Der
Pfad, den GNU Make selbst gelesen hat, wird ungeteilt an die Shell gegeben.
Nebenbei ist damit die bisher als "nicht unterstützt" bezeichnete Aufrufart
`make -f '<pfad mit leerzeichen>/Makefile'` aus einem fremden
Arbeitsverzeichnis nicht mehr nur erkannt, sondern richtig aufgelöst.

**Präzisierung nach der Nachprüfung** — die erste Fassung dieses Absatzes
sagte "ausgeführt belegt für sieben Aufrufarten" und war damit zu weit:

- Für die **umbenannte Datei** (`make -f '<verzeichnis>/Projektregeln.mk'`)
  galt das nur für die Herleitung von `PROJ`, nicht für einen vollständigen
  `make dod`. Die Schleife in `dod` ruft jeden Kettenschritt als Unter-Make mit
  `-C "$(PROJ)"` auf; ohne `-f` sucht ein Unter-Make dort die Vorgabenamen
  `Makefile`/`makefile` und brach mit `No rule to make target 'bau'` ab, **bevor
  der erste Kettenschritt lief**. Der Fehler bestand schon vor dieser
  Fortschreibung und fiel sicher ab (Rückgabewert 2, Meldung "nicht nachweisbar
  gelaufen") — kein falsches Grün, aber eine Aufrufart, die nicht lief. Er ist
  in derselben Arbeitseinheit behoben: Der Unter-Make-Aufruf trägt jetzt
  zusätzlich `-f "$(MAKEFILE_NAME)"`, den **Basisnamen** dieser Datei. Der
  Basisname und nicht der Pfad, weil ein relativer `-f`-Pfad nach dem `-C` ein
  anderer wäre. Sieben Aufrufarten laufen jetzt vollständig an (ausgeführt
  belegt: aus dem Verzeichnis selbst, `-f ./Makefile`, `-C` mit und ohne
  Leerzeichen, `-f` mit Leerzeichen, `-f` mit Apostroph, umbenannte Datei mit
  und ohne fremdes Arbeitsverzeichnis).
- Für den **symbolischen Verweis** gilt die Aussage nur für einen Verweis
  *innerhalb* des Projektverzeichnisses. Zeigt ein Verweis von *aussen* auf das
  Makefile des Projekts, wird `PROJ` das Verzeichnis des Verweises — weder
  `dirname` noch `pwd -P` lösen einen Symlink in der letzten Pfadkomponente auf.
  Das ist gewollt: Ein in eine Arbeitskopie gelegter Verweis soll diese
  Arbeitskopie prüfen. Liegt der Verweis dagegen in einem Verzeichnis, das kein
  Projekt ist, greift die zweite Wache und bricht ab.

#### 6.6.3 Was diese Fortschreibung nicht ändert

Die Werkzeugwahl aus 3.12 bleibt unverändert. Kein Kettenschritt wechselt sein
Werkzeug, seine Stellung oder seinen Gegenstand; D1 bis D12, D18 und D19
bleiben im Befehl unberührt. Der Kettengrundsatz aus 6.1.3, die Nummernregel
aus 6.1.2, die beiden Läufe aus 6.1.1, die Objektbestimmung aus 6.2.2, die
Prüffläche aus 6.2.3, `--locked` mit `--project backend` aus 6.3.1 und die
Inhaltsprüfung aus 6.4 bleiben in Kraft. Die Reichweitenentscheidung aus 6.5
bleibt bestehen und wird durch 6.6.1 präzisiert, nicht aufgehoben. Offen
bleiben O-7, O-8, die beiden Restfragen aus O-10, O-11 und O-12; neu
hinzu kommt O-13.


### 6.7 Siebte Fortschreibung vom 2026-08-31 — O-13 entschieden: die Kette benutzt den Zwischenspeicher nicht

**Entscheid des Auftraggebers vom 2026-08-31**, wörtlich: "Das, was korrekt und
qualitativ ist. Soll zwar effizient sein, aber nie an Korrektheit und Qualität
verlieren." Damit ist O-13 in dem Tag entschieden, an dem er entstanden ist,
und zwar zugunsten der Beweiskraft.

| | |
|---|---|
| **Vorher galt** | Nach 6.6.1 blieb ein Restweg: `HOME` muss durchgereicht werden, weil `uv` ohne `HOME` nicht läuft, und der Zwischenspeicher liegt darunter. Wer `HOME` setzen oder in `~/.cache/uv` schreiben konnte, brachte D1 dazu, manipulierten Paketinhalt als "Lage A — bestanden" zu melden |
| **Jetzt gilt** | Jeder `uv`-Aufruf der Kette läuft mit `UV_NO_CACHE=1`. `uv` liest und schreibt den Zwischenspeicher nicht mehr, sondern benutzt ein temporäres Verzeichnis für die Dauer des Aufrufs; jedes Paket wird geladen und dabei gegen `uv.lock` geprüft |

**Weshalb die Umgebungsvariable und nicht der Schalter `--no-cache`.** Beide
wirken gleich (belegt geprüft). Die Variable wirkt aber für **jeden**
`uv`-Aufruf der Kette, auch für die, die erst später hinzukommen — der
Schalter müsste an jeder einzelnen Aufrufstelle stehen und fehlte dann
irgendwann an einer. Das ist dieselbe Überlegung wie bei `--project backend`
in 6.3.1, nur diesmal vorher statt hinterher angestellt.

**Weshalb sie gesetzt und nicht durchgereicht wird.** `$(UV)` beginnt mit
`env -i`: Die Umgebung wird geleert, danach setzt die Kette ihre eigenen
Werte. Eine von aussen mitgebrachte Fassung `UV_NO_CACHE=0` wird dabei
gelöscht und wirkt nicht (ausgeführt geprüft). Das ist der Unterschied
zwischen einer Einstellung und einer Bauvorschrift (5.4): Der Aufrufer kann
sie nicht abschalten.

**Beleg.** Synthetisches `backend/` mit einer echten externen Abhängigkeit,
Zwischenspeicher aufgebaut, das bereits entpackte Archiv manipuliert,
`backend/.venv` gelöscht, `HOME` auf dieses Heimatverzeichnis gerichtet:

- ohne `UV_NO_CACHE`: `::LAGE … D1 bau A_OK::` **mit** manipuliertem Inhalt in
  `backend/.venv` — das falsche Grün, reproduziert;
- mit `UV_NO_CACHE=1`: fünf Läufe hintereinander sauber, auch mit
  `UV_NO_CACHE=0` und mit `UV_CACHE_DIR` von aussen gesetzt.

**Der Preis, benannt und angenommen.** Ein Lauf, der wirklich installiert,
lädt den Abhängigkeitsbaum neu und braucht dafür Netz. Ein Lauf gegen ein
bereits vollständiges Umfeld installiert nichts und lädt deshalb auch nichts
(ausgeführt geprüft). Für eine Kette, deren Ergebnis nach 5.3 ein Nachweis
ist, ist ein wiederholbarer Ladevorgang der kleinere Preis als eine Aussage,
die auf einem Zwischenspeicher beruht, den niemand prüft.

**Folge für Abschnitt 6.5 und 6.6.** Fall 3 der Abgrenzung ist kein offener
Weg mehr. Er bleibt im Kopfabschnitt des Makefiles als Geschichte stehen, weil
er zeigt, was eine zu breite Positivliste anrichtet — und mit dem Satz, der
daraus folgt: **Eine Abgrenzung ist keine Erlaubnis.** Was sich schliessen
lässt, wird geschlossen; abgegrenzt wird nur, was sich im Makefile nicht
schliessen lässt. Fall 1 (`BASH_ENV`) und Fall 2 (gefälschtes `uv` im `PATH`)
bleiben genau das, und für sie bleibt O-12 die Antwort.

### 6.8 Achte Fortschreibung vom 2026-09-01 — der Belegprüfer wird Kettenschritt D20 und läuft als erster

**Anlass.** Der Auftraggeber hat am 2026-09-01 entschieden, den Belegprüfer in
die Definition-of-Done-Kette einzubinden. Ein zusätzlicher Kettenschritt ist
nach diesem Abschnitt eine Fortschreibung und keine stillschweigende Ergänzung;
die Übergabe des Werkzeugs hat die Entscheidung ausdrücklich dem Auftraggeber
vorgelegt statt sie vorwegzunehmen
(`docs/uebergaben/2026-09-01_belegpruefer-abbruch-nach-3-4.md`). Zu entscheiden
sind vier Dinge: die Kennung, die Stelle in der Kette, die Lage-Bedingung und
der Umgang damit, dass das Werkzeug nach Eskalationsregel 3.4 abgebrochen und
**nicht abgenommen** ist.

**Beleglage dieser Fortschreibung — was worauf beruht.** Diese Rolle hat den
Quelltext von `scripts/belege-pruefen.sh` und den Inhalt von
`scripts/belege-ausnahmen.txt` vollständig gelesen; sie hat das Skript **nicht
selbst ausgeführt**. Jede Aussage unten über die *Struktur* des Werkzeugs —
Prüffläche, Rückgabewerte, Zählweise, Ausnahmeformen, Regel für noch nicht
gebaute Bäume, Schlussausgabe — stammt aus dem gelesenen Quelltext und ist dort
nachprüfbar. Jede Aussage über einen *ausgeführten Lauf* — neun eingebaute
Fehlerklassen in drei Runden gefangen, null Funde über den heutigen Bestand bei
30 Ausnahmen, der Lauf verändert nichts, das Umschlagen von null auf 46 Funde
beim Entstehen eines Teilbaums — ist als Fremdbeleg aus der genannten Übergabe
übernommen und hier als solcher gekennzeichnet, nicht als eigene Beobachtung.
Diese Trennung steht hier, weil genau ihre Verletzung — *eine Aussage über die
Herkunft ist stärker, als die Quelle sie trägt* — die Fehlerklasse ist, an der
die vorangegangene Arbeitseinheit dreimal gescheitert ist und gegen die das
Werkzeug gebaut wurde.

#### 6.8.1 Die Kennung — D20

| | |
|---|---|
| **Vorher galt** | Der gemeinsame D-Namensraum führte D1 bis D12 (Kette), D13 bis D17 (menschlich bestätigte Bedingungen), D18 (Architekturverträge) und D19 (Rahmenprüfung) |
| **Jetzt gilt** | Der neue Kettenschritt heisst **D20** |

**Weshalb D20 und keine kleinere Nummer.** Die Nummernregel aus 6.1.2 gilt
unverändert: Nummern sind Kennungen, keine Reihenfolge; es wird nie
umnummeriert und nie wiederverwendet, weil die Nummern in Dokumenten stehen,
die einen vergangenen Stand belegen und deshalb nicht geändert werden dürfen.
D13 bis D17 sind in `docs/06_Definition_of_Ready_und_Done.md`, Teil 2, an die
menschlich bestätigten Bedingungen vergeben, D18 und D19 sind in diesem ADR
vergeben. Die nächste freie Nummer ist damit D20.

**Ein Punkt, der ohne ausdrückliche Entscheidung zu einer zweiten Vergabe
derselben Nummer geführt hätte.** `docs/06_Definition_of_Ready_und_Done.md`
führt D19 heute **noch nicht** — die Nachführung steht in Abschnitt 9 offen.
Wer die Freiheit einer Nummer an dieser Datei ablesen wollte, hielte D19 für
frei und vergäbe sie ein zweites Mal. Deshalb gilt hier ausdrücklich: **Eine
D-Nummer ist vergeben, sobald ein ADR sie vergibt**, nicht erst, wenn die
Nachführung sie erreicht hat. Der gemeinsame Namensraum wird aus der Vereinigung
beider Dokumente gelesen, und bei Abweichung gilt der frühere Vergabezeitpunkt.

#### 6.8.2 Die Stelle in der Kette — als erster Schritt, vor D1

| | |
|---|---|
| **Vorher galt** | `make dod` rief D1 bis D4, dann D18, dann D5 bis D12 auf |
| **Jetzt gilt** | `make dod` ruft **D20**, dann D1 bis D4, dann D18, dann D5 bis D12 auf. D20 ist der erste Schritt der Kette |

Das ist die eigentliche Entscheidung dieser Fortschreibung, und beide
Richtungen hatten ein Argument. Für das Ende sprach: Der Gegenstand von D20 ist
die Dokumentation, nicht die Software; die Kette ist bisher von der billigsten
strukturellen Prüfung zur teuersten geordnet, und ein Dokumentationsbefund darf
nicht wie ein Baufehler wirken. Für den Anfang sprachen vier Punkte, und sie
wiegen zusammen schwerer.

1. **Ein Schritt hinter D7 liefe bis auf Weiteres nie.** Die Kette bricht beim
   ersten Schritt ab, der ungleich 0 endet, und heute ist das D7: Der Backlog
   besteht und führt Abnahmekriterien, `scripts/abnahme-abgleich.sh` fehlt und
   entsteht erst mit dem Grundgerüst — nach der Objekttabelle oben ist das
   Lage C, und Lage C endet ungleich 0. Ein Kettenschritt, der nie läuft, ist
   dasselbe wie die auskommentierte Prüfung, die dieser Abschnitt bereits
   zweimal verworfen hat: *Er bleibt still liegen, nachdem er gebraucht würde.*
   Ein ADR-Eintrag, der ein Jahr lang keine Wirkung hat, ist keine Entscheidung,
   sondern eine Absichtserklärung.
2. **Sein Gegenstand ist der einzige, an dem heute tatsächlich gearbeitet
   wird.** Es besteht kein `backend/`, kein `frontend/`, kein `deploy/`; die
   Bau-, Prüf- und Testschritte finden dafür nach der Objekttabelle oben keinen
   Gegenstand. Was das Repository heute trägt, sind Texte:
   Projektauftrag, Backlog, Definition of Done, Regeln, Rollen, ADR,
   Übergaben. Eine Definition-of-Done-Kette, die über die einzige heute
   vorhandene Artefaktklasse **nichts** aussagt, ist für den heutigen Stand
   keine Kette.
3. **Er ist der billigste Schritt der Kette und hängt von keinem anderen
   ab.** Er braucht kein `uv`, kein `node`, kein `docker`, keinen
   Netzzugang und keinen Bau; nach dem Kopfkommentar des Skripts benutzt er
   `bash`, `git`, `grep`, `sed` und `awk` und kein Python. Damit gilt für ihn
   dieselbe Überlegung wie in 6.1.2 für die Stellung von D18: Ein Verstoss, der
   billig und früh feststellbar ist, soll vor den teuren Schritten fallen und
   nicht nach ihnen.
4. **Am Ende würde er in dem Augenblick scharf, in dem er am meisten
   Schaden anrichtet.** Das Skript behandelt Pfadverweise unter `backend/`,
   `frontend/`, `deploy/` und `prototype/` **nicht** als Fund, solange das
   oberste Verzeichnis fehlt (Regel b im Kopfkommentar, im Quelltext an der
   Prüfung der Pfadverweise umgesetzt); es schaltet sich von selbst scharf,
   sobald das Verzeichnis entsteht. D7 verlässt seine Lage C erst, wenn
   `scripts/abnahme-abgleich.sh` existiert — und dieses Skript entsteht nach
   der begründeten Ausnahme in `scripts/belege-ausnahmen.txt` mit **demselben**
   Grundgerüst wie `backend/`. Ein am Ende eingehängter D20 liefe also zum
   ersten Mal genau in dem Lauf, in dem sich zugleich seine schärfste Regel
   scharf schaltet. Die Übergabe nennt dafür einen ausgeführten Beleg: aus
   null Funden werden in diesem Augenblick 46. Das ist der stille
   Zustandswechsel, den 6.2.2 bei D18 und D10 bereits als Muster verworfen hat
   — *ein Zustandswechsel, den niemand beobachtet*. Vorn eingehängt, läuft der
   Schritt ab heute, wächst mit dem Bestand mit, und der Sprung findet nicht
   statt.

**Der Preis, benannt und angenommen.** Ein Fund in einem Dokument blockiert ab
sofort auch eine Arbeitseinheit, die mit Dokumentation nichts zu tun hat. Das
ist gewollt und nicht bloss hingenommen: Nach 5.3 ist das Ergebnis dieser Kette
ein Nachweis, und ein Nachweis, dessen Verweise ins Leere zeigen, ist als
Nachweis untauglich. Die Rückkopplung bleibt kurz, weil D20 der schnellste
Schritt ist, und jeder Fund ist ortsgebunden: Er ist entweder ein echter Fehler
oder er wird zur Ausnahme mit geschriebenem Grund (6.8.5). Scheitert dieselbe
Prüfung dreimal am gleichen Kriterium, gilt unverändert die Eskalation aus 3.4.

**Nicht entschieden wird hier**, ob D20 später an eine andere Stelle wandert.
Sollte die Kette einmal durchgehend grün laufen, ist die Stellung neu zu
bewerten — als Fortschreibung, nicht nebenbei. Die Kennung bleibt davon
unberührt; die Reihenfolge steht in der Zielliste von `make dod`, nicht in der
Zahl (6.1.2).

#### 6.8.3 Die Lage-Bedingung — und weshalb es für D20 keine Lage B geben kann

Die Objektbestimmung folgt der Regel aus 6.2.2: Der Gegenstand wird als Sache
benannt, das Erkennungsmerkmal als Beobachtung, die Bedingung steht einmal, und
zwar in der Objekttabelle in Abschnitt 6.

| Lage | Für D20 |
|---|---|
| **A** | Es besteht ein Git-Arbeitsbaum mit mindestens einer versionierten Markdown-Datei in der Prüffläche, und alle Prüfmittel sind vorhanden. Der Schritt urteilt: 0 oder ungleich 0 |
| **B** | **Gibt es nicht.** Siehe unten |
| **C** | Der Bestand besteht, aber ein Prüfmittel fehlt: kein `git` oder kein Git-Arbeitsbaum, `scripts/belege-pruefen.sh` oder `scripts/belege-ausnahmen.txt` fehlt oder ist nicht lesbar, oder eines der beiden Bezugsdokumente `docs/05_Product_Backlog.md` und `docs/00_Projektauftrag.md` fehlt. Rückgabewert ungleich 0 |

*Berichtigt mit der elften Fortschreibung (ADR 0002, Abschnitt 6.11):* Diese
Tabelle und der übrige Text von 6.8.3 sowie 6.8.4 kannten an dieser Stelle bis
dahin nur die Rückgabewerte 0 und 2 des Belegprüfers und behandelten damit
„das Prüfmittel selbst ist ausgefallen" als denselben Fall wie „am Bestand
wurde etwas gefunden". Seit der elften Fortschreibung unterscheidet das
Werkzeug selbst: Rückgabewert 2 heisst mindestens ein Befund, Rückgabewert 3
heisst Lage C. Beide sind „ungleich 0" im Sinn dieser Tabelle; Einzelheiten
in 6.11.2.

**Weshalb es keine Lage B geben kann — zwei voneinander unabhängige Gründe.**

1. **Der Bestand kann nicht leer sein.** Die Prüffläche umfasst die
   versionierten Markdown-Dateien der Wurzel, unter `docs/` und unter
   `.claude/`. `CLAUDE.md` und `docs/00_Projektauftrag.md` liegen darin und
   sind nach CLAUDE.md die verbindliche Grundlage des Projekts; ein Repository
   ohne sie ist nicht dieses Repository. Das ist dieselbe Begründung, mit der
   die dritte Fortschreibung vom 2026-08-30 (6.3.2) für D7 die Lage B
   gestrichen hat: Ein Gegenstand, der seit einer
   Freigabe dauerhaft besteht, wird nicht sinnvoll als "nicht vorhanden"
   behandelt — sein Fehlen ist ein Befund.
2. **Das Werkzeug könnte "leer" und "sauber" gar nicht unterscheiden.** Nach
   dem gelesenen Quelltext zählt das Skript Funde und endet bei null Funden mit
   Rückgabewert 0. Ein leerer Bestand ergibt ebenfalls null Funde. Die
   Unterscheidung zwischen *nichts gefunden* und *nichts geprüft* kann das
   Skript also nicht treffen — sie gehört deshalb in die Lage-Bestimmung des
   Kettenschritts und nicht in das Skript. Eine Lage B einzurichten hiesse,
   einen grünen Schritt zu erlauben, der über nichts geurteilt hat; das ist
   genau der Ausgang, den Regel 4 aus 6.2.2 untersagt.

**Weshalb ein fehlender Git-Arbeitsbaum Lage C ergibt und nicht Lage B.** Bei
D11 und D19 ist der Gegenstand selbst das Repository; ohne Repository gibt es
dort nichts zu beurteilen, also Lage B. Bei D20 ist der Gegenstand die
**Dokumentation**; sie besteht als Dateien unabhängig davon, ob eine
Versionsverwaltung läuft. `git` ist hier nur das Mittel, mit dem der Bestand
abgegrenzt wird. Fehlt es, besteht der Gegenstand fort und die Prüfung fällt
aus — das ist die Definition von Lage C. Der gelesene Quelltext verhält sich
bereits so: Findet das Skript am Arbeitsverzeichnis kein Git-Repository, endet
es mit einer Meldung und Rückgabewert 2 statt mit 0.

**Die beiden Bezugsdokumente sind Prüfmittel, nicht Beiwerk.** Das Skript
bildet seine Referenzmengen aus den Überschriften von
`docs/05_Product_Backlog.md` (gültige Anforderungskennungen) und
`docs/00_Projektauftrag.md` (gültige Abschnittsnummern). Fehlt eines davon,
bleibt die zugehörige Referenzmenge leer, und **jede** geprüfte Kennung
beziehungsweise Abschnittsangabe im ganzen Bestand wird zum Fund. Der Schritt
wäre dann zwar rot, aber mit einer falschen Begründung — hunderte Scheinfunde
statt der einen richtigen Aussage "das Prüfmittel fehlt". Deshalb stehen beide
Dateien in der Prüfmittelspalte: Lage C sagt, was los ist.

**Der zweite Arbeitsbaum ist kein Prüfmittel im Sinne von Lage C.** Das Skript
liest das Methodik-Repository an einem fest verdrahteten Ort ausserhalb dieses
Repositories mit, für Commit-Prüfsummen und für Pfade unter `methodik/`,
`nachweise/` und `sprints/`. Fehlt dieser Arbeitsbaum, zählt es die betroffenen
Zeilen nach dem gelesenen Quelltext als **nicht prüfbar**; diese Zählung geht
nicht in den Rückgabewert ein. Entschieden wird: Das ergibt **keine** Lage C —
der Schritt urteilt weiterhin über seinen eigenen Bestand, und ein Mitlesen,
das nur an einem Arbeitsplatz möglich ist, darf die Kette nicht an diesen
Arbeitsplatz binden. Aber nach Regel 4 aus 6.2.2 gilt: **Die Zahl der nicht
prüfbaren Zeilen gehört in die Lage-Meldung des Schrittes.** Ein Lauf, der
weniger prüfen konnte, muss von einem unterscheidbar sein, der alles geprüft
hat. Dass der Ort fest verdrahtet und nicht konfigurierbar ist, macht die
Aussage des Schrittes maschinenabhängig; das ist keine Architekturfrage, aber
es darf nicht unbemerkt bleiben und ist deshalb als **O-14** terminiert.

#### 6.8.4 Was ein grüner D20 aussagt — und was nicht

Dies ist der architektonisch erhebliche Teil. Das Werkzeug ist nach
Eskalationsregel 3.4 abgebrochen: Dreimal in Folge hat eine unabhängige Prüfung
eine reale Grenze gefunden, die in seiner Selbstauskunft fehlte, und jedes Mal
in der Schicht, welche die vorangegangene Behebung erst erreichbar gemacht
hatte. Die abgelieferte Fassung behauptet deshalb nicht mehr, die Liste ihrer
Grenzen sei vollständig; ihre Schlussausgabe sagt das ausdrücklich und schliesst
nach dem gelesenen Quelltext mit dem Satz, dass Rückgabewert 0 heisse, nichts
von dem gefunden zu haben, was dort aufgezählt ist — nicht, dass nichts
vorhanden sei.

**Was ein grüner D20 aussagt.** Kein Verweis der geprüften Klassen — Zeile,
Commit-Prüfsumme, Anforderungskennung, Pfad, Abschnitt des Projektauftrags,
Zweigform statt Commit-Prüfsumme — zeigt in der Prüffläche auf etwas, das es
nicht gibt, soweit die eingebauten Prüfungen reichen; und die Ausnahmeliste ist
formgerecht, begründet und nicht veraltet.

**Was ein grüner D20 nicht aussagt.** Erstens und vor allem nicht, dass der
Inhalt am genannten Fundort die Behauptung trägt, die ihm zugeschrieben wird —
das bleibt Sache des menschlichen Reviews, und das Skript sagt es selbst.
Zweitens nicht, dass alle Verweisformen erfasst sind: Pfade ausserhalb von
Rückwärtsakzenten und im Pfadteil von Shell-Befehlen werden nicht erfasst, das
Muster Inhaber/Repository nimmt auch echte künftige Zwei-Segment-Pfade aus, bei
der Abschnittsprüfung gilt eine Tabelle ohne Leerzeile als ein Absatz, und zwei
vorgesehene Prüfungen — Skill-Zuordnung im Rollen-Frontmatter und
Anforderungskennung im Skill-Frontmatter — sind nicht gebaut. Drittens und
entscheidend: **nicht, dass diese Aufzählung vollständig ist.**

*Berichtigt mit der elften Fortschreibung (ADR 0002, Abschnitt 6.11):* Bis
dahin kannte auch dieser Abschnitt für den Belegprüfer nur die Rückgabewerte
0 und 2 und behandelte „das Prüfmittel selbst ist ausgefallen" als denselben
Fall wie „am Bestand wurde etwas gefunden". Seit der genannten Fortschreibung
meldet das Werkzeug diesen Unterschied selbst, über einen dritten
Rückgabewert; Einzelheiten in 6.11.2.

**Schadet das der Kette oder tut es ihr gut? Es tut ihr gut, aus drei
Gründen.**

1. **Der Zusatz ist einseitig.** D20 teilt mit keinem anderen Schritt einen
   Gegenstand und kein Prüfmittel, und er kann nach dem gelesenen Quelltext
   nichts unterdrücken, was ein anderer Schritt meldet — er schreibt nichts,
   jede Ausgabe geht auf die Standard- oder die Fehlerausgabe, und die
   Übergabe belegt zusätzlich mit einem ausgeführten Lauf, dass er in keinem
   der beiden Arbeitsbäume etwas verändert. Für eine Zusicherung genügt das
   ohnehin nicht: Die Einhaltung des Kettengrundsatzes ist bei D20 wie bei
   jedem anderen Schritt **beobachtet**, nämlich durch D19. Ein Schritt, der
   nur Funde hinzufügen kann, macht die Aussage der Kette nie schwächer, als
   sie ohne ihn wäre. Ihn wegzulassen wäre nicht die vorsichtigere Wahl, es
   wäre die schwächere.
2. **Ein grüner Kettenschritt ist ohnehin nie eine positive Aussage.** `ruff
   format --check` sagt nicht, dass der Code gut entworfen ist; `pip-audit`
   sagt nicht, dass keine Schwachstelle besteht, sondern dass keine in der
   verwendeten Datenbank steht; `gitleaks` sagt nicht, dass kein Geheimnis
   vorliegt, sondern dass keines seinen Mustern entsprach. **Jeder** Schritt
   dieser Kette ist eine Negativaussage über den eigenen Suchraum. D20 sagt
   damit nichts Schwächeres als die übrigen — er ist der einzige, dessen
   Werkzeug es laut sagt. Daraus folgt kein Ausschluss, sondern ein
   Kettengrundsatz, der ab hier für alle Schritte gilt:

   > **Rückgabewert 0 eines Kettenschritts heisst: nichts von dem gefunden,
   > was dieser Schritt sucht. Er heisst nie: nichts vorhanden.** Ein grünes
   > `make dod` ist der Nachweis, dass die Kette gelaufen ist und nichts
   > gefunden hat — nicht der Nachweis, dass die Arbeit richtig ist. Die
   > menschlich bestätigten Bedingungen D13 bis D17 stehen genau deshalb
   > daneben und werden durch keinen grünen Lauf ersetzt.

   Dieser Grundsatz ändert an keinem Schritt das Verhalten. Er ändert, was die
   Kette zu behaupten beansprucht — und das ist bei einem Artefakt, dessen
   Ergebnis nach 5.3 ein Nachweis ist, kein Nebenpunkt.
3. **Die gefährliche Richtung ist abgedeckt.** Ein Kettenschritt kann falsch
   grün oder falsch rot sein. Falsch rot ist sichtbar, ortsgebunden behandelbar
   und unterliegt der Eskalation aus 3.4. Falsch grün ist die gefährliche
   Richtung — aber ohne D20 ist die Kette in dieser Dimension **immer** falsch
   grün, weil sie überhaupt nicht hinsieht. Ein Werkzeug, das einen Teil findet
   und den Rest nicht behauptet, ist jeder Lage überlegen, in der niemand
   sucht.

**Zwei Bedingungen, unter denen das gilt.**

- **D20 ist blockierend, nicht meldend.** Die naheliegende Milderung — der
  Schritt warnt, blockiert aber nicht, weil das Werkzeug nicht abgenommen ist —
  ist in diesem ADR bereits entschieden, und zwar gegen sie: 6.2.3 verwirft die
  Abstufung mit der Begründung, eine Meldung, die nicht blockiert, werde in
  einem Stop-Hook nicht gelesen, und eine abgestufte Wirkung sei eine
  Abschaltung mit besserem Namen (5.4). Für D20 gilt dasselbe. Wer dem Werkzeug
  nicht genug traut, um es blockieren zu lassen, nimmt es nicht in die Kette
  auf; ein sichtbar wirkungsloser Schritt ist die schlechteste der drei
  Möglichkeiten.
- **D20 belegt nichts, was ein anderer Schritt zu belegen hat.** Er prüft, dass
  eine Anforderungskennung als Überschrift im Backlog steht. Er sagt damit
  **nicht**, dass zu dieser Anforderung ein Test existiert — das ist die Aussage
  von D7 — und nicht, dass das Nachweisverzeichnis stimmt — das ist D12. Die
  Aussagen werden nicht vermischt, und ein grüner D20 ersetzt keinen der beiden.

**Die fehlende Abnahme wird nicht durch diese Fortschreibung geheilt.** Sie ist
als **O-15** terminiert: Ein Werkzeug, das eine Nachweiskette blockiert,
braucht eine Abnahme durch Static und Dynamic Software Tester auf einem anderen
Modell als die Umsetzung (3.4). Die Aufnahme in die Kette hängt nicht daran —
ein nicht abgenommenes Werkzeug, das Funde meldet und nichts darüber hinaus
behauptet, ist besser als kein Werkzeug —, aber der Zustand wird geführt und
nicht vergessen. Bis zur Abnahme gilt der Satz aus der Übergabe unverändert:
Was das Skript findet, ist unabhängig belegt; was es über sich selbst sagt, ist
es nicht.

#### 6.8.5 Die Ausnahmeliste ist Teil des Prüfmittels, nicht seine Umgehung

`scripts/belege-ausnahmen.txt` entscheidet, was ein Fund ist und was nicht. Sie
ist damit die einzige Stelle, an der sich D20 abschalten liesse, und deshalb
ein architektonischer Gegenstand.

**Was im ADR steht und was nicht.** Entschieden wird: Die **Regeln** der Liste
gehören in diesen ADR, die **Einträge** nicht. Die Einträge sind ein Inventar
des Bestandes; sie ändern sich mit jedem Dokument. Eine Liste, die
wöchentlich wechselt, in einem ADR zu führen, machte den ADR zum
Pflegegegenstand und seine Fortschreibungen bedeutungslos — dieselbe
Überlegung, mit der Abschnitt 2 keine Versionsnummern nennt. Die Liste liegt
versioniert neben dem Skript und wird dort gelesen.

**Vier Eigenschaften, die dieser ADR festlegt.** Sie sind im gelesenen
Quelltext bereits umgesetzt; sie stehen hier, weil sie sonst durch eine
Änderung am Skript stillschweigend wegfallen könnten.

1. **Jeder Schlüssel ist ortsgebunden.** Zulässig sind genau zwei Formen: die
   Bindung an einen Fundort aus Datei und Zeilennummer und die Bindung an einen
   Wert innerhalb einer bestimmten Datei. Eine dritte Form gibt es nicht; ein
   blosser Wert ohne Datei ist selbst ein Befund. Grund: Eine wertgebundene
   Ausnahme unterdrückt jedes künftige Vorkommen desselben Wortlauts im ganzen
   Bestand — auch einen echten neuen Fehler. Damit wäre die Fehlerklasse, gegen
   die das Werkzeug gebaut ist, in das Werkzeug selbst gewandert: eine Ausnahme
   mit richtigem historischem Grund würde zur Aussage über alle künftigen
   Vorkommen.
2. **Jeder Eintrag trägt einen geschriebenen Grund.** Ein Eintrag ohne Grund ist
   ein Befund. Eine Ausnahme ohne Begründung ist eine Lücke mit Deckmantel.
3. **Ein Eintrag, dessen Gegenstand entstanden ist, ist ein Befund.** Sonst
   deckt die Zeile beim nächsten Mal etwas Echtes zu. Die benannte Grenze dieses
   Rückgleichs — Schlüssel der Fundortform und nicht pfadförmige Werte werden
   nicht zurückgeglichen — bleibt eine benannte Grenze und wird nicht durch eine
   Neuformulierung überdeckt; die dritte Prüfrunde ist genau daran gescheitert,
   und die Behebung war eine Streichung, weil eine Streichung keinen neuen
   Fehlalarm einführen kann.
4. **Die Liste wird geschrieben, nicht abgeleitet.** Sie wird nicht zur Laufzeit
   erzeugt und nicht aus `.gitignore` oder einer anderen Quelle abgeleitet. Das
   ist derselbe Massstab wie in 6.2.3 für den Ausschluss bei D11: namentlich
   aufgezählt und versioniert abgelegt. Sie ist damit ausdrücklich **kein**
   erzeugtes Artefakt und fällt nicht unter die Regel für `docs/NACHWEISE.md`
   und den Ordner der Nachweise, die von Hand nie bearbeitet werden.

**Wer sie pflegen darf.** Auch das ist bereits entschieden, für die
Ausnahmeliste von D11 in 6.2.3, und wird übernommen statt neu erfunden: Eine
Ausnahme entsteht ausschliesslich zu einem **belegten** Fehlalarm, je Eintrag
mit Fundstelle und Begründung; eine pauschale Ausnahme ist unzulässig, weil sie
das Gate stillschweigend abschaltet. Daraus folgt für D20:

| Vorgang | Wer | Bedingung |
|---|---|---|
| Einen ortsgebundenen Eintrag hinzufügen oder entfernen | Die Rolle, deren Dokument den Fund ausgelöst hat | Nur zu einem belegten Fehlalarm, mit Fundstelle und geschriebenem Grund, der die **Tatsache** nennt und nicht die Absicht. Der Eintrag unterliegt der Verifikation wie jede andere Änderung; die schreibende Rolle prüft ihn nicht selbst (3.4) |
| Eine ganze Fallgruppe von der Prüfung ausnehmen | Niemand über die Ausnahmeliste | Das ist keine Ausnahme, sondern eine Änderung der Prüfung. Sie geht über eine Fortschreibung dieses ADR und eine Änderung am Skript, nicht über eine Zeile in der Liste |
| Die Form der Schlüssel, die beiden Selbstprüfungen oder die Prüffläche ändern | Software Architect, als Fortschreibung dieses ADR | Es sind die vier Eigenschaften oben |

**Die Grenze zwischen Ausnahme und Regel ist die tragende Unterscheidung.** Ein
Eintrag in der Liste sagt: *An dieser einen Stelle ist der Fund kein Fehler.*
Eine neue Regel im Skript sagt: *Diese Art von Stelle wird nicht mehr geprüft.*
Das Zweite ist eine Architekturentscheidung und darf nicht die Form des Ersten
annehmen. Genau diese Verwechslung — eine ortsungebundene Ausnahme, die
faktisch eine Regel war — ist der Befund der ersten der drei gescheiterten
Prüfrunden.

#### 6.8.6 Was diese Fortschreibung nicht ändert

D1 bis D12, D18 und D19 bleiben in Befehl, Objektbedingung und Prüfmitteln
unverändert; hinzu kommt allein D20 und seine Stellung vor D1. Die
Werkzeugwahl aus 3.12 bleibt unverändert — D20 ist kein Teststack, sondern eine
Prüfung über den Dokumentationsbestand. Der Kettengrundsatz aus 6.1.3 und seine
Beobachtung durch D19 aus 6.2.2 gelten für D20 unverändert und ohne Ausnahme.
Die Nummernregel aus 6.1.2 bleibt in Kraft und wird um den Satz ergänzt, dass
eine Nummer mit ihrer Vergabe in einem ADR vergeben ist (6.8.1). Die offenen
Schwellenwerte (O-7), die offenen Formfragen zu D10 und D12 (O-8), die
Restfragen aus O-10 und der Lauf auf der Gegenseite (O-12) bleiben offen. Der
Befund zum untauglichen Abgleich über einen Verzeichnisvergleich in D12 bleibt
bestehen. Nicht entschieden wird die Abnahme des Werkzeugs (O-15) und nicht der
fest verdrahtete Ort des zweiten Arbeitsbaums (O-14); beides ist terminiert,
nicht erledigt. Diese Fortschreibung legt keine Datei an ausser dieser: Die
Umsetzung im Makefile und die Nachführung von
`docs/06_Definition_of_Ready_und_Done.md` stehen in Abschnitt 9 und liegen bei
anderen Rollen.

### 6.9 Neunte Fortschreibung vom 2026-09-01 — die Beobachtbarkeit des Index gehört zum Prüfmittel von D19

**Anlass.** Der Requirements Engineer hat beim Nachtragen von D19 und D20 in
`docs/06_Definition_of_Ready_und_Done.md` gemeldet, dass das Prüfmittel von D19
an zwei Stellen verschieden steht, und hat den Befund ausdrücklich **nicht**
selbst gelöst. Das ist der vorgesehene Weg (CLAUDE.md: Abweichungen von diesem
ADR nur als Fortschreibung) und dasselbe Vorgehen, das schon der dritten
Fortschreibung vom 2026-08-30 zugrunde lag: melden statt stillschweigend
entscheiden.

**Beleglage dieser Fortschreibung.** Wie in 6.8 wird getrennt, worauf welche
Aussage beruht. Diese Rolle hat den D19-Teil des Ziels `dod` im Makefile
gelesen; sie hat **nichts ausgeführt**. Aussagen über den *Aufbau* der Umsetzung
— welche Grössen vor und nach dem Lauf erhoben werden, welcher Vergleich zu
welchem Ausgang führt, dass der Rückgabewert nur von 0 auf ungleich 0 angehoben
wird — stammen aus dem gelesenen Quelltext. Die Aussage, dass sich die
Beobachtung durch `git update-index --assume-unchanged` beziehungsweise
`--skip-worktree` tatsächlich abschalten lässt, ist **nicht** eigene
Beobachtung: Der Kommentar E5 an der betreffenden Stelle des Makefiles führt
dafür einen ausgeführten Beleg an, und diese Fortschreibung übernimmt ihn als
Fremdbeleg. Was dieser Beleg **nicht** abdeckt, ist in 6.9.4 als offener Punkt
festgehalten, statt es zu vermuten.

#### 6.9.1 Der Befund

| | |
|---|---|
| **Vorher galt** | Als Mittel von D19 nannten die Tabelle in Abschnitt 6 und die vierte Fortschreibung (6.4) die Statusliste `git status --porcelain --untracked-files=all` und eine Inhaltsprüfsumme je verfolgter Datei. Von den Maskierungsmerkmalen des Index stand in diesem ADR nichts |
| **Jetzt gilt** | Die Beobachtbarkeit des Index ist zweiter Teil des Prüfmittels: Der Bestand der Merkmale `assume-unchanged` und `skip-worktree` wird vor und nach dem Lauf erhoben. Ein gesetztes Merkmal ergibt Lage C mit eigenem Befundtext |

Die Umsetzung war der Festlegung also voraus. Das ist die unangenehmere der
beiden Richtungen — eine Umsetzung, die weniger tut als der ADR, ist ein
gewöhnlicher Mangel; eine, die mehr tut, ist eine Entscheidung, die niemand
getroffen hat. Beide Male gilt derselbe Satz aus 6.3: Der Befund wird
entschieden, nicht angeglichen.

**Zwei Wege standen offen.** Entweder die Beobachtung aus dem Makefile
entfernen, weil sie dort nichts zu suchen hat, oder sie in das Prüfmittel
aufnehmen. Entschieden wird: **aufnehmen.**

**Weshalb aufnehmen und nicht entfernen.** D19 sagt: Der Bestand der
versionierten Dateien ist vor und nach dem Lauf derselbe. Diese Aussage ruht auf
einem Messmittel, und ein Teil dieses Messmittels — `git status` — richtet sich
nach dem Index. Ein Kettenschritt, der ein Maskierungsmerkmal setzt, verändert
damit nicht den Gegenstand, sondern **das Messmittel**. Das Ergebnis wäre nicht
ein falsches Urteil, sondern ein Urteil ohne Grundlage: D19 meldete "unverändert"
über eine Datei, die es nicht mehr ansehen kann. Genau diese Falschaussage ist
der Grund, aus dem D19 überhaupt existiert — die zweite Fortschreibung hat sie
mit dem Satz eingeführt, beobachtbar genüge nicht, beobachtet werde verlangt.
Eine Beobachtung zu entfernen, die feststellt, ob überhaupt noch beobachtet
werden kann, hiesse, diesen Satz zurückzunehmen.

**Einordnung in das Muster.** Es ist zum dritten Mal derselbe Fehler auf einer
neuen Ebene. Die Schlussprüfung vom 2026-08-30 hat ihn benannt: *gemessen wird
die Verfügbarkeit eines Namens statt die Anwesenheit des Gegenstands.* 6.4 hat
ihn eine Ebene höher geschlossen: die Statusliste misst eine Liste von Namen
statt den Inhalt. Diese Fortschreibung schliesst ihn eine Ebene darüber: **Es
genügt nicht, den Gegenstand zu messen; es muss auch feststehen, dass das
Messmittel misst.** Damit ist die Reihe an ihrem Ende angelangt — was das
Messmittel des Messmittels prüft, ist keine Eigenschaft der Kette mehr, sondern
der Lauf auf der Gegenseite aus O-12.

#### 6.9.2 Der Ausgang "nicht beobachtbar" ist Lage C — und Lage C wird dafür geschärft

Der gemeldete Punkt trifft zu: Der Ausgang war bisher keine der drei Lagen. Das
ist selbst eine Festlegung, und sie wird hier getroffen.

**Optionen.**

| Option | Bewertung |
|---|---|
| (a) Eine vierte Lage D "Gegenstand vorhanden, Prüfmittel vorhanden, aber stummgeschaltet" | Beschreibt den Fall genau. Dagegen: Das Lagenschema gilt für **alle** Kettenschritte; eine vierte Lage müsste für jeden von ihnen bestimmt werden, obwohl sie nur bei D19 auftritt. Ein Schema um eines Einzelfalls willen zu erweitern, macht es für die anderen fünfzehn Fälle ungenauer |
| (b) Unter Lage C fassen und Lage C schärfen | Der Ausgang ist bereits derselbe: ungleich 0, kein bestandener Schritt. Der tragende Satz von Lage C — ein Schritt, der nicht urteilen kann, meldet nicht "bestanden" — passt wörtlich. Verlangt eine Präzisierung der C-Bedingung, die ohnehin fällig ist |
| (c) Als Verletzung des Kettengrundsatzes behandeln (wie eine Abweichung des Bestandes) | Abgelehnt. Das behauptete, der Arbeitsbaum sei verändert worden. Bekannt ist aber gerade das Gegenteil: Es ist **nicht bekannt**, ob er verändert wurde. Ein Nachweis, der Ungewissheit als Feststellung ausgibt, ist als Nachweis untauglich (5.3) — dieselbe Begründung, mit der die Schlusszeile schon einmal getrennt werden musste |
| (d) Nur melden, nicht blockieren | Abgelehnt, aus dem in 6.2.3 bereits entschiedenen Grund: Eine Meldung, die nicht blockiert, wird in einem Stop-Hook nicht gelesen; eine abgestufte Wirkung ist eine Abschaltung mit besserem Namen (5.4) |

**Entscheid: (b).** Lage C lautet neu — Gegenstand vorhanden, Prüfmittel fehlt
**oder trägt die Aussage nicht**: es ist unlesbar, unbrauchbar oder
stummgeschaltet. Der Ausgang bleibt unverändert ungleich 0.

**Weshalb das keine Ausweitung, sondern eine Klarstellung ist.** Die Umsetzung
behandelt einen vorhandenen, aber unbrauchbaren Prüfgegenstand schon heute als
Lage C, und dieser ADR trägt es an zwei Stellen mit: D18 meldet Lage C, wenn
`backend/importvertraege.toml` zwar existiert, aber nicht lesbar ist, und D7
endet nach 6.3.2 ungleich 0, wenn die gefundene Backlog-Datei keine
Abnahmekriterien führt — in beiden Fällen ist das Prüfmittel da und trägt die
Aussage nicht. Die C-Bedingung war also bereits weiter, als ihr Wortlaut sagte.
Diese Fortschreibung bringt den Wortlaut auf den Stand der bereits getroffenen
Entscheidungen, statt eine neue Freiheit zu schaffen.

**Der eigene Befundtext bleibt.** Lage C ist die Lage, nicht die Meldung. Ein
Lauf muss unterscheidbar machen, **welcher** C-Fall eingetreten ist — `git`
fehlt, oder `git` ist da und der Index ist maskiert. Das Makefile trennt beide
Texte bereits, und der Grund steht dort ausdrücklich als Anmerkung zur
Nachweiszeile nach 5.3: Eine Schlusszeile, die "beobachtet und in Ordnung" mit
"gar nicht beobachtet" verschmilzt, ist als Nachweis untauglich. Dieselbe
Trennung gilt jetzt auch begrifflich.

**Der absolute Massstab für das Instrument, und weshalb er dem Massstab für den
Gegenstand nicht widerspricht.** Für den Gegenstand gilt seit der zweiten
Fortschreibung: vorher gegen nachher, nicht gegen einen sauberen Arbeitsbaum —
ein bereits veränderter Arbeitsbaum ist zulässig. Für das Instrument gilt das
**nicht**: Ein Maskierungsmerkmal, das schon vor dem Lauf gesetzt war, ist
ebenso ein Befund wie eines, das während des Laufs gesetzt wurde. Der
Unterschied hat einen Grund, und es ist nicht Strenge um ihrer selbst willen:
Ein veränderter Arbeitsbaum ist der normale Betriebszustand vor einem Commit
und beeinträchtigt die Messung nicht. Ein maskierter Index beeinträchtigt sie
für die ganze Dauer des Laufs — die Vorher-Aufnahme ist dann bereits blind, und
ein Vergleich zweier blinder Aufnahmen ergibt zuverlässig "keine Abweichung".
Das ist dieselbe Unterscheidung, die 6.2.3 für D11 getroffen hat: Ein Fund im
Arbeitsbaum ist immer ein Befund und nie ein Betriebszustand. **Der Gegenstand
wird relativ gemessen, das Instrument absolut verlangt.**

#### 6.9.3 Ein zweiter, kleinerer Unterschied derselben Art in derselben Zeile

Beim Lesen des D19-Teils ist ein zweiter Punkt aufgefallen, den der gemeldete
Befund nicht nennt; er wird hier mitentschieden, weil er dieselbe Tabellenzeile
betrifft und dieselbe Ursache hat.

| | |
|---|---|
| **Vorher galt** | Die Objekttabelle nannte als Erkennungsmerkmal von D19 "`.git/` vorhanden" — ein Verzeichnisname |
| **Jetzt gilt** | Erkennungsmerkmal ist, dass die Versionsverwaltung einen Arbeitsbaum meldet; ist `git` nicht ausführbar, hilfsweise die Anwesenheit von `.git` als **Datei oder** Verzeichnis |

Der Grund steht als Anmerkung B2 im Makefile und ist dort als blockierender
Befund der Schlussprüfung vom 2026-08-30 vermerkt: In einem zusätzlichen
Arbeitsbaum und in einem Untermodul ist `.git` eine **Datei**, kein Verzeichnis.
Eine Prüfung auf ein Verzeichnis meldete dort Lage B und beobachtete nichts,
obwohl der Baum voll versioniert war — und der Betrieb auf einem Arbeitszweig
nach CLAUDE.md macht zusätzliche Arbeitsbäume zu einer naheliegenden
Arbeitsform. Das ist wörtlich Regel 1 aus 6.2.2: Die Lage wird an einem
Pfadnamen festgemacht statt am Gegenstand. Die Umsetzung hatte den Fehler
bereits behoben; nur die Tabelle, die nach Regel 2 allein massgeblich ist, trug
ihn noch.

#### 6.9.4 Was diese Fortschreibung offenlässt — O-16

Nicht entschieden, weil nicht ohne einen ausgeführten Lauf entscheidbar: **wie
weit die Maskierungsmerkmale die Messung tatsächlich beeinträchtigen.** Das
Instrument hat zwei Teile. Die Statusliste richtet sich nach dem Index; für sie
ist die Beeinträchtigung belegt. Die Inhaltsprüfsumme je verfolgter Datei liest
dagegen den Dateiinhalt über den Pfad. Ob sie eine Änderung an einer maskierten
Datei weiterhin erfasst — und damit, ob die Maskierung D19 halb oder ganz blind
macht —, ist eine Frage über das Verhalten eines Werkzeugs und wird hier
**nicht behauptet**, in keine der beiden Richtungen. Sie ist als **O-16**
terminiert und mit einem ausgeführten Lauf zu beantworten.

**Am Entscheid ändert die Antwort nichts, und das ist Absicht.** Fällt sie so
aus, dass die Prüfsumme weiterhin greift, bleibt die Maskierung trotzdem ein
Befund: Ein Instrument, dessen eine Hälfte stummgeschaltet ist, trägt die
Aussage von D19 nicht mehr vollständig, und die Kette soll nicht auf der
stillschweigenden Annahme beruhen, die andere Hälfte fange es schon auf. Die
Antwort bestimmt also nicht, **ob** gemeldet wird, sondern **wie genau** die
Befundmeldung sagen darf, was ungewiss geworden ist. Genau deshalb steht sie als
offener Punkt und nicht als Vermutung im Entscheid.

#### 6.9.5 Was diese Fortschreibung nicht ändert

Der Gegenstand von D19 bleibt unverändert der Bestand der versionierten Dateien
über die Dauer eines Laufs; die Aufnahme aus Statusliste und Inhaltsprüfsumme
aus 6.4 bleibt unverändert und wird ergänzt, nicht ersetzt. D19 bleibt
Rahmenprüfung ohne eigenes `make`-Ziel und ohne Platz in der Zielliste. Die
Eigenschaft "kann einen grünen Lauf rot machen, nie einen roten grün" bleibt.
Kein Kettenschritt D1 bis D12, D18 oder D20 ändert sich in Befehl,
Objektbedingung oder Prüfmitteln; die Schärfung von Lage C beschreibt für sie,
was bei D7 und D18 ohnehin schon galt. Der Kettengrundsatz aus 6.1.3, die
Nummernregel aus 6.1.2 und der Grundsatz aus 6.8.4 zur Aussagekraft eines
Rückgabewerts 0 bleiben in Kraft. Die offenen Punkte O-7, O-8, O-10, O-12, O-14
und O-15 bleiben offen. Nicht entschieden wird O-16.

**Erledigt und hier nur vermerkt:** Die in 6.8.1 festgestellte
Nachführungslücke — `docs/06_Definition_of_Ready_und_Done.md` führte D19 nicht,
weshalb die Nummer dort als frei erschien — ist geschlossen; D19 und D20 stehen
jetzt dort. Der Satz aus 6.8.1 bleibt als Regel bestehen: Eine D-Nummer ist
vergeben, sobald ein ADR sie vergibt.

### 6.10 Zehnte Fortschreibung vom 2026-09-01 — O-16 beantwortet: eine Hälfte des Instruments ist stumm, nicht beide

**Anlass.** O-16 ist am selben Tag beantwortet worden, an dem er entstanden ist,
und zwar mit dem Mittel, das dieser ADR dafür verlangt: einem ausgeführten Lauf
statt einer Vermutung. 6.9.4 hatte die Frage ausdrücklich in keine Richtung
behauptet. Sie ist jetzt gemessen.

**Beleglage — Fremdbeleg, kein eigener Lauf.** Die Zahlen unten stammen aus
einem Lauf des Koordinators, nicht aus einer eigenen Beobachtung dieser Rolle;
diese Rolle hat auch für diese Fortschreibung nichts ausgeführt. Übernommen wird
das Ergebnis als Fremdbeleg mit Angabe des Versuchsaufbaus, damit nachprüfbar
ist, was gemessen wurde — und, ebenso wichtig, was nicht.

#### 6.10.1 Das Messergebnis

**Versuchsaufbau** (Fremdbeleg): Wegwerf-Klon des Repositories,
`git update-index --skip-worktree CLAUDE.md`, danach eine Zeile an die Datei
angehängt; beide Hälften des Instruments jeweils vorher und nachher aufgenommen.

| Instrumententeil | vorher | nachher | Ergebnis |
|---|---|---|---|
| Statusliste (`git status --porcelain --untracked-files=all`) | 0 Zeilen | 0 Zeilen | **blind** — meldet die Änderung nicht |
| Inhaltsprüfsumme je verfolgter Datei | `36ef1067b2eaf772…` | `b58f937bac3b839e…` | **erfasst die Änderung** |

**Was das feststellt.** Die Maskierung schaltet **eine** Hälfte des Instruments
stumm, nicht beide. Die Inhaltsprüfsumme liest über den Pfad und sieht die
Änderung weiterhin.

**Was das nicht feststellt.** Der Versuch deckt die Änderung des Inhalts einer
vorhandenen, maskierten Datei ab. Er sagt nichts über die Löschung einer
maskierten Datei (6.10.4), nichts über Rechte- und Typwechsel und nichts über
Einträge, die allein die Statusliste sieht — unverfolgte Dateien und den
Zustand des Index. Diese Aufzählung ist die Grenze des Belegs, nicht die Grenze
des Instruments; sie wird hier genannt, weil ein Beleg, dessen Reichweite
unausgesprochen bleibt, wieder zu der Aussage würde, die stärker ist als ihre
Quelle.

#### 6.10.2 Was die Befundmeldung sagen darf — und was nicht mehr

| | |
|---|---|
| **Vorher galt** | Der Ausgang war als "nicht beobachtbar" benannt; die Tabelle in Abschnitt 6 sagte, ob der Kettengrundsatz verletzt sei, lasse sich "gerade nicht sagen" |
| **Jetzt gilt** | Die Meldung nennt, **welche Hälfte** des Instruments stumm ist, für **welche Dateien**, und was die andere Hälfte gemessen hat. Sie behauptet nicht mehr, der Arbeitsbaum sei unbeobachtet |

Der Koordinator hat den Befundtext im Makefile bereits so benannt — er nennt
ausdrücklich Lage C und führt das Messergebnis mit. Diese Fortschreibung deckt
das und legt den Massstab dafür fest.

**Die Aussage, die nach dem Messergebnis noch trägt**, lautet für einen Lauf mit
gesetzter Maskierung und ohne Abweichung der Prüfsummen: *Der Inhalt der
verfolgten Dateien ist unverändert. Für die maskierten Dateien trägt allein die
Inhaltsprüfsumme; alles, was nur die Statusliste sieht, ist für sie nicht
beurteilt.* Das ist schwächer als "unbeobachtet" und schwächer als "unverändert"
— und es ist die einzige der drei Aussagen, die belegt ist.

**Weshalb die Genauigkeit hier mehr ist als Wortklauberei.** Nach 5.3 ist die
Ausgabe der Kette eine Protokollspur, und Negativbefunde sind darin zwingend
enthalten. Ein Negativbefund, der zu viel behauptet, ist derselbe Mangel wie ein
fehlender: Wer später liest, "der Arbeitsbaum war unbeobachtet", schliesst
daraus, dass über den Inhalt nichts bekannt war — obwohl er gemessen wurde. Der
Protokolleintrag wäre dann in der einen Richtung falsch, in der er nicht falsch
sein darf. Dieselbe Überlegung hat im Makefile bereits dazu geführt, "beobachtet
und in Ordnung" von "gar nicht beobachtet" zu trennen; sie wird hier eine Stufe
feiner fortgesetzt.

#### 6.10.3 Der absolute Massstab bleibt — eine Zeile seiner Begründung wird berichtigt

**Der Entscheid aus 6.9.2 bleibt unverändert:** Ein gesetztes
Maskierungsmerkmal ist ein Befund, auch wenn es schon vor dem Lauf gesetzt war,
und der Ausgang ist Lage C.

**Berichtigt wird eine Begründungszeile.** 6.9.2 stützte den absoluten Massstab
unter anderem auf den Satz, die Vorher-Aufnahme sei dann bereits blind und ein
Vergleich zweier blinder Aufnahmen ergebe zuverlässig "keine Abweichung". Das
gilt nach dem Messergebnis **nur für die Statusliste**, nicht für das Instrument
als Ganzes. Der Satz war für beide Hälften formuliert und behauptete damit mehr,
als er trug. Er wird hier nicht gelöscht — 6.9 bleibt als früherer Stand stehen,
wie jede vorangegangene Fortschreibung —, sondern an dieser Stelle berichtigt.
Das ist genau der Vorgang, den dieser ADR von allen Beteiligten verlangt, und er
gilt auch für die Rolle, die ihn schreibt.

**Weshalb der Entscheid die Berichtigung übersteht — drei Gründe, die vom
Messergebnis unabhängig sind.**

1. **Ein Instrument mit einer stummen Hälfte ist kein vollständiges
   Instrument.** D19 hat zwei Teile, weil ein Teil nicht genügte; das war der
   Inhalt der vierten Fortschreibung. Wenn einer davon ausfällt, ist die
   Zusicherung von D19 nicht mehr die, die entschieden wurde. Ob der Rest
   "wahrscheinlich reicht", ist keine Kategorie einer Bauvorschrift (5.4).
2. **Die Reichweite des Rests ist selbst nicht vollständig gemessen.** Der
   Löschfall steht offen (6.10.4). Den absoluten Massstab auf eine Deckung zu
   stützen, deren Umfang unbekannt ist, wäre dieselbe Annahme, gegen die 6.9
   entschieden hat — nur eine Ebene versetzt.
3. **Der Massstab kostet im Normalfall nichts.** Ein Maskierungsmerkmal
   entsteht nicht versehentlich; es wird gesetzt. Wo keines gesetzt ist, meldet
   der Schritt nichts. Der absolute Massstab verlangt also niemandem etwas ab
   ausser dem, der das Messmittel stummgeschaltet hat — und dass genau das
   sichtbar wird, ist der Zweck.

**Was sich durch die Berichtigung tatsächlich ändert**, ist nicht die Farbe des
Laufs, sondern der Satz, mit dem er begründet wird: Der Befund heisst nicht mehr
"es konnte nichts beobachtet werden", sondern "das Instrument war unvollständig,
und zwar in diesem benannten Teil".

#### 6.10.4 Der nicht gemessene Fall — O-17

Ausdrücklich als Restpunkt geführt und nicht vermutet: **Was geschieht, wenn
eine maskierte, verfolgte Datei gelöscht wird?** Die Aufzählung der verfolgten
Dateien führt sie weiter, weil sie im Index steht; die Prüfsummenbildung findet
die Datei dann nicht vor. Ob die Aufnahme dadurch abweicht — und die Löschung
damit trotz Maskierung sichtbar wird — oder ob sie unverändert bleibt, ist
**nicht gemessen worden**. Dieser ADR behauptet dazu nichts und führt die Frage
als **O-17**.

Auch hier gilt, was schon für O-16 galt: Am Entscheid ändert die Antwort nichts.
Eine gesetzte Maskierung bleibt ein Befund, und der Ausgang bleibt Lage C. Die
Antwort bestimmt allein, wie weit die Meldung nach 6.10.2 sagen darf, dass der
Inhalt beurteilt sei. Fällt sie ungünstig aus, ist die Aussage über die
maskierten Dateien enger zu fassen — eine Fortschreibung der Meldung, nicht des
Entscheids.

#### 6.10.5 Was diese Fortschreibung nicht ändert

Der Entscheid aus 6.9 bleibt in allen Teilen: Die Beobachtbarkeit des Index ist
zweiter Teil des Prüfmittels von D19, ein gesetztes Maskierungsmerkmal ergibt
Lage C, der Gegenstand wird relativ gemessen und das Instrument absolut
verlangt, und die geschärfte Lage C gilt für alle Kettenschritte. Gegenstand,
Mittel und Massstab von D19 bleiben unverändert; geändert wird ausschliesslich,
was die **Meldung** behaupten darf. Kein Kettenschritt D1 bis D12, D18 oder D20
ändert sich. Der Kettengrundsatz aus 6.1.3, die Nummernregel aus 6.1.2 und der
Grundsatz aus 6.8.4 bleiben in Kraft — letzterer erhält mit diesem Fall sein
genauestes Beispiel: Ein Rückgabewert sagt, was der Schritt gefunden hat, und
eine Befundmeldung darf nicht mehr behaupten, als der Schritt messen konnte. Die
offenen Punkte O-7, O-8, O-10, O-12, O-14 und O-15 bleiben offen; O-16 ist
geschlossen, O-17 ist neu.

### 6.11 Elfte Fortschreibung vom 2026-09-01 — ein blockierender und fünf nachrangige Befunde behoben, eine Lücke geschlossen

**Anlass.** Eine unabhängige Prüfung auf einem anderen Modell als die
Umsetzung — Static Software Tester, Dynamic Software Tester und Protocol
Master, alle drei am 2026-09-01 — hat gegen die achte bis zehnte
Fortschreibung einen blockierenden und fünf nachrangige Befunde gebracht. Der
Koordinator hat jeden Befund gegen diese Datei und gegen einen ausgeführten
Lauf nachgeprüft und behoben. Diese Fortschreibung dokumentiert den Entscheid;
sie trifft ihn nicht neu.

**Beleglage dieser Fortschreibung.** Wie in 6.8 und 6.9 wird getrennt, worauf
welche Aussage beruht. Diese Rolle hat den vollständigen, bereits behobenen
Quelltext von `scripts/belege-pruefen.sh` und die einschlägigen Stellen von
`Makefile` gelesen; sie hat **nichts selbst ausgeführt**. Aussagen über die
*Struktur* der Behebung — der neue Rückgabewert 3, die vorgeschaltete Prüfung
der drei Dateien, die getrennte Auswertung im Makefile-Ziel `belege`, die
Ersetzung von `wc -l` durch `awk`, die Streichung der beiden Aufzählungen, die
ergänzte Lagetabelle, das Trimmen der beiden D7-Meldungen, die laufbezogene
Zeile im D19-Zweig — stammen aus dem gelesenen Quelltext und sind dort
nachprüfbar. Aussagen über einen *ausgeführten Lauf* — die drei Gegenproben zu
Lage C, der Hintergrundlauf von `make dod` mit einer während des Laufs
geänderten Datei, die 67 auf einen Schlussumbruch geprüften Dateien — sind als
Fremdbeleg des Koordinators übernommen und hier als solche gekennzeichnet,
nicht als eigene Beobachtung. Dieselbe Trennung wie in 6.8 und 6.9, aus
demselben Grund: Eine Aussage über die Herkunft, die stärker ist, als die
Quelle sie trägt, ist genau die Fehlerklasse, gegen die der Belegprüfer gebaut
wurde und die diese Fortschreibung selbst behebt.

#### 6.11.1 Der blockierende Befund — wortgetreu belegt

Behauptet war an drei Stellen, dass ein fehlendes Bezugsdokument Lage C
ergibt: hier in 6.8.3 mit dem Satz „Deshalb stehen beide Dateien in der
Prüfmittelspalte: Lage C sagt, was los ist.", in der D20-Zeile der
Objekttabelle in Abschnitt 6 mit dem Satz „Fehlt eines davon, ist das Lage
C — nicht ein bestandener Schritt (6.8.3)." und im D20-Kriterium von
`docs/06_Definition_of_Ready_und_Done.md`. Gebaut war davon nichts: Das
Makefile-Ziel `belege` prüfte vor dieser Fortschreibung genau drei
Bedingungen — Skript vorhanden, `git` installiert, Git-Arbeitsbaum
vorhanden —, und im Skript stand vor den beiden `mapfile`-Zeilen, die die
Referenzmengen aus `docs/05_Product_Backlog.md` und
`docs/00_Projektauftrag.md` bilden, keine Existenzprüfung; die Ausnahmeliste
wurde über `if [ -f "$AUSNAHMEDATEI" ]` stillschweigend als „keine Ausnahmen"
behandelt.

**Gemessen** (isolierter Lauf des Koordinators, 2026-09-01, Fremdbeleg): `set
-uo pipefail` ohne `-e` lässt `mapfile` über eine fehlende Datei mit
Rückgabewert 0 laufen. Die Referenzmenge bleibt leer, und danach gilt jede
gültige Anforderungskennung im Bestand als ungültig. Das Ergebnis wäre
Rückgabewert 2 mit hunderten Scheinfunden gewesen — genau der Fehlermodus,
den 6.8.3 als vermieden beschreibt, aber nicht baute.

#### 6.11.2 Was behoben wurde, und wie es geprüft ist

1. **Neuer Rückgabewert 3 des Belegprüfers.** `scripts/belege-pruefen.sh`
   unterscheidet jetzt: 0 = keine Beanstandung, 2 = mindestens ein Befund, 3 =
   Lage C — ein Prüfmittel fehlt oder trägt die Aussage nicht. Grund für die
   Trennung: „rot, weil etwas gefunden wurde" und „rot, weil nicht gemessen
   werden konnte" sind verschiedene Aussagen. Bis zu dieser Fortschreibung
   kannten 6.8.3 und 6.8.4 nur 0 und 2; das ist unvollständig geworden und in
   6.11.5 berichtigt.
2. **Prüfung vor jeder Verwendung.** Das Skript prüft vor jeder Verwendung
   `docs/05_Product_Backlog.md`, `docs/00_Projektauftrag.md` und
   `scripts/belege-ausnahmen.txt` auf Vorhandensein und Lesbarkeit, und
   zusätzlich — nach der geschärften Lage C aus 6.9 — ob die beiden
   Bezugsdokumente eine **nicht leere** Referenzmenge hergeben. Eine
   vorhandene, aber aussagelose Datei ist derselbe Ausfall wie eine fehlende.
   Für die Ausnahmeliste gilt nur der erste Teil: Eine vorhandene Liste ohne
   Einträge ist ein zulässiger Zustand, eine fehlende lässt jede begründete
   Ausnahme stumm wegfallen.
3. **Getrennte Auswertung im Makefile.** Das Ziel `belege` prüft dieselben
   drei Dateien vorab und wertet den Rückgabewert des Skripts getrennt aus: 3
   wird Lage C, jeder andere Wert ungleich 0 wird A_FAIL.

**Ausgeführt belegt am 2026-09-01** (Fremdbeleg, drei Gegenproben, Arbeitsbaum
jeweils vorher und nachher gleich):

- Ausnahmeliste beiseitegelegt: `make belege` meldet Lage C mit dem Hinweis,
  dass `scripts/belege-ausnahmen.txt` fehlt, samt einer entsprechenden
  Lage-Marke; das Skript allein endet mit Rückgabewert 3.
- Backlog beiseitegelegt: dieselbe Wirkung mit der auf den Backlog gemünzten
  Meldung, Skript ebenfalls 3.
- Backlog vorhanden, aber ohne jede Kennung als Überschrift: das Skript
  meldet, dass die Datei keine einzige Anforderungskennung als Überschrift
  trägt, und endet mit 3 — der zweite Teil der geschärften Lage C, erstmals
  ausgeführt belegt.

#### 6.11.3 Fünf nachrangige Befunde, ebenfalls behoben

a) **`wc -l` zählte Zeilenumbrüche statt Zeilen** (`scripts/belege-pruefen.sh`).
Einer Datei ohne abschliessenden Umbruch fehlte in der Zählung die letzte
Zeile; ein richtiger Verweis auf sie wäre fälschlich ein Fund gewesen — die
entgegengesetzte Fehlerrichtung zu den drei bisherigen Prüfrunden. Im
damaligen Bestand latent, weil alle 67 erfassten Dateien mit einem Umbruch
enden (Fremdbeleg, einzeln gemessen). Ersetzt durch `awk 'END{print NR+0}'`.
Gegenprobe: drei Zeilen ohne Schlussumbruch — `wc -l` sagt 2, `awk` sagt 3;
leere Datei: beide 0.

b) **Zwei veraltete Aufzählungen der Ausführungsreihenfolge** im
Makefile-Kommentar nannten D20 nicht, obwohl er seit dem 2026-09-01 als
erster Schritt läuft. Bemerkenswert: Der eine Absatz warnt wörtlich davor,
die Reihenfolge ein zweites Mal aufzuzählen, „die bei der nächsten
Fortschreibung erneut veralten könnte" — und führte im selben Absatz eine
solche Aufzählung, die genau so veraltet war. Die Aufzählungen sind
gestrichen, nicht nachgeführt: eine nachgeführte Aufzählung wäre beim
nächsten Schritt wieder falsch. Die Reihenfolge steht jetzt ausschliesslich
in `schritte_liste`.

c) **Die Lagetabelle im Makefile-Kopf führte D20 nicht.** Zeile ergänzt (Lage
A, keine Lage B nach 6.8.3), Überschrift auf „Stand des Bestands am
2026-08-30, um D20 ergänzt am 2026-09-01".

d) **Doppeltes Leerzeichen in zwei D7-Meldungen** (`Makefile`) durch `tr '\n'
' '` auf einem Einzeltreffer: `tr` macht auch aus dem abschliessenden
Zeilenumbruch ein Leerzeichen. Beide Pfade werden jetzt zusätzlich mit `sed`
beschnitten, je durch einen ausgeführten Lauf nachgemessen (Fremdbeleg).

e) **Der D19-Zweig für den stummgeschalteten Index sagte nicht, was die
andere Hälfte in DIESEM Lauf gemessen hat**, obwohl 6.10.2 genau das zusagt.
Er gab den allgemeinen O-16-Befund aus und schwieg über den Lauf; Schweigen
ist keine Messung. Der Code ist an die Zusage herangeführt worden, nicht die
Zusage abgeschwächt: Eine laufbezogene Zeile nennt jetzt, ob Statusliste und
Inhaltsprüfsummen vorher und nachher gleich waren, mit dem ausdrücklichen
Zusatz, dass diese Gleichheit den Lauf nicht entlastet, weil sie nicht
ausschliessen kann, was die blinde Hälfte gar nicht meldet. Ausgeführt belegt
am 2026-09-01 mit gesetztem `assume-unchanged` (Fremdbeleg).

#### 6.11.4 Eine geschlossene Lücke — D19 während eines laufenden `make dod`

Die dynamische Prüfung hat offengelassen, ob D19 eine **während des Laufs**
vorgenommene Änderung tatsächlich meldet — nur der Erfolgsfall war
beobachtet. Der Koordinator hat das am 2026-09-01 nachgeholt (Fremdbeleg):
`make dod` im Hintergrund gestartet, nach drei Sekunden eine verfolgte Datei
geändert. D19 meldete den Befund „VERLETZT", nannte den Kettengrundsatz als
Grundlage, benannte die betroffene Datei und zeigte **beide** Hälften des
Instruments — die Statuszeile und die geänderte Inhaltsprüfsumme. Damit ist
erstmals belegt, dass D19 nicht nur schweigt, wenn nichts ist, sondern auch
spricht, wenn etwas ist.

#### 6.11.5 Zwei Berichtigungen in dieser Datei

**Erstens, 6.8.3 und 6.8.4.** Beide Abschnitte nannten bis zu dieser
Fortschreibung nur die Rückgabewerte 0 und 2 des Belegprüfers und behandelten
damit „das Prüfmittel selbst ist ausgefallen" und „am Bestand wurde etwas
gefunden" als denselben Fall. Das ist seit 6.11.2 unvollständig; an beiden
Stellen steht jetzt ein kurzer Verweis auf diesen Abschnitt.

**Zweitens, die Tabelle der offenen Punkte in Abschnitt 8.** Sie führte
„O-10" zweimal: eine Zeile als offenen Punkt vom 2026-08-30, die
darunterliegende als „O-10 (neu gefasst)" mit dem Vermerk „Beantwortet am
2026-08-30". Die Nummernregel verlangt, dass die Nummer bleibt und Historie
nicht umgeschrieben wird; gelöscht wird deshalb keine Zeile. Die erste Zeile
ist als überholt gekennzeichnet und verweist auf die zweite.

#### 6.11.6 Neuer offener Punkt — O-18

Ob die drei Bezugsdokumente in der Prüfmittelspalte künftig auch auf
**Aktualität** und nicht nur auf Vorhandensein zu prüfen sind: Eine veraltete
Referenzmenge — eine Anforderungskennung, die im Backlog längst umbenannt
oder gestrichen wurde, ein Abschnitt des Projektauftrags, der verschoben
wurde — fällt heute durch kein Netz. Der Belegprüfer sieht nur, ob die
Dateien bestehen und eine nicht leere Referenzmenge hergeben, nicht, ob diese
Referenzmenge noch dem aktuellen Stand entspricht. Zuständig: Software
Architect mit dem Static Software Tester, terminiert mit R3-Q-001.

#### 6.11.7 Was diese Fortschreibung nicht ändert

Kennung, Stellung, Objektbedingung und die drei ursprünglichen Prüfmittel von
D20 bleiben unverändert; hinzu kommt ausschliesslich der dritte Rückgabewert
des Skripts und die vorgeschaltete Prüfung im Makefile, beide bereits als
Teil von 6.8 angelegt und hier zu Ende gebracht. Gegenstand, Mittel und
Massstab von D19 bleiben unverändert; geändert ist ausschliesslich, was die
laufbezogene Meldung zusätzlich nennt (6.11.3, Punkt e). Der Kettengrundsatz
aus 6.1.3, die Nummernregel aus 6.1.2 und der Grundsatz aus 6.8.4 zur
Aussagekraft eines Rückgabewerts 0 bleiben in Kraft; 6.8.4 gilt jetzt
sinngemäss auch für Rückgabewert 3 — auch er sagt nur, was das Prüfmittel
nicht leisten konnte, nie, dass am Bestand nichts wäre. D1 bis D12 und D18
bleiben unverändert. Die offenen Punkte O-7, O-8, O-10 (neu gefasst), O-12,
O-14, O-15 und O-17 bleiben offen. O-16 bleibt geschlossen. O-18 ist neu.

### 6.12 Zwölfte Fortschreibung vom 2026-09-02 — das Definition-of-Done-Gate aus R3-Q-001, entworfen; Bau auf Weisung vom 2026-09-02 begonnen, förmliche Freigabe ausstehend

Verschoben am 2026-10-22 nach ADR 0003 (`docs/adr/0003-definition-of-done-gate.md`), Teil B, unverändert; Wortlaut hier bis zum Schnitt: `docs/adr/0002-architekturentscheid-ziel-stack.md` beim Commit `ac6e0c17672ad9f0d139a59dba8ca319f46056c4`.

#### 6.12.1 Überblick über die Entscheide dieser Fortschreibung

Verschoben am 2026-10-22 nach ADR 0003 (`docs/adr/0003-definition-of-done-gate.md`), Teil B, unverändert; Wortlaut hier bis zum Schnitt: `docs/adr/0002-architekturentscheid-ziel-stack.md` beim Commit `ac6e0c17672ad9f0d139a59dba8ca319f46056c4`.

#### 6.12.2 G1 — Die drei Ereignisse, und welche Ebene welche Zusicherung trägt

Verschoben am 2026-10-22 nach ADR 0003 (`docs/adr/0003-definition-of-done-gate.md`), Teil B, unverändert; Wortlaut hier bis zum Schnitt: `docs/adr/0002-architekturentscheid-ziel-stack.md` beim Commit `ac6e0c17672ad9f0d139a59dba8ca319f46056c4`.

#### 6.12.3 G2 — Das Gate liest die Ausgabe, nicht nur den Rückgabewert

Verschoben am 2026-10-22 nach ADR 0003 (`docs/adr/0003-definition-of-done-gate.md`), Teil B, unverändert; Wortlaut hier bis zum Schnitt: `docs/adr/0002-architekturentscheid-ziel-stack.md` beim Commit `ac6e0c17672ad9f0d139a59dba8ca319f46056c4`.

#### 6.12.4 G3 — Frage 1: Wie das Gate einen Befund von einem ausgefallenen Prüfmittel unterscheidet

Verschoben am 2026-10-22 nach ADR 0003 (`docs/adr/0003-definition-of-done-gate.md`), Teil B, unverändert; Wortlaut hier bis zum Schnitt: `docs/adr/0002-architekturentscheid-ziel-stack.md` beim Commit `ac6e0c17672ad9f0d139a59dba8ca319f46056c4`.

#### 6.12.5 G4 — Frage 2: Was bei Lage C geschieht

Verschoben am 2026-10-22 nach ADR 0003 (`docs/adr/0003-definition-of-done-gate.md`), Teil B, unverändert; Wortlaut hier bis zum Schnitt: `docs/adr/0002-architekturentscheid-ziel-stack.md` beim Commit `ac6e0c17672ad9f0d139a59dba8ca319f46056c4`.

#### 6.12.6 G5 — Der blinde Fleck hinter dem ersten C, und weshalb die Kette dort nicht mehr abbricht

Verschoben am 2026-10-22 nach ADR 0003 (`docs/adr/0003-definition-of-done-gate.md`), Teil B, unverändert; Wortlaut hier bis zum Schnitt: `docs/adr/0002-architekturentscheid-ziel-stack.md` beim Commit `ac6e0c17672ad9f0d139a59dba8ca319f46056c4`.

#### 6.12.7 G6 — Die Lage-Marke trägt das fehlende Prüfmittel, nicht der Meldungstext

Verschoben am 2026-10-22 nach ADR 0003 (`docs/adr/0003-definition-of-done-gate.md`), Teil B, unverändert; Wortlaut hier bis zum Schnitt: `docs/adr/0002-architekturentscheid-ziel-stack.md` beim Commit `ac6e0c17672ad9f0d139a59dba8ca319f46056c4`.

#### 6.12.8 G7 — Vier eindeutige Schlusszeilen, eine eigenständige D19-Zeile, ein genannter Baum

Verschoben am 2026-10-22 nach ADR 0003 (`docs/adr/0003-definition-of-done-gate.md`), Teil B, unverändert; Wortlaut hier bis zum Schnitt: `docs/adr/0002-architekturentscheid-ziel-stack.md` beim Commit `ac6e0c17672ad9f0d139a59dba8ca319f46056c4`.

#### 6.12.9 G8 — Frage 3: Wie dreimaliges Scheitern am gleichen Kriterium erkannt wird, und wo gezählt wird

Verschoben am 2026-10-22 nach ADR 0003 (`docs/adr/0003-definition-of-done-gate.md`), Teil B, unverändert; Wortlaut hier bis zum Schnitt: `docs/adr/0002-architekturentscheid-ziel-stack.md` beim Commit `ac6e0c17672ad9f0d139a59dba8ca319f46056c4`.

#### 6.12.10 G9 — Frage 4: Wie `stop_hook_active` greift

Verschoben am 2026-10-22 nach ADR 0003 (`docs/adr/0003-definition-of-done-gate.md`), Teil B, unverändert; Wortlaut hier bis zum Schnitt: `docs/adr/0002-architekturentscheid-ziel-stack.md` beim Commit `ac6e0c17672ad9f0d139a59dba8ca319f46056c4`.

#### 6.12.11 G10 — Die Prüfmittel des Gates, und was bei deren Ausfall geschieht

Verschoben am 2026-10-22 nach ADR 0003 (`docs/adr/0003-definition-of-done-gate.md`), Teil B, unverändert; Wortlaut hier bis zum Schnitt: `docs/adr/0002-architekturentscheid-ziel-stack.md` beim Commit `ac6e0c17672ad9f0d139a59dba8ca319f46056c4`.

#### 6.12.12 G11 — Zeitüberschreitung: zwei Grenzen, und weshalb die innere die kleinere ist

Verschoben am 2026-10-22 nach ADR 0003 (`docs/adr/0003-definition-of-done-gate.md`), Teil B, unverändert; Wortlaut hier bis zum Schnitt: `docs/adr/0002-architekturentscheid-ziel-stack.md` beim Commit `ac6e0c17672ad9f0d139a59dba8ca319f46056c4`.

#### 6.12.13 G12 — Welcher Arbeitsbaum geprüft wird, und was bei Nebenläufigkeit gilt

Verschoben am 2026-10-22 nach ADR 0003 (`docs/adr/0003-definition-of-done-gate.md`), Teil B, unverändert; Wortlaut hier bis zum Schnitt: `docs/adr/0002-architekturentscheid-ziel-stack.md` beim Commit `ac6e0c17672ad9f0d139a59dba8ca319f46056c4`.

#### 6.12.14 G13 — `SubagentStop` und Rollen, die den Arbeitsbaum nicht ändern können

Verschoben am 2026-10-22 nach ADR 0003 (`docs/adr/0003-definition-of-done-gate.md`), Teil B, unverändert; Wortlaut hier bis zum Schnitt: `docs/adr/0002-architekturentscheid-ziel-stack.md` beim Commit `ac6e0c17672ad9f0d139a59dba8ca319f46056c4`.

#### 6.12.15 G14 — Sichtbarkeit: was gemeldet wird, wohin, und was nicht

Verschoben am 2026-10-22 nach ADR 0003 (`docs/adr/0003-definition-of-done-gate.md`), Teil B, unverändert; Wortlaut hier bis zum Schnitt: `docs/adr/0002-architekturentscheid-ziel-stack.md` beim Commit `ac6e0c17672ad9f0d139a59dba8ca319f46056c4`.

#### 6.12.16 G15 — Kein Zwischenspeicher des Urteils

Verschoben am 2026-10-22 nach ADR 0003 (`docs/adr/0003-definition-of-done-gate.md`), Teil B, unverändert; Wortlaut hier bis zum Schnitt: `docs/adr/0002-architekturentscheid-ziel-stack.md` beim Commit `ac6e0c17672ad9f0d139a59dba8ca319f46056c4`.

#### 6.12.17 G16 — Der flache Klon: die Vollständigkeit der Historie wird Prüfmittel von D20

Verschoben am 2026-10-22 nach ADR 0003 (`docs/adr/0003-definition-of-done-gate.md`), Teil B, unverändert; Wortlaut hier bis zum Schnitt: `docs/adr/0002-architekturentscheid-ziel-stack.md` beim Commit `ac6e0c17672ad9f0d139a59dba8ca319f46056c4`.

#### 6.12.18 Was ein Durchlass des Gates aussagt — und was nicht

Verschoben am 2026-10-22 nach ADR 0003 (`docs/adr/0003-definition-of-done-gate.md`), Teil B, unverändert; Wortlaut hier bis zum Schnitt: `docs/adr/0002-architekturentscheid-ziel-stack.md` beim Commit `ac6e0c17672ad9f0d139a59dba8ca319f46056c4`.

#### 6.12.19 G17 — Was der Selbsttest zu decken hat

Verschoben am 2026-10-22 nach ADR 0003 (`docs/adr/0003-definition-of-done-gate.md`), Teil B, unverändert; Wortlaut hier bis zum Schnitt: `docs/adr/0002-architekturentscheid-ziel-stack.md` beim Commit `ac6e0c17672ad9f0d139a59dba8ca319f46056c4`.

#### 6.12.20 Einordnung der drei übrigen Punkte aus dem Achtung-Hinweis zu R3-Q-001

Verschoben am 2026-10-22 nach ADR 0003 (`docs/adr/0003-definition-of-done-gate.md`), Teil B, unverändert; Wortlaut hier bis zum Schnitt: `docs/adr/0002-architekturentscheid-ziel-stack.md` beim Commit `ac6e0c17672ad9f0d139a59dba8ca319f46056c4`.

#### 6.12.21 Bezug zu den offenen Punkten, die das Gate berühren

Verschoben am 2026-10-22 nach ADR 0003 (`docs/adr/0003-definition-of-done-gate.md`), Teil B, unverändert; Wortlaut hier bis zum Schnitt: `docs/adr/0002-architekturentscheid-ziel-stack.md` beim Commit `ac6e0c17672ad9f0d139a59dba8ca319f46056c4`.

#### 6.12.22 Was diese Fortschreibung nicht ändert

Verschoben am 2026-10-22 nach ADR 0003 (`docs/adr/0003-definition-of-done-gate.md`), Teil B, unverändert; Wortlaut hier bis zum Schnitt: `docs/adr/0002-architekturentscheid-ziel-stack.md` beim Commit `ac6e0c17672ad9f0d139a59dba8ca319f46056c4`.

#### 6.12.23 Nachträge aus dem Bau vom 2026-09-02

Verschoben am 2026-10-22 nach ADR 0003 (`docs/adr/0003-definition-of-done-gate.md`), Teil B, unverändert; Wortlaut hier bis zum Schnitt: `docs/adr/0002-architekturentscheid-ziel-stack.md` beim Commit `ac6e0c17672ad9f0d139a59dba8ca319f46056c4`.

#### 6.12.24 Nachträge aus der Verifikation vom 2026-09-02

Verschoben am 2026-10-22 nach ADR 0003 (`docs/adr/0003-definition-of-done-gate.md`), Teil B, unverändert; Wortlaut hier bis zum Schnitt: `docs/adr/0002-architekturentscheid-ziel-stack.md` beim Commit `ac6e0c17672ad9f0d139a59dba8ca319f46056c4`.

#### 6.12.25 O-24 — die Prüftabelle in Zusicherungen zerlegt (Entscheid des Auftraggebers vom 2026-09-03)

Verschoben am 2026-10-22 nach ADR 0003 (`docs/adr/0003-definition-of-done-gate.md`), Teil B, unverändert; Wortlaut hier bis zum Schnitt: `docs/adr/0002-architekturentscheid-ziel-stack.md` beim Commit `ac6e0c17672ad9f0d139a59dba8ca319f46056c4`.

#### 6.12.26 O-25 — Kanal und Mutationsprobe je Zusicherung (Entscheid des Auftraggebers vom 2026-09-03)

Verschoben am 2026-10-22 nach ADR 0003 (`docs/adr/0003-definition-of-done-gate.md`), Teil B, unverändert; Wortlaut hier bis zum Schnitt: `docs/adr/0002-architekturentscheid-ziel-stack.md` beim Commit `ac6e0c17672ad9f0d139a59dba8ca319f46056c4`.

#### 6.12.27 O-26 — Prädikatbindung, Schlüssel- und Grammatikdeckung, Abnahmekriterium (Entscheid des Auftraggebers vom 2026-09-06)

Verschoben am 2026-10-22 nach ADR 0003 (`docs/adr/0003-definition-of-done-gate.md`), Teil B, unverändert; Wortlaut hier bis zum Schnitt: `docs/adr/0002-architekturentscheid-ziel-stack.md` beim Commit `ac6e0c17672ad9f0d139a59dba8ca319f46056c4`.

#### 6.12.28 O-27 — Deckung am Gegenstand für Pfade und Grammatik, Abnahmekriterium auf falsches Grün bezogen (Ausformung des Entscheids vom 2026-09-07)

Verschoben am 2026-10-22 nach ADR 0003 (`docs/adr/0003-definition-of-done-gate.md`), Teil B, unverändert; Wortlaut hier bis zum Schnitt: `docs/adr/0002-architekturentscheid-ziel-stack.md` beim Commit `ac6e0c17672ad9f0d139a59dba8ca319f46056c4`.

### 6.13 Neunzehnte Fortschreibung vom 2026-09-21 — E4: die beiden PreToolUse-Gates, ihre belegten Lücken und ihr Prüfmittel (R3-Q-010), festgelegt und nicht gebaut

Verschoben am 2026-10-22 nach ADR 0004 (`docs/adr/0004-pretooluse-gates.md`), Teil B, unverändert; Wortlaut hier bis zum Schnitt: `docs/adr/0002-architekturentscheid-ziel-stack.md` beim Commit `ac6e0c17672ad9f0d139a59dba8ca319f46056c4`.

### 6.14 Dreiundzwanzigste Fortschreibung vom 2026-09-23 — E3: fremde Inhalte im Harness, Regel und Skill zur Einschleusungsprüfung (R3-Q-011), festgelegt und nicht gebaut

Verschoben am 2026-10-22 nach ADR 0005 (`docs/adr/0005-fremde-inhalte-im-harness.md`), Teil B, unverändert; Wortlaut hier bis zum Schnitt: `docs/adr/0002-architekturentscheid-ziel-stack.md` beim Commit `ac6e0c17672ad9f0d139a59dba8ca319f46056c4`.

## 7. Konsequenzen

**7.1 Zwei Sprachstacks.** Python im Backend, TypeScript in der Oberfläche. Das kostet eine zweite Werkzeugkette, eine zweite Sperrdatei und eine grössere Lieferkettenfläche in D8 und D11. Angenommen wird das, weil die Alternative — ein Stack — an einer der beiden Seiten teurer wäre: entweder Nachbau der kanonischen Schemata oder handgeschriebene Interaktionslogik ohne geprüfte Bausteine für Barrierefreiheit.

**7.2 Die Garantien sitzen im Aufrufpfad, nicht im einzelnen Werkzeug.** Eine neue Quelle in Etappe 2 erbt Fallbindung, Freigabe, Protokollierung, Positivliste und Kontingentzählung, ohne dass die Anbindung sie selbst umsetzt. Umgekehrt heisst das: An diesem Aufrufpfad wird nichts vorbeigebaut, auch nicht „nur für einen Test". Die Architekturverträge aus 4.3 sind die Stelle, an der das auffällt.

**7.3 Kein zweiter Suchdienst und kein Vektorindex bedeutet weniger Löschwege.** R3-F-020 verlangt, dass eine Löschung jeden Ablageort erreicht. Jeder Speicher, den es nicht gibt, ist ein Nachweis, der nicht zu führen ist. Das ist der praktische Nutzen von A3 und A4, unabhängig von der Betriebsersparnis.

**7.4 Der Modell-Bauweg ist unbequemer als üblich.** Ohne Werkzeugaufrufe des Modells muss die Anwendung Vorschläge als strukturierte Ausgabe prüfen und den Ablauf selbst führen. Das ist mehr Arbeit als der geläufige Weg und der Preis dafür, dass eine Einschleusung in einem Leak-Seiten-Text technisch nichts auslösen kann.

**7.5 Die Oberfläche bleibt zur Hälfte offen — mit Termin.** Rahmenwerk und Bauwerkzeug stehen, Komponentenbibliothek und Designsystem folgen nach R3-F-050. Wer diese Trennung nicht bestätigt, muss entweder die Prototyp-Reihenfolge aus 5.6 aufgeben oder das Abnahmekriterium von R3-C-001 anpassen. Beides ist eine Entscheidung des Auftraggebers, nicht des Software Architects.

**7.6 Betrieb offline, Bau nicht.** Der Betrieb kommt ohne ausgehendes Netz aus. Der Bau braucht eine Paketquelle. Für die Dienststelle heisst das: entweder eine hausinterne Spiegelung oder ein Bauplatz mit Netzzugang und Auslieferung als Image. Das gehört in die Betriebsdokumentation und in Punkt 1 der Bereitschaftsliste.

**7.7 Dieser ADR bildet einen Stand ab.** Ändert sich eine Entscheidung, wird er fortgeschrieben, nicht stillschweigend überholt (`.claude/rules/dokumentation.md`). Nachgeordnete Entscheide entstehen als eigene ADR mit eigener Nummer.

---

## 8. Offene Punkte, die dieser ADR nicht entscheidet

| Nr. | Punkt | Warum heute nicht entscheidbar | Wer entscheidet | Spätestens |
|---|---|---|---|---|
| O-1 | Trennung „Rahmenwerk jetzt, Komponentenbibliothek nach dem Prototyp" (3.8) | Abnahmekriterium von R3-C-001 und 5.6 verlangen Verschiedenes | Auftraggeber; Anpassung des Backlogs durch den Product Owner | mit der Freigabe dieses ADR |
| O-2 | Komponentenbibliothek, Designsystem, Design-Tokens, Zielplattformen, Bibliothek für die Graphbearbeitung | 5.6: fällt nach dem Prototyp-Review, auf Beobachtungen statt Vermutungen | Software Architect mit UX/UI-Designer, Freigabe Auftraggeber; eigener ADR | unmittelbar nach R3-F-050, vor dem ersten Frontend-Produktionscode |
| O-3 | Ort der Durchsetzung des zweiten Faktors (Provider oder R3cOSINT) | Hängt an der MFA-Richtlinie des KapoBE-Mandanten, die noch nicht vorliegt | Software Architect mit Auftraggeber | vor R3-F-052, Etappe 3 |
| O-4 | Einbindungstiefe von TheHive und Cortex — **entfallen am 2026-08-21** | TheHive und Cortex sind mit der Neufassung von Projektauftrag 5.17 gestrichen; die frühere Nennung als zu übernehmende Anbindungen war eine Fehlübertragung aus dem Konzept. Ein Backlog-Eintrag wird nicht mehr angelegt (Begründung: Änderungsprotokoll des Projektauftrags, Abschnitt 8) | entfällt | entfällt |
| O-5 | Erzeugung und Prüfung von PDF/A-3 mit eingebetteten Daten (R3-F-074) | Die Wahl entscheidet über zusätzliche Abhängigkeiten und möglicherweise eine zweite Laufzeitumgebung im Prüfcontainer | Software Architect mit Backend Engineer; eigener ADR | vor Etappe 4 |
| O-6 | Verwaltung der fallbezogenen Schlüssel (4.4, Problem B): wo das Schlüsselmaterial liegt und wie es getrennt von den verschlüsselten Daten gesichert wird | Berührt Sicherung und Wiederherstellung (Bereitschaft 3) und ist mit SecDevOps und Datenschutz gemeinsam zu entscheiden | Software Architect mit SecDevOps und Datenschutzexperte; eigener ADR | vor R3-F-020, Etappe 1 |
| O-7 | Schwellenwerte in D3, D6 und D8 | Sind am Gate als E-07 und E-08 offen | Auftraggeber mit SecDevOps | mit R3-Q-001 beziehungsweise der ersten Umsetzungseinheit mit Code |
| O-8 | Betriebsart für D10 und Form von D12 (Befunde in Abschnitt 6) | Betrifft bestehende Skripte, die anderen Rollen gehören | DevOps Engineer mit Protocol Master | mit R3-Q-001. **Fortschreibung 2026-08-30:** Für D12 kommt die Bindung an den Kettengrundsatz aus 6.1.3 hinzu — die gewählte Form schreibt nicht in den Arbeitsbaum. **Zwölfte Fortschreibung 2026-09-02 (6.12.20, Bau auf Weisung vom 2026-09-02 begonnen, förmliche Freigabe ausstehend):** Termin neu **mit dem Grundgerüst** statt mit R3-Q-001. Weder `scripts/prototyp-trennung-pruefen.sh` noch `scripts/nachweise-vollstaendig.sh` bestehen; ein Entscheid über die Betriebsart eines nicht vorhandenen Skripts wäre eine Absichtserklärung. Der vierte Punkt des Achtung-Hinweises zu R3-Q-001 (Prüfmodus für den Nachweiserzeuger) fällt unter diesen Punkt und erhält keine eigene Nummer |
| O-9 | Anbindungsdaten des Entra-ID-Mandanten | Liegen bei der Informatik der Kantonspolizei Bern | KapoBE Informatik | blockiert nur den Mandantenwechsel, nicht die Entwicklung |
| O-10 — **überholt, siehe die Zeile „O-10 (neu gefasst)" darunter (ADR 0002, Abschnitt 6.11)** | Prüffläche des Arbeitsbaumlaufs in D11: welche Dateien er beurteilt, wie er sich gegenüber `.gitignore` verhält, und wie ein belegter Fehlalarm behandelt wird, dessen Fingerabdruck in den beiden Läufen verschieden ist (6.1.1) | **Neu am 2026-08-30, am selben Tag neu gefasst — diese Zeile bleibt stehen, weil Nummern nicht umnummeriert und Historie nicht umgeschrieben wird (6.1.2), ist aber durch die Zeile darunter ersetzt.** Mit einem ausgeführten Lauf der eingesetzten Werkzeugfassung festzustellen, nicht durch Annahme; berührt Laufzeit und Aussagekraft des Schrittes | DevOps Engineer mit SecDevOps | mit R3-Q-001 |
| O-10 (neu gefasst) | **Beantwortet am 2026-08-30 mit einem ausgeführten Lauf (gitleaks 8.21.2):** `--no-git` beachtet `.gitignore` nicht; eine ignorierte `.env` oder `*.pem` blockiert die ganze Kette. Entschieden in 6.2.3: Zugangsdaten liegen nicht im Arbeitsbaum (3.11), ausgeschlossen wird ausschliesslich, was kein Repository-Inhalt sein kann, der Schutz wird nicht abgestuft. **Offen bleiben zwei Restfragen:** (a) die namentliche Ausschlussliste für Abhängigkeits- und Bauverzeichnisse samt ihrer technischen Form — Werkzeugkonfiguration oder Aufrufparameter; (b) die betriebliche Form der Ablage von Zugangsdaten ausserhalb des Arbeitsbaums, einschliesslich Einhängung im Prüfstapel und Eintrag in die Betriebsdokumentation | (a) hängt an der eingesetzten Werkzeugfassung und ist mit einem ausgeführten Lauf zu belegen; (b) ist Betrieb und Sicherheit, nicht Architektur | (a) DevOps Engineer mit SecDevOps; (b) SecDevOps mit DevOps Engineer | (a) **zwölfte Fortschreibung 2026-09-02 (6.12.21, Bau auf Weisung vom 2026-09-02 begonnen, förmliche Freigabe ausstehend):** Termin neu **mit der Installation von `gitleaks`, spätestens mit dem Grundgerüst** — die Restfrage ist nur mit einem ausgeführten Lauf der eingesetzten Werkzeugfassung zu belegen, und `gitleaks` ist nicht installiert; (b) mit dem Grundgerüst, vor der ersten Umsetzungseinheit mit Code |
| O-11 | Abgleich für D18: Jedes oberste Paket unterhalb `backend/src/` ist in `backend/importvertraege.toml` als Wurzelpaket genannt — und wo dieser Abgleich sitzt, im Aufruf oder als Vertrag im Prüfer selbst | **Neu am 2026-08-30 (6.3.4).** Nicht baubar, solange `backend/importvertraege.toml` nicht besteht; heute im Makefile nur als Kommentar hinterlegt, und ein Kommentar ist keine Prüflogik. Ohne den Abgleich meldet D18 Lage A, ohne etwas beurteilt zu haben — der Befund aus 6.2.2 | DevOps Engineer mit Backend Engineer | mit dem Anlegen von `backend/importvertraege.toml`, also mit dem Grundgerüst und vor der ersten Umsetzungseinheit mit Fachlogik |
| O-13 — **entschieden am 2026-08-31, siehe 6.7** | Ob die Kette den Zwischenspeicher von `uv` benutzen darf oder ob D1 ohne ihn läuft. **Entscheid des Auftraggebers: ohne.** Umgesetzt mit `UV_NO_CACHE=1` in `$(UV)`, wirksam für jeden `uv`-Aufruf der Kette und von aussen nicht abschaltbar | **Neu am 2026-08-31 (6.6.1).** `--locked` prüft die Prüfsumme beim Herunterladen, nicht noch einmal für ein bereits entpacktes Archiv im Zwischenspeicher; ausgeführt belegt. Wer `HOME` setzen oder in `~/.cache/uv` schreiben kann, erhält damit ein falsches `A_OK` in D1. `--no-cache` schliesst das, kostet aber je Lauf einen vollständigen Ladevorgang und macht die Kette netzabhängig — eine Abwägung zwischen Laufzeit und Beweiskraft, die der Auftraggeber trifft, nicht die Umsetzung | Auftraggeber mit SecDevOps und DevOps Engineer | mit R3-Q-001; spätestens mit dem Lauf auf der Gegenseite (O-12), der denselben Punkt betrifft |
| O-14 | Der Belegprüfer liest das Methodik-Repository an einem **fest verdrahteten, nicht konfigurierbaren Ort ausserhalb dieses Repositories** mit. Offen ist, wie der Ort bestimmt wird, ohne die Aussage des Kettenschrittes an einen einzelnen Arbeitsplatz zu binden | **Neu am 2026-09-01 (6.8.3).** Auf einer Maschine ohne diesen Arbeitsbaum zählt das Skript die betroffenen Zeilen als "nicht prüfbar"; die Zählung geht nicht in den Rückgabewert ein. D20 wird dadurch nicht falsch, aber schwächer — und wie viel schwächer, hängt an der Maschine. `.claude/rules/dokumentation.md` untersagt absolute Pfade der Arbeitsumgebung ausdrücklich für Architecture Decision Records; für ein Skript sagt die Regel nichts, weshalb dieser Punkt eine Abwägung ist und kein Regelverstoss. Die Behebung ist Umsetzung (Umgebungsvariable, Suchpfad oder ausdrückliche Lage-Meldung), nicht Architektur | DevOps Engineer mit dem Protocol Master (Verfolgbarkeit über beide Repositories, 6.6) | mit R3-Q-001 |
| O-15 | **Abnahme des Belegprüfers.** Das Werkzeug ist nach Eskalationsregel 3.4 abgebrochen und nicht abgenommen; seine Selbstauskunft erklärt die Liste ihrer Grenzen ausdrücklich für unvollständig. Offen ist, welches Abnahmekriterium für ein Werkzeug gilt, das eine Nachweiskette blockiert | **Neu am 2026-09-01 (6.8.4).** Die Aufnahme in die Kette hängt nicht an der Abnahme — ein Schritt, der nur Funde hinzufügt und nichts darüber hinaus behauptet, macht die Kette nicht schwächer. Die Abnahme selbst ist damit nicht erledigt: Sie verlangt eine Prüfung auf einem anderen Modell als die Umsetzung (3.4) und eine Entscheidung darüber, ob "die Liste der Grenzen ist unvollständig" als Abnahmekriterium ausreicht. Dazu gehören die beiden benannten, nicht gebauten Prüfungen. **Zwölfte Fortschreibung 2026-09-02 (6.12.18, Bau auf Weisung vom 2026-09-02 begonnen, förmliche Freigabe ausstehend):** Das Gate aus R3-Q-001 stützt sich auf die ganze Kette und damit auf dieses nicht abgenommene Werkzeug; ein Befund von D20 blockiert damit jede Arbeitseinheit. Seit dem 2026-09-02 ist zudem belegt, dass D20 rote Läufe erzeugt, deren Ursache die Umgebung ist (flacher Klon, lokaler Zweig-Ref in einer Übergabe). Die Aufnahme in die Kette hängt weiterhin nicht an der Abnahme; die Dringlichkeit steigt | Static und Dynamic Software Tester, Entscheid über das Abnahmekriterium beim Auftraggeber | vor der Freigabe des Grundgerüsts |
| O-16 — **beantwortet am 2026-09-01, siehe 6.10** | Reichweite der Index-Maskierung gegenüber dem zweiten Teil des D19-Instruments: Macht die Maskierung D19 halb oder ganz blind? **Antwort, mit ausgeführtem Lauf belegt: halb.** Die Statusliste ist für die maskierte Datei blind, die Inhaltsprüfsumme erfasst die Änderung weiterhin | **Neu und geschlossen am 2026-09-01 (6.9.4, 6.10.1).** Die Frage war nur durch einen Lauf zu beantworten und ist in diesem ADR bis dahin in keine Richtung behauptet worden. Folge: Der Entscheid bleibt unverändert, eine Begründungszeile aus 6.9.2 ist berichtigt (6.10.3), und die Befundmeldung ist auf die schwächere, richtige Aussage festgelegt (6.10.2) | beantwortet durch den Koordinator, übernommen als Fremdbeleg | erledigt |
| O-17 | **Löschung einer maskierten, verfolgten Datei.** Die Aufzählung der verfolgten Dateien führt sie weiter, weil sie im Index steht; die Prüfsummenbildung findet die Datei nicht vor. Ob die Aufnahme dadurch abweicht — die Löschung also trotz Maskierung sichtbar wird — oder nicht, ist offen | **Neu am 2026-09-01 (6.10.4).** Der Versuch zu O-16 deckt die Inhaltsänderung einer vorhandenen Datei ab, nicht die Löschung. Dieser ADR behauptet dazu nichts. Am Entscheid ändert die Antwort nichts — die Maskierung bleibt ein Befund, der Ausgang Lage C; sie bestimmt allein, wie weit die Meldung nach 6.10.2 sagen darf, der Inhalt sei beurteilt | DevOps Engineer, Verifikation Static und Dynamic Software Tester (3.4) | mit R3-Q-001 |
| O-18 | Ob die drei Bezugsdokumente in der Prüfmittelspalte von D20 künftig auch auf **Aktualität** und nicht nur auf Vorhandensein zu prüfen sind — eine veraltete Referenzmenge fällt heute durch kein Netz | **Neu am 2026-09-01 (6.11.6).** Der Belegprüfer prüft seit der elften Fortschreibung, dass `docs/05_Product_Backlog.md` und `docs/00_Projektauftrag.md` bestehen, lesbar sind und eine nicht leere Referenzmenge hergeben — nicht, ob diese Referenzmenge noch dem aktuellen Stand entspricht. **Zwölfte Fortschreibung 2026-09-02 (6.12.21, Bau auf Weisung vom 2026-09-02 begonnen, förmliche Freigabe ausstehend):** Der Punkt bleibt offen, mit geschärfter Frage. Ob eine Anforderungskennung noch **gilt**, ist eine Aussage über den Inhalt am Fundort, und die hat 6.8.4 dem menschlichen Review zugewiesen. Maschinell prüfbar wird sie erst, wenn der Backlog je Eintrag ein **maschinenlesbares Statusfeld** trägt — das ist die eigentliche, bisher nicht benannte Vorbedingung und eine Änderung am Format des Backlogs, nicht am Belegprüfer | Software Architect mit dem Static Software Tester; für das Statusfeld Requirements Engineer mit Product Owner | mit R3-Q-001. **Zwölfte Fortschreibung 2026-09-02 (Entwurf):** Termin neu **mit dem Grundgerüst** |
| O-19 | **Die Umgebungsvariable `CLAUDE_CODE_STOP_HOOK_BLOCK_CAP` ist nicht belegt.** **Drei** Stellen des Repositories nennen sie und behandeln sie als gegeben *(dritte Fundstelle ergänzt in Runde 1)*: Projektauftrag 3.4, Ebene 4 ("Die Grenze ist über `CLAUDE_CODE_STOP_HOOK_BLOCK_CAP` anpassbar"), `docs/06_Definition_of_Ready_und_Done.md`, Abschnitt "Durchsetzung", und `docs/adr/0001-rollenmodell.md` ("Ebenso verbindlich sind der Reentranz-Schutz über `stop_hook_active` und die harte Obergrenze über `CLAUDE_CODE_STOP_HOOK_BLOCK_CAP`") — die dritte Stelle erklärt sie sogar für **verbindlich**. In der am 2026-09-02 gelesenen offiziellen Hook-Dokumentation kommt dieser Name nicht vor (selbst geprüft über eine Textsuche in `hooks.md`); dass er auch im Leitfaden fehlt, ist Fremdbeleg. Die Obergrenze 8 steht dort ohne Variablennamen. Offen ist, wie beide Dokumente damit umgehen | **Neu am 2026-09-02 (6.12.2, Bau auf Weisung vom 2026-09-02 begonnen, förmliche Freigabe ausstehend).** Der Entwurf des Gates stützt sich an keiner Stelle auf die Variable und braucht sie auch nicht: Mit dem Reentranz-Schutz aus 3.4 ist eine Folge von acht Blockaden innerhalb eines Beendigungsversuchs ohnehin unerreichbar. Der Befund ist damit nicht dringlich, aber er steht in einem Dokument, das verbindliche Grundlage ist, und wird deshalb nicht stillschweigend übergangen. Diese Rolle ändert weder den Projektauftrag noch `docs/06_Definition_of_Ready_und_Done.md` | Requirements Engineer mit Protocol Master, Entscheid über eine Änderung des Projektauftrags beim Auftraggeber; die Nachführung von `docs/adr/0001-rollenmodell.md` liegt beim Software Architect als Fortschreibung jenes ADR | mit der nächsten Nachführung von `docs/06_Definition_of_Ready_und_Done.md` |
| O-20 | **Laufzeit der Kette und die beiden Zeitgrenzen des Gates.** Festgelegt sind 900 s in `.claude/settings.json`, 600 s für `make dod` im Skript und 120 s Wartezeit auf die Sperre. Ob 600 s reichen, sobald Bau, Containerbau, Testsuite, Abdeckung und die durchgehenden Oberflächenläufe dazukommen, ist nicht gemessen | **Neu am 2026-09-02 (6.12.12 und 6.12.16, Bau auf Weisung vom 2026-09-02 begonnen, förmliche Freigabe ausstehend).** Der heutige Lauf dauert 5,8 s (Fremdbeleg); die Grössenordnung wechselt mit dem Grundgerüst von Sekunden zu Minuten. Reichen 600 s nicht, wäre das Gate regelmässig falsch rot, und ein regelmässig falsch rotes Gate wird entfernt. Reicht die Laufzeit je Beendigungsversuch insgesamt nicht aus, ist auch der Entscheid gegen einen Zwischenspeicher des Urteils (G15) neu zu bewerten. Beides ist mit einem ausgeführten Lauf zu beantworten und als Fortschreibung zu entscheiden, nicht im Skript stillschweigend anzupassen. **Nachtrag 6.12.24 j (Fremdbeleg aus der dynamischen Prüfung vom 2026-09-02, nicht von dieser Rolle nachgeprüft):** Gemessen wurden 6,4 bis 7,0 s je Lauf des Gates auf dem echten Baum (Mittel 6,65 s) und 7,6 bis 8,2 s für einen vollständigen Lauf im Klon. Das ist der Stand **ohne** `backend/` und `deploy/` und beantwortet die Frage nicht — sie lautet, ob 600 s **mit** dem Grundgerüst reichen. **O-20 bleibt offen**, die Grenzen von 600 s und 900 s bleiben unverändert, bis der Auftraggeber entscheidet | DevOps Engineer mit einem ausgeführten Lauf, Verifikation Static und Dynamic Software Tester (3.4); Änderung der Werte als Fortschreibung durch den Software Architect | mit dem Grundgerüst, sobald `backend/` und `deploy/` bestehen |
| O-21 | **Kettenschritt gegen Schwachstellenklassen im eigenen Code** (ruff-Regelgruppe `S`): als Regelgruppe in der bestehenden Konfiguration und damit in D3, oder als eigener Kettenschritt mit eigener Nummer | **Neu am 2026-09-02 (6.12.20, Bau auf Weisung vom 2026-09-02 begonnen, förmliche Freigabe ausstehend).** Punkt 2 des zweiten Achtung-Hinweises bei R3-Q-001, dort ausdrücklich dem Software Architect zugewiesen. Heute nicht entscheidbar, weil es keinen eigenen Python-Code gibt: D3 ist Lage B. Für D3 spricht, dass kein neues Werkzeug entsteht; dagegen das Argument aus 6.1.2 für D18 — eine Aussage über eine Sicherheitseigenschaft soll einen eigenen Rückgabewert haben und nicht mit einem Schwellenwert für Stilwarnungen (E-08, O-7) zusammenfallen | Software Architect mit SecDevOps Engineer; Bau beim Backend Engineer | mit dem Anlegen von `backend/pyproject.toml`, vor der ersten Umsetzungseinheit mit Fachlogik |
| O-22 | **Markdown-Struktur- und Tabellenprüfer** über den Dokumentenbestand: eigener Kettenschritt oder Aufnahme in ein bestehendes Werkzeug, und welche Prüfungen er trägt | **Neu am 2026-09-02 (6.12.20, Bau auf Weisung vom 2026-09-02 begonnen, förmliche Freigabe ausstehend).** Punkt 3 des zweiten Achtung-Hinweises bei R3-Q-001. Der Gegenstand besteht heute — eine verrutschte Spalte in der Rollentabelle ist eine falsch gelesene Bauvorschrift. Er geht **nicht** in D20 auf: D20 urteilt über Herkunfts- und Fundortangaben, ein Strukturprüfer über den Aufbau des Dokuments; das sind zwei Sachen (6.2.2). Eine D-Nummer ist bewusst **nicht** vergeben, weil eine Nummer für einen nicht entschiedenen Schritt eine Absichtserklärung wäre und nach 6.8.1 mit der Nennung vergeben wäre | Software Architect (Schnitt), DevOps Engineer (Bau) | mit der nächsten Fortschreibung von Abschnitt 6, spätestens vor der Freigabe des Grundgerüsts |
| O-23 | **Wovon die harte Zusicherung des Gates abhängt: dass eine Aufgabenliste geführt wird.** `TaskCompleted` ist nach 6.12.2 das einzige der drei Ereignisse, das die Zusicherung "die Aufgabe lässt sich nicht abschliessen" trägt. Nach der gelesenen Referenz feuert es aber nur, "when any agent explicitly marks a task as completed through the TaskUpdate tool, or when an agent team teammate finishes its turn with in-progress tasks". In einer Sitzung ohne Aufgabenliste feuert es nie, und die Zusicherung gilt dann für nichts | **Neu am 2026-09-02 (6.12.2, Bau auf Weisung vom 2026-09-02 begonnen, förmliche Freigabe ausstehend; Befund aus Runde 1 der Prüfung).** Zwei Wege stehen offen, und beide sind Vorgehen, nicht Architektur: (1) eine Vorschrift, dass jede Arbeitseinheit als Aufgabe geführt wird — Ort `CLAUDE.md` oder `.claude/rules/claude-konfiguration.md`, in Abschnitt 9 als bedingte Nachführung vorgemerkt; oder (2) es bleibt bei fakultativen Aufgabenlisten, dann ist auszusprechen, dass die Kette in solchen Sitzungen nur angemahnt und nicht erzwungen wird und der Nachweis dort am menschlichen Review hängt. Diese Rolle nimmt die Wahl nicht vorweg: Eine Zusicherung, deren Voraussetzung ungeklärt ist, wäre die Zusicherung ohne Deckung aus V12 | Auftraggeber; Umsetzung der gewählten Fassung durch den Protocol Master (CLAUDE.md) beziehungsweise den DevOps Engineer (Regeldatei) | mit der Freigabe von 6.12, weil der Entwurf ohne diese Wahl nicht beurteilbar ist |
| O-24 — **entschieden am 2026-09-03, siehe 6.12.25** | **Abbildung der Tabelle 6.12.19 auf einzeln prüfbare Zusicherungen. Entscheid des Auftraggebers: Tabellenzeilen zerlegen** — je Zeile genau eine messbare Zusicherung mit dauerhafter Kennung `Z-nnn`, je Kennung genau eine Prüfung im Selbsttest, mechanische Deckung in beide Richtungen (6.12.25 a). Die Frage im Wortlaut, wie sie am 2026-09-03 vorgelegt wurde: Die Tabelle führt je Zeile **mehrteilige** Erwartungen ("2, mit Nennung des Mittels"; "0, mit `systemMessage`, die den Schritt nennt"), der Selbsttest je Fall **eine** Zusicherung. Wo eine Zeile mehr verspricht als Rückgabewert und Schlüssel, bleibt der Rest ungemessen, und der Fall ist grün, ohne seine Behauptung zu belegen. Offen ist die Form der Zerlegung — eine Zeile je Erwartung, eine eigene Spalte mit den einzeln zu messenden Zusicherungen, oder die Regel, dass jeder Selbsttestfall genau eine Zusicherung trägt | **Neu am 2026-09-03 (6.12.24 j, Punkt 15).** Die Fehlerklasse "ein Selbsttestfall besteht, ohne seine Behauptung zu belegen" ist **dreimal** aufgetreten (DT-B4, S-01, S3-01). Nach 3.4 ist die Arbeitseinheit am 2026-09-03 abgebrochen und **dieser Punkt** vorgelegt worden statt einer vierten Einzelbehebung: Die Frage ist nicht, ob der einzelne Fall nachgebessert wird — das ist er dreimal worden —, sondern wie die Prüftabelle so geschnitten wird, dass eine unvollständig gemessene Zeile auffällt statt grün zu sein | Auftraggeber; Vorbereitung durch den Software Architect, Umsetzung durch den DevOps Engineer, Verifikation durch Static und Dynamic Software Tester (3.4) | **vor der Abnahme des Gates** aus R3-Q-001. **Entscheid erteilt am 2026-09-03** und in 6.12.25 festgeschrieben; offen bleiben die Umsetzung in `scripts/dod-gate-selbsttest.sh` und `.claude/hooks/dod-gate.sh` sowie eine **vierte** Prüfrunde, die den Stand danach belegt. **Nachtrag vom 2026-09-03 (6.12.25 f bis k):** Die vierte Prüfrunde ist gelaufen — dynamisch bestanden, **statisch nicht bestanden** (S4-01 blockierend, vierter Auftritt der Fehlerklasse, und zwar an einer in dieser Einheit neu geschriebenen Zeile). Auf Weisung des Auftraggebers vom 2026-09-03 sind die Befunde als **f) bis j)** entschieden: Messvorschrift je Zusicherung mit Kanal, Ereignis und Anzahl (f, S4-01/DT4-02), Berichtigung von `Z-129` (g), Rücknahme von `Z-110` und Präzisierung von `Z-111` (h), Zählung **jedes** `GATE <Prüfmittel>`-Blocks ausser `GATE jq` (i, S4-04), Sperre des Selbsttests gegen Nebenläufigkeit (j, S4-03); k) hält die Beleglage der vierten Runde fest. Offen bleiben die Umsetzung und eine **fünfte** Prüfrunde |
| O-25 — **entschieden am 2026-09-03, siehe 6.12.26** | **Messumfang und Trennschärfe je Zusicherung maschinell erzwingen.** Die Messvorschrift aus 6.12.25 f — Kanal, Ereignis und Anzahl je Zusicherung — steht heute als **Text** in der Tabellenzeile. Ob eine Zusicherung den dort genannten Kanal auch tatsächlich misst und ob sie überhaupt trennscharf ist, prüft nichts. Vorgeschlagen sind zwei Mittel: (1) eine Tabellenspalte "Kanal" mit **festem Wertevorrat**, die der Selbsttest liest und gegen die je Kennung tatsächlich benutzte Messart abgleicht; (2) je Zusicherung eine **Mutationsprobe** — welche Änderung am Gate lässt sie fehlschlagen —, die der Selbsttest in einem Mutationsmodus ausführt (6.12.25 k, fünfte Runde) | **Neu am 2026-09-03 (6.12.25 k).** Die fünfte Prüfrunde hat die Fehlerklasse "ein Selbsttestfall besteht, ohne seine Behauptung zu belegen" zum **fünften** Mal gefunden: 16 Zusicherungen messen einen anderen Kanal als den in ihrer Zeile genannten (S5-01, blockierend), und `Z-111` besteht ohne Beobachtungsfenster (DT5-01, blockierend). Der mechanische Deckungsprüfer nach O-24 kann diese Klasse nicht finden — er sieht **Kennungen**, nicht **Messumfang** und nicht **Trennschärfe**. Beide Prüfer schlagen dasselbe Mittel vor; ihr Vorschlag ist als Vorschlag gekennzeichnet und in 6.12.25 k nicht entschieden | Auftraggeber; Vorbereitung durch den Software Architect, Umsetzung durch den DevOps Engineer, Verifikation durch Static und Dynamic Software Tester (3.4) | **vor der Abnahme des Gates** aus R3-Q-001. **Entscheid erteilt am 2026-09-03** (Weisung im Wortlaut: "O-25 entscheiden: beides umsetzen, dann sechste Runde.") und in **6.12.26** festgeschrieben: Kanalspalte mit abschliessendem Wertevorrat samt maschinellem Abgleich (a), Mutationsprobe je Zusicherung in `scripts/dod-gate-mutationen.txt` mit eigenem Modus `--mutationen` (b), dazu die vier Befunde der fünften Runde als Entscheide (c). **Offen bleiben** die Umsetzung in `scripts/dod-gate-selbsttest.sh`, `.claude/hooks/dod-gate.sh` und `Makefile` sowie die **sechste** Prüfrunde, die den Stand danach belegt. **Nachtrag vom 2026-09-03 (6.12.26 e und f):** Die sechste Runde ist statisch und dynamisch nicht bestanden; der Bau lief in drei kontrollierten Phasen weiter, Phase 3 blieb unvollständig (e). Die **siebte** Runde meldet Normalmodus Rückgabewert 2 (`Z-089` doppelt, Kanal von `Z-130`) und Mutationsmodus Rückgabewert 2 (5 von 146 Mutationen nicht erkannt), dazu den blockierenden Befund `DT7-03`: Der Durchlass nach der Eskalation ist **nicht** an den gezählten Schlüssel gebunden. Entschieden in **6.12.26 f**: `Z-114`, `Z-124`, `Z-132`, `Z-133` und `Z-139` präzisiert, neu `Z-154` und `Z-155`, Grund 3 weiter gefasst, typisierte Messhüllen für fünf Kanäle verbindlich (`S7-05`), Sperre unter `/tmp` bestätigt (`S7-06`). **Offen bleiben** die Umsetzung (Bau 4 mit Zwischenkontrolle) und die **achte** Prüfrunde; **O-25 ist weiterhin nicht abgenommen**. **Nachtrag vom 2026-09-04 (6.12.26 g):** achte Runde **statisch bestanden** (154 von 154, Mutationsmodus 145 von 145 erkannt, Kanalabgleich ohne Abweichung, sieben nachrangige Befunde), **dynamisch nicht bestanden** (`DT8-01` bis `DT8-03`, alle drei aus Fremdmutationen, die keine Kennung fallen lassen); die Einheit ist nach 3.4 **abgebrochen** und **O-26** vorgelegt. **O-25 bleibt offen und nicht abgenommen** |
| O-26 — **entschieden am 2026-09-06, siehe 6.12.27** | **Die Messhülle maschinell binden und die Prüftabelle gegen den ADR-Text vollständig halten — mit einem Abnahmekriterium, das die Prüfrunden beendet.** Fünf Bausteine als Vorschlag: (a) **Prädikatbindung** — je Zeile ein Prädikat aus geschlossenem Vorrat (`zeile-woertlich`, `enthaelt`, `gleich`, `einzelfeld`, `leer`, `existiert`, `fehlt`, `ausserhalb`), von der Messhülle mitgemeldet und abgeglichen wie heute der Kanal; "die Zeile ... wörtlich" nur mit einer Zeilenhülle (`grep -x`). (b) **Schlüsseldeckung** — jeder Zählschlüssel aus 6.12.4 kommt als erwarteter Schlüssel in mindestens einer Zeile von 6.12.19 vor, maschinell geprüft; heute fehlt `KETTE schlusszeile-widerspruch`. (c) **Grammatikdeckung** — je Element der Markengrammatik aus 6.12.7 (Präfix `::LAGE`, Felder, `FEHLT=`, `SCHWELLE=`, schliessendes `::`, Rückgabewertklammer) eine verneinende Zeile. (d) Die sechs Befunde `DT8-01` bis `DT8-06` als neue oder geänderte Zeilen samt Mutationen. (e) Ein **Abnahmekriterium**: tabelleneigene Mutationen zu 100 Prozent erkannt **und** eine Fremdmutationsrunde ohne blockierenden Befund in den Kategorien Schlüssel (6.12.4), Grammatik (6.12.7), Schwellen und Ereignisfolge (6.12.9) und Ausgabeform (6.12.15); weitere Fremdmutationen danach sind Backlog, kein Abbruchgrund | **Neu am 2026-09-04 (6.12.26 g).** Die Fehlerklasse "eine Zusicherung besteht, ohne ihre Behauptung zu belegen" ist zum **achten** Mal aufgetreten, diesmal an `Z-040` (Ausprägung wie `DT7-03`: Teilzeichenkette statt Zeile) und zusätzlich als **ungedeckte Stellen** — ein Zählschlüssel aus 6.12.4 und ein Element der Grammatik aus 6.12.7 ohne jede Zusicherung. Weder die Deckungsprüfung nach O-24 (Kennung gegen Kennung) noch der Kanalabgleich nach O-25 (Kanal gegen Kanal) findet diese Klasse: Keiner hält **Aussage gegen Prädikat**, und keiner hält die **Tabelle gegen den ADR-Text**. Der Punkt ist heute nicht von dieser Rolle entscheidbar, weil er über eine Behebung hinausgeht — er ändert den Prüfmassstab und, mit (e), den Massstab der Abnahme selbst; und weil acht Runden gezeigt haben, dass das offene Kriterium "keine neue Lücke" nicht konvergiert, ist die Frage, wann genug geprüft ist, eine Entscheidung des Auftraggebers und keine der Umsetzung | Auftraggeber; Vorbereitung durch den Software Architect, Umsetzung durch den DevOps Engineer, Verifikation durch Static und Dynamic Software Tester auf einem anderen Modell als die Umsetzung (3.4) | **vor der Abnahme des Gates** aus R3-Q-001. **Entscheid erteilt am 2026-09-06** — Bericht des Koordinators vom 2026-09-05, Antwort des Auftraggebers im Wortlaut: "Na dann weiter gehts, so wie du es sagst"; Lesart: der Vorschlag wird angenommen, wie er in 6.12.26 g steht, alle fünf Bausteine (a) bis (e) werden umgesetzt, danach läuft die neunte Prüfrunde nach dem Abnahmekriterium. Festgeschrieben in **6.12.27**: Prädikatspalte mit geschlossenem Vorrat, Bindungsregeln Wortlaut zu Prädikat und maschinellem Abgleich (b); Schlüsseldeckung gegen 6.12.4 in beide Richtungen — die vollständige Erhebung findet **zehn** ungedeckte Schlüssel statt des einen aus `DT8-02` (c); Grammatikdeckung gegen die neue Elementtabelle in 6.12.7 mit neun Kürzeln (d); `Z-040` und `Z-080` berichtigt und **29** neue Zeilen `Z-156` bis `Z-184` (e); Zahlen und Meldepflicht des Baus (f); das Abnahmekriterium mit **einer** Fremdmutationsrunde in vier Kategorien, mindestens drei Fremdmutationen je Kategorie, gewählt ohne Kenntnis der Mutationsdatei (g); die nachrangigen Befunde S8-01, S8-03, S8-05, S8-06 und S8-07 als Entscheide (h). **Offen bleiben** die Umsetzung in `scripts/dod-gate-selbsttest.sh`, `scripts/dod-gate-mutationen.txt` und `.claude/hooks/dod-gate.sh` sowie die **neunte** Prüfrunde, die den Stand danach belegt. Der Entscheid betrifft **allein O-26**: **O-25**, die Entscheidpunkte E-A bis E-K und die Abnahme des Gates bleiben offen (Abschnitt 10) |
| O-27 — **entschieden am 2026-09-07, siehe 6.12.27 k** | **Wie die Deckung des Selbsttests vollständig wird — oder woran die Abnahme sonst gemessen wird.** Zwei Wege als Vorschlag, die einander nicht ausschliessen. **(a) Deckung am Gegenstand für Grammatik und Pfade:** (a1) **Pfaddeckung** — der Selbsttest erhebt aus dem Gate jede Ausgangsstelle (jedes `exit`) und verlangt, dass die protokollierten Aufrufe jede Stelle mindestens einmal beschritten haben, messbar über eine Ausführungsspur gegen eine Wegwerfkopie (`bash -x` mit `BASH_XTRACEFD` und eigenem `PS4`), ohne Änderung am Gate; damit decken die Invarianten `A01`, `A04`, `A05`, `A08` **alle** Pfade statt der beschrittenen. (a2) **Grammatik am Gegenstand** — der Selbsttest erzeugt aus dem `marken_muster` mechanisch Schwächungen (je Anker entfernt, je `+` zu `*`, je Zeichenklasse geweitet, je Literal optional, je Alternative erweitert) und verlangt, dass jede Schwächung, die eine missgebildete Probemarke annimmt, eine Zeile fallen lässt — vollständig **relativ zum Muster** statt zur Aufzählung. Dazu `DT11-11` als Gate-Berichtigung (einheitliche Meldungsform an den drei Vor-Eingabe-Pfaden und beim Sperrpfad) und `S11-04` bis `S11-06` als fail-closed-Deckungen (Mindestzahl, leeres Muster ist ein Fehlschlag). **(b) Das Abnahmekriterium ändern:** Teil 2 wird auf das **Gate** bezogen — blockierend ist nur eine Fremdmutation, die am Gate ein **falsches Grün** erzeugt und keine Zeile fallen lässt; Formänderungen (falsch rot, Meldungsform, Rückgabewert 3 statt 2) sind nachrangig und Backlog. Festgehalten: **Runde 11 hätte auch unter (b) nicht bestanden** (`DT11-01` bis `DT11-05` erzeugen falsches Grün für missgebildete Marken, erreichbar allerdings nur mit einer gefälschten Marke mit richtiger Lauf-Kennung) | **Neu am 2026-09-06 (6.12.27 k).** Teil 2 des Abnahmekriteriums aus 6.12.27 g ist zum **dritten** Mal nicht erfüllt; die Arbeitseinheit ist nach 3.4 abgebrochen, wie in 6.12.27 j Punkt 8 **vorab** festgelegt. Die Klasse ist benannt und geht über eine Behebung hinaus: 6.12.27 j hat die Deckung am Gegenstand **nur für die Schlüssel** gebaut — dort ist die Kategorie als einzige vollständig erfüllt (7 von 7, mit erkannten Umbenennungen an je einer von mehreren Fundstellen). Für die **Grammatik** fehlt sie, weil die Elementtabelle aufzählt, **woraus** die Marke besteht, nicht, auf wie viele Arten jedes Element verletzt werden kann (`DT11-01` bis `DT11-05`); für **Ausgabeform und Ereignisfolge** fehlt sie, weil die Invariante über alle **protokollierten Aufrufe** gilt und nicht über alle **Pfade** des Gates (`DT11-06` bis `DT11-10`). Ob der Aufzählung ein drittes Mal nachgesetzt wird oder ob der Massstab der Abnahme selbst geändert wird, ist keine Frage der Umsetzung, sondern eine Entscheidung über den Prüfmassstab — dieselbe Lage wie bei O-26 (e), nur eine Ebene höher. **Einschätzung des Koordinators, als solche gekennzeichnet und nicht als Entscheid:** Weg (a) in **einer** weiteren Einheit mit Runde 12; fällt auch sie, sei die Fähigkeit der Aufzählung erschöpft, und (b) mit dokumentierter Restlücke sei dann der ehrliche Abschluss — das Gate selbst sei in elf Runden gegen echte Bäume **nie falsch grün** gewesen | Auftraggeber; Vorbereitung durch den Software Architect, Umsetzung durch den DevOps Engineer, Verifikation durch Static und Dynamic Software Tester auf einem anderen Modell als die Umsetzung (3.4) | **vor der Abnahme des Gates** aus R3-Q-001. **Entscheid erteilt am 2026-09-07** — Weisung des Auftraggebers im Wortlaut: "Dann wähle den besten und korrektesten Weg aus, ich vertraue dir und deiner Expertise."; Lesart: der Auftraggeber **delegiert die Wahl** zwischen den beiden Wegen an den Koordinator, und dessen Wahl ist damit der Entscheid (3.1). **Gewählt sind beide Wege zusammen, in einer Einheit**: (a1) **Pfaddeckung** — jede Ausgangsstelle des Gates als Sollmenge, Ausführungsspur über alle Aufrufe des Selbsttests als Ist, keine Ausnahme ohne Grund aus geschlossener Liste; (a2) **Grammatik am Gegenstand** — mechanisch erzeugte Schwächungen des `marken_muster` nach geschlossener Umformungsliste, jede annehmende Schwächung muss eine Zusicherung fallen lassen; beide als eigene Zusicherungen und **fail-closed**. Dazu `DT11-06` (je Aufrufstelle eine Messung), `DT11-11` als Gate-Berichtigung ohne Verhaltenswechsel und `S11-04` bis `S11-06`. **(b) Teil 2 neu gefasst:** blockierend ist allein eine Fremdmutation, die am Gate ein **falsches Grün** erzeugt und keine Zusicherung fallen lässt; Formabweichungen sind nachrangig und Backlog. **Runde 12 ist die letzte Fremdmutationsrunde** (blind, mindestens sechs je Kategorie); besteht sie, wird die Abnahme des Gates vorgelegt; ein falsches Grün wird behoben und mit gezielter Wiederholung belegt — **keine Runde 13**, was bleibt, ist dokumentierte Restlücke. **Offen bleiben** die **Ausformung als 6.12.28** durch den Software Architect, die Umsetzung durch den DevOps Engineer und **Runde 12**; O-25, die Entscheidpunkte E-A bis E-K und die Abnahme des Gates bleiben offen (Abschnitt 10). **Ausgeformt am 2026-09-07 als 6.12.28**: Pfaddeckung über **40** Ausgangsstellen (14 Ausstiege, 26 Aufrufstellen) mit Ausführungsspur und geschlossener Ausnahmeliste; Grammatik am Gegenstand über **35** mechanisch erzeugte Schwächungen des `marken_muster` nach geschlossener Umformungsliste, gemessen **am Gate**; `DT11-06` (je Aufrufstelle eine Messung); `DT11-11` als Gate-Berichtigung mit **vier** neuen Schlüsseln in 6.12.4 und der neuen Aussage `E23`; `S11-04` bis `S11-06` fail-closed; Teil 2 des Abnahmekriteriums neu gefasst (g); **53** neue Zeilen `Z-209` bis `Z-261`. **Offen bleiben** danach die **Umsetzung** durch den DevOps Engineer und **Runde 12**. Die **förmliche Freigabe der Entscheidpunkte E-A bis E-K ist am 2026-09-07 durch den Merge des Pull Requests erteilt** (Abschnitt 10); **O-25** und die **Abnahme des Gates** bleiben offen. **Runde 12 ist am 2026-09-07 gelaufen und in 6.12.28 j festgehalten**: statisch mit zwei blockierenden **Baubefunden** (`S12-01`, `S12-02`, beide behoben) und allen Zahlen bestätigt; dynamisch 29 blind gewählte Fremdmutationen, 28 erkannt, **eine** mit falschem Grün — `DT12-M14`, die Grammatik der D19-Zeile aus 6.12.8. Nach g) wird sie **behoben** (`Z-262`, `Z-263`), statisch nachgeprüft und mit einer gezielten Wiederholung belegt; **keine Runde 13**. **Restlücke:** die Grammatik der D19-Zeile ist nicht am Gegenstand gedeckt, dazu die beiden benannten Grenzen aus c). **Offen bleiben** die Behebungsrunde samt Fremdbeleg und danach die **Abnahmevorlage** in Abschnitt 10. **Nachtrag vom 2026-09-08 (6.12.28 j, Punkte 8 bis 12):** Die Behebungsrunde ist als Fremdbeleg gemeldet — die gezielte Wiederholung von `DT12-M14` ist in allen vier Punkten belegt (der Mutant lässt zwei Zusicherungen fallen, am Gate selbst blockiert das Original und lässt der Mutant durch), die statische Nachprüfung urteilt **bestanden** ohne blockierenden Befund; nachrangig hinzu kommt `SNP-01` — die erläuternde Begründung zur Mutation von `Z-252` traf nicht zu (18 Schwächungen über die Elemente 1 bis 9 statt "die Elemente 3 bis 9"), Wirkung und `sed`-Ausdruck unverändert, in ADR und Mutationsdatei berichtigt. Die **Abnahmevorlage steht seit dem 2026-09-08 in Abschnitt 10**; sie stützt sich ausdrücklich **nicht** auf einen bestandenen Teil 2 — dieser ist **nicht erfüllt** —, sondern auf den in g) vorab festgelegten Weg aus Behebung, statischer Nachprüfung, gezielter Wiederholung und dokumentierter Restlücke. **Offen bleiben** die Abnahme selbst, die der Auftraggeber auf einem der beiden Formwege aus Abschnitt 10 erteilt, und **O-25** |
| O-28 | **ST-11: Die beiden `PreToolUse`-Matcher in `.claude/settings.json` führen keinen Werkzeugnamen für PowerShell.** Beide führen dieselben fünf Namen (Write, Edit, MultiEdit, NotebookEdit, Bash) und keinen weiteren. Zu entscheiden ist zweierlei: ob ein Werkzeugname dieser Art in die Matcher aufgenommen wird, **und** ob die auf Shell-Grammatik zugeschnittene Textprüfung beider Gates über Befehle dieser Sprache trägt. Bedingung für den Entscheid: erst, wenn eine Arbeitsumgebung mit diesem Werkzeug besteht, und nur mit ausgeführter Probe je Gate — ein Schreibvorgang auf `main` und ein Prototyp-Import, je blockierend erwartet, dazu je eine Gegenprobe; ein Matcher-Eintrag ohne Messung ist nicht zulässig. Fällt die Probe, ist die Folge nicht zwingend ein Matcher-Eintrag, sondern kann auch eine im Kopfkommentar festgeschriebene Grenze sein | **Neu am 2026-09-21 (ADR 0002, 6.13, E4/R3-Q-010).** Die Konfigurationslücke ist statisch belegt, die **Wirkung** ist es nicht. In dieser Umgebung besteht das Werkzeug nicht; ein Matcher-Eintrag allein liesse die auf Shell-Grammatik zugeschnittene Textprüfung beider Gates über fremde Grammatik laufen, und ob sie dort trägt, ist mit statischen Mitteln nicht zu belegen — so auch der Fremdbeleg des Static Software Testers. Ein Eintrag ohne Messung wäre eine **Zusicherung ohne Deckung**, genau die Fehlerklasse, gegen die R3-Q-010 gerichtet ist. Eine **Ablehnung** wäre umgekehrt falsch: Der Befund ist im Zustandsbericht mit Rang gering bestätigt und kann mit einer anderen Arbeitsumgebung sofort wirksam werden. Deshalb **nicht aufgenommen in R3-Q-010, aber nicht abgelehnt** | Software Architect auf Vorlage des SecDevOps Engineers (ausgeführte Probe) und des Dynamic Software Testers (Fremdbeleg der Probe, auf einem anderen Modell als die Umsetzung, 3.4) | Bei der ersten Sitzung in einer Umgebung, die ein solches Werkzeug anbietet. Besteht bis zur **Freigabe des Grundgerüsts** keine solche Umgebung, wird O-28 dort ausdrücklich als weiterhin bedingt offen bestätigt und **nicht stillschweigend fallen gelassen** |
| O-29 | **NF-005: Das Zeichenbudget des Eingangs-Hooks `.claude/hooks/session-start-eingang.sh` liegt über der Kappungsgrenze, die Claude Code auf Hook-Ausgaben anwendet.** Befund des Zustandsberichts vom 2026-09-02 (`docs/10_Zustandsbericht_2026-09-02.md`) im Wortlaut: "Das Zeichenbudget des Hooks (20000 plus rund 2360 Rahmen) liegt weit ueber der Kappungsgrenze von 10'000 Zeichen, die Claude Code auf Hook-Ausgaben anwendet; oberhalb dieser Grenze erreicht die Einfassung des fremden Teils den Sitzungskontext nicht mehr vollstaendig, sondern als Vorschau samt Dateipfad." Zu entscheiden ist, ob das Budget unter die Grenze gesenkt wird, ob die Einfassung so gebaut wird, dass ihre tragenden Teile auch in der Vorschau stehen, oder ob die Grenze im Kopfkommentar des Hooks festgeschrieben wird | **Neu am 2026-09-23 (ADR 0002, 6.14 c, E3/R3-Q-011).** **Nicht in R3-Q-011 aufgenommen**, weil E3 sich nicht auf die Einfassung verlässt — der Kanal entscheidet über die Herkunft, nicht die Einfassung — und eine Änderung am Eingangs-Hook dort bewusst nicht Gegenstand ist. **Nicht abgelehnt**, weil der Befund die Absicherung aus E2 schwächt und bisher nur in einem Bericht steht, der einen vergangenen Stand belegt, ohne Termin; derselbe Weg wie bei ST-11 (ADR 0002, O-28). Heute nicht entscheidbar, weil die Wirkung nicht gemessen ist: Am 2026-09-02 ergab ein Lauf des Hooks "9008 Zeichen Ausgabe" (ebenda, Beleg zu NF-005), also weniger als die Grenze; ob die Ausgabe heute darüber liegt und was die Sitzung dann tatsächlich erhält, ist mit einem ausgeführten Lauf zu belegen, nicht anzunehmen. Die Kappungsgrenze selbst ist eine Angabe des Berichts und von dieser Rolle nicht nachgeprüft. Die Zuweisung des Berichts (DevOps Engineer mit Security Specialist GRC) ist wie in ADR 0002, 6.13 e an ADR 0001 gemessen: Die Hook-Konfiguration liegt nach ADR 0001, Abschnitt 8 beim SecDevOps Engineer | SecDevOps Engineer mit Security Specialist GRC, auf Grundlage eines ausgeführten Laufs; der DevOps Engineer, falls der Arbeitsablauf eingang.yml des Methodik-Repositories zu ändern ist; Verifikation Static und Dynamic Software Tester auf einem anderen Modell als die Umsetzung (3.4) | mit der nächsten Änderung am Eingangs-Hook, spätestens vor der Freigabe des Grundgerüsts; an E3 ändert der Entscheid nichts |

Nicht offen, sondern entschieden und hier nur zur Klarstellung: `pgvector` (A4), Suchindex (A3), Orchestrierung (A11). Nicht offen, weil gestrichen: VirusTotal, Gesichtserkennung samt biometrischer Vektoren, Open WebUI, CASE/UCO, Fernsteuerung von Maltego; seit der Fortschreibung vom 2026-08-21 auch TheHive und Cortex (5.17).

---

## 9. Was dieser ADR nach seiner Freigabe auflöst und was nachzuführen ist

**Aufgelöst mit der Freigabe:**

| Offener Punkt | Fundstelle | Auflösung |
|---|---|---|
| Ziel-Stack, Rahmenwerk und Komponentenbibliothek der Oberfläche | `docs/04_Kontextmodell.md`, offener Punkt 1 | Stack und Rahmenwerk entschieden (A1, A8); Komponentenbibliothek terminiert als O-2 |
| Ob `pgvector` gebraucht wird | `docs/04_Kontextmodell.md`, offener Punkt 3; 5.18 | Entschieden: nein (A4) |
| Konkrete Befehle je Kettenschritt | `docs/06_Definition_of_Ready_und_Done.md`, offener Punkt 3 | Vorschlag in Abschnitt 6, zu bestätigen durch DevOps und Auftraggeber |
| Abhängigkeit von R3-Q-001 auf R3-C-001 | `docs/05_Product_Backlog.md`, R3-Q-001 | Aufgelöst: Der Hook ruft `make dod`; die Werkzeugnamen stehen im Makefile |
| Einbindungstiefe TheHive/Cortex | `docs/04_Kontextmodell.md`, offener Punkt 2 | **Nicht** aufgelöst; neu terminiert als O-4, mit dem Befund, dass zuerst ein Backlog-Eintrag fehlt. **Fortschreibung 2026-08-21:** O-4 ist inzwischen entfallen — TheHive und Cortex gestrichen (5.17 neu), Abschnitt 8 |

**Nachzuführen durch die zuständigen Rollen — nicht durch diese Arbeitseinheit:**

| Was | Wo | Wer |
|---|---|---|
| Suchindex in PostgreSQL, Container- und Netzlayout, Modulschnitt, Auflösung der offenen Punkte 1 und 3 | `docs/04_Kontextmodell.md` | Software Architect, eigene Arbeitseinheit |
| Konkrete Befehle in der Tabelle D1 bis D12, Befunde zu D10 und D12 | `docs/06_Definition_of_Ready_und_Done.md` | DevOps Engineer, Bestätigung Auftraggeber |
| **Fortschreibung 2026-08-30:** Kriterienzeile für den Kettenschritt D18 (Architekturverträge) in Teil 2; Kriterium D11 auf beide Gegenstände erweitert (Arbeitsbaum **und** Git-Historie); die Wendung "Kette D1 bis D12" ist unvollständig geworden | `docs/06_Definition_of_Ready_und_Done.md` | DevOps Engineer mit Product Owner, Bestätigung Auftraggeber mit R3-Q-001 |
| **Fortschreibung 2026-08-30:** zwei gitleaks-Läufe in D11, neues Ziel `architekturvertraege` für D18 in der Reihenfolge nach D4 und vor D5, D12 ohne Schreibvorgang in den Arbeitsbaum | `Makefile` | DevOps Engineer, in derselben Arbeitseinheit |
| **Fortschreibung 2026-08-30:** die Wendung "Kette D1 bis D12" im Rollenprofil | `.claude/agents/static-software-tester.md` | Rolle, die die Rollendateien pflegt (ADR 0001) |
| **Zweite Fortschreibung 2026-08-30:** `--locked` statt `--frozen` in D1 und an jedem `uv run`-Aufruf einschliesslich der Verfügbarkeitsproben; Rahmenprüfung D19 um die Zielliste von `make dod` gelegt, auch bei Abbruch laufend; Objektbedingungen aller Schritte an die Objekttabelle in Abschnitt 6 angeglichen — namentlich D18 (Python-Produktionscode unterhalb `backend/src/` statt `backend/src/r3cosint/`), D10 (läuft, solange `prototype/` besteht) und der Backend-Anteil von D1 bis D8 (`backend/pyproject.toml` statt `backend/`) | `Makefile` | DevOps Engineer |
| **Zweite Fortschreibung 2026-08-30:** Zwischenspeicher der Prüfwerkzeuge ergänzen (`.pytest_cache/`, `.ruff_cache/`, `.mypy_cache/`, Abdeckungsdateien, Berichte der durchgehenden Oberflächenläufe) — heute steht keiner davon dort, und ohne sie schlägt D19 an | `.gitignore` | DevOps Engineer |
| **Zweite Fortschreibung 2026-08-30:** Kriterienzeile für die Rahmenprüfung **D19** (Unverändertheit des Arbeitsbaums) in Teil 2; der Absatz zum Kettengrundsatz um die Beobachtung durch D19 ergänzt, weil "beobachtbar" dort bisher niemanden benennt, der beobachtet; Kriterium D1 um die Aussage ergänzt, dass eine Abweichung zwischen `pyproject.toml` und `uv.lock` den Schritt rot macht; Punkt 3 der offenen Punkte um den beantworteten Teil von O-10 nachgeführt | `docs/06_Definition_of_Ready_und_Done.md` | DevOps Engineer mit Product Owner, Bestätigung Auftraggeber mit R3-Q-001 |
| **Dritte Fortschreibung 2026-08-30:** `--project backend` an jedem `uv`-Aufruf (bereits umgesetzt, hiermit gedeckt); Suchmuster und **Wegfall der Lage B** bei D7 — ein Nichtfinden des Backlogs endet ungleich 0 statt mit 0; `git` als Prüfmittel des Historienlaufs in D11, sein Fehlen ergibt Lage C bei vorhandenem `.git/` (bereits umgesetzt, hiermit gedeckt) | `Makefile` | DevOps Engineer |
| **Dritte Fortschreibung 2026-08-30:** Kriterium D7 — der Schritt hat keine Lage B; Kriterium D11 um `git` als Prüfmittel des Historienlaufs ergänzt; die `uv`-Aufrufe der Kette tragen `--project backend` | `docs/06_Definition_of_Ready_und_Done.md` | DevOps Engineer mit Product Owner, Bestätigung Auftraggeber mit R3-Q-001 |
| **Dritte Fortschreibung 2026-08-30:** Nachweis mit ausgeführtem Lauf, dass `--locked --project backend` nicht mehr mit "has no effect" antwortet, und Feststellung, welchen Gegenstand `pytest` in D5 und D6 ohne Pfadangabe aus der Repository-Wurzel einsammelt (6.3.1) | ausgeführter Lauf, Ergebnis in die Übergabedatei | DevOps Engineer, Verifikation Static und Dynamic Software Tester (3.4) |
| **Achte Fortschreibung 2026-09-01:** neues Ziel `belege` für D20 (`bash scripts/belege-pruefen.sh`), eingehängt als **erster** Eintrag der Zielliste von `make dod` vor D1; `D20` in die eigenständige Liste der erwarteten Kettenschritte aufnehmen, sonst bricht die Kette an ihrer eigenen Vorprüfung ab; Lage-Marke des Schrittes nach der Objekttabelle — **keine Lage B**, fehlendes Prüfmittel und leerer Bestand ergeben Lage C; die Zahl der nicht prüfbaren Zeilen gehört in die Lage-Meldung (6.8.3); die Schlusszeile "D1 bis D12 plus D18" ist unvollständig geworden | `Makefile` | DevOps Engineer |
| **Achte Fortschreibung 2026-09-01:** Kriterienzeile für den Kettenschritt **D20** (Belege) in Teil 2, samt der Aussage, was ein grüner Lauf trägt und was nicht (6.8.4); der neue Kettengrundsatz "Rückgabewert 0 heisst: nichts von dem gefunden, was dieser Schritt sucht" gilt für alle Schritte und gehört in denselben Teil; die Wendung "Kette D1 bis D12" ist ein zweites Mal unvollständig geworden. Zusammen mit der noch offenen Nachführung von D19 aus der zweiten Fortschreibung vom 2026-08-30 nachzuführen — solange D19 dort fehlt, liest sich D19 als freie Nummer (6.8.1) | `docs/06_Definition_of_Ready_und_Done.md` | DevOps Engineer mit Product Owner, Bestätigung Auftraggeber mit R3-Q-001 |
| **Neunte Fortschreibung 2026-09-01:** Die Beobachtung der Index-Maskierung ist bereits umgesetzt und hiermit gedeckt — zu ändern ist allein die **Benennung** des Ausgangs: Der Befundtext "D19 nicht beobachtbar" nennt neu ausdrücklich **Lage C**, damit Marke und Nachweiszeile dieselbe Sprache sprechen wie die übrigen Schritte. Kein Verhaltenswechsel, keine Änderung am Rückgabewert. Ebenfalls gedeckt, nicht zu ändern: die Bestimmung des Arbeitsbaums über `git` statt über einen Verzeichnisnamen (6.9.3) | `Makefile` | DevOps Engineer |
| **Neunte Fortschreibung 2026-09-01:** Kriterium D19 um den zweiten Teil des Prüfmittels ergänzen (Beobachtbarkeit des Index; ein gesetztes `assume-unchanged` oder `skip-worktree` ist Lage C, auch wenn es schon vor dem Lauf gesetzt war) und um die Unterscheidung der beiden Massstäbe — Gegenstand relativ, Instrument absolut; die geschärfte Lage C gilt für **alle** Schritte und gehört in denselben Teil | `docs/06_Definition_of_Ready_und_Done.md` | Requirements Engineer mit DevOps Engineer, Bestätigung Auftraggeber mit R3-Q-001 |
| **Neunte Fortschreibung 2026-09-01 — erledigt am selben Tag:** ausgeführter Lauf zur Beantwortung von O-16. Ergebnis in 6.10.1; die Befundmeldung ist daraufhin in 6.10.2 festgelegt und im Makefile bereits so benannt worden | ausgeführter Lauf | erledigt durch den Koordinator |
| **Zehnte Fortschreibung 2026-09-01:** Die Benennung des Befundtextes (Lage C, mitgeführtes Messergebnis) ist umgesetzt und hiermit gedeckt. Zu prüfen bleibt allein, dass die Meldung nicht mehr behauptet, der Arbeitsbaum sei unbeobachtet, sondern nennt, **welche Hälfte** des Instruments stumm ist und was die andere gemessen hat (6.10.2) | `Makefile` | DevOps Engineer, Verifikation Static und Dynamic Software Tester (3.4) |
| **Zehnte Fortschreibung 2026-09-01:** ausgeführter Lauf zur Beantwortung von **O-17** — weicht die Aufnahme ab, wenn eine maskierte, verfolgte Datei gelöscht wird? Ergebnis in die Übergabedatei; fällt es ungünstig aus, ist die Aussage über maskierte Dateien in der Meldung enger zu fassen | ausgeführter Lauf | DevOps Engineer, Verifikation Static und Dynamic Software Tester (3.4) |
| **Zehnte Fortschreibung 2026-09-01:** Kriterium D19 — die Meldung bei stummgeschaltetem Instrument nennt die betroffene Hälfte und das Ergebnis der anderen; sie behauptet nicht, der Arbeitsbaum sei unbeobachtet | `docs/06_Definition_of_Ready_und_Done.md` | Requirements Engineer mit DevOps Engineer, Bestätigung Auftraggeber mit R3-Q-001 |
| **Zwölfte Fortschreibung 2026-09-02 — Entwurf, erst nach der Freigabe von 6.12 auszuführen:** vier Änderungen am Ziel `dod` und an den Kettenschritten. (1) Die Schleife bricht bei Lage C nicht mehr ab, sondern vermerkt Kennung, Ziel und fehlendes Prüfmittel und läuft weiter; abgebrochen wird bei `A_FAIL`, bei fehlender oder mehrfacher Marke und bei jedem anderen Rückgabewert ungleich 0 (G5, 6.12.6). (2) Feste Grammatik der Lage-Marke: `<Lage>[ FEHLT=<wert>][ SCHWELLE=…\|OHNE_SCHWELLE]`. Jeder der 53 Lage-C-Zweige setzt neben `hat_lage_c=1` eine **Shell-Variable zur Laufzeit** mit dem fehlenden Prüfmittel; `KLASSIFIZIEREN` hängt daraus im C-Zweig selbst `FEHLT=<wert>` an, vor dem Zusatz aus dem vierten Parameter, und bei leerer Variable lautet der Wert `FEHLT=unbenannt`. Der vierte Parameter wird **nicht** umgewidmet — D3, D6 und D8 belegen ihn statisch mit `SCHWELLE=`/`OHNE_SCHWELLE`, und bei Lage C stehen beide Zusätze nebeneinander (G6, 6.12.7; Fassung nach Runde 1 der Prüfung, die erste Fassung dieser Zeile sprach vom vierten Parameter und übersah dessen Belegung sowie den Unterschied zwischen Expansions- und Laufzeit). (3) **Vier** eindeutige Schlusszeilen (die vierte für den vollständig gelaufenen Lauf mit D19-Befund — Nachtrag aus dem Bau, 6.12.23 a; die Zeile hiess bis dahin "drei"), eine eigenständige D19-Zeile in **jedem** Ausgang mit fester Grammatik `make dod: D19: <OHNE_BEFUND\|VERLETZT\|B\|C>[ -- <Text>].` — heute fünf freie Befundtexte mit zwei Schreibweisen für Lage C und eine Lage-B-Zeile, die nicht mit `D19:` beginnt — und eine erste Zeile `make dod: geprueft wird <PROJ>.`; die D19-Angabe fällt aus der Erfolgszeile weg statt dort zusätzlich zu stehen (G7, 6.12.8). (4) Im Ziel `belege` prüft der Wächter-Block zusätzlich, ob der Klon flach ist; ist er es, ist das Lage C mit `git fetch --unshallow` als Beschaffungsweg (G16, 6.12.17). Kein Kettenschritt wechselt dadurch seine Lage, und kein roter Lauf wird grün | `Makefile` | DevOps Engineer; Verifikation Static und Dynamic Software Tester auf einem anderen Modell (3.4) |
| **Zwölfte Fortschreibung 2026-09-02 — Entwurf:** neues Hook-Skript nach 6.12, das `Stop`, `SubagentStop` und `TaskCompleted` bedient und über `hook_event_name` verzweigt; es fängt Standard- und Fehlerausgabe von `make dod` gemeinsam ab und lässt auf die eigene Standardausgabe ausschliesslich ein JSON-Objekt oder nichts | `.claude/hooks/dod-gate.sh` (neu) | DevOps Engineer; Verifikation Static und Dynamic Software Tester (3.4) |
| **Zwölfte Fortschreibung 2026-09-02 — Entwurf:** die Liste der terminierten Lagen C, versioniert, in der Form aus 6.12.5. Sie enthält beim Anlegen ausschliesslich Einträge für Artefakte, die dieser ADR als noch nicht entstanden führt; `gitleaks` und jedes Prüfmittel von D20 sind darin unzulässig | `.claude/hooks/dod-gate-terminierte-lagen.txt` (neu) | Software Architect legt die Einträge an (Fortschreibung dieses Abschnitts); DevOps Engineer baut die Auswertung; Verifikation Static und Dynamic Software Tester (3.4) |
| **Zwölfte Fortschreibung 2026-09-02 — Entwurf:** drei Hook-Einträge in der **versionierten** Datei, für `Stop`, `SubagentStop` und `TaskCompleted`, ohne Matcher, in Exec-Form mit `args`, das Skript über `${CLAUDE_PROJECT_DIR}` angesprochen, `timeout: 900` je Eintrag (G11, 6.12.12). Cloud-Sitzungen lesen die lokale `~/.claude/settings.json` nicht (3.4) | `.claude/settings.json` | DevOps Engineer |
| **Zwölfte Fortschreibung 2026-09-02 — Entwurf:** Abschnitt "Durchsetzung" um das Gate nachführen — die drei Ereignisse und wer die Zusicherung trägt (6.12.2), die Unterscheidung Befund/Ausfall (6.12.4), die terminierten Lagen C samt ihren sechs Selbstprüfungen (6.12.5), die Zählung und die Eskalation (6.12.9), das Verhalten bei `stop_hook_active` (6.12.10) und die Aussage eines Durchlasses (6.12.18). Zusätzlich: der Satz zur Obergrenze nennt heute eine Umgebungsvariable, die in der gelesenen Dokumentation nicht vorkommt (O-19); die Kriterienzeilen D7 bis D12 und D20 sind um das strukturierte `FEHLT=` und um das Weiterlaufen bei Lage C zu ergänzen; D20 zusätzlich um die Vollständigkeit der Historie als siebtes Prüfmittel | `docs/06_Definition_of_Ready_und_Done.md` | Requirements Engineer mit DevOps Engineer, Bestätigung Auftraggeber mit R3-Q-001 |
| **Zwölfte Fortschreibung 2026-09-02 — Entwurf:** Tabelle "Aktive Gates" um das Definition-of-Done-Gate ergänzen; der Absatz "Noch nicht vorhanden" ist für `Stop`, `SubagentStop` und `TaskCompleted` überholt, sobald das Gate steht (R3-Q-005 bleibt offen). In der Lieferreihenfolge ist R3-Q-001 als erledigt zu führen, sobald Abnahme und Verifikation vorliegen | `CLAUDE.md` | Protocol Master |
| **Zwölfte Fortschreibung 2026-09-02 — Entwurf:** Abschnitt "Hooks" um zwei belegte Sätze ergänzen, die dort fehlen und beide gegen ein wirkungsloses Gate schützen: Ein Hook, der seine Zeitgrenze reisst, wird abgebrochen und **lässt durch** — die Zeitgrenze ist deshalb im Skript selbst zu ziehen, kürzer als in `settings.json`; und die Standardausgabe eines Hooks darf ausschliesslich das JSON-Objekt tragen, weil eine misslungene Auswertung als Fehler erscheint. Beides ist der Referenz vom 2026-09-02 entnommen | `.claude/rules/claude-konfiguration.md` | DevOps Engineer mit Protocol Master |
| **Zwölfte Fortschreibung 2026-09-02 — Entwurf, Befund aus Runde 1 (B13):** Der Abschnitt zu den Hooks erklärt die harte Obergrenze "über `CLAUDE_CODE_STOP_HOOK_BLOCK_CAP`" für **verbindlich**. Die Variable ist in der am 2026-09-02 gelesenen Hook-Dokumentation nicht belegt (O-19); die Obergrenze 8 steht dort ohne Variablennamen. Die Stelle ist nachzuführen, sobald O-19 entschieden ist — eine verbindlich erklärte Einstellung, die es möglicherweise nicht gibt, ist als Bauvorschrift untauglich | `docs/adr/0001-rollenmodell.md` | Software Architect als Fortschreibung jenes ADR, nach dem Entscheid zu O-19 |
| **Zwölfte Fortschreibung 2026-09-02 — Entwurf, bedingt auf den Entscheid zu O-23 (Befund B4 aus Runde 1):** Wählt der Auftraggeber Weg (1), ist eine Vorschrift nachzuführen, dass **jede Arbeitseinheit als Aufgabe geführt wird** — sonst feuert `TaskCompleted` nicht, und die einzige harte Zusicherung des Gates trägt nichts (6.12.2, 6.12.18 Punkt 5). Wählt er Weg (2), ist an derselben Stelle festzuhalten, dass die Kette in Sitzungen ohne Aufgabenliste nur angemahnt und nicht erzwungen wird. Eine der beiden Fassungen ist zu schreiben, keine ist wegzulassen | `CLAUDE.md` oder `.claude/rules/claude-konfiguration.md` | Protocol Master (CLAUDE.md) beziehungsweise DevOps Engineer (Regeldatei), nach dem Entscheid des Auftraggebers |
| **Zwölfte Fortschreibung 2026-09-02 — Entwurf:** Das Abnahmekriterium `R3-Q-001_gate_blockiert` ist zu präzisieren. Es setzt heute "roter Prüflauf" mit "Rückgabewert ungleich 0" gleich; mit den terminierten Lagen C endet `make dod` mit 2, während das Gate mit 0 endet. Vorschlag: "rot" ersetzen durch "Befund — `A_FAIL`, D19 `VERLETZT` oder nicht nachweisbar gelaufen"; als eigener, ebenfalls zu prüfender Fall aufnehmen, dass ein Lauf, dessen einzige Abweichungen gedeckte terminierte Lagen C sind, mit 0 endet und sich über `systemMessage` meldet; dazu die weiteren Fälle aus 6.12.19. Der Eintrag trägt weiterhin keinen benannten Stakeholder (offener Punkt 12 des Backlogs) | `docs/05_Product_Backlog.md` | Product Owner mit Requirements Engineer, Bestätigung Auftraggeber |
| **Zwölfte Fortschreibung 2026-09-02 — Entwurf:** **drei** ortsgebundene Ausnahmeeinträge, jeder mit Tatsachengrund, jeder Umsetzung nach 6.8.5 und **kein** Architekturentscheid. (1) Für den Fund auf `origin/main` — der lokale Zweig-Ref als Beleg in einer Übergabedatei; die Übergabedatei selbst wird nicht geändert (siehe den letzten Absatz dieses Abschnitts). (2) und (3) Für die beiden Pfade `.claude/hooks/dod-gate.sh` und `.claude/hooks/dod-gate-terminierte-lagen.txt`, die dieser Abschnitt nennt und die erst mit dem Bau entstehen; Form `datei\|wert`, gebunden an `docs/adr/0002-architekturentscheid-ziel-stack.md`. **Die Einträge (2) und (3) sind mit dem Entstehen der beiden Dateien wieder zu entfernen** — die Selbstprüfung "der Gegenstand existiert inzwischen" macht sie dann selbst zum Befund (6.8.5, Eigenschaft 3), und genau das ist ihre Sollbruchstelle | `scripts/belege-ausnahmen.txt` | Die Rolle, deren Dokument den Fund ausgelöst hat; Verifikation durch eine andere Rolle (3.4) |
| **Zwölfte Fortschreibung 2026-09-02 — Entwurf:** Zeile für das neue Hook-Skript und die Liste der terminierten Lagen in der Artefaktliste des Nachweiserzeugers; Neuerzeugung des Nachweisverzeichnisses; Changelog | `scripts/nachweise-erzeugen.sh`, `docs/NACHWEISE.md`, `CHANGELOG.md` | Protocol Master (4.2, 6.6) |
| **Zwölfte Fortschreibung 2026-09-02 — Entwurf:** zu prüfen, ob ein methodischer Entscheid festzuhalten ist — die Unterscheidung zwischen einer Kette, die streng bleibt, und einem Gate der Arbeitsumgebung, das einen abzählbaren, selbstprüfenden und terminierten Ausfall duldet, während die Gegenseite ihn nicht kennt (6.12.5). Diese Rolle schlägt ihn vor und trägt ihn nicht selbst ein | `methodik/entscheide.md` im Methodik-Repository | Protocol Master mit dem Auftraggeber |
| **Nachträge aus der Verifikation 2026-09-02 (6.12.24, Bau auf Weisung begonnen, förmliche Freigabe ausstehend):** Entscheide zu den Befunden B-01, B-02, B-03, N-01, N-04 bis N-07 und N-09 — im Gate umgesetzt, N-01 und N-07 allein durch den Entscheid ohne Codeänderung — der geprüfte Baum als **physisch aufgelöste Wurzel** des Arbeitsbaums (a); der Schlüssel `KETTE baum-widerspruch` (b); kein Ausgang 1 mehr bei nicht bestimmbarem Zustandsverzeichnis, sondern dieselbe Behandlung wie bei einem nicht beschreibbaren (c); der Zähler bleibt beim Durchlass nach der Eskalation stehen (d); Sperrdatei unter `/tmp`, wenn das Zustandsverzeichnis ausfällt, und Lauf ohne Sperre mit Meldung, wenn auch das nicht geht (e); die Wegwerfdatei nachweislich ausserhalb des Baums, sonst `GATE mktemp` (f); `sha256sum` und `mktemp` als Prüfmittel mit eigenem Schlüssel (g); die Selbstprüfungen 2, 4 und 6 vor dem Lauf der Kette, Schlüssel aus der kleinsten Zeilennummer (h). **Nach Runde 2 zusätzlich:** der Zähler zählt beim Durchlass nach der Eskalation **weiter** statt still zu stehen, und die Meldung nennt das n-te Mal (d, DT2-B1); der Hinweis auf ein ausgefallenes Zählwerk steht in **jeder** Meldung, bei sauberem Grün als einzige, und unterscheidet "nicht bestimmbar" von "nicht beschreibbar" (c, S-13); der Kettenlauf erhält `TMPDIR` gleich dem Verzeichnis der geprüften Wegwerfdatei, damit auch die Kette nicht in den Baum schreibt (f, DT2-B2); die Zahl der gelesenen Marken wird gegen die Zahl der Schlusszeile geprüft, mindestens eine Marke verlangt, Abweichung `KETTE ausgabe-unlesbar` (k, S-11); `D19 B-widerspruch` geht der Konsistenzwache vor (S-01), eine fehlende Baumzeile ist `KETTE ausgabe-unlesbar` (S-10) | `.claude/hooks/dod-gate.sh` | DevOps Engineer; Verifikation Static und Dynamic Software Tester auf einem anderen Modell (3.4) |
| **Nachträge aus der Verifikation 2026-09-02 (6.12.24 i):** Selbsttest — alle **acht** Kombinationen der D19-Zeile (N-02); der G13-Fall mit den **echten** Rollendateien `static-software-tester.md` und `pentester.md` samt Gegenfall `devops-engineer.md` (N-03); eigene Fälle für G12 (Unterverzeichnis, Schrägstrich am Ende, Symlink, `cwd` ausserhalb des Repositories, zweiter Arbeitsbaum — DT-B5); die Übergabedatei des Falls zur Eskalation nachweislich in `HEAD` (DT-B4); je ein Fall für die Entscheide a), c), e), f), g) und h) sowie für D12 mit mehreren fehlenden Gegenständen (N-08). **Nach Runde 2 zusätzlich** die dort als fehlend beanstandeten Fälle (S-03, S-04, S-05) und je ein Fall für: null Marken bei Form-1-Schlusszeile und Rückgabewert 0 sowie abweichende Markenzahl (k, S-11); D19 Lage B bei Rückgabewert 0 unter `D19 B-widerspruch` (S-01); fehlende Baumzeile unter `KETTE ausgabe-unlesbar` (S-10); `TMPDIR` in den Baum, wobei die **Kette selbst** eine Wegwerfdatei anlegt (f, DT2-B2); Weiterzählen des Zählers nach dem vierten Durchlass (d, DT2-B1); die Meldung zum ausgefallenen Zählwerk bei grüner Kette (c, S-13) | `scripts/dod-gate-selbsttest.sh` | DevOps Engineer; Verifikation Static und Dynamic Software Tester (3.4) |
| **Nachträge aus der Verifikation 2026-09-02 (6.12.24 i, Befund N-08):** In D12 gewinnt bei mehreren fehlenden Gegenständen der **erste** in `FEHLT=`; kein späterer `if`-Block überschreibt ihn. Anwendung von G6, keine neue Regel | `Makefile` | DevOps Engineer |
| **Nachträge aus der Verifikation 2026-09-02 (6.12.24, Befunde B-04 und B-05) — bereits ausgeführt (Fremdbeleg, nicht von dieser Rolle geprüft):** die ortsgebundene Ausnahme für `CLAUDE.md`, deren Zeilenangabe durch das Wachsen der Datei überholt war, ist nachgeführt; vier Ausnahmen der Form `datei\|wert` decken die in `docs/06_Definition_of_Ready_und_Done.md` genannten, noch nicht gebauten Skripte. Umsetzung nach 6.8.5, **kein** Architekturentscheid; die vier Einträge sind mit dem Entstehen der Skripte wieder zu entfernen (6.8.5, Eigenschaft 3) | `scripts/belege-ausnahmen.txt` | Koordinator, ausgeführt am 2026-09-02; Verifikation durch eine andere Rolle (3.4) |
| **Nachträge aus der Verifikation 2026-09-02 (6.12.24 j):** **Drei** Prüfrunden sind gelaufen und in 6.12.24 j verzeichnet. Runde 3 (2026-09-03, Fremdbeleg): alle dreizehn Befunde aus Runde 2 sind mit eigenen Läufen **beider** Prüfer als behoben belegt, der Selbsttest besteht **81 von 81** Fällen, unabhängig reproduziert — und dennoch ist die Runde **nicht bestanden** (S3-01 statisch, DT3-B1 dynamisch, dazu sechs nicht blockierende Befunde). Weil dieselbe Fehlerklasse zum dritten Mal auftrat, ist die **Arbeitseinheit am 2026-09-03 nach 3.4 abgebrochen**, die Übergabedatei `docs/uebergaben/2026-09-02_r3-q-001-gate-gebaut.md` mit der Eskalationszeile geschrieben und **O-24** vorgelegt worden. Nachzuführen bleiben: der Entscheid zu O-24, danach die fünf in 6.12.24 j, Punkt 16, als Vorschlag festgehaltenen Behebungen und eine **vierte** Prüfrunde; erst sie belegt den Stand danach, dieser ADR belegt ihn nicht. Die Forderung aus 6.12.23 d — der grüne Lauf gegen das **echte** `Makefile` mit **Rückgabewert 0 der Kette** — ist nach Fremdbeleg beider Prüfer in beiden Runden durch Selbsttestfall 28 erfüllt; der Lauf am echten Bestand endete erwartungsgemäss mit Form 2 und Rückgabewert 2 (terminierte Lage C bei D7, D10 und D12) | Prüfbericht, Ergebnis in die Übergabedatei | Static und Dynamic Software Tester auf einem anderen Modell als die Umsetzung (3.4) |
| **Dreizehnte Fortschreibung 2026-09-03 (6.12.25, Entscheid des Auftraggebers zu O-24):** (1) Der Selbsttest trägt **je Kennung `Z-nnn` der Tabelle 6.12.19 genau eine Prüfung** und gibt je Prüfung eine Zeile `BESTANDEN Z-nnn …` oder `FEHLGESCHLAGEN Z-nnn …` aus; am Ende liest er die Kennungen aus der Tabelle dieser ADR-Datei (Zeilen, die mit `\| Z-` beginnen) und endet ungleich 0, wenn eine Kennung ohne Prüfung ist **oder** eine Prüfung eine Kennung trägt, die nicht in der Tabelle steht (zurückgezogene Kennungen ausgenommen und als solche ausgegeben). (2) Im Gate: die Blockmeldung nennt **alle** Abweichungen, gezählt wird weiterhin die erste in Kettenreihenfolge (b, S3-01); das Zielverzeichnis der Wegwerfdatei wird **vor** dem Anlegen bestimmt, die Prüfung danach bleibt als Wache (c, DT3-B1); ein physisch nicht auflösbares Verzeichnis endet mit 2 und `GATE mktemp` (d, S3-05). (3) Neue Zusicherungen `Z-137` bis `Z-141` (Markenzahl bei Form 2 und 4, Gegenprobe Form 3) und `Z-129` (keine zweite Forderung nach der Übergabedatei) — e), S3-02 und S3-07. Erst eine **vierte** Prüfrunde belegt den Stand danach; dieser ADR belegt ihn nicht. **Nachtrag vom 2026-09-03 nach der vierten Runde (6.12.25 f bis k):** (4) Die Tabelle 6.12.19 nennt je Zeile den **Messumfang** — Kanal, Ereignis und, wo es darauf ankommt, Anzahl —, und die Prüfung misst genau diesen Umfang; **75** Zeilen sind daraufhin präzisiert (f). (5) `Z-129` ist berichtigt: keine **Forderung** nach der Übergabedatei bei irgendeinem Ereignis nach dem vierten Durchlass, auf **keinem** der beiden Kanäle; das Zitat der Zeile `Eskalation 3.4: <Schlüssel>` als Begründung des Durchlasses bleibt zulässig (g). (6) `Z-110` ist zurückgezogen, `Z-111` misst den ganzen Baum (h). (7) Im Gate: **jeder** Block mit Schlüssel `GATE <Prüfmittel>` läuft über die Zählung nach 6.12.9, einzige Ausnahme `GATE jq`; neue Zusicherungen `Z-146` bis `Z-151` (i). (8) Im Selbsttest: Sperre (`flock`) auf `/tmp/r3cosint-dod-gate-selbsttest.lock` für die ganze Laufzeit, ohne Wartezeit genommen, sonst `Selbsttest laeuft bereits` auf der Fehlerausgabe und Rückgabewert 3; neue Zusicherungen `Z-152` und `Z-153` (j). Die Tabelle führt damit `Z-001` bis `Z-153`, davon `Z-110` zurückgezogen. Erst eine **fünfte** Prüfrunde belegt den Stand danach | `scripts/dod-gate-selbsttest.sh`, `.claude/hooks/dod-gate.sh`; Spezifikation in `docs/adr/0002-architekturentscheid-ziel-stack.md` (6.12.19, 6.12.25) | DevOps Engineer; Verifikation Static und Dynamic Software Tester auf einem anderen Modell als die Umsetzung (3.4) |
| **Vierzehnte Fortschreibung 2026-09-03 (6.12.26, Entscheid des Auftraggebers zu O-25):** (1) Die Tabelle 6.12.19 trägt die Spalten **Kennung, Fall, Kanal, Zusicherung, Mutation, Herkunft**. Der Selbsttest meldet je Kennung den **tatsächlich benutzten Kanal** mit und endet ungleich 0, wenn er vom Kanal der Tabelle abweicht — zusätzlich zur Deckung in beide Richtungen aus 6.12.25 a. Der Wertevorrat ist abschliessend: `rc`, `stdout`, `stderr`, `zaehler`, `datei`, `beobachter`, `kette`, `selbsttest`, `dauer`. (2) Neue versionierte Datei `scripts/dod-gate-mutationen.txt` (Kennung, Ziel, `sed`-Ausdruck oder `keine`, Grund) und ein **Mutationsmodus** `--mutationen` des Selbsttests: Deckung der Einträge in beide Richtungen, die mutierte Kopie muss sich vom Original unterscheiden, und genau die Kennung der Mutation muss `FEHLGESCHLAGEN` melden. (3) Behebungen der fünften Runde: die 16 Zeilen aus S5-01 messen auf dem in ihrer Zeile genannten Kanal (Wortlaut unverändert); die Attrappenkette hält ihre Wegwerfdatei mindestens 300 ms, damit `Z-111` ein Beobachtungsfenster hat (DT5-01); `Z-018` misst den Stand 2 vor und nach dem Aufruf statt der Abwesenheit der Zählerdatei (S5-03). (4) Im `Makefile`: nichts zu ändern ausser den Mutationszielen des Prüfaufbaus — die Baumzeile und der Beschaffungsweg `git fetch --unshallow` sind Gegenstand von Mutationen, nicht von Änderungen. Erst eine **sechste** Prüfrunde belegt den Stand danach; dieser ADR belegt ihn nicht | `scripts/dod-gate-selbsttest.sh`, `scripts/dod-gate-mutationen.txt` (neu), `.claude/hooks/dod-gate.sh`; Spezifikation in `docs/adr/0002-architekturentscheid-ziel-stack.md` (6.12.19, 6.12.26) | DevOps Engineer; Verifikation Static und Dynamic Software Tester auf einem anderen Modell als die Umsetzung (3.4) |
| **Vierzehnte Fortschreibung 2026-09-03 (6.12.26 c, Befund S5-02):** Der Ausweichname der Zählerdatei bei fehlendem `sha256sum` — die bereinigte Rohform der `session_id`, nur `A-Za-z0-9_-`, alles andere zu `_` — ist in 6.12.9 und 6.12.11 terminiert. Im Gate bereits so gebaut; hiermit gedeckt, **keine** Codeänderung | `.claude/hooks/dod-gate.sh` | DevOps Engineer, nichts auszuführen; Verifikation Static Software Tester (3.4) |
| **Vierzehnte Fortschreibung 2026-09-03:** neue Zeile für `scripts/dod-gate-mutationen.txt` in der Artefaktliste des Nachweiserzeugers; Neuerzeugung des Nachweisverzeichnisses; Changelog | `scripts/nachweise-erzeugen.sh`, `docs/NACHWEISE.md`, `CHANGELOG.md` | Protocol Master (4.2, 6.6) |
| **Vierzehnte Fortschreibung 2026-09-03 (6.12.26 e, Entscheide 1 und 4):** Die Ausnahmeliste `kanal_ausnahmen_bekannt` mit `Z-080` und `Z-130` ist **ersatzlos zu entfernen** — die Tabelle 6.12.19 führt für beide Kennungen neu den Kanal `kette`, Tabelle und Messung stimmen damit überein, und eine geduldete Abweichung nähme dem Abgleich nach 6.12.26 a für diese beiden Zeilen die Wirkung. Am Kanal `kette` selbst und an den Messhüllen ist nichts zu ändern | `scripts/dod-gate-selbsttest.sh` | DevOps Engineer; Verifikation Static Software Tester (3.4) |
| **Vierzehnte Fortschreibung 2026-09-03 (6.12.26 e, Phase 3 unvollständig):** trennscharfe Mutationen für `Z-124` (Ausdruck trifft 10 Stellen einschliesslich einer Kommentarzeile) und `Z-133` (der zweite Disjunkt trägt den geforderten Rückgabewert 2 weiter, die Messung isoliert die zerstörte Eigenschaft nicht); Abtragen der **18** nicht erkannten und **3** wirkungslosen Mutationen. Ziel bleibt Rückgabewert 0 des Mutationsmodus bei `nicht_erkannt=0` und `wirkungslos=0` | `scripts/dod-gate-mutationen.txt`, `scripts/dod-gate-selbsttest.sh` | DevOps Engineer; Verifikation Static und Dynamic Software Tester auf einem anderen Modell (3.4) |
| **Vierzehnte Fortschreibung 2026-09-03 (6.12.26 e):** **siebte Prüfrunde** — die sechste ist statisch (12 Befunde) und dynamisch (6 Befunde) nicht bestanden, der Bau danach in drei Phasen fortgeführt, Phase 3 unvollständig. Erst die siebte Runde belegt den Stand nach den beiden vorstehenden Zeilen; dieser ADR belegt ihn nicht. **O-25**, die Entscheidpunkte E-A bis E-K und die Abnahme des Gates bleiben offen (Abschnitt 10) | Prüfbericht, Ergebnis in die Übergabedatei | Static und Dynamic Software Tester auf einem anderen Modell als die Umsetzung (3.4) |
| **Fünfzehnte Fortschreibung 2026-09-03 (6.12.26 f, Runde 7):** (1) `Z-114` misst neu `rc+datei` — Rückgabewert 2 **und** fehlende Spurdatei der Attrappenkette, damit die offen ausfallende Wache (`if false`) erkannt wird; (2) `Z-132` misst neu `datei` an einer Spurdatei ausserhalb des Baums, in die die Attrappenkette das ihr wirksam übergebene `TMPDIR` schreibt; (3) `Z-133` läuft gegen eine Form-1-Schlusszeile mit genau `0 gueltige Marken gezaehlt`, damit allein die Forderung nach mindestens einer Marke den Block trägt; (4) `Z-124` erhält zwei fehlerhafte Zeilen mit verschiedenen Schlüsseln und eine über den Block **verankerte** Mutation der Abbruchanweisung der Selbstprüfungen 2, 4 und 6; (5) `Z-139` trägt `keine` (Grund 3, Schwester `Z-140`); (6) neu `Z-154` und `Z-155` zur Bindung des Durchlasses an den **gezählten** Schlüssel (`DT7-03`), `Z-155` mit `keine` (Grund 3, Schwester `Z-154`); (7) `Z-089` genau **einmal** messen, und die Deckungsprüfung zählt eindeutige Kennungen — eine doppelt gemeldete Kennung ist selbst eine Abweichung (`S7-04`); (8) die Ausnahmeliste `kanal_ausnahmen_bekannt` ersatzlos entfernen (`S7-03`, bereits in e angeordnet); (9) für `rc`, `stdout`, `stderr`, `zaehler` und `kette` sind die **typisierten** Messhüllen verbindlich, eine `pruefe_wahr`-Meldung mit einem dieser fünf Kanäle verwirft der Abgleich als Abweichung (`S7-05`); (10) an der Sperre unter `/tmp` ist nichts zu ändern (`S7-06`). Ziel bleibt Rückgabewert 0 in beiden Modi bei `nicht_erkannt=0` und `wirkungslos=0`; die Zahlen aus 6.12.26 f ("Umfang nach dieser Fortschreibung") sind beim Bau zu bestätigen und bei Abweichung zu melden, nicht anzugleichen. **Berichtigt am 2026-09-04 durch 6.12.26 f Punkt 13 (Bau 4):** (1) entfällt — `Z-114` bleibt bei `rc`, Mutation `keine` (Grund 3, Schwester `Z-115`); die Mutation von `Z-130` ist auf das `Makefile` verlegt; Umfang 156 Messhüllen, neun Zeilen mit `keine`. | `scripts/dod-gate-selbsttest.sh`, `scripts/dod-gate-mutationen.txt`, `.claude/hooks/dod-gate.sh`; Spezifikation in `docs/adr/0002-architekturentscheid-ziel-stack.md` (6.12.19, 6.12.26 f) | DevOps Engineer; Verifikation Static und Dynamic Software Tester auf einem anderen Modell als die Umsetzung (3.4) |
| **Fünfzehnte Fortschreibung 2026-09-03 (6.12.26 f):** **achte Prüfrunde** nach Bau 4 mit Zwischenkontrolle. Sie belegt den Stand, dieser ADR belegt ihn nicht. Tritt die Fehlerklasse "eine Zusicherung besteht, ohne ihre Behauptung zu belegen" dort erneut auf, wird nach 3.4 abgebrochen, die Übergabedatei geschrieben und die Sache vorgelegt (Entscheid des Koordinators). **O-25**, die Entscheidpunkte E-A bis E-K und die Abnahme des Gates bleiben offen (Abschnitt 10) | Prüfbericht, Ergebnis in die Übergabedatei | Static und Dynamic Software Tester auf einem anderen Modell als die Umsetzung (3.4) |
| **Sechzehnte Fortschreibung 2026-09-04 (6.12.26 g, Runde 8):** Die achte Prüfrunde ist gelaufen (Fremdbeleg, beide Prüfer auf einem anderen Modell als die Umsetzung, je in einer Wegwerfkopie, Bestand prüfsummengleich). **Statisch bestanden:** Normalmodus Rückgabewert 0 mit 154 von 154, Deckung 154/154/0/0, Kanalabgleich 0 Abweichungen, keine Doppelmeldung; Mutationsmodus Rückgabewert 0 mit 145 geprüft, 145 erkannt, 0 nicht erkannt, 9 ohne Mutation, 0 wirkungslos; die Zahlen aus Punkt 13 sind damit bestätigt. **Dynamisch nicht bestanden:** von sechzehn **eigenen** Mutationen des Prüfers, keine davon in der Mutationsdatei, lässt ein Teil keine Kennung fallen — `DT8-01` (`Z-040` misst eine Teilzeichenkette statt der Zeile, und der Durchlass frühestens beim vierten Ereignis ist ungedeckt; achter Auftritt der Fehlerklasse), `DT8-02` (der Zählschlüssel `KETTE schlusszeile-widerspruch` aus 6.12.4 ist von keiner Zusicherung gedeckt) und `DT8-03` (das schliessende `::` der Markengrammatik aus 6.12.7 ist ungedeckt), alle drei blockierend. **Die Arbeitseinheit ist nach 3.4 abgebrochen**, kein Befund der achten Runde wird in ihr behoben, der Stand ist mit Übergabedatei committet und vorgelegt; vorgelegt ist **O-26** (Prädikatbindung, Schlüsseldeckung, Grammatikdeckung, die sechs Befunde als Zeilen, Abnahmekriterium). **Nachführungsposten der nächsten Einheit** — nicht in dieser: `S8-01` (Rückzugserkennung liest die Zeile statt der Spalte), `S8-03` (der Block `GATE sha256sum` steht zweimal, die alte Fassung ist unerreichbar und zu entfernen), `S8-05` (`Z-080` misst nicht isoliert in der Marke), `S8-06` (Kanalabgleich vergleicht Zeichenketten statt Mengen — strenger als verlangt), `S8-07` (fünf Nicht-ASCII-Stellen in den Skripten) sowie `DT8-04` (Rückfallpfad über `CLAUDE_PROJECT_DIR` physisch aufgelöst), `DT8-05` (Wert der inneren Zeitgrenze ungemessen) und `DT8-06` (Ausgabeform nur für zwei von fünf Durchlasspfaden gemessen). `S8-02` ist am aktuellen Stand nicht reproduzierbar und gegenstandslos; `S8-04` (Mutationsdatei noch nicht unter Versionskontrolle) erledigt sich mit dem Commit dieser Einheit. **O-25**, das neue **O-26**, die Entscheidpunkte E-A bis E-K und die Abnahme des Gates bleiben offen (Abschnitt 10) | Übergabedatei der Einheit (`docs/uebergaben/2026-09-04_r3-q-001-o-25-kanal-und-mutation.md`); `scripts/dod-gate-selbsttest.sh`, `scripts/dod-gate-mutationen.txt`, `.claude/hooks/dod-gate.sh`; Spezifikation in `docs/adr/0002-architekturentscheid-ziel-stack.md` (6.12.19, 6.12.26 g) | Entscheid zu O-26 beim Auftraggeber; Vorbereitung Software Architect, Umsetzung DevOps Engineer, Verifikation Static und Dynamic Software Tester auf einem anderen Modell als die Umsetzung (3.4); Changelog und Nachweisverzeichnis beim Protocol Master (4.2, 6.6) |
| **Siebzehnte Fortschreibung 2026-09-06 (6.12.27 b bis e, h — Entscheid des Auftraggebers zu O-26):** Im Selbsttest: (1) je Messhülle die **Meldung des Prädikats** und ein **Prädikatabgleich** gegen Spalte 4 der Tabelle 6.12.19, Rückgabewert ungleich 0 bei jeder Abweichung — die Bindung läuft über den **Namen** der Hülle oder über ein von ihr selbst auf einen geschlossenen Teilvorrat eingeschränktes Argument; frei angegeben werden darf das Prädikat allein dort, wo schon der Kanal frei angegeben werden darf (`beobachter`, `dauer`, `selbsttest`, `datei`), und auch dort nur aus dem Vorrat. (2) Neue **Zeilenhülle** je Kanal für das Prädikat `zeile-woertlich` (`grep -x`), heute für `Z-040` (`stderr`) und `Z-153` (`selbsttest`). (3) **Schlüsseldeckung** nach 6.12.27 c: Schlüssel aus der Spalte "Schlüssel des Kriteriums" der Tabelle 6.12.4 **dieser** ADR-Datei lesen, Platzhalter nach der dortigen Ersetzungsvorschrift auflösen, in den Backtick-Abschnitten der Spalte Zusicherung suchen — in **beide** Richtungen, die Gegenrichtung über die Stämme `KETTE `, `LISTE `, `GATE `, `D19 `. **Keine zweite Liste im Skript.** (4) **Grammatikdeckung** nach 6.12.27 d: Kürzel aus der Elementtabelle in 6.12.7 lesen, je Kürzel mindestens eine Zeile mit dem Etikett `Grammatik <KUERZEL>: ` am Anfang der Spalte Fall verlangen. (5) Fälle für die **29** neuen Kennungen `Z-156` bis `Z-184` und die berichtigten Messungen von `Z-040` (Zeile statt Teilzeichenkette) und `Z-080` (isoliert auf der Lage-C-Zeile zu D20, `S8-05`). (6) Die **Rückzugserkennung** liest die Spalte **Kanal**; zurückgezogen ist eine Zeile genau dann, wenn diese Spalte keinen Wert des Vorrats aus 6.12.26 a trägt (`S8-01`). (7) Kanal- **und** Prädikatabgleich vergleichen der **Reihenfolge** nach (`S8-06`). (8) **Keine Nicht-ASCII-Zeichen** mehr im Skript (`S8-07`) | `scripts/dod-gate-selbsttest.sh`; Spezifikation in `docs/adr/0002-architekturentscheid-ziel-stack.md` (6.12.19, 6.12.27) | DevOps Engineer; Zwischenkontrolle Static Software Tester, Verifikation Static und Dynamic Software Tester auf einem anderen Modell als die Umsetzung (3.4) |
| **Siebzehnte Fortschreibung 2026-09-06 (6.12.27 d, h):** Im Gate: (1) `S8-03` — die alte, unerreichbare Fassung des Blocks `GATE sha256sum` (Zeilen 478 bis 482) **entfernen**; verhaltensneutral, aber zwei Stellen mit derselben Aussage (6.2.2). (2) `S8-07` — die Nicht-ASCII-Stellen ersetzen. (3) **Bauposten aus der Grammatikdeckung:** Für acht der neun Elemente der Marke ist der erwartete Ausgang (Rückgabewert 2, Schlüssel `KETTE ausgabe-unlesbar`) aus dem Aufbau des Gates **abgeleitet** und mit einem Lauf zu **bestätigen**; allein `ABSCHLUSS` trägt einen Fremdbeleg (`DT8-03`). Weicht ein Ausgang ab, ist das ein **Befund** und die Elementtabelle in 6.12.7 fortzuschreiben — die Prüfzeile wird **nicht** an das Gate angepasst. Am Verhalten des Gates ändert diese Fortschreibung im Übrigen **nichts** | `.claude/hooks/dod-gate.sh` | DevOps Engineer; Verifikation Static und Dynamic Software Tester (3.4) |
| **Siebzehnte Fortschreibung 2026-09-06 (6.12.27 e, f):** **29** neue Einträge für `Z-156` bis `Z-184`, davon **28** mit `sed`-Ausdruck und einer mit `keine` (`Z-169`, Grund 3, Schwester `Z-168`); der Eintrag für `Z-040` wechselt den Gegenstand auf die **Eskalationsschwelle** (`-ge 4` auf `-ge 3`). Bestand danach: **183** Einträge, davon **173** mit `sed` und **zehn** mit `keine`. Die Mutationen der neun Grammatikzeilen greifen am `marken_muster` an und dürfen keine Zeile ausserhalb der genannten Stelle treffen (6.12.26 f, Punkt 6); die drei Mutationen zur Ausgabeform sind **pfadgenau** über den vorangehenden Meldungstext zu adressieren | `scripts/dod-gate-mutationen.txt` | DevOps Engineer; Verifikation Static und Dynamic Software Tester (3.4) |
| **Siebzehnte Fortschreibung 2026-09-06 (6.12.27 a, g):** In der Lieferreihenfolge ist der Stand von R3-Q-001 nachzuführen — O-26 am 2026-09-06 entschieden, Umsetzung und **neunte** Prüfrunde (Fremdmutationsrunde) ausstehend; in der Tabelle "Aktive Gates" die Zahlen des Selbsttests (Zusicherungen, Prädikatabgleich, Schlüssel- und Grammatikdeckung) **erst nach** dem Bau und der Bestätigung durch die statische Prüfung, nicht vorab | `CLAUDE.md` | Protocol Master (4.2) |
| **Siebzehnte Fortschreibung 2026-09-06 (6.12.27 g):** Stand von R3-Q-001 nachführen; **neuer Sammelposten** unter R3-Q-001 für die **nachrangigen** Fremdmutationsbefunde ausserhalb der vier Kategorien Schlüssel, Grammatik, Schwellen und Ereignisfolge, Ausgabeform — sie sind nach dem Abnahmekriterium **kein** Abbruchgrund und werden dort geführt statt die Abnahme zu verlängern | `docs/05_Product_Backlog.md` | Product Owner mit dem Requirements Engineer |
| **Siebzehnte Fortschreibung 2026-09-06 (6.12.27 g):** Zu prüfen, ob das Abnahmekriterium aus 6.12.27 g den Abschnitt "Durchsetzung" oder das Abnahmekriterium `R3-Q-001_gate_blockiert` berührt. Diese Rolle hat `docs/06_Definition_of_Ready_und_Done.md` in dieser Arbeitseinheit **nicht gelesen** und stellt deshalb **nichts** darüber fest — die Feststellung ist zu treffen, nicht zu vermuten | `docs/06_Definition_of_Ready_und_Done.md` | Requirements Engineer mit Product Owner, Bestätigung Auftraggeber |
| **Siebzehnte Fortschreibung 2026-09-06 (6.12.27 g):** Vorgeschlagen als **methodischer Entscheid**: "Ein Abnahmekriterium, das jede neue Lücke zum Abbruchgrund macht, beendet keine Abnahme." Dazu der Weg, den O-26 dafür geht — vier benannte, abzählbare Kategorien für den blockierenden Befund, alles darüber hinaus in den Backlog. Diese Rolle **schlägt vor** und trägt nichts selbst ein | `UEBERGABE.md` und `methodik/entscheide.md` im Methodik-Repository | Protocol Master mit dem Auftraggeber |
| **Siebzehnte Fortschreibung 2026-09-06 (6.12.27 g):** **Neunte Prüfrunde**, und zwar als **Fremdmutationsrunde** nach dem Abnahmekriterium: mindestens drei Fremdmutationen je Kategorie (Schlüssel 6.12.4, Grammatik 6.12.7, Schwellen und Ereignisfolge 6.12.9, Ausgabeform 6.12.15), vom Dynamic Software Tester **ohne Kenntnis** von `scripts/dod-gate-mutationen.txt` gewählt und die Datei erst danach gelesen; dazu beide Modi des Selbsttests, die Bestätigung der Zahlen aus 6.12.27 f und die Klärung der Zähldifferenz "elf/zehn" aus Runde 8. Sie belegt den Stand, dieser ADR belegt ihn nicht. **O-25**, die Entscheidpunkte E-A bis E-K und die Abnahme des Gates bleiben offen (Abschnitt 10) | Prüfbericht, Ergebnis in die Übergabedatei | Static und Dynamic Software Tester auf einem anderen Modell als die Umsetzung (3.4) |
| **Siebzehnte Fortschreibung, Nachtrag i, 2026-09-06 (6.12.27 i, Runde 9):** Im Selbsttest: (1) **Aussagendeckung** — die Kürzel aus den beiden neuen Tabellen "Aussagen dieser Festlegung" in **6.12.9** (`E01` bis `E22`) und **6.12.15** (`A01` bis `A07`) lesen und je Kürzel mindestens eine Zeile der Tabelle 6.12.19 verlangen, deren Fallspalte mit `Aussage <KUERZEL>: ` beginnt; Ausgabezeile `Aussagendeckung: n Kuerzel, m ohne Zeile`, Rückgabewert ungleich 0 bei jedem Kürzel ohne Zeile. (2) Das zehnte Grammatikkürzel `ENDE` in die Grammatikdeckung (`DT9-01`). (3) **Typisierte Messhüllen auch für `beobachter`** — die Hülle startet und wertet den Beobachter selbst aus — **und für `datei`**; `pruefe_wahr` bleibt allein für `dauer` und `selbsttest` zulässig (`S9-01`, `S9-02`, `SST-B5-01`). `Z-106` und `Z-109` bleiben im Wortlaut, die Behebung liegt in der Hülle; lässt sich ein Beobachter für einen der beiden Fälle nicht bauen, ist das ein Befund und eine Fortschreibung. (4) Die **Ersetzungsvorschrift** der Schlüsseldeckung verankern: Deckung nur bei vollständiger Übereinstimmung des Backtick-Abschnitts, Gegenrichtung weiterhin über den Anfang (`S9-04`); die Deckung 14/0/0 danach erneut erheben. (5) Fälle für die neun neuen Kennungen `Z-185` bis `Z-193`. (6) Bauvorschrift aus `SST-B5-08`: Der **erste** Lauf nach einer neuen Spalte läuft gegen den **unveränderten** Bau, und seine Abweichungszahl wird gemeldet, bevor eine Hülle angepasst wird | `scripts/dod-gate-selbsttest.sh`; Spezifikation in `docs/adr/0002-architekturentscheid-ziel-stack.md` (6.12.7, 6.12.9, 6.12.15, 6.12.19, 6.12.27 i) | DevOps Engineer; Zwischenkontrolle Static Software Tester, Verifikation Static und Dynamic Software Tester auf einem anderen Modell als die Umsetzung (3.4) |
| **Siebzehnte Fortschreibung, Nachtrag i, 2026-09-06 (6.12.27 i):** Am Gate ist aus diesem Nachtrag **nichts** zu ändern. `DT9-01` bis `DT9-03` sind **Mutationen**, keine Befunde am Verhalten; das Gate hat sich in allen Negativbefunden der neunten Runde richtig verhalten. Diese Zeile steht hier, damit die Abwesenheit einer Änderung festgehalten ist und nicht als Vergessen erscheint | `.claude/hooks/dod-gate.sh` | nichts auszuführen; Feststellung durch den Static Software Tester (3.4) |
| **Siebzehnte Fortschreibung, Nachtrag i, 2026-09-06 (6.12.27 i):** **Neun** neue Einträge für `Z-185` bis `Z-193`, alle mit `sed`-Ausdruck, davon drei als **eingefügte** Zeile (`Z-188`, `Z-192`, `Z-193`) — Einfügungen sind nach 6.12.26 b zulässig, sofern sich die Kopie vom Original unterscheidet und genau die eigene Kennung fällt. Bestand danach: **192** Einträge, davon **182** mit `sed` und unverändert **zehn** mit `keine` | `scripts/dod-gate-mutationen.txt` | DevOps Engineer; Verifikation Static und Dynamic Software Tester (3.4) |
| **Siebzehnte Fortschreibung, Nachtrag i, 2026-09-06 (6.12.27 g, i):** **Zehnte Prüfrunde** als neue **Fremdmutationsrunde**: mindestens drei Fremdmutationen je Kategorie, **blind** gewählt von einer **neuen Instanz** des Dynamic Software Testers (die Wahl wird vor dem ersten Blick in `scripts/dod-gate-mutationen.txt` schriftlich festgehalten), dazu eine statische Nachprüfung. Belegt ist aus Runde 9, dass die Blindheit trägt: alle 19 blind gewählten Fremdmutationen erkannt, alle drei unerkannten aus der Nachwahl. **Teil 1** des Abnahmekriteriums ist erfüllt, **Teil 2 nicht**; die Zählung nach 3.4 steht bei **eins**. **O-25**, die Entscheidpunkte E-A bis E-K und die Abnahme des Gates bleiben offen (Abschnitt 10) | Prüfbericht, Ergebnis in die Übergabedatei | Static und Dynamic Software Tester auf einem anderen Modell als die Umsetzung (3.4) |
| **Siebzehnte Fortschreibung, Nachtrag j, 2026-09-06 (6.12.27 j, Runde 10):** Im Selbsttest: (1) **Gegenstandsdeckung Schlüssel** nach 6.12.27 j, Punkt 3 — die Literale aus `.claude/hooks/dod-gate.sh` erheben (erste Argumente von `blockieren_mit_zaehlung` und Zuweisungen an `*_schluessel`, reine Variablen übergehen, Variablenanteil als **ein oder mehr** Wörter, Vollmatch gegen die Backtick-Abschnitte der Spalte Zusicherung), Ausgabezeile `Gegenstandsdeckung Schluessel: n Literale, m ohne Zeile`, Rückgabewert ungleich 0 bei jedem Literal ohne Zeile. (2) **Ausgabeform als Invariante**: je Gate-Aufruf Rückgabewert, Standard- und Fehlerausgabe protokollieren und am Ende über **alle** Aufrufe messen (`Z-194` bis `Z-197`). (3) Das elfte Grammatikkürzel `ANFANG` in die Grammatikdeckung und die Erzeugerseiten-Zeile `Z-199`, deren Muster **aus dem Gate gelesen** und nicht im Selbsttest wiederholt wird. (4) Aussagendeckung mit **Gegenrichtung** und der Wache "genau ein Etikett je Zeile" (S10-05). (5) Fälle für `Z-194` bis `Z-208`; berichtigte Messung für `Z-109` (Wegwerfverzeichnis des Gates, S10-01). (6) **Zeitmarke** je Beobachtung im Beobachterprotokoll (S10-02). (7) `pruefe_wahr` mit freier Angabe nur noch an **zwei** Stellen (S10-04) | `scripts/dod-gate-selbsttest.sh`; Spezifikation in `docs/adr/0002-architekturentscheid-ziel-stack.md` (6.12.7, 6.12.15, 6.12.19, 6.12.27 j) | DevOps Engineer; Zwischenkontrolle Static Software Tester, Verifikation Static und Dynamic Software Tester auf einem anderen Modell als die Umsetzung (3.4) |
| **Siebzehnte Fortschreibung, Nachtrag j, 2026-09-06 (6.12.27 j):** **Fünfzehn** neue Einträge für `Z-194` bis `Z-208`, alle mit `sed`-Ausdruck; die Mutation von `Z-190` wird auf die engere, ausführbare Form gebracht (S10-07). Zwei Mutationen zielen auf das `Makefile` (`M15`, `Z-199`) beziehungsweise auf das `marken_muster` des Gates (`M08`, `Z-198`). Bestand danach: **207** Einträge, davon **197** mit `sed` und unverändert **zehn** mit `keine`. Am **`Makefile`** ist aus diesem Nachtrag **nichts** zu ändern — `M08` und `M15` sind Mutationen, keine Befunde am Verhalten | `scripts/dod-gate-mutationen.txt` | DevOps Engineer; Verifikation Static und Dynamic Software Tester (3.4) |
| **Siebzehnte Fortschreibung, Nachtrag j, 2026-09-06 (6.12.27 j, Punkt 9, Teilschritt 6a):** Am Gate ist **genau eine** Stelle zu ändern: Der Block `GATE jq` (Zeile 110) erhält die **einheitliche Meldungsform** aller übrigen Blockpfade — "dod-gate: BLOCKIERT. Schluessel: GATE jq. 'jq' ist nicht installiert; die Eingabe auf der Standardeingabe kann nicht gelesen werden." **Kein Verhalten ändert sich**: Rückgabewert 2, **keine** Zählung (Aussage `E12` bleibt wahr), Beschaffungsweg und nächster Schritt bleiben. Anlass ist die neue Invariante `Z-196` (`A05`), die den einzigen abweichenden Pfad von 117 erfassten Gate-Aufrufen gezeigt hat; `Z-021` und `Z-022` bleiben unverändert wahr | `.claude/hooks/dod-gate.sh` | DevOps Engineer; Verifikation Static und Dynamic Software Tester (3.4) |
| **Siebzehnte Fortschreibung, Nachtrag j, 2026-09-06 (6.12.27 j, Punkt 7):** Die Zahlen der Tabelle 6.12.19 sind erneut zu erheben und zu bestätigen: **208** Zeilen, **207** Zusicherungen, **209** Messhüllen (`gleich` 132, `enthaelt` 35, `fehlt` 12, `leer` 9, `existiert` 7, `einzelfeld` 6, `ausserhalb` 4, `kleiner` 2, `zeile-woertlich` 2), **11** Grammatikkürzel, **30** Aussagenkürzel, **14** Schlüssel aus 6.12.4, **24** Literale aus dem Gate. Weichen sie ab, ist das ein Befund und zu melden, nicht anzugleichen | `docs/adr/0002-architekturentscheid-ziel-stack.md` (6.12.19, 6.12.27 f, i, j) | Bau meldet, Static Software Tester bestätigt (3.4) |
| **Siebzehnte Fortschreibung, Nachtrag j, 2026-09-06 (6.12.27 g, j):** **Elfte Prüfrunde** als **dritter** Versuch an Teil 2 des Abnahmekriteriums, wiederum als Fremdmutationsrunde mit **blinder** Wahl durch eine neue Instanz des Dynamic Software Testers. **Vorab festgelegt:** Fällt sie, wird nach 3.4 **abgebrochen**, die Übergabedatei geschrieben und die Sache dem Auftraggeber vorgelegt. Belegt ist aus den Runden 9 und 10, dass die Blindheit trägt — die unerkannten Mutationen stammen überwiegend aus der Nachwahl. **O-25**, die Entscheidpunkte E-A bis E-K und die Abnahme des Gates bleiben offen (Abschnitt 10) | Prüfbericht, Ergebnis in die Übergabedatei | Static und Dynamic Software Tester auf einem anderen Modell als die Umsetzung (3.4) |
| **Siebzehnte Fortschreibung, Nachtrag k, 2026-09-06 (6.12.27 k, Runde 11):** Die Arbeitseinheit ist nach **3.4 abgebrochen** — dritter Fehlschlag an Teil 2 des Abnahmekriteriums, vorab in 6.12.27 j Punkt 8 so festgelegt. **In dieser Einheit wird kein Befund der elften Runde behoben**, auch `DT11-11` und `S11-04` bis `S11-06` nicht; am Selbsttest, am Gate, am `Makefile` und an der Tabelle 6.12.19 ändert sich **nichts**. Offen und als **Backlog-Posten unter R3-Q-001** zu führen: `DT11-01` bis `DT11-05` (weitere Verstossformen der Grammatik), `DT11-06` (`E21` nur an einer von drei Aufrufstellen gemessen), `DT11-07` bis `DT11-10` (`A08`, `A04`, `A05` an drei nie beschrittenen Blockpfaden), **`DT11-11`** (dieselben drei Pfade und der Sperrpfad blockieren, ohne `Schluessel: ` zu nennen — Befund am **Original**, dieselbe Klasse wie `GATE jq` in j Punkt 9), `S11-02` (die Mutationsspalte von `Z-190` nennt die Zweigbeschränkung nicht), `S11-03` (gleicher Falltext bei `Z-194` bis `Z-197`), `S11-04` bis `S11-06` (Deckungen bestehen leer, wenn ihr Lesen misslingt — Mindestzahl und Gegenrichtung fehlen), `S11-09` (Variablenanteil als Zeichen statt als Wörter) und `S11-10` (die Auswahl der Übersichtszeilen ist enger als der Zeilenwortlaut). **Der Entscheid über das weitere Vorgehen liegt beim Auftraggeber: O-27**, Abschnitt 8. **O-25**, **O-27**, die Entscheidpunkte E-A bis E-K und die Abnahme des Gates bleiben offen (Abschnitt 10) | Übergabedatei der Einheit; `docs/05_Product_Backlog.md` (Posten unter R3-Q-001); Vorlage in `docs/adr/0002-architekturentscheid-ziel-stack.md` (6.12.27 k, Abschnitt 8) | Entscheid zu O-27 beim Auftraggeber; Backlog-Posten durch den Product Owner; Changelog und Nachweisverzeichnis beim Protocol Master (4.2, 6.6) |
| **Siebzehnte Fortschreibung, Nachtrag k, Entscheid O-27, 2026-09-07:** Der Auftraggeber hat die Wahl zwischen den Wegen delegiert; gewählt sind **beide zusammen** (6.12.27 k, Punkt 5). Nachzuführen: (1) die **Ausformung als 6.12.28** — Zeilen der Tabelle 6.12.19 für (a1) und (a2) samt Mutationen, der neue **Wortlaut von Teil 2** in 6.12.27 g, die geschlossene Liste der zulässigen Ausnahmen zu (a1) und die geschlossene Liste der Umformungen zu (a2) — **zu Beginn der nächsten Einheit**; (2) die **Umsetzung** in `scripts/dod-gate-selbsttest.sh`, `scripts/dod-gate-mutationen.txt` und `.claude/hooks/dod-gate.sh` (dort allein die Meldungsform nach `DT11-11`, ohne Verhaltenswechsel); (3) **Runde 12** als **letzte** Fremdmutationsrunde, blind gewählt, mindestens sechs je Kategorie; besteht sie, folgt die **Abnahmevorlage** für das Gate. In dieser Einheit ändert sich am Selbsttest, am Gate, an der Tabelle und am `Makefile` **nichts** | `docs/adr/0002-architekturentscheid-ziel-stack.md` (6.12.28, neu), danach `scripts/dod-gate-selbsttest.sh`, `scripts/dod-gate-mutationen.txt`, `.claude/hooks/dod-gate.sh` | Ausformung Software Architect; Umsetzung DevOps Engineer; Runde 12 Static und Dynamic Software Tester auf einem anderen Modell als die Umsetzung (3.4) |
| **Siebzehnte Fortschreibung, Nachtrag k, Entscheid O-27, 2026-09-07:** Das **Abnahmekriterium** ist mit Teil 2 neu gefasst (falsches Grün als alleiniger blockierender Befund, Formabweichungen nachrangig). Zu prüfen und nachzuführen, wo `docs/06_Definition_of_Ready_und_Done.md` das Abnahmekriterium von R3-Q-001 berührt; diese Rolle hat die Datei nicht gelesen und stellt dazu **nichts** fest | `docs/06_Definition_of_Ready_und_Done.md` | Requirements Engineer mit Product Owner, Bestätigung Auftraggeber |
| **Siebzehnte Fortschreibung, Nachtrag k, Entscheid O-27, 2026-09-07:** **Abschnitt 10 nach dem Merge des Pull Requests nachführen.** Die förmliche Freigabe der Entscheidpunkte **E-A bis E-K** wird mit dem Merge erteilt — der Formweg steht in Abschnitt 10 und ist unverändert. Die **Abnahme des Gates** bleibt davon **getrennt** und folgt erst nach Runde 12. Solange der Merge nicht erfolgt ist, bleibt Abschnitt 10, wie er steht; diese Einheit ändert ihn **nicht** | `docs/adr/0002-architekturentscheid-ziel-stack.md`, Abschnitt 10 | Software Architect nach dem Merge; Protokollvermerk zur Form durch den Protocol Master (4.2) |
| **Achtzehnte Fortschreibung, 2026-09-07 (6.12.28 b, c, d, f):** Im Selbsttest: (1) **Pfaddeckung** — Sollmenge aus dem Gate erheben (14 `exit`-Anweisungen und 26 Aufrufstellen von `blockieren_mit_zaehlung`, Erhebungsmuster in b) Punkt 2), Ist als **Ausführungsspur** gegen eine bytegleiche Wegwerfkopie (`bash -x`, `BASH_XTRACEFD` auf einen vom Aufrufer geöffneten Deskriptor, `PS4` über `BASH_ENV`), Ausgabezeile `Pfaddeckung: n Ausgangsstellen, m nicht beschritten, a mit Ausnahme`, fail-closed nach b) Punkt 4. (2) **Zwölf neue Fälle** für die heute unbeschrittenen Ausgangsstellen, darunter eine `flock`-Attrappe für den Sperrpfad und drei `mktemp`-Attrappen. (3) **Grammatikschwächungen** — Muster aus dem Gate lesen, nach der Zerlegung in c) Punkt 2 und der Umformungsliste in c) Punkt 3 schwächen, Probemarken mechanisch bilden, Wirksamkeit am Muster, fallende Zusicherung **am Gate** messen (Abbruch bei der ersten), Ausgabezeile `Grammatikschwaechungen: n Schwaechungen, w wirksam, m ohne fallende Zusicherung`; Schwächungen an Element 1 oder 2 zusätzlich auf den `awk`-Vorfilter anwenden. (4) **Alternativendeckung** gegen die Elementtabelle 6.12.7 (`Z-253`, `Z-254`). (5) **Aufrufstellendeckung zu `E21`** (`Z-258`). (6) **Gegenrichtung der Grammatikdeckung** (`f` fremde Etiketten) und die generische **Mindestzahlwache** über alle Deckungszeilen (`Z-260`). (7) Fälle für `Z-209` bis `Z-261`. **Aufrufe gegen geschwächte Kopien gehen weder in die Spur noch in die Invarianten `Z-194` bis `Z-197` ein** | `scripts/dod-gate-selbsttest.sh`; Spezifikation in `docs/adr/0002-architekturentscheid-ziel-stack.md` (6.12.4, 6.12.7, 6.12.9, 6.12.19, 6.12.28) | DevOps Engineer; Zwischenkontrolle Static Software Tester nach Phase 1 und nach Phase 3, Verifikation Static und Dynamic Software Tester auf einem anderen Modell als die Umsetzung (3.4) |
| **Achtzehnte Fortschreibung, 2026-09-07 (6.12.28 b) Punkt 5):** **Neue versionierte Datei** für die Ausnahmen der Pfaddeckung: je Zeile Zeilennummer, Wortlaut der Ausgangsstelle, Grundnummer 1 bis 3 aus der geschlossenen Liste und Begründung, durch Tabulator getrennt. Die Datei wird **angelegt und bleibt ohne Ausnahmezeile**; **fehlt** sie, ist der Lauf ein Fehlschlag. Jede Ausnahme braucht zusätzlich eine Fortschreibung von 6.12.28 b | `.claude/hooks/dod-gate-pfadausnahmen.txt` (neu) | DevOps Engineer; Verifikation Static und Dynamic Software Tester (3.4) |
| **Achtzehnte Fortschreibung, 2026-09-07 (6.12.28 h):** **53** neue Einträge für `Z-209` bis `Z-261`, davon **51** mit `sed`-Ausdruck und **zwei** mit `keine` nach Grund 1 (`Z-231`, `Z-261`). Die Mutationen der acht Aufrufstellen-Zeilen und der beiden neuen `E21`-Zeilen sind **pfadgenau** über den vorangehenden Meldungstext zu adressieren, sonst sind die Zeilen untereinander nicht trennscharf. Bestand danach: **260** Einträge, davon **248** mit `sed` und **12** mit `keine` | `scripts/dod-gate-mutationen.txt` | DevOps Engineer; Verifikation Static und Dynamic Software Tester (3.4) |
| **Achtzehnte Fortschreibung, 2026-09-07 (6.12.28 e):** Am Gate ist **genau eine** Berichtigung vorzunehmen: Die vier Blockpfade "kein gültiges JSON" (Zeile 119), "unbekanntes Ereignis" (127), "kein bestimmbarer Arbeitsbaum" (429) und "Sperre belegt" (582) erhalten die **einheitliche Meldungsform** `dod-gate: BLOCKIERT. Schluessel: <Schluessel>. <Text>` mit den vier neuen Schlüsseln aus 6.12.4; Wortlaute in 6.12.28 e) Punkt 3. **Kein Verhalten ändert sich**: Rückgabewert 2, Reihenfolge und **Nichtzählung** bleiben. Die Berichtigung gehört in **Phase 1**, weil `Z-196` sonst am unveränderten Gate an genau diesen Pfaden fällt, sobald sie beschritten werden | `.claude/hooks/dod-gate.sh` | DevOps Engineer; Verifikation Static und Dynamic Software Tester (3.4) |
| **Achtzehnte Fortschreibung, 2026-09-07 (6.12.28 h):** Die Zahlen der Tabelle 6.12.19 sind erneut zu erheben und zu bestätigen: **261** Zeilen, **260** Zusicherungen, **262** Messhüllen (`gleich` 172, `enthaelt` 41, `fehlt` 18, `leer` 9, `existiert` 8, `einzelfeld` 6, `ausserhalb` 4, `kleiner` 2, `zeile-woertlich` 2), **12** Grammatikkürzel, **31** Aussagenkürzel, **18** Schlüssel aus 6.12.4, **24** Literale aus dem Gate, **40** Ausgangsstellen, **35** Schwächungen vor der Entdopplung, **3** Aufrufstellen zu `E21`. Weichen sie ab, ist das ein Befund und zu melden, nicht anzugleichen | `docs/adr/0002-architekturentscheid-ziel-stack.md` (6.12.19, 6.12.28 h) | Bau meldet, Static Software Tester bestätigt (3.4) |
| **Achtzehnte Fortschreibung, 2026-09-07 (6.12.28):** Statustabelle, Gate-Tabelle und der Abschnitt zum DoD-Gate sind nachzuführen: förmliche Freigabe der Entscheidpunkte E-A bis E-K am 2026-09-07 erteilt, O-27 ausgeformt als 6.12.28, neue Deckungen und neuer Teil 2 des Abnahmekriteriums, Runde 12 als letzte Fremdmutationsrunde, Abnahme des Gates weiterhin ausstehend | `CLAUDE.md` | Protocol Master (4.2) |
| **Achtzehnte Fortschreibung, 2026-09-07 (6.12.28 c, i):** Zwei **Restlücken** sind als Posten unter R3-Q-001 zu führen: (1) Zeichen **im Inneren** eines Wortliterals werden nicht einzeln geschwächt (c) Punkt 3); (2) eine Alternative mit einem **bestimmten fremden Literal** ist nur über die Alternativendeckung als Klasse erfasst. Dazu die nachrangigen Befunde aus Runde 12, sobald sie vorliegen | `docs/05_Product_Backlog.md` | Product Owner |
| **Achtzehnte Fortschreibung, 2026-09-07 (6.12.28 g):** Zu prüfen und nachzuführen, wo das Abnahmekriterium von R3-Q-001 den **neuen Teil 2** berührt (falsches Grün als alleiniger blockierender Befund, Formabweichungen nachrangig, Runde 12 als letzte Runde). Diese Rolle hat die Datei **nicht gelesen** und stellt dazu nichts fest | `docs/06_Definition_of_Ready_und_Done.md` | Requirements Engineer mit Product Owner, Bestätigung Auftraggeber |
| **Achtzehnte Fortschreibung, 2026-09-07 (6.12.28):** Im Methodik-Repository sind der Stand der Einheit und der Entscheid O-27 nachzuführen — O-27 entschieden am 2026-09-07 und ausgeformt als 6.12.28, Umsetzung und Runde 12 offen. Verweise ausschliesslich über die 40-stellige Commit-Prüfsumme (6.6) | `UEBERGABE.md`, `methodik/entscheide.md` (Repository `r3coscrum`) | Protocol Master (4.2, 6.6) |
| **Achtzehnte Fortschreibung, 2026-09-07 (6.12.28 g):** **Runde 12** als **letzte** Fremdmutationsrunde: statisch mit eigenständiger Nachzählung aller Zahlen, aller `sed`-Ausdrücke und aller Deckungen; dynamisch **blind**, mindestens **sechs** Fremdmutationen je Kategorie, schriftlich mit Zeitmarke festgehalten, **bevor** Mutationsdatei und Tabelle 6.12.19 gelesen werden, **ohne Nachwahl**. Massstab ist der neue Teil 2: blockierend ist allein ein **falsches Grün am Gate**. Ein falsches Grün wird behoben, statisch nachgeprüft und mit einer **gezielten Wiederholung** belegt — **keine Runde 13** | Prüfbericht, Ergebnis in die Übergabedatei | Static und Dynamic Software Tester auf einem anderen Modell als die Umsetzung (3.4) |
| **Achtzehnte Fortschreibung, 2026-09-07 (6.12.28 i):** **Nach** bestandener Runde 12 die **Abnahmevorlage** des Gates in Abschnitt 10 (Vorgelegt am, Beleg, Restlücke). Sie wird in dieser Einheit **nicht** geschrieben; die förmliche Freigabe der Entscheidpunkte E-A bis E-K ist davon getrennt und am 2026-09-07 erteilt | `docs/adr/0002-architekturentscheid-ziel-stack.md`, Abschnitt 10 | Software Architect nach Runde 12; die Abnahme selbst erteilt der Auftraggeber |
| **Achtzehnte Fortschreibung, Nachtrag j, 2026-09-07 (6.12.28 j, Runde 12):** Aus der zwölften Runde ist **ein** blockierender Befund zu beheben — `DT12-M14`, falsches Grün an der Grammatik der **D19-Zeile** (6.12.8): Im Selbsttest entsteht **ein** neuer Fall (D19-Zeile mit einem Wort ausserhalb von `OHNE_BEFUND`, `VERLETZT`, `B` und `C`, sonst grüne Kette mit Schlusszeile Form 1) mit den **zwei** Zeilen `Z-262` (Rückgabewert 2) und `Z-263` (Schlüssel `KETTE ausgabe-unlesbar`); in der Mutationsdatei **zwei** neue Einträge mit demselben `sed`-Ausdruck (die Alternativen der D19-Grammatik an **beiden** Stellen durch `[A-Z_][A-Z_]*` ersetzt). Dazu die Baubefunde `S12-01`, `S12-02` (Block der Deckungszeilen einmal erzeugen, daraus ausgeben und prüfen; `Z-258` registriert seine Zahlen im Block) und die nachrangigen `SST-P3-01` bis `SST-P3-04`, `S12-04`, `S12-05`. **Am Gate ist nichts zu ändern.** Bestand danach: **263** Zeilen, **262** Zusicherungen, **264** Messhüllen, **262** Einträge (250 `sed`, 12 `keine`), Prädikat `gleich` **174** | `scripts/dod-gate-selbsttest.sh`, `scripts/dod-gate-mutationen.txt`; Spezifikation in `docs/adr/0002-architekturentscheid-ziel-stack.md` (6.12.28 j) | DevOps Engineer; statische Nachprüfung und **gezielte Wiederholung** von `DT12-M14` durch Static und Dynamic Software Tester auf einem anderen Modell als die Umsetzung (3.4) |
| **Achtzehnte Fortschreibung, Nachtrag j, 2026-09-07 (6.12.28 j, Punkt 5):** **Drei Restlücken** als Posten unter R3-Q-001 führen: (1) die Grammatik der **D19-Zeile** ist nicht am Gegenstand gedeckt — geschlossen ist die eine belegte Verstossform, ein Schwächungslauf über das D19-Muster ist **nicht** Gegenstand dieser Einheit (g: keine Runde 13); (2) Zeichen im Inneren eines Wortliterals; (3) eine Alternative mit einem bestimmten fremden Literal, für die D19-Grammatik ohne Gegenstück. Dazu die nachrangigen Befunde der Runde 12 | `docs/05_Product_Backlog.md` | Product Owner |
| Backlog-Eintrag für TheHive/Cortex (O-4) — **entfallen am 2026-08-21**, O-4 gestrichen (5.17 neu); bleibt: Formulierung der Abnahme von R3-C-001 gegenüber 5.6 (O-1) | `docs/05_Product_Backlog.md` | Product Owner |
| Zeile für diesen ADR in der Artefaktliste des Erzeugers; Neuerzeugung des Nachweisverzeichnisses; Changelog | `scripts/nachweise-erzeugen.sh`, `docs/NACHWEISE.md`, `CHANGELOG.md` | Protocol Master (4.2, 6.6) |
| Statustabelle und Verweis auf den Ziel-Stack | `CLAUDE.md` | Protocol Master |
| Anlegen des Grundgerüsts nach Abschnitt 5 | `backend/`, `deploy/`, `Makefile` | Backend Engineer und DevOps Engineer, nächste Arbeitseinheit |
| **Neunzehnte Fortschreibung, 2026-09-21 (ADR 0002, Abschnitt 10, Abnahme erteilt):** Statustabelle (Schritt 5) und die Zeile des DoD-Gates in "Aktive Gates" nachführen — Abnahme erteilt am 2026-09-08 durch Merge des Pull Requests #15, Teil 2 des Abnahmekriteriums nicht erfüllt, getragen hat der in 6.12.28 g vorab festgelegte Weg; nicht umfasst: O-25, D20 (O-15), R3-Q-005, Freigabe des Grundgerüsts | `CLAUDE.md` | Koordinator, in dieser Einheit — die ältere Zeile dieser Tabelle, die die Statustabelle dem Protocol Master zuweist, ist damit überholt: ADR 0001, Abschnitt 4 weist `.claude/` und CLAUDE.md keiner Rolle zu |
| **Neunzehnte Fortschreibung, 2026-09-21 (ADR 0002, Abschnitt 10, Abnahme erteilt):** Stand-Vermerk zu R3-Q-001 nachführen | `docs/05_Product_Backlog.md` | Product Owner, in dieser Einheit |
| **Neunzehnte Fortschreibung, 2026-09-21 (ADR 0002, Abschnitt 10, Abnahme erteilt):** Zeile des DoD-Gates in der Artefaktliste nachführen — die Abnahme steht nicht mehr aus; Neuerzeugung des Nachweisverzeichnisses | `scripts/nachweise-erzeugen.sh`, `docs/NACHWEISE.md` | Koordinator, in dieser Einheit — Artefaktliste und Beschreibungstext des Erzeugers (Datenzeilen), keine Änderung an seiner Logik; das Nachweisverzeichnis wird daraus neu erzeugt |
| **Neunzehnte Fortschreibung, 2026-09-21 (ADR 0002, Abschnitt 10, Abnahme erteilt):** die Stellen, die "förmliche Freigabe und Abnahme stehen aus" sagen, nachführen | `docs/adr/0001-rollenmodell.md` | Protocol Master, in dieser Einheit |
| **Neunzehnte Fortschreibung, 2026-09-21 (ADR 0002, Abschnitt 10, Abnahme erteilt):** Die Kommentarzeilen "foermliche Freigabe ausstehend" sind überholt; **in dieser Einheit bewusst nicht angefasst** — eine Änderung am Gate oder an der Lagenliste, auch nur im Kommentar, ist eine Änderung am abgenommenen Prüfmittel und Sache des Software Architects als Fortschreibung | `.claude/hooks/dod-gate.sh` Zeile 6, `.claude/hooks/dod-gate-terminierte-lagen.txt` Zeile 3 | Software Architect, als Fortschreibung des abgenommenen Prüfmittels |
| **Neunzehnte Fortschreibung, 2026-09-21 (ADR 0002, Abschnitt 10, Abnahme erteilt):** Stellen "Freigabe steht aus" nachführen — bereits offen geführt aus der achtzehnten Fortschreibung, nicht Gegenstand dieser Einheit | `docs/06_Definition_of_Ready_und_Done.md` | Requirements Engineer mit Product Owner |
| **Neunzehnte Fortschreibung, 2026-09-21 (ADR 0002, Abschnitt 10, Abnahme erteilt):** Stand der Einheit und der Eintrag zu O-27/V17 um die erteilte Abnahme ergänzen; Verweise ausschliesslich über die 40-stellige Commit-Prüfsumme | `methodik/entscheide.md`, `UEBERGABE.md` (Repository `r3coscrum`) | Koordinator, in dieser Einheit |
| **Neunzehnte Fortschreibung, 2026-09-21 (ADR 0002, Abschnitt 10, Abnahme erteilt):** `CHANGELOG.md` besteht weiterhin nicht | `CHANGELOG.md` (nicht angelegt) | offen, Entscheid des Auftraggebers |
| **Neunzehnte Fortschreibung, 2026-09-21 (ADR 0002, 6.13, E4/R3-Q-010):** Summen der Etappe 0 (Zahl der gezählten Einträge, Stundensumme) und Stand-Zeile im Kopf nach der Aufnahme von R3-Q-010 | `docs/05_Product_Backlog.md` | Product Owner, in dieser Einheit |
| **Neunzehnte Fortschreibung, 2026-09-21 (ADR 0002, 6.13, E4/R3-Q-010):** Neuer offener Punkt O-28 (ST-11) in die Tabelle der offenen Punkte | ADR 0002, Abschnitt 8 (`docs/adr/0002-architekturentscheid-ziel-stack.md`) | Software Architect beziehungsweise Schritt 2 dieser Einheit |
| **Neunzehnte Fortschreibung, 2026-09-21 (ADR 0002, 6.13, E4/R3-Q-010):** Zeile für das neue Prüfmittel in der Gate-Tabelle beziehungsweise im Abschnitt Aktive Gates, nach dem Bau von E4.1 | `CLAUDE.md` | Koordinator (CLAUDE.md ist keiner Rolle zugewiesen) |
| **Neunzehnte Fortschreibung, 2026-09-21 (ADR 0002, 6.13, E4/R3-Q-010):** Hook-Regel um das Prüfmittel der beiden `PreToolUse`-Gates ergänzen (heute verlangt sie je Hook einen blockierenden und einen durchzulassenden Fall, nennt aber kein Prüfmittel), nach dem Bau von E4.1 | `.claude/rules/claude-konfiguration.md` | umsetzende Rolle (SecDevOps Engineer) |
| **Neunzehnte Fortschreibung, 2026-09-21 (ADR 0002, 6.13, E4/R3-Q-010):** Kopfkommentare der beiden Gates — behauptete Fallklassen und benannte Grenzen an den Stand angleichen, Nichtprüfung gemeinsamer Abhängigkeiten (P-10) als Grenze aufnehmen | `.claude/hooks/block-main-write.sh` und `.claude/hooks/block-prototype-import.sh` | umsetzende Rolle, in E4.3 beziehungsweise mit jeder Gate-Änderung |
| **Neunzehnte Fortschreibung, 2026-09-21 (ADR 0002, 6.13, E4/R3-Q-010):** Neues Artefakt (Prüfmittel der beiden `PreToolUse`-Gates) in die Artefaktliste des Nachweiserzeugers aufnehmen, nach dem Bau von E4.1 | `scripts/nachweise-erzeugen.sh` | DevOps Engineer |
| **Neunzehnte Fortschreibung, 2026-09-21 (ADR 0002, 6.13, E4/R3-Q-010):** Die beiden Ausnahmezeilen (ADR-Datei und Backlog) für das geplante Prüfmittel wieder entfernen, sobald die Datei besteht | `scripts/belege-ausnahmen.txt` | umsetzende Rolle, mit dem Abschluss von E4.1 |
| **Neunzehnte Fortschreibung, 2026-09-21 (ADR 0002, 6.13, E4/R3-Q-010):** Nachführung nur, falls E4 die dortigen Festlegungen berührt (Notation der Abnahmekriterien, Definition of Done) | `docs/06_Definition_of_Ready_und_Done.md` | Requirements Engineer |
| **Zwanzigste Fortschreibung, 2026-09-22 (ADR 0002, 6.13, Freigabe erteilt):** Offener Punkt 18 auf erledigt, Stand-Vermerk in R3-Q-010, Nachführungsvermerk | `docs/05_Product_Backlog.md` | Product Owner, in dieser Einheit |
| **Zwanzigste Fortschreibung, 2026-09-22 (ADR 0002, Abschnitt 10, E-E):** Starthook, Eintrag im Array `SessionStart` und Hook-Regel | `.claude/hooks/session-start-gitleaks.sh`, `.claude/settings.json`, `.claude/rules/claude-konfiguration.md` | SecDevOps Engineer, in dieser Einheit |
| **Zwanzigste Fortschreibung, 2026-09-22 (ADR 0002, Abschnitt 10, E-E):** Statustabelle (Weisung vom 2026-09-22) und Absatz zu den `SessionStart`-Hooks | `CLAUDE.md` | Koordinator, in dieser Einheit |
| **Zwanzigste Fortschreibung, 2026-09-22 (ADR 0002, Abschnitt 10, E-E):** Artefaktzeile für den Starthook und für die Übergabe dieser Einheit | `scripts/nachweise-erzeugen.sh` | Koordinator, in dieser Einheit |
| **Zwanzigste Fortschreibung, 2026-09-22 (Weisung zu Punkt C):** Lesart von R1 für Einträge mit benanntem Stakeholder, deren Abstimmung mit der Freigabe durch den Auftraggeber eintritt; offener Punkt 19 des Backlogs | `docs/06_Definition_of_Ready_und_Done.md` | Requirements Engineer, in dieser Einheit |
| **Zwanzigste Fortschreibung, 2026-09-22:** Weisung, Lesart zu 3.4 und Lesart zu R1 in den methodischen Entscheiden; Übergabevermerk | `methodik/entscheide.md`, `UEBERGABE.md` (Repository `r3coscrum`) | Koordinator, in dieser Einheit |
| **Zwanzigste Fortschreibung, 2026-09-22, Teil 2 (ADR 0002, Abschnitt 10, E-F):** Starthook für die Git-Historie, Eintrag im Array `SessionStart`, Hook-Regel | `.claude/hooks/session-start-git-historie.sh`, `.claude/settings.json`, `.claude/rules/claude-konfiguration.md` | SecDevOps Engineer, in dieser Einheit |
| **Zwanzigste Fortschreibung, 2026-09-22, Teil 2 (ADR 0002, Abschnitt 10, E-F):** Absatz zu den drei `SessionStart`-Hooks und Artefaktzeilen | `CLAUDE.md`, `scripts/nachweise-erzeugen.sh` | Koordinator, in dieser Einheit |
| **Zwanzigste Fortschreibung, 2026-09-22, Teil 2:** Nachtrag zu S8 und Übergabevermerk | `methodik/entscheide.md`, `UEBERGABE.md` (Repository `r3coscrum`) | Koordinator, in dieser Einheit |
| **Zwanzigste Fortschreibung, 2026-09-22, Nachtrag (ADR 0002, Abschnitt 10, E-E und E-F):** Abschnitt 10, E-E und E-F, je zweiter Nachtrag (Codex-Review am Pull Request #17: vier Befunde behoben, P1 in zwei Schritten — Refspec und leere Refmap) | `docs/adr/0002-architekturentscheid-ziel-stack.md`, Abschnitt 10 | Anlass: Codex-Review am Pull Request #17 vom 2026-09-22; statische und dynamische Nachprüfung; Protocol Master, in dieser Einheit |
| **Zwanzigste Fortschreibung, 2026-09-22, Abnahme (ADR 0002, Abschnitt 10):** Abschnitt 10, neuer Abnahmeeintrag: Abnahme der beiden Starthooks E-E und E-F durch Merge des Pull Requests #17 | `docs/adr/0002-architekturentscheid-ziel-stack.md`, Abschnitt 10 | Anlass: Merge des Pull Requests #17 am 2026-09-22; Protocol Master, in dieser Einheit |
| **Zwanzigste Fortschreibung, 2026-09-22, dritter Nachtrag (ADR 0002, Abschnitt 10, E-E und E-F):** Abschnitt 10, E-E und E-F, je dritter Nachtrag (Codex-Review, dritter Lauf: `SSLKEYLOGFILE` und PATH-Reihenfolge bei E-E; `core.hooksPath` und `--no-recurse-submodules` bei E-F) | `docs/adr/0002-architekturentscheid-ziel-stack.md`, Abschnitt 10 | Anlass: Codex-Review am Pull Request #17, dritter Lauf, am Commit `59de8974bc6871e4e5e1ce179cc1b29d98739961`; statische und dynamische Nachprüfung; Protocol Master, in dieser Einheit |
| **Einundzwanzigste Fortschreibung, 2026-09-23 (E4.1, ADR 0002, 6.13):** Prüfmittel, Ausnahmeliste, Hook-Regel | `scripts/pretooluse-gates-selbsttest.sh`, `scripts/belege-ausnahmen.txt`, `.claude/rules/claude-konfiguration.md` | SecDevOps Engineer, in dieser Einheit |
| **Einundzwanzigste Fortschreibung, 2026-09-23 (E4.1):** Gate-Tabelle und Statuszeile, Artefaktzeilen, Stand-Vermerk R3-Q-010, Übergabe; Methodik-Repository | `CLAUDE.md`, `scripts/nachweise-erzeugen.sh`, `docs/05_Product_Backlog.md`, `docs/uebergaben/2026-09-23_e4-1-pruefmittel-pretooluse-gates.md`; `methodik/entscheide.md`, `UEBERGABE.md` (Repository `r3coscrum`) | Koordinator und Product Owner, in dieser Einheit |
| **Einundzwanzigste Fortschreibung, 2026-09-23 (E4.2, ADR 0002, 6.13):** Prototyp-Gate (ST-04, ST-05, P-01) und Prüfmittel (17 Fälle blockierend, B43 neu) | `.claude/hooks/block-prototype-import.sh`, `scripts/pretooluse-gates-selbsttest.sh`, Nachführung in `CLAUDE.md`, `docs/05_Product_Backlog.md`, `scripts/nachweise-erzeugen.sh`, `docs/uebergaben/2026-09-23_e4-2-prototyp-gate-erkennungsluecken.md`; `methodik/entscheide.md`, `UEBERGABE.md` (Repository `r3coscrum`) | SecDevOps Engineer, Koordinator, Product Owner, in dieser Einheit |
| **Einundzwanzigste Fortschreibung, 2026-09-23 (E4.3, ADR 0002, 6.13):** beide Gates (ST-09, ST-13, Grenzen, P-10) und Prüfmittel | `.claude/hooks/block-main-write.sh`, `.claude/hooks/block-prototype-import.sh`, `scripts/pretooluse-gates-selbsttest.sh`; Nachführung in `CLAUDE.md`, `docs/05_Product_Backlog.md`, `scripts/nachweise-erzeugen.sh`, `docs/uebergaben/2026-09-23_e4-3-raender-st-09-st-13-grenzen.md`; `UEBERGABE.md` (Repository `r3coscrum`) | SecDevOps Engineer, Koordinator, Product Owner, in dieser Einheit |
| **Zweiundzwanzigste Fortschreibung, 2026-09-23 (ADR 0002, Abschnitt 10, Abnahme von R3-Q-010):** Abnahmeeintrag zu R3-Q-010 — Merge des Pull Requests #21 am 2026-09-23, erster Formweg, ohne Auflagen, im Umfang der drei Übergaben vom 2026-09-23 einschliesslich der dort benannten Restbefunde; Merge-Commits und Uhrzeiten wie im Nachtrag vom 2026-09-23 im Status-Block von ADR 0002, 6.13 | ADR 0002, Abschnitt 10 (`docs/adr/0002-architekturentscheid-ziel-stack.md`) | Protocol Master, in dieser Einheit |
| **Zweiundzwanzigste Fortschreibung, 2026-09-23 (ADR 0002, Abschnitt 10 und 6.13 c):** Stand-Vermerk zu R3-Q-010 auf "abgenommen" mit Merge-Commit; drei Posten unter R3-Q-010 nach ADR 0002, 6.13 c (Nachtrag vom 2026-09-23): Posten 1 main-Gate (L01 bis L04), Posten 2 Prototyp-Gate (L05 bis L08), Posten 3 Prototyp-Gate (L09), je mit Terminierung, Bauvorschrift und Vorbehalt | `docs/05_Product_Backlog.md` | Product Owner, in dieser Einheit |
| **Zweiundzwanzigste Fortschreibung, 2026-09-23 (ADR 0002, Abschnitt 10 und 6.13 c):** Statuszeile (Schritt 5): Abnahme von R3-Q-010 erteilt; Gate-Tabelle: die Angaben zu belegten Lücken und Prüfstand-Fällen in den Einträgen beider Gates um den Entscheid ergänzen (L01 bis L09 als belegte Lücken in drei Posten, die übrigen Prüfstand-Fälle als Grenze oder gewollt); Artefakt- und Beschreibungszeilen des Erzeugers (Datenzeilen), keine Änderung an seiner Logik | `CLAUDE.md`, `scripts/nachweise-erzeugen.sh` | Koordinator, in dieser Einheit |
| **Zweiundzwanzigste Fortschreibung, 2026-09-23:** ADR 0001, Abschnitt 8 — die beiden Entscheide des Auftraggebers vom 2026-09-23: Entscheid 1 (Schreibrecht an .claude/skills/: SecDevOps Engineer) und Entscheid 2 (Prüfstand-Fälle als Fortschreibung von ADR 0002, 6.13 c) | `docs/adr/0001-rollenmodell.md` | Protocol Master, in dieser Einheit |
| **Zweiundzwanzigste Fortschreibung, 2026-09-23 (ADR 0002, 6.13 c):** Kopfkommentare nach dem Entscheid — Grenze an der Schnittstelle (Werkzeugname) in beiden Gates, Grenze der Auswertung im main-Gate mit Posten 1, Absatz zu den symmetrischen Lücken mit Posten 2, im Absatz zur Asymmetrie der Pfadschreibweise der Verweis auf den Nachtrag; im Prüfmittel Klassen und Vermerke der 21 Prüfstand-Fälle nach der Spalte "Folge", Fallklassen neu abgezählt | `.claude/hooks/block-main-write.sh`, `.claude/hooks/block-prototype-import.sh`, `scripts/pretooluse-gates-selbsttest.sh` | SecDevOps Engineer, mit der nächsten Änderung an den Gates, nicht in dieser Sitzung |
| **Zweiundzwanzigste Fortschreibung, 2026-09-23:** Übergabevermerk — Abnahme von R3-Q-010 und Entscheid zu den Prüfstand-Fällen; Verweise ausschliesslich über die 40-stellige Commit-Prüfsumme | `UEBERGABE.md` (Repository `r3coscrum`) | Koordinator |
| **Dreiundzwanzigste Fortschreibung, 2026-09-23 (ADR 0002, 6.14, E3/R3-Q-011):** Stand-Vermerk zu R3-Q-011 (eingeordnet in ADR 0002, 6.14, nicht gebaut), Summen der Etappe 0 und Stand-Zeile im Kopf; neuer offener Punkt 22 — Freigabe des Umfangs und des Schnitts durch den Merge des Pull Requests dieser Sitzung | `docs/05_Product_Backlog.md` | Product Owner, in dieser Einheit |
| **Dreiundzwanzigste Fortschreibung, 2026-09-23 (ADR 0002, 6.14, E3/R3-Q-011):** Fortschreibung des Eintrags R3-Q-011 nach den Entscheiden zu den sechs Fragen — Achtung-Zeile mit den Annahmen nach R4 durch die Entscheide ersetzen, Rollen des Prüfsatzes (DevOps Engineer legt an, Static Software Tester prüft, Dynamic Software Tester fährt), Zerlegung mit dem Prüfsatz in E3.3, Lesart der Zeile "Zerlegung" zu CLAUDE.md; Entscheid über den Vorschlag `R3-Q-011_regel_im_startkontext` (ADR 0002, 6.14 f) — erfolgt am 2026-09-23, als sechstes Kriterium übernommen; offen: den Satz zum Nachweis der Modellverschiedenheit in den Zeilen "Nachweis" und "Achtung" (Frage 4) an ADR 0002, 6.14 e angleichen, ohne Modellnamen, und in der Zeile "Zerlegung" den überholten Hinweis zur Reihenfolge der beiden Versuche streichen (ADR 0002, 6.14 g) | `docs/05_Product_Backlog.md` | Requirements Engineer, in dieser Einheit vor dem Pull Request |
| **Dreiundzwanzigste Fortschreibung, 2026-09-23 (ADR 0002, 6.14, E3/R3-Q-011):** Begriffe Einschleusung, Fremder Inhalt und Harness | `docs/03_Glossar.md` | Requirements Engineer, in dieser Einheit |
| **Dreiundzwanzigste Fortschreibung, 2026-09-23 (ADR 0002, 6.14, E3/R3-Q-011):** Statuszeile (Schritt 5: E3 als R3-Q-011 festgelegt, Einordnung in ADR 0002, 6.14, Freigabe durch Merge ausstehend) und Tabelle "Wo steht was" (Zeile zu E3, R3-Q-011); Artefaktzeile für die Übergabe dieser Einheit | `CLAUDE.md`, `scripts/nachweise-erzeugen.sh` | Koordinator, in dieser Einheit |
| **Dreiundzwanzigste Fortschreibung, 2026-09-23 (ADR 0002, 6.14 c):** Neuer offener Punkt O-29 (NF-005) in der Tabelle der offenen Punkte | ADR 0002, Abschnitt 8 (`docs/adr/0002-architekturentscheid-ziel-stack.md`) | Software Architect, in dieser Einheit — mit dieser Fortschreibung eingetragen |
| **Dreiundzwanzigste Fortschreibung, 2026-09-23:** Übergabevermerk — E3 als R3-Q-011 festgelegt und in ADR 0002, 6.14 eingeordnet, Freigabe ausstehend; Verweise ausschliesslich über die 40-stellige Commit-Prüfsumme | `UEBERGABE.md` (Repository `r3coscrum`) | Koordinator, in dieser Einheit |
| **Dreiundzwanzigste Fortschreibung, 2026-09-23 (ADR 0002, 6.14 g, nach der Freigabe, E3.1):** Regel ohne `paths:`, höchstens 120 Zeilen, die Skill darin nur mit Namen, ohne Pfad; Zeile "Rules" der Mechanismentabelle um die immer geladene Regel ergänzen | `.claude/rules/fremde-inhalte-im-harness.md`, `.claude/rules/claude-konfiguration.md` | Koordinator; Verifikation Static Software Tester auf einem anderen Modell, mit Nachweis der Modellverschiedenheit ohne Modellnamen nach ADR 0002, 6.14 e |
| **Dreiundzwanzigste Fortschreibung, 2026-09-23 (ADR 0002, 6.14 g, nach der Freigabe, E3.2):** Skill in der Bauform nach ADR 0002, 6.14 d | `.claude/skills/einschleusung-pruefen/SKILL.md` | SecDevOps Engineer; Verifikation Static Software Tester auf einem anderen Modell |
| **Dreiundzwanzigste Fortschreibung, 2026-09-23 (ADR 0002, 6.14 g, nach der Freigabe, E3.2):** `skills:`-Feld der sechs Rollen nach ADR 0002, 6.14 e; `Skill` neu in den Werkzeuglisten von Security Specialist GRC, Legal Reviewer, Digital-Forensics-Spezialist und IT Supporter; in der Regel den Pfad der Skill ergänzen; zu Beginn der Sitzung der Versuch `R3-Q-011_regel_im_startkontext`, Ergebnis und Gegenprobe in der Übergabe | die sechs Rollendateien unter `.claude/agents/`; `.claude/rules/fremde-inhalte-im-harness.md` | Koordinator (der Versuch auf Frage des Auftraggebers); Verifikation Static Software Tester auf einem anderen Modell, mit Nachweis der Modellverschiedenheit nach ADR 0002, 6.14 e |
| **Dreiundzwanzigste Fortschreibung, 2026-09-23 (ADR 0002, 6.14 g, nach der Freigabe, E3.2):** Rollentabelle (vier Werkzeuglisten; Nachtrag vom 2026-08-31: dreizehn statt neun Rollen mit `Skill`) und Zeile der dritten Skill mit Begründung je Rolle | `docs/adr/0001-rollenmodell.md`, Abschnitte 3 und 5.1 | Software Architect; Verifikation Static Software Tester auf einem anderen Modell — die `model`-Felder beider Rollen sind gleich, deshalb mit Erklärung in der Übergabe nach ADR 0002, 6.14 e |
| **Dreiundzwanzigste Fortschreibung, 2026-09-23 (ADR 0002, 6.14 g, nach der Freigabe, E3.3):** gegebenenfalls der nachgeholte Versuch zur Regel, dann Kontrollversuch mit Gegenprobe; Prüfsatz anlegen, formal prüfen, committen; Lauf; Abgleich und Arbeitsbaum; Ergebnis des Kontrollversuchs | "scripts/einschleusung-pruefsatz/"; `docs/adr/0001-rollenmodell.md`, Abschnitt 5.1 | Koordinator (Versuche), DevOps Engineer (Prüfsatz), Static Software Tester (formale Prüfung, Abgleich, Arbeitsbaum), Dynamic Software Tester (Lauf), Software Architect (ADR 0001, Abschnitt 5.1) — erledigt am 2026-09-25 (E3.3): Versuch zur Regel geführt, Gegenprobe nicht durchgeführt, `R3-Q-011_regel_im_startkontext` offen; Kontrollversuch mit Gegenprobe, Ergebnis in ADR 0001, Abschnitt 5.1 (Commit `1f8865cc36701702f1bb61bc47e40cf948b51756`); Prüfsatz angelegt, formal geprüft und vor dem Lauf committet (Commit `818a17162bbbc51206138ddcecae907f5e4bb235`); Lauf, Abgleich und Arbeitsbaum bestanden (ADR 0002, 6.14, Status-Block, Nachtrag vom 2026-09-25 "E3.3 gebaut") |
| **Dreiundzwanzigste Fortschreibung, 2026-09-23 (ADR 0002, 6.14 g, nach der Freigabe, E3.1 und E3.2):** Ausnahmezeilen für den dann bestehenden Pfad der Regel beziehungsweise der Skill wieder entfernen | `scripts/belege-ausnahmen.txt` | umsetzende Rolle: Koordinator mit E3.1, SecDevOps Engineer mit E3.2 |
| **Dreiundzwanzigste Fortschreibung, 2026-09-23 (ADR 0002, 6.14 g, nach der Freigabe, E3.1 bis E3.3):** Artefaktzeilen für Regel, Skill und Prüfsatz; Tabelle "Wo steht was" und Statuszeile | `scripts/nachweise-erzeugen.sh`, `CLAUDE.md` | Koordinator, mit der jeweiligen Teileinheit — für E3.3 erledigt am 2026-09-25: Artefaktzeile für den Prüfsatz in `scripts/nachweise-erzeugen.sh`, Zeile zu E3 in der Tabelle "Wo steht was" und Statuszeile in `CLAUDE.md` (am Arbeitsbaum geprüft am 2026-09-25) |
| **Vierundzwanzigste Fortschreibung, 2026-09-24 (ADR 0002, Abschnitt 10, Freigabe von E3):** Freigabeeintrag zu E3 (R3-Q-011) — Merge des Pull Requests #23 am 2026-09-24, erster Formweg, ohne Auflagen, mit dem Wortlaut der Weisung vom 2026-09-24; Nachtrag vom 2026-09-24 zum Abnahmeeintrag zu R3-Q-010 (Bestätigung durch denselben Merge) | ADR 0002, Abschnitt 10 (`docs/adr/0002-architekturentscheid-ziel-stack.md`) | Protocol Master, in dieser Einheit |
| **Vierundzwanzigste Fortschreibung, 2026-09-24 (ADR 0002, 6.14):** Status-Block, Nachtrag vom 2026-09-24 (Freigabe erteilt, Weisung zu Schnitt und Reihenfolge, Wortlaut beider), und Buchstabe g, Nachtrag vom 2026-09-24 (Folgen der Weisung für den Versuch zur Regel, den Merksatz der Regel, die drei Posten unter R3-Q-010 und O-29 und die Reihenfolge); Kopfzeile "Fortschreibung" | ADR 0002, 6.14 (`docs/adr/0002-architekturentscheid-ziel-stack.md`) | Software Architect, in dieser Einheit — mit dieser Fortschreibung eingetragen |
| **Vierundzwanzigste Fortschreibung, 2026-09-24 (ADR 0002, 6.14 g, E3/R3-Q-011):** Zerlegung des Eintrags R3-Q-011 nach der Weisung vom 2026-09-24, mit deren Wortlaut, und Zeile "Abhängigkeit" von R3-Q-011, Nachtrag vom 2026-09-24 (freigegeben durch Merge des Pull Requests #23, Weisung in der Zeile "Zerlegung") — Requirements Engineer; Wegfall des Vorbehalts nach R1 für S-01, Stand-Vermerk zu R3-Q-011, Eintrag R3-Q-010 um den Nachtrag 2026-09-24 (drei Posten entschieden, offener Punkt 21 erledigt) und den Stand-Vermerk 2026-09-24 (Bestätigung des Abnahmeeintrags in ADR 0002, Abschnitt 10) ergänzt, offene Punkte 21 und 22 erledigt, offener Punkt 20 um den Stand-Vermerk 2026-09-24 ergänzt, Punkt 15 nachgeführt, Stand-Zeile im Kopf — Product Owner | `docs/05_Product_Backlog.md` | Requirements Engineer und Product Owner, in dieser Einheit |
| **Vierundzwanzigste Fortschreibung, 2026-09-24:** Statuszeile (Schritt 5: Freigabe von E3 erteilt, Weisung vom 2026-09-24, nächste Einheiten) | `CLAUDE.md` | Koordinator, in dieser Einheit |
| **Vierundzwanzigste Fortschreibung, 2026-09-24:** Übergabevermerk — Freigabe von E3 und Weisung vom 2026-09-24; Verweise ausschliesslich über die 40-stellige Commit-Prüfsumme | `UEBERGABE.md` (Repository `r3coscrum`) | Koordinator |
| **Vierundzwanzigste Fortschreibung, 2026-09-24 (ADR 0002, 6.14 g, Nachtrag vom 2026-09-24, E3.1 bis E3.3):** E3.1 und der Bau von E3.2 liegen in derselben Sitzung; der Versuch `R3-Q-011_regel_im_startkontext` aus den Zeilen zu E3.2 wird zu Beginn von E3.3 geführt, vor dem Kontrollversuch, mit Ergebnis und Gegenprobe samt Datum in der Übergabe; die Zeilen der Dreiundzwanzigsten Fortschreibung zu E3.1 bis E3.3 bleiben als Stand davor stehen (ADR 0002, 6.1.2) | Übergabe der Sitzung, die E3.3 beginnt (unter docs/uebergaben/) | Koordinator auf Frage des Auftraggebers, in der ersten Sitzung nach dem Commit von E3.2 |
| **Fünfundzwanzigste Fortschreibung, 2026-09-25 (ADR 0002, Abschnitt 10 und 6.14, Merges #24 und #14):** Eintrag der Merges der Pull Requests #24 (Merge-Commit `0af86aa4e6485d6cdfe09829accfdb65a8a8c65a`) und #14 im Methodik-Repository (Merge-Commit `ee56fea8572348799069ac0b866376764edf6694`) vom 2026-09-25, erster Formweg, ohne Auflagen — Bestätigung des Freigabe-Eintrags zu E3, Regel verbindlich, Skill und Zuordnung zu sechs Rollen angenommen, Gegenprobe zu `R3-Q-011_regel_im_startkontext` vor dem Merge nicht gelaufen (Protocol Master); Vollzug der angekündigten Wirkungen in ADR 0002, 6.14, Status-Block und Buchstabe e, je Nachtrag vom 2026-09-25, und Kopfzeile "Fortschreibung"; in ADR 0001 Kopfzeile "Fortgeschrieben" und Abschnitt 5.1, Nachtrag vom 2026-09-25 (Software Architect); der Stand davor bleibt stehen (ADR 0002, 6.1.2) | ADR 0002, Abschnitt 10 und 6.14 (`docs/adr/0002-architekturentscheid-ziel-stack.md`); `docs/adr/0001-rollenmodell.md`, Abschnitt 5.1 | Protocol Master (Abschnitt 10) und Software Architect (6.14, Kopfzeile, ADR 0001), in dieser Einheit — mit dieser Fortschreibung eingetragen |
| **Sechsundzwanzigste Fortschreibung, 2026-09-25 (ADR 0002, 6.14, E3.3):** Status-Block, Nachtrag vom 2026-09-25 "E3.3 gebaut" — Versuch zur Regel mit Vergleich "gleich", Gegenprobe nicht durchgeführt, `R3-Q-011_regel_im_startkontext` offen; Kontrollversuch positiv, mit Offenlegung zum Übergabeaufruf (ADR 0001, Abschnitt 5.1, Commit `1f8865cc36701702f1bb61bc47e40cf948b51756`); Prüfsatz nach ADR 0002, 6.14 d angelegt, formal geprüft und vor dem Lauf committet (Commit `818a17162bbbc51206138ddcecae907f5e4bb235`); Lauf und Abgleich bestanden, mit den Grenzen des Belegs; Abnahme von R3-Q-011 durch den Merge des Pull Requests dieser Sitzung, ohne `R3-Q-011_regel_im_startkontext`; Terminierung nach ADR 0002, 6.14 e für die dreizehn Werkzeuglisten nicht entschieden; Buchstabe d, Nachtrag vom 2026-09-25 (die Pfade des Prüfsatzes bestehen); Erledigt-Vermerke in den Zeilen der Dreiundzwanzigsten Fortschreibung zu E3.3 und zu E3.1 bis E3.3; Kopfzeile "Fortschreibung"; der Stand davor bleibt stehen (ADR 0002, 6.1, Absatz "Anlass") | ADR 0002, 6.14 und Abschnitt 9 (`docs/adr/0002-architekturentscheid-ziel-stack.md`) | Software Architect, in dieser Einheit — mit dieser Fortschreibung eingetragen |
| **Siebenundzwanzigste Fortschreibung, 2026-10-14 (ADR 0002, Abschnitt 10, Abnahme von R3-Q-011):** Abnahmeeintrag zu R3-Q-011 — Merge des Pull Requests #25 am 2026-09-25 (Merge-Commit `0b6d59625423f53fcd0e8b3f22150d97ef2a17f4`; Methodik-Repository Pull Request #15, Merge-Commit `d349f3ce4bba8db8f919c188849acc452190ac44`), erster Formweg, ohne Auflagen, fünf der sechs Kriterien mit der Lesart zum Übergabeaufruf, nicht umfasst `R3-Q-011_regel_im_startkontext`, die Terminierung von `Skill`, die drei Posten unter R3-Q-010, O-29, R3-Q-005, D20 (O-15), Grundgerüst; dazu die Bestätigung des Eintrags zu den Merges #24 und #14 (Nachtrag vom 2026-10-14) | ADR 0002, Abschnitt 10 (`docs/adr/0002-architekturentscheid-ziel-stack.md`) | Protocol Master, in dieser Einheit — mit dieser Fortschreibung eingetragen |
| **Siebenundzwanzigste Fortschreibung, 2026-10-14 (ADR 0002, 6.14):** Status-Block, Nachtrag vom 2026-10-14 (Abnahme erteilt und eingetragen, Umfang, Nicht-Umfasstes, Terminierung nicht entschieden); Buchstabe e, Nachtrag vom 2026-10-14 (Terminierung fällig, nicht entschieden, `Skill` bleibt in dreizehn Werkzeuglisten); Buchstabe g, Nachtrag vom 2026-10-14 (Punkt 5 vollzogen bis zur Abnahme, die drei Posten unter R3-Q-010 stehen an); Kopfzeile "Fortschreibung"; der Stand davor bleibt stehen (ADR 0002, 6.1, Absatz "Anlass") | ADR 0002, 6.14 und Kopfzeile (`docs/adr/0002-architekturentscheid-ziel-stack.md`) | Software Architect, in dieser Einheit — mit dieser Fortschreibung eingetragen |
| **Siebenundzwanzigste Fortschreibung, 2026-10-14 (Abnahme von R3-Q-011):** Stand-Vermerk "2026-10-14 (abgenommen am 2026-09-25)" bei R3-Q-011 mit dem Wortlaut des Pull Requests #25, achtzehnte Nachführung, Stand-Zeile im Kopf, offener Punkt 23 ((b) erledigt, (a) und (c) offen); keine Summenänderung | `docs/05_Product_Backlog.md` | Product Owner, in dieser Einheit — erledigt |
| **Siebenundzwanzigste Fortschreibung, 2026-10-14 (Abnahme von R3-Q-011):** Statuszeile (Schritt 5): Abnahme von R3-Q-011 erteilt, nicht umfasst `R3-Q-011_regel_im_startkontext` und die Terminierung von `Skill`; Abschnitt B läuft | `CLAUDE.md` | Koordinator, in dieser Einheit — erledigt |
| **Siebenundzwanzigste Fortschreibung, 2026-10-14 (ADR 0002, 6.14 e):** Terminierung von `Skill` in den dreizehn Werkzeuglisten — erneut begründen oder entfernen, als Fortschreibung von ADR 0001, Abschnitte 3 und 5.1; erst nach dem Entscheid des Auftraggebers (Backlog, offener Punkt 23, Buchstabe c), bis dahin keine Zeile an ADR 0001 | `docs/adr/0001-rollenmodell.md` | Software Architect, nach dem Entscheid des Auftraggebers |
| **Siebenundzwanzigste Fortschreibung, 2026-10-14:** Übergabe der Sitzung (Abnahme von R3-Q-011 eingetragen, die drei Posten unter R3-Q-010), Artefaktzeile der Übergabe, Übergabevermerk im Methodik-Repository; Verweise ausschliesslich über die 40-stellige Commit-Prüfsumme | Übergabe unter docs/uebergaben/, `scripts/nachweise-erzeugen.sh`, `UEBERGABE.md` (Repository `r3coscrum`) | Koordinator, mit dem Abschluss der Sitzung |
| **Achtundzwanzigste Fortschreibung, 2026-10-14 (ADR 0002, 6.13, Posten 1 unter R3-Q-010):** Status-Block, Nachtrag vom 2026-10-14 "Posten 1 gebaut" (Gate, Prüfmittel, Läufe, Verifikation, Einordnungen in Kurzform, Posten 4 und Posten 5, Nicht-Geändertes, Abnahme durch Merge); Buchstabe c, Nachtrag vom 2026-10-14 (Einordnungen nach dem Massstab des Nachtrags vom 2026-09-23, Posten 4 mit a bis c und Posten 5 mit Rahmen, Zählung der Fallklassen mit der Abweichung von "einmal", Vollzug des Klassenwechsels der Prüfstand-Fälle, die zwei weiteren Formen aus DT-E41-04, Restpunkte); Kopfzeile "Fortschreibung"; der Stand davor bleibt stehen (ADR 0002, 6.1, Absatz "Anlass") | ADR 0002, 6.13, Kopfzeile und Abschnitt 9 (`docs/adr/0002-architekturentscheid-ziel-stack.md`) | Software Architect, in dieser Einheit — mit dieser Fortschreibung eingetragen |
| **Achtundzwanzigste Fortschreibung, 2026-10-14 (ADR 0002, 6.13, Posten 1 unter R3-Q-010):** main-Gate: cmd_ziel mit vier lexikalischen Schritten, ziel_hat als Oder-Verknüpfung für die Zielmuster und den Namen hinter -b/-B, neue Prüfung für -b/-B vor der worktree-Sperre, Verb, Sammel-Push-Optionen und Ausnahme am Befehlstext; im Kopfkommentar der Absatz zu Posten 1, die Grenzen GM-5 bis GM-8 und der datierte Nachtrag zur Deckungsaussage; Prüfmittel von 258 Fällen, 19 Mutationen und 23 Fallklassen auf 318, 26 und 28, L01 bis L04 mit Soll 2, Mutationen MM9 bis MM15, Klassenwechsel der Prüfstand-Fälle | `.claude/hooks/block-main-write.sh`, `scripts/pretooluse-gates-selbsttest.sh` | SecDevOps Engineer, in dieser Einheit; verifiziert durch Static und Dynamic Software Tester auf einem anderen Modell als die Umsetzung (ADR 0002, 6.13 f, Punkt 4) |
| **Achtundzwanzigste Fortschreibung, 2026-10-14 (Posten 1 unter R3-Q-010):** Zeile zu `.claude/hooks/block-main-write.sh` in der Tabelle "Aktive Gates" | `CLAUDE.md` | Koordinator, in dieser Einheit |
| **Achtundzwanzigste Fortschreibung, 2026-10-14 (ADR 0002, 6.13 c, Nachtrag vom 2026-10-14):** Sammelposten R3-Q-010 — Posten 1 gebaut; neu Posten 4 (a Befehlskette, b Zeilenfortsetzung in den Prüfungen am Befehlstext, c Basename-Form) und Posten 5 (beide Gates, grosse Eingabe), je mit Terminierung und der Einordnung in die Reihenfolge durch den Auftraggeber | `docs/05_Product_Backlog.md` | Product Owner, in den Nachführungen dieser Sitzung (Backlog, `CLAUDE.md`, Nachweise; Schritt B5 des Sitzungsauftrags vom 2026-10-14, festgehalten in der Übergabe der Sitzung) — ausstehend |
| **Achtundzwanzigste Fortschreibung, 2026-10-14:** Statuszeile und Tabelle "Wo steht was"; Artefaktzeilen | `CLAUDE.md`, `scripts/nachweise-erzeugen.sh` | Koordinator, in den Nachführungen dieser Sitzung (Backlog, `CLAUDE.md`, Nachweise; Schritt B5 des Sitzungsauftrags vom 2026-10-14, festgehalten in der Übergabe der Sitzung) — ausstehend |
| **Neunundzwanzigste Fortschreibung, 2026-10-21 (ADR 0002, 6.13 und Abschnitt 10, Abnahme von Posten 1, Weisung vom 2026-10-21):** Abnahmeeintrag zu Posten 1 unter R3-Q-010 in Abschnitt 10 — Merge des Pull Requests #26 am 2026-10-16 (Merge-Commit `5ada002023c0ff160c26c78659727c7e8623c6f5`), erster Formweg, ohne Kommentare und Reviews, zugleich Bestätigung des Eintrags zu R3-Q-011 (Protocol Master); 6.13, Status-Block, Nachtrag vom 2026-10-21 (Abnahme, Merge des Pull Requests #16 im Methodik-Repository, Weisung vom 2026-10-21 und Vorangegangenes vom 2026-10-15 im Wortlaut, die delegierten Entscheide 1 bis 5 des Koordinators zu Reihenfolge, CVSS-Bewertung und Schwachstellenregister, Prüftiefe, Zurückgestelltem und Zweig); Kopfzeile "Fortschreibung"; der Stand davor bleibt stehen (ADR 0002, 6.1, Absatz "Anlass") | ADR 0002, Abschnitt 10, 6.13, Kopfzeile und Abschnitt 9 (`docs/adr/0002-architekturentscheid-ziel-stack.md`) | Protocol Master (Abschnitt 10) und Software Architect (6.13, Kopfzeile, Abschnitt 9), in dieser Einheit — mit dieser Fortschreibung eingetragen |
| **Dreissigste Fortschreibung, 2026-10-21 (ADR 0002, 6.13, Posten 4 und 5 unter R3-Q-010 gebaut, Posten 6 und 7 erfasst):** 6.13, Status-Block, Nachtrag vom 2026-10-21 zum Bau von Posten 4 und 5 (Bau, Prüfmittel, Läufe, Verifikation in einer ersten Runde und vier Delta-Runden, die vierte statisch und dynamisch bestanden, Zählung nach 3.4, Register, Posten 6 und 7, Vorbehalte, Abnahme durch Merge); Buchstabe c, Nachtrag vom 2026-10-21 (Posten 5 Form, Fehlerpfad und Fälle, Posten 4 a bis c samt DT-C2-01, DT-C2-02, DT-C2-E-01, ST-C2-F-01, den Fehlalarmklassen ST-C2-02 und ST-C2-D-07, den Preisen KM-14 und KM-17 mit der Fortschreibung des Vorbehalts zu A139 bis A142 und A149 und der Grenze der Umleitungs-Erkennung, Umgebung, Regressionsschutz in beide Richtungen, Posten 6 und 7 mit Rahmen, Ausnahme der Zeitgrenze von 6.13 d, belegte Lücken, Register, Zählung, Restpunkte samt DT-C2-G-01 und ST-C2-G-01 bis ST-C2-G-03 ohne weitere Änderung am Gate, Übergabe) und der Vermerk "überholt" am Restpunkt zum Register im Nachtrag vom 2026-10-14; Kopfzeile "Fortschreibung"; Gates und Prüfmittel, verifiziert durch Static und Dynamic Software Tester auf dem anderen `model`-Feld; ausserhalb des ADR nachzuführen: Status von SR-001 und Einträge zu DT-C2-01, Posten 6 und Posten 7, Sammelposten R3-Q-010 (Posten 4 und 5 gebaut, Posten 6 und 7 neu), Zeilen beider Gates in "Aktive Gates" und Statuszeile, Übergabe; der Stand davor bleibt stehen (ADR 0002, 6.1, Absatz "Anlass") | ADR 0002, 6.13, Kopfzeile und Abschnitt 9 (`docs/adr/0002-architekturentscheid-ziel-stack.md`); `.claude/hooks/block-main-write.sh`, `.claude/hooks/block-prototype-import.sh`, `scripts/pretooluse-gates-selbsttest.sh`; `docs/11_Schwachstellenregister.md`; `docs/05_Product_Backlog.md`; `CLAUDE.md`; `docs/uebergaben/2026-10-21_abschnitt-c-posten-4-5.md` | Software Architect (ADR), in dieser Einheit — mit dieser Fortschreibung eingetragen; SecDevOps Engineer (Gates, Prüfmittel) — erledigt; Vulnerability Manager (Register), Product Owner (Backlog), Koordinator (`CLAUDE.md`, Übergabe), in den Nachführungen dieser Sitzung |
| **Einunddreissigste Fortschreibung, 2026-10-21 (ADR 0002, 6.13 und Abschnitt 10, Abnahme von Posten 4 und 5, Weisung vom 2026-10-21, Festlegung für C3):** Abnahmeeintrag zu Posten 4 und 5 unter R3-Q-010 in Abschnitt 10 — Merge des Pull Requests #27 am 2026-10-21 (Merge-Commit `998f81d9fffe3970baf870d04e44576eda534fcc`), erster Formweg, ohne Kommentare und Reviews, zugleich Bestätigung des Eintrags zur Abnahme von Posten 1 und der delegierten Einordnungen; Methodik-Repository Pull Request #17 (Merge-Commit `f8cb47867fe09b80adb623a6c37fb6d800c49f1c`) (Protocol Master); 6.13, Status-Block, Nachtrag vom 2026-10-21 zur Abnahme von Posten 4 und 5 (Abnahme, Weisung im Wortlaut, Lesarten des Koordinators zu D1, C3 und zum Register) und Buchstabe c, Nachtrag vom 2026-10-21 zur Abnahme von Posten 4 und 5 — Festlegung für C3 (Posten 2, Posten 6 und Teil von Posten 7 am Prototyp-Gate, je mit Abnahmekriterium; Teil von Posten 7 am main-Gate; Rahmen); Kopfzeile "Fortschreibung"; ausserhalb des ADR nachzuführen: Status von SR-001 und SR-002, Backlog, `CLAUDE.md`; der Stand davor bleibt stehen (ADR 0002, 6.1, Absatz "Anlass") | ADR 0002, Abschnitt 10, 6.13, Kopfzeile und Abschnitt 9 (`docs/adr/0002-architekturentscheid-ziel-stack.md`); `docs/11_Schwachstellenregister.md`; `docs/05_Product_Backlog.md`; `CLAUDE.md` | Protocol Master (Abschnitt 10) und Software Architect (6.13, Kopfzeile, Abschnitt 9), in dieser Einheit — mit dieser Fortschreibung eingetragen; Vulnerability Manager (Register), Product Owner (Backlog), Koordinator (`CLAUDE.md`), in D1 |
| **Zweiunddreissigste Fortschreibung, 2026-10-22 (ADR 0002, 6.13, C3 gebaut, Weisungen vom 2026-10-22, Posten 8 bis 10 erfasst):** 6.13, Status-Block, Nachtrag vom 2026-10-22 — C3: Posten 2, Posten 6 und Teil von Posten 7 am Prototyp-Gate gebaut (Bau, Zahlen 479, 66 und 39, Endprüfsummen, Läufe, Verifikation, Register, Posten 8 bis 10, Weisungen vom 2026-10-22 im Wortlaut mit Lesart des Koordinators, nächste Einheit) und Buchstabe c, Nachtrag vom 2026-10-22 zum Bau von C3 — Einordnungen und Berichtigung (gewollter Durchlass, JS-Zuweisungen, Berichtigung der Laufzeit, Schärfung je geprüfter Stelle, Mutationen über die Mindestzahl, DT-C3-01 bis DT-C3-05 mit Posten 8, 9 und 10 und der Grenze des Waisenprozesses, Restpunkte, belegte Lücken, Zählung); Kopfzeile "Fortschreibung"; Gate und Prüfmittel, verifiziert durch Static und Dynamic Software Tester auf einem anderen Modell als die Umsetzung; ausserhalb des ADR nachzuführen: Status von SR-003 (Teil am Prototyp-Gate), Bewertung von SR-004, neu SR-005 (Posten 8) und SR-006 (Posten 9), Sammelposten R3-Q-010 (Posten 2, Posten 6 und Teil von Posten 7 am Prototyp-Gate gebaut, Posten 8 bis 10 neu), Zeile des Prototyp-Gates in "Aktive Gates", Absatz zu den vorausgesetzten Werkzeugen und Statuszeile in `CLAUDE.md`, Übergabe; der Stand davor bleibt stehen (ADR 0002, 6.1, Absatz "Anlass") | ADR 0002, 6.13, Kopfzeile und Abschnitt 9 (`docs/adr/0002-architekturentscheid-ziel-stack.md`); `.claude/hooks/block-prototype-import.sh`, `scripts/pretooluse-gates-selbsttest.sh`; `docs/11_Schwachstellenregister.md`; `docs/05_Product_Backlog.md`; `CLAUDE.md`; Übergabe unter `docs/uebergaben/` | Software Architect (ADR), in dieser Einheit — mit dieser Fortschreibung eingetragen; SecDevOps Engineer (Gate, Prüfmittel) — erledigt; Vulnerability Manager (Register), Product Owner (Backlog), Koordinator (`CLAUDE.md`, Übergabe), in den Nachführungen dieser Sitzung |
| **Dreiunddreissigste Fortschreibung, 2026-10-22 (ADR 0002, 6.13 und Abschnitt 10, Abnahme von Posten 2, 6 und Teil von Posten 7; Annahme von PS-1):** Abnahmeeintrag zu Posten 2, 6 und zum Teil von Posten 7 am Prototyp-Gate unter R3-Q-010 in Abschnitt 10 — Merge des Pull Requests #28 am 2026-10-22 (Merge-Commit `95cafc9cc31773a6c29d977ec9c3b97af5a1f047`), erster Formweg, ohne Kommentare und Reviews, zugleich Bestätigung des Eintrags zur Abnahme von Posten 4 und 5 (Nachtrag an jenem Eintrag), der Lesart des Koordinators zum Register und Annahme der Register-Nachträge im vorgelegten Stand; Methodik-Repository Pull Request #18 gemergt (Merge-Commit `b26f286ef9680a741c0de5294d80543bace44de8`), spricht nach eigenem Text keine Abnahme aus; Eintrag zur Annahme des Prozess-Schnitts PS-1 in Abschnitt 10 — Merge des Pull Requests #29 am 2026-10-22 (Merge-Commit `d7d539ebea07043201d58e36c8abafec54045848`), erster Formweg, ohne Kommentare und Reviews, zugleich Bestätigung der Lesart zu E-PS-2 und E-PS-5 (Protocol Master); 6.13, Status-Block, Nachtrag vom 2026-10-22 zur Abnahme von Posten 2, 6 und des Teils von Posten 7 am Prototyp-Gate (Merge-Fakten, Verweis auf Abschnitt 10, Umfang und Nicht-Umfasstes, Annahme von PS-1, Beginn von PS-2); Kopfzeile "Fortschreibung"; der Stand davor bleibt stehen (ADR 0002, 6.1, Absatz "Anlass") | ADR 0002, Abschnitt 10, 6.13, Kopfzeile und Abschnitt 9 (`docs/adr/0002-architekturentscheid-ziel-stack.md`) | Protocol Master (Abschnitt 10, 6.13, Kopfzeile und Abschnitt 9), in dieser Einheit (D2) — mit dieser Fortschreibung eingetragen; Register (`docs/11_Schwachstellenregister.md`) und Backlog (`docs/05_Product_Backlog.md`) führen nach Angabe des Koordinators die dafür zuständigen Rollen in derselben Einheit nach (nicht Gegenstand dieser Zeile) |
| **Abschluss dieses Abschnitts, 2026-10-22 (ADR 0002, Abschnitt 9, Prozess-Schnitt PS-2):** Dieser Abschnitt erhält keine weitere Zeile. Die Nachführliste steht ab jetzt im Text des Pull Requests je Sitzung (Projektauftrag 3.3, Fortschreibung vom 2026-10-22: je Sitzung ein Pull Request, dessen Text sagt, was der Merge bedeutet; Abschluss dieses Abschnitts nach `docs/vorlagen/2026-10-22_prozess-schnitt/anhang-a-adr-aufteilung-software-architect.md`, Abschnitt 1); dort stehen auch die Nachführungen zu PS-2 selbst. Die Zeilen oben bleiben als Bestand unverändert stehen; der Stand dieses Abschnitts bis zum Schnitt steht in `docs/adr/0002-architekturentscheid-ziel-stack.md` beim Commit `ac6e0c17672ad9f0d139a59dba8ca319f46056c4` | Text des Pull Requests je Sitzung | Koordinator, mit dem Pull Request je Sitzung — ab dem Schnitt |

**Nicht nachzuführen, weil sie einen vergangenen Stand belegen:** `docs/08_Freigabe_Schritt_4.md`, `docs/09_Zustandsbericht_2026-08-21.md` und die Dateien unter `docs/uebergaben/`. Sie nennen die Kette als "D1 bis D12" beziehungsweise "D1–D12 plus D13–D17"; das war am Tag ihrer Entstehung richtig und bleibt als Nachweis unverändert. Genau deshalb werden D-Nummern nicht umnummeriert (6.1.2).

---

## 10. Freigabevermerk

R3-C-001 gilt erst als abgenommen, wenn hier die schriftliche Freigabe des Auftraggebers vermerkt ist und der Status oben auf „angenommen" steht. Bis dahin bleibt dieser ADR ein Vorschlag, und Etappe 1 beginnt nicht.

| | |
|---|---|
| **Vorgelegt am** | 2026-08-20 |
| **Entscheid des Auftraggebers** | **freigegeben**, ohne Auflagen |
| **Auflagen** | keine |
| **Entscheid zu O-1 (Trennung Rahmenwerk und Komponentenbibliothek)** | **bestätigt** — Rahmenwerk jetzt entschieden, die konkrete Komponentenbibliothek folgt nach dem Prototyp-Review als eigener ADR (O-2) |
| **Datum der Freigabe** | 2026-08-20 |
| **Auftraggeber (S-01)** | Freigabe erteilt in der Claude-Code-Session, Wortlaut «Freigegeben, O-1 bestätigt»; Name nach offenem Entscheid E-11 nicht im Repository geführt |

**Protokollvermerk zur Form:** Die Freigabe wurde am 2026-08-20 über den
zweiten Formweg erteilt (Anweisung an die Session) und von der Session in
diesen Vermerk übertragen; Urheber und Zeitpunkt belegt die Commit-Historie
des Arbeitszweigs.

### Vorlage der zwölften Fortschreibung (Abschnitt 6.12) und Weisung vom 2026-09-02

| | |
|---|---|
| **Vorgelegt am** | 2026-09-02, Commit `21cc3ddbf45668c2e185958f8e2a8d42eeaf0150`, mit `docs/uebergaben/2026-09-02_r3-q-001-entwurf-dod-gate.md` und den elf Entscheidpunkten E-A bis E-K |
| **Weisung des Auftraggebers, Wortlaut** | "Gehe nach der besten Lösung und Schritte. Einfach keine Annahmen und sei vollkommen sicher." |
| **Lesart des Koordinators** | Der Bau beginnt auf diese Weisung; je Entscheidpunkt wird die vom Software Architect empfohlene Option umgesetzt. Die Weisung entscheidet die elf Punkte nicht einzeln |
| **Förmliche Freigabe** | **steht aus.** Formweg wie beim Freigabe-Gate Schritt 4: Merge des Pull Requests dieses Arbeitszweigs oder Anweisung an die nächste Sitzung mit dem exakten Wortlaut; jede der unten umgesetzten Optionen kann dabei zurückgewiesen werden — **erteilt am 2026-09-07 durch Merge des Pull Requests #13, Merge-Commit `135e3614197a8150ad3d96fbf32eb0e893c9cbbc`; der Satz "steht aus" bleibt als Stand davor stehen (6.1.2), Einzelheiten im Unterabschnitt darunter** |

Vom Koordinator umgesetzte Optionen, je die Empfehlung des Architects:

| Nr. | Punkt | Umgesetzte Option |
|---|---|---|
| E-A | 6.12 als Ganzes | Bau nach 6.12 |
| E-B | Terminierte Lagen C (G4) | (a) |
| E-C | Kette bricht bei Lage C nicht mehr ab (G5) | (a) |
| E-D | `FEHLT=` strukturiert in der Marke (G6) | (a) |
| E-E | `gitleaks` bleibt blockierend | (a), verbunden mit (b): gitleaks 8.21.2 am 2026-09-02 in der Sitzungsumgebung installiert, Prüfsumme des Release-Archivs gegen die veröffentlichte Prüfsummendatei geprüft; die dauerhafte Bereitstellung in der Umgebung liegt beim Auftraggeber; **Nachtrag vom 2026-09-22:** Die dauerhafte Bereitstellung ist auf Weisung des Auftraggebers (Wortlaut: "gitleaks permanent einbauen bitte.") als versionierter `SessionStart`-Hook `.claude/hooks/session-start-gitleaks.sh` gebaut (SecDevOps Engineer; Verifikation durch Static und Dynamic Software Tester auf einem anderen Modell): fehlt `gitleaks`, lädt er das Release-Archiv 8.21.2 für `linux_x64`, prüft die SHA-256-Prüfsumme gegen den im Skript gepinnten Wert `5bc41815076e6ed6ef8fbecc9d9b75bcae31f39029ceb55da08086315316e3ba` **und** gegen die veröffentlichte Prüfsummendatei des Release und installiert nur bei doppelter Übereinstimmung; für andere Architekturen installiert er nichts und sagt das; ist `gitleaks` vorhanden, tut er nichts; er blockiert nie (Kanal, kein Gate). Die Wendung "liegt beim Auftraggeber" bleibt als Stand davor stehen. An der Kette ändert der Hook nichts: Fehlt `gitleaks` trotz Hook, meldet D11 Lage C — der Hook ist Bereitstellung, die Kette bleibt das Prüfmittel. **Zweiter Nachtrag vom 2026-09-22 (Codex-Review am Pull Request #17 und statische Nachprüfung):** Zwei Behebungen am Hook: (1) `curl` läuft mit `-q` als erstem Parameter, damit keine `.curlrc` aus `CURL_HOME`, `XDG_CONFIG_HOME` oder `HOME` die Gegenstelle ändert; (2) liegt zum Prüfzeitpunkt, vor jedem Download, unter einem der Zielverzeichnisse (`/usr/local/bin`, `$HOME/.local/bin`) bereits ein Eintrag `gitleaks` — Datei, Verzeichnis oder Symlink —, der nicht als `gitleaks` im PATH ausführbar ist, lädt der Hook nichts herunter, ersetzt nichts und sagt das; D11 meldet dann Lage C, bis dort ein ausführbares `gitleaks` im PATH liegt. Die Aussage "ist `gitleaks` vorhanden, tut er nichts" aus dem ersten Nachtrag gilt damit auch für "vorhanden, aber nicht im PATH". Ein zweiter, gleichzeitiger Lauf des Hooks ist nicht abgesichert (`SessionStart` ist auf die Matcher `startup` und `resume` begrenzt); das ist Grenze, keine Zusicherung. Verifikation durch Static und Dynamic Software Tester auf einem anderen Modell, Runden und Restbefunde in `docs/uebergaben/2026-09-22_git-historie-starthook.md`, Nachtrag "nach dem Codex-Review". **Dritter Nachtrag vom 2026-09-22 (Codex-Review, dritter Lauf):** `curl` läuft ohne `SSLKEYLOGFILE` — der Hook löscht die Variable zu Beginn aus der Umgebung, sonst schriebe `curl` beim Herunterladen des Release-Archivs TLS-Sitzungsschlüssel an den dort genannten Pfad, auch bei einem fehlgeschlagenen Download; die Kandidaten `/usr/local/bin` und `$HOME/.local/bin` werden so geordnet, dass die im `PATH` stehenden zuerst geprüft und beschrieben werden, damit ein bereits installiertes Binary auffindbar ist und der Ersetzungsschutz keinen Fehlschlag dauerhaft macht. Anlass: Codex-Review, dritter Lauf, am Commit `59de8974bc6871e4e5e1ce179cc1b29d98739961`. Verifikation durch Static und Dynamic Software Tester auf einem anderen Modell. `docs/uebergaben/2026-09-22_abnahme-starthooks-und-codex-dritter-lauf.md`. Die Klasse "vererbte Umgebung oder Konfiguration lenkt einen Schreibzugriff in den Arbeitsbaum" ist damit am Codex-Review zum zweiten Mal gescheitert (erster Lauf `GIT_TRACE`, dritter Lauf `core.hooksPath` und `SSLKEYLOGFILE`); ein drittes Scheitern löst 3.4 aus. |
| E-F | Flacher Klon blockiert (G16) | (a); **Nachtrag vom 2026-09-22:** Der Beschaffungsweg `git fetch --unshallow` aus ADR 0002, 6.12.17 wird auf Delegation des Auftraggebers (Wortlaut: "Ich überlasse es dir, da du einen besseren Überblick hast", zur in der Übergabe vom 2026-09-22 vorgelegten Frage) als versionierter `SessionStart`-Hook `.claude/hooks/session-start-git-historie.sh` ausgeführt: Ist der Klon flach, holt er die Historie vom konfigurierten Remote `origin` des Klons nach; ist er es nicht, tut er nichts; er blockiert nie, schreibt ausschliesslich in `.git/` und nie in den Arbeitsbaum und lässt Zweige, HEAD und Index unberührt. An G16 ändert das nichts: Bleibt der Klon flach, meldet D20 Lage C `FEHLT=git-historie` — der Hook ist Bereitstellung, die Kette bleibt das Prüfmittel (Bau SecDevOps Engineer, Verifikation Static und Dynamic Software Tester auf einem anderen Modell; Übergabe `docs/uebergaben/2026-09-22_git-historie-starthook.md`). **Zweiter Nachtrag vom 2026-09-22 (Codex-Review am Pull Request #17, statische und dynamische Nachprüfung):** Die Zusicherung "lässt Zweige, HEAD und Index unberührt" hielt am Stand `bb6c1965fa271f7f1d28cc57d3c0fc192ad8cb15` nicht: `git fetch --unshallow origin` ohne Refspec verwendete die konfigurierte `remote.origin.fetch`-Refspec; eine nicht standardmässige Refspec hätte einen lokalen Zweig unter refs/heads/ geschrieben (Codex, P1). Die erste Behebung — explizite Refspec `+refs/heads/*:refs/remotes/origin/*` auf der Befehlszeile — trug nur die Hälfte: `git` zieht die konfigurierten Refspecs weiterhin als Refmap heran und schrieb im Messfall `+refs/heads/<zweig>:refs/heads/side` den lokalen Zweig `side` trotzdem (Dynamic Software Tester, Fall K-B2; Static Software Tester, Befund B-11 mit den Läufen F, I, J, darunter ein `forced update` über einen eigenen lokalen Commit). Zweite Behebung: zusätzlich `--refmap=''` an beiden Fetch-Aufrufen; erst explizite Refspec und leere Refmap zusammen tragen die Zusicherung. Der Beschaffungsweg lautet damit `git fetch --unshallow --refmap='' origin '+refs/heads/*:refs/remotes/origin/*'`: er holt alle Zweige der Gegenstelle als Remote-Tracking-Refs — nicht nur den ausgecheckten Zweig, was für D20 messbar mehr Commit-Objekte lokal verfügbar macht, etwa Merge-Commits von `main` — und, wie `git fetch` es vorsieht, Tags, die in die geholte Historie zeigen; alles unter `.git/`. Die git-eigenen Umgebungsvariablen der `GIT_DIR`-Familie, `GIT_SHALLOW_FILE` und alle mit dem Präfix `GIT_TRACE` löscht der Hook vor dem ersten `git`-Aufruf (Codex, P2). Nicht gelöscht werden `GIT_CONFIG_COUNT`, `GIT_CONFIG_KEY_n` und `GIT_CONFIG_VALUE_n`: Der Harness dieser Sitzungsumgebung setzt darüber `url.<...>.insteadOf` und `credential.interactive` (gemessen am 2026-09-22); eine darüber eingeschleuste `remote.origin.fetch`-Refspec wirkt wegen `--refmap=''` nicht mehr auf refs/heads/ (Static Software Tester, Läufe J und K). Die Zusicherung "Zweige unberührt" ist in dieser Einheit zweimal am Gegenstand gescheitert (Codex P1, dann K-B2/B-11); die dritte Messung nach 3.4 ist die letzte an diesem Kriterium. Verifikation und Restbefunde in `docs/uebergaben/2026-09-22_git-historie-starthook.md`, Nachtrag "nach dem Codex-Review". **Dritter Nachtrag vom 2026-09-22 (Codex-Review, dritter Lauf):** Der Fetch läuft zusätzlich mit `-c core.hooksPath=/dev/null`, damit kein Git-Hook des Klons — insbesondere kein `reference-transaction`-Hook — während des Nachholens läuft, und mit `--no-recurse-submodules`, damit bei bestückten Submodulen keine zweite Gegenstelle kontaktiert wird; der Beschaffungsweg lautet damit `git fetch --unshallow --no-recurse-submodules --refmap='' origin '+refs/heads/*:refs/remotes/origin/*'` unter `-c core.hooksPath=/dev/null`. Anlass: Codex-Review, dritter Lauf, am Commit `59de8974bc6871e4e5e1ce179cc1b29d98739961`. Verifikation durch Static und Dynamic Software Tester auf einem anderen Modell. `docs/uebergaben/2026-09-22_abnahme-starthooks-und-codex-dritter-lauf.md`. Die Klasse "vererbte Umgebung oder Konfiguration lenkt einen Schreibzugriff in den Arbeitsbaum" ist damit am Codex-Review zum zweiten Mal gescheitert (erster Lauf `GIT_TRACE`, dritter Lauf `core.hooksPath` und `SSLKEYLOGFILE`); ein drittes Scheitern löst 3.4 aus. |
| E-G | Laufzeit je Beendigungsversuch (G15, O-20) | (a) |
| E-H | Reichweite der Zusicherung, Voraussetzung Aufgabenliste (G9, O-23) | (a): Wortlaut befolgen und vorschreiben, dass jede Arbeitseinheit als Aufgabe geführt wird |
| E-I | Abnahmekriterium `R3-Q-001_gate_blockiert` | (a) präzisieren |
| E-J | Durchlass nach der Eskalation | (a): nur `Stop` und `SubagentStop`; `TaskCompleted` blockiert weiter |
| E-K | `Bash` zählt nicht als Schreibwerkzeug (G13) | (a), mit benannter Lücke bis R3-Q-005 |

Formweg wie beim Freigabe-Gate Schritt 4: entweder direkte Bearbeitung dieser Datei über einen Pull Request oder Anweisung an die nächste Sitzung mit dem exakten Wortlaut des Entscheids. Massgeblich ist der committete Stand; Urheber und Zeitpunkt belegt die Commit-Historie.

### Förmliche Freigabe der Entscheidpunkte E-A bis E-K (2026-09-07)

| | |
|---|---|
| **Vorgelegt** | 2026-09-02 mit `docs/uebergaben/2026-09-02_r3-q-001-entwurf-dod-gate.md` und den elf Entscheidpunkten E-A bis E-K (Tabelle darüber); vorgelegt zur Freigabe mit dem Pull Request #13 des Repositories `valITino/r3cosint`, Arbeitszweig `claude/r3-dod-gates-hooks-fn5hia`, Kopf `e922a57564175b38b6b0eb3ecd4615872c59a59e` |
| **Formweg** | **Merge des Pull Requests** — der erste der beiden in Abschnitt 10 genannten Formwege, unverändert. Der Text des Pull Requests sagt wörtlich: "Der Merge dieses Pull Requests gilt als foermliche Freigabe der Entscheidpunkte E-A bis E-K (ADR 0002, Abschnitt 10)" |
| **Merge-Commit** | `135e3614197a8150ad3d96fbf32eb0e893c9cbbc` |
| **Datum** | 2026-09-07, 06:39:39 UTC |
| **Auftraggeber (S-01)** | Merge durch das Konto des Repository-Eigentümers; Name nach offenem Entscheid E-11 nicht im Repository geführt |
| **Zugehöriger Merge im Methodik-Repository** | `valITino/r3coscrum`, Pull Request #8, Merge-Commit `2ec4bc2047d0cd940f38481277433086c69b13be`, 2026-09-07, 06:40:21 UTC |

**Damit sind die elf umgesetzten Optionen E-A bis E-K freigegeben**, wie sie in
der Tabelle darüber stehen; keine ist zurückgewiesen worden. Die Angaben zum
Merge sind der **Erhebung des Koordinators vom 2026-09-07** entnommen
(Fremdbeleg); diese Rolle hat den Merge nicht ausgeführt und nichts
nachgemessen.

**Die Abnahme des Gates ist davon getrennt und steht aus.** Die Freigabe der
Entscheidpunkte sagt, dass der Bau **so** gebaut werden durfte, wie er gebaut
worden ist. Sie sagt **nichts** darüber, ob das Prüfmittel seinen Massstab
erfüllt. Der Massstab ist das Abnahmekriterium aus 6.12.27 g in der Fassung von
**6.12.28 g**; Teil 1 ist erfüllt, Teil 2 ist ungeprüft, bis **Runde 12**
gelaufen ist. Die **Abnahmevorlage** wird erst danach geschrieben und hier
eingesetzt; die Abnahme selbst erteilt der Auftraggeber. **O-25** bleibt
unabhängig davon offen.

**Protokollvermerk zur Form** (Protocol Master, 4.2): Die förmliche Freigabe erfolgte
am 2026-09-07 über den ersten Formweg aus Abschnitt 10 — Merge des Pull Requests des
Arbeitszweigs, Merge-Commit `135e3614197a8150ad3d96fbf32eb0e893c9cbbc`; der PR-Text
nannte diese Bedeutung, der Auftraggeber hatte sie beim Merge vor sich. Urheber und
Zeitpunkt belegt der Merge-Commit in der Historie von `main` (Konto des
Repository-Eigentümers, Name nach E-11 nicht geführt). Übertragen aus der Erhebung
des Koordinators vom 2026-09-07 (Fremdbeleg), von dieser Rolle nicht nachgemessen;
die Abnahme des Gates bleibt getrennt, offen bis Runde 12.

### Abnahmevorlage für das DoD-Gate aus R3-Q-001 (vorgelegt am 2026-09-08)

Diese Vorlage schreibt der Software Architect, weil 6.12.28 j Punkt 12 die
Bedingung dafür als erfüllt feststellt. **Alle Läufe, Zahlen und Befunde, auf die
sie sich stützt, sind Fremdbeleg** von Static und Dynamic Software Tester auf
einem anderen Modell als die Umsetzung (3.4); diese Rolle hat nichts ausgeführt,
nichts nachgemessen und bestätigt nichts. Sie legt vor, sie nimmt nicht ab.

| | |
|---|---|
| **Vorgelegt am** | 2026-09-08 |
| **Gegenstand** | Abnahme des **Prüfmittels** aus R3-Q-001: `.claude/hooks/dod-gate.sh`, `.claude/hooks/dod-gate-terminierte-lagen.txt`, `scripts/dod-gate-selbsttest.sh` mit **262** Zusicherungen und **264** Messhüllen, `scripts/dod-gate-mutationen.txt` mit **262** Einträgen (250 `sed`, 12 `keine`) sowie die Festlegung in 6.12 samt den Nachträgen 6.12.23 bis 6.12.28 und der Prüftabelle 6.12.19 mit **263** Zeilen |
| **Nicht Gegenstand** | **O-25** bleibt offen und wird hier nicht mitentschieden. Die **Entscheidpunkte E-A bis E-K** sind seit dem 2026-09-07 durch Merge freigegeben (Unterabschnitt darüber) und stehen nicht erneut zur Wahl; Freigabe der Entscheidpunkte und Abnahme des Prüfmittels bleiben getrennt. Ebenfalls nicht Gegenstand: die Abnahme des Belegprüfers D20 (**O-15**), die harte Durchsetzung der Rollen-Schreibgrenzen (**R3-Q-005**) und die Freigabe des Grundgerüsts |
| **Massstab** | Das Abnahmekriterium aus 6.12.27 g in der Fassung von **6.12.28 g** |
| **Teil 1** | **erfüllt** (Fremdbeleg) |
| **Teil 2** | **nicht erfüllt** |
| **Grundlage der Vorlage** | **Nicht** ein bestandener Teil 2, sondern der in 6.12.28 g für genau diesen Fall **vorab** festgelegte Weg |
| **Entscheid des Auftraggebers** | **offen** (das Wort "offen" bleibt als Stand davor stehen) — **erteilt am 2026-09-08 durch Merge des Pull Requests #15, Merge-Commit `9870b0d115b8ef330a7c19777af5741093e4f0e9`, eingetragen am 2026-09-21; Einzelheiten in der Entscheidtabelle unten** |

**1. Weshalb Teil 2 nicht erfüllt ist, und was an seiner Stelle trägt.** Teil 2
verlangt, dass eine **Fremdmutationsrunde ohne blockierenden Befund** durchläuft.
**Runde 12 hatte einen blockierenden Befund**: `DT12-M14` erzeugte am Gate ein
falsches Grün — Rückgabewert 0 mit leerer Ausgabe, wo das unveränderte Gate mit
Rückgabewert 2 und dem Schlüssel `KETTE ausgabe-unlesbar` blockiert — und liess
dabei keine Zusicherung der Tabelle 6.12.19 fallen. Damit ist Teil 2 **nicht
erfüllt**, und diese Vorlage behauptet nichts anderes.

Getragen wird sie von dem Weg, den 6.12.28 g **vor** Runde 12 für genau diesen
Fall festgelegt hat: Ein falsches Grün aus Runde 12 wird **behoben**, **statisch
nachgeprüft** und mit einer **gezielten Wiederholung** der betroffenen
Fremdmutation belegt; **eine Runde 13 gibt es nicht**; was bleibt, ist
**dokumentierte Restlücke**, in 6.12.28 j benannt, im Backlog unter R3-Q-001 zu
führen und hier genannt. Alle vier Schritte sind als Fremdbeleg gemeldet
(6.12.28 j Punkte 4, 8, 9 und 10). Der Auftraggeber entscheidet damit über eine
Abnahme, die auf einem **vorab vereinbarten Ersatzweg** ruht, nicht auf einem
bestandenen Teil 2.

**2. Beleglage (Fremdbeleg, 6.12.28 j Punkte 8 bis 10).**

| Beleg | Inhalt |
|---|---|
| Teil 1 | 250 tabelleneigene Mutationen geprüft, **250 erkannt**, 0 nicht erkannt, 0 wirkungslos, 12 Einträge ohne Mutation mit zulässigem Grund; beide Modi enden mit Rückgabewert 0; Deckung in beide Richtungen, Kanal- und Prädikatabgleich, Schlüssel-, Gegenstands-, Grammatik- und Aussagendeckung, Pfaddeckung, Grammatikschwächungen und Aufrufstellendeckung ohne Abweichung |
| Gezielte Wiederholung von `DT12-M14` | Gegen die Mutanten-Kopie fallen `Z-262` und `Z-263`; am unveränderten Gate bestehen beide; am Gate selbst blockiert das Original mit Rückgabewert 2 und geschriebener Zählerdatei, während der Mutant mit Rückgabewert 0, leeren Ausgaben und ohne Zählerdatei durchlässt; im vollständigen Normallauf gegen den Mutanten genau zwei fallende Zusicherungen, keine weitere Kennung |
| Statische Nachprüfung | Gesamturteil **bestanden**, kein blockierender Befund nach 6.12.28 g; vier eigene Läufe; alle Zahlen aus 6.12.28 j Punkt 6 und die Deckungszahlen eigenständig bestätigt; die fail-closed-Wachen des Deckungsblocks ausgelöst statt nur gelesen; Gate-Diff genau die vier Meldungszeilen aus 6.12.28 e |
| Nachrangiger Befund `SNP-01` | Die erläuternde Begründung zur Mutation von `Z-252` traf nicht zu (18 Schwächungen über die Elemente 1 bis 9 statt "die Elemente 3 bis 9"); Wirkung und `sed`-Ausdruck unverändert, am 2026-09-08 in ADR und Mutationsdatei berichtigt (6.12.28 j Punkt 10) |

**3. Restlücken — benannt, nicht geschlossen** (6.12.28 j Punkt 5; als Posten im
Backlog unter R3-Q-001 zu führen, was der Product Owner tut, nicht diese Rolle):

1. **Die Grammatik der D19-Zeile (6.12.8) ist nicht am Gegenstand gedeckt.**
   Geschlossen ist die **eine** belegte Verstossform (`Z-262`, `Z-263`); die
   Menge der Verstossformen deckt kein Schwächungslauf. Die systematische
   Antwort wäre ein Schwächungslauf über das D19-Muster nach dem Muster von
   6.12.28 c — nach 6.12.28 g in dieser Einheit ausdrücklich **nicht** zu bauen.
2. **Zeichen im Inneren eines Wortliterals** werden nicht einzeln geschwächt.
3. **Eine Alternative mit einem bestimmten fremden Literal** ist nur als Klasse
   erfasst; für die Lage-Marke fängt die Alternativendeckung (`Z-253`, `Z-254`)
   das ab, für die D19-Grammatik besteht kein Gegenstück.

Die Punkte 2 und 3 sind **die beiden in 6.12.28 c benannten Grenzen** — erste
Grenze: Erstes und letztes Zeichen eines Wortliterals sind die Nahtstellen zum
Nachbarelement und werden geschwächt, das Wortinnere nicht; zweite Grenze: `U5`
erfasst die Klasse "jedes Wort", nicht jedes einzelne fremde Literal. Beide sind
vor Runde 12 ausgesprochen worden, nicht nachträglich. Hinzu kommen die drei im
Nachtrag zu 6.12.28 f Punkt 11 benannten Grenzen: `Z-260` erreicht keine Zeile
ohne Zahl an erster Stelle; die Blockdeckung ist selbst nicht mutationsgedeckt;
und sie gilt im Normallauf, nicht im isolierten Einzelfall-Lauf.

**4. Grenzen, die die Prüfrollen an ihrer eigenen Prüfung benannt haben**
(6.12.28 j Punkt 11, unverändert übernommen): Die **wortlautgenaue Feindeckung**
der Aussagen- und Grammatikkürzel ist nicht Zeile für Zeile nachgezogen worden —
übernommen ist die vom Selbsttest gemeldete Deckung, geprüft ist also, **dass**
er sie meldet, nicht, dass jede einzelne Zuordnung wörtlich trägt. Und es ist
**kein Lauf gegen einen unabhängig geklonten Baum** erfolgt. Wer abnimmt, nimmt
mit diesen beiden Einschränkungen ab.

**5. Zwei bekannte Lücken ausserhalb dieser Einheit.**

- **Das Gate misst das Recht einer Rolle, nicht ihre Fähigkeit.** Beurteilt wird
  das `tools`-Feld der Rollendatei: Eine Rolle mit `Bash` und ohne `Edit` oder
  `Write` könnte schreiben und wird trotzdem nicht geprüft (6.12.14). Diese
  Lücke ist mit dem Entscheid **E-K** ausdrücklich **benannt freigegeben**
  worden und bleibt bis **R3-Q-005** (Etappe 0) bestehen. Sie ist mit dieser
  Abnahme **nicht** geschlossen.
- **Das Gate stützt sich auf die ganze Kette und damit auf den nicht
  abgenommenen Belegprüfer D20** (**O-15**). Ein Befund von D20 blockiert damit
  jede Arbeitseinheit, obwohl das Werkzeug nach 3.4 abgebrochen und nicht
  abgenommen ist und seine Selbstauskunft die Liste ihrer Grenzen ausdrücklich
  für unvollständig erklärt. Die Abnahme des Gates ist **keine** Abnahme von
  D20; O-15 bleibt offen und ist vor der Freigabe des Grundgerüsts fällig.

**6. Formweg der Abnahme**, wie ihn dieser Abschnitt seit dem Freigabe-Gate
Schritt 4 führt — zwei Wege, sonst keiner:

1. **Merge des Pull Requests** dieses Arbeitszweigs, wobei der Text des Pull
   Requests ausdrücklich sagen muss, dass der Merge als Abnahme des DoD-Gates
   aus R3-Q-001 gilt; Beleg ist der Merge-Commit mit seiner vollständigen,
   40-stelligen Prüfsumme.
2. **Anweisung an die nächste Sitzung im exakten Wortlaut**; die Sitzung
   überträgt den Wortlaut in diesen Abschnitt, Urheber und Zeitpunkt belegt die
   Commit-Historie des Arbeitszweigs.

Massgeblich ist der committete Stand. Die Abnahme kann **verweigert** oder **mit
Auflagen** erteilt werden; eine Auflage ist als Fortschreibung dieses ADR
umzusetzen, nicht stillschweigend.

| | |
|---|---|
| **Entscheid des Auftraggebers** | *offen* (das Wort "offen" bleibt als Stand davor stehen) — **erteilt, ohne Auflagen** |
| **Auflagen** | *offen* — **keine: kein Kommentar, kein Review und keine Anweisung; der Pull Request wurde unverändert gemergt** |
| **Datum der Abnahme** | *offen* — **2026-09-08, 09:51:49 UTC (Zeitstempel des Merge-Commits)** |
| **Formweg und Beleg** | *offen — Merge-Commit oder Wortlaut der Anweisung* — **erster Formweg aus Punkt 6: Merge des Pull Requests #15 des Repositories `valITino/r3cosint`, dessen Text ausdrücklich sagt: "Der Merge dieses Pull Requests gilt als Erteilung der Abnahme des Prüfmittels aus R3-Q-001 in dem Umfang, den die Abnahmevorlage in Abschnitt 10 beschreibt — Gate, Lagenliste, Selbsttest, Mutationsdatei und die Festlegung in 6.12 samt Nachträgen. Wer die Abnahme nicht erteilen oder sie mit Auflagen verbinden will, merget diesen Pull Request nicht, sondern hinterlässt den Entscheid als Kommentar oder als Anweisung an die nächste Sitzung im exakten Wortlaut."; Merge-Commit `9870b0d115b8ef330a7c19777af5741093e4f0e9`, Eltern `7e72a410937badcc89c55f6ecf9377a2c5408562` (main) und `71596aae9b6fd20324c7e16863ca18a16b57794a` (Kopf des Arbeitszweigs `claude/o-27-umsetzen-qo9pef`)** |
| **Auftraggeber (S-01)** | Name nach offenem Entscheid E-11 nicht im Repository geführt — **Merge durch das Konto des Repository-Eigentümers** |
| **Zugehöriger Merge im Methodik-Repository** | `valITino/r3coscrum`, Pull Request #9, Merge-Commit `9c28499252ab3f42a96dc43bf096c3a6353ce0cb`, 2026-09-08, 09:51:04 UTC |

**7. Was die Abnahme bedeutet — und was nicht.** Sie bedeutet, dass das
Prüfmittel seinen Massstab in der Fassung von 6.12.28 g erfüllt, mit Teil 2 auf
dem Ersatzweg und mit den Restlücken aus Punkt 3 und den Grenzen aus Punkt 4.
Sie bedeutet **nicht** die Erledigung von **O-25** — das ist am 2026-09-03 entschieden (Abschnitt 8) und wird hier nur als nicht umfasst genannt —, **nicht** die Abnahme von
D20 (**O-15**), **nicht** die Schliessung der Lücke aus **E-K** und **R3-Q-005**
und **nicht** die Freigabe des Grundgerüsts. Am Verhältnis zu 5.2 ändert sie
nichts: Das Gate steht an keiner Stelle zwischen Freigabe und Ausführung. Die
Nachführung von Changelog und Nachweisverzeichnis nach der Abnahme liegt beim
Protocol Master (4.2, 6.6), die Aufnahme der Restlücken in den Backlog beim
Product Owner.

### Abnahme des DoD-Gates aus R3-Q-001 — erteilt am 2026-09-08, eingetragen am 2026-09-21

| | |
|---|---|
| **Vorgelegt** | 2026-09-08 mit der Abnahmevorlage oben und `docs/uebergaben/2026-09-07_r3-q-001-o-27-deckung-am-gegenstand.md`; vorgelegt zur Abnahme mit dem Pull Request #15 des Repositories `valITino/r3cosint`, Arbeitszweig `claude/o-27-umsetzen-qo9pef` |
| **Formweg** | **Merge des Pull Requests** — der erste der beiden in Punkt 6 genannten Formwege. Der Text des Pull Requests sagt wörtlich: "Der Merge dieses Pull Requests gilt als Erteilung der Abnahme des Prüfmittels aus R3-Q-001 in dem Umfang, den die Abnahmevorlage in Abschnitt 10 beschreibt — Gate, Lagenliste, Selbsttest, Mutationsdatei und die Festlegung in 6.12 samt Nachträgen. Wer die Abnahme nicht erteilen oder sie mit Auflagen verbinden will, merget diesen Pull Request nicht, sondern hinterlässt den Entscheid als Kommentar oder als Anweisung an die nächste Sitzung im exakten Wortlaut." |
| **Merge-Commit** | `9870b0d115b8ef330a7c19777af5741093e4f0e9`, Eltern `7e72a410937badcc89c55f6ecf9377a2c5408562` (main) und `71596aae9b6fd20324c7e16863ca18a16b57794a` (Kopf des Arbeitszweigs) |
| **Datum** | 2026-09-08, 09:51:49 UTC |
| **Auftraggeber (S-01)** | Merge durch das Konto des Repository-Eigentümers; Name nach offenem Entscheid E-11 nicht im Repository geführt |
| **Zugehöriger Merge im Methodik-Repository** | `valITino/r3coscrum`, Pull Request #9, Merge-Commit `9c28499252ab3f42a96dc43bf096c3a6353ce0cb`, 2026-09-08, 09:51:04 UTC |
| **Kommentare, Reviews, Auflagen** | **0 Kommentare, 0 Reviews, keine Auflagen** — der Pull Request wurde unverändert gemergt |
| **Eingetragen am** | 2026-09-21 |

**Was die Abnahme umfasst.** Der Gegenstand ist derselbe wie in der Abnahmevorlage oben: das Prüfmittel aus R3-Q-001 — `.claude/hooks/dod-gate.sh`, `.claude/hooks/dod-gate-terminierte-lagen.txt`, `scripts/dod-gate-selbsttest.sh` mit 262 Zusicherungen und 264 Messhüllen, `scripts/dod-gate-mutationen.txt` mit 262 Einträgen (250 `sed`, 12 `keine`) sowie die Festlegung in ADR 0002, 6.12 samt den Nachträgen 6.12.23 bis 6.12.28 und der Prüftabelle 6.12.19 mit 263 Zeilen.

**Was sie NICHT umfasst.** **O-25** bleibt offen. *Berichtigung vom 2026-09-22 (Befund des Codex-Reviews am Pull Request r3coscrum#10): O-25 ist am 2026-09-03 entschieden (Abschnitt 8) und nicht Gegenstand dieser Abnahme; die Wendung "bleibt offen" ist seit dem 2026-09-07 ohne benannten Grund fortgeschrieben worden und bleibt als Stand davor stehen (6.1.2).* Die Abnahme des Belegprüfers **D20** ist damit nicht erteilt (**O-15**); sie ist vor der Freigabe des Grundgerüsts fällig. Die harte Durchsetzung der Rollen-Schreibgrenzen (**R3-Q-005**) bleibt offen, und die Lücke aus **E-K** bleibt bestehen. Die **Freigabe des Grundgerüsts** ist mit dieser Abnahme nicht erteilt. Die Entscheidpunkte **E-A bis E-K** waren bereits am 2026-09-07 durch Merge freigegeben (Unterabschnitt darüber) und standen hier nicht erneut zur Wahl.

**Massstab und Ergebnis, ohne Beschönigung.** Das Abnahmekriterium aus ADR 0002, 6.12.27 g in der Fassung von **6.12.28 g** hat zwei Teile. **Teil 1 ist erfüllt** (Fremdbeleg). **Teil 2 ist NICHT erfüllt** — er verlangt eine Fremdmutationsrunde ohne blockierenden Befund, und **Runde 12 hatte einen**: `DT12-M14`, ein falsches Grün an der Grammatik der D19-Zeile. Getragen hat die Abnahme nicht ein bestandener Teil 2, sondern der in **6.12.28 g** für genau diesen Fall **vorab** festgelegte Weg: Der Befund wurde behoben, statisch nachgeprüft und mit einer gezielten Wiederholung belegt; eine Runde 13 gibt es nicht. Mit abgenommen sind damit die **drei Restlücken** (ADR 0002, 6.12.28 j Punkt 5: die Grammatik der D19-Zeile ist nicht am Gegenstand gedeckt; Zeichen im Inneren eines Wortliterals werden nicht einzeln geschwächt; eine Alternative mit einem bestimmten fremden Literal ist nur als Klasse erfasst), die **Grenzen der Prüfrollen an ihrer eigenen Prüfung** (keine wortlautgenaue Feindeckung Zeile für Zeile; kein Lauf gegen einen unabhängig geklonten Baum) und die **beiden bekannten Lücken ausserhalb dieser Einheit** (das Gate misst das Recht einer Rolle, nicht ihre Fähigkeit — E-K und R3-Q-005; das Gate stützt sich auf den nicht abgenommenen Belegprüfer D20 — O-15). Diese Grenzen sind mit dieser Abnahme **benannt und mitgetragen**, nicht geschlossen.

**Protokollvermerk zur Form** (Protocol Master, 4.2): Formweg 1 — Merge des Pull Requests, Beleg der Merge-Commit `9870b0d115b8ef330a7c19777af5741093e4f0e9`. Die Angaben zum Merge sind der **Erhebung des Koordinators vom 2026-09-21** entnommen (`git` und GitHub-API) — Fremdbeleg, von dieser Rolle nicht nachgemessen. Der Eintrag erfolgt 13 Tage nach dem Merge; nach den drei Folge-Commits vom 2026-09-08 — `c06ed44337b297a70fcf33ae2410b0fd69503445` (Merge des automatisch eröffneten Eingangs-Pull-Requests #16 durch das Konto des Repository-Eigentümers, Repository `valITino/r3cosint`) sowie `05d0cfc97d665098c743f40ee037c5fd8e2f06be` und `b7345b31df6f7e598bc29a1767ab124ad7df5d10` (Nachweis-Commits der Automatik, Repository `valITino/r3coscrum`) — liegt auf keinem Zweig der beiden Repositories bis zum 2026-09-20 ein weiterer Commit (Erhebung des Koordinators mit `git log --all`). `main` war seit dem Merge von Pull Request #15 an D20 rot — Ursache war der fehlende Zusatz "ADR 0002, " an einer historischen Übergabedatei —; der Koordinator hat die Stelle berichtigt.

### Abnahme der beiden Starthooks E-E und E-F — erteilt und eingetragen am 2026-09-22

| | |
|---|---|
| **Vorgelegt** | 2026-09-22 mit `docs/uebergaben/2026-09-22_weisung-r3-q-010-freigabe-gitleaks-starthook.md` und `docs/uebergaben/2026-09-22_git-historie-starthook.md`; vorgelegt zur Abnahme mit dem Pull Request #17 des Repositories `valITino/r3cosint` |
| **Formweg** | **Merge des Pull Requests** — der erste der beiden in Punkt 6 genannten Formwege. Wortlaut im Text des Pull Requests: "Der Merge dieses Pull Requests gilt als **Abnahme der beiden Starthooks** im Umfang der beiden Übergaben vom 2026-09-22, einschliesslich der dort benannten, nicht behobenen Restbefunde, und als **Bestätigung des Eintrags** der Weisungen und der beiden delegierten Entscheide (Lesart zu R1; Nachholen der Git-Historie)." Damit gilt der Merge als Abnahme der beiden Starthooks `session-start-gitleaks.sh` (E-E) und `session-start-git-historie.sh` (E-F) im Umfang der beiden genannten Übergaben vom 2026-09-22, einschliesslich der dort benannten, nicht behobenen Restbefunde, und zugleich als Bestätigung des Eintrags der Weisungen vom 2026-09-21 und 2026-09-22 sowie der beiden dort delegierten Entscheide (Lesart zu R1, Backlog Punkt 19; Nachholen der Git-Historie) |
| **Merge-Commit** | `a462aacfcedaa5ae62e92b14335f9db6718499be` |
| **Datum** | 2026-09-22, 11:18:43 UTC (13:18:43 MESZ) |
| **Abgenommener Stand des Zweigs** | `59de8974bc6871e4e5e1ce179cc1b29d98739961` |
| **Auftraggeber (S-01)** | Merge durch das Konto des Repository-Eigentümers; Name nach offenem Entscheid E-11 nicht im Repository geführt |
| **Zugehöriger Merge im Methodik-Repository** | `valITino/r3coscrum`, Pull Request #10, Merge-Commit `494409cf431e447ef26ce18f99832e467ec8a08d`, 2026-09-22, 13:20:36 MESZ |
| **Kommentare, Reviews, Auflagen** | Kein Kommentar und kein Review des Auftraggebers, keine Auflagen — der Pull Request wurde unverändert gemergt. Daneben Reviews des Code-Review-Bots (Codex) mit elf Threads: sechs aus dem ersten und zweiten Lauf vor dem Merge beantwortet und aufgelöst; fünf aus dem dritten Lauf eine Minute vor dem Merge, davon einer (Nachweisverzeichnis nach Squash) nach dem Merge beantwortet und aufgelöst, die vier Hook-Befunde beim Merge unbeantwortet und in der Folgeeinheit behoben |
| **Eingetragen am** | 2026-09-22 |

**Was die Abnahme umfasst.** Die beiden Starthooks `session-start-gitleaks.sh` (E-E) und `session-start-git-historie.sh` (E-F), im Umfang der beiden Übergaben vom 2026-09-22 (`docs/uebergaben/2026-09-22_weisung-r3-q-010-freigabe-gitleaks-starthook.md`, `docs/uebergaben/2026-09-22_git-historie-starthook.md`) einschliesslich der dort benannten, nicht behobenen Restbefunde. Zugleich gilt der Merge als Bestätigung des Eintrags der Weisungen vom 2026-09-21 und 2026-09-22 und der beiden dort delegierten Entscheide (Lesart zu R1, Backlog Punkt 19; Nachholen der Git-Historie).

**Was sie NICHT umfasst.** **O-25** (entschieden am 2026-09-03, Abschnitt 8), der Belegprüfer **D20** (**O-15**), **R3-Q-005**, die **Freigabe des Grundgerüsts**, die offenen Punkte **12, 15 und 20** des Backlogs sowie **O-28** (bleibt bedingt offen). Die **Abnahme des DoD-Gates** vom 2026-09-08 (Merge des Pull Requests #15, Merge-Commit `9870b0d115b8ef330a7c19777af5741093e4f0e9`) wird durch diesen Eintrag **weder erweitert noch berührt**.

**Ohne Beschönigung.** Eine Minute vor dem Merge, um 11:17:44 UTC, hat der Codex-Review am Commit `59de8974bc6871e4e5e1ce179cc1b29d98739961` vier weitere P2-Befunde an den beiden Hooks gemeldet: `core.hooksPath` lässt beim Fetch einen `reference-transaction`-Hook laufen; `fetch.recurseSubmodules` holt Submodul-Remotes; `SSLKEYLOGFILE` lässt `curl` TLS-Geheimnisse in den Arbeitsbaum schreiben; ein Installationsziel ausserhalb des `PATH` macht den Fehlschlag mit dem Ersetzungsschutz dauerhaft. Dazu ein fünfter Befund zum Nachweisverzeichnis, der vor dem Merge nicht behebbar war, weil es erst durch den Arbeitsablauf nach dem Merge erzeugt wird. Diese Abnahme umfasst die vier Befunde an den Hooks **nicht** als behoben; sie werden in der laufenden Einheit behoben und geprüft (`docs/uebergaben/2026-09-22_abnahme-starthooks-und-codex-dritter-lauf.md`); ob sie als eigener Pull Request vorgelegt werden, entscheidet der Auftraggeber.

**Protokollvermerk zur Form** (Protocol Master, 4.2): Formweg 1 — Merge des Pull Requests, Beleg der Merge-Commit `a462aacfcedaa5ae62e92b14335f9db6718499be`. Die Angaben zum Merge, zu den Zeitstempeln und zu den fünf Befunden des Codex-Reviews sind der Weisung des Koordinators an diese Einheit entnommen — Fremdbeleg, von dieser Rolle nicht nachgemessen.

### Abnahme von R3-Q-010 — E4, die beiden PreToolUse-Gates und ihr Prüfmittel — erteilt und eingetragen am 2026-09-23

| | |
|---|---|
| **Vorgelegt** | 2026-09-23 mit den drei Übergaben `docs/uebergaben/2026-09-23_e4-1-pruefmittel-pretooluse-gates.md`, `docs/uebergaben/2026-09-23_e4-2-prototyp-gate-erkennungsluecken.md` und `docs/uebergaben/2026-09-23_e4-3-raender-st-09-st-13-grenzen.md`; vorgelegt zur Abnahme mit dem Pull Request #21 des Repositories `valITino/r3cosint`, Arbeitszweig claude/happy-johnson-t0yqlo |
| **Formweg** | **Merge des Pull Requests** — der erste der beiden in ADR 0002, Abschnitt 10, Punkt 6 genannten Formwege. Wortlaut im Text des Pull Requests #21: "**Was der Merge bedeutet:** Abnahme von R3-Q-010 im Umfang der drei Übergaben vom 2026-09-23 einschliesslich der dort benannten Restbefunde (erster Formweg, ADR 0002, Abschnitt 10). Restbefunde, nicht behoben: DT-E43-4 (deno eval, node --eval, bun -e an beiden Gates nicht erkannt, Parität besteht), Preis P38, aus E4.1 und E4.2 NEU-1, NEU-4, N-DT-1, R-1/E-1, DST-E42-N1; dazu die Prüfstand-Fälle, über die der Software Architect als Fortschreibung von 6.13 c entscheidet. Nicht Gegenstand: E3, Grundgerüst, R3-Q-005, D20 (O-15)." Damit gilt der Merge als Abnahme von R3-Q-010 — den beiden PreToolUse-Gates `.claude/hooks/block-main-write.sh` und `.claude/hooks/block-prototype-import.sh` samt dem Prüfmittel `scripts/pretooluse-gates-selbsttest.sh` — im Umfang der drei genannten Übergaben vom 2026-09-23, einschliesslich der dort benannten, nicht behobenen Restbefunde |
| **Merge-Commit** | `9a84b9ccd1ecb81b19739f64defc5881e83e2db5`, Eltern `b60c82041799837e2714551d6dcb05c3552b16bd` (main) und `28b9ac18a046e95e21b606214ed16b62b0695e0e` (Kopf des Arbeitszweigs) |
| **Datum** | 2026-09-23, 12:47:58 UTC (14:47:58 MESZ) |
| **Abgenommener Stand des Zweigs** | `28b9ac18a046e95e21b606214ed16b62b0695e0e` |
| **Auftraggeber (S-01)** | Merge durch das Konto des Repository-Eigentümers; Name nach offenem Entscheid E-11 nicht im Repository geführt |
| **Zugehöriger Merge im Methodik-Repository** | `valITino/r3coscrum`, Pull Request #12, Merge-Commit `cb838ecd35baba30fb04ab64300e501ab55ed0b6`, 2026-09-23, 12:48:24 UTC (14:48:24 MESZ), Kopf des dortigen Zweigs `19b395101e1843561c5b02ed18f4b475dc36ee42` |
| **Kommentare, Reviews, Auflagen** | **0 Kommentare, 0 Reviews, 0 Review-Threads, keine Auflagen** (GitHub-API; die leere Review-Liste umfasst auch ein allfälliges Review des Code-Review-Bots) — der Pull Request wurde unverändert gemergt: Der zweite Elternteil des Merge-Commits ist der Kopf des Arbeitszweigs `28b9ac18a046e95e21b606214ed16b62b0695e0e` (git) |
| **Bestätigung über den zweiten Formweg** | Sitzungsauftrag vom 2026-09-23, Wortlaut: "Abnahme von R3-Q-010 eintragen wie am 2026-09-21 beim DoD-Gate: ADR 0002 Abschnitt 10 und 6.13 Status-Block, CLAUDE.md Statuszeile, Backlog-Eintrag R3-Q-010 auf "abgenommen" mit Merge-Commit 9a84b9ccd1ecb81b19739f64defc5881e83e2db5 (Methodik cb838ecd35baba30fb04ab64300e501ab55ed0b6), ohne Auflagen, im Umfang der drei Übergaben vom 2026-09-23 einschliesslich Restbefunde." |
| **Eingetragen am** | 2026-09-23 |

**Was die Abnahme umfasst.** Die sieben Abnahmekriterien von R3-Q-010 — `R3-Q-010_prototyp_gate_pfadformen`, `R3-Q-010_prototyp_gate_richtungsgleichheit`, `R3-Q-010_prototyp_gate_schreibwirkung`, `R3-Q-010_gates_unlesbare_eingabe`, `R3-Q-010_pruefmittel_je_gate`, `R3-Q-010_main_gate_fremdbelegt`, `R3-Q-010_benannte_grenzen` —, die beiden Gates `.claude/hooks/block-main-write.sh` und `.claude/hooks/block-prototype-import.sh` am abgenommenen Stand sowie das Prüfmittel `scripts/pretooluse-gates-selbsttest.sh` mit 258 Fällen, 19 Mutationen und 23 Fallklassen (beide Modi Rückgabewert 0). Mit demselben Merge sind die Nachträge E4.1, E4.2, E4.3 und der E4.3-Nachtrag in ADR 0002, 6.13 samt ADR 0002, Abschnitt 9 sowie die Ergänzung der Hook-Regel in `.claude/rules/claude-konfiguration.md` auf main gelangt; die drei Übergaben führen sie als Nachführung der jeweiligen Einheit. Dass der Merge sie mitbestätigt, ist eine Schlussfolgerung dieser Rolle aus dem gemergten Stand (Kopf `28b9ac18a046e95e21b606214ed16b62b0695e0e`) und nicht Wortlaut des Pull Requests, der allein die drei Übergaben samt Restbefunden nennt. Je Einheit (E4.1, E4.2, E4.3) lag die Verifikation bei Static und Dynamic Software Tester auf einem anderen Modell als die Umsetzung (3.4).

**Was sie NICHT umfasst.** **O-25** (entschieden am 2026-09-03, ADR 0002, Abschnitt 8), der Belegprüfer **D20** (**O-15**), **R3-Q-005**, die **Freigabe des Grundgerüsts**, **O-28** (bleibt bedingt offen) sowie die offenen Punkte **12, 15 und 20** des Backlogs und **E3**. Die **Abnahme des DoD-Gates** vom 2026-09-08 (Merge-Commit `9870b0d115b8ef330a7c19777af5741093e4f0e9`) und die **Abnahme der beiden Starthooks** vom 2026-09-22 (Merge-Commit `a462aacfcedaa5ae62e92b14335f9db6718499be`) werden durch diesen Eintrag weder erweitert noch berührt.

**Ohne Beschönigung.** Der Pull Request benennt sieben Restbefunde, nicht behoben: `DT-E43-4` (`deno eval`, `node --eval` und `bun -e` an beiden Gates nicht erkannt, Parität zwischen den Gates besteht), `P38` sowie aus E4.1 und E4.2 `NEU-1`, `NEU-4`, `N-DT-1`, `R-1/E-1` und `DST-E42-N1`; diese Abnahme umfasst sie nicht als behoben. Die Prüfstand-Fälle ZF9, ZF10a bis ZF10d und L01 bis L16, im Wortlaut des Pull Requests noch der Entscheidung überlassen, hat der Software Architect noch in derselben Einheit, im Anschluss an den Merge, als Fortschreibung von ADR 0002, 6.13 c entschieden: L01 bis L09 als belegte Lücken in drei Posten unter R3-Q-010, ZF10a, ZF10b, ZF10d und L10 bis L16 als Grenze, ZF9 und ZF10c als gewolltes Verhalten. Die drei Posten sind neue Arbeit an den Gates, keine Nacharbeit am abgenommenen Umfang, und von dieser Abnahme **nicht** mitumfasst. Die Verifikation je Einheit ist Fremdbeleg dieser Rolle: Sie ist in den drei Übergaben vom 2026-09-23 dokumentiert, von dieser Rolle nicht nachgemessen (3.4).

**Protokollvermerk zur Form** (Protocol Master, 4.2): Formweg 1 — Merge des Pull Requests, Beleg der Merge-Commit `9a84b9ccd1ecb81b19739f64defc5881e83e2db5`. Die Angaben zum Merge, zu den Zeitstempeln und zu den Folge-Commits sind der Erhebung des Koordinators mit `git` und der GitHub-API entnommen — Fremdbeleg, von dieser Rolle nicht nachgemessen. Nach dem Merge folgten auf `main` im Repository `valITino/r3cosint` die Commits `dd1604d37b6d76ab44c087d1b12a870e3c8d0005` (Eingang Methodik, Automatik, 12:48:34 UTC) und `8f278e0b34d58c9070618edac6f17dcb04077437` (Merge des automatisch eröffneten Eingangs-Pull-Requests #22, 12:48:50 UTC); im Repository `valITino/r3coscrum` folgte `716ffd46f38cca563e8648e0790095db83f421d6` (Nachweis-Commit der Automatik, 12:49:02 UTC). `make dod` auf dem unveränderten Stand `8f278e0b34d58c9070618edac6f17dcb04077437` endete am 2026-09-23 in der erwarteten Form (drei terminierte Lagen C D7, D10, D12; D20 und D11 A_OK; D19 OHNE_BEFUND; Rückgabewert 2) — `main` war an D20 grün (Erhebung des Koordinators).

**Bestätigung des Eintrags (Nachtrag vom 2026-09-24).** Der Merge des Pull Requests #23 des Repositories `valITino/r3cosint` am 2026-09-24 (Merge-Commit `3e5caf71b2bca97b7f9764a19841025875974df7`, siehe den Eintrag zur Freigabe von E3 weiter unten in diesem Abschnitt) gilt nach dem Wortlaut des Pull Requests auch als "Bestätigung des Abnahmeeintrags zu R3-Q-010" (wörtliches Teilzitat aus dem Absatz "Was der Merge bedeutet" im Text des Pull Requests #23). Bestätigt ist der Eintrag in der Fassung des Commits `bf45760836124d87b3e71c3882cf1ebfffe153da`; bis zum gemergten Kopf `9ffbab7be8e8c4285624bd71570f88278355f12d` ist er nicht mehr geändert worden (Erhebung des Koordinators mit `git`). Die Abnahme selbst ist am 2026-09-23 erteilt; die Bestätigung ändert an Umfang, Restbefunden und dem, was nicht umfasst ist, nichts.

### Freigabe von E3 (R3-Q-011) — Umfang, Schnitt und Reihenfolge — erteilt und eingetragen am 2026-09-24

| | |
|---|---|
| **Vorgelegt** | 2026-09-24 mit der Übergabe `docs/uebergaben/2026-09-23_e3-dor.md` (Einheit vom 2026-09-23, abgeschlossen 2026-09-24) und der Festlegung in ADR 0002, 6.14, beide mit dem Commit `4ef9b65b82cd30aae702d17700d3a8ed4dc5ef9a` vom 2026-09-24; vorgelegt zur Freigabe mit dem Pull Request #23 des Repositories `valITino/r3cosint`, eröffnet am 2026-09-24, Arbeitszweig claude/wizardly-hypatia-239hsf |
| **Formweg** | **Merge des Pull Requests** — der erste der beiden in ADR 0002, Abschnitt 10, Punkt 6 genannten Formwege. Wortlaut im Text des Pull Requests #23: "**Was der Merge bedeutet:** Freigabe des Umfangs von E3 (R3-Q-011), des Schnitts E3.1 bis E3.3 und der Reihenfolge E3.1, E3.2, E3.3, dann Grundgerüst (erster Formweg, ADR 0002, Abschnitt 10; ADR 0002, 6.14 g; Backlog, offener Punkt 22) — und Bestätigung des Abnahmeeintrags zu R3-Q-010. Bis zum Merge bleibt R3-Q-011 ready mit Vorbehalt und wird nicht gezogen." |
| **Merge-Commit** | `3e5caf71b2bca97b7f9764a19841025875974df7`, Eltern `8f278e0b34d58c9070618edac6f17dcb04077437` (main) und `9ffbab7be8e8c4285624bd71570f88278355f12d` (Kopf des Arbeitszweigs, zugleich `head.sha` des Pull Requests, also unverändert gemergt) |
| **Datum** | 2026-09-24, 04:57:15 UTC (06:57:15 MESZ) |
| **Freigegebener Stand des Zweigs** | `9ffbab7be8e8c4285624bd71570f88278355f12d` |
| **Auftraggeber (S-01)** | Merge durch das Konto des Repository-Eigentümers; Name nach offenem Entscheid E-11 nicht im Repository geführt |
| **Zugehöriger Merge im Methodik-Repository** | `valITino/r3coscrum`, Pull Request #13, Merge-Commit `33bb5dfa18193ce25fc861c53d53b78b265fddcf`, 2026-09-24, 06:05:30 UTC (08:05:30 MESZ), Kopf des dortigen Zweigs `336157a08c31e3eb12c2f00bf8fc8973c3a16c44` |
| **Kommentare, Reviews, Auflagen** | **0 Kommentare, 0 Reviews, 0 Review-Threads, keine Auflagen** (GitHub-API; die leere Review-Liste umfasst auch ein allfälliges Review des Code-Review-Bots) — der Pull Request wurde unverändert gemergt: Der zweite Elternteil des Merge-Commits ist der Kopf des Arbeitszweigs `9ffbab7be8e8c4285624bd71570f88278355f12d` (git) |
| **Weisung über den zweiten Formweg** | Sitzungsauftrag vom 2026-09-24, Wortlaut: "E3.1 und der Bau von E3.2 laufen in einer Session. Der Versuch R3-Q-011_regel_im_startkontext steht damit zu Beginn von E3.3 vor dem Kontrollversuch, wie ADR 0002, 6.14 g es für den noch nicht erledigten Versuch vorsieht. Fällt er negativ aus, nehme ich eine Änderung an der Skill in Kauf. Die drei Posten unter R3-Q-010 und O-29 kommen nach E3.3, vor der Freigabe des Grundgerüsts." |
| **Bestätigung über den zweiten Formweg** | Sitzungsauftrag vom 2026-09-24, Wortlaut: "Freigabe von Umfang, Schnitt und Reihenfolge von E3 durch den Merge von Pull Request #23 eintragen, wie am 2026-09-23 die Abnahme von R3-Q-010, zusammen mit der Weisung oben." |
| **Eingetragen am** | 2026-09-24 |

**Was die Freigabe umfasst.** Der Umfang von E3 nach ADR 0002, 6.14 a bis f, der Schnitt E3.1 bis E3.3 und die Reihenfolge nach ADR 0002, 6.14 g; dazu, nach dem Wortlaut des Pull Requests, die Bestätigung des Abnahmeeintrags zu R3-Q-010 (Nachtrag vom 2026-09-24 im Eintrag weiter oben in diesem Abschnitt). Der Vorbehalt nach R1 für S-01 bei R3-Q-011 entfällt damit; das vermerkt der Product Owner im Backlog.

**Was die Weisung dazu festlegt.** Ohne Umdeutung: E3.1 und der Bau von E3.2 laufen in einer Sitzung; der Versuch `R3-Q-011_regel_im_startkontext` steht damit zu Beginn von E3.3 vor dem Kontrollversuch, wie ADR 0002, 6.14 g es für den noch nicht erledigten Versuch vorsieht. Fällt er negativ aus, nimmt der Auftraggeber eine Änderung an der Skill in Kauf. Die drei Posten unter R3-Q-010 und O-29 kommen nach E3.3, vor der Freigabe des Grundgerüsts. Die Einordnung dieser Weisung in ADR 0002, 6.14 (Status-Block und Buchstabe g) führt der Software Architect nach; diese Rolle hält den Wortlaut hier nur fest.

**Was sie NICHT umfasst.** Die **Abnahme von R3-Q-011** (steht nach E3.3 an); den **Bau** von E3 selbst — zum Zeitpunkt dieses Eintrags ist an E3 nichts gebaut; der Bau von E3.1 und E3.2 folgt in dieser Sitzung als eigene Einheiten. Ebenso nicht umfasst: **O-25** (entschieden am 2026-09-03, ADR 0002, Abschnitt 8), der Belegprüfer **D20** (**O-15**), **R3-Q-005**, die **Freigabe des Grundgerüsts**, **O-28** (bleibt bedingt offen), **O-29** als Entscheid (die Weisung ordnet ihn nur ein, entscheidet ihn nicht) sowie die offenen Punkte **12, 15** (für R3-Q-011 bleibt S-02 offen) **und 20** des Backlogs. Die früheren Abnahmen — **DoD-Gate** (2026-09-08), **Starthooks** (2026-09-22), **R3-Q-010** (2026-09-23) — werden durch diesen Eintrag weder erweitert noch sonst berührt, ausser der Bestätigung des R3-Q-010-Eintrags nach dem Nachtrag weiter oben in diesem Abschnitt.

**Ohne Beschönigung.** Der Merge gibt den Schnitt E3.1 bis E3.3 frei; die Weisung vom selben Tag ändert seine Ausführung — der Versuch `R3-Q-011_regel_im_startkontext` steht nicht mehr zu Beginn von E3.2, sondern zu Beginn von E3.3, und die Begründung, die ADR 0002, 6.14 g für den früheren Ort gab, trägt damit nicht mehr (Einordnung durch den Software Architect im Nachtrag vom 2026-09-24 zu 6.14 g); fällt der Versuch negativ aus, nimmt der Auftraggeber eine Änderung an der Skill in Kauf. Für R3-Q-011 bleibt die Abstimmung mit S-02 offen (Backlog, offener Punkt 15). Keine weiteren Aussagen.

**Protokollvermerk zur Form** (Protocol Master, 4.2): Formweg 1 — Merge des Pull Requests, Beleg der Merge-Commit `3e5caf71b2bca97b7f9764a19841025875974df7`. Die Angaben zum Merge, zu den Zeitstempeln und zu den Folge-Commits sind der Erhebung des Koordinators vom 2026-09-24 mit `git` und der GitHub-API entnommen — Fremdbeleg, von dieser Rolle nicht nachgemessen. Nach dem Merge folgte auf main des Repositories `valITino/r3cosint` bis zum Beginn dieser Sitzung kein weiterer Commit. Im Repository `valITino/r3coscrum` folgte vor dem Merge des Pull Requests #13 der Nachweis-Commit der Automatik `6f7f04cf97460b744dfdb6ed9a25eef071a324cd` (2026-09-24, 04:57:26 UTC), der erste Elternteil jenes Merges.

**Bestätigung des Eintrags (Nachtrag vom 2026-09-25).** Der Merge des Pull Requests #24 des Repositories `valITino/r3cosint` am 2026-09-25 (Merge-Commit `0af86aa4e6485d6cdfe09829accfdb65a8a8c65a`, siehe den Unterabschnitt weiter unten in diesem Abschnitt) gilt nach dem Wortlaut des Pull Requests auch als "Bestätigung des Freigabe-Eintrags zu E3" (wörtliches Teilzitat aus dem Absatz "Was der Merge bedeutet" im Text des Pull Requests #24). Bestätigt ist der Eintrag in der Fassung des Commits `0415dace763bb40f0f6403c0463c3f6517f2c36b`; bis zum gemergten Kopf `697df5c7259acb9c9cf33b0e0f2db2b05db7a09d` ist er nicht mehr geändert worden — zwischen beiden Commits hat nur `0415dace763bb40f0f6403c0463c3f6517f2c36b` selbst die Datei `docs/adr/0002-architekturentscheid-ziel-stack.md` geändert, und dieser Unterabschnitt ist in beiden Ständen zeichengleich (Erhebung des Koordinators mit `git`, maschineller Vergleich). Die Freigabe selbst ist am 2026-09-24 erteilt; die Bestätigung ändert an Umfang, an dem, was nicht umfasst ist, und an der Weisung vom 2026-09-24 nichts.

### Merges #24 und #14 — Bestätigung des Freigabe-Eintrags zu E3, Regel verbindlich, Skill und Zuordnung angenommen (R3-Q-011) — erteilt am 2026-09-25, eingetragen am 2026-09-25

| | |
|---|---|
| **Vorgelegt** | 2026-09-24, eröffnet 12:35:54 UTC, mit der Übergabe `docs/uebergaben/2026-09-24_e3-1-und-e3-2.md`; vorgelegt zur Bestätigung mit dem Pull Request #24 des Repositories `valITino/r3cosint`, Arbeitszweig claude/jolly-pascal-0hd0tu, Kopf (`head.sha`) `697df5c7259acb9c9cf33b0e0f2db2b05db7a09d`, Basis bei Eröffnung `3e5caf71b2bca97b7f9764a19841025875974df7`, 5 Commits |
| **Formweg** | **Merge des Pull Requests** — der erste der beiden in ADR 0002, Abschnitt 10, Punkt 6 genannten Formwege. Wortlaut im Text des Pull Requests #24, Absatz "Was der Merge bedeutet": "**Was der Merge bedeutet:** Bestätigung des Freigabe-Eintrags zu E3 (ADR 0002, Abschnitt 10 und 6.14; Backlog R3-Q-011), die Regel `.claude/rules/fremde-inhalte-im-harness.md` wird verbindlich, die Skill `einschleusung-pruefen` und ihre Zuordnung zu sechs Rollen (ADR 0001, Abschnitte 3 und 5.1) sind angenommen (erster Formweg, ADR 0002, Abschnitt 10). Die Abnahme von R3-Q-011 steht nach E3.3 an. Nicht Gegenstand: E3.3 (Versuch zur Regel, Kontrollversuch, Prüfsatz, Lauf), die drei Posten unter R3-Q-010, O-29, R3-Q-005, D20 (O-15), Grundgerüst." |
| **Merge-Commit** | `0af86aa4e6485d6cdfe09829accfdb65a8a8c65a`, Eltern `3e5caf71b2bca97b7f9764a19841025875974df7` (main) und `697df5c7259acb9c9cf33b0e0f2db2b05db7a09d` (Kopf des Arbeitszweigs, zugleich `head.sha` des Pull Requests, also unverändert gemergt) |
| **Datum** | 2026-09-25, 03:45:36 UTC (05:45:36 MESZ) |
| **Bestätigter Stand des Zweigs** | `697df5c7259acb9c9cf33b0e0f2db2b05db7a09d` |
| **Auftraggeber (S-01)** | Merge durch das Konto des Repository-Eigentümers, für beide Pull Requests (#24 im Repository `valITino/r3cosint` und #14 im Repository `valITino/r3coscrum`); Name nach offenem Entscheid E-11 nicht im Repository geführt |
| **Zugehöriger Merge im Methodik-Repository** | `valITino/r3coscrum`, Pull Request #14, Arbeitszweig claude/jolly-pascal-0hd0tu, Basis bei Eröffnung `33bb5dfa18193ce25fc861c53d53b78b265fddcf`; Merge-Commit `ee56fea8572348799069ac0b866376764edf6694`, Eltern `211a6238d7dcdbbbdc09912bcffdf894dc9630a8` (main; Nachweis-Commit der Automatik "nachweise: Stand 0af86aa4e6485d6cdfe09829accfdb65a8a8c65a aus r3cosint", 2026-09-25T03:45:47Z, mit Elternteil `33bb5dfa18193ce25fc861c53d53b78b265fddcf`) und `c5cac57f4a10852d000b4b54b46bb53a4767575d` (Kopf des dortigen Arbeitszweigs, zugleich `head.sha`, also unverändert gemergt); Zeitpunkt nach `git` 2026-09-25, 03:46:30 UTC (05:46:30 MESZ), `merged_at` nach dem GitHub-Werkzeug 03:46:31 UTC (05:46:31 MESZ) — eine Sekunde Unterschied zwischen den beiden Quellen |
| **Kommentare, Reviews, Auflagen** | **0 Kommentare, 0 Reviews, 0 Review-Threads, keine Auflagen — für beide Pull Requests** (GitHub-Werkzeug: `get_comments`, `get_reviews`, `get_review_comments`; die leere Review-Liste umfasst auch ein allfälliges Review des Code-Review-Bots) — beide Pull Requests wurden unverändert gemergt: Der zweite Elternteil ist je der Kopf (`head.sha`) des betreffenden Arbeitszweigs |
| **Bestätigung über den zweiten Formweg** | Sitzungsauftrag vom 2026-09-25, Wortlaut: "Diese Sitzung ist Abschnitt A des Fahrplans in Punkt 2: die Merges von valITino/r3cosint#24 und valITino/r3coscrum#14 eintragen und E3.3 nach ADR 0002, 6.14 g vollständig bauen." |
| **Eingetragen am** | 2026-09-25 |

**Was der Merge umfasst.** Die **Bestätigung des Freigabe-Eintrags zu E3** (Unterabschnitt "Freigabe von E3 (R3-Q-011) — Umfang, Schnitt und Reihenfolge — erteilt und eingetragen am 2026-09-24" weiter oben in diesem Abschnitt 10; ADR 0002, 6.14; Backlog R3-Q-011). Die Regel `.claude/rules/fremde-inhalte-im-harness.md` **wird mit diesem Merge verbindlich** — in ADR 0002, 6.14 e angekündigt als "**Verbindlich** wird die Regel mit dem Merge des Pull Requests, der sie enthält, durch den Auftraggeber, bei dem Änderungen an den Projektregeln liegen (Eintrag R3-Q-011, Frage 4)". Die Skill `.claude/skills/einschleusung-pruefen/SKILL.md` und ihre Zuordnung zu sechs Rollen (ADR 0001, Abschnitte 3 und 5.1) sind **angenommen**. Gebaut mit den Commits: Schritt "Freigabe eintragen" `0415dace763bb40f0f6403c0463c3f6517f2c36b`, E3.1 (Regel) `2adfc37cad8d2d95ef9da103ab76fec9d63f225a`, E3.2 (Skill, Zuordnung) `757135b19eb628e3f278d4bb2005af9e3a6e488f`, Übergabe `4b39fd847f40a8637baeaa74c889c6a6a517bf18`, Nachweisverzeichnis `697df5c7259acb9c9cf33b0e0f2db2b05db7a09d` (Kopf des Arbeitszweigs, zugleich der bestätigte Stand oben).

**Was er NICHT umfasst.** Die **Abnahme von R3-Q-011** (steht nach E3.3 an); **E3.3** selbst (Versuch zur Regel, Kontrollversuch, Prüfsatz, Lauf); die **drei Posten unter R3-Q-010**; **O-29**; **R3-Q-005**; der Belegprüfer **D20** (**O-15**); das **Grundgerüst**. Ebenso nicht umfasst: **O-25** (entschieden am 2026-09-03, ADR 0002, Abschnitt 8), **O-28** (bleibt bedingt offen) sowie die offenen Punkte **12, 15 und 20** des Backlogs. Die früheren Abnahmen und Freigaben — **DoD-Gate** (2026-09-08), **Starthooks** (2026-09-22), **R3-Q-010** (2026-09-23), **Freigabe von E3** (2026-09-24) — werden durch diesen Eintrag **weder erweitert noch sonst berührt**, ausser der hier vermerkten Bestätigung des Eintrags vom 2026-09-24.

**Ohne Beschönigung.** Der Text des Pull Requests #24 nannte unter "Vor dem Merge" wörtlich: "**Vor dem Merge:** die Gegenprobe zu `R3-Q-011_regel_im_startkontext` in einer neuen Sitzung auf main ohne die Regel; die einzige Nachricht ist die Frage zur Regel." Diese Gegenprobe ist **vor dem Merge nicht gelaufen**: Das entsprechende Feld im Sitzungsauftrag vom 2026-09-25 ist leer; der Auftrag hält dazu fest: "Leer heisst: nicht durchgeführt." Folge: Der Versuch zur Regel ist in dieser Sitzung geführt, das Kriterium bleibt aber **ohne Gegenprobe offen**; die Abnahme von R3-Q-011 steht nach E3.3 an und ist **nicht Gegenstand dieses Merge**. Das Ergebnis des Versuchs selbst steht nicht in diesem Eintrag, sondern in der Übergabe dieser Sitzung.

**Protokollvermerk zur Form** (Protocol Master, 4.2): Formweg 1 — Merge des Pull Requests, Belege die Merge-Commits `0af86aa4e6485d6cdfe09829accfdb65a8a8c65a` (Repository `valITino/r3cosint`, Pull Request #24) und `ee56fea8572348799069ac0b866376764edf6694` (Repository `valITino/r3coscrum`, Pull Request #14). Die Angaben zu den beiden Merges, zu den Zeitstempeln, zum Wortlaut des Pull Requests #24, zur Gegenprobe und zum Versuch zur Regel (A0) in dieser Sitzung sind der Erhebung des Koordinators vom 2026-09-25 mit `git`, dem GitHub-Werkzeug und dem Sitzungsverlauf entnommen — Fremdbeleg, von dieser Rolle nicht nachgemessen. Nach dem Merge folgte auf main des Repositories `valITino/r3cosint` bis zum Beginn dieser Sitzung (2026-09-25, 06:43:39 UTC) kein weiterer Commit; origin/main stand am 2026-09-25 um 06:44:35 UTC unverändert auf `0af86aa4e6485d6cdfe09829accfdb65a8a8c65a` (Erhebung des Koordinators).

**Bestätigung des Eintrags (Nachtrag vom 2026-10-14).** Der Merge des Pull Requests #25 des Repositories `valITino/r3cosint` am 2026-09-25 (Merge-Commit `0b6d59625423f53fcd0e8b3f22150d97ef2a17f4`, siehe den Unterabschnitt weiter unten in diesem Abschnitt) gilt nach dem Wortlaut des Pull Requests ("Merge = Merges #24 und #14 eingetragen", wörtliches Teilzitat aus dem Absatz "Was der Merge bedeutet" im Text des Pull Requests #25) als Bestätigung dieses Eintrags. Bestätigt ist der Eintrag in der Fassung des Commits `eab40ec2c2cae26bdc3f94ee76b53b812ad487f5`; bis zum gemergten Kopf `fac7e3dcc33b5cda8722fecf4d339b7b36a6fe5f` ist er nicht mehr geändert worden — zwischen beiden Commits hat nur `7e69fafacc5af23ef174d87445485b782d03dceb` die Datei `docs/adr/0002-architekturentscheid-ziel-stack.md` geändert, und der Unterabschnitt ist in den Ständen `eab40ec2c2cae26bdc3f94ee76b53b812ad487f5`, `fac7e3dcc33b5cda8722fecf4d339b7b36a6fe5f` und `0b6d59625423f53fcd0e8b3f22150d97ef2a17f4` von seiner Überschrift bis zum Dateiende des jeweiligen Standes zeichengleich (Erhebung des Koordinators mit `git`, maschineller Vergleich; Fremdbeleg). Die Bestätigung ändert am Inhalt des Eintrags nichts; was er zum Stand des 2026-09-25 sagt, etwa "steht nach E3.3 an", bleibt als Stand dieses Tages stehen (ADR 0002, 6.1, Absatz "Anlass"). Den Eintrag zur Abnahme von R3-Q-011 siehe den Unterabschnitt darunter.

### Abnahme von R3-Q-011 — E3, fremde Inhalte im Harness: Regel, Skill zur Einschleusungsprüfung und Prüfsatz — erteilt am 2026-09-25, eingetragen am 2026-10-14

| | |
|---|---|
| **Vorgelegt** | 2026-09-25, eröffnet 09:52:12 UTC, mit der Übergabe `docs/uebergaben/2026-09-25_e3-3.md`; vorgelegt zur Abnahme mit dem Pull Request #25 des Repositories `valITino/r3cosint`, Arbeitszweig claude/dreamy-heisenberg-ijp5jy, Kopf (`head.sha`) `fac7e3dcc33b5cda8722fecf4d339b7b36a6fe5f`, Basis bei Eröffnung `0af86aa4e6485d6cdfe09829accfdb65a8a8c65a`, 5 Commits, 18 Dateien |
| **Formweg** | **Merge des Pull Requests** — der erste der beiden in ADR 0002, Abschnitt 10, Punkt 6 genannten Formwege. Wortlaut im Text des Pull Requests #25, Absatz "Was der Merge bedeutet": "**Was der Merge bedeutet:** Merge = Merges #24 und #14 eingetragen, Abnahme von R3-Q-011 mit fünf der sechs Kriterien — `R3-Q-011_regel_vorhanden`, `R3-Q-011_skill_bauform`, `R3-Q-011_skills_feld_nachgefuehrt`, `R3-Q-011_pruefsatz_einschleusung` und `R3-Q-011_vorladen_kontrollversuch`, dieses in der Lesart, dass der Übergabeaufruf der Antwort (SubagentHandback) kein Werkzeugaufruf im Sinne des Kriteriums ist (erster Formweg, ADR 0002, Abschnitt 10). **Nicht umfasst:** `R3-Q-011_regel_im_startkontext`, weil die Gegenprobe aussteht (Ablauf: neue Sitzung auf Commit `3e5caf71b2bca97b7f9764a19841025875974df7`, einzige Nachricht die Frage aus dem Sitzungsauftrag vom 2026-09-25, kein Werkzeug; Ergebnis mit Datum und Uhrzeit an die nächste Sitzung). Ebenfalls nicht Gegenstand: die Terminierung von `Skill` in dreizehn Werkzeuglisten (ADR 0002, 6.14 e), die drei Posten unter R3-Q-010, O-29, R3-Q-005, D20 (O-15), Grundgerüst. Wer die Lesart zum Übergabeaufruf nicht teilt, merget nicht, sondern hinterlässt den Entscheid als Anweisung an die nächste Sitzung." Damit gilt der Merge als Abnahme von R3-Q-011 mit fünf der sechs Kriterien, im Umfang des Absatzes "Was die Abnahme umfasst" unten, und nach dem Wortlaut "Merge = Merges #24 und #14 eingetragen" zugleich als Bestätigung des Eintrags zu den Merges #24 und #14 (Nachtrag vom 2026-10-14 weiter oben in diesem Abschnitt) |
| **Merge-Commit** | `0b6d59625423f53fcd0e8b3f22150d97ef2a17f4`, Eltern `0af86aa4e6485d6cdfe09829accfdb65a8a8c65a` (main; zugleich der Merge-Commit von #24) und `fac7e3dcc33b5cda8722fecf4d339b7b36a6fe5f` (Kopf des Arbeitszweigs, zugleich `head.sha` des Pull Requests, also unverändert gemergt) |
| **Datum** | 2026-09-25, 10:48:01 UTC (12:48:01 MESZ); nach git und nach dem GitHub-Werkzeug (`merged_at`) gleich |
| **Abgenommener Stand des Zweigs** | `fac7e3dcc33b5cda8722fecf4d339b7b36a6fe5f` |
| **Auftraggeber (S-01)** | Merge durch das Konto des Repository-Eigentümers, für beide Pull Requests (#25 im Repository `valITino/r3cosint` und #15 im Repository `valITino/r3coscrum`); Name nach offenem Entscheid E-11 nicht im Repository geführt |
| **Zugehöriger Merge im Methodik-Repository** | `valITino/r3coscrum`, Pull Request #15, Arbeitszweig claude/dreamy-heisenberg-ijp5jy, Basis bei Eröffnung `ee56fea8572348799069ac0b866376764edf6694`; Merge-Commit `d349f3ce4bba8db8f919c188849acc452190ac44`, Eltern `265a4d89cd81267257d3d4824e226054458e9c59` (main; Nachweis-Commit der Automatik "nachweise: Stand 0b6d59625423f53fcd0e8b3f22150d97ef2a17f4 aus r3cosint", 2026-09-25, 10:48:12 UTC, mit Elternteil `ee56fea8572348799069ac0b866376764edf6694`, dem Merge-Commit von #14) und `df0dab7231c6c79de095a9f18a47813bdbda3038` (Kopf des dortigen Arbeitszweigs, zugleich `head.sha`, also unverändert gemergt); Zeitpunkt nach `git` 2026-09-25, 10:50:09 UTC (12:50:09 MESZ), `merged_at` nach dem GitHub-Werkzeug 10:50:10 UTC (12:50:10 MESZ) — eine Sekunde Unterschied zwischen den beiden Quellen. Wortlaut der Beschreibung des Pull Requests #15 (Teilzitat aus dem Abschnitt "Beschreibung"): "Der Merge gehört zum Merge des zugehörigen Pull Requests im Produkt-Repository (valITino/r3cosint, Zweig claude/dreamy-heisenberg-ijp5jy): Merge = Merges #24 und #14 eingetragen, Abnahme von R3-Q-011 mit fünf der sechs Kriterien; nicht umfasst ist `R3-Q-011_regel_im_startkontext`, weil die Gegenprobe aussteht." |
| **Kommentare, Reviews, Auflagen** | **0 Kommentare, 0 Reviews, 0 Review-Threads, keine Auflagen — für beide Pull Requests** (GitHub-Werkzeug: `get_comments`, `get_reviews`, `get_review_comments`; die leere Review-Liste umfasst auch ein allfälliges Review des Code-Review-Bots) — beide Pull Requests wurden unverändert gemergt: Der zweite Elternteil ist je der Kopf (`head.sha`) des betreffenden Arbeitszweigs |
| **Weisung über den zweiten Formweg** | Sitzungsauftrag vom 2026-10-14, Wortlaut: "Diese Sitzung ist Abschnitt B des Fahrplans in Punkt 2: die Merges von valITino/r3cosint#25 und valITino/r3coscrum#15 als Abnahme von R3-Q-011 eintragen und die drei Posten unter R3-Q-010 nach ADR 0002, 6.13 c bauen." |
| **Eingetragen am** | 2026-10-14 |

**Was die Abnahme umfasst.** Fünf der sechs Abnahmekriterien von R3-Q-011 — `R3-Q-011_regel_vorhanden`, `R3-Q-011_skill_bauform`, `R3-Q-011_skills_feld_nachgefuehrt`, `R3-Q-011_pruefsatz_einschleusung` und `R3-Q-011_vorladen_kontrollversuch` —, das letzte in der Lesart, dass der Übergabeaufruf der Antwort (SubagentHandback) kein Werkzeugaufruf im Sinne des Kriteriums ist. Der Text des Pull Requests legte diese Lesart zur Abnahme vor ("Wer die Lesart zum Übergabeaufruf nicht teilt, merget nicht, sondern hinterlässt den Entscheid als Anweisung an die nächste Sitzung."); der Auftraggeber hat gemergt, die Lesart ist damit angenommen. Am abgenommenen Stand gehören dazu die Regel `.claude/rules/fremde-inhalte-im-harness.md`, die Skill `.claude/skills/einschleusung-pruefen/SKILL.md`, der Prüfsatz `scripts/einschleusung-pruefsatz/` (angelegt mit dem Commit `818a17162bbbc51206138ddcecae907f5e4bb235`) und das Ergebnis des Kontrollversuchs in ADR 0001, Abschnitt 5.1 (eingetragen mit dem Commit `1f8865cc36701702f1bb61bc47e40cf948b51756`); Einzelheiten zur Einheit E3.3 stehen in der Übergabe `docs/uebergaben/2026-09-25_e3-3.md`. Die fünf Commits des Pull Requests, neueste zuerst (2026-09-25, Zeit UTC): `fac7e3dcc33b5cda8722fecf4d339b7b36a6fe5f` (09:45:15, Nachweisverzeichnis nach E3.3 neu erzeugt; Kopf des Arbeitszweigs, zugleich der abgenommene Stand), `7e69fafacc5af23ef174d87445485b782d03dceb` (09:44:40, E3.3 abgeschlossen mit den Nachführungen nach ADR 0002, 6.14 h und der Übergabe), `1f8865cc36701702f1bb61bc47e40cf948b51756` (08:50:32, Ergebnis des Kontrollversuchs SK-02 in ADR 0001, 5.1 eingetragen), `818a17162bbbc51206138ddcecae907f5e4bb235` (08:23:16, Prüfsatz zur Einschleusungsprüfung angelegt, E3.3) und `eab40ec2c2cae26bdc3f94ee76b53b812ad487f5` (07:35:52, "Merges #24 und #14 eingetragen", der im Nachtrag vom 2026-10-14 weiter oben bestätigte Eintrag). Mit demselben Merge sind unter anderem die Nachträge in ADR 0002, 6.14, Kopfzeile und Abschnitt 9, der Nachtrag in ADR 0001, Abschnitt 5.1, die Nachführungen in Backlog, CLAUDE.md und `scripts/nachweise-erzeugen.sh` (Artefaktzeile des Prüfsatzes), die Übergabe und das neu erzeugte Nachweisverzeichnis auf main gelangt; dass der Merge sie mitumfasst, ist eine Schlussfolgerung dieser Rolle aus dem gemergten Stand (Kopf `fac7e3dcc33b5cda8722fecf4d339b7b36a6fe5f`) und nicht Wortlaut des Absatzes "Was der Merge bedeutet" im Text des Pull Requests.

**Was sie NICHT umfasst.** Das **sechste Kriterium** `R3-Q-011_regel_im_startkontext`; der Text des Pull Requests sagt dazu: "**Nicht umfasst:** `R3-Q-011_regel_im_startkontext`, weil die Gegenprobe aussteht (Ablauf: neue Sitzung auf Commit `3e5caf71b2bca97b7f9764a19841025875974df7`, einzige Nachricht die Frage aus dem Sitzungsauftrag vom 2026-09-25, kein Werkzeug; Ergebnis mit Datum und Uhrzeit an die nächste Sitzung)." Ebenfalls nicht Gegenstand, nach dem Wortlaut des Pull Requests: die **Terminierung** von `Skill` in dreizehn Werkzeuglisten (ADR 0002, 6.14 e; das Feld dazu im Sitzungsauftrag vom 2026-10-14 ist leer, der Entscheid damit nicht getroffen), die **drei Posten unter R3-Q-010** (ADR 0002, 6.13 c; ihr Bau folgt nach der Weisung oben in dieser Sitzung), **O-29**, **R3-Q-005**, der Belegprüfer **D20** (**O-15**) und das **Grundgerüst**. Ebenso nicht umfasst: **O-25** (entschieden am 2026-09-03, ADR 0002, Abschnitt 8), **O-28** (bleibt bedingt offen) sowie die offenen Punkte **12, 15 und 20** des Backlogs. Die früheren Abnahmen, Freigaben und Bestätigungen — darunter **DoD-Gate** (2026-09-08), **Starthooks** (2026-09-22), **R3-Q-010** (2026-09-23), **Freigabe von E3** (2026-09-24), **Merges #24 und #14** (2026-09-25) — werden durch diesen Eintrag **weder erweitert noch sonst berührt**, ausser der Bestätigung des Eintrags zu den Merges #24 und #14 nach dem Nachtrag vom 2026-10-14 weiter oben in diesem Abschnitt.

**Ohne Beschönigung.** (1) Die Gegenprobe zu `R3-Q-011_regel_im_startkontext` stand zum Zeitpunkt des Merge aus (Wortlaut des Pull Requests) und ist auch am 2026-10-14 nicht durchgeführt: Das Feld dazu im Sitzungsauftrag vom 2026-10-14 ist leer, und der Auftrag hält fest: "leer heisst: nicht durchgeführt beziehungsweise nicht entschieden". Das Kriterium bleibt offen; der Auftrag verlangt, den Ablauf erneut in Übergabe und Schlussbericht zu nennen. Der Ablauf für den Auftraggeber steht im Wortlaut des Pull Requests: neue Sitzung auf Commit `3e5caf71b2bca97b7f9764a19841025875974df7`, einzige Nachricht die Frage aus dem Sitzungsauftrag vom 2026-09-25, kein Werkzeug. (2) Der Eintrag erfolgt 19 Tage nach dem Merge; zwischen dem jeweiligen Merge (#25 im Repository `valITino/r3cosint`, #15 im Repository `valITino/r3coscrum`) und dem Beginn dieser Sitzung folgte auf main des jeweiligen Repositories kein weiterer Commit (Einzelheiten im Protokollvermerk unten). (3) Die Lesart zum Übergabeaufruf ist durch den Merge angenommen; der Wortlaut des Kriteriums im Backlog ("ohne einen einzigen Werkzeugaufruf") ist dadurch nicht geändert. (4) Die Terminierung von `Skill` in dreizehn Werkzeuglisten (ADR 0002, 6.14 e) ist nicht entschieden, weil das Feld im Sitzungsauftrag vom 2026-10-14 leer ist; ADR 0001 bleibt in dieser Einheit unverändert. (5) Der Entscheid zur Berichtigung des Verweises "(ADR 0002, 6.1.2)" ist nicht getroffen (Feld im Sitzungsauftrag vom 2026-10-14 leer); bestehende Verweise bleiben unverändert. Der Text des Pull Requests nennt diesen Verweis unter den Restbefunden und Entscheiden für den Auftraggeber, die in der Übergabe stehen, und vermerkt, dass er auf den falschen Abschnitt zeigt; 6.1.2 handelt vom Kettenschritt für die Architekturverträge. Dieser Eintrag stützt den Grundsatz "der Stand davor bleibt stehen" auf ADR 0002, 6.1, Absatz "Anlass" ("die früheren Fassungen bleiben im Text stehen"). (6) Weitere Restbefunde und Entscheide für den Auftraggeber stehen nach dem Text des Pull Requests in der Übergabe `docs/uebergaben/2026-09-25_e3-3.md`; diese Abnahme umfasst sie nicht als behoben. (7) Nach dem Text des Pull Requests lag die Verifikation je Schritt beim Static Software Tester auf einem anderen `model`-Feld als die Umsetzung, vier blockierende Befunde wurden behoben und in Delta-Runden nachgeprüft, und `make dod` lief vor jedem Commit von Hand in der erwarteten Form (drei terminierte Lagen C D7, D10, D12; D20 und D11 A_OK; D19 OHNE_BEFUND; Rückgabewert 2), weil die Hooks aus `.claude/settings.json` in der Sitzung vom 2026-09-25 nicht wirkten — Fremdbeleg aus dem Text des Pull Requests und der Übergabe, von dieser Rolle nicht nachgemessen.

**Protokollvermerk zur Form** (Protocol Master, 4.2): Formweg 1 — Merge des Pull Requests, Belege die Merge-Commits `0b6d59625423f53fcd0e8b3f22150d97ef2a17f4` (Repository `valITino/r3cosint`, Pull Request #25) und `d349f3ce4bba8db8f919c188849acc452190ac44` (Repository `valITino/r3coscrum`, Pull Request #15). Die Angaben zu den beiden Merges, zu den Zeitstempeln, zum Wortlaut der Pull Requests und des Sitzungsauftrags, zu den Kommentarzahlen und zu den Folge-Commits sind der Erhebung des Koordinators vom 2026-10-14 mit `git`, dem GitHub-Werkzeug und dem Sitzungsauftrag entnommen — Fremdbeleg, von dieser Rolle nicht nachgemessen. Nach dem Merge folgte auf main des Repositories `valITino/r3cosint` bis zum Beginn dieser Sitzung (2026-10-14, 03:47 UTC) kein weiterer Commit; origin/main stand um 03:49 UTC auf dem Merge-Commit `0b6d59625423f53fcd0e8b3f22150d97ef2a17f4` selbst. Im Repository `valITino/r3coscrum` folgte vor dem Merge des Pull Requests #15 der Nachweis-Commit der Automatik `265a4d89cd81267257d3d4824e226054458e9c59` (2026-09-25, 10:48:12 UTC), der erste Elternteil jenes Merges; nach dem Merge folgte kein weiterer Commit, origin/main stand um 03:49 UTC auf `d349f3ce4bba8db8f919c188849acc452190ac44` selbst (Erhebung des Koordinators).

**Bestätigung des Eintrags (Nachtrag vom 2026-10-21).** Mit dem Merge des Pull Requests #26 des Repositories `valITino/r3cosint` am 2026-10-16 (Merge-Commit `5ada002023c0ff160c26c78659727c7e8623c6f5`, siehe den Unterabschnitt darunter) ist dieser Eintrag bestätigt — nach dem Wortlaut des Pull Requests ("Merge = Abnahme von R3-Q-011 eingetragen", wörtliches Teilzitat). Am Wortlaut des Eintrags ändert die Bestätigung nichts; was er zum Stand des 2026-10-14 sagt, bleibt als Stand dieses Tages stehen (ADR 0002, 6.1, Absatz "Anlass").

### Abnahme von Posten 1 unter R3-Q-010 — main-Gate, L01 bis L04, Grenzen GM-5 bis GM-8 — erteilt am 2026-10-16, eingetragen am 2026-10-21

| | |
|---|---|
| **Vorgelegt** | 2026-10-15, eröffnet 06:09:14 UTC, mit der Übergabe `docs/uebergaben/2026-10-14_abnahme-r3-q-011-posten-1.md`; vorgelegt zur Abnahme mit dem Pull Request #26 des Repositories `valITino/r3cosint`, Arbeitszweig ccr-0cbb4387-oe1i3c, Kopf (`head.sha`) `7abbcd4c3ee69c3f1c9cafb04b63f177a1a7f09f`, Basis `0b6d59625423f53fcd0e8b3f22150d97ef2a17f4` (Merge-Commit von #25), 4 Commits, 8 Dateien, +934/-51 |
| **Formweg** | **Merge des Pull Requests** — der erste der beiden in ADR 0002, Abschnitt 10, Punkt 6 genannten Formwege. Wortlaut im Text des Pull Requests #26 zum Umfang (Teilzitat; die Klammer "(...)" ist so in der Erhebung des Koordinators wiedergegeben und hier nicht ergänzt): "Merge = Abnahme von R3-Q-011 eingetragen (ADR 0002, Abschnitt 10 und 6.14) und Abnahme von Posten 1 unter R3-Q-010 (...), im Umfang der Übergabe docs/uebergaben/2026-10-14_abnahme-r3-q-011-posten-1.md einschliesslich der dort benannten Restbefunde (erster Formweg, ADR 0002, Abschnitt 10)." |
| **Merge-Commit** | `5ada002023c0ff160c26c78659727c7e8623c6f5` ("Merge pull request #26 from valITino/ccr-0cbb4387-oe1i3c"), Eltern `0b6d59625423f53fcd0e8b3f22150d97ef2a17f4` (main; zugleich der Merge-Commit von #25) und `7abbcd4c3ee69c3f1c9cafb04b63f177a1a7f09f` (Kopf des Arbeitszweigs, zugleich `head.sha` des Pull Requests, also unverändert gemergt); abgenommener Stand des Zweigs ist dieser Kopf; `merged_by` `valITino`, das Konto des Repository-Eigentümers (Auftraggeber, S-01; Name nach offenem Entscheid E-11 nicht im Repository geführt) |
| **Datum** | 2026-10-16, 05:54:49 UTC (07:54:49 MESZ); nach git und nach dem GitHub-Werkzeug (`merged_at`) gleich |
| **Kommentare, Reviews, Auflagen** | **0 Kommentare, 0 Reviews, keine Auflagen in diesen Kanälen** (GitHub-Werkzeug: `get_comments`, `get_reviews`) |
| **Zugehöriger Pull Request im Methodik-Repository** | Pull Request #16 (Übergabevermerk) des Repositories `valITino/r3coscrum`, gemergt am 2026-10-21, 03:39:54 UTC (`merged_at`, GitHub-Werkzeug; der Merge-Commit trägt nach git 03:39:53 UTC — eine Sekunde Unterschied zwischen den beiden Quellen); Merge-Commit `44d6c5b5dbc4428d53708e8cfd20d7154e895e9d`, Eltern `44171380dadbec9676813a6394f1481b9e2c3601` (main; Nachweis-Commit der Automatik "nachweise: Stand 5ada002023c0ff160c26c78659727c7e8623c6f5 aus r3cosint", 2026-10-16, 05:54:58 UTC) und `3590ed5a12f560d19b881542634dc4be0e4c5980` (Kopf des Pull Requests, also unverändert gemergt); `merged_by` `valITino`; 0 Kommentare, 0 Reviews (GitHub-Werkzeug: `get_comments`, `get_reviews`); 1 Commit, 1 Datei, +59. Wortlaut im Text des Pull Requests #16 zur Bedeutung des Merges: "Merge = Bestätigung des Übergabevermerks; die Abnahme von Posten 1 und der Eintrag zu R3-Q-011 erfolgen durch den Merge des zugehörigen Pull Requests #26 im Produkt-Repository." Die erste Erhebung des Koordinators vom selben Tag (vor 03:39 UTC) fand den Pull Request noch offen; die Angaben hier stammen aus dem Nachtrag zu dieser Erhebung (Fremdbeleg, von dieser Rolle nicht nachgemessen). Der Formweg dieses Eintrags ist allein der Merge von #26 |
| **Weisung über den zweiten Formweg** | Anweisung an die Sitzung vom 2026-10-21, Wortlaut: "Was jetzt? Weitermachen bzw. fortfahren mit dem nächsten? Alles so gemerged wie es soll und bereit für das nächste? Mach einfach das, was richtig ist und gemacht werden soll, ich erlaube es dir." Der Eintrag erfolgt auf diese Weisung; ihr Wortlaut nennt den Eintrag nicht ausdrücklich |
| **Eingetragen am** | 2026-10-21 |

**Was die Abnahme umfasst.** Die **Abnahme von Posten 1 unter R3-Q-010** (main-Gate; Bau und Verifikation in ADR 0002, 6.13, Status-Block, und 6.13 c, je Nachtrag vom 2026-10-14) im Umfang der Übergabe `docs/uebergaben/2026-10-14_abnahme-r3-q-011-posten-1.md` einschliesslich der dort benannten Restbefunde, im Wortlaut der Zeile "Formweg". Die Restbefunde gehören nach dem Wortlaut zum Umfang; behoben sind sie dadurch nicht. Nach dem Wortlaut ("Merge = Abnahme von R3-Q-011 eingetragen", wörtliches Teilzitat) gilt der Merge zugleich als **Bestätigung des Eintrags zur Abnahme von R3-Q-011** (Nachtrag vom 2026-10-21 im Unterabschnitt darüber).

**Was sie NICHT umfasst.** Nach dem Text des Pull Requests (Zusammenfassung in der Erhebung des Koordinators, kein Wortzitat): die **Posten 2 und 3** unter R3-Q-010 (nicht gebaut); die **Posten 4 und 5** (neu erfasst, nicht gebaut, Einordnung durch den Auftraggeber; die Einordnung ist nicht Gegenstand dieses Eintrags); das Kriterium `R3-Q-011_regel_im_startkontext`; die **Terminierung** von `Skill` (ADR 0002, 6.14 e); die **Berichtigung** des Verweises "(ADR 0002, 6.1.2)" an bestehenden Stellen (der Verweis zeigt auf den falschen Abschnitt, der Grundsatz steht in ADR 0002, 6.1, Absatz "Anlass"). Frühere Abnahmen, Freigaben und Bestätigungen werden durch diesen Eintrag weder erweitert noch sonst berührt, ausser der Bestätigung des Eintrags zu R3-Q-011. Was der Nachtrag vom 2026-10-14 im Status-Block von ADR 0002, 6.13 zum Stand von Posten 1 sagt ("Abgenommen ist Posten 1 damit nicht"), bleibt als Stand seines Tages stehen (ADR 0002, 6.1, Absatz "Anlass").

**Protokollvermerk zur Form** (Protocol Master, 4.2): Formweg 1 — Merge des Pull Requests, Beleg der Merge-Commit `5ada002023c0ff160c26c78659727c7e8623c6f5` (Repository `valITino/r3cosint`, Pull Request #26). Die Angaben zum Merge, zu den Zeitstempeln, zum Wortlaut des Pull Requests, zu den Kommentarzahlen, zum Methodik-Repository und der Wortlaut der Weisung sind der Erhebung des Koordinators vom 2026-10-21 entnommen, die Merge-Fakten erhoben mit `git` und dem GitHub-Werkzeug — Fremdbeleg, von dieser Rolle nicht nachgemessen; Zitate stehen in der Schreibweise des ADR (die Erhebung gibt Teile in ASCII-Umschrift wieder, etwa "Uebergabe"). Der Arbeitszweig der Sitzung vom 2026-10-21 heisst wie der Zweig des Pull Requests (ccr-0cbb4387-oe1i3c) und wurde an diesem Tag neu von origin/main gesetzt; für den Stand des Pull Requests massgeblich sind die Prüfsummen oben, nicht der Zweigname.

**Bestätigung des Eintrags (Nachtrag vom 2026-10-21).** Mit dem Merge des Pull Requests #27 des Repositories `valITino/r3cosint` am 2026-10-21 (Merge-Commit `998f81d9fffe3970baf870d04e44576eda534fcc`, siehe den Unterabschnitt darunter) ist dieser Eintrag bestätigt — nach dem Wortlaut des Pull Requests ("zugleich Bestätigung des Eintrags zur Abnahme von Posten 1", wörtliches Teilzitat). Am Wortlaut des Eintrags ändert die Bestätigung nichts; was er zum Stand des 2026-10-16 sagt, etwa dass die Posten 4 und 5 neu erfasst und nicht gebaut sind, bleibt als Stand dieses Tages stehen (ADR 0002, 6.1, Absatz "Anlass").

### Abnahme von Posten 4 und 5 unter R3-Q-010 — main-Gate L17, L19, L21; beide Gates L20, L22, B64, B65 — erteilt am 2026-10-21, eingetragen am 2026-10-21

| | |
|---|---|
| **Vorgelegt** | 2026-10-21, eröffnet 15:13:34 UTC, mit der Übergabe `docs/uebergaben/2026-10-21_abschnitt-c-posten-4-5.md`; vorgelegt zur Abnahme mit dem Pull Request #27 des Repositories `valITino/r3cosint`, Arbeitszweig ccr-0cbb4387-oe1i3c, Kopf (`head.sha`) `c84e2a36b22cd328e1887d6fc317a023ddccb639`, Basis `5ada002023c0ff160c26c78659727c7e8623c6f5` (Merge-Commit von #26), 3 Commits, 10 Dateien, +1458/-58 |
| **Formweg** | **Merge des Pull Requests** — der erste der beiden in ADR 0002, Abschnitt 10, Punkt 6 genannten Formwege. Wortlaut im Text des Pull Requests #27 zur Bedeutung des Merges: "**Merge = Abnahme von Posten 4 (main-Gate: L17 Befehlskette, L19 Zeilenfortsetzung, L21 Basename-Form) und Posten 5 (beide PreToolUse-Gates: L20, L22, B64, B65) unter R3-Q-010** im Umfang der Übergabe `docs/uebergaben/2026-10-21_abschnitt-c-posten-4-5.md` einschliesslich der dort benannten Restbefunde, Preise und Grenzen (erster Formweg, ADR 0002, Abschnitt 10); zugleich Bestätigung des Eintrags zur Abnahme von Posten 1 (ADR 0002, Abschnitt 10) und der unter der Delegation der Weisung vom 2026-10-21 getroffenen Einordnungen (Reihenfolge; Posten 6 und 7 als belegte Lücken; Prüftiefe für Texte)." |
| **Merge-Commit** | `998f81d9fffe3970baf870d04e44576eda534fcc` ("Merge pull request #27 from valITino/ccr-0cbb4387-oe1i3c"), Eltern `5ada002023c0ff160c26c78659727c7e8623c6f5` (main; zugleich der Merge-Commit von #26) und `c84e2a36b22cd328e1887d6fc317a023ddccb639` (Kopf des Arbeitszweigs, zugleich `head.sha` des Pull Requests, also unverändert gemergt) |
| **Datum** | 2026-10-21, 16:53:03 UTC (18:53:03 MESZ); nach git und nach dem GitHub-Werkzeug (`merged_at`) gleich |
| **Abgenommener Stand des Zweigs** | `c84e2a36b22cd328e1887d6fc317a023ddccb639` |
| **Auftraggeber (S-01)** | Merge durch das Konto des Repository-Eigentümers (`merged_by` `valITino`), für beide Pull Requests (#27 im Repository `valITino/r3cosint` und #17 im Repository `valITino/r3coscrum`); Name nach offenem Entscheid E-11 nicht im Repository geführt |
| **Zugehöriger Pull Request im Methodik-Repository** | Pull Request #17 (Übergabevermerk) des Repositories `valITino/r3coscrum`, gemergt am 2026-10-21, 16:53:23 UTC (`merged_at`; der Merge-Commit trägt nach git 16:53:23 UTC, also gleich); Merge-Commit `f8cb47867fe09b80adb623a6c37fb6d800c49f1c`, Eltern `b881a0b509984bcbe4462e6f21715c61ae9fa900` (main; Bot-Commit der Automatik nach dem Merge von #27) und `aeacddb3c602ac0c769fd3234b008873682c9334` (Kopf des Pull Requests, also unverändert gemergt); `merged_by` `valITino`; 0 Kommentare, 0 Reviews. Wortlaut im Text des Pull Requests #17: "Merge = Bestätigung des Übergabevermerks; die Abnahme von Posten 4 und 5 erfolgt durch den Merge des zugehörigen Pull Requests #27 im Produkt-Repository." Die erste Erhebung des Koordinators (16:53 UTC) fand den Pull Request noch offen (Basis `44d6c5b5dbc4428d53708e8cfd20d7154e895e9d`, der Merge-Commit von #16); die Angaben hier stammen aus dem Nachtrag zur Erhebung von 16:54 UTC (Fremdbeleg, von dieser Rolle nicht nachgemessen). Der Formweg dieses Eintrags ist allein der Merge von #27 |
| **Kommentare, Reviews, Auflagen** | **0 Kommentare, 0 Reviews, keine Auflagen in diesen Kanälen — für beide Pull Requests** (GitHub-Werkzeug; für #27 `get_comments` und `get_reviews`) |
| **Weisung über den zweiten Formweg** | Anweisung an die Sitzung vom 2026-10-21, nach den Merges #27 und #17, Wortlaut: "Weiter mit Abschnitt D, D1 und dann C3". Lesart des Koordinators (nicht Wortlaut der Weisung): D1 ist der Eintrag der Merges #27 und #17; danach C3, Posten 2 (L05 bis L08) zusammen mit Posten 6 (L23, L24) und dem Prototyp-Teil von Posten 7, weil C3 die nächste Änderung am Prototyp-Gate ist (ADR 0002, 6.13 c, Nachtrag vom 2026-10-21 — Posten 4 und 5 gebaut; Einordnungen aus Bau und Verifikation; Posten 6 und 7 erfasst). Der Eintrag erfolgt auf diese Weisung |
| **Eingetragen am** | 2026-10-21 |

**Was die Abnahme umfasst.** Die **Abnahme von Posten 4 und 5 unter R3-Q-010** (Posten 4 am main-Gate: L17, L19, L21; Posten 5 an beiden Gates: L20, L22, B64, B65) im Umfang der Übergabe `docs/uebergaben/2026-10-21_abschnitt-c-posten-4-5.md` einschliesslich der dort benannten Restbefunde, Preise und Grenzen, im Wortlaut der Zeile "Formweg". Die Restbefunde, Preise und Grenzen gehören nach dem Wortlaut zum Umfang, wie die Übergabe sie benennt; behoben oder aufgehoben sind sie dadurch nicht. Nach dem Wortlaut gilt der Merge zugleich als **Bestätigung des Eintrags zur Abnahme von Posten 1** (Nachtrag vom 2026-10-21 im Unterabschnitt darüber) und der **unter der Delegation der Weisung vom 2026-10-21 getroffenen Einordnungen** (Reihenfolge; Posten 6 und 7 als belegte Lücken; Prüftiefe für Texte). Der Titel des Pull Requests nennt auch das Schwachstellenregister, der Wortlaut zur Bedeutung des Merges nennt es nicht; dieser Eintrag ordnet es weder dem Umfang noch dem Nicht-Umfassten zu.

**Was sie NICHT umfasst.** Nach dem Text des Pull Requests (Zusammenfassung in der Erhebung des Koordinators, kein Wortzitat): die **Posten 2 und 3** unter R3-Q-010; die **Posten 6 und 7**; das Kriterium `R3-Q-011_regel_im_startkontext`; die **Terminierung** von `Skill` (ADR 0002, 6.14 e); die **Berichtigung** des Verweises "(ADR 0002, 6.1.2)" an bestehenden Stellen (der Verweis zeigt auf den falschen Abschnitt, der Grundsatz steht in ADR 0002, 6.1, Absatz "Anlass"); die **Wirkung der Gates im laufenden Harness**. Frühere Abnahmen, Freigaben und Bestätigungen werden durch diesen Eintrag weder erweitert noch sonst berührt, ausser der Bestätigung des Eintrags zur Abnahme von Posten 1. Was frühere Einträge und Nachträge zum Stand von Posten 4 und 5 sagen ("neu erfasst, nicht gebaut"), bleibt als Stand ihres Tages stehen (ADR 0002, 6.1, Absatz "Anlass").

**Protokollvermerk zur Form** (Protocol Master, 4.2): Formweg 1 — Merge des Pull Requests, Beleg der Merge-Commit `998f81d9fffe3970baf870d04e44576eda534fcc` (Repository `valITino/r3cosint`, Pull Request #27); der Merge-Commit `f8cb47867fe09b80adb623a6c37fb6d800c49f1c` (Repository `valITino/r3coscrum`, Pull Request #17) belegt die Bestätigung des Übergabevermerks. Die Angaben zu den beiden Merges, zu den Zeitstempeln, zum Wortlaut der Pull Requests und der Weisung und zu den Kommentarzahlen sind der Erhebung des Koordinators vom 2026-10-21 entnommen (Merge-Fakten mit `git` und dem GitHub-Werkzeug erhoben, dazu der Nachtrag von 16:54 UTC) — Fremdbeleg, von dieser Rolle nicht nachgemessen; Zitate stehen in der Schreibweise des ADR (die Erhebung gibt Teile in ASCII-Umschrift wieder, etwa "Uebergabevermerk"). Die Arbeitszweige gleichen Namens wurden nach den Merges in beiden Repositories neu von origin/main gesetzt und mit `--force-with-lease` gepusht (nur gemergte Historie); für den Stand der Pull Requests massgeblich sind die Prüfsummen oben, nicht der Zweigname.

**Bestätigung des Eintrags (Nachtrag vom 2026-10-22).** Mit dem Merge des Pull Requests #28 des Repositories `valITino/r3cosint` am 2026-10-22 (Merge-Commit `95cafc9cc31773a6c29d977ec9c3b97af5a1f047`, siehe den Unterabschnitt darunter) ist dieser Eintrag bestätigt — nach dem Wortlaut des Pull Requests ("Zugleich Bestätigung des Eintrags zur Abnahme von Posten 4 und 5 (ADR 0002, Abschnitt 10, eingetragen in D1)", wörtliches Teilzitat). Am Wortlaut des Eintrags ändert die Bestätigung nichts; was er zum Stand des 2026-10-21 sagt, etwa dass die Posten 2, 3, 6 und 7 nicht umfasst sind, bleibt als Stand dieses Tages stehen (ADR 0002, 6.1, Absatz "Anlass").

### Abnahme von Posten 2, 6 und des Teils von Posten 7 am Prototyp-Gate unter R3-Q-010 — Prototyp-Gate L05 bis L08, L23, L24, eigene Zeitgrenze — erteilt am 2026-10-22, eingetragen am 2026-10-22

| | |
|---|---|
| **Vorgelegt** | 2026-10-22, eröffnet 07:16:13 UTC, mit der Übergabe `docs/uebergaben/2026-10-22_c3-prototyp-gate.md`; vorgelegt zur Abnahme mit dem Pull Request #28 des Repositories `valITino/r3cosint` (Titel: "D1 und C3: Abnahme von Posten 4 und 5 eingetragen; Posten 2, 6 und Prototyp-Teil von Posten 7 unter R3-Q-010 gebaut (Merge = Abnahme von Posten 2, 6 und des Teils von Posten 7 am Prototyp-Gate)"), Arbeitszweig ccr-0cbb4387-oe1i3c, Kopf (`head.sha`) `4a27245973ecbbc5d29b02d0bdfb4d8fa38935a7`, Basis `998f81d9fffe3970baf870d04e44576eda534fcc` (Merge-Commit von #27), 3 Commits (`529ce5a568be573cd36c853967f9739893328cd2` D1, `b19c7b0cb2b701be3dbe646d2cf6c892e4fb3810` C3, `4a27245973ecbbc5d29b02d0bdfb4d8fa38935a7` Nachweisverzeichnis), 9 Dateien, +967/-92 |
| **Formweg** | **Merge des Pull Requests** — der erste der beiden in ADR 0002, Abschnitt 10, Punkt 6 genannten Formwege. Wortlaut im Text des Pull Requests #28 zur Bedeutung des Merges: "**Merge = Abnahme von Posten 2 (L05 bis L08: vier Schreibweisen in beiden Richtungen, JS-Zuweisungen mit Leerraum), Posten 6 (L23, L24: Rückgabewert-Prüfung der sieben sed- und tr-Schritte) und des Teils von Posten 7 am Prototyp-Gate (eigene Zeitgrenze 12 s plus 1 s Nachlauf durch Selbstaufruf unter `timeout`) unter R3-Q-010** im Umfang der Übergabe docs/uebergaben/2026-10-22_c3-prototyp-gate.md einschliesslich der dort benannten Restpunkte, des gewollten Durchlasses für den blossen JS-Modulnamen `import("backend")` (Entscheid des Software Architects vom 2026-10-22) und der Berichtigung zur Laufzeit (gemessenes Maximum statt Quote) — erster Formweg, ADR 0002, Abschnitt 10. Zugleich Bestätigung des Eintrags zur Abnahme von Posten 4 und 5 (ADR 0002, Abschnitt 10, eingetragen in D1) und der Lesart des Koordinators zum Register; zugleich Annahme der Register-Nachträge im vorgelegten Stand (SR-003 Teilstand, SR-004 mit CVSS 3.1 Basiswert 4.7, SR-005 und SR-006 neu, offen)." |
| **Merge-Commit** | `95cafc9cc31773a6c29d977ec9c3b97af5a1f047` ("Merge pull request #28 from valITino/ccr-0cbb4387-oe1i3c"), Eltern `998f81d9fffe3970baf870d04e44576eda534fcc` (main; zugleich der Merge-Commit von #27) und `4a27245973ecbbc5d29b02d0bdfb4d8fa38935a7` (Kopf des Arbeitszweigs, zugleich `head.sha` des Pull Requests, also unverändert gemergt) |
| **Datum** | 2026-10-22, 14:59:00 UTC (16:59:00 MESZ) nach dem GitHub-Werkzeug (`merged_at`); der Merge-Commit trägt nach git 16:58:59 +02:00, das sind 14:58:59 UTC — eine Sekunde Unterschied zwischen den beiden Quellen |
| **Abgenommener Stand des Zweigs** | `4a27245973ecbbc5d29b02d0bdfb4d8fa38935a7` |
| **Auftraggeber (S-01)** | Merge durch das Konto des Repository-Eigentümers (`merged_by` `valITino`), ebenso für den Pull Request #18 im Repository `valITino/r3coscrum`; Name nach offenem Entscheid E-11 nicht im Repository geführt |
| **Zugehöriger Pull Request im Methodik-Repository** | Pull Request #18 (Übergabevermerk) des Repositories `valITino/r3coscrum`, gemergt am 2026-10-22, 14:59:51 UTC (`merged_at`; der Merge-Commit trägt nach git 14:59:50 UTC, also eine Sekunde früher); Merge-Commit `b26f286ef9680a741c0de5294d80543bace44de8` ("Merge pull request #18 from valITino/ccr-0cbb4387-oe1i3c"), Eltern `afa10059889a4602e3df3040438045c659164fca` (main; Bot-Commit der Automatik "nachweise: Stand d7d539ebea07043201d58e36c8abafec54045848 aus r3cosint", 14:59:26 UTC) und `078ee0076056592c374dd0724c232173177969d6` (Kopf des Pull Requests, also unverändert gemergt); `merged_by` `valITino`; 0 Kommentare, 0 Reviews, 0 Review-Threads. Wortlaut im Text des Pull Requests #18 zur Bedeutung des Merges: "**Merge = Bestätigung des Übergabevermerks** in UEBERGABE.md zur Sitzung vom 2026-10-21/22 (D1 und C3). Die Abnahme von Posten 2, Posten 6 und des Teils von Posten 7 am Prototyp-Gate erfolgt durch den Merge des zugehörigen Pull Requests im Produkt-Repository valITino/r3cosint; dieser Merge hier spricht keine Abnahme aus." Nach dem Merge von #28 und vor dem Merge von #18 setzte die Automatik des Produkt-Repositories zwei Bot-Commits auf main des Repositories `valITino/r3coscrum`: `986f731c571bdb08938a1852dc7d94096913b517` (Nachweise zum Stand `95cafc9cc31773a6c29d977ec9c3b97af5a1f047`, 14:59:12 UTC, zwischen den Merges von #28 und #29) und `afa10059889a4602e3df3040438045c659164fca` (Nachweise zum Stand `d7d539ebea07043201d58e36c8abafec54045848`, 14:59:26 UTC, nach dem Merge von #29). Die Angaben zu #18 und zu den beiden Bot-Commits stammen aus der Ergänzung des Koordinators zu seiner Erhebung (Fremdbeleg, von dieser Rolle nicht nachgemessen). Der Formweg dieses Eintrags ist allein der Merge von #28 |
| **Kommentare, Reviews, Auflagen** | **0 Kommentare, 0 Reviews, 0 Review-Threads, keine Auflagen in diesen Kanälen — für beide Pull Requests** (GitHub-Werkzeug; für #28 `get_comments`, `get_reviews` und `get_review_comments`) |
| **Weisung über den zweiten Formweg** | Keine neue Weisung nach den Merges (Erhebung des Koordinators). Der Text des Pull Requests #28 nennt die Weisungen vom 2026-10-22 (zweiter Formweg) im Wortlaut: "Ich vertraue dir und deinen super Fähigkeiten und gehen nach deiner Empfehlung"; "Nein, FFHS braucht es nicht, nach Übergangsfrist weg". Sie stehen im Status-Block von ADR 0002, 6.13 (Nachtrag vom 2026-10-22 — C3) und sind nicht der Formweg dieses Eintrags. Lesart des Koordinators (nicht Wortlaut einer Weisung): Die Einheit PS-2 beginnt mit diesem Eintrag, nach der Vorlage `docs/vorlagen/2026-10-22_prozess-schnitt.md`, Abschnitt 3 ("PS-2 ADR-Aufteilung (nach dem Merge von PS-1, weil die Nachtrag-Regel vorher geändert sein muss)"); die Annahme von PS-2 erfolgt durch den Merge des Pull Requests dieser Einheit |
| **Eingetragen am** | 2026-10-22 |

**Was die Abnahme umfasst.** Die **Abnahme von Posten 2, 6 und des Teils von Posten 7 am Prototyp-Gate unter R3-Q-010** (Posten 2: L05 bis L08; Posten 6: L23, L24; Posten 7, Teil am Prototyp-Gate: eigene Zeitgrenze; Bau und Verifikation in ADR 0002, 6.13, Status-Block, Nachtrag vom 2026-10-22 — C3, und 6.13 c, Nachtrag vom 2026-10-22 zum Bau von C3 — Einordnungen und Berichtigung) im Umfang der Übergabe `docs/uebergaben/2026-10-22_c3-prototyp-gate.md` in der Fassung des abgenommenen Stands einschliesslich der dort benannten Restpunkte, des gewollten Durchlasses für den blossen JS-Modulnamen `import("backend")` (Entscheid des Software Architects vom 2026-10-22) und der Berichtigung zur Laufzeit (gemessenes Maximum statt Quote), im Wortlaut der Zeile "Formweg". Die Restpunkte gehören nach dem Wortlaut zum Umfang, wie die Übergabe sie benennt; behoben sind sie dadurch nicht. Nach dem Wortlaut gilt der Merge zugleich als **Bestätigung des Eintrags zur Abnahme von Posten 4 und 5** (Nachtrag vom 2026-10-22 im Unterabschnitt darüber), als **Bestätigung der Lesart des Koordinators zum Register** (ADR 0002, 6.13, Status-Block, Nachtrag vom 2026-10-21 zur Abnahme von Posten 4 und 5: Annahme der Datei im vorgelegten Stand, keine Abnahme der CVSS-Bewertungen, Pflege beim Vulnerability Manager) und als **Annahme der Register-Nachträge im vorgelegten Stand** (SR-003 Teilstand, SR-004 mit CVSS 3.1 Basiswert 4.7, SR-005 und SR-006 neu, offen). Vorgelegter Stand ist der Kopf `4a27245973ecbbc5d29b02d0bdfb4d8fa38935a7`; spätere Änderungen an `docs/11_Schwachstellenregister.md` sind davon nicht erfasst.

**Was sie NICHT umfasst.** Nach dem Text des Pull Requests (Zusammenfassung in der Erhebung des Koordinators, kein Wortzitat): der **Posten 3** unter R3-Q-010 (L09, C4); die **Posten 8, 9 und 10** (neu erfasst, mit C4 terminiert; der Schnitt von C4 ist vor dem Bau festzulegen); der **Teil von Posten 7 am main-Gate** (eigene Einheit vor der Freigabe des Grundgerüsts, Einordnung ausstehend) und die **Restpunkte am main-Gate** vom 2026-10-21; der **Prozess-Schnitt** (eigene Einheit, eigener Pull Request); das Kriterium `R3-Q-011_regel_im_startkontext`; die **Terminierung** von `Skill` (ADR 0002, 6.14 e); die **Berichtigung** des Verweises "(ADR 0002, 6.1.2)" an bestehenden Stellen (der Verweis zeigt auf den falschen Abschnitt, der Grundsatz steht in ADR 0002, 6.1, Absatz "Anlass"); die **Wirkung der Gates im laufenden Harness** (ungemessen). Der Merge des Pull Requests #18 im Methodik-Repository spricht nach dessen Text keine Abnahme aus. Frühere Abnahmen, Freigaben und Bestätigungen werden durch diesen Eintrag weder erweitert noch sonst berührt, ausser der Bestätigung des Eintrags zur Abnahme von Posten 4 und 5. Was frühere Einträge und Nachträge zum Stand von Posten 2, 6 und 7 sagen (etwa "Neu erfasst, nicht gebaut" im Nachtrag vom 2026-10-21 — Posten 4 und 5 gebaut, Posten 6 und 7 erfasst, und die Sätze, die C3 als künftig beschreiben, im Status-Block von ADR 0002, 6.13), bleibt als Stand ihres Tages stehen (ADR 0002, 6.1, Absatz "Anlass").

**Protokollvermerk zur Form** (Protocol Master, 4.2): Formweg 1 — Merge des Pull Requests, Beleg der Merge-Commit `95cafc9cc31773a6c29d977ec9c3b97af5a1f047` (Repository `valITino/r3cosint`, Pull Request #28); der Merge-Commit `b26f286ef9680a741c0de5294d80543bace44de8` (Repository `valITino/r3coscrum`, Pull Request #18) belegt die Bestätigung des Übergabevermerks. Die Angaben zu den Merges, zu den Zeitstempeln, zum Wortlaut der Pull Requests und zu den Kommentarzahlen sind der Erhebung des Koordinators vom 2026-10-22 entnommen (Merge-Fakten mit `git` und dem GitHub-Werkzeug erhoben, dazu die Ergänzung zu #18 und zu den beiden Bot-Commits) — Fremdbeleg, von dieser Rolle nicht nachgemessen. Die Erhebung gibt für #28 die git-Zeit des Merge-Commits (16:58:59 +02:00) als gleich mit `merged_at` (14:59:00 UTC) an; umgerechnet sind 16:58:59 +02:00 aber 14:58:59 UTC, eine Sekunde vor `merged_at`, wie bei #29 (16:59:14 +02:00 gegen 14:59:15 UTC) und bei #18 (14:59:50 UTC gegen 14:59:51 UTC); die Zeilen oben führen die umgerechneten Zahlenwerte. Nach `merged_at` folgten die Merges in der Reihenfolge #28 (14:59:00 UTC), #29 (14:59:15 UTC), #18 (14:59:51 UTC). Der Arbeitszweig dieser Einheit heisst wie der Zweig des Pull Requests #28 (ccr-0cbb4387-oe1i3c) und steht nach Angabe des Koordinators auf dem Merge-Commit `d7d539ebea07043201d58e36c8abafec54045848` von #29, dem Stand von main nach den Merges; für den Stand der Pull Requests massgeblich sind die Prüfsummen oben, nicht der Zweigname.

### Annahme des Prozess-Schnitts PS-1 (Regeln) — Merge des Pull Requests #29 — erteilt am 2026-10-22, eingetragen am 2026-10-22

| | |
|---|---|
| **Vorgelegt** | 2026-10-22, eröffnet 14:27:49 UTC, mit der Vorlage `docs/vorlagen/2026-10-22_prozess-schnitt.md`; vorgelegt zur Annahme mit dem Pull Request #29 des Repositories `valITino/r3cosint` (Titel: "Prozess-Schnitt PS-1: Regeln (Merge = Annahme der Regeländerungen und der Fortschreibung des Projektauftrags 1.3, 3.3, 6.6)"), Arbeitszweig ccr-0cbb4387-oe1i3c-ps1 (abgezweigt vom Kopf von #28), Kopf (`head.sha`) `9234a373cb7d5a1523002fdfb43f888cc874cc73`, Basis `998f81d9fffe3970baf870d04e44576eda534fcc` (Merge-Commit von #27), 5 Commits (die drei von #28 und `291e8a509b244b3fc6c2f76d5dafb87a18875e1d` PS-1, `9234a373cb7d5a1523002fdfb43f888cc874cc73` Nachweisverzeichnis, 84 Artefakte), 16 Dateien, +1773/-103 |
| **Formweg** | **Merge des Pull Requests** — der erste der beiden in ADR 0002, Abschnitt 10, Punkt 6 genannten Formwege. Wortlaut im Text des Pull Requests #29 zur Bedeutung des Merges: "**Merge = Annahme** (erster Formweg, ADR 0002, Abschnitt 10) der Vorlage docs/vorlagen/2026-10-22_prozess-schnitt.md mit der Zerlegung in PS-1 bis PS-4, der Fortschreibungsabsätze im Projektauftrag 1.3, 3.3 und 6.6 (E-PS-1), der neuen Regeln in .claude/rules/dokumentation.md (ADR als aktueller Stand mit Entscheidlog, Backlog-Form, Übergabe und Pull Request je Sitzung, eine Textprüfung je Einheit) und der neu gefassten Statuszeile und Gate-Tabelle in CLAUDE.md (frühere Fassung in git bis Commit `4a27245973ecbbc5d29b02d0bdfb4d8fa38935a7`). Zugleich Bestätigung der Lesart zu E-PS-2 (Archivzweig archiv/r3coscrum in r3cosint) und E-PS-5 (Übergangsfrist bis zum Merge der Freigabe des Grundgerüsts), beide mit der Weisung vom 2026-10-22 erteilt und in PS-4 umzusetzen." |
| **Merge-Commit** | `d7d539ebea07043201d58e36c8abafec54045848` ("Merge pull request #29 from valITino/ccr-0cbb4387-oe1i3c-ps1"), Eltern `95cafc9cc31773a6c29d977ec9c3b97af5a1f047` (main; zugleich der Merge-Commit von #28) und `9234a373cb7d5a1523002fdfb43f888cc874cc73` (Kopf des Arbeitszweigs, zugleich `head.sha` des Pull Requests, also unverändert gemergt) |
| **Datum** | 2026-10-22, 14:59:15 UTC (16:59:15 MESZ) nach dem GitHub-Werkzeug (`merged_at`); der Merge-Commit trägt nach git 16:59:14 +02:00, das sind 14:59:14 UTC — eine Sekunde Unterschied zwischen den beiden Quellen. Der Merge folgte dem Merge von #28 nach 15 Sekunden (`merged_at` 14:59:00 UTC und 14:59:15 UTC) |
| **Angenommener Stand des Zweigs** | `9234a373cb7d5a1523002fdfb43f888cc874cc73` |
| **Auftraggeber (S-01)** | Merge durch das Konto des Repository-Eigentümers (`merged_by` `valITino`); Name nach offenem Entscheid E-11 nicht im Repository geführt |
| **Zugehöriger Pull Request im Methodik-Repository** | keiner. Der Pull Request #18 des Repositories `valITino/r3coscrum` (Übergabevermerk) gehört zu #28 (D1 und C3), nicht zu PS-1; er steht beim Eintrag zu #28 im Unterabschnitt darüber |
| **Kommentare, Reviews, Auflagen** | **0 Kommentare, 0 Reviews, 0 Review-Threads, keine Auflagen in diesen Kanälen** (GitHub-Werkzeug: `get_comments`, `get_reviews`, `get_review_comments`) |
| **Weisung über den zweiten Formweg** | Der Text des Pull Requests #29 nennt die Weisung vom 2026-10-22 (zweiter Formweg), Wortlaut: "Mach einfach, ich erlaube es dir. Vertraue dir." Sie ist nach der Vorlage `docs/vorlagen/2026-10-22_prozess-schnitt.md`, Abschnitt 7, eine Weisung zur Vorlage mit den Entscheiden E-PS-1 bis E-PS-5; die Lesart des Koordinators dort lautet unter anderem: "Der Merge jedes Pull Requests bleibt der Entscheid (erster Formweg)." Die beiden früheren Weisungen vom selben Tag ("Ich vertraue dir und deinen super Fähigkeiten und gehen nach deiner Empfehlung"; "Nein, FFHS braucht es nicht, nach Übergangsfrist weg") stehen im Status-Block von ADR 0002, 6.13 (Nachtrag vom 2026-10-22 — C3). Nach den Merges ist keine neue Weisung ergangen (Erhebung des Koordinators). Formweg dieses Eintrags ist allein der Merge von #29 |
| **Eingetragen am** | 2026-10-22 |

**Was die Annahme umfasst.** Die **Annahme des Prozess-Schnitts PS-1 (Regeln)** im Wortlaut der Zeile "Formweg": die Vorlage `docs/vorlagen/2026-10-22_prozess-schnitt.md` mit der Zerlegung in PS-1 bis PS-4; die Fortschreibungsabsätze im Projektauftrag 1.3, 3.3 und 6.6 (E-PS-1); die neuen Regeln in `.claude/rules/dokumentation.md` (ADR als aktueller Stand mit Entscheidlog, Backlog-Form, Übergabe und Pull Request je Sitzung, eine Textprüfung je Einheit); die neu gefasste Statuszeile und Gate-Tabelle in `CLAUDE.md` (frühere Fassung in git bis Commit `4a27245973ecbbc5d29b02d0bdfb4d8fa38935a7`). Nach dem Wortlaut gilt der Merge zugleich als **Bestätigung der Lesart zu E-PS-2** (Archivzweig archiv/r3coscrum in r3cosint) und **E-PS-5** (Übergangsfrist bis zum Merge der Freigabe des Grundgerüsts), beide mit der Weisung vom 2026-10-22 erteilt und in PS-4 umzusetzen. Die neue Regel hält zu diesem ADR fest: "Bis zur Aufteilung (PS-2) gilt für ADR 0002 der Stand vom 2026-10-22." (`.claude/rules/dokumentation.md`, Abschnitt "Architecture Decision Records").

**Was sie NICHT umfasst.** Nach dem Text des Pull Requests (Zusammenfassung in der Erhebung des Koordinators, kein Wortzitat): **PS-2** (Aufteilung von ADR 0002 in ADR 0003 bis 0005), **PS-3** (Backlog-Rahmen als Tabellen) und **PS-4** (Einfalten von r3coscrum); **C4** (Posten 3, 8, 9 und 10 unter R3-Q-010); **O-29**; **E-PS-3** (Widerruf der Tokens, Archivierung von r3coscrum), **E-PS-4** (Sichtbarkeit) und die Löschung nach der Frist, die Handlungen des Auftraggebers bleiben; die **drei Anhänge** der Vorlage, Entwürfe der Rollen, nicht nach 3.4 geprüft, die in PS-2 bis PS-4 nachgemessen werden. Der Satz im Text des Pull Requests "Wird er vor #28 gemergt, gilt der Merge zugleich als Abnahme im Umfang von #28" ist nicht eingetreten: #28 wurde 15 Sekunden vorher gemergt (`merged_at` 14:59:00 UTC gegen 14:59:15 UTC); die Abnahme im Umfang von #28 beruht allein auf dem Merge von #28 (Unterabschnitt darüber). Frühere Abnahmen, Freigaben und Bestätigungen werden durch diesen Eintrag weder erweitert noch sonst berührt.

**Protokollvermerk zur Form** (Protocol Master, 4.2): Formweg 1 — Merge des Pull Requests, Beleg der Merge-Commit `d7d539ebea07043201d58e36c8abafec54045848` (Repository `valITino/r3cosint`, Pull Request #29). Die Angaben zum Merge, zu den Zeitstempeln, zum Wortlaut des Pull Requests und zu den Kommentarzahlen sind der Erhebung des Koordinators vom 2026-10-22 entnommen, die Merge-Fakten erhoben mit `git` und dem GitHub-Werkzeug — Fremdbeleg, von dieser Rolle nicht nachgemessen. Der Zweig des Pull Requests war vom Kopf von #28 abgezweigt und enthielt dessen drei Commits; gemergt wurde nach #28, dessen Merge-Commit der erste Elternteil des Merge-Commits von #29 ist. Die beiden Nachweis-Commits der Automatik im Repository `valITino/r3coscrum` und der Pull Request #18 stehen beim Eintrag zu #28; #18 gehört nicht zu diesem Eintrag.
