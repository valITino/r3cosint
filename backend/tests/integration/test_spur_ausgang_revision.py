"""Integrationstest: Revision 0006, Vorrat der Eintragstypen der Arbeitsspur (ADR 0008, Nr. 20, Festlegung S2.1; R3-F-015, R3-F-028).

Geprüft werden Kopf und Namensschema, die Bedingung im Katalog, die Annahme der vier neuen Typen
und die Abweisung eines fremden Typs, der Rückweg mit und ohne Zeile eines neuen Typs und die
unveränderten Rechte der Anwendung. Alle Werte sind synthetisch.
"""

import re
from collections.abc import Awaitable, Callable
from dataclasses import replace
from datetime import UTC, datetime
from pathlib import Path
from typing import TYPE_CHECKING
from uuid import UUID

import pytest
from sqlalchemy import text
from sqlalchemy.exc import DBAPIError
from sqlalchemy.ext.asyncio import AsyncConnection

from r3cosint.core.kennung import neue_kennung
from r3cosint.spur.kette import (
    Eintrag,
    Eintragstyp,
    Kennzeichnung,
    Spur,
    anfangswert,
    pruefsumme,
)
from r3cosint.spur.payload import Verbindungsversuch
from r3cosint.spur.service import (
    alle_ketten_pruefen,
    anfuegen,
    kette_pruefen,
    kette_pruefen_datenbank,
)

if TYPE_CHECKING:
    from conftest import SynthetischerFall, Testdatenbank

    from r3cosint.core.konfiguration import Datenbankverbindung

pytestmark = pytest.mark.anyio

MIGRATIONEN = Path(__file__).resolve().parents[2] / "migrationen"
AlembicBefehl = Callable[["Datenbankverbindung", str, str | None], Awaitable[None]]
NEUE_TYPEN = ("verbindungsversuch", "abweisung", "abfrage", "negativbefund")
BEDINGUNG = "arbeitsspur_eintragstyp_vorrat"
ZIEL = "https://dienst.beispiel.test:443"


async def _bedingung(
    verbindung: AsyncConnection, tabelle: str, name: str
) -> tuple[str, bool]:
    zeile = (
        await verbindung.execute(
            text(
                "SELECT pg_get_constraintdef(c.oid), c.convalidated FROM pg_constraint c "
                "JOIN pg_class cl ON cl.oid = c.conrelid "
                "JOIN pg_namespace n ON n.oid = cl.relnamespace "
                "WHERE n.nspname = 'r3cosint' AND cl.relname = :t AND c.conname = :n"
            ),
            {"t": tabelle, "n": name},
        )
    ).one()
    return str(zeile[0]), bool(zeile[1])


def _werte(definition: str) -> set[str]:
    return set(re.findall(r"'([a-z_]+)'", definition))


async def _version(verbindung: AsyncConnection) -> list[str]:
    zeilen = await verbindung.execute(
        text("SELECT version_num FROM r3cosint.alembic_version")
    )
    return [zeile[0] for zeile in zeilen]


def _versuch(fall: UUID) -> Verbindungsversuch:
    return Verbindungsversuch(
        fall_kennung=fall,
        werkzeug="test.werkzeug",
        versuch_kennung=UUID(int=9),
        schritt=0,
        methode="GET",
        ergebnis="zugelassen",
        listenstand="ab" * 32,
        schema="https",
        anschluss=443,
        zielart="name",
        ziel=ZIEL,
        adresse="2001:20::1",
        adressbereich="oeffentlich",
        listeneintrag="test.ziel-synth",
    )


async def _versuch_anfuegen(
    verbindung: AsyncConnection, fall: "SynthetischerFall"
) -> Eintrag:
    async with verbindung.begin():
        return await anfuegen(
            verbindung,
            spur=Spur.ARBEITSSPUR,
            fall_kennung=fall.kennung,
            person_kennung="test.ermittlung",
            kennzeichnung=Kennzeichnung.QUELLENAUSSAGE,
            eingabe=_versuch(fall.kennung),
            pseudonymisierer=fall.pseudonymisierer,
            uhr=fall.uhr,
        )


async def _beide_wege_unversehrt(verbindung: AsyncConnection, fall: UUID) -> None:
    async with verbindung.begin():
        anwendung = await kette_pruefen(verbindung, fall)
        datenbank = await kette_pruefen_datenbank(verbindung, fall)
        alle = await alle_ketten_pruefen(verbindung)
    for spur in Spur:
        assert anwendung[spur].unversehrt
        assert anwendung[spur] == datenbank[spur]
    assert all(befund.unversehrt for befund in alle)


def test_R3_F_015_revision_0006_ist_der_kopf_mit_dem_namen_ausgang() -> None:
    from alembic.config import Config
    from alembic.script import ScriptDirectory

    konfiguration = Config()
    konfiguration.set_main_option("script_location", str(MIGRATIONEN))
    konfiguration.set_main_option("path_separator", "os")
    konfiguration.set_main_option("version_locations", str(MIGRATIONEN / "versionen"))
    skripte = ScriptDirectory.from_config(konfiguration)
    assert skripte.get_heads() == ["0006"]
    assert (MIGRATIONEN / "versionen" / "0006_ausgang.py").is_file()
    assert skripte.get_revision("0006").down_revision == "0005"


def test_R3_F_015_rueckweg_ohne_delete_und_ohne_not_valid() -> None:
    for name in ("0006_ausgang.sql", "0006_ausgang_rueckweg.sql"):
        sql = (MIGRATIONEN / "sql" / name).read_text(encoding="utf-8")
        ohne_kommentar = "\n".join(
            z for z in sql.splitlines() if not z.lstrip().startswith("--")
        ).upper()
        assert "DELETE" not in ohne_kommentar
        assert "NOT VALID" not in ohne_kommentar
        assert "TRUNCATE" not in ohne_kommentar


async def test_R3_F_015_bedingung_im_katalog_hat_sechs_werte_und_ist_geprueft(
    verbindung_eigentuemer: AsyncConnection,
) -> None:
    assert await _version(verbindung_eigentuemer) == ["0006"]
    definition, geprueft = await _bedingung(
        verbindung_eigentuemer, "arbeitsspur", BEDINGUNG
    )
    assert geprueft
    assert _werte(definition) == {"fall_eroeffnet", "fall_geschlossen", *NEUE_TYPEN}
    # Die Ermittlungsspur bleibt unverändert.
    definition, _ = await _bedingung(
        verbindung_eigentuemer, "ermittlungsspur", "ermittlungsspur_eintragstyp_vorrat"
    )
    assert _werte(definition) == {"entitaet", "beziehung"}


async def test_R3_F_015_vorrat_der_revision_gleich_dem_vorrat_der_anwendung(
    verbindung_eigentuemer: AsyncConnection,
) -> None:
    definition, _ = await _bedingung(verbindung_eigentuemer, "arbeitsspur", BEDINGUNG)
    arbeitsspur = {
        typ.value
        for typ in Eintragstyp
        if typ
        in (
            Eintragstyp.FALL_EROEFFNET,
            Eintragstyp.FALL_GESCHLOSSEN,
            *(Eintragstyp(n) for n in NEUE_TYPEN),
        )
    }
    assert _werte(definition) == arbeitsspur


async def test_R3_F_015_verbindungsversuch_ueber_den_dienst_wird_angenommen(
    fall_mit_ketten: "SynthetischerFall", verbindung_anwendung: AsyncConnection
) -> None:
    eintrag = await _versuch_anfuegen(verbindung_anwendung, fall_mit_ketten)
    assert eintrag.eintragstyp is Eintragstyp.VERBINDUNGSVERSUCH
    assert eintrag.spur is Spur.ARBEITSSPUR
    await _beide_wege_unversehrt(verbindung_anwendung, fall_mit_ketten.kennung)


class _FremderTyp:
    """Stand-in für einen Typ ausserhalb des Vorrats; die Prüfsumme liest allein value."""

    value = "freigabe_erteilt"


def _eintrag(
    fall: UUID, position: int, vorgaenger: str, typ: str | _FremderTyp
) -> Eintrag:
    offen = Eintrag(
        spur=Spur.ARBEITSSPUR,
        kennung=neue_kennung(),
        fall_kennung=fall,
        position=position,
        zeitpunkt=datetime(2026, 1, 15, 8, 30, 0, tzinfo=UTC),
        person_kennung="test.ermittlung",
        eintragstyp=typ if isinstance(typ, _FremderTyp) else Eintragstyp(typ),  # type: ignore[arg-type]
        kennzeichnung=Kennzeichnung.QUELLENAUSSAGE,
        payload="{}",
        vorgaenger_pruefsumme=vorgaenger,
        pruefsumme="",
    )
    return replace(offen, pruefsumme=pruefsumme(offen))


_INSERT = (
    "INSERT INTO r3cosint.arbeitsspur (kennung, fall_kennung, position, zeitpunkt, "
    "person_kennung, eintragstyp, kennzeichnung, payload, vorgaenger_pruefsumme, pruefsumme) "
    "VALUES (:kennung, :fall, :position, :zeit, :person, :typ, :kz, :payload, :vorg, :summe)"
)


async def _roh(verbindung: AsyncConnection, e: Eintrag, typ: str | None = None) -> None:
    await verbindung.execute(
        text(_INSERT),
        {
            "kennung": e.kennung,
            "fall": e.fall_kennung,
            "position": e.position,
            "zeit": e.zeitpunkt,
            "person": e.person_kennung,
            "typ": typ or e.eintragstyp.value,
            "kz": e.kennzeichnung.value,
            "payload": e.payload,
            "vorg": e.vorgaenger_pruefsumme,
            "summe": e.pruefsumme,
        },
    )


async def test_R3_F_015_alle_vier_neuen_typen_werden_von_der_datenbank_angenommen(
    fall_mit_ketten: "SynthetischerFall", verbindung_anwendung: AsyncConnection
) -> None:
    fall = fall_mit_ketten.kennung
    vorgaenger = anfangswert(Spur.ARBEITSSPUR, fall)
    # Position 1 ist die Eröffnung der Fixture-Kette nicht: fall_mit_ketten legt leere Ketten an.
    async with verbindung_anwendung.begin():
        for position, typ in enumerate(NEUE_TYPEN, start=1):
            eintrag = _eintrag(fall, position, vorgaenger, typ)
            await _roh(verbindung_anwendung, eintrag)
            await verbindung_anwendung.execute(
                text(
                    "UPDATE r3cosint.kettenkopf SET position = :p, pruefsumme = :s "
                    "WHERE fall_kennung = :f AND spur = 'arbeitsspur'"
                ),
                {"p": position, "s": eintrag.pruefsumme, "f": fall},
            )
            vorgaenger = eintrag.pruefsumme
    await _beide_wege_unversehrt(verbindung_anwendung, fall)


async def test_R3_F_015_ein_fremder_typ_wird_abgewiesen(
    fall_mit_ketten: "SynthetischerFall", verbindung_anwendung: AsyncConnection
) -> None:
    fall = fall_mit_ketten.kennung
    anfang = anfangswert(Spur.ARBEITSSPUR, fall)
    fremd = _eintrag(fall, 1, anfang, _FremderTyp())
    with pytest.raises(DBAPIError, match="eintragstyp_vorrat"):
        async with verbindung_anwendung.begin():
            await _roh(verbindung_anwendung, fremd)
    # Gegenprobe: ein zulässiger Typ derselben Form geht durch.
    async with verbindung_anwendung.begin():
        await _roh(verbindung_anwendung, _eintrag(fall, 1, anfang, "abfrage"))


async def test_R3_F_015_rechte_der_anwendung_sind_unveraendert(
    verbindung_anwendung: AsyncConnection,
) -> None:
    zeilen = await verbindung_anwendung.execute(
        text(
            "SELECT privilege_type FROM information_schema.role_table_grants "
            "WHERE table_schema = 'r3cosint' AND table_name = 'arbeitsspur' "
            "AND grantee = 'r3cosint_anwendung'"
        )
    )
    assert {z[0] for z in zeilen} == {"INSERT", "SELECT"}
    funktionen = await verbindung_anwendung.execute(
        text(
            "SELECT count(*) FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace "
            "WHERE n.nspname = 'r3cosint' AND p.proname LIKE '%ausgang%'"
        )
    )
    assert funktionen.scalar_one() == 0


async def test_R3_F_015_rueckweg_ohne_zeile_stellt_den_stand_von_0003_her(
    datenbank: "Testdatenbank",
    verbindung_eigentuemer: AsyncConnection,
    alembic_befehl: AlembicBefehl,
) -> None:
    eigentuemer = datenbank.verbindung("r3cosint_eigentuemer")
    await verbindung_eigentuemer.rollback()
    await alembic_befehl(eigentuemer, "downgrade", "0005")
    assert await _version(verbindung_eigentuemer) == ["0005"]
    definition, geprueft = await _bedingung(
        verbindung_eigentuemer, "arbeitsspur", BEDINGUNG
    )
    assert geprueft
    assert _werte(definition) == {"fall_eroeffnet", "fall_geschlossen"}
    await verbindung_eigentuemer.rollback()
    await alembic_befehl(eigentuemer, "upgrade", "head")
    assert await _version(verbindung_eigentuemer) == ["0006"]
    definition, _ = await _bedingung(verbindung_eigentuemer, "arbeitsspur", BEDINGUNG)
    assert len(_werte(definition)) == 6


async def test_R3_F_015_rueckweg_mit_einer_zeile_scheitert_ohne_wert_und_laesst_alles_stehen(
    datenbank: "Testdatenbank",
    fall_mit_ketten: "SynthetischerFall",
    verbindung_anwendung: AsyncConnection,
    verbindung_eigentuemer: AsyncConnection,
    alembic_befehl: AlembicBefehl,
) -> None:
    eintrag = await _versuch_anfuegen(verbindung_anwendung, fall_mit_ketten)
    fall = fall_mit_ketten.kennung

    async def stand() -> tuple[object, ...]:
        async with verbindung_eigentuemer.begin():
            zeile = (
                await verbindung_eigentuemer.execute(
                    text(
                        "SELECT a.payload, a.pruefsumme, a.eintragstyp, k.pruefsumme, k.position "
                        "FROM r3cosint.arbeitsspur a JOIN r3cosint.kettenkopf k "
                        "ON k.fall_kennung = a.fall_kennung AND k.spur = 'arbeitsspur' "
                        "WHERE a.kennung = :k"
                    ),
                    {"k": eintrag.kennung},
                )
            ).one()
        return tuple(zeile)

    vorher = await stand()
    with pytest.raises(
        Exception, match="Rueckweg von Revision 0006 abgebrochen"
    ) as fehler:
        await alembic_befehl(
            datenbank.verbindung("r3cosint_eigentuemer"), "downgrade", "0005"
        )
    assert type(fehler.value).__name__ == "CheckViolationError"
    meldung = str(fehler.value)
    for wert in (
        ZIEL,
        "beispiel.test",
        "test.werkzeug",
        "test.ziel-synth",
        "2001:20::1",
    ):
        assert wert not in meldung
    assert await stand() == vorher
    async with verbindung_eigentuemer.begin():
        assert await _version(verbindung_eigentuemer) == ["0006"]
        definition, _ = await _bedingung(
            verbindung_eigentuemer, "arbeitsspur", BEDINGUNG
        )
    assert len(_werte(definition)) == 6
    await _beide_wege_unversehrt(verbindung_anwendung, fall)
