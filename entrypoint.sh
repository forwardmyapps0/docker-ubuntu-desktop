#!/bin/bash
set -e

# Passwort generieren, falls keines über Umgebungsvariable übergeben wurde
if [ -z "$MY_PASS" ]; then
    MY_PASS=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 16)
fi

# Root Passwort setzen
echo "root:$MY_PASS" | chpasswd

# VNC Passwort setzen
mkdir -p /root/.vnc
echo "$MY_PASS" | vncpasswd -f > /root/.vnc/passwd
chmod 600 /root/.vnc/passwd

# Zertifikat für noVNC erstellen, falls nicht vorhanden
if [ ! -f /root/self.pem ]; then
    openssl req -new -subj '/C=DE/ST=None/L=None/O=None/CN=localhost' -x509 -days 365 -nodes -out /root/self.pem -keyout /root/self.pem
fi

# Dienste starten
/usr/sbin/sshd
vncserver -localhost no -SecurityTypes VncAuth -geometry 1024x768 :1
websockify -D --web=/usr/share/novnc/ --cert=/root/self.pem 6080 localhost:5901

echo "========================================="
echo "ZUGANG: root / $MY_PASS"
echo "========================================="

# Container am Laufen halten
tail -f /dev/null
