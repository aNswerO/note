# openVPN：
## VPN：
```
    Virtual Private Network，虚拟专有网络，用于在不安全的线路上安全地传输数据
```
## openVPN：
```
    实现VPN的开源软件，openVPN是一个健壮、高度灵活的VPN守护进程；它支持SSL/TLS安
    全、Ethernet bridging、经由代理的TCP或UDP隧道和NAT
```
## openVPN的部署：
1. 安装包（基于epel源）：
    ```
        yum install -y openvpn easy-rsa
    ```
2. 准备配置文件：
    >可利用rpm -ql命令查看包中的文件
    + 复制配置文件：
        ```
            [root@openvpn_server ~]#cp /usr/share/doc/openvpn-2.4.7/sample/sample-config-files/server.conf  /etc/openvpn
        ```
        ```
            [root@openvpn_server ~]#cp -r /usr/share/easy-rsa/ /etc/openvpn/
        ```
        ```
            [root@openvpn_server ~]#cp /usr/share/doc/easy-rsa-3.0.3/vars.example /etc/openvpn/easy-rsa/3.0.3/vars
        ```
    + 目录结构：
        ```
            [root@openvpn_server ~]#tree /etc/openvpn/
            /etc/openvpn/
            ├── client
            ├── easy-rsa
            │   ├── 3 -> 3.0.3
            │   ├── 3.0 -> 3.0.3
            │   └── 3.0.3
            │       ├── easyrsa
            │       ├── openssl-1.0.cnf
            │       ├── vars
            │       └── x509-types
            │           ├── ca
            │           ├── client
            │           ├── COMMON
            │           ├── san
            │           └── server
            ├── server
            └── server.conf

            7 directories, 9 files
        ```
3. 配置服务端：
    1. 创建PIKI：
        ```
            [root@openvpn_server ~]#cd /etc/openvpn/easy-rsa/3.0.3/
        ```
        ```
        [root@openvpn_server 3.0.3]#./easyrsa init-pki
        ```
    2. 创建CA机构：
        ```
        [root@openvpn_server 3.0.3]#./easyrsa build-ca nopass
        ```
        >上述命令执行后直接按回车
    3. 创建服务器端证书（私钥）：
        ```
        [root@openvpn_server 3.0.3]#./easyrsa gen-req server nopass
        ```
        >上述命令执行后直接按回车
        ```
        [root@openvpn_server 3.0.3]#ll ./pki/private/
        ```
        >验证CA证书
    4. 签发服务端证书：
        ```
        [root@openvpn_server 3.0.3]#./easyrsa sign server server
        ```
        ```
        [root@openvpn_server 3.0.3]#ll /etc/openvpn/easy-rsa/3.0.3/pki/issued/server.crt 
        ```
        >验证生成的服务端公钥
    5. 创建对称密钥：
        ```
        [root@openvpn_server 3.0.3]#./easyrsa gen-dh
        ```
        ```
        [root@openvpn_server 3.0.3]#ll /etc/openvpn/easy-rsa/3.0.3/pki/dh.pem 
        ```
        >验证生成的密钥
4. 配置客户端：
    1. 复制客户端配置文件：
        ```
        [root@openvpn_server 3.0.3]#cp -r /usr/share/easy-rsa/ /etc/openvpn/client/easy-rsa
        ```
        ```
        [root@openvpn_server 3.0.3]#cp /usr/share/doc/easy-rsa-3.0.3/vars.example /etc/openvpn/client/easy-rsa/vars
        ```
    2. 生成pki目录：
        ```
        [root@openvpn_server 3.0.3]#cd /etc/openvpn/client/easy-rsa/3.0.3/
        ```
        ```
        [root@openvpn_server 3.0.3]#./easyrsa init-pki
        ```
        ```
        [root@openvpn_server 3.0.3]#tree ./pki/
        ```
        >验证pki目录
    3. 生成客户端证书：
        ```
        [root@openvpn_server 3.0.3]#./easyrsa gen-req qyh nopass
        ```
        >客户证书为qyh，未设置密码
        ```
        [root@openvpn_server 3.0.3]#tree /etc/openvpn/client/easy-rsa/3.0.3/pki/
        /etc/openvpn/client/easy-rsa/3.0.3/pki/
        ├── private
        │   └── qyh.key
        └── reqs
            └── qyh.req

        2 directories, 2 files
        ```
        >验证客户端证书
    4. 签发客户端证书：
        ```
        [root@openvpn_server 3.0.3]#./easyrsa import-req /etc/openvpn/client/easy-rsa/3.0.3/pki/reqs/qyh.req qyh
        ```
        >导入req文件
        ```
        [root@openvpn_server 3.0.3]#./easyrsa sign client qyh
        ```
        >签发客户端证书
        ```
        [root@openvpn_server 3.0.3]#ll /etc/openvpn/easy-rsa/3.0.3/pki/issued/qyh.crt 
        ```
        >验证签发后的crt证书
    5. 复制证书：
        ```
        [root@openvpn_server 3.0.3]#mkdir /etc/openvpn/certs
        ```
        ```
        [root@openvpn_server 3.0.3]#cd /etc/openvpn/certs
        ```
        ```
        [root@openvpn_server certs]#cp /etc/openvpn/easy-rsa/3.0.3/pki/dh.pem .

        [root@openvpn_server certs]#cp /etc/openvpn/easy-rsa/3.0.3/pki/ca.crt .

        [root@openvpn_server certs]#cp /etc/openvpn/easy-rsa/3.0.3/pki/issued/server.crt .

        [root@openvpn_server certs]#cp /etc/openvpn/easy-rsa/3.0.3/pki/private/server.key .
        ```
        >复制证书
        ```
        [root@openvpn_server certs]#ll /etc/openvpn/certs
        ```
        >验证
    6. 准备客户端公钥和私钥：
        ```
        [root@openvpn_server certs]#mkdir /etc/openvpn/client/qyh/
        ```
        >创建目录
        ```
        [root@openvpn_server certs]#cp /etc/openvpn/easy-rsa/3.0.3/pki/ca.crt /etc/openvpn/client/qyh/

        [root@openvpn_server certs]#cp /etc/openvpn/easy-rsa/3.0.3/pki/issued/qyh.crt /etc/openvpn/client/qyh/

        [root@openvpn_server certs]#cp /etc/openvpn/client/easy-rsa/3.0.3/pki/private/qyh.key /etc/openvpn/client/qyh/
        ```
        ```
        [root@openvpn_server certs]#ll /etc/openvpn/client/qyh/
        ```
        >验证
    7. 编辑服务端配置文件：
        ```
        [root@openvpn_server certs]#vim /etc/openvpn/server.conf 
        ```
        ```sh
        local 172.20.6.41    #本机监听的IP地址
        port 1194    #监听的端口
        proto tcp    #协议；指定openVPN创建的通信隧道类型
        dev tun    #创建一个路由IP隧道，互联网使用；tap为创建一个以太网隧道，以太网使用
        ca ca.crt
        cert server.crt
        key server.key  # This file should be kept secret
        dh dh2048.pem
        server 10.8.0.0 255.255.255.0    #客户端连接后分配的地址池，服务器默认占用第一个IP
        push "route 10.1.3.0 255.255.255.0"    #为客户端生成的静态路由表，下一跳为openVPN服务器的IP地址；此处填服务端的所在局域网的网段
        client-to-client    #运行不同的client间可以直接通信
        keepalive 10 120    #设置服务器检测的间隔和超时时间
        cipher AES-256-CBC    #加密算法
        persist-key    
        persist-tun
        status openvpn-status.log    #openVPN状态记录文件，每分钟记录一次
        log-append  /var/log/openvpn/openvpn.log    #重启openVPN后在之前的日志后追加新的日志
        verb 3    #日志级别，0~9，级别越高记录内容越详细
        mute 20    #相同类别的信息只有前20条会记录到日志中
        explicit-exit-notify 1    #通知客户端，在服务端重启后可以自动重新连接，仅能用于udp模式
        ```
    8. 准备客户端配置文件：
        ```
        [root@openvpn_server qyh]#grep  "^[a-Z]" /usr/share/doc/openvpn-2.4.7/sample/sample-config-files/client.conf > /etc/openvpn/client/qyh/client.ovpn
        ```
        >将/usr/share/doc/openvpn-2.4.7/sample/sample-config-files/client.conf中的内容重定向至/etc/openvpn/client/qyh/client.ovpn，此为客户端配置文件
        ```sh
        client    #定义这是一个客户端，将配置从服务端pull（拉取）过来，如IP地址和路由信息，这些信息写在服务端的配置文件中，服务端会将这些信息push（推送）过来
        dev tun    #此处必须要和服务端保持一致
        proto tcp    #此处必须要和服务端保持一致
        remote 172.20.6.41 1194    #此处填服务端的IP地址和端口号
        resolv-retry infinite    #始终重新解析IP地址
        nobind    #本机不绑定任何端口
        persist-key
        persist-tun
        ca ca.crt    #定义ca证书
        cert qyh.crt    #定义客户端证书文件
        key qyh.key    #定义客户端密钥文件
        remote-cert-tls server    #指定采用服务端校验方式
        #tls-auth ta.key 1
        cipher AES-256-CBC    #加密算法
        verb 3    #日志级别
        ```
    9. 防火墙配置：
        ```
        [root@openvpn_server qyh]#systemctl stop firewalld

        [root@openvpn_server qyh]#systemctl disable firewalld
        ```
        >关闭firewalld服务，并关闭开机自启
        ```
        [root@openvpn_server qyh]#systemctl start iptables

        [root@openvpn_server qyh]#systemctl enable iptables
        ```
        >启动iptables服务，并设为开机自启
        ```
        [root@openvpn_server qyh]#iptables -F
        [root@openvpn_server qyh]#iptables -X
        [root@openvpn_server qyh]#iptables -Z
        ```
        >清空iptables规则
        ```
        [root@openvpn_server ~]#iptables -t nat -A POSTROUTING -s 10.1.3.0/16 -j MASQUERADE
        [root@openvpn_server ~]#iptables -A INPUT -p TCP --dport 1194 -j ACCEPT
        [root@openvpn_server ~]#iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
        ```
        >创建iptables规则
        ```
        [root@openvpn_server qyh]#vim /etc/sysctl.conf 
        ```
        >开启转发功能；在文件中添加net.ipv4.ip_forward = 1，保存后使用sysctl -p使其生效
    10. 启动openVPN服务：
        ```
        [root@openvpn_server qyh]#systemctl start openvpn@server

        [root@openvpn_server qyh]#systemctl enable openvpn@server
        ```
        >启动openVPN服务并设为开机自启
        ```
        [root@openvpn_server qyh]#ifconfig tun0
        tun0: flags=4305<UP,POINTOPOINT,RUNNING,NOARP,MULTICAST>  mtu 1500
            inet 10.8.0.1  netmask 255.255.255.255  destination 10.8.0.2
            inet6 fe80::bd4e:5e7c:4f8a:9e31  prefixlen 64  scopeid 0x20<link>
            unspec 00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00  txqueuelen 100  (UNSPEC)
            RX packets 3  bytes 180 (180.0 B)
            RX errors 0  dropped 0  overruns 0  frame 0
            TX packets 6  bytes 352 (352.0 B)
            TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
        ```
        >验证tun网卡设备
    11. 客户端验证：
        1. 在windows PC安装openVPN，官方下载地址 https://openvpn.net/community-downloads/

        2. 测试连接：
            >要将服务端/etc/openvpn/client/qyh目录下的全部文件打包发送给客户端，由客户端解压到指定目录  

            ![avagar](https://github.com/aNswerO/note/blob/master/17th-week/pic/openVPN/%E5%AE%A2%E6%88%B7%E7%AB%AF%E6%96%87%E4%BB%B6%E5%AD%98%E6%94%BE%E8%B7%AF%E5%BE%84.png)  
        3. 查看路由表：  
            ![avagar](https://github.com/aNswerO/note/blob/master/17th-week/pic/openVPN/%E6%9F%A5%E7%9C%8B%E5%AE%A2%E6%88%B7%E7%AB%AF%E8%B7%AF%E7%94%B1%E8%A1%A8.png)  
        4. 测试连接：  
            ![avagar](https://github.com/aNswerO/note/blob/master/17th-week/pic/openVPN/%E8%BF%9E%E6%8E%A5.png)  
            ![avagar](https://github.com/aNswerO/note/blob/master/17th-week/pic/openVPN/%E6%B5%8B%E8%AF%95%E8%BF%9E%E6%8E%A5.png)  
