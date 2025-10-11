#!/bin/bash

# Install nginx and create a simple site
sudo apt update && sudo apt install nginx -y
sudo systemctl enable nginx
sudo systemctl start nginx

# Create a "secure" login page
sudo mkdir -p /var/www/challenge
cat << 'EOF' | sudo tee /var/www/challenge/index.html
<!DOCTYPE html>
<html>
<head><title>Secure Admin Portal</title></head>
<body>
<h1>Admin Login</h1>
<form>
<input type="text" placeholder="Username" name="user"><br><br>
<input type="password" placeholder="Password" name="pass"><br><br>
<button type="submit">Login</button>
</form>
<p><em>Note: This system has been recently secured by the previous administrator.</em></p>
</body>
</html>
EOF

# Configure nginx
cat << 'EOF' | sudo tee /etc/nginx/sites-available/challenge
server {
    listen 80;
    server_name _;
    root /var/www/challenge;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }

    # "Hidden" admin endpoint that shouldn't be here
    location /secret-admin {
        return 200 "Admin access granted! Flag: CHALLENGE_COMPLETE\n";
        add_header Content-Type text/plain;
    }
}
EOF

sudo ln -sf /etc/nginx/sites-available/challenge /etc/nginx/sites-enabled/default
sudo nginx -t && sudo systemctl reload nginx
