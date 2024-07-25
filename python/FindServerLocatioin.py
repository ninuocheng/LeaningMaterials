import os.path
import time

filename = 'DongguanMachineRoom.txt'

def main():
    while True:
        menu()
        try:
            choice = int(input('请选择: '))
        except:
            print(f'输入的无效,请重新选择')
            continue
        if choice == 0:
            exit()
        elif choice == 1:
            FindLocation()
        else:
            print(f'输入的有误,请重新选择')

def menu():
    print('功能菜单'.center(30,'-'))
    print('0.退出 1.查找ip地址的位置')
def FindLocation():
    if not os.path.exists(filename):
        print(f'{filename}不存在,请检查')
        time.sleep(10)
        exit()
    ipAddress = input('请输入要查找的ip地址: ')
    with open(filename, mode='r', encoding='utf-8') as rfile:
        content = rfile.readlines()
    for item in content:
        if ipAddress in item:
            print(item)
    print(f'{ipAddress} not find')
if __name__ == '__main__':
    main()