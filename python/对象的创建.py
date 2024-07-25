# Python中一切皆是对象
# Student为类的名称（类名），由一个或多个单词组成，每个单词的首字母大写，其余小写
class Student:
    # 类里的变量成为类属性
    native_place = '吉林'
    # self.name称为实体属性，进行了一个赋值的操作，将局部变量name的值赋给实体属性
    def __init__(self,name,age):
        self.name = name
        self.age = age
    # 在类之外定义的称为函数，在类之内定义的称为方法
    # 实例方法
    def eat(self):
        print('学生在吃饭...')
    # 静态方法
    @staticmethod
    def method():
        print('使用staticmethod进行修饰的是静态方法')
    @classmethod
    def cm(cls):
        print('使用classmethod进行修饰的是类方法')
# 创建Student类的对象
stu1 = Student('张三',20)
stu1.eat()
print(stu1.name,stu1.age)
Student.eat(stu1)