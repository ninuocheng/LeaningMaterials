#!/bin/bash
#下班的时分秒
AfterWorkH=18
AfterWorkM=45
AfterWorkS=50
#当前的时分秒
CurrentH=$(date +%H)
CurrentM=$(date +%M)
CurrentS=$(date +%S)
#去掉开头的0
CurrentH=`echo "$CurrentH" |sed 's#^0##g'`
CurrentM=`echo "$CurrentM" |sed 's#^0##g'`
CurrentS=`echo "$CurrentS" |sed 's#^0##g'`
#距离下班的时间
DistanceH=$[AfterWorkH - CurrentH]
DistanceM=$[AfterWorkM - CurrentM]
DistanceS=$[AfterWorkS - CurrentS]
if [ $AfterWorkH -lt $CurrentH ];then
	DistanceH=$[CurrentH - AfterWorkH]
	if [ $AfterWorkM -le $CurrentM ];then
		DistanceM=$[CurrentM - AfterWorkM]
	else
		DistanceH=$[DistanceH - 1]
		DistanceM=$[CurrentM + 60 - AfterWorkM]
		[ $DistanceM -ge 60 ] && DistanceH=$[$[DistanceM/60] + $DistanceH] && DistanceM=$[DistanceM%60]
	fi
	if [ $AfterWorkS -le $CurrentS ];then
		DistanceS=$[CurrentS - AfterWorkS]
	else
		DistanceM=$[DistanceM -1]
		DistanceS=$[CurrentS + 60 - AfterWorkS]
		[ $DistanceS -ge 60 ] && DistanceM=$[$[DistanceS/60] + $DistanceSM] && DistanceS=$[DistanceS%60]
	fi
	echo "实际下班的时间: $AfterWorkH:$AfterWorkM:$AfterWorkS"
	echo "下班了$DistanceH时$DistanceM分$DistanceS秒"
	exit 1
elif [ $AfterWorkH -eq $CurrentH ];then
	if [ $AfterWorkM -lt $CurrentM ];then
		DistanceM=$[CurrentM - AfterWorkM]
		if [ $AfterWorkS -le $CurrentS ];then
			DistanceS=$[CurrentS - AfterWorkS]
		else
			DistanceM=$[DistanceM - 1]
                        DistanceS=$[CurrentS + 60 - AfterWorkS]
		        [ $DistanceS -ge 60 ] && DistanceM=$[$[DistanceS/60] + $DistanceSM] && DistanceS=$[DistanceS%60]
		fi
	        echo "实际下班的时间: $AfterWorkH:$AfterWorkM:$AfterWorkS"
	        echo "下班了$DistanceH时$DistanceM分$DistanceS秒"
		exit 2
	elif [ $AfterWorkM -eq $CurrentM ];then
		if [ $AfterWorkS -le $CurrentS ];then
			DistanceS=$[CurrentS - AfterWorkS]
	                echo "实际下班的时间: $AfterWorkH:$AfterWorkM:$AfterWorkS"
	                echo "下班了$DistanceH时$DistanceM分$DistanceS秒"
			exit 3
		fi
	else
		if [ $AfterWorkS -le $CurrentS ];then
			DistanceS=$[CurrentS - AfterWorkS]
		else
			DistanceM=$[DistanceM - 1]
                        DistanceS=$[CurrentS + 60 - AfterWorkS]
		        [ $DistanceS -ge 60 ] && DistanceM=$[$[DistanceS/60] + $DistanceSM] && DistanceS=$[DistanceS%60]
		fi
	fi
else
	if [ $AfterWorkM -lt $CurrentM ];then
		DistanceH=$[DistanceH - 1]
		DistanceM=$[AfterWorkM + 60 - CurrentM]
	fi
	if [ $AfterWorkS -lt $CurrentS ];then
		DistanceM=$[DistanceM - 1]
		DistanceS=$[AfterWorkS + 60 - CurrentS]
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
