FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1

WORKDIR /opt/webvirtcloud

# Installation der Abhängigkeiten und Cleanup in einem Schritt
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3-dev \
    python3-venv \
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
    && rm -rf /var/lib/apt/lists/*

# Webvirtcloud vorbereiten
RUN curl -L https://github.com/retspen/webvirtcloud/tarball/master | tar xzC /opt/ --strip-components=1 \
    && python3 -m venv /opt/venv \
    && /opt/venv/bin/pip install --no-cache-dir -r /opt/webvirtcloud/conf/requirements.txt \
    && mkdir -p /run/supervisor/ /var/log/webvirtcloud/ \
    && cp /opt/webvirtcloud/conf/nginx/webvirtcloud.conf /etc/nginx/conf.d/webvirtcloud.conf \
    && sed -i 's/\/srv\/webvirtcloud/\/opt\/webvirtcloud/' /etc/nginx/conf.d/webvirtcloud.conf \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

# SSH Config
RUN mkdir -p /root/.ssh && chmod 700 /root/.ssh \
    && echo "Host *\n  StrictHostKeyChecking no" > /root/.ssh/config

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

COPY conf/supervisord.ini /etc/supervisor/conf.d/webvirtcloud.conf

EXPOSE 80 6080

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
