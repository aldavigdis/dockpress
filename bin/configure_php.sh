#!/bin/bash

# Make the memory limits and file size limits a bit more generous
sed -i -e "s/upload_max_filesize = 2M/upload_max_filesize = ${PHP_UPLOAD_MAX_FILESIZE}/" /etc/php/8.4/fpm/php.ini
sed -i -e "s/post_max_size = 8M/post_max_size = ${PHP_POST_MAX_SIZE}/" /etc/php/8.4/fpm/php.ini
sed -i -e "s/memory_limit = 128M/memory_limit = ${PHP_MEMORY_LIMIT}/" /etc/php/8.4/fpm/php.ini
sed -i -e "s/max_execution_time = 30/max_execution_time = ${PHP_MAX_EXECUTION_TIME}/" /etc/php/8.4/fpm/php.ini

sed -i -e "s/error_reporting =.*/error_reporting = ${PHP_ERROR_REPORTING}/" /etc/php/8.4/fpm/php.ini

sed -i "/\;catch_workers_output = yes/a catch_workers_output = yes" /etc/php/8.4/fpm/pool.d/www.conf


# Make Memcached the PHP session handler if the $MEMCACHED_HOST environment variable is set
export MEMCACHED_HOST=$(jq -r '.memcached_servers[0]' /secrets/credentials.json)
if [ $MEMCACHED_HOST ]
then
    sed -i -e "s/session.save_handler = files/session.save_handler = memcached\nsession.save_path = \"${MEMCACHED_HOST}\"/" /etc/php/8.4/fpm/php.ini
fi
