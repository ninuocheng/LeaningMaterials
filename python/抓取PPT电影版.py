import urllib.request as req
url = 'https://www.ptt.cc/bbs/movie/index.html'
headers = {
    'accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9',
    'accept-language': 'zh-CN,zh;q=0.9,en-US;q=0.8,en;q=0.7',
    'cache-control': 'no-cache',
    'cookie': '_ga=GA1.1.1694390734.1719891253; _ga_DZ6Y3BY9GW=GS1.1.1719891252.1.1.1719891272.0.0.0',
    'pragma': 'no-cache',
    'sec-ch-ua': '"Chromium";v="92", " Not A;Brand";v="99", "Google Chrome";v="92"',
    'sec-ch-ua-mobile': '?0',
    'sec-fetch-dest': 'document',
    'sec-fetch-mode': 'navigate',
    'sec-fetch-site': 'none',
    'sec-fetch-user': '?1',
    'upgrade-insecure-requests': '1',
    'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36'
}
request = req.Request(url=url,headers=headers)
with req.urlopen(request) as response:
    data = response.read().decode('utf-8')
# print(data)
# 解析网页源码
import bs4
root = bs4.BeautifulSoup(data,'html.parser')
# print(root.title.string)
titles = root.find_all('div',class_='title')
for title in titles:
    if title.a != None:
        with open('PTT',mode='a',encoding='utf-8') as fp:
            fp.write(title.a.string + '\n')