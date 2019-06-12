# redis主从同步：
## redis主从同步过程：
1. 从服务器连接主服务器，发送**SYNC**命令

2. 主服务器收到从服务器发来的**SYNC**命令后，执行**BGSAVE**命令，生成**RDB快照文件**并将此后执行的所有**写命令**记录在缓冲区中
3. 主服务器执行完**BGSAVE**命令后，向所有的从服务器发送快照文件（发送期间主服务器还会继续记录被执行的**写命令**）
4. 从服务器收到主服务器发送的快照文件后，丢弃所有的旧数据，载入接收到的快照文件
5. 主服务器发送完快照文件后，开始将缓冲区中的写命令发送给从服务器
6. 从服务器载入快照文件后，开始接收命令请求，并执行从主服务器缓冲区发送来的写命令
7. 以上为**全量同步**，即第一次同步时从服务器会同步全部来自主服务器的数据
8. 以后的同步（**增量同步**）从服务器会向主服务器发送自己的slave_repl_offset位置请求同步
9. 主服务器收到从服务器发来的slave_repl_offest后，查看自己的master_repl_offset位置，若通过此位置发现有新的名令执行（master_repl_offset与slave_repl_offest不一致），则执行**BGSAVE**命令，将缓冲区中的此位置后的**写命令**发送给从服务器
10. 从服务器收到新的**写命令**，执行这些命令，完成此次**增量同步**，并等待下一次**增量同步**
## redis主从配置：
+ 主从服务器的ip地址：
    + redis_master：10.1.0.1
    + redis_slave：10.1.0.2
+ 实验步骤：
    1. 编辑master的配置文件：
        ```sh
        vim /usr/local/redis/etc/redis.conf

        bind 0.0.0.0    #此项默认为127.0.0.1，无法跨主机连接，测试时改为0.0.0.0图省事，生成环境不合适
        port 6379    #监听的端口，此处使用默认值
        daemonize yes    #以守护进程启动
        logfile "/usr/local/redis/log/redis.log"    #指定日志的存放位置和文件名
        requirepass centos    #设置连接密码为“centos”
        ```

    2. 编辑slave的配置文件：
        ```sh
        vim /usr/local/redis/etc/redis.conf

        bind 0.0.0.0
        port 6379
        daemonize yes
        logfile "/usr/local/redis/log/redis.log"
        requirepass centos    #slave的密码需要设置成同master一致，因为后期slave会有提升为master的可能
        slaveof 10.1.0.1 6379    #指定master的IP和端口
        masterauth centos    #使用“centos”密码与master进行连接
        ```
    3. 重启两台redis服务器：
        + 使用systemd启动的redis：
            ```
            systemctl restart redis
            ```
        + 使用redis-server启动：
            ```sh
            kill -9 $(cat /var/run/redis_6379.pid)    #杀死原进程
            
            redis-server    #启动redis使配置文件生效
            ```
    4. 查看slave的slave状态：
        ```
        redis-cli

        10.1.0.1:6379> auth centos
        ```  
        ![avagar]()  
    5. 查看slave数据库中的内容是否与master同步：  
        ![avagar]()  
        ![avagar]()    
    6. 查看slave的日志：
        ```
        tail -10 /usr/local/redis/log/redis.log 
        ```  
        ![avagar]()  
    7. 重启redis，再次查看slave的状态：
        ```
        kill -9 $(cat /var/run/redis_6379.pid)

        redis-server
        ```  
        ![avagar]()  
    8. 在master上新增key，查看slave是否同步：  
        ![avagar]()  