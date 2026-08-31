# Übergabe — Makefile mit `make dod`, drei Befunde behoben

| | |
|---|---|
| **Arbeitsprodukt nach** | Projektauftrag 3.3 (Übergabedatei je Arbeitseinheit) |
| **Einheit** | Zwischenschritt vor R3-Q-001 auf Weisung vom 2026-08-29, fortgesetzt auf die Weisung vom 2026-08-31 |
| **Datum** | 2026-08-31 |
| **Zweig** | `claude/next-step-g8slnq` |
| **Vorgänger** | `docs/uebergaben/2026-08-30_makefile-dod-abbruch-nach-3-4.md` |
| **Ergebnis** | **Abgenommen.** Zwei blockierende und ein nicht blockierender Befund behoben, jeder mit einem ausgeführten Beleg; zwei unabhängige Prüfungen auf einem anderen Modell mit Urteil bestanden |
| **Stand der Dateien** | `Makefile` sha256 `340699673b73a076e1854aaefa385f3f515632679bc9d80cab0eb59054fa94a4`; `docs/adr/0002-architekturentscheid-ziel-stack.md` sha256 `dde54174442a1dd6f81ca24f5114b2349ffddf332d3e2190cf654d3b0ec155f9` |

## Woran diese Einheit anknüpft

Am 2026-08-30 wurde die Arbeit am Makefile nach Eskalationsregel 3.4
abgebrochen und vorgelegt: Dieselbe Fehlerklasse — ein Kettenschritt endet
mit 0, ohne geprüft zu haben — war dreimal an einem neuen Einzelfall
aufgetreten. Der Auftraggeber hat am 2026-08-31 angewiesen, gefundene Punkte
selbstständig, genau und vollständig anzugehen und erst nach Abschluss
vorzulegen. Diese Einheit setzt dort an.

## Was behoben wurde

### 1. Der Zwischenspeicher von `uv` hebelte `--locked` aus (blockierend)

**Befund.** Die Positivliste um `$(UV)` war am 2026-08-31 um die Netz- und
Zertifikatsvariablen erweitert worden, weil `uv` in einer Umgebung mit Proxy
und eigener Wurzelzertifizierungsstelle sonst scheitert — bei einer
Polizeiorganisation der Regelfall. Mitgenommen wurden dabei stillschweigend
`UV_CACHE_DIR`, `XDG_CACHE_HOME` und `TMPDIR`, die für diesen Fall gar nicht
gebraucht werden. `--locked` prüft die Prüfsumme eines Pakets beim
**Herunterladen**; ein bereits **entpacktes** Archiv im Zwischenspeicher wird
ohne erneute Prüfung ins Umfeld gelegt. Damit genügte **eine einzige gesetzte
Umgebungsvariable**, um manipulierten Paketinhalt zu installieren, während D1
"Lage A — bestanden" meldete. Ausgeführt belegt.

**Behebung.** Die drei Variablen sind wieder entfernt. Der Restweg führt nur
noch über `HOME`, das `uv` zwingend braucht und unter dem der Zwischenspeicher
liegt; für `HOME` trägt die Reichweitenbegründung aus ADR 0002, 6.5 (wer sie
setzen kann, kann den Aufruf ebenso gut unterlassen). Der Restweg ist im
Makefile-Kopf als Fall 3 und in ADR 0002, 6.6.1 ausdrücklich benannt statt
verschwiegen — die Nachprüfung hatte zu Recht beanstandet, dass die alte
Abgrenzung ihn nicht trug.

**Was bewusst nicht getan wurde.** Ein fest verdrahteter Zwischenspeicherpfad
wäre gegen `HOME` dicht, tauscht den Weg aber gegen zwei neue Fehler: Ein nicht
beschreibbarer Ort lässt jeden `uv`-Schritt als "Lage A — durchgefallen" enden,
und ein Zwischenspeicher im Arbeitsbaum käme unter den Arbeitsbaumlauf von D11.
Der wirksame Abschluss ist `uv sync --no-cache` — voller Ladevorgang je Lauf,
Netzabhängigkeit. Das ist eine Betriebsentscheidung, nicht eine der Umsetzung,
und liegt als **neuer offener Punkt O-13** beim Auftraggeber.

### 2. Die Kette konnte still das falsche Repository prüfen (blockierend)

**Befund.** `PROJ` fiel auf das Arbeitsverzeichnis zurück, wenn die Herleitung
aus `$(MAKEFILE_LIST)` scheiterte, und die Wache prüfte nur, ob dort
*irgendein* Marker liegt (`CLAUDE.md` oder `.git`). Steht der Aufrufer in einem
anderen echten Arbeitsbaum — zwei Arbeitskopien nebeneinander sind die
naheliegende Arbeitsform —, schwieg die Wache, und `make dod` prüfte
vollständig und unbemerkt das falsche Repository. Kommt die falsche Kopie
weiter als die gemeinte, ist das ein falsches Grün für einen Stand, den
niemand angesehen hat. Ausgeführt belegt mit zwei Arbeitskopien.

**Behebung.** Kein Rückfall mehr. `PROJ` kommt aus dem **ganzen** Wert von
`$(MAKEFILE_LIST)`: Die Datei bindet nichts ein, die Liste trägt also genau
einen Eintrag, und gespalten hat ihn immer erst `$(firstword)`. Der Shell-Test
bekommt ihn gequotet und damit unverfälscht. Lässt sich der Pfad nicht
bestimmen, bricht der Lauf mit einer Erklärung ab. Damit ist die bisher als
"nicht unterstützt" bezeichnete Aufrufart `make -f '<pfad mit
leerzeichen>/Makefile'` aus fremdem Arbeitsverzeichnis nicht mehr nur erkannt,
sondern richtig aufgelöst.

**Es ist dieselbe Ursache wie überall in dieser Datei:** Die Wache machte die
Lage an einem **Namen** fest ("hier liegt ein `CLAUDE.md`") statt am
**Gegenstand** ("das ist das Verzeichnis dieses Makefiles").

### 3. Eine Aufrufart lief gar nicht (nicht blockierend, vorbestehend)

**Befund** der Nachprüfung zu Behebung 2: Heisst die Datei nicht `Makefile`
(`make -f '<verzeichnis>/Projektregeln.mk' dod`), bestimmte die Kette `PROJ`
zwar richtig, der Unter-Make-Aufruf der Schleife in `dod` brach aber mit
`No rule to make target 'bau'` ab, bevor der erste Kettenschritt lief — ohne
`-f` sucht ein Unter-Make in `$(PROJ)` die Vorgabenamen. Der Fehler bestand
schon vorher und fiel sicher ab (Rückgabewert 2, Meldung "nicht nachweisbar
gelaufen"), war also kein falsches Grün, aber eine Aufrufart, die nicht lief.

**Behebung.** Der Unter-Make-Aufruf trägt zusätzlich `-f "$(MAKEFILE_NAME)"`,
den **Basisnamen** dieser Datei — nicht den Pfad, weil ein relativer `-f`-Pfad
nach dem `-C` ein anderer wäre. Behoben in derselben Einheit, weil erst
Behebung 2 den Dateinamen verlässlich macht und die Fortschreibung des ADR
sonst mehr behauptet hätte, als der Code leistet.

## Prüfungen

| Runde | Modell | Gegenstand | Urteil |
|---|---|---|---|
| 6 | anderes Modell als die Umsetzung | die zwei Änderungen der fünften Fortschreibung | **nicht bestanden** — zwei blockierende Befunde (oben 1 und 2) |
| 7 | anderes Modell als die Umsetzung | die Behebungen zu 1 und 2, Regression | **bestanden** — beide Angriffswege belegt geschlossen, Regression ohne Abweichung; zwei nicht blockierende Befunde gemeldet (oben 3 und eine Textungenauigkeit zum symbolischen Verweis) |
| 8 | anderes Modell als die Umsetzung | die Behebung zu 3, Regression | **bestanden** — dreizehn Läufe, keine Regression in den geprüften Aufrufarten, kein Weg zu einem falschen `A_OK` über den Dateinamen |

Die Rolle, die umsetzt, prüft ihre eigene Arbeit nicht (3.4); jeder Prüfschritt
lief auf einem anderen Modell als die Umsetzung.

## Nachgeführte Dokumentation

- `docs/adr/0002-architekturentscheid-ziel-stack.md`: neuer Abschnitt **6.6**
  (sechste Fortschreibung) mit 6.6.1, 6.6.2 und 6.6.3; neuer offener Punkt
  **O-13** in Abschnitt 8; Kopfzeile um die vierte bis sechste Fortschreibung
  nachgeführt, die dort fehlten.
- `Makefile`: Abschnitt "WOGEGEN DIESE KETTE SCHUETZT — UND WOGEGEN NICHT" um
  Fall 3 ergänzt, samt der Feststellung, weshalb die bisherige Begründung ihn
  nicht trug.

## Was offen bleibt

| Punkt | Wer entscheidet |
|---|---|
| **O-13 (neu)** — Zwischenspeicher von `uv` benutzen oder D1 mit `--no-cache` | Auftraggeber mit SecDevOps und DevOps Engineer |
| O-12 — Lauf der Kette auf der Gegenseite, in einer Umgebung, die der Aufrufer nicht setzt | DevOps Engineer mit SecDevOps |
| O-11 — Abgleich der Wurzelpakete für D18 | DevOps Engineer mit Backend Engineer |
| O-10 (a) und (b) — Ausschlussliste für D11, Ablage der Zugangsdaten | DevOps Engineer mit SecDevOps |
| O-8 — Betriebsart für D10, Form von D12 | DevOps Engineer mit Protocol Master |
| O-7 / E-07, E-08 — Schwellenwerte in D3, D6 und D8 | Auftraggeber mit SecDevOps |

Ohne O-7 laufen D3, D6 und D8 mit den im Makefile hinterlegten Vorgaben, die
als solche gekennzeichnet und nicht erfunden sind.

## Nächster Schritt

Nach der freigegebenen Reihenfolge: **R3-Q-001** — die Gates für die
Definition-of-Done-Befehlskette (`Stop`, `SubagentStop`, `TaskCompleted`).
Sie stützen sich auf `make dod`, das jetzt besteht. Danach E4, E3, dann das
Grundgerüst.
