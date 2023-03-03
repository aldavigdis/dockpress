FROM ubuntu:jammy

EXPOSE 80

ENV NR_PHP_AGENT_URL 'https://download.newrelic.com/php_agent/archive/10.6.0.318/newrelic-php5-10.6.0.318-linux.tar.gz'
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

# Configure PHP
COPY bin/configure_php.sh /root/configure_php.sh
RUN /root/configure_php.sh

WORKDIR /var/www/html

COPY ./wordpress_site/ .

# If there was no index.php file located in the site/ directory, we fetch a fresh installation of WordPress
RUN if [ ! -f index.php ]; then wp core download --allow-root; fi

COPY ./bin/configure_wordpress.sh /root/configure_wordpress.sh
RUN /root/configure_wordpress.sh

COPY ./bin/install_new_relic.sh /root/install_new_relic.sh
COPY ./bin/nuke_permissions.sh /root/nuke_permissions.sh
COPY ./bin/entrypoint.sh /root/entrypoint.sh

RUN mkdir /run/php

ENTRYPOINT /root/entrypoint.sh
