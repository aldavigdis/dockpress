#!/bin/bash

if [ ! -f index.php ] && [ $WP_INSTALL_IF_NOT_FOUND ]
then
    wp core download --allow-root
fi

if [ ! -d wp-content/mu-plugins ]
then
    mkdir -p wp-content/mu-plugins
fi
cp /root/mu-plugins/* wp-content/mu-plugins

# If wp-config.php already exists, we will not edit it, unless the
# $FORCE_WP_CONFIG environment variable is set
if [ ! -f wp-config.php ] || [ $FORCE_WP_CONFIG ]
then
    if [ -f wp-config.php ]; then rm wp-config.php; fi
    cp wp-config-sample.php wp-config.php

    sed -i "/<?php/a \$credentials = json_decode( file_get_contents('/secrets/credentials.json') );" wp-config.php

    # Set the MySQL credentials
    wp config set DB_HOST "\$credentials->mysql_server" --raw --allow-root
    wp config set DB_NAME "\$credentials->mysql_db" --raw --allow-root
    wp config set DB_USER "\$credentials->mysql_user" --raw --allow-root
    wp config set DB_PASSWORD "\$credentials->mysql_password" --raw --allow-root

    # Set the WP salts and and keys based on a secret JSON file
    wp config set AUTH_KEY "\$credentials->auth_key" --raw --allow-root
    wp config set SECURE_AUTH_KEY "\$credentials->secure_auth_key" --raw --allow-root
    wp config set LOGGED_IN_KEY "\$credentials->logged_in_key" --raw --allow-root
    wp config set NONCE_KEY "\$credentials->nonce_key" --raw --allow-root
    wp config set AUTH_SALT "\$credentials->auth_salt" --raw --allow-root
    wp config set SECURE_AUTH_SALT "\$credentials->secure_auth_salt" --raw --allow-root
    wp config set LOGGED_IN_SALT "\$credentials->logged_in_salt" --raw --allow-root
    wp config set NONCE_SALT "\$credentials->nonce_salt" --raw --allow-root

    # Prevent redirect loop from happening if we are running WordPress behind a load balancer
    # This will make WP presume it is running on HTTPS, no matter if it is actually old-school HTTP on port 80
    sed -i "/Add any custom values between this line/a if ( isset( \$_SERVER['HTTP_X_FORWARDED_PROTO'] ) && strpos( \$_SERVER['HTTP_X_FORWARDED_PROTO'], 'https') !== false ) { \$_SERVER['HTTPS'] = 'on'; }" wp-config.php

    # Prevent edits and updates as we want the site to be immutable once deployed
    wp config set DISALLOW_FILE_EDIT true --raw --allow-root
    wp config set WP_AUTO_UPDATE_CORE false --raw --allow-root

    if [ $DISABLE_WP_CRON ]
    then
        wp config set DISABLE_WP_CRON true --allow-root
    fi

    if [ $WP_UPLOADS_URL ]
    then
        wp config set UPLOADS_URL "$WP_UPLOADS_URL" --allow-root
    fi

    # Enable Memcached object storage
    export MEMCACHED_HOST=$(jq -r '.memcached_servers[0]' /secrets/credentials.json)
    if [ $MEMCACHED_HOST ]
    then
        sed -i "/Add any custom values between this line/a \$memcached_servers = array( 'default' => \$credentials->memcached_servers );" wp-config.php
        curl -s https://plugins.trac.wordpress.org/export/HEAD/memcached/trunk/object-cache.php > ./wp-content/object-cache.php
        chmod $FILE_MODE ./wp-content/object-cache.php
        chown $FILE_OWNER ./wp-content/object-cache.php
    fi

    # Configure the CDN urls and scope, if enabled

    if [ $WP_CONTENT_URL ]
    then
        wp config set WP_CONTENT_URL "$WP_CONTENT_URL" --allow-root
    fi
fi

# Remove crapware plugins from the WordPress installation
if [ $REMOVE_CRAP_PLUGINS ]
then
    rm -rf wp-content/plugins/akismet/
    rm -rf wp-content/plugins/hello.php
fi

if [ ! -d wp-content/uploads ]
then
    echo "📁 Creating uploads directory"
    mkdir wp-content/uploads
    chmod a+rw wp-content/uploads
fi
