# 安装dhcp：
```
    yum install -y dhcp
```
# 修改配置文件：
>httpd安装后默认没有做任何配置，通过以下命令进行配置
+ 创建配置文件
```shell
    cp /usr/share/doc/dhcp-4.2.5/dhcpd.conf.example /etc/dhcp/dhcpd.conf   #以此文件为模板进行修改，将修改后的文件作为配置文件
```
+ 修改配置如下：
```shell
    option domain-name "dns";    
    option domain-name-servers    114.114.114.114, 223.5.5.5;   

    default 6000;    
    max-lease-time 72000;  

    subnet 192.168.1.0 netmask 255.255.255.0 {
        range 192.168.1.10 192.168.1.100;
        option routers 192.168.1.251;
    }
```
# 重启dhcp服务：
```
    systemctl restart dhcpd
```
# 客户端通过dhcp服务器获取IP地址：
+ 修改同一网络中的一个客户端网卡配置文件，获取IP地址的方式改为dhcp  
![avagar](https://github.com/aNswerO/note/blob/master/7th-week/pic/%E4%BF%AE%E6%94%B9%E5%AE%A2%E6%88%B7%E7%AB%AF%E7%BD%91%E5%8D%A1%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B6.png)
+ 重启客户端网络服务：
```
    systemctl restart network
```
+ 查看是否获取到IP地址：
```
    ip a
```
![avagar](https://github.com/aNswerO/note/blob/master/7th-week/pic/%E6%B5%8B%E8%AF%95.png)
>获取到了IP地址，观察到此IP地址是DHCP服务器配置文件中地址池的第一个IP地址
