#!/bin/bash
export PATH=${PATH}:/usr/local/bin
while :
do
   check_listen_port() {
      netstat -atnlp |grep -w "1234"
   }
   stop_lotus() {
      #主目录的关键字,比如raid0 lotus,如果不指定参数，默认是raid0
      read -p "请输入要停掉的程序关键字:(如果不指定，默认是raid0,请谨慎操作)" stopkey
      [ -z "${stopkey}" ] && stopkey="raid0"
      unset LOTUS_PATH LOTUS_MINER_PATH
      unset FULLNODE_API_INFO MINER_API_INFO
      [ ! -f "/opt/${stopkey}/profile" ] && echo "/opt/${stopkey}/profile不存在，请检查。" && exit
      which lotus > /dev/null && [ $? -ne 0 ] && echo "lotus程序不存在，请检查。" && exit
      echo "Lotus的API信息:"
      lotus auth api-info --perm admin && lotus sync wait
      LotusProcess=$(pgrep -a lotus |awk '/daemon/{print $1}')
      LotusListenPort=$(netstat -tnlp |awk -F':|[ ]*' '/'${LotusProcess}'/{print $5}' |awk '/1234/{print}')
      if ps -aux |grep -v grep |grep -w |grep -w lotus |grep daemon ;then
         if lotus auth api-info --perm admin |grep -w "$LotusListenPort" ;then
            echo "lotus daemon stop"
            lotus daemon stop && echo "lotus程序停止中......"
         fi
      else
	    echo "lotus已停止掉"
      fi
   }
   check_lotus_process() {
      pgrep -a lotus
   }
   lotus_version_update() {
      LatestlotusDateDir=`date +%Y%m%d`
      LatestLotusBinFile="/opt/raid0/.latest-version/${LatestLotusDateDir}/lotus"
      [ ! -f "$LatestLotusBinFile" ] && echo "${LatestLotusBinFile}不存在，请检查。" && exit
      cd /opt/raid0/.latest-version/${LatestLotusDateDir} && md5sum lotus > /tmp/Md5-lotus.txt
      CPUModel=$(lscpu |egrep  -w 'Intel|AMD' |awk '{if($0~"Intel"){print $(NF-6)} else if($3 == "AMD"){print $3}else{print ""}}' |awk -F'(' '/Intel|AMD/{print $1}')
      SystemInfo="/tmp/systeminfo"
      lsb_release -a > $SystemInfo
      SystemName=$(awk '/Distributor/{print $NF}' $SystemInfo)
      VersionID=$(awk '/Release/{print $NF}' $SystemInfo)
      if $LatestLotusBinFile -v |grep -wiv "${CPUModel}.${SystemName}.${VersionID}" ;then
	    echo "准备要更新的版本: `$LatestLotusBinFile -v`和系统版本${SystemName}.${VersionID}或是CPU型号${CPUModel}不匹配，请检查确认"
	    exit
      fi
      #主目录的关键字,比如raid0 lotus
      read -p "请输入要停掉的程序关键字:(如果不指定，默认是raid0，请谨慎操作)" updatekey
      [ -z "${updatekey}" ] && updatekey="raid0"
      while :
      do
            if ps -aux |grep -v grep |grep -w lotus |grep daemon 2>/dev/null ;then
                    sleep 1s
                    continue
            else
      	         #软链接的源文件如果失效了，应该清理掉已失效的软链接文件，不然cp会报错。而对于是否已失效的软链接或是源文件，可以直接软链接过去强制覆盖。下面的操作先是备份源文件，然后判断清理其它目录的文件（此步骤可以直接跳过，因为软链接过去也会强制覆盖）。cd的目的是要清理掉该文件（因为失效的软链接文件，判断不起作用。所以此步骤不可或缺）
   	         LotusBinPathFile="$(ls  `which lotus` -l |awk '{print $NF}')"
		 LotusBinPathDir=${LotusBinPathFile%/*}
                 [ ! -d "$LotusBinPathDir" ] && echo "${LotusBinPathDir}不存在，请检查。" && break
                 cd $LotusBinPathDir
                 if md5sum -c /tmp/Md5-lotus.txt >/dev/null ;then
                      echo "${LotusBinPathFile}已更新"
	         else
   	              [ -f "$LotusBinPathFile" ] && echo "mv $LotusBinPathFile ${LotusBinPathFile}-`date +%Y%m%d%H%M%S`" && mv $LotusBinPathFile ${LotusBinPathFile}-`date +%Y%m%d%H%M%S`
                      cd $LotusBinPathDir && rm lotus
      	              cp -a $LatestLotusBinFile $LotusBinPathFile
		 fi
		 LotusBinFile="/opt/${updatekey}/lotus/bin/lotus"
		 LotusBinDir=${LotusBinFile%/*}
                 [ ! -d "$LotusBinDir" ] && echo "${LotusBinDir}不存在，请检查。" && break
		 cd $LotusBinDir
		 if md5sum -c /tmp/Md5-lotus.txt >/dev/null ;then
			 echo "${LotusBinFile}已更新"
		 else
		      [ -f "$LotusBinFile" ] && rm $LotusBinFile
      	              ln -svf $LotusBinPathFile $LotusBinFile
		 fi
            fi
	    break
      done
   }
   check_lotus_version() {
	ls -l $(which lotus) /opt/*/lotus/bin/lotus
	for i in `ls -1 $(which lotus) /opt/*/lotus/bin/lotus`
	do
		$i -v 2>/dev/null |awk '{print "'${i}'"":",$0}'
	done
   }
   start_lotus() {
      #主目录的关键字,比如raid0 lotus,如果不指定参数，默认是raid0
      read -p "请输入要启动的lotus程序关键字:(如果不指定，默认是raid0,请谨慎操作)" startkey
      [ -z "${startkey}" ] && startkey="raid0"
      unset LOTUS_PATH LOTUS_MINER_PATH
      unset FULLNODE_API_INFO MINER_API_INFO
      [ ! -f "/opt/${startkey}/profile" ] && echo "/opt/${startkey}/profile不存在，请检查。" && exit
      which lotus > /dev/null && [ $? -ne 0 ] && echo "lotus程序不存在，请检查。" && exit
      echo "Lotus的API信息:"
      lotus auth api-info --perm admin && lotus sync wait
      while :
      do
         if ps -aux |grep -v grep |grep -w lotus |grep -w daemon ;then
                 sleep 1s
                 continue
         else
		 echo "source /opt/${startkey}/profile"
                 echo "bash /opt/${startkey}/start_lotus.sh"
                 source /opt/${startkey}/profile
                 bash /opt/${startkey}/start_lotusminer.sh && echo "Lotus程序启动中......"
		 break
         fi
      done
   }
   menu() {
   	echo "1: 查看lotus监听的端口"
   	echo "2: 查看lotus进程"
   	echo "3: 查看lotus版本"
	echo "4: Stop lotus"
	echo "5: Lotus版本更新"
	echo "6: Start lotus"
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
