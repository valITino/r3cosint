# Übergabe 2026-09-22 (3) — Abnahme der beiden Starthooks durch Merge eingetragen; vier Befunde des dritten Codex-Laufs behoben; Nachweisfluss am Regelwerk gescheitert

Dritte Arbeitseinheit des Tages, als Aufgabe #5 geführt (O-23, Entscheid
E-H). Anlass waren drei Ereignisse innerhalb weniger Minuten: der dritte
Lauf des Codex-Reviews am Pull Request #17 (11:17 UTC, geprüfter Commit
`59de8974bc6871e4e5e1ce179cc1b29d98739961`), der Merge beider Pull Requests
durch den Auftraggeber (11:18 und 11:20 UTC) und der daraufhin gescheiterte
Lauf des Nachweisflusses `nachweise-uebertragen.yml`. Arbeitszweig
`claude/awesome-knuth-blvzpb`, nach dem Merge neu aufgesetzt auf
`ace906c83bcd93afd1cdd7b7610ed38cd023c89f` (Produkt-Repository) und
`494409cf431e447ef26ce18f99832e467ec8a08d` (Methodik-Repository).

## Ergebnis in einem Absatz

Die Abnahme der beiden Starthooks ist am 2026-09-22 durch den Merge des
Pull Requests #17 erteilt (Merge-Commit
`a462aacfcedaa5ae62e92b14335f9db6718499be`, 13:18:43 MESZ, ohne Kommentar
und ohne Review des Auftraggebers; Formweg 1 aus ADR 0002, Abschnitt 10) und in ADR 0002,
`CLAUDE.md` und Backlog eingetragen. Die vier Befunde des dritten
Codex-Laufs — Git-Hooks des Klons laufen während des Fetches, Submodule
werden mitgeholt, `SSLKEYLOGFILE` lässt `curl` TLS-Schlüssel in den
Arbeitsbaum schreiben, ein Installationsziel ausserhalb des PATH macht den
Fehlschlag mit dem Ersetzungsschutz dauerhaft — sind von der Abnahme nicht
als behoben umfasst, in dieser Einheit vom SecDevOps Engineer behoben und
auf einem anderen Modell statisch und dynamisch geprüft (unten). Ein
fünfter Befund (Nachweisverzeichnis nach Squash) ist vor dem Merge nicht
behebbar und so beantwortet. Der Nachweisfluss ist nach dem Merge am neuen
Regelwerk von `main` im Methodik-Repository gescheitert; das ist ein
Entscheid des Auftraggebers, hier vorgelegt. Ob die vier Behebungen als
eigener Pull Request eröffnet werden, entscheidet der Auftraggeber; der
Zweig ist gepusht.

## Entscheidungen dieser Einheit

1. **Behebungen fertigstellen, aber keinen Pull Request ohne Weisung.** Die
   Befunde betreffen Code, den die abgenommenen Hooks tragen, und die
   Behebungen waren bei Eintreffen der Merge-Meldung bereits gebaut. Eine
   begonnene Einheit wird zu Ende geführt (3.1); ein neuer Pull Request ist
   dagegen ein Schritt nach aussen, und der Auftraggeber hat mit der
   Weisung vom 2026-09-22 E4.1 als nächste Einheit bestimmt. Der Zweig
   trägt den geprüften Stand; die Eröffnung liegt beim Auftraggeber.
2. **Abnahme durch Merge ohne Beschönigung eingetragen.** Der Merge kam
   eine Minute nach dem dritten Codex-Lauf. Die Abnahme umfasst den
   gemergten Stand mit seinen benannten Restbefunden; die vier neuen
   Befunde sind darin nicht als behoben enthalten. Beides steht so im
   Abnahmeeintrag.
3. **Nachweisfluss: keine Änderung am Arbeitsablauf ohne Weisung.** Zwei
   Wege sind möglich (unten); beide ändern etwas, das dem Auftraggeber
   gehört (Regelwerk oder Nachweisfluss).

## Was gebaut ist

`.claude/hooks/session-start-git-historie.sh` (381 Zeilen): beide
Fetch-Aufrufe lauten jetzt
`git -C "$projekt" -c core.hooksPath=/dev/null fetch --unshallow --no-recurse-submodules --refmap='' origin "$refspec"`.
`-c core.hooksPath=/dev/null` verhindert, dass ein `reference-transaction`-
oder anderer Git-Hook des Klons während des Nachholens läuft (githooks(5):
Ref-Transaktionen lösen ihn aus; die übrigen git-Aufrufe des Hooks führen
keine aus); `--no-recurse-submodules` hält die Ein-Gegenstellen-Zusicherung
auch bei bestückten Submodulen mit `fetch.recurseSubmodules=true`.
`.claude/hooks/session-start-gitleaks.sh` (510 Zeilen): `SSLKEYLOGFILE`
wird zu Beginn gelöscht; die Kandidaten `/usr/local/bin` und
`$HOME/.local/bin` werden so geordnet, dass die im PATH stehenden zuerst
geprüft und beschrieben werden (exakter Verzeichnisvergleich über
`case ":$PATH:"`), für Prüfung und Installation dieselbe Liste.

## Verifikation auf einem anderen Modell

**Dynamisch (r10) — bestanden, 116 von 116 Zusicherungen**, je mit
Kontrolle, die am selben Gegenstand das alte Verhalten zeigt: K-H
(`reference-transaction`-Hook unter `core.hooksPath`, der in den Arbeitsbaum
schreibt: Datei entsteht nicht; ohne die Option entsteht sie), K-S
(bestücktes Submodul mit `fetch.recurseSubmodules=true`, Quelle inzwischen
weiter: Remote-Tracking-Ref des Submoduls unverändert; ohne die Option
bewegt er sich), L-K (`SSLKEYLOGFILE` in einen Wegwerfklon: Datei entsteht
nicht; `curl` ohne Hook legt sie an), L-P (`/usr/local/bin` nicht im PATH,
`$HOME/.local/bin` im PATH: Installation nach `$HOME/.local/bin`, Meldung
nennt den Kandidaten, `command -v` findet das Binary; Kontrolle mit
`/usr/local/bin` im PATH: Installation dorthin), Regression aller r9-Fälle
(K-A bis K-B5, K-F, K-F2, L-A) auf dem Endstand; `/usr/local/bin/gitleaks`
byte-identisch mit Zeitstempel zurückgespielt, nichts Globales geändert,
kein Rest. Zwei Messfehler im Prüfskript (verdrahtete Commit-Zahl, Kontrolle
K-SK zu spät geklont) offengelegt und vor dem Ergebnislauf behoben.

**Statisch (s5) — nicht bestanden, ohne Verhaltensmangel.** Alle vier
Behebungen am Gegenstand nachgemessen und bestätigt, darunter: die Option
`-c core.hooksPath=/dev/null` hält auch gegen ein über `GIT_CONFIG_*`
eingeschleustes `core.hooksPath`; die fünf lesenden git-Aufrufe des Hooks
lösen keine Ref-Transaktion aus; die Kandidatenordnung ist teilstringfrei,
glob-fest und bei leerem oder ungesetztem PATH fehlerfrei. Ein blockierender
Textbefund: S5-01 — der Kommentar zitierte `githooks(5)` mit "performs
reference transactions", die Quelle sagt "performs reference updates"; der
falsche Wortlaut stammte aus dem Codex-Kommentar und war vom Koordinator
ungeprüft an den SecDevOps Engineer weitergegeben worden. Das Kriterium
"wörtliches Zitat am Original belegbar" ist damit zum zweiten Mal
gescheitert (erstes Mal S3-01); ein drittes Scheitern löst 3.4 aus.
Nachrangig: S5-02 (`/dev/null` als Verzeichnis bezeichnet), S5-03
(Rundenzählung des gitleaks-Hooks um eins zu tief), S5-04 (Absatz zu
`GIT_CONFIG_*` von der siebten Runde überholt), S5-07 (Optionszeichen aus
`git fetch -h` verkürzt zitiert) — alle vom Koordinator in den Kommentaren
berichtigt, Rümpfe unverändert; S5-05 als benannte Restlage (die
PATH-Ordnung verhindert, dass die Lage neu entsteht, heilt einen aus einer
früheren Sitzung vorhandenen Eintrag ausserhalb des PATH aber nicht); S5-06
als Grenze (leeres Array unter `set -u` verlangt bash ab 4.4, gemessen nur
mit 5.2). Zählung nach 3.4 zur Klasse "vererbte Umgebung oder Konfiguration
lenkt einen Schreibzugriff in den Arbeitsbaum": zweites Scheitern (erster
Codex-Lauf `GIT_TRACE`, dritter Lauf `core.hooksPath` und `SSLKEYLOGFILE`);
die Klasse ist offen und lässt sich nicht leerprüfen — weitere Vektoren,
benannt und nicht behoben: `BASH_ENV` (gemessen: fremder Code läuft vor der
ersten Skriptzeile, kein `unset` im Skript hilft), `LD_PRELOAD`,
`credential.helper`/`GIT_ASKPASS`, `url.*.insteadOf`, `remote.origin.url`
mit `ext::`-Adresse, `GIT_CONFIG_GLOBAL`/`GIT_CONFIG_SYSTEM`,
`core.fsmonitor`; kein Vektor sind `GIT_EXEC_PATH` und
`GIT_REDIRECT_STDOUT`/`STDERR` (gemessen).

**Statisch (s6) — Nachprüfung der Kommentarberichtigungen:** bestanden. Beide Zitate am Original wörtlich belegt, Rümpfe beider Hooks
byte-gleich mit dem r10-Stand, S5-01 bis S5-07 behoben oder als Grenze
geführt; die Abnahmefakten (Merge-Commit, Zeitstempel, abgenommener Stand,
Methodik-Merge, Wortlaut des PR-Texts, fünf Befunde um 11:17:44 UTC) gegen
die Primärquellen geprüft und bestätigt. Drei nachrangige Textbefunde, vom
Koordinator berichtigt: S6-01 (Rundenabsätze nicht in aufsteigender Folge,
Selbstbezug ohne die achte Runde), S6-02 (der Abnahmeeintrag sagte "zehn
Threads vor dem Merge beantwortet", zutreffend sind sechs vor dem Merge,
einer danach, vier unbeantwortet), S6-03 ("ohne Kommentar und ohne Review"
ohne den Zusatz "des Auftraggebers" in Backlog und dieser Übergabe).

## Nachweisfluss gescheitert — vorgelegt

Der Arbeitsablauf `nachweise-uebertragen.yml` lief nach dem Merge auf
`main` (Stand `a462aacfcedaa5ae62e92b14335f9db6718499be`), erzeugte den
Commit für `nachweise/` im Methodik-Repository und wurde beim Push auf
dessen `main` abgewiesen: "GH013: Repository rule violations found for
refs/heads/main — Changes must be made through a pull request." Frühere
Läufe (zuletzt Stand `c06ed44337b297a70fcf33ae2410b0fd69503445`) sind
durchgekommen; das Regelwerk auf `main` des Methodik-Repositories ist also
neu oder verschärft. Der Arbeitsablauf schreibt mit `NACHWEISE_TOKEN`
direkt nach `main`, wie `.claude/rules/versionierung-und-nachweisfluss.md`
und die Regel "`nachweise/` beschreibt ausschliesslich die Automatik" es
vorsehen. Zwei Wege, beide Entscheid des Auftraggebers:

- **Regelwerk:** Im Methodik-Repository unter Settings, Rules, Rulesets
  dem Regelwerk für `main` eine Umgehung ("Bypass list") für den Akteur
  des Tokens geben (das Token handelt als Kontoinhaber, also die Rolle
  Repository admin) — und den fehlgeschlagenen Lauf über den Actions-Tab
  erneut starten (oder `workflow_dispatch` mit dem Stand). Nichts am
  Nachweisfluss ändert sich.
- **Nachweisfluss:** Den Arbeitsablauf so ändern, dass er einen Zweig
  pusht und einen Pull Request eröffnet, den der Auftraggeber mergt. Das
  ändert `.claude/rules/versionierung-und-nachweisfluss.md` in beiden
  Repositories und ist Methodik, keine Bauentscheidung des Koordinators.

Bis dahin fehlt im Methodik-Repository der Nachweisstand `a462aacf…`;
`docs/NACHWEISE.md` im Produkt-Repository ist davon nicht betroffen.

## Codex-Review — Frage des Auftraggebers

Der Auftraggeber hat gefragt, ob der Codex-Review entfernt werden kann.
Der Review ist eine GitHub-App (`chatgpt-codex-connector`), die auf dem
Konto des Auftraggebers installiert ist; sie ist keine Datei dieses
Repositories und kann vom Koordinator nicht entfernt werden. Zwei Stellen:
GitHub, Settings, Applications, Installed GitHub Apps, Codex, Configure —
dort den Zugriff auf die Repositories entziehen oder die App deinstallieren;
oder in den Codex-Einstellungen (Cloud, Settings, General) den Code-Review
für die Repositories ausschalten. Bewertung ohne Beschönigung: Von den elf
Befunden an diesem Pull Request waren neun berechtigte Mängel an den beiden
Hooks, darunter der halb behobene P1; der Review hat also Fehler gefunden,
die die eigenen Prüfrollen nicht gefunden hatten. Der Preis ist Lärm bei
jedem Push. Der Entscheid liegt beim Auftraggeber.

## Was offen bleibt

- Pull Request für die vier Behebungen: auf Weisung.
- Nachweisfluss: einer der beiden Wege oben, auf Weisung; danach den Lauf
  wiederholen.
- Restbefunde aus den früheren Übergaben vom 2026-09-22 unverändert;
  weitere Vektoren derselben Klasse (siehe Verifikation).
- Nächste Einheit nach Weisung: E4.1, in einer neuen Sitzung von `main`.

## Protokoll der ausgeführten Befehle (Koordinator)

- Lesen der fünf Codex-Threads am Pull Request #17 (Commit `59de8974…`);
  Anlegen der Aufgabe #5; Antwort und Auflösung zum Nachweisverzeichnis.
- Delegation: SecDevOps Engineer (beide Hooks), Protocol Master (ADR 0002:
  Abschnitt 10 Abnahmeeintrag, E-E und E-F dritter Nachtrag, Abschnitt 9),
  Static und Dynamic Software Tester (s5, r10) auf einem anderen Modell;
  ein Sitzungslimit hat alle drei Prüf- und Protokollrollen um 11:24 UTC
  abgebrochen (Rücksetzung 14:20 UTC), fortgesetzt um 16:46 UTC.
- Nach der Merge-Meldung: `git fetch origin main`, Arbeitszweig mit
  `git checkout -B` auf `origin/main` neu aufgesetzt (Behebungen im
  Arbeitsbaum erhalten), Abonnements beider Pull Requests beendet,
  Selbstkontrolle gelöscht.
- Eigene Nachführung: `CLAUDE.md` (Statustabelle, Hook-Absatz), Hook-Regel,
  Backlog (Stand-Vermerk R3-Q-001, neunte Nachführung), Nachweiserzeuger
  (Artefaktzeile dieser Übergabe, Beschreibungen der Hooks), diese Übergabe;
  im Methodik-Repository der Nachtrag zu S8 und der Übergabevermerk.
- `git add`, `make dod`, Commit mit Kennung R3-Q-001, Push des Zweigs; danach
  `docs/NACHWEISE.md` neu erzeugt, `make dod`, zweiter Commit, Push.
