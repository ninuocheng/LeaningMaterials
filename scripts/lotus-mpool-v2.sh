#!/bin/bash
#堵塞的消息文件
MPoolMessageInfo="/tmp/MpoolMessageInfo"
#刷新环境变量
source /opt/raid0/profile
#检查jq是否安装
dpkg -s jq  &>/dev/null || apt -y install jq
#导出消息到文件
lotus mpool pending --local |jq -r '.Message.Method,.CID' > $MPoolMessageInfo
#遍历导出的消息
while [ -s "$MPoolMessageInfo" ]
do
	#消息上链需要一定的时间
	sleep 60s
        #记录当前的时间
        date +%F%\t%T
        while [ -s "$MPoolMessageInfo" ]
	do
	    #消息类型
            Method=$(sed -n '1p' $MPoolMessageInfo)
	    #消息的CID
            CID=$(awk -F'"' 'NR==3{print $(NF-1)}' $MPoolMessageInfo)
	    #删除前四行
            sed -i '1,4d' $MPoolMessageInfo
	    #如果满足是5类消息，就自动疏通
            if [ "$Method" -eq 5 ];then
                  lotus mpool replace --auto --fee-limit 0.3 $CID && echo "$Method类消息的CID: $CID 已疏通"
		  sleep 1s
            fi
        done
	echo ""
done
