#!/bin/bash
unset LOTUS_PATH LOTUS_MINER_PATH
unset FULLNODE_API_INFO MINER_API_INFO
export LOTUS_PATH=/opt/raid0/lotus ; if lotus sync wait &>/dev/null ;then sleep 1s; else export LOTUS_PATH=/opt/lotus/lotus; lotus sync wait &>/dev/null; fi
[ -f /opt/raid0/lotusminer-window/profile ] && source /opt/raid0/lotusminer-window/profile
MinerID=$(lotus-miner proving info 2>/dev/null |awk '$1 == "Miner:"{print $2}')
echo "Count  Deadline" > /tmp/faultsnub
lotus-miner proving faults 2>/dev/null |awk '!/Miner:|deadline/{print $1}' |uniq -c >> /tmp/faultsnub
if [ $(cat /tmp/faultsnub |wc -l) -gt 1 ];then
	echo "${MinerID} 有错误扇区:"
        column -t /tmp/faultsnub
fi
