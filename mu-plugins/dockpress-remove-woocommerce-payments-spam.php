<?php
/**
 * Get rid of the WooCommerce Payment upsell menu page
 *
 * WooCommerce abuses the WP admin menu to upsell their Stripe and PayPal
 * integration plugins. As this looks alarming and confuses most users, this
 * should be removed.
 *
 * @package dockpress
 * @see https://github.com/aldavigdis/remove-woocommerce-payment-spam
 */

add_action(
	'admin_menu',
	'remove_woocommerce_payments_menu_page',
	PHP_INT_MAX
);

/**
 * Remove WooCommerce Payments menu page
 */
function remove_woocommerce_payments_menu_page(): void {
	remove_menu_page(
		'admin.php?page=wc-settings&tab=checkout&from=PAYMENTS_MENU_ITEM'
	);
}
