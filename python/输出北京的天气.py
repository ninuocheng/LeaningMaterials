print('星期日','今天')
print(''.ljust(36,'-'))
for i in range(8,24,3):
    print(f'{i}时'.zfill(3),end=' ')
print()
temp_list = [0,6,10,4,1,0]
for i in temp_list:
    print(f'{i}°C'.ljust(4),end=' ')
print()
print(''.ljust(36,'-'))
# print('明天','\t 2/23','\t 2°C/11°C')
dic_list = {'明天': '2/23\t2°C/11°C','星期二': '2/24\t0°C/9°C','星期三': '2/25\t-2°C/8°C','星期四': '2/26\t-3°C/6°C','星期五': '2/27\t-2°C/7°C','星期六': '2/28\t1°C/11°C'}
for i in dic_list:
    print(i,'\t',dic_list[i])
