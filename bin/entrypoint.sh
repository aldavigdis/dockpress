#!/bin/bash

echo "🐘 Configuring PHP"
RUN /root/configure_php.sh

echo "📊 Configuring New Relic"
bash /root/install_new_relic.sh

if [ $NUKE_PERMISSIONS ]
then
    echo "💣 Nuking File Permissions"
    bash /root/nuke_permissions.sh
fi

echo "🔧 Configuring WordPress"
bash /root/configure_wordpress.sh

echo "🚀 Starting PHP-FPM and Nginx Web Server"
php-fpm8.1 && nginx -c /etc/nginx/nginx.conf -g 'daemon off;'
