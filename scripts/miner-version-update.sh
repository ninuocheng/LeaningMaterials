#!/bin/bash
unset LOTUS_PATH LOTUS_MINER_PATH
unset FULLNODE_API_INFO MINER_API_INFO
export PATH=${PATH}:/usr/local/bin
which lotus > /dev/null && [ $? -ne 0 ] && echo "`which lotus`不存在，请检查。" && exit
which lotus-miner > /dev/null && [ $? -ne 0 ] && echo "`which lotus-miner`不存在，请检查。" && exit
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
      netstat -atnlp |grep -w "lotus-miner"
   }
   stop_miner() {
      #主目录的关键字,比如window winning sealing,如果不指定参数，默认是sealing
      read -p "请输入要停掉的程序关键字:(如果不指定，默认是sealing,请谨慎操作)" stopkey
      [ -z "${stopkey}" ] && stopkey="sealing"
      [ ! -f "/opt/raid0/lotusminer-${stopkey}/profile" ] && echo "/opt/raid0/lotusminer-${stopkey}/profile不存在，请检查。" && exit
      [ -f "$LOTUS_PATH/../profile" ] && source $LOTUS_PATH/../profile
      source /opt/raid0/lotusminer-${stopkey}/profile
      lotus auth api-info --perm admin && lotus sync wait
      lotus-miner auth api-info --perm admin
      MinerProcess=$(pgrep -a lotus-miner |awk '/lotusminer-'${stopkey}'/{print $1}')
      MinerListenPort=$(netstat -tnlp |awk -F':|[ ]*' '/'${MinerProcess}'/{print $5}')
      if ps -aux |grep -v grep |grep -w "lotusminer-${stopkey}" ;then
         if lotus-miner auth api-info --perm admin |grep -w "$MinerListenPort" ;then
            echo "lotus-miner stop"
            lotus-miner stop && echo "lotusminer-${stopkey}停止中......"
         fi
      else
	    echo "lotusminer-${stopkey}已停止掉"
      fi
   }
   check_miner_process() {
      pgrep -a lotus
   }
   miner_version_update() {
      LatestMinerDateDir=`date +%Y%m%d`
      LatestMinerBinFile="/opt/raid0/.latest-version/${LatestMinerDateDir}/lotus-miner"
      [ ! -f "$LatestMinerBinFile" ] && echo "${LatestMinerBinFile}不存在，请检查。" && exit
      cd /opt/raid0/.latest-version/${LatestMinerDateDir} && md5sum lotus-miner > /tmp/Md5-lotus-miner.txt
      CPUModel=$(lscpu |egrep  -w 'Intel|AMD' |awk '{if($0~"Intel"){print $(NF-6)} else if($3 == "AMD"){print $3}else{print ""}}' |awk -F'(' '/Intel|AMD/{print $1}')
      SystemInfo="/tmp/systeminfo"
      lsb_release -a &> $SystemInfo
      SystemName=$(awk '/Distributor/{print $NF}' $SystemInfo)
      VersionID=$(awk '/Release/{print $NF}' $SystemInfo)
      if $LatestMinerBinFile -v |grep -wiv "${CPUModel}.${SystemName}.${VersionID}" ;then
	    echo "准备要更新的版本: `$LatestMinerBinFile -v`和系统版本${SystemName}.${VersionID}或是CPU型号${CPUModel}不匹配，请检查确认"
	    exit
      fi
      #主目录的关键字,比如window winning sealing
      read -p "请输入要停掉的程序关键字:(如果不指定，默认是所有，请谨慎操作)" updatekey
      #软链接的源文件如果失效了，应该清理掉已失效的软链接文件，不然cp会报错。而对于是否已失效的软链接或是源文件，可以直接软链接过去强制覆盖。下面的操作先是备份源文件，然后判断清理其它目录的文件（此步骤可以直接跳过，因为软链接过去也会强制覆盖）。cd的目的是要清理掉该文件（因为失效的软链接文件，判断不起作用。所以此步骤不可或缺）
      MinerBinPathFile="$(ls  `which lotus-miner` -l |awk '{print $NF}')"
      MinerBinPathDir=${MinerBinPathFile%/*}
      [ ! -d "$MinerBinPathDir" ] && echo "${MinerBinPathDir}不存在，请检查。" && break
      cd $MinerBinPathDir
      if md5sum -c /tmp/Md5-lotus-miner.txt >/dev/null ;then
              echo "`which lotus-miner`已更新"
      else
   	      [ -f "$MinerBinPathFile" ] && echo "mv $MinerBinPathFile ${MinerBinPathFile}-`date +%Y%m%d%H%M%S`" && mv $MinerBinPathFile ${MinerBinPathFile}-`date +%Y%m%d%H%M%S`
              cd $MinerBinPathDir && rm lotus-miner
              cp -a $LatestMinerBinFile $MinerBinPathFile
      fi
      if [ -z "${updatekey}" ];then
	      for i in $(ls -1 /opt/raid0/lotusminer-*/lotusminer/bin/lotus-miner 2>/dev/null)
	      do
		      MinerBinDir=${i%/*}
                      [ -d "$MinerBinDir" ] && cd $MinerBinDir || continue
                      if md5sum -c /tmp/Md5-lotus-miner.txt >/dev/null ;then
			     echo "${i}已更新"
			     continue
                      else
                             [ -f "$i" ] && rm $i
                             ln -svf $MinerBinPathFile $i
                      fi
	      done
      else
	      MinerBinFile="/opt/raid0/lotusminer-${updatekey}/lotusminer/bin/lotus-miner"
              MinerBinDir=${MinerBinFile%/*}
	      [ ! -d "$MinerBinDir" ] && echo "${MinerBinDir}不存在，请检查。" && break
	      cd $MinerBinDir
	      if md5sum -c /tmp/Md5-lotus-miner.txt >/dev/null ;then
 		      echo "${MinerBinFile}已更新"
       	      else
	      	      [ -f "$MinerBinFile" ] && rm $MinerBinFile
 	              ln -svf $MinerBinPathFile $MinerBinFile
    	      fi
      fi
   }
   check_miner_version() {
	ls -l $(which lotus-miner) /opt/raid0/lotusminer-*/lotusminer/bin/lotus-miner
	for i in `ls -1 $(which lotus-miner) /opt/raid0/lotusminer-*/lotusminer/bin/lotus-miner`
	do
		$i -v 2>/dev/null |awk '{print "'${i}'"":",$0}'
	done
   }
   start_miner() {
      #主目录的关键字,比如window winning sealing,如果不指定参数，默认是sealing
      read -p "请输入要启动的miner程序关键字:(如果不指定，默认是sealing,请谨慎操作)" startkey
      [ -z "${startkey}" ] && startkey="sealing"
      [ ! -f "/opt/raid0/lotusminer-${startkey}/profile" ] && echo "/opt/raid0/lotusminer-${startkey}/profile不存在，请检查。" && exit
      [ -f "$LOTUS_PATH/../profile" ] && source $LOTUS_PATH/../profile
      while :
      do
         if ps -aux |grep -v grep |grep -wq "lotusminer-${startkey}" ;then
                 sleep 3s
                 continue
         else
                 echo "bash /opt/raid0/lotusminer-${startkey}/start_lotusminer.sh"
                 bash /opt/raid0/lotusminer-${startkey}/start_lotusminer.sh && echo "Lotusminer-${startkey}启动中......"
		 break
         fi
      done
   }
   menu() {
   	echo "1: 查看miner监听的端口"
   	echo "2: 查看miner进程"
   	echo "3: 查看miner版本"
	echo "4: Stop miner(建议先停调度，再停抽查（要留充足的时间，为保证下一个抽查的窗口正常上链，最后停爆块)"
	echo "5: Miner版本更新(建议先更新版本，再stop)"
	echo "6: Start miner(建议先启爆块，再启调度，最后是启动抽查的时候，视抽查的时间开始启动，否则可能会出现抽查重做的问题，会拖慢抽查的时间导致不能正常上链。尤其是云库这样的大节点会出现窗口重做的现象，请谨慎操作)"
   	echo "7: 退出脚本"
   }
   menu
   read -p "请选择:" choose
   case $choose in
   	1)
   		check_listen_port;;
   	2)
   		check_miner_process;;
   	3)
   		check_miner_version;;
   	4)
   		stop_miner;;
   	5)
   		miner_version_update;;
   	6)
   		start_miner;;
   	7)
   		exit;;
   esac
done
