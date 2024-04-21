#!/bin/bash
#脚本路径
ScriptsPath=`dirname $(readlink -f $0)`
echo ${ScriptsPath}
#全部扇区续期到12月31号,续期的新高度
NewExpiration=3522722
echo $NewExpiration
[ -z $NewExpiration ] && echo "--new-expiration没有给定参数值，请检查。" && exit
#批量续期
for SectorIdFile in a{11..20}
do
        [ ! -f "${ScriptsPath}/../${SectorIdFile}" ]  && echo "存储扇区ID的文件${ScriptsPath}/../${SectorIdFile} 不存在，请检查！" && continue
        wc -l "${ScriptsPath}/../${SectorIdFile}"
        lotus-miner sectors extend --really-do-it --sector-file ${ScriptsPath}/../${SectorIdFile} --new-expiration ${NewExpiration} --tolerance 0
done
