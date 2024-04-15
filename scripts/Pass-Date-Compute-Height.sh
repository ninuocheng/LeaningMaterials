#!/bin/bash
#脚本路径
ScriptPath=`dirname $(readlink -f "$0")`
#第一个区块高度的时间戳，备注：第一个区块高度0的区块时间：2020-08-25 06:00:00 说明：如果是参考其它区块高度就换算对应的时间戳，只要查询区块高度的日期晚于这个参考值
TimeStampFirstBlockHeight="1598306400"
#api的token值
Token="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJuYW1lIjoiZHVkdSIsInBlcm0iOiJ3cml0ZSIsImV4dCI6IiJ9.XiZj23AEa6BkMKS81EqRUdysD7NSMA-jDGTb4EpujSk eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJuYW1lIjoiaHVqdW4iLCJwZXJtIjoid3JpdGUiLCJleHQiOiIifQ.2EtT0YmlPlu0IXC8i_VAYL2RNMN7lSN90rodUGncUm4"
#检查是否有传递参数，备注：0表示今天的日期，-1表示昨天的日期，-2表示前天的日期，以此类推
[ $# -eq 0 ] && echo "执行脚本时，请传递要查询的区块时间的日期的参数。" && exit 1
#遍历循环传递的参数
for i in $@
do
    #区块时间的日期
    BlockTimeDate=`date -d ''$i' day' '+%Y-%m-%d 00:00:00'`  #注释的和下面等效
    #BlockTimeDate=`date -d ''$i' day' '+%Y-%m-%d'`
    #区块时间的日期转换时间戳
    TimeStampBlockTimeDate=`date -d "$BlockTimeDate" +%s`
    #区块高度的时间戳转换区块时间的高度，unix时间戳是从1970年1月1日（UTC/GMT的午夜）开始所经过的秒数，不考虑闰秒
    let BlockTimeHeight=(TimeStampBlockTimeDate-TimeStampFirstBlockHeight)/30+0  #0可以不加，主要为了方便理解，如果是参考其它区块高度值，就非加不可了
    echo "${BlockTimeDate}的区块高度: $BlockTimeHeight"
done
