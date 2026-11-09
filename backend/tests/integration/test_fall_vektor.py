"""Integrationstest: ein Vektor durch den ganzen Weg des Falls (ADR 0007, S1.3, DF-S13-06; R3-F-001).

Fester Schlüssel bytes(range(32)), feste Kennungen und Zeiten. Die Erwartungswerte (Pseudonyme,
Nutzlasttexte, Prüfsummen an Position 1 und 2) sind mit openssl (HMAC-SHA-256) und sha256sum
ausserhalb von Python gerechnet; der Test baut die Einträge über spur.service.anfuegen mit einem
Pseudonymisierer aus dem festen Schlüssel, nicht über eroeffnen (dort sind Kennung und Schlüssel
zufällig). Verglichen wird in beiden Rechenwegen der Kettenprüfung. Alle Werte sind erfunden (5.15).
"""

from datetime import UTC, datetime
from uuid import UUID

import pytest
from sqlalchemy import text
from sqlalchemy.ext.asyncio import AsyncConnection

from r3cosint.spur import service as spur_service
from r3cosint.spur.service import (
    FallEroeffnet,
    FallGeschlossen,
    Kennzeichnung,
    Pseudonymisierer,
    Spur,
    anfuegen,
    kette_pruefen,
    kette_pruefen_datenbank,
    ketten_anlegen,
)

pytestmark = pytest.mark.anyio

FALL = UUID("123e4567-e89b-12d3-a456-426614174000")
KENNUNGEN = [
    UUID("00000000-0000-4000-8000-000000000001"),
    UUID("00000000-0000-4000-8000-000000000002"),
]
ANFANGSWERT = "3806383304f69cbb6ecad56fc9582cb8180e7b1bd74042cd6c5e098334d7f477"
PAYLOAD_1 = (
    '{"aktenzeichen_pseudonym":"a6e83823c3ca0e1713fff951720cb7c7af0051527951ceb6929ea0c46616eb0d",'
    '"ermittelnde_person_pseudonym":"2a839b72a9016737e43dab8cc30785d7a80cbd06a6f5b8fe60da9a76465e672c",'
    '"eroeffnet_am":"2026-01-15T08:30:00.123456Z",'
    '"fall_kennung":"123e4567-e89b-12d3-a456-426614174000","fallkategorie":"vergehen",'
    '"rechtsgrundlage_pseudonym":"7374cb1543d6d6bed3f71b2b073c42da30091de446e0356f583fb9e8db0bec53",'
    '"rechtsregime":"R1"}'
)
PAYLOAD_2 = (
    '{"erste_pruefung_monate":84,"fall_kennung":"123e4567-e89b-12d3-a456-426614174000",'
    '"geschlossen_am":"2026-03-10T14:05:06.654321Z",'
    '"prueffrist_bis":"2033-03-10T14:05:06.654321Z"}'
)
PRUEFSUMME_1 = "5a00ace02818b7fa8c0c62f2ee6edae3bf66d500851402946bbbd1fb0777c807"
PRUEFSUMME_2 = "24dfab8eedca9e95db6ae917c94f5b5bcc406f4a4c1ebfa0485d3e1ec1b65d52"
ZEIT_1 = datetime(2026, 1, 15, 8, 30, 0, 123456, tzinfo=UTC)
ZEIT_2 = datetime(2026, 3, 10, 14, 5, 6, 654321, tzinfo=UTC)
FRIST = datetime(2033, 3, 10, 14, 5, 6, 654321, tzinfo=UTC)


class _Uhr:
    def __init__(self, zeitpunkt: datetime) -> None:
        self.zeitpunkt = zeitpunkt

    def jetzt(self) -> datetime:
        return self.zeitpunkt


async def test_R3_F_001_vektor_durch_den_ganzen_weg_eroeffnet_und_geschlossen(
    verbindung_eigentuemer: AsyncConnection,
    verbindung_anwendung: AsyncConnection,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    schluessel = bytes(range(32))
    await verbindung_eigentuemer.execute(
        text(
            "INSERT INTO r3cosint.fall (kennung, aktenzeichen, ermittelnde_person, "
            "rechtsgrundlage, rechtsregime, fallkategorie, zustand, eroeffnet_am) VALUES "
            "(:k, 'test-synth-vektor-1', 'test.fallfuehrung', 'synthetisch', 'R1', 'vergehen', "
            "'aktiv', :z)"
        ),
        {"k": FALL, "z": ZEIT_1},
    )
    await verbindung_eigentuemer.execute(
        text("INSERT INTO r3cosint.fall_schluessel VALUES (:k, :s)"),
        {"k": FALL, "s": schluessel},
    )
    await verbindung_eigentuemer.commit()
    kennungen = iter(KENNUNGEN)
    monkeypatch.setattr(spur_service, "neue_kennung", lambda: next(kennungen))
    pseudo = Pseudonymisierer(schluessel)
    v = verbindung_anwendung
    async with v.begin():
        await ketten_anlegen(v, FALL)
        e1 = await anfuegen(
            v,
            spur=Spur.ARBEITSSPUR,
            fall_kennung=FALL,
            person_kennung="test.ermittlung",
            kennzeichnung=Kennzeichnung.QUELLENAUSSAGE,
            eingabe=FallEroeffnet(
                fall_kennung=FALL,
                rechtsregime="R1",
                fallkategorie="vergehen",
                aktenzeichen="test-synth-vektor-1",
                rechtsgrundlage="synthetisch",
                ermittelnde_person="test.fallfuehrung",
                eroeffnet_am=ZEIT_1,
            ),
            pseudonymisierer=pseudo,
            uhr=_Uhr(ZEIT_1),
        )
        e2 = await anfuegen(
            v,
            spur=Spur.ARBEITSSPUR,
            fall_kennung=FALL,
            person_kennung="test.ermittlung",
            kennzeichnung=Kennzeichnung.QUELLENAUSSAGE,
            eingabe=FallGeschlossen(
                fall_kennung=FALL,
                geschlossen_am=ZEIT_2,
                prueffrist_bis=FRIST,
                erste_pruefung_monate=84,
            ),
            pseudonymisierer=pseudo,
            uhr=_Uhr(ZEIT_2),
        )
    assert e1.vorgaenger_pruefsumme == ANFANGSWERT
    assert e1.payload == PAYLOAD_1
    assert e1.pruefsumme == PRUEFSUMME_1
    assert e2.vorgaenger_pruefsumme == PRUEFSUMME_1
    assert e2.payload == PAYLOAD_2
    assert e2.pruefsumme == PRUEFSUMME_2
    async with v.begin():
        anwendung = await kette_pruefen(v, FALL)
    async with v.begin():
        datenbank = await kette_pruefen_datenbank(v, FALL)
    for weg in (anwendung, datenbank):
        befund = weg[Spur.ARBEITSSPUR]
        assert befund.unversehrt
        assert befund.anzahl == 2
        assert befund.letzte_pruefsumme == PRUEFSUMME_2
