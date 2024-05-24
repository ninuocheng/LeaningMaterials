#!/bin/bash
#日志文件
WinningLogFile=/opt/raid0/lotusminer-winning/lotusminer/logs
for d in $@
do
        #要查询的日期
        DateTime=`date  -d ''$d' day' '+%Y-%m-%d'`
        #遍历抽奖的日期时间赋值到数组
        for i in $(grep "$DateTime" $WinningLogFile |awk '/isEligible": true/{print $1}')
        do
                array+=($i)
        done
        #初始化变量
        DValue=0
        DValueSum=0
        #检查是否有赋值到数组
        declare -p array &>/dev/null && echo "$DateTime"
        #遍历元素的索引值
        for j in `seq 2 ${#array[*]}`
        do
                Before=$(date +%s -d "${array[$j-2]}")
                After=$(date +%s -d "${array[$j-1]}")
                DValue=$(echo "$After - $Before" |bc)
                #echo $Before $After $DValue
                if [ "$DValue" -gt 32 ];then
                        let DValueSum=$[DValueSum+DValue-30]
                        echo "前1行日志时间: ${array[$j-2]} 后1行日志时间: ${array[$j-1]} 间隔秒数: ${DValue}s 超出秒数: $[DValue-30]s 超出的累计秒数: ${DValueSum}s"
                fi
        done
done
