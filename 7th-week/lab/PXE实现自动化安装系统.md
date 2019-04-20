# 实验环境准备：
+ 一台Linux虚拟机，关闭防火墙和selinux  
+ 虚拟机的网卡设置为仅主机模式，并在**虚拟网络编辑器**中关闭虚拟机的DHCP服务功能
![avagar](https://github.com/aNswerO/note/blob/master/7th-week/pic/%E8%87%AA%E5%8A%A8%E5%8C%96%E5%AE%89%E8%A3%85%E7%B3%BB%E7%BB%9F%E5%AE%9E%E9%AA%8C1.png)
+ 实验所需软件：httpd、TFTP、dhcp、system-config-kickstart、syslinux

# 实验：
## 安装软件：
```shell
    yum install -y tftp-server dhcp syslinux system-config-kickstart
```
## 开启服务：
```shell
    systemctl start dhcpd tftp httpd
```
## 配置DHCP服务：
+ 编辑配置文件：
```shell
    vim /etc/dhcp/dhcpd.conf

    option domain-name "dns";   #设置dns服务器名字
    option domain-name-servers   114.114.114.114, 223.5.5.5;    #设置dns服务器IP

    default-lease-time 600;    #设定租期
    max-lease-time 7200;    #设定最大租期

    subnet 192.168.1.0 netmask 255.255.255.0 {
        range 192.168.1.10 192.168.1.100;    #指定动态分配IP地址的地址池
        option routers 192.168.1.254;
        next-server 192.168.1.142;    #指向的tftp服务器的ip地址
        filename "pxelinux.0";
    }
```
+ 启动dhcp服务：
```
    systemctl start dhcpd
```
## 配置文件共享服务：
+ 将光盘中的内容放置到http服务器上：
```shell
    mkdir /var/www/html/centos/7
    mount /dev/sr0 /var/www/html/centos/7   #将光盘挂载到http的指定目录上
```
+ 准备kickstart文件：(https://github.com/aNswerO/note/blob/master/7th-week/files/ks7-mini.cfg)
    >注意权限：644
```shell
    cp ks7-mini.cfg /var/www/html/ks/
```
+ 浏览器访问测试:  
![avagar](https://github.com/aNswerO/note/blob/master/7th-week/pic/%E8%87%AA%E5%8A%A8%E5%8C%96%E5%AE%89%E8%A3%85%E7%B3%BB%E7%BB%9F%E5%AE%9E%E9%AA%8C2.png)  
![avagar](https://github.com/aNswerO/note/blob/master/7th-week/pic/%E8%87%AA%E5%8A%A8%E5%8C%96%E5%AE%89%E8%A3%85%E7%B3%BB%E7%BB%9F%E5%AE%9E%E9%AA%8C3.png)
+ 将必需文件放置在tftp服务器目录下：
```shell
    mkdir /var/lib/tftpboot/pxelinux.cfg/
    cp /dev/sr0/isolinux/isolinux.cfg /var/lib/tftpboot/pxelinux.cfg/default
    cp /dev/sr0/isolinux/{vmliuz,initrd.img} /var/lib/tftpboot/
    cp /usr/share/syslinux/{pxelinux.0,menu.c32} /var/lib/tftpboot/
```
### 文件列表如下图：
![avagar](https://github.com/aNswerO/note/blob/master/7th-week/pic/%E8%87%AA%E5%8A%A8%E5%8C%96%E5%AE%89%E8%A3%85%E7%B3%BB%E7%BB%9F%E5%AE%9E%E9%AA%8C4.png)
+ 准备启动菜单：
```shell
    vim /var/lib/tftpboot/pxelinux.cfg/default
```
### 启动菜单文件：
（https://github.com/aNswerO/note/blob/master/7th-week/files/default）


## 新建虚拟机测试自动化安装：
>安装CentOS7需要更大一些的内存，比如在虚拟机中的硬件设置中设置为1.5G
+ 开机按ESC，弹出如下界面，选择使用网卡通过网络启动  
![avagar](https://github.com/aNswerO/note/blob/master/7th-week/pic/%E8%87%AA%E5%8A%A8%E5%8C%96%E5%AE%89%E8%A3%85%E5%AE%9E%E9%AA%8C5.png)
+ 进入启动菜单  
![avagar](https://github.com/aNswerO/note/blob/master/7th-week/pic/%E8%87%AA%E5%8A%A8%E5%8C%96%E5%AE%89%E8%A3%85%E7%B3%BB%E7%BB%9F%E5%AE%9E%E9%AA%8C6.png)
+ 之后就可以等待系统自动安装
