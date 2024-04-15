#!/bin/bash
Current=`date +%Y%m%d`
UpdateLotusVersion=/root/.gzc/lotus
UpdateMinerVersion=/root/.gzc/lotus-miner
LotusPath=`which lotus`
Lotus=/opt/raid0/lotus/bin/lotus
MinerPath=`which lotus-miner`
MinerSealing=/opt/raid0/lotusminer-sealing/lotusminer/bin/lotus-miner
MinerWindow=/opt/raid0/lotusminer-window/lotusminer/bin/lotus-miner
MinerWinning=/opt/raid0/lotusminer-winning/lotusminer/bin/lotus-miner
[ -f $LotusPath ] && mv $LotusPath ${LotusPath}-$Current && cp -au $UpdateLotusVersion $LotusPath
[ -f $Lotus ] && mv $Lotus ${Lotus}-$Current && ln -sv $LotusPath $Lotus
[ -f $MinerPath ] && mv $MinerPath ${MinerPath}-$Current && cp -au $UpdateMinerVersion $MinerPath
[ -f $MinerSealing ] && mv $MinerSealing ${MinerSealing}-$Current && ln -sv $MinerPath $MinerSealing
[ -f $MinerWindow ] && mv $MinerWindow ${MinerWindow}-$Current && ln -sv $MinerPath $MinerWindow
[ -f $MinerWinning ]&& mv  $MinerWinning ${MinerWinning}-$Current && ln -sv $MinerPath $MinerWinning
