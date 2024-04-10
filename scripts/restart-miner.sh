#!/bin/bash
#主目录的关键字,比如window winning sealing,如果不指定参数，默认是winning
MinerKeyWord=$1
[ -z "${MinerKeyWord}" ] && MinerKeyWord="winning"
unset LOTUS_PATH LOTUS_MINER_PATH
unset FULLNODE_API_INFO MINER_API_INFO
[ ! -f /opt/raid0/lotusminer-${MinerKeyWord}/profile ] && echo "/opt/raid0/lotusminer-${MinerKeyWord}/profile不存在，请检查。" && exit
[ -f /opt/raid0/profile ] && source /opt/raid0/profile
source /opt/raid0/lotusminer-${MinerKeyWord}/profile
if ps -aux |grep -v grep |grep -w lotusminer-${MinerKeyWord} ;then
   echo "lotusminer-${MinerKeyWord}准备stop......"
   which lotus-miner && [ $? -ne 0 ] && echo "lotus-miner程序不存在，请检查。" && exit
   echo "lotus-miner stop"
   lotus-miner stop
fi
while :
do
      if ps -aux |grep -v grep |grep -w lotusminer-${MinerKeyWord} ;then
	      pgrep -a lotus
	      sleep 3s
	      continue
      else
	      echo "lotusminer-${MinerKeyWord}准备start......"
	      echo "bash /opt/raid0/lotusminer-${MinerKeyWord}/start_lotusminer.sh"
	      bash /opt/raid0/lotusminer-${MinerKeyWord}/start_lotusminer.sh && echo "Lotusminer-${MinerKeyWord}程序启动中......"
	      break
      fi
done
which lotus && [ $? -ne 0 ] && echo "lotus程序不存在，请检查。" && exit
echo "Lotus的API信息：`lotus auth api-info --perm admin`"
echo "Lotusminer-${MinerKeyWord}的API信息：`lotus-miner auth api-info --perm admin`"
