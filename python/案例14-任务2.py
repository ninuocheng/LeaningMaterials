import datetime
from datetime import date
def input_date():
    date = input('请输入开始日期(如20200808)：')
    date = date.strip()
    datestr = date[0:4] + '-' + date[4:6] + '-' + date[6:]
    return datetime.datetime.strptime(datestr,'%Y-%m-%d')
if __name__ == '__main__':
    print('推算几天后的日期'.center(30,'-'))
    date = input_date()
    print(date,type(date))
    num = int(input('请输入间隔天数：'))
    date = date + datetime.timedelta(days=num)
    print(date,type(date))
    print(f'您推算的日期是{str(date).split(' ')[0]}')
# now = date.today()
# now1 = date.year
# print(now)
# print(now1)
# current = datetime.datetime.strptime(now,'%Y-%m-%d %H-%M-%S')
# print(current)
def down_load(content):
    blocks = content['data']['blocks']
    with open(filename,mode='a',encoding='utf-8') as fp:
        for block in blocks:
            fp.write(f'{block}\n')