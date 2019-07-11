# docker网络：
## docker的网络类型：
### bridge：
>使用-net=bridge指定，此为默认模式
```
    使用此模式创建容器，docker会为每一个容器分配自己的网络IP信息，并将容器连接到一个虚拟网桥与外界通信
```

### host：
>使用-net=host指定
```
    使用此模式创建出的容器不会创建自己的虚拟网卡，而是直接使用宿主机的网卡和IP地址，因此在容器里查看到的IP信息就是宿主机的信息，访问容器时使用宿主机的IP和容器端口即可
    不过容器的其他资源如文件系统、系统进程还是要和宿主机保持隔离
    此模式网络性能最高，但是各容器之间端口不能相同，适用于运行容器端口比较固定的业务
```
### none：
>使用-net=none指定
```
    使用此模式创建容器后，docker不会对此容器进行任何网络配置，其没有网卡、IP，也没有路由，因此默认无法与外界通信，需要手动添加网卡，配置IP等，所以极少使用
```
### container：
>使用-net=container:容器ID或名称
```
    使用此模式创建的容器不会和宿主机共享网络配置，而是和指定的容器共享IP和端口范围，因此这个容器的端口不能和指定的容器的端口冲突，两个容器的进程可以通过lo网卡进行通信，此模式较少使用
```
# 同一宿主机中的容器间互联：
## 通过容器名称互联：
1. 创建第一个容器：
    ```
    [root@master ~]#docker run -d --name nginx1 -p 8001:80 nginx
    c0d791d52ed9b11c8c95583d9ea834950710eb8ef6223e55bff5111e8466e503
    ```
2. 查看第一个容器的hosts文件内容：  
    ![avagar](https://github.com/aNswerO/note/blob/master/19th-week/pic/docker%E7%BD%91%E7%BB%9C/%E7%AC%AC%E4%B8%80%E4%B8%AA%E5%AE%B9%E5%99%A8hosts.png)  
3. 创建第二个容器：
    ```
    [root@masterdocker run -d --name nginx2 --link nginx1 -p 8002:80 nginx
    b2d91aed87442e227668d11b5
    ```
4. 查看第二个容器的hosts文件内容：  
    ![avagar](https://github.com/aNswerO/note/blob/master/19th-week/pic/docker%E7%BD%91%E7%BB%9C/%E7%AC%AC%E4%BA%8C%E4%B8%AA%E5%AE%B9%E5%99%A8hosts.png)  
5. 检测通信：  
    ![avagar](https://github.com/aNswerO/note/blob/master/19th-week/pic/docker%E7%BD%91%E7%BB%9C/2ping1.png)  
    >第一个容器的ID和名称只会被添加到link到第一个容器的容器中，而不会将自己的ID和名称添加到第一个容器中
## 通过自定义容器别名互联：
>使用自定义容器别名，那么容器的名称就可以随意更换了，只要自定义的容器别名不变，就不会因容器名称变化而影响访问
1. 创建第三个容器：
    ```
    [root@master ~]#docker run -d --name nginx3 --link nginx1:nginx-1 -p 8010:80 nginx
    6de8f4aa609c638c060ee05d699ddc72b93788dca347efbd9b5b1436c65eb29e
    ```
2. 查看第三个容器的hosts内容：  
    ![avagar](https://github.com/aNswerO/note/blob/master/19th-week/pic/docker%E7%BD%91%E7%BB%9C/%E7%AC%AC%E4%BA%8C%E4%B8%AA%E5%AE%B9%E5%99%A8hosts.png)  
3. 检测通信：  
    ![avagar](https://github.com/aNswerO/note/blob/master/19th-week/pic/docker%E7%BD%91%E7%BB%9C/3ping1%E5%88%AB%E5%90%8D.png)  
# 跨主机容器间互联：
>要想让位于两个宿主机上的容器间进行通信，首先要保证两宿主机间是可以通信的，通过添加静态路由实现宿主机A与宿主机B间的通信  

|主机|IP|
|--|--|
|宿主机A|192.168.16.100|
|宿主机B|192.168.16.101|

1. 修改各宿主机网段：
    >由于docker的默认网段为172.17.0.X/24，且每个宿主机都是这个，因此要做路由的前提就是要使各个宿主机的网段不同
    + 修改宿主机A的docker的网段：
        ```
        [root@master ~]#vim /lib/systemd/system/docker.service 

        [root@node1 ~]#systemctl daemon-reload 

        [root@node1 ~]#systemctl restart docker
        ```
        >ubuntu修改这个文件，CentOS修改/usr/lib/systemd/system/docker.service，为service配置段中的ExecStart加上如图所示的参数  
        ![avagar](https://github.com/aNswerO/note/blob/master/19th-week/pic/docker%E7%BD%91%E7%BB%9C/%E4%BF%AE%E6%94%B9A%E5%AE%BF%E4%B8%BB%E6%9C%BA%E7%BD%91%E6%AE%B5.png)  
        + 验证网卡：  
            ![avagar](https://github.com/aNswerO/note/blob/master/19th-week/pic/docker%E7%BD%91%E7%BB%9C/A%E7%BD%91%E5%8D%A1.png)              
    + 修改宿主机B的docker的网段：  
        ![avagar](https://github.com/aNswerO/note/blob/master/19th-week/pic/docker%E7%BD%91%E7%BB%9C/%E4%BF%AE%E6%94%B9B%E5%AE%BF%E4%B8%BB%E6%9C%BA%E7%BD%91%E6%AE%B5.png)  
        + 验证网卡:  
            ![avagar](https://github.com/aNswerO/note/blob/master/19th-week/pic/docker%E7%BD%91%E7%BB%9C/B%E7%BD%91%E5%8D%A1.png)  
2. 启动两宿主机上的容器，查看网络信息：
    + 宿主机A中容器：  
        ![avagar](https://github.com/aNswerO/note/blob/master/19th-week/pic/docker%E7%BD%91%E7%BB%9C/A%E4%B8%AD%E5%AE%B9%E5%99%A8IP.png)  

    + 宿主机B中容器：
        ![avagar](https://github.com/aNswerO/note/blob/master/19th-week/pic/docker%E7%BD%91%E7%BB%9C/B%E4%B8%AD%E5%AE%B9%E5%99%A8IP.png)  
3. 为宿主机添加静态路由，网关指向对方宿主机的IP：
    + 宿主机A：
        ```
        [root@master ~]#route add -net 172.16.20.0/24 gw 192.168.6.101
        ```
        + 查看路由表：  
            ![avagar](https://github.com/aNswerO/note/blob/master/19th-week/pic/docker%E7%BD%91%E7%BB%9C/A%E8%B7%AF%E7%94%B1%E8%A1%A8.png)  
    + 宿主机B：
        ```
        [root@node1 ~]#route add -net 172.16.10.0/24 gw 192.168.6.100
        ```
        + 查看路由表：  
            ![avagar](https://github.com/aNswerO/note/blob/master/19th-week/pic/docker%E7%BD%91%E7%BB%9C/B%E8%B7%AF%E7%94%B1%E8%A1%A8.png)  
4. 如果iptables中FORWARD链的默认策略为DROP，还要在两宿主机上添加一条iptables规则：
    ```
    [root@master ~]#iptables -A FORWARD -s 192.168.6.100/24 -j ACCEPT
    ```
5. 测试互联：
    + 宿主机A ping 宿主机B：  
        ![avagar](https://github.com/aNswerO/note/blob/master/19th-week/pic/docker%E7%BD%91%E7%BB%9C/ApingB.png)  
    + 宿主机B中的容器 ping 宿主机A中的容器：  
        ![avagar](https://github.com/aNswerO/note/blob/master/19th-week/pic/docker%E7%BD%91%E7%BB%9C/A%E4%B8%AD%E5%AE%B9%E5%99%A8pingB%E4%B8%AD%E5%AE%B9%E5%99%A8.png)  
    + 宿主机B ping 宿主机A：  
        ![avagar](https://github.com/aNswerO/note/blob/master/19th-week/pic/docker%E7%BD%91%E7%BB%9C/BpingA.png)  
    + 宿主机B中的容器 ping 宿主机A中的容器：  
        ![avagar](https://github.com/aNswerO/note/blob/master/19th-week/pic/docker%E7%BD%91%E7%BB%9C/B%E4%B8%AD%E5%AE%B9%E5%99%A8pingA%E5%AE%B9%E5%99%A8.png)  
