# Dockpress

This is a build-it-yourself Docker image intended for WordPress sites that are
run in a cluster or a swarm in the cloud. It can also run as a development
environment where PHP-FPM, Nginx, Memcached and New Relic need to be accounted
for.

## Features

* Facilitates an immutable WordPress installation in the cloud, usin Docker or Kubernetes
* Runs PHP-FPM 8.1 behind Nginx (as opposed to the legacy apache mod_php of doing things)
* Keeps WordPress' uploads directory in a persistent volume
* Installes Memcached support for WP Object and PHP session storage
* Keeps credentials, salts and keys in a JSON file, located in a persistent volume
* Supports and runs the New Relic PHP Agent
* Facilitiates changing image URLs to point to a different server (like a CDN)

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

## Features

### Fresh WordPress installation

Make sure tha the `WP_INSTALL_IF_NOT_FOUND` environment variable is set and if
no WordPress installation is found (the entrypoint script checks for
`index.php`), a new version of the WordPress Core is fetched and installed.

### Force WordPress configuration

DockPress's WordPress configuration script will not run (for the most part) if
`wp-config.php` already exists. In order to force it to run on deployment, you
can set the `FORCE_WP_CONFIG`.

This may have unintended consequences and it is recommended not to deploy or
version `wp-config.php`, as DockPress takes care of configuring the WordPress
installation. (I.e. keep your own `wp-config.php` for development purposes, but
add it to your `.gitignore` file.)

### New Relic Agent installation

Set your New Relic credentials in `credentials.json` and the New Relic PHP Agent
will be installed and configured.

If you need a specific version of New Relic, you can set the `NR_PHP_AGENT_URL`
environment variable to the full URL of the newest version's .tar.gz archive.

### Refer to uploads on a different URL

Set the `WP_UPLOADS_URL` environment variable to your CDN's URL and WordPress
will refer to that server when fetching images and other media from your Media
Library.

This featue is disabled for logged-in users with the `upload_files` ability.

### Tweak PHP memory use

You can set the following environment variables, which will then be applied to
the corresponding values in `php.ini`.

* `PHP_UPLOAD_MAX_FILESIZE`
* `PHP_POST_MAX_SIZE`
* `PHP_MEMORY_LIMIT`

Those are currently set to be appropriate for Google Kubernetes Engine's
*General Purpose* pods.

### Tweak acceptable PHP response time

Set the `PHP_MAX_EXECUTION_TIME` to a numeric value, to set the number of
seconds to allow PHP processess to run. This sets both the `php.ini` value and
the relevant Nginx configuration variable.

### Nuke Permissions

Set the `NUKE_PERMISSIONS` environment variable to reset file and directory
permissions on deployment. This will scan your WordPress installation (but not
the `.git` or `wp-content/uploads` directories) and set file ownership to
`FILE_OWNER`, the file mode to `FILE_MODE` and directory mode to
`DIRECTORY_MODE`

Note that this takes a while to run, so if you are depending on rolling restarts
in a small cluster, this may not be the right thing to do.

### Remove crap plugins

If the `REMOVE_CRAP_PLUGINS` environment variable is set, the built-in Akismet
and hello.php plugins are removed from the WordPress installation.

### Prevent updates

Keep the `PREVENT_UPDATES` environment variable set in order to make sure that
the WordPress core, plugins and themes are not updated.

In case of running DockPress in a cluster, if each node/pod has its own file
storage and runs the built-in update mechanism,

This also ensures that the WordPress installation is immutable and makes it less
likely that the site is exploited by and falls victim to code injection.

## Further Technical Stuff

This image requires two volumes to be mounted at the following paths:

* `/var/www/html/`: The storage location for the WordPress installation itself. If not set, a fresh installation is made on deployment.
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

## Build and send off to your private image registry

You can do the following to build and publish a Docker image based on DockPress
to your private Docker registry:

```bash
export registry_path=eu.gcr.io/dockerpress-379014/dockpress/dockpress:latest

docker build -t dockpress . -f Dockerfile

# You can also run `docker create dockpress` if you don't want to test anything
docker run -dp 80:80 --mount type=bind,src=$(pwd)/secrets,dst=/secrets \
                     --mount type=bind,src=$(pwd)/wordpress_site,dst=/var/www/html \
                     --mount type=bind,src=$(pwd)/uploads,dst=/uploads \
                     dockpress

docker commit $(docker create dockpress) $registry_path

docker push $registry_path
```

## Licence

Please do not hesistate to contact the author to enquire about a license
exception or if there are questions about appropriate use of this software.

**Copyright (C) 2023 Alda Vigdís Skarphéðinsdóttir (aldavigdis@aldavigdis.is)**

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program. If not, see <https://www.gnu.org/licenses/>.
