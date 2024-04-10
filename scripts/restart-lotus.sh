#!/bin/bash
unset LOTUS_PATH LOTUS_MINER_PATH
unset FULLNODE_API_INFO MINER_API_INFO
[ ! -f /opt/raid0/profile ] && echo "/opt/raid0/profile不存在，请检查。" && exit
which lotus && [ $? -ne 0 ] && echo "lotus程序不存在，请检查。" && exit
source /opt/raid0/profile
if ps -aux |grep -v grep |grep -w lotus |grep -w daemon ;then
   echo "lotus准备stop......"
   echo "lotus daemon stop"
   lotus daemon stop
fi
while :
do
      if ps -aux |grep -v grep |grep -w lotus |grep -w daemon ;then
	      sleep 1s
	      continue
      else
	      echo "lotus准备start......"
	      echo "bash /opt/raid0/start_lotus.sh"
	      bash /opt/raid0/start_lotus.sh && echo "Lotus程序启动中......"
	      break
      fi
done
echo "Lotus的API信息：`lotus auth api-info --perm admin`"
