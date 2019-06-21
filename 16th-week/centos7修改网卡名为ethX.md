# 1. 修改grub配置文件：
```sh
    vim /etc/sysconfig/grub
    #在GRUB\_CMDLINE_LINUX配置项中加入 net.ifname=0 biosdevname=0
```
# 2. 重新加载grub配置：
```sh
    grub2-mkconfig -o /boot/grub2/grub.cfg
```
# 3. 修改网卡文件的文件名：
```
    mv /etc/sysconfig/network-scripts/ifcfg-ens33 /etc/sysconfig/network-scripts/ifcfg-eth0
```
# 4. 修改配置文件：
```sh
    vim /etc/sysconfig/network-scripts/ifcfg-eth0
    #NAME=eth0
    #DEVICE=eth0
    #ONBOOT=yes
```
# 5. 重启生效：
```
    reboot
```
