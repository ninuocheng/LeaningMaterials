import json
import urllib.request

def main():
    menu()
    choice_lst = [0,1,2,3]
    choice = input('请选择：')
    choice = int(choice)
    if choice in choice_lst:
        if choice == 0:
            print('谢谢您的使用！')
            exit()
        elif choice == 1:
            request = create_request(miner_id)
            content = get_content(request)
            account_balance(content)
        elif choice == 2:
            power_view()
        elif choice == 3:
            accout_view()
def menu():
    print('矿工节点链上信息查询'.center(30,'='))
    print('功能菜单'.center(30,'-'))
    print('1.账户余额')
    print('2.算力概览')
    print('3.账户概览')

def create_request(miner_id):
    url = f'https://api.filutils.com/api/v2/miner/{miner_id}'
    print(url)
    headers = {
        'accept': '*/*',
        'accept-language': 'zh-CN,zh;q=0.9,en-US;q=0.8,en;q=0.7',
        'cache-control': 'no-cache',
        'content-length': '0',
        'locale': 'zh',
        'origin': 'https://www.filutils.com',
        'pragma': 'no-cache',
        'referer': 'https://www.filutils.com/',
        'sec-ch-ua': '"Chromium";v="92", " Not A;Brand";v="99", "Google Chrome";v="92"',
        'sec-ch-ua-mobile': '?0',
        'sec-fetch-dest': 'empty',
        'sec-fetch-mode': 'cors',
        'sec-fetch-site': 'same-site',
        'content-type': 'application/json;charset=UTF-8',
        'token': '',
        'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36'
    }
    request = urllib.request.Request(url=url,headers=headers)
    return request

def get_content(request):
    with urllib.request.urlopen(request) as response:
        content = response.read().decode('utf-8')
    return content
def account_balance(content):
    print(content)
def power_view():
    pass
def accout_view():
    pass

if __name__ == '__main__':
    # miner_id = input('请输入要查询的矿工号：')
    # main()
    miner_id = 'f02528'
    request = create_request(miner_id)
    # content = get_content(request)
    print(request)
    # account_balance(content)