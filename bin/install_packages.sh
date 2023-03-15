#!/bin/bash

apt-get update
apt-get install software-properties-common -y
add-apt-repository ppa:ondrej/php
apt-get install sudo nginx php8.1-fpm php8.1 \
                php8.1-mysqli php8.1-curl php8.1-memcached php8.1-memcache \
                php8.1-zip php8.1-dom php8.1-mbstring -y php8.1-imagick \
                php8.1-redis php8.1-bc php8.1-gd php8.1-intl php8.1-ssh2 \
                mariadb-client curl locales jq less -y

rm -rf /var/lib/apt/lists/*
localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp
