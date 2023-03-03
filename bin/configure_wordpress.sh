#!/bin/bash

if [ ! -f wp-config.php ]
then
  cp wp-config-sample.php wp-config.php
fi

# Set the MySQL credentials
sed -i "/<?php/a \$credentials = json_decode( file_get_contents('/secrets/credentials.json') );" wp-config.php
wp config set DB_HOST "\$credentials->mysql_server" --raw --allow-root
wp config set DB_NAME "\$credentials->mysql_db" --raw --allow-root
wp config set DB_USER "\$credentials->mysql_user" --raw --allow-root
wp config set DB_PASSWORD "\$credentials->mysql_password" --raw --allow-root

# Set the WP salts and and keys based on a secret JSON file
sed -i "/<?php/a \$salts = json_decode( file_get_contents('/secrets/wp_salts.json') );" wp-config.php
wp config set AUTH_KEY "\$salts->auth_key" --raw --allow-root
wp config set SECURE_AUTH_KEY "\$salts->secure_auth_key" --raw --allow-root
wp config set LOGGED_IN_KEY "\$salts->logged_in_key" --raw --allow-root
wp config set NONCE_KEY "\$salts->nonce_key" --raw --allow-root
wp config set AUTH_SALT "\$salts->auth_salt" --raw --allow-root
wp config set SECURE_AUTH_SALT "\$salts->secure_auth_salt" --raw --allow-root
wp config set LOGGED_IN_SALT "\$salts->logged_in_salt" --raw --allow-root
wp config set NONCE_SALT "\$salts->nonce_salt" --raw --allow-root

# Prevent redirect loop from happening if we are running WordPress behind a load balancer
sed -i "/Add any custom values between this line/a if ( isset( \$_SERVER['HTTP_X_FORWARDED_PROTO'] ) && strpos( \$_SERVER['HTTP_X_FORWARDED_PROTO'], 'https') !== false ) { \$_SERVER['HTTPS'] = 'on'; }" wp-config.php

# Enable Memcached object storage
export MEMCACHED_HOST=$(jq -r '.memcached_servers[0]' /secrets/credentials.json)
if [ $MEMCACHED_HOST ]
then
  sed -i "/Add any custom values between this line/a \$memcached_servers = array( 'default' => \$credentials->memcached_servers );" wp-config.php
  curl https://plugins.trac.wordpress.org/export/HEAD/memcached/trunk/object-cache.php > /var/www/html/wp-content/object-cache.php
fi

# Remove crapware plugins from the WordPress installation
rm -rf wp-content/plugins/akismet/
rm -rf wp-content/plugins/hello.php
