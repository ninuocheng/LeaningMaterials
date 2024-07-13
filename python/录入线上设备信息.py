import os
filename = 'D:\\bak/资料/onlinedeviceinfo'
def main():
    while True:
        menu()
        while True:
            choice = input('请选择：')
            if not choice.isnumeric():
                print(f'输入的{choice}无效，请重新输入')
                continue
            choice_list = [0,1,2,3,4,5,6]
            if int(choice) in choice_list:
                if choice == '0':
                    answer = input('您确定要退出系统吗(y/n)?')
                    if answer == 'y' or answer == 'Y':
                        print('谢谢您的使用！！！')
                        exit()
                elif choice == '1':
                    insert()
                elif choice == '2':
                    search()
                elif choice == '3':
                    delete()
                elif choice =='4':
                    modify()
                elif choice == '5':
                    total()
                elif choice == '6':
                    show()
            else:
                print('输入有误，请重新输入')
                continue
def menu():
    ondeviceinfo = '线上设备信息'
    mgsys = '管理系统'
    print(f'{ondeviceinfo}{mgsys}'.center(30,'='))
    print('功能菜单'.center(34,'-'))
    print(f'1.录入{ondeviceinfo}'.center(30))
    print(f'2.查找{ondeviceinfo}'.center(30))
    print(f'3.删除{ondeviceinfo}'.center(30))
    print(f'4.修改{ondeviceinfo}'.center(30))
    print(f'5.统计{ondeviceinfo}'.center(30))
    print(f'6.显示{ondeviceinfo}'.center(30))
    print(f'0.退出设备{mgsys}'.center(30))
    print(''.center(36,'-'))
def checkfile():
    if not os.path.exists(filename):
        print(f'{filename}不存在')
        exit(1)
def insert():
    info_list = []
    while True:
        ip = input('请输入ip地址(如172.25.11.1)：')
        location = input('请输入机柜位置(如A203 A01 3-6)：')
        sn = input('请输入序列号：')
        stype = input('请输入设备类型：')
        info_dict = {'类型': stype,'设备位置': location,'序列号': sn,'ip': ip}
        info_list.append(info_dict)
        answer = input('是否继续添加(y/n)?')
        if answer == 'y':
            continue
        else:
            break
    save(info_list)
def save(info_list):
    info_file = open(filename,'a',encoding='utf-8')
    for item in info_list:
        info_file.write(str(item) + '\n')
    info_file.close()
    print(f'{info_list}录入完毕!!!')
def search():
    checkfile()
    if not bool(show()):
        return
    info_query = []
    while True:
        ip = input('请输入ip：')
        with open(filename,'r',encoding='utf-8') as rfile:
            deviceinfo = rfile.readlines()
        for item in deviceinfo:
            d = dict(eval(item))
            if d['ip'] == ip:
                info_query.append(d)
        if info_query:
            show_info(info_query)
            info_query.clear()
        else:
            print(f'没有查找到{ip}的信息')
        answer = input('是否要继续查询(y/n)?')
        if answer == 'y':
            continue
        elif answer == 'n':
            break
def show_info(info_query):
    format_title = '{:^6}\t{:^18}\t{:^22}\t{:^13}'
    print(format_title.format('类型','设备位置','序列号','ip'))
    format_data = '{:^6}\t{:^20}\t{:^25}\t{:^10}'
    for item in info_query:
        print(format_data.format(item.get('类型'),
                                 item.get('设备位置'),
                                 item.get('序列号'),
                                 item.get('ip')
                                 ))
def delete():
    checkfile()
    if not bool(show()):
        return
    while True:
        ip = input('请输入ip：')
        with open(filename,'r',encoding='utf-8') as file:
            info_old = file.readlines()
        flag = False
        if info_old:
            with open(filename,'w',encoding='utf-8') as wfile:
                for item in info_old:
                    d = dict(eval(item))
                    if d['ip'] != ip:
                        wfile.write(str(d) + '\n')
                    else:
                        flag = True
                if flag:
                    print(f'ip为{ip}的设备信息已被删除')
                else:
                    print(f'没有找到ip为{ip}的设备信息')
        else:
            print(f'录入的设备信息{info_old}为空')
            break
        show()
        answer = input('是否继续删除(y/n)?')
        if answer == 'y':
            continue
        elif answer == 'n':
            break
def modify():
    checkfile()
    if not bool(show()):
        return
    with open(filename,'r',encoding='utf-8') as rfile:
        info_old = rfile.readlines()
    ip = input('请输入ip：')
    flag = False
    with open(filename,'w',encoding='utf-8') as wfile:
        for item in info_old:
            d = dict(eval(item))
            if d['ip'] == ip:
                flag = True
                print(f'找到ip为{ip}的设备信息{d}')
                while True:
                    d['类型'] = input('请输入更新的类型：')
                    d['设备位置'] = input('请输入更新的设备位置：')
                    d['序列号'] = input('请输入更新的序列号：')
                    d['ip'] = input('请输入更新的ip：')
                    break
                wfile.write(str(d) + '\n')
                print(f'修改成功为{d}!!!')
            else:
                wfile.write(str(d) + '\n')
    if not flag:
        print(f'没有找到ip为{ip}的设备信息')
    answer = input('是否继续修改设备信息(y/n)?')
    if answer == 'y':
        modify()
def total():
    checkfile()
    with open(filename, 'r', encoding='utf-8') as rfile:
        info_list = rfile.readlines()
    if info_list:
        print(f'设备总计有{len(info_list)}个')
    else:
        print(f'录入的设备信息{info_list}为空')
def show():
    checkfile()
    info_list = []
    with open(filename,'r',encoding='utf-8') as rfile:
        info = rfile.readlines()
    flag = False
    if info:
        flag =True
        for item in info:
            info_list.append(eval(item))
        show_info(info_list)
    else:
        print(f'录入的设备信息{info}为空')
    return flag
if __name__ == '__main__':
    main()