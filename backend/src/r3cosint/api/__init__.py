"""HTTP-Endpunkte, Anmeldung, Sitzung, Schemata der Aussenschnittstelle. Keine Fachlogik.

Modul nach ADR 0002, 4.1 (Ebene 0). Im Grundgerüst steht hier allein die ASGI-Anwendung
ohne Route und ohne die mitgelieferten Dokumentationsrouten; Vertrag 6: kein anderes Modul
importiert api.
"""

from fastapi import FastAPI

app = FastAPI(docs_url=None, redoc_url=None, openapi_url=None)
