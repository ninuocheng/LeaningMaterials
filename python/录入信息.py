import os
filename = 'student1111.txt'
def main():
    while True:
        menu()
        while True:
            choice = input('请选择：')
            if not choice.isnumeric():
                print(f'输入的{choice}无效，请重新输入')
                continue
            choice_list = [0,1,2,3,4,5,6,7]
            if int(choice) in choice_list:
                if choice == '0':
                    answer = input('您确定要退出系统吗(y/n)?')
                    if answer == 'y' or answer == 'Y':
                        print('谢谢您的使用！！！')
                        exit()
                elif choice == '1':
                    insert()
                    break
                elif choice == '2':
                    search()
                    break
                elif choice == '3':
                    delete()
                    break
                elif choice =='4':
                    modify()
                    break
                elif choice == '5':
                    sort()
                    break
                elif choice == '6':
                    total()
                    break
                elif choice == '7':
                    show()
                    break
            else:
                print('输入有误，请重新输入')
                continue
def menu():
    print('学生信息管理系统'.center(20,'='))
    print('功能菜单'.center(22,'-'))
    print('1.录入学生信息'.center(20))
    print('2.查找学生信息'.center(20))
    print('3.删除学生信息'.center(20))
    print('4.修改学生信息'.center(20))
    print('5.排序学生信息'.center(20))
    print('6.统计学生人数'.center(20))
    print('7.显示学生信息'.center(20))
    print('0.退出管理系统'.center(20))
    print(''.center(20,'-'))
def checkfile():
    if not os.path.exists(filename):
        print(f'{filename}不存在')
        exit(1)
def inputid():
    id = input('请输入id(如1001)：')
    if not id.isnumeric():
        print(f'输入的{id}无效,请重新再选择输入')
        return False
    return id
def inputname():
    name = input('请输入姓名：')
    if name.isnumeric():
        print(f'输入的姓名的{name}无效,请重新再选择输入')
        return
    return name
def insert():
    student_list = []
    while True:
        id = inputid()
        if id:

        name = inputname()
        try:
            englist = int(input('请输入英语成绩：'))
            python = int(input('请输入Python成绩：'))
            java = int(input('请输入Java成绩：'))
        except:
            print('输入的成绩无效，请重新输入')
            continue
        student = {'id': id,'name': name,'english': englist,'python': python,'java': java}
        student_list.append(student)
        answer = input('是否继续添加(y/n)?')
        if answer == 'y':
            continue
        else:
            break
    save(student_list)
def save(student_list):
    student_file = open(filename,'a',encoding='utf-8')
    for item in student_list:
        student_file.write(str(item)+'\n')
    student_file.close()
    print(f'学生信息{student_list}录入完毕!!!')
def search():
    checkfile()
    student_query = []
    while True:
        id = ''
        name = ''
        mode = input('id查找输入1，姓名查找输入2：')
        if mode == '1':
            id = inputid()
        elif mode == '2':
            name = inputname()
        else:
            print(f'输入的{mode}有误，请重新输入')
            search()
        with open(filename,'r',encoding='utf-8') as rfile:
            student = rfile.readlines()
        for item in student:
            d = dict(eval(item))
            if id:
                if d['id'] == id:
                    student_query.append(d)
            elif name:
                if d['name'] == name:
                    student_query.append(d)
        show_student(student_query)
        student_query.clear()
        answer = input('是否要继续查询(y/n)?')
        if answer == 'y':
            continue
        else:
            break
def show_student(student_query):
    if len(student_query) == 0:
        print('没有查询到{}学生信息，无数据显示!!!')
        return
    format_title = '{:^6}\t{:^12}\t{:^8}\t{:^10}\t{:^10}\t{:^8}'
    print(format_title.format('ID','姓名','英语成绩','Python成绩','Java成绩','总成绩'))
    format_data = '{:^6}\t{:^12}\t{:^8}\t{:^10}\t{:^10}\t{:^8}'
    for item in student_query:
        print(format_data.format(item.get('id'),
                                 item.get('name'),
                                 item.get('english'),
                                 item.get('python'),
                                 item.get('java'),
                                 int(item.get('english')) + int(item.get('python')) + int(item.get('java'))
                                 ))
def delete():
    checkfile()
    while True:
        id = inputid()
        with open(filename,'r',encoding='utf-8') as file:
            student_old = file.readlines()
        flag = False
        if student_old:
            with open(filename,'w',encoding='utf-8') as wfile:
                for item in student_old:
                    d = dict(eval(item))
                    if d['id'] != id:
                        wfile.write(str(d) + '\n')
                    else:
                        flag = True
                if flag:
                    print(f'id为{id}的学生信息已被删除')
                else:
                    print(f'没有找到id为{id}的学生信息')
        else:
            print(f'录入的学生信息{student_old}为空')
            break
        show()
        answer = input('是否继续删除(y/n)?')
        if answer == 'y':
            continue
        elif answer == 'n':
            break
def modify():
    checkfile()
    show()
    with open(filename,'r',encoding='utf-8') as rfile:
        student_old = rfile.readlines()
    if not student_old:
        print(f'录入的学生信息{student_old}为空')
        return
    id = inputid()
    flag = False
    with open(filename,'w',encoding='utf-8') as wfile:
        for item in student_old:
            d = dict(eval(item))
            if d['id'] == id:
                flag = True
                print(f'找到id为{id}的学生信息{d}！！！')
                while True:
                    try:
                        d['name'] = input('请输入更新的姓名：')
                        d['english'] = input('请输入更新的英语成绩：')
                        d['python'] = input('请输入更新的Python成绩：')
                        d['java'] = input('请输入更新的Java成绩：')
                    except:
                        print('您的输入有误，请重新输入!!!')
                        continue
                    else:
                        break
                wfile.write(str(d) + '\n')
                print(f'修改成功为{d}!!!')
            else:
                wfile.write(str(d) + '\n')
    if not flag:
        print(f'没有找到id为{id}的学生信息')
    answer = input('是否继续修改学生信息(y/n)?')
    if answer == 'y':
        modify()
def sort():
    checkfile()
    show()
    with open(filename,'r',encoding='utf-8') as rfile:
        student_list = rfile.readlines()
    if not student_list:
        print(f'录入的学生信息{student_list}为空')
        return
    student_new = []
    for item in student_list:
        d = eval(item)
        student_new.append(d)
    asc_or_desc = input('请选择(0.升序 1.降序)')
    if asc_or_desc == '0':
        asc_or_desc_bool = False
    elif asc_or_desc == '1':
        asc_or_desc_bool = True
    else:
        print(f'您输入的{asc_or_desc}有误，请重新输入')
        sort()
    mode = input('请选择排序方式(1.英语成绩排序 2.Python成绩排序 3.Java成绩排序 0.总成绩排序)：')
    if mode == '1':
        student_new.sort(key=lambda x :int(x['english']),reverse=asc_or_desc_bool)
    elif mode == '2':
        student_new.sort(key=lambda x :int(x['python']),reverse=asc_or_desc_bool)
    elif mode == '3':
        student_new.sort(key=lambda x: int(x['java']), reverse=asc_or_desc_bool)
    elif mode == '0':
        student_new.sort(key=lambda x :int(x['english']) + int(x['python']) + int(x['java']),reverse=asc_or_desc_bool)
    else:
        print(f'您输入的{mode}有误，请重新输入')
        sort()
    show_student(student_new)
def total():
    checkfile()
    with open(filename, 'r', encoding='utf-8') as rfile:
        students = rfile.readlines()
    if students:
        print(f'一共有{len(students)}名学生')
    else:
        print(f'录入的学生信息{students}为空!!!')
def show():
    checkfile()
    student_list = []
    with open(filename,'r',encoding='utf-8') as rfile:
        students = rfile.readlines()
    if students:
        for item in students:
            student_list.append(eval(item))
        show_student(student_list)
    else:
        print(f'录入的学生信息{students}为空')
if __name__ == '__main__':
    main()