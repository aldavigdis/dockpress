#!/bin/bash

export MEMCACHED_HOST $(jq -r '.memcached_servers[0]' secrets/credentials.json)

# Make the memory limits and file size limits a bit more generous
sed -i -e "s/upload_max_filesize = 2M/upload_max_filesize = 128M/" /etc/php/8.1/fpm/php.ini
sed -i -e "s/post_max_size = 8M/post_max_size = 512M/" /etc/php/8.1/fpm/php.ini
sed -i -e "s/memory_limit = 128M/memory_limit = 1024M/" /etc/php/8.1/fpm/php.ini

# Make Memcached the PHP session handler if the $MEMCACHED_HOST environment variable is set
export MEMCACHED_HOST $(jq -r '.memcached_servers[0]' secrets/credentials.json)

if [ $MEMCACHED_HOST ]
then
    sed -i -e "s/session.save_handler = files/session.save_handler = memcached\nsession.save_path = \"${MEMCACHED_HOST}\"/" /etc/php/8.1/fpm/php.ini
fi