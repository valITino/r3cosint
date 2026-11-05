"""Einheitstest: core.zeit (ADR 0007, Entscheid 28; Festlegung S1.1, R3-F-008)."""

from datetime import UTC, datetime, timedelta, timezone

import pytest

from r3cosint.core.zeit import Systemuhr, Uhr, monate_addieren


def _utc(jahr: int, monat: int, tag: int, stunde: int = 12) -> datetime:
    return datetime(jahr, monat, tag, stunde, 30, 15, tzinfo=UTC)


@pytest.mark.parametrize(
    ("start", "monate", "erwartet"),
    [
        (_utc(2025, 1, 31), 1, _utc(2025, 2, 28)),
        (_utc(2024, 1, 31), 1, _utc(2024, 2, 29)),
        (_utc(2023, 1, 31), 2, _utc(2023, 3, 31)),
        (_utc(2025, 3, 31), 1, _utc(2025, 4, 30)),
        (_utc(2025, 8, 31), 1, _utc(2025, 9, 30)),
        (_utc(2025, 10, 15), 3, _utc(2026, 1, 15)),
        (_utc(2025, 12, 31), 2, _utc(2026, 2, 28)),
        (_utc(2024, 2, 29), 12, _utc(2025, 2, 28)),
        (_utc(2024, 2, 29), 48, _utc(2028, 2, 29)),
        (_utc(2025, 6, 10), 0, _utc(2025, 6, 10)),
        (_utc(2025, 11, 30), 14, _utc(2027, 1, 30)),
    ],
)
def test_R3_F_008_monate_addieren_begrenzt_den_tag_am_monatsende(
    start: datetime, monate: int, erwartet: datetime
) -> None:
    assert monate_addieren(start, monate) == erwartet


def test_R3_F_008_monate_addieren_behaelt_uhrzeit_und_zone() -> None:
    zone = timezone(timedelta(hours=2))
    start = datetime(2025, 1, 31, 8, 5, 3, 7, tzinfo=zone)
    ergebnis = monate_addieren(start, 1)
    assert ergebnis == datetime(2025, 2, 28, 8, 5, 3, 7, tzinfo=zone)
    assert ergebnis.utcoffset() == timedelta(hours=2)


def test_R3_F_008_monate_addieren_weist_naive_zeit_ab() -> None:
    with pytest.raises(ValueError, match="naive"):
        monate_addieren(datetime(2025, 1, 31, 12, 0, 0), 1)  # noqa: DTZ001 - der Fall selbst


def test_R3_F_008_monate_addieren_weist_negative_monate_ab() -> None:
    with pytest.raises(ValueError, match="negativ"):
        monate_addieren(_utc(2025, 5, 31), -1)


def test_R3_F_008_systemuhr_liefert_zeitbewusste_utc_zeit() -> None:
    uhr: Uhr = Systemuhr()
    jetzt = uhr.jetzt()
    assert jetzt.utcoffset() == timedelta(0)
    assert abs(datetime.now(UTC) - jetzt) < timedelta(seconds=5)


def test_R3_F_008_eine_feste_uhr_erfuellt_das_protocol() -> None:
    class FesteUhr:
        def jetzt(self) -> datetime:
            return _utc(2026, 1, 1)

    uhr: Uhr = FesteUhr()
    assert uhr.jetzt() == _utc(2026, 1, 1)
