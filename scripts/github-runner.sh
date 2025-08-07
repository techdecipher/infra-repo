#!/bin/bash
set -e

yum update -y
yum install -y curl unzip jq git docker aws-cli

# Start docker service
systemctl start docker
systemctl enable docker

# Create runner user
useradd -m runner && usermod -aG docker runner
cd /home/runner

# Load GitHub PAT from SSM
GH_PAT=$(aws ssm get-parameter --name /github/pat --with-decryption --query Parameter.Value --output text --region us-east-1)

GH_OWNER="techdecipher"
GH_REPO="infra-repo"
GH_RUNNER_URL="https://github.com/${GH_OWNER}/${GH_REPO}"
RUNNER_LABELS="self-hosted,eks"

# Install GitHub Runner
curl -o actions-runner-linux-x64.tar.gz -L https://github.com/actions/runner/releases/download/v2.314.1/actions-runner-linux-x64-2.314.1.tar.gz
mkdir actions-runner && cd actions-runner
tar xzf ../actions-runner-linux-x64.tar.gz

# Register the runner
./config.sh --url ${GH_RUNNER_URL} --token $(curl -s -H "Authorization: token ${GH_PAT}" \
  https://api.github.com/repos/${GH_OWNER}/${GH_REPO}/actions/runners/registration-token | jq -r .token) \
  --unattended --labels ${RUNNER_LABELS} --name runner-eks

# Run as service
./svc.sh install
./svc.sh start

