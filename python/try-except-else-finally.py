# 如果try块中没有抛出异常，则执行else块，否则执行except块
# finally块无论是否抛出异常都会执行，用来释放try块中申请的资源
try:
    n1 = int(input('请输入一个整数：'))
    n2 = int(input('请输入另一个整数：'))
    result = n1 / n2
except BaseException as error:
    print('出错了',error)
else:
    print('结果为：',result)
finally:
    print('谢谢您的使用')