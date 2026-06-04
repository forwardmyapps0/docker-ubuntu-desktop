FROM --platform=linux/amd64 ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Pakete installieren
RUN apt-get update && apt-get install -y --no-install-recommends \
    qemu-system-x86 qemu-utils wget novnc websockify python3 curl bash screen \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Filebrowser Installation
RUN curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh | bash

# Arbeitsverzeichnis & ISO-Download (Platzhalter)
WORKDIR /root/vm
RUN wget -O ubuntu.iso https://releases.ubuntu.com/24.04/ubuntu-24.04-live-server-amd64.iso

# Ports freigeben (6080 für noVNC, 80 für Filebrowser)
EXPOSE 6080 80

# Start-Logik
# 1. QEMU startet im Hintergrund
# 2. websockify verbindet VNC mit Port 6080
# 3. Filebrowser startet in einem screen auf Port 80
CMD bash -c " \
    qemu-system-x86_64 \
    -m 2G -smp 2 \
    -cdrom /root/vm/ubuntu.iso \
    -vnc :0 \
    -netdev user,id=net0 -device e1000,netdev=net0 \
    -monitor stdio & \
    websockify --web=/usr/share/novnc/ 6080 localhost:5900 & \
    screen -dmS filebrowser filebrowser -r /root/vm -p 80; \
    tail -f /dev/null"
