# filename = 'a.txt'
# with open(filename,'w',encoding='utf-8') as wfile:
#     wfile.write('奋斗成就更好的你')
path = './b.txt'
fp = open(path,'w',encoding='utf-8')
print('奋斗成就更好的你',file=fp)
fp.close()
