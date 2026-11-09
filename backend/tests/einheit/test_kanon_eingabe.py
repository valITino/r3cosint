"""Einheitstest: kanon.eingabe (ADR 0007, Festlegung S1.4; R3-F-003, R3-F-005). Alle Werte erfunden (5.15)."""

import traceback
from datetime import UTC, datetime
from typing import Any
from uuid import uuid4

import pytest
from pydantic import ValidationError

from r3cosint.kanon.eingabe import (
    Datenpunkt,
    Datenpunktart,
    Datensatz,
    Herkunft,
    Herkunftssatz,
    wert_angleichen,
    werte_angleichen,
)
from r3cosint.spur.service import Kennzeichnung

ZEIT = datetime(2026, 2, 1, 9, 15, 0, tzinfo=UTC)
SENTINEL = "SYNTH-SENTINEL-4711"


def _datensatz(eigenschaften: Any = None, **weitere: Any) -> dict[str, Any]:
    return {
        "id": "synth-1",
        "schema": "Person",
        "properties": {"name": ["TEST-SYNTH Person"]}
        if eigenschaften is None
        else eigenschaften,
        **weitere,
    }


def _herkunft(**aenderung: Any) -> dict[str, Any]:
    werte: dict[str, Any] = {
        "werkzeug": "synth.werkzeug",
        "abfrage": "SYNTH-Abfrage",
        "zeitpunkt": ZEIT,
        "erhebende_person": "synth.erhebung",
        "kennzeichnung": Kennzeichnung.QUELLENAUSSAGE,
    }
    werte.update(aenderung)
    return werte


def test_R3_F_003_angleichung_nfc_trimmen_gross_und_innerer_leerraum_bleiben() -> None:
    assert wert_angleichen("  é  ") == "é"
    assert wert_angleichen("A  b\tC") == "A  b\tC"
    assert wert_angleichen("​wert") == "​wert"  # Cf bleibt zulässig (GS-48)


@pytest.mark.parametrize(
    "wert",
    ["", "   ", "a\x00b", "a\x07b", "a\ud800b", "x" * 4097, " " + "x" * 4097 + " "],
)
def test_R3_F_003_angleichung_weist_ab_ohne_den_wert_zu_nennen(wert: str) -> None:
    with pytest.raises(ValueError) as fehler:
        wert_angleichen(wert)
    assert "x" * 10 not in str(fehler.value)


def test_R3_F_003_angleichung_grenze_4096_angenommen_und_steuerzeichen_tab_lf_cr_zulaessig() -> (
    None
):
    assert len(wert_angleichen("x" * 4096)) == 4096
    assert wert_angleichen("a\tb\nc\rd") == "a\tb\nc\rd"


def test_R3_F_003_doppel_entfallen_reihenfolge_der_ersten_nennung_bleibt() -> None:
    assert werte_angleichen(("b", "a", " b ", "a", "c")) == ("b", "a", "c")
    with pytest.raises(ValueError):
        werte_angleichen(())
    with pytest.raises(ValueError):
        werte_angleichen(tuple(str(n) for n in range(101)))


def test_R3_F_003_datensatz_gleicht_an_und_nimmt_listen_als_werte() -> None:
    satz = Datensatz.model_validate(_datensatz({"name": [" A ", "A", "B"]}))
    assert satz.eigenschaften == {"name": ("A", "B")}
    assert satz.ftm_kennung == "synth-1"
    assert satz.ftm_schema == "Person"


@pytest.mark.parametrize(
    "schaden",
    [
        {"id": ""},
        {"id": "-ungueltig"},
        {"id": "x" * 129},
        {"schema": "person"},
        {"properties": {"Name": ["a"]}},
        {"properties": {"name": []}},
        {"properties": {"name": [""]}},
        {"properties": {"name": [1]}},
        {"properties": {"name": "text"}},
        {"fremd": 1},
    ],
)
def test_R3_F_003_datensatz_ausser_form_wird_abgewiesen(
    schaden: dict[str, Any],
) -> None:
    daten = _datensatz()
    daten.update(schaden)
    with pytest.raises(ValidationError):
        Datensatz.model_validate(daten)


def test_R3_F_003_datensatz_nur_ueber_aliasse() -> None:
    with pytest.raises(ValidationError):
        Datensatz.model_validate(
            {"ftm_kennung": "a", "ftm_schema": "Person", "eigenschaften": {}}
        )


def test_R3_F_003_begrenzungen_je_grenze_angenommen_und_darueber_abgewiesen() -> None:
    # Eigenschaften: 128 angenommen, 129 nicht (Namen aus Buchstaben).
    namen = [f"e{chr(97 + n // 26)}{chr(97 + n % 26)}" for n in range(129)]
    Datensatz.model_validate(_datensatz({n: ["a"] for n in namen[:128]}))
    with pytest.raises(ValidationError):
        Datensatz.model_validate(_datensatz({n: ["a"] for n in namen}))
    # Werte je Eigenschaft: 100 angenommen, 101 nicht.
    Datensatz.model_validate(_datensatz({"name": [str(n) for n in range(100)]}))
    with pytest.raises(ValidationError):
        Datensatz.model_validate(_datensatz({"name": [str(n) for n in range(101)]}))
    # Werte gesamt: 1000 angenommen, 1001 nicht.
    zehn = {f"e{chr(97 + n)}": [f"{n}-{m}" for m in range(100)] for n in range(10)}
    Datensatz.model_validate(_datensatz(zehn))
    with pytest.raises(ValidationError):
        Datensatz.model_validate(_datensatz({**zehn, "ek": ["einer"]}))
    # Gesamtlänge: 64 Werte zu 4096 Zeichen angenommen, ein Zeichen mehr nicht.
    voll = [f"{n:04d}".ljust(4096, "x") for n in range(64)]
    Datensatz.model_validate(_datensatz({"name": voll[:50], "alias": voll[50:]}))
    with pytest.raises(ValidationError):
        Datensatz.model_validate(
            _datensatz({"name": voll[:50], "alias": voll[50:], "notes": ["y"]})
        )


def test_R3_F_003_laengenpruefung_laeuft_vor_der_pruefung_der_elemente() -> None:
    # Messung SD-S14-04: Pydantic prüft die Elemente vor max_length; der Vorprüfer begrenzt zuerst.
    with pytest.raises(ValidationError) as fehler:
        Datensatz.model_validate(_datensatz({"name": [1] * 101}))
    assert [e["loc"] for e in fehler.value.errors(include_input=False)] == [
        ("properties",)
    ]
    with pytest.raises(ValidationError) as fehler:
        Datensatz.model_validate(_datensatz({str(n): ["a"] for n in range(129)}))
    assert [e["loc"] for e in fehler.value.errors(include_input=False)] == [
        ("properties",)
    ]


def test_R3_F_003_repr_und_str_nennen_weder_kennung_noch_werte() -> None:
    satz = Datensatz.model_validate(_datensatz({"name": [SENTINEL]}, id="synth-geheim"))
    assert SENTINEL not in repr(satz) + str(satz)
    assert "synth-geheim" not in repr(satz) + str(satz)
    punkt = Datenpunkt(
        kennung=uuid4(),
        art=Datenpunktart.KNOTEN,
        fall_kennung=uuid4(),
        ftm_schema="Person",
        herkunft_kennung=uuid4(),
        erstellt_am=ZEIT,
        quelle_kennung=None,
        ziel_kennung=None,
        ftm_kennung="synth-geheim",
        eigenschaften={"name": (SENTINEL,)},
    )
    assert SENTINEL not in repr(punkt)
    assert "synth-geheim" not in repr(punkt)


def test_R3_F_003_validierungsfehler_nennt_den_wert_nicht() -> None:
    with pytest.raises(ValidationError) as fehler:
        Datensatz.model_validate(_datensatz({"name": [f"{SENTINEL}\x00"]}))
    text = str(fehler.value) + "".join(traceback.format_exception(fehler.value))
    assert SENTINEL not in text


def test_R3_F_005_herkunft_nimmt_vollstaendige_angaben_an() -> None:
    h = Herkunft.model_validate(_herkunft())
    assert h.abfrage == "SYNTH-Abfrage"  # unverändert gespeichert
    assert "SYNTH-Abfrage" not in repr(h)


@pytest.mark.parametrize(
    "feld", ["werkzeug", "abfrage", "zeitpunkt", "erhebende_person", "kennzeichnung"]
)
def test_R3_F_005_herkunft_je_angabe_fehlend_wird_abgewiesen(feld: str) -> None:
    daten = _herkunft()
    del daten[feld]
    with pytest.raises(ValidationError):
        Herkunft.model_validate(daten)


@pytest.mark.parametrize(
    "aenderung",
    [
        {"werkzeug": ""},
        {"werkzeug": "Synth Werkzeug"},
        {"werkzeug": "w" * 65},
        {"abfrage": ""},
        {"abfrage": " \t\n "},
        {"abfrage": "a\x00b"},
        {"abfrage": "a\ud800b"},
        {"abfrage": "a" * 4097},
        {"zeitpunkt": datetime(2026, 2, 1)},  # noqa: DTZ001 - naive Zeit ist der Prüfgegenstand
        {"zeitpunkt": datetime(1999, 12, 31, tzinfo=UTC)},
        {"erhebende_person": ""},
        {"erhebende_person": "Synth Person"},
        {"kennzeichnung": "quellenaussage"},
        {"kennzeichnung": None},
        {"fremd": 1},
    ],
)
def test_R3_F_005_herkunft_ausser_form_wird_abgewiesen_ohne_abfrage_im_text(
    aenderung: dict[str, Any],
) -> None:
    daten = _herkunft(abfrage=SENTINEL)
    daten.update(aenderung)
    with pytest.raises(ValidationError) as fehler:
        Herkunft.model_validate(daten)
    text = str(fehler.value) + "".join(traceback.format_exception(fehler.value))
    assert SENTINEL not in text


def test_R3_F_005_herkunft_abfrage_grenze_4096_angenommen_und_unveraendert() -> None:
    abfrage = "A  " + "b" * 4093
    assert len(abfrage) == 4096
    assert Herkunft.model_validate(_herkunft(abfrage=abfrage)).abfrage == abfrage


def test_R3_F_005_herkunftssatz_nennt_die_abfrage_nicht_in_repr() -> None:
    uuid = uuid4()
    satz = Herkunftssatz(
        kennung=uuid,
        fall_kennung=uuid,
        werkzeug="synth.werkzeug",
        zeitpunkt=ZEIT,
        erhebende_person="synth.erhebung",
        kennzeichnung=Kennzeichnung.QUELLENAUSSAGE,
        erstellt_am=ZEIT,
        abfrage=SENTINEL,
    )
    assert SENTINEL not in repr(satz)


def test_R3_F_003_properties_ausser_abbildung_wird_abgewiesen() -> None:
    with pytest.raises(ValidationError):
        Datensatz.model_validate(_datensatz([]))


@pytest.mark.parametrize(
    "aenderung",
    [
        {"abfrage": SENTINEL + "\x00"},
        {"abfrage": SENTINEL + "\ud800"},
        {"abfrage": SENTINEL + "a" * 4097},
        {"werkzeug": SENTINEL},
        {"erhebende_person": SENTINEL},
        {"kennzeichnung": SENTINEL},
        {"zeitpunkt": SENTINEL},
    ],
)
def test_R3_F_005_herkunft_nennt_den_fehlerhaften_wert_selbst_nicht_in_str_und_repr(
    aenderung: dict[str, Any],
) -> None:
    daten = _herkunft()
    daten.update(aenderung)
    with pytest.raises(ValidationError) as fehler:
        Herkunft.model_validate(daten)
    text = (
        str(fehler.value)
        + repr(fehler.value)
        + "".join(traceback.format_exception(fehler.value))
    )
    assert SENTINEL not in text


@pytest.mark.parametrize(
    "daten",
    [
        _datensatz({"name": [SENTINEL + "\x00"]}),
        _datensatz(id=SENTINEL + " ungültig"),
        _datensatz(schema=SENTINEL),
    ],
)
def test_R3_F_003_datensatz_nennt_den_fehlerhaften_wert_selbst_nicht_in_str_und_repr(
    daten: dict[str, Any],
) -> None:
    with pytest.raises(ValidationError) as fehler:
        Datensatz.model_validate(daten)
    assert SENTINEL not in str(fehler.value) + repr(fehler.value)


def test_R3_F_003_gesamtgroesse_in_bytes_vier_byte_zeichen_an_der_grenze() -> None:
    def werte(anzahl: int) -> list[str]:
        return [chr(0x1F600 + n) + "\U0001f600" * 4095 for n in range(anzahl)]

    # 63 Werte zu 4096 Zeichen aus vier Bytes: unter 1 MiB, angenommen.
    Datensatz.model_validate(_datensatz({"name": werte(50), "alias": werte(63)[50:]}))
    # 64 Werte: genau 262 144 Zeichen (Zeichengrenze erfüllt), aber mehr als 1 MiB mit der JSON-Syntax.
    with pytest.raises(ValidationError) as fehler:
        Datensatz.model_validate(
            _datensatz({"name": werte(50), "alias": werte(64)[50:]})
        )
    assert [e["loc"] for e in fehler.value.errors(include_input=False)] == [()]
