import json
import sys
import urllib.request
def message():
    filename = 'minerID'  # 矿工列表
    with open(filename, mode='r', encoding='utf-8') as rfile:
        minerID = rfile.readlines()
    parameterfilename = 'parameters'  # 参数文件
    with open(parameterfilename, mode='r', encoding='utf-8') as fp:
        parameter = fp.readlines()
    for item in parameter:
        item = dict(eval(item))
        days = item['days']  # 天数
        pageNum = item['pages']  # 页码数
    from datetime import date
    dateNow = date.today()
    for miner in minerID:
        Sum = 0
        miner = miner.replace('\n', '')
        print(miner)
        for i in range(days, 1):
            import datetime
            checkDate = dateNow + datetime.timedelta(days=i)
            from datetime import datetime
            total = 0
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
                with urllib.request.urlopen(req) as response:
                    content = json.load(response)
                # print(content)
                cid_lst = content['data']
                for item in cid_lst:
                    cid = item['cid']
                    fee = item['fee']
                    method = item.get('method')
                    # print(cid,method,fee)
                    if method == 'ExtendSectorExpiration2':
                        url = f'https://api.filutils.com/api/v2/message/{cid}'
                        headers = {
                            'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36'
                        }
                        req = urllib.request.Request(url=url,headers=headers)
                        with urllib.request.urlopen(req) as response:
                            content = json.load(response)
                        # print(content)
                        timeDate = content['data']['time']
                        timeDate = timeDate.split(' ')[0]
                        if str(checkDate) == timeDate:
                            minerTip = content['data']['minerTip']
                            feeValue = minerTip.split(' ')[0]
                            feeUnit = minerTip.split(' ')[1]
                            totalBurnFee = content['data']['totalBurnFee']
                            totalBurnValue = totalBurnFee.split(' ')[0]
                            totalBurnUnit = totalBurnFee.split(' ')[1]
                            if feeUnit == 'nanoFIL':
                                Sum += float(feeValue)
                            elif feeUnit == 'FIL':
                                feeValue = float(feeValue)*(10**9)
                                Sum += feeValue
                            if totalBurnUnit == 'nanoFIL':
                                Sum += float(totalBurnValue)
                            elif totalBurnUnit == 'FIL':
                                totalBurnValue = float(totalBurnValue)*(10**9)
                                Sum += totalBurnValue
                            print('{0} 节点手续费: {1} 销毁手续费: {2}'.format(timeDate,minerTip,totalBurnFee))
    Sum = Sum/(10**9)
    print('总计: {0:,} FIL'.format(Sum))
if __name__ == '__main__':
    message()