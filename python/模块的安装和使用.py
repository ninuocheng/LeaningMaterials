'''
模块的安装
pip install 模块名称
模块的使用
import 模块名称
'''
import schedule
import time
def job():
    print('哈哈 ------')

schedule.every(3).seconds.do(job)

while True:
    schedule.run_pending()
    time.sleep(1)