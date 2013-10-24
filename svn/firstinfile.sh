#!/bin/bash

# 查询一个字符串第一次在某文件中出现的详情
#echo `pwd`

#file 相对与trunk的位置
file=$1
if [[ ! -f $file ]]; then
    echo "File not exists!"
    exit;
fi

keyword=$2
if [[ -z $keyword ]]; then
    echo "string should not be empty!"
    exit;
fi

allR=$(svn log $file > asd.tmp) 
allR=$( grep '^r' asd.tmp | cut -f 1 -d '|' | sort )
rm asd.tmp

#$file=$AVATAR_HOME/$file
c=`pwd`
#$file=$c/$file

echo 
for REV in $allR; do
    REV="-$REV"
    svn cat $REV $file | grep $keyword       #TODO 要严格匹配； 增加过滤步骤
    if [[ $? -eq 0 ]]; then
	author=`svn log $REV $file | grep "^r" | cut -d "|" -f2`
	time=`svn log $REV $file | grep "^r" | cut -d "|" -f3`
        comment=`svn log $REV $file | awk 'NR==4'`
        echo "第一次出现在 $REV  作者：$author  时间: $time  comment: $comment"
	exit;
    fi
done
