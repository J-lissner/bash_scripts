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
        echo "It also pads any assignment, i.e. 'my_var=5' will become 'my_var = 5'"
        echo "Every 'block' is marked by empty lines, or keywords like 'for', 'if', 'while', 'def' or indentation"
        echo "For every line it has to indent, the file is overwritte, so the script might be slow for many lines"
        echo "Skips identation for python like function calls containing '=' symbols, e.g. fun.call(arg=10) "
        echo "saves a backup for every file as file.bak, overwrites existing backups"
        echo 
        echo "Current version works fine for almost all python and matlab scripts (11.11.19)"
        echo "Note that the version is still not perfect, it skips over '+=' instead of moving both"
        echo "Also note that kwargs passed with spaces e.g. 'kwarg =5' will also be padded to 'kwarg = 5'"
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
keywords='         /^\s*for[^a-zA-Z]/ ||  /^\s*if[^a-zA-Z]/ ||  /^\s*while[^a-zA-Z]/ ||  /^\s*def[^a-zA-Z]/ ||  /^\s*#/ ||  /^\s*\%/ ||  /^\s*with/ ||  /^\s*try/ ||  /^\s*except/'
negated_keywords='!/^\s*for[^a-zA-Z]/ && !/^\s*if[^a-zA-Z]/ && !/^\s*while[^a-zA-Z]/ && !/^\s*def[^a-zA-Z]/ && !/^\s*#/ && !/^\s*\%/ && !/^\s*with/ && !/^\s*try/ && !/^\s*except/'

## indentation level
current_line='sed -n "$i s/\(\s*\).*/\1/p" $file'
base_line='sed -n "$i s/\(\s*\).*/\1/p" $file'

## padding with zeros
find_column='sed -n "$i s/./&\\n/gp" $file | grep -nx -m 1  "=" | cut -d: -f1'
pad_spaces='sed -i -e "$i s/=/$spaces=/" $file'
correction='sed -i -e "s/\([+<=>*/-]\) \+=/\1=/g" $file'
pad='awk "BEGIN{\$$n_spaces=OFS=\" \";print}" '

## skip python like function calls
function_call='awk "NR==$i && /^[^=]*\(.*=/ { print NR; exit}" $file'

## skip "assigment incrementation" etc (e.g +=)
increment='awk "{ if( (NR==$i) && (/\+=/ || $incr_keywords) ) { print NR; exit} }" $file'
incr_keywords=' /\*=/ || /-=/ || /\/=/ '


#preallocating
for file in $@; do
    echo "Manipulating file: '$file'"
    #reset all padded = symbols, then fix the condition statements +=, ==, !=, <=, etc.
    sed -i -e 's/\s\+=\s*/ = /g ;s/\s*=\s\+/ = /g' $file
    #sed -i -e 's/\(\<if\>.*[=!]\)\s*=/\1=/g' $file
    #sed -i -e 's/\(\<while\>.*[=!]\)\s*=/\1=/g' $file
    sed -i -e 's/\([+-/*<>!=]\)\s\+=/\1=/g' $file
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

                skip_fun=$( eval $function_call)
                skip_incr=$( eval $increment)
                if [[ ! -z "$skip_fun" ]] ; then
                    skip_array+=($skip_fun)
                    continue
                fi
                if [[ ! -z "$skip_incr" ]] ; then
                    if [[ ! -z "$skip_fun" ]] && (( "$skip_incr" != "$skip_fun" )); then
                        continue
                    fi 
                    skip_array+=($skip_incr)
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
            echo "detected block: lines $line1 - $line2"
        elif (( "$line1" == "$line2" )); then
            continue
        else
            break
        fi 
    done
    eval $correction 
done
