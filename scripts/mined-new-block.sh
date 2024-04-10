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
#抽奖的数量
#IsEligible=`grep -a -r "${DateTime}T" /opt/raid0/lotusminer-winning/lotusminer/log* |grep '"isEligible": true, "isWinner":'|grep -iv "error" |awk 'END{print NR}'`
IsEligible=`grep -r "${DateTime}T" /opt/raid0/lotusminer-winning/lotusminer/log* |grep '"isEligible": true, "isWinner":'|awk 'END{print NR}'`
#中奖的数量
#IsWinner=`grep -a -r "${DateTime}T" /opt/raid0/lotusminer-winning/lotusminer/log* |grep '"isEligible": true, "isWinner": true' |grep -iv "error" |awk 'END{print NR}'`
IsWinner=`grep  -r "${DateTime}T" /opt/raid0/lotusminer-winning/lotusminer/log* |grep '"isEligible": true, "isWinner": true' |awk 'END{print NR}'`
#爆块的数量
MinedNewBlock=`grep -r "${DateTime}T" /opt/raid0/lotusminer-winning/lotusminer/log* |grep 'mined new block' |awk 'END{print NR}'`
grep -r "${DateTime}T" /opt/raid0/lotusminer-winning/lotusminer/log* |grep '"isEligible": true, "isWinner": true' |awk -F'[,]' '{print $2,$3}' |awk '{print $2,$NF}' |awk '{print $1,$2+1}'|awk 'BEGIN{print "'$MinerID'","抽奖的数量: " '$IsEligible',"中奖的数量: " '$IsWinner',"爆块的数量: " '$MinedNewBlock'}{if($1 != $2)print "'$MinerID'   " $1"   区块高度不同步"}' |tee /tmp/MinedNewBlock
