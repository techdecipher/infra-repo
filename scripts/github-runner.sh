#!/bin/bash

# Update and install packages
yum update -y
yum install -y curl unzip git jq docker shadow-utils

# Enable and start Docker
systemctl enable docker
systemctl start docker

# Create runner user and add to docker group
useradd -m runner && usermod -aG docker runner

# Go to runner home
cd /home/runner
chown runner:runner /home/runner

# Set GitHub repo details
GH_OWNER="techdecipher"
GH_REPO="infra-repo"
GH_PAT=$(aws ssm get-parameter --name /github/pat --with-decryption --query Parameter.Value --output text)
RUNNER_LABELS="self-hosted,eks"
GH_RUNNER_URL="https://github.com/${GH_OWNER}/${GH_REPO}"

# Switch to runner user for the rest
sudo -u runner bash <<EOF
cd /home/runner

# Download latest runner version
curl -L -H "Accept: application/octet-stream" \
  -o actions-runner-linux-x64.tar.gz \
  https://github.com/actions/runner/releases/download/v2.314.1/actions-runner-linux-x64-2.314.1.tar.gz

mkdir -p actions-runner && cd actions-runner
tar -xzf ../actions-runner-linux-x64.tar.gz

# Configure the runner
./config.sh --url ${GH_RUNNER_URL} \
  --token \$(curl -s -H "Authorization: token ${GH_PAT}" \
  https://api.github.com/repos/${GH_OWNER}/${GH_REPO}/actions/runners/registration-token | jq -r .token) \
  --unattended --labels ${RUNNER_LABELS} --name runner-eks

# Start the runner
./run.sh
EOF

