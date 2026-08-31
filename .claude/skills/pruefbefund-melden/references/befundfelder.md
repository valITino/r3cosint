# Feldmenge je Prüfrolle, Berichtskopf und Beispiele

Ergänzung zu `../SKILL.md`. Wird geladen, wenn der Bericht geschrieben wird.

**Herkunft der Angaben.** Diese Datei macht dazu keine Sammelaussage mehr —
zwei Anläufe dazu waren nacheinander zu stark ("stammen aus den
Rollendateien", dann "stammen wörtlich"), und beide Male fanden Prüfungen
Zusätze, die dort nicht standen. **Die Herkunft steht deshalb jetzt bei jeder
einzelnen Angabe**, nicht in einem Satz über alle. Ein Punkt ohne Zusatz ist
aus der genannten Rollendatei übernommen; alles, was diese Datei selbst
hinzufügt, trägt den Vermerk _(Zusatz dieser Datei)_.

Das ist derselbe Grundsatz, den `../SKILL.md` für Prüfberichte aufstellt, hier
auf die eigene Datei angewandt: Wer eine Sammelaussage über Herkunft schreibt,
muss sie für jede einzelne Angabe verantworten — und genau das misslingt.

## Berichtskopf — bei jedem Bericht

**Vollständig Zusatz dieser Datei.** Keines dieser fünf Felder steht in einer
Rollendatei. Sie sind hier ergänzt, damit im Bericht selbst belegt ist, was
3.4 (Prüfung auf einem anderen Modell als die Umsetzung) und 6.6
(Verfolgbarkeit) verlangen.

| Angabe | Weshalb sie dasteht |
|---|---|
| Prüfgegenstand | Datei, Commit oder Arbeitsbaum-Stand, eindeutig bezeichnet. Bei einem Commit die vollständige 40-stellige Prüfsumme (6.6) |
| Massstab | Wogegen geprüft wurde: Abnahmekriterium, Abschnitt des Projektauftrags, ADR |
| Prüfendes Modell | 3.4 verlangt, dass ein modellbasierter Prüfschritt auf einem anderen Modell läuft als die Umsetzung. Steht es nicht im Bericht, ist die Trennung behauptet und nicht belegt |
| Umfang der Stichprobe | Was angesehen wurde und was nicht. "Alles" ist nur zulässig, wenn es stimmt |
| Ort der Ausführung | Original oder Wegwerf-Kopie. Ein Prüflauf verändert den Gegenstand nicht, über den er urteilt |

## Static Software Tester

Zusätzlich zu den Pflichtfeldern aus `../SKILL.md`; Quelle
`.claude/agents/static-software-tester.md`, Abschnitt "Erwartete Ausgabeform":

- **Schweregrad** je Befund.
- **Belegstelle** je Befund. _(Zusatz dieser Datei: gemeint ist die Stelle im
  Bestand, die den Befund trägt.)_
- **Protokoll der ausgeführten Prüfbefehle** mit Befehlszeile und
  Rückgabewert. _(Zusatz dieser Datei: vollständig, nicht als Auswahl der
  gelungenen.)_

## Dynamic Software Tester

Quelle `.claude/agents/dynamic-software-tester.md`, Abschnitt "Erwartete
Ausgabeform":

- **Testfall nach ISO/IEC/IEEE 29119**: Vorbedingung, Schritte, erwartetes
  Ergebnis, Bezug auf das Abnahmekriterium.
- **Testname mit Anforderungskennung** (6.6). _(Zusatz dieser Datei: dieselbe
  Kennung wie im Backlog-Eintrag.)_
- **Testlaufprotokoll** mit Befehlszeile, Rückgabewert je Befehl und
  gemessener Abdeckung.
- **Reproduktionsschritte** je Fehlerbericht.
- **Verwendete synthetische Ausgangslage** je Fehlerbericht. _(Zusatz dieser
  Datei: Über den Harness laufen zu keinem Zeitpunkt echte Fall- oder
  Personendaten (5.15); die Ausgangslage ist deshalb Teil des Nachweises,
  nicht Beiwerk.)_

## Pentester

Quelle `.claude/agents/pentester.md`, Abschnitt "Erwartete Ausgabeform":

- **Testplan nach OWASP WSTG**, in dem jeder Testfall einer Verfahrensgarantie
  aus 5.4 oder einem Punkt der OWASP Top 10 zugeordnet ist.
- **Reproduktionsschritte**, betroffenes Bauteil, Nachweis, **CWE-Bezug**.
- **Keine eigene Risikoeinstufung.** Die Bewertung nach CVSS liegt beim
  Vulnerability Manager; der Befund geht dorthin.
- Geprüft wird ausschliesslich gegen Test/Schulung (5.16). _(Aus dem Abschnitt
  "Grenzen und Rechte" derselben Rollendatei, nicht aus der Ausgabeform.)_

## Zwei Beispiele

### Ein Befund

> **Befund 2 — blockierend — die Wache misst einen Namen, nicht den Gegenstand**
>
> **Datei/Zeile:** `Makefile:212` (Rückfall), `Makefile:242-245` (Wache)
> **Was falsch ist:** Die Wache prüft, ob am Rückfallort *irgendein* Marker
> liegt, nicht ob es der *richtige* ist.
> **Beleg (ausgeführt):** Zwei vollständige Arbeitskopien; aus `repoB` heraus
> `make -f "<pfad mit leerzeichen>/Makefile" dod` → `PROJ_TAUGLICH := ja`,
> keine Meldung, `git -C repoA status` unverändert: `repoA` wurde nie berührt.
> **Blockierend, weil:** Der Lauf sieht aus wie eine reguläre Prüfung von A;
> geprüft wurde B. Kommt B weiter als A, ist das ein falsches Grün.

Woran das Beispiel hängt: Datei und Zeile, ein Satz zum Mangel, ein
ausgeführter Beleg, und die Begründung der Einstufung. Keine Behebung.

### Ein Negativbefund

> **Geprüft, ohne Beanstandung:** `PYTHONPATH`, `UV_PROJECT_ENVIRONMENT`,
> `VIRTUAL_ENV` und `PYTHONHOME` wirken strukturell nicht — alle vier in der
> aufrufenden Shell auf Angriffswerte gesetzt, danach `make bau`:
> Rückgabewert 0, Umfeld korrekt angelegt, echtes Paket installiert.

Ein Negativbefund ohne Beleg ist kein Negativbefund, sondern eine Beteuerung.

## Der Textbaustein für die Übergabedatei

Fällt dieselbe Prüfung dreimal am gleichen Kriterium durch, wird abgebrochen
(3.4). Der Baustein enthält:

1. Das gescheiterte Kriterium, wörtlich und einmal — nicht drei Beschreibungen
   desselben Kriteriums.
2. Je Runde eine Zeile: was befundet wurde, was behoben wurde.
3. Das **Muster** hinter den drei Runden. Wer nur die drei Einzelfälle
   aufschreibt, legt die vierte Runde an.
4. Was der Auftraggeber entscheiden muss, damit es weitergeht.
