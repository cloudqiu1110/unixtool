#!/bin/bash

# 某文件某函数的修改历史，也就是被那些人修改过; v 表示输出每次更改的比较 
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
allR=$( grep '^r' asd.tmp | cut -f 1 -d '|' | cut -c2- | sort )
rm asd.tmp

#$file=$AVATAR_HOME/$file
c=`pwd`
#$file=$c/$file

#echo $allR 
#exit;

for REV in $allR; do
    svn cat -r$REV $file | grep -n "function" | grep "$keyword\\([[:space:]]\\|(\\)"  > /tmp/funkeyword.log
    if [[ $? -eq 0 ]]; then
	author=`svn log -r$REV $file | grep "^r" | cut -d "|" -f2`
	time=`svn log -r$REV $file | grep "^r" | cut -d "|" -f3`
        comment=`svn log -r$REV $file | awk 'NR==4'`
	break;
    fi
done

#step 1
firstOccurenceRev=$REV
echo "第一次出现在-r$REV"

#step 2  获取之后的此fun被修改的rev
afterRevs=()
for rev in $allR  ; do
    if [[ $firstOccurenceRev -lt $rev ]]; then
        afterRevs=(${afterRevs[@]} $rev)	
    fi
done
#echo ${afterRevs[@]}

#step 3 变为了数组
preRev=$firstOccurenceRev
diffContent=
totalLines=
startLineNum=
endLineNum=
modRev=
for reversion in ${afterRevs[@]} ; do 
    #echo "diff $preRev $reversion"
    if [[ $preRev -eq $reversion ]]; then   # skip the first
        continue
    fi
    totalLines=$(svn cat -r$preRev $file | wc -l)
    startLineNum=$(svn cat -r$preRev $file | grep -n "function" | grep "$keyword\\([[:space:]]\\|(\\)" | cut -d":" -f1)
    nextFunStartLineNum=$(svn cat -r$preRev $file | grep -n "function" | grep -n2 "$keyword\\([[:space:]]\\|(\\)" | awk 'NR==4' | cut -d":" -f1 | cut -d"-" -f2)
    #echo "begins:" $startLineNum
    #echo "ends:" $nextFunStartLineNum
    endLineNum=$(($nextFunStartLineNum - 1))
    #echo "from: $startLineNum to: $endLineNum"
    svn diff -r$preRev:r$reversion $file  | grep "@@"  | cut -c5- > /tmp/prevNow.svnlog
    cat /tmp/prevNow.svnlog | while read difflog 
    do
	#echo $difflog
	#echo "base is" $base
        base=$(echo $difflog | cut -d"," -f1) # | cut -d"-" -f2-)
	if [[ ($(($base + 4)) -le $endLineNum) && ($(($base + 4)) -gt $startLineNum) ]]; then
            mauthor=`svn log -r$reversion $file | grep "^r" | cut -d "|" -f2`
	    mtime=`svn log -r$reversion $file | grep "^r" | cut -d "|" -f3`
	    mcomment=`svn log -r$reversion $file | awk 'NR==4'`
	    echo $reversion $mauthor "在" $mtime "修改了," $mcomment
	    if [[ "v" = "$3" ]]; then
		echo $reversion
		if [[ -z $modRev ]]; then
		    svn diff -r$modRev:r$reversion $file
		fi
            fi
	    modRev=$reversion
	    #echo "************$modRev"
	    break
	fi 
    done
    preRev=$reversion
done

# 如果某一个版本开始没有了， 就表示被移除了。
