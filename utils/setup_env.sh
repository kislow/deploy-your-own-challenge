#!/bin/bash
set -e

# -----------------------------------------------------------
# DevOps Environment Setup Script
# Location: utils/setup_env.sh
# -----------------------------------------------------------

# Color definitions
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Detect project root (assumimng the script is in utils/)
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ANSIBLE_DIR="$PROJECT_ROOT/ansible"

# -----------------------------------------------------------
# Helper Functions
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
# Installation Functions
# -----------------------------------------------------------

install_python() {
    echo -e "\n${YELLOW}🐍 Checking Python3...${NC}"
    if ! check_command python3; then
        echo -e "${YELLOW}Installing Python3...${NC}"
        sudo apt update -y && sudo apt install -y python3 python3-pip
        echo -e "${GREEN}✓ Python3 installed${NC}"
    fi
}

install_ansible() {
    echo -e "\n${YELLOW}📘 Checking Ansible...${NC}"
    if ! check_command ansible-playbook; then
        echo -e "${YELLOW}Installing Ansible...${NC}"
        sudo apt update -y && sudo apt install -y ansible
        echo -e "${GREEN}✓ Ansible installed${NC}"
    fi
}

install_docker() {
    echo -e "\n${YELLOW}🐳 Checking Docker...${NC}"
    if ! check_command docker; then
        echo -e "${YELLOW}Installing Docker...${NC}"
        sudo apt update -y
        sudo apt install -y ca-certificates curl gnupg lsb-release

        # Add Docker's official GPG key
        sudo mkdir -p /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
            sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

        # Set up the repository
        echo \
            "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
             https://download.docker.com/linux/ubuntu \
             $(lsb_release -cs) stable" | \
            sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

        # Install Docker Engine
        sudo apt update -y
        sudo apt install -y docker-ce docker-ce-cli containerd.io \
            docker-buildx-plugin docker-compose-plugin

        # Enable and start Docker
        sudo systemctl enable docker
        sudo systemctl start docker

        echo -e "${GREEN}✓ Docker installed and running${NC}"
    fi
}

setup_ansible_dependencies() {
    echo -e "\n${YELLOW}📦 Setting up Ansible dependencies...${NC}"

    if [ ! -d "$ANSIBLE_DIR" ]; then
        echo -e "${RED}❌ ansible directory not found at $ANSIBLE_DIR${NC}"
        return 1
    fi

    cd "$ANSIBLE_DIR"

    echo -e "${YELLOW}📦 Installing required Ansible roles...${NC}"
    if [ -f "$ANSIBLE_DIR/requirements.yml" ]; then
        ansible-galaxy install -r requirements.yml -p roles/
        echo -e "${GREEN}✓ Ansible roles installed${NC}"
    else
        echo -e "${RED}⚠️  No ansible/requirements.yml found, skipping role installation.${NC}"
    fi

    echo -e "\n${YELLOW}📚 Installing essential Ansible collections...${NC}"
    ansible-galaxy collection install \
        community.general \
        ansible.posix \
        community.docker \
        community.kubernetes

    echo -e "${GREEN}✓ Ansible collections installed${NC}"

    cd "$PROJECT_ROOT"
}

verify_installation() {
    echo -e "\n${YELLOW}🧩 Verifying tool versions...${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    echo -e "${YELLOW}Python:${NC} $(python3 --version)"
    echo -e "${YELLOW}Ansible:${NC} $(ansible --version | head -n 1)"
    echo -e "${YELLOW}Docker:${NC} $(docker --version)"

    # Check Docker Compose (v2 first, then v1 fallback)
    echo -en "${YELLOW}Docker Compose:${NC} "
    if docker compose version &>/dev/null; then
        echo -e "$(docker compose version) ${GREEN}→ use: docker compose${NC}"
    elif command -v docker-compose &>/dev/null; then
        echo -e "$(docker-compose --version) ${YELLOW}→ use: docker-compose (legacy)${NC}"
    else
        echo -e "${RED}Not found${NC}"
    fi

    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# -----------------------------------------------------------
# Main Execution
# -----------------------------------------------------------

main() {
    echo -e "${YELLOW}🚀 Starting environment setup...${NC}"
    echo -e "${YELLOW}📂 Project root: ${PROJECT_ROOT}${NC}\n"

    # Install core tools
    install_python
    install_ansible
    install_docker

    # Setup Ansible dependencies
    setup_ansible_dependencies

    # Verify everything
    verify_installation

    # Success message
    echo -e "\n${GREEN}✅ Environment setup complete!${NC}"
    echo -e "You can now safely run: ${YELLOW}make webserver HOST=localhost${NC}\n"
}

# Run main function
main
