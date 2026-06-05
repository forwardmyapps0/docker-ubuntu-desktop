FROM --platform=linux/amd64 ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo gnupg curl wget nano screen neofetch \
    tigervnc-standalone-server tigervnc-common tigervnc-tools \
    xfce4 xfce4-goodies dbus-x11 xauth \
    novnc websockify python3 openssl \
    openjdk-21-jdk

RUN install -d -m 0755 /etc/apt/keyrings && \
    wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O /etc/apt/keyrings/packages.mozilla.org.asc && \
    echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | tee /etc/apt/sources.list.d/mozilla.list > /dev/null && \
    echo 'Package: *\nPin: origin packages.mozilla.org\nPin-Priority: 1000' | tee /etc/apt/preferences.d/mozilla && \
    apt-get update && apt-get install -y firefox

RUN mkdir -p /root/.vnc && \
    touch /root/.Xauthority && \
    mkdir -p /etc/ssl/certs/custom

CMD bash -c " \
    echo \"$VNC_PASSWORD\" | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd && \
    openssl req -new -x509 -days 365 -nodes \
    -subj '/C=DE/ST=None/L=None/O=None/CN=localhost' \
    -out /etc/ssl/certs/custom/self.pem -keyout /etc/ssl/certs/custom/self.pem && \
    vncserver :0 -geometry 1280x720 -depth 24 -localhost no -xstartup startxfce4 && \
    websockify --web=/usr/share/novnc/ --cert=/etc/ssl/certs/custom/self.pem 6080 localhost:5900"
