# 负载均衡：
+ 负载均衡是什么：  
    ```
        负载均衡是一种服务或基于硬件设备等实现的高可用反向代理技术，负载均衡将特定的业务（web服务或网络流量）分担给指定的一个或多个后端的特定服务器或设备，从而提高了公司业务的并发处理能力、保证了业务的高可用性、方便了业务后期的水平动态扩展
    ```
+ 负载均衡的特点：
    + web服务器的动态水平扩展
        + 用户对此无感知

    + 增加业务并发访问及处理能力
        + 解决单服务器瓶颈问题
    + 节约公网IP地址
        + 降低IT支出成本
    + 隐藏内部服务器的IP
        + 提高安全性
    + 配置简单
        + 固定格式的配置文件
    + 功能丰富
        + 支持四层负载均衡或7层负载均衡
    + 性能较强
        + 并发数万甚至数十万
## 四层负载均衡和七层负载均衡的区别：
+ 四层负载均衡：
>主要通过报文中的目标地址和端口，再加上负载均衡设备设置的服务器调度方式，决定最终选择转发到的后端服务器
```
    负载均衡设备在接收到第一个来自客户端的SYN请求时，过报文中的目标地址和端口，结合负载均衡设备设置的服务器调度方式选择一个最佳的服务器，并对报文中的目标IP地址进行修改（修改为后端服务器IP），直接转发给服务器  
    TCP的三次握手是客户端和后端服务器直接建立的，负载均衡设备只起到了一个类似路由器的转发作用  
    在某些部署情况下（如lvs的fullnat工作模式），为保证服务器的响应数据包能正确返回给负载均衡设备，在转发报文的同时可能还会对报文的源地址进行修改
```

+ 七层负载均衡：
>主要通过报文中的应用层内容，再加上负载均衡设置的服务器的调度方式，决定最终选择转发到的后端服务器
```
    若负载均衡设备想要根据应用层内容选择后端服务器，只能先与客户端进行一次TCP的三次握手，才能接收到客户端发送的应用层内容的报文；然后再根据报文中应用层内容中的特定字段，结合负载均衡设备设置的服务器调度方式，选择一个最佳的服务器  
    负载均衡设备在此情况下，更类似于一个代理服务器；它与客户端和后端的服务器会分别进行一次TCP三次握手
```
# HAProxy：
+ 简介：
    ```
        HAProxy是法国开发者Willy Tarreau开发的一个开源软件，是一款具备高并发、高性能的TCP和HTTP负载均衡器，支持基于cookie的持久性，自动故障切换，支持正则表达式及web状态统计
    ```
+ 功能：
    >HAProxy是TCP/HTTP反向代理服务器，尤其适合高可用性高并发环境
    + 可以针对HTTP请求添加cookie，进行路由后端服务器

    + 可平衡负载至后端服务器，并支持持久连接
    + 支持基于cookie进行调度
    + 支持所有主服务器故障切换至备用服务器
    + 支持专用端口实现监控服务
    + 支持不影响现有连接的情况下停止接受新连接请求
    + 可以在双向添加、修改或删除HTTP报文首部
    + 支持基于pattern实现连接请求的访问控制
    + 通过特定的URI为授权用户提供详细的状态信息
# 编译安装HAProxy-1.8.20：
1. 安装所需工具：
    ```
    yum install gcc gcc-c++ glibc glibc-devel pcre pcre-devel openssl openssl-devel systemd-devel net-tools vim iotop bc zip unzip zlib-devel lrzsz tree screen lsof tcpdump wget ntpdate
    ```
2. 解包并进入目录：
    ```
    tar xvf haproxy-1.8.20.tar.gz
    ```
    ```
    cd haproxy-1.8.20
    ```
3. 编译安装：
    ```
    make ARCH=x86_64 TARGET=linux2628 USE_PCRE=1 USE_OPENSSL=1 USE_ZLIB=1 USE_SYSTEMD=1 USE_CPU_AFFINITY=1 PREFIX=/usr/local/haproxy
    ```
    ```
    make install PREFIX=/usr/local/haproxy
    ```
    ```sh
    cp haproxy /usr/sbin/
    #将haproxy程序添加到系统管理命令中
    ```
4. 创建启动脚本：
    ```
    vim /usr/lib/systemd/system/haproxy.service
    ```
    ```
    [Unit]
    Description=HAProxyLoad Balancer
    After=syslog.targetnetwork.target
    [Service]
    ExecStartPre=/usr/sbin/haproxy -f /etc/haproxy/haproxy.cfg -c -q
    ExecStart=/usr/sbin/haproxy -Ws -f /etc/haproxy/haproxy.cfg -p /run/haproxy.pid
    ExecReload=/bin/kill -USR2 $MAINPID
    [Install]
    WantedBy=multi-user.target
    ```
5. 从其他机器上拷贝一份配置文件haproxy.cfg用作本机的配置文件
    >需要将配置文件中的backend和frontend部分注释，不然无法启动haproxy服务
6. 启动haproxy服务：
    ```
    systemctl start haproxy
    ```
    ```sh
    systemctl enable haproxy
    #开机自启
    ```
