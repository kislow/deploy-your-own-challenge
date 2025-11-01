#!/bin/bash
#
# MongoDB Backup Script - TEMPLATE
# Students: Fill in the TODOs to complete this script
#

set -e  # Exit on any error

# Configuration
BACKUP_DIR=""
LOG_FILE=""
RETENTION_DAYS=7

# TODO: Source the credentials file
# Hint: Use 'source' command to load .mongo_credentials
# Your code here:


# TODO: Create timestamp variable for backup directory
# Format: YYYY-MM-DD_HH-MM-SS
# Hint: Use 'date' command
# Your code here:
TIMESTAMP=""


# Create backup directory with timestamp
BACKUP_PATH="${BACKUP_DIR}/${TIMESTAMP}"

# TODO: Create the backup directory
# Hint: Use 'mkdir -p'
# Your code here:


# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "Starting backup process..."
log "Backup location: ${BACKUP_PATH}"

# TODO: Run mongodump command
# Requirements:
# - Connect using credentials from .mongo_credentials
# - Backup only 'production_db' database
# - Output to ${BACKUP_PATH}
# - Enable gzip compression
# Hint: mongodump --uri or mongodump -h -u -p --authenticationDatabase
# Your code here:


# TODO: Check if mongodump was successful
# Hint: Check exit code with $?
# Your code here:


# TODO: Calculate backup size
# Hint: Use 'du -sh' command
# Your code here:
BACKUP_SIZE=""


log "Backup completed successfully"
log "Backup size: ${BACKUP_SIZE}"

# TODO: Implement retention policy
# Delete backups older than RETENTION_DAYS
# Hint: Use 'find' command with -mtime
# BE CAREFUL: Don't delete today's backup!
# Your code here:


log "Backup retention cleanup completed"
log "Backup process finished successfully"

exit 0
