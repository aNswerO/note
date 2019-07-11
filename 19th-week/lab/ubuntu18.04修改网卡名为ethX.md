# 1. 修改grub配置文件：
```sh
    vim /etc/default/grub
    #在GRUB\_CMDLINE_LINUX配置项中加入 net.ifname=0 biosdevname=0
```
# 2. 重新加载grub配置：
```sh
    grub-mkconfig -o /boot/grub/grub.cfg
```
# 3. 修改配置文件：
```sh
    vim /etc/netplan/01-netcfg.yaml
    #将网卡名从ensXX改为ethX
```
# 4. 重启生效：
```
    reboot
```
