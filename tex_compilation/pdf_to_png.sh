#!/usr/bin/env bash



if [ -z "$1" ]; then
    for file in *pdf; do
        fname=${file/.pdf/}
        convert -density 300 $file -quality 90 "$fname.png"
    done
elif [ -z "$2" ]; then 
    fname=${1/.pdf/}
    convert -density 300 $1 -quality 90 "$fname.png"
else
    convert -density 300 $1 -quality 90 $2
fi


