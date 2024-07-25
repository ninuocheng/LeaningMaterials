# a的ASCII的值
x = 97
# for _ in range(1,27):
#     print(chr(x),'--->',x)
#     x += 1
# for _ in range(1,27):
#     print(f'{chr(x)}的ASCII的值为{x}')
#     x += 1
# while x < 123:
#     print(f'{chr(x)}-->{x}')
#     x += 1
for i in range(1,4):
    user_name = input('请输入用户名：')
    user_pwd = input('请输入密码：')
    if user_name == 'admin' and user_pwd == '123456':
        print('输入正确')
        break
    else:
        print('用户名或密码输入错误，请重新输入')
        if i < 3:
            print(f'您还有{3-i}次机会')
print('对不起，输入了三次用户名或密码错误')