file = open('a.txt','r')
# # read()方法默认读取所有内容，返回的是字符串的数据类型，可以指定读取的字符串数量
# content = file.read(2)
# file.seek(0)
# print(content)
# content1 = file.read(2)
# print(content1)
# # readline()方法默认只读取第一行，返回的是字符串的数据类型
# content2 = file.readline()
# # readlines()方法默认读取所有内容，返回的是以行的内容为元素的一个列表
# content3 = file.readlines()
# print(content3,type(content3))
# print(content2)
# print(content3)
#
# # # 一个中文两个字节，所以seek(奇数)就会报错
# file = open('a.txt','r')
# # 移动文件指针到新的位置，默认是0从文件头开始计算，1从当前位置开始计算 2从文件尾开始计算
# file.seek(2)
# content = file.readline()
# file.seek(0)
content = file.readlines()
# # 返回文件指针的当前位置
position = file.tell()
print(content,position)
# flush()把缓冲区的内容写入文件，但不关闭文件
# close()把缓冲区的内容写入文件，同时关闭文件，释放文件对象相关资源
# file = open('d.txt','a')
# file.write('hello')
# file.close()
# file.write('world')
# file.flush()