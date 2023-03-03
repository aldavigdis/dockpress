#!/bin/bash

echo "📊 Configuring New Relic"
bash /root/install_new_relic.sh

echo "💣 Nuking File Permissions"
bash /root/nuke_permissions.sh

echo "🚀 Starting PHP-FPM and Nginx Web Server"
php-fpm8.1 && nginx -c /etc/nginx/nginx.conf -g 'daemon off;'
