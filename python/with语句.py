'''
with语句(上下文管理器)
with语句可以自动管理上下文资源，不论什么原因跳出with块，都能确保文件正确的关闭，以此来达到释放资源的目的
with open('文件名称','模式') as 别名:
    别名.read()
离开运行时上下文，自动调用上下文管理器的特殊方法__exit__()
'''
# print(type(open('a.txt','r')))
# with open('a.txt','r') as file:
#     content = file.read()
#     print(content)
'''
MyCountMgr实现了特殊方法__enter__(),__exit__()
该类对象遵守了上下文管理器协议
该类对象的实例对象称为上下文管理器
'''
# class MyCountMgr(object):
#     def __enter__(self):
#         print('enter方法被调用执行了')
#         return self
#     def __exit__(self, exc_type, exc_val, exc_tb):
#         print('exit方法被调用执行了')
#     def show(self):
#         print('show方法被调用执行了')
# with MyCountMgr() as file:
#     file.show()
with open('copylogo.jpg','rb') as src_file:
    with open('copylogo1.jpg','wb') as target_file:
        target_file.write(src_file.read())