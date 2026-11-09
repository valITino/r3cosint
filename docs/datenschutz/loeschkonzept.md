# Löschkonzept R3cOSINT (ENTWURF)

| Feld | Angabe |
|---|---|
| **Status** | **ENTWURF.** Kein gebauter Löschweg, kein Test, kein Nachweis. Der Löschweg und sein Nachweis folgen mit R3-F-020; bis dahin ist Punkt 4 der Bereitschaftsliste (5.16) offen (Abschnitt 10) |
| **Arbeitsprodukt** | Löschkonzept nach Projektauftrag 4.2 (Rolle Datenschutzexperte) und 4.4, "Aufbewahrung und Löschung"; Teil von Punkt 4 der Bereitschaftsliste |
| **Verantwortlich** | Datenschutzexperte |
| **Stand** | 2026-11-09, zur Baueinheit S1.3 (Fall, R3-F-001) nach ADR 0007, Zerlegung, Zeile S1.3: "Löschkonzept als Entwurf mit dem Vermerk, dass der Löschweg mit R3-F-020 folgt"; nachgeführt auf den gebauten, nicht abgenommenen Stand von S1.3 (gebaut am 2026-11-09, zur Abnahme vorgelegt mit dem Pull Request der Einheiten D24 und S1.3; ADR 0007, "Gebauter Stand S1.3"): Eröffnen und Schliessen gebaut, Übergänge zusätzlich durch den Auslöser `fall_uebergang` der Revision 0004_fall_uebergang gebunden, Grenze GS-26 mit SR-030 (offen bis R3-F-020); S1.3 abgenommen mit dem Merge des Pull Requests #55 am 2026-11-09 (Angabe des Koordinators, Fremdbeleg). Ergänzt am 2026-11-09 vor dem Bau der Einheit S1.4 um den Entwurf des Löschwegs für den Bestand (`herkunft`, `entitaet`, `beziehung`; Abschnitt 5, Absatz "Bestand"; Stand: festgelegt, nicht gebaut). Nachtrag vom 2026-11-09: S1.3 ist abgenommen (Merge #55), die Angabe "gebauten, nicht abgenommenen Stand" ist überholt; S1.4 gebaut am 2026-11-09, zur Abnahme vorgelegt (Pull Request der Einheiten D25 und S1.4). Nachtrag D26 vom 2026-11-09: S1.4 abgenommen mit dem Merge des Pull Requests #56 am 2026-11-09 (Merge-Commit `04e759130e63111556a853487db03b035430e522`, ohne Kommentar, ohne Review; Angabe des Koordinators, Fremdbeleg); der Löschweg bleibt ungebaut (R3-F-020) |
| **Geltung** | Test/Schulung mit synthetischen Daten (5.6, 5.16); keine echten Fall- oder Personendaten über den Harness (5.15) |
| **Grundlage** | Projektauftrag 4.4 (Punkte 1 bis 7), 5.3, 5.10, 5.16; `.claude/rules/recht-und-datenschutz.md`, "Aufbewahrung: nichts wird automatisch gelöscht"; ADR 0007 (Entscheide 9, 14, 22, 23, 24, 25, 26; E-S1-06 b, E-S1-12 a, E-S1-07 a, E-S1-11 a; Grenze GS-5; "Nicht Gegenstand"); ADR 0002, Abschnitt 8, O-6; Backlog R3-F-001, R3-F-011, R3-F-020; Glossar (Prüffrist, Fallkategorie, Löschsperre, Löschweg, Grabstein-Eintrag) |
| **Zugehörig** | Bearbeitungsverzeichnis: `docs/datenschutz/bearbeitungsverzeichnis.md` |
| **Was dieser Entwurf nicht tut** | Er setzt keine Frist als Recht: die Startwerte sind betriebliche Voreinstellungen, Bestätigung oder Korrektur liegt bei der Kantonspolizei Bern (4.4, Punkte 3 und 6). Er bewertet das Zugriffsmodell auf Dezernatsebene nicht (5.8). Er legt keine Bauform fest; das ist Sache des Software Architects in der Festlegung zu R3-F-020 |

## Leseanleitung

- Abschnitte 1 bis 4 beschreiben das Zustandsmodell und die Fristen, 5 bis 9 die Löschung selbst, 10 den Stand von Punkt 4 der Bereitschaftsliste, 11 die offenen Punkte.
- Jede Zeile trennt, was gebaut ist (Revision, Modul), was S1.3 baut und was erst mit R3-F-020 entsteht. Bezeichner sind die des gebauten Schemas; Begriffe folgen dem Glossar (Fallkategorie, nicht Aufbewahrungsklasse).
- Fristen sind Daten der Tabelle `fallkategorie`, nie Konstanten im Code; Startwerte sind Vorschläge zur Bestätigung, kein Recht.
- [OFFEN] kennzeichnet eine Frage ohne Entscheid, mit der zuständigen Rolle in Klammern. Angaben anderer Rollen gelten als Fremdbeleg.

## 1. Grundsatz

> **Nichts wird automatisch gelöscht. Aber kein Fall bleibt ohne Entscheid.** (4.4, Punkt 1, entschieden)

- Eine Frist löst nie eine Löschung aus, sondern eine **Aufgabe** an den Fallverantwortlichen.
- Fristen laufen ab Fallabschluss, nie ab Erstellung; ein laufender Fall gerät nie in eine Löschprüfung (4.4, Punkt 2).
- "Unbegrenzt behalten" ist kein Dauerzustand: Das KDSG verlangt, nicht mehr benötigte Personendaten zu vernichten; wer periodisch entscheidet und den Entscheid protokolliert, erfüllt das, ohne unfreiwillig etwas zu verlieren (4.4, Punkt 1).
- Ein Datensatz, der nur aus der Anzeige verschwindet, ist nicht gelöscht (4.4, Punkt 4).

## 2. Zustandsmodell je Fall

Acht Zustände nach 4.4, Punkt 2. Spalte "Schema" nennt den Bezeichner in der Prüfbedingung `fall_zustand_vorrat` der Revision 0002_fall; Spalte "Sprint 1" den Stand.

| Zustand | Auslöser | Wirkung | Schema | Sprint 1 |
|---|---|---|---|---|
| Aktiv | Fall eröffnet | Keine Frist läuft | `aktiv` | erreichbar (S1.3, eröffnen) |
| Abgeschlossen | Fall geschlossen | Prüffrist beginnt; `geschlossen_am` und `prueffrist_bis` werden festgeschrieben | `abgeschlossen` | erreichbar (S1.3, schliessen) |
| Prüfung fällig | Frist erreicht | Aufgabe an den Fallverantwortlichen, sonst nichts | `pruefung_faellig` | im Vorrat, nicht erreichbar |
| Verlängert | Entscheid mit Begründung | Neue Prüffrist, Begründung protokolliert | `verlaengert` | im Vorrat, nicht erreichbar |
| Zur Löschung freigegeben | Entscheid im Vier-Augen-Prinzip | Löschung terminiert, Widerruf bis zur Ausführung möglich | `zur_loeschung_freigegeben` | im Vorrat, nicht erreichbar |
| Gelöscht | Ausführung | Nur der Grabstein-Eintrag bleibt; die Falldaten in `fall` sind geleert | `geloescht` | im Vorrat, nicht erreichbar |
| Archiviert | Übergabe an die Archivierung | Statt Löschung, wenn archivwürdig (R5); entschieden am Prüftermin, nicht bei der Eröffnung (4.4, Punkt 3b) | `archiviert` | im Vorrat, nicht erreichbar |
| Löschsperre | Manuell gesetzt | Fall kann nicht gelöscht werden, unabhängig von Fristen; für laufende Rechtsmittel, Aufbewahrungsanordnungen, Wiederaufnahme | **nicht im Vorrat** | nicht gebaut |

**Vorrat.** Die Prüfbedingung führt die sieben Zustände von Aktiv bis Archiviert vollständig; die Löschsperre steht nicht darin. 4.4 führt sie als Zeile des Zustandsmodells, das Glossar als "Markierung" neben dem Zustand; welche Lesart gilt, ist offen (Walkthrough vor Sprint 1, W1-30). Fachlich spricht für die Markierung, dass die Sperre in mehreren Zuständen wirken muss (abgeschlossen, Prüfung fällig, verlängert, zur Löschung freigegeben mit terminierter Löschung; W1-29) und der Zustand darunter erhalten bleiben soll. Der Entscheid gehört in die Festlegung zu R3-F-020 [OFFEN, Software Architect]. Das Schema von Sprint 1 schliesst beide Lesarten nicht aus (ADR 0007, Entscheid 22).

**Übergänge**, wie 4.4 sie nahelegt; verbindlich erst mit der Festlegung zu R3-F-020:

- aktiv nach abgeschlossen (schliessen; ein zweites Schliessen wird abgewiesen, ADR 0007, Entscheid 23);
- abgeschlossen nach Prüfung fällig (Frist erreicht; erzeugt eine Aufgabe, keine Löschung);
- Prüfung fällig nach verlängert (neue Prüffrist mit Begründung), nach zur Löschung freigegeben (Vier-Augen-Prinzip) oder nach archiviert;
- verlängert nach Prüfung fällig (neue Frist erreicht);
- zur Löschung freigegeben nach gelöscht (Ausführung) oder zurück (Widerruf bis zur Ausführung);
- jede Löschung setzt voraus, dass keine Löschsperre gesetzt ist.

Nicht geregelt in 4.4 und hier nicht festgelegt: die Wiederaufnahme eines abgeschlossenen Falls (W1-12), wer die Löschsperre setzt und aufhebt (W1-31), und ob ein Wechsel des Rechtsregimes ein Vorgang an demselben Fall ist (R3-F-001, "Achtung" (2)).

## 3. Prüffristen als Konfiguration je Fallkategorie

**Ort.** Tabelle `fallkategorie` (Revision 0002_fall), Startwerte als eigene Datendatei der Revision (`backend/migrationen/sql/0002_fall_startwerte.sql`, neben `backend/migrationen/sql/0002_fall.sql`). Es gibt genau ein Feld Fallkategorie je Fall; die Prüffrist wird daraus abgeleitet, nicht separat erfasst (4.4, Punkt 3b). Kein Fristwert steht im Code (ADR 0007, Entscheid 22, mit Architekturtest).

**Startwerte [VORSCHLAG zur Bestätigung, 4.4, Punkt 3]:**

| Kennung | Fallkategorie (4.4) | Erste Prüfung (Monate) | Folgeprüfung (Monate) | Anker (4.4) |
|---|---|---|---|---|
| `nichtanhandnahme_einstellung` | Nichtanhandnahme oder Einstellung ohne verbleibenden Tatverdacht | 12 | — | Kein fortbestehender Beweiszweck |
| `uebertretung` | Übertretungen | 36 | — | Verjährung nach Art. 109 StGB |
| `vergehen` | Vergehen im Regelfall | 84 | — | Art. 97 Abs. 1 StGB: andere Strafe (Bezeichnung weicht vom Wortlaut der Quelle ab: `docs/konformitaet/konformitaetsanalyse.md`, Abschnitt 4.1, H-A, Prüfpunkt P-03) |
| `freiheitsstrafe_bis_3_jahre` | Taten mit Freiheitsstrafe bis drei Jahre | 120 | — | Art. 97 Abs. 1 StGB (Bezeichnung weicht vom Wortlaut der Quelle ab: `docs/konformitaet/konformitaetsanalyse.md`, Abschnitt 4.1, H-A, Prüfpunkt P-03) |
| `verbrechen_ueber_3_jahre` | Verbrechen mit Freiheitsstrafe über drei Jahre | 180 | — | Art. 97 Abs. 1 StGB |
| `lebenslaenglich` | Taten mit lebenslänglicher Strafandrohung | 360 | — | Art. 97 Abs. 1 StGB |
| `unverjaehrbar` | Unverjährbare Taten nach Art. 101 StGB und Delikte gegen Kinder mit Fristenlauf bis zum 25. Altersjahr des Opfers | 60 | 60 | Keine Ablauffrist, Prüfung alle 5 Jahre (Bezeichnung weicht vom Wortlaut der Quelle ab: `docs/konformitaet/konformitaetsanalyse.md`, Abschnitt 4.1, H-B, Prüfpunkt P-03) |

**Einordnung.** Betriebliche Voreinstellungen, keine rechtliche Festlegung. Die Verjährung regelt die Verfolgbarkeit, nicht die Datenaufbewahrung; sie dient als nachvollziehbarer Massstab, weil es keinen näherliegenden gibt (4.4, Punkt 3). Die Kantonspolizei Bern bestätigt oder korrigiert die Werte und die Zuordnung der Fallkategorien im Bearbeitungsreglement (4.4, Punkt 6); das blockiert den Bau nicht.

**Berechnung.** Beim Schliessen: `prueffrist_bis` = `geschlossen_am` plus `erste_pruefung_monate` in Kalendermonaten, der Tag am Monatsende begrenzt (`core.zeit`), festgeschrieben und im Eintrag `fall_geschlossen` protokolliert (ADR 0007, Entscheid 23, E-S1-11 a). Eine spätere Änderung der Werte wirkt auf künftige Abschlüsse; eine Neuberechnung laufender Fristen ist ein eigener, protokollierter Vorgang mit R3-F-020 (E-S1-11 a). `folgepruefung_monate` wirkt erst mit "Prüfung fällig" und "Verlängert" (R3-F-020).

**Was "konfigurierbar" in Sprint 1 heisst.** Die Werte sind Daten, keine Konstante im Code. Die Anwendungsrolle hat an `fallkategorie` allein SELECT (ADR 0007, Nr. 9); geändert werden sie heute nur über eine Revision unter dem Eigentümer. Ein Konfigurationsweg für den Betrieb (Administrator nach 5.8, mit Protokolleintrag) ist nicht gebaut [OFFEN, Product Owner und Software Architect].

**Änderung der rechtlichen Würdigung.** 4.4, Punkt 3b sagt: Ändert sich die rechtliche Würdigung, ändert sich die Frist mit, und das ist protokolliert. In Sprint 1 hat die Anwendungsrolle kein Änderungsrecht auf `fall.fallkategorie` (Revision 0002_fall); ein Vorgang "Fallkategorie ändern" mit Neuberechnung der Prüffrist und Protokolleintrag fehlt [OFFEN, Product Owner, Vorschlag DS-04 im Bericht an ihn].

## 4. Löschsperre, Vier-Augen-Prinzip und Widerruf

Nicht gebaut; Gegenstand von R3-F-020 (ADR 0007, "Nicht Gegenstand"). Anforderungen aus 4.4 und dem Backlog:

| Gegenstand | Anforderung | Prüfung |
|---|---|---|
| Löschsperre | Verhindert die Löschung unabhängig von jeder Frist und jedem Zustand; manuell gesetzt; Setzen und Aufheben sind protokollpflichtig (4.4, Punkt 4) | `R3-F-020_loeschsperre`; nachzubessern nach W1-27 bis W1-29 (Reaktion auf den Löschversuch, Gegenprobe ohne Sperre, Geltung über die Zustände) |
| Vier-Augen-Prinzip | Die Freigabe zur Löschung braucht zwei verschiedene Personen; beide stehen im Protokoll | kein Abnahmekriterium im Backlog [OFFEN, Product Owner] |
| Widerruf | Bis zur Ausführung möglich, protokolliert | kein Abnahmekriterium im Backlog [OFFEN, Product Owner] |
| Aufgabe statt Löschung | Nach Ablauf der Prüffrist besteht eine Aufgabe an den Fallverantwortlichen, der Fall ist unverändert | `R3-F-020_frist_loescht_nicht` |

## 5. Löschwege (vollständige Aufzählung zur Prüfung)

Ein Löschweg erreicht jeden Ort, an dem Daten des Falls liegen (4.4, Punkt 4; Glossar, Löschweg). Die sieben Orte aus 4.4 sind Gegenstand von `R3-F-020_loeschweg_vollstaendig`; die weiteren Zeilen nennen, was die Liste nicht nennt, aber berührt.

| Nr. | Ablageort | Besteht in Sprint 1 | Daten des Falls | Vorgesehene Wirkung der Löschung |
|---|---|---|---|---|
| LW-1 | Datenbestand: `fall` | ja (S1.2, S1.3) | Aktenzeichen, ermittelnde Person, Rechtsgrundlage | Felder geleert, Zustand `geloescht`; es bleiben Kennung (Fallnummer), Rechtsregime, Fallkategorie und Zeitpunkte (E-S1-06 b, Entscheid 22) |
| LW-2 | Datenbestand: `fall_schluessel` | ja | Fallschlüssel | Zeile gelöscht; die Pseudonyme werden unumkehrbar (4.4, Problem B) |
| LW-3 | Datenbestand: `entitaet`, `beziehung`, `herkunft` | ab S1.4 (festgelegt, nicht gebaut); Nachtrag vom 2026-11-09: gebaut am 2026-11-09, zur Abnahme vorgelegt; Nachtrag D26: abgenommen mit dem Merge des Pull Requests #56 am 2026-11-09 | Eigenschaftswerte (Namen, Adressen, Telefonnummern, weitere Eigenschaften nach FollowTheMoney), Kennung nach FollowTheMoney, Abfragetext, erhebende Person | Zeilen des Falls gelöscht in der Reihenfolge `beziehung`, `entitaet`, `herkunft` (Entwurf, Absatz "Bestand" unten); Festlegung mit R3-F-020; DELETE nur auf die Tabellen, die der Löschweg nennt (ADR 0007, Nr. 9) |
| LW-4 | Graph | nein | Knoten und Kanten des Falls | mit seinem Eintrag |
| LW-5 | Anhänge und Asservate | nein (Ablageform offen, Backlog offener Punkt 11, R3-F-024) | Dateien, Medien | mit seinem Eintrag; R3-F-024 sichert, dass keine Datei ausserhalb des vorgesehenen Orts entsteht |
| LW-6 | Suchindex | nein | Begriffe und Treffer des Falls | mit seinem Eintrag; gilt auch für Autovervollständigung und Trefferzahlen (5.8) |
| LW-7 | Zwischenspeicher | nein | zwischengespeicherte Antworten und Werte | mit seinem Eintrag |
| LW-8 | Vorschaubilder | nein | abgeleitete Bilder von Anhängen | mit seinem Eintrag |
| LW-9 | Abgeleitete Auswertungen | nein | Statistiken, Berichtsentwürfe, Zwischenauswertungen | mit seinem Eintrag |
| LW-10 | Protokollspuren (`ermittlungsspur`, `arbeitsspur`, `kettenkopf`) | ja | Pseudonyme, Kennungen, Zeitpunkte, `person_kennung` | **keine Löschung** (4.4, Problem A); Pseudonyme unumkehrbar über LW-2 |
| LW-11 | Sicherungen | nein (Test/Schulung ohne Sicherung) | alles aus LW-1 bis LW-9 im Stand der Sicherung | **nicht bearbeitet**; unlesbar über die Vernichtung des Schlüssels je Fall (4.4, Problem B); setzt voraus, dass die Falldaten mit diesem Schlüssel verschlüsselt sind (O-6, Abschnitt 7) |
| LW-12 | Schreibprotokoll der Datenbank | ja | alle geschriebenen Werte bis zur Wiederverwendung des Protokolls | wie LW-11; GS-5 nennt es ausdrücklich [OFFEN, Software Architect mit SecDevOps Engineer] |
| LW-13 | Bereits ausgeführte Exporte | nein (5.10 nicht gebaut) | was exportiert wurde | **ausserhalb jeder Löschung** (Abschnitt 9) |

**Bestand: `entitaet`, `beziehung`, `herkunft` (Entwurf zu LW-3; Stand: festgelegt in ADR 0007, Entscheide 24 und 25, nicht gebaut).** Verbindlich erst mit der Festlegung zu R3-F-020 (Software Architect); dieser Entwurf hält fest, was der Datenschutz vom Löschweg verlangt und was S1.4 dafür nicht verbauen darf. Nachtrag vom 2026-11-09: Die drei Tabellen sind mit der Revision 0005_bestand gebaut am 2026-11-09 und zur Abnahme vorgelegt; der Löschweg selbst bleibt ungebaut (R3-F-020). Nachtrag D26 vom 2026-11-09: abgenommen mit dem Merge des Pull Requests #56 am 2026-11-09; der Löschweg bleibt ungebaut (R3-F-020).

| Schritt | Gegenstand | Wirkung | Grund |
|---|---|---|---|
| 1 | `beziehung` mit `fall_kennung` des Falls | Zeilen gelöscht | Kanten verweisen über `quelle_kennung` und `ziel_kennung` auf `entitaet` und über `herkunft_kennung` auf `herkunft`; sie gehen zuerst |
| 2 | `entitaet` mit `fall_kennung` des Falls | Zeilen gelöscht | verweisen über `herkunft_kennung` auf `herkunft` |
| 3 | `herkunft` mit `fall_kennung` des Falls | Zeilen gelöscht, auch Herkunftssätze ohne verweisenden Datensatz | Abfragetext und erhebende Person sind Falldaten des Bestands; ohne Datensatz hat der Herkunftsnachweis keinen Gegenstand |
| 4 | `fall_schluessel` (LW-2), danach `fall` (LW-1) | wie oben | die Pseudonyme der Spuren werden unumkehrbar |
| — | Einträge `entitaet` und `beziehung` der Ermittlungsspur (LW-10) | **bleiben unverändert** | Problem A (Abschnitt 7): Die Einträge tragen Kennungen (danach ohne Ziel), den Schemanamen, Eigenschaftsnamen und Pseudonyme; mit dem Vernichten des Fallschlüssels sind die Pseudonyme unumkehrbar (E-S1-06 b). Die Kettenprüfung berührt das nicht, weil spur Verweise nicht prüft (ADR 0007, Vertrag 9) |

Alle Schritte in einer Transaktion zusammen mit dem Grabstein-Eintrag (Abschnitt 6) und dem Zustandswechsel nach `geloescht`; bricht ein Schritt ab, bleibt der Fall unverändert. Nicht Gegenstand des Entwurfs: ob die Reihenfolge über Fremdschlüssel mit Weitergabe der Löschung (ON DELETE CASCADE) oder über ausdrückliche Befehle je Tabelle läuft. Empfehlung des Datenschutzexperten: ausdrückliche Befehle je Tabelle, Fremdschlüssel ohne Weitergabe, wie an den Spuren (ADR 0007, Festlegung S1.2, Fremdschlüssel ohne ON DELETE); dann löscht keine Anweisung mehr, als der Löschweg nennt, und ein vergessener Schritt scheitert am Fremdschlüssel statt still mitzulaufen (Vorgabe DS-S14-06 an die Festlegung S1.4). Was nach Schritt 3 in der Spur bleibt: dass im Fall Knoten und Kanten bestimmter Schemata zu bestimmten Zeitpunkten von bestimmten Benutzerkennungen erfasst wurden, nicht welche Werte. Ob auch der Schemaname (etwa "Person") nach der Löschung als Klartext in der Spur bleiben darf, ist eine Frage an die Festlegung zu R3-F-020 [OFFEN, Datenschutzexperte mit Software Architect] (LK-10).

**Nachtrag vom 2026-11-09: Abgleich mit GS-43 (ADR 0007, Festlegung S1.4 in der nachgebesserten Fassung).** GS-43: Der Löschweg des Bestands (beziehung, entitaet, herkunft, ohne CASCADE) kommt mit R3-F-020; die Spureinträge bleiben, ihre Pseudonyme werden mit dem Fallschlüssel unumkehrbar; Schemaname, Eigenschaftsnamen, werkzeug und erhebende_person bleiben im Klartext in der Spur.

| Gegenstand | Entwurf oben | GS-43 und Festlegung S1.4 | Ergebnis |
|---|---|---|---|
| Reihenfolge und Zeitpunkt | Schritte 1 bis 4, mit R3-F-020 | beziehung, entitaet, herkunft, mit R3-F-020 | übereinstimmend |
| Weitergabe der Löschung | Empfehlung ausdrückliche Befehle, Fremdschlüssel ohne Weitergabe (DS-S14-06) | ohne CASCADE; Fremdschlüssel ohne ON DELETE und ON UPDATE (Zeile "Revision 0005_bestand") | übereinstimmend; Empfehlung umgesetzt |
| Spureinträge | bleiben unverändert, Pseudonyme unumkehrbar über LW-2 | bleiben, Pseudonyme mit dem Fallschlüssel unumkehrbar | übereinstimmend |
| Klartext in der Spur nach der Löschung | Kennungen, Schemaname, Eigenschaftsnamen, Benutzerkennung (`person_kennung`) | zusätzlich werkzeug, erhoben_am und erhebende_person (E-S14-02 a); die Abfrage als abfrage_pseudonym und abfrage_bindung | **abweichend, nachgeführt:** der Entwurf nannte diese Angaben nicht, weil die Herkunft vor der Nachbesserung nicht in der Spur stand. Nach der Löschung lesbar bleibt damit: im Fall wurde zu einem Zeitpunkt mit einem Werkzeug von einer Benutzerkennung ein Datenpunkt eines Schemas erhoben; nicht über wen und nicht wonach gesucht wurde |
| abfrage_bindung | nicht vorgesehen | HMAC-SHA-256 mit dem Fallschlüssel über die exakten Bytes der Abfrage | nach LW-2 unumkehrbar wie ein Pseudonym; kein eigener Löschschritt nötig |
| Spalte `herkunft.erstellt_am` | nicht genannt | neu (E-S14-06 a) | mit der Zeile gelöscht (Schritt 3) |
| Rückweg der Revision | — | `backend/migrationen/sql/0005_bestand_rueckweg.sql` (Zeile "Revision 0005_bestand") entfernt die drei Tabellen | ist ein Migrationsweg, kein Löschweg: er ist nicht fallbezogen, schreibt keinen Grabstein und ist nicht Teil von `R3-F-020_loeschweg_vollstaendig` |

**Bewertung der Abweichung.** werkzeug ist eine Kennung ohne Personenbezug; erhebende_person ist wie `person_kennung` die Zurechnung einer Handlung an Mitarbeitende (E-S1-07 a) und bleibt aus demselben Grund. Daten der betroffenen Personen bleiben nach der Löschung nicht lesbar in der Spur. Ob die Kombination aus Schemaname "Person", Werkzeug und Zeitpunkt nach der Löschung bleiben darf, wird zusammen mit dem Schemanamen in LK-10 entschieden; LK-10 ist um werkzeug, erhoben_am und erhebende_person erweitert (Abschnitt 11, Nachtrag).

**Was der Löschweg zusätzlich erfassen muss (GS-38).** Am unmittelbaren Weg kann die Anwendungsrolle Datenpunkte ohne Spureintrag und in einen abgeschlossenen Fall schreiben. Der Löschweg wählt deshalb allein über `fall_kennung`, nie über die Spur oder den Zustand zur Zeit des Schreibens; Spureinträge `entitaet` oder `beziehung` ohne Datenpunkt bleiben wie jeder Spureintrag (LK-11, Nachtrag).

## 6. Grabstein-Eintrag

Nach der Löschung bleibt ein Grabstein-Eintrag: Fallnummer, Löschzeitpunkt, wer freigegeben hat, Rechtsgrundlage, Prüfsumme; kein Inhalt (4.4, Problem A; Glossar). Damit bleibt die Kette lückenlos und die Löschung selbst belegt.

| Bestandteil | Abbildung im gebauten Stand | Bemerkung |
|---|---|---|
| Fallnummer | `fall.kennung` (ADR 0007, Entscheid 22) | bleibt; die Zeile in `fall` bleibt bestehen, die Spuren verweisen darauf |
| Löschzeitpunkt | — | mit R3-F-020 |
| freigebende Person | Benutzerkennung (E-S1-07 a) | bei Vier-Augen-Prinzip beide Personen [OFFEN, Software Architect] |
| Rechtsgrundlage | — | **Widerspruch zu klären:** Der Löschweg leert `fall.rechtsgrundlage` (E-S1-06 b). Gemeint ist im Grabstein entweder die Rechtsgrundlage der Löschung (etwa Vernichtungspflicht nach R3 und Bearbeitungsreglement) oder die des Falls; im zweiten Fall bliebe ein Falldatum im Klartext. [OFFEN, Software Architect mit GRC-Rolle] |
| Prüfsumme | — | Worüber die Prüfsumme gebildet wird (Falldaten vor dem Leeren, letzte Kettenprüfsumme je Spur), ist nicht bestimmt [OFFEN, Software Architect mit Digital-Forensics-Spezialist] |
| Ort | — | Eintragstyp `grabstein` kommt als Erweiterung des Vorrats mit seinem Eintrag (ADR 0007, Nr. 14); in Sprint 1 besteht er nicht |

## 7. Problem A und Problem B (4.4, Punkt 5)

**Problem A: Die Protokollkette darf nicht brechen.** Gelöst durch die Pseudonymisierung: Das Protokoll hält fest, dass etwas geschah, nicht was; die Fallinhalte liegen im Datenbestand. Im gebauten Stand tragen `fall_eroeffnet` und `fall_geschlossen` Aktenzeichen, Rechtsgrundlage und ermittelnde Person allein als Pseudonym (ADR 0007, Nr. 17 und 26). Eine Fallöschung berührt die Kette nicht; die Spurtabellen lassen DELETE ohnehin für keine Rolle zu (Nr. 10). Den Nachweis über alle Spalten bringt R3-F-011 in S1.5.

**Problem B: Sicherungen lassen sich nicht selektiv umschreiben.** Lösung nach 4.4: ein eigener Schlüssel je Fall, die Falldaten damit verschlüsselt, die Löschung vernichtet den Schlüssel. Stand Sprint 1:

- Gebaut ist allein der Schlüssel je Fall für die **Pseudonymisierung** (E-S1-06 b). Wird er vernichtet, werden die Pseudonyme der Spuren unumkehrbar.
- **Nicht gebaut** ist die Verschlüsselung der Falldaten selbst und die Verwaltung der Schlüssel getrennt von den Sicherungen (O-6, fällig vor R3-F-020). Bis dahin läge ein gelöschter Fall in einer Sicherung im Klartext weiter vor; der Schlüssel selbst liegt unverschlüsselt in Datenbank, Schreibprotokoll und Sicherung (GS-5). In Test/Schulung gibt es keine Sicherung und nur synthetische Daten; für die Produktion ist O-6 Vorbedingung von Punkt 4 der Bereitschaftsliste.

**Nachtrag vom 2026-11-09 (Einheit S1.5, Stellungnahme zur Pseudonymisierung).** Stand: festgelegt, nicht gebaut. Der Nachweis zu Problem A (R3-F-011) ist mit den Vorgaben DS-S15-01 bis DS-S15-10 beschrieben (Bearbeitungsverzeichnis, B-02, Nachtrag D). Für dieses Konzept folgt daraus dreierlei: (1) Der Nachweis von S1.5 deckt die Tabellen des Schemas und die Ausgaben des Prozesses im Test, nicht das Protokoll des Datenbankservers, das Schreibprotokoll und Sicherungen (DS-S15-10 a und b); für diese bleibt Problem B nach LW-11, LW-12 und O-6 offen. (2) Die Unumkehrbarkeit nach LW-2 gilt allein, weil die Spuren keine Klartextwerte tragen; Pseudonyme kleiner Wertebereiche (Rufnummern, Namen, Aktenzeichen, Benutzerkennungen) sind mit dem Fallschlüssel durch Probieren umkehrbar, solange er besteht. Der Abnahmetest von R3-F-020 prüft deshalb nach dem Löschweg zusätzlich, dass der Fallschlüssel in keiner Tabelle mehr lesbar ist und ein Pseudonym des Testfalls mit keinem verbliebenen Schlüssel nachrechenbar ist (Vorschlag an den Product Owner mit LK-11). (3) Die Benutzerkennungen bleiben nach der Fallöschung im Klartext in der Spur (E-S1-07 a, LK-10); trägt eine Kennung den Namen einer mitarbeitenden Person, bleibt dieser Name (DS-S15-10 c, Bearbeitungsverzeichnis BV-16).

**Nachtrag vom 2026-11-09 (Einheit S1.5, gebauter Stand).** Stand: S1.5 gebaut am 2026-11-09, zur Abnahme vorgelegt mit dem Pull Request der Einheiten D26 und S1.5 (Angabe des Koordinators, Fremdbeleg; ADR 0007, Festlegung S1.5; Verlauf in `docs/uebergaben/2026-11-05_d21-etappe-1-sprint-1.md`, Abschnitt "Einheit S1.5"; Einzelheiten im Bearbeitungsverzeichnis, B-02, Nachtrag D, D.4). Der Nachweis zu Problem A besteht damit für die Tabellen des Schemas und die Ausgaben des Testprozesses (Abnahmetest R3-F-011, Z01 bis Z14). Grenze des Nachweises (GS-52): nicht umfasst sind das Protokoll des Datenbankservers (GS-28, BV-10; gemessen: DETAIL mit Klartext beim doppelten Aktenzeichen), das Schreibprotokoll und Sicherungen (LW-11, LW-12, GS-5, O-6); für sie bleibt Problem B offen. Zusätzlich zu (1) bis (3) oben: (4) Auf Stufe DEBUG meldet sqlalchemy.engine den Fallschlüssel als Ergebniszeile (GS-54, E-S15-10 a); ein so protokollierter Schlüssel überdauert seine Vernichtung nach LW-2, die Unumkehrbarkeit setzt deshalb die Betriebsregel aus GS-54 voraus (R3-F-019). (5) werkzeug, erhebende_person und person_kennung werden nur der Form nach geprüft (DF-S15-D16-01); ein dort eingesetztes Falldatum stünde im Klartext in der Spur und überdauerte nach GS-43 die Löschung. Die Empfehlung zu LK-10 (Abschnitt 11, Nachtrag) gilt deshalb nur, solange werkzeug aus einem geschlossenen Werkzeugverzeichnis stammt (R3-F-026) und Benutzerkennungen keine Namen tragen (BV-16, GS-55). Ergänzung zum Vorschlag in (2) für den Abnahmetest von R3-F-020: die Suche nach dem Löschweg läuft zusätzlich mit den Suchformen von R3-F-011 über die Protokolltabellen, damit ein Klartext in werkzeug oder in einer Benutzerkennung auffiele (Vorschlag an den Product Owner mit LK-11).

## 8. Protokollpflicht

Jede Löschung, Verlängerung, Sperre und Freigabe ist protokollpflichtig und erscheint in der Kette aus 5.3 (4.4, Punkt 4). In Sprint 1 bestehen allein die Eintragstypen `fall_eroeffnet` und `fall_geschlossen` (ADR 0007, Nr. 14); die übrigen (Zustandswechsel, Verlängerung mit Begründung, Löschsperre setzen und aufheben, Freigabe zur Löschung, Widerruf, Grabstein, Aufgabe) kommen als Erweiterung des Vorrats mit R3-F-020, je in der Arbeitsspur (Nr. 15) und je mit Pseudonymen für jede Angabe ausserhalb der geschlossenen Vorräte (Nr. 17), auch für die Begründung einer Verlängerung.

## 9. Ehrliche Grenze: Exporte

Bereits ausgeführte Exporte (5.10) liegen ausserhalb des Systems und werden von keiner Löschung erreicht. Das Exportprotokoll weist aus, welche Exporte bestehen; ihre Vernichtung ist ein organisatorischer Schritt, kein technischer, und gehört ins Bearbeitungsreglement (4.4, "Ehrliche Grenze"). Ein Löschweg kann für einen Fall mit Exporten deshalb nur melden, dass Exporte bestehen, nicht dass sie vernichtet sind.

## 10. Vermerk zu Punkt 4 der Bereitschaftsliste (5.16)

**Stand 2026-11-09: offen.**

| Teil von Punkt 4 | Stand |
|---|---|
| Bearbeitungsverzeichnis dokumentiert | Erste Fassung mit B-01 "Fall" und B-02 "Protokollspuren" (`docs/datenschutz/bearbeitungsverzeichnis.md`), dazu B-03 "Kanonischer Datenbestand" als Entwurf vor dem Bau von S1.4; weitere Bearbeitungen folgen mit ihren Einheiten; Rechtsgrundlagen im Einzelnen offen (BV-1, BV-2, BV-8). Nachtrag D26 vom 2026-11-09: B-03 gebaut und abgenommen mit dem Merge des Pull Requests #56; Angabe des Koordinators, Fremdbeleg |
| Löschweg getestet und Nachweis abgelegt | **nicht gebaut, nicht getestet, kein Nachweis.** Folgt mit R3-F-020 (`R3-F-020_frist_loescht_nicht`, `R3-F-020_loeschweg_vollstaendig`, `R3-F-020_loeschsperre`); Vorbedingung O-6. Der Nachweis wird unter `docs/datenschutz/` abgelegt, mit Commit-Prüfsumme des geprüften Stands |
| Fristenwerte aus 4.4 bestätigt | **nicht bestätigt.** Startwerte als Vorschlag in `fallkategorie`; Bestätigung oder Korrektur durch die Kantonspolizei Bern im Bearbeitungsreglement (4.4, Punkt 6; 7.2) |

**Nachtrag vom 2026-11-09.** Bearbeitungsverzeichnis und Löschkonzept sind auf die nachgebesserte Festlegung S1.4 nachgeführt (B-03, Nachträge A und B; Abschnitt 5, Nachtrag zu GS-43; Abschnitt 11, Nachtrag). B-03 ist damit kein Entwurf vor dem Bau mehr: S1.4 ist gebaut am 2026-11-09 und zur Abnahme vorgelegt. Punkt 4 bleibt offen: Löschweg und Nachweis folgen mit R3-F-020. Nachtrag D26: S1.4 ist abgenommen mit dem Merge des Pull Requests #56 am 2026-11-09 (Merge-Commit `04e759130e63111556a853487db03b035430e522`; Angabe des Koordinators, Fremdbeleg); an Punkt 4 ändert das nichts, er bleibt offen bis R3-F-020.

## 11. Offene Punkte

| Nr. | Punkt | Zuständig |
|---|---|---|
| LK-1 | Löschsperre als Zustand oder als Markierung neben dem Zustand (W1-30); wer sie setzt und aufhebt (W1-31) | Software Architect (Festlegung R3-F-020), Product Owner |
| LK-2 | Rechtsgrundlage im Grabstein-Eintrag gegen das Leeren von `fall.rechtsgrundlage` (Abschnitt 6) | Software Architect mit GRC-Rolle |
| LK-3 | Gegenstand der Prüfsumme im Grabstein-Eintrag | Software Architect mit Digital-Forensics-Spezialist |
| LK-4 | Verschlüsselung der Falldaten mit dem Schlüssel je Fall und Schlüsselverwaltung getrennt von den Sicherungen (O-6, GS-5), einschliesslich Schreibprotokoll der Datenbank (LW-12) | Software Architect mit SecDevOps Engineer und Datenschutzexperte, vor R3-F-020 |
| LK-5 | Konfigurationsweg für die Fristenwerte im Betrieb, mit Protokolleintrag | Product Owner, Software Architect |
| LK-6 | Vorgang "Fallkategorie ändern" mit Neuberechnung der Prüffrist (4.4, Punkt 3b) | Product Owner |
| LK-7 | Abnahmekriterien für Vier-Augen-Prinzip und Widerruf | Product Owner |
| LK-8 | Bestätigung der Startwerte und der Zuordnung der Fallkategorien | Kantonspolizei Bern (Auftraggeber) |
| LK-9 | Wiederaufnahme eines abgeschlossenen Falls (W1-12) | Product Owner mit GRC-Rolle |
| LK-10 | Schemaname von FollowTheMoney (Klartext `ftm_schema` in den Einträgen `entitaet` und `beziehung`) nach der Fallöschung in der Spur (Abschnitt 5, Absatz "Bestand") | Datenschutzexperte mit Software Architect (Festlegung R3-F-020) |
| LK-11 | Löschweg des Bestands: ausdrückliche Befehle je Tabelle statt Weitergabe über Fremdschlüssel; Abnahme von `R3-F-020_loeschweg_vollstaendig` mit einem Testfall, der Knoten, Kanten und Herkunftssätze ohne verweisenden Datensatz enthält | Software Architect (Festlegung S1.4 für die Fremdschlüssel, Festlegung R3-F-020 für den Löschweg), Product Owner |

**Nachtrag vom 2026-11-09 (nachgebesserte Festlegung S1.4, GS-43).**

| Nr. | Punkt | Zuständig |
|---|---|---|
| LK-10 | Erweitert: neben dem Schemanamen bleiben nach GS-43 auch werkzeug, erhoben_am und erhebende_person im Klartext in den Einträgen `entitaet` und `beziehung`; zu entscheiden ist, ob diese Angaben nach der Fallöschung so bleiben dürfen (Empfehlung des Datenschutzexperten: ja, weil sie keine Daten der betroffenen Personen tragen und die Kette sie bindet) | Datenschutzexperte mit Software Architect (Festlegung R3-F-020) |
| LK-11 | Teil Fremdschlüssel erledigt mit der Festlegung S1.4 (ohne ON DELETE und ON UPDATE). Der Testfall von `R3-F-020_loeschweg_vollstaendig` enthält zusätzlich einen Datenpunkt ohne Spureintrag und einen nach dem Schliessen am unmittelbaren Weg geschriebenen Datenpunkt (GS-38) | Software Architect (Festlegung R3-F-020), Product Owner |
