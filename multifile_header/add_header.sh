#!/usr/bin/env bash


#default arguments
start_line=1 
add='sed -i -e "$start_line { r $header" -e "N; }" $file'

# go through the user options
for args in "$@"; do
    case "$1" in 
        -b | --backup) # user option, save a backup
        add='sed -i.bak -e "$start_line { r $header" -e "N; }" $file'
        shift
    esac
    case "$1" in
        -l | --line)
        shift
        start_line=$1
        shift
    esac
    case "$1" in
        -h | --help) # user option, help file
        echo "Usage: $( basename $0) [-options...] {header file file....} "
        echo 
        echo "options:"
        echo "  -h --help,      I don't need to explain, you're already here"
        echo "  -b --backup,    saves a backup before inserting the header"
        echo "  -l --line,      specify the line where the header is inserted"
        echo "  The -l option changes the structure of the call to $( basename $0) -l [-options] {line_number header file file....} "
        echo "  i.e. there needs to be a 'number' as additional input"
        echo
        echo "Adds the 'header' to each 'file' given on input before the first line"
        echo "If the header contains any unwanted empty lines, they will also be copied into each file, so, make sure your header looks nice."
        exit
    esac
done


if [ -z "$1" ]; then
    echo "please specify input. First file is the header, second file(s) are the files to insert at"
    exit
fi

header=$1
shift

for file in "$@"; do
    echo $file
    eval "$add"
done
