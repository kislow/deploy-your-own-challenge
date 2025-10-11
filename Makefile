# Makefile for Ansible Challenge Deployment
# Usage: make <target> HOST=<ip_address>

# Default values
ANSIBLE_DIR := ansible
PLAYBOOK := $(ANSIBLE_DIR)/playbook.yaml
ANSIBLE_OPTS := --diff -v

export ANSIBLE_CONFIG := $(ANSIBLE_DIR)/ansible.cfg

# Check if HOST is set
check-host:
ifndef HOST
	$(error HOST is not set. Usage: make <target> HOST=<ip_address>)
endif

# Helper function for running ansible-playbook
define run-ansible
	@echo "🚀 Running: $(1)"
	ansible-playbook $(ANSIBLE_OPTS) -i $(HOST), $(PLAYBOOK) $(2)
endef

# Main deployment (all roles)
.PHONY: deploy
deploy: check-host
	$(call run-ansible,Full deployment,)

# Quick deploy with specific tags
.PHONY: quick
quick: check-host
ifndef TAGS
	$(error TAGS is not set. Usage: make quick HOST=<ip> TAGS=<tag1,tag2>)
endif
	$(call run-ansible,Quick deployment with tags: $(TAGS),--tags $(TAGS))

# Base setup
.PHONY: base
base: check-host
	$(call run-ansible,Base setup,--tags base)

# Infrastructure components
.PHONY: kind
kind: check-host
	$(call run-ansible,Kind cluster setup,--tags kind)

.PHONY: go-app
docker: check-host
	$(call run-ansible,Go App exercise,--tags go-docker-exercise)

.PHONY: curl
curl: check-host
	$(call run-ansible,Linux curl exercise,--tags linux-curl-exercise)

.PHONY: webserver
webserver: check-host
	$(call run-ansible,Linux webserver exercise,--tags linux-webserver-exercise)

.PHONY: psql
psql: check-host
	$(call run-ansible,Postgresql exercise,--tags postgres-docker-exercise)

# SSH Key management (uses group_vars/all.yml)
.PHONY: ssh-keys
ssh-keys: check-host
	$(call run-ansible,Add SSH public keys,--tags ssh-keys)

.PHONY: ssh-keys-dry-run
ssh-keys-dry-run: check-host
	@echo "🔍 Dry run - SSH keys deployment"
	ansible-playbook $(ANSIBLE_OPTS) -i $(HOST), $(PLAYBOOK) --tags ssh-keys --check --diff

.PHONY: ssh-keys-info
ssh-keys-info:
	@echo "📋 SSH Keys Information:"
	@echo "   Keys are defined in: $(ANSIBLE_DIR)/group_vars/all.yml"
	@echo "   Variable name: pub_keys"
	@echo "   Format: ssh-rsa AAAAB3NzaC1yc2E... comment"
	@echo ""
	@echo "Usage: make ssh-keys HOST=192.168.1.100"
	@echo "       make ssh-keys-dry-run HOST=192.168.1.100"

# Combination deployments
.PHONY: all-exercises
all-exercises: check-host
	$(call run-ansible,All exercises,--tags go-docker-exercise$(comma)linux-curl-exercise$(comma)linux-webserver-exercise$(comma)postgres-docker-exercise)


.PHONY: infra
infra: check-host
	$(call run-ansible,Infrastructure setup,--tags base$(comma)kind)

# Deploy with exclusions
.PHONY: deploy-except
deploy-except: check-host
ifndef SKIP
	$(error SKIP is not set. Usage: make deploy-except HOST=<ip> SKIP=<tag1,tag2>)
endif
	$(call run-ansible,Deployment excluding: $(SKIP),--skip-tags $(SKIP))

# Dry run commands
.PHONY: dry-run
dry-run: check-host
	@echo "🔍 Dry run - Full deployment"
	ansible-playbook $(ANSIBLE_OPTS) -i $(HOST), $(PLAYBOOK) --check

.PHONY: dry-run-tag
dry-run-tag: check-host
ifndef TAGS
	$(error TAGS is not set. Usage: make dry-run-tag HOST=<ip> TAGS=<tag>)
endif
	@echo "🔍 Dry run with tags: $(TAGS)"
	ansible-playbook $(ANSIBLE_OPTS) -i $(HOST), $(PLAYBOOK) --tags $(TAGS) --check

.PHONY: list-tags
list-tags:
	@echo "📋 Available tags (auto-detected):"
	@find $(ANSIBLE_DIR)/roles -maxdepth 1 -type d ! -path "$(ANSIBLE_DIR)/roles" -exec basename {} \; | sed 's/^/  - /'

.PHONY: show-config
show-config:
	@echo "📋 Ansible Configuration:"
	@echo "   Playbook: $(PLAYBOOK)"
	@echo "   Config file: $(ANSIBLE_CONFIG)"
	@echo "   ANSIBLE_CONFIG env: $(ANSIBLE_CONFIG)"
	@if [ -f "$(ANSIBLE_CONFIG)" ]; then \
		echo ""; \
		echo "   ansible.cfg contents:"; \
		echo "   ---------------------"; \
		grep -E "^[^#;]" $(ANSIBLE_CONFIG) | sed 's/^/   /'; \
	else \
		echo "   ⚠️  No ansible.cfg found at $(ANSIBLE_CONFIG)"; \
	fi

.PHONY: test-connection
test-connection: check-host
	@echo "🔌 Testing SSH connection to $(HOST)..."
	@ansible all -m ping -i $(HOST), || \
		(echo ""; \
		echo "❌ Connection failed!"; \
		echo ""; \
		echo "Troubleshooting tips:"; \
		echo "1. Check if the SSH key is correct:"; \
		echo "   make test-connection HOST=$(HOST)"; \
		echo ""; \
		echo "2. Test SSH manually:"; \
		echo "   ssh <user>@$(HOST)"; \
		echo ""; \
		echo "3. Ensure the key has correct permissions:"; \
		echo "   chmod 600 <your-key-file>"; \
		echo ""; \
		echo "4. Check if you need a different user:"; \
		echo "   Common users: ubuntu, ec2-user, admin, root, centos"; \
		echo ""; \
		exit 1)

.PHONY: help
help:
	@echo "🛠️  Ansible Challenge Deployment Makefile"
	@echo ""
	@echo "📍 Location: This Makefile should be in the project root directory"
	@echo "            (same level as README.md, .gitignore, and the 'ansible' folder)"
	@echo ""
	@echo "Usage: make <target> HOST=<ip_address> [OPTIONS]"
	@echo ""
	@echo "Main Targets:"
	@echo "  deploy           - Run full deployment"
	@echo "  quick            - Deploy specific tags (requires TAGS=tag1,tag2)"
	@echo "  infra            - Deploy infrastructure (base, kind, wetty)"
	@echo "  all-exercises    - Deploy all exercises"
	@echo ""
	@echo "Individual Exercises:"
	@echo "  base             - Base setup"
	@echo "  kind             - Kind cluster"
	@echo "  go-app           - Go App exercise"
	@echo "  helm             - Helm exercise"
	@echo "  curl             - Linux curl exercise"
	@echo "  webserver        - Linux webserver exercise"
	@echo "  psql        - Postgresql docker exercise"
	@echo "  ssh-keys         - Add SSH public keys from group_vars"
	@echo ""
	@echo "Combination Targets:"
	@echo "  deploy-except    - Deploy all except specified (requires SKIP=tag1,tag2)"
	@echo ""
	@echo "Utility Targets:"
	@echo "  dry-run          - Dry run full deployment"
	@echo "  dry-run-tag      - Dry run specific tags (requires TAGS=tag)"
	@echo "  ssh-keys-dry-run - Dry run SSH key deployment"
	@echo "  ssh-keys-info    - Show SSH key configuration info"
	@echo "  list-tags        - List all available tags"
	@echo "  help             - Show this help message"
	@echo ""
	@echo "Examples:"
	@echo "  make deploy HOST=192.168.1.100"
	@echo "  make k8s-pod HOST=192.168.1.100"
	@echo "  make quick HOST=192.168.1.100 TAGS=docker,helm"
	@echo "  make ssh-keys HOST=192.168.1.100"
	@echo "  make ssh-keys-dry-run HOST=192.168.1.100"
	@echo "  make deploy-except HOST=192.168.1.100 SKIP=postgres-docker,linux-webserver"
	@echo "  make dry-run HOST=192.168.1.100"

# Clean up (if needed for local testing artifacts)
.PHONY: clean
clean:
	@echo "🧹 Cleaning up local artifacts..."
	@find . -name "*.retry" -delete 2>/dev/null || true
	@echo "✨ Clean complete"

# Define comma for use in recipes
comma := ,

# Default target
.DEFAULT_GOAL := help
