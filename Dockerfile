FROM --platform=linux/amd64 ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    curl gnupg wget xterm nano net-tools neofetch git tzdata unzip zip screen htop nload \
    openjdk-21-jdk openjdk-8-jdk python3 python3-pip \
    xfce4 xfce4-goodies tigervnc-standalone-server tigervnc-tools novnc websockify \
    dbus-x11 x11-utils x11-xserver-utils x11-apps software-properties-common \
    ca-certificates xubuntu-icon-theme openssl && \
    curl -SsL https://playit-cloud.github.io/ppa/key.gpg | gpg --dearmor | tee /etc/apt/trusted.gpg.d/playit.gpg >/dev/null && \
    echo "deb [signed-by=/etc/apt/trusted.gpg.d/playit.gpg] https://playit-cloud.github.io/ppa/data ./" | tee /etc/apt/sources.list.d/playit-cloud.list && \
    apt-get update && \
    apt-get install -y playit && \
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    apt-get install -y ./google-chrome-stable_current_amd64.deb && \
    rm google-chrome-stable_current_amd64.deb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN touch /root/.Xauthority

EXPOSE 6080

CMD bash -c " \
    mkdir -p /root/.vnc; \
    echo 'SecurityTypes=None' > /root/.vnc/config; \
    vncserver -localhost no -geometry 1024x768 :1; \
    openssl req -new -subj '/C=DE/ST=None/L=None/O=None/CN=localhost' -x509 -days 365 -nodes -out /root/self.pem -keyout /root/self.pem; \
    websockify -D --web=/usr/share/novnc/ --cert=/root/self.pem 6080 localhost:5901; \
    echo 'System gestartet. Playit und VNC (Port 6080) bereit.'; \
    tail -f /dev/null"
