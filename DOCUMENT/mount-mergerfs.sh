#挂载mergerfs
df -h | grep -w 15T |awk '{printf $NF":"}' |awk '{print "mergerfs -o noforget,allow_other,use_ino,nonempty,minfreespace=65G,category.create=rand  "$1 "  /export"}'|bash
#重启nfs服务
systemctl restart nfs-server.service
