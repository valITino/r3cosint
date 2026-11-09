"""Einheitstest: Prüfvektor der Nutzlast entitaet und beziehung mit Herkunftsfeldern (ADR 0007, Festlegung S1.4; R3-F-005, R3-F-011).

Die Erwartungswerte (Nutzlasttexte und Prüfsummen V1 bis V3, G1 bis G3, Bindungen) hat der
Digital-Forensics-Spezialist ausserhalb von Python gerechnet (printf, openssl, sha256sum; Fall
00000000-0000-4000-8000-000000000001, Schlüssel 00 01 ... 1f, Fremdbeleg DF-S14-04, Bedingung 2)
und stehen hier als feste Konstanten, unabhängig von der Umsetzung. Alle Werte sind erfunden (5.15).
"""

import hashlib
from datetime import UTC, datetime
from uuid import UUID

import pytest

from r3cosint.spur.kette import Eintrag, Eintragstyp, Kennzeichnung, Spur, pruefsumme
from r3cosint.spur.payload import (
    Beziehung,
    Entitaet,
    Pseudonymisierer,
    nutzlast_bilden,
)

SCHLUESSEL = bytes(range(32))
FALL = UUID("00000000-0000-4000-8000-000000000001")
ANFANGSWERT = "b34cdc3ccddc2481b761073ed173b7f4c0e1cd311484c66d57c8614cdce7181a"
BINDUNG_ABFRAGE_1 = "aaf59a3586c2a5618c2ddfd4f8486bd5a068484abdef4c138a15a4662b69c5e1"
BINDUNG_ABFRAGE_2 = "8c1cd9d74271d6188410f040f27993c5dedd6ee0aa1a6c96fea285be76e14886"
BINDUNG_NORMALFORM_1 = (
    "aefe9abd0f2192673c27e4b676fc4a7706723c982fade9bf01da46a2d35ebd9c"
)

NUTZLAST_V1 = '{"abfrage_bindung":"aaf59a3586c2a5618c2ddfd4f8486bd5a068484abdef4c138a15a4662b69c5e1","abfrage_pseudonym":"56cdbff7d27297c96da27d04ecb96edda9924f6f0a516518be200ab2855be6ac","eigenschaften":{"name":["5b97782379a086cf4a491007fbe1b22b87bf87aa9b91dd95351861dd4092d208"]},"entitaet_kennung":"00000000-0000-4000-8000-000000000002","erhebende_person":"test.erhebung","erhoben_am":"2026-11-09T10:00:00.000000Z","fall_kennung":"00000000-0000-4000-8000-000000000001","ftm_kennung_pseudonym":"91072798398f8d64bda394d52dc38e52fe6ff650c10a547b5a3fee6def489f2b","ftm_schema":"Person","herkunft_kennung":"00000000-0000-4000-8000-000000000003","werkzeug":"test.werkzeug"}'
NUTZLAST_V2 = '{"abfrage_bindung":"8c1cd9d74271d6188410f040f27993c5dedd6ee0aa1a6c96fea285be76e14886","abfrage_pseudonym":"72b286915610fa7d9d8793652a1db73d9d9dd446b3f074914bfac0035d93df44","eigenschaften":{"name":["efefc0acd703f83bf304f0fef463264ffaa036d482d8a3c56f912dd0be362cf8"]},"entitaet_kennung":"00000000-0000-4000-8000-000000000004","erhebende_person":"test.erhebung","erhoben_am":"2026-11-09T10:01:00.000000Z","fall_kennung":"00000000-0000-4000-8000-000000000001","ftm_kennung_pseudonym":"3a9b8e3c6c7da1f56c2515178077b300640c2f3b330b897447388a2e3ab0b8dc","ftm_schema":"Person","herkunft_kennung":"00000000-0000-4000-8000-000000000005","werkzeug":"test.werkzeug"}'
NUTZLAST_V3 = '{"abfrage_bindung":"aaf59a3586c2a5618c2ddfd4f8486bd5a068484abdef4c138a15a4662b69c5e1","abfrage_pseudonym":"56cdbff7d27297c96da27d04ecb96edda9924f6f0a516518be200ab2855be6ac","beziehung_kennung":"00000000-0000-4000-8000-000000000006","eigenschaften":{"person":["91072798398f8d64bda394d52dc38e52fe6ff650c10a547b5a3fee6def489f2b"],"relative":["3a9b8e3c6c7da1f56c2515178077b300640c2f3b330b897447388a2e3ab0b8dc"]},"erhebende_person":"test.erhebung","erhoben_am":"2026-11-09T10:02:00.000000Z","fall_kennung":"00000000-0000-4000-8000-000000000001","ftm_kennung_pseudonym":"cbfa46d904718aeda707e0da8789f8d47fd21d7e4c72cca48294b28806a0a7c4","ftm_schema":"Family","herkunft_kennung":"00000000-0000-4000-8000-000000000007","quelle_kennung":"00000000-0000-4000-8000-000000000002","werkzeug":"test.werkzeug","ziel_kennung":"00000000-0000-4000-8000-000000000004"}'
NUTZLAST_SHA256 = {
    "V1": "84733a5ef287062d9262f1e8235c8c5f4221eeb5ee81ecca46220ff2759641cd",
    "V2": "d32ac30c0822fd769a19a4d185ac79c7ef16798307d047aac7ccd950b3c91f0c",
    "V3": "af32d95d55829ea70070e1b15e751c29245ba19603637edcde60e169d97896c3",
    "G3": "73f2e84797bc95f4d550ee323a79c18f7d836ed68b96eb210939b5d8e52af64a",
}
PRUEFSUMME = {
    "V1": "d796f38e07a5e8f3e4524bd0b892a253ae89d0cabb36d4fc8bc6ba5477c17d81",
    "V2": "c2e52f14cf0f8bbd5b69f05be36be005c262fcc723e6cbabf4fe61ffeec9db91",
    "V3": "09a0c322d610a24b6df1693666b3123be121b800e2d1eb7af91aeccafd291edf",
    "G1": "e806e533afd3f3006a1b3a8c626223c77634f4785c34d587104fa6463148b081",
    "G2": "f2c62906e0d96dcd144533f1fb1b9f1703c6d711fbca49b79f9fd16ffcbe1dcc",
    "G3": "e4a7831fe458271428d053222d60e4fe55218a76c05d3664e4fffd349eb461ec",
}


def _kennung(nr: int) -> UUID:
    return UUID(f"00000000-0000-4000-8000-{nr:012d}")


def _zeit(minute: int) -> datetime:
    return datetime(2026, 11, 9, 10, minute, 0, tzinfo=UTC)


def _v1(**aenderung: object) -> Entitaet:
    werte: dict[str, object] = dict(
        fall_kennung=FALL,
        entitaet_kennung=_kennung(2),
        ftm_kennung="TEST-SYNTH-P1",
        ftm_schema="Person",
        herkunft_kennung=_kennung(3),
        eigenschaften={"name": ("TEST-SYNTH Erika Muster",)},
        werkzeug="test.werkzeug",
        erhoben_am=_zeit(0),
        erhebende_person="test.erhebung",
        abfrage="TEST-SYNTH Abfrage 1",
    )
    werte.update(aenderung)
    return Entitaet(**werte)  # type: ignore[arg-type]


def _v2() -> Entitaet:
    return Entitaet(
        fall_kennung=FALL,
        entitaet_kennung=_kennung(4),
        ftm_kennung="TEST-SYNTH-P2",
        ftm_schema="Person",
        herkunft_kennung=_kennung(5),
        eigenschaften={"name": ("TEST-SYNTH Max Muster",)},
        werkzeug="test.werkzeug",
        erhoben_am=_zeit(1),
        erhebende_person="test.erhebung",
        abfrage="TEST-SYNTH Abfrage 2",
    )


def _v3() -> Beziehung:
    return Beziehung(
        fall_kennung=FALL,
        beziehung_kennung=_kennung(6),
        ftm_kennung="TEST-SYNTH-F1",
        ftm_schema="Family",
        herkunft_kennung=_kennung(7),
        quelle_kennung=_kennung(2),
        ziel_kennung=_kennung(4),
        eigenschaften={
            "person": ("TEST-SYNTH-P1",),
            "relative": ("TEST-SYNTH-P2",),
        },
        werkzeug="test.werkzeug",
        erhoben_am=_zeit(2),
        erhebende_person="test.erhebung",
        abfrage="TEST-SYNTH Abfrage 1",
    )


def _eintrag(
    nr: int,
    minute: int,
    typ: Eintragstyp,
    kennzeichnung: Kennzeichnung,
    nutzlast: str,
    vorgaenger: str,
) -> Eintrag:
    return Eintrag(
        spur=Spur.ERMITTLUNGSSPUR,
        kennung=_kennung(9 + nr),
        fall_kennung=FALL,
        position=nr,
        zeitpunkt=_zeit(4 + nr),
        person_kennung="test.ermittlung",
        eintragstyp=typ,
        kennzeichnung=kennzeichnung,
        payload=nutzlast,
        vorgaenger_pruefsumme=vorgaenger,
        pruefsumme="0" * 64,
    )


def test_R3_F_005_bindung_vektor_mit_festem_schluessel() -> None:
    p = Pseudonymisierer(SCHLUESSEL)
    assert p.bindung("TEST-SYNTH Abfrage 1") == BINDUNG_ABFRAGE_1
    assert p.bindung("TEST-SYNTH Abfrage 2") == BINDUNG_ABFRAGE_2
    assert p.bindung("test-synth abfrage 1") == BINDUNG_NORMALFORM_1


def test_R3_F_005_bindung_unterscheidet_schreibweise_und_leerraum_das_pseudonym_nicht() -> (
    None
):
    p = Pseudonymisierer(SCHLUESSEL)
    exakt = "TEST-SYNTH  Abfrage 1"
    normal = "test-synth abfrage 1"
    assert p.bindung(exakt) != p.bindung(normal)
    assert p.pseudonym(exakt) == p.pseudonym(normal)


def test_R3_F_005_bindung_leerer_wert_ohne_wert_im_text() -> None:
    with pytest.raises(ValueError) as fehler:
        Pseudonymisierer(SCHLUESSEL).bindung("")
    assert "TEST" not in str(fehler.value)


def test_R3_F_005_nutzlast_und_pruefsumme_vektor_v1_bis_v3() -> None:
    p = Pseudonymisierer(SCHLUESSEL)
    texte = {
        "V1": nutzlast_bilden(_v1(), p),
        "V2": nutzlast_bilden(_v2(), p),
        "V3": nutzlast_bilden(_v3(), p),
    }
    assert texte == {"V1": NUTZLAST_V1, "V2": NUTZLAST_V2, "V3": NUTZLAST_V3}
    for name, text in texte.items():
        assert hashlib.sha256(text.encode()).hexdigest() == NUTZLAST_SHA256[name]
    e1 = _eintrag(
        1,
        0,
        Eintragstyp.ENTITAET,
        Kennzeichnung.QUELLENAUSSAGE,
        NUTZLAST_V1,
        ANFANGSWERT,
    )
    assert pruefsumme(e1) == PRUEFSUMME["V1"]
    e2 = _eintrag(
        2,
        0,
        Eintragstyp.ENTITAET,
        Kennzeichnung.SCHLUSSFOLGERUNG,
        NUTZLAST_V2,
        PRUEFSUMME["V1"],
    )
    assert pruefsumme(e2) == PRUEFSUMME["V2"]
    e3 = _eintrag(
        3,
        0,
        Eintragstyp.BEZIEHUNG,
        Kennzeichnung.QUELLENAUSSAGE,
        NUTZLAST_V3,
        PRUEFSUMME["V2"],
    )
    assert pruefsumme(e3) == PRUEFSUMME["V3"]


def test_R3_F_005_gegenproben_g1_und_g2_ungleich_v1() -> None:
    p = Pseudonymisierer(SCHLUESSEL)
    # G1: anderes Werkzeug; G2: andere Kennzeichnung.
    g1_text = nutzlast_bilden(_v1(werkzeug="test.werkzeugx"), p)
    g1 = _eintrag(
        1, 0, Eintragstyp.ENTITAET, Kennzeichnung.QUELLENAUSSAGE, g1_text, ANFANGSWERT
    )
    assert pruefsumme(g1) == PRUEFSUMME["G1"] != PRUEFSUMME["V1"]
    g2 = _eintrag(
        1,
        0,
        Eintragstyp.ENTITAET,
        Kennzeichnung.SCHLUSSFOLGERUNG,
        NUTZLAST_V1,
        ANFANGSWERT,
    )
    assert pruefsumme(g2) == PRUEFSUMME["G2"] != PRUEFSUMME["V1"]


def test_R3_F_005_g3_bindung_ueber_die_normalform_statt_der_exakten_bytes_ungleich_v1() -> (
    None
):
    g3_text = NUTZLAST_V1.replace(BINDUNG_ABFRAGE_1, BINDUNG_NORMALFORM_1)
    assert g3_text != NUTZLAST_V1
    assert hashlib.sha256(g3_text.encode()).hexdigest() == NUTZLAST_SHA256["G3"]
    g3 = _eintrag(
        1, 0, Eintragstyp.ENTITAET, Kennzeichnung.QUELLENAUSSAGE, g3_text, ANFANGSWERT
    )
    assert pruefsumme(g3) == PRUEFSUMME["G3"] != PRUEFSUMME["V1"]


def test_R3_F_005_kein_klartext_im_text_der_nutzlast_mit_herkunftsfeldern() -> None:
    p = Pseudonymisierer(SCHLUESSEL)
    for eingabe in (_v1(), _v2(), _v3()):
        text = nutzlast_bilden(eingabe, p)
        for klartext in ("TEST-SYNTH", "Abfrage", "Erika", "Muster"):
            assert klartext not in text


def test_R3_F_005_eingaben_nennen_in_repr_und_fehlern_die_abfrage_nicht() -> None:
    assert "Abfrage" not in repr(_v1())
    assert "Abfrage" not in repr(_v3())
    with pytest.raises(Exception) as fehler:
        _v1(werkzeug="Ungueltig TEST-SYNTH Abfrage")
    assert "Abfrage" not in str(fehler.value)
