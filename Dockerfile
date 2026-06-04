FROM --platform=linux/amd64 ubuntu:24.04

# Umgebungsvariablen für eine automatische Installation
ENV DEBIAN_FRONTEND=noninteractive
ENV USER=root

# Pakete installieren: TigerVNC, XFCE Desktop, noVNC und SSL-Tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    tigervnc-standalone-server tigervnc-common \
    xfce4 xfce4-goodies \
    novnc websockify python3 openssl

# VNC Verzeichnis vorbereiten
RUN mkdir -p /root/.vnc

# VNC Passwort setzen (Standard: "password")
RUN echo "password" | vncpasswd -f > /root/.vnc/passwd && chmod 600 /root/.vnc/passwd

# Port 6080 für den Web-Zugriff freigeben
EXPOSE 6080

# Start-Skript
# 1. Zertifikat erstellen (für HTTPS)
# 2. VNC Server starten
# 3. websockify starten, das HTTPS auf Port 6080 annimmt und an VNC weiterleitet
CMD bash -c " \
    openssl req -new -x509 -days 365 -nodes \
    -subj '/C=DE/ST=None/L=None/O=None/CN=localhost' \
    -out /root/self.pem -keyout /root/self.pem && \
    vncserver :1 -geometry 1280x720 -depth 24 && \
    websockify --web=/usr/share/novnc/ --cert=/root/self.pem 6080 localhost:5901"
