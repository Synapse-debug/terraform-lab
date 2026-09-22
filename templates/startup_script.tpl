#! /bin/bash
amazon-linux-extras install -y nginx1
sed -i 's/listen       \[::\]:80;/#listen \[::\]:80;/' /etc/nginx/nginx.conf
sed -i 's/listen       80;/listen 10.0.0.10:80;/' /etc/nginx/nginx.conf
nginx
rm -f /usr/share/nginx/html/index.html
echo '<h1>Welcome to the ${environment} website! Have a pizza! 🍕</h1>' > /usr/share/nginx/html/index.html