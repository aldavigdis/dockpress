#!/bin/bash

apt-get update
apt-get dist-upgrade -y
apt-get install nginx php8.1-fpm php8.1 \
                php8.1-mysql php8.1-curl php8.1-memcached php8.1-memcache \
                php8.1-zip php8.1-xml php8.1-mbstring \
                php8.1-redis php8.1-bc php8.1-intl php8.1-ssh2 \
                mariadb-client curl locales jq less python3-pip -y

if [ ! $INSTALL_GHOSTSCRIPT ]
then
    apt-get install php8.1-imagick
fi

rm -rf /var/lib/apt/lists/*
localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp

# Update Python packages with known security vulnerabilities
python3 -m pip install cryptography --break-system-packages --upgrade
