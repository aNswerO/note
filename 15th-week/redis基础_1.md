# 系统缓存：
+ buffer：
```
    又名写缓冲，一般用于写操作；写数据时先将数据临时写入到内存中的buffer中，以提高写入速度，写入到buffer中后CPU就认为数据已经写入完成，之后内核的线程会在空闲的时间将数据从buffer写入磁盘；所以服务器突然断电会丢失内存中部分数据，导致数据并没有真正写入磁盘
```

+ cache：
```
    又名读缓存，一般用于读操作；CPU读取数据时先从内存中读，若内存中没有则会将数据从硬盘中读取到内存中的cache中，之后CPU从cache中读取数据；由于需要频繁读取的数据放在内存中，所以下次再读取的时候会很快
```
# reids：
## redis基础：
+ noSQL（非关系型数据库）：
    ```
        redis为key-value型数据库；是面向高性能并发读写的缓存存储，结构类似于数据结构中的hash表，每个key对应一个value，查询速度快、适用于大数据存储量和高并发操作的场合  
        key-value型非关系数据库由于具有极高的并发读写性能，所以非常适合作为缓存系统使用
    ```
+ redis的典型应用场景：
    + session共享：常见于web集群中的Tomcat或PHP中多web服务器的session共享

    + 消息队列：ELK的日志缓存、部分业务的订阅发布系统
    + 计数器：访问排行榜、商品浏览数等和次数相关的数值计算统计场景
    + 缓存：数据查询、新闻内容、电商网站的商品信息
    + 微博、微信社交场合：共同好友、点赞评论等
## redis的安装：
+ yum安装（基于epel源）：
    ```
    yum install -y redis
    ```

+ 编译安装：
    + 安装gcc：
        ```
        yum install -y gcc
        ```
    + 下载源码包并解压：
        ```
        tar xvf redis-4.0.14.tar.gz 
        ```
    + 进入解压后的目录，编译安装：
        ```
        cd redis-4.0.14/
        ```
        ```
        make PREFIX=/usr/local/redis install
        ```
        + 编译时出现“zmalloc.h:50:31: error: jemalloc/jemalloc.h: No such file or directory”的解决方法：
            ```sh
            make PREFIX=/usr/local/redis MALLOC=libc install
            #原因是jemalloc重载了Linux下的ANSI C的malloc和free函数，添加参数“MALLOC=libc”可成功编译安装
            ```
    + 创建用户：
        ```
        useradd redis -s /sbin/nologin
        ```
    + 创建能用到的目录，且修改属主属组，并将配置文件复制到/usr/local/redis/etc目录下：
        ```sh
        mkdir /usr/local/redis/{etc,data,log,run}
        #etc：存放配置文件
        #data：redis数据目录
        #log：日志目录
        #run：存放redis运行时相关的文件
        ```
        ```
        chown -R redis.redis /usr/local/redis/
        ```
        ```
        cp redis.conf /usr/local/redis/etc/
        ```
    + 编译安装后的命令：
        ```sh
        redis-benchmark    #redis的性能测试工具
        redis-check-aof    #AOF文件检查工具
        redis-check-rdb    #RDB文件检查工具
        redis-cli    #redis客户端工具
        redis-sentinel    #哨兵，它软链接到redis-server
        redis-server    #服务端
        ```
    + 为命令创建软链接：
        ```
        ln -s /usr/local/bin/redis-* /usr/bin/
        ```
    + 前台启动redis：
        ```
        redis-server /usr/local/redis/etc/redis.conf
        ```  
        ![avagar]()
        + 第一个warning：
            ```
                backlog参数控制的是三次握手的时候server端收到client ack确认号之后的队列值；修改内核参数net.core.somaxconn=512可以消除此warning  
            ```
        + 第二个warning：
            ```
                内存分配设置相关；修改内核参数vm.overcommit_memory=1可以消除此warning  

                vm.overcommit_memory=0：表示内核将检查是否有足够的可用内存供应用进程使用；如果有足够的可用内存，内存申请允许；否则，内存申请失败，并把错误返回给应用进程

                vm.overcommit_memory=1：表示内核允许分配所有的物理内存，而不管当前的内存状态如何

                vm.overcommit_memory=2：表示内核允许分配超过所有物理内存和交换空间总和的内存
            ```
        >在/etc/sysctl.conf加入“vm.overcommit_memory=1”和“net.core.somaxconn=512”来对这两个内核参数进行修改，使用“sysctl -p”命令使修改生效
        + 再次启动redis，查看warning是否消失：  
            ![avagar]()  
    + 创建一个redis服务启动脚本/usr/lib/systemd/system/redis.service，使之能通过systemd启动、重载、重启和关闭，内容如下：
        ```
        [Unit]
        Description=Redis persistent key value database
        After=network.target
        After=network-online.target
        Wants=network-online.target
        [Server]
        ExecStart=/usr/local/redis/bin/redis-server /usr/local/redis/etc/redis.conf supervised systemd
        ExecReload=/bin/kill -s HUP $MAINPID
        ExecStop=/bin/kill -s QUIT $MAINPID
        Type=notify
        User=redis
        Group=redis
        RuntimeDirectory=redis
        RuntimeDirectoryMode=0755
        [Install]
        WantedBy=multi user.target
        ```
## 连接redis：
1. 通过systemd启动，使其在后台运行：
    ```
    systemctl start redis
    ```  
    ![avagar]()  
2. 连接redis：
    + 本机非密码连接：
        ```
        redis-cli
        ```
    + 跨主机非密码连接：
        ```
        redis-cli -h HOSTNAME -p PORT
        ```
    + 跨主机密码连接：
        ```
        redis-cli -h HOSTNAME -p PORT -a PASSWORD
        ```
## redis配置文件：
+ redis的主要配置项：
    ```sh
    bind 0.0.0.0    #redis监听的地址，可用空格分隔以监听多个地址；默认为127.0.0.0
    protected-mode yes    #在没有设置bind IP和密码的时候只允许本机连接
    port 6379    #redis监听的端口
    tcp-backlog 511    #三次握手时server端收到client ack确认号之后的队列
    timeout 0    #客户端和redis服务器的连接超时时间；默认为0，表示永不超时
    tcp-keepalive 300    #会话保持时间
    daemonize no    #默认情况下，redis不是作为守护进程运行的，若想让它在后台运行，就需要把此项的值改为yes；当redis作为守护进程运行的时候，他会写一个pid文件到/var/run/目录下
    supervised no    #可以设置通过upstart和systemd管理redis守护进程，CentOS 7之后都使用systemd
    pidfile /var/run/redis_6379.pid    #pid文件路径
    loglevel notice    #日志级别
    logfile ""    #日志路径
    database 16    #设置db的数量；默认为16（索引为0~15）
    always-show-logo yes    #启动redis时是否显示logo
    save 900 1    #在900秒内有1个键发生改变就触发快照机制
    stop-writes-on-bgsave-error yes    #快照出错时是否禁止redis写入操作；默认为yes，表示禁止，建议改为no
    rdbcompression yes    #持久化到RDB文件时是否压缩
    rdbchecksum yes    #是否开启RC64校验
    dbfilename dumo.rdb    #快债的文件名
    dir ./    #快照文件保存路径
    replica-server-stale-data yes    #当从库与主库时区连接或复制正在进行，从库有两种运行方式：1）若此值为yes，从库会继续响应客户端的读请求；2）若此值为no，除去指定的命令之外的任何请求都会返回一个错误"SYNC with master in progress" 
    replica-read-sync no    #是否设置从库只读
    repl-diskless-sync no    #是否使用socket方式复制数据；目前redis复制提供两种方式：disk和socket，若新的slave连上来或重连的slave无法增量同步，就会执行全量同步，master会生成rdb文件，disk方式是master创建一个新的进程将rdb文件先保存到磁盘，再把磁盘上的rdb文件传递给slave，在一个rdb保存的过程中，多个slave都能共享这个rdb文件；socket方式是创建一个新的进程，直接把rdb文件以socket的方式发送给slave（一个一个slave顺序复制）；只有在磁盘速度缓慢但网络相对较快时才使用socket方式，否则就使用默认的disk方式
    repl-diskless-sync-delay 30    #diskless复制的延迟时间，设置0为关闭，复制开始到结束之前，master节点不会再接收新的slave复制请求，直到下一次开始
    repl-ping-slave-period 10    #slave根据master指定的时间进行周期性的PING监测
    repl-timeout 60    #复制连接的超时时间，需要大于repl-ping-slave-period，否则会经常报超时
    repl-disable-tcp-nodelay no    #在socket模式下是否在slave套接字发送SYNC之后禁用TCP_NODELAY。若此值为yes，redis将使用更少的TCP包和带宽向slaves发送数据，但这将使数据传输到slave上出现延迟；若此值为no，数据传输到slave的延迟会减少，但要使用更多的带宽
    repl-backlog-size 1mb    #复制缓冲区的大小，只有在slave连接之后才分配内存
    repl-backlog-ttl 3600    #多长时间master没有slave连接，就清空backlog缓冲区
    replica-priority 100    #当master不可用，sentinel会根据slave的优先级选举一个master；最低的优先级的slave当选master。若此值配置为0，则永远不会被选举上
    requirepass foobared    #设置redis的连接密码
    rename-command “”    #重命名一些高危命令
    maxclients 10000    #最大连接客户端
    maxmemory “”    #最大内存，单位为bytes；slave的输出缓冲区不计算在maxmemory内
    appendonly no    #是否开启AOF日志记录，默认redis使用的是rdb持久化，append only file（AOF）是另一种持久化方式，可提供更好的持久化特性。redis会把每次写入的数据在接收后都写入appendonly.aof文件，每次启动时redis都会先把这个文件的数据读入内存，先忽略RDB文件
    appendfilename “”    #AOF文件名
    appendfsync everysec    #AOF持久化策略的配置，no表示不执行fsync，由操作系统保证数据同步到磁盘；always表示每次写入都执行fsync，以保证数据同步到磁盘，everysec表示每秒执行一次fsync，可能会导致丢失这1s的数据
    no-appendfsync-on-rewrite no    #在AOFrewrite期间，是否对aof新纪录的append暂缓使用文件同步策略，主要考虑磁盘IO开支和请求阻塞时间。默认为no，表示不暂缓，新的AOF记录仍然会被立即同步；Linux的默认fsync策略是30s，若为yes，可能会丢失30s的数据，但由于yes性能较好而且会避免出现阻塞因此比较推荐
    auto-aof-rewrite-percentage 100    #当AOF log增长超过指定百分比时，重写log file，设置为0表示不自动重写AOF日志，重写是为了使AOF日志的体积保持最小，而确保保存最完整的数据
    auto-aof-rewrite-min-size 64mb    #触发aof rewrite的最小文件大小
    aof-load-truncated yes    #是否加载由于其他原因（主进程被kill、断电等）导致的末尾异常的AOF文件
    aof-use-rdb-preamble yes    #redis4.0新增的RDB-AOF混合持久化模式，在开启了这个功能后，AOF重写产生的文件将同时包含RDB格式的内容和AOF格式的内容，其中RDB格式的内容用于记录已有的数据，而AOF格式的内存则用于记录最近发生了变化的数据，这样redis就兼有RDB和AOF的有点，既能快速生成重写文件，又能在出现问题时快速地载入数据
    lua-time-limit 5000    #lua脚本的最大执行时间，单位为毫秒
    cluster-enable yes    #是否开启集群模式，默认为单机模式
    cluster-config-file nodes-6379.conf    #由node节点自动生成的集群配置文件
    cluster-node-timeout 15000    #集群中node节点连接的超时时间
    cluster-replica-validity-factor 10    #在执行故障转移的时候可能有些节点和master断开一段时间数据比较旧，这些节点就不适合用于选举为master，超过此时间的就不会被进行故障转移
    cluster-migration-barrier 1     #一个主节点拥有的至少正常工作的从节点，即如果主节点的slave节点故障后会将多余的从节点分配到当前主节点称为新的从节点
    cluster-require-full-coverage no    #集群槽位覆盖，若一个主库宕机且没有备库就会出现集群槽位不全，那么yes情况下集群槽位验证不全就不再对外提供服务，而no则可以继续使用但是会出现查询数据查不到的情况（因为有数据丢失）
    slowlog-log-slower-than 10000    #以ms为单位的慢日志记录，为负数时会禁用慢日志，为0会记录每个命令操作；slow log是redis用来记录查询执行时间的日志系统，slow log保存在内存里面，读写速度非常快，开启slow log并不会影响redis的速度
    slowlog-max-len 128    #记录多少条慢日志保存在队列，超出后会删除最早的，以此实现滚动删除
    ```
