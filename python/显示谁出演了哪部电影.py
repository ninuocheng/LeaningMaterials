lst = [{'rating': [9.7,50],'id': '1292052','type': ['犯罪','剧情'],'title': '肖申克的救赎','actors': ['蒂姆.罗宾斯',' 摩根.弗里曼']},{'rating': [9.6,50],'id': '1291546','type': ['剧情','爱情','同性'],'title': '霸王别姬','actors': ['张国荣','张丰毅','巩俐','葛优']},{'rating': [9.6,50],'id': '1296141','type': ['剧情','犯罪','悬疑'],'title': '控方证人','actors': ['泰隆.鲍华','玛琳.黛德丽']}]
name = input('请输入你要查询的演员：')
# 遍历列表的元素
for item in lst:
    print(item)
    print(item['actors'])
    print(item['title'])
    # 演员
    actor_lst = item['actors']
    if name in item['actors']:
        print(name,'出演了',item['title'])

# dict = {'rating': [9.7,50],'id': '1292052','type': ['犯罪','剧情'],'title': '肖申克的救赎','actors': ['蒂姆.罗宾斯',' 摩根.弗里曼']}
# print(dict['id'])