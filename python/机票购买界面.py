dic={'国内': '✈','♜': '国际.港澳台','↘': '发现低价'}
for i in dic:
    print(f'{i}{dic[i]}',end=' ')
print()
print(''.ljust(36,'-'))
dic1 = {'航班类型': '\t ☉单程 ☉往返 ☉多程(含缺口程)','出发城市:': '北京','达到城市:': '长春','出发日期:': '2020-3-8','返回日期:': 'yyyy-MM-dd'}
for i in dic1:
    print(f'{i}{dic1[i]}')
print(''.ljust(36,'-'))
print('□带儿童\t□带婴儿'.center(24))
print('------'.center(26))
print('｜_搜索_｜'.center(24))