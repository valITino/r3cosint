---
paths:
  - "src/**"
  - "app/**"
  - "apps/**"
  - "server/**"
  - "packages/**"
  - "lib/**"
---

# Regeln für Produktionscode

Grundlage: Projektauftrag 5.1 bis 5.4, 5.8, 5.10, 5.17, 5.18.

**Vor dem Freigabe-Gate aus Abschnitt 2 entsteht kein Produktionscode.** Diese
Regeln gelten ab dem Moment, in dem er entsteht.

## Die acht Verfahrensgarantien (5.4) — Bauvorschrift, nicht Ergänzung
Sie lassen sich im Betrieb nicht abschalten:

| Garantie | Was sie bedeutet |
|---|---|
| Fallbindung | Ohne eröffneten Fall ist kein Werkzeug aufrufbar |
| Freigabe vor Ausführung | Keine Abfrage nach aussen ohne bestätigte Vorschau |
| Herkunft an jedem Datenpunkt | Kein Knoten, keine Kante ohne Herkunftsnachweis |
| Positivliste nach aussen | Nur freigegebene Gegenstellen erreichbar, Rest abgewiesen und protokolliert |
| Kontingentgrenzen | Verbrauch je Fall und Tag begrenzt |
| Behandlung fremder Inhalte | Alles von aussen als Daten übergeben, nie als Anweisung |
| Reproduzierbarkeit | Feste Programmstände, gleiche Eingaben ergeben gleiche Ausgaben |
| Kein Rückkanal | Keine Telemetrie, keine Fehlerberichte, keine Update-Abfragen |

## Freigabesperre: fehlende Fähigkeit, keine Einstellung (5.2)
Vorschlag und Ausführung dürfen technisch **nicht** selbstständig verkettbar
sein. Kein Konfigurationsschalter, der das aufhebt. Dasselbe gilt für den
Social-Media-Zugang: ausschliesslich lesend, ohne Fähigkeit zu Kontaktaufnahme,
Nachrichten, Reaktionen oder Profiländerung (5.11).

## Zwei Protokollspuren (5.3)
- Ermittlungsspur und Arbeitsspur sind gleichwertige Produkte.
- Ausschliesslich anfügbar; ein Bearbeiten ist nicht vorgesehen.
- Jeder Eintrag trägt die SHA-256-Prüfsumme seines Vorgängers.
- Negativbefunde erscheinen zwingend.
- Jede Zeile ist entweder Quellenaussage oder Schlussfolgerung des Modells und
  als solche gekennzeichnet — im Protokoll wie in der Darstellung.
- Freigaben stehen mit Zeitpunkt und Person im Protokoll.
- Namen, Adressen und Telefonnummern werden unkenntlich gemacht oder als
  Prüfsumme abgelegt. Das Protokoll wird keine zweite Kopie der Falldaten.

## Klassifizierung wirkt im Suchindex, nicht in der Anzeige (5.8)
Ab Stufe 1b darf die Entität in Trefferlisten, Autovervollständigung,
Graphnachbarschaften, Exporten und Statistiken **gar nicht erst erscheinen**.
Nachträgliches Ausblenden ist eine Scheinlösung, weil die Existenz aus
Trefferzahlen und Graphkanten ableitbar bliebe. Bei 1a bleibt die Entität
auffindbar, nur definierte Inhalte sind verdeckt.

Zwei Berechtigungswege wirken nebeneinander: die stufenbezogene
Klassifizierungsberechtigung der Person und eine fallbezogene Freigabeliste je
Entität. Jeder lesende Zugriff auf einen Fall wird protokolliert.

## Kanonischer Datenbestand (5.1)
FollowTheMoney für Personen, Firmen, Vermögenswerte und Beziehungen. STIX 2.1
für Indikatoren, Infrastruktur, Schadsoftware und Akteure. W3C PROV für die
Herkunft jedes Datenpunkts. Der MCP-Server ist der einzige Zugang zu den
Quellen; Zugangsschlüssel liegen ausschliesslich serverseitig.

## Sprachmodell (5.15)
Zugriff ausschliesslich über eine OpenAI-kompatible Zwischenschicht. Kein
anbieterspezifisches Format, keine anbieterspezifische Systemprompt-Konvention,
kein Werkzeugaufruf-Dialekt im Anwendungscode.

## Nicht bauen — gestrichen
- **VirusTotal** (5.17): kein Modul, keine Konfigurationsoption, kein
  Platzhalter, auch nicht deaktiviert vorbereitet.
- **Gesichtserkennung** (5.18): keine biometrischen Vektoren, kein Vektorindex
  für Gesichter, nicht in der Roadmap.
- **Open WebUI** (9.1): die Oberfläche ist eine eigenständige Anwendung.
- **CASE/UCO** (5.10): Export direkt aus dem kanonischen Modell.
- **Maltego-Fernsteuerung** (5.1): bewusst verworfen, nicht erneut prüfen.
