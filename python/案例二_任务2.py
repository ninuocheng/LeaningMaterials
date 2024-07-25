lst_name = ['林黛玉','薛宝钗','贾元春','贾探春','史湘云']
lst_sig = ['❶','❷','❸','❹','❺']
# for i in range(5):
#     print(lst_sig[i],lst_name[i])
#
d = {'❶':'林黛玉','❷':'薛宝钗','❸':'贾元春','❹':'贾探春','❺':'史湘云'}
# for key,value in d.items():
#     print(key,value)
# for key in d.keys():
#     print(key,d[key])
# for key in d:
#     print(key,d[key])
for sig,name in zip(lst_sig,lst_name):
    print(sig,name)