# 实现NFS服务：
+ 实验环境：两台主机
    + 一台NFS服务器，一台测试主机
1. 在NFS服务器上创建共享目录/nfsshare：
    ```
    mkdir /nfsshare

    chown nfsnobody /nfsshare
    ```
2. 在NFS服务器上编辑/etc/exports文件：
    ```sh
    vim /etc/exports

    /nfsshare 192.168.1.129(rw)
    #只允许192.168.1.129一台主机访问，且具有读写权限

    exportfs -r
    #重新加载/etc/exports中的设置，此外同步更新/etc/exports和/var/lib/nfs/xtab中的内容
    ```
3. 在测试主机（192.168.1.129）上创建要挂载到的目录：
    ```
    mkdir /mnt/fsshare
    ```
4. 在测试主机（192.168.1.129）上挂载共享目录：
    ```
    mount 192.168.1.129:/nfsshare /mnt/nfsshare
    ```
5. 测试：  
    + 服务器共享目录内容：  
        ![avagar](https://github.com/aNswerO/note/blob/master/11th-week/pic/NFS/%E6%9C%8D%E5%8A%A1%E5%99%A8%E5%85%B1%E4%BA%AB%E7%9B%AE%E5%BD%95.png)  
    + 测试：  
        ![avagar](https://github.com/aNswerO/note/blob/master/11th-week/pic/NFS/%E6%B5%8B%E8%AF%95%E6%9C%BA_1.png)
