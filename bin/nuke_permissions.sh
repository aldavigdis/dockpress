#!/bin/bash

chown -R $FILE_OWNER .
find . -type f -not -path "./.git/*" -not -path "./wp-content/uploads/*" -exec chmod $DIRECTORY_MODE {} \;
find . -type f -not -path "./.git/*" -not -path "./wp-content/uploads/*" -exec chmod $FILE_MODE {} \;
