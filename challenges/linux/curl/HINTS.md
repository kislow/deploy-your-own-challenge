# 🕵️‍♂️ Curl Troubleshooting Challenge – Hints

## 💭 General Guidance
This challenge is designed to test your ability to spot unusual system behavior
and trace the root cause logically.
Don’t overthink it — most clues are already on your machine.

---

## 🧩 Hint 1: Where’s curl really coming from?
Check whether the `curl` command you’re invoking is the genuine binary.

```bash
which curl
type curl
ls -l $(which curl)
