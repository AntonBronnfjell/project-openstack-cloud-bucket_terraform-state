#!/usr/bin/env bash
# Run by Terraform null_resource to deploy Swift on the OpenStack host via SSH.
# Env: SWIFT_DEPLOY_ENABLED, SWIFT_DEPLOY_SSH_HOST, SWIFT_DEPLOY_SSH_USER,
#      SWIFT_DEPLOY_SSH_PRIVATE_KEY_PATH, SWIFT_DEPLOY_INFRA_REPO.

set -e

[ "${SWIFT_DEPLOY_ENABLED:-0}" = "1" ] || { echo "Swift deploy disabled (SWIFT_DEPLOY_ENABLED != 1), skipping."; exit 0; }

HOST="${SWIFT_DEPLOY_SSH_HOST:?SWIFT_DEPLOY_SSH_HOST required}"
USER="${SWIFT_DEPLOY_SSH_USER:-root}"
KEY="${SWIFT_DEPLOY_SSH_PRIVATE_KEY_PATH:-}"
REPO="${SWIFT_DEPLOY_INFRA_REPO:-https://github.com/AntonBronnfjell/tooling-openstack-infra-ansible_graphicsforge-infrastructure.git}"
INFRA_PATH="/root/tooling-openstack-infra-ansible_graphicsforge-infrastructure"

SSH_OPTS="-o ConnectTimeout=30 -o StrictHostKeyChecking=accept-new"
[ -n "$KEY" ] && [ -f "$KEY" ] && SSH_OPTS="$SSH_OPTS -i $KEY"

REMOTE_SCRIPT="
set -e
if [ ! -d $INFRA_PATH ]; then
  git clone $REPO $INFRA_PATH
fi
cd $INFRA_PATH && git pull
chmod +x scripts/deploy-swift-on-host.sh 2>/dev/null || true
./scripts/deploy-swift-on-host.sh
"

echo "Deploying Swift on $USER@$HOST (this may take several minutes)..."
ssh $SSH_OPTS "$USER@$HOST" "bash -s" <<< "$REMOTE_SCRIPT"
echo "Swift deploy finished on $HOST."
