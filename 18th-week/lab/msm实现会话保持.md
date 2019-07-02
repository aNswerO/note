# msm（memcached session manager）：
>将tomcat的session保持到memcached或redis的程序，可实现高可用
## sticky模式：
>当请求结束时，tomcat会将session送到memcached，相当于做了备份  
即tomcat的session相当于主session，memcached的session相当于备session

>当查询session时，tomcat会优先使用自己内存的session，若tomcat通过jvmRoute发现不是自己的session，就会去memcached中找该session，然后更新本机session，在请求完成后再更新memcached
```
    <t1> <t2>
    . \ / .
    .  X  .
    . / \ .
    <m1> <m2>
```
+ 修改后端服务器/usr/local/tomcat/conf/context.conf配置文件，在<context>设置段中添加如下内容：
    + backend1：
        ```
            <Manager className="de.javakaffee.web.msm.MemcachedBackupSessionManager"
                memcachedNodes="n1:192.168.6.20:11211,n2:192.168.6.21:11211"
                failoverNodes="n1"
                requestUriIgnorePattern=".*\.(ico|png|gif|jpg|css|js)$"
                transcoderFactoryClass="de.javakaffee.web.msm.serializer.kryo.KryoTranscoderFactory"
            />
        ```
    + backend2:
        ```
            <Manager className="de.javakaffee.web.msm.MemcachedBackupSessionManager"
                memcachedNodes="n1:192.168.6.20:11211,n2:192.168.6.21:11211"
                failoverNodes="n2"
                requestUriIgnorePattern=".*\.(ico|png|gif|jpg|css|js)$"
                transcoderFactoryClass="de.javakaffee.web.msm.serializer.kryo.KryoTranscoderFactory"
            />
        ```
+ 重启tomcat：
    ```
    catalina.sh stop

    catalina.sh start
    ```
+ 测试：
    + 后端服务器无故障：  
        ![avagar]()  
        ![avagar]()  
    + 运行py脚本查看memcached中session信息：
        + py脚本：
            ```py
            import memcache
            mc = memcache.Client(['192.168.6.21:11211'], debug=True)
            stats = mc.get_stats()[0]
            print(stats)
            for k,v in stats[1].items():
                print(k, v)
            print('-' * 30)
            print(mc.get_stats('items'))
            print('-' * 30)
            print(mc.get_stats('cachedump 5 0'))
            ```  
            ![avagar]()  
    + backend2故障：  
        ![avagar]()  
        ![avagar]()  
        >可以看到故障恢复后，故障节点重新恢复为主存储节点
## non-sticky模式：
>msm 1.4.0之后开始支持non-sticky模式

>tomcat session为中转session，n1为主session，n2为备session；产生的新的session会发送给主、备session，之后清除中转session

>n1因故障下线后，n2转为主session，当n1恢复上线，n2仍然为主session
+ 编辑两台后端服务器的/usr/local/tomcat/conf/context.conf配置文件，在<context>配置段中添加如下内容：
    ```conf
    <Manager className="de.javakaffee.web.msm.MemcachedBackupSessionManager"
      memcachedNodes="n1:192.168.6.20:11211,n2:192.168.6.21:11211"
      sticky="false"
      sessionBackupAsync="false"
      lockingMode="uriPattern:/path1|/path2"
      requestUriIgnorePattern=".*\.(ico|png|gif|jpg|css|js)$"
      transcoderFactoryClass="de.javakaffee.web.msm.serializer.kryo.KryoTranscoderFactory"
    />
    ```
+ 重启tomcat：
    ```
    catalina.sh stop

    catalina.sh start
    ```
+ 测试：  
    + 后端服务器无故障：  
        ![avagar]()  
        ![avagar]()  
    + backend2故障下线：  
        ![avagar]()  
    + backend2恢复上线：  
        ![avagar]()  
    >可以看到无故障时，从n2读取的sessionID；故障发生后，转而从n1读取sessionID；即使从故障恢复上线后，仍然从n1读取sessionID