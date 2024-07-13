def get_count(s,ch):
    count = 0
    for i in s:
        if ch.upper() == i or ch.lower() == i:
            count += 1
    return count
if __name__ == '__main__':
    s = 'hellopython,hellojava,hellogo'
    ch = input('请输入要统计的字符：')
    count = get_count(s,ch)
    print(f'{ch}在{s}中出现的次数为：{count}')