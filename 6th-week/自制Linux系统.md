1. 为新硬盘分区
```shell
    fdisk /dev/sdb
    #/dev/sdb1对应/boot；/dev/sdb2对应/
```
2. 创建文件系统
```shell
    mkfs.ext4 /dev/sdb1
    mkfs.ext4 /dev/sdb2    
```
3. 挂载boot
```shell
    mkdir /mnt/boot
    mount /dev/sdb1 /mnt/boot
```
4. 安装grub
```shell
    grub-install --root-directory=/mnt /dev/sdb
    #--root-directory指定的是boot的根目录
```
5. 准备内核和initramfs文件
```shell
    cp /boot/vmlinuz-VERSION-RELEASE /mnt/boot
    cp /boot/initramfs-VERSION-RELEASE /mnt/boot
```
6. 创建并编辑grub.conf文件
```shell
    vim /mnt/boot/grub.conf

    title linux
    root (hd0,0)
    kernel=/vmlinuz-VERSION-RELEASE root=/dev/sdb1 selinux=0 init=/bin/bash
    initrd /initramfs-VERSION-RELEASE
```
7. 挂载以及切根
```shell
    mkdir /mnt/sysroot
    mount /dev/sdb2 /mnt/sysroot
    chroot /mnt/sysroot
```
8. 创建一级目录
```shell
    mkdir -pv /{etc,lib,lib64,bin,sbin,tmp,usr,sys,proc,opt,home,root,boot,dev,media,mnt}
```
9. 复制bash以及相关库文件
10. 复制命令以及相关库文件
