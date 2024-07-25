class A():
    pass
class B():
    pass
class C(A,B):
    def __init__(self,name,age):
        self.name = name
        self.age = age
class D(A):
    pass
# x是C类的一个实例对象
x = C('Jack',20)
# 实例对象的属性字典
print(x.__dict__)
print(C.__dict__)
# 对象所属的类
print(x.__class__)
# C类的父类
print(C.__bases__)
# 类的基类
print(C.__base__)
# 类的层次结构
print(C.__mro__)
# 子类
print(A.__subclasses__())