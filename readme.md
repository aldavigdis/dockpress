# Dockpress

This is a build-it-yourself Docker image intended for WordPress sites that are
run in a cluster or a swarm in the cloud. It can also run as a development
environment where PHP-FPM, Nginx, Memcached and New Relic need to be accounted
for.

You can fork this codebase and use it as the basis of your own WordPress
development by placing your WP site in the `wordpress_site` directory and
committing it to the codebase; plugins, themes and all by running
`git add wordpress_site/*`.

This enables the site to be baked into the Docker image when you build and
deploy it.

## Features

* Runs PHP-FPM 8.1 behind Nginx (as opposed to the legacy apache mod_php of doing things)
* Keeps WordPress' uploads directory in a persistent volume
* Supports Memcached for WP Object and PHP session storage
* Keeps credentials, salts and keys in JSON files, located in a persistent volume
* Supports and runs the New Relic PHP Agent

## Quick Start

This assumes you are not running this on Docker Desktop for testing or
development purposes. You may want to do things differently in your production
or staging environments.

Set up a MySQL server for WordPress to connect to. (You can do this via Docker
or locally.)

Optionally, you can set up a Memcached server. (Docker is ideal for this, as
this does not need persistent storage.)

Then you may want to sign up for New Relic.

Copy your WordPress codebase into the `wordpress_site/` directory, including
your plugins, themes and other modifications to the code. If you don't have a
site ready, a new one is provisioned automatically if that directory does not
have an `index.php` file in it.

Edit the `secets/credentials.json` file with the correct information and
credentials for your database, New Relic setup (leave blank if none) and the
Memcached server (leave as-is if none).

Build the Docker image:

```bash
docker build -t dockpress . -f Dockerfile --no-cache
```

Run the Docker image:

```bash
docker run -dp 80:80 --mount type=bind,src=$(pwd)/secrets,dst=/secrets \
                     --mount type=bind,src=$(pwd)/uploads,dst=/var/www/html/wp-content/uploads \
                     dockpress
```

That's it!

## Further Technical Stuff

The source code of the WordPress site is assumed to reside in the
`wordpress_site/` directory. In case there is no index.php file in there, a
fresh installation is made using WP-CLI.

Regardless, it is recommended to download WordPress into `wordpress_site/`,
even if you want to start at a blank slate and adjusting the file permissions
and ownership in there before building the Docker image.

Assuming you have WP-CLI installed:

```bash
cd wordpress_site
wp core download
chown -R www-data:www-data .
find . -type d -exec chmod 755 {} \;
find . -type f -exec chmod 644 {} \;
cd ..
docker build -t dockpress . -f Dockerfile
```

You can set the NUKE_FILE_PERMISSIONS environment variable in the Dockerfile to
reset the file permissions and ownership.

This image requires two volumes to be mounted at the following paths:

* `/secrets`: Contains the file `credentials.json`, which includes our MySQL credentials, the Memcached host, the New Relic key and the secure salts and keys used by WordPress.
* `/var/www/html/wp-content/uploads`: The persistent storage location for WordPress uploads. If it isn't mounted, then those files will be lost as soon as the container is restarted and each swarm node will not have access to each uploaded file.

In case no New Relic app name or key are supplied in the `credentials.json`
file, the New Relic installer will simply not run.

The same goes with Memcached. If it is an array containing null, Memcached will
not be configured as the PHP session store and the Memcached drop-in will not be
installed.

MySQL credentials and the WordPress Salts and Keys (stored in
`secrets/wp-salts.json`) can be changed during runtime as wp-config.php will be
configured to refer to those values directly.

Each node in a swarm needs to share the same salts and keys in order for things
like logging in and such to be consistent (and actually work) between nodes.

**Please replace the values with new, randomised values found at https://api.wordpress.org/secret-key/1.1/salt/ for production use.**

## Cloud Deployment

* [Google Cloud Services and GKE](docs/gcs_deployment.md)

## TODOs:

1. Figure out if keeping the defaults for wp-cron is a good idea or if developing a "runner" container for wp-cron is better.
2. Improve error handling.
3. Add Redis support.

## Build and send off

(The following is for internal purposes.)

```bash
$ docker build -t dockpress . -f Dockerfile
$ docker run -dp 80:80 dockpress
$ docker commit <hash> eu.gcr.io/dockerpress-379014/dockpress/dockpress:latest
$ docker push eu.gcr.io/dockerpress-379014/dockpress/dockpress
```
