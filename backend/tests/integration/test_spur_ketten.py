"""Integrationstest: Ketten über beide Rechenwege, Manipulationskatalog, gleichzeitiges Anfügen,
Dienstfunktionen und die Hilfe manipulieren (ADR 0007, Nr. 13 bis 20, Festlegung S1.2;
R3-F-008, R3-F-012).
"""

import asyncio
from collections.abc import Awaitable, Callable
from dataclasses import replace
from datetime import UTC, datetime
from typing import TYPE_CHECKING, Any
from uuid import UUID

import pytest
from sqlalchemy import text
from sqlalchemy.exc import DBAPIError
from sqlalchemy.ext.asyncio import AsyncConnection

from r3cosint.core.datenbank import engine_erzeugen
from r3cosint.core.fehler import EingabeFehler
from r3cosint.spur.kette import (
    Befund,
    Bruchgrund,
    Eintrag,
    Spur,
    anfangswert,
    pruefsumme,
)
from r3cosint.spur.payload import FallEroeffnet, FallGeschlossen, Pseudonymisierer
from r3cosint.spur.service import (
    Kennzeichnung,
    alle_ketten_pruefen,
    anfuegen,
    kette_pruefen,
    kette_pruefen_datenbank,
)

if TYPE_CHECKING:
    from conftest import SynthetischerFall, Testdatenbank

pytestmark = pytest.mark.anyio

SPUREN = [Spur.ARBEITSSPUR, Spur.ERMITTLUNGSSPUR]
Schreiben = Callable[["SynthetischerFall", Spur, int], Awaitable[list[Eintrag]]]
Manipulieren = Callable[..., Awaitable[str]]
NEUE_ZEIT = datetime(2026, 2, 1, 12, 0, 0, 5, tzinfo=UTC)


async def _beide_wege(
    verbindung: AsyncConnection, fall: UUID
) -> tuple[dict[Spur, Befund], dict[Spur, Befund]]:
    async with verbindung.begin():
        anwendung = await kette_pruefen(verbindung, fall)
        datenbank = await kette_pruefen_datenbank(verbindung, fall)
    return anwendung, datenbank


async def _gleich(
    verbindung: AsyncConnection, fall: UUID, spur: Spur, **erwartet: Any
) -> Befund:
    anwendung, datenbank = await _beide_wege(verbindung, fall)
    assert anwendung[spur] == datenbank[spur]
    befund = anwendung[spur]
    for name, wert in erwartet.items():
        assert getattr(befund, name) == wert, name
    return befund


def _setzen(spur: Spur, e: Eintrag, **aenderung: Any) -> tuple[str, Eintrag]:
    neu = replace(e, **aenderung)
    neu = replace(neu, pruefsumme=pruefsumme(neu))
    sql = (
        f"UPDATE r3cosint.{spur.value} SET payload = '{neu.payload}', "
        f"vorgaenger_pruefsumme = '{neu.vorgaenger_pruefsumme}', "
        f"pruefsumme = '{neu.pruefsumme}' WHERE kennung = CAST('{e.kennung}' AS uuid)"
    )
    return sql, neu


def _loeschen(spur: Spur, *eintraege: Eintrag) -> str:
    return "; ".join(
        f"DELETE FROM r3cosint.{spur.value} WHERE kennung = CAST('{e.kennung}' AS uuid)"
        for e in eintraege
    )


def _kopf_setzen(spur: Spur, fall: UUID, position: int, summe: str) -> str:
    return (
        f"UPDATE r3cosint.kettenkopf SET position = {position}, pruefsumme = '{summe}' "
        f"WHERE fall_kennung = CAST('{fall}' AS uuid) AND spur = '{spur.value}'"
    )


@pytest.mark.parametrize("spur", SPUREN)
async def test_R3_F_012_beide_rechenwege_gleich_an_unversehrtem_und_leerem_bestand(
    fall_mit_ketten: "SynthetischerFall",
    eintraege_schreiben: Schreiben,
    verbindung_anwendung: AsyncConnection,
    spur: Spur,
) -> None:
    fall = fall_mit_ketten.kennung
    leer = await _gleich(
        verbindung_anwendung, fall, spur, unversehrt=True, anzahl=0, kopf_position=0
    )
    assert leer.letzte_pruefsumme == anfangswert(spur, fall)
    eintraege = await eintraege_schreiben(fall_mit_ketten, spur, 4)
    voll = await _gleich(
        verbindung_anwendung, fall, spur, unversehrt=True, anzahl=4, kopf_position=4
    )
    assert voll.letzte_pruefsumme == eintraege[-1].pruefsumme
    assert (voll.position, voll.grund) == (None, None)


@pytest.mark.parametrize("spur", SPUREN)
@pytest.mark.parametrize(
    "fall_name",
    [
        "aenderung",
        "position_geaendert",
        "entfernen_mitte",
        "entfernen_ende",
        "abschneiden_zwei",
        "eintrag_hinter_kopf",
        "kopf_fehlt",
        "nachgerechnet_ende",
        "nachgerechnet_mitte",
        "doppelte_position",
    ],
)
async def test_R3_F_012_manipulationskatalog_beide_rechenwege_nennen_dieselbe_stelle(
    fall_mit_ketten: "SynthetischerFall",
    eintraege_schreiben: Schreiben,
    manipulieren: Manipulieren,
    verbindung_anwendung: AsyncConnection,
    spur: Spur,
    fall_name: str,
) -> None:
    fall = fall_mit_ketten.kennung
    e = await eintraege_schreiben(fall_mit_ketten, spur, 5)
    entfernen: tuple[str, ...] = ()
    if fall_name == "aenderung":
        sql = _setzen(spur, e[2], payload='{"x":"y"}')[0].replace(
            f"pruefsumme = '{pruefsumme(replace(e[2], payload='{"x":"y"}'))}'",
            f"pruefsumme = '{e[2].pruefsumme}'",
        )
        erwartet = (Bruchgrund.INHALT_GEAENDERT, 3, 2)
    elif fall_name == "position_geaendert":
        sql = (
            f"UPDATE r3cosint.{spur.value} SET position = 7 "
            f"WHERE kennung = CAST('{e[2].kennung}' AS uuid)"
        )
        erwartet = (Bruchgrund.LUECKE, 3, 2)
    elif fall_name == "entfernen_mitte":
        sql = _loeschen(spur, e[2])
        erwartet = (Bruchgrund.LUECKE, 3, 2)
    elif fall_name == "entfernen_ende":
        sql = _loeschen(spur, e[4])
        erwartet = (Bruchgrund.KOPF_ABWEICHEND, 5, 4)
    elif fall_name == "abschneiden_zwei":
        sql = _loeschen(spur, e[3], e[4])
        erwartet = (Bruchgrund.KOPF_ABWEICHEND, 4, 3)
    elif fall_name == "eintrag_hinter_kopf":
        sql = _kopf_setzen(spur, fall, 4, e[3].pruefsumme)
        erwartet = (Bruchgrund.KOPF_ABWEICHEND, 5, 4)
    elif fall_name == "kopf_fehlt":
        sql = (
            f"DELETE FROM r3cosint.kettenkopf WHERE fall_kennung = CAST('{fall}' AS uuid) "
            f"AND spur = '{spur.value}'"
        )
        erwartet = (Bruchgrund.KOPF_ABWEICHEND, 0, 5)
    elif fall_name == "nachgerechnet_ende":
        sql = _setzen(spur, e[4], payload='{"x":"y"}')[0]
        erwartet = (Bruchgrund.KOPF_ABWEICHEND, 5, 4)
    elif fall_name == "nachgerechnet_mitte":
        sql = _setzen(spur, e[2], payload='{"x":"y"}')[0]
        erwartet = (Bruchgrund.VORGAENGER_FALSCH, 4, 3)
    else:
        doppelt = replace(e[1], kennung=UUID(int=4242))
        doppelt = replace(doppelt, pruefsumme="e" * 64)
        sql = (
            f"INSERT INTO r3cosint.{spur.value} (kennung, fall_kennung, position, zeitpunkt, "
            "person_kennung, eintragstyp, kennzeichnung, payload, vorgaenger_pruefsumme, "
            f"pruefsumme) VALUES (CAST('{doppelt.kennung}' AS uuid), CAST('{fall}' AS uuid), "
            f"{doppelt.position}, '{doppelt.zeitpunkt.isoformat()}', '{doppelt.person_kennung}', "
            f"'{doppelt.eintragstyp.value}', '{doppelt.kennzeichnung.value}', '{doppelt.payload}', "
            f"'{doppelt.vorgaenger_pruefsumme}', '{doppelt.pruefsumme}')"
        )
        entfernen = (f"{spur.value}_fall_kennung_position_key",)
        erwartet = (Bruchgrund.INHALT_GEAENDERT, 2, 1)
        # Die doppelte Zeile (kennung 4242) sortiert nach (position, kennung) vor dem Original und
        # trägt eine falsche Prüfsumme; beide Wege müssen sie zuerst lesen und an Position 2 brechen.
    await manipulieren(sql, bedingungen_entfernen=entfernen)
    anwendung, datenbank = await _beide_wege(verbindung_anwendung, fall)
    assert anwendung[spur] == datenbank[spur]
    befund = anwendung[spur]
    assert befund.unversehrt is False
    assert (befund.grund, befund.position, befund.anzahl) == erwartet
    # Die andere Spur desselben Falls bleibt unversehrt.
    andere = Spur.ERMITTLUNGSSPUR if spur is Spur.ARBEITSSPUR else Spur.ARBEITSSPUR
    assert anwendung[andere] == datenbank[andere]
    assert anwendung[andere].unversehrt is True


@pytest.mark.parametrize("spur", SPUREN)
async def test_R3_F_012_nachrechnen_bis_zum_ende_samt_kopf_bleibt_unentdeckt_grenze_gs_2(
    fall_mit_ketten: "SynthetischerFall",
    eintraege_schreiben: Schreiben,
    manipulieren: Manipulieren,
    verbindung_anwendung: AsyncConnection,
    spur: Spur,
) -> None:
    fall = fall_mit_ketten.kennung
    eintraege = await eintraege_schreiben(fall_mit_ketten, spur, 3)
    vorgaenger = anfangswert(spur, fall)
    anweisungen = []
    for e in eintraege:
        sql, neu = _setzen(
            spur, e, payload='{"x":"y"}', vorgaenger_pruefsumme=vorgaenger
        )
        anweisungen.append(sql)
        vorgaenger = neu.pruefsumme
    anweisungen.append(_kopf_setzen(spur, fall, 3, vorgaenger))
    # Unter replica laufen keine Auslöser: Einträge und Kopf werden in einer Transaktion
    # neu gerechnet; die neuen Prüfsummen sind alle neu und kollidieren nicht mit UNIQUE.
    await manipulieren("; ".join(anweisungen))
    await _gleich(verbindung_anwendung, fall, spur, unversehrt=True, anzahl=3)


@pytest.mark.parametrize("spur", SPUREN)
async def test_R3_F_012_unendlicher_zeitpunkt_ist_nie_unversehrt(
    fall_mit_ketten: "SynthetischerFall",
    eintraege_schreiben: Schreiben,
    manipulieren: Manipulieren,
    verbindung_anwendung: AsyncConnection,
    spur: Spur,
) -> None:
    fall = fall_mit_ketten.kennung
    eintraege = await eintraege_schreiben(fall_mit_ketten, spur, 3)
    sql = (
        f"UPDATE r3cosint.{spur.value} SET zeitpunkt = 'infinity' "
        f"WHERE kennung = CAST('{eintraege[1].kennung}' AS uuid)"
    )
    # Unter replica gelten Prüfbedingungen weiter: ohne Entfernen weist die Datenbank ab.
    with pytest.raises(DBAPIError, match="zeitbereich"):
        await manipulieren(sql)
    await manipulieren(sql, bedingungen_entfernen=(f"{spur.value}_zeitbereich",))
    befund = (
        await verbindung_anwendung.execute(
            text(
                "SELECT o_unversehrt, o_grund, o_position FROM "
                "r3cosint.spur_kette_pruefen(:spur, :fall)"
            ),
            {"spur": spur.value, "fall": fall},
        )
    ).one()
    await verbindung_anwendung.rollback()
    assert (befund.o_unversehrt, befund.o_grund, befund.o_position) == (
        False,
        "inhalt_geaendert",
        2,
    )
    try:
        python_weg = (await _beide_wege(verbindung_anwendung, fall))[0][spur]
    except (ValueError, DBAPIError):
        return
    assert python_weg.unversehrt is False


async def test_R3_F_012_alle_ketten_pruefen_ueber_zwei_faelle_sortiert(
    fall_mit_ketten: "SynthetischerFall",
    fall_anlegen: Callable[[], Awaitable["SynthetischerFall"]],
    eintraege_schreiben: Schreiben,
    verbindung_anwendung: AsyncConnection,
) -> None:
    zweiter = await fall_anlegen()
    for fall in (fall_mit_ketten, zweiter):
        await eintraege_schreiben(fall, Spur.ARBEITSSPUR, 2)
    async with verbindung_anwendung.begin():
        befunde = await alle_ketten_pruefen(verbindung_anwendung)
    assert [(b.fall_kennung, b.spur) for b in befunde] == sorted(
        (f.kennung, s) for f in (fall_mit_ketten, zweiter) for s in Spur
    )
    assert all(b.unversehrt for b in befunde)
    assert sorted(b.anzahl for b in befunde) == [0, 0, 2, 2]


async def test_R3_F_012_alle_ketten_pruefen_meldet_den_bruch_eines_einzelnen_falls(
    fall_mit_ketten: "SynthetischerFall",
    fall_anlegen: Callable[[], Awaitable["SynthetischerFall"]],
    eintraege_schreiben: Schreiben,
    manipulieren: Manipulieren,
    verbindung_anwendung: AsyncConnection,
) -> None:
    zweiter = await fall_anlegen()
    eintraege = await eintraege_schreiben(zweiter, Spur.ERMITTLUNGSSPUR, 2)
    await manipulieren(_loeschen(Spur.ERMITTLUNGSSPUR, eintraege[1]))
    async with verbindung_anwendung.begin():
        befunde = await alle_ketten_pruefen(verbindung_anwendung)
    gebrochen = [b for b in befunde if not b.unversehrt]
    assert [(b.fall_kennung, b.spur, b.grund) for b in gebrochen] == [
        (zweiter.kennung, Spur.ERMITTLUNGSSPUR, Bruchgrund.KOPF_ABWEICHEND)
    ]
    assert fall_mit_ketten.kennung != zweiter.kennung


@pytest.mark.parametrize("spur", SPUREN)
async def test_R3_F_008_gleichzeitiges_anfuegen_ueber_zwei_verbindungen_bleibt_lueckenlos(
    fall_mit_ketten: "SynthetischerFall",
    eintraege_schreiben: Schreiben,
    verbindung_anwendung: AsyncConnection,
    spur: Spur,
) -> None:
    fall = fall_mit_ketten.kennung
    a, b = await asyncio.gather(
        eintraege_schreiben(fall_mit_ketten, spur, 20),
        eintraege_schreiben(fall_mit_ketten, spur, 20),
    )
    positionen = sorted(e.position for e in (*a, *b))
    assert positionen == list(range(1, 41))
    await _gleich(verbindung_anwendung, fall, spur, unversehrt=True, anzahl=40)


async def test_R3_F_012_beide_wege_sind_waehrend_des_gleichzeitigen_anfuegens_gleich(
    datenbank: "Testdatenbank",
    fall_mit_ketten: "SynthetischerFall",
    eintraege_schreiben: Schreiben,
) -> None:
    fall = fall_mit_ketten.kennung

    async def lesen() -> int:
        engine = engine_erzeugen(datenbank.verbindung("r3cosint_anwendung"))
        gleiche = 0
        try:
            for _ in range(8):
                async with engine.connect() as verbindung:
                    anwendung, db = await _beide_wege(verbindung, fall)
                    assert anwendung == db
                    assert all(b.unversehrt for b in anwendung.values())
                    gleiche += 1
        finally:
            await engine.dispose()
        return gleiche

    ergebnisse = await asyncio.gather(
        eintraege_schreiben(fall_mit_ketten, Spur.ARBEITSSPUR, 20),
        eintraege_schreiben(fall_mit_ketten, Spur.ARBEITSSPUR, 20),
        lesen(),
    )
    assert ergebnisse[2] == 8


# --- Dienstfunktionen -------------------------------------------------------------------------------


def _eroeffnet(fall: "SynthetischerFall", **aenderung: Any) -> FallEroeffnet:
    werte: dict[str, Any] = {
        "fall_kennung": fall.kennung,
        "rechtsregime": "R2",
        "fallkategorie": "uebertretung",
        "aktenzeichen": "TEST-SYNTH-X",
        "rechtsgrundlage": "synthetisch",
        "ermittelnde_person": "test.ermittlung",
        "eroeffnet_am": fall.uhr.zeitpunkt,
    }
    werte.update(aenderung)
    return FallEroeffnet(**werte)


async def _anfuegen(
    verbindung: AsyncConnection, fall: "SynthetischerFall", **aenderung: Any
) -> Eintrag:
    werte: dict[str, Any] = {
        "spur": Spur.ARBEITSSPUR,
        "fall_kennung": fall.kennung,
        "person_kennung": "test.ermittlung",
        "kennzeichnung": Kennzeichnung.SCHLUSSFOLGERUNG,
        "eingabe": _eroeffnet(fall),
        "pseudonymisierer": fall.pseudonymisierer,
        "uhr": fall.uhr,
    }
    werte.update(aenderung)
    return await anfuegen(verbindung, **werte)


async def test_R3_F_008_anfuegen_ohne_transaktion_des_aufrufers_wird_abgewiesen(
    fall_mit_ketten: "SynthetischerFall", verbindung_anwendung: AsyncConnection
) -> None:
    with pytest.raises(EingabeFehler, match="Transaktion"):
        await _anfuegen(verbindung_anwendung, fall_mit_ketten)
    with pytest.raises(EingabeFehler, match="Transaktion"):
        await kette_pruefen(verbindung_anwendung, fall_mit_ketten.kennung)
    with pytest.raises(EingabeFehler, match="Transaktion"):
        await kette_pruefen_datenbank(verbindung_anwendung, fall_mit_ketten.kennung)


@pytest.mark.parametrize(
    ("aenderung", "meldung"),
    [
        ({"person_kennung": "Falsch Person"}, "Benutzerkennung"),
        ({"spur": Spur.ERMITTLUNGSSPUR}, "Spur"),
        ({"fall_kennung": UUID(int=5)}, "Fallkennung"),
        (
            {
                "eingabe": FallGeschlossen(
                    fall_kennung=UUID(int=0),
                    geschlossen_am=NEUE_ZEIT,
                    prueffrist_bis=NEUE_ZEIT,
                    erste_pruefung_monate=84,
                )
            },
            "Fallkennung",
        ),
    ],
    ids=["person", "spur", "fall_parameter", "fall_eingabe"],
)
async def test_R3_F_008_anfuegen_weist_falsche_angaben_vor_jedem_schreiben_ab(
    fall_mit_ketten: "SynthetischerFall",
    verbindung_anwendung: AsyncConnection,
    aenderung: dict[str, Any],
    meldung: str,
) -> None:
    with pytest.raises(EingabeFehler, match=meldung):
        async with verbindung_anwendung.begin():
            await _anfuegen(verbindung_anwendung, fall_mit_ketten, **aenderung)
    anwendung, _ = await _beide_wege(verbindung_anwendung, fall_mit_ketten.kennung)
    assert all(b.unversehrt and b.anzahl == 0 for b in anwendung.values())


async def test_R3_F_008_anfuegen_ohne_kette_wird_abgewiesen(
    fall_mit_ketten: "SynthetischerFall", verbindung_anwendung: AsyncConnection
) -> None:
    unbekannt = replace(fall_mit_ketten, kennung=UUID(int=9))
    with pytest.raises(EingabeFehler, match="keine Kette"):
        async with verbindung_anwendung.begin():
            await _anfuegen(
                verbindung_anwendung, unbekannt, eingabe=_eroeffnet(unbekannt)
            )


async def test_R3_F_008_anfuegen_weist_leere_werte_und_zeit_ausserhalb_des_bereichs_ab(
    fall_mit_ketten: "SynthetischerFall", verbindung_anwendung: AsyncConnection
) -> None:
    for aenderung in (
        {"eingabe": _eroeffnet(fall_mit_ketten, aktenzeichen="   ")},
        {
            "eingabe": _eroeffnet(
                fall_mit_ketten, eroeffnet_am=datetime(1999, 1, 1, tzinfo=UTC)
            )
        },
    ):
        with pytest.raises(EingabeFehler, match="Nutzlast") as fehler:
            async with verbindung_anwendung.begin():
                await _anfuegen(verbindung_anwendung, fall_mit_ketten, **aenderung)
        assert "   " not in str(fehler.value)
    anwendung, _ = await _beide_wege(verbindung_anwendung, fall_mit_ketten.kennung)
    assert anwendung[Spur.ARBEITSSPUR].anzahl == 0


class _UhrMax:
    """Uhr auf datetime.max, das asyncpg als 'infinity' läse; anfuegen weist es ab."""

    def jetzt(self) -> datetime:
        """Liefert datetime.max in UTC."""
        return datetime.max.replace(tzinfo=UTC)


async def test_R3_F_008_anfuegen_weist_datetime_max_als_zeitpunkt_ab(
    fall_mit_ketten: "SynthetischerFall", verbindung_anwendung: AsyncConnection
) -> None:
    with pytest.raises(EingabeFehler, match="Zeitpunkt der Uhr"):
        async with verbindung_anwendung.begin():
            await _anfuegen(verbindung_anwendung, fall_mit_ketten, uhr=_UhrMax())
    anwendung, _ = await _beide_wege(verbindung_anwendung, fall_mit_ketten.kennung)
    assert anwendung[Spur.ARBEITSSPUR].anzahl == 0


async def test_R3_F_008_anfuegen_liefert_den_gespeicherten_eintrag_ohne_klartext(
    fall_mit_ketten: "SynthetischerFall",
    verbindung_anwendung: AsyncConnection,
    verbindung_eigentuemer: AsyncConnection,
) -> None:
    async with verbindung_anwendung.begin():
        eintrag = await _anfuegen(verbindung_anwendung, fall_mit_ketten)
    assert eintrag.position == 1
    assert eintrag.vorgaenger_pruefsumme == anfangswert(
        Spur.ARBEITSSPUR, fall_kennung_von(fall_mit_ketten)
    )
    assert eintrag.pruefsumme == pruefsumme(eintrag)
    assert eintrag.kennzeichnung is Kennzeichnung.SCHLUSSFOLGERUNG
    zeilen = (
        await verbindung_eigentuemer.execute(
            text("SELECT payload, person_kennung FROM r3cosint.arbeitsspur")
        )
    ).all()
    assert len(zeilen) == 1
    assert zeilen[0].payload == eintrag.payload
    assert "TEST-SYNTH-X" not in zeilen[0].payload
    assert "synthetisch" not in zeilen[0].payload


def fall_kennung_von(fall: "SynthetischerFall") -> UUID:
    return fall.kennung


async def test_R3_F_008_die_pruefung_aendert_nichts_und_schreibt_keinen_eintrag(
    fall_mit_ketten: "SynthetischerFall",
    eintraege_schreiben: Schreiben,
    verbindung_anwendung: AsyncConnection,
    verbindung_eigentuemer: AsyncConnection,
) -> None:
    await eintraege_schreiben(fall_mit_ketten, Spur.ARBEITSSPUR, 2)

    async def stand() -> list[tuple[Any, ...]]:
        zeilen = (
            await verbindung_eigentuemer.execute(
                text(
                    "SELECT 'a', pruefsumme FROM r3cosint.arbeitsspur UNION ALL "
                    "SELECT 'e', pruefsumme FROM r3cosint.ermittlungsspur UNION ALL "
                    "SELECT spur, pruefsumme || position FROM r3cosint.kettenkopf ORDER BY 1, 2"
                )
            )
        ).all()
        await verbindung_eigentuemer.rollback()
        return [tuple(z) for z in zeilen]

    vorher = await stand()
    await _beide_wege(verbindung_anwendung, fall_mit_ketten.kennung)
    assert await stand() == vorher


# --- Hilfe manipulieren ----------------------------------------------------------------------------------


async def test_R3_F_008_manipulieren_laesst_nach_der_hilfe_die_ausloeser_wieder_greifen(
    fall_mit_ketten: "SynthetischerFall",
    eintraege_schreiben: Schreiben,
    manipulieren: Manipulieren,
    verbindung_eigentuemer: AsyncConnection,
    replikationsparameter: str,
) -> None:
    e = await eintraege_schreiben(fall_mit_ketten, Spur.ARBEITSSPUR, 2)
    # Die Hilfe liest den Parameter auf ihrer eigenen Verbindung in einer neuen Transaktion.
    assert await manipulieren(_loeschen(Spur.ARBEITSSPUR, e[1])) == "origin"
    assert (
        await verbindung_eigentuemer.execute(text(f"SHOW {replikationsparameter}"))
    ).scalar_one() == "origin"
    await verbindung_eigentuemer.rollback()
    with pytest.raises(DBAPIError, match="ausschliesslich anfügbar"):
        await verbindung_eigentuemer.execute(
            text("UPDATE r3cosint.arbeitsspur SET payload = '{}'")
        )
    await verbindung_eigentuemer.rollback()


@pytest.mark.parametrize(
    "sql",
    [
        "DROP TABLE r3cosint.arbeitsspur",
        "ALTER ROLE r3cosint_anwendung SUPERUSER",
        "INSERT INTO r3cosint.fall DEFAULT VALUES",
        "SELECT 1",
        "UPDATE r3cosint.arbeitsspur SET payload = '{}'; DROP TABLE r3cosint.arbeitsspur",
    ],
)
async def test_R3_F_008_manipulieren_weist_anderes_als_dml_auf_die_drei_tabellen_vor_der_ausfuehrung_ab(
    manipulieren: Manipulieren, sql: str
) -> None:
    with pytest.raises(ValueError, match="INSERT, UPDATE und DELETE"):
        await manipulieren(sql)


async def test_R3_F_008_manipulieren_entfernt_nur_bedingungen_dieser_drei_tabellen(
    fall_mit_ketten: "SynthetischerFall", manipulieren: Manipulieren
) -> None:
    assert fall_mit_ketten.kennung
    for name in ("fall_zustand_vorrat", "gibt_es_nicht"):
        with pytest.raises(ValueError, match="unbekannt"):
            await manipulieren(
                "UPDATE r3cosint.kettenkopf SET position = position",
                bedingungen_entfernen=(name,),
            )


# --- Nachbesserungsrunde (ST-S12-14 bis -16, -20) -------------------------------------------------------


class _UhrNaiv:
    """Uhr ohne Zone; anfuegen weist sie ab."""

    def jetzt(self) -> datetime:
        """Liefert eine Zeit ohne Zone."""
        return datetime(2026, 1, 1)  # noqa: DTZ001 - der Fall selbst


async def test_R3_F_008_anfuegen_weist_eine_uhr_ohne_zone_mit_dem_zeitpunkt_in_der_meldung_ab(
    fall_mit_ketten: "SynthetischerFall", verbindung_anwendung: AsyncConnection
) -> None:
    with pytest.raises(EingabeFehler, match="Zeitpunkt der Uhr"):
        async with verbindung_anwendung.begin():
            await _anfuegen(verbindung_anwendung, fall_mit_ketten, uhr=_UhrNaiv())


async def test_R3_F_008_alle_ketten_pruefen_verlangt_eine_offene_transaktion(
    verbindung_anwendung: AsyncConnection,
) -> None:
    with pytest.raises(EingabeFehler, match="Transaktion"):
        await alle_ketten_pruefen(verbindung_anwendung)


async def test_R3_F_008_eine_eingabe_ausserhalb_der_zuordnung_endet_mit_eingabefehler(
    fall_mit_ketten: "SynthetischerFall", verbindung_anwendung: AsyncConnection
) -> None:
    class Fremd(FallGeschlossen):
        """Unterklasse ausserhalb der festen Zuordnung."""

    eingabe = Fremd(
        fall_kennung=fall_mit_ketten.kennung,
        geschlossen_am=NEUE_ZEIT,
        prueffrist_bis=NEUE_ZEIT,
        erste_pruefung_monate=84,
    )
    with pytest.raises(EingabeFehler, match="Eintragstyp"):
        async with verbindung_anwendung.begin():
            await _anfuegen(verbindung_anwendung, fall_mit_ketten, eingabe=eingabe)


@pytest.mark.parametrize("negativ", [-1, -3])
@pytest.mark.parametrize("spur", SPUREN)
async def test_R3_F_012_negative_kopfposition_gibt_in_beiden_wegen_denselben_befund(
    fall_mit_ketten: "SynthetischerFall",
    eintraege_schreiben: Schreiben,
    manipulieren: Manipulieren,
    verbindung_anwendung: AsyncConnection,
    spur: Spur,
    negativ: int,
) -> None:
    fall = fall_mit_ketten.kennung
    await eintraege_schreiben(fall_mit_ketten, spur, 3)
    sql = (
        f"UPDATE r3cosint.kettenkopf SET position = {negativ} "
        f"WHERE fall_kennung = CAST('{fall}' AS uuid) AND spur = '{spur.value}'"
    )
    await manipulieren(sql, bedingungen_entfernen=("kettenkopf_position_ab_null",))
    befund = await _gleich(
        verbindung_anwendung,
        fall,
        spur,
        grund=Bruchgrund.KOPF_ABWEICHEND,
        position=negativ + 1,
        anzahl=0,
        kopf_position=negativ,
    )
    assert befund.letzte_pruefsumme == anfangswert(spur, fall)


# --- Schlüssel in Darstellungen und Fällen (SD-S12-08, SD-S12-09) ----------------------------------------


def _schluesselformen(schluessel: bytes) -> list[str]:
    return [schluessel.hex(), repr(schluessel), str(schluessel), repr(schluessel)[2:-1]]


async def test_R3_F_011_darstellungen_und_fehlertexte_enthalten_den_schluessel_nicht(
    fall_mit_ketten: "SynthetischerFall", verbindung_anwendung: AsyncConnection
) -> None:
    schluessel = fall_mit_ketten.schluessel
    texte = [
        repr(fall_mit_ketten),
        str(fall_mit_ketten),
        repr(fall_mit_ketten.pseudonymisierer),
        str(fall_mit_ketten.pseudonymisierer),
    ]
    with pytest.raises(ValueError, match="32 Bytes") as laenge:
        Pseudonymisierer(schluessel[:31])
    texte.append(str(laenge.value))
    with pytest.raises(EingabeFehler) as eingabe:
        async with verbindung_anwendung.begin():
            await _anfuegen(
                verbindung_anwendung, fall_mit_ketten, person_kennung="Falsch"
            )
    texte.append(str(eingabe.value))
    for text_ in texte:
        for form in _schluesselformen(schluessel):
            assert form not in text_, form


async def test_R3_F_011_zwei_faelle_der_fixture_tragen_zwei_verschiedene_schluessel(
    fall_mit_ketten: "SynthetischerFall",
    fall_anlegen: Callable[[], Awaitable["SynthetischerFall"]],
    verbindung_eigentuemer: AsyncConnection,
) -> None:
    zweiter = await fall_anlegen()
    assert fall_mit_ketten.schluessel != zweiter.schluessel
    assert len(fall_mit_ketten.schluessel) == len(zweiter.schluessel) == 32
    zeilen = (
        await verbindung_eigentuemer.execute(
            text("SELECT fall_kennung, schluessel FROM r3cosint.fall_schluessel")
        )
    ).all()
    assert {z.fall_kennung: bytes(z.schluessel) for z in zeilen} == {
        fall_mit_ketten.kennung: fall_mit_ketten.schluessel,
        zweiter.kennung: zweiter.schluessel,
    }


@pytest.mark.parametrize("spur", SPUREN)
async def test_R3_F_012_stimmig_gerechneter_eintrag_von_1999_wird_in_beiden_wegen_gleich_gemeldet(
    fall_mit_ketten: "SynthetischerFall",
    eintraege_schreiben: Schreiben,
    manipulieren: Manipulieren,
    verbindung_anwendung: AsyncConnection,
    spur: Spur,
) -> None:
    import hashlib

    from r3cosint.spur.kette import serialisieren, zeitpunkt_text

    fall = fall_mit_ketten.kennung
    e = await eintraege_schreiben(fall_mit_ketten, spur, 3)
    frueh = datetime(1999, 12, 31, 23, 59, 59, 999999, tzinfo=UTC)
    alt = zeitpunkt_text(e[2].zeitpunkt).encode()
    neu_text = "1999-12-31T23:59:59.999999Z"
    assert len(alt) == len(neu_text)
    summe = hashlib.sha256(
        serialisieren(e[2]).replace(alt, neu_text.encode())
    ).hexdigest()
    anweisungen = [
        f"UPDATE r3cosint.{spur.value} SET zeitpunkt = '{frueh.isoformat()}', "
        f"pruefsumme = '{summe}' WHERE kennung = CAST('{e[2].kennung}' AS uuid)",
        _kopf_setzen(spur, fall, 3, summe),
    ]
    await manipulieren(
        "; ".join(anweisungen), bedingungen_entfernen=(f"{spur.value}_zeitbereich",)
    )
    befund = await _gleich(
        verbindung_anwendung,
        fall,
        spur,
        unversehrt=False,
        grund=Bruchgrund.INHALT_GEAENDERT,
        position=3,
        anzahl=2,
    )
    assert befund.letzte_pruefsumme == e[1].pruefsumme
