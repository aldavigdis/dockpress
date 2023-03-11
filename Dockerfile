FROM ubuntu:jammy

EXPOSE 80

ENV NR_PHP_AGENT_URL 'https://download.newrelic.com/php_agent/archive/10.6.0.318/newrelic-php5-10.6.0.318-linux.tar.gz'

ENV PHP_UPLOAD_MAX_FILESIZE '64M'
ENV PHP_POST_MAX_SIZE '128M'
ENV PHP_MEMORY_LIMIT '256M'

ENV CDN_SCOPE 'uploads'
ENV CDN_UPLOADS_URL 'https://cdn.example.com/wp-content/uploads'
ENV CDN_CONTENT_URL 'https://cdn.example.com/wp-content/'

# Wether we should fix file permissions on deployment or not
ENV NUKE_PERMISSIONS true

# Remove Akismet and hello.php during deployment
ENV REMOVE_CRAP_PLUGINS true

# Stops the WP updating mechanism
ENV PREVENT_UPDATES true

# Stops WP from preventing large image uploads
ENV DISABLE_IMAGE_SCALING true

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

COPY mu-plugins/ /root/mu-plugins/
RUN mkdir mu-plugins
RUN if [ $PREVENT_UPDATES ]; then cp /root/mu-plugins/dockpress-prevent-updates.php mu-plugins/; fi
RUN if [ $DISABLE_IMAGE_SCALING ]; then cp /root/mu-plugins/dockpress-disable-image-scaling.php mu-plugins/; fi
RUN if [ $CDN_SCOPE ]; then cp /root/mu-plugins/dockpress-filter-cdn-url.php mu-plugins/; fi

COPY wordpress_site/ .

# If there was no index.php file located in the site/ directory, we fetch a fresh installation of WordPress
RUN if [ ! -f index.php ]; then wp core download --allow-root; fi

COPY bin/* /root/

RUN mkdir /run/php

ENTRYPOINT /root/entrypoint.sh
