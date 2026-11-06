"""Abnahmetests R3-F-008 und R3-F-012 (ADR 0007, Festlegung S1.2, Zeile "Tests Abnahme").

R3-F-008 (Backlog, Abnahme): die nachträgliche Änderung eines Eintrags lässt die Kettenprüfung
fehlschlagen und benennt die Bruchstelle; das Entfernen eines Eintrags ebenso; ein
Aktualisierungs- oder Löschbefehl auf die Protokolltabelle wird abgewiesen.

R3-F-012 (Backlog, Abnahme): die Prüfung meldet für einen unversehrten Bestand "unversehrt" samt
Anzahl verifizierter Einträge und für einen manipulierten Bestand die Position des ersten Bruchs.

Massstab der Erwartungswerte: ADR 0007, Teil A, Festlegung S1.2, Zeilen "Befund" und "Ablauf und
Vorrang der Prüfung" (Positionsregel DF-S12-09, Felder letzte_pruefsumme und kopf_position
DF-S12-11). Geschrieben vor dem Bau vom Dynamic Software Tester; die Tests werden nicht an die
Umsetzung angepasst, Abweichungen gehen an den Koordinator.

Alle Werte sind erfunden (5.15). Manipulationen laufen allein über die Hilfe manipulieren aus
backend/tests/conftest.py; dieser Test öffnet selbst keine Verbindung mit erweiterten Rechten.
Die Hilfe nimmt keine Bindeparameter; die eingesetzten Werte (Kennungen, Prüfsummen, Positionen)
stammen aus diesem Test und werden vor dem Einsetzen gegen ein enges Muster geprüft.
"""

import hashlib
import re
from collections.abc import Awaitable, Callable, Sequence
from typing import Any, Protocol
from uuid import UUID, uuid4

import pytest
from sqlalchemy import text
from sqlalchemy.exc import DBAPIError
from sqlalchemy.ext.asyncio import AsyncConnection

from r3cosint.spur.service import (
    Befund,
    Bruchgrund,
    Eintrag,
    Spur,
    kette_pruefen,
    kette_pruefen_datenbank,
)

pytestmark = [pytest.mark.anyio, pytest.mark.abnahme]

# Länge der manipulierten Kette und der Kette der anderen Spur desselben Falls.
N = 5
N_ANDERE = 3

EINTRAGSTYP = {Spur.ARBEITSSPUR: "fall_eroeffnet", Spur.ERMITTLUNGSSPUR: "entitaet"}
ANDERE = {
    Spur.ARBEITSSPUR: Spur.ERMITTLUNGSSPUR,
    Spur.ERMITTLUNGSSPUR: Spur.ARBEITSSPUR,
}

_MUSTER = {
    "tabelle": re.compile(r"^(ermittlungsspur|arbeitsspur)$"),
    "spur": re.compile(r"^(ermittlungsspur|arbeitsspur)$"),
    "eintragstyp": re.compile(r"^(fall_eroeffnet|entitaet)$"),
    "fall": re.compile(
        r"^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$"
    ),
    "kennung": re.compile(
        r"^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$"
    ),
    "pruefsumme": re.compile(r"^[0-9a-f]{64}$"),
    "vorgaenger": re.compile(r"^[0-9a-f]{64}$"),
    "position": re.compile(r"^[0-9]{1,4}$"),
}


_PLATZHALTER = re.compile(r"\{[a-z_]+\}")


class FallMitKennung(Protocol):
    """Was diese Tests vom SynthetischerFall der Fixture brauchen."""

    @property
    def kennung(self) -> UUID: ...


Schreiben = Callable[[Any, Spur, int], Awaitable[list[Eintrag]]]
Manipulieren = Callable[..., Awaitable[None]]


def _sql(vorlage: str, **werte: object) -> str:
    """Setzt geprüfte Werte in eine feste Vorlage ein (die Hilfe nimmt keine Bindeparameter)."""
    ergebnis = vorlage
    for name, wert in werte.items():
        textwert = str(wert)
        if not _MUSTER[name].fullmatch(textwert):
            raise ValueError(f"Wert für {name} ausserhalb des Musters")
        ergebnis = ergebnis.replace("{" + name + "}", textwert)
    if _PLATZHALTER.search(ergebnis):
        raise ValueError("Vorlage mit nicht ersetztem Platzhalter")
    return ergebnis


def _anfangswert(spur: Spur, fall: UUID) -> str:
    """Anfangswert nach Nr. 16, unabhängig von spur.kette berechnet."""
    return hashlib.sha256(f"r3cosint-spur-1|{spur.value}|{fall}".encode()).hexdigest()


def _befund(
    spur: Spur,
    fall: UUID,
    *,
    anzahl: int,
    letzte_pruefsumme: str,
    kopf_position: int | None,
    position: int | None = None,
    grund: Bruchgrund | None = None,
) -> Befund:
    return Befund(
        spur=spur,
        fall_kennung=fall,
        unversehrt=position is None,
        anzahl=anzahl,
        position=position,
        grund=grund,
        letzte_pruefsumme=letzte_pruefsumme,
        kopf_position=kopf_position,
    )


def _ps(eintraege: Sequence[Eintrag], spur: Spur, fall: UUID, position: int) -> str:
    """Prüfsumme des Eintrags an position (1-basiert); bei 0 der Anfangswert."""
    if position == 0:
        return _anfangswert(spur, fall)
    return eintraege[position - 1].pruefsumme


def _unversehrt(spur: Spur, fall: UUID, eintraege: Sequence[Eintrag]) -> Befund:
    return _befund(
        spur,
        fall,
        anzahl=len(eintraege),
        letzte_pruefsumme=_ps(eintraege, spur, fall, len(eintraege)),
        kopf_position=len(eintraege),
    )


async def _bestand(
    verbindung: AsyncConnection, fall: UUID
) -> dict[str, list[tuple[Any, ...]]]:
    """Alle Zeilen beider Spuren und des Kettenkopfs dieses Falls, geordnet."""
    stand: dict[str, list[tuple[Any, ...]]] = {}
    async with verbindung.begin():
        for spur in Spur:
            vorlage = (
                "SELECT kennung, fall_kennung, position, zeitpunkt, person_kennung, eintragstyp, "
                "kennzeichnung, payload, vorgaenger_pruefsumme, pruefsumme "
                "FROM r3cosint.{tabelle} "
                "WHERE fall_kennung = :fall ORDER BY position, kennung"
            )
            zeilen = await verbindung.execute(
                text(_sql(vorlage, tabelle=spur.value)), {"fall": fall}
            )
            stand[spur.value] = [tuple(z) for z in zeilen]
        kopf = await verbindung.execute(
            text(
                "SELECT fall_kennung, spur, position, pruefsumme FROM r3cosint.kettenkopf "
                "WHERE fall_kennung = :fall ORDER BY spur"
            ),
            {"fall": fall},
        )
        stand["kettenkopf"] = [tuple(z) for z in kopf]
    return stand


async def _pruefen_beide_wege(
    verbindung: AsyncConnection, fall: UUID
) -> tuple[dict[Spur, Befund], dict[Spur, Befund]]:
    """Beide Rechenwege, je in eigener Transaktion der Anwendung; der Bestand bleibt gleich."""
    vorher = await _bestand(verbindung, fall)
    async with verbindung.begin():
        anwendungsweg = await kette_pruefen(verbindung, fall)
    async with verbindung.begin():
        datenbankweg = await kette_pruefen_datenbank(verbindung, fall)
    assert await _bestand(verbindung, fall) == vorher, (
        "die Prüfung hat den Bestand verändert"
    )
    return anwendungsweg, datenbankweg


async def _erwarten(
    verbindung: AsyncConnection,
    fall: UUID,
    erwartet: dict[Spur, Befund],
) -> None:
    anwendungsweg, datenbankweg = await _pruefen_beide_wege(verbindung, fall)
    assert anwendungsweg == erwartet
    assert datenbankweg == erwartet
    assert datenbankweg == anwendungsweg


def _sqlstate(fehler: DBAPIError) -> str | None:
    return getattr(fehler.orig, "sqlstate", None)


# ---------------------------------------------------------------------------------------------
# R3-F-008
# ---------------------------------------------------------------------------------------------

FAELLE_008_BRUCH = [
    "aendern_erster",
    "aendern_mitte",
    "aendern_letzter",
    "entfernen_mitte",
    "entfernen_letzter",
]
FAELLE_008_ABWEISUNG = [
    f"{befehl}_als_{rolle}"
    for befehl in ("update", "delete", "truncate")
    for rolle in ("anwendung", "eigentuemer")
]
FAELLE_008 = [*FAELLE_008_BRUCH, *FAELLE_008_ABWEISUNG, "gegenprobe_anfuegen"]

ABWEISUNG_SQL = {
    "update": "UPDATE r3cosint.{tabelle} SET person_kennung = 'test.abgewiesen' "
    "WHERE fall_kennung = '{fall}' AND position = 3",
    "delete": "DELETE FROM r3cosint.{tabelle} WHERE fall_kennung = '{fall}' AND position = 3",
    "truncate": "TRUNCATE r3cosint.{tabelle}",
}


@pytest.mark.parametrize("fall_art", FAELLE_008)
@pytest.mark.parametrize("spur", list(Spur), ids=[s.value for s in Spur])
async def test_R3_F_008_kette_bricht_bei_aenderung(
    spur: Spur,
    fall_art: str,
    fall_mit_ketten: FallMitKennung,
    eintraege_schreiben: Schreiben,
    manipulieren: Manipulieren,
    verbindung_anwendung: AsyncConnection,
    verbindung_eigentuemer: AsyncConnection,
) -> None:
    fall = fall_mit_ketten.kennung
    andere = ANDERE[spur]
    eintraege = await eintraege_schreiben(fall_mit_ketten, spur, N)
    eintraege_andere = await eintraege_schreiben(fall_mit_ketten, andere, N_ANDERE)
    assert [e.position for e in eintraege] == list(range(1, N + 1))
    unversehrt_andere = _unversehrt(andere, fall, eintraege_andere)
    werte: dict[str, object] = {"tabelle": spur.value, "fall": fall}

    if fall_art in FAELLE_008_BRUCH:
        if fall_art == "aendern_erster":
            bruch = 1
            sql = (
                "UPDATE r3cosint.{tabelle} SET person_kennung = 'test.manipuliert' "
                "WHERE fall_kennung = '{fall}' AND position = 1"
            )
        elif fall_art == "aendern_mitte":
            bruch = 3
            sql = (
                "UPDATE r3cosint.{tabelle} SET zeitpunkt = zeitpunkt + interval '1 microsecond' "
                "WHERE fall_kennung = '{fall}' AND position = 3"
            )
        elif fall_art == "aendern_letzter":
            bruch = N
            sql = (
                "UPDATE r3cosint.{tabelle} SET kennzeichnung = CASE kennzeichnung "
                "WHEN 'quellenaussage' THEN 'schlussfolgerung' ELSE 'quellenaussage' END "
                "WHERE fall_kennung = '{fall}' AND position = 5"
            )
        elif fall_art == "entfernen_mitte":
            bruch = 3
            sql = "DELETE FROM r3cosint.{tabelle} WHERE fall_kennung = '{fall}' AND position = 3"
        else:  # entfernen_letzter
            bruch = N
            sql = "DELETE FROM r3cosint.{tabelle} WHERE fall_kennung = '{fall}' AND position = 5"
        await manipulieren(_sql(sql, **werte))
        grund = {
            "aendern_erster": Bruchgrund.INHALT_GEAENDERT,
            "aendern_mitte": Bruchgrund.INHALT_GEAENDERT,
            "aendern_letzter": Bruchgrund.INHALT_GEAENDERT,
            "entfernen_mitte": Bruchgrund.LUECKE,
            "entfernen_letzter": Bruchgrund.KOPF_ABWEICHEND,
        }[fall_art]
        erwartet = _befund(
            spur,
            fall,
            anzahl=bruch - 1,
            letzte_pruefsumme=_ps(eintraege, spur, fall, bruch - 1),
            kopf_position=N,
            position=bruch,
            grund=grund,
        )
        anwendungsweg, datenbankweg = await _pruefen_beide_wege(
            verbindung_anwendung, fall
        )
        # Die Prüfung schlägt fehl und benennt die Stelle (Backlog R3-F-008).
        assert anwendungsweg[spur].unversehrt is False
        assert anwendungsweg[spur].position == bruch
        assert anwendungsweg == {spur: erwartet, andere: unversehrt_andere}
        assert datenbankweg == anwendungsweg
        return

    if fall_art in FAELLE_008_ABWEISUNG:
        befehl, rolle = fall_art.split("_als_")
        verbindung = (
            verbindung_anwendung if rolle == "anwendung" else verbindung_eigentuemer
        )
        vorher = await _bestand(verbindung_anwendung, fall)
        with pytest.raises(DBAPIError) as ausnahme:
            async with verbindung.begin():
                await verbindung.execute(text(_sql(ABWEISUNG_SQL[befehl], **werte)))
        if rolle == "anwendung":
            assert _sqlstate(ausnahme.value) == "42501", str(ausnahme.value)
        else:
            assert _sqlstate(ausnahme.value) == "P0001", str(ausnahme.value)
            assert f"r3cosint: {spur.value} ist ausschliesslich anfügbar" in str(
                ausnahme.value
            )
        assert await _bestand(verbindung_anwendung, fall) == vorher
        await _erwarten(
            verbindung_anwendung,
            fall,
            {spur: _unversehrt(spur, fall, eintraege), andere: unversehrt_andere},
        )
        return

    # Gegenprobe: Anfügen läuft durch, der unversehrte Bestand besteht die Prüfung.
    await _erwarten(
        verbindung_anwendung,
        fall,
        {spur: _unversehrt(spur, fall, eintraege), andere: unversehrt_andere},
    )
    neu = await eintraege_schreiben(fall_mit_ketten, spur, 1)
    assert len(neu) == 1
    assert neu[0].position == N + 1
    assert neu[0].vorgaenger_pruefsumme == eintraege[-1].pruefsumme
    await _erwarten(
        verbindung_anwendung,
        fall,
        {spur: _unversehrt(spur, fall, [*eintraege, *neu]), andere: unversehrt_andere},
    )


# ---------------------------------------------------------------------------------------------
# R3-F-012
# ---------------------------------------------------------------------------------------------

FAELLE_012 = [
    "unversehrt",
    "leer",
    "aenderung",
    "entfernen",
    "einfuegen",
    "vertauschen",
    "abschneiden_letzter",
    "abschneiden_zwei",
    "eintrag_hinter_kopf",
]


async def _manipulation_012(
    fall_art: str,
    spur: Spur,
    fall: UUID,
    eintraege: Sequence[Eintrag],
    manipulieren: Manipulieren,
) -> Befund:
    """Stellt die Manipulation her und liefert den erwarteten Befund der Spur."""
    werte: dict[str, object] = {"tabelle": spur.value, "fall": fall}

    def bruch(position: int, grund: Bruchgrund, anzahl: int, kopf: int = N) -> Befund:
        return _befund(
            spur,
            fall,
            anzahl=anzahl,
            letzte_pruefsumme=_ps(eintraege, spur, fall, anzahl),
            kopf_position=kopf,
            position=position,
            grund=grund,
        )

    if fall_art == "aenderung":
        # Änderung eines Felds ohne Nachrechnen: inhalt_geaendert an dieser Position.
        await manipulieren(
            _sql(
                "UPDATE r3cosint.{tabelle} SET person_kennung = 'test.manipuliert' "
                "WHERE fall_kennung = '{fall}' AND position = 3",
                **werte,
            )
        )
        return bruch(3, Bruchgrund.INHALT_GEAENDERT, 2)
    if fall_art == "entfernen":
        # Entfernen in der Mitte: luecke an der entfernten Position.
        await manipulieren(
            _sql(
                "DELETE FROM r3cosint.{tabelle} WHERE fall_kennung = '{fall}' AND position = 3",
                **werte,
            )
        )
        return bruch(3, Bruchgrund.LUECKE, 2)
    if fall_art == "einfuegen":
        # Einfügen mit neu vergebenen Positionen (3..5 werden 4..6, neuer Eintrag an 3, nicht
        # nachgerechnet): inhalt_geaendert an der ersten berührten Position 3. Der Umweg über
        # +100 hält UNIQUE (fall_kennung, position) bei jeder Zeile ein.
        for vorlage in (
            "UPDATE r3cosint.{tabelle} SET position = position + 100 "
            "WHERE fall_kennung = '{fall}' AND position >= 3",
            "UPDATE r3cosint.{tabelle} SET position = position - 99 "
            "WHERE fall_kennung = '{fall}' AND position > 100",
        ):
            await manipulieren(_sql(vorlage, **werte))
        await manipulieren(
            _sql(
                "INSERT INTO r3cosint.{tabelle} (kennung, fall_kennung, position, zeitpunkt, "
                "person_kennung, eintragstyp, kennzeichnung, payload, vorgaenger_pruefsumme, "
                "pruefsumme) VALUES ('{kennung}', "
                "'{fall}', 3, '2026-01-15 09:00:00+00', 'test.eingefuegt', '{eintragstyp}', "
                "'quellenaussage', '{\"eingefuegt\":\"synthetisch\"}', '{vorgaenger}', "
                "'{pruefsumme}')",
                **werte,
                kennung=uuid4(),
                eintragstyp=EINTRAGSTYP[spur],
                vorgaenger=eintraege[1].pruefsumme,
                pruefsumme="e" * 64,
            )
        )
        return bruch(3, Bruchgrund.INHALT_GEAENDERT, 2)
    if fall_art == "vertauschen":
        # Vertauschen der Einträge 2 und 3 (Positionen neu vergeben, nicht nachgerechnet):
        # inhalt_geaendert an der ersten berührten Position 2.
        for vorlage in (
            "UPDATE r3cosint.{tabelle} SET position = 1000 "
            "WHERE fall_kennung = '{fall}' AND position = 2",
            "UPDATE r3cosint.{tabelle} SET position = 2 "
            "WHERE fall_kennung = '{fall}' AND position = 3",
            "UPDATE r3cosint.{tabelle} SET position = 3 "
            "WHERE fall_kennung = '{fall}' AND position = 1000",
        ):
            await manipulieren(_sql(vorlage, **werte))
        return bruch(2, Bruchgrund.INHALT_GEAENDERT, 1)
    if fall_art == "abschneiden_letzter":
        # Kopf in 5, a = 4: kopf_abweichend an a + 1 = 5.
        await manipulieren(
            _sql(
                "DELETE FROM r3cosint.{tabelle} WHERE fall_kennung = '{fall}' AND position = 5",
                **werte,
            )
        )
        return bruch(5, Bruchgrund.KOPF_ABWEICHEND, 4)
    if fall_art == "abschneiden_zwei":
        # Kopf in 5, a = 3: kopf_abweichend an der ersten fehlenden Position a + 1 = 4.
        await manipulieren(
            _sql(
                "DELETE FROM r3cosint.{tabelle} WHERE fall_kennung = '{fall}' AND position >= 4",
                **werte,
            )
        )
        return bruch(4, Bruchgrund.KOPF_ABWEICHEND, 3)
    if fall_art == "eintrag_hinter_kopf":
        # Kopf auf Position 4 mit der Prüfsumme von Eintrag 4 zurückgesetzt: Eintrag 5 steht
        # stimmig verkettet hinter dem Kopf. kopf.position (4) < a (5): kopf_abweichend an
        # kopf.position + 1 = 5, anzahl kopf.position = 4, kopf_position 4. Lesart von
        # letzte_pruefsumme hier: Prüfsumme des Eintrags an Position anzahl (offene Frage im
        # Bericht des Dynamic Software Testers).
        await manipulieren(
            _sql(
                "UPDATE r3cosint.kettenkopf SET position = {position}, "
                "pruefsumme = '{pruefsumme}' WHERE fall_kennung = '{fall}' AND spur = '{spur}'",
                fall=fall,
                spur=spur.value,
                position=N - 1,
                pruefsumme=eintraege[N - 2].pruefsumme,
            )
        )
        return bruch(5, Bruchgrund.KOPF_ABWEICHEND, 4, kopf=N - 1)
    raise AssertionError(f"unbekannter Fall {fall_art}")


@pytest.mark.parametrize("fall_art", FAELLE_012)
@pytest.mark.parametrize("spur", list(Spur), ids=[s.value for s in Spur])
async def test_R3_F_012_pruefung_meldet_bruch(
    spur: Spur,
    fall_art: str,
    fall_mit_ketten: FallMitKennung,
    eintraege_schreiben: Schreiben,
    manipulieren: Manipulieren,
    verbindung_anwendung: AsyncConnection,
) -> None:
    fall = fall_mit_ketten.kennung
    andere = ANDERE[spur]
    anzahl = 0 if fall_art == "leer" else N
    eintraege = (
        await eintraege_schreiben(fall_mit_ketten, spur, anzahl) if anzahl else []
    )
    eintraege_andere = await eintraege_schreiben(fall_mit_ketten, andere, N_ANDERE)
    unversehrt_andere = _unversehrt(andere, fall, eintraege_andere)

    if fall_art in ("unversehrt", "leer"):
        # Unversehrt mit Anzahl der Einträge dieser Spur und dieses Falls; leer: Anzahl 0,
        # letzte_pruefsumme der Anfangswert, Kopf in Position 0 (W1-53).
        erwartet = _unversehrt(spur, fall, eintraege)
        if fall_art == "leer":
            assert erwartet.anzahl == 0
            assert erwartet.letzte_pruefsumme == _anfangswert(spur, fall)
            assert erwartet.kopf_position == 0
    else:
        erwartet = await _manipulation_012(
            fall_art, spur, fall, eintraege, manipulieren
        )

    anwendungsweg, datenbankweg = await _pruefen_beide_wege(verbindung_anwendung, fall)
    assert anwendungsweg == {spur: erwartet, andere: unversehrt_andere}
    assert datenbankweg == anwendungsweg
