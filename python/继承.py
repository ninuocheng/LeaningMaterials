class Person(object):
     def __init__(self,name,age):
         self.name = name
         self.age = age
     def info(self):
         # print('姓名: {0},年龄: {1}'.format(self.name,self.age))
         # print(f'姓名: self.name,年龄: self.age')
         print('姓名: %s,年龄: %d' % (self.name,self.age))


# 定义子类
class Student(Person):
    def __init__(self,name,age,score):
        super().__init__(name,age)
        self.score = score
# 测试
stu = Student('Jack',20,1001)
stu.info()