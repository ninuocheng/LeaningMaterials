# for i in range(3):
#     pwd = input('请输入密码：')
#     if pwd == '8888':
#         print('密码输入正确')
#         break
#     else:
#         print('密码输入错误')
# else:
#     print('密码输入三次错误')

n = 0
while n < 3:
    pwd = input('请输入密码：')
    if pwd == '8888':
        print('密码输入正确')
        break
    else:
        print('密码输入错误')
    n += 1
else:
    print('密码输入三次错误')