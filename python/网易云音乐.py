import requests # 数据请求模块 第三方模块 pip install requests
import re #正则表达式模块 内置模块 不需要安装
import os # 文件操作模块
filename = 'music1'
if not os.path.exists(filename): # 如果没有这个文件夹，就创建
    os.mkdir(filename)
url = 'https://music.163.com/discover/toplist?id=3778678'
#headers请求头，就是用来伪装Python代码的，把python代码伪装成浏览器对服务器发送请求
#服务器接收到请求之后，会给我们返回响应数据（response）
headers = {
    'accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.9',
    'accept-language': 'zh-CN,zh;q=0.9,en-US;q=0.8,en;q=0.7',
    'cookie': 'NTES_P_UTID=Y8yPYR5iJCSIg0ftCnoHK8XNIfbnnWcf|1718273763; P_INFO=ninuocheng@163.com|1718273763|0|mail163|00&99|gud&1717578080&carddav#gud&440300#10#0#0|152090&0||ninuocheng@163.com; nts_mail_user=ninuocheng@163.com:-1:1; NMTID=00OrC8EPq2-SFDViEzElqJ6auKpJBUAAAGQFGkgow; _iuqxldmzr_=32; _ntes_nnid=9fc7963d97da5478fbeaff41af2ae1f6,1718329351556; _ntes_nuid=9fc7963d97da5478fbeaff41af2ae1f6; WNMCID=lflsba.1718329353483.01.0; WEVNSM=1.0.0; WM_TID=yUWt3jWzTxRAQUFRFEbDFUJgeMdLUytA; sDeviceId=YD-IijvrNVIlVRER0QBUVLHURcxadcKRymi; ntes_utid=tid._.QzxVXYLWvRZAE0BFAUPCFAIkLYYOFz2k._.0; JSESSIONID-WYYY=AHZK%2Fjyu3%5C76QNW%5CXsNHDu9zsA6KP2XK%2FOdgENgTfYEUir3z9vKtpdp8sEZ39uEnBuGPEWeo%5CnF6QHQQ8%2B6%2FMkMS74%5CaSRTHf3exnzWtisF%2B6Umz7loosVl1EnaJonijS3qGYoFZIxT4lEnuYr2t05bkR8bO9N0mOzKFtbGNOdOFf%5Cwk%3A1719822739268; WM_NI=WzRsww5bFq311zOeucLdFIz4uZNTfGeE2wq7Fnfd9Gfkc9ZlZ2aeADVEFiNDYwFfxs1NeimTPtSwLNGOjrIomABmahXk8MC3pXd2X0%2Fez3KEsmbvv1QtIJHYfh5msDZASnE%3D; WM_NIKE=9ca17ae2e6ffcda170e2e6ee8dd23cfc9cae89d564a38a8ea2d15b878e9b83d24a98eda384e64db2f189d8f02af0fea7c3b92a95a69e94f67df7be8a92b23bf3a68186f86990bc8aaaf940b78682b5e54da79bfe98f43d86b2aa85bc4da6b5addad9689aeeaf86c450969b8a8acd509ba98a87fb79f392ab8af06094ac9d98cf468591a693cc65af9f8e8ee4649cb5f8aec239b488acd3db3cedbbb6d4ca4fb1b3ae97f53b93ac87abcb53a6b8fb8ef2509a9f9d8fc837e2a3',
    'referer': 'https://music.163.com/',
    'sec-ch-ua': '"Chromium";v="92", " Not A;Brand";v="99", "Google Chrome";v="92"',
    'sec-ch-ua-mobile': '?0',
    'sec-fetch-dest': 'iframe',
    'sec-fetch-mode': 'navigate',
    'sec-fetch-site': 'same-origin',
    'upgrade-insecure-requests': '1',
    'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36'
}
response = requests.get(url=url,headers=headers)
# print(response.text)
html_data = re.findall('<li><a href="/song\\?id=(\\d+)">(.*?)</a>',response.text)
# 正则表达式提取出来的内容是一个列表，元素是一个元组
# print(html_data)
for num_id,title in html_data:
    music_url = f'http://music.163.com/song/media/outer/url?id={num_id}.mp3'
    # 对于音乐播放地址发送请求，获取二进制数据内容
    music_content = requests.get(url=music_url,headers=headers).content
    # with open(filename + '\\' + title + '.mp3',mode='wb') as fp:
    with open(f'{filename}\\{title}.mp3', mode='wb') as fp:
        fp.write(music_content)
    print(num_id,title)