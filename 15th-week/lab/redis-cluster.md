# redis cluster：
## redis cluster的出现解决了什么问题：
```
    如果使用哨兵机制实现redis的高可用，那么无法解决redis单机写入的瓶颈问题；redis cluster为无中心架构，每个节点都和其他所有的节点连接，且保存有当前节点的数据和整个集群的状态信息
```
## redis cluster的特点：
1. 所有节点互联（通过ping机制）

2. 集群中某个节点的失效判定，是整个集群中超过半数的节点都判断为失效才认定为失效
3. 客户端直接连接redis，不经过代理；应用程序的配置需要写所有redis服务器的IP
4. redis cluster将写入的键值映射到**槽位**（slot）中，共16384个（0 ~ 16383），每个redis node（节点）上分配有一定数目的**槽位**，分配的数量取决于有多少台redis **master** node（由于需要在解决单机瓶颈的同时兼顾redis的高可用性，所以还集群中还需要主从同步）
5. 当要在cluster中写入键值时，会先通过对键做特殊运算，再用此结果对16384取模，决定将键值写入到哪个槽位中（当然也就同时决定了写入到哪个node上），这样就解决了单机的瓶颈

## redis cluster的部署：
### 创建redis cluster的前提：
+ 每个cluster节点要采用相同的硬件配置和相同的密码

+ 每个节点都要开启以下参数：
    ```sh
    cluster-enable yes
    #开启集群状态；开启这个参数后，查看进程时会有”（cluster）“显示
    cluster-config-file nodes-6379.conf
    #这个文件由集群自动创建和维护，无需手动操作
    ```
+ 所有redis节点中不能有redis数据
+ 所有节点要先启动为单机redis，且不能有任何键值
### 部署前的准备：
+ 部署redis cluster需要用到集群管理工具 —— redis-trib.rb：
    ```
        该工具集成在redis的源码目录下，由于作者是用ruby完成的，所以要使用此工具需要先安装ruby
    ```
+ 安装ruby：
    ```
        由于yum安装的ruby版本不符合要求，所以编译安装较新版本的ruby
    ```
    ```
    tar xvf ruby-2.5.5.tar.gz

    cd ruby-2.5.5

    ./configure

    make -j 2 && make install

    ln -sv /usr/local/src/ruby-2.5.5/bin/gem /usr/bin/
    ln -sv /usr/local/src/ruby-2.5.5/ruby /usr/bin/

    yum install -y rubygems
    ```
    ```
    gem install redis
    ```
    + 这一步可能会出现问题，提示缺少zlib和openssl：
        + 解决缺少zlib的问题：
            1. yum安装zlib：
                ```
                yum install -y zlib
                ```
            2. 将zlib集成到ruby环境：
                ```
                cd ls /usr/local/src/ruby-2.5.5/ext/zlib

                ruby extconf.rb
                ```
            3. 修改Makefile文件：
                ```sh
                #zlib.o: $(top_srcdir)/include/ruby.h      #为这行添加注释
                zlib.o:../../include/ruby.h    #添加此行
                ```
            4. 编译安装：
                ```
                make && make install
                ```
        + 解决缺少openssl的问题：
            1. 编译安装openssl：
                ```sh
                tar xvf openssl-1.0.2s.tar.gz

                cd openssl-1.0.2s

                ./config -fPIC --prefix=/usr/local/openssl enable-shared
                #需要配置-fPIC参数，不然后面的安装会出现问题

                make && make install
                ```
            2. 执行ruby extconf.rb：
                ```
                cd ext/openssl

                ruby extconf.rb --with-openssl-include=/usr/local/openssl/include/ --with-openssl-lib=/usr/local/openssl/lib
                ```
            3. 做一个软链接：
                ```
                ln -sv /usr/local/src/ruby-2.2.3/include /
                ```
            4. 安装：
                ```
                make && make install
                ```
### 部署集群：
1. 为集群管理工具redis-trib.rb创建一个软链接：
    ```
    ln -sv /usr/local/src/redis-4.0.14/src/redis-trib.rb /usr/bin
    ```
2. 修改密码：
    ```
    vim /usr/local/lib/ruby/gems/2.5.0/gems/redis-4.1.2/lib/redis/client.rb 
    ```  
    ![avagar](https://github.com/aNswerO/note/blob/master/15th-week/pic/redis_cluster/%E4%BF%AE%E6%94%B9%E5%AF%86%E7%A0%81.png)  
    >注意引号不能丢
3. 创建集群：
    ```
    redis-trib.rb create --replicas 1 10.1.0.1:6379 10.1.0.2:6379 10.2.0.3:6379 10.0.1.1:6379 10.0.1.2:6379 10.0.1.3:6379
    ```  
    ![avagar](https://github.com/aNswerO/note/blob/master/15th-week/pic/redis_cluster/%E5%88%9B%E5%BB%BA%E9%9B%86%E7%BE%A4.png)  
4. 查看集群信息和集群配置文件内容：
    + 配置文件内容：
        ```
        vim /usr/local/redis/etc/nodes-6379.conf
        ```  
        ![avagar](https://github.com/aNswerO/note/blob/master/15th-week/pic/redis_cluster/%E9%9B%86%E7%BE%A4%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B6%E5%86%85%E5%AE%B9.png)  
    + 集群信息：  
        ![avagar](https://github.com/aNswerO/note/blob/master/15th-week/pic/redis_cluster/%E9%9B%86%E7%BE%A4%E7%8A%B6%E6%80%81.png)  
5. 测试写入数据和同步：
    + 测试写入与同步：  
    ![avagar](https://github.com/aNswerO/note/blob/master/15th-week/pic/redis_cluster/%E6%B5%8B%E8%AF%95%E5%86%99%E5%85%A5_1.png)  
    >因为特定的槽位分配在特定的节点上，且新建不同的键时经过特殊运算后会分配到特定的槽位，所以创建新键时不能想建在哪个节点就建在哪个节点；如图中的报错，表示经过计算后得出的特定槽位为449，在0-5460之间，所以只能在10.1.0.1:6379写入，如下图  
      
    ![avagar](https://github.com/aNswerO/note/blob/master/15th-week/pic/redis_cluster/%E6%B5%8B%E8%AF%95%E5%86%99%E5%85%A5_2.png)  
    + 运气好，这次新建的键正好被分配到连接的节点上，直接写入，同步也没问题：
    ![avagar](https://github.com/aNswerO/note/blob/master/15th-week/pic/redis_cluster/%E6%B5%8B%E8%AF%95%E5%90%8C%E6%AD%A5_1.png)  
