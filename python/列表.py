# lst = [20,40,10,98,54]
# print('排序前的列表',lst,id(lst))
# # 调用列表对象的sort()方法，默认升序排序
# lst.sort()
# print('排序后的列表',lst,id(lst))
# # 指定关键字的参数，进行降序排序 True表示降序，False表示升序
# lst.sort(reverse=True)
# print(lst,id(lst))
# lst.sort(reverse=False)
# print(lst,id(lst))
# print('---使用内置函数sorted()对列表进行排序，将产生一个新的列表对象-----')
# lst = [20,40,10,98,54]
# print('原列表',lst)
# # 开始排序
# new_lst = sorted(lst)
# print(lst)
# print(new_lst)
# # 指定关键字的参数，实现列表元素的降序排序
# desc_lst = sorted(lst,reverse=True)
# print(desc_lst)
# print()
lst1 = [i**2 for i in range(1,10)]
lst2 = [i*i for i in range(1,10)]
lst3 = [i*2 for i in range(1,6)]
print(lst3)