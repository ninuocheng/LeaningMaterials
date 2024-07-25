class Cpu:
    pass
class Disk:
    pass
class Computer:
    def __init__(self,cpu,disk):
        self.cpu = cpu
        self.disk = disk

# 变量的赋值
cpu1 = Cpu()
cpu2 = cpu1
print(cpu1,id(cpu1))
print(cpu2,id(cpu2))
# 类的浅拷贝
print('-----------------------类的浅拷贝---------------------------')
disk = Disk() # 创建一个硬盘类的对象
computer = Computer(cpu1,disk)
# 浅拷贝
import copy
computer2 = copy.copy(computer)
print(computer,computer.cpu,computer.disk)
print(computer2,computer2.cpu,computer2.disk)
print('---------------深拷贝---------------')
computer3 = copy.deepcopy(computer)