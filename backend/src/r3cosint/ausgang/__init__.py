"""Der einzige Ort mit einem HTTP-Client nach aussen; Positivliste, Protokollierung jedes Versuchs.

Modul nach ADR 0002, 4.1 (Ebene 1). Einziges Paket, das Bibliotheken für ausgehende
Verbindungen importieren darf (Vertrag 2).
"""
