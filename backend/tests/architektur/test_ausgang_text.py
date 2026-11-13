"""Texttests zu ausgang (ADR 0008, Festlegung S2.1, Zeile Tests Architektur; R3-F-015, R3-F-028).

Gelesen werden die Quelltexte als Text, ohne sie auszuführen.
"""

import re
from pathlib import Path

BACKEND = Path(__file__).resolve().parents[2]
WURZEL = BACKEND.parent
AUSGANG = BACKEND / "src" / "r3cosint" / "ausgang"
TESTKONSTANTE = re.compile(r"2001:0*20:(?::|0*:)*0*:?0*1(?![0-9a-f:])", re.IGNORECASE)


def _quelltexte(ordner: Path) -> dict[str, str]:
    return {
        str(pfad.relative_to(WURZEL)): pfad.read_text(encoding="utf-8")
        for pfad in sorted(ordner.rglob("*.py"))
    }


def _alle_texte(ordner: Path) -> dict[str, str]:
    texte: dict[str, str] = {}
    for pfad in sorted(ordner.rglob("*")):
        if (
            pfad.is_file()
            and ".venv" not in pfad.parts
            and "__pycache__" not in pfad.parts
        ):
            try:
                texte[str(pfad.relative_to(WURZEL))] = pfad.read_text(encoding="utf-8")
            except UnicodeDecodeError:
                continue
    return texte


def test_R3_F_028_ausgang_hat_quelltexte() -> None:
    assert {Path(p).name for p in _quelltexte(AUSGANG)} >= {
        "positivliste.py",
        "ziel.py",
        "aufloesung.py",
    }


def test_R3_F_028_inet_aton_und_der_codec_idna_kommen_in_ausgang_nicht_vor() -> None:
    codec = re.compile(r"""["']idna["']""")
    fundorte = [
        pfad
        for pfad, text in _quelltexte(AUSGANG).items()
        if "inet_aton" in text or codec.search(text)
    ]
    assert fundorte == []


def test_R3_F_015_importlib_und_dunder_import_kommen_in_ausgang_nicht_vor() -> None:
    fundorte = [
        pfad
        for pfad, text in _quelltexte(AUSGANG).items()
        if "importlib" in text or "__import__" in text
    ]
    assert fundorte == []


def test_R3_F_028_die_testkonstante_kommt_unter_src_und_deploy_nicht_vor() -> None:
    """DS-S21-12: 2001:20::1 steht allein im Testbaum, nie in Quelltext oder Konfiguration."""
    fundorte = [
        pfad
        for ordner in (BACKEND / "src", WURZEL / "deploy")
        for pfad, text in _alle_texte(ordner).items()
        if TESTKONSTANTE.search(text)
    ]
    assert fundorte == []


def test_R3_F_028_der_suchausdruck_der_testkonstante_ist_trennscharf() -> None:
    for treffer in (
        "2001:20::1",
        "2001:0020::1",
        "2001:20:0:0:0:0:0:1",
        "x 2001:20::1 y",
    ):
        assert TESTKONSTANTE.search(treffer), treffer
    for kein in ("2001:20::10", "2001:200::1", "2001:2::1", "2001:20::2"):
        assert TESTKONSTANTE.search(kein) is None, kein
