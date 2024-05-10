#!/bin/bash
#统计每个状态的个数
declare -A array1
#states=`ss -ant|cut -d' ' -f1`
states=$(ss -ant|awk 'NR>1{print $1}')
for i in $states
do
        let array1[$i]++
done
#通过遍历数组里的索引和元素打印出来
for j in ${!array1[@]}
do
        echo $j:${array1[$j]}
done
