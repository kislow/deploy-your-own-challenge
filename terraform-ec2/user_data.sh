#!/bin/bash

# Update system
apt-get update -y

# Install Docker using the convenience script
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Determine the non-root user dynamically
USER_NAME=$(logname 2>/dev/null || echo $SUDO_USER || echo $(whoami))

# Add user to docker group
usermod -aG docker "$USER_NAME"

# Enable and start Docker
systemctl enable docker
systemctl start docker

# Clean up
rm get-docker.sh

# Create setup completion marker
echo "Docker setup completed at $(date)" > "/home/$USER_NAME/.docker-setup-complete"
