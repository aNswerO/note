# 集群和分布式：
+ 集群（cluster）：
    >为解决某个特定问题将多台计算机组合起来形成的单个系统；可理解为对服务的横向扩展
    + 同一个**业务系统**，部署在多台服务器上

    + 集群中每一台服务器实现的功能都是一样的
+ 分布式系统（distribution）：
    >多台服务器协同工作完成一个任务；可理解为对业务的纵向拆分
    + 不同的**业务**部署在不同服务器上

    + 每台服务器实现的功能是有差别的

# LVS（Linux Virtual Server）：
>LVS作用于iptables中的prerouting链和input链之间，即接收到请求后在俩链之间将请求进行处理后直接经由postrouting转出VS；  
VS根据请求报文的目标IP和目标协议及端口，根据调度算法将其调度转发至某RS
## LVS集群中的术语：
+ **VS**：virtual server；负责调度的服务器

+ **RS**：real server；真正负责提供服务的服务器
+ **CIP**：客户端IP
+ **VIP**：**VS**的外网IP
+ **DIP**：**VS**的内网IP
+ **RIP**：**RS**的IP

## LVS集群的工作模式：
+ lvs-nat：修改请求报文中的目标IP；相当于多目标IP的DNAT

+ lvs-dr：操纵封装新的MAC地址
+ lvs-tun：在原请求IP报文之外新加一个IP首部
+ lvs-fullnat：修改请求报文的源、目标IP

## LVS的调度算法：
+ 静态算法：仅根据算法本身进行调度
    + RR（Round-Robin）：轮询

    + WRR（Weight RR）：加权轮询
    + SH（Source Hashing）：源IP地址hash；实现session sticky，将来自同一IP地址的请求始终发往第一个被调度的RS，从而实现会话绑定
    + DH（Destination Hashing）：目标地址hash；第一次轮询调度至某RS，后续将发往同一IP地址的请求始终转发至这个RS

+ 动态算法：根据每个RS当前的**负载状态**和调度算法进行调度；通过overhead（系统开销）的值来判断，值越小，调度的优先级越高，每种算法计算overhead的公式不同
    + LC（Least Connection）：最小连接；适用于长连接应用
        ```sh
        overhead = activeconns*256 + inatciveconns
        #activeconns：活动连接
        #inactiveconns：非活动连接
        ```
    + WLC（Weight LC）：加权最小连接；默认的调度算法
        ```sh
        overhead = (activeconns*256 + inatciveconns)/weight
        ```
    + SED（Shortest Expection Delay）：最短预期延时调度
        ```
        Overhead=(activeconns+1)*256/weight
        ```
    + NQ（Nerver Queue）：不排队调度；第一轮均匀分配，后续使用SED
    + LBLC（Locality-Based LC）：基于局部性的最少连接；动态的DH算法
    + LBLCR（LBLC with Replication）：带复制的基于局部性最少连接；带复制功能的LBLC，解决了LBLC负载不均衡的问题，从负载重的RS复制到负载轻的RS
# ipvsadm命令：
+ 核心功能：
    + 集群服务管理：增、删、改

    + 集群服务的RS管理：增、删、改
    + 查看集群的管理规则
+ 集群管理命令：
    ```sh
    ipvsadm -A|E -t|u|f service-address [-s scheduler] [-p [timeout]] [-M netmask] [--pe persistence_engine] [-b sched-flags]
    #增加集群、对集群进行修改
    #    -t|u|f：
    #        -t：TCP协议的端口；VIP:TCP_PORT
    #        -u：UDP协议的端口；VIP_UDP_PORT
    #        -f：firewall MARK；标记，对集群进行分组管理
    #    [-s scheduler]：指定集群的调度算法，默认为wlc

    ipvsadm -D -t|u|f service-address
    #删除集群

    ipvsadm –C 
    #清空所有

    ipvsadm –R
    #重载

    ipvsadm –S
    #保存
    ```
    + fireWall MARK：
        ```sh
        iptables -t mangle -A PREROUTING -d $vip -p $proto –m multiport --dports $port1,$port2,… -j MARK --set-mark NUMBER
        #在Director主机打标记

        ipvsadm -A -f NUMBER [OPTIONS]
        #在Director主机基于标记定义集群服务
        ```
+ 集群中RS管理命令：
    ```sh
    ipvsadm -a|e -t|u|f service-address -r server-address [options]
    #添加RS、对RS进行修改
    #    -r：
    #        RIP[:PORT]：若省略端口，则不作端口映射
    #    lvs工作模式：
    #       -g：gateway；DR模式，为默认选项
    #       -i：ipip；TUN模式
    #       -m：masquerade；NAT模式
    #    -w：weight；权重


    ipvsadm -d -t|u|f service-address -r sever-address
    #删除RS
    ```
+ 查看：
    ```sh
    ipvsadm -L[options]
    #    --numberic，-n：以数字形式输出地址和端口号
    #    --exact：扩展信息
    #    --connection，-c：当前IPVS连接输出
    #    --stats：统计信息
    #    --rate：输出速率信息
    ```
# 保存及重载IPVS规则：
+ 保存：建议保存在/etc/sysconfig/ipvsadm
    ```
    ipvsadm-save > /PATH/TO/IPVSADM_FILE
    systemctl stop ipvsadm
    ```
+ 重载：
    ```
    ipvsadm-restore < /PATH/FROM/IPVSADM_FILE
    systemctl restart|start ipvsadm
    ```
