#!/bin/bash
a="$1"
method="$2"
b="$3"
[ $# -ne 3 ] && echo "位置参数的数量不对" && exit 1
[ -z "$a" -o -z "$method" -o -z "$b" ] && echo "没有给定位置参数" && exit 2
if [ "$1" -ge 0 -a "$3" -ge 0 ];then
	if echo "$method" |egrep -q '+|-|*|/';then
            echo "scale=6;$1 $2 $3" |bc
	fi
fi
