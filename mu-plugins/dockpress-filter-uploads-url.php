<?php
/**
 * Filters URLs for assets in the Media Library so that they point to a specific
 * root url defined using the UPLOADS_URL constant in wp-config.php.
 *
 * This is unlike the effects of setting the value of WP_CONTENT_URL as here,
 * we only retreive media files from the specified root url but not all static content such as CSS and JS files.
 *
 * @package dockpress
 */

if ( defined( 'UPLOADS_URL' ) ) {
	add_filter(
		'pre_option_upload_url_path',
		'dockpress_filter_uploads_url'
	);
}

/**
 * Filter the uploads url to point to the value of UPLOADS_URL
 */
function dockpress_filter_uploads_url() {
	return UPLOADS_URL;
}
