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
