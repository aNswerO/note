# bonding:
>将多块网卡绑定同一IP对外提供服务，可以实现高可用和负载均衡
## bonding配置：
1. 新建bonding文件并编辑：
```
    vim /etc/sysconfig/netwotk-scripts/bond0

    [root@localhost network-scripts]#cat ifcfg-bond0 
    DEVICE=bond0
    BOOTPROTO=none
    IPADDR=172.22.6.2
    PREFIX=16
    GATEWAY=172.22.0.1
    BONDING_OTPS="miimon=100 mode=1"
```
+ miimon：用来进行链路监测，表示多久监测一次，如果监测到一条线路不通，则转换到其他线路
+ mode：
    + mode 0（balance-rr）：轮询（Round-robin）策略，从头到尾顺序在每一个slave（bonding中指**从设备**，此处即网卡）上发送数据包，实现高可用和负载均衡
    + mode 1（active-backup）：主备策略，同一时间只有一个slave处于激活状态，仅当此slave连接出现问题时才会激活其他的slave
    + mode 3（broadcast）：广播策略，在所有slave上发送数据包，仅提供容错能力
>此bonding实验使用mode 1，即主备模式
2. 查看bonding模块是否加载
```
    lsmod | grep bonding
```
3. 加载bonding模块：
```
    modprobe --firsti-time bonding

    lsmod | grep bonding
    bonding               145728  0 
```
4. 编辑两块网卡的配置文件：
```
    vim /etc/sysconfig/netwotk-scripts/ifcfg-eth0

        BOOTPROTO="none"
        MASTER=bond0
        SLAVE=yes 
        DEVICE="eth0"
        USERCTL=no

    vim /etc/sysconfig/netwotk-scripts/ifcfg-eth1

        BOOTPROTO="none"
        MASTER=bond0
        SLAVE=yes
        DEVICE="eth1"
        USERCTL=no
```
5. 使用ip -a查看两块网卡和bond0是否均处于启用状态，若为down状态则启用
```
    ifconfig DEV up
```
6. 测试：在ping命令执行过程中，断开bonding中一块网卡的连接，可以看到在极短时间内恢复了连接
![avagar](https://github.com/aNswerO/note/blob/master/5th-week/pic/bonding.png)
