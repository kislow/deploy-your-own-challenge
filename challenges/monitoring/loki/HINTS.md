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

## 📚 Useful Commands

### Docker Commands
```bash
# Check Loki is receiving logs
curl http://localhost:3100/ready

# View container logs directly
docker logs -f flask-api
docker logs -f order-service
docker logs -f worker

# Restart a service
docker restart promtail

# Check all running containers
docker ps
```

### LogQL Queries (for Grafana)

```logql
# All logs
{job="docker"}

# Only Flask API logs
{container="flask-api"}

# Only Order Service logs
{container="order-service"}

# Only errors
{job="docker"} |= "ERROR"

# Errors in last 5 minutes
{job="docker"} |= "ERROR" [5m]

# JSON parsing (Flask and Order Service use JSON)
{container="order-service"} | json

# Filter by specific error
{container="flask-api"} |= "database_timeout"

# Count errors over time
count_over_time({job="docker"} |= "ERROR" [1h])
```

## 🧪 Generate Traffic (Create Orders)

The system needs orders to show the bug! Create orders manually:
```bash
# Create a single order
curl -X POST http://localhost:3001/orders \
  -H "Content-Type: application/json" \
  -d '{"customerId": 1, "product": "Laptop", "amount": 1200}'

# View all orders
curl http://localhost:3001/orders

# Generate multiple orders to see the pattern (recommended!)
for i in {1..20}; do
  curl -X POST http://localhost:3001/orders \
    -H "Content-Type: application/json" \
    -d '{"customerId": 1, "product": "Test-$i", "amount": 100}'
  echo "Order $i created"
  sleep 1
done
```

---

## 🔍 Investigation Tips

### Level 1: Getting Started
- **Can't access Grafana?** Make sure port 3000 is open in your EC2 security group
- **No logs showing?** Wait 30 seconds after starting, then refresh Grafana
- **Loki datasource not working?** It's auto-configured, just select "Loki" in Explore

### Level 2: Finding Errors
- Start with: `{job="docker"} |= "ERROR"`
- Look at timestamps - do errors happen randomly or in patterns?
- Compare Flask API logs with Order Service logs at the same time

### Level 3: Advanced Queries
- Use the "Explore" tab in Grafana (compass icon)
- Click "Log browser" to see available labels
- Use `|=` for contains, `!=` for not contains
- Use `| json` to parse JSON logs into fields

### Level 4: Root Cause
- Which service logs the error first?
- What's the error message exactly?
- Is it always the same error or different ones?
- Try creating multiple orders - how often do they fail?

---

## 🐛 Troubleshooting

### "No data" in Grafana
```bash
# Check Promtail is running
docker logs promtail

# Check Loki is healthy
curl http://localhost:3100/ready

# Restart Promtail if needed
docker compose restart promtail
```

### Services won't start
```bash
# Check what's wrong
docker compose logs

# Clean restart
docker compose down
docker compose up -d
```

### Can't create orders
```bash
# Test Flask API directly
curl http://localhost:5000/customers

# Test order creation
curl -X POST http://localhost:3001/orders \
  -H "Content-Type: application/json" \
  -d '{"customerId": 1, "product": "Laptop", "amount": 1200}'
```

---

## 💡 Learning Resources

### LogQL Basics
- Labels: `{container="flask-api"}`
- Line filters: `|= "ERROR"` (contains)
- JSON parser: `| json`
- Time range: `[5m]` (last 5 minutes)

### Understanding the Services
- **Flask API (Port 5000)**: Validates customers before orders
- **Order Service (Port 3001)**: Creates orders, calls Flask
- **Worker**: Processes orders in background
- **Loki (Port 3100)**: Stores logs
- **Grafana (Port 3000)**: Query and visualize logs

---

## 🎯 Hints by Level

<details>
<summary>Hint 1: Where to start?</summary>

Go to Grafana → Explore → select "Loki" datasource → try:
```logql
{job="docker"}
```
You should see logs from all services.
</details>

<details>
<summary>Hint 2: How to find errors?</summary>

Filter for errors:
```logql
{job="docker"} |= "ERROR"
```
Look at which container shows errors most frequently.
</details>

<details>
<summary>Hint 3: Which service has the bug?</summary>

Compare these two queries:
```logql
{container="flask-api"} |= "ERROR"
{container="order-service"} |= "ERROR"
```
One service generates errors, the other reports them.
</details>

<details>
<summary>Hint 4: What's the exact error?</summary>

Look for the error in Flask API:
```logql
{container="flask-api"} |= "database_timeout"
```
This is your root cause!
</details>

<details>
<summary>Hint 5: How often does it fail?</summary>

The bug is random! Create multiple test orders:
```bash
for i in {1..20}; do
  curl -X POST http://localhost:3001/orders \
    -H "Content-Type: application/json" \
    -d '{"customerId": 1, "product": "Test", "amount": 100}'
  sleep 1
done
```
About 15% will fail.
</details>

---
