#网络排查
#查看所有网卡信息
ip link show
#查看指定网卡信息
ip link show 网卡名
#查看详细的网卡信息
ip -s link show
#关闭指定的网卡
ip link set 网卡名 down
#开启指定的网卡
ip link set 网卡名 up
#替换网卡eth1的name为eth2
ip link set eth1 name eth2
#设置eth1的mac地址
ip link set eth1 address 02:03:04:05:06
#开启混杂模式
ip link set eth1 promisc on
BROADCAST：
        该网卡支持广播,该网络设备可以将数据报传送给子网内的所有主机
MULTICAST ：
        该网卡支持组播包,该网络设备具有接收和发送多目传送（multicast）的能力
qdisc ：该网卡使用的排对算法
        noqueue表示不对数据包进行排队；
        noop 表示这个网络接口出于黑洞模式，也就是所有进入本网络设备的数据会直接被丢弃
LOOPBACK：
        表示这是一个回送设备，该接口发出的数据报不会被传到网络上；
pointtopoint：
        表示该网络设备是一个点对点连接的一端，所有该设备发出的数据报都将被对端节点所接收，所有对端发出的数据报也将被本设备所接收。
promisc：
        表示网络设备处于混杂模式，这时该设备将进行监听并将监听到的数据传递给内核，即使这些数据不是发送给该主机的。通常用于网络探测。
allmulti：
        表示网络设备将接收所有多目传送的数据报，通常用于多目传送路由器。
noapp ：
        这个参数在使用不同的协议时具有不同的意义。但通常表示不需要地址解析。
dynamic ：
        表示该网络设备可以动态的建立和删除。
slave：
        表示该网络设备与其他网络设备绑定在一起，形成逻辑上的一个网络设备。
link/ether：
        表示接口硬件类型，后面是网络设备的硬件地址；
brd：
         后面的是网络设备的硬件广播地址。
 
UP：
    代表网卡开启状态；如果是关闭状态则不显示UP（重要）
LOWER_UP：
    有说法是代表网卡的网线被接上，自己测试验证发现使用ifconfig eth0 down后，UP和LOWER_UP均不显示；使用ifconfig eth0 up后，UP和LOWER_UP均显示（重要）

如上，RX和TX显示了接收和发送了多少数据。
 
    bytes：表示已接收/发送的数据字节数
    packets：表示已接收/发送的数据报数目
    errors：表示在接收/发送时出现的错误次数，包括 too-long-frames 错误，Ring Buffer 溢出错误，crc 校验错误，帧同步错误，fifo overruns 以及 missed pkg 等等。
    dropped：由于资源不足而丢弃的数据包总数
    overrun：表示在接收数据包时，因为系统出现错误或系统反应太慢而导致丢包的数目
    mcast：收到的组播数据包总数
    carrier：表示物理连接出错的次数
    collsns：表示出现以太冲突的次数
#查看所有网卡及地址
ip -s addr show
#添加ip地址
ip addr add 192.168.10.1/24 dev eth1
#删除ip地址
ip addr del 192.168.10.1/24 dev eth1



ip link set DEVICE  { up | down | arp { on | off } | name NEWNAME | address LLADDR } 
选项说明：
dev DEVICE：指定要操作的设备名
up and down：启动或停用该设备
arp on or arp off：启用或禁用该设备的arp协议
name NAME：修改指定设备的名称，建议不要在该接口处于运行状态或已分配IP地址时重命名
address LLADDRESS：设置指定接口的MAC地址

停用 eth1网卡：
  ~ # ip link set eth1 down
启用 eth1网卡：
    ~ # ip link set eth1 up
等价于:
~ #  ifconfig eth1 down 或 ifconfig eth1 up

语法格式：
    ip [ -s | -h | -d ] link show [dev DEV] 
    选项说明：
    -s[tatistics]：将显示各网络接口上的流量统计信息；
    -h[uman-readable]：以人类可读的方式显式，即单位转换；
    -d[etails]：显示详细信息
	（选项说明可以通过ip help查看）
ip -s -h -d link show
