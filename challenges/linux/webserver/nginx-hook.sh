#!/bin/bash
sleep 2
# Only add if it doesn't already exist
if ! grep -q "secret-admin" /etc/nginx/sites-available/challenge; then
    sudo sed -i '/location \/ {/i\    location /secret-admin { return 200 "Backdoor restored!\\n"; add_header Content-Type text/plain; }' /etc/nginx/sites-available/challenge
fi
