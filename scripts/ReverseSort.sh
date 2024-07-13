#!/bin/bash
#以相反的顺序把原有数组的内容重新排序。
#基本思想:
#把数组最后一个元素与第一个元素替换，倒数第二个元素与第二个元素替换，以此类推，直到把所有数组元素反转替换
array=(60 20 30 50 10 40 70)
echo "反转前顺序：${array[*]}"  
length=${#array[*]}
for ((i=0;i<$length/2;i++))
do
  temp=${array[$i]}
  array[$i]=${array[$length-1-$i]}
  array[$length-1-$i]=$temp
  echo "$i ${array[*]}"
done
echo "反转排序后：${array[*]}"
