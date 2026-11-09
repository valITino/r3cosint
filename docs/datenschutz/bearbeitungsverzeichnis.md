# Bearbeitungsverzeichnis R3cOSINT

| Feld | Angabe |
|---|---|
| **Arbeitsprodukt** | Bearbeitungsverzeichnis nach Projektauftrag 4.2 (Rolle Datenschutzexperte) und 4.4 ("Zweckbindung, Bearbeitungsverzeichnis, Aufbewahrung"); Teil von Punkt 4 der Bereitschaftsliste (5.16: "Bearbeitungsverzeichnis dokumentiert, Löschweg getestet und Nachweis abgelegt, Fristenwerte aus 4.4 bestätigt") |
| **Verantwortlich** | Datenschutzexperte |
| **Stand** | 2026-11-09, zur Baueinheit S1.3 (Fall, R3-F-001) nach ADR 0007, Zerlegung, Zeile S1.3; nachgeführt auf den gebauten, nicht abgenommenen Stand von S1.3 (ADR 0007, "Gebauter Stand S1.3") |
| **Status** | Erste Fassung. Erfasst sind die Bearbeitungen, die der gebaute Stand trägt (Revisionen 0002_fall und 0003_spur, Modul spur) und die S1.3 in Betrieb nimmt. Weitere Bearbeitungen kommen mit ihren Einheiten hinzu (Abschnitt 4) |
| **Geltung** | Umgebung Test/Schulung mit ausschliesslich synthetischen Daten (5.6, 5.16). Über den Harness laufen zu keinem Zeitpunkt echte Fall- oder Personendaten (5.15); dieses Dokument enthält keine, auch nicht als Beispiel. Für die Produktion gilt es erst nach Bestätigung der offenen Punkte (Abschnitt 5) |
| **Grundlage** | Projektauftrag 4.4 (Prioritätsordnung, Aufbewahrung und Löschung), 5.3, 5.8, 5.10, 5.12, 5.15, 5.16; `.claude/rules/recht-und-datenschutz.md`; ADR 0007 (Entscheide 13, 17, 22, 23, 26, 27; E-S1-06, E-S1-07, E-S1-09, E-S1-10, E-S1-11; Grenzen GS-1, GS-5, GS-7, GS-20); Backlog R3-F-001, R3-F-011, R3-F-020; Glossar (Fall, Fallkategorie, Rechtsregime, Aktenzeichen, Prüffrist, Löschweg, Grabstein-Eintrag) |
| **Zugehörig** | Löschkonzept (Entwurf): `docs/datenschutz/loeschkonzept.md` |

## Leseanleitung

- Je Bearbeitung ein Abschnitt mit den Feldern Zweck, Rechtsgrundlage, Datenkategorien, betroffene Personen, Empfänger, Aufbewahrung und Löschweg; danach "Stand der Umsetzung" und die offenen Punkte der Bearbeitung.
- **Rechtsgrundlage** folgt der Prioritätsordnung aus 4.4 (Ränge R1 bis R5). Genannt wird der Rang und der Erlass, nicht ein Artikel: Die Belegpflicht verlangt, Artikelnummern erst nach Prüfung der geltenden Fassung zu verwenden (`.claude/rules/recht-und-datenschutz.md`, "Belegpflicht"; 4.4, "Hinweis zur Aktualität"). Die Einschlägigkeit im Einzelnen erarbeitet die GRC-Rolle in der Konformitätsanalyse (Punkt 5 der Bereitschaftsliste); wo sie fehlt, steht [OFFEN].
- Das revDSG des Bundes ist für kantonale Organe nicht direkt anwendbar und wird nicht herangezogen (4.4, Tabelle). Die Anwendbarkeit der DSGVO ist zu klären, nicht zu unterstellen (4.4, "Zu prüfende Rechtsgebiete") [OFFEN]; dieses Verzeichnis stützt sich nicht auf sie.
- **Stand der Umsetzung** unterscheidet, was gebaut ist (Revision, Modul), was S1.3 baut und was erst mit einem späteren Eintrag entsteht. Angaben anderer Rollen sind als Fremdbeleg gekennzeichnet.
- Zitierte Bezeichner (Tabellen, Spalten, Eintragstypen) sind die des gebauten Schemas; Begriffe folgen dem Glossar (Fallkategorie; "Aufbewahrungsklasse" ist Synonym und wird hier nicht verwendet).
- Das Zugriffsmodell auf Dezernatsebene (5.8) ist gesetzt; es wird dokumentiert, nicht bewertet (4.4, "Was die Rolle nicht tut").

## 1. Geltung und Abgrenzung

| Punkt | Festhaltung |
|---|---|
| Verantwortliches Organ im Betrieb | Kantonspolizei Bern (1.1, 5.16). Bezeichnung der zuständigen Stelle und der Ansprechperson für Datenschutz im Bearbeitungsreglement [OFFEN, Auftraggeber] |
| Was erfasst ist | Bearbeitungen von Personendaten durch R3cOSINT selbst, je Datensammlung (4.4, KDSG: "Der Zeitpunkt der Vernichtung ist pro Datensammlung von der Institution selbst festzulegen") |
| Was nicht erfasst ist | Die Entwicklung im Harness (keine echten Daten, 5.15); der Prototyp (synthetische Daten ohne reale Personen, 5.6); biometrische Verarbeitung (das Modul Gesichtserkennung ist gestrichen, es entstehen keine biometrischen Vektoren, 5.18) |
| Umgebungen | Test/Schulung und Produktion sind getrennt, ohne Importweg in beide Richtungen, ohne gemeinsamen Speicher, ohne geteilte Zugangsdaten (5.16). Jede Bearbeitung gilt je Umgebung für sich; eine Übermittlung zwischen den Umgebungen gibt es nicht |
| Diagnose | Diagnoseausgaben enthalten keine Personendaten aus laufenden Ermittlungen, keine Zugangsdaten und keine Tokens (5.12); eine Bearbeitung "Diagnose" mit Personendaten ist deshalb nicht vorgesehen |

## 2. Bearbeitung B-01 "Fall"

| Feld | Angabe |
|---|---|
| **Kennung** | B-01 |
| **Datensammlung** | Tabellen `fall`, `fallkategorie` und `fall_schluessel` im Schema r3cosint (Revision 0002_fall; ADR 0007, Entscheid 22). Dienstschicht `fall.service` mit den Vorgängen eröffnen und schliessen (Baueinheit S1.3; ADR 0007, Entscheid 23) |
| **Zweck** | Jeder Ermittlungsschritt wird einem Verfahren und einer Person zugeordnet (Verfahrensgarantie Fallbindung, 5.4; R3-F-001), und für jeden Fall bleibt bestimmbar, welche Löschregel gilt: Der Fall trägt sein Rechtsregime ab der Eröffnung (4.4, "Warum die Aufteilung an der Spitze wichtig ist") und seine Fallkategorie, aus der die Prüffrist abgeleitet wird (4.4, Punkt 3b). Weitere Zwecke sind nicht vorgesehen; eine Auswertung der Falldaten über Fälle hinweg ist nicht Gegenstand (ADR 0007, E-S1-12) |
| **Rechtsgrundlage** | Je Fall nach dem Feld `rechtsregime`: **R1** StPO (Bund) für Daten innerhalb eines hängigen Strafverfahrens, wo das kantonale Datenschutzgesetz ausdrücklich nicht anwendbar ist; **R2** PolG/BE, BSG 551.1, für polizeiliche Datenbearbeitung ausserhalb eines hängigen Verfahrens (4.4, Tabelle; ADR 0007, E-S1-09 a; Glossar, Rechtsregime). **R3** KDSG, BSG 152.04, gilt subsidiär als allgemeiner kantonaler Rahmen (Verhältnismässigkeit, Zweckbindung, gesetzliche Grundlage, Vernichtung nicht mehr benötigter Daten). R4 (Schengen-relevante Bearbeitung) ist Eigenschaft einer Bearbeitung, nicht Regime eines Falls; ob und wann sie greift, ist [OFFEN, GRC-Rolle]. R5 (Archivierung) betrifft die Phase nach dem Betriebszweck (Zustand "Archiviert", Löschkonzept Abschnitt 2). Die Bestimmungen, die das Führen einer Fallverwaltung in R1 und R2 tragen, und die Artikelnummern der geltenden KDSG-Fassung erarbeitet die GRC-Rolle [OFFEN]. revDSG: nicht herangezogen. DSGVO: Anwendbarkeit [OFFEN], nicht unterstellt |
| **Betroffene Personen** | (a) Mitarbeitende der Kantonspolizei Bern als ermittelnde Person eines Falls. (b) Mittelbar Personen des Verfahrens, auf das das Aktenzeichen verweist; die Tabelle `fall` führt keine Angaben zu ihnen, das Aktenzeichen ist aber ein Schlüssel zum Verfahren ausserhalb von R3cOSINT. Angaben zu Personen im Fall (Namen, Adressen, Telefonnummern) entstehen erst mit dem Bestand (S1.4, Abschnitt 4) |
| **Empfänger** | In Sprint 1 keine Schnittstelle: keine HTTP-Endpunkte, die Fachlogik ist allein über die Dienstschicht erreichbar (ADR 0007, Entscheid 27). Keine Übermittlung an Dritte, kein Rückkanal (5.4). Im Betrieb: Angehörige des Dezernats nach dem gesetzten Zugriffsmodell auf Dezernatsebene, darüber wirkend Klassifizierung und fallbezogene Freigabeliste (5.8); der Administrator erhält keinen fachlichen Zugriff, nur weil er Administrator ist (5.8). Jeder lesende Zugriff auf einen Fall wird protokolliert (5.8); gebaut ist das nicht (Abschnitt 4) |
| **Aufbewahrung** | Nichts wird automatisch gelöscht, aber kein Fall bleibt ohne Entscheid (4.4, Punkt 1). Die Prüffrist beginnt mit dem Schliessen, nie mit der Eröffnung; `prueffrist_bis` = `geschlossen_am` plus `erste_pruefung_monate` der Fallkategorie in Kalendermonaten, beim Schliessen festgeschrieben (ADR 0007, Entscheid 23, E-S1-11 a). Die Werte je Fallkategorie sind Daten der Tabelle `fallkategorie`, keine Konstante im Code; die Startwerte aus 4.4, Punkt 3, sind betriebliche Voreinstellungen zur Bestätigung durch die Kantonspolizei Bern, keine rechtliche Festlegung (Löschkonzept Abschnitt 3). Ihr Erreichen löst eine Aufgabe aus, nie eine Löschung |
| **Löschweg** | Folgt mit R3-F-020 (Löschkonzept Abschnitte 5 bis 7). Festgelegt ist die Richtung (ADR 0007, E-S1-06 b und Entscheid 22): Der Löschweg leert `aktenzeichen`, `ermittelnde_person` und `rechtsgrundlage` in `fall` (die Prüfbedingung verlangt sie nur, solange `zustand` nicht `geloescht` ist), löscht die Zeile in `fall_schluessel` und lässt die Spuren unberührt; es bleibt ein Grabstein-Eintrag. In Sprint 1 gibt es keinen Löschweg: die Anwendungsrolle hat kein DELETE und kein Änderungsrecht auf diese Spalten (Revision 0002_fall), der Zustand `geloescht` ist nicht erreichbar. Punkt 4 der Bereitschaftsliste ist damit offen |

### 2.1 Datenkategorien je Spalte

| Tabelle, Spalte | Inhalt | Personenbezug | Im Protokoll (Arbeitsspur) | Nach der Löschung (R3-F-020, E-S1-06 b) |
|---|---|---|---|---|
| `fall.kennung` | Vom System vergebene Kennung (uuid), zugleich Fallnummer des späteren Grabstein-Eintrags | keiner | Klartext (Kennung, ADR 0007, Nr. 17) | bleibt (Fallnummer, Glossar, Aktenzeichen, "Abzugrenzen von") |
| `fall.aktenzeichen` | Kennzeichen des Verfahrens, ausserhalb von R3cOSINT vergeben; eindeutig unter den nicht gelöschten Fällen (E-S1-10 a, Teilindex) | mittelbar (Schlüssel zum Verfahren) | allein als Pseudonym `aktenzeichen_pseudonym` im Eintrag `fall_eroeffnet` | geleert |
| `fall.ermittelnde_person` | Wer den Fall führt, als Benutzerkennung ohne Namen (E-S1-07 a; Zuordnung zum Namen erst über das Kontoverzeichnis der Anmeldung, Etappe 3) | ja (Mitarbeitende) | allein als Pseudonym `ermittelnde_person_pseudonym` | geleert (Falldatum, ADR 0007, Entscheid 22) |
| `fall.rechtsgrundlage` | Rechtsgrundlage des Falls als Text | in der Regel keiner; als Freitext kann sie Personendaten tragen, wenn sie zweckwidrig befüllt wird | allein als Pseudonym `rechtsgrundlage_pseudonym` | geleert |
| `fall.rechtsregime` | R1 oder R2 (geschlossener Vorrat, Prüfbedingung) | keiner | Klartext (geschlossener Vorrat) | bleibt |
| `fall.fallkategorie` | Kennung der Fallkategorie (Verweis auf `fallkategorie`) | keiner; sie sagt aber etwas über die Schwere des Verfahrens | Klartext (geschlossener Vorrat) | bleibt |
| `fall.zustand` | Zustand nach dem Zustandsmodell aus 4.4 (Löschkonzept Abschnitt 2) | keiner | mittelbar über die Eintragstypen | `geloescht` |
| `fall.eroeffnet_am`, `fall.geschlossen_am`, `fall.prueffrist_bis` | Zeitpunkte in UTC | keiner | Klartext (Zeitpunkte) in `fall_eroeffnet` und `fall_geschlossen` | bleiben |
| `fallkategorie` (alle Spalten) | Kategorien und Prüffristen in Monaten; Konfiguration, nicht Falldaten | keiner | nein | unberührt |
| `fall_schluessel.schluessel` | 32 Zufallsbytes je Fall, beim Eröffnen erzeugt; Schlüssel der Pseudonyme dieses Falls (HMAC-SHA-256, E-S1-06 b) | keiner; er macht aber Pseudonyme der Spuren prüfbar und bei kleinem Wertebereich umkehrbar | nie | Zeile gelöscht; die Pseudonyme werden damit unumkehrbar (4.4, Problem B) |

**Geheimnis Fallschlüssel (Grenze GS-5).** In Sprint 1 liegt der Fallschlüssel unverschlüsselt in der Datenbank, in ihrem Schreibprotokoll und in jeder künftigen Sicherung. Das Pseudonym schützt gegen Leser des Protokolls ohne Zugriff auf die Datenbank, nicht gegen Leser der Datenbank: wer `fall_schluessel` lesen kann, kann kleine Wertebereiche durchprobieren. Die Verwaltung der fallbezogenen Schlüssel getrennt von den Sicherungen ist O-6 (ADR 0002, Abschnitt 8; fällig vor R3-F-020). In Test/Schulung gibt es nur synthetische Daten und keine Sicherung.

**Spuren ohne Klartextwerte (4.4, Problem A).** Die Einträge `fall_eroeffnet` und `fall_geschlossen` der Arbeitsspur tragen Kennungen, Werte aus geschlossenen Vorräten, Zeitpunkte und Pseudonyme, keine Klartextwerte von Aktenzeichen, ermittelnder Person oder Rechtsgrundlage (ADR 0007, Entscheide 17 und 26; `spur.payload`, Eingaben FallEroeffnet und FallGeschlossen). Das Protokoll hält fest, dass eröffnet und geschlossen wurde, nicht was; eine Fallöschung berührt die Kette deshalb nicht. Den Nachweis über alle Text- und JSON-Spalten der Spuren erbringt R3-F-011 in S1.5.

### 2.2 Technische Massnahmen (Stand des Schemas)

| Massnahme | Fundort |
|---|---|
| Eröffnung nur mit gesetztem Rechtsregime R1 oder R2, vor jedem Schreiben (Pydantic) und in der Prüfbedingung | ADR 0007, Entscheid 23; Revision 0002_fall, Prüfbedingung des Vorrats |
| Aktenzeichen, ermittelnde Person und Rechtsgrundlage gesetzt, solange der Fall nicht gelöscht ist | Revision 0002_fall, Prüfbedingung der Falldaten |
| Kleinstes Recht der Anwendungsrolle: an `fall` SELECT, INSERT und UPDATE allein auf `zustand`, `geschlossen_am`, `prueffrist_bis`; an `fall_schluessel` SELECT, INSERT; an `fallkategorie` SELECT; nirgends DELETE | ADR 0007, Nr. 9; Revision 0002_fall |
| Vorgang und Protokolleintrag in derselben Transaktion | ADR 0007, Entscheid 23; Grenze GS-20 (die Bindung trägt ab S1.3 die Dienstschicht) |
| Zustandsübergänge in der Datenbank gebunden: Auslöser `fall_uebergang` lässt ein INSERT in `fall` allein im Zustand `aktiv` ohne `geschlossen_am` und `prueffrist_bis` zu und ein UPDATE allein von `aktiv` nach `abgeschlossen`; alles andere wird abgewiesen, Ausnahme allein die Eigentümerrolle | Revision 0004_fall_uebergang; ADR 0007, Festlegung S1.3 (E-S13-12 b) |
| Grenze: Die Anwendungsrolle kann den Übergang `aktiv` nach `abgeschlossen` am Dienst vorbei setzen, ohne Eintrag `fall_geschlossen` in der Arbeitsspur und mit `geschlossen_am` und `prueffrist_bis` ausserhalb der Regel; offen bis R3-F-020 | ADR 0007, Grenze GS-26; Schwachstellenregister SR-030 (offen) |
| Pseudonymisierer gibt den Schlüssel weder in der Darstellung noch bei der Serialisierung heraus | `spur.payload`, Klasse Pseudonymisierer |

### 2.3 Stand der Umsetzung B-01

Stand 2026-11-09: S1.3 gebaut, nicht abgenommen.

| Teil | Stand |
|---|---|
| Schema `fall`, `fallkategorie` mit Startwerten, `fall_schluessel` | gebaut (Revision 0002_fall, abgenommen mit S1.2) |
| Eröffnen und Schliessen mit Einträgen in der Arbeitsspur | gebaut am 2026-11-09 (Baueinheit S1.3: `fall.eingabe`, `fall.store`, `fall.service`, Revision 0004_fall_uebergang), zur Abnahme vorgelegt mit dem Pull Request der Einheiten D24 und S1.3; nicht abgenommen |
| Erreichbare Zustände | allein aktiv und abgeschlossen (ADR 0007, Entscheid 22) |
| Person | bis zur Anmeldung (Etappe 3) ein Parameter des Aufrufs, keine Authentifizierung (Grenze GS-1) |
| Prüfung fällig, Aufgabe, Verlängerung, Löschsperre, Löschweg, Grabstein | nicht gebaut, R3-F-020 |

## 3. Bearbeitung B-02 "Protokollspuren"

Nur so weit, wie der gebaute Stand sie trägt (Revision 0003_spur, Modul spur; abgenommen mit S1.2).

| Feld | Angabe |
|---|---|
| **Kennung** | B-02 |
| **Datensammlung** | Tabellen `ermittlungsspur`, `arbeitsspur` und `kettenkopf` (ADR 0007, Entscheide 12 und 13) |
| **Zweck** | Nachweis, was im Fall geschah und wie man dorthin kam, für Akte, Verteidigung, Gericht und Aufsicht (5.3); Unversehrtheit über die Verkettung mit SHA-256 je Spur und Fall (R3-F-008, R3-F-012) |
| **Rechtsgrundlage** | Wie B-01 nach dem Rechtsregime des Falls (R1 oder R2, R3 subsidiär). Die Abgrenzung zwischen der Löschung von Nichttreffern nach dem Bundesgerichtsentscheid vom August 2026 und der Pflicht, Negativbefunde zu protokollieren (5.3), hält die GRC-Rolle schriftlich fest (4.4, Punkt 7) [OFFEN, GRC-Rolle]; in Sprint 1 gibt es noch keinen Eintragstyp für Negativbefunde (ADR 0007, Nr. 14) |
| **Betroffene Personen** | (a) Mitarbeitende als handelnde Person je Eintrag. (b) Personen im Fall, allein über Pseudonyme |
| **Datenkategorien** | Je Eintrag: Kennung, Fallkennung, Position, Zeitpunkt, `person_kennung`, Eintragstyp, Kennzeichnung (quellenaussage oder schlussfolgerung), Nutzlast als kanonisches JSON, Vorgänger-Prüfsumme und Prüfsumme; im Kettenkopf Fallkennung, Spur, Position und Prüfsumme. `person_kennung` ist die Benutzerkennung im Klartext (Form `^[a-z0-9._-]{1,64}$`), Zurechnung einer Handlung und keine Falldatenkategorie (E-S1-07 a). Die Nutzlast trägt Klartext allein für Kennungen, geschlossene Vorräte, Zeitpunkte, ganze Zahlen und Prüfsummen; jede andere Angabe allein als Pseudonym mit dem Schlüssel des Falls (ADR 0007, Nr. 17; E-S1-06 b). Vorrat der Eintragstypen in Sprint 1: `fall_eroeffnet`, `fall_geschlossen` (Arbeitsspur), `entitaet`, `beziehung` (Ermittlungsspur) |
| **Empfänger** | Wie B-01. Die Kette eines Falls lässt sich der Verteidigung offenlegen, ohne andere Verfahren zu berühren (E-S1-05 b); der Export (5.10) ist nicht gebaut |
| **Aufbewahrung** | Ausschliesslich anfügbar; UPDATE, DELETE und TRUNCATE werden für jede Rolle abgewiesen (ADR 0007, Nr. 10 und 13). Die Spuren bleiben auch nach einer Fallöschung bestehen (4.4, Problem A). Wie lange sie über die Vernichtung des Fallschlüssels hinaus aufbewahrt werden und ob sie an der Archivierung (R5) teilnehmen, ist [OFFEN, GRC-Rolle mit Datenschutzexperte] |
| **Löschweg** | Keine Löschung von Einträgen. Die Fallöschung vernichtet den Fallschlüssel; die Pseudonyme in den Spuren werden damit unumkehrbar, ohne die Kette zu brechen (4.4, Problem B; E-S1-06 b). Es bleibt die Benutzerkennung in `person_kennung` (E-S1-07 a) |

**Grenzen der Bearbeitung B-02**, soweit sie den Datenschutz berühren: Normalisierung vor dem Pseudonym ist allgemein, verschiedene Quellwerte gleicher Normalform ergeben dasselbe Pseudonym (GS-7); gegen den Superuser der Instanz hält kein Mittel in der Datenbank (GS-2); eine Kettenprüfung schreibt keinen Eintrag (GS-16).

## 4. Noch nicht erfasste Bearbeitungen

Erfasst wird je Bearbeitung mit der Einheit, die sie baut; bis dahin besteht sie nicht.

| Bearbeitung | Entsteht mit | Bemerkung |
|---|---|---|
| Kanonischer Bestand (Entitäten, Beziehungen, Herkunft) mit Namen, Adressen und Telefonnummern | S1.4 (R3-F-003, R3-F-005) | Stellungnahme des Datenschutzexperten zu den Personendaten im Bestand nach ADR 0007, Zerlegung, Zeile S1.4; `erhebende_person` in `herkunft` ist Zurechnung wie `person_kennung` (E-S1-07 a) |
| Protokoll lesender Zugriffe | späterer Eintrag (5.8, Bereitschaft Punkt 2) | nicht im Sprint Backlog |
| Benutzerkonten und Anmeldung | Etappe 3 (5.7) | bis dahin GS-1 |
| Aufgaben an Fallverantwortliche, Grabstein-Einträge | R3-F-020 | Löschkonzept |
| Export und Exportprotokoll | späterer Eintrag (5.10) | bereits ausgeführte Exporte liegen ausserhalb jeder Löschung (4.4, "Ehrliche Grenze") |
| Sprachmodell, Quellenabfragen, Alias-Profile, Anhänge und Asservate, Suchindex, Graph | spätere Etappen | je mit eigenem Eintrag |

## 5. Offene Punkte

| Nr. | Punkt | Zuständig |
|---|---|---|
| BV-1 | Einschlägige Bestimmungen in R1 und R2 für das Führen der Fallverwaltung; Artikelnummern der geltenden KDSG-Fassung nach der Totalrevision vom 3. Dezember 2025 | GRC-Rolle, Gegenprüfung Legal Reviewer |
| BV-2 | Anwendbarkeit der DSGVO (nicht unterstellt) und Geltung von R4 je Bearbeitung | GRC-Rolle |
| BV-3 | Bezeichnung des verantwortlichen Organs und der Ansprechperson für Datenschutz im Bearbeitungsreglement | Auftraggeber (Kantonspolizei Bern) |
| BV-4 | `fall.rechtsgrundlage` ist Freitext ohne Formprüfung, `fall.ermittelnde_person` ohne die Formprüfung der Benutzerkennung, die `person_kennung` in den Spuren trägt; beide könnten zweckwidrig Namen aufnehmen. **Erledigt** mit ADR 0007, Festlegung S1.3 (Zeile "Stellungnahmen vor dem Bau": BV-4 eingearbeitet), gebaut am 2026-11-09: `ermittelnde_person` in der Form der Benutzerkennung, geprüft in `fall.eingabe`, Eroeffnung; Höchstlänge der Rechtsgrundlage 2000 Zeichen in der Angleichung | Software Architect (Festlegung S1.3) |
| BV-5 | Aufbewahrung der Spuren nach der Fallöschung und ihr Verhältnis zur Archivierung (R5) | GRC-Rolle mit Datenschutzexperte |
| BV-6 | Abgrenzung Nichttreffer (Bundesgericht, August 2026) gegen Negativbefunde (5.3), schriftlich | GRC-Rolle (4.4, Punkt 7) |
| BV-7 | Schlüsselverwaltung getrennt von den Sicherungen (O-6, GS-5) | Software Architect mit SecDevOps Engineer und Datenschutzexperte, vor R3-F-020 |
