#!/bin/bash

for args in "$@"; do
    case "$1" in
        -h | --help) # user option, help file
        echo "Usage: $( basename $0) {file.bak file.bak file.bak ....} "
        echo 
        echo "Recover every passed backup file (file.bak) and overwrite the current 'file'"
        echo "The original file will be terminally deleted and overwritten by the .bak file!"
        echo "The script shows which files have been replaced"
        exit
    esac
done

for file in "$@"; do
    if [[ $file =~ .*\.bak$ ]]; then
        rename -v -f -e s/.bak// $file
    fi
done
