import json
import urllib.request

filname = '234'
with open(filname,mode='r',encoding='utf-8') as rfile:
    content_lst = rfile.readlines()
for data in range(0,len(content_lst)):
    line_lst = content_lst[data].split(' ')
    height = line_lst[0]
    winning_parents = line_lst[1]
    winning_parents_lst = json.loads(winning_parents)
    url = f'https://api.filutils.com/api/v2/tipset/{int(height) - 1}'
    headers = {
        'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36'
    }
    req = urllib.request.Request(url=url,headers=headers)
    with urllib.request.urlopen(req) as response:
        content = json.load(response)
    onChain_parents_lst = []
    blocks_lst = content['data']['blocks']
    for item in blocks_lst:
        onChain_parents_lst.append(item['miner'])
    pubParents = set(winning_parents_lst) & set(onChain_parents_lst) #交集
    lackParents = set(onChain_parents_lst) - set(winning_parents_lst) #差集(缺少)
    addParents = set(winning_parents_lst) - set(onChain_parents_lst)  #差集(多了)
    print(f'WinParents: {winning_parents_lst}')
    print(f'OnChainParents: {onChain_parents_lst}')
    print(f'PubParnets: {pubParents}')
    if not pubParents:
        print(f'{height} 父区块同步错误')
        continue
    if set(winning_parents_lst) == set(onChain_parents_lst):
        print(f'{height} 可能是爬取的页码不够，或是上链超时，或是lotus分叉所致，请检查确认')
    if lackParents:
        lackParents = str(lackParents).replace('\'','').replace('{','').replace('}','')
        print(f'{height} 缺少了父区块{lackParents}')
    if addParents:
        addParents = str(addParents).replace('\'','').replace('{','').replace('}','')
        print(f'{height} 多同步了父区块{addParents}')
