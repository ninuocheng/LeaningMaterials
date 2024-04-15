#!/bin/bash
#查询的日期
DateTime=$1
#矿工ID
#MinerID=`hostname |awk -F"-" '{print $1}'`
unset LOTUS_PATH LOTUS_MINER_PATH
unset FULLNODE_API_INFO MINER_API_INFO
[ -f /opt/raid0/profile ] && source /opt/raid0/profile
[ -f /opt/raid0/lotusminer-winning/profile ] && source /opt/raid0/lotusminer-winning/profile
MinerID=$(/opt/raid0/lotusminer-winning/lotusminer/bin/lotus-miner proving info |awk '$1 == "Miner:"{print $2}')
#中奖次数
#IsWinner=`grep -a "${DateTime}T" /opt/raid0/lotusminer-winning/lotusminer/log* -r |grep '"isEligible": true, "isWinner": true'|awk 'END{print NR}'`
IsWinner=`grep "${DateTime}T" /opt/raid0/lotusminer-winning/lotusminer/log* -r |grep '"isEligible": true, "isWinner": true'|awk 'END{print NR}'`
#grep -a "${DateTime}T" /opt/raid0/lotusminer-winning/lotusminer/log* -r |grep '"isEligible": true, "isWinner":'|awk 'END{print "'$MinerID'", "抽奖次数："NR, "中奖次数：" '$IsWinner'}' |tee /tmp/IsEligible-IsWinner-Time
grep "${DateTime}T" /opt/raid0/lotusminer-winning/lotusminer/log* -r |grep '"isEligible": true, "isWinner":'|awk 'END{print "'$MinerID'", "抽奖次数："NR, "中奖次数：" '$IsWinner'}' |tee /tmp/IsEligible-IsWinner-Time
