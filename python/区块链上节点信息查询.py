import json
import datetime
from datetime import date
import urllib.request
def main():
    while True:
        menu()
        choice_lst = [0,1,2,3,4,5,6,7]
        choice = input('请选择：')
        choice = int(choice)
        if choice in choice_lst:
            if choice == 0:
                print('欢迎您再次使用！')
                exit()
            elif choice == 1:
                block_info()
            elif choice == 2:
                parent_block()
            elif choice == 3:
                block_reward()
            elif choice == 4:
                window_post()
            elif choice == 5:
                message_info()
            elif choice == 6:
                check_deadline()
            elif choice == 7:
                deadline_fault()
def menu():
    print('区块链上节点信息查询管理系统'.center(30,'='))
    print('功能菜单'.center(30,'-'))
    print('0.退出节点信息查询管理系统')
    print('1.区块高度的区块列表信息')
    print('2.区块高度的父区块列表信息')
    print('3.昨天出块的列表消息')
    print('4.当前抽查的窗口信息')
    print('5.最新上链的窗口消息')
    print('6.所有窗口的抽查情况')
    print('7.查看错误扇区的窗口')
def create_request(url):
    headers = {
        'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36'
    }
    request = urllib.request.Request(url=url,headers=headers)
    return request
def get_content(request):
    with urllib.request.urlopen(request) as response:
        content = json.load(response)
    return content
def block_info():
    while True:
        height = input('请输入要查询的区块高度：')
        # if not height:

        url = f'https://api.filutils.com/api/v2/tipset/{height}'
        request = create_request(url)
        content = get_content(request)
        miner_lst = []
        cid_lst = []
        blocks = content['data']['blocks']
        for item in blocks:
            miner_lst.append(item['miner'])
            cid_lst.append(item['cid'])
        print(f'{height}的区块列表信息：{miner_lst}\n对应的区块哈希列表信息：{cid_lst}')
        answer = input('回车继续，q回退到功能菜单:')
        if answer == 'q':
            break
def parent_block():
    while True:
        height = int(input('请输入要查询的区块高度：'))
        url = f'https://api.filutils.com/api/v2/tipset/{height - 1}'
        request = create_request(url)
        content = get_content(request)
        miner_lst = []
        cid_lst = []
        blocks_lst = content['data']['blocks']
        for item in blocks_lst:
            miner_lst.append(item['miner'])
            cid_lst.append(item['cid'])
        print(f'{height}的父区块列表信息：{miner_lst}\n对应的父区块哈希列表信息：{cid_lst}')
        answer = input('回车继续，q回退到功能菜单:')
        if answer == 'q':
            break
def block_reward():
    while True:
        sum = 0
        num = -1
        page_num = 3
        reward_sum = 0
        now_date = date.today()
        miner_id = input('请输入要查询的矿工号：')
        check_date = now_date + datetime.timedelta(days=num)
        print(f'{miner_id} {check_date}的出块列表:')
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
                reward = item['reward']
                minerDate = mineTime.split()[0]
                reward_value = reward.split()[0]
                reward_value = float(reward_value)
                if str(minerDate) == str(check_date):
                    print(item)
                    sum += 1
                    reward_sum += reward_value
                else:
                    continue
        print('出块数量: {0}, 出块奖励: {1:.2f} FIL'.format(sum,reward_sum))
        answer = input('回车继续，q回退到功能菜单:')
        if answer == 'q':
            break
def window_post():
    while True:
        miner_id = input('请输入要查询的矿工号：')
        url = f'https://api.filutils.com/api/v2/miner/{miner_id}/deadline'
        request = create_request(url)
        content = get_content(request)
        data_lst = content['data']
        for item in data_lst:
            current = item['current']
            if current == '(current)':
                print(f'{miner_id}当前抽查的窗口信息:\n{item}')
        answer = input('回车继续，q回退到功能菜单:')
        if answer == 'q':
            break
def check_deadline():
    while True:
        miner_id = input('请输入要查询的矿工号：')
        url = f'https://api.filutils.com/api/v2/miner/{miner_id}/deadline'
        req = create_request(url)
        content =get_content(req)
        date_lst = content['data']
        print(f'{miner_id}最近抽查的所有窗口历史记录:')
        for item in date_lst:
            live = int(item['live'])
            current = item['current']
            fault = item['fault']
            if live > 0:
                deadLineId = item['deadLineId']
                sectors = item['sectors']
                active = item['active']
                recovery = item['recovery']
                terminated = item['terminated']
                openTime = item['openTime']
                dct = {'deadLineId':deadLineId, 'sectors':sectors, 'live':live, 'active':active, 'fault':fault, 'recovery':recovery, 'terminated':terminated,'current':current, 'openTime':openTime}
                print(dct)
            if current == '(current)':
                print(f'{miner_id}当前抽查的窗口信息:\n{item}')
        answer = input('回车继续，q回退到功能菜单:')
        if answer == 'q':
            break
def deadline_fault():
    while True:
        miner_lst = []
        miner_id = input('请输入要查询的矿工号:(如果不输入，回车查询所有)')
        if miner_id:
            miner_lst.append(miner_id)
        else:
            miner_lst = ['f01250983', 'f0513878', 'f01530777', 'f01044086', 'f01527777', 'f01990005', 'f01521158', 'f01264518', 'f01666880', 'f01417791', 'f01609999', 'f090387', 'f01777777', 'f01520487', 'f01038389', 'f0469055', 'f01416862', 'f0753213', 'f02236965', 'f0716775', 'f02229760', 'f0428661', 'f01699999', 'f01658888', 'f01656666', 'f0503420', 'f01566485', 'f01699876', 'f01098835', 'f01538000', 'f02528', 'f0723827', 'f01777770', 'f02239698', 'f02836080', 'f02836091', 'f0845296']
        for miner_id in miner_lst:
            url = f'https://api.filutils.com/api/v2/miner/{miner_id}/deadline'
            req = create_request(url)
            content =get_content(req)
            date_lst = content['data']
            name = f'{miner_id}有错误扇区的窗口:'
            for item in date_lst:
                live = int(item['live'])
                current = item['current']
                fault = item['fault']
                if fault > 0:
                    if name:
                        print(name)
                        name = ''
                    deadLineId = item['deadLineId']
                    sectors = item['sectors']
                    active = item['active']
                    recovery = item['recovery']
                    terminated = item['terminated']
                    openTime = item['openTime']
                    dct = {'deadLineId':deadLineId, 'sectors':sectors, 'live':live, 'active':active, 'fault':fault, 'recovery':recovery, 'terminated':terminated,'current':current, 'openTime':openTime}
                    print(dct)
        answer = input('回车继续，q回退到功能菜单:')
        if answer == 'q':
            break
def message_info():
    while True:
        miner_id = input('请输入要查询的矿工号：')
        url = 'https://api.filutils.com/api/v2/actor/message'
        headers = {
            'content-type': 'application/json;charset=UTF-8',
            'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.159 Safari/537.36'
        }
        data = {
            'address': miner_id,
            'method': '',
            'pageIndex': 1,
            'pageSize': 20
        }
        data = json.dumps(data).encode('utf-8')
        request = urllib.request.Request(url=url,headers=headers,data=data)
        with urllib.request.urlopen(request) as response:
            content = json.load(response)
        message_lst = content['data']
        for item in message_lst:
            if item['method'] == 'SubmitWindowedPoSt':
                url = f'https://api.filutils.com/api/v2/message/{item['cid']}'
                request = create_request(url)
                content = get_content(request)
                data = content['data']
                cid = data['cid']
                height = data['height']
                time = data['time']
                fee = data['fee']
                method = data['method']
                From = data['from']
                to = data['to']
                paramsRes = data['paramsRes']
                Deadline = paramsRes['Deadline']
                Partitions = paramsRes['Partitions']
                message = f'cid: {cid}, height: {height}, time: {time}, fee: {fee}, method: {method}, from: {From}, to: {to}, Deadline: {Deadline}, Partitions: {str(Partitions)}'
                print(f'{miner_id}最新上链的窗口消息:\n{message}')
                break
        answer = input('回车继续，q回退到功能菜单:')
        if answer == 'q':
            break
if __name__ == '__main__':
    main()