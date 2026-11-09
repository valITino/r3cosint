# Löschkonzept R3cOSINT (ENTWURF)

| Feld | Angabe |
|---|---|
| **Status** | **ENTWURF.** Kein gebauter Löschweg, kein Test, kein Nachweis. Der Löschweg und sein Nachweis folgen mit R3-F-020; bis dahin ist Punkt 4 der Bereitschaftsliste (5.16) offen (Abschnitt 10) |
| **Arbeitsprodukt** | Löschkonzept nach Projektauftrag 4.2 (Rolle Datenschutzexperte) und 4.4, "Aufbewahrung und Löschung"; Teil von Punkt 4 der Bereitschaftsliste |
| **Verantwortlich** | Datenschutzexperte |
| **Stand** | 2026-11-09, zur Baueinheit S1.3 (Fall, R3-F-001) nach ADR 0007, Zerlegung, Zeile S1.3: "Löschkonzept als Entwurf mit dem Vermerk, dass der Löschweg mit R3-F-020 folgt"; nachgeführt auf den gebauten, nicht abgenommenen Stand von S1.3 (gebaut am 2026-11-09, zur Abnahme vorgelegt mit dem Pull Request der Einheiten D24 und S1.3; ADR 0007, "Gebauter Stand S1.3"): Eröffnen und Schliessen gebaut, Übergänge zusätzlich durch den Auslöser `fall_uebergang` der Revision 0004_fall_uebergang gebunden, Grenze GS-26 mit SR-030 (offen bis R3-F-020) |
| **Geltung** | Test/Schulung mit synthetischen Daten (5.6, 5.16); keine echten Fall- oder Personendaten über den Harness (5.15) |
| **Grundlage** | Projektauftrag 4.4 (Punkte 1 bis 7), 5.3, 5.10, 5.16; `.claude/rules/recht-und-datenschutz.md`, "Aufbewahrung: nichts wird automatisch gelöscht"; ADR 0007 (Entscheide 9, 14, 22, 23; E-S1-06 b, E-S1-07 a, E-S1-11 a; Grenze GS-5; "Nicht Gegenstand"); ADR 0002, Abschnitt 8, O-6; Backlog R3-F-001, R3-F-011, R3-F-020; Glossar (Prüffrist, Fallkategorie, Löschsperre, Löschweg, Grabstein-Eintrag) |
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
| LW-3 | Datenbestand: `entitaet`, `beziehung`, `herkunft` | ab S1.4 | Eigenschaftswerte (Namen, Adressen, Telefonnummern), Herkunftsangaben | Festlegung mit R3-F-020; DELETE nur auf die Tabellen, die der Löschweg nennt (ADR 0007, Nr. 9) |
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

## 8. Protokollpflicht

Jede Löschung, Verlängerung, Sperre und Freigabe ist protokollpflichtig und erscheint in der Kette aus 5.3 (4.4, Punkt 4). In Sprint 1 bestehen allein die Eintragstypen `fall_eroeffnet` und `fall_geschlossen` (ADR 0007, Nr. 14); die übrigen (Zustandswechsel, Verlängerung mit Begründung, Löschsperre setzen und aufheben, Freigabe zur Löschung, Widerruf, Grabstein, Aufgabe) kommen als Erweiterung des Vorrats mit R3-F-020, je in der Arbeitsspur (Nr. 15) und je mit Pseudonymen für jede Angabe ausserhalb der geschlossenen Vorräte (Nr. 17), auch für die Begründung einer Verlängerung.

## 9. Ehrliche Grenze: Exporte

Bereits ausgeführte Exporte (5.10) liegen ausserhalb des Systems und werden von keiner Löschung erreicht. Das Exportprotokoll weist aus, welche Exporte bestehen; ihre Vernichtung ist ein organisatorischer Schritt, kein technischer, und gehört ins Bearbeitungsreglement (4.4, "Ehrliche Grenze"). Ein Löschweg kann für einen Fall mit Exporten deshalb nur melden, dass Exporte bestehen, nicht dass sie vernichtet sind.

## 10. Vermerk zu Punkt 4 der Bereitschaftsliste (5.16)

**Stand 2026-11-09: offen.**

| Teil von Punkt 4 | Stand |
|---|---|
| Bearbeitungsverzeichnis dokumentiert | Erste Fassung mit B-01 "Fall" und B-02 "Protokollspuren" (`docs/datenschutz/bearbeitungsverzeichnis.md`); weitere Bearbeitungen folgen mit ihren Einheiten; Rechtsgrundlagen im Einzelnen offen (BV-1, BV-2) |
| Löschweg getestet und Nachweis abgelegt | **nicht gebaut, nicht getestet, kein Nachweis.** Folgt mit R3-F-020 (`R3-F-020_frist_loescht_nicht`, `R3-F-020_loeschweg_vollstaendig`, `R3-F-020_loeschsperre`); Vorbedingung O-6. Der Nachweis wird unter `docs/datenschutz/` abgelegt, mit Commit-Prüfsumme des geprüften Stands |
| Fristenwerte aus 4.4 bestätigt | **nicht bestätigt.** Startwerte als Vorschlag in `fallkategorie`; Bestätigung oder Korrektur durch die Kantonspolizei Bern im Bearbeitungsreglement (4.4, Punkt 6; 7.2) |

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
