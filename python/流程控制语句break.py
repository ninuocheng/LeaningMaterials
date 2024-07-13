'''
break=语句用于结束循环结构，通常与分支结构if一起使用
for 自定义的变量 in 可迭代对象:
    循环体
    if 条件判断:
        break

while (条件):
    循环体
    if 条件:
        break
'''
# 从键盘录入密码，最多输入3次，如果正确就结束循环
# for i in range(3):
#     pwd = input('请输入密码：')
#     if pwd == '8888':
#         print('密码输入正确')
#         break
#     else:
#         print('密码输入错误')
# 初始化变量
a = 0
while a < 3:
    # 条件执行体（循环体）
    pwd = input('请输入密码：')
    if pwd == '8888':
        print('密码输入正确')
        break
    else:
        print('密码输入错误')
    # 改变变量
    a += 1
