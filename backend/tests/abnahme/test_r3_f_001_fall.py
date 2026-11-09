"""Abnahmetests R3-F-001 (ADR 0007, Festlegung S1.3, Zeile "Tests Abnahme").

R3-F-001 (Backlog, Abnahme `R3-F-001_fall_traegt_regime`): ein Fall lässt sich nur mit gesetztem
Rechtsregime (R1 StPO oder R2 PolG) eröffnen; beim Schliessen wird der Zeitpunkt festgeschrieben
und die Prüffrist der Aufbewahrungsklasse beginnt; beide Vorgänge erzeugen je einen
Protokolleintrag.

R3-F-001 (Backlog, Abnahme `R3-F-001_aktenzeichen_eindeutig`): eine Eröffnung mit einem
Aktenzeichen, das nach der Angleichung (E-S13-05 b) zeichengleich ist mit dem Aktenzeichen eines
bestehenden, nicht gelöschten Falls (aktiv oder abgeschlossen), wird abgewiesen; danach besteht
kein neuer Fall und kein Protokolleintrag zu dieser Eröffnung, beide Protokollspuren des
bestehenden Falls sind unverändert (gleiche Anzahl, Kettenprüfung unversehrt); eine Eröffnung mit
einem anderen Aktenzeichen gelingt.

Massstab der Erwartungswerte: ADR 0007, Teil A, Festlegung S1.3 (Zeilen fall.eingabe,
fall.service Eröffnen und Schliessen, fall.store Abweisungswege, Tests Abnahme) und Festlegung
S1.2 (Kette, Nutzlast, Zeitform YYYY-MM-DDTHH:MM:SS.ffffffZ). Die Prüffristen sind von Hand aus
den Startwerten der Revision 0002 gerechnet (nicht über core.zeit); der Test gleicht die
Startwerte der beteiligten Kategorien zuerst mit der Tabelle fallkategorie ab. Geschrieben vor dem
Bau vom Dynamic Software Tester; die Tests werden nicht an die Umsetzung angepasst, Abweichungen
gehen an den Koordinator.

Alle Werte sind erfunden (5.15). Geschrieben wird allein über fall.service; gelesen über
fall.service, spur.service und SQL-Lesezugriffe der Anwendungsrolle. Jeder Vorgang läuft in einer
eigenen Klammer verbindung.begin(); eine Abweisung verlässt die Klammer als Ausnahme und rollt
damit zurück (Lesart der Festlegung, Zeile Eröffnen: "der Aufrufer rollt mit dem Ende seiner
Klammer zurück").
"""

import json
from dataclasses import dataclass
from datetime import UTC, datetime, timedelta, timezone
from typing import Any
from uuid import UUID

import pytest
from pydantic import ValidationError
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncConnection

from r3cosint.core.fehler import EindeutigkeitsFehler, ZustandsFehler
from r3cosint.fall.service import (
    Eroeffnung,
    Fall,
    Fallzustand,
    Rechtsregime,
    eroeffnen,
    fall_lesen,
    ketten_aller_faelle_pruefen,
    schliessen,
)
from r3cosint.spur.service import Befund, Spur, kette_pruefen, kette_pruefen_datenbank

pytestmark = [pytest.mark.anyio, pytest.mark.abnahme]

PERSON = "test.ermittlung"
ERMITTELNDE_PERSON = "test.fallfuehrung"
RECHTSGRUNDLAGE = "synthetisch,  ohne\tRechtsgrundlage "
RECHTSGRUNDLAGE_ANGEGLICHEN = "synthetisch, ohne Rechtsgrundlage"

# Startwerte der Revision 0002 (0002_fall_startwerte.sql), als Zahlen aus dem Test.
STARTWERTE = {"vergehen": 84, "uebertretung": 36, "nichtanhandnahme_einstellung": 12}

_BESTAND_SQL = {
    "fall": "SELECT kennung, aktenzeichen, rechtsregime, fallkategorie, zustand, eroeffnet_am, "
    "geschlossen_am, prueffrist_bis FROM r3cosint.fall ORDER BY kennung",
    "fall_schluessel": "SELECT fall_kennung, octet_length(schluessel) "
    "FROM r3cosint.fall_schluessel ORDER BY fall_kennung",
    "kettenkopf": "SELECT fall_kennung, spur, position, pruefsumme FROM r3cosint.kettenkopf "
    "ORDER BY fall_kennung, spur",
    "arbeitsspur": "SELECT kennung, fall_kennung, position, zeitpunkt, person_kennung, "
    "eintragstyp, kennzeichnung, payload, vorgaenger_pruefsumme, pruefsumme "
    "FROM r3cosint.arbeitsspur ORDER BY fall_kennung, position",
    "ermittlungsspur": "SELECT kennung, fall_kennung, position, zeitpunkt, person_kennung, "
    "eintragstyp, kennzeichnung, payload, vorgaenger_pruefsumme, pruefsumme "
    "FROM r3cosint.ermittlungsspur ORDER BY fall_kennung, position",
}

_EINTRAEGE_SQL = {
    Spur.ARBEITSSPUR: "SELECT position, zeitpunkt, person_kennung, eintragstyp, kennzeichnung, "
    "payload FROM r3cosint.arbeitsspur WHERE fall_kennung = :fall ORDER BY position",
    Spur.ERMITTLUNGSSPUR: "SELECT position, zeitpunkt, person_kennung, eintragstyp, "
    "kennzeichnung, payload FROM r3cosint.ermittlungsspur WHERE fall_kennung = :fall "
    "ORDER BY position",
}


@dataclass
class VerstellbareUhr:
    """Uhr mit einstellbarem Zeitpunkt; Eröffnen und Schliessen laufen zu verschiedenen Zeiten."""

    zeitpunkt: datetime

    def jetzt(self) -> datetime:
        """Liefert den eingestellten Zeitpunkt."""
        return self.zeitpunkt


def _utc(
    jahr: int, monat: int, tag: int, h: int = 0, m: int = 0, s: int = 0, us: int = 0
) -> datetime:
    return datetime(jahr, monat, tag, h, m, s, us, tzinfo=UTC)


def _eroeffnung(
    aktenzeichen: str,
    *,
    rechtsregime: Rechtsregime = Rechtsregime.R1,
    fallkategorie: str = "vergehen",
) -> Eroeffnung:
    return Eroeffnung(
        aktenzeichen=aktenzeichen,
        rechtsgrundlage=RECHTSGRUNDLAGE,
        rechtsregime=rechtsregime,
        fallkategorie=fallkategorie,
        ermittelnde_person=ERMITTELNDE_PERSON,
    )


async def _eroeffnen(
    verbindung: AsyncConnection, eroeffnung: Eroeffnung, uhr: VerstellbareUhr
) -> Fall:
    async with verbindung.begin():
        return await eroeffnen(
            verbindung, eroeffnung=eroeffnung, person_kennung=PERSON, uhr=uhr
        )


async def _schliessen(
    verbindung: AsyncConnection, fall: UUID, uhr: VerstellbareUhr
) -> Fall:
    async with verbindung.begin():
        return await schliessen(
            verbindung, fall_kennung=fall, person_kennung=PERSON, uhr=uhr
        )


async def _bestand(verbindung: AsyncConnection) -> dict[str, list[tuple[Any, ...]]]:
    """Alle Zeilen der Falltabellen, des Kettenkopfs und beider Spuren (ohne Schlüsselbytes)."""
    stand: dict[str, list[tuple[Any, ...]]] = {}
    async with verbindung.begin():
        for name, sql in _BESTAND_SQL.items():
            stand[name] = [tuple(z) for z in await verbindung.execute(text(sql))]
    return stand


async def _eintraege(
    verbindung: AsyncConnection, fall: UUID, spur: Spur
) -> list[dict[str, Any]]:
    async with verbindung.begin():
        zeilen = await verbindung.execute(text(_EINTRAEGE_SQL[spur]), {"fall": fall})
        return [dict(z._mapping) for z in zeilen]


async def _fallzeile(verbindung: AsyncConnection, fall: UUID) -> dict[str, Any]:
    async with verbindung.begin():
        zeile = (
            await verbindung.execute(
                text(
                    "SELECT rechtsregime, fallkategorie, zustand, eroeffnet_am, geschlossen_am, "
                    "prueffrist_bis, aktenzeichen FROM r3cosint.fall WHERE kennung = :fall"
                ),
                {"fall": fall},
            )
        ).one()
        return dict(zeile._mapping)


async def _monate_der_kategorie(verbindung: AsyncConnection, kategorie: str) -> int:
    async with verbindung.begin():
        wert = (
            await verbindung.execute(
                text(
                    "SELECT erste_pruefung_monate FROM r3cosint.fallkategorie "
                    "WHERE kennung = :k"
                ),
                {"k": kategorie},
            )
        ).scalar_one()
    assert isinstance(wert, int)
    return wert


async def _ketten_unversehrt(
    verbindung: AsyncConnection, fall: UUID, *, arbeitsspur: int
) -> None:
    """Beide Rechenwege, je in eigener Transaktion: unversehrt, Anzahl und Kopf wie erwartet."""
    async with verbindung.begin():
        anwendungsweg = await kette_pruefen(verbindung, fall)
    async with verbindung.begin():
        datenbankweg = await kette_pruefen_datenbank(verbindung, fall)
    erwartet = {Spur.ARBEITSSPUR: arbeitsspur, Spur.ERMITTLUNGSSPUR: 0}
    for weg in (anwendungsweg, datenbankweg):
        assert set(weg) == set(Spur)
        for spur, anzahl in erwartet.items():
            befund: Befund = weg[spur]
            assert befund.unversehrt, (spur, befund)
            assert befund.anzahl == anzahl, (spur, befund)
            assert befund.kopf_position == anzahl, (spur, befund)
            assert befund.position is None
            assert befund.grund is None
    assert anwendungsweg == datenbankweg


def _zeit_text(zeitpunkt: datetime) -> str:
    """Erwartete Zeitform der Nutzlast (Nr. 18), von Hand gebildet."""
    u = zeitpunkt.astimezone(UTC)
    return (
        f"{u.year:04d}-{u.month:02d}-{u.day:02d}T{u.hour:02d}:{u.minute:02d}:"
        f"{u.second:02d}.{u.microsecond:06d}Z"
    )


def _ohne_klartext(nutzlast: str, *klartexte: str) -> None:
    for wert in klartexte:
        assert wert not in nutzlast, "Klartext in der Nutzlast"
        assert wert.casefold() not in nutzlast.casefold(), "Klartext in der Nutzlast"


def _ist_utc(zeitpunkt: datetime | None) -> None:
    assert zeitpunkt is not None
    assert zeitpunkt.utcoffset() == timedelta(0)


# ---------------------------------------------------------------------------------------------
# R3-F-001_fall_traegt_regime
# ---------------------------------------------------------------------------------------------


@dataclass(frozen=True)
class Ablauf:
    """Eröffnen zu eroeffnet, Schliessen zu geschlossen; prueffrist von Hand gerechnet."""

    rechtsregime: Rechtsregime
    fallkategorie: str
    eroeffnet: datetime
    geschlossen: datetime
    prueffrist: datetime


ABLAEUFE = {
    # 84 Kalendermonate; Uhrzeit und Mikrosekunden bleiben.
    "R1_vergehen": Ablauf(
        Rechtsregime.R1,
        "vergehen",
        _utc(2026, 1, 15, 8, 30, 0, 123456),
        _utc(2026, 3, 10, 14, 5, 6, 654321),
        _utc(2033, 3, 10, 14, 5, 6, 654321),
    ),
    # 31. Januar plus 36 Kalendermonate ist der 31. Januar (30 Tage je Monat ergäben anderes).
    "R2_uebertretung_31_januar": Ablauf(
        Rechtsregime.R2,
        "uebertretung",
        _utc(2026, 12, 1, 7, 0, 0),
        _utc(2027, 1, 31, 23, 59, 59, 999999),
        _utc(2030, 1, 31, 23, 59, 59, 999999),
    ),
    # Monatsende begrenzt: 29. Februar 2028 plus 12 Monate ist der 28. Februar 2029.
    "R1_monatsende_schaltjahr": Ablauf(
        Rechtsregime.R1,
        "nichtanhandnahme_einstellung",
        _utc(2028, 1, 31, 10, 0, 0),
        _utc(2028, 2, 29, 18, 30, 0),
        _utc(2029, 2, 28, 18, 30, 0),
    ),
    # Uhr in UTC+1: 2027-03-01 00:30+01:00 ist 2027-02-28 23:30Z; in UTC gerechnet (E-S13-10 a)
    # ergibt sich 2028-02-28 23:30Z, in Ortszeit gerechnet wäre es 2028-02-29 23:30Z.
    "R2_monatsrechnung_in_utc": Ablauf(
        Rechtsregime.R2,
        "nichtanhandnahme_einstellung",
        _utc(2027, 1, 10, 8, 0, 0),
        datetime(2027, 3, 1, 0, 30, 0, tzinfo=timezone(timedelta(hours=1))),
        _utc(2028, 2, 28, 23, 30, 0),
    ),
}

# Rechtsregime ausserhalb von R1 und R2, leer, ungesetzt, fehlend, als Text statt StrEnum.
_FEHLT = object()
ABWEISUNGEN: dict[str, object] = {
    "R3": "R3",
    "R4": "R4",
    "R5": "R5",
    "leer": "",
    "ungesetzt": None,
    "fehlend": _FEHLT,
    "klein_r1": "r1",
    "text_statt_enum_R1": "R1",
    "text_statt_enum_R2": "R2",
}

FAELLE_REGIME = [*ABLAEUFE, *(f"abgewiesen_{name}" for name in ABWEISUNGEN)]


@pytest.mark.parametrize("fall_art", FAELLE_REGIME)
async def test_R3_F_001_fall_traegt_regime(
    fall_art: str, verbindung_anwendung: AsyncConnection
) -> None:
    """R3-F-001_fall_traegt_regime: Eröffnung nur mit R1 oder R2; Schliessen schreibt den
    Zeitpunkt fest und setzt die Prüffrist; je Vorgang genau ein Eintrag in der Arbeitsspur.
    """
    verbindung = verbindung_anwendung
    aktenzeichen = f"TEST-SYNTH-REGIME  {fall_art} "
    aktenzeichen_angeglichen = f"TEST-SYNTH-REGIME {fall_art}"
    leer = await _bestand(verbindung)
    assert all(not zeilen for zeilen in leer.values()), (
        "Bestand vor dem Test nicht leer"
    )

    if fall_art.startswith("abgewiesen_"):
        wert = ABWEISUNGEN[fall_art.removeprefix("abgewiesen_")]
        daten: dict[str, object] = {
            "aktenzeichen": aktenzeichen,
            "rechtsgrundlage": RECHTSGRUNDLAGE,
            "fallkategorie": "vergehen",
            "ermittelnde_person": ERMITTELNDE_PERSON,
        }
        if wert is not _FEHLT:
            daten["rechtsregime"] = wert
        with pytest.raises(ValidationError) as info:
            Eroeffnung.model_validate(daten)
        assert any(f["loc"] == ("rechtsregime",) for f in info.value.errors())
        if isinstance(wert, str) and not fall_art.startswith(
            "abgewiesen_text_statt_enum"
        ):
            # Der Vorrat selbst kennt den Wert nicht, auch nicht über JSON (Mutation: R3 ergänzt).
            assert {r.value for r in Rechtsregime} == {"R1", "R2"}
            with pytest.raises(ValueError):
                Rechtsregime(wert)
            with pytest.raises(ValidationError):
                Eroeffnung.model_validate_json(json.dumps(daten))
        # Vor jedem Schreiben: keine Eroeffnung, also kein Aufruf von eroeffnen, kein Bestand.
        assert await _bestand(verbindung) == leer
        return

    ablauf = ABLAEUFE[fall_art]
    assert (
        await _monate_der_kategorie(verbindung, ablauf.fallkategorie)
        == (STARTWERTE[ablauf.fallkategorie])
    ), "Startwert der Fallkategorie weicht ab; Erwartungswert neu rechnen"
    uhr = VerstellbareUhr(ablauf.eroeffnet)

    # (a) Eröffnen
    fall = await _eroeffnen(
        verbindung,
        _eroeffnung(
            aktenzeichen,
            rechtsregime=ablauf.rechtsregime,
            fallkategorie=ablauf.fallkategorie,
        ),
        uhr,
    )
    assert fall.rechtsregime is ablauf.rechtsregime
    assert fall.fallkategorie == ablauf.fallkategorie
    assert fall.zustand is Fallzustand.AKTIV
    assert fall.eroeffnet_am == ablauf.eroeffnet
    _ist_utc(fall.eroeffnet_am)
    assert fall.geschlossen_am is None
    assert fall.prueffrist_bis is None
    assert await fall_lesen(verbindung, fall.kennung) == fall
    zeile = await _fallzeile(verbindung, fall.kennung)
    assert zeile["rechtsregime"] == ablauf.rechtsregime.value
    assert zeile["zustand"] == "aktiv"
    assert zeile["eroeffnet_am"] == ablauf.eroeffnet
    assert zeile["geschlossen_am"] is None
    assert zeile["prueffrist_bis"] is None
    assert zeile["aktenzeichen"] == aktenzeichen_angeglichen

    arbeit = await _eintraege(verbindung, fall.kennung, Spur.ARBEITSSPUR)
    assert [(e["position"], e["eintragstyp"]) for e in arbeit] == [
        (1, "fall_eroeffnet")
    ]
    assert arbeit[0]["zeitpunkt"] == ablauf.eroeffnet
    assert arbeit[0]["person_kennung"] == PERSON
    assert arbeit[0]["kennzeichnung"] == "quellenaussage"
    nutzlast = json.loads(arbeit[0]["payload"])
    assert nutzlast["fall_kennung"] == str(fall.kennung)
    assert nutzlast["rechtsregime"] == ablauf.rechtsregime.value
    assert nutzlast["fallkategorie"] == ablauf.fallkategorie
    assert nutzlast["eroeffnet_am"] == _zeit_text(ablauf.eroeffnet)
    _ohne_klartext(
        arbeit[0]["payload"],
        aktenzeichen_angeglichen,
        RECHTSGRUNDLAGE_ANGEGLICHEN,
        ERMITTELNDE_PERSON,
    )
    assert await _eintraege(verbindung, fall.kennung, Spur.ERMITTLUNGSSPUR) == []
    await _ketten_unversehrt(verbindung, fall.kennung, arbeitsspur=1)

    # (b) Schliessen
    uhr.zeitpunkt = ablauf.geschlossen
    geschlossen = await _schliessen(verbindung, fall.kennung, uhr)
    assert geschlossen.kennung == fall.kennung
    assert geschlossen.rechtsregime is ablauf.rechtsregime
    assert geschlossen.zustand is Fallzustand.ABGESCHLOSSEN
    assert geschlossen.eroeffnet_am == ablauf.eroeffnet
    assert geschlossen.geschlossen_am == ablauf.geschlossen
    _ist_utc(geschlossen.geschlossen_am)
    assert geschlossen.prueffrist_bis == ablauf.prueffrist
    _ist_utc(geschlossen.prueffrist_bis)
    assert await fall_lesen(verbindung, fall.kennung) == geschlossen
    zeile = await _fallzeile(verbindung, fall.kennung)
    assert zeile["zustand"] == "abgeschlossen"
    assert zeile["geschlossen_am"] == ablauf.geschlossen
    assert zeile["prueffrist_bis"] == ablauf.prueffrist
    assert zeile["eroeffnet_am"] == ablauf.eroeffnet

    # (c) Je Vorgang genau ein Eintrag in der Arbeitsspur, Ermittlungsspur leer, Ketten unversehrt
    arbeit = await _eintraege(verbindung, fall.kennung, Spur.ARBEITSSPUR)
    assert [(e["position"], e["eintragstyp"]) for e in arbeit] == [
        (1, "fall_eroeffnet"),
        (2, "fall_geschlossen"),
    ]
    assert arbeit[1]["zeitpunkt"] == ablauf.geschlossen
    assert arbeit[1]["person_kennung"] == PERSON
    assert arbeit[1]["kennzeichnung"] == "quellenaussage"
    nutzlast = json.loads(arbeit[1]["payload"])
    assert nutzlast == {
        "fall_kennung": str(fall.kennung),
        "geschlossen_am": _zeit_text(ablauf.geschlossen),
        "prueffrist_bis": _zeit_text(ablauf.prueffrist),
        # DF-S13-02: die Regel der Prüffrist steht verkettet in der Nutzlast.
        "erste_pruefung_monate": STARTWERTE[ablauf.fallkategorie],
    }
    assert await _eintraege(verbindung, fall.kennung, Spur.ERMITTLUNGSSPUR) == []
    await _ketten_unversehrt(verbindung, fall.kennung, arbeitsspur=2)

    # (d) Zweites Schliessen: ZustandsFehler, kein weiterer Eintrag, Zeitpunkt bleibt fest
    vorher = await _bestand(verbindung)
    uhr.zeitpunkt = ablauf.geschlossen + timedelta(days=40)
    with pytest.raises(ZustandsFehler):
        await _schliessen(verbindung, fall.kennung, uhr)
    assert await _bestand(verbindung) == vorher
    assert await fall_lesen(verbindung, fall.kennung) == geschlossen
    await _ketten_unversehrt(verbindung, fall.kennung, arbeitsspur=2)


# ---------------------------------------------------------------------------------------------
# R3-F-001_aktenzeichen_eindeutig
# ---------------------------------------------------------------------------------------------

AKTENZEICHEN = "TEST-SYNTH-BE 2026/\u00c4-0417"
ANDERES_AKTENZEICHEN = "TEST-SYNTH-BE 2026/\u00c4-0418"

# Zweite Eröffnung: abgewiesen, wenn nach der Angleichung zeichengleich (gleicher Text, anderer
# Leerraum, andere Unicode-Normalform); angenommen bei anderer Gross- und Kleinschreibung (GS-24)
# und bei einem anderen sichtbaren Zeichen.
VARIANTEN: dict[str, tuple[str, bool]] = {
    "gleich": (AKTENZEICHEN, True),
    "leerraum": ("  TEST-SYNTH-BE\t\n 2026/\u00c4-0417 \x0c", True),
    "normalform_nfd": ("TEST-SYNTH-BE 2026/A\u0308-0417", True),
    "nfd_und_leerraum": (" TEST-SYNTH-BE   2026/A\u0308-0417", True),
    "grossschreibung_verschieden": ("test-synth-be 2026/\u00e4-0417", False),
    "anderes_zeichen": (ANDERES_AKTENZEICHEN, False),
}

ZUSTAENDE = ["aktiv", "abgeschlossen"]


# Spalte der Fallkennung je Tabelle in _BESTAND_SQL.
_SPALTE_FALL = {
    "fall": 0,
    "fall_schluessel": 0,
    "kettenkopf": 0,
    "arbeitsspur": 1,
    "ermittlungsspur": 1,
}


def _zeilen_des_falls(
    stand: dict[str, list[tuple[Any, ...]]], fall: UUID
) -> dict[str, list[tuple[Any, ...]]]:
    """Die Zeilen eines Falls in jeder Tabelle des Bestands."""
    return {
        name: [z for z in zeilen if z[_SPALTE_FALL[name]] == fall]
        for name, zeilen in stand.items()
    }


def _texte_der_ausnahme(fehler: BaseException) -> list[str]:
    """str, repr und args der Ausnahme und jeder Ursache und jedes Kontexts."""
    texte: list[str] = []
    gesehen: set[int] = set()
    offen: list[BaseException | None] = [fehler]
    while offen:
        aktuell = offen.pop()
        if aktuell is None or id(aktuell) in gesehen:
            continue
        gesehen.add(id(aktuell))
        texte.extend([str(aktuell), repr(aktuell), *(repr(a) for a in aktuell.args)])
        offen.extend([aktuell.__cause__, aktuell.__context__])
    return texte


@pytest.mark.parametrize("variante", list(VARIANTEN))
@pytest.mark.parametrize("zustand", ZUSTAENDE)
async def test_R3_F_001_aktenzeichen_eindeutig(
    zustand: str, variante: str, verbindung_anwendung: AsyncConnection
) -> None:
    """R3-F-001_aktenzeichen_eindeutig: ein nach der Angleichung zeichengleiches Aktenzeichen
    eines aktiven oder abgeschlossenen Falls wird abgewiesen, ohne neuen Fall und ohne Eintrag;
    die Spuren des bestehenden Falls bleiben unverändert; ein anderes Aktenzeichen gelingt.
    """
    verbindung = verbindung_anwendung
    zweites, abgewiesen = VARIANTEN[variante]

    uhr = VerstellbareUhr(_utc(2026, 2, 2, 9, 0, 0))
    bestehend = await _eroeffnen(verbindung, _eroeffnung(AKTENZEICHEN), uhr)
    eintraege_bestehend = 1
    if zustand == "abgeschlossen":
        uhr.zeitpunkt = _utc(2026, 4, 1, 16, 0, 0)
        bestehend = await _schliessen(verbindung, bestehend.kennung, uhr)
        assert bestehend.zustand is Fallzustand.ABGESCHLOSSEN
        eintraege_bestehend = 2
    await _ketten_unversehrt(
        verbindung, bestehend.kennung, arbeitsspur=eintraege_bestehend
    )
    vorher = await _bestand(verbindung)
    assert len(vorher["fall"]) == 1

    uhr.zeitpunkt = _utc(2026, 5, 5, 11, 0, 0)
    zweite_eroeffnung = _eroeffnung(zweites, rechtsregime=Rechtsregime.R2)

    if abgewiesen:
        assert zweite_eroeffnung.aktenzeichen == AKTENZEICHEN
        with pytest.raises(EindeutigkeitsFehler) as info:
            await _eroeffnen(verbindung, zweite_eroeffnung, uhr)
        # Kein neuer Fall, kein Schlüssel, kein Kettenkopf, kein Eintrag; Bestand unverändert.
        assert await _bestand(verbindung) == vorher
        assert await fall_lesen(verbindung, bestehend.kennung) == bestehend
        await _ketten_unversehrt(
            verbindung, bestehend.kennung, arbeitsspur=eintraege_bestehend
        )
        async with verbindung.begin():
            alle = await ketten_aller_faelle_pruefen(verbindung)
        assert [(b.fall_kennung, b.unversehrt) for b in alle] == [
            (bestehend.kennung, True),
            (bestehend.kennung, True),
        ]
        # Fehlertext, Ursache und Kontext ohne Aktenzeichen im Klartext (E-S13-09 a).
        fehler = info.value
        assert fehler.__cause__ is None
        assert fehler.__suppress_context__
        for textstueck in _texte_der_ausnahme(fehler):
            for form in {AKTENZEICHEN, zweites, zweites.strip()}:
                assert form not in textstueck, "Aktenzeichen im Fehlertext"
            assert "0417" not in textstueck, "Teil des Aktenzeichens im Fehlertext"
        # Gegenprobe: ein anderes Aktenzeichen gelingt danach.
        zweites = ANDERES_AKTENZEICHEN
        neu = await _eroeffnen(
            verbindung, _eroeffnung(zweites, rechtsregime=Rechtsregime.R2), uhr
        )
    else:
        neu = await _eroeffnen(verbindung, zweite_eroeffnung, uhr)

    # Die angenommene Eröffnung ist ein eigener Fall mit eigenem Eintrag; der bestehende Fall
    # und seine Spuren sind unverändert.
    assert neu.kennung != bestehend.kennung
    assert neu.zustand is Fallzustand.AKTIV
    assert neu.rechtsregime is Rechtsregime.R2
    nachher = await _bestand(verbindung)
    assert len(nachher["fall"]) == 2
    assert _zeilen_des_falls(nachher, bestehend.kennung) == _zeilen_des_falls(
        vorher, bestehend.kennung
    )
    arbeit_neu = await _eintraege(verbindung, neu.kennung, Spur.ARBEITSSPUR)
    assert [(e["position"], e["eintragstyp"]) for e in arbeit_neu] == [
        (1, "fall_eroeffnet")
    ]
    await _ketten_unversehrt(verbindung, neu.kennung, arbeitsspur=1)
    await _ketten_unversehrt(
        verbindung, bestehend.kennung, arbeitsspur=eintraege_bestehend
    )
    assert (await _fallzeile(verbindung, neu.kennung))["aktenzeichen"] == (
        zweite_eroeffnung.aktenzeichen if not abgewiesen else ANDERES_AKTENZEICHEN
    )
