# Image des Dienstes anwendung (ADR 0002, Abschnitt 5, Nachtrag vom 2026-11-04, Einheit G2).
# Baukontext ist backend/ (compose: context ../backend); die Ignorierdatei Dockerfile.dockerignore
# neben diesem Dockerfile lässt allein pyproject.toml, uv.lock, .python-version und src/ zu.
# Beschaffung geschieht allein beim Bau: FROM, COPY --from und uv sync. Zur Laufzeit hat der
# Container keine Route (internal-Netz im Stapel). Kein ADD mit URL, kein Geheimnis, keine
# Adresse der Datenbank. Proxy-Variablen und Zertifikate gehören nie in das Image: HTTPS_PROXY
# kommt als vordefiniertes Bau-Argument (docker build --build-arg HTTPS_PROXY=...), das in der
# Umgebung der RUN-Schritte, nicht im Verlauf des Images steht; ein Zertifikat gäbe es allein
# als Bau-Geheimnis (secret mount), nie über COPY, ENV oder ARG.

# ---- Baustufe: Umgebung mit uv aus der Sperrdatei -------------------------------------------
# python: Tag 3.13-slim, Python 3.13.18, Debian 13 trixie; Digest des Manifest-Index,
# Plattform-Digest linux/amd64 sha256:aaf08c5490d52cd92bc27142a5215b1e47355a5eaf9adfad2a0fbc022d0b5490.
FROM docker.io/library/python@sha256:ae14d4ce8771606477a81446e7ef429edd6762305fc50c84507c1041fa8285d1 AS bau

# uv: Tag 0.11.32 (gleich required-version in backend/pyproject.toml), Plattform-Digest linux/amd64
# sha256:0d127b3a7049b879a6e18a79c7f33fea59aa83c226464248f89cfb716a6b96f5; nur das Binary uv.
COPY --from=ghcr.io/astral-sh/uv@sha256:df4cae8f3a96d175e2e5f992e597550000edbe78fdc2594d5cd8de1a217f504c /uv /usr/local/bin/uv

# UV_PYTHON_DOWNLOADS=never: kein Python wird nachgeladen, es gilt das Python des Images.
# UV_COMPILE_BYTECODE=1: Bytecode entsteht beim Bau, damit die Laufzeitstufe (schreibgeschützt,
# nur /tmp beschreibbar) nichts schreiben muss. UV_LINK_MODE=copy: die Umgebung ist ohne den
# Zwischenspeicher von uv lauffähig und lässt sich als Ganzes in die Laufzeitstufe kopieren.
ENV UV_PYTHON_DOWNLOADS=never \
    UV_PYTHON_PREFERENCE=only-system \
    UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy \
    UV_PROJECT_ENVIRONMENT=/opt/umgebung

WORKDIR /bau

# Erst die Abhängigkeiten (ändern sich selten), dann das Projekt.
COPY pyproject.toml uv.lock .python-version ./
RUN uv sync --locked --no-dev --no-install-project --no-editable

COPY src ./src
RUN uv sync --locked --no-dev --no-editable

# ---- Laufzeitstufe: dieselbe Python-Basis, nur die Umgebung, ohne uv und ohne Compiler ------
# python: Tag 3.13-slim, Plattform-Digest linux/amd64 sha256:aaf08c5490d52cd92bc27142a5215b1e47355a5eaf9adfad2a0fbc022d0b5490
# (derselbe Index-Digest wie in der Baustufe).
FROM docker.io/library/python@sha256:ae14d4ce8771606477a81446e7ef429edd6762305fc50c84507c1041fa8285d1

# Benutzer mit fester UID/GID 10001, ohne Login-Shell, ohne Heimatverzeichnis.
# groupadd und useradd stammen aus dem Basis-Image; es wird kein Paket nachinstalliert.
RUN groupadd --system --gid 10001 r3cosint \
 && useradd --system --uid 10001 --gid 10001 --no-create-home \
            --home-dir /nonexistent --shell /usr/sbin/nologin r3cosint

# Die Umgebung gehört root und ist für den Benutzer nur lesbar.
COPY --from=bau /opt/umgebung /opt/umgebung

ENV PATH=/opt/umgebung/bin:$PATH \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

USER 10001:10001

EXPOSE 8000

# Gesundheitsprüfung allein über die Rückschleife, mit dem Python des Images, ohne curl.
HEALTHCHECK --interval=10s --timeout=3s --start-period=10s --retries=3 \
    CMD ["/opt/umgebung/bin/python", "-c", "import socket; socket.create_connection(('127.0.0.1', 8000), timeout=2).close()"]

# Exec-Form: uvicorn ist Prozess 1 und erhält Signale unmittelbar.
CMD ["/opt/umgebung/bin/python", "-m", "uvicorn", "r3cosint.api:app", "--host", "0.0.0.0", "--port", "8000"]
