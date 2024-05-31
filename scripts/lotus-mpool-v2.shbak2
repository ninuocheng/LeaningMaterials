#!/bin/bash
#定义的消息文件
MPoolMessageInfo="/tmp/MPoolMessageInfo"
#定义的日志文件
LogFile="/tmp/LogFile"
#刷新环境变量
source /opt/raid0/profile &>/dev/null
#检查jq是否安装
dpkg -s jq  &>/dev/null || apt -y install jq
#导出消息到文件
lotus mpool pending --local |jq -r '.Message|.To,.From,.Nonce,.Method,.CID."/"' |awk '{if(NR%5==0){print $0}else{printf "%s ",$0}}' > $MPoolMessageInfo
#消息上链需要一定的时间
[ -s "$MPoolMessageInfo" ] && sleep 60s || exit 1
#刷新导出消息的文件
lotus mpool pending --local |jq -r '.Message|.To,.From,.Nonce,.Method,.CID."/"' |awk '{if(NR%5==0){print $0}else{printf "%s ",$0}}' > $MPoolMessageInfo
#遍历导出的消息
while read Receiver Sender Nonce Method CID
do
	#如果满足是5类消息，就自动疏通
	if [ "$Method" -eq 5 ];then
		LimitFee="0.006" #第1次疏通限定的数值,如果第一次疏通因为gas的波动超出限定的数值而导致的失败，会进行再次的疏通
		echo "$Receiver的Nonce:$Nonce第1次疏通: lotus mpool replace --auto --fee-limit $LimitFee $CID" &>> $LogFile
		lotus mpool replace --auto --fee-limit $LimitFee $CID &>> $LogFile && {
			echo "$Receiver $Method类消息的CID: $CID 的 Nonce: $Nonce 已疏通(限定的--fee-limit: $LimitFee)" &>> $LogFile
		}||{
			if grep -wq "no pending message found from $Sender with nonce $Nonce" $LogFile;then
                                continue
                        fi
			if grep -wq "failed to push new message to mempool: failed to add locked: message from $Sender with nonce $Nonce already in mpool: message with nonce already exists" $LogFile;then
				continue
			fi
			LimitFee="0.2" #第2次疏通限定的数值
		        echo "$Receiver的Nonce:$Nonce第2次疏通: lotus mpool replace --auto --fee-limit $LimitFee $CID" &>> $LogFile
		        lotus mpool replace --auto --fee-limit $LimitFee $CID &>> $LogFile && {
				echo "$Receiver $Method类消息的CID: $CID 的 Nonce: $Nonce 已疏通(限定的--fee-limit: $LimitFee)" &>> $LogFile
			}
		}
	else
		echo "$Receiver $Method类消息的CID: $CID 的 Nonce: $Nonce 不满足条件，无需操作" &>> $LogFile
	fi
done < $MPoolMessageInfo
echo "" &>> $LogFile
exit 3
