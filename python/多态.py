class Animal(object):
    def eat(self):
        print('动物要吃东西')
class Dog(Animal):
    def eat(self):
        print('狗吃肉')
class Cat(Animal):
    def eat(self):
        print('猫吃鱼')
class Person(Animal):
    def eat(self):
        print('人吃五谷杂粮')

def fun(animal):
    animal.eat()

fun(Cat())
fun(Dog())
fun(Animal())
fun(Person())