#!/bin/bash

#export functions info

file=$1
if [[ ! -f $file ]]; then
    echo "File does not exist!\n"
    exit;
fi

cat $file | grep "function"  | grep -e "private" -e "public" | cut -d"o" -f2- | cut -c3- | cut -d"(" -f1 
