# # 创建字典
dict = {'name': 'zhangsan','age': 16}
# #字典变量[]查找的键值不存在，会报KeyError异常
# # print(dict['sex'])
# #字典变量.get()方法查找的键值不存在，会返回None
# print(dict.get('sex'))
# #查找的键值不存在时，提供一个默认值：男
# print(dict.get('sex','男'))
#
# # key的判断
# print('sex' in dict)
# print('name' in dict)
# print('age' not in dict)
# print('sex' not in dict)
# # 删除指定的键值对
# del dict['age']
# print(dict)
# # 清空字典的元素
# # dict.clear()
# # 新增字典的元素
# dict['sex'] = '男'
# print(dict)
# # 修改value值
# dict['name'] = 'lisi'
# print(dict)
# # 获取字典所有的key
# print(dict.keys())
# # 将所有的key转成列表
# print(list(dict.keys()))
# print(type(list(dict.keys())))
# # 遍历字典的key
# for key in dict.keys():
#     print(key)
# print(type(dict.keys()))
# # 获取字典所有的value
# print(dict.values())
# print(type(dict.values()))
# #遍历字典的value
# for value in dict.values():
#     print(value)
# # 获取字典所有的key,value对
# print(dict.items())
# print(type(dict.items()))
# 遍历字典的key,value对
print(dict)
for height,parents in dict.items():
    print(height,parents)