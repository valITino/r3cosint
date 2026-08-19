# Glossar

| | |
|---|---|
| **Arbeitsprodukt nach** | Projektauftrag 6.3 |
| **Verantwortlich** | Requirements Engineer; ein benannter Verantwortlicher ist noch zu bestimmen |
| **Lebensdauer** | langlebig |
| **Stand** | 2026-08-19, Erstfassung |

**Die Verwendung dieses Glossars ist für alle Arbeitsprodukte und für die
Oberflächentexte verpflichtend** (6.3). Synonyme sind gekennzeichnet, Homonyme
werden vermieden.

Begriffe tragen in diesem Projekt teils rechtliche Bedeutung. Der Unterschied
zwischen verdeckter Fahndung und verdeckter Ermittlung ist kein sprachlicher,
sondern entscheidet über die Zulässigkeit (6.3). Solche Einträge sind mit
**[rechtlich]** gekennzeichnet und dürfen nicht umformuliert werden, ohne dass
die GRC-Rolle es prüft.

---

## A

**Alias-Profil** — Dienstlich zur Verfügung gestelltes Konto auf einer
Social-Media-Plattform, das der Genauigkeit der Suche dient. Kein Mittel zur
Kontaktaufnahme. Der zugehörige MCP-Server ist ausschliesslich lesend gebaut
(5.11). *Nicht verwenden als Synonym für:* Legende.

**Anforderungskennung** — Dauerhafte, eindeutige Kennung einer Anforderung. Sie
ändert sich nie, auch wenn der Text sich ändert (6.6). Steht im Commit-Betreff
und im Testnamen.

**Arbeitsspur** — Spur 2 der Protokollierung. Beantwortet: *wie sind wir darauf
gekommen*. Enthält jede Abfrage mit Werkzeug und Parametern, jedes Ergebnis,
jede Schlussfolgerung, jede Freigabe und zwingend die Negativbefunde. Adressat:
Verteidigung, Gericht, Aufsicht (5.3). *Nicht:* ein Systemlog.

**Asservat** — Sichergestelltes Beweisstück, im System mit Prüfsumme abgelegt.
Daraus übernommene Werte tragen die Herkunftsangabe auf das Asservat.

**Aufbewahrungsklasse** — Konfigurierbare Fallkategorie, an der die Prüffrist
hängt. Sie löst **nie** eine Löschung aus, sondern eine Aufgabe an den
Fallverantwortlichen (4.4).

## B

**Bekanntgabe** — Jede Abfrage an eine externe Quelle. Man teilt einem Dritten
mit, dass man sich für eine bestimmte Domain, IP-Adresse oder Person
interessiert (5.17). Protokollpflichtig. *Synonym im Konzeptdokument:* "was das
Haus verlässt".

**Bereitschaftsliste** — Die sieben Bedingungen aus 5.16, die vor dem ersten
Produktivbetrieb erfüllt sein müssen. Punkt 7 kann nur der Auftraggeber abhaken.

**Beweismittelformat** — Exportformat, das für die Beweisführung geeignet ist.
CSV und XLSX sind ausdrücklich **kein** Beweismittelformat und werden im Export
entsprechend gekennzeichnet (5.10).

## E

**Entität** — Ein Objekt im kanonischen Datenbestand: Person, Firma, IP-Adresse,
Domain, Wallet, Vermögenswert und so weiter. Trägt immer einen Herkunftsnachweis
und eine Klassifizierungsstufe.

**Ermittlung** — Die Gesamtheit der Tätigkeit in einem Fall. *Abzugrenzen von:*
Recherche (siehe dort).

**Ermittlungsspur** — Spur 1 der Protokollierung. Beantwortet: *was wissen wir
jetzt*. Enthält Entitäten, Beziehungsgraph und Berichtsentwurf mit
Herkunftsangabe je Aussage. Adressat: Akte, Rapport, Anklage (5.3).

**Export** — Erzeugung eines Artefakts ausserhalb des Systems. Selbst
protokollpflichtig, mit Manifest samt SHA-256 je Artefakt. Bereits ausgeführte
Exporte liegen ausserhalb des Systems und werden von keiner Löschung erreicht
(4.4, 5.10).

## F

**Fall** — Ein Verfahren oder Vorgang mit Aktenzeichen, ermittelnder Person,
Rechtsgrundlage und Aufbewahrungsklasse. **Ohne eröffneten Fall ist kein
einziges Werkzeug aufrufbar** (5.4, Fallbindung).

**Fallbindung** — Verfahrensgarantie: jede Abfrage ist zwingend einem Verfahren
und einer Person zugeordnet (5.4).

**Freigabe** — Die bewusste Bestätigung eines Menschen vor der Ausführung von
Abfragen nach aussen. Steht mit Zeitpunkt und Person im Protokoll. Vorschlag und
Ausführung dürfen technisch nicht selbstständig verkettbar sein (5.2).
*Abzugrenzen von:* Freigabe-Gate (siehe dort).

**Freigabe-Gate** — Ein Prüfpunkt im Projektablauf, an dem der Auftraggeber
schriftlich zustimmt, bevor der nächste Lieferschritt beginnt (Abschnitt 2, 5.6).
*Homonym-Warnung:* nicht dasselbe wie die Freigabe einer Abfrage.

## G

**Grabstein-Eintrag** — Was nach einer Löschung bleibt: Fallnummer,
Löschzeitpunkt, freigebende Person, Rechtsgrundlage, Prüfsumme. Kein Inhalt.
Hält die Protokollkette lückenlos (4.4).

## H

**Herkunftsnachweis** — Die Angabe, aus welcher Quelle ein Datenpunkt stammt,
wann er erhoben wurde und von wem. Nach W3C PROV geführt. Kein Knoten und keine
Kante ohne Herkunftsnachweis (5.4). *Synonym:* Provenienz.

## K

**Kanonischer Datenbestand** — Ebene 2 der Architektur und der eigentliche Kern
des Systems. Alle Quellergebnisse werden in ein einheitliches Modell überführt:
FollowTheMoney, STIX 2.1, W3C PROV (5.1).

**Klassifizierung** — Das Schutzstufenschema der Kantonspolizei Bern: nicht
klassifiziert, 1a (Eingeschränkt), 1b (Ermittlungen), 2 (Geheim), sowie
"verborgen" ohne Klassifizierungswirkung (5.8). Wirkt zusätzlich zur
Organisationszugehörigkeit, nicht statt ihrer.
*Homonym-Warnung:* Die Stufen 1a und 1b der Klassifizierung sind **nicht**
dasselbe wie die Prioritäten 1a und 1b der Rechtsregime in 4.4. In
Arbeitsprodukten immer "Klassifizierung 1b" beziehungsweise "Rechtsregime-Prio
1b" ausschreiben.

**Klassifizierungsberechtigung** — Die stufenbezogene Berechtigung einer Person.
Wirkt neben der fallbezogenen Freigabeliste je Entität; beide Wege sind
umzusetzen (5.8).

**Kontingent** — Das Abfragebudget einer externen Quelle. Verbrauch je Fall und
je Tag begrenzt, damit kein Kontingent mitten im Verfahren unbemerkt aufgebraucht
ist (5.4).

## L

**Löschsperre** — Manuell gesetzte Markierung, die eine Löschung unabhängig von
jeder Frist verhindert. Für laufende Rechtsmittel, Aufbewahrungsanordnungen und
Wiederaufnahme (4.4).

## M

**MCP-Server** — Ebene 1 der Architektur und der **einzige** Zugang zu den
Quellen. Zugangsschlüssel liegen ausschliesslich serverseitig; weder das
Sprachmodell noch die Ermittelnden sehen sie (5.1).

## N

**Negativbefund** — Eine ausgeführte Abfrage ohne Treffer. Erscheint zwingend im
Protokoll und im Export. Dass eine Adresse in einer Datenbank *nicht* verzeichnet
war, kann entlastend sein (5.3). *Nicht verwechseln mit:* Nichttreffer im Sinne
der Massendatenerhebung nach dem Bundesgerichtsentscheid von August 2026 — die
Abgrenzung hält die GRC-Rolle schriftlich fest (4.4).

## P

**Positivliste** — Die Liste ausdrücklich freigegebener Gegenstellen. Nur sie
sind erreichbar; jeder Versuch darüber hinaus wird abgewiesen und protokolliert
(5.4). *Synonym:* Allowlist. In Oberflächentexten "Positivliste" verwenden.

**Produktionsumgebung** — Die Umgebung mit echten Fällen. Sprachmodell
ausschliesslich lokal. Claude Code hat technisch keinen Zugang; die Trennung
läuft über getrennte Zugangsdaten, nicht über eine Regel (5.16).

**Prototyp** — Der klickbare Wegwerf-Prototyp mit synthetischen Daten. Sein Code
wird nach der Freigabe nicht weiterverwendet (5.6). *Nicht verwenden als Synonym
für:* erste Fassung des Produkts.

**Prüfaufwand** — Der geschätzte Aufwand des Teams, ein Inkrement zu prüfen und
freizugeben — **nicht** der Umsetzungsaufwand. Der Sprintumfang bemisst sich
daran (6.8).

## Q

**Quellenaussage** — Eine Zeile, die ein Dienst geliefert hat. Gegenstück:
Schlussfolgerung des Modells. Beide werden unterschiedlich gekennzeichnet, im
Protokoll wie in der Darstellung. Das ist die wichtigste einzelne Absicherung
gegen den Vorwurf, eine Maschine habe Tatsachen erfunden (5.3).

## R

**Recherche** — Das Abfragen offen zugänglicher Quellen. Reine Recherche, keine
verdeckte Ermittlung (5.11). *Abzugrenzen von:* Ermittlung als Oberbegriff.

**Rückkanal** — Jede ausgehende Verbindung zu Zwecken des Systems selbst:
Nutzungsstatistik, Fehlerbericht, Aktualisierungsabfrage. **Es gibt keinen.**
Wird im Bauprozess geprüft (5.4).

## S

**Schlussfolgerung des Modells** — Eine Aussage, die aus keiner Quelle stammt.
Gesondert gekennzeichnet und in jeder Darstellung optisch abgesetzt. Darf im
Bericht nicht als Tatsache erscheinen (5.3, 5.4).

**Schutzstufe** — Umgangssprachlich für Klassifizierung. In Arbeitsprodukten und
Oberflächentexten ist **Klassifizierung** zu verwenden; "Schutzstufe" gilt als
Synonym und wird nicht neu eingeführt.

## T

**Test/Schulung** — Die Umgebung mit ausschliesslich synthetischen Beispielakten.
Trägt in der Oberfläche ein dauerhaftes Band mit deutlich abweichender
Farbgebung. Entwicklung findet ausschliesslich hier statt (5.16).

## U

**Übergabedatei** — Der am Ende jeder Arbeitseinheit geschriebene Stand: was
fertig ist, was offen ist, welche Entscheidungen getroffen wurden (3.3).

## V

**[rechtlich] Verdeckte Ermittlung** — Art. 285a ff. StPO. Angehörige der Polizei
knüpfen unter einer **urkundlich abgesicherten Legende** Kontakte. Verlangt die
Genehmigung des Zwangsmassnahmengerichts. **R3cOSINT leistet das nicht und darf
es nicht leisten.**

**[rechtlich] Verdeckte Fahndung** — Art. 298a ff. StPO. Angehörige der Polizei
treten aktiv in Kontakt und verschweigen ihre Funktion, **ohne** urkundlich
abgesicherte Legende. Anordnung durch Staatsanwaltschaft oder Polizei. **Auch
diese Schwelle überschreitet R3cOSINT nicht** — der Social-Media-Zugang hat
technisch keine Fähigkeit zur Kontaktaufnahme (5.11).

**[rechtlich] Blosses Betrachten öffentlich zugänglicher Inhalte** — Erreicht
keine der beiden Schwellen. Das ist der Bereich, in dem R3cOSINT arbeitet: so
weit, wie es keinen Zwangsmassnahmenentscheid braucht (5.11). Erreicht eine
Ermittlung den Punkt, an dem Interaktion nötig wäre, endet die Zuständigkeit von
R3cOSINT und das System zeigt einen Hinweis, statt eine Möglichkeit anzubieten.

**Verfahrensgarantie** — Eine der acht Bauvorschriften aus 5.4. Im Betrieb nicht
abschaltbar. *Nicht:* eine Einstellung.

**verborgen** — Markierung für den Austausch zwischen Rialto und ELS. **Keine
Klassifizierungsfunktion**, wirkt nicht auf Zugriffsrechte (5.8). Wird leicht für
eine Schutzstufe gehalten und ist keine.

---

## Zu ergänzen

| Nr. | Was fehlt | Wer liefert |
|---|---|---|
| 1 | Benannter Verantwortlicher für das Glossar (6.3 verlangt einen) | Auftraggeber |
| 2 | Fachbegriffe aus dem Dezernatsalltag, die hier noch fehlen | Ermittelnde (S-03) |
| 3 | Bestätigung, dass "Schutzstufe" als Synonym und nicht als eigener Begriff geführt wird | Auftraggeber |
