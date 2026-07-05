=== Memcached Redux ===
Contributors: wonderboymusic, ryan, sivel, mikeschroder, Ipstenu, batmoo
Tags: cache, Memcached, admin, manage cache, object cache, WP Object Cache
Requires at least: 3.0
Tested up to: 5.4.1
Stable Tag: 0.1.7

Uses the Memcached class (not the Memcache class) to implement WP Object Cache

== Description ==

Changes the famous Memcached WP Object Cache backend to actually use the Memcached class (not the Memcache class). Implements wp_cache_get_multi() and wp_cache_set_multi()

<code>
wp_cache_get_multi( array(
	array( 'key', 'group' ),
	array( 'key', '' ),
	array( 'key', 'group' ),
	'key'
) );

wp_cache_set_multi( array(
	array( 'key', 'data', 'group' ),
	array( 'key', 'data' )
) );
</code>

Blog Post: [http://scotty-t.com/2012/06/05/memcached-redux/](http://scotty-t.com/2012/06/05/memcached-redux/)

== Installation ==
1. Install [memcached](http://danga.com/memcached) on at least one server. Note the connection info. The default is `127.0.0.1:11211`.

1. Install the [PECL memcached extension](http://pecl.php.net/package/memcached) 

1. Copy object-cache.php to wp-content

== Changelog ==

= 0.1.7 =
* Improved escaping in debug output ported from [Memcached plugin](https://wordpress.org/plugins/memcached/) (props @batmoo).
* Fixed PHP notice when no Memcached server:port manually specified.

= 0.1.6 =
* Corrected documentation
* Corrected stats collection (props @johnbillion)

= 0.1.5 =
* Added support for PHP 7+ by changing to `__construct` and pre-initializing stats

= 0.1.3 =
* Added support for WP_CACHE_KEY_SALT allowing multiple sites to use the same Memcached server.

= 0.1.2 =
* Allows graceful fallback to database object cache in WordPress 3.7+ for users without PECL Memcached available.
* Fixes warning due to replace() call, as it does not take a compression argument in Memcached.

= 0.1.1 = 
* Fixes a problem with the get_option() function and the return value of wp_cache_get() on Linux

= 0.1 =
* Initial release

== Upgrade Notice ==
