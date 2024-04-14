#!/bin/bash
unset LOTUS_PATH LOTUS_MINER_PATH
unset FULLNODE_API_INFO MINER_API_INFO
which lotus > /dev/null && [ $? -ne 0 ] && echo "`which lotus`不存在，请检查。" && exit
export LOTUS_PATH=/opt/raid0/lotus ; if lotus sync wait &>/dev/null ;then sleep 1s; else export LOTUS_PATH=/opt/lotus/lotus; lotus sync wait &>/dev/null; fi
[ ! -f $LOTUS_PATH/../start_lotus.sh ] && echo "$LOTUS_PATH/../start_lotus.sh启动脚本不存在，请检查。" && exit
if ps -aux |grep -v grep |grep -w lotus |grep -wq daemon ;then
   echo "lotus daemon stop"
   lotus daemon stop && echo "lotus停止中......"
fi
while :
do
      if ps -aux |grep -v grep |grep -w lotus |grep -wq daemon ;then
              sleep 1s
              continue
      else
              echo "bash $LOTUS_PATH/../start_lotus.sh"
              bash $LOTUS_PATH/../start_lotus.sh && echo "Lotus启动中......"
              break
      fi
done
