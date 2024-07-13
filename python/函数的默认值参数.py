# 计算两个数的和
# def calc(a,b):
#     sum = a + b
#     return sum
# result = calc(10,2)
# print(result)
# 6的阶乘
# def fac(num):
#     if num == 1:
#         result = num
#         return result
#     else:
#         result = num * fac(num - 1)
#         return result
# res = fac(6)
# print(res)
# 斐波那契数列 1 1 2 3 5 8 13 数量特点：数列的第一个和第二个数值为1，后面的数值是前两个数值之和
# 定义一个函数求斐波那数列的第8项
def fib_seq(n):
    if n == 1:
        return 1
    elif n == 2:
        return 1
    else:
        result = fib_seq(n - 2) + fib_seq(n - 1)
        return result
res = fib_seq(2)
print(res)
# 定义一个函数求斐波那数列的前8项
lst = []
print(type(lst))
for i in range(1,9):
    lst.append(fib_seq(i))
    print(id(lst),type(lst))
print(lst)
