# import os.path
# filename = 'D:\\tedu1/f02528'
# dirname = os.path.dirname(filename)
# print(dirname)
# if not os.path.exists(dirname):
#     os.mkdir(dirname)
# if os.path.exists(filename):
#     os.remove(filename)
import json
a = '123'
with open(a,mode='r',encoding='utf-8') as rfile:
    content = json.dumps(rfile)
print(content)
    # content = json.loads(content)
    # for data in content:
    #     # content = json.loads(data)
    #     # print(content)
    #     print(data)