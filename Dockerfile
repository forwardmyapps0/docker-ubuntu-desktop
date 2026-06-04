FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /tmp

# Pakete installieren
RUN apt-get update && apt-get install -y \
    python3-dev \
    python3-libvirt \
    python3-lxml \
    libsasl2-modules \
    gcc \
    libc6-dev \
    libvirt-dev \
    iproute2 \
    nginx \
    supervisor \
    git \
    openssh-client \
    curl \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Webvirtcloud installieren
RUN curl -L https://github.com/retspen/webvirtcloud/tarball/master | tar xzC /opt/ \
   && mv /opt/retspen-webvirtcloud* /opt/webvirtcloud \
   && pip3 install --no-cache-dir -r /opt/webvirtcloud/conf/requirements.txt \
   && mkdir -p /run/supervisor/ \
   && cp /opt/webvirtcloud/conf/nginx/webvirtcloud.conf /etc/nginx/conf.d/webvirtcloud.conf \
   && sed -i 's/\/srv\/webvirtcloud/\/opt\/webvirtcloud/' /etc/nginx/conf.d/webvirtcloud.conf \
   && ln -sf /dev/stdout /var/log/nginx/access.log \
   && ln -sf /dev/stderr /var/log/nginx/error.log

# SSH Konfiguration
RUN mkdir -p /root/.ssh \
   && echo "Host *\n  StrictHostKeyChecking no" >> /root/.ssh/config

# Entrypoint vorbereiten
COPY entrypoint.sh /opt/entrypoint.sh
RUN chmod +x /opt/entrypoint.sh

# Supervisord Konfiguration
COPY conf/supervisord.ini /etc/supervisor/conf.d/webvirtcloud.conf

WORKDIR /opt
ENTRYPOINT ["/opt/entrypoint.sh"]

EXPOSE 80 6080
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf", "-n"]
