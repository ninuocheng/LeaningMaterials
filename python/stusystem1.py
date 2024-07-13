# import os
# filename = 'a.txt'
# def sort():
#     if os.path.exists(filename):
#         with open(filename,'r') as rfile:
#             student_list = rfile.readlines()
#             print(student_list)
#         student_new = []
#         for item in student_list:
#             print(item,type(item))
#             d = dict(eval(item))
#             print(d,type(d))
#             student_new.append(d)
#             print(student_new)
#     else:
#         return
# sort()
#
# id = input('请输入ID: ')
# if not id:
#     print('1')
#     print(bool(id))
# else:
#     print(2)
#     print(bool(id))
filename = 'test1.txt'
with open(filename,'a',encoding='utf-8') as wfile:
    for i in range(11):
        position = wfile.tell()
        print(position)
        wfile.write(str(i) + '\n')
# with open(filename,'w',encoding='utf-8') as wfile:
#     wfile.write('hello')
# with open(filename, 'w', encoding='utf-8') as wfile:
#     wfile.write('world')