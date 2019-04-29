# 准备实验环境：
+ 关闭SELinux
+ 安装如下包：
```
    yum install bison bison-devel zlib-devel libcurl-devel libarchive-devel boost-devel gcc gcc-c++ cmake ncurses-devel gnutls-devel libxml2-devel openssl-devel libevent-devel libaio-devel
```
+ 创建用户和数据目录：
```shell
    usadd -r -s /sbin/nologin -d /data/mysql mysql    #创建系统用户mysql，默认shell为nologin，指定家目录为/data/mysql（稍后创建）

    mkdir /data/mysql    #创建mysql家目录

    chown mysql:mysql /data/mysql    #修改属主、属组
```
# 编译安装：
+ 解压源码包：
```
    tar xvf mariadb-10.2.23.tar.gz
```
+ 编译安装：
```shell
    cd mariadb-10.2.23.tar.gz/

    cd mariadb-10.2.18/
    cmake . \
    -DCMAKE_INSTALL_PREFIX=/app/mysql \
    -DMYSQL_DATADIR=/data/mysql/ \
    -DSYSCONFDIR=/etc/mysql \
    -DMYSQL_USER=mysql \
    -DWITH_INNOBASE_STORAGE_ENGINE=1 \
    -DWITH_ARCHIVE_STORAGE_ENGINE=1 \
    -DWITH_BLACKHOLE_STORAGE_ENGINE=1 \
    -DWITH_PARTITION_STORAGE_ENGINE=1 \
    -DWITHOUT_MROONGA_STORAGE_ENGINE=1 \
    -DWITH_DEBUG=0 \
    -DWITH_READLINE=1 \
    -DWITH_SSL=system \
    -DWITH_ZLIB=system \
    -DWITH_LIBWRAP=0 \
    -DENABLED_LOCAL_INFILE=1 \
    -DMYSQL_UNIX_ADDR=/data/mysql/mysql.sock \
    -DDEFAULT_CHARSET=utf8 \
    -DDEFAULT_COLLATION=utf8_general_ci

    make && make install
```
# 准备环境变量：
```
    echo 'PATH=/app/mysql/bin:$PATH' > /etc/profile.d/mysql.sh

    . /etc/profile.d/mysql.sh
```
# 构建多实例对应的目录结构：
```shell
    mkdir -pv /data/mysql/{3306,3307,3308}/{data,etc,socket,log,bin.pid}

    chown -R msyql:mysql /data/mysql    #十分重要，属主属组未修改会因权限问题导致后面的步骤中mysql无法在目录下创建socket和pid文件，服务无法启动
```  
![avagar](https://github.com/aNswerO/note/blob/master/8th-week/pic/tree.png)
# 生成多实例的数据库文件：
```
    cd /app/mysql

    mysql_install_db --datadir=/data/mysql/3306/data/ --user=mysql
    mysql_install_db --datadir=/data/mysql/3307/data/ --user=mysql
    mysql_install_db --datadir=/data/mysql/3308/data/ --user=mysql
```
# 创建对应的配置文件：
```
    cp /app/mysql/support-files/my-huge.cnf /data/mysql/3306/etc
```  
![avagar](https://github.com/aNswerO/note/blob/master/8th-week/pic/3306%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B6.png)
```
    cp /app/mysql/support-files/my-huge.cnf /data/mysql/3307/etc
```  
![avagar](https://github.com/aNswerO/note/blob/master/8th-week/pic/3307%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B6.png)
```
    cp /app/mysql/support-files/my-huge.cnf /data/mysql/3308/etc
```  
![avagar](https://github.com/aNswerO/note/blob/master/8th-week/pic/3308%E9%85%8D%E7%BD%AE%E6%96%87%E4%BB%B6.png)
# 准备各实例的启动脚本：
```shell
    cp /app/mysql/support-files/mysql.server /data/mysql/3306/bin/mysqld
    cp /app/mysql/support-files/mysql.server /data/mysql/3307/bin/mysqld
    cp /app/mysql/support-files/mysql.server /data/mysql/3308/bin/mysqld


    vim /data/mysql/3306/bin/mysqld    #分别修改三个实例的启动脚本，将各自的端口号配置好
    #!/bin/bash
    port=3306
    mysql_user="root"
    mysql_pwd="centos"    #需要在之后的安全加固步骤中指定此处的口令，否则无法关闭实例
    cmd_path="/app/mysql/bin"
    mysql_basedir="/data/mysql"
    mysql_sock="${mysql_basedir}/${port}/socket/mysql.sock"

    function_start_mysql()
    {
            if [ ! -e "$mysql_sock" ];then
                    cd ${cmd_path}/../
                    ${cmd_path}/mysqld_safe --defaults-file=${mysql_basedir}/${port}/etc/my.cnf >& /dev/null &
                    printf "starting MySQL...\n"
            else
                    printf "MySQL is running.\n"
                    exit
            fi
    }

    function_stop_mysql()
    {                                                                               
            if [ ! -e "$mysql_sock" ];then
                    printf "MySQL is stopped.\n"
            else
                    printf "stopping MySQL...\n"
                    ${cmd_path}/mysqladmin -u ${mysql_user} -p${mysql_pwd} -S ${mysql_sock} shutdown
            fi
    }

    function_restart_mysql()
    {
            printf "restarting MySQL...\n"
            function_stop_mysql
            sleep 1
            function_start_mysql
    }

    case $1 in
    start)
            function_start_mysql
    ;;
    stop)
            function_stop_mysql
    ;;
    restart)
            function_restart_mysql
    ;;
    *)
            printf "usage: ${mysql_basedir}/${port/bin/mysqld} {start|stop|restart}\n"
    esac
```
# 启动/关闭实例和安全加固：
```shell
    cd /data/mysql/3306/bin

    ./mysqld start

    mysqladmin -S /data/mysql/3306/socket/mysql.sock password "centos"
    #关闭实例前需要进行安全加固

    ./mysqld stop
    #启动/关闭3306实例
    #其余实例的启动与关闭同3306
```  
![avagar](https://github.com/aNswerO/note/blob/master/8th-week/pic/mysql%E5%A4%9A%E5%AE%9E%E4%BE%8B%E7%AB%AF%E5%8F%A3%E7%A1%AE%E8%AE%A4.png)  
# 测试连接：
```
    mysql -S /data/mysql/3306/socket/mysql.sock
```  
![avagar](https://github.com/aNswerO/note/blob/master/8th-week/pic/%E6%B5%8B%E8%AF%95%E8%BF%9E%E6%8E%A5.png)
