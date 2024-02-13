```bash
apt-get update
apt-get install less php inotify-tool php8.1 \
                php8.1-mysql php8.1-curl php8.1-memcached php8.1-memcache \
                php8.1-zip php8.1-xml php8.1-mbstring php8.1-imagick \
                php8.1-redis php8.1-bc php8.1-intl php8.1-ssh2 \
                mariadb-client
useradd wp-services -r -m --shell=/bin/false --uid=699
```

Instal the New Relic PHP Agent. It is up to you if you name it something other
than your web app (I prefer to do that myself). After the installation, you may
be promted to "restart your web server" but as we are using the CLI version of
PHP, it is not needed.

```bash
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp
alias wp="sudo -u wp-services -- wp"
```

```bash
sudo -u wp-services -- gcloud auth activate-service-account \
                       --key-file=/home/wp-services/bucket-key.json
```
