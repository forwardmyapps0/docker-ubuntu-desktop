FROM --platform=linux/amd64 ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV USER=root
ENV VNC_PASSWORD=qwer1234

EXPOSE 6080 5900

RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo curl nano screen neofetch \
    tigervnc-standalone-server tigervnc-common tigervnc-tools \
    gnome-session gnome-terminal gnome-settings-daemon epiphany-browser \
    metacity nautilus dbus-x11 xauth \
    novnc websockify python3 openssl

RUN mkdir -p /root/.vnc && \
    echo "$VNC_PASSWORD" | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd && \
    touch /root/.Xauthority && \
    dbus-uuidgen > /var/lib/dbus/machine-id

# Startup-Skript für GNOME-Session
RUN echo '#!/bin/sh' > /root/.vnc/xstartup && \
    echo 'unset SESSION_MANAGER' >> /root/.vnc/xstartup && \
    echo 'unset DBUS_SESSION_BUS_ADDRESS' >> /root/.vnc/xstartup && \
    echo 'export XKL_XMODMAP_DISABLE=1' >> /root/.vnc/xstartup && \
    echo 'exec gnome-session --session=gnome-flashback-metacity' >> /root/.vnc/xstartup && \
    chmod +x /root/.vnc/xstartup

CMD bash -c " \
    openssl req -new -x509 -days 365 -nodes \
    -subj '/C=DE/ST=None/L=None/O=None/CN=localhost' \
    -out /root/self.pem -keyout /root/self.pem && \
    vncserver :0 -geometry 1280x720 -depth 24 -localhost no && \
    websockify --web=/usr/share/novnc/ --cert=/root/self.pem 6080 localhost:5900"
