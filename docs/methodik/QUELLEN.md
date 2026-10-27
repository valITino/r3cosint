# Quellen der eingefalteten Methodiktexte

| | |
|---|---|
| **Zweck** | Herkunft der Dateien unter `docs/methodik/` und der nicht kopierten Dateien des früheren Methodik-Repositories (Repo B) festhalten |
| **Grundlage** | Projektauftrag 6.6, Fortschreibung vom 2026-10-22; Vorlage `docs/vorlagen/2026-10-22_prozess-schnitt.md`, Einheit PS-4 |
| **Stand** | 2026-10-26 (Einfalten) |
| **Fortschreibung** | nur die Zeile "Nachführung des Archivzweigs" (D5, 2026-10-26); sonst hält die Datei den Stand beim Einfalten fest |

## Zweck

Das frühere Methodik-Repository (Repo B, `github.com/valITino/r3coscrum`) ist mit dem Prozess-Schnitt PS-4 in dieses Repository eingefaltet worden, auf die Weisungen des Auftraggebers vom 2026-10-22 (Wortlaut: Vorlage `docs/vorlagen/2026-10-22_prozess-schnitt.md` und ihre Anhänge). Fünf Dateien liegen als byte-gleiche Kopien unter `docs/methodik/`. Die übrigen Dateien, auf die es für die Herkunft ankommt, sind nicht kopiert; sie stehen hier als Referenz mit Quell-Commit und SHA-256, ihr Inhalt ist im Archivzweig lesbar. So bleibt jede Herkunftsangabe nachprüfbar, auch wenn das frühere Repository nicht mehr besteht (Projektauftrag 6.6: feste Verweise mit der 40-stelligen Commit-Prüfsumme).

## Einfrierpunkt und Archivzweig

| | |
|---|---|
| **Archivzweig** | archiv/r3coscrum in diesem Repository (am 2026-10-26 lokal und auf origin): der unveränderte Verlauf des früheren Repositories |
| **Einfrierpunkt** | `6bb7834c546baadf402ebd428ab94f079471ca42`, Spitze des Archivzweigs beim Einfalten |
| **Zeit des Einfrierpunkts** | 2026-10-26T12:15:17Z (Commit-Zeit, UTC) |
| **Betreff dort** | "nachweise: Stand fd9f40176999599be59401bbb33409ae6b9c2e08 aus r3cosint" |
| **Umfang** | 93 Commits beim Einfalten; getrennter Verlauf ohne gemeinsamen Vorfahren mit dem Hauptzweig dieses Repositories, Wurzel `c83b9070aa0afeb653b717ed4fd53c3fee323705` |
| **Nachführung des Archivzweigs** | 2026-10-26 (D5; Anhang B, Schritt N2): Spitze `78bcef984583e665edb28f0f2e7ef8f1da0a87dc`, der Merge-Commit des Pull Requests #19 im früheren Repository (Hinweis in der README, Arbeitsablauf eingang.yml entfernt), 95 Commits; die Kopien unter `docs/methodik/` und der Einfrierpunkt bleiben unverändert |

Der Archivzweig wird nie in den Hauptzweig gemergt. Die Versionsableitung in `.github/workflows/meilenstein-tag.yml` liest alle Commit-Betreffe seit dem letzten Versionsschild und würde sonst die Betreffe des früheren Repositories auswerten. Es ist ein Zweig und kein Versionsschild, weil der Sitzungshook `session-start-git-historie.sh` nur Zweige holt.

## Verweise auf Commits von r3coscrum

Dokumente dieses Repositories zitieren Commits des früheren Repositories. Dieselbe Prüfsumme löst künftig unter der zweiten Form auf, solange der Archivzweig in r3cosint besteht:

```
bisher:   https://github.com/valITino/r3coscrum/commit/<40-stellige Commit-Prüfsumme>
künftig:  https://github.com/valITino/r3cosint/commit/<40-stellige Commit-Prüfsumme>
```

Die Zitate in den Dokumenten bleiben unverändert; sie belegen den Stand, auf den sie zeigen. Ist das frühere Repository gelöscht, lösen die Verweise der ersten Form nicht mehr auf; die Prüfsummen selbst bleiben über den Archivzweig auflösbar. Geprüft am 2026-10-26: 31 von 31 Commit-Prüfsummen aus der Liste "Anhang A: Commit-Prüfsummen, die nur in r3coscrum auflösen" in `docs/vorlagen/2026-10-22_prozess-schnitt/anhang-b-r3coscrum-kopplung-devops-engineer.md` lösen in diesem Repository auf (`git cat-file -e <Prüfsumme>^{commit}`, ohne den Nachbarordner des früheren Repositories).

## Quellenliste

Quell-Commit: letzter Commit bis zum Einfrierpunkt, der die Datei geändert hat (`git log -1 --format=%H 6bb7834c546baadf402ebd428ab94f079471ca42 -- <Quellpfad>`; der Einfrierpunkt, nicht die bewegte Spitze des Archivzweigs). SHA-256: über den Quell-Blob am Einfrierpunkt (`git show 6bb7834c546baadf402ebd428ab94f079471ca42:<Quellpfad> | sha256sum`). Zeilen: Zeilenenden des Quell-Blobs (`wc -l`). Die Quellpfade sind Pfade in r3coscrum; sie stehen ohne Rückwärtsakzente, weil sie in diesem Repository nicht liegen und der Belegprüfer (D20) Pfade in Rückwärtsakzenten gegen dieses Repository prüft.

| Datei in r3cosint | Quellpfad in r3coscrum | Quell-Commit (40) | SHA-256 des Quell-Blobs | Zeilen | Art |
|---|---|---|---|---|---|
| `docs/methodik/arbeitsprodukte.md` | methodik/arbeitsprodukte.md | `e43b9a7fe808463b121f4352b9f1ba10267bdf5c` | `5482ee880cad4e3ebe1e3459f2c15728d97e16f71df7cbbc727269250255c357` | 111 | K1, Methodiktext |
| `docs/methodik/entscheide.md` | methodik/entscheide.md | `30864e9c59b09495405b368419fbde719cf8f05d` | `d8f99653b7a83f296b807d700ddb9c691a4ce54e039ffdd3fa7301a4c491e9c1` | 176 | K1, Methodiktext |
| `docs/methodik/re-prozess.md` | methodik/re-prozess.md | `e43b9a7fe808463b121f4352b9f1ba10267bdf5c` | `87c69d1429b22521ce6a8f5c4a356bdf4a1cc38ba8fa6dd78d3e6ee92a156739` | 117 | K1, Methodiktext |
| `docs/methodik/scrum-aufbau.md` | methodik/scrum-aufbau.md | `e43b9a7fe808463b121f4352b9f1ba10267bdf5c` | `3934433181c3a0d8fbe22b165543f7531eba6d634eeec6ef1f84fcd188690409` | 140 | K1, Methodiktext |
| `docs/methodik/UEBERGABE.md` | UEBERGABE.md | `078ee0076056592c374dd0724c232173177969d6` | `8a6fe5eb8642adc9c3d75106dd1057fdcd8eb3d5ec004de4b83f2f788b467e88` | 1561 | K1, eingefrorenes Archiv |
| (keine) | CLAUDE.md | `7f59a16cb3ccd10b31aae1549ba7667dcc2fdefd` | `3fb303dbd0702b0db18ea13d5cfc7bb503a592da867f3834c3b37abdc0050bf9` | 18 | K2, nur Referenz |
| (keine) | README.md | `7f59a16cb3ccd10b31aae1549ba7667dcc2fdefd` | `4047988ff632e3b8a23315acceafcb419e9874a65c8b4e0a1f3bcb8e19f7f270` | 39 | K2, nur Referenz |
| (keine) | CONTRIBUTING.md | `08d358f6af3b049a9d13caada88c9c57bb379e52` | `5dd2b4e0901b9fb3d8cbcbf11b0a90108df406d53ee397aeafc4750772f12671` | 40 | K2, nur Referenz |
| (keine) | .claude/rules/versionierung-und-nachweisfluss.md | `e43b9a7fe808463b121f4352b9f1ba10267bdf5c` | `8202cd77b1ddd2600e536bda4d3b9dff4cd6fe533a28f1ac9476647e4332295d` | 59 | K2, nur Referenz |
| (keine) | nachweise/NACHWEISE.md | `6bb7834c546baadf402ebd428ab94f079471ca42` | `c18078e2bb080024d506a4bcd062d458a724a0daffc1c803c61bf209d36b6246` | 128 | K3, abgeleitet, keine Kopie |
| (keine) | nachweise/HINWEIS.md | `6bb7834c546baadf402ebd428ab94f079471ca42` | `a40ff2b79d2b6b68dbf95f9640ed9374856ed61b3a352e3d7a6ada67bdfcf621` | 5 | K3, abgeleitet, keine Kopie |
| (keine) | .github/workflows/eingang.yml | `26b64a86aa9350b0ad67ac95f4bd77f58bedea6a` | `894709feb352c27b7084fe8031d4fb707e6bc772c809a1b36431500460a5c730` | 344 | K4, Konfiguration, keine Kopie |

## Art

| Kennung | Bedeutung |
|---|---|
| K1, Methodiktext | Fachlicher Inhalt, byte-gleich nach `docs/methodik/` kopiert, gleicher Dateiname (relative Verweise in den Texten bleiben gültig), ohne Kopfzeile: die Herkunft steht in dieser Datei. Die Kopie ist der Stand beim Einfalten |
| K1, eingefrorenes Archiv | Wie oben; die Datei trägt die Übergabevermerke des früheren Repositories und wird nicht fortgeschrieben |
| K2, nur Referenz | Regeln und Beschreibung des früheren Repositories; nicht kopiert, lesbar im Archivzweig |
| K3, abgeleitet, keine Kopie | Nachweisverzeichnis des früheren Repositories; aus dem Verlauf dieses Repositories abgeleitet und daraus reproduzierbar, nicht kopiert |
| K4, Konfiguration, keine Kopie | Arbeitsablauf des früheren Repositories (Eingang Methodik), aktiv bis zum Merge des Pull Requests in r3coscrum und zum Widerruf von R3COSINT_TOKEN (Anhang B, N1, N2); sein Ergebnis wird nicht mehr übernommen; nicht kopiert, lesbar im Archivzweig |

## Prüfung der Kopien

Am 2026-10-26 hat der DevOps Engineer in der Einheit PS-4 für jede der fünf Kopien geprüft: SHA-256 der Kopie gleich SHA-256 des Quell-Blobs; Blob-Kennung der Kopie (`git hash-object --no-filters`) gleich Blob-Kennung auf dem Archivzweig (`git rev-parse archiv/r3coscrum:<Quellpfad>`); Zeilenzahl und Quell-Commit gleich der Tabelle. Es gab keine Abweichung. Das ist die Prüfung des Umsetzers und nicht unabhängig geprüft. Wiederholbar, solange der Archivzweig besteht und die Kopien unverändert sind:

```
for d in arbeitsprodukte entscheide re-prozess scrum-aufbau; do
  git show archiv/r3coscrum:methodik/$d.md | sha256sum
  sha256sum docs/methodik/$d.md
done
git show archiv/r3coscrum:UEBERGABE.md | sha256sum
sha256sum docs/methodik/UEBERGABE.md
```

## Grenzen

- Die SHA-256-Werte der Tabelle gehören zu den Quell-Blobs. Wird eine Kopie nach dem Einfalten geändert, weicht ihre Prüfsumme von der Tabelle ab; frühere Fassungen liegen im Archivzweig.
- Die Datei belegt die Herkunft, nicht die Richtigkeit des Inhalts.
