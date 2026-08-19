---
paths:
  - "prototype/**"
---

# Regeln für den Prototyp

Grundlage: Projektauftrag 5.6. Diese Regeln gelten für alles unter `prototype/`.

## Der Prototyp ist Wegwerf-Code
- Sein Code wird nach der Freigabe **nicht** weiterverwendet (5.6, FESTGELEGT).
- Weiter gehen nur: Bildschirmfluss und Navigationsstruktur, Komponenteninventar,
  Design-Tokens für Farben, Abstände und Typografie, die Oberflächentexte, die
  Review-Entscheidungen als Kurzprotokoll sowie der synthetische Datenbestand.
- Der synthetische Datenbestand wird später Grundlage der Testdaten. Das ist eine
  Übernahme von Daten, nicht von Code.

## Keine Importe in beide Richtungen
- Produktionscode importiert nichts aus `prototype/`.
- Der Prototyp importiert nichts aus dem Produktionscode.
- Keine gemeinsamen Abhängigkeiten.
- Ein `PreToolUse`-Hook blockiert beide Richtungen; siehe
  `.claude/hooks/block-prototype-import.sh`.

## Die bestehende Demo wird ergänzt, nicht ersetzt
`OSINT_Plattform_Demo.html` enthält abgestimmte Gestaltungsentscheidungen. Sie
werden nicht ohne Anlass verworfen. Vorhanden sind sechs Ansichten: Ermittlung,
Verlauf, Export in die Akte, Werkzeuge, Gesichtsvergleich, Einstellungen.

Zu ergänzen sind laut 5.6: Anmeldung und Setup, Fallübersicht mit Aufgaben und
Kommentaren (5.8), API-Schlüsselverwaltung (5.13), Diagnosebereich (5.12),
Malware- und Reverse-Engineering-Bereich (5.14).

Die Ansicht "Gesichtsvergleich" bleibt in der Demo unangetastet, wird aber nicht
in die Anwendung überführt (5.18).

## Synthetische Daten — verbindlich
- Keine realen Personen, Adressen, Telefonnummern, E-Mail-Adressen oder
  Social-Media-Konten.
- Telefonnummern aus reservierten Nummernbereichen, Domains aus den dafür
  vorgesehenen Beispiel-Domains.
- Erzeugung über einen Generator mit festem Startwert. Der Generator wird
  versioniert, der erzeugte Datenbestand nicht.
- Dauerhaft sichtbarer Hinweis in der Oberfläche: Demonstrationszweck,
  synthetische Daten.

## Definition of Done des Prototyps
Maschinell prüfbar: Der Prototyp baut fehlerfrei, jede Ansicht ist über die
Navigation erreichbar, es gibt keine toten Verweise oder Sackgassen, die
automatisierte Prüfung nach WCAG 2.2 AA läuft ohne Fehler durch.

Menschliches Gate: Auftraggeber und Studienkollege gehen jeden Bereich durch und
geben schriftlich frei. Das ist die **einzige** Ausnahme von der Regel, dass das
Abbruchkriterium ein Rückgabewert sein muss (3.4). Sie gilt nur hier.
