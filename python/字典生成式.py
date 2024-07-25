# 内置函数zip()用于将可迭代的对象作为参数，将对象中对应的元素打包成一个元组，然后返回由这些元组组成的列表
items = ['Fruits','Books','Others']
prices = [96,78,85]
lst = zip(items,prices)
print(dict(lst))
for key,value in zip(items,prices):
    print(key,value)
# print({key.upper():value for key,value in zip(items,prices)})