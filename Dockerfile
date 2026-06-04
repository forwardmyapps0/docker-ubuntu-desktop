FROM --platform=linux/amd64 ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV USER=root
ENV VNC_PASSWORD=pass1234

RUN apt-get update && apt-get install -y --no-install-recommends \
    tigervnc-standalone-server tigervnc-common tigervnc-tools \
    xfce4 xfce4-goodies dbus-x11 xauth \
    novnc websockify python3 openssl

RUN mkdir -p /root/.vnc && \
    echo "$VNC_PASSWORD" | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd && \
    touch /root/.Xauthority && \
    dbus-uuidgen > /var/lib/dbus/machine-id

EXPOSE 6080

CMD bash -c " \
    openssl req -new -x509 -days 365 -nodes \
    -subj '/C=DE/ST=None/L=None/O=None/CN=localhost' \
    -out /root/self.pem -keyout /root/self.pem && \
    vncserver :0 -geometry 1280x720 -depth 24 -localhost no && \
    websockify --web=/usr/share/novnc/ --cert=/root/self.pem 6080 localhost:5900"
