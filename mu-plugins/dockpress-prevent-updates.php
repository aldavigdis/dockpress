<?php

# Prevent automatic updates for themes and plugins in order to ensure that the
# site is immutable
add_filter( 'auto_update_plugin', '__return_false' );
add_filter( 'auto_update_theme', '__return_false' );
