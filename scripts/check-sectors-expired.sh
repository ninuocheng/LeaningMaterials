#!/bin/bash
#脚本的路径
ScriptPath=`dirname $(readlink -f $0)`
#当前的时间
Current=`date +%Y%m%d-%H%M%S`
#封装任务
SealingJobs=$ScriptPath/SealingJobs
#lotus-miner sealing jobs |awk '$5!="AP"{print}' > $SealingJobs
#扇区封装的各阶段状态
SectorsPeriodState=$ScriptPath/SectorsPeriodState
lotus-miner sectors list --states PreCommit1,PreCommit2,PreCommitWait,WaitSeed,Committing,CommitFinalize,CommitWait > $SectorsPeriodState
#扇区的详细信息
SectorsDetailInfo=$ScriptPath/SectorsDetailInfo
#初始扇区的详细信息
>$SectorsDetailInfo
#for i in `awk 'NR>1{print $2}' $SealingJobs`; do lotus-miner sectors status --log $i >> $SectorsDetailInfo; done   #针对正在封装的任务
for i in `awk 'NR>1{print $1}' $SectorsPeriodState`; do lotus-miner sectors status --log $i >> $SectorsDetailInfo; done   #针对各阶段状态的任务
#扇区的开始高度
SectorsStartEpoch=$ScriptPath/SectorsStartEpoch
awk '/StartEpoch/{print $7}' $SectorsDetailInfo > $SectorsStartEpoch
#转换Json格式
SectorsStartEpochJsonFormat=$ScriptPath/SectorsStartEpochJsonFormat
cat $SectorsStartEpoch |jq . > $SectorsStartEpochJsonFormat
#Json格式转换为字符串
CharcterString=$ScriptPath/CharcterString
awk '/"\/": "bag/ {PieceCID=$2} /DealID/ {DealID=$2} /Client/ {Client=$2} /Provider/ {Provider=$2} /StartEpoch/ {StartEpoch=$2} /EndEpoch/ {EndEpoch=$2} /StoragePricePerEpoch/ {print PieceCID,DealID,Client,Provider,StartEpoch,EndEpoch;PieceCID="";DealID="";Client="";Provider="";StartEpoch="";EndEpoch=""}' $SectorsStartEpochJsonFormat > $CharcterString
#去掉引号和逗号
sed -i -e 's/"//g' -i -e 's/,//g' $CharcterString
#开始高度的去重排序
StartEpochDesorting=$ScriptPath/StartEpochDesorting
awk '{print $5}' $CharcterString |sort |uniq -c |sort -nk2 > $StartEpochDesorting
#扇区的关键信息
SectorsKeyInfo=$ScriptPath/SectorsKeyInfo
#初始扇区的关键信息
>$SectorsKeyInfo
awk '/SectorID/ {SectorID=$2} /Status/ {Status=$2} /TicketH/ {TicketH=$2} /Deals/ {Deals=$2" "$3} /SealGroupID/ {SealGroupID=$2} /StartEpoch/ {StartEpoch=$7} /event;sealing.SectorTicket/ {print SectorID,Status,TicketH,Deals,SealGroupID,StartEpoch;SectorID="";Status="";TicketH="";Deals="";SealGroupID="";StartEpoch=""}' $SectorsDetailInfo >> $SectorsKeyInfo
#当前最新区块高度
LatestBlockHeight=`lotus chain getblock $(lotus chain head 2>/dev/null| head -n 1) 2>/dev/null | jq .Height`
#需要保证完成封装的开始高度，视情况而定。p1阶段6个小时，p2阶段20分钟���然后提交p2上链消息预质押币到waitseed阶段，等待75分钟。c2阶段20分钟，提交C2上链消息质押币，然后落盘10分钟Proving证明阶段。平均整个过程需要8个小时零5分钟
let RequirePledgeMinHeight=$LatestBlockHeight+0
mkdir -p $ScriptPath/ExpiredSectors && [ -f $ScriptPath/ExpiredSectors/ExpiredSectors ] && mv $ScriptPath/ExpiredSectors/ExpiredSectors $ScriptPath/ExpiredSectors/${Current}-ExpiredSectors
mkdir -p $ScriptPath/No-ExpireSectors && [ -f $ScriptPath/No-ExpireSectors/No-ExpireSectors ] && mv $ScriptPath/No-ExpireSectors/No-ExpireSectors $ScriptPath/No-ExpireSectors/${Current}-No-ExpireSectors
echo "当前最新区块高度：$LatestBlockHeight" 
#echo "需要保证完成封装的最小开始高度：$RequirePledgeMinHeight"
#第一个区块高度的时间戳，备注：第一个区块高度0的区块时间：2020-08-25 06:00:00
TimeStampFirstBlockHeight="1598306400"
for BlockHeight in `awk '{print $2}' $StartEpochDesorting`
do
        #区块高度的秒数，备注：30秒一个区块高度
        let BlockHeightSeconds=BlockHeight*30
        #区块高度的时间戳，unix时间戳是从1970年1月1日（UTC/GMT的午夜）开始所经过的秒数，不考虑闰秒
        let TimeStampBlockHeight=TimeStampFirstBlockHeight+BlockHeightSeconds
        #区块时间的时间戳转换日期时间
        BlockHeightExpirationDate=`date -d @$TimeStampBlockHeight +"%Y-%m-%d %H:%M:%S"`
        #let ExpirationTime=(BlockHeight-LatestBlockHeight)/2880 注释：let计算取值为整数
        ExpirationTime=`echo "scale=5;($BlockHeight - $LatestBlockHeight)/2880" |bc`
	if [ $BlockHeight -le $RequirePledgeMinHeight ];then
	    echo "过期的日期时间：${BlockHeightExpirationDate}" |tee -a $ScriptPath/ExpiredSectors/ExpiredSectors
	    egrep -w  '"StartEpoch":'$BlockHeight''  $SectorsKeyInfo |awk 'BEGIN{print "ID State SealGroupID StartEpoch ExpiredDays"}{print $1,$2,$6,'${BlockHeight}','${ExpirationTime}'}' |column -t |tee -a $ScriptPath/ExpiredSectors/ExpiredSectors
	    #egrep -w  '"StartEpoch":'$BlockHeight''  $SectorsKeyInfo |awk 'BEGIN{print "ID State SealGroupID StartEpoch ExpiredTime"}{print $1,$2,$6,'${BlockHeight}','$BlockHeightExpirationDate'}' |column -t |tee -a $ScriptPath/ExpiredSectors/ExpiredSectors
        else
	    echo "距离过期的日期时间：${BlockHeightExpirationDate}" >> $ScriptPath/No-ExpireSectors/No-ExpireSectors
	    egrep -w  '"StartEpoch":'$BlockHeight''  $SectorsKeyInfo |awk 'BEGIN{print "ID State SealGroupID StartEpoch DistanceExpirationDays"}{print $1,$2,$6,'${BlockHeight}','${ExpirationTime}'}' |column -t >> $ScriptPath/No-ExpireSectors/No-ExpireSectors
        fi
done
