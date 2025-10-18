# Hints — Webserver Investigation Challenge

## High-level approach
Start with surface-level checks (what's listening, what config files exist) and then follow any dynamic or scripted changes. Think both persistence (what survives restarts) and immediacy (what happens when the service starts or reloads).

---

## Quick commands to begin
- What is listening on port 80?
```bash
  sudo ss -tulnp | grep :80
````

* Confirm Nginx unit and process details:

  ```bash
  systemctl status nginx
  ps aux | grep nginx
  ```

---

## Inspect the site and config

* Read the site configuration and list the site files:

```bash
  sudo cat /etc/nginx/sites-available/challenge
  sudo ls -l /var/www/challenge
```
* Focus your attention on `location` blocks and any `return` statements — they often reveal unexpected endpoints.

---

## Systemd and service behavior

* Check for service-level customization or extra unit files (these can change behavior at start/reload):

```bash
  ls -l /etc/systemd/system/nginx.service.d/
  systemctl cat nginx
```
* If you see custom Exec* entries, investigate the referenced scripts — but don't remove anything yet.

---

## Look for scripts and tampering

* List likely script locations and search for files referencing `nginx`:

```bash
  ls -la /usr/local/bin
  ls -la /tmp
  grep -R "nginx" /usr/local/bin /tmp /etc -n 2>/dev/null || true
```
* Small helper scripts placed in common paths can subtly alter config files or server behavior.

---

## Scheduled jobs & cron

* Inspect system cron for recent additions:

```bash
  sudo cat /etc/crontab
  sudo ls -la /etc/cron.* || true
```
* Cron entries may appear innocuous while being part of a persistence strategy.

---

## Users & logs

* Look for unusual or recently created accounts:

```bash
  getent passwd | egrep 'suspicious|admin|backup' || true
```
* Review logs for clues:

```bash
  sudo ls -la /var/log
  sudo tail -n 50 /var/log/syslog 2>/dev/null || true
  sudo ls -la /var/log/intrusion 2>/dev/null || true
```

---

## Verification & safe remediation (no spoilers)

* Inspect any script you find before changing or deleting it.
* To test persistence safely: stop the service, make a change to the config on disk, then restart and observe whether the change remains.
* When you change anything, ensure you reload systemd and the service:

```bash
  sudo systemctl daemon-reload
  sudo systemctl restart nginx
```
* Record exact commands and outputs so you can reproduce and explain your findings.
