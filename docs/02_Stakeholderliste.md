# Stakeholderliste

| | |
|---|---|
| **Arbeitsprodukt nach** | Projektauftrag 6.3 |
| **Verantwortlich** | Requirements Engineer |
| **Lebensdauer** | sich weiterentwickelnd |
| **Stand** | 2026-08-19, Erstfassung |

Pflichtangaben je Stakeholder nach 6.3: Name, Funktion und Rolle, Kontakt,
Verfügbarkeit, Relevanz, Fachgebiet, Ziele und Interessen.

**Zu Namen und Kontaktangaben.** Diese Fassung führt die Stakeholder nach
Funktion. Namen, Kontakt und Verfügbarkeit trägt der Auftraggeber nach; sie
werden hier nicht erfunden. Personenbezogene Angaben gehören nicht in das
öffentliche Repository, sofern der Auftraggeber nichts anderes bestimmt —
gegebenenfalls ist diese Datei auf Funktionsangaben zu beschränken und die
Kontaktliste getrennt zu führen.

Relevanz nach Einfluss auf das Ergebnis: **hoch** (kann das Vorhaben stoppen
oder umlenken), **mittel** (liefert bindende Anforderungen), **gering**
(betroffen, aber ohne Entscheidungsbefugnis).

---

## S-01 — Auftraggeber und Ermittler Cybercrime

| Feld | Angabe |
|---|---|
| Name | *nachzutragen* |
| Funktion und Rolle | Ermittler im Bereich Cybercrime, Kantonspolizei Bern; im Projekt Auftraggeber und Product-Owner-Gegenüber |
| Kontakt | *nachzutragen* |
| Verfügbarkeit | 7 bis 10 Stunden pro Woche (6.8) |
| Relevanz | hoch |
| Fachgebiet | Ermittlungspraxis, OSINT-Werkzeuge, Ablauf im Dezernat |
| Ziele und Interessen | Ein Werkzeug für den echten Einsatz, nicht für die Ablage. Lückenlose Herkunftsdokumentation, weil sie im Verfahren am ehesten trifft (1.1). Behält die Kontrolle: nichts wird automatisch gelöscht (4.4), keine Abfrage ohne Freigabe (5.2) |
| Entscheidet über | Freigabe-Gate Schritt 4, Prototyp-Freigabe (5.6), Punkt 7 der Bereitschaftsliste (5.16) |

## S-02 — Studienkollege

| Feld | Angabe |
|---|---|
| Name | *nachzutragen* |
| Funktion und Rolle | Zweiter Studierender, Review und Feinschliff |
| Kontakt | *nachzutragen* |
| Verfügbarkeit | 7 bis 10 Stunden pro Woche (6.8) |
| Relevanz | hoch |
| Fachgebiet | *nachzutragen* |
| Ziele und Interessen | Prüfbare Inkremente in der zur Verfügung stehenden Zeit; erfolgreiche Studienleistung |
| Entscheidet über | Prototyp-Freigabe gemeinsam mit S-01 (5.6) |

## S-03 — Ermittelnde des Dezernats (Endbenutzer)

| Feld | Angabe |
|---|---|
| Name | Gruppe, namentlich über S-01 erreichbar |
| Funktion und Rolle | Tägliche Anwender; Rollen Fallverantwortlicher, Ermittler, Leser (5.8) |
| Kontakt | über S-01 |
| Verfügbarkeit | punktuell, im Rahmen von Reviews und Schulung |
| Relevanz | hoch |
| Fachgebiet | Ermittlungsarbeit, heutiger Ablauf mit Maltego und Einzelwerkzeugen |
| Ziele und Interessen | Kein Abtippen zwischen Werkzeugen; ein gemeinsames Lagebild statt zwölf Browser-Tabs; der eigene MISP-Bestand wird automatisch mitgeprüft |
| Achtung | Alle Dezernatsangehörigen sind Fallbearbeiter und haben Zugriff auf die Fälle des Dezernats — Standardzustand, nicht Ausnahme (5.8) |

## S-04 — Dezernats- beziehungsweise Gruppenleitung

| Feld | Angabe |
|---|---|
| Name | *nachzutragen* |
| Funktion und Rolle | Fachliche Führung, Beschaffungsentscheide |
| Kontakt | *nachzutragen* |
| Verfügbarkeit | *nachzutragen* |
| Relevanz | hoch |
| Fachgebiet | Ressourcen, Priorisierung, Zusammenarbeit mit anderen Stellen |
| Ziele und Interessen | Nutzen gegenüber Kosten; kein unkontrollierter Kontingentverbrauch (5.4); Bestätigung der Fristenwerte im Bearbeitungsreglement (4.4) |
| Entscheidet über | Fallkategorien und Aufbewahrungswerte (4.4, Punkt 6), Beschaffung lizenzierter Quellen |

## S-05 — Informatik der Kantonspolizei Bern

| Feld | Angabe |
|---|---|
| Name | *nachzutragen* |
| Funktion und Rolle | Betrieb der Infrastruktur, Identitätsverwaltung über Entra ID |
| Kontakt | *nachzutragen* |
| Verfügbarkeit | *nachzutragen*, voraussichtlich gering |
| Relevanz | mittel |
| Fachgebiet | Netz, Serverbetrieb, SSO, Informationsschutz |
| Ziele und Interessen | Betreibbarkeit, Einhaltung der internen Vorgaben |
| Liefert | Die sieben Angaben aus der Tabelle in 5.7: Tenant-ID und Discovery-URL, Client-ID und Geheimnis, Redirect-URIs je Umgebung, Scopes und Claims, Träger der Rolleninformation, eindeutiges Benutzermerkmal, MFA-Richtlinie |
| Offener Punkt | C-Rest in 7.2. Blockiert nur den Wechsel vom lokalen OIDC-Provider auf den echten Mandanten, nicht die Entwicklung |

## S-06 — Kantonaler Datenschutzbeauftragter

| Feld | Angabe |
|---|---|
| Name | *nachzutragen* |
| Funktion und Rolle | Aufsicht über die Datenbearbeitung |
| Kontakt | *nachzutragen* |
| Verfügbarkeit | auf Anfrage |
| Relevanz | hoch |
| Fachgebiet | KDSG, Bearbeitungsverzeichnis, Folgenabschätzung, Löschung |
| Ziele und Interessen | Zweckbindung, Verhältnismässigkeit, dokumentierte Löschentscheide. Der erste Punkt einer Prüfung ist, ob nicht mehr benötigte Personendaten vernichtet werden (4.4) |
| Wirkt auf | Punkt 4 und 5 der Bereitschaftsliste (5.16) |

## S-07 — Staatsanwaltschaft

| Feld | Angabe |
|---|---|
| Name | wechselnd je Verfahren |
| Funktion und Rolle | Empfängerin der Exporte, Verfahrensleitung |
| Kontakt | über S-01 |
| Verfügbarkeit | verfahrensabhängig |
| Relevanz | hoch |
| Fachgebiet | StPO, Verwertbarkeit, Anklageerhebung |
| Ziele und Interessen | Nachvollziehbarkeit beider Spuren; klare Trennung zwischen Erhobenem und Gefolgertem; belegbare Herkunft ein Jahr später (5.3) |
| Achtung | Die Arbeitsspur ist ausdrücklich auch für Verteidigung, Gericht und Aufsicht bestimmt (5.3) |

## S-08 — Verteidigung und Gericht (mittelbar)

| Feld | Angabe |
|---|---|
| Name | wechselnd je Verfahren |
| Funktion und Rolle | Prüfen die Ergebnisse, ohne am Projekt beteiligt zu sein |
| Kontakt | kein direkter |
| Verfügbarkeit | keine |
| Relevanz | hoch für die Anforderungen, ohne Mitwirkung |
| Fachgebiet | Beweiswürdigung |
| Ziele und Interessen | Vollständigkeit einschliesslich der Negativbefunde; Nachweis, dass keine Abfrage ohne menschlichen Entscheid lief; unversehrte Prüfkette (5.3) |
| Achtung | Dieser Stakeholder kann nicht befragt werden. Seine Anforderungen sind aus 5.3 und 5.10 abgeleitet und dürfen nicht wegverhandelt werden |

## S-09 — Betreuende Dozentur der FFHS

| Feld | Angabe |
|---|---|
| Name | *nachzutragen* |
| Funktion und Rolle | Betreuung und Bewertung der Studienleistung |
| Kontakt | *nachzutragen* |
| Verfügbarkeit | nach Studienplan |
| Relevanz | mittel |
| Fachgebiet | Methodik, Requirements Engineering nach IREB, Scrum |
| Ziele und Interessen | Nachvollziehbare methodische Herleitung; sichtbare Anwendung von IREB CPRE FL v3.3.0 und Scrum Guide 2020 (6.1) |
| Achtung | Adressat von Repo B (`r3coscrum`). Repo B enthält keine Kopien, sondern feste Verweise (1.3, 6.6) |

## S-10 — Betroffene Personen der Datenbearbeitung

| Feld | Angabe |
|---|---|
| Name | nicht bestimmbar |
| Funktion und Rolle | Personen, deren Daten bearbeitet werden — beschuldigt, geschädigt oder unbeteiligt |
| Kontakt | keiner |
| Verfügbarkeit | keine |
| Relevanz | hoch für die Anforderungen, ohne Mitwirkung |
| Fachgebiet | — |
| Ziele und Interessen | Verhältnismässigkeit, Zweckbindung, Löschung nicht mehr benötigter Daten, Auskunftsrecht nach KDSG (4.4) |
| Achtung | Vertreten durch S-06. Ihre Interessen werden über die präskriptiven Anforderungen abgebildet, nicht über Beteiligung |

## S-11 — Betreiber der externen Quellen

| Feld | Angabe |
|---|---|
| Name | Shodan, DomainTools, HIBP, abuse.ch, urlscan.io, Chainalysis und weitere nach Anhang A |
| Funktion und Rolle | Liefern Daten, setzen Nutzungsbedingungen |
| Kontakt | über Vertrag oder Support |
| Verfügbarkeit | keine Mitwirkung |
| Relevanz | mittel |
| Fachgebiet | Eigene Nutzungsbedingungen und Kontingente |
| Ziele und Interessen | Vertragskonforme Nutzung; Schlüsselweitergabe nur im erlaubten Rahmen (5.17) |
| Achtung | Jede Abfrage nach aussen ist eine Bekanntgabe — man teilt einem Dritten mit, wofür man sich interessiert (5.17). VirusTotal ist gestrichen (5.17) |

---

## Was noch fehlt

| Nr. | Fehlende Angabe | Wer liefert |
|---|---|---|
| 1 | Namen, Kontakte und Verfügbarkeit zu S-01 bis S-06 und S-09 | Auftraggeber |
| 2 | Entscheid, ob personenbezogene Kontaktangaben in dieses Repository dürfen | Auftraggeber |
| 3 | Ob eine Vertretung der Ermittelnden (S-03) benannt wird, die stellvertretend an Reviews teilnimmt | Auftraggeber |
