<?php

if (defined(DOCKPRESS_CDN_SCOPE) && (false == is_user_logged_in())) {
    switch (DOCKPRESS_CDN_SCOPE) {
    case 'uploads':
        if ( defined(DOCKPRESS_CDN_UPLOADS_URL) ) {
            apply_filters(
                'upload_dir',
                ['baseurl' => DOCKPRESS_CDN_UPLOADS_URL]
            );
        }
        break;
    case 'content':
        if ( defined(DOCKPRESS_CDN_CONTENT_URL) ) {
            apply_filters('content_url', DOCKPRESS_CDN_CONTENT_URL);
        }
        break;
    }
}
