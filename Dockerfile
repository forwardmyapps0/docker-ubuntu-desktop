FROM --platform=linux/amd64 ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

EXPOSE 6080

# 1. Pakete installieren
RUN apt-get update && apt-get install -y --no-install-recommends \
    qemu-system-x86 qemu-utils \
    novnc websockify python3 openssl \
    curl wget

# 2. ISO herunterladen
RUN wget -q https://releases.ubuntu.com/24.04/ubuntu-24.04.4-live-server-amd64.iso -O /root/ubuntu.iso

# 3. Festplatte erstellen
RUN qemu-img create -f qcow2 /root/vm_disk.qcow2 30G

# 4. Entrypoint-Skript erstellen, das QEMU bei Abbruch automatisch neu startet
RUN echo '#!/bin/bash\n\
# Zertifikat für noVNC erstellen\n\
openssl req -new -x509 -days 365 -nodes -subj "/C=DE/ST=None/L=None/O=None/CN=localhost" -out /root/self.pem -keyout /root/self.pem\n\
\n\
# Websockify im Hintergrund starten\n\
websockify --web=/usr/share/novnc/ --cert=/root/self.pem 6080 localhost:5900 &\n\
\n\
# Endlosschleife für QEMU\n\
while true; do\n\
  echo "Starte QEMU VM..."\n\
  qemu-system-x86_64 -m 4G -smp 2 -hda /root/vm_disk.qcow2 -cdrom /root/ubuntu.iso -boot d -net nic -net user -vnc localhost:0\n\
  echo "QEMU wurde beendet. Neustart in 2 Sekunden..."\n\
  sleep 2\n\
done' > /root/entrypoint.sh && chmod +x /root/entrypoint.sh

# 5. Starten
CMD ["/root/entrypoint.sh"]
