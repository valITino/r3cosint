---
paths:
  - "docs/recht/**"
  - "docs/datenschutz/**"
  - "docs/konformitaet/**"
---

# Regeln für die rechtlichen Arbeitsprodukte

Grundlage: Projektauftrag 4.4. Dieser Teil ist **präskriptiv** (6.2): Er wird
nicht neu priorisiert und nicht verhandelt, sondern nur terminiert.

## Was diese Arbeitsprodukte leisten — und was nicht
Eine Software kann nicht "gültig für den Polizeieinsatz" sein. Über die
Zulässigkeit einer Ermittlungsmassnahme entscheidet die Rechtsgrundlage im
Einzelfall, nicht das Werkzeug. Geliefert wird eine dokumentierte
Konformitätsanalyse: welche Rechtsgrundlagen für welche Funktion einschlägig
sind, welche Anforderungen daraus folgen, wie diese technisch umgesetzt sind und
welche Punkte einer behördlichen Prüfung bedürfen. Grundlage für eine Prüfung,
nicht deren Ergebnis.

## Prioritätsordnung der Rechtsregime (4.4)

| Prio | Erlass | Gilt für |
|---|---|---|
| 1a | StPO (Bund) | Daten innerhalb eines hängigen Strafverfahrens; das kantonale Datenschutzgesetz ist hier ausdrücklich nicht anwendbar |
| 1b | PolG/BE, BSG 551.1 | Polizeiliche Datenbearbeitung ausserhalb eines hängigen Verfahrens |
| 2 | KDSG, BSG 152.04 | Allgemeiner kantonaler Rahmen, subsidiär |
| 3 | Einführungsverordnung zur EU-Richtlinie 2016/680 | Schengen-relevante Bearbeitung |
| 4 | Archivierungsgesetz und -verordnung BE | Nach Ende des Betriebszwecks |
| — | revDSG des Bundes | Für kantonale Organe **nicht** direkt anwendbar, nicht heranziehen |

Ein Fall trägt sein Regime ab der Eröffnung. Ohne dieses Feld lässt sich später
nicht sagen, welche Löschregel für ihn gilt.

## Belegpflicht
Jede Aussage wird mit Fundstelle geführt. Wo keine tragfähige Grundlage besteht,
wird das hingeschrieben, statt eine zu konstruieren.

Zu verifizieren, bevor Artikelnummern verwendet werden: Stand des Inkrafttretens
der KDSG-Totalrevision (zweite Lesung am 3. Dezember 2025) und die
Artikelnummern der geltenden Fassung.

## Aufbewahrung: nichts wird automatisch gelöscht
Es gibt keine nachschlagbare kantonale Frist; das Gesetz delegiert die
Festlegung an die Behörde. Umgesetzt wird:

> **Nichts wird automatisch gelöscht. Aber kein Fall bleibt ohne Entscheid.**

Eine Frist löst nie eine Löschung aus, sondern eine **Aufgabe** an den
Fallverantwortlichen. Fristen laufen ab Fallabschluss, nie ab Erstellung. Die
Startwerte orientieren sich an der Verfolgungsverjährung nach Art. 97 StGB und
sind konfigurierbare betriebliche Voreinstellungen, keine rechtliche Festlegung.
Die Löschsperre verhindert eine Löschung unabhängig von jeder Frist.

## Was diese Rollen nicht tun
Betriebliche Festlegungen des Auftraggebers werden nicht in Frage gestellt. Das
Zugriffsmodell auf Dezernatsebene (5.8) ist gesetzt; Aufgabe ist, es sauber zu
dokumentieren — Zweckbindung, Bearbeitungsverzeichnis, Aufbewahrung — nicht, es
zu bewerten. Geschlossene Entscheide werden nicht neu aufgerollt (5.11, 5.17,
5.18).

## Ausdrücklich schriftlich festzuhalten (4.4)
Die Abgrenzung zwischen dem Bundesgerichtsentscheid vom August 2026 zur Löschung
von Nichttreffern und der Vorgabe aus 5.3, dass Negativbefunde zwingend im
Protokoll erscheinen. Beides widerspricht sich nicht — dort massenhaft erhobene
Daten unbeteiligter Personen, hier eine dokumentierte Abfrage innerhalb eines
konkreten Falls. Die Frage wird im Verfahren mit hoher Wahrscheinlichkeit
gestellt; eine vorbereitete Antwort ist besser als eine improvisierte.
