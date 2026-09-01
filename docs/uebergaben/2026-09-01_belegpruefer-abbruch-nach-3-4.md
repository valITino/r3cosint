# Übergabe — Belegprüfer, Abbruch nach Eskalationsregel 3.4

| | |
|---|---|
| **Arbeitsprodukt nach** | Projektauftrag 3.3 (Übergabedatei), 3.4 (Eskalation) |
| **Einheit** | Prüfregel für Herkunftsangaben, auf Freigabe des Auftraggebers vom 2026-09-01 |
| **Datum** | 2026-09-01 |
| **Zweig** | `claude/next-step-g8slnq` |
| **Ergebnis** | **Gebaut und wirksam, aber nicht abgenommen.** Drei Prüfrunden, drei blockierende Befunde, jedes Mal am gleichen Kriterium |

## Woher der Auftrag kam

Die Arbeitseinheit zu den ersten zwei Skills war am 2026-08-31 nach 3.4
abgebrochen worden: dreimal dieselbe Fehlerklasse — *eine Aussage über die
Herkunft ist stärker, als die Quelle sie trägt*. Die Prüfung hatte den Ausweg
selbst benannt: eine Prüfregel, die jede Zahl, jedes Zitat und jeden Verweis
maschinell gegen seinen Fundort hält. Der Auftraggeber hat sie freigegeben.

## Was das Skript kann — und das ist unabhängig belegt

`scripts/belege-pruefen.sh` prüft über alle versionierten Markdown-Dateien in
`docs/`, `.claude/` und im Wurzelverzeichnis:

| Prüfung | Was sie feststellt |
|---|---|
| Zeilenverweise | `datei:N` zeigt hinter das Dateiende |
| Commit-Prüfsummen | 40 Hexstellen bezeichnen keinen Commit der beiden Arbeitsbäume |
| `blob/main`, `tree/main` | Verstoss gegen 6.6 — ausser wo eine Regel die Form als Beispiel zitiert |
| Anforderungskennungen | `R3-x-nnn` steht nicht als Überschrift im Backlog |
| Pfadverweise | Datei oder Verzeichnis fehlt, auch im Methodik-Repository |
| Abschnitte | `(N.M)` bezeichnet keinen Abschnitt des Projektauftrags |

Dazu eine Ausnahmeliste mit **ortsgebundenen** Schlüsseln (`datei:zeile` oder
`datei|wert`), die sich selbst prüft: Ein Eintrag ohne Grund ist ein Befund,
und ein Eintrag, dessen Gegenstand inzwischen existiert, ebenfalls.

**Unabhängig belegt in drei Runden:** Neun eingebaute Fehlerklassen wurden je
gefangen. Die Unterscheidung zwischen Zweigname und kaputtem Pfad hält in
beide Richtungen. Die Regel "Verweise in einen noch nicht gebauten Baum sind
kein Fund" schaltet sich nachweislich scharf, sobald das Verzeichnis entsteht
— aus 0 Funden werden sofort 46. Der Lauf verändert nichts, in keinem der
beiden Arbeitsbäume.

Über den heutigen Bestand: **null Funde**, 30 Ausnahmen, jede mit Datei und
geschriebenem Grund, alle einzeln am Bestand nachgeschlagen.

## Weshalb es trotzdem nicht abgenommen ist

Drei Prüfrunden, drei blockierende Befunde — und alle drei am gleichen
Kriterium: **Was das Skript über sich selbst sagt, ist stärker als das, was
sein Code trägt.**

| Runde | Befund | Wo er herkam |
|---|---|---|
| 1 | Ausnahmen waren wertgebunden und unterdrückten jedes künftige Vorkommen desselben Wortlauts im ganzen Bestand | Das Skript kannte das Risiko und hatte es nur für eine von vier Kategorien gelöst |
| 2 | Die Umstellung auf ortsgebundene Schlüssel legte die Veraltungsprüfung still — für 23 von 30 Einträgen konnte sie strukturell nie auslösen | Die Behebung aus Runde 1 |
| 3 | Die Behebung aus Runde 2 machte einen Codepfad erstmals wirksam, dessen Fehlalarm-Verhalten nie geprüft war | Die Behebung aus Runde 2 |

**Das Muster ist in Runde 3 ausdrücklich benannt worden und trägt:** Jede
Behebung hat eine Schicht geschaffen oder erreichbar gemacht, die niemand
geprüft hat. Wer die dritte Runde nur an ihrer Fundstelle repariert, legt die
vierte an. Das ist der Fall, für den 3.4 den Abbruch vorsieht.

## Was trotzdem getan wurde

**Der belegte Fehlalarm ist gestrichen, nicht umgeschrieben.** Die
Veraltungsprüfung fiel auf einen Existenztest an der Wurzel zurück, der auch
für nicht pfadförmige Werte griff. Die zwei Vergleiche sind entfernt; eine
Streichung kann keinen neuen Fehlalarm einführen, eine Neuformulierung schon.
Gegenprobe ausgeführt: Der Fehlalarm ist weg, der echte Treffer bleibt.

**Und die Selbstauskunft sagt jetzt die einzige Aussage, die nach drei Runden
noch belegbar ist:** dass die Liste ihrer Grenzen **unvollständig** ist. Sie
nennt die Zahl der Runden, sagt, dass jede eine weitere Grenze fand, und
schliesst mit dem Satz, auf den es ankommt — *Rückgabewert 0 heisst: nichts
von dem gefunden, was hier aufgezählt ist; nicht: nichts vorhanden.*

Das ist der Unterschied zu den drei gescheiterten Runden. Sie haben jeweils
versucht, die Liste der Grenzen zu vervollständigen. Diese Fassung behauptet
nicht mehr, sie sei vollständig.

## Was der Auftraggeber entscheiden muss

1. **Wird der Belegprüfer in `make dod` eingebunden?** Er ist es **nicht** —
   ein zusätzlicher Kettenschritt ist nach ADR 0002 eine Fortschreibung, keine
   stillschweigende Ergänzung, und ein nicht abgenommenes Werkzeug gehört
   nicht in eine Kette, deren Ergebnis ein Nachweis ist. Meine Empfehlung:
   einbinden, aber erst nach dieser Entscheidung und mit dem ADR-Schritt.
2. **Reicht "die Liste der Grenzen ist unvollständig" als Abnahmekriterium?**
   Das ist die eigentliche Frage. Für ein Werkzeug, das Befunde meldet, halte
   ich sie für ausreichend — es findet, was es findet, und behauptet nichts
   darüber hinaus. Für ein Werkzeug, das eine Kette blockiert, ist sie es
   möglicherweise nicht.
3. **Die zwei nicht gebauten Prüfungen** — Skill-Zuordnung im Rollen-
   Frontmatter und `metadata.anforderung` gegen den Backlog. Beide sind billig
   und rauschfrei; sie fehlen aus Zeitgründen und sind im Skript benannt.

## Zu den beiden Skills

Der Vermerk "NICHT ABGENOMMEN" ist von ihnen **entfernt**. Die drei
Herkunftsangaben, die stärker waren als ihre Quelle, sind weg, und der
maschinell prüfbare Teil dieser Klasse wird jetzt geprüft — beide Skills
laufen im Belegprüfer ohne Befund. An ihre Stelle tritt ein genauerer Satz:
Was nicht maschinell prüfbar ist — ob der Inhalt am genannten Fundort die
Behauptung auch trägt —, bleibt Sache des menschlichen Reviews, und das Skript
sagt es selbst.

## Was diese Einheit gelernt hat

Zweimal an einem Tag ist dasselbe Muster aufgetreten, einmal in einem
Dokument, einmal im Werkzeug, das es finden sollte. Beide Male hat es keine
Selbstprüfung gefunden, sondern eine unabhängige Instanz auf einem anderen
Modell — und beide Male erst, nachdem die vorherige Behebung eine neue Schicht
geschaffen hatte.

Daraus folgt nichts über Sorgfalt und alles über Verfahren: **Eine Behebung
ist nicht fertig, wenn der Befund weg ist, sondern wenn die Schicht geprüft
ist, die sie neu erreichbar gemacht hat.** Dieser Satz gehört in die
Definition of Done, nicht in eine Übergabe — und das ist ein Vorschlag an den
Requirements Engineer, kein Entscheid.
