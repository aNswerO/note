# lamp:
## 拓扑：  
  ![avagar](https://github.com/aNswerO/note/blob/master/11th-week/pic/%E6%9B%B4%E5%AE%8C%E5%96%84%E7%9A%84lamp/web%E6%9C%8D%E5%8A%A1%E5%99%A8/%E6%8B%93%E6%89%91.png)  
## 实验环境：8台主机
  + 一台测试主机
  + 一台读写分离器
  + 两台数据库服务器：一主一从
  + 一台DNS服务器
  + 一台web服务器
  + 一台NFS服务器
  + 一台NFS备份主机
## mysql读写分离：
>要先实现主从复制
1. 主服务器（192.168.1.128）配置：
    1. 修改配置文件：  
        >注意server_id，并开启二进制日志  

        ![avagar](https://github.com/aNswerO/note/blob/master/11th-week/pic/%E6%9B%B4%E5%AE%8C%E5%96%84%E7%9A%84lamp/%E6%95%B0%E6%8D%AE%E5%BA%93/%E4%B8%BB_%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B6.png)  
    2. 查看二进制日志位置信息：
        ```
        mysql> show master logs;
        ```  
        ![avagar](https://github.com/aNswerO/note/blob/master/11th-week/pic/%E6%9B%B4%E5%AE%8C%E5%96%84%E7%9A%84lamp/%E6%95%B0%E6%8D%AE%E5%BA%93/%E4%BA%8C%E8%BF%9B%E5%88%B6%E6%97%A5%E5%BF%97%E4%BD%8D%E7%BD%AE%E4%BF%A1%E6%81%AF.png)  

2. 从服务器（192.168.1.132）配置：
    1. 修改配置文件：
        >注意server_id，开启只读  

        ![avagar](https://github.com/aNswerO/note/blob/master/11th-week/pic/%E6%9B%B4%E5%AE%8C%E5%96%84%E7%9A%84lamp/%E6%95%B0%E6%8D%AE%E5%BA%93/%E4%BB%8E_%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B6.png)  
    2. 配置同步信息：
        ```
        mysql> CHANGE MASTER TO   
            MASTER_HOST='192.168.1.128',
            MASTER_USER='repluser', 
            MASTER_PASSWORD='centos', 
            MASTER_PORT=3306, 
            MASTER_LOG_FILE='mariadb_bin_log.000001', 
            MASTER_LOG_POS=245;
        ```  
        ![avagar](https://github.com/aNswerO/note/blob/master/11th-week/pic/%E6%9B%B4%E5%AE%8C%E5%96%84%E7%9A%84lamp/%E6%95%B0%E6%8D%AE%E5%BA%93/%E9%85%8D%E7%BD%AE%E5%90%8C%E6%AD%A5%E4%BF%A1%E6%81%AF.png)  
    3. 开启复制线程，并查看状态：
        ```
        mysql> start slave;

        mysql> show slave status;
        ```  
        ![avagar](https://github.com/aNswerO/note/blob/master/11th-week/pic/%E6%9B%B4%E5%AE%8C%E5%96%84%E7%9A%84lamp/%E6%95%B0%E6%8D%AE%E5%BA%93/slave%E7%8A%B6%E6%80%81.png)    
3. 测试复制：
    1. 主服务器创建一个名为testdb的数据库：
        ```
        mysql> create database testdb;
        ```
    2. 查看从服务器是否复制：
        ```
        mysql> show databases;
        ```  
        ![avagar](https://github.com/aNswerO/note/blob/master/11th-week/pic/%E6%9B%B4%E5%AE%8C%E5%96%84%E7%9A%84lamp/%E6%95%B0%E6%8D%AE%E5%BA%93/%E6%B5%8B%E8%AF%95%E6%98%AF%E5%90%A6%E5%A4%8D%E5%88%B6.png)  
4. 构建读写分离：
    1. 在主机192.168.1.129上安装proxySQL：
        + 配置yum源：
            ```
            vim /etc/yum.repos.d/proxysql.repo

            [proxysql_repo]
            name= ProxySQL YUM repository
            baseurl=http://repo.proxysql.com/ProxySQL/proxysql-1.4.x/centos/\$releasever
            gpgcheck=0          
            ```
        + 安装proxysql：
            ```
            yum install -y proxysql
            ```
    2. 使用mysql客户端连接到proxySQL的管理端口6032，默认管理员用户和密码都为“admin”：
        ```
        systemctl start proxysql
        systemctl enable proxysql
        
        mysql -uadmin -padmin -P6032 -h127.0.0.1
        ```
    3. 向proxysql中添加MySQL节点：
        ```sh
        MySQL [(none)]> insert into mysql_servers(hostgroup_id,hostname,port)values(10,'192.168.1.128',3306);

        MySQL [(none)]> insert into mysql_servers(hostgroup_id,hostname,port)values(10,'192.168.1.132',3306);

        MySQL [(none)]> load mysql servers to runtime;
        #加载到RUNTIME使之生效

        MySQL [(none)]> save mysql servers to disk;
        #写入磁盘；保存到proxysql.db文件中
        ```
    4. 在主、从节点上各添加一个用户，使读写分离器（193.168.1.129）可以复制服务器的数据：
        ```
        mysql> grant replication client on *.* to monitor@'192.168.1.129' identified by 'centos';
        ```
    5. 在读写分离器（192.168.1.132）上配置监控：
        ```
        mysql> set mysql-monitor_username='monitor';

        mysql> set mysql-monitor_password='centos';

        mysql> load mysql variables to runtime;

        mysql> save mysql variables to disk;
        ```
    6. 在读写分离器上查看监控连接是否正常：
        ```
        mysql> select * from mysql_server_connect_log;
        ```
    7. 在读写分离器上设置分组信息：
        + 设置分组：
            ```sh
            mysql> insert into mysql_replication_hostgroups values(10,20,"test");
            #mysql_replication_hostgroups表中有3个字段，分别为writer_hostgroup（写组），reader_hostgroup（读组），comment（描述内容）；此命令指定了读组的组id为20，写组的id为10

            mysql> load mysql servers to runtime;

            mysql> save mysql servers to disk;
            ```  
            ![avagar](https://github.com/aNswerO/note/blob/master/11th-week/pic/%E6%9B%B4%E5%AE%8C%E5%96%84%E7%9A%84lamp/%E6%95%B0%E6%8D%AE%E5%BA%93/proxysql%E7%9B%91%E6%8E%A7.png)  
        + 查看分组信息：
            ```sh
            mysql> select hostgroup_id,hostname,status from mysql_servers;
            #monitor模块监控后端节点的read_only值，根据此值将节点自动移动到写组或读组
            ```  
            ![avagar](https://github.com/aNswerO/note/blob/master/11th-week/pic/%E6%9B%B4%E5%AE%8C%E5%96%84%E7%9A%84lamp/%E6%95%B0%E6%8D%AE%E5%BA%93/%E6%9F%A5%E7%9C%8B%E5%88%86%E7%BB%84%E4%BF%A1%E6%81%AF.png)
    8. 实现读写分离：
        + 在后端节点创建用于测试的用户：
            ```
            mysql> grant all on *.* to sqluser@'192.168.1.129' identified by 'centos';
            ```
        + 在读写分离器上配置：
            + 设置默认访问的组：
                ```sh
                mysql> insert into mysql_users(username,password,default_hostgroup)values('sqluser','centos',10);
                #将用户sqluser添加到mysql_users表中， default_hostgroup默认组设置为写组10，当读写分离的路由规则不符合时，会访问默认组的数据库

                mysql> load mysql users to runtime;

                mysql> save mysql users to disk;
                ```
            + 配置路由规则：
                >注意：select语句中由一个特例，就是SELECT...FOR UPDATE会申请写锁，所以应路由到10的写组
                ```sh
                mysql> insert into mysql_query_rules
                (rule_id,active,match_digest,destination_hostgroup,apply)VALUES
                (1,1,'^SELECT.*FOR UPDATE$',10,1),(2,1,'^SELECT',20,1);
                #因ProxySQL根据rule_id顺序进行规则匹配，所以select ... for update规则的rule_id必须要小于普通的select规则的rule_id

                mysql> load mysql users to runtime;

                mysql> save mysql users to disk;
                
                mysql> select * from mysql_query_rules\G;
                ```  
                ![avagar](https://github.com/aNswerO/note/blob/master/11th-week/pic/%E6%9B%B4%E5%AE%8C%E5%96%84%E7%9A%84lamp/%E6%95%B0%E6%8D%AE%E5%BA%93/%E5%88%86%E7%BB%84%E4%BF%A1%E6%81%AF_1.png)  
                ![avagar](https://github.com/aNswerO/note/blob/master/11th-week/pic/%E6%9B%B4%E5%AE%8C%E5%96%84%E7%9A%84lamp/%E6%95%B0%E6%8D%AE%E5%BA%93/%E5%88%86%E7%BB%84%E4%BF%A1%E6%81%AF_2.png)  
    9. 测试：
        + 读测试
            ```
            mysql -usqluser -pcentos -P6033 -h127.0.0.1 -e 'select @@server_id';
            ```  
            ![avagar](https://github.com/aNswerO/note/blob/master/11th-week/pic/%E6%9B%B4%E5%AE%8C%E5%96%84%E7%9A%84lamp/%E6%95%B0%E6%8D%AE%E5%BA%93/%E6%B5%8B%E8%AF%95_%E8%AF%BB.png)  
        + 写测试：
            ```
            mysql -usqluser -pcentos -P6033 -h127.0.0.1 \
            -e 'start transaction;select @@server_id;commit;select @@server_id'
            ```  
            ![avagar](https://github.com/aNswerO/note/blob/master/11th-week/pic/%E6%9B%B4%E5%AE%8C%E5%96%84%E7%9A%84lamp/%E6%95%B0%E6%8D%AE%E5%BA%93/%E5%86%99_%E6%B5%8B%E8%AF%95.png)  
## NFS和实时同步：
+ 实时同步：
    1. 修改rsync服务器（192.168.1.143）的配置文件：  
        ![avagar](https://github.com/aNswerO/note/blob/master/11th-week/pic/%E6%9B%B4%E5%AE%8C%E5%96%84%E7%9A%84lamp/NFS%E5%85%B1%E4%BA%AB%E5%92%8C%E5%AE%9E%E6%97%B6%E5%90%8C%E6%AD%A5/rsync%E6%9C%8D%E5%8A%A1%E5%99%A8%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B6.png)  
    2. 在服务器生成验证文件：
        ```
        echo "rsyncuser:centos" > /etc/rsync.pass

        chmod 600 /etc/rsync.pass
        ```
    3. 创建备份目录：
        ```
        mkdir /backup
        ```
    4. 在客户端配置密码文件：
        ```
        echo "centos" > /etc/rsync.pass

        chmod 600 /etc/rsync.pass
        ```
    5. 利用脚本将**rsync**和**inotify**结合，实现监控+自动同步：
        + 脚本内容：
            ```sh
            vim inotify_rsync.sh

            #!/bin/bash
            SRC='/data/'
            DEST='rsyncuser@192.168.1.143::backup'
            inotifywait -mrq --timefmt '%Y-%m-%d %H:%M' --format '%T %w %f' -e create,delete,moved_to,close_write,attrib ${SRC} |while read DATE TIME DIR FILE;do
                    FILEPATH=${DIR}${FILE}
                    rsync -az --delete --password-file=/etc/rsync.pass $SRC $DEST && echo "At ${TIME} on ${DATE}, file $FILEPATH was backuped up via rsync" >> /var/log/changelist.log
            done
            ```
        + 在客户端（NFS服务器：192.168.1.159）运行脚本：
            ```
            bash inotify_rsync.sh
            ```
    6. 启动rsync服务器的rsync服务：
        ```
        systemctl start rsyncd
        systemctl enable rsyncd
        ```
+ NFS：
    1. 在NFS服务器（192.168.1.159）上准备好共享目录/data/（此目录下放有解压完后的wordpress）：
        ```sh
        mkdir /data

        chown -R nfsnobody /data
        #如果没有此操作，在安装wordpress时会导致无法内容自动写入wp-config.php文件
        ```
    2. 在NFS服务器上编辑/etc/exports：
        ```sh
        vim /etc/exports

        /data 192.168.1.121(rw)    #将/data目录共享给web服务器192.168.1.121 
        ```
    3. 重载配置：
        ```
        exportfs -r
        ```
    4. 在web服务器（192.168.1.121）上挂载共享目录：
        ```
        mount 192.168.1.159:/data /mnt/wordpress
        ```  
        ![avagar](https://github.com/aNswerO/note/blob/master/11th-week/pic/%E6%9B%B4%E5%AE%8C%E5%96%84%E7%9A%84lamp/NFS%E5%85%B1%E4%BA%AB%E5%92%8C%E5%AE%9E%E6%97%B6%E5%90%8C%E6%AD%A5/%E6%8C%82%E8%BD%BD.png)  
    5. 测试读写：  
        ![avagar](https://github.com/aNswerO/note/blob/master/11th-week/pic/%E6%9B%B4%E5%AE%8C%E5%96%84%E7%9A%84lamp/NFS%E5%85%B1%E4%BA%AB%E5%92%8C%E5%AE%9E%E6%97%B6%E5%90%8C%E6%AD%A5/%E6%B5%8B%E8%AF%95%E8%AF%BB%E5%86%99.png)  
        + 此时查看rsync服务器的备份目录，发现改变已同步：  
        ![avagar](https://github.com/aNswerO/note/blob/master/11th-week/pic/%E6%9B%B4%E5%AE%8C%E5%96%84%E7%9A%84lamp/NFS%E5%85%B1%E4%BA%AB%E5%92%8C%E5%AE%9E%E6%97%B6%E5%90%8C%E6%AD%A5/%E5%AE%9E%E6%97%B6%E5%90%8C%E6%AD%A5%E5%AE%8C%E6%88%90.png)  

## 在web服务器（192.168.1.121）上搭建lap（linux、apache、php）：
1. 安装httpd、php-fpm：
    ```
    yum install -y httpd php-fpm
    ```
2. 编辑/etc/php.ini文件，修改时区：
    ```
    vim /etc/php.ini
    ```  
    ![avagar](https://github.com/aNswerO/note/blob/master/11th-week/pic/%E6%9B%B4%E5%AE%8C%E5%96%84%E7%9A%84lamp/web%E6%9C%8D%E5%8A%A1%E5%99%A8/%E4%BF%AE%E6%94%B9%E6%97%B6%E5%8C%BA.png)  
3. 启动php-fpm服务和http服务：
    ```
    systemctl start php-fpm
    systemctl enable php-fpm

    systemctl start httpd
    systemctl enable httpd
    ```
4. 测试页面能否正确渲染：  
    ![avagar](https://github.com/aNswerO/note/blob/master/11th-week/pic/%E6%9B%B4%E5%AE%8C%E5%96%84%E7%9A%84lamp/web%E6%9C%8D%E5%8A%A1%E5%99%A8/%E6%B5%8B%E8%AF%95%E9%A1%B5%E9%9D%A2.png)
## lap连接数据库：
1. 在数据库主服务器（192.168.1.128）上创建wordpress数据库：
    ```
    mysql> create database wordpress;
    ```
2. 在数据库主服务器（192.168.1.128）上创建wpuser用户并授权：
    ```
    mysql> grant all on wordpress.* to wpuser@'192.168.1.129' identified by 'centos';

    mysql> flush privileges;
    ```
3. 将windows主机的hosts文件修改，添加一条记录暂时用以连接数据库：
    ```
    192.168.1.121 wwwwpsite.com
    ```  
    ![avagar](https://github.com/aNswerO/note/blob/master/11th-week/pic/%E6%9B%B4%E5%AE%8C%E5%96%84%E7%9A%84lamp/web%E6%9C%8D%E5%8A%A1%E5%99%A8/%E8%BF%9E%E6%8E%A5%E6%95%B0%E6%8D%AE%E5%BA%93.png)  
4. 填写表单，安装数据库：
    ![avagar](https://github.com/aNswerO/note/blob/master/11th-week/pic/%E6%9B%B4%E5%AE%8C%E5%96%84%E7%9A%84lamp/web%E6%9C%8D%E5%8A%A1%E5%99%A8/%E5%AE%89%E8%A3%85%E6%95%B0%E6%8D%AE%E5%BA%93.png)  
    ![avagar](https://github.com/aNswerO/note/blob/master/11th-week/pic/%E6%9B%B4%E5%AE%8C%E5%96%84%E7%9A%84lamp/web%E6%9C%8D%E5%8A%A1%E5%99%A8/%E5%AE%89%E8%A3%85%E5%AE%8C%E6%88%90.png)  
## DNS服务：
1. 安装bind：
    ```
    yum install -y bind
    ```
2. 修改主配置文件：
    ```
    vim /etc/named.conf
    ```  
    ![avagar](https://github.com/aNswerO/note/blob/master/11th-week/pic/%E6%9B%B4%E5%AE%8C%E5%96%84%E7%9A%84lamp/DNS/%E4%B8%BB%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B6.png)  
3. 修改/etc/named.rfc1912.zones文件：
    ```
    vim /etc/named.rfc1912.zones
    ```  
    ![avagar](https://github.com/aNswerO/note/blob/master/11th-week/pic/%E6%9B%B4%E5%AE%8C%E5%96%84%E7%9A%84lamp/DNS/%E5%8C%BA%E5%9F%9F%E6%96%87%E4%BB%B6.png)  
4. 以/var/named/named.localhost文件为模板，创建区域数据库文件：
    + 复制：
        ```
        cp -a /var/named/named.localhost /var/named/wpsite.com.zone
        ```
    + 修改内容：  
        ![avagar](https://github.com/aNswerO/note/blob/master/11th-week/pic/%E6%9B%B4%E5%AE%8C%E5%96%84%E7%9A%84lamp/DNS/%E5%8C%BA%E5%9F%9F%E6%95%B0%E6%8D%AE%E5%BA%93%E6%96%87%E4%BB%B6.png)  
5. 测试：
    1. 修改测试主机的/etc/resolv.d文件，将其余的行打上注释：  
        ![avagar](https://github.com/aNswerO/note/blob/master/11th-week/pic/%E6%9B%B4%E5%AE%8C%E5%96%84%E7%9A%84lamp/DNS/resolv.png)  
    2. 测试：
        ```
        curl www.wpsite.com
        ```  
        ![avagar](https://github.com/aNswerO/note/blob/master/11th-week/pic/%E6%9B%B4%E5%AE%8C%E5%96%84%E7%9A%84lamp/DNS/%E8%A7%A3%E6%9E%90%E6%88%90%E5%8A%9F.png)
