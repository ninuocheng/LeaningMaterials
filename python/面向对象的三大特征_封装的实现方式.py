# class Car:
#     def __init__(self,brand):
#         self.brand = brand
#     def start(self):
#         print('汽车已启动...')
# car = Car('宝马X5')
# car.start()
# print(car.brand)
class Student:
    def __init__(self,name,age):
        self.name = name
        self.__age = age # 两个_表示在类之外不希望被使用
    def show(self):
        print(self.name,self.__age)
stu = Student('张三',20)
stu.show()
print(stu.name)
print(dir(stu))
print(stu._Student__age) # 在类之外__age不希望被使用，但可以通过_Student__ag使用