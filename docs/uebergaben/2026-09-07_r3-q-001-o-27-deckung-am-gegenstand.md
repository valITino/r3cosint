# Übergabe 2026-09-07 — R3-Q-001: O-27 umgesetzt (Pfad- und Grammatikdeckung am Gegenstand), Runde 12, Abnahmevorlage

Arbeitseinheit auf den Sitzungsauftrag `docs/vorlagen/2026-09-07_sitzungsauftrag-o-27.md`
(Weisung des Auftraggebers vom 2026-09-07, Delegation der Wahl zu O-27 an den
Koordinator; Entscheid in ADR 0002, 6.12.27 k Punkt 5: Weg (a) und (b)
zusammen, Runde 12 als letzte Fremdmutationsrunde). Vorangegangen ist die
Einheit vom 2026-09-06/07 (`docs/uebergaben/2026-09-06_r3-q-001-o-26-praedikat-und-deckung.md`),
die nach Projektauftrag 3.4 abgebrochen wurde. Diese Einheit ist die erste nach
dem Merge der Pull Requests #13 (`valITino/r3cosint`, Merge-Commit
`135e3614197a8150ad3d96fbf32eb0e893c9cbbc`) und #8 (`valITino/r3coscrum`,
`2ec4bc2047d0cd940f38481277433086c69b13be`); sie wurde als Aufgabe #1 geführt
(O-23, Entscheid E-H).

## Ergebnis in einem Absatz

O-27 ist umgesetzt, und zwar in beiden vom Auftraggeber delegierten Wegen
zugleich: Die Deckung des Selbsttests erhebt ihre Sollmenge jetzt **aus dem
Gegenstand** — 40 Ausgangsstellen aus dem Quelltext des Gates, 35 Schwächungen
mechanisch aus dem Markenmuster —, und das Abnahmekriterium ist auf das
**falsche Grün am Gate** bezogen. Runde 12 lief als letzte Fremdmutationsrunde
mit 29 blind gewählten Mutationen; 28 wurden erkannt, **eine nicht** —
`DT12-M14`, die Grammatik der D19-Zeile, eine zweite Grammatik ohne
Elementtabelle. Sie ist mit `Z-262` und `Z-263` geschlossen und durch eine
gezielte Wiederholung auf einem anderen Modell belegt: Gegen den Mutanten
fallen jetzt genau diese zwei Zusicherungen und keine weitere; am Gate selbst
blockiert die Probe unverändert mit Rückgabewert 2, am Mutanten läuft sie mit 0
durch. Zwei weitere Befunde traten an der Behebung selbst auf — `Z-260` war im
Normalmodus ungemessen, und zwei Deckungszeilen fehlten in der Ausgabe ganz —,
also dieselbe Klasse, gegen die sich der ganze Entscheid richtet, im Prüfmittel;
beide sind nach einem Entscheid des Architekten geschlossen und die Wachen
dagegen ausgeführt belegt. **Teil 1 des Abnahmekriteriums ist erfüllt, Teil 2
nicht** — er verlangt eine Runde ohne blockierenden Befund. Getragen hat der in
6.12.28 g für genau diesen Fall vorab festgelegte Weg; eine Runde 13 gibt es
nicht, und was bleibt, sind drei benannte Restlücken. Die Abnahme des Gates
wird auf dieser Grundlage vorgelegt.

## Bestand nach dem Merge (Schritt 1)

- Arbeitszweig `claude/o-27-umsetzen-qo9pef` auf `7e72a410937badcc89c55f6ecf9377a2c5408562`
  (Merge von PR #14, Eingang Methodik), der den Merge-Commit von PR #13 enthält;
  `git status` sauber.
- Zwei Umgebungsbefunde, beide behoben, keine Änderung am Repository:
  1. `gitleaks` fehlte in der Sitzungsumgebung. Beschafft wie am 2026-09-02
     (E-E, Option b): Release-Archiv `gitleaks_8.21.2_linux_x64.tar.gz`,
     SHA-256 `5bc41815076e6ed6ef8fbecc9d9b75bcae31f39029ceb55da08086315316e3ba`
     gegen die veröffentlichte Prüfsummendatei geprüft, nach
     `/usr/local/bin/gitleaks` installiert (`gitleaks version` = 8.21.2).
  2. Der Klon war flach (108 Commits); `make dod` meldete D20 `C
     FEHLT=git-historie`. `git fetch --unshallow origin` ausgeführt (116
     Commits, nicht flach).
- `make dod` danach (06:47 UTC, 8,5 s): Schlusszeile Form 2, drei terminierte
  Lagen C (D7, D10, D12), D20 `A_OK`, D11 `A_OK`, D19 `OHNE_BEFUND`,
  Rückgabewert 2 — wie erwartet.
- Selbsttest vor dem Bau: Normalmodus 207 von 207, alle Deckungen 0, 41,6 s,
  124 Gate-Aufrufe, Rückgabewert 0; Mutationsmodus 197 von 197, 0
  wirkungslos, 180 s, Rückgabewert 0. Prüfsummen der sechs Dateien vor und
  nach den Läufen gleich.
- Erhebung des Koordinators am Gate (Spur mit `bash -x`, `BASH_XTRACEFD`,
  `PS4` über `BASH_ENV`, gegen eine bytegleiche Kopie): 14 `exit`-Zeilen,
  davon vier unbeschritten (120, 128, 430, 584); 26 Aufrufstellen von
  `blockieren_mit_zaehlung`, davon acht unbeschritten (705, 740, 748, 805,
  812, 826, 1110, 1115); alle drei Aufrufstellen von
  `weitere_abweichungen_ausgeben` beschritten. Belegt: `PS4` wird aus der
  Umgebung nicht übernommen, über `BASH_ENV` schon.

## Abschnitt 10 und Ausformung 6.12.28 (Schritte 2 und 3)

- Abschnitt 10: förmliche Freigabe der Entscheidpunkte E-A bis E-K erteilt
  durch den Merge des Pull Requests #13 am 2026-09-07, 06:39:39 UTC
  (Software Architect; Protokollvermerk zur Form durch den Protocol Master).
  Die Abnahme des Gates ist davon getrennt.
- 6.12.28 a bis i (Software Architect, ohne Ausführung): Sollmenge der
  Pfaddeckung 40 Ausgangsstellen (14 `exit`, 26 Aufrufstellen);
  Erhebungsmuster mit Kommentarregel; Spur über `BASH_ENV`; geschlossene
  Liste von drei Ausnahmegründen, Ausnahmedatei
  `.claude/hooks/dod-gate-pfadausnahmen.txt` (angelegt, leer, Fehlen ist
  Fehlschlag); Sperrpfad über eine `flock`-Attrappe mit echtem zweitem
  Halter, dazu `Z-221` statisch (120 s im Gate); Zerlegung des
  `marken_muster` in 16 Elemente, sechs Umformungen U1 bis U6 (35
  Schwächungen), Probemarken mechanisch aus einem Musterexemplar,
  Wirksamkeit am Muster, fallende Zusicherung am Gate über die
  Grammatik-Fallfunktionen (mechanisch aus der Fallspalte), Zeilenanfang an
  beiden Ankern geschwächt; vier neue Schlüssel `EINGABE json`, `EINGABE
  ereignis`, `EINGABE baum`, `SPERRE belegt` in 6.12.4 (nicht gezählt, Aussage
  `E23` in 6.12.9 präzisiert `E12`); zwölftes Grammatikelement `TRENNUNG` in
  6.12.7; Alternativendeckung `Z-253`/`Z-254`; DT11-06 mit `Z-256` bis
  `Z-258`; fail-closed `Z-259` bis `Z-261`; Teil 2 des Abnahmekriteriums neu
  gefasst (6.12.28 g); Phasen mit begründeter Umordnung (Gate-Berichtigung in
  Phase 1). 53 neue Zeilen `Z-209` bis `Z-261` als Zuordnungsdatei, vom
  Koordinator mechanisch eingesetzt (261 Zeilen, 7 Spalten, keine Dublette,
  keine Lücke; Prädikate 172/41/18/9/8/6/4/2/2).
- Drei Berichtigungen des Architekten auf Befund des Koordinators vor dem
  Bau: b Punkt 8 (verschachtelter Selbsttestaufruf unmöglich wegen der
  globalen Sperre — isolierter Lauf über die ganze `FALL_REIHENFOLGE`),
  Z-237 (leeres Lage-Feld statt "unmittelbar"), Z-253/Z-254 (Spalte Element).
- Nachträge des Architekten aus dem Bau: c Punkt 4 (Probemarken: Einfügen
  eines von einer negierten Zeichenklasse ausgeschlossenen Zeichens;
  Feldlöschung als Löschung allein des Werts, Elemente 3, 5, 7, 9, 10, 11,
  14) nach dem Befund, dass U3 an Element 9 und U4 an Element 10 mit der
  ersten Probemarkenmenge unwirksam waren; Z-209 (Fallspalte nicht
  herstellbar, SST-P1-09).

## Bau (Schritt 4)

- Phase 1 (DevOps Engineer): Gate-Berichtigung (vier Meldungszeilen 119,
  127, 429, 582), Spur, `flock`- und drei `mktemp`-Attrappen, zwölf neue
  Fälle, `pfaddeckung_pruefen`, `fall_z230_231`, Ausnahmedatei, 23
  Mutationseinträge. Lauf: 230 von 230, Pfaddeckung 40/0/0, alle Deckungen 0,
  30 Kennungen ohne Prüfung (erwartet), Rückgabewert 2; Koordinatorlauf
  gleich (49,6 s).
- Zwischenkontrolle nach Phase 1 (Static Software Tester, auf einem
  Schnappschuss): NICHT BESTANDEN, vier blockierende Befunde SST-P1-01 bis
  SST-P1-04 (Vorspann-Variable `SKRIPT_VERZEICHNIS`; `timeout 30` des
  Mutationsmodus zu kurz für den isolierten Z-230-Lauf; E23-Hüllen messen
  einen Dateinamen statt "keine Zählerdatei im Verzeichnis", Mutationen auf
  die Hülle zugeschnitten; `fall_z194_197` nicht mehr letzte Fallfunktion —
  Invarianten erfassen die zwölf neuen Aufrufe nicht), sechs nachrangige
  SST-P1-05 bis SST-P1-10; Fehlerklasse "Selbsttestfall besteht, ohne seine
  Behauptung zu belegen" zweimal aufgetreten. Negativbefunde: Gate-Diff
  genau vier Zeilen, Sollmenge 40 unabhängig nachgezählt, Spur 136 = 136
  Aufrufe mit allen 40 Ausgangsstellen, fail-closed in sieben Proben, alle
  22 Mutationen wirksam und pfadgenau. Behebung in Phase 3.
- Phase 2 (DevOps Engineer): Zerlegung, Schwächungen, Probemarken,
  Schwächungslauf, Alternativendeckung, zwanzig Grammatikzeilen. Erster
  Schwächungslauf gegen den unveränderten Bestand (Bauvorschrift c Punkt
  10): 35 Schwächungen, 33 wirksam, 22 ohne fallende Zusicherung (95 s) —
  deckungsgleich mit der Ableitung des Architekten (17 distinkte Zielzeilen;
  Z-237 und Z-240 unwirksam mit der ersten Probemarkenmenge, Z-238 schon
  über Z-176 gedeckt). Endlauf: 254 von 254, Grammatikschwaechungen
  35/33/0 (156 s), Pfaddeckung 40/0/0, sechs Kennungen ohne Prüfung
  (erwartet), Rückgabewert 2; Normallauf 3 min 31 s; Koordinatorlauf auf dem Schnappschuss gleich (254 von 254, 35/33/0, 40/0/0, 3 min 31 s). Baubefund:
  `FALL_ZU_KENNUNG` musste in den Vorspann. Alle 20 Grammatikzeilen liefern
  den abgeleiteten Ausgang (`KETTE ausgabe-unlesbar`, rc 2) — bestätigt.
- Phase 3 (DevOps Engineer): fünf Fälle zu `DT11-06` und den fail-closed-Deckungen
  (`Z-256` bis `Z-261`), der Block der Deckungszeilen, sechs weitere
  Mutationseinträge; dazu die Behebung aller zehn Befunde `SST-P1-01` bis
  `SST-P1-10`. Endlauf: Normalmodus 260 von 260 Zusicherungen, Rückgabewert 0
  (4 min 33 s); Mutationsmodus 248 von 248 erkannt, 0 wirkungslos,
  Rückgabewert 0 (9 min 47 s). Deckungen: Pfaddeckung 40/0/0,
  Grammatikschwächungen 35/35/0, Schlüsseldeckung 18/0/0, Grammatikdeckung
  12/0/0, Aussagendeckung 31/0/0/0, Gegenstandsdeckung 24/0. `make dod` in
  Form 2 mit drei terminierten Lagen C und D20 `A_OK`.

## Verifikation (Schritt 5, Runde 12)

Runde 12 ist die **letzte** Fremdmutationsrunde (6.12.28 g). Beide Prüfrollen
haben auf einem anderen Modell als die Umsetzung gearbeitet (3.4).

**Statisch (Static Software Tester).** **Nicht bestanden**, an zwei
blockierenden **Baubefunden**, nicht an der Festlegung:

- `S12-01` — `Z-260` mass ein Feld, das vier der neun Blockzeilen nicht
  enthielt (drei entstehen erst in der Zusammenfassung, die Zeile
  `Pfaddeckung:` wird erst nach dem Fall angehängt). Ausgeführt belegt gegen
  eine ADR-Kopie ohne Tabellenzeilen.
- `S12-02` — `Z-258` bestand mit **leerer** Sollmenge (0 Aufrufstellen = 0
  Fallfunktionen); die zugesagte fail-closed-Wache `Z-260` sah seine Zahlen
  nie. Ausgeführt belegt gegen eine Gate-Kopie ohne Aufrufstellen.

Nachrangig: `SST-P3-01` bis `SST-P3-05`, `S12-03` bis `S12-05`. Alle Zahlen
aus 6.12.28 h sind eigenständig bestätigt; beide Modi enden in der Kopie mit
Rückgabewert 0 (262 s und 577 s); alle 248 `sed`-Ausdrücke sind wirksam; der
Gate-Diff umfasst genau die vier Zeilen aus 6.12.28 e; `Makefile` und
Lagenliste sind bytegleich. `shellcheck` fehlt in der Umgebung (Lage C).

**Dynamisch (Dynamic Software Tester).** 29 Fremdmutationen blind gewählt um
11:15:54 UTC, erster Blick in die Mutationsdatei und die Tabelle um 11:21:06
UTC, keine Nachwahl; 7/7/7/8 je Kategorie, alle wirksam, neun davon mit
falschem Grün am Gate. **28 liessen mindestens eine Zusicherung fallen. Genau
eine nicht — und sie erzeugt ein falsches Grün:** `DT12-M14`.

`DT12-M14` weitet die Grammatik der **D19-Zeile** (Gate, Zeilen 810 und 816;
Festlegung in 6.12.8) auf jedes Grosswort. Gegen die Probe
`make dod: D19: SPAETER.` blockiert das **unveränderte** Gate richtig
(Rückgabewert 2, Schlüssel `KETTE ausgabe-unlesbar`); der Mutant lässt sie
mit **Rückgabewert 0 ohne Ausgabe** durch, und der Selbsttest meldet 260 von
260. Die Klasse ist dieselbe, die 6.12.28 c für die Lage-Marke geschlossen
hat — eine Aufzählung deckt die zulässigen Formen, nicht die Menge der
unzulässigen —, nur an einer zweiten Grammatik ohne Elementtabelle.

**Damit ist Teil 1 des Abnahmekriteriums erfüllt und Teil 2 nicht.** Nach
6.12.28 g wird der Befund behoben, statisch nachgeprüft und mit einer
gezielten Wiederholung belegt; **eine Runde 13 gibt es nicht.**

### Behebungsrunde

Die Behebung ist am 2026-09-07/08 gelaufen. **Gebaut hat der DevOps Engineer,
entschieden der Software Architect; geprüft haben Static und Dynamic Software
Tester auf einem anderen Modell** (3.4).

**1. Der blockierende Befund ist geschlossen.** Zwei neue Zeilen decken die
Verstossform, die `DT12-M14` ausgenutzt hat: `Z-262` (Kanal `rc`, Prädikat
`gleich`, Rückgabewert 2) und `Z-263` (Kanal `zaehler`, Prädikat `gleich`,
Schlüssel `KETTE ausgabe-unlesbar`), beide über **einen** Lauf mit zwei
Messungen — eine D19-Zeile mit einem Wort ausserhalb der vier zulässigen
(`SPAETER`), sonst grüne Kette mit Schlusszeile Form 1. Gegen die Gate-Kopie
mit `DT12-M14` fallen jetzt beide (`rc 0` statt 2; Zählerdatei ohne Schlüssel);
im vollständigen Mutationslauf sind beide als erkannt ausgewiesen. **Am Gate
ist nichts geändert** — die Prüfsumme ist unverändert die aus Phase 1.

**2. Zwei Befunde an der Behebung zu `S12-01`/`S12-02`**, vom Koordinator am
Code gefunden, vom DevOps Engineer bestätigt und durch eine Rückrechnung als
**vorbestehend** von den Posten dieser Einheit abgegrenzt:

- `_z260_pruefen` hatte genau eine Aufrufstelle, innerhalb von `fall_z260`,
  und `fall_z260` steht nicht in der `FALL_REIHENFOLGE`. `Z-260` war im
  Normalmodus **ungemessen**; der Lauf endete mit Rückgabewert 2.
- Die Zeilen `Deckung:`, `Kanalabgleich:` und `Praedikatabgleich:` waren
  weiterhin direkte Ausgaben und standen nicht im geprüften Block; das Feld
  `PFADDECKUNG_ZEILEN` wurde nirgends befüllt, sodass die Zeilen
  `Pfaddeckung:` und `Grammatikschwaechungen:` in der Ausgabe **ganz
  fehlten**.

Beides ist dieselbe Klasse, die `S12-02` beanstandet hat: eine Deckung, die
unbemerkt nicht läuft. Der DevOps Engineer hat nicht improvisiert und den
Sachverhalt vorgelegt, statt `Z-260` als Deckungsausnahme einzutragen — das
hätte genau die Klasse reproduziert.

**3. Entscheid des Architekten** (ADR 0002, 6.12.28 f, Nachtrag vom
2026-09-08). Der Zirkel ist echt: `Z-260` braucht den fertigen Block, die
Buchhaltung braucht die Meldung von `Z-260`. Aufgelöst wird er über den
**Messumfang**. `Z-260` misst am Block allein die **ersten Zahlen**, und die
erste Zahl der drei Abgleichzeilen ist in allen dreien die Zahl der Kennungen
der Tabelle 6.12.19 — sie hängt nicht davon ab, welche Zusicherungen bereits
gemeldet sind. Die Buchhaltung wird deshalb als **zwei Erhebungen aus einer
einzigen Funktion** geführt: die erste registriert die drei Zeilen an ihrem
Platz und gibt nichts aus; dann misst `Z-260` den vollständigen Block; dann
löst die zweite Erhebung dieselben drei Zeilen mit den endgültigen Zahlen ein
und liefert als **einzige** das Urteil und die Befundzeilen. Ausgabe und
Rückgabewert stammen damit aus derselben Erhebung und können sich nicht
widersprechen. Dass die Einlösung nichts ändert, was `Z-260` gemessen hat,
wird **nicht angenommen, sondern geprüft** — über einen Vergleich des Vektors
der ersten Zahlen. Die zweite Lücke schliesst eine **Blockdeckung**: elf
Pflichtetiketten als Sollmenge im ADR, in beide Richtungen gegen die Etiketten
im Feld gehalten; ihre eigene erste Zahl ist die Sollzahl, sodass eine
geleerte Sollmenge über `Z-260` fällt. **Es kommt keine Kennung hinzu**;
Tabelle, Mutationsdatei, Gate, `Makefile` und Lagenliste bleiben unangetastet.

**4. Ergebnis des Baus.** Beide Modi enden mit Rückgabewert 0.

| Grösse | Wert |
|---|---|
| Zusicherungen, Normalmodus | 262 von 262 bestanden, Rückgabewert 0 |
| Mutationen | 250 geprüft, **250 erkannt, 0 nicht erkannt**, 12 ohne Mutation, 0 wirkungslos, Rückgabewert 0 |
| Deckung | 262 Kennungen, 262 geprüft, 0 ohne Prüfung, 0 ohne Kennung |
| Kanal- und Prädikatabgleich | je 262 Kennungen, 0 Abweichungen |
| Pfaddeckung | 40 Ausgangsstellen, 0 nicht beschritten, 0 mit Ausnahme |
| Grammatikschwächungen | 35 Schwächungen, 35 wirksam, 0 ohne fallende Zusicherung |
| Aufrufstellendeckung `E21` | 3 Aufrufstellen, 3 Fallfunktionen |
| Schlüssel-, Grammatik-, Aussagen-, Gegenstandsdeckung | 18 / 12 / 31 / 24, je 0 Abweichungen |
| Blockdeckung | 11 Etiketten erwartet, 0 ohne Zeile, 0 fremde Etiketten, 35 Zeilen im Block |
| Tabelle 6.12.19 | 263 Zeilen, 262 Zusicherungen, 264 Messhüllen, Prädikat `gleich` 174 |
| Mutationsdatei | 262 Einträge (250 `sed`, 12 `keine`) |
| Gate | unverändert; Prüfsumme wie nach Phase 1 |

Unterwegs hat der DevOps Engineer einen eigenen Baufehler gefunden und behoben:
`X=$(deckungszeile_registrieren …)` hätte die Anhängung in einer Subshell
verloren, weil Kommandosubstitution forkt.

## Nachführung

- `docs/adr/0002-architekturentscheid-ziel-stack.md`: Abschnitt 6.12.28 a bis j
  neu, mit dem Nachtrag vom 2026-09-08 in f; 6.12.4 um vier Schlüssel, 6.12.7
  um das Kürzel `TRENNUNG`, 6.12.9 um die Aussage `E23` erweitert; Tabelle
  6.12.19 auf 263 Zeilen; Abschnitte 8, 9 und 10 nachgeführt.
- `docs/05_Product_Backlog.md`: Eintrag R3-Q-001 nachgeführt — Nachweis-Zeile
  auf den Stand 2026-09-08, die Runde-11-Posten auf den verbleibenden Rest
  umgeschrieben, neuer Sammelposten mit den drei Restlücken aus Runde 12,
  neuer Stand-Vermerk. Der Koordinator hat zwei Stellen berichtigt: die
  Aussage, Teil 2 des Abnahmekriteriums sei erfüllt (er ist es nicht), und
  eine Commit-Kurzform ohne die 40-stellige Prüfsumme.
- `CLAUDE.md`: Statustabelle und Gate-Zeile auf den Stand nach Runde 12.
- `scripts/nachweise-erzeugen.sh` und `docs/NACHWEISE.md`: Artefaktliste um
  diese Übergabe und die Ausnahmedatei ergänzt, Verzeichnis neu erzeugt.
- Methodik-Repository `valITino/r3coscrum`: `V17` in `methodik/entscheide.md`,
  O-27 auf erledigt, Übergabevermerk in `UEBERGABE.md`.

## Abnahmevorlage (Schritt 6)

Der Software Architect hat die Abnahmevorlage am 2026-09-08 in Abschnitt 10
des ADR 0002 geschrieben, nachdem Behebung, statische Nachprüfung und
gezielte Wiederholung als Fremdbeleg gemeldet waren — und nicht vorher.

Vorgelegt wird die Abnahme des Prüfmittels aus R3-Q-001: Gate, Lagenliste,
Selbsttest mit 262 Zusicherungen, Mutationsdatei mit 262 Einträgen und die
Festlegung in 6.12 samt Nachträgen. **Nicht** vorgelegt werden O-25, die
Abnahme des Belegprüfers D20 (O-15), R3-Q-005 und die Freigabe des
Grundgerüsts; die Entscheidpunkte E-A bis E-K sind seit dem 2026-09-07
freigegeben und stehen nicht erneut zur Wahl.

Die Vorlage stützt sich ausdrücklich **nicht** auf einen bestandenen Teil 2
des Abnahmekriteriums, sondern auf den Weg, den 6.12.28 g **vor** Runde 12
für genau diesen Fall festgelegt hat. Sie führt im Haupttext die drei
Restlücken, die drei Grenzen aus dem Nachtrag zu f) und die Grenzen, die die
Prüfrollen an ihrer **eigenen** Prüfung benannt haben: keine wortlautgenaue
Feindeckung der Aussagen- und Grammatikkürzel Zeile für Zeile, und kein Lauf
gegen einen unabhängig geklonten Baum. Dazu die beiden bekannten Lücken
ausserhalb dieser Einheit — das Gate misst das Recht einer Rolle, nicht ihre
Fähigkeit (E-K, offen bis R3-Q-005), und es stützt sich auf die ganze Kette
und damit auf den nicht abgenommenen Belegprüfer D20 (O-15).

Der Formweg ist der aus Abschnitt 10 geführte: Merge des Pull Requests mit
ausdrücklicher Nennung dieser Bedeutung im Text des Pull Requests, oder
Anweisung an die nächste Sitzung im exakten Wortlaut. Die Abnahme kann
verweigert oder mit Auflagen erteilt werden; die Entscheidtabelle steht mit
"offen" bereit.

## Was offen ist

**Zur Entscheidung durch den Auftraggeber**

- Die **Abnahme des Gates** aus R3-Q-001. Vorgelegt wird sie mit dieser
  Einheit in Abschnitt 10 des ADR 0002; der Formweg ist derselbe wie bei den
  Entscheidpunkten E-A bis E-K: der Merge des Pull Requests oder eine
  Anweisung an die nächste Sitzung im exakten Wortlaut.
- **O-25** bleibt offen (6.12.26 g) und wird von dieser Einheit nicht berührt.

**Restlücken, benannt und im Backlog unter R3-Q-001 geführt** (6.12.28 j
Punkt 5)

1. Die **Grammatik der D19-Zeile** (6.12.8) ist nicht am Gegenstand gedeckt.
   Geschlossen ist die eine belegte Verstossform (`Z-262`, `Z-263`); die Menge
   der Verstossformen deckt kein Schwächungslauf. Die systematische Antwort
   wäre ein Schwächungslauf über das D19-Muster nach dem Vorbild von
   6.12.28 c — nach 6.12.28 g ausdrücklich **nicht** Gegenstand dieser
   Einheit.
2. **Zeichen im Inneren eines Wortliterals** werden nicht einzeln geschwächt
   (6.12.28 c Punkt 3, benannte Grenze).
3. **Eine Alternative mit einem bestimmten fremden Literal** ist nur als
   Klasse erfasst; für die D19-Grammatik besteht kein Gegenstück zur
   Alternativendeckung `Z-253`/`Z-254`.

Dazu die nachrangigen Befunde der Runden 11 und 12: `S11-02`, `S11-03`,
`S11-09`, `S11-10`, `S10-06`, `SST-B5-09`, `S9-05` sowie die nachrangigen
Befunde der Runde 12, soweit sie nicht in dieser Einheit behoben sind.

**Bekannte Grenzen, die bestehen bleiben**

- Das DoD-Gate misst über das `tools`-Feld das **Recht** einer Rolle zu
  schreiben, nicht ihre **Fähigkeit**; eine Rolle mit `Bash` und ohne `Edit`
  könnte schreiben und darf es nicht (6.12.14, Entscheid E-K). Geschlossen
  wird das erst mit **R3-Q-005**.
- Das Gate stützt sich auf die ganze Kette und damit auf den nicht
  abgenommenen Belegprüfer D20 (O-15).
- `shellcheck` fehlt in der Sitzungsumgebung; die Lage ist als C geführt.

**Danach in eigenen Einheiten**

E4, E3, dann das Grundgerüst — in dieser Reihenfolge nach dem freigegebenen
Plan.

## Protokoll der ausgeführten Befehle (Koordinator)

Diese Rolle hat weder gebaut noch geprüft. Ausgeführt hat sie:

- die Erhebung der Ausgangsstellen am Gate für die Sollmenge der Pfaddeckung
  (Spur mit `bash -x`, `BASH_XTRACEFD`, `PS4` über `BASH_ENV`, gegen eine
  bytegleiche Kopie) — Grundlage für die Zahl 40, die der Architekt festgelegt
  und beide Prüfrollen unabhängig nachgezählt haben;
- das mechanische Einsetzen der Zuordnungsdateien des Architekten in die
  Tabelle 6.12.19 (`zeilen-einsetzen.py`) mit Prüfung von Form, Spaltenzahl,
  Kanal- und Prädikatvorrat, Dubletten und Lücken — zuletzt für `Z-262` und
  `Z-263`;
- die Formprüfung über alle geänderten Dateien (Eszett, typografische
  Anführungszeichen, Verweise über einen Zweignamen statt über eine
  Commit-Prüfsumme, Modellnamen) — durchgehend ohne Treffer;
- `make dod` vor jedem Commit, je in Form 2 mit den drei terminierten Lagen C;
- die statische Feststellung der beiden Befunde an der Behebung zu `S12-01`
  und `S12-02` (`_z260_pruefen` mit nur einer Aufrufstelle; die drei
  Abgleichzeilen als direkte Ausgaben, `PFADDECKUNG_ZEILEN` nie befüllt),
  die dem Architekten vorgelegt wurden;
- die Berichtigung zweier Stellen in der Backlog-Nachführung des Product
  Owners (Teil 2 des Abnahmekriteriums, Commit-Kurzform);
- Commit und Push auf `claude/o-27-umsetzen-qo9pef` in beiden Repositories.

**Eine Weisung dieser Rolle hat eine Prüflücke verursacht und wurde
zurückgenommen:** Der Dynamic Software Tester war angewiesen worden,
Hintergrund-Warteschleifen zu vermeiden; das war zu pauschal formuliert und
führte dazu, dass die Trennschärfe zunächst nur stichprobenartig belegt war
(`DT12W-06`). Nach der Rücknahme hat er den einen vollständigen Normallauf
gegen den Mutanten nachgeholt, der die Lücke geschlossen hat.
