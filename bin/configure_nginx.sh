#!/bin/bash

sed -i -e "s/access_log \/var\/log\/nginx\/access.log;/access_log \/dev\/stdout;/" /etc/nginx/nginx.conf
sed -i -e "s/error_log \/var\/log\/nginx\/error.log;/error_log \/dev\/stderr;/" /etc/nginx/nginx.conf
