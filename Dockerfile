FROM --platform=linux/amd64 ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV USER=root
ENV VNC_PASSWORD=qwer1234
ENV DISPLAY=:0

EXPOSE 6080 5900

# GNOME Flashback, Browser und notwendige Tools installieren
RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo curl nano neofetch \
    tigervnc-standalone-server tigervnc-common tigervnc-tools dbus-x11 xauth \
    gnome-session gnome-session-flashback gnome-terminal gnome-settings-daemon metacity nautilus epiphany-browser \
    dbus-x11 xauth novnc websockify python3 openssl

RUN mkdir -p /root/.vnc && \
    echo "$VNC_PASSWORD" | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd && \
    touch /root/.Xauthority && \
    dbus-uuidgen > /var/lib/dbus/machine-id

CMD bash -c " \
    openssl req -new -x509 -days 365 -nodes \
    -subj '/C=DE/ST=None/L=None/O=None/CN=localhost' \
    -out /root/self.pem -keyout /root/self.pem && \
    dbus-daemon --session --address=unix:path=/var/run/dbus/system_bus_socket --fork && \
    vncserver :0 -geometry 1280x720 -depth 24 -localhost no \
    -xstartup '/usr/bin/gnome-session --session=gnome-flashback-metacity' && \
    websockify --web=/usr/share/novnc/ --cert=/root/self.pem 6080 localhost:5900"
