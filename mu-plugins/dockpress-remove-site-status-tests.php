<?php
/**
 * Prevent the WordPress Health Check feature from flagging things that are
 * considered to be normal in a DockPress setup.
 *
 * Those are:
 *
 * * Automatic updates for themes and plugins
 * * Background updates for the WordPress core
 * * Page cache
 *
 * @see https://developer.wordpress.org/reference/classes/wp_site_health/get_tests/
 * @see https://developer.wordpress.org/reference/hooks/site_status_tests/
 *
 * @package dockpress
 */

add_filter(
	'site_status_tests',
	'dockpress_remove_site_status_tests'
);

/**
 * Filter WordPress health check
 *
 * Filters the WordPress Health Check feature skip warning the user about things
 * that are considered normal in a DockPress setup.
 *
 * @param array $tests The tests array as coming from the site_status_tests filter.
 */
function dockpress_remove_site_status_tests( array $tests ) {
	unset( $tests['direct']['plugin_theme_auto_updates'] );
	unset( $tests['async']['background_updates'] );
	unset( $tests['async']['page_cache'] );
	return $tests;
}
