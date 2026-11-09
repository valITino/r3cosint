"""Einheitstest: Übersetzung der Datenbankfehler in kanon.store ohne Datenbank (ADR 0007, Festlegung S1.4; R3-F-005)."""

from typing import Any
from uuid import uuid4

import pytest
from sqlalchemy.exc import DataError, DBAPIError, OperationalError

from r3cosint.core.fehler import EingabeFehler
from r3cosint.kanon.store import _einfuegen, _ist_datenfehler


class _Treiberfehler(Exception):
    def __init__(self, sqlstate: str | None = None) -> None:
        super().__init__("synth")
        self.sqlstate = sqlstate


class _Verbindung:
    def __init__(self, fehler: BaseException) -> None:
        self._fehler = fehler

    async def execute(self, anweisung: Any) -> None:
        raise self._fehler


def test_R3_F_005_datenfehler_wird_an_klasse_sqlstate_und_ursache_erkannt() -> None:
    assert _ist_datenfehler(DataError("s", {}, _Treiberfehler()))
    assert _ist_datenfehler(DBAPIError("s", {}, _Treiberfehler("22P02")))
    assert not _ist_datenfehler(DBAPIError("s", {}, _Treiberfehler("23505")))
    assert not _ist_datenfehler(OperationalError("s", {}, _Treiberfehler("08006")))


@pytest.mark.anyio
async def test_R3_F_005_verbindungsfehler_bleiben_unuebersetzt() -> None:
    fehler = OperationalError("s", {}, _Treiberfehler("08006"))
    with pytest.raises(OperationalError):
        await _einfuegen(_Verbindung(fehler), None, "entitaet")  # type: ignore[arg-type]


@pytest.mark.anyio
async def test_R3_F_005_datenfehler_ergibt_eingabefehler_ohne_ursache() -> None:
    fehler = DataError("s", {}, _Treiberfehler())
    with pytest.raises(EingabeFehler) as info:
        await _einfuegen(_Verbindung(fehler), None, "entitaet")  # type: ignore[arg-type]
    assert info.value.__cause__ is None
    assert info.value.__context__ is None
    assert str(uuid4()) not in str(info.value)


_TreiberDataError = type(
    "DataError",
    (Exception,),
    {
        "__doc__": "Treiber-Doppel: Klasse namens DataError ohne Import von asyncpg (Vertrag 10)."
    },
)


class _AndereUrsache(Exception):
    """Treiber-Doppel mit anderem Klassennamen."""


class _OrigOhneSqlstate(Exception):
    """orig-Objekt ohne Attribut sqlstate (Treiberstand ohne SQLSTATE)."""


def _ohne_sqlstate(ursache: BaseException) -> DBAPIError:
    orig = _OrigOhneSqlstate("synth")
    assert not hasattr(orig, "sqlstate")
    orig.__cause__ = ursache
    return DBAPIError("s", {}, orig)


def test_R3_F_005_datenfehler_an_der_ursache_ohne_sqlstate_wird_erkannt() -> None:
    fehler = _ohne_sqlstate(_TreiberDataError("synth"))
    assert type(fehler) is DBAPIError
    assert _ist_datenfehler(fehler) is True


def test_R3_F_005_andere_ursache_ohne_sqlstate_ist_kein_datenfehler_gegenprobe() -> (
    None
):
    assert _ist_datenfehler(_ohne_sqlstate(_AndereUrsache("synth"))) is False


@pytest.mark.anyio
async def test_R3_F_005_ursache_datenfehler_ohne_sqlstate_ergibt_eingabefehler_ohne_ursache() -> (
    None
):
    verbindung = _Verbindung(_ohne_sqlstate(_TreiberDataError("synth")))
    with pytest.raises(EingabeFehler) as info:
        await _einfuegen(verbindung, None, "entitaet")  # type: ignore[arg-type]
    assert info.value.__cause__ is None
    assert info.value.__context__ is None


@pytest.mark.anyio
async def test_R3_F_005_andere_ursache_ohne_sqlstate_bleibt_unuebersetzt_gegenprobe() -> (
    None
):
    fehler = _ohne_sqlstate(_AndereUrsache("synth"))
    with pytest.raises(DBAPIError) as info:
        await _einfuegen(_Verbindung(fehler), None, "entitaet")  # type: ignore[arg-type]
    assert info.value is fehler


def _zweistufig(innen: BaseException, ueber: str = "__cause__") -> DBAPIError:
    zwischen = _AndereUrsache("synth")
    setattr(zwischen, ueber, innen)
    orig = _OrigOhneSqlstate("synth")
    orig.__cause__ = zwischen
    return DBAPIError("s", {}, orig)


@pytest.mark.parametrize("ueber", ["__cause__", "__context__"])
def test_R3_F_005_ursachenkette_wird_ueber_mehrere_stufen_gelesen(ueber: str) -> None:
    assert _ist_datenfehler(_zweistufig(_TreiberDataError("synth"), ueber)) is True


def test_R3_F_005_ursachenkette_ohne_datenfehler_gegenprobe_und_tiefe_ist_begrenzt() -> (
    None
):
    assert _ist_datenfehler(_zweistufig(_AndereUrsache("synth"))) is False
    kette: BaseException = _TreiberDataError("synth")
    for _ in range(20):
        glied = _AndereUrsache("synth")
        glied.__cause__ = kette
        kette = glied
    orig = _OrigOhneSqlstate("synth")
    orig.__cause__ = kette
    assert _ist_datenfehler(DBAPIError("s", {}, orig)) is False
