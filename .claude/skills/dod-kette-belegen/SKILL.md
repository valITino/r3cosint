---
name: dod-kette-belegen
description: "Wird gebraucht, bevor eine Rolle eine Arbeitseinheit als fertig meldet. Legt fest, wie eine Fertigmeldung belegt wird: den Befehl benennen, ihn frisch ausführen, Ausgabe UND Rückgabewert lesen, die Lage benennen, erst dann behaupten."
metadata:
  anforderung: R3-Q-001
  auftrag: "3.4 (Definition-of-Done-Befehlskette), 5.3 (Negativbefunde)"
  adr: docs/adr/0002-architekturentscheid-ziel-stack.md
---

# Die Definition-of-Done-Kette belegen

## Wann diese Prozedur gilt

Vor jeder Fertigmeldung, von jeder Rolle. Solange die Gates aus R3-Q-001 nicht
stehen, prüft das menschliche Review die Befehlskette — bis dahin ist jede
Fertigmeldung eine Behauptung ohne Mechanismus, und diese Prozedur ist das
Einzige, was zwischen der Behauptung und dem Nachweis steht.

## Der Kernablauf

1. **Den Befehl benennen, der die Behauptung belegt.** In aller Regel
   `make dod`, der eine Einstieg in die Kette. Wird ein einzelner Schritt
   gemeint, wird er benannt: `make linter`, `make test`.
2. **Frisch ausführen.** Nicht ein Ergebnis von vorhin wiederverwenden. Der
   Bestand hat sich seither geändert — sonst gäbe es nichts zu melden.
3. **Ausgabe UND Rückgabewert lesen.** Der Rückgabewert allein genügt nicht,
   die Ausgabe allein auch nicht. Eine Kette kann mit 0 enden und nichts
   geprüft haben; genau dagegen ist sie gebaut.
4. **Die Lage je Schritt benennen** — A, B oder C, siehe unten.
5. **Erst dann behaupten.** "Fertig" ist eine Aussage über einen ausgeführten
   Befehl, nicht über ein Gefühl.

## Die drei Lagen

| Lage | Was sie bedeutet | Was sie für den Rückgabewert heisst |
|---|---|---|
| **A** | Der Prüfer lief. Er ist bestanden oder durchgefallen — beides ist Lage A | 0 bei bestanden, ungleich 0 bei durchgefallen |
| **B** | Es gibt nichts zu prüfen. Der Gegenstand existiert nicht | 0 — und das ist keine Beschönigung, sondern die Wahrheit |
| **C** | Der Gegenstand existiert, aber das Prüfmittel fehlt | **Ungleich 0.** Hier 0 zu melden, wäre eine Lüge und ist untersagt |

Lage C ist der **Negativbefund der Kette** im Sinn von 5.3: "konnte nicht
geprüft werden" ist ein Ergebnis und gehört in den Nachweis. Wer sie zu 0
verkürzt, streicht genau die Aussage, die 5.3 zwingend verlangt.

Der häufigste stille Fehler ist die Verwechslung von A und B: Ein Schritt
meldet "nichts zu prüfen", obwohl der Gegenstand da ist. Deshalb wird die Lage
gelesen, nicht nur der Rückgabewert.

## Was "grün" heisst

`make dod` ist grün, wenn **alle drei** Bedingungen gelten:

- Rückgabewert 0.
- Je Kettenschritt **genau eine** Lage-Marke. Mehr als eine ist selbst ein
  Befund — ein Werkzeug, das eine markenförmige Zeile ausgibt, gewönne sonst
  gegen die echte Marke.
- Keine Marke trägt Lage C.

Fehlt eine dieser Bedingungen, ist der Lauf nicht grün, unabhängig davon, wie
die Ausgabe aussieht.

## Was der Lauf nicht verändern darf

Ein Prüflauf verändert den Gegenstand nicht, über den er urteilt. Die
Rahmenprüfung D19 beobachtet das: Sie nimmt vor und nach dem Lauf die
Prüfsummen aller versionierten Dateien und die Maskierungsmerkmale des Index
auf. Wer einen Schritt so baut, dass er eine Datei schreibt — eine Sperrdatei,
ein Nachweisverzeichnis —, hebt die Aussage des Laufs auf.

## Wenn es dreimal am gleichen Kriterium scheitert

Nicht die vierte Runde am Einzelfall beginnen. Abbrechen, die Übergabedatei
schreiben, die Aufgabe vorlegen (3.4). Und in der Übergabe nicht die drei
Einzelfälle aufzählen, sondern das **Muster** benennen, das sie erzeugt hat.
Wer nur die Einzelfälle aufschreibt, legt die vierte Runde an.

## Zwei Sätze, die diese Kette teuer gelernt hat

- **Die Kette misst zu leicht die Verfügbarkeit eines Namens statt die
  Anwesenheit des Gegenstands.** Ein Werkzeug im Suchpfad ist nicht dasselbe
  wie ein Werkzeug im gesperrten Umfeld; ein Verzeichnis `.git` ist nicht
  dasselbe wie ein Repository; ein Dateiname ist nicht dasselbe wie sein
  Inhalt. Wer einen Schritt baut, prüft zuerst, woran er die Lage festmacht.
- **Eine Abgrenzung ist keine Erlaubnis.** Was sich schliessen lässt, wird
  geschlossen; abgegrenzt wird nur, was sich mit den Mitteln des Artefakts
  nicht schliessen lässt. Eine benannte Lücke bleibt eine Lücke.
