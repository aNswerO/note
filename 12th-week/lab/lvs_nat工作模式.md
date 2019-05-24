# lvs-nat：
>本质是多目标IP的DNAT；通过将请求报文中的目标IP和目标port修改为某被调度的RS的RIP和port实现转发
+ 注意：
    1. **RIP**和**DIP**应在同一网络中，且应使用私网地址；**RS**的网关要指向**DIP**

    2. 请求报文和响应报文都必须经由**Director**转发；所以**Director**易成为系统瓶颈
    3. 支持端口映射，可以修改请求报文中的目标port
    4. **VS**必须是Linux主机，**RS**可以是任意主机

# 实验环境：
>关闭防火墙和SELinux
+ 一台客户端：172.22.
+ 一台lvs调度器
+ 两台web服务器
# 拓扑：  
![avagar]()  

||SRC_IP|DEST_IP|
|--|--|--|
|①|CIP（172.22.6.10）|VIP（172.22.6.200）|
|②|CIP（172.22.6.10）|RIP（192.168.1.20）|
|③|RIP（192.168.1.20）|CIP（172.22.6.10）|
|④|VIP（172.22.6.200）|CIP（172.22.6.10）|
# 实验步骤：
1. 在两台服务器上安装httpd：
    ```
    yum install -y httpd
    ```
2. 将两台服务器的监听端口都改为8080，主页内容分别设置为RS1和RS2：
    + 更改监听端口：
        ```sh
        vim /etc/httpd/conf/httpd.conf

        Listen 8080    #将本行的80改为8080
        ```
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
4. 在Director上添加集群：
    ```sh
    ipvsadm -A -t 172.22.6.200:80
    #-t后跟的IP地址是VIP
    ```
5. 为集群中添加RS：
    ```sh
    ipvsadm -a -t 172.22.6.200:80 -d 192.168.1.20:8080 -m
    ipvsadm -a -t 172.22.6.200:80 -d 192.168.1.30:8080 -m
    #-d后跟的IP地址是RIP；-m指定lvs的工作模式为nat
    ```
6. 开启Director的核心转发功能：
    + 修改配置文件：
        ```sh
        vim /etc/sysctl.conf

        net.ipv4.ip_forward=1    #添加这一行
        ```
    + 加载内核参数：
        ```sh
        sysctl -p
        #不指定文件时，默认从/etc/sysctl.conf文件中加载内核参数
        ```
7. 测试：
    + 在客户端（172.22.6.10）上执行如下命令，观察效果：
        ```
        while true;do curl 172.22.6.200;sleep 1;done
        ```  
        + 直接ping RIP显示主机不可达,但执行上述命令可以访问：  
        ![avagar]()  
        + 在两台RS上的日志中可以看到访问记录：  
        ![avagar]()  
        ![avagar]()  
        >实现了lvs调度
