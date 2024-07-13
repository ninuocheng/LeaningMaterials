#!/bin/bash
#开始时间
start=$(date +%s)
#历史信息文件
HistoryInfo="/tmp/HistoryInfo"
#刷新前的消息文件
BeforeRefreshMessageInfo="/tmp/BeforeRefreshMessageInfo"
#针对刷新前的消息，刷新后到目前还未上链的消息文件
MPoolMessageInfo="/tmp/MPoolMessageInfo"
#日志文件
LogFile="/tmp/LogFile"
#刷新环境变量
source /opt/raid0/profile &>/dev/null
#检查jq是否安装
dpkg -s jq  &>/dev/null || apt -y install jq
#导出消息到文件
lotus mpool pending --local |jq -r '.Message|.To,.From,.Nonce,.GasLimit,.GasFeeCap,.GasPremium,.Method,.CID."/"' |awk '{if(NR%8==0){print $0}else{printf "%s ",$0}}' > $BeforeRefreshMessageInfo
#消息上链需要一定的时间
[ -s "$BeforeRefreshMessageInfo" ] && sleep 120s || exit 1
#再次导出消息追加到文件
lotus mpool pending --local |jq -r '.Message|.To,.From,.Nonce,.GasLimit,.GasFeeCap,.GasPremium,.Method,.CID."/"' |awk '{if(NR%8==0){print $0}else{printf "%s ",$0}}' >> $BeforeRefreshMessageInfo
#到目前还未上链的5类消息重定向到文件
awk '$7==5' $BeforeRefreshMessageInfo |sort |uniq -d > $MPoolMessageInfo
#记录疏通的时间
[ -s "$MPoolMessageInfo" ] && echo "$(date +%F%\t%T)" &>> $LogFile || exit 2
#记录历史信息追加到文件，并记录时间
echo "$(date +%F%\t%T)" &>> $HistoryInfo
cat $MPoolMessageInfo &>> $HistoryInfo
LimitFeeParameter=$(cat /root/.LimitFeeParameter 2>/dev/null)
LimitFee=${LimitFeeParameter:-0.0008} #疏通限定的数值,如果未指定限定的数值，默认0.0008 如果疏通因为gas的波动超出限定的数值而导致的失败，会进行再次的疏通
#遍历导出的消息
while read Receiver Sender Nonce GasLimit GasFeeCap GasPremium Method CID
do
        #疏通的次数
        n=1
	while :
	do
		lotus mpool replace --auto --fee-limit $LimitFee $CID &>> $LogFile && {
			echo "第${n}次: $Receiver $Method类消息的CID: $CID 的 Nonce: $Nonce 已疏通(限定的--fee-limit: $LimitFee)" &>> $LogFile
			break
		}||{
			if grep -wq "no pending message found from $Sender with nonce $Nonce" $LogFile;then
				break
			fi
			sleep 15s
			LimitFee=$(awk 'BEGIN{print '$LimitFee+0.0001'}')
		        let n++
		}
	done
done < $MPoolMessageInfo
#结束时间
end=$(date +%s)
#耗时秒数
echo "Total execution time: $((end - start))s" &>> $LogFile
exit 3
