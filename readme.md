# DockPress

```
   ______   _____  _______ _     _  _____   ______ _______ _______ _______
   |     \ |     | |       |____/  |_____] |_____/ |______ |______ |______
   |_____/ |_____| |_____  |    \_ |       |    \_ |______ ______| ______|

```

This is a build-it-yourself Docker image intended for WordPress sites that are
run in a cluster or a swarm in the cloud. It can also run as a development/test
environment where PHP-FPM, Nginx, Memcached and New Relic need to be accounted
for.

DockPress is designed with Kubernetes in mind and includes documentation on
deployment and operations in Google Cloud and Google Kubernetes engine.

Contributions are welcome.

This image is a build-it-yourself template and is **meant to be forked** and
modified for every use case, under the AGPL licence.

Application-specific things such as modifying the entry point and adding the
required secrets to pull a WordPress site from a git hosting provider (such as
Github) for a production site is up to you.

## DockPress has:

* Facilitates an immutable WordPress installation in the cloud, using **Docker** and **Kubernetes**
* Runs **PHP-FPM** 8.4 behind **Nginx** (as opposed to the legacy apache mod_php way of doing things)
* Keeps WordPress' uploads directory in a persistent volume
* Installs **Memcached** support for WP Object and PHP session storage
* Keeps credentials, salts and keys in a JSON file, which can be kept in a Kubernetes secret volume
* Facilitates the installation of and runs the **New Relic** PHP Agent, which is used for system monitoring
* Facilitiates changing image URLs to point to a different server (like a CDN)
* Installs and configures **Ghostscript** to work with ImageMagick and PHP to generate PDF thumbnails
* Includes documentation on **Kubernetes** deployment on Google Cloud

## Needed contributions:

* Improved testing and documentation
* Usage examples for beginner to advanced use
* Documentation and example YAML files for other cloud services such as AWS and IBM Cloud
* Scripts and interfaces to build YAML files and feed into `kubectl` based on variables

## Quick Start with Docker Desktop

This assumes you are not running this on Docker Desktop for testing or
development purposes.

Set up a MySQL server for WordPress to connect to and note down its IP address.
(You can do this via Docker or locally.)

Edit the `secets/credentials.json` file with the correct information and
credentials for your database, New Relic setup (leave blank if none) and the
Memcached server (leave as-is if none).

Example:

```json
{
    "mysql_server":       "172.17.0.2:3306",
    "mysql_db":           "wordpress",
    "mysql_user":         "root",
    "mysql_password":     "very_secure_password",
    "new_relic_app_name": "",
    "new_relic_key":      "",
    "memcached_servers":  [""],
    "memcached_key_salt": "ciVWNmAjdnKO5SUkEoUI",
    "auth_key":          "SuuPyW6VmNCHtUIyMjj9",
    "secure_auth_key":   "oEZl3jIFUOdgAfEpjtPE",
    "logged_in_key":     "HnCiub8gPhoxs8gFWtuA",
    "nonce_key":         "GSfL7q0E7f1VWQzwvIv5",
    "auth_salt":         "YrdqeWT3dfcCv46yY19H",
    "secure_auth_salt":  "sZ3vthTmfp0U60vGZjRX",
    "logged_in_salt":    "kToEN1cJe4aKDOq0iItf",
    "nonce_salt":        "uG1u4lyr3xXOKCY1cWih"
}
```

Build the Docker image:

```bash
docker build -t dockpress . -f Dockerfile --no-cache
```

Run the Docker image:

```bash
docker run -dp 80:80 --mount type=bind,src=$(pwd)/secrets,dst=/secrets \
                     dockpress
```

That's it!

## Features

The following is a list of features that can be enabled and facilitated by
environment variables that are set usig `ENV` statements in the Dockerfile.

### Fresh WordPress installation

Make sure tha the `WP_INSTALL_IF_NOT_FOUND` environment variable is set and if
no WordPress installation is found (the entrypoint script checks for
`index.php`), a new version of the WordPress Core is fetched and installed.

This is based on `wp-config-sample.php`, so that one needs to be in there for
the installation to work.

### Force WordPress configuration

DockPress's WordPress configuration script will not run (for the most part) if
`wp-config.php` already exists. In order to force it to run on deployment, you
can set the `FORCE_WP_CONFIG` environment variable.

This may have unintended consequences and it is recommended not to deploy or
version `wp-config.php` for use in Dockpress, as DockPress takes care of
configuring the WordPress installation. (I.e. keep your own `wp-config.php`
for development purposes, but add it to your `.gitignore` file.)

Furthermore, DockPress runs WP-CLI as root. If you have a WordPress installation
running and use `FORCE_WP_CONFIG`, the WP Core, themes, plugins, drop-ins etc.
will be run by root, which is the most priveleged user account on the system.

### New Relic PHP Agent installation

Set your New Relic credentials in `credentials.json` and the New Relic PHP Agent
will be installed and configured.

If you need a specific version of New Relic, you can set the `NR_PHP_AGENT_URL`
environment variable to the full URL of the newest version's .tar.gz archive.

Plese not that while optionally hosted in the EU, you may want to inform your
users about data egress to New Relic's servers, especially as NR injects
JavaScript code into the frontend of your site for performance monitoring.

### Debugging and error logging

Make sure that the `WP_DEBUG` environment varialbe is set to enable error
logging for WordPress' PHP bits and plugins that supress error reporting unless
`WP_DEBUG` is enabled.

Note that errors, warnings and notices are not displayed in the web interface,
but appear in the system log instead.

Non-minified versions of the WP Core's JavaScript libraries and CSS can be
loaded by setting the `WP_SCRIPT_DEBUG` environment variable.

### Refer to uploads on a different server

Set the `WP_UPLOADS_URL` or `WP_CONTENT_URL` environment variables to your CDN's
URL and WordPress will refer to that server when fetching images and other media
from your Media Library.

If you are syncing static files between your DockPress managed WP installation
and a CDN bucket, DockPress installs an mu-plugin that waits for files uploaded
using the Media Library to be reached from the CDN, before a the upload is
confirmed.

### Tweak PHP memory use

You can set the following environment variables, which will then be applied to
the corresponding values in `php.ini`.

* `PHP_UPLOAD_MAX_FILESIZE`
* `PHP_POST_MAX_SIZE`
* `PHP_MEMORY_LIMIT`

Those are currently set to be appropriate for Google Kubernetes Engine's
*General Purpose* pods.

Also note that WordPress tends to override the `PHP_MEMORY_LIMIT` value and uses
its own value, which is set to `40M` per process as if it's still the 90's and
most WordPress plugins weren't horriby inefficient.

To get past this, make sure that the `WP_MEMORY_LIMIT` ENV variable is set to a
good portion of the `PHP_MEMORY_LIMIT`. DockPress sets it to `448MB` by default.

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

### Ghostscript (GhostPDL) installation

Make sure that the `INSTALL_GHOSTSCRIPT` environment variable is set to enable
the installation of Ghostscript (as a part of the larger GhostPDL package).

Ghostpress may take a while to build from source.

Note that while *open source*, Ghostscript and GhostPDL are, like this package,
licenced under the GNU Affero General Public License by Artifex Software Inc and
availabe commerically as well.

Please check [Artiflex's licencing information](https://artifex.com/licensing/)
for more information on their licencing terms.

## Further Technical Stuff

### Users

Nginx and PHP-FPM run WordPress as the service account `www-data` by default.
In DockPress, the web root and the files in the WordPress installation are owned
by a service account `wp-services`, which then has elevated access.

This arrangement makes sure that the web server does not write files into the
WordPress installation while enabling maintainance, file sync and other tasks to
be run using a specific account.

### Expected volume mounts

* `/var/www/html/`: The storage location for the WordPress installation itself. If not set, a fresh installation may be made on deployment.
* `/secrets`: Contains the file `credentials.json`, which includes our MySQL credentials, the Memcached host, the New Relic key and the secure salts and keys used by WordPress. (In Kubernetes, you would use a secret volume for this.)

### File permissions

The Linux service account `www-data` (Debian user ID `33`) nees to have read
access to the mounted volumes and write access to
`/var/www/html/wp-content/uploads`.

Choosing to mount a volume accessed by `www-data` outside of `/var/www/html` may
result in SELinux stepping in and blocking access.

### WordPress keys and salts

Each node in a swarm needs to share the same salts and keys in order for things
like logging in and such to be consistent (and actually work) between nodes.

**Please replace the values with new, randomised values found at
https://api.wordpress.org/secret-key/1.1/salt/ or https://random.org for
production use.**

## Cloud Deployment

* [Google Cloud Services and GKE](docs/gcs_deployment.md)

## Build and send off to your private image registry

You can do the following to build and publish a Docker image based on DockPress
to your private Docker registry. The following uses my own internal URL for my
own build and yours will be different:

```bash
export registry_path=eu.gcr.io/dockerpress-379014/dockpress/dockpress:latest
docker build -t dockpress . -f Dockerfile
docker commit $(docker create dockpress) $registry_path
docker push $registry_path
```

## Licence

This software is licenced according to and is subject to the GNU Affero General
Public License (AGPL), with the possibility of an exception upon request.

The 3rd party software that it installs during build is generally subject to the
GPL licence or other highly permissive licences, with the exception of
Ghostscript/GhostPDL, which is also distributed according to the AGPL.

Please do not hesistate to contact the author to enquire about a license
exception or if there are questions about appropriate use of this software.

---

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
