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
#WinningList='f01538000,f0753988,f0112087,f0716775,f01179295,f01658888,f0428661'
#WinningList='f01990005,f01658888,f0428661,f0716775,f01179295'
#WinningList='f01990005,f0112087'
#WinningList='f01699999,f01777770'
#WinningList='f01777770,f0753988,f0112087,f047857,f01777777,f0469055,f0748179,f01699999,f01990005,f01699876,f01038389,f01566485,f01527777,f090387,f01658888,f0716775,f0428661,f02229760,f01250983,f02239698,f01530777,f01520487,f01264518,f0503420,f01098835,f02236965,f01417791,f0513878,f02836091,f01044086,f01521158,f01609999,f0845296,f02836080,f01656666,f01666880,f01825045,f01416862,f0753213,f0723827,f02528,f01538000'
WinningList='f01658888,f02528'
#WinningList='f047857,f0753988'
#WinningList='f01656666'
#WinningList='f0716775,f0428661,f01179295,f01658888'
#WinningList='f0748179,f01777777,01656666,f0469055,f0753988,f047857,f0112087'
#WinningList='f02236965,f0753988,f047857,f0112087,f0748179,f01416862,f0753213,f01699999,f01038389,f01777770,f01777777,f0469055,f01699876,f01566485,f01136428,f02229760,f0503420,f01521158,f0428661,f01656666,f01530777,f01789225,f01527777,f01098835,f01825045,f0845296,f01990005,f01520487,f090387,f0513878,f02528,f02239698,f01417791,f01609999,f022748,f01666880,f0723827,f01264518,f01658888,f01415710,f01250983,f01538000,f01044086,f0716775'
for i in $@
do
   #要查询的日期
   DateTime=`date  -d ''$i' day' '+%Y-%m-%d'`
   #执行操作命令
   #ansible -i $WinningHost $WinningList -m script -a ''$ScriptPath'/isEligible-isWinner.sh '$DateTime'' |tee JumperIsEligible-IsWinner-Time
   ansible -i $WinningHost $WinningList -m script -a ''$ScriptPath'/isEligible-isWinner.sh '$DateTime'' 1>/dev/null
   #ansible -i $WinningHost $WinningList -m shell -a 'cat /tmp/IsEligible-IsWinner-Time' |awk 'BEGIN{print "'$DateTime'的抽奖和中奖："}/抽奖次数/{print}' |column -t
   ansible -i $WinningHost $WinningList -m shell -a 'cat /tmp/IsEligible-IsWinner-Time' |awk 'BEGIN{print "'$DateTime'"}/抽奖次数/{print}' |column -t
done
