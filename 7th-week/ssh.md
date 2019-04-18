# SSH（secure shell）：安全的远程登录
+ 协议：tcp
+ 端口号：22
+ 软件实现：基于C/S结构
    + openssh
    + dropbear

+ 相关包：
    + openssh
    + openssh-client
    + openssh-server
+ 配置文件：/etc/ssh/ssh_config

+ 登录认证方式：
1. 基于用户名、密码登录：
    1. 客户端发起ssh连接请求，服务端将自己的公钥发送给客户端

    2. 客户端用户使用服务器的公钥将自己的密码加密，发送给服务端
    3. 服务端使用自己的私钥将密码解密，判断密码是否正确，若正确则用户登录成功
2. 基于密钥：
    1. 客户端生成一对密钥，并把公钥发送给服务端；服务端将这个公钥存放到authority_keys中

    2. 客户端发起连接请求，此请求内容包括ip、用户名
    3. 服务端收到连接请求时，会查找authority_keys中是否有相应的IP和用户，如果有，则生成一个随机字符串，并用得到的客户端公钥将其加密，发送给客户端
    4. 收到服务端的信息后，客户端使用自己的私钥将信息解密，然后将解密得到的字符串发送给服务端
    5. 服务端收到信息，核对字符串是否一致，若一致，则允许免密登录
    + 基于密钥免密登录的实现：
    ```shell
        ssh-keygen -t rsa #在客户端生成密钥对

        ssh-copy-id HOST #将公钥传输给服务端
    ```
## 首次连接时的公钥交换
1. 客户端发起连接请求

2. 服务端将会话ID和自己的公钥发送给客户端
3. 客户端生成密钥对，用会话ID与自己的公钥做**异或**运算，将异或得出的值用服务端的公钥加密并发送给服务端
4. 服务端使用自己的私钥进行解密，用客户端异或所得值与会话ID进行异或运算，得到客户端公钥
## ssh命令：
+ 语法：
```shell
    ssh [user@]HOST [COMMAND]
    ssh [-l user]HOST [COMMAND]
```
+ 选项：
    + -p port：连接到指定的端口
    + -b：指定连接的源IP，仅在当前主机有多个IP地址时有效
    + -v：调试模式，显示调试信息
    + -C：压缩方式
    + -X：支持x11转发
    + -t：强制伪终端分配（适用于无权限连接目标主机，需要经过一个或多个主机登录的情况）
        ```
        ssh -t HOST1 ssh -t HOST2 ssh HOST3
        ```
## ssh服务器配置相关：
+ 配置文件：/etc/ssh/sshd.config
+ 常用参数：
    + port：指定sshd服务的端口
    + ListenAddress：监听的ip地址，仅当主机中有多个ip地址时才有效
    + LoginGraceTIME：用户未能成功登录时，服务器等待的时间
    + PermitRootLogin：是否允许以root身份登录
    + StrictModes：ssh接受登录请求之前是否检查用户家目录和rhosts文件的权限和所有权
    + MaxAuthTries：最大认证尝试次数
    + MaxSessions：最大会话数
    + PubkeyAuthentication：是否允许基于公钥的认证
    + PermitEmptyPasswords：是否允许空口令登录
    + PasswordAuthentication：是否允许密码认证
    + GatewayPorts：是否允许远程主机连接本机的转发端口
    + ClientAliveInterval：设置一个以秒为单位的时间，超过此时间未收到客户端的数据，则断开连接
    + ClientAliveCountMax：与客户端进行连接但并未登陆的最大数目，超过一半时，随机断开30%的连接；达到最大数目时断开所有连接
    + UseDNS：是否对远程主机进行名称反解，以检查此主机名是否与IP地址对应
    + GSSAPIauthentication：是否允许使用基于GSSAPI的用户认证
    + MaxStartups：允许有多少次验证连接请求
    + Banner：登陆前显示在用户屏幕上
+ 相对安全的ssh服务配置策略：
    + 使用非默认端口
    + 对可登陆用户进行限制
    + 设定空闲会话登陆时长
    + 利用防火墙设置ssh策略
    + 仅监听特定的IP地址
    + 基于口令认证时，使用强密码策略
    + 使用基于密钥的认证方式
    + 禁止使用空密码
    + 禁止root用户直接登陆
    + 限制ssh的访问频度和并发在线数
    + 经常分析日志
## scp命令：
+ 语法：
```
    scp [OPTIONS] [user@host:]FILE [user@host:]FILE
```
+ 常用选项：
    + -C：压缩数据流
    + -r：递归复制目录
    + -p：保持源文件的属性信息
    + -q：静默模式
    + -P PORT：指明远程主机监听的端口
## rsync命令：
>基于ssh和rsh服务在远程系统中实现高效率复制文件
+ 语法：
```
    rsync [OPTION] SRC DEST
```
+ 常用选项：
    + -n：模拟复制过程
    + -v：显示详细过程
    + -r：递归复制目录树
    + -p：保留权限
    + -t：保留时间戳
    + -g：保留组信息
    + -o：保留所有者信息
    + -l：当复制的对象是一个软链接时，复制软链接文件本身
    + -L：当复制的对象是一个软链接时，复制软链接指向的文件
    + -a：归档，相当于-rlptgoD，但不保留ACL（-A）和SELinux属性（-X）
# 轻量级自动化运维工具：
+ pssh：可在多台服务器上执行命令，也可实现文件的复制，提供了基于ssh和scp的多个并行工具
    + 语法：
    ```
        psssh [OPTION] COMMAND
    ```
    + 选项：
        + --version：查看版本信息
        + -h：记录主机列表的文件，格式为"[user@]host[:post]"
        + -H 主机字符串，格式为"[user@]host[:post] [user@]host[:post] ..."
        + -A：手动输入密码的模式
        + -i：显示每个服务器内部处理信息的输出
        + -l：登录使用的用户名
        + -p：并发的进程数
        + -o：输出的文件目录
        + -e：错误输出文件
        + -t：超时时间设置
        + -O：SSH的选项
        + -P：打印出服务器返回的信息
        + -v：显示详细信息
    + 示例：
    ```shell
        pssh -H "HOST1 HOST2 HOST3" -i 'sed -i "s/^SELINUX=.*/SELINUX=disabled/" /etc/selinux.config' #批量关闭selinux

        pssh -H "HOST1 HOST2" -i setenforce 0
        #批量关闭selinux（临时）

        pssh -H "HOST1 HOST2" -A -i setenforce 0 #手动输入密码
    ```
