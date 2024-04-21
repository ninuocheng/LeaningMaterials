#!/bin/bash
#说明：注释的这一行命令的作用是用来更方便的加入主机列表
#cat template |tr '\n' ','
#脚本路径
ScriptPath=`dirname $(readlink -f "$0")`
#ansible要调用的爆块主机的hosts文件
WinningHost="$ScriptPath/winninghosts"
[ ! -f "$WinningHost" ] && echo "ansible要调用的爆块主机的hosts文件${WinningHost}不存在，请检查！" && exit
#主机列表
#WinningList='winninglist'
WinningList='f01658888'
#要查询的日期
DateTime=`date  -d ''$1' day' '+%Y-%m-%d'`
#执行操作命令
#ansible -i $WinningHost $WinningList -m script -a ''$ScriptPath'/mined-new-block.sh '$DateTime'' |tee Jumpermined-new-block
ansible -i $WinningHost $WinningList -m script -a ''$ScriptPath'/mined-new-block.sh '$DateTime'' 1>/dev/null
#ansible -i $WinningHost $WinningList -m shell -a 'cat /tmp/MinedNewBlock' |awk 'BEGIN{print "'$DateTime'"}{print}' |tee minedNewBlock
ansible -i $WinningHost $WinningList -m shell -a 'cat /tmp/MinedNewBlock' |awk 'BEGIN{print "'$DateTime'"}/抽奖的数量|区块高度/{print}' |tee minedNewBlock
