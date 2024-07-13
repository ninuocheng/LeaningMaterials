a = 12
b = 23
c = a + b
d = a.__add__(b)
print(c,d)

class Student:
    def __init__(self,name):
        self.name = name
    def __add__(self, other):
        return self.name + other.name
    def __len__(self):
        return len(self.name)
stu1 = Student('Jack')
stu2 = Student('李四')
# 实现了两个对象的加法运算（因为在Student类中，编写了__add__()特殊的方法）
result = stu1 + stu2
print(result)
res = stu1.__add__(stu2)
print(res)
print(len(stu1),len(stu2))