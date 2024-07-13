'''
占位符
%s 字符串格式
%d 十进制整数格式
%f 浮点数格式
f-string
Python3.6引入的格式化字符串的方式，它是以花括号{}标明被替换的字符
str.format()
模版字符串.format(逗号分隔的参数)
'''
name = '马冬梅'
age = 18
score = 98.5
print('姓名：%s,年龄：%d,成绩：%.1f' % (name,age,score))
print(f'姓名：{name},年龄：{age},成绩：{score}')
print('姓名：{0},年龄：{1},成绩：{2}'.format(name,age,score))
