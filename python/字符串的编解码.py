s = '天涯共此时'
# 编码
# GBK编码格式中，一个中文占两个字节
print(s.encode(encoding='GBK'))
# UTF-8编码格式中，一个中文占三个字节
print(s.encode(encoding='UTF-8'))
# 解码
byte = s.encode(encoding='GBK')
print(byte.decode(encoding='GBK'))
byte = s.encode(encoding='UTF-8')
print(byte.decode(encoding='UTF-8'))