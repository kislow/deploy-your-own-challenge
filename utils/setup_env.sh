#!/bin/bash
set -e

# -----------------------------------------------------------
# DevOps Environment Setup Script
# Location: util/setup_env.sh
# -----------------------------------------------------------

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}🚀 Starting environment setup...${NC}"


# Detect project root (assume script is in util/)
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ANSIBLE_DIR="$PROJECT_ROOT/ansible"

# -----------------------------------------------------------
# Helper: Command Checker
# -----------------------------------------------------------
check_command() {
    if ! command -v "$1" &>/dev/null; then
        echo -e "${RED}✗ $1 not found${NC}"
        return 1
    else
        echo -e "${GREEN}✓ $1 found: $(command -v $1)${NC}"
        return 0
    fi
}

# -----------------------------------------------------------
# 1️⃣ Check Python
# -----------------------------------------------------------
if ! check_command python3; then
    echo -e "${YELLOW}Installing Python3...${NC}"
    sudo apt update -y && sudo apt install -y python3 python3-pip
fi

# -----------------------------------------------------------
# 2️⃣ Check Ansible
# -----------------------------------------------------------
if ! check_command ansible-playbook; then
    echo -e "${YELLOW}Installing Ansible...${NC}"
    sudo apt update -y && sudo apt install -y ansible
fi

# -----------------------------------------------------------
# 3️⃣ Check Docker
# -----------------------------------------------------------
if ! check_command docker; then
    echo -e "${YELLOW}Installing Docker...${NC}"
    sudo apt update -y
    sudo apt install -y ca-certificates curl gnupg lsb-release

    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
      https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt update -y
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    sudo systemctl enable docker
    sudo systemctl start docker
    echo -e "${GREEN}✓ Docker installed and running${NC}"
fi

# -----------------------------------------------------------
# 4️⃣ Install Required Ansible Roles and Collections
# -----------------------------------------------------------
if [ -d "$ANSIBLE_DIR" ]; then
    cd "$ANSIBLE_DIR"

    echo -e "\n${YELLOW}📦 Installing required Ansible roles...${NC}"
    if [ -f "$ANSIBLE_DIR/requirements.yml" ]; then
        ansible-galaxy install -r requirements.yml -p roles/
    else
        echo -e "${RED}⚠️ No ansible/requirements.yml found, skipping role installation.${NC}"
    fi

    echo -e "\n${YELLOW}📚 Installing essential Ansible collections...${NC}"
    ansible-galaxy collection install \
        community.general \
        ansible.posix \
        community.docker \
        community.kubernetes

    cd "$PROJECT_ROOT"
else
    echo -e "${RED}❌ ansible directory not found at $ANSIBLE_DIR${NC}"
fi

# -----------------------------------------------------------
# 5️⃣ Verify Environment Versions
# -----------------------------------------------------------
echo -e "\n${YELLOW}🧩 Verifying tool versions...${NC}"
python3 --version
ansible --version | head -n 1
docker --version

echo -e "\n${GREEN}✅ Environment setup complete!${NC}"
echo -e "You can now safely run: ${YELLOW}make webserver HOST=localhost${NC}\n"
