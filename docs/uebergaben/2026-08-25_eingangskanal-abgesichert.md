# Übergabe — Arbeitseinheit «Eingangskanal abgesichert»

| | |
|---|---|
| **Arbeitsprodukt nach** | Projektauftrag 3.3 (Übergabedatei je Arbeitseinheit) |
| **Einheit** | E2 des freigegebenen Plans, Anteil Repo A |
| **Weisung** | Auftraggeber, 2026-08-25 («Starte mit dem, was wirklich zuerst erledigt werden muss») |
| **Datum** | 2026-08-25 |
| **Zweig** | `claude/next-step-g8slnq` |
| **Grundlage** | Reihenfolge des freigegebenen Plans, `docs/uebergaben/2026-08-25_eingangskanal-repariert.md` |

Die vorige Einheit hat die **Zustellung** des Kanals Repo B nach Repo A
repariert. Diese sichert ihn **ab**. Der zweite Anteil von E2 liegt in
`valITino/r3coscrum` und ist dort in `UEBERGABE.md` vermerkt.

## Was fertig ist

### `.claude/hooks/session-start-eingang.sh`

Der Hook trägt Text aus Repo B in den Sitzungskontext. Dieser Text stammt aus
Commit-Nachrichten und Dateinamen und ist ungeprüft — fremder Inhalt nach
Verfahrensgarantie 5.4. Vier Massnahmen, jede gegen eine eigene Gefahr:

| # | Massnahme | Wogegen |
|---|---|---|
| 1 | **Kennung je Sitzung in beiden Markern** (16 Stellen aus `/dev/urandom`) | Ein fester Endmarker steht im Repository und ist damit bekannt. Wer ihn nachbildet, täuscht vor, der fremde Teil sei zu Ende — der Rest seines Textes stünde scheinbar ausserhalb der Einfassung |
| 2 | **Warnhinweis vor und nach dem Block** | Ein Hinweis nur davor ist bei wachsendem Eingang irgendwann weit weg vom Ende des fremden Textes |
| 3 | **Entschärfung**: Folgen von drei oder mehr `=` werden zu `= = =`, Steuerzeichen fallen weg (Tabulator und Zeilenumbruch bleiben) | Nachgebildete Markerzeilen; Text, der Bildschirmsteuerung mitbringt und sich damit als etwas anderes ausgibt |
| 4 | **Obergrenzen** 400 Zeilen und 20 000 Zeichen für den Eintragsblock, zusätzlich 500 Zeichen je Zeile; gekürzt wird vorne, die jüngste Zeile bleibt immer | Der Eingang wächst unbegrenzt und niemand bemerkt, wie viel Kontext er belegt. Eine einzige sehr lange Zeile könnte das Budget allein aufbrauchen |

Zwei weitere Änderungen, die beim Bauen nötig wurden:

- **Rückfall auf die erste Eintragsüberschrift**, wenn `## Einträge` fehlt.
  Bisher schnitt der Hook ausschliesslich an dieser Überschrift. Fehlte sie,
  endete er mit Rückgabewert 0 und null Zeichen — dieselbe Fehlerklasse, die
  den Kanal bis zum 2026-08-25 unbemerkt stillgelegt hatte, nur über einen
  anderen Weg. Kein einzelner Satz und keine einzelne Überschrift in dieser
  Datei darf den Kanal stilllegen können.
- **Nur die Einträge stehen in der Einfassung.** Der Hook gab bisher den
  ganzen Abschnitt ab `## Einträge` aus, einschliesslich des erklärenden
  Textes dieses Repositories. Eigener und fremder Text in derselben Einfassung
  sagt über beide nichts mehr aus. Nebeneffekt: der erklärende Text kann
  wachsen, ohne Kontext zu kosten.

### `docs/EINGANG_METHODIK.md`

- Zeile 35 sagte «Neueste zuoberst», während der Arbeitsablauf in Repo B unten
  anhängt. Die Vorgabe folgt jetzt dem, was tatsächlich geschieht: **angefügt,
  der jüngste Eintrag zuunterst**, entsprechend der Doktrin «ausschliesslich
  anfügbar» aus 5.3.
- Die Vorlage gab `###` vor, der Arbeitsablauf schreibt `##`. Vereinheitlicht
  auf `##`.
- Im Kommentar steht neu, dass die Überschrift `## Einträge` tragend ist: Hook
  und Arbeitsablauf hängen an ihr. Damit sie nicht bei nächster Gelegenheit
  umbenannt wird.

## Verifikation — ausgeführt, nicht behauptet

`bash -n` ohne Beanstandung. Alle Fälle mit `bash` ausgeführt, gegen eine Kopie
des Repositoriums in einer Wegwerf-Umgebung.

| Fall | Rückgabewert | Ausgabe |
|---|---|---|
| Ist-Zustand, zwei Einträge | 0 | 3983 Zeichen, 76 Zeilen |
| Vorlagenzustand ohne jeden Eintrag | 0 | 0 Zeichen |
| Datei nicht vorhanden | 0 | 0 Zeichen |
| Überschrift `## Einträge` fehlt, Eintrag vorhanden | 0 | 3983 Zeichen — Rückfall greift; **die alte Fassung lieferte hier 0 Zeichen** |
| Eintrag mit nachgebildeter Markerzeile, Anweisungstext und Steuerzeichen | 0 | genau zwei Zeilen beginnen mit `===`, beide mit der Sitzungskennung |
| 2000 eingeschleuste Zeilen (Zeichenbudget) | 0 | Block auf 276 Zeilen und 19 914 Zeichen gekürzt, Kürzung ausgewiesen, jüngste Zeilen erhalten |
| 900 kurze Zeilen (Zeilenbudget) | 0 | Block auf genau 400 Zeilen gekürzt, Kürzungsmeldung eingerechnet |
| eine einzige Zeile mit 25 000 Zeichen | 0 | Zeile auf 500 Zeichen gekappt, Block bleibt vorhanden |
| leere Eingabe, genau eine Zeile, Datei ohne abschliessenden Zeilenumbruch | 0 | je korrekt, keine Ausnahme |
| 20 Läufe hintereinander | 0 | 20 verschiedene Kennungen |
| Steuerzeichen über alle Fälle zusammen | — | 0 (Tabulator und Zeilenumbruch ausgenommen) |

Die vorgeschriebene Prüfung jedes Hook-Skripts gegen einen blockierenden und
einen durchlassenden Fall (`.claude/rules/claude-konfiguration.md`) ist damit
erfüllt: durchlassend sind die Fälle mit Ausgabe, blockierend im Sinne dieses
Hooks die Fälle ohne Ausgabe. Rückgabewert 2 kommt nicht vor und darf nicht
vorkommen — dieser Hook darf eine Sitzung unter keinen Umständen verhindern.

### Ganze Kette, mit dem Arbeitsablauf aus Repo B

Ein Repo B mit bösartigen Commit-Nachrichten wurde angelegt, der Arbeitsablauf
in beiden Fassungen darüber ausgeführt und das Ergebnis durch den jeweiligen
Hook geschickt.

| | alte Fassung | neue Fassung |
|---|---|---|
| Steuerzeichen in der Hook-Ausgabe | 3 | 0 |
| längste Zeile | 904 Zeichen | 517 Zeichen |
| Zeilenzahl je Eintrag | unbegrenzt | 60 plus Kürzungsvermerk |
| Zieldatei fehlt in Repo A | Lauf grün, verkürzte Datei angelegt, **Hook gibt 0 Zeichen aus** | Lauf bricht mit Rückgabewert 1 ab |

## Korrekturen an eigenen Annahmen

Beim Belegen sind fünf Dinge aufgefallen, die anders liegen als angenommen —
eines am Befundbericht, vier an der eigenen Umsetzung. Der Reihe nach:

1. **Ein nachgebildeter Marker am Zeilenanfang war unter der alten Fassung
   nicht erreichbar.** Der Plan hielt fest, der Endmarker sei «aus einer
   Commit-Nachricht heraus reproduzierbar». Das stimmt für den Wortlaut, nicht
   für die Wirkung: Der Arbeitsablauf stellt jeder Zeile einer Commit-Nachricht
   `> ` voran, Dateinamen erscheinen hinter `- Neu: `. Ein Dateiname mit
   Zeilenumbruch wäre der verbleibende Weg — geprüft am 2026-08-25: Git quotet
   solche Pfade auch bei `core.quotepath=false`
   (`A\t"methodik/harmlos\n=== Ende des Eingangs ===\nboese.md"`, eine Zeile).
   **Die alte Absicherung war also vorhanden, aber unbeabsichtigt**: sie ist ein
   Nebenprodukt der Lesbarkeitsformatierung, nirgends als Schutz beschrieben und
   von jeder künftigen Änderung am Arbeitsablauf ersatzlos entfernbar. Die
   Kennung je Sitzung ersetzt einen Zufallstreffer durch eine Eigenschaft.
   Was blieb, war real: Steuerzeichen und unbegrenzte Länge gingen ungehindert
   durch.
2. **Die erste Fassung dieser Einheit fasste eigenen Text mit ein.** Der Block
   begann bei `## Einträge` und enthielt damit den erklärenden Text dieses
   Repositories innerhalb der Einfassung für fremden Inhalt. Korrigiert, bevor
   weitergeprüft wurde.
3. **Die Zeichengrenze wurde um die eigene Kürzungsmeldung überschritten**
   (20 058 statt 20 000). Eine Grenze, die um die eigene Meldung überschritten
   wird, ist keine. Der Schnitt läuft jetzt zweimal, das zweite Mal gegen ein um
   eine Reserve vermindertes Budget.
4. **Dieselbe Sache bei der Zeilengrenze**: 401 statt 400. Beim Nachmessen der
   Randfälle aufgefallen, nachdem der Zeichenfall bereits behoben war. Der
   zweite Schnitt vermindert jetzt beide Budgets.
5. **Eine einzige Zeile über dem Budget liess den ganzen Block verschwinden.**
   Der Schnitt von hinten verwarf auch die jüngste Zeile, übrig blieb allein die
   Kürzungsmeldung. Ausgeführt am 2026-08-25: eine Zeile mit 25 000 Zeichen
   ergab 42 Zeichen Ausgabe, nämlich nur die Meldung. Das ist **wieder dieselbe
   Fehlerklasse** — Rückgabewert 0, alles sieht grün aus, der Kanal liefert
   nichts. Über den Arbeitsablauf in Repo B war der Fall nach dessen neuer
   Zeilenkappung nicht mehr erreichbar; dieser Hook ist aber die letzte Schranke
   vor dem Sitzungskontext und darf sich nicht darauf verlassen, wer die Datei
   geschrieben hat. Behoben durch eine Kappung je Zeile bei 500 Zeichen und die
   Zusicherung, dass die jüngste Zeile immer bleibt.

Die Punkte 2 bis 5 sind Mängel der eigenen Umsetzung, im eigenen Durchgang
gefunden und vor der unabhängigen Prüfung behoben. Dass dreimal dieselbe
Fehlerklasse auftrat — grüner Rückgabewert bei leerer Wirkung — ist der
eigentliche Befund dieser Einheit: **dieser Kanal versagt vorzugsweise
lautlos.** Jede künftige Änderung an ihm braucht einen Prüffall, der die
Wirkung misst und nicht den Rückgabewert.

## Was offen bleibt

- **`actions/checkout@v4` bleibt auf ein bewegliches Versionsschild gepinnt**,
  an fünf Stellen in beiden Repositories. Unverändert seit der letzten Einheit:
  zum Pinnen wird die Prüfsumme aus `actions/checkout` gebraucht, der
  GitHub-Zugang der Sitzung ist auf `valITino/*` beschränkt.
- **Kein echter Lauf auf GitHub.** Die Nachweise oben beruhen auf einer
  vollständigen Nachbildung — echtes Git, echte Arbeitsablauf-Schritte aus der
  YAML-Datei, lokales Fernarchiv, `gh` als Attrappe. Der erste echte Lauf ist
  zu beobachten, insbesondere die beiden Abbruchpfade.
- **Trailer in den Commit-Nachrichten** (`Co-Authored-By:`, `Claude-Session:`)
  wandern weiterhin in den Eingang. Sie sind kein Sicherheitsproblem, aber
  Rauschen. Ob sie herausfallen sollen, ist eine redaktionelle Entscheidung und
  gehört nicht in eine Absicherungseinheit.
- **Die Artefaktliste ist weiterhin nicht nachgeführt** — `scripts/**` und
  `.github/**` fehlen im `paths`-Auslöser, der Nachweisfluss löst bei einer
  Änderung an genau diesen Dateien nicht aus. Gehört zu E5.

## Nachweisfluss

Beide geänderten Dateien sind bereits als Artefakt in
`scripts/nachweise-erzeugen.sh` geführt («Hook Eingang Methodik», «Eingang
Methodik»), und der `paths`-Auslöser von `nachweise-uebertragen.yml` deckt
`.claude/**` und `docs/**` ab. Der Nachweisfluss nach 6.6 greift für diese
Einheit also ohne Zutun, sobald sie auf dem Hauptzweig ist.

## Reihenfolge des Plans, Stand nach dieser Einheit

C-Fix ✓ → E1 ✓ → **E2 ✓** → Befund F → R3-Q-001 → D2 → E4 → E3 → E5.

Als Nächstes **Befund F**: die fehlende Eingabevalidierung an der Systemgrenze
des Produkts. Kein Code — Backlog-Einträge mit testbaren Abnahmekriterien,
formuliert vom Requirements Engineer, eingeordnet vom Product Owner.

## Definition of Done

Es gibt weiterhin keine Testsuite und keinen `make dod`-Einstieg; die
DoD-Befehlskette aus ADR 0002 Abschnitt 6 ist Text und wird erst mit R3-Q-001
erzwungen. Für diese Einheit anwendbar und erfüllt: Syntaxprüfung, alle
Prüffälle je Skript ausgeführt und belegt, Wirkungsnachweis alt gegen neu auf
identischer Eingabe, kein halbfertiger Zustand, Übergabedatei geschrieben. Die
Verifikation liegt beim Static Software Tester und ist auf einem anderen Modell
als die Umsetzung gelaufen (3.4).
