# 创建一个字典
dict = {'zhangsan': 165,'lisi': 176,'wangwu': 187}
# 遍历字典的元素
# 方法一
for item in dict:
    print(item,dict[item])
# 方法二
for key in dict.keys():
    print(key,dict[key])
# 方法三
for key,value in dict.items():
    print(key,value)