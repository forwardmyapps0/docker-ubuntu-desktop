FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# 1. System-Abhängigkeiten installieren
# Wichtig: python3-libvirt wird über apt installiert, um Kompilierfehler zu vermeiden
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3-pip \
    python3-venv \
    python3-dev \
    python3-libvirt \
    git \
    libvirt-dev \
    libxml2-dev \
    libssl-dev \
    libffi-dev \
    gcc \
    g++ \
    pkg-config \
    build-essential \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 2. WebVirtCloud klonen
RUN git clone https://github.com/retspen/webvirtcloud.git /var/www/webvirtcloud

WORKDIR /var/www/webvirtcloud

# 3. Virtuelle Umgebung erstellen und Abhängigkeiten installieren
# Wir nutzen --system-site-packages, damit die per apt installierte libvirt-Bibliothek gefunden wird
RUN python3 -m venv --system-site-packages venv && \
    ./venv/bin/pip install --upgrade pip && \
    ./venv/bin/pip install -r requirements.txt && \
    ./venv/bin/pip install gunicorn

# 4. WebVirtCloud Konfiguration
# Wir kopieren eine Standard-Settings-Datei oder erstellen eine minimale Konfiguration
# (Hinweis: Für den produktiven Einsatz solltest du eine eigene local_settings.py mounten)
RUN cp webvirtcloud/settings.py.template webvirtcloud/local_settings.py

# 5. Datenbank initialisieren und statische Dateien sammeln
RUN ./venv/bin/python3 manage.py migrate && \
    ./venv/bin/python3 manage.py collectstatic --noinput

# 6. Starten
EXPOSE 80
CMD ["./venv/bin/gunicorn", "webvirtcloud.wsgi:application", "--bind", "0.0.0.0:80"]
