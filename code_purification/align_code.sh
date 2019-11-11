#!/bin/bash

backup=true

# go through the user options
for args in "$@"; do
    case "$1" in 
        -nb | --nobackup) # user option, save a backup
        backup=false
        shift
    esac
    case "$1" in
        -h | --help) # user option, help file
        echo "Usage: $( basename $0) [option...] {file file file ...} "
        echo 
        echo "options:"
        echo "  -nb --nobackup, don't save any backup"
        echo "  -h  --help,     no need to explain, you're already here"
        echo
        echo "This script aligns every '=' sign of a 'block' to the same identation level by padding spaces"
        echo "Every 'block' is marked by empty lines, or keywords like 'for', 'if', 'while', 'def' or indentation"
        echo "For every line it has to indent, the file is overwritte, so the script might be slow for many lines"
        echo "Skips identation for python like function calls containing '=' symbols, e.g. fun.call(arg=10) "
        echo "saves a backup for every file as file.bak, overwrites existing backups"
        echo 
        echo "Current version works fine for python and matlab scripts (11.11.19)"
        echo "NOTE, there will be another script released soon, which pads '=' symbols correclty"
        exit
    esac
done
if [ -z "$1" ]; then
    echo "please specify file input"
    exit
fi

if $backup; then
    for file in $@; do
        backup_name="$file.bak"
        cp $file $backup_name
    done
fi
    

## commands which should be evaluated during the loops
block_start='awk "NR>$line2 && /=/ && $negated_keywords { print NR; exit}" $file'
block_end='awk "{ if( (NR>$line1) && (!/=/ || $keywords) ) { print NR; exit} }" $file'
keywords='/^\s*for/ || /^\s*if/ || /^\s*while/ || /^\s*def/ '
negated_keywords='!/^\s*for/ && !/^\s*if/ && !/^\s*while/ && !/^\s*def/ '

## indentation level
current_line='sed -n "$i s/\(\s*\).*/\1/p" $file'
base_line='sed -n "$i s/\(\s*\).*/\1/p" $file'

## padding with zeros
find_column='sed -n "$i s/./&\\n/gp" $file | grep -nx -m 1  "=" | cut -d: -f1'
pad_spaces='sed -i -e "$i s/=/$spaces=/" $file'
pad='awk "BEGIN{\$$n_spaces=OFS=\" \";print}" '

## skip python lines
function_call='awk "NR==$i && /.*\(.*=/ && !/.*=.*\(/ { print NR; exit}" $file'


#preallocating
for file in $@; do
    line2=$(( 0 ))
    while true; do
        line1=$( eval $block_start  )
        if [ -z "$line1" ]; then  #breaks if there are any blank lines at the end of file
            break
        fi
        line2=$( eval $block_end  )
        line2=$(( line2 -1)) 

        if (( "$line1" < "$line2" )); then 
            skip_array=()
            ## check which '=' is the most indented

            max_column=$(( 0 )) #might not be needed
            ## current indentation level
            indentation=$( eval $base_line)
            base_level=${#indentation}
            for ((i=line1;i<=line2;i++)); do
                indentation=$( eval $current_line)
                level=${#indentation}
                if (( "$level" != "$base_level")); then
                    line2=$(( i-1 ))
                    break
                fi

                skip=$( eval $function_call)
                if [[ ! -z "$skip" ]] ; then
                    skip_array+=($skip)
                    continue
                fi
                column=$( eval $find_column )
                if (("$column" > "$max_column")); then
                    max_column=$column
                fi
            done
            # pad ever unindented '=' by enough spaces to match the last one
            j=0
            for ((i=line1;i<=line2;i++)); do
                if [[ ! -z "${skip_array[j]}" ]] && (( "$i" == "${skip_array[j]}" )); then
                    j=$(( j+1 ))
                    continue
                fi
                column=$( eval $find_column )
                n_spaces=$(( max_column - column ))
                spaces=$( eval $pad  )
                if (( "$column" < "$max_column" )); then
                    eval $pad_spaces
                fi
            done
        elif (( "$line1" == "$line2" )); then
            continue
        else
            break
        fi 
    done
done
