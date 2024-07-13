#awk擅长取列
awk '/root/' passwd #取包含root的行
awk '/root/;/adm/' passwd #取包含root和adm的行
awk '/root|adm/' passwd #取包含root和adm的行
awk '/adm/,/mail/' passwd #取adm到mail的行
awk 'NR==1' passwd #取第一行
awk 'NR==1,NR==3' passwd #取第一行到第三行
awk 'NR==1;NR==3' passwd #取第一行和第三行
awk '{print NR,$0}' passwd #显示所有行号
cat -n passwd #显示所有行号
awk '!/sbin/' passwd #取不包含sbin的行
awk引用shell变量
方法1:
awk -v var=$1 -F: '$1==var{print NR,$0}' /etc/passwd #第一个$1是位置变量，第二个$1是awk逐行处理的第一个字段
方法2:
var=$1
awk -F: '$1=="'$var'"{print NR,$0}' /etc/passwd
#!/bin/bash
UserName=$1
awk -F: -v UserName=$UserName '$1==UserName{print}' /etc/passwd
#!/bin/bash
UserName=$1
awk -F:  '$1=="'$UserName'"{print}' /etc/passwd

awk的if和for循环
awk -F : '{if($3 == 0){print $1"是超级用户";num1++;}else if($3>1 && $3 <1000){print $1"是系统用户";num2++;}else{print $1 "是普通用户";num3++;}}END{print"超级用户有："num1"系统用户有："num2"普通用户有："num3}' passwd 
awk数组

awk -F',' '{
    array[$1] = $2
}
END{
    for(i in array)
        print i, array[i]
}' file.txt
awk '{access[$1]+=$10}END{for (i in access) print i,access[i]}' access.log |sort -k 2 -nr|head -100
awk '{vote[$1]+=$3}END{for (i in vote) print i,vote[i]}' lianxi.txt | sort -n -k 2
awk '{a[$5]+=$5}ENDfor (i in a) print i,a[i]}' 3.txt
length()函数
substr()函数
#输出密码字段长度小于2并且输出用户名字段的前2个字符，统计个数输出出来
awk -F : 'length($2)<=2 {print substr($1,1,2);num++}END{print num}' passwd
awk -F "|" '{print substr($1,1,16),$6}' nginx.log
awk -F "|" '{bandwidth[substr($1,1,16)]+=$6}END{for (i in bandwidth) print i,bandwidth[i]}' nginx.log 
awk列求和
统计/etc目录下以.conf结尾的文件总大小
find /etc/ -type f -name "*.conf" |xargs ls -l |awk '{sum+=$5}END{print sum}'
#如果要匹配第一列的才累加，需要用到awk数组和for循环
cat 文件 |cut -d'' -f7,8 |sort -n > file1
awk '{a[$1]+=$2}END{for(i in a)print i,a[i]}' |sort -rnk2
awk '/export/{sum+=$6}{print $0 ,sum}' windowlog
awk行求和
echo 3 54 53 13|awk '{for(i=1;i<=NF;i++) sum+=$i;print sum}'
seq -s ' ' 100 |awk '{for(i=1;i<=NF;i++) sum+=$i;print sum}'
