import json
import sys
import os
import time
import urllib.request

Script = sys.argv[1] # 执行脚本路径
MinerID = sys.argv[2] # 节点号
DateTime = sys.argv[3] # 查询日期
BlockNum = sys.argv[4] # 出块数量

filename = f'{Script}/HashHeightParents'
with open(filename,mode='r',encoding='utf-8') as rfp:
    content = rfp.readlines()
HeightParents = {}
for item in content:
    line = item.split(' ')
    MinedHash = line[0].replace('"','').replace(',','')
    MinedHeight = line[1].replace(',','')
    MinedParents = line[2]
    url = f'https://api.filutils.com/api/v2/block/{MinedHash}'
    headers = {
        'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36'
    }
    req = urllib.request.Request(url=url,headers=headers)
    with urllib.request.urlopen(req) as response:
        content = json.load(response)
    data = content['data']
    if str(data) == 'None':
        HeightParents[MinedHeight] = MinedParents

if HeightParents:
    for height,parents in HeightParents.items():
        ChainparentsHeight = int(height) - 1
        while True:
            url = f'https://api.filutils.com/api/v2/tipset/{ChainparentsHeight}'
            headers = {
                'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36'
            }
            req = urllib.request.Request(url=url, headers=headers)
            while True:
                try:
                    with urllib.request.urlopen(req) as response:
                        content = json.load(response)
                except:
                    print(f'{url}访问异常，请检查')
                    time.sleep(10)
                    continue
                else:
                    break
            onChain_parents_lst = []
            blocks_lst = content['data']['blocks']
            if str(blocks_lst) == 'None':
                ChainparentsHeight = ChainparentsHeight - 1
                continue
            else:
                break
        blocks_lst = content['data']['blocks']
        for item in blocks_lst:
            onChain_parents_lst.append(item['miner'])
        winning_parents_lst = list(eval(parents))
        pubParents = set(winning_parents_lst) & set(onChain_parents_lst)  # 交集
        lackParents = set(onChain_parents_lst) - set(winning_parents_lst)  # 差集(缺少)
        addParents = set(winning_parents_lst) - set(onChain_parents_lst)  # 差集(多了)
        print(f'WinningParents: {winning_parents_lst}')
        print(f'OnChainParents: {onChain_parents_lst}')
        print(f'{DateTime} {MinerID} 出块数量: {BlockNum}')
        if not pubParents:
            print(f'{MinerID} {height} 父区块同步错误')
            continue
        if set(winning_parents_lst) == set(onChain_parents_lst):
            print(f'{MinerID} {height} 可能是爬取的页码不够，或是上链超时，或是lotus分叉所致，请检查确认')
        if lackParents:
            lackParents = str(lackParents).replace('\'', '').replace('{', '').replace('}', '')
            print(f'{MinerID} {height} 缺少了父区块{lackParents}')
        if addParents:
            addParents = str(addParents).replace('\'', '').replace('{', '').replace('}', '')
            print(f'{MinerID} {height} 多同步了父区块{addParents}')
else:
    print(f'{DateTime} {MinerID} 出块数量: {BlockNum} 没有孤块')