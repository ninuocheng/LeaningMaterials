awk擅长取列
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
