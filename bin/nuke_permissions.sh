#!/bin/bash

if [ "$FILE_OWNER" ]
then
    if [ ! "$FILE_GROUP" ]
    then
        FILE_GROUP=$FILE_OWNER
    fi
    chown -R "$FILE_OWNER:$FILE_GROUP" .
fi

if [ "$DIRECTORY_MODE" ]
then
    find . -type d -not -path "./.git/*" -not -path "./wp-content/uploads/*" -exec chmod "$DIRECTORY_MODE" {} \;
fi

if [ "$FILE_MODE" ]
then
    find . -type f -not -path "./.git/*" -not -path "./wp-content/uploads/*" -exec chmod "$FILE_MODE" {} \;
fi
