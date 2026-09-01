# Übergabe — Arbeitseinheit «Automatik gegen Einschleusung gehärtet»

| | |
|---|---|
| **Arbeitsprodukt nach** | Projektauftrag 3.3 (Übergabedatei je Arbeitseinheit) |
| **Einheit** | Einheit 2 dieser Session: E1 des freigegebenen Plans |
| **Weisung** | Auftraggeber, 2026-08-25 (E1 als zusammenhängende Kette behandeln, nicht als zwei Einzelbefunde) |
| **Datum** | 2026-08-25 |
| **Zweig** | `claude/deep-review-input-sanitization-s00nb3` |
| **Grundlage des Befunds** | Deep Review vom 2026-08-25, Befunde A1, A2 und F |

## Was fertig ist

### `.github/workflows/meilenstein-tag.yml`

- **Die Commit-Betreffzeilen gehen nicht mehr durch `$GITHUB_OUTPUT`.** Sie
  liegen in `"$RUNNER_TEMP/betreffs.txt"` und werden vom Release-Schritt von
  dort gelesen. Der Ausgabewert `betreffs` samt festem Trenner `ENDE_BETREFFS`
  ist ersatzlos entfallen. Damit ist nicht der Trenner verbessert, sondern die
  Fehlerklasse entfernt.
- **Alle Einsetzungen aus den `run:`-Blöcken herausgenommen.** `VERSION`,
  `PR_NUMMER` und `MERGE_SHA` kommen über `env:` herein und werden als
  `"$VARIABLE"` benutzt. Eine Einsetzung von `${{ ... }}` unmittelbar im
  `run:`-Block ist eine Textersetzung **vor** der Ausführung; der Wert wird
  dort zu Code, nicht zu einem Argument.
- **Formprüfung des letzten Versionsschilds** vor der arithmetischen
  Weiterverarbeitung. Abbruch mit Meldung statt einer unsinnigen Version.
- `/tmp/release-notizen.md` durch `"$RUNNER_TEMP/release-notizen.md"` ersetzt.

### `.github/workflows/nachweise-uebertragen.yml`

- **`inputs.schild` kommt über `env:` herein** und wird gegen die erwartete
  Form geprüft, bevor der Wert weitergereicht wird: ein Versionsschild
  `vMAJOR.MINOR.PATCH` oder eine 40-stellige Prüfsumme. Dasselbe gilt für
  `GITHUB_REF_NAME` beim Tag-Auslöser.
- **Die vier verbleibenden Einsetzungen in `run:`-Blöcken** (Zeilen 164, 188,
  210, 235 der alten Fassung) laufen über `env: BEZUG` beziehungsweise
  `env: ABZUG`. Betroffen war unter anderem
  `git commit -m "nachweise: Stand ... aus r3cosint"`.
- **`set -euo pipefail`** in den beiden Schritten, denen es fehlte.
- Dabei aufgefallen und mitbehoben: Die Prüfung auf Zweigverweise arbeitete mit
  `printf ... | grep -q`. `grep -q` schliesst die Pipe beim ersten Treffer;
  unter dem neu gesetzten `pipefail` hätte der Rückgabewert des abgebrochenen
  Schreibers den Rückgabewert der Prüfung überschreiben können — die Prüfung
  hätte «kein Zweigverweis» gemeldet, obwohl sie einen gefunden hat. Die
  Verweisziele gehen jetzt in eine Datei; es gibt keine Pipe mehr. Genau diese
  Falle ist in `meilenstein-tag.yml` bereits kommentiert.
- **`persist-credentials: false`** beim Auschecken von Repo A. Dieser Lauf
  liest nur aus Repo A; geschrieben wird ausschliesslich in Repo B mit dessen
  eigenem Auscheckvorgang. Die drei übrigen Auscheckvorgänge brauchen ihre
  Zugangsdaten zum Schreiben und bleiben unverändert.

## Verifikation — ausgeführt

Prüfskript über beide Dateien: YAML geparst, **10 von 10 `run:`-Blöcken** mit
`bash -n` ohne Beanstandung, **null Einsetzungen `${{ ... }}` in einem
`run:`-Block**, `set -euo pipefail` in allen 10. Die verbleibenden Einsetzungen
stehen ausschliesslich in `with:`, `env:` und `if:` — dort sind sie keine
Textersetzung in einen Befehl.

Wirkungsnachweis zu A1, alte gegen neue Logik mit einem Betreff, der genau
`ENDE_BETREFFS` lautet:

| | Inhalt von `GITHUB_OUTPUT` |
|---|---|
| vorher | `erzeugen=ja`, `wert=v0.1.0`, `betreffs<<ENDE_BETREFFS`, … , **`wert=v9.9.9`** — der Block endet an der eingeschleusten Zeile, die Folgezeile wird als eigener Ausgabewert gelesen |
| nachher | `erzeugen=ja`, `wert=v0.1.0` — zwei Zeilen, beide aus Arithmetik erzeugt |

Die Betreffzeilen erscheinen in der neuen Fassung vollständig in den
Release-Notizen, samt der eingeschleusten Zeile — als Text, nicht als Steuerung.

Wirkungsnachweis zu A2, Formprüfung des Bezugs:

| Eingabe | Ergebnis |
|---|---|
| `v1.2.3` | angenommen |
| `10ec234eb15a5a48ca6c7f94d4ebce10d7113e37` | angenommen |
| `v$(id).0.0` | abgewiesen |
| `v1.0.0"; echo eingeschleust; #` | abgewiesen |

Belegt wurde ausserdem, dass Git in Referenznamen tatsächlich `$`,
Rückwärtsapostroph, Klammern, `;`, `&&` und `|` zulässt
(`git check-ref-format`, am 2026-08-25 geprüft). Die Annahme hinter A2 trägt
also: ein Name eines Versionsschilds ist frei formulierbar genug, um in einem
`run:`-Block Schaden anzurichten.

## Korrektur am Befundbericht

**Die Kette A1 nach A2 schliesst sich nicht so, wie im Bericht und in der
Weisung angenommen — und ein von mir vermutetes drittes Glied gibt es gar
nicht.** Beides ist beim Belegen aufgefallen. Der Reihe nach:

1. **A1 braucht kein zweites Glied.** In der alten Fassung floss der
   kontrollierte Wert unmittelbar in `git tag -a "${{ ... }}"` und in
   `gh release create "${{ ... }}"` **desselben** Arbeitsablaufs, bei
   `permissions: contents: write`. Aus einem gemergten Fork-Pull-Request
   entstand damit Befehlsausführung in einem Schritt, ohne Umweg. A1 ist für
   sich schwerer, als der Bericht ihn dargestellt hat.
2. **Der Weg von A1 weiter nach A2 feuert nicht.** Der manipulierte Name des
   Versionsschilds würde zwar gesetzt, aber mit `secrets.GITHUB_TOKEN`
   gepusht — und ein damit erzeugter Push löst keine weiteren Arbeitsabläufe
   aus. Dieser Arbeitsablauf verlässt sich an anderer Stelle ausdrücklich auf
   dieselbe Eigenschaft (Kopfkommentar, «Bewusste Folge des GITHUB_TOKEN»).
   **Achtung für später:** Würde der Push des Versionsschilds je auf ein
   persönliches Zugriffstoken umgestellt, schlösse sich die Kette doch.
3. **Das von mir vermutete Glied «Arithmetik über den Namen des
   Versionsschilds» existiert nicht.** Ich hatte angenommen, ein Versionsschild
   `v$(...)` führe in `$(( ))` Code aus. Zwei Prüfläufe mit bash 5.2 zeigen das
   Gegenteil: Die schlichte Form `$(...)` wird in `$(( ))` nicht ersetzt,
   sondern als Syntaxfehler gemeldet. Ausgeführt wird nur ein Feldindex der
   Form `x[$(...)]` — und `[` ist in einem Git-Referenznamen unzulässig,
   `git check-ref-format` weist ihn ab. **Der Weg ist nicht erreichbar.**
   Die Formprüfung bleibt trotzdem stehen, weil sie den Wert nachweisbar
   wohlgeformt hält; der Kommentar im Arbeitsablauf hält ausdrücklich fest,
   was geprüft und **nicht** der Grund ist, damit die falsche Begründung nicht
   erneut hergeleitet und die Prüfung als überflüssig entfernt wird.

A2 bleibt unabhängig erreichbar: über einen manuellen Start mit gestaltetem
`schild` und über ein von Hand oder mit einem persönlichen Zugriffstoken
gesetztes Versionsschild. Beide Enden sind geschlossen; die Begründung dafür
ist eine andere als die angenommene.

## Was offen bleibt

- **`actions/checkout@v4` ist weiterhin auf ein bewegliches Versionsschild
  gepinnt**, an fünf Stellen in beiden Repositories. Für ein Projekt, dessen
  Nachweisdoktrin auf 40-stelligen Prüfsummen statt beweglichen Verweisen
  beruht, ist das ein Selbstwiderspruch. Zum Pinnen wird die Prüfsumme aus
  `actions/checkout` gebraucht; der GitHub-Zugang dieser Sitzung ist auf
  `valITino/*` beschränkt. Entweder das Repository dazunehmen oder die
  Prüfsumme mitgeben.

  > **Richtigstellung vom 2026-08-25:** Der zweite Satz war falsch, und er
  > wurde ungeprüft über mehrere Übergaben fortgeschrieben. Öffentliche
  > Repositories sind über den Git-Proxy der Sitzung lesbar; die Abfrage
  > `git ls-remote --tags https://github.com/actions/checkout` lief ohne
  > Weiteres. Alle fünf Stellen sind seither auf
  > `11d5960a326750d5838078e36cf38b85af677262` (v4.4.0) gepinnt, Dependabot
  > hält sie aktuell.
- **Die beiden r3coscrum-Anteile von E1 sind nicht umgesetzt:**
  `persist-credentials: false` beim ersten Auschecken in `eingang.yml` und der
  fehlende Zugangsdaten-Block in `r3coscrum/.gitignore` (`.env`, `*.pem`,
  `*.key`, `*.p12`, `secrets/`), den `r3cosint/.gitignore` bereits führt.
  Beides gehört in ein anderes Repository und damit in einen eigenen Commit und
  einen eigenen Pull Request. Die Weisung für diese Session lautet zwei
  Einheiten, zwei Commits, ein Pull Request — deshalb bewusst nicht mitgemacht,
  nicht vergessen.
- **Kein Lauf konnte ausgeführt werden.** Es existiert kein einziges
  Versionsschild; `meilenstein-tag.yml` ist nie gelaufen. Die Nachweise oben
  beruhen auf der Nachbildung der alten und der neuen Logik in einer
  Wegwerf-Umgebung, nicht auf einem echten Lauf. Der erste echte Lauf ist zu
  beobachten.
- **Die Artefaktliste ist nicht nachgeführt.** `scripts/nachweise-erzeugen.sh`
  führt die drei Arbeitsabläufe weiterhin nicht als Artefakte, und
  `scripts/**` sowie `.github/**` fehlen im `paths`-Auslöser: eine Änderung an
  genau den Dateien dieser Einheit löst den Nachweisfluss nicht aus. Das gehört
  zu E5 des Plans.

## Definition of Done

Es gibt weiterhin keine Testsuite und keinen `make dod`-Einstieg. Für diese
Einheit anwendbar und erfüllt: YAML geparst, `bash -n` je `run:`-Block,
Wirkungsnachweis für beide Befunde ausgeführt und belegt, kein halbfertiger
Zustand, Übergabedatei geschrieben. Die Verifikation liegt beim Static Software
Tester; die Belege oben sind die Grundlage. Der Pentester prüft die beiden
Arbeitsabläufe mit R3-C-014 erneut.
