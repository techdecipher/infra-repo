#!/bin/bash
set -euxo pipefail

apt-get update -y
apt-get install -y docker.io awscli snapd
systemctl enable --now docker

# SSM Agent (Ubuntu 20.04 via snap)
snap install amazon-ssm-agent --classic
systemctl enable --now snap.amazon-ssm-agent.amazon-ssm-agent.service

# Placeholder app
docker run -d --name site -p 80:80 --restart unless-stopped nginx:alpine
