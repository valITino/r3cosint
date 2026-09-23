# Übergabe 2026-09-23 (2) — E4.2: Erkennungslücken ST-04, ST-05 und P-01 am Prototyp-Gate geschlossen (R3-Q-010)

Zweite Arbeitseinheit des Tages, als Aufgabe #2 geführt (O-23, Entscheid E-H).
Grundlage: Sitzungsauftrag vom 2026-09-23, ADR 0002, 6.13 g ("E4.2 — Prototyp-Gate,
Erkennungslücken: ST-04, ST-05, P-01"), Backlog R3-Q-010. Aufgesetzt auf E4.1
(`a3f5cb24247b1c471e48b6b9305c552af08ff7a7`, Nachweisverzeichnis
`1ce0f30852e252f78937b0d27beafbeb7b3ae040`). Vorgehen nach 6.13 g: Soll zuerst
auf 2, dann das Gate, dann der Vermerk.

## Ergebnis in einem Absatz

Die drei belegten Lücken sind am Prototyp-Gate `.claude/hooks/block-prototype-import.sh`
geschlossen (SecDevOps Engineer): Richtung 1 erkennt den Verzeichnisimport ohne
Schrägstrich und den Rückstrich-Pfad (ST-04), Richtung 2 den Präfix `./` vor `../`
(ST-05), die HTML-Formen `src=` und `href=` sowie die Python-Modul-, Punkt- und
Funktionsform (P-01, Richtungsgleichheit); beide Meldungen nennen 5.6 und die
Richtung. Im Prüfmittel stand das Soll der 16 Fälle zuerst auf 2 — der Lauf fiel mit
genau diesen 16 Kennungen —, dann folgte die Gate-Änderung, zuletzt die Entfernung
der Befundkennungen; dazu der neue Fall B43. Der Lauf führt jetzt 225 Fälle, beide
Modi enden mit Rückgabewert 0 (elf Mutationen), die Zeile "belegte Lücken" nennt nur noch die zwölf
Fälle von ST-09 und ST-13 (E4.3). Abgeschlossen sind
`R3-Q-010_prototyp_gate_pfadformen` und `R3-Q-010_prototyp_gate_richtungsgleichheit`
(je eine statische und eine dynamische Runde mit
je einem blockierenden Befund, Behebung, Nachprüfung bestanden). Keine Zeile am main-Gate, am `Makefile` und an der Kette.

## Entscheidungen dieser Einheit

1. **Muster statt Liste.** Hinter `prototype` sind Schrägstrich, Rückstrich oder
   schliessendes Anführungszeichen zulässig; `prototypes`, `prototyp` und
   `prototype_alt` treffen weiterhin nicht (Gegenproben P16, P17, P26).
2. **Python-Formen in Richtung 2 nur für die Bauwurzeln** `backend`, `frontend` und
   `deploy` nach ADR 0002, nicht für die generischen Namen `src`, `app`, `lib`,
   `server`, `packages`, `apps`: `import app` wäre in einem Python-Prototyp ein
   plausibles Fremdmodul, der Fehlalarm teurer als die engere Deckung (Begründung
   im Rumpfkommentar des Gates). Für Import-Pfade mit Schrägstrich bleibt die
   volle Liste.
3. **Verzeichnisliste einmal definiert** (Variable `WURZELN`), damit der Suchtext
   der Mutation MP3 eindeutig bleibt; MP1 und MP3 im Prüfmittel angepasst.
4. **Die Meldung nennt die Richtung** ausdrücklich ("Richtung 1 (Produktionscode
   -> Prototyp)", "Richtung 2 (Prototyp -> Produktionscode)"), wie das Kriterium
   Richtungsgleichheit es verlangt; die Nennung von 5.6 bleibt.
5. **Keine Härtung über die belegten Lücken hinaus** (ADR 0002, 6.13 c): die
   Bash-Prüfung (ST-09), ST-13 und die Prüfstand-Fälle (ZF9, ZF10c, ZF10d, ZF7b,
   ZF2a, L01 bis L04) sind unverändert.

## Was gebaut ist

- `.claude/hooks/block-prototype-import.sh`: fünf Muster der Richtung 2 (Import-
  Pfad mit `(\./|\.\./)*`, Alias, `src=`/`href=`, Python-Modulform, Funktionsform),
  zwei Muster der Richtung 1 erweitert, zwei Meldungen mit Richtung,
  Kopfkommentar mit Stand seit E4.2, weiterhin reines ASCII.
- `scripts/pretooluse-gates-selbsttest.sh`: 225 Fälle (Prototyp 65 mit Soll 2,
  48 mit Soll 0), 17 Fälle blockierend statt belegte Lücke, 22 neue Fälle aus den
  Prüfrunden (B43 bis B51 und ZF6f blockierend, P27 bis P32 Gegenproben gegen
  Fehlalarme, L05 bis L11 Prüfstand), Meldungsprüfung bei Soll 2 (5.6 oder 3.2 c,
  Richtung bei Dateiwerkzeugen des Prototyp-Gates), elfte Mutation MP6 an der
  Meldung, MP1 und MP3 angepasst, FEHLEND in einer Kriterienliste wirkt auf den
  Rückgabewert (Restbefund N-2 aus E4.1 erledigt).
- Nachführung: ADR 0002 (6.13 Nachtrag E4.2, Abschnitt 9, Kopftabelle), Backlog
  (Stand-Vermerk, elfte Nachführung), CLAUDE.md, Nachweiserzeuger, diese
  Übergabe; Methodik-Repository (Übergabevermerk).
- Sitzungsunterbruch: das Nutzungslimit des Auftraggebers hat den Engineer
  während des Behebungsauftrags abgebrochen (ohne Änderung); Fortsetzung nach
  der Rückstellung.

## Verifikation auf einem anderen Modell

**Runde 1, statisch:** `pfadformen` **nicht bestanden** (B-1: der Prüfsatz führte
die Grammatik `import "…"` ohne `from` nicht), `richtungsgleichheit` bestanden
unter der Lesart "Bezugsform = Konstrukt"; N-1 bis N-6 (unter anderem
Fehlalarme des neuen Präfixes für Pfade, die den Prototyp nicht verlassen),
T-1 bis T-6. **Runde 1, dynamisch** (90 eigene Fälle, 30 Paarvergleiche): beide
Kriterien **nicht bestanden** — DST-E42-03 (der Prüfsatz prüfte die Meldung
nicht; eine Kopie ohne "5.6" und Richtung blieb grün), DST-E42-01 (Richtung 2
erkannte Verzeichnisimport ohne Schrägstrich und Rückstrich nicht), DST-E42-02
(Fehlalarme bei Pfaden, die den Prototyp nicht verlassen), DST-E42-04 (vier symmetrische Lücken beider
Richtungen), DST-E42-05 (`es-prototype`).
**Behebung** (SecDevOps Engineer auf Entscheid des Koordinators): Präfixe der
Richtung 2 enger (`./` nur mit folgendem `../`, `src=`/`href=` verlangen `../`),
Verzeichnisimport ohne Schrägstrich und Rückstrich in Richtung 2 für die drei
Bauwurzeln, Pfadtrenner vor `prototype` in Richtung 1, Meldungsprüfung und MP6
im Prüfmittel, 22 neue Fälle, Kopfkommentar mit Preisen und benannter
Asymmetrie. **Lesart des Koordinators:** "Bezugsform" ist das Konstrukt; die
Pfadschreibweise bleibt in Richtung 2 präfixgebunden (Wurzelpfade, beliebige
Vorspanne, `src=`/`href=` ohne Schrägstrich, doppelter Rückstrich, mehrfaches
`./`) und steht als benannte Grenze im Kopfkommentar; Prüfstand L05 bis L11.
**Nachprüfung** (je eine Runde): statisch und dynamisch je **bestanden** für
beide Kriterien am Stand `bf803ef96806c416` / `01c01113e4f79150`; Gegenprobe mit
dem Gate aus HEAD lässt genau die 26 Fälle der Einheit fallen. Restbefunde,
nicht blockierend: R-1/E-1 (Rest-Asymmetrie bei `src=`/`href=` in Richtung 2
und doppelter Rückstrich), DST-E42-N1 (mehrfaches `./` vor `../` seit der
Behebung nicht mehr erkannt), R-2 bis R-5 (Kommentare; vom Koordinator
behoben). Danach nur Text (Kommentare, Zahlen), beide Modi erneut grün
(Koordinator), Stand `fb13fb2a3054dc7d` / `b8079eab3ceefa3f`. Zählfehler des
Koordinators im Behebungsauftrag (224 statt 225 Fälle) vom Engineer gemeldet
und vom Koordinator berichtigt.

## Was offen bleibt

- E4.3: ST-09 (B09, ZF7a, ZF7c, ZF7d), ST-13 (S01, S02, S04, S05, ZF8a bis ZF8d),
  benannte Grenzen und P-10 im Kopfkommentar; Befund N-9 (Subshell-Grenze ohne
  durchlaufenden Fall) und die Prüfstand-Fälle bleiben für E4.3 und die
  Fortschreibung durch den Software Architect.
- Restbefunde aus E4.1 unverändert (N-2-Rest, NEU-1, NEU-4, N-DT-1); R-1/E-1 und DST-E42-N1 (oben), L05 bis L11 als Prüfstand:
  Entscheid des Software Architects als Fortschreibung von ADR 0002, 6.13 c.
- Unverändert: O-28 (bedingt), O-15, R3-Q-005, offene Punkte 12, 15 und 20 des
  Backlogs; Nachweisfluss.

## Protokoll (Koordinator)

- Bauauftrag an den SecDevOps Engineer (vier Schritte nach 6.13 g); Kontrolllauf
  beider Modi; Prüfaufträge an Static und Dynamic Software Tester, Behebungsauftrag,
  Nachprüfaufträge; Textkorrekturen R-2 bis R-5 und Grenze im Kopfkommentar;
  eigene Nachführung: CLAUDE.md, Nachweiserzeuger, diese Übergabe; ADR 0002
  durch den Software Architect, Backlog durch den Product Owner.
- `git add`, `make dod` (drei terminierte Lagen C, D20 und D11 A_OK, D19
  OHNE_BEFUND, Rückgabewert 2), Commit mit Kennung R3-Q-010, Push;
  `docs/NACHWEISE.md` neu erzeugt, `make dod`, zweiter Commit, Push;
  Methodik-Repository, Commit, Push.
