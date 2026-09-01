---
name: pruefbefund-melden
description: "Wird gebraucht, sobald eine Prüfrolle einen Befund meldet oder einen Prüfbericht abschliesst — Static Software Tester, Dynamic Software Tester und Pentester. Legt die Pflichtfelder je Befund fest, verlangt Negativbefunde und das Protokoll der ausgeführten Befehle, und trennt Beleg von Schlussfolgerung."
metadata:
  anforderung: R3-C-007
  auftrag: "3.4 (Verifikation und Eskalation), 5.3 (Negativbefunde)"
  adr: docs/adr/0001-rollenmodell.md
---

# Prüfbefund melden

> **Stand 2026-08-31.** Die drei Herkunftsangaben, die staerker waren als
> ihre Quelle, sind entfernt. Der maschinell pruefbare Teil dieser Klasse
> wird seit dem 2026-08-31 von `scripts/belege-pruefen.sh` geprueft; dieser
> Skill laeuft dort ohne Befund. Was **nicht** maschinell pruefbar ist —
> ob der Inhalt am genannten Fundort die Behauptung auch traegt —, benennt
> das Skript selbst und bleibt Sache des menschlichen Reviews.
> Vorgeschichte: `docs/uebergaben/2026-08-31_skill-repository-ausgewertet.md`.

## Wann diese Prozedur gilt

Immer dann, wenn eine der drei Prüfrollen einen Befund meldet oder einen
Prüfbericht abschliesst: Static Software Tester, Dynamic Software Tester,
Pentester. Der Vulnerability Manager ist der Empfänger, nicht der Absender —
er bewertet, was hier gemeldet wird.

Sie gilt nicht für Umsetzungsrollen. Wer implementiert, prüft seine eigene
Arbeit nicht (3.4); wer nicht prüft, meldet auch keinen Prüfbefund.

## Der Kernablauf

1. **Massstab benennen, bevor geprüft wird.** Wogegen wird geprüft — welches
   Abnahmekriterium, welcher Abschnitt des Projektauftrags, welcher ADR? Ein
   Befund ohne Massstab ist eine Meinung.
2. **Prüfen und dabei mitschreiben.** Jede ausgeführte Befehlszeile mit ihrem
   Rückgabewert. Nicht am Ende aus dem Gedächtnis rekonstruieren.
3. **Je Befund die Pflichtfelder ausfüllen** (siehe unten und
   `references/befundfelder.md`). Fehlt ein Feld, fehlt der Befund.
4. **Negativbefunde ausdrücklich aufführen.** Was geprüft und ohne
   Beanstandung war, steht im Bericht. Das ist keine Höflichkeit, sondern der
   Grundsatz aus 5.3, der für die beiden Protokollspuren des Produkts gilt und
   für den Prüfbericht genauso.
5. **Benennen, was nicht geprüft wurde**, und weshalb. Eine Prüfung, deren
   Grenzen unbenannt bleiben, wird als vollständig gelesen.
6. **Entscheid abgeben:** "bestanden" oder "nicht bestanden", unter Nennung
   des blockierenden Kriteriums. Kein "weitgehend", kein "im Wesentlichen".
7. **Bei dreimaligem Scheitern am gleichen Kriterium** nicht weiterprobieren,
   sondern den Textbaustein für die Übergabedatei nach 3.3 liefern (3.4).

## Pflichtfelder je Befund

Für alle drei Rollen gleich:

| Feld | Inhalt |
|---|---|
| Datei und Zeile | Wo der Befund sitzt. Kein Verzeichnis, keine Datei ohne Zeile |
| Was falsch ist | Ein Satz, der den Mangel benennt, nicht die Lösung |
| Beleg | Die ausgeführte Befehlszeile mit Rückgabewert, oder die zitierte Belegstelle |
| Blockierend oder nicht | Und woran das hängt |

Je Rolle kommen Felder hinzu; die Aufstellung steht in
`references/befundfelder.md`.

**Keine Sammelurteile.** "Mehrere Stellen behandeln Fehler unsauber" ist kein
Befund, sondern die Ankündigung von Befunden, die niemand geschrieben hat.

## Jede Aussage trägt ihre Herkunft

Diese Regel ist der Grund, weshalb es diesen Skill gibt. Sie spiegelt die
Bauvorschrift des Produkts — jede Zeile ist entweder Quellenaussage oder
Schlussfolgerung des Modells und als solche gekennzeichnet
(`.claude/rules/produktionscode.md`) — auf die Prüfarbeit:

| Kennzeichnung | Was sie bedeutet | Was sie verlangt |
|---|---|---|
| **ausgeführt belegt** | Der Befehl lief, das Ergebnis steht im Bericht | Befehlszeile und Rückgabewert |
| **gelesen** | Im Bestand nachgeschlagen | Datei und Zeile, am Original geprüft |
| **geschlossen** | Aus Belegen abgeleitet, nicht selbst beobachtet | Die Belege, aus denen geschlossen wurde |
| **offen** | Vermutet, nicht geprüft | Gehört unter "nicht geprüft", nie unter "Befund" |

Eine Zeilennummer, die niemand nachgeschlagen hat, ist kein Beleg. Wird eine
Angabe tragend — sie begründet einen blockierenden Befund oder eine
Streichung —, wird sie vor der Meldung am Original nachgeschlagen.

## Was nicht in einen Prüfbericht gehört

- **Eine eigene Risikoeinstufung des Pentesters.** Er meldet mit CWE-Bezug und
  übergibt an den Vulnerability Manager; die Bewertung nach CVSS liegt dort
  (Projektauftrag 4.2, so auch `.claude/agents/pentester.md` und
  `.claude/agents/vulnerability-manager.md`).
- **Die Behebung.** Prüfrollen melden Befunde, sie beheben sie nicht. Ein
  Vorschlag zur Behebung ist zulässig und als Vorschlag zu kennzeichnen.
- **Bewegliche Werkzeugangaben** wie "Version 1.x" oder "aktuelle Fassung".
  Genannt werden Befehlszeile und Rückgabewert; die Reproduzierbarkeit ist
  Bauvorschrift (5.4).
- **Der Nachweis, dass viel geprüft wurde.** Die Zahl der Prüfschritte belegt
  nichts. Der Massstab belegt.

## Weiterführend

| Datei | Wann laden |
|---|---|
| `references/befundfelder.md` | Sobald der Bericht geschrieben wird — Feldmenge je Rolle, Berichtskopf, zwei ausgeführte Beispiele |
