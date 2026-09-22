#!/bin/bash
set -x
apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get install -y nginx
# Floci usa la porta 80 su 169.254.169.254 per l'IMDS: nginx va su 8080
sed -i 's/listen 80 default_server;/listen 8080 default_server;/' /etc/nginx/sites-available/default
sed -i 's/listen \[::\]:80 default_server;/listen [::]:8080 default_server;/' /etc/nginx/sites-available/default
echo "<h1>Hello from ${environment} website! Terraform + nginx su Floci 🍕</h1>" > /var/www/html/index.html
nginx || true
sleep 2
(ss -ltnp 2>/dev/null || netstat -ltnp 2>/dev/null) | grep ':8080' || true