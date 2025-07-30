#!/bin/bash

# EC2 User Data Script for Juvenile Immigration API with Email Support
# This script sets up the Python Flask API with AWS SES email functionality

# Update system
yum update -y

# Install Python 3.11, pip, git, and other dependencies
yum install -y python3.11 python3.11-pip git docker htop

# Create a symlink for python3
ln -sf /usr/bin/python3.11 /usr/bin/python3

# Enable and start Docker
systemctl enable docker
systemctl start docker

# Add ec2-user to docker group
usermod -a -G docker ec2-user

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Create application directory
mkdir -p /opt/juvenile-immigration-api
cd /opt/juvenile-immigration-api

# Clone repository (replace with your actual repo)
git clone https://github.com/RamonColmenares/ET6-CDSP-group-19-repo-web.git .

# Set environment variables for AWS SES
# NOTE: Replace these values with your actual email addresses
export AWS_REGION=${aws_region}
export SENDER_EMAIL=${sender_email}
export RECIPIENT_EMAIL=${recipient_email}

# Add environment variables to system-wide environment
echo "export AWS_REGION=${aws_region}" >> /etc/environment
echo "export SENDER_EMAIL=${sender_email}" >> /etc/environment
echo "export RECIPIENT_EMAIL=${recipient_email}" >> /etc/environment

# Create .env file for the application
cat > /opt/juvenile-immigration-api/.env << EOF
AWS_REGION=${aws_region}
SENDER_EMAIL=${sender_email}
RECIPIENT_EMAIL=${recipient_email}
FLASK_ENV=production
DEBUG=False
EOF

# Install Python dependencies
cd /opt/juvenile-immigration-api/api
python3 -m pip install --upgrade pip
python3 -m pip install -r requirements.txt

# Create systemd service for the API
cat > /etc/systemd/system/juvenile-immigration-api.service << EOF
[Unit]
Description=Juvenile Immigration API
After=network.target

[Service]
Type=simple
User=ec2-user
WorkingDirectory=/opt/juvenile-immigration-api/api
Environment=PATH=/usr/bin:/usr/local/bin
Environment=AWS_REGION=${aws_region}
Environment=SENDER_EMAIL=${sender_email}
Environment=RECIPIENT_EMAIL=${recipient_email}
Environment=FLASK_ENV=production
Environment=DEBUG=False
ExecStart=/usr/bin/python3 index.py
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the service
systemctl daemon-reload
systemctl enable juvenile-immigration-api
systemctl start juvenile-immigration-api

# Install and configure nginx as reverse proxy
yum install -y nginx

cat > /etc/nginx/conf.d/api.conf << EOF
server {
    listen 80;
    server_name _;

    # API routes
    location /api/ {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    # Health check
    location /health {
        proxy_pass http://127.0.0.1:5000/api/health;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }

    # Default route for other requests
    location / {
        return 200 'API Server Running';
        add_header Content-Type text/plain;
    }
}
EOF

# Enable and start nginx
systemctl enable nginx
systemctl start nginx

# Create log rotation for the application
cat > /etc/logrotate.d/juvenile-immigration-api << EOF
/var/log/juvenile-immigration-api.log {
    daily
    missingok
    rotate 7
    compress
    delaycompress
    notifempty
    create 644 ec2-user ec2-user
}
EOF

# Set correct permissions
chown -R ec2-user:ec2-user /opt/juvenile-immigration-api

# Wait for services to start
sleep 10

# Test the API
curl -f http://localhost/api/health || echo "Warning: API health check failed"

echo "=== Deployment Complete ==="
echo "API should be running on port 80"
echo "Test with: curl http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)/api/health"
echo ""
echo "Remember to:"
echo "1. Verify email addresses in AWS SES console"
echo "2. Test the contact form after verification"
echo "3. Check application logs: sudo journalctl -u juvenile-immigration-api -f"
