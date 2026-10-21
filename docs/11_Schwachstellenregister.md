# Schwachstellenregister R3cOSINT

Zweck: einziges verbindliches Verzeichnis der Schwachstellen aus Pentest, statischer Analyse, Abhängigkeits- und Containerprüfung (Projektauftrag 4.2;
Rollendatei des Vulnerability Managers, Abschnitt "Auftrag"), hier ergänzt um die dynamische Prüfung. Jeder Eintrag endet behoben mit Nachweis oder akzeptiert mit schriftlicher Begründung.
Punkt 6 der Bereitschaftsliste (5.16) lautet "Penetrationstest durchgeführt, Befunde behandelt oder mit Begründung akzeptiert"; die Lesart
"kein Eintrag ohne Endzustand" stammt aus der Rollendatei (`.claude/agents/vulnerability-manager.md`, Abschnitt "Erwartete Ausgabeform").
Pflege: nur der Vulnerability Manager. Finder melden, bewerten nicht; behoben wird durch die schreibberechtigten Rollen.
Form: ein Abschnitt je Eintrag (Quelle, CWE, CVSS 3.1, Bauteil, Status, Fälligkeit, Verweis); Kennung SR-nnn, fortlaufend, nie geändert, nach dem Muster von 6.6
(gilt für Anforderungen; hier Festlegung des Registers) im Commit-Betreff der Behebung und, soweit der Test es zulässt, im Testnamen oder Fallvermerk.
Übersicht 2026-10-21: offen 2 (SR-003, SR-004), in Behebung 2 (SR-001, SR-002), behoben mit Nachweis 0, akzeptiert mit Begründung 0.

Bewertungsgrundlage SR-001 bis SR-003 (gleicher Angreifer, gleiche Wirkung): Angreifer ist das Modell selbst, über die Eingabe des Gates, deren Länge es setzt (Befehlstext; am Prototyp-Gate auch
Dateiinhalt bei Write, Edit und NotebookEdit, MultiEdit vorsorglich). Es läuft durch, was beide Gates als gedeckt führen (ADR 0002, 6.13 c), unter anderem Push nach main, Arbeitsbaum auf main, Mirror- und
Wildcard-Push und Import zwischen Prototyp und Produktionscode. Für main liefert das serverseitige GitHub-Ruleset die harte Zusicherung, das Gate ist dort die zweite Linie (Kopfkommentar des main-Gates);
für den Prototyp-Import nennt der Befund keine zweite Linie; das Ruleset ist in den Basiswerten nicht angerechnet und nicht geprüft. Metriken: AV:L (das Gate liest nur lokale Eingabe des Harness, auch bei
Lenkung des Modells von aussen), PR:L (ein Werkzeugaufruf in der Sitzung), UI:N (das Gate entscheidet ohne Person), S:U (Gate und geschützter Zustand liegen in derselben Berechtigung der Sitzung, das
Ruleset bleibt unberührt), C:N, A:N, I:H (ohne wirksames Gate sind main bzw. die Trennung nach 5.6 ungeschützt); AC je Eintrag. Der Weg über Write, Edit und NotebookEdit ändert keine Metrik. Einstufung:
keine der acht Verfahrensgarantien (5.4) unmittelbar betroffen, die Gates sichern Entwicklungsregeln (3.2 c, 5.6). Nicht gemessen: Wirkung im laufenden Harness (die Hooks wirken in dieser Sitzung nicht),
Befehlsgrösse im Harness sowie Edit und NotebookEdit (MultiEdit vorsorglich) einzeln.

## SR-001 Umgehung der PreToolUse-Gates durch grosse Eingabe
- Befund: Beide Gates prüfen im Stand auf main mit `printf | grep -Eq` unter `set -uo pipefail`. Endet grep nach einem frühen Treffer, während printf noch schreibt, liefert die Pipeline 141 (SIGPIPE),
  die Bedingung gilt als nicht erfüllt, das Gate gibt 0; der blockierte Befehl steht vorn, danach folgt eine lange Kommentarzeile. Unter etwa 64 KiB sperrt das Gate, darüber entscheidet ein Wettlauf,
  ab 131072 Zeichen lässt es durch. Gemessen bei 200000 Zeichen, je 30 Läufe (Dynamic Software Tester): main-Gate sowie Prototyp-Gate über Bash und Write (beide Richtungen) 30 von 30 Durchlass. Vorbestehend.
- Quelle: B2-GATE-D05 (statische Prüfung), DT-B2-10 (dynamische Prüfung, Streuung der Schwelle), beide 2026-10-14; Fall L20 in `scripts/pretooluse-gates-selbsttest.sh`; Fundort ADR 0002, 6.13 c,
  Nachtrag vom 2026-10-14; Befund C1-REG-07 der statischen Prüfung des Registers; Lesebefund Static Software Tester 2026-10-21 zu dod-gate.sh (Stand `5ada002023c0ff160c26c78659727c7e8623c6f5`).
- CWE: CWE-636 (Not Failing Securely, 'Failing Open'); Ursache CWE-394 (legitimer, aber unerwarteter Rückgabewert 141).
- CVSS 3.1: CVSS:3.1/AV:L/AC:L/PR:L/UI:N/S:U/C:N/I:H/A:N, Basiswert 5.5 (Mittel); AC:L, weil der Angreifer die Länge über der Schwelle wählt und keinen Wettlauf gewinnen muss. Sensitivität: PR:N ergäbe 6.2,
  S:C 6.5, beides zusammen 7.1 (hoch). Rechnung: Impact 6.42 x 0.56 = 3.595, Exploitability 8.22 x 0.55 x 0.77 x 0.62 x 0.85 = 1.835, Summe 5.430, aufgerundet 5.5.
- Bauteil: `.claude/hooks/block-main-write.sh` und `.claude/hooks/block-prototype-import.sh` (beide gemessen). `.claude/hooks/dod-gate.sh` nach dem Lesebefund nicht betroffen: gleiche Bauform an Z. 514 und
  Z. 528; Z. 514 wirkt nur in sicherer Richtung, Z. 528 stünde in unsicherer Richtung (Durchlass ohne Kette), ihr Auslöser ist nicht erreichbar, solange tools_zeile einzeilig bleibt (nicht gemessen). Weder
  Neubewertung noch eigener Eintrag, da keine Umgehung belegt ist; andere grep-Fehlerstatus brauchen Schreibzugriff auf die Rollendatei. Neubewertung bei mehrzeiliger tools_zeile oder gemessenem Fehlerstatus.
- Status: in Behebung (Posten 5, Einheit C2): gebaut und verifiziert am 2026-10-21; Wechsel auf "behoben mit Nachweis" nach dem Commit der Einheit, in der nächsten Einheit.
- Fälligkeit: Bau von Posten 5 zusammen mit Posten 4, vor Posten 2 und 3 (Entscheid des Koordinators, delegiert durch die Weisung vom 2026-10-21; ADR 0002, 6.13,
  Status-Block, Nachtrag vom 2026-10-21); spätestens vor der Freigabe des Grundgerüsts (ADR 0002, 6.13 c).
- Verweis: Posten 5 unter R3-Q-010 (Sammelposten in `docs/05_Product_Backlog.md`, kein eigener Eintrag, daher keine Meldung an den Product Owner). Behebung: Hilfsfunktion trifft, Status aus PIPESTATUS,
  nicht Here-String und nicht grep ohne -q (Präzisierung des Software Architects), Muster unverändert. Commit-Prüfsumme folgt mit dem Commit der Einheit. Akzeptanzbegründung: keine.
- Schliesskriterium (erfüllt, Nachweis 2026-10-21): L20 (main-Gate), L22 (Prototyp-Gate, Bash), B64 und B65 (Prototyp-Gate Write, beide Richtungen) je Soll 2 in 30 von 30 Läufen (altes Gate 30 von 30 Durchlass),
  Vermerke von L20 und L22 nennen SR-001; Mutationen MM16 und MP12 erkannt; Prüfmittel in beiden Modi Rückgabewert 0 (447 Fälle, 49 Mutationen, 36 Fallklassen); Verifikation in vier Delta-Runden, je Static und Dynamic Software Tester auf einem anderen Modell.
- Vermerk ST-C2-D-01: Unter gesetzter Umgebungsvariable POSIXLY_CORRECT liessen beide Gates durch (Fälle S17, S18, S19); behoben mit unset POSIXLY_CORRECT als erster Anweisung beider Gates (Mutationen MM30, MP15).

## SR-002 Zeitgrenze des main-Gates bei vielen Zeilenfortsetzungen gerissen (DT-C2-01)
- Befund: Die Entfernung der Zeilenfortsetzungen lief seit Posten 1 als sed-Schleife, quadratisch in der Zahl der Fortsetzungen; ab etwa 150 KB reisst das main-Gate die Hook-Zeitgrenze des Harness
  (15 s), der Hook wird abgebrochen und lässt durch. Gemessen vor der Behebung (Dynamic Software Tester): 120 KB Fortsetzungen 8,9 s, 300 KB über 20 s (Messgrenze); sed allein 20000 Fortsetzungen 9,2 s,
  50000 Fortsetzungen 62 s. Auf main seit dem Merge von Posten 1 (`5ada002023c0ff160c26c78659727c7e8623c6f5`, 2026-10-16); vorbestehend, nicht durch C2 verursacht.
- Quelle: DT-C2-01 (Dynamic Software Tester 2026-10-21); Einordnung Software Architect 2026-10-21: Behebung in C2 als Teil von Posten 4 b, kein eigener Posten, im Register wegen des Zeitraums seit Posten 1.
- CWE: CWE-407 (Inefficient Algorithmic Complexity), Folge CWE-636 (Failing Open: Hook-Abbruch ist Durchlass). Bauteil: `.claude/hooks/block-main-write.sh` (gemessen).
- CVSS 3.1: CVSS:3.1/AV:L/AC:L/PR:L/UI:N/S:U/C:N/I:H/A:N, Basiswert 5.5 (Mittel), Rechnung wie SR-001. Gleicher Angreifer und gleiche Wirkung wie SR-001 (Bewertungsgrundlage), anderer Mechanismus: nicht der
  Schreiber, sondern die Laufzeit bricht die Prüfung ab; AC:L, weil der Angreifer die Länge über der Schwelle wählt und die Laufzeit quadratisch wächst (300 KB: über 20 s). Sensitivität: AC:H ergäbe 4.7.
- Status: in Behebung (C2, Teil von Posten 4 b), gebaut und verifiziert am 2026-10-21; Wechsel auf "behoben mit Nachweis" nach dem Commit der Einheit. Fälligkeit: wie SR-001.
- Verweis: Posten 4 b unter R3-Q-010 (Sammelposten in `docs/05_Product_Backlog.md`): sed -z mit gleicher Bedeutung statt der Schleife (Rückstriche paarweise von links, nur das Paar Rückstrich und
  Zeilenumbruch fällt weg). Commit-Prüfsumme folgt mit dem Commit der Einheit. Akzeptanzbegründung: keine.
- Schliesskriterium (erfüllt, Nachweis 2026-10-21): Fall A105 (300 KB Fortsetzungen) Soll 2, Messeingabe mit 50000 Fortsetzungen in 30 von 30 Läufen Rückgabewert 2, längster Lauf 0,12 s; Gegenprobe G94;
  Gleichheit mit der Schleife an 88573 Zeichenfolgen; Mutation MM22 erkannt; Prüfmittel mit Zeitgrenze 14 s je Gate-Aufruf; beide Modi Rückgabewert 0; Verifikation in vier Delta-Runden, je Static und Dynamic Software Tester auf einem anderen Modell.
- Restpunkt DT-C2-G-01 (Posten 4 c, nicht SR-002; nicht geschlossene Grenze der Behebung): Ein Umleitungsoperator mit & vor dem Pfad trennt den Abschnitt (Durchlass der Basename-Form); vorbestehend, offen, Fall und Bewertung mit der nächsten Änderung am main-Gate.

## SR-003 Keine eigene Zeitgrenze in den PreToolUse-Gates (Posten 7)
- Befund: Keines der beiden Gates zieht eine eigene Zeitgrenze, obwohl `.claude/rules/claude-konfiguration.md` es für jedes Gate verlangt (ADR 0002, 6.12.12); überschreitet ein Hook die Grenze des Harness
  (15 s), wird er abgebrochen und lässt durch. Gemessen am main-Gate nach der Behebung von SR-002, Zeile aus '&' hinter `git worktree add /tmp/wt feature`: 5 MB 8,07 s, 7 MB 11,82 s, 8 MB 14,22 s,
  9 MB 17,16 s, 10 MB 19,82 s (über 15 s zwischen 8 und 9 MB); Prototyp-Gate bei 10 MB höchstens 3,7 s, keine Überschreitung. Ob der Harness einen Befehl dieser Grösse übergibt, ist unbekannt. Vorbestehend.
- Quelle: Einordnung Software Architect 2026-10-21 (Posten 7, belegte Lücke); Messwerte SecDevOps Engineer 2026-10-21; statische Prüfung ST-C2-05 (Zeitgrenze befristet bis Posten 7 als Grenze ausgenommen).
- CWE: CWE-636 (Failing Open), Ursache CWE-400 (Uncontrolled Resource Consumption). Bauteil: `.claude/hooks/block-main-write.sh` (gemessen), `.claude/hooks/block-prototype-import.sh` (gemessen bis 10 MB, keine Überschreitung).
- CVSS 3.1: CVSS:3.1/AV:L/AC:H/PR:L/UI:N/S:U/C:N/I:H/A:N, Basiswert 4.7 (Mittel). Wie SR-001 (Bewertungsgrundlage), aber AC:H: Die Überschreitung braucht eine Eingabe von mehr als 8 MB, und ob Modell und Harness
  einen Befehl dieser Grösse erzeugen und übergeben, ist unbekannt (ausserhalb der Kontrolle des Angreifers). Rechnung: Exploitability 1.048 + Impact 3.595 = 4.644, aufgerundet 4.7. Sensitivität: AC:L ergäbe 5.5.
- Status: offen. Fälligkeit: mit der nächsten Änderung am jeweiligen Gate, spätestens vor der Freigabe des Grundgerüsts (ADR 0002, 6.13 c; Einordnung nach der Delegation vom 2026-10-21).
- Verweis: Posten 7 unter R3-Q-010 (Sammelposten, Nachführung im Backlog durch den Product Owner); vorgesehen: je Gate eine eigene Zeitgrenze im Skript, kürzer als in settings.json, Überschreitung endet mit Rückgabewert 2 (ADR 0002, 6.12.12, 6.13 b);
  bis dahin ohne Fall und Fallklasse (befristet ausgenommen, ADR 0002, 6.13 c, Nachtrag vom 2026-10-21). Schliesskriterium: je Gate ein Fall mit Soll 2 über der eigenen Grenze, Mutation (Grenze entfernt)
  erkannt, beide Modi Rückgabewert 0, Verifikation auf einem anderen Modell. Akzeptanzbegründung: keine.

## SR-004 Prototyp-Gate: Rückgabewerte von sed und tr nicht geprüft (Posten 6)
- Befund: Die sed- und tr-Schritte des Prototyp-Gates (Bash-Weg: cmd_flach, bereinigt; Dateiwerkzeuge: payload_norm) prüfen ihren Rückgabewert nicht; ohne sed oder tr im PATH läuft ein sonst gesperrter Befehl durch
  (Fälle L23 Bash ohne sed, L24 Write ohne tr: Rückgabewert 0 statt 2, gemessen). Am main-Gate mit Posten 4 geschlossen (gebaut, noch nicht committet); vorbestehend, weder Posten 2 noch Posten 5.
- Quelle: Messung SecDevOps Engineer 2026-10-21, Einordnung Software Architect (Posten 6). CWE: CWE-252 (Unchecked Return Value), Folge CWE-636. Bauteil: `.claude/hooks/block-prototype-import.sh`.
- CVSS 3.1: Bewertung mit dem Bau (C3). Status: offen. Fälligkeit: mit der nächsten Änderung am Prototyp-Gate (Einheit C3, zusammen mit Posten 2), spätestens vor der Freigabe des Grundgerüsts.
  Verweis: Posten 6 unter R3-Q-010 (Sammelposten, Nachführung im Backlog durch den Product Owner); vorgesehen: Rückgabewert jedes Schritts prüfen wie am main-Gate. Akzeptanzbegründung: keine.
- Schliesskriterium: L23 und L24 mit Soll 2, je Weg eine Mutation erkannt, Prüfmittel in beiden Modi Rückgabewert 0, Verifikation auf einem anderen Modell.
