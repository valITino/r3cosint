"""Einheitstest: die ASGI-Anwendung ohne Route (Grundgerüst, Einheit G1).

Die Anwendung bietet nichts an: keine Route und keine der mitgelieferten
Dokumentationsrouten. Der Testclient von FastAPI läuft über httpx.
"""

import pytest
from fastapi.testclient import TestClient

from r3cosint.api import app


def test_routenliste_ist_leer() -> None:
    assert list(app.routes) == []


def test_dokumentationsrouten_sind_abgeschaltet() -> None:
    assert app.docs_url is None
    assert app.redoc_url is None
    assert app.openapi_url is None


@pytest.mark.parametrize("pfad", ["/", "/docs", "/redoc", "/openapi.json"])
def test_get_liefert_404(pfad: str) -> None:
    with TestClient(app) as client:
        antwort = client.get(pfad)
    assert antwort.status_code == 404
