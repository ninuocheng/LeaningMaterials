# filename = 'D:\\bak/资料/onlinedeviceinfo'
filename = 'D:\\Users/ninuo/Downloads/机器列表-Sheet1.csv'
with open(filename,mode='r',encoding='utf-8') as fp:
    content = fp.readline()
    for i in content:
        print(i)
