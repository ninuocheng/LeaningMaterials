year = [82,89,88,86,85,00,99]
print(f'原列表:{year}')
for index,value in enumerate(year):
    if value == 0:
        year[index] = '200' + str(value)
    else:
        year[index] = '19' + str(value)
print(f'修改后的列表{year}')
year.sort()
print(f'排序后的列表{year}')