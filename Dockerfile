FROM --platform=linux/amd64 ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update -y && apt install --no-install-recommends -y \
    sudo curl wget xterm init systemd nano net-tools neofetch git tzdata unzip zip screen openjdk-21-jdk \
    xfce4 xfce4-goodies tigervnc-standalone-server novnc websockify \
    dbus-x11 x11-utils x11-xserver-utils x11-apps software-properties-common \
    gnupg ca-certificates xubuntu-icon-theme openssl && \
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    apt install -y ./google-chrome-stable_current_amd64.deb && \
    rm google-chrome-stable_current_amd64.deb && \
    apt clean && rm -rf /var/lib/apt/lists/*

RUN touch /root/.Xauthority

EXPOSE 6080
EXPOSE 8080

CMD bash -c "mkdir -p /root/.vnc && \
    echo \"$VNC_PASSWORD\" | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd && \
    vncserver -localhost no -SecurityTypes VncAuth -geometry 1024x768 :1 && \
    openssl req -new -subj '/C=DE/ST=None/L=None/O=None/CN=localhost' -x509 -days 365 -nodes -out /root/self.pem -keyout /root/self.pem && \
    websockify -D --web=/usr/share/novnc/ --cert=/root/self.pem 6080 localhost:5901 && \
    tail -f /dev/null"
