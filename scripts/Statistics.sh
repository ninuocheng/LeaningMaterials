#统计web服务的不同连接状态个数
#找出查看网站连接状态的命令 ss -natp|grep :80
#如何统计不同的状态 循环去统计，需要计算
#!/bin/bash
#count_http_80_state
#统计每个状态的个数

declare -A array1
states=`ss -ant|grep 80|cut -d' ' -f1`

for i in $states
do
        let array1[$i]++
done

#通过遍历数组里的索引和元素打印出来
for j in ${!array1[@]}
do
        echo $j:${array1[$j]}
done
