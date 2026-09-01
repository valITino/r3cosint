# Übergabe — Fremdes Skill-Repository ausgewertet, erste zwei Skills

| | |
|---|---|
| **Arbeitsprodukt nach** | Projektauftrag 3.3 (Übergabedatei je Arbeitseinheit), 3.4 (Eskalation) |
| **Einheit** | Auswertung von `valITino/claude-skills-fullstack` auf Weisung des Auftraggebers vom 2026-08-31 |
| **Datum** | 2026-08-31 |
| **Zweig** | `claude/next-step-g8slnq` |
| **Fremder Bestand** | `882ef55e377dbf9a4dbe496bb41ac6ccd0e555cf`, lokal unter `/home/user/valitino/claude-skills-fullstack` |
| **Ergebnis** | **Teilweise abgenommen; die beiden Skills nach 3.4 abgebrochen.** Backlog, Definition of Ready, Roadmap, Konfigurationsregel und ADR 0001 sind geprüft und abgenommen. Die beiden Skills sind **nicht abgenommen**: Dieselbe Prüfung ist dreimal am selben Kriterium gescheitert |

## Auftrag

Der Auftraggeber hat das Repository angebunden mit der Weisung, es genau
anzusehen und zu übernehmen, was Qualität und Rollenmodell stärkt, "damit
wirklich die Qualität bzw. das Team sauber da steht, um endlich dann das
Produkt aufzubauen".

## Was der Bestand ist

67 Skills für Claude Code, je einer mit einer `SKILL.md`, dazu 371
Referenzdateien und eine eigene Werkzeugschicht. Allgemeiner
Full-Stack-Zuschnitt, englisch, ohne Bezug zu Ermittlungsarbeit,
Protokollpflichten oder Rechtsregimen. Verteilt über einen Marktplatz, der
sich selbsttätig aktualisiert.

**Negativbefund zu den gestrichenen Entscheiden.** Eine Suche über den ganzen
Bestand nach VirusTotal, TheHive, Cortex, Gesichtserkennung, Open WebUI,
CASE/UCO und Maltego ergibt genau einen Treffer, und der ist ein Fehltreffer
("ARM Cortex-M"). **Nachtrag:** `pgvector` gehörte in dieselbe Suche und war
nicht darin — es steht in vier Dateien, unter anderem in einem ganzen Skill,
dessen Gegenstand die Auswahl eines Vektorspeichers ist. Beide sind abgelehnt.

## Wie ausgewertet wurde

Sieben Bereiche parallel erfasst, jeder gegen unsere Bauvorschriften bewertet,
zusammengeführt und von einer unabhängigen Vollständigkeitskritik
gegengelesen. Die Kritik fand im Vorschlag sechzehn Lücken und sieben falsche
Belegstellen.

**Arbeitsregel dieser Einheit:** Keine Angabe aus der Auswertung ist ungeprüft
in ein Artefakt gelangt. Eine Behauptung der Kritik hat die Nachprüfung selbst
nicht überstanden und ist deshalb nirgends übernommen: Der fremde Bestand
widerspreche sich über den eigenen Rückkanal. Er tut es nicht — die Aussage
"keine Telemetrie" steht dort ausdrücklich unter der Überschrift "The Plugin",
und der Analysedienst der Dokumentationsseite ist in einem eigenen Abschnitt
offengelegt.

## Was entstanden und abgenommen ist

- **`docs/05_Product_Backlog.md`** — fünf neue Einträge (R3-Q-007, R3-Q-008,
  R3-Q-009, R3-F-029, R3-F-062), sechs Kandidaten begründet abgelehnt. Danach
  drei Beobachtungen einer Prüfung nachgezogen: Gegenprobe bei R3-F-062,
  einheitliche Verbuchung der nicht bereiten Einträge, Operationalisierung des
  zweiten Kriteriums von R3-Q-007.
- **`docs/06_Definition_of_Ready_und_Done.md`** — Notation der
  Abnahmekriterien: vier Glieder (Umfang, Prüfsatz, Nachbedingung,
  Gegenprobe), als Vorschlag zur Bestätigung. Weder EARS noch
  Given/When/Then, beide an vierzehn Kriterien des Bestands geprüft und
  begründet verworfen.
- **`docs/07_Roadmap.md`** — Zahlen gegen den Backlog abgeglichen.
- **`.claude/rules/claude-konfiguration.md`** — neuer Abschnitt "Skills".
- **`docs/adr/0001-rollenmodell.md`** — drei Berichtigungen und eine
  Fortschreibung.

**Der wichtigste Zugewinn ist R3-Q-007.** Er schliesst die Lücke, die ADR 0001
selbst benennt: Rechte liegen in zwei Formen vor, hart im `tools`-Feld und
weich als Instruktion, "beide müssen übereinstimmen" — und für dreizehn der
einundzwanzig Rollen ist die weiche Form die einzige. Eine Übereinstimmung,
die niemand prüft, ist eine Hoffnung.

## Was ausdrücklich nicht übernommen wurde

**Der Bezugsweg selbst.** Marktplatz und Plugin-Installation aktualisieren
sich selbsttätig — die ausführbare Form genau desjenigen Verweises, den unsere
Dokumentationsregel als Nachweis für untauglich erklärt, und unvereinbar mit
der Verfahrensgarantie Reproduzierbarkeit.

**Alles mit gestrichenem oder entschiedenem Gegenstand.** Zwei Skills führen
`pgvector`; ein Skill, der bei der nach A4 ausgeschlossenen Erweiterung
anspringt, **ist** der Platzhalter, den A4 verbietet. Ebenso die
Betriebs-Skills gegen unser Umgebungsbild aus A11 und ein Entwurfs-Skill, der
das Rechtsregime als Auswahlliste anbietet — für ein Vorhaben der
Kantonspolizei Bern ist das Regime nicht wählbar.

**Alles, was die Freigabesperre zur Einstellung machte.** Selbstheilungsmuster
verketten Erkennen und Handeln ohne Menschen dazwischen; eine Rückfrage im
Text ist keine Freigabe.

**Zwei Referenzdateien mit Einschleusungsmustern**, eine Sammlung ausgehender
Aufklärungsbefehle, eine selbst gebaute Anmeldung gegen A10, eine zweite
Prüfkette neben `make dod`, die den Gegenstand verändert, über den sie
urteilt — und alles Frontend, auch als Platzhalter (5.6).

**Alles aus der Darstellungsschicht**: Analysedienst, externe Bilddienste, ein
Dienst für Abdeckungsdaten. Kein Rückkanal, und zwar auch einzeln nicht.

## Offen für den Auftraggeber

1. **Wer `.claude/skills/` beschreiben darf.** ADR 0001 weist `.claude/`
   keiner Rolle zu.
2. **Herkunftsvermerk bei fehlendem Rechteinhaber** (Methodik-Repository, S6).
3. **R3-F-029** — ist die Verfeinerung von "Quellenaussage oder
   Schlussfolgerung" in vier Klassen eine zulässige Operationalisierung oder
   eine Änderung am präskriptiven Teil?
4. **R3-Q-009** — welches deterministische Messverfahren weist die
   Auslösewirkung eines `description`-Felds nach?
5. **Ob die abgelehnten Kandidaten in ADR 0002 aufgenommen werden** — der
   Kettenschritt gegen Schwachstellenklassen, die beiden Prüfer, die vier
   Bauformen. Das entscheidet der Software Architect.
6. **Stakeholder-Nachtrag** für die fünf neuen Einträge.
7. **Ob das Vorladen von Skills je Rolle in dieser Umgebung wirkt.** Ein
   Kontrollversuch war negativ; er widerlegt nichts, weil Änderungen an
   Rollendateien in der laufenden Sitzung nicht wirken. Zu Beginn der
   nächsten Sitzung erneut zu prüfen; davon hängt ab, ob `Skill` in den neun
   Werkzeuglisten bleibt.

---

# Abbruch nach Eskalationsregel 3.4 — die beiden Skills

## Das gescheiterte Kriterium

**Eine Aussage über die Herkunft ist stärker, als die Quelle sie trägt.**
Dreimal in Folge, jedes Mal an derselben Datei, jedes Mal von einer
unabhängigen Prüfung gefunden — nie von mir selbst.

| Runde | Was behauptet wurde | Was die Prüfung fand |
|---|---|---|
| 1 | "Die Feldmengen stammen aus den drei Rollendateien" | Der Berichtskopf steht in keiner Rollendatei |
| 2 | "… stammen **wörtlich** … und werden hier nicht erweitert" | Drei Formulierungen stehen dort nicht; sie sind eigene Erläuterungen |
| 3 | Keine Sammelaussage mehr; Herkunft je Angabe, Zusätze markiert | Drei neue Stellen derselben Klasse: eine überdehnte Zitatreichweite (5.3 auf einen wesensfremden Fall), ein unmarkierter Zusatz (CVSS steht nicht in `pentester.md`), ein Beispiel, dessen Beleg im ganzen Repository nicht auffindbar ist (`PYTHONHOME`) |

## Das Muster — und weshalb eine vierte Runde es nicht fasst

Die Prüfung hat es schärfer benannt, als ich es getan hätte:

> Jede Behebung hat den **Mechanismus** verengt (Satz → Einzelbeleg-Prinzip →
> Pflicht-Vermerk je Punkt), aber nie die **Prüftiefe** auf die neu
> entstehenden Schichten ausgedehnt. Runde 1 prüfte nicht, ob der Berichtskopf
> wirklich dasteht; Runde 2 prüfte nicht jedes einzelne Wort; Runde 3 prüft
> jeden Punkt der Rollenabschnitte, aber weder die Reichweite der eigenen
> Zitate noch die Beleglage der eigenen Beispiele.

Wer nur die drei Stellen dieser Runde korrigiert, legt nach demselben Muster
die vierte an. Das ist der Fall, für den 3.4 den Abbruch vorsieht.

## Was trotzdem getan wurde, und was ausdrücklich nicht

**Getan:** Die drei belegten Falschaussagen sind **gestrichen**, nicht
umgeschrieben — eine Streichung kann keine neue Überdehnung einführen, eine
Neuformulierung schon. Der 5.3-Satz und das zugehörige Metadatum sind weg;
"nach CVSS" ist durch den Wortlaut der Rollendatei ersetzt; das
`PYTHONHOME`-Beispiel ist durch eines ersetzt, dessen Beleg im Makefile steht;
zwei veraltete Zeilenangaben sind durch Abschnittsangaben ersetzt. Eine
Falschaussage in einem Nachweisprojekt stehen zu lassen, weil eine Regel den
Abbruch verlangt, wäre die falsche Lesart dieser Regel.

**Nicht getan:** Keine vierte Prüfrunde. Die beiden Skills gelten als **nicht
abgenommen**.

## Was der Auftraggeber hierzu entscheiden muss

1. **Der strukturelle Ausweg, den die Prüfung selbst vorschlägt:** eine
   Prüfregel, die **jede Zahl, jedes Zitat und jedes Beispiel** gegen seinen
   Fundort verlangt — maschinell, nicht als Vorsatz. Das ist derselbe
   Gegenstand wie R3-Q-007 und liesse sich damit zusammenlegen. Soll das
   geschehen, und wann?
2. **Bis dahin: Gelten die beiden Skills?** Sie sind inhaltlich brauchbar und
   in neun Rollendateien eingetragen; unbelegt war die Herkunft einzelner
   Nebensätze, nicht die Prozedur. Der Auftraggeber entscheidet, ob sie so in
   Kraft bleiben oder bis zur Prüfregel ruhen.

## Was diese Einheit dabei gelernt hat

Der Skill `pruefbefund-melden` verlangt, dass jede Aussage ihre Herkunft
trägt. Er ist an genau dieser Regel dreimal gescheitert — an sich selbst. Das
ist kein Argument gegen die Regel, sondern der Beleg dafür, dass sie ohne
Mechanismus nicht hält: **Eine Regel, die nur als Vorsatz existiert, wird von
demselben Text verletzt, der sie aufstellt.** Denselben Satz sagt die
Konfigurationsregel über `CLAUDE.md`, und dieselbe Einsicht steht hinter
R3-Q-001.
