# Übergabe — Arbeitseinheit «Befund F: fehlende Abnahmekriterien nachgetragen»

| | |
|---|---|
| **Arbeitsprodukt nach** | Projektauftrag 3.3 (Übergabedatei je Arbeitseinheit) |
| **Einheit** | Befund F des freigegebenen Plans vom 2026-08-25 |
| **Datum** | 2026-08-26 |
| **Zweig** | `claude/next-step-g8slnq` |
| **Grundlage** | Deep Review vom 2026-08-25, Befund F |
| **Beteiligte Rollen** | Requirements Engineer (Formulierung), Product Owner (Einordnung), Static Software Tester (zwei unabhängige Prüfungen) |

## Worum es ging

Befund F belegte ein Muster, kein Einzelversehen: **ADR 0002 sichert Eigenschaften
zu, für die der Backlog kein Abnahmekriterium führt.** Ein Architekturentscheid,
den kein Test prüft, ist eine Absichtserklärung. Die Einheit trägt die fehlenden
Abnahmekriterien nach — kein Code, wie im Plan festgelegt.

## Was fertig ist

### Acht neue Backlog-Einträge

| Kennung | Titel | Etappe | Prüfaufwand |
|---|---|---|---|
| R3-F-022 | Schemaprüfung eingehender Quellantworten | 1 | 6 h |
| R3-F-023 | Schemaprüfung der Modellantwort | 1 | 5 h |
| R3-F-024 | Pfadangaben von aussen ohne Traversierung | 1 | 5 h |
| R3-F-026 | Werkzeugverzeichnis: Vollständigkeit und Inhalt je Eintrag | 1 | 4 h |
| R3-F-027 | Eingangsvalidierung der eigenen HTTP-Schnittstelle | 1 | 6 h |
| R3-F-028 | Positivliste nach aussen: Weiterleitung, Namensauflösung, IP-Literale | 1 | 6 h |
| R3-Q-006 | Fremde Inhalte in der Oberfläche sind Text, nie Auszeichnung | 3 | 4 h |
| R3-F-025 | Ausgabekodierung: fremde Inhalte sind Inhalt, nie Struktur | 4 | 6 h |

### Drei bestehende Einträge fortgeschrieben

- **R3-F-017** um ein zweites Abnahmekriterium erweitert, Prüfaufwand 8 h auf 10 h.
- **R3-F-015** um einen Rückverweis auf R3-F-028 ergänzt.
- **R3-F-002** um einen Rückverweis auf R3-F-026 ergänzt.

### Summen nachgeführt

Erste Fassung von 71 Einträgen / 300 h auf **79 / 344 h**, gesamt von 76 / 323 h
auf **84 / 367 h**. Etappe 1 von 113 h auf 147 h, Etappe 3 von 59 h auf 63 h,
Etappe 4 von 26 h auf 32 h. Nachgeführt in `docs/05_Product_Backlog.md` und an
allen sechs betroffenen Stellen in `docs/07_Roadmap.md`.

## Entscheidungen des Product Owners

| Frage | Entscheid | Begründung |
|---|---|---|
| Werkzeugverzeichnis | eigener Eintrag R3-F-026 | nach Korrektur der Prämisse (siehe unten) auf Vollständigkeit und Inhalt zugeschnitten, nicht auf die Existenz |
| Eingangsvalidierung `api` | eigener Eintrag R3-F-027 | kein bestehender Test setzt sie voraus; echte Lücke |
| Etappe von R3-F-025 | Etappe 4 statt 1 | zwei der drei Tests validieren Artefakte, die es vor Etappe 4 nicht gibt |
| R3-Q-006 und das Gate aus 5.6 | jetzt schätzen | das Gate nennt nur Frontend-Einträge ab R3-F-051; Präzedenz R3-Q-003 |
| Positivliste | eigener Eintrag R3-F-028 | B4 und 6.7 verlangen Änderungen als eigenen Eintrag |
| fehlender Ursachentest | R3-F-017 fortschreiben, kein neuer Eintrag | ADR 0002 ordnet die Zusicherung bereits R3-F-017 zu; der Product Owner hat kein Schreibrecht auf `docs/adr/` und hätte die Zuordnung nicht nachführen können |
| Etappe von R3-F-024 | Etappe 1, Test selbstskalierend formuliert | anders als bei R3-F-025 lässt sich der Test skalieren |

## Korrekturen an eigenen Aussagen

Zwei Aussagen aus dem Arbeitsverlauf waren falsch und sind vor dem Einschreiben
in den Backlog korrigiert worden. Beide standen bereits im Entwurf und wären
sonst als Tatsache im Backlog gelandet.

1. **«R3-F-013 begründet das Werkzeugverzeichnis.»** Falsch. R3-F-013 heisst
   «MCP-Server als einziger Zugang, Schlüssel serverseitig». Die Abhängigkeit
   ist auf ADR 0002 umgestellt.
2. **«Kein Backlog-Eintrag verlangt ein Werkzeugverzeichnis.»** Ebenfalls falsch,
   und diese Aussage hatte die Vorprüfung des Koordinators durchgelassen.
   ADR 0002, Zeile 388, nennt **R3-F-002** ausdrücklich, und dessen
   Abnahmekriterium verlangt wörtlich, dass der Test «über alle registrierten
   Werkzeuge iteriert» — ohne Verzeichnis nicht ausführbar. Die tatsächliche
   Lücke ist enger: Vollständigkeit und Inhalt des Verzeichnisses. R3-F-026 ist
   danach neu zugeschnitten worden.

## Verifikation — zwei unabhängige Prüfungen, beide zunächst nicht bestanden

Die Prüfung ist geteilt worden, weil die Umsetzung auf zwei Modellen entstand
(Formulierung auf Opus, Einordnung auf Sonnet). Eine einzige Prüfung hätte die
Vorgabe aus 3.4 — Prüfschritt auf einem anderen Modell als die Umsetzung — nur
für eine Hälfte erfüllt.

| Prüfung | Modell | Gegenstand | Urteil |
|---|---|---|---|
| Wortlaut gegen R1–R10 | Sonnet | die zehn Einträge | nicht bestanden |
| Einordnung gegen B1–B6, Arithmetik | Opus | Etappen, Summen, Roadmap | nicht bestanden |

**Die Arithmetik hielt vollständig stand** — alle zehn Summenzeilen, alle
Sprint- und Wochenzahlen unabhängig nachgerechnet, keine Abweichung, keine
veraltete Zahl stehen geblieben.

Die Befunde lagen woanders:

- **blockierend, R6:** `R3-F-025_jeder_ausgabeweg_kodiert` iteriert über
  «Ausgabewege», ohne dass irgendwo steht, was ein Ausgabeweg ist.
- **blockierend, Sachfehler:** die Roadmap sprach von «sieben neuen Einträgen»,
  es sind acht.
- **R3:** sechs tragend verwendete Fachbegriffe standen nicht im Glossar.
- **falscher Querverweis:** R3-F-023 behauptete, R3-F-014 und R3-F-018 prüften,
  dass das Sprachmodell keine Werkzeugaufruf-Fähigkeit erhält. R3-F-014 prüft
  die Freigabesperre, R3-F-018 prüft «null Treffer ausserhalb der
  Zwischenschicht». ADR 0002 ordnet die Zusicherung R3-F-017 zu.
- **B5:** sieben Abhängigkeiten waren nur in eine Richtung verwiesen.
- **C-Befunde:** zwei Annahmen fehlten in der Tabelle der offenen Punkte, die
  Stand-Zeile nannte R3-F-002 nicht, ein Roadmap-Satz suggerierte
  Vollständigkeit.

**Ein Befund wurde zurückgewiesen und dann doch bestätigt — die Zurückweisung
war falsch.** Die Wortlautprüfung beanstandete die Quellenangabe 5.13 bei
R3-F-027. Der Koordinator wies das zurück mit der Begründung, 5.13 verlange
Ratenbegrenzung wörtlich und sei damit der Ursprung des Bedarfs. Der
bestätigende Prüflauf beanstandete dieselbe Stelle erneut. Erst dann wurde 5.13
vollständig gelesen: «API-Zugang für Dritte — Benutzer können API-Schlüssel
erzeugen, um R3cOSINT an Drittsysteme anzubinden. Erforderlich: Gültigkeitsdauer,
Widerruf, feingranularer Berechtigungsumfang pro Schlüssel, Ratenbegrenzung,
vollständige Protokollierung jedes Zugriffs.» Die Ratenbegrenzung dort gilt
ausschliesslich Schlüsseln für Dritte — ein Umfang, der bereits R3-F-091
zugewiesen ist.

Die Zurückweisung stützte sich auf das Vorkommen eines Wortes, nicht auf den
Abschnitt. Die Angabe ist gestrichen; es bleibt 5.4, und der Ursprung der
allgemeinen Eingangsvalidierung steht mit ADR 0002 (3.1, 3.9) ohnehin im
Eintrag. Der Vorgang ist in einer Achtung-Zeile des Eintrags festgehalten,
samt der falschen Begründung — sonst wird 5.13 beim nächsten Durchgang mit
derselben Herleitung wieder eingesetzt.

**Aus einem Befund ist eine neue Anforderung entstanden.** Die Prüfung des
falschen Querverweises legte offen, dass R3-F-017 nur die Wirkung prüft
(eingeschleuster Text löst kein Werkzeug aus), während ADR 0002 auch die Ursache
zusichert (dem Modell werden keine Werkzeugbeschreibungen übergeben). Ein
Programm könnte R3-F-017 grün bestehen und dem Modell trotzdem
Werkzeugbeschreibungen übergeben. Dasselbe Muster wie Befund F, an einer
weiteren Stelle.

## Behebung der Befunde

- **Prüfbarkeit (R6).** `R3-F-025_jeder_ausgabeweg_kodiert` benennt jetzt die
  Zähleinheit ausdrücklich: der Eintrag in der Registrierung der Module
  `export` beziehungsweise `graph`, weder die einzelne Funktion noch der
  einzelne Aufrufort. Die Formatliste steht nur noch in der Annahme als Stand
  der ersten Fassung, nicht im Test — ein siebtes Format wird von derselben
  Iteration erfasst, ohne dass der Test geändert wird.
- **Verfolgbarkeit (B5).** Neun Rückverweise nachgetragen. Zwei davon tragen
  fachlich: R3-F-091 hält fest, dass die allgemeine Ratenbegrenzung aus
  R3-F-027 kein Teilumfang ist und bei einem Schnitt von R3-F-091 nicht
  mitentfällt; R3-Q-006 hält fest, dass ein grüner Test von R3-F-025 nichts
  über die Darstellung im Browser aussagt.
- **D7.** Der Sammeltest von R3-F-024 bündelte mehrere Prüfstellen mal acht
  Angriffsformen mal zwei Richtungen unter einem Testnamen. Er ist in drei
  benannte Tests aufgeteilt, geschnitten nach Richtung und Herkunft der Angabe,
  wie R3-F-028 es vorführt. Umfang, Prüfsatz, Nachbedingung und Gegenprobe
  bleiben erhalten, ebenso die selbstskalierende Formulierung des Product
  Owners.
- **Folgekorrektur dabei:** Nach der Aufteilung zeigten die Ordnungsverweise
  «der erste Test» und «sein zweiter Test» in der Abhängigkeit und im
  Etappenentscheid ins Leere. Sie sind durch die Testnamen ersetzt; der
  Entscheid selbst ist unberührt.

## Zwei Funde, die in keinem Auftrag standen

Der Requirements Engineer hat beim Nachlesen von ADR 0002 zwei Sachverhalte
gefunden, nach denen niemand gefragt hatte. Beide sind nachgeprüft und
bestätigt.

**1. «Werkzeugverzeichnis» ist ein Homonym.** Der Projektauftrag verwendet den
Begriff in 5.17 für die fachliche Quellenliste in Anhang A des Konzepts («sie
stehen nicht im Werkzeugverzeichnis in Anhang A»), der Backlog ebenso in Zeile
299. Das ist eine andere Sache als das auslesbare Laufzeitverzeichnis des Moduls
`beschaffung`. Ohne Klärung wäre «der Test läuft über alle Einträge des
Werkzeugverzeichnisses» zweideutig — in einem Glossar, das im Kopf zusagt,
Homonyme zu vermeiden. Der Eintrag trägt deshalb eine Homonym-Warnung mit
Vorrangregel statt einer blossen Übernahme aus dem ADR.

**2. Der Mechanismus, auf den R3-F-025 sich beruft, existiert nicht.** Die
Annahme des Eintrags nennt «Architekturvertrag nach ADR 0002, Abschnitt 4.3».
Die sieben dort geführten Verträge sind ausnahmslos Import-Aussagen
(«`freigabe.vorschlag` importiert `freigabe.ausfuehrung` nicht», «ausser
`ausgang` importiert kein Modul eine Bibliothek für ausgehende HTTP-
Verbindungen»), geprüft durch einen Importprüfer der import-linter-Klasse
(Abschnitt 3.12). Ein Importprüfer prüft Importkanten, nicht die Vollständigkeit
einer Registrierung. Der genannte Weg verlangt also einen neuen Vertragstyp oder
einen zweiten Mechanismus. Im Eintrag festgehalten, damit der Software Architect
bei offenem Punkt 10 nicht davon ausgeht, das Werkzeug stehe bereits.

Der zweite Fund wiegt schwerer: Er hätte sonst erst bei der Umsetzung
zugeschlagen, mit einem Abnahmekriterium, das sich auf ein nicht vorhandenes
Prüfwerkzeug beruft.

## Glossar

Sechs Begriffe sind nachgetragen, weil R3 der Definition of Ready verlangt, dass
verwendete Fachbegriffe im Glossar stehen: **Antwortschema**, **Ausgabeweg**,
**Freigabevorlage**, **Rohantwort**, **Vorschlagsschema**, **Werkzeugverzeichnis**
(neuer Abschnitt `## W`). Drei davon waren in ADR 0002 vorbelegt und sind von
dort übernommen, drei waren nirgends definiert.

Die Definition von «Ausgabeweg» und das Abnahmekriterium von R3-F-025 sind
aufeinander abgestimmt: Zähleinheit ist der Eintrag in der Registrierung, weder
die einzelne Funktion noch der einzelne Aufrufort. Ohne diese Festlegung war das
Kriterium nicht prüfbar — das war der blockierende Befund der Wortlautprüfung.

## Nebenbefund: `maxTurns` des Product Owners

Der Product Owner ist zweimal mitten in der Arbeit an der Turn-Grenze gestoppt.
Gemessen: Abbruch nach 29 Werkzeugaufrufen bei `maxTurns: 25`; ein vollständiger
Einordnungsdurchgang braucht rund 44 Werkzeugaufrufe, etwa 38 Turns. Der Wert
steht neu auf **50** — dieselbe Bemessung wie bei der ersten Korrektur am
2026-08-25 (Static Software Tester, 30 auf 80). Nachgeführt in ADR 0001,
Commit `385ccad`.

**Dabei beobachtet:** Die Korrektur wirkte in der laufenden Sitzung nicht — der
Wert stand auf 50, bevor der Lauf startete, und der Lauf stoppte gleichwohl bei
25 Zügen. Das deutet darauf hin, dass die Rollendateien beim Sitzungsstart
gelesen und danach nicht erneut eingelesen werden. Als Beobachtung und nicht als
Festlegung in ADR 0001 vermerkt, Commit `aa3e797`; ein Einzelbeleg trägt keine
Festlegung.

## Was offen bleibt

- **Offene Punkte 6 bis 12 der Backlog-Tabelle** brauchen den Auftraggeber:
  Obergrenzen für Feldlänge und Antwortgrösse, Verhalten bei Teilverwurf,
  Höchstzahl der Abweisungen einer Modellantwort, Grenzen der eigenen
  Schnittstelle, Höchstzahl der Weiterleitungsschritte, Form der Registrierung
  der Ausgabewege, Ablageform der Anhänge.
- **R3-Q-001 bis R3-Q-005 tragen keinen benannten Stakeholder** und erfüllen R1
  damit nicht. Als offener Punkt aufgenommen, nicht in dieser Einheit behoben —
  das sind bestehende Einträge ausserhalb des Umfangs von Befund F.
- **ADR 0002, Zeile 393** verweist weiterhin pauschal auf R3-F-017, ohne die
  heutige Aufteilung in Wirkungs- und Ursachentest zu nennen. Inhaltlich
  weiterhin richtig; eine Präzisierung liegt beim Software Architect.
- **Es gibt weiterhin keine Testsuite und keinen `make dod`-Einstieg.** Die
  Glieder D1 bis D8 der Definition-of-Done-Kette sind auf diese Einheit nicht
  anwendbar, weil sie keinen Produktionscode enthält.

## Bestätigender Prüflauf

**Urteil: bestanden.** Geprüft wurden die Zähleinheit und die Schutzwirkung des
neu gefassten R3-F-025-Kriteriums, Vollständigkeit und Überschneidungsfreiheit
der drei neuen R3-F-024-Tests, die Widerspruchsfreiheit aller sechs
Glossareinträge gegen ADR 0002 und den Projektauftrag, und ob durch die
Behebungen neue Widersprüche entstanden sind. Kein Befund erreichte
Blockierschwere.

Vier kleinere Befunde sind anschliessend behoben worden: die Quellenangabe bei
R3-F-027 (siehe oben), eine Vorrangregel im Glossar, die eine wörtliche Wendung
behauptete, die an der selbst zitierten Stelle so nicht steht, zwei
Abgrenzungen, die nur in eine Richtung lesbar waren, und eine ungenaue
Analogie: Von R3-F-028 übernommen ist das Vorgehen — einen überladenen
Sammeltest zerlegen —, nicht dessen Schnittkriterium.

## Einschränkung, die zur Redlichkeit gehört

Der bestätigende Prüflauf ist **nicht in beiden Hälften unabhängig**. Er lief
auf Sonnet und damit auf einem anderen Modell als der Requirements Engineer
(Opus), von dem das Gewicht der neuen Formulierungen stammt. Die Korrekturen
des Product Owners entstanden ebenfalls auf Sonnet; für sie ist die Vorgabe aus
3.4 nicht erfüllt. Sie waren kleine Sachkorrekturen — eine Zahl, ein
Querverweis, Tabellenzeilen — und sind vom Koordinator mechanisch gegen die
Datei geprüft worden. Das ersetzt die Modelltrennung nicht, es begrenzt nur den
Schaden.

Ebenfalls festzuhalten: Ein Prüfskript des Koordinators erzeugte zwei
Fehlalarme, weil verkettete `sed`-Ersetzungen die jeweils vorangehende
rückgängig machten. Die Arbeit war korrekt, die Prüfung nicht. Ein
überraschendes Prüfergebnis wird deshalb am Text nachgesehen, nicht geglaubt.

## Definition of Done

Anwendbar und erfüllt: beide Dateien maschinell auf Schweizer Schreibweise
geprüft (kein Eszett, keine typografischen Anführungszeichen), alle Summen aus
dem Dateiinhalt nachgerechnet statt fortgeschrieben, Kennungen auf Eindeutigkeit
geprüft, jede Etappenangabe gegen ihren Block geprüft, zwei unabhängige
Prüfungen auf je einem anderen Modell als die Umsetzung, alle Befunde behoben
oder mit Begründung zurückgewiesen, kein halbfertiger Zustand committet.
