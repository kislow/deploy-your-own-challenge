#!/bin/bash
set -e

# -----------------------------------------------------------
# Docker Installation Script for EC2 User Data
# -----------------------------------------------------------


# -----------------------------------------------------------
# Helper Functions
# -----------------------------------------------------------

log_info() {
    echo -e "[INFO] $1"
}

# -----------------------------------------------------------
# Installation Functions
# -----------------------------------------------------------

update_system() {
    log_info "Updating system packages..."
    apt-get update -y
    log_info "System update completed"
}

install_docker() {
    log_info "Installing Docker..."

    # Download Docker convenience script
    curl -fsSL https://get.docker.com -o get-docker.sh

    # Run installation script
    sh get-docker.sh

    log_info "Docker installation completed"
}

configure_docker_user() {
    log_info "Configuring Docker user permissions..."

    # Determine the non-root user dynamically
    # For EC2 user_data, this will typically be 'ubuntu' or 'ec2-user'
    USER_NAME=$(getent passwd 1000 | cut -d: -f1)

    # Fallback to ubuntu if user not found
    if [ -z "$USER_NAME" ]; then
        USER_NAME="ubuntu"
        log_info "Could not detect user, defaulting to: $USER_NAME"
    else
        log_info "Detected user: $USER_NAME"
    fi

    # Add user to docker group
    if id "$USER_NAME" &>/dev/null; then
        usermod -aG docker "$USER_NAME"
        log_info "User $USER_NAME added to docker group"
    else
        log_error "User $USER_NAME not found, skipping group addition"
    fi
}

start_docker_service() {
    log_info "Starting Docker service..."

    systemctl enable docker
    systemctl start docker

    log_info "Docker service started and enabled"
}

cleanup() {
    log_info "Cleaning up installation files..."

    rm -f get-docker.sh

    log_info "Cleanup completed"
}

create_completion_marker() {
    local USER_NAME=$(getent passwd 1000 | cut -d: -f1)

    if [ -z "$USER_NAME" ]; then
        USER_NAME="ubuntu"
    fi

    local MARKER_FILE="/home/$USER_NAME/.docker-setup-complete"

    log_info "Creating completion marker..."
    echo "Docker setup completed at $(date)" > "$MARKER_FILE"
    chown "$USER_NAME:$USER_NAME" "$MARKER_FILE" 2>/dev/null || true

    log_info "Setup marker created at: $MARKER_FILE"
}

verify_installation() {
    log_info "Verifying Docker installation..."

    if command -v docker &>/dev/null; then
        docker --version
        docker compose version 2>/dev/null || log_info "Docker Compose plugin not available"
        log_info "Docker verification completed"
    else
        log_info "Docker installation verification failed"
        exit 1
    fi
}

# -----------------------------------------------------------
# Main Execution
# -----------------------------------------------------------

main() {
    log_info "Starting Docker setup for EC2 instance..."

    update_system
    install_docker
    configure_docker_user
    start_docker_service
    verify_installation
    cleanup
    create_completion_marker

    log_info "Docker setup completed successfully!"
    log_info "Note: User must log out and log back in for group changes to take effect"
}

# Run main function
main
