#!/bin/bash

# Install GitHub Actions Runner
apt update -y
apt install -y curl unzip jq git docker.io

# Add GitHub runner user
useradd -m runner && usermod -aG docker runner
cd /home/runner

# Replace these values with your repo details
GH_OWNER="techdecipher"
GH_REPO="infra-repo"
GH_PAT=$(aws ssm get-parameter --name /github/pat --with-decryption --query Parameter.Value --output text)
RUNNER_LABELS="self-hosted,eks"

GH_RUNNER_URL="https://github.com/${GH_OWNER}/${GH_REPO}"

# Download latest runner
curl -o actions-runner-linux-x64.tar.gz -L https://github.com/actions/runner/releases/latest/download/actions-runner-linux-x64-2.314.1.tar.gz
mkdir actions-runner && cd actions-runner
tar xzf ../actions-runner-linux-x64.tar.gz

# Configure runner
./config.sh --url ${GH_RUNNER_URL} --token $(curl -s \
  -H "Authorization: token ${GH_PAT}" \
  https://api.github.com/repos/${GH_OWNER}/${GH_REPO}/actions/runners/registration-token | jq -r .token) \
  --unattended --labels ${RUNNER_LABELS} --name runner-eks

# Start the runner
./run.sh

