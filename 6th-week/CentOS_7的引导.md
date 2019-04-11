# CentOS 7的引导顺序：
1. UEFI或BIOS初始化，进行POST加电自检

2. 选择启动设备
3. 引导装载程序，CentOS 7是grub2
4. 加载装载程序（grub2）的配置文件
    + /etc/grub.d/
    + /etc/default/grub
    + /boot/grub2/grub.cfg
5. 加载initramfs驱动模块
6. 加载内核选项
7. 内核初始化，CentOS 7使用systemd替代init
8. 运行initrd.target所有单元，包括挂载/etc/fstab
9. 从initramfs根文件系统切换至磁盘根目录
10. systemd执行默认target配置，配置文件/etc/systemd/system/default.target
11. systemd执行sysinit.target，初始化系统及basic.target准备操作系统
12. systemd启动mutli-user.target下的本机与服务器服务
13. systemd执行mutli-user.target下的/etc/rc.d/rc.local
14. systemd执行mutli-user.target下的getty.target及登录服务
15. systemd执行graphical需要的服务
# 启动时设置内核参数：
>只影响当次启动
# 修复grub2：
+ 主要配置文件：/boot/grub2/grub.cfg
+ 修复配置文件：
```
    grub2-mkconfig > /boot/grub2/grub.cfg
```
+ 修复grub：
```shell
    grub2-install /dev/sda #BIOS环境

    grub2-install #UEFI环境
```
+ 调整默认启动内核：
```
    vim /etc/default/grub

    GRUB_DEFAULT=0
```
