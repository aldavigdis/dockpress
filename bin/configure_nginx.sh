#!/bin/bash

# sed -i -e "s/access_log \/var\/log\/nginx\/access.log;/access_log \/dev\/stdout;/" /etc/nginx/nginx.conf
# sed -i -e "s/error_log \/var\/log\/nginx\/error.log;/error_log \/dev\/stderr;/" /etc/nginx/nginx.conf

if [ $PHP_MAX_EXECUTION_TIME ]
then
    sed -i -e "s/fastcgi_read_timeout 30;/fastcgi_read_timeout ${PHP_MAX_EXECUTION_TIME};/" /etc/nginx/sites-enabled/default
    sed -i -e "s/fastcgi_send_timeout 30;/fastcgi_send_timeout ${PHP_MAX_EXECUTION_TIME};/" /etc/nginx/sites-enabled/default
fi
