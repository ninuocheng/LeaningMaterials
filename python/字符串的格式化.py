# 格式化字符串的三种方法
name = 'zhangsan'
age  = 28
# % 占位符
print('我的名字叫%s,今年%d岁' % (name,age))
# {} 占位符
print('我的名字叫{0},今年{1}岁'.format(name,age))
# f-string
print(f'我的名字叫{name},今年{age}岁')
print(f'My\'name is {name},I\'m {age} years old.')