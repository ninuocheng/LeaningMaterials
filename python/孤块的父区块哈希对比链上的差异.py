import json
import datetime
import os.path
from datetime import date
import urllib.request
def block_reward():
        num = -1
        page_num = 3
        now_date = date.today()
        miner_id = 'f01699999'
        check_date = now_date + datetime.timedelta(days=num)
        filename = f'{miner_id}/{check_date}-block-reward.csv'
        dirname = os.path.dirname(filename)
        if not os.path.exists(dirname):
            os.mkdir(dirname)
        if os.path.exists(filename):
            os.remove(filename)
        for page in range(1,page_num + 1):
            url = 'https://api.filutils.com/api/v2/block'
            headers = {
                'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36'
            }
            data = {
                'height': 0,
                'miner': miner_id,
                'pageIndex': page,
                'pageSize': 20
            }
            data = json.dumps(data).encode('utf-8')
            request = urllib.request.Request(url=url,headers=headers,data=data)
            with urllib.request.urlopen(request) as response:
                content = json.load(response)
            blocks = content['data']
            for item in blocks:
                mineTime = item['mineTime']
                minerDate = mineTime.split()[0]
                if str(minerDate) == str(check_date):
                    with open(filename,mode='a',encoding='utf-8') as afile:
                        afile.write(f'{str(item)}\n')
block_reward()