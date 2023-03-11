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

## A quick note

This image is a build-it-yourself template and is **meant to be forked** and
modified for every use case.

In its current state, it works both in a local development environment using
Docker Desktop and [GCS/Kubernetes deployment](/docs/gcs_deployment.md) has been
documented.

However, application-specific things such as modifying the entry point and
adding the required secrets to pull a WordPress site from a git hosting provider
(such as Github) for a production site is up to you.

## Quick Start with Docker Desktop

This assumes you are not running this on Docker Desktop for testing or
development purposes.

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

## Directing assets to a CDN

To activate CDN support, simply comment out and edit the relevant environment variables in the `Dockerfile` and your static assets will be downloaded from a CDN/proxy server instead of your main web server. Your image then needs to be rebuilt and redeployed in order for the changes to take effect.

Note that in some cases, hard-coded URLs to assets will not change automatically and require manual replacement or clever use of WP CLI's `find-replace` command.

Dockpress offers two ways to scope which files are fetched from a general purpose CDN service, defined with the `CDN_SCOPE` environment variable:

* `uploads`: This only affects URLs for what ends up in the `wp-content/uploads` directory
* `content`: This affects URLs for everything in the `wp-content` directory, including assets from themes and plugins

If you choose to use the `uploads` scope, the base URL for the assets is defined using the `CDN_UPLOADS_URL` environment variable. The base URL for the `content` scope is defined using the `CDN_CONTENT_URL` variable.

## Cloud Deployment

* [Google Cloud Services and GKE](docs/gcs_deployment.md)

## TODOs:

1. Find a way to clear or invalidate Memcached easily
2. Figure out if keeping the defaults for wp-cron is a good idea or if developing a "runner" container for wp-cron is better.
3. Improve error handling.
4. Add Redis support.

## Build and send off to your private image registry

You can do the following

```bash
export registry_path=eu.gcr.io/dockerpress-379014/dockpress/dockpress:latest

docker build -t dockpress . -f Dockerfile

# You can also run `docker create dockpress` if you don't want to test anything
docker run -dp 80:80 --mount type=bind,src=$(pwd)/secrets,dst=/secrets \
                     --mount type=bind,src=$(pwd)/uploads,dst=/var/www/html/wp-content/uploads \
                     dockpress

docker commit $(docker create dockpress) $registry_path

docker push $registry_path
```
