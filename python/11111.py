import json
import sys
import os
import urllib.request

# Script = sys.argv[1]
MinerID = 1
DateTime = 2

filename = f'HashHeightParents'
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
    print(data)
    if str(data) == 'None':
        HeightParents[MinedHeight] = MinedParents
if HeightParents:
    for height,parents in HeightParents.items():
        url = f'https://api.filutils.com/api/v2/tipset/{int(height) - 1}'
        headers = {
            'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36'
        }
        req = urllib.request.Request(url=url, headers=headers)
        with urllib.request.urlopen(req) as response:
            content = json.load(response)
        onChain_parents_lst = []
        blocks_lst = content['data']['blocks']
        if str(blocks_lst) == 'None':
            url = f'https://api.filutils.com/api/v2/tipset/{int(height) - 2}'
            headers = {
                'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36'
            }
            req = urllib.request.Request(url=url, headers=headers)
            with urllib.request.urlopen(req) as response:
                content = json.load(response)
            blocks_lst = content['data']['blocks']
        for item in blocks_lst:
            onChain_parents_lst.append(item['miner'])
        winning_parents_lst = list(eval(parents))
        pubParents = set(winning_parents_lst) & set(onChain_parents_lst)  # 交集
        lackParents = set(onChain_parents_lst) - set(winning_parents_lst)  # 差集(缺少)
        addParents = set(winning_parents_lst) - set(onChain_parents_lst)  # 差集(多了)
        print(f'WinningParents: {winning_parents_lst}')
        print(f'OnChainParents: {onChain_parents_lst}')
        if not pubParents:
            print(f'{MinerID} {height} 父区块同步错误')
            continue
        if set(winning_parents_lst) == set(onChain_parents_lst):
            print(f'{MinerID} {height} 可能是爬取的页码不够，或是上链超时，或是lotus分叉所致，请检查确认')
        if lackParents:
            print(lackParents)
            lackParents = str(lackParents).replace('\'', '').replace('{', '').replace('}', '')
            print(f'{MinerID} {height} 缺少了父区块{lackParents}')
        if addParents:
            print(addParents)
            addParents = str(addParents).replace('\'', '').replace('{', '').replace('}', '')
            print(f'{MinerID} {height} 多同步了父区块{addParents}')
else:
    print(f'{DateTime} {MinerID} 没有孤块')