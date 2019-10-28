#!/bin/bash

#default parameters
backup=true

if [ -z "$1" ]; then
    echo "please specify file input"
    exit
fi
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
        echo
        echo "This script aligns every '=' sign of a 'block' to the same identation level by padding spaces"
        echo "Every 'block' is marked by empty lines, or keywords like 'for', 'if', 'while', 'def'"
        echo "For every line it has to indent, the file is overwritte, so the script might be slow for many lines"
        echo 
        echo "NOTE, this is not the final version, unexpected behaviour on unindentation of statements without a blank line"
        echo "NOTE, also unexpected behaviour on e.g. python function calls containing= without any variable assignment"
        echo "This will be fixed in future releases (currently 28.10.19, first version)"
        echo "NOTE, there will be another script released soon, which pads '=' symbols correclty"
        exit
    esac
done
##commands which should be evaluated during the loops

# checking the size of the block and where the farthest '=' is located
block_start='awk " NR>$line2 && /=/ && $negated_keywords {print NR; exit} " $file'
block_end='awk "{ if( NR>$line1 && (!/=/ || $keyword_matches ) )  {print NR; exit} } " $file'
find_column='sed -n "$i s/./&\\n/gp" $file | grep -nx -m 1  "=" | cut -d: -f1'

# evaluating how many spaces it needs to pad
save_backup='sed -i.bak -e "$i s/=/$spaces=/" $file'
pad_spaces='sed -i -e "$i s/=/$spaces=/" $file'
pad='awk "BEGIN{\$$n_spaces=OFS=\" \";print}" '

# conditions for the block to respect keywords so they dont mess up the identation
keyword_matches="/^\s*for/  || /^\s*while/  || /^\s*if/ || /^\s*def/ || /^\s*class/"
negated_keywords="!/^\s*for/  && !/^\s*while/  && !/^\s*if/ && !/^\s*def/ && !/^\s*class/"

# conditions on the identation level for the block to not mess up the design
#identation_level='awk "NR==$line1 { match(\$0, /^ */); print RLENGTH }" $file ' #THIS ONE WORKS
#unindent='awk "{if( NR>$line1 && $tmpvar!={match(\$0, /^ */);RLENGTH} ) {print NR; exit} }" $file '

#TODO TODO TODO
# ANOTHER SCRIPT WHICH PADS THE = SIGNS (only those which need padding (dont pad on keyword or bracket before '=') )
# TERMINATE BLOCK UPON UNINDENTATION


#preallocating
line2=$(( 0 ))

for file in $@; do
    while true; do
        line1=$( eval $block_start  )
        line2=$( eval $block_end  )
        line2=$(( line2 -1)) 

        if (( "$line1" < "$line2" )); then 
            #check which '=' is the most indented
            max_column=$(( 0 )) #might not be needed
            for ((i=line1;i<=line2;i++)); do
                column=$( eval $find_column )
                if (("$column" > "$max_column")); then
                    max_column=$column
                fi
            done
            # pad ever unindented '=' by enough spaces to match the last one
            for ((i=line1;i<=line2;i++)); do
                column=$( eval $find_column )
                n_spaces=$(( max_column - column ))
                spaces=$( eval $pad  )
                if (( "$column" < "$max_column" )); then
                    if $backup; then
                        backup=false
                        eval $save_backup
                    else
                        eval $pad_spaces
                    fi
                fi
            done
        else 
            break
        fi 
    done
    line2=$( (eval "awk 'END{print NR}' $file" ) )
    for ((i=line1;i<=line2;i++)); do
        column=$( (eval $find_column) )
        if (("$column" > "$max_column")); then
            max_column=$column
        fi
    done
    for ((i=line1;i<=line2;i++)); do
        column=$( (eval $find_column) )
        for ((j=column;j<max_column;j++)); do
            eval $pad_spaces
        done
    done
    #cat -n $file #TODO THE ONES DOWN HERE JUST TO DEBUG #
done
#cp backup/my_file.py .
