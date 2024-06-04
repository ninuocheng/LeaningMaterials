#linux系统上查询ip地址归属
#查询本机外网ip
curl cip.cc（显示ipv4和地址信息） 或 curl ip.sb（只显示ipv4）
#查询指定的ip的归属地
curl cip.cc/ip
#批量查询ip的归属地
for i in $(cat iplist); do echo "$i";curl -s --user-agent foobar https://ip.cn/index.php?ip=$i | grep '<div id="tab0_address' |awk -F'[>|<]' '{print $3}'; done
