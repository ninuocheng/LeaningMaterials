'''
文件的读写俗称"IO"操作
内置函数open()创建文件对象
通过IO流将磁盘文件中的内容与程序中的对象中的内容进行同步
file = open('filename')
文件的类型
按照文件中数据的组织形式，文件分为以下两大类
文本文件：存储的是普通“字符”文本，默认为unicode字符集，可以使用记事本程序打开
二进制文件：把数据内容用“字节”进行存储，无法用记事本打开，必须使用专用的软件打开，eg：mp3音频文件，jpg图片，.doc文档等
打开模式
r 只读模式打开文件
w 只写模式打开文件,如果文件不存在会创建，如果文件存在会覆盖内容
a 追加模式打开文件,如果文件不存在会创建，如果文件存在会追加内容
b 二进制方法打开文件，不能单独使用，需要与r或是w一起使用,eg:rb,rw
+ 读写方式打开文件，不能单独使用，需要与其它模式一起使用,eg: a+
'''

# file = open('a.txt','r')
# content = file.readlines()
# print(content)
# file.close()
# file = open('b.txt','r,w')
# content1 = file.write('helloworld2')
# print(content1)
# # file = open('b.txt','a+')
# content2 = file.readlines()
# print(content2)
# file.close()
# 复制图片
src_file = open('Mango Dragonfruit with Lemonade Starbucks Refreshers™                      .jpg','rb')
target_file = open('copylogo.jpg','wb')
target_file.write(src_file.read())

src_file.close()
target_file.close()