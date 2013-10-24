#! /bin/bash

# set the unix system time for testing

now=`date +%Y%m%d%H:%M:%S`
echo "现在的日期是" $now 
echo "系统时间修改到" $1

# 断言 $1 的 正确性


# 设置测试用的系统时间
date -s $1

confirm=
read -p "Input [y] to go back normal:"  confirm

#reset the time
date -s $now
exitTime=`date +%Y%m%d`
echo "脚本退出的时候系统时间:" $exitTime
