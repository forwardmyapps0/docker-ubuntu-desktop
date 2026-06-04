FROM --platform=linux/amd64 ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Pakete effizient installieren
RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo curl wget xterm systemd nano net-tools neofetch git tzdata unzip zip screen htop nload \
    openjdk-21-jdk openjdk-8-jdk python3 python3-pip \
    xfce4 xfce4-goodies tigervnc-standalone-server tigervnc-tools novnc websockify \
    dbus-x11 x11-utils x11-xserver-utils x11-apps software-properties-common \
    gnupg ca-certificates openssl openssh-server && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# SSH konfigurieren: Root-Login und Passwort-Auth erlauben
RUN mkdir -p /var/run/sshd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Entrypoint-Skript kopieren
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 22 6080 8080

ENTRYPOINT ["/entrypoint.sh"]
