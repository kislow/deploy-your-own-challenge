#!/bin/bash

# Create a suspicious cron job that actually does nothing harmful
echo "*/5 * * * * root /usr/bin/find /tmp -name '*.tmp' -mtime +1 -delete" | sudo tee -a /etc/crontab

# Add a suspicious user (disabled, but they'll spend time on it)
sudo useradd -s /bin/false -d /nonexistent suspicious_user
sudo passwd -l suspicious_user

# Create some fake logs
sudo mkdir -p /var/log/intrusion
echo "[$(date)] Attempted login from 192.168.1.100" | sudo tee /var/log/intrusion/detected.log
echo "[$(date)] Firewall rule bypass detected" | sudo tee -a /var/log/intrusion/detected.log
