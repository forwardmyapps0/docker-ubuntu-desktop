# Wir verwenden offizielles Ubuntu, das ist fast überall verfügbar
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Manuelle Installation von WebVirtCloud-Abhängigkeiten
RUN apt-get update && apt-get install -y \
    python3-pip \
    python3-venv \
    git \
    nginx \
    libvirt-daemon-system \
    qemu-kvm \
    && apt-get clean

# WebVirtCloud direkt von GitHub klonen und installieren
RUN git clone https://github.com/retspen/webvirtcloud.git /var/www/webvirtcloud
WORKDIR /var/www/webvirtcloud
RUN python3 -m venv venv && \
    ./venv/bin/pip install -r requirements.txt

# Start-Skript für den Webserver
CMD ["./venv/bin/gunicorn", "webvirtcloud.wsgi:application", "--bind", "0.0.0.0:80"]
