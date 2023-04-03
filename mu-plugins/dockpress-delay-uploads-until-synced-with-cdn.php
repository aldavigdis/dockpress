<?php

if (defined('WP_CONTENT_URL') || defined('UPLOADS_URL')) {
    add_action(
        'wp_handle_upload',
        'dockpress_delay_upload_until_synced_with_cdn'
    );
}

function dockpress_delay_upload_until_synced_with_cdn($file) {
    $i = 0;
    while($i < 5) {
        sleep(5);
        $check_headers = get_headers($file['url']);
        if (str_contains($check_headers[0], '200')) {
            return $file;
        }
    }
    return $file;
}
