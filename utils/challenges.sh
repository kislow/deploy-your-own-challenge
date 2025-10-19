#!/bin/bash
# ============================================
# Challenge Runner for Ansible Exercises
# ============================================
set -euo pipefail

# 🧩 Source environment setup
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Load environment setup (installs dependencies, collections, etc.)
source "${PROJECT_ROOT}/utils/setup_env.sh"

echo "🧭 Setting up challenges..."

ANSIBLE_DIR="ansible"
PLAYBOOK="${ANSIBLE_DIR}/playbook.yaml"
ANSIBLE_OPTS="--diff -v"
export ANSIBLE_CONFIG="${ANSIBLE_DIR}/ansible.cfg"

HOST="${HOST:-}"
if [[ -z "$HOST" ]]; then
  echo "❌ HOST not set. Usage: make <target> HOST=<ip_address>"
  exit 1
fi

run_ansible() {
  local desc="$1"
  local tags="$2"

  echo "🚀 ${desc}"

  if [[ -n "${tags}" ]]; then
    ansible-playbook ${ANSIBLE_OPTS} -i "${HOST}," "${PLAYBOOK}" --tags "${tags}"
  else
    ansible-playbook ${ANSIBLE_OPTS} -i "${HOST}," "${PLAYBOOK}"
  fi
}

case "${1:-}" in
  base)        run_ansible "Base setup" "base" ;;
  kind)        run_ansible "Kind cluster setup" "kind" ;;
  go-app)      run_ansible "Go App exercise" "go-app-challenge" ;;
  curl)        run_ansible "Linux curl exercise" "linux-curl-challenge" ;;
  webserver)   run_ansible "Linux webserver exercise" "linux-webserver-challenge" ;;
  psql)        run_ansible "PostgreSQL docker exercise" "postgres-docker-challenge" ;;
  ssh-keys)    run_ansible "Add SSH public keys" "ssh-keys" ;;
  deploy)      run_ansible "Full deployment" "" ;;
  *)
    echo "Usage: $0 {base|kind|go-app|curl|webserver|psql|ssh-keys|deploy}"
    exit 1
    ;;
esac
