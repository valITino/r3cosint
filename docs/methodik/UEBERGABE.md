# Übergaben

Vermerke je Arbeitseinheit in diesem Repository, neueste zuoberst.

---

## 2026-10-22 — D1 und C3: Abnahme von Posten 4 und 5 eingetragen; Posten 2, 6 und Teil von Posten 7 am Prototyp-Gate gebaut (R3-Q-010); Weisungen vom 2026-10-22

Produkt-Repository, Zweig ccr-0cbb4387-oe1i3c. Übergabe: [docs/uebergaben/2026-10-22_c3-prototyp-gate.md](https://github.com/valITino/r3cosint/blob/b19c7b0cb2b701be3dbe646d2cf6c892e4fb3810/docs/uebergaben/2026-10-22_c3-prototyp-gate.md). Commits: [`529ce5a568be573cd36c853967f9739893328cd2`](https://github.com/valITino/r3cosint/commit/529ce5a568be573cd36c853967f9739893328cd2) (D1), [`b19c7b0cb2b701be3dbe646d2cf6c892e4fb3810`](https://github.com/valITino/r3cosint/commit/b19c7b0cb2b701be3dbe646d2cf6c892e4fb3810) (C3), [`4a27245973ecbbc5d29b02d0bdfb4d8fa38935a7`](https://github.com/valITino/r3cosint/commit/4a27245973ecbbc5d29b02d0bdfb4d8fa38935a7) (Nachweisverzeichnis).
- Merge des Pull Requests #27 (2026-10-21) als Abnahme von Posten 4 und 5 in ADR 0002, Abschnitt 10 eingetragen; Merge des Pull Requests #17 dieses Repositories (2026-10-21) vermerkt; Weisung vom 2026-10-21 ("Weiter mit Abschnitt D, D1 und dann C3") und Festlegung für C3 in ADR 0002, 6.13 festgehalten.
- Posten 2 (L05 bis L08), Posten 6 (L23, L24) und der Teil von Posten 7 am Prototyp-Gate gebaut; Prüfmittel 479 Fälle, 66 Mutationen, 39 Fallklassen, beide Modi Rückgabewert 0; Verifikation durch Static und Dynamic Software Tester auf einem anderen Modell ohne blockierenden Befund.
- Register: SR-004 bewertet (CVSS 3.1 Basiswert 4.7), SR-003 Teilstand (Prototyp-Teil in Behebung, main-Gate-Teil offen), neu SR-005 und SR-006 (vorbestehende Lücken, Posten 8 und 9); Posten 8 bis 10 mit C4 terminiert.
- Weisungen vom 2026-10-22 (zweiter Formweg, Wortlaut in ADR 0002, 6.13, Status-Block): Prozess-Schnitt als nächste Einheit; dieses Repository wird eingefaltet, nur lesbar archiviert und nach einer Übergangsfrist vom Auftraggeber gelöscht.
- Abnahme von Posten 2, 6 und des Teils von Posten 7 am Prototyp-Gate durch Merge des Pull Requests im Produkt-Repository; dieser Vermerk wird mit dem Merge des zugehörigen Pull Requests hier bestätigt.

---

## 2026-10-21 — Abschnitt C: Abnahme von Posten 1 eingetragen, Posten 4 und 5 unter R3-Q-010 gebaut, Schwachstellenregister angelegt

Produkt-Repository, Zweig ccr-0cbb4387-oe1i3c. Übergabe: [docs/uebergaben/2026-10-21_abschnitt-c-posten-4-5.md](https://github.com/valITino/r3cosint/blob/dd654f0a8d22254926e52bce6a3be98f9ad7c98a/docs/uebergaben/2026-10-21_abschnitt-c-posten-4-5.md). Commits: [`0c8f149f235afffa1f85df21352d9fa09d283a5e`](https://github.com/valITino/r3cosint/commit/0c8f149f235afffa1f85df21352d9fa09d283a5e) (C1), [`dd654f0a8d22254926e52bce6a3be98f9ad7c98a`](https://github.com/valITino/r3cosint/commit/dd654f0a8d22254926e52bce6a3be98f9ad7c98a) (C2 mit Übergabe), [`c84e2a36b22cd328e1887d6fc317a023ddccb639`](https://github.com/valITino/r3cosint/commit/c84e2a36b22cd328e1887d6fc317a023ddccb639) (Nachweisverzeichnis).
- Merge des Pull Requests #26 (2026-10-16) als Abnahme von Posten 1 in ADR 0002, Abschnitt 10 eingetragen; Merge des Pull Requests #16 dieses Repositories (2026-10-21) vermerkt.
- Weisung vom 2026-10-21 (zweiter Formweg) mit delegierten Entscheiden in ADR 0002, 6.13 festgehalten.
- Posten 5 (beide PreToolUse-Gates) und Posten 4 (main-Gate) gebaut; Prüfmittel 447 Fälle, 49 Mutationen, 36 Fallklassen; Verifikation in einer Erstprüfung und vier Delta-Runden durch Static und Dynamic Software Tester auf einem anderen Modell.
- Schwachstellenregister angelegt (SR-001 bis SR-004); Posten 6 und 7 neu erfasst, nicht gebaut; C3 und C4 nach Projektauftrag 3.3 nicht begonnen.
- Abnahme von Posten 4 und 5 durch Merge des Pull Requests im Produkt-Repository; dieser Vermerk wird mit dem Merge des zugehörigen Pull Requests hier bestätigt.

---

## 2026-10-14/15 — Abschnitt B: Abnahme von R3-Q-011 eingetragen, Posten 1 unter R3-Q-010 gebaut

Sitzung vom 2026-10-14 (Sitzungsauftrag Abschnitt B, Schritte B1 bis B6; zwei
Unterbrüche durch das Nutzungslimit, Abschluss am 2026-10-15). Hauptteil im
Produkt-Repository, dort `docs/uebergaben/2026-10-14_abnahme-r3-q-011-posten-1.md`
([`445efc9751e3`](https://github.com/valITino/r3cosint/commit/445efc9751e3e37773b11cb29922b52d92b4d374)); Nachweisverzeichnis
[`7abbcd4c3ee6`](https://github.com/valITino/r3cosint/commit/7abbcd4c3ee69c3f1c9cafb04b63f177a1a7f09f).

### Erledigt

- **B1 — Abnahme von R3-Q-011 eingetragen** (Commit
  [`721c0f23a902`](https://github.com/valITino/r3cosint/commit/721c0f23a9024c516c3ca0760e2d27b12553d985)):
  Merge des Pull Requests #25 des Produkt-Repositories (Merge-Commit
  [`0b6d59625423`](https://github.com/valITino/r3cosint/commit/0b6d59625423f53fcd0e8b3f22150d97ef2a17f4))
  und hier Pull Request #15 (Merge-Commit
  [`d349f3ce4bba`](https://github.com/valITino/r3coscrum/commit/d349f3ce4bba8db8f919c188849acc452190ac44)),
  je ohne Kommentare und Reviews; fünf der sechs Kriterien; nicht umfasst
  `R3-Q-011_regel_im_startkontext` (Gegenprobe nicht durchgeführt) und die
  Terminierung von `Skill` (nicht entschieden).
- **B2 — Posten 1 unter R3-Q-010 gebaut und verifiziert** (Commit
  [`5b3f3181b04a`](https://github.com/valITino/r3cosint/commit/5b3f3181b04a7575930f876d0682079d9262ad88)):
  main-Gate vergleicht Ziele und den Namen hinter -b/-B nach vier lexikalischen
  Schritten; L01 bis L04 geschlossen; Grenzen GM-5 bis GM-8 benannt; Prüfmittel
  318 Fälle, 26 Mutationen, 28 Fallklassen; drei Baurunden, je verifiziert durch
  Static und Dynamic Software Tester auf dem anderen model-Feld. Neu erfasst, nicht
  gebaut: Posten 4 (main-Gate) und Posten 5 (beide Gates, Umgehung bei grosser
  Eingabe).
- **B5/B6** (Commit [`445efc9751e3`](https://github.com/valITino/r3cosint/commit/445efc9751e3e37773b11cb29922b52d92b4d374)):
  Backlog-Sammelposten, CLAUDE.md, Nachweise, Übergabe.

### Nicht begonnen

- **B3 und B4 (Posten 2 und 3)**, nach Projektauftrag 3.3: Posten 2 wäre die nächste
  Änderung am Prototyp-Gate und zöge den Prototyp-Teil von Posten 5 nach sich; die
  Einordnung von Posten 4 und 5 legt der Auftraggeber fest (Empfehlung des Software
  Architects: Posten 5, dann Posten 2, Posten 3).

### Was methodisch bemerkenswert ist

- **Ruhender Arbeitsbaum:** Prüfmittel-Mutationsläufe und D19 melden jede Änderung einer
  versionierten Datei während des Laufs; zwei Läufe fielen, weil eine andere Rolle
  parallel im ADR schrieb. Schreibende Rollen und Läufe werden seither getrennt.
- **Vorgaben als Fehlerquelle:** Mehrere blockierende Befunde der statischen Prüfung
  gingen auf Vorgaben des Koordinators zurück (falsche Zuordnung zu einem ADR-Punkt,
  behauptete Prüfung des Prüfmittels, mehrdeutige Zuordnung von Einheiten).
- **Zählung nach 3.4:** Der Static Software Tester zählte drei Kriterien bis zum
  zweiten Scheitern; die dritte Baurunde war die letzte und bestand.
- **Die Hooks wirkten wieder nicht;** Starthooks und `make dod` liefen von Hand. Der
  Harness gab den Zweignamen vor (ccr-0cbb4387-oe1i3c statt claude/<Name>).

### Offen (Auftraggeber)

Gegenprobe `R3-Q-011_regel_im_startkontext`; Terminierung von `Skill`; Berichtigung
"6.1.2"; Einordnung von Posten 4 und 5, CVSS-Bewertung von Posten 5 durch den
Vulnerability Manager, Anlage eines Schwachstellenregisters; Abnahme von Posten 1 durch
Merge der Pull Requests (nicht umfasst Posten 2 bis 5).

---

## 2026-09-25 — E3.3: Merges eingetragen; Versuche, Prüfsatz, Lauf (R3-Q-011)

Einheit vom 2026-09-25, Abschnitt A des Fahrplans, Schritte A0 bis A6. Hauptteil im
Produkt-Repository, dort `docs/uebergaben/2026-09-25_e3-3.md`
([`7e69fafacc5a`](https://github.com/valITino/r3cosint/commit/7e69fafacc5af23ef174d87445485b782d03dceb)); Nachweisverzeichnis
[`fac7e3dcc33b`](https://github.com/valITino/r3cosint/commit/fac7e3dcc33b5cda8722fecf4d339b7b36a6fe5f).

### Erledigt

- **Merges eingetragen** (Commit [`eab40ec2c2ca`](https://github.com/valITino/r3cosint/commit/eab40ec2c2cae26bdc3f94ee76b53b812ad487f5)): Pull
  Request #24 des Produkt-Repositories (Merge-Commit
  [`0af86aa4e648`](https://github.com/valITino/r3cosint/commit/0af86aa4e6485d6cdfe09829accfdb65a8a8c65a)) und hier Pull Request #14 (Merge-Commit
  [`ee56fea85723`](https://github.com/valITino/r3coscrum/commit/ee56fea8572348799069ac0b866376764edf6694)),
  je ohne Kommentare und Reviews: Freigabe-Eintrag zu E3 bestätigt, die Regel zu fremden
  Inhalten im Harness verbindlich, die Skill zur Einschleusungsprüfung und ihre Zuordnung
  zu sechs Rollen angenommen. Die Gegenprobe zum Versuch zur Regel lief vor dem Merge nicht.
- **Versuch zur Regel** (kein Commit): Antwort vor jedem Werkzeugaufruf, Vergleich "gleich";
  die Gegenprobe steht aus.
- **Kontrollversuch SK-02** (kein Commit; Ergebnis in ADR 0001, 5.1, Commit
  [`1f8865cc3670`](https://github.com/valITino/r3cosint/commit/1f8865cc36701702f1bb61bc47e40cf948b51756)): positiv, mit Gegenprobe; die
  Rückmeldung zählt je Rolle einen Werkzeugaufruf, den Übergabeaufruf.
- **Prüfsatz** (Commit [`818a17162bbb`](https://github.com/valITino/r3cosint/commit/818a17162bbbc51206138ddcecae907f5e4bb235)) vom DevOps
  Engineer, formal geprüft und vor dem Lauf committet; **Lauf und Abgleich bestanden**.
- **Abschluss** (Commit [`7e69fafacc5a`](https://github.com/valITino/r3cosint/commit/7e69fafacc5af23ef174d87445485b782d03dceb)): Nachführungen,
  Übergabe mit Prüfbericht.

### Was methodisch bemerkenswert ist

- **Die Hooks wirkten wieder nicht:** Die Probe des main-Gates blockierte nicht; die
  Starthooks liefen erst mit gesetzter Variable CLAUDE_PROJECT_DIR. Die Kette lief vor
  jedem Commit von Hand.
- **Blinder Lauf:** Die fahrende Rolle erhielt nur die Pfade; der Zustand des Arbeitsbaums
  vor und nach dem Lauf und das Protokoll des Harness belegen, dass nichts ausgeführt wurde.
- **Die Hauptsitzung las keinen Inhalt des Prüfsatzes;** sein Pfad kam erst nach dem Lauf
  in CLAUDE.md, weil CLAUDE.md im Startkontext der Rollen liegt.

### Offen

- Gegenprobe zum Versuch zur Regel: neue Sitzung auf Commit
  [`3e5caf71b2bc`](https://github.com/valITino/r3cosint/commit/3e5caf71b2bca97b7f9764a19841025875974df7), einzige Nachricht die Frage.
- Wertung des Übergabeaufrufs (der Pull Request legt sie zur Abnahme vor), Terminierung von
  `Skill` in dreizehn Werkzeuglisten, Berichtigung des Verweises "6.1.2"; Restbefunde nach
  der Übergabe des Produkt-Repositories.
- Nächste Einheit: Abschnitt B (Abnahme von R3-Q-011 eintragen, drei Posten unter R3-Q-010).

---

## 2026-09-24 — E3: Freigabe eingetragen; E3.1 und E3.2 gebaut (R3-Q-011)

Einheit vom 2026-09-24, drei Schritte und Abschluss. Hauptteil im
Produkt-Repository, dort `docs/uebergaben/2026-09-24_e3-1-und-e3-2.md`
([`4b39fd847f40`](https://github.com/valITino/r3cosint/commit/4b39fd847f40a8637baeaa74c889c6a6a517bf18)); Nachweisverzeichnis
[`697df5c7259a`](https://github.com/valITino/r3cosint/commit/697df5c7259acb9c9cf33b0e0f2db2b05db7a09d).

### Erledigt

- **Freigabe von E3 eingetragen** (Commit
  [`0415dace763b`](https://github.com/valITino/r3cosint/commit/0415dace763bb40f0f6403c0463c3f6517f2c36b)): erteilt am
  2026-09-24 durch den Merge des Pull Requests #23 des Produkt-Repositories
  (Merge-Commit [`3e5caf71b2bc`](https://github.com/valITino/r3cosint/commit/3e5caf71b2bca97b7f9764a19841025875974df7); hier Pull
  Request #13, Merge-Commit [`33bb5dfa1819`](https://github.com/valITino/r3coscrum/commit/33bb5dfa18193ce25fc861c53d53b78b265fddcf)),
  ohne Auflagen, zugleich Bestätigung des Abnahmeeintrags zu R3-Q-010. Die
  Weisung vom selben Tag steht im Wortlaut in ADR 0002, 6.14 und im Backlog
  unter R3-Q-011: E3.1 und der Bau von E3.2 in einer Sitzung, der Versuch zur
  Regel zu Beginn von E3.3, die drei Posten unter R3-Q-010 und O-29 nach E3.3.
- **E3.1 gebaut** (Commit [`2adfc37cad8d`](https://github.com/valITino/r3cosint/commit/2adfc37cad8d2d95ef9da103ab76fec9d63f225a)):
  die Regel zu fremden Inhalten im Harness, ohne Pfadbindung, vom Koordinator.
- **E3.2 gebaut, ohne den Versuch** (Commit
  [`757135b19eb6`](https://github.com/valITino/r3cosint/commit/757135b19eb628e3f278d4bb2005af9e3a6e488f)): die Skill zur
  Einschleusungsprüfung vom SecDevOps Engineer, ihre Zuordnung zu sechs Rollen
  und die Nachführung von ADR 0001. Einen Prüfsatz gibt es noch nicht.

### Was methodisch bemerkenswert ist

- **Die Hooks wirkten in dieser Sitzung nicht:** Sie begann ausserhalb der
  Repositories. Die Kette lief deshalb vor jedem Commit von Hand; die
  Starthooks sind von Hand ausgeführt.
- **Zwei gekennzeichnete Sätze für zwei Versuche** stehen nur in ihrer Datei.
  Ihre Wahrung ist über Zählungen geprüft, nie über eine Ausgabe des Satzes.
- **Prüfbesetzung nach Teilen:** Weil die Hauptsitzung auf dem `model`-Feld
  des Static Software Testers lief, prüfte er die Teile der Hauptsitzung und
  der Rollen mit gleichem Feld abweichend besetzt, die übrigen auf seinem Feld.

### Offen

- Vor dem Merge die Gegenprobe zur Regel in einer neuen Sitzung auf main ohne
  die Regel; danach E3.3 mit dem Versuch zur Regel als erster Nachricht.
- Restbefunde nach der Übergabe des Produkt-Repositories, dazu die offenen
  Punkte aus dem Vermerk vom 2026-09-23 (4).

---

## 2026-09-23 (4) — R3-Q-010 abgenommen und eingetragen; E3 als R3-Q-011 auf der Definition of Ready, nicht gebaut

Vierte Einheit vom 2026-09-23, abgeschlossen am 2026-09-24. Hauptteil im
Produkt-Repository
([`4ef9b65b82cd`](https://github.com/valITino/r3cosint/commit/4ef9b65b82cd30aae702d17700d3a8ed4dc5ef9a),
Nachweisverzeichnis
[`9ffbab7be8e8`](https://github.com/valITino/r3cosint/commit/9ffbab7be8e8c4285624bd71570f88278355f12d),
dort `docs/uebergaben/2026-09-23_e3-dor.md`); der Abnahmeeintrag zu R3-Q-010
steht im Commit
[`bf4576083612`](https://github.com/valITino/r3cosint/commit/bf45760836124d87b3e71c3882cf1ebfffe153da).

### Erledigt

- **Abnahme von R3-Q-010 aktenkundig:** erteilt am 2026-09-23 durch den Merge
  des Pull Requests #21 des Produkt-Repositories (Merge-Commit
  [`9a84b9ccd1ec`](https://github.com/valITino/r3cosint/commit/9a84b9ccd1ecb81b19739f64defc5881e83e2db5);
  hier Pull Request #12, Merge-Commit
  [`cb838ecd35ba`](https://github.com/valITino/r3coscrum/commit/cb838ecd35baba30fb04ab64300e501ab55ed0b6)),
  ohne Auflagen, im Umfang der drei Übergaben vom 2026-09-23 einschliesslich
  Restbefunde; eingetragen in ADR 0002 (Abschnitt 10, 6.13), ADR 0001
  (Abschnitt 8: zwei Entscheide des Auftraggebers — Skills schreibt der
  SecDevOps Engineer; die Prüfstand-Fälle des Prüfmittels sind in ADR 0002,
  6.13 c entschieden), CLAUDE.md und Backlog.
- **E3 festgelegt, nicht gebaut:** Backlog-Eintrag R3-Q-011 (Regel zu fremden
  Inhalten im Harness, Skill zur Einschleusungsprüfung, versionierter
  Prüfsatz, Kontrollversuch zu SK-02; sechs Abnahmekriterien, Prüfaufwand
  6 h, ready mit ausdrücklichem Vorbehalt nach R1), Einordnung als ADR 0002,
  6.14, Zerlegung in E3.1 bis E3.3. Der Merge des Produkt-Pull-Requests ist
  die Freigabe des Umfangs, des Schnitts und der Reihenfolge.

### Was methodisch bemerkenswert ist

- **Ein Kriterium für die eigene Prämisse:** Der Entscheid, die Regel ohne
  Pfadbindung zu bauen, stützt sich darauf, dass eine solche Regel die
  Hauptsitzung erreicht — im Repository nicht belegt. Statt einer Annahme
  steht jetzt ein Kriterium mit Versuch und Gegenprobe; fällt es negativ aus,
  wird der Entscheid neu getroffen, nicht die Messung.
- **Der Prüfsatz entsteht nach der Skill,** damit ihr Verfasser die Prüffälle
  nicht kennt — derselbe Grundsatz wie bei der Fremdmutationsrunde des
  DoD-Gates. Der Modellnachweis je Prüfbericht läuft über Rollen und
  `model`-Feld, ohne Modellnamen in Repository-Dateien.
- **Ein Modellwechsel mitten in der Einheit verschiebt die Prüfbesetzung:**
  Nach dem Wechsel durch den Auftraggeber lief die Hauptsitzung auf dem
  `model`-Feld des Static Software Testers; ihre danach entstandene Arbeit
  prüfte deshalb eine abweichend besetzte Prüfrolle.

### Offen

- Freigabe von Umfang, Schnitt und Reihenfolge von E3 durch den Merge des
  Produkt-Pull-Requests (dort Backlog, offener Punkt 22); die Einordnung der
  drei Posten unter R3-Q-010 liegt beim Auftraggeber (offener Punkt 21).
- Restbefunde nach der Übergabe des Produkt-Repositories: Rollendatei des
  SecDevOps Engineers, veralteter Kopfkommentar im Prüfmittel der
  PreToolUse-Gates, Homonym "Freigabe" im Glossar. Ob das Verbot von
  Modellnamen auch Commit-Nachrichten erfasst, entscheidet der Auftraggeber.
- Nächste Einheit nach dem Merge: E3.1 (Regel), zu Beginn der Sitzung danach
  der Versuch zur Regel, dann E3.2, E3.3 und das Grundgerüst.

---

## 2026-09-23 (3) — E4.3: Ränder der beiden PreToolUse-Gates — ST-09, ST-13, benannte Grenzen und P-10 (R3-Q-010)

Dritte Einheit des Tages. Hauptteil im Produkt-Repository
([`56e27e5bb8ea`](https://github.com/valITino/r3cosint/commit/56e27e5bb8eac5e5d50561387c8ce44907652ba7),
Nachweisverzeichnis
[`53d6300b9aab`](https://github.com/valITino/r3cosint/commit/53d6300b9aab1b0ff8bdfc525c126ce53cbc57f3),
dort `docs/uebergaben/2026-09-23_e4-3-raender-st-09-st-13-grenzen.md`).

### Erledigt

- **Die letzten beiden belegten Lücken geschlossen, die Grenzen benannt** (S9):
  das Prototyp-Gate führt bei Bash dieselbe Befehlsklassenliste als
  Schreibwirkung wie das main-Gate; beide Gates blockieren eine nicht
  auswertbare Eingabe mit Rückgabewert 2 und Meldung; P-10 und die
  Subshell-Grenze stehen als Grenzen im Kopfkommentar. Prüfmittel nach dem
  Nachtrag mit 258 Fällen, 19 Mutationen und 23 Fallklassen, keine belegte
  Lücke verbleibt.
- Damit sind alle sieben Abnahmekriterien von R3-Q-010 gebaut und auf einem
  anderen Modell verifiziert (je eine statische und eine dynamische Runde,
  Behebung, je eine Nachprüfung). Die Abnahme liegt beim Auftraggeber: Merge
  der Pull Requests beider Repositories.

### Was methodisch bemerkenswert ist

- **Eine Behebung kann eine Schwäche importieren:** Die aus dem main-Gate
  übernommene Ausnahme für flüchtige Ziele (gegen den Fehlalarm bei
  "2>/dev/null") liess in beiden Gates Umleitungen über "/tmp/.." durch. Sie
  wurde nicht als Grenze festgeschrieben, sondern noch am selben Tag behoben:
  Ein Preis, der sich beheben lässt, wird nicht zur Grenze erklärt.
- **Der Wortlaut eines Kommentars entscheidet über ein Kriterium:** Der
  dynamische Prüfer wertete "benannte Grenzen" zunächst als nicht bestanden,
  weil ein als Preis benannter Fall keinen durchlaufenden Fall hatte; die
  Neufassung als Restbefund löste das ohne Codezeile.

### Offen

- DT-E43-6/N-1, N-3 und der dabei gefundene DT-E43-8 am selben Tag als Nachtrag
  behoben (Produkt-Repository
  Commit [`d4b5c66c6279`](https://github.com/valITino/r3cosint/commit/d4b5c66c6279d3628345258b2a5a87196c37608a), Nachweisverzeichnis [`28b9ac18a046`](https://github.com/valITino/r3cosint/commit/28b9ac18a046e95e21b606214ed16b62b0695e0e)); offen bleiben DT-E43-4 (deno eval, node --eval,
  bun -e), Preis P38 und der Entscheid des Software Architects zu den
  Prüfstand-Fällen.
- Nächste Einheit nach ADR 0002, 6.13 g: E3 (Festlegung), dann Grundgerüst.

---

## 2026-09-23 (2) — E4.2: Erkennungslücken ST-04, ST-05 und P-01 am Prototyp-Gate geschlossen (R3-Q-010)

Zweite Einheit des Tages. Hauptteil im Produkt-Repository
([`5467c30a42d5`](https://github.com/valITino/r3cosint/commit/5467c30a42d5579f7ac56929222e5a2f39b81a12),
dort `docs/uebergaben/2026-09-23_e4-2-prototyp-gate-erkennungsluecken.md`).

### Erledigt

- **Drei belegte Lücken am Prototyp-Gate geschlossen**, nach dem Vorgehen aus S9:
  Soll zuerst auf 2 (der Lauf fiel mit genau den 16 Fällen), dann das Gate,
  dann der Vermerk. Prüfmittel mit 225 Fällen und elf Mutationen, jetzt auch
  mit Prüfung der Meldung; zwei weitere Abnahmekriterien von R3-Q-010 erfüllt.
- Verifikation auf einem anderen Modell: je eine statische und eine dynamische
  Runde mit blockierendem Befund, Behebung, eine Nachprüfung, bestanden.

### Was methodisch bemerkenswert ist

- **Ein Kriterium, das eine Meldung verlangt, braucht einen Test, der die
  Meldung liest.** Der Prüfsatz blieb grün, als eine Kopie des Gates weder 5.6
  noch die Richtung nannte; erst die dynamische Runde fand das.
- **Jede Erweiterung eines Musters hat einen Preis, den die Gegenproben messen
  müssen:** Das neue Präfix blockierte Pfade, die den Prototyp nie verlassen
  ("./lib/utils"); behoben durch ein engeres Präfix und sechs neue Gegenproben.
- **Lesarten werden festgehalten, nicht stillschweigend angewandt:** "Bezugsform"
  ist das Konstrukt, die Pfadschreibweise bleibt in Richtung 2 präfixgebunden;
  die Asymmetrie steht als benannte Grenze im Kopfkommentar, die Aufnahme ist
  Sache einer Fortschreibung des ADR.

### Offen

- E4.3 (ST-09, ST-13, benannte Grenzen, P-10) in derselben Sitzung; Entscheid
  des Software Architects zu den Prüfstand-Fällen (L01 bis L11).

---

## 2026-09-23 (1) — E4.1: Prüfmittel für die beiden PreToolUse-Gates gebaut (R3-Q-010)

Erste Einheit des Tages, nach Weisung ("E4 bauen, nach Plan, ohne Umwege").
Hauptteil im Produkt-Repository
([`a3f5cb24247b`](https://github.com/valITino/r3cosint/commit/a3f5cb24247b1c471e48b6b9305c552af08ff7a7),
dort `docs/uebergaben/2026-09-23_e4-1-pruefmittel-pretooluse-gates.md`).

### Erledigt

- **Prüfmittel `scripts/pretooluse-gates-selbsttest.sh`** mit 202 Fällen und
  zehn Mutationen, beide Modi grün, Arbeitsbaum im Lauf als unverändert
  gemessen; keine Zeile an den Gates (S9). Zwei Abnahmekriterien von
  R3-Q-010 erfüllt, ST-01 bis ST-03 erstmals fremdbelegt.
- Verifikation auf einem anderen Modell: statisch und dynamisch je eine Runde
  mit demselben blockierenden Befund, Behebung, eine Nachprüfung, bestanden.

### Was methodisch bemerkenswert ist

- **Ein blockierender Fall belegt eine Behebung nur, wenn er an ihr hängt.**
  Die ST-01-Fälle endeten im main-Kontext mit und ohne Behebung gleich, weil
  eine allgemeinere Sperre alles überdeckte; die Vormessung des Koordinators
  und der Fremdbeleg vom 2026-09-21 trugen dieselbe Schwäche. Getragen hat die
  Mutationsprobe: erst die zehnte Mutation, die die Behebung zurücksetzt,
  macht die Fälle trennscharf (S9).
- **Eine Aufzählung misst, was sie führt.** Die dynamische Runde fand mit
  eigenen Schreibweisen vier neue Lücken am main-Gate; sie stehen als
  Prüfstand-Fälle mit dem heutigen Wert, nicht als stillschweigende Härtung.

### Offen

- E4.2 und E4.3 in derselben Sitzung; Entscheid des Software Architects zu
  den vier neuen Lücken und zur Subshell-Form; Pull Requests am Ende der
  Sitzung, der Merge gilt als Abnahme.

---

## 2026-09-22 (3) — Beide Pull Requests gemergt; Nachweisfluss am Regelwerk gescheitert; dritter Codex-Lauf

Dritte Einheit des Tages. Hauptteil im Produkt-Repository
([`3c712292c74c`](https://github.com/valITino/r3cosint/commit/3c712292c74c14c8d7934f1edcfbbe3deceaad84),
dort `docs/uebergaben/2026-09-22_abnahme-starthooks-und-codex-dritter-lauf.md`).

### Erledigt

- **Abnahme der beiden Starthooks** durch den Merge des Pull Requests #17
  (`a462aacfcedaa5ae62e92b14335f9db6718499be`) und des Pull Requests #10
  dieses Repositories (`494409cf431e447ef26ce18f99832e467ec8a08d`) am
  2026-09-22 — in ADR 0002, Abschnitt 10, `CLAUDE.md`, Backlog und hier
  (S8) eingetragen.
- **Vier Befunde des dritten Codex-Laufs** (eine Minute vor dem Merge
  gemeldet) behoben und auf einem anderen Modell geprueft; der Zweig traegt
  den geprueften Stand, ein Pull Request wird nur auf Weisung eroeffnet.

### Was methodisch bemerkenswert ist

- **Der Nachweisfluss ist am eigenen Regelwerk gescheitert:** Nach dem Merge
  wies `main` dieses Repositories den Commit der Automatik ab ("Changes must
  be made through a pull request"). Die Regel "nie direkt auf main" und die
  Regel "`nachweise/` beschreibt ausschliesslich die Automatik" stehen damit
  gegeneinander; welche weicht (Umgehung im Regelwerk fuer den Akteur des
  Tokens oder Nachweisfluss ueber Pull Request), ist ein Entscheid des
  Auftraggebers, im Produkt-Repository vorgelegt. Bis dahin fehlt hier der
  Nachweisstand `a462aacf…`.
- **Ein Zitat aus einem fremden Review ist keine Quelle.** Der falsche
  Wortlaut eines `githooks(5)`-Zitats stammte aus dem Codex-Kommentar und
  wurde ungeprueft weitergegeben; die statische Pruefung hat ihn am Original
  gefunden. Das Kriterium "woertliches Zitat belegbar" ist damit zweimal
  gescheitert.
- **Die Klasse "vererbte Umgebung lenkt einen Schreibzugriff in den
  Arbeitsbaum" ist offen** und laesst sich nicht leerpruefen; sie wird als
  benannte Grenze gefuehrt, nicht als Liste geschlossener Vektoren.

### Offen

- Entscheid zum Nachweisfluss (Regelwerk oder Pull Request); Wiederholung
  des Laufs.
- Entscheid, ob die vier Behebungen als Pull Request vorgelegt werden.
- Entscheid zum Codex-Review (Frage des Auftraggebers, beantwortet im
  Produkt-Repository: GitHub-App, nur vom Kontoinhaber zu entfernen).
- Danach E4.1 in einer neuen Sitzung von `main`.

---

## 2026-09-22 (2) — Git-Historie beim Sitzungsstart nachgeholt; Pull Requests eröffnet

Zweite Einheit des Tages, auf Delegation des Auftraggebers ("Ich überlasse es
dir, da du einen besseren Überblick hast"). Hauptteil im Produkt-Repository
([`bb6c1965fa27`](https://github.com/valITino/r3cosint/commit/bb6c1965fa271f7f1d28cc57d3c0fc192ad8cb15),
dort `docs/uebergaben/2026-09-22_git-historie-starthook.md`).

### Erledigt

- **Der flache Klon ist ein gelöstes Bauproblem**, nicht mehr ein Handgriff
  je Sitzung: ein versionierter `SessionStart`-Hook holt die Git-Historie
  nach, wenn der Klon flach ist (S8, Nachtrag). Verifikation auf einem
  anderen Modell, Ergebnis in der Übergabe des Produkt-Repositories.
- **Pull Requests beider Repositories eröffnet** (Produkt-Repository: Pull
  Request #17; dieses Repository: der Pull Request dieses Zweigs). Der Merge im
  Produkt-Repository gilt nach seinem Text als Abnahme der beiden Starthooks
  (erster Formweg); der Merge liegt beim Auftraggeber.

### Was methodisch bemerkenswert ist

- Eine delegierte Frage wird nicht mit "später" beantwortet, wenn dieselbe
  Klasse am selben Tag bereits einmal gelöst wurde: Zwei Handgriffe je
  Sitzung sind zwei Bauprobleme, nicht eines.
- Der Remote des Klons wird nicht gepinnt, die Prüfsumme eines
  Werkzeugarchivs schon — die Grenze verläuft zwischen dem, was dem Klon
  gehört, und dem, was von aussen kommt.

### Offen

- Merge durch den Auftraggeber, dann E4.1 in einer neuen Sitzung von `main`.
- Unverändert: offene Punkte 12, 15 und 20 des Backlogs, O-28 bedingt, O-15,
  Restbefunde an den Hooks.

### Nachtrag nach dem Codex-Review (Pull Request #10, Befund P2)

O-25 des ADR 0002 ist seit dem 2026-09-03 **entschieden** (dort Abschnitt 8;
hier V15 und der erledigte Punkt oben), wurde aber seit dem 2026-09-07 in
beiden Repositories als "bleibt offen" mitgeführt, ohne dass eine Stelle den
Grund nennt. Berichtigt im Eintrag zu O-27 in `methodik/entscheide.md` und
in diesem Vermerk; im Produkt-Repository in `CLAUDE.md`, Backlog, ADR 0002
(Status-Block 6.13, Abnahmeeintrag in Abschnitt 10 mit Vermerk) und im
Nachweiserzeuger
([`98512f42ad1e`](https://github.com/valITino/r3cosint/commit/98512f42ad1e7752235dabab03981d0b058d4c2f)).
Die Vermerke vom 2026-09-21 und 2026-09-22 (erste Einheit) und die
Übergaben des Produkt-Repositories bleiben als Stand davor stehen; sie
führen O-25 noch als offen, und dieser Nachtrag sagt, dass das unzutreffend
war.


### Nachtrag nach dem Codex-Review (Pull Request #17 des Produkt-Repositories)

Der Code-Review-Bot hat am Pull Request #17 vier berechtigte Befunde an den
beiden Starthooks gemeldet; alle vier sind behoben und auf einem anderen
Modell in drei Runden nachgeprüft ([`1d9da15e4617`](https://github.com/valITino/r3cosint/commit/1d9da15e4617555f73a60a49f6dbc968cb166a87),
dort `docs/uebergaben/2026-09-22_git-historie-starthook.md`, Nachtrag nach
dem Codex-Review; ADR 0002, Abschnitt 10, E-E und E-F je zweiter Nachtrag).

Was methodisch bemerkenswert ist:

- **Eine Zusicherung über ein fremdes Werkzeug wurde aus dessen
  Dokumentation geschlossen statt am Werkzeug gemessen.** Die erste
  Behebung (explizite Refspec) deckte nur einen der zwei Wege, auf denen die
  konfigurierte Refspec wirkt (Abrufliste, nicht Refmap); Static und Dynamic
  Software Tester haben das unabhängig voneinander am Gegenstand gefunden.
  Erst die zweite Behebung (`--refmap=''`) trug die Zusicherung "Zweige
  unberührt" — zweimal gescheitert, im dritten Antreten bestanden; nach 3.4
  keine Eskalation, die Zählung ist im Produkt-Repository festgehalten.
- **Ein als Zitat ausgewiesener Satz, der in der Quelle nicht steht, ist ein
  blockierender Befund**, auch wenn die Sache stimmt: Die statische
  Schlussprüfung hat ein erfundenes Zitat aus `git-fetch(1)` in drei
  Kommentarstellen gefunden (Vorgabe aus dem Auftrag des Koordinators);
  ersetzt durch wörtlich belegte Passagen.
- **Was die Umgebung braucht, wird nicht gelöscht:** `GIT_CONFIG_*` bleibt
  stehen, weil der Harness darüber Anmeldung und URL-Umschreibung setzt; die
  Wirkung auf Zweige ist anders abgeschaltet. Entscheid im Produkt-Repository
  begründet.
- Der Belegprüfer D20 liest Git-Ref-Namen in Rückwärtsakzenten als Pfade
  (bekannte Grenze); Ref-Namen werden deshalb ohne Akzente geschrieben.
---

## 2026-09-22 — Weisung aktenkundig: R3-Q-010 freigegeben, Lesart zu 3.4 und zu R1; gitleaks als Starthook dauerhaft bereitgestellt

Arbeitseinheit auf Weisung des Auftraggebers vom 2026-09-22. Der Hauptteil
liegt im Produkt-Repository
([`13a23b98d0ed`](https://github.com/valITino/r3cosint/commit/13a23b98d0ed5c4e5531ddfb01f43a6b91f4d8a8),
dort `docs/uebergaben/2026-09-22_weisung-r3-q-010-freigabe-gitleaks-starthook.md`);
hier der methodische Anteil.

### Erledigt

- **Die Weisung ist aktenkundig** — vier Entscheide in einer Nachricht:
  Umfang von R3-Q-010 freigegeben und Schnitt E4.1 bis E4.3 bestätigt (im
  Produkt-Repository in ADR 0002, 6.13, im Backlog und in CLAUDE.md; hier
  unter "Offene Punkte"), die Lesart des Koordinators zur Zählfrage nach 3.4
  bestätigt (V18), der Entscheid zur Lesart von R1 an den Koordinator
  delegiert und von ihm gefällt (V19; im Produkt-Repository in
  `docs/06_Definition_of_Ready_und_Done.md`), dazu "gitleaks permanent
  einbauen bitte." (S8; im Produkt-Repository als versionierter
  `SessionStart`-Hook).
- **Gebaut ist an E4 nichts.** Die nächste Einheit ist E4.1; sie ändert nach
  ADR 0002, 6.13 g keine Zeile an den beiden Gates.

### Was methodisch bemerkenswert ist

- Eine Weisung, die vier Entscheide in vier Sätzen trägt, wird an jeder
  Stelle im Wortlaut zitiert, nicht paraphrasiert; die Sätze "steht aus"
  bleiben als Stand davor stehen. Der Aufwand, das an sieben Stellen zu
  tun, ist der Preis dafür, dass der zweite Formweg (Anweisung an die
  Sitzung) denselben Beleg hergibt wie der erste (Merge eines Pull Requests).
- Ein delegierter Entscheid ("Das, was richtig ist und Sinn macht") wird
  nicht stillschweigend gefällt: Die gewählte Option, die verworfene und der
  Grund stehen in der Definition of Ready, im Backlog und hier. Die erste
  Fassung der Lesart hatte drei fachliche Lücken, die der Requirements
  Engineer — die Rolle, die den Text eingetragen hat — selbst gemeldet hat;
  sie sind vor dem Commit eingearbeitet, und die Fortschreibungszeile sagt
  das.
- Die Zählfrage nach 3.4 ist an einem Fall entschieden und als Lesart
  verallgemeinert, mit ausdrücklicher Grenze: Sie macht einen ausführbaren,
  dreimal offen gebliebenen Schritt nicht zum Nicht-Scheitern.
- Ein Umgebungsproblem, das dreimal von Hand behoben wurde, ist ein
  Bauproblem. Die Bereitstellung liegt jetzt im Repository, mit gepinnter
  Prüfsumme und doppelter Prüfung, und sie behauptet nichts, was sie nicht
  trägt: für andere Architekturen installiert sie nichts, und die Lage-C-
  Meldung der Kette bleibt unangetastet.

### Offen

- E4.1 bauen (nächste Einheit). Vorher empfohlen: Merge der beiden
  Arbeitszweige; die Pull Requests werden nur auf ausdrückliche Anweisung
  eröffnet.
- Frage an den Auftraggeber: Soll ein flacher Klon beim Sitzungsstart
  ebenfalls durch einen Hook nachgeholt werden?
- Offene Punkte 12 und 15 des Backlogs (benannter Stakeholder für R3-Q-001
  bis R3-Q-009); O-28 bedingt offen; O-25 und O-15 offen.

---

## 2026-09-21 — R3-Q-001: Abnahme aktenkundig; E4 als R3-Q-010 auf die Definition of Ready gebracht, nicht gebaut

Arbeitseinheit auf Weisung des Auftraggebers vom 2026-09-21. Der Hauptteil
liegt im Produkt-Repository
([`e5bab959aa48`](https://github.com/valITino/r3cosint/commit/e5bab959aa4886eefc7983ce23916bbd798d8a83),
dort `docs/uebergaben/2026-09-21_r3-q-001-abnahme-eingetragen-e4-dor.md`);
hier der methodische Anteil.

### Erledigt

- **Die Abnahme des Prüfmittels aus R3-Q-001 ist aktenkundig.** Sie war am
  2026-09-08 über den ersten Formweg erteilt worden — Merge des Pull Requests
  #15 im Produkt-Repository, dessen Text den Merge ausdrücklich als Erteilung
  der Abnahme benennt (Merge-Commit
  [`9870b0d115b8`](https://github.com/valITino/r3cosint/commit/9870b0d115b8ef330a7c19777af5741093e4f0e9),
  09:51:49 UTC, ohne Kommentar, ohne Review, ohne Auflage); der zugehörige
  Merge in diesem Repository ist der Pull Request #9
  ([`9c28499252ab`](https://github.com/valITino/r3coscrum/commit/9c28499252ab3f42a96dc43bf096c3a6353ce0cb)).
  Eingetragen ist der Entscheid im Produkt-Repository (ADR 0002, Abschnitt 10;
  ADR 0001; CLAUDE.md; Backlog R3-Q-001) und hier in `methodik/entscheide.md`
  (V17 um die erteilte Abnahme ergänzt, O-27 um den Entscheid ergänzt).
- **Nicht umfasst** sind O-25, der Belegprüfer D20 (O-15), R3-Q-005 und die
  Freigabe des Grundgerüsts. **Teil 2 des Abnahmekriteriums war nicht
  erfüllt**; getragen hat allein der in ADR 0002, 6.12.28 g vorab festgelegte
  Weg. Das steht an jeder Stelle so.
- **E4 hat einen Umfang:** Backlog-Eintrag R3-Q-010 (beide PreToolUse-Gates,
  sieben Abnahmekriterien, Prüfaufwand 5 h, ready mit ausdrücklichem
  Vorbehalt zu R1), eingeordnet in ADR 0002, 6.13; neuer offener Punkt O-28.
  Massgeblich waren allein die im Zustandsbericht vom 2026-09-02 belegten
  Lücken, am 2026-09-21 nachgemessen und von einer Prüfrolle auf einem
  anderen Modell belegt. Die Umsetzung ist in E4.1 bis E4.3 zerlegt; gebaut
  ist nichts.

### Was methodisch bemerkenswert ist

- Ein Abnahmeentscheid, der über einen Merge erteilt wird, ist erst dann
  aktenkundig, wenn ihn jemand aus der Merge-Historie in die Dokumente
  überträgt. Zwischen Merge und Eintrag lagen hier 13 Tage; in dieser Zeit war
  `main` des Produkt-Repositories an D20 rot (eine Abschnittsangabe ohne
  ADR-Nennung in der Übergabe vom 2026-09-07 — die Klasse K-01 des
  Zustandsberichts: der Belegprüfer liest nur versionierte Dateien, und die
  Datei war vor `git add` geprüft worden). Behoben; die Übergabe dieser Einheit
  ist vor dem letzten Kettenlauf versioniert worden.
- Der Umfang von E4 wurde nicht aus dem abgeleitet, was ein Gate "sonst noch
  könnte", sondern aus belegten Lücken; was bewusst nicht aufgenommen ist,
  steht mit Grund im Eintrag. Ein als widerlegt geführter Befund (ST-13) wurde
  aufgenommen, weil sein operativer Teil bestätigt ist und der
  Widerlegungsgrund im Bericht abgeschnitten und nicht überliefert ist — als
  abweichende Beurteilung gekennzeichnet, nicht stillschweigend.
- Das Prüfmittel für die beiden Gates ist bewusst kleiner angelegt als das des
  Definition-of-Done-Gates: eine Fallliste mit Mutationsprobe, ohne
  Zusicherungsapparatur, mit benannter Grenze. Ein Prüfmittel, das aufwendiger
  ist als der geprüfte Gegenstand, bindet Kontingent ohne Zuwachs an
  Sicherheit.
- Zwei Orchestrierungen sind an Turn-Grenzen von Rollen gescheitert, weil die
  Rollen den ganzen ADR lasen; die dritte hat jeder Rolle Zeilenbereiche und
  Anker vorgegeben. Eine Prüfrolle hat an der Übergabe die Eskalationsregel
  3.4 angesprochen, weil ein geplanter, von der Commit-Prüfsumme abhängiger
  Schritt dreimal als offen gemeldet wurde; der Koordinator hat das dem
  Auftraggeber offen vorgelegt statt umgedeutet.

### Offen

- Freigabe des Umfangs von R3-Q-010 und Entscheid über den Schnitt E4.1 bis
  E4.3 durch den Auftraggeber; O-28 bedingt offen.
- E3 (Regel zu fremden Inhalten im Harness und die zurückgestellte Skill)
  braucht eine eigene Festlegungseinheit: kein Befundbestand, und vor der
  dritten Skill steht der Entscheid, wer `.claude/skills/` schreibt (ADR 0001,
  Abschnitt 8), dazu der nicht belegte Kontrollversuch zum Vorladen (SK-02).
- O-25 und O-15 bleiben offen; die Lesart von R1 für Einträge mit benanntem
  Stakeholder ist in der Definition of Ready festzuhalten (Backlog, offener
  Punkt 19).

---

## 2026-09-07 — R3-Q-001: O-27 umgesetzt, Runde 12 als letzte Fremdmutationsrunde

Der Auftraggeber hat am 2026-09-07 die Wahl zwischen den beiden Wegen zu O-27
an den Koordinator delegiert ("Dann wähle den besten und korrektesten Weg aus,
ich vertraue dir und deiner Expertise."). Gewählt sind beide Wege zusammen.
Der Hauptteil dieser Einheit liegt im Produkt-Repository
([`71596aae9b6f`](https://github.com/valITino/r3cosint/commit/71596aae9b6fd20324c7e16863ca18a16b57794a),
dort `docs/uebergaben/2026-09-07_r3-q-001-o-27-deckung-am-gegenstand.md`);
hier der methodische Anteil. Die Einheit erstreckt sich über den 2026-09-07
und den 2026-09-08.

### Erledigt

- Der Entscheid O-27 ist als **V17** in `methodik/entscheide.md` eingetragen:
  Die Sollmenge einer Deckung wird aus dem Gegenstand selbst erhoben, jede
  Deckung ist fail-closed, das Abnahmekriterium ist auf das falsche Grün am
  Prüfling bezogen, und die Zahl der Prüfrunden wird vorab begrenzt.
- Der offene Punkt **O-27 ist geschlossen**.
- Beide Modi des Selbsttests enden mit Rückgabewert 0: Normalmodus 262 von
  262 Zusicherungen, Mutationsmodus 250 von 250 erkannten Mutationen, alle
  elf Deckungen ohne Abweichung.
- Runde 12 ist als **letzte** Fremdmutationsrunde gelaufen: 29 blind
  gewählte Fremdmutationen, 28 erkannt, ein blockierender Befund
  (`DT12-M14`), behoben und mit gezielter Wiederholung als Fremdbeleg
  bestätigt.

### Was methodisch bemerkenswert ist

Zum ersten Mal hat eine Prüfrunde nicht eine weitere Lücke in einer
Aufzählung gefunden, sondern die Aufzählung als Massstab abgelöst. Der
Unterschied zeigt sich an den Zahlen: Wo die Deckung ihre Sollmenge aus dem
Gegenstand erhebt, ist sie vollständig geworden; wo sie an einer zweiten,
nicht erhobenen Grammatik hängt, ist sie es nicht — und genau dort hat die
zwölfte Runde ihren einen Treffer gelandet. Das ist kein Argument gegen den
Entscheid, sondern seine Bestätigung, und es ist als benannte Restlücke
festgehalten statt als weiterer Anlauf.

Zweitens hat sich in derselben Einheit die Fehlerklasse, gegen die sich V17
richtet, **im Prüfmittel selbst** gezeigt: Die Wache über den Deckungsblock
mass ein Feld, das vier der Blockzeilen nicht enthielt, und eine Deckung mit
leerer Sollmenge bestand unbemerkt. Beides ist behoben, beides war nur
sichtbar, weil eine fremde Rolle den Bau gegengelesen hat.

Drittens: **Teil 2 des Abnahmekriteriums ist nicht erfüllt.** Er verlangt eine
Fremdmutationsrunde ohne blockierenden Befund, und Runde 12 hatte einen. Die
Abnahme wird trotzdem vorgelegt — auf der Grundlage des Wegs, den dieselbe
Festlegung **vor** der Runde für genau diesen Fall bestimmt hat. Ein
Abnahmekriterium taugt nur, wenn auch sein Fehlschlag vorab geregelt ist;
sonst wird es im Fehlschlag umgedeutet.

### Offen

- Die **Abnahme des Gates** aus R3-Q-001 ist dem Auftraggeber vorgelegt und
  steht aus (Produkt-Repository, ADR 0002, Abschnitt 10).
- **O-25** bleibt offen.
- Drei benannte Restlücken und die nachrangigen Befunde der Runden 11 und 12
  sind im Backlog unter R3-Q-001 geführt.

---

## 2026-09-06 — R3-Q-001: O-26 umgesetzt, Runden 9 bis 11, dritter Abbruch nach 3.4, O-27 vorgelegt

Der Auftraggeber hat am 2026-09-06 O-26 entschieden ("Na dann weiter gehts,
so wie du es sagst" -- Annahme des Vorschlags aus dem Bericht des
Koordinators vom 2026-09-05). Der Hauptteil dieser Einheit liegt im
Produkt-Repository
([`12402c82a11a`](https://github.com/valITino/r3cosint/commit/12402c82a11a5a0b7f6bb86c7b614d7580b68c72),
dort `docs/uebergaben/2026-09-06_r3-q-001-o-26-praedikat-und-deckung.md`);
hier der methodische Anteil. Die Einheit erstreckt sich ueber den 2026-09-06
und den 2026-09-07.

### Erledigt

- Der Entscheid O-26 ist als **V16** in `methodik/entscheide.md` eingetragen:
  Ein Abnahmekriterium, das jede neue Luecke zum Abbruchgrund macht, beendet
  keine Abnahme -- die Abnahme eines Pruefmittels verlangt vollstaendig
  erkannte tabelleneigene Mutationen und eine Fremdmutationsrunde in
  benannten Kategorien ohne blockierenden Befund; dazu bindet die
  Prueftabelle die Messart je Zusicherung wie den Kanal und wird maschinell
  gegen den Text der Festlegung gehalten. Umgesetzt im Produkt-Repository
  als Abschnitt 6.12.27 des Architekturentscheids 0002 mit 207
  Zusicherungen, 197 Mutationen und zehn begruendeten Ausnahmen.
- Der offene Punkt O-26 ist geschlossen; **O-27** ist als offener Punkt
  eingetragen.
- Beide Modi des Selbsttests enden mit Rueckgabewert 0 (207 von 207
  Zusicherungen; Kanal-, Praedikat-, Schluessel-, Gegenstands-, Grammatik-
  und Aussagendeckung ohne Abweichung; 197 von 197 tabelleneigenen
  Mutationen erkannt). Teil 1 des Abnahmekriteriums ist in den Runden 9, 10
  und 11 erfuellt und statisch bestaetigt.
- Die Einheit ist zum dritten Mal nach Projektauftrag 3.4 abgebrochen:
  Teil 2 des Abnahmekriteriums -- eine blind gewaehlte Fremdmutationsrunde
  ohne blockierenden Befund in vier Kategorien -- ist in Runde 9 (drei),
  Runde 10 (sieben) und Runde 11 (zehn unerkannte Fremdmutationen) nicht
  erfuellt. Der Abbruch nach dem dritten Fehlschlag war nach dem zweiten
  vorab festgelegt und im Architekturentscheid protokolliert. Das Gate
  selbst war in allen elf Runden gegen echte Baeume nie falsch gruen; die
  Luecken liegen im Nachweis, nicht im Schutz.

### Vorgeschlagen, nicht eingetragen

- **Eine Vollstaendigkeitspruefung leitet ihre Sollmenge aus dem Gegenstand
  ab, nicht aus einer Aufzaehlung im Text.** Drei Runden lang hat jede
  nachgetragene Aufzaehlung (Zaehlschluessel, Grammatikelemente, normative
  Aussagen) genau die Luecke geschlossen, die die vorige Runde gezeigt
  hatte, und die naechste Runde fand die naechste Auspraegung derselben
  Klasse. Vollstaendig war in Runde 11 allein die Kategorie, deren Sollmenge
  aus dem Gate selbst erhoben wurde (die Schluesselliterale). Eine Liste im
  Text ist eine zweite Quelle der Wahrheit; sie deckt, was jemand
  aufgeschrieben hat, nicht, was da ist. Ob das Regel wird, haengt am
  Entscheid zu O-27.
- **Ein vorab festgelegter Ausgang schuetzt den Abbruch vor dem Ermessen.**
  Nach dem zweiten Fehlschlag hat der Koordinator den dritten Versuch mit
  vorab festgelegtem Ausgang angesetzt und das im Architekturentscheid
  protokolliert. Der Abbruch nach dem dritten Fehlschlag war dadurch kein
  Ermessensentscheid unter dem Eindruck kleiner, leicht behebbarer Befunde
  -- und genau solche lagen vor. Regelvorschlag: Wird die Schwelle nach 3.4
  in einer Einheit absehbar (zweiter Fehlschlag am selben Kriterium), wird
  der Ausgang des dritten Versuchs vor dem Versuch schriftlich festgelegt.
- **Eine mechanische Deckung muss geschlossen ausfallen.** Drei Deckungen
  des Selbsttests bestehen "leer", wenn ihr Lesen misslingt (ein leeres
  Muster trifft jede Zeile, eine leere Sollmenge hat null Luecken).
  Regelvorschlag: Jede Vollstaendigkeitspruefung verlangt eine Mindestzahl
  groesser null und behandelt eine leere Sollmenge oder ein leeres Muster
  als Fehlschlag. Ob das Regel wird, entscheidet der Auftraggeber.

### Offen

- O-27 beim Auftraggeber; danach entweder eine weitere Einheit mit Runde 12
  oder der Abschluss mit geaendertem Abnahmekriterium. Die foermliche
  Freigabe der Entscheidpunkte E-A bis E-K und die Abnahme des Gates
  stehen aus; Formweg ist der Merge der beiden Pull Requests. Empfehlung
  des Koordinators: noch nicht mergen.

### Nachtrag 2026-09-07: O-27 entschieden, Merge empfohlen

- Der Auftraggeber hat die Wahl zu O-27 an den Koordinator delegiert
  ("Dann wähle den besten und korrektesten Weg aus, ich vertraue dir und
  deiner Expertise."). Gewaehlt und damit entschieden: Weg (a) und (b)
  zusammen in einer Einheit, Runde 12 als letzte Fremdmutationsrunde;
  Einzelheiten in `methodik/entscheide.md` (O-27) und im
  Produkt-Repository (ADR 0002, 6.12.27 k). Die Umsetzung folgt in der
  naechsten Sitzung; der Sitzungsauftrag liegt im Produkt-Repository unter
  `docs/vorlagen/2026-09-07_sitzungsauftrag-o-27.md`.
- Empfehlung des Koordinators damit geaendert: beide Pull Requests jetzt
  mergen. Der Merge im Produkt-Repository ist die foermliche Freigabe der
  Entscheidpunkte E-A bis E-K (ADR 0002, Abschnitt 10) und schaltet das
  Gate scharf; die Abnahme des Gates bleibt davon getrennt und folgt nach
  Runde 12.

---

## 2026-09-04 — R3-Q-001: O-25 umgesetzt, Runden 6 bis 8, erneuter Abbruch nach 3.4, O-26 vorgelegt

Der Auftraggeber hat am 2026-09-03 O-25 entschieden ("O-25 entscheiden:
beides umsetzen, dann sechste Runde."). Der Hauptteil dieser Einheit liegt im
Produkt-Repository
([`ce8ed8a0487d6b7dc8b2f805d3110996fd50e765`](https://github.com/valITino/r3cosint/commit/ce8ed8a0487d6b7dc8b2f805d3110996fd50e765),
dort `docs/uebergaben/2026-09-04_r3-q-001-o-25-kanal-und-mutation.md`); hier
der methodische Anteil.

### Erledigt

- Der Entscheid O-25 ist als **V15** in `methodik/entscheide.md` eingetragen:
  Eine Pruefung ist erst dann Beleg, wenn sie ihre eigene Verneinung erkennt
  -- je Zusicherung nennt die Prueftabelle den gemessenen Kanal aus einem
  abschliessenden Wertevorrat und die Aenderung am Gegenstand, die sie
  fehlschlagen lassen muss; der Selbsttest gleicht den Kanal maschinell ab
  und fuehrt jede Mutation gegen eine Kopie aus. Umgesetzt im
  Produkt-Repository als Abschnitt 6.12.26 des Architekturentscheids 0002
  mit 154 Zusicherungen, 145 Mutationen und neun
  begruendeten Ausnahmen ("keine", drei geschlossene Gruende).
- Der offene Punkt O-25 in `methodik/entscheide.md` ist geschlossen.
- Beide Modi des Selbsttests enden mit Rueckgabewert 0 (154 von 154
  Zusicherungen, Kanalabgleich ohne Abweichung, 145 von 145 tabelleneigenen
  Mutationen erkannt); das Gate verhaelt sich in allen dynamischen
  Pruefpunkten der Runden 6 bis 8 richtig, ohne ein einziges falsches Gruen.
- Die Einheit ist trotzdem erneut nach Projektauftrag 3.4 abgebrochen: Die
  achte Runde ist statisch bestanden und dynamisch nicht bestanden. Mit
  sechzehn eigenen, nicht in der Tabelle stehenden Mutationen hat der Pruefer
  fuenf Aenderungen am Gate gefunden, die keine Zusicherung fallen lassen --
  darunter die Verschiebung der Eskalationsschwelle (eine Zusicherung misst
  "die Zeile ... woertlich" als Teilzeichenkette) und zwei Behauptungen des
  Architekturentscheids ohne jede Zeile (ein Zaehlschluessel, ein Element der
  Markengrammatik). Achter Auftritt der Fehlerklasse "ein Selbsttestfall
  besteht, ohne seine Behauptung zu belegen". Vorgelegt ist O-26.

### Vorgeschlagen, nicht eingetragen

- **Eine Praemisse ist zu belegen, bevor sie eine Messvorschrift wird.** In
  Bau 4 hielten zwei Entscheide des Architekturentscheids der Probe am Code
  nicht stand: Eine Zeile sollte auf zwei Kanaelen messen, weil unter der
  Verneinung "die Kette liefe" -- sie laeuft in der herstellbaren Lage nicht;
  eine andere nannte eine Mutation am Gate fuer eine Zusicherung, die nur die
  Kette misst. Beide Male hat erst die ausgefuehrte Probe die Luecke gezeigt,
  und beide Male war die Berichtigung klein. Regelvorschlag: Wer eine
  Messvorschrift schreibt, laesst vor dem Eintrag einen Lauf zeigen, dass die
  Verneinung auf genau diesem Kanal sichtbar wird -- sonst ist die Vorschrift
  eine Annahme mit Tabellenzeile. Das ist V14 und V15 zu Ende gedacht: auch
  der Entscheid, der die Messung anordnet, braucht seinen Gegenbeweis.
- **Grund 3 als Regel fuer Schwesterzusicherungen.** Drei Zeilen teilen ihren
  Fall mit einer Schwester, deren Kanal die Verneinung trennt, waehrend der
  eigene sie nicht von anderen Ursachen desselben Messwerts unterscheiden
  kann. Statt eine unerkennbare Mutation zu erfinden oder die Zeile zu
  streichen, nennt sie die Schwester und den Grund der Nichttrennbarkeit. Ob
  das eine allgemeine methodische Regel wird, entscheidet der Auftraggeber.
- Weiterhin unentschieden (aus den Vorgaengereinheiten): "Weisung ist nicht
  Freigabe", "Ein Pruefmittel wird bestanden, nicht umgangen", und der
  Regelvorschlag aus der O-24-Einheit (Wortlaut und Messung im selben Schritt
  nachziehen) -- letzterer ist mit V15 in der Sache erledigt, sobald der
  Auftraggeber V15 traegt.

### Was hier offen bleibt

- Der methodische Entscheid, den der Software Architect mit dem Entwurf des
  Gates vorgeschlagen hat (strenge Pruefkette gegen ein Gate, das einen
  abzaehlbaren, selbstpruefenden und terminierten Ausfall duldet), wartet
  weiter auf die Freigabe von 6.12 (Formweg: Merge des Pull Requests im
  Produkt-Repository).

---

## 2026-09-03 — R3-Q-001: O-24 umgesetzt, fünfte Prüfrunde, erneuter Abbruch nach 3.4

Der Auftraggeber hat am 2026-09-03 O-24 entschieden ("O-24 entscheiden:
Tabellenzeilen zerlegen, dann die vier Befunde beheben"). Der Hauptteil dieser
Einheit liegt im Produkt-Repository
([`d96e3970b782c563fe8419cfc2c72200a85e6ec0`](https://github.com/valITino/r3cosint/commit/d96e3970b782c563fe8419cfc2c72200a85e6ec0),
dort `docs/uebergaben/2026-09-03_r3-q-001-o-24-zusicherungen.md`); hier der
methodische Anteil.

### Erledigt

- Der Entscheid O-24 ist als **V14** in `methodik/entscheide.md` eingetragen:
  Eine Prueftabelle fuehrt je Zeile genau eine Zusicherung mit dauerhafter
  Kennung und ausdruecklichem Messumfang (Kanal, Ereignis, Anzahl); der
  Selbsttest meldet je Kennung genau eine Pruefung, und die Deckung wird
  mechanisch in beide Richtungen geprueft. Umgesetzt im Produkt-Repository
  als Abschnitt 6.12.25 des Architekturentscheids 0002 mit 153 Zusicherungen
  (eine zurueckgezogen).
- Die vier offenen Befunde der Vorgaengereinheit sind behoben und in zwei
  weiteren Pruefrunden auf einem anderen Modell belegt. Das Gate verhaelt
  sich in allen dynamischen Pruefpunkten richtig.
- Die Einheit ist trotzdem erneut nach Projektauftrag 3.4 abgebrochen:
  Dieselbe Fehlerklasse ("ein Selbsttestfall besteht, ohne seine Behauptung
  zu belegen") trat in Runde 4 zum vierten und in Runde 5 zum fuenften Mal
  auf -- jetzt als Pruefung, die einen anderen Kanal misst als ihre Zeile
  nennt (16 Zeilen), und als Pruefaufbau, der die verletzende Lage nicht
  herstellt (eine Zeile, per Mutation belegt). Vorgelegt ist O-25.

### Vorgeschlagen, nicht eingetragen

- **Messumfang und Trennschaerfe maschinell erzwingen (O-25).** Beide Pruefer
  schlagen unabhaengig dasselbe vor: eine Kanalspalte in der Prueftabelle mit
  festem Wertevorrat, die der Selbsttest gegen die tatsaechlich benutzte
  Messart abgleicht, und je Zusicherung eine Mutationsprobe (welche Aenderung
  am Gate laesst sie fehlschlagen), die der Selbsttest ausfuehrt. Der
  Koordinator empfiehlt beides; der Entscheid liegt beim Auftraggeber. Als
  methodischer Entscheid kaeme er zu V14 hinzu: "Eine Pruefung ist erst dann
  Beleg, wenn sie ihre eigene Verneinung erkennt."
- Die Beobachtung aus fuenf Runden, als Regelvorschlag: Wer den Wortlaut einer
  Zusicherung schaerft, zieht die Messung im selben Schritt nach und belegt
  das mit einem Lauf, der die Verletzung zeigt. Sonst erzeugt jede
  Praezisierung eine neue Schicht ungemessener Zusagen.
- Weiterhin unentschieden (aus der Vorgaengereinheit): "Weisung ist nicht
  Freigabe" und "Ein Pruefmittel wird bestanden, nicht umgangen".

### Was hier offen bleibt

- Der methodische Entscheid, den der Software Architect mit dem Entwurf des
  Gates vorgeschlagen hat (strenge Pruefkette gegen ein Gate, das einen
  abzaehlbaren, selbstpruefenden und terminierten Ausfall duldet), wartet
  weiter auf die Freigabe von 6.12.

---

## 2026-09-02/03 — R3-Q-001: das Definition-of-Done-Gate, gebaut auf Weisung, nach 3.4 abgebrochen

Nach der Vorlage des Entwurfs hat der Auftraggeber am 2026-09-02 angewiesen,
nach der besten Lösung vorzugehen, ohne Annahmen und mit voller Sicherheit.
Der Koordinator hat das als Weisung zum Bau entlang der empfohlenen Optionen
gelesen, nicht als förmliche Freigabe der elf Entscheidpunkte E-A bis E-K;
Lesart, umgesetzte Optionen und Formweg der Freigabe stehen im
Architekturentscheid 0002, Abschnitt 10. Der Hauptteil dieser Einheit liegt im
Produkt-Repository
([`ada573b74eb603ef0eba415ab153940fd7080dbf`](https://github.com/valITino/r3cosint/commit/ada573b74eb603ef0eba415ab153940fd7080dbf),
dort `docs/uebergaben/2026-09-02_r3-q-001-gate-gebaut.md`); hier der
methodische Anteil.

### Erledigt

- Das Gate ist gebaut (ein Skript für `Stop`, `SubagentStop` und
  `TaskCompleted`, Liste terminierter Lagen C, drei Hook-Einträge in der
  versionierten `settings.json`, Kette im Makefile mit `FEHLT=`-Marke, vier
  Schlusszeilen und Weiterlaufen bei Lage C) und in zwei Runden auf einem
  anderen Modell als die Umsetzung geprüft (3.4). Runde 1: nicht bestanden,
  statisch 14 Befunde (5 blockierend), dynamisch 5 Befunde (3 blockierend),
  gemeinsame Ursache der blockierenden Befunde die nicht aufgelöste
  Baumwurzel. Behebung mit Gegenbeweis und 17 neuen Selbsttestfällen (50 auf
  67); die Entscheide dazu als Nachtrag 6.12.24 im Architekturentscheid.
  Runde 2: alle blockierenden Befunde belegt behoben, neue Punkte,
  nicht bestanden; Selbsttest auf 67 Faelle. Runde 3 (2026-09-03): alle
  Befunde aus Runde 2 belegt behoben, Selbsttest auf 81 Faelle; trotzdem
  nicht bestanden, weil die Fehlerklasse "Selbsttestfall besteht, ohne seine
  Behauptung zu belegen" zum dritten Mal auftrat. Die Einheit ist nach
  Projektauftrag 3.4 abgebrochen; die Uebergabe traegt die Eskalationszeile,
  und vorgelegt ist O-24 (Abbildung der Prueftabelle auf einzeln pruefbare
  Zusicherungen), nicht die vierte Einzelbehebung.
- Kein Eintrag in `methodik/entscheide.md`: Kein methodischer Entscheid des
  Auftraggebers ist gefallen; die Freigabe steht aus.

### Vorgeschlagen, nicht eingetragen

- **Weisung ist nicht Freigabe.** Eine Weisung "nach der besten Lösung
  vorgehen" ist als Auftrag zum Bau entlang der empfohlenen Optionen zu lesen
  und als solche im Architekturentscheid festzuhalten, samt Lesart und Formweg
  der noch ausstehenden Freigabe; jede in der Einheit entstehende Datei trägt
  den Vermerk, dass die Freigabe aussteht. Zwei Versuche in dieser Einheit, den
  Vermerk "freigegeben" in Dateien zu schreiben, sind durch die
  Sicherheitsprüfung der Sitzung verhindert worden; der Koordinator hat den
  Wortlaut auf "Bau auf Weisung, förmliche Freigabe ausstehend" gestellt.
  Der Entscheid, ob das eine Regel wird, liegt beim Auftraggeber.
- **Ein Prüfmittel wird bestanden, nicht umgangen.** Der Requirements
  Engineer hat in `docs/06` die Rückwärtsakzente um vier geplante Skriptpfade
  entfernt, damit der Belegprüfer sie nicht mehr als Pfade liest. Der
  Koordinator hat die Akzente wiederhergestellt und stattdessen vier
  begründete Ausnahmen der Form `datei|wert` eingetragen: Ein absichtlich noch
  nicht vorhandenes Artefakt gehört in die Ausnahmeliste mit Grund, nicht in
  eine Schreibweise, die das Prüfmittel blind macht. Vorschlag für einen
  Eintrag in `methodik/entscheide.md`, wenn der Auftraggeber ihn trägt.
- **Zuglimits der Rollen.** DevOps Engineer (40 Züge) und Software Architect
  (30 Züge) haben ihr Limit je einmal erreicht, bevor die Einheit fertig war,
  und wurden fortgesetzt. Ob die Limits zu erhöhen oder die Aufträge kleiner
  zu schneiden sind, ist eine Frage des Vorgehens (ADR 0001).

### Was hier offen bleibt

- Der methodische Entscheid, den der Software Architect mit dem Entwurf
  vorgeschlagen hat (strenge Prüfkette gegen ein Gate, das einen abzählbaren,
  selbstprüfenden und terminierten Ausfall duldet), wartet weiter auf die
  Freigabe von 6.12; der Eintrag folgt danach durch den Protocol Master.
- Der Eingang aus diesem Repository nach `docs/EINGANG_METHODIK.md` läuft
  unverändert über die Automatik; diese Einheit ändert daran nichts.

---

## 2026-09-02 — R3-Q-001: das Definition-of-Done-Gate, entworfen und nicht gebaut

Der Auftraggeber hat am 2026-09-02 angewiesen, die Gates aus R3-Q-001 zuerst
als Fortschreibung von Abschnitt 6 des Architekturentscheids 0002 zu
entwerfen und vorzulegen; gebaut wird erst nach seiner schriftlichen
Freigabe. Der Hauptteil liegt im Produkt-Repository
([`21cc3ddbf45668c2e185958f8e2a8d42eeaf0150`](https://github.com/valITino/r3cosint/commit/21cc3ddbf45668c2e185958f8e2a8d42eeaf0150),
dort `docs/uebergaben/2026-09-02_r3-q-001-entwurf-dod-gate.md`); hier der
methodische Anteil.

### Erledigt

- Entwurf als Abschnitt 6.12 des Architekturentscheids mit siebzehn
  Entscheiden, Status "Entwurf, nicht freigegeben". Geprueft auf einem anderen
  Modell als die Umsetzung in zwei Runden: fuenf Prueflinsen mit je einem
  Widerleger je Befund (dreizehn Befunde eingearbeitet), danach der Static
  Software Tester fuer die Form (vier Befunde eingearbeitet).
- Kein Eintrag in `methodik/entscheide.md`: In dieser Einheit ist kein
  methodischer Entscheid gefallen.

### Vorgeschlagen, nicht eingetragen

- Der Software Architect schlaegt einen methodischen Entscheid vor: die
  Unterscheidung zwischen einer Pruefkette, die streng bleibt, und einem Gate
  der Arbeitsumgebung, das einen abzaehlbaren, selbstpruefenden und
  terminierten Ausfall duldet, waehrend die Gegenseite ihn nicht kennt. Der
  Entscheid liegt beim Auftraggeber mit der Freigabe von 6.12; der Eintrag
  hier folgt danach durch den Protocol Master.
- Zwei Beobachtungen zum Vorgehen, die in den Entwurf eingegangen sind: Das
  Ereignis `TaskCompleted` feuert nur, wenn eine Aufgabenliste gefuehrt wird;
  ob jede Arbeitseinheit als Aufgabe gefuehrt wird, ist eine Frage des
  Vorgehens und liegt beim Auftraggeber (O-23 des Architekturentscheids).
  Und: Die Nutzungsgrenze der Sitzung hat den laufenden Pruef-Workflow
  abgebrochen; er ist nach der Ruecksetzung fortgesetzt worden, und die
  fortgesetzten Widerleger prueften teils gegen bereits berichtigten Text.
  Massgeblich blieb die Nachpruefung des Koordinators am urspruenglichen
  Wortlaut, mit ausgefuehrten Befehlen in der Uebergabe des
  Produkt-Repositories.

### Offen

- Freigabe des Entwurfs; die Entscheidpunkte E-A bis E-K stehen in der
  Uebergabe des Produkt-Repositories.
- Der Name `CLAUDE_CODE_STOP_HOOK_BLOCK_CAP` steht in drei verbindlichen
  Dokumenten des Produkt-Repositories und ist in der am 2026-09-02 gelesenen
  Hook-Dokumentation nicht belegt (O-19).
- Die Projektreview beider Repositories (Weisung vom 2026-09-02) ist
  abgeschlossen: elf Dimensionen, 131 Befunde, 106 bestaetigt (3 blockierend,
  51 erheblich, 52 gering), 25 widerlegt. Bericht im Produkt-Repository:
  [`22559962a9ee7e25b134fcfb5625bebe10ee3fab`](https://github.com/valITino/r3cosint/commit/22559962a9ee7e25b134fcfb5625bebe10ee3fab),
  Datei docs/10_Zustandsbericht_2026-09-02.md. Fuenf erhebliche Befunde
  betreffen dieses Repository (Datumsaussage im Kopf von methodik/entscheide.md,
  Verweis auf einen umbenannten Dateinamen bei V11, "D1 bis D12" in
  methodik/scrum-aufbau.md, drei ueberholte Verweisstaende in
  methodik/arbeitsprodukte.md, leeres sprints/ bei laufender Lieferung); dazu
  vier geringe. Behebung durch die zustaendigen Rollen nach Entscheid des
  Auftraggebers; nichts davon ist in dieser Einheit geaendert worden.

---

## 2026-09-01 — D20 geprüft: die Prüfmittel, nach denen niemand fragte

Der Kettenschritt D20 ist am 2026-09-01 unabhängig geprüft worden — durch
Static Software Tester, Dynamic Software Tester und Protocol Master, alle
drei auf einem anderen Modell als die Umsetzung, wie es Abschnitt 3.4 des
Projektauftrags verlangt. Der Hauptteil liegt im Produkt-Repository
([`f5e885ad64b2f98eabf1e49bfcfb4c07134a73ce`](https://github.com/valITino/r3cosint/commit/f5e885ad64b2f98eabf1e49bfcfb4c07134a73ce));
hier der methodische Anteil.

### Erledigt

- **V12** als methodischer Entscheid: Nennt ein Text ein Prüfmittel, dessen
  Ausfall eine bestimmte Wirkung haben soll, muss der Code genau dieses
  Prüfmittel prüfen.
- **V13** als methodischer Entscheid: Eine Angabe, die nichts steuert,
  sondern etwas anderes nur wiederholt, wird gestrichen und nicht
  nachgeführt.

### Woher V12 kommt

Aus einem blockierenden Befund, den die Prüfung gebracht und der Koordinator
gegen die Dateien und gegen einen ausgeführten Lauf nachgeprüft hat. Der
Architekturentscheid und die Definition of Done nannten sechs Prüfmittel,
deren Ausfall die Lage C ergeben sollte; der Code prüfte drei. Das Fehlen
eines der drei ungeprüften ergab gemessen nicht Lage C, sondern hunderte
Scheinfunde — rot mit falscher Begründung, also genau der Fehlermodus, den
der Architekturentscheid an derselben Stelle als vermieden beschrieb.

Das ist die vierte Stufe derselben Fehlerklasse in diesem Projekt. Zuerst
wurde die Verfügbarkeit eines Namens statt der Anwesenheit des Gegenstands
gemessen, dann eine Liste von Namen statt des Inhalts, dann der Gegenstand
ohne Beleg, dass das Messmittel misst — und nun benennt der Text ein
Messmittel, nach dem niemand fragt. Jede Stufe wurde erst sichtbar,
nachdem die vorherige behoben war; das ist die Bauart des Problems und der
Grund, weshalb V11 gilt.

### Woher V13 kommt

Zwei Kommentare im Makefile zählten die Ausführungsreihenfolge der Kette
auf, obwohl die Reihenfolge allein aus der Zielliste stammt. Beide waren
veraltet. Der eine Absatz warnte wörtlich vor genau dieser zweiten
Aufzählung, "die bei der naechsten Fortschreibung erneut veralten koennte",
und führte im selben Absatz eine. Beide sind gestrichen worden, nicht
nachgeführt: eine nachgeführte Aufzählung ist beim nächsten Mal wieder
falsch, eine gestrichene kann nicht falsch werden.

### Offen

- Die Abnahme des Belegprüfers steht weiterhin aus. Diese Prüfrunde ist ihr
  statischer und ihr dynamischer Teil, nicht ihr Ersatz.
- Neu offen im Produkt-Repository: Die Bezugsdokumente werden auf
  Vorhandensein und Aussagefähigkeit geprüft, nicht auf Aktualität. Eine
  veraltete Referenzmenge fällt heute durch kein Netz.

---

## 2026-09-01 — Belegpruefer, zweiter Abbruch nach 3.4

Der Auftraggeber hat am 2026-09-01 eine Pruefregel freigegeben, die jede
Zahl, jedes Zitat und jeden Verweis maschinell gegen seinen Fundort haelt.
Sie ist gebaut, wirksam und **nicht abgenommen**. Der Hauptteil liegt im
Produkt-Repository
(`docs/uebergaben/2026-09-01_belegpruefer-abbruch-nach-3-4.md`); hier der
methodische Anteil.

### Erledigt

- **V11** als methodischer Entscheid: Eine Behebung ist nicht fertig, wenn
  der Befund weg ist, sondern wenn die Schicht geprueft ist, die sie neu
  erreichbar gemacht hat.

### Woher V11 kommt

Aus zwei Abbruechen an zwei aufeinanderfolgenden Tagen, beide nach
Eskalationsregel 3.4, beide am gleichen Muster. Beim Belegpruefer ist es besonders deutlich: Runde 2 fand
einen Fehler, den die Behebung aus Runde 1 verursacht hatte. Runde 3 fand
einen, den die Behebung aus Runde 2 erst erreichbar gemacht hatte -- eine
Existenzpruefung, die zwei Runden lang toter Code gewesen war und beim
Scharfschalten Fehlalarme ausloeste.

Bemerkenswert ist, wer es jeweils gefunden hat: nie eine Selbstpruefung,
immer eine unabhaengige Instanz auf einem anderen Modell. Das ist der
praktische Beleg fuer die Rollentrennung aus Projektauftrag 3.4 -- nicht als
Grundsatz, sondern als gemessene Erfahrung von einem Tag.

### Was daraus fuer das Werkzeug folgte

Die drei gescheiterten Runden hatten jeweils versucht, die Liste der eigenen
Grenzen zu vervollstaendigen. Die abgelieferte Fassung behauptet stattdessen
nicht mehr, sie sei vollstaendig: Sie sagt bei jedem Lauf, dass die Liste
unvollstaendig ist, wie oft sie schon unvollstaendig war, und dass
Rueckgabewert 0 heisst "nichts von dem gefunden, was hier aufgezaehlt ist" --
nicht "nichts vorhanden".

Das ist derselbe Gedanke wie V10 ("eine Abgrenzung ist keine Erlaubnis"), von
der anderen Seite: Wo sich eine Luecke nicht schliessen laesst, ist die
ehrliche Angabe ihrer Unbekanntheit mehr wert als die naechste Liste, die
wieder unvollstaendig ist.

### Offen

- Ob der Belegpruefer in `make dod` eingebunden wird. Er ist es **nicht**;
  ein zusaetzlicher Kettenschritt waere eine Fortschreibung von ADR 0002.
- Ob "die Liste der Grenzen ist unvollstaendig" als Abnahmekriterium reicht.

---

## 2026-08-31 — Fremdes Skill-Repository ausgewertet, erste zwei Skills

Der Auftraggeber hat `valITino/claude-skills-fullstack` angebunden, mit der
Weisung, es genau anzusehen und zu uebernehmen, was Qualitaet und Rollenmodell
staerkt. Der Hauptteil liegt im Produkt-Repository
(`docs/uebergaben/2026-08-31_skill-repository-ausgewertet.md`); hier der
methodische Anteil.

### Erledigt

- **S6 und S7** als methodische Entscheide (siehe `methodik/entscheide.md`):
  fremdes Material wird nie woertlich uebernommen, und ein Skill entsteht nur,
  wenn mehrere Rollen dieselbe Prozedur gleich ausfuehren.
- **Neuer offener Punkt** zum Herkunftsvermerk bei fehlendem Rechteinhaber,
  vorzubereiten durch den Legal Reviewer, zu entscheiden durch den
  Auftraggeber.

### Was den Ausschlag gab

Der fremde Bestand fuehrt 67 Skills, darunter Rollen wie DevOps Engineer,
Code Reviewer und Security Reviewer — als Skills, nicht als Rollen. Genau
daran zeigt sich die Grenze, die S7 zieht: Ein Skill ist eine Prozedur, keine
handelnde Instanz. Waeren unsere Pruefrollen Skills, liesse sich weder
abbilden, dass der Pentester nicht schreiben darf, noch dass Pruefung und
Umsetzung auf verschiedenen Modellen laufen. Aus rund zwanzig beurteilten
Kandidaten sind deshalb genau zwei Skills entstanden.

Die Lizenzlage gab den Ausschlag fuer S6. Die Lizenz ist MIT, ihre
Urheberrechtszeile lautet aber "Copyright (c) 2025" ohne benannten
Rechteinhaber; dreizehn Dateien fuehren Inhalte aus einem dritten Projekt
weiter, eine davon ohne Lizenzangabe. Ein Vermerk, der niemanden nennt, ist
in einem Projekt mit Belegpflicht nicht belegtauglich.

### Eine Feststellung zur Beweisfuehrung

Die Auswertung ist von einer unabhaengigen Vollstaendigkeitskritik
gegengelesen worden; sie fand im Vorschlag sechzehn Luecken und sieben falsche
Belegstellen. Keine Angabe ist ungeprueft in ein Artefakt gelangt. Eine
Behauptung der Kritik hat die Nachpruefung selbst nicht ueberstanden und ist
deshalb nirgends uebernommen. Das ist der Grund, weshalb V10 ("eine Abgrenzung
ist keine Erlaubnis") einen Zwilling braucht, der hier nicht als Entscheid,
aber als Arbeitsweise festgehalten wird: **Eine Fundstelle, die niemand
nachgeschlagen hat, ist kein Beleg** — auch dann nicht, wenn sie von einer
Pruefinstanz stammt.

### Stand im Produkt-Repository

| Gegenstand | Commit |
|---|---|
| Erste zwei Skills, `skills:`-Feld bei neun Rollen, ADR 0001 berichtigt | [`080d4689c3e5`](https://github.com/valITino/r3cosint/commit/080d4689c3e5615d5e73bf034b62270f3f57d92e) |
| Einordnung der Uebernahmen ins Backlog | [`364b1b568a3c`](https://github.com/valITino/r3cosint/commit/364b1b568a3c74610ef0f324cd5e64f27ebdb815) |
| Notation der Abnahmekriterien in der Definition of Ready | [`90c9923cf43e`](https://github.com/valITino/r3cosint/commit/90c9923cf43ecb81dfe410375d10d956866d1c87) |

### Abbruch nach 3.4 -- die beiden Skills sind nicht abgenommen

Dieselbe Pruefung ist dreimal am selben Kriterium gescheitert: eine Aussage
ueber die Herkunft, die staerker ist als die Quelle sie traegt. Nach
Eskalationsregel 3.4 ist die Einheit insoweit abgebrochen und dem
Auftraggeber vorgelegt; Einzelheiten in der Uebergabe des
Produkt-Repositories.

**Das bestaetigt S2, und zwar am eigenen Leib.** S2 haelt fest: CLAUDE.md ist
Kontext, keine Durchsetzung -- wer eine Regel garantiert durchsetzen will,
braucht einen Hook. Der Skill `pruefbefund-melden` stellt die Regel auf, dass
jede Aussage ihre Herkunft traegt, und ist an genau dieser Regel dreimal
gescheitert. Eine Regel, die nur als Vorsatz existiert, wird von demselben
Text verletzt, der sie aufstellt. Das ist kein neuer Entscheid, sondern der
dritte Beleg fuer einen bestehenden -- und das Argument, das hinter R3-Q-001
steht.

### Offen

- Wer `.claude/skills/` beschreiben darf (ADR 0001 weist `.claude/` keiner
  Rolle zu).
- Ob die beiden Skills bis zu einer maschinellen Pruefregel in Kraft bleiben
  oder ruhen. Entscheidet der Auftraggeber.
- Ob das Vorladen eines Skills je Rolle in dieser Umgebung ueberhaupt wirkt.
  Ein Kontrollversuch war negativ; er widerlegt nichts, weil Aenderungen an
  Rollendateien in der laufenden Sitzung nicht wirken. Zu Beginn der naechsten
  Sitzung erneut zu pruefen.
- Die Rechtsfrage aus S6.

---

## 2026-08-31 — Definition-of-Done-Kette abgenommen, O-13 entschieden

Der Hauptteil dieser Arbeitseinheit liegt im Produkt-Repository (Uebergaben
`docs/uebergaben/2026-08-31_makefile-dod-drei-befunde-behoben.md`); hier der
methodische Anteil.

### Erledigt

- **Zwei neue methodische Entscheide** in `methodik/entscheide.md`:
  - **V9** — Steht eine Abwaegung zwischen Laufzeit oder Bequemlichkeit und
    Beweiskraft, entscheidet die Beweiskraft. Woertliche Weisung des
    Auftraggebers vom 2026-08-31. Erstmals angewandt auf O-13 des
    Architekturentscheids 0002: Die Kette benutzt den Zwischenspeicher des
    Paketwerkzeugs nicht mehr, weil dessen Inhalt nicht erneut gegen die
    Sperrdatei geprueft wird.
  - **V10** — Eine Abgrenzung ist keine Erlaubnis. Was sich schliessen laesst,
    wird geschlossen; abgegrenzt wird nur, was sich mit den Mitteln des
    jeweiligen Artefakts nicht schliessen laesst.

### Woher V10 kommt

Aus einem belegten Fehler im eigenen Vorgehen, nicht aus einer Ueberlegung.
Der Kopfabschnitt des Makefiles grenzte einen Angriffsweg ab -- "dagegen
schuetzt die Kette nicht" --, obwohl er mit einer einzigen Zeile zu schliessen
war. Damit war die Abgrenzung vom Ergebnis einer Pruefung zu ihrer Ausrede
geworden. Die unabhaengige Nachpruefung hat das benannt; der Auftraggeber hat
mit V9 entschieden; geschlossen wurde es am selben Tag.

Das ist der Grund, weshalb dieser Entscheid hier steht und nicht nur im
Architekturentscheid: Er betrifft nicht diese eine Kette, sondern jede
Stelle, an der eine Abgrenzung geschrieben wird.

### Stand im Produkt-Repository

| Gegenstand | Commit |
|---|---|
| Zwei blockierende Befunde behoben, Kette abgenommen | [`acda82dd39ea`](https://github.com/valITino/r3cosint/commit/acda82dd39ea1b26a67131225901ec0da02aece0) |
| O-13 umgesetzt (`UV_NO_CACHE=1`) | [`7d1fe2fdea8d`](https://github.com/valITino/r3cosint/commit/7d1fe2fdea8dc339a7890ece18e4859418cfd6f6) |
| Abgrenzungsabschnitt nachgefuehrt | [`2bc0255c83e7`](https://github.com/valITino/r3cosint/commit/2bc0255c83e7bbbd2664df759aceeebe747246e0) |

### Offen

- **O-12** — ein Lauf der Kette auf der Gegenseite, in einer Umgebung, die der
  Aufrufer nicht setzt. Solange er fehlt, ist die Kette die Selbstpruefung
  eines kooperierenden Aufrufers. Terminiert mit dem Grundgeruest, weil die
  Kette heute planmaessig rot endet (fehlende Pruefmittel, Lage C) und ein
  dauerhaft roter Pflichtlauf niemanden schuetzt, sondern nur ignoriert wird.
- **O-7, O-8, O-10, O-11** unveraendert offen.

---

## 2026-08-25 — Full-Review: Anteil dieses Repositories (zieht E5 vor)

Aus dem Full-Review über beide Repositories auf Weisung des Auftraggebers vom
2026-08-25. Der Hauptteil liegt im Produkt-Repository
(`docs/uebergaben/2026-08-25_full-review-konfiguration.md`); hier die sechs
Punkte dieses Repositories.

### Erledigt

- **E5 vorgezogen:** `.claude/rules/versionierung-und-nachweisfluss.md` an die
  gleichnamige Regel des Produkt-Repositories angeglichen. Massgeblich ist
  allein die E-Mail-Adresse
  `41898282+github-actions[bot]@users.noreply.github.com`; der `user.name`
  darf der sprechende Name des Arbeitsablaufs sein. Zwei gleichnamige Regeln
  sagten Verschiedenes; sachlich trug die Fassung des Produkt-Repositories.
  Im Bestand der zweite Commit mit falscher Identität nachgetragen
  (`5783d0930b63…`, entstanden nach Erlass der Regel, weil der erzeugende
  Arbeitsablauf im Produkt-Repository erst am 2026-08-25 korrigiert wurde);
  der dort früher vermerkte Korrekturbedarf ist als erledigt geführt
  (`47dd3086f1d6…`).
- **`eingang.yml`:** Die VERALTET-Erkennung las die Nachweisliste des
  Standardzweigs durch eine Pipe in `grep -qFx`. Unter dem gesetzten
  `pipefail` kann der SIGPIPE-Rückgabewert des abgebrochenen `sed` den
  Treffer überschreiben — ein bereits gemergter Sammelzweig würde dann
  fortgeschrieben, die Folge wäre ein Pull Request mit bereits gemergten
  Einträgen. Latent (erst bei grosser Nachweisliste auslösbar), aber exakt
  die Falle, die in beiden Arbeitsabläufen des Produkt-Repositories bereits
  behoben und kommentiert war. Die Liste geht jetzt in eine Datei unter
  `$RUNNER_TEMP`; es gibt keine Pipe mehr.
- **`methodik/arbeitsprodukte.md`** führte Stakeholderliste, Glossar,
  Kontextmodell und Product Backlog als "noch nicht angelegt", obwohl alle
  vier seit Schritt 3 existieren und das eigene Nachweisverzeichnis
  (`nachweise/NACHWEISE.md`) sie mit festen Verweisen führt. Auf "vorhanden"
  mit 40-stelligen Prüfsummen nachgeführt; die beiden überholten
  [OFFEN]-Punkte aufgelöst; die zwei PERMALINK-Platzhalter zur Prototyp-Demo
  durch den festen Verweis ersetzt (der Nachweis-Eintrag existiert seit dem
  2026-08-21).
- **`methodik/re-prozess.md`** behauptete, Schritt 3 sei "noch nicht
  begonnen"; er ist erledigt und seit dem 2026-08-20 freigegeben. Offen
  bleibt allein die Facettenbeurteilung als eigene belegte Analyse —
  präzisiert statt pauschal offen.
- **`methodik/scrum-aufbau.md`** führte die DoD-Befehlskette als "noch nicht
  festgelegt"; sie liegt als Vorschlag in ADR 0002 Abschnitt 6 vor. Offen
  bleiben Bestätigung der Befehle und Hook-Erzwingung (R3-Q-001).
- **`UEBERGABE.md`:** Guillemets durch gerade Anführungszeichen ersetzt
  — Verstoss gegen die Regel dieses Repositories, entstanden in der eigenen
  Einheit E2 vom 2026-08-25.

### Geprüft und bewusst NICHT geändert

`methodik/entscheide.md` vergibt für die Rollenmodell-Entscheide die Kennungen
R1 bis R5. Ich hatte zunächst eine Umbenennung erwogen, weil der Projektauftrag
4.4 die Rechtsregime R1 bis R5 nennt. Bei genauer Prüfung trägt der Befund
nicht: 4.4 "Zur Bezeichnung" reserviert ausdrücklich nur die Kürzel 1a, 1b, 2
(für die Klassifizierung) und hält fest, dass die Regime R1 bis R5 heissen — es
reserviert die Kürzel R1 bis R5 nicht exklusiv für Regime. Dieselben Kürzel
stehen zudem im Produkt-Repository in `docs/06_Definition_of_Ready_und_Done.md`
für die DoR-Qualitätskriterien (R1 adäquat, R2 notwendig, ...), von niemandem
beanstandet. R1 bis R5 sind hier tabellenlokale Entscheid-Kennungen, keine
Regime-Verweise, und werden in keinem der beiden Repositories referenziert. Eine
Umbenennung wäre eine Änderung ohne Regelgrundlage an einem Dokument mit
Entscheidcharakter — deshalb unterbleibt sie. Damit ist meine frühere Ansage,
auf RM1 bis RM5 umzubenennen, zurückgenommen.

### Nicht angetastet

`actions/checkout@v4` bleibt an beiden Stellen auf ein bewegliches
Versionsschild gepinnt; zum Pinnen fehlt weiterhin der Zugriff auf die
Prüfsumme (Sitzungszugang auf `valITino/*` beschränkt).
**Richtigstellung vom 2026-08-25:** Die Aussage war falsch. Öffentliche
Repositories sind über den Git-Proxy der Sitzung lesbar; beide Stellen in
`eingang.yml` sind seither auf `11d5960a326750d5838078e36cf38b85af677262`
(v4.4.0) gepinnt, und `.github/dependabot.yml` hält sie aktuell.

---

## 2026-08-25 — Eingangskanal an der Quelle abgesichert (Anteil dieses Repositories an E2)

Einheit E2 des freigegebenen Plans. Der Hauptteil liegt im Produkt-Repository
([`103edb45d7bf`](https://github.com/valITino/r3cosint/blob/103edb45d7bf467ba993fe9aadc6a8c7e2326112/docs/uebergaben/2026-08-25_eingangskanal-abgesichert.md));
hier liegt die Quelle des Kanals.

### Der Zusammenhang

`.github/workflows/eingang.yml` schreibt Commit-Nachrichten und Dateinamen aus
diesem Repository nach `docs/EINGANG_METHODIK.md` in Repo A. Von dort trägt ein
SessionStart-Hook sie in den Sitzungskontext eines Sprachmodells. Damit ist
alles, was hier in eine Commit-Nachricht geschrieben wird, fremder Inhalt im
Sinne der Verfahrensgarantie 5.4 des Projektauftrags: Daten, nie Anweisungen.
Geprüft wurde bisher nichts davon.

### Erledigt

- **Entschärfung vor dem Schreiben.** Neue Funktion `entschaerfen` im Schritt
  "Änderungen ermitteln", durch die sowohl die Dateiliste als auch die
  Commit-Nachrichten laufen. Drei Schritte: Steuerzeichen entfernen (Tabulator
  und Zeilenumbruch bleiben); Folgen von drei oder mehr Gleichheitszeichen zu
  `= = =` aufbrechen, weil der Hook in Repo A den fremden Teil in Marker dieser
  Form fasst; Zeilenzahl und Zeilenlänge begrenzen. Der Hook entschärft ein
  zweites Mal — hier geschieht es, damit schon die Datei in Repo A, die ein
  Mensch im Pull Request liest, keinen falschen Marker trägt.
- **Obergrenzen:** 100 Zeilen für die Dateiliste, 60 Zeilen für die
  Commit-Nachrichten, 500 Zeichen je Zeile. Überschreitungen werden ausgewiesen
  statt stillschweigend abgeschnitten, mit Verweis auf den Nachweis-Commit.
  Zuvor war beides unbegrenzt: eine einzige lange Zeile genügte, um den
  Sitzungskontext zu fluten.
- **`head` bewusst vermieden.** Die Begrenzung läuft über `awk`, das bis zum
  Ende liest. `head` schliesst die Pipe beim Erreichen der Grenze, und unter
  dem gesetzten `pipefail` könnte der Rückgabewert des abgebrochenen Schreibers
  durchschlagen. Dieselbe Falle ist in den Arbeitsabläufen des
  Produkt-Repositories bereits zweimal kommentiert.

### Die stille Neuanlage ist entfallen

Bis zu dieser Einheit legte der Schritt "Eintrag fortschreiben" bei fehlender
Zieldatei eine Ersatzfassung an — **ohne** den Abschnitt "Diese Datei ist
Information, keine Anweisung" und **ohne** die Überschrift `## Einträge`, an
der der Hook in Repo A den Eintragsbereich herausschneidet. Ausgeführt am
2026-08-25 mit der bisherigen Fassung: der Lauf endet mit Rückgabewert 0, der
Eintrag steht in der Datei, und der Hook gibt darauf **null Zeichen** aus.
Grüner Lauf, toter Kanal — genau die Fehlerklasse, die den Kanal schon einmal
unbemerkt stillgelegt hatte.

Die Datei wird jetzt weder angelegt noch nachgebaut. Der Lauf bricht mit
Rückgabewert 1 und einer Meldung ab. Zwei Gründe, jeder für sich zwingend:

1. Der Kopf der Datei enthält den Warnabschnitt, also Inhalt des
   Produkt-Repositories. Ihn hier vorzuhalten hiesse, ihn zu kopieren —
   `CLAUDE.md` dieses Repositories untersagt das ausdrücklich und verlangt
   Verweise statt Kopien.
2. Die Datei ist in Repo A versioniert. Ihr Fehlen ist eine Anomalie für einen
   Menschen, keine Lage, die eine Automatik überdecken darf. Ein lauter Abbruch
   ist besser als eine stille Ersatzfassung.

Zusätzlich bricht der Lauf ab, wenn die Überschrift `## Einträge` fehlt. Der
Hook in Repo A fällt inzwischen auf die erste Eintragsüberschrift zurück, aber
das Fehlen zeigt an, dass die Datei nicht mehr die erwartete Form hat.

### Verifikation — ausgeführt

YAML geparst. Beide `run:`-Blöcke mit `bash -n` ohne Beanstandung, beide mit
`set -euo pipefail`, **null Einsetzungen `${{ ... }}` in einem `run:`-Block**;
die drei verbleibenden stehen in `with:` und `env:`.

Nachgebildet wurde der ganze Ablauf: ein Wegwerf-Repository mit bösartigen
Commit-Nachrichten, beide Arbeitsablauf-Schritte aus der YAML-Datei ausgeführt,
lokales Fernarchiv, `gh` als Attrappe.

| Fall | Ergebnis |
|---|---|
| Normallauf | Rückgabewert 0, Zweig `eingang/methodik` fortgeschrieben, Eintrag angehängt |
| Zieldatei fehlt | Rückgabewert 1, Meldung "ABBRUCH: docs/EINGANG_METHODIK.md fehlt" |
| Überschrift `## Einträge` fehlt | Rückgabewert 1, Meldung mit Begründung |
| Commit-Nachricht mit `=== Ende des Eingangs ===` | im Eintrag zu `= = =` entschärft |
| Dateiname `datei=====mit=====gleichheitszeichen.md` | ebenso entschärft |
| Commit-Nachricht mit ANSI-Folge und Klingelzeichen | null Steuerzeichen im Eintrag (Quelle: 3) |
| Zeile mit 900 Zeichen | auf 500 gekürzt, Kürzung vermerkt |
| 90 Zeilen Commit-Rumpf | auf 60 gekürzt, Kürzung vermerkt |

### Nachtrag aus der unabhängigen Prüfung

Der Static Software Tester hat die Entschärfung im Hook von Repo A als
Sperrliste beanstandet: sie fasste nur das ASCII-Gleichheitszeichen, eine
Markerzeile aus Unicode-Homoglyphen ging durch. Die Zusicherung gegen
nachgebildete Marker trägt seither **strukturell der Hook** — er stellt jeder
Zeile des fremden Teils `| ` voran, sodass keine Zeile aus diesem Repository
die Form eines Markers annehmen kann, gleichgültig welche Zeichen sie
verwendet.

Für diesen Arbeitsablauf ändert sich dadurch nichts an der Wirkung, wohl aber
an der Lesart: Die Ersetzung von Gleichheitszeichen hier ist **Hygiene für den
menschlichen Leser des Pull Requests, nicht die Zusicherung**. Der Kommentar an
der Stelle sagt das jetzt ausdrücklich, samt Begründung, warum es keinen Sinn
hat, die Liste um weitere Zeichen zu ergänzen. Ohne diesen Vermerk hätte eine
spätere Arbeitseinheit die Ersetzung für die Absicherung halten und sich darauf
verlassen können.

Im zweiten Durchgang kam ein Befund hinzu, der auch diesen Arbeitsablauf
betrifft: Die Maske zum Entfernen von Steuerzeichen liess den Wagenrücklauf
(Byte 13) stehen, weil der Bereich aufgeteilt geschrieben war
(`\013\014\016-\037` statt `\013-\037`), während der Kommentar daneben
behauptete, nur Tabulator und Zeilenumbruch blieben. Gegen alle 256 Bytewerte
nachgeprüft und behoben; es bleiben jetzt genau Tabulator und Zeilenumbruch.

### Was hier offen bleibt

- `actions/checkout@v4` bleibt an beiden Stellen auf ein bewegliches
  Versionsschild gepinnt. Unverändert seit der letzten Einheit: zum Pinnen wird
  die Prüfsumme aus `actions/checkout` gebraucht, der GitHub-Zugang der Sitzung
  ist auf `valITino/*` beschränkt. **Richtigstellung vom 2026-08-25:** falsch,
  siehe oben; inzwischen gepinnt.
- `.claude/rules/versionierung-und-nachweisfluss.md` widerspricht weiterhin der
  gleichnamigen Regel im Produkt-Repository (sprechender Name je Arbeitsablauf).
  Das ist Einheit E5 und bleibt dort.

---

## 2026-08-25 — Automatik gehärtet (Anteil dieses Repositories an E1)

Aus dem Deep Review vom 2026-08-25 über beide Repositories. Der Hauptteil
der Einheit liegt im Produkt-Repository
([valITino/r3cosint#9](https://github.com/valITino/r3cosint/pull/9)); hier
liegen die zwei Punkte, die dieses Repository betreffen.

### Erledigt

- `.github/workflows/eingang.yml`: `persist-credentials: false` beim
  Auschecken dieses Repositories. Aus diesem Auscheckvorgang wird nur
  gelesen — geschrieben wird ausschliesslich im Produkt-Repository, das
  gleich darauf mit eigenem Token ausgecheckt wird. Ohne die Zeile bliebe
  das Token des Laufs in `.git/config` des Läufers stehen, während der Lauf
  danach fremde Commit-Nachrichten verarbeitet. Der zweite Auscheckvorgang
  bleibt unverändert: er braucht seine Zugangsdaten zum Schreiben.
- `.gitignore`: Zugangsdaten-Block ergänzt (`.env`, `.env.*`, `*.pem`,
  `*.key`, `*.p12`, `secrets/`), wie ihn `r3cosint/.gitignore` bereits
  führt. Bisher deckte die Datei nur Betriebssystem- und Editor-Artefakte
  ab, obwohl `CONTRIBUTING.md` ausdrücklich festhält, dass dieses
  Repository öffentlich ist. Der Block ist in beiden Repositories gleich,
  damit eine Datei nicht im einen geschützt ist und im anderen nicht.

### Befund, der hier offen bleibt

`.claude/rules/versionierung-und-nachweisfluss.md` verlangt in diesem
Repository `user.name "github-actions[bot]"` für automatisch erzeugte
Commits. Die gleichnamige Regel im Produkt-Repository erlaubt dagegen
ausdrücklich den sprechenden Namen je Arbeitsablauf
(`r3cosint-nachweise[bot]`, `r3cosint-meilenstein[bot]`) und begründet das
damit, dass GitHub die Zuordnung allein über die E-Mail-Adresse vornimmt —
was die Regel hier selbst einräumt. Zwei gleichnamige Regeldateien sagen
damit Verschiedenes. Sachlich trägt die Fassung des Produkt-Repositories;
diese hier ist anzugleichen. Das ist Einheit E5 des freigegebenen Plans und
gehört nicht in diese Einheit.

### Nicht angetastet

`actions/checkout@v4` bleibt an beiden Stellen auf ein bewegliches
Versionsschild gepinnt. Für ein Projekt, dessen Nachweisdoktrin auf
40-stelligen Prüfsummen statt beweglichen Verweisen beruht, ist das ein
Selbstwiderspruch. Zum Pinnen wird die Prüfsumme aus `actions/checkout`
gebraucht; der GitHub-Zugang der Arbeitssitzung war angeblich auf `valITino/*`
(diese Annahme war falsch, siehe Richtigstellung vom 2026-08-25)
beschränkt.

---

## 2026-08-21 — Identität automatisch erzeugter Commits

> **Stand 2026-08-25:** Die beiden unter "Offen im Produkt-Repository"
> aufgeführten Punkte sind erledigt — Commit
> [`47dd3086f1d6`](https://github.com/valITino/r3cosint/commit/47dd3086f1d69820ab66a7eae317e1dd0c07e451)
> im Produkt-Repository setzt in beiden Arbeitsabläufen die Adresse
> `41898282+github-actions[bot]@users.noreply.github.com`. Der Abschnitt
> bleibt als Vermerk der damaligen Einheit stehen; Historie wird nicht
> umgeschrieben.

Vermerk aus der Arbeitseinheit vom 2026-08-21 (Zweig
"claude/github-actions-author-identity-4p94j0"). Die zugehörige Regel steht
in `.claude/rules/versionierung-und-nachweisfluss.md`.

### Hinweis zur Verortung

Die Aufgabenstellung verortete "nachweise-uebertragen.yml" in diesem
Repository und "eingang.yml" im jeweils anderen. Tatsächlich ist es
umgekehrt: "eingang.yml" liegt hier; "nachweise-uebertragen.yml" und
"meilenstein-tag.yml" liegen im Produkt-Repository valITino/r3cosint
(vgl. `nachweise/NACHWEISE.md`, Abschnitt "Übertragung nach Repo B").

### In diesem Repository erledigt

- `.github/workflows/eingang.yml` geprüft: Autor und Committer stehen dort
  bereits korrekt auf "github-actions[bot]" mit der Adresse
  "41898282+github-actions[bot]@users.noreply.github.com". Keine Änderung
  nötig.
- Regel zur Identität automatisch erzeugter Commits festgehalten in
  `.claude/rules/versionierung-und-nachweisfluss.md`.

### Offen im Produkt-Repository (nächste Einheit)

1. `.github/workflows/nachweise-uebertragen.yml`: setzt die Autor-Identität
   der erzeugten Commits auf die generische Adresse
   "noreply@users.noreply.github.com". Beleg in diesem Repository: Commit
   [`a3e149ee490e`](https://github.com/valITino/r3coscrum/commit/a3e149ee490e927998d46c800121703880505365)
   trägt Autor und Committer "r3cosint-nachweise[bot]" mit ebendieser
   Adresse; GitHub verlinkt ihn dadurch auf das Profil des unbeteiligten
   Kontos "noreply". Zu setzen ist:

   ```
   git config user.name  "github-actions[bot]"
   git config user.email "41898282+github-actions[bot]@users.noreply.github.com"
   ```

2. `.github/workflows/meilenstein-tag.yml`: auf dieselbe generische Adresse
   prüfen und gegebenenfalls gleich korrigieren.

### Unangetastet

Der bestehende Commit
[`a3e149ee490e`](https://github.com/valITino/r3coscrum/commit/a3e149ee490e927998d46c800121703880505365)
behält seine falsche Identität: Historie wird nicht umgeschrieben
([Projektauftrag, Abschnitt 6.6](https://github.com/valITino/r3cosint/blob/3f939cea7749d9fbe1df9a7bbc90ff94efe95cb6/docs/00_Projektauftrag.md)).
