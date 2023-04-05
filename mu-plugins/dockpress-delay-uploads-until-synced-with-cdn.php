<?php
/**
 * Makes the uploader wait for the uploaded file to be reachable via HTTP by
 * checking its existence 5 times on a 5 second interval.
 * This is useful when WP_CONTENT_URL has been defined as an external URL that
 * requires something like rsync to be run as a file changes in the wp-content
 * directory.
 *
 * In a normal non-CDN setup, a file can be reached right away, so that a
 * thumbnail can be displayed in the Media Library uploader or the editor as
 * soon as it makes it to the filesystem. When using a static CDN however, it
 * may take a couple of second for the file to appear there, so waiting for it
 * to upload makes sure that a thumbnail is displayed in the Media Library and
 * the Edit or on upload.
 *
 * @package dockpress
 * @see https://developer.wordpress.org/reference/hooks/wp_handle_upload/
 */

add_action(
	'wp_handle_upload',
	'dockpress_delay_upload_until_synced_with_cdn'
);

/**
 * Wait until an uploaded file can be reached
 *
 * Checks 5 times on a 5 second interval if $upload['url'] can be reached over
 * HTTP. If 20 seconds have passed, an error is logged if `WP_DEBUG` is enabled.
 *
 * As this is used for hooking into the `wp_handle_upload` filter without
 * modifying anything, it receives the $upload parameter and returns it without
 * modifying the values.
 *
 * @param array $upload the $upload array as coming from wp_handle_upload`.
 *
 * @return array The same as $upload, unchanged.
 *
 * @package dockpress
 */
function dockpress_delay_upload_until_synced_with_cdn( $upload ) {
	for ( $i = 0; $i < 5; $i++ ) {
		if ( $i < 0 ) {
			sleep( 5 );
		}
		$check_headers = get_headers( $upload['url'] );
		if ( str_contains( $check_headers[0], '200' ) ) {
			return $upload;
		}
	}
	if ( true === WP_DEBUG ) {
		error_log(
			"DockPress: CDN sync delay time expired for {$upload['url']}"
		);
	}
	return $upload;
}
