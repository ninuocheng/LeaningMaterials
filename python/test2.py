def parameter():
    filename = 'minerID'  # 矿工列表
    with open(filename, mode='r', encoding='utf-8') as rfile:
        minerID = rfile.readlines()
    parameterfilename = 'parameters'  # 参数文件
    with open(parameterfilename, mode='r', encoding='utf-8') as fp:
        parameter = fp.readlines()
    for item in parameter:
        item = dict(eval(item))
        days = item['days']  # 天数
        pageNum = item['pages']  # 页码数
        method = item['method']
    from datetime import date
    dateNow = date.today()
    return minerID,days,pageNum,method,dateNow
a = parameter()
print(a,type(a))
for i in a:
    if isinstance(i,list):
        minerID = i
        print(minerID,type(minerID))
    else:
        days = a[1]
        pages = a[2]
        method = a[3]
        dateNow = a[4]
print(days,pages,method,dateNow)
