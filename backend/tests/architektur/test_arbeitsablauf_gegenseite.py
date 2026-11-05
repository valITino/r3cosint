"""Architekturtest R3-Q-001: Form des Arbeitsablaufs der Gegenseite (Einheit G4, O-12).

Gelesen werden die Dateien unter .github/workflows/ als Text und mit yaml.safe_load, ohne
Netz und ohne Runner (ADR 0002, Abschnitt 5, Nachtrag "Festlegung fuer G4", Zeile "Pruefung
des Arbeitsablaufs selbst"). Die Nummern 01 bis 08 in den Testnamen sind die acht
Zusicherungen dieser Zeile (Festlegung); die Nummern 00 und 09 ff. sind Zusaetze (Auftrag
G4.2 und Nachbesserung): 09 Zeitgrenzen, 10 COMPOSE_BAKE und Abschaltung der Befehle,
11 kein if, 12 Urteilsform des Schritts make dod (einschliesslich set -uo pipefail), 13 Umgebung und Ausfuehrungsform,
14 keine Ausdruecke in run, 15 weitere Rohtextverbote, 16 Einzigkeit, 17 Kopie-Variable,
18 Laden des Images des Dienstes datenbank ueber den Digest (S1.1, E-S1-03 a).
Alle Pfade folgen der Lage dieser Datei, nicht dem Arbeitsverzeichnis.

Pruefort: Voreinstellung ist .github/workflows/ der Repository-Wurzel. Fuer die
Mutationsprobe (Dynamic Software Tester) darf die Umgebungsvariable
R3COSINT_WORKFLOWS_VERZEICHNIS auf eine Kopie dieses Verzeichnisses zeigen; ohne die
Variable liest der Test allein das Repository.

Kopie-Grenze: Wer die Umgebung von D5 (make dod) setzt, kann den Test mit der Variable auf
eine Kopie lenken; das Makefile setzt sie nicht, und Testfall 17 verlangt, dass keine Datei
unter .github/workflows/ ihren Namen nennt (keine env-Ebene setzt sie). Gewaehlt ist die
Umgebungsvariable statt eines pytest-Parameters, weil die Testfaelle dann unveraendert
bleiben und die Mutationsprobe ohne Hilfsfunktion auskommt; die Grenze ist benannt.

Grenzen: Der Test prueft die Form des Texts, nicht das Verhalten des Runners. YAML-Anker,
Aliase und Ausdruecke ${{ }} werden nicht ausgewertet; ein Ausdruck als Wert gilt als
anderer Wert und faellt. Der Schluessel on wird von PyYAML (YAML 1.1) als True gelesen;
_ausloeser behandelt beide Schreibweisen und meldet beide zugleich als Fund. Die Suche nach
"make dod" im run-Block ist textlich (ein Kommentar im Block zaehlt mit). Ein Auftrag mit
uses: (wiederverwendbarer Arbeitsablauf) wird von (1) erfasst, von (5) nicht, weil (5) nur
Schritte liest. Zeichenketten im Rohtext (4), (7) werden ohne Beachtung der Gross- und
Kleinschreibung nicht erweitert: "Secrets." in anderer Schreibung wird nicht erkannt.
"""

import os
import re
from pathlib import Path
from typing import Any

import pytest
import yaml

WURZEL = Path(__file__).resolve().parents[3]
VERZEICHNIS = Path(
    os.environ.get(
        "R3COSINT_WORKFLOWS_VERZEICHNIS", str(WURZEL / ".github" / "workflows")
    )
)
GEGENSEITE = VERZEICHNIS / "kette-gegenseite.yml"
KENNUNG = "R3-Q-001"

PRUEFSUMME = re.compile(r"^[^@\s]+@[0-9a-f]{40}$")
MAKE_DOD = re.compile(r"\bmake\s+dod\b")
VERBOTENE_AUSLOESER = (
    "pull_request_target",
    "workflow_run",
    "schedule",
    "workflow_dispatch",
)


def _dateien() -> list[Path]:
    return sorted(
        p
        for p in VERZEICHNIS.iterdir()
        if p.is_file() and p.suffix in (".yml", ".yaml")
    )


def _lade(pfad: Path) -> dict[str, Any]:
    assert pfad.is_file(), f"{pfad} fehlt"
    inhalt = yaml.safe_load(pfad.read_text(encoding="utf-8"))
    assert isinstance(inhalt, dict), f"{pfad} ist kein YAML-Abbild"
    return inhalt


def _ausloeser(doc: dict[Any, Any]) -> Any:
    """Wert von on; PyYAML liest den unquotierten Schluessel on als True."""
    assert not (True in doc and "on" in doc), "on kommt als True und als 'on' vor"
    assert True in doc or "on" in doc, "kein Schluessel on im Arbeitsablauf"
    return doc[True] if True in doc else doc["on"]


def _ausloeser_namen(doc: dict[Any, Any]) -> set[str]:
    wert = _ausloeser(doc)
    if isinstance(wert, str):
        return {wert}
    if isinstance(wert, list):
        return {str(x) for x in wert}
    assert isinstance(wert, dict), f"on hat unerwartete Form: {type(wert).__name__}"
    return {str(k) for k in wert}


def _auftraege(doc: dict[str, Any]) -> dict[str, Any]:
    jobs = doc.get("jobs")
    assert isinstance(jobs, dict), "jobs fehlt oder ist kein Abbild"
    return jobs


def _schritte(auftrag: Any) -> list[dict[str, Any]]:
    assert isinstance(auftrag, dict), "Auftrag ist kein Abbild"
    schritte = auftrag.get("steps")
    assert isinstance(schritte, list), "steps fehlt oder ist keine Liste"
    assert all(isinstance(s, dict) for s in schritte), "ein Schritt ist kein Abbild"
    return schritte


def _alle_schritte(doc: dict[str, Any]) -> list[tuple[str, dict[str, Any]]]:
    return [(k, s) for k, a in _auftraege(doc).items() for s in _schritte(a)]


def _make_dod_schritte(doc: dict[str, Any]) -> list[dict[str, Any]]:
    return [
        s
        for _, s in _alle_schritte(doc)
        if isinstance(s.get("run"), str) and MAKE_DOD.search(s["run"])
    ]


def test_r3_q_001_00_arbeitsablauf_der_gegenseite_liegt_vor() -> None:
    assert GEGENSEITE.is_file(), f"{GEGENSEITE} fehlt"
    assert len(_dateien()) >= 1


@pytest.mark.parametrize("datei", _dateien(), ids=lambda p: p.name)
def test_r3_q_001_01_jede_aktion_steht_auf_einer_pruefsumme(datei: Path) -> None:
    doc = _lade(datei)
    fundorte: list[tuple[str, Any]] = []
    for name, auftrag in _auftraege(doc).items():
        if isinstance(auftrag, dict) and "uses" in auftrag:
            fundorte.append((f"jobs.{name}.uses", auftrag["uses"]))
        for i, schritt in enumerate(_schritte(auftrag)):
            if "uses" in schritt:
                fundorte.append((f"jobs.{name}.steps[{i}].uses", schritt["uses"]))
    for ort, wert in fundorte:
        assert isinstance(wert, str) and PRUEFSUMME.match(wert), (
            f"{datei.name} {ort}: {wert!r} steht nicht auf einer 40-stelligen "
            "Hex-Pruefsumme hinter @"
        )


def test_r3_q_001_02_rechte_nur_contents_read_ohne_auftragsrechte() -> None:
    doc = _lade(GEGENSEITE)
    assert doc.get("permissions") == {"contents": "read"}, (
        f"permissions oberster Ebene ist {doc.get('permissions')!r}, erwartet "
        "genau {'contents': 'read'}"
    )
    for name, auftrag in _auftraege(doc).items():
        assert isinstance(auftrag, dict) and "permissions" not in auftrag, (
            f"Auftrag {name} traegt einen permissions-Block"
        )


def test_r3_q_001_03_keine_verbotenen_ausloeser() -> None:
    namen = _ausloeser_namen(_lade(GEGENSEITE))
    gefunden = sorted(namen & set(VERBOTENE_AUSLOESER))
    assert not gefunden, f"verbotene Ausloeser in on: {gefunden}"


def test_r3_q_001_04_rohtext_ohne_secrets_und_github_token() -> None:
    text = GEGENSEITE.read_text(encoding="utf-8")
    for verboten in ("secrets.", "GITHUB_TOKEN"):
        assert verboten not in text, (
            f"{GEGENSEITE.name} enthaelt {verboten!r} (auch in Kommentaren)"
        )


def test_r3_q_001_05_nur_checkout_ohne_zugangsdaten_mit_voller_historie() -> None:
    doc = _lade(GEGENSEITE)
    verwendungen = [s for _, s in _alle_schritte(doc) if "uses" in s]
    assert verwendungen, "keine Aktion gefunden (actions/checkout erwartet)"
    for schritt in verwendungen:
        uses = schritt["uses"]
        assert isinstance(uses, str) and uses.startswith("actions/checkout@"), (
            f"Aktion {uses!r} ausser actions/checkout"
        )
        mit = schritt.get("with")
        assert isinstance(mit, dict), f"{uses}: with fehlt"
        assert mit.get("persist-credentials") is False, (
            f"{uses}: with.persist-credentials ist {mit.get('persist-credentials')!r}, erwartet false"
        )
        tiefe = mit.get("fetch-depth")
        assert isinstance(tiefe, int) and not isinstance(tiefe, bool) and tiefe == 0, (
            f"{uses}: with.fetch-depth ist {tiefe!r}, erwartet 0"
        )


def test_r3_q_001_06_kein_continue_on_error_und_kein_if_am_schritt() -> None:
    doc = _lade(GEGENSEITE)
    for name, auftrag in _auftraege(doc).items():
        assert auftrag.get("continue-on-error", False) is False, (
            f"Auftrag {name}: continue-on-error ist {auftrag.get('continue-on-error')!r}"
        )
    for name, schritt in _alle_schritte(doc):
        bezeichnung = (
            f"Auftrag {name}, Schritt {schritt.get('name', schritt.get('uses', '?'))!r}"
        )
        assert schritt.get("continue-on-error", False) is False, (
            f"{bezeichnung}: continue-on-error ist {schritt.get('continue-on-error')!r}"
        )
        assert "if" not in schritt, f"{bezeichnung}: traegt if"


def test_r3_q_001_07_genau_ein_make_dod_schritt_und_liste_ungenannt() -> None:
    doc = _lade(GEGENSEITE)
    schritte = _make_dod_schritte(doc)
    assert len(schritte) == 1, (
        f"{len(schritte)} Schritte rufen make dod auf, erwartet genau 1"
    )
    for datei in _dateien():
        text = datei.read_text(encoding="utf-8")
        for verboten in ("dod-gate-terminierte-lagen", "dod-gate.sh"):
            assert verboten not in text, f"{datei.name} nennt {verboten!r}"


def test_r3_q_001_08_ein_auftrag_kette_mit_name_runner_und_ausloesern() -> None:
    doc = _lade(GEGENSEITE)
    auftraege = _auftraege(doc)
    assert list(auftraege) == ["kette"], (
        f"Auftraege {list(auftraege)}, erwartet genau ['kette']"
    )
    kette = auftraege["kette"]
    assert kette.get("runs-on") == "ubuntu-24.04", (
        f"runs-on ist {kette.get('runs-on')!r}"
    )
    assert kette.get("name") == "make dod (ohne Liste der terminierten Lagen)", (
        f"Auftragsname ist {kette.get('name')!r}"
    )
    on = _ausloeser(doc)
    assert isinstance(on, dict), "on ist kein Abbild"
    assert set(on) == {"pull_request", "push"}, f"Ausloeser {sorted(map(str, on))}"
    pr = on["pull_request"]
    assert isinstance(pr, dict) and set(pr) == {"branches", "types"}, (
        f"pull_request hat Schluessel {pr!r}, erwartet genau branches und types"
    )
    assert pr["branches"] == ["main"], f"pull_request.branches ist {pr['branches']!r}"
    assert sorted(pr["types"]) == ["opened", "reopened", "synchronize"], (
        f"pull_request.types ist {pr['types']!r}"
    )
    assert len(pr["types"]) == 3, f"pull_request.types ist {pr['types']!r}"
    push = on["push"]
    assert isinstance(push, dict) and push == {"branches": ["wegwerf/**"]}, (
        f"push ist {push!r}, erwartet genau branches: [wegwerf/**]"
    )


def test_r3_q_001_09_zeitgrenzen_auftrag_30_und_make_dod_20_minuten() -> None:
    doc = _lade(GEGENSEITE)
    kette = _auftraege(doc)["kette"]
    assert kette.get("timeout-minutes") == 30 and not isinstance(
        kette.get("timeout-minutes"), bool
    ), f"timeout-minutes am Auftrag ist {kette.get('timeout-minutes')!r}, erwartet 30"
    schritte = _make_dod_schritte(doc)
    assert len(schritte) == 1, "make-dod-Schritt nicht eindeutig"
    grenze = schritte[0].get("timeout-minutes")
    assert grenze == 20 and not isinstance(grenze, bool), (
        f"timeout-minutes am Schritt make dod ist {grenze!r}, erwartet 20"
    )


def test_r3_q_001_10_make_dod_schritt_setzt_compose_bake_und_stoppt_befehle() -> None:
    schritte = _make_dod_schritte(_lade(GEGENSEITE))
    assert len(schritte) == 1, "make-dod-Schritt nicht eindeutig"
    schritt = schritte[0]
    env = schritt.get("env")
    assert isinstance(env, dict) and env.get("COMPOSE_BAKE") == "false", (
        f"env.COMPOSE_BAKE ist {env.get('COMPOSE_BAKE') if isinstance(env, dict) else env!r}, "
        "erwartet die Zeichenkette 'false'"
    )
    assert "::stop-commands::" in schritt["run"], (
        "der run-Block des make-dod-Schritts enthaelt kein '::stop-commands::'"
    )


def _run_bloecke(doc: dict[str, Any]) -> list[str]:
    return [s["run"] for _, s in _alle_schritte(doc) if isinstance(s.get("run"), str)]


def test_r3_q_001_11_kein_if_am_auftrag_und_an_keinem_schritt() -> None:
    """Zusatz: ein uebersprungener Auftrag oder Schritt zaehlte als gruen."""
    doc = _lade(GEGENSEITE)
    for name, auftrag in _auftraege(doc).items():
        assert "if" not in auftrag, f"Auftrag {name} traegt if"
    for name, schritt in _alle_schritte(doc):
        assert "if" not in schritt, (
            f"Auftrag {name}, Schritt {schritt.get('name')!r}: if"
        )


AUFRUF = re.compile(r"^(env(?: -u \w+)* )?make dod\b")
ENV_PRAEFIX = "env -u GITHUB_ENV -u GITHUB_PATH -u GITHUB_OUTPUT -u GITHUB_STATE -u GITHUB_STEP_SUMMARY "


def test_r3_q_001_12_urteilsform_des_schritts_make_dod() -> None:
    """Zusatz (Zeile "Aufruf und Urteil"): der Rueckgabewert von make dod ist das Urteil.

    Zusatz zu 12 (DT-G4-01): vor dem Aufruf steht set -uo pipefail und keine Zeile
    set ... +o pipefail; ohne pipefail liefert die Pipeline den Rueckgabewert von tee.
    """
    bloecke = []
    for block in _run_bloecke(_lade(GEGENSEITE)):
        zeilen = [z.strip() for z in block.splitlines() if z.strip()]
        aufrufe = [z for z in zeilen if AUFRUF.match(z)]
        if aufrufe:
            bloecke.append((zeilen, aufrufe))
    assert len(bloecke) == 1, (
        f"{len(bloecke)} run-Bloecke rufen make dod auf, erwartet 1"
    )
    zeilen, aufrufe = bloecke[0]
    assert len(aufrufe) == 1, f"{len(aufrufe)} Aufrufzeilen im Block, erwartet 1"
    aufruf = aufrufe[0]
    assert aufruf.startswith(ENV_PRAEFIX + "make dod"), (
        f"Aufruf ohne env -u Praefix: {aufruf!r}"
    )
    assert aufruf.endswith("|| rc=$?"), f"Aufruf endet nicht auf '|| rc=$?': {aufruf!r}"
    i = zeilen.index(aufruf)
    assert "rc=0" in zeilen[:i], "rc=0 steht nicht vor dem Aufruf"
    assert "set -uo pipefail" in zeilen[:i], (
        "set -uo pipefail steht nicht vor dem Aufruf"
    )
    for z in zeilen[:i]:
        assert not (z.startswith("set ") and "+o pipefail" in z), (
            f"Zeile vor dem Aufruf hebt pipefail auf: {z!r}"
        )
    assert any(z.startswith('echo "::stop-commands::') for z in zeilen[:i]), (
        "::stop-commands:: steht nicht vor dem Aufruf"
    )
    assert 'echo "::$TOKEN::"' in zeilen[i + 1 :], (
        "Wiedereinschaltzeile steht nicht nach dem Aufruf"
    )
    assert zeilen[-1] == 'exit "$rc"', (
        f'letzte Zeile ist {zeilen[-1]!r}, erwartet exit "$rc"'
    )
    for z in zeilen[i + 1 : -1]:
        assert not z.startswith("rc="), f"Zeile nach dem Aufruf setzt rc neu: {z!r}"
    text = "\n".join(zeilen)
    assert text.count("$TOKEN") == 2, (
        f"$TOKEN kommt {text.count('$TOKEN')} mal vor, erwartet 2 (Abschaltung, Wiedereinschaltung)"
    )
    for verboten in ("|| true", "exit 0", "PIPESTATUS"):
        assert verboten not in text, f"der Block enthaelt {verboten!r}"


def test_r3_q_001_13_umgebung_und_ausfuehrungsform_unveraendert() -> None:
    """Zusatz: env genau COMPOSE_BAKE; keine Umgebung, Standards, Container, Dienste, Matrix."""
    doc = _lade(GEGENSEITE)
    schritte = _make_dod_schritte(doc)
    assert len(schritte) == 1, "make-dod-Schritt nicht eindeutig"
    assert schritte[0].get("env") == {"COMPOSE_BAKE": "false"}, (
        f"env des Schritts make dod ist {schritte[0].get('env')!r}, erwartet genau COMPOSE_BAKE"
    )
    for schluessel in ("env", "defaults", "container", "services", "strategy"):
        assert schluessel not in doc, f"{schluessel} auf oberster Ebene"
        for name, auftrag in _auftraege(doc).items():
            assert schluessel not in auftrag, f"{schluessel} am Auftrag {name}"
    for name, schritt in _alle_schritte(doc):
        for schluessel in ("shell", "working-directory"):
            assert schluessel not in schritt, (
                f"Auftrag {name}, Schritt {schritt.get('name')!r}: {schluessel}"
            )


def test_r3_q_001_14_kein_ausdruck_in_run_bloecken() -> None:
    """Zusatz: Werte aus Ausdruecken gehen ueber env, nie in den Skriptblock."""
    for block in _run_bloecke(_lade(GEGENSEITE)):
        assert "${{" not in block, f"run-Block enthaelt einen Ausdruck: {block[:80]!r}"


def test_r3_q_001_15_rohtext_ohne_weitere_zugangsmittel() -> None:
    """Zusatz zu (4): github.token, GH_TOKEN und docker login im Rohtext."""
    text = GEGENSEITE.read_text(encoding="utf-8")
    for verboten in ("github.token", "GH_TOKEN", "docker login"):
        assert verboten not in text, f"{GEGENSEITE.name} enthaelt {verboten!r}"


def test_r3_q_001_16_einzigkeit_der_datei() -> None:
    """Zusatz: genau eine Datei mit Auftrag kette, genau eine mit dem Namen, und sie heisst so."""
    mit_kette: list[str] = []
    mit_name: list[str] = []
    for datei in _dateien():
        doc = _lade(datei)
        if "kette" in _auftraege(doc):
            mit_kette.append(datei.name)
        if doc.get("name") == "Kette auf der Gegenseite (O-12)":
            mit_name.append(datei.name)
    assert mit_kette == ["kette-gegenseite.yml"], (
        f"Dateien mit Auftrag kette: {mit_kette}"
    )
    assert mit_name == ["kette-gegenseite.yml"], (
        f"Dateien mit dem Namen der Gegenseite: {mit_name}"
    )


def test_r3_q_001_17_keine_env_ebene_setzt_die_kopie_variable() -> None:
    """Zusatz (Kopie-Grenze): keine Datei nennt R3COSINT_WORKFLOWS_VERZEICHNIS."""
    for datei in _dateien():
        text = datei.read_text(encoding="utf-8")
        assert "R3COSINT_WORKFLOWS_VERZEICHNIS" not in text, (
            f"{datei.name} nennt die Variable"
        )


COMPOSE_TEST = WURZEL / "deploy" / "compose.test.yml"
DIGEST_ZEILE = re.compile(
    r"^\s*image:\s*docker\.io/library/postgres@sha256:([0-9a-f]{64})\s*$", re.MULTILINE
)
BILD_BEFEHL = re.compile(r"\bdocker\s+(pull|create|run)\s+(?:-\S+\s+)*(\S+)")
UV_BILD = re.compile(r'^"?ghcr\.io/astral-sh/uv@sha256:[0-9a-f]{64}\)?"?$')


def test_r3_q_001_18_genau_ein_schritt_laedt_das_image_der_datenbank_ueber_den_digest() -> (
    None
):
    """Zusatz (S1.1, E-S1-03 a): ein Schritt vor make dod laedt allein das Image des Dienstes datenbank.

    Der Digest steht allein in deploy/compose.test.yml (eine Quelle); der Schritt liest ihn
    aus der Zeile image: und laedt nur dieses Image mit docker pull ueber den Digest, danach
    docker image inspect. Sonst wird ausser dem uv-Image des Schritts "uv aus dem Image"
    nichts geladen, erzeugt oder gestartet. Grenze: der Test fuehrt den Schritt nicht aus.
    """
    treffer = DIGEST_ZEILE.findall(COMPOSE_TEST.read_text(encoding="utf-8"))
    assert len(treffer) == 1, (
        f"{COMPOSE_TEST.name} nennt den Digest des Dienstes datenbank {len(treffer)} mal, erwartet 1"
    )
    digest = treffer[0]
    doc = _lade(GEGENSEITE)
    schritte = [s for _, s in _alle_schritte(doc)]
    laden = [
        (i, s)
        for i, s in enumerate(schritte)
        if isinstance(s.get("run"), str) and re.search(r"\bdocker\s+pull\b", s["run"])
    ]
    assert len(laden) == 1, (
        f"{len(laden)} Schritte rufen docker pull auf, erwartet genau 1"
    )
    i_laden, schritt = laden[0]
    assert (
        schritt.get("name") == "Image des Dienstes datenbank ueber den Digest laden"
    ), f"Name des Schritts ist {schritt.get('name')!r}"
    i_dod = schritte.index(_make_dod_schritte(doc)[0])
    assert i_laden < i_dod, "der Schritt, der das Image laedt, steht nicht vor make dod"
    assert i_laden == i_dod - 1, (
        "zwischen dem Laden und make dod steht ein weiterer Schritt"
    )
    run = schritt["run"]
    zeilen = [z.strip() for z in run.splitlines() if z.strip()]
    assert zeilen[0] == "set -euo pipefail", f"erste Zeile ist {zeilen[0]!r}"
    grenze = schritt.get("timeout-minutes")
    assert grenze == 10 and not isinstance(grenze, bool), (
        f"timeout-minutes am Ladeschritt ist {grenze!r}, erwartet 10"
    )
    i_stop = next(
        (i for i, z in enumerate(zeilen) if z.startswith('echo "::stop-commands::')), -1
    )
    assert 0 <= i_stop < zeilen.index('docker pull "$bild"'), (
        "::stop-commands:: steht nicht vor docker pull"
    )
    assert "trap 'echo \"::$TOKEN::\"' EXIT" in zeilen, (
        "Wiedereinschalten in der EXIT-Falle fehlt"
    )
    lesezeilen = [z for z in zeilen if z.startswith('digest="$(sed -n ')]
    assert len(lesezeilen) == 1 and lesezeilen[0].endswith(
        ' deploy/compose.test.yml)"'
    ), f"der Digest wird nicht aus deploy/compose.test.yml gelesen: {lesezeilen}"
    assert r"docker\.io\/library\/postgres@sha256:" in run, (
        "die Lesart des Digests nennt das Image nicht"
    )
    assert 'bild="docker.io/library/postgres@sha256:$digest"' in zeilen, (
        "das Image wird nicht aus dem gelesenen Digest gebildet"
    )
    assert 'docker pull "$bild"' in zeilen, "docker pull ueber $bild fehlt"
    assert zeilen.index('docker pull "$bild"') < zeilen.index(
        'docker image inspect "$bild" >/dev/null'
    ), "docker image inspect steht nicht hinter docker pull"
    # Steht ein Digest im Wortlaut im Arbeitsablauf, muss er dem der Compose-Datei gleichen.
    text = GEGENSEITE.read_text(encoding="utf-8")
    woertlich = re.findall(r"postgres@sha256:([0-9a-f]+)", text)
    assert all(w == digest for w in woertlich), (
        f"Digest im Arbeitsablauf weicht von {COMPOSE_TEST.name} ab: {woertlich}"
    )
    # Sonst wird nichts geladen: jedes Image in docker pull, create und run steht auf einem
    # Digest und ist entweder das uv-Image des Schritts "uv aus dem Image" oder das Datenbank-Image.
    gesehen: list[str] = []
    for block in _run_bloecke(doc):
        for befehl, bild in BILD_BEFEHL.findall(block):
            gesehen.append(f"{befehl} {bild}")
            if befehl == "pull":
                assert bild == '"$bild"', f"docker pull laedt {bild!r}"
            else:
                assert befehl == "create" and UV_BILD.match(bild), (
                    f"docker {befehl} {bild!r} ausser dem uv-Image"
                )
    assert sorted(g.split()[0] for g in gesehen) == ["create", "pull"], (
        f"geladene oder erzeugte Images: {gesehen}"
    )
    for block in _run_bloecke(doc):
        assert not re.search(
            r"\bdocker\s+(image\s+)?(load|import|build|compose\s+pull)\b", block
        ), "ein Schritt laedt, importiert oder baut ein Image"
        assert not re.search(r"postgres:", block), "ein Schritt nennt ein Image mit Tag"
