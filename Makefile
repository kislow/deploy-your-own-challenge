# ============================================
# Ansible Challenge Deployment (Lean Makefile)
# ============================================

# Defaults
ANSIBLE_DIR := ansible
PLAYBOOK := $(ANSIBLE_DIR)/playbook.yaml
ANSIBLE_OPTS := --diff -v
export ANSIBLE_CONFIG := $(ANSIBLE_DIR)/ansible.cfg

# Script locations
SETUP_SCRIPT := ./utils/setup_env.sh
CHALLENGE_SCRIPT := ./utils/challenges.sh
EC2_SCRIPT := ./utils/ec2_manager.sh

# Define comma for use in recipes
comma := ,

# ============================================
# Environment Setup
# ============================================

.PHONY: setup
setup:
	@echo "🧩 Setting up environment..."
	@$(SETUP_SCRIPT)

# ============================================
# Terraform EC2 Management
# ============================================

.PHONY: ec2-plan ec2-create ec2-destroy
ec2-plan:
	@$(EC2_SCRIPT) plan
ec2-create:
	@$(EC2_SCRIPT) create
ec2-destroy:
	@$(EC2_SCRIPT) destroy

# ============================================
# Ansible Challenge Targets
# ============================================

# Verify HOST is set before running anything
check-host:
ifndef HOST
	$(error HOST is not set. Usage: make <target> HOST=<ip_address>)
endif

# Dynamic Challenge Runner
.PHONY: base kind go-app curl webserver psql mongo ssh-keys
base kind go-app curl webserver psql mongo ssh-keys: check-host
	@$(CHALLENGE_SCRIPT) $@ HOST=$(HOST)

# ============================================
# Deployment Modes
# ============================================

.PHONY: deploy quick infra all-challenges deploy-except dry-run dry-run-tag
deploy: check-host
	@$(CHALLENGE_SCRIPT) deploy HOST=$(HOST)

quick: check-host
ifndef TAGS
	$(error TAGS is not set. Usage: make quick HOST=<ip> TAGS=<tag1,tag2>)
endif
	@$(CHALLENGE_SCRIPT) quick HOST=$(HOST) TAGS=$(TAGS)

infra: check-host
	@$(CHALLENGE_SCRIPT) infra HOST=$(HOST)

all-challenges: check-host
	@$(CHALLENGE_SCRIPT) all-challenges HOST=$(HOST)

deploy-except: check-host
ifndef SKIP
	$(error SKIP is not set. Usage: make deploy-except HOST=<ip> SKIP=<tag1,tag2>)
endif
	@$(CHALLENGE_SCRIPT) deploy-except HOST=$(HOST) SKIP=$(SKIP)

dry-run: check-host
	@$(CHALLENGE_SCRIPT) dry-run HOST=$(HOST)

dry-run-tag: check-host
ifndef TAGS
	$(error TAGS is not set. Usage: make dry-run-tag HOST=<ip> TAGS=<tag>)
endif
	@$(CHALLENGE_SCRIPT) dry-run-tag HOST=$(HOST) TAGS=$(TAGS)

# ============================================
# Utility Targets
# ============================================

.PHONY: list-tags show-config test-connection clean help

list-tags:
	@echo "📋 Available role tags:"
	@find $(ANSIBLE_DIR)/roles -maxdepth 1 -type d ! -path "$(ANSIBLE_DIR)/roles" -exec basename {} \; | sed 's/^/  - /'

show-config:
	@echo "📋 Ansible Configuration:"
	@echo "  Playbook: $(PLAYBOOK)"
	@echo "  Config: $(ANSIBLE_CONFIG)"
	@if [ -f "$(ANSIBLE_CONFIG)" ]; then \
		echo ""; echo "Contents:"; grep -E "^[^#;]" $(ANSIBLE_CONFIG) | sed 's/^/  /'; \
	else \
		echo "⚠️ No ansible.cfg found at $(ANSIBLE_CONFIG)"; \
	fi

test-connection: check-host
	@echo "🔌 Testing SSH connection to $(HOST)..."
	@ansible all -m ping -i $(HOST), || \
		(echo "❌ SSH connection failed! Try manually: ssh <user>@$(HOST)"; exit 1)

clean:
	@echo "🧹 Cleaning up retry files..."
	@find . -name "*.retry" -delete 2>/dev/null || true

help:
	@echo "🛠️  Ansible Challenge Deployment"
	@echo ""
	@echo "Usage: make <target> HOST=<ip> [REMOTE_USER=...] [SSH_KEY=...]"
	@echo ""
	@echo "Setup & Utilities:"
	@echo "  setup           - Prepare environment (Python, Ansible, Docker, Roles)"
	@echo "  list-tags       - List available role tags"
	@echo "  show-config     - Show ansible.cfg details"
	@echo "  test-connection - Ping target host via Ansible"
	@echo ""
	@echo "Deployments:"
	@echo "  deploy          - Full deployment"
	@echo "  quick           - Deploy specific tags (TAGS=...)"
	@echo "  infra           - Deploy base infra (base, kind)"
	@echo "  all-challenges   - Deploy all challenges"
	@echo "  deploy-except   - Deploy all except SKIP=..."
	@echo ""
	@echo "Challenges:"
	@echo "  base, kind, go-app, curl, webserver, psql, mongo, ssh-keys"
	@echo ""
	@echo "Terraform EC2:"
	@echo "  ec2-plan, ec2-create, ec2-destroy"
	@echo ""
	@echo "Examples:"
	@echo "  make setup"
	@echo "  make webserver HOST=localhost"
	@echo "  make webserver HOST=192.168.1.100"
	@echo "  make webserver HOST=192.168.1.100 REMOTE_USER=root"
	@echo "  make webserver HOST=ec2-instance REMOTE_USER=ec2-user SSH_KEY=~/.ssh/ec2.pem"
	@echo "  make quick HOST=localhost TAGS=linux-curl-challenge"
	@echo "  make ec2-plan"

.DEFAULT_GOAL := help
