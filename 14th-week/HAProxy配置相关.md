# HAProxy组成：
## 程序环境：
+ 主程序：/usr/sbin/haproxy

+ 配置文件：/etc/haproxy/haproxy.cfg
+ Unit file：/usr/lib/systemd/system/haproxy.service

## 配置段：
+ global（全局配置段）：
    >进程及安全配置相关的参数，性能调整相关参数，debug参数
    ```sh
    chroot    #锁定运行目录
    daemon    #以守护进程运行
    stats socket /var/lib/haproxy/stats    #指定socket文件
    user，group，uid，gid    #运行haproxy工作进程的用户身份
    nbproc    #开启的haproxy工作进程数，与CPU保持一致
    nbthread    #指定每个haproxy工作进程开启的线程数；默认为一个
    cpu-map    #绑定haproxy工作进程至指定CPU
    maxconn    #每个haproxy工作进程的最大并发连接数
    maxsslconn    #SSL每个haproxy工作进程的ssl最大连接数
    maxconnrate    #每个工作进程，每秒最大连接数
    spread-checks    #后端server状态check随机提前或延后的时间百分比；建议2~5（即20%~50%）之间
    pidfile    #指定pid文件路径
    log 127.0.0.1 local3 info    #定义全局的syslog服务器；最多可定义两个
    ```
+ proxies（代理配置段）：
    >代理服务器配置相关的参数
    ```sh
    defaults [<NAME>]    #为frontend，backend和listen提供默认配置
    frontend <NAME>    #前端，相当于nginx中的server{}
    backend <NAME>    #后端，相当于nginx中的upstream{}
    listen <NAME>    #同时拥有前端和后端的配置，将frontend和backend一起配置
    ```
    >NAME只能使用“-”、“_”、“.”和“:”，且严格区分大小写
    + defaults配置参数：
        ```sh
        option redispatch    #当server ID对应的服务器挂掉后，强制定向到其他健康的服务器
        option abortonclose    #当服务器负载很高时，自动结束掉当前队列处理比较久的连接
        option http-keep-alive    #开启会话保持
        option forwardfor    #开启IP透传
        mode http    #默认工作类型
        timeout connect 120s    #转发客户端请求到后端server的最长连接时间
        timeout server 600s    #转发客户端请求到后端server的超时时长
        timeout client 600s    #与客户端的最长空闲时间
        timeout http-keep-alive 120s    #会话保持超时时间，范围内会转发到相同的后端服务器
        timeout check 5s    #对后端server的检测超时时长
        ```
    + frontend配置参数：
        ```sh
        bind [<address>]:<port_range> [param*]    #指定HAProxy的监听地址，可以是IPv4或IPv6，可同时监听多个IP或端口，可同时用于listen字段中
        mode http/tcp    #指定负载协议类型
        use_backend BACKEND_NAME    #指定调用的后端服务器组的名称
        ```
    + backend配置参数：
        ```sh
        mode http/tcp    #指定负载协议类型
        option    #配置选项
        server    #定义后端real server
        ```
+ 后端服务器状态监测及相关配置：
    + check：对指定的real server进行健康状态监测；默认不开启
        + addr IP：指定的健康状态监测的IP

        + port NUM：指定的健康状态监测的端口
        + inter NUM：健康状态检查的时间间隔；默认为2000ms
        + fall NUM：后端服务器失效检查次数；默认为3
        + rise NUM：后端服务器从下线恢复的检查次数；默认为2
        + weight：权重；默认为1，最大为256，0表示不参与负载均衡
        + backup：将后端服务器标记为备份状态
        + disable：将后端服务器标记为不可用状态
        + redirect prefix URL：将请求临时重定向至指定URL；只适用于http模式
        + maxconn \<MAXCONN>：当前后端服务器的最大并发连接数
        + backlog \<backlog>：当后端服务器的连接数达到上限后的后援队列长度