#!/bin/bash
#脚本路径
ScriptPath=`dirname $(readlink -f "$0")`
#第一个区块高度的时间戳，备注：第一个区块高度0的区块时间：2020-08-25 06:00:00
TimeStampFirstBlockHeight="1598306400"
#检查是否有传递参数
[ $# -eq 0 ] && echo "请传递区块高度的参数" && exit 1
#最新的区块高度
LatestBlockHeight=`lotus chain getblock $(lotus chain head 2>/dev/null| head -n 1) 2>/dev/null | jq .Height`
#遍历循环传递的参数
for BlockHeight in $@
do
	#区块高度的秒数，备注：30秒一个区块高度
	let BlockHeightSeconds=BlockHeight*30
	#区块高度的时间戳，unix时间戳是从1970年1月1日（UTC/GMT的午夜）开始所经过的秒数，不考虑闰秒
	let TimeStampBlockHeight=TimeStampFirstBlockHeight+BlockHeightSeconds
	#区块时间的时间戳转换日期时间
	BlockHeightExpirationDate=`date -d @$TimeStampBlockHeight +"%Y-%m-%d %H:%M:%S"`
	echo "区块高度${BlockHeight}的过期日期时间：$BlockHeightExpirationDate"
	#let ExpirationTime=(BlockHeight-LatestBlockHeight)/2880 注释：let计算取值为整数
	ExpirationTime=`echo "scale=5;($BlockHeight - $LatestBlockHeight)/2880" |bc`
	echo "区块高度${BlockHeight}的过期时间天数：${ExpirationTime}天"
done
