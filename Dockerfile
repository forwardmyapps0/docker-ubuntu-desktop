FROM --platform=linux/amd64 ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV USER=root

RUN apt-get update && apt-get install -y --no-install-recommends \
    tigervnc-standalone-server tigervnc-common tigervnc-tools \
    xfce4 xfce4-goodies dbus-x11 xauth \
    novnc websockify python3 openssl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /root/.vnc

EXPOSE 6080

CMD bash -c " \
    PASS=$(hostname) && \
    echo \"$PASS\" | vncpasswd -f > /root/.vnc/passwd && chmod 600 /root/.vnc/passwd && \
    echo \"VNC-Passwort ist: $PASS\" && \
    openssl req -new -x509 -days 365 -nodes \
    -subj '/C=DE/ST=None/L=None/O=None/CN=localhost' \
    -out /root/self.pem -keyout /root/self.pem && \
    touch /root/.Xauthority && \
    dbus-uuidgen > /var/lib/dbus/machine-id && \
    vncserver :1 -geometry 1280x720 -depth 24 -localhost no && \
    websockify --web=/usr/share/novnc/ --cert=/root/self.pem 6080 localhost:5901"
