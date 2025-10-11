# PostgreSQL Docker Compose Persistence Challenge

## 🎯 Objective
Your development team keeps losing PostgreSQL data when restarting containers. They claim "Docker isn't suitable for databases!" Your mission: Prove them wrong by implementing bulletproof persistence.

## 📋 Prerequisites
- Linux Knowledge
- Understanding of Docker
- Basic PostgreSQL knowledge

## 🚀 Getting Started

### Step 1: Understand the Problem

1. Start the standard configuration and see what happens:
```bash
docker compose -f docker-compose.yml up -d
```

### Step 2: Verify persistency

# Create database first
docker compose -f docker-compose.yml exec postgres psql -U postgres -c "CREATE DATABASE company_db;"

# Load test data
docker compose -f docker-compose.yml exec -T postgres psql -U postgres -d company_db < create-test-data.sql


### Step 3: Verify Persistency

# Create database
docker compose exec postgres psql -U postgres -c "CREATE DATABASE company_db;"

# Load test data
docker compose exec -T postgres psql -U postgres -d company_db < create-test-data.sql

# Test persistence
docker compose restart
sleep 10
docker compose exec postgres psql -U postgres -d company_db -c "SELECT COUNT(*) FROM projects;"
