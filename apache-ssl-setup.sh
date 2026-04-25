#!/bin/bash
# Part A: Apache SSL/TLS Setup Script for Amazon Linux 2

# Install Apache and mod_ssl
sudo yum update -y
sudo yum install -y httpd mod_ssl

# Start and enable Apache
sudo systemctl start httpd
sudo systemctl enable httpd

# Install EPEL and certbot
sudo amazon-linux-extras install epel -y
sudo yum install -y certbot python2-certbot-apache

# Configure ServerName (replace with your domain)
DOMAIN="<YOUR_IP>.nip.io"
sudo bash -c "echo 'ServerName $DOMAIN' >> /etc/httpd/conf/httpd.conf"

# Add VirtualHost for port 80 (required for certbot challenge)
sudo bash -c "cat >> /etc/httpd/conf/httpd.conf << EOF

<VirtualHost *:80>
    ServerName $DOMAIN
    DocumentRoot /var/www/html
</VirtualHost>
EOF"

sudo systemctl restart httpd

# Obtain Let's Encrypt SSL certificate
sudo certbot --apache -d $DOMAIN --non-interactive --agree-tos -m your@email.com

# Add Listen 443 and SSL session config
sudo bash -c 'cat > /etc/httpd/conf.d/ssl-listen.conf << EOF
Listen 443 https
SSLPassPhraseDialog exec:/usr/libexec/httpd-ssl-pass-dialog
SSLSessionCache         shmcb:/run/httpd/sslcache(512000)
SSLSessionCacheTimeout  300
SSLRandomSeed startup file:/dev/urandom  256
SSLRandomSeed connect builtin
SSLCryptoDevice builtin
EOF'

# Enable HSTS
sudo sed -i 's|</VirtualHost>|    Header always set Strict-Transport-Security "max-age=63072000; includeSubDomains"\n</VirtualHost>|' /etc/httpd/conf/httpd-le-ssl.conf
sudo bash -c 'echo "LoadModule headers_module modules/mod_headers.so" > /etc/httpd/conf.d/headers.conf'

sudo systemctl restart httpd
echo "Apache SSL setup complete!"
