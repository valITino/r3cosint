# Walkthrough vor Sprint 2 — Befundliste

| | |
|---|---|
| **Arbeitsprodukt nach** | Projektauftrag 6.7 (Reviewtechnik "Walkthrough der Backlog-Einträge vor dem Sprint"; Fehlerfindung getrennt von Fehlerkorrektur) und `docs/06_Definition_of_Ready_und_Done.md`, Teil 1, Abschnitt "Geltung" (Sichtung gegen die vier Glieder, Befundliste ohne Lösungsvorschlag) |
| **Einheit** | S2 (Sprint 2 der Etappe 1: Sprintplanung mit Walkthrough) |
| **Datum** | 2026-11-10 |
| **Verfasser-Rolle** | Requirements Engineer |
| **Gegenstand** | Die sieben Kandidaten für Sprint 2 nach `docs/sprints/sprint-01.md`, Abschnitt 2: R3-F-026, R3-F-002, R3-F-009, R3-F-014, R3-F-015, R3-F-016, R3-F-028; dazu kurz die vier Reserveeinträge R3-F-027, R3-F-024, R3-F-020 und R3-F-004, je mit dem Vermerk "nur falls gezogen". Wortlaut der Einträge samt Vormerkungen in `docs/05_Product_Backlog.md`, Abschnitt "Etappe 1", Stand nach der Einheit D27 (Commit `2307ffa72cdd595689c698dd59fee3a335f68034`); die Eintragsblöcke sind nicht verändert. Den Sprint-Inhalt entscheidet der Product Owner parallel zu diesem Walkthrough |
| **Massstab** | Je Abnahmekriterium die vier Glieder Umfang, Prüfsatz, Nachbedingung und Gegenprobe nach `docs/06_Definition_of_Ready_und_Done.md`, Teil 1, "Notation der Abnahmekriterien (R6)" (Vorschlag zur Bestätigung durch den Auftraggeber, bisher nicht bestätigt; hier als Prüfraster verwendet, nicht als gesetzte Regel); je Eintrag R3 (eindeutig, Fachbegriffe im Glossar `docs/03_Glossar.md`), R4 (vollständig in sich, offene Punkte als Annahme benannt) und R6 (prüfbar, hier: in Sprint 2 als ehrlicher Test formulierbar, ohne Teile des Kriteriums auszulassen); dazu B1 und B6, wo ein Befund sie berührt |
| **Grundlage** | Projektauftrag 4.4, 5.2, 5.3, 5.4, 5.8, 5.17, 6.5, 6.7; ADR 0002, Abschnitte 4.1 bis 4.3; ADR 0007, Teil A (Entscheide 13, 14, 16, 17, 25, 27; Grenzen GS-6, GS-22, GS-43); Walkthrough vor Sprint 1 (`docs/sprints/sprint-01-walkthrough.md`, W1-19, W1-21, W1-64, W1-66 bis W1-71, W1-75); Angaben zum gebauten Stand (Pakete core, spur, fall, kanon; übrige Pakete ohne Fachlogik; api ohne Route) aus der Tatsachendatei des Koordinators vom 2026-11-10 (Fremdbeleg, nicht selbst gemessen) |
| **Nicht geprüft** | R1, R2, R5, R7 bis R10 (Ready-Prüfung des Product Owners), ausser wo ein Befund sie streift; Prüfaufwand; Reihenfolge und Sprintschnitt; die Festlegung des Software Architects für Sprint 2 (entsteht parallel) |
| **Rechtlich berührte Stellen** | Befunde mit der Marke [GRC] berühren 5.2 (Freigabe), Abfragen nach aussen (Bekanntgabe, 5.17) oder den präskriptiven Teil (4.4). Sie sind an die GRC-Rolle gekennzeichnet und hier nicht bewertet |

## Lesart der Schwere

| Schwere | Bedeutung |
|---|---|
| **blockierend** | Das Kriterium lässt sich in Sprint 2 nicht als ehrlicher Test formulieren, oder es lässt mehr als eine Lesart zu, von der abhängt, ob der Test grün werden kann, ohne Teile auszulassen. Der Eintrag erfüllt in dieser Form die Definition of Ready für Sprint 2 aus Sicht des Requirements Engineers nicht (blockierend für die Ready-Prüfung) |
| **Nachbesserung** | Kein Blocker. Ein Glied, eine Bestimmung oder eine Annahme fehlt; die Nachbesserung kommt als eigener Backlog-Eintrag über den Product Owner herein (B4) |
| **Hinweis** | Kein Blocker, keine Nachbesserung zwingend; zur Kenntnis für Product Owner, Software Architect oder GRC-Rolle |

Ein Befund nennt, was fehlt oder mehrdeutig ist, nicht, wie es zu beheben ist
(6.7: gesammelt, nicht gelöst). Wo ein Befund aus Sprint 1 unverändert
weiter gilt, ist er mit seiner Kennung W1-nn genannt und nicht neu gezählt,
ausser er ist unter den Bedingungen von Sprint 2 neu zu bewerten.

## Befunde

### R3-F-026 — Werkzeugverzeichnis: Vollständigkeit und Inhalt je Eintrag

| Kennung | Eintrag | Kriterium | Befund | Schwere |
|---|---|---|---|---|
| W2-01 | R3-F-026 | R3-F-026_kein_werkzeug_am_verzeichnis_vorbei; R3, R6 | Was ein Werkzeug ist, bestimmt weder der Eintrag noch das Glossar. In Sprint 2 besteht keine Quelle und keine MCP-Anbindung (R3-F-013 nicht unter den Kandidaten); ob ein synthetisches Prüfwerkzeug ohne Quelle als Werkzeug im Sinn dieses Eintrags zählt, entscheidet, ob der Test etwas anderes als ein leeres oder rein zu Prüfzwecken befülltes Verzeichnis prüft. | blockierend |
| W2-02 | R3-F-026 | R3-F-026_kein_werkzeug_am_verzeichnis_vorbei; Umfang | Die Story spricht von "jedem erreichbaren Werkzeug", das Kriterium vom Aufrufpfad, der "ausschliesslich" eingetragene Werkzeuge kennt; erreichbar über welchen Weg (Aufrufpfad von beschaffung, Python-Import, MCP, HTTP) ist als Zähleinheit nicht benannt. | Nachbesserung |
| W2-03 | R3-F-026 | R3-F-026_kein_werkzeug_am_verzeichnis_vorbei; Prüfsatz | "Etwa über einen eigenen Router oder eine eigene Aufrufkante" nennt Beispiele, keinen Prüfsatz; welche Arten der Anbindung am Verzeichnis vorbei der Test vorführt, ist offen. | Nachbesserung |
| W2-04 | R3-F-026 | R3-F-026_kein_werkzeug_am_verzeichnis_vorbei; Nachbedingung | "Lässt sich nicht aufrufen" nennt weder die beobachtbare Reaktion (Fehler, Protokolleintrag oder keiner) noch den Zustand danach (keine Abfrage nach aussen, kein Kontingentverbrauch, kein Eintrag im Bestand). | Nachbesserung |
| W2-05 | R3-F-026 | R3-F-026_kein_werkzeug_am_verzeichnis_vorbei; Gegenprobe | Der zulässige Fall (ein registriertes Werkzeug ist über den Aufrufpfad aufrufbar) fehlt; ohne ihn ist das Kriterium auch grün, wenn gar kein Werkzeug aufrufbar ist. | Nachbesserung |
| W2-06 | R3-F-026 | R3-F-026_kein_werkzeug_am_verzeichnis_vorbei; R6 | Die Zeile "Achtung" vom 2026-08-26 hält fest, dass der Test einen noch nicht bestehenden Mechanismus voraussetzt (neuer Vertragstyp oder zweiter Prüfweg), dessen Form der Software Architect entscheidet; die Prüfbarkeit hängt an dieser Festlegung. | Hinweis |
| W2-07 | R3-F-026 | R3-F-026_eintrag_traegt_pflichtangaben; R3, Umfang | "Die für Kontingent- und Feldgrenzen relevanten Grenzwerte" bestimmt nicht, welche Grenzwerte Pflicht sind (Kontingent je Fall, je Tag, je Quelle; Feldlänge; Antwortgrösse); die Feldgrenzen gehören nach dem Glossar zum Antwortschema (R3-F-022). | Nachbesserung |
| W2-08 | R3-F-026 | R3-F-026_eintrag_traegt_pflichtangaben; R4, R10 | Der "Verweis auf das Antwortschema (R3-F-022)" setzt ein Antwortschema voraus; R3-F-022 ist nicht unter den Kandidaten. Ob ein Verweis auf ein nicht bestehendes Antwortschema die Pflichtangabe erfüllt, ist nicht benannt. | Nachbesserung |
| W2-09 | R3-F-026 | R3-F-026_eintrag_traegt_pflichtangaben; R3, B1 | Wertebereich und Bedeutung des "Fallbindungskennzeichens" sind nicht bestimmt. Ein Kennzeichen mit einem Wert "nicht fallgebunden" stünde gegen R3-F-002 und 5.4 ("ohne eröffneten Fall kein einziges Werkzeug"). | Nachbesserung |
| W2-10 | R3-F-026 | R3-F-026_eintrag_traegt_pflichtangaben; Prüfsatz | "Ein Eintrag mit einer fehlenden dieser Angaben lässt den Test fehlschlagen" nennt den Prüffall nicht und lässt offen, ob die Prüfung beim Registrieren abweist oder erst der Test am Bestand den Mangel findet. | Nachbesserung |
| W2-11 | R3-F-026 | R3-F-026_eintrag_traegt_pflichtangaben; Umfang, Gegenprobe | Bei leerem Verzeichnis ist die Iteration "für jedes registrierte Werkzeug" leer und grün; eine Mindestzahl von Einträgen oder ein vollständiger Eintrag als Gegenprobe ist nicht verlangt. | Nachbesserung |
| W2-12 | R3-F-026 | Vormerkung 2026-11-09 (S1.5); R3 | Die Vormerkung (werkzeug im Herkunftssatz nur noch aus dem geschlossenen Werkzeugverzeichnis, DF-S15-D16-01) steht in keinem Abnahmekriterium; ob sie mit diesem Eintrag fällig wird, und wie sich der "Name" im Verzeichnis zur Angabe werkzeug in der Form einer Kennung (ADR 0007, Entscheid 25) verhält, ist nicht benannt. | Hinweis |

### R3-F-002 — Fallbindung: kein Werkzeug ohne Fall

| Kennung | Eintrag | Kriterium | Befund | Schwere |
|---|---|---|---|---|
| W2-13 | R3-F-002 | R3-F-002_kein_werkzeug_ohne_fall; R6, Umfang | W1-66 gilt unter den Bedingungen von Sprint 2 weiter, soweit nicht feststeht, ob ein synthetisches Prüfwerkzeug als "registriertes Werkzeug" zählt (W2-01): Davon hängt ab, ob die Iteration "über alle registrierten Werkzeuge" etwas anderes als eine leere Menge prüft. | blockierend |
| W2-14 | R3-F-002 | R3-F-002_kein_werkzeug_ohne_fall; Nachbedingung, R4 | "Abgewiesen und protokolliert" ohne gültigen Fallbezug: Die Spuren bestehen je Fall (ADR 0007, Entscheide 13 und 16), und nach ADR 0007, GS-22, stehen abgewiesene Vorgänge in keiner Spur; ein Protokoll abgewiesener Vorgänge ist dort R3-F-019 oder R3-F-027 zugeordnet. Wo und in welcher Form die Abweisung protokolliert wird, entscheidet, ob der Test grün werden kann. | blockierend |
| W2-15 | R3-F-002 | R3-F-002_kein_werkzeug_ohne_fall; R4 | W1-67 gilt weiter und ist mit dem gebauten Zustandsvorrat konkreter: Ob ein Fall im Zustand abgeschlossen einen gültigen Fallbezug bildet, ist nicht benannt (ADR 0007, Entscheid 22: erreichbar sind aktiv und abgeschlossen). | Nachbesserung |
| W2-16 | R3-F-002 | R3-F-002_kein_werkzeug_ohne_fall; Prüfsatz | Die Arten ungültigen Fallbezugs, gegen die geprüft wird, sind nicht genannt (fehlend, unbekannte Kennung, Kennung falscher Form, Fall in einem nicht gültigen Zustand). | Nachbesserung |
| W2-17 | R3-F-002 | R3-F-002_kein_werkzeug_ohne_fall; Nachbedingung | W1-68 gilt weiter: Der Zustand nach der Abweisung (keine Abfrage an eine Gegenstelle, kein Kontingentverbrauch, kein Bestand) ist nicht genannt. | Nachbesserung |
| W2-18 | R3-F-002 | R3-F-002_kein_werkzeug_ohne_fall; Gegenprobe | Der zulässige Fall (Aufruf mit gültigem Fallbezug läuft durch) fehlt im Wortlaut (W1-66, zweiter Teil). | Nachbesserung |
| W2-19 | R3-F-002 | Story; R3 | Die Story verlangt die Zuordnung zu "einer Person"; vor der Anmeldung (Etappe 3) ist die Person eine Benutzerkennung ohne Authentifizierung (ADR 0007, E-S1-07 a, GS-1). Die Rolle "Aufsicht" der Story ist in `docs/02_Stakeholderliste.md` kein eigener Stakeholder; dort führt S-06 (Kantonaler Datenschutzbeauftragter) die Funktion "Aufsicht über die Datenbearbeitung", ob die Story diese Aufsicht meint oder eine weitere (etwa die nach 5.3 genannte), ist nicht festgelegt (R1 prüft der Product Owner). | Hinweis |

### R3-F-009 — Negativbefunde erscheinen zwingend

| Kennung | Eintrag | Kriterium | Befund | Schwere |
|---|---|---|---|---|
| W2-20 | R3-F-009 | R3-F-009_negativbefund_protokolliert; R6 | W1-69 ist unter den Bedingungen von Sprint 2 neu zu bewerten: Ob eine "Abfrage" eine über den Aufrufpfad von beschaffung und nach Freigabe (R3-F-014) ausgeführte Abfrage gegen eine Testgegenstelle sein muss oder ein Aufruf eines Prüfwerkzeugs ohne Freigabeweg genügt, ist nicht benannt; davon hängt ab, ob der Test ohne gezogenen Ausführungsweg grün werden kann. | blockierend |
| W2-21 | R3-F-009 | R3-F-009_negativbefund_protokolliert; R3 [GRC] | "Leeres Ergebnis" ist nicht bestimmt: leere Antwort, Antwort ohne Treffer, Zeitüberschreitung, Fehler der Gegenstelle, Abweisung durch Positivliste oder Kontingent, Antwort, die dem Antwortschema nicht entspricht (R3-F-022). Das Glossar grenzt Negativbefund gegen den Nichttreffer im Sinne der Massendatenerhebung ab; die schriftliche Abgrenzung durch die GRC-Rolle (4.4) steht aus. | Nachbesserung |
| W2-22 | R3-F-009 | R3-F-009_negativbefund_protokolliert; R3, R4 | "Protokolleintrag vom Typ Negativbefund": Der Eintragstyp negativbefund steht nicht im Vorrat (ADR 0007, Entscheid 14: kommt mit seinem Eintrag als Erweiterung der Prüfbedingung); Spur und Schlüssel der Nutzlast sind nicht benannt. Nach dem Glossar enthält die Arbeitsspur "zwingend die Negativbefunde". | Nachbesserung |
| W2-23 | R3-F-009 | R3-F-009_negativbefund_protokolliert; Prüfsatz | W1-70 gilt weiter: "Ein Protokoll, das nur Treffer enthält, lässt den Test fehlschlagen" lässt zwei Lesarten zu (absichtlich veränderter Stand als Prüffall oder Aussage über den Bestand). | Nachbesserung |
| W2-24 | R3-F-009 | R3-F-009_negativbefund_protokolliert; Gegenprobe | W1-71 gilt weiter: Der Prüffall, dass eine Abfrage mit Treffer keinen Negativbefund erzeugt, fehlt. | Nachbesserung |
| W2-25 | R3-F-009 | R3-F-009_negativbefund_protokolliert; Nachbedingung | Welche Kennzeichnung (quellenaussage oder schlussfolgerung, ohne Vorgabewert, ADR 0007, Entscheid 13) ein Negativbefund trägt, ist nicht benannt (vgl. W1-64). | Nachbesserung |
| W2-26 | R3-F-009 | Story; Umfang | Das Glossar und 5.3 verlangen den Negativbefund "im Protokoll und im Export"; das Kriterium prüft nur das Protokoll. Der Export entsteht nicht in Etappe 1. | Hinweis |

### R3-F-014 — Freigabesperre zwischen Vorschlag und Ausführung

| Kennung | Eintrag | Kriterium | Befund | Schwere |
|---|---|---|---|---|
| W2-27 | R3-F-014 | R3-F-014_keine_verkettung; Umfang, Prüfsatz, R3 | "Es existiert kein Codepfad, über den ein Vorschlag ... zur Ausführung führt" ist eine Nichtexistenzaussage ohne benanntes Prüfmittel. Vertrag 1 (ADR 0002, 4.3) belegt das Fehlen einer Importkante; ob "Codepfad" auch Wege über ein drittes Modul, einen Rückruf, ein Ereignis, einen dynamischen Import oder die Datenbank umfasst, ist nicht bestimmt. Von dieser Lesart hängt ab, ob ein grüner Test die Aussage trägt. | blockierend |
| W2-28 | R3-F-014 | R3-F-014_keine_verkettung; R3, R6 [GRC] | "Menschliche Bestätigung" und "Freigabe-Kennung nur aus interaktiver Sitzung" (ADR 0002, 4.2): Vor der Anmeldung (Etappe 3) und ohne Oberfläche (5.6) gibt es keine Sitzung; woran eine menschliche von einer maschinell erzeugten Bestätigung unterschieden wird, ist nicht bestimmt. Davon hängt ab, ob dieser Teil des Kriteriums in Sprint 2 geprüft oder ausgelassen würde (5.2). | blockierend |
| W2-29 | R3-F-014 | R3-F-014_keine_verkettung; Nachbedingung | "Wird abgewiesen" nennt weder die beobachtbare Reaktion (Fehler, Protokolleintrag und wo, vgl. W2-14) noch den Zustand danach (keine Abfrage nach aussen, kein Kontingentverbrauch, Freigabevorlage unverändert offen). | Nachbesserung |
| W2-30 | R3-F-014 | R3-F-014_keine_verkettung; Prüfsatz | Nur "ohne Freigabe-Kennung" ist genannt; nicht genannt sind unbekannte, bereits verbrauchte (Einmalverwendung, ADR 0002, 4.2), einer anderen Freigabevorlage oder einem anderen Fall gehörende Kennungen und eine Ausführung, deren Umfang oder Zielmenge von der Freigabevorlage abweicht (Glossar, Freigabevorlage). | Nachbesserung |
| W2-31 | R3-F-014 | R3-F-014_keine_verkettung; Gegenprobe | Der zulässige Fall (Ausführung mit gültiger, unverbrauchter Freigabe-Kennung läuft genau einmal) fehlt. | Nachbesserung |
| W2-32 | R3-F-014 | R3-F-014_keine_verkettung; Umfang, Gegenprobe | "Es existiert keine Konfiguration, die diese Prüfung deaktiviert": Umfang (Umgebungsvariablen, Dateien unter `deploy/konfiguration/`, Parameter, Testschalter) und Prüfmittel sind nicht benannt, und für die Nullaussage fehlt der Nachweis, dass die Suche einen eingebrachten Schalter fände. | Nachbesserung |
| W2-33 | R3-F-014 | Story; Umfang | Die Story verlangt eine Vorschau "welche Abfragen an welche Dienste, mit welchem Kontingentverbrauch"; kein Kriterium dieses Eintrags prüft die Vorschau (den Verbrauch darin prüft R3-F-016). | Nachbesserung |
| W2-34 | R3-F-014 | Story; R3, B1 [GRC] | Die Story lässt die Ermittlerin bestätigen; nach dem Glossar (Fallverantwortlicher, 5.8) ist "Freigaben erteilen" ein Recht des Fallverantwortlichen zusätzlich zur Rolle Ermittler. Wer eine Freigabe erteilen darf, ist damit nicht eindeutig. | Nachbesserung |
| W2-35 | R3-F-014 | R3-F-014_keine_verkettung; Nachbedingung | Nach dem Glossar steht die Freigabe "mit Zeitpunkt und Person im Protokoll"; das Kriterium verlangt keinen Protokolleintrag der Freigabe, und der Eintragstyp freigabe steht nicht im Vorrat (ADR 0007, Entscheid 14). | Nachbesserung |

### R3-F-015 — Positivliste nach aussen

| Kennung | Eintrag | Kriterium | Befund | Schwere |
|---|---|---|---|---|
| W2-36 | R3-F-015 | R3-F-015_ziel_ausserhalb_abgewiesen; Umfang, R3 | "Ziel", "Gegenstelle" und "Verbindungsversuch" sind nicht bestimmt; ob ein Ziel durch Name, Adresse, Schema und Anschluss oder durch einen Teil davon bestimmt ist, ist als Zähleinheit offen (R3-F-028 behandelt "dieselbe Gegenstelle mit anderem Anschluss" als eigenen Fall). | Nachbesserung |
| W2-37 | R3-F-015 | R3-F-015_ziel_ausserhalb_abgewiesen; Gegenprobe | Der zulässige Fall (Verbindung zu einem Ziel der Positivliste gelingt) fehlt. In einer Teststufe ohne Netz nach aussen scheitert jeder Verbindungsversuch ohnehin; ohne Gegenprobe ist der Test auch ohne Positivliste grün. | Nachbesserung |
| W2-38 | R3-F-015 | R3-F-015_ziel_ausserhalb_abgewiesen; Nachbedingung [GRC] | "Protokolleintrag mit dem versuchten Ziel": Ort (Spur eines Falls, anderes Protokoll; vgl. W2-14) und Form sind nicht benannt. Ein Ziel kann Bestandteile der Abfrage tragen (etwa in der Adresse); ob das versuchte Ziel als Klartext protokolliert werden darf, berührt R3-F-011 und die Bekanntgabe (5.17). | Nachbesserung |
| W2-39 | R3-F-015 | R3-F-015_ziel_ausserhalb_abgewiesen; Nachbedingung | "Scheitert" bestimmt den Zustand danach nicht: ob vor der Abweisung eine Namensauflösung, ein Verbindungsaufbau oder ein Byte an die Gegenstelle zulässig ist, ist nicht benannt. | Nachbesserung |
| W2-40 | R3-F-015 | Story, Kriterium; R4 | Form der Einträge der Positivliste (Name, Adresse, Schema, Anschluss), Ort (Konfiguration oder Code), Pflege (wer, Protokoll der Änderung) und Geltung je Umgebung (5.16) sind nicht benannt; R3-F-028 setzt für IP-Literale Adressen als Einträge voraus. | Nachbesserung |
| W2-41 | R3-F-015 | R3-F-015_ziel_ausserhalb_abgewiesen; Umfang | "Jeder Versuch darüber hinaus" (Story) umfasst auch Verbindungen ausserhalb von ausgang; das Kriterium prüft nur Versuche über ausgang, Vertrag 2 nur Importe. Wege ausserhalb (Namensauflösung anderer Bibliotheken, Betrieb) gehören zu R3-C-004. | Hinweis |

### R3-F-016 — Kontingentgrenzen je Fall und je Tag

| Kennung | Eintrag | Kriterium | Befund | Schwere |
|---|---|---|---|---|
| W2-42 | R3-F-016 | R3-F-016_grenze_greift; Umfang, R3 | "Je Fall und je Tag": Tag in welcher Zeitzone (core führt UTC) und als Kalendertag oder gleitende 24 Stunden; Grenze je Werkzeug, je Quelle oder über alle; Zähleinheit (Werkzeugaufruf, Abfrage, Ergebnis, Verbrauchseinheit des Anbieters) sind nicht benannt. | Nachbesserung |
| W2-43 | R3-F-016 | R3-F-016_grenze_greift; R4 | Wert, Ort (Grenzwerte im Werkzeugverzeichnis nach R3-F-026), Konfigurierbarkeit und setzende Instanz der Grenze sind nicht benannt und nicht als Annahme geführt; das Glossar fasst Kontingent als "Abfragebudget einer externen Quelle", ohne zu sagen, ob die Grenze von R3cOSINT oder das Budget des Anbieters gemeint ist. | Nachbesserung |
| W2-44 | R3-F-016 | R3-F-016_grenze_greift; Nachbedingung | "Abgewiesen und protokolliert": Spur und Eintragstyp (nicht im Vorrat, ADR 0007, Entscheid 14) und der Zustand danach (Verbrauch unverändert, keine Abfrage nach aussen) sind nicht benannt. | Nachbesserung |
| W2-45 | R3-F-016 | R3-F-016_grenze_greift; Prüfsatz | Die Prüffälle sind nicht genannt: letzte zulässige und erste abgewiesene Abfrage an der Grenze, Tageswechsel, zwei Fälle, gleichzeitige Ausführungen (Zählung in derselben Transaktion wie die Ausführung, ADR 0002, 4.2). | Nachbesserung |
| W2-46 | R3-F-016 | R3-F-016_grenze_greift; Gegenprobe | Der zulässige Fall fehlt: unterhalb der Grenze läuft die Abfrage, ein anderer Fall am selben Tag ist nicht betroffen. | Nachbesserung |
| W2-47 | R3-F-016 | R3-F-016_grenze_greift; Nachbedingung, R3 | "Der aktuelle Verbrauch ist je Fall abrufbar": Schnittstelle (in Etappe 1 Dienstschicht ohne HTTP-Route, ADR 0007, Entscheid 27) und Form (je Tag, je Werkzeug, Summe) sind nicht benannt. | Nachbesserung |
| W2-48 | R3-F-016 | R3-F-016_grenze_greift; R10 | "Erscheint in der Freigabevorschau" setzt die Vorschau aus R3-F-014 voraus; die Abhängigkeit ist im Eintrag nicht benannt (genannt ist nur R3-F-026), und "Freigabevorschau" steht nicht im Glossar. | Nachbesserung |
| W2-49 | R3-F-016 | Story; Umfang | "Nicht unbemerkt aufgebraucht" kann eine Anzeige oder Warnung vor dem Erreichen der Grenze meinen; das Kriterium prüft nur das Verhalten bei erreichter Grenze. | Hinweis |

### R3-F-028 — Positivliste nach aussen: Weiterleitung, Namensauflösung und IP-Literale

| Kennung | Eintrag | Kriterium | Befund | Schwere |
|---|---|---|---|---|
| W2-50 | R3-F-028 | R3-F-028_weiterleitung_wird_erneut_geprueft; Umfang | Wie die Schritte gezählt werden, ist offen: ob der erste Versuch mitzählt und ob bei einer Höchstzahl von drei die dritte oder die vierte Weiterleitung abgewiesen wird. | Nachbesserung |
| W2-51 | R3-F-028 | R3-F-028_weiterleitung_wird_erneut_geprueft; Gegenprobe | Der zulässige Fall fehlt: eine Weiterleitung auf ein Ziel der Positivliste wird als neuer Versuch geprüft und durchgeführt; eine Kette genau bis zur Höchstzahl gelingt. | Nachbesserung |
| W2-52 | R3-F-028 | R3-F-028_weiterleitung_wird_erneut_geprueft; R3 | "Dieselbe Gegenstelle mit anderem Anschluss oder mit http statt https" setzt voraus, dass Anschluss und Schema Teil des Eintrags der Positivliste sind; das ist nicht bestimmt (W2-36, W2-40), und ob ein solches Ziel abgewiesen oder nur erneut geprüft wird, hängt davon ab. | Nachbesserung |
| W2-53 | R3-F-028 | R3-F-028_weiterleitung_wird_erneut_geprueft; R4 | Die Annahme von drei Weiterleitungsschritten ist nicht bestätigt (mit S-05, offene Vorlage beim Auftraggeber); "prüft die wirksame Einstellung des HTTP-Clients" bindet den Prüfsatz an eine Bibliothek, die nicht festgelegt ist. | Hinweis |
| W2-54 | R3-F-028 | R3-F-028_namensaufloesung_einmal_und_geprueft; R4, R6 | Eine Adresse in einem privaten, verbindungslokalen, Rückschleifen- oder "anderweitig nicht öffentlich geführten" Bereich wird abgewiesen; eine Testgegenstelle im internen Netz des Prüfstapels hat eine solche Adresse. Ob es dafür eine Ausnahme gibt und wie sie sich zu "keine Einstellung" (5.2, 5.4) verhält, ist nicht benannt; davon hängt ab, ob die Gegenproben dieses Eintrags und von R3-F-015 in der Teststufe gebaut werden können. Die Liste der Bereiche ist mit "anderweitig" offen. | blockierend |
| W2-55 | R3-F-028 | R3-F-028_namensaufloesung_einmal_und_geprueft; Gegenprobe | Der zulässige Fall fehlt: ein Name der Positivliste löst einmal auf eine zulässige Adresse auf, und die Verbindung entsteht gegen genau diese Adresse. | Nachbesserung |
| W2-56 | R3-F-028 | R3-F-028_namensaufloesung_einmal_und_geprueft; Umfang | Löst ein Name auf mehrere Adressen auf (mehrere Einträge, IPv4 und IPv6), ist nicht benannt, welche geprüft werden und gegen welche verbunden wird. | Nachbesserung |
| W2-57 | R3-F-028 | R3-F-028_namensaufloesung_einmal_und_geprueft; Prüfsatz | Der Prüffall "bei der zweiten Abfrage eine andere Adresse" setzt eine steuerbare Namensauflösung in der Teststufe voraus; die Prüffälle der Normalform (Grossschreibung, abschliessender Punkt, internationalisierter Name) sind mitgemeint, nicht genannt. | Hinweis |
| W2-58 | R3-F-028 | R3-F-028_ip_literal_wie_normalform_entschieden; Prüfsatz | Für IPv6 nennt der Prüfsatz nur die IPv4-in-IPv6-Abbildung; verkürzte und ausgeschriebene Form, Gross- und Kleinschreibung und Zonenangabe sind nicht genannt. | Nachbesserung |
| W2-59 | R3-F-028 | R3-F-028_ip_literal_wie_normalform_entschieden; Gegenprobe | Dass eine hinterlegte Adresse in jeder Schreibweise zugelassen wird, ist nur über "dieselbe Entscheidung" mitgemeint und nicht als Prüffall benannt; sie steht zudem unter W2-54. | Nachbesserung |
| W2-60 | R3-F-028 | R3-F-028_ip_literal_wie_normalform_entschieden; R3 | "Nicht selbst als Eintrag hinterlegt": ob ein IP-Literal zugelassen wird, auf das ein hinterlegter Name auflöst, lässt der Wortlaut offen. | Nachbesserung |

### Querschnitt der Kandidaten

| Kennung | Eintrag | Kriterium | Befund | Schwere |
|---|---|---|---|---|
| W2-61 | R3-F-002, R3-F-026, R3-F-016 | Glossar; R3 | Kein Glossareintrag für Werkzeug, Werkzeugaufruf, Aufrufpfad und Registrierung (registriertes Werkzeug); das Glossar trägt allein Werkzeugverzeichnis. "Werkzeug" ist zudem im Harness belegt (Aufgabenwerkzeug, CLAUDE.md). | Nachbesserung |
| W2-62 | R3-F-015, R3-F-028 | Glossar; R3 | Kein Glossareintrag für Gegenstelle, Ziel, Verbindungsversuch und Weiterleitung; der Eintrag Positivliste verwendet "Gegenstellen" ohne Bestimmung. | Nachbesserung |
| W2-63 | R3-F-014, R3-F-016 | Glossar; R3 | Kein eigener Glossareintrag für Freigabe-Kennung (nur im Eintrag Freigabevorlage erwähnt), Freigabevorschau und Vorschau (ADR 0002, 4.1 und 4.2) und Ausführung. | Nachbesserung |
| W2-64 | R3-F-002, R3-F-009, R3-F-016 | Glossar; R3 | Kein Glossareintrag für Abfrage und Fallbezug; das Glossar nennt Abfrage nur innerhalb von Bekanntgabe ("jede Abfrage an eine externe Quelle"). | Nachbesserung |
| W2-65 | R3-F-009, R3-F-015, R3-F-016 | Glossar; R3 | Wortlaut von Glossar und Kriterien weicht ab: Negativbefund ist im Glossar "eine ausgeführte Abfrage ohne Treffer", im Kriterium "eine Abfrage mit leerem Ergebnis"; Kontingent ist im Glossar das Budget einer Quelle, in R3-F-016 eine Grenze je Fall und Tag. | Hinweis |
| W2-66 | R3-F-002, R3-F-014, R3-F-015, R3-F-016, R3-F-028 | Nachbedingung; B1 | Fünf Kandidaten verlangen bei einer Abweisung einen Protokolleintrag; ADR 0007, GS-22, hält für Sprint 1 fest, dass abgewiesene Vorgänge in keiner Spur stehen, und ordnet ein Protokoll abgewiesener Vorgänge R3-F-019 oder R3-F-027 zu. Für die Abweisungen von Sprint 2 ist der Ort nicht benannt. | Nachbesserung |
| W2-67 | R3-F-009, R3-F-014, R3-F-016 | R4 | Jeder neue Eintragstyp braucht nach R3-F-011, zweite Zeile "Achtung" (7), eine Zeile in der positiven Formprüfung und Testwerte; kein Kandidat nennt das. | Hinweis |
| W2-68 | alle Kandidaten | R4 | Kein Eintrag beschreibt das synthetische Prüfwerkzeug und die Testgegenstelle, auf die die Kandidaten ohne echte Quelle angewiesen sind, und ob ein Prüfwerkzeug im Werkzeugverzeichnis des Produktionscodes steht. | Hinweis |
| W2-69 | R3-F-014, R3-F-015, R3-F-016, R3-F-028 | B6 [GRC] | Abfragen nach aussen sind Bekanntgaben (Glossar; 5.17), die Freigabe ist Verfahrensgarantie nach 5.2. Die Konformitätsanalyse deckt bisher die Funktion F-01 (Fall); ob die Funktionen dieser Kandidaten vor dem Bau eine eigene Einordnung brauchen, ist nicht benannt. | Hinweis |

### R3-F-027 — Eingangsvalidierung der eigenen HTTP-Schnittstelle (nur falls gezogen)

| Kennung | Eintrag | Kriterium | Befund | Schwere |
|---|---|---|---|---|
| W2-70 | R3-F-027 | alle drei Kriterien; R6 | api hat keine Route (ADR 0007, Entscheid 27); die Iteration über die vorhandenen Endpunkte ist leer und grün, die Grössen- und die Ratenbegrenzung haben keinen Gegenstand. | blockierend |
| W2-71 | R3-F-027 | R3-F-027_ratenbegrenzung_greift; R3 | "Herkunft" ist vor der Anmeldung nicht bestimmt (Adresse, Sitzung, Person). | Nachbesserung |
| W2-72 | R3-F-027 | R3-F-027_anfrage_ausserhalb_schema_abgewiesen, R3-F-027_anfragegroesse_begrenzt; Gegenprobe | Der zulässige Fall (gültige Anfrage, Anfrage unter der Grenze) fehlt; beim zweiten Kriterium fehlt der Zustand danach. | Nachbesserung |
| W2-73 | R3-F-027 | Annahme, Vormerkung; R4 | Die Annahmewerte sind nicht bestätigt (offene Vorlage beim Auftraggeber); GS-22 und GS-56 (ADR 0007) verweisen auf diesen Eintrag, ohne dass ein Kriterium sie aufnimmt. | Hinweis |

### R3-F-024 — Pfadangaben von aussen ohne Traversierung (nur falls gezogen)

| Kennung | Eintrag | Kriterium | Befund | Schwere |
|---|---|---|---|---|
| W2-74 | R3-F-024 | drei Wegtests; R6, Gegenprobe | Ohne schreibende oder lesende Stelle mit Datei- oder Pfadangabe sind die drei selbstskalierenden Wegtests leer und grün; ihre Gegenproben ("genau eine Datei im vorgesehenen Ablageort") setzen eine Stelle voraus, die in Sprint 2 nach den Kandidaten nicht entsteht. | blockierend |
| W2-75 | R3-F-024 | R3-F-024_pfad_aus_systemeigenen_teilen; R4 | Der Ablageort ist nicht bestimmt (Annahme Dateisystem oder Datenbank; Glossar, "Zu ergänzen" Nr. 6). | Nachbesserung |

### R3-F-020 — Aufbewahrung als Zustandsmodell, Löschwege vollständig (nur falls gezogen)

| Kennung | Eintrag | Kriterium | Befund | Schwere |
|---|---|---|---|---|
| W2-76 | R3-F-020 | R3-F-020_loeschweg_vollstaendig; R6 | W1-19 und W1-21 gelten unverändert: Das Kriterium nennt Ablageorte (Graph, Anhänge, Asservate, Suchindex, Vorschaubilder), die nicht bestehen, und Aktenzeichen und Fallnummer sind nicht bestimmt (Glossar, "Zu ergänzen" Nr. 4). | blockierend |
| W2-77 | R3-F-020 | Eintrag; B6 [GRC] | Präskriptiver Teil (4.4): wird terminiert, nicht wegpriorisiert. Fällig mit diesem Eintrag sind SR-030 und SR-031 sowie die Vormerkungen zu Schreibprotokoll, Sicherungen und Serverprotokoll; Punkt 4 der Bereitschaftsliste und das Löschkonzept sind offen. | Hinweis |

### R3-F-004 — Kanonischer Datenbestand nach STIX 2.1 (nur falls gezogen)

| Kennung | Eintrag | Kriterium | Befund | Schwere |
|---|---|---|---|---|
| W2-78 | R3-F-004 | R3-F-004_stix_schemakonform; R6 | Der Rundlauf MISP-Import, Ablage, STIX-Export setzt einen Importweg aus MISP und einen Export voraus, die in Etappe 1 nicht entstehen; "ohne Informationsverlust" nennt kein Mass. | blockierend |
| W2-79 | R3-F-004 | R3-F-004_stix_schemakonform; R3, R4 | Welche Typen nach STIX 2.1 und welche nach FollowTheMoney abgelegt werden (W1-75; Glossar, Entität), und wogegen validiert wird (Schemadateien oder Bibliothek; vgl. E-S1-13), ist nicht bestimmt. | Nachbesserung |
| W2-80 | R3-F-004 | R3-F-004_stix_schemakonform; Gegenprobe | Der Prüffall, dass ein nicht schemakonformes Objekt abgewiesen wird, fehlt. | Nachbesserung |

## Übersicht

Die Spalte "Einschätzung" ist ein Hinweis an den Product Owner und ersetzt
seine Ready-Prüfung nicht.

| Eintrag | Rolle im Walkthrough | blockierend | Nachbesserung | Hinweis | Einschätzung aus Sicht des Requirements Engineers |
|---|---|---|---|---|---|
| R3-F-026 | Kandidat | 1 | 9 | 2 | nicht ready in dieser Form: was ein Werkzeug ohne Quelle ist, entscheidet über die Prüfbarkeit (W2-01) |
| R3-F-002 | Kandidat | 2 | 4 | 1 | nicht ready in dieser Form: registriertes Werkzeug (W2-13) und Ort des Protokolls einer Abweisung ohne Fall (W2-14) |
| R3-F-009 | Kandidat | 1 | 5 | 1 | nicht ready in dieser Form: welche Abfrage den Negativbefund auslöst (W2-20) |
| R3-F-014 | Kandidat | 2 | 7 | 0 | nicht ready in dieser Form: Lesart von "Codepfad" (W2-27) und "menschliche Bestätigung" ohne Sitzung (W2-28) |
| R3-F-015 | Kandidat | 0 | 5 | 1 | prüfbar mit Nachbesserungen; Gegenprobe steht unter W2-54 |
| R3-F-016 | Kandidat | 0 | 7 | 1 | prüfbar mit Nachbesserungen; Vorschau setzt R3-F-014 voraus (W2-48) |
| R3-F-028 | Kandidat | 1 | 8 | 2 | nicht ready in dieser Form: private Adressen gegen Testgegenstelle im internen Netz (W2-54) |
| Querschnitt | Kandidaten | 0 | 5 | 4 | Glossar (W2-61 bis W2-65), Ort des Protokolls von Abweisungen (W2-66) |
| R3-F-027 | Reserve, nur falls gezogen | 1 | 2 | 1 | nicht ehrlich prüfbar ohne Route (W2-70) |
| R3-F-024 | Reserve, nur falls gezogen | 1 | 1 | 0 | nicht ehrlich prüfbar ohne Ablageweg (W2-74) |
| R3-F-020 | Reserve, nur falls gezogen | 1 | 0 | 1 | nicht ready in dieser Form (W2-76, wie W1-19 und W1-21) |
| R3-F-004 | Reserve, nur falls gezogen | 1 | 2 | 0 | nicht ehrlich prüfbar ohne Import und Export (W2-78) |
| **Summe** | | **11** | **55** | **14** | 80 Befunde; davon bei den sieben Kandidaten und im Querschnitt 7 blockierend, 50 Nachbesserung, 12 Hinweis; an die GRC-Rolle gekennzeichnet 6 (W2-21, W2-28, W2-34, W2-38, W2-69, W2-77) |

## Nachtrag S2 (nach der Festlegung, 2026-11-10)

Verfasser-Rolle: Requirements Engineer. Anlass: die Festlegung des Software
Architects für Sprint 2, ADR 0008 (docs/adr/0008-ermittlungskreislauf-kern.md,
Status vorgeschlagen), Teil A, Absatz "Walkthrough-Befunde, die diese
Festlegung auflöst". Die Befunde W2-01 bis W2-80 und die Übersicht bleiben im
Stand der Einheit S2; dieser Nachtrag ändert keinen Befund, löscht keinen und
schlägt keine Lösung vor. Die Auflösung gilt mit der Annahme von ADR 0008.

**(a) Blockierende Befunde der Kandidaten**

| Kennung | Eintrag | Auflösung in ADR 0008 | Stand |
|---|---|---|---|
| W2-01 | R3-F-026 | Entscheid 2 | aufgelöst durch die Festlegung, Fortschreibung des Eintrags vor der Baueinheit (B4, E-S2-12) |
| W2-13 | R3-F-002 | Entscheid 2 | aufgelöst durch die Festlegung, Fortschreibung des Eintrags vor der Baueinheit (B4, E-S2-12) |
| W2-14 | R3-F-002 | Entscheid 7, Entscheidpunkt E-S2-01 | aufgelöst durch die Festlegung, Fortschreibung des Eintrags vor der Baueinheit (B4, E-S2-12) |
| W2-20 | R3-F-009 | Entscheid 19 | aufgelöst durch die Festlegung, Fortschreibung des Eintrags vor der Baueinheit (B4, E-S2-12) |
| W2-27 | R3-F-014 | Entscheid 12 | aufgelöst durch die Festlegung, Fortschreibung des Eintrags vor der Baueinheit (B4, E-S2-12) |
| W2-28 | R3-F-014 | Entscheid 13, als Grenze | als Grenze GK-3 geführt |
| W2-54 | R3-F-028 | Entscheid 15, Entscheidpunkt E-S2-03 | aufgelöst durch die Festlegung, Fortschreibung des Eintrags vor der Baueinheit (B4, E-S2-12) |

**(b) Übrige Befunde.** Die übrigen Nachbesserungen und Hinweise zu den
Kandidaten, die ADR 0008 im genannten Absatz einem Entscheid oder
Entscheidpunkt zuordnet, kommen als Fortschreibung je Eintrag vor der
Baueinheit, die ihn baut (E-S2-12 a, wie E-S1-22). Nicht aufgelöst und beim
Requirements Engineer bleiben W2-19 und W2-61 bis W2-65 (Glossar; Stakeholder
"Aufsicht"). Die sechs an die GRC-Rolle gekennzeichneten Befunde (W2-21,
W2-28, W2-34, W2-38, W2-69, W2-77) gehen an die GRC-Rolle in der jeweiligen
Baueinheit. Die Reserve (W2-70 bis W2-80) ist nach ADR 0008 nicht Gegenstand.

**(c) Glossar.** Die fünf Vorschläge aus S2 (Freigabe-Kennung,
Freigabevorschau, Gegenstelle, Verbindungsversuch, Werkzeug) sind an ADR 0008
angeglichen; sie bleiben gekennzeichnet und nicht bestätigt, Vorlage E-D27-01.

## Nachtrag vom 2026-11-10 (Einheit D28)

Verfasser-Rolle: Requirements Engineer; Angabe des Koordinators, Fremdbeleg.
ADR 0008 ist mit dem Merge des Pull Requests #58 am 2026-11-10 (Merge-Commit
`6d517d1fb0c7dc2e2317d0181198edf06b8d4cd2`) angenommen; die Auflösungen der
sieben blockierenden Befunde nach dem Nachtrag S2, Teil (a), gelten damit
(W2-28 als Grenze GK-3). E-S2-12 (a): die Fortschreibung der Einträge erfolgt
je vor der Baueinheit, die den Eintrag baut, als Nächstes R3-F-015 und
R3-F-028 vor S2.1. E-D27-01 (a): die Glossarvorschläge sind bestätigt, die
Kennzeichnung entfällt. Offen bleiben W2-19, W2-61 bis W2-65 und die sechs
GRC-Befunde (W2-21, W2-28, W2-34, W2-38, W2-69, W2-77) in der jeweiligen
Baueinheit. Kein Befund ist geändert oder gelöscht.

## Nachtrag vom 2026-11-10 (Einheit S2.1)

Verfasser-Rolle: Requirements Engineer. Anlass: Auftrag des Koordinators vom
2026-11-10, die Befunde zu R3-F-015 und R3-F-028 vor der Baueinheit S2.1 als
Fortschreibung der Einträge zu bearbeiten (B4, E-S2-12 a; Stand des
Repositories nach der Angabe des Koordinators, Fremdbeleg). Die Befunde W2-01
bis W2-80, ihre Schwere, die Übersicht und die Zeile "Summe" bleiben
unverändert; dieser Nachtrag fügt keinen Befund hinzu.

**Vermerk zu W2-36 bis W2-41, W2-50 bis W2-60 und W2-62: bearbeitet.** Die
Befunde bleiben in der Liste stehen; die Nachbesserung ist als Fortschreibung
der Einträge R3-F-015 und R3-F-028 in `docs/05_Product_Backlog.md` vorgenommen
(je Zusatz "Präzisiert am 2026-11-10" an den Abnahmezeilen, eine Zeile
"Achtung" und eine Zeile "Stand 2026-11-10 (S2.1)"), gestützt auf ADR 0008,
Entscheide 14, 15, 16 und 25, die mit dem Merge #58 entschiedenen E-S2-03 a,
E-S2-04 a und E-S2-06 a sowie die Grenzen GK-2, GK-5, GK-6, GK-8, GK-12 und
GK-14. Was ADR 0008 nicht beantwortet, steht als Annahme in der Zeile
"Achtung" des Eintrags und als Frage FA-S21-01 bis FA-S21-08 an den Software
Architect (Festlegung S2.1).

| Befund | Bearbeitet durch | Offen |
|---|---|---|
| W2-36 | R3-F-015, Präzisierung: Ziel aus Schema, Rechnername oder Literal in Normalform und Anschluss (Entscheid 14) | — |
| W2-37 | R3-F-015, Präzisierung (b): Gegenprobe mit Literal-Eintrag der Rückschleife (Entscheid 25, E-S2-03 a) | — |
| W2-38 | R3-F-015, Präzisierung (a): Spur des Falls, Ziel als Pseudonym, Klartextfelder nach Entscheid 16 | FA-S21-03 (Eingabe des Pseudonyms); rechtliche Einordnung bei der GRC-Rolle (F-04) |
| W2-39 | R3-F-015, Präzisierung (a): keine Auflösung, keine Verbindung (Entscheid 15, Schritt 2) | FA-S21-02 (Form der Abweisung, Transaktion) |
| W2-40 | R3-F-015, "Achtung" (4): Form, Ort und Geltung nach Entscheid 14 | Pflege und Änderungsprotokoll, GK-12 (Restpunkt DS-S2-16) |
| W2-41 | R3-F-015, "Achtung" (5): Wege ausserhalb von ausgang, GK-2, R3-C-004 | — |
| W2-50 | R3-F-028, Präzisierung des ersten Kriteriums: Schritt 0, Weiterleitungen 1 bis N, Schritt N+1 kette_zu_lang (Entscheid 15) | FA-S21-06 |
| W2-51 | R3-F-028, Gegenprobe des ersten Kriteriums: Weiterleitung auf ein Listenziel, Kette genau bis N | — |
| W2-52 | R3-F-028, erstes Kriterium: anderer Anschluss und anderes Schema sind andere Ziele (Entscheide 14, 15) | — |
| W2-53 | R3-F-028, erstes Kriterium und "Achtung" (8): E-S2-04 a, httpx nach E-S2-06 a | Bestätigung durch S-05 (nicht Sache dieser Rolle) |
| W2-54 | R3-F-028, zweites Kriterium: geschlossener Vorrat der Bereiche, Literal ohne Bereichsregel (Entscheid 15, E-S2-03 a, GK-6) | — |
| W2-55 | R3-F-028, Gegenprobe des zweiten Kriteriums: Testkonstante über den Transport-Ersatz (GK-5) | Testkonstante (Annahme 2, Messung vor dem Bau) |
| W2-56 | R3-F-028, zweites Kriterium: jede Adresse geprüft, erste zulässige verwendet | FA-S21-05 |
| W2-57 | R3-F-028, zweites Kriterium: steuerbarer Auflöser, Normalformfälle als Prüffälle (GK-8) | FA-S21-04 (Lesart), FA-S21-08 (Regelwerk der Punycode-Form) |
| W2-58 | R3-F-028, drittes Kriterium: IPv6 verkürzt, ausgeschrieben, Gross- und Kleinschreibung, Zonenangabe abgewiesen | FA-S21-07 (Ergebnis der Zonenangabe) |
| W2-59 | R3-F-028, Gegenprobe des dritten Kriteriums: Literal-Eintrag in jeder Schreibweise zugelassen | IPv6-Rückschleife der Teststufe nicht gemessen |
| W2-60 | R3-F-028, drittes Kriterium: Literal eines Listennamens ohne eigenen Eintrag abgewiesen (ADR 0008, Absatz "Walkthrough-Befunde, die diese Festlegung auflöst") | — |
| W2-62 | Glossar: Gegenstelle und Verbindungsversuch bestätigt (E-D27-01 a); Ziel und Weiterleitung als Vorschläge, gekennzeichnet und nicht bestätigt | Bestätigung der zwei Vorschläge |

**Angleichung an die Festlegung S2.1 (2026-11-10).** Die Fragen FA-S21-01 bis
FA-S21-08 aus der Spalte "Offen" sind in der Festlegung S2.1 beantwortet (ADR
0008, Teil A, Abschnitt "Festlegung S2.1 (2026-11-10)", Zeile "Antworten auf
FA-S21-01 bis FA-S21-08"; dazu die Zeilen "ausgang.aufloesung",
"ausgang.client.anfragen", "Protokoll: spur.payload" und "Tests Abnahme"). Die
Lesart zu W2-57 (FA-S21-04) ist bestätigt. Zu W2-56 gilt E-S21-02: eine nicht
öffentliche Adresse unter mehreren weist den ganzen Versuch ab. Mit der Zeile
"Nachbesserung nach den Stellungnahmen (S2.1.1)" kommen vier Punkte hinzu:
(1) bei einem Zielwechsel gehen keine Kopfzeilen des Aufrufers und kein Körper
an das neue Ziel, und 307 und 308 mit Körper und Zielwechsel werden nicht
verfolgt (SD-S21-02); (2) es gilt eine Gesamtfrist je Aufruf (SD-S21-03);
(3) die Klasse protokollzuweisung und die eingebetteten Formen gelten als
nicht öffentlich (SD-S21-04); (4) es gibt die Ergebnisse beantwortet und
url_nicht_auswertbar sowie die Felder versuch_kennung und methode, und eine
Antwort mit content-encoding ausser identity ist ein Fehlschlag; die
Testkonstante ist 2001:20::1, und kein Test bindet oder verbindet einen
IPv6-Socket (GK-21). Damit entfällt auch der offene Punkt "IPv6-Rückschleife
der Teststufe nicht gemessen" zu W2-59. Die Einträge R3-F-015 und R3-F-028
sind daran angeglichen. Offen bleiben bei W2-38 die rechtliche Einordnung
(GRC-Rolle), bei W2-40 Pflege und Änderungsprotokoll (GK-12), bei W2-53 die
Bestätigung durch S-05, bei W2-55 die Prüfstärke des Namenspfads (GK-5) und
bei W2-62 die Bestätigung der zwei Glossarvorschläge. Kein Befund ist geändert
oder gelöscht.
