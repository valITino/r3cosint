"""Texttests zu ausgang.client (ADR 0008, Festlegung S2.1, Zeile Tests Architektur; R3-F-028, SD-S21-07).

Gelesen werden die Quelltexte als Text, ohne sie auszuführen.
"""

import ast
import re
from pathlib import Path

SRC = Path(__file__).resolve().parents[2] / "src"
CLIENT = SRC / "r3cosint" / "ausgang" / "client.py"


def _quelltexte() -> dict[Path, str]:
    return {p: p.read_text(encoding="utf-8") for p in sorted(SRC.rglob("*.py"))}


def _funktion_zeilen(name: str) -> range:
    baum = ast.parse(CLIENT.read_text(encoding="utf-8"))
    for knoten in ast.walk(baum):
        if isinstance(knoten, ast.FunctionDef) and knoten.name == name:
            return range(knoten.lineno, (knoten.end_lineno or knoten.lineno) + 1)
    raise AssertionError(f"{name} fehlt")


def test_R3_F_028_follow_redirects_und_trust_env_allein_in_bibliotheksclient_bauen() -> (
    None
):
    zeilen = CLIENT.read_text(encoding="utf-8").splitlines()
    erlaubt = _funktion_zeilen("bibliotheksclient_bauen")
    for name in ("follow_redirects", "trust_env"):
        funde = [
            nummer
            for nummer, zeile in enumerate(zeilen, start=1)
            if re.search(rf"\b{name}\b", zeile)
            and not zeile.lstrip().startswith(("#", '"'))
        ]
        # Vorkommen in Docstrings und Kommentaren zählen nicht; Zuweisungen und Aufrufargumente schon
        zuweisungen = [n for n in funde if re.search(rf"\b{name}\s*=", zeilen[n - 1])]
        assert zuweisungen, name
        assert all(n in erlaubt for n in zuweisungen), (name, zuweisungen)
        for n in zuweisungen:
            assert re.search(rf"\b{name}\s*=\s*False\b", zeilen[n - 1]), (name, n)
    for pfad, text in _quelltexte().items():
        if pfad != CLIENT and "ausgang" in pfad.parts:
            assert "follow_redirects" not in text and "trust_env" not in text, pfad


def test_R3_F_015_der_name_vertrauensanker_steht_allein_in_ausgang_client() -> None:
    fundorte = [
        p
        for p, text in _quelltexte().items()
        if "vertrauensanker" in text and p != CLIENT
    ]
    assert fundorte == []
    assert "vertrauensanker" in CLIENT.read_text(encoding="utf-8")


def test_R3_F_015_nur_ausgang_importiert_httpx_und_httpcore() -> None:
    for pfad, text in _quelltexte().items():
        if "ausgang" in pfad.parts:
            continue
        assert not re.search(r"^\s*(import|from)\s+(httpx|httpcore)\b", text, re.M), (
            pfad
        )


def test_R3_F_028_der_client_liest_den_koerper_allein_ueber_den_rohstrom() -> None:
    text = CLIENT.read_text(encoding="utf-8")
    assert "aiter_raw" in text
    for verboten in ("aiter_bytes", ".aread(", ".text", "aiter_text", ".json("):
        assert verboten not in text, verboten
