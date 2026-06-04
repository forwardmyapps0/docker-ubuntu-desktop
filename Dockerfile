FROM --platform=linux/amd64 ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Pakete installieren (openssl für die Zertifikatserstellung hinzugefügt)
RUN apt-get update && apt-get install -y --no-install-recommends \
    qemu-system-x86 qemu-utils curl ca-certificates novnc websockify python3 bash openssl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Filebrowser Installation
RUN curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh | bash

# Arbeitsverzeichnis & ISO-Download mittels curl
WORKDIR /root/vm
RUN curl -LO https://releases.ubuntu.com/24.04/ubuntu-24.04.4-live-server-amd64.iso

# Ports freigeben
EXPOSE 6080 80

# Start-Logik
CMD bash -c " \
    # Zertifikat für websockify erstellen \
    openssl req -new -subj '/C=DE/ST=None/L=None/O=None/CN=localhost' -x509 -days 365 -nodes -out /root/self.pem -keyout /root/self.pem; \
    qemu-system-x86_64 \
    -m 2G -smp 2 \
    -cdrom /root/vm/ubuntu-24.04.4-live-server-amd64.iso \
    -vnc :0 \
    -netdev user,id=net0 -device e1000,netdev=net0 \
    -monitor stdio & \
    websockify -D --web=/usr/share/novnc/ --cert=/root/self.pem 6080 localhost:5900 & \
    filebrowser -r /root/vm -p 80 & \
    tail -f /dev/null"
