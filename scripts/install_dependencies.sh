#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

# Install tomcat and httpd
yum install -y tomcat httpd

# Enable and start services
systemctl enable tomcat
systemctl start tomcat

systemctl enable httpd
systemctl start httpd

# Enable proxy modules (for Amazon Linux 2 / RHEL-based)
# For Amazon Linux 2, mod_proxy is included but not enabled by default
# Let's ensure proxy modules are loaded by adding them to /etc/httpd/conf.modules.d/proxy.conf
cat > /etc/httpd/conf.modules.d/proxy.conf << 'EOF'
LoadModule proxy_module modules/mod_proxy.so
LoadModule proxy_http_module modules/mod_proxy_http.so
EOF

# Create Apache virtual host config for Tomcat proxy
cat > /etc/httpd/conf.d/tomcat_manager.conf << EOF
<VirtualHost *:80>
  ServerAdmin root@localhost
  ServerName app.nextwork.com
  ProxyRequests off
  ProxyPreserveHost On
  ProxyPass / http://localhost:8080/astro-web-project/
  ProxyPassReverse / http://localhost:8080/astro-web-project/
</VirtualHost>
EOF

# Restart Apache to apply changes
systemctl restart httpd
