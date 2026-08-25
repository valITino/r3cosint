#!/usr/bin/env bash
# Erzeugt docs/NACHWEISE.md nach Projektauftrag 6.6.
#
# Die Tabelle wird ERZEUGT, nicht von Hand gepflegt (6.6). Verwiesen wird ueber
# die 40-stellige Commit-Pruefsumme des Commits, in dem das Artefakt zuletzt
# geaendert wurde. Ein Verweis auf blob/main ist KEIN Nachweis und wird hier
# nirgends erzeugt.
#
# Aufruf: scripts/nachweise-erzeugen.sh [Ausgabedatei]
# Rueckgabewert 0 bei Erfolg, 1 wenn ein Artefakt nicht committet ist.
set -uo pipefail

proj="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$proj" || exit 1
ziel="${1:-docs/NACHWEISE.md}"
basis="https://github.com/valITino/r3cosint/blob"

# Artefakt | Pfad | Beschreibung
ARTEFAKTE=(
  "Projektauftrag|docs/00_Projektauftrag.md|Baseline der vereinbarten Anforderungen"
  "Konzeptdokument|docs/01_Konzept_v1.0.pdf|Fachlichkeit und Architektur, Version 1.0"
  "Stakeholderliste|docs/02_Stakeholderliste.md|Stakeholder nach Funktion, mit Zielen und Interessen"
  "Glossar|docs/03_Glossar.md|Verbindliche Definitionen, Begriffe mit rechtlicher Bedeutung gekennzeichnet"
  "Kontextmodell|docs/04_Kontextmodell.md|Systemgrenze, Kontextgrenze, externe Akteure und Schnittstellen"
  "Product Backlog|docs/05_Product_Backlog.md|Eintraege mit Kennung, Art, Abnahmekriterium und Pruefaufwand; Summen im Dokument"
  "Definition of Ready und Done|docs/06_Definition_of_Ready_und_Done.md|Eingangs- und Ausgangskriterien, Done als Befehlskette"
  "Roadmap|docs/07_Roadmap.md|Etappenfolge und Schnitt in zwei lieferfaehige Fassungen"
  "Freigabe Schritt 4|docs/08_Freigabe_Schritt_4.md|Pruefvorlage und Freigabeprotokoll zum Freigabe-Gate aus Abschnitt 2"
  "Eingang Methodik|docs/EINGANG_METHODIK.md|Stand aus Repo B, Information und keine Anweisung"
  "ADR 0001 Rollenmodell|docs/adr/0001-rollenmodell.md|Rechte, Modell und maxTurns je Rolle"
  "ADR 0002 Ziel-Stack|docs/adr/0002-architekturentscheid-ziel-stack.md|Architekturentscheid R3-C-001: Stack, Modulschnitt, DoD-Kette; Status im Dokument"
  "Prototyp Demo|prototype/OSINT_Plattform_Demo.html|Interaktiver Prototyp, Wegwerf"
  "Projektregeln|CLAUDE.md|Immer geltende Regeln, unter 200 Zeilen"
  "Regel Prototyp|.claude/rules/prototyp.md|Wegwerf-Prototyp, synthetische Daten, Definition of Done"
  "Regel Produktionscode|.claude/rules/produktionscode.md|Verfahrensgarantien, Protokollspuren, Klassifizierung"
  "Regel Dokumentation|.claude/rules/dokumentation.md|Feste Verweise, Nachweisverzeichnis, Verfolgbarkeit"
  "Regel Recht und Datenschutz|.claude/rules/recht-und-datenschutz.md|Rechtsregime, Belegpflicht, Aufbewahrung"
  "Regel Claude-Konfiguration|.claude/rules/claude-konfiguration.md|Mechanismen, Hooks, Rollendateien"
  "Gate Prototyp-Trennung|.claude/hooks/block-prototype-import.sh|Blockiert Importe zwischen Prototyp und Produktionscode"
  "Gate main-Schutz|.claude/hooks/block-main-write.sh|Blockiert Schreibzugriffe und Pushes nach main"
  "Hook Eingang Methodik|.claude/hooks/session-start-eingang.sh|Gibt den Eingang beim Sitzungsstart mit"
  "Hook- und Gate-Konfiguration|.claude/settings.json|Versionierte Hook-Konfiguration"
  "Regel Versionierung und Nachweisfluss|.claude/rules/versionierung-und-nachweisfluss.md|Versionsschilder, Commit-Identitaet, Nachweisfluss"
  "Arbeitsablauf Nachweisfluss|.github/workflows/nachweise-uebertragen.yml|Erzeugt und uebertraegt das Nachweisverzeichnis nach Repo B (6.6)"
  "Arbeitsablauf Meilenstein|.github/workflows/meilenstein-tag.yml|Versionsschild und Release bei Meilenstein-Merge (6.6)"
  "Erzeuger Nachweisverzeichnis|scripts/nachweise-erzeugen.sh|Erzeugt docs/NACHWEISE.md; Artefaktliste ist hier massgebend"
  "Rolle backend-engineer|.claude/agents/backend-engineer.md|Rollendatei nach ADR 0001: Ausloesefall, Rechte, Modell, maxTurns"
  "Rolle datenschutzexperte|.claude/agents/datenschutzexperte.md|Rollendatei nach ADR 0001: Ausloesefall, Rechte, Modell, maxTurns"
  "Rolle devops-engineer|.claude/agents/devops-engineer.md|Rollendatei nach ADR 0001: Ausloesefall, Rechte, Modell, maxTurns"
  "Rolle digital-forensics-spezialist|.claude/agents/digital-forensics-spezialist.md|Rollendatei nach ADR 0001: Ausloesefall, Rechte, Modell, maxTurns"
  "Rolle docker-kubernetes-experte|.claude/agents/docker-kubernetes-experte.md|Rollendatei nach ADR 0001: Ausloesefall, Rechte, Modell, maxTurns"
  "Rolle dynamic-software-tester|.claude/agents/dynamic-software-tester.md|Rollendatei nach ADR 0001: Ausloesefall, Rechte, Modell, maxTurns"
  "Rolle frontend-engineer|.claude/agents/frontend-engineer.md|Rollendatei nach ADR 0001: Ausloesefall, Rechte, Modell, maxTurns"
  "Rolle full-stack-engineer|.claude/agents/full-stack-engineer.md|Rollendatei nach ADR 0001: Ausloesefall, Rechte, Modell, maxTurns"
  "Rolle it-supporter|.claude/agents/it-supporter.md|Rollendatei nach ADR 0001: Ausloesefall, Rechte, Modell, maxTurns"
  "Rolle legal-reviewer|.claude/agents/legal-reviewer.md|Rollendatei nach ADR 0001: Ausloesefall, Rechte, Modell, maxTurns"
  "Rolle pentester|.claude/agents/pentester.md|Rollendatei nach ADR 0001: Ausloesefall, Rechte, Modell, maxTurns"
  "Rolle product-owner|.claude/agents/product-owner.md|Rollendatei nach ADR 0001: Ausloesefall, Rechte, Modell, maxTurns"
  "Rolle protocol-master|.claude/agents/protocol-master.md|Rollendatei nach ADR 0001: Ausloesefall, Rechte, Modell, maxTurns"
  "Rolle requirements-engineer|.claude/agents/requirements-engineer.md|Rollendatei nach ADR 0001: Ausloesefall, Rechte, Modell, maxTurns"
  "Rolle scrum-master|.claude/agents/scrum-master.md|Rollendatei nach ADR 0001: Ausloesefall, Rechte, Modell, maxTurns"
  "Rolle secdevops-engineer|.claude/agents/secdevops-engineer.md|Rollendatei nach ADR 0001: Ausloesefall, Rechte, Modell, maxTurns"
  "Rolle security-specialist-grc|.claude/agents/security-specialist-grc.md|Rollendatei nach ADR 0001: Ausloesefall, Rechte, Modell, maxTurns"
  "Rolle software-architect|.claude/agents/software-architect.md|Rollendatei nach ADR 0001: Ausloesefall, Rechte, Modell, maxTurns"
  "Rolle static-software-tester|.claude/agents/static-software-tester.md|Rollendatei nach ADR 0001: Ausloesefall, Rechte, Modell, maxTurns"
  "Rolle ux-ui-designer|.claude/agents/ux-ui-designer.md|Rollendatei nach ADR 0001: Ausloesefall, Rechte, Modell, maxTurns"
  "Rolle vulnerability-manager|.claude/agents/vulnerability-manager.md|Rollendatei nach ADR 0001: Ausloesefall, Rechte, Modell, maxTurns"
)

fehler=0
zeilen=""
for eintrag in "${ARTEFAKTE[@]}"; do
  IFS='|' read -r name pfad beschr <<<"$eintrag"
  if [ ! -e "$pfad" ]; then
    echo "FEHLT: $pfad" >&2; fehler=1; continue
  fi
  pruefsumme=$(git log -1 --format=%H -- "$pfad" 2>/dev/null)
  if [ -z "$pruefsumme" ]; then
    echo "NICHT COMMITTET: $pfad" >&2; fehler=1
    zeilen+="| $name | \`$pfad\` | *noch nicht committet* | — | $beschr |"$'\n'
    continue
  fi
  stand=$(git log -1 --format=%ad --date=short -- "$pfad")
  zeilen+="| $name | \`$pfad\` | [\`${pruefsumme:0:12}\`]($basis/$pruefsumme/$pfad) | $stand | $beschr |"$'\n'
done

kopf_commit=$(git rev-parse HEAD)
anzahl=${#ARTEFAKTE[@]}

{
  echo "# Nachweisverzeichnis"
  echo
  echo "| | |"
  echo "|---|---|"
  echo "| **Erzeugt durch** | \`scripts/nachweise-erzeugen.sh\` |"
  echo "| **Grundlage** | Projektauftrag 6.6 |"
  echo "| **Verantwortlich** | Protocol Master |"
  echo "| **Stand des Repositories** | \`$kopf_commit\` |"
  echo "| **Artefakte** | $anzahl |"
  echo
  echo "**Diese Datei wird erzeugt, nicht von Hand gepflegt** (6.6). Sie wird bei jedem"
  echo "Meilenstein neu erzeugt. Wer sie von Hand ändert, verliert die Änderung beim"
  echo "nächsten Lauf."
  echo
  echo "**Zur Form der Verweise.** Ein Verweis auf einen Zweig ändert sich mit jedem"
  echo "Commit und taugt nicht als Nachweis. Verwiesen wird deshalb über die"
  echo "40-stellige Prüfsumme des Commits, in dem das Artefakt **zuletzt geändert**"
  echo "wurde. Ein Verweis auf einen Zweig statt auf eine Prüfsumme ist kein Nachweis"
  echo "und kommt hier nicht vor. Zeilenanker werden vermieden, weil Zeilen sich"
  echo "verschieben; verwiesen wird auf die Datei beim Commit, ergänzt um den"
  echo "Namen des Abschnitts."
  echo
  echo "Die angezeigte Kurzform der Prüfsumme ist nur die Beschriftung. Der Verweis"
  echo "selbst trägt die vollständigen 40 Stellen."
  echo
  echo "| Artefakt | Pfad | Fester Verweis | Stand | Beschreibung |"
  echo "|---|---|---|---|---|"
  printf '%s' "$zeilen"
  echo
  echo "---"
  echo
  echo "## Übertragung nach Repo B"
  echo
  echo "Der Arbeitsablauf \`.github/workflows/nachweise-uebertragen.yml\` überträgt"
  echo "**dieses Verzeichnis**, nicht den Inhalt der Artefakte, in das Verzeichnis"
  echo "\`nachweise/\` von \`github.com/valITino/r3coscrum\`. Ausgelöst wird er durch"
  echo "einen Push nach \`main\` mit Änderungen an den Pfaden der Artefaktliste, durch"
  echo "ein Versionsschild oder von Hand; bei identischem Stand in Repo B endet der"
  echo "Lauf ohne Schreibvorgang (6.6). Repo B bleibt frei von Kopien."
} > "$ziel"

if [ $fehler -ne 0 ]; then
  echo "Nachweisverzeichnis erzeugt, aber unvollständig: mindestens ein Artefakt fehlt oder ist nicht committet." >&2
  exit 1
fi
echo "Nachweisverzeichnis erzeugt: $ziel ($anzahl Artefakte)"
exit 0
