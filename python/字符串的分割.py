# split分割，如果参数sep不指定分隔符，默认是空格，返回的是一个列表
s = 'hello world Python'
lst = s.split()
print(lst)
s1 = 'hello|world|Python'
lst1 = s1.split(sep='|')
print(lst1)
# maxsplit指定最大分割的次数
s2 = 'hello|world|Python'
print(s2.split(sep='/',maxsplit=2))
# rsplit 从右侧开始分割
s3 = '/root/opt/text.conf'
print(s3.rsplit('/',maxsplit=1)[1]) # 获取的是文件
print(s3.rsplit('/',maxsplit=1)[0]) # 获取的是目录