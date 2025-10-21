# Installation Guide

Complete setup instructions for **Deploy Your Own Challenge**.

This guide covers everything you need to get started deploying DevOps challenges locally or on remote hosts.

---

## Table of Contents

- [Prerequisites](#prerequisites)
- [Quick Setup](#quick-setup)
- [SSH Configuration](#ssh-configuration)
- [Deployment Overview](#deployment-overview)
- [Verification](#verification)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

### System Requirements

- **Operating System:** Ubuntu 22.04+, Debian 11+, or macOS
- **Memory:** 2GB minimum, 4GB recommended for Kubernetes challenges
- **Disk Space:** 10GB free space
- **Architecture:** x86_64 (amd64) or ARM64

### Required Software

Before running the automated setup, you only need:

- **Git** - for cloning the repository
- **Sudo access** - required for installing dependencies

Everything else (Python, Ansible, Docker, roles) is installed automatically by the setup script.

---

## Quick Setup

### 1. Clone the Repository

```bash
git clone https://github.com/kislow/deploy-your-own-challenge.git
cd deploy-your-own-challenge
```

### 2. Run Automated Setup

```bash
make setup
```

This single command handles everything:
- ✅ Installs Python 3.8+ (if not present)
- ✅ Installs Ansible 2.9+ (if not present)
- ✅ Installs Docker (if not present)
- ✅ Installs required Ansible roles from Galaxy
- ✅ Installs required Ansible collections (community.general, ansible.posix, community.docker, community.kubernetes)
- ✅ Verifies all dependencies

**Expected output:**
```
🚀 Starting environment setup...
✓ python3 found: /usr/bin/python3
✓ ansible-playbook found: /usr/bin/ansible-playbook
✓ docker found: /usr/bin/docker
📦 Installing required Ansible roles...
📚 Installing essential Ansible collections...
✅ Environment setup complete!
```

### 3. You're Ready!

```bash
# Deploy your first challenge locally
make curl HOST=localhost
```

That's it! The Makefile and scripts handle all the complexity.

---

## SSH Configuration

### Local Deployment (No SSH Required)

If you're deploying to **localhost**, SSH is **not required**. The system automatically detects local deployment and uses direct execution:

```bash
make curl HOST=localhost
make webserver HOST=localhost
```

**Challenges deploy to:** `~/linux-curl`, `~/linux-webserver`, etc.

---

### Remote Deployment (SSH Required)

For remote VMs or cloud instances, you need SSH access.

#### Default SSH Settings

By default, deployments use:
- **User:** `ubuntu`
- **SSH Key:** `~/.ssh/id_rsa`

If your setup matches these defaults, no configuration needed:

```bash
make deploy HOST=192.168.1.100
```

#### Custom SSH Credentials

Override the user or SSH key per deployment:

```bash
# Custom user
make webserver HOST=192.168.1.100 REMOTE_USER=admin

# Custom SSH key
make webserver HOST=192.168.1.100 SSH_KEY=~/.ssh/custom_key.pem

# Both
make webserver HOST=ec2-instance REMOTE_USER=ec2-user SSH_KEY=~/.ssh/ec2.pem
```

#### Setting Up SSH Keys

If you don't have SSH keys configured:

```bash
# 1. Generate SSH key (if you don't have one)
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa

# 2. Copy to remote host
ssh-copy-id ubuntu@192.168.1.100

# 3. Test connection
ssh ubuntu@192.168.1.100

# 4. Deploy!
make webserver HOST=192.168.1.100
```

---

## Deployment Overview

All deployment complexity is handled by the Makefile and automation scripts. You just need to know:

### How It Works

1. **You run:** `make <challenge> HOST=<target>`
2. **Script detects:** Is this localhost or remote?
3. **Script configures:** Connection type (local or SSH)
4. **Script deploys:** Ansible playbook with correct settings
5. **Script verifies:** Challenge directory and shows next steps

### Deployment Targets

**Local machine:**
```bash
make curl HOST=localhost
```

**Remote VM (IP address):**
```bash
make curl HOST=192.168.1.100
```

**Remote VM (hostname):**
```bash
make curl HOST=my-server.example.com
```

**Cloud instances:**
```bash
# AWS EC2
make curl HOST=181.168.1.100 REMOTE_USER=ec2-user SSH_KEY=~/.ssh/ec2.pem

# Any cloud provider - same pattern!
```

The scripts automatically handle:
- Connection type (local vs SSH)
- User permissions
- Directory creation
- Challenge verification
- Post-deployment instructions

---

## Cloud Prerequisites

### AWS EC2

**Before deploying to EC2:**
- Launch an instance (recommended: `t3.medium`, Ubuntu 22.04+)
- Configure security group to allow SSH (port 22) from your IP
- Have your EC2 SSH key ready (usually `.pem` file)

**EC2 Management (Optional):**
```bash
# If using the included Terraform scripts
make ec2-plan      # Preview infrastructure
make ec2-create    # Create EC2 instance
make ec2-destroy   # Destroy EC2 instance
```

**Deploy to EC2:**
```bash
make deploy HOST=<ec2-public-ip> \
  REMOTE_USER=ec2-user \
  SSH_KEY=~/.ssh/your-ec2-key.pem
```

---

### Other Cloud Providers

The same pattern works for **any cloud provider** (GCP, DigitalOcean, Linode, etc.):

1. Launch a VM with Ubuntu/Debian
2. Allow SSH access (port 22)
3. Get the public IP
4. Deploy using the Makefile with appropriate credentials

---

## Verification

### Test Your Setup

```bash
# 1. Check versions
python3 --version    # Should be 3.8+
ansible --version    # Should be 2.9+
docker --version     # Should be 20.10+

# 2. List available challenges
make list-tags

# 3. Test localhost connection
make test-connection HOST=localhost

# 4. Test remote connection (if applicable)
make test-connection HOST=192.168.1.100

# 5. Deploy a test challenge
make curl HOST=localhost
```

### Expected Behavior

After a successful deployment, you should see:

```
✅ Deployment complete!

🔍 Verifying challenge directory...
✅ Challenge directory verified at: /home/ubuntu/linux-curl/
📊 Found 1 challenge(s)

To start the challenge:
  cd /home/ubuntu/linux-curl
  cat task.txt
```

---

## Troubleshooting

### Common Issues

#### "Command not found: make"

**Solution:** Install make
```bash
# Ubuntu/Debian
sudo apt install make

# macOS
xcode-select --install
```

---

#### "Host key verification failed"

**Problem:** SSH can't verify the remote host's identity

**Solution:**
```bash
# Option 1: Accept the host key manually
ssh ubuntu@192.168.1.100

# Option 2: Disable host key checking (less secure, use for testing only)
# Already handled in ansible.cfg, but you can also:
export ANSIBLE_HOST_KEY_CHECKING=False
```

---

#### "Permission denied (publickey)"

**Problem:** SSH authentication failed

**Solutions:**
```bash
# 1. Verify your SSH key works
ssh -i ~/.ssh/id_rsa ubuntu@192.168.1.100

# 2. Check file permissions
chmod 600 ~/.ssh/id_rsa

# 3. Verify you're using the correct user
make deploy HOST=192.168.1.100 REMOTE_USER=ubuntu

# 4. Verify you're using the correct key
make deploy HOST=192.168.1.100 SSH_KEY=~/.ssh/id_rsa
```

---

#### "Ansible role not found"

**Problem:** Required Ansible roles weren't installed

**Solution:**
```bash
# Re-run setup
make setup

# Or manually install roles
cd ansible
ansible-galaxy install -r requirements.yml -p roles/
```

---

#### "Docker daemon not running"

**Problem:** Docker isn't started (for Docker-based challenges)

**Solution:**
```bash
# Ubuntu/Debian
sudo systemctl start docker
sudo systemctl enable docker

# Verify
docker ps
```

---

#### "Challenge directory not found"

**Problem:** Deployment completed but challenge files aren't where expected

**Diagnostics:**
```bash
# For localhost, check your home directory
ls -la ~/

# For remote hosts
ssh ubuntu@192.168.1.100 "ls -la ~/"

# Look for directories like:
# - linux-curl
# - linux-webserver
# - go-app
# - postgres-docker
```

---

#### "Sudo password required"

**Problem:** Some tasks require sudo privileges

**Solution:**
```bash
# For localhost deployments, ensure your user has passwordless sudo
# Or run with sudo privileges when prompted

# For remote deployments, ensure the remote user can sudo
ssh ubuntu@192.168.1.100 "sudo -v"
```

---

### Getting Help

If you encounter issues not covered here:

1. **Check logs:** Ansible provides detailed output during deployment
2. **Run dry-run:** `make dry-run HOST=<target>` to see what would change
3. **Test connection:** `make test-connection HOST=<target>` to verify SSH access
4. **Open an issue:** [GitHub Issues](https://github.com/kislow/deploy-your-own-challenge/issues)

---

### Debug Mode

For more detailed output during deployment:

```bash
# Add -vvv for verbose Ansible output (handled internally)
# Or check the ansible playbook output directly
ansible-playbook -i "localhost," ansible/playbook.yaml --tags linux-curl-challenge -vvv
```

---

## Next Steps

Once installation is complete:

1. 📖 Return to the [README](README.md) for usage examples
2. 🎯 Browse [available challenges](README.md#available-challenges)
3. 🚀 Deploy your first challenge: `make curl HOST=localhost`
4. 📚 Explore the challenge directories and start learning!

---

**Ready to deploy?** Head back to the [main README](README.md) to get started!
