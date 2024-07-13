# import json
#
# height_filename = '123'
# parents_filename = '234'
# with open(height_filename,mode='r',encoding='utf-8') as heightfile:
#     height_lst = heightfile.readlines()
# with open(parents_filename,mode='r',encoding='utf-8') as parentsfile:
#     parents_lst = parentsfile.readlines()
# lst = zip(height_lst,parents_lst)
# for key,value in zip(height_lst,parents_lst):
#     if key:
#         print(key,end='')
import json
import urllib.request

filname = '555'
with open(filname,mode='r',encoding='utf-8') as rfile:
    content_lst = rfile.readlines()
for data in range(0,len(content_lst)):
    line_lst = content_lst[data].split(' ')
    height = line_lst[0]
    parents = line_lst[1]
    print(height,parents,end='')
    url = f'https://api.filutils.com/api/v2/tipset/{height - 1}'
    headers = {
        'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36'
    }
    req = urllib.request.Request(url=url,headers=headers)
    with urllib.request.urlopen(req) as response:
        content = json.load(response)
    miner_lst = []
    cid_lst = []
    blocks_lst = content['data']['blocks']
    for item in blocks_lst:
        miner_lst.append(item['miner'])
        cid_lst.append(item['cid'])
    print(miner_lst)


