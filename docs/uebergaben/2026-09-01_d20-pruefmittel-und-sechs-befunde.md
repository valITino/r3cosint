# Übergabe 2026-09-01 — D20: die Prüfmittel, die niemand prüfte

Arbeitseinheit: unabhängige Prüfung der D20-Einbindung, Behebung der Befunde,
Nachführung von Architekturentscheid und Definition of Done.

## Ausgangslage

Am 2026-09-01 war der Belegprüfer als Kettenschritt D20 in `make dod`
eingebunden (Fortschreibungen 6.8 bis 6.10 des Architekturentscheids). Nach
Abschnitt 3.4 des Projektauftrags prüft die umsetzende Rolle ihre eigene Arbeit
nicht, und ein modellbasierter Prüfschritt läuft auf einem anderen Modell als
die Umsetzung. Drei Rollen haben deshalb unabhängig geprüft — Static Software
Tester, Dynamic Software Tester und Protocol Master, alle drei auf einem anderen
Modell als die Umsetzung.

## Der blockierende Befund

Der Architekturentscheid nannte an zwei Stellen und die Definition of Done an
einer dritten **sechs Prüfmittel**, deren Ausfall die Lage C ergeben sollte:
`git`, den Arbeitsbaum, `scripts/belege-pruefen.sh`, `scripts/belege-ausnahmen.txt`
sowie die beiden Bezugsdokumente `docs/05_Product_Backlog.md` und
`docs/00_Projektauftrag.md`.

Geprüft hat der Code **drei**. Das Ziel `belege` im `Makefile` fragte nach dem
Skript, nach `git` und nach dem Arbeitsbaum. Nach den beiden Bezugsdokumenten
und nach der Ausnahmeliste fragte weder das Ziel noch das Skript.

Was daraus folgt, ist nicht "eine Prüfung fehlt", sondern etwas Schlimmeres.
`set -uo pipefail` ohne `-e` lässt `mapfile` über eine fehlende Datei mit
Rückgabewert 0 laufen. Die Referenzmenge bleibt leer, und danach gilt jede
gültige Anforderungskennung im ganzen Bestand als ungültig. Der Schritt wäre
rot — aber mit hunderten Scheinfunden statt der einen richtigen Aussage "das
Prüfmittel fehlt". Genau diesen Fehlermodus beschreibt der Architekturentscheid
an der Stelle, an der er die Prüfung zusagt, als vermieden.

Das ist am 2026-09-01 in einem isolierten Lauf nachgestellt und gemessen worden,
bevor eine Zeile geändert wurde.

## Was behoben ist

**Der Belegprüfer kennt drei Rückgabewerte statt zwei.** 0 heisst keine
Beanstandung, 2 heisst mindestens ein Befund am Bestand, **3 heisst Lage C**.
Die Trennung von 2 und 3 ist die eigentliche Sache: "rot, weil etwas gefunden
wurde" und "rot, weil nicht gemessen werden konnte" sind verschiedene Aussagen,
und das `Makefile` führt sie getrennt weiter — als A_FAIL beziehungsweise als
Lage C.

**Alle sechs Prüfmittel werden geprüft**, im Ziel `belege` vorab und im Skript
vor jeder Verwendung. Für die beiden Bezugsdokumente gilt zusätzlich der zweite
Teil der geschärften Lage C: Vorhandensein genügt nicht, sie müssen eine nicht
leere Referenzmenge hergeben. Ein Backlog ohne eine einzige Anforderungskennung
als Überschrift ist derselbe Ausfall wie ein fehlender. Für die Ausnahmeliste
gilt das ausdrücklich nicht — eine vorhandene, leere Liste ist ein zulässiger
Zustand, es gibt dann eben keine Ausnahmen; nur eine fehlende Liste ist Lage C,
weil sie jede begründete Ausnahme stumm wegfallen liesse.

Drei ausgeführte Gegenproben, der Arbeitsbaum jeweils vorher und nachher gleich:
Ausnahmeliste beiseitegelegt, Backlog beiseitegelegt, Backlog vorhanden aber
ohne jede Kennung. Alle drei ergeben Lage C, das Skript allein endet mit
Rückgabewert 3.

## Fünf nachrangige Befunde, ebenfalls behoben

1. **`wc -l` zählte Zeilenumbrüche statt Zeilen.** Einer Datei ohne
   abschliessenden Umbruch fehlte in der Zählung die letzte Zeile, und ein
   richtiger Verweis auf genau diese Zeile wäre fälschlich ein Fund geworden —
   ein Fehlalarm, also die entgegengesetzte Fehlerrichtung zu den drei
   bisherigen Prüfrunden. Im damaligen Bestand latent, weil alle erfassten
   Dateien mit einem Umbruch enden; der Static Software Tester hat das für alle
   67 einzeln gemessen. Ersetzt durch `awk 'END{print NR+0}'`, gegengeprobt:
   drei Zeilen ohne Schlussumbruch ergeben bei `wc -l` zwei, bei `awk` drei.

2. **Zwei Aufzählungen der Ausführungsreihenfolge im `Makefile` waren
   veraltet** — D20 fehlte in beiden, obwohl er als erster Schritt läuft. Der
   eine Absatz warnt wörtlich davor, die Reihenfolge ein zweites Mal
   aufzuzählen, "die bei der naechsten Fortschreibung erneut veralten koennte",
   und führte im selben Absatz eine solche Aufzählung. Beide sind **gestrichen,
   nicht nachgeführt**: eine nachgeführte Aufzählung ist beim nächsten Schritt
   wieder falsch, eine gestrichene kann nicht falsch werden.

3. **Die Lagetabelle im Kopf des `Makefile` führte D20 nicht.** Zeile ergänzt.

4. **Doppeltes Leerzeichen in zwei D7-Meldungen**, aus `tr '\n' ' '` auf einem
   Einzeltreffer. Beide Pfade beschnitten und je durch einen ausgeführten Lauf
   nachgemessen. Anmerkung für später: der erste Versuch schrieb den
   Zeilenende-Anker als vier Dollarzeichen, was `make` zu zwei zusammenzieht und
   die Shell als Prozessnummer liest. Erst der ausgeführte Lauf hat das gezeigt.

5. **Der D19-Zweig für den stummgeschalteten Index sagte nicht, was die andere
   Hälfte in diesem Lauf gemessen hat**, obwohl der Architekturentscheid genau
   das zusagt. Er gab den allgemeinen Messbefund aus und schwieg über den Lauf.
   Schweigen ist keine Messung. Der Code ist an die Zusage herangeführt worden,
   nicht die Zusage abgeschwächt — mit dem ausdrücklichen Zusatz, dass die
   Gleichheit beider Aufnahmen den Lauf nicht entlastet, weil sie nicht
   ausschliessen kann, was die blinde Hälfte gar nicht meldet.

## Eine Lücke geschlossen

Die dynamische Prüfung hat offengelassen, ob D19 eine **während des Laufs**
vorgenommene Änderung tatsächlich meldet — beobachtet war nur der Erfolgsfall.
Der Koordinator hat das nachgeholt: `make dod` im Hintergrund gestartet, nach
drei Sekunden eine verfolgte Datei geändert. D19 meldet "VERLETZT", nennt die
Datei und zeigt **beide** Hälften des Instruments, die Statuszeile und die
geänderte Inhaltsprüfsumme. Damit ist erstmals belegt, dass D19 nicht nur
schweigt, wenn nichts ist, sondern auch spricht, wenn etwas ist.

## Was das Muster sagt

Dies ist die **vierte Stufe derselben Fehlerklasse** in diesem Projekt:

1. Die Kette mass die Verfügbarkeit eines Namens statt der Anwesenheit des
   Gegenstands.
2. Sie mass eine Liste von Namen statt des Inhalts.
3. Sie mass den Gegenstand, ohne dass feststand, dass das Messmittel misst.
4. Und nun: der Text benennt ein Messmittel, nach dem niemand fragt.

Jede Stufe wurde erst sichtbar, nachdem die vorherige behoben war. Das ist keine
Nachlässigkeit, sondern die Bauart des Problems, und es ist der Grund, weshalb
V11 gilt: Eine Behebung ist nicht fertig, wenn der Befund weg ist, sondern wenn
die Schicht geprüft ist, die sie neu erreichbar gemacht hat.

## Offen

- **Die Abnahme des Belegprüfers steht weiterhin aus.** Er ist nach
  Eskalationsregel 3.4 abgebrochen und in die Kette aufgenommen, ohne abgenommen
  zu sein; das ist im Architekturentscheid als eigener Entscheid festgehalten.
  Diese Prüfrunde ist der statische und der dynamische Teil dieser Abnahme, nicht
  ihr Ersatz — der Static Software Tester hat das ausdrücklich vermerkt.
- **Neu offen: die Bezugsdokumente werden auf Vorhandensein und
  Aussagefähigkeit geprüft, nicht auf Aktualität.** Eine veraltete Referenzmenge
  fällt heute durch kein Netz. Zuständig Software Architect mit dem Static
  Software Tester, terminiert mit R3-Q-001.
- Die übrigen offenen Punkte des Architekturentscheids bleiben unverändert
  bestehen und liegen beim Auftraggeber.

## Nächster Schritt

Nach der freigegebenen Reihenfolge folgt R3-Q-001 — die Definition-of-Done-Gates
als Hooks. Die Befehlskette, auf die sich der Hook stützt, steht damit; ihre
Prüfmittel prüfen sich seit dieser Einheit selbst.
