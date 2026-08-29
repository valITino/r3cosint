# Entscheidungsvorlage — Werkzeugvorschlag des Auftraggebers vom 2026-08-29

| | |
|---|---|
| **Arbeitsprodukt nach** | Projektauftrag 3.1 (keine Abweichung nach eigenem Ermessen), 5.17 (Quellenverzeichnis) |
| **Anlass** | Vorschlag des Auftraggebers nach CAS-Blockwoche 3 "Cyber Investigations" |
| **Umfang** | 14 Werkzeuge, vier Vorschlagsstränge |
| **Stand** | 2026-08-29 |
| **Entscheid** | offen — liegt beim Auftraggeber |

## Was geprüft wurde und wie

Je Werkzeuggruppe eine belegte Faktenerhebung, je Werkzeug eine Prüfung gegen
die Bauvorschriften, je Vorschlagsstrang eine eigene Untersuchung, dazu zwei
Gegenproben: eine, die den Auftraggeber vertritt und prüft, ob die Beurteilung
zu streng ist, und eine aus Sicht von Datenschutz und Beweissicherung, die
prüft, ob sie zu nachsichtig ist. Die Prüfenden haben unter anderem Anhang A
des Konzeptdokuments ausgelesen, den Quelltext von SpiderFoot gelesen und die
Nutzungsbedingungen der Dienste im Wortlaut abgerufen.

**Zwei von achtzehn Prüfschritten fehlen** — die Vollständigkeitsprüfung und
die maschinelle Schlusssynthese sind am Sitzungslimit gescheitert. Die Synthese
hat der Koordinator selbst erstellt. Das heisst: Es ist nicht unabhängig
geprüft, ob jedes eingereichte Werkzeug tatsächlich beurteilt wurde. Nach
eigener Zählung ist keines ausgelassen, aber diese Zählung ist keine
unabhängige Prüfung.

## Drei Korrekturen an eigenen früheren Aussagen

Sie stehen hier vorn, weil sie die Grundlage betreffen.

**1. Der Kali-MCP-Server existiert offiziell. Die erste Prüfung hat das
falsch verneint.** Ein Prüfschritt kam zum Ergebnis, es gebe "keinen
MCP-Server von OffSec oder vom Kali-Projekt", das Paket sei nur Paketierung
fremden Codes. Die Nachprüfung an der Primärquelle
(`https://www.kali.org/tools/mcp-kali-server/`) zeigt: Das Paket
`mcp-kali-server` ist ein reguläres Kali-Paket, geführt auf der offiziellen
Werkzeugseite, im GitLab von Kali, installierbar mit `apt install`. Upstream
ist `Wh0am123/MCP-Kali-Server`. Dass der Quellcode von aussen stammt, macht das
Paket nicht inoffiziell — Kali paketiert hunderte fremde Werkzeuge; das ist,
was eine Distribution tut. **Die Annahme des Auftraggebers war im Kern
richtig.** Die Ablehnung stützt sich deshalb nicht darauf.

**2. Der Koordinator hat Abschnitt 5.11 zu weit gelesen.** In der ersten
Antwort hiess es, ein Portscan gegen die Infrastruktur einer Zielperson liege
wegen 5.11 "nicht mehr in OSINT". Die Gegenprobe hat das widerlegt, und sie hat
recht: 5.11 regelt die Social-Media-Recherche über Alias-Profile, und die dort
als fehlende Funktion verlangten Fähigkeiten sind abschliessend aufgezählt —
Kontaktanfragen, Folgen, Abonnieren, Beitreten, Nachrichten, Kommentare,
Reaktionen, Beiträge, Profile anlegen oder verändern. Das sind samt und sonders
Interaktionen mit **Menschen**. Kein Wort davon handelt von Paketen an ein
Zielsystem. Schwerer wiegt: **5.2 nennt die Scan-Abfrage ausdrücklich als
Beispiel dafür, weshalb es die Freigabesperre gibt** — also als eine Abfrage,
die das System ausführt und ein Mensch auslöst, nicht als eine, die es nicht
können darf. Und mit urlscan.io lässt der Auftrag eine Quelle zu, die die
Zielseite tatsächlich lädt.

**3. Reproduzierbarkeit nach R3-Q-002 wurde als Ausschlussgrund missbraucht.**
Das Abnahmekriterium prüft "zwei Läufe desselben Auftrags gegen denselben
**aufgezeichneten** Quellstand"; ADR 0002 nennt den Mechanismus: Rohantworten
mit Prüfsumme im Fallbestand. Reproduzierbarkeit ist gegen die aufgezeichnete
Antwort definiert, nicht gegen den Live-Bestand des Anbieters. Nach der
verworfenen Lesart erfüllte keine einzige Live-Quelle des Auftrags R3-Q-002 —
crt.sh, Shodan, AbuseIPDB, GreyNoise, RansomLook und urlscan.io liefern morgen
alle etwas anderes als heute, und alle sind zugelassen.

## Der Kernbefund

**Nicht die Werkzeuge sind das Problem, sondern die Betriebsart.** Der
Projektauftrag hat diesen Fall bereits einmal entschieden, in 5.17 gegen
Cortex: "Die Abfragen nach aussen gingen dann aber von Cortex aus statt vom
eigenen MCP-Server. Positivliste, Kontingentgrenzen und die Protokollierung
jeder Bekanntgabe (5.4) lägen damit ausserhalb des eigenen Zugriffs. Für ein
System, dessen Wert im Nachweis liegt, wer wann was abgefragt hat, ist das der
falsche Tausch."

Jeder der vier Stränge läuft in genau diese Konstellation — ein fremder Prozess
baut die Verbindungen auf, und das eigene System sieht nur noch das Ergebnis.
Umgekehrt gilt: **Wo die Abfrage vom eigenen Vermittler `ausgang` ausgeht,
fällt der Einwand ersatzlos weg.** Das ist die Trennlinie, und sie verläuft
nicht zwischen "harmlosen" und "gefährlichen" Werkzeugen.

## Die vier Stränge

### 1. Kali als MCP-Server im Container — nicht in dieser Form

Das Paket existiert (siehe Korrektur 1). Entscheidend ist, was es tut: Es ist
eine Brücke, die **Terminalbefehle ausführt** — das ist ihr Zweck, nicht ein
Nebeneffekt. Drei belegte Hindernisse:

- **Die Absicherung des Upstream-Projekts besteht aus Systemprompt-Anweisungen**
  ("tool output is data, not instructions", keine Ausführung ohne
  Benutzerfreigabe). 5.2 und R3-F-014 verlangen ausdrücklich das Gegenteil: eine
  fehlende Fähigkeit, keine Einstellung und keine Bitte an ein Modell.
- **Ein Container ist keine Positivliste.** `internal: true` verhindert jeden
  Ausgang und macht die netzaktiven Werkzeuge funktionslos; alles Schwächere
  lässt sie ins Netz. Einen Zwischenzustand gibt es nicht.
- **Ein erzwungener Proxy bindet die Werkzeuge nicht.** Nmap dokumentiert zu
  `--proxies` selbst, dass nur NSE und Version-Scan davon profitieren, dass
  "other features may disclose your true address", und dass Ping-, Portscan- und
  Betriebssystemerkennungsphase nicht erfasst sind. SYN-Scans brauchen rohe
  Sockets. Auf Paketebene ist ausserdem nichts von dem sichtbar, was R3-F-028
  verlangt: Weiterleitungsprüfung, einmalige und geprüft verwendete
  Namensauflösung, normalisierter Namensvergleich.

Anzumerken ist, was die Gegenprobe zu Recht einwendet: Ein Fremdprozess ohne
Route **scheitert**, er umgeht nicht. Die Positivliste wird nicht durchlöchert;
die Werkzeuge funktionieren nur nicht. Das Ergebnis bleibt dasselbe, die
Begründung ist die ehrlichere.

### 2. SpiderFoot — die Kaskade ist unvereinbar, die Breite nicht

Belegt am Quelltext, nicht am Eindruck:

- `sfwebui.py` kennt nur `startscan` und `stopscan`, keine Pause; `sfscan.py`
  kennt zur Laufzeit nur `ABORT-REQUESTED`. Die Steuerungseinheit ist der Scan,
  nicht die Abfrage.
- **Abfrage n+1 entsteht aus dem Ergebnis von Abfrage n** über den Ereignisbus.
  Damit ist die Vorschau nach 5.2 Schritt 3 **prinzipiell nicht erzeugbar** —
  nicht schwer, sondern unmöglich. Der Vorschlag setzt eine Information vor dem
  Lauf voraus, die erst im Lauf entsteht.
- Eine Freigabe je Modul ist nicht dasselbe wie eine Freigabe je Abfrage:
  `sfp_spider` macht mit einer Modulfreigabe bis zu 100 Abrufe, `sfp_portscan_tcp`
  eine Verbindung je Anschluss.
- SpiderFoot führt Anbieterschlüssel in eigener Optionsverwaltung, auslesbar
  über `optsraw`, exportierbar über `optsexport`. Das bricht R3-F-013.
- WHOIS über `whois`/`ipwhois`, Namensauflösung über `dns.resolver`, roher TCP
  über `socket.create_connection` — nichts davon ist HTTP, nichts davon sieht
  der Vermittler `ausgang`.

**Was stattdessen gebaut wird — und es gibt dem Auftraggeber, was er will:**

**Die Stapelfreigabe.** `freigabe.vorschlag` erzeugt **eine** Freigabevorlage,
die hundert Abfragen **aufzählt**: je Zeile Werkzeug, Gegenstelle,
Abfrageinhalt, erwarteter Kontingentverbrauch, Sichtbarkeitskennzeichen. Die
Ermittlerin sieht die Liste, hakt an oder ab, bestätigt einmal. Es entsteht eine
Freigabe-Kennung; `freigabe.ausfuehrung` arbeitet die abgehakte Menge ab und
prüft nach ADR 0002, Abschnitt 3.5, Punkt 3 Umfang und Zielmenge gegen die
Vorlage.

Das ist keine Aufweichung, sondern der bestehende Entwurf: **5.2 Schritt 3
spricht selbst im Plural** von "welche Abfragen an welche Dienste". Zulässig ist
eine geschlossene, vor der Freigabe vollständig aufgezählte Menge. Unzulässig
ist allein, dass Ergebnisse aus diesem Lauf **innerhalb derselben Freigabe**
neue Abfragen erzeugen. Dafür gibt es Schritt 6 des Kreislaufs: Vorschlag für
Anschlussabfragen, der zu einer **neuen** Vorlage führt.

Praktisch: **Der SpiderFoot-Ereignisbus wird in der eigenen Umsetzung zu einem
Vorschlagsbus.** Jeder neue Datenpunkt erzeugt Vorschlagszeilen statt Abfragen.
Der Unterschied ist eine Zeile im Modulschnitt — und rechtlich der ganze
Unterschied.

Damit die Erforderlichkeit je Bekanntgabe entscheidbar bleibt: Voreinstellung
ist **nichts** angehakt ausser den als passiv gekennzeichneten Quellen; je Zeile
ein Sichtbarkeits- und ein Kontingentkennzeichen; Reihenfolge nach steigender
Sichtbarkeit, Zeilen mit Berührung der Zielinfrastruktur unten und gesondert zu
bestätigen; die getroffene Auswahl **samt abgewählter Zeilen** in die
Arbeitsspur. Damit ist später belegbar, dass jede einzelne Bekanntgabe gewollt
war — was ein Kaskadenlauf gerade nicht leisten kann. Das Muster gibt es im
Projekt bereits: R3-F-040 (urlscan.io fest nicht öffentlich, Übersteuerung nur
mit gesonderter Bestätigung).

**Zusätzlich übernehmbar:** Die Korrelationsmaschine (`correlations/`).
`spiderfoot/correlation.py` importiert ausschliesslich `logging`, `deepcopy`,
`re`, `netaddr`, `yaml` und `SpiderFootDb` — keinen HTTP-Client, keine
Netzbibliothek. Sie rechnet auf bereits erhobenen Daten und ist damit belegbar
netzfrei. Ebenso der Modulkatalog als Dokumentationsquelle für das eigene
Quellenverzeichnis.

### 3. Onion und Dorking — der Hauptbedarf ist bereits gedeckt

Zwei technische Annahmen der ersten Einschätzung waren falsch und sind
korrigiert:

- **Onion-Dienste brauchen keinen Tor-Ausgang.** Der Verkehr bleibt vollständig
  im Tor-Netz. Es braucht einen Client, kein Relais.
- **Eine Onion-Adresse eignet sich hervorragend für eine Positivliste.** Die
  v3-Adresse **ist** der öffentliche ed25519-Schlüssel des Dienstes, und der
  Client prüft den Dienstdeskriptor gegen genau diesen Schlüssel. Als
  Listeneintrag ist sie exakter als jeder Domainname.

Was tatsächlich entgegensteht:

- **Ein unbeaufsichtigter Sammler steuert nicht, was er herunterlädt.** Der
  Konsum verbotener Pornografie ist bereits durch das Betrachten erfüllt; das
  Belassen im Zwischenspeicher genügt. Ein Filter greift zwangsläufig zu spät.
  Eine ausdrückliche dienstliche Ausnahme liess sich nicht belegen; die
  Rechtfertigung liefe über Art. 14 StGB und setzt eine konkrete Grundlage im
  Einzelfall voraus, die ein unbeaufsichtigter Lauf nicht hat.
- **Eine Registrierung auf einer Onion-Plattform ist genau die Fähigkeit**, die
  5.11 dem System als fehlende Funktion versagt. Die verdeckte Fahndung nach
  Art. 298a StPO steht im Titel Zwangsmassnahmen und setzt hinreichenden
  Tatverdacht nach Art. 197 Abs. 1 lit. b voraus.
- **Ein Clearnet-Gateway auf .onion wäre der Cortex-Tausch** in Reinform.

**Was sofort baubar ist, ohne eine einzige Zeile Tor-Code:** RansomLook und
Ransomware.live stehen bereits im Quellenverzeichnis und sind in R3-F-037
terminiert. Beide greifen die Onion-Leak-Seiten **selber** ab und stellen das
Ergebnis über Clearnet und eine Schnittstelle bereit. Der Hauptanwendungsfall —
eine Tätergruppe über ihre Leak-Seite und Opferliste zuordnen — ist damit
abgedeckt, mit Positivliste, Kontingent, Fallbindung und Protokoll vollständig
im eigenen Zugriff. Ergänzend: Die in den Antworten enthaltenen .onion-Adressen
werden als Entitäten im kanonischen Bestand geführt, mit Herkunftsnachweis —
ermittelbar, verknüpfbar und exportierbar, ohne sie je abzurufen.

Falls der direkte Zugriff angewiesen wird: Tor ausschliesslich als Client, im
Container `ausgang`; Positivliste als Liste vollständiger 56-Zeichen-Adressen
mit exaktem Zeichenvergleich, kein Suffix-Match; R3-F-028 ausdrücklich
fortschreiben, weil das Kriterium zur Namensauflösung für .onion ersatzlos
entfällt und an seine Stelle die kryptografische Bindung tritt.

### 4. Suchmaschinen — der Weg über die offizielle Schnittstelle ist zugefallen

Die entscheidende Tatsache hat sich seit der CAS-Blockwoche geändert:

- **Googles Custom Search JSON API ist für Neukunden geschlossen** und wird am
  2027-01-01 abgeschaltet.
- **Die Bing Search APIs sind seit dem 2025-08-11 vollständig abgeschaltet**,
  ohne Neuanmeldung.
- DuckDuckGo dokumentiert nur die Instant-Answer-Schnittstelle, die keine
  Trefferliste liefert.
- Alle vier Betreiber sperren die Ergebnisseite in `robots.txt`.

**Yandex gesondert:** Seit Juli 2024 gehört die Suchmaschine nicht mehr zur
niederländischen Yandex N.V. Diese verkaufte das russische Geschäft an das
Konsortium "Consortium.First" und heisst seither Nebius Group; die Konzernmutter
ist in Kaliningrad eingetragen. Suchbegriffe aus einem laufenden Schweizer
Strafverfahren gelangen damit in russische Jurisdiktion.

Ein Metasuchdienst mit Vertrag (SerpApi, Bright Data) löst das nicht, sondern
verlagert es — und trifft dieselbe Ablehnung wie Cortex.

**Was stattdessen trägt: den Index ins Haus holen.** Der Backlog geht diesen Weg
bereits — R3-F-035 begründet OpenSanctions im Eigenbetrieb ausdrücklich damit,
dass "Namen von Zielpersonen für die Sanktionsprüfung das Haus nicht verlassen".
Ein lokal gehaltener Common-Crawl-Korpusstand mit eigenem Suchindex beantwortet
die Kernfrage — kommt dieser Name, dieses Handle, diese Domain im offenen Netz
vor, und in welchem Zusammenhang — **ohne eine einzige ausgehende Verbindung**.

Der eigentliche Gewinn liegt woanders, als man erwartet: **Nur so ist ein
Negativbefund nach 5.3 belastbar.** Ein "nicht gefunden" aus Korpusstand X vom
Datum Y ist eine überprüfbare Aussage. Ein "nicht gefunden" aus Google ist es
nicht — Google schreibt selbst, eine auf das ganze Web gestellte Suche sei
"limited to a subset of the total Google Web Search corpus". Ein Negativbefund
kann entlastend wirken; er muss tragen.

Ehrliche Grenzen: Der Korpus ist Wochen bis Monate alt, deckt nicht alles ab und
enthält nichts hinter Anmeldung. Er ersetzt eine Live-Suche nicht. Bereits
vorhanden und zuerst auszuschöpfen: Sherlock/Maigret, holehe und PhoneInfoga im
Eigenbetrieb (R3-F-036) decken Benutzernamen, Konten zu E-Mail-Adressen und
Rufnummern ab — einen erheblichen Teil dessen, wofür sonst eine Suchmaschine
herhalten muss.

## Urteile je Werkzeug

| Werkzeug | Urteil | Tragender Grund |
|---|---|---|
| **MalwareBazaar** (abuse.ch) | baubar mit Auflage | Bereits im Auftrag als Ersatz für VirusTotal genannt. **Korrektur:** 5.14 verbietet das Senden eines Fallartefakts an einen Dritten, nicht den Bezug einer bereits öffentlichen Probe. Auflage: kein Einreichungspfad im Code — und zwar **im Werkzeug**, nicht am Vermittler, weil Abfrage, Download und Einreichung denselben Host und Pfad benutzen (`mb-api.abuse.ch/api/v1/`) und sich nur im Formularfeld unterscheiden. Keine Vollspiegelung: ein stehender Fremdbestand ohne Fallbezug fällt aus dem Aufbewahrungsmodell von 4.4 heraus |
| **mnemonic Passive DNS** | baubar mit Auflage | Dokumentierte REST-Schnittstelle, Abfrage geht vom eigenen System aus. Auflage: **mit Konto und Vertrag**, nicht unauthentifiziert — ohne Vertrag keine Zusicherung zu Protokollierung und Aufbewahrung, und der Abfrageinhalt ist die Ermittlungshypothese selbst. Deren MCP-Server-Image ist der Cortex-Fehler und wird nicht verwendet |
| **sitemapper-nodejs** | baubar mit Auflage | Kein Sicherheitswerkzeug, sondern ein Crawler. Art. 143bis StGB setzt das Überwinden einer Sicherung voraus, hier nicht berührt. Auflagen: Kapselung als `FremderInhalt` (R3-F-017), aufgezeichneter Rohstand mit Prüfsumme für R3-Q-002, Seitenobergrenze und Nebenläufigkeit in der Freigabevorschau. **Offener Punkt:** Ein Kennzeichen, das die eigene Instanz benennt, schreibt ins Protokoll des Ziels, dass die Kantonspolizei Bern systematisch abgreift — genau der Schaden aus 5.2 |
| **SpiderFoot-Korrelationsmaschine** | baubar mit Auflage | Belegbar netzfrei (keine Netzbibliothek im Import). Nur dieser Teil, nicht die Abfragemaschine |
| **HackerTarget Reverse IP** | rechtlich zu klären | Technisch sauber, dokumentierte Schnittstelle, Kontingent sogar in den Antwortkopfzeilen. Offen ist allein die vertragliche Seite. **Korrektur:** Das ist nach 5.17 ("Schlüsselweitergabe [GEKLÄRT]") kein Ausschlussgrund, sondern ein Fall für Etappe 5 nach dem Muster von R3-F-083 — geführter Eintrag bis zum Beschaffungsentscheid, keine Streichung |
| **WiGLE** | rechtlich zu klären | Technisch sauber; die Ablehnung war rein vertraglich. **Korrektur:** Der behauptete Konflikt mit R3-F-013 ist konstruiert — ein personengebundener Schlüssel je Ermittlerin, serverseitig gehalten, erfüllt die Vorschrift und verletzt die Lizenz nicht. Ebenfalls Etappe-5-Muster. Zusätzlich zu klären: Welche Personendaten der Bestand enthält |
| **viewDNS Portscan** | rechtlich zu klären, geparkt | Zwei Empfänger statt einem: viewDNS erfährt Ziel und Zeitpunkt, **und das Ziel selbst erhält Verbindungsversuche**. Genau der Fall aus 5.2. **Korrektur:** Die schärfere Fassung stützte sich auf die widerlegte 5.11-Lesart. Kein belegter Bedarf in Etappe 1 bis 4; wenn gewollt, eigener Eintrag mit vorheriger Einordnung durch die GRC-Rolle |
| **viewDNS Registrierungshistorie** | Bedarf gedeckt | Existiert bei viewDNS so nicht (es gibt IP History, WHOIS und Reverse WHOIS — drei verschiedene Dinge). Der Bedarf ist durch **DomainTools** gedeckt, R3-F-081, Etappe 5, bestehender Vertrag |
| **bgp.he.net / certs** | Bedarf gedeckt | Der passive Teil ist fachlich unbedenklich. Es fehlt eine dokumentierte Schnittstelle — die nutzbaren Endpunkte stammen aus dem JavaScript der Seite, ohne Versionszusage und Nutzungsregel; damit kein Antwortschema nach R3-F-022. **Zertifikatsprotokolle deckt crt.sh ab**, R3-F-032, Etappe 2 |
| **SpyOnWeb** | unvereinbar | Die Betreiberin sagt es selbst: "We collect data straight from the domains you look up ... Every lookup refreshes the domain data on the spot." Jede Abfrage löst einen Abruf gegen die Zielseite aus. Schwerer: Die Überwachungsfunktion fragt nach Zeitplan über Monate wiederholt ab, ohne Freigabe je Abfrage — die Verkettung, die 5.2 ausschliesst |
| **OSINT Cabal Live Center** | unvereinbar | Cortex-Präzedenz in schärfster Form. Die Werkzeuge laufen serverseitig (`nmap_wrapper.php`, `dorksint_wrapper.php`); betrieben "solely by Terrorbyte", keine Rechtsperson, keine Anschrift. Kein Empfänger, der sich nach 5.4 dokumentieren liesse |
| **URLQuery.net** | unvereinbar | Nutzungsbedingungen: "solely for your personal, non-commercial research or educational purposes"; zusätzlich "Do not submit URLs that contain private, confidential, or personally identifiable data". Weitergabe an "trusted security companies and communities" ohne Verzeichnis und ohne Abwahl. **Der Platz ist mit urlscan.io besetzt** (R3-F-040), wo je Stufe dokumentiert ist, wer was sieht |
| **Jotti** | unvereinbar | Dieselbe Klasse wie VirusTotal, und der Upload eines Fallartefakts an einen öffentlichen Dienst Dritter ist genau, was 5.14 untersagt. Weitergabe zugesichert und unumkehrbar |
| **Sn1per, SCANNER-INURLBR** | unvereinbar | Angriffswerkzeuge mit Ausnutzungsmodulen, keine Quellen. Ausserhalb dessen, was dieses Projekt baut |

## Was der Auftraggeber entscheiden muss

**1. Ist der Vorschlag vom 2026-08-29 eine Weisung nach 5.17?** Das ist die
Frage, die alles andere aufhält, und sie ist in einem Satz zu beantworten. 5.17
sagt: Das Quellenverzeichnis "wird nicht erweitert und nicht gekürzt, ausser der
Auftraggeber weist es an." Die Prüfung hat diese Frage zweimal gegensätzlich
beantwortet — einmal "die Weisung liegt der Sache nach vor", einmal "eine
Begeisterungsäusserung ist keine Anweisung". **Beides kann nicht stimmen.** In
sieben Bewertungen ist "nicht im Quellenverzeichnis" als eigenständiger
Ablehnungsgrund geführt; wird die Einreichung als Weisung gelesen, fällt dieser
Punkt überall weg und es bleibt nur, was sachlich übrig ist. 3.1 verlangt nicht,
im Zweifel gegen den Auftraggeber zu entscheiden, sondern nicht nach eigenem
Ermessen zu handeln — deshalb steht die Frage hier und ist nicht entschieden.

**2. Portscan als Fähigkeit — ja oder nein?** Nicht technisch, sondern
grundsätzlich. Wenn ja, geht es vor jeder Umsetzung an die GRC-Rolle und den
Legal Reviewer.

**3. Direkter Onion-Zugriff — nötig, oder genügen RansomLook und
Ransomware.live?** Die Empfehlung lautet: zuerst das Vorhandene ausschöpfen. Der
direkte Zugriff bringt einen unbeaufsichtigten Sammler mit einem Risiko, das
sich technisch nicht abfangen lässt.

**4. Reihenfolge.** Der freigegebene Plan sieht als Nächstes R3-Q-001 vor, dann
E4, E3, dann das Grundgerüst. Nichts aus dieser Vorlage ist darin enthalten.

## Weg durch die Gremien

1. **Auftraggeber:** Weisung nach 5.17 zu Frage 1, Entscheid zu 2 und 3.
2. **GRC-Rolle und Legal Reviewer:** Einordnung des aktiven Scannens nach 4.4
   und der Onion-Frage nach Art. 298a ff. StPO — vor jeder Umsetzung.
3. **Datenschutzexperte:** WiGLE-Bestand, Bekanntgabe je Quelle,
   Aufbewahrung eines allfälligen Fremdbestands.
4. **Software Architect:** Fortschreibung von ADR 0002 für die Stapelfreigabe
   (Vorschlagsbus statt Ereignisbus) und, falls angewiesen, für den
   Tor-Transport im Vermittler `ausgang`.
5. **Product Owner:** Einordnung der neuen Backlog-Einträge nach 6.6 und B4 —
   als **eigene** Einträge, nicht als Erweiterung bestehender (Muster R3-F-028
   neben R3-F-015).

## Was sofort und ohne jeden Entscheid baubar ist

**Lokale Werkzeuge aus Kali als Paketquelle, nicht als Laufzeit.** exiftool
(steht ohnehin in Anhang A), binwalk, strings, yara, Hash-Werkzeuge arbeiten an
einer bereits beschafften Datei und bauen **keine** Netzverbindung auf. Sie
erzeugen keine Bekanntgabe, also stellt sich die Frage nach Positivliste und
Kontingent gar nicht. Installation per `apt` über Prüfsumme in die bestehenden
Container, kein Kali-Basisimage, kein fremder MCP-Server. Jedes bekommt einen
regulären Eintrag im Werkzeugverzeichnis nach R3-F-026.

Das ist der grösste sofort verfügbare Gewinn aus dem ganzen Vorschlag — und er
beugt keine einzige Vorschrift.
