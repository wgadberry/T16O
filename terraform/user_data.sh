#!/bin/bash
set -ex

# Install Docker and git
dnf install -y docker git
systemctl enable --now docker
usermod -aG docker ec2-user

# Install buildx plugin (required by compose build)
mkdir -p /usr/local/lib/docker/cli-plugins
BUILDX_URL=$(curl -sL https://api.github.com/repos/docker/buildx/releases/latest \
  | grep browser_download_url | grep 'linux-amd64"' | head -1 | cut -d'"' -f4)
curl -fSL "$BUILDX_URL" -o /usr/local/lib/docker/cli-plugins/docker-buildx
chmod +x /usr/local/lib/docker/cli-plugins/docker-buildx

# Install docker-compose plugin
curl -fSL https://github.com/docker/compose/releases/latest/download/docker-compose-linux-x86_64 \
  -o /usr/local/lib/docker/cli-plugins/docker-compose
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

# Clone repo
cd /home/ec2-user
git clone https://github.com/wgadberry/T16O.git t16o
chown -R ec2-user:ec2-user t16o
cd t16o/docker

# Build and start all services
docker compose -f docker-compose.services.yml build
docker compose -f docker-compose.services.yml up -d
