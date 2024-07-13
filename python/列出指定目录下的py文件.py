# import os
# path = os.getcwd()
# lst_file = os.listdir(path)
# for filename in lst_file:
#     if filename.endswith('.py'):
#         print(filename)
import os
path = os.getcwd()
lst_files = os.walk(path)
print(lst_files)
for dirpath,dirname,filename in lst_files:
    print(dirpath)
    print(dirname)
    print(filename)
    print('------------------------1')
    for dir in dirname:
        print(os.path.join(dirpath,dir))
        print('------------------------------2')
    for file in filename:
        print(os.path.join(dirpath,file))
        print('---------------------------------3')