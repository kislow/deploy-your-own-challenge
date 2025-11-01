# MongoDB Backup & Restore Challenge - Hints

## 🎯 Objective
Your company's MongoDB database was accidentally dropped in production. Your mission: Build an automated backup solution and prove you can recover from disaster in under 5 minutes.

## 📋 Prerequisites
- Linux command line knowledge
- Basic bash scripting
- Understanding of cron jobs
- MongoDB basics (will be reinforced during challenge)

## 🚀 Getting Started

### Step 1: Understand Your Environment

First, check what's been set up for you:

```bash
# Navigate to the challenge directory
cd ~/mongo-challenge

# Read the welcome message
cat README.md

# Check what helper scripts you have
ls -la scripts/

# View your MongoDB credentials (KEEP THESE SECURE!)
cat .mongo_credentials
```

### Step 2: Connect to MongoDB

Load your credentials and test the connection:

```bash
# Source the credentials into your shell
source ~/mongo-challenge/.mongo_credentials

# Connect to MongoDB using the variables
mongosh -u $MONGO_ADMIN_USER -p $MONGO_ADMIN_PASSWORD --authenticationDatabase admin
```

### Step 3: Explore the Database

Once connected to mongosh, explore what data exists:

```javascript
// Show all databases
show dbs

// Switch to production database
use production_db

// Show all collections
show collections

// Count documents in each collection
db.customers.countDocuments()
db.orders.countDocuments()

// View a sample customer
db.customers.findOne()

// View a sample order
db.orders.findOne()

// Find a specific customer by ID to verify later
db.customers.findOne({customer_id: 25})

// Exit mongosh
exit
```

**Pro Tip:** Before the disaster, note down the exact counts and maybe check a few specific records (like customer_id: 25 or order_id: 100). After restore, verify these exact same records exist with identical data - this proves data integrity, not just count matching!

## 🔧 Backup Script Hints

### Creating Your First Backup Script

You can use the `backup_template.sh`


### Understanding mongodump

Research the `mongodump` command. You'll need to figure out:
- How to authenticate (username, password, auth database)
- How to specify which database to backup
- Where to output the backup
- How to compress the backup (there's a flag for this!)

**Hints:**
- Never hardcode passwords in scripts - always source them from a secure file
- Use `date` command to create timestamps: `date +%Y-%m-%d_%H-%M-%S`
- Check if commands succeed: `if [ $? -eq 0 ]` checks the exit code of the last command
- The `--help` flag is your friend: `mongodump --help`

### Secure Credential Handling

**Wrong approach:**
```bash
# ❌ Password visible in script, logs, and process list
mongodump -u admin -p MyPassword123 ...
```

**Right approach:**
Think about how to load variables from `.mongo_credentials` file at the start of your script.

### Logging Your Operations

Good scripts log what they're doing:
- What time did the backup start?
- Did it succeed or fail?
- How big is the backup?
- Where is it stored?

Consider creating a log function that writes to both console and file. Research the `tee` command.

### Implementing Retention Policy

You need to automatically delete backups older than 7 days. The `find` command is perfect for this:
- Research: `find` with `-type d` (directories), `-mtime` (modification time), and `-delete` or `-exec rm`
- **IMPORTANT:** Always test your find command with `-print` first to see what it would delete!
- Make sure you don't accidentally delete today's backup

## ⏰ Cron Job Hints

### Creating a Cron Job

```bash
# Edit your crontab
crontab -e

# Basic cron syntax: minute hour day month dayofweek command
# Example format:
# 0 2 * * * /path/to/script.sh
```

### Cron Time Patterns

Research cron syntax:
- `0 2 * * *` means something specific about timing
- `*/5 * * * *` runs at a different interval
- What would daily at 2 AM look like?

**IMPORTANT:** For testing, you might want to run it every few minutes first!!!

### Debugging Cron Jobs

Common issues to check:
- Is cron service running? (check with `systemctl`)
- Are you using absolute paths in your cron command?
- Does your script source the credentials file with absolute path?
- Check system logs: `/var/log/syslog` or use `journalctl`

**Critical:** Cron doesn't have your normal environment variables or PATH. Always use full paths!

## 🔄 Restore Script Hints

### Understanding mongorestore

Research the `mongorestore` command - it's the opposite of mongodump:
- Similar authentication parameters needed
- Need to point to the backup directory
- If backups are compressed, there's a flag for that

### Making Your Script User-Friendly

Consider these features:
- Accept the backup timestamp as a command-line parameter
- If no parameter given, show available backups
- Ask for confirmation before restoring (it's destructive!)
- Verify the backup directory exists before attempting restore

**Bash tips:**
- `$1` is the first command-line argument
- `if [ -z "$1" ]` checks if a variable is empty
- `ls` command can list directories
- `read -p "prompt text" variable_name` gets user input

### Verifying Backup Exists

Before restoring, check:
- Does the backup directory exist?
- Is it in the expected location?
- Give a helpful error message if not

## ✅ Verification Script Hints

### What to Verify

Your verify script should check:
1. Does a backup from today exist?
2. Is the backup directory actually populated with files?
3. Does it contain the expected database structure?

### Checking Today's Backup

You'll need to:
- Get today's date in the same format as your backup directories
- Search for directories matching that date (might have different times)
- The `find` command can search by name patterns

### Checking Backup Integrity

Basic checks:
- Is the directory empty? (`ls -A` can help)
- Does it contain the database subdirectory you expect?
- Count the number of collection files

Research: What files does mongodump create? What's their extension?

## 💥 Disaster Simulation Hints

### Before Running the Disaster

**CRITICAL CHECKLIST:**
1. Have you created a backup?
2. Have you verified it exists?
3. Have you noted the current document counts?

```bash
# Verify your backup exists
ls -la /opt/mongo-backup/backups/

# Note current state - use mongosh to check counts
mongosh -u $MONGO_ADMIN_USER -p $MONGO_ADMIN_PASSWORD --authenticationDatabase admin
```

### After the Disaster

The database will be gone. Your task:
1. Stay calm (it's just a challenge... this time!)
2. Note the time (your RTO clock starts now)
3. Run your restore script
4. Verify all data is back correctly
5. Calculate how long it took

## 🔍 Troubleshooting

### "Authentication failed"
Check your credentials file syntax and test manual connection first.

### "command not found"
MongoDB tools should be installed. Check with: `which mongodump mongorestore`

### "Permission denied"
Check script permissions with `ls -l` and fix with `chmod +x`

### Script works manually but not in cron
- Use absolute paths everywhere
- Source credentials with full path
- Check logs: `grep CRON /var/log/syslog`
- Test what environment cron has: try logging `env` in your script

### Can't delete old backups
Test your find command carefully with `-print` before using `-delete`

## 📚 Useful Commands to Research

**File Operations:**
- `mkdir -p` - Create directories
- `chmod` - Change permissions
- `find` - Search for files/directories
- `du -sh` - Check directory size
- `df -h` - Check disk space

**Bash Scripting:**
- `$?` - Exit code of last command
- `$1, $2` - Command line arguments
- `if [ condition ]` - Conditional execution
- `set -e` - Exit on error
- `tee` - Write to file and stdout

**Date/Time:**
- `date` - Display or format dates
- `date +%Y-%m-%d` - Format date as YYYY-MM-DD

**MongoDB:**
- `mongodump --help` - See all options
- `mongorestore --help` - See restore options
- `mongosh` - MongoDB shell

## 🎓 Learning Approach

**When stuck:**
1. Read the error messages carefully
2. Google the specific error or command you need
3. Check command help: `command --help`
4. Test small pieces before building the full script
5. Use `echo` statements to debug your scripts

**Example search queries:**
- "bash get current date timestamp"
- "cron run script daily at 2am"
- "bash check if directory exists"
- "find delete files older than 7 days"
- "mongodump authentication example"

Remember: Looking up syntax and examples is not cheating - it's how real sysadmins work every day!

## ✨ Success Checklist

Before claiming victory:
- [ ] Backup script completes without errors
- [ ] Backups have timestamps in directory names
- [ ] Backups are compressed (check file sizes)
- [ ] Old backups are cleaned up automatically
- [ ] Cron job runs automatically (check logs next day)
- [ ] Restore script works from any backup
- [ ] Disaster recovery succeeds
- [ ] All data verified (counts match, sample records exist)
- [ ] Recovery time under 5 minutes
- [ ] Documentation written

## 🚀 You've Got This!

This challenge simulates a real production scenario. The skills you learn here - automation, error handling, disaster recovery - are exactly what companies need.

Take your time, test thoroughly, and don't be afraid to break things (that's what the disaster simulation is for!).

Good luck! 🍀
