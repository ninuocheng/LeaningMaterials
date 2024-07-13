import urllib.request
filname = 'ppt3'
def getData(url):
    headers = {
        'authority': 'www.ptt.cc',
        'accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9',
        'accept-language': 'zh-CN,zh;q=0.9,en-US;q=0.8,en;q=0.7',
        'cache-control': 'no-cache',
        'cookie': '_ga=GA1.1.1694390734.1719891253; over18=1; _ga_DZ6Y3BY9GW=GS1.1.1719893898.2.1.1719893913.0.0.0',
        'pragma': 'no-cache',
        'referer': 'https://www.ptt.cc/ask/over18?from=%2Fbbs%2FGossiping%2Findex.html',
        'sec-ch-ua': '"Chromium";v="92", " Not A;Brand";v="99", "Google Chrome";v="92"',
        'sec-ch-ua-mobile': '?0',
        'sec-fetch-dest': 'document',
        'sec-fetch-mode': 'navigate',
        'sec-fetch-site': 'same-origin',
        'sec-fetch-user': '?1',
        'upgrade-insecure-requests': '1',
        'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36',
    }
    request = urllib.request.Request(url=url,headers=headers)
    with urllib.request.urlopen(request) as response:
        data = response.read().decode('utf-8')
    import bs4
    root = bs4.BeautifulSoup(data,'html.parser')
    titles = root.find_all('div',class_='title')
    for title in titles:
        # 如果标题包含a标题，就打印出来
        if title.a != None:
            print(title.a.string)
            with open(filname, mode='a', encoding='utf-8') as fp:
                fp.write(title.a.string + '\n')
    # 抓取上页的标题
    nextlink = root.find('a',string='‹ 上頁') # 找到内文是‹ 上頁的a标题
    return nextlink['href']
# 抓取一个页面的标题
pageURL = 'https://www.ptt.cc/bbs/Gossiping/index.html'
count = 0
while count < 1000:
    print(pageURL)
    pageURL = 'https://www.ptt.cc' + getData(pageURL)
    count += 1
