'''
absent(path) 用于获取文件或是目录的绝对路径
exists(path) 用于判断文件或是目录是否存在，如果存在返回True，否则返回False
join(path,name) 将目录与目录或者文件名拼接起来
splitext() 分离文件名和扩展名
basename(path) 从一个目录中提取文件名
dirname(path) 从一个路径中提取文件路径，不包括文件名
isdir(path) 用于判断是否为路径
'''
import os.path
path = os.path.abspath('11.py')
print(path)
file = os.path.exists('22.py')
file1 = os.path.exists('23.py')
print(file)
print(file1)
# 拼接
spicing = os.path.join('E:\\Python','demo10.py')
print(spicing)
# 拆分目录和文件，返回的是一个元组
separation = os.path.split('E:\\vipython\\chp13\\dea13.py')
print(separation)
# 拆分目录和扩展名，返回的是一个元组
separation1 = os.path.splitext('E:\\vipython\\chp13\\dea13.py')
separation2 = os.path.splitext('dea13.py')
print(separation1)
print(separation2)
basename = os.path.basename('E:\\vipython\\chp13\\dea13.py')
print(basename)
dirname = os.path.dirname('E:\\vipython\\chp13\\dea13.py')
print(dirname)
isdir1 = os.path.isdir('D:\\Users\\ninuo\\PycharmProjects\\python基础\\Python入门到精通\\11.py')
isdir2 = os.path.isdir('D:\\Users\\ninuo\\PycharmProjects\\python基础\\Python入门到精通')
print(isdir1)
print(isdir2)