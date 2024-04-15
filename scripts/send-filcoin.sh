#!/bin/bash
#定义的位置参数未初始化，会异常退出
set -o nounset
#返回非真的值，会异常退出
set -o errexit
#false|true被认为执行失败，会异常退出
set -o pipefail
#脚本的路径
ConfDir=`dirname $(readlink -f $0)`
#参数文件
ParamFile=send.conf
[ ! -f "${ConfDir}/${ParamFile}" ] && echo "参数文件${ConfDir}/${ParamFile}不存在，请检查。" |tee -a $ConfDir/logs && exit
#转币的信息文件
SendFilInfo=sendfil.info
awk '!/#/{print}' $ConfDir/$ParamFile > $ConfDir/$SendFilInfo
[ ! -f "${ConfDir}/${SendFilInfo}" ] && echo "转币的信息文件${ConfDir}/${SendFilInfo}不存在，请检查。" |tee -a $ConfDir/logs && exit
[ ! -s "${ConfDir}/${SendFilInfo}" ] && echo "转币的信息文件${ConfDir}/${SendFilInfo}内容为空，请检查。" |tee -a $ConfDir/logs && exit
echo "---------------------------------------------------------------------------------------------------------------------------------------- " |tee -a $ConfDir/logs
echo "---------------------------------------------------------------------------------------------------------------------------------------- " |tee -a $ConfDir/Send-Fil-Command
echo "发起转币操作的时间：$(date +%F%\t%T)" |tee -a $ConfDir/logs
echo "发起转币操作的时间：$(date +%F%\t%T)" |tee -a $ConfDir/Send-Fil-Command
while read MinerID MultAddr ProvideProposerAddr DestAddr IntegerBit DecimalDigit TransferCoin
do
     #参数个数
     FieldNub=`awk '$1 == "'${MinerID}'" && $4 == "'${DestAddr}'"{print NF}' ${ConfDir}/${SendFilInfo}`
     [ "${FieldNub}" -ne 7 ] && echo "矿工：${MinerID}转币的参数文件${ConfDir}/${ParamFile}配置的参数个数有问题，请检查。" && continue
     #第六列参数的长度
     Length=`echo "${DecimalDigit}" |wc -L`
     [ "${Length}" -ne 18 ] && echo "矿工：${MinerID}转币的参数文件${ConfDir}/${ParamFile}配置的第六列参数有问题，请检查。" && continue
     #检查转币的数额前后是否一致
     InAddDe=`echo "${IntegerBit} + 0.${DecimalDigit}" |bc` || {
	      echo "矿工：${MinerID}转币的参数文件${ConfDir}/${ParamFile}配置的转币整数位${IntegerBit} + 转币小数位0.${DecimalDigit}计算出错，请检查。"
              continue
     }
     [ $(echo "${InAddDe} == ${TransferCoin}"|bc) -eq 0 ] && echo "矿工：${MinerID}转币的参数文件${ConfDir}/${ParamFile}配置的转币整数位${IntegerBit}+转币小数位0.${DecimalDigit}不等于转币有效数位${TransferCoin}，请检查。" && continue
     echo "---------------------------------------------------------------------------------------------------------------------------------------- " |tee -a $ConfDir/logs
     echo "---------------------------------------------------------------------------------------------------------------------------------------- " |tee -a $ConfDir/Send-Fil-Command
     #多签发起钱包地址
     ProposerAddr=`lotus msig inspect $MultAddr |awk '/'$ProvideProposerAddr'/ {print $1}'`
     #ProposerAddr=`lotus msig inspect $MultAddr |awk '/'$ProvideProposerAddr'/ {print $2}'`
     #验证提供的多签发起人地址是否正确，安全起见
     if [ "$ProposerAddr" != "$ProvideProposerAddr" ];then
          echo "矿工：${MinerID}的多签${MultAddr}的发起转币钱包地址${ProposerAddr}和提供的${ProvideProposerAddr}不一致，请检查。" |tee -a $ConfDir/logs
          exit
     fi
     #检查矿工提币到多签的币是否到账
     [ $(echo "$(lotus wallet balance ${MultAddr} |awk '{print $1}') < ${TransferCoin}"|bc) -eq 1 ] && echo "矿工：${MinerID}提币到多签${MultAddr}的${TransferCoin} FIL没有到账，请检查。" && continue
     #检查多签发起钱包地址的余额币
     [ $(echo "$(lotus wallet balance ${ProposerAddr} |awk '{print $1}') < 0.5"|bc) -eq 1 ] && echo "矿工：${MinerID}的多签${MultAddr}的发起转币钱包地址${ProposerAddr}的币不足0.5 FIL，请检查。" && continue
     #参与多签地址的签名数量
     ProposerThreshold=`lotus msig inspect $MultAddr |awk '/Threshold:/ {print $2}'`
     #[ ${ProposerThreshold} -ge 3 ] && echo "矿工${MinerID}的多签${MultAddr}的发起签名钱包地址${ProposerAddr}转币到目标地址${DestAddr}除了@涛哥审批，还需要@哈尔通知到客户走审批流程"
     [ ${ProposerThreshold} -ge 3 ] && echo -e "\033[47;30m矿工${MinerID}的多签${MultAddr}的发起签名钱包地址${ProposerAddr}转币到目标地址${DestAddr}除了@涛哥审批，还需要@哈尔通知到客户走审批流程\033[0m"
     #执行返回的参数
     Params=`lotus chain encode params --encoding=hex ${MultAddr} 2 "{\"To\":\"${DestAddr}\" ,\"Value\":\"${IntegerBit}${DecimalDigit}\" , \"Method\":2 , \"Params\":\"null\"}"` || {
	     echo "矿工：${MinerID}的多签${MultAddr}执行转币前返回的参数出问题，请检查。"
             continue
     }
     [ -z "${Params}" ] && echo "矿工：${MinerID}的多签${MultAddr}执行转币前返回的参数为空，请检查。" && continue
     #打印参数文件中的相关参数值
     echo '矿工'${MinerID}'的多签'${MultAddr}'的发起钱包地址'${ProposerAddr}'转币到目标地址'${DestAddr}'的参数信息如下：' |tee -a $ConfDir/logs
     echo '多签地址：'${MultAddr}' 目标地址：'${DestAddr}' 转币数量：'${TransferCoin}'' |tee -a $ConfDir/logs
     echo '多签的发起地址：'${ProposerAddr}' 多签地址：'${MultAddr}' 目标地址：'${DestAddr}' 转币数量：'${TransferCoin}' 返回的参数：'${Params}'' |tee -a $ConfDir/logs

     #测试之用
     #echo 'lotus chain encode params --encoding=hex '${MultAddr}' 2 "{\"To\":\"'${DestAddr}'\" ,\"Value\":\"'${IntegerBit}''${DecimalDigit}'\" , \"Method\":2 , \"Params\":\"null\"}"'
     #echo 'lotus msig propose --from '${ProposerAddr}' '${MultAddr}' '${DestAddr}' '${TransferCoin}' 0 '${Params}''
     #continue

     #多签的发起钱包地址发起转币操作
     lotus msig propose --from ${ProposerAddr} ${MultAddr} ${DestAddr} ${TransferCoin} 0 ${Params}  && {
              echo "矿工${MinerID}已成功发起转币操作" |tee -a $ConfDir/logs
              sleep 3
     }||{
              echo "矿工${MinerID}发起转币操作失败，请检查！" |tee -a $ConfDir/logs
     } &
     #打印发起转币操作的执行命令
     echo "---------------------------------------------------------------------------------------------------------------------------------------- " |tee -a $ConfDir/logs
     echo "---------------------------------------------------------------------------------------------------------------------------------------- " |tee -a $ConfDir/Send-Fil-Command
     echo '矿工'${MinerID}'的多签'${MultAddr}'的发起钱包地址'${ProposerAddr}'转币到目标钱包地址'${DestAddr}'的操作命令如下：' |tee -a $ConfDir/Send-Fil-Command
     echo 'lotus chain encode params --encoding=hex '${MultAddr}' 2 "{\"To\":\"'${DestAddr}'\" ,\"Value\":\"'${IntegerBit}''${DecimalDigit}'\" , \"Method\":2 , \"Params\":\"null\"}"' |tee -a $ConfDir/Send-Fil-Command
     echo 'lotus msig propose --from '${ProposerAddr}' '${MultAddr}' '${DestAddr}' '${TransferCoin}' 0 '${Params}'' |tee -a $ConfDir/Send-Fil-Command
     echo "---------------------------------------------------------------------------------------------------------------------------------------- " |tee -a $ConfDir/logs
     echo "---------------------------------------------------------------------------------------------------------------------------------------- " |tee -a $ConfDir/Send-Fil-Command
done < $ConfDir/$SendFilInfo
wait
