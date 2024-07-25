class Student:
    def __init__(self,name,age):
        self.nm = name
        self.ag = age
    def eat(self):
        print(self.nm + '在吃饭')

stu1 = Student('张三',20)
stu2 = Student('李四',30)
print(id(stu1))
print(id(stu2))
# 为stu1动态绑定性别属性
stu1.gender = '女'
print(stu1.nm,stu1.ag,stu1.gender)
def show():
    print('定义在类之外的，称为函数')
stu1.show = show
stu1.show()