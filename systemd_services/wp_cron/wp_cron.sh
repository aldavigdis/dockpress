#!/bin/bash

wp_root="/mnt/wp_root/"

while true
do
    wp cron event run --due-now --path="$wp_root"
    sleep 10
done
