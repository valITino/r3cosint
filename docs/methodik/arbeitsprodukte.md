# Arbeitsprodukte des Requirements Engineering

Dieses Dokument hält fest, welche RE-Arbeitsprodukte für R3cOSINT geführt
werden, wozu, von wem und mit welcher Lebensdauer. Grundlage ist der
Projektauftrag im Produkt-Repository,
[Abschnitt 6.3](https://github.com/valITino/r3cosint/blob/3f939cea7749d9fbe1df9a7bbc90ff94efe95cb6/docs/00_Projektauftrag.md).
Die Arbeitsprodukte
selbst liegen im Produkt-Repository und werden von hier aus nur verwiesen,
nie kopiert — Begründung der Aufteilung in
[Abschnitt 1.3](https://github.com/valITino/r3cosint/blob/3f939cea7749d9fbe1df9a7bbc90ff94efe95cb6/docs/00_Projektauftrag.md).

## Herleitung

Für einen partizipativen RE-Prozess (siehe `re-prozess.md`) sieht IREB als
Arbeitsprodukte ein Product Backlog mit User Stories und Prototypen vor.
Beides ist im Projekt vorgesehen. Ergänzt werden drei Arbeitsprodukte, die
im ursprünglichen Auftrag fehlten: Stakeholderliste, Glossar und
Kontextmodell [Abschnitt 6.3](https://github.com/valITino/r3cosint/blob/3f939cea7749d9fbe1df9a7bbc90ff94efe95cb6/docs/00_Projektauftrag.md).

## Übersicht

| Arbeitsprodukt | Wozu | Verantwortlich | Lebensdauer | Stand im Produkt-Repository |
|---|---|---|---|---|
| **Stakeholderliste** | Festhalten, wer betroffen ist und mitredet: je Stakeholder mindestens Name, Funktion und Rolle, Kontakt, Verfügbarkeit, Relevanz, Fachgebiet, Ziele und Interessen | Requirements Engineer | sich weiterentwickelnd | vorhanden: [Stakeholderliste](https://github.com/valITino/r3cosint/blob/a48cb46fb7d2d9f8fc05bc573d1fd248cf9c989f/docs/02_Stakeholderliste.md) |
| **Glossar** | Verbindliche Definitionen aller Fachbegriffe; Verwendung für alle Arbeitsprodukte und Oberflächentexte verpflichtend | Requirements Engineer, ein benannter Verantwortlicher | langlebig | vorhanden: [Glossar](https://github.com/valITino/r3cosint/blob/a48cb46fb7d2d9f8fc05bc573d1fd248cf9c989f/docs/03_Glossar.md) |
| **Kontextmodell** | Systemgrenze, Kontextgrenze, Scope, externe Akteure und Schnittstellen | Software Architect | sich weiterentwickelnd | vorhanden: [Kontextmodell](https://github.com/valITino/r3cosint/blob/ef62b489e54d609b2e0a8760f38fa4478f587704/docs/04_Kontextmodell.md) |
| **Product Backlog** | Geordnete Anforderungen mit Anforderungsart, Priorisierung und Abnahmekriterien | Product Owner | sich weiterentwickelnd | vorhanden: [Product Backlog](https://github.com/valITino/r3cosint/blob/3a40faa87feac056cd7bfa7c0fdf3f5f77b761fb/docs/05_Product_Backlog.md) |
| **Interaktiver Prototyp** | Anforderungen am laufenden Bild ermitteln und validieren; Freigabe-Gate vor jedem Frontend-Produktionscode | UX/UI-Designer (fachlich), Requirements Engineer (methodisch) | kurzlebig, Wegwerf | vorhanden: [Prototyp Demo](https://github.com/valITino/r3cosint/blob/783081fe6d13fef8ab89bc9d5f62d3e2e368716a/prototype/OSINT_Plattform_Demo.html), wird ergänzt, nicht ersetzt |
| **Projektauftrag** | Baseline der vereinbarten Anforderungen | Protocol Master | langlebig, änderungskontrolliert | vorhanden: [Projektauftrag](https://github.com/valITino/r3cosint/blob/3f939cea7749d9fbe1df9a7bbc90ff94efe95cb6/docs/00_Projektauftrag.md) |

## Einzelheiten je Arbeitsprodukt

**Stakeholderliste.** Absehbar sind mindestens: Ermittler des Dezernats
als Endbenutzer, Dezernatsleitung, Informatik der Kantonspolizei Bern,
kantonaler Datenschutzbeauftragter, Staatsanwaltschaft als Empfängerin der
Exporte, der Studienkollege, die betreuende Dozentur der FFHS. Die Liste
wird vom Requirements Engineer vervollständigt
[Abschnitt 6.3](https://github.com/valITino/r3cosint/blob/3f939cea7749d9fbe1df9a7bbc90ff94efe95cb6/docs/00_Projektauftrag.md).

**Glossar.** Für dieses Projekt überdurchschnittlich wichtig, weil
Begriffe teils rechtliche Bedeutung tragen: Der Unterschied zwischen
verdeckter Fahndung und verdeckter Ermittlung ist kein sprachlicher,
sondern entscheidet über Zulässigkeit. Zu definieren sind unter anderem
Fall, Entität, Alias-Profil, Schutzstufe, Ermittlung, Recherche, Export,
Beweismittel. Synonyme werden gekennzeichnet, Homonyme vermieden
[Abschnitt 6.3](https://github.com/valITino/r3cosint/blob/3f939cea7749d9fbe1df9a7bbc90ff94efe95cb6/docs/00_Projektauftrag.md).

**Product Backlog.** Jeder Eintrag wird einer der drei Anforderungsarten
nach IREB zugeordnet (funktionale Anforderung, Qualitätsanforderung,
Randbedingung), Qualitätsanforderungen messbar mit ISO/IEC 25010 als
Checkliste, Priorisierung ergänzt um das Kano-Modell. Randbedingungen aus
dem präskriptiven Teil werden nicht priorisiert, sie sind gesetzt
[Abschnitt 6.4](https://github.com/valITino/r3cosint/blob/3f939cea7749d9fbe1df9a7bbc90ff94efe95cb6/docs/00_Projektauftrag.md). Ein Eintrag darf
erst in einen Sprint, wenn er die Definition of Ready erfüllt (siehe
`scrum-aufbau.md`).

**Interaktiver Prototyp.** Methodisch ein exploratives Arbeitsprodukt zur
Validierung von Anforderungen im Sinne von IREB — das ist der Grund, warum
er vor dem Frontend steht, nicht nur ein praktischer
[Abschnitt 6.7](https://github.com/valITino/r3cosint/blob/3f939cea7749d9fbe1df9a7bbc90ff94efe95cb6/docs/00_Projektauftrag.md). Er ist als
Wegwerf-Prototyp festgelegt: Der Code wird nach der Freigabe nicht
weiterverwendet; weitergegeben werden Bildschirmfluss, Komponenteninventar,
Design-Tokens, Oberflächentexte, Review-Entscheide und der synthetische
Datenbestand [Abschnitt 5.6](https://github.com/valITino/r3cosint/blob/3f939cea7749d9fbe1df9a7bbc90ff94efe95cb6/docs/00_Projektauftrag.md).

**Projektauftrag.** Erste Baseline der Anforderungen. Jede spätere
freigegebene Fassung wird als neue Baseline gekennzeichnet, mit
Versionsnummer und fortgeführtem Änderungsprotokoll
[Abschnitt 6.6](https://github.com/valITino/r3cosint/blob/3f939cea7749d9fbe1df9a7bbc90ff94efe95cb6/docs/00_Projektauftrag.md).

## Verweise statt Kopien

Alle Nachweise aus diesem Repository auf Arbeitsprodukte im
Produkt-Repository verwenden feste Verweise mit vollständiger
Commit-Prüfsumme. Das Produkt-Repository führt dafür unter
`docs/NACHWEISE.md` ein erzeugtes Nachweisverzeichnis, das bei jedem
Meilenstein neu erzeugt wird [Abschnitt 6.6](https://github.com/valITino/r3cosint/blob/3f939cea7749d9fbe1df9a7bbc90ff94efe95cb6/docs/00_Projektauftrag.md).

## Offene Punkte

- Erledigt (2026-08-25 nachgeführt): Die Ablagepfade sind mit Schritt 3
  entstanden — `docs/02_Stakeholderliste.md`, `docs/03_Glossar.md`,
  `docs/04_Kontextmodell.md`, `docs/05_Product_Backlog.md`,
  `docs/06_Definition_of_Ready_und_Done.md` ([Definition of Ready und
  Done](https://github.com/valITino/r3cosint/blob/3a40faa87feac056cd7bfa7c0fdf3f5f77b761fb/docs/06_Definition_of_Ready_und_Done.md)); die Verweise oben sind nachgeführt.
- [OFFEN] Der benannte Verantwortliche für das Glossar ist noch nicht
  bestimmt.
- Erledigt (2026-08-25 nachgeführt): Das Nachweisverzeichnis
  `docs/NACHWEISE.md` existiert im Produkt-Repository, wird von
  `scripts/nachweise-erzeugen.sh` erzeugt und liegt als übertragene Kopie
  in diesem Repository unter `nachweise/NACHWEISE.md`.

## Verweise in diesem Dokument

Aufgelöst aus dem Nachweisverzeichnis (`nachweise/NACHWEISE.md`, Stand
`4c64300e9ec00fd1068964e14c2666c631d00dfa`):

- [Abschnitt 6.3](https://github.com/valITino/r3cosint/blob/3f939cea7749d9fbe1df9a7bbc90ff94efe95cb6/docs/00_Projektauftrag.md)
- [Abschnitt 6.4](https://github.com/valITino/r3cosint/blob/3f939cea7749d9fbe1df9a7bbc90ff94efe95cb6/docs/00_Projektauftrag.md)
- [Abschnitt 6.6](https://github.com/valITino/r3cosint/blob/3f939cea7749d9fbe1df9a7bbc90ff94efe95cb6/docs/00_Projektauftrag.md)
- [Abschnitt 6.7](https://github.com/valITino/r3cosint/blob/3f939cea7749d9fbe1df9a7bbc90ff94efe95cb6/docs/00_Projektauftrag.md)
- [Abschnitt 5.6](https://github.com/valITino/r3cosint/blob/3f939cea7749d9fbe1df9a7bbc90ff94efe95cb6/docs/00_Projektauftrag.md)
- [Abschnitt 1.3](https://github.com/valITino/r3cosint/blob/3f939cea7749d9fbe1df9a7bbc90ff94efe95cb6/docs/00_Projektauftrag.md)
- [Abschnitt 2](https://github.com/valITino/r3cosint/blob/3f939cea7749d9fbe1df9a7bbc90ff94efe95cb6/docs/00_Projektauftrag.md)
- [Projektauftrag](https://github.com/valITino/r3cosint/blob/3f939cea7749d9fbe1df9a7bbc90ff94efe95cb6/docs/00_Projektauftrag.md)

Der Eintrag "Prototyp Demo" ist seit dem 2026-08-21 im Nachweisverzeichnis
(Nachweislücke geschlossen, siehe Produkt-Repository,
`docs/uebergaben/2026-08-21_nachweisluecke-prototyp-demo.md`):

- [Prototyp Demo](https://github.com/valITino/r3cosint/blob/783081fe6d13fef8ab89bc9d5f62d3e2e368716a/prototype/OSINT_Plattform_Demo.html)
