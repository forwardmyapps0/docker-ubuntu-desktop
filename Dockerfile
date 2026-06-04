# Basis-Image für WebVirtCloud
FROM retspen/webvirtcloud:latest

# Als Root ausführen, um System-Tools zu installieren
USER root

# Installation der QEMU-Engine, libvirt-Tools und Netzwerkhilfsmittel
RUN apt-get update && apt-get install -y --no-install-recommends \
    qemu-kvm \
    qemu-system-x86 \
    libvirt-daemon-system \
    libvirt-clients \
    bridge-utils \
    virtinst \
    python3-libvirt \
    novnc \
    websockify \
    iputils-ping \
    net-tools \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Rechte anpassen, damit der WebVirtCloud-User auf libvirt zugreifen darf
RUN usermod -aG libvirt www-data

# Zurück zum Standard-User
USER 1000
