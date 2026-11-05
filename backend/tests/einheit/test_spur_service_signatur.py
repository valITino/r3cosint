"""Einheitstest: Signatur von spur.service.anfuegen (ADR 0007, E-S1-08; R3-F-008)."""

import inspect

from r3cosint.spur import service


def test_R3_F_008_anfuegen_nimmt_alles_nach_der_verbindung_nur_als_schluesselwort() -> (
    None
):
    parameter = list(inspect.signature(service.anfuegen).parameters.values())
    assert parameter[0].name == "verbindung"
    assert parameter[0].kind is inspect.Parameter.POSITIONAL_OR_KEYWORD
    assert all(p.kind is inspect.Parameter.KEYWORD_ONLY for p in parameter[1:])
    assert [p.name for p in parameter[1:]] == [
        "spur",
        "fall_kennung",
        "person_kennung",
        "kennzeichnung",
        "eingabe",
        "pseudonymisierer",
        "uhr",
    ]


def test_R3_F_008_kennzeichnung_hat_keinen_vorgabewert() -> None:
    parameter = inspect.signature(service.anfuegen).parameters["kennzeichnung"]
    assert parameter.default is inspect.Parameter.empty
    assert not any(
        p.default is not inspect.Parameter.empty
        for p in inspect.signature(service.anfuegen).parameters.values()
    )


def test_R3_F_008_die_oeffentliche_schnittstelle_nennt_die_vorgesehenen_namen() -> None:
    assert set(service.__all__) >= {
        "Spur",
        "Eintragstyp",
        "Kennzeichnung",
        "Bruchgrund",
        "Eintrag",
        "Kettenkopf",
        "Befund",
        "Pseudonymisierer",
        "FallEroeffnet",
        "FallGeschlossen",
        "Entitaet",
        "Beziehung",
        "ketten_anlegen",
        "anfuegen",
        "kette_pruefen",
        "kette_pruefen_datenbank",
        "alle_ketten_pruefen",
    }
    for name in service.__all__:
        assert hasattr(service, name)
