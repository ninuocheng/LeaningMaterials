#!/bin/bash
#主目录的关键字,比如window winning sealing,如果不指定参数，默认是winning
MinerKeyWord=$1
[ -z "${MinerKeyWord}" ] && MinerKeyWord="winning"
unset LOTUS_PATH LOTUS_MINER_PATH
unset FULLNODE_API_INFO MINER_API_INFO
[ ! -f /opt/raid0/lotusminer-${MinerKeyWord}/profile ] && echo "/opt/raid0/lotusminer-${MinerKeyWord}/profile不存在，请检查。" && exit
which lotus > /dev/null && [ $? -ne 0 ] && echo "`which lotus`不存在，请检查。" && exit
which lotus-miner > /dev/null && [ $? -ne 0 ] && echo "`which lotus-miner`不存在，请检查。" && exit
export LOTUS_PATH=/opt/raid0/lotus ; if lotus sync wait &>/dev/null ;then sleep 1s; else export LOTUS_PATH=/opt/lotus/lotus; lotus sync wait &>/dev/null; fi
[ ! -f "$LOTUS_PATH/../lotusminer-${MinerKeyWord}/start_lotusminer.sh" ] && echo "$LOTUS_PATH/../lotusminer-${MinerKeyWord}/start_lotusminer.sh启动脚本不存在，请检查。" && exit
[ -f $LOTUS_PATH/../profile ] && source $LOTUS_PATH/../profile
source /opt/raid0/lotusminer-${MinerKeyWord}/profile
if ps -aux |grep -v grep |grep -wq lotusminer-${MinerKeyWord} ;then
   echo "lotus-miner stop"
   lotus-miner stop && echo "lotusminer-${MinerKeyWord}停止中......"
fi
while :
do
      if ps -aux |grep -v grep |grep -wq lotusminer-${MinerKeyWord} ;then
              sleep 3s
              continue
      else
              echo "bash $LOTUS_PATH/../lotusminer-${MinerKeyWord}/start_lotusminer.sh"
              bash $LOTUS_PATH/../lotusminer-${MinerKeyWord}/start_lotusminer.sh && echo "Lotusminer-${MinerKeyWord}启动中......"
              break
      fi
done
