"""Konfiguration der Datenbankverbindung (ADR 0007, Entscheid 8; Festlegung S1.1, R3-F-008).

Fünf Variablen bestimmen die Verbindung: R3COSINT_DB_HOST, R3COSINT_DB_PORT,
R3COSINT_DB_NAME, R3COSINT_DB_BENUTZER und R3COSINT_DB_PASSWORT_DATEI. Das Passwort
steht allein in der Datei, nie in einer Variable und nie in einer URL, einer Meldung
oder einer Darstellung des Objekts: eine Umgebung ist über Prozessliste und Abbilder
sichtbar, eine Datei mit engen Rechten nicht (A11, zweite Fortschreibung).
"""

import os
from collections.abc import Mapping
from pathlib import Path

from pydantic import (
    BaseModel,
    ConfigDict,
    Field,
    SecretStr,
    ValidationError,
    field_validator,
)
from sqlalchemy.engine import URL

from r3cosint.core.fehler import KonfigurationsFehler

TREIBER = "postgresql+asyncpg"

VARIABLE_HOST = "R3COSINT_DB_HOST"
VARIABLE_PORT = "R3COSINT_DB_PORT"
VARIABLE_NAME = "R3COSINT_DB_NAME"
VARIABLE_BENUTZER = "R3COSINT_DB_BENUTZER"
VARIABLE_PASSWORT_DATEI = "R3COSINT_DB_PASSWORT_DATEI"

_FELD_ZU_VARIABLE = {
    "host": VARIABLE_HOST,
    "port": VARIABLE_PORT,
    "name": VARIABLE_NAME,
    "benutzer": VARIABLE_BENUTZER,
    "passwort_datei": VARIABLE_PASSWORT_DATEI,
}
_VORGABE_PORT = "5432"


class Datenbankverbindung(BaseModel):
    """Parameter der Verbindung zur Datenbank; enthält kein Passwort."""

    model_config = ConfigDict(frozen=True, extra="forbid")

    host: str = Field(min_length=1)
    port: int = Field(default=5432, ge=1, le=65535)
    name: str = Field(min_length=1)
    benutzer: str = Field(min_length=1)
    passwort_datei: Path

    @field_validator("passwort_datei")
    @classmethod
    def _absolut(cls, pfad: Path) -> Path:
        """Verlangt einen absoluten Pfad: ein relativer hinge vom Arbeitsverzeichnis ab."""
        if not pfad.is_absolute():
            raise ValueError("passwort_datei muss ein absoluter Pfad sein")
        return pfad

    def passwort_lesen(self) -> SecretStr:
        """Liest das Passwort aus der Datei; ein abschliessender Zeilenumbruch entfällt."""
        try:
            roh = self.passwort_datei.read_text(encoding="utf-8")
        except (OSError, UnicodeDecodeError) as fehler:
            raise KonfigurationsFehler(
                f"Die Passwortdatei {self.passwort_datei} ist nicht lesbar.",
                f"Pfad und Rechte der Datei prüfen (Variable {VARIABLE_PASSWORT_DATEI}).",
            ) from fehler
        passwort = roh.removesuffix("\n").removesuffix("\r")
        if passwort == "":
            raise KonfigurationsFehler(
                f"Die Passwortdatei {self.passwort_datei} ist leer.",
                "Das Passwort der Datenbankrolle in die Datei schreiben.",
            )
        return SecretStr(passwort)


def aus_umgebung(umgebung: Mapping[str, str] | None = None) -> Datenbankverbindung:
    """Baut die Verbindung aus den Variablen; fehlt oder irrt eine, nennt der Fehler den Namen.

    Vorgabe der Abbildung ist os.environ. Der Wert einer Variablen steht nie in der Meldung.
    """
    quelle = os.environ if umgebung is None else umgebung
    for variable in (
        VARIABLE_HOST,
        VARIABLE_NAME,
        VARIABLE_BENUTZER,
        VARIABLE_PASSWORT_DATEI,
    ):
        if variable not in quelle:
            raise KonfigurationsFehler(
                f"Die Variable {variable} fehlt.",
                f"{variable} setzen (Verbindung zur Datenbank, ADR 0007, Entscheid 8).",
            )
    try:
        port = int(quelle.get(VARIABLE_PORT, _VORGABE_PORT))
    except ValueError:
        raise _ungueltig(VARIABLE_PORT) from None
    try:
        return Datenbankverbindung(
            host=quelle[VARIABLE_HOST],
            port=port,
            name=quelle[VARIABLE_NAME],
            benutzer=quelle[VARIABLE_BENUTZER],
            passwort_datei=Path(quelle[VARIABLE_PASSWORT_DATEI]),
        )
    except ValidationError as fehler:
        # Nur der Feldname wird übernommen; der Eingabewert bliebe in der Meldung von pydantic.
        feld = str(fehler.errors(include_input=False, include_url=False)[0]["loc"][0])
        raise _ungueltig(_FELD_ZU_VARIABLE[feld]) from None


def _ungueltig(variable: str) -> KonfigurationsFehler:
    return KonfigurationsFehler(
        f"Die Variable {variable} ist ungültig.",
        "Wert der genannten Variablen prüfen (Port 1 bis 65535, Pfad absolut, sonst nicht leer).",
    )


def verbindungs_url(verbindung: Datenbankverbindung) -> URL:
    """Liefert die Verbindungs-URL (Treiber postgresql+asyncpg) ohne Passwort."""
    return URL.create(
        TREIBER,
        username=verbindung.benutzer,
        host=verbindung.host,
        port=verbindung.port,
        database=verbindung.name,
    )
