FROM --platform=linux/amd64 ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

EXPOSE 6080

# 1. Pakete installieren
RUN apt-get update && apt-get install -y --no-install-recommends \
    qemu-system-x86 qemu-utils \
    novnc websockify python3 openssl \
    curl wget \
    && rm -rf /var/lib/apt/lists/*

# 2. ISO und Festplatte vorbereiten
RUN wget -q https://releases.ubuntu.com/24.04/ubuntu-24.04.4-live-server-amd64.iso -O /root/ubuntu.iso && \
    qemu-img create -f qcow2 /root/vm_disk.qcow2 30G

# 3. Zertifikat und QEMU direkt im CMD ausführen
# Wir nutzen && um sicherzustellen, dass alles nacheinander startet
CMD openssl req -new -x509 -days 365 -nodes -subj "/C=DE/ST=None/L=None/O=None/CN=localhost" -out /root/self.pem -keyout /root/self.pem && \
    websockify --web=/usr/share/novnc/ --cert=/root/self.pem 6080 localhost:5900 & \
    qemu-system-x86_64 -m 4G -smp 2 -hda /root/vm_disk.qcow2 -cdrom /root/ubuntu.iso -boot d -net nic -net user -vnc localhost:0
