# Basis-Image für WebVirtCloud
FROM retspen/webvirtcloud:latest

# Als Root ausführen, um System-Tools zu installieren
USER root

# Hier kannst du zusätzliche Pakete installieren, die du im Container brauchst
RUN apt-get update && apt-get install -y --no-install-recommends \
    iputils-ping \
    net-tools \
    curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Zurück zum Standard-User (Sicherheit)
USER 1000
