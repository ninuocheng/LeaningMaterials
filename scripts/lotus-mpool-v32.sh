#!/bin/bash
#环境变量
source /opt/raid0/profile
#脚本的路径
ScriptPath=`dirname $(readlink -f $0)`
#消息参数信息
ParameterInfo=parameterinfo
##################修改下面参数####################################
#SetGasFeecap=`lotus chain head | awk 'NR==1{print; exit}' | xargs lotus chain getblock | jq -r .ParentBaseFee`
SetGasFeecap=382206885
echo $SetGasFeecap
#################################################################
lotus mpool pending --local | awk -F '[ ,"]+' '/"\/"/||/Method/||/GasLimit/||/GasPremium/||/GasFeeCap/{print $(NF-1)}' > $ScriptPath/$ParameterInfo
while [ -s $ScriptPath/$ParameterInfo ];do
        GasLimit=`sed -n '1,1p' $ScriptPath/$ParameterInfo`
        GasFeeCap=`sed -n '2,2p' $ScriptPath/$ParameterInfo`
        GasPremium=`sed -n '3,3p' $ScriptPath/$ParameterInfo`
        Method=`sed -n '4,4p' $ScriptPath/$ParameterInfo`
        CID=`sed -n '5,5p' $ScriptPath/$ParameterInfo`
        sed -i '1,6d' $ScriptPath/$ParameterInfo
        #SetGasPremium=`echo "$GasPremium * 1.25 + 1 " |bc`
        SetGasPremium=382206885
        if [ $Method -eq 32 ];then
                if [ ${GasFeeCap} -gt ${SetGasFeecap} ];then
                        echo " 无需加价,稍休息几分钟后再试"
                        continue
                fi
                lotus mpool replace --gas-feecap ${SetGasFeecap%.*} --gas-premium ${SetGasPremium%.*} --gas-limit ${GasLimit%.*} $CID && echo "${Method}类消息，CID 为:$CID; GasFeeCap 从 ${GasFeeCap} 增加到 ${SetGasFeecap%.*},GasPremium 从 $GasPremium 增加到 ${SetGasPremium%.*}"
        else
                echo "${Method}类消息，CID 为:$CID; 无操作"
        fi
done
echo "完成........................................................................................................................................................................"
