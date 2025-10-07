#!/bin/bash

apt-get update
apt-get install apt-utils software-properties-common -y
add-apt-repository ppa:ondrej/php -y
add-apt-repository ppa:ondrej/nginx -y
apt-get update
apt-get dist-upgrade -y
apt-get install nginx php8.4-fpm php8.4 \
                php8.4-mysql php8.4-curl php8.4-memcached php8.4-memcache \
                php8.4-zip php8.4-xml php8.4-mbstring php8.4-imagick \
                php8.4-redis php8.4-bc php8.4-intl php8.4-ssh2 \
                mariadb-client curl locales jq less vim -y

rm -rf /var/lib/apt/lists/*
localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp
