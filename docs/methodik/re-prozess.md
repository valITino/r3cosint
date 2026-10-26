# Konfiguration des RE-Prozesses nach IREB

Dieses Dokument leitet her, wie das Requirements Engineering für R3cOSINT
konfiguriert ist. Grundlage sind der Projektauftrag im Produkt-Repository,
[Abschnitt 6.1](https://github.com/valITino/r3cosint/blob/3f939cea7749d9fbe1df9a7bbc90ff94efe95cb6/docs/00_Projektauftrag.md) und
[Abschnitt 6.2](https://github.com/valITino/r3cosint/blob/3f939cea7749d9fbe1df9a7bbc90ff94efe95cb6/docs/00_Projektauftrag.md),
sowie der IREB CPRE
Foundation Level, Lehrplan v3.3.0.

## Ausgangspunkt: zwei Rahmenwerke, bewusst getrennt

Die Planung folgt zwei Rahmenwerken, die sich ergänzen statt konkurrieren:

- **IREB CPRE Foundation Level v3.3.0** für das Requirements Engineering.
  Es beantwortet: Was soll das System leisten, wie gut, und woran erkennt
  man das.
- **Scrum Guide 2020** für den Entwicklungsprozess. Er beantwortet: In
  welcher Reihenfolge, in welchem Takt, mit welchen Ereignissen.

Die Trennung ist kein Formalismus. Ein Product Backlog ist eine
Dokumentationsstruktur für Anforderungen, kein Ersatz für Requirements
Engineering: Wer nur Scrum macht, hat eine Reihenfolge, aber keine
geprüften Anforderungen. Umgekehrt liefert RE ohne Prozessrahmen keine
Lieferfähigkeit. [Abschnitt 6.1](https://github.com/valITino/r3cosint/blob/3f939cea7749d9fbe1df9a7bbc90ff94efe95cb6/docs/00_Projektauftrag.md)

## Die drei Facetten und ihre Einordnung für R3cOSINT

Nach IREB gibt es keinen allgemeingültigen RE-Prozess. Er wird anhand von
drei Facetten mit je zwei Polen konfiguriert. Die Einordnung für R3cOSINT
ist im Projektauftrag festgelegt
[Abschnitt 6.2](https://github.com/valITino/r3cosint/blob/3f939cea7749d9fbe1df9a7bbc90ff94efe95cb6/docs/00_Projektauftrag.md):

| Facette | Pole | Einordnung R3cOSINT | Begründung |
|---|---|---|---|
| **Zeit** | linear / iterativ | **iterativ** | Entwicklung nach Scrum; ein Teil der Anforderungen entsteht erst am laufenden Prototyp |
| **Zweck** | präskriptiv / explorativ | **explorativ, mit präskriptivem Teil** | Die fachlichen Anforderungen werden erarbeitet; die rechtlichen und datenschutzrechtlichen Vorgaben sind vorab verbindlich und nicht verhandelbar |
| **Ziel** | kundenspezifisch / marktorientiert | **kundenspezifisch** | Auftraggeber ist das eigene Dezernat; die Stakeholder sind namentlich bekannt und erreichbar |

## Ergebnis: partizipativer Prozess mit präskriptivem Teilbereich

Aus der Kombination iterativ, explorativ und kundenspezifisch ergibt sich
ein **partizipativer RE-Prozess** — mit einem klar abgegrenzten
**präskriptiven Teilbereich** für Recht und Datenschutz. Die massgebenden
Vorgaben dieses Teilbereichs stehen im Projektauftrag,
[Abschnitt 4.4](https://github.com/valITino/r3cosint/blob/3f939cea7749d9fbe1df9a7bbc90ff94efe95cb6/docs/00_Projektauftrag.md).

## Warum diese Mischung gewählt wurde

Die Mischung ist bewusst so und keine Unschärfe. Der Massstab dafür steht
im Projektauftrag: Ein Anwendungsfall im Graphen darf sich über mehrere
Sprints entwickeln — eine Aufbewahrungsfrist nicht.

- Der **explorative Teil** passt zum Projekt, weil zu Beginn kein
  Produktionscode und kein festgelegter Tech-Stack existiert und die
  fachlichen Anforderungen am Prototyp und im Dialog mit den bekannten
  Stakeholdern erarbeitet werden. Der interaktive Prototyp ist dabei ein
  Validierungsmittel im Sinne von IREB
  [Abschnitt 6.7](https://github.com/valITino/r3cosint/blob/3f939cea7749d9fbe1df9a7bbc90ff94efe95cb6/docs/00_Projektauftrag.md).
- Der **präskriptive Teilbereich** ist nötig, weil R3cOSINT für den echten
  Einsatz bei der Kantonspolizei Bern gebaut wird. Rechtliche und
  datenschutzrechtliche Vorgaben werden nicht erarbeitet, sondern gelten
  vorab. Im Backlog werden beide Teile deshalb unterschiedlich behandelt:
  Der präskriptive Teil ist nicht verhandelbar und wird **nicht neu
  priorisiert, sondern nur terminiert**
  [Abschnitt 6.2](https://github.com/valITino/r3cosint/blob/3f939cea7749d9fbe1df9a7bbc90ff94efe95cb6/docs/00_Projektauftrag.md)
  [Abschnitt 6.4](https://github.com/valITino/r3cosint/blob/3f939cea7749d9fbe1df9a7bbc90ff94efe95cb6/docs/00_Projektauftrag.md).
- Die **kundenspezifische** Ausrichtung erlaubt direkte Beteiligung: Die
  Stakeholder sind erreichbar, Klärungen laufen über den Auftraggeber
  statt über Marktannahmen.

## Zuständigkeiten

Der RE-Anteil liegt bei der Rolle Requirements Engineer, der Prozessanteil
beim Scrum Master, die Ordnung des Backlogs beim Product Owner. Nach IREB
nimmt der Product Owner häufig zugleich die Rolle des Requirements
Engineers ein; hier bleiben die beiden getrennt, damit nicht dieselbe
Instanz Anforderungen erhebt und priorisiert
[Abschnitt 6.1](https://github.com/valITino/r3cosint/blob/3f939cea7749d9fbe1df9a7bbc90ff94efe95cb6/docs/00_Projektauftrag.md).

## Vorgehen: die fünf Konfigurationsschritte

Der Requirements Engineer arbeitet die fünf Konfigurationsschritte nach
IREB der Reihe nach ab und dokumentiert jeden
[Abschnitt 6.2](https://github.com/valITino/r3cosint/blob/3f939cea7749d9fbe1df9a7bbc90ff94efe95cb6/docs/00_Projektauftrag.md):

1. Einflussfaktoren analysieren (Entwicklungskontext, Verfügbarkeit der
   Stakeholder, Kritikalität, Randbedingungen, Zeit und Budget,
   Volatilität der Anforderungen).
2. Facettenkriterien beurteilen — die Tabelle oben ist die Vorgabe aus dem
   Projektauftrag; sie ist zu **belegen, nicht zu übernehmen**.
3. Prozess konfigurieren.
4. Arbeitsprodukte bestimmen (siehe `arbeitsprodukte.md`).
5. Praktiken auswählen (Ermittlungs-, Validierungs- und
   Priorisierungstechniken).

## Offene Punkte

- [OFFEN, präzisiert 2026-08-25] Schritt 3 der Lieferreihenfolge ist
  erledigt und am 2026-08-20 freigegeben (Produkt-Repository,
  `docs/08_Freigabe_Schritt_4.md`); die Arbeitsprodukte liegen vor. Offen
  bleibt allein die Facettenbeurteilung (Schritt 2 des RE-Prozesses) als
  eigene, belegte Analyse; bis dahin gibt dieses Dokument nur die Vorgabe
  aus dem Projektauftrag wieder.
- [OFFEN] Die Auswahl der Praktiken (Schritt 5) ist im Projektauftrag
  nicht festgelegt.

## Verweise in diesem Dokument

Aufgelöst aus dem Nachweisverzeichnis (`nachweise/NACHWEISE.md`, Stand
`4c64300e9ec00fd1068964e14c2666c631d00dfa`):

- [Abschnitt 6.1](https://github.com/valITino/r3cosint/blob/3f939cea7749d9fbe1df9a7bbc90ff94efe95cb6/docs/00_Projektauftrag.md)
- [Abschnitt 6.2](https://github.com/valITino/r3cosint/blob/3f939cea7749d9fbe1df9a7bbc90ff94efe95cb6/docs/00_Projektauftrag.md)
- [Abschnitt 6.4](https://github.com/valITino/r3cosint/blob/3f939cea7749d9fbe1df9a7bbc90ff94efe95cb6/docs/00_Projektauftrag.md)
- [Abschnitt 6.7](https://github.com/valITino/r3cosint/blob/3f939cea7749d9fbe1df9a7bbc90ff94efe95cb6/docs/00_Projektauftrag.md)
- [Abschnitt 4.4](https://github.com/valITino/r3cosint/blob/3f939cea7749d9fbe1df9a7bbc90ff94efe95cb6/docs/00_Projektauftrag.md)
- [Abschnitt 2](https://github.com/valITino/r3cosint/blob/3f939cea7749d9fbe1df9a7bbc90ff94efe95cb6/docs/00_Projektauftrag.md)
