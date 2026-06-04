FROM --platform=linux/amd64 ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Pakete installieren
RUN apt-get update && apt-get install -y --no-install-recommends \
    qemu-system-x86 qemu-utils curl ca-certificates novnc websockify python3 bash openssl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Arbeitsverzeichnis & ISO-Download
WORKDIR /root/vm
RUN curl -LO https://releases.ubuntu.com/24.04/ubuntu-24.04.4-live-server-amd64.iso

# Port 6080 für noVNC und 5901 für VNC intern
EXPOSE 6080 5901

# Start-Logik
CMD bash -c " \
    # Zertifikat erstellen \
    openssl req -new -subj '/C=DE/ST=None/L=None/O=None/CN=localhost' -x509 -days 365 -nodes -out /root/self.pem -keyout /root/self.pem; \
    \
    # QEMU starten mit VNC-Port 5901 \
    qemu-system-x86_64 \
    -m 2G -smp 2 \
    -cdrom /root/vm/ubuntu-24.04.4-live-server-amd64.iso \
    -vnc :1 \
    -netdev user,id=net0 -device e1000,netdev=net0 \
    -monitor stdio & \
    \
    # Warten, bis QEMU bereit ist \
    sleep 5; \
    \
    # websockify verbindet 6080 mit VNC-Port 5901 \
    websockify -D --web=/usr/share/novnc/ --cert=/root/self.pem 6080 127.0.0.1:5901 & \
    \
    tail -f /dev/null"
