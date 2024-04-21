#!/bin/bash
#脚本的相关说明：
#关键就是注意四个"一定要注意"的标注就可以了
#发好的会追加到订单文件中，发单过程中有发失败的，会重新发，直到要发单的文件数量为0，就会退出脚本，最后还是建议检查一下发好的订单及数量
#false|true被认为执行失败，会异常退出
set -o pipefail
#脚本的路径
ScriptDir="/root/.gzc/auto-send-deal"
[ ! -d "$ScriptDir" ] && echo "脚本的路径: $ScriptDir 不存在，请检查。" && exit 1
#检查是否有重复执行该脚本，如果有执行了，就不会再执行
ProcessNub=`ps -ef |grep -c auto-send-deal.sh`
[ "$ProcessNub" -gt 3 ] && echo "发单脚本: auto-send-deal.sh 有在执行中，请检查。" && exit 2
#定义订单数量的变量
DealNub=0
#一定要注意发单的矿工号
#Provider="f02836080"
#Provider="f02836091"
Provider="f01777777"
#Provider="f0753213"
#Provider="f01777770"
[ -z "$Provider" ] && echo "提供要发单的矿工号参数为空，请检查。" && exit 3
#发单文件的目录
SendDealFileDir="$ScriptDir/$Provider"
[ ! -d "$SendDealFileDir" ] && mkdir -p $SendDealFileDir
#准备要发单的文件
SendDealFile="$SendDealFileDir/send-deal-file-${Provider}"
[ ! -f "$SendDealFile" ] && echo "准备要发单的文件: $SendDealFile 不存在，请检查。" && exit 4
[ ! -s "$SendDealFile" ] && echo "准备要发单的文件: $SendDealFile 数量为0，请检查。" && exit 5
#备份的时间
BakTime=`date +%Y%m%d-%H%M%S`
#发单的日志
SendDealLog="$ScriptDir/$Provider/send-deal-${Provider}.log"
#日志备份目录
LogBakDir="$ScriptDir/$Provider/logbak"
#备份发单的日志文件
[ -f "$SendDealLog" ] && mkdir -p $LogBakDir && mv $SendDealLog $LogBakDir/send-deal-${Provider}-${BakTime}.log
echo "给发单的矿工号：$Provider" |tee -a $SendDealLog
#一定要注意发单的生命周期 367天：2880 * 367 = 1056960  530天：2880 * 530 = 1526400
#Duration="1056960"  #367天
Duration="1526400"  #530天
[ -z "$Duration" ] && echo "提供要发单的生命周期参数为空，请检查。" && exit 6
[ "$Duration" -eq "1056960" ] && echo "发单的生命周期：367天" |tee -a $SendDealLog
[ "$Duration" -eq "1526400" ] && echo "发单的生命周期：530天" |tee -a $SendDealLog
#一定要注意主网当前的区块高度加上7天的区块高度，即：主网当前的区块高度 + 7 * 24 * 3600 / 30 = 主网当前的区块高度 + 20160 备注：30秒一个区块高度
LatestBlockHeight=`lotus chain getblock $(lotus chain head 2>/dev/null| head -n 1) 2>/dev/null | jq .Height`
StartEpoch=`echo "${LatestBlockHeight} + 20160" |bc`
[ -z "$StartEpoch" ] && echo "提供要发单的开始区块高度参数为空，请检查。" && exit 7
echo "发单的开始区块高度：$StartEpoch" |tee -a $SendDealLog
#一定要注意发单前是否需要配置保存unsealed检索文件，默认是false保存unsealed检索文件。miner的封装程序记得配置AlwaysKeepUnsealedCopy = true/false 备注：true 保存unsealed      false   不保存unsealed
RemoveUnsealedCopy="true"      #   true：不保存unsealed检索文件
#RemoveUnsealedCopy="false"     #   false：保存unsealed检索文件
[ -z "$RemoveUnsealedCopy" ] && echo "发单配置的参数: --remove-unsealed-copy=$RemoveUnsealedCopy 为空，请确认检查。"  && exit 8
[ "$RemoveUnsealedCopy" == "true" ] && echo "发单配置的参数: --remove-unsealed-copy=$RemoveUnsealedCopy 是不保存unsealed检索文件" |tee -a $SendDealLog
[ "$RemoveUnsealedCopy" == "false" ] && echo "发单配置的参数: --remove-unsealed-copy=$RemoveUnsealedCopy 是保存unsealed检索文件"  |tee -a $SendDealLog
#发好的订单文件，建议命名有标识性
SendDealInputFile="$ScriptDir/$Provider/ok-${Provider}-317-02-155"
[ -f "$SendDealInputFile" ] && echo "订单文件: $SendDealInputFile 已存在，请检查是否要继续。否则需要中断" && sleep 30s
#初始发单的PieceCid数量
InitialSendDealNub=`wc -l $SendDealFile |awk '{print $1}'`
#检查发单文件是否唯一
SendDealFileNub=`awk '{print $2}' $SendDealFile |sort |uniq -c |sort |wc -l`
[ "$InitialSendDealNub" -ne "$SendDealFileNub" ] && echo "准备要发单的文件: $SendDealFile 有重复的，请检查。" && exit 9
#检查发单的钱包地址，额度 默认单位是字节
boost wallet list 2>/dev/null|awk '$(NF-2) == "X"{print "发单的钱包地址: "$1,"额度: "$(NF-1),$NF}' |tee -a $SendDealLog
#本次发单要消耗的额度
ConsumeQuota=`echo "scale=6;$(wc -l $SendDealFile |awk '{print $1}')*32/1024"|bc`
#剩余的额度
QuotaQuantity=`boost wallet list 2>/dev/null|awk '$(NF-2) == "X"{print $(NF-1)}'`
[ $(echo "$ConsumeQuota > $QuotaQuantity"|bc) -eq 1 ] && echo "本次发单要消耗的额度: $ConsumeQuota 超出了额度的限制，请检查。" && exit 10
echo "本次发单要消耗的额度: $ConsumeQuota TiB" |tee -a $SendDealLog
#备份发单文件的目录
SendDealFileBakDir="$ScriptDir/$Provider/send-deal-filebak"
#备份发单的文件
[ -s "$SendDealFile" ] && mkdir -p $SendDealFileBakDir && cp -a $SendDealFile $SendDealFileBakDir/send-deal-file-${Provider}-$BakTime
echo "发单前的开始时间: $(date +%F%\t%T)" >> $SendDealLog 2>&1
echo "初始发单的数量: $InitialSendDealNub" >> $SendDealLog 2>&1
while [ -s "$SendDealFile" ]
do
    #发单前的PieceCid数量
    SendDealFrontNub=`wc -l $SendDealFile |awk '{print $1}'`
    echo "发单前的PieceCid数量: $SendDealFrontNub" >> $SendDealLog 2>&1
    #一定要注意发单的关键字段
    #因为PieceSize参数是个定值，所以传递的PieceSize变量就没有被调用到，只是起到一个占位参数
    while read PayloadCid Commp PieceSize
    do
	if [ "$DealNub" -eq 0 ];then
	   #该行输出的目的是方便检查发单的参数是否正确，还没有执行发单的命令，如果发现有问题就不要继续，按照提示选择退出脚本
           echo "boost offline-deal --verified=true --provider=$Provider --duration=$Duration --commp=$Commp  --start-epoch=$StartEpoch --piece-size=34359738368 --storage-price=0 --payload-cid=$PayloadCid --remove-unsealed-copy=$RemoveUnsealedCopy |egrep 'deal uuid|storage provider|payload cid|commp|start epoch|end epoch' |awk '{printf "'$NF'" \"|\"}' |awk '{print "'$1'"}' >> $SendDealInputFile"
	   if read -t 600 -p "Do you want to continue [Y/N]? " </dev/tty;then
              if [ "$REPLY" == "Y" ];then
	         sleep 1s
              elif [ "$REPLY" == "N" ];then
	         exit 11
              else
		echo
		echo "请选择Y是继续，或者N是退出脚本。"
	        break
              fi
           else
		echo
                echo "很抱歉，等待的时间太久没有选择继续，自动退出，请重新执行脚本"
		exit 12
           fi
        fi
	if [ -f "$SendDealInputFile" ];then
           if grep -wq "$Commp" $SendDealInputFile;then
	      echo "${Commp}已发过，禁止重复发单，请检查。" |tee -a $SendDealLog
	      sleep 120s
	      break
           fi
        fi
        #发单的命令及发好的订单会追加到订单文件中
	#一定要注意是否需要保存unsealed检索文件，默认是false保存unsealed检索文件，true是不保存unsealed
    	boost offline-deal  --verified=true  --provider=$Provider  --duration=$Duration  --commp=$Commp  --start-epoch=$StartEpoch --piece-size=34359738368  --storage-price=0   --payload-cid=$PayloadCid  --remove-unsealed-copy=$RemoveUnsealedCopy |egrep 'deal uuid|storage provider|payload cid|commp|start epoch|end epoch' |awk '{printf $NF "|"}' |awk '{print $1}' >> $SendDealInputFile && {
    	let DealNub++
	#打印发单的命令
        echo "第${DealNub}个：boost offline-deal --verified=true --provider=$Provider --duration=$Duration --commp=$Commp --start-epoch=$StartEpoch --piece-size=34359738368 --storage-price=0 --payload-cid=$PayloadCid --remove-unsealed-copy=$RemoveUnsealedCopy |egrep 'deal uuid|storage provider|payload cid|commp|start epoch|end epoch' |awk '{printf "'$NF'" \"|\"}' |awk '{print "'$1'"}' >> $SendDealInputFile" >> $SendDealLog 2>&1
    	sed -i '/'${Commp}'/d' $SendDealFile
    	}
        #一开始限制发单的数量，不要一次性发很多单，可以尝试的测试几个，如果发现有异常，睡眠的这段时间需要手动中断脚本，如果发单正常，就无需操作，耐心等待就可以了
        [ "$DealNub" -eq 1 ] && echo "请检查发的订单是否异常，会睡眠一段时间，确认没问题方可执行批量的发单操作，否则需要中断" |tee -a $SendDealLog && sleep 60s
        #[ "$DealNub" -eq 700 ] && exit
    done < $SendDealFile
done
[ ! -f "$SendDealInputFile" ] && echo "发好的订单文件: $SendDealInputFile 不存在，请检查。" && exit 13
[ ! -s "$SendDealInputFile" ] && echo "发好的订单文件: $SendDealInputFile 数量为空，请检查。" && exit 14
SendDealInputNub=`wc -l $SendDealInputFile |awk '{print $1}'`
SendDealNub=`awk -F'|' '{print $4}' $SendDealInputFile |sort |uniq -c |sort |wc -l`
if [ "$SendDealInputNub" -eq "$SendDealNub" ];then
	echo "发好的订单数量: $SendDealInputNub ,建议再检查并核对数量。" |tee -a $SendDealLog
elif [ "$SendDealInputNub" -gt "$SendDealNub" ];then
	echo "发好的订单数量: $SendDealInputNub ,有重复发单的，请检查。" |tee -a $SendDealLog
else
        echo "发好的订单数量: $SendDealInputNub ,有问题，请检查。" |tee -a $SendDealLog
        exit 15
fi
