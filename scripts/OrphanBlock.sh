#!/bin/bash
ScriptDir=$(dirname $(readlink -f $0))
unset LOTUS_PATH LOTUS_MINER_PATH
unset FULLNODE_API_INFO MINER_API_INFO
[ -f "/opt/raid0/profile" ] && source /opt/raid0/profile
[ -f "/opt/raid0/lotusminer-winning/profile" ] && source /opt/raid0/lotusminer-winning/profile
MinerID=$(lotus-miner proving info 2>/dev/null |awk '$1 == "Miner:"{print $2}')
HostName=$(hostname |awk -F'-' '{print $1}')
MinerID=${MinerID:-$HostName}
[ $# -eq 0 ] && echo "需要给位置参数(-1：昨天，-2：前天，以此类推)"
for i in $@
do
    #查询的日期
    DateTime=$(date  -d ''$i' day' '+%Y-%m-%d')
    WinningLog="/opt/raid0/lotusminer-winning/lotusminer/log*"
    MinedNewBlock="$ScriptDir/MinedNewBlock"
    HashHeightParents="$ScriptDir/HashHeightParents"
    WinParentBlockHeight="$ScriptDir/WinParentBlockHeight"
    HashHeightParentsParentBlockHeight="$ScriptDir/HashHeightParentsParentBlockHeight"
    IsWinner="$ScriptDir/IsWinner"
    IsWinERROR="$ScriptDir/IsWinERROR"
    [ ! -f "/opt/raid0/lotusminer-winning/lotusminer/logs" ] && echo "日志文件不存在，请检查" && exit
    grep -ar 'mined new block.*{"cid":' $WinningLog |grep "${DateTime}T" > $MinedNewBlock
    grep -ar '"isEligible": true, "isWinner": true' $WinningLog |grep "${DateTime}T" > $IsWinner
    LotteryNum=$(grep -ar '"isEligible": true, "isWinner":' $WinningLog |grep "${DateTime}T" -c) #抽奖数量
    WinNum=$(grep -ar '"isEligible": true, "isWinner": true'  $WinningLog |grep "${DateTime}T" -c) #中奖数量
    # 过滤区块哈希，区块高度，父区块到一个文件
    awk '{print $9,$11,$15}' $MinedNewBlock |sed 's#,$##' > $HashHeightParents
    > $WinParentBlockHeight
    # 中奖数和出块数匹配要一致，否则需要处理掉,一般都是区块高度不同步，再次重做所致
    IsWinNum=$(wc -l < $IsWinner)
    MinedNum=$(wc -l < $MinedNewBlock)
    n=$[IsWinNum-MinedNum]
    if [ "$n" -ne 0 ];then
	    sed -i '/ERROR/d' $IsWinner
    fi
    for forRound in $(awk '{print $2}' $HashHeightParents |sed 's#,##' |sort |uniq)
    do
	    # 过滤区块高度的父区块高度到一个文件
            awk '/"forRound": '$forRound'/{print $12}' $IsWinner|sed 's#,##' >> $WinParentBlockHeight
    done
    # 合并区块哈希，区块高度，父区块， 父区块高度到一个文件
    paste $HashHeightParents $WinParentBlockHeight > $HashHeightParentsParentBlockHeight
    m=$(awk '{print $2}' $HashHeightParentsParentBlockHeight |uniq -c |awk '{sum+=$1-1}END{print sum}')
    python3 $ScriptDir/ComparedParents.py $ScriptDir $MinerID $DateTime $LotteryNum $WinNum $[n+m]
done
