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
IsEligible=`grep -r "${DateTime}T" /opt/raid0/lotusminer-winning/lotusminer/log* |grep '"isEligible": true, "isWinner":'|awk 'END{print NR}'`
#中奖的数量
IsWinner=`grep -r "${DateTime}T" /opt/raid0/lotusminer-winning/lotusminer/log* |grep '"isEligible": true, "isWinner": true' |awk 'END{print NR}'`
#爆块的数量
MinedNewBlock=`grep  -r "${DateTime}T" /opt/raid0/lotusminer-winning/lotusminer/log* |grep 'mined new block' |awk 'END{print NR}'`
#从中奖的列表中过滤区块高度不同步
#grep -a -r "${DateTime}T" /opt/raid0/lotusminer-winning/lotusminer/log* |grep '"isEligible": true, "isWinner": true' |awk -F'[,]' '{print $2,$3}' |awk '{print $2,$NF}' |awk '{print $1,$2+1}'|awk 'BEGIN{print "'$MinerID'","抽奖的数量: " '$IsEligible',"中奖的数量: " '$IsWinner',"爆块的数量: " '$MinedNewBlock'}{if($1 != $2)print "'$MinerID'   "$1"   区块高度不同步"}' |tee /tmp/MinedNewBlocklist
#如果参数中奖的区块高度不同步，会有提示
grep  -r "${DateTime}T" /opt/raid0/lotusminer-winning/lotusminer/log* |grep '"isEligible": true, "isWinner": true' |awk -F'[,]' '{print $2,$3}' |awk '{print $2,$NF}' |awk '{print $1,$2+1}'|awk 'BEGIN{print "'$MinerID'","抽奖的数量: " '$IsEligible',"中奖的数量: " '$IsWinner',"爆块的数量: " '$MinedNewBlock'}{if($1 != $2)print "'$MinerID'   "$1"   区块高度不同步";else print $1}' |tee /tmp/MinedNewBlocklist
#过滤的是爆块的区块高度 备注：如果浏览器的爆块列表查不到爆块的区块高度，说明爆块的区块高度是孤块的区块高度，需要注意的是如果中奖的数量比爆块的数量多，一般问题多是区块高度不同步导致completed mineOne报错
#grep -a -r "${DateTime}T" /opt/raid0/lotusminer-winning/lotusminer/log* |grep 'mined new block' |awk -F"," '{print $3}'
