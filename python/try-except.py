try:
    a = int(input('请输入第一个整数：'))
    b = int(input('请输入第二个整数：'))
    result = a / b
    print('结果为：',result)
# except ZeroDivisionError:
#     print('除数不允许为0')
except BaseException as e:
    print(e)
print('程序结束')