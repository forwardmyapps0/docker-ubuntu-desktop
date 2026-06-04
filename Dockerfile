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
    apt-get update && apt-get install -y cloudflared && \
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

# Ports freigeben
EXPOSE 6080

# Start-Logik
CMD bash -c " \
    mkdir -p /root/.vnc; \
    echo 'SecurityTypes=None' > /root/.vnc/config; \
    vncserver -localhost no -geometry 1024x768 :1; \
    openssl req -new -subj '/C=DE/ST=None/L=None/O=None/CN=localhost' -x509 -days 365 -nodes -out /root/self.pem -keyout /root/self.pem; \
    websockify -D --web=/usr/share/novnc/ --cert=/root/self.pem 6080 localhost:5901; \
    filebrowser -d /root/filebrowser.db config init --address 0.0.0.0 --port 8080; \
    filebrowser -d /root/filebrowser.db users add admin admin --perm.admin; \
    filebrowser -d /root/filebrowser.db; \
    echo 'System gestartet. Cloudflared, Filebrowser und VNC (Port 6080) bereit.'; \
    tail -f /dev/null"
