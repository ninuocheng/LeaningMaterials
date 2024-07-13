import urllib.request

# url = 'https://www.filutils.com/zh/miner/f02528'
url = 'https://api.filutils.com/api/v2/block'
headers = {
    'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36'
}
data = {"miner": "f02528", "height": 0, "pageIndex": 1, "pageSize": 20}
# print(data)
# print(type(data))
request = urllib.request.Request(url=url,headers=headers)
with urllib.request.urlopen(request) as response:
    content = response.read().decode('utf-8')
print(content)