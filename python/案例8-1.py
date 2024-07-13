phones = set()
for i in range(5):
    info = input(f'请输入{i+1}个朋友的姓名和手机号码：')
    phones.add(info)
for item in phones:
    print(item)