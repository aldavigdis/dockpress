FROM ubuntu:lunar

EXPOSE 80

ENV NR_PHP_AGENT_URL 'https://download.newrelic.com/php_agent/archive/10.16.0.5/newrelic-php5-10.16.0.5-linux.tar.gz'
ENV GHOSTSCRIPT_URL 'https://github.com/ArtifexSoftware/ghostpdl-downloads/releases/download/gs10021/ghostscript-10.02.1.tar.gz'

# ENV INSTALL_GHOSTSCRIPT true

ENV WP_INSTALL_IF_NOT_FOUND true
ENV WP_MEMORY_LIMIT = '448M'

ENV PHP_UPLOAD_MAX_FILESIZE '256M'
ENV PHP_POST_MAX_SIZE '384M'
ENV PHP_MEMORY_LIMIT '512M'
ENV PHP_MAX_EXECUTION_TIME '240'

ENV PHP_ERROR_REPORTING 'E_ALL \& ~E_STRICT'
ENV WP_DEBUG true

# ENV WP_UPLOADS_URL 'https://cdn.aldavigdis.dev'
# ENV WP_CONTENT_URL 'https://cdn.aldavigdis.dev'

# Remove Akismet and hello.php during deployment
ENV REMOVE_CRAP_PLUGINS true

# Stops the WP updating mechanism
ENV PREVENT_UPDATES true

# Wether we should fix file permissions on deployment or not
# ENV NUKE_PERMISSIONS true

ENV FILE_OWNER 'wp-services'
ENV FILE_GROUP 'www-data'
ENV FILE_MODE 0644
ENV DIRECTORY_MODE 0644
RUN useradd wp-services -r -m --shell=/bin/false --uid=699

ENV DEBIAN_FRONTEND=noninteractive

# Install PHP and related packages, plus locales
COPY ./bin/install_packages.sh /root/install_packages.sh
RUN bash /root/install_packages.sh
ENV LANG en_US.utf8

# Install Ghostscript
COPY ./bin/install_ghostscript.sh /root/install_ghostscript.sh
RUN if [ $INSTALL_GHOSTSCRIPT ]; then bash /root/install_ghostscript.sh; fi

# Copy over our nginx site config
COPY ./nginx_config/default_site /etc/nginx/sites-enabled/default

# Run further nginx configurations
COPY bin/configure_nginx.sh /root/configure_nginx.sh
RUN /root/configure_nginx.sh

WORKDIR /var/www/html

# COPY wordpress_site/ .

COPY mu-plugins/ /root/mu-plugins/

COPY bin/* /root/

ENTRYPOINT /root/entrypoint.sh
