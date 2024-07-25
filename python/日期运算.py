# from datetime import date,timedelta
# print(date(2000,2,3))
# print(date.today())
# dt = date.today()
# print(dt.year,dt.month,dt.day,dt.weekday()) #星期的取值范围（0-6）所以0是星期一，6是星期日
# # 时间差
# diff1 = timedelta(days=10)
# print(diff1)
# differ2 = timedelta(weeks=1)
# print(differ2)
# # 新的日期 = 日期 +/- 时间差
# from datetime import date,timedelta
# # 当前日期
# dt = date.today()
# # 加3天
# dt1 = dt + timedelta(days=3)
# # 减一周
# dt2 = dt - timedelta(weeks=1)
# print(dt1,dt2)
from datetime import date,timedelta
dateNow = date.today()
# print(dateNow.year,dateNow.month,dateNow.day,dateNow.weekday() + 1)
# weekNow = dateNow.weekday()
# print(f'{dateNow},星期{dateNow.weekday() + 1}')
# weekAfter = dateNow + timedelta(weeks=1)
# print(weekAfter)
# dateNowMonth = dateNow.month
weekday_names = {
    0:'周一',1:'周二',2:'周三',3:'周四',4:'周五',5:'周六',6:'周日'
}
today = date.today()
dt = date(today.year,today.month,1)
while dt.month == today.month:
    print(dt,weekday_names[dt.weekday()])
    dt = dt + timedelta(days=1)