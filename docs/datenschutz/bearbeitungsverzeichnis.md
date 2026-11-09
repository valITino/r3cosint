# Bearbeitungsverzeichnis R3cOSINT

| Feld | Angabe |
|---|---|
| **Arbeitsprodukt** | Bearbeitungsverzeichnis nach Projektauftrag 4.2 (Rolle Datenschutzexperte) und 4.4 ("Zweckbindung, Bearbeitungsverzeichnis, Aufbewahrung"); Teil von Punkt 4 der Bereitschaftsliste (5.16: "Bearbeitungsverzeichnis dokumentiert, Löschweg getestet und Nachweis abgelegt, Fristenwerte aus 4.4 bestätigt") |
| **Verantwortlich** | Datenschutzexperte |
| **Stand** | 2026-11-09, zur Baueinheit S1.3 (Fall, R3-F-001) nach ADR 0007, Zerlegung, Zeile S1.3, abgenommen mit dem Merge des Pull Requests #55 am 2026-11-09 (Angabe des Koordinators, Fremdbeleg); ergänzt am 2026-11-09 um die Bearbeitung B-03 "Kanonischer Datenbestand" als Entwurf vor dem Bau der Einheit S1.4 (ADR 0007, Zerlegung, Zeile S1.4: "Datenschutzexperte (Personendaten im Bestand)"); nachgeführt am 2026-11-09 auf die nachgebesserte Festlegung S1.4 und um die Erhebung DS-S14-08 (B-03, Nachträge A und B); Einheit D26 (2026-11-09): Stand zur Baueinheit S1.4 (Bestand und Herkunft, R3-F-003 und R3-F-005), abgenommen mit dem Merge des Pull Requests #56 am 2026-11-09 (Merge-Commit `04e759130e63111556a853487db03b035430e522`, ohne Kommentar, ohne Review; Angabe des Koordinators, Fremdbeleg); E-S14-01 (b) und VA-S14-01 (a) entschieden (B-03, Nachtrag C) |
| **Status** | Erste Fassung. Erfasst sind die Bearbeitungen, die der gebaute Stand trägt (Revisionen 0002_fall, 0003_spur und 0004_fall_uebergang, Module spur und fall) und, als Entwurf mit dem Stand "festgelegt, nicht gebaut", der kanonische Datenbestand aus S1.4 (Abschnitt 4; Nachtrag vom 2026-11-09: gebaut am 2026-11-09, zur Abnahme vorgelegt; Nachtrag D26: abgenommen mit dem Merge des Pull Requests #56 am 2026-11-09, der gebaute Stand trägt nun auch die Revision 0005_bestand und das Modul kanon). Weitere Bearbeitungen kommen mit ihren Einheiten hinzu (Abschnitt 5) |
| **Geltung** | Umgebung Test/Schulung mit ausschliesslich synthetischen Daten (5.6, 5.16). Über den Harness laufen zu keinem Zeitpunkt echte Fall- oder Personendaten (5.15); dieses Dokument enthält keine, auch nicht als Beispiel. Für die Produktion gilt es erst nach Bestätigung der offenen Punkte (Abschnitt 6) |
| **Grundlage** | Projektauftrag 4.4 (Prioritätsordnung, Aufbewahrung und Löschung), 5.3, 5.4, 5.8, 5.10, 5.12, 5.15, 5.16; `.claude/rules/recht-und-datenschutz.md`; ADR 0007 (Entscheide 9, 13, 17, 22, 23, 24, 25, 26, 27; E-S1-06, E-S1-07, E-S1-09, E-S1-10, E-S1-11, E-S1-12, E-S1-13, E-S1-15; Grenzen GS-1, GS-5, GS-6, GS-7, GS-20); Backlog R3-F-001, R3-F-003, R3-F-005, R3-F-011, R3-F-020; Glossar (Fall, Fallkategorie, Rechtsregime, Aktenzeichen, Prüffrist, Löschweg, Grabstein-Eintrag, Entität, Datenpunkt, Herkunftsnachweis, Klardaten, Kanonischer Datenbestand) |
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
| **Betroffene Personen** | (a) Mitarbeitende der Kantonspolizei Bern als ermittelnde Person eines Falls. (b) Mittelbar Personen des Verfahrens, auf das das Aktenzeichen verweist; die Tabelle `fall` führt keine Angaben zu ihnen, das Aktenzeichen ist aber ein Schlüssel zum Verfahren ausserhalb von R3cOSINT. Angaben zu Personen im Fall (Namen, Adressen, Telefonnummern) entstehen erst mit dem Bestand (S1.4, Bearbeitung B-03, Abschnitt 4) |
| **Empfänger** | In Sprint 1 keine Schnittstelle: keine HTTP-Endpunkte, die Fachlogik ist allein über die Dienstschicht erreichbar (ADR 0007, Entscheid 27). Keine Übermittlung an Dritte, kein Rückkanal (5.4). Im Betrieb: Angehörige des Dezernats nach dem gesetzten Zugriffsmodell auf Dezernatsebene, darüber wirkend Klassifizierung und fallbezogene Freigabeliste (5.8); der Administrator erhält keinen fachlichen Zugriff, nur weil er Administrator ist (5.8). Jeder lesende Zugriff auf einen Fall wird protokolliert (5.8); gebaut ist das nicht (Abschnitt 5) |
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

Stand 2026-11-09: S1.3 gebaut und abgenommen mit dem Merge des Pull Requests #55 am 2026-11-09 (Angabe des Koordinators, Fremdbeleg).

| Teil | Stand |
|---|---|
| Schema `fall`, `fallkategorie` mit Startwerten, `fall_schluessel` | gebaut (Revision 0002_fall, abgenommen mit S1.2) |
| Eröffnen und Schliessen mit Einträgen in der Arbeitsspur | gebaut am 2026-11-09 (Baueinheit S1.3: `fall.eingabe`, `fall.store`, `fall.service`, Revision 0004_fall_uebergang), abgenommen mit dem Merge des Pull Requests #55 am 2026-11-09 |
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

**Nachtrag vom 2026-11-09 (Festlegung S1.4, E-S14-02 a).** Die Einträge `entitaet` und `beziehung` tragen ab dem Bau von S1.4 zusätzlich werkzeug (Kennungsform), erhoben_am (Zeitpunkt) und erhebende_person (Benutzerkennung) im Klartext sowie die Abfrage allein als abfrage_pseudonym und abfrage_bindung (beide HMAC-SHA-256 mit dem Fallschlüssel). Damit führt B-02 neben `person_kennung` eine zweite Benutzerkennung je Eintrag (wer erhoben hat, getrennt von wer abgelegt hat, E-S14-13 a); beide sind Zurechnung an Mitarbeitende, keine Falldaten. Einzelheiten: B-03, Nachtrag A.

## 4. Bearbeitung B-03 "Kanonischer Datenbestand (Entitäten und Beziehungen nach FollowTheMoney) mit Herkunftsnachweis"

**Stand: festgelegt, nicht gebaut.** Entwurf vor dem Bau der Einheit S1.4 (R3-F-003, R3-F-005) nach ADR 0007, Entscheide 24 bis 26 und Zerlegung, Zeile S1.4. Bezeichner sind die der Festlegung (künftige Tabellen `herkunft`, `entitaet`, `beziehung` im Schema r3cosint, Revision 0005, Modul kanon); bis zum Bau besteht keine dieser Tabellen. Am gebauten Stand wird dieser Abschnitt nachgeführt.

**Nachtrag vom 2026-11-09 (Stand):** S1.4 ist gebaut am 2026-11-09 und zur Abnahme vorgelegt mit dem Pull Request der Einheiten D25 und S1.4 (ADR 0007, "Gebauter Stand S1.4"; Angabe des Koordinators, Fremdbeleg). Die Revision 0005_bestand mit `herkunft`, `entitaet` und `beziehung` besteht; abgenommen ist sie erst mit dem Merge dieses Pull Requests. Wo der Text dieses Abschnitts "festgelegt, nicht gebaut" sagt, gilt dieser Stand; Abweichungen der Festlegung gegen den Entwurf: Nachtrag A.

**Nachtrag D26 vom 2026-11-09 (Stand):** S1.4 ist **abgenommen** mit dem Merge des Pull Requests #56 am 2026-11-09 (Merge-Commit `04e759130e63111556a853487db03b035430e522`; erster Formweg, ohne Kommentar, ohne Review; Angabe des Koordinators, Fremdbeleg). Stand von B-03: gebaut und abgenommen (Merge #56); die Revision 0005_bestand mit `herkunft`, `entitaet` und `beziehung` gehört zum abgenommenen Stand. Entscheide mit demselben Merge: Nachtrag C.

| Feld | Angabe |
|---|---|
| **Kennung** | B-03 |
| **Datensammlung** | Tabellen `herkunft`, `entitaet` (Knotenschemata von FollowTheMoney) und `beziehung` (Kantenschemata) im Schema r3cosint (ADR 0007, Entscheide 24 und 25; Revision 0005). Einziger Schreibweg ist die Dienstschicht `kanon.service` (Vertrag 5); je geschriebenem Knoten und je Kante ein Eintrag `entitaet` beziehungsweise `beziehung` in der Ermittlungsspur (Bearbeitung B-02) |
| **Zweck** | Quellergebnisse eines Falls in ein einheitliches Modell überführen, damit sie quellenübergreifend verknüpft und dargestellt werden können, ohne dass die Herkunft verloren geht (5.1, "Warum Ebene 2 entscheidend ist"; R3-F-003), und für jeden Knoten und jede Kante belegen, aus welcher Quelle er stammt, wann und von wem er erhoben wurde (Verfahrensgarantie "Herkunft an jedem Datenpunkt", 5.4; R3-F-005; Glossar, Herkunftsnachweis). Jeder Datensatz gehört genau einem Fall (E-S1-12 a); eine Zusammenführung oder Auswertung über Fälle hinweg ist nicht Gegenstand. Die Bewertung bleibt bei der ermittelnden Person (1.1, "Was R3cOSINT ausdrücklich nicht ist") |
| **Rechtsgrundlage** | Über den Fall: Jeder Datensatz trägt `fall_kennung` und folgt dem Rechtsregime des Falls (B-01): **R1** StPO innerhalb eines hängigen Strafverfahrens, **R2** PolG/BE, BSG 551.1, ausserhalb; **R3** KDSG, BSG 152.04, subsidiär (4.4, Tabelle). Die Bestimmungen, die das Erheben und Verknüpfen von Personendaten aus offenen Quellen in R1 und R2 tragen, sind nicht Gegenstand der Konformitätsanalyse zu F-01 und bleiben [OFFEN, GRC-Rolle mit Gegenprüfung Legal Reviewer] (BV-8). Die Zulässigkeit einer einzelnen Erhebung entscheidet die Rechtsgrundlage im Einzelfall, nicht das Werkzeug (`.claude/rules/recht-und-datenschutz.md`). revDSG: nicht herangezogen. DSGVO: Anwendbarkeit [OFFEN], nicht unterstellt (BV-2) |
| **Betroffene Personen** | (a) Personen, zu denen ein Fall Angaben führt: beschuldigte Personen, Geschädigte, Zeugen, Kontaktpersonen und Dritte, die in einem Quellergebnis vorkommen; auch Unbeteiligte, wenn ein Quellergebnis sie nennt. (b) Mitarbeitende als erhebende Person je Herkunftssatz |
| **Empfänger** | In Sprint 1 keine Schnittstelle: keine HTTP-Endpunkte; zugänglich allein über die Dienstschicht unter der Datenbankrolle der Anwendung (`r3cosint_anwendung`: an `herkunft`, `entitaet`, `beziehung` allein INSERT und SELECT, kein UPDATE, kein DELETE; ADR 0007, Nr. 9 und 27). Keine Übermittlung an Dritte, kein Rückkanal (5.4). Im Betrieb: Angehörige des Dezernats nach dem gesetzten Zugriffsmodell (5.8), darüber wirkend Klassifizierung und fallbezogene Freigabeliste je Entität (5.8; Glossar, Klassifizierungsberechtigung); dokumentiert, nicht bewertet. Der Export (5.10) ist nicht gebaut; was exportiert ist, liegt ausserhalb jeder Löschung (Löschkonzept Abschnitt 9) |
| **Aufbewahrung** | Über den Fall: Der Bestand folgt dem Zustand und der Fallkategorie seines Falls (B-01; Löschkonzept Abschnitte 2 und 3). Kein eigener Fristlauf je Entität; nichts wird automatisch gelöscht, eine Frist löst eine Aufgabe aus (4.4, Punkt 1) |
| **Löschweg** | Folgt mit R3-F-020. Entwurf der Reihenfolge und Wirkung: Löschkonzept, Abschnitt 5, Absatz "Bestand" (LW-3): `beziehung`, dann `entitaet`, dann `herkunft` je Fall; die Einträge `entitaet` und `beziehung` der Ermittlungsspur bleiben, ihre Pseudonyme werden mit dem Vernichten des Fallschlüssels unumkehrbar (E-S1-06 b). In Sprint 1 gibt es keinen Löschweg: die Anwendungsrolle hat an diesen Tabellen kein DELETE (Nr. 9) |

### 4.1 Datenkategorien je Spalte

| Tabelle, Spalte | Inhalt | Personenbezug | In der Ermittlungsspur | Nach der Löschung (Entwurf, R3-F-020) |
|---|---|---|---|---|
| `entitaet.eigenschaften`, `beziehung.eigenschaften` | Eigenschaftswerte nach dem Schema von FollowTheMoney (jsonb): Namen, Adressen, Telefonnummern, E-Mail-Adressen, Kennungen wie Konten, Ausweis- oder Registernummern, Geburtsdaten und weitere Eigenschaften, die das Schema führt | ja, Kern der Bearbeitung; je nach Eigenschaft besonders schützenswert (Risiken R-1) | allein als Pseudonym je Wert (Liste der Pseudonyme, ADR 0007, Nr. 17 und 26; Festlegung S1.2, Zeile "spur.payload, Nutzlast"); Eigenschaftsnamen im Klartext | Zeile gelöscht |
| `entitaet.ftm_kennung`, `beziehung.ftm_kennung` | Kennung des Datensatzes nach FollowTheMoney; kann aus Namen gebildet sein | möglich | allein als Pseudonym `ftm_kennung_pseudonym` | Zeile gelöscht |
| `entitaet.schema`, `beziehung.schema` | Schema von FollowTheMoney (geschlossener Vorrat der Bibliothek, etwa Person, Firma) | keiner; sagt aber, ob ein Knoten eine Person ist | Klartext `ftm_schema` (Nr. 17) | Zeile gelöscht; in der Spur bleibt der Schemaname |
| `beziehung.quelle_kennung`, `beziehung.ziel_kennung` | Verweis auf zwei Entitäten desselben Falls | mittelbar: die Kante verknüpft Personen (Risiken R-2) | Klartext (Kennungen) | Zeile gelöscht; in der Spur bleiben Kennungen ohne Ziel |
| `entitaet.kennung`, `beziehung.kennung`, `herkunft_kennung`, `erstellt_am`, `fall_kennung` | Vom System vergebene Kennungen (uuid), Zeitpunkte, Fallbindung | keiner | Klartext | Zeile gelöscht; in der Spur bleiben die Kennungen |
| `herkunft.werkzeug` | Werkzeug als Text in Kennungsform (Kleinbuchstaben, Ziffern, Punkt, Unterstrich, Bindestrich, 1 bis 64 Zeichen; Nr. 25; GS-6) | keiner | nein (der Eintrag trägt allein `herkunft_kennung`) | Zeile gelöscht |
| `herkunft.abfrage` | Abfrage, aus der der Datensatz stammt, Text bis 4096 Zeichen (Nr. 25) | **ja, in der Regel**: der Suchbegriff ist oft gerade ein Name, eine Adresse oder eine Telefonnummer; zugleich ist die Abfrage der Nachweis, was wann abgefragt wurde (5.2, 5.3) | nein; darf auch künftig nur als Pseudonym in eine Spur (DS-S14-03) | Zeile gelöscht |
| `herkunft.zeitpunkt` | Zeitpunkt der Erhebung in UTC | keiner | nein | Zeile gelöscht |
| `herkunft.erhebende_person` | Wer erhoben hat, als Benutzerkennung ohne Namen, Form der Benutzerkennung (Nr. 25; E-S1-07 a) | ja (Mitarbeitende) | nein; die Zurechnung trägt `person_kennung` des Spureintrags | Zeile gelöscht; die Zurechnung bleibt über `person_kennung` in der Spur (E-S1-07 a) |
| `herkunft.kennzeichnung` | Quellenaussage oder Schlussfolgerung (Nr. 25 wie Nr. 13) | keiner | Klartext als Spalte des Eintrags | Zeile gelöscht |

**Klartext im Bestand, nicht im Protokoll (Nr. 26).** Die Eigenschaftswerte, die Kennung nach FollowTheMoney und der Abfragetext liegen allein im Bestand im Klartext; die Ermittlungsspur trägt Kennungen, Schemanamen, Eigenschaftsnamen und Pseudonyme (HMAC-SHA-256 mit dem Schlüssel des Falls, E-S1-06 b). Gleiche Werte ergeben innerhalb des Falls gleiche Pseudonyme, zwischen Fällen verschiedene; die Spur lässt damit innerhalb eines Falls erkennen, dass ein Wert mehrfach vorkommt, nicht welcher (GS-7).

**Bewertung der Spalte `abfrage` (Frage des Koordinators zu S1.4).** Die Abfrage ist ein Falldatum gleicher Art wie die Eigenschaftswerte: Sie trägt regelmässig Personendaten und ist zugleich der Kern des Herkunftsnachweises (wer hat wann womit wonach gesucht; 5.3 verlangt für die Arbeitsspur "jede Abfrage mit Werkzeug und Parametern"). Ein Pseudonym im Bestand machte den Herkunftsnachweis für Akte, Verteidigung und Gericht unlesbar und hätte keinen Gewinn gegenüber den Eigenschaftswerten daneben, die im selben Datensatz im Klartext stehen. **Empfehlung: Klartext im Bestand ist zulässig**, als Falldatum mit vier Bedingungen: nie im Klartext in einer Spur, in Fehlertexten oder Diagnoseausgaben (DS-S14-01, DS-S14-03); vom Löschweg erfasst wie die Eigenschaftswerte (LW-3); im Abnahmetest von R3-F-011 als Klartextwert des Testfalls mitgesucht (DS-S14-04); Verschlüsselung mit dem Schlüssel je Fall zusammen mit den übrigen Falldaten unter O-6 (BV-7). Weil Nr. 25 den Klartext schon festlegt, ist das keine Vorlage an den Auftraggeber; eine Pseudonymisierung wäre eine Abweichung von Nr. 25 und dann eine Fortschreibung mit Vorlage.

### 4.2 Risiken

| Nr. | Risiko | Massnahme im Entwurf | Offen |
|---|---|---|---|
| R-1 | **Besonders schützenswerte Personendaten in Eigenschaftswerten.** Daten aus Strafverfahren und polizeilichen Ermittlungen sind als solche heikel; dazu kann das Schema von FollowTheMoney Eigenschaften führen, die Angaben etwa zu Gesundheit, Religion, politischer Haltung oder Herkunft aufnehmen. Welche Eigenschaften die eingesetzte Fassung führt, ist am gebauten Stand zu erheben, nicht hier behauptet | Validierung gegen das Schema der Bibliothek, unbekannte Eigenschaften werden abgewiesen (Nr. 24); Klassifizierung je Fall und je Entität im Betrieb (5.8) | Ob einzelne Schemata oder Eigenschaften im Betrieb gesperrt, nur mit Begründung oder nur unter höherer Klassifizierung zulässig sind (Positivliste), ist [OFFEN, GRC-Rolle; Entscheid Kantonspolizei Bern im Bearbeitungsreglement] (BV-9; als Vorlage VA-S14-01 an den Auftraggeber über den Koordinator gemeldet, blockiert S1.4 nicht). Nachtrag D26: VA-S14-01 entschieden (a) mit dem Merge #56 am 2026-11-09, keine Sperre in Sprint 1 (B-03, Nachtrag C) |
| R-2 | **Verknüpfbarkeit über Kanten.** Kanten verbinden Personen mit Personen, Firmen, Adressen und Konten; der Graph ergibt ein Beziehungsprofil, das mehr aussagt als jeder Einzelwert und Unbeteiligte einschliesst | Bestand je Fall (E-S1-12 a); keine Zusammenführung über Fälle; Pseudonyme zwischen Fällen verschieden (E-S1-06 b); Kanten nur zwischen bestehenden Entitäten desselben Falls (Nr. 24) | Verknüpfung über Fälle ist nicht Gegenstand; kommt sie mit einem späteren Eintrag, braucht sie einen eigenen Eintrag in diesem Verzeichnis |
| R-3 | **Export.** Der Bestand ist die Quelle späterer Exporte (5.10); ein ausgeführter Export liegt ausserhalb jeder Löschung | Export nicht gebaut; Exportprotokoll und Manifest mit seinem Eintrag | Löschkonzept Abschnitt 9 |
| R-4 | **Klardaten in Fehlertexten und Diagnose.** Validierungsfehler und Fehler der Datenbank können den abgewiesenen Wert wiedergeben (Text der Ausnahme, verkettete Ursache, Meldung des Datenbankservers zu verletzten Prüfbedingungen und Eindeutigkeit) | 5.12; DS-S14-01 | Protokoll des Datenbankservers im Betrieb (BV-10) |
| R-5 | **Abfragetext mit Personendaten.** Siehe Bewertung oben | DS-S14-03, DS-S14-04 | — |
| R-6 | **Klartext in Datenbank, Schreibprotokoll und Sicherung.** Der Bestand ist der grösste Klartextbestand des Systems; der Fallschlüssel liegt in Sprint 1 unverschlüsselt daneben (GS-5) | Test/Schulung ohne Sicherung, nur synthetische Daten | O-6, BV-7, Löschkonzept LW-11 und LW-12 |
| R-7 | **Keine Berichtigung.** Die Anwendungsrolle hat an den Bestandstabellen kein UPDATE (Nr. 9); ein unrichtiger Datensatz lässt sich in Sprint 1 weder berichtigen noch entfernen | Kennzeichnung als Quellenaussage, Herkunft je Datensatz: die Unrichtigkeit liegt bei der Quelle und bleibt nachvollziehbar | Weg der Berichtigung oder Bestreitung im Betrieb [OFFEN, GRC-Rolle mit Product Owner] (BV-11) |

### 4.3 Stand der Umsetzung B-03

| Teil | Stand |
|---|---|
| Revision 0005 (`herkunft`, `entitaet`, `beziehung`, Rechte), kanon nach Nr. 24 und 25, Vertrag 5 | festgelegt (ADR 0007), nicht gebaut; Bau in S1.4. Nachtrag vom 2026-11-09: gebaut am 2026-11-09, zur Abnahme vorgelegt (Pull Request der Einheiten D25 und S1.4). Nachtrag D26: gebaut und abgenommen (Merge #56 am 2026-11-09) |
| Eingaben `Entitaet` und `Beziehung` der Ermittlungsspur mit Pseudonymisierung | gebaut seit S1.2 (`spur.payload`); Erzeuger kanon folgt in S1.4. Nachtrag vom 2026-11-09: Erzeuger kanon und die Herkunftsfelder der Eingaben gebaut am 2026-11-09, zur Abnahme vorgelegt. Nachtrag D26: abgenommen (Merge #56 am 2026-11-09) |
| Nachweis "keine Klardaten im Protokoll" über alle Spalten | R3-F-011 in S1.5 |
| Klassifizierung und Freigabeliste je Entität, Protokoll lesender Zugriffe | nicht Gegenstand von Sprint 1 (5.8); die Festlegung Nr. 24 führt keine Spalte der Klassifizierung (BV-12) |
| Löschweg, Grabstein | nicht gebaut, R3-F-020 |

### Nachtrag A vom 2026-11-09: Abgleich mit der nachgebesserten Festlegung S1.4

Massstab ist ADR 0007, Festlegung S1.4, in der Fassung nach der Zeile "Nachbesserung nach den Stellungnahmen (S1.4.1)" mit den Entscheiden E-S14-02 bis E-S14-13 je (a) und den Grenzen GS-33 bis GS-50. Der Bau läuft parallel (Angabe des Koordinators, Fremdbeleg); Abschnitt 4 oben bleibt als Stand vor dem Bau stehen, wo er abweicht, gilt diese Tabelle. Den gebauten Stand trägt dieses Verzeichnis nach der Abnahme nach.

| Gegenstand | Stand vor dem Bau (Abschnitt 4) | Nachgebesserte Festlegung | Wirkung auf B-03 und B-02 |
|---|---|---|---|
| Herkunftsangaben in der Ermittlungsspur | Tabelle 4.1: `herkunft.werkzeug`, `herkunft.zeitpunkt`, `herkunft.erhebende_person` und `herkunft.abfrage` "nein" in der Spur; der Eintrag trägt allein `herkunft_kennung` | E-S14-02 (a), Zeile "spur.payload, Fortschreibung": Einträge `entitaet` und `beziehung` tragen werkzeug (Kennungsform, Klartext nach Nr. 17), erhoben_am (Zeitpunkt der Erhebung, Klartext), erhebende_person (Benutzerkennung, Klartext nach E-S1-07) und die Abfrage allein als abfrage_pseudonym (Normalform) und abfrage_bindung (siehe unten); die Kennzeichnung steht in der Spalte des Eintrags | In Tabelle 4.1 gilt für diese vier Spalten die Spalte "In der Ermittlungsspur" nach dieser Zeile. Die Abfrage gelangt nie im Klartext in die Spur (DS-S14-03 erfüllt). Die Kette sichert damit die Herkunft jedes Datenpunkts; die Tabelle `herkunft` selbst ist nicht verkettet (GS-37) |
| `abfrage_bindung` (neu, DF-S14-01) | nicht vorgesehen | HMAC-SHA-256 mit dem Fallschlüssel über ein festes Etikett und die exakten UTF-8-Bytes der gespeicherten Abfrage, ohne Normalisierung, 64 Hexadezimalzeichen; macht eine Änderung allein der Schreibweise oder des Leerraums in `herkunft.abfrage` mit dem Fallschlüssel erkennbar | Kein Klartext. Datenschutzrechtlich gleichwertig zu einem Pseudonym: ohne Fallschlüssel nicht umkehrbar; wer `fall_schluessel` lesen kann, kann einen vermuteten Abfragetext bestätigen, wie beim Pseudonym (GS-5). Nach dem Vernichten des Fallschlüssels unumkehrbar (LW-2). Im Abnahmetest von R3-F-011 wird die Abfrage als Klartextwert mitgesucht (DS-S14-04) |
| Spalte `herkunft.erstellt_am` (neu, E-S14-06 a) | nicht genannt; `herkunft.zeitpunkt` als "Zeitpunkt der Erhebung" | `zeitpunkt` ist die Erhebung (Angabe des Aufrufers, nicht nach dem Schreiben), `erstellt_am` der Zeitpunkt des Schreibens; Prüfbedingung `zeitpunkt` <= `erstellt_am` | Ergänzung von Tabelle 4.1: `herkunft.erstellt_am`, Zeitpunkt in UTC, kein Personenbezug, in der Spur als Zeitpunkt des Eintrags, nach der Löschung Zeile gelöscht |
| Enden einer Kante | `beziehung.quelle_kennung` und `beziehung.ziel_kennung` (Kennungen) | Zeile "kanon.service": die Enden stehen zusätzlich nach FollowTheMoney in `beziehung.eigenschaften` (source und target mit der FollowTheMoney-Kennung des Endes, wie eingegeben) | `beziehung.eigenschaften` trägt damit FollowTheMoney-Kennungen der Enden im Klartext; sie können Namen enthalten (GS-44). In der Spur als Pseudonym wie jeder Eigenschaftswert |
| Umfang der Validierung | "Validierung gegen das Schema der Bibliothek" (R-1) | E-S14-07 (a), GS-33: geprüft werden Schema, Vorrat, Eigenschaftsname, Pflichteigenschaft und Typ entity; Eigenschaften vom Typ entity ausserhalb der Kantenenden werden abgewiesen; die übrigen Werttypen (country, date, gender, topic, email, phone und andere) werden nicht geprüft | Jede Eigenschaft nimmt faktisch Text bis 4096 Zeichen je Wert auf, höchstens 100 Werte je Eigenschaft, 128 Eigenschaften und 262 144 Zeichen je Datensatz; Zeichen der Kategorie Cf bleiben zulässig (GS-48). Folge für die Erhebung: Nachtrag B, Freitextfelder |
| Fallübergreifende Funktion | DS-S14-07: Zählwerte, keine Werte | E-S14-10 (a), GS-36: `herkunft_pruefen` liefert über alle Fälle allein Zählwerte je Form, Anzahl Knoten und Kanten und die Isolationsstufe; keine Kennungen. `datenpunkte_lesen` und `herkunft_lesen` sind fallgebunden; keine weitere fallübergreifende Lese- oder Suchfunktion | Entspricht der Zweckbindung je Fall (E-S1-12 a). Die Zählwerte enthalten keine Personendaten; Empfänger der Zählwerte ist, wer die Dienstschicht aufruft (in Sprint 1 keine Schnittstelle) |
| Fehlertexte (DS-S14-01) | Vorgabe | Zeilen "kanon.store", "kanon.service" und "core, Ergänzungen": Fehler nennen allein Feldnamen der Eingabe und Namen aus den versionierten Schemadateien, nie einen Wert, eine FollowTheMoney-Kennung oder eine vom Aufrufer gelieferte unbekannte Bezeichnung; das DETAIL von PostgreSQL gelangt in keinen Fehler; Ursachenkette leer | R-4 im Code umgesetzt nach der Festlegung, Nachweis mit den Integrationstests der Festlegung; offen bleibt das Protokoll des Datenbankservers im Betrieb (BV-10) |
| Bindung der Werte in der Spur | nicht unterschieden | GS-48: Eigenschaftswerte und FollowTheMoney-Kennung in der Normalform gebunden (NFC, casefold, Leerraum), die Abfrage exakt über `abfrage_bindung` | Kein Einfluss auf den Personenbezug; vermerkt, weil zwei Schreibweisen desselben Werts in der Spur dasselbe Pseudonym tragen (GS-7) |
| Vorrat der Schemata | nicht festgelegt | E-S14-01, Vorlage an den Auftraggeber mit Empfehlung (b): Knoten Person, LegalEntity, Organization, Company, Asset; Kanten Ownership, Directorship, Control, Employment, Associate, Family; Bau auf (b). Nachtrag D26: entschieden (b) mit dem Merge #56 am 2026-11-09, ohne Kommentar | Die Erhebung in Nachtrag B gilt für diesen Vorrat. Wird (a) entschieden, ist sie für die übrigen nicht abstrakten Schemata zu wiederholen, bevor diese im Betrieb verwendet werden. Nachtrag D26: mit (b) entfällt die Wiederholung, solange der Vorrat geschlossen bleibt (Nachtrag C) |
| Klassifizierung je Entität (BV-12) | offen, dokumentiert | E-S14-08 (a), GS-40: keine Spalte in Sprint 1, kommt mit R3-F-054 | BV-12 ist eingeordnet; bis dahin allein synthetische Daten in Test/Schulung |
| Rechte, Fremdschlüssel, Löschweg | DS-S14-06 als Vorgabe | Zeile "Revision 0005_bestand": INSERT und SELECT für die Anwendungsrolle, kein UPDATE, DELETE, TRUNCATE; Fremdschlüssel ohne ON DELETE und ON UPDATE; GS-43. Nachtrag D26: gebaut und abgenommen (Merge #56) | Übereinstimmung mit Abschnitt 4; Löschweg: Löschkonzept, Nachtrag zu Abschnitt 5 |
| Unmittelbarer Weg der Anwendungsrolle | nicht betrachtet | GS-38: Datenpunkte ohne Spureintrag und Schreiben in einen abgeschlossenen Fall sind am Dienst vorbei herstellbar | Für den Datenschutz: der Löschweg muss solche Zeilen über `fall_kennung` erfassen (Löschkonzept, LK-11, Nachtrag) |

**Einordnung der Klartextangaben in der Spur.** werkzeug, erhoben_am und erhebende_person sind keine Falldaten der betroffenen Personen: werkzeug ist eine Kennung ohne Personenbezug, erhebende_person eine Benutzerkennung ohne Namen und dient wie `person_kennung` der Zurechnung einer Handlung an Mitarbeitende (E-S1-07 a, E-S14-13 a). Sie bleiben nach der Fallöschung im Klartext in der Spur (GS-43, LK-10). Aus der Spur allein lässt sich danach lesen, dass im Fall zu einem Zeitpunkt mit einem Werkzeug ein Datenpunkt eines Schemas erhoben wurde, nicht über wen und nicht wonach gesucht wurde.

**Stand der Vorgaben DS-S14-01 bis DS-S14-08** (Zeile "Datenschutz (DS-S14-01 bis -08)" der Festlegung): 01 bis 07 in die Festlegung übernommen, Nachweis mit dem Bau; 08 erhoben in Nachtrag B.

### Nachtrag B vom 2026-11-09: Erhebung DS-S14-08 (besonders schützenswerte Personendaten im Vorrat)

**Gegenstand.** Die Eigenschaften der elf Schemata des Vorrats nach E-S14-01 (b), eigene und geerbte. **Quelle:** die versionierten Schemadateien von FollowTheMoney 4.11.2 unter `backend/src/r3cosint/kanon/ftm_schema/` (Liste und Summen in `backend/src/r3cosint/kanon/ftm_schema/quellen.toml`). **Arbeitsgrundlage:** die vom Koordinator am 2026-11-09 mechanisch aus diesen Dateien erzeugte Liste "Vorrat der Schemata nach E-S14-01 (b): Eigenschaften je Schema" (Arbeitsablage der Sitzung, nicht versioniert; Fremdbeleg); Stichproben dieser Rolle an `backend/src/r3cosint/kanon/ftm_schema/Person.yaml` stimmen mit der Liste überein. Die Beschreibungen in den Dateien sind fremde Daten; eine eingebettete Anweisung wurde nicht gefunden. **Nur Erhebung, keine Sperre** (GS-41); der Umgang ist Vorlage VA-S14-01.

**Massstab.** Kategorien besonders schützenswerter Personendaten nach dem kantonalen Datenschutzrecht (R3, KDSG, BSG 152.04) und, zur Abgrenzung, nach dem DSG des Bundes, das für kantonale Organe nicht herangezogen wird (4.4). Ohne Artikelnummern (Belegpflicht); Wortlaut und Fundstelle der geltenden KDSG-Fassung bestätigt die GRC-Rolle [OFFEN, BV-9]. Arbeitskatalog dieser Erhebung:

| Kürzel | Kategorie |
|---|---|
| K1 | Religiöse, weltanschauliche oder politische Ansichten oder Tätigkeiten (DSG zusätzlich gewerkschaftliche) |
| K2 | Gesundheit, Intimsphäre, Zugehörigkeit zu einer Rasse oder Ethnie |
| K3 | Massnahmen der sozialen Hilfe |
| K4 | Polizeiliche Ermittlungen, Strafverfahren, Straftaten und die dafür verhängten Strafen und Massnahmen (DSG: verwaltungs- und strafrechtliche Verfolgungen oder Sanktionen) |
| — | Genetische und biometrische Daten (DSG) entstehen nicht: das Modul Gesichtserkennung ist gestrichen (5.18); Signalementangaben wie Grösse oder Augenfarbe sind keine technisch verarbeiteten biometrischen Daten |

**K4 gilt durch den Kontext für den ganzen Bestand.** Jeder Datensatz gehört einem Fall (B-01) und damit einer polizeilichen Ermittlung oder einem Strafverfahren; jede Angabe zu einer Person im Bestand ist deshalb besonders schützenswert, unabhängig von der Eigenschaft. Die Einordnung je Eigenschaft fragt darüber hinaus, ob der Inhalt selbst eine Kategorie trägt.

**Stufen.** "typisch": die Eigenschaft ist nach ihrer Bestimmung in der Schemadatei zur Aufnahme einer Kategorie da. "möglich": sie nimmt solche Angaben nach Bestimmung oder als Freitext auf, ohne dafür bestimmt zu sein. "nein": nach Bestimmung keine Kategorie (K4 aus dem Kontext bleibt). "abgewiesen": in Sprint 1 nicht schreibbar, weil vom Typ entity ausserhalb der Kantenenden (Zeile "Umfang der Validierung").

**Knoten: eigene Eigenschaften von Person**

| Eigenschaft (Typ) | Einordnung | Begründung |
|---|---|---|
| ethnicity (string) | typisch | K2 Ethnie; Bestimmung "Ethnicity" |
| religion (string) | typisch | K1 religiöse Ansicht oder Zugehörigkeit |
| political (string) | typisch | K1; Bestimmung "Political association" |
| appearance (string) | möglich | K2: eine Beschreibung des Aussehens kann Gesundheit (Behinderung, Narben) oder Ethnie wiedergeben; Freitext |
| biography (text) | möglich | Freitext, jede Kategorie |
| gender (gender) | möglich | K2 Intimsphäre, wenn der Wert eine Geschlechtsidentität wiedergibt; Wertevorrat wird nicht geprüft (GS-33) |
| position (string) | möglich | K1 bei einem politischen Amt oder einem Amt in einer Religionsgemeinschaft oder Gewerkschaft |
| profession, education, title (string) | nein | Beruf, Ausbildung, Titel; mittelbar K1 möglich (etwa ein geistliches Amt als Beruf) |
| eyeColor, hairColor (string); height, weight (number) | nein | Signalement, keine biometrischen Daten im Sinn von 5.18; weight mittelbar K2 möglich |
| birthCountry, citizenship, nationality (country); birthPlace (string); spokenLanguage (language) | nein | Staatsangehörigkeit, Geburtsort und Sprache sind keine Ethnie; zusammen mit ethnicity oder appearance verstärken sie den Rückschluss |
| birthDate, deathDate (date) | nein | Identifikation; ob Daten verstorbener Personen erfasst sind, klärt die GRC-Rolle mit BV-9 |
| firstName, lastName, middleName, nameSuffix, secondName, fatherName, motherName (string) | nein | Identifikation; fatherName und motherName betreffen Dritte |
| passportNumber, socialSecurityNumber (identifier) | nein | keine Kategorie, aber hohe Identifikationskraft; ob die Bearbeitung der Sozialversicherungsnummer eine eigene Grundlage braucht, ist [OFFEN, GRC-Rolle] (BV-13) |

**Knoten: von Thing geerbt (Person, LegalEntity, Organization, Company, Asset)**

| Eigenschaft (Typ) | Einordnung | Begründung |
|---|---|---|
| program (string), programId (identifier) | typisch | K4: Bestimmung "Regulatory program or sanctions list on which an entity is listed"; die Listung auf einer Sanktionsliste ist eine Massnahme oder Sanktion; Einordnung durch die GRC-Rolle |
| topics (topic) | möglich | K1, K4: Bestimmung "Controlled tags ... risk category"; die Kategorien können Straftaten, Sanktionen oder politische Exponiertheit bezeichnen. Der Wertevorrat steht nicht in den Schemadateien und wird nicht geprüft (GS-33) |
| description, notes, summary, indexText (text) | möglich | Freitext, jede Kategorie |
| keywords (string) | möglich | Freitext ohne Wertevorrat |
| name, alias, previousName, weakAlias (name) | nein | Identifikation; ein Übername kann Merkmale wiedergeben (dann möglich K2) |
| address (address), country (country) | nein | Aufenthalt; die Adresse einer Einrichtung (Klinik, Gotteshaus) kann mittelbar K1 oder K2 anzeigen |
| createdAt, modifiedAt, retrievedAt (date) | nein | Zeitangaben der Quelle |
| alephUrl, sourceUrl, publisherUrl, wikipediaUrl (url); publisher (string); wikidataId (identifier) | nein | Quellenangaben; die Quelle selbst (Seite einer Partei, Kirche) kann mittelbar K1 anzeigen |
| addressEntity, proof, riskSource (entity) | abgewiesen | Typ entity ausserhalb der Kantenenden |

**Knoten: von LegalEntity geerbt (Person, LegalEntity, Organization, Company) und eigene von Organization, Company und Value**

| Eigenschaft (Typ) | Einordnung | Begründung |
|---|---|---|
| classification (string) | möglich | Freitext "as provided by the data source"; bei einer Organisation kann die Einordnung (Partei, Religionsgemeinschaft, Gewerkschaft) mittelbar K1 für ihre Mitglieder und Organe anzeigen |
| sector, legalForm, status, taxStatus (string) | nein | Angaben zur Tätigkeit und Form; mittelbar K1 wie classification |
| email (email), phone (phone), website (url) | nein | Erreichbarkeit |
| idNumber, taxNumber (identifier) | nein | keine Kategorie, hohe Identifikationskraft |
| npiCode (identifier) | nein | kennzeichnet eine Gesundheitsfachperson als Leistungserbringerin, keine Gesundheitsdaten |
| icijId (string) | nein | Kennung einer journalistischen Datensammlung; Indiz, keine Kategorie |
| abbreviation, brightQueryId, brightQueryOrgId, bvdId, dissolutionDate, dunsCode, incorporationDate, innCode, jurisdiction, leiCode, licenseNumber, mainCountry, ogrnCode, okpoCode, okvedCode, opencorporatesUrl, registrationNumber, sayariId, swiftBic, uniqueEntityId, uscCode, vatCode | nein | Register-, Steuer- und Datenbankkennungen und Daten juristischer Personen |
| parent (entity) | abgewiesen | Typ entity ausserhalb der Kantenenden |
| cageCode, giiNumber, imoNumber, permId (Organization) | nein | Kennungen von Organisationen |
| bikCode, caemCode, capital, cikCode, coatoCode, fnsCode, fssCode, ipoCode, irsCode, isinCode, jibCode, kppCode, mbsCode, okopfCode, oksmCode, pfrNumber, ricCode, ticker, voenCode (Company) | nein | Kennungen und Klassifikatoren von Unternehmen; fssCode und pfrNumber betreffen die Registrierung des Unternehmens bei Sozialversicherungsträgern, nicht Massnahmen der sozialen Hilfe (K3) |
| amount, amountEur, amountUsd (number), currency (string) (Value, geerbt von Asset und Company) | nein | Vermögenswerte; finanzielle Verhältnisse stehen nicht im Katalog |

**Kanten (Ownership, Directorship, Control, Employment, Associate, Family)**

| Eigenschaft (Typ) | Schemata | Einordnung | Begründung |
|---|---|---|---|
| description, summary, indexText (text) | alle sechs (Interval) | möglich | Freitext, jede Kategorie |
| relationship (string) | Associate, Family | möglich | K2 Intimsphäre: die Art der Beziehung kann eine Partnerschaft oder Lebensform wiedergeben; Family verbindet regelmässig Unbeteiligte (R-2) |
| role, status (string) | Ownership, Directorship, Control, Employment (Interest) | möglich | K1 bei einer Rolle in einer Partei, Religionsgemeinschaft oder Gewerkschaft |
| owner, asset, director, organization, controller, controlled, employee, employer, person, associate, relative (entity, Kantenenden) | je Kante | möglich über das Ziel | Die Kante selbst trägt keine Kategorie; ist das Ziel eine Partei, Religionsgemeinschaft, Gewerkschaft oder Gesundheitseinrichtung, zeigt sie eine Zugehörigkeit oder Tätigkeit nach K1 oder K2 an (R-2) |
| namesMentioned (name) | alle sechs | nein | Namen, oft Dritter |
| secretary (string) | Directorship | nein | kann den Namen einer dritten Person tragen |
| legalBasis, ownershipType, percentage, sharesCount, sharesCurrency, sharesType, sharesValue (string) | Ownership (legalBasis auch Control) | nein | Beteiligungsangaben |
| controlType (string) | Control | nein | Art der Kontrolle |
| date, startDate, endDate, modifiedAt, retrievedAt (date); alephUrl, sourceUrl, publisherUrl (url); publisher, recordId (string) | alle sechs | nein | Zeit- und Quellenangaben |
| proof (entity) | alle sechs | abgewiesen | Typ entity ausserhalb der Kantenenden |

**Freitextfelder (gesondert).**

| Gruppe | Eigenschaften | Bewertung |
|---|---|---|
| Typ text | biography; description, notes, summary, indexText (Knoten); description, summary, indexText (Kanten) | Freitext nach Bestimmung; keine Kategorie lässt sich ausschliessen |
| string ohne Wertevorrat | appearance, keywords, classification, relationship, role, status, position, profession, education, title, secretary, legalBasis, controlType, ownershipType, birthPlace, sowie ethnicity, religion, political | Freitext nach Bestimmung; die drei typischen Eigenschaften sind selbst Freitext |
| faktisch jede Eigenschaft | alle Eigenschaften ausser den Kantenenden | Die Werttypen werden nicht geprüft (GS-33): auch country, gender, topic, date, phone, email, url und identifier nehmen beliebigen Text bis 4096 Zeichen je Wert auf |
| ausserhalb des Schemas | `herkunft.abfrage`; FollowTheMoney-Kennung (GS-44) | Abfrage: Bewertung in Abschnitt 4; Kennung: kann Namen tragen |

**Ergebnis in Kurzform.** K4 gilt für den ganzen Bestand aus dem Kontext. Typisch: ethnicity, religion, political (Person) und program, programId (alle Knoten). Möglich: appearance, biography, gender, position, topics, keywords, classification, die Freitextfelder vom Typ text, relationship (Associate, Family), role und status (Interest) und die Kantenenden über ihr Ziel. Abgewiesen in Sprint 1: addressEntity, proof, riskSource, parent. Alle übrigen: nein. Weil jede Eigenschaft faktisch Freitext aufnimmt, beseitigt eine Sperre einzelner Eigenschaften das Risiko nicht; dieselbe Angabe kann in notes oder description stehen. Wirksam sind ergänzend die Zweckbindung je Fall, Klassifizierung und Freigabeliste je Entität (R3-F-054, GS-40) und Regeln im Bearbeitungsreglement.

**Nicht erhoben.** Schemata ausserhalb des Vorrats. Nach den Dateinamen im Verzeichnis gehören dazu Schemata, deren Bestimmung Kategorien nahelegt (etwa Sanction, CourtCase, CourtCaseParty, Membership, Occupancy, Passport, Identification, Note, Message); sie sind nicht gelesen und nicht eingeordnet. Bei Entscheid E-S14-01 (a) ist die Erhebung für sie nachzuholen.

### Nachtrag C vom 2026-11-09 (Einheit D26): Abnahme von S1.4, Entscheide E-S14-01 und VA-S14-01

Quelle: Merge des Pull Requests #56 am 2026-11-09 (Merge-Commit `04e759130e63111556a853487db03b035430e522`; erster Formweg, ohne Kommentar des Auftraggebers, ohne Review), Bedeutung nach dem Text des Pull Requests (Angabe des Koordinators, Fremdbeleg; Verlauf in `docs/uebergaben/2026-11-05_d21-etappe-1-sprint-1.md`, Abschnitt "Einheit D26").

| Gegenstand | Entscheid | Wirkung auf B-03 |
|---|---|---|
| Abnahme S1.4 (R3-F-003, R3-F-005) | abgenommen nach dem Abnahmekriterium der Festlegung S1.4 | B-03 ist gebaut und abgenommen; Revision 0005_bestand, Modul kanon und Vertrag 5 gehören zum abgenommenen Stand. Löschweg und Grabstein bleiben ungebaut (R3-F-020) |
| E-S14-01 | (b) nach der Empfehlung: geschlossener Vorrat in Sprint 1, Knoten Person, LegalEntity, Organization, Company, Asset; Kanten Ownership, Directorship, Control, Employment, Associate, Family; Erweiterung je mit Backlog-Eintrag und Fortschreibung der Konstanten | Die Erhebung DS-S14-08 (Nachtrag B) deckt den ganzen zulässigen Vorrat. Die Nachholung für Schemata ausserhalb des Vorrats ("Nicht erhoben") entfällt, solange der Vorrat geschlossen bleibt; jede Erweiterung braucht vor ihrer Verwendung die Erhebung der neuen Schemata durch den Datenschutzexperten |
| VA-S14-01 | (a) nach der Empfehlung: keine Sperre besonders schützenswerter Eigenschaften in Sprint 1 | Die GRC-Rolle ordnet die Erhebung ein und bestätigt den Arbeitskatalog K1 bis K4 an der geltenden Fassung des KDSG (BV-9). Die Kantonspolizei Bern entscheidet im Bearbeitungsreglement über Positivliste, Begründungspflicht oder höhere Klassifizierung. Die Umsetzung kommt danach als Backlog-Eintrag über den Product Owner (Vormerkung an R3-F-054 durch den Product Owner in D26), spätestens vor der Produktion und zusammen mit Klassifizierung und Freigabeliste je Entität (R3-F-054, GS-40). Bis dahin allein synthetische Daten in Test/Schulung (5.6, 5.16) |

Keine neue Erhebung, keine inhaltliche Änderung an Nachtrag B.

## 5. Noch nicht erfasste Bearbeitungen

Erfasst wird je Bearbeitung mit der Einheit, die sie baut; bis dahin besteht sie nicht.

| Bearbeitung | Entsteht mit | Bemerkung |
|---|---|---|
| Protokoll lesender Zugriffe | späterer Eintrag (5.8, Bereitschaft Punkt 2) | nicht im Sprint Backlog |
| Benutzerkonten und Anmeldung | Etappe 3 (5.7) | bis dahin GS-1 |
| Aufgaben an Fallverantwortliche, Grabstein-Einträge | R3-F-020 | Löschkonzept |
| Export und Exportprotokoll | späterer Eintrag (5.10) | bereits ausgeführte Exporte liegen ausserhalb jeder Löschung (4.4, "Ehrliche Grenze") |
| Sprachmodell, Quellenabfragen, Alias-Profile, Anhänge und Asservate, Suchindex, Graph | spätere Etappen | je mit eigenem Eintrag |

## 6. Offene Punkte

| Nr. | Punkt | Zuständig |
|---|---|---|
| BV-1 | Einschlägige Bestimmungen in R1 und R2 für das Führen der Fallverwaltung; Artikelnummern der geltenden KDSG-Fassung nach der Totalrevision vom 3. Dezember 2025 | GRC-Rolle, Gegenprüfung Legal Reviewer |
| BV-2 | Anwendbarkeit der DSGVO (nicht unterstellt) und Geltung von R4 je Bearbeitung | GRC-Rolle |
| BV-3 | Bezeichnung des verantwortlichen Organs und der Ansprechperson für Datenschutz im Bearbeitungsreglement | Auftraggeber (Kantonspolizei Bern) |
| BV-4 | `fall.rechtsgrundlage` ist Freitext ohne Formprüfung, `fall.ermittelnde_person` ohne die Formprüfung der Benutzerkennung, die `person_kennung` in den Spuren trägt; beide könnten zweckwidrig Namen aufnehmen. **Erledigt** mit ADR 0007, Festlegung S1.3 (Zeile "Stellungnahmen vor dem Bau": BV-4 eingearbeitet), gebaut am 2026-11-09: `ermittelnde_person` in der Form der Benutzerkennung, geprüft in `fall.eingabe`, Eroeffnung; Höchstlänge der Rechtsgrundlage 2000 Zeichen in der Angleichung | Software Architect (Festlegung S1.3) |
| BV-5 | Aufbewahrung der Spuren nach der Fallöschung und ihr Verhältnis zur Archivierung (R5) | GRC-Rolle mit Datenschutzexperte |
| BV-6 | Abgrenzung Nichttreffer (Bundesgericht, August 2026) gegen Negativbefunde (5.3), schriftlich | GRC-Rolle (4.4, Punkt 7) |
| BV-7 | Schlüsselverwaltung getrennt von den Sicherungen (O-6, GS-5); mit B-03 auch Verschlüsselung der Bestandswerte und des Abfragetexts mit dem Schlüssel je Fall | Software Architect mit SecDevOps Engineer und Datenschutzexperte, vor R3-F-020 |
| BV-8 | Einschlägige Bestimmungen in R1 und R2 für das Erheben, Überführen und Verknüpfen von Personendaten im kanonischen Bestand (B-03); Konformitätsanalyse für die Funktion des Bestands | GRC-Rolle, Gegenprüfung Legal Reviewer |
| BV-9 | Umgang mit besonders schützenswerten Eigenschaften im Schema von FollowTheMoney: Erhebung der Eigenschaften der eingesetzten Fassung am gebauten Stand; Positivliste, Begründungspflicht oder Klassifizierung (B-03, R-1) | Erhebung: Backend Engineer mit Datenschutzexperte in S1.4; Einordnung: GRC-Rolle; Entscheid: Kantonspolizei Bern (Bearbeitungsreglement) |
| BV-10 | Protokoll des Datenbankservers im Betrieb: Meldungen zu verletzten Prüfbedingungen und zur Eindeutigkeit können Werte der abgewiesenen Zeile enthalten; Einstellung und Aufbewahrung dieses Protokolls (5.12) | DevOps Engineer mit SecDevOps Engineer und Datenschutzexperte, vor der Produktion |
| BV-11 | Berichtigung oder Bestreitung unrichtiger Bestandsdaten ohne UPDATE-Recht der Anwendung (B-03, R-7) | GRC-Rolle mit Product Owner |
| BV-12 | Klassifizierungsstufe und Freigabeliste je Entität (Glossar, Entität: "Trägt immer einen Herkunftsnachweis und eine Klassifizierungsstufe."; 5.8) fehlen im Schema nach Nr. 24; dokumentiert, nicht bewertet | Product Owner mit Software Architect (späterer Eintrag zu 5.8) |

**Nachtrag vom 2026-11-09 (nachgebesserte Festlegung S1.4).**

| Nr. | Punkt | Zuständig |
|---|---|---|
| BV-9 | Teil Erhebung erledigt (B-03, Nachtrag B, für den Vorrat nach E-S14-01 b); offen bleiben die Bestätigung des Arbeitskatalogs K1 bis K4 an der geltenden KDSG-Fassung, die Einordnung und der Umgang im Betrieb (Vorlage VA-S14-01) | GRC-Rolle; Entscheid Kantonspolizei Bern (Bearbeitungsreglement) |
| BV-12 | Eingeordnet: E-S14-08 (a), Grenze GS-40, Spalte mit R3-F-054 | Product Owner mit Software Architect |
| BV-13 | Ob die Bearbeitung der Sozialversicherungsnummer (Person, socialSecurityNumber) im Bestand eine eigene gesetzliche Grundlage braucht, und ob Angaben zu verstorbenen Personen (deathDate) dem kantonalen Datenschutzrecht unterstehen | GRC-Rolle, Gegenprüfung Legal Reviewer |

**Nachtrag D26 vom 2026-11-09 (Merge des Pull Requests #56).**

| Nr. | Punkt | Zuständig |
|---|---|---|
| BV-9 | Teil Erhebung erledigt für den Vorrat nach E-S14-01 (b), entschieden mit dem Merge #56; VA-S14-01 entschieden (a), keine Sperre in Sprint 1 (B-03, Nachtrag C). Offen bleiben die Bestätigung des Arbeitskatalogs K1 bis K4 an der geltenden KDSG-Fassung, die Einordnung der Erhebung und der Entscheid der Kantonspolizei Bern im Bearbeitungsreglement (Positivliste, Begründungspflicht oder höhere Klassifizierung); Umsetzung danach als Backlog-Eintrag, spätestens vor der Produktion, mit R3-F-054 und GS-40 | Einordnung und K1 bis K4: GRC-Rolle; Entscheid: Kantonspolizei Bern (Bearbeitungsreglement); Backlog-Eintrag: Product Owner |
