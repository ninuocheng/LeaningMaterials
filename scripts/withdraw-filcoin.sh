#!/bin/bash
#自定义的位置参数未初始化，会异常退出
set -o nounset
#返回非真的值，会异常退出
set -o errexit
#false|true被认为执行失败，会异常退出
set -o pipefail
#脚本的路径
ConfDir=`dirname $(readlink -f $0)`
echo '切记！！！发起提币操作后，需要@涛哥审批通过后，确保多签地址提币到账成功后方可执行后续的转币操作 备注：双签只需要@涛哥审批即可，多签需要同时@哈儿审批方可通过' |tee -a $ConfDir/logs
#参数文件
ParamFile=withdraw.conf
[ ! -f "${ConfDir}/${ParamFile}" ] && echo "参数文件${ConfDir}/${ParamFile}不存在，请检查。" |tee -a $ConfDir/logs && exit
#提币信息文件
WithdrawFilInfo=withdrawfil.info
awk '!/#/{print}' ${ConfDir}/${ParamFile} > ${ConfDir}/${WithdrawFilInfo}
[ ! -f "${ConfDir}/${WithdrawFilInfo}" ] && echo "提币的信息文件${ConfDir}/${WithdrawFilInfo}不存在，请检查。" |tee -a $ConfDir/logs && exit
[ ! -s "${ConfDir}/${WithdrawFilInfo}" ] && echo "提币的信息文件${ConfDir}/${WithdrawFilInfo}内容为空，请检查。" |tee -a $ConfDir/logs && exit
echo "---------------------------------------------------------------------------------------------------------------------------------------- " |tee -a $ConfDir/logs
echo "---------------------------------------------------------------------------------------------------------------------------------------- " |tee -a $ConfDir/Withdraw-Fil-Command
echo "发起提币操作的时间：$(date +%F%\t%T)" |tee -a $ConfDir/logs
echo "发起提币操作的时间：$(date +%F%\t%T)" |tee -a $ConfDir/Withdraw-Fil-Command
while read MinerID MultAddr ProvideProposerAddr IntegerBit DecimalDigit WithdrawCoin
do
     #参数个数
     FieldNub=`awk '$1 == "'${MinerID}'"{print NF}' ${ConfDir}/${WithdrawFilInfo}`
     [ "${FieldNub}" -ne 6 ] && echo "矿工：${MinerID}提币的参数文件${ConfDir}/${ParamFile}配置的参数个数有问题，请检查。" && continue
     #第五列参数的长度
     Length=`echo "${DecimalDigit}" |wc -L`
     [ "${Length}" -ne 18 ] && echo "矿工：${MinerID}提币的参数文件${ConfDir}/${ParamFile}配置的第五列参数有问题，请检查。" && continue
     #检查提币的数额前后是否一致
     InAddDe=`echo "${IntegerBit} + 0.${DecimalDigit}" |bc` || {
	      echo "矿工：${MinerID}提币的参数文件${ConfDir}/${ParamFile}配置的提币整数位${IntegerBit} + 提币小数位0.${DecimalDigit}计算出错，请检查。"
              continue
     }
     [ $(echo "${InAddDe} == ${WithdrawCoin}"|bc) -eq 0 ] && echo "矿工：${MinerID}提币的参数文件${ConfDir}/${ParamFile}配置的提币整数位${IntegerBit}+提币小数位0.${DecimalDigit}不等于提币有效数位${WithdrawCoin}，请检查。" && continue
     echo "---------------------------------------------------------------------------------------------------------------------------------------- " |tee -a $ConfDir/logs
     echo "---------------------------------------------------------------------------------------------------------------------------------------- " |tee -a $ConfDir/Withdraw-Fil-Command
     #多签发起钱包地址
     ProposerAddr=`lotus msig inspect $MultAddr |awk '/'$ProvideProposerAddr'/ {print $1}'`
     #ProposerAddr=`lotus msig inspect $MultAddr |awk '/'$ProvideProposerAddr'/ {print $2}'`
     #验证提供的多签发起人地址是否正确，安全起见
     if [ "$ProposerAddr" != "$ProvideProposerAddr" ];then
	  echo "矿工：${MinerID}提币到多签${MultAddr}的发起钱包地址${ProposerAddr}和提供的${ProvideProposerAddr}不一致，请检查。" |tee -a $ConfDir/logs
          continue
     fi
     #检查多签发起钱包地址的余额币
     [ $(echo "$(lotus wallet balance ${ProposerAddr} |awk '{print $1}') < 0.5"|bc) -eq 1 ] && echo "矿工：${MinerID}提币到多签${MultAddr}的发起钱包地址${ProposerAddr}的币不足0.5 FIL，请检查。" && continue
     #参与多签地址的签名数量
     ProposerThreshold=`lotus msig inspect $MultAddr |awk '/Threshold:/ {print $2}'`
     #[ ${ProposerThreshold} -ge 3 ] && echo "矿工${MinerID}提币到多签${MultAddr}除了@涛哥审批，还需要@哈尔通知到客户走审批流程"
     [ ${ProposerThreshold} -ge 3 ] && echo -e "\033[47;30m矿工${MinerID}提币到多签${MultAddr}除了@涛哥审批，还需要@哈尔通知到客户走审批流程\033[0m"
     #执行返回的参数
     Params=`lotus chain encode params --encoding=hex ${MinerID} 16 {\"amountRequested\":\"${IntegerBit}${DecimalDigit}\"}` || {
	     echo "矿工${MinerID}提币到多签${MultAddr}执行提币前返回的参数出问题，请检查。"
             continue
     }
     [ -z "${Params}" ] && echo "矿工${MinerID}提币到多签${MultAddr}执行提币前返回的参数为空，请检查。" && continue
     #打印参数文件中的相关参数值
     echo '矿工'${MinerID}'提币到多签'${MultAddr}'的发起提币钱包地址'${ProposerAddr}'的参数信息如下：' |tee -a $ConfDir/logs
     echo '矿工ID： '$MinerID'   提币数量：'${WithdrawCoin}'' |tee -a $ConfDir/logs
     echo '多签的发起地址：'$ProposerAddr' 多签地址：'$MultAddr' 矿工ID： '$MinerID'  返回的参数：'$Params'' |tee -a $ConfDir/logs
     echo "---------------------------------------------------------------------------------------------------------------------------------------- " |tee -a $ConfDir/logs
     echo "---------------------------------------------------------------------------------------------------------------------------------------- " |tee -a $ConfDir/Withdraw-Fil-Command
     #多签的发起钱包地址发起提币操作
     lotus msig propose --from=${ProposerAddr} ${MultAddr} ${MinerID} 0 16 ${Params} && {
         echo "矿工${MinerID}已成功发起提币操作" |tee -a $ConfDir/logs
         sleep 3
      }||{
         echo "矿工${MinerID}发起提币操作失败，请检查！" |tee -a $ConfDir/logs
      } &
     #打印发起提币操作的执行命令
     echo '矿工'$MinerID'提币到多签'${MultAddr}'的发起提币钱包地址'${ProposerAddr}'的操作命令如下：' |tee -a $ConfDir/Withdraw-Fil-Command
     echo 'lotus chain encode params --encoding=hex '${MinerID}' 16 {\"amountRequested\":\"'${IntegerBit}''${DecimalDigit}'\"}' |tee -a $ConfDir/Withdraw-Fil-Command
     echo 'lotus msig propose --from='${ProposerAddr}' '${MultAddr}' '${MinerID}' 0 16 '${Params}'' |tee -a $ConfDir/Withdraw-Fil-Command
     echo "---------------------------------------------------------------------------------------------------------------------------------------- " |tee -a $ConfDir/logs
     echo "---------------------------------------------------------------------------------------------------------------------------------------- " |tee -a $ConfDir/Withdraw-Fil-Command
done < $ConfDir/$WithdrawFilInfo
wait
