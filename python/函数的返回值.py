def fun(num):
    odd = [] # 奇数
    even= [] # 偶数
    for i in num:
        if i % 2:
            odd.append(i)
        else:
            even.append(i)
    return odd,even
print(fun([10,29,34,23,44,53,55]))