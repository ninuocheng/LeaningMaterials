import prettytable as pt
#显示席座
def show_ticket(row_num):
    tb = pt.PrettyTable()
    tb.field_names = ['行号','座位1','座位2','座位3','座位4','座位5']
    for  i in range(row_num):
        lst = [f'第{i+1}行','有票','有票','有票','有票','有票']
        tb.add_row(lst)
    print(tb)
#订票
def order_ticket(row_num,row,column):
    tb = pt.PrettyTable()
    tb.field_names = ['行号', '座位1', '座位2', '座位3', '座位4', '座位5']
    for i in range(row_num):
        if int(row) == i + 1:
            lst = [f'第{i+1}行','有票','有票','有票','有票','有票']
            lst[int(column)] = '已售'
            tb.add_row(lst)
        else:
            lst = [f'第{i + 1}行', '有票', '有票', '有票', '有票', '有票']
            tb.add_row(lst)
    print(tb)

if __name__ == '__main__':
    row_num = 13
    show_ticket(row_num)
    choose_num = input('请输入选择的座位：(如13,5表示13排5号座位)')
    try:
        row,column = choose_num.split(',')
    except:
        print('输入格式有误，如13排5号座位,应该输入13,5')
    order_ticket(row_num,row,column)