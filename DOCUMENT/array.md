数组的概念：
定义数组方法
数组：（30 20 60）
索引值：0 1 2
方法一：
数组名=(value1 value2 value3)
方法二:
数组名=([0]=value1 [1]=value2 [3]=value3)
方法三:
列表名="value1 value2 value3"
数组名=($列表名)
方法四:
数组名[0]="value1"
数组名[1]="value2"
数组名[2]="value3"
获取的数组长度：
array1=(1 3 4 5)
echo ${#array1[*]}或echo ${#array1[@]}
读取下标的元素值
方法1:
array1=(1 3 4 5)
echo ${array1[索引值]}
数组遍历
array1=(1 3 4 5)  #定义数组
for i in ${array1[*]}  #遍历数组的元素值
do
     echo $i   #查看元素值
done
方法2:
array1=(1 3 4 5)  #定义数组
for i in ${!array1[*]} #遍历数组的索引值
do
     echo array1[$i]  #查看索引对应的元素值
done
方法3:
array1=(1 3 4 5) #定义数组
for i in `seq ${#array1[*]}` #遍历数组的数量值，起始值1至数组的长度${#array1[*]}=4
do
     echo array1[$i-1] #数量值$i减1对应到元素的索引值
done
数组切片:
array1=(1 3 4 5)
echo ${array1[@]} #查看数组的元素值
echo ${array1[@]:0:2} #查看数组的起始索引为0，长度为2的元素值
数组替换：
格式：${数组名[*或@]/原元素值/新元素值}
array1=(1 3 4 5)
临时替换：
echo ${array1[*]/3/66} #将数组array1的元素值3替换为66，但原来的数组元素值不会改变
永久替换：
array1=(${array1[*]/3/66})  #重新赋值给数组
删除数组：
格式： unset 数组名[索引值]  #删除索引对应的元素
             unset 数组名 #删除整个数组
