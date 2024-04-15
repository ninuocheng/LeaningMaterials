#!/bin/bash
unset LOTUS_PATH LOTUS_MINER_PATH
unset FULLNODE_API_INFO MINER_API_INFO
export PATH=${PATH}:/usr/local/bin
which lotus > /dev/null && [ $? -ne 0 ] && echo "`which lotus`不存在，请检查。" && exit
echo "注意的是执行脚本前，如果lotus进程已停止了，那么LOTUS_PATH默认的环境变量是/opt/raid0/lotus"
export LOTUS_PATH=/opt/lotus/lotus
if lotus sync wait &>/dev/null ;then
	sleep 1s
else
	export LOTUS_PATH=/opt/raid0/lotus
	lotus sync wait &>/dev/null
fi
while :
do
   check_listen_port() {
      netstat -atnlp |grep -w "1234"
   }
   stop_lotus() {
      LotusProcess=$(pgrep -a lotus |awk '/daemon/{print $1}')
      LotusListenPort=$(netstat -tnlp |awk -F':|[ ]*' '/'${LotusProcess}'/{print $5}' |awk '/1234/{print}')
      if ps -aux |grep -v grep |grep -w lotus |grep -wq daemon ;then
         if lotus auth api-info --perm admin |grep -wq "$LotusListenPort" ;then
            echo "lotus daemon stop"
            lotus daemon stop && echo "lotus停止中......"
         fi
      else
	    echo "lotus已停止掉"
      fi
   }
   check_lotus_process() {
      pgrep -a lotus
   }
   lotus_version_update() {
      LatestLotusDateDir=`date +%Y%m%d`
      LatestLotusBinFile="/opt/raid0/.latest-version/${LatestLotusDateDir}/lotus"
      [ ! -f "$LatestLotusBinFile" ] && echo "${LatestLotusBinFile}不存在，请检查。" && exit
      cd /opt/raid0/.latest-version/${LatestLotusDateDir} && md5sum lotus > /tmp/Md5-lotus.txt
      CPUModel=$(lscpu |egrep  -w 'Intel|AMD' |awk '{if($0~"Intel"){print $(NF-6)} else if($3 == "AMD"){print $3}else{print ""}}' |awk -F'(' '/Intel|AMD/{print $1}')
      SystemInfo="/tmp/systeminfo"
      lsb_release -a &> $SystemInfo
      SystemName=$(awk '/Distributor/{print $NF}' $SystemInfo)
      VersionID=$(awk '/Release/{print $NF}' $SystemInfo)
      if $LatestLotusBinFile -v |grep -wiv "${CPUModel}.${SystemName}.${VersionID}" ;then
	    echo "准备要更新的版本: `$LatestLotusBinFile -v`和系统版本${SystemName}.${VersionID}或是CPU型号${CPUModel}不匹配，请检查确认"
	    exit
      fi
      #软链接的源文件如果失效了，应该清理掉已失效的软链接文件，不然cp会报错。而对于是否已失效的软链接或是源文件，可以直接软链接过去强制覆盖。下面的操作先是备份源文件，然后判断清理其它目录的文件（此步骤可以直接跳过，因为软链接过去也会强制覆盖）。cd的目的是要清理掉该文件（因为失效的软链接文件，判断不起作用。所以此步骤不可或缺）
      LotusBinPathFile="$(ls  `which lotus` -l |awk '{print $NF}')"
      LotusBinPathDir=${LotusBinPathFile%/*}
      [ ! -d "$LotusBinPathDir" ] && echo "${LotusBinPathDir}不存在，请检查。" && exit
      cd $LotusBinPathDir
      if md5sum -c /tmp/Md5-lotus.txt >/dev/null ;then
             echo "`which lotus`已更新"
      else
   	     [ -f "$LotusBinPathFile" ] && echo "mv $LotusBinPathFile ${LotusBinPathFile}-`date +%Y%m%d%H%M%S`" && mv $LotusBinPathFile ${LotusBinPathFile}-`date +%Y%m%d%H%M%S`
             cd $LotusBinPathDir && rm lotus
      	     cp -a $LatestLotusBinFile $LotusBinPathFile
      fi
      LotusBinFile="$LOTUS_PATH/bin/lotus"
      LotusBinDir="$LOTUS_PATH/bin"
      [ ! -d "$LotusBinDir" ] && echo "${LotusBinDir}不存在，请检查。" && exit
      cd $LotusBinDir
      if md5sum -c /tmp/Md5-lotus.txt >/dev/null ;then
             echo "${LotusBinFile}已更新"
      else
             [ -f "$LotusBinFile" ] && rm $LotusBinFile
      	     ln -svf $LotusBinPathFile $LotusBinFile
      fi
   }
   check_lotus_version() {
	ls -l $(which lotus) /opt/*/lotus/bin/lotus
	for i in `ls -1 $(which lotus) /opt/*/lotus/bin/lotus`
	do
		$i -v 2>/dev/null |awk '{print "'${i}'"":",$0}'
	done
   }
   start_lotus() {
      [ ! -f "$LOTUS_PATH/../start_lotus.sh" ] && echo "$LOTUS_PATH/../start_lotus.sh不存在，请检查。" && exit
      while :
      do
         if ps -aux |grep -v grep |grep -w lotus |grep -wq daemon ;then
                 sleep 3s
		 continue
         else
                 echo "bash $LOTUS_PATH/../start_lotus.sh"
                 bash $LOTUS_PATH/../start_lotus.sh && echo "Lotus启动中......"
                 break
         fi
      done
   }
   menu() {
   	echo "1: 查看lotus监听的端口"
   	echo "2: 查看lotus进程"
   	echo "3: 查看lotus版本"
	echo "4: Stop lotus（建议先更新版本，再stop)"
	echo "5: Lotus版本更新(更新后，然后再启动lotus)"
	echo "6: Start lotus(lotus进程挂了，才能正常启动，不然会一直等待)"
   	echo "7: 退出脚本"
   }
   menu
   read -p "请选择:" choose
   case $choose in
   	1)
   		check_listen_port;;
   	2)
   		check_lotus_process;;
   	3)
   		check_lotus_version;;
   	4)
   		stop_lotus;;
   	5)
   		lotus_version_update;;
   	6)
   		start_lotus;;
   	7)
   		exit;;
   esac
done
