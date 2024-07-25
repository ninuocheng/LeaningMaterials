print('地铁\t\t\t\t四惠东➔苹果园')
dic = {'首车:': '05:05','末车:': '23:30\t  票价:起步价2元'}
for i in dic:
    print(f'\t\t{i}{dic[i]}')
print(''.ljust(96,'-'))
for i in range(1,12,2):
    if i == 1:
        print(f'   {i}\t\t ',end='')
    elif i == 9:
        print(f'{i}\t\t\t',end='')
    else:
        print(f'{i}\t\t',end='')
for i in range(12,21,2):
    print(f'{i}\t\t', end='')
print()
for i in [1,3,5,7,9,11,12,14,16,18,20]:
    if i == 1:
        print('   ⇌\t\t',end='')
    elif i == 9:
        print('⇌\t\t\t',end='')
    else:
        print('⇌',end='\t\t')
print()
for i in ['四惠东','大望路','水安里','东单','天安门东','西单','复兴门','木樨地','公主坟','五课松','八宝山']:
    if i == '四惠东':
        print(f' {i}\t',end='')
    elif i == '天安门东':
        print(f'\t {i}\t '.ljust(4,'\t'),end='')
    else:
        print(f'  {i} '.ljust(4,'\t'),end='')