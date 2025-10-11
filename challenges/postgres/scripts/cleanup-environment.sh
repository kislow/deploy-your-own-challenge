#!/bin/bash

echo "========================================="
echo "Cleaning up PostgreSQL Docker Challenge"
echo "========================================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Stop port blocker
echo -e "${YELLOW}Removing port blocker...${NC}"
$SCRIPT_DIR/port-blocker.sh stop
echo -e "${GREEN}✓ Port 5432 freed${NC}"

# Remove user kicker
echo -e "${YELLOW}Removing user kicker...${NC}"
$SCRIPT_DIR/user-kicker.sh uninstall
echo -e "${GREEN}✓ User kicker removed${NC}"

# Remove decoy volume
docker volume rm old_postgres_backup 2>/dev/null || true
echo -e "${GREEN}✓ Decoy volume removed${NC}"

# Ask about exercise cleanup
echo ""
read -p "Remove all exercise containers and volumes? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Stop and remove containers
    docker-compose down 2>/dev/null || true
    docker-compose -f docker-compose-broken.yml down 2>/dev/null || true

    # Remove exercise volumes
    docker volume rm company_postgres_data 2>/dev/null || true
    docker volume rm postgres_data 2>/dev/null || true

    echo -e "${GREEN}✓ Exercise containers and volumes cleaned${NC}"

    # Clean backup directory
    if [ -d "./backups" ]; then
        rm -f ./backups/*.sql
        echo -e "${GREEN}✓ Backup files cleaned${NC}"
    fi
fi

echo ""
echo -e "${GREEN}=========================================${NC}"
echo -e "${GREEN}Cleanup complete!${NC}"
echo -e "${GREEN}=========================================${NC}"
