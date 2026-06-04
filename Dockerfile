FROM --platform=linux/amd64 ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Pakete installieren
RUN apt-get update && apt-get install -y --no-install-recommends \
    qemu-system-x86 qemu-utils curl ca-certificates novnc websockify python3 bash \
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
    qemu-system-x86_64 \
    -m 2G -smp 2 \
    -cdrom /root/vm/ubuntu-24.04.4-live-server-amd64.iso \
    -vnc :0 \
    -netdev user,id=net0 -device e1000,netdev=net0 \
    -monitor stdio & \
    websockify --web=/usr/share/novnc/ 6080 localhost:5900 & \
    filebrowser -r /root/vm -p 80 & \
    tail -f /dev/null"
