#!/bin/bash

if [ ! -f index.php ] && [ $WP_INSTALL_IF_NOT_FOUND ]
then
    if [ $WP_INSTALL_VERSION ]
    then
        wp core download --version="$WP_INSTALL_VERSION" --allow-root
    else
        wp core download --allow-root
    fi
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

    if [ "$WP_DEBUG" ]
    then
        wp config set WP_DEBUG true --raw --allow-root
        wp config set WP_DEBUG_DISPLAY false --raw --allow-root
    fi

    if [ "$WP_SCRIPT_DEBUG" ]
    then
        wp config set SCRIPT_DEBUG false --raw --allow-root
    fi

    if [ "$WP_MEMORY_LIMIT" ]
    then
        wp config set WP_MEMORY_LIMIT "$WP_MEMORY_LIMIT" --allow-root
        wp config set WP_MAX_MEMORY_LIMIT "$WP_MEMORY_LIMIT" --allow-root
    else
        wp config set WP_MEMORY_LIMIT "ini_get( 'memory_limit' )" --raw --allow-root
        wp config set WP_MAX_MEMORY_LIMIT "ini_get( 'memory_limit' )" --raw --allow-root
    fi

    if [ "$DISABLE_WP_CRON" ]
    then
        wp config set DISABLE_WP_CRON true --allow-root
    fi

    if [ "$WP_UPLOADS_URL" ]
    then
        wp config set UPLOADS_URL "$WP_UPLOADS_URL" --allow-root
    fi

    # Enable Memcached object storage
    memcached_host=$(jq -r '.memcached_servers[0]' /secrets/credentials.json)
    if [ "$memcached_host" ]
    then
        sed -i "/Add any custom values between this line/a \$memcached_servers = array( 'default' => \$credentials->memcached_servers );" wp-config.php
        curl -s https://plugins.trac.wordpress.org/export/HEAD/memcached/trunk/object-cache.php > ./wp-content/object-cache.php
        if [ "$FILE_MODE" ]
        then
            chmod "$FILE_MODE" ./wp-content/object-cache.php
        fi
        if [ "$FILE_OWNER" ]
        then
            chown "$FILE_OWNER" ./wp-content/object-cache.php
        fi
    fi

    if [ "$WP_CONTENT_URL" ]
    then
        wp config set WP_CONTENT_URL "$WP_CONTENT_URL" --allow-root
    fi
fi

wp core install --url="localhost" --title="DockPress Site" --admin_user="admin" --admin_password="password" --admin_email="root@example.com" --skip-email --allow-root

if [ "$WP_THEME_INSTALL" ]
then
    wp theme install "$WP_THEME_INSTALL" --allow-root
fi

if [ "$WP_THEME_ACTIVATE" ]
then
    wp theme activate "$WP_THEME_ACTIVATE" --allow-root
fi

if [ "$WP_PLUGIN_INSTALL" ]
then
    wp plugin install "$WP_PLUGIN_INSTALL" --allow-root
fi

if [ "$WP_PLUGIN_ACTIVATE" ]
then
    wp plugin activate "$WP_PLUGIN_ACTIVATE" --allow-root
fi

# Remove crapware plugins from the WordPress installation
if [ "$REMOVE_CRAP_PLUGINS" ]
then
    rm -rf wp-content/plugins/akismet/
    rm -rf wp-content/plugins/hello.php
fi

if [ ! -d wp-content/uploads ]
then
    echo "📁 Creating uploads directory"
    mkdir wp-content/uploads
fi
