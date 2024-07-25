# class Person(object):
#     def __init__(self,name,age):
#         self.name = name
#         self.age = age
#     def info(self):
#         print('姓名：%s,年龄：%d' % (self.name,self.age))
#     def __str__(self):
#         return '姓名: %s,年龄：%d'  % (self.name,self.age)
# o = object
# p = Person('Jack',20)
# print(dir(o))
# print(dir(p))
# print(p)
class Student:
    def __init__(self,name,age):
        self.name = name
        self.age = age
    def __str__(self):
        return '我的名字是{0}，今年{1}岁'.format(self.name,self.age)

stu = Student('jack',20)
print(dir(stu))
print(stu)