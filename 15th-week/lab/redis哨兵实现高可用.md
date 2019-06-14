# sentinel（哨兵）：
## sentinel的存在意义：
>由于只靠redis的主从复制无法实现高可用，需要人工干预；sentinel解决了这个问题
## sentinel实现高可用的机制：
>当主节点出现故障时，sentinel会自动完成故障发现和master的转移，并通知应用方，实现了高可用
+ sentinel的配置：
    ```
        每个sentinel的配置文件都是一样的，配置文件中“sentinel monitor mymaster”项填一个共同的master节点的ip地址和端口号，并提供连接它的密码；所有的哨兵都监控这个master节点，通过向主节点发送info命令获取从节点的信息，并当有新的从节点加入时可以马上感知到
    ```

+ sentinel的定时监控：
    + 每个哨兵节点每10s会向主节点和从节点发送**info**命令获取当时的拓扑结构图

    + 每个哨兵节点每隔2s会向redis数据节点的指定频道（消息队列中的**publish/subscribe**——发布者订阅模式）上发送该节点对主节点的判断（如判断主节点已宕机——**主观宕机**）以及自己的信息，每个哨兵都会订阅该频道，通过这个频道来了解其他节点的信息以及它们对主节点的判断
    + 每个哨兵每隔1s会向所有哨兵节点和主、从节点发送一次ping命令作心跳检测，这是哨兵判断节点是否正常的依据
    + 当master哨兵节点判断主节点已宕机（**主观宕机**），此哨兵会通过“sentinel is-masterdown-by-addr”指令寻求其他哨兵节点对主节点的判断，当有超过半数的哨兵节点对主节点做出**主观宕机**的判断，此时master哨兵节点认为主节点**客观宕机**，选举新的主节点
+ master哨兵的选举：
    ```
        每个哨兵节点都可以成为master哨兵，故障转移由master哨兵处理
    ```
+ 故障转移：
    + 每个哨兵都会向主节点发送ping作存活确认，若主节点在一段时间内没有回应pong或回复了一个错误信息，那哨兵会主观地认为主节点宕机

    + 当有半数以上的哨兵主观认为主节点宕机，则触发选举，由master哨兵节点执行故障转移
    + 故障转移的过程与手动的主从迁移一致，但是是自动执行的
+ 故障转移的流程：
    1. 将一个从节点提升为主节点

    2. 将其余的从节点指向新的主节点
    3. 通知客户端主节点已更换
    4. 将原主节点降级为从节点，并指向新的主节点

## 通过哨兵实现redis高可用：
>此实验基于主从复制，要先实现主从复制；另外，主节点的配置文件需要设置masterauth项，因为在出现故障后，此主节点会被降级为从节点，需要密码连接新的主节点
1. 将解压后的源码包中的sentinel.conf复制到出来：
    ```
    cp /usr/local/src/redis-4.0.14/sentinel.conf /usr/local/redis/etc/
    ```
2. 编辑哨兵配置文件（三个哨兵的配置文件的内容一样）：
    ```
    vim /usr/local/redis/etc/sentinel.conf
    ```
    ```sh
    bind 0.0.0.0
    port 26379
    daemonize yes    #以守护进程运行
    logfile "/usr/local/redis/log/sentinel.log"    #指定日志的存放位置和文件名
    sentinel monitor mymaster 10.1.0.1 6379 2    #指定主节点的IP和端口号；后面的2是（哨兵节点总数/2 + 1），用作客观宕机的判断依据
    sentinel auth-pass mymaster centos    #用来连接主节点的密码
    ```
3. 启动redis和sentinel：
    ```
    redis-server /usr/local/redis/etc/redis.conf

    redis-sentinel /usr/local/redis/etc/sentinel.conf
    ```
4. 连接redis-server查看主从状态：
    ```
    redis-server /usr/local/redis/etc/redis.conf
    ```
    ```
    redis-cli
    ```  
    + 主节点：  
    ![avagar](https://github.com/aNswerO/note/blob/master/15th-week/pic/redis%E5%93%A8%E5%85%B5/%E4%B8%BB%E8%8A%82%E7%82%B9%E7%8A%B6%E6%80%81%E4%BF%A1%E6%81%AF.png)  
    + 从节点：  
    ![avagar](https://github.com/aNswerO/note/blob/master/15th-week/pic/redis%E5%93%A8%E5%85%B5/%E4%BB%8E%E8%8A%82%E7%82%B9%E7%8A%B6%E6%80%81%E4%BF%A1%E6%81%AF.png)  
    ![avagar](https://github.com/aNswerO/note/blob/master/15th-week/pic/redis%E5%93%A8%E5%85%B5/%E4%BB%8E%E8%8A%82%E7%82%B9%E7%8A%B6%E6%80%81_2.png)  
5. 连接redis-sentinel查看哨兵状态：
    ```
    redis-cli -h 127.0.0.1 -p 26379
    ```  
    ![avagar](https://github.com/aNswerO/note/blob/master/15th-week/pic/redis%E5%93%A8%E5%85%B5/%E5%93%A8%E5%85%B5%E7%8A%B6%E6%80%81%E4%BF%A1%E6%81%AF.png)  
    >三个哨兵节点的状态信息一致
6. 测试：
    + 停止主节点的redis服务：
        ```
        kill -9 $(cat /usr/local/redis/run/redis.pid)
        ```
    + 启动主节点的redis服务：
        ```
        redis-server /usr/local/redis/etc/redis.conf
        ```
    + 再次查看各节点的复制状态信息：  
        ![avagar](https://github.com/aNswerO/note/blob/master/15th-week/pic/redis%E5%93%A8%E5%85%B5/%E4%B8%BB%E8%8A%82%E7%82%B9%E5%88%87%E6%8D%A2%E5%90%8E%E7%9A%84%E4%B8%BB.png)  
        ![avagar](https://github.com/aNswerO/note/blob/master/15th-week/pic/redis%E5%93%A8%E5%85%B5/%E4%B8%BB%E8%8A%82%E7%82%B9%E5%88%87%E6%8D%A2%E5%90%8E%E7%9A%84%E4%BB%8E.png)  
        ![avagar](https://github.com/aNswerO/note/blob/master/15th-week/pic/redis%E5%93%A8%E5%85%B5/%E5%8E%9F%E4%B8%BB%E6%96%B0%E4%BB%8E.png)  
    + 测试新的主从关系能否实现同步：  
        ![avagar](https://github.com/aNswerO/note/blob/master/15th-week/pic/redis%E5%93%A8%E5%85%B5/%E5%86%8D%E6%AC%A1%E6%B5%8B%E8%AF%95%E5%90%8C%E6%AD%A5.png)  
