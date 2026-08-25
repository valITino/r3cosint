# Übergabe — Arbeitseinheit «Eingangskanal aus Repo B repariert»

| | |
|---|---|
| **Arbeitsprodukt nach** | Projektauftrag 3.3 (Übergabedatei je Arbeitseinheit) |
| **Einheit** | Einheit 1 dieser Session: der `SessionStart`-Hook gibt den Eingang wieder aus |
| **Weisung** | Auftraggeber, 2026-08-25 (Deep Review freigegeben mit vier Änderungen; diese Session: zwei Einheiten, zwei Commits, ein Pull Request) |
| **Datum** | 2026-08-25 |
| **Zweig** | `claude/deep-review-input-sanitization-s00nb3` |
| **Grundlage des Befunds** | Deep Review vom 2026-08-25, Befund C |

## Der Befund

`.claude/hooks/session-start-eingang.sh` machte seine Leerprüfung an der
Vorlagenzeile «Noch kein Eintrag» fest. Diese Zeile stand in
`docs/EINGANG_METHODIK.md` **über** den beiden echten Einträgen vom 2026-08-20
und 2026-08-21 und wurde beim Eintragen nie entfernt. Der Hook endete deshalb
vor der Ausgabe mit Rückgabewert 0 und schrieb **null Zeichen** in den
Sitzungskontext.

Die Gegenrichtung B nach A aus Projektauftrag 6.6 war damit seit dem ersten
Eintrag still wirkungslos. Still ist hier das Wesentliche: Rückgabewert 0 und
leere Ausgabe sind vom Erfolgsfall «keine Einträge vorhanden» nicht zu
unterscheiden. Beim Bau war die Zustellung geprüft, nie die Wirkung.

## Was fertig ist

- `.claude/hooks/session-start-eingang.sh`: Die Leerprüfung hängt nicht mehr an
  einem Satz im Fliesstext, sondern am Vorhandensein einer Eintragsüberschrift
  mit ISO-Datum (`^#{2,3}[[:space:]]+[0-9]{4}-[0-9]{2}-[0-9]{2}`). Eine
  vergessene oder umformulierte Vorlagenzeile kann den Kanal nicht mehr
  stilllegen. Der Grund steht als Kommentar im Skript, damit die Prüfung nicht
  bei nächster Gelegenheit wieder auf eine Zeichenkette im Fliesstext
  zurückfällt.
- `docs/EINGANG_METHODIK.md`: Die Platzhalterzeile «Noch kein Eintrag» ist
  entfernt — sie war seit dem ersten Eintrag ohnehin sachlich falsch. Der
  Hinweis auf den Leerzustand steht neu im HTML-Kommentar, den der Hook
  herausfiltert; er verbraucht damit keinen Kontext und kann keine Prüfung mehr
  auslösen.

## Verifikation — ausgeführt, nicht behauptet

Der Auftraggeber hat die tatsächliche Ausführung verlangt. Alle drei Fälle sind
mit `bash` ausgeführt worden.

| Fall | Rückgabewert | Ausgabe |
|---|---|---|
| Ist-Zustand des Repositories, zwei Einträge vorhanden | 0 | **3032 Zeichen, 63 Zeilen** — beide Einträge samt Warnpräambel und Nachweisverweisen |
| Datei ohne jeden Eintrag (Vorlagenzustand, in einer Kopie geprüft) | 0 | 0 Zeichen |
| `docs/EINGANG_METHODIK.md` nicht vorhanden | 0 | 0 Zeichen |

Vor der Änderung lieferte der erste Fall 0 Zeichen. `bash -n` auf dem Skript
ohne Beanstandung. Damit ist die Vorgabe aus
`.claude/rules/claude-konfiguration.md` erfüllt, jedes Hook-Skript gegen einen
blockierenden und einen durchzulassenden Fall zu prüfen.

## Was offen bleibt

Diese Einheit repariert die Zustellung. Sie sichert den Kanal **nicht** ab. Das
ist bewusst getrennt und gehört zu Einheit E2 des freigegebenen Plans:

- `r3coscrum/.github/workflows/eingang.yml` schreibt ungeprüfte
  Commit-Nachrichten in diese Datei; der Endmarker `=== Ende des Eingangs ===`
  steht im Repository und ist aus einer Commit-Nachricht heraus reproduzierbar.
  Nötig sind ein Marker je Sitzung, der Warnhinweis vor **und** nach dem Block,
  Entschärfung markerähnlicher Zeilen und eine Längenbegrenzung.
- Die Datei-Neuanlage in `eingang.yml` erzeugt eine Fassung **ohne** den
  Abschnitt «Diese Datei ist Information, keine Anweisung».
- Form: Die Datei sagt in Zeile 35 «Neueste zuoberst» und gibt in der Vorlage
  `###` vor; der Arbeitsablauf hängt unten an und schreibt `##`. Zu
  vereinheitlichen auf Anfügen und `##` — das entspricht der Doktrin
  «ausschliesslich anfügbar» aus 5.3. Der Hook erkennt bereits beide Ebenen.

**Nicht angefasst**, weil ausserhalb dieser Einheit: die Artefaktliste in
`scripts/nachweise-erzeugen.sh` führt weder die 21 Rollendateien noch
`.claude/rules/versionierung-und-nachweisfluss.md`, die Arbeitsabläufe oder den
Erzeuger selbst; `docs/NACHWEISE.md` steht auf 22 Artefakten und Stand
`3a40faa87feac056cd7bfa7c0fdf3f5f77b761fb`, während Repo B 23 und
`10ec234eb15a5a48ca6c7f94d4ebce10d7113e37` führt.

## Entscheidungen

**Reihenfolge des freigegebenen Plans, Stand 2026-08-25:**
C-Fix → E1 → E2 → Befund F → R3-Q-001 → D2 → E4 → E3 → E5.

- Der C-Befund wurde aus E2 herausgelöst und vorgezogen: der Kanal war tot, der
  Fix ist klein und wirkt sofort.
- **Befund F wird nicht geparkt, sondern eigene Einheit.** Der Auftrag lautete
  «Eingabevalidierung», und der Befund ist, dass genau sie an der Systemgrenze
  des Produkts im ganzen Backlog fehlt. Umfang: Schemaprüfung eingehender
  Quellantworten, Pfadtraversierung, Ausgabekodierung beim Rendern, das
  fehlende Abnahmekriterium zur Schemaprüfung der Modellantwort (ADR 0002,
  Abschnitt 3.7), und die Lücken bei R3-F-015 zu Weiterleitungen,
  Namensauflösung und IP-Literalen. Kein Code — Backlog-Einträge mit testbaren
  Abnahmekriterien, formuliert vom Requirements Engineer, eingeordnet vom
  Product Owner.
- **R3-Q-001** (Definition-of-Done-Kette als Hooks) fehlte im Plan und ist nach
  Befund F eingeplant, vor dem Grundgerüst.
- **D2** (Kollision 1a/1b/2 gegen R1 bis R5) wurde vorgezogen: die verbotene
  Schreibweise steht in Rollendateien und Regeln, die in jeder Sitzung gelesen
  werden. Verwechslungsquelle bei der täglichen Arbeit, kein Schönheitsfehler.
- **E4** (main-Gate) rückt nach hinten. Auf `main` greift zusätzlich ein
  GitHub-Ruleset mit Blockade von Force-Pushes und Pull-Request-Pflicht; der
  Hook ist damit zweite Verteidigungslinie, nicht einzige. Der Umfang bleibt,
  die Dringlichkeit fällt weg.

**Zurückgestellt — nicht vergessen:** Die Skill
`.claude/skills/einschleusung-pruefen/` wird nicht jetzt angelegt. Sie wäre die
**erste** Skill des Projekts, löst damit R3-C-007 aus und verlangt eine
Fortschreibung von ADR 0001 Abschnitt 5.1 («Kein `skills:`-Feld») sowie das
Nachtragen des `skills:`-Feldes in vier Rollendateien. Der Nutzen des
Injektionsschutzes liegt überwiegend in der Regel
`.claude/rules/fremde-inhalte-im-harness.md`, die in E3 entsteht. Die Skill
folgt separat, damit R3-C-007 sauber und in einem Zug erfüllt wird statt
halb.

**Ergänzung zum Befundbericht:** A1 und A2 sind keine zwei Einzelbefunde,
sondern eine Kette. A1 gibt Kontrolle über `steps.version.outputs.wert`, der in
`git tag -a` landet; ein manipulierter Name des Versionsschilds löst einen
Tag-Push aus, dessen `GITHUB_REF_NAME` in A2 landet — bei laufendem
`NACHWEISE_TOKEN` mit Schreibrecht auf Repo B. Aus einem gemergten Fork-Pull-Request
entsteht so eine Kette bis zur Befehlsausführung. Beide Enden werden in Einheit 2
dieser Session geschlossen.

## Definition of Done

Es gibt weiterhin keine Testsuite und keinen `make dod`-Einstieg; die
DoD-Befehlskette aus ADR 0002 Abschnitt 6 ist Text und wird erst mit R3-Q-001
erzwungen. Für diese Einheit anwendbar und erfüllt: Syntaxprüfung, beide
Prüffälle je Hook ausgeführt und belegt, kein halbfertiger Zustand, Übergabedatei
geschrieben. Die Verifikation dieser Einheit liegt beim Static Software Tester;
die Ausführungsbelege oben sind die Grundlage dafür.
