"""Architekturtest R3-C-003: die Stapel test und produktion sind getrennt.

Gelesen werden die beiden Compose-Dateien unter deploy/, alle Dockerfiles unter
deploy/images/, die Konfigurationsdateien unter deploy/konfiguration/ und das Makefile,
ohne Docker und ohne Netz (ADR 0002, Abschnitt 5, Nachtrag vom 2026-11-04, Einheit G2,
Zeile "Test zur Trennung der Stapel"). Die Nummern (1) bis (10) in den Testnamen sind die
Zusicherungen dieser Zeile. Alle Pfade folgen der Lage dieser Datei, nicht dem
Arbeitsverzeichnis.

Lesarten (G2.3, im Bericht gemeldet): Eine Meldungszeile im Makefile (Zeile mit echo ohne
Verkettung) darf den Text "docker compose" nennen. Die Wache "docker compose version" im
Rezept bau ist die eine Ausnahme von "-f deploy/compose.test.yml", weil die Festlegung sie
selbst vorschreibt und das Plugin ohne Datei abgefragt wird.

Grenzen: Die Auswertung der Ignorierdatei ist vereinfacht (letzte Zeile gewinnt, fnmatch).
Der Dockerfile-Leser kennt keine Heredocs; eine ARG-Referenz im FROM oder ein $ im USER
gilt als Fund. Aufrufe von docker compose ueber eine Variable oder mit globaler Option vor
compose ($(DOCKER) compose, docker --log-level info compose) erkennt Zusicherung (10)
nicht (ST-G23-03). Interpolation und Ausfuehrung der Compose-Dateien sind nicht Gegenstand.
"""

import fnmatch
import json
import re
from pathlib import Path
from typing import Any

import pytest
import yaml

WURZEL = Path(__file__).resolve().parents[3]
DEPLOY = WURZEL / "deploy"
MAKEFILE = WURZEL / "Makefile"
STAPEL = ("test", "produktion")
COMPOSE = {stapel: DEPLOY / f"compose.{stapel}.yml" for stapel in STAPEL}
KENNUNG = "R3-C-003"

DIGEST = re.compile(r"@sha256:[0-9a-f]{64}$")
GEHEIMNISSCHLUESSEL = re.compile(r"PASSWORD|PASSWORT|SECRET|TOKEN|KEY", re.IGNORECASE)
GEHEIMNISDATEI = re.compile(r"^\$\{([A-Z][A-Z0-9_]*):\?\}/[^/\s$]+$")
VERKETTUNG = re.compile(r"[;|`&]|\$\(|\n|[<>]\(")
UMLEITUNG = re.compile(r"\d*>&\d+")
NUR_TESTDATEI = re.compile(r"docker\s+compose\s+-f\s+deploy/compose\.test\.yml(\s|$)")


def _lade(stapel: str) -> dict[str, Any]:
    inhalt = yaml.safe_load(COMPOSE[stapel].read_text(encoding="utf-8"))
    assert isinstance(inhalt, dict), f"{COMPOSE[stapel]} ist kein YAML-Abbild"
    return inhalt


def _abschnitt(datei: dict[str, Any], name: str) -> dict[str, Any]:
    wert = datei.get(name) or {}
    assert isinstance(wert, dict), f"Abschnitt {name} ist kein Abbild"
    return wert


def _dienste(stapel: str) -> dict[str, dict[str, Any]]:
    dienste = _abschnitt(_lade(stapel), "services")
    assert dienste, f"{stapel}: keine Dienste"
    return dienste


def _wirkungsname(datei: dict[str, Any], abschnitt: str, schluessel: str) -> str:
    """Name, den Compose dem Netz oder Datentraeger gibt: name: oder Projekt_Schluessel."""
    eintrag = _abschnitt(datei, abschnitt).get(schluessel) or {}
    name = eintrag.get("name") if isinstance(eintrag, dict) else None
    return str(name) if name else f"{datei.get('name')}_{schluessel}"


def _namen(stapel: str, abschnitt: str) -> set[str]:
    datei = _lade(stapel)
    return {_wirkungsname(datei, abschnitt, s) for s in _abschnitt(datei, abschnitt)}


def _als_liste(wert: Any) -> list[Any]:
    if wert is None:
        return []
    return wert if isinstance(wert, list) else [wert]


def _umgebung(dienst: dict[str, Any], schluessel: str) -> dict[str, str]:
    roh = dienst.get(schluessel) or {}
    if isinstance(roh, dict):
        return {str(k): "" if v is None else str(v) for k, v in roh.items()}
    ergebnis: dict[str, str] = {}
    for zeile in roh:
        name, _, wert = str(zeile).partition("=")
        ergebnis[name] = wert
    return ergebnis


def _ist_geheimnisverweis(name: str, wert: str) -> bool:
    return name.endswith("_FILE") and wert.startswith("/run/secrets/")


def _dockerfiles() -> list[Path]:
    gefunden = sorted((DEPLOY / "images").rglob("Dockerfile*"))
    gefunden = [
        p for p in gefunden if p.is_file() and not p.name.endswith(".dockerignore")
    ]
    assert gefunden, "kein Dockerfile unter deploy/images/"
    return gefunden


def _anweisungen(dockerfile: Path) -> list[tuple[str, str]]:
    """Anweisungen (GROSSBUCHSTABEN, Rest) mit verbundenen Fortsetzungszeilen."""
    ergebnis: list[tuple[str, str]] = []
    puffer = ""
    for zeile in dockerfile.read_text(encoding="utf-8").splitlines():
        if not puffer and (not zeile.strip() or zeile.lstrip().startswith("#")):
            continue
        if puffer and zeile.lstrip().startswith("#"):
            continue
        fortgesetzt = zeile.rstrip().endswith("\\")
        puffer += (zeile.rstrip()[:-1] if fortgesetzt else zeile) + " "
        if fortgesetzt:
            continue
        wort, _, rest = puffer.strip().partition(" ")
        ergebnis.append((wort.upper(), rest.strip()))
        puffer = ""
    assert not puffer.strip(), f"{dockerfile}: Fortsetzungszeile ohne Ende"
    return ergebnis


def _optionen_und_rest(rest: str) -> tuple[dict[str, str], list[str]]:
    optionen: dict[str, str] = {}
    rest = rest.strip()
    while rest.startswith("--"):
        kopf, _, rest = rest.partition(" ")
        rest = rest.strip()
        name, _, wert = kopf[2:].partition("=")
        optionen[name] = wert
    if rest.startswith("["):
        try:
            roh = json.loads(rest)
        except ValueError:
            roh = None
        if isinstance(roh, list) and all(isinstance(e, str) for e in roh):
            return optionen, [str(e) for e in roh]
    return optionen, rest.split()


def _stufen(dockerfile: Path) -> list[tuple[str, list[tuple[str, str]]]]:
    """Stufen als (Image-Angabe, Anweisungen nach dem FROM)."""
    stufen: list[tuple[str, list[tuple[str, str]]]] = []
    for wort, rest in _anweisungen(dockerfile):
        if wort == "FROM":
            _, teile = _optionen_und_rest(rest)
            stufen.append((teile[0] if teile else "", []))
        elif stufen:
            stufen[-1][1].append((wort, rest))
        elif wort != "ARG":
            pytest.fail(f"{dockerfile}: Anweisung {wort} vor dem ersten FROM")
    assert stufen, f"{dockerfile}: kein FROM"
    return stufen


def _alias_namen(dockerfile: Path) -> set[str]:
    alias: set[str] = set()
    for wort, rest in _anweisungen(dockerfile):
        if wort == "FROM":
            teile = rest.split()
            if len(teile) >= 3 and teile[-2].upper() == "AS":
                alias.add(teile[-1])
    return alias


def _ignoriert(dockerfile: Path, kontext: Path, pfad: str) -> bool:
    """Schliesst die Ignorierdatei den Pfad aus (letzte Zeile gewinnt, vereinfachte Muster)?"""
    datei = dockerfile.with_name(dockerfile.name + ".dockerignore")
    if not datei.is_file():
        datei = kontext / ".dockerignore"
    if not datei.is_file():
        return False
    ausgeschlossen = False
    for zeile in datei.read_text(encoding="utf-8").splitlines():
        muster = zeile.strip()
        if not muster or muster.startswith("#"):
            continue
        negiert = muster.startswith("!")
        muster = muster.lstrip("!").strip("/")
        if negiert and (muster == pfad or muster.startswith(pfad + "/")):
            ausgeschlossen = False
        elif not negiert and (muster in ("**", pfad) or fnmatch.fnmatch(pfad, muster)):
            ausgeschlossen = True
    return ausgeschlossen


def _baukontexte(stapel: str) -> list[tuple[str, Path, Path]]:
    """(Dienst, aufgeloester Kontext, aufgeloestes Dockerfile) je Dienst mit build."""
    ergebnis: list[tuple[str, Path, Path]] = []
    for name, dienst in _dienste(stapel).items():
        bau = dienst.get("build")
        if bau is None:
            continue
        angaben = {"context": bau} if isinstance(bau, str) else dict(bau)
        kontext = (DEPLOY / str(angaben.get("context", "."))).resolve()
        dockerfile = (kontext / str(angaben.get("dockerfile", "Dockerfile"))).resolve()
        ergebnis.append((name, kontext, dockerfile))
    return ergebnis


def _unter(pfad: Path, ober: Path) -> bool:
    return pfad == ober or ober in pfad.parents


# (1) Projektnamen


def test_r3_c_003_1_projektnamen_der_stapel_sind_verschieden() -> None:
    namen = {stapel: _lade(stapel).get("name") for stapel in STAPEL}
    assert all(isinstance(n, str) and n for n in namen.values()), (
        f"name: fehlt: {namen}"
    )
    assert len(set(namen.values())) == len(STAPEL), f"gleicher Projektname: {namen}"


# (2) Netze


def test_r3_c_003_2_netznamen_der_stapel_sind_disjunkt() -> None:
    gemeinsam = _namen("test", "networks") & _namen("produktion", "networks")
    assert not gemeinsam, f"gemeinsame Netznamen in beiden Stapeln: {sorted(gemeinsam)}"


@pytest.mark.parametrize("stapel", STAPEL)
def test_r3_c_003_2_netze_sind_intern_und_dienste_nennen_ihre_netze(
    stapel: str,
) -> None:
    netze = _abschnitt(_lade(stapel), "networks")
    assert netze, f"{stapel}: kein Netz"
    for schluessel, netz in netze.items():
        netz = netz or {}
        assert netz.get("internal") is True, (
            f"{stapel}: Netz {schluessel} ohne internal: true"
        )
        assert "external" not in netz, f"{stapel}: Netz {schluessel} ist external"
    for name, dienst in _dienste(stapel).items():
        assert "network_mode" not in dienst, f"{stapel}: {name} setzt network_mode"
        genannt = dienst.get("networks")
        assert genannt, f"{stapel}: {name} nennt keine Netze ausdruecklich"
        unbekannt = set(genannt) - set(netze)
        assert not unbekannt, (
            f"{stapel}: {name} nennt unbekannte Netze {sorted(unbekannt)}"
        )


# (3) Datentraeger


def test_r3_c_003_3_datentraegernamen_der_stapel_sind_disjunkt() -> None:
    gemeinsam = _namen("test", "volumes") & _namen("produktion", "volumes")
    assert not gemeinsam, (
        f"gemeinsame Datentraeger in beiden Stapeln: {sorted(gemeinsam)}"
    )


@pytest.mark.parametrize("stapel", STAPEL)
def test_r3_c_003_3_keine_bindung_eines_host_pfads(stapel: str) -> None:
    datei = _lade(stapel)
    assert "configs" not in datei, f"{stapel}: configs auf oberster Ebene"
    assert "include" not in datei, f"{stapel}: include auf oberster Ebene"
    benannt = _abschnitt(datei, "volumes")
    for schluessel, traeger in benannt.items():
        traeger = traeger or {}
        assert "external" not in traeger, (
            f"{stapel}: Datentraeger {schluessel} ist external"
        )
        optionen = traeger.get("driver_opts") or {}
        assert not optionen, (
            f"{stapel}: Datentraeger {schluessel} mit driver_opts {optionen}"
        )
    for name, dienst in _dienste(stapel).items():
        assert "volumes_from" not in dienst, f"{stapel}: {name} setzt volumes_from"
        assert "configs" not in dienst, f"{stapel}: {name} setzt configs"
        assert "extends" not in dienst, f"{stapel}: {name} setzt extends"
        for eintrag in _als_liste(dienst.get("volumes")):
            if isinstance(eintrag, dict):
                art, quelle = eintrag.get("type"), str(eintrag.get("source", ""))
                assert art == "volume", (
                    f"{stapel}: {name}: Eintrag vom Typ {art}: {eintrag}"
                )
            else:
                quelle = str(eintrag).split(":", 1)[0]
            assert quelle in benannt, (
                f"{stapel}: {name}: Einhaengung {eintrag!r} nennt keinen benannten Datentraeger"
            )


# (4) env_file


@pytest.mark.parametrize("stapel", STAPEL)
def test_r3_c_003_4_env_file_liegt_allein_im_eigenen_konfigurationsverzeichnis(
    stapel: str,
) -> None:
    eigenes = (DEPLOY / "konfiguration" / stapel).resolve()
    for name, dienst in _dienste(stapel).items():
        for eintrag in _als_liste(dienst.get("env_file")):
            pfad = eintrag.get("path") if isinstance(eintrag, dict) else eintrag
            aufgeloest = (DEPLOY / str(pfad)).resolve()
            assert _unter(aufgeloest, eigenes) and aufgeloest != eigenes, (
                f"{stapel}: {name}: env_file {pfad} liegt nicht unter {eigenes.relative_to(WURZEL)}"
            )


# (5) Geheimnisse


@pytest.mark.parametrize("stapel", STAPEL)
def test_r3_c_003_5_geheimnisse_nur_als_datei_mit_pflichtvariable(stapel: str) -> None:
    geheimnisse = _abschnitt(_lade(stapel), "secrets")
    assert geheimnisse, f"{stapel}: kein secrets-Abschnitt"
    for name, eintrag in geheimnisse.items():
        assert set(eintrag) == {"file"}, (
            f"{stapel}: Geheimnis {name} nicht allein als file: {eintrag}"
        )
        assert GEHEIMNISDATEI.match(str(eintrag["file"])), (
            f"{stapel}: Geheimnis {name}: file: {eintrag['file']} ist nicht ${{VAR:?}}/Datei"
        )


def test_r3_c_003_5_geheimnisvariablen_der_stapel_sind_verschieden() -> None:
    variablen: dict[str, set[str]] = {}
    for stapel in STAPEL:
        eintraege = _abschnitt(_lade(stapel), "secrets").values()
        variablen[stapel] = {
            m.group(1)
            for e in eintraege
            if (m := GEHEIMNISDATEI.match(str(e.get("file"))))
        }
        assert variablen[stapel], f"{stapel}: keine Geheimnisvariable gefunden"
    gemeinsam = variablen["test"] & variablen["produktion"]
    assert not gemeinsam, (
        f"gleiche Geheimnisvariable in beiden Stapeln: {sorted(gemeinsam)}"
    )


@pytest.mark.parametrize("stapel", STAPEL)
def test_r3_c_003_5_kein_geheimniswert_in_umgebung_und_konfiguration(
    stapel: str,
) -> None:
    for name, dienst in _dienste(stapel).items():
        angaben = _umgebung(dienst, "environment")
        angaben.update(_umgebung(dienst.get("build") or {}, "args"))
        for schluessel, wert in angaben.items():
            if GEHEIMNISSCHLUESSEL.search(schluessel):
                assert _ist_geheimnisverweis(schluessel, wert), (
                    f"{stapel}: {name}: {schluessel} traegt einen Wert statt einer Geheimnisdatei"
                )
    dateien = sorted((DEPLOY / "konfiguration" / stapel).glob("*.env"))
    assert dateien, f"{stapel}: keine Konfigurationsdatei"
    for datei in dateien:
        for zeile in datei.read_text(encoding="utf-8").splitlines():
            if not zeile.strip() or zeile.lstrip().startswith("#"):
                continue
            schluessel, _, wert = zeile.partition("=")
            if GEHEIMNISSCHLUESSEL.search(schluessel):
                assert not wert.strip() or _ist_geheimnisverweis(
                    schluessel.strip(), wert.strip()
                ), (
                    f"{datei.relative_to(WURZEL)}: {schluessel.strip()} traegt einen Wert"
                )


# (6) Ports, privileged, Protokolltreiber


@pytest.mark.parametrize("stapel", STAPEL)
def test_r3_c_003_6_keine_ports_kein_privileged_protokolltreiber_local(
    stapel: str,
) -> None:
    for name, dienst in _dienste(stapel).items():
        assert "ports" not in dienst, f"{stapel}: {name} veroeffentlicht Ports"
        assert not dienst.get("privileged"), f"{stapel}: {name} ist privileged"
        treiber = (dienst.get("logging") or {}).get("driver")
        assert treiber == "local", (
            f"{stapel}: {name}: logging driver {treiber!r}, verlangt local"
        )


# (7) Digests


@pytest.mark.parametrize("stapel", STAPEL)
def test_r3_c_003_7_jedes_image_der_compose_dateien_traegt_einen_digest(
    stapel: str,
) -> None:
    for name, dienst in _dienste(stapel).items():
        if "build" in dienst:
            assert "image" not in dienst or DIGEST.search(str(dienst["image"])), (
                f"{stapel}: {name}: image {dienst['image']} ohne Digest"
            )
        else:
            image = str(dienst.get("image", ""))
            assert DIGEST.search(image), (
                f"{stapel}: {name}: image {image!r} ohne @sha256:<64 Hex>"
            )


def test_r3_c_003_7_jedes_from_und_copy_from_der_dockerfiles_traegt_einen_digest() -> (
    None
):
    for dockerfile in _dockerfiles():
        alias = _alias_namen(dockerfile)
        ort = dockerfile.relative_to(WURZEL)
        for image, anweisungen in _stufen(dockerfile):
            assert image in alias or DIGEST.search(image), (
                f"{ort}: FROM {image} ohne Digest"
            )
            for wort, rest in anweisungen:
                if wort not in ("COPY", "RUN"):
                    continue
                optionen = _optionen_und_rest(rest)[0]
                quellen = [optionen["from"]] if "from" in optionen else []
                for mount in (
                    re.findall(r"--mount=(\S+)", rest) if wort == "RUN" else []
                ):
                    quellen += [
                        teil[5:]
                        for teil in mount.split(",")
                        if teil.startswith("from=")
                    ]
                for quelle in quellen:
                    assert quelle in alias or DIGEST.search(quelle), (
                        f"{ort}: {wort} from={quelle} ohne Digest"
                    )


# (8) Benutzer


def test_r3_c_003_8_letzte_stufe_jedes_dockerfiles_laeuft_nicht_als_root() -> None:
    for dockerfile in _dockerfiles():
        _, anweisungen = _stufen(dockerfile)[-1]
        benutzer = [rest for wort, rest in anweisungen if wort == "USER"]
        ort = dockerfile.relative_to(WURZEL)
        assert benutzer, f"{ort}: letzte Stufe ohne USER"
        assert "$" not in benutzer[-1], (
            f"{ort}: USER {benutzer[-1]!r} nennt eine Variable, Wert nicht festgestellt"
        )
        name = benutzer[-1].split(":", 1)[0].strip()
        assert name and name != "root" and not re.fullmatch(r"0+", name), (
            f"{ort}: letzte USER-Anweisung {benutzer[-1]!r} ist root"
        )


# (9) Kein prototype/ im Bau


def test_r3_c_003_9_baukontext_und_dockerfile_erreichen_prototype_nicht() -> None:
    prototyp = (WURZEL / "prototype").resolve()
    for stapel in STAPEL:
        for name, kontext, dockerfile in _baukontexte(stapel):
            wo = f"{stapel}: {name}"
            assert _unter(kontext, WURZEL), (
                f"{wo}: Baukontext {kontext} liegt ueber der Wurzel"
            )
            assert not _unter(kontext, prototyp), (
                f"{wo}: Baukontext liegt unter prototype/"
            )
            if _unter(prototyp, kontext):
                relativ = prototyp.relative_to(kontext).as_posix()
                assert _ignoriert(dockerfile, kontext, relativ), (
                    f"{wo}: Baukontext umfasst prototype/ ohne Ausschluss in der Ignorierdatei"
                )
            assert dockerfile.is_file(), f"{wo}: Dockerfile {dockerfile} fehlt"


@pytest.mark.parametrize("stapel", STAPEL)
def test_r3_c_003_9_kein_datentraeger_und_keine_konfiguration_unter_prototype(
    stapel: str,
) -> None:
    text = COMPOSE[stapel].read_text(encoding="utf-8")
    zeilen = [z for z in text.splitlines() if not z.lstrip().startswith("#")]
    treffer = [
        z for z in zeilen if re.search(r"(^|[/\s:'\"=])prototype(/|\s|$|['\"])", z)
    ]
    assert not treffer, (
        f"{stapel}: Verweis auf prototype/ in der Compose-Datei: {treffer}"
    )


def test_r3_c_003_9_kein_copy_oder_add_quellpfad_unter_prototype_oder_ausserhalb() -> (
    None
):
    for dockerfile in _dockerfiles():
        ort = dockerfile.relative_to(WURZEL)
        for _, anweisungen in _stufen(dockerfile):
            for wort, rest in anweisungen:
                if wort not in ("COPY", "ADD"):
                    continue
                optionen, teile = _optionen_und_rest(rest)
                if "from" in optionen:
                    continue
                for quelle in teile[:-1]:
                    pfad = quelle.lstrip("./")
                    assert "://" not in quelle, f"{ort}: {wort} mit URL {quelle}"
                    assert (
                        not quelle.startswith("/") and ".." not in Path(quelle).parts
                    ), f"{ort}: {wort} Quelle {quelle} verlaesst den Baukontext"
                    assert not pfad.startswith("prototype"), (
                        f"{ort}: {wort} Quelle {quelle}"
                    )


# (10) Makefile


def _makefile_zeilen() -> list[str]:
    """Zeilen des Makefiles mit verbundenen Fortsetzungen, ohne Kommentarzeilen."""
    zeilen: list[str] = []
    puffer = ""
    for zeile in MAKEFILE.read_text(encoding="utf-8").splitlines():
        fortgesetzt = zeile.endswith("\\")
        puffer += (zeile[:-1] if fortgesetzt else zeile) + (" " if fortgesetzt else "")
        if not fortgesetzt:
            if not puffer.lstrip().startswith("#"):
                zeilen.append(puffer.strip())
            puffer = ""
    return zeilen


def test_r3_c_003_10_makefile_nennt_compose_produktion_nicht() -> None:
    text = MAKEFILE.read_text(encoding="utf-8")
    assert "compose.produktion" not in text, "Makefile nennt compose.produktion.yml"
    assert "r3cosint-produktion" not in text and "R3COSINT_PRODUKTION" not in text


def test_r3_c_003_10_jedes_docker_compose_im_makefile_nennt_die_testdatei() -> None:
    gesehen = 0
    for zeile in _makefile_zeilen():
        assert not re.search(r"(?<![\w\"=-])docker-compose(?![\w\"-])", zeile), (
            f"Makefile: docker-compose: {zeile}"
        )
        if not re.search(r"docker\s+compose", zeile):
            continue
        gesehen += 1
        meldung = zeile.startswith("echo ") and not VERKETTUNG.search(
            UMLEITUNG.sub("", zeile)
        )
        aufrufe = re.findall(r"docker\s+compose\s+(\S+)", zeile)
        wache = bool(aufrufe) and all(a == "version" for a in aufrufe)
        if meldung or wache:
            continue
        assert NUR_TESTDATEI.search(zeile), (
            f"Makefile: docker compose ohne -f deploy/compose.test.yml: {zeile}"
        )
        assert len(re.findall(r"docker\s+compose", zeile)) == 1, (
            f"Makefile: mehrere Aufrufe in einer Zeile: {zeile}"
        )
    assert gesehen, "Makefile: kein docker compose gefunden (Rezept bau)"
