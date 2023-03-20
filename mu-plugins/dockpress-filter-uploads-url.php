<?php

if (defined('UPLOADS_URL')) {
    add_filter(
        'pre_option_upload_url_path',
        'dockpress_filter_uploads_url'
    );
}

function dockpress_filter_uploads_url() {
    return UPLOADS_URL;
}
