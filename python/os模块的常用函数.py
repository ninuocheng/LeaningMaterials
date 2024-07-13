# '''
# 目录操作
# os模块是Python内置的与操作系统功能和文件系统相关的模块
# 该模块中的语句的执行结果通常与操作系统有关，在不同的操作
# 系统上运行，得到的结果可能不一样
# os模块与os.path模块用于对目录或是文件进行操作
# 函数                                    说明
# getcwd()                          返回当前的工作目录
# listdir(path)                     返回指定路径下的文件和目录信息
# mkdir(path[,mode])                创建目录
# makedirs(path1/path2/...[,mode])  创建多级目录
# rmdir(path)                       删除目录
# removedirs(path1/path2/...)       删除多级目录
# chdir(path)                       将path设置为当前工作目录
# '''
# # os模块是与操作系统相关的一个模块
# # 调用系统程序
# import os
# # os.system('notepad.exe')
# # os.system('calc.exe')
# # 调用可执行文件
# # os.startfile("D:\\Program Files\\Tencent\\QQNT\\QQ.exe")
# print(os.getcwd())
# # 列出指定路径下的文件和目录，返回的是一个列表
# # print(os.listdir('../Python入门到精通'),len(os.listdir('../Python入门到精通')))
# # os.mkdir('newdir2/A')
# # os.makedirs('newdir2/A/B/C')
# # os.rmdir('newdir2')
# # os.removedirs('newdir2/A')
# print(os.listdir('newdir2'))
# # print(os.chdir('../../'))
# # print(os.getcwd())
# from datetime import datetime
# current = datetime.today()
# currnet1 =  datetime.date
# print(current)
# print(currnet1)
import os

dirname = os.getcwd()
print(f'{dirname}/WinningParents')