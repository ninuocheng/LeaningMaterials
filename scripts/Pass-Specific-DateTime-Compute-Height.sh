#!/bin/bash
#脚本路径
ScriptPath=`dirname $(readlink -f "$0")`
#第一个区块高度的时间戳，备注：第一个区块高度0的区块时间：2020-08-25 06:00:00 说明：如果是参考其它区块高度就换算对应的时间戳，只要查询区块高度的日期晚于这个参考值
TimeStampFirstBlockHeight="1598306400"
#如果不指定具体的参数值，默认是第天的0时0分0秒
DefaultDateVaule=`date -d '1day' '+%Y-%m-%d'`
DefaultDateTime="00:00:00"
BlockDate="$1"
BlockTime="$2"
BlockDate=${BlockDate:-$DefaultDateVaule}
BlockTime=${BlockTime:-$DefaultDateTime}
BlockTimeDate="$BlockDate $BlockTime"
#区块时间的日期转换时间戳
TimeStampBlockTimeDate=`date -d "$BlockTimeDate" +%s`
#区块高度的时间戳转换区块时间的高度，unix时间戳是从1970年1月1日（UTC/GMT的午夜）开始所经过的秒数，不考虑闰秒
let BlockTimeHeight=(TimeStampBlockTimeDate-TimeStampFirstBlockHeight)/30+0  #0可以不加，主要为了方便理解，如果是参考其它区块高度值，就非加不可了
echo "${BlockTimeDate}的区块高度: $BlockTimeHeight"
