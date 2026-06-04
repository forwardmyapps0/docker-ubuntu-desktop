FROM ubuntu:24.04

# Verhindert interaktive Abfragen während der Installation
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    libxext6 \
    libxtst6 \
    libxrender1 \
    virt-manager \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
