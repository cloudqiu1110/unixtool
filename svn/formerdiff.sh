#!/bin/bash

# 不断和前一次diff 
#echo `pwd`

#file 相对与trunk的位置
file=$1
if [[ ! -f $file ]]; then
    echo "File not exists!"
    exit;
fi

allR=$(svn log $file > asd.tmp) 
allR=$( grep '^r' asd.tmp | cut -f 1 -d '|' | cut -d"r" -f2 | sort -r)
rm asd.tmp

echo $allR

cmd1=
n=0
RS=($allR)
for REV in $allR ; do
    now="r${RS[$n]}"
    former="-r${RS[$n+1]}"
    echo $former
    svn diff $former:$now $file
    echo "please input n if you want to diff continue[n]"
    read cmd1
    if [ "n" = "$cmd1" ]; then
        n=$n+1
    else
	echo "in else"
        #break
    fi   
done
