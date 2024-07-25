import json
# json.dump('要写入的内容','filename')
# json.load('filename')
# filename = 'D:\\Users/ninuo/Downloads/machine-list.json'
filename = 'parameters'
with open(filename,mode='r',encoding='utf-8') as fp:
    content = fp.read()
data = dict(eval(content))
for item in data:
    miner = data['miner']
    days = data['days']
    pageNum = data['pages']
    method = data['method']
print(miner,days,pageNum,method)
print(type(miner),type(days))
    # content = json.load(fp)
# for item in content:
#     if str(content[item].get('miner_id')) != 'None':
#         print(item, content[item]['miner_id'],content[item]['user'])
#     else:
#         print(item)
# print(data,type(data))
# 说明：load方法的是文件 loads方法的是读取的内容
