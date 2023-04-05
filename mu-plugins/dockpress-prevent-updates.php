<?php
/**
 * Prevents automatic updates for themes and plugins in order to ensure that the
 * WordPress installation is immutable as far as each node is concerned.
 *
 * In a DockPress setup, we would be using a static VM or a node that handles
 * the updating process via WP-CLI and may even act as the NFS file server for
 * the dockpress server nodes.
 *
 * This means that if we have multiple nodes, each with WordPress running their
 * own separate filesystem (as opposed to mounting from a central NFS server),
 * then there will be a divergence if automatic updating is enabled; and nobody
 * wants that.
 *
 * @package dockpress
 */

if ( defined( 'WP_AUTO_UPDATE_CORE' ) ) {
	add_filter( 'auto_update_plugin', '__return_false' );
	add_filter( 'auto_update_theme', '__return_false' );
}
