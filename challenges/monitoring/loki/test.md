cd ~/challenge/loki

# 🧠 Kadir's Tech Playground – Hints

## 🚀 Quick Start
```bash
cd ~/challenge/loki
docker compose up -d

# Check if everything is running
docker compose ps

# Access Grafana (use your EC2 public IP)
# http://<EC2_PUBLIC_IP>:3000
# Login: admin/admin
```

---

## 🏗️ System Architecture
```
Student → Order Service → Flask API (validates customer)
              ↓              ↓
          Creates Order
              ↓
          Worker (processes order)

All logs flow to:
Promtail → Loki → Grafana (you query here)
```

**Services:**
- **Flask API** (Port 5000): Validates customers
- **Order Service** (Port 3001): Creates orders
- **Worker**: Processes orders every 30 seconds
- **promtail**: Collects and ships logs to Loki
- **Loki** (Port 3100): Stores logs
- **Grafana** (Port 3000): Query interface

---

## 📖 Challenge Walkthrough

### Level 1: Setup & Verify

**1.1 Check Services Are Running**
```bash
docker ps
# Should see: loki, promtail, grafana, flask-api, order-service, worker
```

**1.2 Verify Promtail/Loki versions**

Especially If you see errors indicating that images are not compatible:
```bash

# Restart
docker compose down
docker compose up -d
```

**1.3 Verify Loki is Receiving Logs**
```bash
curl http://localhost:3100/ready
# Should return: "ready"

# Check Promtail connection
docker logs promtail | grep -i "connected"
```

**1.4 Access Grafana**
- Open: `http://<EC2_PUBLIC_IP>:3000`
- Login: admin/admin
- Go to: Explore (compass icon) → Select "Loki"

**1.5 Test Basic Query**
```logql
{job="docker"}
```
✅ If you see logs → System is working!
❌ If "No data" → See Troubleshooting section below

---

### Level 2: Generate Traffic & Find Errors

**2.1 Create Test Orders**
```bash
# Single order
curl -X POST http://localhost:3001/orders \
  -H "Content-Type: application/json" \
  -d '{"customerId": 1, "product": "Laptop", "amount": 1200}'

# Generate 20 orders to see the bug pattern
for i in {1..20}; do
  curl -X POST http://localhost:3001/orders \
    -H "Content-Type: application/json" \
    -d '{"customerId": 1, "product": "Test-$i", "amount": 100}'
  echo "Order $i created"
  sleep 1
done
```

**2.2 View All Orders**
```bash
curl http://localhost:3001/orders | jq
# Note which ones have status: "pending" vs "completed"
```

**2.3 Find Errors in Grafana**
```logql
# Show all errors
{job="docker"} |= "ERROR"
```

**Questions to answer:**
- Which service shows the most errors?
- What's the error message?
- Do errors happen randomly or in patterns?

---

### Level 3: Investigate Root Cause

**3.1 Compare Services**
```logql
# Flask API errors
{container="flask-api"} |= "ERROR"

# Order Service errors
{container="order-service"} |= "ERROR"
```

**Key insight:** One service *generates* errors, the other *reports* them.

**3.2 Find the Exact Error**
```logql
# Look for specific error in Flask
{container="flask-api"} |= "database_timeout"
```

**3.3 Correlate Logs**
Look at the same timestamp:
- Flask API logs: "database_timeout" for customer_id: 1
- Order Service logs: "validation failed" for customer_id: 1

**3.4 Calculate Failure Rate**
```logql
# Count errors in last hour
count_over_time({container="flask-api"} |= "ERROR" [1h])
```

Create 20 orders → Count failures → Calculate percentage

**Expected:** ~15% failure rate (3 out of 20)

---

### Level 4: Advanced Analysis

**4.1 Parse JSON Logs**
```logql
{container="flask-api"} | json
```

**4.2 Filter by Customer ID**
```logql
{container="flask-api"} | json | customer_id="1"
```

**4.3 Time-based Queries**
```logql
# Errors in last 5 minutes
{job="docker"} |= "ERROR" [5m]

# Errors for specific service in last hour
{container="flask-api"} |= "ERROR" [1h]
```

**4.4 Count Errors Over Time**
```logql
count_over_time({container="flask-api"} |= "database_timeout" [1h])
```

---

## 🎯 Progressive Hints

<details>
<summary>💡 Hint 1: Can't see any logs in Grafana?</summary>

**Check Loki health:**
```bash
curl http://localhost:3100/ready
```

**Check Promtail is connected:**
```bash
docker logs promtail | grep -i "loki"
# Should see: "connected to Loki"
```

**Restart if needed:**
```bash
docker compose restart promtail
# Wait 30 seconds, then refresh Grafana
```
</details>

<details>
<summary>💡 Hint 2: Which service has the bug?</summary>

Run both queries and compare:
```logql
{container="flask-api"} |= "ERROR"
{container="order-service"} |= "ERROR"
```

The service with "database_timeout" is the root cause!
</details>

<details>
<summary>💡 Hint 3: How to find the failure rate?</summary>

Create 20 orders, then:
```bash
# Count successful orders
curl http://localhost:3001/orders | jq '.orders | length'

# In Grafana, count errors:
count_over_time({container="flask-api"} |= "database_timeout" [5m])
```

Calculate: (errors / total orders) × 100 = ~25%
</details>

<details>
<summary>💡 Hint 4: Why do some orders succeed and others fail?</summary>

The Flask API has a **random bug**. It's not related to:
- Customer ID
- Product type
- Order amount
- Time of day

It's purely random (~25% chance of failure)!
</details>

<details>
<summary>💡 Hint 5: How would you fix this in production?</summary>

**Immediate fix:**
- Add retry logic with exponential backoff
- Circuit breaker pattern

**Root cause fix:**
- Fix the database connection issue
- Add proper connection pooling
- Improve error handling

**Monitoring:**
- Alert on >5% error rate
- Dashboard showing error trends
</details>

---

## 🐛 Troubleshooting

### Problem: "No data" in Grafana

**Step 1: Check Loki**
```bash
curl http://localhost:3100/ready
# Should return: "ready"
```

**Step 2: Check Promtail**
```bash
docker logs promtail
# Look for: "connected to Loki" or errors
```

**Step 3: Restart Promtail**
```bash
docker compose restart promtail
# Wait 30 seconds
```

**Step 4: Check containers are labeled**
```bash
docker inspect flask-api | grep -A5 Labels
# Should see: "logging": "promtail"
```

---

### Problem: Promtail API Version Error

**Error:**
```
client version 1.42 is too old. Minimum supported API version is 1.44
```

**Fix:**
```bash
# check dockerhub for newer version
# Edit docker-compose.yml
# Change promtail image from 2.9.3 to 3.0.0
docker compose down
docker compose up -d
```

---

### Problem: Orders Not Being Processed

**Check worker is running:**
```bash
docker logs worker
# Should see: "Processing order X"
```

**Check worker can reach order service:**
```bash
docker exec worker wget -O- http://order-service:3001/orders
```

**If 404 errors on /status endpoint:**
The order-service is missing the PATCH endpoint - ask instructor!

---

### Problem: Can't Create Orders

**Test Flask API:**
```bash
curl http://localhost:5000/customers
# Should return customer list
```

**Test customer validation:**
```bash
curl http://localhost:5000/customers/1/validate
# Should return: {"valid": true} (85% of time)
# Or: {"valid": false, "reason": "database_timeout"} (15%)
```

**Try different customer IDs:**
- Valid: 1, 2, 4 (active customers)
- Invalid: 3 (inactive), 5 (suspended)

---

## 📚 LogQL Quick Reference

| Query | Description |
|-------|-------------|
| `{job="docker"}` | All logs |
| `{container="flask-api"}` | Specific container |
| `\|= "ERROR"` | Contains "ERROR" |
| `!= "INFO"` | Doesn't contain "INFO" |
| `\| json` | Parse JSON logs |
| `[5m]` | Last 5 minutes |
| `count_over_time()` | Count matches |

**Examples:**
```logql
# All errors
{job="docker"} |= "ERROR"

# Flask errors only
{container="flask-api"} |= "ERROR"

# Parse JSON and filter
{container="flask-api"} | json | customer_id="1"

# Count errors per minute
count_over_time({job="docker"} |= "ERROR" [1m])
```

---

## 🎓 What You're Learning

By completing this challenge, you'll understand:

✅ **Centralized Logging**
- Why it matters in distributed systems
- How Promtail collects logs
- How Loki stores and indexes logs

✅ **Log Correlation**
- Tracing requests across services
- Finding root cause vs symptoms
- Using timestamps to correlate events

✅ **LogQL Queries**
- Label-based filtering
- Text search and parsing
- Time-based queries
- Aggregations

✅ **Debugging Distributed Systems**
- Identifying failure patterns
- Statistical analysis (25% failure rate)
- Service dependency troubleshooting

---

## 💡 Pro Tips

1. **Always check logs with timestamps** - helps correlate issues
2. **Start broad, then narrow down** - {job="docker"} → {container="flask-api"} → |= "ERROR"
3. **Use JSON parsing** - structured logs are easier to query
4. **Count things** - helps identify patterns (15% failure!)
5. **Check all services** - the bug might not be where you think
