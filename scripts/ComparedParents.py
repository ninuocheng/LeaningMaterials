#!/usr/bin/python3
import json
import sys
import os
import time
import urllib.request

Script = sys.argv[1] # 执行脚本路径
MinerID = sys.argv[2] # 节点号
DateTime = sys.argv[3] # 查询日期
LotteryNum = sys.argv[4] # 抽奖数量
WinNum = sys.argv[5] # 中奖数量
RebaseNum = sys.argv[6] # 重做数量

filename = f'{Script}/HashHeightParentsParentBlockHeight'
with open(filename,mode='r',encoding='utf-8') as rfp:
    content = rfp.readlines()
HeightParents = {}
ParentsHeight = {}
for item in content:
    line = item.split('\t')
    HashHeightParents = line[0].split(' ')
    ParentBlockHeight = line[1]
    MinedHash = HashHeightParents[0].replace('"','').replace(',','')
    MinedHeight = HashHeightParents[1].replace(',','')
    MinedParents = HashHeightParents[2]
    url = f'https://api.filutils.com/api/v2/block/{MinedHash}'
    headers = {
        'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36'
    }
    req = urllib.request.Request(url=url,headers=headers)
    while True:
        try:
            with urllib.request.urlopen(req) as response:
                content = json.load(response)
                break
        except:
            time.sleep(5)
            continue
    data = content['data']
    if str(data) == 'None':
        HeightParents[MinedHeight] = [MinedParents,ParentBlockHeight]
        ParentsHeight[MinedParents,ParentBlockHeight] = [MinedHeight]

OrphanNum = len(HeightParents) # 孤块数量
BlockNum = int(WinNum) - OrphanNum - int(RebaseNum) # 出块数量
print(f'{DateTime} {MinerID} 抽奖数量: {LotteryNum} 中奖数量: {WinNum} 出块数量: {BlockNum} 孤块数量: {OrphanNum}')
if ParentsHeight:
    for parents,height in ParentsHeight.items():
        parentsBlock = parents[0]
        parentsHeight = int(parents[1].replace('\n', ''))
        blockHeight = height[0]
        height = int(height[0])
        while True:
            url = f'https://api.filutils.com/api/v2/tipset/{height-1}'
            headers = {
                    'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36'
                    }
            req = urllib.request.Request(url=url, headers=headers)
            while True:
                try:
                    with urllib.request.urlopen(req) as response:
                        content = json.load(response)
                        break
                except:
                    time.sleep(10)
                    continue
            onChain_parents_lst = []
            blocks_lst = content['data']['blocks']
            if str(blocks_lst) == 'None':
                height = height - 1
                continue
            break
        blocks_lst = content['data']['blocks']
        for item in blocks_lst:
            onChain_parents_lst.append(item['miner'])
        winning_parents_lst = json.loads(parentsBlock)
        print(f'WinningParents: {winning_parents_lst}')
        pubParents = set(winning_parents_lst) & set(onChain_parents_lst)  # 交集
        lackParents = set(onChain_parents_lst) - set(winning_parents_lst)  # 差集(缺少)
        addParents = set(winning_parents_lst) - set(onChain_parents_lst)  # 差集(多了)
        url = 'https://api.filutils.com/api/v2/orphanblock'
        headers = {
            'content-type': 'application/json;charset=UTF-8',
            'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36'
        }
        data = {
            'height': 0,
            'miner': MinerID,
            'pageIndex': 1,
            'pageSize': 20,
            'type': 0
        }
        data = json.dumps(data).encode('utf-8')
        req = urllib.request.Request(url=url, headers=headers, data=data)
        while True:
            try:
                with urllib.request.urlopen(req) as res:
                    content = json.load(res)
                    break
            except:
                time.sleep(5)
                continue
        data = content['data']
        height_list = []  # 孤块高度列表
        for item in data:
            chainHeight = item['height']
            height_list.append(chainHeight)
        if int(blockHeight) not in height_list:
            print(f'OnChainParents: {onChain_parents_lst}')
            print(f'{MinerID} {blockHeight} 链上查不到该孤块')
        else:
            if height - 1 == parentsHeight:             # 同步到的父区块高度正常
                print(f'OnChainParents: {onChain_parents_lst}')
                if lackParents and pubParents:
                    lackParents = str(lackParents).replace('\'', '').replace('{', '').replace('}', '')
                    print(f'{MinerID} {blockHeight} 缺少了父区块{lackParents}')
                if addParents and pubParents:
                    addParents = str(addParents).replace('\'', '').replace('{', '').replace('}', '')
                    print(f'{MinerID} {blockHeight} 多同步了父区块{addParents}')
                if not pubParents:
                    print(f'{MinerID} {blockHeight} 父区块同步错误')
                if set(winning_parents_lst) == set(onChain_parents_lst):
                    print(f'{MinerID} {blockHeight} 上链超时或是lotus分叉或是触发了双叉挖掘故障，请检查确认')
            else:     # 同步到的父区块高度不正常
                url = f'https://api.filutils.com/api/v2/tipset/{parentsHeight}'
                headers = {
                        'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36'
                }
                req = urllib.request.Request(url=url, headers=headers)
                while True:
                    try:
                        with urllib.request.urlopen(req) as response:
                            content = json.load(response)
                            break
                    except:
                        time.sleep(10)
                        continue
                onChain_parents_lst = []
                blocks_lst = content['data']['blocks']
                for item in blocks_lst:
                    onChain_parents_lst.append(item['miner'])
                print(f'OnChainParents: {onChain_parents_lst}')
                pubParents = set(winning_parents_lst) & set(onChain_parents_lst)  # 交集
                lackParents = set(onChain_parents_lst) - set(winning_parents_lst)  # 差集(缺少)
                addParents = set(winning_parents_lst) - set(onChain_parents_lst)  # 差集(多了)
                if lackParents and pubParents:
                    lackParents = str(lackParents).replace('\'', '').replace('{', '').replace('}', '')
                    print(f'{MinerID} {blockHeight} 缺少了父区块{lackParents}(同步到的父区块高度是{parentsHeight})')
                if addParents and pubParents:
                    addParents = str(addParents).replace('\'', '').replace('{', '').replace('}', '')
                    print(f'{MinerID} {blockHeight} 多同步了父区块{addParents}(同步到的父区块高度是{parentsHeight})')
                if not pubParents:
                    print(f'{MinerID} {blockHeight} 父区块同步错误(同步到的父区块高度是{parentsHeight})')
                if set(winning_parents_lst) == set(onChain_parents_lst):
                    print(f'{MinerID} {blockHeight} 同步到的父区块高度是{parentsHeight}')
