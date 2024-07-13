'''
字符串的编码
将str类型转换成bytes类型,需要使用到字符串的encode()方法
语法格式
str.encode(encoding='utf-8',errors='strict/ignore/replace')
字符串的解码
将bytes类型转换成str类型,需要使用到bytes类型的decode()方法
语法格式
bytes.decode(encoding='utf-8',errors='strict/ignore/replace')
'''
s = '伟大的中国梦'
# 编码 str --> bytes
s_code = s.encode(errors='replace') #默认是utf-8,因为utf-8中午占3个字符
print(s_code)
gbk_code = s.encode(encoding='gbk',errors='replace') # gbk中文占2个字符
print(gbk_code)
# 编码中的出错问题
s2 = '耶✌️'
s_error = s2.encode(encoding='gbk',errors='replace')
print(s_error)
 # 解码 bytes --> str
print(bytes.decode(s_code))
print(bytes.decode(gbk_code,encoding='gbk'))
