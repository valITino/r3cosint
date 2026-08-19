# Freigabe-Gate Schritt 4 — Prüfung und schriftliche Freigabe der Schritte 1 bis 3

| | |
|---|---|
| **Arbeitsprodukt nach** | Projektauftrag Abschnitt 2, Schritt 4 |
| **Entscheidet** | Auftraggeber (S-01); Prüfung gemeinsam mit dem Studienkollegen (S-02) |
| **Vorbereitet** | 2026-08-19, Lieferschritt-4-Vorbereitung durch Claude Code |
| **Status** | **offen — Freigabe nicht erteilt** |

## 1. Was dieses Gate ist

Abschnitt 2 des Projektauftrags: *«FREIGABE-GATE: Der Auftraggeber prüft 1 bis 3
und gibt schriftlich frei.»* Kein Schritt beginnt, bevor der vorherige
abgeschlossen und freigegeben ist; vor Schritt 4 wird kein Produktionscode
geschrieben. Die Roadmap führt dieses Gate als Blockade für **alles**
(`07_Roadmap.md`, «Was diese Roadmap blockiert»).

Das Freigabe-Gate ist ein Prüfpunkt im Projektablauf und nicht zu verwechseln
mit der Freigabe einer Abfrage im späteren Betrieb (Glossar, Homonym-Warnung).

Drei Festlegungen zur Form:

1. **Schriftlich heisst committet.** Die Freigabe ist erteilt, wenn die
   Freigabeerklärung in Abschnitt 6 ausgefüllt und im Repository committet ist.
   Ein mündliches oder im Chat erteiltes Ja genügt der Form aus Abschnitt 2
   nicht und wäre nicht nachweisbar (6.6).
2. **Claude Code füllt Abschnitt 6 nicht aus.** Die Entscheidung liegt beim
   Auftraggeber; dieses Dokument bereitet sie nur vor.
3. **Geprüft wird der benannte Stand.** Prüfgegenstand ist der unter Abschnitt 2
   genannte Commit. Was danach committet wurde, ist nicht Gegenstand dieser
   Freigabe.

## 2. Prüfgegenstand

Geprüft wird der Stand des Repositories beim Merge von Pull Request #3:

```
41ccb72695d0755a879d50c2fd1ffd4ce2ae6ea1
```

Die festen Verweise je Artefakt — mit der 40-stelligen Prüfsumme des Commits,
in dem das Artefakt zuletzt geändert wurde — stehen im Nachweisverzeichnis
`docs/NACHWEISE.md`. Zuordnung der Artefakte zu den Schritten:

| Schritt | Artefakte |
|---|---|
| 1 — Rollenmodell | 21 Rollendateien unter `.claude/agents/`; `docs/adr/0001-rollenmodell.md` |
| 2 — CLAUDE.md, Rules, Hooks | `CLAUDE.md`; fünf Regelwerke unter `.claude/rules/`; `.claude/settings.json`; drei Hook-Skripte unter `.claude/hooks/` |
| 3 — Requirements Engineering und Planung | `docs/02_Stakeholderliste.md`, `docs/03_Glossar.md`, `docs/04_Kontextmodell.md`, `docs/05_Product_Backlog.md`, `docs/06_Definition_of_Ready_und_Done.md`, `docs/07_Roadmap.md`, `docs/NACHWEISE.md` samt `scripts/nachweise-erzeugen.sh`, `.github/workflows/nachweise-uebertragen.yml`, `docs/EINGANG_METHODIK.md` |

**Nicht Prüfgegenstand:** der Projektauftrag und das Konzeptdokument (sie sind
der Massstab, nicht das Ergebnis), die Demo unter `prototype/` (ihr Gate ist die
spätere Prototyp-Freigabe nach 5.6) und jede Form von Produktionscode (es
existiert bestimmungsgemäss keiner).

## 3. Prüffragen

Die Fragen sind aus den Abschnitten 3, 4 und 6 des Projektauftrags abgeleitet.
Jede Frage nennt die Fundstelle, gegen die geprüft wird. Nach 6.7 gilt: Im
Review wird gesammelt, nicht gelöst — Befunde werden notiert und landen als
Auflagen in Abschnitt 6 oder als Einträge beim Product Owner.

### Schritt 1 — Rollenmodell (Abschnitt 4)

- [ ] Unter `.claude/agents/` liegen 21 Rollendateien; sie decken die Tabellen
      4.2 und 4.3 ab, keine Rolle ist erfunden. Der Release Manager ist bewusst
      nicht angelegt (Entscheid E-04).
- [ ] Stichprobe über mindestens fünf Rollendateien: das `description`-Feld
      beschreibt den Auslösefall, nicht die Rolle (4.1).
- [ ] Die Tool-Listen sind Positivlisten nach minimalen Rechten und stimmen mit
      der Tabelle in ADR 0001 Abschnitt 3 überein; Static Software Tester und
      Pentester haben kein `Edit` und kein `Write` (4.2).
- [ ] Modelltrennung: Umsetzung und Prüfung laufen auf verschiedenen Modellen;
      die Paare aus ADR 0001 Abschnitt 2.3 sind nachvollziehbar (3.4).
- [ ] `maxTurns` ist in jeder Rollendatei gesetzt (3.4, Ebene 4).
- [ ] Die Grenze ist ausgewiesen, nicht beschönigt: Verzeichnisbegrenzungen sind
      Instruktion, kein Mechanismus; hart würden sie erst über einen
      `PreToolUse`-Hook (ADR 0001, Abschnitte 4 und 7.1). Ein Backlog-Eintrag
      dafür fehlt — siehe V-04.

### Schritt 2 — CLAUDE.md, Rules, Hooks (Abschnitt 3)

- [ ] `CLAUDE.md` bleibt unter 200 Zeilen und formuliert konkret und überprüfbar
      statt allgemein (3.2).
- [ ] Die fünf Regelwerke unter `.claude/rules/` decken Prototyp,
      Produktionscode, Dokumentation, Recht/Datenschutz und
      Claude-Konfiguration ab und widersprechen CLAUDE.md nicht.
- [ ] `.claude/settings.json` ist versioniert und enthält beide
      `PreToolUse`-Gates sowie den `SessionStart`-Hook (3.4: ein Hook, der nur
      lokal existiert, wirkt in der Web-Umgebung nicht).
- [ ] Gate-Probe main-Schutz: In einer Sitzung auf `main` eine Datei zu ändern
      oder `git commit` auszuführen wird mit der Meldung «BLOCKIERT
      (Projektauftrag 3.2 c)» verweigert (Rückgabewert 2, nicht 1).
- [ ] Gate-Probe Prototyp-Trennung: Ein Import aus `prototype/` in eine Datei
      ausserhalb wird blockiert (5.6).
- [ ] Fehlt `jq`, blockieren beide Gates mit Meldung, statt stillschweigend
      durchzulassen (fail closed).

### Schritt 3 — Requirements Engineering und Planung (Abschnitt 6)

- [ ] Stakeholderliste: je Stakeholder die Pflichtangaben nach 6.3; die in 6.3
      genannten Mindest-Stakeholder sind enthalten; fehlende Namen und Kontakte
      sind als *nachzutragen* markiert statt erfunden.
- [ ] Glossar: die Begriffe mit rechtlicher Bedeutung sind definiert und
      gekennzeichnet, insbesondere die Abgrenzung verdeckte Fahndung gegen
      verdeckte Ermittlung; Synonyme gekennzeichnet, Homonyme vermieden (6.3).
- [ ] Kontextmodell: Systemgrenze, Kontextgrenze, externe Akteure und
      Schnittstellen; offene Punkte benannt statt entschieden (6.3).
- [ ] Product Backlog: 74 Einträge; je Eintrag dauerhafte Kennung,
      Anforderungsart nach 6.4, Kano-Einordnung, geschätzter **Prüfaufwand**,
      Rückverweis auf den Projektauftrag und ein als Test formuliertes
      Abnahmekriterium mit der Kennung im Testnamen (6.4, 6.5, 6.6).
- [ ] Stichprobe über mindestens fünf Backlog-Einträge gegen den zitierten
      Abschnitt des Projektauftrags: Formulierung deckt die Quelle, nichts
      dazuerfunden.
- [ ] Gestrichenes bleibt gestrichen: kein Eintrag baut VirusTotal,
      Gesichtserkennung, Open WebUI, CASE/UCO oder eine Maltego-Fernsteuerung
      (5.17, 5.18, 9.1, 5.10, 5.1).
- [ ] Der präskriptive Teil (4.4) ist als gesetzte Randbedingungen abgebildet
      und nicht wegpriorisiert (6.2, DoR B6).
- [ ] Definition of Ready und Done: DoR nach den IREB-Kriterien; DoD als
      Befehlskette D1–D12 plus die menschlich bestätigten Bedingungen D13–D17;
      beide Reihenfolge-Gates verankert; Sonderfall Prototyp ausgewiesen (6.5,
      6.8, 3.4).
- [ ] Roadmap: Sprintzahlen aus geschätzten Prüfstunden abgeleitet, keine
      Kalenderzusage; der Sprintumfang bemisst sich an der Prüfkapazität
      28–40 h (6.8); die Blockadetabelle stimmt mit Abschnitt 2 überein.
- [ ] Nachweisverzeichnis: erzeugt statt von Hand gepflegt; jeder Verweis trägt
      die 40-stellige Commit-Prüfsumme, kein Verweis auf `blob/main` (6.6).
- [ ] Commit-Betreffe der geprüften Stände folgen Conventional Commits; zum
      Fehlen der Anforderungskennung in den Commits der Schritte 1 bis 3
      siehe V-05 (6.6).

## 4. Befunde der Vorprüfung

Bei der Vorbereitung dieses Gates wurden die Artefakte quergelesen; die
Vorbereitung selbst wurde vom Static Software Tester gegengeprüft, auf einem
anderen Modell als die Umsetzung (3.4). Zählungen sind konsistent und
nachgerechnet (Backlog-Summentabelle, Roadmap und Einträge: 69 + 5 = 74;
Prüfaufwand 296 h + 23 h = 319 h). Vier Befunde bleiben offen und gehören in
den Freigabeentscheid; einer wurde in dieser Vorbereitung behoben.

### V-01 — R3-Q-001 verweist auf einen Eintrag, den es nicht gibt

`R3-Q-001` (Definition-of-Done-Gates als Hooks) nennt als Abhängigkeit
*«Setzt R3-C-020 (Definition of Done) voraus»*. Ein Eintrag `R3-C-020`
existiert im Backlog nicht. Gemeint ist erkennbar die Definition of Done
selbst (`docs/06_Definition_of_Ready_und_Done.md`), die seit Schritt 3
vorliegt, sowie deren offener Punkt 3 — die konkreten Befehle je Kettenschritt
aus R3-C-001. Der hängende Verweis verletzt die DoR-Kriterien R10 und B5.

**Vorschlag:** Als Auflage zur Freigabe die Abhängigkeit umformulieren auf:
*«Setzt die Definition of Done (`docs/06_Definition_of_Ready_und_Done.md`) und
R3-C-001 voraus, weil die konkreten Befehle je Kettenschritt vom Ziel-Stack
abhängen.»* Die Korrektur ordnet der Product Owner ein (DoR B4).

### V-02 — Zeitpunkt der DoD-Hooks: ADR 0001 widerspricht der Planung aus Schritt 3

ADR 0001, Konsequenz 7.4, verlangt die `Stop`-, `SubagentStop`- und
`TaskCompleted`-Hooks **vor** dem Freigabe-Gate. Die später entstandene
Definition of Done und der Backlog terminieren dieselben Hooks als `R3-Q-001`
in Etappe 0 — **nach** dem Gate —, weil die Befehle der Kette (Bau, Linter,
Typprüfung, Tests) erst mit dem Ziel-Stack aus R3-C-001 existieren. Der
ADR-Stand ist damit vom Schritt-3-Ergebnis überholt, aber nicht fortgeschrieben
(Regel Dokumentation: ADR fortschreiben, nicht stillschweigend überholen).

**Zur Sache, ehrlich in beide Richtungen:** Ein Hook-Gerüst wäre heute
teilweise baubar — D10 (Prototyp-Trennung), D11 (Geheimnisse) und D12
(Nachweisverzeichnis) sind schon prüfbar. Die tragenden Schritte D1 bis D9
sind es ohne Stack nicht; ein Gate, das nur das Prüfbare prüft, wäre grün,
ohne das Wesentliche zu sichern.

**Vorschlag:** Die Terminierung als R3-Q-001 in Etappe 0 bestätigen (Entscheid
E-02) und ADR 0001 als Auflage fortschreiben. Die Gegenposition — Hooks vor
der Freigabe — bleibt wählbar; dann verschiebt sich das Gate, bis das Gerüst
steht.

### V-03 — Statustabelle in CLAUDE.md war veraltet *(behoben)*

Die Tabelle der Lieferreihenfolge führte Schritt 3 noch als «offen», obwohl
Pull Request #3 gemergt ist. Mit dieser Vorbereitung nachgeführt: Schritt 3
«erledigt», Schritt 4 «vorbereitet» mit Verweis auf dieses Dokument; zugleich
nennt der Absatz zu den fehlenden DoD-Gates jetzt den Stand aus Schritt 3
(R3-Q-001), ausdrücklich unter Vorbehalt des Entscheids E-02. Kein Entscheid
nötig; der Hinweis dient der Transparenz, weil CLAUDE.md zum Prüfgegenstand
von Schritt 2 gehört. Beide Nachführungen liegen nach dem Stand aus
Abschnitt 2 und sind nicht Gegenstand dieser Freigabe; sie sind über die
Commit-Historie des Arbeitszweigs nachvollziehbar.

### V-04 — Zwei Folgearbeiten aus ADR 0001 haben keinen Backlog-Eintrag

ADR 0001, Abschnitt 8, führt als Folgearbeit die harte Durchsetzung der
Rollen-Schreibgrenzen und das `skills:`-Feld je Rolle. Für beides existiert
kein Backlog-Eintrag: R3-Q-001 deckt nur die `Stop`-, `SubagentStop`- und
`TaskCompleted`-Hooks der Definition of Done; die Verzeichnisbegrenzung je
Rolle bräuchte einen `PreToolUse`-Hook (ADR 0001, Abschnitt 4), und das
`skills:`-Feld wartet auf die ersten Skills. Ohne Eintrag bleibt der in
ADR 0001 7.1 offengelegte Instruktionszustand nach dem Gate unverfolgt.

**Vorschlag:** Als Auflage beide Punkte dem Product Owner zur Einordnung als
Backlog-Einträge geben — oder bewusst beim Instruktionszustand bleiben und
das in ADR 0001 fortschreiben.

### V-05 — Commit-Betreffe der Schritte 1 bis 3 ohne Anforderungskennung

Die Commit-Betreffe des Prüfgegenstands folgen Conventional Commits, tragen
aber keine Anforderungskennung (6.6). Das ist erklärbar: die Kennungen
entstanden erst mit dem Backlog in Schritt 3.

**Vorschlag:** Kein rückwirkender Handlungsbedarf. Ab der ersten
Umsetzungseinheit ist die Kennung im Commit-Betreff und im Testnamen Pflicht
und wird im Review jeder Einheit mitgeprüft.

## 5. Entscheidungspunkte

**Am Gate zu entscheiden** — alle drei gehören in die Freigabeerklärung:

| Nr. | Entscheid | Fundstelle | Was daran hängt |
|---|---|---|---|
| E-01 | Freigabe der Schritte 1 bis 3: ja, mit Auflagen, oder Zurückweisung | Abschnitt 2 | alles — ohne E-01 beginnt keine Umsetzung |
| E-02 | DoD-Hooks als R3-Q-001 in Etappe 0 bestätigen, oder vor der Freigabe verlangen | V-02; ADR 0001 7.4; DoD «Durchsetzung» | die Auflösung von V-02 und der Startzeitpunkt von Etappe 0 |
| E-03 | Schnitt in erste und zweite lieferfähige Fassung bestätigen oder ändern | Backlog «Offene Punkte» 3; Roadmap; 9.1 | Roadmap und erste Fassung bauen darauf; der Schnitt gehört nach 9.1 zu Schritt 3, den dieses Gate abschliesst |

**Nicht blockierend** — mit Termin, damit nichts verlorengeht:

| Nr. | Entscheid | Fundstelle | Spätestens |
|---|---|---|---|
| E-04 | Release Manager als eigene Rolle oder beim DevOps Engineer belassen | 4.3 [OFFEN]; ADR 0001 6 und 8 | vor der ersten Versionsfreigabe |
| E-05 | Schreibrechte des Legal Reviewers: «gar keine» (3.2 a) gegen «nur Dokumentation» (4.2) | ADR 0001 8 | vor dem ersten Einsatz der Rolle |
| E-06 | Zugeordneter Standard für den IT Supporter | ADR 0001 8 | vor R3-F-092 (zweite Fassung) |
| E-07 | Abdeckungsschwelle D6: Vorschlag 80 % Zeilen, 100 % für Protokoll, Klassifizierung, Freigabesperre | DoD «Offene Punkte» 1 | mit R3-Q-001 |
| E-08 | Schwellen für Linter-Warnungen (D3) und Abhängigkeits-Schwachstellen (D8), mit SecDevOps | DoD «Offene Punkte» 2 | erste Umsetzungseinheit mit Code |
| E-09 | Zahlenwert der Graph-Antwortzeit bestätigen (2 s, 95. Perzentil, 50 Knoten) | R3-Q-004 | vor Etappe 6 |
| E-10 | R3-F-094 schneiden; der Eintrag erfüllt die DoR bewusst noch nicht | Backlog «Offene Punkte» 2 | vor der zweiten Fassung |
| E-11 | Namen und Kontakte der Stakeholder nachtragen; entscheiden, ob personenbezogene Angaben ins öffentliche Repository dürfen und ob eine Vertretung der Ermittelnden (S-03) für Reviews benannt wird | Stakeholderliste «Was noch fehlt» | vor der ersten Review-Runde mit Dritten |
| E-12 | Beschaffung Epieos | Backlog «Offene Punkte» 5 | vor Etappe 5 |
| E-13 | Weitere Qualitätsanforderungen nach ISO/IEC 25010 ergänzen, insbesondere Verfügbarkeit und Wiederanlaufzeit | Backlog «Offene Punkte» 4 | fortlaufende Backlog-Pflege, spätestens vor Etappe 6 |

Die offenen Punkte des Kontextmodells (Ziel-Stack, TheHive/Cortex-Tiefe,
`pgvector`) sind keine Gate-Entscheide: sie gehören zum Architekturentscheid
R3-C-001 und werden dort vorgelegt und freigegeben. Der Entra-ID-Punkt liegt
bei der Informatik KapoBE und blockiert nur den Mandantenwechsel.

## 6. Freigabeerklärung

*Auszufüllen durch den Auftraggeber (S-01). Claude Code füllt diesen Abschnitt
nicht aus.*

### Entscheid (E-01)

- [ ] **Freigegeben.** Die Umsetzung gemäss freigegebenem Plan darf beginnen.
- [ ] **Freigegeben mit Auflagen.** Die Umsetzung darf beginnen; die Auflagen
      unten werden als Einträge eingeordnet und abgearbeitet.
- [ ] **Zurückgewiesen.** Nachbesserung gemäss Auflagen, danach erneute Vorlage.

### Auflagen

| Nr. | Auflage | Frist oder Bedingung |
|---|---|---|
| A-1 | | |
| A-2 | | |

### Entscheide am Gate

| Punkt | Entscheid |
|---|---|
| E-02 — Zeitpunkt der DoD-Hooks | |
| E-03 — Schnitt der Fassungen | |

### Erklärung

> Ich habe die Ergebnisse der Lieferschritte 1 bis 3 im Stand
> `41ccb72695d0755a879d50c2fd1ffd4ce2ae6ea1` geprüft.
> Der Entscheid oben gilt.

| | |
|---|---|
| **Auftraggeber (S-01)** | *Name, Datum* |
| **Mitgeprüft, Studienkollege (S-02)** | *Name, Datum* |

### Formweg

Die ausgefüllte Erklärung wird committet — entweder direkt über die
GitHub-Oberfläche (Datei bearbeiten, eigener Zweig, Pull Request, Merge) oder
als Anweisung an die nächste Claude-Code-Session mit dem exakten Wortlaut des
Entscheids. Massgeblich ist der committete Stand; die Commit-Historie belegt
Urheber und Zeitpunkt. Erst mit diesem Commit gilt Schritt 4 als erledigt.

## 7. Nach der Freigabe

1. Die erste Session nach der Freigabe führt die Statustabelle in CLAUDE.md
   nach — Schritt 4 «erledigt» mit der Commit-Prüfsumme der Freigabe,
   Schritt 5 frei — und arbeitet die beschlossenen Auflagen als Erstes ab.
2. Erste Arbeitseinheit ist **R3-C-001** (Architekturentscheid und Ziel-Stack):
   er blockiert Etappe 1 und alles danach und wird dem Auftraggeber zur
   Freigabe vorgelegt. Danach folgen die übrigen Einträge der Etappe 0
   (R3-C-002 bis R3-C-005, R3-Q-001 nach Entscheid E-02).
3. Für jede weitere Session gilt dasselbe Muster:

   ```
   Nimm den Backlog-Eintrag <Kennung>. Arbeite nach CLAUDE.md.
   Halte an, wenn die Definition of Done erfüllt ist oder wenn dieselbe Prüfung
   dreimal am selben Kriterium scheitert.
   ```

4. **Ehrlicher Hinweis zur Übergangszeit:** Bis R3-Q-001 umgesetzt ist, wird
   die Definition of Done nicht technisch erzwungen. Die Prüfung der ersten
   Einheiten liegt vollständig beim menschlichen Review — bei Dokument- und
   Konfigurationsarbeit wie R3-C-001 und R3-C-002 ist sie dort ohnehin am
   richtigen Ort.
