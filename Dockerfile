FROM --platform=linux/amd64 ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Pakete installieren (qemu-kvm hinzugefügt für bessere Performance)
RUN apt-get update && apt-get install -y --no-install-recommends \
    qemu-system-x86 qemu-utils curl ca-certificates novnc websockify python3 bash openssl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /root/vm

# ISO herunterladen
RUN curl -LO https://releases.ubuntu.com/24.04/ubuntu-24.04-live-server-amd64.iso

# Erstelle ein leeres Disk-Image (20GB) während des Builds oder beim Start
RUN qemu-img create -f qcow2 /root/vm/disk.img 20G

EXPOSE 6080

CMD bash -c " \
    # Zertifikat für noVNC erstellen \
    openssl req -new -subj '/C=DE/ST=None/L=None/O=None/CN=localhost' -x509 -days 365 -nodes -out /root/self.pem -keyout /root/self.pem; \
    \
    # QEMU im Hintergrund starten \
    qemu-system-x86_64 \
    -enable-kvm \
    -m 2G -smp 2 \
    -cdrom /root/vm/ubuntu-24.04.4-live-server-amd64.iso \
    -drive file=/root/vm/disk.img,format=qcow2 \
    -boot d \
    -vnc 0.0.0.0:1 \
    -netdev user,id=net0 -device e1000,netdev=net0 \
    -monitor none & \
    \
    # websockify starten (verbindet Port 6080 mit VNC-Port 5901) \
    websockify --web=/usr/share/novnc/ 6080 localhost:5901"
