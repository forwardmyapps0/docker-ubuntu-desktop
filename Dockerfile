FROM --platform=linux/amd64 ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Pakete installieren
RUN apt-get update -y && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    curl gnupg wget xterm nano net-tools neofetch git tzdata unzip zip screen htop nload \
    openjdk-21-jdk openjdk-8-jdk python3 python3-pip \
    xfce4 xfce4-goodies tigervnc-standalone-server tigervnc-tools novnc websockify \
    dbus-x11 x11-utils x11-xserver-utils x11-apps software-properties-common \
    ca-certificates xubuntu-icon-theme openssl lsb-release && \
    # Cloudflared Installation
    mkdir -p --mode=0755 /usr/share/keyrings && \
    curl -fsSL https://pkg.cloudflare.com/cloudflare-main.gpg | tee /usr/share/keyrings/cloudflare-main.gpg >/dev/null && \
    echo "deb [signed-by=/usr/share/keyrings/cloudflare-main.gpg] https://pkg.cloudflare.com/cloudflared $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/cloudflared.list && \
    # Playit.gg Installation
    curl -SsL https://playit-cloud.github.io/ppa/key.gpg | gpg --dearmor | tee /etc/apt/trusted.gpg.d/playit.gpg >/dev/null && \
    echo "deb [signed-by=/etc/apt/trusted.gpg.d/playit.gpg] https://playit-cloud.github.io/ppa/data ./" | tee /etc/apt/sources.list.d/playit-cloud.list && \
    # Updates und Installation
    apt-get update && apt-get install -y cloudflared playit && \
    # Filebrowser Installation
    curl -fsSL https://raw.githubusercontent.com/filebrowser/get/master/get.sh | bash && \
    # Chrome Installation
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    apt-get install -y ./google-chrome-stable_current_amd64.deb && \
    rm google-chrome-stable_current_amd64.deb && \
    # Aufräumen
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Konfigurationen
RUN touch /root/.Xauthority

EXPOSE 6080

# Start-Logik
CMD bash -c " \
    mkdir -p /root/.vnc; \
    echo 'SecurityTypes=None' > /root/.vnc/config; \
    vncserver -localhost no -geometry 1024x768 :1; \
    openssl req -new -subj '/C=DE/ST=None/L=None/O=None/CN=localhost' -x509 -days 365 -nodes -out /root/self.pem -keyout /root/self.pem; \
    websockify -D --web=/usr/share/novnc/ --cert=/root/self.pem 6080 localhost:5901; \
    tail -f /dev/null"
