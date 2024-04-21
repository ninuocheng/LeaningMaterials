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
#WinningList='f01777777,f02236965,f01538000,f01825045,f01699999'
#WinningList='f01038389,f02236965,f0753988,f01699999'
WinningList='f01658888'
#WinningList='f02236965,f01699999,f01777777,f01538000,f01044086,f0723827'
#f0753988,f01566485,f01038389,f047857,f01538000,f02236965,f02229760'
#WinningList='f01038389,f01656666,f047857,f02236965,f01699999'
#WinningList='f01038389,f01538000'
#WinningList='f0469055,f01538000'
#要查询的日期
DateTime=`date  -d ''$1' day' '+%Y-%m-%d'`
#执行操作命令
#ansible -i $WinningHost $WinningList -m script -a ''$ScriptPath'/mined-new-blocklist.sh '$DateTime'' |tee Jumpermined-new-blocklist
ansible -i $WinningHost $WinningList -m script -a ''$ScriptPath'/mined-new-blocklist.sh '$DateTime'' 1>/dev/null
#ansible -i $WinningHost $WinningList -m shell -a 'cat /tmp/MinedNewBlocklist' |awk 'BEGIN{print "'$DateTime'"}/区块高度不同步|抽奖/{print}' |tee minedNewBlocklist
ansible -i $WinningHost $WinningList -m shell -a 'cat /tmp/MinedNewBlocklist' |awk 'BEGIN{print "'$DateTime'"}!/CHANGED/{print}' |tee minedNewBlocklist
