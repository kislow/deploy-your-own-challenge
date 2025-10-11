#!/bin/bash

echo "========================================="
echo "PostgreSQL Persistence Verification"
echo "========================================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASS_COUNT=0
FAIL_COUNT=0

# Function to check test result
check_result() {
    if [ $1 -eq 0 ]; then
        echo -e "${GREEN}✓ $2${NC}"
        ((PASS_COUNT++))
    else
        echo -e "${RED}✗ $2${NC}"
        ((FAIL_COUNT++))
    fi
}

# Test 1: Check if docker-compose.yml exists
echo -e "${YELLOW}Test 1: Docker Compose Configuration${NC}"
if [ -f "docker-compose.yml" ]; then
    # Check for volume configuration
    grep -q "volumes:" docker-compose.yml && grep -q "postgres_data" docker-compose.yml
    check_result $? "Docker Compose has volume configuration"

    # Check if they handled the port issue
    if grep -q "5433:5432" docker-compose.yml || grep -q "5434:5432" docker-compose.yml; then
        check_result 0 "Port conflict handled (using alternative port)"
    elif ! sudo lsof -i :5432 > /dev/null 2>&1; then
        check_result 0 "Port conflict resolved (5432 is free)"
    else
        check_result 1 "Port 5432 conflict not resolved"
    fi
else
    check_result 1 "docker-compose.yml not found"
fi

# Test 2: Check if .env file exists
echo -e "\n${YELLOW}Test 2: Environment Security${NC}"
if [ -f ".env" ]; then
    check_result 0 ".env file exists"
    # Check that password is not in docker-compose.yml
    if grep -q "POSTGRES_PASSWORD=" docker-compose.yml 2>/dev/null; then
        check_result 1 "Password should not be in docker-compose.yml"
    else
        check_result 0 "Password not hardcoded in docker-compose.yml"
    fi
else
    check_result 1 ".env file not found"
fi

# Test 3: Check if container is running
echo -e "\n${YELLOW}Test 3: Container Status${NC}"
CONTAINER_NAME=$(docker-compose ps -q 2>/dev/null | head -1)
if [ -n "$CONTAINER_NAME" ]; then
    check_result 0 "PostgreSQL container is running"

    # Check health if healthcheck exists
    HEALTH=$(docker inspect --format='{{if .State.Health}}{{.State.Health.Status}}{{else}}no-healthcheck{{end}}' $CONTAINER_NAME 2>/dev/null)
    if [ "$HEALTH" == "healthy" ]; then
        check_result 0 "Container healthcheck passing"
    elif [ "$HEALTH" == "no-healthcheck" ]; then
        echo -e "${YELLOW}ℹ No healthcheck configured (optional)${NC}"
    else
        check_result 1 "Container healthcheck failing: $HEALTH"
    fi
else
    check_result 1 "PostgreSQL container not running"
fi

# Test 4: Check volume exists
echo -e "\n${YELLOW}Test 4: Volume Persistence${NC}"
# Try to get volume name from docker-compose
if [ -f "docker-compose.yml" ]; then
    # Look for named volume
    if docker volume ls | grep -q "postgres_data\|company_postgres_data"; then
        VOLUME_NAME=$(docker volume ls | grep -E "postgres_data|company_postgres_data" | awk '{print $2}' | head -1)
        docker volume inspect $VOLUME_NAME > /dev/null 2>&1
        check_result $? "Named volume exists: $VOLUME_NAME"
    else
        check_result 1 "No PostgreSQL volume found"
    fi
fi

# Test 5: Test actual persistence
echo -e "\n${YELLOW}Test 5: Data Persistence Test${NC}"
if [ -n "$CONTAINER_NAME" ]; then
    # Try to find the right database and user
    DB_USER=$(grep POSTGRES_USER .env 2>/dev/null | cut -d= -f2 || echo "postgres")
    DB_NAME=$(grep POSTGRES_DB .env 2>/dev/null | cut -d= -f2 || echo "postgres")

    # Create test data
    docker-compose exec -T postgres psql -U $DB_USER -d $DB_NAME -c "CREATE TABLE IF NOT EXISTS persistence_test (id SERIAL PRIMARY KEY, test_time TIMESTAMP DEFAULT NOW());" 2>/dev/null
    docker-compose exec -T postgres psql -U $DB_USER -d $DB_NAME -c "INSERT INTO persistence_test DEFAULT VALUES;" 2>/dev/null

    # Get count before restart
    COUNT_BEFORE=$(docker-compose exec -T postgres psql -U $DB_USER -d $DB_NAME -t -c "SELECT COUNT(*) FROM persistence_test;" 2>/dev/null | tr -d ' ')

    if [ -n "$COUNT_BEFORE" ]; then
        # Restart container
        docker-compose restart > /dev/null 2>&1
        sleep 8  # Give PostgreSQL time to start

        # Get count after restart
        COUNT_AFTER=$(docker-compose exec -T postgres psql -U $DB_USER -d $DB_NAME -t -c "SELECT COUNT(*) FROM persistence_test;" 2>/dev/null | tr -d ' ')

        if [ "$COUNT_BEFORE" == "$COUNT_AFTER" ] && [ -n "$COUNT_AFTER" ]; then
            check_result 0 "Data persists after restart (${COUNT_AFTER} records)"
        else
            check_result 1 "Data lost after restart (Before: $COUNT_BEFORE, After: $COUNT_AFTER)"
        fi
    else
        check_result 1 "Could not create test data"
    fi
else
    echo -e "${YELLOW}⚠ Skipping persistence test (container not running)${NC}"
fi

# Test 6: Test persistence after down/up
echo -e "\n${YELLOW}Test 6: Full Restart Persistence${NC}"
if [ -n "$CONTAINER_NAME" ]; then
    # Add one more record before down
    docker-compose exec -T postgres psql -U $DB_USER -d $DB_NAME -c "INSERT INTO persistence_test DEFAULT VALUES;" 2>/dev/null
    COUNT_BEFORE=$(docker-compose exec -T postgres psql -U $DB_USER -d $DB_NAME -t -c "SELECT COUNT(*) FROM persistence_test;" 2>/dev/null | tr -d ' ')

    # Full down and up
    docker-compose down > /dev/null 2>&1
    sleep 2
    docker-compose up -d > /dev/null 2>&1
    sleep 8  # Give PostgreSQL time to start

    # Check count after full restart
    COUNT_AFTER=$(docker-compose exec -T postgres psql -U $DB_USER -d $DB_NAME -t -c "SELECT COUNT(*) FROM persistence_test;" 2>/dev/null | tr -d ' ')

    if [ "$COUNT_BEFORE" == "$COUNT_AFTER" ] && [ -n "$COUNT_AFTER" ]; then
        check_result 0 "Data persists after down/up (${COUNT_AFTER} records)"
    else
        check_result 1 "Data lost after down/up (Before: $COUNT_BEFORE, After: $COUNT_AFTER)"
    fi
fi

# Test 7: Backup exists
echo -e "\n${YELLOW}Test 7: Backup Implementation${NC}"
if ls backups/*.sql 2>/dev/null | grep -q sql; then
    BACKUP_FILE=$(ls -t backups/*.sql | head -1)
    BACKUP_SIZE=$(stat -f%z "$BACKUP_FILE" 2>/dev/null || stat -c%s "$BACKUP_FILE" 2>/dev/null)
    if [ "$BACKUP_SIZE" -gt 1000 ]; then
        check_result 0 "Valid backup file exists ($(basename $BACKUP_FILE))"
    else
        check_result 1 "Backup file too small (possibly empty)"
    fi
else
    check_result 1 "No backup found in backups/ directory"
fi

# Summary
echo ""
echo "========================================="
echo "VERIFICATION SUMMARY"
echo "========================================="
echo -e "Passed: ${GREEN}$PASS_COUNT${NC}"
echo -e "Failed: ${RED}$FAIL_COUNT${NC}"

if [ $FAIL_COUNT -eq 0 ]; then
    echo -e "\n${GREEN}🎉 ALL TESTS PASSED! Excellent work!${NC}"
    echo -e "${GREEN}Your PostgreSQL setup is production-ready!${NC}"
    exit 0
else
    echo -e "\n${YELLOW}⚠️  Some tests failed. Keep working on it!${NC}"
    echo "Hint: Check .hints.txt if you're stuck"
    exit 1
fi
