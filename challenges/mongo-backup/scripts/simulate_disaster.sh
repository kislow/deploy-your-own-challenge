#!/bin/bash
#
# MongoDB Disaster Simulation Script
# WARNING: This will DROP the entire production_db database!
#

set -e

RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${RED}"
cat << "EOF"
╔════════════════════════════════════════════════════════════╗
║                   ⚠️  DISASTER SIMULATION ⚠️                ║
║                                                            ║
║  This script will DROP the entire production_db database   ║
║  This simulates a real production disaster scenario        ║
║                                                            ║
║  🔥 ALL DATA WILL BE PERMANENTLY DELETED! 🔥               ║
╚════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Source credentials
if [ -f "$HOME/mongo-challenge/.mongo_credentials" ]; then
    source "$HOME/mongo-challenge/.mongo_credentials"
elif [ -f ".mongo_credentials" ]; then
    source ".mongo_credentials"
else
    echo -e "${RED}ERROR: Cannot find .mongo_credentials file${NC}"
    echo "Please ensure you're in the mongo-challenge directory or credentials exist in home directory"
    exit 1
fi

# Verify MongoDB is accessible
echo "Checking MongoDB connection..."
if ! mongosh -u "$MONGO_ADMIN_USER" -p "$MONGO_ADMIN_PASSWORD" --authenticationDatabase admin --quiet --eval "db.adminCommand('ping')" > /dev/null 2>&1; then
    echo -e "${RED}ERROR: Cannot connect to MongoDB${NC}"
    echo "Please verify MongoDB is running and credentials are correct"
    exit 1
fi

# Ensure admin has sufficient privileges for the simulation
mongosh -u "$MONGO_ADMIN_USER" -p "$MONGO_ADMIN_PASSWORD" --authenticationDatabase admin --quiet --eval "db.grantRolesToUser('admin', [{ role: 'root', db: 'admin' }])"

echo -e "${YELLOW}"
echo "Current database status:"
mongosh -u "$MONGO_ADMIN_USER" -p "$MONGO_ADMIN_PASSWORD" --authenticationDatabase admin --quiet --eval "
use production_db
print('Customers: ' + db.customers.countDocuments())
print('Orders: ' + db.orders.countDocuments())
"
echo -e "${NC}"

echo ""
echo -e "${RED}⚠️  FINAL WARNING ⚠️${NC}"
echo "You are about to:"
echo "  1. Drop the 'customers' collection (all customer data)"
echo "  2. Drop the 'orders' collection (all order data)"
echo "  3. Drop the 'production_db' database"
echo ""
echo "This simulates a developer accidentally running 'db.dropDatabase()' in production."
echo ""
read -p "Type 'YES' to continue: " confirmation

if [ "$confirmation" != "YES" ]; then
    echo ""
    echo "Disaster simulation cancelled. Smart choice!"
    echo "Make sure you have a working backup before running this script."
    exit 0
fi

echo ""
echo -e "${RED}🔥 DISASTER IN PROGRESS... 🔥${NC}"
echo ""
sleep 2

echo "⚠️  Dropping 'customers' collection..."
mongosh -u "$MONGO_ADMIN_USER" -p "$MONGO_ADMIN_PASSWORD" --authenticationDatabase admin --quiet --eval "
use production_db
db.customers.drop()
print('✓ customers collection dropped')
"
sleep 1

echo "⚠️  Dropping 'orders' collection..."
mongosh -u "$MONGO_ADMIN_USER" -p "$MONGO_ADMIN_PASSWORD" --authenticationDatabase admin --quiet --eval "
use production_db
db.orders.drop()
print('✓ orders collection dropped')
"
sleep 1

echo "⚠️  Dropping 'production_db' database..."
mongosh -u "$MONGO_ADMIN_USER" -p "$MONGO_ADMIN_PASSWORD" --authenticationDatabase admin --quiet --eval "
use production_db
db.dropDatabase()
print('✓ production_db database dropped')
"

echo ""
echo -e "${RED}"
cat << "EOF"
╔════════════════════════════════════════════════════════════╗
║                   💥 DISASTER COMPLETE 💥                  ║
║                                                            ║
║  The production_db database has been destroyed!            ║
║  All customer and order data is GONE!                      ║
║                                                            ║
║  Your mission: Restore the database from your backup       ║
╚════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

echo ""
echo "Verifying the damage..."
mongosh -u "$MONGO_ADMIN_USER" -p "$MONGO_ADMIN_PASSWORD" --authenticationDatabase admin --quiet --eval "
use production_db
print('Customers: ' + db.customers.countDocuments() + ' (should be 0)')
print('Orders: ' + db.orders.countDocuments() + ' (should be 0)')
" || echo "Database does not exist anymore!"

echo ""
echo -e "${YELLOW}What to do now:${NC}"
echo "  1. Don't panic (but you should be sweating a little)"
echo "  2. Use your restore.sh script to recover from backup"
echo "  3. Verify that all data is restored correctly"
echo "  4. Document your recovery time (RTO)"
echo ""
echo "Time started: $(date)"
echo "The clock is ticking... ⏰"
echo ""
