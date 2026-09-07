# Sitzungsauftrag 2026-09-07 — R3-Q-001: O-27 umsetzen, Runde 12, Abnahmevorlage

Entwurf des Koordinators für den Auftrag an die nächste Sitzung, auf Weisung
des Auftraggebers vom 2026-09-07 ("Dann erstelle einen Prompt für die nächste
Session"). Der Text unter "Auftrag" ist zum Einfügen als erste Nachricht der
neuen Sitzung bestimmt. Er gilt nach dem Merge der beiden Pull Requests
(`valITino/r3cosint` und `valITino/r3coscrum`, Arbeitszweig
`claude/r3-dod-gates-hooks-fn5hia`) und setzt voraus, dass die Sitzung mit
dem Repository `r3cosint` als Projektwurzel geöffnet wird — nur dann wirkt
das Definition-of-Done-Gate — und dass `gitleaks`, `jq`, `make`, `git`,
`timeout`, `flock` und `mktemp` in der Umgebung vorhanden sind.

## Auftrag

Du bist der Koordinator des Projekts R3cOSINT (Repository `valITino/r3cosint`,
Methodik in `valITino/r3coscrum`). Arbeite auf dem zugewiesenen Arbeitszweig,
nie auf `main`. Lies zuerst, in dieser Reihenfolge, und arbeite nicht aus dem
Gedächtnis: `CLAUDE.md`, `docs/00_Projektauftrag.md` (Abschnitte 3.1 bis 3.4,
6.6), `docs/uebergaben/2026-09-06_r3-q-001-o-26-praedikat-und-deckung.md`,
ADR 0002 (`docs/adr/0002-architekturentscheid-ziel-stack.md`) Abschnitt 6.12.27
vollständig — besonders g (Abnahmekriterium), j (Deckung am Gegenstand) und k
(Runde 11, Abbruch nach 3.4, O-27 mit dem Entscheid vom 2026-09-07) —, dazu
6.12.4, 6.12.7, 6.12.9, 6.12.15, 6.12.19 und die Abschnitte 8, 9 und 10; dann
`scripts/dod-gate-selbsttest.sh`, `scripts/dod-gate-mutationen.txt` und
`.claude/hooks/dod-gate.sh`.

Regeln, unverändert: keine Annahmen, nichts erfinden; geraten Effizienz und
Korrektheit in Konflikt, entscheidet die Korrektheit. Deutsch in Schweizer
Schreibweise (`ss`, nie Eszett), gerade Anführungszeichen. Commit-Betreff nach
Conventional Commits mit der Kennung R3-Q-001; in Dokumenten wird über die
40-stellige Commit-Prüfsumme verwiesen, nie über `blob/main`. Über den
Harness laufen keine echten Fall- oder Personendaten. Die Rolle, die
umsetzt, prüft nicht ihre eigene Arbeit; jeder modellbasierte Prüfschritt
läuft auf einem anderen Modell als die Umsetzung (3.4). Jede Arbeitseinheit
wird als Aufgabe geführt (beim Beginn anlegen, beim Abschluss auf erledigt
setzen), endet mit einer Übergabedatei unter `docs/uebergaben/` und wird nur
committet, wenn sie die Definition of Done erfüllt. Scheitert dieselbe
Prüfung dreimal am gleichen Kriterium, wird abgebrochen, die Übergabedatei
geschrieben und dem Auftraggeber vorgelegt (3.4). Das Gate ist seit dem Merge
scharf: `Stop`, `SubagentStop` und `TaskCompleted` enden erst, wenn
`make dod` nachweisbar gelaufen ist und nichts gefunden hat; die terminierten
Lagen C (D7, D10, D12) werden geduldet. Namen von Modellen gehören in keine
Datei des Repositories.

Diese Sitzung hat genau eine Arbeitseinheit: **O-27 umsetzen**. Der Entscheid
ist gefallen (ADR 0002, 6.12.27 k, Entscheid vom 2026-09-07, Wahl auf Weisung
an den Koordinator delegiert): Weg (a) und Weg (b) zusammen, mit Runde 12 als
letzter Fremdmutationsrunde. Führe sie in dieser Reihenfolge durch:

1. **Bestand erfassen und Umfang benennen** (3.1, 3.3). Prüfe `git status`,
   den Stand von `main` nach dem Merge, `make dod` (erwartet: Schlusszeile
   Form 2, drei terminierte Lagen C, Rückgabewert 2) und beide Modi des
   Selbsttests (erwartet: 207 von 207, alle Deckungen 0; 197 von 197 erkannt).
   Weicht etwas ab, ist das der erste Befund und geht vor allem anderen.
2. **Abschnitt 10 des ADR nachführen** (Protocol Master oder Software
   Architect): Die förmliche Freigabe der Entscheidpunkte E-A bis E-K ist mit
   dem Merge des Pull Requests erteilt — Datum, Merge-Commit mit 40-stelliger
   Prüfsumme, Formweg "Merge des Pull Requests" nach Abschnitt 10. Die
   Abnahme des Gates ist davon getrennt und bleibt offen bis nach Runde 12.
3. **Ausformung als 6.12.28** durch den Software Architect, ohne dass er
   etwas ausführt: (a1) Pfaddeckung — Sollmenge jede Ausgangsstelle des
   Gates (jedes `exit`), mechanisch erhoben; Ist die Ausführungsspur des
   Gates (`bash -x` mit `BASH_XTRACEFD` und `PS4` mit Zeilennummer, gegen eine
   Wegwerfkopie, Gate unverändert) über alle Gate-Aufrufe des Selbsttests;
   jede Stelle mindestens einmal beschritten; Ausnahmen nur mit Grund aus
   einer geschlossenen Liste, Ziel keine Ausnahme, auch der Sperrpfad
   "länger als 120 s" wird hergestellt. (a2) Grammatik am Gegenstand —
   Sollmenge mechanisch erzeugte Schwächungen des `marken_muster` nach einer
   geschlossenen Liste von Umformungen je Musterelement (Anker entfernt,
   Quantor `+` zu `*`, Literal oder Gruppe optional, Zeichenklasse geweitet,
   Alternative erweitert, Leerraum vor dem Endanker zugelassen); Ist: jede
   Schwächung, die eine Probemarke annimmt, die das unveränderte Muster
   ablehnt, lässt mindestens eine Zusicherung fallen. Beide als neue Zeilen
   der Tabelle 6.12.19 mit Kanal, Prädikat, Mutation und Etikett, fail-closed
   (Mindestzahl grösser null, leeres Muster oder leere Sollmenge ist ein
   Fehlschlag). Dazu die Zeilen für DT11-06 (je Aufrufstelle einer Aussage
   im Gate eine Messung), DT11-11 (Gate-Berichtigung: einheitliche
   Meldungsform an den drei Vor-Eingabe-Pfaden und am Sperrpfad, kein
   Verhaltenswechsel) und S11-04 bis S11-06 (bestehende Deckungen
   fail-closed). Und die Neufassung von 6.12.27 g Teil 2 im Wortlaut:
   Blockierend ist allein eine Fremdmutation, die am Gate ein falsches Grün
   erzeugt (Rückgabewert 0, wo das unveränderte Gate 2 liefert — gegen einen
   echten Baum, einen Attrappenbaum oder eine Probemarke) und keine
   Zusicherung fallen lässt; Formabweichungen sind nachrangig und Backlog;
   Runde 12 ist die letzte Fremdmutationsrunde. Zahlen und Bestand nach dem
   Muster von 6.12.27 f und j Punkt 7. Die Tabellenzeilen liefert der
   Architekt als Zuordnungsdatei; der Koordinator setzt sie mechanisch ein
   und prüft Spaltenzahl, Dubletten, Lücken und Form.
4. **Umsetzung** durch den DevOps Engineer in höchstens drei Phasen
   (Pfadspur und Pfaddeckung; Musterschwächungen und Grammatikdeckung;
   DT11-06, DT11-11, S11-04 bis S11-06 und Mutationen), je Phase ein
   eigener Lauf beider Modi mit unveränderten Prüfsummen von Gate,
   Selbsttest, Mutationsdatei, `Makefile`, Lagenliste und ADR vor und nach
   dem Lauf; nach Phase 1 und nach Phase 3 eine Zwischenkontrolle durch den
   Static Software Tester. Was der Bau am ADR als falsch findet, wird
   gemeldet und vom Architekten berichtigt, nie stillschweigend angepasst.
5. **Runde 12** durch Static und Dynamic Software Tester in Wegwerfkopien:
   statisch mit eigenständiger Nachzählung aller Zahlen, aller
   `sed`-Ausdrücke und der Gegenstandsdeckungen; dynamisch als blinde
   Fremdmutationsrunde mit mindestens sechs Fremdmutationen je Kategorie
   (Schlüssel, Grammatik, Schwellen und Ereignisfolge, Ausgabeform),
   schriftlich mit Zeitmarke festgelegt, bevor Mutationsdatei und Tabelle
   6.12.19 gelesen werden, ohne Nachwahl. Massstab ist der neue Teil 2:
   Blockierend ist allein ein falsches Grün am Gate; jede andere Abweichung
   ist ein nachrangiger Befund für den Backlog. Ein falsches Grün wird
   behoben, statisch nachgeprüft und mit einer gezielten Wiederholung der
   betroffenen Fremdmutation belegt — keine Runde 13.
6. **Abschluss**: Übergabedatei `docs/uebergaben/2026-MM-TT_r3-q-001-o-27-pfade-und-grammatik.md`
   nach dem Muster der Übergabe vom 2026-09-06; Nachführung von `CLAUDE.md`,
   `docs/05_Product_Backlog.md` (Nachweis, Stand, Sammelposten),
   `scripts/nachweise-erzeugen.sh`, ADR 0002 Abschnitte 8 und 9 und, nach
   bestandener Runde 12, die **Abnahmevorlage** des Gates in Abschnitt 10
   (Vorgelegt am, Beleg, Restlücke) — die Abnahme selbst erteilt der
   Auftraggeber. `make dod`, Commit mit Kennung, Push mit
   `git push -u origin <zugewiesener Zweig>`, `docs/NACHWEISE.md` neu
   erzeugen und committen, Pull Request mit Prüfliste; im
   Methodik-Repository `UEBERGABE.md` und `methodik/entscheide.md` (O-27
   erledigt) nachführen, committen, pushen, Pull Request.
7. **Bericht an den Auftraggeber**: Ergebnis der Runde 12, Restlücke, klare
   Empfehlung zum Merge ("Ja, jetzt mergen" oder "Nein, weil ..."), und die
   Bitte, `/usage` zu prüfen. Nächste Einheiten nach dem Merge: E4, dann E3,
   dann das Grundgerüst als erster Produktcode — nicht in dieser Sitzung.

Kontingent: Der Auftraggeber prüft `/usage`; die Sitzung startet keine
zweite Einheit von sich aus. Wird das Kontingent während der Einheit knapp,
den Stand in eine Übergabedatei schreiben und dem Auftraggeber vorlegen,
statt halbfertig zu committen (3.3).

## Was der Koordinator dieser Sitzung noch offen gelassen hat

- Der Merge selbst und das Öffnen der neuen Sitzung liegen beim
  Auftraggeber. Die stündliche Prüfung der beiden Pull Requests in dieser
  Sitzung endet mit dem Merge von selbst.
- Die Ausformung 6.12.28 ist bewusst nicht in dieser Sitzung geschrieben:
  Sie ist der erste Schritt der Einheit, die sie umsetzt, und der Architekt
  schreibt sie gegen den Stand nach dem Merge.
