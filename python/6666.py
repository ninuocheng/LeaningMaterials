import datetime
from datetime import date
now_time = datetime.datetime.now().replace(microsecond=0)
print(now_time)

now_date = date.today()
print(now_date)