import json
import urllib.request as req
def create_request(miner,page):
    url = 'https://api.filutils.com/api/v2/block'
    headers = {
        'content-type': 'application/json;charset=UTF-8',
        'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36'
    }
    data = {
        'height': 0,
        'miner': miner,
        'pageIndex': int(page),
        'pageSize': 20
    }
    data = json.dumps(data).encode('utf-8')
    request = req.Request(url=url,headers=headers,data=data)
    return request
def get_content(request):
    with req.urlopen(request) as response:
        content = json.load(response)
        # content = response.read().decode('utf-8')
    # content = json.loads(content)
    # cid = content["cid"]
    print(content)
    return content
def down_load(miner,content):
    filename = f'D:\\miner/{miner}'
    lst = content['data']
    with open(filename, mode='a', encoding='utf-8') as fp:
            fp.write(str(lst))
if __name__ == '__main__':
    miner = input('请输入要查询的矿工号：')
    for page in range(1,2):
        request = create_request(miner,page)
        content = get_content(request)
        down_load(miner,content)