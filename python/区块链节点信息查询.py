import json
import sys
import time
import urllib.request

def main():
    while True:
        menu()
        try:
            choice = int(input('请选择:'))
        except:
            print('输入无效，请重新选择：')
        else:
            if choice == 0:
                exit()
            elif choice == 1:
                burn()
            elif choice == 2:
                message()
            elif choice == 3:
                MinerAcountView()
            else:
                print('输入有误，请重新选择：')
def menu():
    print('区块链'.center(30,'='))
    print('功能菜单'.center(28,'-'))
    print('0.退出,1.统计节点罚币,2.节点消息上链的gas消耗,3.节点账户概览')
def parameter():
    from datetime import date
    filename = 'parameters'  # 参数文件
    with open(filename, mode='r', encoding='utf-8') as fp:
        content = fp.read()
    parameter = dict(eval(content))
    for item in parameter:
        minerID = parameter['miner'] # 节点列表
        days = parameter['days']  # 天数
        pageNum = parameter['pages']  # 页码数
        method = parameter['method'] # 消息类型
    dateNow = date.today()
    return minerID,days,pageNum,method,dateNow
def burn():
    returnValue = parameter() # 函数的多个返回值是一个元组
    minerID = returnValue[0]
    days = returnValue[1]
    pageNum = returnValue[2]
    dateNow = returnValue[4]
    for miner in minerID:
        Sum = 0
        miner = miner.replace('\n','')
        print(miner)
        for i in range(days,1):
            import datetime
            checkDate = dateNow + datetime.timedelta(days=i)
            from datetime import datetime
            SingleDaySum = 0
            for page in range(pageNum):
                url = f'https://filfox.info/api/v1/address/{miner}/transfers?pageSize=20&page={page}&type=burn' # burn表示销毁的url
                headers = {
                    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36'
                }
                req = urllib.request.Request(url=url,headers=headers)
                while True:
                    try:
                        with urllib.request.urlopen(req) as response:
                            content = json.load(response)
                    except:
                        print(f'{url}访问异常，请耐心等待片刻...')
                        time.sleep(5)
                        continue
                    else:
                        break
                data = content['transfers']
                for item in data:
                    timestamp = item['timestamp']
                    value = item['value']
                    value = int(value) / (10**18)
                    message = item.get('message')
                    dateTime = datetime.fromtimestamp(timestamp)
                    date = str(dateTime.date())
                    Time = str(dateTime).split(' ')[1]
                    if str(checkDate) == date:
                        if str(message) == 'None':
                            value = float('{0}'.format(value))
                            SingleDaySum += value
                            print('{0} 销毁 {1:f} FIL'.format(Time,value))
            if SingleDaySum:
                print('{0} 单日累计销毁 {1:f} FIL'.format(checkDate,SingleDaySum))
                Sum += SingleDaySum
        print('总计销毁: {0:f} FIL'.format(Sum))
def message():
    returnValue = parameter()
    minerID = returnValue[0]
    days = returnValue[1]
    pageNum = returnValue[2]
    messageType = returnValue[3]
    dateNow = returnValue[4]
    for miner in minerID:
        Sum = 0
        miner = miner.replace('\n', '')
        for i in range(days, 1):
            import datetime
            checkDate = dateNow + datetime.timedelta(days=i)
            from datetime import datetime
            SingleDaySum = 0
            for page in range(1,pageNum+1):
                url = 'https://api.filutils.com/api/v2/actor/message'
                headers = {
                    'content-type': 'application/json;charset=UTF-8',
                    'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36'
                }
                data = {
                    'address': miner,
                    'method': "",
                    'pageIndex': page,
                    'pageSize': 20
                }
                data = json.dumps(data).encode('utf-8')
                req = urllib.request.Request(url=url,headers=headers,data=data)
                while True:
                    try:
                        with urllib.request.urlopen(req) as response:
                            content = json.load(response)
                    except:
                        print(f'{url}访问异常，请耐心等待...')
                        time.sleep(3)
                        continue
                    else:
                        break
                cid_lst = content['data']
                for item in cid_lst:
                    cid = item['cid']
                    method = item.get('method')
                    if method == messageType:
                        url = f'https://api.filutils.com/api/v2/message/{cid}'
                        headers = {
                            'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36'
                        }
                        req = urllib.request.Request(url=url,headers=headers)
                        while True:
                            try:
                                with urllib.request.urlopen(req) as response:
                                    content = json.load(response)
                            except:
                                print(f'{url}访问异常，请耐心等待片刻...')
                                time.sleep(3)
                                continue
                            else:
                                break
                        timeDate = content['data']['time']
                        Date = timeDate.split(' ')[0]
                        Time = timeDate.split(' ')[1]
                        if str(checkDate) == Date:
                            minerTip = content['data']['minerTip']
                            feeValue = minerTip.split(' ')[0]
                            feeUnit = minerTip.split(' ')[1]
                            totalBurnFee = content['data']['totalBurnFee']
                            totalBurnValue = totalBurnFee.split(' ')[0]
                            totalBurnUnit = totalBurnFee.split(' ')[1]
                            if feeUnit == 'nanoFIL':
                                feeValue = str(feeValue).replace(',','')
                                SingleDaySum += float(feeValue)
                            elif feeUnit == 'FIL':
                                feeValue1 = float(feeValue)*(10**9)
                                SingleDaySum += feeValue1
                            if totalBurnUnit == 'nanoFIL':
                                totalBurnValue = str(totalBurnValue).replace(',','')
                                SingleDaySum += float(totalBurnValue)
                            elif totalBurnUnit == 'FIL':
                                totalBurnValue1 = float(totalBurnValue)*(10**9)
                                SingleDaySum += totalBurnValue1
                            print('{0} 节点手续费: {1:,} {2} 销毁手续费: {3:,} {4}'.format(Time,float(feeValue),feeUnit,float(totalBurnValue),totalBurnUnit))
            if SingleDaySum:
                print('{0} 单日累计消耗: {1:,.18f} FIL'.format(checkDate,SingleDaySum/(10**9)))
                Sum += SingleDaySum
        print('{0} 总计消耗: {1:,.18f} FIL'.format(miner,Sum/(10**9)))
def MinerAcountView():
    returnValue = parameter()  # 函数的多个返回值是一个元组
    minerID = returnValue[0]
    for minerID in minerID:
        url = f'https://filfox.info/api/v1/address/{minerID}'
        headers = {
            'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36'
        }
        req = urllib.request.Request(url=url, headers=headers)
        while True:
            try:
                with urllib.request.urlopen(req) as response:
                    content = json.load(response)
                # print(content)
            except:
                print(f'{url}访问异常,请耐心等待片刻...')
                continue
            else:
                break
        robust = content['robust']
        robustBalance = int(content['balance']) / (10 ** 18)
        owner = content['miner']['owner']['address']
        ownerBalance = int(content['miner']['owner']['balance']) / (10 ** 18)
        worker = content['miner']['worker']['address']
        workerBalance = int(content['miner']['worker']['balance']) / (10 ** 18)
        beneficiary = content['miner']['beneficiary']['address']
        beneficiaryBalance = int(content['miner']['beneficiary']['balance']) / (10 ** 18)
        controlAddresses = content['miner']['controlAddresses']
        peerId = content['miner']['peerId']
        multiAddresses = content['miner']['multiAddresses']
        rawBytePower = content['miner']['rawBytePower']
        qualityAdjPower = content['miner']['qualityAdjPower']
        rawBytePower = int(rawBytePower) / (1024 ** 5)
        qualityAdjPower = int(qualityAdjPower) / (1024 ** 5)
        networkRawBytePower = int(content['miner']['networkRawBytePower']) / (1024 ** 6)
        networkQualityAdjPower = int(content['miner']['networkQualityAdjPower']) / (1024 ** 6)
        live = content['miner']['sectors']['live']
        active = content['miner']['sectors']['active']
        faulty = content['miner']['sectors']['faulty']
        recovering = content['miner']['sectors']['recovering']
        preCommitDeposits = content['miner']['preCommitDeposits']
        vestingFunds = int(content['miner']['vestingFunds']) / (10 ** 18)
        initialPledgeRequirement = int(content['miner']['initialPledgeRequirement']) / (10 ** 18)
        availableBalance = int(content['miner']['availableBalance']) / (10 ** 18)
        sectorPledgeBalance = int(content['miner']['sectorPledgeBalance']) / (10 ** 18)
        pledgeBalance = int(content['miner']['pledgeBalance']) / (10 ** 18)
        print(f'{minerID}')
        print('账户地址: {0},余额: {1:,} FIL'.format(robust, robustBalance))
        print('Owner: {0},余额: {1} FIL\nWorker: {2},余额: {3} FIL'.format(owner, ownerBalance, worker, workerBalance))
        print('受益人: {0},余额: {1} FIL'.format(beneficiary, beneficiaryBalance))
        for i in range(len(controlAddresses)):
            controlAddr = controlAddresses[i]['address']
            controlAddrBalance = int(controlAddresses[i]['balance']) / (10 ** 18)
            print('control-{0}: {1},余额: {2} FIL'.format(i, controlAddr, controlAddrBalance))
        print(f'peerId: {peerId}')
        for item in multiAddresses:
            print(f'multiAddresses: {item}')
        print('原值算力: {0:.2f} PiB'.format(rawBytePower))
        print('有效算力: {0:.2f} PiB'.format(qualityAdjPower))
        print('全网原值算力: {0:.2f} EiB'.format(networkRawBytePower))
        print('全网有效算力: {0:.2f} EiB'.format(networkQualityAdjPower))
        print(f'{live} 存活, {active} 有效, {faulty} 错误, {recovering} 恢复中')
        print('preCommitDeposits: {0},奖励锁仓: {1:,} FIL,initialPledgeRequirement: {2:,} FIL'.format(preCommitDeposits,vestingFunds,initialPledgeRequirement))
        print('可用余额: {0:,} FIL,扇区质押: {1:,} FIL,pledgeBalance: {2:,} FIL'.format(availableBalance,sectorPledgeBalance,pledgeBalance))
if __name__ == '__main__':
    main()