#!/usr/bin/env bash


del='sed -i.bak -e "$d1,$d2 d" $file' #default argument with backup
#d1 and d2 are defined in the loop below, they refer to the start and end line of the header
del_start='awk " /^######/{ print NR; exit}" $file'
del_end='awk "NR>$d1 && /^######/{ print NR; exit}" $file'


if [ -z "$1" ]; then
    echo "please specify input. First file is the header, second file(s) are the files to insert at"
    exit
fi

# go through the user options
for args in "$@"; do
    case "$1" in 
        -nb | --nobackup) # user option, save a backup
        del='sed -i -e "$d1,$d2 d" $file'
        shift
    esac
    case "$1" in
        -m | --modulo) # user option, modulo as comment style
        del_start='awk " /^\%\%\%\%\%\%/{ print NR; exit}" $file'
        del_end='awk "NR>$d1 && /^\%\%\%\%\%\%/{ print NR; exit}" $file'
        shift
    esac
    case "$1" in
        -h | --help) # user option, help file
        echo "Usage: $( basename $0) [option...] {header file file....} "
        echo 
        echo "options:"
        echo "  -nb --nobackup, don't save any backup"
        echo "  -m --modulo,    comment style of the replaced header is modulo (%), default # "
        echo "  -h --help,      I don't need to explain, you're already here"
        echo "this script does not allow to combine multiple options!"
        echo "e.g. -mnb is invalid, it requires -m -nb"
        echo
        echo "The existing 'header' is removed and replaced with the new 'header' argument in every 'file'"
        echo "The script remembers the starting line of the previous header and does not touch any preamble"
        echo "Elaboration:"
        echo "  the existing header which will be removed is marked by 6 characters of your specified comment style"
        echo "  the header which will be removed is required to have said 6 characters at the start and end of it, respectively"
        echo
        echo "automatically saves a backup before removing previously existing headers as file*.bak"
        exit
    esac
done

header=$1
shift #removes the header out of the passed variables 

# delete the old header and then insert the new one
for file in "$@"; do
    echo $file
    d1=$( (eval "$del_start") )
    d2=$( (eval "$del_end") )
    eval "$del"
    sed -i -e "$d1 { r $header" -e "N; }" $file
done
