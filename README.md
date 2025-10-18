# 🚀 Deploy Your Own Challenge

Welcome to **Deploy Your Own Challenge** a hands-on playground where you can **spin up real-world DevOps challenges**, break things, fix them, and learn the craft the right way.

This repo is built for engineers who believe the best way to learn DevOps is to **deploy it yourself**, not just read about it.

## No Platforms. No Excuses.

Not every challenge needs a Hackerrank sign-up or pre-built test.
Sometimes the best exercises are **custom-built**, creative, cost-effective, and tailored to **your company’s workflows** or **internal upskilling programs**.
This repo is for engineers who learn by deploying, experimenting, and thinking differently.

🧩 Tips for Junior Engineers

⚠️ Hands-on first, AI second
If you’re new to DevOps, resist the urge to copy-paste solutions from AI or forums.
The real learning comes from reading **official documentation**, experimenting, and troubleshooting yourself.
AI can be a helpful assistant, but don’t let it replace understanding why something works.

💡 Start small, break things, fix them, and gradually build confidence, that’s how professional DevOps engineers are made.

---

## 🧩 What You'll Find Here

Each challenge folder contains:

- **Scenario:** a real-world DevOps problem or setup to tackle
- **Setup:** Docker Compose or Kubernetes manifests to spin up the environment
- **Objective:** clear learning goals and success criteria
- **Hints (optional):** small nudges if you get stuck

💡 *Think of it as a lab manual meets production chaos.*

---

### ⚙️ Ansible Prerequisites

1. **Python**

   * Ansible requires Python **3.8+** on the **control machine** (where you run Ansible).

2. **SSH Access**

   * Ansible communicates over SSH to your managed nodes (VMs, containers, or remote servers).
   * You need:

     * **remote_user** → the user Ansible will log in as on the target host (e.g., `ubuntu` or `admin`).
     * **private_key_file** → the SSH private key to authenticate the remote user (no password needed).
   * In `ansible.cfg` or inventory:

     ```ini
     [defaults]
     remote_user = ubuntu
     private_key_file = /path/to/private_key.pem
     ```

   ✅ *This is required for all VM-based challenges. For local Docker or Kind clusters, this may not be necessary if Ansible runs locally.*

---


## ⚙️ Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/kislow/deploy-your-own-devops.git
cd deploy-your-own-devops
````

### 2. Spin up a VM or local environment

It’s **strongly recommended** to run these challenges in a **clean VM** or **sandboxed environment** especially when testing networking, volumes, or security scenarios.

* 🐳 **Docker-based challenges**: can be run locally on your machine (Docker Desktop or CLI).
* 🧠 **Linux-based challenges**: work best on a lightweight VM (tested on Ubuntu and Debian).
* ☸️ **Kubernetes challenges**: use Kind (Kubernetes in Docker), so you can run clusters directly inside Docker — no separate VM required.
* Alternatively, you can spin up:

  * **Azure:** you may use `Standard_B2s`
  * **AWS:** you may use `t3.medium`
  * **Local:** use Multipass, Vagrant, or Docker Desktop with a Linux container backend

---

## 🚢 Deployments

Each challenge comes with a Makefile to simplify deployment and tear-downs.
You can deploy specific challenges, groups, or even combinations of tags.

```sh
# Exercise deployment
$ make <challenge> HOST=<IP>       # e.g. make linux-curl HOST=192.168.1.10 or HOST=localhost for local deployment

#----------------------#
# Combination targets  #
#----------------------#

# Deploy all challenges
$ make all-challenges HOST=<IP>

# All Kubernetes-related tasks
$ make linux-webserver HOST=<IP>

#----------------------#
# Flexible deployments #
#----------------------#

# Deploy specific tags
$ make quick HOST=<IP> TAGS=docker,postgres

# Deploy all except specific challenge(s)
$ make deploy-except HOST=<IP> SKIP=postgres

#------------------------#
# Built-in documentation #
#------------------------#

$ make help
$ make list-tags

#------------------------#
# Safety Feature         #
#------------------------#

# Perform a dry run (no changes)
$ make dry-run HOST=<IP>
```

🧠 *All commands assume passwordless SSH or pre-configured access to your target host.*

---

## 💬 Feedback & Contributions

We take feedback seriously, each challenge evolves based on real-world input.
If you have ideas for new challenges or improvements, feel free to open a **Pull Request** or **Issue**.

---

## ⚖️ License

* **Code and configurations:** MIT License
* **Challenge write-ups and documentation:** CC BY-NC 4.0 (non-commercial use only)

---

## 🌐 Connect

Tag your setups, screenshots, or notes with **#DeployYourOwnDevOps** on social, let’s grow a community that learns by deploying.

> “You don’t learn DevOps by watching you learn it by deploying.”

---
