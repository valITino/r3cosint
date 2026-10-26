# Scrum-Aufbau

Dieses Dokument hält fest, wie Scrum für R3cOSINT aufgesetzt ist und warum.
Grundlage sind der Projektauftrag im Produkt-Repository,
[Abschnitt 6.8](https://github.com/valITino/r3cosint/blob/3f939cea7749d9fbe1df9a7bbc90ff94efe95cb6/docs/00_Projektauftrag.md),
und der Scrum Guide 2020.

## Sprintlänge: zwei Wochen

Der Auftraggeber hat die Wahl delegiert; festgelegt sind **zwei Wochen**.
Begründung: Der Scrum Guide lässt einen Monat oder weniger zu. Bei einem
Team aus zwei berufstätigen Studierenden fällt der Zeremonieaufwand
kürzerer Sprints prozentual zu stark ins Gewicht. Ein Monat ist zu lang,
weil der Engpass nicht die Umsetzung ist, sondern das menschliche Review —
dann stauen sich zu viele unbegutachtete Inkremente. Zwei Wochen bieten
pro Sprint mehrere Abende und ein Wochenende für Reviews
[Abschnitt 6.8](https://github.com/valITino/r3cosint/blob/3f939cea7749d9fbe1df9a7bbc90ff94efe95cb6/docs/00_Projektauftrag.md).

## Ereignisse und Timeboxes

Die Ereignisse folgen dem Scrum Guide 2020, die Timeboxes sind anteilig
auf die Sprintlänge von zwei Wochen umgerechnet:

| Ereignis | Timebox |
|---|---|
| Sprint Planning | höchstens 4 Stunden |
| Daily Scrum | 15 Minuten |
| Sprint Review | höchstens 2 Stunden |
| Sprint-Retrospektive | höchstens 1,5 Stunden |

Die Ergebnisse von Sprint Reviews und Retrospektiven werden in diesem
Repository unter `sprints/` festgehalten.

## Verantwortlichkeiten

Scrum kennt drei Verantwortlichkeiten: Product Owner, Scrum Master,
Developers. Der ursprüngliche Auftrag nannte nur den Scrum Master; Product
Owner und weitere Rollen wurden ergänzt
[Abschnitt 4.3](https://github.com/valITino/r3cosint/blob/3f939cea7749d9fbe1df9a7bbc90ff94efe95cb6/docs/00_Projektauftrag.md).

| Verantwortlichkeit | Aufgabe | Besonderheit in diesem Projekt |
|---|---|---|
| **Product Owner** | Ordnet das Product Backlog und entscheidet über Priorität | Bleibt vom Requirements Engineer getrennt, damit nicht dieselbe Instanz Anforderungen erhebt und priorisiert [Abschnitt 6.1](https://github.com/valITino/r3cosint/blob/3f939cea7749d9fbe1df9a7bbc90ff94efe95cb6/docs/00_Projektauftrag.md) |
| **Scrum Master** | Prozess, Ereignisse, Hindernisbeseitigung | Arbeitsgrundlage Scrum Guide 2020; Schreibrechte nur auf Planungsartefakte [Abschnitt 4.2](https://github.com/valITino/r3cosint/blob/3f939cea7749d9fbe1df9a7bbc90ff94efe95cb6/docs/00_Projektauftrag.md) |
| **Developers** | Umsetzung der Sprint-Backlog-Einträge | Die Umsetzung übernimmt zu rund 80 Prozent Claude Code über das Rollenmodell; der menschliche Anteil von rund 20 Prozent liegt bei Review, Freigabe und Feinschliff durch Auftraggeber und Studienkollege [Abschnitt 6.8](https://github.com/valITino/r3cosint/blob/3f939cea7749d9fbe1df9a7bbc90ff94efe95cb6/docs/00_Projektauftrag.md) |

**Commitments:** Product Goal für das Product Backlog, Sprint Goal für das
Sprint Backlog, Definition of Done für das Inkrement.

## Definition of Ready gegenüber Definition of Done

Die beiden sind strikt zu unterscheiden: **Ready gilt für den Eingang in
den Sprint, Done für den Ausgang**
[Abschnitt 6.8](https://github.com/valITino/r3cosint/blob/3f939cea7749d9fbe1df9a7bbc90ff94efe95cb6/docs/00_Projektauftrag.md).

**Definition of Ready** — abgeleitet aus den IREB-Qualitätskriterien für
Anforderungen. Ein Backlog-Eintrag darf erst in einen Sprint gezogen
werden, wenn er je Eintrag adäquat, notwendig, eindeutig, in sich
vollständig, ohne Zusatzerklärung verständlich und prüfbar ist — es
existiert ein Abnahmekriterium, das sich als Test formulieren lässt. Für
das Backlog als Ganzes gelten Konsistenz, Redundanzfreiheit,
Vollständigkeit, Änderbarkeit, Verfolgbarkeit und Konformität zu den
rechtlichen Vorgaben. Die Definition of Ready ist der Ort, an dem der
menschliche Anteil am meisten bewirkt: Ein schlecht formulierter Eintrag
erzeugt sauberen Code für das falsche Problem
[Abschnitt 6.5](https://github.com/valITino/r3cosint/blob/3f939cea7749d9fbe1df9a7bbc90ff94efe95cb6/docs/00_Projektauftrag.md).

**Definition of Done** — verbindlich für alle Rollen und formuliert als
**ausführbare Befehlskette**: Für jede Aufgabe ist festgelegt, welche
Befehle mit Rückgabewert 0 enden müssen, damit sie als erledigt gilt.
Damit hat die Iterationspflicht ein maschinell prüfbares Abbruchkriterium
statt einer Selbsteinschätzung des Modells. Was nicht als Test formuliert
werden kann, gilt nicht als erledigt, sondern als offen und geht an den
Auftraggeber zurück [Abschnitt 3.4](https://github.com/valITino/r3cosint/blob/3f939cea7749d9fbe1df9a7bbc90ff94efe95cb6/docs/00_Projektauftrag.md).
Einzige ausdrückliche Ausnahme ist der interaktive Prototyp, dessen
Freigabe ein menschliches Gate ist, weil sich Bedienführung nicht messen
lässt [Abschnitt 5.6](https://github.com/valITino/r3cosint/blob/3f939cea7749d9fbe1df9a7bbc90ff94efe95cb6/docs/00_Projektauftrag.md).

Der Zusammenhang der beiden: Ready verlangt ein testbar formuliertes
Abnahmekriterium, Done führt genau diese Tests aus. Ein Eintrag ohne
testbares Abnahmekriterium erfüllt die Definition of Ready nicht.

## Sprintumfang nach Prüfkapazität, nicht nach Erzeugungskapazität

Die Kapazität ist geklärt: 7 bis 10 Stunden pro Woche und Person, also 14
bis 20 Stunden im Team und **28 bis 40 Personenstunden je Sprint** von
zwei Wochen. Diese Stunden sind nicht Entwicklungszeit, sondern Review-,
Freigabe- und Feinschliffzeit, denn die Umsetzung übernimmt Claude Code
[Abschnitt 6.8](https://github.com/valITino/r3cosint/blob/3f939cea7749d9fbe1df9a7bbc90ff94efe95cb6/docs/00_Projektauftrag.md).

Daraus folgt die Planungsregel, die dem üblichen Vorgehen widerspricht:

> **Der Sprintumfang bemisst sich an der Prüfkapazität, nicht an der
> Erzeugungskapazität.**

Claude Code kann in einem Sprint mehr produzieren, als in 28 bis 40
Stunden sorgfältig geprüft werden kann. Würde der Sprint an dem bemessen,
was erzeugbar ist, entstünde ein wachsender Bestand ungeprüfter
Inkremente — bei einem Werkzeug mit Nachweispflicht die gefährlichste Form
von Fortschritt. Der Product Owner nimmt deshalb nur so viel in den
Sprint, wie das Team prüfen kann.

**Praktische Faustregel:** Vor der Aufnahme eines Backlog-Eintrags wird
der geschätzte **Prüfaufwand** notiert, nicht der Umsetzungsaufwand. Die
Summe darf 28 bis 40 Stunden nicht überschreiten. Die Schätzung ist
anfangs ungenau und wird über die Sprints kalibriert; die Retrospektive
ist der Ort dafür.

Aus demselben Grund weist die Roadmap keine Kalenderzahl aus, bevor das
Backlog geschätzt ist, und führt die menschlichen Review-Wartezeiten als
eigene Positionen, weil sie auf dem kritischen Pfad liegen
[Abschnitt 6.8](https://github.com/valITino/r3cosint/blob/3f939cea7749d9fbe1df9a7bbc90ff94efe95cb6/docs/00_Projektauftrag.md).

## Offene Punkte

- [OFFEN, präzisiert 2026-08-25] Die Definition of Done liegt vor
  ([Definition of Ready und Done](https://github.com/valITino/r3cosint/blob/3a40faa87feac056cd7bfa7c0fdf3f5f77b761fb/docs/06_Definition_of_Ready_und_Done.md));
  die konkrete Befehlskette D1 bis D12 steht als Vorschlag in ADR 0002,
  Abschnitt 6 des Produkt-Repositories. Offen bleiben die Bestätigung der
  Befehle durch DevOps Engineer und Auftraggeber sowie die Erzwingung über
  Hooks (R3-Q-001).
- [OFFEN] Die personelle Besetzung von Product Owner und Scrum Master
  (Mensch oder Claude-Code-Rolle, und wer konkret) ist im Projektauftrag
  nicht ausgewiesen.
- [OFFEN] Der Start des ersten Sprints und damit der Sprintkalender sind
  nicht festgelegt.

## Verweise in diesem Dokument

Aufgelöst aus dem Nachweisverzeichnis (`nachweise/NACHWEISE.md`, Stand
`4c64300e9ec00fd1068964e14c2666c631d00dfa`):

- [Abschnitt 6.8](https://github.com/valITino/r3cosint/blob/3f939cea7749d9fbe1df9a7bbc90ff94efe95cb6/docs/00_Projektauftrag.md)
- [Abschnitt 6.5](https://github.com/valITino/r3cosint/blob/3f939cea7749d9fbe1df9a7bbc90ff94efe95cb6/docs/00_Projektauftrag.md)
- [Abschnitt 6.1](https://github.com/valITino/r3cosint/blob/3f939cea7749d9fbe1df9a7bbc90ff94efe95cb6/docs/00_Projektauftrag.md)
- [Abschnitt 4.2](https://github.com/valITino/r3cosint/blob/3f939cea7749d9fbe1df9a7bbc90ff94efe95cb6/docs/00_Projektauftrag.md)
- [Abschnitt 4.3](https://github.com/valITino/r3cosint/blob/3f939cea7749d9fbe1df9a7bbc90ff94efe95cb6/docs/00_Projektauftrag.md)
- [Abschnitt 3.4](https://github.com/valITino/r3cosint/blob/3f939cea7749d9fbe1df9a7bbc90ff94efe95cb6/docs/00_Projektauftrag.md)
- [Abschnitt 5.6](https://github.com/valITino/r3cosint/blob/3f939cea7749d9fbe1df9a7bbc90ff94efe95cb6/docs/00_Projektauftrag.md)
- [Abschnitt 2](https://github.com/valITino/r3cosint/blob/3f939cea7749d9fbe1df9a7bbc90ff94efe95cb6/docs/00_Projektauftrag.md)
