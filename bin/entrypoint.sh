#!/bin/bash

echo "🐘 Configuring PHP"
bash /root/configure_php.sh

echo "📊 Configuring New Relic"
bash /root/install_new_relic.sh

sleep 1m

echo "🔧 Configuring WordPress"
bash /root/configure_wordpress.sh

if [ $NUKE_PERMISSIONS ]
then
    echo "💣 Nuking File Permissions"
    bash /root/nuke_permissions.sh
fi

echo "🚀 Starting PHP-FPM and Nginx Web Server"
php-fpm8.4 && nginx -c /etc/nginx/nginx.conf -g 'daemon off;'
