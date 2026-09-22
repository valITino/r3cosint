# Übergabe 2026-09-21 — R3-Q-001: Abnahme aktenkundig gemacht; E4 als R3-Q-010 auf die Definition of Ready gebracht, nicht gebaut

Arbeitseinheit auf Weisung des Auftraggebers vom 2026-09-21 (zwei Schritte in
einer Einheit: den Abnahmeentscheid zu R3-Q-001 aktenkundig machen; E4 auf die
Definition of Ready bringen und mit Schätzung vorlegen, ohne zu bauen). Erste
Einheit nach dem Merge der Pull Requests #15 (`valITino/r3cosint`, Merge-Commit
`9870b0d115b8ef330a7c19777af5741093e4f0e9`) und #9 (`valITino/r3coscrum`,
Merge-Commit `9c28499252ab3f42a96dc43bf096c3a6353ce0cb`); als Aufgabe #1 geführt
(O-23, Entscheid E-H). Arbeitszweig `claude/awesome-knuth-blvzpb` in beiden
Repositories.

## Ergebnis in einem Absatz

Die Abnahme des Prüfmittels aus R3-Q-001 ist am **2026-09-08** über den ersten
Formweg aus ADR 0002, Abschnitt 10 erteilt worden — durch den Merge des Pull
Requests #15, dessen Text den Merge ausdrücklich als Erteilung der Abnahme
benennt; ohne Kommentar, ohne Review, ohne Auflage. Das ist jetzt in ADR 0002
(Abschnitt 10, Kopfzeile, Abschnitt 9), in ADR 0001, in `CLAUDE.md`, im
Backlog unter R3-Q-001 und im Methodik-Repository (`methodik/entscheide.md`;
der Vermerk in `UEBERGABE.md` folgt unmittelbar nach dem Commit des
Produkt-Repositories, weil er dessen Prüfsumme trägt) eingetragen — mit dem,
was die Abnahme **nicht** umfasst
(O-25, der Belegprüfer D20 mit O-15, R3-Q-005, die Freigabe des Grundgerüsts)
und ohne Beschönigung: Teil 1 des Abnahmekriteriums war erfüllt, **Teil 2
nicht**; getragen hat der in ADR 0002, 6.12.28 g vorab festgelegte Weg. E4 hat
jetzt einen am Bestand gemessenen Umfang: Backlog-Eintrag **R3-Q-010** (beide
PreToolUse-Gates, sieben Abnahmekriterien, Prüfaufwand 5 h, ready), ADR 0002,
6.13 (Einordnung, Prüfmittel, Rollen, Schnitt), neuer offener Punkt O-28. Die
Umsetzung passt erkennbar nicht in eine Session und ist in E4.1 bis E4.3
zerlegt; E3 braucht eine eigene Festlegungseinheit. Gebaut ist nichts.

## Schritt 1 — Feststellung am Repository (Erhebung des Koordinators, `git` und GitHub-API)

| | `valITino/r3cosint`, Pull Request #15 | `valITino/r3coscrum`, Pull Request #9 |
|---|---|---|
| Zustand | gemergt, geschlossen | gemergt, geschlossen |
| Gemergt durch | Konto des Repository-Eigentümers | Konto des Repository-Eigentümers |
| Merge-Commit | `9870b0d115b8ef330a7c19777af5741093e4f0e9` | `9c28499252ab3f42a96dc43bf096c3a6353ce0cb` |
| Zeitpunkt des Merge-Commits | 2026-09-08, 09:51:49 UTC | 2026-09-08, 09:51:04 UTC |
| Kommentare, Reviews, Auflagen | 0, 0, keine | 0, 0, keine |

Der Text des Pull Requests #15 sagt: "Der Merge dieses Pull Requests gilt als
Erteilung der Abnahme des Prüfmittels aus R3-Q-001 in dem Umfang, den die
Abnahmevorlage in Abschnitt 10 beschreibt — Gate, Lagenliste, Selbsttest,
Mutationsdatei und die Festlegung in 6.12 samt Nachträgen." Damit ist der erste
Formweg erfüllt. Die Abbruchbedingung des Auftrags (nicht gemergt oder mit
Auflagen) trifft nicht zu.

Danach auf `main`: Merge des automatisch eröffneten Eingangs-Pull-Requests #16
durch das Konto des Repository-Eigentümers
(`c06ed44337b297a70fcf33ae2410b0fd69503445`, 09:52:37 UTC) und zwei
Nachweis-Commits der Automatik im Methodik-Repository
(`05d0cfc97d665098c743f40ee037c5fd8e2f06be`,
`b7345b31df6f7e598bc29a1767ab124ad7df5d10`). Bis zum 2026-09-20 liegt auf
keinem Zweig der beiden Repositories ein weiterer Commit (`git log --all`).

## Ausgangslage dieser Einheit — zwei Umgebungsbefunde und ein Befund an `main`

1. Der Klon war flach (113 Commits). `git fetch --unshallow origin` ausgeführt
   (123 Commits, nicht flach). Wie am 2026-09-07.
2. `gitleaks` fehlte. Release-Archiv gitleaks_8.21.2_linux_x64.tar.gz
   beschafft, SHA-256
   `5bc41815076e6ed6ef8fbecc9d9b75bcae31f39029ceb55da08086315316e3ba` gegen
   die veröffentlichte Prüfsummendatei geprüft (`sha256sum -c`: OK), nach
   `/usr/local/bin/gitleaks` installiert (Version 8.21.2). Wie am 2026-09-07
   (Entscheid E-E, Option b).
3. **`main` war seit dem Merge von #15 an D20 rot.** `make dod` auf dem
   unveränderten Stand `c06ed44337b297a70fcf33ae2410b0fd69503445` endete mit
   D20 `A_FAIL` (ein Befund der Art `abschnitt`: die Übergabe vom 2026-09-07
   nannte in einem Aufzählungspunkt "Abschnitt 6.12.28 a bis j" und den ADR
   nur über seinen Dateipfad). Ursache ist die Klasse K-01 des
   Zustandsberichts: D20 liest nur versionierte Dateien, und die damals neue
   Übergabedatei war vor `git add` geprüft worden. Behoben durch den
   Koordinator: Einfügen von "ADR 0002, " an dieser einen Stelle in
   `docs/uebergaben/2026-09-07_r3-q-001-o-27-deckung-am-gegenstand.md`
   (Formberichtigung einer historischen Übergabe, Inhalt unverändert; dasselbe
   Vorgehen wie am 2026-09-02). Danach `make dod`: Form 2 mit den drei
   terminierten Lagen C (D7, D10, D12), D20 `A_OK`, D11 `A_OK`, D19
   `OHNE_BEFUND`, Rückgabewert 2 — der erwartete Zustand. In dieser Einheit ist
   diese Übergabedatei deshalb vor dem letzten `make dod` mit `git add`
   versioniert worden.

## Schritt 1 — Eintragungen

- `docs/adr/0002-architekturentscheid-ziel-stack.md`: Abschnitt 10 —
  Entscheidtabelle der Abnahmevorlage von "offen" auf erteilt (das Wort "offen"
  bleibt als Stand davor stehen), neuer Unterabschnitt "Abnahme des DoD-Gates
  aus R3-Q-001 — erteilt am 2026-09-08, eingetragen am 2026-09-21" am Ende des
  Abschnitts mit Umfang, Nicht-Umfang, Massstab und Ergebnis ("Teil 2 ist NICHT
  erfüllt") und Protokollvermerk zur Form; Kopfzeile "Fortschreibung"; Abschnitt
  9 (acht Zeilen: was wo von wem nachzuführen ist). Protocol Master.
- `docs/adr/0001-rollenmodell.md`: Kopfzeile, Abschnitt 4, Konsequenz 7.4,
  Abschnitt 8 — je Nachtrag mit der Freigabe vom 2026-09-07
  (`135e3614197a8150ad3d96fbf32eb0e893c9cbbc`) und der Abnahme vom 2026-09-08,
  mit dem Vorbehalt zu Teil 2 und dem Nicht-Umfang; R3-Q-005 bleibt offen.
  Protocol Master.
- `docs/05_Product_Backlog.md`: R3-Q-001 um den Stand-Vermerk 2026-09-21
  ergänzt; Stand-Zeile (sechste Nachführung, Teil 1). Product Owner.
- `CLAUDE.md`: Statustabelle (Schritt 5), Gate-Zeile, "Wo steht was".
  Koordinator.
- `scripts/nachweise-erzeugen.sh`: Beschreibung des DoD-Gates (Abnahme
  erteilt), diese Übergabe aufgenommen (Datenzeilen, keine Änderung an der
  Logik); `docs/NACHWEISE.md` nach dem Commit neu erzeugt. Koordinator.
- Methodik-Repository: V17 in `methodik/entscheide.md` um die erteilte Abnahme
  ergänzt und der seit dem 2026-09-07 als erledigt geführte Punkt O-27 um den
  Entscheid ergänzt (nicht neu geschlossen). Der Vermerk in `UEBERGABE.md`
  folgt **nach** dem Commit dieser Einheit im Produkt-Repository, weil er dessen
  40-stellige Commit-Prüfsumme trägt; er ist Teil derselben Einheit und wird
  mit dem Commit des Methodik-Repositories eingelöst. Koordinator.

**Was die Abnahme nicht umfasst**, an jeder dieser Stellen gleich: O-25 (bleibt
offen), die Abnahme des Belegprüfers D20 (O-15, fällig vor der Freigabe des
Grundgerüsts), R3-Q-005 (die Lücke aus E-K bleibt: das Gate misst das Recht
einer Rolle, nicht ihre Fähigkeit), die Freigabe des Grundgerüsts. Die drei
Restlücken aus Runde 12 und die Grenzen der Prüfrollen sind mit der Abnahme
benannt, nicht geschlossen.

**Bewusst nicht angefasst:** die Kommentarzeilen "foermliche Freigabe
ausstehend" in `.claude/hooks/dod-gate.sh` (Zeile 6) und
`.claude/hooks/dod-gate-terminierte-lagen.txt` (Zeile 3) — eine Änderung am
abgenommenen Prüfmittel, auch nur im Kommentar, ist eine Fortschreibung durch
den Software Architect, nicht Sache dieser Einheit (ADR 0002, Abschnitt 9);
`docs/06_Definition_of_Ready_und_Done.md` (dort drei Stellen "Freigabe steht
aus", seit der achtzehnten Fortschreibung als nachzuführen geführt);
CHANGELOG.md (besteht nicht; Befund des Protocol Masters vom 2026-09-08, nicht
entschieden).

## Schritt 2 — Nachmessung der Gate-Befunde des Zustandsberichts

Erhebung des Koordinators gegen einen Wegwerf-Klon auf `main`
(`c06ed44337b297a70fcf33ae2410b0fd69503445`), lesend, mit einem Probeskript,
das die Gates mit JSON-Eingabe aufruft; Prüfsummen (SHA-256, erste 16 Stellen):
`.claude/hooks/block-main-write.sh` `d1a3d2ad3ba7b0aa`,
`.claude/hooks/block-prototype-import.sh` `0e78705ee2cc0cf7`. Der Static
Software Tester hat das Skript unverändert erneut ausgeführt und jeden Befund
statisch am Quelltext belegt (auf einem anderen Modell als die Erhebung);
keine Abweichung in der Sache. Die 37 Proben mit Kennung sind die versionierte
Ausgangsmenge für das Prüfmittel aus E4.1 (ADR 0002, 6.13 d). Der Fremdbeleg
zählte 44 Zeilen; die Differenz ist am Probeskript ausgezählt (erneuter Lauf am
2026-09-21, 37 Zeilen mit Kennung, 7 Zeilen "ABWEICHUNG"): Die sieben weiteren
Zeilen sind die Abweichungsmeldungen des Skripts zu G04, B02, B03, B06, B07,
B08 und B09 — keine Proben, sondern die Meldungen zu genau den Proben, deren
gemessener Wert von dem im Probeskript eingetragenen Soll abwich (im Skript
stand für G04 irrtümlich 0 und für S01, S02, S04 und S05 der heutige Wert; die
Tabelle unten führt das entschiedene Soll).

| Kennung | Gate, Werkzeug | Eingabe | Rückgabewert | Soll | Bedeutung |
|---|---|---|---|---|---|
| A01 | main, Bash | `git push origin main` | 2 | 2 | blockiert |
| A02 | main, Bash | `git push origin 'main'` | 2 | 2 | ST-01 behoben |
| A03 | main, Bash | `git push origin "main"` | 2 | 2 | ST-01 behoben |
| A04 | main, Bash | `git push origin main;` | 2 | 2 | ST-01 behoben |
| A05 | main, Bash | `(git push origin main)` | 2 | 2 | ST-01 behoben |
| A06 | main, Bash | `git push origin main && echo ok` | 2 | 2 | ST-01 behoben |
| A07 | main, Bash | `git worktree add "/tmp/wt" "main"` | 2 | 2 | ST-02 behoben |
| A08 | main, Bash | `git worktree add /tmp/wt main;` | 2 | 2 | ST-02 behoben |
| A09 | main, Bash | `git worktree add /tmp/wt 'main'` | 2 | 2 | ST-02 behoben |
| A10 | main, Bash | `git commit -m x` | 2 | 2 | blockiert |
| A11 | main, Bash | `echo hallo > datei.txt` | 2 | 2 | blockiert |
| G01 | main, Bash | `git status` | 0 | 0 | Gegenprobe |
| G02 | main, Bash | `git switch -c claude/neu` | 0 | 0 | Gegenprobe |
| G03 | main, Bash | `git worktree add -b claude/neu /tmp/wt main` | 0 | 0 | Gegenprobe |
| G04 | main, Bash | `git push -u origin claude/arbeitszweig` bei HEAD auf main | 2 | 2 | gewollte Wirkung laut Kopfkommentar; das Probeskript führte irrtümlich Soll 0 |
| G05 | main, Bash | `grep -rn main docs/` | 0 | 0 | Gegenprobe |
| G06 | main, Bash | `echo hallo > /dev/null` | 0 | 0 | Gegenprobe |
| S01 | main | leere Eingabe | 0 | 2 | ST-13 offen; Soll nach dem Entscheid in ADR 0002, 6.13 b |
| S02 | main | Eingabe "kein json" | 0 | 2 | ST-13 offen; Soll nach dem Entscheid in ADR 0002, 6.13 b |
| S03 | main, Bash | `git commit -m x` ohne git im Suchpfad | 2 | 2 | ST-03 behoben |
| B01 | Prototyp, Write | frontend/src/a.ts mit `import h from "../prototype/helper";` | 2 | 2 | blockiert |
| B02 | Prototyp, Write | frontend/src/a.ts mit `import h from "../prototype";` | 0 | 2 | ST-04 offen |
| B03 | Prototyp, Write | frontend/src/a.ts mit `import h from '../../prototype'` | 0 | 2 | ST-04 offen |
| B04 | Prototyp, Write | backend/src/a.py mit `from prototype import demo` | 2 | 2 | blockiert |
| B05 | Prototyp, Write | prototype/x.js mit `import a from "../backend/api";` | 2 | 2 | blockiert |
| B06 | Prototyp, Write | prototype/x.js mit `import a from "./../backend/api";` | 0 | 2 | ST-05 offen |
| B07 | Prototyp, Write | prototype/demo.html mit `<script src="../backend/app.js"></script>` | 0 | 2 | P-01 (Dimension Prototyp) offen |
| B08 | Prototyp, Write | prototype/demo.html mit `<link href="../frontend/style.css">` | 0 | 2 | P-01 (Dimension Prototyp) offen |
| B09 | Prototyp, Bash | `python3 -c` mit Schreiben eines Prototyp-Imports | 0 | 2 | ST-09 offen |
| B10 | Prototyp, Bash | Heredoc `cat > frontend/src/a.ts` mit Prototyp-Import | 2 | 2 | blockiert |
| P01 | Prototyp, Write | frontend/src/a.ts mit `import x from "./local";` | 0 | 0 | Gegenprobe |
| P02 | Prototyp, Write | frontend/src/demo.html mit `<script src="../prototype/demo.js"></script>` | 2 | 2 | Richtung 1 mit src= blockiert |
| P03 | Prototyp, Write | docs/notiz.md mit Prototyp-Import in Prosa | 0 | 0 | Doku-Ausnahme |
| P04 | Prototyp, Write | prototype/x.js mit `const a = 1;` | 0 | 0 | Gegenprobe |
| P05 | Prototyp, Edit | entfernt einen verbotenen Import (old_string) | 0 | 0 | Falsch-Positiv-Kontrolle |
| S04 | Prototyp | leere Eingabe | 0 | 2 | ST-13 offen; Soll nach dem Entscheid in ADR 0002, 6.13 b |
| S05 | Prototyp | Eingabe "kein json" | 0 | 2 | ST-13 offen; Soll nach dem Entscheid in ADR 0002, 6.13 b |

Stand je Befund des Zustandsberichts: **ST-01, ST-02, ST-03 behoben** seit
Commit `0b3510a3fd8b219c82c093b34be3aff50c68f7e0` vom 2026-09-03 — eine
Verifikation dieser Behebung durch eine Prüfrolle ist in keinem Dokument
belegt (Fremdbeleg: kein Prüfbericht, kein Prüffall, keine benannte Rolle; die
im Commit genannten "16 Fälle" sind nicht überliefert). **ST-04, ST-05, ST-09
und P-01 der Dimension Prototyp offen**; **P-10 der Dimension Prototyp**
benennt eine unbenannte Grenze; **ST-13** an beiden Gates offen (im Bericht
als widerlegt geführt; der Widerlegungsgrund ist in der Tabellenzelle
abgeschnitten und nicht überliefert). ST-10 (Eingangs-Hook) und ST-11
(PowerShell) sind aus `.claude/settings.json` gelesen, nicht messbar. Ein
versioniertes Prüfmittel für die beiden Gates besteht nicht.

## Schritt 2 — E4 auf der Definition of Ready

- **Backlog `R3-Q-010`** (Requirements Engineer formuliert, Product Owner
  eingeordnet und gegen R1 bis R10 und B1 bis B6 geprüft: **ready**): "main-Gate
  und Prototyp-Gate: belegte Lücken geschlossen, Wirkung mit versioniertem
  Prüfmittel belegt". Qualitätsanforderung, Basisfaktor, **Prüfaufwand 5 h**,
  Quelle 3.2 c, 5.6, 3.4, Etappe 0, Stakeholder S-01 und S-02 (R1 zur Hälfte:
  benannt, die Abstimmung fällt mit der Freigabe an). Sieben Abnahmekriterien
  in der R6-Notation: `R3-Q-010_prototyp_gate_pfadformen` (ST-04, ST-05),
  `R3-Q-010_prototyp_gate_richtungsgleichheit` (P-01),
  `R3-Q-010_prototyp_gate_schreibwirkung` (ST-09),
  `R3-Q-010_gates_unlesbare_eingabe` (ST-13), `R3-Q-010_pruefmittel_je_gate`
  (versioniertes Prüfmittel mit Mutationsprobe und Regressionsschutz),
  `R3-Q-010_main_gate_fremdbelegt` (die fehlende Verifikation von ST-01 bis
  ST-03), `R3-Q-010_benannte_grenzen` (P-10 und die Deckung der
  Kopfkommentare). Etappe 0 jetzt 11 Einträge mit 37 h; erste Fassung 83
  Einträge mit 357 h; gesamt 87 Einträge mit 375 h. Neuer offener Punkt 18 des
  Backlogs (Freigabe des Umfangs und Entscheid über den Schnitt, Auftraggeber).
- **Bewusst nicht aufgenommen**, je mit Grund im Eintrag: ST-10 (Kanal, kein
  Gate; E2); ST-11 (PowerShell — hier nicht messbar, ein Matcher-Eintrag ohne
  Messung wäre eine Zusicherung ohne Deckung; als **O-28** in ADR 0002,
  Abschnitt 8 mit Bedingung, Entscheider und Frist geführt); ST-06, ST-12,
  ST-14 (Belegprüfer, O-15); ST-07 (Erzeuger); ST-08, ST-15 (Arbeitsabläufe);
  K-01 (D20, O-15); die Prüfung gemeinsamer Abhängigkeiten aus P-10 (neue
  Fähigkeit; aufgenommen ist allein das Benennen der Grenze); jede Härtung ohne
  belegte Lücke; die im Kopfkommentar des main-Gates benannten Grenzen werden
  festgeschrieben und gemessen, nicht geschlossen.
- **ST-13 aufgenommen** trotz Führung unter "widerlegt": der operative Befund
  ist im Bericht selbst bestätigt und zweimal nachgemessen, der
  Widerlegungsgrund abgeschnitten; die Richtung (Rückgabewert 2) ist am Bestand
  abgelesen (jq-Wache beider Gates, git-Wache seit 2026-09-03, ADR 0002,
  6.12.28 e) — vom Requirements Engineer als Annahme nach R4 formuliert und vom
  Software Architect in ADR 0002, 6.13 b **bestätigt**.
- **ADR 0002, 6.13** (Software Architect): Gegenstand und Abgrenzung (E4 kein
  Kettenschritt, D10 bleibt Lage C, R3-Q-005 und 6.12 unberührt), Tabelle der
  belegten Lücken mit Stand, Nicht-Umfang, **Prüfmittel** — ein einziges
  versioniertes Skript unter scripts/, Name in 6.13 d festgelegt (Fallliste je
  Gate mit Kennung, Werkzeug, Eingabe, Soll und Ist; Wegwerf-Klon auf `main`
  für das main-Gate, Arbeitsbaum für das Prototyp-Gate; keine Änderung am
  Arbeitsbaum; Mutationsprobe als Gegenprobe; **bewusst ohne**
  Zusicherungstabelle, Deckungen und Mutationsdatei nach dem Muster von
  ADR 0002, 6.12.19 bis 6.12.28, mit benannter Grenze und der einen
  mechanischen Bindung: jede vom Kopfkommentar behauptete Fallklasse braucht
  einen Fall), Ausgangsmenge (die 37 Proben oben, die zehn Zusatzfälle des
  Static Software Testers, die Proben vom 2026-08-25 soweit rekonstruierbar),
  **Rollen** (Umsetzung SecDevOps Engineer nach ADR 0001, Abschnitt 8;
  Verifikation Static und Dynamic Software Tester auf einem anderen Modell),
  Abnahmekriterium mit Regressionsschutz, Schnitt und Reihenfolge. Das
  geplante Skript ist in `scripts/belege-ausnahmen.txt` als absichtlich noch
  nicht vorhandenes Artefakt eingetragen (zwei Zeilen, ADR und Backlog; mit
  E4.1 wieder zu entfernen).
- **Glossar** `docs/03_Glossar.md`: "Gate" und "Hook" aufgenommen,
  Homonym-Warnung bei "Freigabe-Gate" erweitert (R3; Requirements Engineer).

**Schätzung und Schnitt (3.3).** Prüfaufwand 5 h (6.8). Die Umsetzung passt
erkennbar **nicht** in eine Session — sieben Sachverhalte an zwei Skripten, ein
Prüfmittel, das es noch nicht gibt, drei Verifikationsschleifen auf einem
anderen Modell, und die Erfahrung aus R3-Q-001. Zerlegung, vom Requirements
Engineer vorgeschlagen und vom Software Architect bestätigt:

| Einheit | Inhalt | schliesst ab |
|---|---|---|
| E4.1 | versioniertes Prüfmittel am heutigen Stand; **keine Zeile an den Gates**; offene Lücken als Fälle "belegte Lücke" mit dem heute gemessenen Rückgabewert als Soll | `R3-Q-010_pruefmittel_je_gate`, `R3-Q-010_main_gate_fremdbelegt` |
| E4.2 | Prototyp-Gate: ST-04, ST-05, P-01 — je Befund Soll auf 2, Gate ändern, Vermerk entfernen | `R3-Q-010_prototyp_gate_pfadformen`, `R3-Q-010_prototyp_gate_richtungsgleichheit` |
| E4.3 | ST-09, ST-13 (beide Gates), benannte Grenzen und Kopfkommentare | `R3-Q-010_prototyp_gate_schreibwirkung`, `R3-Q-010_gates_unlesbare_eingabe`, `R3-Q-010_benannte_grenzen` |

Einschätzung des Koordinators, als solche gekennzeichnet: E4.1 allein ist eine
Session; E4.2 und E4.3 lassen sich zusammenlegen, wenn E4.1 ein Prüfmittel
hinterlässt, das die Fälle trägt. Drei Sessions sind die sichere Planung, zwei
die knappe.

**E3.** Eigene Festlegungseinheit, nicht im selben Zug — vier Gründe: anderer
Gegenstand (eine Regel und eine Skill, keine Hooks; B2); für E4 lag ein
Befundbestand vor, für E3 keiner ("Regel fehlt; Umfang nirgends festgelegt"),
der Umfang wäre zu erheben; E3 hängt an Entscheiden, die nicht beim
Requirements Engineer liegen (wer `.claude/skills/` schreibt — ADR 0001,
Abschnitt 8, fällig vor der dritten Skill; der terminierte Kontrollversuch zum
Vorladen über das skills-Feld, Befund SK-02); die Reihenfolge verliert nichts,
weil E3 ohnehin nach E4 steht. Empfohlene Reihenfolge: E4.1, E4.2, E4.3, dann
die Festlegung von E3, dann E3, dann das Grundgerüst.

## Verifikation

Die Rolle, die schreibt, hat nicht geprüft (3.4). Prüfrolle war der Static
Software Tester in zwei Besetzungen je Runde: A auf dem Modell der Rolle, B
auf einem anderen Modell; die Umsetzungsrollen (Requirements Engineer,
Software Architect, Product Owner, Protocol Master) liefen auf zwei
verschiedenen Modellen, sodass für jede Datei mindestens eine Prüfung auf einem
anderen Modell als ihre Umsetzung stattfand.

- **Runde 1:** A nicht bestanden (drei blockierende Befunde: CLAUDE.md und
  `UEBERGABE.md` noch nicht nachgeführt — Koordinator, zu diesem Zeitpunkt
  planmässig offen; eine Zeile in ADR 0002, Abschnitt 9 sagte eine Nachführung
  zu, die nicht einlösbar war — Software Architect, behoben), zehn nachrangige;
  B bestanden, ein nachrangiger Formhinweis.
- **Runde 2:** A drei blockierende (ADR 0001 führte nur die Abnahme, nicht die
  Freigabe vom 2026-09-07; der ausführlichste Abnahmevermerk in ADR 0001 nannte
  den Vorbehalt zu Teil 2 nicht — Protocol Master, behoben; CLAUDE.md und
  `UEBERGABE.md` — Koordinator), zwölf nachrangige; B ein blockierender (die
  vom Koordinator vorgegebene Aussage "zwischen dem 2026-09-08 und dem
  2026-09-21 kein Commit" war ungenau: am 2026-09-08 folgten dem Merge noch
  drei Commits — Protocol Master, berichtigt), ein nachrangiger.
- **Runde 3:** A zwei blockierende (beide CLAUDE.md, Koordinator), acht
  nachrangige; B ein blockierender (die Kopfzeile von ADR 0002 nannte
  denselben Text als "Teil 1 von 2" und "Teil 2 von 2" — Software Architect,
  behoben), zwei nachrangige.
- **Nachbesserung:** alle nachrangigen Befunde der drei Runden, soweit sie
  Präzision oder Form betrafen, in einem eigenen Durchgang je Rolle behoben
  (Nachbedingungen um die Zustandsaussage, Zähleinheit von
  `R3-Q-010_benannte_grenzen`, Regressionsschutz im Abnahmekriterium und in der
  Einordnungszeile, Dimension bei P-01 und P-10, zehnte Zeile der Lückentabelle,
  Abnahme-Unterabschnitt hinter Punkt 7 verschoben, Kopfzeile ohne
  Wiederholung, "ADR 0002, " vor jeder neu geschriebenen Abschnittsangabe).
  Nicht übernommen: der Vorschlag, den Grundsatz "Historie bleibt stehen" mit
  ADR 0002, 6.1 statt 6.1.2 zu zitieren — der Bestand zitiert durchgehend
  6.1.2, und eine abweichende Zitierweise in neuen Stellen wäre die grössere
  Uneinheitlichkeit.
- **Abschlussprüfung** nach den Nachführungen des Koordinators: siehe den
  Abschnitt "Abschlussprüfung" am Ende dieser Datei.

## Entscheidungen dieser Einheit

- Abnahme aktenkundig über Formweg 1, ohne Beschönigung (Auftrag).
- E4 umfasst beide PreToolUse-Gates (Zustandsbericht, Abschnitt 6.1);
  massgeblich sind allein die belegten Lücken.
- ST-13 aufgenommen (abweichende Beurteilung gegenüber der Widerlegungstabelle
  des Berichts, begründet); ST-11 als O-28 vertagt, nicht abgelehnt.
- Prüfmittel bewusst ohne Zusicherungsapparatur (Mass an den Gegenstand
  angepasst, Grenze benannt).
- Umsetzung von E4 beim SecDevOps Engineer (ADR 0001 vor Zustandsbericht).
- Gebaut wird nichts; Umfang, Schnitt und Schätzung sind Vorlage.
- Formregel für in dieser Einheit neu geschriebenen ADR-Text: auch
  Selbstverweise innerhalb von ADR 0002 tragen "ADR 0002, " — im Fliesstext
  und in den Tabellen der Abschnitte 8, 9 und 10. Ausgenommen ist die
  chronologische Kopfzeile "Fortschreibung": Sie führt seit dem 2026-08-21
  blosse Abschnittsnummern, und eine gemischte Schreibweise in einer einzigen
  Zelle wäre die grössere Uneinheitlichkeit. Bestandstext bleibt unangetastet.
- Die Rollen Requirements Engineer, Software Architect und Product Owner haben
  ihre Turn-Grenzen in einer ersten Orchestrierung überschritten, weil sie den
  ganzen ADR lasen; die zweite Orchestrierung hat jeder Rolle die Zeilenbereiche
  und Anker vorgegeben. Das ist eine Beobachtung zur Steuerung, kein Befund am
  Rollenmodell.

## Was offen ist

**Zur Entscheidung durch den Auftraggeber**

- Freigabe des Umfangs von R3-Q-010 und Entscheid über den Schnitt E4.1 bis
  E4.3 (Backlog, offener Punkt 18; ADR 0002, 6.13 g).
- O-28 (ST-11, PowerShell-Matcher): bedingt offen, Entscheid des Software
  Architects erst mit ausgeführter Probe in einer Umgebung mit dem Werkzeug.
- O-25 und O-15 bleiben offen; CHANGELOG.md besteht nicht; die Bestätigung der
  Notation der Abnahmekriterien in `docs/06_Definition_of_Ready_und_Done.md`
  steht aus.

**Nachzuführen in späteren Einheiten** (ADR 0002, Abschnitt 9): die
Kommentarzeilen "foermliche Freigabe ausstehend" in Gate und Lagenliste
(Software Architect); `docs/06_Definition_of_Ready_und_Done.md` (Requirements
Engineer mit Product Owner); nach E4.1 die Gate-Tabelle in `CLAUDE.md`, die
Hook-Regel, die Kopfkommentare der Gates, der Nachweiserzeuger und die beiden
Ausnahmezeilen.

**Bekannte Grenzen dieser Einheit**

- Die Widerlegung von ST-13 im Zustandsbericht ist nicht lesbar (Zelle
  abgeschnitten); der Bericht bleibt unverändert (historischer Stand).
- Die 29 und 18 Proben vom 2026-08-25 sind nicht gelesen worden; ihr Inhalt
  wird nirgends behauptet.
- R1 für R3-Q-010 nur zur Hälfte belegt (Stakeholder benannt, Abstimmung fällt
  mit der Freigabe an); dieselbe Lücke tragen R3-Q-001 bis R3-Q-009 (offene
  Punkte 12 und 15 des Backlogs).
- K-01 ist in dieser Einheit erneut wirksam geworden und gehört zur Abnahme des
  Belegprüfers (O-15).
- Das Probeskript des Koordinators ist nicht versioniert; seine 37 Proben
  stehen in der Tabelle oben und sind damit versioniert.

## Protokoll der ausgeführten Befehle (Koordinator)

Diese Rolle hat weder formuliert noch eingeordnet noch geprüft. Ausgeführt hat
sie:

- `git log`, `git show --no-patch` auf beiden Merge-Commits und die
  GitHub-API-Abfrage der beiden Pull Requests (Zustand, Merge-Zeitpunkt,
  Kommentare, Reviews) — Grundlage von Schritt 1;
- `git fetch --unshallow origin`; Beschaffung und Prüfsummenprüfung von
  gitleaks 8.21.2 (`sha256sum -c`: OK), Installation nach `/usr/local/bin`;
- `make dod` auf dem unveränderten Stand von `main` (D20 `A_FAIL`), die
  Formberichtigung an der Übergabe vom 2026-09-07, `make dod` danach (Form 2,
  drei terminierte Lagen C, D20 `A_OK`);
- das Probeskript gegen einen Wegwerf-Klon auf `main` (Tabelle oben; der
  Arbeitsbaum blieb unverändert, 0 geänderte Dateien);
- `git log --all --since=2026-09-09` in beiden Repositories (keine Commits);
- die Nachführung von `CLAUDE.md` und `scripts/nachweise-erzeugen.sh`
  (Datenzeilen) sowie von `methodik/entscheide.md` im Methodik-Repository; das
  Schreiben dieser Übergabe;
- `git add` aller geänderten und neuen Dateien vor `make dod` (Lehre aus K-01)
  und `make dod` danach (Form 2, drei terminierte Lagen C, D20 `A_OK`,
  Rückgabewert 2);
- die mechanische Formprüfung über alle vorgemerkten Zeilen (kein Eszett,
  keine typografischen Anführungszeichen, keine Modellnamen, kein
  Zweigverweis, Spaltenzahl aller Tabellen, Existenz oder Ausnahme jedes Pfads
  in Rückwärtsakzenten): ohne Befund.

**Nach der Abschlussprüfung noch auszuführen**, in dieser Reihenfolge und in
dieser Einheit: `make dod` vor dem Commit; Commit und Push auf
`claude/awesome-knuth-blvzpb` im Produkt-Repository; Neuerzeugung von
`docs/NACHWEISE.md` mit erneutem `make dod` und zweitem Commit; Vermerk in
`UEBERGABE.md` des Methodik-Repositories mit der Commit-Prüfsumme des
Produkt-Repositories, Commit und Push dort; Abschluss der Aufgabe #1
(`TaskCompleted`).

## Abschlussprüfung

Nach den Nachführungen des Koordinators (CLAUDE.md, Nachweiserzeuger, diese
Übergabe) hat der Static Software Tester den gesamten vorgemerkten Stand ein
zweites Mal geprüft, wieder in zwei Besetzungen. Der erste Anlauf scheiterte an
der Nutzungsgrenze der Sitzung (beide Prüfer ohne Ergebnis); nach deren
Rücksetzung durch den Auftraggeber lief die Prüfung vollständig.

- **B (anderes Modell): bestanden**, keine Befunde; 19 Negativbefunde,
  darunter: `make dod` frisch ausgeführt (Form 2, D20 `A_OK`, `Befunde: 0`),
  Ausschlussliste der nicht zu ändernden Dateien am Diff geprüft, alle zehn
  40-stelligen Prüfsummen einzeln aufgelöst, Summen des Backlogs nachgerechnet,
  alle Tabellen mechanisch auf Spaltenzahl geprüft, Kopfzeile von ADR 0002 in
  sich stimmig.
- **A (Modell der Rolle): nicht bestanden**, fünf blockierende und fünf
  nachrangige Befunde, alle behoben oder entschieden, bevor committet wurde:
  (1) diese Übergabe führte den Vermerk in `UEBERGABE.md` als erledigt, obwohl
  er erst nach dem Commit des Produkt-Repositories geschrieben werden kann —
  Wortlaut berichtigt, Reihenfolge benannt; der Prüfer weist darauf hin, dass
  derselbe Punkt in drei Runden als offen gemeldet wurde, und nennt die
  Eskalationsregel 3.4 — der Koordinator hält dem entgegen, dass es sich um
  einen geplanten, von der Commit-Prüfsumme abhängigen Schritt handelt und
  nicht um ein dreimaliges Scheitern an derselben Prüfung, und legt beides dem
  Auftraggeber so vor; (2) die Auflösung der Differenz 44 gegen 37 war
  unbelegt — am Skript ausgezählt, die sieben Zeilen sind die
  Abweichungsmeldungen zu G04, B02, B03, B06, B07, B08 und B09; ADR 0002,
  6.13 d und die Einordnungszeile des Backlogs entsprechend berichtigt
  (Koordinator, weil das Probeskript sein eigenes Erhebungsmittel ist); (3) die
  Spalte "Soll" führte für ST-13 den gemessenen Wert statt des entschiedenen
  Solls — auf 2 gesetzt; (4) ADR 0002, 6.13 a nannte den PreToolUse-Hook
  "ausdrücklich untauglich" als D10-Prüfmittel, während die Quelle
  (`docs/06_Definition_of_Ready_und_Done.md`, Zeile D10; ADR 0002, O-8) sagt,
  er leiste die Stapelprüfung nicht und offen bleibe, ob sie als Betriebsart
  desselben Skripts entsteht — Wortlaut angeglichen und die Berührung mit O-8
  als dritte Abgrenzung aufgenommen (Software Architect); (5) R3-Q-010 ist
  ready und in der Summe, obwohl R1 nur zur Hälfte belegt ist — der Product
  Owner hat den Vorbehalt ausdrücklich in den Eintrag und in die sechste
  Nachführung geschrieben und die Gleichbehandlung mit R3-Q-001 bis R3-Q-009
  (gezählt, offene Punkte 12 und 15) begründet; eine Fortschreibung der
  Definition of Ready ist nicht erfolgt und als offener Punkt benannt.
  Nachrangig: Formulierung "nicht abgenommen ... R3-Q-005" in CLAUDE.md und im
  Nachweiserzeuger (berichtigt: R3-Q-005 ist nicht gebaut); Selbstverweise in
  der Kopfzeile ohne Präfix (entschieden, siehe Entscheidungen); geplante
  Schritte im Protokoll der ausgeführten Befehle (getrennt); O-27 als "in dieser
  Einheit geschlossen" (berichtigt); Wortlaut zu D10 im Feld Abhängigkeit des
  Backlogs (mit Befund 4 angeglichen).
- Nach diesen Behebungen ein letzter Durchgang des Static Software Testers auf
  dem Modell der Rolle über den Unterschied zum geprüften Stand; sein Ergebnis
  steht in der Zeile darunter, nachgetragen vor dem Commit.

**Delta-Prüfung** (Static Software Tester, Modell der Rolle, über den
Unterschied Arbeitsbaum gegen den geprüften Index): **nicht bestanden** mit
einem blockierenden Befund D-01 — der Absatz "Ergebnis in einem Absatz" dieser
Übergabe führte den Vermerk in `UEBERGABE.md` weiterhin als eingetragen, im
Widerspruch zum berichtigten Abschnitt "Schritt 1 — Eintragungen" derselben
Datei; vor dem Commit berichtigt. Drei nachrangige Befunde: D-02 (Wortlaut zur
Abweichung der sieben Meldungen, berichtigt), D-03 (die sechste Nachführung des
Backlogs nannte nur den offenen Punkt 18, nicht den in derselben Einheit
angefügten Punkt 19 — berichtigt), D-04 (die offenen Punkte 12 und 15 des
Backlogs nennen R3-Q-006 nicht, obwohl der Text "R3-Q-001 bis R3-Q-009" sagt —
aus dem Bestand geerbt, in dieser Einheit nicht entschieden, offen für den
Requirements Engineer mit dem Product Owner). Alle zehn Behebungen der
Abschlussprüfung tragen laut Delta-Prüfung; `make dod` dort Form 2, D20
`A_OK`, D19 `OHNE_BEFUND`; die sieben Abweichungszeilen und die 37 Proben
sind vom Prüfer selbst nachgezählt.

**Eskalationsregel 3.4, offen vorgelegt.** Der Prüfer hat festgehalten, dass
der Punkt `UEBERGABE.md` viermal gemeldet wurde — in den Runden 1 und 2 als
"noch nicht nachgeführt", in der Abschlussprüfung und in der Delta-Prüfung als
"als eingetragen behauptet, obwohl offen" — und legt die Zählfrage, ob das
"dieselbe Prüfung dreimal am gleichen Kriterium" ist, dem Auftraggeber vor.
Entscheid des Koordinators, ebenfalls offen vorgelegt: **kein Abbruch.** Die
ersten beiden Meldungen betrafen einen planmässig späteren Schritt, der die
Commit-Prüfsumme des Produkt-Repositories voraussetzt und deshalb vor dem
Commit nicht ausführbar ist; die beiden letzten betrafen zwei Sätze dieser
Übergabe, die diesen Schritt im Perfekt beschrieben, und beide sind berichtigt.
Der Schritt selbst wird in dieser Einheit unmittelbar nach dem Commit
eingelöst. Nach der Berichtigung der Befunde D-01 bis D-03 ist keine weitere
modellbasierte Prüfung gelaufen; der committete Stand ist danach allein mit
`make dod` und der mechanischen Formprüfung geprüft. Hält der Auftraggeber die
Zählung des Prüfers für die richtige, ist diese Einheit als nach 3.4 abgebrochen
zu lesen, und der Rest der Reihenfolge steht im Abschnitt "Nach der
Abschlussprüfung noch auszuführen".
