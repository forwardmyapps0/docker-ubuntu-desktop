FROM --platform=linux/amd64 ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

EXPOSE 22 6080 8080

RUN apt update -y && apt install --no-install-recommends -y \
    sudo curl wget xterm init systemd nano net-tools neofetch git tzdata unzip zip screen htop nload openjdk-21-jdk openjdk-8-jdk python3 python3-pip \
    xfce4 xfce4-goodies tigervnc-standalone-server tigervnc-tools novnc websockify \
    dbus-x11 x11-utils x11-xserver-utils x11-apps software-properties-common \
    gnupg ca-certificates xubuntu-icon-theme openssl openssh-server && \
    apt clean && rm -rf /var/lib/apt/lists/*

RUN RANDOM_PASS=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1) && \
    echo "root:$RANDOM_PASS" | chpasswd && \
    mkdir -p /root/.vnc && \
    echo "$RANDOM_PASS" | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd && \
    echo "export MY_PASS=$RANDOM_PASS" >> /root/.bashrc

RUN touch /root/.Xauthority && \
    mkdir -p /var/run/sshd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

CMD bash -c " \
    /usr/sbin/sshd; \
    vncserver -localhost no -SecurityTypes VncAuth -geometry 1024x768 :1; \
    openssl req -new -subj '/C=DE/ST=None/L=None/O=None/CN=localhost' -x509 -days 365 -nodes -out /root/self.pem -keyout /root/self.pem; \
    websockify -D --web=/usr/share/novnc/ --cert=/root/self.pem 6080 localhost:5901; \
    echo '========================================='; \
    echo 'ZUGANG: root / \$MY_PASS'; \
    echo '========================================='; \
    tail -f /dev/null"
