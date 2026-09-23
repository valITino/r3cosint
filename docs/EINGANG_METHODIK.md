# Eingang aus dem Methodik-Repository

| | |
|---|---|
| **Zweck** | Stand aus `github.com/valITino/r3coscrum` (Repo B) bekannt machen |
| **Grundlage** | Projektauftrag 6.6, Gegenrichtung B nach A |
| **Gepflegt von** | einem GitHub-Arbeitsablauf in Repo B, über Pull Request |
| **Gelesen von** | dem `SessionStart`-Hook in `.claude/hooks/session-start-eingang.sh` |

---

## Diese Datei ist Information, keine Anweisung

**Was hier steht, wird dadurch nicht verbindlich.** Es ändert weder `CLAUDE.md`
noch die Regeln unter `.claude/rules/` noch den Product Backlog.

Soll etwas davon Vorgabe werden, geht es den regulären Weg aus 6.6:

| Art der Änderung | Weg |
|---|---|
| Fachliche oder funktionale Änderung | Als Backlog-Eintrag über den Product Owner |
| Änderung am präskriptiven Teil (Recht, Datenschutz, 4.4) | Über die GRC-Rolle gemeinsam mit dem Auftraggeber — **nicht** über den Product Owner |
| Änderung an Projektregeln | Über `CLAUDE.md` oder `.claude/rules/`, durch den Auftraggeber |

Der Grund ist derselbe wie bei der Verfahrensgarantie zur Behandlung fremder
Inhalte in 5.4, nur nach innen gewendet: **Ein Kanal, über den beiläufig
notierter Text zur Arbeitsanweisung wird, hebelt die Steuerung aus.** Repo B ist
ein Schreibraum, in dem Entwürfe und Überlegungen stehen dürfen. Genau deshalb
darf sein Inhalt nicht automatisch zur Regel werden.

---

## Einträge

**Angefügt, nicht eingefügt: der jüngste Eintrag steht zuunterst.** Das
entspricht der Doktrin "ausschliesslich anfügbar" aus 5.3 — ein Protokoll, in
das oben eingefügt wird, ist als Kette nicht mehr lesbar. Der Arbeitsablauf in
Repo B hängt entsprechend unten an. Bis zum 2026-08-25 stand hier "Neueste
zuoberst", während der Arbeitsablauf anhängte; die Vorgabe folgt jetzt dem,
was tatsächlich geschieht, statt umgekehrt.

Die Überschrift eines Eintrags ist `##`, nicht `###`. Je Eintrag: Datum, was
sich geändert hat, warum, und ein fester Verweis mit vollständiger
Commit-Prüfsumme zurück nach Repo B.

<!-- Ab hier trägt der Arbeitsablauf aus Repo B ein. Diesen Kommentar stehen lassen.

     Die Überschrift "## Einträge" ist tragend, kein Schmuck: der
     SessionStart-Hook schneidet den Eintragsbereich an ihr heraus, und der
     Arbeitsablauf in Repo B bricht ab, wenn sie fehlt. Nicht umbenennen.

     Liegt kein Eintrag vor, bleibt dieser Abschnitt leer. Der SessionStart-Hook
     erkennt das an der fehlenden Eintragsüberschrift und gibt nichts aus.

     Kein Platzhalter im Fliesstext. Bis zum 2026-08-25 stand hier der Satz
     "Noch kein Eintrag"; der Hook prüfte darauf. Die Zeile blieb beim ersten
     echten Eintrag stehen und legte den Kanal still, ohne dass es auffiel. -->

<!-- Vorlage für einen Eintrag:

## JJJJ-MM-TT — <kurzer Titel>

- **Was:** <was sich in Repo B geändert hat>
- **Warum:** <Begründung aus Repo B>
- **Verweis:** https://github.com/valITino/r3coscrum/blob/<40-stellige-Prüfsumme>/<Pfad>
- **Wirkung auf Repo A:** keine, bis der reguläre Weg oben beschritten ist

-->

## 2026-08-20 — Änderung an Methodik und Sprints

**Was sich geändert hat:**

- Neu: `methodik/arbeitsprodukte.md`
- Neu: `methodik/entscheide.md`
- Neu: `methodik/re-prozess.md`
- Neu: `methodik/scrum-aufbau.md`
- Neu: `sprints/.gitkeep`

**Warum:**

> 97891e9 — chore: Grundgeruest Methodik-Repository
> Co-Authored-By: Claude <noreply@anthropic.com>
> Claude-Session: https://claude.ai/code/session_01M9wGvPfXAXFsLd7kNSBAQC
>
> 3b22f49 — docs: Methodik-Dokumente aus dem Projektauftrag abgeleitet
> re-prozess.md: Konfiguration des RE-Prozesses nach IREB (drei Facetten,
> partizipativer Prozess mit praeskriptivem Teilbereich, Begruendung).
> arbeitsprodukte.md: gefuehrte RE-Arbeitsprodukte mit Zweck,
> Verantwortung, Lebensdauer und Verweisen ins Produkt-Repository.
> scrum-aufbau.md: Sprintlaenge, Ereignisse mit Timeboxes,
> Verantwortlichkeiten, Ready gegenueber Done, Sprintumfang nach
> Prueffkapazitaet.
> entscheide.md: methodische Entscheide mit Begruendung aus dem
> Aenderungsprotokoll, Abschnitt 8.
>
> Verweise auf das Produkt-Repository als PERMALINK-Platzhalter, die die
> Automatik spaeter mit vollstaendiger Commit-Pruefsumme fuellt. Nicht im
> Projektauftrag Belegtes ist als offen markiert.
>
> Co-Authored-By: Claude <noreply@anthropic.com>
> Claude-Session: https://claude.ai/code/session_01M9wGvPfXAXFsLd7kNSBAQC
>

**Nachweis:** https://github.com/valITino/r3coscrum/commit/baa83daa0bb309b5deb1041965856b1dbc16522b

## 2026-08-21 — Änderung an der Methodik

**Was sich geändert hat:**

- Geändert: `methodik/arbeitsprodukte.md`
- Geändert: `methodik/entscheide.md`
- Geändert: `methodik/re-prozess.md`
- Geändert: `methodik/scrum-aufbau.md`

**Warum:**

> b2fa8e7 — methodik: Platzhalter durch feste Verweise aufgeloest
> 71 Platzhalter, 69 aufgeloest mit dem Verweis aus nachweise/NACHWEISE.md
> (Stand 4c64300e9ec00fd1068964e14c2666c631d00dfa): Projektauftrag bei
> Commit 3f939cea7749d9fbe1df9a7bbc90ff94efe95cb6, Abschnittsname als
> Linktext. 2 bleiben offen, weil das Nachweisverzeichnis keinen Eintrag
> zu prototype/OSINT_Plattform_Demo.html fuehrt; nichts konstruiert.
>
> Co-Authored-By: Claude Fable 5 <noreply@anthropic.com>
> Claude-Session: https://claude.ai/code/session_019kpqfSMsFSuCS7DFFt1cw7
>

**Nachweis:** https://github.com/valITino/r3coscrum/commit/995b4cb6c9fce416978294594f2a9012c4039065

## 2026-09-01 — Änderung an der Methodik

**Was sich geändert hat:**

- Geändert: `methodik/arbeitsprodukte.md`
- Geändert: `methodik/entscheide.md`
- Geändert: `methodik/re-prozess.md`
- Geändert: `methodik/scrum-aufbau.md`

**Warum:**

> e43b9a7 — docs(E5): Regel angeglichen, Methodik auf den Ist-Stand, Anfuehrungszeichen
> Full-Review vom 2026-08-25 auf Weisung des Auftraggebers; der
> Repo-B-Anteil von E5 damit vorgezogen.
>
> - .claude/rules/versionierung-und-nachweisfluss.md an die gleichnamige Regel
>   des Produkt-Repositories angeglichen (E5): massgeblich ist allein die
>   E-Mail-Adresse 41898282+github-actions[bot]@users.noreply.github.com, der
>   user.name darf der sprechende Name des Arbeitsablaufs sein. Zwei
>   gleichnamige Regeln sagten Verschiedenes. Im Bestand der zweite Commit mit
>   falscher Identitaet nachgetragen (5783d0930b63, entstanden nach Erlass der
>   Regel, weil der erzeugende Arbeitsablauf erst am 2026-08-25 korrigiert
>   wurde); der frueher vermerkte Korrekturbedarf im Produkt-Repository ist als
>   erledigt gefuehrt (47dd3086f1d6).
> - methodik/arbeitsprodukte.md: Stakeholderliste, Glossar, Kontextmodell und
>   Product Backlog sind seit Schritt 3 vorhanden -- "noch nicht angelegt" durch
>   feste Verweise mit 40-stelliger Pruefsumme ersetzt; beide ueberholten
>   [OFFEN]-Punkte aufgeloest; die PERMALINK-Platzhalter zur Prototyp-Demo durch
>   den festen Verweis ersetzt (Nachweisluecke seit 2026-08-21 geschlossen).
> - methodik/re-prozess.md, methodik/scrum-aufbau.md: Schritt 3 ist erledigt und
>   freigegeben, die DoD liegt vor; offen bleiben Facettenbeurteilung,
>   Befehls-Bestaetigung und Hook-Erzwingung (R3-Q-001) -- praezisiert statt
>   pauschal offen.
> - UEBERGABE.md: Guillemets durch gerade Anfuehrungszeichen ersetzt (Regel
>   dieses Repositories; der Verstoss stammte aus der Einheit E2 vom 2026-08-25).
>
> Co-Authored-By: Claude <noreply@anthropic.com>
> Claude-Session: https://claude.ai/code/session_01Gsya3qdHFTWV5i4BBhGxYZ
>
> 0eda63e — docs: V9 und V10 als methodische Entscheide, Uebergabe zur DoD-Kette
> V9 -- Steht eine Abwaegung zwischen Laufzeit oder Bequemlichkeit und
> Beweiskraft, entscheidet die Beweiskraft. Woertliche Weisung des
> Auftraggebers vom 2026-08-31, erstmals angewandt auf O-13 des
> Architekturentscheids 0002.
>
> V10 -- Eine Abgrenzung ist keine Erlaubnis. Entstanden aus einem belegten
> eigenen Fehler: Der Kopfabschnitt des Makefiles grenzte einen Angriffsweg
> ab, der mit einer Zeile zu schliessen war. Der Entscheid gehoert hierher
> und nicht nur in den Architekturentscheid, weil er jede Stelle betrifft,
> an der eine Abgrenzung geschrieben wird.
>
> Uebergabevermerk mit den drei Commits des Produkt-Repositories, jeweils
> ueber die vollstaendige Pruefsumme verwiesen.
>
> dcb59db — docs: S6 und S7 -- Umgang mit fremdem Material, Grenze zwischen Rolle und Skill
> S6 -- Fremdes Material wird nie woertlich uebernommen. Uebernommen werden
> Bauweise, Gliederung und Einsicht; der Text ist unserer und wird vor der
> Aufnahme gegen unsere Bauvorschriften geprueft. Herkunft ueber die
> vollstaendige 40-stellige Pruefsumme. Keine Marktplatz- oder
> Plugin-Abhaengigkeit, weil ein Bestand, der sich unter uns aendert, mit der
> Verfahrensgarantie Reproduzierbarkeit unvereinbar ist.
>
> S7 -- Ein Skill entsteht nur, wenn mehrere Rollen dieselbe Prozedur gleich
> ausfuehren. Der fremde Bestand fuehrt Rollen als Skills; damit waere weder
> abbildbar, dass der Pentester nicht schreiben darf, noch dass Pruefung und
> Umsetzung auf verschiedenen Modellen laufen.
>
> Neuer offener Punkt: Herkunftsvermerk bei fehlendem Rechteinhaber. Die
> Lizenz des angebundenen Bestands ist MIT, ihre Urheberrechtszeile nennt
> aber niemanden, und dreizehn Dateien fuehren Inhalte aus einem dritten
> Projekt weiter, eine davon ohne Lizenzangabe. Fachlich vorzubereiten durch
> [Gekuerzt: 53 weitere Zeilen. Vollstaendig im Nachweis-Commit.]

**Nachweis:** https://github.com/valITino/r3coscrum/commit/833e89383176d61dee59e7e059a9b55f683bd35c

## 2026-09-07 — Änderung an der Methodik

**Was sich geändert hat:**

- Geändert: `methodik/entscheide.md`

**Warum:**

> 3033352 — docs(R3-Q-001): O-24 als V14 eingetragen, Uebergabe zur O-24-Einheit, O-25 als offener Punkt
> Methodischer Anteil der Einheit vom 2026-09-03 im Produkt-Repository
> (Commit d96e3970b782c563fe8419cfc2c72200a85e6ec0): Entscheid des
> Auftraggebers zu O-24 als V14; Uebergabevermerk mit dem erneuten Abbruch
> nach 3.4; O-25 (Messumfang und Trennschaerfe maschinell erzwingen) als
> offener Punkt.
>
> Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>
> Claude-Session: https://claude.ai/code/session_01U7CismnmSgiveyY64ynJ15
>
> c8c3e79 — docs(R3-Q-001): O-25 als V15 eingetragen, Uebergabe zur O-25-Einheit, O-26 als offener Punkt
> Methodischer Anteil der Einheit "O-25 umsetzen" (Produkt-Repository, Commit
> ce8ed8a0487d6b7dc8b2f805d3110996fd50e765): V15 (eine Pruefung ist erst dann
> Beleg, wenn sie ihre eigene Verneinung erkennt), O-25 geschlossen, O-26
> vorgelegt (Praedikatbindung, Schluessel- und Grammatikdeckung,
> Abnahmekriterium), Uebergabevermerk mit dem erneuten Abbruch nach 3.4.
>
> Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>
> Claude-Session: https://claude.ai/code/session_01U7CismnmSgiveyY64ynJ15
>
> 2674ad6 — docs(R3-Q-001): O-26 als V16 eingetragen, Uebergabe zur O-26-Einheit (Runden 9 bis 11, Abbruch nach 3.4), O-27 als offener Punkt
> Methodischer Anteil der Einheit vom 2026-09-06/07 im Produkt-Repository
> (12402c82a11a5a0b7f6bb86c7b614d7580b68c72): Entscheid des Auftraggebers
> zu O-26 als V16 mit Begruendung und belegter Grenze; O-26 geschlossen,
> O-27 (Deckung am Gegenstand fuer Pfade und Grammatik oder
> Abnahmekriterium auf falsches Gruen am Gate beziehen) als offener Punkt;
> Uebergabevermerk mit drei Regelvorschlaegen (Sollmenge aus dem Gegenstand,
> vorab festgelegter Ausgang des dritten Versuchs, Deckungen fail-closed).
>
> Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>
> Claude-Session: https://claude.ai/code/session_01U7CismnmSgiveyY64ynJ15
>
> 0b0fbef — docs(R3-Q-001): O-27 entschieden (Wahl am 2026-09-07 an den Koordinator delegiert), Nachtrag zur Uebergabe, Merge empfohlen
> Wortlaut des Auftraggebers: "Dann wähle den besten und korrektesten Weg
> aus, ich vertraue dir und deiner Expertise." Gewaehlt: Weg (a) und (b)
> zusammen in einer Einheit, Runde 12 als letzte Fremdmutationsrunde;
> Umsetzung in der naechsten Sitzung nach dem Merge. Empfehlung des
> Koordinators geaendert auf "jetzt mergen"; der Merge im
> Produkt-Repository ist die foermliche Freigabe der Entscheidpunkte E-A
> bis E-K, die Abnahme des Gates folgt nach Runde 12.
>
> Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>
> Claude-Session: https://claude.ai/code/session_01U7CismnmSgiveyY64ynJ15
>

**Nachweis:** https://github.com/valITino/r3coscrum/commit/2ec4bc2047d0cd940f38481277433086c69b13be

## 2026-09-08 — Änderung an der Methodik

**Was sich geändert hat:**

- Geändert: `methodik/entscheide.md`

**Warum:**

> 2652c3d — docs(R3-Q-001): O-27 als V17 eingetragen, Uebergabe 2026-09-07
> - methodik/entscheide.md: neuer Entscheid V17 -- die Sollmenge einer Deckung
>   wird aus dem Gegenstand selbst erhoben statt aus einer Aufzaehlung im Text,
>   jede Deckung ist fail-closed, das Abnahmekriterium ist auf das falsche
>   Gruen am Pruefling bezogen, und die Zahl der Pruefrunden wird vorab
>   begrenzt. Die Begruendungsspalte nennt beide Grenzen, die in derselben
>   Einheit sichtbar wurden.
> - methodik/entscheide.md: O-27 von [OFFEN] auf [ERLEDIGT 2026-09-07];
>   festgehalten ist, dass Teil 1 des Abnahmekriteriums erfuellt ist und
>   Teil 2 nicht.
> - UEBERGABE.md: Vermerk zur Arbeitseinheit vom 2026-09-07/08 mit dem
>   methodischen Anteil.
>
> Verweise auf das Produkt-Repository ueber die 40-stellige Commit-Pruefsumme
> 71596aae9b6fd20324c7e16863ca18a16b57794a.
>
> Co-Authored-By: Claude Opus 5 <noreply@anthropic.com>
> Claude-Session: https://claude.ai/code/session_01FzfSCQbnf58zYDL4NcSgvB
>

**Nachweis:** https://github.com/valITino/r3coscrum/commit/9c28499252ab3f42a96dc43bf096c3a6353ce0cb

## 2026-09-22 — Änderung an der Methodik

**Was sich geändert hat:**

- Geändert: `methodik/entscheide.md`

**Warum:**

> 3671645 — docs(R3-Q-001): Abnahme des DoD-Gates in V17 und O-27 eingetragen, Uebergabe 2026-09-21
> Methodischer Anteil der Arbeitseinheit vom 2026-09-21 im Produkt-Repository
> (e5bab959aa4886eefc7983ce23916bbd798d8a83, dort
> docs/uebergaben/2026-09-21_r3-q-001-abnahme-eingetragen-e4-dor.md):
>
> - methodik/entscheide.md: V17 um die am 2026-09-08 durch Merge des Pull
>   Requests #15 erteilte Abnahme des Pruefmittels ergaenzt (Merge-Commit
>   9870b0d115b8ef330a7c19777af5741093e4f0e9, ohne Auflagen; Teil 2 des
>   Abnahmekriteriums nicht erfuellt, getragen hat der vorab festgelegte Weg;
>   nicht umfasst: O-25, D20/O-15, R3-Q-005, Freigabe des Grundgeruests); der
>   seit dem 2026-09-07 erledigte Punkt O-27 um den Entscheid ergaenzt.
> - UEBERGABE.md: Vermerk zur Einheit (Abnahme aktenkundig, E4 als R3-Q-010
>   auf der Definition of Ready, Zerlegung E4.1 bis E4.3, E3 eigene Einheit).
>
> Verweise auf das Produkt-Repository ausschliesslich ueber die 40-stellige
> Commit-Pruefsumme.
>
> Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>
> Claude-Session: https://claude.ai/code/session_01HcsiiLQRbfnfArGkF9TqDg
>
> 2b9a1a2 — docs(R3-Q-001): Weisung vom 2026-09-22 als V18, V19 und S8 festgehalten; R3-Q-010-Freigabe erledigt; Uebergabe 2026-09-22
> Lesart zu 3.4 (V18), Lesart zu R1 der Definition of Ready (V19, delegierter
> Entscheid) und die Bereitstellung eines Pruefmittels der Kette durch einen
> versionierten SessionStart-Hook (S8) eingetragen; Freigabe des Umfangs von
> R3-Q-010 und Schnitt E4.1 bis E4.3 unter den offenen Punkten als erledigt
> gefuehrt; Uebergabevermerk. Verweise auf das Produkt-Repository mit
> 40-stelliger Pruefsumme 13a23b98d0ed5c4e5531ddfb01f43a6b91f4d8a8.
>
> Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>
> Claude-Session: https://claude.ai/code/session_01HcsiiLQRbfnfArGkF9TqDg
>
> ab4ef02 — docs(R3-Q-001): Nachtrag zu S8 (Git-Historie bei flachem Klon) und Uebergabe 2026-09-22 (2)
> Auf Delegation des Auftraggebers: Nachholen der Git-Historie beim
> Sitzungsstart als zweiter versionierter SessionStart-Hook im
> Produkt-Repository (bb6c1965fa271f7f1d28cc57d3c0fc192ad8cb15); Pull Request
> #17 dort eroeffnet.
>
> Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>
> Claude-Session: https://claude.ai/code/session_01HcsiiLQRbfnfArGkF9TqDg
>
> ecd60f9 — docs(R3-Q-001): O-25 als entschieden statt als offen gefuehrt (Codex-Review #10, P2); Nachtrag im Uebergabevermerk
> Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>
> Claude-Session: https://claude.ai/code/session_01HcsiiLQRbfnfArGkF9TqDg
>
> b3379e2 — docs: Nachtrag zum Codex-Review am Pull Request #17 des Produkt-Repositories (S8, Uebergabevermerk 2026-09-22 (2))
> Vier Befunde an den beiden Starthooks behoben und in drei Runden nachgeprueft;
> Zusicherung "Zweige unberuehrt" erst mit Refspec und leerer Refmap, Lehre
> festgehalten; Verweis auf Commit 1d9da15e4617555f73a60a49f6dbc968cb166a87.
>
> Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>
> Claude-Session: https://claude.ai/code/session_01HcsiiLQRbfnfArGkF9TqDg
>

**Nachweis:** https://github.com/valITino/r3coscrum/commit/494409cf431e447ef26ce18f99832e467ec8a08d

## 2026-09-23 — Änderung an der Methodik

**Was sich geändert hat:**

- Geändert: `methodik/entscheide.md`

**Warum:**

> 9d19100 — docs: Abnahme der Starthooks durch Merge (S8), Uebergabevermerk 2026-09-22 (3): Nachweisfluss am Regelwerk gescheitert, dritter Codex-Lauf
> Verweis auf Commit 3c712292c74c14c8d7934f1edcfbbe3deceaad84 des Produkt-Repositories.
>
> Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>
> Claude-Session: https://claude.ai/code/session_01HcsiiLQRbfnfArGkF9TqDg
>

**Nachweis:** https://github.com/valITino/r3coscrum/commit/b53e481abd7c13537f4a76b87b4842befeef6f97

## 2026-09-23 — Änderung an der Methodik

**Was sich geändert hat:**

- Geändert: `methodik/entscheide.md`

**Warum:**

> 30864e9 — docs: S9 (Pruefmittel vor Gate-Aenderung, belegte Luecken als Soll) und Uebergabevermerk 2026-09-23 (1): E4.1 gebaut (R3-Q-010)
> Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>
> Claude-Session: https://claude.ai/code/session_01UvFLTyfJxwkoCTwXfEQiud
>

**Nachweis:** https://github.com/valITino/r3coscrum/commit/cb838ecd35baba30fb04ab64300e501ab55ed0b6
