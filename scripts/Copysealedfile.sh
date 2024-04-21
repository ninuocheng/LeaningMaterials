#!/bin/bash
#源路径
#SrcDir="/export"
SrcDir="/mnt/172.25.4.16/export"
#目标路径
#DstDir="/mnt/172.25.4.18/export"
DstDir="/export"
#同步sealed日志文件
SealedLogFile=/root/.gzc/copysealed.Log
#同步cache日志文件
CacheLogFile=/root/.gzc/copycache.Log
#while循环
while :
do
   #定义计数的变量
   n=0
   m=0
   echo "$(date +%F%\t%T)" |tee -a $SealedLogFile
   echo "$(date +%F%\t%T)" >> $CacheLogFile
   #源路径的sealed文件数量
   SrcSealedFileNub=`ls $SrcDir/sealed |wc -l`
   #源路径的cache目录数量
   SrcCacheDirNub=`ls $SrcDir/cache |wc -l`
   #目标路径的sealed文件数量
   DstSealedFileNub=`ls $DstDir/sealed |wc -l`
   #目标路径的cache目录数量
   DstCacheDirNub=`ls $DstDir/cache |wc -l`
   [ "$SrcSealedFileNub" -eq "$DstSealedFileNub" -a "$SrcCacheDirNub" -eq "$DstCacheDirNub" ] && echo "源路径$SrcDir/sealed的sealed文件和$DstDir/cache的cache目录数量已同步完成，请再检查一遍。" && exit 1
   echo "源路径$SrcDir/sealed下的文件数量: $SrcSealedFileNub" |tee -a $SealedLogFile
   #echo "源路径$SrcDir/cache下的目录数量: $SrcCacheDirNub" |tee -a $CacheLogFile
   echo "目标路径$DstDir/sealed下的文件数量: $DstSealedFileNub" |tee -a $SealedLogFile
   #echo "目标路径$DstDir/cache下的目录数量: $DstCacheDirNub" |tee -a $CacheLogFile
   #遍历源路径sealed目录下的文件
   for sealedfile in `ls $SrcDir/sealed`
   do
	#检查同步的源路径下的sealed文件是否存在
	[ ! -f $SrcDir/sealed/$sealedfile ] && echo "源路径文件$SrcDir/sealed/${sealedfile}不存在，请检查。" && exit 2
	#检查目标路径的sealed目录是否存在
	[ ! -d $DstDir/sealed ] && echo "目标路径$DstDir/sealed不存在，请检查。" && exit 3
	#同步sealed下的文件
	let n++
	echo "第${n}个: cp -au $SrcDir/sealed/$sealedfile $DstDir/sealed/" |tee -a $SealedLogFile
        cp -au $SrcDir/sealed/$sealedfile $DstDir/sealed/ &
	#检查同步的源路径下的cache目录是否存在
	#[ ! -d $SrcDir/cache/$sealedfile ] && echo "源路径目录$SrcDir/cache/${sealedfile}不存在，请检查。" && exit 4
	#检查目标路径的cache目录是否存在
	#[ ! -d $DstDir/cache ] && echo "目标路径$DstDir/cache不存在，请检查。" && exit 5
	#同步cache下的目录
	#let m++
	#echo "第${m}个: cp -au $SrcDir/cache/$sealedfile  $DstDir/cache/" |tee -a $CacheLogFile
        #cp -au $SrcDir/cache/$sealedfile  $DstDir/cache/ &
	while [ `pgrep -a cp |grep -wc sealed` -gt 6 ]
        do
            sleep 120s
        done
   done
   sleep 180s
done
