#!/usr/bin/env bash

case "$1" in 
    -h | --help) # user option, save a backup
    echo "Usage: $( basename $0) [option...] "
    echo 
    echo "options:"
    echo "  -h --help,      I don't need to explain, you're already here"
    echo "  -l --list,      lists all the file endings which get deleted"
    echo
    echo "removes alot of files which spam the folder after compilation of tex files"
    echo "basically every possible file which can occur on some way of compilation (10.2019)"
    exit
esac
case "$1" in 
    -l | --list) # user option, save a backup
    echo "List of the file endings which will be deleted, unsorted"
    echo "nav, out, toc, snm, aux, idx, log, dvi, ps, bbl, blg, lot, lof, vrb"
    exit
esac

rm -f *.nav
rm -f *.out
rm -f *.toc
rm -f *.snm
rm -f *.aux
rm -f *.idx
rm -f *.log
rm -f *.dvi
rm -f *.ps
rm -f *.bbl
rm -f *.blg
rm -f *.lot
rm -f *.lof
rm -f *.vrb
