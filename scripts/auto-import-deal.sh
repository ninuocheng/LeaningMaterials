#!/bin/bash
#脚本的相关说明：
#关键就是注意三个"一定要注意"的标注就可以了
#一开始主要是针对存储的car文件没有拷贝好，现在不管是存储的car有没有拷贝好，都可以执行脚本自动导入
#如果有导入过的订单，也会有相关的日志提示，不影响正常订单的导入
#导入的过程中如果因为余额的不足，而导致失败，也会有相关的日志提示，处理好导致失败的原因，就可以继续导入了，此过程无需中断脚本。至于导致失败的这些订单，不会删除,导入成功的才会删除。但还是建议导入前备份初始准备的文件
#false|true被认为执行失败，会异常退出
set -o pipefail
#脚本的路径
ScriptDir="/root/.gzc/auto-import-deal"
#导入订单的日志
ImportDealLog="$ScriptDir/import-deal.log"
#记录当前的时间
echo "$(date +%F%\t%T)" |tee -a $ImportDealLog
[ ! -d "$ScriptDir" ] && echo "${ScriptDir}不存在，请检查。" && exit 1
#注意导入订单的文件，注意把要导入的订单文件拷贝命名为import-deal-file，建议不要改动脚本
ImportDealFile=import-deal-file
[ ! -f "$ScriptDir/$ImportDealFile" ] && echo "$ScriptDir/${ImportDealFile}不存在，请检查。" && exit 2
#定义剩余的订单数量为0的情况下，会继续尝试循环。除此之外不会被调用到
gocycle=0
#定义循环次数的变量
CycleNub=0
#定义订单数量的变量
DealNub=0
#保存订单的数量到一个文件,后面会调用到
echo "$DealNub" > $ScriptDir/StoreDealNub
#初始准备要导入的订单数量
InitialNub=`wc -l $ScriptDir/$ImportDealFile |awk '{print $1}'`
[ "$InitialNub" -eq 0 ] &&  echo "准备的文件: $ScriptDir/$ImportDealFile 要导入的订单数量为0，请检查。" && exit 3 && exit 4
#环境变量
source /opt/raid0/profile 2> /dev/null
source /opt/raid0/lotusminer-sealing/profile 2> /dev/null
source /opt/raid0/boost/profile 2> /dev/null
if pgrep -a lotus |grep -wq daemon ;then
    echo "pgrep -a lotus 进程正常"
else
    echo "lotus程序挂掉了，请检查"
    exit 6
fi
if pgrep lotus-miner >/dev/null;then
    echo "pgrep lotus-miner 进程正常"
else
    echo "调度封装的程序挂掉了，请检查"
    exit 5
fi
if pgrep boostd >/dev/null;then
   echo "pgrep boostd 进程正常"
else
   echo "准备启动boostd中........."
   bash /opt/raid0/boost/start_boostd-data.sh && sleep 6s
   bash /opt/raid0/boost/start_boost.sh >/dev/null && echo "Start boostd Success"
   sleep 120s
fi
#落盘的算力机数量
FinalizeWorkersNub=`lotus-miner sealing workers  |grep -wc 11000`
echo "落盘的算力机数量: $FinalizeWorkersNub"
#封装的PC1任务数量的最大值：算力机的数量乘以配置的任务数量14
MaxPC1SealingJobs=$(echo "$FinalizeWorkersNub*14"|bc)
#还剩余订单的数量
MinDealsMapNub=30
DealsMapNub=`grep 'deals map' /opt/raid0/lotusminer-sealing/lotusminer/logs |tail -1|tr -s ':{} ' '\n' |grep bafy2bzace -c`
echo "DealsMap的数量: $DealsMapNub"
[ $DealsMapNub -gt $MinDealsMapNub ] && echo "DealsMap的数量大于给定的最小值$MinDealsMapNub，无需导入订单。" && exit 7 && exit 8
#正在封装的PC1数量
PC1SealingJobsNub=`lotus-miner sealing jobs |grep -wic pc1`
echo "目前正在封装的PC1数量: $PC1SealingJobsNub"
[ $PC1SealingJobsNub -gt $MaxPC1SealingJobs ] && echo "封装的任务数量目前还处于饱和状态，无需导入订单。" && exit 9 && exit 10
#消息堵塞会导致C2消息频繁上链失败，所以每次导入订单前一定要暂停落盘，如果还有在落盘的，先不要导入订单。等落盘好的C2消息都上链了，然后开始导入订单，消息都上链了再恢复落盘
echo "导入订单前开始执行暂停落盘操作"  |tee -a $ImportDealLog
#暂停落盘操作
lotus-miner sealing workers  |grep -w 11000 |awk -F '[, ]' '{print "lotus-miner worker-pause --uuid "$2" -tt fin"}' |bash
PauseFinalizeWorkersNub=`lotus-miner sealing workers |grep -wc paused`
sleep 30s
[ "$PauseFinalizeWorkersNub" -eq "$FinalizeWorkersNub" ] && echo "已暂停落盘操作" |tee -a $ImportDealLog
echo "本轮初始准备要导入的订单数量：$InitialNub" |tee -a $ImportDealLog
#定义限制导入订单数量的变量
LimitImportDealNub=200
echo "限制导入订单的数量: $LimitImportDealNub"
#循环的嵌套
while :
do
     #还有在落盘的任务数量
     FinalizeNub=`/usr/local/bin/lotus-miner sealing jobs|grep -wic fin`
     echo "还有在落盘的任务数量: $FinalizeNub" |tee -a $ImportDealLog
     if [ "$FinalizeNub" -ne 0 ];then
	echo "先不要导入订单，等待落盘好的C2消息上链......" |tee -a $ImportDealLog
	sleep 60s
        continue
     else
	echo "准备开始导入订单" |tee -a $ImportDealLog
	sleep 3s
     fi
     while [ -s "$ScriptDir/$ImportDealFile" ]
     do
        #导入前的订单数量
        ImportFrontNub=`wc -l $ScriptDir/$ImportDealFile |awk '{print $1}'`
     	#一定要注意导入订单的关键字段UUid和PieceCid
     	awk -F'|' '{print $1,$4}' $ScriptDir/$ImportDealFile | while read UUid PieceCid
        do
     		#注意car文件的绝对路径
     		CarFilePath="/mnt/172.*/car/${PieceCid}.car"
		#查看PieceCid是否唯一
                PieceCidNub=`grep -wc "$PieceCid" $ScriptDir/$ImportDealFile`
                [ $PieceCidNub -gt 1 ] && echo "准备要导入的订单PieceCid：$PieceCid 不唯一，请检查。" 2>&1 |tee -a $ImportDealLog && continue
                if grep -w "$PieceCid" $ImportDealLog|grep -wvq "$UUid";then
                       #已导入的订单计数
                       let DealNub++
                       echo "第${DealNub}个：导入过的${PieceCid}的UUid和现在准备要导入的UUid：$UUid 不相同，可能是有重复发过，禁止该订单再次导入的操作，请检查。" 2>&1 |tee -a $ImportDealLog
                       break
                fi
     		#检查存储的car文件是否存在
     		if ls $CarFilePath &>/dev/null;then
     			#已导入订单的数量
     	                DealNub=`cat $ScriptDir/StoreDealNub`
			#查看存储car文件的具体路径且是否唯一
                        CarFileNub=`ls $CarFilePath |wc -l`
                        [ $CarFileNub -ne 1 ] && echo "第${DealNub}个：要导入订单的UUid：${UUid}存储的car文件${CarFilePath}路径不唯一，请检查。" 2>&1 |tee -a $ImportDealLog && continue
                        CarFilePath=`ls $CarFilePath`
                        #限制导入订单的数量
     	                [ "${DealNub}" -ge "$LimitImportDealNub" ] && break
			#导入订单的命令
                        boostd import-data $UUid $CarFilePath 2>&1 |tee -a $ImportDealLog
     			#已导入的订单计数
     			let DealNub++
			#如果导入订单有报错，会先睡眠一段时间，等待检查报错原因,一般就是余额不足导致的，充币或者是等导入的订单上链，余额释放就可以了，可以不中断脚本，脚本会继续当前报错的订单开始重新导入
                        if grep -w 'Error' $ImportDealLog |grep -wq "$UUid";then
                                if grep -w 'Error' $ImportDealLog |grep -w 'already' |grep -wq "$UUid";then
                                       echo "第${DealNub}个：boostd import-data $UUid $CarFilePath 是已导入过的订单，请检查。" 2>&1 |tee -a $ImportDealLog
				       let DealNub--
                                else
                                       echo "第${DealNub}个：boostd import-data $UUid $CarFilePath 导入订单报错，请检查。" 2>&1 |tee -a $ImportDealLog
				       let DealNub--
				       sleep 600s
                                       break
                               fi
                        else
                               #输出导入成功订单的命令
                               echo "第${DealNub}个：boostd import-data $UUid $CarFilePath" 2>&1 |tee -a $ImportDealLog
                        fi
                        #删除导入后的订单当前行
                        sed -i '/'${PieceCid}'/d' $ScriptDir/$ImportDealFile
			#刚开始执行脚本导入订单方便观察，如果异常，停顿的这几秒足够中断脚本了
			[ "${DealNub}" -eq 1 ] && sleep 6s
                else
                        continue
                fi
     		#更新保存已导入订单的数量
     		echo "$DealNub" > $ScriptDir/StoreDealNub
		#这里的停顿主要是为缓解服务器的压力，更是为了避免boost吞订单的情况,停顿的时间看着合适就好
     		sleep 1s
	done
     	#已循环次数的计数
     	let CycleNub++
     	#输出已循环的次数
     	echo "本轮的第${CycleNub}次循环导入订单的数量明细：" |tee -a $ImportDealLog
     	#还剩余要导入的订单数量
        RemainderNub=`wc -l $ScriptDir/$ImportDealFile |awk '{print $1}'`
        [ "$RemainderNub" -gt 0 ] && echo "还剩余要导入的订单数量：$RemainderNub" |tee -a $ImportDealLog
     	#新增已导入的订单数量
     	NewAlrealyImportNub=`echo "${ImportFrontNub} - ${RemainderNub}" |bc`
     	[ "$NewAlrealyImportNub" -gt 0 ] && echo "新增已导入的订单数量：$NewAlrealyImportNub" |tee -a $ImportDealLog
     	#已导入的订单数量
     	DealNub=`cat $ScriptDir/StoreDealNub`
        [ "$DealNub" -gt 0 ] && echo "已导入的订单数量：$DealNub" |tee -a $ImportDealLog
     	#新增要导入的订单数量；有新增才会输出
     	NewWillImportNub=`echo "${DealNub} + ${RemainderNub} - ${InitialNub}" |bc`
     	[ "$NewWillImportNub" -gt 0 ] && echo "新增要导入的订单数量：$NewWillImportNub" && continue
     	#检查还剩余要导入的订单数量如果为0，就直接退出当前的循环
        [ "$RemainderNub" -eq 0 ] &&  break
        #限制导入订单的数量
     	[ "${DealNub}" -ge "$LimitImportDealNub" ] && break
     done
     echo "本轮导入订单的数量：${DealNub}" |tee -a $ImportDealLog
     echo "本轮导入订单的结束时间：$(date +%F%\t%T)" |tee -a $ImportDealLog
     #导入订单的消息类型数量
     PublishStorageDealsMsgNub=`/usr/local/bin/lotus mpool pending --local|grep Method |grep -wc 4`
     echo "PublishStorageDeals的消息数量: $PublishStorageDealsMsgNub" |tee -a $ImportDealLog
     #如果导入订单的消息都上链了，就恢复落盘，否则会睡眠一段时间，再循环检查
     if [ "$PublishStorageDealsMsgNub" -eq 0 ];then
	echo "开始执行恢复落盘操作" |tee -a $ImportDealLog
        lotus-miner sealing workers  |grep -w 11000 |awk -F '[, ]' '{print "lotus-miner worker-resume --uuid "$2" -tt fin"}' |bash
	sleep 30s
        PauseFinalizeWorkersNub=`lotus-miner sealing workers |grep -wc paused`
	#调用管道会打开一个新的bash，所以要执行多次exit才能退出该脚本，否则会一直循环.....
        [ "$PauseFinalizeWorkersNub" -eq 0 ] && echo "已成功恢复落盘" |tee -a $ImportDealLog
	exit 11 && exit 12 && exit 13
     else
	echo "等待导入订单的消息上链......" |tee -a $ImportDealLog
	sleep 60s
	continue
     fi
done
