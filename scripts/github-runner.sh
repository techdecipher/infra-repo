#!/bin/bash

# Install dependencies
sudo yum update -y
sudo yum install -y curl unzip git jq docker shadow-utils

# Enable & start Docker
sudo systemctl enable docker
sudo systemctl start docker

# Create runner user and give Docker access
sudo useradd -m runner
sudo usermod -aG docker runner

# Replace these
GH_OWNER="techdecipher"
GH_REPO="infra-repo"
GH_PAT=$(aws ssm get-parameter --name /github/pat --with-decryption --query Parameter.Value --output text)
RUNNER_LABELS="self-hosted,eks"
GH_RUNNER_URL="https://github.com/${GH_OWNER}/${GH_REPO}"
RUNNER_VERSION="2.314.1"

# Download & setup as runner user
sudo -i -u runner bash <<EOF
cd ~
mkdir -p actions-runner
cd actions-runner

curl -L -H "Accept: application/octet-stream" \
  -o actions-runner-linux-x64.tar.gz \
  https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz

tar -xzf actions-runner-linux-x64.tar.gz

# Get registration token
TOKEN=\$(curl -s -H "Authorization: token ${GH_PAT}" \
  https://api.github.com/repos/${GH_OWNER}/${GH_REPO}/actions/runners/registration-token | jq -r .token)

# Configure runner
./config.sh --url ${GH_RUNNER_URL} \
  --token \$TOKEN \
  --unattended --labels ${RUNNER_LABELS} --name runner-eks

# Run the runner
./run.sh
EOF

