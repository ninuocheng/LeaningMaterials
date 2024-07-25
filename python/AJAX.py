# 抓取Medium.com的文字资料
import urllib.request as req
url = 'https://medium.com/_/api/home-feed'
headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36'
}
# 请求对象的定制
request = req.Request(url=url,headers=headers)
with req.urlopen(request) as response:
    data = response.read().decode('utf-8')
# 解析JSON格式的资料，取得每篇文字的标题
import json
data = data.replace('要被替换的字符串','') # 要被替换的字符串为空
data = json.loads(data) # 把原始的JSON资料解析成字典或列表的表示形式
# 取得JSON资料中的文章标题
posts = data['payload']['references']['Post']
for key in posts:
    post = posts[key]
    print(post['title'])
