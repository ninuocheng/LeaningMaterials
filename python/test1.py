import urllib.request
import json
# filename = 'minerID'  # 矿工列表
#     with open(filename, mode='r', encoding='utf-8') as rfile:
#         minerID = rfile.readlines()
#     parameterfilename = 'parameters'  # 参数文件
#     with open(parameterfilename, mode='r', encoding='utf-8') as fp:
#         parameter = fp.readlines()
#     for item in parameter:
#         item = dict(eval(item))
#         days = item['days']  # 天数
#         pageNum = item['pages']  # 页码数
#     from datetime import date
#     dateNow = date.today()
#     for miner in minerID:
#         Sum = 0
#         miner = miner.replace('\n', '')
#         print(miner)
#         for i in range(days, 1):
#             import datetime
#             checkDate = dateNow + datetime.timedelta(days=i)
#             from datetime import datetime
#             total = 0
#             for page in range(pageNum):

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
for miner in minerID:
    miner = miner.replace('\n', '')
    print(miner)
    for i in range(days, 1):
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
            print(data)
            req = urllib.request.Request(url=url,headers=headers,data=data)
            with urllib.request.urlopen(req) as response:
                content = json.load(response)
            print(content)