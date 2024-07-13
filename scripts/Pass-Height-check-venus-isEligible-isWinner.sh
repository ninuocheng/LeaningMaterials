#!/bin/bash
#脚本路径
ScriptPath=`dirname $(readlink -f "$0")`
#第一个区块高度的时间戳，备注：第一个区块高度0的区块时间：2020-08-25 06:00:00
TimeStampFirstBlockHeight="1598306400"
#api的token值
Token="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJuYW1lIjoiZHVkdSIsInBlcm0iOiJ3cml0ZSIsImV4dCI6IiJ9.XiZj23AEa6BkMKS81EqRUdysD7NSMA-jDGTb4EpujSk eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJuYW1lIjoiaHVqdW4iLCJwZXJtIjoid3JpdGUiLCJleHQiOiIifQ.2EtT0YmlPlu0IXC8i_VAYL2RNMN7lSN90rodUGncUm4"
#检查是否有传递参数
[ $# -eq 0 ] && echo "执行脚本时，请传递要查询的区块高度的参数。" && exit 1
#遍历循环传递的参数
for BlockHeight in $@
do
    #区块高度的秒数，备注：30秒一个区块高度
    let BlockHeightSeconds=(BlockHeight-0)*30
    #区块高度的时间戳，备注：unix时间戳是从1970年1月1日（UTC/GMT的午夜）开始所经过的秒数，不考虑闰秒
    let TimeStampBlockHeight=TimeStampFirstBlockHeight+BlockHeightSeconds
    #区块高度的时间戳转换区块高度时间的日期
    #BlockHeightDate=`date -d @$TimeStampBlockHeight +"%Y-%m-%d"`
    BlockHeightDate=`date -d @$TimeStampBlockHeight +"%Y-%m-%d %H:%M:%S"`
    echo "${BlockHeightDate}开始一天的抽奖和中奖次数："
    for token in $Token
    do
       #小节点CPU证明
       if [ "$token" == "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJuYW1lIjoiZHVkdSIsInBlcm0iOiJ3cml0ZSIsImV4dCI6IiJ9.XiZj23AEa6BkMKS81EqRUdysD7NSMA-jDGTb4EpujSk" ];then
          for miner in f0716775 f01179295 f0428661
          do
              #bash $ScriptPath/venus_winnig_count_v1.sh "$miner" "$BlockHeight" "$token" |grep '次数'
	      bash $ScriptPath/venus_winnig_count_v1.sh "$miner" "$BlockHeight" "$token" |awk '/次数/{printf("%-10s %-10s %-10s\n",$1,$2,$3)}'
          done
       else
          #大节点GPU证明
          for miner in f01658888
          do
              #bash $ScriptPath/venus_winnig_count_v1.sh "$miner" "$BlockHeight" "$token" |grep '次数'
              bash $ScriptPath/venus_winnig_count_v1.sh "$miner" "$BlockHeight" "$token" |awk '/次数/{printf("%-10s %-10s %-10s\n",$1,$2,$3)}'
          done
       fi
    done
done
