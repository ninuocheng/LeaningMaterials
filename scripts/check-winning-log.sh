#!/bin/bash
#主目录
RootDir=$(dirname $(readlink -f $0))
#日志文件
WinningLogFile=/opt/raid0/lotusminer-winning/lotusminer/log*
#遍历查询的日期，0是当天的日期，-1是前一天的日期，以此类推
for d in $@
do
        #初始化数组
        unset array array1
        #要查询的日期
        DateTime=`date  -d ''$d' day' '+%Y-%m-%d'`
        #要查询日期的前一天
        DayBefore=$[d-1]
        DateTimeBefore=`date  -d ''$DayBefore' day' '+%Y-%m-%d'`
        #抽奖记录日志
        LotteryRecordLog="$RootDir/lottery-record-log-$DateTime"
        MinerPower="$RootDir/minerpower-$DateTime"
        WinningLog="$RootDir/winning-log-$DateTime"
        #要查询日期的前一天的最后一个抽奖记录
        grep -ar "$DateTimeBefore" $WinningLogFile |awk '/isEligible": true/{print}' |tail -n1 > $LotteryRecordLog
        #查询的抽奖记录
        grep -ar "$DateTime" $WinningLogFile |awk '/isEligible": true/{print}' >> $LotteryRecordLog
        awk -F'[,]' '{print $1,$10}' $LotteryRecordLog |awk '{print $1,$NF}' |sed 's#"##g' > $MinerPower
        #遍历抽奖的日期时间赋值到数组
        while read DateTimeFiled MinerPowerField
        do
                i=${DateTimeFiled#*:}
                array+=($i) #赋值到数组
                array1+=($MinerPowerField)
        done < $MinerPower
        #初始化变量
        DValue=0
        DValueMaxSum=0
        DValueMinSum=0
        TotalTime=0
        DValueSum=0
        n=0
        m=0
        s=0
        #数组元素的数量
        Length=${#array[*]}
	[ $Length -le 1 ] && continue
        #数组的第一个元素转换时间戳
        First=$(date +%s -d "${array[0]}")
        #数组的最后一个元素转换时间戳
        Last=$(date +%s -d "${array[$Length-1]}")
        #差值
        SumDValue=$(echo "$Last - $First" |bc)
        >$WinningLog
        #遍历元素的索引值
        for j in `seq 2 $Length`
        do
                Before=$(date +%s -d "${array[$j-2]}")
                After=$(date +%s -d "${array[$j-1]}")
                DValue=$(echo "$After - $Before" |bc)
                #let TotalTime+=DValue
                #let DValueSum=$[DValueSum+DValue-30]
                echo "${array[$j-2]} ${array[$j-1]} $DValue $[DValue-30]s ${array1[$j-1]}" >> $WinningLog
                if [ "$DValue" -lt 30 ];then
                        let n++
                        let DValueMinSum=$[DValueMinSum+DValue-30]
                        #echo "前1行日志时间: ${array[$j-2]} 后1行日志时间: ${array[$j-1]} 间隔秒数: ${DValue}s 提前预期秒数: $[DValue-30]s 提前预期的累计秒数: ${DValueMinSum}s 参与抽奖的有效算力: ${array1[$j-1]}"
                elif [ "$DValue" -gt 30 ];then
                        let m++
                        let DValueMaxSum=$[DValueMaxSum+DValue-30]
                        #echo "前1行日志时间: ${array[$j-2]} 后1行日志时间: ${array[$j-1]} 间隔秒数: ${DValue}s 超出预期秒数: $[DValue-30]s 超出预期的累计秒数: ${DValueMaxSum}s 参与抽奖的有效算力: ${array1[$j-1]}"
                else
                        let s++
                        continue
                fi
        done
        declare -p array &>/dev/null && {
                echo "$DateTime的抽奖情况"
                echo "From ${array[0]} To ${array[$Length-1]}"
                awk 'BEGIN{print "间隔的秒数","预期了的秒数","参与抽奖的有效算力","预期了的累计秒数"}{Dvalue[$3" "$4" "$5]+=$4}END{for(i in Dvalue)print i,Dvalue[i]"s"}' $WinningLog |sort -nk3 |column -t
                #echo "累计的秒数: $TotalTime 相互抵消的累计秒数: $DValueSum"
                echo "累计参与的抽奖数: $[n+m+s] 累计的秒数: ${SumDValue}s 超出预期的抽奖数: $m ���出的累计秒数: ${DValueMaxSum}s 提前预期的抽奖数: $n 提前的累计秒数: ${DValueMinSum}s  预期的抽奖数: $s 相互抵消的累计秒数: $[DValueMinSum+DValueMaxSum]s"
                [ $[DValueMinSum+DValueMaxSum] -eq 0 ] && echo "相互抵消持平，正常" && continue
                [ $[DValueMinSum+DValueMaxSum] -gt 0 ] && echo "抽奖有异常，请检查!" && continue
        }
done
