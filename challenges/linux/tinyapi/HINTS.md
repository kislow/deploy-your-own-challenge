# Hints for the Tiny Linux API Challenge

❗ Hint 1 — Check the service status
Use:
systemctl status tinyapi
journalctl -u tinyapi

Look for missing paths or permission errors.

---

❗ Hint 2 — Verify the ExecStart path
Open the file:
sudo nano /etc/systemd/system/tinyapi.service

Make sure it points to:
ExecStart=/usr/bin/python3 /opt/tinyapi/app.py

If you fix it:
sudo systemctl daemon-reload

---

❗ Hint 3 — Permission issues
If you see:
Permission denied

Check permissions:
ls -l /opt/tinyapi/app.py

Fix with:
chmod +x /opt/tinyapi/app.py

---

❗ Hint 4 — Missing package
If the service log says Python cannot import flask:

sudo apt update
sudo apt install -y python3-flask

---

❗ Hint 5 — Firewall
If the API works locally but not remotely:

sudo ufw allow 5005/tcp
sudo ufw reload

---

❗ Hint 6 — Bonus
Edit:
sudo nano /opt/tinyapi/app.py

Then restart:
sudo systemctl restart tinyapi
