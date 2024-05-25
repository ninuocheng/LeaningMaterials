#!/bin/bash
#日志文件
WinningLogFile=/opt/raid0/lotusminer-winning/lotusminer/log*
for d in $@
do
        unset array array1
        #要查询的日期
        DateTime=`date  -d ''$d' day' '+%Y-%m-%d'`
        #要查询日期的前一天
        DayBefore=$[d-1]
        DateTimeBefore=`date  -d ''$DayBefore' day' '+%Y-%m-%d'`
        #要查询日期的前一天的最后一个抽奖时间
        LastBeforeField=$(grep -ar "$DateTimeBefore" $WinningLogFile |awk '/isEligible": true/{print $1}' |tail -n1)
        LastBeforeTime=${LastBeforeField#*:}
        #遍历抽奖的日期时间赋值到数组
        for f in $(grep -ar "$DateTime" $WinningLogFile |awk '/isEligible": true/{print $1}')
        do
                i=${f#*:}
                array+=($i)
        done
        array1=($LastBeforeTime ${array[*]})
        #初始化变量
        DValue=0
        DValueMaxSum=0
        DValueMinSum=0
        DValueSum=0
        n=0
        m=0
        s=0
        #检查是否有赋值到���组
        Length=${#array1[*]}
        First=$(date +%s -d "${array1[0]}")
        Last=$(date +%s -d "${array1[$Length-1]}")
        SumDValue=$(echo "$Last - $First" |bc)
        #遍历元素的索引值
        for j in `seq 2 ${#array1[*]}`
        do
                Before=$(date +%s -d "${array1[$j-2]}")
                After=$(date +%s -d "${array1[$j-1]}")
                DValue=$(echo "$After - $Before" |bc)
                if [ "$DValue" -lt 30 ];then
                        let n++
                        let DValueMinSum=$[DValueMinSum+DValue-30]
                        #echo "前1行日志时间: ${array1[$j-2]} 后1行日志时间: ${array1[$j-1]} 间隔秒数: ${DValue}s 超出秒数: $[DValue-30]s 超出的累计秒数: ${DValueSum}s"
                elif [ "$DValue" -gt 30 ];then
                        let m++
                        let DValueMaxSum=$[DValueMaxSum+DValue-30]
                        #echo "前1行日志时间: ${array1[$j-2]} 后1行日志时间: ${array1[$j-1]} 间隔秒数: ${DValue}s 超出秒���: $[DValue-30]s 超出的累计秒数: ${DValueSum}s"
                else
                        let s++
                        continue
                fi
        done
        declare -p array &>/dev/null && {
                echo "$DateTime的抽奖情况"
                echo "From ${array1[0]} To ${array1[$Length-1]}"
                echo "累计参与的抽奖数: $[n+m+s] 累计的秒数: $SumDValue 超出预期的抽奖数: $m 累计超出的秒数: ${DValueMaxSum}s 提前预期的抽奖数: $n 累计提前的秒数: ${DValueMinSum}s  预期的抽奖数: $s 相互抵消的累计秒数: $[DValueMinSum+DValueMaxSum]s"
                [ $[DValueMinSum+DValueMaxSum] -eq 0 ] && echo "相互抵消持平，正常" && continue
                [ $[DValueMinSum+DValueMaxSum] -gt 0 ] && echo "抽奖有异常，请检查!" && continue
        }
done
