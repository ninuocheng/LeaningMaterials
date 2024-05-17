#!/bin/bash
#下班的日期时间
AfterWorkDate=$(date +%Y%m%d)
AfterWorkH=18
AfterWorkM=50
AfterWorkS=01
#时间戳
AfterWorkTimeStamp=$(date +%s -d "$AfterWorkDate $AfterWorkH:$AfterWorkM:$AfterWorkS")
#当前的时间戳
CurrentTimeStamp=$(date +%s -d "`date +%Y%m%d\ %H:%M:%S`")
#距离下班的时间戳差值
DValue=$[AfterWorkTimeStamp - CurrentTimeStamp]
if [ $AfterWorkTimeStamp -lt $CurrentTimeStamp ];then
   DValue=$[CurrentTimeStamp - AfterWorkTimeStamp]
   if [ $DValue -ge 3600 ];then
        DistanceH=$[DValue/3600] && DistanceS=$[DValue%3600]
	[ $DistanceS -ge 60 ] && DistanceM=$[DistanceS/60] && DistanceS=$[DistanceS%60]
   fi
   if [ $DValue -ge 60 -a $DValue -lt 3600 ];then
	DistanceM=$[DValue/60] && DistanceS=$[DValue%60]
   fi
   echo "实际下班的时间:$AfterWorkH:$AfterWorkM:$AfterWorkS"
   echo "下班了$DistanceTime"
else
   if [ $DValue -ge 3600 ];then
      DistanceH=$[DValue/3600] && DistanceS=$[DValue%3600]
      [ $DistanceS -ge 60 ] && DistanceM=$[DistanceS/60] && DistanceS=$[DistanceS%60]
   fi
   if [ $DValue -ge 60 -a $DValue -lt 3600 ];then
        DistanceM=$[DValue/60] && DistanceS=$[DValue%60]
   fi
fi
h=${DistanceH:-0}
m=${DistanceM:-0}
s=${DistanceS:-0}
#清屏
clear
#嵌套循环
for ((h1=$h;h1>=0;h1--))
do
     [ $h1 -ge 0 -a $h1 -lt 10 ] && h2=0$h1 || h2=$h1
     m1=${m:-59} && unset m
     for ((m2=$m1;m2>=0;m2--))
     do
          [ $m2 -ge 0 -a $m2 -lt 10 ] && m3=0$m2 || m3=$m2
          s1=${s:-59} && unset s
          for ((s2=$s1;s2>=0;s2--))
          do 
              [ $s2 -ge 0 -a $s2 -lt 10 ] && s3=0$s2 || s3=$s2
              #隐藏光标输出
              echo -e "\033[?25l距离下班倒计时:"
              echo -ne "                                                                                  \033[?25l$h2时$m3分$s3秒"
              sleep 1
              clear
          done
     done
done
#显示光标
echo -e "\033[?25h"
