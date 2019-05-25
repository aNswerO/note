# lvs_DR工作模式：
>DR（Driect Routing）：直接路由，是LVS默认模式，应用最广泛；  
此模式通过为请求报文重新封装一个MAC首部进行转发。源MAC地址为DIP所在端口的MAC地址，目标MAC地址为某被调度的RS的RIP所在端口的MAC地址；  
在此过程中，源IP/PORT以及目标IP/PORT均保持不变

+ 注意：
    1. Director和每个RS都配置有VIP

    2. 确保前端的路由器将目标IP为VIP的请求报文发送给Director（有以下三种方法）：
        + 在前端网关将VIP和Director的MAC地址做静态绑定

        + 在RS上使用arptables工具：
            ```
            arptables -A IN -d $VIP -j DROP
            arptables -A OUT -s $VIP -j mangle --mangle-ip-s $RIP
            ```
        + 在RS上修改内核参数以限制arp通告及应答级别：
            ```sh
            /proc/sys/net/ipv4/conf/all/arp_ignore
            /proc/sys/net/ipv4/conf/all/arp_announce
            ```
    3. RS的RIP可以使用私网地址，也可以是公网地址；RIP与DIP在同一网络，同时RIP的网关不能指向DIP，因为要确保响应报文**不经由**Director
    4. RS与Director要在同一物理网络
    5. 请求报文要经由Director，但响应报文不经由Director，而是由Director直接发往Client
    6. 不支持端口映射
    7. RS可使用大多数OS系统
# 实验环境：
>关闭防火墙和SELinux
+ 一台客户端
+ 一台路由器
+ 一台调度器
+ 两台服务器
+ 拓扑：  
![avagar](https://github.com/aNswerO/note/blob/master/12th-week/pic/LVS/DR%E6%A8%A1%E5%BC%8F.png)  

||SOURCR_IP|DEST_IP|SOURCE_MAC|DEST_MAC|
|--|--|--|--|--|
|①|CIP|VIP|CIP_MAC|ROUTE_MAC|
|②|CIP|VIP|ROUTE_MAC|VIP_MAC|
|③|CIP|VIP|DIP_MAC|RS_MAC|
|④|VIP|CIP|RS_MAC|ROUTE_MAC|
|⑤|VIP|CIP|ROUTE_MAC|CIP_MAC|
# 实验步骤：
1. 在两台服务器上安装httpd：
    ```
    yum install -y httpd
    ```

2. 主页内容分别改为RS1和RS2：
    + 192.168.1.20上：
        ```
        echo RS1 > /var/www/html/index.html
        ```
    + 192.168.1.30上：
        ```
        echo RS2 > /var/www/html/index.html
        ```
    + 启动服务：
        ```
        systemctl restart httpd
        ```
3. 在Director（调度器）上安装ipvsadm：
    ```
    yum install -y ipvsadm
    ```
4. 在Director的本地回环网卡上添加一个IP作为VIP：
    ```sh
    ifconfig lo:1 192.168.1.201 netmask 255.255.255.255
    ```
5. 在Director上添加集群：
    ```sh
    ipvsadm -A -t 192.168.1.201:80 -s rr
    #-t后跟的IP地址是VIP；-s指定调度模式为轮询
    ```
6. 在集群中添加RS：
    ```sh
    ipvsadm -a -t 192.168.1.201:80 -r 192.168.1.20 -g
    #-g指定工作模式为DR；默认为此工作模式，可以不指定
    ```
7. 修改两台RS的内核参数，限制arp通告和应答：
    ```
    echo 1 > /proc/sys/net/ipv4/conf/all/arp_ignore
    echo 1 > /proc/sys/net/ipv4/conf/lo/arp_ignore
    echo 2 > /proc/sys/net/ipv4/conf/all/arp_announce
    echo 2 > /proc/sys/net/ipv4/conf/lo/arp_announce
    ```
8. 为两台RS的回环网卡添加VIP：
    ```
    ifconfig lo:1 192.168.1.201 netmask 255.255.255.255
    ```
9. 为路由器开启核心转发功能：
    ```sh
    vim /etc/sysctl.conf

    net.ipv4.ip_forward=1
    ```
10. 测试：  
    ![avagar](https://github.com/aNswerO/note/blob/master/12th-week/pic/LVS/DR%E6%B5%8B%E8%AF%95.png)
