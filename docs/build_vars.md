| Variable                  | Default       | Description | Build | Run
| ------------------------- | ------------- | ----------- | ----- | --- |
| `INSTALL_GHOSTSCRIPT`     | `true`        | If set, then Ghostscript, ImageMagick and php-imagick will be compiled and installed from source, enabling thumbnails for PDFs in WordPress. | ✔️ |
| `NR_PHP_AGENT_URL`        |               | The URL for the `.tar.gz` package containing the New Relic PHP Agent. | | ✔️ |
| `NUKE_PERMISSIONS`        |               | If set, then WordPress file and directory permissions will be reset to the ones indicated by `FILE_OWNER`, `FILE_GROUP`, `FILE_MODE` and `DIRECTORY_MODE` | | ✔️ |
| `FILE_OWNER`              | `wp-services` | The owner of some new files created by DockPress and when permssions are reset using `NUKE_PERMISSION` | ✔️ | ✔️ |
| `FILE_GROUP`              | `www-data`    | The group that owns some new files created by DockPRess and when permissions are reset using `NUKE_PERMISSIONS` | ✔️ | ✔️ |
| `FILE_MODE`               | `0644`        | The access mode for files in the web root
| `DIRECTORY_MODE`          | `0644`        | The access mode for directories in the web root
| `WP_INSTALL_IF_NOT_FOUND` | `true`        | If set, installs WordPress if `index.php` is not found in the web root. | | ✔️ |
| `WP_INSTALL_VERSION `     |               | Sets the version of WordPress to install, defaults to installing the newest public version. | | ✔️ |
| `FORCE_WP_CONFIG`         |               | If set, an already-existing `wp-config.php` is edited. If not set, a new file is created based on `wp-config-sample.php`.     | | ✔️ |
| `WP_DEBUG`                | `true`        | Enables WordPress error logging. | | ✔️ |
| `WP_SCRIPT_DEBUG`         |               | If set, WordPress will use the development versions of CSS and JavaScript files | | ✔️ |
| `WP_PLUGIN_INSTALL`       |               | Indicates plugins to install. May be plugin slugs, URLs or paths to ZIP files; singular or comma separated. | | ✔️ |
| `WP_PLUGIN_ACTIVATE`      |               | Indictes plugins to be activated. You may want to set this to the same value as `WP_PLUGIN_INSTALL`. | | ✔️ |
| `WP_THEME_INSTALL`        |               | Indicates themes to install. Same format as `WP_PLUGIN_INSTALL`. | | ✔️ |
| `REMOVE_CRAP_PLUGINS `    |               | Removes the useless Akismet and hello.php plugins that come with the WordPress core. | | ✔️ |
| `WP_THEME_ACTIVATE`       |               | Indicates the theme to activate. | | ✔️ |
| `DISABLE_WP_CRON`         |               | Disables the wp_cron.php requests coming from clients. This is useful when you can rely on a separate runner or a systemd service for running wp-cron instead and lowers system resources required by each active user on the site. | | ✔️ |
| `WP_UPLOADS_URL`          |               | Sets the URL for the WordPress uploads if a CDN server is used for uploads only. | | ✔️ |
| `WP_CONTENT_URL `         |               | Sets the URL for where static content from wp-content is served from
| `WP_MEMORY_LIMIT`         | `512M`        | Sets the WordPress memory limit and max memory limit. This defaults on 40 MB in WordPress, so setting it to something close to the value of `PHP_MEMORY_LIMIT` may be a good idea. | | ✔️ |
| `PHP_MAX_EXECUTION_TIME`  | `240`         | The maximum execution time in seconds for PHP-FPM and Nginx. | | ✔️ |
| `PHP_UPLOAD_MAX_FILESIZE` | `256M`        | Sets the `upload_max_filesize` php.ini value. | | ✔️ |
| `PHP_ERROR_REPORTING`     | `E_ALL \& ~E_STRICT` | Sets the `error_reporting` php.ini value. (See: https://www.php.net/manual/en/errorfunc.configuration.php#ini.error-reporting). | | ✔️ |
