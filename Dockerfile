FROM ubuntu:jammy

EXPOSE 80

ENV NR_PHP_AGENT_URL 'https://download.newrelic.com/php_agent/archive/10.6.0.318/newrelic-php5-10.6.0.318-linux.tar.gz'

ENV WP_INSTALL_IF_NOT_FOUND true
# ENV FORCE_WP_CONFIG true

ENV PHP_UPLOAD_MAX_FILESIZE '256M'
ENV PHP_POST_MAX_SIZE '384M'
ENV PHP_MEMORY_LIMIT '512M'

# ENV WP_UPLOADS_URL 'https://cdn.example.com'

# Remove Akismet and hello.php during deployment
ENV REMOVE_CRAP_PLUGINS true

# Stops the WP updating mechanism
ENV PREVENT_UPDATES true

# Wether we should fix file permissions on deployment or not
# ENV NUKE_PERMISSIONS true

# The "Hardening WordPress" article at https://wordpress.org/documentation/article/hardening-wordpress/
# recommends 755 and 644
ENV FILE_OWNER 'www-data:www-data'
ENV FILE_MODE 444
ENV DIRECTORY_MODE 555

ENV DEBIAN_FRONTEND=noninteractive

# Install PHP and related packages, plus locales
COPY ./bin/install_packages.sh /root/install_packages.sh
RUN bash /root/install_packages.sh
ENV LANG en_US.utf8

# Copy over our nginx site config
COPY ./nginx_config/default_site /etc/nginx/sites-enabled/default

# Run further nginx configurations
COPY bin/configure_nginx.sh /root/configure_nginx.sh
RUN /root/configure_nginx.sh

WORKDIR /var/www/html

# COPY wordpress_site/ .

COPY mu-plugins/ /root/mu-plugins/

COPY bin/* /root/

RUN mkdir /run/php

ENTRYPOINT /root/entrypoint.sh
