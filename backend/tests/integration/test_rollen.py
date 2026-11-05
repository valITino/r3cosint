"""Integrationstest: die drei Datenbankrollen (ADR 0007, Entscheid 7; R3-F-008).

Geprüft wird, was der Katalog und ein Versuch zeigen: r3cosint_anwendung ist eine
Rolle ohne besondere Rechte und ohne Eigentum, r3cosint_eigentuemer besitzt das Schema
und die Versionstabelle und ist kein Superuser.
"""

import pytest
from sqlalchemy import text
from sqlalchemy.exc import ProgrammingError
from sqlalchemy.ext.asyncio import AsyncConnection

pytestmark = pytest.mark.anyio

RECHTE = (
    "rolsuper",
    "rolcreaterole",
    "rolcreatedb",
    "rolbypassrls",
    "rolreplication",
    "rolcanlogin",
    "rolinherit",
)


async def _rolle(verbindung: AsyncConnection, name: str) -> dict[str, bool]:
    zeile = (
        await verbindung.execute(
            text(
                "SELECT rolsuper, rolcreaterole, rolcreatedb, rolbypassrls, rolreplication, "
                "rolcanlogin, rolinherit FROM pg_roles WHERE rolname = :name"
            ),
            {"name": name},
        )
    ).one()
    return dict(zip(RECHTE, zeile, strict=True))


async def test_R3_F_008_anwendung_hat_keine_besonderen_rechte_und_erbt_nicht(
    verbindung_anwendung: AsyncConnection,
) -> None:
    assert await _rolle(verbindung_anwendung, "r3cosint_anwendung") == {
        "rolsuper": False,
        "rolcreaterole": False,
        "rolcreatedb": False,
        "rolbypassrls": False,
        "rolreplication": False,
        "rolcanlogin": True,
        "rolinherit": False,
    }


async def test_R3_F_008_eigentuemer_hat_keine_superuser_rechte(
    verbindung_eigentuemer: AsyncConnection,
) -> None:
    rechte = await _rolle(verbindung_eigentuemer, "r3cosint_eigentuemer")
    assert rechte["rolcanlogin"] is True
    for name in (
        "rolsuper",
        "rolcreaterole",
        "rolcreatedb",
        "rolbypassrls",
        "rolreplication",
    ):
        assert rechte[name] is False, name


async def test_R3_F_008_keine_der_beiden_rollen_ist_mitglied_einer_anderen_rolle(
    verbindung_anwendung: AsyncConnection,
) -> None:
    anzahl = await verbindung_anwendung.execute(
        text(
            "SELECT count(*) FROM pg_auth_members m JOIN pg_roles r ON r.oid = m.member "
            "WHERE r.rolname IN ('r3cosint_anwendung', 'r3cosint_eigentuemer')"
        )
    )
    assert anzahl.scalar_one() == 0


@pytest.mark.parametrize("schema", ["public", "r3cosint"])
async def test_R3_F_008_anwendung_hat_kein_create_in_public_und_in_r3cosint(
    verbindung_anwendung: AsyncConnection, schema: str
) -> None:
    recht = await verbindung_anwendung.execute(
        text("SELECT has_schema_privilege(current_user, :schema, 'CREATE')"),
        {"schema": schema},
    )
    assert recht.scalar_one() is False
    await verbindung_anwendung.rollback()
    with pytest.raises(ProgrammingError, match="permission denied"):
        await verbindung_anwendung.execute(
            text(f"CREATE TABLE {schema}.versuch (x integer)")
        )


async def test_R3_F_008_anwendung_hat_usage_in_r3cosint(
    verbindung_anwendung: AsyncConnection,
) -> None:
    recht = await verbindung_anwendung.execute(
        text("SELECT has_schema_privilege(current_user, 'r3cosint', 'USAGE')")
    )
    assert recht.scalar_one() is True


async def test_R3_F_008_anwendung_ist_nicht_eigentuemerin_im_schema(
    verbindung_anwendung: AsyncConnection,
) -> None:
    anzahl = await verbindung_anwendung.execute(
        text(
            "SELECT count(*) FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace "
            "JOIN pg_roles r ON r.oid = c.relowner "
            "WHERE n.nspname = 'r3cosint' AND r.rolname = 'r3cosint_anwendung'"
        )
    )
    assert anzahl.scalar_one() == 0


async def test_R3_F_008_eigentuemer_besitzt_das_schema_und_die_versionstabelle(
    verbindung_eigentuemer: AsyncConnection,
) -> None:
    schema = await verbindung_eigentuemer.execute(
        text(
            "SELECT r.rolname FROM pg_namespace n JOIN pg_roles r ON r.oid = n.nspowner "
            "WHERE n.nspname = 'r3cosint'"
        )
    )
    assert schema.scalar_one() == "r3cosint_eigentuemer"
    tabelle = await verbindung_eigentuemer.execute(
        text(
            "SELECT tableowner FROM pg_tables "
            "WHERE schemaname = 'r3cosint' AND tablename = 'alembic_version'"
        )
    )
    assert tabelle.scalar_one() == "r3cosint_eigentuemer"


async def test_R3_F_008_die_datenbank_ist_fuer_public_gesperrt_und_beide_rollen_verbinden(
    verbindung_eigentuemer: AsyncConnection,
) -> None:
    # Eine Datenbank ohne ausdrückliche ACL (NULL) trägt die Vorgaberechte, darunter CONNECT für
    # PUBLIC; deshalb prüft der Test die wirksamen Rechte über acldefault, nicht allein datacl.
    ergebnis = await verbindung_eigentuemer.execute(
        text(
            "SELECT count(*) FROM pg_database d, "
            "aclexplode(coalesce(d.datacl, acldefault('d', d.datdba))) a "
            "WHERE d.datname = current_database() AND a.grantee = 0"
        )
    )
    assert ergebnis.scalar_one() == 0
    for rolle in ("r3cosint_eigentuemer", "r3cosint_anwendung"):
        recht = await verbindung_eigentuemer.execute(
            text(
                "SELECT has_database_privilege(:rolle, current_database(), 'CONNECT')"
            ),
            {"rolle": rolle},
        )
        assert recht.scalar_one() is True, rolle


async def test_R3_F_008_in_public_hat_niemand_ausser_dem_eigentuemer_create(
    verbindung_eigentuemer: AsyncConnection,
) -> None:
    # PostgreSQL 15 und neuer gibt PUBLIC in public ohnehin kein CREATE; das REVOKE in der
    # Grundeinrichtung trägt die Absicht und schützt auch ältere Vorlagen. Die Zusicherung gilt
    # der Wirkung: kein Recht für PUBLIC und keines für die Rolle der Anwendung.
    ergebnis = await verbindung_eigentuemer.execute(
        text(
            "SELECT count(*) FROM pg_namespace n, "
            "aclexplode(coalesce(n.nspacl, acldefault('n', n.nspowner))) a "
            "WHERE n.nspname = 'public' AND a.grantee = 0 AND a.privilege_type = 'CREATE'"
        )
    )
    assert ergebnis.scalar_one() == 0
    recht = await verbindung_eigentuemer.execute(
        text("SELECT has_schema_privilege('r3cosint_anwendung', 'public', 'CREATE')")
    )
    assert recht.scalar_one() is False


async def test_R3_F_008_eigentuemer_hat_kein_create_auf_der_datenbank_und_in_public(
    verbindung_eigentuemer: AsyncConnection,
) -> None:
    # Der Eigentümer besitzt allein das Schema r3cosint (ADR 0007, Entscheid 7); Eigentum an der
    # Datenbank gäbe ihm CREATE auf ihr und den Besitz von public.
    ergebnis = await verbindung_eigentuemer.execute(
        text(
            "SELECT has_database_privilege('r3cosint_eigentuemer', current_database(), 'CREATE'), "
            "has_schema_privilege('r3cosint_eigentuemer', 'public', 'CREATE')"
        )
    )
    assert ergebnis.one() == (False, False)


async def test_R3_F_008_keine_datenbank_gehoert_einer_der_beiden_rollen(
    verbindung_eigentuemer: AsyncConnection,
) -> None:
    anzahl = await verbindung_eigentuemer.execute(
        text(
            "SELECT count(*) FROM pg_database d JOIN pg_roles r ON r.oid = d.datdba "
            "WHERE r.rolname IN ('r3cosint_eigentuemer', 'r3cosint_anwendung')"
        )
    )
    assert anzahl.scalar_one() == 0
