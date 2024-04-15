#!/bin/bash
#脚本路径
ScriptPath=`dirname $(readlink -f "$0")`
#api的token值
Token="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJuYW1lIjoiZHVkdSIsInBlcm0iOiJ3cml0ZSIsImV4dCI6IiJ9.XiZj23AEa6BkMKS81EqRUdysD7NSMA-jDGTb4EpujSk eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJuYW1lIjoiaHVqdW4iLCJwZXJtIjoid3JpdGUiLCJleHQiOiIifQ.2EtT0YmlPlu0IXC8i_VAYL2RNMN7lSN90rodUGncUm4"
#检查是否有传递参数
[ $# -eq 0 ] && echo "执行脚本时，请传递要查询的区块高度的参数。" && exit 1
#最新的区块高度
LatestBlockHeight=`lotus chain getblock $(lotus chain head 2>/dev/null| head -n 1) 2>/dev/null | jq .Height`
#遍历循环传递的参数
for StartBlockHeight in $@
do
    #开始的区块高度到结束一天的区块高度
    let EndBlockHeight=StartBlockHeight+2880
    #如果开始的区块到到结束的区块高度不足一天，就到当前最新的区块高度取值
    [ "$EndBlockHeight" -gt "$LatestBlockHeight" ] && EndBlockHeight="$LatestBlockHeight"
    #开始的区块高度及时间
    FromStartBlockHeight=`lotus chain list --height "$StartBlockHeight" --count 1 --format "<height>: (<time>)" 2> /dev/null`
    #结束的区块高度及时间
    ToEndBlockHeight=`lotus chain list --height "$EndBlockHeight" --count 1 --format "<height>: (<time>)" 2> /dev/null`
    echo "开始区块高度、时间：$FromStartBlockHeight TO 结束区块高度、时间：$ToEndBlockHeight 的抽奖和中奖次数："
    for token in $Token
    do
       #小节点CPU证明
       if [ "$token" == "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJuYW1lIjoiZHVkdSIsInBlcm0iOiJ3cml0ZSIsImV4dCI6IiJ9.XiZj23AEa6BkMKS81EqRUdysD7NSMA-jDGTb4EpujSk" ];then
          for miner in f0716775 f01179295 f0428661
          do
              bash $ScriptPath/venus_winnig_count_v1.sh "$miner" "$StartBlockHeight" "$token" |awk '/次数/{printf("%-10s %-10s %-10s\n",$1,$2,$3)}'
          done
       else
          #大节点GPU证明
          for miner in f01658888
          do
              bash $ScriptPath/venus_winnig_count_v1.sh "$miner" "$StartBlockHeight" "$token" |awk '/次数/{printf("%-10s %-10s %-10s\n",$1,$2,$3)}'
          done
       fi
    done
done
