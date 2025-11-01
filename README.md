# 🚀 Deploy Your Own Challenge

Welcome to **Deploy Your Own Challenge** a hands-on playground where you can **spin up real-world DevOps challenges**, break things, fix them, and learn the craft the right way.

This repo is built for engineers who believe the best way to learn DevOps is to **deploy it yourself**, not just read about it.

💡 Start small, break things, fix them, and gradually build confidence, that's how professional DevOps engineers are made.

---

## 🚀 Quick Start

⚠️ IMPORTANT NOTICE

I strongly advise **against** running or deploying these challenges on your local machine.
They may contain configurations, scripts, or network behaviors that could interfere with your system environment.

Always use a virtual machine (VM), [Killercoda](https://killercoda.com/playgrounds/scenario/ubuntu), or another isolated sandbox environment for testing and deployment!!!

```bash
# 1. Clone the repo
git clone https://github.com/kislow/deploy-your-own-challenge.git
cd deploy-your-own-challenge

# 2. Run automated setup
make setup

# 3. Deploy your first challenge
make curl HOST=localhost
```

📖 **Need help with installation?** See the **[Installation Guide →](INSTALLATION.md)**

---

## 🎯 Available Challenges

### 🐧 Linux Challenges

#### **Linux Curl Challenge**
**Difficulty:** Beginner
**Tags:** `linux-curl-challenge`

A mischievous script has intercepted your `curl` command! Your mission is to restore it without reinstalling packages or rebooting the system.

**Skills:** Linux troubleshooting, command interception, PATH manipulation, shell aliases

```bash
make curl HOST=localhost
```

---

#### **Linux Webserver Challenge**
**Difficulty:** Beginner
**Tags:** `linux-webserver-challenge`

Deploy a simple static website using a lightweight web server. Learn the fundamentals of web hosting, process management, and basic HTTP serving.

**Skills:** Web servers (nginx/apache), file permissions, port binding, service management

```bash
make webserver HOST=localhost
```

---

### 🐳 Docker Challenges

#### **PostgreSQL Docker Challenge**
**Difficulty:** Intermediate
**Tags:** `postgres-docker-challenge`

Deploy and manage a PostgreSQL database in Docker. Learn container orchestration, volume management, and database persistence.

**Skills:** Docker, PostgreSQL, volume management, container networking

```bash
make psql HOST=localhost
```

---

### 🔧 Application Challenges

#### **Go App Challenge**
**Difficulty:** Intermediate
**Tags:** `go-app-challenge`

Build and deploy a Go application. Understand compilation, binary execution, and application deployment patterns.

**Skills:** Go development, application deployment, process management

```bash
make go-app HOST=localhost
```

### 🗂️ Database Challenges

#### **MongoDB Backup & Recovery Challenge**

**Difficulty: Intermediate**
**Tags: mongodb-backup-challenge**

Master MongoDB backup strategies and disaster recovery procedures. Learn to create automated backups, handle database restoration, and implement robust recovery plans.

**Skills**: MongoDB administration, backup strategies, disaster recovery, automation, database security

```bash
make mongo HOST=localhost
```

---

## 🧩 What You'll Find Here

Each challenge folder contains:

- **Scenario:** a real-world DevOps problem or setup to tackle
- **Setup:** Automated deployment via Ansible
- **Objective:** clear learning goals and success criteria
- **Hints (optional):** small nudges if you get stuck (HINTS.md)

💡 *Think of it as a lab manual meets production chaos.*

---

## 🚢 Deployments

There is a Makefile to simplify deployment and tear-downs (WIP).
You can deploy specific challenges, groups, or even combinations of tags.

### Individual Challenges

```bash
# Deploy to localhost (no SSH required)
make curl HOST=localhost
make webserver HOST=localhost
make go-app HOST=localhost
make psql HOST=localhost
make mongo HOST=localhost

# Deploy to remote VM
make curl HOST=198.168.1.100
make webserver HOST=198.168.1.100

# Deploy with custom SSH credentials
make curl HOST=ec2-instance REMOTE_USER=ec2-user SSH_KEY=~/.ssh/ec2.pem
```

### Combination Deployments

```bash
# Deploy all challenges
make all-challenges HOST=localhost

# Deploy infrastructure only (base setup + Kind cluster)
make infra HOST=localhost

# Full deployment (everything)
make deploy HOST=localhost
```

### Flexible Deployments

```bash
# Deploy specific tags
make quick HOST=localhost TAGS=linux-curl-challenge,linux-webserver-challenge

# Deploy all except specific challenge(s)
make deploy-except HOST=localhost SKIP=postgres-docker-challenge
```

### Built-in Documentation

```bash
# Show all available commands
make help

# List all challenge tags
make list-tags

# Test connection before deployment
make test-connection HOST=localhost
```

### Safety Features

```bash
# Perform a dry run (no changes)
make dry-run HOST=localhost

# Dry run for specific tags
make dry-run-tag HOST=localhost TAGS=linux-curl-challenge
```

🧠 *All commands automatically detect localhost vs remote and configure the connection accordingly.*

---

## 🎓 Learning Path

**Recommended order for beginners:**

1. **Linux Curl** → Master basic Linux troubleshooting
2. **Linux Webserver** → Learn web server fundamentals
3. **PostgreSQL Docker** → Understand containerization
4. **Go App** → Deploy real applications
5. **Mongodb** → Hands on Backup and Disaster Recovery

Each challenge builds on concepts from previous ones!

---

## ⚙️ Requirements

### For Local Deployment (localhost)

- Python 3.8+
- Ansible 2.9+
- Sudo access
- Docker (for Docker-based challenges)

All automatically installed via `make setup`

### For Remote Deployment

Everything above, plus:
- SSH access to target host
- SSH key authentication configured

📖 **Full installation instructions:** [INSTALLATION.md](INSTALLATION.md)

---

## No Platforms. No Excuses.

Not every challenge needs a Hackerrank sign-up or pre-built test.
Sometimes the best exercises are **custom-built**, creative, cost-effective, and tailored to **your company's workflows** or **internal upskilling programs**.
This repo is for engineers who learn by deploying, experimenting, and thinking differently.

🧩 Tips for Junior Engineers

⚠️ Hands-on first, AI second
If you're new to DevOps, resist the urge to copy-paste solutions from AI or forums.
The real learning comes from reading **official documentation**, experimenting, and troubleshooting yourself.
AI can be a helpful assistant, but don't let it replace understanding why something works.

## 💬 Feedback & Contributions

We value feedback, each challenge evolves based on real-world input.
If you have ideas for new challenges or improvements, feel free to open a **Pull Request** or **Issue**.

---

## ⚖️ License

* **Code and configurations:** MIT License
* **Challenge write-ups and documentation:** CC BY-NC 4.0 (non-commercial use only)

---

## 🌐 Connect

Tag your setups, screenshots, or notes with **#DeployYourOwnChallenge** on social, learn by deploying.

> "You don't learn DevOps by watching you learn it by deploying."
