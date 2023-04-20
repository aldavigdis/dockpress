#!/bin/bash

wp_content_path="/mnt/wp_root/wp-content"
bucket="gs://dockpress-wp-content"
filetypes='^(?!.*\.(jpg|png|webp|svg|webm|pdf|mp4|mov|eot|ttf|woff|woff2|css|js|json)$).*'

gsutil -m rsync -r -x "$filetypes" "$wp_content_path" "$bucket"

while inotifywait -r -e modify,create,delete,move "$wp_content_path"
do
    gsutil -m rsync -r -x "$filetypes" "$wp_content_path" "$bucket"
done
