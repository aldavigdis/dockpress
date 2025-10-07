```bash
apt-get update
apt-get install less php inotify-tool php8.4 \
                php8.4-mysql php8.4-curl php8.4-memcached php8.4-memcache \
                php8.4-zip php8.4-xml php8.4-mbstring php8.4-imagick \
                php8.4-redis php8.4-bc php8.4-intl php8.4-ssh2 \
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
