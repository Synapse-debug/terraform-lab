#!/bin/bash
set -e

echo "=== [1/4] Installazione dipendenze ==="
sudo apt-get install -y ca-certificates curl

echo "=== [2/4] Aggiunta repository Docker ==="
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

CODENAME=$(. /etc/os-release; echo "$VERSION_CODENAME")
echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $CODENAME stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "=== [3/4] Installazione Docker Engine ==="
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

echo "=== [4/4] Avvio Docker daemon ==="
sudo service docker start
sudo usermod -aG docker "$USER"

echo ""
echo "=== DOCKER INSTALLATO CON SUCCESSO ==="
docker --version
