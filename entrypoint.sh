#!/usr/bin/env bash
set -e

cd /opt/webvirtcloud

if [ ! -f "webvirtcloud/settings.py" ]; then
  cp webvirtcloud/settings.py.template webvirtcloud/settings.py
  
  # Generierung eines sicheren Keys
  SECRET=$(head /dev/urandom | tr -dc 'a-zA-Z0-9' | head -c 128)
  sed -r "s/SECRET_KEY = .*$/SECRET_KEY = '${SECRET}'/" -i webvirtcloud/settings.py
  
  # Migrationen ausführen
  python3 manage.py migrate

  # SSH Keys generieren
  ssh-keygen -b 4096 -t rsa -f /root/.ssh/id_rsa -q -N ""
  ssh-keygen -t ed25519 -f /root/.ssh/id_ed25519 -q -N ""

  echo "RSA ----------------------------"
  cat /root/.ssh/id_rsa.pub
  echo "---------------------------- RSA"
  echo "ED25519 ------------------------"
  cat /root/.ssh/id_ed25519.pub
  echo "------------------------ ED25519"
fi

exec "$@"
