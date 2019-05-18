# NFS（Network File System）服务：
>NFS，网络文件系统，基于内核的文件系统；基于RPC实现，使用户和程序可以像访问本地文件一样访问远程主机上的文件

>RPC（Remote Procedure Call 远程过程调用）,基于C/S架构；客户端调用进程发送一个有进程参数的调用信息到服务进程，然后等待应答信息。在服务器端，进程保持睡眠状态直到调用信息到达为止。当一个调用信息到达，服务器获得进程参数，计算结果，发送答复信息，然后等待下一个调用信息，最后，客户端调用进程接收答复信息，获得进程结果，然后调用执行继续进行
+ NFS的优势：节省了本地的存储空间，将常用的数据存放在可通过网络访问的NFS服务器上，本地终端将可以减少自身存储空间的使用
## NFS服务介绍：
+ 软件包：nfs-utils

+ 相关软件包：
    + rpcbind（必须）
    + tcp_wrappers
+ 端口：2049；其他端口由portmap（端口111）分配（CentOS-6开始，portmap进程由rpcbind代替）
+ 配置文件：
    + /etc/exports
    + /etc/exports.d/*.exports
+ NFS服务主要进程：
    + rpc.nfsd：最主要的NFS进程，管理客户端是否可以登录

    + rpc.mountd：挂载和卸载NFS文件系统，包括权限管理
    + rpc.locke：非必要；管理文件锁，避免同时写时出错
    + rpc.statd：非必要；检查文件一致性，可修复文件
+ 日志：/var/lib/nfs
## NFS配置文件：
+ 导出的文件系统的格式：
    ```
    /DIR host1(option1,option2) host2(option1,option2)
    ```
+ 主机格式：
    + 单个主机：支持IPv4、IPv6地址和FQDN
    + 某网段内的主机：支持两种掩码
    + 主机名通配：使用"*"
    + 所有主机：*
+ 权限和选项：
    ```sh
    (ro,sync,root_squash,no_all_squash)    #默认选项
    ro    #可读
    rw    #可写
    async    #异步，数据变化后不立即写入磁盘，性能高
    sync    #同步，数据在请求时立即写入共享
    no_all_squash    #默认；保留共享文件的UID和GID
    all_squash    #所有远程用户（包括root）都变成nfsnobody
    root_squash    #默认；远程root映射为nfsnobody    #UID为65534
    no_root_squash    #远程root映射成root用户
    anonuid和anongid    #指明匿名用户映射为特定用户UID和组ID，而非nfsnobody，可配合all_squash使用
    ```
## NFS工具：
+ rpcinfo：
    ```sh
    rpcinfo -p hostname
    #显示了所有注册了RPC项目的程序列表
    rpcinfo -s hostname
    #查看RPC注册程序
    ```

+ exportfs：
    ```sh
    exportfs -v 
    #查看本机所有NFS共享

    exportfs -r
    #重读配置文件，并共享目录

    exportfs -a
    #输出本机所有共享

    exportfs -au
    #停止本机所有共享
    ```
+ showmount -e：显示NFS服务器的输出清单
## 客户端NFS挂载：
+ 使用：
    ```
    mount -o OPTIONS IP:/SHARE_DIR /mnt/MOUNT_DIR
    ```

+ 挂载选项：
    ```sh
    fg：（默认）前台挂载
    bg：后台挂载
    hard：（默认）持续请求
    soft：非持续请求
    intr：和hard选项配合，可实现可中断请求
    rsize=，wsize=：一次读和写数据最大字节数
    _netdev：无网络不挂载
    ```
+ 开机挂载：写入/etc/fstab中
    ```
    IP:/SHARE_DIR   /mnt/mount_nfs  nfs defaults    0   0
    ```
