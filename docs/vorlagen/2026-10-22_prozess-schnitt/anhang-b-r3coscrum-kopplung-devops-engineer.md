# Prozess-Schnitt, Punkt D: Kopplung r3cosint und r3coscrum abschalten oder umbauen

Entwurf des DevOps Engineers vom 2026-10-22 für den Koordinator.
Grundlage: Auftrag "Prozess-Schnitt" und die Weisungen des Auftraggebers vom 2026-10-22 (Wortlaut in der Datendatei der Sitzung (Scratchpad, nicht im Repository): "Ich vertraue dir und deinen super Fähigkeiten und gehen nach deiner Empfehlung"; "Nein, FFHS braucht es nicht, nach Übergangsfrist weg").
Der Entwurf ist nicht geprüft (3.4); die Prüfung liegt beim Static Software Tester auf einem anderen Modell. In den beiden Repositories wurde nichts geändert. Alle Messungen liefen in Wegwerf-Klonen im Scratchpad; Quelle der Zahlen sind die Befehlsausgaben dieser Einheit.

## 0. Ergebnis

1. Die Repositories sind in beide Richtungen gekoppelt, durch zwei Arbeitsabläufe und zwei Zugriffstoken: `nachweise-uebertragen.yml` (r3cosint schreibt nach r3coscrum, Secret `NACHWEISE_TOKEN`) und `eingang.yml` (r3coscrum schreibt nach r3cosint, Secret `R3COSINT_TOKEN`). `meilenstein-tag.yml` hat keinen Teil r3coscrum und bleibt unverändert.
2. Der Hook `session-start-eingang.sh` liest nicht r3coscrum, sondern die Datei `docs/EINGANG_METHODIK.md` im Produkt-Repository. Ihr einziger Erzeuger ist `eingang.yml`. Nach dem Einfalten gibt es keinen Erzeuger mehr; Empfehlung: Hook entfernen, Datei eingefroren belassen.
3. Der Belegprüfer D20 liest den Nachbarordner r3coscrum (fester absoluter Pfad im Skript) fest verdrahtet mit. Ein Eintrag unter docs/methodik/ kann ihn nicht ersetzen: Eine Kopie macht eine Commit-Prüfsumme nicht auflösbar, nur der Commit-Verlauf tut das. Gemessen mit den Kopien, ohne Nachbarordner und ohne Verlauf: 129 Befunde, davon 117 zu Commit-Prüfsummen. Mit dem r3coscrum-Verlauf als Zweig archiv/r3coscrum in r3cosint: Rückgabewert 0, 0 Befunde, ohne Änderung am Skript.
4. 31 Commit-Prüfsummen aus r3coscrum sind in 16 Dateien von r3cosint zitiert (95 Vorkommen; ADR 0002: 47, Backlog: 14, CLAUDE.md: 7). Alle 31 liegen im Hauptzweig von r3coscrum (Anhang A).
5. Das Entfernen von `nachweise-uebertragen.yml` und `session-start-eingang.sh` erzeugt 21 D20-Befunde (Pfadzitate in 14 Dateien, Anhang C). Die Kopien erzeugen weitere 11 Befunde (nur fachliche Texte) bis 14 (mit den Referenzdateien, Anhang D). Beides gehört in dieselbe Einheit wie die Änderung, sonst ist `make dod` rot.
6. Der Erzeuger `scripts/nachweise-erzeugen.sh` führt beide zu entfernenden Dateien in seiner Artefaktliste; fehlt ein Artefakt, endet er mit Rückgabewert 1 und D12 wird rot. Die Zeilen fallen im selben Commit wie die Dateien.
7. Reihenfolge: Verlauf sichern (Zweig archiv/r3coscrum), dann Kopien mit Quell-Commit samt Ausnahmen, dann Abschalten (Workflow, Hook, Tokens), dann Archivieren durch den Auftraggeber, dann nach der Übergangsfrist Löschen. Archivieren vor dem Abschalten von `nachweise-uebertragen.yml` hätte rote Läufe zur Folge (Abschnitt 5).
8. Offen für den Auftraggeber: Ersatz für den Abzug aus 6.6 (nachweise/abzug/), Sichtbarkeit von r3cosint, Umstellung der Sitzungsumgebung (Abschnitt 7).

## 1. Stand der Erhebung

| Gegenstand | Wert |
|---|---|
| r3cosint, Zweig ccr-0cbb4387-oe1i3c | `4a27245973ecbbc5d29b02d0bdfb4d8fa38935a7` (2026-10-22), Klon nicht flach |
| r3coscrum, Sitzungszweig ccr-0cbb4387-oe1i3c | `078ee0076056592c374dd0724c232173177969d6`, ein Commit über dem Hauptzweig (Übergabevermerk D1 und C3, nicht gemergt) |
| r3coscrum, Hauptzweig | `f8cb47867fe09b80adb623a6c37fb6d800c49f1c`, 87 Commits, Packgrösse 213 KiB, Klon nicht flach |
| Wegwerf-Klon der Messungen | Scratchpad der Sitzung, Ordner probe-1 (nicht im Repository) (Ausgaben `ausgabe-*.txt`, Läufe `lauf-*.txt`) |
| Maschinell erzeugte Listen | Scratchpad der Sitzung, Datei anhang-hashes.md (nicht im Repository), Scratchpad der Sitzung, Datei anhang-quellen.md (nicht im Repository) (unten als Anhang A und B eingefügt) |

## 2. Inventar

### 2.1 Arbeitsabläufe

| Kennung | Datei (Zeilen) | Name | Auslöser | Schreibt | Zugang | Commit-Identität | Folge |
|---|---|---|---|---|---|---|---|
| W1 | r3cosint: `.github/workflows/nachweise-uebertragen.yml` (264) | "Nachweise nach Repo B übertragen" | Push auf den Hauptzweig mit Änderungen unter `docs/`, `.claude/`, dem Prototyp-Verzeichnis, `CLAUDE.md`, `.github/workflows/`, `scripts/`; Versionsschild `v*`; manueller Start (Eingaben `schild`, `abzug`) | In r3coscrum: `nachweise/NACHWEISE.md`, `nachweise/HINWEIS.md`, optional nachweise/abzug/. Ein Commit je Lauf mit Änderung, Betreff "nachweise: Stand <Bezug> aus r3cosint", direkter Push auf den Standardzweig (Z. 264). 22 solche Commits im Verlauf, jüngster `b881a0b509984bcbe4462e6f21715c61ae9fa900` | Secret `NACHWEISE_TOKEN` (Z. 168; Zugriffstoken mit Schreibrecht nur auf r3coscrum); `permissions: contents: read`; r3cosint ohne gespeicherte Anmeldedaten ausgecheckt | Name `r3cosint-nachweise[bot]`, E-Mail `41898282+github-actions[bot]@users.noreply.github.com` (Z. 247 und 253) | Entfernen |
| W2 | r3cosint: `.github/workflows/meilenstein-tag.yml` (184) | "Meilenstein-Tag und Release" | Pull Request gegen den Hauptzweig geschlossen, gemergt, Label `meilenstein` | Versionsschild `vMAJOR.MINOR.PATCH` (aus den Commit-Betreffen abgeleitet) und GitHub-Release, beides in r3cosint | `GITHUB_TOKEN` (`contents: write`, Z. 171) | Name `r3cosint-meilenstein[bot]`, gleiche E-Mail (Z. 154 und 160) | Unverändert. Kopfkommentar Z. 40: "Kein Zugriff auf Repo B". Es gibt keinen Teil r3coscrum |
| W3 | r3coscrum: .github/workflows/eingang.yml (344) | "Eingang Methodik" | Push auf den Hauptzweig mit Änderungen unter `methodik/` oder `sprints/` | In r3cosint: Zweig `eingang/methodik`, angehängter Eintrag in `docs/EINGANG_METHODIK.md`, Pull Request "Eingang Methodik" (nie direkter Commit; Push mit `--force-with-lease`, Z. 309; `gh pr create`, Z. 339) | Secret `R3COSINT_TOKEN` (Z. 52 und 211; Schreibrecht auf Inhalte und Pull Requests in r3cosint); `permissions: contents: read` | Name `github-actions[bot]`, gleiche E-Mail (Z. 217 und 218) | Abschalten, dann Archivieren |

Ohne Kopplung, in beiden Repositories vorhanden: `.github/dependabot.yml` (26 Zeilen), `.github/CODEOWNERS` (4 und 5 Zeilen), `.github/pull_request_template.md` (je 16 Zeilen).

Was W1 ausser dem Übertragen tut und bei einem Ersatz zu bedenken ist: Es erzeugt das Nachweisverzeichnis neu (Z. 127 bis 130), prüft es (kein Zweigverweis, jeder Verweis mit 40-stelliger Prüfsumme, mindestens ein Artefakt; Z. 132 bis 162) und vergleicht es mit dem Stand in r3coscrum (Idempotenz, Z. 172 bis 194). Die Prüfung der Verweisform deckt sich zum Teil mit D20 (Zweigverweis, 40 Stellen), D12 ruft den Erzeuger ohnehin auf.

### 2.2 Skripte, Hooks, Makefile, Einstellungen

| Datei | Zeilen | Kopplung (Fundort) | Bemerkung |
|---|---|---|---|
| `.claude/hooks/session-start-eingang.sh` | 220 | Liest `docs/EINGANG_METHODIK.md` (Z. 43), fasst den Text als fremden Inhalt ein (Marker mit Zufallskennung), kappt auf 400 Zeilen und 20'000 Zeichen (Z. 55 und 56), Meldung "Stand aus dem Methodik-Repository" (Z. 209). Liest r3coscrum selbst nicht | SessionStart; die Ausgabe wird Kontext der Sitzung |
| `.claude/settings.json` | | Eintrag Z. 29 bis 39: Auslöser `startup|resume|clear|compact`, Zeitgrenze 10 s, Statusmeldung "Liest den Eingang aus dem Methodik-Repository (6.6)" | Registrierung des Hooks |
| `docs/EINGANG_METHODIK.md` | 384 | 8 Einträge, je mit Zeile "**Nachweis:** https://github.com/valITino/r3coscrum/commit/<40 Stellen>"; jüngster Eintrag 2026-09-23 (`cb838ecd35baba30fb04ab64300e501ab55ed0b6`). Überschrift "## Einträge" und Nachweiszeile sind die Schnittstelle zu W3 und zum Hook | 21 Dateien nennen den Hook oder diese Datei |
| `scripts/nachweise-erzeugen.sh` | 172 | Artefaktliste enthält `docs/EINGANG_METHODIK.md` (Z. 31), `.claude/hooks/session-start-eingang.sh` (Z. 62), `.github/workflows/nachweise-uebertragen.yml` (Z. 77). Der erzeugte Text endet mit dem Abschnitt "Übertragung nach Repo B" (Z. 155 bis 164). Fehlt ein Artefakt: Rückgabewert 1 | Erzeuger von `docs/NACHWEISE.md` (121 Zeilen) |
| `Makefile` | 1919 | Kein Treffer für r3coscrum. D12 `nachweise` (Z. 1437 bis 1481) ruft den Erzeuger mit einer Wegwerfdatei auf; D20 `belege` (Z. 659 bis 745) ruft `scripts/belege-pruefen.sh` auf (Rückgabewert 2 rot, 3 Lage C) | D12 bleibt wegen des fehlenden scripts/nachweise-vollstaendig.sh Lage C, unabhängig von dieser Arbeit |
| `scripts/belege-pruefen.sh` (D20) | 803 | Fest verdrahteter Nachbarordner r3coscrum (fester absoluter Pfad im Skript) (Kopfkommentar Z. 63 bis 70, Erkennung Z. 296 bis 301). Er wird gelesen für: (1) Commit-Prüfsummen, `git cat-file` gegen beide Repositories (Prüfung 2, Z. 622 ff.); (2) Pfade unter `methodik/`, `nachweise/`, `sprints/` (Regel c, Z. 549 bis 565); (3) Pfade mit Präfix `r3coscrum/` (Regel d, Z. 567 bis etwa 590). Fehlt der Nachbarordner, sind Pfade "nicht prüfbar" (kein Befund), nicht auflösbare Prüfsummen aber ein Befund. Schlusszeile Z. 796 "Repo B (r3coscrum) mitgelesen: ja/nein" | Nichts liest diese Zeile (Suche in Makefile, scripts, .claude ohne Treffer ausserhalb des Skripts). Es gibt kein skriptgestütztes Prüfmittel für D20; D20 ist nicht abgenommen (O-15) |
| `scripts/belege-ausnahmen.txt` | 70 | Z. 38: docs/00_Projektauftrag.md|nachweise/abzug/ (Abzug erst bei der Abgabe, 6.6). Formen `datei:zeile` und `datei|wert`, je mit Grund | Bleibt; nimmt die neuen Ausnahmen auf |
| `scripts/einschleusung-pruefsatz/inhalte/PS-03.txt`, `PS-10.txt` | | Kanalbezeichnung "Eingang aus dem Methodik-Repository" als Inhalt des eingefrorenen Prüfsatzes | Nicht ändern |
| Textstellen in Regeln und Rollen | | `.claude/rules/fremde-inhalte-im-harness.md` Z. 19; `dokumentation.md` Z. 50 und 51; `versionierung-und-nachweisfluss.md` Z. 43 und 77 bis 79; `claude-konfiguration.md` Z. 58; `.claude/agents/devops-engineer.md` Z. 23 und 38; `protocol-master.md` Z. 35; `product-owner.md` Z. 39; `CLAUDE.md` (Absatz zu den SessionStart-Hooks, Statuszeile, Gate-Zeilen) | Folgeänderungen, Abschnitt 4 Posten 9 |
| Kommentare in zwei Hooks | | `.claude/hooks/session-start-gitleaks.sh` Z. 13 und `session-start-git-historie.sh` Z. 107 nennen den Eingangs-Hook als Vergleich | Kommentar anpassen |
| Sitzungsumgebung | | Die Umgebung verbindet beide Repositories (in dieser Sitzung ist r3coscrum das Primärverzeichnis, r3cosint zusätzlich; je Repository ein Sitzungszweig ccr-0cbb4387-oe1i3c) | Ausserhalb der Repositories, Auftraggeber |

### 2.3 Inhalte in r3coscrum (Pfad, Zeilen, Bytes, letzter Commit je Datei)

| Pfad | Zeilen | Bytes | Letzter Commit (40 Stellen) | Art | Vorschlag |
|---|---|---|---|---|---|
| `methodik/arbeitsprodukte.md` | 111 | 8'545 | `e43b9a7fe808463b121f4352b9f1ba10267bdf5c` | Methodik-Text | K1 |
| `methodik/entscheide.md` | 176 | 36'730 | `30864e9c59b09495405b368419fbde719cf8f05d` | Entscheidlog | K1 |
| `methodik/re-prozess.md` | 117 | 6'999 | `e43b9a7fe808463b121f4352b9f1ba10267bdf5c` | Methodik-Text | K1 |
| `methodik/scrum-aufbau.md` | 140 | 8'757 | `e43b9a7fe808463b121f4352b9f1ba10267bdf5c` | Methodik-Text | K1 |
| `UEBERGABE.md` | 1'561 | 88'048 | `078ee0076056592c374dd0724c232173177969d6` (nur auf dem Sitzungszweig; Hauptzweig vor dessen Merge: neu erheben) | Übergabevermerke | K1, eingefrorenes Archiv |
| `CLAUDE.md` | 18 | 912 | `7f59a16cb3ccd10b31aae1549ba7667dcc2fdefd` | Regeln des Repositories | K2 |
| `README.md` | 39 | 1'506 | `7f59a16cb3ccd10b31aae1549ba7667dcc2fdefd` | Aufbau, "Keine Kopien", Abzug | K2 |
| `CONTRIBUTING.md` | 40 | 1'808 | `08d358f6af3b049a9d13caada88c9c57bb379e52` | Zweige, Merge nur durch den Eigentümer; Repository ist öffentlich | K2 |
| `.claude/rules/versionierung-und-nachweisfluss.md` | 59 | 2'998 | `e43b9a7fe808463b121f4352b9f1ba10267bdf5c` | Regel; 148 Diff-Zeilen gegenüber der gleichnamigen Regel in r3cosint; enthält die Hashes der zwei Commits mit falscher Identität | K2 |
| `nachweise/NACHWEISE.md` | 120 | 33'512 | `b881a0b509984bcbe4462e6f21715c61ae9fa900` | Ableitung aus r3cosint | K3 |
| `nachweise/HINWEIS.md` | 5 | 316 | `b881a0b509984bcbe4462e6f21715c61ae9fa900` | Ableitung; nennt den Quell-Commit `998f81d9fffe3970baf870d04e44576eda534fcc` | K3 |
| .github/workflows/eingang.yml | 344 | 16'882 | `26b64a86aa9350b0ad67ac95f4bd77f58bedea6a` | Konfiguration (W3) | K4 |
| `.github/CODEOWNERS` | 5 | 174 | `08d358f6af3b049a9d13caada88c9c57bb379e52` | Konfiguration | K4 |
| `.github/dependabot.yml` | 26 | 1'157 | `7fb8c90c3219ee1731d77b7339df12392cc7ac2d` | Konfiguration | K4 |
| `.github/pull_request_template.md` | 16 | 501 | `08d358f6af3b049a9d13caada88c9c57bb379e52` | Konfiguration | K4 |
| `.gitignore` | 21 | 403 | `0d8c88ade70a40de0d31f87a0976672737c97644` | Konfiguration | K4 |
| `nachweise/.gitkeep`, `sprints/.gitkeep` | 0 | 0 | `97891e91ea7e3a628ae8e6575879d08645bd3116` | leer | keine |

Legende. K1: fachlicher Inhalt, wörtlich nach docs/methodik/, gleicher Dateiname, byte-gleich. K2: Referenz, nicht kopiert; in docs/methodik/QUELLEN.md mit Quell-Commit und SHA-256 geführt, Inhalt über den Archivzweig lesbar. K3: abgeleitet, aus dem Verlauf von r3cosint reproduzierbar (der Quell-Commit steht in `HINWEIS.md`; 22 Stände im Verlauf), keine Kopie. K4: Konfiguration, bleibt im archivierten Repository.
Die Quellen des Eingangs sind `methodik/**` und `sprints/**` (Letzteres leer); die Eingangsdatei selbst liegt schon in r3cosint.

### 2.4 Verweise in r3cosint auf r3coscrum

| Form | Menge | Verteilung |
|---|---|---|
| Wortlaut `r3coscrum` (Befehl wie beauftragt: `docs/`, `CLAUDE.md`, `.claude/`, `scripts/`, `Makefile`) | 109 Zeilen; mit `.github/` 110 Zeilen in 23 Dateien | ADR 0002: 41; Zustandsbericht 2026-09-02: 18; `docs/EINGANG_METHODIK.md`: 10; `scripts/belege-pruefen.sh`: 9; `scripts/nachweise-erzeugen.sh`, `docs/NACHWEISE.md`, `docs/05_Product_Backlog.md`: je 3; `docs/uebergaben/`: 14 in 9 Dateien; `docs/vorlagen/`: 2; Zustandsbericht 2026-08-21: 2; Kontextmodell, Stakeholderliste, Projektauftrag, `CLAUDE.md`, `nachweise-uebertragen.yml`: je 1. In `.claude/` und im Makefile kein Treffer |
| Wortformen "Repo B" und "Methodik-Repositor..." (ohne den Namen) | 242 Zeilen in 51 Dateien | `docs/`, `CLAUDE.md`, `.claude/`, `scripts/`, `.github/` |
| Commit-Prüfsummen, die nur in r3coscrum auflösen | 31 verschiedene, 95 Vorkommen in 16 Dateien | ADR 0002: 47; Backlog: 14; `docs/EINGANG_METHODIK.md`: 8; `CLAUDE.md`: 7; zehn Übergaben: 16; Zustandsberichte: 3. Liste in Anhang A. 13 Merge-Commits (Pull Requests #1, #2, #6, #8 bis #17), 9 Bot-Commits "nachweise: Stand ...", 9 Commits "docs: ..." |
| Pfadzitate in Rückwärtsakzenten unter `methodik/`, `nachweise/`, `sprints/` | 59 | Von D20 gegen den Nachbarordner geprüft; ohne ihn "nicht prüfbar" (46 in der Basismessung) |
| Prüfsummen, die in keinem der beiden Repositories auflösen | 3 (`11d5960a...`, `3d3c42e5...`, `882ef55e...`) | In r3cosint von D20 nicht gemeldet (Ausnahmeliste oder Codeblock, nicht einzeln geprüft). Zwei davon stehen auch in den Quelltexten K1 |

## 3. Messungen mit D20 im Wegwerf-Klon

Aufbau: Klon von r3cosint ohne Hardlinks am Stand `4a272459...`; je Variante eine Kopie davon; `bash scripts/belege-pruefen.sh` je Variante (14 bis 15 s). "Nachbarordner nicht vorhanden" heisst: der feste Pfad im Skript des Klons zeigt auf einen nicht vorhandenen Ordner. "Archivzweig" heisst: alle Zweige von r3coscrum als Zweige in den Klon geholt.

| Variante | Zustand | Rückgabewert | Befunde | Nicht prüfbar |
|---|---|---|---|---|
| 0 | Basis, Nachbarordner vorhanden | 0 | 0 | 0 |
| a | neun Kopien unter docs/methodik/ (K1 und K2, je mit Kopfzeile "Kopie aus ..., Quell-Commit ..."), Nachbarordner vorhanden | 2 | 15 | 0 |
| b | wie a, Nachbarordner nicht vorhanden | 2 | 129 (Commit 117, Pfad 5, Abschnitt 4, blob/ mit dem Zweignamen main 3) | 71 |
| c | wie b, mit Archivzweig | 2 | 14 | 71 |
| vf | Basis ohne Kopien, Nachbarordner nicht vorhanden, mit Archivzweig | 0 | 0 | 46 |
| vd | wie vf; Workflow und Hook entfernt, Artefaktliste angepasst, Nachweisverzeichnis neu erzeugt | 2 | 21 (nur Pfade) | 46 |
| vh | wie vf; nur der Hook entfernt (Verzeichnis nicht neu erzeugt) | 2 | 14 | 46 |
| vw | wie vf; nur der Workflow entfernt (Liste und Verzeichnis neu erzeugt) | 2 | 8 | 46 |

Lesart.
- vf: D20 braucht für die Abschaltung des Nachbarordners keine Codeänderung, wenn der Verlauf in r3cosint liegt. Zwischen b und c verschwinden 115 der 117 Prüfsummenbefunde; zwei bleiben, weil `11d5960a...` und `882ef55e...` in keinem Repository auflösen.
- Kopien: 14 Befunde in c, davon 11 aus K1 (UEBERGABE.md: 9, entscheide.md: 2) und 3 aus K2 (`CLAUDE.md:15` und `CONTRIBUTING.md:34` "blob/ mit dem Zweignamen main", Regeldatei Z. 55 .github/workflows/eingang.yml). In a kommt `README.md:36` (nachweise/abzug/) hinzu, solange der Nachbarordner vorhanden ist. Die Zahl 11 für K1 allein ist aus der Befundliste abgeleitet, nicht gesondert gemessen. Einzelheiten in Anhang D.
- Entfernte Dateien: 21 Pfadbefunde in 14 Dateien (13 für den Hook, 8 für den Workflow, Anhang C). D20 meldet nur Pfade mit Verzeichnisteil; der blosse Dateiname `session-start-eingang.sh` (etwa in `CLAUDE.md` und `claude-konfiguration.md`) wird nicht gemeldet.
- `gitleaks detect --no-git` über die neun Kopien: kein Fund.

Grenzen der Messung. Der Archivzweig wurde aus dem lokalen r3coscrum-Klon geholt, nicht über `origin`; dass eine frische Sitzung ihn beim Start holt, folgt aus dem Skript `session-start-git-historie.sh` (Refspec `+refs/heads/*:refs/remotes/origin/*`, Z. 374) und ist in keiner Sitzung geprüft. Gelaufen ist nur D20, nicht die ganze Kette `make dod`. Die Kopien trugen in der Messung eine Kopfzeile; der Vorschlag unten sieht byte-gleiche Kopien und eine Quellenliste vor, die Befundzahl kann dadurch um die Prüfsumme der Kopfzeile sinken.

## 4. Vorschlag je Posten

**Posten 1: `nachweise-uebertragen.yml` (W1). Entfernen.**
- Der Zweck, ein Nachweisverzeichnis in Repo B zu führen, entfällt. Bleibt die Datei bis zur Archivierung stehen, scheitert jeder Lauf mit Änderung am Schreibschritt; nach der Archivierung wird ein Push in ein archiviertes Repository abgelehnt (GitHub-Verhalten, nicht erprobt).
- Ein Umbau auf einen r3cosint-internen Lauf ist jetzt nicht nötig: D12 ruft den Erzeuger ohnehin auf, D20 prüft die Verweisform. Ein rein lesender Prüfschritt (Verzeichnis neu erzeugen, Form der Verweise prüfen, Abweichung vom eingecheckten Stand melden, keine Secrets, `contents: read`) bleibt als Möglichkeit für das Grundgerüst. Beachten: Der Erzeuger schreibt den Stand des Repositories in die Datei (Zeile "Stand des Repositories"); ein Vergleich muss diese Zeile ausnehmen.
- Folgearbeit im selben Commit: zwei Zeilen im Erzeuger streichen (Z. 77 und die Hook-Zeile), den Schlussabschnitt "Übertragung nach Repo B" (Z. 155 bis 164) ersetzen, `docs/NACHWEISE.md` neu erzeugen, acht Pfadzitate behandeln (Anhang C).
- Abzug (`abzug`-Eingabe, nachweise/abzug/): zurückstellen bis zur Abgabe. Vorschlag für später: Release-Anhang am Versionsschild (`git archive` der in `docs/NACHWEISE.md` verwiesenen Pfade, SHA-256-Datei, `gh release upload`), in `meilenstein-tag.yml`, ohne neues Secret und ohne zweites Repository. Entscheid über Form und Zeitpunkt beim Auftraggeber.

**Posten 2: `meilenstein-tag.yml` (W2). Unverändert.** Es liest und schreibt nur r3cosint. Der Entwurf nennt einen "Teil r3coscrum"; diesen Teil gibt es nicht.

**Posten 3: `eingang.yml` (W3). Abschalten, dann Archivieren.**
- Zuerst das Zugriffstoken `R3COSINT_TOKEN` widerrufen und das Secret in r3coscrum löschen (das sensibelste Recht der Kopplung: Schreibrecht auf Inhalte und Pull Requests in r3cosint). Danach die Datei per Pull Request in r3coscrum löschen (Pfad liegt nicht unter `methodik/` oder `sprints/`, löst also nichts aus) oder Actions in den Einstellungen deaktivieren. Danach archivieren.
- Bis dahin keine Änderung unter `methodik/` oder `sprints/` in r3coscrum, sonst eröffnet W3 einen Pull Request in r3cosint.

**Posten 4: `session-start-eingang.sh` und `docs/EINGANG_METHODIK.md`. Hook entfernen, Datei eingefroren belassen.**

| | A: Hook entfernen (Empfehlung) | B: auf docs/methodik/EINGANG.md umstellen |
|---|---|---|
| Änderung | Skript, Einstellungen Z. 29 bis 39, Kommentarzeilen in zwei Hooks, `claude-konfiguration.md` Z. 58, `CLAUDE.md`, Kanaltabelle der Regel Z. 19, Rollentext `product-owner.md` Z. 39, Zeile im Erzeuger | Skript Z. 43 (Pfad) und Z. 209 (Meldung), Statusmeldung in den Einstellungen |
| Wirkung | Kein Eingangs-Kontext mehr; Kanal "Eingang" entfällt | Ohne Erzeuger bleibt der Inhalt statisch; jede Sitzung erhält bis zu 20'000 Zeichen ohne neue Information |
| D20 | 13 Pfadbefunde (Anhang C) | keine |
| Prüfsatz | `PS-03` und `PS-10` bleiben unverändert (Bezeichnung des Kanals im eingefrorenen Prüfsatz) | unverändert |

- Die Datei `docs/EINGANG_METHODIK.md` nicht verschieben und nicht umbenennen: 21 Dateien nennen sie, D20 prüft die Pfadzitate. Sie erhält einen Kopfvermerk "eingefroren, Kanal geschlossen, Erzeuger entfällt" und bleibt in der Artefaktliste.
- Zur Gegenprobe `R3-Q-011_regel_im_startkontext`: Der Eingang ist im Backlog (Z. 160 und 161) als möglicher Nebenweg genannt, über den ein Merksatz in den Kontext gelangen könnte, nicht als Träger des Versuchs. Das Entfernen des Hooks beseitigt diesen Nebenweg; dem Software Architect zur Kenntnis geben.
- Zuständigkeit: Hooks und Einstellungen schreibt der SecDevOps Engineer (Entscheid vom 2026-09-23 zu `.claude/skills/` "wie bei den Hooks"); die Zuordnung ist durch den Koordinator zu bestätigen.

**Posten 5: D20 (`scripts/belege-pruefen.sh`). Mitlesen von Repo B abschalten.**
- Stufe 1, ohne Codeänderung: Archivzweig archiv/r3coscrum (Posten 8). Messung vf: Rückgabewert 0, 0 Befunde.
- Stufe 2, Codeänderung (SecDevOps Engineer, Verifikation Static und Dynamic Software Tester): Erkennung des Nachbarordners entfernen (Z. 296 bis 301); Regel c: `methodik/<x>` gegen `docs/methodik/<x>` prüfen, `nachweise/` und `sprints/` als "nicht prüfbar"; Regel d (Präfix `r3coscrum/`) als "nicht prüfbar"; Kopfkommentar (Z. 63 bis 70, 92, 168) und Schlusszeile (Z. 796, etwa "Repo B (r3coscrum) mitgelesen: nein, archiviert") anpassen. Begründung: Heute hängt das Ergebnis vom Vorhandensein eines Nachbarordners ab (gleiche Eingabe, je Maschine verschiedene Ausgabe).
- Da kein skriptgestütztes Prüfmittel besteht, gilt als Prüfung der Vorher-Nachher-Vergleich desselben Wegwerf-Klons (Abschnitt 3: gleiche Befundmenge für gleiche Eingabe) und ein Lauf in einem frischen Klon ohne Nachbarordner.
- Die Ausnahmen für die Kopien (Anhang D) und die entfernten Dateien (Anhang C) tragen in `scripts/belege-ausnahmen.txt` den Grund im Quelltext der Einheit; wo ein aktueller Text betroffen ist (die beiden Regeln), wird der Text berichtigt, nicht ausgenommen.

**Posten 6: Erzeuger `scripts/nachweise-erzeugen.sh` und `docs/NACHWEISE.md`.** Zeilen für W1 und Hook streichen, Eintrag "Eingang Methodik" umformulieren ("eingefroren, früheres Methodik-Repository"), Schlussabschnitt ersetzen, Zeilen für die K1-Kopien ergänzen (verwiesen wird auf den Commit in r3cosint, der die Kopie einführt; der Quell-Commit steht in `QUELLEN.md`). Danach das Verzeichnis neu erzeugen. Protocol Master liefert das Verzeichnis, der DevOps Engineer den Erzeuger (Rollentexte).

**Posten 7: Kopien nach docs/methodik/.**
- K1 (fünf Dateien) byte-gleich, gleicher Dateiname (relative Verweise bleiben gültig), dazu docs/methodik/QUELLEN.md (Entwurf: Anhang B) mit Quellpfad, Quell-Commit (40 Stellen), SHA-256 des Quell-Blobs, Zeilenzahl, Art. Byte-gleich heisst: keine Kopfzeile in der Kopie; die Herkunft steht in der Quellenliste.
- Der Quell-Commit von `UEBERGABE.md` liegt heute nur auf dem Sitzungszweig; er ist nach dem Merge des offenen Vermerks neu zu erheben.
- Verweise der Form `https://github.com/valITino/r3coscrum/commit/<h>` (8 in der Eingangsdatei, weitere in anderen Dateien) lösen nach dem Löschen nicht mehr auf; dieselbe Prüfsumme löst unter `https://github.com/valITino/r3cosint/commit/<h>` auf, sobald der Archivzweig in r3cosint liegt. Das steht in `QUELLEN.md`; die Zitate in den Dokumenten bleiben als Belege unverändert (Ausnahme: die Nachträge "Kopie unter docs/methodik/..." in ADR 0002 Abschnitt 10 und `CLAUDE.md`, die der Koordinator vorgesehen hat).
- Eine einmalige Prüfung, dass jede Kopie dem Quell-Blob entspricht (SHA-256 gegen `git show <Quell-Commit>:<Pfad>`), im Protokoll der Einheit; kein dauerhafter Kettenschritt.

**Posten 8: Archivzweig archiv/r3coscrum in r3cosint.**
- Zweig (nicht Versionsschild), weil die Sitzungshooks nur Zweige holen (`+refs/heads/*:refs/remotes/origin/*`). Inhalt: der unveränderte Verlauf von r3coscrum (Hauptzweig, 87 Commits, 213 KiB). Er wird nie in den Hauptzweig von r3cosint gemergt: Die Versionsableitung in `meilenstein-tag.yml` liest alle Commit-Betreffe seit dem letzten Versionsschild (`git log` über den Bereich) und würde sonst fremde Betreffe auswerten.
- Prüfung nach dem Anlegen: Alle 31 Prüfsummen aus Anhang A lösen im r3cosint-Klon mit `git cat-file -e <h>^{commit}` auf.
- Wer: der Auftraggeber lokal (Verlauf aus dem r3coscrum-Klon in den Zweig holen, Zweig nach `origin` veröffentlichen). Ob eine Sitzung einen zweiten Zweig im verbundenen Repository veröffentlichen darf, ist nicht geprüft.
- Nach dem letzten Bot-Commit von W1 (siehe Abschnitt 5) und nach dem Hinweis in der README von r3coscrum einmal nachführen.

**Posten 9: Folgeänderungen ausserhalb meiner Zuständigkeit (Koordinator, Rollen, Auftraggeber).** Projektauftrag 1.3 und 6.6 (Fortschreibung als Vorschlag; Zeilen 71, 930 bis 951 nennen Repo B, "keine Kopien" und die Übertragung); `CLAUDE.md`; die Regeln und Rollentexte aus Abschnitt 2.2; ADR 0002 (Kanalliste in 6.14, Abschnitt 10); Backlog (Product Owner, soweit Einträge W1 oder den Eingang nennen: Suche nach `nachweise-uebertragen` in Backlog, Roadmap und Definition of Ready ergab keinen Treffer).

**Posten 10: Zugangsdaten und Umgebung (Auftraggeber).** `NACHWEISE_TOKEN` in r3cosint und `R3COSINT_TOKEN` in r3coscrum widerrufen und die Secrets löschen. Existenz und Rechte der Secrets sind nicht geprüft (Einstellungen der Repositories). In der Sitzungsumgebung r3coscrum aus den verbundenen Repositories nehmen und eine Probesitzung starten, bevor archiviert wird.

**Posten 11: `CHANGELOG.md`.** Die Datei existiert in r3cosint nicht. Das Entfernen zweier Arbeitsabläufe und eines Hooks gehört nach Keep a Changelog unter "Entfernt". Vorschlag: Datei mit dieser Einheit anlegen (Abschnitt "Unreleased") oder den Eintrag mit dem Grundgerüst nachholen; Entscheid beim Koordinator.

## 5. Reihenfolge

Grundsatz wie beauftragt: erst Kopien mit Quell-Prüfsumme, dann Abschalten, dann Archivieren durch den Auftraggeber. Drei Verfeinerungen aus den Messungen: der Verlauf wird vor den Kopien gesichert; Kopien, Ausnahmen und Erzeuger sind eine Einheit mit der Entfernung der Dateien (sonst ist `make dod` zwischen zwei Commits rot); die Zugangsdaten werden vor dem Archivieren widerrufen.

| Schritt | Inhalt | Wer | Prüfung |
|---|---|---|---|
| V1 | Pull Request #28 gemergt (nach den Unterlagen der Inhalt von C3). W1 läuft dabei noch ein letztes Mal und schreibt einen Bot-Commit nach r3coscrum | Auftraggeber | Bot-Commit "nachweise: Stand <Merge-Commit> aus r3cosint" im Verlauf von r3coscrum |
| V2 | Offenen r3coscrum-Vermerk (Sitzungszweig `078ee007...`) mergen oder verwerfen; Schreibstopp für `methodik/`, `sprints/` | Auftraggeber | Hauptzweig von r3coscrum benannt (Einfrierpunkt) |
| V3 | Archivzweig archiv/r3coscrum anlegen und veröffentlichen (Posten 8) | Auftraggeber | 31 von 31 Prüfsummen lösen in einem frischen r3cosint-Klon auf |
| E1 | Kopien K1 und `QUELLEN.md` (Posten 7) | DevOps Engineer | SHA-256 jeder Kopie gleich dem Quell-Blob |
| E2 | Ausnahmen für die Kopien (11 Fundstellen, Anhang D; mit K2 14) | SecDevOps Engineer | D20 mit Kopien: Befunde 0 |
| E3 | W1 und Erzeuger-Zeilen entfernen, Verzeichnis neu erzeugen (Posten 1 und 6); Hook entfernen (Posten 4); 21 Pfadzitate behandeln (Anhang C) | DevOps Engineer, SecDevOps Engineer, Protocol Master | D12 und D20 grün (Lage C von D12 unverändert) |
| E4 | D20 ohne Nachbarordner (Posten 5, Stufe 2), falls in dieser Einheit | SecDevOps Engineer | Vorher-Nachher-Vergleich der Befundmenge; Lauf im frischen Klon ohne Nachbarordner |
| E5 | Folgeänderungen Text (Posten 9) | Koordinator, Product Owner, Software Architect | statische Prüfrunde |
| E6 | Verifikation der Einheit, `make dod` im frischen Klon ohne Nachbarordner | Static und Dynamic Software Tester | Rückgabewert 0, Lagen je Schritt benannt |
| N1 | Zugriffstoken widerrufen, Secrets löschen (Posten 3 und 10) | Auftraggeber | |
| N2 | Hinweis in der README von r3coscrum ("archiviert, Inhalt in r3cosint unter docs/methodik/"), `eingang.yml` löschen oder Actions deaktivieren; Archivzweig nachführen | Koordinator schreibt, Auftraggeber merged | der Hinweis-Pull-Request berührt weder `methodik/` noch `sprints/` |
| N3 | Sitzungsumgebung auf r3cosint allein umstellen, Probesitzung | Auftraggeber | Sitzungsstart und -ende ohne Fehler |
| N4 | r3coscrum archivieren (nur lesbar) | Auftraggeber | |
| N5 | Übergangsfrist; Löschen durch den Auftraggeber (Vorschlag: nach dem Merge, der die Freigabe des Grundgerüsts trägt); davor Abnahmeprobe: frischer Klon von r3cosint ohne Nachbarordner, `make dod`, D20 meldet "mitgelesen: nein" und 0 Befunde | Auftraggeber, Dynamic Software Tester | |

Begründung der Lage von N1 und N2 vor N4: Mit dem Widerruf von `R3COSINT_TOKEN` ist `eingang.yml` wirkungslos; mit der Entfernung von W1 in E3 (vor N4) schreibt nichts mehr in ein archiviertes Repository.

## 6. Risiken

| Nr. | Risiko | Beleg | Gegenmassnahme |
|---|---|---|---|
| R1 | D20 wird rot, sobald der Nachbarordner fehlt, ohne dass der Verlauf in r3cosint liegt | Variante b: 129 Befunde, davon 117 Prüfsummen | Archivzweig vor jeder Sitzung ohne Nachbarordner (V3); Abnahmeprobe N5 |
| R2 | Kopien lösen die zitierten Prüfsummen nicht auf (Annahme im Entwurf: "als Kopien vorliegen, damit die Verweise auflösbar bleiben") | Eine Prüfsumme bezeichnet ein Commit-Objekt; eine Kopie von Dateien enthält keines. 31 zitierte Prüfsummen, 95 Vorkommen in 16 Dateien | Archivzweig; die Kopien dienen der Lesbarkeit in einer Sitzung (6.6: pro Sitzung ein Repository), nicht der Auflösung |
| R3 | Entfernte Dateien werden in Dokumenten zitiert | 21 Pfadbefunde in 14 Dateien | Ausnahme je Fundort mit Grund für Belege eines vergangenen Standes; Textberichtigung in den zwei aktuellen Regeln |
| R4 | Kopien bringen eigene Befunde | 11 (K1) bis 14 (K1 und K2) | Ausnahmen mit Grund; K2 nicht kopieren spart 3 |
| R5 | Erzeuger endet mit Rückgabewert 1, D12 rot | `scripts/nachweise-erzeugen.sh` Z. 110 ("FEHLT"), D12 wertet den Rückgabewert | Zeilen im selben Commit wie die Dateien |
| R6 | Verfolgbarkeit nach 6.6: Verweise der Form `r3coscrum/commit/<h>` brechen nach dem Löschen (URL), die Prüfsumme bleibt auflösbar | 8 URLs in der Eingangsdatei, weitere in anderen Dokumenten | `QUELLEN.md` nennt die Ersatzform `r3cosint/commit/<h>`; Zitate bleiben unverändert |
| R7 | Projektauftrag 6.6 sagt "Repo B enthält keine Kopien" (Z. 71 und 949) und verlangt die Übertragung | `docs/00_Projektauftrag.md` | Fortschreibung als Vorschlag im Pull Request, Entscheid des Auftraggebers durch den Merge |
| R8 | Abgabe: Der Abzug unter nachweise/abzug/ sollte die Arbeit ohne Zugriff auf das Produkt-Repository lesbar halten (README von r3coscrum). r3coscrum ist öffentlich (CONTRIBUTING.md); die Sichtbarkeit von r3cosint ist nicht erhoben | `README.md` von r3coscrum, `scripts/belege-ausnahmen.txt` Z. 38 | Auftraggeber legt fest, wie die FFHS die Arbeit liest; mögliche Form: Release-Anhang (Posten 1) |
| R9 | Zwei Wahrheiten zwischen Kopieren und Archivieren | r3coscrum bleibt bis N4 beschreibbar | Schreibstopp ab V2; N2 und N4 unmittelbar nach dem Merge |
| R10 | Letzter W1-Lauf (V1) und spätere Bot-Commits bewegen den Hauptzweig von r3coscrum; `UEBERGABE.md` hat den Quell-Commit nur auf dem Sitzungszweig | Verlauf: Bot-Commit `b881a0b5...` nach dem Merge von #27 | Quell-Commit je Datei (nicht je Repository) verwenden; Archivzweig nach dem letzten Bot-Commit nachführen (N2) |
| R11 | Sitzungsumgebung verbindet beide Repositories; ein archiviertes Ziel kann Sitzungsstart oder -ende stören | Umgebung dieser Sitzung (Primärverzeichnis r3coscrum, Sitzungszweig in beiden) | N3 vor N4; nicht erprobt |
| R12 | Zugriffstoken mit Schreibrecht über die Repository-Grenze bleiben bis zum Widerruf bestehen | W1 Z. 168, W3 Z. 52 und 211 | N1; Bestätigung des Auftraggebers in der Übergabe (Datum, Name des Tokens) |
| R13 | D20 ist nicht abgenommen und ohne skriptgestütztes Prüfmittel; Änderungen laufen ohne automatisches Netz | `scripts/` enthält nur `belege-pruefen.sh` und `belege-ausnahmen.txt` | Vorher-Nachher-Vergleich im Wegwerf-Klon (Abschnitt 3 als Vorlage); Verifikation auf einem anderen Modell |
| R14 | Hook-Entfernung ändert Rahmen von R3-Q-011 (Kanalliste der Regel, Prüfsatz-Bezeichnung) | Backlog Z. 160 und 161; `PS-03`, `PS-10` | Software Architect und Koordinator; Prüfsatz nicht ändern |
| R15 | Datei `CHANGELOG.md` fehlt | `ls`: Datei nicht vorhanden | Posten 11 |

Keine Auswirkung auf die Produktionskonfiguration (5.15, 5.16) und auf die Bereitschaftsliste Punkte 1 und 3: Die Kopplung betrifft nur das Entwicklungs-Repository.

## 7. Offene Entscheide und Berichtigungen zum Entwurf des Koordinators (Punkt D)

Offene Entscheide.
1. Archivzweig archiv/r3coscrum in r3cosint: ja oder nein, und wer ihn veröffentlicht. Ohne ihn braucht D20 pro zitierter Prüfsumme eine Ausnahme (95 Vorkommen) oder die Zitate müssen entfallen.
2. Hook entfernen (Empfehlung) oder umstellen.
3. D20-Codeänderung (Posten 5, Stufe 2) in dieser Einheit oder als eigene Einheit; für das Abschalten genügt Stufe 1.
4. K2 (`CLAUDE.md`, `README.md`, `CONTRIBUTING.md`, Regeldatei) als Kopie oder nur als Referenz in `QUELLEN.md`.
5. Abzug aus 6.6: Ersatz als Release-Anhang oder ersatzlos.
6. Zeitpunkt der Archivierung: unmittelbar nach dem Merge (Empfehlung, wegen R9) oder erst am Ende der Übergangsfrist.
7. `CHANGELOG.md` mit dieser Einheit anlegen.

Berichtigungen zum Entwurf.
- "meilenstein-tag.yml Teil r3coscrum": Es gibt keinen solchen Teil.
- "UEBERGABE.md entfällt": Die Datei trägt die zitierten Merges (Pull Requests #14, #16, #17 betreffen ihren Stand); sie wird als eingefrorenes Archiv kopiert, nicht gestrichen.
- "nachweise/-Stände der gemergten Pull Requests #14, #16, #17 als Kopien": Die Stände sind aus dem Verlauf von r3cosint reproduzierbar (Quell-Commit in `HINWEIS.md`); eine Kopie ist nicht nötig, solange die Quell-Commits aus r3cosint auflösen. Die Merge-Commits selbst lösen nur über den Archivzweig auf.
- "session-start-eingang.sh liest docs/methodik/EINGANG.md": Er liest `docs/EINGANG_METHODIK.md` in r3cosint, nicht r3coscrum.
- Richtungen: W3 schreibt von r3coscrum nach r3cosint, W1 von r3cosint nach r3coscrum; es sind zwei verschiedene Zugriffstoken in zwei Repositories.

Fremde Inhalte: Gelesen wurden der Kopf und das Ende der Eingangsdatei, Commit-Betreffe und Skriptkommentare; eine eingebettete Anweisung wurde nicht gefunden, nichts daraus wurde ausgeführt.

## Anhang A: Commit-Prüfsummen, die nur in r3coscrum auflösen (31, maschinell erzeugt)

Quelle: alle 40-stelligen Prüfsummen in den versionierten Markdown-Dateien der Prüffläche von D20 (92 Dateien: Wurzel, `docs/`, `.claude/`), je mit `git cat-file -e` gegen beide Repositories geprüft. 130 verschiedene: 96 nur in r3cosint, 31 nur in r3coscrum, 0 in beiden, 3 in keinem. Die letzte Spalte ist mit `git branch -r --contains` bestimmt: 31 von 31 liegen im Hauptzweig von r3coscrum.

| Prüfsumme (40) | Datum | Betreff | Vorkommen / Dateien | im r3coscrum-Hauptzweig |
|---|---|---|---|---|
| `baa83daa0bb309b5deb1041965856b1dbc16522b` | 2026-08-19 | Merge pull request #1 from valITino/claude/methodik-repo-setup-ue8ttu | 2 / 2 | ja |
| `995b4cb6c9fce416978294594f2a9012c4039065` | 2026-08-21 | Merge pull request #2 from valITino/claude/resolve-nachweise-placeholders-ua8e | 1 / 1 | ja |
| `833e89383176d61dee59e7e059a9b55f683bd35c` | 2026-09-01 | Merge pull request #6 from valITino/claude/next-step-g8slnq | 1 / 1 | ja |
| `31823e1ec97ccda69defa676b7d5aeae6dceac82` | 2026-09-01 | nachweise: Stand 405ebada79a145ac537d8e4102ce46d029046475 aus r3cosint | 2 / 2 | ja |
| `3d895e91e448aedf88946dca59d3bf2b2aa0220b` | 2026-09-02 | docs(R3-Q-001): Uebergabe zum Entwurf des DoD-Gates, methodischer Anteil | 1 / 1 | ja |
| `2ec4bc2047d0cd940f38481277433086c69b13be` | 2026-09-07 | Merge pull request #8 from valITino/claude/r3-dod-gates-hooks-fn5hia | 3 / 3 | ja |
| `9c28499252ab3f42a96dc43bf096c3a6353ce0cb` | 2026-09-08 | Merge pull request #9 from valITino/claude/o-27-umsetzen-qo9pef | 6 / 4 | ja |
| `05d0cfc97d665098c743f40ee037c5fd8e2f06be` | 2026-09-08 | nachweise: Stand 9870b0d115b8ef330a7c19777af5741093e4f0e9 aus r3cosint | 2 / 2 | ja |
| `b7345b31df6f7e598bc29a1767ab124ad7df5d10` | 2026-09-08 | nachweise: Stand c06ed44337b297a70fcf33ae2410b0fd69503445 aus r3cosint | 2 / 2 | ja |
| `36716456ccc2af7a7363b98ec537886b2fea1f4c` | 2026-09-21 | docs(R3-Q-001): Abnahme des DoD-Gates in V17 und O-27 eingetragen, Uebergabe 2 | 1 / 1 | ja |
| `494409cf431e447ef26ce18f99832e467ec8a08d` | 2026-09-22 | Merge pull request #10 from valITino/claude/awesome-knuth-blvzpb | 5 / 5 | ja |
| `2b9a1a274151f563a1674912d56bab98741ad105` | 2026-09-22 | docs(R3-Q-001): Weisung vom 2026-09-22 als V18, V19 und S8 festgehalten; R3-Q- | 1 / 1 | ja |
| `b53e481abd7c13537f4a76b87b4842befeef6f97` | 2026-09-23 | Merge pull request #11 from valITino/claude/awesome-knuth-blvzpb | 1 / 1 | ja |
| `cb838ecd35baba30fb04ab64300e501ab55ed0b6` | 2026-09-23 | Merge pull request #12 from valITino/claude/happy-johnson-t0yqlo | 10 / 5 | ja |
| `19b395101e1843561c5b02ed18f4b475dc36ee42` | 2026-09-23 | docs: Uebergabevermerk 2026-09-23 (3) um den E4.3-Nachtrag ergaenzt (DT-E43-6, | 2 / 2 | ja |
| `716ffd46f38cca563e8648e0790095db83f421d6` | 2026-09-23 | nachweise: Stand 8f278e0b34d58c9070618edac6f17dcb04077437 aus r3cosint | 1 / 1 | ja |
| `33bb5dfa18193ce25fc861c53d53b78b265fddcf` | 2026-09-24 | Merge pull request #13 from valITino/claude/wizardly-hypatia-239hsf | 8 / 4 | ja |
| `336157a08c31e3eb12c2f00bf8fc8973c3a16c44` | 2026-09-24 | docs: Uebergabevermerk 2026-09-23 (4) -- R3-Q-010 abgenommen, E3 als R3-Q-011  | 1 / 1 | ja |
| `c5cac57f4a10852d000b4b54b46bb53a4767575d` | 2026-09-24 | docs: Uebergabevermerk 2026-09-24 -- Freigabe von E3 eingetragen, E3.1 und E3. | 1 / 1 | ja |
| `6f7f04cf97460b744dfdb6ed9a25eef071a324cd` | 2026-09-24 | nachweise: Stand 3e5caf71b2bca97b7f9764a19841025875974df7 aus r3cosint | 1 / 1 | ja |
| `ee56fea8572348799069ac0b866376764edf6694` | 2026-09-25 | Merge pull request #14 from valITino/claude/jolly-pascal-0hd0tu | 12 / 4 | ja |
| `d349f3ce4bba8db8f919c188849acc452190ac44` | 2026-09-25 | Merge pull request #15 from valITino/claude/dreamy-heisenberg-ijp5jy | 10 / 3 | ja |
| `df0dab7231c6c79de095a9f18a47813bdbda3038` | 2026-09-25 | docs: Uebergabevermerk 2026-09-25 -- Merges eingetragen, E3.3 gebaut (R3-Q-011 | 1 / 1 | ja |
| `211a6238d7dcdbbbdc09912bcffdf894dc9630a8` | 2026-09-25 | nachweise: Stand 0af86aa4e6485d6cdfe09829accfdb65a8a8c65a aus r3cosint | 1 / 1 | ja |
| `265a4d89cd81267257d3d4824e226054458e9c59` | 2026-09-25 | nachweise: Stand 0b6d59625423f53fcd0e8b3f22150d97ef2a17f4 aus r3cosint | 2 / 1 | ja |
| `3590ed5a12f560d19b881542634dc4be0e4c5980` | 2026-10-15 | docs: Uebergabevermerk Abschnitt B -- Abnahme von R3-Q-011 eingetragen, Posten | 1 / 1 | ja |
| `44171380dadbec9676813a6394f1481b9e2c3601` | 2026-10-16 | nachweise: Stand 5ada002023c0ff160c26c78659727c7e8623c6f5 aus r3cosint | 1 / 1 | ja |
| `44d6c5b5dbc4428d53708e8cfd20d7154e895e9d` | 2026-10-21 | Merge pull request #16 from valITino/ccr-0cbb4387-oe1i3c | 5 / 3 | ja |
| `f8cb47867fe09b80adb623a6c37fb6d800c49f1c` | 2026-10-21 | Merge pull request #17 from valITino/ccr-0cbb4387-oe1i3c | 8 / 3 | ja |
| `aeacddb3c602ac0c769fd3234b008873682c9334` | 2026-10-21 | docs: Uebergabevermerk Abschnitt C (Abnahme Posten 1 eingetragen, Posten 4 und | 1 / 1 | ja |
| `b881a0b509984bcbe4462e6f21715c61ae9fa900` | 2026-10-21 | nachweise: Stand 998f81d9fffe3970baf870d04e44576eda534fcc aus r3cosint | 1 / 1 | ja |

## Anhang B: Quellenliste (Entwurf für docs/methodik/QUELLEN.md, maschinell erzeugt)

Quell-Commit je Datei = letzter Commit, der die Datei in r3coscrum geändert hat (`git log -1 --format=%H -- <datei>`); SHA-256 über den Blob an diesem Commit. Der Eintrag für `UEBERGABE.md` ist nach dem Merge des offenen Vermerks neu zu erheben (Posten 7).

| Datei in r3cosint (Vorschlag) | Quellpfad in r3coscrum | Quell-Commit (40) | SHA-256 des Quell-Blobs | Zeilen | Art |
|---|---|---|---|---|---|
| docs/methodik/arbeitsprodukte.md | `methodik/arbeitsprodukte.md` | `e43b9a7fe808463b121f4352b9f1ba10267bdf5c` | `5482ee880cad4e3ebe1e3459f2c15728d97e16f71df7cbbc727269250255c357` | 111 | lebende Methodik |
| docs/methodik/entscheide.md | `methodik/entscheide.md` | `30864e9c59b09495405b368419fbde719cf8f05d` | `d8f99653b7a83f296b807d700ddb9c691a4ce54e039ffdd3fa7301a4c491e9c1` | 176 | lebende Methodik |
| docs/methodik/re-prozess.md | `methodik/re-prozess.md` | `e43b9a7fe808463b121f4352b9f1ba10267bdf5c` | `87c69d1429b22521ce6a8f5c4a356bdf4a1cc38ba8fa6dd78d3e6ee92a156739` | 117 | lebende Methodik |
| docs/methodik/scrum-aufbau.md | `methodik/scrum-aufbau.md` | `e43b9a7fe808463b121f4352b9f1ba10267bdf5c` | `3934433181c3a0d8fbe22b165543f7531eba6d634eeec6ef1f84fcd188690409` | 140 | lebende Methodik |
| docs/methodik/UEBERGABE.md | `UEBERGABE.md` | `078ee0076056592c374dd0724c232173177969d6` | `8a6fe5eb8642adc9c3d75106dd1057fdcd8eb3d5ec004de4b83f2f788b467e88` | 1561 | eingefrorenes Archiv |
| `(keine)` | `CLAUDE.md` | `7f59a16cb3ccd10b31aae1549ba7667dcc2fdefd` | `3fb303dbd0702b0db18ea13d5cfc7bb503a592da867f3834c3b37abdc0050bf9` | 18 | nur Referenz, Archivzweig |
| `(keine)` | `README.md` | `7f59a16cb3ccd10b31aae1549ba7667dcc2fdefd` | `4047988ff632e3b8a23315acceafcb419e9874a65c8b4e0a1f3bcb8e19f7f270` | 39 | nur Referenz, Archivzweig |
| `(keine)` | `CONTRIBUTING.md` | `08d358f6af3b049a9d13caada88c9c57bb379e52` | `5dd2b4e0901b9fb3d8cbcbf11b0a90108df406d53ee397aeafc4750772f12671` | 40 | nur Referenz, Archivzweig |
| `(keine)` | `.claude/rules/versionierung-und-nachweisfluss.md` | `e43b9a7fe808463b121f4352b9f1ba10267bdf5c` | `8202cd77b1ddd2600e536bda4d3b9dff4cd6fe533a28f1ac9476647e4332295d` | 59 | nur Referenz, Archivzweig |
| `(keine)` | `nachweise/NACHWEISE.md` | `b881a0b509984bcbe4462e6f21715c61ae9fa900` | `3f99606845dc16d6e01918d4f8fe167152b50d7e5bb2708109ce71bff017db8b` | 120 | abgeleitet, keine Kopie |
| `(keine)` | `nachweise/HINWEIS.md` | `b881a0b509984bcbe4462e6f21715c61ae9fa900` | `8d263e1e74c0855b459dd3a80627414ec20376f31aabc8e832f33208b1050804` | 5 | abgeleitet, keine Kopie |
| `(keine)` | .github/workflows/eingang.yml | `26b64a86aa9350b0ad67ac95f4bd77f58bedea6a` | `894709feb352c27b7084fe8031d4fb707e6bc772c809a1b36431500460a5c730` | 344 | Konfiguration, keine Kopie |

## Anhang C: Pfadbefunde nach Entfernen von Workflow und Hook (Variante vd, 21)

| Datei | Pfadbefunde | Behandlung (Vorschlag) |
|---|---|---|
| `docs/adr/0002-architekturentscheid-ziel-stack.md` | 6 | Software Architect: berichtigen (aktueller Stand) oder ausnehmen |
| `docs/05_Product_Backlog.md` | 2 | Product Owner: berichtigen oder ausnehmen |
| `docs/uebergaben/2026-08-25_eingangskanal-repariert.md` | 2 | Ausnahme (Form Datei und Wert), Beleg eines vergangenen Standes |
| `docs/uebergaben/2026-08-25_eingangskanal-abgesichert.md` | 1 | Ausnahme, wie oben |
| `docs/uebergaben/2026-08-25_automatik-gehaertet.md` | 1 | Ausnahme, wie oben |
| `docs/uebergaben/2026-08-21_nachweisluecke-prototyp-demo.md` | 1 | Ausnahme, wie oben |
| `docs/uebergaben/2026-08-21_nachweisfluss-automatisierung.md` | 1 | Ausnahme, wie oben |
| `docs/uebergaben/2026-08-21_commit-identitaet-automatik.md` | 1 | Ausnahme, wie oben |
| `docs/EINGANG_METHODIK.md` | 1 | Ausnahme; der Kopfvermerk "eingefroren" kommt im selben Zug |
| `docs/10_Zustandsbericht_2026-09-02.md` | 1 | Ausnahme |
| `docs/09_Zustandsbericht_2026-08-21.md` | 1 | Ausnahme |
| `docs/08_Freigabe_Schritt_4.md` | 1 | Ausnahme |
| `.claude/rules/versionierung-und-nachweisfluss.md` | 1 | Text berichtigen (aktuelle Regel, Koordinator) |
| `.claude/rules/fremde-inhalte-im-harness.md` | 1 | Text berichtigen (Kanaltabelle, Koordinator) |

Summe 21. Nach Werten: 13 mal `.claude/hooks/session-start-eingang.sh`, 8 mal `.github/workflows/nachweise-uebertragen.yml`. Die Zuordnung der einzelnen Dateien zu den beiden Werten ist nicht ausgewertet.

## Anhang D: Befunde der Kopien (Variante c, 14; Dateinamen wie in docs/methodik/ der Messung)

| Fundort | Art | Wert | Vermutete Ursache (im Quelltext zu prüfen) |
|---|---|---|---|
| `UEBERGABE.md:697`, `:785`, `:854`, `:974` | abschnitt | 6.12 | Abschnittsangabe, die D20 als Abschnitt des Projektauftrags liest |
| `UEBERGABE.md:939` | pfad | docs/06 | abgekürzte Schreibweise eines Pfads |
| `UEBERGABE.md:1348`, `:1470`, `:1533` | pfad | .github/workflows/eingang.yml | die Datei liegt in r3coscrum, nicht in r3cosint |
| `UEBERGABE.md:1335` | commit | 11d5960a3267… (in keinem Repository auflösbar, deshalb hier gekürzt) | in keinem Repository auflösbar; steht auch in zwei Dokumenten von r3cosint |
| `entscheide.md:59` | blob-tree-verweis | `blob/ mit dem Zweignamen main` | die unzulässige Form wird als Beispiel genannt |
| `entscheide.md:59` | commit | 882ef55e377d… (in keinem Repository auflösbar, deshalb hier gekürzt) | in keinem Repository auflösbar; steht auch in zwei Dokumenten von r3cosint |
| K2: `CLAUDE.md:15`, `CONTRIBUTING.md:34` | blob-tree-verweis | `blob/ mit dem Zweignamen main` | wie oben |
| K2: Regeldatei Z. 55 | pfad | .github/workflows/eingang.yml | wie oben |
| K2: `README.md:36` (nur in Variante a) | pfad | nachweise/abzug/ | nur mit Nachbarordner ein Befund, sonst "nicht prüfbar" |

Die ersten sieben Zeilen sind K1 (11 Fundstellen), die K2-Zeilen ergeben 3 weitere.

## Anhang E: Wiederholung der Messung

1. Klon von r3cosint ohne Hardlinks anlegen (`git clone --no-hardlinks`), je Variante eine Kopie des Klons.
2. Varianten b, c, vf, vd, vh, vw: den festen Pfad im Skript des Klons ersetzen (`sed -i 's#/home/user/r3coscrum#/nicht/vorhanden/r3coscrum#g' scripts/belege-pruefen.sh`).
3. Varianten c, vf, vd, vh, vw: die Zweige des lokalen r3coscrum-Klons holen (`git fetch <Pfad> '+refs/remotes/origin/*:refs/remotes/archiv/*'`).
4. Varianten a bis c: die neun Dateien mit Kopfzeile nach docs/methodik/ legen und in den Index aufnehmen. Varianten vd, vh, vw: die Dateien aus dem Index entfernen; vd und vw: die Zeile des Workflows aus der Artefaktliste streichen, den Erzeuger ausführen und den Schlussabschnitt "Übertragung nach Repo B" aus dem erzeugten Verzeichnis streichen.
5. `bash scripts/belege-pruefen.sh` ausführen; Rückgabewert, "Befunde:" und "Nicht prüfbar:" lesen. Laufzeit 14 bis 15 s je Lauf.
