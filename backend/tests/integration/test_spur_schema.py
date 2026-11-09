"""Integrationstest: Schema der Spuren, Rechte, Auslöser, Einfügeprüfung, Katalog (ADR 0007, Nr. 9 bis 20,
Festlegung S1.2; R3-F-008, R3-F-012). Die Prüfvektoren (tests/vektoren) laufen gegen die SQL-Funktionen.
"""

import json
import re
from collections.abc import Awaitable, Callable
from datetime import UTC, datetime
from pathlib import Path
from typing import TYPE_CHECKING, Any
from uuid import UUID

import pytest
from sqlalchemy import text
from sqlalchemy.exc import DBAPIError
from sqlalchemy.ext.asyncio import AsyncConnection

from r3cosint.core.kennung import neue_kennung
from r3cosint.spur.kette import Eintrag, Eintragstyp, Kennzeichnung, Spur, pruefsumme
from r3cosint.spur.kette import anfangswert as kette_anfangswert

if TYPE_CHECKING:
    from conftest import SynthetischerFall, Testdatenbank

pytestmark = pytest.mark.anyio

SQL_DATEI = (
    Path(__file__).resolve().parents[2] / "migrationen" / "sql" / "0003_spur.sql"
)
SQL_DATEI_0004 = (
    Path(__file__).resolve().parents[2]
    / "migrationen"
    / "sql"
    / "0004_fall_uebergang.sql"
)
VEKTOREN: dict[str, Any] = json.loads(
    (Path(__file__).resolve().parents[1] / "vektoren" / "pruefvektoren.json").read_text(
        encoding="utf-8"
    )
)
SPUREN = [Spur.ARBEITSSPUR, Spur.ERMITTLUNGSSPUR]
TYP = {Spur.ARBEITSSPUR: "fall_eroeffnet", Spur.ERMITTLUNGSSPUR: "entitaet"}
Schreiben = Callable[["SynthetischerFall", Spur, int], Awaitable[list[Eintrag]]]
Manipulieren = Callable[..., Awaitable[str]]
FUNKTIONEN = (
    "spur_anfangswert",
    "spur_pruefsumme",
    "spur_kette_pruefen",
    "spur_unveraenderlich",
    "spur_einfuegen_pruefen",
    "kettenkopf_pruefen",
    "fall_uebergang_pruefen",
)
OEFFENTLICH = ("spur_anfangswert", "spur_pruefsumme", "spur_kette_pruefen")


def _sqlstate(fehler: BaseException) -> str:
    orig = getattr(fehler, "orig", None)
    zustand = getattr(orig, "sqlstate", None) or getattr(orig, "pgcode", None)
    assert isinstance(zustand, str), repr(fehler)
    return zustand


async def _scheitert(verbindung: AsyncConnection, sql: str, **parameter: Any) -> str:
    """Führt die Anweisung aus, erwartet einen Fehler und liefert SQLSTATE und Meldung."""
    with pytest.raises(DBAPIError) as fehler:
        await verbindung.execute(text(sql), parameter)
    await verbindung.rollback()
    return f"{_sqlstate(fehler.value)}|{fehler.value}"


async def _skalar(verbindung: AsyncConnection, sql: str, **parameter: Any) -> Any:
    ergebnis = (await verbindung.execute(text(sql), parameter)).scalar_one()
    await verbindung.rollback()
    return ergebnis


# --- Prüfvektoren gegen den zweiten Rechenweg --------------------------------------------------


@pytest.mark.parametrize("spur", SPUREN)
async def test_R3_F_008_sql_anfangswert_gleicht_dem_ausgeschriebenen_vektor(
    verbindung_anwendung: AsyncConnection, spur: Spur
) -> None:
    wert = await _skalar(
        verbindung_anwendung,
        "SELECT r3cosint.spur_anfangswert(:spur, CAST(:fall AS uuid))",
        spur=spur.value,
        fall=VEKTOREN["fall_kennung"].upper(),
    )
    assert wert == VEKTOREN["anfangswerte"][spur.value]


@pytest.mark.parametrize("vektor", VEKTOREN["eintraege"], ids=lambda v: v["name"])
async def test_R3_F_008_sql_pruefsumme_gleicht_dem_ausgeschriebenen_vektor(
    verbindung_anwendung: AsyncConnection, vektor: dict[str, Any]
) -> None:
    wert = await _skalar(
        verbindung_anwendung,
        "SELECT r3cosint.spur_pruefsumme(:spur, CAST(:k AS uuid), CAST(:f AS uuid), :pos, "
        "CAST(CAST(:zeit AS text) AS timestamptz), :person, :typ, :kz, :payload, :vorg)",
        spur=vektor["spur"],
        k=vektor["kennung"],
        f=vektor["fall_kennung"],
        pos=vektor["position"],
        # Als Text: asyncpg liest datetime.max als 'infinity'; die Obergrenze ginge sonst verloren.
        zeit=vektor["zeitpunkt"],
        person=vektor["person_kennung"],
        typ=vektor["eintragstyp"],
        kz=vektor["kennzeichnung"],
        payload=vektor["payload"],
        vorg=vektor["vorgaenger_pruefsumme"],
    )
    assert wert == vektor["erwartet"]


async def test_R3_F_008_null_argument_an_spur_pruefsumme_ergibt_null(
    verbindung_anwendung: AsyncConnection,
) -> None:
    wert = await _skalar(
        verbindung_anwendung,
        "SELECT r3cosint.spur_pruefsumme('arbeitsspur', NULL, NULL, 1, 'infinity', "
        "'a', 'b', 'c', 'd', 'e')",
    )
    assert wert is None
    meldung = await _scheitert(
        verbindung_anwendung,
        "SELECT r3cosint.spur_pruefsumme('arbeitsspur', CAST(:k AS uuid), CAST(:k AS uuid), 1, "
        "'infinity', 'a', 'b', 'c', 'd', 'e')",
        k=str(UUID(int=1)),
    )
    assert meldung.startswith("22008|")


@pytest.mark.parametrize(
    "aufruf",
    [
        "spur_kette_pruefen(NULL, CAST('00000000-0000-0000-0000-000000000001' AS uuid))",
        "spur_kette_pruefen('arbeitsspur', NULL)",
        "spur_kette_pruefen('unbekannt', CAST('00000000-0000-0000-0000-000000000001' AS uuid))",
    ],
)
async def test_R3_F_012_null_argument_und_unbekannte_spur_an_spur_kette_pruefen_enden_mit_fehler(
    verbindung_anwendung: AsyncConnection, aufruf: str
) -> None:
    meldung = await _scheitert(verbindung_anwendung, f"SELECT * FROM r3cosint.{aufruf}")
    assert meldung.startswith("P0001|")


# --- Katalog -----------------------------------------------------------------------------------


def _rumpf(name: str) -> str:
    quelle = "\n".join(
        datei.read_text(encoding="utf-8") for datei in (SQL_DATEI, SQL_DATEI_0004)
    )
    treffer = re.search(rf"\${name}\$(.*?)\${name}\$", quelle, re.DOTALL)
    assert treffer is not None, name
    return treffer.group(1)


async def test_R3_F_008_genau_die_sieben_funktionen_mit_invoker_search_path_und_rumpf_der_revision(
    verbindung_eigentuemer: AsyncConnection,
) -> None:
    zeilen = (
        await verbindung_eigentuemer.execute(
            text(
                "SELECT p.proname, p.prosecdef, p.proconfig, p.prosrc FROM pg_proc p "
                "JOIN pg_namespace n ON n.oid = p.pronamespace WHERE n.nspname = 'r3cosint' "
                "ORDER BY p.proname"
            )
        )
    ).all()
    assert [z.proname for z in zeilen] == sorted(FUNKTIONEN)
    for zeile in zeilen:
        assert zeile.prosecdef is False, zeile.proname
        assert zeile.proconfig == ["search_path=pg_catalog, pg_temp"], zeile.proname
        assert zeile.prosrc == _rumpf(zeile.proname), zeile.proname


async def test_R3_F_008_execute_nur_auf_die_drei_hilfsfunktionen_und_nie_fuer_public(
    verbindung_eigentuemer: AsyncConnection,
) -> None:
    zeilen = (
        await verbindung_eigentuemer.execute(
            text(
                "SELECT p.proname, "
                "has_function_privilege('r3cosint_anwendung', p.oid, 'EXECUTE') AS anwendung, "
                "has_function_privilege('public', p.oid, 'EXECUTE') AS oeffentlich "
                "FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace "
                "WHERE n.nspname = 'r3cosint'"
            )
        )
    ).all()
    assert {z.proname: z.anwendung for z in zeilen} == {
        name: name in OEFFENTLICH for name in FUNKTIONEN
    }
    assert not any(z.oeffentlich for z in zeilen)


async def test_R3_F_008_ausloeser_je_tabelle_sind_aktiv(
    verbindung_eigentuemer: AsyncConnection,
) -> None:
    zeilen = (
        await verbindung_eigentuemer.execute(
            text(
                "SELECT c.relname, t.tgname, t.tgenabled::text AS tgenabled, p.proname "
                "FROM pg_trigger t JOIN pg_class c ON c.oid = t.tgrelid "
                "JOIN pg_namespace n ON n.oid = c.relnamespace "
                "JOIN pg_proc p ON p.oid = t.tgfoid "
                "WHERE n.nspname = 'r3cosint' AND NOT t.tgisinternal ORDER BY 1, 2"
            )
        )
    ).all()
    assert {(z.relname, z.tgname): z.proname for z in zeilen} == {
        ("arbeitsspur", "arbeitsspur_einfuegen_pruefen"): "spur_einfuegen_pruefen",
        ("arbeitsspur", "arbeitsspur_unveraenderlich"): "spur_unveraenderlich",
        ("arbeitsspur", "arbeitsspur_unveraenderlich_leeren"): "spur_unveraenderlich",
        (
            "ermittlungsspur",
            "ermittlungsspur_einfuegen_pruefen",
        ): "spur_einfuegen_pruefen",
        ("ermittlungsspur", "ermittlungsspur_unveraenderlich"): "spur_unveraenderlich",
        (
            "ermittlungsspur",
            "ermittlungsspur_unveraenderlich_leeren",
        ): "spur_unveraenderlich",
        ("kettenkopf", "kettenkopf_einfuegen_aendern_pruefen"): "kettenkopf_pruefen",
        ("kettenkopf", "kettenkopf_nicht_leeren"): "spur_unveraenderlich",
        ("kettenkopf", "kettenkopf_nicht_loeschen"): "spur_unveraenderlich",
        ("fall", "fall_uebergang"): "fall_uebergang_pruefen",
    }
    assert all(z.tgenabled == "O" for z in zeilen)


async def test_R3_F_008_fremdschluessel_ueber_paketgrenzen_ohne_weitergabe(
    verbindung_eigentuemer: AsyncConnection,
) -> None:
    zeilen = (
        await verbindung_eigentuemer.execute(
            text(
                "SELECT c.conrelid::regclass::text AS tabelle, c.confrelid::regclass::text AS ziel, "
                "c.confdeltype::text AS confdeltype, c.confupdtype::text AS confupdtype FROM pg_constraint c "
                "JOIN pg_namespace n ON n.oid = c.connamespace "
                "WHERE n.nspname = 'r3cosint' AND c.contype = 'f'"
            )
        )
    ).all()
    paare = {(z.tabelle, z.ziel) for z in zeilen}
    assert {
        ("r3cosint.arbeitsspur", "r3cosint.fall"),
        ("r3cosint.ermittlungsspur", "r3cosint.fall"),
        ("r3cosint.kettenkopf", "r3cosint.fall"),
        ("r3cosint.fall_schluessel", "r3cosint.fall"),
        ("r3cosint.fall", "r3cosint.fallkategorie"),
        ("r3cosint.herkunft", "r3cosint.fall"),
        ("r3cosint.entitaet", "r3cosint.fall"),
        ("r3cosint.entitaet", "r3cosint.herkunft"),
        ("r3cosint.beziehung", "r3cosint.fall"),
        ("r3cosint.beziehung", "r3cosint.herkunft"),
        ("r3cosint.beziehung", "r3cosint.entitaet"),
    } == paare
    assert all((z.confdeltype, z.confupdtype) == ("a", "a") for z in zeilen)


async def test_R3_F_012_die_datenbank_kodiert_in_utf8(
    verbindung_anwendung: AsyncConnection,
) -> None:
    assert await _skalar(verbindung_anwendung, "SHOW server_encoding") == "UTF8"


async def test_R3_F_008_session_replication_role_ist_fuer_beide_rollen_gesperrt(
    verbindung_anwendung: AsyncConnection,
    verbindung_eigentuemer: AsyncConnection,
    replikationsparameter: str,
) -> None:
    for verbindung in (verbindung_anwendung, verbindung_eigentuemer):
        meldung = await _scheitert(verbindung, f"SET {replikationsparameter} = replica")
        assert meldung.startswith("42501|")
    assert (
        await _skalar(
            verbindung_eigentuemer,
            "SELECT count(*) FROM pg_parameter_acl WHERE parname = :name",
            name=replikationsparameter,
        )
        == 0
    )


# --- Rechte --------------------------------------------------------------------------------------


async def _recht(verbindung: AsyncConnection, tabelle: str, recht: str) -> bool:
    return bool(
        await _skalar(
            verbindung,
            "SELECT has_table_privilege('r3cosint_anwendung', :tabelle, :recht)",
            tabelle=f"r3cosint.{tabelle}",
            recht=recht,
        )
    )


async def _spaltenrecht(verbindung: AsyncConnection, tabelle: str, spalte: str) -> bool:
    return bool(
        await _skalar(
            verbindung,
            "SELECT has_column_privilege('r3cosint_anwendung', :tabelle, :spalte, 'UPDATE')",
            tabelle=f"r3cosint.{tabelle}",
            spalte=spalte,
        )
    )


TABELLENRECHTE = {
    "ermittlungsspur": {"SELECT", "INSERT"},
    "arbeitsspur": {"SELECT", "INSERT"},
    "kettenkopf": {"SELECT", "INSERT"},
    "fall": {"SELECT", "INSERT"},
    "fall_schluessel": {"SELECT", "INSERT"},
    "fallkategorie": {"SELECT"},
    "herkunft": {"INSERT", "SELECT"},
    "entitaet": {"INSERT", "SELECT"},
    "beziehung": {"INSERT", "SELECT"},
}


@pytest.mark.parametrize("tabelle", list(TABELLENRECHTE))
async def test_R3_F_008_rechte_der_anwendung_je_tabelle_nie_delete_oder_truncate(
    verbindung_anwendung: AsyncConnection, tabelle: str
) -> None:
    for recht in (
        "SELECT",
        "INSERT",
        "UPDATE",
        "DELETE",
        "TRUNCATE",
        "REFERENCES",
        "TRIGGER",
    ):
        erwartet = recht in TABELLENRECHTE[tabelle]
        assert await _recht(verbindung_anwendung, tabelle, recht) is erwartet, recht


async def test_R3_F_008_update_der_anwendung_allein_auf_die_benannten_spalten(
    verbindung_anwendung: AsyncConnection,
) -> None:
    for spalte in ("position", "pruefsumme"):
        assert await _spaltenrecht(verbindung_anwendung, "kettenkopf", spalte)
    for spalte in ("fall_kennung", "spur"):
        assert not await _spaltenrecht(verbindung_anwendung, "kettenkopf", spalte)
    for spalte in ("zustand", "geschlossen_am", "prueffrist_bis"):
        assert await _spaltenrecht(verbindung_anwendung, "fall", spalte)
    for spalte in ("kennung", "aktenzeichen", "rechtsregime", "eroeffnet_am"):
        assert not await _spaltenrecht(verbindung_anwendung, "fall", spalte)
    for tabelle in ("arbeitsspur", "ermittlungsspur"):
        assert not await _spaltenrecht(verbindung_anwendung, tabelle, "payload")


async def test_R3_F_008_die_anwendung_kann_die_tabelle_des_kettenkopfs_nicht_sperren(
    verbindung_anwendung: AsyncConnection,
) -> None:
    await verbindung_anwendung.rollback()
    meldung = await _scheitert(
        verbindung_anwendung, "LOCK TABLE r3cosint.kettenkopf IN ACCESS EXCLUSIVE MODE"
    )
    assert meldung.startswith("42501|")


# --- Abweisung -------------------------------------------------------------------------------------


@pytest.mark.parametrize("spur", SPUREN)
async def test_R3_F_008_update_delete_truncate_werden_abgewiesen_und_der_bestand_bleibt(
    fall_mit_ketten: "SynthetischerFall",
    eintraege_schreiben: Schreiben,
    verbindung_anwendung: AsyncConnection,
    verbindung_eigentuemer: AsyncConnection,
    spur: Spur,
) -> None:
    eintraege = await eintraege_schreiben(fall_mit_ketten, spur, 3)
    tabelle = f"r3cosint.{spur.value}"
    for sql in (
        f"UPDATE {tabelle} SET payload = '{{}}'",
        f"DELETE FROM {tabelle}",
        f"TRUNCATE {tabelle}",
    ):
        meldung = await _scheitert(verbindung_anwendung, sql)
        assert meldung.startswith("42501|"), sql
        meldung = await _scheitert(verbindung_eigentuemer, sql)
        assert meldung.startswith("P0001|"), sql
        assert f"{spur.value} ist ausschliesslich anfügbar" in meldung
    zeilen = await _skalar(verbindung_anwendung, f"SELECT count(*) FROM {tabelle}")
    assert zeilen == 3
    assert [e.position for e in eintraege] == [1, 2, 3]


async def test_R3_F_008_kettenkopf_delete_und_truncate_sind_fuer_beide_rollen_gesperrt(
    fall_mit_ketten: "SynthetischerFall",
    verbindung_anwendung: AsyncConnection,
    verbindung_eigentuemer: AsyncConnection,
) -> None:
    for sql in ("DELETE FROM r3cosint.kettenkopf", "TRUNCATE r3cosint.kettenkopf"):
        assert (await _scheitert(verbindung_anwendung, sql)).startswith("42501|")
        assert (await _scheitert(verbindung_eigentuemer, sql)).startswith("P0001|")
    assert (
        await _skalar(verbindung_anwendung, "SELECT count(*) FROM r3cosint.kettenkopf")
        == 2
    )


async def test_R3_F_008_kettenkopf_rueckt_nur_um_eins_vor_und_nur_mit_der_pruefsumme_der_zeile(
    fall_mit_ketten: "SynthetischerFall",
    eintraege_schreiben: Schreiben,
    verbindung_anwendung: AsyncConnection,
    verbindung_eigentuemer: AsyncConnection,
) -> None:
    eintraege = await eintraege_schreiben(fall_mit_ketten, Spur.ARBEITSSPUR, 2)
    fall = str(fall_mit_ketten.kennung)
    where = f"WHERE fall_kennung = CAST('{fall}' AS uuid) AND spur = 'arbeitsspur'"
    for verbindung in (verbindung_anwendung, verbindung_eigentuemer):
        meldung = await _scheitert(
            verbindung, f"UPDATE r3cosint.kettenkopf SET position = 4 {where}"
        )
        assert meldung.startswith("P0001|")
        meldung = await _scheitert(
            verbindung,
            f"UPDATE r3cosint.kettenkopf SET position = 3, pruefsumme = '{'a' * 64}' {where}",
        )
        assert meldung.startswith("P0001|")
    meldung = await _scheitert(
        verbindung_eigentuemer,
        f"UPDATE r3cosint.kettenkopf SET spur = 'ermittlungsspur' {where}",
    )
    assert meldung.startswith("P0001|")
    meldung = await _scheitert(
        verbindung_anwendung,
        f"UPDATE r3cosint.kettenkopf SET fall_kennung = CAST('{UUID(int=5)}' AS uuid) {where}",
    )
    assert meldung.startswith("42501|")
    stand = await _skalar(
        verbindung_anwendung,
        f"SELECT position || ':' || pruefsumme FROM r3cosint.kettenkopf {where}",
    )
    assert stand == f"2:{eintraege[-1].pruefsumme}"


async def test_R3_F_008_kettenkopf_insert_mit_falschem_anfangswert_oder_position_wird_abgewiesen(
    fall_anlegen: Callable[[], Awaitable["SynthetischerFall"]],
    verbindung_anwendung: AsyncConnection,
    verbindung_eigentuemer: AsyncConnection,
) -> None:
    neu = await fall_anlegen()
    await verbindung_eigentuemer.execute(
        text(
            "INSERT INTO r3cosint.fall (kennung, aktenzeichen, ermittelnde_person, "
            "rechtsgrundlage, rechtsregime, fallkategorie, zustand, eroeffnet_am) VALUES "
            "(CAST(:k AS uuid), 'TEST-SYNTH-ohne-kette', 'test.ermittlung', 'x', 'R1', "
            "'vergehen', 'aktiv', now())"
        ),
        {"k": str(UUID(int=77))},
    )
    await verbindung_eigentuemer.commit()
    richtig = kette_anfangswert(Spur.ARBEITSSPUR, UUID(int=77))
    einfuegen = (
        "INSERT INTO r3cosint.kettenkopf (fall_kennung, spur, position, pruefsumme) "
        "VALUES (CAST(:k AS uuid), 'arbeitsspur', :pos, :summe)"
    )
    for pos, summe in ((0, "b" * 64), (1, richtig)):
        meldung = await _scheitert(
            verbindung_anwendung, einfuegen, k=str(UUID(int=77)), pos=pos, summe=summe
        )
        assert meldung.startswith("P0001|")
    assert neu.kennung != UUID(int=77)
    await verbindung_anwendung.execute(
        text(einfuegen), {"k": str(UUID(int=77)), "pos": 0, "summe": richtig}
    )
    await verbindung_anwendung.commit()


# --- Einfügeprüfung und Prüfbedingungen ------------------------------------------------------------------


def _eintrag(
    spur: Spur, fall: UUID, position: int, vorgaenger: str, **aenderung: Any
) -> Eintrag:
    zeit = datetime(2026, 1, 15, 8, 30, 0, tzinfo=UTC)
    werte: dict[str, Any] = {
        "spur": spur,
        "kennung": neue_kennung(),
        "fall_kennung": fall,
        "position": position,
        "zeitpunkt": zeit,
        "person_kennung": "test.ermittlung",
        "eintragstyp": Eintragstyp(TYP[spur]),
        "kennzeichnung": Kennzeichnung.QUELLENAUSSAGE,
        "payload": "{}",
        "vorgaenger_pruefsumme": vorgaenger,
        "pruefsumme": "",
    }
    werte.update(aenderung)
    offen = Eintrag(**werte)
    from dataclasses import replace

    return replace(offen, pruefsumme=pruefsumme(offen))


_INSERT = (
    "INSERT INTO r3cosint.{tabelle} (kennung, fall_kennung, position, zeitpunkt, "
    "person_kennung, eintragstyp, kennzeichnung, payload, vorgaenger_pruefsumme, pruefsumme) "
    "VALUES (:kennung, :fall, :position, :zeit, :person, :typ, :kz, :payload, :vorg, :summe)"
)


async def _einfuegen(
    verbindung: AsyncConnection,
    e: Eintrag,
    tabelle: str | None = None,
    **ueberschrieben: Any,
) -> str:
    parameter: dict[str, Any] = {
        "kennung": e.kennung,
        "fall": e.fall_kennung,
        "position": e.position,
        "zeit": e.zeitpunkt,
        "person": e.person_kennung,
        "typ": e.eintragstyp.value,
        "kz": e.kennzeichnung.value,
        "payload": e.payload,
        "vorg": e.vorgaenger_pruefsumme,
        "summe": e.pruefsumme,
    }
    parameter.update(ueberschrieben)
    return await _scheitert(
        verbindung, _INSERT.format(tabelle=tabelle or e.spur.value), **parameter
    )


@pytest.mark.parametrize("spur", SPUREN)
async def test_R3_F_008_einfuegepruefung_weist_falsche_position_vorgaenger_und_pruefsumme_ab(
    fall_mit_ketten: "SynthetischerFall",
    verbindung_anwendung: AsyncConnection,
    spur: Spur,
) -> None:
    fall = fall_mit_ketten.kennung
    anfang = kette_anfangswert(spur, fall)
    for fehlerhaft in (
        _eintrag(spur, fall, 2, anfang),
        _eintrag(spur, fall, 1, "c" * 64),
    ):
        assert (await _einfuegen(verbindung_anwendung, fehlerhaft)).startswith("P0001|")
    gut = _eintrag(spur, fall, 1, anfang)
    assert (await _einfuegen(verbindung_anwendung, gut, summe="d" * 64)).startswith(
        "P0001|"
    )
    assert (await _einfuegen(verbindung_anwendung, gut, payload='{"x":1}')).startswith(
        "P0001|"
    )


@pytest.mark.parametrize("spur", SPUREN)
async def test_R3_F_008_pruefsumme_der_anderen_spur_wird_abgewiesen(
    fall_mit_ketten: "SynthetischerFall",
    verbindung_anwendung: AsyncConnection,
    spur: Spur,
) -> None:
    andere = Spur.ERMITTLUNGSSPUR if spur is Spur.ARBEITSSPUR else Spur.ARBEITSSPUR
    fall = fall_mit_ketten.kennung
    fuer_andere = _eintrag(andere, fall, 1, kette_anfangswert(spur, fall))
    gut = _eintrag(spur, fall, 1, kette_anfangswert(spur, fall))
    meldung = await _einfuegen(verbindung_anwendung, gut, summe=fuer_andere.pruefsumme)
    assert meldung.startswith("P0001|")


@pytest.mark.parametrize("spur", SPUREN)
async def test_R3_F_008_pruefbedingungen_der_spuren_sqlstate(
    fall_mit_ketten: "SynthetischerFall",
    verbindung_anwendung: AsyncConnection,
    spur: Spur,
) -> None:
    fall = fall_mit_ketten.kennung
    anfang = kette_anfangswert(spur, fall)
    andererTyp = "entitaet" if spur is Spur.ARBEITSSPUR else "fall_eroeffnet"
    # Typ ausserhalb des Vorrats dieser Tabelle: Prüfsumme stimmt, die Prüfbedingung weist ab.
    falscher_typ = _eintrag(spur, fall, 1, anfang, eintragstyp=Eintragstyp(andererTyp))
    assert (await _einfuegen(verbindung_anwendung, falscher_typ)).startswith("23514|")
    # Kennzeichnung fehlt (NULL): NOT NULL weist ab.
    gut = _eintrag(spur, fall, 1, anfang)
    assert (await _einfuegen(verbindung_anwendung, gut, kz=None)).startswith("23502|")
    # Kennzeichnung ausserhalb des Vorrats.
    falsch_kz = _eintrag(spur, fall, 1, anfang)
    assert (
        await _einfuegen(verbindung_anwendung, falsch_kz, kz="vermutung")
    ).startswith("P0001|")
    # Fall unbekannt.
    fremd = _eintrag(spur, UUID(int=404), 1, kette_anfangswert(spur, UUID(int=404)))
    assert (await _einfuegen(verbindung_anwendung, fremd)).startswith("23503|")
    # Zeit ausserhalb des Bereichs: spur_pruefsumme endet in der Einfügeprüfung mit 22008.
    for zeit in (
        datetime(1999, 12, 31, 23, 59, 59, 999999, tzinfo=UTC),
        datetime(9999, 1, 1, tzinfo=UTC),
    ):
        assert (await _einfuegen(verbindung_anwendung, gut, zeit=zeit)).startswith(
            "22008|"
        )
    assert (await _einfuegen(verbindung_anwendung, gut, person="Gross")).startswith(
        "P0001|"
    )
    assert (await _einfuegen(verbindung_anwendung, gut, payload="[]")).startswith(
        "P0001|"
    )


# --- Nachbesserungsrunde (ST-S12-01 bis -08) --------------------------------------------------------------

EIGENTUEMER = "r3cosint_eigentuemer"
ANWENDUNG = "r3cosint_anwendung"
ALLE_RECHTE_EIGENTUEMER = {
    "DELETE",
    "INSERT",
    "MAINTAIN",
    "REFERENCES",
    "SELECT",
    "TRIGGER",
    "TRUNCATE",
    "UPDATE",
}
TABELLEN_RECHTE_ANWENDUNG = {
    "ermittlungsspur": {"INSERT", "SELECT"},
    "arbeitsspur": {"INSERT", "SELECT"},
    "kettenkopf": {"INSERT", "SELECT"},
    "fall": {"INSERT", "SELECT"},
    "fall_schluessel": {"INSERT", "SELECT"},
    "fallkategorie": {"SELECT"},
    "herkunft": {"INSERT", "SELECT"},
    "entitaet": {"INSERT", "SELECT"},
    "beziehung": {"INSERT", "SELECT"},
}
SPALTEN_RECHTE_ANWENDUNG = {
    ("fall", "geschlossen_am"),
    ("fall", "prueffrist_bis"),
    ("fall", "zustand"),
    ("kettenkopf", "position"),
    ("kettenkopf", "pruefsumme"),
}


async def _acl(verbindung: AsyncConnection, sql: str) -> set[tuple[Any, ...]]:
    zeilen = (await verbindung.execute(text(sql))).all()
    await verbindung.rollback()
    return {tuple(z) for z in zeilen}


async def test_R3_F_008_rechtekatalog_nennt_die_vollstaendige_menge_der_berechtigten(
    verbindung_eigentuemer: AsyncConnection,
) -> None:
    # Tabellen: je Tabelle genau Eigentümer (alle Rechte) und Anwendung (die kleinste Menge).
    tabellen = await _acl(
        verbindung_eigentuemer,
        "SELECT c.relname, coalesce(g.rolname, 'PUBLIC'), a.privilege_type "
        "FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace, "
        "aclexplode(c.relacl) a LEFT JOIN pg_roles g ON g.oid = a.grantee "
        "WHERE n.nspname = 'r3cosint' AND c.relkind = 'r'",
    )
    erwartet = {
        (name, EIGENTUEMER, recht)
        for name in TABELLEN_RECHTE_ANWENDUNG
        for recht in ALLE_RECHTE_EIGENTUEMER
    } | {
        (name, ANWENDUNG, recht)
        for name, rechte in TABELLEN_RECHTE_ANWENDUNG.items()
        for recht in rechte
    }
    assert tabellen == erwartet
    # Spalten: UPDATE allein auf die fünf benannten Spalten, allein für die Anwendung.
    spalten = await _acl(
        verbindung_eigentuemer,
        "SELECT c.relname, t.attname, coalesce(g.rolname, 'PUBLIC'), a.privilege_type "
        "FROM pg_attribute t JOIN pg_class c ON c.oid = t.attrelid "
        "JOIN pg_namespace n ON n.oid = c.relnamespace, aclexplode(t.attacl) a "
        "LEFT JOIN pg_roles g ON g.oid = a.grantee WHERE n.nspname = 'r3cosint'",
    )
    assert spalten == {(t, s, ANWENDUNG, "UPDATE") for t, s in SPALTEN_RECHTE_ANWENDUNG}
    # Funktionen: EXECUTE für den Eigentümer auf alle sieben, für die Anwendung auf die drei.
    funktionen = await _acl(
        verbindung_eigentuemer,
        "SELECT p.proname, coalesce(g.rolname, 'PUBLIC'), a.privilege_type "
        "FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace, "
        "aclexplode(p.proacl) a LEFT JOIN pg_roles g ON g.oid = a.grantee "
        "WHERE n.nspname = 'r3cosint'",
    )
    assert funktionen == {(f, EIGENTUEMER, "EXECUTE") for f in FUNKTIONEN} | {
        (f, ANWENDUNG, "EXECUTE") for f in OEFFENTLICH
    }
    # Schema: nur USAGE für die Anwendung; Datenbank: CONNECT für beide Rollen, kein PUBLIC.
    schema = await _acl(
        verbindung_eigentuemer,
        "SELECT coalesce(g.rolname, 'PUBLIC'), a.privilege_type FROM pg_namespace n, "
        "aclexplode(n.nspacl) a LEFT JOIN pg_roles g ON g.oid = a.grantee "
        "WHERE n.nspname = 'r3cosint'",
    )
    assert schema == {
        (EIGENTUEMER, "USAGE"),
        (EIGENTUEMER, "CREATE"),
        (ANWENDUNG, "USAGE"),
    }
    datenbank = await _acl(
        verbindung_eigentuemer,
        "SELECT coalesce(g.rolname, 'PUBLIC'), a.privilege_type FROM pg_database d, "
        "aclexplode(d.datacl) a LEFT JOIN pg_roles g ON g.oid = a.grantee "
        "WHERE d.datname = current_database()",
    )
    assert {
        (rolle, recht)
        for rolle, recht in datenbank
        if rolle in (EIGENTUEMER, ANWENDUNG)
    } == {
        (EIGENTUEMER, "CONNECT"),
        (ANWENDUNG, "CONNECT"),
    }
    assert not any(rolle == "PUBLIC" for rolle, _ in datenbank)


async def test_R3_F_008_truncate_fall_cascade_als_eigentuemer_wird_von_den_spuren_abgewiesen(
    fall_mit_ketten: "SynthetischerFall",
    eintraege_schreiben: Schreiben,
    verbindung_eigentuemer: AsyncConnection,
) -> None:
    await eintraege_schreiben(fall_mit_ketten, Spur.ARBEITSSPUR, 2)
    meldung = await _scheitert(verbindung_eigentuemer, "TRUNCATE r3cosint.fall CASCADE")
    assert meldung.startswith("P0001|")
    assert "ausschliesslich anfügbar" in meldung
    anzahl = await _skalar(verbindung_eigentuemer, "SELECT count(*) FROM r3cosint.fall")
    assert anzahl == 1


async def test_R3_F_008_copy_mit_falschem_eintrag_wird_von_der_einfuegepruefung_abgewiesen(
    fall_mit_ketten: "SynthetischerFall", verbindung_anwendung: AsyncConnection
) -> None:
    spur = Spur.ARBEITSSPUR
    falsch = _eintrag(
        spur,
        fall_mit_ketten.kennung,
        2,
        kette_anfangswert(spur, fall_mit_ketten.kennung),
    )
    roh = await verbindung_anwendung.get_raw_connection()
    treiber: Any = roh.driver_connection
    with pytest.raises(
        Exception, match="Position folgt nicht auf den Kettenkopf"
    ) as fehler:
        await treiber.copy_records_to_table(
            "arbeitsspur",
            schema_name="r3cosint",
            columns=[
                "kennung",
                "fall_kennung",
                "position",
                "zeitpunkt",
                "person_kennung",
                "eintragstyp",
                "kennzeichnung",
                "payload",
                "vorgaenger_pruefsumme",
                "pruefsumme",
            ],
            records=[
                (
                    falsch.kennung,
                    falsch.fall_kennung,
                    falsch.position,
                    falsch.zeitpunkt,
                    falsch.person_kennung,
                    falsch.eintragstyp.value,
                    falsch.kennzeichnung.value,
                    falsch.payload,
                    falsch.vorgaenger_pruefsumme,
                    falsch.pruefsumme,
                )
            ],
        )
    assert getattr(fehler.value, "sqlstate", None) == "P0001"
    await verbindung_anwendung.rollback()
    assert (
        await _skalar(verbindung_anwendung, "SELECT count(*) FROM r3cosint.arbeitsspur")
        == 0
    )


@pytest.mark.parametrize(
    "funktion", ["spur_unveraenderlich", "spur_einfuegen_pruefen", "kettenkopf_pruefen"]
)
async def test_R3_F_008_direktaufruf_der_ausloeserfunktionen_als_anwendung_endet_mit_42501(
    verbindung_anwendung: AsyncConnection, funktion: str
) -> None:
    # Als Block, weil asyncpg den Ergebnistyp trigger nicht kennt; das Recht prüft die Ausführung.
    meldung = await _scheitert(
        verbindung_anwendung,
        f"DO $$ BEGIN PERFORM r3cosint.{funktion}(); END $$",
    )
    assert meldung.startswith("42501|")
    assert "permission denied for function" in meldung


async def test_R3_F_012_beide_rechenwege_gleich_unter_geaenderten_sitzungswerten(
    fall_mit_ketten: "SynthetischerFall",
    eintraege_schreiben: Schreiben,
    verbindung_anwendung: AsyncConnection,
) -> None:
    from r3cosint.spur.payload import Entitaet
    from r3cosint.spur.service import anfuegen, kette_pruefen, kette_pruefen_datenbank

    fall = fall_mit_ketten
    await eintraege_schreiben(fall, Spur.ERMITTLUNGSSPUR, 2)
    async with verbindung_anwendung.begin():
        await verbindung_anwendung.execute(
            text("SET LOCAL timezone = 'Pacific/Kiritimati'")
        )
        await verbindung_anwendung.execute(text("SET LOCAL datestyle = 'SQL, DMY'"))
        await verbindung_anwendung.execute(text("SET LOCAL extra_float_digits = -3"))
        await anfuegen(
            verbindung_anwendung,
            spur=Spur.ERMITTLUNGSSPUR,
            fall_kennung=fall.kennung,
            person_kennung="test.ermittlung",
            kennzeichnung=Kennzeichnung.QUELLENAUSSAGE,
            eingabe=Entitaet(
                fall_kennung=fall.kennung,
                entitaet_kennung=neue_kennung(),
                ftm_kennung="synth-x",
                ftm_schema="Person",
                herkunft_kennung=neue_kennung(),
                eigenschaften={"name": ("Erfundene Person",)},
                werkzeug="synth.werkzeug",
                erhoben_am=fall.uhr.zeitpunkt,
                erhebende_person="synth.erhebung",
                abfrage="TEST-SYNTH Abfrage",
            ),
            pseudonymisierer=fall.pseudonymisierer,
            uhr=fall.uhr,
        )
        anwendung = await kette_pruefen(verbindung_anwendung, fall.kennung)
        datenbank = await kette_pruefen_datenbank(verbindung_anwendung, fall.kennung)
    assert anwendung == datenbank
    assert anwendung[Spur.ERMITTLUNGSSPUR].unversehrt is True
    assert anwendung[Spur.ERMITTLUNGSSPUR].anzahl == 3


async def test_R3_F_008_wettlauf_ohne_sperre_genau_ein_eintrag_gewinnt_und_die_kette_bleibt_unversehrt(
    datenbank: "Testdatenbank",
    fall_mit_ketten: "SynthetischerFall",
    eintraege_schreiben: Schreiben,
) -> None:
    import asyncio

    from r3cosint.core.datenbank import engine_erzeugen
    from r3cosint.spur.service import kette_pruefen

    spur = Spur.ARBEITSSPUR
    fall = fall_mit_ketten.kennung
    erster = (await eintraege_schreiben(fall_mit_ketten, spur, 1))[0]
    a = _eintrag(spur, fall, 2, erster.pruefsumme)
    b = _eintrag(spur, fall, 2, erster.pruefsumme)
    assert a.pruefsumme != b.pruefsumme

    def parameter(e: Eintrag) -> dict[str, Any]:
        return {
            "kennung": e.kennung,
            "fall": e.fall_kennung,
            "position": e.position,
            "zeit": e.zeitpunkt,
            "person": e.person_kennung,
            "typ": e.eintragstyp.value,
            "kz": e.kennzeichnung.value,
            "payload": e.payload,
            "vorg": e.vorgaenger_pruefsumme,
            "summe": e.pruefsumme,
        }

    engines = [engine_erzeugen(datenbank.verbindung(ANWENDUNG)) for _ in range(2)]
    try:
        async with engines[0].connect() as ca, engines[1].connect() as cb:
            # Beide lesen den Kopf ohne FOR UPDATE; A fügt ein und rückt den Kopf vor, B wartet.
            await ca.execute(text(_INSERT.format(tabelle=spur.value)), parameter(a))
            await ca.execute(
                text(
                    "UPDATE r3cosint.kettenkopf SET position = 2, pruefsumme = :s "
                    "WHERE fall_kennung = :f AND spur = :spur"
                ),
                {"s": a.pruefsumme, "f": fall, "spur": spur.value},
            )
            aufgabe = asyncio.create_task(
                cb.execute(text(_INSERT.format(tabelle=spur.value)), parameter(b))
            )
            await asyncio.sleep(0.5)
            assert not aufgabe.done()
            await ca.commit()
            with pytest.raises(DBAPIError) as fehler:
                await aufgabe
            assert _sqlstate(fehler.value) == "23505"
            await cb.rollback()
    finally:
        for engine in engines:
            await engine.dispose()
    pruef = engine_erzeugen(datenbank.verbindung(ANWENDUNG))
    try:
        async with pruef.connect() as verbindung, verbindung.begin():
            befund = (await kette_pruefen(verbindung, fall))[spur]
    finally:
        await pruef.dispose()
    assert befund.unversehrt is True
    assert befund.anzahl == 2
    assert befund.letzte_pruefsumme == a.pruefsumme
