# Vorlage: Prozess-Schnitt (Koordinator, 2026-10-22)

Stand 2026-10-22. Anhänge: `docs/vorlagen/2026-10-22_prozess-schnitt/anhang-a-adr-aufteilung-software-architect.md`, `docs/vorlagen/2026-10-22_prozess-schnitt/anhang-b-r3coscrum-kopplung-devops-engineer.md`, `docs/vorlagen/2026-10-22_prozess-schnitt/anhang-c-backlog-form-product-owner.md` (Entwürfe der Rollen vom 2026-10-22, nicht geprüft im Sinne von 3.4; Grundlage der Einheiten PS-2 bis PS-4).

## 1. Anlass und Weisungen
Frage des Auftraggebers vom 2026-10-22 zur Geschwindigkeit des Entwicklerteams (ECC, r3coscrum); Einschätzung des Koordinators mit drei Optionen; Weisungen im Wortlaut (zweiter Formweg): "Ich vertraue dir und deinen super Fähigkeiten und gehen nach deiner Empfehlung" und "Nein, FFHS braucht es nicht, nach Übergangsfrist weg". Lesart: Optionen 1 (Prozess verschlanken) und 2 (r3coscrum einfalten) sind dem Grundsatz nach entschieden; die konkreten Änderungen legt der Koordinator als Pull Requests vor, der Merge ist der Entscheid (erster Formweg, ADR 0002, Abschnitt 10). Option 3 (ECC-Muster) erst mit dem Grundgerüst, kein Plugin, keine GitHub-App.

## 2. Was bleibt (nicht verhandelbar nach Projektauftrag 5.4 und bewährt)
Gates und Prüfmittel; DoD-Kette; Verifikation von Code und Gates durch SST und DST auf dem anderen Modellfeld; Register; die zwei Formwege; Abnahme durch Merge; Commit-Prüfsummen als Verweise (6.6); Rollenmodell (ADR 0001); 3.4-Regel; Übergabedatei je Sitzung; Entscheidlog ADR 0002, Abschnitt 10 ausschliesslich anfügbar.

## 3. Zerlegung in vier Einheiten (3.3), je ein Pull Request, Merge = Annahme
**PS-1 Regeln (zuerst, kleinster Schnitt):**
- Projektauftrag (Vorschlag zur Fortschreibung, Entscheid durch Merge): 1.3 (ein Repository), 3.3 (eine Übergabe und ein Pull Request je Sitzung), 6.6 (Verfolgbarkeit: Historie in git, Prüfsummen als Verweise; Nachtrag-Pflicht nur für Entscheidlog, Register und Abnahmen).
- .claude/rules/dokumentation.md: ADR als aktueller Stand mit Entscheidlog; Backlog als Tabellen mit wörtlich erhaltenen Eintragsblöcken; Nachtrag-Regel eingegrenzt.
- CLAUDE.md: Statuszeile "5 Umsetzung" auf höchstens 10 Zeilen (Stand, nächste Einheit, Verweise); Gate-Tabelle je Gate höchstens 8 Zeilen (Einzelheiten in den ADR); Textprüfung: ein SST je Einheit auf dem ganzen Diff, Gegenprüfung nur für Gates, Prüfmittel und Code; Beteiligung je Einheit (PM nur bei Entscheiden und Abnahmen, PO nur bei Backlog-Änderung, SA nur bei Festlegungen).
- Vorlage docs/vorlagen/2026-10-22_prozess-schnitt.md mit den drei Entwürfen als Anhänge (Software Architect, DevOps Engineer, Product Owner).
- Aufwand etwa 25 Aufrufe; Rollen: Koordinator, Static Software Tester (eine Runde), Protocol Master (Eintrag Abschnitt 10 nach dem Merge).
**PS-2 ADR-Aufteilung (nach dem Merge von PS-1, weil die Nachtrag-Regel vorher geändert sein muss):**
- Plan des Software Architects: 6.12 (Zeilen 1948 bis 7997, 6'050 Zeilen) nach ADR 0003, 6.13 (7998 bis 10053, 2'056) nach ADR 0004, 6.14 (10054 bis 11057, 1'004) nach ADR 0005; je Teil A "Stand" (Tabellen) und Teil B "Entscheidlog" (verschobener Text, Überschriften und Kennungen unverändert); ADR 0002 behält 1 bis 5, 6.1 bis 6.11, 7, 8, 10, dazu 31 Weiterleitungen; Zeile 7 wird Tabelle "Fortschreibungen" mit Verweis auf den Commit vor dem Schnitt; Abschnitt 9 wird abgeschlossen.
- Drei Commits: Regeln sind schon durch PS-1 da; (1) nur verschoben (sed, sha256-Abgleich durch den DevOps Engineer), (2) Teil A (Software Architect), (3) Prüfmittel: scripts/dod-gate-selbsttest.sh liest ADR 0002 mechanisch an sieben Stellen und gehört nicht zu make dod -> Pfade umstellen, beide Modi fahren (SecDevOps Engineer); D20-Trockenlauf vor dem Commit.
- Aufwand 31 bis 44 Aufrufe in drei bis vier Etappen; Verifikation SST (Teil A, Weiterleitungen, Prüfsummen) und DST (Selbsttest).
**PS-3 Backlog-Umbau:**
- Plan des Product Owners: Rahmen neu (Übersichtstabelle, Tabelle Posten 1 bis 10, Nachführungstabelle, Punktetabelle mit Status); die 91 Eintragsblöcke "### R3-…" bleiben wörtlich, weil D20 die Kennungen aus den Überschriften bildet; heutiger Backlog byte-gleich als docs/archiv/05_Product_Backlog_bis_<datum>.md (nicht unter dem D7-Glob docs/05_Product_Backlog*.md) mit Verweis per Prüfsumme.
- Stufe 1 etwa 46 bis 62 Aufrufe (Spleissen mit Bash durch den Koordinator), Stufe 2 (91-Zeilen-Übersicht) als Folge nach PS-2.
**PS-4 r3coscrum einfalten:**
- Inventar des DevOps Engineers: Kopplung über nachweise-uebertragen.yml (r3cosint -> r3coscrum, Secret NACHWEISE_TOKEN) und eingang.yml (r3coscrum -> r3cosint, Secret R3COSINT_TOKEN); der Starthook liest docs/EINGANG_METHODIK.md in r3cosint; meilenstein-tag.yml bleibt. 31 Methodik-Prüfsummen sind in 16 Dateien zitiert (95 Vorkommen); Kopien machen sie nicht auflösbar, nur der erhaltene Verlauf.
- Vorschlag: der unveränderte Verlauf von r3coscrum (87 Commits, 213 KiB) als Zweig archiv/r3coscrum in r3cosint, nie in den Hauptzweig gemergt (D20 löst die Prüfsummen dann auf: gemessen 0 Befunde mit Archivzweig und ohne Kopien, Variante vf; ohne Archivzweig mit Kopien 129 Befunde, davon 117 Prüfsummen, Variante b); vier Methodiktexte und UEBERGABE.md byte-gleich nach docs/methodik/ mit QUELLEN.md (Quell-Commit, SHA-256); nachweise-uebertragen.yml entfernen (Abzug später als Release-Anhang); eingang.yml nach Widerruf des Tokens entfernen; Starthook session-start-eingang.sh entfernen, Eingangsdatei eingefroren am Ort; D20-Mitlesen von Repo B braucht keine Codeänderung, der feste Pfad in scripts/belege-pruefen.sh ist Stufe 2.
- Blast radius: 21 Pfadbefunde in 14 Dateien beim Entfernen von Workflow und Hook (Ausnahmen oder Nachträge), 11 bis 14 Befunde durch die Kopien; scripts/nachweise-erzeugen.sh listet beide Dateien und würde D12 rot -> Zeilen anpassen.
- Danach durch den Auftraggeber: Tokens widerrufen, r3coscrum archivieren (nur lesbar), nach der Übergangsfrist löschen (Vorschlag: Merge der Freigabe des Grundgerüsts).

## 4. Entscheide, die nur der Auftraggeber treffen kann (im Pull Request PS-1 benannt, Antwort als Weisung oder im Merge-Text)
- E-PS-1: Fortschreibung des Projektauftrags 1.3, 3.3, 6.6 im vorgeschlagenen Wortlaut (Merge von PS-1 = Annahme).
- E-PS-2: Archivzweig archiv/r3coscrum in r3cosint — der Koordinator darf ohne ausdrückliche Erlaubnis keinen anderen Zweig pushen; Erlaubnis nötig ("Zweig archiv/r3coscrum pushen: ja").
- E-PS-3: Widerruf der Tokens NACHWEISE_TOKEN und R3COSINT_TOKEN und Archivierung von r3coscrum (Eigentümerrechte).
- E-PS-4: Sichtbarkeit — r3coscrum ist öffentlich; sollen die eingefalteten Methodiktexte in r3cosint (Sichtbarkeit prüfen) liegen?
- E-PS-5: Übergangsfrist bis zur Löschung (Vorschlag: Merge der Freigabe des Grundgerüsts).

## 5. Risiken
- Regelkonflikt: ADR 0002, 6.1, Absatz "Anlass" ("die früheren Fassungen bleiben im Text stehen") — darum PS-1 vor PS-2.
- scripts/dod-gate-selbsttest.sh (nicht Teil von make dod) bricht beim Schnitt still; Lauf beider Modi ist Pflicht in PS-2.
- D20-Fundorte: 561 Verweiszeilen in 38 Dateien auf ADR 0002 bleiben über Weiterleitungen gültig; 14 Zeilen-Fundorte und 114 Pfadverweise auf das Backlog in 29 Dateien (PS-3); 21 plus 11 bis 14 Befunde in PS-4.
- Verfolgbarkeit nach 6.6: Historie in git plus Archivzweig; ohne Archivzweig gehen 31 zitierte Prüfsummen verloren.
- Aufwand gesamt: etwa 150 bis 200 Aufrufe über vier Einheiten (Schätzung des Koordinators aus den Anhängen A und C; Anhang B nennt keinen Aufwand), je Einheit eine Sitzung oder weniger.

## 6. Nächste Schritte
1. Merge von #28 (Auftraggeber). 2. Zweig auf main setzen. 3. PS-1 bauen, eine statische Textrunde, make dod, Pull Request "Merge = Annahme der Regeln (Prozess-Schnitt PS-1)". 4. Nach dem Merge PS-2, PS-3, PS-4 je als Einheit; C4 (Posten 3, 8, 9, 10) danach im neuen Prozess.

## 7. Weisung vom 2026-10-22 zur Vorlage
Wortlaut: "Mach einfach, ich erlaube es dir. Vertraue dir." Lesart des Koordinators: Erlaubnis für E-PS-1 bis E-PS-5, soweit der Koordinator sie ausführen kann (Vorschlag zur Fortschreibung des Projektauftrags; Push neuer Zweige nach r3cosint, auch archiv/r3coscrum; Übergangsfrist bis zum Merge der Freigabe des Grundgerüsts; Methodiktexte unter docs/methodik/). Beim Auftraggeber verbleiben Widerruf der Tokens, Archivieren und Löschen von r3coscrum und die Sichtbarkeit. Der Merge jedes Pull Requests bleibt der Entscheid (erster Formweg). PS-1 beginnt sofort auf einem eigenen Zweig, damit Pull Request #28 im Umfang unverändert bleibt; der Pull Request von PS-1 setzt den Merge von #28 voraus.
