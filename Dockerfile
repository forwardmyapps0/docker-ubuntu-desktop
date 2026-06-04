FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# 1. Alle nötigen System-Pakete installieren
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3-pip \
    python3-venv \
    python3-dev \
    git \
    libvirt-dev \
    libxml2-dev \
    gcc \
    g++ \
    pkg-config \
    build-essential \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 2. WebVirtCloud klonen
RUN git clone https://github.com/retspen/webvirtcloud.git /var/www/webvirtcloud

WORKDIR /var/www/webvirtcloud

# 3. Umgebung bauen und die kritischen Pakete manuell installieren
RUN python3 -m venv venv && \
    ./venv/bin/pip install --upgrade pip && \
    ./venv/bin/pip install django gunicorn pyopenssl lxml libvirt-python

# 4. Datenbank initialisieren und statische Dateien sammeln
RUN ./venv/bin/python3 manage.py migrate && \
    ./venv/bin/python3 manage.py collectstatic --noinput

# 5. Starten
CMD ["./venv/bin/gunicorn", "webvirtcloud.wsgi:application", "--bind", "0.0.0.0:80"]
