FROM --platform=linux/amd64 ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# 1. System aktualisieren & Pakete installieren
RUN apt update -y && apt upgrade -y && \
    apt install -y curl gnupg && \
    # Playit Installation
    curl -SsL https://playit-cloud.github.io/ppa/key.gpg | gpg --dearmor > /etc/apt/trusted.gpg.d/playit.gpg && \
    echo "deb [signed-by=/etc/apt/trusted.gpg.d/playit.gpg] https://playit-cloud.github.io/ppa/data ./" > /etc/apt/sources.list.d/playit-cloud.list && \
    apt update && \
    apt install -y playit && \
    # Restliche Pakete
    apt install --no-install-recommends -y \
    wget xterm nano net-tools neofetch git tzdata unzip zip screen htop nload \
    openjdk-21-jdk openjdk-8-jdk python3 python3-pip \
    xfce4 xfce4-goodies tigervnc-standalone-server tigervnc-tools novnc websockify \
    dbus-x11 x11-utils x11-xserver-utils x11-apps software-properties-common \
    ca-certificates xubuntu-icon-theme openssl openssh-server && \
    # Chrome Installation
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    apt install -y ./google-chrome-stable_current_amd64.deb && \
    rm google-chrome-stable_current_amd64.deb && \
    apt clean && rm -rf /var/lib/apt/lists/*

# 2. Vorbereitung der Konfigurationen
RUN touch /root/.Xauthority && \
    mkdir -p /var/run/sshd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# 3. Ports freigeben
EXPOSE 22 6080 8080

# 4. Start-Logik
CMD bash -c " \
    echo 'root:password' | chpasswd; \
    mkdir -p /root/.vnc; \
    echo 'SecurityTypes=None' > /root/.vnc/config; \
    /usr/sbin/sshd; \
    vncserver -localhost no -geometry 1024x768 :1; \
    openssl req -new -subj '/C=DE/ST=None/L=None/O=None/CN=localhost' -x509 -days 365 -nodes -out /root/self.pem -keyout /root/self.pem; \
    websockify -D --web=/usr/share/novnc/ --cert=/root/self.pem 6080 localhost:5901; \
    echo 'System gestartet. Playit, SSH und VNC (Port 6080) bereit.'; \
    tail -f /dev/null"
