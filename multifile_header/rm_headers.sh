#!/bin/bash
#THIS SCRIPT WILL REMOVE N HEADERS IF THERE ACCIDENTIALL ARE TOO MANY
#d1 and d2 are defined in the loop below, they refer to the start and end line of the header
del_start='awk " /^######/{ print NR; exit}" $file'
del_end='awk "NR>$d1 && /^######/{ print NR; exit}" $file'
backup='sed -i.bak -e "$d1,$d2 d" $file' #default argument with backup
del='sed -i -e "$d1,$d2 d" $file' #default argument with backup


if [ -z "$1" ]; then
    echo "please specify input. First file is the header, second file(s) are the files to insert at"
    exit
fi

# go through the user options
for args in "$@"; do
    case "$1" in 
        -nb | --nobackup) # user option, save a backup
        backup=$del
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
        echo "Usage: $( basename $0) [option...] {number_of_headers file file....} "
        echo 
        echo "options:"
        echo "  -nb --nobackup, don't save any backup"
        echo "  -m --modulo,    comment style is modulo (%), default # "
        echo "  -h --help,      I don't need to explain, you're already here"
        echo "this script does not allow to combine multiple options!"
        echo "e.g. -mnb is invalid, it requires -m -nb"
        echo
        echo "'number_of_headers' headers will be removed in 'file'. The headers are markes by 6 characters of the comment style"
        echo "Other lines before, between or after each header are detected and will not be deleted"
        echo "Elaboration:"
        echo "  Each header has to be marked by starting AND ending with 6 characters of 'commentstyle' in different lines"
        echo "  e.g. ###### \n ....\n ######, and then 'n_headers' header follow of the same structure"
        echo
        echo "automatically saves a backup before removing previously existing headers as file*.bak"
        echo
        echo "ATTENTION: when there are 'chained headers' (not full headers for each 'header') like"
        echo " ######"
        echo " header text"
        echo " ######"
        echo " header text"
        echo " ######"
        echo " header text"
        echo " ######"
        echo 
        echo "Will most likely yield unexpected behavior, too much of the file could accidentially be deleted"
        exit
    esac
done

n=$1
shift #removes the variable n out of the passed variables 

# delete the old header and then insert the new one
for file in "$@"; do
    for ((i=1;i<=n;i++)); do
        d1=$( (eval "$del_start") )
        d2=$( (eval "$del_end") )
        if [ $i == 1 ]; then
            eval "$backup"
        else
            eval "$del"
        fi
    done
done
